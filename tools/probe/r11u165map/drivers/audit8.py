#!/usr/bin/env python3
"""r11u165: the prediction audit of map 7 (tools/probe/r11u156map) against the landings since its pass-147
cross-section: passes 152, 154, 155, the r11u162 verification commit, 158, 160 and 163. Conversions are read from the
committed baselines at each landing commit (git show <commit>:results/golden_*.csv), never from a sweep. Map 7's
predictions: pair B r11u152's covered clusters (cluster_index_p147.csv coverage) and its rows cleared optimistically
(fail_list_p147.csv), and its section-6 greedy lists for the refills (evidence/greedy_sets147.txt). The landing law
of every converted test and its file are transcribed from the pass READMEs (LANDED below); the site audit compares
that file with map 7's pin of the row's first cluster after pass 147.
Args: <repo> <map-8 work dir (ids.json)> <map-8 out dir (cluster_index.csv)>"""
import csv, io, subprocess, sys, re, json, collections, os
REPO, W, OUT = sys.argv[1:4]
M7 = f'{REPO}/tools/probe/r11u156map'
_t = open(f'{REPO}/RESUME.md').read()
FEN = set(re.findall(r'`([A-Za-z_][A-Za-z0-9_]*)`', re.search(r'The four slang-fenced tests(.*?)are NEVER dispatched', _t, re.S).group(1)))
red = lambda n: 'FENCED' if n in FEN else n
STEPS = [('b6af876c', 'pass 147'), ('78f8134a', 'pass 152'), ('fc99b2d5', 'pass 154'), ('75226e07', 'pass 155'),
         ('0f607463', 'r11u162 (verification)'), ('202fb296', 'pass 158'), ('d48f8f8a', 'pass 160'), ('576b21fa', 'pass 163')]
def at(commit, f):
    return list(csv.DictReader(io.StringIO(subprocess.run(['git', '-C', REPO, 'show', f'{commit}:results/{f}'], capture_output=True, text=True).stdout)))
state = {}
for c, _ in STEPS:
    s = {}
    for corp in ('surelog', 'uhdm2rtlil'):
        for r in at(c, f'golden_{corp}.csv'): s[(corp, r['mode'], r['name'])] = r['status']
    p = {r['case']: r['status'] for r in at(c, 'golden_probe.csv')}
    state[c] = (s, p)
conv = {}; pconv = {}
P = print
P('== A. conversions per landing (committed baselines)')
for (c0, _), (c1, tag) in zip(STEPS, STEPS[1:]):
    s0, p0 = state[c0]; s1, p1 = state[c1]
    cv = sorted(k for k in s1 if s0.get(k) == 'STRICT_NOTEQUAL' and s1[k] == 'CMP_EQUAL')
    bad = sorted(k for k in s1 if s0.get(k) == 'CMP_EQUAL' and s1[k] != 'CMP_EQUAL')
    pc = sorted(k for k in p1 if p0.get(k) == 'STRICT_NOTEQUAL' and p1[k] == 'EQUAL')
    for k in cv: conv[k] = tag
    for k in pc: pconv[k] = tag
    P(f'   {tag} ({c1}): {len(cv)} row-modes / {len({(k[0], k[2]) for k in cv})} tests, {len(pc)} probe cases; left CMP_EQUAL {len(bad)}')
    P('      ', ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in cv))
