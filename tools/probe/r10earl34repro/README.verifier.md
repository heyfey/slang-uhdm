# r10earl34 — ADVERSARIAL VERIFIER REPORT (§ hpMixedIdxPkgFold34)

**VERDICT: PASS — with one MUST-RECORD defect (V-F1) that the brief named and
the implementer's grid does not contain.**

Every one of the implementer's numbers reproduces, on binaries I built myself,
including both md5 digests bit-for-bit. The target head is cleared. The mover
fence is exact. But the empty-product-cell hunt the brief ordered found that the
patch **introduces a wrong hier_path name in a shape golden gets right**: a
package parameter whose initializer is a `{...}` (concatenation or replication)
is folded by the patch and is **not** folded by Surelog. Pristine emitted the
correct name; patched does not. Corpus population is provably **zero today**
(gate 5, both corpora, both modes), so this does not block landing — but it
**does** block any widening of § hierSelPkgParamFold (residues R3 and R6), and
the README's "24 cells, all ✓" must be corrected to record it.

---

## 0. WHAT I BUILT, AND THE STRONGEST SINGLE RESULT

A landing intervened: `2c7f693` is no longer HEAD. Two passes landed on top —
`40a7068` (r10uvm62) and `2ee7a58` (r10svs9), both named "live" in my brief.
**I rebase-checked both** and ran every gate on the CURRENT head.

| binary | worktree | BASE (`git rev-parse HEAD`) | md5 |
|---|---|---|---|
| PRISTINE head | `/tmp/wt_v34pris` | `2ee7a58e8baa07d589428d4b6239afb5d84f379a` | `875d3cd6218c135a8fcc6da3c4c3cf19` |
| PATCHED head  | `/tmp/wt_v34`     | `2ee7a58e8baa07d589428d4b6239afb5d84f379a` | `5475fdd178166446d354dda678399728` |
| PRISTINE base | `/tmp/wt_v34bpris`| `2c7f693dc1dd555ef0eb6d2f473e2e54fd34a96c` | `861bf8969729413ecb41edfdbd0a0727` |
| PATCHED base  | `/tmp/wt_v34b`    | `2c7f693dc1dd555ef0eb6d2f473e2e54fd34a96c` | `1019023e29b17a48ccaab7fce6b49dc9` |

**The two `2c7f693` digests are the implementer's reported digests, exactly.**
That is the strongest available patch-completeness proof: a patch missing a
hunk, carrying an uncommitted edit, or depending on anything outside itself
could not land on the same 32-hex digest from an independent `git worktree add`
+ `cmake` + `make`. All four are 32-hex, asserted in a step SEPARATE from the
build, with `grep -c 'error:'` = 0 and the link line observed
(`[100%] Linking CXX executable slang-uhdm` → `[100%] Built target slang_uhdm`).
Every binary's BASE was printed and grep-checked.

```
git worktree add --detach /tmp/wt_v34{,pris} 2ee7a58
git worktree add --detach /tmp/wt_v34b{,pris} 2c7f693
git -C /tmp/wt_v34  apply /tmp/r10earl34.patch     # clean, verbose, untruncated
git -C /tmp/wt_v34b apply /tmp/r10earl34.patch     # clean
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ && cmake --build build -j 5
md5sum /tmp/r10earl34.patch   ->  ec7f90c9f01760825cb4b73383c6bfc2   (matches)
```

**REBASE CHECK.** `git apply --check /tmp/r10earl34.patch` is **rc=0 at both**
`2c7f693` and `2ee7a58`. The production delta between them is
`include/UhdmExporter.h`, `src/ModuleEmit.cpp`, `src/StmtEmit.cpp`,
`src/UhdmExporter.cpp` — **`src/ExprEmit.cpp` is untouched by either landing**,
so there is no textual or semantic collision. Confirmed behaviourally: both
live passes' arms are byte-identical between my pristine and patched HEAD
binaries (§ 4).

---

