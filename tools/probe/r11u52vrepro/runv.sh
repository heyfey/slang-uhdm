#!/usr/bin/env bash
# r11u52v — verifier arm driver.  Runs the ELEVEN adversarial arms in this
# directory's grid/ against a chosen binary, reusing the pass's own harness
# (run52.sh / cell52.py / score52.sh in ../r11u52repro), so the instrument is
# the one the pass shipped and only the DESIGNS are new.
#
#   usage:  runv.sh <binary> <tag> [arms...]
#   then:   GRID=<this>/grid BASE=base LAW=law bash ../r11u52repro/score52.sh
#
# Nothing here writes outside this directory's grid/.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PASS=${PASS:-$HERE/../r11u52repro}
export GRID=${GRID:-$HERE/grid}
exec bash "$PASS/run52.sh" "$@"
