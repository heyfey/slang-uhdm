# r11u8 — § macroQuoteContLeak11: the stringify continuation-whitespace law

Base commit `0076cdd9`, worktree `/tmp/wt_r11u8`. Pristine binary md5
`d9f02d33ac97b1570209e2e4b1862ab7` — byte-identical to the main tree at the
base. Law binary md5 `ed82305a891da199c68f521ea94f752b`. Judge is the official
`uhdm-cmp` through `scripts/verify_golden.py`; everything in this directory is
measurement-only. `results/*.csv` ARE NOT EDITED BY THIS PASS.

**THREE uhdm2rtlil tests CONVERT in BOTH modes** (§7). Six more advance off
this head onto the next one. The `b5` fence stays CMP_EQUAL.

## 1. The head, re-measured on my own pristine sweep

`u2r` pristine reproduces the base exactly: 743 CMP_EQUAL / 61 CMP_NOTEQUAL /
67 SLANG_REJECT in BOTH modes, and the two not-equal name sets are identical.
Thirteen ibex rows are not-equal (`ibex_counter` converted under r11v11u5).
Every row wears exactly ONE head (`grep -c '^LHS:'` on **stderr** — `uhdm-cmp`
prints the head there, and a stdout-only counter reads 0 for every row).

The stringify head is **NINE** rows, not eleven, in both modes
(`HEADS.pristine.{testflags,default}.txt` — the two mode tables name the same
nine):

| row | golden | ours | leak |
|---|---|---|---|
| ibex_branch_predict | `BranchInsTypeOneHot` (152) | `         BranchInsTypeOneHot` (224) | 9 sp |
| ibex_compressed_decoder | `IbexInstrValidKnown` (152) | + 9 sp (224) | 9 sp |
| ibex_csr | `IbexCSREnValid` (112) | + 9 sp (184) | 9 sp |
| ibex_decoder | `IbexRegImmAluOpKnown` (160) | + 9 sp (232) | 9 sp |
| ibex_fetch_fifo | `IbexFetchFifoPushPopFull` (192) | + 9 sp (264) | 9 sp |
| ibex_load_store_unit | `IbexDataTypeKnown` (136) | + 9 sp (208) | 9 sp |
| ibex_multdiv_fast | `DivEnKnown` (80) | + 9 sp (152) | 9 sp |
| ibex_multdiv_slow | `IbexMultDivStateValid` (168) | + 9 sp (240) | 9 sp |
| ibex_wb_stage | `RFWriteFromOneSourceOnly` (192) | + 9 sp (264) | 9 sp |

All nine are the `$error` argument at `prim_assert.sv:33:10` (34:10 in one
vendored copy), 18 cmp lines each = that one constant and nothing else.

The four ibex rows that are NOT on this head, measured rather than assumed:
`ibex_alu` (operation @ ibex_pkg.sv 750:52), `ibex_icache` (INT-vs-UINT
param constant @ 17:44), `ibex_pmp` (range constant vpiSize 32 vs 64 @ 34:10),
`ibex_tracer` (`ref_obj ibex_tracer_pkg::OPCODE_C0` @ 305:87). They still
CARRY leaked constants behind their heads (§6) — they move, they do not
convert.

Witnesses on the pristine binary: `b1` 18 cmp lines / 1 head, `b8` 18 / 1,
**`b5` cmp rc 0, zero lines** — the counterexample is equal before the law and
must stay equal after it.

## 2. DECODE — both producers, read from source

**Golden (Surelog v1.87).** Measured off the grid, not inferred: Surelog's
stringification is *the macro body's own source characters between the
`` `" `` markers*, with formals replaced by the TRIMMED actual argument text
and nested macro references expanded.

* a line continuation before the stringification contributes NOTHING —
  `` `"__x`" `` renders `N9` whether the call is on the body's first line or
  after nine spaces and a backslash (`gA`, arms A0/A1/A3/A9/A2C/ATAB);
* whitespace WRITTEN between the markers is kept exactly —
  `` `define LIT `"  hello  `" `` renders `  hello  ` (`gB` B0L);
* an actual argument's own surrounding whitespace is STRIPPED —
  `` `STR(  spaced  ) `` renders `spaced` (`gB` B0A/B0B);
* a nested macro inside the stringification is expanded in place —
  `` `"pre `INNER post`" `` renders `pre thing post` (`gC` C0N);
