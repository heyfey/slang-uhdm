# r11u479 — expression/parameter ground, pass 479 (implementer)

Base 94a59927 (pass 477 landed). Ground: src/ExprEmit.cpp, src/EmitHelpers.h,
src/StmtEmit.cpp, src/ParamEmit.cpp (EmitHelpers.h untouched). Worktree build of the
base is byte-identical to the main tree's build/slang-uhdm (md5 5ba47529...).
Final law binary: law11 (md5 in evidence/binaries.txt), links slang 12.0.0+545f88b2e.

## Laws

Every law is read through src/LawSwitch.h (`lawOn(479, "R11U479_<LAW>_OFF")`);
`R11U479_OFF` drops all of them, `R11U479_TRACE=<dir>` logs each firing through
`lawTrace(479, ...)`. No src/R*.h, no LawState.h section, no getenv; the new
bookkeeping is one side map in ParamEmit (`pkgVifTd479`).

| law | switch | file | what it writes |
|---|---|---|---|
| § pkgVirtIfaceTd479 | R11U479_PKGVIFTD_OFF | ParamEmit | package typedef of a virtual interface: listing in both package views, importer clone span, the net copy |
| § pkgVifLocalBareCopy479 | R11U479_VIFLOCALCOPY_OFF | ParamEmit | procedural local typed by such a typedef binds the bare-named aliased copy |
| § vifTdLocalIsRefVar479 | R11U479_VIFLOCALREFVAR_OFF | StmtEmit (+ ParamEmit) | a block-item local declared through a typedef of a virtual interface is a ref_var |
| § parenCallCallee479 | R11U479_PARENCALLEE_OFF | ExprEmit | the callee-shape decoders read through a call's parentheses |

### § pkgVirtIfaceTd479 (cases PV, LV lv10, lv11; the r11u470 cases VB)

Decoded from Surelog CompileHelper::compileTypeDef (CompileHelper.cpp, the `else` branch
that steps past `paVIRTUAL`): `typedef virtual I [#(...)] [.mp] t;` keeps the
interface-name node as its type and, in a package or a file (Reduce::Yes), compiles
its typespec at once: the interface_typespec of the interface name, spanned over the
name (and the modport), never over `virtual` or the parameter list. UhdmWriter lists
it in the package's typedef vector in both views, and the importers' listings carry
the importer's copy. ParamEmit's emitPackage typedef loop had no VirtualInterfaceType
branch (`ts` stayed null, `continue`): the typedef was listed in neither package view,
an importer's clone (built in the import-copy branch) took the whole written type as its
span (`virtual` .. `)`), and a net typed by it bound the shared listing object.
The law (a) lists the typespec builder's interface_typespec named pkg::t, parented and
Instanced at the package, in both views; (b) keeps the builder's span on the import
clone of such a typedef; (c) design-final (end of drainPaNameCopySrc38): a logic_net of
a module, interface, program or package whose own typedef listing holds the typedef
binds a fresh copy (same name pkg::t, span and vpiInstance, Typedef_alias -> the home
definition listing object), as golden; a net written `p::t h;` with no import binds
the listing object itself (PV/pv07), as golden.

### § pkgVifLocalBareCopy479 (cases PV pv09, pv18, LV lv03, lv04, lv07, lv08, lv12)

A variable directly under a begin, fork, function or task typed by such a package
typedef binds LAW S's per-use copy: bare name (t), the listing's span and
vpiInstance, Typedef_alias -> the definition listing object (golden pv18). It reads
§ pkgVirtIfaceTd479's map, so R11U479_PKGVIFTD_OFF turns it off too.

### § vifTdLocalIsRefVar479 (cases PV pv18, pv20, LV)

