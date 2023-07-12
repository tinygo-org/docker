# Local image to download dependencies
# No emulation, runs with host arch
FROM --platform=${BUILDPLATFORM} debian:stable-slim as base

ARG TARGETOS
ARG TARGETARCH

RUN  apt-get clean && apt-get update && \
    apt-get install -y wget

ENV GO_RELEASE=1.20.5
RUN wget https://dl.google.com/go/go${GO_RELEASE}.${TARGETOS}-${TARGETARCH}.tar.gz && \
    tar xfv go${GO_RELEASE}.${TARGETOS}-${TARGETARCH}.tar.gz -C /usr/local && \
    find /usr/local/go -mindepth 1 -maxdepth 1 ! -name 'src' ! -name 'VERSION' ! -name 'bin' ! -name 'pkg' -exec rm -rf {} +


ENV TINYGO_RELEASE=0.28.1-polywrap.1
RUN wget https://github.com/polywrap/tinygo/releases/download/v${TINYGO_RELEASE}/tinygo.${TARGETOS}-${TARGETARCH}.tar.gz && \
    tar xfv tinygo.${TARGETOS}-${TARGETARCH}.tar.gz -C /usr/local


# Build final image, emulation, runs as TARGETARCH
FROM debian:stable-slim as build

RUN apt-get clean && apt-get update && \
    apt-get install -y gcc git sudo make && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash tinygo
RUN usermod -aG sudo tinygo && echo "tinygo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER tinygo
WORKDIR /home/tinygo   

COPY --from=base /usr/local/go /usr/local/go
COPY --from=base /usr/local/tinygo /usr/local/tinygo

ENV PATH=${PATH}:/usr/local/tinygo/bin
ENV PATH=${PATH}:/usr/local/go/bin

# Run a unittest to validate that the image arch and the compiled version matches
FROM build as UnitTest

ARG TARGETARCH
RUN  export TINY_ARCH=$(tinygo info | grep GOARCH | awk '{print $2}') && \
    if [ "${TARGETARCH}" != "${TINY_ARCH}" ]; then exit 1; else exit 0; fi


# Final image, runs as TARGETARCH
FROM build as final

CMD ["tinygo"]
