# v11u479 — adversarial verification of r11u479

Base 94a59927 (pass 477 landed). The implementer's patch /tmp/r11u479.patch applied clean on a fresh worktree
(/tmp/wt_v11u479). VERDICT: CONFIRMED WITH ONE BREAK FIXED (§ vifTdClsScopedAbstain479v, StmtEmit). No sv-tests
row converts (none could: the targeted row's first difference is the sister's face on both binaries), every gate
reads 0 regressions on the law binary and on the verified binary, and every csv of both sweeps equals the master's
control /tmp/intr11u477 row for row.

## Binaries (evidence/binaries.txt)

- pristine: a copy of the main tree's build/slang-uhdm, md5 5ba4752987885570af816df43e96f9e0 (no pristine build,
  no pristine sweep: the master's control is the pristine reading).
- law: rebuilt once from the patch in the worktree, md5 6179073bad95337e0d3e88d55298ed2d = the implementer's law11;
  links slang 12.0.0+545f88b2e.
- ver1 (verified): law + § vifTdClsScopedAbstain479v, md5 7347b3417a262cd8ca085f3e8a13ed5c (the second and last build).

## The break and its fix: § vifTdClsScopedAbstain479v (R11V479_CLSSCOPED_OFF; R11V479_OFF)

§ vifTdLocalIsRefVar479 (StmtEmit) makes ref_var of every block-item local whose declared type is a typedef of a
virtual interface, the README saying "$unit, package, module or class". For a local whose type is written as a
CLASS-SCOPED name, golden writes class_var over an unsupported_typespec K::v_t (Surelog does not resolve the
class-scoped type name, so compileVariable takes its unresolved-name branch), which pristine wrote; the law wrote
ref_var:
- VL/vl17 (`class K; typedef virtual ifc v_t; endclass` + `initial begin K::v_t g; end` in a module):
  pristine NOT_EQUAL 25 lines dump distance 12 -> law 25 lines distance 16 (class_var -> ref_var at work@top.g)
