#!/usr/bin/env bash
# Don't set -e, so that we still save trace if client exits with error

# Replay and run client in container that just recorded trace

# Assumes run from projects

# Run client
docker exec xenon sh -c 'dlv_config_client -initial_bp_file=/usr/local/go/src/net/dnsconfig_unix.go -initial_bp_line=144 -initial_watchexpr=conf.search \
    > /outfiles/client_out.txt 2> /outfiles/client_err.txt'

# Save trace for later replay, and outfiles for convenience
trace_id=$RANDOM # only works if run as `bash <.sh>` -- hence this file is not executable
echo Saving trace as $trace_id
docker exec xenon sh -c 'cd /root/.local/share/rr/xenon-0; rr pack'
docker container cp xenon:/root/.local/share/rr/xenon-0 ./config_tracing/delve/cmd/dlv/dlv_config_client/xenon_trace/$trace_id
docker container cp xenon:/outfiles/ ./config_tracing/delve/cmd/dlv/dlv_config_client/xenon_trace/$trace_id
