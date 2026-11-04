# r11u483 — expression/parameter ground: class-scoped override actuals and interface instances as values

Pass 483 of the sv-tests campaign on the expression/parameter ground (src/ParamEmit.cpp and
src/ExprEmit.cpp; StmtEmit.cpp, EmitHelpers.h and every sister file unchanged), on base
fc1624b5a (pass 481). Measured under the measurement budget: the pristine reading is the
master's control /tmp/intr11u481; no pristine sweep; the worktree's pristine build is
byte-identical to the main tree's build/slang-uhdm (md5 20763fbe4439f89a287c3cf3a5128eb6);
one full five-stage sweep on the final binary (law2, md5 db70b390505c7fdbef10fa1c0805c3a6,
slang 12.0.0+545f88b2e); byteverify against the control.

## Verdict

- CONVERSION: `generated/uvm-examples/uvm_param_vif_config_db.sv` DIFFERENT -> STRICT_NOTEQUAL
  (`differ:fullname(2)`, uhdm-cmp 172 -> 0 lines). Its head at the base was this ground's
  face: the interface instances' param_assign Rhs for `.ADDR_WIDTH(SFR::sfr_addr_width)` and
  `.DATA_WIDTH(SFR::sfr_data_width)` in hdl_top (golden ref_obj `SFR::sfr_addr_width` at
  56:30-56:35, full name `work@hdl_top.SFR_MASTER.SFR::sfr_addr_width`; ours constant UINT:16 at
  the formal's default, evidence/row_pvc_uhdmcmp_pristine.txt). The strict remainder is the
  sister's two module/type faces (evidence/row_pvc_strict_law.txt): #93329 the ref_typespec under
  set_arbitration's formal `val` (golden `sfr_agent_pkg::uvm_sequencer_base::set_arbitration::val::
  UVM_SEQ_ARB_TYPE`, ours through `sfr_test_pkg`), then the walk diverging at #138364
  (uvm_misc.svh 103, `pos` in tb_params_pkg's `uvm_instance_scope` clone, golden binding
  sfr_agent_pkg's TOP-view clone objects): exactly the two faces pass 474 named and the live
  sister pass 476 writes. The row should read EQUAL once those land.
- `generated/easyUVM/top.sv` DIFFERENT -> DIFFERENT, unchanged (no law fires; its head is the
  sister's ref_module face).
- Two laws. The grid has 48 case dirs (OV 23, IV 25): pristine STRICT_EQUAL 5, STRICT_NOTEQUAL 1,
  NOT_EQUAL 42; law2 STRICT_EQUAL 37, STRICT_NOTEQUAL 1, NOT_EQUAL 10: 32 dirs to STRICT_EQUAL
  (OV 14, IV 18), 5 more closer by dump distance, 11 byte-identical. The away census over 562
  fence-filtered earlier case dirs moves 30, all toward golden (19 to STRICT_EQUAL, among them
  pass 481's residues v11u481 VA/va01, va30, va59, VC/vc01 and pass 474's CS/cs02, cs03, cs11 to
  cs13), no exit code moving.
- Corpora unchanged: probe 4024 + 63, surelog 954 + 0, uhdm2rtlil 1606 + 0, downstream
  803/66/2/0, every stage regressions=0; no corpus mover (byteverify 0 of 962, 1608 and 805).

## Laws (each read through src/LawSwitch.h; R11U483_OFF drops them all)

### § clsScopedOvRhsRefObj483 (ParamEmit; R11U483_CLSOVRHS_OFF; cases OV)

An instance parameter overridden by a NAMED actual that is a class-scoped name, `.A(K::w)`,
cannot be valued by Surelog: its reducer resolves a scoped name through a package only. So
NetlistElaboration::elab_parameters_ finds no simple value and takes the instance's complex
value, the unreduced actual, as the elaborated param_assign Rhs (the `getComplexValue` branch:
`m_helper.reduceExpr` reports the value invalid and the expression is kept,
`setParentNoOverride(exp, inst_assign)`). Golden writes a ref_obj named `K::w` located from the
scope's first token to the start of the member name (the span of the `K::` class scope,
12:12-12:15 for `S::w` at column 12), full name `<instance>.K::w`, no actual and no typespec;
the parameter object (the definition's Lhs) keeps its default value. Ours wrote the formal's
folded default as a constant with the parameter's typespec. The law records each such
param_assign in emitParameters (elaborated view, module or interface instance, a body-declared
parameter with a default) and replaces the Rhs after the listing is complete
(clsScopedOvActual483 decides the shape). Shapes: the class reached by an import (ov01), an
explicit import p::S (ov09), a typedef of the class (ov08), a $unit class (ov07), a class
declared in the instantiating module (ov10), interfaces (ov02, ov20), typed `int A` (ov04), two
parameters one overridden by a literal (ov03), two classes and instances (ov13), a nested
instance under two parents (ov12, full name work@top.m1.l.S::w), generate loops (ov21), instance
arrays (ov18), a parenthesized actual `.A((S::w))` (ov17: golden strips the parentheses, the
ref_obj starts at the inner name), `p::S::w` (ov22: golden names it `p::w`, the span ending at
`w`). Abstains (golden differs, pristine kept): an ordered override `#(S::w)`, which Surelog
drops (ov14, golden keeps the default and no vpiOverriden); a parameterized class `C#(4)::w`,
which Surelog values (ov11, golden UINT:4); an expression actual `.A(S::w + 1)` (ov16, golden the
whole operation tree at the actual's span: not written); a package parameter `.A(p::W)` control
(ov15, STRICT_EQUAL on both).

### § ifaceInstValueImplicitNet483 (ExprEmit; R11U483_IFACEVALNET_OFF; cases IV)

An interface INSTANCE named as a value (`g = u;`, `f(u)`, `c.set(u)`, `c = new(u)`,
`virtual ifc g = u;`, `q.push_back(u)`, `if (u != null)`, `mv <= u`) in a module process or a
module task or function is a name UhdmWriter::lateBinding cannot resolve (an instance is
neither a net nor a variable), so the walk ends at the module-level mint (the same mint
§ vifTdRefVarLocalImplicitNet481 decoded): a logic_net named like the instance, vpiNetType 1,
at the FIRST such reference's span, every later reference binding it by name (iv10), listed
among the implicit nets in source order of first reference (iv18, before a later
continuous-assignment implicit wire), in the definition module (iv17, `work@sub.u` under two
instances). Ours left the ref_obj unbound and minted nothing. The law writes it in ExprEmit's
ArbitrarySymbol branch, beside the existing system-call mint. Abstains: `default_nettype none,
where golden binds the ref_obj to the interface instance itself (iv08, not written: golden's
actual is the elaborated interface_inst); an instance in a generate block, where golden mints
nothing (iv12, NOT_EQUAL at another face on both binaries); outside a process (a module
variable initializer `virtual ifc mv = u;`, iv21: golden mints nothing; STRICT_NOTEQUAL endcol
on both, the interface_typespec span, TypeEmit's); a class method, also one declared inside
the module (iv26, byte-identical); an interface body or a program (implicitNetModule not a
module). A static class call's arguments are not written at all (§ staticScopedCall12), so
`C::set(u)` and `cdb#(virtual ifc)::set("vif", u)` stay as golden's (iv15, iv24, iv25:
byte-identical, STRICT_EQUAL).

## Grid (48 case dirs; evidence/grid_pristine.txt, grid_law2.txt, grid_switches.txt)

Every case is accepted by upstream slang (~/.local/bin/slang --single-unit, exit 0; five
candidate cases it rejected were dropped before the grid: OV/ov19, IV/iv16, iv22, iv27,
iv31, iv33). Every exit code is 0 on both binaries.

| group | law | pristine | law2 |
|---|---|---|---|
| OV ov01-ov05, ov07-ov10, ov12, ov13, ov18, ov21, ov24 | clsScopedOvRhsRefObj483 | NOT_EQUAL 46 | STRICT_EQUAL |
| OV ov06 (localparam B = A + 1) | clsScopedOvRhsRefObj483 | NOT_EQUAL 98, distance 89 | NOT_EQUAL 98, distance 78 |
| OV ov17 (parenthesized) | clsScopedOvRhsRefObj483 | NOT_EQUAL 72, distance 45 | NOT_EQUAL 72, distance 30 |
| OV ov20 (interface output port) | clsScopedOvRhsRefObj483 | NOT_EQUAL 46, distance 49 | NOT_EQUAL 72, distance 34 (head later) |
| OV ov22 (p::S::w) | clsScopedOvRhsRefObj483 | NOT_EQUAL 72, distance 45 | NOT_EQUAL 72, distance 30 |
| OV ov23 (port localparam B = A * 2) | clsScopedOvRhsRefObj483 | NOT_EQUAL 98, distance 79 | NOT_EQUAL 98, distance 72 |
| OV ov11, ov14, ov16 | (abstain) | NOT_EQUAL | byte-identical |
| OV ov15 | (control) | STRICT_EQUAL | byte-identical |
| IV iv01-iv07, iv10, iv14, iv17-iv20, iv23, iv28-iv30, iv32 | ifaceInstValueImplicitNet483 | NOT_EQUAL 17 to 542 | STRICT_EQUAL |
| IV iv08, iv12 | (abstain) | NOT_EQUAL | byte-identical |
| IV iv15, iv24, iv25, iv26 | (controls) | STRICT_EQUAL | byte-identical |
| IV iv21 | (control) | STRICT_NOTEQUAL endcol | byte-identical |

ov06, ov17, ov20, ov22 and ov23 reach STRICT_EQUAL on the param_assign the law writes; their
heads are now the elaborated body's declaration bounds (TypeEmit's
§ elabParamClsScopedSubst474 not reaching a parenthesized or three-part actual or an interface
header port) and, for ov06 and ov23, the dependent parameter `B` (below, residues).

