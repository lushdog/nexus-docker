FROM rust:bullseye AS builder

RUN apt update && apt install -y build-essential pkg-config libssl-dev protobuf-compiler git

WORKDIR /usr/src/app

RUN git clone https://github.com/nexus-xyz/network-api && \
    cd network-api && \
    git -c advice.detachedHead=false checkout $(git describe --tags $(git rev-list --tags --max-count=1))

RUN cd /usr/src/app/network-api/clients/cli && cargo build --release

FROM debian:bullseye-slim

RUN apt update && apt install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/app/network-api /usr/src/app/network-api

# 设置工作目录
WORKDIR /usr/src/app/network-api/clients/cli

# 设置默认命令
CMD ["./target/release/nexus-network", "--start", "--beta"]
