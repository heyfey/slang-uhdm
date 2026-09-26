#!/usr/bin/env python3
"""pins.txt (pinall.py / pinmulti.py) -> sites.json {cluster id: {site, owner, example}}. A
site = the minting frame and its two callers, each as `function (File.cpp, law
<nearest law above the frame's line>)`; the law is re-read here from the source
(a law name has an upper-case letter or a digit, so prose after the section
sign such as 'the' is skipped); line numbers dropped (anchors are names).
Args: <pins.txt> <sites.json> <src dir>"""
import sys, re, json, os
SRC = sys.argv[3]; cache = {}
def law_above(f, line):
    p = os.path.join(SRC, f) if os.path.exists(os.path.join(SRC, f)) else os.path.join(SRC, '..', f)
    if p not in cache: cache[p] = open(p, errors='replace').read().splitlines()
    L = cache[p]
    for i in range(min(line, len(L)) - 1, max(0, line - 600), -1):
        for m in re.finditer(r'§ ([A-Za-z][A-Za-z0-9_]*)', L[i]):
            if re.search(r'[A-Z0-9]', m.group(1)): return m.group(1)
    return None
cur = None; S = {}; ranks = {}; lib = {}
for l in open(sys.argv[1]):
    m = re.match(r'^== ([NQ]\d+) (\S+) (.*)$', l)
    if m: cur = m.group(1); ranks[cur] = []; S[cur] = m.group(2) + ' ' + m.group(3); continue
    if re.match(r'^  rank ', l): ranks[cur].append([]); lib[cur] = []; continue
    ml = re.match(r'^\s+#(\d+)\s+(\S+) at \?:0', l)
    if ml and cur and ml.group(1) != '0': lib[cur].append(ml.group(2))
    m = re.match(r'^\s+#(\d+)\s+(\S+) at \S*?(\w+\.cpp):(\d+)', l)
    if m and cur and ranks[cur] and m.group(1) != '0':
        law = law_above(m.group(3), int(m.group(4)))
        ranks[cur][-1].append(f"{m.group(2)} ({m.group(3)}" + (f", law {law})" if law else ")"))
out = {}
for k, rs in ranks.items():
    chains = []
    for r in rs:
        c = ' < '.join(r[:3])
        if c and c not in chains: chains.append(c)
    own = re.search(r'\((\w+\.cpp)', chains[0]).group(1) if chains else '?'
    if not chains and lib.get(k):
        # r11u138: minted inside UHDM's own library (no source frame in the 12 captured): the --elabuhdm elaborator
        out[k] = {'site': 'UHDM library ' + ' < '.join(lib[k][:3]) + ' (--elabuhdm, testflags) run from main (uhdm_main.cpp)', 'owner': 'uhdm_main.cpp', 'example': S[k]}
        continue
    out[k] = {'site': ' | '.join(chains[:2]) if chains else 'NOT PINNED (no mint frame)', 'owner': own, 'example': S[k]}
json.dump(out, open(sys.argv[2], 'w'), indent=1)
print(len(out), 'sites;', sum(1 for v in out.values() if v['owner'] == '?'), 'unpinned')
