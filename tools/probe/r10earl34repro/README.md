# r10earl34 — § hpMixedIdxPkgFold34

**THE HEADLINE, FIRST.** The brief called this "the INDEX-REDUCTION half" of a
new naming law and warned that a NAME-REWRITE is maximal hazard. It turned out
**no new law was needed at all**: the correct law — § hierSelPkgParamFold — was
already decoded, already implemented, already carrying a measured table in
`include/UhdmExporter.h`, and was simply **never applied to the builder that
owns the target's shape** (`emitMixedHierPath`, i.e. `a[IDX].m.n`). The patch
routes that builder's three index-text sites through **one** renderer that adds
the existing fold. `Earlgrey_0_1/default`'s head went **154 lines -> 30** and the
target family is byte-identical to golden. **180 dump lines moved, 100 % of them
inside the predicted fence; 0 collateral.**

The brief's own framing was **refuted twice** along the way, and both
refutations are load-bearing (§ 2).

---

## 0. THE LAW

> **§ hpMixedIdxPkgFold34 — § hierSelPkgParamFold's substitution belongs to
> `emitMixedHierPath`'s ELEMENT-SELECT index text too, not only to the
> range-select arm that already had it.**
>
> A select index's DISPLAY text carries the **VALUE** of a parameter/localparam
> **declared in a PACKAGE** and the **IDENTIFIER** of a module-scope one
> (module parameter, module localparam, genvar). Surelog decompiles a
> hier_path's name off the **ELABORATED** expression, and its definition-compile
> has already substituted every package parameter — packages compile first —
> while the module's own parameters are still symbolic there.
>
> The substitution is **PER-LEAF and TEXTUAL**, spliced by **SOURCE OFFSET**:
> the operator structure of a compound index survives (`arr2[PkgLp-1]` reads
> `[8 - 1]`, **never** `[7]`), and an **escaped** identifier — whose spelling may
> contain brackets, digits or dots — is replaced by its own range rather than by
> any name match.

