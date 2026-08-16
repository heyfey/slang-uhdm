# r10earl48 — ADVERSARIAL VERIFIER's report

**VERDICT: ACCEPT WITH FINDINGS — LAND IT, with the ONE-LINE `EmptyMember`
correction below, and restate the law's first-item clause.**

Every number in the implementer's write-up reproduced on an **independently
built pair of binaries** — both md5s came out bit-for-bit equal to the
implementer's (`e99e73e9…` patched, `d44ed8d2…` pristine), and so did both
Earlgrey databases, the 644→66 head, the whole census, the per-shape movers,
the multiset distance and all five gates. The headline is TRUE: golden's
elaborated view has **no `gen_enc` object at all** (I counted it on golden's own
bytes: `gen_enc` appears **95** times in golden's DEF region and **0** times in
its ELAB region), the flatten is **structural and lossy**, and after the patch
our `work@prim_present` elaborated block is the same **8 839 lines** as golden's
with the census reporting `GOLDEN-ONLY 0 / OURS-ONLY 0 / shared 5182 / span
disagreements 0`.

**But the law as stated is one clause short, and the missing clause is a
REGRESSION.** An **empty item `;`** standing before the if-generate in the else
arm is an ITEM for Surelog: golden **keeps the level**, the **PRISTINE binary
kept it too** (`v48v_emptyitem.sv`: pristine `DUMP_MATCH`, cmp `PASS`, the whole
database byte-identical to Surelog's), and the **patched binary promotes** and
fails cmp on `vpiName` — `gen_scope_array (work@…​.x2_e)` against ours
`(work@…​.x2_c)`. Cause: `elseArmSurvivor48` skips `SymbolKind::EmptyMember`
when it looks for the arm's first item. §F1 has the counterexample and §F1.3 the
one-line fix, which I **built and gated** (binary `44e12c37…`, §F5) — it fixes
the shape, leaves Earlgrey byte-identical and moves no corpus database.

A second, smaller mis-statement rides on the same symbol kind: the R1 fence says
golden emits "NOTHING AT ALL" for a promoted block that is **EMPTY**. A block
holding only `;` is **not** that case — golden **promotes** it and spans it at
the `;` (§F2). The fence is about a truly empty `begin end`.

Both shapes have **zero cells in Earlgrey_0_1 and zero in either corpus** (the
census is 100 % `prim_present`; gate 5 moved no database but Earlgrey and
`IfGen3`), so no gate can see either one. That is why this is an ACCEPT and not
a REJECT — and why the correction must land with the patch rather than be
quoted forward as a measured law.

Everything below ran in the verifier's own worktrees, all three
`git rev-parse HEAD` printed and grep-checked `a6e4932dec…`:
`/tmp/wt_v48` (patched: `git apply` of the delivered patch on a fresh
`a6e4932`), `/tmp/wt_v48pris` (pristine `a6e4932`), `/tmp/wt_v48fix`
(patched + §F1.3). The main tree is at `3a7a6a6` and was never used for a
build, a sweep or an arm.

---

## 0. REPRODUCED, number by number

| claim | implementer | verifier | |
|---|---|---|---|
| patch md5 / size | `c9bdd2144c557842d5e1024c9590ae87`, 469 577 B | identical | ✅ |
| `git apply --check` on fresh `a6e4932` | clean | clean; `src/ModuleEmit.cpp` → `af67485a7df9b4c21fe94055bbe091ad` | ✅ |
| production diff | `src/ModuleEmit.cpp` ONLY, +109 / −1, 3 hunks | `git diff --name-only a6e4932` = `src/ModuleEmit.cpp`; `include/UhdmExporter.h` untouched | ✅ |
| `§ elseArmFirstItemReplaces48` sites | 3, all in ModuleEmit.cpp | 3 (11927 / 12175 / 14940), none elsewhere in `src/`+`include/` | ✅ |
| patched binary md5 | `e99e73e91ad94071fa61639f222c8054` | **same**, from my own `-j 2` build, 0 ` error:` lines | ✅ |
| pristine binary md5 | `d44ed8d2fb93787d4d333d98c00da7f6` | **same** | ✅ |
| pristine Earlgrey head | 644 lines | 644, `diff` vs committed `r6_oldhead48_pristine.cmp` EMPTY, and vs r10earl47's shipped `r6_nexthead47.cmp` EMPTY | ✅ |
| patched Earlgrey head | 66 lines | 66, `diff` vs committed `r6_nexthead48.cmp` **EMPTY** | ✅ |
| Earlgrey `slang.uhdm` | 49 939 877 → 49 887 749 B; `09b53b21d06d…` → `fa1540060d27…` | identical byte counts and md5s, from my own binaries | ✅ |
| Earlgrey dump lines | 4 655 864 → 4 652 516 | identical | ✅ |
| census pristine | 5182 / 5244 / shared 5151 / G-only 31 / O-only 93 (62 drop-one + 31 k128) / span 0 | identical; my `census48.py` output is **byte-identical** to the committed `census48_pristine.txt` | ✅ |
| census patched | 5182 / 5182 / shared 5182 / 0 / 0 / span 0 | identical; byte-identical to committed `census48_patched.txt` | ✅ |
| `present_update_key128` | golden 0, ours 93 → 0 | golden ELAB 0; ours pristine **93 `func_call` lines** (155 lines mentioning it) → **0** | ✅ |
| per-top-module isolation | only `prim_present` moves, 12 188 → 8 840 | only `prim_present`, 12 187 → 8 839 body lines (+1 marker each) — the other nine byte-identical incl. `top_earlgrey` | ✅ |
| DEF view | byte-identical, 1 196 437 lines | `cmp` silent, **1 196 437** lines | ✅ |
| shapes by multiset | ADDED 791/2604, REMOVED 1686/5952, NET −3348 | identical; the only `work@` prefix among the moved shapes is `work@prim_present` | ✅ |
| msdist vs golden | 306 492 → 301 038 | identical, and directional: golden-only 237 038 → 235 985 **and** ours-only 69 454 → 65 053 — strictly toward golden | ✅ |
| prim_present residual diff | 9 858 → 558 | **10 168 → 558** content lines (my pristine figure is 310 higher; the patched one agrees exactly) | ⚠ F6 |
| grid a1 | pristine 19 differing + 1 span → 0 + 0 | 5 G-only + 14 O-only = 19, 1 span → **0 + 0 + 0**, and the whole a1 database is `DUMP_MATCH` to Surelog | ✅ |
| grid a2 | 13 + 3 → 5 + 1 (all R1/R2) | identical; the 5 are `u4`, `u5`, `u5.u5_c2`, `u9`, `u9.u9_c`, the span is `u8.u8_c` | ✅ |
| grid a3 | 14 + 1 → 0 + 1 (R2) | identical; the span is `v6.v6_c`, unchanged from pristine | ✅ |
| gate 1 BUILD | `-j 2`, link line, 0 errors, md5 asserted separately | reproduced on all three of my builds | ✅ |
| gate 2 GOLDENS | 23/0; `/bin/false` 0/23 | **PASS=23 FAIL=0**; `/bin/false` **PASS=0 FAIL=23** | ✅ |
| gate 3 u2r | 679/50/2 ×4, ct8rows 0 rows, dump 496/183/52 | identical; pristine control 0 rows; sorted pat/pris CSVs `diff` EMPTY both modes | ✅ |
| gate 4 surelog | 469/11 + 465/8, FAIL 25/23, DEFER 5/5, histograms 325/244/225 and 329/300/165, 0 rows | identical, both controls, sorted pat/pris CSVs `diff` EMPTY both modes | ✅ |
| gate 5 u2r bytes | `PATH_SETS_IDENTICAL(1358)`, 0 movers, SELFCHECK 1357, SELFCHECK1 1 | identical | ✅ |
| gate 5 surelog bytes | `PATH_SETS_IDENTICAL(953)`, **4** movers, SELFCHECK 952, SELFCHECK1 5 | **3** movers — Earlgrey + IfGen3 ×2, same md5 prefixes; **Scoreboard did not move in my sweep at all**, which is the implementer's own multi-stability finding confirmed from the other side | ✅ F4 |
| IfGen3 real, zero-size-delta | 3+3 solo runs stable; 77→35 and 117→35; span 15:7-15:40 | reproduced: pristine `2315deb2acf7` ×3, patched `f7252eab60f1` ×3; msdist **77 → 35**; span now exactly golden's `15:7, endln:15:40` | ✅ |
| Scoreboard not real | pristine produces the "patched" DB 2/8 | **the PATCHED binary alone produced BOTH** databases in 4 solo runs (`307fdd7029de` ×2, `51045a62d0e4` ×2) | ✅ |
| canaries | ok=8 / ok=52 / ctcan2 1+58 / canaudit 29,0,0 | identical (`unknown-names` 25 / 7, `unknown-patterns` 6 / 1, both PASS) | ✅ |
| bynames u2r | identical=26 moved=0 absent=0 | identical=26 moved=0 absent=0 — every genscope canary, `genblk_order` and `jeras_tcb_gpio` byte-identical | ✅ |
| bynames surelog | identical=14 moved=4 | identical=15 moved=3 (Scoreboard stayed put here) | ✅ |
| boundary arms | 18/18 `o.dump` IDENTICAL | **18/18 IDENTICAL**, re-run from MY worktree's copies incl. `v47v_prefixkinds`, `a1_chain`, `a2_fence`, `v1_outside` | ✅ |
| R3 residue | 93 module-parameter fold cells, wrong parent + ref_typespec name | exactly 93 `+…ref_typespec: (work@prim_present)` / 93 `+…vpiFullName:work@prim_present`, against 93 `-` operation parents and the `…round_key.round_key` names | ✅ |
| R0 next head | `sram2tlul.sv:15`, whole-expression range fold | confirmed from my own `cmp.log`: golden `constant UINT:31`, ours `operation` opType 11 with two folded operands | ✅ |

Sweep provenance was checked the way the ops rules demand: `SLANG_UHDM` exported
per sweep, each sweep's own `cmds.txt` read back (`/tmp/wt_v48/build/slang-uhdm`
and `/tmp/wt_v48pris/build/slang-uhdm`), `GOLDEN_DEFER` never set,
`--jobs 2`, my own CSV dir and workdir roots, `results/*.csv` read-only, the
four slang-fenced tests never dispatched (`canaudit`: FENCE-BREACH=0).