Surelog's compileVariable resolves a local's type name to the typedef's
interface_typespec, which getSimpleVarFromTypespec does not map, so the local falls
to ref_var; a local written `virtual I g;` takes the interface-name branch and stays
logic_var (PV/pv17, unchanged). StmtEmit's block-item local now writes ref_var for a
local whose declared type is a typedef ($unit, package, module or class) of a virtual
interface. Its twin in ParamEmit: § modVirtIfaceTd410's per-variable aliased copy
(UhdmExporter, the sister's) is given to logic_net and logic_var only, so the ref_var
local of a MODULE typedef gets the same copy (no vpiInstance, golden LV/lv02) from
ParamEmit's design-final pass.

### § parenCallCallee479 (cases PC; the v11u477 cases VP/vp10, vp13, vp26, the r11u477 case CD/cd21, the v11u207 cases E/e01, e03, H/h03)

slang stamps the ParenthesizedExpression on a call written `(f(a))`; § parenCallWrittenArgs477
made the written-argument decoders read through it, but the callee-shape decoders
(§ rootCallEatsTheChain150, § superMethodCall17, § staticScopedCall12) still read
`expr.syntax`, found no InvocationExpression and fell to the generic branches:
`(super.m(a))` was a hier_path where golden keeps the method_func_call with the
"super" prefix constant, `(C::sf(1))` a func_call where golden keeps
§ staticScopedCall12's ref_obj `C::sf` (span `C::`, arguments dropped),
`(C::mk().rd(7))` and `(dmk(51).twice(52))` missed § rootCallEatsTheChain150.
Surelog compiles a parenthesized primary's inner expression through the same
compileExpression / compileComplexFuncCall branches, so the shape is the unparenthesized
one (PC/pc01, pc02, pc06, pc07, pc12, pc19 controls; pc11u and pc16u twins read the
same as pc11 and pc16 with the law). NOTE: the brief's framing ("ours a ref_obj or
hier_path where golden writes a func_call") is half inverted: for `(C::sf(1))` golden
writes the ref_obj and ours wrote the func_call (PC/pc05, vp10's diff).

## The targeted rows (sv-tests, before -> after on the law binary)

- generated/uvm-examples/uvm_param_vif_config_db.sv: DIFFERENT -> DIFFERENT (no
  conversion; uhdm-cmp 172 -> 172 lines). Its definition-view tb_params_pkg now lists
  `interface_typespec tb_params_pkg::SFR_master_bfm_t` 54:17-54:31 and
  `SFR_monitor_bfm_t` 53:17-53:32 first, as golden (the eight listings that carry the
  two typedefs in golden, both views of tb_params_pkg and sfr_test_pkg, both views of
  hdl_top and hvl_top, now match golden in name, kind, position and span; the importer
  copies were 54:9 / 53:9 on pristine). The path-normalized dump distance to golden
  falls 928337 -> 928287; the law database differs from the control's in 62 dump lines,
  all on these typespecs. THE ROW'S FIRST DIFFERENCE WAS ALREADY THE SISTER'S FACE ON
  PRISTINE and stays it: uhdm-cmp pairs golden's definition-view tb_params_pkg (first
  typedef SFR_master_bfm_t) with our elaborated-view tb_params_pkg (first typedef
  SFR_agent_t), which is a vpiInstance compare under the SFR_agent_t / this_t class
  typespecs (golden the definition view, ours the elaborated view), pass 474's first
  item: the 172 lines read the same on pristine and law, with the listing face now
  gone from behind it. r11u470's reading (that the missing listing was the head) was a
  misread of that Instance compare. The row converts when the sister's this_t
  vpiInstance face lands on top of this law.
- generated/easyUVM/top.sv: DIFFERENT, unchanged (no pass-479 law fires on it; its
  heads are the sister's: ModuleEmit's ref_module listing, then the FILE macro's
  rest-of-line shift).
- p733, p737, tnoc: KNOWN EXCEPTIONS (user 2026-11-02), not targeted, unchanged.
- generated/uvm-examples/uvm_use_models_pipelined_get_put.sv: EQUAL at this base
  (the brief listed it as open; results/golden_svtests.csv reads EQUAL).

## Goal 1 (evidence/goal1.txt)

Unchanged and re-measured: C::mk().arr[1] and u.mk(x).a[2] exit 4 in ours, 0 upstream,
3 in Surelog (syntax); this.mk().inner.s exports (0), Surelog 3: not forced. bp_unicore
alone with the size guard on: rc 3, 17.2 s, 827 MB max RSS: the guard stays. All 75
SURELOG_ONLY details are upstream slang front-end diagnostics; none is the exporter's.

## Grid (evidence/grid.txt, grid_raw.txt; drivers/runcase.sh: Surelog golden with
check_probe.py's flags, ours `dut.sv --single-unit --nobuiltin`, rc, uhdm-cmp lines,
strict verdict, path-normalized dump distance)

65 case dirs (PV 31, LV 12, PC 22), every one accepted by upstream slang, every exit
code 0 on both binaries:
- NOT_EQUAL -> STRICT_EQUAL 39; NOT_EQUAL -> STRICT_NOTEQUAL 1 (PC/pc11, fullname,
  the same reading as its unparenthesized twin pc11u); NOT_EQUAL -> NOT_EQUAL 16; byte
  or verdict controls STRICT_EQUAL -> STRICT_EQUAL 8 (pv17, pc01, pc02, pc06, pc07,
  pc12, pc19, pc20) and STRICT_NOTEQUAL -> STRICT_NOTEQUAL 1 (pc11u).
- no dump distance grows on any of the 65 (law <= pristine everywhere).
- the 16 still NOT_EQUAL, each at a later head or an older face (see residues):
  pv09, pv11, pv12, pv13, pv16, pv19, pv22, pv25, pv31, pv32, lv05, lv06, lv07, lv09,
  pc16, pc16u.
