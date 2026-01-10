# Test MapLibre Native

Test project for investigating [MapLibre Native issue #4024](https://github.com/maplibre/maplibre-native/issues/4024)

## Current Status

The prebuilt npm binaries for `@maplibre/maplibre-gl-native` require GLIBC 2.38 (Ubuntu 24.04), but Debian Bookworm (used by `node:24-slim`) only has GLIBC 2.36. This causes the following error:

```
Error: /lib/aarch64-linux-gnu/libm.so.6: version `GLIBC_2.38' not found
```

**This confirms issue #4024** - the Ubuntu binaries are not compatible with Debian-based Docker images.

## Setup

### Using Docker (Builds from Source)

The Dockerfile now uses a multi-stage build to compile MapLibre Native from source, which resolves the GLIBC incompatibility:

```bash
docker build -t test-maplibre-native .
docker run test-maplibre-native
```

This will build the native module compatible with Debian's GLIBC 2.36 and run successfully.

### Building from Source

According to the [official build documentation](https://github.com/maplibre/maplibre-native/blob/main/platform/node/DEVELOPING.md), you can build the Node.js bindings from source by installing these dependencies on Debian/Ubuntu:

```bash
sudo apt-get install -y \
  build-essential \
  clang \
  cmake \
  ccache \
  ninja-build \
  pkg-config \
  libcurl4-openssl-dev \
  libglfw3-dev \
  libuv1-dev \
  libpng-dev \
  libicu-dev \
  libjpeg-turbo8-dev \
  libwebp-dev \
  xvfb
```

Then clone the maplibre-native repository and build:

```bash
git clone --recurse-submodules https://github.com/maplibre/maplibre-native.git
cd maplibre-native
cmake . -B build -G Ninja -DMLN_WITH_NODE=ON -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_BUILD_TYPE=Release
cmake --build build -j $(nproc)
```

### Local Development

Install dependencies:

```bash
npm install
```

Run the test:

```bash
npm start
```

## Possible Solutions

1. **Build Debian-specific binaries** - Create prebuilt binaries for Debian with GLIBC 2.36
2. **Build from source in Dockerfile** - Compile the native module during Docker image build
3. **Use Ubuntu-based images** - Switch to Ubuntu-based Node.js images instead of Debian

## Dependencies

- `@maplibre/maplibre-gl-native`: MapLibre GL Native bindings for Node.js
- Base image: `node:24-slim` (Debian Bookworm with GLIBC 2.36)

## System Libraries Required

The Dockerfile includes workarounds for Ubuntu vs Debian library version differences:
- OpenGL libraries (libglx0, libgl1, libopengl0, libegl1, libgles2)
- X11 libraries (libx11-6, libxext6)
- Image libraries (libjpeg62-turbo, libpng16-16, libwebp7)
- Other: libcurl4, libicu72, libuv1
- Symlinks created for version compatibility (libjpeg.so.8 → libjpeg.so.62, libicu*.so.74 → libicu*.so.72)
