# r11u472 — module/type ground, pass 472 (sv-tests campaign)

Base 67001800 (pass 470 landed). Ground: src/TypeEmit.cpp, src/ModuleEmit.cpp,
src/UhdmExporter.cpp, src/TaskFuncEmit.cpp, uhdm_main.cpp. This pass touches
src/ModuleEmit.cpp and src/UhdmExporter.cpp only.

## Summary

Two laws, both decoded from the second family of heads on the target row
generated/uvm-examples/uvm_param_vif_config_db.sv (the family behind the sister's
package virtual-interface typedef head):

- § grpOwnOobGenericCls472 (src/ModuleEmit.cpp, inside withOwnOob452, the helper of
  § pkgGroupOwnOobDef452; switch R11U472_GRPOOBGEN_OFF).
- § clsImpGroupHomeOrder472 (src/UhdmExporter.cpp, beside § importGroupKeepsHomeOrder446
  and § unitGroupKeepsHomeOrder466; switch R11U472_CLSGRPORDER_OFF).

R11U472_OFF drops both; R11U472_TRACE=<dir> logs each firing (lawTrace(472, ...)).
No src/R*.h, no getenv, no header change, no LawState.h section. Both laws read only
VpiName on class_defn objects (VpiFullName's getter stores what it computes, the pass
468 lesson).

SV-TESTS RESULT: no row converts. uvm_param_vif_config_db stays DIFFERENT at 172
uhdm-cmp lines because its FIRST head is the sister's (ParamEmit emitPackage writes no
package virtual-interface typedef). Behind that head, the class-listing heads #2, #3,
#4 and #6 of the pristine trace are gone on the law binary (evidence/pvc_heads_pristine.txt
against evidence/pvc_heads_law2.txt), and the class listings of tb_params_pkg::SFR and
of all five sfr_test_pkg classes now equal golden entry for entry (name, parent, order;
984 and 993/990/993/993/991 entries).

## Targeted row

