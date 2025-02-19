FROM rust:bullseye AS builder

RUN apt update && apt install -y wget build-essential unzip pkg-config libssl-dev git

WORKDIR /usr/src/app

RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protoc-21.12-linux-x86_64.zip && \
    unzip protoc-21.12-linux-x86_64.zip && \
    mv protoc-21.12-linux-x86_64/bin/protoc /usr/local/bin/

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
