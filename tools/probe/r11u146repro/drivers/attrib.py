#!/usr/bin/env python3
# attrib.py <movers.tsv> <law_wd> <pris_wd> <out.tsv> [jobs]: for every mover row (corpus, mode, name),
# re-run its slang command line (from the law sweep's cmds.txt) with the frozen law binary under
# R11U146_OFF and under each single switch; name the switches whose OFF returns the pristine sweep's
# bytes.  Fail-closed on $FENCED (a fenced name is never run).
import sys, os, re, glob, subprocess, concurrent.futures as cf
FENCED = set(os.environ.get('FENCED', '').split())
if len(FENCED) != 4: sys.exit('attrib.py: export FENCED first')
MV, LW, PW, OUT = sys.argv[1:5]; JOBS = int(sys.argv[5]) if len(sys.argv) > 5 else 3
LAW = '/tmp/r11u146_bin/law.final.bin'
SR = '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog'
U2 = '/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test'
SLDIR = {}
for base in (SR + '/tests', SR + '/third_party/tests'):
    for f in glob.glob(base + '/*/*.sl') + glob.glob(base + '/*/*/*.sl'):
        SLDIR.setdefault(os.path.basename(f)[:-3], os.path.dirname(f))
SW = ['R11U148_E_OFF', 'R11U148_E2_OFF', 'R11U148_I_OFF', 'R11U146_MODARRBOUND_OFF', 'R11U146_PORTINIT_OFF',
      'R11U146_TPSTRUCTKW_OFF', 'R11U146_TPCALHS_OFF', 'R11U146_CLSTDPKG_OFF', 'R11U146_CASTKEYFILE_OFF',
      'R11U146_ESCCOL_OFF', 'R11U146_PORTEXPRLOC_OFF', 'R11U146_PORTEXPRDEF_OFF', 'R11U146_UCPLOC_OFF',
      'R11U146_UCPIF_OFF', 'R11U146_PATHBASE_OFF', 'R11U146_TFARGTD_OFF']
def one(row):
    c, mode, name = row[:3]
    if name in FENCED: return (c, mode, name, 'FENCED-SKIPPED', '', '')
    d = glob.glob(f'{LW}/{c}/{mode}/{name}-*')[0]; key = os.path.basename(d)
    pris = f'{PW}/{c}/{mode}/{key}/slang.uhdm'; law = d + '/slang.uhdm'
    line = [l for l in open(d + '/cmds.txt') if l.startswith('slang:')][0].split()[1:]
    args = line[1:]; i = args.index('-o'); cwd = SLDIR.get(name) if c == 'surelog' else f'{U2}/{name}'
    scratch = f'/tmp/r11u146_attrib/{c}/{mode}/{key}'; os.makedirs(scratch, exist_ok=True)
    def run(tag, env):
        o = f'{scratch}/{tag}.uhdm'
        if os.path.exists(o): os.remove(o)
        a = list(args); a[i + 1] = o
        e = dict(os.environ); e.update(env)
        subprocess.run([LAW] + a, cwd=cwd, env=e, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=900)
        return open(o, 'rb').read() if os.path.exists(o) else b''
    P = open(pris, 'rb').read(); L = open(law, 'rb').read()
    rerun = run('L', {})
    off = run('OFF', {'R11U146_OFF': '1'})
    owners = [s for s in SW if run('S', {s: '1'}) == P]
    return (c, mode, name, 'law-rerun-same' if rerun == L else 'law-rerun-DIFFERS',
            'alloff=pristine' if off == P else 'alloff-DIFFERS', ' '.join(owners))
rows = [l.rstrip('\n').split('\t') for l in open(MV) if l.strip()]
with cf.ThreadPoolExecutor(JOBS) as ex, open(OUT, 'w') as fo:
    for r in ex.map(one, rows):
        fo.write('\t'.join(r) + '\n'); fo.flush()
