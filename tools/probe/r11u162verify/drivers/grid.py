#!/usr/bin/env python3
"""grid.py [--el] <casedir>... : score every case law-on against law-off (r11u162: passes 154 + 155).

For each case the first line names its laws (`// § a § b`).  States run on the frozen HEAD binary
($LAW): ON (no switch), OFF_<law> (that law's own switch; a verifier refinement `...v` is also scored
against its parent law's switch, which is pristine), every pair of own switches for a multi-law case,
and ALLOFF (both landings off: R11U154_OFF R11V154_VIDMOD_OFF R11U155_OFF).  Per state: uhdm-cmp line
count, the strict verdict and the strict records (field, golden text, ours text) differing from golden.
Per law:
  UNFIRED   ON and OFF write the same bytes
  TOWARD    records OFF had that ON has not, none new
  AWAY      a record ON differs on that OFF did not (a break candidate: inspect)
  MIXED     both
  BYTES-ONLY bytes move, the differing-record multiset does not
  STAGE1-x  either state is stage 1: the order-blind dump distance to golden decides (CLOSER / SAME / AWAY)
Fail-closed on $FENCED."""
import os, re, subprocess, sys, itertools, collections, hashlib
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('grid.py: source drivers/env.sh first')
D = os.path.dirname(os.path.abspath(__file__))
SW = {
 'hpPartSelBoundNamesBySelect154': ['R11U154_HPPSBOUND_OFF'], 'hpElemSelNameIsPathSoFar154': ['R11U154_HPELEMNAME_OFF'],
 'genScopeProcPsNamedByScope154': ['R11U154_GSPROCPS_OFF'], 'genProcFoldTsKeepsScope154': ['R11U154_GSFOLDTS_OFF'],
 'builtinMethodArgNamedByPath154': ['R11U154_MARGNAME_OFF'], 'varInitStrMethodArgDefNet154': ['R11U154_VARINITDEF_OFF'],
 'varInitDefNetModuleOnly154v': ['R11V154_VIDMOD_OFF'], 'elabCastSharesDeclRef154': ['R11U154_CASTREF_OFF'],
 'lvIdxPathIsRead154': ['R11U154_LVIDXREAD_OFF'], 'lvPathBaseAtFirstMember154': ['R11U154_LVBASEMEM_OFF'],
 'lvPathSelNamedByChain154': ['R11U154_LVSELNAME_OFF'], 'lvIfacePathBitSelWhole154': ['R11U154_LVBSSPAN_OFF'],
 'defPkgStructParamMemberNames154': ['R11U154_DEFPKGTS_OFF'], 'paramInitUnpackedMemberPath154': ['R11U154_PIUNPACKED_OFF'],
 'psBoundPathFirstMember154': ['R11U154_PSBOUNDPATH_OFF'], 'portViewNestedPatTsNamed154': ['R11U154_PVNESTTS_OFF'],
 'initTsEndProgramLocal155': ['R11U155_PRGINITEND_OFF'], 'implicitArgDimsInner155': ['R11U155_IMPLARGDIM_OFF'],
 'nonAnsiArrayNetAtHeader155': ['R11U155_NAARRNET_OFF'], 'naArrNetOwnPortDecl155v': ['R11V155_NAARRSEP_OFF'],
 'unitAggTfArgLastWriter155': ['R11U155_UNITUNIONARG_OFF', 'R11U155_UNITSTRUCTARG_OFF'],
 'modAggTfArgLastWriter155': ['R11U155_MODAGGARG_OFF'], 'pselConnNameNotFrozen155': ['R11U155_PSELNAME_OFF'],
 'packedStructNdaFoldConstLoc155': ['R11U155_NDAFOLDLOC_OFF'], 'ifacePortViewFoldAtLeftOperand155': ['R11U155_PVLEFTOP_OFF'],
 'pkgTdStretchNonAnsiHeaderSkips155': ['R11U155_TDSTRETCHHDR_OFF'], 'tdStretchProgramKeeps155v': ['R11V155_TDPRG_OFF'],
 'dirlessFormalTypeAtName155': ['R11U155_DIRLESSNAME_OFF'], 'ifaceSigConnNamedByChildPort155': ['R11U155_IFSIGCHILD_OFF'],
 'genLpOperandTsNoParent152': ['R11U152_GENLPOPTS_OFF'], 'tpOvrTypedefStructSpan152': ['R11U152_TPOVRSTRUCT_OFF'],
}
PARENT = {'varInitDefNetModuleOnly154v': 'varInitStrMethodArgDefNet154', 'naArrNetOwnPortDecl155v': 'nonAnsiArrayNetAtHeader155',
          'tdStretchProgramKeeps155v': 'pkgTdStretchNonAnsiHeaderSkips155'}
