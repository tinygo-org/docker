FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y wget gcc gcc-avr avr-libc gnupg

RUN echo 'deb http://apt.llvm.org/buster/ llvm-toolchain-buster-8 main' > /etc/apt/sources.list.d/clang-8.list
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN apt-get update && apt-get install -y --no-install-recommends clang-8

ENV GO_RELEASE=1.12.5
RUN wget https://dl.google.com/go/go${GO_RELEASE}.linux-amd64.tar.gz && \
    tar xfv go${GO_RELEASE}.linux-amd64.tar.gz -C /usr/local && \
    rm go${GO_RELEASE}.linux-amd64.tar.gz && \
    find /usr/local/go -mindepth 1 -maxdepth 1 ! -name 'src' ! -name 'VERSION' -exec rm -rf {} +
ENV PATH=${PATH}:/usr/local/go/bin

ENV TINYGO_RELEASE=0.8.0
RUN wget https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_RELEASE}/tinygo${TINYGO_RELEASE}.linux-amd64.tar.gz && \
    tar xfv tinygo${TINYGO_RELEASE}.linux-amd64.tar.gz -C /usr/local && \
    rm tinygo${TINYGO_RELEASE}.linux-amd64.tar.gz
ENV PATH=${PATH}:/usr/local/tinygo/bin

RUN apt-get remove -y wget gnupg && \
    apt-get autoremove -y && \
    apt-get clean

CMD ["tinygo"]
