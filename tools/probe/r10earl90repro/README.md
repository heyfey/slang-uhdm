# r10earl90 — § `connIpsWidthNonOvParamSignedTs90`

**THE EARLGREY HEAD CLEARED IN BOTH MODES.** `Earlgrey_0_1` default and
testflags, 15 cmp lines and ONE head each at `986bc0a`, the two logs
byte-identical; the head object is the `ref_typespec` golden hangs off the
folded `N_TIMERS` **WIDTH** operand of the `indexed_part_select` in
`rv_timer.sv:82`'s port connection, and we minted that constant bare.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `986bc0a`, branch `auto5h`.** `results/*.csv` was **READ ONLY** and is
untouched — **NO ROW WAS CONVERTED** (`Earlgrey_0_1` stays `CMP_NOTEQUAL` in
both modes; its head is cleared, the design has more — see `PREDICT_R0.txt`).
slang was **NOT** patched. Production surface: **`src/ExprEmit.cpp` and
`include/UhdmExporter.h` only.**

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_Earlgrey_{default,testflags}.cmp` are the verbatim pristine logs
from this pass's own build of `986bc0a` (binary md5
`d181b1b59682b7739e5f5681f15a9c83`); they reproduce r10earl89's committed
`HEAD_AFTER_*` logs line for line modulo object ids, and the two modes are
byte-identical to each other, so there is ONE head.

```
LHS:
decompile:
ref_typespec: , id:404128
|vpiParent:
\_constant: , id:404126, line:82:58, endln:82:66
|vpiActual:
\_int_typespec: , id:404127
   … the same block a second time …
RHS: <null>
```

`BaseClass.h`'s **SINGULAR** `SafeCompare` overload names the VALUE and prints
`RHS: <null>`, so the head is a whole missing `ref_typespec`, not a field of
one. The owner is

```
hw/ip/rv_timer/rtl/rv_timer.sv:20   localparam int N_TIMERS = 1;
hw/ip/rv_timer/rtl/rv_timer.sv:82
  .reg2hw_intr_enable_q_i (intr_timer_en[h*N_TIMERS+:N_TIMERS]),

work@top_earlgrey.u_rv_timer.gen_harts[0].u_intr_hw
  port(reg2hw_intr_enable_q_i)
    indexed_part_select intr_timer_en   82:46-82:66
      Base_expr  82:46-82:47  folded `0`  INT:0 sz64 ct7  — NO typespec EITHER SIDE
      Width_expr 82:58-82:66  folded `1`  UINT:1 sz32 ct9 — golden TS, ours <null>
