# r10yoo1 — YosysOldOr **CONVERTS**: a cont-assign RHS that does not fold as a whole still reduces its **ternary operands**

**Verdict, up front: `YosysOldOr` CONVERTS in BOTH MODES.** The rows, quoted from
the committed authoritative baseline FIRST and then from this pass's fresh sweep.
**No `results/*.csv` was touched by this pass** (`git status --porcelain
results/` is EMPTY); the MASTER promotes.

```
committed results/golden_surelog.csv        BEFORE
  YosysOldOr,default,CMP_NOTEQUAL,decompile:,,
  YosysOldOr,testflags,CMP_NOTEQUAL,decompile:,,

this pass, shipped binary bfac08131242f6e62e45408c78adba7f   AFTER
  YosysOldOr,default,CMP_EQUAL,,,differ
  YosysOldOr,testflags,CMP_EQUAL,,,differ
```

`uhdm-cmp` rc **255 → 0**, report **52 lines → 0**, heads **1 → 0**, in both
modes. The whole design compares EQUAL.

* **ONE LAW, `§ caTernOperandRead1`.** The diff is **+87/−7** lines in **ONE**
  production file; the executable core is **~20 lines** and adds **no new
  function** — it widens the harvest inside the existing `paramCaFoldRead`.
* **THE BRIEF'S BOUNDARY HYPOTHESIS IS REFUTED, AND SO IS ITS DESCRIPTION OF THE
  HEAD.** The brief proposed this was `§ mergedPortDefRangeSymbolic`'s residue on
  the typespec-kind axis, on a port "declared logic-ish in the header and int-ish
  in the body". It is not a port at all, there is no split declaration, and the
  three-line span is a three-**declarator** `parameter` statement. §6.1.
* **THE HEAD IS NOT WHERE THE BRIEF PUT IT.** The brief located it on the
  parameter's typespec. A census of all 385 parameter typespecs came back
  **385 EQ / 0 DIF** — golden's parameter typespec is byte-for-byte ours. The head
  is one slot over, on the `param_assign` **Rhs constant's** typespec, and only in
  the **elaborated** view. §1.2, §6.2.
* **THE LAW WAS ALREADY IN THIS CODEBASE AND ALREADY NAMED THIS WITNESS.**
  `src/ParamEmit.cpp` carried the comment *"Corpus witness
  or1200_fpu_intfloat_conv.v:86-88 — INF and QNAN are read at line 284, SNAN is
  read nowhere, and golden splits them exactly that way."* The law was
  implemented; its **read test** was too strict, and the witness it was written
  for never fired. §2.2.
* **I REFUTED TWO OF MY OWN HYPOTHESES WITH PURPOSE-BUILT ARMS BEFORE WRITING A
  LINE OF CODE** — "multi-declarator statement" (arm a1: 26 cells, all EQ) and
  "all but the last declarator" (arm a4 cell w4: the exact **inverse**). §6.3, §6.4.
* **AND I REFUTED A MEASUREMENT ALREADY WRITTEN INTO THIS CODEBASE.** The ablation
  table at `src/ParamEmit.cpp:13984` recorded *`whole name in a ternary condition
  → LOCATED`*. Golden answers **BARE**. Proved with the table's **own** parameter
  shape (arm a6 cell z5) and again with the module **instantiated** — the one
  difference that table's probes had (arm a7 cell k1). The wrong row is now
  struck through in place rather than deleted. §6.5.
* **GRID: 166 CELLS across the witness and seven purpose-built arms — 22
  CONVERGED, 144 HELD, NOT ONE REGRESSED.** §3.
* **FIVE GATES GREEN** in the **CONVERSION** world (§5), the two moved row-sides
  per mode being exactly `YosysOldOr`'s.
* **MOVERS: 2** (`YosysOldOr`, both modes) out of **2311** databases
  (1358 u2r + 953 surelog, both corpora both modes) — against a census-predicted
  upper bound of 100. The per-shape multiset table shows **every one of the 12
  moved shapes moves TOWARD golden and six land EXACTLY on golden's count**. §5.5.
* **The pristine sweep of the surelog corpus is BYTE-IDENTICAL to the committed
  baseline** (0 differing rows of 1588) — the base control, run rather than
  assumed. §5.4.

Base commit `97f6f90`, branch `auto5h`.
Pristine binary md5 **`5478b377271cf37d444e946449f63242`** (worktree
`/tmp/wt_r10yoo1pris`, `git rev-parse HEAD` =
`97f6f906770b306d28674a8a3c129203f32cb7d3`, `git status --porcelain` EMPTY).
Shipped binary md5 **`bfac08131242f6e62e45408c78adba7f`** (worktree
`/tmp/wt_r10yoo1`, same `HEAD`, `git status --porcelain` = exactly
`M src/ParamEmit.cpp` and this directory).

---

## 1. THE HEAD, AND THE CENSUS THAT LOCALIZED IT

### 1.1 The head as `uhdm-cmp` reported it at `97f6f90`

52 lines, ONE head, and the two databases are **byte-identical across the two
modes** (`cmp -s` on the two `slang.uhdm`, both binaries — §5.5.3), so one
measurement serves both rows.

