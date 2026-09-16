#!/usr/bin/env python3
"""r11u49 CENSUS / SHAPE LISTER over a whole verify_golden.py workdir.

For every test, dump BOTH databases and run the r11u49 shape lister over each;
report every (listing, parameter, loc) cell where the two sides disagree, and
count the GOLDEN cells that are `typed + flat` (the cell this pass's law mints)
as the POSITIVE CONTROL -- a zero golden column would mean the instrument is
blind, not that the corpus is empty.
usage: census.py <workdir> <mode>    [env CENSUS_JOBS=2]
"""
import os, re, subprocess, sys, concurrent.futures
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shape

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
TYPEDFLAT = re.compile(r'op=75 ts=(?!-)\S+ ops=\[(?!.*tagged_pattern)')

def one(root, d):
    p = os.path.join(root, d)
    name = d.rsplit('-', 1)[0]
    cmds = os.path.join(p, 'cmds.txt')
    g = None
    if os.path.exists(cmds):
        m = re.search(r'golden cache hit (/\S+?)\)', open(cmds).read())
        if m: g = os.path.join(m.group(1), 'golden.uhdm')
    o = os.path.join(p, 'slang.uhdm')
    res = {'name': name, 'gcells': 0, 'diffs': [], 'note': ''}
    sides = {}
    for tag, path in (('G', g), ('O', o)):
        if not path or not os.path.exists(path):
            res['note'] = 'NOFILE-' + tag; return res
        tmp = '/tmp/r11u49_cen_%s_%s_%d.txt' % (name, tag, os.getpid())
        try:
            r = subprocess.run([DUMP, path], capture_output=True, text=True, timeout=900)
        except subprocess.TimeoutExpired:
            res['note'] = 'TIMEOUT-' + tag; return res
        if r.returncode:
            res['note'] = 'DUMPRC%d-%s' % (r.returncode, tag); return res
        open(tmp, 'w').write(r.stdout)
        sides[tag] = {(a, b, c): d for a, b, c, d in shape.parse(tmp)}
        os.unlink(tmp)
    for k in sorted(set(sides['G']) | set(sides['O'])):
        gv = sides['G'].get(k, 'ABSENT'); ov = sides['O'].get(k, 'ABSENT')
        if TYPEDFLAT.match(gv): res['gcells'] += 1
        if gv != ov:
            res['diffs'].append((k, gv, ov))
    return res

wd, mode = sys.argv[1], sys.argv[2]
root = os.path.join(wd, mode)
dirs = sorted(d for d in os.listdir(root) if os.path.isdir(os.path.join(root, d)))
jobs = int(os.environ.get('CENSUS_JOBS', '2'))
gtot = dtot = 0
with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
    for res in ex.map(lambda d: one(root, d), dirs):
        gtot += res['gcells']
        if res['note']:
            print('NOTE %s %s %s' % (res['name'], mode, res['note'])); continue
        for k, gv, ov in res['diffs']:
            dtot += 1
            print('DIFF %s %s %s %s %s  G[%s]  O[%s]' % (res['name'], mode, k[0], k[1], k[2], gv, ov))
print('CENSUS %s %s: tests=%d GOLDEN-typed-flat-cells=%d differing-cells=%d'
      % (wd, mode, len(dirs), gtot, dtot))