```

The BASE is the **built-in negative control**: `h*N_TIMERS` is an OPERATION, so
Surelog reduces it through `reduceExpr` and not through the identifier arm, and
neither side carries a typespec there. Only the WIDTH — a BARE parameter read —
takes the arm that mints one.

---

## 2. Question 1 — the Surelog decode, read out of the source

1. **The elaborated port connection is RE-COMPILED, not cloned.**
   `NetlistElaboration::high_conn_` (`NetlistElaboration.cpp:1332-1337`)
   compiles the actual in the PARENT instance with **`Reduce::Yes`**.
2. **`compileSelectExpression`'s INDEXED arm passes the caller's `reduce` to
   BOTH bounds** — `CompileExpression.cpp:4258-4272` for `Base_expr` and
   `:4266-4272` for `Width_expr` — while the SIMPLE arm seventeen lines above
   (`:4241-4249`) hardcodes `Reduce::No` for `Left_range` and `Right_range`.
   **CONFIRMED, and confirmed on golden from the other side**: `g3_slots90.sv`
   rows `p01`-`p04` show golden KEEPING `ref_obj P4` in a `part_select`
   LEFT/RIGHT slot in the very same elaborated port high_conn where it folds
   the ips width (§ `genScopeConnPsDirectBoundKeepsRef71`'s family).
3. **The identifier arm's mint** (`CompileExpression.cpp:3004-3018`):
   ```cpp
   c->VpiValue(sval->uhdmValue());   c->VpiDecompile(sval->decompiledValue());
   c->VpiConstType(sval->vpiValType()); c->VpiSize(sval->getSize());
   if (sval->isSigned()) { int_typespec *ts = s.MakeInt_typespec();
                           ts->VpiSigned(true); … c->Typespec(rt); }
   ```
   That `if` is the whole law, and the object is BARE: no name, no location, no
   ranges, no value, no `Typedef_alias`, no `Instance`, no `Cast_to_expr` —
   every field `typespec::Compare` and `int_typespec::Compare` READ is unset.
4. **Where `sval->isSigned()` comes from** —
   `DesignElaboration::collectParams_` (`DesignElaboration.cpp:2519-2545`)
   compiles the default, runs `adjustSize(ts, …)`, then
   ```cpp
   if (c->Typespec() == nullptr) c->Typespec(<the DECLARED ts>);
   value = fromVpiValue(c->VpiValue(), c->VpiSize());
   cts = c->Typespec()->Actual_typespec();
   valueRange(value, /*lhstps=*/ts, /*rhstps=*/cts ? cts : ts, …);
   ```
   and `CompileHelper::valueRange` (`CompileHelper.cpp:5378-5398`) reads
   `VpiSigned` off **`rhstps`** — the EFFECTIVE typespec — for
   `logic_typespec`, `bit_typespec` and `int_typespec` **ONLY**.
5. **An OVERRIDDEN parameter takes the other path**
   (`DesignElaboration.cpp:2147-2172`), which has no `adjustSize` and never
   calls `valueRange`.

**QUESTION 1's TWO SUB-QUESTIONS, ANSWERED ON GOLDEN:**

* *Does golden also stamp a `bit_select` INDEX or a `part_select` bound in an
  ELAB High_conn?* — **The bit_select index YES, the part_select bounds NO.**
  `g3_slots90.sv` `i01` (a bare signed-int localparam index) is a golden
  `constant UINT:4 sz32 ct9` carrying the same bare signed `int_typespec`,
  while we keep a `ref_obj` there; `p01`-`p04` show golden keeping `ref_obj`
  in both part_select slots. So earl84's R2 is **not** 0 cells on golden — it
  is 0 cells in the CORPUS (the corpus census below finds none), and it is a
  FOLD-PRESENCE change, not a typespec one. Recorded as **R2**, untaken.
* *Does golden stamp a width that is an EXPRESSION rather than a bare leaf?* —
  **No.** `g3` `w03` (`P2*2`), `w04` (`4`) and `w05` (`g+4`) carry no typespec
  in golden; they never reach the identifier arm.

---

## 3. Question 2 — THE CENSUS, both corpora, keyed by SLOT

`ct90cen.cpp` reads a `.uhdm` **DIRECTLY** (never a whole-dump diff —
Earlgrey's dump is >1 GB; earl61's direct-reader pattern) and enumerates
**SELECTS**, not bounds, so a bound that changed KIND on one side is still
found under the SAME key. KEY = `SPAN + SLOT + SEL + INHP + CTX + PORTPAR +
CALLARG + PSBOUND + ROOT` (+ `INST` on arms only); PAYLOAD = `KIND NAME SZ VAL
CT DEC TS TSN TSSG TSVL TSRG TSAL TSIN TSCE HPNM CS IPT` — every field the
generated `Compare`s actually read, and **no span-derived field** (earl60's
`attrv60` lesson). `score90.py` is a **multiset** join.

Over **277 surelog** and **488 uhdm2rtlil** databases that hold a select at
all (of 956 / 1358; the golden path comes from each test's OWN `cmds.txt`):

| | surelog pristine | surelog patched | u2r pristine | u2r patched |
|---|---:|---:|---:|---:|
| BOTH-SAME | 215 411 | **215 429** | 19 110 | 19 110 |
| MOVED-WRONG | 1 197 | **1 179** | 0 | 0 |
| GOLDEN-ONLY | 4 922 | 4 922 | 78 | 78 |
| OURS-ONLY | 43 439 | 43 439 | 90 | 90 |
| **TS-MISSING-ELABHC** (both sides the SAME folded constant, golden carries a typespec and we carry none, in an ELAB port High_conn) | **18** | **0** | **0** | 0 |
| TS-MISSING-ELSEWHERE (the same, in any other context) | 174 | 174 | 0 | 0 |
| **TS-EXTRA** (either direction — we carry one golden does not) | **0** | **0** | **0** | **0** |
| TS-KIND-DIFF | 87 | 87 | 0 | 0 |

**THE WHOLE ELAB-HIGH_CONN POPULATION IS 18 CELLS, ALL `SLOT=WIDTH`, ALL
`indexed_part_select`, ALL OUTSIDE A `hier_path`, ALL IN `Earlgrey_0_1`, ALL
`N_TIMERS`** — exactly the 18 r10earl84's residue R1 predicted, at exactly the
six spans it named:

| source | written | golden ELAB High_conn width | ours (pristine) |
|---|---|---|---|
| `rv_timer.sv:82` | `intr_timer_en[h*N_TIMERS+:N_TIMERS]` | `constant UINT:1 sz32 ct9` **+ bare signed `int_typespec`** | the same constant, NO typespec |
| `rv_timer.sv:83` | `intr_timer_test_q[…]` | (identical) | (identical) |
| `rv_timer.sv:85` | `intr_timer_state_q[…]` | (identical) | (identical) |
| `rv_timer.sv:87` | `intr_timer_state_d[…]` | (identical) | (identical) |
| `rv_timer.sv:89` | `intr_out[…]` | (identical) | (identical) |
| `rv_timer.sv:108` | `intr_timer_set[…]` | (identical) | (identical) |

six cells in `default` and twelve in `testflags` (two elaborated copies of each
span, which is why the pristine `MOVED-WRONG` drops by exactly 18).
`CENSUS.family.before.surelog.txt` lists all 18 verbatim.

**THE 174 + 87 CELLS THIS PASS DOES NOT TOUCH** are the same slot in a
different CONTEXT — an ELABORATED `cont_assign`, all in `Earlgrey_0_1` — and
they are a DIFFERENT object: golden's typespec there is an **UNSIGNED**
`int_typespec` (`TSSG=0`), and 87 of them additionally carry a `hier_path`
`VpiName` difference (`…a_source[8_-_1-:1]` vs `…a_source[IDW_-_1-:1]`).
Ranked **R0** in `PREDICT_R0.txt`; a bare signed `int_typespec` there would be
a WRONG object, which is why the law is fenced to the port high_conn.

---

## 4. Question 3 — the law

**§ `connIpsWidthNonOvParamSignedTs90` — inside an ELABORATED port `High_conn`,
the folded WIDTH constant of a bare-name `indexed_part_select` whose width
operand is a BARE read of a MODULE-SCOPE parameter carries a BARE
`int_typespec` with `VpiSigned` set exactly when that parameter's STORED
`Value` is signed: the DECLARED typespec's sign under `valueRange`'s
three-kind (`int` / `bit` / `logic`) switch, EXCEPT that a bare-reference
initializer whose own Value is signed overrides it, a QUALIFIED package
reference replaces it with the package parameter's own declared sign, an
UNTYPED parameter has no compiled typespec and answers FALSE, and an
OVERRIDDEN parameter never runs `valueRange` at all.**

Shipped in `src/ExprEmit.cpp` as one helper plus **ONE call site** — the
`genvarConnFold` width mint, immediately after the constant is built and
before it becomes `Width_expr`. **It only ADDS a `Typespec`**: the value, the
size, the encoding, the span and the parenting above it are untouched, so this
law can add an object and can never change one.

### The fences, each a negative control MEASURED ON GOLDEN

| | fence | measured |
|---|---|---|
| (a) | **the DEFINITION view keeps the ref** (§ `elabConnEmit21`) | every `PORTPAR=ref_module` row of every arm holds `ref_obj N_TIMERS` / `ref_obj P4` on BOTH sides, before and after |
| (b) | the operand must be a **BARE parameter read** | `g3 w03` (`P2*2`), `w04` (`4`), `w05` (`g+4`) and the head's own OPERATION base carry no typespec in golden and are refused by construction |
| (c) | **not a package parameter** | `g2 u17`-`u21`: a WILDCARD-IMPORTED package parameter read BARE folds with **no** typespec, and a QUALIFIED `pk90::X` read carries the package's OWN declared object — `int_typespec` **UNSIGNED** for `int unsigned` (`u19`) and a **`logic_typespec`** on a `DEC:2`/`vpiDecConst` constant for `logic signed [7:0]` (`u20`). A bare signed `int_typespec` there would be a WRONG object |
| (d) | **user-call argument depth** (`callArgDepth - sysCallArgDepth22`) | convicted by golden BOTH ways: `g1 gen_m` `.a_i(uf90({…, sig[m*N+:N], …}))` — golden keeps `ref_obj N_TIMERS` in the ELABORATED copy; `g1 gen_n`'s `$unsigned(…)` twin folds it AND carries the typespec, and the patch lands on golden there exactly |
| (e) | **not overridden at this instantiation** | `g4`'s `mid90 #(parameter int MW = 4)` at THREE instantiations from ONE declaration and ONE span: golden gives `u_m1`/`u_m2` (`.MW(2)`) a `sz64 UINT:2` constant with **no** typespec and `u_m3` (default) a `sz32 UINT:4` one **with** it. The law fires on `u_m3` alone |
| (f) | **not a `bind` instantiation** (§ `connBindInstKeepsRef84v`) | `g4`'s `bind bindee90 bnd90 u_bind (.a(sig[0 +: Bd90]))` — golden AND both binaries keep the `ref_obj`; the flag is asserted anyway |
| (g) | **untyped, and the three-kind switch** | `g2 u16` (untyped) and `u03`-`u08`/`u10`/`u12`/`u15` (`int unsigned`, `integer`, `byte`, `shortint`, `longint`, unsigned `bit`/`logic`/typedef/implicit) carry no typespec in golden and none after |