* a continuation INSIDE the stringification keeps its RAW characters,
  backslash and newline included (`gC` C0MID: `zz   \`⏎`   tail`, vpiSize 112)
  — which is the same "body source text" rule, and is the one shape we do not
  reproduce (§8, R1).

**Ours (slang upstream `7d61e0ad1`) — where the leak is born.** A
`LineContinuation` is a TOKEN in a macro body, not trivia.
`Preprocessor::MacroExpansion::append`
(`source/parsing/Preprocessor_macros.cpp:727-737`) rewrites it into an
`EmptyMacroArgument` whose trivia is `[Whitespace before the backslash] +
[EndOfLine for the rest]`. `MacroOpEvaluator::append`
(`Preprocessor_macros.cpp:236-246`) parks an `EmptyMacroArgument`'s trivia in
`emptyArgTrivia` and prepends it to the next token it appends — **but the
opening `` `" `` is routed to `handleStringifyOp` directly from `apply`'s
switch and never passes through `append`**, so the parked trivia sails past
the marker and lands on the first token INSIDE the stringification.
`Lexer::stringify`'s `addTrivia` (`source/parsing/Lexer.cpp:122-129`) then
emits every Whitespace trivium of every body token, and out comes the leak.

That model predicts, and the grid confirms, both halves of the b8
discriminator: the pre-backslash whitespace leaks (one space before the `\`
leaks exactly one space), and the continuation LINE's indent does not — the
indent is the `` `" `` marker's own trivia, and the marker is `startToken`,
whose trivia `Lexer::stringify` never adds. A TAB before the backslash leaks a
tab (`gA` ATAB). Only the LAST continuation before the call leaks: an
intervening token absorbs the earlier ones (`gA` A2C, two continuations, one
space leaked).

Patching slang is out of scope, so the exporter gates on provenance.

## 3. THE GOLDEN GRID (`GRID.pristine.txt` / `GRID.law.txt`)

Every arm compiled `--nobuiltin` on both sides, every rc recorded; all arms
`surelog_rc=0 ours_rc=0`.

| arm | shape | golden | pristine | law |
|---|---|---|---|---|
| gA A0 | no continuation | `N0` | `N0` | `N0` |
| gA A1 | 1 sp before `\`, 4-sp indent | `N1` | `· N1` | `N1` |
| gA A3 | 3 sp before `\`, 0 indent | `N3` | `···N3` | `N3` |
| gA A9 | 9 sp before `\`, 9-sp indent | `N9` | `·········N9` | `N9` |
| gA A2C | two continuations, token between | `N2C` | `· N2C` | `N2C` |
| gA ATAB | TAB before `\` | `NTAB` | `⇥NTAB` | `NTAB` |
| gB B0L | intentional `` `"  hello  `" `` | `  hello  ` | `  hello  ` | `  hello  ` |
| gB B0A | `` `STR(  spaced  ) `` | `spaced` | `spaced` | `spaced` |
| gB B0B | `` `BRK(  spaced  ) `` | `[spaced]` | `[spaced]` | `[spaced]` |
| gB B1L | **intentional + leak** | `  [NL]  ` | `   [NL]  ` | `  [NL]  ` |
| gB B1B | leak, `` `"[__x]`" `` | `[NB]` | `· [NB]` | `[NB]` |
| gB B1S | leak over an arg-less `` `LIT `` | `  hello  ` | `   hello  ` | `  hello  ` |
| gC C0M/C1M | multi-token `` `"__a __b`" `` | `aa bb` / `pp qq` | `pp qq` leaked | clean |
| gC C0N/C1N | nested macro in stringify | `pre thing post` | leaked | clean |
| gC C0MID | continuation INSIDE stringify | `zz   \`⏎`   tail` | `zz      tail` | `zz      tail` |
| gD | param view + `$error` view | `ParamName`/`ErrName` | leaked | `ErrName` clean, param residue (§8 R2) |

Whole-arm verdicts, pristine → law: **b1 18→0, b8 18→0, gA 18→0, gB 18→0
(cmp rc 0 on all four — CONVERTED), b5 0→0 (the fence holds), gC 20→20 and gD
32→32 (heads unchanged, both pre-existing and unrelated).**

`B1L` is the arm that kills an unconditional trim: golden keeps two of the
three leading spaces, so "strip leading whitespace" is a regression and only a
bounded, provenance-keyed trim is correct.

## 4. THE LAW — § macroQuoteContLeak11

`src/ExprEmit.cpp`, a new `UhdmExporter::macroQuoteContLeak` called from the
`macroQuoted9` branch of `ExpressionKind::StringLiteral`, immediately BEFORE
§ macroPasteDotText104. Declaration and the full decoded model live in
`include/UhdmExporter.h`.

> The synthesized literal is stamped with the OPENING marker's location
> (`Lexer::stringify` returns `token.clone(..., startToken.location())`), so
> `getFullyOriginalLoc` lands on the `` `" `` in the macro body. The
> whitespace that body writes RIGHT AFTER the marker is the amount the value
> is entitled to keep; only the excess is trimmed.

Gate, in order: our value must start with whitespace; the location must be a
macro loc; its fully-original location must be a real (non-macro) buffer
position; the two characters there must be `` `" ``; a `` `""" `` triple quote
is fenced out (it keeps EndOfLine trivia too, a different rule). Anything that
fails is left byte-identical.

**Why it runs BEFORE the paste collapse, measured not asserted.** The
committed arm `r10v104repro/v14_crossmacro.sv` proves it: its `` `MLNOARG ``
stringification is golden `c.d` (Surelog's `` `` ``→`.` regex), pristine
`· c-d` — the leaked space was misaligning § macroPasteDotText104's
left/right walk, so that rule BAILED. Trim first and the alignment succeeds:
the law binary renders `c.d`, byte-exact with golden. Running the trim after
the collapse would have left that arm wrong.

The trim shortens the value, so `vpiSize` and the synthesized end column
(`inner.size() + 2`) follow with no separate rule — which is why the ibex
constants land on golden's SPAN as well as golden's text (pristine
`endln:23:17`, an end BEFORE its start; law and golden both `33:26`-class).

## 5. A-PRIORI MOVER PREDICTION, WITH ITS POSITIVE CONTROL (`PREDICT.txt`)

Predicted from the PRISTINE databases before the patched sweep ran.
`leadscan8.sh` lists every database holding a string constant whose value
begins with whitespace — the law can only SHORTEN such a value, so a database
absent from that list cannot move. Flagged: **26 of 1608** u2r databases and
**35 of 960** surelog databases.

Narrowed by source provenance (the gate needs a `` `" `` marker at the
literal's original location):

* **u2r — 10 tests × 2 modes = 20 databases.** `ibex_branch_predict`,
  `ibex_compressed_decoder`, `ibex_csr`, `ibex_decoder`, `ibex_fetch_fifo`,
  `ibex_icache`, `ibex_load_store_unit`, `ibex_multdiv_fast`,
  `ibex_multdiv_slow`, `ibex_wb_stage`. Excluded with a reason, not by hope:
  `ibex_tracer`'s seven leading-space strings are plain source literals
  (`ibex_tracer.sv:127,149,159` — `$fwrite(fh, " %s:0x%08x", …)`);
  `asgn_expr_sv` and `StringWithBackslash` contain no `` `" `` at all.
  **Measured: exactly those 20.**
* **surelog — 0 databases.** The only flagged rows whose compiled closure
  contains a `` `" `` are the five UVM ones (uvm-1.2 carries 176 of them), and
  for every one of those the leading-whitespace string MULTISET is already
  IDENTICAL between golden and ours on the pristine binary (BuildUVMPkg 117
  distinct / 0 diffs, MiniAmiq 122/0, Scoreboard 122/0, SeqDriver 123/0,
  SimpleUVM 122/0) — so nothing there leaks and nothing there can be trimmed.
  `SVSwitch`'s 41 leading-space strings are `$display(" %0d : …")` literals and
  its whole filelist closure has zero `` `" ``. **Measured: 0 law-attributable
  movers** (§6).
* Positive control for that zero: the same scanner on the same corpora named a
  NONZERO u2r set that the comparator then found exactly; and the static
  shape scanner `leakshape8.sh` returns 23 hits on ibex `prim_assert.sv` and 0
  on SVSwitch / the Yosys rows / the OneNet family, so it is not blind.

## 6. GATES — all green

* **builds** `-j 2`, md5 taken separately: pristine
  `d9f02d33ac97b1570209e2e4b1862ab7` (byte-identical to the main tree at
  `0076cdd9`), law `ed82305a891da199c68f521ea94f752b`. Both frozen `chmod 555`
  at `/tmp/r11u8_{pristine,law}.bin` BEFORE any sweep.
* **goldens** on both binaries: **23 PASS / 0 FAIL**; negative control
  `SLANG_UHDM=/bin/false`: **23 FAIL / 0 PASS** on both.
* **every sweep exported `SLANG_UHDM` explicitly** and every `cmds.txt` was
  audited BY BINARY PATH: u2r 1742/1742 name the pass's own frozen binary;
  surelog 1531/1581 name it and the other 50 have **zero** `slang:` lines
  (SURELOG_FAIL / NO_DATABASE rows where slang never ran). Zero `cmds.txt` on
  either corpus names any other binary.
* **u2r, BOTH mode columns scored** (`ct8rows` against
  `results/golden_uhdm2rtlil.csv` split per mode, against
  `results/gate_uhdm2rtlil.csv`, and against this pass's own pristine sweep):
  **743 → 746 CMP_EQUAL, 61 → 58 CMP_NOTEQUAL, 67 SLANG_REJECT unchanged, in
  BOTH modes.** Exactly the three rows of §7 differ and nothing else; the
  dump-column `match` count is unchanged (531 testflags / 527 default) — no
  `match` → `differ` demotion.
* **surelog, both modes: every row identical to the pristine baseline**
  (465/18 default, 461/16 testflags). `ct8rows` reports two differing rows and
  both are the WORKDIR PATH embedded in a `SURELOG_FAIL` log message
  (`LowMemLib`, `LowMemPkg`) — not a slang-side change; they differ from the
  committed CSV the same way, because that CSV was produced under a different
  workdir.
* **byteverify `SELFCHECK=1` against this pass's own pristine workdirs:**
  u2r **MOVERS 20 / 1608**, every one predicted BY NAME in §5; surelog
  **MOVERS 6 / 960**, all of them the proven UVM coin (§6a). Positive controls:
  SELFCHECK flags 1607/1608 and 959/960, so the comparator can see.
* **canaries** `canaries.sh` sl **ok=52 changed=0**, u2r **ok=8 changed=0**;
  `EXPECT_UNKNOWN=1 ctcan2.sh` sl PASS, `EXPECT_UNKNOWN=6` u2r PASS;
  `canaudit.sh canaries.sh ctcan2.sh` → **audited=29 UNCOVERED=0
  FENCE-BREACH=0**.
* **protected databases by md5**, law vs this pass's pristine, both modes:
  `SVSwitch 4842211c4030` (the hard byte pin, held), `YosysVerx 6ccda350c24a`
  (held), `InterfaceModPort 59a365f3ce2c` SAME, `BlackParrotComplex` SAME,
  `YosysOldOr` SAME.
* **rowheads** on SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg /
  Earlgrey_0_1 / Rggen: cmp-line counts and head counts IDENTICAL between
  pristine and law (SKIP-NOFILE on Scoreboard/tf and Rggen/tf as expected).
* **wide boundary** (`bound221.sh` over the WHOLE probe tree, subdirectories
  included): **LISTED=5744 PROCESSED=5744 RC_DIFFS=0 MOVED_ARMS=18** —
  `BOUNDARY.txt`, attributed in §6b.
* **`results/*.csv` NOT edited.** No fenced test was dispatched.

### 6a. The six surelog byte movers are the coin, proven three ways

`MiniAmiq`, `Scoreboard`, `SeqDriver`, `SimpleUVM` (default; MiniAmiq and
SeqDriver also testflags).

1. **Order-blind attribution** (`attrib8.sh`, dumps path-normalised and
   sorted): Scoreboard **0** changed lines, the other five **4** each —
   exactly the documented 0-or-4-line signature. AWAY-GOLDEN **0** in all six.
   Every changed line is a `` `__LINE__ `` integer: `UINT:592`→`UINT:1344`,
   `UINT:627`→`UINT:0`, `UINT:885`→`UINT:886`, plus each one's
   `vpiDecompile`. No `STRING:`, no `vpiSize`, no string constant.
2. **NULL SWEEP on a FIXED binary** (`nullsweep8.sh`): re-running the
   *pristine* binary on those rows, with the harness's own argv and cwd, moves
   `MiniAmiq`, `SeqDriver` and `SimpleUVM` again — the same `` `__LINE__ ``
   class (MiniAmiq `UINT:592`→`UINT:0` on a run where the law binary had given
   `1344`: three values, one binary difference).
3. **Field identity**: the STRING / quoted-vpiDecompile / vpiSize multisets are
   BYTE-IDENTICAL between the law and pristine databases in all six rows
   (0 diffs). The law wrote nothing in them.

### 6b. The 18 moved boundary arms, named

Nine files × two views. Seven are this pass's own arms (`r11u8repro/`
b1, b8, gA, gB, gC, gD) — `b5` did NOT move, which is the fence's second face.
Two are r11v11u5's `b1`/`b8`, the same witnesses, which CONVERT.

The one EARLIER-PASS arm is `r10v104repro/v14_crossmacro.sv`, and it moves
TOWARD golden: its two leaked stringifications become byte-exact with golden
(`· a-b`→`a-b`, `· c-d`→`c.d`), its pristine head — the leaked constant at
9:7 — CLEARS, and the arm advances to a pre-existing unrelated head
(`string arr[3]` emitted as `logic_var` where golden has `string_var`). Its
cmp-line count grows 14 → 26 because the head OBJECT changed; that is the new
head's decompile size, not a regression.

### 6c. Per-mover attribution on u2r: 0 AWAY-GOLDEN

`attrib8.sh` over all 20 movers: **504 order-blind changed lines, every single
one a field of a string constant** — 56+8 `\_constant:` span lines, 56+8
`STRING:`, 56+8 `vpiDecompile:`, 56+8 `vpiSize:` — i.e. 64 constants, which is
the 32 leaked strings per mode counted from the pristine databases, times two
modes. Nothing else of any kind moved. Per database: **AWAY-GOLDEN 0** in all
twenty; TO-GOLDEN equals three times that database's leaked-string count
(branch_predict 3, compressed_decoder 24, csr 3, decoder 3, fetch_fifo 6,
icache 15, load_store_unit 21, multdiv_fast 15, multdiv_slow 3, wb_stage 3).
The residual `\_constant:` span line is not read by any generated `Compare`
(VpiFile/line/col are never compared) — proven by the three rows converting.

## 7. THE CONVERSIONS — said LOUDLY, quoted, NOT written into `results/*.csv`

```
- ibex_csr,default,CMP_NOTEQUAL,decompile:,,
- ibex_csr,testflags,CMP_NOTEQUAL,decompile:,,
- ibex_fetch_fifo,default,CMP_NOTEQUAL,decompile:,,
- ibex_fetch_fifo,testflags,CMP_NOTEQUAL,decompile:,,
- ibex_load_store_unit,default,CMP_NOTEQUAL,decompile:,,
- ibex_load_store_unit,testflags,CMP_NOTEQUAL,decompile:,,
+ ibex_csr,default,CMP_EQUAL,,,differ
+ ibex_csr,testflags,CMP_EQUAL,,,differ
+ ibex_fetch_fifo,default,CMP_EQUAL,,,differ
+ ibex_fetch_fifo,testflags,CMP_EQUAL,,,differ
+ ibex_load_store_unit,default,CMP_EQUAL,,,differ
+ ibex_load_store_unit,testflags,CMP_EQUAL,,,differ
```

**THREE uhdm2rtlil tests CONVERT, in BOTH modes.** The integrator promotes
those six rows in `results/golden_uhdm2rtlil.csv` and the three testflags ones
in `results/gate_uhdm2rtlil.csv`. This pass did not edit them.

Six more rows CLEAR this head and advance to the next one — `ibex_branch_predict`,
`ibex_compressed_decoder`, `ibex_decoder`, `ibex_multdiv_fast`,
`ibex_multdiv_slow`, `ibex_wb_stage` all now wear `ibex_alu`'s head
(`operation` @ `ibex_pkg.sv:750:52`), a SHARED object across seven rows. Their
cmp-line count goes 18 → 2267 because the head object changed; the leaked
constant is gone from every one of them (`grep -c 'STRING:         '` on each
cmp output: 0, against 1 on the pristine side).

## 8. RESIDUES, ranked — START HERE

* **R0 — the shared `operation` head at `ibex_pkg.sv:750:52`. SEVEN rows.**
  `ibex_alu`, `ibex_branch_predict`, `ibex_compressed_decoder`, `ibex_decoder`,
  `ibex_multdiv_fast`, `ibex_multdiv_slow`, `ibex_wb_stage` now share ONE head
  object, 2267 cmp lines each. This is the widest single remaining law in the
  ibex family and it is what this pass hands the next one.
* **R1 — a line continuation INSIDE a stringification.** Golden keeps the RAW
  body characters, backslash and newline included (`gC` C0MID: golden
  `zz   \`⏎`   tail` vpiSize 112; ours `zz      tail` vpiSize 96 — slang
  collapses the continuation to a space and drops the backslash). Not
  reachable by a leading trim; needs the body-text re-derivation of law shape
  (a). No corpus row has the shape (the census found it in no source), which
  is why it was fenced rather than modelled.
* **R2 — the `parameter` object's own `VpiValue` does not take the trim.**
  `gD`: the `param_assign` Rhs constant is fixed, but the `parameter` object's
  value still reads `· ParamName`; that value is written from slang's
  `ConstantValue` in `ParamEmit.cpp`, not through the `StringLiteral` case.
  `gD`'s head is a different, pre-existing DEF-listing parameter-ORDER
  mismatch (golden lists `P1` first, we list `P0`), so the residue is not the
  head. No corpus row reaches it — every corpus stringify is in a statement
  context.
* **R3 (fenced, not reached) — a stringification whose body opens with a
  nested macro reference.** `` `"`X  y`" `` would give `srcLead = 0` while the
  expansion legitimately starts with whitespace, so the trim would over-trim.
  Census: no such shape in either corpus (the surelog UVM closure was checked
  golden-vs-ours field-by-field and agrees everywhere, §5). Recorded so a
  future source with that shape is not a surprise.
* **The slang-side fix**, for whenever slang is in scope:
  `MacroOpEvaluator::handleStringifyOp` should flush or discard the pending
  `emptyArgTrivia` when it opens a stringification, instead of letting it ride
  past the marker onto the first body token.

## 9. Files

* `b1/dut.sv` `b5/dut.sv` `b8/dut.sv` — r11v11u5's witness, counterexample and
  discriminator, re-measured here (pristine 18 / 0 / 18 cmp lines; law 0/0/0).
* `gA/dut.sv` — continuation counts: none, 1, 3, 9 spaces, two continuations, a TAB.
* `gB/dut.sv` — the fence: intentional leading/trailing spaces, argument
  whitespace, and both together with a leak.
* `gC/dut.sv` — multi-token, nested-macro and mid-stringification continuations.
* `gD/dut.sv` — views: a parameter declaration and a `$error` argument.
* `grid8.sh <binary> [arm…]` — runs Surelog and the given binary on each arm,
  prints rc's, cmp lines, head count and the golden/ours string pairs.
* `heads8.sh <workdir> <mode> <outdir> <test>…` — per-row head and cmp-line
  count from a `verify_golden` workdir; counts `^LHS:` on **stderr**.
* `leadscan8.sh <workdir>` — the a-priori predictor (§5).
* `leakshape8.sh <file>…` — the static, deliberately over-broad leak-shape
  scanner; its positive control is ibex `prim_assert.sv`.
* `attrib8.sh <patched wd> <pristine wd> <rel db>` — order-blind line
  attribution of one byte mover, scored against that row's golden.
* `nullsweep8.sh <binary> <sweep wd> <mode> <outdir> <test>…` — re-runs ONE
  binary with the harness's own argv and cwd (`TESTROOT=` names the corpus
  root) and byte-compares; a row that moves here is nondeterministic on a
  fixed binary.
* `HEADS.*.txt`, `GRID.*.txt`, `PREDICT.txt`, `BOUNDARY.txt` — the recorded
  measurements above.

Reproduce any arm with

```bash
cd gA && ~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv dut.sv
<slang-uhdm> dut.sv --single-unit --nobuiltin -o ours.uhdm
~/git-repos/UHDM/build/bin/uhdm-cmp slpp_all/surelog.uhdm ours.uhdm
```

`--nobuiltin` is REQUIRED on both sides — the harness passes it, and without it
the builtin package turns the whole design into a vector-size mismatch and the
head is thousands of lines of noise.
