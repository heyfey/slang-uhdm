# r10v162 — the ADVERSARIAL VERIFIER of r10uvm162 (§ `badConcatCompoundOperands162`) — **ACCEPT AS SHIPPED**

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge. The
official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for every
number below. slang was **NOT** patched; `results/*.csv` were **READ ONLY**;
**no row was converted**; `GOLDEN_DEFER` stayed unset; the four slang-fenced
tests were never dispatched and are not named in any file here.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `fe4a739` |
| worktrees | `/tmp/wt_v162pris` (clean `fe4a739`), `/tmp/wt_v162` (`fe4a739` + `/tmp/r10uvm162.patch`) |
| pristine binary | md5 `83258cd958cb88be667bf6729dcb0b9d`, frozen `chmod 555` at `/tmp/v162_pris.bin` |
| patched binary | md5 `834a54ee7996ba8b29b245895a4eaee8`, frozen `chmod 555` at `/tmp/v162_pat.bin` |
| verdict | **ACCEPT AS SHIPPED** — no production change was needed; this directory adds only arms and instruments |

Both md5s were produced by this verifier's own `cmake --build … -j 2` from
fresh worktrees and **match the implementer's reported md5s bit for bit**. The
patch applies clean on a fresh `fe4a739` with only whitespace warnings, its
production surface is `src/ExprEmit.cpp` + `include/UhdmExporter.h` and nothing
else, its probe surface is `tools/probe/r10uvm162repro/` only, it touches no
`results/*.csv`, and the fence check over all four fenced names returns 0.

---

## 1. WHAT WAS REPRODUCED, BIT FOR BIT

Every headline number in the implementer's report was re-measured on this
verifier's own binaries, sweeps and workdirs. `GATES.r10v162.txt` carries the
full battery. The ones that matter:

* goldens **23/0** on both binaries, `/bin/false` **0/23**;
* uhdm2rtlil **679 / 50 / 2** in both modes on both binaries, **0 differing
  rows** against the committed baseline AND against this verifier's own
  pristine sweep, **0 / 1358 byte movers**;
* surelog **0 differing rows over 1588** against both, `CMP_NOTEQUAL` **10
  default + 9 testflags** unchanged, **3 / 956 byte movers**;
* **2 of the 3 movers were PREDICTED BY NAME from PRISTINE DATABASES ONLY**
  before the patched sweep was read — this verifier re-ran `predsweep162.sh`
  itself and got `rows=956 SKIP-NOFILE=617 PRED-TOWARD 2 AWAY 0 TRUNC 0 GROW
  14`, the two cells being `uvm_pkg::uvm_registry_common::create`
  `14061:13-14064:70` op33 in `default/BuildUVMPkg-bf853d43` and
  `testflags/BuildUVMPkg-bf853d43`; uhdm2rtlil `rows=1358 SKIP-NOFILE=104`, all
  buckets 0;
* **heads: BuildUVMPkg 321 → 29 on both modes**, one head, and the patched head
  log is **byte-identical to the committed `head_pat_BuildUVMPkg.default.cmp`**;
  every other named row's head log is **byte-identical pristine vs patched**;
* corpus census over the moved rows: **OP TOWARD 5, ARG 2, HP 2, WRONG 0,
  AWAY 0, RESHAPE 0, ONLY-A 0** on both BuildUVMPkg rows, all zero on
  Scoreboard (`CENSUS.r10v162.txt`);
* whole-dump order-blind on BuildUVMPkg: **+154 golden lines VERBATIM, 0
  deleted, distance 68022 → 67878**;
* the ORACLE PROOF re-run on this verifier's golden databases: **TWIN 75,
  NOTTWIN 0** over the four `ok_`/`bd_` arms, both views;
* the cell table on ours: pristine **TWIN 1/75**, patched **TWIN 52/75**, and
  **every one of the 22 refused cells prints `bd=4 lines` — an ABSTENTION
  (the empty operand vector), never a wrongly-minted object**; the 23rd
  (`b15`) is § 160's own top-level `::` recovery and is untouched;