### The declared-type grid (`g2_types90.sv`), golden, ELAB port High_conn, ips WIDTH

All hold the value 2, all in the same gen-for, all `sig[g*2 +: P]`.

| declared type | golden constant | golden typespec | patched |
|---|---|---|---|
| `localparam int` | `UINT:2 sz32 ct9` | **bare signed `int_typespec`** | **= golden** |
| `localparam int signed` | `UINT:2 sz32 ct9` | **yes** | **= golden** |
| `localparam int unsigned` | `UINT:2 sz32 ct9` | — | = golden |
| `localparam integer` | `UINT:2 sz32 ct9` | — | = golden |
| `localparam byte` | `UINT:2 sz8 ct9` | — | = golden |
| `localparam shortint` | `UINT:2 sz16 ct9` | — | = golden |
| `localparam longint` | `UINT:2 sz64 ct9` | — | = golden |
| `localparam bit [3:0]` | `INT:2 sz4 ct7` | — | encoding residue R1 |
| `localparam bit signed [3:0]` | `INT:2 sz4 ct7` | **yes** | typespec = golden, encoding R1 |
| `localparam logic [7:0]` | `INT:2 sz8 ct7` | — | encoding residue R1 |
| `localparam logic signed [7:0]` | `INT:2 sz8 ct7` | **yes** | typespec = golden, encoding R1 |
| `localparam byte_t90` (= `logic [7:0]`) | `INT:2 sz8 ct7` | — | encoding residue R1 |
| `localparam ls_t90` (= `logic signed [7:0]`) | `INT:2 sz8 ct7` | **yes** | typespec = golden, encoding R1 |
| `localparam signed [7:0]` (IMPLICIT) | `INT:2 sz8 ct7` | **yes** | typespec = golden, encoding R1 |
| `localparam [7:0]` (IMPLICIT) | `INT:2 sz8 ct7` | — | encoding residue R1 |
| untyped `localparam` | `UINT:2 sz32 ct9` | — | = golden |
| imported `PKG_I` read BARE | `UINT:2 sz32 ct9` | — | = golden |
| `pk90::PKG_I` QUALIFIED | `UINT:2 sz32 ct9` | int_typespec **signed** | refused (R3) |
| `pk90::PKG_IU` (`int unsigned`) | `UINT:2 sz32 ct9` | int_typespec **UNSIGNED** | refused (R3) |
| `pk90::PKG_LS` (`logic signed [7:0]`) | `DEC:2 sz8 ct1` | **`logic_typespec` signed** | refused (R3) |
| `pk90::PKG_LU` (`logic [7:0]`) | `DEC:2 sz8 ct1` | `logic_typespec` unsigned | refused (R3) |

