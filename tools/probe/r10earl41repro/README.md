# r10earl41 — § pkgWrittenQualSelBase41 (+ § qualSelBaseNoWhitespace41,
# § selChainDecideBeforeMint41, § scopeRootedPathKeepsColons41)

**THE HEADLINE: r10earl40's two RECORDED LATENT DEFECTS are fixed with a
probe-proven byte/name parity, and its top-ranked residue R1 — the ELABORATED
twin of its own law — is CLEARED to the object: the bare-tail population goes
`24 → 0`, the qualified `var_select` count lands EXACTLY on golden's in BOTH
views (def `4/4`, elab `10/10`), the whole-design multiset distance falls
`308889 → 308773 (−116)`, and the Earlgrey head is BYTE-IDENTICAL to the
witness `r10earl40repro/r6_nexthead.cmp`. Five gates green, ZERO byte movers in
the 1358-database uhdm2rtlil corpus.**

**And the pass's own most useful measurements are TWO REFUTATIONS of rules I
wrote myself.** Qualifying a select's base makes every index ref under it join
with `::` instead of `.`, because `joinRef` switched separator on ANY `::` in
the prefix. My first repair broke `OneThis` and the ROW GATE caught it
(dump `match → differ`); my second broke the protected canary `SVSwitch` in a
way NO ROW COULD SEE and only the BYTE VERIFIER caught it (−5 bytes, both
modes). The discriminator needed FOUR golden cells; all four are now written
into the code and both wrong repairs are kept there by name.

---

## 0. THE LAWS

> **§ pkgWrittenQualSelBase41 — a select whose base is a package member
> WRITTEN WITH ITS QUALIFIER is named `pkg::x`, in the AST (`emitExpr`) path,
> on the `var_select` AND on the `part_select` it carries (`vpiName` and
> `vpiDefName`), and the qualified spelling is what every child ref scopes
> through. THE DISCRIMINATOR IS THE WRITTEN SPELLING, NOT THE SYMBOL'S HOME
> PACKAGE.**
>
> The separating pair is one parameter, one package, one import, two spellings
> (`a1_earl41.sv`, cells b4/b5):
>
> ```
> import q41::*;
> always_comb c_mpr_imp_blit  = A[1][DW-1:0];        golden vpiName: A
> always_comb c_mpr_impq_blit = q41::A[1][DW-1:0];   golden vpiName: q41::A
> ```
>
> A "declared in a package" test — the one `isPkgQualifiedVarRef` and
> `stampFoldedPkgParamTs` use for other purposes — would have qualified the
> BARE cell and moved it AWAY from golden. The name is REBUILT from the symbols
> (`pkg::` + `name`), never sliced from source text; the text is read only to
> answer the yes/no question, whitespace removed first.

> **§ qualSelBaseNoWhitespace41 (F3) — the def-view delegation's qualified base
> is cut out of the WRITTEN TEXT at the first `[`, so any whitespace the author
> wrote inside the name lands inside `vpiName` and every child fullname. Strip
> ALL whitespace.** Golden's name is `q41::A` for all FIVE placements measured
> (before the first selector, between selectors, before `::`, after `::`, all at
> once). Strictly wider than the "trailing space" the defect was recorded as.

> **§ selChainDecideBeforeMint41 (F4) — the multi-selector builder must decide
> its ABSTENTION BEFORE the first `Make*()` call.** It minted a `var_select`,
> an `expr_vec` and children and then returned `nullptr` for a `+:`/`-:`
> selector; the caller correctly fell back, but the minted objects stayed in the
> serializer's arena and were WRITTEN OUT as unreachable garbage — invisible to
> `uhdm-dump`, visible only in BYTES.

> **§ scopeRootedPathKeepsColons41 — "inside a package scope" is a property of
> the path's ROOT, not of any `::` anywhere in it. `joinRef` keeps `::` only
> when the FIRST `::` comes BEFORE the first `.`; once a `.` has been taken
> first, the path is a HIERARCHY and a later `::` is just a qualified name
> inside one segment.** Four golden cells fix it and only this rule fits all
> four (§ 4).

### STATED GATE == CODE GATE

