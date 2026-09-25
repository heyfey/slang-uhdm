import os, sys, glob
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.join(HERE, '../../../../scripts'))
fen = os.environ.get('FENCED','').split()
assert len(fen) == 4
import downstream_uhdm2rtlil as ds
tag, root = sys.argv[1], sys.argv[2]
for c in sorted(glob.glob(os.path.join(HERE, '../cases/*/*/dut.sv'))):
    d = os.path.dirname(c); rel = d.split('/cases/')[1]
    if any(f in d for f in fen): continue
    r = ds.one(rel.replace('/', '_'), d, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], root, 300)
    print(rel, r['verdict'], r['differs'], r['surelog_status'], r['slang_status'], flush=True)