Switches (evidence/grid_switches.txt): R11U483_OFF gives pristine's bytes and exit code on 48
of 48 dirs; R11U483_CLSOVRHS_OFF alone restores exactly the 19 OV movers (and leaves the IV
movers on the law's bytes) and R11U483_IFACEVALNET_OFF alone exactly the 18 IV movers; 11 dirs
are byte-identical on every binary.

## Away census (evidence/away_census_bytes.txt, away_movers_verdicts.txt, away_movers_distance.txt)

562 earlier case dirs under tools/probe (fence-filtered path list first, then every dut.sv
holding an `interface` with a `virtual <type> <name>` declaration or a named override actual
`.X(K::w)`), run on pristine and law2: no exit code moves (7 dirs exit 3 or 4 on both), 532
byte-identical, 30 movers, each run against its Surelog golden, all toward golden:

- to STRICT_EQUAL (19): r11u474 CS/cs02, cs03, cs11, cs12, cs13; v11u474 VP/vp01, vp02, vp05,
  vp08, vp13, vp14; v11u481 VA/va01, va30, va59, VC/vc01; v11u479 VA/va09; v11u402
  VV/vv02_vif_assigned; v11u256 M/vm07_class_vif; r11u123canon arms/t04_virtual_interface.
- closer by dump distance, still NOT_EQUAL (11): CS/cs10 133 -> 130; v11u474 VP/vp03 25 -> 10,
  vp04 66 -> 42, vp06 26 -> 19, vp07 24 -> 9, vp09 128 -> 106, vp10 68 -> 44, vp11 57 -> 42,
  vp12 45 -> 30; v11u479 VA/va10 30 -> 21; v11u293 VA/va12_virtual_iface_ctl 66 -> 57. Where
  the uhdm-cmp count grows (vp04 46 -> 72, vp09 46 -> 58, vp10 46 -> 72) the head moved later,
  from the param_assign to the body bound, and the dump distance fell.

## Prediction and census (evidence/prediction.txt, census_svtests_trace.txt)

Written before the sweep from a traced census of law2: probe (all 4087, trace empty, every dump
equal to the control's after path normalisation, negative control DIFF), surelog and
uhdm2rtlil both modes (trace empty, byteverify 0 of 962 and 0 of 1608 with SELFCHECK 961/962 and
1607/1608), and the 286 sv-tests rows whose sources match the text census (positive control
IV/iv01 traced). Predicted movers: sv-tests uvm_param_vif_config_db (DIFFERENT ->
STRICT_NOTEQUAL differ:fullname(2), 4 firings of § clsScopedOvRhsRefObj483) and
hdlconvertor_std2017_p771 (SLANG_ONLY, bytes only, § ifaceInstValueImplicitNet483 minting
work@top.p16 and work@top.p32); nothing else, no exit-code mover.

## Sweep (law2, the final binary)

One full five-stage sweep on law2 (`tests/sweep.sh --jobs 3 --workdir /tmp/r11u483swp`, the
probe, surelog, uhdm2rtlil and downstream stages from the worktree, the sv-tests stage through
the main tree's tests/sweep.sh since the worktree's UVM folder is empty; that call exits 1 on the
main tree's stale law index alone, its comparison reading regressions=0), launched on a quiet
machine after the sister r11u476's sv-tests sweep had finished, R11U483_TRACE on
(evidence/sweep_corpus.log, sweep_svtests.log, trace_sweep_law2.txt):

- probe: EQUAL 4024, STRICT_NOTEQUAL 63 of 4087; regressions=0 conversions=0 changes=0.
- surelog both modes: regressions=0 conversions=0 changes=0 (954 + 0 judge-equal row-modes,
  Tnoc d/t CMP_NOTEQUAL standing).
- uhdm2rtlil both modes: CMP_EQUAL 803, CMP_NOTEQUAL 1 (stamped_gen_param), SLANG_REJECT 67 in each
  mode; regressions=0 conversions=0 changes=0.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871; not identical
  and not excused 0.
- sv-tests: EQUAL 1935, STRICT_NOTEQUAL 1, DIFFERENT 4, SURELOG_ONLY 75, BOTH_REJECT 303,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=1 changes=0:

      CONVERSION generated/uvm-examples/uvm_param_vif_config_db.sv: DIFFERENT -> STRICT_NOTEQUAL
      generated/uvm-examples/uvm_param_vif_config_db.sv,STRICT_NOTEQUAL,differ:fullname(2),differ:fullname(2)

- The sweep's trace fires in exactly the two predicted processes: uvm_param_vif_config_db (4
  firings of § clsScopedOvRhsRefObj483) and hdlconvertor_std2017_p771 (3 of
  § ifaceInstValueImplicitNet483, SLANG_ONLY, its row unchanged).
- byteverify against the master's control /tmp/intr11u481 (SELFCHECK=1, same-length workdir
  names): surelog 0 of 962 (selfcheck 961/962), uhdm2rtlil 0 of 1608 (1607/1608), downstream 0
  of 805 (804/805) (evidence/byteverify_law2_vs_control.txt). The probe databases embed the
  checkout path, so they were compared by dump in the census: all 4087 equal after path
  normalisation.
- canaries: ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil); ctcan2 EXPECT_UNKNOWN=1
  on surelog and EXPECT_UNKNOWN=6 on uhdm2rtlil both PASS.
