# r10earl35 — § pkgStructDeclArrFlat35

**THE HEADLINE, FIRST.** The brief named the r10earl34 **R2 residue** (the index
constant's `vpiParent` / ref_typespec identity) as the suspect and expected the
defect to surface "through VECTORS, not fields". **Both halves are refuted.**
The head is a **scalar own-field** difference — one `int` field, `vpiNetType` —
on the net itself, and R2 is not involved at any point. The defect is that our
two **struct-FLATNESS** tests stop at the declaration's own canonical type and
so answer *"not a struct"* the moment a packed dimension is written at the
declaration, while `isPkgStructType` **beside them** descends those very dims.
The `Earlgrey_0_1/default` head is **CLEARED and ADVANCED**, and the entire
design moved by **exactly one dump line**, predicted formally in advance.

The target's own **next-source-line sibling** is what makes this pass' grid
non-optional: it has the *same* shape and golden gives it the *opposite* answer.

---

## 0. THE LAW

> **§ pkgStructDeclArrFlat35 — a packed dimension written AT THE DECLARATION is
> TRANSPARENT to the struct-FLATNESS tests that qualify the package-struct wire
> tag.**
>
> A net whose declaration writes an **explicitly package-qualified** struct type
> is tagged `vpiNetType = vpiWire`, **except** when that struct is not FLAT — it
> has a struct field, a packed-array-of-struct field, or an integer / enum /
> 2-state field. `isPkgStructType` already walked packed-array dims down to the
> struct leaf before answering "package struct"; the two exception tests did
> **not**, so `pkg::T [N-1:0] x` was a package-struct net for the purpose of the
> tag and a **non-struct** for the purpose of the tag's own exceptions. Every
> exception switched itself off the instant a packed dimension appeared.
>
> The **flatness of the struct leaf is the whole discriminator.** It does not
> matter how many packed dims are written, whether their bounds come from a
> module **parameter** or a module **localparam**, or which port direction the
> declaration has.

| # | site (`src/ModuleEmit.cpp`) | what it does |
|---|---|---|
| 0 | `declPackedStructLeaf35`, defined once above `hasStructFieldMember` | **THE descent** — strips the declaration's own `PackedArrayType` layers, returns the canonical struct leaf or `nullptr` |
| 1 | `hasStructFieldMember` | reads its leaf from site 0 instead of from `dt->getType().getCanonicalType()` |
| 2 | the def-view net site's **ATOM-member** lambda | same |

`git diff --stat 957974d -- src include` = **1 file, 35 insertions, 12
deletions** (comments included). No new predicate: the package-scope test, the
explicit-qualification test, the `UnpackedStructType` exclusion and the
`aliasPackedArr0` typedef arm are all **exactly as they already stood**.

### STATED GATE == CODE GATE

Read verbatim — this is the entire behavioural change:

```cpp
static const Type* declPackedStructLeaf35(const Symbol& sym) {
    auto* dt = sym.getDeclaredType();
    if (!dt)
        return nullptr;
    const Type* t = &dt->getType().getCanonicalType();
    while (t->getCanonicalType().kind == SymbolKind::PackedArrayType)
        t = &t->getCanonicalType().as<PackedArrayType>().elementType;
    const Type& c = t->getCanonicalType();
    return c.isStruct() ? &c : nullptr;
}
```

**When the declared canonical type is already a struct the `while` never runs
and the new code is byte-identical to the old**, so `new ⊇ old`: both predicates
are **MONOTONE INCREASING**. Both are used only as `... && !PRED(sym)` guarding
one `VpiNetType(vpiWire)` assignment, so a monotone increase can only ever
**SUPPRESS** a tag. That is the formal reason § 4's fence is exact rather than
merely observed: **the patch can remove `|vpiNetType:` lines and can do nothing
else at all.**

`hasStructFieldMember` has **7 call sites** and the descent is applied at the
predicate, not at one caller — the same shape as r10oth8's "ONE predicate at
THREE call sites". The pairing with `isPkgStructType` was incoherent at **every**
one of the 7; it is now coherent at all 7, and § 5's gates measure that.

---

## 1. THE TARGET, MEASURED

`Earlgrey_0_1/default` at BASE `957974d`, head measured by me before any edit:

```
LHS/RHS: logic_net: (work@flash_mp.region_cfgs_i), line:21:87, endln:21:100
         (flash_mp.sv:21 — a def-view port net of module flash_mp)
30 cmp lines
```

**LOCALIZE FIRST — own field, not a vector.** 30 lines is the whole log and it
was read whole. cmp prints both sides' fields, and the two prints differ in
**exactly one line**:

| | golden (LHS) | ours (RHS) |
|---|---|---|
| `vpiName` / `vpiFullName` / `vpiParent` / span | identical | identical |
| **`vpiNetType`** | **absent** | **`1` (vpiWire)** |

`logic_net`'s generated `Compare` order is
`BaseClass(VpiType, VpiName, VpiDefName)` -> `expr(VpiDecompile, VpiSize,
Typespec)` -> `simple_expr(VpiUses)` -> `nets(VpiArrayMember, VpiConstantSelect,
VpiExpanded, VpiImplicitDecl, VpiName, VpiNetDeclAssign, **VpiNetType**,
VpiResolvedNetType, …, Ports, Drivers, Loads, …)` -> `net(Net_bits, Attributes,
Exprs)` -> `logic_net(Left_expr, Right_expr, Ranges)`. A container head **can**
be a vector-size mismatch (`SafeCompare` on a vector sets both failed sides to
the CONTAINER), so that was distinguished FIRST: the head is a **scalar int
field**, `VpiNetType`, reached before any vector in the order. Everything the
`Compare` order reads after it agrees.

### the sibling on the NEXT SOURCE LINE is the whole difficulty

```systemverilog
flash_mp.sv:21  input flash_ctrl_reg_pkg::flash_ctrl_reg2hw_mp_region_cfg_mreg_t
                      [TotalRegions-1:0] region_cfgs_i,   golden: NO vpiNetType
flash_mp.sv:22  input flash_ctrl_reg_pkg::flash_ctrl_reg2hw_mp_bank_cfg_mreg_t
                      [NumBanks-1:0]     bank_cfgs_i,     golden: vpiNetType 1
```

Two declarations of the **same shape**, adjacent, opposite answers. They differ
in **TWO** ways at once, so the corpus alone cannot name the law:

* **(a) STRUCT FLATNESS.** `..._mp_region_cfg_mreg_t`'s six members are all
  `struct packed {...}` (**nested**); `..._mp_bank_cfg_mreg_t` is a single
  `logic q` (**flat**).
* **(b) DIMENSION SOURCE.** `TotalRegions` is a module **localparam**
  (`MpRegions+1`, derived); `NumBanks` is a module **parameter**.

Candidate (b) is **REFUTED** by the separating cells in § 3. Naming (a) without
running that cross would have been a guess that happened to be right.

### design-wide net-type census — the head was the ONLY one

`netcen.py` keys every `*_net:` object by `(kind, name, span)` on **both sides**
and records the multiset of `vpiNetType` values it prints:

| | net keys | net-type disagreements vs golden |
|---|---|---|
| PRISTINE | 27239 | **1** — `logic_net work@flash_mp.region_cfgs_i` (golden `-` x2, ours `-` x1 / `1` x1) |
| PATCHED | 27239 | **0** |

### the head after the patch: CLEARED, and it ADVANCED

`Earlgrey_0_1/default` stays `CMP_NOTEQUAL` (its ROW does not move, by design).
The new head is a **different, unrelated** object — and it is on the *sibling*
line, not this net:

```
LHS constant: line:22:67, endln:22:75  |vpiDecompile:2 |UINT:2 |vpiConstType:9
RHS ref_obj: (NumBanks), line:22:67, endln:22:75
42 cmp lines
```

Golden **folds** the module parameter `NumBanks` to the constant `2` inside the
packed-range operation; we keep a `ref_obj`. That is a parameter-fold-in-a-
RANGE-BOUND defect (residue **R1**), a different family from both this pass and
earl34's name-axis folds.

---

## 2. REFUTATIONS

**F1 — the brief's named suspect is NOT involved.** "the earl34 R2 residue
(index constant vpiParent + ref_typespec identity: golden reuses the package
parameter's own value-constant object parented at its param_assign) is the named
suspect". R2 concerns a **hier_path element-select's index constant**. The head
is a **net's own scalar `int` field** in the module DEF view; no hier_path, no
index constant, no ref_typespec and no `vpiParent` difference appears anywhere in
the 30-line log — the parent module_inst prints **identically** on both sides.
R2 is untouched by this pass and remains earl34's residue.

**F2 — "surfaces through VECTORS, not fields" is FALSE.** It surfaces through
precisely one directly-compared **field**, `nets::VpiNetType`, which sits ahead
of every vector in the generated `Compare` order. The vector possibility was
checked before the field one and excluded.

**F3 — "region_cfgs_i is an unpacked array of packed structs" (brief) is FALSE.**
The dimension is written **after the type name and before the identifier**, so it
is a **PACKED** dimension: `input pkg::t [TotalRegions-1:0] region_cfgs_i`.
Golden emits it as a `logic_net`, not an `array_net`. The patch descends
`PackedArrayType` only, and the unpacked case is deliberately left unmeasured
(residue **R3**).

**F4 — MY OWN first hypothesis was refuted within the hour, by the corpus.**
Reading only the target and the `aliasPackedArr0` comment beside it ("a
PACKED-ARRAY typedef signal carries NO net type even when its element leaf is a
pkg struct"), the obvious law was *"a packed array of a package struct carries no
net type"*. `bank_cfgs_i`, **one source line below the target**, is exactly that
shape and golden gives it `vpiNetType 1`. Had the grid not been run the patch
would have stripped a tag golden writes.

**F5 — a measurement-instrument defect, found and fixed before any number was
quoted.** `netcen.py`'s first version put the dump INDENT in its counter key.
uhdm-dump prints one object at several depths (once in place, again under every
`vpiActual` back-reference), so one object produced two identical output lines
and the loader silently kept only the last. It under-reported golden's
`region_cfgs_i` as 1 occurrence instead of 2. Indent is **not identity**: it is
now folded out after counting and the buckets are summed. Every census number in
this README comes from the corrected instrument, re-run on dumps proven complete
(the first `wc -l` readings were taken while `uhdm-dump` was still writing).

---

## 3. THE GRID, CELL FOR CELL

`arm35.sh a1_flat.sv` — golden (Surelog) vs ours, def view, span-keyed, MULTISET
counts (`- xN` = N occurrences printing no `vpiNetType`). Every cell is the
target's shape; the axes are flatness, dimension carrier, dimension bound
source, position and direction.

### 3a. a1_flat.sv — 26 cells

| cell | shape | GOLDEN | PRISTINE | PATCHED | verdict |
|---|---|---|---|---|---|
| `n_flat` | FLAT, no dim | `-`x1/`1`x1 | `-`x1/`1`x1 | `-`x1/`1`x1 | ok |
| `n_nest` | NEST, no dim | `-`x3 | `-`x3 | `-`x3 | ok |
| `n_arrm` | packed-arr-of-struct member, no dim | `-`x2 | `-`x2 | `-`x2 | ok |
| `n_atom` | `integer` member, no dim | `-`x2 | `-`x2 | `-`x2 | ok |
| `n_enum` | enum member, no dim | `-`x2 | `-`x2 | `-`x2 | ok |
| `d_flat` | FLAT, `[3:0]` | `-`x3/`1`x1 | `-`x3/`1`x1 | `-`x3/`1`x1 | ok |
| **`d_nest`** | **NEST, `[3:0]` — THE WITNESS** | `-`x4 | `-`x3/`1`x1 | `-`x4 | **FIXED** |
| `d_arrm` | arr-of-struct member, `[3:0]` | `-`x2 | `-`x1/`1`x1 | `-`x2 | **FIXED** |
| `d_atom` | `integer` member, `[3:0]` | `-`x2 | `-`x1/`1`x1 | `-`x2 | **FIXED** |
| `d_enum` | enum member, `[3:0]` | `-`x2 | `-`x1/`1`x1 | `-`x2 | **FIXED** |
| **`x_flat_lp`** | **FLAT + LOCALPARAM dim** | `-`x1/**`1`**x1 | `-`x1/`1`x1 | `-`x1/`1`x1 | ok |
| **`x_nest_p`** | **NEST + PARAMETER dim** | **`-`x2** | `-`x1/`1`x1 | `-`x2 | **FIXED** |
| **`x_flat_p`** | **FLAT + PARAMETER dim** | `-`x1/**`1`**x1 | `-`x1/`1`x1 | `-`x1/`1`x1 | ok |
| **`x_nest_lp`** | **NEST + LOCALPARAM dim** | **`-`x2** | `-`x1/`1`x1 | `-`x2 | **FIXED** |
| `q_flat` | FLAT, `[3:0][1:0]` (two dims) | `-`x1/`1`x1 | `-`x1/`1`x1 | `-`x1/`1`x1 | ok |
| `q_nest` | NEST, `[3:0][1:0]` | `-`x2 | `-`x1/`1`x1 | `-`x2 | **FIXED** |
| `t_flat` | FLAT, dim inside the TYPEDEF | `-`x2 | `-`x2 | `-`x2 | ok |
| `t_nest` | NEST, dim inside the TYPEDEF | `-`x2 | `-`x2 | `-`x2 | ok |
| `o_flat` | **output**, FLAT `[3:0]` | `-`x2/`1`x1 | `-`x2/`1`x1 | `-`x2/`1`x1 | ok |
| `o_nest` | **output**, NEST `[3:0]` | `-`x3 | `-`x2/`1`x1 | `-`x3 | **FIXED** |
| `b_nest` | **inout**, NEST `[3:0]` | `-`x2 | `-`x1/`1`x1 | `-`x2 | **FIXED** |
| `w_nest` | **input `wire`**, NEST `[3:0]` | `-`x2 | `-`x1/`1`x1 | `-`x1/`1`x1 | **STILL WRONG — R2** |
| `l_flat` / `l_nest` / `l_nest0` | BODY nets (non-port) | `-`x3 each | same | same | ok |
| `clk_i` | scalar control | `-`x2 | `-`x2 | `-`x2 | ok |

**FIXED = 9. unchanged-correct = 16. STILL WRONG = 1. REGRESSIONS = 0.**

**The separating pair is the load-bearing row.** `x_flat_lp` (FLAT +
LOCALPARAM) keeps `1` in golden and `x_nest_p` (NEST + PARAMETER) has none, so
golden's answer tracks **flatness alone** and **candidate (b), the dimension
source, is REFUTED outright** — a localparam bound does not suppress the tag and
a parameter bound does not preserve it.

**`t_flat` / `t_nest` prove the two dimension CARRIERS are NOT symmetric** and
must not be unified: a **typedef-carried** packed array has no tag *even when
the struct is FLAT* (`aliasPackedArr0`, already landed), whereas a
**declaration-carried** one is decided by flatness. The patch leaves
`aliasPackedArr0` alone for exactly this reason.

The arm's own cmp head advanced from `d_nest` (pristine) to `w_nest` (patched) —
the arm reproduces the corpus target's shape and its residue by name.

### 3b. a2_wire.sv — the RESIDUE arm, and it moves the residue OUT of this law

Built because `w_nest` was the one surviving a1 cell, to answer whether the
residue has anything to do with the packed dimension at all.

| cell | shape | GOLDEN | PRISTINE | PATCHED | verdict |
|---|---|---|---|---|---|
| `k_nest` | NEST, no dim, no keyword | `-`x2 | `-`x2 | `-`x2 | ok |
| `k_nest_d` | NEST, `[3:0]`, no keyword | `-`x3 | `-`x2/`1`x1 | `-`x3 | **FIXED** |
| `w_flat` | **`wire`**, FLAT, **no dim** | `-`x1/`1`x1 | `-`x1/`1`x1 | `-`x1/`1`x1 | ok |
| **`w_nest`** | **`wire`**, NEST, **NO DIM** | **`-`x2** | `-`x1/`1`x1 | `-`x1/`1`x1 | **STILL WRONG** |
| `w_flat_d` | **`wire`**, FLAT, `[3:0]` | `-`x2/`1`x1 | `-`x2/`1`x1 | `-`x2/`1`x1 | ok |
| `w_nest_d` | **`wire`**, NEST, `[3:0]` | `-`x2 | `-`x1/`1`x1 | `-`x1/`1`x1 | **STILL WRONG** |
| `w_atom_d` | **`wire`**, `integer` member, `[3:0]` | `-`x2 | `-`x1/`1`x1 | `-`x1/`1`x1 | **STILL WRONG** |
| `bw_nest` / `bw_flat` | BODY `wire` declarations | `-`x4 / `-`x3 | same | same | ok |
| `y_nest` | output NEST `[3:0]` | `-`x3 | `-`x2/`1`x1 | `-`x3 | **FIXED** |

**`w_nest` — NO dimension at all — is ALREADY WRONG in PRISTINE.** So the
residue is **dimension-independent** and is **not** a missed descent: an explicit
net keyword makes `netTypeFor`'s own `explicitDecl` branch answer `vpiWire`
*first*, so the package-struct clause carrying the flatness exceptions is never
reached. It is **pre-existing, not caused by this pass**, and it is ranked as
**R2** rather than forked in — widening `netTypeFor` is a far hotter change than
this one and the shape has **zero corpus population** (see R2).

`w_flat` / `w_flat_d` also show golden applies the *same* flatness rule under an
explicit `wire`, so R2 is a real defect with a known, measured shape.

---

## 4. THE MOVER FENCE — PREDICTED FIRST, THEN MEASURED

`pred35.sh` was written and run against the **PRISTINE** dump **before** any
patched sweep was read. It does not fence by pattern-matching but by the
**monotonicity** argument of § 0:

> **F1.** the patch can only ever REMOVE `|vpiNetType:` lines from nets.
> **F2.** it can ADD no dump line of any kind and can change no other field.
> **F3.** every removal sits on an explicitly package-qualified struct
> declaration carrying a packed-array dim whose struct leaf is NOT flat.
>
> PREDICTION: ADDED = **0**; REMOVED-not-`|vpiNetType:` = **0**; net-type census
> disagreements **1 -> 0**; head CLEARED. Any removal on a net golden **types**
> is an OVER-FIRE and fails.

Measured, pristine dump vs patched dump (both `sed 1d`):

```
$ diff r10earl35_o.dump r10earl35_p.dump
364742d364741
<     |vpiNetType:1

REMOVED lines: 1     ADDED lines: 0
o lines 4654895      p lines 4654894
```

**The whole design moved by ONE LINE, and it is the target's.** No node added,
none removed, no other field touched — the fence is not merely tight, it is the
formal consequence of the change being monotone.

### per-shape, against GOLDEN, by MULTISET (`msdist.sh`, dumps `sed 1d`)

| | golden-only | ours-only | MULTISET DISTANCE |
|---|---|---|---|
| pristine vs golden | 238946 | 70393 | **309339** |
| patched vs golden | 238946 | **70392** | **309338** |
| delta | **0** | **-1** | **-1** |

**ADDED and REMOVED accounted separately:** one ours-only line instance removed,
`golden-only` unchanged at 238946 — **nothing moved the other way**, which is
what distinguishes a fix from a trade. (The pristine figure `309339` is
bit-identical to the number r10earl34's README recorded for its own patched
build, an independent confirmation that this pass' PRISTINE build reproduces the
landed baseline.)

---

## 5. THE FIVE GATES, each with the number I measured

**BASE printed and grep-checked on every binary.** Both worktrees report
`git rev-parse HEAD` = `957974dabc7aacfb75ce00295ef363f70b189be0`.

| binary | md5 | 32-hex asserted |
|---|---|---|
| PRISTINE 957974d (built here) | `8a7c07f418d3a567de0b24c6a5e90fe3` | yes |
| PATCHED | `c6869767f794169b56339699c164fde1` | yes |

**GATE 1 — BUILD.** Absolute path
`/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl35/build/slang-uhdm`.
Waited for the link line (`[100%] Linking CXX executable slang-uhdm` ->
`[100%] Built target slang_uhdm`); `grep -c 'error:'` = **0**. md5 asserted in a
SEPARATE step from the build and 32-hex-checked; it differs from pristine.
**GREEN.**

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
The sweep ran `--mode both` (GATE 5 needs both modes' databases); the committed
baseline contains **testflags rows only** (`awk` count of non-testflags baseline
rows = **0**), so the row gate is fed the testflags projection of the fresh CSV —
731 rows against 731, testflags-to-testflags, which is exactly the committed
gate and not a weakened one. **GREEN.**

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

**GATE 5 — BYTE VERIFIER**, `byteverify.sh`, patched vs the PRISTINE 957974d I
built, **both corpora BOTH modes**, `SELFCHECK=1 SELFCHECK1=1`, movers
attributed per-shape against GOLDEN by MULTISET with ADDED/REMOVED counted
separately, and the movers PREDICTED from source-derived data first (§ 4).

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
  MOVERS: 1 / 953
  SELFCHECK  952 / 953 flagged
  SELFCHECK1 2                     (1 corrupted + the 1 real mover)
```

**ONE mover in 2311 databases, and it is the target.** It was predicted by
`pred35.sh` from the monotonicity argument before the sweep was read; the fence
is exact at 1 removed / 0 added (§ 4) and the multiset distance to golden
improves by 1 in one direction only. The mover's database is **byte-identical**
to the one I dumped and analysed in § 1 and § 4 (`cmp` = equal), so the analysis
and the gate are measuring the same bytes.

**The documented `Scoreboard/default` MULTI-STABLE flake did NOT fire this run**
and needed no 3-rep attribution: `patched=9cf807ea56e4 pristine=9cf807ea56e4`,
**size 11133449 both** — byte-identical across the two binaries. It is reported
here explicitly rather than omitted, because a named check that silently matched
nothing reads exactly like a check that was not run.

**GATE 5 GREEN.**

### CANARIES

| check | result |
|---|---|
| `canaries.sh` vs `golden_surelog.csv` | ok=52 changed=0 absent=0 unknown-names=7 (7 = the u2r-only names, expected) |
| `canaries.sh` vs `gate_uhdm2rtlil.csv` | ok=8 changed=0 absent=0 unknown-names=25 (expected) |
| `ctcan2.sh` EXPECT_UNKNOWN=1 (surelog) | **PASS** — ok=58 changed=0 absent=0 unknown-patterns=1 |
| `ctcan2.sh` EXPECT_UNKNOWN=6 (u2r) | **PASS** — ok=1 changed=0 absent=0 unknown-patterns=6 |
| `canaudit.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| `InterfaceModPort` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh |
| `BlackParrotComplex` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh |
| `Earlgrey_0_1` BY NAME | base `default/CMP_NOTEQUAL testflags/SLANG_REJECT` == fresh |

Both `ctcan2` runs are **mode-matched and baseline-FIRST** (the committed CSV is
argument 1 in every invocation). `InterfaceModPort` and `BlackParrotComplex`
carry **no row at all** in the u2r baseline, so they are checked BY NAME against
the surelog CSV, where they do — quoting a u2r "match" for them would have been
a guard reading green on an empty set.

The four SLANG-FENCED names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) are dispatched by no driver in this directory — asserted by
`canaudit.sh`, not by a sentence.

---

## 6. RANKED RESIDUES

**R1 — a module PARAMETER is not folded inside a packed RANGE BOUND. (THE NEW
HEAD, highest value.)** `Earlgrey_0_1/default`'s head after this pass:
golden `constant 2` (`vpiConstType:9`, `int_typespec` at `flash_mp.sv:11:14`),
ours `ref_obj: (NumBanks)`, both at `flash_mp.sv:22:67` — the `[NumBanks-1:0]`
dimension of `bank_cfgs_i`, the target's own sibling line. 42 cmp lines. This is
a **value fold on the RANGE-BOUND axis**, distinct from earl34's name-axis folds
(§ hierSelPkgParamFold / § hpMixedIdxPkgFold34, which are select-index **display
text**) and distinct from earl34's R2. It is the next head on this design and the
natural next pass.

**R2 — the flatness exceptions do not gate `netTypeFor`'s explicit-net-keyword
answer.** `input wire pkg::nest_t x` -> golden **no** `vpiNetType`, ours `1`.
**PRE-EXISTING and dimension-INDEPENDENT**: measured in PRISTINE on a2's
`w_nest`, which has **no dimension at all**, so it is not a missed descent and
not caused by this pass. Cells: a2 `w_nest`, `w_nest_d`, `w_atom_d` wrong;
`w_flat`, `w_flat_d` right (golden applies the same flatness rule there, so the
rule is confirmed, only unreachable). **Corpus population ZERO** for the shape
that matters: all 6 corpus occurrences of an explicit net keyword before a
package-qualified type
(`grep -rE '\b(wire|wand|wor|tri)\s+[A-Za-z_]\w*::'` over
`Surelog/{tests,third_party/tests}`) are **BODY** `wire pkg::t x;` declarations
in interfaces, and a2's `bw_nest` / `bw_flat` show golden gives those **no** tag
and we already match. Fixing it means moving the flatness exceptions ahead of
`netTypeFor`'s `explicitDecl` branch — a much hotter predicate — and should be
measured before it is written.

**R3 — the UNPACKED carrier is unmeasured.** `declPackedStructLeaf35` descends
`PackedArrayType` only. Three of `hasStructFieldMember`'s call sites pair it with
`isPkgStructType(sym, /*descendUnpacked=*/true)`, so the same incoherence this
pass fixed for packed dims may persist for unpacked ones at those sites. The
def-view site excludes `UnpackedStructType` explicitly and no arm cell covers an
unpacked-array-of-pkg-struct declaration, so **nothing here is measured** and
nothing was changed. The cheapest true extension of § pkgStructDeclArrFlat35 —
build the cells first.

**R4 — the ELAB-view net POPULATION for a non-flat packed-array-of-pkg-struct
port.** In a1's elab view golden emits a `packed_array_net` **only** for the FLAT
cells (`d_flat`, `l_flat`, `o_flat`, `q_flat`, `x_flat_lp`, `x_flat_p`); for
every NEST / atom / enum / arrm cell and for both typedef-carried cells it emits
**no elab net at all**, while we emit one for all of them. On the corpus this is
the ours-only `packed_array_net
work@top_earlgrey.u_flash_ctrl.u_flash_mp.region_cfgs_i`. This is an **object
existence** difference, an order of magnitude more dump bytes than the net-type
field, and it is **not** a net-type question — which is why this pass did not
touch it. It is why the arm still reports `CMP_FAIL` after the fix.

**R5 — two ours-only / two golden-only net keys on the corpus, unrelated to net
type.** ours-only `logic_net work@top_earlgrey.u_spi_device.u_fwmode.tx_data_i`
and `struct_net …u_flash_mp.region_cfgs_i.region_cfgs_i`; golden-only
`struct_net …u_hmac.u_sha2.u_pad.fifo_rdata` and
`struct_net …i_usbdev_iomux.sys_reg2hw_config_i`. All four are population/kind
differences with net-type agreement where both sides exist; catalogued here so
the census's 0 disagreements is not mistaken for 0 net differences.

---

## 7. THE FILES IN THIS DIRECTORY

| file | what it is |
|---|---|
| `arm35.sh` | one arm's golden + ours + dumps + cmp. r10earl34's `arm34.sh` carried forward verbatim (prints the binary md5 on every run; `sed 1d` on both dumps; existence-guards every tool because `uhdm-cmp` exits 0 on a missing input) |
| `a1_flat.sv` | **THE SEPARATING GRID** — 26 cells crossing struct FLATNESS (flat / nested / arr-of-struct member / integer member / enum member) against dimension CARRIER (none / declaration / typedef), dimension BOUND SOURCE (literal / parameter / **localparam**), depth (one dim / two), position (port / body) and direction (input / output / inout / `wire`) |
| `a2_wire.sv` | **THE RESIDUE ARM** — isolates the explicit net-KEYWORD axis and proves R2 is dimension-independent and pre-existing |
| `pred35.sh` | **the SOURCE-DERIVED mover fence**, the monotonicity argument F1/F2/F3, computed and recorded before any patched sweep was read |
| `netcen.py` | **the net-type CENSUS** — keys every `*_net:` by (kind, name, span) on BOTH sides and records the MULTISET of `vpiNetType` values it prints. Indent is folded out of the key AFTER counting (see refutation F5) |

Reused unchanged and by ABSOLUTE path:
`r10uvm55repro/{msdist.sh,ctcan2.sh,canaudit.sh}`,
`r10uvm52repro/canaries.sh`, `r10oth6repro/byteverify.sh`,
`r10oth8repro/ct8rows.sh`.
