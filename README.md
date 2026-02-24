# Evaluation task for “Enabling Sustainable ARM Support for the Belle II Software”

## Overview

This project implements a reproducible, prefix-based dependency build system using GNU Make.

It builds a minimal software stack consisting of:

* libffi
* SQLite
* XZ Utils (liblzma)
* Python (built against the above)

The system demonstrates:

* Explicit dependency ordering
* Prefix-based installation
* Isolation from system-installed libraries
* Deterministic source downloads with checksum verification
* Clean environment activation for downstream software

All components are installed into:

```
./prefix
```

## Build

Build the complete stack:

```
make
```

Clean build artifacts (preserves downloads and prefix):

```
make clean
```

Reset entire project (removes build, downloads, and prefix):

```
make distclean
```

## Environment Activation

After building, activate the stack:

```
source scripts/env.sh
```

This configures:

* PATH  
* LD_LIBRARY_PATH  
* PKG_CONFIG_PATH  
* CPPFLAGS  
* LDFLAGS  

so that downstream software resolves headers and libraries from the local prefix rather than the system.

## Verification

Verify Python modules:

```
make verify
```

This confirms that:

* sqlite3
* lzma
* ctypes

were correctly built and detected.

Verify runtime isolation:

``` 
make check-isolation
```

This ensures that:
* libsqlite3
* liblzma
* libffi

are resolved from the local prefix.

## Project Structure

```
.
├── Makefile              # Top-level build orchestration
├── config.mk             # Global configuration and toolchain settings
├── packages/             # Modular package definitions
│   ├── common.mk         # Download + checksum utilities
│   ├── libffi.mk         # libffi build rules
│   ├── sqlite.mk         # SQLite build rules
│   ├── xz.mk             # XZ (liblzma) build rules
│   └── python.mk         # Python build rules
├── scripts/              # Activation and verification scripts
│   ├── env.sh
│   ├── check_isolation.sh
│   └── verify_checksum.sh
├── checksums/            # SHA256 checksum files
├── downloads/            # Downloaded source archives
├── build/                # Build directories
└── prefix/               # Installation prefix
```

## Requirements

The build requires a glibc-based Linux environment with:

* gcc
* make
* curl
* tar
* sha256sum
* pkg-config

It works inside Debian, Ubuntu, Fedora, and similar Docker containers where standard build tools are installed.

## Isolation Scope

The build system enforces isolation for:

* libffi
* SQLite
* XZ (liblzma)

System runtime libraries such as:

* libc
* libm
* dynamic loader

are intentionally allowed.