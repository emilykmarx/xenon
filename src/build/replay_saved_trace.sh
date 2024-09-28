#!/bin/sh
set -e

# Replay and run client on saved trace

# Assumes run from projects

echo 'Fill in trace id!!!!!!!!!!!'
trace_id=single_query

docker build -f wtf_project/xenon/src/build/debian_Dockerfile -t xenon .
docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --name xenon --rm xenon &
sleep 1
docker container cp ./config_tracing/delve/cmd/dlv/dlv_config_client/xenon_trace/$trace_id xenon:/

docker exec xenon mkdir /outfiles

docker exec xenon sh -c "dlv replay --headless --api-version=2 --accept-multiclient --listen=:4040 \
/$trace_id > /outfiles/server_out.txt 2> /outfiles/server_err.txt" &
sleep 1

docker exec xenon sh -c 'dlv_config_client -initial_bp_file=/usr/local/go/src/net/dnsconfig_unix.go -initial_bp_line=144 -initial_watchexpr=conf.search \
    > /outfiles/client_out.txt 2> /outfiles/client_err.txt'
