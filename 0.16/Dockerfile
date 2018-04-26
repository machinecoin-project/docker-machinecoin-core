FROM debian:stable-slim

LABEL maintainer.0="Nico Lucciola (@nigho)"

RUN useradd -r machinecoin \
  && apt-get update -y \
  && apt-get install -y curl gnupg \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && set -ex \
  && for key in \
    B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
  done

ENV GOSU_VERSION=1.10

RUN curl -o /usr/local/bin/gosu -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture) \
  && curl -o /usr/local/bin/gosu.asc -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

ENV MACHINECOIN_VERSION=0.16.0
ENV MACHINECOINCOIN_DATA=/home/machinecoin/.machinecoin
ENV PATH=/opt/machinecoin-${MACHINECOIN_VERSION}/bin:$PATH

RUN curl -fSL https://github.com/machinecoin-project/machinecoin-core/releases/download/machinecoin-core-${MACHINECOIN_VERSION}/SHA256SUMS.asc \
  && curl -fSL https://github.com/machinecoin-project/machinecoin-core/releases/download/machinecoin-core-${MACHINECOIN_VERSION}/machinecoin-${MACHINECOIN_VERSION}-x86_64-linux-gnu.tar.gz \
  && gpg --verify SHA256SUMS.asc \
  && grep " machinecoin-${MACHINECOIN_VERSION}-x86_64-linux-gnu.tar.gz\$" SHA256SUMS.asc | sha256sum -c - \
  && tar -xzf *.tar.gz -C /opt \
  && rm *.tar.gz *.asc

COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/home/machinecoin/.machinecoin"]

EXPOSE 40332 40333 50332 50333 60332 60333

ENTRYPOINT ["/entrypoint.sh"]

CMD ["machinecoind"]