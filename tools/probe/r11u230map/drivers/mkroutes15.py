#!/usr/bin/env python3
"""r11u230map (fifteenth edition, base 97343175): the live pairs pair A r11u227 (ExprEmit/EmitHelpers/StmtEmit/ParamEmit,
base ac0dda58) and pair B r11u228 (TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main, base 1a30095a): their
brief items mapped to clusters (evidence/routes.json) and the ground overrides (evidence/ground_override.json = map
14's list + pass 228's decodes; report15.py reads it before this edition's writer pins). `pairX_named` = a cluster a brief item names (by id or by its
decoded head); `pairX` = named + the optimistic credits; `pairX_rows` = rows whose whole ground-X half a brief item
names (optimistic: counted fixed whole). The UVM ground-A families and the Earlgrey ground-A scope-name family (pair
A) and map 11's first-ten rule (pair B, the UVM heads and Earlgrey's records) are optimistic too (report15.py).
usage: mkroutes15.py <repo> <routes.json> <ground_override.json> [<writer_ground.json>]"""
import json, sys, os
REPO, OUT, GOV = sys.argv[1:4]
WOV = sys.argv[4] if len(sys.argv) > 4 else None
A_named = {
 # pair A r11u227 brief item (1): map 14's ground-A greedy list
 'N0980': 'item 1: FuncStructVal A half (named N0980)', 'N1946': 'item 1: FuncStructVal A half (named N1946)',
 'N1096': 'item 1: FuncStructVal #747 (a forward reference to a later package spanning pkg::)',
 'N0675': 'item 1: struct_param_func_config A half (N0675)', 'N2412': 'item 1: struct_param_func_config A half (N2412)',
 'N0025': 'item 1: cfg_func_width_loop A half (N0025)', 'N0033': 'item 1: cfg_func_width_loop A half (N0033)',
 'N0754': 'item 1: cfg_func_width_loop A half (N0754)', 'N0794': 'item 1: cfg_func_width_loop A half (N0794)',
 'N0868': 'item 1: BlackBePipeInt head #15268 / #15272 (the defaulted pattern member left empty)',
 'N0131': 'item 1: N0131 (a constant\'s empty ref_typespec full name)',
 'N0812': 'item 1: the Earlgrey_0_1 scope-name clusters (N0812)',
 # item (5) carried
 'N0008': 'item 5: N0008 (a design param_assign constant\'s ref_typespec named uvm_pkg)',
 'N0739': 'item 5: map 13\'s N0739', 'N1903': 'item 5: map 13\'s N1903', 'N1904': 'item 5: map 13\'s N1904',
 'N0476': 'item 5: map 13\'s N0476', 'N0477': 'item 5: map 13\'s N0477'}
B_named = {
 # pair B r11u228 brief item (1): map 14's ground-B greedy list
 'N0891': 'item 1: FuncStructVal (N0891, TypeEmit buildStructTs)',
 'N0817': 'item 1: struct_param_func_config (N0817)', 'N0028': 'item 1: struct_param_func_config (N0028)',
 'N0761': 'item 1: struct_param_func_config (N0761)', 'N0552': 'item 1: struct_param_func_config (N0552)',
 'N0045': 'item 1: struct_param_func_config (N0045)',
 'N0133': 'item 1: cfg_func_width_loop kept call (N0133)', 'N0487': 'item 1: cfg_func_width_loop kept call (N0487)',
 'N0263': 'item 1: cfg_func_width_loop #464 (the elaborated formal clone of the typedef, range folded)',
 'N0073': 'item 1: BlackBePipeInt (N0073)', 'N2471': 'item 1: BlackBePipeInt (N2471)', 'N0014': 'item 1: BlackBePipeInt (N0014)',
 'N0905': 'item 1: BlackBePipeInt (N0905)', 'N1179': 'item 1: BlackBePipeInt (N1179)',
 'N0120': 'item 1: N0120 (the catch enum_var span, TaskFuncEmit emitTaskFuncs)',
 # item (4) the UVM heads, by their decoded head at 97343175
 'N0266': 'item 4: UVM_SEQ_ARB_TYPE (MiniAmiq / SeqDriver first record)',
 'N0337': 'item 4: this_type (SimpleUVM / Scoreboard first record)',
 'N0072': 'item 4: this_type (BuildUVMPkg first record)'}
