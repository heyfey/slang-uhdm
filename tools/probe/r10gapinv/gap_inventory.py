#!/usr/bin/env python3
# FULL GAP INVENTORY across all remaining not-equal tests: every differing dump
# line, attributed to its OWNING OBJECT KIND (own-child-depth), clustered into
# structural families, aggregated across tests. Multiset-based (no alignment),
# names/ids/spans stripped from keys so instances of one law collapse together.
import subprocess, os, re, collections, sys
DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')
TESTS = ['SimpleUVM','Scoreboard','SeqDriver','BuildUVMPkg','SVSwitch',
         'Earlgrey_0_1','YosysOldOr','YosysVerx','Rggen']
HDR = re.compile(r'^( *)\\_(\w+):')
FLD = re.compile(r'^( *)\|(\w+):(.*)$')
def census(db):
    c = collections.Counter()
    proc = subprocess.Popen([DUMP, db], stdout=subprocess.PIPE, text=True,
                            errors='replace')
    stack = []  # (indent, kind)
    first = True
    for line in proc.stdout:
        if first: first = False; continue
        line = line.rstrip('\n')
        m = HDR.match(line)
        if m:
            ind = len(m.group(1))
            while stack and stack[-1][0] >= ind: stack.pop()
            owner = stack[-1][1] if stack else 'design'
            c[('CHILD', owner, m.group(2))] += 1
            stack.append((ind, m.group(2)))
            continue
        f = FLD.match(line)
        if f:
            ind = len(f.group(1))
            while stack and stack[-1][0] >= ind: stack.pop()
            owner = stack[-1][1] if stack else 'design'
            v = f.group(3).strip()
            vc = '' if not v else ('#' if re.fullmatch(r'-?\d+', v) else 's')
            c[('FIELD', owner, f.group(2), vc)] += 1
    proc.wait()
    return c
agg = collections.defaultdict(dict)   # key -> {test: delta}
for t in TESTS:
    dirs = [d for d in os.listdir('/tmp/f57_wd_sl/default') if d.startswith(t+'-')]
    if not dirs: print('SKIP', t, file=sys.stderr); continue
    d = '/tmp/f57_wd_sl/default/'+dirs[0]
    g = None
    for line in open(d+'/cmds.txt'):
        i = line.find('golden cache hit ')
        if i >= 0: g = line[i+17:].split(')')[0].strip()+'/golden.uhdm'; break
    cg, co = census(g), census(d+'/slang.uhdm')
    for k in set(cg) | set(co):
        dl = cg[k] - co[k]
        if dl: agg[k][t] = dl
    print('done', t, file=sys.stderr)
rows = []
for k, per in agg.items():
    tot = sum(abs(v) for v in per.values())
    rows.append((tot, k, per))
rows.sort(reverse=True)
print('DISTINCT FAMILIES with any delta: %d   total differing instances: %d'
      % (len(rows), sum(r[0] for r in rows)))
print('%-7s %-42s %-6s %s' % ('TOTAL','FAMILY (kind of line @ owner)','TESTS','per-test delta (+=golden has more / we MISS, -=we OVER-emit)'))
for tot, k, per in rows[:30]:
    fam = ('%s %s @%s' % (k[0], '/'.join(k[2:]) if k[0]=='FIELD' else k[2], k[1]))
    pt = ' '.join('%s%+d' % (t[:9], v) for t, v in sorted(per.items(), key=lambda x:-abs(x[1]))[:4])
    print('%-7d %-42s %-6d %s' % (tot, fam[:42], len(per), pt))
cum = 0; total = sum(r[0] for r in rows)
for i,(tot,k,per) in enumerate(rows):
    cum += tot
    if cum >= total*0.8:
        print('\n80%% of all differing instances live in the TOP %d families (of %d)' % (i+1, len(rows)))
        break
