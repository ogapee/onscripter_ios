export set PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:$PATH
export set SDK_CC=`xcrun -find -sdk iphonesimulator clang`
export set SDK_CFLAGS='-arch x86_64 -miphoneos-version-min=7.0'
export set SDK_PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
export set HOST=x86_64-apple-darwin
export set INSTALL_PATH=$PWD/Release-iphonesimulator
mkdir -p $INSTALL_PATH