* canaries **52/8 ok, 0 changed**; `ctcan2` PASS ×2; `canaudit` **audited=29
  UNCOVERED=0 FENCE-BREACH=0**; the six protected databases byte-identical,
  `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`;
* every one of the 2981 + 2981 `cmds.txt` command lines audited **BY BINARY
  PATH**: only the two frozen binaries appear, never the main tree's.

### THE § 160 GATE THE IMPLEMENTER SAYS IT KEPT — CHECKED DIRECTLY

`r10v160repro/cells/c05_pkgscope.sv` (§ 160's own committed verifier cell for
its shape (5)) is **28 cmp lines in both views on both binaries and the two
databases are BYTE-IDENTICAL**. The `depth > 0` gate on the package-parameter
refusal does exactly what it claims and touches nothing § 160 landed. This
verifier also confirmed on its own arm (`arms/v162_8_pkgfold.sv`, cell `f01`)
that a top-level `pkg::PARAM` operand is **still minted** as `ref_obj
Untouched8::NEVER`, while the same name inside a ternary, a nested concat, a
replication count and a binary operator is refused.

---

## 2. BREAKING THE LAW — NINE NEW ARMS, DELIBERATELY UNLIKE THE IMPLEMENTER'S

The implementer's grid names every cell `a1`/`b1`/`c1` and always writes the
unbindable call as the **last** operand of the concatenation, so its compound
operands were always fully bindable. These arms vary the naming, the case, the
numbering, the operand ORDER and the position of the bad call, and put the bad
call **inside** the compound.

| arm | what it attacks |
|---|---|
| `v162_1_badinside.sv` | THE FACE THE GRID NEVER WRITES — the silently unbindable call as the ternary's own CONDITION, TRUE ARM, FALSE ARM and all three at once; inside a nested concat one and two deep; inside a replication BODY; inside a binary operand; and a ternary inside a nested concat inside a ternary |
| `v162_2_shapes.sv` | a ternary of ternaries in every position; a bare call with 0, 1 and 3 arguments; nested concat one and two deep; a replication with a CONSTANT, a PARAMETER and an EXPRESSION count; a call whose actual is a call; a package-qualified PARAMETER at top level, in a ternary arm and as a replication count; a system call, a cast, a select and `this.<member>`, each bare and inside a ternary |
| `v162_3_ctx.sv` | assignment Rhs, concat operand, call argument, RETURN value, `if` condition, case EXPRESSION, case ITEM, `while` condition, system-task argument, statement-level ternary arm, two rejected concats in one method, a rejected concat inside a rejected concat, a good concat after a bad one — plus TWO LVALUE concat CONTROLS |
| `v162_4_home.sv` | a generic class's DEFAULT specialization, an OUT-OF-BODY method, a STATIC method (twice), a TASK, a package FUNCTION, a NON-generic class control, and ONE, TWO and THREE explicit specializations in the database beside the default |
| `v162_5_stress.sv` | the recursion's own edges: 18 nested parens (past the unwrap bound of 16) and 8 (inside it); 20 nested ternaries (past the depth bound) and 6 (inside it); 18 nested concatenations and 5; replication counts 0, 1 and 64; 19- and 20-digit literals; `1_000`; `8'd65`; `32'h0000_00FF`; a 25-operand concatenation |
| `v162_6_reported.sv` | THE REPORTED-ERROR TWIN — an explicit `#(int)` specialization that makes slang REPORT the bad access |
| `v162_7_order.sv` | the bad call FIRST, SECOND, in the MIDDLE of six, and TWICE from two different type parameters; the compound as the only good operand; exactly two compounds; the corpus witness with its operands in REVERSE order |
| `v162_8_pkgfold.sv` | the `depth > 0` package-parameter refusal and the AST-FORCE its `getPackage(...)->find(...)` performs: a package the design NEVER otherwise references, reached only through that lookup; a package FUNCTION, a package LOCALPARAM and a package TYPE at depth > 0 (not parameters — the refusal must not fire); a CLASS whose name is a plausible qualifier; a TYPE-PARAMETER qualifier; the same package used at depth 0 and depth > 0 in ONE concatenation |
| `v162_9_exotic.sv` | a replication COUNT that is itself a ternary and a binary op; a replication whose BODY is a replication; a compound under a MACRO argument and a MACRO-BUILT concatenation; `$bits`, a queue method, `inside`, an assignment-pattern-shaped arm; and the two parenting corners — a literal directly under a nested concat directly under a ternary, and a literal count directly under a replication nested in a ternary |

