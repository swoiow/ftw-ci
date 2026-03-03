FROM rust:slim AS base-builder
RUN apt-get update && apt-get install -y \
    build-essential pkg-config libssl-dev git gcc-mingw-w64-x86-64 \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN git clone https://github.com/cloudflare/boringtun.git .

# ==========================================
# Stage 2: Linux Build (独立构建阶段)
# ==========================================
FROM base-builder AS build-linux
RUN rustup target add x86_64-unknown-linux-gnu
RUN cargo build --release --bin boringtun-cli --target x86_64-unknown-linux-gnu

# ==========================================
# Stage 3: Windows Build (独立构建阶段)
# ==========================================
#FROM base-builder AS build-windows
#RUN rustup target add x86_64-pc-windows-gnu
#ENV CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc
#RUN cargo build --release --bin boringtun-cli --target x86_64-pc-windows-gnu

# ==========================================
# Stage 4: Final Artifact Collection (产物汇总)
# ==========================================
FROM runtime-alpine AS final
WORKDIR /app

# 如果你注释掉上方的某个构建阶段，这里的 COPY 也会相应地需要注释
# --- Linux 产物 ---
COPY --from=build-linux /src/target/x86_64-unknown-linux-gnu/release/boringtun-cli ./boringtun-linux
# --- Windows 产物 ---
#COPY --from=build-windows /src/target/x86_64-pc-windows-gnu/release/boringtun-cli.exe ./boringtun-windows.exe

CMD ["ls", "-lh", "/app"]