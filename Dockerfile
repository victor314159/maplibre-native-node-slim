# Multi-stage build: Build MapLibre Native from source
FROM node:24-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    cmake \
    ccache \
    ninja-build \
    pkg-config \
    git \
    libcurl4-openssl-dev \
    libglfw3-dev \
    libuv1-dev \
    libpng-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    xvfb \
    libgl1-mesa-dev \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    libx11-dev \
    libxext-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone MapLibre Native repository
RUN git clone --recurse-submodules --depth 1 --branch main https://github.com/maplibre/maplibre-native.git

WORKDIR /build/maplibre-native

# Configure and build the Node.js bindings
RUN cmake . -B build -G Ninja \
    -DMLN_WITH_NODE=ON \
    -DMLN_WITH_OPENGL=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DMLN_WITH_WERROR=OFF

RUN cmake --build build -j $(nproc)

# Runtime stage
FROM node:24-slim

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
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
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install other npm dependencies (excluding @maplibre/maplibre-gl-native)
RUN npm install --ignore-scripts || true

# Copy the built MapLibre Native module from builder
RUN mkdir -p node_modules/@maplibre/maplibre-gl-native
COPY --from=builder /build/maplibre-native/platform/node/index.js node_modules/@maplibre/maplibre-gl-native/
COPY --from=builder /build/maplibre-native/platform/node/index.d.ts node_modules/@maplibre/maplibre-gl-native/
COPY --from=builder /build/maplibre-native/platform/node/package.json node_modules/@maplibre/maplibre-gl-native/
COPY --from=builder /build/maplibre-native/platform/node/README.md node_modules/@maplibre/maplibre-gl-native/

# Copy the compiled .node files to the lib directory with correct naming
# Node.js v24 uses ABI version 137
RUN mkdir -p node_modules/@maplibre/maplibre-gl-native/lib/node-v137
COPY --from=builder /build/maplibre-native/build/platform/node/mbgl-node.abi-137.node \
    node_modules/@maplibre/maplibre-gl-native/lib/node-v137/mbgl.node

# Copy application code
COPY . .

# Run the test
CMD ["npm", "start"]
