#!/bin/bash
# grid.sh <tag> [env...]: runcase.sh on every case dir of this repro under the binary
# /tmp/r11u478_bin/slang-uhdm.<tag>, explicit directories only (cases/<GROUP>/<case>)
D=$(cd "$(dirname "$0")" && pwd)
T=$1; shift
dirs=$(find "$D/../cases" -mindepth 2 -maxdepth 2 -type d | sort)
env "$@" ENVFILE=${ENVFILE:-/tmp/r11u478_env.sh} "$D/runcase.sh" /tmp/r11u478_bin/slang-uhdm.$T $T $dirs
