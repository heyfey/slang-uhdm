#!/usr/bin/env bash
# r11u59 grid runner — the r11u58 runner over THIS directory's arms.
# usage: run59.sh <binary> <tag> [arms...]
set -u
H=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GRID=${GRID:-$H/grid} bash $H/../r11u58repro/run54.sh "$@"
