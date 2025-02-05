FROM ubuntu:latest

# important lib things
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -yq software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install -yq \
    curl g++ make cmake autoconf automake libtool m4 libopus-dev ffmpeg wget python3.8


# very important lib thing
RUN curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
RUN chmod a+rx /usr/local/bin/youtube-dl

ENV PATH=$PATH:/usr/local/bin/python

# the line we needed, not the line we deserved
RUN ln -s /usr/bin/python3 /usr/bin/python

# rust
RUN mkdir -m777 /opt/rust /opt/cargo
ENV RUSTUP_HOME=/opt/rust CARGO_HOME=/opt/cargo PATH=/opt/cargo/bin:$PATH
RUN wget --https-only --secure-protocol=TLSv1_2 -O- https://sh.rustup.rs | sh /dev/stdin -y
RUN rustup target add x86_64-unknown-linux-gnu
RUN printf '#!/bin/sh\nexport CARGO_HOME=/opt/cargo\nexec /bin/sh "$@"\n' >/usr/local/bin/sh
RUN chmod +x /usr/local/bin/sh

# crusty rust
WORKDIR /workspace

COPY . /workspace

# compiled crusty rust
RUN cargo build --release
ENTRYPOINT ["/workspace/target/release/guobaplay-rs"]
