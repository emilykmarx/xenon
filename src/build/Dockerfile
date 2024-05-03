# Assumes run from wtf-project, which has xenon and go

FROM golang:1.20.1-alpine

ARG XENON_BRANCH=feature_adapt_k8s
WORKDIR /go/src/github.com/radondb
COPY xenon xenon
# Copy in version of go/net 1.20 with dns,files order
COPY xenon/go_1_20_1/net/conf.go /usr/local/go/src/net/

RUN set -ex; \
    cd xenon; \
    apk add --no-cache curl bash jq iputils tcpdump git make; \
    # need to build xenon
    go env -w GO111MODULE=off; \
    make build

RUN set -ex \
    && addgroup -g 1001 mysql && adduser -u 1001 -g 1001 -S mysql \
    && mkdir -p /etc/xenon /var/lib/xenon /lib64 \
    && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && echo "/etc/xenon/xenon.json" > /config.path \
    # allow to change config files
    && chown -R 1001:1001 /etc/xenon /var/lib/xenon \
    # Not in original xenon base image (non-golang alpine) - configures DNS resolution order as files,dns
    && rm /etc/nsswitch.conf

ENV PATH="/go/src/github.com/radondb/xenon/bin/:${PATH}"

RUN git clone https://github.com/go-delve/delve
# need to build delve
RUN go env -w GO111MODULE=on; \
    cd delve; go install github.com/go-delve/delve/cmd/dlv

WORKDIR /
EXPOSE 8801
VOLUME ["/var/lib/xenon", "/etc/xenon"]

COPY xenon/src/build/helm_docker_entrypoint.sh .

ENTRYPOINT ["/helm_docker_entrypoint.sh"]
CMD ["sleep", "infinity"]
# Pod status will show as initializing, but can exec into xenon container and run
# `dlv exec /go/src/github.com/radondb/xenon/bin/xenon -- -c /etc/xenon/xenon.json`

# LEFT OFF with delve: https://alexsniffin.medium.com/debugging-remotely-in-kubernetes-with-go-fda4f3332316
# May want auto-start eventually
# CMD ["dlv", "exec", "--headless", "--listen", ":4040", "/go/src/github.com/radondb/xenon/bin/xenon", "--" "-c", "/etc/xenon/xenon.json"]
