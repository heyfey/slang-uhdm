#!/usr/bin/env python3
"""r11u222map (restart at 551c9751): the live pairs pair A r11u224 and pair B r11u223;' brief items mapped to clusters (evidence/routes.json) and the ground overrides
(evidence/ground_override.json = map 13's list + the decodes since). Every entry names the brief item and the pass
README that decoded the cluster's head. `pairX_named` = a cluster a brief item names by its decoded head (the
non-optimistic count); `pairX` = named + the optimistic cluster credits; `pairX_rows` = rows whose whole ground-X half
a brief item names (optimistic: counted fixed whole); the UVM ground-A families (pair A) and map 11's first-ten rule
(pair B, report14.py) are optimistic too.   usage: mkroutes14.py <repo> <routes.json> <ground_override.json>"""
import json, sys
REPO, OUT, GOV = sys.argv[1:4]
A_named = {
 # pair A r11u224 (ExprEmit/EmitHelpers/StmtEmit/ParamEmit; base 551c9751). Its brief: pass 220's residues first (backtick
 # string spans, continued literals in conditionals and class properties, the dot after a :: scope, clone indices the
 # chain law misses, var_select lvalues, new[] indices), pass 215's writer stamp against r11u214's writer law, the UVM A
 # families after pass 220 and the 598 orphaned return subtrees, the carried BlackBePipeInt, FuncStructVal,
 # struct_param_func_config and cfg_func_width_loop faces, a switch-reach table.
 'N0207': 'brief item: pass 220 residue (the path-select naming joining a dot after a :: scope; golden check_data_width::uvm_reg_data_t, ours check_data_width.uvm_reg_data_t)',
 'N0397': 'brief item: pass 220 residue (the dot after a :: scope: end_v::compiled_regex)',
 'N0832': 'brief item: pass 220 residue (the dot after a :: scope: do_bus_access::rw.value[idx][i0 * 8+:8]::value)',
 'N1060': 'brief item: pass 220 residue (the dot after a :: scope, inside a part-select index path)',
 'N2117': 'brief item: pass 220 residue (the dot after a :: scope, probe case r10uvm48repro/t67d)',
 'N2469': 'brief item: pass 220 residue (clone indices the chain law misses: a call as the index, svaunit_vpi_wrapper vpi_vif.sva_exists)',
 'N0555': 'brief item: pass 220 residue (clone indices the chain law misses: a nested select index, arb_sequence_q[[i]])',
 'N0557': 'brief item: pass 220 residue (clone indices the chain law misses: a nested select index)',
 'N0461': 'brief item: pass 220 residue (clone indices the chain law misses: arb_sequence_q::request)',
 'N0215': 'brief item: pass 220 residue (clone indices the chain law misses: arb_sequence_q::SEQ_TYPE_LOCK)',
 'N0192': 'brief item: pass 220 residue (clone path-select names: from_node.m_sync::node)',
 'N0868': 'brief item: carried BlackBePipeInt #15272 (pass 215 residue 9 / r11u218 section 5: golden writes no value for a pattern member whose conditional compares an int member with a string; ParamEmit)',
 'N0897': 'brief item: carried BlackBePipeInt t #66 (the --elabuhdm claim of law pcwElabKeepsClaim207v too broad for the AllPackages listing; ParamEmit)',
 'N1096': 'brief item: carried FuncStructVal #747 (a forward reference spanning the qualifier; r11u218 section 5)',
 'N2472': 'brief item: carried FuncStructVal R2 (the INSTR_PER_FETCH read-site leftovers 618:22)',
 'N2473': 'brief item: carried FuncStructVal R2 (the same objects\' span)',
 'N0739': 'brief item: pass 220 residue 6 (map 13\'s case clusters)', 'N1903': 'brief item: pass 220 residue 6 (map 13\'s case clusters)',
 'N1904': 'brief item: pass 220 residue 6 (map 13\'s case clusters)', 'N0476': 'brief item: pass 220 residue 6 (map 13\'s case clusters)',
 'N0477': 'brief item: pass 220 residue 6 (map 13\'s case clusters)'}
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
 'cfg_func_width_loop': {'modes': None, 'why': 'r11u224 brief: the carried cfg_func_width_loop faces (its A half)'},
 'struct_param_func_config': {'modes': None, 'why': 'r11u224 brief: the carried struct_param_func_config faces (its A half)'},
 'FuncStructVal': {'modes': None, 'why': 'r11u224 brief: the carried FuncStructVal faces'},
 'BlackBePipeInt': {'modes': None, 'why': 'r11u224 brief: the carried BlackBePipeInt faces'}}
B_rows = {
 'cfg_func_width_loop': {'modes': None, 'why': 'pass 216 residue 2 (#464 decoded) with the kept call N0133 / N0487 (map 13 section 10)'},
 'InterfArrayBind': {'modes': None, 'why': 'pass 219 residue 7 (the hand-off InterfArrayBind #183)'}}
# optimistic cluster credits beyond the named heads: the UVM ground-A families are added in report14.py (every ground-A
# cluster whose rows are all UVM rows); nothing else here
A_opt = {c: 'optimistic: the r11u224 brief names the carried cfg_func_width_loop faces; r11u200 decoded its A half (the elaborated formal clone, the folded range), no law; the cluster also carries UVM rows'
         for c in ('N0025', 'N0033', 'N0794', 'N0754')}
R = dict(pairA=dict(A_named, **A_opt), pairB=dict(B_named), pairA_named=A_named, pairB_named=B_named, pairA_rows=A_rows, pairB_rows=B_rows,
         uvm_A_families='pair A brief: the UVM A families (every ground-A cluster whose rows are all UVM rows, optimistic)')
json.dump(R, open(OUT, 'w'), indent=1)
G = json.load(open(f'{REPO}/tools/probe/r11u211map/evidence/ground_override.json'))
G.update({'N0123': 'B', 'N0263': 'B'})   # pass 219 R1 / v11u219 R1 (UhdmExporter formal writer model); pass 216 R2 (#464, module/type ground)
# r11u222 (551c9751): N0427 (InterfArrayBind #183) is ModuleEmit emitContAssigns' shared cont_assign (pass 220 section 6.1:
# the ExprEmit branch already names it right when the listing is re-emitted); N2474 / N2475 (the clone-return case named
# under the importer's own class, r11u218 residue, new at 551c9751) are ParamEmit emitImportedPkgClassMethodClones'
# (law importCloneSharesHomeReturn218), whatever the mint pin says
G.update({'N0427': 'B', 'N2474': 'A', 'N2475': 'A'})
# pass 220 section 6.2: OutputSize's substituted hier_path spans (N0191) and its element spans (N0001) are TypeEmit
# emitInitHier's (the member-init substitution after emitExpr), the '1 fill constant (N0853) ModuleEmit's instance cont_assign
G.update({'N0191': 'B', 'N0001': 'B', 'N0853': 'B'})
# pass 220 section 6.3: struct_param_func_config's first records (the ref_typespec names inside the member typespec and
# the structural #1364) are TypeEmit buildStructTs' (the sister's); map 13 had routed them to ground A. The two
# leftRefFix174 clusters (N0675, N2412, ParamEmit) stay A.
G.update({c: 'B' for c in ('N0028', 'N0045', 'N0552', 'N0761', 'N0817')})
json.dump(G, open(GOV, 'w'), indent=1)
print('pairA', len(R['pairA']), 'pairB', len(R['pairB']), 'rows A', len(A_rows), 'rows B', len(B_rows), 'ground overrides', len(G))
