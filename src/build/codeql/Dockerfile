# Assumes run from projects: wtf_project has xenon and go, config_tracing has codeql-home

# 1. Build extractor
FROM golang:1.22 as builder

RUN apt update && apt install -y \
  default-jre \
  default-jdk

# Note copying changed files invalidates image build cache, so do slow stuff first
COPY config_tracing/codeql-home/codeql-repo codeql-repo
WORKDIR codeql-repo/go

RUN make extractor

# 2. Build codeql db (which includes building xenon in same way as usual)
FROM golang:1.20.1

RUN apt update && apt install -y \
  vim

ARG XENON_BRANCH=feature_adapt_k8s
WORKDIR /go/src/github.com/radondb
COPY wtf_project/xenon xenon
# Copy in version of go/net 1.20 with dns,files order
COPY wtf_project/xenon/go_1_20_1/net/conf.go /usr/local/go/src/net/
# need to build xenon?
RUN go env -w GO111MODULE=off

WORKDIR /
# Copy in codeql-home
# If the build cache invalidating here gets annoying, can just copy CLI I think
COPY config_tracing/codeql-home codeql-home
ENV PATH="${PATH}:/codeql-home/codeql"
# Copy in extractor, *after* copying in codeql
COPY --from=builder /go/codeql-repo/go/tools/linux64/go-extractor /codeql-home/codeql/go/tools/linux64/

CMD ["sleep", "infinity"]

# This command works:
# codeql database create /xenon_db --command "make build" --source-root /go/src/github.com/radondb/xenon --language=go
# or:
# codeql database create /xenon_db --command "make buildtestdf" --source-root /go/src/github.com/radondb/xenon --language=go