```
LHS (golden):                          RHS (ours):
logic_typespec: , id:198740            int_typespec: , id:591, line:86:4, endln:88:24
|vpiRange:                             |vpiRange:
\_range:                               \_range:
  |vpiLeftRange:  constant UINT:30       |vpiLeftRange:  constant INT:30
  |vpiRightRange: constant UINT:0        |vpiRightRange: constant INT:0
```

Three deltas on one object: typespec **KIND**, bound **ENCODING**, and a **SPAN**
golden does not have.

### 1.2 The source, found by column arithmetic before any tool ran

`uhdm-cmp` gives the span but not the file. `86:4-88:24` was resolved by
scanning the 82 `or1200` RTL files for a line whose column 4 begins a
declaration and whose line 88 is exactly 24 characters long:

```
or1200_fpu_intfloat_conv.v
 86|   parameter\tINF  = 31'h7f800000,      <- col 4 = 'p' of `parameter`
 87|\t\t  QNAN = 31'h7fc00001,
 88|\t\t  SNAN = 31'h7f800001;              <- length 24, col 24 = ';'
```

ONE `parameter` statement, THREE declarators, each initialised to a **31-bit
sized literal** — hence a `[30:0]` range.

### 1.3 The census — BOTH SIDES, span-keyed, run BEFORE any code was written

**The first census was aimed at the wrong slot, and said so.** `r10yoo1cen.cpp`
censuses every **parameter**'s typespec (KIND + SPAN + SIGNED + RANGE-with-
encoding, one string per cell, keyed by `VIEW|owner vpiFullName|param name`):

```
CELLS 385   EQ 385   DIF 0   MISSING-GOLDEN 0   MISSING-OURS 0
```

**All 385 equal.** Golden's parameter typespec for `INF` is
`int_typespec@86:4-88:24 [INT:30:INT:0]` — exactly ours. That is a REFUTATION of
the brief's localization (§6.2), and it is the reason the slot is now named in the
key of the second probe: *a census aimed at the wrong slot reports "all equal" in
exactly the same words as a converged design.*

`r10yoo1pa.cpp` censuses the **`param_assign` Rhs constant's** typespec instead:

```
CELLS 385   EQ 383   DIF 2   MISSING-GOLDEN 0   MISSING-OURS 0
```

**EXACTLY TWO DIF CELLS**, and the design goes EQUAL when they are fixed — so the
localization was complete before a line was written:

| # | cell | golden | ours | |
|---|---|---|---|---|
| 1 | `DEF\|work@or1200_fpu_intfloat_conv\|INF` | `int_typespec@86:4-88:24 [INT:30:INT:0]` | same | EQ |
| 2 | `DEF\|…\|QNAN` | `int_typespec@86:4-88:24` | same | EQ |
| 3 | `DEF\|…\|SNAN` | `int_typespec@86:4-88:24` | same | EQ |
| 4 | `TOP\|…\|INF` | **`logic_typespec@SPANLESS [UINT:30:UINT:0]`** | `int_typespec@86:4-88:24 [INT:30:INT:0]` | **DIF** |
| 5 | `TOP\|…\|QNAN` | **`logic_typespec@SPANLESS [UINT:30:UINT:0]`** | `int_typespec@86:4-88:24 [INT:30:INT:0]` | **DIF** |
| 6 | `TOP\|…\|SNAN` | `int_typespec@86:4-88:24 [INT:30:INT:0]` | same | EQ |

The constant's `VpiValue`, `VpiSize` and `VpiConstType` agree in every cell. Only
the typespec moves. **The DEF view is already right; the split is TOP-view only;
and SNAN — the one of the three that is read nowhere — stays LOCATED on both
sides.**

### 1.4 The reach, measured from the golden cache and not guessed

`r10yoo1reach.cpp` over **all 3673** golden databases in
`~/.cache/slang-uhdm-goldens` (0 load failures, 0 timeouts):

```
spanless-logic_typespec cells on param_assign Rhs : 847
ranged int_typespec cells on param_assign Rhs     : 54881
```

So the shape golden emits at the head is **not rare** — 847 cells corpus-wide,
of which we already matched all but a handful. That number is why this pass is a
*read-predicate* fix and not a typespec-minting fix: the minting was already right.

---

## 2. THE LAW

### § caTernOperandRead1

> **A continuous-assign RHS that does NOT fold as a whole still reduces its
> TERNARY operands, and Surelog calls `getObject` on a parameter it reaches that
> way — which rebinds that parameter's elaborated `param_assign` Rhs constant to
> the LOC-LESS bare `logic_typespec` with UINT bounds.** Exactly two positions
> reach it, and only two:
>
> 1. the **CONDITION**, when the condition itself folds
>    (`assign o = P ? n1 : n2;`);
> 2. **BOTH BRANCHES**, when **BOTH** of them fold
>    (`assign o = (n1|n2) ? P2 : P1;`).
>
> A branch pair with ONE non-constant member reaches **nothing**
> (`assign o = n ? P : n2;` stays LOCATED). Only the plain single-predicate
> ternary is modelled. The population is unchanged from the existing rule's:
> untyped sized-literal, ranged-untyped, and typed-vector parameters alike, never
> an overridden one.

**The `&&` in clause 2 IS the law.** "Params in ternary branches get the bare ts"
is the rule a single witness supports; arm cells `y4`/`z6` show a one-param branch
pair reaches nothing, and that asymmetry is the only thing separating a
*reduction* model from a *mention* model.

