#!/usr/bin/env bash
#
# ============================================================================
# Isolation Verification Script
#
# This script verifies that stack-managed dependencies are correctly resolved
# from the local installation prefix rather than from system locations.
#
# Specifically checks dynamic extension modules for:
#   - libsqlite3  (Python _sqlite3 module)
#   - liblzma     (Python _lzma module)
#   - libffi      (Python _ctypes module)
#
# Important:
#   The main python3 binary does NOT directly link against these libraries.
#   They are linked via dynamically loaded extension modules located under:
#
#       prefix/lib/pythonX.Y/lib-dynload/
#
# Isolation Scope:
#   ✔ libsqlite3 must resolve from PREFIX
#   ✔ liblzma must resolve from PREFIX
#   ✔ libffi must resolve from PREFIX
#
#   ✖ System libraries such as:
#       - libc
#       - libm
#       - libdl
#       - dynamic loader (ld-linux)
#     are intentionally allowed.
#
# Usage:
#   scripts/check_isolation.sh <prefix>
# ============================================================================

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <prefix>"
    exit 1
fi

PREFIX="$1"
PYTHON_LIB_DIR=$(find "$PREFIX/lib" -maxdepth 1 -type d -name "python*" | head -n1)

if [ -z "$PYTHON_LIB_DIR" ]; then
    echo "ERROR: Could not locate python library directory under $PREFIX/lib"
    exit 1
fi

DYNLOAD_DIR="$PYTHON_LIB_DIR/lib-dynload"

if [ ! -d "$DYNLOAD_DIR" ]; then
    echo "ERROR: Could not locate lib-dynload directory."
    exit 1
fi

echo "Inspecting dynamic modules in:"
echo "  $DYNLOAD_DIR"
echo

check_module() {
    MODULE_PATTERN="$1"
    LIB_NAME="$2"

    MODULE_PATH=$(ls "$DYNLOAD_DIR"/$MODULE_PATTERN 2>/dev/null | head -n1 || true)

    if [ -z "$MODULE_PATH" ]; then
        echo "ERROR: Could not find module matching $MODULE_PATTERN"
        exit 1
    fi

    LDD_OUTPUT=$(ldd "$MODULE_PATH")

    if echo "$LDD_OUTPUT" | grep "$LIB_NAME" | grep -q "$PREFIX"; then
        echo "OK: $LIB_NAME is linked from prefix."
    else
        echo "ERROR: $LIB_NAME is NOT linked from prefix."
        echo
        echo "Detected linkage:"
        echo "$LDD_OUTPUT"
        exit 1
    fi
}

check_module "_sqlite3*.so" "libsqlite3"
check_module "_lzma*.so" "liblzma"
check_module "_ctypes*.so" "libffi"

echo
echo "Isolation check passed."