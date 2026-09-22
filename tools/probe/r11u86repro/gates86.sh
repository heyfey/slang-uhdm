#!/usr/bin/env bash
# r11u86 GATE DRIVER — one binary, one FOUR-CHARACTER tag, its own workdir.
#
# THE TAG AND THE WORKDIR PATH MUST BE THE SAME LENGTH FOR EVERY BINARY
# (r11u81's RV-7: the serializer embeds the output path in the database, so a
# byteverify across differently-named workdirs is meaningless).  This pass used
# `pris` and `lawx`.
#
# usage:  WD=<dir> gates86.sh <tag> <binary>
set -u
TAG=${1:?tag}; BIN=${2:?binary}
W=${WD:-/tmp/r11u86_wd}
R=$(cd "$(dirname "$0")/../../.." && pwd)
mkdir -p "$W/$TAG/sl" "$W/$TAG/u2r"
export SLANG_UHDM=$BIN
md5sum "$BIN"
echo "GOLDENS PASS=$(bash "$R/tests/check_goldens.sh" | grep -c '^PASS'; true)" \
     "FAIL=$(bash "$R/tests/check_goldens.sh" | grep -c '^FAIL'; true)"
( cd "$R" && python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
    --jobs 3 --out "$W/${TAG}_u2r_tf.csv"  --workdir "$W/$TAG/u2r" )
( cd "$R" && python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default \
    --jobs 3 --out "$W/${TAG}_u2r_def.csv" --workdir "$W/$TAG/u2r" )
( cd "$R" && python3 scripts/verify_golden.py --corpus surelog --mode both \
    --jobs 3 --out "$W/${TAG}_sl.csv"      --workdir "$W/$TAG/sl" )
# EVERY cmds.txt audited by ABSOLUTE binary path — never by the string
# "slang-uhdm", which also matches the golden cache directory.
echo "CMDS total=$(find "$W/$TAG" -name cmds.txt | wc -l)" \
     "own=$(grep -l "$BIN" $(find "$W/$TAG" -name cmds.txt) 2>/dev/null | wc -l)" \
     "MAINTREE=$(grep -l "$R/build/slang-uhdm" $(find "$W/$TAG" -name cmds.txt) 2>/dev/null | wc -l)"
