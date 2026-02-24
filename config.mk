# ============================================================================
# Global Configuration
#
# This file defines global build parameters shared across all packages.
#
# Design Goals:
#   * Prefix-based installation (self-contained stack)
#   * Toolchain propagation (cross-compilation ready)
#   * Architecture neutrality (ARM-compatible)
#   * Explicit include/library path control
#
# All package Makefiles consume these variables.
# ============================================================================

# Project root directory
ROOT := $(CURDIR)

# ---------------------------------------------------------------------------
# Installation Layout
# ---------------------------------------------------------------------------

# Installation prefix (overridable by user)
# Example:
#   make PREFIX=/opt/belle2-stack
PREFIX ?= $(ROOT)/prefix

# Build, download, and helper directories
BUILD_DIR     := $(ROOT)/build
DOWNLOAD_DIR  := $(ROOT)/downloads
CHECKSUM_DIR  := $(ROOT)/checksums
SCRIPT_DIR    := $(ROOT)/scripts

# ---------------------------------------------------------------------------
# Parallel Build Control
# ---------------------------------------------------------------------------

# Number of parallel jobs (auto-detected, fallback to 4)
JOBS ?= $(shell nproc 2>/dev/null || echo 4)

# ---------------------------------------------------------------------------
# Toolchain Configuration (Cross-Compilation Ready)
# ---------------------------------------------------------------------------

# Toolchain is intentionally overridable to support:
#   - ARM builds
#   - Cross-compilation (e.g. aarch64-linux-gnu-gcc)
#   - Custom compiler toolchains
#
# Example:
#   make CC=aarch64-linux-gnu-gcc
#
CC      ?= gcc
CFLAGS  ?= -O2 -fPIC
LDFLAGS ?=

# ---------------------------------------------------------------------------
# Prefix Isolation Configuration
# ---------------------------------------------------------------------------

# These exported variables ensure that during package configuration:
#   - Header files are resolved from the local prefix
#   - Libraries are resolved from the local prefix
#   - pkg-config metadata is resolved from the local prefix
#
# This prevents accidental linkage against system-installed libraries.
#
export CPPFLAGS       := -I$(PREFIX)/include
export LDFLAGS        := -L$(PREFIX)/lib $(LDFLAGS)
export PKG_CONFIG_PATH := $(PREFIX)/lib/pkgconfig

# ---------------------------------------------------------------------------
# Shared Library Policy
# ---------------------------------------------------------------------------

# Shared libraries are enabled to reflect realistic scientific software
# deployment patterns. Static-only builds are avoided to ensure downstream
# compatibility and modular linkage.
#
CONFIGURE_SHARED_FLAGS := --enable-shared --disable-static