- binary audit: surelog 1531 of 1581 cmds.txt name /tmp/r11u483_bin/law2 (the other 50 hold only
  a Surelog line), uhdm2rtlil 1742 of 1742, sv-tests 2346 of 2346; no record names another
  slang-uhdm binary.

## Goal 1 (re-measured on law2)

- The probe faces: `C::mk().arr[1]` (r11u423 residue_cases/g1a) and `u.mk(3).a[2]` (g1b) exit 4
  in ours, 0 in upstream slang, 3 in Surelog; `this.mk().inner.s` (g1c, v11u415 VT/vt03) exits 0
  in ours and upstream slang, 3 in Surelog. Surelog rejects all three, so golden has no shape to
  write: not forced.
- All 75 SURELOG_ONLY details are front-end `error:` diagnostics of slang (none the exporter's
  unsupported-shape message).
- bp_unicore alone with the size guard on (§ macroVecLitTokenText403), on law2: exit 3 in 15.8 s
  at 817 MB maximum resident (`basic_string::substr`, the guarded crash text): no memory-bounded
  export, the guard stays; the six black-parrot rows stay SURELOG_CRASH.
- generated/rsd/rsd.sv stays SURELOG_CRASH (Surelog dies first): not this ground.

## Residues (all wrong on pristine too; none moved away)