- external grids: r11u470 VB/vb01 to vb05 NOT_EQUAL -> STRICT_EQUAL (5);
  r10v223repro/arms/v12_virtual_iface NOT_EQUAL 79 -> STRICT_EQUAL; r11u472 TI/ti10
  NOT_EQUAL 90 -> 40 lines (dump distance 53 -> 43); v11u477 VP/vp10, vp13, vp26 and
  r11u477 CD/cd21 NOT_EQUAL -> STRICT_EQUAL; v11u207 E/e01, e03, H/h03 NOT_EQUAL ->
  STRICT_EQUAL.
- downstream (evidence/downstream_grid.txt, drivers/dsgrid.py over
  downstream_uhdm2rtlil.one): 15 movers, none moving away from IDENTICAL; PV/pv02,
  pv27 STATUS_DIFF -> IDENTICAL, PC/pc03, pc05, pc09 EQUIVALENT -> IDENTICAL, the
  other 10 IDENTICAL on both.

Switches (evidence/swcheck.txt, drivers/swcheck.sh): R11U479_OFF gives pristine's bytes
and exit code on 79 of 79 dirs (the 65 plus the 14 external movers); each law's own
switch restores pristine on the dirs only it moves (PARENCALLEE 20, PKGVIFTD 34,
VIFLOCALREFVAR 5) and moves the dirs where several laws fire (lv03, lv04, lv07, lv08,
lv12, pv09, pv18 and lv05).

## Away census (evidence/away_law9_virtual.tsv, away_law10.tsv; drivers/away.sh)

Every earlier case dir (tools/probe and tests/probe, fence-filtered first) whose dut.sv
says `virtual` (688) or writes a parenthesized `(X::f(` / `(a.f(` call (454), 1115
dirs, pristine and the law binary from each dir: no exit code moves; 14 dirs move bytes,
all toward golden (listed above: VB x5, v12_virtual_iface, ti10, cd21, vp10, vp13,
vp26, e01, e03, h03), 1101 byte-identical. (law10 and law11 differ only in comments and
one `static`; their bytes are equal on all 65 grid dirs.)

## Prediction and census (evidence/prediction.txt, census.tsv; drivers/census.py)

