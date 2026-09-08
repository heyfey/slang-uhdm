# r10uvm219 — § `hoistedThisRidesTheForwardedBlock219` — **THE IMPLICIT `this` WIRE IS A *FORWARDED* LATE-BINDING MINT, AND SURELOG EMITS EVERY FORWARDED MINT AHEAD OF EVERY NAME THE MODULE'S OWN BODY COULD NOT RESOLVE** — SeqDriver ×2 fell from **32 cmp lines / one head to ZERO**, and **both rows CONVERT to `CMP_EQUAL`**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY** and **NOT EDITED** — this pass converts two
rows and the master promotes them, with the rows quoted in § 4. `GOLDEN_DEFER`
stayed unset. The four slang-fenced tests were never dispatched by any driver
here; the corpus predictor walks a sweep workdir that contains them, so
`scrub219.sh` redacts their names out of every artifact — reading the fence list
out of `canaudit.sh` rather than spelling it — and `canaudit.sh`'s own
`FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `2bdb9bd0` |
| pristine binary | md5 `3445d7b3db309c5cea303dfd69c9241c`, built `-j 2` from this pass's OWN worktree at a clean `2bdb9bd0` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `88aa8f649243647c9eaeb7f333ff7a80`, frozen `chmod 555`. The patch applied to a **FRESH `2bdb9bd0` worktree** (`git apply -3`, four files applied cleanly, 0 conflict markers) and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on — and that fresh rebuild passes `check_goldens.sh` 23/0 too. |
| production surface | `src/TypeEmit.cpp`, `src/ModuleEmit.cpp`, `include/UhdmExporter.h` and three comment lines in `src/UhdmExporter.cpp` — **+91 / −4 lines, of which 63 are the decoded comment**. One `push_back` becomes an `insert` at a recorded index; not one object is minted, deleted, re-parented or re-named, and no new object kind exists. |
| probe surface | `tools/probe/r10uvm219repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head, RE-MEASURED on this pass's own pristine build FIRST (question 1) | **SeqDriver ×2, 32 cmp lines / ONE head each** — exactly r10uvm217's R0, reproduced before a line was written. Every other named row at BASE: SimpleUVM ×2 **0**, Scoreboard/default **0**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**, MiniAmiq ×2 **29/1** (the sister pass's row, untouched). |
| THE OBJECT, ITS OWNER AND ITS FAILING FIELD (question 1) | one `logic_net` pair at **index 223 of the 224-entry `Nets()` vector of the DEF-view `module_inst work@top_tb`** (`testbench.sv:210`). Golden's is `work@top_tb.top_tb` (`234:24`, the `$dumpvars(0, top_tb)` scope-name mint); ours was `work@top_tb.this` (`152:45`). The vector overload of `BaseClass::SafeCompare` (`BaseClass.h:200-224`) walks index by index and `nets::Compare` compares **`VpiName`** — that is the field. |
| the population, both position tables (question 2) | `VECTORS.SeqDriver.r10uvm219.txt`. Both vectors are 224 long; positions 0–65 are the two package clones r10uvm217 delivered and agree exactly; 66–223 are the 158-wire implicit block, the **SAME MULTISET IN A DIFFERENT ORDER** on the two sides. Golden carries `this` at index **70** and `top_tb` LAST; we carried `this` LAST and `top_tb` second to last. |
| golden's mint order, decoded from the WRITER, not guessed (question 2) | `UhdmWriter::lateBinding` (`UhdmWriter.cpp:3294`) walks **one vector**, `mod->getLateBinding()`, and pushes a fresh `logic_net` per name it cannot resolve (`:3982-4004`). `CompileHelper::importPackage` splices the imported package's WHOLE late-binding list into the importing scope's (`CompileHelper.cpp:192`), and `CompileModule::collectObjects_` runs every `paPackage_import_item` in the FUNCTION collect pass (`:566-583`, `:1055-1090`) — before the module's own item bodies compile and reach `component->needLateBinding` (`CompileExpression.cpp:1836…`). So the order is **`[every forwarded package ref][the module's own refs]`**, and a bare `this` inside a hoisted class-method body is a FORWARDED ref. § 3, `DECODE.r10uvm219.txt`. |
| the head after | **SeqDriver ×2: 32 → 0 cmp lines, 0 heads, `uhdm-cmp` rc 0.** Index 223 is now golden's `top_tb`. `head_pat_SeqDriver.*.cmp` are the tool's own empty output. |
| THE CONVERSION | **`SeqDriver,default` and `SeqDriver,testflags` go `CMP_NOTEQUAL` → `CMP_EQUAL`.** 475/6 + 469/6 → **476/5 + 470/5**. The rows are quoted in § 4; `results/golden_surelog.csv` was NOT edited. |
| the golden grid (question 3) | **7 arms × 2 views = 14 arm-views, one REAL Surelog golden each, 0 NO-DATABASE, 0 nonzero rcs, golden-vs-golden CALIBRATION null in all 14.** Arms A, B, C and D go to **POSDIFF 0 — golden's listing exactly, in both views**; arms E and F, the must-stay controls, are **cell-for-cell identical on the two binaries**; arm G is decoded in § 5. The ORDER-ONLY scorer reads the whole grid **12 ORDER-WRONG cells → 2**, with **0 cells going the other way**. § 5. |
| the a-priori prediction (question 5) | written from PRISTINE databases alone, BEFORE the patched sweep: **4 candidates over 956 surelog databases** (SeqDriver ×2, SimpleUVM ×2) and **0 over 1358 uhdm2rtlil databases**. § 6. |
| byte movers | **5 / 956** surelog. FOUR are the predicted set. The fifth is `Scoreboard`/default, **THE COIN**, attributed four ways — including a calibration in which the **PRISTINE binary alone produced three distinct md5s over four runs**, one of them exactly the "patched" hash. **0 / 1358** uhdm2rtlil, as predicted. SELFCHECK controls fire at 955/956 and 678/679 ×2. § 6. |
| the corpus census (question 4) | nine UVM databases × both modes, **16 comparable row-modes**, each against **its OWN mode's golden**, golden-vs-golden CALIBRATED FIRST (null in all 16). **SeqDriver ×2: AGREE 206 → 207, POSDIFF 158 → 157, ONLY-GOLDEN 0, ONLY-OURS 0 — MOVED-WRONG 0 / AWAY 0.** SimpleUVM ×2 score **cell-for-cell identical** on the two binaries (the wire moves between two masked interior slots). Every other row-mode identical and byte-identical. § 7. |
| gates | goldens **23 PASS / 0 FAIL on BOTH binaries**, `/bin/false` control 0/23; uhdm2rtlil **679 / 50 / 2 in BOTH modes**, `ct8rows` PASS ×3, `byteverify` **0/1358**; surelog **476/5 + 470/5** with `ct8rows` showing **exactly the two converted rows** plus the recorded Earlgrey dump-column flake; wide boundary **LISTED 5571 = PROCESSED 5571, RC_DIFFS 0**, 8 moved arms of which 5 are this pass's own positive control and 3 are the static-address false mover; all 20 protected database pins **SAME**; canaudit **FENCE-BREACH 0**. § 8. |

---

## 1. THE HEAD, RE-MEASURED FIRST

The brief says the head is UNKNOWN after the collapse. It was re-measured before
any code was read, on this pass's own pristine binary — built `-j 2` from a
clean `2bdb9bd0` worktree and **byte-identical** to the main tree's binary at
that commit (`3445d7b3`).

```
SeqDriver ×2 32/1   ·  SimpleUVM ×2 0/0  ·  Scoreboard/default 0/0
MiniAmiq ×2 29/1    ·  BuildUVMPkg ×2 0/0 ·  Earlgrey_0_1 ×2 0/0 · Rggen/default 0/0
```

Each row is scored against **its own mode's golden**, read out of that row's own
`cmds.txt` (a test's default and testflags goldens are different cache entries —
RESUME §9). `MiniAmiq`'s 29/1 is the sister pass's row and is untouched here:
its databases are byte-identical on the two binaries.

The SeqDriver head (`head_pris_SeqDriver.*.cmp`, both modes byte-identical to
each other) is the SINGULAR arm of `BaseClass::SafeCompare` on a pair that is
present on both sides:

```
LHS: logic_net: (work@top_tb.top_tb)  line:234:24  |vpiName:top_tb  |vpiNetType:1
RHS: logic_net: (work@top_tb.this)    line:152:45  |vpiName:this    |vpiNetType:1
```

Its owner is the **DEF-view** `module_inst work@top_tb` — the `AllModules`
shell, `VpiName` empty — and the field that separates the pair is **`VpiName`**,
which `nets::Compare` reads outright (`DECODE.r10uvm219.txt` carries the
generated body). The elaborated `work@top_tb.work@top_tb` carries no `Nets()` at
all (`NULLVEC` on both sides), so this is a one-vector question.

## 2. QUESTION (2) — THE POPULATION, AND GOLDEN'S MINT ORDER READ OFF THE WRITER

**Both position tables** are in `VECTORS.SeqDriver.r10uvm219.txt`, printed by
`ct219net` (r10uvm217's `ct217net` plus the element's SOURCE SPAN, which the
judge does not read but which is the only way to see WHICH reference minted a
wire).

```
              size   [0..65]                    [66..223]              index of `this`
golden        224    the two package clones     158 implicit wires     70     (span 902:36)
pristine      224    the same 66, agreeing      the same 158, permuted 223    (span 152:45)
patched       224    unchanged                  the same 158, permuted 66     (span 152:45)
                                                  LAST = top_tb 234:24
```

**Golden's mint order is not guessed; it is the writer's.**
`UhdmWriter::lateBinding` (`src/DesignCompile/UhdmWriter.cpp:3294`) iterates
`mod->getLateBinding()` — a plain `std::vector<ref_obj*>`
(`DesignComponent.h:189-194`) — skips any ref already bound, and, when every
lookup fails, mints a `logic_net` and `push_back`s it into the instance's
`Nets()` (`:3982-4004`). Two things fill that vector, in this order:

1. **the forwarded refs.** `CompileHelper::importPackage` copies the imported
   package's ENTIRE `getLateBinding()` into the importing scope's own
   (`CompileHelper.cpp:192`), and `CompileModule::collectObjects_` calls it for
   every `paPackage_import_item` during the **FUNCTION** collect pass — the
   file-local imports in a block at the top (`:566-583`, `:1055-1069`) and the
   module-scope ones in the item walk (`:600-604`, `:1085-1089`);
2. **the module's own refs**, added later, while the module's item bodies are
   compiled and `CompileExpression` cannot resolve a name
   (`CompileExpression.cpp:1836/2836/2992/5778…`).

So golden's implicit block is `[forwarded…][the module's own…]`, and the
`$dumpvars(0, top_tb)` scope name — a name only the module's own `initial`
mentions — is necessarily **LAST**.

**Where our `this` came from.** `§ thisImplicitNetBoth38`
(`src/TypeEmit.cpp`) mints exactly one `logic_net` named `this` per design, and
it runs **DESIGN-FINAL** (`UhdmExporter.cpp`, pinned last) because its predicate
is which listings hold the routine. It appended the wire to the end of the top
module's `Nets()` — after `bindHoistedClassPropRefs`' forwarded block, after
`mintUnitEnumNets`, and after the process emitter's `$dumpvars` mint. That is
the whole defect: the wire is a forwarded mint wearing a design-final
timestamp.

## 3. QUESTION (3) — THE GOLDEN GRID

`grid219.sh` + `grid219/`, seven arms × two views (`-parse -d coveruhdm
-nobuiltin -nocache`, then again with `-elabuhdm`), one REAL Surelog golden per
arm-view built by the canonical `~/git-repos/Surelog/build/bin/surelog` that
`scripts/verify_golden.py` itself names, **every rc recorded**, both binaries'
databases built in every cell. The per-arm `uhdm-cmp` verdict is RECORDED and is
**NOT** the scorer (r10uvm210's caution: `-nobuiltin` makes golden's
`AllPackages` one entry shorter than ours, so every arm's head is that vector
mismatch — visible as `heads_pris=1 heads_pat=1` on every line of
`GRID.r10uvm219.txt`). The scorer is the position-keyed listing census
(`ct219net` + `cen219.py`), golden-vs-golden CALIBRATED FIRST (**null in all
14**), plus the ORDER-ONLY scorer `subseq219.py` (§ 5).

```
-- 14 arm-views   NO-DATABASE 0   CALIB non-null 0   nonzero rcs 0
```

| arm | what it varies | verdict |
|---|---|---|
| **A** `a_order` | **THE LAW.** A package whose out-of-body method leaves a class PROPERTY and a bare `this` unresolved, imported by a module that also has an unbindable name of its own | golden `[p0_own, clk, c0_prop@10:5, this@11:20, ma@22:24]`; pristine put `this` after `ma`. **POSDIFF 2 → 0 in BOTH views — golden's listing exactly** |
| **B** `b_interleave` | **THE ORDER WITHIN THE BLOCK.** Three methods, one hoisted name each, the `this` in the MIDDLE one | golden `[pa@11:13, pb@14:13, this@14:37, pc@17:13, ma@24:24]`. Pristine POSDIFF 3, patched **0 in both views**: the wire lands BETWEEN `pb` and `pc`, not at the end of the block |
| **C** `c_thisfirst` | **THE `this` AT THE FRONT.** Its reference precedes every other forwarded one | pristine POSDIFF 4, patched **0 in both views** — the arm that distinguishes "append to the block" from "sort into it" |
| **D** `d_ownmulti` | **TWO NAMES THE MODULE'S OWN BODY CANNOT BIND** (a `$dumpvars` on itself and one on a child instance) plus a forwarded block | pristine POSDIFF 3, patched **0 in both views**: every module-own mint stays after the whole forwarded block |
| **E** `e_nothis` | **MUST-STAY.** Arm A's shape with NO bare `this` anywhere | **PATCHED IDENTICAL TO PRISTINE** in both views (AGREE 7, POSDIFF 0). Correctly **ABSENT** from the wide boundary's moved list |
| **F** `f_muststay` | **MUST-STAY, WIDER.** r10uvm217 arm F's § 203 shape, with a bare `this` in a class **no module lists** | **PATCHED IDENTICAL TO PRISTINE** in both views (AGREE 8, POSDIFF 0) — § 38's predicate correctly declines. Also ABSENT from the boundary's moved list |
| **G** `g_transitive` | **THE CONJUNCT WITH § `transitiveImportRidesTheHoist217`** — a two-hop chain whose DEEP package holds the class, plus a ONE-HOP CONTROL in the same file | decoded in § 5; the position census falls one cell and the ORDER-ONLY census rises. Both effects are r10uvm217's R2 and a NEW residue (R2 here), both **identical on the two binaries** |

## 4. THE LAW, AND THE CONVERSION

> **§ `hoistedThisRidesTheForwardedBlock219`.** The implicit wire a bare `this`
> in a hoisted class-method body mints is a **FORWARDED** late-binding mint, not
> a design-final one. Surelog's module late-binding pool is
> `[every forwarded package ref][the module's own refs]`, minted in that one
> order, so the `this` wire lands **inside the forwarded block** — sorted there
> by its anchor's source span, the same order the forwarded stream itself
> carries — and **never after a wire the module's own body minted**.

The implementation is the law made literal and nothing else:
`bindHoistedClassPropRefs`' call site records the half-open `Nets()` span
`[begin, end)` it just minted for that module (a bookmark; nothing is minted or
reordered there), and § 38 `insert`s at the position inside that span where the
anchor's `(file, line, column)` sorts, falling back to `end` and, with no record
at all, to the old `push_back`.

**THE ROWS CONVERT.** `results/golden_surelog.csv` was **NOT** edited; the
master promotes these two rows:

```
old  SeqDriver,default,CMP_NOTEQUAL,decompile:,,
new  SeqDriver,default,CMP_EQUAL,,,differ
old  SeqDriver,testflags,CMP_NOTEQUAL,decompile:,,
new  SeqDriver,testflags,CMP_EQUAL,,,differ
```

`475 CMP_EQUAL / 6 CMP_NOTEQUAL` + `469 / 6` → **`476 / 5` + `470 / 5`**.
`ct8rows` patched-vs-COMMITTED-baseline reports exactly these two rows plus the
recorded `Earlgrey_0_1/testflags` uhdm-dump INFORMATIONAL column flake (status
`CMP_EQUAL` on both sides, and the two databases md5-identical at
`92bf7b7facdc` — `protdb219.sh`).

## 5. ARM G, AND THE ORDER-ONLY SCORER

Arm G's deep module scores **AGREE 14 → 13, POSDIFF 2 → 3**. That reads like a
regression and is not one; the arm's raw listings say why.

```
golden   gg_deep  [g0_own, g1_own, gg_clk, g0_prop@14:5, this@15:20, gg_deep@27:24]
pristine gg_deep  [g0_own, g1_own, gg_clk,               gg_deep@27:24, this@15:20]
patched  gg_deep  [g0_own, g1_own, gg_clk,               this@15:20, gg_deep@27:24]
```

`g0_prop` is **missing on both binaries** — that is r10uvm217's R2,
`bindHoistedClassPropRefs` tests the DIRECT import set and does not reach a
two-hop package's class property. One missing element shifts every later index,
so the pristine listing "agreed" at index 4 by two errors cancelling, and the
patched one — which is golden's sequence with one element deleted — does not.

Because a position census cannot read the order of a listing with a hole, this
pass adds `subseq219.py`, an **ORDER-ONLY** scorer: is our name sequence a
SUBSEQUENCE of golden's, i.e. do we emit no pair of elements in the wrong
relative order? It is blind to what is missing (that is `cen219.py`'s
`ONLY-GOLDEN` column, which this does not replace).

```
over the 14 grid arm-views:   PRISTINE ORDER-WRONG 12   PATCHED ORDER-WRONG 2
                              arm-views that gained an order error: 0
```

The two that remain are arm G's ONE-HOP CONTROL cell `gg_near`, on **both**
binaries, and they are a different residue again — see R2 below.

## 6. QUESTIONS (5) AND THE BYTE MOVERS

**The prediction, written from PRISTINE databases alone, before the patched
sweep ran.** `pred219` asks one question of our own database: does any
`AllModules` `module_inst` list a typespec-less `logic_net` named `this` with
`vpiNetType 1`? A database with none cannot move under a law that only
re-positions that wire, so the answer is an UPPER BOUND.

```
surelog:     rows scanned=956   CLEAN=952   CANDIDATES=4
  SimpleUVM default   work@top     idx=224 size=225 after=0
  SeqDriver default   work@top_tb  idx=223 size=224 after=0
  SeqDriver testflags work@top_tb  idx=223 size=224 after=0
  SimpleUVM testflags work@top     idx=224 size=225 after=0
uhdm2rtlil:  rows scanned=1358  CLEAN=1358  CANDIDATES=0
```

**PREDICTED MOVER SET: SeqDriver ×2 and SimpleUVM ×2, and nothing else.**

```
byteverify surelog:     MOVERS 5 / 956     (SELFCHECK control 955/956)
byteverify uhdm2rtlil:  MOVERS 0 / 1358    (SELFCHECK controls 678/679 in each mode)
```

The four predicted rows moved. **The fifth is `Scoreboard`/default, THE COIN,**
and it is attributed four independent ways, none of them to this law:

* **ORDER-BLIND** (both dumps path-normalised and sorted, RESUME §6): all five
  moved rows score **ADDED 0 / REMOVED 0**. This pass changes ORDER and nothing
  else, so the order-blind test cannot separate the law from the coin here and
  the ORDERED diff has to.
* **the ORDERED diff** of Scoreboard/default is **170 lines, every one of them a
  `svunit_pkg` `|vpiTaskFunc` / `function` / `task` entry and ZERO of them a
  `logic_net` or a `vpiNet`** — the documented `svunit_pkg` `vpiTaskFunc` list
  order flip.
* **`pred219` calls Scoreboard/default CLEAN**: its pristine database holds no
  `logic_net` named `this` at all, so § 38 minted nothing there.
* **THE CALIBRATION.** The PRISTINE binary alone, run four times on the row's
  own command line, produced **three distinct md5 prefixes**, one of which is
  exactly the "patched" hash, and none of which is the stored control:
  `61ee9cb4f6c1 · 2d2760c40920 · 61ee9cb4f6c1 · 89c1b4e51d8e`, control
  `38374ebcc2cb`, patched sweep `61ee9cb4f6c1`. RESUME §9's "up to four pristine
  hashes seen".

## 7. QUESTION (4) — THE CORPUS CENSUS, BOTH CORPORA × BOTH MODES

`cenrows219.sh` + `ct219net` + `cen219.py` over nine UVM databases × both modes
— **16 comparable row-modes**, each scored against **that row's OWN mode's
golden**, read out of that row's OWN `cmds.txt`. Two SKIP-NOFILE row-modes
(`Scoreboard`/testflags and `Rggen`/testflags, which have no database in this
workdir) are COUNTED, not dropped. `CENSUS.r10uvm219.txt`.

```
row-mode              CALIB    PRISTINE                     PATCHED                      bytes
SeqDriver   ×2        null     AGREE 206 POSDIFF 158        AGREE 207 POSDIFF 157        MOVED
SimpleUVM   ×2        null     AGREE 190 POSDIFF 157        (identical)                  MOVED
Scoreboard  /default  null     AGREE  55 POSDIFF 0          (identical)                  MOVED (the coin)
MiniAmiq    ×2        null     AGREE  66 ONLY-G 66          (identical)                  SAME
BuildUVMPkg ×2        null     AGREE  26 everything else 0  (identical)                  SAME
ApbSlave    ×2        null     AGREE  67 everything else 0  (identical)                  SAME
ClassExtends×2        null     (no listing cells)           (identical)                  SAME
Earlgrey_0_1×2        null     3374 cells, AGREE 32756      (identical)                  SAME
Rggen       /default  null     116 cells, AGREE 1164        (identical)                  SAME
-- ROWS=16 SKIP-NOFILE=2 UNKNOWN-NAME=0
-- MOVED-WRONG 0   AWAY 0   ONLY-OURS 0 before and after on every row
```

`Earlgrey_0_1`'s 3374 calibration cells and 32757 golden-vs-golden agreements
are what make its "identical" mean something. **`SimpleUVM` is a byte mover with
an identical census score on purpose:** its `top` module has no `$dumpvars`, so
it has no module-own late-binding mint at all, and the law only relocates the
`this` wire from one masked interior slot to another. Golden's last net there is
`m_check_on_read`; ours was `this` and is now `p`, and BOTH are masked, which is
why the row was and stays `CMP_EQUAL` at **0 cmp lines / 0 heads / rc 0** on both
binaries.

**Why 157 positions of SeqDriver's block still differ and the judge does not
care.** `logic_net::Compare`'s first statement is
`if (!context->m_visited.insert(this).second) return r;`, and `design::Compare`
walks `AllClasses` before `AllModules`, so every implicit wire a class-method
`ref_obj::Actual_group` already reached short-circuits to 0 whatever it is paired
with. r10uvm217 measured that 157 of the 158 are covered; the one that is not is
the `$dumpvars` scope name, which nothing in a class body references — and that
is the position this law fixes.

## 8. QUESTION (6) — THE GATES AND THE BOUNDARY

Full transcript in `GATES.r10uvm219.txt`.

```
goldens          pristine 23/0   patched 23/0   /bin/false control 0/23
uhdm2rtlil       679 / 50 / 2 in BOTH modes; ct8rows PASS vs the committed baseline
                 and vs both rotation controls; byteverify 0/1358
                 every one of the 1458 cmds.txt slang lines names /tmp/r10uvm219_pat.bin
surelog          476/5 default + 470/5 testflags; ct8rows shows exactly the two
                 converted rows + the recorded Earlgrey dump-column flake
wide boundary    LISTED 5571 = PROCESSED 5571, PRODUCED_DBS 5375, RC_DIFFS 0
                 MOVED_ARMS 8: 5 are this pass's own grid arms (the positive control
                 that proves the gate can see) and 3 are the static-address false mover
armscore219      16 arm-views re-scored against REAL Surelog goldens, 0 NOT-SCORED:
                 TO-GOLDEN 8, UNCHANGED 6, AWAY 0; the 2 remaining are arm G (§ 5)
name gate        NAME-ONLY one-sided-OURS 2 pristine / 2 patched over the grid and
                 2 / 2 over the boundary re-score; ARM-VIEWS THAT GAINED A NAME: 0
canaries         surelog ok=49 changed=3 (the two conversions + the Earlgrey flake),
                 uhdm2rtlil ok=8 changed=0; ctcan2 PASS on both corpora
protected DBs    20 / 20 SAME, including SVSwitch 4842211c4030 and YosysVerx 6ccda350c24a
canaudit         audited=29  UNCOVERED=0  FENCE-BREACH=0
```

**THE MUST-STAY FLOOR.** § 217's transitive-import arms and its cycle/diamond
shapes, § 203/206/209's arms and fences, § 215's and § 216's arms and fences all
sit inside the 5571 the wide boundary compiled with both binaries; **not one of
them is in the moved list.** The three arms that did move are attributed in
`FALSEMOVERS.r10uvm219.txt` with five tells each: only `constant` `|UINT` /
`|vpiDecompile` lines differ, every delta is **exactly 4096 — one page**, the
listing census is byte-identical, the arms hold **zero** nets named `this`, and
each scores cell-for-cell IDENTICAL against a real Surelog golden on the two
binaries.

**THE SEVEN PROTECTED CMP_EQUAL ROW-MODES**, both columns scored explicitly:
`BuildUVMPkg` ×2, `SimpleUVM` ×2, `Earlgrey_0_1` ×2, `Scoreboard`/default and
`Rggen`/default are all `CMP_EQUAL` in the patched sweep with `uhdm-cmp` **rc 0
and 0 heads** (`rowheads.sh`, both binaries). The only row of the eight whose CSV
line moved is `Earlgrey_0_1/testflags`, in the INFORMATIONAL dump column only,
with its database md5-identical on the two binaries.

## 9. RESIDUES

* **R0 — THE IMPLICIT BLOCK'S INTERIOR ORDER IS STILL NOT GOLDEN'S, AND THE
  JUDGE CANNOT SEE IT (YET).** SeqDriver's 158-wire block is golden's multiset in
  a different order: 157 of 158 positions still differ, and the census reads
  POSDIFF 157 after the law. Every one of them is covered by
  `logic_net::Compare`'s `m_visited` short-circuit, which is *why* both rows are
  `CMP_EQUAL` — but the mask is a property of golden's class walk, not a
  guarantee. The rule the block wants is the forwarded stream's own order:
  golden's block is the imported packages' `getLateBinding()` vectors
  concatenated in import order, ours is `classPropRefs`' emission order. Two
  concrete symptoms are already measured: golden's first qualifying `this`
  reference is `902:36` where ours is `152:45` (so our wire sorts to index 66
  where golden's is at 70), and r10uvm217's R1 (a package's import clone belongs
  at the FRONT of its listing) is the same family. **This is the next head to
  attack if the mask ever lifts.**
* **R1 — § 38 MINTS ONE `this` WIRE PER DESIGN; SURELOG MINTS ONE PER MODULE,
  AND ONLY IN THE FIRST.** Grid arm G, measured on a real golden: with two top
  modules both importing the package, golden gives `gg_deep` the `this` wire and
  `gg_near` NONE — because `lateBinding` skips a ref that is already bound
  (`UhdmWriter.cpp:3297`) and the forwarded `ref_obj`s are SHARED objects, so the
  first module to run the walk mints the wires and binds them for everybody. Our
  § 38 happens to mint once, in the top module § 38 picks, which agrees with
  golden here by a different mechanism. RECORDED, not claimed, and not this
  pass's to change.
* **R2 — `bindHoistedClassPropRefs` MINTS ITS FORWARDED WIRES *PER MODULE*, AND
  THE SECOND IMPORTER SHOULD GET NONE.** The same arm G measurement, on the
  other half: golden's `gg_near` has no `g0_prop` and we mint one there, on
  BOTH binaries. It is the one-sided name the grid's name gate counts (2
  pristine / 2 patched, 0 gained), it is the only cell `subseq219.py` still
  calls ORDER-WRONG after the law, and it is a listing-mint question, not an
  ordering one.
* **R3 — r10uvm217's R2 IS UNCHANGED.** `bindHoistedClassPropRefs` tests the
  DIRECT import set, so a two-hop package's class property is not minted in the
  deep importer (arm G's `g0_prop` in `gg_deep`). Identical on both binaries; it
  is what makes arm G's position census fall a cell while its order census
  rises.
* **R4 — `Earlgrey_0_1/testflags`'s informational dump column.** The committed
  `results/golden_surelog.csv` says `differ`; this pass's sweep reports it EMPTY.
  The STATUS is `CMP_EQUAL` in both and **the two databases are byte-identical**
  (`protdb219.sh`, md5 `92bf7b7facdc`). The recorded uhdm-dump timeout flake
  (r10uvm197/199/201/209/215/217 all logged the same cell), in the opposite
  direction from r10uvm217's reading of it.
* **R5 — THE BOOKMARK IS A *POSITION*, AND A LISTING THAT GREW BETWEEN THE TWO
  PASSES WOULD SHIFT IT.** The recorded `[begin, end)` is an index pair into the
  module's `Nets()`, read at the moment `bindHoistedClassPropRefs` returns; the
  insert is clamped to it, so anything pushed AFTER that moment necessarily
  lands after the `this` wire. Every mint that follows in `emitInstance`'s def
  path is a module-OWN one (`mintUnitEnumNets`, the gate-terminal wires, and the
  `implicitNetModule` mints of statement and process emission), which is exactly
  where the law wants them — a module's DECLARED nets are all pushed before the
  bookmark. That is an inspection of the current emitter, not a gate: were a
  future pass to append a DECLARED net after this point, the wire would sit
  ahead of it. The exposure today is nil and measured: § 38 fires in exactly two
  designs over 2314 corpus databases and neither top module has a port, and the
  wide boundary moved no arm but this pass's own.
* **R6 — MiniAmiq ×2 stands at 29 cmp lines / one head** on both binaries, its
  databases byte-identical. That is the sister pass's row and nothing here
  touches it.