---

## F1 — THE MISSING CLAUSE: an empty item `;` is an ITEM, and the patch REGRESSES on it

`v48v_emptyitem.sv` (committed here) is one module and nothing else:

```systemverilog
  if (0) begin : x2_t
    wire t;
  end else begin : x2_e
    ;                        // <- the arm's FIRST item
    if (1) begin : x2_c      // <- the if-generate the law promotes
      wire c;
      assign c = 1'b0;
    end
  end
```

| binary | result |
|---|---|
| **PRISTINE** `d44ed8d2…` | `DUMP_MATCH` — the WHOLE database byte-identical to Surelog's, `uhdm-cmp` **PASS**, 0 heads |
| **PATCHED** `e99e73e9…` | `CMP_FAIL`, 198-line head, 83 differing dump lines |

The head is the first field `BaseClass::Compare` reads after the type:

```
LHS: gen_scope_array: (work@v48v_emptyitem.x2_e), line:9:12, endln:15:6   |vpiName:x2_e   <- golden
RHS: gen_scope_array: (work@v48v_emptyitem.x2_c), line:12:7, endln:12:14  |vpiName:x2_c   <- patched ours
```

This is a **regression, not an under-fire**: the pristine binary was exactly
right and the patch made it wrong. The cause is one line of
`elseArmSurvivor48`:

