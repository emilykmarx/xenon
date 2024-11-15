# Assumes run from projects

FROM golang:1.20.1

ARG XENON_BRANCH=feature_adapt_k8s

# Slow stuff and flaky Debian archives first so they get cached
RUN set -ex; \
    # xenon deps
    apt-get update && apt install -y \
    iputils-ping vim

# xenon
WORKDIR /go/src/github.com/radondb
COPY wtf_project/xenon xenon
# Copy in version of go/net 1.20 with dns,files order
COPY wtf_project/go1.20.1/src/net/conf.go /usr/local/go/src/net/
# Copy in version that makes A queries only
COPY wtf_project/go1.20.1/src/net/dnsclient_unix.go /usr/local/go/src/net/
# Copy in /etc/resolv.conf that will get an answer for localhost using first fqdn
# (so only sends one query per ping, if dnsclient_unix only makes A queries)
COPY wtf_project/xenon/src/build/etc_resolv.conf /etc/resolv.conf.xenon
# Confirm nss open did the right thing
COPY wtf_project/go1.20.1/src/net/nss.go /usr/local/go/src/net/

RUN set -ex; \
    cd xenon; \
    go env -w GO111MODULE=off; \
    make build

RUN set -ex \
    && addgroup --gid 1001 mysql && adduser --uid 1001 --gecos 1001 --system mysql \
    && mkdir -p /etc/xenon /var/lib/xenon /lib64 \
    && echo "/etc/xenon/xenon.json" > /config.path \
    # allow to change config files
    && chown -R 1001:1001 /etc/xenon /var/lib/xenon

ENV PATH="/go/src/github.com/radondb/xenon/bin/:${PATH}"

EXPOSE 8801
VOLUME ["/var/lib/xenon", "/etc/xenon"]

WORKDIR /
COPY wtf_project/xenon/src/build/helm_docker_entrypoint.sh .
COPY wtf_project/xenon/src/build/init.txt .

# Delve
COPY config_tracing/delve delve
# need to build delve
RUN set -ex; \
    go env -w GO111MODULE=on; \
    cd delve; \
    go install github.com/go-delve/delve/cmd/dlv; \
    go install ./cmd/dlv/dlv_config_client; \
    cd ..

ENTRYPOINT ["/helm_docker_entrypoint.sh"]
#CMD ["xenon", "-c", "/etc/xenon/xenon.json"]
CMD ["sleep", "infinity"]
# Pod status will show as initializing, but can exec into xenon container and run

# Delve commands
#CMD ["dlv", "exec", "--headless", "--api-version=2", "--accept-multiclient", "--listen=:4040", "/go/src/github.com/radondb/xenon/bin/xenon", "--", "-c", "/etc/xenon/xenon.json"]
# Interactive:
    # dlv exec --init=init.txt /go/src/github.com/radondb/xenon/bin/xenon -- -c /etc/xenon/xenon.json
    # dlv exec --headless --api-version=2 --accept-multiclient --listen=:4040 \
        #/go/src/github.com/radondb/xenon/bin/xenon -- -c /etc/xenon/xenon.json \
        #> server_out.txt 2> server_err.txt
    # dlv_config_client -initial_bp_file=/usr/local/go/src/net/dnsconfig_unix.go -initial_bp_line=144 -initial_watchexpr=conf.search \
    #  > client_out.txt 2> client_err.txt
    # (not ./dlv_config_client - there may be an old executable there if used `go build` for client locally)