### THE RESULT — `GRID.cmp.r10v162.txt`, `GRID.dist.r10v162.txt`, `LOST.r10v162.txt`

```
arm                 view  pristine cmp   patched cmp     order-blind distance
v162_1_badinside    def   133 / 1 head   0 / 0 CMP_EQUAL   564 ->    6  TOWARD
v162_1_badinside    elab  137 / 1        0 / 0 CMP_EQUAL  1028 ->  216  TOWARD
v162_2_shapes       def   339 / 1       77 / 1            1251 ->  831  TOWARD
v162_2_shapes       elab  355 / 1       85 / 1            2253 -> 1743  TOWARD
v162_3_ctx          def   159 / 1        0 / 0 CMP_EQUAL  1043 ->   14  TOWARD
v162_3_ctx          elab  175 / 1        0 / 0 CMP_EQUAL  2303 ->  473  TOWARD
v162_4_home         def   159 / 1       17 / 1             625 ->  201  TOWARD
v162_4_home         elab  159 / 1     1191 / 1            1171 ->  352  TOWARD
v162_5_stress       def    79 / 1       79 / 1            2480 ->  973  TOWARD
v162_5_stress       elab   87 / 1       87 / 1            3894 -> 1571  TOWARD
v162_6_reported     both   SLANG_REJECT rc=3 on BOTH binaries — unchanged
v162_7_order        def   147 / 1        0 / 0 CMP_EQUAL   652 ->   12  TOWARD
v162_7_order        elab  163 / 1        0 / 0 CMP_EQUAL  1418 ->  222  TOWARD
v162_8_pkgfold      def    28 / 1       28 / 1             719 ->  469  TOWARD
v162_8_pkgfold      elab   28 / 1       28 / 1            1507 -> 1031  TOWARD
v162_9_exotic       def   177 / 1      115 / 1             952 ->  268  TOWARD
v162_9_exotic       elab  189 / 1      123 / 1            1904 ->  746  TOWARD
```

**Three of the nine arms — including the one that puts the bad call INSIDE the
ternary, the one that varies OPERAND ORDER, and the one that sweeps every
CONTEXT — go to `CMP_EQUAL` in BOTH views.** Every arm moves TOWARD golden in
order-blind whole-dump distance; **none moves away**; every rc is identical on
the two binaries.

### THE STRICT AWAY TEST — `lostv162.sh`, `LOST.r10v162.txt`

`LOST` counts normalised dump lines that **golden has, our PRISTINE matched,
and our PATCHED no longer matches** — a line that was right and became wrong.

```
arm                 def LOST   elab LOST
v162_1_badinside        0          0
v162_2_shapes           0          0
v162_3_ctx              0          0
v162_4_home             0          0
v162_5_stress           0          0
v162_7_order            0          0
v162_8_pkgfold          0          0
v162_9_exotic           0          0
```

**LOST = 0 on every arm and every view.** The `NEWONLYOURS` column is non-zero
only in the ELAB view, and it is a dump-INDENT artifact, not an object: arms 1,
3 and 7 carry `NEWONLYOURS` 29, 84 and 31 and are nonetheless judged
**CMP_EQUAL** by the official `uhdm-cmp` in that same view.

### THE HEADS THAT REMAIN, EACH NAMED

* `v162_2_shapes` 77/85 — head is `bdB`, a **BARE call** (golden mints a
  `func_call`): the implementer's declared R1, abstained by design.