generated/uvm-examples/uvm_param_vif_config_db.sv: DIFFERENT -> DIFFERENT (uhdm-cmp 172
-> 172 lines, the first head unchanged and on the sister's ground).

Heads traced with cmptrace2 (pass 446's tool, copied into /tmp; it re-runs Compare with
the culprits seeded as visited):

| # | pristine | law2 |
|---|----------|------|
| 0, 1 | golden tb_params_pkg (DEF view) lists interface_typespec SFR_master_bfm_t 54:17 and SFR_monitor_bfm_t 53:17; ours lists none (ParamEmit, the sister's) | same |
| 2 | golden task run_phase < class_defn sfr_driver < sfr_agent_pkg; ours task sfr_driver::run_phase < tb_params_pkg (a clone) | gone |
| 3, 4 | the same for sfr_agent::build_phase and sfr_agent::connect_phase | gone |
| 6 | class_defn tb_params_pkg::SFR: golden 984 subroutines, ours 979 | gone |
| others | instance culprits that only re-enter tb_params_pkg, whose compare fails because of #0 and #1 | same |

What the heads were, measured with evidence/tools/clstf.cpp and pkgtf.cpp:

1. tb_params_pkg's class SFR inherits sfr_agent_pkg's subroutine group
   (§ classInheritsContainerImports23). Golden: sfr_agent_pkg's 979-entry listing with
   uvm_packer's six macro-written get/set_packed_* clones at positions 227 to 232, then
   the five out-of-body definitions of sfr_agent_pkg's own classes (sfr_driver::run_phase,
   sfr_monitor::build_phase, sfr_monitor::run_phase, sfr_agent::build_phase,
   sfr_agent::connect_phase) as class_defn-parented definitions, 984 entries. Ours: 979
   entries, the packer clones at 947 to 952, no out-of-body definitions.
2. The five sfr_test_pkg classes (imports uvm_pkg, sfr_agent_pkg, tb_params_pkg) list at
   positions 980 to 984 golden's class_defn-parented definitions and ours
   tb_params_pkg's package-parented clones (the first group that held the name).

Cause of 1's missing entries and of 2: § pkgGroupOwnOobDef452 swaps a clone-bearing
package's `C::m` clones for the class definitions, but its walk reads only ClassType
members; sfr_driver, sfr_monitor and sfr_agent are parameterized (GenericClassDef
members), so sfr_agent_pkg's group kept no definitions and the later tb_params_pkg group
supplied clones. Cause of 1's order: § 23 copies the group before
§ importGroupKeepsHomeOrder446 re-orders the package and module views design-final; the
class copy was never re-ordered.

## Laws

§ grpOwnOobGenericCls472 (R11U472_GRPOOBGEN_OFF). In withOwnOob452, a parameterized
class's out-of-body definitions join the group exactly as a plain class's do. The
definitions are read from classOobTfs entries whose ClassType has genericClass declared
in the package, and only from a class_defn that one of the package's two views lists.
If two specializations carry the same `C::m` name with different objects, the law
abstains (no pointer-order choice).

§ clsImpGroupHomeOrder472 (R11U472_CLSGRPORDER_OFF). After the package, module,
interface and design re-orders, the same reorder446 runs over every class_defn's
subroutine listing (classes of both package views, of both module views and
design->AllClasses, each class once). A run of clones with one import statement's key is
re-ordered by the home package's DEF listing. Any other run stays as it is.

## Grid (tools/probe/r11u472repro/cases, probe arguments, Surelog golden per case)

evidence/grid_switches.txt. Every exit code is 0 on every binary.

| case | law | pristine | law2 |
|------|-----|----------|------|
| CL/cl01 | clsImpGroupHomeOrder472 (package class, macro-written clones) | STRICT_EQUAL 234 (order invisible to both judges: the clones are already visited) | STRICT_EQUAL 234, bytes moved toward golden's order |
| CL/cl02 | grpOwnOobGenericCls472 (generic class with an out-of-body task) | NOT_EQUAL 146 | STRICT_EQUAL 48 |
| CL/cl03 | grpOwnOobGenericCls472 (control: plain class, § 452 already right) | STRICT_EQUAL 41 | byte-identical |
| CL/cl04 | grpOwnOobGenericCls472 (consumer with three imports) | STRICT_EQUAL 82 | STRICT_EQUAL 82, bytes moved |
| CL/cl05 | both | NOT_EQUAL 726 | STRICT_EQUAL 249 |
| CL/cl06 | clsImpGroupHomeOrder472 (class in a module) | STRICT_NOTEQUAL name | STRICT_EQUAL 180 |
| CL/cl07 | grpOwnOobGenericCls472 (class in a module) | NOT_EQUAL 146 | STRICT_EQUAL 38 |
| CL/cl08 | grpOwnOobGenericCls472 (type-parameter and value-parameter generics) | NOT_EQUAL 164 | STRICT_EQUAL 59 |

Switch table (same file): R11U472_OFF gives pristine's bytes on 12 of 12 dirs (the 8
grid dirs and the 4 away movers below). R11U472_GRPOOBGEN_OFF alone restores cl02, cl04,
cl07, cl08 and VP/vp01. R11U472_CLSGRPORDER_OFF alone restores cl01, cl06, UG/ug01,
UG/ug02 and VG/vg05. cl05 needs both.

The TI cases (TI/ti01 to ti07, ti09, ti10) are the decode grid for residue 2 (no law
written): in every small shape, golden instances the specialization's own this_t at the
TOP view of the declaring package, as § clsLocalTdTopHomeInst446 models. Their first line
names that law because they probe its territory; pass 472 has no law there.

## Away census (earlier case dirs)

drivers/away.sh, evidence/away_census_law2.txt. The candidates were 2514 earlier case dirs
whose dut.sv holds `import`, `class` and `extern` or `::`. The path list was filtered on
the fence list before any file was opened.

