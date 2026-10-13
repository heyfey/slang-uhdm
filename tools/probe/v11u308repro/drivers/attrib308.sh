#!/bin/bash
# r11u308 attrib308.sh <grid.txt> <movers> <law bin> <out>: every mover case-view rerun on the law binary with each
# of this pass's switches set alone; one line per case-view naming the switches that give back pristine's md5
# (`restored-by: <SW>...`) and those that move the bytes at all (`moved-by:`).  Fail-closed on $FENCED (case.sh).
H=$(cd "$(dirname "$0")" && pwd); source "$H/env.sh" || exit 2
G=$1; M=$2; L=$3; O=$4
SW="R11U308_ELABCLSIDX_OFF R11U308_LEAFSELELAB_OFF R11U308_IPSLEAF_OFF R11U308_CASTNTIDX_OFF R11U308_NTIDXCHAIN_OFF R11U308_NTIDXLEAF_OFF R11U308_NESTMIDSEL_OFF R11U308_VSHPOP_OFF R11U308_NESTVARSEL_OFF R11U308_BAREIPS_OFF R11U308_LVMEMSEL_OFF R11U308_LVIDXCHAIN_OFF R11U308_CALHS_OFF"
C=${CB:-$H/../cases}
grep '^MOVER' $M | while read -r _ c v; do v=${v%:}; for s in $SW; do echo "$c $v $s"; done; done | xargs -P 3 -L 1 bash -c 'export $2=1; r=$(bash '"$H"'/case.sh '"$C"'/$0 '"$L"' $1 5); echo "$0 $1 $2 ${r##*md5=}"' > $O.raw
python3 - "$G" "$O.raw" > $O <<'PY'
import sys, collections
G, R = sys.argv[1:3]
md = {}
for l in open(G):
    w = l.split()
    md[(w[0], w[1], w[2])] = l.split('md5=')[-1].strip()
res = collections.defaultdict(list); mv = collections.defaultdict(list)
for l in open(R):
    c, v, s, m = l.split()
    if m == md.get((c, v, 'pristine')): res[(c, v)].append(s.replace('R11U308_', '').replace('_OFF', ''))
    if m != md.get((c, v, 'law')): mv[(c, v)].append(s.replace('R11U308_', '').replace('_OFF', ''))
keys = sorted(set(k for k in mv) | set(k for k in res))
cnt = collections.Counter()
for k in keys:
    print(k[0], k[1], 'restored-by:', ','.join(sorted(res[k])) or '-', 'moved-by:', ','.join(sorted(mv[k])) or '-')
    cnt[','.join(sorted(res[k])) or ('multi:' + ','.join(sorted(mv[k])))] += 1
for k, n in cnt.most_common(): print('#', n, k)
PY
grep '^#' $O