The IMPLICIT `signed [7:0]` row is why this law does **not** carry
§ `connHpIpsBaseNonOvParamFold84`'s explicit-declared-type fence: that fence
exists because `adjustCopiedParamConst64` refuses an implicit type, and this
law re-encodes nothing. Golden stamps it, and so do we.

### The initializer grid (`g4_homes90.sv`) — `valueRange`'s `rhstps`, in both directions

| declaration | golden | patched |
|---|---|---|
| `int P4R = P4` (bare ref, source SIGNED) | TS | = golden |
| `int P4RU = P4U` (bare ref, source UNSIGNED) | **TS** (the declaration decides) | = golden |
| `int unsigned U4R = P4` (bare ref, source SIGNED) | **TS** (the SOURCE decides) | = golden |
| `int unsigned U4RU = P4U` | none | = golden |
| `int unsigned U4Q = pq90::Q_SGN` (QUALIFIED) | **TS** | = golden |
| `int unsigned U4QU = pq90::Q_UNS` | none | = golden |
| **`int S4Q = pq90::Q_UNS`** (QUALIFIED, unsigned source, SIGNED declaration) | **NONE** | = golden |
| `int E1 = P4U*1`, `int E3 = $clog2(16)`, `int E5 = int'(P4U)` | TS | = golden (E1 keeps encoding R1) |
| `int unsigned E2/E4` (same, unsigned decl) | none | = golden |
| `int C2 = P4R` (two-deep bare chain) | TS | = golden |

