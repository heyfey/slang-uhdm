#!/bin/bash
# attrib.sh <law binary> <out dir> <switch>...: the rows a law moves, attributed: the law binary re-run on the named
# corpus rows (verify_golden.py --filter; the fixed test list is checked against $FENCED, fail closed) once per switch
# state (each switch alone), printing the strict cell per row-mode and state beside the all-on state.
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "attrib.sh: source drivers/env.sh" >&2; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
BIN=$1; O=$2; shift 2; T=${ATTRIB_TESTS:-"BuildUVMPkg Earlgrey_0_1 MiniAmiq Rggen Scoreboard SeqDriver SimpleUVM"}
for t in $T; do for f in $FENCED; do [ "$f" = "$t" ] && { echo "attrib.sh: fenced"; exit 2; }; done; done
FIL="^($(echo $T | tr ' ' '|'))$"; mkdir -p $O; cd $REPO
for sw in ALLON "$@"; do
  rm -rf $O/wd_$sw
  if [ $sw = ALLON ]; then env SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$FIL" --out $O/$sw.csv --workdir $O/wd_$sw > /dev/null 2>&1
  else env $sw=1 SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$FIL" --out $O/$sw.csv --workdir $O/wd_$sw > /dev/null 2>&1; fi
  rm -rf $O/wd_$sw
done
python3 - "$O" ALLON "$@" <<'PY'
import csv, sys, os
O = sys.argv[1]; states = sys.argv[2:]
cells = {s: {(r['name'], r['mode']): r['strict'] or r['status'] for r in csv.DictReader(open(os.path.join(O, s + '.csv')))} for s in states}
keys = sorted(cells['ALLON'])
print('row-mode\t' + '\t'.join(states))
for k in keys: print(f'{k[0]}/{k[1]}\t' + '\t'.join(cells[s].get(k, '-') for s in states))
PY
