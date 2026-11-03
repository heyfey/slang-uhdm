# r11u474: the this_t instance of a registry-typed generic class, class-scoped range bounds, copied value formals

Pass 474, the module/type ground (sv-tests campaign, thirty-seventh pass on this ground). Base
a1ffba66c. Law binary `law15` (md5 b8ed2976069b17485592cfe7eb656f1d); the worktree's first build
reproduced the main tree's binary byte for byte (21cd25b130d5a097624f8d4fc3dbb292), which is the
pristine of every reading below. The pristine sweep reading is the master's control at the base,
/tmp/intr11u472 (no pristine sweep of its own).

Every law reads its switch through src/LawSwitch.h (`lawOn(474, "R11U474_<LAW>_OFF")`),
`R11U474_OFF` drops all of them, `R11U474_TRACE=<dir>` logs each firing (`lawTrace(474, ...)`).
No src/R*.h, no LawState.h section, no getenv, no header change. ExprEmit, StmtEmit, ParamEmit,
EmitHelpers.h, TaskFuncEmit, include/ and uhdm_main.cpp are unchanged.

## Targets

| row | before (control) | after (law15) |
|---|---|---|
| generated/uvm-examples/uvm_param_vif_config_db.sv | DIFFERENT, uhdm-cmp 172 lines | DIFFERENT, uhdm-cmp 1376868 lines, the SAME first face (see below) |
| generated/easyUVM/top.sv | DIFFERENT, 60 lines | DIFFERENT, unchanged (no law fires; its heads are the sister's) |

uvm_param_vif_config_db cannot convert in this pass: its first difference is the sister's (ParamEmit's
emitPackage lists no package virtual-interface typedef). Every face behind it on this ground that
the row's own database shows is written: with this pass's laws plus a SIMULATION of the sister's two
faces (evidence/tools/addvif.cpp and addpa.cpp edit our database; they are measurement tools, not
laws) the row reads uhdm-cmp 0 lines, STRICT_NOTEQUAL fullname, and what is left is listed under
Residues 1. The decode is in evidence/row_pvc_decode.txt.

## Laws

