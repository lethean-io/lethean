FROM debian:bullseye-20241016-slim

ARG DAEMON_CHAIN=seed.lethean.io:48782
ENV DAEMON_CHAIN=${DAEMON_CHAIN}
COPY --chmod=0777  --from=lthn/chain:latest /usr/local/bin/lethean* /usr/local/bin/

RUN adduser wallet --disabled-password

VOLUME /wallets

USER wallet
WORKDIR /wallets
ENTRYPOINT lethean-wallet-cli --daemon-host=${DAEMON_CHAIN}