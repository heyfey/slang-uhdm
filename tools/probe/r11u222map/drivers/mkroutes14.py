#!/usr/bin/env python3
"""r11u222map: the live pairs' brief items mapped to clusters (evidence/routes.json) and the ground overrides
(evidence/ground_override.json = map 13's list + the decodes since). Every entry names the brief item and the pass
README that decoded the cluster's head. `pairX_named` = a cluster a brief item names by its decoded head (the
non-optimistic count); `pairX` = named + the optimistic cluster credits; `pairX_rows` = rows whose whole ground-X half
a brief item names (optimistic: counted fixed whole); the UVM ground-A families (pair A) and map 11's first-ten rule
(pair B, report14.py) are optimistic too.   usage: mkroutes14.py <repo> <routes.json> <ground_override.json>"""
import json, sys
REPO, OUT, GOV = sys.argv[1:4]
A_named = {
 'N0820': 'brief item: anon_struct_packed_dim\'s gx records (pass 212 section 5, pass 215 residue 10): the row\'s only cluster',
 'N0868': 'brief item: pass 215 residue 9 / r11u218 section 5: BlackBePipeInt d #15272, golden writes no value for a pattern member whose conditional compares an int member with a string (ParamEmit)',
 'N0897': 'brief item: pass 215 residue 9: BlackBePipeInt t #66, the --elabuhdm claim of law pcwElabKeepsClaim207v too broad for the AllPackages listing (ParamEmit)',
 'N1096': 'brief item: pass 215 residue 10 (FuncStructVal R4 #747, r11u218 section 5: a forward reference spanning the qualifier; no strict grid possible)',
 'N2472': 'brief item: pass 215 residue 10 (FuncStructVal R2, the four INSTR_PER_FETCH read-site leftovers 618:22; r11u217: pass 210 dropped their file)',
 'N2473': 'brief item: pass 215 residue 10 (FuncStructVal R2, the same objects\' span)',
 'N0685': 'brief item: pass 215 residue 10 (the UVM_MACRO_* names in class copies)',
 'N0109': 'brief item: pass 215 residue 10 (the foreach spans; StmtEmit foreachClassPropStringVar22)',
 'N0110': 'brief item: pass 215 residue 10 (the foreach spans)',
 'N0197': 'brief item: pass 215 residue 10 (the foreach spans; StmtEmit foreachAssocIdxAliasTs22)',
 'N0408': 'brief item: pass 215 residue 10 (the foreach spans; StmtEmit cloneLoopVarShared37)',
 'N0739': 'brief item: pass 215 residue 10 (map 13\'s case clusters)', 'N1903': 'brief item: pass 215 residue 10 (map 13\'s case clusters)',
 'N1904': 'brief item: pass 215 residue 10 (map 13\'s case clusters)', 'N0476': 'brief item: pass 215 residue 10 (map 13\'s case clusters)',
 'N0477': 'brief item: pass 215 residue 10 (map 13\'s case clusters)'}
