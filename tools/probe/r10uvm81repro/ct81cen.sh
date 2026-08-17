#!/usr/bin/env bash
# r10uvm81repro/ct81cen.sh — run the r10uvm81 census over a WHOLE verify_golden
# workdir, GOLDEN AND OURS, and JOIN the two per database.
#
#   usage: ct81cen.sh <workdir> <outfile>
#
# For every <mode>/<test>-<hash>/ under the workdir it reads BOTH databases with
# r10uvm81cen (LIST mode) and emits, per test, the two disagreement populations
# of § pkgSubRefBindsPkgVarOverFormal81:
#
#   FMISS  golden binds a `variables`, ours binds an `io_decl`  <- the defect
#   FOVER  ours binds a `variables`,  golden binds an `io_decl` <- an over-fire
#
# and, so that nothing hides behind those two, a third:
#   XDIFF  the two sides disagree on the actual in ANY OTHER way
#
# GUARDS, each an ops trap this campaign has paid for:
#   * the golden path is read out of the workdir's OWN cmds.txt, so the script
#     cannot silently compare against the wrong golden, and the cache DIRECTORY
#     is turned into .../golden.uhdm (handing a directory to the census reads
#     nothing).
#   * a missing side prints SKIP-NOFILE and is COUNTED — a driver that reached
#     nothing must never read as perfection.
#   * references are keyed on (ref line:col, ref fullname) and NOT on the file:
#     OUR side leaves vpiFile EMPTY on every class-member object, so a
#     file-bearing key joins NOTHING (r10uvm80 paid for that one).
#   * the join is a MULTISET per key with a per-ACTUAL-KIND histogram, so a
#     per-object regression inside a shared key cannot be masked.
set -u
WD=${1:?workdir}
OUT=${2:?outfile}
CEN=${R10UVM81CEN:-/tmp/r10uvm81cen}
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
  R10UVM81_LIST=1 "$CEN" "$G" G > /tmp/r10uvm81_cg.$$ 2>/dev/null
  R10UVM81_LIST=1 "$CEN" "$O" O > /tmp/r10uvm81_co.$$ 2>/dev/null
  python3 - "$mode/$t" /tmp/r10uvm81_cg.$$ /tmp/r10uvm81_co.$$ >> "$OUT" <<'PY'
import sys
tag, gf, of = sys.argv[1], sys.argv[2], sys.argv[3]
# BIND <tag> <line:col> <refkind> <actualkind> <actual line:col> <reffull> <actfull>
#  0     1        2         3           4             5              6        7
def rd(p):
    per = {}
    for ln in open(p, errors='replace'):
        if not ln.startswith('BIND\t'):
            continue
        f = ln.rstrip('\n').split('\t')
        if len(f) < 8:
            continue
        key = (f[2], f[6])                       # (ref line:col, ref fullname)
        per.setdefault(key, {})
        act = (f[4], f[5], f[7])                 # (actual kind, span, fullname)
        per[key][act] = per[key].get(act, 0) + 1
    return per
g, o = rd(gf), rd(of)
fmiss = fover = xdiff = 0
rows = []
for k in set(list(g.keys()) + list(o.keys())):
    gv, ov = g.get(k, {}), o.get(k, {})
    if gv == ov:
        continue
    # the SIGNED per-actual multiset difference
    gonly = {a: c - ov.get(a, 0) for a, c in gv.items() if c > ov.get(a, 0)}
    oonly = {a: c - gv.get(a, 0) for a, c in ov.items() if c > gv.get(a, 0)}
    gkinds = set(a[0] for a in gonly)
    okinds = set(a[0] for a in oonly)
    n = sum(gonly.values())
    if okinds == {'io_decl'} and gkinds and 'io_decl' not in gkinds:
        fmiss += n
        rows.append(("FMISS", n, k, sorted(gonly), sorted(oonly)))
    elif gkinds == {'io_decl'} and okinds and 'io_decl' not in okinds:
        fover += sum(oonly.values())
        rows.append(("FOVER", sum(oonly.values()), k, sorted(gonly), sorted(oonly)))
    else:
        xdiff += max(n, sum(oonly.values()))
        rows.append(("XDIFF", max(n, sum(oonly.values())), k, sorted(gonly), sorted(oonly)))
print("TEST %s grefs=%d orefs=%d FMISS=%d FOVER=%d XDIFF=%d"
      % (tag, sum(sum(v.values()) for v in g.values()),
         sum(sum(v.values()) for v in o.values()), fmiss, fover, xdiff))
for w, n, k, ga, oa in sorted(rows, key=lambda r: (r[0], r[2])):
    print("%s %s x%d %s %s  G=%s  O=%s" % (w, tag, n, k[0], k[1], ga, oa))
PY
  done_=$((done_+1))
done
rm -f /tmp/r10uvm81_cg.$$ /tmp/r10uvm81_co.$$
echo "-- censused=$done_ SKIP-NOFILE=$miss -> $OUT"
grep -c '^FMISS ' "$OUT" | sed 's/^/FMISS rows: /'
grep -c '^FOVER ' "$OUT" | sed 's/^/FOVER rows: /'
grep -c '^XDIFF ' "$OUT" | sed 's/^/XDIFF rows: /'
