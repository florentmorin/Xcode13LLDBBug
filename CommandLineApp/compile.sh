#!/bin/sh

SDK_PATH=$(xcrun --show-sdk-path)
SDK_VERSION=$(xcrun --show-sdk-version)
BUILD_PATH="./build"
LIB_BUILD_PATH="${BUILD_PATH}/lib"
ARCH="arm64"
TARGET="${ARCH}-apple-macosx12.0"
TARGET_SDK_VERSION="${SDK_VERSION}.0"
DEVELOPER_DIR=$(xcode-select -p)
SWIFT_FRONTEND_PATH="${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend"
LIBTOOL_PATH="${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/bin/libtool"
LD_PATH="${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld"
DSYMUTIL_PATH="${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/bin/dsymutil"

if [[ -d "build" ]]; then
    rm -rf "${BUILD_PATH}"
fi

mkdir "${BUILD_PATH}"
mkdir "${LIB_BUILD_PATH}"

# libHello

$SWIFT_FRONTEND_PATH \
    -frontend \
    -c \
    -primary-file Hello.swift \
    -emit-module-path "${LIB_BUILD_PATH}/Hello-1.swiftmodule" \
    -emit-module-doc-path "${LIB_BUILD_PATH}/Hello-1.swiftdoc" \
    -emit-module-source-info-path "${LIB_BUILD_PATH}/Hello-1.swiftsourceinfo" \
    -target "${TARGET}" \
    -Xllvm -aarch64-use-tbi \
    -enable-objc-interop \
    -stack-check \
    -sdk "${SDK_PATH}" \
    -color-diagnostics \
    -g -static -Onone \
    -new-driver-path "${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver" \
    -resource-dir "${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift" \
    -enable-anonymous-context-mangled-names \
    -module-name Hello \
    -target-sdk-version "${TARGET_SDK_VERSION}" \
    -parse-as-library -o "${LIB_BUILD_PATH}/Hello-1.o"

$SWIFT_FRONTEND_PATH \
    -frontend -merge-modules \
    -emit-module "${LIB_BUILD_PATH}/Hello-1.swiftmodule" \
    -parse-as-library -disable-diagnostic-passes -disable-sil-perf-optzns \
    -target "${TARGET}" \
    -Xllvm -aarch64-use-tbi -enable-objc-interop -stack-check \
    -sdk "${SDK_PATH}" \
    -color-diagnostics -g -static -Onone \
    -new-driver-path "${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver" \
    -resource-dir "${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift" \
    -enable-anonymous-context-mangled-names \
    -module-name Hello \
    -target-sdk-version "${TARGET_SDK_VERSION}" \
    -emit-module-doc-path "${LIB_BUILD_PATH}/Hello.swiftdoc" \
    -emit-module-source-info-path "${LIB_BUILD_PATH}/Hello.swiftsourceinfo" \
    -o "${LIB_BUILD_PATH}/Hello.swiftmodule" \
    -emit-abi-descriptor-path "${LIB_BUILD_PATH}/Hello.abi.json"

$LIBTOOL_PATH \
    -static "${LIB_BUILD_PATH}/Hello-1.o" \
    -o "${LIB_BUILD_PATH}/libHello.a"


# app

$SWIFT_FRONTEND_PATH \
    -frontend -c \
    -primary-file main.swift \
    -emit-module-path "${BUILD_PATH}/main-1.swiftmodule" \
    -emit-module-doc-path "${BUILD_PATH}/main-1.swiftdoc" \
    -emit-module-source-info-path "${BUILD_PATH}/main-1.swiftsourceinfo" \
    -target "${TARGET}" \
    -Xllvm -aarch64-use-tbi -enable-objc-interop -stack-check \
    -sdk "${SDK_PATH}" -I "${LIB_BUILD_PATH}" \
    -color-diagnostics -g -Onone \
    -new-driver-path "${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver" \
    -resource-dir "${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift" \
    -enable-anonymous-context-mangled-names \
    -module-name app \
    -target-sdk-version "${TARGET_SDK_VERSION}" \
    -o "${BUILD_PATH}/main-1.o"

$SWIFT_FRONTEND_PATH \
    -frontend -merge-modules \
    -emit-module "${BUILD_PATH}/main-1.swiftmodule" -parse-as-library \
    -disable-diagnostic-passes -disable-sil-perf-optzns \
    -target "${TARGET}" \
    -Xllvm -aarch64-use-tbi -enable-objc-interop -stack-check \
    -sdk "${SDK_PATH}" -I "${LIB_BUILD_PATH}" \
    -color-diagnostics -g -Onone \
    -new-driver-path "${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver" \
    -resource-dir "${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift" \
    -enable-anonymous-context-mangled-names \
    -module-name app \
    -target-sdk-version "${TARGET_SDK_VERSION}" \
    -emit-module-doc-path "${BUILD_PATH}/app-1.swiftdoc" \
    -emit-module-source-info-path "${BUILD_PATH}/app-1.swiftsourceinfo" \
    -o "${BUILD_PATH}/app-1.swiftmodule" \
    -emit-abi-descriptor-path "${BUILD_PATH}/app-1.abi.json"
$LD_PATH \
    "${BUILD_PATH}/main-1.o" \
    -add_ast_path "${LIB_BUILD_PATH}/Hello.swiftmodule" \
    -add_ast_path "${BUILD_PATH}/app-1.swiftmodule" \
    "${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/clang/lib/darwin/libclang_rt.osx.a" \
    -syslibroot "${SDK_PATH}" \
    -lobjc -lSystem -arch "${ARCH}" \
    -L "${DEVELOPER_DIR}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx" \
    -L "${SDK_PATH}/usr/lib/swift" \
    -platform_version macos 12.0.0 12.1.0 -no_objc_category_merging -L "${LIB_BUILD_PATH}" -lHello \
    -o "${BUILD_PATH}/app"

$DSYMUTIL_PATH "${BUILD_PATH}/app" -o "${BUILD_PATH}/app.dSYM"
