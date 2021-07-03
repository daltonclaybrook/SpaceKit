#!/bin/bash
# https://github.com/rust-lang/rust/issues/79408

#fail script if a command fails
set -e

#create temp dir
tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')
echo "Created tempdir at $tmpdir"

function cleanup {      
  rm -rf "$tmpdir"
  echo "Deleted temp working directory $tmpdir"
}

trap cleanup EXIT

if !(rustup toolchain list | grep -q "nightly";) then
  echo "install nightly toolchain"
  rustup toolchain install nightly
fi

#install rust-src for nightly
rustup +nightly component add rust-src


swift_module_map() {
  echo 'module libspace_kit {'
  echo '    header "space_kit.h"'
  echo '    export *'
  echo '}'
}

echo "Building architectures..."

XCFRAMEWORK_ARGS=""
for ARCH in "x86_64-apple-ios" "aarch64-apple-ios" "aarch64-apple-ios-sim"
do
  COMMAND="cargo +nightly build --release -Z build-std=core,std,alloc --manifest-path Cargo.toml --target archs/$ARCH.json --target-dir $tmpdir"
  echo $COMMAND
  $COMMAND
done

echo "Building fat binary from simulator slices..."

COMBINED_ARCH="aarch64-x86_64-apple-ios-sim"
mkdir -p "$tmpdir/$COMBINED_ARCH/release"
lipo "$tmpdir/aarch64-apple-ios-sim/release/libspace_kit.a" \
    "$tmpdir/x86_64-apple-ios/release/libspace_kit.a" \
    -create -output "$tmpdir/$COMBINED_ARCH/release/libspace_kit.a"

echo "Building headers and module maps..."

for ARCH in "aarch64-apple-ios" "$COMBINED_ARCH"
do
  cbindgen --config cbindgen.toml --crate space_kit --output "$tmpdir/$ARCH/release/headers/space_kit.h" .

  XCFRAMEWORK_ARGS="${XCFRAMEWORK_ARGS} -library $tmpdir/$ARCH/release/libspace_kit.a"
  XCFRAMEWORK_ARGS="${XCFRAMEWORK_ARGS} -headers $tmpdir/$ARCH/release/headers/"
  
  swift_module_map > "$tmpdir/$ARCH/release/headers/module.modulemap"
done

echo "Creating libspace_kit.xcframework..."

rm -rf libspace_kit.xcframework

XCODEBUILDCOMMAND="xcodebuild -create-xcframework $XCFRAMEWORK_ARGS -output libspace_kit.xcframework"
echo $XCODEBUILDCOMMAND
$XCODEBUILDCOMMAND
