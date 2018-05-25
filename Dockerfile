# runtime stage
FROM itmanagerro/monbuild

ARG BOOST_VERSION=1_66_0
ENV BOOST_ROOT /usr/local/boost_${BOOST_VERSION}
ARG OPENSSL_VERSION=1.0.2n
ENV OPENSSL_ROOT_DIR=/usr/local/openssl-${OPENSSL_VERSION}

WORKDIR /src
COPY . .

ARG NPROC=6
RUN rm -rf build && \
    if [ -z "$NPROC" ];then make VERBOSE=1 -j$(nproc) release-static;else make VERBOSE=1 -j$NPROC release-static;fi

RUN apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt

COPY --from=builder /src/build/release/bin/* /usr/local/bin/

# Contains the blockchain
VOLUME /root/.bitmonero

# Generate your wallet via accessing the container and run:
# cd /wallet
# monero-wallet-cli
VOLUME /wallet

EXPOSE 18080
EXPOSE 18081

ENTRYPOINT ["monerod", "--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=18080", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=18081", "--non-interactive", "--confirm-external-bind"] 
