#!/bin/sh
set -e

# Assumes run from projects

docker build -f wtf_project/xenon/src/build/debian_Dockerfile -t xenon .
docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --name xenon --rm xenon &
sleep 1
docker exec xenon mkdir /outfiles

# Record, replay and run client
docker exec xenon sh -c 'dlv exec --headless --backend=rr --api-version=2 --accept-multiclient --listen=:4040 \
    /go/src/github.com/radondb/xenon/bin/xenon -- -c /etc/xenon/xenon.json \
    > /outfiles/server_out.txt 2> /outfiles/server_err.txt'

echo Manually check if server started, retry if perf counters in use...then pkill xenon
exit

# Run client
docker exec xenon sh -c 'pkill xenon'
docker exec xenon sh -c 'dlv_config_client -initial_bp_file=/usr/local/go/src/net/dnsconfig_unix.go -initial_bp_line=144 -initial_watchexpr=conf.search \
    > /outfiles/client_out.txt 2> /outfiles/client_err.txt'

# Copy outfiles
docker container cp xenon:/outfiles/. ./config_tracing/delve/cmd/dlv/dlv_config_client/xenon_out

# Save trace for later replay
trace_id=$RANDOM
docker exec xenon sh -c 'cd /root/.local/share/rr/xenon-0; rr pack'
docker container cp xenon:/root/.local/share/rr/xenon-0 ./config_tracing/delve/cmd/dlv/dlv_config_client/xenon_trace/$trace_id

# dlv replay --headless --api-version=2 --accept-multiclient --listen=:4040 ./config_tracing/delve/cmd/dlv/dlv_config_client/xenon_trace/$trace_id

# LEFT OFF:
# This works, but trace is so long with manual pkill -- crash xenon when it gets to the msg send for now?
# Also need to fix the fact that sourceLine() uses local go (which is newer version than xenon's)