* `v162_5_stress` 79/87, **identical on both binaries** — head is `d01`, the
  18-nested-paren cell, past the unwrap bound: abstained, and the abstention is
  silent and rc-neutral. The arm still moved 2480 → 973 TOWARD from its other
  cells.
* `v162_8_pkgfold` 28/28, **identical on both binaries** — head is golden's
  CONSTANT-FOLD of `Untouched8::NEVER` against our `ref_obj`: R-V1, pre-existing
  on the accepted twin, untouched in both directions.
* `v162_9_exotic` 115/123 — head is the `$bits`/system-call operand: R1.
* `v162_4_home` def 17 — head is golden's `logic_net work@Top_Home4.hold`,
  **absent from BOTH our databases** (pre-existing, merely unmasked).
* `v162_4_home` elab 1191 — head is our ONLY-OURS `class_defn
  Home4_pkg::Lodge4` under `LHS: <null>`. **PROVEN pre-existing**: the same arm
  with every bad concatenation deleted (`/tmp/v162_ctl_home_nobad.sv`) reports
  the SAME head object at 1055 lines, identically on both binaries. A cmp line
  count is head-object DEPTH, not distance (RESUME §7) — the arm's distance to
  golden FELL 1171 → 352.

---

## 3. THE EARLIER-PASS ARMS THAT MOVE — ALL TEN RE-JUDGED AGAINST GOLDEN

The wide boundary (`LISTED=4601 PROCESSED=4601 PRODUCED_DBS=4448
MOVED_ARMS=24 RC_DIFFS=0`) names 24 arms: 7 are the implementer's own `g162_*`,
7 are this verifier's own, and **10 are r10uvm160 / r10v160 cells of § 160's own
R1 residue**. Every one was rebuilt against Surelog's golden
(`BOUNDMOVERS.dist.r10v162.txt`, `BOUNDMOVERS.lost.r10v162.txt`):

```
arm                            def cmp        elab cmp       def dist      elab dist
r10uvm160repro/g160_e_edge      89 -> 0 EQUAL  93 -> 0 EQUAL  185 -> 110    391 -> 257
r10v160repro/cells/d10_repl     77 -> 0 EQUAL  81 -> 0 EQUAL   42 ->  10     80 ->  22
r10v160repro/cells/o04_paren    55 -> 0 EQUAL  63 -> 0 EQUAL  207 -> 186    273 -> 213
r10v160repro/cells/o05_ternary 121 -> 0 EQUAL 129 -> 0 EQUAL  240 -> 186    322 -> 213
r10v160repro/cells/o06_nestcat  77 -> 0 EQUAL  81 -> 0 EQUAL  218 -> 186    271 -> 213
r10v160repro/cells/o08_repl     87 -> 0 EQUAL  91 -> 0 EQUAL  223 -> 186    281 -> 213
r10v160repro/cells/o10_binary   77 -> 0 EQUAL  85 -> 0 EQUAL  218 -> 186    291 -> 213
r10v160repro/cells/y10_nestgood 101 -> 0 EQUAL 105 -> 0 EQUAL 230 -> 186    287 -> 213
r10uvm160repro/g160_b_operand   77 -> 77       85 -> 85       260 -> 150    524 -> 339
r10v160repro/arms/v160_d_ctx    77 -> 17       81 -> 17       290 -> 214    585 -> 453
```

**Eight go to `CMP_EQUAL`; the other two move TOWARD.** `LOST = 0` and
`NEWONLYOURS = 0` on all twenty arm-views. `g160_b_operand`'s 260 → 150 and
`v160_d_ctx`'s 290 → 214 / 585 → 453 reproduce the implementer's numbers
exactly. **No earlier-pass arm moves away.**

---

## 4. THE THIRD BYTE MOVER — A STRONGER ATTRIBUTION THAN THE IMPLEMENTER'S

