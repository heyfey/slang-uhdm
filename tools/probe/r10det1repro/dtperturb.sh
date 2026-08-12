#!/bin/bash
# r10det1repro/dtperturb.sh — THE DECISIVE EXPERIMENT, and the reason this pass
# has an answer at all.
#
# The question is "does ALLOCATION ORDER reach the emitted database?".  Every
# earlier attempt at it compared two BINARIES, which confounds allocation with
# semantics and with codegen.  This runs ONE binary -- the r10det1 INSTRUMENTED
# build, whose pad and order dump are both ENV-GUARDED -- under several heap
# layouts.  Identical bytes in, identical code path, only the arena moved.  So:
#   * if the database MOVES  -> address sensitivity is proven OUTRIGHT.
#   * if the database is BYTE-IDENTICAL under a pad that DEMONSTRABLY moved every
#     address (the ADDRPROOF line), address sensitivity is REFUTED, and it is
#     refuted with the confound removed rather than argued away.
#
#   usage: dtperturb.sh <instrumented-binary> <outdir> [test] [pad ...]
#          pads are R10DET1_PAD values, `<count>[:<bytes>]`; `none` = unset.
#
# GUARDS, each a trap this campaign has paid for:
#   * THE ADDRPROOF LINE IS MANDATORY.  "The pad changed nothing" is unfalsifiable
#     unless the pad is shown to have moved addresses; this prints lo/hi/design
#     pointers per arm and FAILS LOUD (`PAD-INERT`) on any arm whose addresses
#     match the no-pad arm.  A single >=128 KiB block is served by mmap and moves
#     NOTHING -- that inert arm is why the pad is a COUNT of small blocks.
#   * the ORDER comparison prints SOURCE IDENTITIES ONLY (kind/name/file:line:col)
#     -- addresses are excluded from it by construction, so a diff of two order
#     files cannot be a trivial address diff.
#   * a missing database is NO_OUTPUT, never a verdict.
#   * --jobs 1: no parallel-parse term.
#   * Scoreboard is KNOWN NONDETERMINISTIC on every binary (r10oth9 F2); it is
#     not the default test here and any Scoreboard result must be repped.
set -u
BIN=${1:?instrumented slang binary}
OUT=${2:?outdir}
T=${3:-BuildUVMPkg}
shift 3 2>/dev/null || shift $#
PADS=${*:-"none 1:48 1000:48 100000:48 7:97"}
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../../.." && pwd)
POP=${DTPOP:-/tmp/r10det1_dtpop}
[ -x "$BIN" ] || { echo "FATAL: not executable: $BIN"; exit 3; }
[ -x "$POP" ] || { echo "FATAL: no dtpop at $POP"; exit 3; }
mkdir -p "$OUT" || exit 1
echo "BINARY=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)   TEST=$T"
echo
base_addr=""
for P in $PADS; do
  tag=$(echo "$P" | tr ':' '_')
  WD=$OUT/wd_$tag; ORD=$OUT/order_$tag.txt
  rm -rf "$WD" "$ORD"
  if [ "$P" = none ]; then unset R10DET1_PAD; else export R10DET1_PAD="$P"; fi
  export R10DET1_ORDER="$ORD"
  SLANG_UHDM="$BIN" python3 "$ROOT/scripts/verify_golden.py" --corpus surelog \
     --mode default --filter "^$T\$" --jobs 1 \
     --out "$WD.csv" --workdir "$WD" >"$OUT/vg_$tag.log" 2>&1
  unset R10DET1_ORDER
  D=$(echo "$WD"/default/"$T"-*/ | cut -d' ' -f1)
  O=$D/slang.uhdm
  if [ ! -f "$O" ]; then echo "pad=$P  NO_OUTPUT"; continue; fi
  cp "$O" "$OUT/db_$tag.uhdm"
  m=$(md5sum "$O" | cut -d' ' -f1)
  st=$("$POP" "$O" 2>&1 >/dev/null)
  al=$(echo "$st" | awk '$1=="ALIAS"{print $2}')
  ct=$(echo "$st" | awk '$1=="CTS"{print $2}')
  to=$(echo "$st" | awk '$1=="TOTAL"{print $2}')
  ap=$(grep -m1 'ADDRPROOF' "$ORD" 2>/dev/null | cut -f3-)
  [ -n "$ap" ] || ap="ADDRPROOF-MISSING(instrument not linked?)"
  verdict=""
  if [ -z "$base_addr" ]; then base_addr="$ap"
  elif [ "$ap" = "$base_addr" ]; then verdict="  <<< PAD-INERT: addresses did NOT move, this arm proves nothing"
  fi
  printf 'pad=%-12s db_md5=%s  ALIAS=%s CTS=%s TOTAL=%s\n' "$P" "$m" "$al" "$ct" "$to"
  printf '   %s%s\n' "$ap" "$verdict"
  # order file, source identities only, per tag
  grep -P '^PRE-LAWS\tALLOBJ' "$ORD" 2>/dev/null | cut -f4- > "$OUT/ord_allobj_$tag.txt"
  grep -P '^PRE-LAWS\tTYPEDEFTS' "$ORD" 2>/dev/null | cut -f4- > "$OUT/ord_tdts_$tag.txt"
  grep -P '^PRE-LAWS\tPKGTOPTS' "$ORD" 2>/dev/null | cut -f4- > "$OUT/ord_pkgtop_$tag.txt"
  rm -rf "$WD" "$WD.csv"
done
echo
echo "=== ORDER DIFFS vs the first arm (source identities only, no addresses) ==="
first=""
for P in $PADS; do
  tag=$(echo "$P" | tr ':' '_')
  for k in allobj tdts pkgtop; do
    f=$OUT/ord_${k}_$tag.txt
    [ -s "$f" ] || { echo "$k pad=$P: EMPTY (no instrument output)"; continue; }
    if [ -z "${first:-}" ] || [ ! -f "$OUT/ord_${k}_BASE.txt" ]; then
      cp "$f" "$OUT/ord_${k}_BASE.txt"; echo "$k pad=$P: BASE ($(wc -l <"$f") entries)"
    else
      n=$(diff "$OUT/ord_${k}_BASE.txt" "$f" | grep -c '^[<>]')
      echo "$k pad=$P: $n differing order lines vs BASE ($(wc -l <"$f") entries)"
    fi
  done
  first=set
done