A_rows = {t: {'modes': None, 'why': f'r11u227 brief item 1: the {t} A half'} for t in ('FuncStructVal', 'struct_param_func_config', 'cfg_func_width_loop', 'BlackBePipeInt')}
B_rows = {t: {'modes': None, 'why': f'r11u228 brief item 1: the {t} B half'} for t in ('FuncStructVal', 'struct_param_func_config', 'cfg_func_width_loop', 'BlackBePipeInt')}
R = dict(pairA=dict(A_named), pairB=dict(B_named), pairA_named=A_named, pairB_named=B_named, pairA_rows=A_rows, pairB_rows=B_rows,
         uvm_A_families='pair A item 5: the UVM A families after pass 224 (every ground-A cluster whose rows are all UVM rows, optimistic)',
         earl_A_family='pair A item 1: the Earlgrey_0_1 scope-name clusters (every ground-A cluster whose rows are all Earlgrey rows, optimistic)',
         first10B='pair B items 4 and 5: the UVM heads and Earlgrey\'s records (map 11\'s first-ten rule, ground-B clusters of the first ten records, optimistic)',
         n0039='both briefs: N0039 goes to the pair whose ground WRITES the differing field (section 5 of this map pins it)')
G = json.load(open(f'{REPO}/tools/probe/r11u222map/evidence/ground_override.json'))
# r11u230: the decodes since map 14 (a pass's decode outranks a pin). Pass 228 (tools/probe/r11u228repro README section
# 5, landed at cd4fd02a while this map ran, measured at this map's base 97343175): struct_param_func_config's first
# records N0817 and the same names N0028 N0761 N0552 are the chain root of ParamEmit makeParamTs memberScope; N0045 and
# N0891 (golden's member annotations under typespec_member) are written by ParamEmit stampEvalFuncLeftovers;
# cfg_func_width_loop's #464 (N0263) is a re-pointing of the elaborated param_assign Rhs's ref_typespec in ParamEmit;
# N0073 (BlackBePipeInt, the folded a+b pattern element's end column) is written in the parameter listing. All ground A;
# each is checked against this edition's writer pin in README section 5.
DEC228 = {c: 'A' for c in ('N0817', 'N0028', 'N0761', 'N0552', 'N0045', 'N0891', 'N0263', 'N0073')}
G.update(DEC228)
# r11u230: N2471 (BlackBePipeInt d/t, a member ref_typespec's full name under the proc-param struct) has N0028's writer
# chain on the default row (TypeEmit buildStructTs < ParamEmit makeParamTs, the name built from the memberScope ParamEmit
# passes): pass 228's reading of N0028 applies (README section 5)
G['N2471'] = 'A'
W = json.load(open(WOV)) if WOV and os.path.exists(WOV) else {}   # this edition's writer grounds (pwsum.py)
# map 14 overrides this edition's writer pins supersede (README section 5): N0039 by both briefs' own rule (the pair
# whose file WRITES the field takes it: ParamEmit predefIntTypespec on the BuildUVMPkg row, ExprEmit emitExpr on the
# probe shape); N0001, whose map-14 basis (OutputSize, TypeEmit emitInitHier) converted with pass 225, its one row left
# (Rggen d) written by ExprEmit emitExpr inside a ModuleEmit generate lambda
SUPERSEDED = ('N0039', 'N0001')
for c in SUPERSEDED:
    if W.get(c) in ('A', 'B'): G[c] = W[c]
g39 = G.get('N0039')
if g39 == 'A': R['pairA']['N0039'] = R['pairA_named']['N0039'] = 'item 1: N0039 (its field writer is on ground A: section 5)'
elif g39 == 'B': R['pairB']['N0039'] = R['pairB_named']['N0039'] = 'item 1: N0039 (its field writer is on ground B: section 5)'
json.dump(R, open(OUT, 'w'), indent=1)
json.dump(G, open(GOV, 'w'), indent=1)
print('pairA', len(R['pairA']), 'pairB', len(R['pairB']), 'ground overrides', len(G), 'N0039 ->', g39)
