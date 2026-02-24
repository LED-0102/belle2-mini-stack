#!/usr/bin/env bash
#
# ============================================================================
# Checksum Verification Script
#
# This script verifies the SHA256 checksum of a downloaded source tarball.
#
# Design Goals:
#   * Deterministic builds
#   * Supply-chain integrity enforcement
#   * Fail-fast behavior on corruption or tampering
#
# This script is invoked by the DOWNLOAD_template rule in common.mk.
# Checksum verification is enforced even when a tarball already exists,
# ensuring reproducibility and protection against partial or modified files.
#
# Usage:
#   verify_checksum.sh <file> <checksum_file>
#
# The checksum file must contain a line of the form:
#   <sha256>  downloads/<filename>
#
# Any mismatch results in immediate build failure.
# ============================================================================

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 <file> <checksum_file>"
    exit 1
fi

FILE="$1"
CHECKSUM_FILE="$2"

if [ ! -f "$FILE" ]; then
    echo "ERROR: File not found: $FILE"
    exit 1
fi

if [ ! -f "$CHECKSUM_FILE" ]; then
    echo "ERROR: Checksum file not found: $CHECKSUM_FILE"
    exit 1
fi

echo "Verifying checksum for $FILE"
sha256sum -c "$CHECKSUM_FILE"

echo "Checksum verification passed."