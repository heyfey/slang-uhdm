# r11u476: interface udp-shaped instantiations, the FILE macro column shift, and clones reached through a provider package

Pass 476, the module/type ground (ModuleEmit, UhdmExporter, TypeEmit), the thirty-eighth pass of
the sv-tests campaign on this ground. Base e6f5d904f. The implementer's report.

## Verdicts on the target rows

| row | base (master's control /tmp/intr11u474) | law binary |
|---|---|---|
| generated/easyUVM/top.sv | DIFFERENT (uhdm-cmp 60 lines) | **EQUAL** (uhdm-cmp 0, STRICT_EQUAL; downstream reading of the runner IDENTICAL) |
| generated/uvm-examples/uvm_param_vif_config_db.sv | DIFFERENT (uhdm-cmp 46 lines, the sister's param_assign face) | DIFFERENT (46 lines, the same sister face first) |

easyUVM converts DIFFERENT -> EQUAL through § ifaceUdpShapedNoRefMod476,
§ ifaceUdpShapedLowConnDecl476 and § fileMacroLenNormal476. On the law binary with only the first
two laws (law1), the row read uhdm-cmp 0 and STRICT_NOTEQUAL endcol(10): the FILE macro face that
pass 477 described as a residue. With the third law (law3) it reads EQUAL.

uvm_param_vif_config_db still stops at the sister's face: ParamEmit's emitParameters writes the
param_assign right side of a named `.A(K::w)` override as a folded constant. Behind that face, the
strict walk on a copy of the database with that face simulated (pass 474's
evidence/tools/addpa.cpp, a measurement only) moved as follows:

| binary | first walk divergence | objects (golden 1002258) |
|---|---|---|
| pristine | #138364, uvm_misc.svh 103 (`pos` in uvm_instance_scope) | 994575 |
| law (final) | #201344, uvm_reg_map.svh 2034 (`accesses[i0].data`, a typespec_member face) | 1002253 |

The remaining strict fields before that divergence are face (d) below: the ref_typespec under
set_arbitration's formal `val`, now at two positions (#93329 and #165115).

## The laws

Every law is read through src/LawSwitch.h with `lawOn(476, ...)`. `R11U476_OFF` drops all of
them. `R11U476_TRACE=<dir>` logs each firing.

1. **§ ifaceUdpShapedNoRefMod476** (ModuleEmit; `R11U476_IFUDPREF_OFF`). Surelog's grammar
   tries udp_instantiation before module_instantiation. An ordered list of two or more terminals
   whose first terminal is a net_lvalue (EmitHelpers.h udpShapedInstantiation) is therefore a
   udp_instantiation whatever the child is. CompileModule routes it to compileUdpInstantiation,
   and that never builds a ref_module. The definition view already skipped such MODULE children;
   INTERFACE children were exempt and kept their ref_module. Golden `a_if in(clk, rst)`: no
   ref_module. Golden `a_if u(clk)`: one. Cases IU/iu01 to iu05, iu12, iu14 to iu16; controls
   iu06 to iu11.
2. **§ ifaceUdpShapedLowConnDecl476** (ModuleEmit emitInterfaceInstance; `R11U476_IFUDPLOW_OFF`).
   This is the elaborated twin of the module rule in emitInstance. A udp-shaped instantiation
   never ran compileHighConn, so UhdmWriter::writeNets builds the LowConn ref_obj from the
   definition's net node, which is the interface's port declaration. Golden puts it at 2:22,
   ours put it at the actual, 8:11. Cases IU (iu13, a generate block, moves by this law alone).
3. **§ fileMacroLenNormal476** (UhdmExporter, two sites; `R11U476_FILELEN_OFF`). This is the
   layout twin of the sister's § fileMacroPathNormal477. Surelog splices FileSystem::toPath of
   the file id, a lexically normal path. So the tokens after a `__FILE__` expansion shift by the
   length of the normal literal, not by the length of slang's buffer name as the include
   resolved it. The two sites:
   - buildMacroExpansions: the rawLen of the intrinsic's argument-kind buffer. This governs a
     `__FILE__` written in plain code (FN/fn01, fn03, fn07 control).
   - The pass-166 preprocessor model's `__FILE__` text (cx.topFile). This governs a `__FILE__`
   inside a macro body (FN/fn02, fn04, fn06; fn05 control). It is easyUVM's env.sv line 119,
   reached through `include "./env.sv"`, where uvm_message_defines.svh 119 and 155 read golden's
   columns.
4. **§ cloneViaProviderTopClone476** (TypeEmit cloneStmtHomeVarRef17 and reHomeLateDrain476, and
   UhdmExporter's § cloneMintParentHomeCall253 home call; `R11U476_CLONEPROVIDER_OFF`). Surelog's
   importPackage clones a subroutine from the IMPORTED package's elaborated view. Take a package
   P that reaches the home H only through another package M: M is the first of P's body imports,
   in written order, that offers the subroutine (H itself, or a package whose TOP view holds a
   clone of it). Such a P copies M's TOP-view clone. clone_tree keeps every pointer of the source
   that it does not re-resolve. The decode, with each face's golden reading:
   - A body reference to a body local binds M's clone's variable.
     - CC/cc01: golden t::f's `y` reads a::f::y; ours read u::f::y.
   - A reference already bound to H's variable moves to M's twin.
     - CC/cc09: a for-init variable, after § cloneForIncBindsHomeVar238's design-final binding.
     - This is done in the late drain, which runs after drainPaNameCopySrc38.
   - Kept on H's variable:
     - The clone's ref_var entries (CC/cc13's `process p`).
     - A plain-assignment for-init Lhs (CC/cc11).
     - Every element of a dotted read with two or more elements that is bound to a body local.
       In golden's tb_params_pkg, 847 hier_path bases bound to locals read uvm_pkg[top];
       `t.args = args;` keeps `.args` on uvm_pkg[top].
   - Bound to M's own object (golden, cc10 and the row):
     - A formal or a clone-own variable (TF-ITEM locals) that is read as an element of a dotted
       read: `s.len()`, `m_type_overrides[index].replace`, `p_.get_randstate()`.
     - The array of a foreach when it is a formal: `foreach (stream[i])`.
   - A reference to a foreach loop variable binds M's loop-variable declaration (CC/cc12).
     - Not a dotted base (`pred.m_successors[...]`).
     - Not an argument that § hierCallArgTakesBase39 or § cloneBuiltinMethodArgBindsReceiver184
       handed the receiver's binding; these are recognised by the reference's name differing
       from the variable's.
   - § cloneMintParentHomeCall253's element-variable mint is parented under M's call
     (`visited.exists(succ)` in uvm_phase::sync). Golden's full name is
     sfr_agent_pkg::uvm_phase::sync::visited.exists::succ.
   - A class method copied as a package listing entry (the out-of-body group, § 452) takes the
     package around its class as its home.

   The law is read together with the earlier switches of the laws it extends:
   - `R11U253_TFITEMOWN_OFF`, `R11U247_HOMEVARDUP_OFF` and `R11U253_MINTHOME_OFF` gate the
     pairings it re-targets.
   - § cloneStmtHomeVarRef17 itself has no switch.
5. **§ cloneForInitHomeVar476** (TypeEmit cloneStmtHomeVarRef17; `R11U476_FORINITHOME_OFF`).
   A for loop's declared init variable is listed nowhere (§ cloneForInitVarBind204). This law
   lets it join the clone/home pairing as a body local, so that § cloneViaProviderTopClone476
   can move it. It enters only the provider pairing. It is never in the own-to-home remap or the
   § 247 remap, because its home binding is § cloneForIncBindsHomeVar238's. Case CC/cc09; with
   this switch alone, cc09 and cc10 move off the law's bytes.

**Pass 474's finding, fixed.** § cloneValFormalUnnamed474 now reads its switch
`R11U474_CLONEPARNAME_OFF` before the parameter's full-name getter, which stores a computed name.
No byte change is expected with the law on. The checks: the r11u474 and v11u474 case dirs are
part of the away census below, and R11U476_OFF does not touch this site.

The no-header audit:
- No src/R*.h, no LawState.h section, no getenv, and no header change.
- The late drain and the provider lookup are free functions in TypeEmit.cpp, declared locally in
  UhdmExporter.cpp, as clsScopedRangeNames474 is.
- New bookkeeping lives in function-local statics (side maps), cleared per export.
- ParamEmit, ExprEmit, StmtEmit, EmitHelpers.h, TaskFuncEmit, include/ and uhdm_main.cpp are
  unchanged.

## Grid (cases/, 37 dirs; drivers/grid.sh, drivers/runcase.sh; evidence/grid_*.txt)

Every case is accepted by upstream slang (`~/.local/bin/slang dut.sv --single-unit`, rc 0 on 37 of
37). Every exit code is 0 on both binaries. The first line of each case names its law. Columns:
pristine reading -> law reading (exit code, uhdm-cmp lines, strict verdict, objects or dump
distance).

```
CC/cc01 rc=0 cmp=0 STRICT_NOTEQUAL depth -> rc=0 cmp=0 STRICT_EQUAL 204 
CC/cc02 rc=0 cmp=0 STRICT_NOTEQUAL depth -> rc=0 cmp=0 STRICT_EQUAL 394 
CC/cc03 rc=0 cmp=0 STRICT_NOTEQUAL depth -> rc=0 cmp=0 STRICT_EQUAL 487 
CC/cc04 rc=0 cmp=0 STRICT_NOTEQUAL depth -> rc=0 cmp=0 STRICT_EQUAL 482 
CC/cc05 rc=0 cmp=0 STRICT_EQUAL 201 -> rc=0 cmp=0 STRICT_EQUAL 201 
CC/cc06 rc=0 cmp=0 STRICT_NOTEQUAL depth -> rc=0 cmp=0 STRICT_EQUAL 394 
CC/cc07 rc=0 cmp=0 STRICT_EQUAL 385 -> rc=0 cmp=0 STRICT_EQUAL 385 
CC/cc08 rc=0 cmp=0 STRICT_NOTEQUAL depth -> rc=0 cmp=0 STRICT_EQUAL 384 
CC/cc09 rc=0 cmp=0 STRICT_NOTEQUAL depth -> rc=0 cmp=0 STRICT_EQUAL 312 
CC/cc10 rc=0 cmp=0 STRICT_NOTEQUAL depth -> rc=0 cmp=0 STRICT_EQUAL 353 
CC/cc11 rc=0 cmp=0 STRICT_NOTEQUAL depth -> rc=0 cmp=0 STRICT_EQUAL 385 
CC/cc12 rc=0 cmp=22 NOT_EQUAL stage1 -> rc=0 cmp=0 STRICT_EQUAL 252 
CC/cc13 rc=0 cmp=29 NOT_EQUAL stage1 -> rc=0 cmp=0 STRICT_NOTEQUAL depth dd=104
FN/fn01 rc=0 cmp=0 STRICT_NOTEQUAL endcol -> rc=0 cmp=0 STRICT_EQUAL 13 
FN/fn02 rc=0 cmp=0 STRICT_NOTEQUAL endcol -> rc=0 cmp=0 STRICT_EQUAL 17 
FN/fn03 rc=0 cmp=0 STRICT_NOTEQUAL endcol -> rc=0 cmp=0 STRICT_EQUAL 13 
FN/fn04 rc=0 cmp=0 STRICT_NOTEQUAL endcol -> rc=0 cmp=0 STRICT_EQUAL 19 
FN/fn05 rc=0 cmp=0 STRICT_EQUAL 17 -> rc=0 cmp=0 STRICT_EQUAL 17 
FN/fn06 rc=0 cmp=0 STRICT_NOTEQUAL endcol -> rc=0 cmp=0 STRICT_EQUAL 27 
FN/fn07 rc=0 cmp=0 STRICT_EQUAL 13 -> rc=0 cmp=0 STRICT_EQUAL 13 
IU/iu01 rc=0 cmp=135 NOT_EQUAL stage1 -> rc=0 cmp=0 STRICT_EQUAL 51 
IU/iu02 rc=0 cmp=135 NOT_EQUAL stage1 -> rc=0 cmp=0 STRICT_EQUAL 51 
IU/iu03 rc=0 cmp=135 NOT_EQUAL stage1 -> rc=0 cmp=0 STRICT_EQUAL 51 
IU/iu04 rc=0 cmp=187 NOT_EQUAL stage1 -> rc=0 cmp=0 STRICT_EQUAL 68 
IU/iu05 rc=0 cmp=135 NOT_EQUAL stage1 -> rc=0 cmp=0 STRICT_EQUAL 39 
IU/iu06 rc=0 cmp=0 STRICT_EQUAL 47 -> rc=0 cmp=0 STRICT_EQUAL 47 
IU/iu07 rc=0 cmp=0 STRICT_EQUAL 47 -> rc=0 cmp=0 STRICT_EQUAL 47 
IU/iu08 rc=0 cmp=0 STRICT_EQUAL 47 -> rc=0 cmp=0 STRICT_EQUAL 47 
IU/iu09 rc=0 cmp=0 STRICT_EQUAL 69 -> rc=0 cmp=0 STRICT_EQUAL 69 
IU/iu10 rc=0 cmp=0 STRICT_EQUAL 43 -> rc=0 cmp=0 STRICT_EQUAL 43 
IU/iu11 rc=0 cmp=0 STRICT_EQUAL 76 -> rc=0 cmp=0 STRICT_EQUAL 76 
IU/iu12 rc=0 cmp=135 NOT_EQUAL stage1 -> rc=0 cmp=0 STRICT_EQUAL 67 
IU/iu13 rc=0 cmp=0 STRICT_NOTEQUAL line -> rc=0 cmp=0 STRICT_EQUAL 58 
IU/iu14 rc=0 cmp=199 NOT_EQUAL stage1 -> rc=0 cmp=36 NOT_EQUAL stage1 dd=20
IU/iu15 rc=0 cmp=191 NOT_EQUAL stage1 -> rc=0 cmp=0 STRICT_EQUAL 63 
IU/iu16 rc=0 cmp=312 NOT_EQUAL stage1 -> rc=0 cmp=0 STRICT_EQUAL 102 
IU/iu17 rc=0 cmp=0 STRICT_EQUAL 94 -> rc=0 cmp=0 STRICT_EQUAL 94 
```

The cases by group and law:
- CC: § cloneViaProviderTopClone476; cc09 is § cloneForInitHomeVar476.
  - Moved, as the switch table below shows: cc01 to cc04, cc06, cc08 to cc13.
  - Controls: cc05 is an explicit import of a class only; cc07 imports the home first.
- FN: § fileMacroLenNormal476.
  - Controls: fn05 is an already normal path in a macro; fn07 is a top file.
- IU: § ifaceUdpShapedNoRefMod476 and § ifaceUdpShapedLowConnDecl476.
  - Controls:
    - iu06 to iu08: one terminal.
    - iu09: named connections.
    - iu10: a module child, already handled.
    - iu11: an operation as the first terminal, a module_instantiation.
    - iu17: a bind instantiation, the verifier-style break caught by the away census; see Gates.
  - Movers:
    - iu01 to iu05 and iu12: the udp shape.
    - iu13: a generate block, lowConn only.
    - iu15: an output port.
    - iu16: an interface passed on to a submodule.
    - iu14: a multi-instance statement, residue 2.

Totals: STRICT_EQUAL 14 of 37 on pristine and 34 of 37 on the law binary. iu14 is NOT_EQUAL at
36 lines (199 on pristine). cc13 is STRICT_NOTEQUAL depth (NOT_EQUAL 29 on pristine).

Switch checks (evidence/grid_switches.txt):

```
dirs 37 R11U476_OFF==pristine 37 law!=pristine 26
R11U476_IFUDPREF_OFF moves off the law: IU/iu01 IU/iu02 IU/iu03 IU/iu04 IU/iu05 IU/iu12 IU/iu14 IU/iu15 IU/iu16 | of them back to pristine: 
R11U476_IFUDPLOW_OFF moves off the law: IU/iu01 IU/iu02 IU/iu03 IU/iu04 IU/iu05 IU/iu12 IU/iu13 IU/iu14 IU/iu15 IU/iu16 | of them back to pristine: IU/iu13
R11U476_FILELEN_OFF moves off the law: FN/fn01 FN/fn02 FN/fn03 FN/fn04 FN/fn06 | of them back to pristine: FN/fn01 FN/fn02 FN/fn03 FN/fn04 FN/fn06
R11U476_CLONEPROVIDER_OFF moves off the law: CC/cc01 CC/cc02 CC/cc03 CC/cc04 CC/cc06 CC/cc08 CC/cc09 CC/cc10 CC/cc11 CC/cc12 CC/cc13 | of them back to pristine: CC/cc01 CC/cc02 CC/cc03 CC/cc04 CC/cc06 CC/cc08 CC/cc09 CC/cc10 CC/cc11 CC/cc12 CC/cc13
R11U476_FORINITHOME_OFF moves off the law: CC/cc09 CC/cc10 | of them back to pristine: 
```

R11U476_OFF gives pristine's bytes and exit code on 37 of 37 dirs. Each switch alone moves
exactly its own law's dirs. FILELEN and CLONEPROVIDER return all of their own dirs to pristine.
IFUDPREF and IFUDPLOW each take back their own half on the shared IU dirs; iu13 needs only
IFUDPLOW. FORINITHOME alone moves cc09 and cc10 off the law's bytes, and they stay away from
pristine because the provider law still acts.

## Gates

One full five-stage sweep on the final law binary
`/tmp/r11u476_bin/slang-uhdm.law27` (md5 8b59c2a66cda09cfb5aac611789ea29d, slang
12.0.0+545f88b2e):
- Run with R11U476_TRACE on.
- Workdir /tmp/r476lawswp, the same length as the master's control /tmp/intr11u474.
- Probe, surelog, uhdm2rtlil and downstream were run through this worktree's tests/sweep.sh.
- sv-tests was run through the main tree's scripts/check_svtests.py with
  `--baseline <worktree>/results/golden_svtests.csv`, the base's golden. This worktree's UVM
  folder is empty.
- The sweep was launched only on a quiet machine. It waited for the master's pass 481 landing
  sweep and for r11u483's census runner.

The stage readings (evidence/sweep_corpus.log, sweep_svtests_summary.txt):
- **probe**: regressions 0, conversions 1, changes 0. The conversion:
  `r10uvm227repro/grid227/a9_class_holder STRICT_NOTEQUAL differ:depth(1) -> EQUAL`, fresh row
  `r10uvm227repro/grid227/a9_class_holder,EQUAL,,equal`. This is pass 446's residue 1 (a call
  through the first wildcard-imported package's clone), attributed to
  § cloneViaProviderTopClone476: its trace fires there (p3::f -> p2) and in no other probe
  process.
- **surelog**: 480 + 0 and 474 + 0, regressions 0, conversions 0, changes 0.
- **uhdm2rtlil**: 803/1/67 in both modes, 0/0/0.
- **downstream**: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0. The verdict diff
  against results/downstream_uhdm2rtlil.csv is 0.
- **sv-tests**: regressions 0, conversions 1, changes 0. The conversion:
  `CONVERSION generated/easyUVM/top.sv: DIFFERENT -> EQUAL`, fresh row
  `generated/easyUVM/top.sv,EQUAL,,equal`. The stage reads EQUAL 1936, STRICT_NOTEQUAL 0,
  DIFFERENT 4, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of
  2346.

Byteverify (SELFCHECK on) of the law sweep against the master's control:
- surelog: 0 movers of 962.
- uhdm2rtlil: 0 of 1608.
- downstream: 0 of 805.
- Each negative control flags all but its fixed file.

The trace confirms this: no law of this pass fires in any surelog, uhdm2rtlil or downstream
process. In probe and sv-tests, exactly four processes fire (evidence/trace_sweep.txt):
- the probe case a9_class_holder;
- easyUVM (23 fileMacroLenNormal476, 4 ifaceUdpShapedLowConnDecl476,
  2 ifaceUdpShapedNoRefMod476);
- uvm_param_vif_config_db (provider laws);
- generated/rsd/rsd.sv. This row was NOT named in the prediction. It is SURELOG_CRASH at the base
  and on the law binary, so it has no golden and no verdict. Its interface instantiations and
  package chains fire every law except FILELEN. Its exit code is unchanged, so its status is
  unchanged.

Canaries:
- `canaries.sh`: ok=52 (surelog) and ok=16 (uhdm2rtlil).
- `ctcan2.sh`: PASS on both, ok=58 with 1 unknown pattern and ok=2 with 6.

Binary audit (fence-filtered):
- surelog: 1523 of 1573 records name law27; the other 50 hold only a Surelog line.
- uhdm2rtlil: 1740 of 1740.
- No record names another slang-uhdm binary.

The prediction (evidence/prediction.txt) was written before the sweep:
- No corpus mover, which held.
- sv-tests: easyUVM converts and uvm_param_vif_config_db moves bytes, which held.
- rsd was not predicted, as noted above.

**Away census** (evidence/away_census.txt, away_movers_judged.txt). The scope: 10866
fence-filtered earlier case dirs under tools/probe whose dut.sv holds import, interface or
`__FILE__`, run on pristine and on law26.
- No exit code moves.
- 65 dirs move bytes. All 65 were rerun against golden on pristine and on the final law27.
- **One break was found on legal SV where pristine was right**: r11u251repro BP/b07_positional,
  a `bind ADD_SUB add_sub_if add_sub_if0(clk, a0);`. Pristine read STRICT_EQUAL; law26 read
  STRICT_NOTEQUAL line.
  - The decode: a bind instantiation is a bind_instantiation to Surelog's grammar, never a
    udp_instantiation, so its connections were compiled.
  - The fix: § ifaceUdpShapedLowConnDecl476 abstains under a BindDirective (boundInst476).
    § ifaceUdpShapedNoRefMod476 already skipped bound instances.
  - b07 reads STRICT_EQUAL again on law27, and IU/iu17 is its grid control.
- The other 64 movers:
  - 31 move to STRICT_EQUAL. Among them: pass 477's FN/fn02 and VF/vf06, its RF/rf08
    (easyUVM's shape) and the residue case r11u421 ra01; pass 424's interface cases VI/vi01 to
    vi03, vi07, vi10, vi11, vi13, vi16 and IA/ia01, ia03; the import-chain cases CI/ci13,
    A/a06, VC/vc14, LV/lv08, lv11, LT/lt02, VL/vl04, vl10, VO/vo13, vo14, VF/vf03, VM/vm03,
    vm04, MP/mp06, VA/va14, VI/vi01_homes and VG/vg01_iface_pos_gen.
  - Several move from NOT_EQUAL to STRICT_NOTEQUAL: VM/vm39_positional_multi, VI/vi19_positional,
    PD/p01 and R5/p1, all on line.
  - The rest move closer by dump distance at the same verdict.
  - 2 are byte movers that stay STRICT_EQUAL: NA/na01 and DA/da16.
  - Five have a uhdm-cmp count that grows with its head LATER in the walk:
    - r11u459 FT/ft04 and v11u459 VF/vf07, vf14 (18 -> 20): head `iq` -> `pk::C`.
    - v11u459 VF/vf12 (24 -> 760): the package head is cleared and s::f's loop variable now
      binds r's clone as golden does; uhdm-cmp prints the whole module_inst for the next face.
    - v11u436 VC/vc09 (187 -> 311): the ref_module head is cleared; the next head is pass 436's
      interface covergroup-array face.
  - Two keep their verdict with a different strict reading:
    - v11u264 VC/vc03_three_level_import: STRICT_NOTEQUAL depth, dump distance 211 -> 218. p3's
      clone reference now binds p2[top]'s `f`, golden's target; ours parents that variable at
      the assignment where golden parents it at the block, an older face.
    - r11u241 CF/e09: depth -> fullname at a later object, distance unchanged. q's dotted base
      `v` now binds p[top]'s formal as golden does; the member `a` of q[all] then resolves
      through a module-level struct copy.

**Pass 474's finding**: none of the 102 r11u474 and v11u474 case dirs in the away census moves bytes. The
reordered lawOn check is byte-neutral with the law on.

## Residues, ranked

1. uvm_param_vif_config_db:
   - The sister's param_assign face (ParamEmit emitParameters), unchanged.
   - Behind it, on this ground:
     - (d) The set_arbitration `val` formal's typedef-alias enum typespec. Golden keeps one copy
       per clone, named per clone: sfr_agent_pkg, sfr_test_pkg and tb_params_pkg, 12 copies.
       Ours shares one copy named by the last writer, sfr_test_pkg (2 copies in the dump).
       Decoded, not written.
     - The new head, uvm_reg_map.svh 2034 `accesses[i0].data[...]`. The element binding matches
       golden: the bit_select `accesses` reads sfr_agent_pkg[top] on both sides. Golden reaches
       a typespec_member `data` (uvm_pkg.sv 255) where ours is already visited. This is a
       typespec face of the provider clone's local struct array. Not decoded.
2. A multi-instance interface statement `a_if u1(clk, rst), u2(rst, clk);` (IU/iu14,
   199 -> 36 uhdm-cmp lines). Golden gives u2's elaborated ports u1's high connections (the
   elabConnDonor rule that emitInstance applies to modules). emitInterfaceInstance does not apply
   it.
3. CC/cc13: the clone's extra ref_var entry for a class-typed local, two against golden's one.
   This is an older face, NOT_EQUAL on pristine and STRICT_NOTEQUAL depth now.
4. CC/cc12's direct importer: a's loop-variable references bind the shared § 37 object at a[all]
   where golden binds u[top]'s declaration. This is the § cloneLoopVarShared37 design (StmtEmit,
   the sister's ground).
5. The carried lists of passes 474 and earlier, unchanged.

## Sister-ground faces (reported, not written)

- ParamEmit emitParameters: the param_assign right side of a named `.A(K::w)` override is written
  as a folded constant. This is uvm_param_vif_config_db's first face.
- StmtEmit's § cloneLoopVarShared37 object for a direct importer's foreach (residue 4).

## Process

- Implementer:
  - Builds law1 to law27 on case runs, with targeted runner calls on the two target rows only.
    The row-step driver (drivers/rowstep.sh) keeps each database and simulates the sister's face
    on a copy with pass 474's addpa.cpp.
  - One full five-stage sweep, on law27 only, and one byteverify against the master's control.
  - No pristine build or sweep. The pristine is a frozen copy of the main tree's build, md5
    1f099603e0eb6704a58436e2fa7da0ac.
- A note on the base: the sister's pass 481 landed on the main tree (fc1624b5a) during this pass.
  This pass's base and measurements stay at e6f5d904f. If 481 wrote the param_assign face,
  uvm_param_vif_config_db must be re-measured at integration; this pass's laws move its walk as
  the table above shows.
- Slips that affect no measurement:
  - A first launch of the sweep used a workdir name of a different length than the control's.
    It was stopped by its own PIDs and its directory removed, and the sweep was relaunched before
    any stage finished.
  - A pkill pattern scoped to that workdir path also ended the launching shell. It matched none
    of the sister's processes.
- The fence:
  - The list was read into a file by a program and never printed.
  - Every tree-wide list was filtered on it first.
  - The repro folder was scanned with it before delivery: no match.
- No other agent's process was touched.
- Temporary debug instrumentation used to bisect the § cloneForIncBindsHomeVar238 rebind (DBG
  prints, a global pointer in uhdm_main.cpp) was removed. uhdm_main.cpp is unchanged in the patch.
