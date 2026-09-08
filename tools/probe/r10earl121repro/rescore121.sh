#!/usr/bin/env bash
# r10earl121 — THE BOUNDARY RE-SCORE: every arm×view cell `widerun121.sh` reports
# as DIFFERING, re-measured AGAINST GOLDEN, cell by cell, on the field this law
# owns (the tagged_pattern wrapper of an assignment-pattern operand).
#
# MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge, and its
# line count is printed for all three sides of every arm.
#
#   PATCHED_BIN=<bin> PRISTINE_BIN=<bin> CEN=<cen121> \
#     bash rescore121.sh <probe-root> <BOUNDARY.diff> <outdir>
#
# GUARDS (each an ops trap this campaign has paid for):
#   * GOLDEN is built with the HARNESS Surelog, spelled in full — the shell
#     `surelog` alias is a DIFFERENT build (r10earl120 residue R4);
#   * the view is taken from the diff line, and the SAME view is passed to both
#     Surelog (`-elabuhdm`) and us (`--elabuhdm`) — a mismatched pair scores
#     nothing;
#   * EVERY rc is recorded and a missing database is COUNTED, never skipped;
#   * scratch is keyed on the RELATIVE path (several probe dirs share a
#     basename), children get `</dev/null`, and the list is read on fd 3;
#   * a cell whose GOLDEN side fails to build is reported NOGOLD, not "clean".
set -u
ROOT=${1:?probe root}
DIFF=${2:?BOUNDARY.diff}
OUT=${3:?outdir}
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}; CEN=${CEN:?}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$SL" ] || { echo "FATAL: no harness surelog at $SL"; exit 3; }
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
mkdir -p "$OUT"
: > "$OUT/rescore.tsv"; : > "$OUT/rescore.rc"; : > "$OUT/cells.tsv"
n=0; nogold=0
sort -u "$DIFF" > "$OUT/list"
while read -r view rel <&3; do
  n=$((n+1))
  key=$(echo "$view/$rel" | tr '/' '_'); key=${key%.sv}; key=${key%.v}
  case $view in plain) GF=""; OF="";; elab) GF="-elabuhdm"; OF="--elabuhdm";; *) continue;; esac
  d="$OUT/w/$key"; mkdir -p "$d"; cp "$ROOT/$rel" "$d/" 2>/dev/null || { echo "NOSRC $view $rel" >> "$OUT/rescore.rc"; continue; }
  b=$(basename "$rel")
  ( cd "$d" && "$SL" -parse $GF "$b" -d coveruhdm -o g > sl.log 2>&1 </dev/null )
  echo "$? G $view $rel" >> "$OUT/rescore.rc"
  G="$d/g/slpp_all/surelog.uhdm"
  for side in P X; do
    case $side in P) BIN=$PRIS;; X) BIN=$PAT;; esac
    mkdir -p "$d/$side"
    ( cd "$d/$side" && "$BIN" $OF "../$b" -o slang.uhdm > log.txt 2>&1 </dev/null )
    echo "$? $side $view $rel" >> "$OUT/rescore.rc"
  done
  if [ ! -f "$G" ]; then
    printf "NOGOLD\t%s\t%s\n" "$view" "$rel" >> "$OUT/rescore.tsv"
    nogold=$((nogold+1)); continue
  fi
  # the JUDGE, all three sides
  cp=$("$CMP" "$G" "$d/P/slang.uhdm" 2>&1 | wc -l)
  cx=$("$CMP" "$G" "$d/X/slang.uhdm" 2>&1 | wc -l)
  # the CELL score on this law's field
  for tag in G P X; do
    case $tag in G) DB=$G;; P) DB=$d/P/slang.uhdm;; X) DB=$d/X/slang.uhdm;; esac
    [ -f "$DB" ] || continue
    "$CEN" "$DB" 2>/dev/null | awk -F'\t' -v t=$tag -v v="$view" -v r="$rel" \
      '$1=="CELL"{print t"\t"v"\t"r"\t"$2"\t"$3}' >> "$OUT/cells.tsv"
  done
  printf "ARM\t%s\t%s\tcmp_pris=%s\tcmp_patch=%s\n" "$view" "$rel" "$cp" "$cx" >> "$OUT/rescore.tsv"
done 3< "$OUT/list"
echo "RESCORED=$n  NOGOLD=$nogold"
python3 - "$OUT/cells.tsv" "$OUT/rescore.tsv" <<'EOF'
import collections, sys

