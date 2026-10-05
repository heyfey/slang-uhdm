# r11u245 — module/type ground: the `$unit` typedef writer and LAW S for `$unit` typedefs

Pass 245 (PAIR B refill after pass 243), base `9666f384`, worktree `/tmp/wt_r11u245`. Ground: `src/TypeEmit.cpp`,
`src/ModuleEmit.cpp`, `src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp`, `uhdm_main.cpp`. This pass touches
`src/UhdmExporter.cpp`, `src/ModuleEmit.cpp`, `src/TaskFuncEmit.cpp` and adds `src/R245.h` (switches +
`R11U245_TRACE`). Nothing on the sister ground (ExprEmit, EmitHelpers.h, StmtEmit, ParamEmit) is edited.

Six laws, each behind its own switch; `R11U245_OFF` drops all of them (pristine bytes on 56 of 56 case-views).
`R11U245_TRACE=<dir>` writes `<dir>/<pid>.245`: `OUT <-o path>` then one `<law> <detail>` line per firing.

Binaries (`evidence/binaries.txt`): pristine `0c5bd3be423a452b5cac3b1c1c45aaec` (byte-identical to the main tree's
build at the base), law `9f15dba2596966f23c4610d81e740f10`; both link slang 12.0.0+545f88b2e; both frozen
(`chmod 555`) before any measurement; every cmds.txt of both sweeps names its own frozen binary
(`evidence/cmds_audit.txt`, 3265 + 3265 after the fence filter, 3315 of 3323 cmds.txt kept).

## The face

