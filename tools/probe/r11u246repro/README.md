# r11u246 — pass 246, the expression/parameter ground (implementer)

Base `08d31c79` (matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp` (one drain call and
its declaration) and the new switch header `src/R246.h`. No file of the sister ground (TypeEmit, ModuleEmit,
UhdmExporter, TaskFuncEmit, uhdm_main, include/UhdmExporter.h) is touched.

Nine laws. Each reads its own `R11U246_<LAW>_OFF`; `R11U246_OFF` drops all nine and restores the pristine bytes.
`R11U246_TRACE=<dir>` writes `<dir>/<pid>.246`: first line `OUT <-o path>`, then one `<law> <detail>` line per firing.
The non-writing trace tags are `callArgParamCopyOwnTs246_nested` and `callArgParamCopyOwnTs246_nosrc`.

The four slang-fenced tests are never named here. Every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed. See "Process notes" for the one unfiltered read.

## Verdict per targeted row (base -> this pass; fresh rows of the law sweep `/tmp/r11u246_wL`)

**No corpus row converts.** Four row-modes change their strict verdict, each with **0 golden-agreeing records lost**
(chain-keyed and flat away census 0 on every database that moved). **28 probe cases convert.**

```
Rggen,default,STRICT_NOTEQUAL,differ:fullname(199),,differ:fullname(199)
Scoreboard,default,STRICT_NOTEQUAL,differ:line(6),,differ:line(6)
SimpleUVM,default,STRICT_NOTEQUAL,differ:line(6),,differ:line(6)
SimpleUVM,testflags,STRICT_NOTEQUAL,differ:line(6),,differ:line(6)
```

| row-mode | base | after | what moved ([evidence/heads.txt](evidence/heads.txt)) |
|---|---|---|---|
| SimpleUVM d/t | `type(1)` #98800 / #98812 | `line(6)` #159457 / #159469 | Brief item (1)(c). The DPI cast `uvm_severity'(severity)` in `m__uvm_report_dpi` now resolves in the home package's elaborated copy (§ dpiTopCastResolvesByModImport246). The walk then passed #128833 (the foreach `addrs` INT:63 fold, § foreachLocalArrTsOwnListing246), #144214 (`visit.compiled_regex`, § hpFnStaticTrailScopeJoin246), #168867 (`sev_id_overrides[id].exists(uvm_severity'(..))`, § methArgCastTsChainName246), #173841/#173902 (`cb.METHOD` ends, § macroParamMethNameEnd246), the 11 stream-brace records in uvm_object_defines.svh 3494/3660/3674 (§ streamBraceInMacroBody246) and the 24 file-less M_UVM_QUEUE_RESIZE records (§ colSpanWalkStampsFile246). The six records left are all on the sister ground (see "Sister-ground faces"). Toward 260 per mode, away 0. |
| Scoreboard d | `type(1)` #130737 | `line(6)` #159637 | Brief item (1)(b): #130737 is the same face as BuildUVMPkg #153018 (the foreach over `uvm_reg_addr_t addrs[]` in `uvm_reg_map::m_set_reg_offset`, golden INT:63 at uvm_reg_model.svh 73:24-26). Cleared with SimpleUVM's records above; the remaining six are SimpleUVM's six. Toward 168, away 0. |
| BuildUVMPkg d/t | `endcol(3)` | `endcol(3)` (no verdict change) | Brief item (1)(a). #153018 (the foreach INT:63 face) and #160760 (the `exists` cast chain name) are cleared. Left: the sister heads #91593 and #129711, then #185844, a TaskFuncEmit face (below). Toward 23 per mode, away 0. |
| Rggen d | `line(202)` #23546 | `fullname(199)` #26477 | Brief item (2). #23546 (the folded parameter actual of `get_sub_n_list(N)`) is cleared by § callArgParamCopyOwnTs246, with two more records behind it. The new head is the interface-port-view full name of `register_if.access` seen through `g_decoder[0].u_decoder.i_access` (ModuleEmit; see below). Toward 13, away 0. |
| MiniAmiq d/t, SeqDriver d/t | `depth(1)` #76762 / #76718 | unchanged | Brief item (1)(d), the sister head (UhdmExporter pkgCloneHierBind9). Bytes move toward golden behind it: MiniAmiq 186 per mode, SeqDriver 145 per mode (chain key; flat 118), away 0. SeqDriver's elaborated `uvm_pkg` DPI cast resolves as in SimpleUVM (its testbench imports `uvm_pkg::*` beside `top_tb`). |
| Earlgrey_0_1 d/t | `fullname(160)` / `fullname(55)` | unchanged, no law fires | Brief item (3): decoded, all three heads on the sister ground (below). |
| BlackBePipeInt d/t | `depth(1)` / `fullname(3)` | unchanged, no law fires | Brief item (4): decoded (below), not written. |

The base records, reproduced at the base with `build/uhdm-strictcmp` (question 1):

```
SimpleUVM d #98800 type    A: 9 enum_typespec        uvm_pkg::uvm_severity  uvm_sequence_item.svh 352 37 352 49
                           B: 9 unsupported_typespec uvm_severity           uvm_globals.svh       168 15 168 27
Scoreboard d #130737 type  A: 21 constant  uvm_reg_model.svh 73 24 73 26  INT:63
                           B: 21 operation uvm_reg_model.svh 73 24 73 28
Rggen d #23546 line        A: 13 int_typespec rggen_or_reducer.sv 3 13 3 16
                           B: 13 int_typespec rggen_or_reducer.sv 8 55 8 58
```

## The laws (read each at its § token)

### § dpiTopCastResolvesByModImport246 (`R11U246_DPITOPRES_OFF`; ExprEmit, the cast branch beside § dpiExportedPkgSubBareOwnTdUnsupported170, helper `modImportSeesTd246`)

§ 170 degrades a bare own enum/struct/union typedef cast in a package subroutine whose `export "DPI-C"` is written
above it to `unsupported_typespec`. Surelog's late binding (ElaborationStep `bindTypedefs_`) swaps that placeholder
through a map keyed by the bare typedef name. Only a **module**'s typedef map holds an imported package typedef under
its bare name. So the home package's **elaborated** (TopPackages) copy resolves when some module sees the typedef by
import:

* a `import p::*` or `import p::<name>` in the module's header or body, or
* a file-scope import anywhere in the module's root file (before or after the module).

An interface, a program, a package, a file-scope import in another file, an explicit import of another name and a
qualified use give nothing. The definition (AllPackages) copy and every importer clone keep the placeholder. The
resolved object is the elaborated listing's own typespec, the target the cast takes when nothing degrades it.

Measured on real v1.87 goldens (grid DT, 30 cases): SimpleUVM and SeqDriver resolve, while MiniAmiq, BuildUVMPkg and
Scoreboard do not (Scoreboard's `import uvm_pkg::*` sits in design.sv, which holds a class and no module). This is
the design-level distinguisher pass 170's residue R1 asked for.

### § foreachLocalArrTsOwnListing246 (`R11U246_FEOWNTS_OFF`; StmtEmit, the foreach array reference)

This applies in a package's elaborated listing, for the home package's own subroutine and never in an importer clone.
The iterated reference of a foreach over a subroutine-local array binds the array_typespec of the local declared in
**that** listing. There, Surelog compiled the declaration with the element alias's range folded (INT:63).

The deferred drain `pendingForeachArrayTs` (UhdmExporter) used to bind the last emission of the symbol, a later
unreduced copy, so ours read the operation `64-1`. That was SimpleUVM #128833, Scoreboard #130737 and BuildUVMPkg
#153018 (`uvm_reg_map::m_set_reg_offset`, `foreach (addrs[i])`).

**Law:** the reference is bound at emission, which leaves the drain nothing to do for it.

Grid FE: f12 (an out-of-body method, the UVM shape) converts in both views. In-body methods already matched. f13 (an
importer) is stage 1 on both binaries with an unchanged uhdm-cmp count and 0 records lost.

### § hpFnStaticTrailScopeJoin246 (`R11U246_HPFNSTATIC_OFF`; ExprEmit, the HierarchicalValue trailing reference)

A hierarchical read of a subroutine's static local from a package or class method names its trailing reference with
the scope separator. Golden reads `...::end_v::compiled_regex` (uvm_traversal.svh 284); ours read
`...::end_v.compiled_regex`. A module reader keeps the `.`.

Gate: the reader's prefix is `::`-first and the target's scope (through statement blocks) is a subroutine. Grid HS:
h01-h03, h05, h06 enter STRICT_EQUAL in both views. h04 (a task static) is stage 1 on both binaries on another face,
with 0 records lost.

### § methArgCastTsChainName246 (`R11U246_MARGCASTTS_OFF`; ExprEmit `refFullNameThroughNamedExpr175` drain)

The ref_typespec of an operation inside the argument of a method call that is a hier_path's last element stores no
full name in golden, so the reader's chain names it. Golden reads
`uvm_pkg::uvm_report_handler::process_report_message::sev_id_overrides[id].exists`; ours read
`...::process_report_message`. This is the ref_typespec twin of § methodArgOpRefChainName198.

Only a name that the chain extends is replaced. Grid MC: 5 case-views enter STRICT_EQUAL (m02/m03 elaborated, m04 default,
m05 both). m01 moves fullname -> line, the sister's type-parameter location face. m04's elaborated view keeps a
pre-existing `int_var key` full name.

### § macroParamMethNameEnd246 (`R11U246_MACNAMEEND_OFF`; ExprEmit, five method-call span sites)

Consider `cb.METHOD;` with METHOD = `raised(this,obj,...)` (uvm_callback_defines.svh 168). Golden ends the
method_func_call at the parameter's column plus the **name's** length: 168:11-17, and `dropped` 168:11-18. Our end
was read past the substituted argument: 168:11-56, and a long argument ran it onto the next line.

**Law:** where the start's text does not spell the name, the span is set to (start line, start column + name length).
Grid MN: n01-n03 enter STRICT_EQUAL in both views. The n04 control is unchanged.

### § streamBraceInMacroBody246 (`R11U246_STREAMBRACEMAC_OFF`; ExprEmit Streaming)

A stream operation written in a macro body spans its inner braces as § streamOperandBraceSpan140 measured outside
macros. Golden reads 3494:15-26 for `{ << int { __array }}`; ours read the operands' range ± 1 (16-25).

* With syntax, the law uses the syntax's own `innerOpenBrace` / `innerCloseBrace` tokens, laid out by setLoc. An
  operand from a macro argument works here too (uvm_unpack_enumN 3674:11-24, where ours had read the invocation's
  line 544).
* Without syntax (an rvalue stream), the law reads the body text when every location lies in one body expansion.

Grid SB: b02 and b03 enter STRICT_EQUAL. b04's one-line-macro rvalue streams (an operand from an argument, with no
syntax) stay as they were; this is a residue. The b01 control is unchanged.

### § colSpanWalkStampsFile246 (`R11U246_COLSPANFILE_OFF`; ExprEmit `setColSpan132`)

§ macroPasteRecvMisreadIsAstChain132's column walk locates its objects without the file that
§ vpiFileOnEveryLocated117 stamps through setLoc. Golden's M_UVM_QUEUE_RESIZE `ref_obj` / `size` / `push_back` /
`pop_front` (uvm_object_defines.svh 1566-1567) carry the file; ours had none.

**Law:** stamp the receiver start's file. Grid CF: c01-c03 enter STRICT_EQUAL. Probe r10v132repro/v4_home converts.

### § callArgParamCopyOwnTs246 (`R11U246_PACOPYTS_OFF`; ExprEmit call-argument stamp + `drainCallArgCopyTs246`, called from ParamEmit's design-final list)

§ genLpPaCallArgCopy13 copies an elaborated parameter's param_assign Rhs constant into a multidimensional
initializer's call (Surelog's clone branch, `clone_tree(param_ass->Rhs())`). The clone keeps the Rhs's ref_typespec:
golden Rggen reads N's own `int_typespec` 3:13, where ours read the formal's 8:55.

