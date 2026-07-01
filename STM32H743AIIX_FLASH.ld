/*
******************************************************************************
**
**  File        : LinkerScript.ld
**
**  Author      : STM32CubeIDE
**
**  Abstract    : Linker script for STM32H7 series
**                2048Kbytes FLASH and 1056Kbytes RAM
**
**                Set heap size, stack size and stack location according
**                to application requirements.
**
**                Set memory bank area and size if external memory is used.
**
**  Target      : STMicroelectronics STM32
**
**  Distribution: The file is distributed as is, without any warranty
**                of any kind.
**
*****************************************************************************
** @attention
**
** Copyright (c) 2025 STMicroelectronics.
** All rights reserved.
**
** This software is licensed under terms that can be found in the LICENSE file
** in the root directory of this software component.
** If no LICENSE file comes with this software, it is provided AS-IS.
**
****************************************************************************
*/

/* Entry Point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = ORIGIN(RAM_D1) + LENGTH(RAM_D1);    /* end of RAM */
/* Generate a link error if heap and stack don't fit into RAM */
_Min_Heap_Size = 0x25000;      /* required amount of heap  */
_Min_Stack_Size = 0x1000; /* required amount of stack */
_NonCacheable_RamD1_length 	= 0x8000;
_ed2stack	= ORIGIN(RAM_D2) + LENGTH(RAM_D2);    /* end of RAM */
_Min_D2Stack_Size = LENGTH(RAM_D2);
_Min_D2_Heap_Size = 0x20000;	/* 128K: D1 heap dolunca _sbrk'in tastigi D2 fallback heap'i */
_ed3stack	= ORIGIN(RAM_D3) + LENGTH(RAM_D3);    /* end of RAM */
_Min_D3Stack_Size = LENGTH(RAM_D3);


/* Specify the memory areas */
MEMORY
{
  FLASH_FSBL (rx)     			: ORIGIN = 0x08000000, LENGTH = 128K * 1
  FLASH_PROG_INFO (rx)   		: ORIGIN = 0x08020000, LENGTH = 128K * 1
  FLASH_BOOTLOADER (rx)     	: ORIGIN = 0x08040000, LENGTH = 128K * 4
  FLASH_NON_VOLATILE_MEM (rwx)  : ORIGIN = 0x080C0000, LENGTH = 128K * 2
  FLASH_MAIN_APP (rx)			: ORIGIN = 0x08100000, LENGTH = 128K * 8
  DTCMRAM (xrw)  				: ORIGIN = 0x20000000, LENGTH = 128K
  RAM_D1 (xrw)   				: ORIGIN = 0x24000000, LENGTH = 512K - _NonCacheable_RamD1_length
  RAM_NON_CACHE (xrw) 			: ORIGIN = 0x24000000 + LENGTH(RAM_D1), LENGTH = _NonCacheable_RamD1_length
  RAM_D2 (xrw)   				: ORIGIN = 0x30000000, LENGTH = 288K
  RAM_D3 (xrw)   				: ORIGIN = 0x38000000, LENGTH = 64K
  ITCMRAM (xrw)  				: ORIGIN = 0x00000000, LENGTH = 64K
}

