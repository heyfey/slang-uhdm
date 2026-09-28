#!/usr/bin/env python3
"""r11u211: the live pairs' brief items mapped to clusters (OPTIMISTIC coverage, map 12's rule): pair A r11u207
(ExprEmit/EmitHelpers/StmtEmit/ParamEmit, base 3668bf30) and pair B r11u209 (TypeEmit/ModuleEmit/UhdmExporter/
TaskFuncEmit/uhdm_main, base 6e39a3fc). Map 12's own pair routes are carried where the new brief names the same
item (the pass 201 / pass 206 residue lists carry them: r11u201repro section 7 item 10, r11u206repro section 6 / 7
item 9). Writes evidence/routes.json.  Args: <map12 routes.json> <out routes.json>"""
import json, sys
M12 = json.load(open(sys.argv[1]))
A = {}; B = {}
def add(d, ids, why):
    for c in ids.split():
        d.setdefault(c, why)
# ---- pair A r11u207
add(A, 'N0540 N0689', "map 12's UVM heads (N0540 MiniAmiq/SeqDriver, N0689 SimpleUVM/Scoreboard: a class typedef's ref name in a module-imported package copy; ParamEmit emitPackage)")
add(A, 'N0923', 'BlackBePipeInt N0923 (the brief names it; map 12 did not route it: an identity family of per-use typespec copies, OPTIMISTIC)')
add(A, 'N0016', "the A half the sister needs: UnitElabBlock's implicit-net file (ExprEmit vlogHiddenBlockVars; r11u205 law hiddenBlockVarNetNoFile205, MEASURED here too)")
add(A, 'N0416 N0779 N0836 N1069 N1119', "the A half the sister needs: Scr1SvTests' bound and ground-A names (OPTIMISTIC: the row's structural record N0791 is a Surelog defect)")
add(A, 'N0682', 'pass 201 section 7 item 2: the UVM_MACRO_* package-parameter ref_typespec full names (ParamEmit makeParamTs), SimpleUVM / Scoreboard first record')
add(A, 'N0189', 'pass 201 section 7 item 2: BuildUVMPkg #5639 (a constant argument located at another call)')
add(A, 'N0263 N0025 N0033 N0754 N0794', "pass 201 section 7 item 6: cfg_func_width_loop's evaluator formal-typespec stamp and A names (decoded by r11u200, no law)")
add(A, 'N0028 N0045 N0552 N0675 N0761 N0817 N2412', "pass 201 section 7 item 7: struct_param_func_config's copy names through the chain root (decoded, no law; golden holds five differently named copies)")
add(A, 'N0427', 'pass 201 section 7 item 10 (carried): InterfArrayBind (r11u205 law elabIfArrIdxChainName205 MEASURED reaches one of its two shapes)')
add(A, 'N0086 N0087 N0131 N0407 N0980 N1096 N1946 N0891', 'pass 201 section 7 item 10 (carried): FuncStructVal / FuncStructValSimple (map 12 route: pass 198 R8 / pass 195 R10)')
add(A, 'N0820', 'pass 201 section 7 item 10 (carried): anon_struct_packed_dim N0820 (the 4 ExprEmit records)')
add(A, 'N0003 N0763 N0957 N0971 N0979', "pass 201 section 7 item 10 (carried): ibex_tracer's A half (case-item references to wildcard-imported parameters, ParamEmit ranges)")
add(A, 'N0001 N0191', "map 12 pair-A route carried: OutputSize...'s A half (the hier_path Info.x spans)")
add(A, 'N0290 N0098 N0303 N0304 N0305 N0306 N0050 N0123 N0297 N0314 N0326 N0352 N0374 N0375 N0387 N0390 N0392 N0397 N0399',
    "the UVM ground-A families (map 12 section 9 A4: the 7-row A clusters)")
# map 12's pair-A routes carried only where the r11u207 brief names the item again (pass 201's residue list, section 7
# items 2, 6, 7, 10; the UVM ground-A families): the routes of rows converted since (arb_idx_cast, func_typename_ret,
# rsp_gen_minimal, SVSwitch) and Earlgrey's A2 route (not in this brief) are dropped.
CARRY_A = ('N0217 N0175 N0220 N0682 N0045 N0675 N2412 N0028 N0552 N0761 N0817 N0754 N0794 N0263 N0025 N0033 '
           'N0779 N0836 N1069 N1119 N0416 N0189 N0097 N0012 N0034 N0207 N0054 N0197 N0222 N0225 N0227 N0234 N0235 N0237 '
           'N0238 N0247 N0252 N0253 N2400 N2401 N0820 N0086 N0087 N0131 N0407 N0891 N0980 N1096 N0427 N0191 N0001 N0016 '
           'N0763 N0957 N0971 N0979 N0003 N0192 N0196 N0199 N0183 N0071 N0109 N0110 N0185 N0193 N0061 N0119 N0152 N0153 '
           'N0178 N0179 N0160 N2411').split()