Brief item (1)(c): v11u243 C/c04, `typedef string ustr_t;` at file scope, exits 4. It is not a crash. The `$unit`
typedef writer (UhdmExporter, the compilation-unit typedef loop ahead of the design's Typespecs) has branches for
enum, packed/unpacked struct, packed union, packed array / scalar and class targets only. Every other target
(`string`, every integer atom `byte shortint int longint integer time`, `real shortreal realtime`, every unpacked
array) falls to `noteUnsupported("typedef target: ...")`. The design then lists no typedef and the run exits 4
(`unsupported constructs`). This is the most common `$unit` typedef in SV (`typedef int t;` alone exits 4 at the
base), and its database is stage 1 everywhere. Decoding the face showed a second one behind it: even the kinds that
are written (a `$unit` `logic [3:0]` vector) are stage 1 when a module variable uses them. Golden binds per-use
copies with a Typedef_alias back at the listing (its `weaklyReferenced` objects), and ours binds the listing object
directly. LAW S (TypeEmit `bareScalarTypedefVarTs`) models exactly these copies, but for PACKAGE typedefs only.

No corpus row carries the face (the corpus scoreboards have no `typedef target:` reject and no strict detail on it),
so **no corpus row converts**, as predicted. The pass converts the face on its own grid: **38 case-views enter
STRICT_EQUAL** from stage 1 and none leaves. The downstream harness on the cases goes from 17 IDENTICAL / 6
EQUIVALENT / 2 DIVERGENT / 1 STATUS_DIFF to 22 / 2 / 1 / 1, with no case leaving IDENTICAL.

## Verdicts per targeted row (before -> after)

| row / case | base | after |
|---|---|---|
| v11u243 C/c04 (the brief's item (1)(c)) | stage 1, rc 4 | stage 1, rc 0 (74 cmp lines both). The exit 4 is gone. The next head is ground A: the PACKAGE listing of `typedef str_t al_t;` (golden `p` lists only `p::str_t`; ours lists `p::al_t` too), ParamEmit `emitPackage`'s typedef loop, for the sister pass |
| r11u243 decode tf_f03 (the `$unit` half of item (1)(d)'s d01) | `typedef target: FixedSizeUnpackedArrayType`, rc 4 | the `$unit` listing is written (§ unitArrTd245); a module variable of the type is STRICT_EQUAL (UA a01, a03, a07). The CLASS PROPERTY of the type (UA a06) still exits 4 at UhdmExporter's class property switch (residue 2) |
| surelog / uhdm2rtlil corpora | 936 + 18 / 1606 + 0 | unchanged: 0 conversions, 0 changes, 0 byte movers |
| probe | 3498 + 589 | 3498 + 589: 0 conversions, 1 change (`v11u108repro/brk/f5/b07_param_typedef_arr` file(9) -> file(7), below) |

No row improves on the gate. **No CONVERSION to report.**

## The laws

### § unitPredefTd245 (`R11U245_UNITPREDEF_OFF`; UhdmExporter, the `$unit` typedef loop)
A `$unit` typedef of a predefined kind (`string`, the integer atoms, `real`, `shortreal`, `realtime`) is written by
the same writer as the scalar branch (`makeTypespec(ta, typeSyn)` with the typedef-context flags). The result is one
named typespec of the kind (`string_typespec (ustr_t)`, `int_typespec (uint_t)`), parented and instanced at the
design and located at the target type's tokens (`string` 3:9-3:15). Two measured details:
* An integer atom under `signed` ends at the type keyword (`int signed` 5:9-5:12). Under `unsigned` it spans both
  tokens (US/u14 against u16; the same rule as compileBuiltinTypespec, which § tfSigningSpanFollowsCompilePath200
  reads).
* `realtime` is a `time_typespec` (Surelog's paNonIntType_RealTime), never a real one.

Cases: US u01, u03, u04, u14 (and every US case that uses an `int` or `string` typedef); decode DR/d01.

### § unitPredefAliasOfAlias245 (`R11U245_UNITPREDEFAOA_OFF`; same site)
Case US/u02: `typedef ustr_t ual_t;` over a `$unit` predefined-kind typedef. Golden's listing object for `ual_t`
* is located at the TARGET's type tokens (3:9-3:15, not the `ustr_t` name at 4:9);
* carries a Typedef_alias reference named `ual_t`. That reference binds a per-use COPY of `ustr_t`: named
  `ustr_t`, with its own alias bound to `ustr_t`'s listing, and no vpiInstance. The cmp head was this second-level
  alias.

Cases: US u02, u14.

### § unitArrTd245 (`R11U245_UNITARR_OFF`; same site, plus a design-final half in § unitTdLawS245's pass)
A `$unit` typedef of a FIXED-SIZE unpacked array is written as a class-scope typedef of the same type is
(`buildUnpackedArrayTypedefTs`, the class typedef writer's builder):
* a named `array_typespec`;
* a size dim is `[0 : N-1 op]` at the size token, and a ranged dim keeps its bounds;
* the element is an unnamed typespec under a reference named like the typedef.

Its listing objects join § unitTdLawS245's set. Exceptions:
* An array whose ELEMENT is itself a typedef (`typedef nib_t na_t[2]`) is left out of that set (UA a05: golden's
  element copy carries an alias that this pass does not write).
* An ELABORATED module variable of a SIZE-form array binds a bare copy whose right bound is FOLDED: an unlocated
  `INT` constant `N-1` (golden UA/a01 `INT:3`, where the listing keeps the `4 - 1` operation). The elaborated array
  variable already binds its own bare copy (named like the listing, with no alias), so only that copy's range is
  re-made (trace `unitArrTd245_elabfold`).
* Queue, dynamic and associative arrays stay unsupported (UA a02: the class builder's element reference and marker
  spans differ from golden's `$unit` listing: residue 3).

Cases: UA a01, a03, a07 (STRICT_EQUAL), a04, a05, a06 (residues).

### § unitTdLawS245 (`R11U245_UNITLAWS_OFF`; UhdmExporter exportDesign, design-final, right after § lawSCopyHomeInstance36)
LAW S for a `$unit` typedef. The set is every `$unit` typedef listing object of a scalar, vector, predefined or
fixed-array kind, excluding aliases of typedefs. Golden binds per-use copies:

| binder | golden binds | cases |
|---|---|---|
| definition-view module / interface / program NET (Surelog's def view of a body variable) | copy named like the typedef, Typedef_alias (full name = typedef name) to the listing, vpiInstance the design | u01, u04, u08, u10 |
| subroutine formal (io_decl), local, return; class property | the same aliased copy WITHOUT vpiInstance | u03, u07, u12, u20 |
| struct / union member | its own aliased copy, alias named through the member reference (`s_t.b.ui_t`), the dotted `$unit` twin of § memberBareTdAliasNamedByUse183 | u09 |
| ELABORATED instance-scope variable, unranged typedef (`string`, `int`) | keeps the listing | u01, u04 |
| ELABORATED instance-scope variable, ranged vector (`logic [3:0]`) | an UNALIASED, uninstanced copy (LAW S's `rangedTd` rule; an elaborated per-instance clone aliased to the listing is read through to it) | u08 |
| PORT (any view) | keeps the listing (golden r11u19repro q09 / t11 `output nib_t we`, both probe cases EQUAL at the base: the first cut copied the port net and both read type(1); fixed before the law sweep) | — |

* The copies are one per binding. Identity is canonicalised by the strict comparator, and golden's per-use copy
  span (a formal's copy at the use, 8:28) is excused because golden also gives the listing's span.
* Objects are walked in UhdmId order, so the minted copies are deterministic (§ lawSCopyIdOrder186's lesson).
* Ports of an UNRANGED typedef (US u11, `input ui_t n`) were decoded but not written (residue 1).

Cases: every US case.

### § unitTdRetVarAtTypeToken245 (`R11U245_UNITRETLOC_OFF`; TaskFuncEmit, the return-variable span)
A function returning a `$unit` scalar or predefined-kind typedef: golden locates the return variable at the written
return type (`function automatic ustr_t f`, string_var 5:22-5:28), as for a package typedef's return
(`pkgUnitRet9`). Ours copied the shared typedef's span (3:9-3:15). For a `logic` / `bit` return, the existing
module-local clone branch (`typedefRetClone`) already took the token. There the law fires with no byte effect
(`evidence/trace_predicted_corpus.txt`: uhdm2rtlil `func_typename_ret` and `nested_cast_repro` fire in both modes,
and byteverify reads 0 corpus movers). Cases: US u07, u12, u13, u14, u18, u20.

### § unitRealTdElabShares245 (`R11U245_UNITREALTD_OFF`; ModuleEmit, the elaborated real-variable typespec)
A `real` signal typed by a `$unit` typedef binds the typedef's listing object in golden (`real_typespec (ur_t)`
7:9). The fresh anonymous `real_typespec` at the use is the untyped-real rule. A `shortreal` signal typed by a
`$unit` typedef carries the listing reference too (US/u14 `short_real_var work@top.s`), where an untyped shortreal
carries none. Cases: US u05, u14.

## Measurements

* **Grid** (`evidence/grid.txt`, `evidence/gridsum.txt`; `drivers/grid.sh`, `drivers/case.sh`, `drivers/gridsum.py`):
  * 28 case directories (26 cases + 2 decode cases) in both views, 56 case-views, on 9 configurations: pristine, law,
    law + `R11U245_OFF`, and law + each of the 6 switches. That is 504 lines, and every line carries its exit code.
  * Exit codes: rc 4 on 54 of 56 pristine case-views (all but US u08). On the law binary, rc 0 on every case-view
    except UA a02 and a06, which exit 4 on every configuration (the queue/dynamic typedef and the class property
    switch). Under `R11U245_OFF` and under the listing writer's own switch (`R11U245_UNITPREDEF_OFF` for US,
    `R11U245_UNITARR_OFF` for UA) the cases exit 4 as on pristine.
  * `R11U245_OFF` == pristine on 56 of 56.
  * 54 case-views move. **38 enter STRICT_EQUAL** (US u01-u05, u07-u10, u12-u14, u16-u19; UA a01, a03, a07; both
    views) and none leaves.
  * The rest stay stage 1 on both binaries: UA a02 (unchanged bytes), a04, a05, a06; US u11, u15, u20; the two
    decode cases.
  * Each switch reverts only its own cases: UNITLAWS 54, UNITPREDEF 40, UNITARR 12, UNITRETLOC 12, UNITPREDEFAOA 4,
    UNITREALTD 4 case-views. A second full run after the first-line law names were corrected gives identical
    verdicts.
* **Downstream on the cases** (`evidence/dscase_{pristine,law}.txt`, `drivers/dscase.py`, the harness's own `one`):
  * pristine: 17 IDENTICAL, 6 EQUIVALENT, 2 DIVERGENT, 1 STATUS_DIFF;
  * law: 22 IDENTICAL, 2 EQUIVALENT, 1 DIVERGENT, 1 STATUS_DIFF.
  * IDENTICAL on the law: UA a01, a03, a06, a07 (a07 DIVERGENT -> IDENTICAL: the memory typedefs), US u14.
  * No case leaves IDENTICAL.
  * a04 is DIVERGENT on both binaries (residue 2). a02 is STATUS_DIFF on both (uhdm2rtlil's Surelog READ_FAIL).
  * Every law fires under the downstream flags (`evidence/dscase_law_firings.txt`), the positive control of the lane
    census.
* **Census and prediction, frozen before the law sweep** (`drivers/predict.py`, `evidence/predict.txt` md5
  `f6c62b3bd8089b6fb25fcb7087eb1b6c`):
  * The trigger, read from every PRISTINE database (7452: probe, corpora, downstream lanes; fenced paths skipped
    unread), is a design-level typedef of a kind the laws read whose vpiInstance is the design, or the
    `typedef target:` note.
  * The predictor names 22 databases: 6 probe cases, 2 + 2 surelog row-modes (FileResolutionFunction: a nettype,
    over-predicted; Scr1SvTests, a known failure), 8 uhdm2rtlil row-modes and 4 downstream lanes (arrays03,
    func_typename_ret, nested_cast_repro, resolve_types).
* **Gate sweeps** (`tests/sweep.sh --jobs 3`, workdirs `/tmp/r11u245_wP` and `/tmp/r11u245_wL`;
  `evidence/sweep_{P,L}_*`, fenced rows stripped). Pristine reproduces every baseline: probe 3498 + 589, surelog
  470/10 + 466/8, uhdm2rtlil 803 + 0 per mode, downstream 803/66/2/0, all with 0 changes. The law sweep:

  | stage | result |
  |---|---|
  | probe | EQUAL 3498 + STRICT_NOTEQUAL 589, regressions=0 conversions=0 changes=1 |
  | surelog | regressions=0 conversions=0 changes=0 |
  | uhdm2rtlil | regressions=0 conversions=0 changes=0 |
  | downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; the verdict column equal to pristine's row for row |

  Every csv row of the two sweeps is equal apart from the LowMem workdir paths and the one probe change. Both sweeps
  exit 1 only on the law-index staleness check (the new cases; `tests/LAWS.md` regenerated in the patch).
* **The one probe change**: `v11u108repro/brk/f5/b07_param_typedef_arr`, `differ:file(9)` -> `differ:file(7)`.
  * The first record is the same (#4: the `arr_t` copy's file, golden none, ours `dut.sv` 2:9-2:18) in both sweeps.
    The object count moves 328 -> 398 (golden 368), and the walk diverges in both sweeps.
  * Fired by § unitTdLawS245 on the definition net `work@dut.x` (`T x;` with `parameter type T = arr_t`;
    `typedef e_t [3:0] arr_t;`).
  * Away census 0 chain and 0 flat records lost; flat toward 40. The positive control swaps the two sweeps and reads
    flat away 40. It shrinks on the same first field, so it is allowed.
* **Byte movers**:
  * corpus 0 / 2560 (`evidence/byteverify_law_vs_pristine.txt`, `tools/probe/r11v75repro/byteverify.sh` with
    SELFCHECK=1, 2559 / 2560 flagged, on mirrors built from a path list filtered by `$FENCED`, `drivers/bvmirror.sh`);
  * probe 1 / 4087, downstream slang lanes 0 / 805 (`evidence/probe_downstream_movers.txt`, `drivers/movers.py`).

  The 1 mover was predicted by name. The other 21 predicted databases did not move, as the trace explains (below).
* **Positive control of the corpus zero** (`evidence/trace_predicted_corpus.txt`): the law binary with
  `R11U245_TRACE` on the five predicted corpus tests, in both modes.
  * § unitTdRetVarAtTypeToken245 fires on func_typename_ret and nested_cast_repro, with no byte effect (a `logic`
    return already took the token).
  * Nothing fires on arrays03 and resolve_types (their `$unit` typedefs bind ports or nets of the excluded shapes)
    or on FileResolutionFunction (a nettype, not a TypeAlias).
* **Canaries**:
  * `canaries.sh`: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0;
  * `ctcan2.sh`: surelog ok=58 changed=0 (EXPECT_UNKNOWN=1 PASS), uhdm2rtlil ok=2 changed=0 (EXPECT_UNKNOWN=6 PASS).
* **Determinism** (`evidence/determinism_law.txt`, `drivers/det.sh`): three concurrent harness runs of the law binary
  on Earlgrey_0_1 and the five UVM rows, both modes, give one hash per row-mode on all 11 runnable row-modes, each
  equal to the law sweep's.
* **uhdm-cmp**: no corpus row and no probe case touched; 0 cmp lines on every corpus row (unchanged status).

## Faces decoded and not written (with their call sites)

1. **Ports of an UNRANGED `$unit` typedef** (US/u11, `x/p1`, `x/p3`; `input ui_t n`).
   * Golden binds the port object's typespec and the elaborated port variable to two aliased copies (one carrying
     vpiInstance), and the definition net has no typespec at all. A ranged vector port keeps the listing (q09 / t11).
   * A first transcription (copy the definition port without vpiInstance and the elaborated port variable with it)
     made the dump text identical, yet uhdm-cmp still failed on the elaborated port object. Golden SHARES one port
     object between the two views (`port n` id 2 under both module_inst objects), where ours writes two. The branch
     was dropped before the law sweep.
   * Port sharing is ModuleEmit's elaborated port emission, a structural change for a later pass. u11 reads 1101 cmp
     lines on the law (17 on pristine, which exited 4 before listing anything): the walk now reaches the design.
2. **Unpacked-array `$unit` typedefs in other positions**:
   * a class property (UA/a06: UhdmExporter's class property switch, `class property type:
     FixedSizeUnpackedArrayType`, § fixedClassPropIsArrayVar6's gate clause (2), still exit 4; golden writes the
     small `array_var` of r11u243's face 1);
   * a function formal / local (UA/a04: the local binds an anonymous `array_typespec` at the declarator, TaskFuncEmit's
     local array branch; downstream DIVERGENT on both binaries);
   * an element that is a typedef (UA/a05: golden's element copy carries an alias).
3. **Queue / dynamic / associative `$unit` typedefs** (UA/a02): `buildDynContainerTypedefTs` writes no element
   reference for a `$unit` typedef, and the marker range constants carry spans golden leaves out. Not written.
4. **Ground A, for the sister pass**:
   * a module PARAMETER typed by a `$unit` typedef (decode DP/d01: ParamEmit builds the parameter's typespec from the
     canonical type, an anonymous `int_typespec` at 7:13; golden binds a copy parented at the parameter, alias
     `work@top.P.ui_t`);
   * the package listing of an alias of a string typedef (v11u243 C/c04's new head, ParamEmit `emitPackage`).
5. **`realtime`** (decode DR/d01): the listing is now a `time_typespec`. The elaborated variable is a `real_var`
   with no typespec where golden writes `time_var` bound to the listing. ModuleEmit's real-variable dispatch reads
   the canonical FloatingType. Not written.
6. **A generate block's statements in the definition view** (US/u15: the `$unit` byte typedef variable inside `if
   (1) begin : g` lists a `named_begin` statement golden does not). This is pre-existing, on the definition-view
   generate emission (ModuleEmit). The task formal of the same case clears.

## Residues, ranked

1. The brief's item (1)(a): the `this`-wire anchor faces a13 / a03 / a06 / a15 and the net-list position. These
   are stage 1 on pristine at the base (v11u243 A cases), so no judge-equal case measures them. Not attempted.
2. Item (1)(b): LAW S on a package-qualified foreign binder (v11u243 C/c07, x01). Unchanged bytes, `differ:line`
   on both binaries.
3. Item (1)(d): the package listing half of d01 / d03 is ground A (ParamEmit `emitPackage`). The `$unit` half is
   written here (§ unitArrTd245). The property shape is face 2 above.
4. Item (1)(e): the module and derived-class import parameter copies. Not attempted.
5. Faces 1-3, 5 and 6 above.
6. The brief's items (2) (pass 241's copy residues), (3) (pass 239's), (4) (pass 237's), (5) (BuildUVMPkg's
   module/type clusters behind ground-A #81827) and (6) (passes 231 / 228): not attempted.
7. Carried ground-A heads, unchanged by this pass and for the sister pass:
   * SimpleUVM #98800 / #98812 (ExprEmit § dpiExportedPkgSubBareOwnTdUnsupported170);
   * BuildUVMPkg #81827 (StmtEmit);
   * Scoreboard #81633 (ExprEmit), then #130737;
   * MiniAmiq #71388 / SeqDriver #71344 (StmtEmit);
   * Earlgrey #136315, Rggen #23546, BlackBePipeInt #38807 / #38803 (ParamEmit).

## Process

* Every helper reads `$FENCED` fail-closed from the FENCED= line of `tools/probe/r11u107repro/canaudit.sh`
  (`drivers/env.sh`). `predict.py`, `movers.py`, `awayrows.py`, `bvmirror.sh` and `cmdsaudit.sh` filter every
  corpus path list by `$FENCED` before opening a file. The only corpus rows run outside the gate sweeps are five
  named, unfenced tests (checked against `$FENCED` first): verify_golden.py `--filter` for the pre-check and for the
  trace.
* **One lapse, recorded:** the first command of the pass printed the FENCED= line itself (the four names) to this
  agent's own output while locating it. No fenced source, database or output was opened, and no binary or script ran
  on one.
* The pristine binary was frozen before any source edit. The law binary was frozen after the last law. The
  predictor was written after the last law and frozen (md5 above) before the law sweep. The two sweeps ran one at a
  time, and the cases' downstream runs ran after both sweeps.
* Every `uhdm-dump` call went through a guarded `dump()` / `[ -x "$UHDM_DUMP" ]` check. Every file was written with
  an absolute path under the worktree or `/tmp/r11u245_*`.
* The sweep csvs under `evidence/` leave out every row naming a fenced test by word boundary. For the integration's
  substring fence check, they also leave out the rows of one unfenced uhdm2rtlil test whose name contains a fenced
  name as a substring (1 downstream and 2 uhdm2rtlil rows per sweep). The full csvs read as stated above.
* No patch file is kept under this directory. The delivery `/tmp/r11u245.patch` is transport only.
