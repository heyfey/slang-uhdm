# r10earl36 — § patDefBoundShadowedImport36

**THE HEADLINE, FIRST.** The brief called the target "a VALUE-fold law in an
ELABORATED module context" and told me to check WHICH VIEW first. **The view
half is refuted: the head sits in the DEF view**, and the elaborated view of the
same declaration was already byte-identical to golden before this pass. The law
that was missing is not a new fold at all — it is § shadowedImportBoundFold,
which this repo has implemented since r10earl9 for the plain-vector
(`logic_typespec`) carrier, applied to the **packed_array_typespec** carrier
sitting three lines away in the same file. The brief's prediction that "the law
exists, a builder was skipped" (the earl34/earl35 pattern) is **confirmed
exactly**: the helper, the constant-minter and the gate all already existed and
the named-element bound builder simply never called them.

`Earlgrey_0_1/default`'s 42-line head is **CLEARED and ADVANCED**, and the whole
design moved by exactly the 13 dump lines predicted in advance, in
`PREDICTION.md`, from the candidate enumeration.

---

## 0. THE LAW

> **§ patDefBoundShadowedImport36 — a MODULE-LOCAL parameter or localparam of the
> same name does NOT hide a WILDCARD-IMPORTED package member from Surelog's
> name-keyed `getValue`, in a DECLARATION-CARRIED packed-dim RANGE BOUND over a
> NAMED (package struct / enum typedef) element — the packed_array_typespec
> carrier of the rule § shadowedImportBoundFold already implements for the plain
> vector carrier.**
>
> In the DEF (module-compile) view, an `<ident>-<digits>` bound written
> UNQUALIFIED folds to the **package** member's value at the package member's
> own declared width, carrying `ref_typespec -> the package parameter's OWN
> typespec` (which already carries `vpiInstance` = the package). The module's own
> declaration, which the LRM and slang's `Lookup` let shadow the import, is
> **not** what Surelog reads.
>
> The **shadow** is the whole discriminator, and it is symmetric in kind:
> it does not matter whether the module side is a `parameter` or a `localparam`,
> whether the package side is a `parameter`, a `localparam` or an **UNTYPED**
> `localparam`, whether the import sits in the module HEADER or the module BODY,
> or whether the declaration is a PORT or a BODY net. A bound naming a module
> parameter with **no package twin** stays a symbolic `ref_obj` — golden's own
> answer, measured on the target's next source line.

| # | site | what changed |
|---|---|---|
| 1 | `src/TypeEmit.cpp`, the `patPkgPar9` resolution inside `makeTypespec`'s packed_array_typespec `mkBound` (§ patDefBoundPkgParamSubst) | when `Lookup::unqualified` answers "a parameter that is NOT package-homed", re-point through the existing `wildcardPkgParamNamed9` |

