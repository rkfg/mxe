#!/bin/sh
set -ex


#---
#   Build a MinGW cross compiling environment
#
#   Version:    -
#   Homepage:   http://www.profv.de/mingw_cross_env/
#   File name:  build_mingw_cross_env.sh
#
#   This script compiles a MinGW cross compiler and cross compiles
#   many free libraries such as GD and SDL. Thus, it provides you
#   a nice MinGW cross compiling environment. All necessary source
#   packages are downloaded automatically.
#
#   2007-06-12  Project start
#   2007-06-19  Release 1.0
#---


#---
#   Copyright (c)  Volker Grabsch <vog@notjusthosting.com>
#
#   Permission is hereby granted, free of charge, to any person obtaining
#   a copy of this software and associated documentation files (the
#   "Software"), to deal in the Software without restriction, including
#   without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
#   permit persons to whom the Software is furnished to do so, subject
#   to the following conditions:
#
#   The above copyright notice and this permission notice shall be
#   included in all copies or substantial portions of the Software.
# 
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#---


#---
#   Configuration
#---

TARGET="i386-mingw32msvc"
ROOT=`pwd`
PREFIX="$ROOT/usr"
SOURCE="$ROOT/src"
DOWNLOAD="$ROOT/download"

PATH="$PREFIX/bin:$PATH"

VERSION_mingw_runtime=3.9
VERSION_w32api=3.9
VERSION_binutils=2.17.50-20060824-1
VERSION_gcc=3.4.5-20060117-1
VERSION_pkg_config=0.21
VERSION_pthreads=2-8-0
VERSION_zlib=1.2.3
VERSION_gettext=0.16.1
VERSION_libxml2=2.6.29
VERSION_libgpg_error=1.5
VERSION_libgcrypt=1.2.4
VERSION_gnutls=1.6.3
VERSION_curl=7.16.2
VERSION_libpng=1.2.18
VERSION_jpeg=6b
VERSION_tiff=3.8.2
VERSION_giflib=4.1.4
VERSION_freetype=2.3.4
VERSION_fontconfig=2.4.2
VERSION_gd=2.0.35RC5
VERSION_SDL=1.2.11
VERSION_smpeg=0.4.5+cvs20030824
VERSION_SDL_mixer=1.2.7
VERSION_geos=3.0.0rc4
VERSION_proj=4.5.0
VERSION_libgeotiff=1.2.3
VERSION_gdal=1.4.1


#---
#   Portability
#---

if ! command -v gmake; then alias gmake=make; fi
if ! command -v gsed;  then alias gsed=sed;   fi


#---
#   Main
#---

case "$1" in
"")
    echo "Stage 1: $BASH '$0' --download"
    $BASH "$0" --download
    echo "Stage 2: $BASH '$0' --build"
    $BASH "$0" --build
    exit 0
    ;;
--new-versions)
    # go ahead
    ;;
--download)
    # go ahead
    ;;
--build)
    # go ahead
    ;;
*)
    echo "Usage: $0 [ --new-versions | --download | --build ]"
    exit 1
    ;;
esac


#---
#   Prepare
#---

case "$1" in

--download)
    mkdir -p "$DOWNLOAD"
    ;;

--build)
    rm -rfv "$PREFIX"
    rm -rfv "$SOURCE"
    mkdir -p "$PREFIX"
    mkdir -p "$SOURCE"
    ;;

esac


#---
#   MinGW Runtime
#
#   http://mingw.sourceforge.net/
#---

case "$1" in

--new-versions)
    echo "VERSION_mingw_runtime=`
        wget -q -O- 'http://sourceforge.net/project/showfiles.php?group_id=2435' |
        gsed -n 's,.*mingw-runtime-\([0-9][^>]*\)-src\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "mingw-runtime-$VERSION_mingw_runtime.tar.gz" &>/dev/null ||
    wget -c "http://downloads.sourceforge.net/mingw/mingw-runtime-$VERSION_mingw_runtime.tar.gz"
    ;;

--build)
    install -d "$PREFIX/$TARGET"
    cd "$PREFIX/$TARGET"
    tar xfvz "$DOWNLOAD/mingw-runtime-$VERSION_mingw_runtime.tar.gz"
    ;;

esac


#---
#   MinGW Windows API
#
#   http://mingw.sourceforge.net/
#---

case "$1" in