```cpp
        for (auto& gm : blk.members()) {
            if (gm.kind == SymbolKind::TransparentMember ||
                gm.kind == SymbolKind::EmptyMember ||     // <- this
                gm.kind == SymbolKind::Genvar)
                continue;
```

`;` is skipped, the if-generate becomes "the first item", and the arm collapses.
Golden's elaborator counts it. The law's own sentence — *"the arm's FIRST member
ITEM decides"* — is right; the code's item set is one kind too small.

### F1.1 The same skip in the OTHER direction (`v48v_emptyitem2.sv` y1)

A `;` **after** the if-generate does **not** block the collapse: golden emits
`work@y1.y1_c` at module level and drops the `;` with the rest of the arm. The
patched binary already gets this right, and any fix must keep it — which is why
the fix below distinguishes the FIRST position rather than simply removing the
skip. (My own first attempt did remove the skip and broke `y1`; §F5 records
that, because the fix was measured, not reasoned.)

### F1.2 What the law should say

> …the arm's FIRST member ITEM decides, **and an empty item `;` is an item**: if
> a `;` stands before the if-generate the level stands. After the first item a
> `;` is dropped with every other sibling.

### F1.3 The fix (in `/tmp/wt_v48fix`, binary `44e12c378271d55e2b44e229c212951e`)

