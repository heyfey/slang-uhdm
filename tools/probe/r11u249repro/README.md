# r11u249: the module/type ground, pass 249 (implementer)

Base dfc487f1 (`matrix-1.87`). Pristine binary md5 da60f833fd263102ef74d71140183800, the same as the main tree's
`build/slang-uhdm`. Law binary md5 9ef1b5bbcb757d8df1d568cb1d22bbd3. Both link slang 12.0.0+545f88b2e. Production
files: src/UhdmExporter.cpp, src/TypeEmit.cpp, src/ModuleEmit.cpp and the new src/R249.h. Every law reads its own
`R11U249_<LAW>_OFF` switch. `R11U249_OFF` drops all seven laws and restores pristine bytes (110 of 110 grid
case-views). `R11U249_TRACE=<dir>` logs every firing of every branch.

**Verdict on the gate: no corpus row or probe case moves.** The pass removes exporter exit 4 on legal shapes the
corpora do not contain. It also makes the case shapes of pass 247's residues (1)(b) and (1)(d) and pass 245's
residues (2) (UA/a02, UA/a06, d01's class-property half) judge-equal and STRICT_EQUAL where the sister ground allows.

* Byte movers against this pass's own pristine sweep: 0 of 2560 corpus databases, 0 of 4087 probe databases and 0
  of 805 downstream slang lanes. The frozen prediction was 0, 0 and 0 (`evidence/prediction.txt`).
* Every sweep csv is identical to the pristine sweep's csv. The only difference is the LowMem log-path text, which
  is environment.

## The laws

| law | switch | site | what |
|---|---|---|---|
| § clsPropWholeArrTd249 | R11U249_WHOLEARRTD_OFF | UhdmExporter: the class-property switch, the write-phase `pendingClassPropTs` stamp, § unitTdLawS245's variable loop, design-final | A class property whose declared type is a typedef NAME of a whole unpacked array (fixed, dynamic, queue or associative) is golden's SMALL array_var. It has name, full name, the name token's span, vpiAutomatic unless static, rand and visibility, and a reference named by the property. It has no vpiSize, vpiArrayType, vpiRange or vpiReg. The fixed form exited 4 ("class property type: FixedSizeUnpackedArrayType"). The dynamic forms took the declarator branch and wrote vpiSize 1, vpiArrayType and an element golden does not have. The reference binds the listing, and the listing keeps its parent. Design-final, an UNQUALIFIED name whose array element is written as a KEYWORD gets golden's per-property DEEP copy (Surelog `compileDatastructureTypespec` clone_tree's the typedef's SimpleType). The copy has its own ranges, constants, operations and element typespec, and every reference inside it is named `<property>::<typedef>`. It is named bare, parented at the property, and keeps vpiInstance only when that is a package. Its Typedef_alias binds the listing. A package-QUALIFIED name (`a::v_t`, `p::i_t`) and an array whose element is a typedef name keep the listing itself (golden A/a03, a10, a13-a16). An initializer takes the § classPropInit29 route. |
| § clsTdArrElemPkgPath249 | R11U249_CLSTDARRPATH_OFF | UhdmExporter class typedef listing (the FixedSizeUnpackedArrayType branch) | The element reference of an unpacked-array typedef declared in a class is named from the class's FULL name: `p::c::f_t` for a package class, `work@top::c::f_t` for a module class (golden A/a07, C/c01, C/c03). Ours wrote `c::f_t`. This is the array twin of § classTdStructMemberPkgPath146. |
| § unitDynArrTd249 | R11U249_UNITDYNTD_OFF | UhdmExporter $unit typedef writer, TypeEmit `buildUnpackedArrayTypedefTs`, UhdmExporter § unitTdLawS245's elaborated-variable branch | A $unit typedef of a dynamic array, queue or associative array (one dimension, keyword element, keyword index) is listed instead of exiting 4. The listing carries ONE kind-marker range. `[]`: the range at the brackets, with `0` and `unsized` both at the `[`. `[$]`: the range at the `$`, `0` unlocated, and `$` with size 1 and vpiUnboundedConst at the `$`. `[kw]`: the range at the brackets, with `0` and `associative` unlocated; the marker carries a reference named like the typedef to the index typespec, which is signed as the index is. An elaborated module variable binds a bare, unaliased copy (golden's weakly-referenced pair). |
| § modDynArrTd249 | R11U249_MODDYNTD_OFF | TypeEmit module-body typedef writer | The same listing for a MODULE-BODY typedef of a dynamic container. Before this law it exited 4 ("typedef target: QueueType"). |
| § dynAliasNetType249 | R11U249_DYNNETTYPE_OFF | ModuleEmit definition-view net type, a chained `else if` read only where no earlier branch stamps | This is § unpackedAliasNetType65 read through a dynamic container. A definition net written as a bare typedef name of a dynamic, queue or associative typedef whose element is an alias-free four-state packed vector or scalar prints vpiLogicNet 36, or vpiReg 48 for `reg`. A two-state element prints none (golden U/u05, N/n01-n03). |
| § modTdElabFoldSize249 | R11U249_MODFOLD_OFF | UhdmExporter design-final | This is the module-body twin of § unitArrTd245's elaborated fold. An elaborated variable typed by a module-body SIZE-form fixed-array typedef (`typedef int f_t[4]; f_t x;`) binds a bare unaliased copy. That copy's single range has its right bound FOLDED to an unlocated `INT:3` (size 64, vpiIntConst), where the listing keeps `4 - 1`. Ours shared the listing's operation. Only a copy whose range operation IS the listing's is re-made. |
| § unitUnpackedUnionTd249 | R11U249_UNITUNION_OFF | UhdmExporter $unit typedef writer | A $unit typedef of an UNPACKED union is listed by the union builder, as the unpacked struct is. Before this law it exited 4 ("typedef target: UnpackedUnionType"). |

