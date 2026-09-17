#!/usr/bin/env python3
"""r11u60 CENSUS + CANDIDATE BOUND — the SHAPE LISTER over a whole
verify_golden.py workdir, restricted to the law's face: the DEFINITION listings
(`uhdmallModules`, `uhdmallInterfaces`) where a module or interface carries the
MATERIALIZED IMPORT COPY of a package parameter.

Three columns, every one read from PRISTINE databases only, so the prediction
can be written down BEFORE a single patched sweep is scored:

  GCTRL  golden cells in those listings that are TYPED+FLAT  -- the POSITIVE
         CONTROL.  A zero OUR column is a fact about the corpus only if this
         one is non-zero.
  LAWCELL golden TYPED+FLAT and ours different -- the cells this law is meant
         to move.  These are the PREDICTED MOVERS, by test name.
  RISK   every other cell in those listings whose Rhs is an op75 and where the
         two sides already AGREE -- the complete AWAY-GOLDEN exposure, the set
         that must not move.

usage: cen60.py <workdir> <mode>     [env CENSUS_JOBS=2]
"""
import os, re, subprocess, sys, concurrent.futures
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shape

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
DEFSECT = ('uhdmallModules', 'uhdmallInterfaces')
TYPEDFLAT = re.compile(r'op=75 ts=(?!-)\S+ ops=\[(?!.*tagged_pattern)')
ISOP = re.compile(r'op=\d+ ')

def one(root, d):
    p = os.path.join(root, d)
    name = d.rsplit('-', 1)[0]
    g = None
    cmds = os.path.join(p, 'cmds.txt')
    if os.path.exists(cmds):
        m = re.search(r'golden cache hit (/\S+?)\)', open(cmds).read())
        if m:
            g = os.path.join(m.group(1), 'golden.uhdm')
    o = os.path.join(p, 'slang.uhdm')
    res = {'name': name, 'gctrl': 0, 'allctrl': 0, 'law': [], 'risk': 0, 'note': ''}
    sides = {}
    for tag, path in (('G', g), ('O', o)):
        if not path or not os.path.exists(path):
            res['note'] = 'NOFILE-' + tag
            return res
        try:
            r = subprocess.run([DUMP, path], capture_output=True, text=True, timeout=900)
        except subprocess.TimeoutExpired:
            res['note'] = 'TIMEOUT-' + tag
            return res
        if r.returncode:
            res['note'] = 'DUMPRC%d-%s' % (r.returncode, tag)
            return res
        tmp = '/tmp/r11u60_cen_%s_%s_%d.txt' % (re.sub(r'\W', '_', name), tag, os.getpid())
        open(tmp, 'w').write(r.stdout)
        sides[tag] = {}
        for a, b, c, dd in shape.parse(tmp):
            if tag == 'G' and TYPEDFLAT.match(dd):
                res['allctrl'] += 1
            if a in DEFSECT:
                sides[tag].setdefault((a, b, c), []).append(dd)
        os.unlink(tmp)
    for k in sorted(set(sides['G']) | set(sides['O'])):
        gv = sorted(sides['G'].get(k, ['ABSENT']))
        ov = sorted(sides['O'].get(k, ['ABSENT']))
        if any(TYPEDFLAT.match(x) for x in gv):
            res['gctrl'] += 1
        if any(TYPEDFLAT.match(x) for x in gv) and gv != ov:
            res['law'].append((k, gv, ov))
        elif gv == ov and any(ISOP.match(x) for x in ov):
            res['risk'] += 1
    return res

wd, mode = sys.argv[1], sys.argv[2]
root = os.path.join(wd, mode)
dirs = sorted(d for d in os.listdir(root) if os.path.isdir(os.path.join(root, d)))
jobs = int(os.environ.get('CENSUS_JOBS', '2'))
gtot = risk = alltot = 0
names = []
with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
    for res in ex.map(lambda d: one(root, d), dirs):
        if res['note']:
            print('NOTE %s %s %s' % (res['name'], mode, res['note']))
            continue
        gtot += res['gctrl']
        alltot += res['allctrl']
        risk += res['risk']
        for k, gv, ov in res['law']:
            print('LAWCELL %-34s %-17s %-30s %-14s golden=%s ours=%s'
                  % (res['name'], k[0], k[1], k[2], gv, ov))
            names.append(res['name'])
print('== %s %s: ALLCTRL(golden typed-flat, every listing)=%d  GCTRL(golden typed-flat, DEF listings)=%d  LAWCELLS=%d on %d tests  RISK(must not move)=%d'
      % (wd, mode, alltot, gtot, len(names), len(set(names)), risk))
print('== LAW TESTS: %s' % ' '.join(sorted(set(names))))
