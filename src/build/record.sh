#!/bin/sh

# Assumes run from projects

docker kill xenon
set -e
docker build -f wtf_project/xenon/src/build/Dockerfile -t xenon .
docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --name xenon --rm xenon &
sleep 1
docker exec xenon sh -c 'mkdir /outfiles; cat /etc/resolv.conf.xenon > /etc/resolv.conf' # overwrite resolv.conf
