#!/usr/bin/env python3
"""swcheck_rows.py <law-binary> <pristine sweep wd> <movers.txt> <census.txt>: for every corpus mover (corpus mode
name), re-run the pristine sweep's command with the law binary under R11U151_OFF=1 and under each class switch the
census names for the row, and compare the bytes with the pristine sweep's database.  FAIL-CLOSED on the fenced tests."""
import os, sys, shlex, subprocess, glob
HERE = os.path.dirname(os.path.abspath(__file__))
WT = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(WT, 'scripts'))
import verify_golden as vg
FENCED = {'UnsignedParam', 'HierPathEval', 'FileLocalParam', 'TopParam'}
CLASS = {'ARR': 'ARR', 'ARRNB': 'ARR', 'D2-def': 'D2', 'D2-elab': 'D2', 'D': 'D', 'DCAST': 'D', 'G': 'G', 'G2': 'G',
         'DEFPAT': 'DEFPAT', 'C3': 'C3'}
binary, swp, movers, census = sys.argv[1:5]
dirs = {'surelog': {k: v[0] for k, v in vg.discover_surelog(None).items()},
        'uhdm2rtlil': {k: v[0] for k, v in vg.discover_uhdm2rtlil(None).items()}}
laws = {}
for l in open(census):
    f = l.rstrip('\n').split('\t')
    laws[(f[0], f[1], f[2])] = [x for x in f[5][5:].split(',') if x]
for l in open(movers):
    corpus, mode, name = l.split()
    if name in FENCED:
        sys.exit('FENCE')
    d = glob.glob(os.path.join(swp, corpus, mode, name + '-*'))[0]
    argv = shlex.split([x for x in open(os.path.join(d, 'cmds.txt')) if x.startswith('slang:')][0][6:])[1:]
    i = argv.index('-o'); o = '/tmp/r11u151_swrow.uhdm'; argv = argv[:i] + ['-o', o] + argv[i + 2:]
    out = []
    classes = sorted({CLASS[x] for x in laws.get((corpus, mode, name), [])})
    for tag, env in [('ALL_OFF', {'R11U151_OFF': '1'})] + [(c + '_OFF', {f'R11U151_{c}_OFF': '1'}) for c in classes]:
        if os.path.exists(o): os.unlink(o)
        subprocess.run([binary] + argv, cwd=dirs[corpus][name], capture_output=True, env=dict(os.environ, **env))
        same = open(o, 'rb').read() == open(os.path.join(d, 'slang.uhdm'), 'rb').read()
        out.append(f'{tag}={"PRISTINE" if same else "MOVED"}')
    print(corpus, mode, name, 'classes=' + ','.join(classes), ' '.join(out), flush=True)