## 1. THE FIVE GATES, RE-RUN INDEPENDENTLY (all on HEAD `2ee7a58`)

**GATE 1 — BUILD.** Four builds, table above. **GREEN.**

**GATE 2 — GOLDENS.** `SLANG_UHDM=/tmp/wt_v34/build/slang-uhdm
./tests/check_goldens.sh` from the worktree root → **23 PASS / 0 FAIL**.
Negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL, rc=1**.
`GOLDEN_DEFER` printed as **UNSET**. **GREEN.**

**GATE 3 — uhdm2rtlil, `--jobs 2`, own `--out`/`--workdir`.**

```
[testflags] 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL   -> 679/50/2  EXPECTED
[testflags] dump 496 match / 183 differ / 52 empty             -> 496/183/52 EXPECTED
[default]   679/50/2, dump 492 match / 187 differ / 52 empty
ct8rows.sh results/gate_uhdm2rtlil.csv <fresh testflags>: 0 differing ROWS
  "PASS: every row byte-identical to the committed baseline"
```
Identical on the pristine binary; the two CSVs `diff` to nothing. **GREEN.**
(Trap recorded: `gate_uhdm2rtlil.csv` carries **testflags rows only**. Feeding
it a `--mode both` CSV reports 731 bogus ADDED rows. Filter first.)

**GATE 4 — surelog, BOTH modes, `--jobs 2`.**

```
[default]   467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
[testflags] 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL
            + 3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM
dump histograms UNCHANGED: default 225 match / 242 differ / 327 empty
                           testflags 165 match / 298 differ / 331 empty
ct8rows.sh results/golden_surelog.csv <fresh>: 0 differing ROWS (1588 rows)
```
`467/13 + 463/10` as claimed. Pristine CSV `diff`s to nothing against patched.
`Earlgrey_0_1/default` stays `CMP_NOTEQUAL`+`differ` — its ROW does not move,
its BYTES do. **GREEN.**

**GATE 5 — BYTE VERIFIER**, `r10oth6repro/byteverify.sh`, patched vs the
pristine HEAD binary I built, `SELFCHECK=1 SELFCHECK1=1`:

```
u2r     : PATH_SETS_IDENTICAL (1358)  MOVERS 0/1358   SELFCHECK 1357/1358   SELFCHECK1 1
surelog : PATH_SETS_IDENTICAL (953)   MOVERS 2/953    SELFCHECK  952/953    SELFCHECK1 3
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm   <- THE TARGET
  MOVER ./default/Scoreboard-59431470/slang.uhdm     <- THE DOCUMENTED FLAKE
```
Both controls fire. **GREEN**, and the mover set is exactly the claimed one.

**CANARIES.**

| check | measured |
|---|---|
| `canaries.sh` vs `golden_surelog.csv` | ok=**52** changed=**0** absent=**0** unknown-names=7 |
| `canaries.sh` vs `gate_uhdm2rtlil.csv` | ok=**8** changed=**0** absent=**0** unknown-names=25 |
| `ctcan2.sh` EXPECT_UNKNOWN=1 (surelog) | **PASS** ok=58 changed=0 absent=0 |
| `ctcan2.sh` EXPECT_UNKNOWN=6 (u2r) | **PASS** ok=1 changed=0 absent=0 |
| `canaudit.sh` | audited=**29 UNCOVERED=0 FENCE-BREACH=0** |
| `InterfaceModPort` BY NAME | `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == baseline |
| `BlackParrotComplex` BY NAME | `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == baseline |

---

## 2. THE TARGET, RE-MEASURED END TO END

`uhdm-cmp <golden> <ours>` on `Earlgrey_0_1/default`, run by me:

```
PRISTINE : rc=255, 154 lines   head = hier_path (region_cfgs[8].base.q) @315:10
PATCHED  : rc=255,  30 lines   head = logic_net (work@flash_mp.region_cfgs_i)
```

