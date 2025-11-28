#!/bin/bash

set -e

error_handler() {
    echo "Error occurred in script at line: $1"
    exit 1
}

android_ndk_detect(){
    NDK_PAKEGE_URL="https://dl.google.com/android/repository/android-ndk-r27d-linux.zip?hl=zh-cn"
    echo "Please set ANDROID_NDK_HOME to your Android NDK path."
    echo "Automatically Set ANDROID_NDK_HOME by downloading NDK? (y/n)"
    read answer
    if [ "$answer" != "y" -a "$answer" != "Y" ]; then
        return 1
    fi
    echo "Downloading NDK..."
    wget -q "$NDK_PAKEGE_URL" -O android-ndk.zip
    unzip -q android-ndk.zip -d $HOME
    echo "export ANDROID_NDK_HOME=$HOME/android-ndk-r27d" >> $HOME/.bashrc
    source $HOME/.bashrc
    echo "NDK has been downloaded and configured."
    return 0
}

trap 'error_handler $LINENO' ERR

if [ -z "$ANDROID_NDK_HOME" ]; then
    android_ndk_detect
fi

export API=21
export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export AR=llvm-ar
export RANLIB=llvm-ranlib

if [ $1 -eq 32 ]; then
	echo "build to 32"
    	export TARGET=armv7a-linux-androideabi
	export CC=armv7a-linux-androideabi$API-clang
	export CXX=armv7a-linux-androideabi$API-clang++
else
	echo "build to 64"
	export TARGET=aarch64-linux-android
	export CC=aarch64-linux-android$API-clang
	export CXX=aarch64-linux-android$API-clang++

fi

INSTALL_DIR="`pwd`/out_libs/$TARGET"

./configure --host=$TARGET \
            --enable-float \
            --enable-neon \
            --prefix=$INSTALL_DIR \
            --disable-doc \
            CC=$CC \
            CXX=$CXX \
            AR=$AR \
            RANLIB=$RANLIB \
            CFLAGS="-O3 -fPIC" \
            LDFLAGS="-static"

make -j$(nproc)

make install
echo “”
echo "################################################"
echo "#Build and installation completed successfully.#"
echo "################################################"
exit 0