# ---- the landing laws (from the pass READMEs' targeted-row tables)
LANDED = {
 'pass 152': {'StructArrayParameterInitializedByPatternPassedAsPort': ('portConnParamFoldAtActual152', 'ModuleEmit'),
   'NestedStructArrayParameterInitializedByPatternPassedAsPort': ('portConnParamFoldAtActual152 + pass 147 nestedPatOpTsNoParent151', 'ModuleEmit'),
   'LocalParamInNestedForLoops': ('genLpOperandTsNoParent152', 'ModuleEmit'), 'type_param_packed_dim': ('tpElemPatAtUser152', 'TypeEmit'),
   'FileLevelUnionWithMultirange': ('pkgElemMemberPatNoLoc152', 'TypeEmit'), 'PackageMemberTypespec': ('pkgElemMemberPatNoLoc152', 'TypeEmit'),
   'UnsupportedTypespecRange': ('pkgElemMemberPatNoLoc152', 'TypeEmit'), 'PackedEnumPort': ('packedElemAliasTypedef152', 'TypeEmit'),
   'VarPassedTo2Submodules': ('packedElemAliasTypedef152', 'TypeEmit'), 'packed_array_struct_port_sel': ('tpOvrTypedefStructSpan152', 'TypeEmit'),
   'struct_member_cfg_width': ('tpOvrTypedefStructSpan152', 'TypeEmit'), 'TypeParamElab': ('tpOvrTypedefStructSpan152', 'TypeEmit'),
   'GenCase': ('genCaseItemUnnamed152', 'ModuleEmit'), 'GenCaseStmt': ('genCaseItemUnnamed152', 'ModuleEmit'),
   'DelayAssign': ('delayLiteralValueText152', 'ModuleEmit'), 'CrossFunc': ('unsupportedTsInitEnd152', 'TypeEmit+ModuleEmit'),
   'ClassParamAsParam': ('classVarInitSpan152 + classSpecNestedAtName152 + classSpecPaNoFile152', 'ModuleEmit+TypeEmit+UhdmExporter'),
   'ibex_alu': ('crossPkgFoldTsNameOnChain152, joint with the landed base (r11u159 section 8)', 'TypeEmit')},
 'pass 154': {'BasicOh': ('genScopeProcPsNamedByScope154 + genProcFoldTsKeepsScope154', 'ExprEmit'),
   'InterfaceParamOverrideProp': ('defPkgStructParamMemberNames154', 'ParamEmit'),
   'StringMethod': ('builtinMethodArgNamedByPath154 + varInitStrMethodArgDefNet154', 'EmitHelpers+ExprEmit'),
   'comb_dyn_2d_packed_sel': ('elabCastSharesDeclRef154', 'ExprEmit'),
   'iface_arr_struct_field_partsel': ('hpPartSelBoundNamesBySelect154 + hpElemSelNameIsPathSoFar154', 'ExprEmit'),
   'iface_cfg_mem': ('portViewNestedPatTsNamed154', 'ExprEmit+ParamEmit'), 'iface_param_2level': ('portViewNestedPatTsNamed154', 'ExprEmit+ParamEmit'),
   'iface_nested_param_field': ('defPkgStructParamMemberNames154 + portViewNestedPatTsNamed154', 'ParamEmit+ExprEmit'),
   'iface_struct_field_param_width': ('defPkgStructParamMemberNames154 + portViewNestedPatTsNamed154', 'ParamEmit+ExprEmit'),
   'iface_scalar_localparam': ('five laws (hpPartSelBoundNamesBySelect154 ... portViewNestedPatTsNamed154)', 'ExprEmit+EmitHelpers+ParamEmit'),
   'iface_struct_field_partsel': ('five laws (as iface_scalar_localparam)', 'ExprEmit+EmitHelpers+ParamEmit'),
   'jeras_tcb_gpio': ('hpPartSelBoundNamesBySelect154', 'ExprEmit'), 'mem_ff_partial_rsp': ('lvIdxPathIsRead154', 'EmitHelpers')},
 'pass 155': {'ImplicitArg': ('implicitArgDimsInner155', 'TypeEmit'), 'UnpackPort': ('nonAnsiArrayNetAtHeader155', 'ModuleEmit'),
   'GenForIfaceLocalparamBound': ('ifacePortViewFoldAtLeftOperand155', 'ModuleEmit'), 'GenForIfaceLocalparamNestedGen': ('ifacePortViewFoldAtLeftOperand155', 'ModuleEmit'),
   'IfGenTypeBinding': ('pkgTdStretchNonAnsiHeaderSkips155', 'UhdmExporter'), 'union_param_repro': ('unitAggTfArgLastWriter155', 'UhdmExporter'),
   'genscope_module_ctx_reset': ('pselConnNameNotFrozen155', 'ModuleEmit'), 'PatternStruct': ('packedStructNdaFoldConstLoc155', 'ModuleEmit'),
   'OneNetModport': ('ifaceSigConnNamedByChildPort155', 'ModuleEmit'), 'iface_sig_in_child_port': ('ifaceSigConnNamedByChildPort155', 'ModuleEmit')},
 'pass 158': {'EnumVar': ('enumAliasEndAtDimOrInitDecl158', 'ParamEmit'), 'HierPathStructTypespec': ('pkgFoldLeftParenSpan158', 'ParamEmit'),
   'LocalScopeHierPath': ('foreachArrPathVarForm157', 'ExprEmit'), 'SimpleConstraint': ('methodRandomizeCallSpan158', 'ExprEmit'),
   'MultirangesStartNotFromZero': ('genCaLhsEnumConstClone158', 'ExprEmit+EmitHelpers'), 'expr_width_cast': ('hpSelRoute157', 'ExprEmit'),
   'portsel_struct_param': ('hpSelRoute157', 'ExprEmit')},
 'pass 160': {'MacroArgMismatch': ('objMacroParenArgsTrimmed160', 'UhdmExporter'), 'ComplexParamOverload': ('implNetBareParamElab160', 'ModuleEmit'),
   'BlackConst': ('ppMacroBodyLines160', 'UhdmExporter'), 'gen_scope_typaram': ('tpCloneWholeLhsBare160', 'TypeEmit'),
   'gen_scope_numports': ('tpUseBindsDefDefault160', 'UhdmExporter'), 'packed_array_reset_loop': ('defNetTypeParamPackedVec160 + tpUseBindsDefDefault160', 'ModuleEmit+UhdmExporter'),
   'packed_array_struct': ('bodyTypeParamDefaultBound160 + tpUseBindsDefDefault160', 'ModuleEmit+UhdmExporter'),
   'packed_struct_array_fifo': ('tpUseBindsDefDefault160', 'UhdmExporter'),
   **{t: ('ppMacroBodyLines160', 'UhdmExporter') for t in ('ibex_branch_predict', 'ibex_csr', 'ibex_fetch_fifo', 'ibex_wb_stage', 'ibex_decoder', 'ibex_multdiv_slow', 'ibex_compressed_decoder')}},
 'pass 163': {'FuncIoTypespec': ('fnParamRangeNetNoFile163', 'ExprEmit'), 'LargeValue2Struct': ('elabAggFoldYCopyDefNamed163', 'ParamEmit'),
   'StructUnsizedVal': ('elabAggFoldYCopyDefNamed163', 'ParamEmit'), 'ParamNoImport': ('ovPkgPatOpInstanceCopy163', 'ParamEmit'),
   'ParamTypespec2': ('pkgPatListingCopyWhenShared163 + importPatOpCloneParamNamed163', 'ParamEmit'),
   'param_array_wildcard': ('elabOvArrFoldSharesDefParamTs163', 'ParamEmit'), 'struct_param_pattern_packing': ('paramOpCloneRelocatedSpan163', 'ParamEmit'),
   'type_param_override_elem_sel': ('elabTpNamedElemDimDefNamed163', 'ParamEmit')}}
