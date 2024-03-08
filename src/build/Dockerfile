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

FROM alpine:3.13

RUN set -ex \
    && addgroup -g 1001 mysql && adduser -u 1001 -g 1001 -S mysql \
    && apk add --no-cache curl bash jq iputils tcpdump \
    && mkdir -p /etc/xenon /var/lib/xenon /lib64 \
    && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && echo "/etc/xenon/xenon.json" > /config.path \
    # allow to change config files
    && chown -R 1001:1001 /etc/xenon /var/lib/xenon

COPY --from=builder /go/src/github.com/radondb/xenon/bin/xenon /usr/local/bin/xenon
COPY --from=builder /go/src/github.com/radondb/xenon/bin/xenoncli /usr/local/bin/xenoncli

WORKDIR /
EXPOSE 8801
VOLUME ["/var/lib/xenon", "/etc/xenon"]

COPY xenon/src/build/helm_docker_entrypoint.sh .

ENTRYPOINT ["/helm_docker_entrypoint.sh"]
CMD ["xenon", "-c", "/etc/xenon/xenon.json"]