`default/Scoreboard` moved bytes in this verifier's sweeps too — but with the
faces SWAPPED (patched `86a9fa4fd934`, pristine `eb2a3e30c551`, the exact
reverse of the implementer's run). Run SERIALLY from the test's own directory,
three times per binary:

```
pristine -> efaba1fecd2b   86a9fa4fd934   0cf9f54ec324
patched  -> 86a9fa4fd934   86a9fa4fd934   eb2a3e30c551
```

All six databases are **order-blind IDENTICAL** (0 content lines apart; the only
diff line is the dump's own filename header). The **PRISTINE binary alone
produces three distinct hashes**, so a Scoreboard hash change cannot be
attributed to the patch at all. The corpus census over OP / ASGN / ARG / COND /
HP on that row scores **TOWARD 0 / WRONG 0 / AWAY 0 / ONLY-A 0**, and the
pristine-vs-patched order-blind whole-dump diff is **0 lines added, 0 deleted**
(94 raw).

**This CORRECTS `r10uvm162repro/README.md` §9**, which reports the pristine
null sweep as byte-stable `86a9fa4fd934` three times out of three. It is not;
it was a lucky draw. The correction strengthens the conclusion rather than
weakening it — RESUME §9's "up to four pristine hashes seen" is what this
measures — but the README's sentence should not be carried forward as written.

---

## 5. THE CODE, READ ADVERSARIALLY

The change is **monotone**: it only widens the set of operand shapes admitted
inside a concatenation slang already emptied, and the one narrowing it adds (the
package-parameter refusal) is gated on `depth > 0`, which no pre-existing call
site can reach — every existing caller enters at `depth = 0` with `direct =
true`, and the atomic shapes' code paths are byte-for-byte what they were.
`badConcatParentConst162`'s `direct` branch is a literal transcription of the
code it replaced. This is why 4577 of the 4601 boundary arms are byte-identical.

Three specific failure modes were checked in the source and found closed:

1. **A SHORT operand vector** (worse than abstaining, because
   `operation::Compare` reads the vector SIZE first) would need a sub-operand
   that passes the shape pass and then returns null during the mint pass. Every
   branch's shape test *is* its mint test: shapes (1)/(1b)/(1c) re-run the same
   string predicate; (2)/(3) call `emitDroppedArg14`, which has no null return;
   (4) calls `emitDroppedCall14`, whose ONLY null return re-runs the very
   `droppedCallShape14` the shape pass asked (the second `return nullptr` in
   that region belongs to `findDroppedCallAt14`, a different function); (5)
   re-runs `splitScopedName12` and the same package test. **No short-vector
   path exists.**
2. **Unbounded recursion** — the paren unwrap is capped at 16 iterations and the
   shape recursion at `depth > 16`; past either bound the operand falls through
   every test and abstains, which `v162_5_stress.sv` cells `d01`, `d03` and
   `d05` exercise and measure as identical on both binaries.
3. **Side effects in the recursion** — `emitDroppedArg14` uses its `parent`
   only for `VpiParent` and touches `netMap` only when `bind` is true (it is
   passed `false`); `classArgBindDepth12` is saved and restored around the mint
   loop, which the recursion sits inside; no branch calls `noteUnsupportedAt`,
   so the abstention cannot turn a row into `SLANG_REJECT`.

**The one residual risk this verifier names**: the `depth > 0` refusal calls
`comp.getPackage(first)->find(last)`, a NAME LOOKUP that elaborates that
package's scope from inside DEF emission — RESUME §9's "do not force AST binding
during the DEF phase" window. It is reachable only from inside a rejected
concatenation's new recursion, and `arms/v162_8_pkgfold.sv` drives it against a
package the design never otherwise references, with the qualifier being a
parameter, a localparam, a function, a type, a class and a type parameter in
turn: **identical rc on both binaries, LOST 0, TOWARD in both views**, and the
4601-arm boundary reports `RC_DIFFS=0`. Recorded as R-V2 below rather than
dismissed.

### THE PARENTING CORNER, CHECKED CELL BY CELL

`v162_9_exotic.sv` cell `x12` — `{"[", u=="" ? {"a", 7} : "b", "]", <bad>}` —
is **byte-identical to golden** in the patched database: the nested
concatenation's own direct literals `"a"` and `7` carry NO `vpiParent`, while
the ternary's `"b"` and the `==`'s `""` both do. The `direct` flag propagates
correctly through ternary → nested concat → literal, and through
replication-count → literal.

---

## 6. RESIDUES, RANKED

| | |
|---|---|
| **R-V1** (implementer's, confirmed) | golden CONSTANT-FOLDS `<package>::<parameter>` where our BOUND path emits a `ref_obj`. Measured here on the ACCEPTED twin (`v162_8_pkgfold.sv` `g01`/`g02`), so **pre-existing, not the recovery's**. Costs 0 corpus cells. Closing it is § `stampFoldedPkgParamTs`'s family. |
| **R-V2** (this verifier's, new) | the refusal's `getPackage(...)->find(...)` is an AST-FORCING lookup performed during DEF emission. Zero measured effect (rc-identical over 4601 boundary arms and a dedicated arm), but it is the only new call into slang's symbol tables this pass adds, and a future pass that widens the refusal beyond `depth > 0` should re-measure it. |
| **R1** (implementer's, confirmed) | four operand shapes still unmodelled — a BARE call, a UNARY operator, a call whose actual is a call, a SIZED/BASED/REAL literal — plus a SYSTEM call, an INDEX SELECT, a CAST and `this.<member>`. Every refusal measured here prints an EMPTY operand vector (`bd=4 lines`), never a wrong mint. Corpus cost **0** cells (`PRED-TOWARD 2` is the entire population, and both are recovered). |
| **R-V3** (this verifier's, new, cosmetic) | the recursion's recovered objects appear at dump INDENTS golden does not match in the ELAB view (`NEWONLYOURS` 7–84 lines per arm). Invisible to the judge — three arms carrying it are `CMP_EQUAL` — and it is the same class of dump-label artifact as the corpus row's five `\|vpiSize:64` / `\|vpiActual:` lines. |
| **R0** (implementer's, confirmed PRE-EXISTING) | the new head is `LHS: <null>` naming our `io_decl (alias_name)`; the edge is `ref_obj::Actual_group` at `uvm_pkg.sv:14098:35`, where golden leaves the argument ref BARE and we bind it to the enclosing function's `io_decl`. **This verifier confirmed the identical `vpiActual` edge in the PRISTINE database at the same line**, so the next pass inherits a pre-existing over-bind, not one this pass created. |

---

## 7. FILE MAP

| file | what it is |
|---|---|
| `arms/v162_1_badinside.sv` … `arms/v162_9_exotic.sv` | the nine adversarial arms |
| `gridv162.sh` | `r10uvm162repro/grid162.sh`, copied unchanged — three databases per view, `cmds.txt` with binary PATH and rc, official `uhdm-cmp` on both of ours |
| `lostv162.sh` | THE STRICT AWAY TEST: golden lines pristine matched and patched no longer matches (LOST), the mirror (GAINED), and freshly-minted only-ours lines |
| `GRID.cmp.r10v162.txt`, `GRID.dist.r10v162.txt`, `LOST.r10v162.txt` | the arm measurements |
| `BOUNDMOVERS.dist.r10v162.txt`, `BOUNDMOVERS.lost.r10v162.txt` | the ten earlier-pass boundary movers, re-judged against golden |
| `BOUNDARY.r10v162.txt` | the 4601-arm wide boundary summary and its mover list |
| `CENSUS.r10v162.txt` | the corpus census over the three moved databases |
| `GATES.r10v162.txt` | the whole gate battery, reproduced on this verifier's own binaries and sweeps |
| `head_pris_BuildUVMPkg.default.cmp`, `head_pat_BuildUVMPkg.default.cmp` | this verifier's own official `uhdm-cmp` head logs, 321 → 29 |