1. **§ thisTdRegDefView474** (UhdmExporter, at § clsNestedSpecCloneHomeInst460; switch
   `R11U474_THISREGDEF_OFF`). The class-nested specialization clone (`typedef sfr_agent
   #(SFR_ADDR_WIDTH, SFR_DATA_WIDTH) this_t;` copied for `typedef sfr_agent #(SFR::w, SFR::v)
   SFR_agent_t;`) that pass 460 stamps with the declaring package's TOP view keeps that package's
   DEFINITION view when the generic class also declares `typedef R #(<this typedef>, ...) X;` with R a
   generic class reached through an IMPORT from another package (`typedef
   uvm_component_registry #(this_t) type_id;`, the first line of `uvm_component_param_utils(this_t)`).
   Decoded by bisecting the row's own sources (evidence/row_pvc_decode.txt: only removing the
   `uvm_*_param_utils(this_t)` line flips golden to TOP; the registry typedef alone keeps the
   definition view), then gridded without UVM. Surelog's clone of a class typedef
   (ElaborationStep.cpp bindTypedefs_, `clone_tree` keeps the source's vpiInstance) takes the
   instance of whichever compile of the declaring package made the specialization it binds; the rule
   is MEASURED, not stepped through. A qualified `u::R #(this_t)`, R in the class's own package,
   another argument, a property or a function-local typedef keep TOP (cases RG rg02 to rg05, rg08,
   rg09).
2. **§ clsScopedRangeKept474** (TypeEmit, in the packed-range bound builder `emitBound`, helper
   above makeBoundConst, its naming half `clsScopedRangeNames474` called design-final from
   UhdmExporter after § subrAggCopyNamesByChain458; switch `R11U474_CLSRANGE_OFF`). A packed range
   bound of a NET or VARIABLE that reads a class-scoped name `K::w` (K a class or a typedef of one,
   two parts) is the written tree, not a fold: Surelog's reduceExpr resolves a scoped name only
   through a package, so `S::w - 1` stays `operation -` over an unbound `ref_obj S::w` and `constant
   1` (UINT, size 64). The reference on the typespec an elaborated net or variable references is named
   `<net full name>.S::w`; the definition-view copy carries no name (cs01, cs07). Parameters and
   typedefs abstain (cs08 measured a different, undecoded shape); `p::K::w` abstains (golden names it
   `p::w` at a shortened span, cs05's `c`).
3. **§ elabParamClsScopedSubst474** (TypeEmit, the same builder, before law 2; switch
   `R11U474_PARAMSUBST_OFF`). In an ELABORATED instance body (module: `elabInstanceTs`; interface:
   the flag `g474IfaceElab`, WRITTEN by ModuleEmit's emitInterfaceInstance through a scope guard and
   read only here) a body declaration's packed bound that reads a parameter overridden by a NAMED
   `.A(K::w)` keeps the written tree with the reference renamed `K::w` at the parameter's own span,
   unbound, with a ref_typespec to the instance parameter's typespec (golden cs03 work@top.u.d). An
   ORDERED override `#(S::w)` abstains: Surelog drops it and keeps the default (golden cs06 u reads
   UINT:8 and the bound 7). PORTS abstain: golden folds the interface header port (the row's bfm
   `output logic [ADDR_WIDTH-1:0] address`) and writes an undecoded form on a module port (cs10).
4. **§ cloneValFormalUnnamed474** (UhdmExporter, pass 460's alias deep copies, `unname460`; switch
   `R11U474_CLONEPARNAME_OFF`). A copied VALUE formal (a `parameter`, from § specValueArgRefObj470's
   value pairing or § specArgPairsImportedFormal468's imported formal) in a fresh copy that the loop
   made (parented by the copy or its copied param_assign) drops the stored full name it inherited, as
   the type_parameter copies already did: golden names it by the copy's chain (`this_t.UVM_ALL_ON`)
   where ours kept `sfr_agent_pkg::sfr_agent::UVM_ALL_ON`. Read together with pass 460's switch
   `R11U460_PKGTDSPEC_OFF` (the loop it lives in): that switch turns this law off too. Laws 1 and 4
   both live in pass 460's drain, so `R11U460_NESTCLONEINST_OFF` also turns law 1 off.

Flags written across emitters: `g474IfaceElab` (ModuleEmit writes, TypeEmit reads, membership only).
Side lists: `clsScopedRangeRefs474()` (TypeEmit, drained once design-final), `gen474`/`def474`
(local maps in the pass 460 drain).

## Grid (cases/CS, cases/RG, cases/TI; drivers/runcase.sh; every case accepted by upstream slang,
negative control `wire [Q::w-1:0] a;` rc 1; every exit code 0 on both binaries)

evidence/grid.txt and evidence/grid_switches.txt. Each case names its law on its first line.

| case | law | pristine | law15 | switch alone restoring |
|---|---|---|---|---|
| CS/cs01 wire [S::w-1:0] | clsScopedRangeKept474 | NOT_EQUAL 58 | STRICT_EQUAL 33 | CLSRANGE |
| CS/cs04 logic var | clsScopedRangeKept474 | NOT_EQUAL 58 | STRICT_EQUAL 33 | CLSRANGE |
| CS/cs07 non-top module | clsScopedRangeKept474 | NOT_EQUAL 58 | STRICT_EQUAL 36 | CLSRANGE |
| CS/cs14 ports, file-scope import | clsScopedRangeKept474 | NOT_EQUAL 58 | STRICT_EQUAL 75 | CLSRANGE |
| CS/cs05 [S::w:0], p::S::w | clsScopedRangeKept474 | NOT_EQUAL 24 | NOT_EQUAL 24, dump distance 54 -> 25 | CLSRANGE |
| CS/cs09 unpacked dim, function return | clsScopedRangeKept474 | NOT_EQUAL 24 | NOT_EQUAL 24, dump distance 117 -> 96 | CLSRANGE |
| CS/cs08 package typedef, parameter | (abstains) | NOT_EQUAL 58 | byte-identical | - |
| CS/cs02 interface .A(S::w) | elabParamClsScopedSubst474 | NOT_EQUAL 72 | NOT_EQUAL 46 (the sister's param_assign) | PARAMSUBST |
| CS/cs03 module .A(S::w) | elabParamClsScopedSubst474 | NOT_EQUAL 72 | NOT_EQUAL 46 (same) | PARAMSUBST |
| CS/cs11 interface with a port | elabParamClsScopedSubst474 | NOT_EQUAL 72 | NOT_EQUAL 46 (same) | PARAMSUBST |
| CS/cs12 two parameters, a default instance | elabParamClsScopedSubst474 | NOT_EQUAL 72 | NOT_EQUAL 46 (same) | PARAMSUBST |
| CS/cs13 int-typed parameter | elabParamClsScopedSubst474 | NOT_EQUAL 72 | NOT_EQUAL 46 (same) | PARAMSUBST |
| CS/cs10 module output port + body net | elabParamClsScopedSubst474 | NOT_EQUAL 36 | NOT_EQUAL 36, dump distance 148 -> 97 | PARAMSUBST |
| CS/cs06 ordered #(S::w), .A(S::w + 1) | (abstains) | NOT_EQUAL 36 | byte-identical | - |
| RG/rg01 wildcard import of R | thisTdRegDefView474 + cloneValFormalUnnamed474 | NOT_EQUAL 670 | STRICT_EQUAL 251 | both needed |
| RG/rg07 R #(this_t, 3) | thisTdRegDefView474 + cloneValFormalUnnamed474 | NOT_EQUAL 670 | STRICT_EQUAL 258 | both needed |
| RG/rg10 explicit import u::R | thisTdRegDefView474 + cloneValFormalUnnamed474 | NOT_EQUAL 358 | NOT_EQUAL 358 (instance now golden's; head elsewhere) | both needed |
| RG/rg11 imported value parameters | thisTdRegDefView474 + cloneValFormalUnnamed474 | NOT_EQUAL 1298 | STRICT_NOTEQUAL depth | both needed |
| RG/rg02 qualified u::R | cloneValFormalUnnamed474 (law 1 abstains) | STRICT_NOTEQUAL fullname | STRICT_EQUAL 148 | CLONEPARNAME |
| RG/rg04 R in the class's package | cloneValFormalUnnamed474 (law 1 abstains) | STRICT_NOTEQUAL fullname | STRICT_EQUAL 154 | CLONEPARNAME |
| RG/rg05 property R #(this_t) | cloneValFormalUnnamed474 (law 1 abstains) | STRICT_NOTEQUAL fullname | STRICT_EQUAL 158 | CLONEPARNAME |
| RG/rg09 function-local typedef | cloneValFormalUnnamed474 (law 1 abstains) | STRICT_NOTEQUAL fullname | STRICT_EQUAL 152 | CLONEPARNAME |
| RG/rg12 imported value parameters, no registry | cloneValFormalUnnamed474 | STRICT_NOTEQUAL fullname | STRICT_EQUAL 478 | CLONEPARNAME |
| RG/rg03 R #(int) | cloneValFormalUnnamed474 (law 1 abstains) | STRICT_NOTEQUAL file | STRICT_NOTEQUAL file (fullname cleared, head type_id.T's span) | CLONEPARNAME |
| RG/rg08 R #(A #(W, V)) | cloneValFormalUnnamed474 (law 1 abstains) | STRICT_NOTEQUAL file | STRICT_NOTEQUAL file (same) | CLONEPARNAME |
| TI/t01 to t22 | thisTdRegDefView474 decode grid | 17 or 40 | byte-identical (ours writes no this_t copy without an importing class) | - |

`R11U474_OFF` gives pristine's bytes and exit code on all 47 case dirs (evidence/grid_switches.txt).

## Away census (earlier case dirs)

drivers/away.sh, evidence/away_census_law15.txt: 2533 earlier case dirs whose dut.sv holds a class
with `#(`, a scoped name inside brackets or a named `.P(K::w)` override, the path list filtered on
the fence list before any file was opened. 2511 exit 0, 18 exit 3 and 4 exit 4 on both binaries, no
exit code moving; 2530 byte-identical; 3 movers, each restored by `R11U474_CLONEPARNAME_OFF` alone
and each closer: r11u472 TI/ti04 and ti05 and v11u470 VK/vk09, STRICT_NOTEQUAL fullname ->
STRICT_EQUAL (138, 154 and 126 objects).

## Prediction and sweep

evidence/prediction.txt, written before the sweep: sv-tests byte mover uvm_param_vif_config_db only
(traced census of law15 over the 223 candidate rows, drivers' evidence/tools/census.sh and cands.py,
firing on that row alone); no corpus, probe or downstream mover.

One full five-stage sweep on law15 with `R11U474_TRACE` on (evidence/sweep_corpus.log,
sweep_svtests_summary.txt, trace_sweep_law15.txt, byteverify_law15_vs_control.txt,
probe_dump_census.txt):

- probe: EQUAL 4024 + STRICT_NOTEQUAL 63 of 4087, regressions=0 conversions=0 changes=0; the csv
  identical to the control's; all 4087 dumps equal to the control's after path normalisation
  (a negative control, a different case pair, flagged).
- surelog: default 480 + 0, testflags 474 + 0 (Tnoc d/t CMP_NOTEQUAL standing), 0/0/0; csv identical
  to the control's.
- uhdm2rtlil: 803/1/67 in both modes (stamped_gen_param d/t CMP_NOTEQUAL standing), 0/0/0; csv
  identical.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; csv identical.
- byteverify against the control /tmp/intr11u472: surelog 0 of 962, uhdm2rtlil 0 of 1608,
  downstream 0 of 805 (self-checks flag 961, 1607, 804). NO CORPUS MOVER, as predicted.
- canaries ok=52 and ok=16; both ctcan2 checks PASS.
- sv-tests (the main tree's tests/sweep.sh, the worktree's UVM folder being empty): EQUAL 1935,
  STRICT_NOTEQUAL 0, DIFFERENT 5, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8,
  TIMEOUT 1 of 2346, regressions=0 conversions=0 changes=0; the status columns identical to the
  control's. The command exited 1 on the main tree's stale law index alone (an uncommitted
  integration in the main tree); the worktree's own corpus run read "law index current".
- trace: one process fired, uvm_param_vif_config_db (thisTdRegDefView474 2, clsScopedRangeKept474
  6 + 3 names, cloneValFormalUnnamed474 4), exactly the prediction; no corpus row or probe case.
- uvm_param_vif_config_db's uhdm-cmp count 172 -> 1376868: the head is the same sister face, now
  reached through the corrected this_t instance as a vector-size mismatch on the definition-view
  package tb_params_pkg (vpiTypedef 134 in golden, 132 in ours: the two interface typedefs), which
  uhdm-cmp prints as both whole packages. With the sister's listing simulated the count is 58 on law4
  and, with the param_assign face also simulated, 0 lines on law14/law15 (evidence/row_pvc_decode.txt).
- binary audit: surelog 1531 of 1581 cmds.txt name law15 (the other 50 hold only a Surelog line),
  uhdm2rtlil 1742 of 1742, sv-tests 2346 of 2346.

## Residues (all wrong on pristine too; none moved away)

1. uvm_param_vif_config_db, in walk order: (a) the sister's package virtual-interface typedef
   listing in the definition view (ParamEmit emitPackage) and the typedefs' span, which starts at
   `virtual` in our TOP view and hvl_top where golden starts at the interface name and ends at 54:31
   / 53:32; (b) the sister's param_assign Rhs of an instance parameter overridden by a named
   class-scoped `.A(K::w)` (ParamEmit emitParameters: golden ref_obj K::w at the actual, span ending
   after `K::`, full name work@<inst>.K::w, no typespec; ours the folded UINT constant at the
   formal's default; cases CS cs02, cs03, cs11 to cs13 read 46 uhdm-cmp lines on exactly this);
   (c) THIS GROUND, behind them: tb_params_pkg's clones of uvm_pkg subroutines (it reaches uvm_pkg
   only through `import sfr_agent_pkg::*;`) bind their references to sfr_agent_pkg's TOP-view clone
   objects in golden (4594 references, 2897 to their own), ours to their own (evidence/tools/
   clbind.cpp; the strict walk diverges at uvm_misc.svh 103, `pos` in tb_params_pkg's
   uvm_instance_scope); (d) a ref_typespec under set_arbitration's formal `val` named through
   sfr_agent_pkg in golden and sfr_test_pkg in ours. Next step for (c): grid a package that reaches
   a home only through another importer, and decode Surelog's clone of a clone (UhdmWriter /
   the package elaboration's clone_tree with the importer's elaborator scope).
2. easyUVM: unchanged, heads the sister's (the FILE macro path and the default argument on
   exp.compare(rec) in ExprEmit; collectMaterializedPkgs in EmitHelpers.h).
3. The class-scoped bound shapes this pass leaves: a parameter's or package typedef's range (CS/cs08:
   golden keeps the tree on a package typedef with a different copy naming, work@top.p::w_t.S::w,
   and gives the parameter size 1); `p::K::w` (golden `p::w` at a span ending after `p::K::`, cs05);
   an unpacked dimension [S::w] (golden vpiArrayType 3, cs09); a module output port in an elaborated
   instance (cs10, golden's ref_obj keeps the bare name S::w with a typespec named S::w); a
   positional override, which golden drops (cs06, decoded, ours honours it: our param_assign and
   bounds use 16 where golden keeps 8, a ParamEmit and TypeEmit face); an expression override
   `.A(S::w + 1)` (cs06's v, golden substitutes the whole tree).
4. RG/rg10 (explicit import u::R) at 358 uhdm-cmp lines, its head not on the instance; RG/rg11's
   class imported-parameter listing constants without their typespec in a class that also declares
   the registry typedef (STRICT_NOTEQUAL depth); RG/rg03 and rg08's type_id.T span (STRICT_NOTEQUAL
   file).
5. TI/t01 to t22: without an importing class, ours writes no class-nested this_t copy at the
   specialization where golden writes one (instance TOP or DEFINITION by law 1's rule); pass 460's
   drain needs a listing to fire.
6. The carried lists of passes 472 and earlier (r11u472repro, v11u472repro and older READMEs).

## Sister-ground faces (reported, not written)

- ParamEmit emitPackage: no VirtualInterfaceType branch (the definition view of tb_params_pkg
  lists no SFR_master_bfm_t / SFR_monitor_bfm_t) and the TOP-view span starting at `virtual`.
- ParamEmit emitParameters: an instance parameter overridden by a named `.A(K::w)` keeps golden's
  ref_obj K::w (residue 1b; cases CS cs02, cs03, cs11 to cs13).
- ExprEmit and EmitHelpers.h: easyUVM's heads as passes 470 and 472 reported.

## Process

Implementer within the budget: law1 to law15 on case runs (law5 is a copy of law4 from a failed
build; law1 to law3 fired nowhere until the predicate unwrapped class property declarations, named
types and a ClassType lookup result; law7 and law8 narrowed law 2 to nets and variables after cs08;
law10 gated law 3 on the elaborated view after law9 renamed the definition view; law11 abstained on
ordered overrides after cs06 moved away; law13 left ports to the fold after the row's interface
ports moved away; law15 guarded law 4 to fresh copies), targeted runner calls on the two target rows
(pristine, law4, law12, law13, law14), one traced sv-tests census and one away census before the
sweep, one full five-stage sweep on law15 with the trace on (the sv-tests stage through the main
tree's tests/sweep.sh since the worktree's UVM folder is empty), one byteverify. No pristine build
beyond the worktree's first, no pristine sweep. The fence list was read into a file by a program and
never printed; every tree-wide list was filtered on it before a file was opened. No other agent's
process was touched. One slip: an unset UHDM_CMP in one shell made bash execute a golden .uhdm as a
script (caught at once; no file was written anywhere, the worktree and main tree statuses checked);
every later command sourced drivers/env.sh, which checks each tool with `[ -x ]`.