| § | file, site | the gate, verbatim |
|---|---|---|
| `pkgWrittenQualSelBase41` | `src/ExprEmit.cpp`, new member `pkgWrittenQualSelBase41` | `psc41->asSymbol().kind == SymbolKind::Package` **and** whitespace-stripped `rawText(base.sourceRange)` starts with `pn41 + "::"` → returns `pn41 + "::" + symbol.name`; **empty string otherwise, and an empty string leaves every caller byte-identical** |
| | `ExprEmit.cpp` SITE 1 — `RangeSelect` over `ElementSelect` over `NamedValue` | `bnm41` replaces `nvb.symbol.name` at `vs->VpiName`, `baseFull`, `ps->VpiName`, `ps->VpiDefName`, `psFull`, and the three `ips->` fields |
| | `ExprEmit.cpp` SITE 2 — nested `ElementSelect` over `NamedValue` | `bnm41` replaces `nv2.symbol.name` at `vs->VpiName` and `baseFull` |
| `qualSelBaseNoWhitespace41` | `src/TypeEmit.cpp`, earl40's delegation | `qualSelBase40` built char-by-char from `raw.substr(0, lb40)` skipping `isspace` |
| `selChainDecideBeforeMint41` | `src/TypeEmit.cpp`, multi-selector builder | a pre-scan `for (auto* s3 : selChain) if (kind != BitSelect && kind != SimpleRangeSelect) return nullptr;` placed **immediately before** `MakeVar_select()` |
| `scopeRootedPathKeepsColons41` | `src/EmitHelpers.h`, `joinRef` | `c41 = prefix.find("::")`, `d41 = prefix.find('.')`; `c41 != npos && (d41 == npos \|\| c41 < d41)` → `::`, else `.` |

**Four files, 158 inserted / 13 deleted, of which 48 lines are code** — the rest
is the decode above stated where it is enforced. The `selChain` loop's own
`else { return nullptr; }` is now unreachable and is kept, and SAID to be kept,
as a fail-safe should a selector kind ever be added to one list and not the
other.

---

## 1. THE CENSUS, BOTH SIDES, SPAN-KEYED, VIEW-SEPARATED, BEFORE ANY CODE

`census41.py` reads the STORED `|vpiName:` field (never the header's computed
display string, which is a different mechanism and would confuse a name defect
with a parent-chain defect) and separates the views by DUMP SECTION
(`|uhdmallModules:` = def, `|uhdmtopModules:` = elab).

```
Q1  select-family objects with a QUALIFIED stored vpiName        PRISTINE
view   kind                     golden     ours    delta
def    part_select                   7        2       -5
def    var_select                    4        2       -2
elab   part_select                  11        0      -11
elab   var_select                   10        0      -10

Q2  at golden's qualified spans, what do WE emit
def    var_select   BARE_TAIL(R1)  2      MATCH 2
def    part_select  BARE_TAIL(R1)  2      MATCH 2   WE_HAVE_NOTHING 3
elab   var_select   BARE_TAIL(R1) 10
elab   part_select  BARE_TAIL(R1) 10                WE_HAVE_NOTHING 1
```

**THE PREDICTION, made from the pristine dumps alone:**

1. **exactly 24 objects move** — 20 in the elab view (`prim_prince` 106:29,
   106:68, 142:30, 142:86 × FIVE elaborated `gen_fwd_pass`/`gen_bwd_pass`
   instances) and 4 in the def view (81:22, 81:61, 167:15, 167:55, the
   MODULE-LEVEL `always_comb` twins the def view emits through the same AST
   path) — all from `vpiName`/`vpiDefName` BARE_TAIL to golden's qualified name;
2. **SITE 2's corpus footprint is ZERO** — every one of golden's 10 qualified
   elab `var_select`s is the trailing-range shape, so if the patched census
   reports MORE than 10 the law has fired somewhere unmeasured;
3. **F3 moves nothing in the corpus** (zero whitespace occurrences);
4. **F4 moves no DUMP LINE anywhere** (the orphans are unreachable) but must
   move BYTES wherever a def-view multi-selector abstains.

**MEASURED after the build — all four held:**

```
Q1  PATCHED
def    part_select                   7        4       -3     (the 3 are R1', § 8)
def    var_select                    4        4       +0     EXACT
elab   part_select                  11       10       -1     (the 1 is R1')
elab   var_select                   10       10       +0     EXACT
Q2  BARE_TAIL(R1)  24 -> 0 ;  MATCH  def 4+4, elab 10+10
Q3  (the R5 fold caution) 122/29/17/1 — IDENTICAL pristine and patched
```

