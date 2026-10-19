# v11u408 — adversarial verification of r11u408 (module/type ground, sv-tests campaign)

Base e748204c (pass 406). Verdict: **VERIFIED, no production refinement.** The
verified patch carries the implementer's three source files unchanged
(src/ModuleEmit.cpp, src/UhdmExporter.cpp, src/TaskFuncEmit.cpp), its
tools/probe/r11u408repro, this directory and the regenerated tests/LAWS.md.
No fresh case on legal SV found a place where pristine was right and the law
wrong, so no `§ <name>408v` was written and no second sweep was run (the
measurement budget).

## Binaries

- Pristine: not built (budget). The implementer's frozen pristine copy has md5
  cd23107a552e7e853195ee4a4923716f, the base build's md5 from the brief; it was
  used only for case grids. The pristine sweep reading is the master's control
  /tmp/intr11u406 (its csvs equal the committed results/*.csv at e748204c).
- Law: rebuilt once from the implementer's patch applied to a fresh e748204c
  worktree, `-j 2`: md5 aa17501c936ae1e9bdd790be09149b36, equal to the
  implementer's law binary. Frozen read-only before any measurement. It reports
  slang 12.0.0+545f88b2e.
- No-header audit: the source diff adds no src/R*.h, no getenv and no reader
  function; every switch reads through lawOn(408, ...); include/ and
  uhdm_main.cpp are unchanged.

## The laws under test (the implementer's; switches unchanged)

| law | switch |
|---|---|
| § ifaceClassNotListed408 | R11U408_IFACECLASS_OFF |
| § unitTaskNotListed408 | R11U408_UNITTASK_OFF |
| § classBoundedQueueStatic408 | R11U408_CLSBOUNDEDQ_OFF |
| § genericClassNoDefaultListed408 | R11U408_GENCLSNODEF_OFF |
| § classImpTdParamTsClone408 | R11U408_CLSIMPTSCHAIN_OFF |

R11U408_OFF drops all five.

## Gate: one five-stage sweep on the law binary (workdir /tmp/v11u408_lw)

`tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil downstream"` from
the worktree, then the sv-tests stage through the main tree's
scripts/check_svtests.py (read-only; a worktree has no UVM tree; scripts/ is
unchanged between e748204c and the main tree's HEAD) with
`--baseline` = results/golden_svtests.csv at e748204c, so pass 405's promoted
rows cannot show as false regressions. The machine was quiet at launch.

- probe: EQUAL 4018, STRICT_NOTEQUAL 69 of 4087; regressions=0 conversions=0
  changes=0. probe.csv is byte-identical to the control's. All 4087 databases are
  identical to the control's by normalised dump (source root replaced); a
  negative control on two different databases differs.
- surelog: default CMP_EQUAL 480, testflags 474; regressions=0 conversions=0
  changes=0. The csv differs from the control only in the LowMemLib and
  LowMemPkg testflags detail text (the workdir path in Surelog's log line).
- uhdm2rtlil: 803/1/67 in both modes; 0/0/0; csv byte-identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871;
  not identical and not excused 0; csv byte-identical to the control.
- sv-tests: EQUAL 1569 -> 1598, STRICT_NOTEQUAL 9 -> 16, DIFFERENT 361 -> 325,
  BOTH_REJECT 303, SURELOG_ONLY 76, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of
  2346; **regressions=0 conversions=36 changes=0**. The csv is byte-identical to
  the implementer's. Against the control, 36 rows move status and no other row
  changes any field (status, detail or strict).
- byteverify (SELFCHECK=1) of the law workdir against /tmp/intr11u406: surelog
  0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805 movers; path sets
  identical; the self-checks flag 961, 1607 and 804.
- Canaries: canaries.sh ok=52 changed=0 (surelog) and ok=16 changed=0
  (uhdm2rtlil); ctcan2 EXPECT_UNKNOWN=1 ok=58 PASS and EXPECT_UNKNOWN=6 ok=2
  PASS.
- Binary audit: 3323 cmds.txt in the four corpus stages; the path list was
  fence-filtered first (3313 left). 3263 name /tmp/v11u408_bin/law.bin, 0 name
  another slang-uhdm binary, and the other 50 hold no slang line. (Two
  CoresSweRV records match the repo name in Surelog's UVM path only.)
- Trace census (R11U408_TRACE over the whole sweep): 0 firings in the probe and
  in the surelog, uhdm2rtlil and downstream stages; every trace file names an
  sv-tests database. 190 sv-tests rows fire: classImpTdParamTsClone408 153,
  ifaceClassNotListed408 28, genericClassNoDefaultListed408 6,
  unitTaskNotListed408 5, classBoundedQueueStatic408 4 (the implementer's
  census exactly). The positive control (VI/vi05, VT/vt02, VQ/vq03, VG/vg05,
  VU/vu13) writes trace lines for all five laws.
- Determinism: three concurrent draws of the law binary on
  generated/uvm_classes_2/uvm_agent_class_2 (one hash, equal to the sweep's
  database) and on hdlconvertor_std2012_p160_1 (one hash).

## sv-tests conversions (36, every one attributed by its own trace file)

- § ifaceClassNotListed408 alone, DIFFERENT -> EQUAL (19): chapter-8/8.26.2--implements,
  8.26.2--implements_extends, 8.26.2--implements_multiple, 8.26.3--type_access_extends,
  8.26.6.1--name_conflict_resolved, 8.26.6.2--parameter_type_conflict,
  8.26.6.3--diamond_relationship, 8.26.7--partial_implementation;
  generic/iface/iface_class_test_0, _1, _2, _9, _10; generic/class/class_test_25, _28, _29;
  generated/hdlconv_std2017/hdlconvertor_std2017_p199, p200_2, p202.
- § ifaceClassNotListed408 + § classBoundedQueueStatic408, DIFFERENT -> EQUAL (4):
  hdlconvertor_std2012_p158, p160_1, hdlconvertor_std2017_p194, p196.
- § unitTaskNotListed408, DIFFERENT -> EQUAL (4): hdlconvertor_std2017_p230, p332, p530, p728.
- § genericClassNoDefaultListed408, DIFFERENT -> EQUAL (2): generic/class/class_test_9, class_test_11.
- § classImpTdParamTsClone408, DIFFERENT -> STRICT_NOTEQUAL (7), strict `differ:col(4)`:
  generated/uvm_classes_2/uvm_{agent,driver,env,monitor,scoreboard,sequencer,test}_class_2.

Away census (evidence/svtests_away_census.txt): on each of the 190 fired rows,
the distance to golden (normalised dump line multiset) of the control's
database and of the law's. 151 rows move toward golden, 0 stay at the same
distance, and 0 move away. 31 rows have no law database because they are EQUAL
(the 29 EQUAL conversions, plus class_test_26 and _27, which are EQUAL on both).
8 rows have no Surelog golden (SLANG_ONLY): 18.5.11--static-constraint-blocks_1,
8.26.5--cast_between_interface_classes, 8.26.5--implemented_class_handle,
hdlconvertor_std2017_p771, and uvm-examples uvm_overriding, uvm_slave_agent,
uvm_slave_agent_multi_seq_item and uvm_wait_for_signal.

## The implementer's grid, reproduced

All 34 case dirs were rerun with the frozen binaries and a fresh golden from
Surelog v1.87 (evidence/impl_grid_reproduced.txt). Every exit code, uhdm-cmp
line count and strict verdict equals the implementer's grid line. The raw md5s
differ only because the databases embed the source path. Where the
implementer's pristine and law md5s are equal, so are these. R11U408_OFF gives
pristine's bytes and exit code on 34 of 34. Each group's own switch gives
pristine's bytes on 34 of 34. Downstream on UT ut01 to ut06 reads the same on
both binaries: ut02 is EQUIVALENT on both, the rest IDENTICAL.

## Attack grid: 60 fresh case dirs (cases/, every first line names its law; evidence/grid.txt)

Golden: `surelog -parse -nobuiltin -nocache -sv dut.sv`. Ours:
`dut.sv --single-unit --nobuiltin` (drivers/run1.sh). Each line records exit
code, uhdm-cmp lines, strict verdict, md5 and the dump-multiset distance to
golden, pristine -> law.

- **Totals:** 25 NOT_EQUAL -> STRICT_EQUAL, 23 NOT_EQUAL toward golden, 10 NOT_EQUAL with
  pristine's bytes, and 2 controls with pristine's bytes (VU/vu01 STRICT_EQUAL, VU/vu02
  STRICT_NOTEQUAL on type). 0 cases move away and no exit code changes.
- **Switches:** R11U408_OFF gives pristine's bytes and exit code on 60 of 60. The group's
  own switch gives pristine's bytes on 60 of 60.
- **Downstream:** on VT/vt01 to vt04 and vt06 to vt09 and on VI/vi05, vi09, VQ/vq03,
  VG/vg05 and VU/vu13, the verdict is the same on both binaries: IDENTICAL, except vt07 and
  vt08, which are EQUIVALENT on both with an identical slang-lane nohier.il. Golden writes
  the module's call to a `$unit` task as an unlinked func_call, so the Surelog lane drops the
  task body.

Per group:
- VI (§ ifaceClassNotListed408): vi03 (forward `typedef interface class`), vi04
  (interface scope), vi05 (implements two, extends a parameterized class), vi06
  (package interface class implemented at $unit), vi08 (program scope), vi09
  (a subclass of an implementer), vi10 (parameterized interface class) enter
  STRICT_EQUAL. vi01 (an interface class as a class type parameter),
  vi02 (as a method argument) and vi07 (an array of handles in a module) move
  toward and stay NOT_EQUAL: the interface-class-typed object residue below.
  Golden itself errors (CP0317 Undefined type) on vi02, vi03, vi07.
- VT (§ unitTaskNotListed408): vt02 (a task calling a task), vt03 (beside a
  package task), vt09 (beside extern class methods) enter STRICT_EQUAL; vt05
  (called from a class), vt06, vt07 and vt08 (called from a module) move toward;
  vt01 (DPI import task) and vt04 (DPI export task) keep pristine's bytes (the
  law does not fire).
- VQ (§ classBoundedQueueStatic408): vq03 (a class-header parameter bound), vq07
  (a specialized class), vq08 (static, struct and class elements), vq09 (a class in a module)
  enter STRICT_EQUAL. vq01, vq02, vq04, vq05 and vq06 move toward, with residues named
  below. vq10 (`int q[$:3][2]` and `int r[2][$:3]`) exits 4 on both binaries
  (a goal-1 residue below).
- VG (§ genericClassNoDefaultListed408): vg01 (untyped), vg03 (extended
  by a specialization), vg05 (also specialized), vg06, vg09, vg10, vg13 (package
  class specialized twice), vg17 (a constraint) enter STRICT_EQUAL; vg02, vg04,
  vg11, vg12, vg15 move toward; vg07 (with a type parameter), vg08 (module
  scope), vg14 (nested in a class), vg16 (dependent unpacked and queue
  dimensions) keep pristine's bytes.
- VU (§ classImpTdParamTsClone408): vu06 (a parameterized class), vu08 (an
  explicit import), vu13 (a localparam) enter STRICT_EQUAL. vu03, vu04, vu05, vu07, vu12 and
  vu14 move toward. vu05 (`typedef int`) moves its uhdm-cmp head from the class copy to the
  module copy `work@top.A`, which is the sister's ParamEmit face, so its cmp output grows
  36 -> 48 lines while its distance falls 566 -> 314. vu01 (enum typedef, STRICT_EQUAL)
  and vu02 (packed struct, STRICT_NOTEQUAL) are controls with unchanged bytes. vu09
  (unpacked-array typedef), vu10 (string) and vu11 (real) keep pristine's bytes: no copy
  for those kinds.

## Residues (all wrong on pristine too; none moved away), ranked by reach

1. **The ~107 UVM rows: the sister's face.** The elaborated module copy of a `$unit`-imported
   typedef-typed parameter is an int_typespec where golden has the cloned chain (ParamEmit
   makeParamTs / patchParamTypespecs). VU/vu05 and the implementer's UC/uc01 show it.
2. **Interface-class-typed objects.** Golden errors (CP0317) and writes the object
   with an unsupported_typespec. Shapes: a class type parameter (VI/vi01), a method argument
   (vi02), a module array of handles (vi07), and the implementer's ic06 and
   chapter-8/8.26.3--type_access_implements.
3. **Goal 1, a new face: exit 4 on suite-legal SV that upstream slang accepts.**
   A class property that is a bounded queue of fixed arrays reads
   "class array property element", and a fixed array of bounded queues reads
   "class property type: FixedSizeUnpackedArrayType" (VQ/vq10). This holds on both
   binaries. No sv-tests row holds it.
4. **The class bounded-queue fold, decoded and not written:**
   - A parenthesized bound `(3)` or `(P)`: golden places the constant at the inner
     expression, not at `(`.
   - A sized literal `4'd5`: golden keeps the literal (DEC, size 4, const type 1), not a
     64-bit INT fold.
   - An untyped class parameter: golden's constant references the class parameter's
     synthesized int_typespec, which spans the declaration (vq01).
   - A `bit [7:0]` parameter: golden references its bit_typespec (vq02).
   - An imported package parameter: golden folds at size 32 (vq06 `q`).
   - A scoped `pk::P`: golden writes UINT size 32 spanning the scoped name, with a
     reference to the package parameter's int_typespec, where the law writes INT 64 at the
     first token (vq06 `r`).
5. **The default-less generic class:**
   - `int unsigned N` gets vpiSigned on its typespec (vg11, 1 line).
   - A `bit [3:0]` parameter has no typespec (vg02).
   - A localparam derived from the parameter has no typespec (vg04, vg12).
   - A local of a method sized by the parameter keeps its range unfolded in golden (vg15).
   - Module scope (vg08), a nested class (vg14) and type parameters (vg07, the implementer's
     gc04) are not reached.
6. **A module's call to a `$unit` task:** golden writes an unlinked func_call (the sister's
   ExprEmit/StmtEmit face; VT/vt05, vt07, vt08, the implementer's ut02).
7. **The UVM class-copy chain for other typedef kinds** (unpacked array, string, real:
   vu09 to vu11), and DPI import and export tasks at `$unit` (vt01, vt04). These are not
   reached by the law and are unchanged.

## Sister-ground faces (reported, not written)

- ParamEmit makeParamTs / patchParamTypespecs: the module copy of a `$unit`-imported
  typedef'd parameter (residue 1).
- ExprEmit / StmtEmit: a module or class call to a `$unit` task should be an unlinked
  func_call (residue 6).

## Process

- One law build (`-j 2`), one five-stage sweep, no pristine build and no pristine sweep.
  The machine read no other sweep or runner at launch, and no other agent's process was
  touched.
- The fence list was read into a file from tools/probe/r11u107repro/canaudit.sh without
  printing it. On the way, two prose lines of tests/FENCED.md that hold no name were
  printed with the list masked. Every tree-wide list (sv-tests paths, cmds.txt, probe
  databases) was filtered on it before any file was opened. sv-tests holds none of the
  four names.
- Nothing was written outside the worktree and /tmp/v11u408_*.
