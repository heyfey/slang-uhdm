#!/usr/bin/env bash
# r10uvm81repro/mv81.sh — ATTRIBUTE EVERY BYTE MOVER, per NAME and per BINDING.
#
#   usage: mv81.sh <before-workdir> <after-workdir> <mode/test-hash> [...]
#
# For each named database it prints
#   * the fullname MULTISET distance to GOLDEN before and after, the count of
#     names the AFTER side produces that GOLDEN LACKS (must be 0) and the count
#     of GOLDEN names it newly produces — the r10uvm79-V-F2 judge, because a
#     per-shape aggregate can hide a field-level regression inside a
#     net-improving line;
#   * every reference whose vpiActual CHANGED, named, with the golden verdict on
#     each — so a byte mover is never reported as a size or a distance alone.
#
# The golden path comes out of the AFTER workdir's own cmds.txt.  A missing side
# prints SKIP-NOFILE and is COUNTED.
set -u
A=${1:?before workdir}
B=${2:?after workdir}
shift 2
CEN=${R10UVM81CEN:-/tmp/r10uvm81cen}
HERE=$(cd "$(dirname "$0")" && pwd)
[ -x "$CEN" ] || { echo "FATAL: no census at $CEN"; exit 3; }
T=$(mktemp -d)
for t in "$@"; do
  ad=$A/$t; bd=$B/$t
  G=""
  [ -f "$bd/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$bd/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$ad/slang.uhdm" ] || [ ! -f "$bd/slang.uhdm" ]; then
    echo "SKIP-NOFILE $t"; continue
  fi
  R10UVM81_NAMES=1 "$CEN" "$G"            g > "$T/g.n" 2>/dev/null
  R10UVM81_NAMES=1 "$CEN" "$ad/slang.uhdm" a > "$T/a.n" 2>/dev/null
  R10UVM81_NAMES=1 "$CEN" "$bd/slang.uhdm" b > "$T/b.n" 2>/dev/null
  python3 "$HERE/namecmp80.py" "$T/g.n" "$T/a.n" "$T/b.n" "$t"
  R10UVM81_LIST=1 "$CEN" "$G"             g > "$T/g.b" 2>/dev/null
  R10UVM81_LIST=1 "$CEN" "$ad/slang.uhdm" a > "$T/a.b" 2>/dev/null
  R10UVM81_LIST=1 "$CEN" "$bd/slang.uhdm" b > "$T/b.b" 2>/dev/null
  python3 - "$t" "$T/g.b" "$T/a.b" "$T/b.b" <<'PY'
import sys
tag, gf, af, bf = sys.argv[1:5]
def rd(p):
    d = {}
    for ln in open(p, errors='replace'):
        if not ln.startswith('BIND\t'):
            continue
        f = ln.rstrip('\n').split('\t')
        d.setdefault((f[2], f[6]), {})
        k = (f[4], f[5])
        d[(f[2], f[6])][k] = d[(f[2], f[6])].get(k, 0) + 1
    return d
g, a, b = rd(gf), rd(af), rd(bf)
moved = [k for k in set(list(a.keys()) + list(b.keys())) if a.get(k) != b.get(k)]
print("   BINDINGS CHANGED: %d" % len(moved))
for k in sorted(moved):
    gv = sorted(g.get(k, {}).items())
    av = sorted(a.get(k, {}).items())
    bv = sorted(b.get(k, {}).items())
    verdict = "-> GOLDEN" if bv == gv else ("still != golden" if gv else "no golden twin")
    print("     %s %s\n        G=%s\n        BEFORE=%s\n        AFTER =%s   %s"
          % (k[0], k[1], gv, av, bv, verdict))
PY
done
rm -rf "$T"