Prediction 2 is the falsifiable one and it survived: `var_select` landed on
`4` and `10`, not `5` or `11`, so SITE 2 fired **zero** times in Earlgrey.

---

## 2. THE GRID, CELL FOR CELL

`a1_earl41.sv`, 19 measured cells, read by `cells41.py`. **The instrument was
FIXED for this grid**: `cells40.py` keyed the view on an `[i]` in the LHS
fullname, which only separates GEN-FOR cells; this grid's module-level cells
have IDENTICAL def and elab fullnames, so the view is taken from the DUMP
SECTION instead. `G` = golden (Surelog), `O` = ours PRISTINE, `P` = PATCHED.
The column is the select-family `vpiName`s of the assignment's RHS.

### 2a. DEF view

| cell | source | G | O | P | verdict |
|---|---|---|---|---|---|
| `c_ws_none` | `q41::A[g][DW-1:0]` | `q41::A` | `q41::A` | `q41::A` | HOLD |
| `c_ws_trail` | `q41::A [g][DW-1:0]` | `q41::A` | `q41::A `**␣** | `q41::A` | **F3 MOVED** |
| `c_ws_mid` | `q41::A[g] [DW-1:0]` | `q41::A` | `q41::A` | `q41::A` | HOLD |
| `c_ws_coll` | `q41 ::A[g][DW-1:0]` | `q41::A` | `q41 ::A` | `q41::A` | **F3 MOVED** |
| `c_ws_colr` | `q41:: A[g][DW-1:0]` | `q41::A` | `q41:: A` | `q41::A` | **F3 MOVED** |
| `c_ws_all` | `q41 :: A [g] [DW-1:0]` | `q41::A` | `q41 :: A` | `q41::A` | **F3 MOVED** |
| `c_mca_pkg_bk` | module cont-assign | `p41::A` | `A` | `p41::A` | **R1 MOVED** |
| `c_mpr_pkg_bk` | `always_comb`, var index | `p41::A` | `A` | `p41::A` | **R1 MOVED** |
| `c_mpr_pkg_blit` | `always_comb`, literal index (81:22 shape) | `p41::A` | `A` | `p41::A` | **R1 MOVED** |
| `c_mpr_impq_blit` | imported pkg, written QUALIFIED | `q41::A` | `A` | `q41::A` | **R1 MOVED** |
| `c_mpr_pkg_bb` | `p41::A[sel][0]` — SITE 2 | `p41::A` | `A` | `p41::A` | **R1 MOVED** |
| `c_mpr_pkg_three` | `p41::D[sel[0]][1][DW-1:0]` | `p41::D`,`sel` | `D`,`sel` | `p41::D`,`sel` | **R1 MOVED** |
| `c_mpr_imp_blit` | imported pkg, written BARE | `A` | `A` | `A` | **HOLD — the discriminator** |
| `c_mpr_loc_blit` | LOCAL base | `loc` | `loc` | `loc` | HOLD |
| `c_gca_loc_bk` | LOCAL base in a gen block | `loc` | `loc` | `loc` | HOLD |
| `c_mpr_pkg_one` | single `bit_select` on a pkg param | `p41::B` | `p41::B` | `p41::B` | HOLD (already right) |
| `c_gca_pkg_bk` | earl40's own head shape | `q41::A` | `q41::A` | `q41::A` | HOLD (earl40's) |
| `c_mpr_pkg_rng` | single `part_select` on a pkg param | `p41::C` | `C` | `C` | **residue R1'** |
| `c_gca_pkg_bidx` | `+:`/`-:` — the ABSTAIN | `q41::A` | — | — | **residue R3 (earl40's)** |

The trailing space in `c_ws_trail` is invisible at the end of a `vpiName`, so the
witness is the CHILD it propagates into:

```
O  |vpiFullName:work@a1_earl41.gb.q41::A .g      <- a space, inside a fullname
P  |vpiFullName:work@a1_earl41.gb.q41::A.g
G  |vpiFullName:q41::A::q41::A::g                (golden's own chain, § 3)
```

### 2b. ELAB view — every cell reaches golden's name

| cell | G | O | P |
|---|---|---|---|
| `c_ws_none` / `trail` / `mid` / `coll` / `colr` / `all` | `q41::A` | `A` | **`q41::A`** |
| `c_gca_pkg_bk` | `q41::A` | `A` | **`q41::A`** |
| `c_gca_pkg_bidx` (def abstains, elab builds it) | `q41::A` | `A` | **`q41::A`** |
| `c_gca_loc_bk` (LOCAL control) | `loc` | `loc` | `loc` HOLD |

**0 REGRESSED, 5 HOLD-OK, 9 DEF cells + 8 ELAB cells moved their names to
golden.** No cell reaches FULL byte parity, and that is stated rather than
hidden: every remaining difference is the stored-`vpiFullName` residue R2
(§ 8), which golden does not carry on a qualified select and we do.

### 2c. The separating pairs

* **`c_mpr_imp_blit` vs `c_mpr_impq_blit`** — same symbol, same package, same
  import, same construct, differing ONLY in whether the qualifier is written.
  Golden names them `A` and `q41::A`. This is the whole discriminator.
* **`c_gca_loc_bk` vs `c_gca_pkg_bk`** — same generate scope, same selectors,
  differing only in the base's package qualifier (earl40's pair, still holding).
