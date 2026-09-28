#!/usr/bin/env python3
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
"""statecounts.py <workdir>...: per sweep, probe EQUAL, surelog CMP_EQUAL default + testflags, uhdm2rtlil CMP_EQUAL
default / testflags (read from the sweep csvs; the fenced rows are counted by status only, never opened)."""
import csv, sys, os, collections
for w in sys.argv[1:]:
    out = [os.path.basename(w)]
    p = f'{w}/probe.csv'
    out.append('probe=' + (str(sum(1 for r in csv.DictReader(open(p)) if r['status'] == 'EQUAL')) if os.path.exists(p) else '-'))
    for c in ('surelog', 'uhdm2rtlil'):
        p = f'{w}/{c}.csv'
        if not os.path.exists(p): out.append(f'{c}=-'); continue
        n = collections.Counter((r['mode']) for r in csv.DictReader(open(p)) if r['status'] == 'CMP_EQUAL')
        out.append(f"{c}={n['default']}+{n['testflags']}")
    print(' '.join(out))