B_named = {
 'N0123': 'brief item 1: typedef int UVM_FILE, the scalar-typedef formal writer (pass 219 residue 1, v11u219 residue 1: UhdmExporter law tfArgClassMethodOrder176 admits only enum and aggregate typedefs)',
 'N0318': 'brief item 1 (the same scalar-typedef formal-writer model): MiniAmiq/SeqDriver uvm_reg_cvr_t, a bit typedef golden relocates to the class method formal uvm_reg.svh 1861:41 (ours at its declaration uvm_reg_model.svh 105:10); the first open record of MiniAmiq/SeqDriver after r11u218',
 'N0516': 'brief item: the svaunit clone names (golden uvm_pkg::uvm_object::..., ours svaunit_pkg::...)', 'N0521': 'brief item: the svaunit clone names',
 'N0481': 'brief item: the svaunit clone names', 'N0550': 'brief item: the svaunit clone names',
 'N0565': 'brief item: the writer rule\'s remaining faces (SimpleUVM work@env:: vs work@top.: a $unit class writing last, pass 215 residue 1)',
 'N2464': 'brief item: the writer rule\'s remaining faces (the same prefix on the bit typedef member alias)',
 'N0121': 'brief item: the writer rule\'s remaining faces (pass 216 residue 3: the partially modelled enum listings, uvm_radix_enum ...)',
 'N0144': 'brief item: the writer rule\'s remaining faces (pass 216 residue 3: uvm_active_passive_enum at the declaration)',
 'N0321': 'brief item: the writer rule\'s remaining faces (pass 216 residue 3, under class_defn)',
 'N0263': 'brief item: pass 216 residue 2 / pass 219 residue 6: cfg_func_width_loop #464 decoded (the elaborated function formal\'s clone of the typedef), also MiniAmiq/SeqDriver uvm_hdl_data_t',
 'N0262': 'brief item: pass 219 residue 7 (the sister\'s hand-off: importPaCopy82\'s UVM_MACRO_NUMFLAGS copies)',
 'N0008': 'brief item: pass 219 residue 5 (N0008, the design param_assign\'s right side as compiled)',
 'N0427': 'brief item: pass 219 residue 7 (the sister\'s hand-off: InterfArrayBind #183; pass 210 called it this ground\'s, pass 216 the sister\'s)',
}
A_rows = {
 'OutputSizeWithParameterOfInstanceInitializedByStructMember': {'modes': None, 'why': 'the joint rows\' A halves (pass 215 residue 10: OutputSize, never attempted)'},
 'cfg_func_width_loop': {'modes': None, 'why': 'the joint rows\' A halves (pass 215 residue 10; decoded by r11u200, no law)'},
 'struct_param_func_config': {'modes': None, 'why': 'pass 215 residue 10 (decoded by r11u200, no law)'},
 'FuncStructVal': {'modes': None, 'why': 'the joint rows\' A halves (pass 215 residue 10)'},
 'BlackBePipeInt': {'modes': None, 'why': 'the joint rows\' A halves (pass 215 residue 9)'},
 'Scr1SvTests': {'modes': None, 'why': 'the joint rows\' A halves (behind the Surelog defect N0791)'},
 'Earlgrey_0_1': {'modes': None, 'why': 'the joint rows\' A halves (r11u218 residue 1: Earlgrey\'s new heads)'},
 'Rggen': {'modes': None, 'why': 'the joint rows\' A halves'}}
B_rows = {
 'cfg_func_width_loop': {'modes': None, 'why': 'pass 216 residue 2 (#464 decoded) with the kept call N0133 / N0487 (map 13 section 10)'},
 'InterfArrayBind': {'modes': None, 'why': 'pass 219 residue 7 (the hand-off InterfArrayBind #183)'}}
# optimistic cluster credits beyond the named heads: the UVM ground-A families are added in report14.py (every ground-A
# cluster whose rows are all UVM rows); nothing else here
A_opt = {c: 'optimistic: pass 215 residue 10 names cfg_func_width_loop; r11u200 decoded its A half (the elaborated formal clone, the folded range), no law; the cluster also carries UVM rows'
         for c in ('N0025', 'N0033', 'N0794', 'N0754')}
R = dict(pairA=dict(A_named, **A_opt), pairB=dict(B_named), pairA_named=A_named, pairB_named=B_named, pairA_rows=A_rows, pairB_rows=B_rows,
         uvm_A_families='pair A brief: the UVM A families (every ground-A cluster whose rows are all UVM rows, optimistic)')
json.dump(R, open(OUT, 'w'), indent=1)
G = json.load(open(f'{REPO}/tools/probe/r11u211map/evidence/ground_override.json'))
G.update({'N0123': 'B', 'N0263': 'B'})   # pass 219 R1 / v11u219 R1 (UhdmExporter formal writer model); pass 216 R2 (#464, module/type ground)
json.dump(G, open(GOV, 'w'), indent=1)
print('pairA', len(R['pairA']), 'pairB', len(R['pairB']), 'rows A', len(A_rows), 'rows B', len(B_rows), 'ground overrides', len(G))