/* Define output sections */
SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >FLASH_MAIN_APP
  
  /*--- New CCMRAM linker section definition ---*/
  _siccmram = LOADADDR(.ccmram);
  /* CCMRAM section */
  .ccmram :
  {
   . = ALIGN(4);
   _sccmram = .; /* define a global symbols at ccmram start */
   *(.ccmram)
   *(.ccmram*)
    KEEP(*tx_*.o (.text*))
    KEEP(*txe_*.o (.text*))
    KEEP(*posix*.o (.text*))
    *ThreadXFlagWrapper.o(.text .text*)
    *ThreadXMutexWrapper.o(.text .text*)
    *ThreadXSemWrapper.o(.text .text*)
    *ThreadXQueueWrapper.o(.text .text*)
    *ThreadXTimerWrapper.o(.text .text*)
    *ThreadXCriticalSection.o(.text .text*)
    *OsWrapperIf.o(.text .text*)
    *STM32H7DeviceTime.o(.text .text*)
    *CppWrapper.o(.text .text*)
    *stm32h7xx_it.o(.text .text*)
    *stm32h7xx_hal.o(.text .text*)
    /* *stm32h7xx_hal_adc.o(.text .text*)
    *stm32h7xx_hal_adc_ex.o(.text .text*) */
    *stm32h7xx_hal_uart.o(.text .text*)
    *stm32h7xx_hal_uart_ex.o(.text .text*)
    *stm32h7xx_hal_tim.o(.text .text*)
    *stm32h7xx_hal_tim_ex.o(.text .text*)
    /* *stm32h7xx_hal_spi.o(.text .text*)
    *stm32h7xx_hal_spi_ex.o(.text .text*) */
    /* *stm32h7xx_hal_gpio.o(.text .text*)
    *stm32h7xx_hal_gpio_ex.o(.text .text*) */
    *stm32h7xx_hal_exti.o(.text .text*)
    *stm32h7xx_hal_dma.o(.text .text*)
    *stm32h7xx_hal_dma_ex.o(.text .text*)
   . = ALIGN(4);
    _eccmram = .; /* define a global symbols at ccmram end */
  } >ITCMRAM AT> FLASH_MAIN_APP
 /*--- End of CCMRAM linker section definition ---*/

  /* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)

    KEEP (*(.init))
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >FLASH_MAIN_APP

  /* Constant data goes into FLASH */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    . = ALIGN(4);
  } >FLASH_MAIN_APP

  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH_MAIN_APP
  .ARM : {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } >FLASH_MAIN_APP

  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASH_MAIN_APP

  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASH_MAIN_APP

  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >FLASH_MAIN_APP
  
    
  .flash_rest_fsbl (NOLOAD) :
  {
    . = ALIGN(4);
    *(.flash_rest_fsbl)           /* .flash_rest sections (data) */
    . = ALIGN(4);
  } >FLASH_FSBL
    
  .flash_rest_prog_info (NOLOAD) :
  {
    . = ALIGN(4);
    *(.flash_rest_prog_info)           /* .flash_rest sections (data) */
    . = ALIGN(4);
  } >FLASH_PROG_INFO
  
    .flash_rest_boot (NOLOAD) :
  {
    . = ALIGN(4);
    *(.flash_rest_boot)           /* .flash_rest sections (data) */
    . = ALIGN(4);
  } >FLASH_BOOTLOADER
  
  .flash_rest_non_vol_mem (NOLOAD) :
  {
    . = ALIGN(4);
    *(.flash_rest_non_vol_mem)           /* .flash_rest sections (data) */
    . = ALIGN(4);
  } >FLASH_NON_VOLATILE_MEM

  /* used by the startup to initialize data */
  _sidata = LOADADDR(.data);

  /* Initialized data sections goes into RAM, load LMA copy after code */
  .data :
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */
    *(.RamFunc)        /* .RamFunc sections */
    *(.RamFunc*)       /* .RamFunc* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >RAM_D1 AT> FLASH_MAIN_APP

  /* Uninitialized data section */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss section */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >RAM_D1

  /* User_heap_stack section, used to check that there is enough RAM left */
  ._user_heap_stack :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >RAM_D1

  /* Remove information from the standard libraries */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }
  
  .itcm (NOLOAD) :
  {
    . = ALIGN(4);
    *(.itcm)           /* .itcm sections (code) */
    . = ALIGN(4);
  } >ITCMRAM
  
  /* D2 fallback heap: D1 heap doldugunda _sbrk() buraya tasar (bkz. sysmem2.c) */
  ._heap_d2 (NOLOAD) :
  {
    . = ALIGN(8);
    PROVIDE ( _heap_d2_start = . );
    . = . + _Min_D2_Heap_Size;
    PROVIDE ( _heap_d2_end = . );
    . = ALIGN(8);
  } >RAM_D2

  .ram_d2 (NOLOAD) :
  {
    . = ALIGN(8);
    PROVIDE ( d2end = . );
    PROVIDE ( _d2end = . );
    . = . + (_Min_D2Stack_Size - _Min_D2_Heap_Size);
    . = ALIGN(8);
  }>RAM_D2
  
  .ram_d3 (NOLOAD) :
  {
    . = ALIGN(8);
    PROVIDE ( d3end = . );
    PROVIDE ( _d3end = . );
    . = . + _Min_D3Stack_Size;
    . = ALIGN(8);
  }>RAM_D3
  
    .dtcm (NOLOAD) :
  {
    . = ALIGN(4);
    *(.dtcm)           /* .dtcm sections (data) */
    . = ALIGN(4);
  } >DTCMRAM
  
  /* yusuf non cacheable area    */
  .DATA_RAM_NOCACHE (NOLOAD) :
 {  . = ALIGN(4);
  *(.DATA_RAM_NOCACHE)     
  *(.DATA_RAM_NOCACHE*) 
  . = ALIGN(4);
 } >RAM_NON_CACHE 
  

  .ARM.attributes 0 : { *(.ARM.attributes) }
}