Only an evalFunc that runs the call in the tree overwrites the clone. That is exactly the nested write-through
§ nestedParamActualTs6 models for the call node: FuncInModule's `get_sub_n_list(N)` node is stamped and its actual
carries the formal's typespec, while Rggen's node is bare and its actual keeps N's.

**Law:** the copy takes the source constant's typespec design-final, unless § nestedParamActualTs6 stamped the call
node (`_nested`, no byte change).

Grid PA: p01-p06, p08-p10 and p13 enter STRICT_EQUAL in both views (call depth 0/1/2, an override, a default, a
top-level module, the same value, two arguments, a localparam source). p08 (a `logic [7:0]` parameter) and p09 (an
implicit parameter) were uhdm-cmp NOT_EQUAL at the base. p07 (FuncInModule with an override), p11 (generate scope)
and p12 (an inline nested call) are stage 1 and unchanged. FuncInModule d/t stays CMP_EQUAL (byte-identical).

### § contLvMidSelNetBase246 (`R11U246_LVNETMIDSEL_OFF`; ExprEmit `emitMixedHierPath`, the lvalue member-select branches)

Take a continuous-assignment lvalue `w.key[1].d = ...` whose base is a **net** (`wire s_t w;`). Golden spans the
member through its index and freezes the doubled name, as for a variable: `work@m.w.key[1].d.key` 10:12-18. Ours took
the index-only branch (`w.key[1]` 10:16-17), in the definition listing and in every elaborated instance.

