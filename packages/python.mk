# ============================================================================
# Python Package Definition
#
# Python is the top-level component of this dependency stack.
#
# It depends on:
#   - libffi  (for ctypes module)
#   - SQLite  (for _sqlite3 module)
#   - XZ      (for _lzma module)
#
# Design Goals:
#   * Detect and link against locally built dependencies
#   * Avoid reliance on system-installed libraries
#   * Preserve cross-compilation and ARM portability
#   * Enable dynamic extension modules
#   * Maintain deterministic, reproducible builds
#
# Isolation Strategy:
#   - CPPFLAGS and LDFLAGS are exported globally (via config.mk)
#   - This ensures header and library resolution occurs from PREFIX
#   - System-installed versions are not used
#
# Verification:
#   - "make verify" checks module availability
#   - "make check-isolation" validates dynamic linkage
# ============================================================================


# ---------------------------------------------------------------------------
# Version and Source Definition
# ---------------------------------------------------------------------------

PYTHON_VERSION := 3.11.8
PYTHON_TAR     := Python-$(PYTHON_VERSION).tgz
PYTHON_URL     := https://www.python.org/ftp/python/$(PYTHON_VERSION)/$(PYTHON_TAR)
PYTHON_SRC     := $(BUILD_DIR)/Python-$(PYTHON_VERSION)

# Instantiate deterministic download rule
$(eval $(call DOWNLOAD_template,$(PYTHON_TAR),$(PYTHON_URL),python.sha256))


# ---------------------------------------------------------------------------
# Extraction Rule
# ---------------------------------------------------------------------------

# Extract into build directory.
# Order-only dependency ensures BUILD_DIR exists without triggering rebuilds.
$(PYTHON_SRC): $(DOWNLOAD_DIR)/$(PYTHON_TAR) | $(BUILD_DIR)
	cd $(BUILD_DIR) && tar xf $(DOWNLOAD_DIR)/$(PYTHON_TAR)


# ---------------------------------------------------------------------------
# Build and Install Rule
# ---------------------------------------------------------------------------

# Python must be built AFTER libffi, SQLite, and XZ to ensure
# correct detection of optional extension modules.
#
# The configure step relies on:
#   - CPPFLAGS (for header resolution)
#   - LDFLAGS (for library resolution)
#   - PKG_CONFIG_PATH (for metadata resolution)
#
# These are exported in config.mk and enforce prefix isolation.
#
# --with-system-ffi ensures that Python uses the externally built libffi
# from the prefix instead of bundling or using system copies.
#
# Shared libraries are required for extension modules such as:
#   - _sqlite3
#   - _lzma
#   - _ctypes
#
# Toolchain variables (CC, CFLAGS) are propagated to support:
#   - ARM builds
#   - Cross-compilation
#   - Alternative compilers
#
python: libffi sqlite xz $(PYTHON_SRC) | $(PREFIX)
	cd $(PYTHON_SRC) && \
	./configure \
		--prefix=$(PREFIX) \
		--with-system-ffi \
		--with-ensurepip=install \
		CC="$(CC)" \
		CFLAGS="$(CFLAGS)" && \
	make -j$(JOBS) && \
	make install