#!/usr/bin/env bash
# r10earl92 — the wide boundary's FILE LIST: every .sv / .v at ANY depth under
# a COPY of tools/probe.  MEASUREMENT ONLY; it dispatches nothing.
#   usage: bdlist92.sh <probe-root> > list.txt
set -u
R=${1:?probe root}
find "$R" \( -name '*.sv' -o -name '*.v' \) -type f | sort
