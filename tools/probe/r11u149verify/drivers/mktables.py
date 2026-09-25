#!/usr/bin/env python3
# mktables.py: the per-law tables of README.md from evidence/grid_score.tsv and evidence/downstream_cases.tsv
import csv, collections, re
E = '/tmp/wt_r11u149/tools/probe/r11u149verify/evidence/'
LAW = {'sca': '§ sysArgUnaryWholeSpan140 (`R11U140_SYSUNARY_OFF`)', 'scv': '§ sysArgUnaryConstSelToken140v (`R11V140_CONSTSEL_OFF`)',
 'stm': '§ streamOperandBraceSpan140 (`R11U140_STREAMBRACE_OFF`)', 'plv': '§ procLvTrailIdxNamesByPath140 (`R11U140_LVIDX_OFF`)',
 'plt': '§ procLvBaseSelTrailAtIdx140 (`R11U140_LVTRAIL_OFF`)', 'fav': '§ foreachArrayPlaceholderFile140 (`R11U140_FEFILE_OFF`)',
 'pso': '§ elabPatOperandRefSpan140 (`R11U140_PATOPSPAN_OFF`)', 'mdi': '§ multiDeclOneItem140 (`R11U140_MULTIDECL_OFF`)',
 'lat': '§ impLhsCloneArrayTsOwnCopy140 (`R11U140_LHSARRTS_OFF`)', 'pfp': '§ pkgRefFoldClonesMultiDimOnly140 (`R11U140_PKGREFMD_OFF`)',
 'pfx': '§ mdRenameNotUnderBareCa140v (`R11V140_MDRENAME_OFF`)', 'tdc': '§ pkgTypedefCastTargetTs140 (`R11U140_PKGTDCAST_OFF`)',
 'dfl': '§ defaultFillOneConstant140 (`R11U140_DEFFILL_OFF`)', 'rcf': '§ replCountFoldFile140 (`R11U140_REPLCNTFILE_OFF`)',
 'el': '§ elabCloneInstTreeUnstored144 (`R11U144_ELABINST_OFF` + `R11U144_ELABPROP_OFF`)', 'ia': '§ caSelLhsBareDecNoAdjust144 (`R11U144_SELBAREDEC_OFF`)',
 'pf': '§ callFoldFormalBitSelLoc144 (`R11U144_CALLBITSEL_OFF`)', 'fb': '§ foldedBoundTsRefUnstored144 (`R11U144_FOLDTSNAME_OFF`)',
 'tq': '§ defNetTypeParamPackedDim144 (`R11U144_TPPACKEDNET_OFF`)', 'pt': '§ paramAliasBoundRefUnstored144 (`R11U144_PARAMALIASREF_OFF`)',
 'qb': '§ pkgTsForeignQualRefUnstored144 (`R11U144_PKGQUALREF_OFF`)', 'vf': '§ classMethodQualSpan144 (`R11U144_METHQUALSPAN_OFF`)',
 'at': '§ methodSpanSkipsAttrs144 (`R11U144_METHATTR_OFF`)', 'hg': '§ defGenLhsHpBaseAnchor144 (`R11U144_DEFGENHP_OFF`)'}
ds = collections.defaultdict(dict)
for ln in open(E + 'downstream_cases.tsv'):
    f = ln.rstrip('\n').split('\t')
    if len(f) >= 3: ds[f[1]][f[0]] = f[2]
rows = collections.defaultdict(list)
for ln in open(E + 'grid_score.tsv'):
    f = ln.rstrip('\n').split('\t')
    g, c, m = f[0].split('__')
    rows[g].append((c, m, f[1], f[2], f[3], f[4], f[5]))
def verdict(v):
    v = re.sub(r'\(refdiv=\d+\)', '', v)
    return {'CONVERT': 'law converts', 'IMPROVE': 'toward golden', 'same-bytes': 'law not reached (bytes equal)', 'STAGE1': 'stage 1 both',
            'SAME-RECS': 'same records', 'UNMASK': 'unmask (proven)'}.get(v, v)
for g in LAW:
    if g not in rows: continue
    print(f'\n#### {LAW[g]}\n')
    print('| case | mode | both landings off | own switch off | law on | own switch -> on | downstream off -> on |')
    print('|---|---|---|---|---|---|---|')
    for c, m, off, own, on, vo, vf in sorted(rows[g]):
        d = ds.get(f'{g}__{c}', {})
        dd = f"{d.get('OF','-')} -> {d.get('ON','-')}" if m == 'plain' else ''
        v = verdict(vo)
        if v.startswith('NEW'): v = '**BREAK** ' + v
        print(f'| `{g}/{c}` | {m} | {off} | {own} | {on} | {v} | {dd} |')