slang gives an `EmptyMember` **no syntax node**, so the fix rides the `!ms` test
that is already there — it needs no new symbol-kind test at all:

```cpp
            if (gm.kind == SymbolKind::TransparentMember ||
                gm.kind == SymbolKind::Genvar)
                continue;
            auto* ms = gm.getSyntax();
            if (!ms) {
                if (!item)
                    return nullptr;   // a `;` FIRST keeps the level
                break;                // a `;` after the first item is dropped
            }
```

---

## F2 — the R1 fence is mis-stated: a `;`-only promoted block is PROMOTED, not vanished

`v48v_emptyitem2.sv` `y3`:

```systemverilog
  end else begin : y3_e
    if (1) begin : y3_c
      ;
    end
  end
```

Golden emits `work@y3.y3_c` at module level with span **24:7-24:8** — the `;`
itself. It does **not** emit nothing. Both the patched binary and the fixed one
keep the level here (the pristine answer), so this is an **under-fire, not a
regression**, and it is fenced in the fixed source in the same words: slang
gives the `;` no syntax node, so its span cannot be reproduced without new
machinery. R1's "EMPTY promoted block ⇒ NOTHING AT ALL" is a statement about a
**truly empty `begin end`** (a2 `u9`), and should say so.

---

## F3 — the law CONFIRMED in five shapes no arm had measured

`v48v_instanced.sv` + `v48v_firstitem.sv` (committed here). LHS always golden.
Every one of these rows is **exact** on the patched binary and **wrong** on the
pristine one:

| row | shape | golden | pristine | patched |
|---|---|---|---|---|
| `w1` | the EXACT `prim_present` shape inside an **INSTANTIATED** child module (`u_w1.w1_round[i]`) | `…w1_round[i].w1_d64`, `w1_enc` gone, `w1_k128` gone | 3 levels + k128 ✗ | ✓ exact |
| `w2` | else arm whose SECOND item is a **MODULE INSTANCE** | `w2_c` promoted, **`v48v_leaf u_leaf` gone from the design** | ✗ | ✓ exact |
| `w4` | promoted block holding an **instance first**, a for-generate second, inside an instantiated module | `u_w4.w4_c` at the instance's span, `w4_l[0..1]` under it | ✗ | ✓ exact |
| `w9` | first item is an if / **else-IF** chain | the taken else-if block `w9_b` promoted, re-spanned at its first member | ✗ | ✓ exact |
| `x5` | the shape inside a **for-generate inside an INTERFACE**, two children | `x5_l[i].x5_c` only, `x5_c2` dropped | ✗ | ✓ exact |
| `w3` | first item's taken branch is a **BARE STATEMENT** (unnamed) | level KEPT (`w3_e.genblk1`) | ✓ | ✓ |
| `x1` | a **typedef** before the if-generate | level KEPT | ✓ | ✓ |
| `x3` | a **localparam AFTER** the if-generate | promoted, localparam dropped | ✗ | ✓ exact |
| `x4` | promoted block whose only member is another if-generate | `x4_c` with `x4_d` nested | ✗ | ✓ exact |

`w1` matters most: **every cell the census population contains is in a TOP
module** (`prim_present` is never instantiated in Earlgrey_0_1) and all three
implementer arms are top modules, so "Surelog only flattens on the top
elaboration path" was still live. It is now refuted by measurement.

`w2` matters second: golden really does **delete a module instance** that
follows the first item — the destructive reading of the law is golden's, not the
implementer's.