`S4Q` is the row that separates this predicate from
§ `dimBoundLeafValueSignedTs89`'s `paramValueSigned89`, which asks the DECLARED
question first and would answer TRUE there. Its site is the dimension bound,
its corpus population for this shape is 0, and this pass does not touch it —
recorded as **R4**.

### The home / slot grid (`g3_slots90.sv`, `g4_homes90.sv`)

Golden stamps, and the patch lands on golden, in EVERY home measured: a
for-generate, an if-generate, an UNNAMED `begin`/`end` generate, a THREE-DEEP
`gd1[0].gd2[0].gd3` chain, an interface instantiated in a generate scope, a
gen-scope localparam as the width, both copies of a two-iteration loop, and the
gen-scope body of a `bind` TARGET module. A PLAIN (non-generate) module
instantiation is the one home where golden folds and **we still keep a
`ref_obj`** — a FOLD-PRESENCE residue this pass does not create and does not
fix (**R5**, `g1` `u_flat`, `g4` `h01`; 0 corpus cells).

---

## 5. Question 4 — the arms

`arm90.sh` builds each arm with Surelog (`-parse -nobuiltin -nocache -d uhdm`)
and with BOTH FROZEN binaries, censuses all three with `--inst`, and scores
every cell two ways. Every child gets `</dev/null` and its rc is recorded.
Full output: `ARMS.r10earl90.txt`.

