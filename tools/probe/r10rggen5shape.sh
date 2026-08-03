#!/bin/bash
# r10rggen5shape: run a probe binary over the Rggen golden/ours pair, capture
# to /tmp/r10rggen5_probe.txt and print a head.
# usage: r10rggen5shape.sh <probe-binary> [extra args...]
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen5_slang.path)
P=$1; shift
timeout 1800 "$P" "$G" "$S" "$@" > /tmp/r10rggen5_probe.txt 2>&1
echo "rc=$? lines=$(wc -l < /tmp/r10rggen5_probe.txt)"
head -80 /tmp/r10rggen5_probe.txt
