#!/bin/bash
# switches.sh <law binary> <pristine binary> <out>: every case under ../cases with the pristine binary, the law binary,
# the law binary with R11U166_OFF=1 R11U168_OFF=1 (must equal pristine bytes on every case), and each r11u168 switch
# alone; one line per case: verdicts and the switches that move the case off the law's bytes.
D=$(cd "$(dirname "$0")" && pwd); C=$D/../cases; L=$1; P=$2; O=$3
export GW=${GW:-/tmp/r11u168_gC}
bash $D/grid.sh $C pris $P > $O.pris
bash $D/grid.sh $C law $L > $O.law
bash $D/grid.sh $C off $L R11U166_OFF=1 R11U168_OFF=1 > $O.off
SW="R11U168_PPFILECALL_OFF R11U168_UNDEFXROOT_OFF R11U168_PSBOUNDTS_OFF R11U168_HCIDXNAME_OFF R11U168_SPLEAF_OFF R11U168_RNGHPNAME_OFF"
for s in $SW; do bash $D/grid.sh $C sw_$s $L $s=1 > $O.$s; done
python3 - $O $SW <<'PY'
import sys
o = sys.argv[1]; sw = sys.argv[2:]
def rd(f):
    d = {}
    for l in open(f):
        p = l.split()
        d[p[0]] = (p[4] if len(p) > 4 else p[2], p[-1])
    return d
pr, la, of = rd(o + '.pris'), rd(o + '.law'), rd(o + '.off')
ss = {s: rd(o + '.' + s) for s in sw}
same_off = sum(1 for k in pr if of.get(k, (0, 0))[1] == pr[k][1])
with open(o, 'w') as f:
    for k in sorted(pr):
        mv = [s for s in sw if ss[s][k][1] != la[k][1]]
        f.write('%s pris=%s law=%s off_eq_pris=%s moved_by=%s\n' % (k, pr[k][0], la[k][0], of[k][1] == pr[k][1], ','.join(mv) or '-'))
    f.write('CASES %d  all-off==pristine %d  strict-equal pristine %d law %d\n' % (len(pr), same_off,
            sum('STRICT_EQUAL' in v[0] for v in pr.values()), sum('STRICT_EQUAL' in v[0] for v in la.values())))
PY
tail -1 $O
