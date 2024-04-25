FROM ubuntu:16.04 as build

ARG RELEASE_TYPE=release-static

RUN set -ex && \
    apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq --no-install-recommends install \
      ca-certificates libboost-all-dev cmake g++ git libssl-dev make pkg-config libunbound-dev

WORKDIR /lethean
COPY . .

RUN make -j$(nproc) ${RELEASE_TYPE}
RUN make ci-release

FROM debian:bullseye-20240423-slim as container

COPY --from=build /lethean/build/packaged/lethean* /usr/local/bin/
RUN apt-get update && apt-get install -y ca-certificates

RUN adduser --system --group --disabled-password --home /home/lethean --shell /bin/sh lethean && \
	mkdir -p /wallet /home/lethean/.letheand && \
	chown -R lethean:lethean /home/lethean/.letheand && \
	chown -R lethean:lethean /wallet

# Contains the blockchain
VOLUME /home/lethean/.letheand
VOLUME /wallet

COPY utils/docker/entrypoint.sh /entrypoint.sh
RUN chmod a+rx /entrypoint.sh

ENV LOG_LEVEL 0
ENV SEED_NODE seed.lethean.io

EXPOSE 48782
EXPOSE 48772
EXPOSE 38772
EXPOSE 38782

USER lethean
WORKDIR /home/lethean

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "letheand" ]
