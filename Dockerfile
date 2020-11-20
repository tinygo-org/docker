FROM debian:stable-slim

RUN apt-get clean && apt-get update && \
    apt-get install -y wget gcc gcc-avr avr-libc

ENV GO_RELEASE=1.15.2
RUN wget https://dl.google.com/go/go${GO_RELEASE}.linux-amd64.tar.gz && \
    tar xfv go${GO_RELEASE}.linux-amd64.tar.gz -C /usr/local && \
    rm go${GO_RELEASE}.linux-amd64.tar.gz && \
    find /usr/local/go -mindepth 1 -maxdepth 1 ! -name 'src' ! -name 'VERSION' ! -name 'bin' ! -name 'pkg' -exec rm -rf {} +
ENV PATH=${PATH}:/usr/local/go/bin

ENV TINYGO_RELEASE=0.16.0
RUN wget https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_RELEASE}/tinygo${TINYGO_RELEASE}.linux-amd64.tar.gz && \
    tar xfv tinygo${TINYGO_RELEASE}.linux-amd64.tar.gz -C /usr/local && \
    rm tinygo${TINYGO_RELEASE}.linux-amd64.tar.gz
ENV PATH=${PATH}:/usr/local/tinygo/bin

RUN apt-get remove -y wget && \
    apt-get autoremove -y && \
    apt-get clean

CMD ["tinygo"]
