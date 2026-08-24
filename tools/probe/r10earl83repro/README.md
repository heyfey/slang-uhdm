# r10earl83 — § `elabConnWrittenCastFold83`

**THE EARLGREY HEAD CLEARED IN BOTH MODES** (default 58 cmp lines → 240,
testflags 58 → 268; one head each, the 58-line object GONE), and every other
named row's head **byte-identical**.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `0df1393`, branch `auto5h`.** `results/*.csv` was **READ ONLY** and is
untouched — **NO ROW WAS CONVERTED** (`Earlgrey_0_1` stays `CMP_NOTEQUAL` in
both modes; its head is cleared, the design has more — see `PREDICT_R0.txt`).
slang was **NOT** patched. Production surface: **`src/ExprEmit.cpp` only**.

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_Earlgrey_{default,testflags}.cmp` are the verbatim pristine logs
from this pass's own build of `0df1393` (binary md5
`62a546a2e309c01971d212d7cf31605d`, equal to the main tree's). The default log
reproduces the master's `earlgrey_head_0df1393.cmp` **byte for byte**; the two
modes differ only in object ids.

`hw/ip/flash_ctrl/rtl/flash_ctrl.sv:137`, inside the instantiation of
`tlul_adapter_sram` in `top_earlgrey.u_flash_ctrl`:

```systemverilog
    .rdata_i    (BusWidth'(0)),
```

| | LHS (golden) | RHS (ours, pristine) |
|---|---|---|
| kind | `constant` 137:18-137:30 | `operation` 137:18-137:30 |
| | `vpiSize:32` | `vpiOpType:67` |
| | `UINT:0` | `vpiTypespec -> ref_typespec -> integer_typespec` 137:18-137:26 |
| | `vpiConstType:9` | `vpiOperand -> constant` 137:28-137:29 `UINT:0 size 64` |
| | *(no `vpiDecompile`, no typespec)* | |

**Which arm — read the MK line, not the shape.** Both sides are non-null and of
**different `UhdmType`** (`constant` vs `operation`), so `BaseClass.h:188`'s
two-non-null arm names both sides and the head is a **KIND mismatch inside
`BaseClass::Compare`'s `VpiType` line**, before any per-kind field of either
side is read. The 58 lines are the operation's sub-tree printing, not 58 cells.

r10earl82's `PREDICT_R0.txt` called this cast `integer'(0)`; the source says
`BusWidth'(0)` — a **size cast whose width is a parameter NAME**, which is what
the whole corpus population turns out to be (§3).

---

## 2. Question 2 — decoded from Surelog and UHDM, not guessed

1. **The elaborated port connection is RE-COMPILED, not cloned.**
   `NetlistElaboration::high_conn_`
   (`Surelog/src/DesignCompile/NetlistElaboration.cpp:1332-1337`, the ordered
   form at `:1088-1096`) calls
   `m_helper.compileExpression(parent_comp, fC, Expression, m_compileDesign,
   Reduce::Yes, nullptr, parent)` — the same fact
   § `elabConnEnumConstFold66` and § `connBitSelIdxModParamFold81` rest on.
2. **Every `compileExpression` ends in a reduce.**
   `CompileExpression.cpp:3648` runs `ExprEval::reduceExpr` on the result and
   keeps it when `invalidValue` stayed false.
3. **`reduceExpr`'s `vpiCastOp` arm** (`UHDM/templates/ExprEval.cpp:4074`)
   reduces the operand first, bails out on `invalidValue` (a net, a select, an
   `x`/`z` literal, a stream — golden KEEPS the cast for those), and then
   switches on the target typespec kind. The **`uhdminteger_typespec`** branch —
   which a size cast `N'(x)` / `PARAM'(x)` and the `integer` keyword both take —
   reads `cast_to` out of the typespec's own `VpiValue`, does
   `resize(oper, cast_to); res = get_value(oper) & mask;` and mints
   `UINT:<res>` / `VpiSize = cast_to` / `VpiConstType = vpiUIntConst`,
   **with no typespec and no `VpiDecompile`**. The sibling branches have their
   own widths and tags (`int` 64, `long_int` 64, `short_int` 16, `bit` 1 with
   `BIN:`), and `byte` / `logic` / `time` / typedef have **no arm at all**.
4. **The span.** The minted constant gets **no location**, so
   `compileExpression`'s tail (`:3658`) stamps it with the cast NODE's own
   span — the WHOLE cast text. buvm30 named the same `populateCoreMembers`
   mechanism with a FIRST-CHILD span; that is the unary-minus arm's. **Both
   claims were measured here**: golden's constant is `137:18-137:30`, our
   operation's own range, not the operand's `137:28-137:29`.
5. **Why we kept the cast.** `ExprEmit.cpp`'s `ExpressionKind::Conversion` case
   is purely syntax-driven: § `implicitStrConcatNoCast118`'s written-tick fence
   drops only compiler-inserted STRING conversions, § `castOverStreamKeepsCast29`
   only stream operands, and everything else falls through to the `vpiCastOp`
   mint. There was no reduce-context test at all.

---

## 3. Question 1 — THE CENSUS: every written cast in both corpora

`ct83cen.cpp` reads a `.uhdm` DIRECTLY (never a whole-dump diff — Earlgrey's
dump is >1 GB; earl61's direct-reader pattern) and has two modes, because
**a REDUCED cast is no longer an operation and cannot be found by looking for
operations**:

* `--cast` / `--spans` — one row per `vpiCastOp` operation, or its bare span;
* `--at <spanlist>` — one row per OBJECT OF ANY KIND at a listed span.

`cen83.sh` takes the **UNION of the two databases' own cast spans** and asks
BOTH what each span holds. KEY = `SPAN + CTX + PORTPAR + CALLARG + PSBOUND`;
PAYLOAD = `KIND OPT NOPS SZ VAL CT DEC TS TSV TSN OP0`. `CTX`/`PORTPAR` are
computed from the parent walk, so the **ELAB (`PORTPAR=module_inst`) and DEF
(`PORTPAR=ref_module`) copies of the same connection are separate cells** —
that split is the law's whole context test, read out of the data.
`score83.py` is a **multiset** join (a last-writer dict drops colliding rows).
Traps avoided: `VpiParent` is not a key beyond its CONTEXT CLASS; nesting DEPTH
is never a key (this law REMOVES an operation and shifts everything under it);
`ROOT=` records where the parent walk ends so an unreachable object
(uvm97) is visible as such; the payload carries no span-derived field.

Over the **76 surelog** and **132 uhdm2rtlil** databases that contain a written
cast at all (of 956 / 1358):

| | surelog pristine | surelog patched | u2r pristine | u2r patched |
|---|---:|---:|---:|---:|
| BOTH-SAME | 6149 | 6129 | 1986 | 1986 |
| MOVED-WRONG | 113 | **107** | 0 | 0 |
| GOLDEN-ONLY | 689 | 689 | 0 | 0 |
| OURS-ONLY | 1984 | **1978** | 16 | 16 |
| **FAMILY** (golden a `constant`, ours a `vpiCastOp`, ELAB High_conn) | **6** | **0** | **0** | **0** |
| REDUCED-ELSEWHERE (same, any other context) | 0 | 0 | 0 | 0 |

(the patched columns are censused on the patched sweep, whose union span set is
smaller because span `156:14-156:32` is no longer a cast span on our side at
all; the per-database **fixed-universe** re-score below is the apples-to-apples
one.)

**THE WHOLE POPULATION IS SIX CELLS — THREE SITES, ONCE PER MODE, ALL IN
`Earlgrey_0_1`, and every one a SIZE cast whose width is a parameter NAME:**

| source | written | golden ELAB High_conn | ours (pristine) |
|---|---|---|---|
| `flash_ctrl.sv:137` | `BusWidth'(0)` | `constant sz32 UINT:0 ct9` | `op67 -> integer_typespec`, operand `UINT:0 sz64` |
| `alert_handler.sv:87` | `PING_CNT_DW'(24'hFFFFFF)` | `constant sz24 UINT:16777215 ct9` | `op67 -> int_typespec UINT:24 PING_CNT_DW`, operand `HEX:FFFFFF sz24` |
| `pwrmgr_pkg.sv:156` | `WakeUpPeris'(1'b1)` | `constant sz16 UINT:1 ct9` | `op67 -> int_typespec UINT:16 WakeUpPeris`, operand `BIN:1 sz1` |

`res = value & ((1 << W) - 1)` reproduces all three, and in **all three** the
golden DEF-listing (`PORTPAR=ref_module`) copy at the very same span is still a
`vpiCastOp` operation, in golden and in ours alike — the fence that makes this
an ELAB-only law. `pwrmgr_pkg.sv:156` is the sharpest control: its **twelve**
`param_assign` copies of the same written cast are already folded constants in
BOTH databases and agree; only the ELAB High_conn copy disagreed.

**The mover prediction, made from PRISTINE databases before any patched sweep
was read** (the fire-set: `CTX=PORTHC PORTPAR=module_inst CALLARG=0 PSBOUND=0`,
ours a `vpiCastOp` whose operand is a constant with a `UINT:`/`HEX:`/`BIN:`/
`OCT:` value): **`Earlgrey_0_1` default and `Earlgrey_0_1` testflags, and
nothing else in either corpus.**

### Fixed-universe re-score of the two movers (the pristine span universe)

|  | pristine | patched |
|---|---:|---:|
| BOTH-SAME | 4826 | **4832** |
| MOVED-WRONG | 20 | **14** |
| GOLDEN-ONLY | 257 | 257 |
| OURS-ONLY | 1746 | 1740 |

and the cell-by-cell `.ours` diff (also in this directory's census dirs) is
**exactly six cells, each an `operation OPT=67` replaced by the `constant`
golden holds, field for field** — `sz32 UINT:0 ct9`, `sz16 UINT:1 ct9`,
`sz24 UINT:16777215 ct9`. **MOVED-WRONG 0, AWAY 0.** Nothing else in either
Earlgrey database changed a cell.

---

## 4. The law

**§ `elabConnWrittenCastFold83` — inside an ELABORATED port `High_conn`, a
WRITTEN size cast (or `integer'`) over an UNSIGNED WRITTEN INTEGER LITERAL is a
plain `constant` in golden, not a `vpiCastOp` operation: `VpiSize` = the cast
width W, `VpiValue = "UINT:" + (value & ((1<<W)-1))`,
`VpiConstType = vpiUIntConst`, NO typespec, NO decompile, and the span of the
WHOLE cast text.**

Shipped in `src/ExprEmit.cpp`'s `ExpressionKind::Conversion` case, as an early
return placed AFTER § `implicitStrConcatNoCast118` and
§ `castOverStreamKeepsCast29` and BEFORE the `vpiCastOp` mint, so the operation
and its typespec are never created (no orphan objects) and no operand is
emitted twice.

### The fences, each a negative control MEASURED ON GOLDEN

| | fence | measured |
|---|---|---|
| (a) | `elabConnEmit21` — the **DEF `ref_module` listing keeps the cast** | golden's def listing holds `op67` at the very same span at all three corpus sites and on every arm cell; `SAME->SAME` after the patch |
| (b) | a **`cont_assign` Rhs**, a **procedural statement**, an **instance PARAMETER actual** and a **gen-scope body** are not this law's context | `g1_ctx83.sv` C10-C13: golden keeps `op67` for every `cont_assign` Rhs and every procedural statement, in BOTH views (a module body compiles `Reduce::No`) — all unchanged. C14: an instance parameter ACTUAL leaves no cast object at all, in either database. C15 (`localparam int Q = integer'(7)`): golden's ELAB `param_assign` copy IS folded and we do not fold it — a REAL residue this law deliberately does not take, because its constant carries a `DEC` and an `int_typespec` the High_conn form does not (see `PREDICT_R0.txt` R1); untouched here |
| (c) | `callArgDepth == 0` | `g1_ctx83.sv` C6 and `g3_law83.sv` L64: golden KEEPS the cast inside a user call's argument (`compileTfCallArguments` compiles with a non-null `pexpr`) — § `connCallArgKeepsEnumRef66v`'s carve-out at a new consumer; unchanged |
| (d) | `!inPsRangeBound` | `g3_law83.sv` L65 `acc[32'(19):32'(4)]`: golden keeps BOTH bounds (`compilePartSelectRange` hardcodes `Reduce::No`, § `genScopeConnPsDirectBoundKeepsRef71`); both cells were already `SAME->SAME` and stayed |
| (e) | the WRITTEN `'` | § `implicitStrConcatNoCast118`'s and § `castOverStreamKeepsCast29`'s populations never reach this predicate — a compiler-inserted conversion is not a `CastExpression`, and a stream is not a literal (`g2_types83.sv` s06 unchanged) |

### The five producer abstentions, each measured and left byte-identical

| refused | golden actually does | arm |
|---|---|---|
| a **signed** written literal (`8'sd9`, `4'sh3`), and any parameter operand | `INT:<v>` `vpiIntConst` **plus a signed `logic_typespec`** — ExprEval's `oper_signed` branch | `g3_law83.sv` L53, L57, L59 |
| an **x/z** literal | KEEPS the cast (`get_value` invalidates) | L58 |
| a **non-literal** operand (net, select, expression, nested cast, call, stream, string) | keeps it for net/select/stream; folds the others through encodings this law does not name | L60, L61; `g2_types83.sv` s04-s12 |
| a target that is **not the integer arm** (`byte'`, `logic'`, `time'`, a typedef, an enum; `int'`, `longint'`, `shortint'`, `bit'`) | keeps `byte'`/`logic'`/`time'`/typedef; folds the others at 64 / 64 / 16 / 1-and-`BIN:` | `g2_types83.sv` t02, t06, t09, t13, t01, t04, t03, t05 |
| a cast **width ≥ 64** | `64'(64'h…FFFF)` is `sz64 UINT:0` and `96'(64'h…FFFF)` is `sz96 UINT:4294967295` — ExprEval's `mask = (1ULL << cast_to) - 1` is **C++ UB** and x86 shifts modulo 64 | L46, L47 |

The last one is a deliberate refusal to encode undefined behaviour; no corpus
cell needs it (see `PREDICT_R0.txt` R2).

---

## 5. Question 4 — the purpose-built goldens

`arm83.sh` builds each arm with Surelog (`-parse -nobuiltin -nocache -d uhdm`)
and with BOTH FROZEN binaries, censuses all three over the union of their cast
spans, and `score3_83.py` scores every cell three ways. Every child gets
`</dev/null` and its rc is recorded. Full output: `ARMS.r10earl83.txt`.

| arm | what it holds | SAME→SAME | WRONG→RIGHT | **RIGHT→WRONG** | WRONG→WRONG |
|---|---|---:|---:|---:|---:|
| `g1_ctx83.sv` | **17 CONTEXTS**, one and the same `integer'(0)`: whole actual / operation operand / concat operand / bit-select index / ips base / user-call arg / system-call arg / ternary arm / part-select bound, then cont_assign, nested cont_assign, procedural, nested procedural, instance-param actual, param init, gen-scope High_conn, declaration range bound | 24 | 5 | **0** | 3 |
| `g2_types83.sv` | **CAST TYPE × OPERAND**: 19 written targets (integer/int/byte/shortint/longint/bit/logic/`4'`/`8'`/typedef/enum/`signed'`/`unsigned'`/time/based/negative/x/huge) × 13 operand shapes (literal, module localparam, package parameter, based localparam, expression, net, net select, stream, enum constant, system call, nested cast, ternary, x, string) | 40 | 6 | **0** | 21 |
| `g3_law83.sv` | **THE LAW ARM**: the three corpus shapes, 1 and 3 instances, an overridden instance, 8 width cells (1/4/8/32/63/64/96/`integer'`), 11 base cells (plain, `'d`, `'sd`, `'h`, `'o`, `'b`, `'sh`, x, parameter, expression, net) and all four fenced positions | 37 | **17** | **0** | 8 |
| `g4_head83.sv` | **the head minimised** — `BusWidth'(0)` as an ELAB High_conn actual, nothing else | 1 | 1 | **0** | 0 |

`WRONG->OTHER` is **1**, on `g1_ctx83.sv` C2 alone (`.a(integer'(0) + 64'd2)`):
golden folds the WHOLE `+` to one `INT:2 sz64` constant *stamped at the cast's
own span*, so neither binary agrees there; pristine had an operation, patched a
constant. Golden holds no object at all at the other four such spans (a concat
operand, an ips base, a ternary false arm, a system-call argument) because it
folded the enclosing expression whole. Those shapes have **zero corpus cells**
(the census FAMILY is 6 and all six are bare actuals) and the corpus gate
confirms nothing else moved.

The official `uhdm-cmp` on each arm, golden vs ours, never grows:
`g1` 11139 → 10909, `g2` 29040 → 28884, `g3` 33406 → 32920,
`g4` 1741 → 1715 lines.

---

## 6. The gates

All green — `GATES.r10earl83.txt` has the full battery. In one line: goldens
23/0 and 0/23 on the negative control; uhdm2rtlil 679/50/2 in both modes with
**0 differing rows** and **0 byte movers / 1358**; surelog 471+466 CMP_EQUAL /
10+9 CMP_NOTEQUAL with **0 differing rows over 1588** and **3 byte movers /
956** — the two predicted Earlgrey databases plus the documented
Scoreboard/default ORDER COIN, whose path-normalised order-blind dump diff is
**0 lines**; canaries `ok=52` / `ok=8` `changed=0`, both `ctcan2` PASS,
`canaudit` `audited=29 UNCOVERED=0 FENCE-BREACH=0`, all five protected
databases byte-identical (SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`).

**THE WIDE BOUNDARY** (`vwide83.sh`, 4 shards, list on fd 3, children
`</dev/null`, PROCESSED asserted): **LISTED = PROCESSED = 3728** `.sv`/`.v`
sources at any depth under `tools/probe`, both views, both frozen binaries,
workdir-normalised dump byte-compare — **7156 identical, 8 DIFFERING, and all 8
are THIS PASS'S OWN FOUR ARMS in both views.** Every `r10uvm118repro` and
`r10v118repro` arm, every `r10buvm29repro` and `r10vbuvm29repro` arm, every
earl45-82 arm and every UVM/BUVM arm is **byte-identical** — the committed
fences of § `implicitStrConcatNoCast118` and § `castOverStreamKeepsCast29` were
re-run by this boundary and did not move.

**The one rc asymmetry, stated out loud.** rc histograms are symmetric
(`rc=3` 278/278, `rc=139` 14/14 — the pre-existing elab-view signals earl82's
R6 recorded) except `g4_head83.sv`, where **pristine exits 4 and patched exits
0**. The cause is benign and one-directional: pristine's cast-target bind for
`BusWidth'` runs under `emitInstance`'s STALE `currentScope`
(§ `castSizeElabScopeBind57`) and reports `expression kind: Invalid`; the fold
returns before that bind is attempted. It can only ever REMOVE a diagnostic,
and the corpus status histograms are identical in both corpora and both modes,
so **no corpus row changed status**.

---

## 7. Files

| | |
|---|---|
| `ct83cen.cpp` | the span-keyed written-cast census; direct `.uhdm` reader, dispatches nothing |
| `cen83.sh` | runs it over a whole `verify_golden` workdir, golden path from each test's OWN `cmds.txt` |
| `score83.py` | the multiset join + the FAMILY extractor (`--family`) |
| `arm83.sh`, `score3_83.py` | one arm, three databases, the 3-way per-cell verdict |
| `vwide83.sh` | the wide boundary |
| `g1_ctx83.sv` … `g4_head83.sv` | the purpose-built goldens |
| `HEAD_BEFORE_*.cmp`, `HEAD_AFTER_*.cmp` | the verbatim `uhdm-cmp` logs, both modes |
| `CENSUS.r10earl83.txt`, `ARMS.r10earl83.txt`, `GATES.r10earl83.txt`, `BOUNDARY_WIDE.*` | the measurements |
| `PREDICT_R0.txt` | the mover prediction and the NEXT HEAD, decoded |

Build the census tool with
`g++ -O2 -std=c++17 ct83cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83cen`.
