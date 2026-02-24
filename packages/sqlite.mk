# ============================================================================
# SQLite Package Definition
#
# SQLite provides the embedded database engine required by Python's
# _sqlite3 extension module.
#
# In this dependency stack:
#   - SQLite must be built before Python
#   - Python must detect this instance via CPPFLAGS/LDFLAGS
#   - System-installed SQLite must NOT be used
#
# Design Goals:
#   * Prefix-based installation (no system SQLite usage)
#   * Shared library build to support dynamic Python extension modules
#   * Toolchain propagation for ARM portability
#   * Deterministic source acquisition via checksum verification
# ============================================================================


# ---------------------------------------------------------------------------
# Version and Source Definition
# ---------------------------------------------------------------------------

# SQLite distributes versioned tarballs using an internal numeric scheme.
# The year component is part of the download path.
#
SQLITE_YEAR    := 2024
SQLITE_VERSION := 3450300
SQLITE_TAR     := sqlite-autoconf-$(SQLITE_VERSION).tar.gz
SQLITE_URL     := https://sqlite.org/$(SQLITE_YEAR)/$(SQLITE_TAR)
SQLITE_SRC     := $(BUILD_DIR)/sqlite-autoconf-$(SQLITE_VERSION)

# Instantiate deterministic download rule
$(eval $(call DOWNLOAD_template,$(SQLITE_TAR),$(SQLITE_URL),sqlite.sha256))


# ---------------------------------------------------------------------------
# Extraction Rule
# ---------------------------------------------------------------------------

# Extract into build directory.
# Order-only dependency ensures BUILD_DIR exists without triggering rebuilds.
$(SQLITE_SRC): $(DOWNLOAD_DIR)/$(SQLITE_TAR) | $(BUILD_DIR)
	cd $(BUILD_DIR) && tar xf $(DOWNLOAD_DIR)/$(SQLITE_TAR)


# ---------------------------------------------------------------------------
# Build and Install Rule
# ---------------------------------------------------------------------------

# SQLite is installed into the local prefix to ensure:
#   - Python links against this instance
#   - No reliance on system-installed libsqlite3
#
# Toolchain variables are propagated to support:
#   - Cross-compilation (e.g., ARM)
#   - Alternative compilers
#
# Shared libraries are enabled because Python's _sqlite3 extension
# dynamically links against libsqlite3.
#
sqlite: $(SQLITE_SRC) | $(PREFIX)
	cd $(SQLITE_SRC) && \
	./configure \
		--prefix=$(PREFIX) \
		$(CONFIGURE_SHARED_FLAGS) \
		CC="$(CC)" CFLAGS="$(CFLAGS)" && \
	make -j$(JOBS) && \
	make install