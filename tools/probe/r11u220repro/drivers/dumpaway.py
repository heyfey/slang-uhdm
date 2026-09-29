#!/usr/bin/env python3
"""dumpaway.py: see the text below.
Fail-closed on the fence: the four names of the FENCED= line of tools/probe/r11u107repro/canaudit.sh (read here); a
path holding one of them is refused."""
import os, re, sys
_R = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
_F = next((l.split('=', 1)[1].strip().strip('"\'').split() for l in open(os.path.join(_R, 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')), [])
if len(_F) != 4: sys.exit('fence unreadable')
for _a in sys.argv[1:]:
    if any(re.search(r'(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])' % re.escape(f), _a) for f in _F): sys.exit('fenced path refused')
# #!/usr/bin/env python3
# """dumpaway.py <golden.uhdm> <pristine.uhdm> <law.uhdm>: the dump-line away census for one case-view, usable where the
# strict comparator stops at stage 1 (no record lists): uhdm-dump of each database, ids and the case path stripped, as
# multisets of lines; lost = lines golden holds that the pristine dump matched and the law dump no longer matches
# (sum over lines of max(0, min(P,G) - min(L,G))), toward = the reverse. Prints `lost=<n> toward=<n>` (swap the last two
# arguments for the positive control: it must read lost equal to the forward toward). UHDM_DUMP from the environment."""
# 
import sys, os, re, subprocess, collections
dump = os.environ['UHDM_DUMP']
def lines(p):
    out = subprocess.run([dump, p], capture_output=True, text=True).stdout
    c = collections.Counter()
    for l in out.splitlines():
        l = re.sub(r'id:\d+', '', l); l = re.sub(r'file:\S+', 'file:', l)
        c[l] += 1
    return c
G, P, L = (lines(p) for p in sys.argv[1:4])
lost = sum(max(0, min(P[k], G[k]) - min(L[k], G[k])) for k in G)
toward = sum(max(0, min(L[k], G[k]) - min(P[k], G[k])) for k in G)
print(f'lost={lost} toward={toward}')
