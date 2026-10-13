# (v11u310: copied from r11u310repro/drivers, scratch paths renamed to /tmp/v11u310_*)
# (r11u310: copied from r11u308repro/drivers, renamed to R11U310 / r11u310)
#!/bin/bash
# r11u310 attrib310.sh (copied from r11u308repro attrib308.sh) <grid.txt> <movers> <law bin> <out>: every mover case-view rerun on the law binary with each
# of this pass's switches set alone; one line per case-view naming the switches that give back pristine's md5
# (`restored-by: <SW>...`) and those that move the bytes at all (`moved-by:`).  Fail-closed on $FENCED (case.sh).
H=$(cd "$(dirname "$0")" && pwd); source "$H/env.sh" || exit 2
G=$1; M=$2; L=$3; O=$4
SW="R11U310_METHTAIL_OFF R11U310_METHIDXTEXT_OFF R11U310_METHRECVCUM_OFF R11U310_METHIDXCALL_OFF R11U310_METHIDXSEL_OFF R11U310_METHNESTSEL_OFF R11U310_METHPATHSPAN_OFF R11U310_LVNESTIDX_OFF R11U310_CASTSELIDX_OFF R11U310_CASTLVIDX_OFF R11U310_CLSLVTRAIL_OFF R11U310_CALLTERNTRUE_OFF R11U310_QUALCALLSPAN_OFF"
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
    if m == md.get((c, v, 'pristine')): res[(c, v)].append(s.replace('R11U310_', '').replace('_OFF', ''))
    if m != md.get((c, v, 'law')): mv[(c, v)].append(s.replace('R11U310_', '').replace('_OFF', ''))
keys = sorted(set(k for k in mv) | set(k for k in res))
cnt = collections.Counter()
for k in keys:
    print(k[0], k[1], 'restored-by:', ','.join(sorted(res[k])) or '-', 'moved-by:', ','.join(sorted(mv[k])) or '-')
    cnt[','.join(sorted(res[k])) or ('multi:' + ','.join(sorted(mv[k])))] += 1
for k, n in cnt.most_common(): print('#', n, k)
PY
grep '^#' $O
