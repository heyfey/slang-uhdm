# r10earl40 — § pkgScopedMultiSelVarSelect40

**THE HEADLINE: the 100-line head on `Earlgrey_0_1/default` at
`prim_prince.sv:105-106` is CLEARED, and the brief's central instruction —
"transcribe golden's select-scoped and DOUBLED fullnames rather than derive
them" — is REFUTED by measurement. Those two strings are not a convention to
copy. They are one `ComputeFullName()` walk over two different `vpiParent`
chains, and the way to reproduce them is to STORE NOTHING.**

Two spans move in a 4 655 093-line dump, both in `prim_prince`; the whole-design
multiset distance to golden falls **308941 → 308889 (−52)**, the diff is
**2 hunks, 4 lines removed, 112 added**, and the byte verifier finds **exactly
one real mover in 2311 databases** across both corpora and both modes — the
target itself.

---

## 0. THE LAW

> **§ pkgScopedMultiSelVarSelect40 — a PACKAGE-SCOPED name carrying TWO OR MORE
> SELECTORS (`pkg::ARR[i][h:l]`) is a SELECT, not a name. In `emitSyntaxExpr` —
> the DEF-view generate emitter's expression path — it must build the SAME
> `var_select` + `vpiIndex` structure that a BARE base already builds, with the
> QUALIFIED written spelling as the base name, and it must STORE NO
> `vpiFullName` anywhere in the subtree.**
>
> **The structure was already implemented.** The multi-selector `var_select`
> builder has existed since `MultirangesStartNotFromZero`. The only thing that
> kept a qualified base out of it is a parse shape: the builder's base must be
> an `IdentifierName`, and `pkg::X[i][j]` parses as a `ScopedName` whose RIGHT
> is the `IdentifierSelectName`. So this pass is a **DELEGATION, not a second
> builder** — and the existing builder's whole policy grid (bit+range →
> `part_select`, bit+indexed-range → `indexed_part_select`, bit+bit → constant
> index, genvar / param / literal / expression indices) comes with it unchanged.
>
> **NO STORED FULLNAME.** Golden's `var_select` and `part_select` carry none,
> and its index refs carry one that depends on the PARENT CHAIN, not on the
> enclosing scope. The select builder already spells "store nothing" as
> "`syntaxRefPrefix` is empty" — every `VpiFullName` call in it is guarded on
> that prefix — so **clearing the prefix for the duration is the whole
> implementation of the naming law**.
>
> **SCOPE: TWO OR MORE SELECTORS.** A single-selector package select is a
> DIFFERENT span policy (golden anchors a lone `bit_select`/`part_select` AT THE
> SELECTOR, not over the written text) and Earlgrey contains none in this
> position — measured, not assumed (§ 1).

### STATED GATE == CODE GATE

`src/TypeEmit.cpp`, `emitSyntaxExpr`'s `ScopedName` arm, immediately before the
unconditional pasted-text `ref_obj` fallback — so **everything that folded
before still folds**, and only the object that WOULD have become the pasted-text
`ref_obj` is redirected. Verbatim:

```cpp
                if (const auto* isn40 =
                        syn.as<syntax::ScopedNameSyntax>()
                            .right->as_if<syntax::IdentifierSelectNameSyntax>()) {
                    auto lb40 = raw.find('[');
                    if (isn40->selectors.size() > 1 &&
                        lb40 != std::string::npos && lb40 > 0) {
                        std::string savedPfx40 = syntaxRefPrefix;
                        qualSelBase40 = raw.substr(0, lb40);
                        syntaxRefPrefix.clear();          // policy (1)
                        auto* sel40 = emitSyntaxExpr(*isn40, parent);
                        syntaxRefPrefix = savedPfx40;
                        qualSelBase40.clear();
                        if (sel40) {
                            setLoc(sel40, syn.sourceRange());   // policy (2)
                            return sel40;
                        }
                        // The delegate ABSTAINED: fall through to the ref_obj
                        // below — an unchanged wrong object, never a half-built
                        // one.
                    }
                }
```

