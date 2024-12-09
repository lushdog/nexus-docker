FROM rust:bullseye

WORKDIR /usr/src/app

RUN apt update && apt install -y build-essential libssl-dev pkg-config protobuf-compiler git

RUN git clone https://github.com/nexus-xyz/network-api && \
    cd network-api && \
    git -c advice.detachedHead=false checkout $(git describe --tags $(git rev-list --tags --max-count=1))

RUN cd /usr/src/app/network-api/clients/cli && cargo build --release

WORKDIR /usr/src/app/network-api/clients/cli/target/release/

CMD ["./prover", "beta.orchestrator.nexus.xyz"]
