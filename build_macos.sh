#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
PROJECT_DIR="$(pwd)"

echo "==> [1/4] Checking MacKernelSDK..."
if [ ! -d "${PROJECT_DIR}/MacKernelSDK/Headers" ]; then
    rm -rf "${PROJECT_DIR}/MacKernelSDK"
    git clone --depth=1 https://github.com/acidanthera/MacKernelSDK.git "${PROJECT_DIR}/MacKernelSDK"
fi

echo "==> [2/4] Generating embedded firmware (MA-B0 + GF-A0-83 + PNVM)..."
rm -f "${PROJECT_DIR}/include/FwBinary.cpp"
python3 "${PROJECT_DIR}/scripts/zlib_compress_fw.py" "${PROJECT_DIR}/include/FwBinary.cpp" "${PROJECT_DIR}/itlwm/firmware"

echo "==> [3/4] Building itlwm.kext (Release) for Killer AX1675i (8086:7E40)..."
xcodebuild -project "${PROJECT_DIR}/itlwm.xcodeproj" \
    -scheme itlwm \
    -configuration Release \
    -derivedDataPath "${PROJECT_DIR}/build" \
    GIT_COMMIT="_7e40" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

mkdir -p "${PROJECT_DIR}/dist"
rm -rf "${PROJECT_DIR}/dist/itlwm.kext"
cp -R "${PROJECT_DIR}/build/Build/Products/Release/itlwm.kext" "${PROJECT_DIR}/dist/itlwm.kext"

echo "==> [4/4] Done!"
du -sh "${PROJECT_DIR}/dist/itlwm.kext"
echo "Output: ${PROJECT_DIR}/dist/itlwm.kext"
