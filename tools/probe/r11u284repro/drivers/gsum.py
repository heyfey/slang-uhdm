import collections,sys
# r11u284 gsum.py <gridall.txt>: one line per case-view: MOVE flag, pristine and law verdicts, OFF!=PRIS when law+R11U284_OFF differs from pristine.
rows=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p=l.split(); case,v,lab=p[0],p[1],p[2]; rest=' '.join(p[3:])
    rows[(case,v)][lab]=rest
for (c,v),d in sorted(rows.items()):
    P=d.get('pristine',''); L=d.get('law',''); O=d.get('law+R11U284_OFF','')
    pm=P.split('md5=')[-1]; lm=L.split('md5=')[-1]; om=O.split('md5=')[-1]
    mv='MOVE' if pm!=lm else '    '
    flag='' if om==pm else ' OFF!=PRIS'
    print(f"{mv} {c} {v} | P: {P.split(' md5')[0]} | L: {L.split(' md5')[0]}{flag}")
