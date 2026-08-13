#!/usr/bin/env bash
# r10svs14 THE GRID, CELL FOR CELL, BOTH BINARIES IN ONE TABLE.
#
#   usage: ./grid14.sh <arm-tag>          # e.g. b1, reading
#                                         #   /tmp/r10svs14_arm_{pris,ship}_<tag>
#
# A CELL is one (interface view, Variables() list) pair: the view is keyed by
# DEFNAME + FULLNAME + VIEW (HOME vs the col-0 DUP), and the value is the ORDERED
# list of `vpiVariables` entries with their UHDM kinds.  Both columns are read by
# dupread.py from dumps ALREADY ON DISK, so the table can be re-read without
# re-running either tool.
#
# The verdict column is the pair (PRIS vs GOLDEN, SHIP vs GOLDEN):
#   EQ->EQ     held           DIF->EQ    CONVERGED
#   EQ->DIF    REGRESSED      DIF->DIF   still DIF (the CONTENT may still have
#                                        changed -- printed when it did)
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${1:?arm tag, e.g. b1}
P=/tmp/r10svs14_arm_pris_$TAG
S=/tmp/r10svs14_arm_ship_$TAG
for d in "$P" "$S"; do
    [ -s "$d/g.dump" ] && [ -s "$d/o.dump" ] || { echo "MISSING DUMPS in $d"; exit 6; }
done
# The GOLDEN column must be IDENTICAL in both runs -- if it is not, the two
# columns were produced against different goldens and the table is meaningless.
# THE ARM SCRATCH DIRECTORY IS PART OF EVERY `file:` FIELD (each binary gets its
# own dir so the two columns survive on disk), so the two golden dumps differ by
# that path and NOTHING else; the assertion is made on the PATH-NORMALISED text.
if ! diff -q <(sed "s#$P#WD#g" "$P/g.dump") <(sed "s#$S#WD#g" "$S/g.dump") >/dev/null; then
    echo "GOLDEN DUMPS DIFFER BETWEEN THE TWO ARM RUNS (beyond the scratch path)"
    echo "  -- table refused; the two columns are not against the same golden"
    diff <(sed "s#$P#WD#g" "$P/g.dump") <(sed "s#$S#WD#g" "$S/g.dump") | head -10
    exit 4
fi
python3 - "$HERE" "$P" "$S" <<'PY'
import re, subprocess, sys
here, p, s = sys.argv[1], sys.argv[2], sys.argv[3]

def read(d):
    out = subprocess.run(['python3', here + '/dupread.py', d + '/g.dump',
                          d + '/o.dump', '--all'],
                         capture_output=True, text=True).stdout
    cells, key = {}, None
    for ln in out.split('\n'):
        m = re.match(r'^OBJ (\S+)\s+(\S+)\s+(\S+)\s+(EQ|DIF)$', ln)
        if m:
            key = (m.group(2), m.group(3), m.group(1))
            cells[key] = {'v': m.group(4)}
            continue
        m = re.match(r'^    (GOLDEN|OURS)\s+vars \S+: (.*)$', ln)
        if m and key:
            cells[key][m.group(1)] = m.group(2)
    return cells

P, S = read(p), read(s)
keys = sorted(set(P) | set(S), key=lambda k: (k[1], k[2]))
n = {'held': 0, 'CONVERGED': 0, 'REGRESSED': 0, 'stillDIF': 0}
print('%-6s %-22s %-26s %-9s %s' % ('view', 'defname', 'fullname', 'PRIS->SHIP',
                                    'verdict'))
for k in keys:
    a, b = P.get(k), S.get(k)
    av = a['v'] if a else '-'
    bv = b['v'] if b else '-'
    if av == 'EQ' and bv == 'EQ':
        verd = 'held'
    elif av == 'DIF' and bv == 'EQ':
        verd = 'CONVERGED'
    elif av == 'EQ' and bv == 'DIF':
        verd = 'REGRESSED'
    else:
        verd = 'stillDIF'
        if a and b and a.get('OURS') != b.get('OURS'):
            verd = 'stillDIF (content CHANGED)'
    n[verd.split(' ')[0]] = n.get(verd.split(' ')[0], 0) + 1
    print('%-6s %-22s %-26s %-9s %s' % (k[2], k[0], k[1], av + '->' + bv, verd))
    if verd != 'held':
        print('        GOLDEN %s' % (b or a).get('GOLDEN'))
        if a:
            print('        PRIS   %s' % a.get('OURS'))
        if b:
            print('        SHIP   %s' % b.get('OURS'))
print('CELLS %d   held %d   CONVERGED %d   REGRESSED %d   stillDIF %d' %
      (len(keys), n.get('held', 0), n.get('CONVERGED', 0), n.get('REGRESSED', 0),
       n.get('stillDIF', 0)))
PY