and, in the receiving arm, the base name and its **unconditional consumption**
(so a select written inside an index can never inherit the outer base):

```cpp
            std::string chainBase;
            std::string qualBase40;
            qualBase40.swap(qualSelBase40);
...
                chainBase = qualBase40.empty()
                                ? std::string(isnW.identifier.valueText())
                                : qualBase40;
```

`chainBase`'s type changes from `std::string_view` to `std::string` because it
may now own a synthesised qualified spelling instead of pointing into the token.

**Two production files, 26 code lines** (`include/UhdmExporter.h` +8, of which 1
is code; `src/TypeEmit.cpp` +95, of which 25 are code and 70 are the comment
stating this law and its measurements). `qualSelBase40` has **exactly one writer
and one reader**, both shown above.

---

## 1. THE CENSUS, BOTH SIDES, SPAN-KEYED, BEFORE ANY CODE

`census40.py` reads both 4.8M/4.6M-line dumps and tallies select-family object
headers by `(kind, name-contains-`::`, name-contains-`[`)`. Our defect has a
signature readable on ONE line — a `ref_obj` whose `vpiName` is the ENTIRE
written text of a select, so it contains both `::` and `[`. Golden never writes
such a name.

```
=== OUR PASTED-TEXT ref_obj  (name has BOTH `::` and `[`)
count = 2 distinct spans
golden object kinds at those same spans:   var_select   2

   106:29-106:82   OURS=prim_cipher_pkg::PRINCE_ROUND_CONST[k][DataWidth-1:0]
                   GOLD=var_select (prim_cipher_pkg::PRINCE_ROUND_CONST)
   142:30-142:100  OURS=prim_cipher_pkg::PRINCE_ROUND_CONST[10-NumRoundsHalf+k][DataWidth-1:0]
                   GOLD=var_select (prim_cipher_pkg::PRINCE_ROUND_CONST)
```

**THE PREDICTION, made from the pristine dump alone: exactly 2 spans move, both
in `prim_prince`, both from `ref_obj` to `var_select`; 4 lines removed
(2 objects × header + `|vpiName:`) and a subtree added at each.** Measured after
the build: **2 hunks, 4 removed, 112 added, net +108** — nothing else in
4.6 million lines.

`142:30` is the BACKWARD pass and it is **not** the head's twin by shape: its
index is the EXPRESSION `10-NumRoundsHalf+k`, not a bare genvar. It came along
because the law is indifferent to index kind — which the grid then proves cell
for cell.

### The full family deficit, and why the law stops where it does

Golden has **8 distinct spans** design-wide with a qualified-name `var_select`:

| golden span class | count | ours | verdict |
|---|---|---|---|
| already QUALIFIED on our side (`aes_pkg::aes_transpose::in`) | 4 | correct | **HOLD** |
| we build the structure but name the base BARE (prim_prince 81:22 etc.) | 2 | wrong NAME | **residue R1** |
| we paste the whole text into one `ref_obj` | **2** | wrong STRUCTURE | **THIS PASS** |

So the family splits into two independent defects — a STRUCTURE defect (the
def-view syntax path, 2 spans, cleared here) and a NAME defect (the elaborated
`emitExpr` path, which names the base with its bare tail, R1). **Only the
structure defect is the head**, and the single-selector package select does not
occur in this position anywhere in Earlgrey — which is what licenses the law's
"two or more selectors" boundary as a MEASURED one rather than a convenient one.

---

## 2. THE GRID, CELL FOR CELL

`a1_sel40.sv` (51 cells) crosses **BASE SCOPE** × **SELECT SHAPE** × **INDEX
KIND** × **CONTEXT**, read by `cells40.py` (object-level, **VIEW-KEYED** — the
def listing and the elaborated `gen_scope` are separated by the `[i]` the
elaborated fullname carries, because r10earl32's `cells32.py` collapsed them
onto one row and printed only the first, and that is recorded as that pass's own
instrument defect). `G` = golden (Surelog), `O` = ours PRISTINE, `P` = PATCHED.

### 2a. What the delegation does — the structure axis

| cell | shape | O kind | P kind | G kind | verdict |
|---|---|---|---|---|---|
| `c_gca_pkg_bk_rsym` | **THE HEAD** `pkg::ARR[k][DW-1:0]` | `ref_obj`(text) | **`var_select`** | `var_select` | **STRUCTURE MOVED** |
| `c_gca_pkg_blit_rsym` | literal index | `ref_obj`(text) | **`var_select`** | `var_select` | STRUCTURE MOVED |
| `c_gca_pkg_bexpr_rsym` | `[k-1]` EXPRESSION index | `ref_obj`(text) | **`var_select`** | `var_select` | STRUCTURE MOVED |
| `c_gca_pkg_bparam_rsym` | localparam index | `ref_obj`(text) | **`var_select`** | `var_select` | STRUCTURE MOVED |
| `c_gca_pkg_bb` | `[k-1][7:0]` on a 4×8 array | `ref_obj`(text) | **`var_select`** | `var_select` | STRUCTURE MOVED |
| `c_gca_pkg_bbit` | `[k][0]` — **bit+bit** | `ref_obj`(text) | **`var_select`** | `var_select` | STRUCTURE MOVED |
| `c_gca_pkg_bidx` | `[k][DW-1 -: 8]` | `ref_obj`(text) | `ref_obj` | `var_select`+`ips` | ABSTAINED → R3 |
| `c_gca_pkg_bidxa` | `[k][0 +: 8]` | `ref_obj`(text) | `ref_obj` | `var_select`+`ips` | ABSTAINED → R3 |
| `c_gif_pkg_bk_rsym` | nested **gen-if inside gen-for** | `ref_obj`(text) | **`var_select`** | `var_select` | STRUCTURE MOVED |
| `c_gife_pkg_bk_rsym` | the **gen-ELSE** (untaken) arm | `ref_obj`(text) | **`var_select`** | `var_select` | STRUCTURE MOVED |
| `c_gift_pkg_blit_rsym` | **top-level gen-if** CA | `ref_obj`(text) | **`var_select`** | `var_select` | STRUCTURE MOVED |

**11 cells change kind from the pasted-text `ref_obj` to golden's `var_select`,
across gen-for bodies, gen-if branches, gen-else arms, top-level gen-ifs and
nested generate scopes, and across genvar / literal / localparam / expression
indices.** The abstention on `+:` / `-:` is stated, not hidden: the existing
builder's multi-selector loop supports `BitSelect` and `SimpleRangeSelect` and
returns `nullptr` for an indexed range, and the delegation's `if (sel40)` guard
turns that into **the unchanged old object rather than a half-built new one**.

### 2b. The cells that must NOT move — and did not

| cell | what it is | O | P | verdict |
|---|---|---|---|---|
| `c_gca_pkg_nosel` | **bare `pkg::W40`, no select** | `ref_obj` | `ref_obj` | **HOLD** — untouched |
| `c_gca_pkg_whole` | **whole array `pkg::ARR40`, no select** | `ref_obj` | `ref_obj` | **HOLD** — untouched |
| `c_mca_pkg_nos` | bare pkg param, module CA | = G | = G | **HOLD-OK** |
| `c_gca_loc_bk_rsym` | **LOCAL** base `loc40[k][DW-1:0]` | = G | = G | **HOLD-OK** |
| `c_gca_loc_bonly` | local base, one selector | = G | = G | **HOLD-OK** |
| `c_gif_loc_bk_rsym` | local base in nested gen-if | = G | = G | **HOLD-OK** |
| `c_mca_loc_br` | local base, module CA | = G | = G | **HOLD-OK** |

**The two NO-SELECT cells are the controls that matter most** — a bare package
name must never be dragged into a `var_select` — and both are byte-unchanged.
**9 HOLD-OK cells, 0 REGRESSED, in the whole 51-cell grid.**

### 2c. The separating pair that isolates the discriminator

`c_gca_loc_bk_rsym` vs `c_gca_pkg_bk_rsym`: **the same source shape, the same
generate scope, the same selectors — differing only in whether the base carries
a package qualifier.** The local one was already golden-identical; the qualified
one was a pasted string. That holds the generate nesting, the index kind and the
select shape fixed and isolates **the base's PARSE SHAPE** as the whole
discriminator, which is exactly what the law says.

---

## 3. THE BRIEF'S NAMING INSTRUCTION, REFUTED BY MEASUREMENT

The brief said to note "the SELECT-SCOPED fullname convention on index refs
(including the DOUBLED scope on the part_select range refs)" and that whoever
took this head should **"transcribe those strings rather than derive them."**

Transcribing either one would have been wrong, and the arm proves it with two
cells of **identical source shape**:

```
a1_sel40 76:32   pkg select is a cont-assign's WHOLE RHS
   golden index ref k  ->  p40::ARR40::p40::ARR40::k                  (`::`, no scope)
prim_prince 106:29   pkg select is an OPERAND of `^`
   golden index ref k  ->  work@prim_prince.gen_fwd_pass.prim_cipher_pkg::PRINCE_ROUND_CONST.k
```

Same construct, same package-parameter base, same two selectors — **two
completely different strings, with different separators**. They are not two
conventions. They are `UHDM::ComputeFullName()` walking two different
`vpiParent` chains: in the arm golden parents the whole-RHS select at the
resolved PACKAGE PARAMETER (so the walk terminates in a package and joins with
`::`), and in Earlgrey it parents it at the enclosing `operation` (so the walk
reaches the generate scope and joins with `.`). The "DOUBLED" scope is the same
mechanism seen twice: a `part_select` and its parent `var_select` **both carry
the base name**, so a ref beneath the part_select picks the base up twice.

**Storing nothing reproduces both.** Our patched output at the head is
character-identical to golden on every ref:

```
ours   |vpiFullName:work@prim_prince.gen_fwd_pass.prim_cipher_pkg::PRINCE_ROUND_CONST.k
golden |vpiFullName:work@prim_prince.gen_fwd_pass.prim_cipher_pkg::PRINCE_ROUND_CONST.k
ours   ...PRINCE_ROUND_CONST.prim_cipher_pkg::PRINCE_ROUND_CONST.DataWidth   (the DOUBLED one)
golden ...PRINCE_ROUND_CONST.prim_cipher_pkg::PRINCE_ROUND_CONST.DataWidth
```

This is the same lazy-memoising-getter mechanism r10earl39 found and named as
its own second effect. That pass learned that **reading** the getter too early
freezes a wrong name; this pass learns the complement — **writing** the field at
all freezes a name that golden lets the walk decide.

---

## 4. THE HEAD IS CLEARED — the order-independent proof

`uhdm-cmp` reports only ONE head, so "the head changed" is never by itself proof
that the old one cleared: a NEW head earlier in walk order would mask it. Three
independent instruments say it genuinely cleared.

1. **`prim_prince` and `PRINCE` appear ZERO times in the new `cmp.log`** (`grep
   -c` = 0), and the new head is a different construct in a different file — a
   `param_assign` concatenation at `13:59-18:4` whose operands we emit in
   reverse with `vpiReordered:1`. That is the **operand-order** family, not a
   select at all.
2. **The census population went 2 → 0.** No pasted-text `ref_obj` survives
   anywhere in the design.
3. **The decisive one — a direct subtree diff of golden against ours at
   `106:29`**, which does not depend on cmp's walk order at all. Every field
   matches character for character: `vpiName`, the `vpiIndex` `ref_obj k` with
   its full string, the `part_select`'s `vpiName` / `vpiDefName` /
   `vpiConstantSelect:1`, the `vpiLeftRange` `operation` with `vpiOpType:11`,
   the `DataWidth` ref with its doubled fullname, and both bound constants. The
   **only** difference is two `|vpiFullName:` display lines on the `var_select`
   and the `part_select` (residue R2 below).

**Say the number out loud so it is not misread: the cmp log grows from 100 lines
to 154.** That is NOT a regression. A cmp log prints the first divergent object
IN FULL, so its length is **HEAD DEPTH, never a distance** — the new head is a
four-operand concatenation and simply prints bigger. Every instrument that IS a
distance moves the right way (§ 5).

---

## 5. MOVERS PER SHAPE, vs GOLDEN, BY MULTISET, ADDED AND REMOVED SEPARATELY

```
golden vs PRISTINE : golden-only 238648   ours-only 70293   MULTISET DISTANCE 308941
golden vs PATCHED  : golden-only 238568   ours-only 70321   MULTISET DISTANCE 308889
                                                            improvement          -52
dump lines 4 655 093 -> 4 655 201   (+108)      diff: 2 hunks, 4 removed, 112 added
```

The pristine distance **308941 is byte-for-byte the value r10earl39 recorded for
its own patched build**, and my pristine binary's md5 is **identical to earl39's
patched md5** — two independent confirmations that this pass's baseline really
is the landed `06d0fcd`.

Per-shape closure (`67` distinct line shapes changed):

```
SUM|g-o| over changed shapes = 2644
SUM|g-p| over changed shapes = 2592
                  difference =   52   ==   308941 - 308889
shapes reaching EXACT golden parity: 35 / 67
```

**Closes to the unit**, so no line outside the changed shapes moved.

**REMOVED — all 4 lines, the entire removal set:**

```
-1  \_ref_obj: (prim_cipher_pkg::PRINCE_ROUND_CONST[k][DataWidth-1:0]), line:106:29...
-1  |vpiName:prim_cipher_pkg::PRINCE_ROUND_CONST[k][DataWidth-1:0]
-1  \_ref_obj: (prim_cipher_pkg::PRINCE_ROUND_CONST[10-NumRoundsHalf+k][DataWidth-1:0])
-1  |vpiName:prim_cipher_pkg::PRINCE_ROUND_CONST[10-NumRoundsHalf+k][DataWidth-1:0]
```

Golden has **0** of each. Exactly the two predicted objects, and nothing else.

**ADDED** — 112 lines building the two subtrees. The load-bearing ones reach
golden's count exactly: `|vpiConstantSelect:1` 263→**265** (g 265),
`|vpiLeftRange:`/`|vpiRightRange:` 166→**168** (g 168), `|vpiOpType:11`
222→**225** (g 225), `|vpiName:DataWidth` 5→**7** (g 7).

**17 shapes move AWAY from golden, and none is a new defect:**

* **13 are the two dump-computed display names** (`\_var_select: (work@…)`,
  `\_part_select: … (work@…)`, `|vpiFullName:work@…`) — residue R2. Golden has
  0 of these exact lines because its walk produces a shorter string.
* **4 are anonymous field labels counted design-wide** where we ALREADY had a
  surplus before this pass: `|vpiIndex:` g 1602 / o 1634 / p 1638,
  `|vpiConstType:9` g 4175 / o 4185 / p 4187, `|UINT:1` g 705 / o 710 / p 712,
  `|vpiDecompile:1` g 691 / o 696 / p 698. Adding CORRECT objects at correct
  positions necessarily raises the global count of an anonymous label while a
  surplus stands elsewhere. **No line moved away from golden at a position where
  golden has one**; the object-level census (§ 1) is the authority and it
  reports the target population at 0.

---

## 6. THE FIVE GATES

| binary | md5 | 32-hex asserted |
|---|---|---|
| PRISTINE `06d0fcd` (built here, `/tmp/wt_r10earl40pris/build/slang-uhdm`) | `bbee9562c6a92d50d76199f32bf20f22` | yes |
| PATCHED (`/tmp/wt_r10earl40/build/slang-uhdm`) | `cec108c6e20de62bf9cb090c41d59ba6` | yes |

**GATE 1 — BUILD.** Absolute paths above. Both builds waited for the LINK line
(`grep -c 'Built target slang_uhdm$'` = 1 each; the anchor matters because
`slang_uhdm_obj_lib` substring-matches a naive grep). `grep -icE 'error:'` = **0**
on both. md5 taken in a SEPARATE step, asserted at 32 hex, and different between
the two. `git status --porcelain` in the PRISTINE worktree = **0 lines** at
`06d0fcde21386b7a1b0de9615d951613cbd4e85c`. **GREEN.**

**GATE 2 — GOLDENS.** `tests/check_goldens.sh` with `SLANG_UHDM` exported and
echoed with its md5 (the script defaults it to the MAIN TREE): **23 PASS /
0 FAIL**. Negative control `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL**.
**GREEN.**

**GATE 3 — uhdm2rtlil, `--mode both`, `--jobs 2`**, own `--out`/`--workdir`.

```
[default]   CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2   -> 679/50/2   EXPECTED
[testflags] CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2   -> 679/50/2   EXPECTED
dump (testflags): 496 match / 183 differ / 52 blank             -> 496/183/52 EXPECTED
ct8rows vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
```

The committed baseline carries **testflags rows only** (731 of 731), so the row
gate is fed the TESTFLAGS PROJECTION: 731 against 731. **GREEN.**

**GATE 4 — surelog, BOTH modes, `--jobs 2`**, run **sequentially** so the
documented `SURELOG_FAIL` detail-row race under concurrent sweeps cannot fire.

```
[default]   CMP_EQUAL 469   CMP_NOTEQUAL 11   SURELOG_FAIL 25   DEFERRED 5  -> 469/11  EXPECTED
[testflags] CMP_EQUAL 465   CMP_NOTEQUAL  8   SURELOG_FAIL 23   DEFERRED 5  -> 465/8   EXPECTED
ct8rows vs results/golden_surelog.csv: 0 differing ROWS (0 diff row-sides)
dump histograms UNCHANGED both modes:
  default   325 blank / 244 differ / 225 match   (base == fresh)
  testflags 329 blank / 300 differ / 165 match   (base == fresh)
```

`SURELOG_FAIL` 25/23 and `DEFERRED` 5/5 match the committed baseline's own
counts. `GOLDEN_DEFER` was left UNSET. The target's row is byte-identical:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,      (baseline: identical)
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,   (baseline: identical)
```

**Its ROW does not move, its BYTES do** — which is the target. The detail string
stays `decompile:` because the new head's first line is also `decompile:`.
**GREEN.**

**GATE 5 — BYTE VERIFIER**, `r10oth6repro/byteverify.sh`, PATCHED vs the
PRISTINE `06d0fcd` I built myself, **both corpora, BOTH modes**:

```
uhdm2rtlil : databases patched=1358 pristine=1358  PATH_SETS_IDENTICAL  MOVERS: 0 / 1358
surelog    : databases patched= 953 pristine= 953  PATH_SETS_IDENTICAL  MOVERS: 2 /  953
  MOVER ./default/Earlgrey_0_1-71da2fd7  patched=c2384ffe6132 pristine=971d2c072671
  MOVER ./default/Scoreboard-59431470    patched=4fb87c934262 pristine=8debd9be5872
```

Both mandatory controls fire on both corpora:

```
uhdm2rtlil  SELFCHECK=1 -> 1357 / 1358 flagged      SELFCHECK1=1 -> 1
surelog     SELFCHECK=1 ->  952 /  953 flagged      SELFCHECK1=1 -> 3
```

The surelog `SELFCHECK1` answer **3 = the one corrupted file + the two movers**,
which is precisely what that control's own message says to expect.

### `Scoreboard` — arbitrated by the stated law, not waved away

The measurement law is: *same-size = flake, size-delta = real; 3 reps before
attributing.* Both were applied.

```
SIZE   Scoreboard   patched 11122522   pristine 11122522   ->  SAME SIZE
       Earlgrey     patched 49940463   pristine 49938801   ->  +1662, SIZE DELTA

3 REPS, all with the SAME PRISTINE BINARY, Scoreboard/default:
   rep1 8debd9be587250b612576ad452fb918d      size 11122522
   rep2 8efa3d8a2906fbf1423ab22961840118      size 11122522
   rep3 c7d29a6824a9f65a503d2ea24912eecf      size 11122522
```

**Three runs of the unmodified pristine binary produce three different md5s at a
constant size.** `Scoreboard` is non-deterministic run to run *independently of
this patch* — the documented emitter nondeterminism (SourceLocation compares
across macro buffers flip per run under parallel parse). It is a FLAKE by both
halves of the stated test, and its CSV row is byte-identical in every sweep.

**The one REAL mover in 2311 databases is `Earlgrey_0_1/default` — the target,
named by the verifier itself**, and it is accounted for object-for-object in
§§ 1 and 5. **GREEN.**

**Independent confirmation that my PRISTINE is the landed baseline:**
`diff u2r_pat.csv u2r_pris.csv` and `diff sl_pat.csv sl_pris.csv` are both
**empty**, and both match the committed CSVs — so every row-level number above
is a property of the change, not of the machine.

---

## 7. CANARIES

```
canaries.sh  u2r  : rows ok=8  changed=0 absent=0  unknown-names=25   (u2r/surelog split)
canaries.sh  SL   : rows ok=52 changed=0 absent=0  unknown-names=7    (the 7 u2r-only names)
ctcan2.sh    u2r  : EXPECT_UNKNOWN=6  rows ok=1  changed=0 absent=0  unknown-patterns=6  PASS
ctcan2.sh    SL   : EXPECT_UNKNOWN=1  rows ok=58 changed=0 absent=0  unknown-patterns=1  PASS
canaudit.sh       : audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
```

Both `ctcan2` runs are **mode-matched to the corpus** and take the COMMITTED
baseline as their first argument, per the script's own contract. `canaudit`
confirms the four slang-fenced names are **dispatched by no driver here**.

**PROTECTED genscope canaries, BY NAME, in the fresh CSV — all byte-identical to
the committed baseline:**

```
gen_test9              testflags CMP_EQUAL ,,match
genvar_loop_decl_2     testflags CMP_EQUAL ,,differ
genvar_loop_decl_3     testflags CMP_EQUAL ,,differ
paramod_genscope_child testflags CMP_EQUAL ,,match
genscope_cells         testflags CMP_EQUAL ,,differ
```

**Adjacency check the brief asked for** (the array-of-struct memory says the
`IndexedPartSelectOfArrayElement` family is next door):

```
indexed_partsel_array  testflags CMP_EQUAL ,,match    IDENTICAL to baseline
gen_test4              testflags CMP_EQUAL ,,differ   IDENTICAL (known open residue, unperturbed)
EnumConcat             testflags CMP_EQUAL ,,differ   IDENTICAL
```

**BY NAME, per corpus, so a vacuous "identical" cannot hide:**

```
InterfaceModPort     gate_uhdm2rtlil.csv : 0 rows (surelog-only canary) -- vacuous, stated
                     golden_surelog.csv  : 2 rows, IDENTICAL
BlackParrotComplex   gate_uhdm2rtlil.csv : 0 rows (surelog-only canary) -- vacuous, stated
                     golden_surelog.csv  : 2 rows, IDENTICAL
```

### The three BOUNDARY arms the ops rules fence — all held byte-for-byte

Run with BOTH binaries, `o.dump` compared after workdir-path normalisation
(uhdm-dump embeds the scratch dir in every `file:` field):

```
r10earl38 a1_chain.sv  (§ genChainBranchScopeThreads38)  PASS_CMP both, dump BYTE-IDENTICAL, cmp.log identical
r10earl38 a2_fence.sv  (earl38 residue R3)               17/17 both, dump BYTE-IDENTICAL, cmp.log identical
r10earl39 a1_argts.sv  (§ defGenProcArgNoFormalTs39)     17/17, DUMP_DIFF 306/21 both -- earl39's own recorded value
```

`a1_chain` stays **`PASS_CMP`**, and `a1_argts` reproduces earl39's recorded
`content=306 hunks=21` exactly on both sides. The boundaries hold.

---

## 8. RANKED RESIDUES

**R1 — the ELABORATED twin still names the base BARE. The top-ranked next step,
and it is the other half of this head's own family.** `emitExpr`'s select path
builds the right structure but names a package-scoped base with its bare tail:

```
ours   |vpiFullName:work@prim_prince.gen_fwd_pass[1].PRINCE_ROUND_CONST.k
golden |vpiFullName:work@prim_prince.gen_fwd_pass[1].prim_cipher_pkg::PRINCE_ROUND_CONST.k
```

Population, measured: the shape tally's qualified-name deficits are
`var_select` 66 vs 30, `part_select` 110 vs 84, `ref_obj` 860 vs 845 — i.e.
**36 / 26 / 15 objects** over 4 remaining spans, including `prim_prince` 81:22
(`p_pre_round_xor`, a MODULE-LEVEL `always_comb` naming the same array with a
literal index — the natural in-corpus control) and its backward twin. The arm
carries it as `c_mca_pkg_br`, `c_mpr_pkg_br` and every `ELAB` row. This is
statement-shaped and its fix is in `emitExpr`, not in the syntax path.

**R2 — the two dump-computed display names on `var_select` / `part_select`.**
Our subtree at `106:29` differs from golden's on exactly two lines: golden's walk
yields `prim_cipher_pkg::PRINCE_ROUND_CONST` where ours yields
`work@prim_prince.gen_fwd_pass.prim_cipher_pkg::PRINCE_ROUND_CONST`. **`uhdm-cmp`
does not flag it** — the head cleared — so this is a `uhdm-dump`-visible,
`msdist`-visible difference in the parent chain above the select, not a stored
field mismatch. 13 of the 17 "moved away" line shapes are this one residue.

**R3 — the indexed part-select (`+:` / `-:`) on a package base ABSTAINS.** The
existing multi-selector builder returns `nullptr` for an indexed range selector,
so `c_gca_pkg_bidx` / `c_gca_pkg_bidxa` keep the old pasted-text `ref_obj`.
Golden's answer is fully decoded in the arm (a `var_select` whose second index is
an `indexed_part_select` with `vpiDefName`, `vpiConstantSelect:1`,
`vpiIndexedPartSelectType`, `vpiBaseExpr`/`vpiWidthExpr`) and it does **not**
occur in Earlgrey. Cheap and self-contained: extend the builder's selector loop.

**R4 — the SINGLE-selector package select, span policy already read off.** In a
def-view gen CA, golden emits a lone `bit_select` / `part_select` **spanned at
the SELECTOR** (`a1_sel40` 95:43-95:44, 99:42-99:45), not over the written text,
where we still paste the text. Deliberately outside this law's scope (§ 1); zero
occurrences in Earlgrey.

**R5 — golden folds a package-parameter select to a CONSTANT in the elaborated
view** (`c_gca_pkg_bonly_k` / `bonly_lit` ELAB are a 64-bit constant in golden
and a `bit_select` in ours; `c_gca_pkg_ronly` likewise). A different law —
constant folding of package parameters — and not touched here.

**R6 — the NEW Earlgrey head: operand REORDERING in a `param_assign`
concatenation**, `13:59-18:4`, four 32-bit hex constants emitted in reverse with
`vpiReordered:1` on our side. A different family in a different construct; the
next head on this row and fully printed in `pat/cmp.log`.
