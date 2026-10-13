#!/usr/bin/env python3
# (r11u307: copied from r11u305repro/drivers)
# (r11u305: copied from r11u303repro/drivers)
# (r11u303: copied from r11u301repro/drivers)
# (r11u299: copied from r11u297repro/drivers)
# (r11u297: copied from r11u295repro/drivers)
# (r11u295: copied from r11u293repro/drivers)
# (r11u293: copied from r11u291repro/drivers)
# (r11u291: copied from r11u289repro/drivers)
# r11u285 recpath.py <rec file> <index>...: the walk path (ancestors by depth) of strict records #index (1-based, as
# uhdm-strictcmp numbers them), printed with the record itself. Reads only the record dump it is given.
import os, re, sys
F = os.environ.get("FENCED", "").split()
if len(F) != 4: sys.exit("recpath.py: FENCED unset")
if any(re.search(rf"(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])", sys.argv[1]) for f in F): sys.exit("fenced path refused")
recs = [l.rstrip('\n').split('\t') for l in open(sys.argv[1])]
for a in sys.argv[2:]:
    i = int(a) - 1
    d = int(recs[i][0]); out = [recs[i]]
    for j in range(i - 1, -1, -1):
        if int(recs[j][0]) < d:
            out.append(recs[j]); d = int(recs[j][0])
            if d == 0: break
    print('#' + a)
    for r in reversed(out): print('  ' + ' | '.join(r[:10]))
