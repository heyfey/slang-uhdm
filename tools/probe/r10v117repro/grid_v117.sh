#!/usr/bin/env bash
# r10v117repro/grid_v117.sh — a THIN wrapper that runs r10uvm117repro's own
# grid117.sh on one of THIS directory's arms, so the verifier's arms and the
# implementer's arms are measured by the SAME instrument.  MEASUREMENT ONLY.
#   grid_v117.sh <arm.sv> <bin A (pristine)> <bin B> <workdir> <cen bin>
set -u
D=$(cd "$(dirname "$0")" && pwd)
exec bash "$D/../r10uvm117repro/grid117.sh" "$@"