- 2500 are byte-identical.
- 10 exit-3 dirs differ (r11u468 OV/ov01 to ov04, v11u470 VK/vk04, r11u231 TI/t18,
  r11u470 VA/va16, v11u152 KV/v04_in_pkg, v11u216 T/t11, v11u223 A/a19_twofiles). Exit-3
  bytes vary between runs of any binary (pass 464's note).
- 4 exit-0 dirs move, all toward golden. Each is attributed by its switch:
  - r11u466 UG/ug01: STRICT_NOTEQUAL name -> STRICT_EQUAL 249 (clsImpGroupHomeOrder472).
  - r11u466 UG/ug02: NOT_EQUAL 136 -> STRICT_EQUAL 179 (clsImpGroupHomeOrder472). These
    are pass 466's residue "package group order with macro-written out-of-body methods
    (UG/ug01 to ug03)".
  - v11u455 VP/vp01: NOT_EQUAL 710 -> STRICT_EQUAL 171 (grpOwnOobGenericCls472).
  - v11u446 VG/vg05: NOT_EQUAL 46 -> 46 at the same head (a struct_var face), dump
    distance 215 -> 211 (clsImpGroupHomeOrder472).

## Prediction (written before the sweep, from the pristine databases)

evidence/prediction.txt, evidence/tools/pred472.cpp. Predicate F2: a package that
imports, lists a `C::m` clone of its own parameterized class, and is imported somewhere.
Predicate F1: a class listing whose package-parented clones are out of the package
listing's order. The scan covered 7477 fence-filtered control databases of the master's
control /tmp/intr11u470.

- Corpus movers predicted: NONE (probe 4087, surelog 954, uhdm2rtlil 1606,
  downstream 804).
- sv-tests: uvm_param_vif_config_db (F1 SFR, F2 five definitions).
- uvm_slave_agent and uvm_slave_agent_multi_seq_item read F2 in the scan. That is a
  scanner false positive: their classes are not parameterized (localparams inside the
  class span), and the law keys on slang's genericClass. Prediction: no firing there and
  no status change.

## Gates

Pristine reading: the master's control sweep /tmp/intr11u470 (its csvs equal
results/*.csv). Law sweep: one full five-stage sweep on law2 (md5 21cd25b1...) with
R11U472_TRACE on (evidence/sweep_law2_summary.txt).

- probe: EQUAL 4024 + STRICT_NOTEQUAL 63 of 4087, regressions=0 conversions=0 changes=0.
  All 4087 databases match the control's after path normalization of the uhdm-dump. The
  negative control flags 199 of 200 (the one unflagged file is the fixed file itself;
  evidence/probe_dump_census.txt).
- surelog: default CMP_EQUAL 480, testflags 474 (Tnoc d/t CMP_NOTEQUAL standing),
  regressions=0 conversions=0 changes=0. The csv equals the control's except the two
  LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes (stamped_gen_param d/t CMP_NOTEQUAL standing), 0/0/0.
  The csv is identical to the control's.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0. The csv is
  identical to the control's.
- svtests: EQUAL 1935, STRICT_NOTEQUAL 0, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions=0 conversions=0
  changes=0. The csv is identical to the control's.
- Both sweep commands exited 1, on "law index STALE" alone (the new case files; the
  index is regenerated in the patch).
- byteverify against the control (SELFCHECK=1, same-length roots): surelog 0 of 962,
  uhdm2rtlil 0 of 1608, downstream 0 of 805. The self-checks flagged 961, 1607 and 804
  (evidence/byteverify_law2_vs_control.txt).
- The prediction held. The trace fired in exactly one database of the whole sweep:
  sv-tests uvm_param_vif_config_db (grpOwnOobGenericCls472 40 lines,
  clsImpGroupHomeOrder472 1, class SFR; evidence/trace_sweep_law2.txt). It fired on no
  corpus row and no probe case. It did not fire on the two scanner false positives.
- Canaries: ok=52 (surelog) and ok=16 (uhdm2rtlil), changed=0; both ctcan2 checks PASS.
- Binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name law2 (the other 50
  hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346.
- Corpus UVM rows (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg): no byte
  move, so no determinism draw was needed. Both laws re-order or extend listings only
  where they fire, and they fire nowhere in the corpora.

## Residues (ranked)

1. uvm_param_vif_config_db, the SISTER's head (first): ParamEmit emitPackage writes no
   package virtual-interface typedef in either package view (golden interface_typespec
   at the interface NAME, 54:17 and 53:17). Also on that face: our TOP-view listing and
   hvl_top's module listing carry the object spanned from `virtual` (54:9, 53:9), where
   golden starts at the interface name. A strict column face that rides with the same
   writer.
2. uvm_param_vif_config_db, this ground, NOT DECODED (no law written):
   the class-local `this_t` of the specializations sfr_agent #(SFR::...) and
   sfr_config_object #(SFR::...) (class_typespec this_t 51:9 and 50:9, parented by the
   generic's class_defn). Golden instances them at tb_params_pkg's DEFINITION view, ours
   at its TOP view. Cases TI/ti01 to ti07, ti09 and ti10 (value, class-scoped,
   two-argument, registry-typedef, method and virtual-interface shapes) all read golden
   TOP. The distinguisher is not reproduced on a small case, so no law was written.
   Next: bisect the row's own sources (sfr_agent_pkg's uvm macros, the extends chain).
   The tb_params_pkg string and int typespec instance culprits in the trace re-enter the
   package only and need no law of their own.
3. easyUVM (unchanged): its heads are the sister's (__FILE__ path, the default argument
   on exp.compare(rec), collectMaterializedPkgs).
4. The value-argument shapes § specValueArgRefObj470 does not reach (v11u470 VK/vk02,
   vk06, vk07, vk10; measured on law2, NOT_EQUAL 79, 87, 87, 87). vk02's head: golden's
   module variable `C #(K::w, 4) h;` class_typespec lists the K::w type_parameter and
   param_assign, ours writes no listing (RHS null). The listing writer
   emitClassPropSpecParams163 is reached only from the class-property predicate
   (TypeEmit foreignPkgHome163) and pass 460's package typedef drain, not from a module
   variable. Not written this pass.
5. The carried backlog of passes 470 and earlier (their READMEs), unchanged.

## Sister-ground faces (reported, not written)

- ParamEmit.cpp emitPackage: no VirtualInterfaceType branch in the package typedef
  loop (uvm_param_vif_config_db's first head). The package listing objects should start
  at the interface name, not at `virtual`.
- ExprEmit.cpp: easyUVM's __FILE__ string constant path and the default argument added
  to exp.compare(rec) (as pass 470 reported).
- EmitHelpers.h collectMaterializedPkgs: it compares raw buffers, where the root file of
  an include chain is needed (easyUVM's included modules and interfaces).

## Process

- The worktree's first build reproduced the main tree's binary (md5 68485a77...). No
  build, runner or case run started while the sister r11u477's sweep was live.
  drivers/quietwait.py (pass 466's) gated every launch.
- Binaries: law1 (first cut: § grpOwnOobGenericCls472 read only the DEF view's
  class_defns, which a package's DEF view does not list, so it fired nowhere), law2 (both
  views; FINAL, md5 21cd25b1...).
- One full five-stage sweep on law2 with the trace on. Stages probe, surelog,
  uhdm2rtlil and downstream ran from the worktree; the svtests stage ran through the main
  tree's tests/sweep.sh, because the worktree's UVM folder is empty. The main tree was at
  the same base with the same golden csv.
- The fence list was read into a file by a program and never printed. Every tree-wide
  list was path-filtered on it before a file was opened.

## Files

- cases/CL (8 dirs) and cases/TI (9 dirs).
- drivers: env.sh, runcase.sh, runuvm.sh, dist.sh, quietwait.py (adapted from
  r11u470repro), away.sh.
- evidence: grid_switches.txt, prediction.txt, away_census_law2.txt,
  pvc_heads_pristine.txt, pvc_heads_law2.txt, the sweep summaries, and tools/
  (pred472.cpp, clstf.cpp, pkgtf.cpp, clsts.cpp, pkgts2.cpp, pkgvars.cpp; build with
  `g++ -O2 -std=c++17 X.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj`).
