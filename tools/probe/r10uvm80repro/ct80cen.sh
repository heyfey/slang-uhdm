#!/usr/bin/env bash
# r10uvm80repro/ct80cen.sh — run the census over a WHOLE verify_golden workdir,
# GOLDEN AND OURS, and JOIN the two per database.
#
#   usage: ct80cen.sh <workdir> <outfile>
#
# For every <mode>/<test>-<hash>/ under the workdir it reads BOTH databases with
# r10uvm80cen (LIST mode) and emits, per test, the two disagreement populations:
#
#   MISS  golden vpiAutomatic=1, ours=0   (the defect this pass predicts moving)
#   OVER  ours   vpiAutomatic=1, golden=0 (an over-fire; MUST stay 0)
#
# GUARDS, each an ops trap this campaign has paid for:
#   * the golden path is read out of the workdir's OWN cmds.txt, so the script
#     cannot silently compare against the wrong golden, and the cache DIRECTORY
#     is turned into .../golden.uhdm.
#   * a missing side prints SKIP-NOFILE and is COUNTED — a driver that reached
#     nothing must never read as perfection.
#   * objects are keyed on (line:col, kind, fullname) and NOT on the file.  The
#     absolute path is out because the two sides run in different working
#     directories; the BASENAME is out because it was TRIED and it broke the
#     instrument: OUR side leaves vpiFile EMPTY on every class-member variable,
#     so a basename key joined NOTHING in SimpleUVM and reported all 970 of
#     golden's automatic variables as defects and all 953 of ours as over-fires.
#     A detector that flags everything is a broken detector; the calibration
#     below is what caught it.
set -u
WD=${1:?workdir}
OUT=${2:?outfile}
CEN=${R10UVM80CEN:-/tmp/r10uvm80cen}
[ -x "$CEN" ] || { echo "FATAL: no census at $CEN"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
: > "$OUT"
miss=0; done_=0
for d in "$WD"/*/*/; do
  [ -d "$d" ] || continue
  mode=$(basename "$(dirname "$d")")
  t=$(basename "$d")
  O=$d/slang.uhdm
  G=""
  [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    echo "SKIP-NOFILE $mode/$t" >> "$OUT"; miss=$((miss+1)); continue
  fi
  R10UVM80_LIST=1 "$CEN" "$G" G > /tmp/r10uvm80_cg.$$ 2>/dev/null
  R10UVM80_LIST=1 "$CEN" "$O" O > /tmp/r10uvm80_co.$$ 2>/dev/null
  python3 - "$mode/$t" /tmp/r10uvm80_cg.$$ /tmp/r10uvm80_co.$$ >> "$OUT" <<'PY'
import os, sys
tag, gf, of = sys.argv[1], sys.argv[2], sys.argv[3]
# PER-SHAPE MULTISET, not a set: 2 346 of SimpleUVM's 9 464 variable objects
# share a (file, line:col, kind, fullname) key with another object (an
# uninstantiated def view and its elaborated clones), so a set-valued join would
# MASK a per-object regression inside a key.  Each key therefore carries a COUNT
# of vpiAutomatic=1 objects and a COUNT of objects, and the disagreement is the
# signed difference of the former.
def rd(p):
    n, a = {}, {}
    for ln in open(p, errors='replace'):
        if not ln.startswith('VAR\t'):
            continue
        f = ln.rstrip('\n').split('\t')
        if len(f) < 8:
            continue
        key = (f[3], f[5], f[7])
        n[key] = n.get(key, 0) + 1
        a[key] = a.get(key, 0) + int(f[4])
    return n, a
gn, ga = rd(gf)
on, oa = rd(of)
miss = over = 0
rows = []
for k in set(list(ga.keys()) + list(oa.keys())):
    d = ga.get(k, 0) - oa.get(k, 0)
    if d > 0:
        miss += d
        rows.append(("MISS", d, k))
    elif d < 0:
        over += -d
        rows.append(("OVER", -d, k))
print("TEST %s gvars=%d ovars=%d gauto=%d oauto=%d MISS=%d OVER=%d"
      % (tag, sum(gn.values()), sum(on.values()), sum(ga.values()),
         sum(oa.values()), miss, over))
for w, d, k in sorted(rows, key=lambda r: (r[0], r[2])):
    print("%s %s x%d %s %s %s" % (w, tag, d, k[0], k[1], k[2]))
PY
  done_=$((done_+1))
done
rm -f /tmp/r10uvm80_cg.$$ /tmp/r10uvm80_co.$$
echo "-- censused=$done_ SKIP-NOFILE=$miss -> $OUT"
grep -c '^MISS ' "$OUT" | sed 's/^/MISS rows: /'
grep -c '^OVER ' "$OUT" | sed 's/^/OVER rows: /'