**The one shape where both binaries disagree with golden** is `w8`, a NAME
COLLISION (a promoted `w8_c` landing in a scope that already has a `w8_c`):
golden's promoted scope carries the OTHER `w8_c`'s net and cont_assign as well.
Contrived, present in neither corpus, wrong before and after — recorded as R7
below, not charged to this pass.

---

## F4 — gate 5's fourth mover is a coin, and I flipped it from the other side

My surelog byte verifier reports **3** movers, not 4: Earlgrey and `IfGen3` in
both modes, with exactly the implementer's md5 prefixes. `Scoreboard` was
**byte-identical between my two sweeps** — and 4 solo runs of the **PATCHED**
binary produced `307fdd7029de` twice and `51045a62d0e4` twice. One binary,
both databases: `Scoreboard`'s dump is multi-stable on this machine and the
implementer's classification is right, arrived at from the opposite direction.

`IfGen3` is a **real** mover with a zero size delta, exactly as claimed:
3 solo runs of each binary are stable and stably different, msdist to its own
golden goes **77 → 35**, and `work@lzc.all_true`'s span becomes golden's
`15:7-15:40` exactly. It is the law's one corpus cell and it is a WIN that
gates 3 and 4 cannot see (`CMP_EQUAL / differ` on both sides).

---

## F5 — the fix, gated

`/tmp/wt_v48fix` = fresh `a6e4932` + the delivered patch + §F1.3, built `-j 2`,
0 ` error:` lines, binary `44e12c378271d55e2b44e229c212951e`.

| check | patched `e99e73e9…` | fixed `44e12c37…` |
|---|---|---|
| `v48v_emptyitem` (the regression) | `CMP_FAIL`, 198-line head, 83 diff lines | **`DUMP_MATCH`, cmp PASS, 0 heads** |
| `v48v_emptyitem2` (`y1` collapse must survive) | 23 diff lines (`y1` ✓ golden, `y3` fenced) | **23 diff lines — identical behaviour** |
| `v48v_firstitem` grid (x1…x5) | 2 golden-only + 1 ours-only | **0 golden-only + 0 ours-only, 11 shared — every row golden's** |
| `a1_earl48` | `DUMP_MATCH` | `DUMP_MATCH` |
| `a2_earl48` / `a3_earl48` | 171 / 67 diff lines | **171 / 67 — identical** |
| `v48v_instanced` | 43 diff lines (only the `w8` collision) | **43 — identical** |
| Earlgrey_0_1 default | `fa1540060d27b1af8784b77ee95b459b`, 66-line head | **same md5, same 66-line head, `diff` vs `r6_nexthead48.cmp` EMPTY** |
| goldens | 23/0, `/bin/false` 0/23 | **23/0** |
| u2r sweeps, both modes | 679/50/2 | **679/50/2**, `ct8rows` **0 differing rows**, CSVs `diff`-identical to the patched sweeps |
| surelog sweeps, both modes | 469/11 + 465/8, FAIL 25/23, DEFER 5/5 | **identical**, `ct8rows` **0 differing rows**, CSVs `diff`-identical to the patched sweeps |
| byte verifier **fixed vs patched**, u2r | — | `PATH_SETS_IDENTICAL(1358)`, **MOVERS 0 / 1358**, SELFCHECK 1357, SELFCHECK1 1 |
| byte verifier **fixed vs patched**, surelog | — | `PATH_SETS_IDENTICAL(953)`, **MOVERS 1 / 953 — `Scoreboard` only**, and its two md5s (`307fdd7029de` / `51045a62d0e4`) are exactly the two the PATCHED binary alone produces (§F4), i.e. the coin again. Earlgrey and both `IfGen3` databases are **byte-identical** between patched and fixed |

The fix is therefore inert on the target, inert on both corpora, and fixes the
only shape it touches. **My first attempt was wrong and is recorded rather than
hidden**: binary `044aa9e2be3fa795bbc8872053b58fb1` removed the `EmptyMember`
skip outright, which made *any* `;` in the arm block the promotion (via the
pre-existing `!ms → return nullptr`) and broke `y1` — golden collapses there and
the patched binary was right. The arm caught it and the second build
(`44e12c37…`) is what is measured above. A one-line fix that is not gated is a
guess; this one has an arm on every row it changes and two corpus sweeps behind
it.

