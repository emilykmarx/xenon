#!/bin/sh
set -e

# Assumes run from projects

docker build -f wtf_project/xenon/src/build/debian_Dockerfile -t xenon .
docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --name xenon --rm xenon &
sleep 1
docker exec xenon sh -c 'mkdir /outfiles; cat /etc/resolv.conf.xenon > /etc/resolv.conf' # overwrite resolv.conf

# Record and replay
docker exec xenon sh -c 'dlv exec --headless --backend=rr --api-version=2 --accept-multiclient --listen=:4040 \
    /go/src/github.com/radondb/xenon/bin/xenon -- -c /etc/xenon/xenon.json \
    > /outfiles/server_out.txt 2> /outfiles/server_err.txt'

# Should hang here - if not, perf counters likely in use => kill container and retry