--new-versions)
    echo "VERSION_w32api=`
        wget -q -O- 'http://sourceforge.net/project/showfiles.php?group_id=2435' |
        gsed -n 's,.*w32api-\([0-9][^>]*\)-src\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "w32api-$VERSION_w32api.tar.gz" &>/dev/null ||
    wget -c "http://downloads.sourceforge.net/mingw/w32api-$VERSION_w32api.tar.gz"
    ;;

--build)
    install -d "$PREFIX/$TARGET"
    cd "$PREFIX/$TARGET"
    tar xfvz "$DOWNLOAD/w32api-$VERSION_w32api.tar.gz"
    # fix incompatibilities with gettext
    gsed 's,\(SUBLANG_BENGALI_INDIA\t\)0x01,\10x00,'    -i "$PREFIX/$TARGET/include/winnt.h"
    gsed 's,\(SUBLANG_PUNJABI_INDIA\t\)0x01,\10x00,'    -i "$PREFIX/$TARGET/include/winnt.h"
    gsed 's,\(SUBLANG_ROMANIAN_ROMANIA\t\)0x01,\10x00,' -i "$PREFIX/$TARGET/include/winnt.h"
    # fix incompatibilities with jpeg
    gsed 's,typedef unsigned char boolean;,,'           -i "$PREFIX/$TARGET/include/rpcndr.h"
    ;;

esac


#---
#   MinGW binutils
#
#   http://mingw.sourceforge.net/
#---

case "$1" in

--new-versions)
    echo "VERSION_binutils=`
        wget -q -O- 'http://sourceforge.net/project/showfiles.php?group_id=2435' |
        gsed -n 's,.*binutils-\([0-9][^>]*\)-src\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "binutils-$VERSION_binutils-src.tar.gz" &>/dev/null ||
    wget -c "http://downloads.sourceforge.net/mingw/binutils-$VERSION_binutils-src.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/binutils-$VERSION_binutils-src.tar.gz"
    cd "binutils-$VERSION_binutils-src"
    ./configure \
        --target="$TARGET" \
        --prefix="$PREFIX" \
        --with-gcc \
        --with-gnu-ld \
        --with-gnu-as \
        --disable-nls \
        --disable-shared
    gmake
    gmake install
    cd "$SOURCE"
    rm -rfv "binutils-$VERSION_binutils-src"
    strip -sv \
        "$PREFIX/bin/$TARGET-addr2line" \
        "$PREFIX/bin/$TARGET-ar" \
        "$PREFIX/bin/$TARGET-as" \
        "$PREFIX/bin/$TARGET-c++filt" \
        "$PREFIX/bin/$TARGET-dlltool" \
        "$PREFIX/bin/$TARGET-dllwrap" \
        "$PREFIX/bin/$TARGET-gprof" \
        "$PREFIX/bin/$TARGET-ld" \
        "$PREFIX/bin/$TARGET-nm" \
        "$PREFIX/bin/$TARGET-objcopy" \
        "$PREFIX/bin/$TARGET-objdump" \
        "$PREFIX/bin/$TARGET-ranlib" \
        "$PREFIX/bin/$TARGET-readelf" \
        "$PREFIX/bin/$TARGET-size" \
        "$PREFIX/bin/$TARGET-strings" \
        "$PREFIX/bin/$TARGET-strip" \
        "$PREFIX/bin/$TARGET-windres" \
        "$PREFIX/$TARGET/bin/ar" \
        "$PREFIX/$TARGET/bin/as" \
        "$PREFIX/$TARGET/bin/dlltool" \
        "$PREFIX/$TARGET/bin/ld" \
        "$PREFIX/$TARGET/bin/nm" \
        "$PREFIX/$TARGET/bin/objdump" \
        "$PREFIX/$TARGET/bin/ranlib" \
        "$PREFIX/$TARGET/bin/strip" \
        "$PREFIX/lib/libiberty.a"
    ;;

esac


#---
#   MinGW GCC
#
#   http://mingw.sourceforge.net/
#---

case "$1" in

