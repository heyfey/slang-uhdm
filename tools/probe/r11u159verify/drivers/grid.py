#!/usr/bin/env python3
"""grid.py [--el] [--only REGEX] <casedir>... : score every case law-on against law-off.

For each case the first line names its laws (`// § a § b`).  States run on the frozen HEAD binary
($LAW): ON (no switch), OFF_<law> (that law's own switch), ALLOFF (both landings off) and, for a
multi-law case, every pair of own switches.  For each state: uhdm-cmp line count, the strict verdict,
and the strict records (field, golden text, ours text) differing from golden.  Per law:
  UNFIRED   ON and OFF write the same bytes
  TOWARD    records OFF had that ON has not, none new
  AWAY      a record ON differs on that OFF did not (a break candidate: inspect)
  MIXED     both
  STAGE1    either state is stage 1: then the order-blind dump distance decides (CLOSER / SAME / AWAY)
Fail-closed on $FENCED."""
import os, re, subprocess, sys, itertools, collections, hashlib
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('grid.py: source drivers/env.sh first')
D = os.path.dirname(os.path.abspath(__file__))
SW = {
 'ifaceMemberTrailIdxNamesByPath147': 'R11U147_IFTRAILIDX_OFF', 'vsIpsBaseNamesByIps147': 'R11U147_VSIPSBASE_OFF',
 'lvIdxBitSelAtIndex147': 'R11U147_LVIDXBS_OFF', 'nestedDefaultPatLoc147': 'R11U147_NESTDEFLOC_OFF',
 'gcaUseSiteParamConst147': 'R11U147_GCAUSESITE_OFF', 'gcaBareBoundKeepsInst147v': 'R11V147_GCABARE_OFF',
 'firstOrderedConnBitSelWhole147': 'R11U147_FIRSTPOS_OFF', 'memberEnumCloneKeepsBase147': 'R11U147_ENUMCLONE_OFF',
 'enumQualDefaultDefSpan147': 'R11U147_ENUMQSPAN_OFF',
 'pkgTdCastTargetOwnView151': 'R11U151_D2_OFF', 'blockLhsVarSelBindsWholeRef151': 'R11U151_ARR_OFF',
 'nonblockingSelLhsBindsWholeRef151': 'R11U151_ARRNB_OFF', 'condTakenParamRhsShared151': 'R11U151_G_OFF',
 'concatArrParamDefTs151': 'R11U151_G2_OFF', 'patLeftoverOrphanCopy151': 'R11U151_D_OFF',
 'hierSizeCastBaseStructTs151': 'R11U151_DCAST_OFF', 'nestedPatOpTsNoParent151': 'R11U151_C3_OFF',
 'portConnParamFoldAtActual152': 'R11U152_C3_OFF', 'genLpOperandTsNoParent152': 'R11U152_GENLPOPTS_OFF',
 'crossPkgFoldTsNameOnChain152': 'R11U152_FOLDCHAIN_OFF', 'tpElemPatAtUser152': 'R11U152_TPELEMPAT_OFF',
 'pkgElemMemberPatNoLoc152': 'R11U152_PKGELEMPAT_OFF', 'packedElemAliasTypedef152': 'R11U152_ELEMALIAS_OFF',
 'tpOvrTypedefStructSpan152': 'R11U152_TPOVRSTRUCT_OFF', 'genCaseItemUnnamed152': 'R11U152_GENCASE_OFF',
 'delayLiteralValueText152': 'R11U152_DLYREAL_OFF', 'unsupportedTsInitEnd152': 'R11U152_CGINITEND_OFF',
 'classVarInitSpan152': 'R11U152_CLSVARINIT_OFF', 'classSpecNestedAtName152': 'R11U152_CLSNESTNAME_OFF',
 'classSpecPaNoFile152': 'R11U152_CLSPANOFILE_OFF', 'pkgLeafPatLocByWriting152': 'R11U152_PKGLEAFLOC_OFF',
 'classVarInitNewDecl152v': 'R11V152_CLSVARNEW_OFF'}
ALL = ['R11U147_OFF=1', 'R11U151_OFF=1', 'R11U152_OFF=1', 'R11V152_CLSVARNEW_OFF=1', 'R11V147_GCABARE_OFF=1']
DUMP = os.environ['UHDM_DUMP']; LAW = os.environ['LAW']
GW = os.environ.get('GW', '/tmp/r11u159_g')

