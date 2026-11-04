#!/bin/bash
# grid.sh <tag> [VAR=val...]: runcase.sh on every case dir of this repro (cases/<GROUP>/<case>,
# explicit directories only) under the frozen binary /tmp/r11u480_bin/slang-uhdm.<tag>.
D=$(cd "$(dirname "$0")" && pwd)
T=$1; shift
dirs=$(find "$D/../cases" -mindepth 2 -maxdepth 2 -type d | sort)
env "$@" "$D/runcase.sh" /tmp/r11u480_bin/slang-uhdm.$T $T $dirs
