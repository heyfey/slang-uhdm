#!/usr/bin/env bash
# v11u64 verifier grid runner.  usage: rungrid.sh <file.sv> <tag>
set -u
SV=$1; TAG=$2
ROOT=/tmp/v11u64_scratch/grid/$TAG
rm -rf "$ROOT"; mkdir -p "$ROOT/sl"
cp "$SV" "$ROOT/dut.sv"
cd "$ROOT" || exit 1
SL=~/git-repos/Surelog/build/bin/surelog
DUMP=~/git-repos/UHDM/build/bin/uhdm-dump
$SL -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$ROOT/sl" > sl.log 2>&1
echo "surelog rc=$?  ERR=$(grep -c '\[ERR' sl.log; true)"
G=$(ls "$ROOT"/sl/slpp_all/*.uhdm "$ROOT"/sl/slpp_unit/*.uhdm 2>/dev/null | head -1)
echo "golden=$G"
for b in pris law; do
  for m in default testflags; do
    FL="--single-unit"
    [ "$m" = testflags ] && FL="--single-unit --nobuiltin"
    /tmp/v11u64_bin/$b dut.sv $FL -o "$ROOT/$b.$m.uhdm" > "$ROOT/$b.$m.log" 2>&1
    echo "$b/$m rc=$?"
  done
done
$DUMP "$G" > "$ROOT/golden.dump" 2>/dev/null
python3 /tmp/v11u64_scratch/vlist64.py "$ROOT/golden.dump" > "$ROOT/golden.shape"
# calibration: golden against its own second restore
$DUMP "$G" > "$ROOT/golden2.dump" 2>/dev/null
python3 /tmp/v11u64_scratch/vlist64.py "$ROOT/golden2.dump" > "$ROOT/golden2.shape"
echo "CALIB golden-vs-golden diff lines = $(diff "$ROOT/golden.shape" "$ROOT/golden2.shape" | grep -c '^[<>]'; true)"
for b in pris law; do
  for m in default testflags; do
    $DUMP "$ROOT/$b.$m.uhdm" > "$ROOT/$b.$m.dump" 2>/dev/null
    python3 /tmp/v11u64_scratch/vlist64.py "$ROOT/$b.$m.dump" > "$ROOT/$b.$m.shape"
    echo "$b/$m rows=$(wc -l < "$ROOT/$b.$m.shape") vs-golden-difflines=$(diff "$ROOT/golden.shape" "$ROOT/$b.$m.shape" | grep -c '^[<>]'; true)"
  done
done
