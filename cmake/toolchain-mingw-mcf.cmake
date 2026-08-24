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
set(CMAKE_FIND_ROOT_PATH ${MINGW_SYSROOT})

# Search behavior
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)   # host tools (moc, rcc, etc.) — use host
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)   # target libs — only sysroot
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)   # target headers — only sysroot
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Don't try to run target executables during configure (we're cross-compiling)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_CROSSCOMPILING_EMULATOR "")

# MCF thread model — Qt threading should be enabled
set(QT_FEATURE_thread ON CACHE BOOL "Enable threading" FORCE)

# Export all symbols in shared libs (typical Windows behavior)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# pkg-config: target only, not host
set(ENV{PKG_CONFIG_PATH}   "${MINGW_SYSROOT}/lib/pkgconfig")
set(ENV{PKG_CONFIG_LIBDIR} "${MINGW_SYSROOT}/lib/pkgconfig")