**154 → 30, head CLEARED.** The successor head is **pre-existing and
independent**: the net appears **twice in both** my pristine and patched dumps,
carrying `|vpiNetType:1` on our side and not on golden's, byte-identical between
the two binaries. (Small correction: it is 2 occurrences, not the "7×" the
implementer's README states; the substance — pre-existing, merely masked — is
right.)

**MOVER FENCE, dumps `sed 1d`, pristine vs patched:**

```
REMOVED 180   ADDED 180        line counts identical (4 654 895 both)
REMOVED lines NOT mentioning region_cfgs[MpRegions] : 0
ADDED   lines NOT mentioning region_cfgs[8]         : 0
```
**Exact, 180/180, zero collateral.** `pred34.sh` on my pristine dump reproduces
the 185 identifier-indexed names, the six target names and the 135 fenced ones.

**PER-SHAPE vs GOLDEN, BY MULTISET** (`r10uvm55repro/msdist.sh`, both `sed 1d`,
ADDED and REMOVED counted separately):

| | golden-only | ours-only | DISTANCE |
|---|---|---|---|
| pristine vs golden | 239030 | 70477 | **309507** |
| patched vs golden | 238946 | 70393 | **309339** |
| delta | **−84** | **−84** | **−168** |

Symmetric — nothing moved the wrong way. Every implementer figure reproduced.

**DESIGN-WIDE NAME CENSUS** (distinct hier_path names carrying an
identifier-bearing index; my regex is `\(.*\), line`, which is correct where the
README's `\([^)]*\)` truncates on `$clog2(...)` — hence 183/187/181 here vs the
README's 181/185, same sets):

```
ours-only, PRISTINE (9): region_cfgs[MpRegions].{base,size,en,rd_en,prog_en,erase_en}.q
                         tl_h_i[i].a_source[0+:IDW-STIDW]
                         tl_h_i[i].a_source[IDW - 1-:1]
                         tl_h_i[i].a_source[IDW - 1-:2]
ours-only, PATCHED  (3): the three tl_h_i names only          <- 9 -> 3 CONFIRMED
```
Target-family lines: golden **93**, patched **180**, `region_cfgs[MpRegions]`
count **0**. The 87-line excess is R1+R2, confirmed directly in the dump:
golden's middle element is `ref_obj: (base)` with `vpiName:base` and **no
fullname**, and golden's index constant is parented at the package parameter's
own `param_assign` (`28:18`) with `ref_typespec: (work@flash_ctrl)`; ours writes
`ref_obj: (region_cfgs[8].base)` + `vpiFullName`, parents at the `bit_select`,
and names the ref_typespec `region_cfgs[8]`. **F1 and the R1/R2 ranking hold.**

**THE SCOREBOARD FLAKE — re-proved, and one implementer sentence corrected.**
Three fresh reps per binary, `--filter Scoreboard`:

| rep | PRISTINE md5 | PATCHED md5 | size (all six) |
|---|---|---|---|
| 1 | `4da8d507fa65` | `7cfa3a567877` | 11133439 |
| 2 | `c64f2fe81fec` | `7cfa3a567877` | 11133439 |
| 3 | `1df12766ef22` | `7cfa3a567877` | 11133439 |

The **pristine binary alone yields three distinct hashes** at constant size —
the documented multi-stable flake, reproduced. *Correction:* the README's claim
that "every patched hash is drawn from that same set" is **not general** — my
patched hash appears in no pristine rep. The decisive evidence is the one the
README also gave, and it reproduces:

```
uhdm-dump pristine vs patched (Scoreboard, sed 1d): 1 095 679 == 1 095 679
MULTISET DISTANCE = 0        (and 0 again between an independent rep pair)
```
Content-identical as multisets; pure emission ORDER. Mover 2 correctly
attributed.

---

## 3. HUNTING THE EMPTY PRODUCT CELLS (index kind × view × escaped)

New arms, in this directory, run on BOTH my binaries:
`v1_view.sv`, `v2_kinds.sv`, `v3_cat.sv`, `v4_paren.sv`, `v5_init.sv`.

### 3a. THE VIEW SPLIT — the brief's cell (f), absent from every implementer arm

a1/a2/a3 are single modules with **no instantiation**, so Surelog emits ONE view
of every name and they **cannot see a view split at all**. The brief asked for
this cell explicitly (the 36-vs-48 census asymmetry). `v1_view.sv` instantiates
a submodule so the same name exists in `allModules` (def) and `topModules`
(elab):

| name | golden | pristine | patched |
|---|---|---|---|
| `arr[8].base.q` | 8× | `arr[PkgLp]` 8× | **8× ✓** |
| `arr_r[8].base.q` (RVALUE) | 4× | `arr_r[PkgLp]` 4× | **4× ✓** |
| `arr2d[8][2].base.q` (multi-dim, both dims package) | 10× | `arr2d[PkgLp][PkgTwo]` 10× | **10× ✓** |

**Golden folds in BOTH views, ours now matches in both, with equal
multiplicity.** No view split. The riskiest unmeasured cell in the pass comes
out clean — but nothing in the delivered arms established that.

### 3b. THE INITIALIZER-KIND GRID — where the patch is WRONG (`v5_init.sv`)

The brief named this cell: *"(e) parameter that does NOT reduce (concat-init —
the § 32 discriminator may reappear here)"*. It is absent from a1/a2/a3, and the
patch fails it.