* **`c_ws_none` vs the four whitespace cells** — same expression, same objects,
  differing only in typography.

---

## 3. WHAT GOLDEN STORES, AND THE ONE THING WE STILL STORE

Golden stores **no `vpiFullName` at all** on a qualified `var_select` /
`part_select`, and stores one on a bare/local select (`work@a1_earl41.loc`).
That is the same "store nothing and let `ComputeFullName` walk" mechanism
r10earl40 decoded — and it is why golden's two elaborated `gb[0]`/`gb[1]`
instances of a cell are BYTE-IDENTICAL to each other while ours differ.

**A REFUTATION of r10earl40's own README.** Its residue R2 calls the surplus
`|vpiFullName:` lines "a `uhdm-dump`-visible difference in the parent chain, not
a stored field mismatch". They ARE a stored field: `uhdm-dump` prints the line
only when the field is non-empty (golden's qualified selects print none at all),
and the field is frozen by a GETTER READ — `std::string sf9(vs->VpiFullName())`
in `ModuleEmit.cpp`'s def-view substitution walk, on a getter whose generated
body is `if (!vpiFullName_) { compute; cache; }`. Clearing `syntaxRefPrefix`, as
earl40 did, prevents the WRITE but not the FREEZE. Not fixed here (the read is
in a shared pass and this pass's law does not own it) — restated correctly and
ranked (§ 8, R2).

---

## 4. THE TWO OVER-FIRES I MINTED, AND THE TWO GATES THAT CAUGHT THEM

Qualifying the base makes `baseFull` contain `::`, and `joinRef`'s pre-existing
rule was *"any `::` in the prefix ⇒ join the next segment with `::`"*. So every
index ref under a qualified select came out

```
ours(first attempt) work@prim_prince.gen_fwd_pass[1].prim_cipher_pkg::PRINCE_ROUND_CONST::k
golden              work@prim_prince.gen_fwd_pass[1].prim_cipher_pkg::PRINCE_ROUND_CONST.k
```

**Repair 1 — "…unless the prefix starts with `work@`" — REFUTED by the ROW
GATE.** `OneThis` (uhdm2rtlil) moved dump `match → differ`:

```
prefix work@foo::set + body    golden work@foo::set::body     a CLASS-scoped
repair 1                              work@foo::set.body      subroutine
```

**Repair 2 — "`work@`-rooted AND already dotted ⇒ `.`" — REFUTED by the BYTE
VERIFIER, and by nothing else.** `SVSwitch` (surelog, a PROTECTED canary) moved
−5 bytes in BOTH modes with its CSV row byte-identical, so no row gate, no
histogram and no canary script could see it:

```
prefix work@Receiver::start.bytes + size
   golden   work@Receiver::start::bytes::size
   pristine work@Receiver::start.bytes::size    (the `.bytes` is our older defect, R4)
   repair 2 work@Receiver::start.bytes.size     <- AWAY from golden on the 2nd separator
```

**The rule that survives all four cells** is about the path's ROOT: keep `::`
only when the FIRST `::` precedes the first `.`.

| cell | prefix | first `::` before first `.`? | golden joins with |
|---|---|---|---|
| A `aes_circ_byte_shift` | `aes_pkg::aes_circ_byte_shift.in` | yes | `::` |
| B `OneThis` | `work@foo::set` | yes (no `.` at all) | `::` |
| C `SVSwitch` | `work@Receiver::start.bytes` | yes | `::` |
| D `prim_prince` | `work@prim_prince.gen_fwd_pass[1].prim_cipher_pkg::PRINCE_ROUND_CONST` | **no** | `.` |

Cell D is the shape § pkgWrittenQualSelBase41 creates; before it, **no prefix
with a `.` before its first `::` ever reached `joinRef`**, which is why the
blanket rule survived until now. `OneThis` under the final rule is
byte-identical to its pristine dump AND to its golden (checked directly against
the golden cache, not only through the CSV); `SVSwitch` is byte-identical to
pristine and is no longer a mover. Cell A's 8
`aes_pkg::aes_circ_byte_shift.in::s` lines are untouched — their `.in`
should-be-`::in` is a DIFFERENT defect and is left alone (residue R4).

## 5. F4 — THE ORPHAN, PROVEN IN BYTES ON AN ISOLATING PROBE

`v41_orphan.sv` carries a package-qualified base, so this pass's OTHER change
touches it too and its dump is allowed to move. `orphan41.sh` therefore also
derives **`v41_bare`**, the same abstention driven through a LOCAL array base
that no part of the naming law can reach:

```
                     dump (workdir-path-normalised)      bytes
v41_bare    PRIS/PAT  ab64e4bd…  ==  ab64e4bd…           13579 -> 13424   (-155)
v41_orphan  PRIS/PAT  0949342c…  !=  0eb156b3…           12703 -> 12590   (-113)
v41_ctrl (no abstain) PRIS/PAT   differ (naming only)    12938 -> 12961   (+23)
```

**`v41_bare` is the proof: a BYTE-IDENTICAL dump and 155 fewer bytes.** The
control that never abstains GROWS (+23) by exactly the naming law, which is why
the qualified probe's −113 is a net of the two effects and not the measurement.

---

## 6. THE FIVE GATES

| binary | md5 | 32-hex asserted |
|---|---|---|
| PRISTINE `19730ce` (built here, `/tmp/wt_r10earl41pris/build/slang-uhdm`) | `d90af4f662bab7e66f24bfe6258a8f9b` | yes |
| PATCHED (`/tmp/wt_r10earl41/build/slang-uhdm`) | `0b7bba3fa768a345acb8ab02b6b6ed4c` | yes |

**GATE 1 — BUILD.** Absolute paths, `-j 2`, waited for the LINK line:
`grep -c 'Built target slang_uhdm$'` = 1 on both (the `$` anchor matters —
`slang_uhdm_obj_lib` substring-matches a naive grep). `grep -icE 'error:'` = 0
on both. md5 taken in a SEPARATE step and asserted at 32 hex.
`git status --porcelain` in the PRISTINE worktree = 0 lines at
`19730ce655fe913bbd12a503d5ef9599e09225f3`. **GREEN.**

**GATE 2 — GOLDENS.** `SLANG_UHDM` exported and echoed with its md5 (the script
SILENTLY DEFAULTS it to the main tree): **23 PASS / 0 FAIL**. Negative control
`SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL**. **GREEN.**

**GATE 3 — uhdm2rtlil, `--mode both`, `--jobs 2`**, own `--out`/`--workdir`.

```
[default]   CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2  -> 679/50/2  EXPECTED
[testflags] CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2  -> 679/50/2  EXPECTED
dump (testflags): 496 match / 183 differ / 52 blank        -> 496/183/52 EXPECTED
ct8rows vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
```

The committed baseline carries testflags rows only, so the row gate is fed the
TESTFLAGS PROJECTION, 731 against 731. **GREEN.** *(The FIRST binary of this
pass failed this gate at 495/184 with `OneThis` moving — § 4. The number above
is the corrected build; the failing one is recorded, not hidden.)*

**GATE 4 — surelog, BOTH modes, `--jobs 2`**, run **sequentially** (one
invocation per mode) so the documented `SURELOG_FAIL` detail-row race under
concurrent sweeps cannot fire. `GOLDEN_DEFER` left UNSET.

```
[default]   CMP_EQUAL 469  CMP_NOTEQUAL 11  SURELOG_FAIL 25  DEFERRED 5  -> 469/11  EXPECTED
[testflags] CMP_EQUAL 465  CMP_NOTEQUAL  8  SURELOG_FAIL 23  DEFERRED 5  -> 465/8   EXPECTED
ct8rows vs results/golden_surelog.csv: 0 differing ROWS (0 diff row-sides), 1588 vs 1588
dump histograms UNCHANGED both modes: default 325/244/225, testflags 329/300/165
```

**GREEN.** Raw output, the canaries and the boundary arms: `GATE4.md`.

**GATE 5 — BYTE VERIFIER**, `byteverify41.sh`, PATCHED vs the PRISTINE
`19730ce` built here, both corpora, both modes. uhdm2rtlil:

```
databases patched=1358 pristine=1358  PATH_SETS_IDENTICAL  MOVERS: 0 / 1358
SELFCHECK=1  -> 1357 / 1358 flagged     SELFCHECK1=1 -> 1
```

surelog:

```
databases patched=953 pristine=953  PATH_SETS_IDENTICAL  MOVERS: 2 / 953
  MOVER ./default/Earlgrey_0_1-71da2fd7  patched=db5d5f79efc7 pristine=c2384ffe6132  +855 bytes
  MOVER ./default/Scoreboard-59431470    patched=8e9695a9e7cf pristine=9d3fd083f4f1  SAME SIZE
SELFCHECK=1 -> 952 / 953 flagged        SELFCHECK1=1 -> 3  (= 1 corrupted + 2 movers)
```

`Scoreboard` is arbitrated by the stated law and is a FLAKE: SAME SIZE, and
**three runs of the unmodified PRISTINE binary give three different md5s**
(`9d3fd083…`, `8a2c4827…`, `ed015f92…`) at a constant 11122938 bytes — the
documented emitter nondeterminism, not this patch. **The one REAL mover in 2311
databases is `Earlgrey_0_1/default`, the target, named by the verifier itself.**
Both mandatory controls fire on both corpora. **Zero movers on 1358 uhdm2rtlil
databases is itself a measurement**: the whole change is confined to the surelog
corpus. Raw output in `GATE4.md`. **GREEN.**

---

## 7. MOVERS PER SHAPE, vs GOLDEN, BY MULTISET, ADDED AND REMOVED SEPARATELY

```
golden vs PRISTINE : golden-only 238568   ours-only 70321   MULTISET DISTANCE 308889
golden vs PATCHED  : golden-only 238510   ours-only 70263   MULTISET DISTANCE 308773
                                                            improvement         -116
dump lines 4 655 201 -> 4 655 201   (UNCHANGED)   144 lines rewritten in place
```

The pristine distance **308889 is byte-for-byte the value r10earl40 recorded for
its own PATCHED build** — an independent confirmation that this baseline really
is that pass's landed successor.

Per-shape closure (`202` distinct line shapes changed):

```
SUM|g-o| over changed shapes = 202
SUM|g-p| over changed shapes =  86
                  difference = 116   ==   308889 - 308773
shapes reaching EXACT golden parity: 128 / 202
```

**Closes to the unit**, so no line outside the changed shapes moved.

```
REMOVED 144 line instances over 101 shapes
ADDED   144 line instances over 101 shapes
```

The load-bearing ones, with golden's own counts:

```
-12 |vpiName:PRINCE_ROUND_CONST          (g 0)   +12 |vpiName:prim_cipher_pkg::PRINCE_ROUND_CONST   (g 14)
-11 |vpiName:PRINCE_ROUND_CONST          (g 0)   +11 |vpiName:prim_cipher_pkg::PRINCE_ROUND_CONST   (g 13)
-11 |vpiDefName:PRINCE_ROUND_CONST       (g 0)   +11 |vpiDefName:prim_cipher_pkg::PRINCE_ROUND_CONST(g 13)
```

(the two `|vpiName:` rows are the two indentation depths, which the shape key
keeps distinct.)

**74 shapes move AWAY from golden, and EVERY ONE of them has `golden = 0` and
`ours-pristine = 0`** — they are the new *display* strings (`\_var_select:
(work@…prim_cipher_pkg::…)`, `|vpiFullName:work@…`) that replaced 74 old display
strings golden also lacked. Mechanically:

```
shapes moving TOWARD golden 128, distance gained 202
shapes moving AWAY         74, of which with golden count > 0:  0
```

**No line moved away from golden at a position where golden has one.** The
object-level census (§ 1) is the authority and it reports the target population
at 0.

**The head is UNCHANGED, as the brief required.** `pat/cmp.log` is byte-identical
to `pris/cmp.log` AND to `r10earl40repro/r6_nexthead.cmp` (the `param_assign`
concat reorder at `13:59-18:4`, 154 lines). `prim_prince`/`PRINCE` appear 0 times
in it. This pass's law provably does not own that head and did not touch it.

---

## 8. RANKED RESIDUES

**R1' — the SINGLE-selector package select, name AND span.** Golden names a lone
`part_select` on a package parameter `prim_cipher_pkg::PRINCE_ALPHA_CONST` and
anchors it AT THE SELECTOR; we name it `PRINCE_ALPHA_CONST` and span the whole
written expression. Measured population: **3 def spans + 1 elab span**
(`prim_prince` 59:55, `dm::ResumeAddress` 273:67, `dm::HaltAddress` 471:75), and
grid cell `c_mpr_pkg_rng` reproduces both halves. Deliberately outside this law
(which is the multi-selector twin of earl40's) because the NAME fix alone would
not join the span-keyed census, and the span change touches the `psel` site that
serves 3223 part_selects. Top-ranked next step in this family. NOTE: the single
`bit_select` form is ALREADY correct (`c_mpr_pkg_one`), so the fix is
part_select-only.

**R2 — the stored `vpiFullName` on a qualified select (restated correctly).**
Golden carries none; we carry one, frozen by a getter READ in `ModuleEmit.cpp`'s
def-view substitution walk (§ 3). It is the whole of the 74 "moved away" shapes
and the reason no grid cell reaches full byte parity. Cheap to test (guard the
read), but it is a SHARED pass and needs its own census.

**R3 — the `+:`/`-:` abstain (earl40's, unchanged).** `c_gca_pkg_bidx` DEF still
falls back to the pasted-text `ref_obj`; its ELAB twin now carries the right
name. F4 only stopped it LEAKING; extending the selector loop is still open, and
golden's answer is fully decoded in earl40's arm.

**R4 — a package/class-rooted path takes a `.` where golden takes `::`.** Two
independent witnesses found while fixing `joinRef` and deliberately not touched:
`aes_pkg::aes_circ_byte_shift.in::s` (8 lines; golden `...::in::s`) and
`work@Receiver::start.bytes::size` in `SVSwitch` (golden
`work@Receiver::start::bytes::size`). Both are the SEGMENT BEFORE the one this
pass's rule governs, i.e. a different emitter writing a `.` into a scope-rooted
path. Self-contained and now witnessed in two corpora.

**R5 — the elab fold caution, re-measured and UNMOVED.** 122 `bit_select`, 29
`indexed_part_select`, 17 `bit_select`-where-golden-has-`ref_obj` and 1
`part_select` sit at elab spans where golden has no select at all (it folds).
Identical pristine and patched — this pass neither helped nor hurt it, and it is
a different law (constant folding of package parameters).

**R6 — the Earlgrey head**, `param_assign` concatenation operand REORDER at
`13:59-18:4` with `vpiReordered:1`. Untouched and unchanged; witness carried
forward.

---

## 9. LANDING HYGIENE

**No `README.verifier.md` is shipped in this directory.** This pass's record is
written by the IMPLEMENTER and says so; an implementer-authored file named
`README.verifier.md` is exactly what r10earl40's verifier had to replace, and
carrying an earlier pass's verifier record forward would be worse. Everything in
this file is a run whose command and binary md5 are printed by the script that
produced it.

Files here: `census41.py` (both-sides span-keyed census, view-separated),
`cells41.py` (cell grid, SECTION-keyed views), `a1_earl41.sv` (19 cells),
`arm41.sh`, `v41_orphan.sv` + `orphan41.sh` (F4 in bytes, with the isolating
bare-base case), `msdist.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`,
`canaudit.sh`, `byteverify41.sh`, and `GATE4.md` with the raw surelog-side gate
output, the canaries and the fenced boundary arms.