Grid LN: n01 and n07 enter STRICT_EQUAL. n02's elaborated records all clear; its definition-view gen-scope record is
TypeEmit's (below). n03 and n04 are stage 1 on both binaries with unchanged counts and 0 records lost. The n05 and
n06 controls are unchanged. No corpus database fires this law.

## Binaries (frozen before any measurement; every `cmds.txt` audited by binary path)

| binary | md5 | note |
|---|---|---|
| pristine (`/tmp/r11u246_bin/pristine`) | `2af88ce8c0c70f3e728d6e8fdfaf0d9a` | built at `08d31c79` with the system-deps config (`-j 2`), identical to the main tree's `build/slang-uhdm`; reports slang 12.0.0+545f88b2e |
| law (`/tmp/r11u246_bin/law`) | `35706fcd9b8f6a3e61d1874dc6e84d1e` | this patch (frozen 2026-10-05T07:35:58-04:00, before the census) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the worktree's build |
| strictcmp_x | `886f030233ecdbcce7d0e29ac0c4df2c` | `drivers/cc_x.sh`, for the away census |

Development binaries `dev1` to `dev11` ran only on cases and on filtered target rows, and in two full development
sweeps (dev7 and dev9, regressions 0 in every stage). Every `cmds.txt` of the pristine sweep (fence-filtered path
list, 3265 slang runs) names `/tmp/r11u246_bin/pristine` only, and every one of the law sweep names
`/tmp/r11u246_bin/law` only.

