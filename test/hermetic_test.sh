#!/bin/sh
# node is a real binary; npm, npx and corepack are JavaScript. Run each the way
# a rule is meant to, with no node on $PATH, so a regression to the bin/ symlinks
# (which resolve node from $PATH) fails here rather than silently on a host that
# happens to have one installed.
set -eu

TOOLCHAIN="$(pwd)/$1"
EXPECTED_NODE="$2"
NODE="$TOOLCHAIN/bin/node"
fails=0

check() {
    name="$1"; expected="$2"; shift 2
    got=$(env -i PATH=/usr/bin:/bin "$@" --version 2>&1 | tail -1) || true
    if [ "$got" = "$expected" ]; then
        echo "ok       $name -> $got"
    else
        echo "FAIL     $name -> expected '$expected', got '$got'" >&2
        fails=$((fails + 1))
    fi
}

check node "$EXPECTED_NODE" "$NODE"

NPM="$TOOLCHAIN/lib/node_modules/npm/bin/npm-cli.js"
NPM_VERSION=$(env -i PATH=/usr/bin:/bin "$NODE" "$NPM" --version 2>&1 | tail -1)
check npm "$NPM_VERSION" "$NODE" "$NPM"
check npx "$NPM_VERSION" "$NODE" "$TOOLCHAIN/lib/node_modules/npm/bin/npx-cli.js"

[ "$fails" -eq 0 ] || exit 1
echo "entry points are hermetic"