--new-versions)
    echo "VERSION_gcc=`
        wget -q -O- 'http://sourceforge.net/project/showfiles.php?group_id=2435' |
        gsed -n 's,.*gcc-core-\([0-9][^>]*\)-src\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "gcc-core-$VERSION_gcc-src.tar.gz" &>/dev/null ||
    wget -c "http://downloads.sourceforge.net/mingw/gcc-core-$VERSION_gcc-src.tar.gz"
    tar tfz "gcc-g++-$VERSION_gcc-src.tar.gz" &>/dev/null ||
    wget -c "http://downloads.sourceforge.net/mingw/gcc-g++-$VERSION_gcc-src.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/gcc-core-$VERSION_gcc-src.tar.gz"
    tar xfvz "$DOWNLOAD/gcc-g++-$VERSION_gcc-src.tar.gz"
    cd "gcc-$VERSION_gcc"
    ./configure \
        --target="$TARGET" \
        --prefix="$PREFIX" \
        --enable-languages="c,c++" \
        --enable-version-specific-runtime-libs \
        --with-gcc \
        --with-gnu-ld \
        --with-gnu-as \
        --disable-nls \
        --disable-shared \
        --without-x \
        --enable-threads=win32 \
        --disable-win32-registry \
        --enable-sjlj-exceptions
    gmake
    gmake install
    cd "$SOURCE"
    rm -rfv "gcc-$VERSION_gcc"
    VERSION_gcc_short=`echo "$VERSION_gcc" | cut -d'-' -f1`
    strip -sv \
        "$PREFIX/bin/$TARGET-c++" \
        "$PREFIX/bin/$TARGET-cpp" \
        "$PREFIX/bin/$TARGET-g++" \
        "$PREFIX/bin/$TARGET-gcc" \
        "$PREFIX/bin/$TARGET-gcc-3.4.5" \
        "$PREFIX/bin/$TARGET-gcov" \
        "$PREFIX/$TARGET/bin/c++" \
        "$PREFIX/$TARGET/bin/g++" \
        "$PREFIX/$TARGET/bin/gcc" \
        "$PREFIX/libexec/gcc/$TARGET/$VERSION_gcc_short/cc1" \
        "$PREFIX/libexec/gcc/$TARGET/$VERSION_gcc_short/cc1plus" \
        "$PREFIX/libexec/gcc/$TARGET/$VERSION_gcc_short/collect2"
    ;;

esac


#---
#   pkg-config
#
#   http://pkg-config.freedesktop.org/
#---

case "$1" in

--new-versions)
    echo "VERSION_pkg_config=`
        wget -q -O- 'http://pkgconfig.freedesktop.org/' |
        gsed -n 's,.*current release of pkg-config is version \([0-9][^ ]*\) and.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "pkg-config-$VERSION_pkg_config.tar.gz" &>/dev/null ||
    wget -c "http://pkgconfig.freedesktop.org/releases/pkg-config-$VERSION_pkg_config.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/pkg-config-$VERSION_pkg_config.tar.gz"
    cd "pkg-config-$VERSION_pkg_config"
    ./configure --prefix="$PREFIX/$TARGET"
    gmake install
    cd "$SOURCE"
    rm -rfv "pkg-config-$VERSION_pkg_config"
    install -d "$PREFIX/bin"
    rm -fv "$PREFIX/bin/$TARGET-pkg-config"
    ln -s "../$TARGET/bin/pkg-config" "$PREFIX/bin/$TARGET-pkg-config"
    ;;

esac


#---
#   pthreads-w32
#
#   http://sourceware.org/pthreads-win32/
#---

case "$1" in

--new-versions)
    echo "VERSION_pthreads=`
        wget -q -O- 'ftp://sourceware.org/pub/pthreads-win32/Release_notes' |
        gsed -n 's,^RELEASE \([0-9][^[:space:]]*\).*,\1,p' | 
        tr '.' '-' |
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "pthreads-w32-$VERSION_pthreads-release.tar.gz" &>/dev/null ||
    wget -c "ftp://sourceware.org/pub/pthreads-win32/pthreads-w32-$VERSION_pthreads-release.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/pthreads-w32-$VERSION_pthreads-release.tar.gz"
    cd "pthreads-w32-$VERSION_pthreads-release"
    gsed '35i\#define PTW32_STATIC_LIB' -i pthread.h
    gmake CROSS="$TARGET-" GC-static
    install -d "$PREFIX/$TARGET/lib"
    install -m664 libpthreadGC2.a "$PREFIX/$TARGET/lib/libpthread.a"
    install -d "$PREFIX/$TARGET/include"
    install -m664 pthread.h sched.h semaphore.h "$PREFIX/$TARGET/include/"
    cd "$SOURCE"
    rm -rfv "pthreads-w32-$VERSION_pthreads-release"
    ;;

esac


#---
#   zlib
#
#   http://www.zlib.net/
#---

