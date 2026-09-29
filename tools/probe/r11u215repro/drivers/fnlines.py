#!/usr/bin/env python3
"""r11u215: the full-name line check of a database triple (pass 210's BlackBePipeInt check, generalised): the distinct
`vpiFullName:` lines of the golden, pristine and law uhdm-dumps.  written = in law, not pristine; removed = the reverse;
each split by presence in golden's dump.  A law that only writes golden names and removes only non-golden ones reads
written_not_in_golden=0 removed_in_golden=0.  usage: fnlines.py <golden.uhdm> <pristine.uhdm> <law.uhdm>"""
import sys, subprocess, os
D = os.environ.get('UHDM_DUMP', '/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump')
def fn(u):
    t = subprocess.run([D, u], capture_output=True, text=True, errors='replace').stdout
    return {l.strip() for l in t.splitlines() if l.strip().startswith('|vpiFullName:')}
G, P, L = (fn(u) for u in sys.argv[1:4])
w = L - P; r = P - L
print(f'written={len(w)} written_in_golden={len(w & G)} written_not_in_golden={len(w - G)} '
      f'removed={len(r)} removed_in_golden={len(r & G)} removed_not_in_golden={len(r - G)}')
for x in sorted(w - G)[:5]: print('  W!', x)
for x in sorted(r & G)[:5]: print('  R!', x)
