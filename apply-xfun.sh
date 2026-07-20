#!/usr/bin/env bash
# apply-xfun.sh - apply the xfun (Blackbird fun ISA) patch to the binutils
# submodule of this riscv-gnu-toolchain checkout.
#
#   git submodule update --init binutils     # if not already checked out
#   ./apply-xfun.sh                          # apply
#   ./apply-xfun.sh --check                  # dry run, change nothing
#   ./apply-xfun.sh --revert                 # undo
#
# Then build/install the toolchain as usual, e.g.
#   ./configure --prefix=/opt/riscv --with-arch=rv32ima_zicsr --with-abi=ilp32
#   make
#
# Verify afterwards:
#   /opt/riscv/bin/riscv32-unknown-elf-as -march=rv32imf_zicsr_xfun f.S -o f.o
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
PATCH="$HERE/patches/0001-riscv-xfun-fn-assembler-support.patch"
SRC="$HERE/binutils"

[ -f "$PATCH" ] || { echo "apply-xfun: missing $PATCH" >&2; exit 1; }
[ -d "$SRC/gas" ] || {
    echo "apply-xfun: binutils submodule not checked out." >&2
    echo "            run: git submodule update --init binutils" >&2
    exit 1
}

MODE="apply"
case "${1:-}" in
    --check)  MODE="check" ;;
    --revert) MODE="revert" ;;
    "")       ;;
    *) echo "usage: $0 [--check|--revert]" >&2; exit 1 ;;
esac

cd "$SRC"
case "$MODE" in
    check)
        patch -p1 --dry-run < "$PATCH" && echo "apply-xfun: applies cleanly"
        ;;
    revert)
        patch -p1 -R < "$PATCH" && echo "apply-xfun: reverted"
        ;;
    apply)
        if patch -p1 --dry-run -R --force < "$PATCH" >/dev/null 2>&1; then
            echo "apply-xfun: already applied, nothing to do"
            exit 0
        fi
        patch -p1 < "$PATCH"
        echo "apply-xfun: applied to $SRC"
        echo "apply-xfun: now configure + make the toolchain (see the top of this script)"
        ;;
esac