### 2.1 STATED GATE == CODE GATE

| the law says | the code says |
|---|---|
| continuous assign only | `if (m.kind != SymbolKind::ContinuousAssign) continue;` (pre-existing) |
| whole RHS folds → harvest all of it | `if (ctx.tryEval(rhs)) { harvest(rhs); continue; }` |
| otherwise: ternary only | `if (r0.kind != ExpressionKind::ConditionalOp) continue;` |
| plain single predicate only | `if (co.conditions.size() != 1 \|\| co.conditions[0].pattern) continue;` |
| condition, when it folds | `if (ctx.tryEval(*co.conditions[0].expr)) harvest(...);` |
| BOTH branches, when BOTH fold | `if (ctx.tryEval(co.left()) && ctx.tryEval(co.right())) { harvest(left); harvest(right); }` |
| never an overridden param | `!isOverriddenParam(*ps)` at the call site, unchanged |

The conversion is stripped (`stripImplicitConv`) before the kind test because an
assignment RHS is commonly wrapped in a width conversion to the LHS.

### 2.2 THE LAW WAS ALREADY HERE, AND ALREADY NAMED THIS WITNESS

`src/ParamEmit.cpp:16108` (at `97f6f90`, before this pass):

```
// Corpus witness or1200_fpu_intfloat_conv.v:86-88 — INF and QNAN are
// read at line 284 (`… ? QNAN : INF`), SNAN is read nowhere, and
// golden splits them exactly that way.
```