`git diff --stat 4296917 -- src include` = **1 file, 52 insertions, 0
deletions** — and 39 of the 52 are the comment. **No new helper, no new
predicate, no new constant-minter**: `wildcardPkgParamNamed9` (§
shadowedImportBoundFold's own instrument) and `pkgBoundValueConst9` (§
patDefBoundPkgParamSubst's own minter) are called exactly as they already stood.

### STATED GATE == CODE GATE

Read verbatim — this is the entire behavioural change:

```cpp
if (!patPkgPar9 && identV && tfContext &&
    idV.find("::") == std::string::npos)
    if (auto* psc9 = declSymbol.getParentScope())
        if (auto* bs9 = Lookup::unqualified(*psc9, idV);
            bs9 &&
            bs9->kind == SymbolKind::Parameter &&
            bs9->getParentScope() &&
            bs9->getParentScope()->asSymbol().kind !=
                SymbolKind::Package)
            if (auto* wp9 = wildcardPkgParamNamed9(psc9, idV))
                patPkgPar9 = wp9;
```

Five conjuncts, and every one is load-bearing with a measured cell behind it:

* `!patPkgPar9` — the existing package-homed arm keeps precedence, so no
  already-correct cell can change (a1 `c_onlypk`, a2 `h_other`).
* `identV && tfContext` — **the DEF-view `<ident>-<digits>` arm only.** The
  `plainIdV` arm is deliberately NOT widened: golden answers the plain-ident
  bound DIFFERENTLY PER VIEW (a1 `a_shp_plain` — the def view takes the package
  value, the elab view keeps the module's), so widening it would have fixed one
  print and broken two. Residue **R1**.
* `idV.find("::") == npos` — a QUALIFIED read is a different rule and golden
  leaves it a bound `ref_obj` (a1 `a_qual`, and the four `alert_pkg::`-qualified
  corpus candidates).
* `kind != SymbolKind::Package` — this is the SHADOW arm; a bound that already
  resolves to a package member is the existing arm's business.
* `wildcardPkgParamNamed9(psc9, idV)` — **the import is load-bearing.** With the
  package member present but NOT imported, golden keeps the symbolic `ref_obj`
  (a2 `n_shp`, `n_body`), and this call is the only thing that abstains there.

The change is **MONOTONE**: it can only convert a bare, unbound `ref_obj` into a
constant, in one arm of one builder, and only when a wildcard-imported package
declares the name. It can add no object anywhere else and can change no other
field — which is why § 4's fence is a formal consequence rather than an
observation.

---

## 1. THE TARGET, MEASURED — and the VIEW question answered FIRST

`Earlgrey_0_1/default` at BASE `4296917`, head measured by me before any edit
(42 cmp lines, quoted whole):

```
LHS constant: , id:927782, line:22:67, endln:22:75
      |vpiDecompile:2  |vpiSize:32  |UINT:2  |vpiConstType:9
      |vpiTypespec: \_ref_typespec: -> \_int_typespec: , line:11:14, endln:11:17
RHS ref_obj: (NumBanks), id:726174, line:22:67, endln:22:75  |vpiName:NumBanks
```

`flash_mp.sv:22` — `input flash_ctrl_reg_pkg::flash_ctrl_reg2hw_mp_bank_cfg_mreg_t
[NumBanks-1:0] bank_cfgs_i`. This is r10earl35's residue **R1**, inherited by
name.

### WHICH VIEW — the brief's first instruction, and the brief is WRONG

The brief: "this is a VALUE-fold law in an **ELABORATED** module context". The
design carries **two** `packed_array_typespec` objects with this range span, and
they are not the same view:

| view | left bound, GOLDEN | left bound, PRISTINE |
|---|---|---|
| **ELAB** (`o.dump:4085016`, the `u_flash_mp` instance) | `constant INT:1 sz64 ct7` (`NumBanks-1` fully evaluated) | **identical** |
| **DEF** (`o.dump:4476943`, the module listing) | `operation op11 { constant UINT:2 sz32 ct9 -> int_typespec 11:14 , constant 1 }` | `operation op11 { ref_obj(NumBanks), constant 1 }` |

**The elaborated view was already right.** The head is the DEF-view listing, and
the fold-rule memory ("DEF view never folds an operation") holds: golden does
NOT fold the operation — it keeps `op11` and substitutes only the **leaf**.

### the int_typespec names WHICH parameter Surelog resolved

Golden's folded constant points at `int_typespec , line:11:14, endln:11:17` whose
`vpiInstance` is `package flash_ctrl_pkg`. That is **flash_ctrl_pkg.sv:11**,
`localparam int NumBanks = top_pkg::FLASH_BANKS` — the PACKAGE member, not
flash_mp.sv:12's `parameter int NumBanks = 2`. Both evaluate to 2, so the VALUE
cannot tell them apart and the typespec identity is the only witness. `flash_mp`
wildcard-imports `flash_ctrl_pkg` at **line 51**, in the module BODY, twenty-nine
lines BELOW the port whose bound it decides.

### the same file already proves we own the law

`flash_mp.sv:26`, `input [AllPagesW-1:0] req_addr_i` — `AllPagesW` is a module
parameter (default 16) AND a `flash_ctrl_pkg` localparam (value 9). PRISTINE
already emits `constant UINT:9 sz32 ct9 -> int_typespec 22:14` and golden's print
is **byte-identical**. Same module, same view, same shadow, same package: only
the CARRIER differs — `logic_typespec` there, `packed_array_typespec` here.

### the head after the patch: CLEARED, and it ADVANCED to another family

```
LHS/RHS hier_path: (flash_ctrl_i.rd), id:90798, line:129:13, endln:129:28
        (flash_phy.sv:129, a port's ACTUAL — a naming-axis head)
48 cmp lines
```

`Earlgrey_0_1/default` stays `CMP_NOTEQUAL` (its ROW does not move, by design);
the new head is an unrelated object in an unrelated file. Residue **R4**.

---

## 2. REFUTATIONS

**F1 — "an ELABORATED module context" is FALSE.** Measured in § 1: the elab
view's bound is `constant INT:1` on both sides and has been for at least a pass.
The head is the DEF-view module listing. Had I patched the elab arm the target
would not have moved and two correct prints would have broken.

**F2 — "a fold-rule / ExprEval question" is FALSE.** No fold is added: the
operation `op11` stays an operation in the def view on BOTH sides, before and
after. What changes is which SYMBOL the leaf resolves to. `ExprEval` is never
reached; `Lookup::unqualified` is.

**F3 — the brief's named owners do not own it.** § fcArgPkgParamValueFolds32
(call-arg folds, concat/repl/pattern abstention) and § hpMixedIdxPkgFold34
(index NAME text) were both grepped and read first. Neither transfers: this is
neither a call argument nor a name render, and the § 32 aggregate-abstention axis
has no cell here. § psBoundPkgParamTs31 is the nearest relative — a pkg-param
fold in a **part_select** bound stamping a ref_typespec — and the ref_typespec
this pass produces comes from `pkgBoundValueConst9`, a DIFFERENT minter with a
different width rule (the package member's own declared width, not 64). The
prior art that actually applied was § shadowedImportBoundFold, which the brief
did not name.

**F4 — MY OWN first hypothesis was refuted by the corpus within the hour.**
Reading only flash_mp.sv:21/22 side by side, the obvious law was *"golden folds a
module PARAMETER bound and keeps a module LOCALPARAM bound symbolic"* —
`NumBanks` is a parameter and folds, `TotalRegions` is a localparam and does
not. a1's `a_shlp` cell (module **localparam** shadowing a package localparam)
folds in golden, and `a_nocoll` (module **parameter**, no twin) does not. **The
parameter/localparam axis is REFUTED in both directions**; the axis is the
SHADOW. Had the grid not been run the patch would have folded every
module-parameter bound in the corpus.

**F5 — "the fold is what golden does to a `$clog2` bound too" is FALSE, and it
is a PRE-EXISTING defect in the other direction.** a1 `a_clog`
(`q36::f_t [$clog2(SH_P)-1:0]`): golden keeps the sys-call operation in the def
view and folds only the pkg leaf inside it; **we fold the whole bound to one
`UINT sz64` constant in all three prints**. That is wrong in PRISTINE and
unchanged by this patch (the arm requires `<ident>-<digits>`, and `$clog2(...)`
is not an identifier), so it is ranked as residue **R2** rather than folded in.

**F6 — a measurement-instrument caveat, stated rather than hidden.**
`bndcen.py` renders an object once per uhdm-dump print. uhdm-dump prints one
object at several depths, and a back-reference print carries no attributes — so a
folded constant appears BOTH as `const[UINT:5 …]` and as `const[None sz- ct-]`
at the same span. Indent is NOT identity (r10earl35's F5) and is folded out of
the key, so the two prints of one object are two multiset entries, not two
objects. Every grid verdict below is read off the ATTRIBUTED entry
(`const[...]->int_typespec@L:C` vs `ref_obj(NAME)`), never off a count.

---

## 3. THE GRID, CELL FOR CELL

`arm36.sh a1_bound.sv` / `a2_noimport.sv`, span-keyed MULTISET counts through
`bndcen.py`, LHS always golden (Surelog). Values are chosen so the package
member and the module declaration DISAGREE, so every cell's constant names which
side Surelog resolved: `q36::SH_P=5` vs module `SH_P=9`, `q36::SH_PP=6` vs `9`,
`q36::SH_IMPL=4` vs `9`, `q36::SH_LP=7` vs `9`, `q36::ONLY_PK=3`.

### 3a. a1_bound.sv — 22 cells, wildcard import in the module BODY (flash_mp's shape)

| cell | shape | GOLDEN | PRISTINE | PATCHED | verdict |
|---|---|---|---|---|---|
| **`a_shp`** | **packed, module PARAM shadowed — THE WITNESS** | `UINT:5 sz32 ct9 ->its@22:14` | `ref_obj(SH_P)` | `UINT:5 sz32 ct9 ->its@22:14` | **FIXED** |
| `a_shpp` | packed, shadowed by a pkg **parameter** | `UINT:6 ->its@24:14` | `ref_obj` | `UINT:6 ->its@24:14` | **FIXED** |
| `a_shimpl` | packed, shadowed by an **UNTYPED** pkg localparam | `UINT:4 ->its@25:3` | `ref_obj` | `UINT:4 ->its@25:3` | **FIXED** |
| **`a_shlp`** | **packed, module LOCALPARAM shadowed** | `UINT:7 ->its@23:14` | `ref_obj` | `UINT:7 ->its@23:14` | **FIXED** |
| **`a_nocoll`** | **packed, module PARAM, NO twin** | **`ref_obj(NOCOLL)`** | `ref_obj` | `ref_obj` | ok |
| **`a_loconly`** | **packed, module LOCALPARAM, NO twin** (flash_mp:21) | **`ref_obj(LOCONLY)`** | `ref_obj` | `ref_obj` | ok |
| `a_shp_plain` | packed, PLAIN ident `[SH_P:0]` | def `UINT:5 sz32 ->its@22:14`, elab `UINT:9 sz32 ->ts` | `UINT:9 sz64` x3 | `UINT:9 sz64` x3 | STILL WRONG — **R1** |
| `a_qual` | packed, written `q36::ONLY_PK-1` | `ref_obj(q36::ONLY_PK)` | same | same | ok |
| `a_clog` | packed, `$clog2(SH_P)-1` | op kept + inner `UINT:5 ->its@22:14` | `UINT:3 sz64` x3 | `UINT:3 sz64` x3 | STILL WRONG — **R2** |
| `a_two` | packed, TWO dims `[SH_P-1:0][NOCOLL-1:0]` | `UINT:5 ->its@22:14` + `ref_obj(NOCOLL)` | `ref_obj`+`ref_obj` | `UINT:5 ->its@22:14` + `ref_obj(NOCOLL)` | **FIXED** (and the no-twin dim correctly left alone) |
| `a_lit` | packed, literal `[3:0]` | `UINT:3`/`UINT:0` | same | same | ok |
| `a_out` | **output**, logic carrier, shadowed | `UINT:5 ->its@22:14` | same | same | ok |
| `b_shp` / `b_shlp` / `b_shimpl` | **logic** carrier, shadowed (param / localparam / untyped) | folded pkg value + its | same | same | ok |
| `b_nocoll` / `b_loconly` | logic carrier, NO twin | `ref_obj` | same | same | ok |
| **`c_shp`** | **packed BODY net, shadowed** (the arm's own head) | `UINT:5 ->its@22:14` | `ref_obj(SH_P)` | `UINT:5 ->its@22:14` | **FIXED** |
| `c_nocoll` | packed BODY net, NO twin | `ref_obj(NOCOLL)` | same | same | ok |
| `c_onlypk` | packed BODY net, pkg-ONLY name (no shadow) | `UINT:3 ->its@26:14` | same | same | ok |
| `c_bshp` / `c_bonlypk` | logic BODY nets | folded | same | same | ok |

**FIXED = 6 cells (7 bounds — `a_two` carries two). unchanged-correct = 14.
STILL WRONG = 2. REGRESSIONS = 0.**

**The separating pair is `a_shlp` against `a_nocoll`.** A module **localparam**
that IS shadowed folds; a module **parameter** that is NOT shadowed does not.
Golden's answer therefore tracks the SHADOW alone and the parameter/localparam
axis — the only axis the corpus's two adjacent lines expose — is REFUTED (F4).

**`a_shimpl` proves the UNTYPED package member is in scope too**: its
`int_typespec` sits at `25:3`, the whole `localparam SH_IMPL = 4;` declaration
span rather than a type token, which is `pkgBoundValueConst9`'s
`dImplicit9` branch answering correctly without being touched.

### 3b. a2_noimport.sv — THE OVER-FIRE CONTROL, and the import is load-bearing

| cell | shape | GOLDEN | PRISTINE | PATCHED | verdict |
|---|---|---|---|---|---|
| **`n_shp`** | packed port, twin exists, **NO import** | **`ref_obj(SH_P)`** | `ref_obj` | **`ref_obj`** | ok — no over-fire |
| `n_bshp` | logic port, twin exists, NO import | `ref_obj(SH_P)` | `ref_obj` | `ref_obj` | ok |
| `n_body` | packed BODY net, twin, NO import | `ref_obj(SH_P)` | `ref_obj` | `ref_obj` | ok |
| `n_blp` | logic BODY net, module localparam, NO import | `ref_obj(SH_LP2)` | `ref_obj` | `ref_obj` | ok |
| **`h_shp`** | packed port, shadowed, **HEADER import** | `UINT:5 ->its@15:14` | `ref_obj(SH_P)` | `UINT:5 ->its@15:14` | **FIXED** |
| `h_other` | packed port, pkg-ONLY name, header import | `UINT:3 ->its@16:14` | same | same | ok |
| `h_bshp` | logic port, shadowed, header import | `UINT:5 ->its@15:14` | same | same | ok |

**FIXED = 1. unchanged-correct = 6. REGRESSIONS = 0.**

`n_shp` / `n_body` are the cells that make the fifth conjunct of the gate
necessary rather than decorative: the package member EXISTS and golden still
keeps the bound symbolic, so "a same-named package member folds the bound" would
have been an over-fire and `wildcardPkgParamNamed9`'s walk is the correct
instrument. `h_shp` shows the import SITE (header vs body) is not an axis.

---

## 4. THE MOVER FENCE — PREDICTED FIRST, THEN MEASURED

`PREDICTION.md` + `pred36.py` were written and run against the **PRISTINE** dump
and the corpus SOURCE **before** either patched sweep was launched. The fence is
not a pattern match but the monotonicity argument of § 0 plus a COMPLETE
candidate enumeration: `pred36.py` lists every bare `ref_obj` bound under a
`packed_array_typespec` range — the only objects the patch can reach.

**13 candidates, 13 prints, on the whole Earlgrey_0_1 design.** Twelve are
excluded by a gate conjunct, each for a stated reason (4 written QUALIFIED; 2 in
`structMemberTsCtx`; `TotalRegions` has no package twin; `N_ESC_SEV` ×2 —
`prim_esc_pkg` declares no `N_ESC_SEV` at all; `NrHarts` ×2 and
`NrHartsAligned` — `dm_csrs` and `rv_dm` carry **no wildcard import**). The
thirteenth is the target.

> PREDICTION: movers = **1** object, `NumBanks` @flash_mp.sv:22:67. Every moved
> dump line is a removed `\_ref_obj:` + `|vpiName:` pair or an added
> `constant`/`ref_typespec`/`int_typespec` group at the SAME span. ADDED outside
> that group = 0; REMOVED outside it = 0. Any mover on a bound golden leaves
> symbolic is an OVER-FIRE and fails the pass.

Measured, PRISTINE dump vs PATCHED dump (both `sed 1d`, whole design):

```
$ diff o.dump p.dump
4476952c4476952
<       \_ref_obj: (NumBanks), line:22:67, endln:22:75
>       \_constant: , line:22:67, endln:22:75
4476955c4476955,4476964
<         |vpiName:NumBanks
>         |vpiDecompile:2
>         |vpiSize:32
>         |UINT:2
>         |vpiTypespec:
>         \_ref_typespec:
>           |vpiParent:
>           \_constant: , line:22:67, endln:22:75
>           |vpiActual:
>           \_int_typespec: , line:11:14, endln:11:17
>         |vpiConstType:9

REMOVED lines: 2     ADDED lines: 11
o lines 4654894      p lines 4654903
```

**One hunk pair in 4.65 million lines, and it is the target's — exactly the
predicted group, nothing else at all.** The added group is byte-for-byte golden's
print from § 1.

### per-shape, against GOLDEN, by MULTISET (`msdist.sh`, dumps `sed 1d`)

| | golden-only | ours-only | MULTISET DISTANCE |
|---|---|---|---|
| pristine vs golden | 238946 | 70392 | **309338** |
| patched vs golden | 238937 | 70392 | **309329** |
| delta | **−9** | **0** | **−9** |

The pristine figure `309338` is bit-identical to the number r10earl35's README
recorded for its own PATCHED build — an independent confirmation that this pass'
PRISTINE build reproduces the landed baseline 4296917. (`o.dump` is also 4654894
lines, r10earl35's patched line count.)

**ADDED and REMOVED accounted separately, per distinct line** — the 13 changed
lines are the complete accounting and it closes exactly:

| line | golden | pristine | patched | \|g−o\| | \|g−p\| |
|---|---|---|---|---|---|
| `\_constant: , line:22:67, endln:22:75` (depth 6) | 2 | 1 | 2 | 1 | **0** |
| `\_constant: , line:22:67, endln:22:75` (depth 10) | 1 | 0 | 1 | 1 | **0** |
| `\_int_typespec: , line:11:14, endln:11:17` | 23 | 22 | 23 | 1 | **0** |
| `|vpiDecompile:2` | 188 | 187 | 188 | 1 | **0** |
| `|vpiName:NumBanks` | 5 | 6 | 5 | 1 | **0** |
| `\_ref_obj: (NumBanks), line:22:67, endln:22:75` | 0 | 1 | 0 | 1 | **0** |
| `\_ref_typespec:` | 244 | 226 | 227 | 18 | 17 |
| `|UINT:2` | 228 | 224 | 225 | 4 | 3 |
| `|vpiConstType:9` | 5790 | 5693 | 5694 | 97 | 96 |
| `|vpiSize:32` | 1018 | 1014 | 1015 | 4 | 3 |
| `|vpiTypespec:` | 9004 | 9002 | 9003 | 2 | 1 |
| `|vpiParent:` | 77691 | 77832 | 77833 | 141 | **142** |
| `|vpiActual:` | 21705 | 21873 | 21874 | 168 | **169** |
| **sum** | | | | **440** | **431** |

**Six distinct line shapes reach EXACT golden parity; five move one instance
closer; two move one instance further** — `|vpiParent:` and `|vpiActual:` at that
one indent, both already in OUR surplus (77832 > 77691 and 21873 > 21705), so
one more generic relation line costs +1 each. That is the honest cost of the fix
and it is stated rather than netted away: **11 improvements, 2 regressions, net
−9**, with the `ours-only` total flat because the two relation-line increments
(+2) exactly cancel the two ours-only removals (the surplus `ref_obj` and the
surplus `|vpiName:NumBanks`).

---

## 5. THE FIVE GATES, each with the number I measured

**BASE printed and grep-checked on every binary.** Both worktrees report
`git rev-parse HEAD` = `42969177aac74db7c595d3707945c7bfbab87071`, and
`git status --porcelain` in the PRISTINE worktree is **empty** (an incremental
`cmake --build` there recompiled nothing and reproduced the same md5).

| binary | md5 | 32-hex asserted |
|---|---|---|
| PRISTINE 4296917 (built here) | `5c2da1b76847bf1f1aaf14cf207eb104` | yes |
| PATCHED | `5500bf4d776745babe113ac3ede66f38` | yes |

**GATE 1 — BUILD.** Absolute path `/tmp/wt_r10earl36/build/slang-uhdm`. Waited
for the link line (`[100%] Linking CXX executable slang-uhdm` -> `[100%] Built
target slang_uhdm`); `grep -c 'error:'` = **0**. md5 asserted in a SEPARATE step
from the build and 32-hex-checked; it differs from pristine. **GREEN.**

**GATE 2 — GOLDENS.** `tests/check_goldens.sh`: **23 PASS / 0 FAIL**. Negative
control `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the harness genuinely
executes the binary under test. **GREEN.**

**GATE 3 — uhdm2rtlil, testflags, `--jobs 2`.**

```
CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2      -> 679/50/2   EXPECTED
dump: 496 match / 183 differ / 52 (blank)              -> 496/183/52 EXPECTED
ct8rows vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
```
The sweep ran `--mode both` (GATE 5 needs both modes' databases). The committed
baseline carries **testflags rows only** (`awk` count of non-testflags baseline
rows = **0**), so the row gate is fed the testflags projection — 731 rows against
731, testflags-to-testflags, exactly the committed gate and not a weakened one.
Feeding it the unprojected CSV first reported "rows moved"; that reading is a
MODE MISMATCH (`base=[] fresh=[…]` on every default row), not a regression, and
it is recorded here because a reader who sees only the green number cannot tell
the two apart. **GREEN.**

**GATE 4 — surelog, BOTH modes, `--jobs 2`.**

```
[default]   CMP_EQUAL 467   CMP_NOTEQUAL 13   -> 467/13  EXPECTED
[testflags] CMP_EQUAL 463   CMP_NOTEQUAL 10   -> 463/10  EXPECTED
ct8rows vs results/golden_surelog.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
dump histograms UNCHANGED both modes:
  default   327 / 242 differ / 225 match    (base == fresh)
  testflags 331 / 298 differ / 165 match    (base == fresh)
```
`Earlgrey_0_1/default` stays `CMP_NOTEQUAL` and `testflags` stays
`SLANG_REJECT` — its ROW does not move, its BYTES do, which is exactly the
target. **GREEN.**

**GATE 5 — BYTE VERIFIER**, `byteverify.sh`, patched vs the PRISTINE 4296917 I
built, **both corpora BOTH modes**, `SELFCHECK=1 SELFCHECK1=1`, movers
attributed per-shape against GOLDEN by MULTISET with ADDED/REMOVED counted
separately (§ 4), and the movers PREDICTED from source-derived data first
(`PREDICTION.md`).

First, the CSVs themselves: **pristine and patched are byte-identical CSVs** for
both corpora in both modes (`diff -q` = no output), so the whole-row gate is
blind inside them by construction — which is the entire reason this gate exists.

```
uhdm2rtlil, BOTH modes:
  PATH_SETS_IDENTICAL (1358 paths)
  MOVERS: 0 / 1358
  SELFCHECK  1357 / 1358 flagged   (the one fixed file matches itself)
  SELFCHECK1 1                     (exactly the one corrupted file)

surelog, BOTH modes:
  PATH_SETS_IDENTICAL (953 paths)
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  <- THE TARGET, predicted
  MOVER ./default/Scoreboard-59431470/slang.uhdm    <- the documented FLAKE, see below
  MOVERS: 2 / 953
  SELFCHECK  952 / 953 flagged
  SELFCHECK1 3                     (1 corrupted + the 2 reported movers)
```

**ONE real mover in 2311 databases, and it is the target.** Its database is
byte-identical to the one dumped and analysed in § 1 and § 4, and the PRISTINE
Earlgrey database from the sweep is byte-identical (`cmp`) to the one used for
the pristine analysis — so the analysis and the gate measure the same bytes.

### the Scoreboard mover is the documented MULTI-STABLE flake, ATTRIBUTED not asserted

Same size on both sides (**11133449 bytes both**), which the standing rule names
as the flake signature. Attributed with a **3-rep run of each binary alone**,
same command line, sequentially:

| binary | rep1 | rep2 | rep3 | size |
|---|---|---|---|---|
| PRISTINE `5c2da1b76847` | `0163f3d48653` | `0163f3d48653` | `9cf807ea56e4` | 11133449 |
| PATCHED `5500bf4d7767` | `1ba839e9c608` | `0735c667b15d` | `1ba839e9c608` | 11133449 |

**Each binary alone produces MORE THAN ONE stable md5 at an identical size**, so
the difference is binary-INDEPENDENT: it is § emitter-nondeterminism
(SourceLocation compares across macro buffers flipping per run under parallel
parse), not an effect of this patch. Cross-pass corroboration: pristine rep3's
`9cf807ea56e4` is the exact md5 r10earl35's README recorded for BOTH of its
binaries. It is also structurally impossible for this patch to reach Scoreboard —
`pred36.py` on it is not needed, because the arm requires a wildcard-imported
package member shadowed by a module parameter used as a NAMED-element packed-dim
bound, and § 4's monotonicity argument confines every reachable line.

**GATE 5 GREEN.**

### CANARIES

| check | result |
|---|---|
| `canaries.sh` vs `golden_surelog.csv` | **ok=52 changed=0 absent=0** unknown-names=7 (7 = the u2r-only names, expected) |
| `canaries.sh` vs `gate_uhdm2rtlil.csv` (testflags projection) | **ok=8 changed=0 absent=0** unknown-names=25 (expected) |
| `ctcan2.sh` EXPECT_UNKNOWN=1 (surelog), baseline FIRST | **PASS** — ok=58 changed=0 absent=0 unknown-patterns=1 |
| `ctcan2.sh` EXPECT_UNKNOWN=6 (u2r), baseline FIRST, mode-matched | **PASS** — ok=1 changed=0 absent=0 unknown-patterns=6 |
| `canaudit.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| `InterfaceModPort` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh |
| `BlackParrotComplex` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh |
| `Earlgrey_0_1` BY NAME | base `default/CMP_NOTEQUAL testflags/SLANG_REJECT` == fresh |

Both `ctcan2` runs are baseline-FIRST and **mode-matched**. The u2r runs are fed
the testflags projection for the same reason GATE 3 is: against the unprojected
CSV both canary scripts report `absent=8` / `absent=1` with `base=[]` on every
**default** row — the committed u2r baseline has no default rows at all. That is
a mode mismatch in the instrument, not a moved canary, and both readings are
printed here so the green one cannot be mistaken for the only one taken.
`InterfaceModPort` and `BlackParrotComplex` carry **no row at all** in the u2r
baseline, so they are checked BY NAME against the surelog CSV, where they do.

The four SLANG-FENCED names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) are dispatched by no driver in this directory — asserted by
`canaudit.sh`, not by a sentence.

---

## 6. RANKED RESIDUES

**R1 — the PLAIN-IDENT packed-dim bound is wrong in BOTH views, and golden
answers the two views DIFFERENTLY.** a1 `a_shp_plain`
(`q36::f_t [SH_P:0]`, no operation): golden's **def** print is
`constant UINT:5 sz32 ct9 -> int_typespec@22:14` (the shadowed PACKAGE value) and
its **two elab** prints are `constant UINT:9 sz32` **with a typespec** (the
module's value at 32 bits); ours is `constant UINT:9 sz64` with **no typespec**
in all three. So there are three separate defects stacked — the def view's
symbol, every view's `vpiSize` (64 vs 32), and every view's missing
`ref_typespec`. This is why the `plainIdV` arm was deliberately NOT widened: the
one-line change that fixes the def print would have written the package value
into the two elab prints, which golden gives the module's. **Fix it by
view, and build the per-view cells first** — a1 already has the witness.

**R2 — a SYS-CALL packed-dim bound is fully folded where golden keeps the
operation.** a1 `a_clog` (`q36::f_t [$clog2(SH_P)-1:0]`): golden's def view keeps
`op11` and substitutes the pkg leaf inside the `$clog2` argument
(`UINT:5 ->its@22:14` at the ARGUMENT's span); its elab view keeps `op11` with a
folded `INT:3 ct7`; ours emits ONE `UINT:3 sz64` constant spanning the whole
bound text in all three prints. **PRE-EXISTING** (measured in PRISTINE) and
untouched here — the arm requires `<ident>-<digits>` and `$clog2(…)` is not an
identifier. § psBoundPkgParamTs31 recorded the mirror-image negative for
part-select bounds ("a bound under a SYS-FUNC CALL stops at the sys_func_call"),
so the sys-call axis is known to be its own rule; this is its
declaration-dim carrier. Corpus population is unmeasured.

**R3 — `int_typespec` at flash_ctrl_pkg.sv:11:14 is still 22 short of golden.**
§ 4's table: golden prints that line 137 times, we now print 115. The patch
closed exactly one. The 22 remaining are OTHER reads of `flash_ctrl_pkg::NumBanks`
that golden types and we do not — the same shape as this pass' head in other
containers. This is the **cheapest true extension** of § patDefBoundShadowedImport36:
enumerate the 22 sites and check which are shadowed bounds in a container the
arm does not cover.

**R4 — the NEW HEAD, and it is a naming axis, not a fold.**
`Earlgrey_0_1/default` after this pass: `hier_path: (flash_ctrl_i.rd)` at
flash_phy.sv:129:13, a `port`'s `vpiActual`, 48 cmp lines, printing IDENTICALLY
on both sides in the first 20 lines of the log — so the divergence is deeper in
the `Compare` order than the print shows and must be localised field-by-field
before anything is written. A different family from every fold law in the
earl29–earl36 chain, and the natural next pass on this design.

**R5 — the `|vpiParent:` / `|vpiActual:` surplus this patch grows by one each.**
§ 4's last two rows. Our design prints 141 more `|vpiParent:` and 168 more
`|vpiActual:` than golden at that one indent, and adding golden's own constant
group necessarily adds one of each. The surplus is a POPULATION difference
elsewhere (objects we emit that golden does not), pre-existing and far larger
than this pass; catalogued so the net `−9` is not mistaken for "nothing moved the
wrong way".

---

## 7. THE FILES IN THIS DIRECTORY

| file | what it is |
|---|---|
| `arm36.sh` | one arm's golden + ours + dumps + cmp. r10earl35's `arm35.sh` carried forward verbatim (prints the binary md5 on every run; `sed 1d` on both dumps; existence-guards every tool because `uhdm-cmp` exits 0 on a missing input; runs in its own scratch dir because Surelog synthesizes `builtin.sv` into the CWD) |
| `a1_bound.sv` | **THE SEPARATING GRID** — 22 cells crossing the bound symbol's KIND (module parameter / module localparam / package parameter / package localparam / UNTYPED package localparam) against the SHADOW (twin / no twin), the CARRIER (`pkg::t [B]` packed_array_typespec vs `logic [B]` logic_typespec), the bound FORM (`X-1` / plain `X` / `$clog2(X)-1` / literal / qualified), depth (one dim / two), position (port / body) and direction. The package and module values DISAGREE by construction, so each cell's constant names which symbol Surelog resolved |
| `a2_noimport.sv` | **THE OVER-FIRE CONTROL** — the same shapes with the wildcard import REMOVED (golden keeps the bound symbolic: the import is load-bearing) and with it moved to the module HEADER (same defect, so the import SITE is not an axis) |
| `bndcen.py` | **the RANGE-BOUND census** — per source line, the MULTISET of `constant`/`ref_obj` bound leaves with value / size / constType and the span of the `int_typespec` behind the `ref_typespec`, which is what names the resolved parameter. Indent is used only to find an object's own attributes and is then folded out of the key (r10earl35 F5) |
| `pred36.py` | **the source-derived MOVER FENCE** — enumerates every bare `ref_obj` bound under a `packed_array_typespec` range, the complete set the patch can reach |
| `PREDICTION.md` | the fence's argument (F1/F2/F3), the 13-candidate table with the exclusion reason for each of the 12 that cannot move, and the prediction, all recorded before either patched sweep was launched |

Reused unchanged and by ABSOLUTE path:
`r10uvm55repro/{msdist.sh,ctcan2.sh,canaudit.sh}`,
`r10uvm52repro/canaries.sh`, `r10oth6repro/byteverify.sh`,
`r10oth8repro/ct8rows.sh`.