# TWO PROJECTIONS, scored separately and out loud (score121.py's own split):
#   CELL = the whole payload -- the wrapper AND the value it wraps
#   WRAP = the wrapper only  -- `TP|<tag ts kind>|<tag name>|<tag span>` or `RAW`,
#          the field THIS law owns.  A member whose VALUE another law still gets
#          wrong reads as MOVED-WRONG under CELL when all this law did was put
#          golden's own tag on it; WRAP is what convicts or acquits this law.
def project(payload, mode):
    if mode == 'CELL':
        return payload
    if payload.startswith('RAW|'):
        return 'RAW'
    return '|'.join(payload.split('|')[:4])


# TWO KEYINGS, scored separately too (score121.py's `--slot`).  cen121's key ends
# in the OPERAND's own span, and that span is part of the object this law
# REPLACES: a bare `bit_select` carries the INDEX's span where the
# `tagged_pattern` wrapping it carries the VALUE's span -- golden's own.  Keyed
# positionally, one moved cell reads as TWO (a vacated key and a new one); SLOT
# re-keys on site + operand index and moves the span into the payload, where any
# change in it is still fully visible.
def rekey(key, payload, slot):
    if not slot:
        return key, payload
    parts = key.split('|')
    if len(parts) < 4:
        return key, payload
    return '|'.join(parts[:3]), parts[3] + '#' + payload

raw = []
for line in open(sys.argv[1]):
    f = line.rstrip('\n').split('\t')
    if len(f) < 5: continue
    raw.append(f)

for slot, proj in ((True, 'WRAP'), (True, 'CELL'), (False, 'WRAP'), (False, 'CELL')):
    cells = {}
    for side, view, rel, key, payload in raw:
        k, pay = rekey(key, project(payload, proj), slot)
        cells.setdefault((view, rel), {}).setdefault(side, {}) \
             .setdefault(k, collections.Counter())[pay] += 1
    tot = collections.Counter()
    per = []
    for (view, rel), d in sorted(cells.items()):
        g, p, x = d.get('G', {}), d.get('P', {}), d.get('X', {})
        c = collections.Counter()
        for k in set(g) | set(p) | set(x):
            gv, pv, xv = g.get(k), p.get(k), x.get(k)
            if gv is None:                  v = 'NOGOLD_SAME' if pv == xv else 'NOGOLD_MOVED'
            elif pv is None and xv is None: v = 'GOLD_ONLY'
            elif pv == gv and xv == gv:     v = 'SAME_AGREE'
            elif pv != gv and xv == gv:     v = 'TO-GOLDEN'
            elif pv == gv and xv != gv:     v = 'AWAY-GOLDEN'
            elif pv == xv:                  v = 'STILL-WRONG'
            else:                           v = 'MOVED-WRONG'
            c[v] += 1; tot[v] += 1
        per.append((view, rel, c))
    print()
    print('=========== KEYING %-10s x PROJECTION %-4s ===========' %
          ('SLOT' if slot else 'POSITIONAL', proj))
    print('%-6s %-46s %s' % ('VIEW', 'ARM', 'CELL SCORE vs GOLDEN'))
    for view, rel, c in per:
        interesting = {k: n for k, n in c.items() if k not in ('SAME_AGREE', 'GOLD_ONLY')}
        print('%-6s %-46s %s' % (view, rel, interesting if interesting else '(all SAME_AGREE)'))
    print()
    for v in ('SAME_AGREE','TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG','STILL-WRONG','NOGOLD_SAME','NOGOLD_MOVED','GOLD_ONLY'):
        print('%-14s %d cells' % (v, tot[v]))
    bad = tot['AWAY-GOLDEN'] + tot['MOVED-WRONG'] + tot['NOGOLD_MOVED']
    print()
    print('BOUNDARY VERDICT (%s x %s) %s  (AWAY-GOLDEN %d + MOVED-WRONG %d + NOGOLD_MOVED %d)'
          % ('SLOT' if slot else 'POSITIONAL', proj,
             'CLEAN' if bad == 0 else 'DIRTY', tot['AWAY-GOLDEN'],
             tot['MOVED-WRONG'], tot['NOGOLD_MOVED']))

print()
print('OFFICIAL uhdm-cmp LINE COUNT per differing arm (pristine -> patched):')
for line in open(sys.argv[2]):
    f = line.rstrip('\n').split('\t')
    if f[0] != 'ARM': continue
    p = int(f[3].split('=')[1]); x = int(f[4].split('=')[1])
    print('  %-6s %-46s %6d -> %6d %s' % (f[1], f[2], p, x,
          '' if p == x else ('BETTER' if x < p else 'HEAD MOVED (depth, not distance)')))
EOF