def run(case, tag, envs, el):
    env = dict(os.environ); env['EL'] = '1' if el else '0'
    out = subprocess.run([f'{D}/case.sh', case, tag, LAW] + envs, capture_output=True, text=True, env=env).stdout.strip()
    return out

def wdir(case, el):
    rel = case.split('/r11u159verify/cases/')[1]
    return f'{GW}/{rel}' + ('_el' if el else '')

def recs(w, tag):
    p = f'{w}/{tag}.strict'
    if not os.path.exists(p): return None, 'NODB'
    L = open(p, errors='replace').read().splitlines()
    last = L[-1] if L else ''
    if 'stage1' in last: return None, 'stage1'
    s = collections.Counter()
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L): s[(m.group(2), L[i+1].strip(), L[i+2].strip())] += 1
    return s, last

def dump(f):
    t = subprocess.run([DUMP, f], capture_output=True, text=True, errors='replace').stdout
    return collections.Counter(re.sub(r'id:\d+', '', re.sub(r'/[^ ,:()]*/', '', l)).strip() for l in t.splitlines()
                               if 'Restored design' not in l)

def dist(a, b): return sum(((a - b) + (b - a)).values())

def md5(f): return hashlib.md5(open(f, 'rb').read()).hexdigest()[:8] if os.path.exists(f) else '-'

def score(case, w, on, off, g):
    fon, foff = f'{w}/{on}.uhdm', f'{w}/{off}.uhdm'
    if not (os.path.exists(fon) and os.path.exists(foff)): return 'NODB', ''
    if md5(fon) == md5(foff): return 'UNFIRED', ''
    ra, la = recs(w, on); rb, lb = recs(w, off)
    if ra is not None and rb is not None:
        new = ra - rb; gone = rb - ra
        v = 'TOWARD' if gone and not new else 'AWAY' if new and not gone else 'MIXED' if new else 'BYTES-ONLY'
        det = f'new={sum(new.values())} gone={sum(gone.values())}'
        if new: det += ' | first new: ' + ' / '.join(sorted(new)[0])
        if v == 'BYTES-ONLY' or True:
            dg, dn, df = dump(g), dump(fon), dump(foff)
            det += f' | dump pris={dist(dg, df)} law={dist(dg, dn)}'
        return v, det
    dg, dn, df = dump(g), dump(fon), dump(foff)
    a, b = dist(dg, df), dist(dg, dn)
    nb = (dn - dg) - (df - dg)
    v = 'STAGE1-' + ('CLOSER' if b < a else 'SAME' if a == b else 'AWAY')
    det = f'dump pris={a} law={b} newbad={sum(nb.values())}'
    if sum(nb.values()): det += ' | +' + ' | +'.join(list(nb)[:3])
    return v, det

def main():
    args = sys.argv[1:]; el = False; only = None
    if args and args[0] == '--el': el = True; args = args[1:]
    for case in args:
        case = os.path.abspath(case)
        if any(re.search(rf'\b{re.escape(n)}\b', case) for n in FENCED): print('FENCED-SKIP', case); continue
        first = open(f'{case}/dut.sv').readline()
        laws = re.findall(r'§ (\w+)', first)
        w = wdir(case, el)
        lines = [run(case, 'on', [], el)]
        states = []
        for l in laws:
            lines.append(run(case, 'off_' + l, [SW[l] + '=1'], el)); states.append(('off_' + l, l))
        if len(laws) > 1:
            for a, b in itertools.combinations(laws, 2):
                t = f'off2_{a}_{b}'
                lines.append(run(case, t, [SW[a] + '=1', SW[b] + '=1'], el))
        lines.append(run(case, 'alloff', ALL, el))
        for l in lines: print('  ' + l)
        g = None
        for x in os.listdir(w):
            if x.startswith('gold_') and os.path.exists(f'{w}/{x}/golden.uhdm'): g = f'{w}/{x}/golden.uhdm'
        if not g: print('RESULT', w.split(GW + '/')[1], 'NOGOLD'); continue
        for t, l in states:
            v, det = score(case, w, 'on', t, g)
            print('RESULT', w.split(GW + '/')[1], l, v, det, flush=True)
        v, det = score(case, w, 'on', 'alloff', g)
        print('RESULT', w.split(GW + '/')[1], 'ALLOFF', v, det, flush=True)

main()
