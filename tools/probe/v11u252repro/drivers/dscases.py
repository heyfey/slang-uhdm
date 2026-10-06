#!/usr/bin/env python3
# (v11u252: copied from r11u252repro/drivers)
# (r11u250: copied from r11u249repro/drivers)
# (r11u249: copied from r11u247repro/drivers)
# (r11u247) dscases.py <tag> <workroot> <casedir>...: the downstream harness (scripts/downstream_uhdm2rtlil.py's
# one()) on each case with the binary at $SLANG_UHDM; one line per case: <case> <tag> <verdict> <differs> rc-columns.
# Fail-closed on $FENCED; a case path holding a fenced name is refused.
import os, re, sys
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscases.py: FENCED unset (source drivers/env.sh)')
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds
tag, root = sys.argv[1:3]
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', c) for f in F):
        print(c, 'FENCED-REFUSED'); continue
    name = re.sub(r'[^A-Za-z0-9_]', '_', c.split('/tools/probe/')[-1])
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], os.path.join(root, tag), 300)
    print(c.split('/tools/probe/')[-1], tag, r, flush=True)