## Gates (from the worktree, SLANG_UHDM exported, `tests/sweep.sh --jobs 3`; [evidence/sweep_pristine.txt](evidence/sweep_pristine.txt), [evidence/sweep_law.txt](evidence/sweep_law.txt))

| stage | pristine sweep (`/tmp/r11u246_wP`) | law sweep (`/tmp/r11u246_wL`) |
|---|---|---|
| probe | EQUAL 3510 + STRICT_NOTEQUAL 577, 0 / 0 / 0 | EQUAL **3538** + 549: **regressions 0, conversions 28, changes 5** |
| surelog | 470 + 10 / 466 + 8, 0 / 0 / 0 | 470 + 10 / 466 + 8: **regressions 0, conversions 0, changes 4** (the rows above) |
| uhdm2rtlil | 803 + 0 per mode, 0 / 0 / 0 | **0 / 0 / 0** |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **803 / 66 / 2 / 0, not excused 0**; the two csvs sorted and diffed: **0 lines** |

Both sweeps print `law index STALE` first: the base's committed `tests/LAWS.md` predates its own commit. The patch
carries the regenerated file.

**Probe conversions (28):**

* § callArgParamCopyOwnTs246 (27): r10rgg13repro/top; r10rgg6repro/cells genfor_none_n4_yes_typed_param,
  genfor_p1_n4_yes_typed_param, one_none_n4_yes_typed_param, one_none_n4_yes_typed_proc,
  one_p1_n2_yes_typed_param, one_p1_n4_yes_typed_param, one_p1_n4_yes_typed_param_2ts, r2_rggen, r3_proc_outer,
  rec_p1_n4_yes_typed_param, top_none_n4_yes_typed_param, top_none_n4_yes_typed_proc, top_p1_n2_yes_typed_param,
  top_p1_n4_yes_typed_param, top_p1_n4_yes_typed_param_2ts, twoN_none_n4_yes_typed_param,
  two_none_n4_yes_typed_param, two_p1_n4_yes_typed_param; r10rgg7repro/cells m_sat_13x, s_sat_n1, s_sat_n2,
  s_sat_n4; r10vrgg5repro v3_retlast, v4_single, v8_postzero; r10vrgg6repro/cells/v_shared_fnname.
* § colSpanWalkStampsFile246 (1): r10v132repro/v4_home.

**Probe changes (5):**