| # | call site (`src/ExprEmit.cpp`, `emitMixedHierPath`) | what it does |
|---|---|---|
| 0 | `idxText34` lambda, defined once above the `dotted` loop | **THE renderer** — `concatIdxText` first (§ concatIdxDecompile29), else `spaceIdxOps(rawTextPkgFold(...))` |
| 1 | the `dotted` loop (the hier_path's own `VpiName`/`VpiFullName`) | uses `idxText34` |
| 2 | the `dottedAt` **baseSelMode** loop (each `bit_select`'s `VpiFullName`) | uses `idxText34` |
| 3 | the `dottedAt` **member-select** branch | uses `idxText34` |

All three **must** render identically or the hier_path's name and its own
elements' fullnames disagree about the same select — which is why there is one
lambda and not three copies. `git diff --stat 2c7f693 -- src include` =
**1 file, 45 insertions, 18 deletions** (comments included).

### STATED GATE == CODE GATE

Read verbatim:

```cpp
auto idxText34 = [&](const Expression& selExpr) {
    // § concatIdxDecompile29 — a CONCATENATION index is decompiled from
    // the tree; every other index keeps its raw text.
    std::string ci29 = concatIdxText(selExpr);
    if (!ci29.empty())
        return ci29;
    std::vector<PkgFoldSub> pf34;
    collectPkgParamFolds(selExpr, pf34);
    return spaceIdxOps(rawTextPkgFold(selExpr.sourceRange, pf34));
};
```

There is **no new predicate in this pass**. The package-scope test, the
integer/unknown test, the macro-location test and the offset-splice are all
`collectPkgParamFolds` / `rawTextPkgFold` **exactly as they already stood** —
the gate I state is the gate they already execute:

```cpp
auto* psc = nv.symbol.getParentScope();
if (!psc || psc->asSymbol().kind != SymbolKind::Package)
    return;
```

`rawTextPkgFold` returns plain `rawText` when nothing is collected, so **a name
with no package parameter in it renders byte-for-byte as before** — that is the
formal reason the fence in § 4 is exact rather than merely observed.

---

## 1. THE TARGET, MEASURED

`flash_ctrl.sv:315`, `Earlgrey_0_1/default`, at BASE 2c7f693. The head is
**one** `cont_assign` LHS and it carries **six** distinct field defects — the
brief said "the DISPLAY NAME ONLY", which is **not** what the bytes say:

| # | field | golden | ours (pristine) | cmp-visible? |
|---|---|---|---|---|
| 1 | `hier_path::VpiName` | `region_cfgs[8].base.q` | `region_cfgs[MpRegions].base.q` | **YES — the sole head driver** |
| 2 | `hier_path::VpiFullName` | `region_cfgs[8].base.q` | `…[MpRegions]…` | no |
| 3 | `bit_select::VpiFullName` | `region_cfgs[8]` | `region_cfgs[MpRegions]` | no |
| 4 | leaf `ref_obj::VpiFullName` | `region_cfgs[8].base.q` | `…[MpRegions]…` | no |
| 5 | **middle** `ref_obj` | **no `VpiFullName` at all** | `region_cfgs[MpRegions].base` | no |
| 6 | index constant `vpiParent` + its ref_typespec fullname | `param_assign@28:18` / `work@flash_ctrl` | the `bit_select` / `region_cfgs[MpRegions]` | no |

**Which fields cmp actually reads** (UHDM generated sources, quoted, not
assumed):

* `hier_path::Compare` -> `Path_elems`, `Root_value`, **`VpiName`**
* `ref_obj::Compare` -> `VpiName`, `VpiDefName`, `Actual_group` — **not `VpiFullName`**
* `bit_select::Compare` -> `VpiConstantSelect`, `VpiIndex`, + basetype

So defects 2-6 are **dump-only**; defect 1 alone drives the 154-line head. This
pass fixes 1-4 (they all derive from the one shared text) and leaves 5 and 6 as
ranked residues R1/R2 — both are name/parent rewrites outside this pass's half
and squarely inside the standing NAMING-CONTEXT-DEPENDENT dead-end.

### the head after the patch: 154 lines -> 30, and it ADVANCED

`Earlgrey_0_1/default` is still `CMP_NOTEQUAL` (its row does not move, by
design), but the head is a **different, unrelated** object:

```
LHS/RHS: logic_net: (work@flash_mp.region_cfgs_i), line:21:87, endln:21:100
         (flash_mp.sv — a NET, not a hier_path)
```

That node occurs **7 times in the pristine dump and 7 times in the patched
dump**, and it appears in **none** of the 180 changed lines — so it is a
**pre-existing** defect that was merely masked behind `flash_ctrl.sv:315`
(uhdm-cmp reports the first head only). The target head is cleared, not moved.

---

## 2. TWO REFUTATIONS THAT CHANGED THE PATCH

**F1 — the brief's "the head is the DISPLAY NAME ONLY … everything STRUCTURAL
in the subtree agrees" is FALSE**, and so is r10earl33's README table row
`| elements 2/3 | ref_obj (region_cfgs[8].base) / …base.q) | …`. Golden's
**middle** element is `ref_obj: (base)` with `vpiName:base` and **no
fullname whatsoever**; r10earl33 recorded it as carrying the dotted path. Had I
"restored parity" on that row I would have written a fullname golden does not
have. Measured on both the corpus dump and every arm cell (a1 `arr_b`/`arr_d`/
`arr_m`/`arr_c`): golden's middle element is bare in **all** of them, reducing
or not. It is R1, not part of this law.

**F2 — "an index that REDUCES to a constant is displayed as that constant"
(r10earl33's suggested first rule) is FALSE, and so is the standing comment on
`reducedImportedIdx`.** Two independent counterexamples:

* `arr2[PkgLp-1]` reduces to the constant **7**; golden prints **`[8 - 1]`**.
  The fold is per-leaf and textual, and the operator survives. A value-based
  rule would have printed `[7]` on the target's own design.
* `reducedImportedIdx`'s comment states "a QUALIFIED `pkg::P` read keeps its
  text too (measured against Surelog: `access[L]` keeps `L`)". Arm cell
  **arr_q** refutes it: `arr_q[e34_pkg::PkgLp]` reads **`[8]`** in golden. The
  discriminator is **where the symbol is declared**, never how it is spelled at
  the use site.

Both are why the patch reuses `collectPkgParamFolds` (declaration-scope keyed,
offset-spliced) instead of anything value- or text-keyed.

---

## 3. THE GRID, CELL FOR CELL

Golden vs ours, `arm34.sh a1_idxkind.sv` and `a2_shape.sv`. Every cell is the
target's shape; only the index varies. **P = patched, ✓ = matches golden.**

### 3a. by INDEX KIND (a1_idxkind.sv) — 8 cells, 8 ✓

| cell | index kind | golden | pristine | P |
|---|---|---|---|---|
| `arr_a` | **wildcard-imported package localparam** (THE WITNESS = `MpRegions`) | `[8]` | `[PkgLp]` | `[8]` ✓ |
| `arr_p` | wildcard-imported package **parameter** | `[5]` | `[PkgParam]` | `[5]` ✓ |
| `arr_q` | **QUALIFIED** `e34_pkg::PkgLp` | `[8]` | `[e34_pkg::PkgLp]` | `[8]` ✓ |
| `arr_g` | **expression** over an imported param, `PkgLp-1` | `[8 - 1]` | `[PkgLp - 1]` | `[8 - 1]` ✓ |
| `arr_b` | module-local **localparam** | `[LocLp]` | `[LocLp]` | unchanged ✓ |
| `arr_m` | module **parameter** | `[ModP]` | `[ModP]` | unchanged ✓ |
| `arr_c` | **genvar** | `[gi]` | `[gi]` | unchanged ✓ |
| `arr_d` | literal (control) | `[3]` | `[3]` | unchanged ✓ |

### 3b. by POSITION / SELECT KIND / CONTAINER (a2_shape.sv)

Built because a1's "package vs module" reading was **refuted by the corpus**:
tlul_socket_m1's `IDW`/`STIDW` are MODULE localparams (`tlul_socket_m1.sv:72-73`)
and golden reduces them, while the **genvar `[i]` in the very same name** stays.

| cell | shape | golden | pristine | P |
|---|---|---|---|---|
| `bb_pkg` | base, bare, pkg | `arr[8]` | `arr[PkgLp]` | ✓ |
| `bc_pkg` | base, compound, pkg | `arr2[8 - 1]` | `arr2[PkgLp - 1]` | ✓ |
| `tb_pkg` | **trailing**, bare, pkg | `a_source[8]` | `[PkgLp]` | ✓ |
| `tc_pkg` | **trailing**, compound, pkg | `a_source[8 - 1]` | `[PkgLp - 1]` | ✓ |
| `bb_loc` / `bc_loc` | base, module localparam | `[LocLp]` / `[LocLp - 1]` | same | unchanged ✓ |
| `bb_modp` / `bc_modp` | base, module parameter | `[ModP]` / `[ModP - 1]` | same | unchanged ✓ |
| `bb_frompkg` | module lp **initialised from** `pkg::X` | `[FromPkg]` | same | unchanged ✓ |
| `bb_fromclog` | module lp initialised from `$clog2` | `[FromClog]` | same | unchanged ✓ |
| `tb_loc` / `tc_loc` / `tb_modp` / `tc_modp` | trailing, module-scope | text kept | same | unchanged ✓ |
| `tr_compound_pkg` | trailing **range** `[PkgLp-1:0]` | `[8 - 1:0]` | `[PkgLp - 1:0]` | **still wrong — R3** |
| `tp_bare_loc` | trailing `[0+:LocLp]` | `[0+:LocLp]` | **`[0+:6]`** | **still wrong — R4 (OVER-fold, pre-existing)** |
| `tp_compound` | trailing `[0+:(FromPkg-FromClog)]` | `[0+:FromPkg - FromClog]` | `[0+:FromPkg-FromClog]` | **spacing — R5** |
| gen-scope `arr[LocLp]` | module lp **inside an unrolled generate** | `arr[6]` | `arr[LocLp]` | **still wrong — R6** |
| gen-scope `tl_h_i[gi]…` | module lps inside a generate | `[0+:9 - 5]` | `[0+:FromPkg-FromClog]` | **still wrong — R6** |
| gen-scope `tl_h_i[gi + 1]` | **genvar**, compound, in a generate | `[gi + 1]` | same | unchanged ✓ |

**4 cells fixed, 5 pre-existing residues untouched, 0 regressions.**

### 3c. ESCAPED IDENTIFIERS — the maximal-hazard arm (a3_escaped.sv)

The ops rule demands escaped-identifier cells on any name-reading gate. A
name-**matching** splice fails these loudly; the offset splice passes.

| cell | written | golden | pristine | P |
|---|---|---|---|---|
| bracketed pkg lp | `arr[\p[0] ]` | `arr[3]` | `arr[\p[0]]` | `arr[3]` ✓ |
| digit-suffixed pkg lp | `arr[\p8 ]` | `arr[5]` | `arr[\p8]` | `arr[5]` ✓ |
| **dotted** pkg lp | `arr[\a.b ]` | `arr[6]` | `arr[\a.b]` | `arr[6]` ✓ |
| plain pkg lp | `arr[Plain]` | `arr[7]` | `arr[Plain]` | `arr[7]` ✓ |
| escaped ARRAY base | `\arr[x] [Plain]` | `arr[x][7]` | `arr[x][Plain]` | `arr[x][7]` ✓ |
| **NEGATIVE CONTROL** module escaped | `arr[\m[0] ]` | `arr[m[0]]` | `arr[\m[0]]` | unchanged — correctly **not** folded |
| compound escaped | `arr[\p[0] +1]` | `arr[3 + 1]` | `arr[\p[0] +1]` | `arr[3 +1]` — folds right, **spacing R5** |

Arm cmp **154 -> 118 lines**; 6 of 7 names corrected, none regressed. The
bracketed and dotted cells are the proof that the splice is offset-keyed: a
name match on `\p[0]` would have collided with the `[`/`]` of the select itself.

---

## 4. THE MOVER FENCE — PREDICTED FIRST, THEN MEASURED

`pred34.sh` was written and run against the **pristine** dump **before** any
patched sweep was read. It fences on A ∧ B ∧ C (a hier_path name, an
identifier-bearing index, and a **package-declared** symbol) and predicted:

> the only names that may move are the SIX
> `region_cfgs[MpRegions].{base,size,en,rd_en,prog_en,erase_en}.q`,
> each becoming `region_cfgs[8].<…>.q`, on `Earlgrey_0_1/default` only.

Measured, pristine dump vs patched dump (both `sed 1d`):

```
REMOVED lines NOT mentioning region_cfgs[MpRegions] : 0
ADDED   lines NOT mentioning region_cfgs[8]         : 0
REMOVED total 180   ADDED total 180   (line count identical: 4654895 both)
```

**The fence is exact: 180/180, zero collateral, no node added or removed.**
Of 185 identifier-indexed hier_path names in the design, 135 are genvar- or
module-param-indexed and every one of them is untouched.

### per-shape, against GOLDEN, by MULTISET (`msdist.sh`, dumps `sed 1d`)

| | golden-only | ours-only | MULTISET DISTANCE |
|---|---|---|---|
| pristine vs golden | 239030 | 70477 | **309507** |
| patched vs golden | 238946 | 70393 | **309339** |
| delta | **-84** | **-84** | **-168** |

Symmetric in both directions — 84 line-instances moved from wrong to right on
each side, **nothing moved the other way**. ADDED and REMOVED accounted
separately, as required.

### design-wide name census, before and after

Distinct hier_path names carrying an identifier index: golden 181, ours 185.
The names present **only on our side** — i.e. the entire naming defect on this
design — were **9**, and are now **3**:

| | pristine | patched |
|---|---|---|
| `region_cfgs[MpRegions].{6 members}.q` | 6 | **0 — matches golden** |
| `tl_h_i[i].a_source[…]` (gen-scope, R6) | 3 | 3 |

### what is STILL not byte-equal in the target family, and why

Lines mentioning the family: golden **93**, patched **180**, and every one of
ours now spells `[8]` (`region_cfgs[MpRegions]` count = **0**). The 87-line
excess is **entirely** R1 and R2 and is accounted for line-for-line:

| shape | golden | ours | residue |
|---|---|---|---|
| `\_ref_typespec: (region_cfgs[8])` | 0 | 24 | **R2** (golden's is `work@top_earlgrey.u_flash_ctrl.…region_cfgs`, hung elsewhere) |
| middle `\_ref_obj: (region_cfgs[8].<member>)` | 0 (golden: `ref_obj: (base)`) | 12 | **R1** |
| `|vpiFullName:region_cfgs[8].<member>` | 0 | 12 | **R1** |
| `\_hier_path: (region_cfgs[8].<m>.q)` | 8+8+8+4+4+4 = 36 | 8x6 = 48 | view/instance population, not naming |
| `|vpiName:region_cfgs[8].<m>.q` | 2+2+2+1+1+1 = 9 | 2x6 = 12 | same |

**No part of the excess is a name spelled wrong** — that is the whole of what
this pass claims.

---

## 5. THE FIVE GATES, each with the number I measured

**BASE printed and grep-checked on every binary.** Both worktrees report
`git rev-parse HEAD` = `2c7f693dc1dd555ef0eb6d2f473e2e54fd34a96c`.

| binary | md5 | 32-hex asserted |
|---|---|---|
| PRISTINE 2c7f693 (built here) | `861bf8969729413ecb41edfdbd0a0727` | yes |
| PATCHED | `1019023e29b17a48ccaab7fce6b49dc9` | yes |

**GATE 1 — BUILD.** Absolute path
`/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl34/build/slang-uhdm`.
Waited for the link line (`[100%] Linking CXX executable slang-uhdm` ->
`[100%] Built target slang_uhdm`); `grep -c 'error:'` = **0**. md5 asserted in a
SEPARATE step from the build, and it differs from pristine. **GREEN.**

**GATE 2 — GOLDENS.** `tests/check_goldens.sh` from the repo root:
**23 PASS / 0 FAIL**. Negative control `SLANG_UHDM=/bin/false`:
**0 PASS / 23 FAIL** — the harness genuinely executes. **GREEN.**

**GATE 3 — uhdm2rtlil, testflags, `--jobs 2`.**

```
CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2      -> 679/50/2   EXPECTED
dump: 496 match / 183 differ / 52 (blank)              -> 496/183/52 EXPECTED
ct8rows vs results/gate_uhdm2rtlil.csv: 0 differing ROWS
  "PASS: every row byte-identical to the committed baseline"
```
**GREEN.**

**GATE 4 — surelog, BOTH modes, `--jobs 2`.**

```
[default]   CMP_EQUAL 467   CMP_NOTEQUAL 13   -> 467/13  EXPECTED
[testflags] CMP_EQUAL 463   CMP_NOTEQUAL 10   -> 463/10  EXPECTED
ct8rows vs results/golden_surelog.csv: 0 differing ROWS
dump histograms UNCHANGED both modes:
  default   327 / 242 differ / 225 match   (base == fresh)
  testflags 331 / 298 differ / 165 match   (base == fresh)
```
`Earlgrey_0_1/default` stays `CMP_NOTEQUAL` + `differ` — its ROW does not move,
its BYTES do, which is exactly the target. **GREEN.**

**GATE 5 — BYTE VERIFIER**, `byteverify.sh`, patched vs the PRISTINE 2c7f693 I
built, `SELFCHECK=1 SELFCHECK1=1`, movers attributed per-shape against GOLDEN by
MULTISET with ADDED/REMOVED counted separately, and the movers PREDICTED from
source-derived data first (§ 4). Numbers in § 5a.

### 5a. byte-verifier results

First, the CSVs themselves: **pristine and patched are byte-identical CSVs** for
both corpora in both modes (`diff` = no output), so the whole-row gate is blind
inside them by construction — which is the entire reason this gate exists.

```
uhdm2rtlil, BOTH modes:
  PATH_SETS_IDENTICAL (1358 paths)
  MOVERS: 0 / 1358
  SELFCHECK  1357 / 1358 flagged   (the one fixed file matches itself)
  SELFCHECK1 1                     (exactly the one corrupted file)

surelog, BOTH modes:
  PATH_SETS_IDENTICAL (953 paths)
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm   <- THE TARGET, predicted
  MOVER ./default/Scoreboard-59431470/slang.uhdm     <- THE KNOWN FLAKE
  MOVERS: 2 / 953
  SELFCHECK  952 / 953 flagged
  SELFCHECK1 3                     (1 corrupted + the 2 movers)
```

**Mover 1 — `Earlgrey_0_1/default`: THE TARGET.** Predicted by `pred34.sh`
before the sweep was read; the fence is exact at 180/180 with zero collateral
(§ 4), and the multiset distance to golden improves by 168 symmetrically.

**Mover 2 — `Scoreboard/default`: THE DOCUMENTED MULTI-STABLE FLAKE, not this
patch.** The brief names it and prescribes 3-rep + size-delta. Run:

| rep | PRISTINE md5 | PATCHED md5 | size (both) |
|---|---|---|---|
| 1 | `c0a286dbcf5f` | `d5161cc4717c` | 11133612 |
| 2 | `d5161cc4717c` | `d5161cc4717c` | 11133612 |
| 3 | `a71bdc27636e` | `c0a286dbcf5f` | 11133612 |

**The PRISTINE binary alone produces THREE distinct hashes**, and every patched
hash is drawn from that same set (`c0a286`/`d5161c` appear on both sides). The
byteverify pair (`patched=c0a286dbcf5f`, `pristine=a71bdc27636e`) are *both*
members of the pristine binary's own envelope. **Size is constant across all six
runs**, and the decisive per-shape check:

```
uhdm-dump pristine vs patched (Scoreboard, sed 1d):
  lines 1095638 == 1095638
  MULTISET DISTANCE (sum |dg-do|): 0
```

**Content-identical as multisets — the difference is pure emission ORDER.** This
patch changes nothing in `Scoreboard`; it has no package-parameter-indexed mixed
hier_path at all. Attributed to the flake, on evidence, not by assertion.

**GATE 5 GREEN.**

### CANARIES

| check | result |
|---|---|
| `canaries.sh` vs `golden_surelog.csv` | ok=52 changed=0 absent=0 unknown-names=7 (7 = the u2r-only names, expected) |
| `canaries.sh` vs `gate_uhdm2rtlil.csv` | ok=8 changed=0 absent=0 unknown-names=25 (expected) |
| `ctcan2.sh` EXPECT_UNKNOWN=1 (surelog) | **PASS** — ok=58 changed=0 absent=0 |
| `ctcan2.sh` EXPECT_UNKNOWN=6 (u2r) | **PASS** — ok=1 changed=0 absent=0 |
| `canaudit.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| `InterfaceModPort` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh |
| `BlackParrotComplex` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh |

The four SLANG-FENCED names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) are dispatched by no driver in this directory — asserted by
`canaudit.sh`, not by a sentence.

---

## 6. RANKED RESIDUES

**R1 — the middle `ref_obj` of a mixed hier_path carries a fullname golden does
not have.** Golden: `ref_obj: (base)`, `vpiName:base`, no fullname. Ours:
`vpiFullName:region_cfgs[8].base`. Universal in `emitMixedHierPath` (every arm
cell, reducing or not). **cmp-INVISIBLE** (`ref_obj::Compare` never reads
`VpiFullName`) — dump-only, so it cannot clear a head by itself, but it is
dump bytes on every mixed path in every design. Highest-value next item and
the natural other half of this builder's cleanup.

**R2 — the index constant's `vpiParent` and its ref_typespec's fullname.**
Golden reuses the **package parameter's own constant object**: `vpiParent` is
that parameter's `param_assign` (`@28:18`) and the ref_typespec's fullname is
the enclosing **module** (`work@flash_ctrl`). Ours parents the constant at the
`bit_select` and names the ref_typespec after the path. cmp-invisible on this
head. Pairs naturally with R1.

**R3 — a trailing RANGE select (`[PkgLp-1:0]`) does not fold in this builder.**
Golden `[8 - 1:0]`, ours `[PkgLp - 1:0]` (a2 cell `tr_compound_pkg`). Same law,
a sibling code path inside `emitMixedHierPath` that `idxText34` does not reach.
**Zero corpus population today** (no such name in the Earlgrey only-ours set),
which is why it was not widened into this pass — but it is the cheapest true
extension of § hpMixedIdxPkgFold34 and should be measured before it is written.

**R4 — an OVER-fold, pre-existing and in the opposite direction.** A trailing
indexed part-select folds a **module** localparam that golden leaves spelled:
`a_source[0+:LocLp]` in golden, `a_source[0+:6]` in ours (a2 `tp_bare_loc`).
Unchanged by this pass and **not caused by it**. It is a genuine defect of the
part-select width path, and it is the one place the codebase currently violates
§ hierSelPkgParamFold's own gate.

**R5 — index operator SPACING after a fold.** Golden `[3 + 1]` / `[0+:FromPkg -
FromClog]`, ours `[3 +1]` / `[0+:FromPkg-FromClog]`. `spaceIdxOps` declines to
space an operator whose left neighbour is already a space, which is exactly what
an escaped identifier's trailing space produces. Cosmetic, cell-local, no corpus
population.

**R6 — THE GEN-SCOPE TRIGGER (the second corpus family, and the biggest one).**
Inside an **unrolled generate scope**, golden reduces module-scope localparams
too: `arr[LocLp]` -> `arr[6]`, and `tl_h_i[gi].a_source[0+:(IDW-STIDW)]` ->
`[0+:9 - 5]`, while the **genvar itself never reduces**. Measured on both a2 and
the corpus (`tlul_socket_m1` + `xbar_main`, 3 names). This is a **second,
independent trigger** on top of § hierSelPkgParamFold's declaration-scope one:
the gen-scope clone has substituted its parameters. It is the **entire remaining
naming defect on this design**. Deliberately NOT forked into this pass — it
widens the gate from "declared in a package" to "declared outside the unrolled
clone", which is precisely the shape the standing NAMING-CONTEXT-DEPENDENT
dead-end says must be gated to measured contexts. The cells to start from are
a2's section (7) and the two `tl_h_i` corpus names.

---

## 7. THE FILES IN THIS DIRECTORY

| file | what it is |
|---|---|
| `arm34.sh` | one arm's golden + ours + dumps + cmp. r10earl33's `arm33.sh`, carried forward verbatim (prints the binary md5 on every run; `sed 1d` on both dumps) |
| `a1_idxkind.sv` | **THE INDEX-KIND GRID** — 8 cells: package localparam (the witness), package parameter, qualified `pkg::P`, expression index, module localparam, module parameter, genvar, literal |
| `a2_shape.sv` | **THE SEPARATING GRID** — position (base/trailing) x kind (bit/part/range) x container (flat/generate) x symbol home, with distinct values so no two cells collide on one array element |
| `a3_escaped.sv` | **THE MAXIMAL-HAZARD ARM** — escaped identifiers containing brackets, digits and dots, an escaped array base, and the module-scope escaped negative control |
| `pred34.sh` | **the SOURCE-DERIVED mover fence**, A∧B∧C, computed and recorded before any patched sweep was read |

Reused unchanged and by ABSOLUTE path: `r10uvm55repro/{msdist.sh,ctcan2.sh,canaudit.sh}`,
`r10uvm52repro/canaries.sh`, `r10oth6repro/byteverify.sh`, `r10oth8repro/ct8rows.sh`.
