#!/bin/bash
# usage: rp5.sh <probe> <basename> [probe args...]  -> run a probe on a witness
B=$2; P=$1; shift 2
D=/tmp/r10earl9_rep/out_$B
G=$(ls "$D"/sl/slpp_all/*.uhdm 2>/dev/null | head -1)
"/tmp/$P" "$G" "$D/ours.uhdm" "$@"