case "$1" in

--new-versions)
    echo "VERSION_zlib=`
        wget -q -O- 'http://sourceforge.net/project/showfiles.php?group_id=5624' |
        gsed -n 's,.*zlib-\([0-9][^>]*\)\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfj "zlib-$VERSION_zlib.tar.bz2" &>/dev/null ||
    wget -c "http://downloads.sourceforge.net/libpng/zlib-$VERSION_zlib.tar.bz2"
    ;;

--build)
    cd "$SOURCE"
    tar xfvj "$DOWNLOAD/zlib-$VERSION_zlib.tar.bz2"
    cd "zlib-$VERSION_zlib"
    CC="$TARGET-gcc" RANLIB="$TARGET-ranlib" ./configure \
        --prefix="$PREFIX/$TARGET"
    gmake install
    cd "$SOURCE"
    rm -rfv "zlib-$VERSION_zlib"
    ;;

esac


#---
#   gettext
#
#   http://www.gnu.org/software/gettext/
#---

case "$1" in

--new-versions)
    echo "VERSION_gettext=`
        wget -q -O- 'ftp://ftp.gnu.org/pub/gnu/gettext/' |
        gsed -n 's,.*gettext-\([0-9][^>]*\)\.tar.*,\1,p' |
        sort | tail -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "gettext-$VERSION_gettext.tar.gz" &>/dev/null ||
    wget -c "ftp://ftp.gnu.org/pub/gnu/gettext/gettext-$VERSION_gettext.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/gettext-$VERSION_gettext.tar.gz"
    cd "gettext-$VERSION_gettext"
    cd gettext-runtime
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        --enable-threads=win32
    gmake -C intl install
    cd "$SOURCE"
    rm -rfv "gettext-$VERSION_gettext"
    ;;

esac


#---
#   libxml2
#
#   http://www.xmlsoft.org/
#---

case "$1" in

--new-versions)
    echo "VERSION_libxml2=`
        wget -q -O- 'ftp://xmlsoft.org/libxml2/' |
        gsed -n 's,.*LATEST_LIBXML2_IS_\([0-9][^>]*\)</a>.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "libxml2-$VERSION_libxml2.tar.gz" &>/dev/null ||
    wget -c "ftp://xmlsoft.org/libxml2/libxml2-$VERSION_libxml2.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/libxml2-$VERSION_libxml2.tar.gz"
    cd "libxml2-$VERSION_libxml2"
    gsed 's,`uname`,MinGW,g' -i xml2-config.in
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --without-debug \
        --prefix="$PREFIX/$TARGET" \
        --without-python
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "libxml2-$VERSION_libxml2"
    ;;

esac


#---
#   libgpg-error
#
#   ftp://ftp.gnupg.org/gcrypt/libgpg-error/
#---

case "$1" in

--new-versions)
    echo "VERSION_libgpg_error=`
        wget -q -O- 'ftp://ftp.gnupg.org/gcrypt/libgpg-error/' |
        gsed -n 's,.*libgpg-error-\([0-9][^>]*\)\.tar.*,\1,p' | 
        tail -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfj "libgpg-error-$VERSION_libgpg_error.tar.bz2" &>/dev/null ||
    wget -c "ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-$VERSION_libgpg_error.tar.bz2"
    ;;

--build)
    cd "$SOURCE"
    tar xfvj "$DOWNLOAD/libgpg-error-$VERSION_libgpg_error.tar.bz2"
    cd "libgpg-error-$VERSION_libgpg_error"
    # wine confuses the cross-compiling detection, so set it explicitly
    sed 's,cross_compiling=no,cross_compiling=yes,' -i configure
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET"
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "libgpg-error-$VERSION_libgpg_error"
    ;;

esac


#---
#   libgcrypt
#
#   ftp://ftp.gnupg.org/gcrypt/libgcrypt/
#---

case "$1" in

--new-versions)
    echo "VERSION_libgcrypt=`
        wget -q -O- 'ftp://ftp.gnupg.org/gcrypt/libgcrypt/' |
        gsed -n 's,.*libgcrypt-\([0-9][^>]*\)\.tar.*,\1,p' | 
        tail -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfj "libgcrypt-$VERSION_libgcrypt.tar.bz2" &>/dev/null ||
    wget -c "ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-$VERSION_libgcrypt.tar.bz2"
    ;;

