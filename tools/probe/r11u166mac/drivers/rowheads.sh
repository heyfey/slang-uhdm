#!/bin/bash
# rowheads.sh <workdir root (verify_golden --workdir)> <mode> <test> <outdir> [max]
#   strictcmp --max <max,50> --dump-a/--dump-b on the row's golden and slang databases; writes <outdir>/<test>.<mode>.
#   {g,s}.rec + strict.txt and prints the verdict and each differing record pair (strictcmp's own listing: A = golden,
#   B = ours) with the three nearest golden ancestors (the parent chain in walk order).
# Refuses a fenced test: FENCED must be set (the four names, space separated) and <test> must not match one.
set -u
: "${FENCED:?FENCED must list the fenced tests}"
root=$1; mode=$2; t=$3; out=$4; mx=${5:-50}
for f in $FENCED; do [[ "$t" =~ (^|[^A-Za-z0-9_])$f([^A-Za-z0-9_]|$) ]] && { echo "REFUSE fenced"; exit 3; }; done
d=$(ls -d "$root/$mode/$t"-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "NO_ROW $t/$mode"; exit 4; }
g=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' "$d/cmds.txt")/golden.uhdm
[ -s "$g" ] || g=$(sed -n 's/.*golden cache \(store\|miss\)[^/]*\(\/[^) ]*\).*/\2/p' "$d/cmds.txt")/golden.uhdm
[ -s "$g" ] || { echo "NO_GOLDEN $d"; exit 5; }
mkdir -p "$out"; a=$out/$t.$mode.g.rec; b=$out/$t.$mode.s.rec
"${STRICT_CMP:?}" --max "$mx" --dump-a "$a" --dump-b "$b" "$g" "$d/slang.uhdm" > "$out/$t.$mode.strict.txt" 2>&1
tail -1 "$out/$t.$mode.strict.txt"
python3 - "$a" "$out/$t.$mode.strict.txt" <<'PY'
import sys,re
A=[l.rstrip('\n').split('\t') for l in open(sys.argv[1])]
def chain(i):
    d=int(A[i][0]); out=[]
    for j in range(i-1,-1,-1):
        if int(A[j][0])<d:
            out.append(A[j]); d=int(A[j][0])
            if len(out)==3: break
    return out
for l in open(sys.argv[2]):
    m=re.match(r'#(\d+) (\S+)',l)
    if m:
        i=int(m.group(1))
        if i<len(A): print('#%s %s  <- %s'%(i,m.group(2),' / '.join('%s %s %s:%s'%(c[1],c[2] or c[4],c[6],c[7]) for c in chain(i))))
    elif l.startswith('  A:') or l.startswith('  B:'):
        f=l.rstrip('\n')[5:].split('\t'); print('   %s %s %s %s %s:%s-%s:%s %s'%(l[2],f[1],f[2],f[5],f[6],f[7],f[8],f[9],f[10][:40]))
PY