# ---- map 7's predictions
CI7 = {r['cluster_id']: r for r in csv.DictReader(open(f'{M7}/cluster_index_p147.csv'))}
FL7 = {(r['corpus'], r['mode'], r['test']): r for r in csv.DictReader(open(f'{M7}/fail_list_p147.csv'))}
open147 = {k for k, r in FL7 if False} if False else {k for k, r in FL7.items() if not r['strict_after_law'].startswith('equal')}
predB = {k for k, r in FL7.items() if k in open147 and r['clears_after_both_pairs'].startswith('yes')}
lists = {}; cur = None
for l in open(f'{M7}/evidence/greedy_sets147.txt'):
    m = re.match(r'## ground (\w)', l)
    if m: cur = m.group(1); continue
    m = re.match(r'\| (\d+) \| ([N0-9 +]+) \| (\d+) \| \d+ \| \d+ \| ([^|]*) \|', l)
    if m and cur:
        for tok in m.group(4).split():
            p = tok.split('/'); t = p[0]; mode = 'default' if p[1] == 'd' else 'testflags'; corp = 'uhdm2rtlil' if len(p) > 2 else 'surelog'
            lists[(corp, mode, t)] = (cur, int(m.group(1)), m.group(2).strip())
file_of = lambda s: set(re.findall(r'\((\w+)\.(?:cpp|h)', s))
mint_of = lambda s: (re.findall(r'\((\w+)\.(?:cpp|h)', s) or ['?'])[0]
P(f'== B. map 7 predicted, on its pass-147 cross-section ({len(open147)} row-modes open after pass 147)')
P(f'   pair B r11u152 optimistic (named + routed + C3): {len(predB)} row-modes')
P(f'   section-6 ground-A list: {sum(1 for v in lists.values() if v[0] == "A")} row-modes; ground-B list: {sum(1 for v in lists.values() if v[0] == "B")}')
by = collections.defaultdict(list)
for k in sorted(open147):
    tag = conv.get(k)
    pr = ('pairB-r11u152' if k in predB else '') + (f' list-{lists[k][0]}{lists[k][1]}' if k in lists else '')
    by[(pr.strip() or 'none', tag or 'open')].append(k)