| case | change | law | attribution |
|---|---|---|---|
| r10rgg6repro/cells one_none_n4_yes_typed_ca, r2_ca_outer, top_none_n4_yes_typed_ca | line(2) -> type(1) | § callArgParamCopyOwnTs246 | the old first record (#483 in one_none_n4_yes_typed_ca: N's typespec, golden 3:13) is cleared; the remaining record #778 (a continuous assignment's `f2(P1)` kept by golden, folded by ours) is in the pristine database too; 1 toward, 0 away each |
| r10uvm208repro/g208_e_head | fullname(8) -> fullname(5) | § foreachLocalArrTsOwnListing246 | the three foreach-loop-variable records pass 244 named (#173, #386) cleared; 3 toward, 0 away |
| r10v208repro/v208_f_io | name(15) -> name(12) | § foreachLocalArrTsOwnListing246 | improvement; 3 toward, 0 away |

**uhdm-cmp** reads 0 lines (rc 0) on all 10 corpus movers ([evidence/movers/uhdmcmp.txt](evidence/movers/uhdmcmp.txt)).

**Canaries** ([evidence/canaries.txt](evidence/canaries.txt)):

* `canaries.sh` surelog: ok=49 changed=3. The three are the targeted SimpleUVM d/t and Scoreboard d; Rggen is not a canary. unknown-names 7 (the u2r-only canaries).
* `canaries.sh` uhdm2rtlil: ok=16 changed=0.
* `EXPECT_UNKNOWN=1 ctcan2.sh` surelog: PASS.
* `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil: PASS.

**`R11U246_OFF=1`** with the law binary writes the pristine bytes on all 10 corpus mover row-modes
([evidence/movers/off_corpus.txt](evidence/movers/off_corpus.txt)) and on all 186 grid case-views.

## The mover prediction, frozen before the law sweep ([evidence/census/](evidence/census/))

`drivers/census.sh` ran `law` with `R11U246_TRACE` over both corpora in both modes, using a `--filter` built from
`$FENCED`, and over every probe case. `drivers/dscensus.py` ran every downstream lane on the harness's translated
command line. `drivers/predict.py` then named every database whose process fired a writing branch.

**47 predicted movers:** 10 surelog row-modes, 37 probe cases, 0 uhdm2rtlil and 0 downstream lanes. The prediction
was frozen at 2026-10-05T07:41:29-04:00 (`frozen_at.txt`, md5 `f9933dbb316869b183685f9d6b3f7960`); the law sweep's log was
created at 07:41:40.

Firings ([census/firings.txt](evidence/census/firings.txt)):

| law or tag | firings |
|---|---|
| foreachLocalArrTsOwnListing246 | 713 |
| colSpanWalkStampsFile246 | 192 |
| streamBraceInMacroBody246 | 112 |
| callArgParamCopyOwnTs246 | 68 |
| callArgParamCopyOwnTs246_nested (non-writing) | 24 |
| macroParamMethNameEnd246 | 14 |
| methArgCastTsChainName246 | 9 |
| hpFnStaticTrailScopeJoin246 | 7 |
| dpiTopCastResolvesByModImport246 | 4 |

`contLvMidSelNetBase246` fires in no corpus, probe or downstream database. It is carried by its grid alone.

### byteverify

`tools/probe/r11v75repro/byteverify.sh` was run with `SELFCHECK=1`, on hard-link mirrors of both sweeps without the
fenced paths (`drivers/bvmirror.sh`) and with same-length workdir names
([evidence/movers/byteverify.txt](evidence/movers/byteverify.txt)).

It reads `PATH_SETS_IDENTICAL (2560 paths)`, **MOVERS: 10 / 2560**: BuildUVMPkg d/t, MiniAmiq d/t, Rggen d,
Scoreboard d, SeqDriver d/t and SimpleUVM d/t. That is exactly the 10 predicted.

`SELFCHECK (every file vs one fixed file): 2559 / 2560 flagged` is the self-check reading correctly, not a movers
line. One side is replaced by one fixed file, and that file compared with itself is the one path the check cannot
flag.

### Probe and downstream movers

**Probe:** 35 of 4087 databases move ([evidence/movers/probe_movers.txt](evidence/movers/probe_movers.txt)), all of
them predicted. Two predicted cases did not move: r10buvm8repro/v3_argts8 and r10v122repro/q7extra. There,
§ foreachLocalArrTsOwnListing246 bound the object the deferred drain would have bound anyway, which is an
over-prediction.

**Downstream:** 0 of 805 slang-lane databases move, and the verdict csvs are identical.

## Away-moved-record census (map 13's chain-keyed census, `drivers/awayrows.py` with strictcmp_x; [evidence/movers/away.txt](evidence/movers/away.txt))

Over the 45 databases that differ between the pristine and the law sweeps, **chain-keyed away is 0 and flat away is 0
on every one**. Toward counts:

| database | toward (chain key) |
|---|---|
| SimpleUVM, per mode | 260 |
| MiniAmiq, per mode | 186 |
| Scoreboard d | 168 |
| SeqDriver, per mode | 145 (flat 118) |
| BuildUVMPkg, per mode | 23 |
| Rggen d | 13 |
| r10v132repro/v4_home | 48 |
| r10rgg7repro/cells/m_sat_13x | 13 |
| the other probe movers | 0-4 each |

g193_c_argface and t51a read 0 / 0: their byte change is outside every record, in identity and order.

Positive control ([evidence/movers/away_reversed_control.txt](evidence/movers/away_reversed_control.txt)): the same
census with the sweeps swapped reads those numbers as away, with toward 0.

## Determinism ([evidence/det_law.txt](evidence/det_law.txt))

`drivers/det.sh` ran three concurrent harness runs of the law binary on Earlgrey_0_1 and the five UVM rows, in both
modes. It reads **one hash per row-mode on all 11** (Scoreboard testflags writes no database), each equal to the law
sweep's database:

* Earlgrey_0_1 d `99040b3db63c`, t `233bf5448585` (unchanged from the base)
* MiniAmiq d/t `5cda5adadf8e`
* SeqDriver d `3c37ab496583`, t `8567e06eed93`
* SimpleUVM d `9e6e51503423`, t `a093007b6eaa`
* Scoreboard d `9340d9e97507`
* BuildUVMPkg d/t `d18305a4d1c6`

## Grid (cases/, 93 cases, both views; `drivers/gridp.sh` (grid.sh, one case per job), `drivers/gridsum.py`; [evidence/grid/grid.txt](evidence/grid/grid.txt), [evidence/grid/grid_summary.md](evidence/grid/grid_summary.md))

The grid made 2232 runs: pristine, law, law with `R11U246_OFF`, and the law with each of the nine switches, in the
default and `-elabuhdm` views. **Every line carries its exit code**: 2208 lines exit 0. The 24 others are DT/d12_v11
(a class-local `sev_e loc` in a package class method), which exits 4 on every binary including pristine, at stage 1
with an unchanged uhdm-cmp count.

* `R11U246_OFF` writes the pristine bytes on **186 of 186** case-views.
* **95 case-views enter STRICT_EQUAL and none leaves.**
* No uhdm-cmp line count changes.
* The chain-keyed away census on all 120 moved case-views ([evidence/grid/away_cases.txt](evidence/grid/away_cases.txt), `drivers/awaycases.py`) reads **away 0 on every one**, toward 1642 in all.
* Each switch reverts only its own law's cases:

| switch | case-views reverted | cases |
|---|---|---|
| DPITOPRES | 38 | DT d03-d06, d08-d17, d20, d24, d25, d29; X x04 |
| FEOWNTS | 6 | FE f12, f13; X x05 |
| HPFNSTATIC | 12 | HS h01-h06 |
| MARGCASTTS | 12 | MC m01-m05; X x03 |
| MACNAMEEND | 6 | MN n01-n03 |
| STREAMBRACEMAC | 6 | SB b02-b04 |
| COLSPANFILE | 6 | CF c01-c03 |
| PACOPYTS | 22 | PA p01-p06, p08-p10, p13; X x02 |
| LVNETMIDSEL | 12 | LN n01-n04, n07; X x01 |

| group | law | shapes | pristine -> law |
|---|---|---|---|
| DT d01-d31 | § dpiTopCastResolvesByModImport246 | no module; module without import; class extension + top; module-body import; file import before / after the module; explicit import of the type / of another name; program, interface, package importers; qualified use; class-method / package-function formal orders (the shared enum's location); multi-file SimpleUVM / Scoreboard / MiniAmiq shapes | 34 case-views enter STRICT_EQUAL. The no-import, program, interface, package and other-file controls are byte-identical. d12 exits 4 on both binaries. m4 (d28) was dropped: illegal declaration order for slang. |
| FE f01-f16 | § foreachLocalArrTsOwnListing246 | dynamic, queue, fixed and associative locals; a macro width; a package-parameter width; task; two loops; nested block; module function; out-of-body method; an importer; a wildcard import plus class use; a `logic` width | f12 enters STRICT_EQUAL in both views. f04, f11 and f16 are stage 1 on both binaries; f13 is stage 1 with 0 lost. The rest are equal on both. |
| HS h01-h06 | § hpFnStaticTrailScopeJoin246 | a DPI argument; call-argument, rvalue and condition reads; task statics; a module reader (control) and a class inside a module; extern methods | 10 case-views enter STRICT_EQUAL. h04 is stage 1 on both. |
| MC m01-m05 | § methArgCastTsChainName246 | parameterized pool `exists`; associative `exists`; operation, ternary and two-argument forms; module scope; `this.` receivers | 5 case-views enter STRICT_EQUAL: m02 and m03 (elaborated view), m04 (default view) and m05 (both). m01: fullname -> line (the sister's type-parameter location). The default views of m02 and m03 are stage 1 on both binaries with unchanged counts. |
| MN n01-n04 | § macroParamMethNameEnd246 | multi-line and one-line bodies; names of 1 to 18 characters; an include file; plain-call and receiver-macro controls | n01-n03 enter STRICT_EQUAL in both views. |
| SB b01-b04 | § streamBraceInMacroBody246 | non-macro control; multi-line body lvalue and rvalue; a macro-argument operand (include file); one-line macros, `>>` and sliced | b02 and b03 enter STRICT_EQUAL. b04's one-line rvalue streams are a residue. |
| CF c01-c03 | § colSpanWalkStampsFile246 | a pasted queue-resize macro in a module, a class method, and an include file | all 6 case-views enter STRICT_EQUAL. |
| PA p01-p13 | § callArgParamCopyOwnTs246 | depth 0, 1 and 2; no override; top module; same value; `logic [7:0]` and implicit parameters; two arguments; generate scope; an inline nested call; a localparam source; FuncInModule with an override | 20 case-views enter STRICT_EQUAL. p07, p11 and p12 are stage 1 and unchanged. |
| LN n01-n07 | § contLvMidSelNetBase246 | a module-level net; a generate scope; a base-selected net array; an inout port; controls (a trailing select and an rvalue; a variable); parameter, localparam and `$clog2` indices | n01 and n07 enter STRICT_EQUAL. |
| X x01-x05 | context | an interface body with an implicit net and a function static; a class specialization in a bound; `this.`, named, empty-slot and default-argument calls with pure-virtual and extern prototypes; the DPI cast with a module-body import and an implicit net; out-of-body method foreach with constant slots (indexed width, replication) | x03 and x04 enter STRICT_EQUAL. x01, x02 and x05 are stage 1 on both binaries with unchanged counts and 0 lost. |

The constant slots were exercised where each law can meet them:

* an indexed part-select width and a replication count (X x05);
* a dimension bound with a specialization call (X x02);
* parameter defaults (PA p04, p05) and parameter, localparam and system-call indices (LN n07);
* the macro-born and include-file tokens of the location laws (MN n03, SB b03, CF c03).

**Downstream on the cases** (`drivers/dscases.py`, the harness's own `one`; [evidence/downstream/](evidence/downstream/))
gives the same verdict for every case on both binaries: 90 IDENTICAL, 2 EQUIVALENT, and 1 DIVERGENT (PA p11, a
generate-scope localparam, NO_GATES on both lanes) that is pre-existing.

## Sister-ground faces (decode only; call sites)

1. **SimpleUVM d/t and Scoreboard d, the six records left** (all wrong at the base too, behind the old heads):
   * #159457 / #159469 / #159637: the `T` int_typespec of `uvm_queue#(T)`. Golden locates it at uvm_queue.svh 171:35, ours at 43:13. This is BuildUVMPkg #129711's face (the class body writers, TypeEmit).
   * #194836: the second stringification `` `"T``(string)`" `` in uvm_printer_defines.svh 270 starts at the unshifted body column (golden 51, ours 42). The site is UhdmExporter `locLineCol` (§ ppMacroBodyLines160's stringify branch with `macroArgShift`).
   * #201235: the raw full name of a class-scope enum typedef's base reference (`uvm_resource_types::override_e`), TypeEmit's class typedef writer.
   * #201602 / #201634: `typedef T tab_t[string]` in `uvm_spell_chkr#(T)`, whose element string_typespec has no file. TypeEmit, the class typedef writer under a specialization.
   * #202914: `uvm_utils::find_all`'s return type `types_t` (`typedef TYPE types_t[$]`). Golden binds the array_typespec without an alias, while ours wraps it in `<in>types_t`. TaskFuncEmit's return typespec, the walk-diverging record.
2. **BuildUVMPkg #185844** (after the sister heads #91593 and #129711): `uvm_tlm_b_initiator_socket::connect(this_type provider)`. Golden's io_decl has no typespec (`this_type` is the base class's typedef, unresolved there), while ours binds `class_typespec this_type` 13776. TaskFuncEmit formal typespec.
3. **Rggen #26477** (the 44 port-view full names): the interface variable `register_if.access` seen through the modport io_decl is named after the child port it was connected to, `...g_decoder[0].u_decoder.i_access.access` (a last-writer of the port connection). ModuleEmit's interface port view.
4. **Earlgrey_0_1** (brief item 3), all three heads decoded with cases (kept in this pass's scratch, not committed):
   * #136315 / #137760: an imported package parameter written bare as a system call's direct argument in a module definition's net range (`logic [$clog2(NumRound)-1:0] round;`) folds to a constant whose ref_typespec golden names after the module (`work@sha2`). A qualified spelling, an operand one level deeper and an outside-call use stay unnamed. The site is TypeEmit `emitSyntaxExpr` (its InvocationExpression branch emits the definition listing's range). The law was written in ExprEmit's call branch first, fired nowhere, and was removed. The elaborated view's `[$clog2(W):0]` fold also ends at `$clog2` (ours 7:16, golden 7:19 — the whole call): same branch.
   * #142988: `assign hw2reg.key[7-i].d = '0;` in a definition-view generate scope. Golden spans the member select `key[7-i]` from the member through `]`; ours spans the bracket contents. This is TypeEmit `emitSyntaxExpr`'s expression-indexed bit_select branch ("vc.sv row 5"). The same select outside a generate scope on a **net** base was ours, and is § contLvMidSelNetBase246.
   * #154375 / #165002: `.instr_pmp_err_i(pmp_req_err[PMP_I])`, the folded index constant's ref_typespec in the module definition's ref_module port. Golden names it after the instance (`work@ibex_core.if_stage_i.pmp_req_err`), ours after the port (`...if_stage_i.instr_pmp_err_i.pmp_req_err`). The bit_select's own name is right; the prefix comes from the port high-conn emission (ModuleEmit).
5. **MiniAmiq / SeqDriver #76762 / #76718**: UhdmExporter pkgCloneHierBind9 / § cloneStmtHomeVarRef17 (pass 244's decode stands).

## Residues, ranked (ground A first)

1. **BlackBePipeInt d #38807 / t #38803** (brief item 4; decoded, not written). In bp_be_pkg's re-listed copy of
   `dev_addr_width_gp`, the paren-cast width reference under the int_typespec 1793:1-34 binds, in golden, a
   **parameter copy** `bp_common_pkg::dev_addr_width_gp` that no listing walks (so the strict walk expands it under
   the reference). Ours binds the listed object (default view), so the walk does not expand it and diverges in
   depth.
   * The site is ParamEmit `stampParenCastWidthTs` (§ parenCastWidthRefPkgBare207, `pcwDecl207`).
   * The law to write would mint one unlisted parameter copy per importer copy. Its identity rules (one per copy, or shared) need a grid first.
2. **SB b04**: an rvalue stream in a one-line macro with an operand from a macro argument has no syntax, so
   § streamBraceInMacroBody246's text reading declines (two buffers). Golden lays the braces out at the invocation.
3. **MC m04 (elaborated view)**: the `int_var key` of an associative `exists` in a class at file scope reads
   `work@pool::m` where golden has `work@pool::exists::m.exists::key` (pre-existing).
4. **LN n03 / n04 and the PA p07, p11, p12 stage-1 shapes**: other faces, wrong on pristine too.
5. Brief items (5) to (7): not attempted. These are pass 244's, 242's, 240's and 238's grid residues, pass 245's
   ground-A faces and d03, map 15's ground-A brief, and the carried value encodings.

## Process notes

- **Fence (one unfiltered read).** The first binary-path audit of the pristine sweep ran
  `find surelog uhdm2rtlil -name cmds.txt | xargs grep -h '^slang:'` with no fence filter. It read the command-line
  records of the four fenced rows (8 cmds.txt) and printed only the per-binary counts.
  * Every later audit built its path list first and filtered it by `$FENCED` before opening a file (3265 slang runs per sweep).
  * No fenced source, database or golden was opened, run or decoded.
  * The census, the mirrors, the away census and the predictor skip fenced paths before opening them.
- Every command ran from the worktree `/tmp/wt_r11u246` (base `08d31c79`), with scratch under `/tmp/r11u246_*`. The
  main checkout was never written. No submodule was initialised in the worktree. No process of another agent was
  listed or signalled.
- Every tool reached through a variable was guarded with `[ -x ]` (in `drivers/env.sh`, `case.sh` and the scratch
  helpers); no database was executed.
- The producer (`$SURELOG`) ran only on this pass's own case files and inside the harness.
- Decode-only scratch cases (SimpleUVM's other faces, the Earlgrey shapes, the BlackBePipeInt reading) stayed in
  `/tmp/r11u246_x`. The Earlgrey sys-argument cases did not converge to a law on this ground and are described above.
- The patch carries no patch file; `/tmp/r11u246.patch` is transport only.

## Drivers (`drivers/`; every one reads `$FENCED` fail-closed, compiled helpers included)

Copied from r11u244repro with the switches, trace names and trace suffix updated: `env.sh`, `case.sh`, `grid.sh`,
`gridsum.py`, `census.sh`, `dscensus.py`, `predict.py`, `bvmirror.sh`, `det.sh`, `awayrows.py`, `strictcmp_x.cpp` +
`cc_x.sh`, and the identity readers `memids.cpp` and `paramids.cpp`.

New in this pass:

* `gridp.sh`: grid.sh's runs, one case per job.
* `awaycases.py`: the chain-keyed away census on grid case-views.
* `dscases.py`: the downstream harness's `one` on every case.