## Cases (tools/probe/r11u249repro/cases; every first line names its law)

The verdict runs from pristine to law in both views. `cN` is the uhdm-cmp line count. `rc` is the exit code.

| cases | law | result |
|---|---|---|
| A a01-a19 | § clsPropWholeArrTd249 | a01 ($unit fixed), a04 ($unit dyn/queue), a07 (class-scope), a08 (module class) and a19 (static/protected/local rand) go stage 1 rc 4 -> STRICT_EQUAL in both views. a02, a05, a06, a09, a11 and a12 (package typedefs) stay stage 1 with an unchanged cN: the package LISTING is first wrong there (ParamEmit emitPackage, sister ground). The listing branch covers a03, a10, a13, a15 and a16, which stay stage 1 behind the same package face. a14 is stage 1 43 -> 17: golden lists two unreferenced aliased clones of the element typedef that we never mint. a17 (initializer) is 250 -> 28: golden sizes the pattern constants oddly (2, 1). a18 (alias of an alias of an array, $unit) still exits 4 in the $unit writer. |
| C c01-c05 | § clsTdArrElemPkgPath249 (c02 the $unit-class control, which only WHOLEARRTD moves) | c01, c02 and c03 go stage 1 rc 4 -> STRICT_EQUAL. c04 (2-D class typedef) stays stage 1: TypeEmit's builder lists one dimension. c05 (parameter-sized `[N]` class typedef) is 125 -> 46: golden keeps a `ref_obj p::c::f_t::N`. |
| U u01-u08 | § unitDynArrTd249 | u01-u06 and u08 go rc 4 -> STRICT_EQUAL. u07 (a function-local `q_t` in a module function) stays stage 1 (134 -> 134): a TaskFuncEmit local face. |
| M m01-m05 | § modDynArrTd249 | m04 (unused) goes -> STRICT_EQUAL. m01-m03 and m05 go 109/227 -> 17 cmp lines: golden lists two UNREFERENCED copies per typedef (aliased with vpiInstance, and bare) while every reference binds the listing. |
| N n01-n07 | § dynAliasNetType249 (n02, n06 controls) | n02 and n03 go -> STRICT_EQUAL. n01 (`reg` element) is 86 -> 47: golden's elaborated module lists the array_var under vpiNet. n04 (module-local) is 203 -> 17 (the M face). n05 and n06 (package) stay behind the ParamEmit listing face. n07 (element typedef, $unit) still exits 4. |
| B b01-b08 | § modTdElabFoldSize249 (b02, b03 controls) | b01 goes -> STRICT_EQUAL. b08 goes stage 1 -> STRICT_NOTEQUAL type (struct-element copy, walk diverges). b04_two_inst (the second instance writes a full array_var), b05 (generate block), b06 (interface) and b07 (parameter size) are unchanged other faces. |
| K k01-k03 | § unitUnpackedUnionTd249 | k03 (used in a class) goes -> STRICT_EQUAL. k01 and k02 go rc 4 -> rc 0 and stay stage 1 (90 -> 297 / 331): the ELABORATED view writes `logic_net` where golden has `union_var`. That face is the same for package and module unions on pristine (ModuleEmit). |
| decode E e01-e03 | site § fixedClassPropIsArrayVar6 (no law) | e01 (`my_t m2[2][3]`) is already STRICT_EQUAL on pristine. e02 and e03 (`[][$]`) are the hybrid class property. Golden has array_var vpiArrayType 2 (the outer kind), the INNER marker as the array_var's vpiRange (`0`, `$`), and a vpiReg element: the assoc multi-dim rule of `emitAssocDims` extended to unsized dims. Not written. |

