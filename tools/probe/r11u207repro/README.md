# r11u207 — the expression/parameter ground: the implicit wire minted for a hidden block variable carries no file (§ hiddenBlockVarMintNoFile207, UnitElabBlock's A half), an unresolved named call lists its written actuals in written order (§ namedUnlinkedWrittenOrder207) and a named call's slot filler carries the root file (§ namedSlotFillerRootFile207), a select indexed by a handle's method call spans the whole call (§ bitSelMethodCallIdxSpan207) and so does a parenthesized method call's path (§ parenMethodCallPathSpan207), `foreach (this.a[i])` spans `this` (§ foreachThisArrAtThisToken207), the cast-width mark's reference binds the declaring package's parameter with no full name (§ parenCastWidthRefPkgBare207, refined in the `--elabuhdm` view by § pcwElabKeepsClaim207v); UnitElabBlock d/t CONVERT, 7 probe cases convert, 0 regressions

**Base.** `3668bf30` (branch matrix-1.87: passes 201 and 202 and r11u204 landed). Worktree `/tmp/wt_r11u207`,
system-deps config. Ground A only: `src/ExprEmit.cpp`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`, `src/EmitHelpers.h`
(the switch and trace helpers). No file of the sister's ground (TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit,
uhdm_main, include/UhdmExporter.h) is touched; nothing under `results/`, `tests/` (but the regenerated
`tests/LAWS.md`) or `third_party/` is edited.

**The fence.** `drivers/env.sh` reads the four names from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` in the main repository (resolved through git's common dir) and every driver
fails closed on it: `case.sh`, `judge.sh`, `grid.sh`, `rowhead.sh`, `obrow.sh`, `uvmdist.sh`, `det.sh`, `detob.sh`,
`awaycorp.sh`, `dscase.py` refuse a fenced name; `census.sh` runs the corpora and the downstream lanes with a
`--filter` built from the fence; `bvmirror.sh` leaves the 8 fenced row-mode databases out of every byte comparison
(`fenced_skipped=8`); the byte-control list was checked against the fence (0 hits). The gate sweeps dispatched every
row; their csv verdicts are the only fenced facts cited (all unchanged). No fenced source, database or head was read.

## 0. Verdicts

| row-mode | base (`3668bf30`) | after | laws |
|---|---|---|---|
| **UnitElabBlock d** | `differ:file(2)` | **`CMP_EQUAL`** | § hiddenBlockVarMintNoFile207 |
| **UnitElabBlock t** | `differ:file(1)` | **`CMP_EQUAL`** | § hiddenBlockVarMintNoFile207 |
| BuildUVMPkg d / t | `differ:line(11)` | `differ:line(7)` | § namedUnlinkedWrittenOrder207 (#5639, #5909), § foreachThisArrAtThisToken207 (#13373), § bitSelMethodCallIdxSpan207 (#19888) |
| MiniAmiq d / t | `differ:file(71)` | `differ:file(70)` | § bitSelMethodCallIdxSpan207 (+ records past the walk's divergence) |
| SeqDriver d / t | `differ:fullname(65)` | `differ:fullname(64)` | the same |
| SimpleUVM d / t | `differ:fullname(95)` | `differ:fullname(94)` | the same |
| Scoreboard d | `differ:fullname(103)` | `differ:fullname(102)` | the same |
| BlackBePipeInt d | `differ:fullname(2)` | `differ:type(1)` | § parenCastWidthRefPkgBare207: the head moves from #66 to #15272 (walk diverges 15,000 records later) |
| BlackBePipeInt t | `differ:fullname(2)` | `differ:depth(1)` | § parenCastWidthRefPkgBare207 + § pcwElabKeepsClaim207v (the full name; the binding is the next record) |
| **probe r10buvm4repro/a2_kindgrid** | `differ:file(16)` | **`EQUAL`** | § namedSlotFillerRootFile207 |
| **probe r10uvm167repro/g167_d_decline** | `differ:file(1)` | **`EQUAL`** | § namedSlotFillerRootFile207 |
| **probe r10v167repro/vB_bare** | `differ:file(8)` | **`EQUAL`** | § namedSlotFillerRootFile207 |
| **probe r10uvm21repro/t32g_t** | `differ:endcol(10)` | **`EQUAL`** | § foreachThisArrAtThisToken207 |
| **probe r10uvm84repro/g84_c1_lvalue** | `differ:endcol(1)` | **`EQUAL`** | § foreachThisArrAtThisToken207 |
| **probe r10uvm84repro/v84x6_stmt** | `differ:endcol(1)` | **`EQUAL`** | § foreachThisArrAtThisToken207 |
| **probe r10uvm85repro/v85x4_pos** | `differ:endcol(1)` | **`EQUAL`** | § foreachThisArrAtThisToken207 |
| probe r10uvm167repro/g167_b_spell | `differ:file(6)` | `differ:endcol(2)` | § namedSlotFillerRootFile207 (the two records left: the shell call's path span, pristine's) |
| probe r10uvm22repro/t33e_t | `differ:endcol(8)` | `differ:file(2)` | § foreachThisArrAtThisToken207 (left: a string_typespec's file, pristine's) |
| probe r10v204repro/v204_s_shadow | `differ:endcol(3)` | `differ:depth(1)` | § foreachThisArrAtThisToken207 (left: the #186 class_var record, identical on both binaries) |

**CONVERSIONS (loud).** The fresh rows of the final law sweep (`/tmp/r11u207_swF`, NOT written to `results/`):

    UnitElabBlock,default,CMP_EQUAL,,,equal
    UnitElabBlock,testflags,CMP_EQUAL,,,equal
    r10buvm4repro/a2_kindgrid,EQUAL,,equal        (probe.csv; likewise the six other probe conversions above)

Totals of the final law sweep against the committed baselines: see section 4 (probe `regressions=0 conversions=7
changes=3`; surelog `regressions=0 conversions=2 changes=11`; uhdm2rtlil `regressions=0 conversions=0 changes=0`;
downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT with `downstream.csv` byte-identical to the
pristine sweep's).

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u207_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `d27bb984d49f6d31eb76cd00e98e517f` | the main tree's `build/slang-uhdm`; the worktree build at `3668bf30` reproduces it byte for byte |
| `law.bin` (= `law10.bin`) | `f089267c5b0178611607749681a1f5f4` | all seven laws, before the refinement; ran the first census, the first law sweep `/tmp/r11u207_swL` and the byte controls |
| **`lawF.bin`** | **`7be18fd04b6c3fb632ea4447a6e2dc25`** | **THE DELIVERED SOURCES**: `law.bin` + § pcwElabKeepsClaim207v (section 3.7.1); ran the final census, the final law sweep `/tmp/r11u207_swF`, the grids, the switch checks and the determinism runs |
| `law1` .. `law9`, `law12` | | development steps (`law12` = `lawF`) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

## 2. Switches (every law droppable alone; `R11U207_OFF=1` restores the pristine bytes on every case)

| switch | law | file | grid |
|---|---|---|---|
| `R11U207_HIDDENVARFILE_OFF` | § hiddenBlockVarMintNoFile207 | ExprEmit.cpp (the `vlogHiddenBlockVars` mint) | cases/U |
| `R11U207_NAMEDORDER_OFF` | § namedUnlinkedWrittenOrder207 | ExprEmit.cpp (`namedWrittenOrder207`, the receiver-less call branch and the § classCallNoLink12 branch) | cases/N |
| `R11U207_SLOTFILE_OFF` | § namedSlotFillerRootFile207 | ExprEmit.cpp (the § namedTfArgsFormalSlots4 filler) | cases/F, N/n04 |
| `R11U207_MCALLIDX_OFF` | § bitSelMethodCallIdxSpan207 | ExprEmit.cpp (`methodCallIdxRange207`, the rvalue bit_select anchor) | cases/B |
| `R11U207_PARENMCALL_OFF` | § parenMethodCallPathSpan207 | ExprEmit.cpp (§ callParenSpan11's site) | cases/B b01 b04 |
| `R11U207_FOREACHTHIS_OFF` | § foreachThisArrAtThisToken207 | StmtEmit.cpp (the foreach loop list's ref_var) | cases/T |
| `R11U207_PCWPKG_OFF` | § parenCastWidthRefPkgBare207 | ParamEmit.cpp (`stampParenCastWidthTs`, `claimParenCastWidthOwner`, `drainShareDefParamTs`) + ExprEmit.cpp (the package-scope cast site) | cases/P p01 |
| `R11U207_PCWELAB_OFF` | § pcwElabKeepsClaim207v (refines the law above in the `--elabuhdm` view) | ParamEmit.cpp | BlackBePipeInt t (section 3.7.1) |

`R11U207_TRACE=<dir>` (one file per process, `<pid>.T207`, first line `OUT <-o path>`, then one law name per firing):
the census's input.

**Switch checks** ([evidence/switchcheck.txt](evidence/switchcheck.txt), `drivers/switchcheck.sh lawF.bin`): each
switch alone, on every case of its grid where its law fires and no other law does, restores the pristine bytes, both
forms: HIDDENVARFILE 3 of 3, NAMEDORDER 6 of 6, SLOTFILE 3 of 3 (F) + 1 of 1 (N), MCALLIDX 2 of 2 (b01 mixed),
PARENMCALL 1 of 1 (b01 mixed), FOREACHTHIS 3 of 3, PCWPKG 3 of 3; NOT_RESTORED none. **`R11U207_OFF=1` writes the
pristine bytes on all 29 grid cases in both forms** (`OFF=pristine` in every row of
[evidence/grid/grid_parse.tsv](evidence/grid/grid_parse.tsv) and [grid_elab.tsv](evidence/grid/grid_elab.tsv)).

## 3. The laws

Every grid case is judged against a real pinned Surelog v1.87 golden in two forms: the probe form (`-parse -nobuiltin
-nocache -sv` against `--single-unit --nobuiltin`; a case with a `nosv` file drops `-sv`, a case with an `args` file
lists its root files) and the `-elabuhdm` form (`ELAB=1`, `--elabuhdm` on our side). Each case names its law on its
first line. Verdicts: pristine -> law, both forms identical unless stated.

### 3.1 § hiddenBlockVarMintNoFile207 (`R11U207_HIDDENVARFILE_OFF`; map 12's N0016, pass 202's residue)

**Face.** UnitElabBlock (`top.v`, Verilog mode): `begin : keep logic hold; hold = in; end` — the Verilog-mode lexer
hides `logic`, the block local compiles to an unbound ref and Surelog's late binder mints an implicit module wire at
the first reference: golden `logic_net hold work@mod.hold` 21:1-21:5 with NO vpiFile (#105 and #207 in default mode,
#105 in testflags), ours `top.v`.

**Decode.** The mint is § implicitNetMintNoFile131's (UhdmWriter's lateBinding lookup-miss branch: four span fields, no
file). ExprEmit's `vlogHiddenBlockVars` mint was the one road that law's note (`noteImplicitNetMint131`) had not
reached; the end-of-export pass clears the file on a definition's noted net.

**Law.** The mint calls the note. **Grid** cases/U: u01 (UnitElabBlock's shape) `file(2)` -> EQUAL (elab `file(1)` ->
EQUAL), u02 (two modules, a variable read twice) `file(4)` -> EQUAL, u04 (the read macro-born from an included file)
`file(2)` -> EQUAL; controls u03 (a `reg`, declared: no mint) and u05 (hidden variables in for- and if-generate
blocks, the module instantiated twice: this mint is not reached there) EQUAL on both binaries, bytes unchanged.
**Downstream** (the gate's `one()`, [evidence/downstream/ds_U.txt](evidence/downstream/ds_U.txt)): **u01 and u02
EQUIVALENT -> IDENTICAL** — the plugin writes `attribute \src "top.v:10.1-10.5"` on the wire from our file where
golden's wire has none; u04 u05 IDENTICAL on both.

### 3.2 § namedUnlinkedWrittenOrder207 (`R11U207_NAMEDORDER_OFF`; BuildUVMPkg's N0189)

**Face.** BuildUVMPkg `m_matches_type_override(.override(...), .requested_type(rtype), .requested_type_name(...),
.full_inst_path(full_inst_path), .resolve_null_type_by_inst(1))` (uvm_pkg.sv 12959, 13071): golden's fifth
argument is the written `1` at 12963:61, ours the skipped `match_original_type`'s default `1` at 13469:85 (#5639,
#5909); a reordered list (`mt(.rt(2), .o(a), .rtn("x"))`) reads NOT_EQUAL at the base.

**Decode.** CompileHelper.cpp `compileTfCallArguments`: named actuals are collected in `argOrder` (and a map by name);
a positional actual is pushed as it is met; at the end, with the callee's `io_decls` in hand the list is rebuilt in
formal order with an `INT:0` filler per unwritten formal (§ namedTfArgsFormalSlots4), and WITHOUT them (the callee not
yet compiled: an extern method whose body comes after the caller's, an inherited method) `argOrder` is appended as it
stands. slang binds one actual per formal, and the § writtenCallArgs16 prefix kept the first nWritten FORMALS.

**Law.** For a call that takes the no-slot path (the receiver-less branch with `!haveSlots4`, and the
§ classCallNoLink12 branch), when every written argument is a named one with an expression naming a distinct formal (or a
leading positional one, taking its position's formal) and the written order is not the formal prefix, the written
actuals are listed in written order (emitted in formal order, permuted after, so every formal-indexed rule keeps its
index). **Grid** cases/N: n01 (BuildUVMPkg's shape) n02 (reordered) n03 (an inherited method) n05 (an extern task)
n06 (a mixed positional + named list, a named call nested in another's argument) n08 (a class specialization and a
derived specialization) NOT_EQUAL -> EQUAL; controls n04 (resolved calls: the formal-slot list) and n07 (method calls
through a handle: their branches already list the written order) keep their lists.

### 3.3 § namedSlotFillerRootFile207 (`R11U207_SLOTFILE_OFF`)

**Face** (found on the N grid). The `INT:0` filler § namedTfArgsFormalSlots4 mints for an unwritten formal: golden
`constant ... dut.sv 0:0-0:0`, ours no file.

**Decode.** `compileTfCallArguments`: `c->VpiFile(fileSystem->toPath(fC->getFileId()))` — the COMPILED file, the
root of the call's include chain, not the included file or macro body the call is written in; no span.

**Law.** The filler carries `rootFilePath` of the call. **Grid** cases/F: f01 (a call in an included `.svh` and one
from a macro body: golden `dut.sv`) `file(4)` -> EQUAL, f02 (two root files: the calls in `b.sv` take `b.sv`, the
callee in `a.sv`) `file(6)` -> EQUAL, f03 (module, interface and class fillers, a task) `file(7)` -> EQUAL; N/n04
`file(5)` -> EQUAL. Byte controls: r11u204verify DF/e06 and e08 move (their fillers gain the root file; both stay
NOT_EQUAL on their own evaluator faces, the order-blind dump distance unchanged: the dump prints no constant file).

### 3.4 § bitSelMethodCallIdxSpan207 (`R11U207_MCALLIDX_OFF`)

**Face.** BuildUVMPkg `m_children[child.get_name()] != child` (#19888): golden bit_select 39715:18-34 (the index
`child.get_name()`), ours 39715:18-32 (`child.get_name`); the same object in MiniAmiq, SeqDriver, SimpleUVM and
Scoreboard (uvm_component.svh 1825).

**Decode.** Surelog anchors an rvalue bit_select at its index node, which is the whole invocation; slang binds a
method call through a handle with the member-access range (a plain `gi(2)` keeps its invocation's range).

**Law.** The rvalue anchor (§ bitSelParenIdxSpan181's, `parenIdxRange181`) takes the InvocationExpression's range
when the selector is a call whose syntax is an invocation of a dotted name starting where the bound range starts and
ending later. **Grid** cases/B: b01 (with and without arguments, nested calls; lvalue and plain-call controls) b02
(module processes, two handles deep, macro-born `IDX(k)`) b05 (`this.` / `super.` calls, a specialization, a
for-generate process) -> EQUAL; b03 (string / queue methods) EQUAL on both. Byte controls: v11u201repro M/m04_task_ctl
`endcol(2)` -> EQUAL; r11u195repro A/a04 moves closer (order-blind dump 22 -> 18 lines, NOT_EQUAL on its own face).

### 3.5 § parenMethodCallPathSpan207 (`R11U207_PARENMCALL_OFF`)

**Face** (found on the B grid). `m_i[(c.gi(4))]`, `y = (c.gi(1))`: golden hier_path `c.gi` 16:43-54 (the call inside
the parentheses), ours 16:43-51 (the name).

**Decode.** § callParenSpan11 takes the invocation syntax's range when it starts at the call; for a parenthesized call
slang keeps the ParenthesizedExpression on the bound call, whose range starts at `(`, so the rule never reached it.

**Law.** Read the invocation inside the parentheses. **Grid** B/b04 (one and two pairs, index, operand, right-hand
side) `endcol(5)` -> EQUAL, b01's last record.

### 3.6 § foreachThisArrAtThisToken207 (`R11U207_FOREACHTHIS_OFF`)

**Face.** BuildUVMPkg `foreach (this.m_predecessors[pred])` (#13373): golden ref_var 33455:16-20 (`this`), ours
16-30 (the property name's length from the base's start).

**Law.** When the loop list's base is `this.<name>` (§ foreachHierPathAlwaysRes21's `arrThis21`), the iterated
ref_var spans the `this` keyword. **Grid** cases/T: t01 (associative, queue, dynamic, fixed arrays; short and long
names) `endcol(4)`, t02 (out-of-body method, task, nested foreach, two-dimensional) `endcol(7)`, t03 (a class derived
from a specialization, an inherited array) `endcol(3)` -> EQUAL. A name of four characters spans the same columns
either way (SVSwitch `foreach(this.data[i])`, probe r10svs4repro/g1_thisidx: the law fires, the bytes do not move).

### 3.7 § parenCastWidthRefPkgBare207 (`R11U207_PCWPKG_OFF`; map 12's N0923)

**Face.** BlackBePipeInt: the cast-width mark's `vpiExpr ref_obj dev_addr_width_gp` under the package parameter's
`int_typespec` (1793:1-34): golden stores no full name and binds `bp_common_pkg::dev_addr_width_gp` (on the walk's
path in the package listing; every one of its 13 expanded occurrences in default mode is that package object); ours
named `work@bp_be_pipe_int.dev_addr_width_gp.dev_addr_width_gp` and bound the importing module's copy
(§ parenCastWidthRefModuleCopy, measured on the v1.86 producer).

**Law.** The reference stores no full name; a package listing's copy binds that listing's own parameter, an
importer's copy the declaring package's first listing (refs stamped earlier are re-pointed when it is met; a ref the
package-scope cast site left on a re-exporting package's IMPORTED copy is re-pointed at design end), and the module
copy's claim is skipped. **Grid** P/p01 (BlackBePipeInt's package lines, no importer) `fullname(6)` -> EQUAL, both
forms. p02 p03 (an importing module) are decode-only: golden folds the importer's copies of the cast parameters
(`UINT:4096`) where ours keeps the cast, NOT_EQUAL on both binaries (ModuleEmit's import copy, section 7).

#### 3.7.1 § pcwElabKeepsClaim207v (`R11U207_PCWELAB_OFF`)

**Break found by the away-moved census** (section 6) on the first law binary: BlackBePipeInt testflags LOST 12 golden
records (6 `parameter work@bp_be_pipe_int.dev_addr_width_gp` and its ref_typespec). In the `--elabuhdm` view golden's
expanded actuals are the importing module's copy at all 14 expanded records: the v1.86 claim still holds in that
view. **Refinement.** In the `--elabuhdm` view the binding stays pristine's (the claim runs, re-pointing without a
full name); only the full name is dropped. After it: BlackBePipeInt testflags LOST 0, GAINED 49; p01's `-elabuhdm`
form stays EQUAL.

## 4. The gates (`tests/sweep.sh --jobs 3`, all four stages, against the committed baselines at `3668bf30`)

| gate | pristine (`/tmp/r11u207_swP`) | first law binary (`/tmp/r11u207_swL`, `law.bin`) | **final (`/tmp/r11u207_swF`, `lawF.bin`)** |
|---|---|---|---|
| (1) build | = the main tree's build (`d27bb984...`) | | `3668bf30` + this patch (`7be18fd0...`) |
| (2) probe vs golden_probe.csv | EQUAL 3363 / 724, `probe.csv` byte-identical to the baseline, `regressions=0 conversions=0 changes=0` | EQUAL 3370 / 717 | **EQUAL 3370 / 717: `regressions=0 conversions=7 changes=3`** (section 0); `probe.csv` byte-identical to swL's |
| (3) surelog vs golden_surelog.csv | `regressions=0 conversions=0 changes=0` (463 + 17 / 459 + 15) | the same as final | **`regressions=0 conversions=2 changes=11`** (464 + 16 / 460 + 14; CMP_NOTEQUAL 3 / 3 unchanged; judge-equal 480 / 474 unchanged) |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | `regressions=0 conversions=0 changes=0` (797 + 6 both modes) | the same | the same; `uhdm2rtlil.csv` byte-identical to the pristine sweep's |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same | **the same; `downstream.csv` byte-identical to the pristine sweep's**; 0 of 805 slang-lane databases move |
| (5) uhdm-cmp | – | | every mover keeps its judge status (the histograms above; every probe mover stays uhdm-cmp equal) |
| (6) byteverify (`SELFCHECK=1`, fence-free mirrors `fenced_skipped=8`) | | 13 / 2560 | **13 / 2560 movers, every one predicted by name** ([evidence/sweeps/byteverify_final.txt](evidence/sweeps/byteverify_final.txt)); SELFCHECK 2559 / 2560 flagged |

Every sweep exits 0 (`law index current`: the regenerated `tests/LAWS.md` is part of the worktree). `cmds.txt`
audit: swP 3273 of 3273 `slang:` lines name `/tmp/r11u207_bin/pris.bin`, swL 3273 of 3273 `law.bin`, swF 3273 of
3273 `lawF.bin`. The surelog csvs of swL and swF differ only in the LowMemLib / LowMemPkg testflags detail text (the
workdir path in Surelog's log line: environment).

**The SELFCHECK reading 2559 / 2560** is the negative control working as designed, not a mover line: byteverify
compares every patched database against the PRISTINE copy of one fixed path (the first in sort order) and counts the
files that differ; that fixed path's own patched database is byte-identical to its pristine copy (it is not a mover),
so exactly one comparison of the 2560 reads equal, and the control's threshold is `>= N - 1`. A reading below 2559
would mean a second database byte-identical to the reference, or a blind comparator.

**Byte controls** ([evidence/byte_controls.txt](evidence/byte_controls.txt), `drivers/ctlbytes.sh` + `ctlsum.py` on
`law.bin`; the refinement touches only the `--elabuhdm` view of a cast-width reference, which none of these cases
contains): every case of the evidence grids of passes 118, 119, 120, 124, 131, 175, 195, 198, 200, 201, 202 and their
verifiers r11v11u118, r11v120, r11v124, r11v131, v11u195, v11u198, r11u199verify, v11u201, v11u202, r11u204verify —
**1760 cases, 4 databases move: v11u201repro M/m04_task_ctl `endcol(2)` -> EQUAL (§ bitSelMethodCallIdxSpan207);
r11u195repro A/a04 NOT_EQUAL both, order-blind dump 22 -> 18 lines (§ bitSelMethodCallIdxSpan207); r11u204verify
DF/e06 and DF/e08 NOT_EQUAL both, the named fillers gaining the root file (§ namedSlotFillerRootFile207; the dump
prints no constant file, so the order-blind dump distance is unchanged, 42 and 124 lines); 0 worse.**

## 5. The prediction and the attribution of every change

**The prediction** ([evidence/predicted_movers.txt](evidence/predicted_movers.txt), frozen `chmod 444` before the
final law sweep, [predicted_frozen_at.txt](evidence/predicted_frozen_at.txt)): `drivers/census.sh` runs the law binary
with `R11U207_TRACE` over every corpus row-mode but the fenced four (the `--filter` built from the fence), every probe
case and every downstream lane; `drivers/censum.py` lists every database a law fired on. The census of `lawF.bin` is
line for line the census of `law.bin` (the refinement adds no trace name): 15 corpus row-modes, 11 probe cases, 0
downstream lanes.

| where | moved | predicted | predicted, not moved |
|---|---|---|---|
| corpus (2560 databases, fence-free mirrors) | 13 | 15 | SVSwitch d/t (§ foreachThisArrAtThisToken207 ×1: `foreach(this.data[i])`, a four-letter name spans the same columns as `this`) |
| probe (4087) | 10 | 11 | r10svs4repro/g1_thisidx (the same: `this.data`) |
| downstream slang lanes (805) | 0 | 0 | – |

Moved and not predicted: **0** in every population.

| row-mode / case | change | law, by the firing census |
|---|---|---|
| UnitElabBlock d/t | `file(2)` / `file(1)` -> **CMP_EQUAL** | § hiddenBlockVarMintNoFile207 ×1 |
| BuildUVMPkg d/t | `line(11) -> line(7)` | § namedUnlinkedWrittenOrder207 ×4, § foreachThisArrAtThisToken207 ×28, § bitSelMethodCallIdxSpan207 ×5, § parenMethodCallPathSpan207 ×8 |
| MiniAmiq d/t | `file(71) -> file(70)` | § foreachThisArrAtThisToken207 ×52, § bitSelMethodCallIdxSpan207 ×8, § parenMethodCallPathSpan207 ×14 |
| SeqDriver d/t | `fullname(65) -> fullname(64)` | ×52, ×8, ×13 (the same three laws) |
| SimpleUVM d/t, Scoreboard d | `fullname(95) -> (94)`, `(103) -> (102)` | ×26, ×4, ×13 |
| BlackBePipeInt d/t | `fullname(2) -> type(1)` / `depth(1)` | § parenCastWidthRefPkgBare207 ×10 (t: + § pcwElabKeepsClaim207v) |
| 7 probe conversions, 3 probe changes | section 0 | per the census file |

**The CHANGE lines.** Every count shrinks. The UVM rows' first records are unchanged (MiniAmiq #899 the
`uvm_severity` enum file, SeqDriver #10090 the `uvm_event_pool` ref_typespec name, SimpleUVM #458 / Scoreboard #466
the `UVM_MACRO_NUMFLAGS` ref_typespec name, BuildUVMPkg #3245 the `uvm_action` int_typespec line: all ground B or not
this pass's, section 7); one record each leaves the pre-divergence window (the `m_children[child.get_name()]` select at
uvm_component.svh 1825), and BuildUVMPkg's four (#5639 #5909 #13373 #19888). BlackBePipeInt d: the walk's first
difference moves from #66 to #15272 (a tagged_pattern's child order in `bp_default_cfg_p`'s users, section 7);
BlackBePipeInt t: #66 now reads the binding alone (the full name is gone). Quoted first records:
[evidence/rowheads_law.txt](evidence/rowheads_law.txt).

## 6. Away-moved census, distances and determinism

**Away-moved-record census** (map 12's method, v11u202's `away.py`; `drivers/awaycorp.sh`: golden, pristine and law
records of every corpus mover as multisets, depth dropped; LOST = in golden and pristine, not in law;
[evidence/away_final.txt](evidence/away_final.txt)): **0 lost records on all 13 final movers**, gained 1 to 79 each
(BlackBePipeInt d 75, t 49; BuildUVMPkg 37; MiniAmiq 69; SeqDriver 79; SimpleUVM 57; Scoreboard 46; UnitElabBlock 2 /
1). The first law binary read **LOST 12 on BlackBePipeInt testflags** ([evidence/away_law.txt](evidence/away_law.txt):
six `parameter work@bp_be_pipe_int.dev_addr_width_gp` records and their ref_typespecs) while the gate read no
regression: refined by § pcwElabKeepsClaim207v (section 3.7.1) before delivery.

**Order-blind distance to golden** (`drivers/uvmdist.sh`: uhdm-strictcmp's records as multisets, depth dropped;
total = ours-not-in-golden + golden-not-in-ours; [evidence/uvmdist.txt](evidence/uvmdist.txt)):

| row-mode | pristine | law | |
|---|---|---|---|
| MiniAmiq d / t | 15058 | 14920 | −138 |
| SeqDriver d / t | 11252 | 11094 | −158 |
| SimpleUVM d / t | 4060 | 3946 | −114 |
| Scoreboard d | 3029 | 2937 | −92 |
| BuildUVMPkg d / t | 1551 | 1477 | −74 |
| SVSwitch d / t, ApbSlave d / t | 0 | 0 | |

(The swL and swF databases of these rows are byte-identical: the refinement moves BlackBePipeInt testflags alone,
[evidence/sweeps/](evidence/sweeps/).)

**Determinism** (`drivers/det.sh lawF.bin`: three CONCURRENT harness runs per row-mode; `drivers/detob.sh`: sorted-dump
diffs between draws; [evidence/determinism/](evidence/determinism/)): **Earlgrey_0_1 default and testflags one hash
per mode**; MiniAmiq, SeqDriver, SimpleUVM, BuildUVMPkg, BlackBePipeInt and UnitElabBlock one hash per mode, each equal
to the final sweep's; Scoreboard default two hashes (`498cfef0` / `24ba24eb`), 0 sorted-dump lines apart (the known
svunit listing-order coin, storage order only). No law adds a coin.

**Downstream** ([evidence/downstream/](evidence/downstream/)): the corpus lanes do not move (0 of 805 slang-lane
databases; `downstream.csv` byte-identical); on the grid cases every dut.sv case is IDENTICAL on both binaries, and
**U/u01, U/u02 EQUIVALENT -> IDENTICAL** (the implicit wire's `\src` attribute, section 3.1).

**Canaries** ([evidence/canaries.txt](evidence/canaries.txt)): surelog `ok=45 changed=7` (exactly the seven canary
rows among the eleven CHANGE lines: SimpleUVM d/t, SeqDriver d/t, BuildUVMPkg d/t, Scoreboard d); uhdm2rtlil
`ok=16 changed=0`; ctcan2 `EXPECT_UNKNOWN=1` on surelog `changed=2` (exactly BlackBePipeInt d/t, the named CHANGE)
and `EXPECT_UNKNOWN=6` on uhdm2rtlil PASS (`ok=2`).

## 7. Ranked residues and the sister-ground faces (call sites; not edited here)

1. **The UVM rows' pre-divergence windows are ground B now, but for one A family not attempted.** Per row, the
   records before the walk diverges (MiniAmiq 70, SimpleUVM 94): 52 are macro-born method-call spans (the
   `cb.METHOD` of `uvm_do_obj_callbacks`: golden `phase_state_change` 168:11-168:29, ours 168:11-169:9; the `MSG`
   argument's `get_full_name` / `get_inst_id`: golden 116:13-26, ours 115:89-1346:16) — the end of a token that came
   from a macro ARGUMENT, mapped by the pp-output model (UhdmExporter `locLineCol` / `fullFilePath`, § ppOutputFile166,
   § ppFileCallArgBody168: ground B); the `uvm_severity` / `uvm_action` / `UVM_FILE` typedef typespecs located at a
   formal's type use (MiniAmiq #899 N0144, BuildUVMPkg #3245: the io_decl typespec's last writer, TaskFuncEmit /
   TypeEmit); SimpleUVM / Scoreboard #458 `UVM_MACRO_NUMFLAGS` — decoded here: golden's bare name is the last writer
   of the `$unit` `import uvm_pkg::*` (testbench.sv line 1), which copies the package parameters into every class of the
   file; every small shape of it reads NOT_EQUAL on both binaries because ours lists those class `param_assign` copies
   without their `ref_typespec` (probe `import p::*; class env ... endclass`: golden
   `class_defn(work@env) > param_assign > constant > ref_typespec`, ours `<null>`), ModuleEmit
   § classInheritsContainerImports23 / importPaCopy82 (ground B), so no gate-able A law exists yet. **Ground A, not
   attempted:** SeqDriver #10090 (map 12's N0540 family): `ref_typespec uvm_pkg::uvm_event_pool` raw full name
   golden `work@top_tb.uvm_pkg::uvm_event_pool`, ours `uvm_pkg::uvm_event_pool` (ParamEmit `emitPackage` near
   § pkgImportCloneLastWriter32).
2. **The TF-ITEM body variable's span (ground B, decoded).** BuildUVMPkg / MiniAmiq / SimpleUVM `static bit first =
   1;` and `uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();` in the PAREN-LESS
   `function void uvm_component::m_set_cl_verb;`: golden locates a body variable WITH an initializer at its DATA TYPE
   (`bit` 3381:10-13, `uvm_cmdline_processor` 3383:3-24), ours at its name; a variable without an initializer and
   every variable of a function written with `()` agree (probe `function void C::m1; static bit first = 1; K clp =
   K::get(); int plain; int init = 3; endfunction`: golden `first` 13:10-13, `clp` 15:3-4, `init` 17:3-6; `plain`
   and `m2()`'s variables equal). The TF-ITEM production's variables are listed by TaskFuncEmit (`tfBodyTfItems9`,
   § tfItemBodyLocal148's production).
3. **BlackBePipeInt's next records.** d: #15272, a `tagged_pattern` of a struct-typed parameter's assignment pattern
   (dut.sv 2602) whose first child in ours is a constant from `bp_default_cfg_p` (2047:16) where golden lists the
   member's `ref_typespec` first: not decoded (ParamEmit pattern substitution, ground A: next). t: #66, the
   `--elabuhdm` view's first package listing, where golden's reference sits on the walk's path (the package
   parameter) and ours on the importer's claim; the other 14 expanded golden records are the importer's copy, so the
   claim is right there; the rule separating the first listing is not decoded.
4. **§ namedUnlinkedWrittenOrder207's under-reach (decoded, cases/X x02).** A named call to a function declared LATER
   in the same interface or module lists golden's written order although it is linked (Surelog compiled the caller
   before the callee had io_decls): `first()` calling `later(.c(x), .a(1))` in an interface, `f1` calling `f2(.c(x),
   .a(1))` in a module (golden `x, 1` with vpiFunction; ours the formal slots `1, 0, x`), while `f3` declared after
   `f2` takes the slots. NOT_EQUAL on both binaries; the gate would be the callee's declaration position against the
   caller's in the same scope (ExprEmit, `namedTfSlots4`'s caller).
5. **§ parenMethodCallPathSpan207's neighbour (decoded, cases/X x01).** A parenthesized method call that omits a
   defaulted argument (`((c.gi()))`) lists the default in ours: `callInvocation167` (EmitHelpers.h) does not see
   through the parentheses, so § writtenCallArgs16 falls back to the bound count. NOT_EQUAL on both binaries.
6. **InterfArrayBind d `fullname(3)` (ground B, decoded).** `assign b[E1].we = 1'b1;` and the for-generate
   `assign b[i].d = ...` over an interface array: golden's instance listing holds its own CLONE of the continuous
   assignment whose index reference stores no name (`work@tb.b[E1].we.E1`, `work@tb.g[0].b[i].d.i` computed through the
   chain); ours shares the definition's object (named `work@tb.E1`), so no naming law can serve both listings
   (ModuleEmit `emitContAssigns`, the instance listing). The `-elabuhdm` form agrees already.
7. **The cast-width importer copies (ground B, cases/P p02 p03).** An importing module's copies of the cast
   parameters: golden folds them (`UINT:4096`), ours keeps the cast (NOT_EQUAL on both binaries; ModuleEmit
   importPaCopy82).
8. **Carried, not reached this pass**: struct_param_func_config's A half (the four `memberScope` names in ParamEmit
   `makeParamTs`, then #1364 a golden-only constant copy: the row does not convert on the names alone);
   cfg_func_width_loop's evaluator stamp (#464, then the kept call #472, ground B); OutputSize... (a folded member
   read located at its use, #169 / #172); the ExprEval value encodings (srlgRedIntSyn); r11u204's N2 N3 N4 (evaluator
   and stamp faces) and N6 (§ elabCaConstLhsSized191 lives in ModuleEmit: ground B); pass 198's R3 R4 R6 R10; pass
   201's residues 6-10.
9. **Rows at the base, attributed:** Earlgrey_0_1 d/t `fullname(76)` heads #90097 (the generate-scope port-connection
   select, both halves ground B per pass 201); Rggen d `defname(142)` #3227 (TypeEmit's path branches, ground B);
   Scr1SvTests d/t `type(1)` (the Surelog defect of map 12's 8a); arb_idx_cast d/t `endline(2)` (TypeEmit
   `makeTypeParamDefaultTs`, ground B only); SVSwitch already CMP_EQUAL at the base.

## 8. Files, and how to reproduce

* `drivers/`: `env.sh` (pins + fence), `case.sh` (judge one case, both forms with `ELAB=1`; `nosv`, `args`), `judge.sh`,
  `grid.sh` (`OFFCHECK=1 LAWBIN=lawF.bin`: the `R11U207_OFF=1` byte check), `switchcheck.sh`, `census.sh` + `censum.py`
  (the firing census), `bvmirror.sh`, `ctlbytes.sh` + `ctlsum.py` (the byte controls), `rowhead.sh`, `obrow.sh`,
  `obdist.sh`, `uvmdist.sh`, `away.py` + `awaycorp.sh` (the away-moved census), `det.sh` + `detob.sh`, `dscase.py`.
* `cases/`: U (§ hiddenBlockVarMintNoFile207), N (§ namedUnlinkedWrittenOrder207), F (§ namedSlotFillerRootFile207),
  B (§ bitSelMethodCallIdxSpan207, b04 § parenMethodCallPathSpan207), T (§ foreachThisArrAtThisToken207), P
  (§ parenCastWidthRefPkgBare207; p02 p03 decode-only), X (decode-only residues: x01 § parenMethodCallPathSpan207's
  omitted-default neighbour, x02 § namedUnlinkedWrittenOrder207's forward-declared callee).
* `evidence/`: `grid/`, `switchcheck.txt`, `predicted_movers.txt` (frozen), `byte_controls*.txt`, `sweeps/`,
  `away.txt`, `uvmdist.txt`, `rowheads_law.txt`, `downstream/`, `determinism/`.

Reproduce: build `3668bf30` + the patch (`cmake -B build -DCMAKE_BUILD_TYPE=Release -DSLANG_UHDM_USE_SYSTEM_DEPS=ON
-DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build build -j 2`), freeze it beside the pristine build in `/tmp/r11u207_bin`
as `lawF.bin`, then `bash drivers/grid.sh` (and `ELAB=1`), `bash drivers/switchcheck.sh lawF.bin`,
`bash drivers/census.sh <wd> <tr> <prefix>`, `tests/sweep.sh --jobs 3 --workdir <wd>` with `SLANG_UHDM` exported.

## 9. The patch

`/tmp/r11u207.patch` = `git diff 3668bf30` of this worktree: `src/ExprEmit.cpp`, `src/StmtEmit.cpp`,
`src/ParamEmit.cpp`, `src/EmitHelpers.h`, `tools/probe/r11u207repro/`, `tests/LAWS.md` (regenerated by
`python3 scripts/law_index.py`; `--check` reads `law index current` on the patched fresh tree). It applies clean on a
fresh `3668bf30` worktree (`git apply --check`), and the src part applied there (`/tmp/r11u207_chk`, system-deps
config, `-j 2`) rebuilds `lawF.bin`'s md5 `7be18fd04b6c3fb632ea4447a6e2dc25`.
