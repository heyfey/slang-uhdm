#!/usr/bin/env bash
# r11v53 grid runner — golden + a chosen binary per arm, rc recorded for BOTH.
# It is r11u53repro/run53.sh pointed at THIS grid; kept as a one-liner so the
# verifier's arms are reproducible without knowing the other dir's env names.
#   usage: run.sh <binary> <tag> [arms...]
set -u
R=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GRID=$R/grid exec bash "$R/../r11u53repro/run53.sh" "$@"
