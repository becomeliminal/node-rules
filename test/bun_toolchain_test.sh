#!/bin/sh
set -eu

BUN="$(pwd)/$1/bun"
got=$(env -i PATH=/usr/bin:/bin "$BUN" --version)
[ "$got" = "$2" ] || { echo "Bun: expected $2, got $got" >&2; exit 1; }

echo "Bun tool entry point is hermetic"
