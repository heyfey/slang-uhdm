#!/usr/bin/env bash
# r10earl71 — score ONE arm 3-way, JUDGE-VISIBLE payload only.
# usage: armscore71.sh <dir> [o|oe]
set -u
V=${2:-o}; P=$V; Q=q; [ "$V" = oe ] && Q=qe
python3 "$(dirname "$0")/score71.py" "$1/g.ex" "$1/$P.ex" "$1/$Q.ex" 4 "${3:-8}"
