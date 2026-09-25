# r11u166mac: the preprocessor location model, decoded and scratch-verified

Analyst pass (measurement only). Base `0f607463f` (branch matrix-1.87). Nothing under `src/`, `scripts/`,
`results/`, `tests/` or `third_party/` is edited by this directory; the laws are delivered as patch files for the
pairs to land:

| file | touches | owner | what |
|---|---|---|---|
| `law.patch` | `src/UhdmExporter.cpp` only | pair B | the model and the four axis laws (LINE, COL, FILE, INCL) |
| `law_litall.patch` (on top of `law.patch`) | `src/UhdmExporter.cpp`, `src/EmitHelpers.h`, `src/ExprEmit.cpp`, `src/StmtEmit.cpp` (pair A); `src/ModuleEmit.cpp`, `src/TypeEmit.cpp` (pair B) | both pairs, one landing | § ppBasedLitWsAfter166: the spaced based literal folded by the location model, the emitters' own span compaction retired |
| `law_macroconn.patch` (independent) | `src/ModuleEmit.cpp` | pair B | § macroConnInRange166: the macro-expanded port connection that lost its HighConn (r11u162 N2) |
| `law_on_d48f8f8a8.patch` | `src/UhdmExporter.cpp` | pair B | `law.patch` resolved onto d48f8f8a8, where pass 160 landed during this pass (section 7) |

`uhdm_main.cpp` needed nothing: the builtin `SV_COV_*` macros it predefines are read by the model from slang's
`<api>` define buffers.

The deliverable of the brief's first paragraph (a canonicalisation patch and `tools/probe/r11u166hp/`) contradicts its
TARGET paragraph; this pass follows the TARGET (`tools/probe/r11u166mac/`, `law.patch`, no `src/` edit). No
canonicalisation patch was handed over, and `tools/uhdm-strictcmp` needed no fix.

## 0. Binaries and runs

Worktrees `/tmp/wt_r11u166` (pristine build, then the development tree), `/tmp/r11u166_wtF` (0f607463f +
`law.patch`), `/tmp/r11u166_wtA` (+ `law_litall.patch` + `law_macroconn.patch`); system-deps config, `-j 2`. Every
binary frozen (`chmod 555`, `/tmp/r11u166_bin/`) before it measured anything; every sweep exported `SLANG_UHDM` and
`STRICT_CMP` to the frozen copies.