**Deliverable.** `/tmp/r10earl48.verified.patch` = the delivered patch + §F1.3 +
this file + the four verifier arms (`v48v_emptyitem.sv`, `v48v_emptyitem2.sv`,
`v48v_instanced.sv`, `v48v_firstitem.sv`) + a three-line ERRATUM at the top of
the implementer's `README.md` pointing here. Production diff is still
`src/ModuleEmit.cpp` ONLY (+129 / −1 against `a6e4932`).

---

## F6 — two small numbers I could not reproduce, and one artifact that quotes a retracted reading

1. **`prim_present` pristine residual diff.** The README says the unified-diff
   content between golden's and our `work@prim_present` elaborated block fell
   from **9 858** to **558**. I measure **10 168 → 558** (`diff -u`, `^[-+]`
   lines, `---`/`+++` excluded, blocks split at the ten `|uhdmtopModules:`
   markers). The post-patch figure — the one the residue ranking rests on —
   agrees exactly; only the pristine baseline differs, and nothing depends on
   it.
2. **`present_update_key128` = 93.** True for `func_call` lines (31 sites × 3);
   155 dump lines mention the name. Both are 0 after the patch, and 0 in golden.
   Stated here only so the next reader knows which count the 93 is.
3. **`CENSUS_PREDICT.txt` still quotes the truncated dump.** Its line-arithmetic
   prediction reads *"the dump SHORTER than 4 199 404 lines"* — 4 199 404 is the
   partial `wc -l` from the read the README itself retracts (R-8); the finished
   pristine dump is **4 655 864**. The prediction's direction is right and the
   README discloses the error, but the artifact that is supposed to be the
   before-the-fact record still carries the retracted number.

---

## F7 — statements that do not match the code (no measured consequence)

1. **R6 (miseval).** The README says "a re-decided arm is collapsed by the same
   rule as a normally decided one". It cannot be: `emitSurelogMisevalGenIf` /
   `misevalTake9` reach `pushGenBlk9` with `blk.isUninstantiated == true`, and
   every generate child of an uninstantiated block is uninstantiated too, so
   `elseArmSurvivor48`'s `b2.isUninstantiated → continue` leaves `survivor`
   null and the law is **structurally inert** there. The direction is safe; the
   sentence should say inert, not "collapsed by the same rule".
2. **`bndarms48.sh` reads the MAIN TREE** (`ROOT=/home/heyfey/git-repos/
   slang-uhdm/tools/probe`) for the boundary arms and stages them into
   `/tmp/wt_r10earl48`. The main tree moved to `3a7a6a6` mid-pass, so the
   committed script's inputs are a moving target. I re-ran all 18 arms from my
   own `a6e4932` worktree instead (`identical=18 differing=0`); the script
   should take the arm root as an argument.
3. **The promoted block's name bypasses `genResetName9` / `shiftGenName9`.**
   `pushGenBlk9(*surv48, std::string(surv48->getExternalName()), …)` is correct
   for every measured row (the promoted block must be NAMED, so neither helper
   would rename it), but a user-written `begin : genblk3` in that position would
   now skip the module-level `shiftGenName9` renumber. No arm, no corpus cell,
   no Earlgrey cell — recorded so it is not discovered as a surprise.

---

## RANKED RESIDUES (verifier's ranking)

**R0 — the next head, `sram2tlul.sv:15`, 66 lines.** Confirmed from my own
`cmp.log`: golden folds the whole range expression to `constant UINT:31`; we
keep an `operation` (opType 11) over two folded operands. Whole-expression range
fold — the row's next law, and unrelated to generate scopes.

**R1 — the VANISHING arm (a2 `u4`/`u5`/`u9`), 5 arm paths, 0 Earlgrey cells,
0 corpus cells.** Correctly fenced: implementing it destroys elaborated content
(`u5` loses `u5_c2` and its wire). Restate as "a **truly empty** `begin end`"
per §F2.