ALL = ['R11U154_OFF=1', 'R11V154_VIDMOD_OFF=1', 'R11U155_OFF=1']
DUMP = os.environ['UHDM_DUMP']; LAW = os.environ['LAW']
GW = os.environ.get('GW', '/tmp/r11u162_g')

def env_of(law): return [s + '=1' for s in SW[law]]

def run(case, tag, envs, el):
    env = dict(os.environ); env['EL'] = '1' if el else '0'
    return subprocess.run([f'{D}/case.sh', case, tag, LAW] + envs, capture_output=True, text=True, env=env).stdout.strip()

def wdir(case, el):
    rel = case.split('/r11u162verify/cases/')[1]
    return f'{GW}/{rel}' + ('_el' if el else '')

def recs(w, tag):
    p = f'{w}/{tag}.strict'
    if not os.path.exists(p): return None, 'NODB'
    L = open(p, errors='replace').read().splitlines()
    last = L[-1] if L else ''
    if 'stage1' in last or not L: return None, 'stage1'
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

def score(w, on, off, g):
    fon, foff = f'{w}/{on}.uhdm', f'{w}/{off}.uhdm'
    if not (os.path.exists(fon) and os.path.exists(foff)): return 'NODB', ''
    if md5(fon) == md5(foff): return 'UNFIRED', ''
    ra, la = recs(w, on); rb, lb = recs(w, off)
    dg, dn, df = dump(g), dump(fon), dump(foff)
    if ra is not None and rb is not None:
        new = ra - rb; gone = rb - ra
        v = 'TOWARD' if gone and not new else 'AWAY' if new and not gone else 'MIXED' if new else 'BYTES-ONLY'
        det = f'new={sum(new.values())} gone={sum(gone.values())}'
        if new: det += ' | first new: ' + ' / '.join(sorted(new)[0])
        det += f' | dump pris={dist(dg, df)} law={dist(dg, dn)}'
        return v, det
    a, b = dist(dg, df), dist(dg, dn)
    nb = (dn - dg) - (df - dg)
    v = 'STAGE1-' + ('CLOSER' if b < a else 'SAME' if a == b else 'AWAY')
    det = f'dump pris={a} law={b} newbad={sum(nb.values())}'
    if sum(nb.values()): det += ' | +' + ' | +'.join(list(nb)[:3])
    return v, det

def main():
    args = sys.argv[1:]; el = False
    if args and args[0] == '--el': el = True; args = args[1:]
    for case in args:
        case = os.path.abspath(case)
        if any(re.search(rf'\b{re.escape(n)}\b', case) for n in FENCED): print('FENCED-SKIP', case); continue
        laws = re.findall(r'§ (\w+)', open(f'{case}/dut.sv').readline())
        for l in list(laws):
            if l in PARENT and PARENT[l] not in laws: laws.append(PARENT[l])
        w = wdir(case, el)
        lines = [run(case, 'on', [], el)]
        states = []
        for l in laws:
            lines.append(run(case, 'off_' + l, env_of(l), el)); states.append(('off_' + l, l))
        own = [l for l in laws if l not in PARENT.values() or l in re.findall(r'§ (\w+)', open(f'{case}/dut.sv').readline())]
        if len(own) > 1:
            for a, b in itertools.combinations(own, 2):
                lines.append(run(case, f'off2_{a}_{b}', env_of(a) + env_of(b), el))
        lines.append(run(case, 'alloff', ALL, el))
        for l in lines: print('  ' + l)
        g = None
        for x in os.listdir(w):
            if x.startswith('gold_') and os.path.exists(f'{w}/{x}/golden.uhdm'): g = f'{w}/{x}/golden.uhdm'
        if not g: print('RESULT', w.split(GW + '/')[1], 'NOGOLD', flush=True); continue
        for t, l in states:
            v, det = score(w, 'on', t, g)
            print('RESULT', w.split(GW + '/')[1], l, v, det, flush=True)
        v, det = score(w, 'on', 'alloff', g)
        print('RESULT', w.split(GW + '/')[1], 'ALLOFF', v, det, flush=True)

main()