| package localparam initializer | golden | pristine | patched | |
|---|---|---|---|---|
| sized literal `4` | `a1[4]` | `a1[InLit]` | `a1[4]` | ✓ |
| arithmetic `InLit+2` | `a2[6]` | `a2[InArith]` | `a2[6]` | ✓ |
| **concatenation `{2'b10,2'b01}`** | **`a3[InCat]`** | **`a3[InCat]` ✓** | **`a3[9]`** | **WRONG** |
| **replication `{2{2'b01}}`** | **`a4[InRep]`** | **`a4[InRep]` ✓** | **`a4[5]`** | **WRONG** |
| `$clog2(128)` | `a5[7]` | `a5[InFunc]` | `a5[7]` | ✓ |
| ternary | `a6[3]` | `a6[InCond]` | `a6[3]` | ✓ |
| cast `int'(2)` | `a7[2]` | `a7[InCast]` | `a7[2]` | ✓ |

Corroborated on `v2_kinds.sv`, where golden does not merely keep the text — it
keeps a **`ref_obj: (work@v2_kinds.PkgCat)` as `vpiIndex`**, i.e. Surelog's
definition-compile never substituted the parameter at all. That is the mechanism
behind the whole law, and it says the gate is not "declared in a package" but
"**did Surelog's definition-compile substitute it**"; a `{...}` initializer
defeats the substitution.

### 3c. other kind cells (`v2_kinds.sv`, `v4_paren.sv`, `v3_cat.sv`)