**R1b — the `;`-only promoted block (§F2), 1 arm path, 0 corpus cells.** Same
family, newly characterised; blocked by slang's `EmptyMember` carrying no
syntax, so it needs a span source before it can be modelled.

**R2 — the case-generate item span (a2 `u8_c`, a3 `v6_c`), 2 arm cells,
PRE-EXISTING.** Identical before and after; `underCase9` is older than this law.

**R3 — 93 `prim_present` module-parameter fold cells.** After this pass the
whole of that module's remaining 558-line diff: wrong `vpiParent`
(`param_assign` where golden has the enclosing `operation`) and a
`ref_typespec` named `work@prim_present` where golden names
`…gen_round[i].round_key.round_key`. r10earl47's R3/R4 family, ParamEmit's.

**R4 — `genHoists9` overlap decided by ORDER.** The new test runs first, so an
unnamed else arm whose first item is a named if-generate takes the new path.
Both measured rows (`u2`, `u3`) match golden; the unmeasured combination
(unnamed arm, unnamed first child, second child) has no arm and no corpus cell.

**R5 — `collapseIfLeaf9` pre-empts the law on `jeras_tcb_gpio`.** Confirmed
byte-identical in gate 5's `bynames` run.

**R6 — the miseval path is inert, not "collapsed by the same rule"** (§F7.1).

**R7 — name collision (`w8`).** When a promoted block's name already exists in
the destination scope, golden's promoted `gen_scope` also carries the OTHER
scope's net and cont_assign. Wrong before and after this pass, contrived, 0
corpus cells. Recorded, not charged.

---

## REPRODUCING (verifier's runs)

```sh
git worktree add -f --detach /tmp/wt_v48     a6e4932 && cd /tmp/wt_v48 && git apply /tmp/r10earl48.patch
git worktree add -f --detach /tmp/wt_v48pris a6e4932
cmake -S <wt> -B <wt>/build -DCMAKE_BUILD_TYPE=Release && cmake --build <wt>/build -j 2

cd /tmp/wt_v48/tools/probe/r10earl48repro
SLANG_UHDM=<bin> ./earl48.sh <outdir>                    # head 644 -> 66
SLANG_UHDM=<bin> ./arm48.sh  v48v_emptyitem.sv  <wd>     # F1: pristine DUMP_MATCH, patched CMP_FAIL
SLANG_UHDM=<bin> ./arm48.sh  v48v_emptyitem2.sv <wd>     # F1.1 y1, F2 y3
SLANG_UHDM=<bin> ./arm48.sh  v48v_instanced.sv  <wd>     # F3 w1/w2/w4/w8/w9
SLANG_UHDM=<bin> ./arm48.sh  v48v_firstitem.sv  <wd>     # F3 x1/x3/x4/x5, F1 x2
python3 grid48.py <wd>/g.dump <wd>/o.dump
./sweeps48.sh <pat> <pris> /tmp/v48scr/csv /tmp/v48scr/wd
SELFCHECK=1 SELFCHECK1=1 ./byteverify48.sh /tmp/v48scr/wd/<corpus>_pat /tmp/v48scr/wd/<corpus>_pris
```

Sweep workdirs deleted after the gates; the three worktrees and
`/tmp/v48scr` hold everything quoted above.

---

## DELIVERABLES

| file | md5 |
|---|---|
| `/tmp/r10earl48.verified.patch` (delivered patch + §F1.3 + this file + 4 arms + README erratum) | md5 in the verifier's return message — this file is inside the patch, so it cannot quote its own digest |
| gated binary `/tmp/wt_v48fix/build/slang-uhdm` | `44e12c378271d55e2b44e229c212951e` |
| patched binary (delivered patch as-is) | `e99e73e91ad94071fa61639f222c8054` |
| pristine binary (`a6e4932`) | `d44ed8d2fb93787d4d333d98c00da7f6` |
| `src/ModuleEmit.cpp` after the verified patch | `2d4382fb17ad95d58729d5a5a44a9e75` |

`git apply --check` of `/tmp/r10earl48.verified.patch` is clean on a fourth,
untouched `a6e4932` worktree and reproduces that source md5 exactly. Production
diff: `src/ModuleEmit.cpp` ONLY. Sweep workdirs deleted.