- VL/vl19 (the same local in another class's task): 14 lines distance 12 -> law 56 lines distance 16
- VL/vl21 (`p::K::v_t g;`, the class in a package): 27 lines distance 12 -> law 27 lines distance 16
The ref_var branch holds for an unqualified name: the implementer's LV/lv06 (own class typedef) and the fresh VL/vl18
(an inherited typedef used unqualified in a derived class's task) are golden's ref_var and stay improved.
The fix (StmtEmit, the helper vifTdClsScopedName479v, read inside the law's condition): abstain when the type
syntax is a NamedType over a ScopedName and the alias is declared in a class (ClassType or GenericClassDef);
a package-qualified local `t::vt_t g;` is left to the law (Surelog v1.87 segfaults on it, no golden: tried as a
first VL/vl16 and replaced). The fix gives pristine's bytes on vl17, vl19, vl21 and the law's bytes on every
other one of the 143 grid dirs (evidence/sw3.txt); R11V479_OFF and R11V479_CLSSCOPED_OFF each give the law's bytes
on all 143.

## Reproduction of the implementer's numbers

- Grid: the implementer's 65 dirs (PV 31, LV 12, PC 22) rerun on pristine and law: exit code, uhdm-cmp line count,
  strict verdict and dump distance equal to its evidence/grid_raw.txt on 130 of 130 lines
  (evidence/impl_grid_rerun.txt; the md5s differ only by the worktree path in the file field); ver1 writes the law's
  bytes on all 65.
- External movers: r11u470 VB/vb01 to vb05, r10v223 v12_virtual_iface, v11u477 VP/vp10, vp13, vp26, r11u477 CD/cd21,
  v11u207 E/e01, e03, H/h03 NOT_EQUAL -> STRICT_EQUAL; r11u472 TI/ti10 90 -> 40 lines (dump distance 53 -> 43).
- Switches: R11U479_OFF gives pristine's bytes and exit code on 143 of 143 dirs (the implementer's 79 and my 64).
- Target row (evidence/target_row.txt): generated/uvm-examples/uvm_param_vif_config_db.sv DIFFERENT -> DIFFERENT,
  uhdm-cmp 172 -> 172 lines with the same pairing (golden's definition-view tb_params_pkg SFR_master_bfm_t against
  our SFR_agent_t class_typespec: the vpiInstance face, the sister's), the listing now golden's (26 interface_typespec
  SFR_m* dump lines as golden, pristine 24), dump distance 928335 -> 928285.
- Prediction and sweeps: the trace of the verified sweep reads § parenCallCallee479 6318 and § pkgVirtIfaceTd479 4
  firings, the implementer's census exactly; no local law, no fix firing on any gate row.

## Sweeps (one on the law binary, one on the verified binary; evidence/sweep_*)

tests/sweep.sh --jobs 3 from the worktree (probe, surelog, uhdm2rtlil, downstream), the sv-tests stage through the
main tree's tests/sweep.sh with SVTESTS_ROOT set (the worktree's UVM folder is empty), launched on a quiet machine
one after the other; each command exits 1 on the stale law index alone. Both read:
- probe: EQUAL 4024 + STRICT_NOTEQUAL 63, regressions 0, conversions 0, changes 0.
- surelog: default CMP_EQUAL 480, testflags 474, 0/0/0 (Tnoc d/t CMP_NOTEQUAL standing).
- uhdm2rtlil: 803/1/67 both modes, 0/0/0 (stamped_gen_param d/t CMP_NOTEQUAL).
- downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; not identical and not excused 0.
- sv-tests: EQUAL 1935, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of
  2346; regressions 0, conversions 0, changes 0.
- every csv of both sweeps equals the control's row for row after workdir-path normalization (5 of 5, both sweeps).
- byteverify (SELFCHECK=1): law vs control surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805 (negative
  controls 961, 1607, 804 flagged); ver1 vs law 0/962, 0/1608, 0/805; probe: 4087 of 4087 dumps identical law vs
  control after path normalization (negative control 4085 flagged), 4087 of 4087 databases byte-identical ver1 vs law.
- canaries on the verified csvs: ok=52 changed=0 and ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 and 6).
- binary audit (fence-filtered cmds.txt): surelog 1523 of 1573 records name the binary under test (the other 50 hold
  only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346; no record names another slang-uhdm binary.

## Attack grid (cases/VA, VC, VL; 64 dirs; evidence/grid.txt, upstream_slang.txt, downstream_grid.txt)

Every case accepted by upstream slang (rc 0, negative control rc 1). Exit codes equal on all three binaries (vl05 and
vl20 exit 4 on all three: a goal-1 face, below). Verdicts pristine -> law -> ver1: STRICT_EQUAL 5 -> 39 -> 39,
STRICT_NOTEQUAL 1 -> 4 -> 4, NOT_EQUAL 58 -> 21 -> 21; dump distance up on law only at vl17, vl19, vl21 (the break),
on ver1 nowhere.
- VA (§ pkgVirtIfaceTd479, 19): to STRICT_EQUAL va02 (a parameterized child instantiated twice, a generate-block net),
  va06, va08 (listing order among int, logic and parameter items), va11 (`var vt_t h`), va12 (a modport typedef in an
  importing package), va13, va14 (a $unit and a package vif typedef side by side), va16, va17 (a parameterized
  interface without parameters), va18 ($unit import), va19 (re-listing through a second package); va05 (`t::vt_t h =
  null;`) STRICT_NOTEQUAL endline, golden moving the shared listing object's end to 6:29, a Surelog artefact; va07
  (`virtual ifc #(8).mp`) STRICT_NOTEQUAL endcol: golden spans the name alone, 4:19-4:22, when parameters AND a modport
  are written, ours 4:19-4:30 (a new law object, pristine wrote none: a residue of the law); va01, va03, va04, va09,
  va10, va15 closer at older faces (subroutine-local kind, implicit nets).
- VC (§ parenCallCallee479, 23): to STRICT_EQUAL vc01 to vc06, vc08 (generate block), vc09 (double parentheses),
  vc10, vc14 (a parameterized base), vc15 (if condition), vc17 (two instances), vc18 (ternary), vc20 (an out-of-body
  method), vc22 (package classes); byte-identical controls vc07, vc11, vc12, vc13, vc16, vc21u; vc19 (`assign z =
  (C::sf(1));`) NOT_EQUAL -> STRICT_NOTEQUAL type at the elaborated cont_assign golden leaves empty (older face);
  vc21 (`int k = (C::sf(4));` class property) NOT_EQUAL 46 -> 15 lines, see finding 1.
- VL (local laws and the fix, 22): to STRICT_EQUAL vl04, vl06 (module modport typedef), vl10 (two instances), vl12,
  vl13 (nested blocks), vl15, vl16 (a package class constructor local), vl22; vl17, vl19, vl21 the break (fixed);
  vl18 closer; vl01, vl02, vl03, vl08, vl09, vl11, vl14 closer at the subroutine-local kind or listing faces;
  vl07 byte-identical; vl05 and vl20 exit 4 on all three binaries (the goal-1 face below), dump distance
  32 -> 28 and 28 -> 24 on the partial output.
- downstream (19 movers, pristine -> ver1): none moving away from IDENTICAL; va06, va13, va18 STATUS_DIFF ->
  IDENTICAL, vc04, vc08, vc17 EQUIVALENT -> IDENTICAL, vc15 DIVERGENT -> IDENTICAL, vc19 EQUIVALENT on both.

## Away census (evidence/away.tsv, away_movers.txt)

2499 fence-filtered earlier case dirs under tools/probe and tests/probe whose dut.sv writes `virtual`, a
parenthesized scoped or dotted call, or a scoped type declaration, on pristine, law and ver1: no exit code moves;
14 dirs move bytes under the law, exactly the implementer's 14 external movers (all STRICT_EQUAL or closer, above);
ver1 equals the law on all 2499.

## Findings (not breaks)

1. § parenCallCallee479 with UhdmExporter's class-property initializer (the sister's file): `int k = (C::sf(4));`
   (VC/vc21) loses its vpiExpr: UhdmExporter's scopedCallName29 does not read through the parentheses, so the
   initializer falls to its last branch, which keeps only a func_call, and emitExpr now returns § staticScopedCall12's
   ref_obj. Pristine wrote a func_call (wrong kind), golden the ref_obj C::sf; the unparenthesized twin vc21u is
   STRICT_EQUAL on all binaries. uhdm-cmp 46 -> 15 lines, dump distance 17 -> 8. The fix is scopedCallName29 reading
   through a ParenthesizedExpression (UhdmExporter): the sister's ground, reported.
2. The implementer's README says the ref_var law covers "class" typedefs: true only for an unqualified name (the fix).

## Residues (ranked; all wrong on pristine too, none moved away on ver1)

1. uvm_param_vif_config_db's head, the this_t / SFR_agent_t vpiInstance face (the sister's, pass 474).
2. Subroutine locals and function return variables typed by a vif typedef stay logic_var where golden writes ref_var
   (VA/va01, va03, VL/vl01, vl02, vl14; TaskFuncEmit § blockLocalTdDeclIsRefVarUnsupported155 SITE 1, the sister's).
3. A write to or read of a vif-typedef local binds an implicit module net in golden (VA/va15, the implementer's
   lv07, lv09).
4. The span of a vif typedef written with parameters and a modport (VA/va07, golden the name alone).
5. Goal 1: a $unit typedef of a vif typedef (VL/vl05) or of a class-scoped vif typedef (VL/vl20) exits 4,
   "typedef target: VirtualInterfaceType", in UhdmExporter's / TypeEmit's $unit typedef builder (the sister's).
6. finding 1 (vc21) and the implementer's residues 2 to 11.

## Sister-ground faces (reported, not written)

- UhdmExporter scopedCallName29 (§ classPropScopedCallIsRefObj29): read through a parenthesized call (VC/vc21).
- UhdmExporter / TypeEmit noteUnsupported("typedef target: ...") on a $unit typedef of a vif typedef (VL/vl05, vl20).
- TaskFuncEmit SITE 1: subroutine-local and return-variable kind (VA/va01, va03, VL/vl01, vl02).

## Process

Within the budget: one law build, one verified build, one five-stage sweep on each (sequential, quiet machine at
launch); byteverify once per binary. The fence list was read into a file by a program; SLIP: the shell command that
located the FENCED= line in tools/probe/r11u107repro/canaudit.sh printed the line cut at 20 characters, which shows
the first 9 characters of one fenced name; no fenced test was named in full, opened, read or run, every tree-wide
list was filtered on the fence file before any file was opened, and this folder was scanned with it before delivery.
The 64-dir attack grid reruns of all three binaries (single process) ran while the law sweep's probe stage was live
and the target-row runner calls while the probe dump comparison ran; neither sweep read a TIMEOUT or any change.
The verified sweep's trace directory was created a few seconds after the sweep started (the tally equals the
implementer's census, so no firing was lost). No other agent's process touched.