--build)
    cd "$SOURCE"
    tar xfvj "$DOWNLOAD/libgcrypt-$VERSION_libgcrypt.tar.bz2"
    cd "libgcrypt-$VERSION_libgcrypt"
    gsed '26i\#include <ws2tcpip.h>' -i src/gcrypt.h.in
    gsed '26i\#include <ws2tcpip.h>' -i src/ath.h
    gsed 's,sys/times.h,sys/time.h,' -i cipher/random.c
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        --with-gpg-error-prefix="$PREFIX/$TARGET"
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "libgcrypt-$VERSION_libgcrypt"
    ;;

esac


#---
#   GnuTLS
#
#   http://www.gnu.org/software/gnutls/
#---

case "$1" in

--new-versions)
    echo "VERSION_gnutls=`
        wget -q -O- 'http://www.gnu.org/software/gnutls/news.html' |
        gsed -n 's,.*GnuTLS \([0-9][^>]*\)</a>.*stable branch.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfj "gnutls-$VERSION_gnutls.tar.bz2" &>/dev/null ||
    wget -c "ftp://ftp.gnutls.org/pub/gnutls/gnutls-$VERSION_gnutls.tar.bz2"
    ;;

--build)
    cd "$SOURCE"
    tar xfvj "$DOWNLOAD/gnutls-$VERSION_gnutls.tar.bz2"
    cd "gnutls-$VERSION_gnutls"
    echo "/* DEACTIVATED */" >gl/gai_strerror.c
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        --with-libgcrypt-prefix="$PREFIX/$TARGET" \
        --disable-nls \
        --with-included-opencdk \
        --with-included-libtasn1 \
        --with-included-libcfg \
        --with-included-lzo
    gmake install bin_PROGRAMS= noinst_PROGRAMS= defexec_DATA=
    cd "$SOURCE"
    rm -rfv "gnutls-$VERSION_gnutls"
    ;;

esac


#---
#   cURL
#
#   http://curl.haxx.se/libcurl/
#---

case "$1" in

--new-versions)
    echo "VERSION_curl=`
        wget -q -O- 'http://curl.haxx.se/changes.html' |
        gsed -n 's,.*Fixed in \([0-9][^ ]*\) - .*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfj "curl-$VERSION_curl.tar.bz2" &>/dev/null ||
    wget -c "http://curl.haxx.se/download/curl-$VERSION_curl.tar.bz2"
    ;;

--build)
    cd "$SOURCE"
    tar xfvj "$DOWNLOAD/curl-$VERSION_curl.tar.bz2"
    cd "curl-$VERSION_curl"
    gsed 's,-I@includedir@,-I@includedir@ -DCURL_STATICLIB,' -i curl-config.in
    gsed 's,GNUTLS_ENABLED = 1,GNUTLS_ENABLED=1,' -i configure
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        --with-gnutls="$PREFIX/$TARGET" \
        LIBS="-lgcrypt `$PREFIX/$TARGET/bin/gpg-error-config --libs`"
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "curl-$VERSION_curl"
    ;;

esac


#---
#   libpng
#
#   http://www.libpng.org/
#---

case "$1" in

--new-versions)
    echo "VERSION_libpng=`
        wget -q -O- 'http://sourceforge.net/project/showfiles.php?group_id=5624' |
        gsed -n 's,.*libpng-\([0-9][^>]*\)-no-config\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfj "libpng-$VERSION_libpng.tar.bz2" &>/dev/null ||
    wget -c "http://downloads.sourceforge.net/libpng/libpng-$VERSION_libpng.tar.bz2"
    ;;

--build)
    cd "$SOURCE"
    tar xfvj "$DOWNLOAD/libpng-$VERSION_libpng.tar.bz2"
    cd "libpng-$VERSION_libpng"
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET"
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "libpng-$VERSION_libpng"
    ;;

esac


#---
#   jpeg
#
#   http://www.ijg.org/
#---

case "$1" in

--new-versions)
    echo "VERSION_jpeg=`
        wget -q -O- 'http://www.ijg.org/files/' |
        gsed -n 's,.*jpegsrc.v\([0-9][^>]*\)\.tar.*,\1,p' | 
        tail -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "jpegsrc.v$VERSION_jpeg.tar.gz" &>/dev/null ||
    wget -c "http://www.ijg.org/files/jpegsrc.v$VERSION_jpeg.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/jpegsrc.v$VERSION_jpeg.tar.gz"
    cd "jpeg-$VERSION_jpeg"
    ./configure \
        CC="$TARGET-gcc" RANLIB="$TARGET-ranlib" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET"
    gmake install-lib
    cd "$SOURCE"
    rm -rfv "jpeg-$VERSION_jpeg"
    ;;

