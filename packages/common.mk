# ============================================================================
# Common Package Utilities
#
# This file defines reusable helper rules shared by all package definitions.
#
# Design Goals:
#   * Deterministic source acquisition
#   * Strict checksum verification
#   * Idempotent directory creation
#   * Separation of orchestration and package logic
#
# All package-specific Makefiles use the DOWNLOAD_template defined here.
# ============================================================================


# ---------------------------------------------------------------------------
# Directory Creation Rules
# ---------------------------------------------------------------------------

# These rules ensure required directories exist before use.
# They are order-only prerequisites in package rules to avoid unnecessary
# rebuild triggers.

$(DOWNLOAD_DIR):
	mkdir -p $@

$(BUILD_DIR):
	mkdir -p $@

$(PREFIX):
	mkdir -p $@


# ---------------------------------------------------------------------------
# Deterministic Download Template
# ---------------------------------------------------------------------------

# DOWNLOAD_template
#
# Parameters:
#   $1 - Tarball filename
#   $2 - Source URL
#   $3 - Corresponding checksum file
#
# Behavior:
#   - Downloads tarball only if missing
#   - ALWAYS verifies checksum (even if file already exists)
#   - Fails build on checksum mismatch
#
# Rationale:
#   Checksum verification is enforced unconditionally to ensure:
#     * Reproducibility
#     * Supply-chain integrity
#     * Protection against partial or corrupted downloads
#
# This ensures that builds are deterministic and not dependent on
# previously cached, potentially modified files.
#
define DOWNLOAD_template
$(DOWNLOAD_DIR)/$1: | $(DOWNLOAD_DIR)
	@if [ ! -f $$@ ]; then \
		echo "Downloading $1..."; \
		curl -L -o $$@ $2; \
	else \
		echo "$1 already exists. Verifying integrity..."; \
	fi
	@$(SCRIPT_DIR)/verify_checksum.sh $$@ $(CHECKSUM_DIR)/$3
endef