1. uvm_param_vif_config_db: the sister's two module/type faces above (pass 476's brief).
2. The dependent parameter of a class-scoped override (OV/ov06 `localparam B = A + 1`, ov23 a
   port-list `localparam B = A * 2`): golden's B param_assign Rhs is the operation over A's very
   ref_obj (the same object, re-parented to the operation, with a ref_typespec named
   `work@top.u.S::w` to A's int_typespec), ours a folded constant (UINT:17, INT:32); and the body
   bound reading B keeps the substituted tree (TypeEmit's). The object sharing makes it a
   ParamEmit-and-TypeEmit pair, not written.
3. An expression actual `.A(S::w + 1)` (ov16): golden the operation(+) at the actual's span with
   the ref_obj and `UINT:1` size 64, not written.
4. The body declaration bound with a parenthesized `.A((S::w))` (ov17), a three-part `p::S::w`
   (ov22, golden names the bound's reference `work@top.u.d.p::w`) and an interface header port
   (ov20, golden keeps the operation where pass 474's comment says the port folds): TypeEmit's
   § elabParamClsScopedSubst474, the sister's.
5. `default_nettype none with an interface instance read as a value (iv08): golden binds the
   ref_obj to the elaborated interface_inst; not written.
6. An interface instance in a generate block read by a process there (iv12): golden mints no net,
   and its generate-scope listing differs at another face.
7. A module variable initializer `virtual ifc mv = u;` (iv21): STRICT_NOTEQUAL endcol, the
   interface_typespec span `ifc` (golden 4:11-4:21), TypeEmit's.
8. v11u481 VA/va56 (`s1.tk(g == null)` through a module instance) unchanged at 124 lines.
9. The carried lists of passes 481 and earlier (r11u481repro, v11u481repro and older READMEs).

## Sister-ground faces (reported, not written)

- TypeEmit § elabParamClsScopedSubst474: the elaborated body bound for a parenthesized or
  three-part class-scoped override and for an interface header port (OV/ov17, ov22, ov20), and
  the bound reading a dependent parameter (ov06, ov23).
- TypeEmit's interface_typespec span on a module variable `virtual ifc mv = u;` (iv21).
- The two uvm_param_vif_config_db faces of pass 474 (UhdmExporter / ModuleEmit clone binding
  through sfr_agent_pkg; the ref_typespec route under set_arbitration's formal).

## Process

The IMPLEMENTER within the budget: no pristine build of its own beyond the worktree build that
had to match the main tree (md5 equal), no pristine sweep (the master's control read instead);
law1 (§ clsScopedOvRhsRefObj483 alone) on case runs and two targeted runner calls on the two
target rows (pristine and law1); law2 (both laws, the final binary) on case runs, one traced
census (probe, surelog and uhdm2rtlil in full through the harness scripts, sv-tests on the 286
text-census rows through the runner, two calls since the first path list missed the rows whose
:files: paths hold `/./`, found by the target row's absence and fixed by normalising), one full
five-stage sweep and one byteverify. The census overlapped the sister r11u476's sv-tests sweep for
part of its run (it reads bytes, exit codes and traces only, and its csvs read every status as
the control); the sweep was launched only after the sister's sweep had finished. The fence list
was read into a file by a program and never printed; every tree-wide list (the text census over
25558 sources, the away census over 39096 case dirs) was fence-filtered before any file was
opened, and the repro folder scans clean. No other agent's process was touched. Every tool
variable was checked with `[ -x ]` by drivers/env.sh before use.

## Files

- cases/OV (23 dirs, § clsScopedOvRhsRefObj483) and cases/IV (25 dirs,
  § ifaceInstValueImplicitNet483); every dut.sv names its law on its first line.
- drivers: env.sh, runcase.sh (Surelog golden + ours, rc, uhdm-cmp lines, strict verdict,
  md5), grid.sh, switches.sh, away.sh, dist.sh (path-normalised dump distance).
- evidence: prediction.txt, grid_*.txt, away_*.txt, census_svtests_trace.txt,
  row_pvc_uhdmcmp_pristine.txt, row_pvc_strict_law.txt, sweep and byteverify logs.