## Measurements

* **Grid** (`evidence/grid.txt`, 1100 lines, `drivers/grid.sh`): 55 cases in both views on pristine, law, law +
  R11U249_OFF and law + each of the 7 switches; every line carries rc. R11U249_OFF reproduces pristine bytes on 110
  of 110 case-views. **40 case-views enter STRICT_EQUAL and none leaves.** Law exit 4 remains on 4 case-views (a18,
  n07), down from 90 on pristine. Each switch moves only its own law's cases (the `sw:` column of the summary).
* **Byte controls** (`evidence/controls.txt`, `drivers/controls.sh`): 17 earlier repro dirs (r11u247, v11u247,
  r11u245, v11u245, r11u243, v11u243, r11u241, r11u237, r11u118, r11u119, r11u120, r11v120, r11u124, r11v124,
  r11u131, r11v131, r11u125), 2226 case-views in both views. 18 move, all of them named shapes of this pass:
  - pass 245's UA/a02 and UA/a06 -> STRICT_EQUAL (both views);
  - pass 247's B/b04 -> STRICT_EQUAL;
  - r11u243 decode tf_f03 (the class-property half of d01) -> STRICT_EQUAL;
  - tf_f01, tf_f02 and tf_f04 rc 4 -> 0 (tf_f04 682 -> 17);
  - tq_q02 (a § dynAliasNetType249 mover, the package queue listing face first);
  - v11u247 K/k10 rc 4 -> 0, stage 1 on both.

  **8 enter STRICT_EQUAL and none leaves.**
* **Gate sweeps** (`evidence/*_sweep_summary.txt`, tests/sweep.sh --jobs 3, workdirs /tmp/r11u249_wdP and
  /tmp/r11u249_wdL), law sweep rc=0 with the law index current:
  - probe: 3511 EQUAL + 576 STRICT_NOTEQUAL, regressions=0 conversions=0 changes=0.
  - surelog: default 470 + 10, testflags 466 + 8 (936 + 18), 0/0/0.
  - uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
  - downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, verdict csv identical to the
    pristine sweep's.
* **Binary-path audit**: 3265 cmds.txt per sweep (fence-filtered list), each naming only its own frozen binary.
* **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered hard-link mirrors, `drivers/bvmirror.sh`,
  same-length workdirs): MOVERS 0 / 2560, PATH_SETS_IDENTICAL, SELFCHECK 2559 / 2560 flagged (the gate can see).
  Probe databases are 0 / 4087 byte movers. Downstream slang lanes are 0 / 805.
