# Assumes run from wtf-project, which has xenon and go

##############################################################################
#  Build Xenon
###############################################################################
FROM golang:1.13.15 as builder

ARG XENON_BRANCH=feature_adapt_k8s
WORKDIR /go/src/github.com/radondb
COPY xenon xenon
# Copy in my version of net
COPY go/src/net /usr/local/go/src/net

RUN set -ex; \
    cd xenon; \
    make build

###############################################################################
#  Docker image for Xenon
###############################################################################
FROM golang:1.13.15-alpine

RUN set -ex \
    && addgroup -g 1001 mysql && adduser -u 1001 -g 1001 -S mysql \
    && apk add --no-cache curl make bash jq iputils tcpdump git \
    && mkdir -p /etc/xenon /var/lib/xenon /lib64 \
    && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && echo "/etc/xenon/xenon.json" > /config.path \
    # allow to change config files
    && chown -R 1001:1001 /etc/xenon /var/lib/xenon \
    # Not in original xenon base image (non-golang alpine) - configures DNS resolution order as files,dns
    && rm -f /etc/nsswitch.conf

ENV PATH="/go/src/github.com/radondb/xenon/bin/:${PATH}"
# For delve: Copy in xenon source as well as executable
COPY --from=builder /go/src/github.com/radondb/xenon /go/src/github.com/radondb/xenon

# Build delve
RUN git clone https://github.com/go-delve/delve.git $GOPATH/src/github.com/go-delve/delve; \
    cd $GOPATH/src/github.com/go-delve/delve; \
    # Latest version that works with go1.13
    git checkout v1.6.0; \
    make install

WORKDIR /
EXPOSE 8801
VOLUME ["/var/lib/xenon", "/etc/xenon"]

COPY xenon/src/build/helm_docker_entrypoint.sh .

ENTRYPOINT ["/helm_docker_entrypoint.sh"]
# To start xenon on entry: CMD ["xenon", "-c", "/etc/xenon/xenon.json"]
CMD ["sleep", "infinity"]