esac


#---
#   LibTIFF
#
#   http://www.remotesensing.org/libtiff/
#---

case "$1" in

--new-versions)
    echo "VERSION_tiff=`
        wget -q -O- 'http://www.remotesensing.org/libtiff/' |
        gsed -n 's,.*>v\([0-9][^<]*\)<.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "tiff-$VERSION_tiff.tar.gz" &>/dev/null ||
    wget -c "ftp://ftp.remotesensing.org/pub/libtiff/tiff-$VERSION_tiff.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/tiff-$VERSION_tiff.tar.gz"
    cd "tiff-$VERSION_tiff"
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        PTHREAD_LIBS="-lpthread -lws2_32" \
        --without-x
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "tiff-$VERSION_tiff"
    ;;

esac


#---
#   giflib
#
#   http://sourceforge.net/projects/libungif
#---

case "$1" in

--new-versions)
    echo "VERSION_giflib=`
        wget -q -O- 'http://sourceforge.net/project/showfiles.php?group_id=102202' |
        gsed -n 's,.*giflib-\([0-9][^>]*\)\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfj "giflib-$VERSION_giflib.tar.bz2" &>/dev/null ||
    wget -c "http://downloads.sourceforge.net/libungif/giflib-$VERSION_giflib.tar.bz2"
    ;;

--build)
    cd "$SOURCE"
    tar xfvj "$DOWNLOAD/giflib-$VERSION_giflib.tar.bz2"
    cd "giflib-$VERSION_giflib"
    gsed 's,u_int32_t,unsigned int,' -i configure
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        --without-x
    gmake -C lib install
    cd "$SOURCE"
    rm -rfv "giflib-$VERSION_giflib"
    ;;

esac


#---
#   freetype
#
#   http://freetype.sourceforge.net/
#---

case "$1" in

--new-versions)
    echo "VERSION_freetype=`
        wget -q -O- 'http://sourceforge.net/project/showfiles.php?group_id=3157' |
        gsed -n 's,.*freetype-\([2-9][^>]*\)\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfj "freetype-$VERSION_freetype.tar.bz2" &>/dev/null ||
    wget -c "http://downloads.sourceforge.net/freetype/freetype-$VERSION_freetype.tar.bz2"
    ;;

--build)
    cd "$SOURCE"
    tar xfvj "$DOWNLOAD/freetype-$VERSION_freetype.tar.bz2"
    cd "freetype-$VERSION_freetype"
    GNUMAKE=gmake \
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET"
    gmake install
    cd "$SOURCE"
    rm -rfv "freetype-$VERSION_freetype"
    ;;

esac


#---
#   fontconfig
#
#   http://fontconfig.org/
#---

case "$1" in

--new-versions)
    echo "VERSION_fontconfig=`
        wget -q -O- 'http://fontconfig.org/release/' |
        gsed -n 's,.*fontconfig-\([0-9][^>]*\)\.tar.*,\1,p' | 
        tail -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "fontconfig-$VERSION_fontconfig.tar.gz" &>/dev/null ||
    wget -c "http://fontconfig.org/release/fontconfig-$VERSION_fontconfig.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/fontconfig-$VERSION_fontconfig.tar.gz"
    cd "fontconfig-$VERSION_fontconfig"
    gsed 's,^install-data-local:.*,install-data-local:,' -i src/Makefile.in
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        --with-arch="" \
        --with-freetype-config="$PREFIX/$TARGET/bin/freetype-config" \
        --enable-libxml2 \
        LIBXML2_CFLAGS="`$PREFIX/$TARGET/bin/xml2-config --cflags`" \
        LIBXML2_LIBS="`$PREFIX/$TARGET/bin/xml2-config --libs`"
    gmake -C src install
    gmake -C fontconfig install
    cd "$SOURCE"
    rm -rfv "fontconfig-$VERSION_fontconfig"
    ;;

esac


#---
#   GD
#   (without support for xpm)
#
#   http://www.libgd.org/
#---

case "$1" in

--new-versions)
    echo "VERSION_gd=`
        wget -q -O- 'http://www.libgd.org/Main_Page' |
        gsed -n 's,.*gd-\([0-9][^>]*\)\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfj "gd-$VERSION_gd.tar.bz2" &>/dev/null ||
    wget -c "http://www.libgd.org/releases/gd-$VERSION_gd.tar.bz2"
    ;;

