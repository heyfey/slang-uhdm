#!/usr/bin/env python3
# (r11u246) dscases.py <binary> <workroot> <out.csv> [jobs]: the downstream harness's own `one` (uhdm2rtlil's Surelog
# lane vs the slang lane with the downstream flags, then Yosys) on every case under cases/ (case dirs only; the
# corpora are not read).  Writes name,verdict,differs,slang_status,surelog_status.
import os, sys, csv, glob, concurrent.futures
B, W, OUT = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2]), sys.argv[3]
J = int(sys.argv[4]) if len(sys.argv) > 4 else 3
os.environ['SLANG_UHDM'] = B
H = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
R = os.path.abspath(os.path.join(H, '..', '..', '..'))
sys.path.insert(0, os.path.join(R, 'scripts'))
import downstream_uhdm2rtlil as ds
cases = sorted(d for d in glob.glob(os.path.join(H, 'cases', '*', '*')) if os.path.isdir(d))
def run(d):
    name = os.path.relpath(d, os.path.join(H, 'cases')).replace('/', '__')
    a = os.path.join(d, 'args')
    files = open(a).read().split() if os.path.exists(a) else ['dut.sv']
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv'] + files, W, 300)
    return [name, r['verdict'], r['differs'], r['slang_status'], r['surelog_status']]
with concurrent.futures.ThreadPoolExecutor(J) as p:
    rows = list(p.map(run, cases))
with open(OUT, 'w', newline='') as f:
    w = csv.writer(f); w.writerow(['name', 'verdict', 'differs', 'slang_status', 'surelog_status']); w.writerows(rows)
print(len(rows), 'cases')