The binding site, the population gates and `makeBareVecParamTs` (which mints
precisely golden's loc-less logic ts with UINT-only bounds) were all in place.
**Only the read test was wrong**: `paramCaFoldRead` required
`ctx.tryEval(rhs)` to succeed on the *whole* cont-assign RHS. The witness's RHS is

```verilog
assign out_fixed = ((qnan_d | snan_d) | (ind_d)) ? QNAN : INF;   // :283
```

whose condition reads **nets**, so it folds nowhere, so `INF`/`QNAN` were never
harvested. **A pass wrote the law, cited this witness, and shipped a gate the
witness cannot pass.** That is also exactly why my own arm a4 (`assign o2 = 1'b1
? T2 : T1;` — fully constant, therefore foldable) came back 24/24 EQ and told me
the law already worked. §6.6.

### 2.3 THE ADJACENT LAWS, AND WHY THIS IS NOT ONE OF THEM

* **`§ mergedPortDefRangeSymbolic`** — split port declarations. **Not this**: no
  port, no split declaration (§6.1).
* **`makeParamTs` / `predefIntTypespec`** — typespec-KIND minting per integer
  kind. **Not touched.** The kinds minted here were already correct; the DEF view
  proves it (all three cells EQ).
* **the fold-rule family (UINT-vs-INT encoding)** — **not touched.** The UINT
  encoding comes from `makeBareVecParamTs`, which already existed and already
  wrote UINT-only bounds.
* **`paramNameIsRead`'s select rule** — deliberately **not** widened. The existing
  comment records that the wider spelling over-fired on
  `Surelog/tests/PartSelect4/dut.sv`; this pass changes only
  `paramCaFoldRead`, and `PartSelect4` is unmoved in the byte verifier.

---

## 3. THE GRID, CELL FOR CELL

166 cells: the witness (6, §1.3) plus seven arms. Every arm was run with **both**
binaries; `PRIS` and `SHIP` are the same census, same key, same format.

### 3.1 The witness (`default`; `testflags` is byte-identical, §5.5.3)

| cell | golden | PRIS | SHIP | |
|---|---|---|---|---|
| `TOP\|…\|INF` | bare logic UINT | int LOCATED INT | **bare logic UINT** | **CONVERGED** |
| `TOP\|…\|QNAN` | bare logic UINT | int LOCATED INT | **bare logic UINT** | **CONVERGED** |
| `TOP\|…\|SNAN` | int LOCATED | int LOCATED | int LOCATED | HELD |
| `DEF\|…\|INF/QNAN/SNAN` | int LOCATED | int LOCATED | int LOCATED | HELD ×3 |

### 3.2 Arm **a5** `a5_readshape.v` — THE ARM THAT DECIDED THE LAW

Every condition/operand is a **net**, so nothing in the file folds; a cell that
comes back BARE therefore proves foldability of the whole RHS is not required.
`CELLS 24  EQ 24  DIF 0` with the shipped binary (was `EQ 21 DIF 3`).

| cell | shape | golden | PRIS | SHIP | |
|---|---|---|---|---|---|
| y1 A1 | `(n1\|n2) ? A2 : A1` | BARE | LOCATED | **BARE** | **CONVERGED** |
| y1 A2 | both branches params | BARE | LOCATED | **BARE** | **CONVERGED** |
| y3 C1 | `C1 ? nc1 : nc2` (condition) | BARE | LOCATED | **BARE** | **CONVERGED** |
| y4 D1 | `nd ? D1 : nd2` (ONE branch) | LOCATED | LOCATED | LOCATED | **HELD — the `&&`** |
| y5 E1,E2 | branch of a NESTED ternary | LOCATED | LOCATED | LOCATED | HELD ×2 |
| y2 B1 | `nb & B1` (not a ternary) | LOCATED | LOCATED | LOCATED | HELD |
| y6 F1 | `{nf, F1}` (concat) | LOCATED | LOCATED | LOCATED | HELD |
| y7 G1,G2 | the same ternary in `always` | LOCATED | LOCATED | LOCATED | HELD ×2 |
| y8 H1,H2 | never read | LOCATED | LOCATED | LOCATED | HELD ×2 |

`y1` is the witness **minimized to 10 lines**; `y3` is the cell that refutes the
codebase's own table; `y4` is the cell that makes clause 2 an `&&`.

### 3.3 Arm **a6** `a6_overfire.v` — the OVER-FIRE fence across all three populations

The call-site gate admits three parameter populations at once, so each needed its
own golden answer in the witness's read shape. `EQ 20 DIF 2` shipped (was `EQ 12
DIF 10`).

| cell | population | golden | PRIS | SHIP | |
|---|---|---|---|---|---|
| z1 A1,A2 | untyped **sized-literal** | BARE | LOCATED | **BARE** | **CONVERGED ×2** |
| z2 B1,B2 | **ranged** untyped `[30:0]` | BARE | LOCATED | **BARE** | **CONVERGED ×2** |
| z3 C1,C2 (TOP) | **typed** `logic [30:0]` | BARE | LOCATED | **BARE** | **CONVERGED ×2** |
| z4 D1 | ranged, whole name in cond | BARE | LOCATED | **BARE** | **CONVERGED** |
| z5 P1 | **the table's own shape** `[4:0] P1 = 7` in cond | BARE | LOCATED | **BARE** | **CONVERGED** |
| z6 E1 | ranged, ONE branch | LOCATED | LOCATED | LOCATED | HELD |
| z7 F1,F2 | unsized decimal (no range exists) | int norange | int norange | int norange | HELD ×2 |
| z3 C1,C2 (**DEF**) | typed, DEF-view span | `@46:14-46:19` | `@46:14-46:26` | `@46:14-46:26` | **stillDIF ×2 → R1** |

The 2 `stillDIF` cells are a **pre-existing** DEF-view span-extent defect present
in the pristine binary too (§7 R1) — not a regression, and outside this head.

### 3.4 Arm **a7** `a7_instantiated.v` — the instantiation confound, and the override fence

`EQ 10 DIF 0` shipped (was `EQ 7 DIF 3`).

| cell | shape | golden | PRIS | SHIP | |
|---|---|---|---|---|---|
| k1 P1 | the table's shape, **INSTANTIATED** | BARE | LOCATED | **BARE** | **CONVERGED** |
| k2 Q1,Q2 | witness shape, **INSTANTIATED** | BARE | LOCATED | **BARE** | **CONVERGED ×2** |
| k3 R1,R2 | witness shape, **OVERRIDDEN** | LOCATED | LOCATED | LOCATED | **HELD ×2 — the override fence** |

### 3.5 Arms **a1**, **a2**, **a4** — the three that HELD ENTIRELY (80 cells, 0 DIF on both binaries)

| arm | what it varies | cells | PRIS | SHIP |
|---|---|---|---|---|
| a1 `a1_declcount.v` | 1/2/3/4 declarators, mixed widths | 26 | 26 EQ | 26 EQ |
| a2 `a2_litform.v` | unsized dec, `'d`, `'b`, expression, mixed | 30 | 30 EQ | 30 EQ |
| a4 `a4_usage.v` | usage × declarator count, all **foldable** | 24 | 24 EQ | 24 EQ |

a1 and a4 are the arms that **refuted my hypotheses** (§6.3, §6.4). a2 confirms
the initialiser population is untouched: no `[w-1:0]` range exists for an unsized
decimal, so nothing there can move.

### 3.6 Arm **a3** `a3_declform.v` — 12 DIF on **BOTH** binaries, all pre-existing

`EQ 18 DIF 12` with **both** the pristine and the shipped binary — identical
verdicts, so this pass neither fixed nor broke any of them. Two distinct
pre-existing residues, filed as §7 R1 and R2.

**GRID TOTAL: 166 cells — 22 CONVERGED, 144 HELD, 0 REGRESSED.**

---

## 4. THE PATCH

`src/ParamEmit.cpp`, **+87/−7**, one file, no new symbol.

1. **`paramCaFoldRead`** (`:14250`) — the harvest is lifted into a `harvest`
   lambda so it can be called on sub-expressions; the whole-RHS `tryEval` path is
   unchanged in effect (`harvest(rhs); continue;`); and `§ caTernOperandRead1`
   adds the ternary arm underneath it. ~20 executable lines.
2. **The ablation table** (`:13984`) — the row this pass refuted is **struck
   through in place**, with the two arm cells that refute it named, rather than
   deleted. A silently removed wrong measurement is indistinguishable from one
   that was never made.

No other production file is touched. `include/UhdmExporter.h` needs no change:
`paramCaFoldRead`'s signature and the `caFoldReadNames` cache are unchanged.

---

## 5. THE FIVE GATES

Read in the **CONVERSION** world of GATE 4 — **said first, as the brief
requires** — because `YosysOldOr` moved.

### 5.1 GATE 1 — BUILD, and a BEHAVIOURAL base marker

Both binaries built from an absolute path; the link line **waited for** and
counted (`Linking CXX executable slang-uhdm` = 1 each); **0** lines matching
`error:`; `Built target slang_uhdm` = 1 each; each md5 asserted in its **own**
command and checked to be 32 hex.

```
pristine  /tmp/wt_r10yoo1pris/build/slang-uhdm   5478b377271cf37d444e946449f63242   32-hex ✓
shipped   /tmp/wt_r10yoo1/build/slang-uhdm       bfac08131242f6e62e45408c78adba7f   32-hex ✓
```

**A build-determinism control fell out for free**: before the patch, the two
*separate* worktrees produced binaries with the **same** md5
(`5478b377271cf37d444e946449f63242`), so the toolchain is reproducible and the
post-patch md5 change is attributable to the patch alone.

`basemark1.sh` is **two-directional on one observable with FOUR controls that must
NOT move**. **There is deliberately no symbol row** — this pass adds no function,
its law's name lives only in a comment, and a `strings` row would read 0 for both
binaries and look like a missing patch (§6.7):

```
                                                        PRISTINE            SHIPPED
MOVER      TOP|work@y1_tern_branches|A1     int_typespec@34:4-35:24 [INT:30:INT:0]  ->  logic_typespec@SPANLESS [UINT:30:UINT:0]
CONTROL A  TOP|work@y4_one_branch|D1        int_typespec@56:4-56:31 [INT:30:INT:0]  ==  int_typespec@56:4-56:31 [INT:30:INT:0]
CONTROL B  TOP|work@y2_and_operand|B1       int_typespec@42:4-42:31 [INT:30:INT:0]  ==  int_typespec@42:4-42:31 [INT:30:INT:0]
CONTROL C  TOP|work@y8_neverread|H1         int_typespec@88:4-89:24 [INT:30:INT:0]  ==  int_typespec@88:4-89:24 [INT:30:INT:0]
CONTROL D  TOP|work@k3_parent.u3|R1         int_typespec@46:4-47:24 [INT:30:INT:0]  ==  int_typespec@46:4-47:24 [INT:30:INT:0]
```

CONTROL A is the law's `&&`, B the non-ternary read, C the never-read control, D
the override fence.

### 5.2 GATE 2 — GOLDENS, both directions

```
SLANG_UHDM=<shipped>  ./tests/check_goldens.sh   rc=0   PASS=23  FAIL=0
SLANG_UHDM=/bin/false ./tests/check_goldens.sh   rc=1   PASS=0   FAIL=23
```

### 5.3 GATE 3 — uhdm2rtlil, `testflags`, `--jobs 2`

```
679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL        (= 679/50/2)   ✓
496 match       183 differ        52 <empty>            (= 496/183/52) ✓
ct8rows.sh vs committed results/gate_uhdm2rtlil.csv:
  baseline 731 ROWS, fresh 731 ROWS
  WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  PASS: every row byte-identical to the committed baseline
```

(The sweep was run `--mode both`; `default` is also 679/50/2. The testflags rows
were split out for the row gate because `results/gate_uhdm2rtlil.csv` is a
testflags baseline.)

### 5.4 GATE 4 — surelog, BOTH modes, `--jobs 2` — **CONVERSION world**

**WHICH WORLD, SAID FIRST: the CONVERSION world.** `YosysOldOr` moved, so the
post-`SVSwitch` unconverted expectation (`468/12` + `464/9`) is **not** the one to
judge against; the conversion expectation is, and it is met exactly:

```
                       BASELINE             FRESH        expected
default    CMP_EQUAL    468        ->        469          469   ✓
default    CMP_NOTEQUAL  12        ->         11           11   ✓
testflags  CMP_EQUAL    464        ->        465          465   ✓
testflags  CMP_NOTEQUAL   9        ->          8            8   ✓
```

Every other status bucket is **unchanged in both modes**: `DEFERRED` 5/5,
`SLANG_REJECT` 284/286, `SURELOG_FAIL` 25/23, `NO_DATABASE` 3, `NO_UHDM` 1,
`TIMEOUT` 1, `UNTRANSLATABLE` 2.

**THE BASE CONTROL, RUN AND NOT ASSUMED.** The *pristine* sweep of the same corpus
was diffed against the committed baseline first:

```
ct8rows.sh results/golden_surelog.csv <pristine sweep>
  baseline 1588 ROWS, fresh 1588 ROWS
  WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  PASS: every row byte-identical to the committed baseline
```

This also **disposes of the concurrent-sweep race** the ops rules warn about: the
two sweeps ran concurrently and not one `SURELOG_FAIL` detail row moved.

`ct8rows.sh` on the **shipped** sweep, whole row, status **and** dump column:

```
baseline 1588 ROWS, fresh 1588 ROWS
WHOLE-ROW diff: 2 differing ROWS (4 diff row-sides)   = EXACTLY 2 row-sides per mode ✓
  < YosysOldOr,default,CMP_NOTEQUAL,decompile:,,
  < YosysOldOr,testflags,CMP_NOTEQUAL,decompile:,,
  > YosysOldOr,default,CMP_EQUAL,,,differ
  > YosysOldOr,testflags,CMP_EQUAL,,,differ
```

The dump-column histogram moves consistently and only there: `default` empty
326→325 / differ 243→244, `testflags` empty 330→329 / differ 299→300 — one row
per mode leaving the empty bucket, which is `YosysOldOr` acquiring a dump verdict
now that it compares.

**CANARIES.**

* **`InterfaceModPort` and `BlackParrotComplex` — BY NAME, checked FIRST**, both
  modes, baseline then fresh: `CMP_EQUAL,differ` → `CMP_EQUAL,differ`,
  **UNMOVED** in all four rows.
* `canaries.sh`, **named on both corpora**: surelog `ok=50 changed=2 absent=0
  unknown-names=7` (7 is the documented u2r-only count); u2r `ok=8 changed=0
  absent=0 unknown-names=25`. **The 2 CHANGED rows are printed, read, and are
  exactly the intended conversion** — `YosysOldOr default` and `YosysOldOr
  testflags`, `CMP_NOTEQUAL/ -> CMP_EQUAL/differ`. Nothing else in either corpus
  moved.
* `ctcan2.sh`, **EXPECT_UNKNOWN mode-matched and baseline FIRST**: surelog
  `EXPECT_UNKNOWN=1` → `ok=58 changed=0 absent=0 unknown-patterns=1`, **PASS**;
  u2r `EXPECT_UNKNOWN=6` → `ok=1 changed=0 absent=0 unknown-patterns=6`, **PASS**.
* `canaudit.sh` → `audited=29  UNCOVERED=0  FENCE-BREACH=0`, and the four
  slang-fenced names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
  `TopParam`) are dispatched by **no** driver in this directory.
* **`Scoreboard/default`, the documented same-size flake, did NOT appear as a
  mover in this run** (`grep -c Scoreboard` on the verifier output = 0), so there
  was no flake to disambiguate. Recorded because its *absence* is also a fact.

### 5.5 GATE 5 — the BYTE VERIFIER, both corpora BOTH modes, vs the PRISTINE `97f6f90` I built

#### 5.5.0 The prediction, recorded BEFORE the verifier's answer was known

`census1.sh` filters on the law's two **necessary** conditions — a cont-assign
whose RHS contains a ternary, and a parameter whose typespec can carry a
`[w-1:0]` range — and is an explicit **UPPER BOUND**, because foldability is an
elaboration fact no grep can decide:

```
uhdm2rtlil          7 of 734 test dirs   -> <= 14 databases (x2 modes)
Surelog/tests       5 of 695 test dirs
third_party/tests  38 of  70 test dirs   -> <= 86 databases (x2 modes)
UPPER BOUND        <= 100 databases
```

Reasoned down before measuring: most of those ternaries fold entirely (already
handled by the old path) or their parameters carry no range. **Predicted: a small
single-digit number, with `YosysOldOr` certain and `openmsp430` the one named
plausible surprise** (the existing table cites it as carrying exactly this
distinction).

#### 5.5.1 The verifier

`byteverify.sh`, `SELFCHECK=1 SELFCHECK1=1`, against the pristine sweeps of the
**same** binary-to-corpus pairing:

```
uhdm2rtlil   databases: patched=1358 pristine=1358   PATH_SETS_IDENTICAL
             MOVERS: 0 / 1358
             SELFCHECK  1357/1358 flagged      SELFCHECK1  1                ✓

surelog      databases: patched=953 pristine=953     PATH_SETS_IDENTICAL
             MOVER ./default/YosysOldOr-02449e06/slang.uhdm
             MOVER ./testflags/YosysOldOr-02449e06/slang.uhdm
             MOVERS: 2 / 953
             SELFCHECK  952/953 flagged        SELFCHECK1  3 (= 1 + 2 real)  ✓
```

**REAL MOVERS: 2, out of 2311 databases across both corpora and both modes** —
inside the predicted bound of 100, and `openmsp430` did **not** move.

#### 5.5.2 Movers per-shape, by MULTISET, vs GOLDEN — ADDED and REMOVED separately

`msthree.sh` (GOLD / PRIS / SHIP counts per dump shape, `sed 1d` on every dump,
ADDED and REMOVED never netted):

| | shape | GOLD | PRIS | SHIP | |
|---|---|---|---|---|---|
| ADDED | `\_logic_typespec: ` (ind 0) | 2 | 0 | **2** | **exactly golden** |
| ADDED | `\_logic_typespec: ` (ind 4) | 2 | 0 | **2** | **exactly golden** |
| ADDED | `\_logic_typespec: ` (ind 8) | 2 | 0 | **2** | **exactly golden** |
| REMOVED | `\_int_typespec: , line:86:4, endln:88:24` (ind 8) | 4 | 6 | **4** | **exactly golden** |
| ADDED | `\|UINT:30` (ind 6) | 11 | 9 | **11** | **exactly golden** |
| ADDED | `\|UINT:0` (ind 6) | 2823 | 2821 | **2823** | **exactly golden** |
| ADDED | `\|vpiRange:` (ind 2) | 2911 | 2907 | 2909 | toward golden |
| ADDED | `\|vpiParent:` (ind 4) | 11010 | 11006 | 11008 | toward golden |
| ADDED | `\|vpiLeftRange:` (ind 4) | 2911 | 2907 | 2909 | toward golden |
| ADDED | `\|vpiRightRange:` (ind 4) | 2911 | 2907 | 2909 | toward golden |
| ADDED | `\_range: ` (ind 2) | 88 | 84 | 86 | toward golden |
| ADDED | `\_constant: ` (ind 4) | 178 | 170 | 174 | toward golden |
| | **TOTAL SHAPES MOVED** | | | **12** | |

**Every one of the 12 moved shapes moves TOWARD golden; six land EXACTLY on
golden's count and none overshoots.** The six that remain short are short by
exactly the residual dump-only gap that keeps the converted row's dump column at
`differ` (§7 R3) — the *cmp* head is gone, the *byte* residue is not, and those
are different metrics.

#### 5.5.3 The two modes are one measurement

`cmp -s` on the two `slang.uhdm` files, for **each** binary:

```
PATCHED  default == testflags   BYTE-IDENTICAL
PRISTINE default == testflags   BYTE-IDENTICAL
```

So every per-object number in this document holds for both rows, and the
`testflags` row's conversion is not a separate claim needing separate evidence.

---

## 6. REFUTATIONS

### 6.1 **THE BRIEF'S BOUNDARY HYPOTHESIS IS WRONG — there is no port here**

The brief proposed the head might be `§ mergedPortDefRangeSymbolic`'s residue "on
the TYPESPEC-KIND axis (a port declared logic-ish in the header and int-ish in the
body …); the source @86:4-88:24 spans THREE lines — read it." Read: the three
lines are one `parameter` statement with three **declarators**
(`or1200_fpu_intfloat_conv.v:86-88`). There is no port, no header/body split, and
`§ mergedPortDefRangeSymbolic` is not in the call path. The three-line span is a
declarator **list**, not a merged declaration.

### 6.2 **THE HEAD IS NOT ON THE PARAMETER'S TYPESPEC — 385 cells say so**

The brief described the head as "golden `logic_typespec` … ours `int_typespec
@86:4-88:24`" and asked *"whose typespec is it"*. The natural read is the
parameter's. It is not: golden's parameter typespec **is** `int_typespec@86:4-88:24
[INT:30:INT:0]`, ours byte-for-byte, in **both** views, and the parameter census
returns `385 EQ / 0 DIF`. The head is on the `param_assign` **Rhs constant's**
typespec, TOP view only. Had I coded against the brief's localization I would have
changed `makeParamTs` and broken all 385 cells to fix 2.

### 6.3 **"MULTI-DECLARATOR" IS REFUTED — arm a1, 26 cells, all EQ**

My first hypothesis, from the witness's shape and its siblings
(`or1200_fpu_arith.v`, `_div.v`, `_mul.v`, `_post_norm_div.v` all declare the same
`INF/QNAN/SNAN` idiom in **separate** statements and golden keeps all of them
`int_typespec`): *a multi-declarator untyped statement splits*. Arm a1 cell
`c3_three` is the witness's shape **exactly** — three declarators, `31'h` literals,
elaborated view — and golden gives **all three** `int_typespec`. 26/26 EQ. Dead.

### 6.4 **"ALL BUT THE LAST DECLARATOR" IS REFUTED BY ITS EXACT INVERSE — arm a4 cell w4**

The witness's split is `{INF, QNAN} = logic`, `{SNAN} = int` — the first two of
three. "All but the last" fits perfectly and is wrong. Arm a4 `w4_three_last_used`
declares three and reads **only the last**: golden gives `V1,V2 = int` and
**`V3 = logic`** — the exact inverse. And `w1_one_used` (ONE declarator, read)
comes back `logic`, so declarator count is irrelevant to begin with. What a4
actually proved is that **usage** is the axis, cell for cell across 24 cells.

### 6.5 **A MEASUREMENT ALREADY WRITTEN INTO THIS CODEBASE IS WRONG — arms a6 z5 and a7 k1**

`src/ParamEmit.cpp:13984` recorded, as part of a table of purpose-built ablations:

```
//   whole name in a ternary condition      assign w = P ? n1 : n2      -> LOCATED
```

Golden answers **BARE**. I did not take my own arm's word for it, because my arms
used a different parameter population (untyped sized-literal) from that table's
(`parameter [4:0] Pn = 7`, ranged untyped), and both could have been right for
their own population. So:

* cell **z5** runs the table's **own** shape — `parameter [4:0] P1 = 7`, read as a
  whole name in a ternary condition → golden **BARE**;
* cell **k1** repeats z5 with the module **INSTANTIATED**, which is the one
  difference that table's probes describe ("one instantiated `sub`") → golden
  **still BARE**.

Both readings are BARE, so the row is **wrong, not merely narrow**. It is now
struck through in place with both refuting cells named, because deleting it would
make a wrong measurement indistinguishable from an absent one.

### 6.6 **MY OWN FIRST ARM SAID THE LAW ALREADY WORKED, AND IT WAS THE ARM'S FAULT**

Arm a4 returned `24 EQ / 0 DIF` on the **pristine** binary — including ternary
cells — which reads as "we already implement this; there is nothing to fix." The
arm was wrong, not the diagnosis: every a4 cell's cont-assign RHS is **fully
constant** (`assign o2 = 1'b1 ? T2 : T1;`), so it satisfies the old
`tryEval(rhs)` gate and exercises the *old* path. The witness's condition reads
nets. Arm a5 was written specifically to make **every** condition and operand a
net, and it immediately produced the 3 DIF cells the diagnosis needed. **An arm
that accidentally satisfies the gate under test measures the gate you already
had.**

### 6.7 **THERE IS NO SYMBOL ROW IN GATE 1, AND THAT IS DELIBERATE**

Every recent pass's base marker carries a `strings | grep <new symbol>` row. This
pass adds **no** new function — it widens an existing one — and `§
caTernOperandRead1` exists only in a comment, which no binary contains. A symbol
row would print `0` for **both** binaries and read as a missing patch. Rather than
invent a function to have a row to print, the marker is behaviour-only with four
controls. Stated here so its absence is not read as an omission.

### 6.8 WHAT THIS PASS DID **NOT** PROVE

* **Nested foldable branches.** `assign o = n ? (1'b1?A:B) : (1'b0?C:D)` — both
  branches fold, so the law harvests A,B,C,D. **Untested against golden.** Arm a5
  `y5` tests only the *non*-foldable nesting. Filed as R4.
* **Non-ternary non-foldable reduction positions.** Only `&` (y2) and concat (y6)
  were measured LOCATED. A `+`, a shift, or a comparison with one constant operand
  may or may not behave like them.
* **`if`/`case` generate conditions.** The existing comment says slang has already
  folded those away; not re-verified here.
* **Why `SNAN` gets an `int_typespec` object at all** in the elaborated view rather
  than sharing the DEF view's. Not needed for the head, not investigated.
* **The 847-cell corpus population** was counted, not audited cell-by-cell. The
  byte verifier bounds the *change* at 2 databases; it does not claim the other
  845 cells are individually correct.

---

## 7. RANKED RESIDUES

**R1 — typed multi-declarator vector param: DEF-view typespec SPAN EXTENT.**
`parameter logic [30:0] P1 = .., P2 = .., P3 = ..;` → golden's typespec spans
`33:14-33:19` (the first declarator's name alone), we span `33:14-33:26`. 6 cells
in arm a3 (`m3_typed`, DEF+TOP × 3) and 2 in arm a6 (`z3` DEF). **Pre-existing on
both binaries.** Highest-ranked because it is a pure span rule with a purpose-built
repro already on disk. Owner: `makeParamTs`'s `trimTypeSigning` span.

**R2 — signed untyped multi-declarator param: we add a range golden does not.**
`parameter signed Q1 = 31'h.., Q2 = .., Q3 = ..;` → golden `int_typespec
@39:14-39:20 norange`, ours the same span **with** `[INT:30:INT:0]`. 6 cells in
arm a3 (`m4_signed`). **Pre-existing on both binaries.** The signing keyword
apparently suppresses the based-literal range; the production rule at
`ParamEmit.cpp:15149` does not consult it.

**R3 — `YosysOldOr` remains `dump: differ` after converting.** The row is
`CMP_EQUAL` in both modes but not byte-equal. The dump diff is dominated by
`begin`-block column spans (`work@or1200_alu` `211:15` golden vs `211:19` ours,
and ~20 more like it) — a **CMP_ONLY** class, uncompared by `uhdm-cmp`. The six
"toward golden" shapes in §5.5.2 are this gap. Next target for this test.

**R4 — nested FOLDABLE ternary branches, untested.** See §6.8. The implemented
rule will harvest through them; golden's answer is unknown. A 6-line arm would
settle it.

**R5 — the other 845 spanless-logic golden cells are unaudited.** §1.4 counted the
population; this pass did not verify each. A full-corpus run of `r10yoo1pa.cpp`
(golden vs ours, every test) would turn that count into a grid and is the natural
next census.

---

## 8. WHAT IS ON DISK

### 8.1 Written by this pass

| file | what it is |
|---|---|
| `r10yoo1cen.cpp` | parameter-typespec census — the probe that **refuted** the brief's localization (385 EQ) |
| `r10yoo1pa.cpp` | `param_assign` Rhs-constant typespec census — the probe that **found** the head (2 DIF) |
| `r10yoo1reach.cpp` | golden-cache reach scanner (847 / 54881 over 3673 databases) |
| `armrun.sh` | runs Surelog + a slang binary on one arm and prints the joined census |
| `basemark1.sh` | GATE 1's behavioural, two-directional marker with 4 controls |
| `census1.sh` | GATE 5's census-predict upper bound |
| `a1_declcount.v` … `a7_instantiated.v` | the seven arms the grid in §3 is measured on |
| `README.md` | this file |
| `README.verifier.md` | this pass's verifier record (GATE 5's instrument and its controls) |

### 8.2 Carried in unchanged, because the gates above quote them

`ct8rows.sh`, `byteverify.sh`, `msthree.sh`, `msmovers.sh`, `msdist.sh`,
`canaudit.sh`, `ctcan2.sh` (from `r10svs15repro`), `canaries.sh` (from
`r10uvm52repro`). Carried rather than referenced so this directory reproduces §5
on its own.

### 8.3 Deleted after the gates read them

The four sweep workdirs (`/tmp/r10yoo1_wdslr_{pat,pris}`,
`/tmp/r10yoo1_wdu2r_{pat,pris}`), the two witness workdirs, and the per-arm temp
directories. The CSVs and gate logs under `/tmp/r10yoo1_*` are the readable
record; the databases are regenerable from them plus the two binaries.

### 8.4 The arm sources the grid was measured on ARE the ones being landed

No arm was edited after its numbers were taken. `a5_readshape.v` and
`a7_instantiated.v` are additionally the inputs `basemark1.sh` re-runs, so GATE 1
is reproducible from this directory alone.
