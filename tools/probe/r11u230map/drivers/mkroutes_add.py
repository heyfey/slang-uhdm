#!/usr/bin/env python3
"""r11u230map addendum (9c9c11d6: passes 228 and 227 landed while this map ran): the NEW live pairs, pair A r11u232
(ExprEmit/EmitHelpers/StmtEmit/ParamEmit, base 9c9c11d6) and pair B r11u231 (TypeEmit/ModuleEmit/UhdmExporter/
TaskFuncEmit/uhdm_main, base cd4fd02a), their brief items mapped to clusters exactly as mkroutes15.py does for the pairs
this map was briefed on (named = a cluster the brief names by id or decoded head; row credits = rows whose whole
ground-X half a brief item names; the UVM / Earlgrey families and map 11's first-ten rule optimistic).
usage: mkroutes_add.py <routes.json> [<writer_ground.json>]"""
import json, sys, os
OUT = sys.argv[1]; WOV = sys.argv[2] if len(sys.argv) > 2 else None
A_named = {
 # r11u232 item (1): the joint rows start on ground A (pass 228's measurement)
 'N0817': 'item 1: struct_param_func_config #759 (ParamEmit makeParamTs memberScope)', 'N0028': 'item 1: the same names',
 'N0761': 'item 1: the same names', 'N0552': 'item 1: the same names',
 'N0045': 'item 1: annotations of ParamEmit stampEvalFuncLeftovers', 'N0891': 'item 1: annotations of ParamEmit stampEvalFuncLeftovers',
 'N0675': 'item 1: struct_param_func_config', 'N2412': 'item 1: struct_param_func_config',
 'N0263': 'item 1: cfg_func_width_loop #464 (the elaborated param_assign Rhs re-pointing, ParamEmit)',
 'N0025': 'item 1: cfg_func_width_loop', 'N0033': 'item 1: cfg_func_width_loop', 'N0754': 'item 1: cfg_func_width_loop', 'N0794': 'item 1: cfg_func_width_loop',
 'N2472': 'item 1: FuncStructVal #4782 (the INSTR_PER_FETCH leftover)', 'N2473': 'item 1: FuncStructVal #4782',
 'N0980': 'item 1: FuncStructVal', 'N1946': 'item 1: FuncStructVal',
 'N0868': 'item 1: BlackBePipeInt #15268 / #15272',
 # item (5) map 14's remaining ground-A clusters, item (6) carried
 'N0131': 'item 5: N0131', 'N0812': 'item 5: the Earlgrey_0_1 scope names (N0812)', 'N0008': 'item 6: N0008'}
B_named = {
 'N0266': 'item 1b: UVM_SEQ_ARB_TYPE', 'N0337': 'item 1c: this_type (SimpleUVM / Scoreboard)', 'N0072': 'item 1c: this_type (BuildUVMPkg)',
 'N0120': 'item 2: N0120'}
A_rows = {t: {'modes': None, 'why': f'r11u232 item 1: the {t} A half'} for t in ('FuncStructVal', 'struct_param_func_config', 'cfg_func_width_loop', 'BlackBePipeInt')}
B_rows = {}   # r11u231 item 5: the joint rows only if their first record is on ground B (none is at 9c9c11d6)
R = dict(pairA=dict(A_named), pairB=dict(B_named), pairA_named=A_named, pairB_named=B_named, pairA_rows=A_rows, pairB_rows=B_rows,
         tags={'pairA': 'r11u232', 'pairB': 'r11u231'},
         uvm_A_families='r11u232 item 6: the UVM A families', earl_A_family='r11u232 item 5: the Earlgrey scope names',
         first10B='r11u231 items 1 and 4: the UVM heads and Earlgrey ground-B families (first-ten rule, optimistic)')
W = json.load(open(WOV)) if WOV and os.path.exists(WOV) else {}
if W.get('N0039') == 'A': R['pairA']['N0039'] = R['pairA_named']['N0039'] = 'item 5: N0039 (its field writer is ExprEmit)'
elif W.get('N0039') == 'B': R['pairB']['N0039'] = R['pairB_named']['N0039'] = 'N0039 (its field writer is on ground B)'
json.dump(R, open(OUT, 'w'), indent=1)
print('pairA', len(R['pairA']), 'pairB', len(R['pairB']))
