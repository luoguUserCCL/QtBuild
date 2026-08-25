# CMake toolchain file for cross-compiling Qt with
# MinGW-w64 (UCRT/MCF/SEH) GCC 16.1.1 20260701
# Linux host -> Windows x86_64 target
#
# Used by .github/workflows/build-qt.yml

set(CMAKE_SYSTEM_NAME       Windows)
set(CMAKE_SYSTEM_PROCESSOR  x86_64)

# Toolchain is extracted to /opt/mingw-mcf by the workflow
set(MINGW_PREFIX   /opt/mingw-mcf/bin)
set(MINGW_SYSROOT  /opt/mingw-mcf/x86_64-w64-mingw32)

# Compilers and binutils (target-prefixed cross tools)
set(CMAKE_C_COMPILER      ${MINGW_PREFIX}/x86_64-w64-mingw32-gcc    CACHE FILEPATH "C compiler")
set(CMAKE_CXX_COMPILER   ${MINGW_PREFIX}/x86_64-w64-mingw32-g++    CACHE FILEPATH "C++ compiler")
set(CMAKE_RC_COMPILER    ${MINGW_PREFIX}/x86_64-w64-mingw32-windres CACHE FILEPATH "RC compiler")
set(CMAKE_AR             ${MINGW_PREFIX}/x86_64-w64-mingw32-ar      CACHE FILEPATH "archiver")
set(CMAKE_RANLIB         ${MINGW_PREFIX}/x86_64-w64-mingw32-ranlib CACHE FILEPATH "ranlib")
set(CMAKE_STRIP          ${MINGW_PREFIX}/x86_64-w64-mingw32-strip   CACHE FILEPATH "strip")
set(CMAKE_DLLTOOL        ${MINGW_PREFIX}/x86_64-w64-mingw32-dlltool CACHE FILEPATH "dlltool")
set(CMAKE_OBJDUMP        ${MINGW_PREFIX}/x86_64-w64-mingw32-objdump CACHE FILEPATH "objdump")

# Where target libs / headers live
# Phase 2: include both the MinGW sysroot AND the user-provided deps prefix
# (/opt/qt-deps with OpenSSL/ICU/PCRE2/zlib/Brotli/... headers+libs).
# CMAKE_FIND_ROOT_PATH_MODE_LIBRARY/INCLUDE are ONLY, so any prefix that
# should be searchable must be listed here, otherwise find_path/find_library
# never look outside the sysroot and every system-lib detection fails
# (WrapSystemZLIB_FOUND / ICU_FOUND / WrapSystemPCRE2_FOUND = FALSE etc).
set(CMAKE_FIND_ROOT_PATH ${MINGW_SYSROOT} /opt/qt-deps)

# Tell CMake's find modules about the deps prefix too (some use these hints)
set(OPENSSL_ROOT_DIR         /opt/qt-deps CACHE PATH "OpenSSL root")
set(ICU_ROOT                 /opt/qt-deps CACHE PATH "ICU root")
set(PCRE2_INCLUDE_DIR        /opt/qt-deps/include CACHE PATH "PCRE2 includes")
set(ZLIB_ROOT                /opt/qt-deps CACHE PATH "ZLIB root")

# Search behavior
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)   # host tools (moc, rcc, etc.) — use host
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)   # target libs — sysroot + deps only
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)   # target headers — sysroot + deps only
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Don't try to run target executables during configure (we're cross-compiling)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_CROSSCOMPILING_EMULATOR "")

# MCF thread model — Qt threading should be enabled
set(QT_FEATURE_thread ON CACHE BOOL "Enable threading" FORCE)

# Export all symbols in shared libs (typical Windows behavior)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# Override ar command templates to NOT pass LINK_FLAGS to ar.
# Qt 6's qt_internal_add_link_flags_no_undefined adds -Wl,--no-undefined to
# target LINK_OPTIONS (for shared libs). CMake's default CMAKE_*_ARCHIVE_CREATE
# templates include <LINK_FLAGS>, so static-lib try-compile passes -Wl,--no-undefined
# to ar, which fails with "invalid option -- 'W'". Drop LINK_FLAGS from
# archive-create commands using CACHE + FORCE to override CMake's defaults.
set(CMAKE_C_ARCHIVE_CREATE       "<CMAKE_AR> qc <TARGET> <OBJECTS>" CACHE STRING "C archive create" FORCE)
set(CMAKE_CXX_ARCHIVE_CREATE     "<CMAKE_AR> qc <TARGET> <OBJECTS>" CACHE STRING "C++ archive create" FORCE)
set(CMAKE_C_ARCHIVE_FINISH       "<CMAKE_RANLIB> <TARGET>" CACHE STRING "C archive finish" FORCE)
set(CMAKE_CXX_ARCHIVE_FINISH     "<CMAKE_RANLIB> <TARGET>" CACHE STRING "C++ archive finish" FORCE)
set(CMAKE_C_ARCHIVE_APPEND       "<CMAKE_AR> q <TARGET> <OBJECTS>" CACHE STRING "C archive append" FORCE)
set(CMAKE_CXX_ARCHIVE_APPEND     "<CMAKE_AR> q <TARGET> <OBJECTS>" CACHE STRING "C++ archive append" FORCE)

# pkg-config: target only, not host; include deps prefix
set(ENV{PKG_CONFIG_PATH}   "/opt/qt-deps/lib/pkgconfig:${MINGW_SYSROOT}/lib/pkgconfig")
set(ENV{PKG_CONFIG_LIBDIR} "/opt/qt-deps/lib/pkgconfig:${MINGW_SYSROOT}/lib/pkgconfig")