* **Prediction** (`evidence/prediction.txt`, `drivers/tracesweep.sh`): a firing census of the law binary with
  R11U249_TRACE over both corpora in both modes and the probe, fenced tests excluded by the harness filter. It read
  0 firings. Positive control: a scratch probe copy of cases/B/b01_int run through check_probe.py fired
  modTdElabFoldSize249; the copy was removed afterwards. The prediction was frozen before the law sweep and held
  (0 = 0).
* **uhdm-cmp** on touched rows: no row touched.
* **Away census** (`drivers/awayrows.py`, chain-keyed variant comparator): "0 databases differ between the
  pristine and law sweeps". The census is vacuous here; its positive control is byteverify's SELFCHECK.
* **Canaries**:
  - surelog ok=52 changed=0;
  - uhdm2rtlil ok=16 changed=0;
  - ctcan2 EXPECT_UNKNOWN=1 (surelog) PASS;
  - ctcan2 EXPECT_UNKNOWN=6 (uhdm2rtlil) PASS.
* **Determinism** (`evidence/determinism.txt`, `drivers/det.sh`): three concurrent draws per row-mode on
  Earlgrey_0_1 and the five UVM rows read one hash on 11 of 11 row-modes (Scoreboard testflags has no database,
  as at the base). Each hash equals the law sweep's.
* **Downstream on the cases** (`evidence/ds_*.txt`, `drivers/dscases.py`): pristine 38 IDENTICAL / 11 EQUIVALENT /
  4 STATUS_DIFF / 2 DIVERGENT, law 47 / 6 / 0 / 2. No case leaves IDENTICAL.
  - M m01, m02 and m05, U u02 and u05: EQUIVALENT -> IDENTICAL.
  - N n03 and n04, U u01 and u04: STATUS_DIFF -> IDENTICAL.
  - K k01 and k02: DIVERGENT on both binaries (the union_var face).

## Rows targeted, before -> after

No row of the brief's list moves. Every UVM row is headed by a ground-A record, and none of these laws fires on
any corpus row:

* BuildUVMPkg d/t: type(1) #153018 (StmtEmit arrayVarArrayTs)
* MiniAmiq / SeqDriver d/t: type(1) #78478 / #78434 / #78446 (StmtEmit § cloneLoopVarHomeObject183 /
  § cloneLoopVarClassPropArrayTs238, r11u247repro decode/d01)
* SimpleUVM d/t: type(1) #98800 / #98812 (ExprEmit § dpiExportedPkgSubBareOwnTdUnsupported170)
* Scoreboard d: type(1) #130737 (ParamEmit / ExprEmit, a folded constant INT:63 where ours writes an operation)

These go to the sister passes with the call sites listed. Rggen #23546, Earlgrey #136315, BlackBePipeInt #38807 /
#38803, DP/d01 and c04 / d03 (ParamEmit emitPackage) are carried unchanged.

## Residues, ranked

1. **Package typedef listings of arrays** (sister ground: ParamEmit emitPackage). A size-form fixed dim is folded to
   `[0:3]` at the brackets where golden keeps `0 .. 4 - 1` at the size token. The queue, dynamic and associative
   markers are also wrong. This first-fails A/a02, a05, a06, a09, a11, a12, N/n05, n06 and r11u243 tq_q02, and it
   blocks § clsPropWholeArrTd249's package half from equality (pass 247's K/k01, k04 face).
2. **Unreferenced Surelog clones in the tail.** Module-body dynamic typedefs list two weakly-referenced copies per
   typedef while every reference binds the listing (M m01-m03, m05, N/n04). A $unit array of a typedef element
   lists two aliased clones of the element typedef (A/a14). These are mint-only objects with no binder.