| binary | md5 | source |
|---|---|---|
| `pris.bin` | `a52c8ec19093858f0da7a4daae5bfbad` | 0f607463f (= the md5 the brief names; the main tree's `build/slang-uhdm` was rebuilt by someone else during the pass, `2ba43a59…`, not used) |
| `lawF5.bin` | `e668f1873c3f24510a3b061033567127` | 0f607463f + `law.patch` |
| `fullF5.bin` | `5ed3e56ed32acce117c25bc26d8edb31` | + `law_litall.patch` + `law_macroconn.patch` (the patch stack reproduces the tree byte for byte: section 5, gate 1) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

Sweeps (`tests/sweep.sh --jobs 3`, all four stages): pristine `/tmp/r11u166_wdP`, law `/tmp/r11u166_wdF`, full
`/tmp/r11u166_wdX` (same-length names). `tests/sweep.sh` exits 1 on every run here, pristine included, for one reason
only: `law index STALE: tests/LAWS.md` — the committed index is stale at 0f607463f itself (the main tree reads the same);
no stage reads a regression.

| sweep | binary | probe EQUAL (of 4087) | surelog CMP_EQUAL d / t (judge-equal 480 / 474) | uhdm2rtlil CMP_EQUAL d / t (judge-equal 803 / 803) | downstream (of 871) | regressions |
|---|---|---|---|---|---|---|
| P `/tmp/r11u166_wdP` | pristine | 2515 | 425 / 423 | 751 / 751 | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 | 0 |
| F `/tmp/r11u166_wdF` | law | **2530** (+15) | **427 / 425** (+2 / +2) | **759 / 759** (+8 / +8) | 803 / 66 / 2 / 0, row by row = P | **0** (every stage) |
| X `/tmp/r11u166_wdX` | law + litall + macroconn | **2535** (+20) | **428 / 426** | **759 / 759** | 803 / 66 / 2 / 0, row by row = P | **0** (every stage) |

Judge status unchanged everywhere (surelog 480/3 + 474/3, uhdm2rtlil 803/1/67 both modes; every probe case EQUAL
under uhdm-cmp). Logs: `evidence/sweep_{pristine,law,full}.log` (the per-row csvs stay in the sweep workdirs; the evidence keeps the logs, the byte-mover lists and the predicted rows).

## 1. Verdict per targeted row

Fresh csv cells, pristine sweep → law sweep (→ full sweep where it differs). "equal" = `CMP_EQUAL,,,equal`.

| row (both modes) | pristine | law | full | what is left |
|---|---|---|---|---|
| ibex_branch_predict | line(12) | **equal** | equal | — |
| ibex_compressed_decoder | line(132) | **equal** | equal | — |
| ibex_csr | line(12) | **equal** | equal | — |
| ibex_decoder | endline(18) | **equal** | equal | — |
| ibex_fetch_fifo | line(24) | **equal** | equal | — |
| ibex_load_store_unit | endline(240) | **equal** | equal | — |
| ibex_multdiv_slow | endline(18) | **equal** | equal | — |
| ibex_wb_stage | line(24) | **equal** | equal | — |
| ibex_icache | line(157) | fullname(49) | fullname(49) | ref_typespec full names of part-select bound constants (pair A) |
| ibex_multdiv_fast | line(86) | endcol(26) | endcol(26) | `$signed({..})` sys_func_call: golden spans the NAME only (158:24-31), ours the call (ExprEmit) |
| ibex_pmp | file(52) | file(16) | file(16) | struct/enum typespec located at its USE in golden (`ibex_pmp.sv 114:47`): the typespec-copy identity residue |
| ibex_register_file_ff | fullname(31) | fullname(31) | fullname(31) | no macro face (bytes unchanged) |
| ibex_tracer | fullname(579) | fullname(579) | fullname(579) | no macro face (bytes unchanged) |
| MacroArgMismatch | endcol(8) | **equal** | equal | — |
| BlackConst (not named; same family: text before a multi-line call) | line(29) / line(19) | **equal** | equal | — |
| YosysMarlann | endcol(24) | endcol(24) | **equal** | the spaced literal: `law_litall.patch` |
| N0064 include_file_info rows | | | | include_file_info records differing, pristine → law (`evidence/include_file_info_rows.txt`): SimpleUVM 121 → **0**, SeqDriver 121 → 0, MiniAmiq 137 → 0, Scoreboard 125 → 0, ApbSlave 4 → 0, Earlgrey_0_1 5 → 0, Scr1SvTests 76 → 0 |
| SimpleUVM | line(183) | fullname(62) | fullname(62) | the hier_path/ref_obj full-name heads (pair A) |
| SeqDriver, MiniAmiq | line(167), line(183) | file(46) | file(46) | uvm_reg typespec located at its use (`uvm_reg_block.svh 1671:35`), identity residue |
| Scoreboard (default) | line(187) | fullname(62) | fullname(62) | as SimpleUVM |
| ApbSlave | line(29) | depth(1) | depth(1) | the pre-existing svunit_pkg walk divergence (#372 in pristine too) |
| Earlgrey_0_1 | line(1730) | endcol(1725) | fullname(564) | the spaced literals (`= 8'h 0;` param_assign ends): litall; then full names |
| Scr1SvTests | line(219) | file(143) | file(143) | typespec_member of an included typedef: golden writes the ROOT file (`scr1_pipe_hdu.sv 76:41`), ours the header (TypeEmit) |
| YosysOldOr | line(75) | line(1) | line(1) | 74 fields toward golden (nested one-line bodies); the last is a non-ANSI port typespec line (ModuleEmit) |
| YosysRiscv | endcol(86) | endcol(86) | col(40) | spaced literals (litall) |
| CovMacro | endcol(118) | fullname(24) | fullname(24) | the builtin `SV_COV_*` expansions now land; `$root.top` hier_path names and golden's `$root` element span (pair A) |
| Rggen (default) | fullname(7) | fullname(7) | fullname(7) | 914 generate-scope spans move to golden (order-blind census); the head is an enum typespec order face |
| r11u162 N2 (`.clk(`CK)`, cases `ds/c05`, `ds/c08`) | stage 1 (31 cmp lines), downstream EQUIVALENT | unchanged | **equal**, downstream **IDENTICAL** | — (`law_macroconn.patch`) |
| r11u162 N1 (`bs . wdtxx [3:0]`, `ds/l06`, `ds/p04`) | stage 1, downstream STATUS_DIFF (slang READ_FAIL) | unchanged | unchanged | not a location face: decoded, section 8 |
| pass 154 macro lvalue paths (`mlv/m1`, `mlv/m2`) | col | col | col | § lvPathBaseAtFirstMember154 cannot find its member token in a macro body (ExprEmit): section 8 |

Every converted row is also byte-attributed: the conversion lines of the three sweeps are in `evidence/sweep_*.log`.

## 2. The decode: where Surelog's locations come from

Surelog parses the text its preprocessor writes. Every location it records is a position in that OUTPUT text; the
line and file are the output line mapped through the preprocessor's line records.

* **The mapping.** `third_party/Surelog/src/SourceCompile/SV3_1aTreeShapeHelper.cpp:169` `getFileLine`: file =
  `getFileId(start output line)`, line and end line = `getLineNb(output line)`, columns = the raw output columns.
  `ParseFile.cpp:168` `buildLineInfoCache_`: for an output line the LAST-inserted `IncludeFileInfo` record that covers
  it wins — a POP covers every line from its own on, a PUSH the lines before its closing POP.
* **A macro call** (`SV3_1aPpTreeShapeListener.cpp:484` `enterMacroInstanceWithArgs`, `:635`
  `enterMacroInstanceNoArgs`): a PUSH at the call's output line mapping it to (definition file, line of the macro name
  in the `define); the expansion text; then a POP → (call's file, call's line + the newlines of the actuals) for a call
  WITH parentheses (always, a one-line body too: push and pop on one output line, the pop wins), and for a call
  without parentheses only when the text holds a newline. An empty body writes the actuals' newlines and pops at the
  call's own line.
* **The expansion text** (`PreprocessFile.cpp:818` `evaluateMacro_`): the body tokens with `` `" `` → `"`; every actual
  TRIMMED (`:870`) and, when it holds a backtick, pre-expanded (`evaluateMacroInstance`, `:784`, a preprocessor with no
  includer: its line records are discarded); formals replaced token-wise (the `` `` `` patterns), a formal-less macro
  called with parentheses gets `"(" + first actual + ")"` appended (`:989`; `` `D (~d) `` → `#1(~d)`, the parentheses'
  blank dropped); `` \ ``+newline → newline; up to two trailing newlines cut and ONE appended when the text still holds a
  newline (`:1010`, `:1022`), so the text after a multi-line call starts a new output line; `` `` `` removed
  (`getMacro`, `:1191`). A text holding a backtick is re-preprocessed as a macro body: nested calls write their own
  PUSH/POP (the POP resyncs to the embedding body's own line: definition line - 1 + line in the body text),
  `` `__FILE__ ``/`` `__LINE__ `` read the top call, an INACTIVE `` `ifdef `` branch drops its text AND its newlines
  (`SV3_1aPpTreeListenerHelper.cpp:181` `addLineFiller` is a no-op in a macro body), a result of only newlines and
  spaces is EMPTY (`getPreProcessedFileContent`, `:1256`), numbers are squeezed (`enterIntegral_number`,
  `SV3_1aPpTreeShapeListener.cpp:145`: every space but a last one dropped).
* **The define** (`third_party/Surelog/grammar/SV3_1aPpParser.g4:475` `escaped_macro_definition_body`): a body that
  continued over lines ends with `CR Spaces*` — the next line's leading blanks are body text (one more output line);
  a body whose last line is blank after a backslash ends with `ESCAPED_CR Spaces* CR` and takes no blanks.
  `:106` `macro_instance`: `` `NAME Spaces* ( `` is a call with actuals whatever the macro's formals.
* **An include** (`SV3_1aPpTreeShapeListener.cpp:264` `enterInclude_directive`, `:387`): Surelog has no include-guard
  skip; a re-inclusion is preprocessed again (the guarded body inactive, its lines left as fillers,
  `enterText_blob` `:1639`) and appended whenever its text is not empty — a license comment outside the guard makes it
  non-empty.
* **The flattened line** of an `include_file_info` is an OUTPUT line: every expansion adds (newlines of its text −
  newlines of its actuals) lines to everything after it.

What golden therefore keeps (the question of the brief): a token of a multi-line expansion reads the definition
FILE and the definition line + its OUTPUT line index (arguments with newlines and dropped `` `ifdef `` lines move it; a
nested call's pop resyncs to the body's own line), at its OUTPUT column; every token on the call's first output line
— the text BEFORE the call included — reads the definition line and file; the text AFTER a multi-line call starts at
column 1 (+ its distance from the call's end) on the call's line; an argument's token reads where its formal's text
landed; the end column counts the output text (squeezed numbers, trimmed actuals, `"(" + actual + ")"`).

The slang side of the same facts (what the model has to work around): a top-level macro usage is a `MacroUsage`
directive trivia on the next token (also a usage that expands to nothing: UVM's `` `uvm_cb_trace_noobj `` →
`/* null */`); slang's offsets inside one expansion buffer are NOT unique after a token paste (a pasted identifier and
the next line's token share an offset: AllPackageSignal, ibex `` fcov_``NAME_ ``); a stringified actual keeps the
actual's leading blanks inside the quotes and its expression range is its value's length.

## 3. The laws (`law.patch`, src/UhdmExporter.cpp; `R11U166_OFF=1` drops them all)

The model (namespace `pp166`): the define table is walked in preprocessing order from the directive trivia
(`<api>` buffers seed the command-line and builtin defines, which write no line records); every top-level usage
(`MacroUsage` trivia, or the first token of an expansion) becomes a REGION whose OUTPUT TEXT is rebuilt with
Surelog's rules above, with its line records; slang's tokens of the region are aligned to that text in tree order
(exact spelling at the cursor, or a little further on the same output line, never across a string; a stringified
actual by its trimmed spelling, or the string at the cursor). A key two tokens claim (the paste offsets) is
ambiguous and left to the pristine arithmetic, except the end of a one-token span, which is its start token's end.
Regions that share a source line form a GROUP with one record list.

| axis | law | switch | rule |
|---|---|---|---|
| LINE | § ppOutputLine166 | `R11U166_LINE_OFF` | the line of a token of a multi-line (or cross-line-actual) expansion, and of any text on the call's first output line, is its output line mapped through the group's records (latest-inserted covering record); every call with parentheses (and a multi-line call without) resyncs the `emptyRedefineObjLine130` drop at its last line |
| COL | § ppOutputCol166 | `R11U166_COL_OFF` | a token's column is its column in the output text: first output line = the call's own output column + its offset, later lines = offset from the line start; text after a multi-line call = 1 + its distance from the call's end, after a one-line call its model length; a formal-less macro's `(…)` reads `"(" + trimmed first actual + ")"` |
| COL | § ppOutputCol166, one-line expansions | `R11U166_ONELINE_OFF` | the same for every paste-free one-line expansion (a stringified actual keeps Surelog's spelling, a nested body's squeezed numbers and trailing blanks count); an expansion with a `` `` `` paste keeps the pristine arithmetic |
| FILE | § ppOutputFile166 | `R11U166_FILE_OFF` | the file of the record that covers the start's output line (text before a multi-line call: the definition file; a nested call's pop: the embedding body's file) |
| INCL | § ppOutputInclLine166 | `R11U166_INCL_OFF` | an `include_file_info` line = the flattened OUTPUT line: + the growth (text newlines − actual newlines) of every expansion before it in its file and in every file spliced before it |
| INCL | § ppReincludeSplice166 | `R11U166_INCL_REINC_OFF` | a re-inclusion slang skipped (guard defined) splices the file's line count when anything but blanks lies outside its guard; a guard-only file splices nothing (the pristine rule) |

`law_litall.patch`: § ppBasedLitWsAfter166 (`R11U166_COL_LIT_OFF`) — the spaces between a based literal's base and its
digits are squeezed by the preprocessor, so every position AFTER them on the line moves left; the emitters' span
compaction (`basedLiteralSpaceCount` at StmtEmit 4 sites, ExprEmit 5, ModuleEmit 3 incl. `setLocCompact`, TypeEmit's
enum-const end shrink) is retired in the same landing (`basedLiteralSpanShrink`/`basedLiteralSitesCompact`,
EmitHelpers.h). Without its site changes the location fold counts twice every span an emitter already compacts
(measured on the one site a first variant missed, TypeEmit's enum constant); a context-guarded fold that left the
sites alone broke `connReplFoldNested54`'s span keys (probe `r10earl54repro/v10step1` read uhdm-cmp NOT_EQUAL). Both
variants measured and rejected (section 6).

`law_macroconn.patch`: § macroConnInRange166 (`R11U166_MACROCONN_OFF`) — ModuleEmit.cpp `emitInstance`, the
default-value-connection test `es9 < ir9.start() || es9 > ir9.end()` compared a macro-expanded connection's location
(its own buffer) with the instance range; the expansion point is compared instead.

## 4. The grid (69 cases, `cases/`; `evidence/grid.txt`)

Scored per case against the pinned Surelog's golden (`drivers/case.sh`: Surelog `-parse -nobuiltin -nocache -sv
dut.sv -mt 0 -mp 0`, ours `dut.sv --single-unit --nobuiltin`, uhdm-cmp line count, strictcmp verdict; the golden is
cached by the md5 of every file of the case, so an edited case never meets a stale golden). Each shape is written in
the module a top instance elaborates, so every case carries the definition view and the elaborated view (`line/l11`
adds a parameterised sub-instance).

| group (shape) | cases | uhdm-cmp NOT_EQUAL at base | strict-equal pristine | strict-equal law | strict-equal full |
|---|---|---|---|---|---|
| `line/` a multi-line body; text before and after a call; an actual with a newline; a one-line body whose call spans lines; nested multi-line calls; an inactive / a taken `` `ifdef `` in a body; two multi-line calls on one line; the define in an include; the call in an include; a sub-instance | 11 | 0 | 4 | **11** | 11 |
| `col/` the column after a multi-line call; a formal-less macro with `(…)` (spaced, as a function); a stringified actual in a nested body; a nested one-line body in a multi-line body; two regions on a line; a pasted token in a multi-line body; nested one-line bodies with trailing blanks and comments (or1200); a stringified spaced actual | 10 | 0 | 2 | **10** | 10 |
| `file/` text before a multi-line call whose define is in an include; a nested call defined in another include; the ibex `ASSERT` / `ASSERT_ERROR` / `PRIM_STRINGIFY` shape | 3 | 0 | 1 | **3** | 3 |
| `incl/` expansion growth before an include: multi-line, `` `ifdef``-dropped lines, actuals over lines, an empty body, a `/* null */` body, a define followed by a blank-space line, a define ending in `\` + empty line, growth inside an included file, a body that expands to blanks, a call without arguments | 10 | 0 | 2 | **10** | 10 |
| `reinc/` a guarded file included twice: header comment + (blank, defines, includes, nested ifdefs, comments, else, a multi-line define) / no header (r06) | 8 | 0 | 1 | **8** | 8 |
| `explore/` the decode seeds (text before/after, the ibex body, nested) | 5 | 0 | 1 | **5** | 5 |
| `lit/` a spaced based literal before a ternary branch, `begin`, `_` digits, a param_assign end, a cast (b05, b10), two literals, a concatenation, a case item, an assertion, a statement over two lines, an immediate assert, a port connection, a space before the tick (b14), a sequence property, an enum constant (the TypeEmit site) | 16 | 2 (b05, b14: the same line counts with every binary) | 2 | 2 | **14** |
| `ds/` r11u162's downstream faces: N2 macro connection (c05, c08), N1 spaced path (l06, p04) | 4 | 4 | 0 | 0 | **2** (N2) |
| `mlv/` pass 154's macro lvalue paths | 2 | 0 | 0 | 0 | 0 |
| **total** | **69** | 6 | 13 | **49** | **63** |

No case's differing-object count grows under either binary; every NOT_EQUAL case keeps its uhdm-cmp line count
except `ds/c05`, `ds/c08` (31 → 0 with `law_macroconn.patch`).

Switches (`drivers/switches.sh`, `evidence/switches_{law,full}.txt`): `R11U166_OFF=1` gives the pristine bytes on
**69/69** cases with both binaries; each moved case lists the switches that move it off the law's bytes (law binary:
36 cases moved; `R11U166_LINE_OFF` 16, `R11U166_COL_OFF` 16, `R11U166_ONELINE_OFF` 2 (c09, c10), `R11U166_FILE_OFF` 2
(f01, l09), `R11U166_INCL_OFF` 15, `R11U166_INCL_REINC_OFF` 7; full binary adds `R11U166_COL_LIT_OFF` on the
literal cases and `R11U166_MACROCONN_OFF` on c05/c08).

## 5. Gates (0f607463f, both deliverable binaries)

1. **Build.** pristine `a52c8ec19093` (= the brief's md5); law `e668f1873c3f`; full `5ed3e56ed32a`; the patch stack
   `law.patch` + `law_litall.patch` + `law_macroconn.patch` on a fresh 0f607463f reproduces the full tree's six
   source files byte for byte (checked with `cmp` after `git apply`).
2. **Probe** (`tests/sweep.sh`, `results/golden_probe.csv`): law EQUAL 2515 → **2530**, regressions 0, conversions
   15, changes 5; full → **2535** (conversions 20: + `r10earl42repro/v42_overfire`, `r10earl43repro/v43_h1_order`,
   `r10earl54repro/v10step1`, `r10earl_repro/a`, `r10earl_repro/mm`, all spaced literals). Law conversions:
   `r10uvm104repro/g104_a5_fence`, `r10uvm60repro/b7_multiline`, `r11u8repro/{b5,b8,gA,gB}`,
   `r11v11u8repro/{v1,v2,v4,v5,v8,v10,v11,v12,v13}`. Changes (both): `r10uvm104repro/g104_a1_sep` endcol(48) → (44),
   `r10uvm160repro/g160_f_witness` line(11) → (2), `r10v104repro/v1_pastecount` endcol(8) → (4),
   `r10v132repro/v4_home` file(50) → (48), `r11v11u8repro/v9` line(6) → col(6) (the 6 line diffs cleared, the col ones
   were there). Every probe case stays EQUAL under uhdm-cmp.
3. **Corpora** (`results/golden_*.csv` of 0f607463f): `regressions=0` in both corpora for both binaries. Law:
   surelog conversions 4 (BlackConst, MacroArgMismatch; both modes), changes 17 (ApbSlave, CovMacro, Earlgrey_0_1,
   MiniAmiq, Scoreboard/d, Scr1SvTests, SeqDriver, SimpleUVM, YosysOldOr; section 1); uhdm2rtlil conversions 16
   (8 ibex tests × 2), changes 6 (ibex_icache, ibex_multdiv_fast, ibex_pmp). Full adds YosysMarlann × 2 (surelog 6)
   and YosysRiscv's change. The LowMem / Earlgrey environment draws did not occur.
4. **Downstream**: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2 (func_upto, matching_end_labels), DIVERGENT 0, `not
   identical and not excused=0` for pristine, law and full; the csvs agree with the pristine run on every one of the
   871 rows (verdict, statuses, gate counts, `differs`); the converted ibex rows read IDENTICAL
   (`ibex_load_store_unit,IDENTICAL,OK,OK,736,736,`).
5. **uhdm-cmp**: every row keeps its judge status (the histograms above); every moved row-mode is judge-equal before
   and after, i.e. 0 uhdm-cmp lines.
6. **Byte movers** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, same-length workdirs):
   * law: surelog **22/960** (ApbSlave, BlackConst, CovMacro, Earlgrey_0_1, MacroArgMismatch, MiniAmiq, Scr1SvTests,
     SeqDriver, SimpleUVM, YosysOldOr — both modes; Rggen/d, Scoreboard/d), uhdm2rtlil **22/1608** (ibex
     branch_predict, compressed_decoder, csr, decoder, fetch_fifo, icache, load_store_unit, multdiv_fast,
     multdiv_slow, pmp, wb_stage — both modes); PATH_SETS_IDENTICAL, selfcheck 959/960 and 1607/1608.
   * full: surelog **26/960** (+ YosysMarlann, YosysRiscv both modes), uhdm2rtlil 22/1608.
   * probe (pristine databases rebuilt from a same-length root: `/tmp/r11u166_wdQ`, `wdR`): law 21 (the 20 changed
     cases + `r10v212repro/gridv_v7_macro_clone_design`, one byte outside the strict walk, strict equal before and
     after), full 26.
   * **PREDICTED by name** from the pristine sweep's sources first (`drivers/predict.py`, fail-closed on `FENCED`;
     triggers ML, AS, FP, RI, PD, NB, LW — docstring): law 44/44 movers predicted (67 rows predicted), full 48/48
     (83 predicted); `evidence/predict_vs_movers_{law,full}.txt`. Honesty note: the first prediction (before the
     one-line rule existed) had no NB trigger and missed YosysOldOr; NB was added from the decoded mechanism (a
     re-preprocessed nested one-line body), LW for the literal.
7. **Per object** (`drivers/objcheck.py`, pairs by walk index): uhdm2rtlil movers **improved 3126 fields, worsened
   0**. The surelog movers' walks diverge from golden (WALK), so they are judged order-blind (`drivers/orderblind.py`,
   `evidence/orderblind_{law,full}_surelog.txt`): every row gains golden records and loses none, except one
   `constant UINT:0` in MiniAmiq/d and SeqDriver/t (the documented UVM `vpiDecompile`/`UINT` order coin): SimpleUVM
   +19958, SeqDriver +28383, MiniAmiq +24558, Scoreboard +15880, ApbSlave +206, Rggen +914, Scr1SvTests +76,
   YosysOldOr +74, CovMacro +94, BlackConst +29/+19, MacroArgMismatch +8, Earlgrey +5 (full: +3416), YosysMarlann +24
   (full), YosysRiscv +46 (full).
8. **The landed laws' cases as byte controls** (`drivers/controls.sh` over r11u125repro, r11v125repro, r11u130repro,
   r11v130repro, r11u141verify, r11u146repro, r11u118repro, r11v11u118repro, r11u119repro — 777 cases): law 767
   byte-identical, **10 move, all to strict-equal** (pass 125's R4 cells g3 m05 m10 m13 m14 m15, r11v125's
   w04 w05 w11, pass 130's R6 g9 r07, r11v130's adv h09); full 764 identical, 13 move (+ `r11u141verify` p130_wildspan
   w01_macro_conn NOT_EQUAL → strict-equal by macroconn, and r11u119's n_dir_lits / n_nodir_lits, NOT_EQUAL at base
   with the same 36 cmp lines). `evidence/controls_{lawF5,fullF5}.txt`.
9. **Canaries** (against 0f607463f's csvs): `r11u107repro/canaries.sh` surelog ok=39 changed=13 (exactly the
   improved rows of section 1), uhdm2rtlil ok=16 changed=0; `ctcan2.sh` uhdm2rtlil `EXPECT_UNKNOWN=6` PASS;
   surelog `EXPECT_UNKNOWN=1` reads "FAIL: a supplementary canary moved" on BlackConst STRICT_NOTEQUAL → CMP_EQUAL (the
   conversion) and nothing else. (Run against the main tree's csvs instead they read SimpleConstraint / SVSwitch /
   MultirangesStartNotFromZero "changed": that tree had moved to d48f8f8a8 — pass 158 and pass 160 landed during this
   pass — whose baselines differ from 0f607463f's; my pristine sweep reads those rows exactly as 0f607463f's csvs.)

## 6. The downstream check on the cases (`drivers/dsgrid.sh`, `evidence/downstream_grid.txt`)

The downstream harness (`scripts/downstream_uhdm2rtlil.py` `one`, the probe arguments; a FRESH golden cache,
`GOLDEN_CACHE=/tmp/r11u166_gc_ds`: the harness keys on directory + arguments and five cases were edited) on all 69
cases, pristine / law / full:

| pristine → law → full | cases |
|---|---|
| IDENTICAL → IDENTICAL → IDENTICAL | 50 |
| EQUIVALENT → **IDENTICAL** (law) | 9: col c02 c03 c04 c08 c09, explore e05, file f03 (the ibex shape), line l03 l04 |
| EQUIVALENT → EQUIVALENT → **IDENTICAL** (full) | 8: ds c05 c08 (N2), lit b01 b03 b06 b08 b12 b14 |
| STATUS_DIFF → STATUS_DIFF → STATUS_DIFF | 2: ds l06, p04 (N1; Surelog lane NO_GATES, slang lane READ_FAIL) |

No case moves away from IDENTICAL. The two r11u162 faces, taken first as the brief asks: **N2 turns IDENTICAL** with
`law_macroconn.patch` (c05, c08: EQUIVALENT `nohier il synth` → IDENTICAL, the child's `\clk` connected); N1 is not
a location face (section 8).

The rejected literal variants (section 3): (a) a context-guarded fold (a span end whose span starts at or before the
literal on its line is left to the emitter) moved `r10earl54repro/v10step1` to uhdm-cmp NOT_EQUAL:
§ connReplFoldNested54 compares spans computed by `locLineCol` (no context) with the spans `setLoc` wrote; (b) the
fold with the sites retired but TypeEmit's enum-constant end shrink left in read Kmac, PackStructVar and UndersVal
as regressions (the enum constant compacted twice); `law_litall.patch` retires that site too (`lit/b16`).

## 7. The base moved during this pass: pass 158 and pass 160 landed (d48f8f8a8)

Pair B's r11u160 landed § ppMacroBodyLines160 / § objMacroParenArgsTrimmed160 (a macro-body line and column model
built on the pristine delta arithmetic) while this pass ran. At d48f8f8a8 it already converts the seven ibex tests,
BlackConst and MacroArgMismatch that `law.patch` converts at 0f607463f. `law.patch` does not apply there (two
hunks conflict in `src/UhdmExporter.cpp`: the `pp166` block next to pass 160's model state, and the tail of
`locLineCol`); `law_on_d48f8f8a8.patch` is the resolution (both sides kept: pass 160's arithmetic becomes the
fallback the model overrides), measured with two more full sweeps (`/tmp/r11u166_wdH` = d48f8f8a8 as built,
md5 `76f6b803…`, = the main tree's binary; `/tmp/r11u166_wdJ` = + the resolved law, md5 `fb095dfa…`):

| stage | d48f8f8a8 | + law | |
|---|---|---|---|
| probe EQUAL | 2547 | **2561** | +14 (`r10uvm60repro/b7_multiline`, `r11u8repro/{b5,b8,gA,gB}`, `r11v11u8repro/{v1,v2,v4,v5,v8,v10,v11,v12,v13}`), 5 changes (fewer objects), 0 regressions |
| surelog CMP_EQUAL d / t | 432 / 429 | 432 / 429 | 0 conversions, 17 changes (ApbSlave, CovMacro → fullname(8), Earlgrey, MiniAmiq, Scoreboard, Scr1SvTests, SeqDriver, SimpleUVM, YosysOldOr: the include_file_info records and the nested one-line bodies), 0 regressions |
| uhdm2rtlil CMP_EQUAL d / t | 766 / 766 | **767 / 767** | ibex_load_store_unit × 2 (endline(142) → equal), ibex_pmp file(52) → file(16), 0 regressions |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0 | row by row identical |

Byte movers: surelog 18/960, uhdm2rtlil 4/1608 (`evidence/byteverify_head_*.txt`), a subset of the 0f607463f
movers. `law_litall.patch` and `law_macroconn.patch` apply cleanly on top of it (not swept there).

## 8. Residues, ranked, and the faces decoded but not written

1. **The spaced based literal** (§ ppBasedLitWsAfter166, `law_litall.patch`): YosysMarlann × 2 convert, YosysRiscv,
   Earlgrey (+3416 records) move, 5 probe cases convert, 0 regressions — but it touches both pairs' files (the
   literal's own span, casts, tagged patterns, assertion instances in ExprEmit; the assertion statements and property
   specs in StmtEmit; the assertion items and `setLocCompact` in ModuleEmit; the enum constant in TypeEmit) and must
   land as ONE change. Scratch-verified here with the full sweep.
2. **N2, a macro-expanded interface-member connection** (r11u162): ModuleEmit.cpp `emitInstance`, the default-value
   test `es9 < ir9.start() || es9 > ir9.end()` (0f607463f ModuleEmit.cpp:16380) compares locations of two buffers; gdb on a
   `-g1` build of the pristine source pins it: the macro connection never reaches the HighConn write the plain
   connection reaches (ModuleEmit.cpp:18013, `evidence/n2_highconn_sites_{macro,plain}.txt`,
   `drivers/gdb_highconn.cmd`). `law_macroconn.patch` compares the expansion point: cases c05, c08 strict-equal and
   downstream IDENTICAL; `r11u141verify/.../w01_macro_conn` NOT_EQUAL → strict-equal; no corpus row moves.
3. **N1, blanks inside a dotted path** (`bs . wdtxx [3:0] <= x`, `v[sub . W : 0]`): NOT a location face. The names come
   from splitting the RAW text of the path (`dotted = rawText(expr.sourceRange)`, ExprEmit.cpp:34209 / 34221 / 37746
   into `buildDottedHierPath` :8386, split loop :8452; the lvalue-path builders under § lvPathBaseAtFirstMember154
   :31495 / :32610 / :33634 and the bound path under § psBoundPathFirstMember154 :37343 split their own text). Rule:
   a path element's name is its identifier token (no blanks), located at its own token (`wdtxx` 4:33, ours 4:32).
   A scratch fix of `buildDottedHierPath` alone (element names trimmed, offsets moved past the blanks) fixed the
   rvalue hier_path names but not the lvalue and bound builders; both cases stay stage 1 and downstream STATUS_DIFF
   (Surelog's own lane reads NO_GATES there, so even a full fix meets STATUS_DIFF unless our lane also yields no
   gates). Pair A.
4. **pass 154's macro-argument lvalue paths** (`mlv/m1`, `m2`, from r11u154repro lv): golden anchors the path base at
   the MEMBER token (`read_data`, 3:24-33 after `RIF` → `bit_field_if`); ours at the base token. The model maps the
   member token correctly; § lvPathBaseAtFirstMember154's own member-token lookup reads the path's text and finds no
   member offset inside a macro body (ExprEmit.cpp :31495 family). Pair A.
5. **The typespec located at its use** (ibex_pmp file(16), SeqDriver / MiniAmiq file(46), Scr1SvTests file(143)):
   golden copies a package typedef's typespec per use and locates it (and its members) at the use in the ROOT file
   (`uvm_reg_block.svh 1671:35`, `scr1_pipe_hdu.sv 76:41`); ours shares the declaration's object. The identity
   residue (GOLDEN_EQUIVALENCE), TypeEmit.
6. **Not macro faces, uncovered by this pass**: ibex_multdiv_fast `$signed` sys_func_call span (golden the name only),
   ibex_icache ref_typespec full names, CovMacro `$root.top` (hier_path name and golden's `$root` element span at the
   `top` token), SimpleUVM / Scoreboard full names, ApbSlave's svunit walk divergence, YosysOldOr's non-ANSI port
   typespec line (`opb_dn` 51:12 vs ours 50:12), Rggen's enum typespec order.
7. **Model limits** (the shapes golden decides by something not modelled, all falling back to the pristine
   arithmetic): an expansion with a `` `` `` paste keeps the pristine one-line arithmetic (the rebuilt text is not
   Surelog's for `` `"`Q``-```R`" `` shapes, r10uvm104 a6; with the model on for them: 1 probe regression, 2 cases
   worse); a key two tokens claim after a paste is ambiguous (only a one-token span's end is recovered); a `define`
   INSIDE a macro body, `` `line ``/`` `pragma `` in bodies, and the arg pre-expansion's own line records are not
   modelled; an `` `ifdef `` inside a body is evaluated against the table at the top-level call (Surelog evaluates it
   when the body is re-preprocessed, which is the same point). Surelog defects reproduced ON PURPOSE: the formal-less
   call's appended `"(" + first actual + ")"` drops every other actual; a re-included guarded file splices all its
   lines.

R0 (next): `law_litall.patch` as one landing of both pairs; then N1's text-splitting builders (pair A).

## 9. Files

* `law.patch`, `law_litall.patch`, `law_macroconn.patch` — the laws (git diffs vs 0f607463f; the second applies on top
  of the first, the third on either); `law_on_d48f8f8a8.patch` — the law resolved onto d48f8f8a8.
* `cases/` — 69 cases (`line/`, `col/`, `file/`, `incl/`, `reinc/`, `lit/`, `explore/`, `ds/` the r11u162 faces,
  `mlv/` pass 154's macro lvalue paths); every case names its law in its first line. Trailing blanks ARE the case in
  `incl/i06` (the blank-space line after a define), `col/c09` and `line/`/`explore/` bodies: apply the patch without
  `--whitespace=fix` (git reports them as whitespace errors).
* `drivers/` — `case.sh` (one case: golden, ours, uhdm-cmp, strictcmp dumps), `grid.sh`, `switches.sh`, `dsgrid.sh`
  (the downstream harness per case), `controls.sh` (the landed laws' cases as byte controls), `family.sh`,
  `rowheads.sh` (a row's differing records with their parent chains), `incinfo.sh` (include_file_info lines side by
  side), `objcheck.py` (per-object improved/worsened), `orderblind.py` (order-blind record census for rows whose walk
  diverges), `predict.py` + `predcmp.sh` (the mover predictor and its check). Every driver that reads corpus sources
  or databases refuses to run without `FENCED` and skips a fenced test by word boundary.
* `evidence/` — every measurement quoted here.