--build)
    cd "$SOURCE"
    tar xfvj "$DOWNLOAD/gd-$VERSION_gd.tar.bz2"
    cd "gd-$VERSION_gd"
    touch aclocal.m4
    touch config.hin
    touch Makefile.in
    gsed 's,-I@includedir@,-I@includedir@ -DNONDLL,' -i config/gdlib-config.in
    gsed 's,-lX11 ,,g' -i configure
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        --with-freetype="$PREFIX/$TARGET" \
        --without-x \
        LIBPNG12_CONFIG="$PREFIX/$TARGET/bin/libpng12-config" \
        LIBPNG_CONFIG="$PREFIX/$TARGET/bin/libpng-config" \
        CFLAGS="-DNONDLL -DXMD_H -L$PREFIX/$TARGET/lib" \
        LIBS="`$PREFIX/$TARGET/bin/xml2-config --libs`"
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "gd-$VERSION_gd"
    ;;

esac


#---
#   SDL
#
#   http://www.libsdl.org/
#---

case "$1" in

--new-versions)
    echo "VERSION_SDL=`
        wget -q -O- 'http://www.libsdl.org/release/changes.html' |
        gsed -n 's,.*SDL \([0-9][^>]*\) Release Notes.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "SDL-$VERSION_SDL.tar.gz" &>/dev/null ||
    wget -c "http://www.libsdl.org/release/SDL-$VERSION_SDL.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/SDL-$VERSION_SDL.tar.gz"
    cd "SDL-$VERSION_SDL"
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --disable-debug \
        --prefix="$PREFIX/$TARGET"
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "SDL-$VERSION_SDL"
    ;;

esac


#---
#   smpeg
#
#   http://icculus.org/smpeg/
#   http://packages.debian.org/unstable/source/smpeg
#---

case "$1" in

--new-versions)
    echo "VERSION_smpeg=`
        wget -q -O- 'http://packages.debian.org/unstable/source/smpeg' |
        gsed -n 's,.*smpeg_\([0-9][^>]*\)\.orig\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "smpeg_$VERSION_smpeg.orig.tar.gz" &>/dev/null ||
    wget -c "http://ftp.debian.org/debian/pool/main/s/smpeg/smpeg_$VERSION_smpeg.orig.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/smpeg_$VERSION_smpeg.orig.tar.gz"
    cd "smpeg-$VERSION_smpeg.orig"
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --disable-debug \
        --prefix="$PREFIX/$TARGET" \
        --with-sdl-prefix="$PREFIX/$TARGET" \
        --disable-sdltest \
        --disable-gtk-player \
        --disable-opengl-player
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "smpeg-$VERSION_smpeg.orig"
    ;;

esac


#---
#   SDL_mixer
#
#   http://www.libsdl.org/projects/SDL_mixer/
#---

case "$1" in

--new-versions)
    echo "VERSION_SDL_mixer=`
        wget -q -O- 'http://www.libsdl.org/projects/SDL_mixer/' |
        gsed -n 's,.*SDL_mixer-\([0-9][^>]*\)\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "SDL_mixer-$VERSION_SDL_mixer.tar.gz" &>/dev/null ||
    wget -c "http://www.libsdl.org/projects/SDL_mixer/release/SDL_mixer-$VERSION_SDL_mixer.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/SDL_mixer-$VERSION_SDL_mixer.tar.gz"
    cd "SDL_mixer-$VERSION_SDL_mixer"
    gsed 's,for path in /usr/local; do,for path in; do,' -i configure
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        --with-sdl-prefix="$PREFIX/$TARGET" \
        --disable-sdltest \
        --with-smpeg-prefix="$PREFIX/$TARGET" \
        --disable-smpegtest
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "SDL_mixer-$VERSION_SDL_mixer"
    ;;

esac


#---
#   GEOS
#
#   http://geos.refractions.net/
#---

case "$1" in

--new-versions)
    echo "VERSION_geos=`
        wget -q -O- 'http://geos.refractions.net/' |
        gsed -n 's,.*geos-\([0-9][^>]*\)\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfj "geos-$VERSION_geos.tar.bz2" &>/dev/null ||
    wget -c "http://geos.refractions.net/geos-$VERSION_geos.tar.bz2"
    ;;