3. **Unpacked unions in the elaborated view** (ModuleEmit): golden `union_var`, ours `logic_net`, for $unit, package
   and module unions alike (K k01, k02, v11u247 K/k10; downstream DIVERGENT on both binaries).
4. **The class-property hybrid `[][$]` / `[4][]`** (decode/E e02, e03; the § fixedClassPropIsArrayVar6 branch). The
   decoded golden shape is above; it is pass 247's E/e07 remainder.
5. **Module-body fixed typedef variables outside the top instance's first copy**: the second instance of the same
   module writes a full array_var (B/b04_two_inst), plus a generate block (b05), an interface (b06) and a
   parameter-sized dimension (b07).
6. **2-D class typedefs** (C/c04, TypeEmit `buildUnpackedArrayTypedefTs` lists one dimension) and parameter-sized
   class typedef dimensions (C/c05).
7. **Remaining exit-4 shapes**:
   - alias-of-alias $unit array typedefs (A/a18);
   - $unit dynamic typedefs of a typedef element (N/n07);
   - bounded queues, non-keyword associative indexes and multi-dimension dynamic typedefs (gated out by
     `unitDynTdShape249`).
8. **Smaller faces**: a `reg`-element queue's elaborated var under vpiNet (N/n01); the pattern initializer
   constants' sizes (A/a17); a function-local $unit queue (U/u07, TaskFuncEmit).
9. **Brief items not attempted**:
   - (1)(a) the generate-block definition view;
   - (1)(c) the package-qualified element typedef;
   - (1)(e) interface-class prototypes and `type U = T` chains;
   - (1)(f) beyond the listed shapes;
   - (2) US/u11 unranged $unit ports, the generate-block listing position, V/v01, K/k02, k03, A/a03, a04 and DR/d01;
   - (3) the this-wire faces;
   - (4) and (5) the decode's BuildUVMPkg clusters;
   - (6).

## Process notes

* **First law binary (md5 709b5b98…).** It carried an ungated defect. § dynAliasNetType249 was first written as an
  `else if` whose nested braceless `if`s captured the FOLLOWING `else if` of the net-type chain, so a
  package-qualified struct port net (`output p::s_t o`) lost vpiNetType 1 even under R11U249_OFF. The pass's own
  grid could not see it: no case had such a net. The byte controls found it, with 12 r11u124repro c13/f02
  case-views leaving STRICT_EQUAL.
* **What was done about it.** The law sweep already started on that binary was stopped by its own task id before
  its probe stage finished. Its workdir, firing census and prediction were discarded. The law was rewritten as a
  chained `else if (int32_t nt249 = dynNt249())`. The binary was rebuilt (9ef1b5bb…) and re-frozen. The census,
  prediction, grid, controls (widened to 17 dirs) and the law sweep were all rerun on it. Every number above is
  from that binary.
* **Fence.** No fenced test was dispatched, read or opened outside the gate sweeps. The census excluded the fenced
  tests through the harness filter. byteverify ran on fence-filtered mirrors. Every cmds.txt list was filtered by
  `$FENCED` (word boundary, read fail-closed from tools/probe/r11u107repro/canaudit.sh) before reading.
* **Processes.** No process of another agent was listed or signalled. One check of leftover processes read only
  command lines holding this pass's own workdir name.
* **Drivers.** The drivers were copied from r11u247repro/drivers, with a header line added. The first header
  insertion broke `strictcmp_x.cpp`'s first line (`#` instead of `//`); it was fixed before the comparator was
  built.

## Drivers

`drivers/` holds the following, every one reading `$FENCED` fail-closed and resolving paths from the repo:

* `env.sh`
* `case.sh`
* `grid.sh` (this pass's switches)
* `controls.sh`
* `tracesweep.sh` (R11U249_TRACE)
* `dscases.py`
* `bvmirror.sh`
* `det.sh`
* `awayrows.py`, `cc_x.sh` and `strictcmp_x.cpp`
* `flatlost.py`
