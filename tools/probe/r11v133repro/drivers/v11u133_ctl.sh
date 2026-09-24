#!/bin/bash
# v11u133_ctl.sh <name> <root> : runs grid on pris+law, byte compare (path-normalised), record-check movers
n=$1; r=$2
/tmp/v11u133_grid.sh $r /tmp/v11u133_c${n}P /tmp/v11u133_bin/pris > /tmp/v11u133_c${n}P.txt
/tmp/v11u133_grid.sh $r /tmp/v11u133_c${n}L /tmp/v11u133_bin/law0 > /tmp/v11u133_c${n}L.txt
python3 - $n <<'PY'
import sys,os,glob
n=sys.argv[1]; P=f'/tmp/v11u133_c{n}P'; L=f'/tmp/v11u133_c{n}L'
mov=[]; tot=0
for a in sorted(glob.glob(P+'/*.uhdm')):
    b=L+'/'+os.path.basename(a); tot+=1
    if not os.path.exists(b): mov.append((a,b)); continue
    if open(a,'rb').read().replace(f'v11u133_c{n}P'.encode(),f'v11u133_c{n}L'.encode())!=open(b,'rb').read(): mov.append((a,b))
with open(f'/tmp/v11u133_c{n}.tsv','w') as f:
    for a,b in mov:
        g=a[:-5]+'.golden'
        if os.path.exists(g): f.write(f'{os.path.basename(a)[:-5]}\t{open(g).read().strip()}\t{a}\t{b}\n')
print(f'{n}: movers {len(mov)}/{tot}')
PY
python3 /tmp/v11u133_worse.py /tmp/v11u133_c$n.tsv > /tmp/v11u133_c${n}_worse.txt