| arm | what it holds | SAME→SAME | WRONG→RIGHT | **RIGHT→WRONG** | CHANGED | EXACT | **AWAY** |
|---|---|---:|---:|---:|---:|---:|---:|
| `g1_head90.sv` | the head minimised, then ELEVEN CONTEXTS for one read | 46 | 8 | **0** | 8 | 8 | **0** |
| `g2_types90.sv` | **21 DECLARED TYPES** × the ips WIDTH | 38 | 2 | **0** | 6 | 2 | **0** |
| `g3_slots90.sv` | **THE SLOT GRID**: ips BASE/WIDTH, bit_select IDX, part_select LEFT/RIGHT, var_select × six operand shapes | 22 | 2 | **0** | 2 | 2 | **0** |
| `g4_homes90.sv` | **THE HOME / OVERRIDE / PRODUCER GRID**: 7 homes, 3 instances with 2 overrides, a `bind`, 13 initializer forms | 90 | 23 | **0** | 25 | 23 | **0** |

**`RIGHT->WRONG` 0 and `AWAY` 0 on every arm.** The six CHANGED-but-not-EXACT
cells are named in `ARMS.r10earl90.txt` and ranked R1; every one of them gained
golden's exact typespec and kept a pre-existing `VAL`/`CT` difference.

---

## 6. The gates

All green — `GATES.r10earl90.txt` has the full battery. In one line: goldens
**23/0** and **0/23** on the negative control; uhdm2rtlil **679/50/2** in both
modes with **0 differing rows** and **0 byte movers / 1358**; surelog
**471+466 CMP_EQUAL / 10+9 CMP_NOTEQUAL** with **0 differing rows over 1588**
and **3 byte movers / 956** — the two Earlgrey databases this pass PREDICTED
BY NAME from the pristine census AND from the pristine cell trace, plus the
`Scoreboard`/default COIN; canaries `ok=52` / `ok=8` `changed=0`, both
`ctcan2` PASS, `canaudit` `audited=29 UNCOVERED=0 FENCE-BREACH=0`, all five
protected databases byte-identical (`SVSwitch` `4842211c4030`, `YosysVerx`
`6ccda350c24a`).

**THE MOVERS ARE ATTRIBUTED THREE WAYS, and all three are exact.**

* **A run-time A/B gate.** The patched binary run with `R10E90_OFF=1` (the law
  disabled, everything else identical) re-runs Earlgrey's own two command
  lines and reproduces the PRISTINE database **byte for byte in both modes** —
  `ded7aff7a3d0` and `8cfc4af7915b`, the pristine sweep's own hashes — while
  the law ON gives `43a8d277a6fc` / `02496164d2f6`, the patched sweep's own.
  **100 % of each mover's byte delta is this law**, and the same gate holds on
  all four arms.
* **The span-keyed direct-reader census**, fixed-universe (golden side asserted
  unchanged): `TS-MISSING-ELABHC` **18 → 0**, `TS-EXTRA` **0 → 0**, BOTH-SAME
  215 411 → 215 429, MOVED-WRONG 1 197 → 1 179, every other bucket unchanged.
  Per-cell: **WRONG->RIGHT 18, RIGHT->WRONG 0, AWAY-GOLDEN 0, STILL-WRONG 0.**
* **The order-blind dump diff** for the coin: `Scoreboard`/default's two dumps,
  path-normalised and SORTED, are 1 099 223 lines each and differ in **ZERO
  lines** — the svunit_pkg `vpiTaskFunc` ORDER flip of RESUME §9, not a cell of
  this law. Its select-bound census is byte-identical between the two binaries.

