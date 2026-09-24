#!/usr/bin/env python3
# attrib_table.py -> per mover row: the switches whose single-switch-off run changes the law bytes (owns the move)
import glob, os, filecmp
SW = 'PATD EMPTYCONN UNSIGNEDSPAN CALLSPAN REPLTSNAME ELABCLONE PUREVIRTSPAN TAGGEDSPAN DEFNETTP ALIASFILE SCOPEDARRTD PATHBASE CA NDA CLK PORT'.split()
L = '/tmp/r11u137_wdL'; A = '/tmp/r11u137_att'
rows = {}
for s in SW:
    for c in ('surelog', 'uhdm2rtlil'):
        for d in glob.glob(f'{A}/{s}/{c}/*/*'):
            rel = d.split(f'/{s}/{c}/')[1]
            o, l = d + '/slang.uhdm', f'{L}/{c}/{rel}/slang.uhdm'
            if not (os.path.exists(o) and os.path.exists(l)): continue
            rows.setdefault((c, rel), [])
            if not filecmp.cmp(o, l, shallow=False): rows[(c, rel)].append(s)
for (c, rel), v in sorted(rows.items()):
    print(f'{c}\t{rel}\t{" ".join(v) if v else "-"}')