for c, why in M12['pairA'].items():
    if c in CARRY_A: add(A, c, 'map 12 pair-A route carried: ' + why)
# r11u201 section 7 item 4: Rggen's N0145 is ground B (TypeEmit emitSyntaxExpr's path branches), not ExprEmit as map 11 had it
A.pop('N0145', None)
# ---- pair B r11u209
add(B, 'N0144', "MiniAmiq #899 by Surelog's compile order (the uvm_severity enum typedef file; r11u205 4.3's writer family)")
add(B, 'N0039', "BuildUVMPkg #3245 by Surelog's compile order (the uvm_action int typedef copy at a use; r11u205 4.3)")
add(B, 'N0014', 'pass 206 R2: anon_struct_packed_dim (39 of 43 records: the $unit struct re-parented at the last member using it)')
add(B, 'N0519 N1117 N1126 N1128 N1134', 'pass 206 R3: InterfaceStructMemberPort (modport io_decl nets without a full name; ModuleEmit emitInterfaceInstance)')
add(B, 'N1174', 'pass 206 R4: HierPathTypespec t (the per-use elaboration clone of the typedef; OPTIMISTIC: the naming-context face)')
add(B, 'N0133 N0487', "pass 206 section 6 (4): cfg_func_width_loop's kept q::maxw(M) call in the elaborated cont_assign (ModuleEmit; r11u205 read it covered from the tool's first records, but the record sits past the walk divergence)")
add(B, 'N0853 N1127', "pass 206 section 6 (4): OutputSize...'s B half (map 12 route carried)")
add(B, 'N0563', "pass 206 section 6 (4): ibex_tracer's B half (the :: separators of package-parameter struct copies)")
add(B, 'N0145 N1249', "pass 206 section 6 (2): Rggen's indexed part select names (N1249: r11u205 law defGenTargetIpsDefName205, MEASURED; N0145 the same object's name facet)")
add(B, 'N0288 N0121 N0262 N0318 N0321 N0337 N0266 N0043 N0078 N0426 N0974',
    "the UVM ground-B families (map 12 section 9 B6: the 7-row and 6-row B clusters)")
# map 12's pair-B routes carried only where the r11u209 brief names the item again (pass 206's residues and its
# section-6 not-attempted list; the UVM ground-B families): InterfaceModPort's N0040 (the harness flag, not in the
# brief), the converted rows' routes (arb_idx_cast N0090 N0448, UnitElabBlock N0011) and the r11u200 away keys are dropped.
CARRY_B = ('N0144 N0039 N0133 N0487 N0067 N0068 N0180 N0158 N0177 N0184 N0188 N0423 N0117 N0120 N0213 N0230 N0232 N0254 '
           'N0255 N0256 N0072 N0103 N0051 N0161 N0170 N0171 N0757 N0327 N0853 N1127 N0519 N1117 N1126 N1128 N1134 N0563 '
           'N0014 N1174 N0219 N0023 N0738 N0031 N0042 N0132').split()
for c, why in M12['pairB'].items():
    if c in CARRY_B: add(B, c, 'map 12 pair-B route carried: ' + why)
out = dict(pairA=A, pairB=B, pairA_rows={}, pairB_rows={},
           pairB_first_records=M12['pairB_first_records'].replace('r11u200', 'r11u205'),
           unmapped=['pair A: r11u205 law_exprstmt.patch: MEASURED (the law205 binary; pair A r11u210 will land it), not a route',
                     'pair B: r11u205 law_typeemit.patch minus its superseded first law: MEASURED (the law205 binary; pair B r11u209 lands it first), not a route',
                     "pair B: the r11u204 twin helper's determinism fix (pass 206 R1): reader-invisible, no strict cluster",
                     'pair B: pass 206 R5 (definition-view generate-block class locals), R6 (TE/e17), R7 (V2), r11u204 B3/B4/N5-N9: evidence cases and downstream faces, no gate row',
                     'pair A: r11u204 ground-A residues (N1-N4, N6, N10), pass 201 items 8-9 (value encodings, the --elabuhdm operator stamp): evidence cases',
                     "pair B: Scr1SvTests' structural record N0791 (a Surelog binding defect, r11u200 3d), PreprocTest N0056 (.vh face, not implementable), LogicTypespec (a user decision): NOT routed"])
json.dump(out, open(sys.argv[2], 'w'), indent=1)
print('pairA', len(A), 'pairB', len(B))
