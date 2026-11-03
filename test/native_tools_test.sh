#!/bin/sh
set -eu

BUN="$(pwd)/$1/bun"
OXLINT="$(pwd)/$3/oxlint"

got=$(env -i PATH=/usr/bin:/bin "$BUN" --version)
[ "$got" = "$2" ] || { echo "Bun: expected $2, got $got" >&2; exit 1; }

got=$(env -i PATH=/usr/bin:/bin "$OXLINT" --version)
case "$got" in
    *"$4"*) ;;
    *) echo "OXLint: expected $4, got $got" >&2; exit 1 ;;
esac

echo "native tool entry points are hermetic"
