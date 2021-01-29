
FROM debian:stable-slim

RUN set -ex \
    && apt-get update \
    && apt-get install -y libssl-dev apt-transport-https ca-certificates gpg \
    && update-ca-certificates \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF \
    && gpg --export 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C | apt-key add - \
    && gpg --export BC528686B50D79E339D3721CEB3E94ADBE1229CF | apt-key add - \
    && echo 'deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/10/prod buster main' | tee /etc/apt/sources.list.d/microsoft.list > /dev/null \
    && echo 'deb https://deb.ln-ask.me/beta buster common local desktop' | tee /etc/apt/sources.list.d/cryptoanarchy.list > /dev/null \
    && apt-get update \
    && apt-get install -y python3 python3-distutils postgresql electrs curl acl libzmq5 \
    && curl https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - \
    && echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null \
    && apt-get update \
    && apt-get -y install mongodb-org || true \
    && cd /root \
    && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python3 get-pip.py \
    && pip3 install pytest \
    && pip3 install requests \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --system --group --home /srv/bitcoin bitcoin \
    && adduser --system --group --home /srv/electrs electrs \
    && adduser --system --group --home /srv/mercury mercury \
    && adduser --system --group --home /srv/mongo mongo \
    && adduser --system --group --home /srv/mainstay mainstay \
    && adduser --system --group --home /srv/tests tester \
    && mkdir /var/log/daemons \
    && ln -s /srv/mainstay/src /src


COPY --from=commerceblock/mercury:latest /usr/local/bin/mercury /usr/local/bin/

COPY --from=commerceblock/bitcoin:0.20.1 /opt/bitcoin-*/bin/bitcoin-cli /usr/local/bin/
COPY --from=commerceblock/bitcoin:0.20.1 /opt/bitcoin-*/bin/bitcoind /usr/local/bin/
COPY --from=commerceblock/bitcoin:0.20.1 /opt/bitcoin-*/bin/bitcoin-tx /usr/local/bin/
COPY --from=commerceblock/bitcoin:0.20.1 /opt/bitcoin-*/bin/bitcoin-wallet /usr/local/bin/

COPY --from=commerceblock/mainstay:latest /go/bin/* /usr/local/bin/

COPY ./mainstay-config.json /srv/mainstay/src/mainstay/config/conf.json 
COPY ./postgres-setup.txt /etc/postgres-setup.txt
COPY ./mongo-setup.txt /etc/mongo-setup.txt
COPY ./tests/* /srv/tests/
COPY ./docker-entrypoint.sh /docker-entrypoint.sh


ENTRYPOINT ["/docker-entrypoint.sh"]

