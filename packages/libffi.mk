# ============================================================================
# libffi Package Definition
#
# libffi provides a portable Foreign Function Interface, which is required
# by Python for the ctypes module.
#
# In this dependency stack:
#   - libffi must be built before Python
#   - Python is configured with --with-system-ffi to use this instance
#
# Design Goals:
#   * Install into local prefix (no system dependency)
#   * Enable shared libraries for realistic runtime usage
#   * Propagate toolchain variables for ARM compatibility
#   * Maintain deterministic source acquisition via checksum validation
# ============================================================================

# ---------------------------------------------------------------------------
# Version and Source Definition
# ---------------------------------------------------------------------------

LIBFFI_VERSION := 3.4.5
LIBFFI_TAR     := libffi-$(LIBFFI_VERSION).tar.gz
LIBFFI_URL     := https://github.com/libffi/libffi/releases/download/v$(LIBFFI_VERSION)/$(LIBFFI_TAR)
LIBFFI_SRC     := $(BUILD_DIR)/libffi-$(LIBFFI_VERSION)

# Instantiate deterministic download rule
$(eval $(call DOWNLOAD_template,$(LIBFFI_TAR),$(LIBFFI_URL),libffi.sha256))


# ---------------------------------------------------------------------------
# Extraction Rule
# ---------------------------------------------------------------------------

# Extract source into build directory.
# Order-only dependency ensures BUILD_DIR exists without triggering rebuilds.
$(LIBFFI_SRC): $(DOWNLOAD_DIR)/$(LIBFFI_TAR) | $(BUILD_DIR)
	cd $(BUILD_DIR) && tar xf $(DOWNLOAD_DIR)/$(LIBFFI_TAR)


# ---------------------------------------------------------------------------
# Build and Install Rule
# ---------------------------------------------------------------------------

# libffi is installed into the local prefix to prevent reliance on
# system-installed versions.
#
# Toolchain variables (CC, CFLAGS) are propagated to support:
#   - Cross-compilation (e.g., ARM)
#   - Alternative compilers
#
# Shared libraries are enabled to reflect realistic scientific software
# deployment patterns and to allow dynamic linkage from Python.
#
libffi: $(LIBFFI_SRC) | $(PREFIX)
	cd $(LIBFFI_SRC) && \
	./configure \
		--prefix=$(PREFIX) \
		$(CONFIGURE_SHARED_FLAGS) \
		CC="$(CC)" CFLAGS="$(CFLAGS)" && \
	make -j$(JOBS) && \
	make install