P('   predicted-by x landed-by (row-modes):')
for (pr, tag), ks in sorted(by.items()):
    P(f'     {pr:32s} {tag:28s} {len(ks):3d}  ' + ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in ks[:40]))
P('== C. per landing: predicted (and by whom) vs not predicted; the site audit (map 7 pin of the first cluster after pass 147 vs the landing file)')
rows = []
for k, tag in sorted(conv.items(), key=lambda x: (x[1], x[0])):
    if tag in ('pass 147',): continue
    law, f = LANDED.get(tag, {}).get(k[2], ('?', '?'))
    fc = FL7.get(k, {}).get('first_cluster_after_law', '-')
    site = CI7.get(fc, {}).get('site', '-')
    lf = set(f.split('+'))
    verdict = ('pin right (mint)' if mint_of(site) in lf else 'pin right (a caller)' if lf & file_of(site) else 'pin misses') if site not in ('-', '') else 'no pin'
    pred = 'pairB-r11u152' if k in predB else (f'list-{lists[k][0]} step {lists[k][1]} ({lists[k][2]})' if k in lists else 'not predicted')
    rows.append((tag, k, law, f, fc, mint_of(site), verdict, pred))
    P(f"   {tag:10s} {k[0][:3]}/{k[1][0]}/{red(k[2]):58s} {pred:40s} first@147={fc} pin={mint_of(site):14s} law={law} ({f}) -> {verdict}")
cnt = collections.Counter((r[0], r[7].split()[0] if r[7] != 'not predicted' else 'not predicted') for r in rows)
P('   tally (landing, predicted-by):', dict(cnt))
P('   site verdicts:', dict(collections.Counter(r[6] for r in rows)))
P('   site verdicts by ground of the landing:', dict(collections.Counter((r[0], r[6]) for r in rows)))
# ---- cluster level
CI8 = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))}
B7 = {c for c, r in CI7.items() if r['coverage'].startswith('COVERED') and 'r11u152' in r['coverage'].split('(')[0]}
L7 = {}
for l in open(f'{M7}/evidence/greedy_sets147.txt'):
    m = re.match(r'## ground (\w)', l)
    if m: cur = m.group(1); continue
    m = re.match(r'\| (\d+) \| ([N0-9 +]+) \|', l)
    if m and cur:
        for c in m.group(2).split('+'): L7[c.strip()] = f'{cur}{m.group(1)}'
def fate(c):
    a = int(CI7[c]['rows_after_law']) if c in CI7 else 0
    b = int(CI8[c]['rows']) if c in CI8 else 0
    pa = int(CI7[c]['probe_after_law']) if c in CI7 else 0; pb = int(CI8[c]['probe_cases']) if c in CI8 else 0
    return a, b, pa, pb, ('gone' if b == 0 and pb == 0 else 'rows cleared' if b == 0 and a > 0 else 'fell' if b < a else 'unchanged' if b == a else 'grew')
for tag, S in (('map 7 pair B r11u152 covered', B7), ('map 7 section-6 lists', set(L7))):
    fs = collections.Counter(); det = collections.defaultdict(list)
    for c in sorted(S):
        a, b, pa, pb, f = fate(c); fs[f] += 1; det[f].append(f'{c}{"(" + L7[c] + ")" if c in L7 else ""} {a}->{b}')
    P(f'== D. {tag}: {len(S)} clusters: {dict(fs)}')
    for f, v in det.items(): P(f'     {f}: ' + ' '.join(v))
# clusters not predicted that cleared / fell
unp = []
for c, r in CI7.items():
    if c in B7 or c in L7: continue
    a, b, pa, pb, f = fate(c)
    if a > 0 and b < a: unp.append((a - b, c, a, b))
unp.sort(reverse=True)
P(f'== E. clusters map 7 did not route (pair B / section 6) whose rows cleared or fell: {len(unp)}:', ' '.join(f'{c} {a}->{b}' for _, c, a, b in unp[:60]))
json.dump([dict(zip(('landing', 'row', 'law', 'file', 'first_cluster_p147', 'pin_mint', 'verdict', 'predicted'), (r[0], '/'.join(r[1]), *r[2:]))) for r in rows], open(f'{W}/audit_rows.json', 'w'), indent=0)
