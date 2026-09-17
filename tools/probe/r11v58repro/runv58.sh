#!/usr/bin/env bash
# r11v58 (VERIFIER) grid runner — the r11u58 runner over THIS directory's arms.
# usage: runv58.sh <binary> <tag> [arms...]
set -u
H=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GRID=$H/grid bash $H/../r11u58repro/run54.sh "$@"
