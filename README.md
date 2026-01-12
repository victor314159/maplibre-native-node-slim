# MapLibre Native Node Slim

Prebuilt MapLibre Native binaries for Debian-based Node.js environments (Node.js 24+).

## Why This Package?

The official `@maplibre/maplibre-gl-native` npm package provides prebuilt binaries for Ubuntu 24.04, which are **incompatible with Debian** distributions like `node:slim` Docker images, because of some shared library differences. This package solves that problem by providing Debian-compatible prebuilt binaries.

## Installation

```bash
npm install @victor314159/maplibre-native-node-slim
```

## Usage

Same API as the official package:

```javascript
const mbgl = require('@victor314159/maplibre-native-node-slim');

// Use mbgl.Map, mbgl.Expression, etc.
```

## Runtime Dependencies

### Debian (Bookworm) - node:24-slim

When using this package, ensure these system libraries are installed:

```bash
apt-get install -y \
    libcurl4 \
    libuv1 \
    libpng16-16 \
    libicu72 \
    libjpeg62-turbo \
    libwebp7 \
    libglx0 \
    libgl1 \
    libopengl0 \
    libegl1 \
    libgles2 \
    libx11-6 \
    libxext6
```

**Note:** This package is built specifically for Debian. If you're using Ubuntu, use the official `@maplibre/maplibre-gl-native` package instead, which provides Ubuntu-compatible binaries.

## Supported Platforms

- **OS**: Linux (Debian-based)
- **Architectures**: x64, arm64
- **Node.js**: 24+
- **ABI**: 137

## How It Works

This package:
1. Builds MapLibre Native from source using Docker for both x64 and arm64
2. Includes prebuilt `.node` binaries in the npm package
3. Works with Debian-based Node.js environments

## Build Configuration

To update the MapLibre Native version, change `MAPLIBRE_VERSION` in the [Dockerfile](Dockerfile):

```dockerfile
ARG MAPLIBRE_VERSION=node-v6.3.0
```

Push to main, and GitHub Actions will automatically build and publish the new version.

## License

BSD-2-Clause (same as MapLibre Native)
