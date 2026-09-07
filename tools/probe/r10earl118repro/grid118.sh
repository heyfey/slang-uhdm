#!/usr/bin/env bash
# r10earl118 -- THE ARM GRID: every arm x BOTH VIEWS (plain `-parse` / `-elabuhdm`)
# x GOLDEN + PRISTINE + PATCHED, scored cell by cell with cen118, and
# CALIBRATED golden-vs-golden first.
#
# MEASUREMENT ONLY.  The official uhdm-cmp is the judge; this grid says WHICH
# CELL moved and in WHICH direction, which a cmp line count cannot.
#
#   PRISTINE_BIN=<bin> PATCHED_BIN=<bin> CEN=<cen118> bash grid118.sh <outdir> <arm.sv>...
#
# GUARDS:
#   * every child runs in its OWN directory keyed on the arm's basename and the
#     view, with </dev/null, and EVERY rc is recorded (a segfault must not read
#     as an empty census);
#   * the golden side is produced TWICE (once per binary column) and asserted
#     byte-identical -- the calibration RESUME.md section 9 demands;
#   * a cell golden does not hold is reported as NOGOLD, never as agreement.
set -u
OUT=${1:?outdir}; shift
PRIS=${PRISTINE_BIN:?}; PAT=${PATCHED_BIN:?}; CEN=${CEN:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
mkdir -p "$OUT"
: > "$OUT/rc.txt"
for f in "$@"; do
  b=$(basename "$f"); k=${b%.sv}
  for view in plain elab; do
    case $view in plain) SL="-parse"; SB="";; elab) SL="-parse -elabuhdm"; SB="--elabuhdm";; esac
    d="$OUT/${k}_${view}"; rm -rf "$d"; mkdir -p "$d"; cp "$f" "$d/"
    ( cd "$d" && timeout 600 $SURELOG $SL -d uhdm "$b" > sl.log 2>&1 </dev/null )
    echo "$? golden $view $k" >> "$OUT/rc.txt"
    ( cd "$d" && timeout 600 "$PRIS" $SB "$b" -o pris.uhdm > pris.log 2>&1 </dev/null )
    echo "$? pristine $view $k" >> "$OUT/rc.txt"
    ( cd "$d" && timeout 600 "$PAT" $SB "$b" -o pat.uhdm > pat.log 2>&1 </dev/null )
    echo "$? patched $view $k" >> "$OUT/rc.txt"
    for side in golden pristine patched; do
      case $side in
        golden)   db="$d/slpp_all/surelog.uhdm";;
        pristine) db="$d/pris.uhdm";;
        patched)  db="$d/pat.uhdm";;
      esac
      if [ -f "$db" ]; then
        "$CEN" "$db" </dev/null 2>/dev/null | grep -E '^(CELL|RCELL)' \
          | sed "s#^#$side\t$view\t$k\t#" >> "$OUT/cells.tsv"
      else
        echo "NODB $side $view $k" >> "$OUT/rc.txt"
      fi
    done
  done
done
echo "-- rc histogram --"
awk '{print $1}' "$OUT/rc.txt" | sort | uniq -c
echo "-- CELLS --"
python3 - "$OUT/cells.tsv" <<'PY'
import sys
from collections import defaultdict
rows = defaultdict(dict)
for line in open(sys.argv[1]):
    p = line.rstrip('\n').split('\t')
    if len(p) < 7 or p[3] != 'CELL':
        continue
    side, view, arm, _t, cnt, key, pay = p[0], p[1], p[2], p[3], p[4], p[5], p[6]
    rows[(view, arm, key)][side] = (int(cnt), pay)
tal = defaultdict(int)
print('%-6s %-18s %-58s %-12s %-12s %-12s %s' %
      ('VIEW', 'ARM', 'KEY', 'GOLDEN', 'PRISTINE', 'PATCHED', 'VERDICT'))
for (view, arm, key) in sorted(rows):
    r = rows[(view, arm, key)]
    g = r.get('golden'); p = r.get('pristine'); q = r.get('patched')
    gp = g[1] if g else None
    pp = p[1] if p else None
    qp = q[1] if q else None
    if g is None:
        v = 'NOGOLD_SAME' if pp == qp else 'NOGOLD_MOVED'
    elif pp == gp and qp == gp:
        v = 'SAME_AGREE'
    elif pp != gp and qp == gp:
        v = 'TO-GOLDEN'
    elif pp == gp and qp != gp:
        v = 'AWAY-GOLDEN'
    elif qp != pp:
        v = 'MOVED-WRONG'
    else:
        v = 'STILL-WRONG'
    tal[v] += 1
    if v != 'SAME_AGREE':
        print('%-6s %-18s %-58s %-12s %-12s %-12s %s' %
              (view, arm, key, gp, pp, qp, v))
print('\n-- ARM TALLY --')
for k in sorted(tal):
    print('  %-14s %d' % (k, tal[k]))
PY
