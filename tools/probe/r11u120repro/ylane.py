#!/usr/bin/env python3
"""ylane.py <workdir> <db>...: run the downstream harness's own Yosys lane
(scripts/downstream_uhdm2rtlil.yosys_lane: fixed-length run path, in.uhdm copy)
on each database and print '<db> <status> <md5 of nohier.il>'.  Run from the
repo root with UHDM2RTLIL_ROOT exported."""
import hashlib, os, sys
sys.path.insert(0, 'scripts')
import downstream_uhdm2rtlil as ds
work = sys.argv[1]
for i, db in enumerate(sys.argv[2:]):
    name = 'yl%02d' % i
    st, g, files = ds.yosys_lane(name, name, os.path.abspath(db), None, False, work, 300)
    h = hashlib.md5(b''.join(open(files['nohier'], 'rb').readlines()[1:])).hexdigest()[:12] if os.path.isfile(files['nohier']) else '-'
    print(db, st, h, files['nohier'])