--build)
    cd "$SOURCE"
    tar xfvj "$DOWNLOAD/geos-$VERSION_geos.tar.bz2"
    cd "geos-$VERSION_geos"
    gsed 's,-lgeos,-lgeos -lstdc++,' -i tools/geos-config.in
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        --disable-swig
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "geos-$VERSION_geos"
    ;;

esac


#---
#   proj
#
#   http://www.remotesensing.org/proj/
#---

case "$1" in

--new-versions)
    echo "VERSION_proj=`
        wget -q -O- 'http://www.remotesensing.org/proj/' |
        gsed -n 's,.*proj-\([0-9][^>]*\)\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "proj-$VERSION_proj.tar.gz" &>/dev/null ||
    wget -c "ftp://ftp.remotesensing.org/proj/proj-$VERSION_proj.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/proj-$VERSION_proj.tar.gz"
    cd "proj-$VERSION_proj"
    gsed 's,install-exec-local[^:],,' -i src/Makefile.in
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET"
    gmake install bin_PROGRAMS= noinst_PROGRAMS=
    cd "$SOURCE"
    rm -rfv "proj-$VERSION_proj"
    ;;

esac


#---
#   GeoTiff
#
#   http://www.remotesensing.org/geotiff/
#---

case "$1" in

--new-versions)
    echo "VERSION_libgeotiff=`
        wget -q -O- 'http://www.remotesensing.org/geotiff/geotiff.html' |
        gsed -n 's,.*libgeotiff-\([0-9][^>]*\)\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "libgeotiff-$VERSION_libgeotiff.tar.gz" &>/dev/null ||
    wget -c "ftp://ftp.remotesensing.org/pub/geotiff/libgeotiff/libgeotiff-$VERSION_libgeotiff.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/libgeotiff-$VERSION_libgeotiff.tar.gz"
    cd "libgeotiff-$VERSION_libgeotiff"
    gsed 's,/usr/local,@prefix@,' -i bin/Makefile.in
    touch configure
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET"
    gmake all install EXEEXT=.remove-me
    rm -fv "$PREFIX/$TARGET"/bin/*.remove-me
    cd "$SOURCE"
    rm -rfv "libgeotiff-$VERSION_libgeotiff"
    ;;

esac


#---
#   GDAL
#
#   http://www.gdal.org/
#---

case "$1" in

--new-versions)
    echo "VERSION_gdal=`
        wget -q -O- 'http://trac.osgeo.org/gdal/wiki/DownloadSource' |
        gsed -n 's,.*gdal-\([0-9][^>]*\)\.tar.*,\1,p' | 
        head -1`"
    ;;

--download)
    cd "$DOWNLOAD"
    tar tfz "gdal-$VERSION_gdal.tar.gz" &>/dev/null ||
    wget -c "http://www.gdal.org/dl/gdal-$VERSION_gdal.tar.gz"
    ;;

--build)
    cd "$SOURCE"
    tar xfvz "$DOWNLOAD/gdal-$VERSION_gdal.tar.gz"
    cd "gdal-$VERSION_gdal"
    ./configure \
        --host="$TARGET" \
        --disable-shared \
        --prefix="$PREFIX/$TARGET" \
        LIBS="-ljpeg" \
        --with-png="$PREFIX/$TARGET" \
        --with-libtiff="$PREFIX/$TARGET" \
        --with-geotiff="$PREFIX/$TARGET" \
        --with-jpeg="$PREFIX/$TARGET" \
        --with-gif="$PREFIX/$TARGET" \
        --with-curl="$PREFIX/$TARGET/bin/curl-config" \
        --with-geos="$PREFIX/$TARGET/bin/geos-config" \
        --without-python \
        --without-ngpython
    gmake lib-target
    gmake install-lib
    gmake -C port  install
    gmake -C gcore install
    gmake -C frmts install
    gmake -C alg   install
    gmake -C ogr   install OGR_ENABLED=
    gmake -C apps  install BIN_LIST=
    cd "$SOURCE"
    rm -rfv "gdal-$VERSION_gdal"
    ;;

esac


#---
#   Create package
#---

case "$1" in

--build)
    cd "$PREFIX"
    tar cfv - \
        bin \
        lib \
        libexec \
        "$TARGET/bin" \
        "$TARGET/include" \
        "$TARGET/lib" \
    | gzip -9 >"$ROOT/mingw_cross_env.tar.gz"
    ;;

esac
