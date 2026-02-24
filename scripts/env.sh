#!/usr/bin/env bash
#
# ============================================================================
# Environment Activation Script
#
# This script activates the Belle II minimal dependency stack by exporting
# environment variables required for:
#
#   * Runtime library resolution
#   * Header resolution for downstream builds
#   * pkg-config metadata discovery
#
# Design Goals:
#   * Prefix isolation (no reliance on system-installed libraries)
#   * Clean activation for downstream software
#   * Cross-shell compatibility (bash and zsh)
#   * Explicit and reproducible environment configuration
#
# Usage:
#   source scripts/env.sh
#
# This script must be sourced (not executed) to modify the current shell.
# ============================================================================
#

# ---------------------------------------------------------------------------
# Robust Project Root Detection
# ---------------------------------------------------------------------------
#
# Supports both bash and zsh. BASH_SOURCE is used when available;
# otherwise fallback to $0.
#

if [ -n "${BASH_SOURCE[0]}" ]; then
    SCRIPT_PATH="${BASH_SOURCE[0]}"
else
    SCRIPT_PATH="$0"
fi

SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Installation prefix
export B2STACK="$ROOT/prefix"


# ---------------------------------------------------------------------------
# Runtime Environment Configuration
# ---------------------------------------------------------------------------

# Ensure stack binaries are resolved before system binaries.
export PATH="$B2STACK/bin:$PATH"

# Ensure dynamic linker resolves stack-managed shared libraries first.
# This enables correct runtime resolution of:
#   - libsqlite3
#   - liblzma
#   - libffi
#
# Note:
#   System libraries such as glibc remain system-resolved.
#
export LD_LIBRARY_PATH="$B2STACK/lib:$LD_LIBRARY_PATH"

# Ensure pkg-config resolves metadata from the local prefix.
export PKG_CONFIG_PATH="$B2STACK/lib/pkgconfig:$PKG_CONFIG_PATH"

# Ensure downstream builds resolve headers and libraries from prefix.
export CPPFLAGS="-I$B2STACK/include"
export LDFLAGS="-L$B2STACK/lib"

echo "Activated Belle II mini stack at $B2STACK"