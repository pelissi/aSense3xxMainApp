#!/usr/bin/env bash
# Release kaynak paketi: ana repo + tum submodule kodlarini tek tar.gz olarak
# GitHub release'ine asset diye yukler. GitHub'in otomatik "Source code" arsivi
# submodule icermedigi (gitlink'ler bos klasor kalir) icin her release'te
# binary asset'in yaninda bu script de calistirilir.
#
# Kullanim: scripts/release_source_bundle.sh <tag> [owner/repo]
#   <tag>       : mevcut bir release tag'i (orn. v03.06.12)
#   [owner/repo]: verilmezse gh, bulundugun repodan cozer
set -euo pipefail

TAG="${1:?Kullanim: $0 <tag> [owner/repo]}"
REPO="${2:-}"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
PROJECT="$(basename "$ROOT")"
NAME="${PROJECT}_${TAG}_full-source"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Ana repo arsivleniyor..."
git archive --format=tar --prefix="$NAME/" HEAD | tar -x -C "$TMP"

# --recursive: ic ice submodule'ler de dahil; path'ler ust repoya goredir
git submodule status --recursive | awk '{print $2}' | while read -r sm; do
    echo "Submodule arsivleniyor: $sm"
    (cd "$sm" && git archive --format=tar --prefix="$NAME/$sm/" HEAD) | tar -x -C "$TMP"
done

tar -czf "$NAME.tar.gz" -C "$TMP" "$NAME"
echo "Paket: $NAME.tar.gz ($(du -h "$NAME.tar.gz" | cut -f1))"

if [ -n "$REPO" ]; then
    gh release upload "$TAG" "$NAME.tar.gz" --clobber --repo "$REPO"
else
    gh release upload "$TAG" "$NAME.tar.gz" --clobber
fi
rm -f "$NAME.tar.gz"
echo "Yuklendi: $TAG -> $NAME.tar.gz"
