# ============================================================================
# XZ Utils (liblzma) Package Definition
#
# XZ Utils provides liblzma, which is required by Python's _lzma
# extension module for LZMA compression support.
#
# In this dependency stack:
#   - XZ must be built before Python
#   - Python must detect this instance via CPPFLAGS/LDFLAGS
#   - System-installed liblzma must NOT be used
#
# Design Goals:
#   * Prefix-based installation (no reliance on system liblzma)
#   * Shared library build for dynamic Python extension linkage
#   * Toolchain propagation for ARM portability
#   * Deterministic source acquisition via checksum verification
# ============================================================================


# ---------------------------------------------------------------------------
# Version and Source Definition
# ---------------------------------------------------------------------------

XZ_VERSION := 5.4.5
XZ_TAR     := xz-$(XZ_VERSION).tar.gz
XZ_URL     := https://tukaani.org/xz/$(XZ_TAR)
XZ_SRC     := $(BUILD_DIR)/xz-$(XZ_VERSION)

# Instantiate deterministic download rule
$(eval $(call DOWNLOAD_template,$(XZ_TAR),$(XZ_URL),xz.sha256))


# ---------------------------------------------------------------------------
# Extraction Rule
# ---------------------------------------------------------------------------

# Extract into build directory.
# Order-only dependency ensures BUILD_DIR exists without triggering rebuilds.
$(XZ_SRC): $(DOWNLOAD_DIR)/$(XZ_TAR) | $(BUILD_DIR)
	cd $(BUILD_DIR) && tar xf $(DOWNLOAD_DIR)/$(XZ_TAR)


# ---------------------------------------------------------------------------
# Build and Install Rule
# ---------------------------------------------------------------------------

# XZ is installed into the local prefix to ensure:
#   - Python links against this instance of liblzma
#   - No accidental linkage to system liblzma
#
# Toolchain variables are propagated to support:
#   - Cross-compilation (e.g., ARM)
#   - Alternative compilers
#
# Shared libraries are enabled because Python's _lzma extension
# dynamically links against liblzma.
#
xz: $(XZ_SRC) | $(PREFIX)
	cd $(XZ_SRC) && \
	./configure \
		--prefix=$(PREFIX) \
		$(CONFIGURE_SHARED_FLAGS) \
		CC="$(CC)" CFLAGS="$(CFLAGS)" && \
	make -j$(JOBS) && \
	make install