**THE WIDE BOUNDARY** (`vwide90.sh`, list on fd 3, children `</dev/null`,
PROCESSED asserted): **LISTED = PROCESSED = 4067** `.sv`/`.v` sources at any
depth under a copy of `tools/probe`, both views, both frozen binaries,
workdir-normalised dump byte-compare — see `BOUNDARY_WIDE.tally`. **Eight of
the differing cells are this pass's own four arms in both views.** Of the rest:

| file | verdict |
|---|---|
| `r10earl47repro/b1_earl47.sv` | 3 cells, **all this law**, re-scored against a fresh Surelog golden: `RIGHT->WRONG 0`, `AWAY 0`, 3 TO-GOLDEN (each gains golden's exact typespec and keeps the pre-existing `INT:v`/ct 7 vs `UINT:v`/ct 9 encoding difference — residue R1) |
| `r10earl65repro/g1_conn65.sv` | 3 cells, **all this law**: `WRONG->RIGHT 3`, `RIGHT->WRONG 0`, **EXACT 3, AWAY 0** |
| `r10earl70repro/g1_earl70.sv` | 6 cells, **all this law**: `WRONG->RIGHT 6`, `RIGHT->WRONG 0`, **EXACT 6, AWAY 0** |
| `r10buvm22repro/g22.sv` | **NOT this law** — the A/B gate proves it: `R10E90_OFF=1` on the patched binary still prints the PATCHED dump hash (`acd78ab17832`), identical to law-ON, while the pristine binary prints `60725d038650`. Both binaries exit `rc=4` and emit no comparable database. It is the pre-existing garbage numeric literal whose value TRACKS THE BINARY'S CODE LAYOUT that r10earl84's R5 recorded, and it moved for r10earl84 and r10earl89 the same way |

So **every earlier-pass arm that moved was re-measured against a fresh golden
and moves TOWARD it**; 12 cells across three arms, `RIGHT->WRONG 0` and
`AWAY 0` on all three.

---

## 7. Files

| | |
|---|---|
| `ct90cen.cpp` | the select-bound census; direct `.uhdm` reader, dispatches nothing |
| `cen90.sh` | runs it over a whole `verify_golden` workdir, golden path from each test's OWN `cmds.txt` |
| `score90.py` | the multiset join + the TYPESPEC-PRESENCE family extractor (`--family`) |
| `arm90.sh`, `score3_90.py` | one arm, three databases, the 3-way per-cell verdict |
| `tsdir90.py` | the DIRECTION scorer (EXACT / TO-GOLDEN / NEUTRAL / **AWAY**) |
| `predict90.sh`, `dirmap90.sh` | the mover prediction: every pristine command line re-run under `R10E90_OFF=1 R10E90_CELLDBG=1`, in the test's own directory. `dirmap90.sh` rebuilds the workdir-suffix → source-directory map and is where the FENCE lives: the four slang-fenced tests' directories are omitted, listed only as opaque sha1[:8] hashes, so the driver prints `FENCED-SKIP` and runs nothing |
| `vwide90.sh`, `bdlist90.sh`, `bdscore90.sh` | the wide boundary, its file list, and the per-mover re-score against a fresh Surelog golden |
| `g1_head90.sv` … `g4_homes90.sv` | the purpose-built goldens |
| `HEAD_BEFORE_*.cmp`, `HEAD_AFTER_*.cmp` | the verbatim `uhdm-cmp` logs, both modes |
| `CENSUS.*`, `ARMS.*`, `GATES.*`, `PREDICT_*`, `BOUNDARY_WIDE.*` | the measurements |
| `PREDICT_R0.txt` | the mover prediction and the NEXT HEAD, decoded |

Build the census tool with
`g++ -O2 -std=c++17 ct90cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct90cen`.

`R10E90_OFF=1` disables the law at run time in the shipped binary and
`R10E90_CELLDBG=1` names every cell that REACHES the site with BOTH answers;
they are the A/B gate and the mover predictor every attribution here rests on.