Written before the sweep from pristine and law11 over every fence-filtered row-mode
(10616: probe 4087, surelog 789 + 784, uhdm2rtlil 870 + 870, downstream 870, sv-tests
2346), the law traced: no exit-code mover; byte movers only in sv-tests:
uvm_param_vif_config_db (by § pkgVirtIfaceTd479) and two pristine coins
(uvm_id_register, the order of hvl_top's `this` net, and
uvm_use_models_pipelined_get_put, dump-identical; both read two hashes on pristine
itself and STRICT_EQUAL on both binaries). Firings: § parenCallCallee479 6318 times on
158 sv-tests rows (uvm_pkg's own parenthesized class-scope calls, 24 per UVM row), 21
surelog row-modes (BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, Tnoc,
Earlgrey_0_1, BitSelectPartSelectInFunction, IncompFunc, PackedEnumVar, UnsizedFunc),
8 uhdm2rtlil row-modes, 4 downstream rows and 8 probe cases, every one with identical
bytes (the unwrap reaches a decoder that decides the same shape); § pkgVirtIfaceTd479
4 times on uvm_param_vif_config_db; the two local laws nowhere. The census ran while
the sister's verifier v11u474 started its sv-tests sweep (it was quiet at launch); the
census reads bytes and exit codes only and read no TIMEOUT.

## The sweep (one full five-stage sweep on law11, evidence/sweep_*.log)

tests/sweep.sh --jobs 3 from the worktree with SLANG_UHDM=/tmp/r11u479_bin/law11 and
the trace on (probe, surelog, uhdm2rtlil, downstream), the sv-tests stage through the
main tree's tests/sweep.sh (the worktree's UVM folder is empty); each exits 1 on a
stale law index alone (the worktree's, from this README written after the index run;
the main tree's own):
- probe: EQUAL 4024, STRICT_NOTEQUAL 63, regressions 0, conversions 0, changes 0.
- surelog: default CMP_EQUAL 480, testflags 474 (Tnoc d/t CMP_NOTEQUAL standing),
  0/0/0.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0 (stamped_gen_param d/t CMP_NOTEQUAL).
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not
  identical and not excused 0.
- sv-tests: EQUAL 1935, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions 0, conversions 0, changes 0.
Every csv equals the master's control at the base (/tmp/intr11u477) row for row after
path normalization (probe, surelog, uhdm2rtlil, downstream, svtests).
byteverify (SELFCHECK=1) against the control: surelog 0 of 962, uhdm2rtlil 0 of 1608,
downstream 0 of 805 (negative controls 961/962, 1607/1608, 804/805 flagged); probe 4087
of 4087 dumps identical after path normalization (negative control 4085 flagged).
Canaries ok=52 changed=0 and ok=16 changed=0; both ctcan2 checks PASS. Binary audit
(fence-filtered): surelog 1523 of 1573 records name law11 (the other 50 hold only a
Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346, no record naming another
slang-uhdm binary. The sweep's trace reads exactly the census's firing rows (158
sv-tests, 21 surelog, 8 uhdm2rtlil, 4 downstream, 8 probe; 6318 + 4 firings).

## Residues (ranked; all wrong on pristine too, none moved away)

1. uvm_param_vif_config_db's head: the vpiInstance of the SFR_agent_t / this_t class
   typespecs (golden tb_params_pkg's definition view, ours its elaborated view):
   the sister's (pass 474), see above.
2. A procedural local of a FUNCTION or TASK declared through a typedef of a virtual
   interface stays logic_var where golden writes ref_var (PV/pv09 `f.h`): TaskFuncEmit's
   § blockLocalTdDeclIsRefVarUnsupported155 SITE 1 (the subroutine-body local), the
   sister's; its typespec copy is now golden's.
3. A subroutine FORMAL typed by a package virtual-interface typedef binds the listing
   where golden binds a bare per-use copy spanned at the USE (PV/pv16 8:36-8:40, pv19
   5:28-5:32; LAW S in TypeEmit, `pkgScalarTd` lists no interface_typespec): the
   sister's.
4. A typedef of such a typedef (`typedef vt_t vt2_t;`): golden lists t::vt2_t in the
   TOP view only, aliased to a bare copy of vt_t (PV/pv11, LV/lv05): not decoded
   further; ParamEmit's alias-of-alias branch would take it.
5. A program's import listing lists no package typedef of any kind (PV/pv22, the scalar
   control pv31) and a module's listing omits a typedef re-exported by an explicit
   `export p::t` (pv25, the scalar control pv32): older listing faces, ModuleEmit's.
6. `vt_t arr[2];` in a module: golden writes one logic_net (no array_net) whose copy
   ends at the dimension (6:38) (PV/pv12): ModuleEmit's array-net face, then the copy's
   end.
7. `D#(vt_t) d;` (PV/pv13): ours mints a net named vt_t (head moved later; golden none).
8. A write to a VI-typedef ref_var local (`g = null;`) binds an implicit net in golden
   (LV/lv07, lv09): the implicit-net mint at a ref_var local, not written.
9. A class-scoped virtual-interface typedef is not listed under the class
   (LV/lv06; UhdmExporter's class typedef listing, the sister's).
10. PC/pc16 (and its twin pc16u): a static class call inside a package function, an
    older face equal on both spellings.
11. Carried: pass 477's residues (vp08's return share with a defaulted formal; va09 and
    va36, whose range bound reads `paramIntEnc` directly in TypeEmit, so the whole-read
    INT form needs a second marker read there, the sister's ground; va04's overflow
    re-fold; rf03/vr11 program in an included file; rf07) and the carried lists of
    passes 475 and earlier.

## Sister-ground faces (reported, not written)

- uvm_param_vif_config_db's head (pass 474's item 1), see residue 1.
- TaskFuncEmit § blockLocalTdDeclIsRefVarUnsupported155 SITE 1: a function/task local
  through a virtual-interface typedef is a ref_var in golden (PV/pv09).
- TypeEmit LAW S (§ bareScalarTdCopyOf, `pkgScalarTd`): formals typed by a package
  virtual-interface typedef bind a bare copy at the use span (PV/pv16, pv19).
- TypeEmit's range builder reads `paramIntEnc` directly (the v11u477 cases VA/va09,
  va36): the whole read of a parameter whose initializer is an add with a 'd leaf
  is INT in golden.
- ModuleEmit: program import listings (PV/pv22, pv31), explicit-export re-listing in a
  module (pv25, pv32), the module array net of virtual-interface typedef elements
  (pv12).
- UhdmExporter: class-scoped virtual-interface typedef listing (LV/lv06).

## Process

Within the budget: no pristine build of my own beyond the worktree's first build
(byte-identical to the main tree's, frozen as the pristine), no pristine sweep (the
master's control /tmp/intr11u477 is the pristine reading); law1 to law11 on case runs
only; one census (pristine and law11) and one full five-stage sweep on law11; one
byteverify. The fence list was read into a file by a program and never printed; every
tree-wide list was filtered on it before any file was opened; no fenced test named,
opened or run; the evidence folder was scanned with the fence list (no hit). No other
agent's process touched. Slips: one build failed to compile (law3's first build) and
my launcher had copied the stale binary under the new name before I added the
build-success guard (drivers: drivers/bld.sh); the stale run was discarded and
rerun. The first four-stage launch passed `--corpus` an unquoted list and stopped at
the usage line before running anything; it was relaunched after the sv-tests stage.