| cell | golden | pristine | patched | |
|---|---|---|---|---|
| package lp whose init is a **sized hex literal** `5'h8` | `arr[5'h8]` | `arr[PkgHex]` | `arr[5'h8]` | **✓ new, unmeasured by the implementer** |
| package lp read through a **second package** (`Near = other::Far`) | `arr3[6]` | `arr3[Near]` | `arr3[6]` | ✓ |
| **negative** package lp `[PkgNeg+5]` | `arr4[-3 + 5]` | `arr4[PkgNeg + 5]` | `arr4[-3 + 5]` | ✓ |
| **parenthesised** `[(PkgLp-1)]` (§ hpSelParenStrip's shape) | `arr[8 - 1]` | `arr[PkgLp - 1]` | `arr[8 - 1]` | ✓ — parens already absent from the selector's own span, so the strip law is not needed here |
| **MACRO-spelled** index `` arr2[`V4IDX] `` | `arr2[8]` | `arr2[PkgLp]` | `arr2[PkgLp]` | **MISS (V-F2)** — `rawTextPkgFold`'s `isMacroLoc` guard abstains where golden folds |
| `$clog2(pkg::P)` index | `arr3[]` (golden empties it) | `arr3[$clog2(v2_pkg::PkgLp)]` | `arr3[$clog2(8)]` | wrong before and after (V-F3) |
| qualified `pkg::Dup` | `arr5[3]` | `arr5[v2_pkg::Dup]` | `arr5[3]` | ✓ (F2's refutation of `reducedImportedIdx`'s comment reproduces) |
| module lp `Dup` shadowing a package `Dup` | `arr4[3]` (!) | `arr4[Dup]` | `arr4[Dup]` | unchanged; **golden resolves the shadowed name to the PACKAGE symbol** — a Surelog quirk, pre-existing, worth its own item |
| **VARIABLE index** beside a package index, process LHS | `arrv[8].a_source` | `arrv[v2_pkg::PkgLp].a_source[idx]` | `arrv[8].a_source[idx]` | index folded ✓ (V-F4 below) |
| range `[PkgCat-1:0]` in the OLD (range) builder | `[PkgCat - 1:0]` | `[PkgCat - 1:0]` | same | ✓ — the concat defect is **NOT** in the pre-existing arm |
| ips `[0+:PkgCat]` in the OLD builder | `[0+:PkgCat]` | **`[0+:9]`** | same | pre-existing over-fold (the implementer's R4 family), **not** this patch |
| range `[PkgHex-1:0]` in the OLD builder | `[5'h8 - 1:0]` | `[PkgHex - 1:0]` | same | pre-existing MISS in the old arm, unranked by the implementer |

### 3d. ESCAPED IDENTIFIERS — the delivered arm re-scored

I reproduce the implementer's a3 result (cmp **154 → 118**) and the offset-splice
proof. Two corrections to its scoring:

* the module-scope negative control `\m[0]` is marked **"✓ correctly not
  folded"**, but golden's name is **`arr[m[0]]`** and ours is **`arr[\m[0]]`** —
  golden **drops the leading backslash** of an escaped identifier inside a
  hier_path index, and we keep it. It is a real, unlisted golden-vs-ours
  mismatch (our escaped *base* already prints unescaped: golden and ours both
  say `arr[x][7]`). Not caused by this patch; not in R1–R6 either.
* "6 of 7 names corrected" is **5 of 7** fully corrected by set diff; the 6th
  (`\p[0] +1` → `arr[3 +1]`) folds right and then trips the R5 spacing bug.

---

## 4. THE STANDING LAWS AND THE LIVE PASSES

* **NAMING-CONTEXT-DEPENDENT dead end / `RefPkgParamInEnum`.** The name is
  carried by **no row** in `results/gate_uhdm2rtlil.csv`, `results/golden_surelog.csv`
  or `tests/golden/` — it is not a live guard in either corpus today. The
  substantive protection is the goldens (23/23) plus ct8rows (0 rows), both
  green, and the fold is scope-gated rather than uniform, which is what the dead
  end demands.
* **§ hpSelParenStrip** (TypeEmit.cpp:12287) owns paren stripping and has its own
  `stripParens9`/`spaceOps`; `idxText34` calls the *other* renderer
  (`spaceIdxOps`). I built the collision cell (`v4_paren`) and it is clean —
  a parenthesised element-select index already reaches the builder without its
  parens.
* **r10earl33 arms** `b1_gen b2_init b3_text a3_ctx v4_more v5_holes v6_tfnest`:
  **0 differing dump lines** between my pristine and patched binaries after
  normalising the workdir path, and **`vpiActual` counts equal on every arm**
  (336/270/169/244/223/139/88), read explicitly with `grep -c vpiActual` rather
  than through `cells33.py`. No collision.
* **r10svs9** (landed): arms `a1_parens a3_escaped v1_ctxclock v2_prefix v3_esc
  v4_more` → **0 diff**, `vpiActual` equal (54/35/0/61/30/40).
* **r10uvm62** (landed): arms `c1_endlabel c2_neighbours c3_edge` → **0 diff**,
  `vpiActual` equal (32/16/20).

*(Ops trap for the next verifier: a dump comparison across two arm workdirs is
**not** clean under `sed 1d` alone — the dump embeds `file:<workdir>/...` on
every module_inst line. Normalise the workdir path or you will read hundreds of
phantom "movers". `arm62.sh` also takes the binary as its THIRD argument and
exits with an empty dump if you export `SLANG_UHDM` instead.)*

---

## 5. NUMBERED FINDINGS

**V-F1 — THE PATCH INTRODUCES A WRONG NAME FOR A `{...}`-INITIALISED PACKAGE
PARAMETER. (correctness; zero corpus population today; must be recorded, and
must be fixed before R3/R6 widen the law.)**
Golden keeps the identifier — and keeps a `ref_obj` as the index — for a package
parameter initialised by a concatenation or a replication. Pristine was
**right**; patched is **wrong**.
```
cd tools/probe/r10earl34repro
SLANG_UHDM=<pristine> bash ./arm34.sh v5_init.sv /tmp/x_R
SLANG_UHDM=<patched>  bash ./arm34.sh v5_init.sv /tmp/x_P
grep -oE '_hier_path: \(.*\), line' /tmp/x_P/{g,o}.dump   # golden a3[InCat] / ours a3[9]
```
The whole defect is in `collectPkgParamFolds` (`src/ExprEmit.cpp:3880`), which
tests only `cv.isInteger()` and never looks at the initializer's KIND before
falling back to the decimal value. The shape of the fix is one clause next to
the existing `IntegerLiteral` test — abstain when `stripImplicitConv(*ini).kind`
is `Concatenation` or `Replication` — but it must be written to the grid in
§ 3b, not to one cell, and it changes only the new call sites (the pre-existing
range arm is already correct here, § 3c).

**V-F2 — a MACRO-spelled index does not fold, where golden folds it.**
`rawTextPkgFold` returns early on `sm->isMacroLoc(range.start())`, so
`` arr2[`V4IDX] `` stays `arr2[PkgLp]` against golden's `arr2[8]` (`v4_paren.sv`).
This is a MISS, not a wrong name, and it is the *safe* direction — but Earlgrey
and UVM are macro-dense, so it is the most likely place for the remaining
population of this law to hide. Command as V-F1 with `v4_paren.sv`.

**V-F3 — a `$clog2(...)` index renders EMPTY in golden for this builder.**
Golden: `arr3[]`; pristine `arr3[$clog2(v2_pkg::PkgLp)]`; patched
`arr3[$clog2(8)]`. Both wrong; the patch changes one wrong text into another.
Note the contrast with the standing table's dm_csrs row, where the RANGE arm
renders `[$clog2(5'h8) - 1:0]` — the two builders genuinely differ, and the
element-select rule is "empty". Unmeasured by the implementer. (`v2_kinds.sv`)

**V-F4 — the folded text LEAKS into a child's naming scope, and there it feeds a
`::`-vs-`.` DECISION.** `emitMixedHierPath` passes `prefix + "." + dotted` to
`emitExpr` for a variable index (two arms, `src/ExprEmit.cpp` ~3205 and ~3218).
With the fold, `v2_kinds`'s process-LHS cell moves
```
pristine: ref_obj (work@v2_kinds.arrv[v2_pkg::PkgLp].a_source[idx]::idx)
patched : ref_obj (work@v2_kinds.arrv[8].a_source[idx].idx)
```
— the separator changes because downstream code does `prefix.find("::")` to
decide a package qualification (`src/ExprEmit.cpp:4750`, `:5290`). Here the
change is an **improvement** (the pristine `::` was a corruption caused by the
unfolded `pkg::P` text leaking into a prefix that is parsed for `::`), but the
mechanism — a display name feeding a syntactic decision — is exactly the hazard
class the NAMING-CONTEXT-DEPENDENT dead end names, and it was not measured.
Zero corpus population (gate 5).

**V-F5 — the delivered grid over-scores two escaped cells.** `\m[0]`: golden
`arr[m[0]]`, ours `arr[\m[0]]` — a real mismatch scored "✓ unchanged". And
"6 of 7 corrected" is 5 of 7 by set diff. (§ 3d.)

**V-F6 — `pred34.sh`'s clause C is an assertion, not a derivation.** The header
claims a fence on A∧B∧C, but step C is literally
`grep -E 'region_cfgs\[MpRegions\]'` — it looks up the answer. Its A and B steps
are real and reproduce (185 / 135), and the *measured* fence (180/180, zero
collateral) is sound, so nothing downstream is wrong; but the script does not
predict what its header says it predicts, and 44 of the 185 identifier-indexed
names are never classified by it at all.

**V-F7 — two implementer sentences do not survive re-measurement**, both
immaterial to the verdict: the Scoreboard "every patched hash is drawn from the
pristine set" (§ 2), and the successor head's "present 7× in both" (it is 2×).

**V-F8 — golden resolves a shadowed name to the PACKAGE symbol.** With a module
`localparam int Dup = 5` shadowing a wildcard-imported `v2_pkg::Dup = 3`, golden
prints `arr4[3]`. Ours prints `arr4[Dup]` in both builds. Pre-existing, unrelated
to this patch, and probably a Surelog defect — recorded so the next pass that
touches this law does not "fix" it by folding module localparams.

---

## 6. RANKED RESIDUES (mine, merged with the implementer's)

1. **V-F1 concat/replication over-fold** — the only *wrong-direction* item this
   pass creates. One clause, one grid, zero corpus risk. Do it before R3 or R6.
2. **R1** middle `ref_obj` carries a fullname golden lacks — confirmed in the
   Earlgrey dump; universal in this builder; cmp-invisible but 12 lines per
   target path. Highest-value dump item, as ranked.
3. **R6 gen-scope trigger** — 3 names, the entire remaining naming defect on
   Earlgrey. Confirmed present and unchanged (`tl_h_i[i].a_source[...]`).
   Correctly deferred; it widens the gate exactly the way the dead end warns.
4. **R2** index-constant parent + ref_typespec fullname — confirmed
   (`param_assign` @28:18, `work@flash_ctrl`). Pairs with R1.
5. **V-F2 macro-spelled index** — a MISS in the safe direction; most likely home
   of any remaining population.
6. **R3** trailing range select does not fold in this builder — reproduced
   (`[PkgLp - 1:0]` vs `[8 - 1:0]`), zero population.
7. **R4** ips over-fold of a *module* localparam (`[0+:LocLp]` → `[0+:6]`) —
   reproduced, pre-existing, and it is the same defect *family* as V-F1 in a
   different builder.
8. **V-F3** `$clog2` index renders empty in golden; **R5** spacing after a fold;
   **V-F5** escaped-identifier backslash retention; **V-F8** shadow resolution —
   all cosmetic/pre-existing, all with zero corpus population.

---

## 7. FILES

New in this directory (mine): `README.verifier.md`, `v1_view.sv` (view split),
`v2_kinds.sv` (initializer/shadow/variable-index kinds), `v3_cat.sv`
(old-builder attribution), `v4_paren.sv` (paren/macro/nested/negative),
`v5_init.sv` (the initializer-kind grid). All are driven by the implementer's
own `arm34.sh`, unchanged.

Sweep CSVs: `/tmp/v34out/{u2r,sl}_{P,R}.csv`. All sweep workdirs
(`/tmp/v34wd`, `/tmp/v34arm`, `/tmp/v34a33`, `/tmp/v34s9`, `/tmp/v34u62`,
`/tmp/v34eg`, `/tmp/v34sb`) are deleted. `results/*.csv` were only ever read;
the main worktree is untouched.
