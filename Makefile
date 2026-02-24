# ============================================================================
# Evaluation task for “Enabling Sustainable ARM Support for the Belle II Software”
#
# Top-Level Makefile
#
# This Makefile orchestrates the build of a minimal, reproducible software
# stack required for sustainable Belle II software deployment.
#
# The stack consists of:
#   - libffi
#   - SQLite
#   - XZ Utils (liblzma)
#   - Python (built against the above)
#
# Design Principles:
#   * Prefix-based installation (no reliance on system versions)
#   * Explicit dependency ordering
#   * Toolchain propagation (CC, CFLAGS overridable)
#   * Deterministic builds via checksum verification
#   * Isolation verification for stack-managed libraries
#
# The default target builds the complete stack into ./prefix.
#
# This file contains only orchestration logic. Package-specific build
# definitions are modularized under packages/.
# ============================================================================

# Ensure 'make' without arguments builds the full stack.
.DEFAULT_GOAL := all

# Global configuration and package modules
include config.mk
include packages/common.mk
include packages/libffi.mk
include packages/xz.mk
include packages/sqlite.mk
include packages/python.mk

# Public targets (these are logical targets, not files)
.PHONY: all clean distclean verify check-isolation \
        python libffi sqlite xz

# ---------------------------------------------------------------------------
# Build Targets
# ---------------------------------------------------------------------------

# Build entire dependency stack.
# Dependency resolution is handled inside package definitions.
all: python

# ---------------------------------------------------------------------------
# Verification Targets
# ---------------------------------------------------------------------------

# Verifies that Python was built with required optional modules enabled.
# This confirms correct dependency resolution at build time.
verify:
	@$(PREFIX)/bin/python3 -c "import sqlite3, lzma, ctypes; print('Modules OK')"

# Verifies runtime isolation of stack-managed libraries.
# Ensures that libsqlite3, liblzma, and libffi are resolved from the
# local prefix rather than system locations.
check-isolation:
	@$(SCRIPT_DIR)/check_isolation.sh $(PREFIX)

# ---------------------------------------------------------------------------
# Cleanup Targets
# ---------------------------------------------------------------------------

# Removes build artifacts but preserves downloads and installed prefix.
clean:
	rm -rf $(BUILD_DIR)

# Removes build artifacts, downloaded tarballs, and installation prefix.
# Restores project to pristine state.
distclean:
	rm -rf $(BUILD_DIR) $(DOWNLOAD_DIR) $(PREFIX)