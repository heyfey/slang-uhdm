# r10earl38 — § genChainBranchScopeThreads38

**THE HEADLINE, FIRST.** The brief handed me a naming-free, statement-shaped
head — *"golden's LHS carries TWO assignment objects @126:13 and @126:25 that
ours lacks"* — and told me to read the source and census both sides before any
theory. The source says `logic unused_out, unused_oe;`, and columns **13** and
**25** are the two DECLARATORS of that one declaration. So the brief's framing
("declaration inits become assignment statements? a continuous assign? an
unused-lint pattern?") was answered on the first look and **none of those is the
mechanism**: the rule that turns a def-view gen-block declaration into a
Rhs-less `assignment` has been implemented and correct for many passes. It was
simply **never reached**, because the block it lives in had **no AST scope**.

The defect is one missing argument. An `else if` clause introduces **no AST
scope of its own**, so the emitter's branch-scope lookup returns null for it and
falls back to searching the **module body** — which is exactly right for a chain
written at module level, and exactly wrong for one written inside a generate
scope, where the branches are members of the enclosing gen block. Every branch
after the first `else if` of a chain nested in a gen-for therefore lost its
scope, and with it **five separate scope-gated emission loops at once**.

`Earlgrey_0_1/default`'s **596-line head is CLEARED** (596 → 17 cmp lines,
a different family in a different file). The whole design moved by **260 added
lines, 0 removed, in 6 hunks over 4.65 million lines** — and the object-level
fence computed from the two dumps **before the build** predicted **exactly** the
10 statement objects in exactly the 4 blocks that moved, with nothing else
reachable. Both grid arms go from wrong to golden-identical with **0
regressions**, and the witness arm `a1_chain.sv` goes from `CMP_FAIL` to
**`PASS_CMP`**.

---

## 0. THE LAW

> **§ genChainBranchScopeThreads38 — an `else if` CLAUSE introduces NO AST SCOPE
> OF ITS OWN. Its branch blocks are SIBLINGS of the outer `if`'s branches in the
> SAME enclosing scope, so the def-view generate emitter must thread the CURRENT
> scope into the chain recursion. Resolving a chain branch's scope by searching
> the MODULE BODY is correct only when the chain IS at module level; inside any
> generate scope it silently returns null, and a null scope disables FIVE
> emission loops at once — gen-block localparams, VARIABLE DECLARATIONS,
> case-generate item scopes, further nested if-generate branch scopes
> (recursively, so the loss compounds with depth), and processes.**
>
> The rule is INDIFFERENT to every axis the grids cross. What the branch
> CONTAINS does not matter (bare `logic`, multi-declarator, written initialiser,
> ranged logic, `integer`, `int`, unpacked array, package-qualified type,
> localparam typed or untyped, `always_comb` / `always_ff` / `always_latch` /
> `initial`, a case-generate, a nested chain, an instance, a cont-assign);
> the DEPTH of the chain does not matter (2nd, 3rd or 4th `else if`, and the
> final `else`); the ENCLOSING CONSTRUCT does not matter (gen-for, a module-level
> `if (…) begin` block, a case-generate item, or a chain branch three levels
> down). **The only discriminator is whether an enclosing GENERATE SCOPE exists
> at all** — which is why the module-level chain (`gen_m1…gen_m4`) is
> byte-identical to golden in PRISTINE and the same four branches inside a
> gen-for are all empty.
>
> What the rule does NOT reach, measured: a plain `if / else` whose else clause
> is a **GenerateBlock** (not an `IfGenerate`) — the lookup finds that one and
> always did (`gen_y1`/`gen_y2`); a bare `if` with no else (`gen_z1`); the
> gen-for body's own declarations (`gen_p`); and the whole module-level chain.
> It also does not change WHICH declarations stmt-ify: a module-local typedef, a
> bare wildcard-imported package type and an unpacked array over a user type stay
> OUT in the newly reached branches exactly as they already did in the served
> one (a2 `gen_f4a` vs `gen_f4b`).

| # | site | what changed |
|---|---|---|
| 1 | `src/ModuleEmit.cpp` ~26281, `emitDefGenStmts` > `emitBranch` > the NESTED if-generate loop's ELSE-CLAUSE recursion | when the else clause is itself an `IfGenerate` and the scope lookup returns null, pass the CURRENT `astBlock` down instead of null |

`git diff --stat 49475c9 -- src include` = **1 file, 32 insertions, 5
deletions**. Of the 32 added lines **24 are comment and 8 are code**; the 5
removed lines are the single `emitBranch(...)` call this rewrites (0 comment).
So the behavioural change is **8 lines of code at ONE site**. No `include/`
change, therefore **no new member, no new helper, no new predicate** — and no
new object is constructed anywhere: the patch only decides which `const Scope*`
an existing recursive call receives.

### STATED GATE == CODE GATE

Read verbatim — this is the entire behavioural change.

**Before** (the 5 removed lines):

```cpp
if (auto* e = emitBranch(
        *nIf.elseClause->clause, ngie,
        findNested((const syntax::SyntaxNode*)nIf
                       .elseClause->clause),
        branchPrefix, false))
    ngie->VpiElseStmt((UHDM::any*)e);
```

**After** (the 8 added code lines; the 24 comment lines are omitted here and are
in the source):

```cpp
const Scope* ecScope38 = findNested(
    (const syntax::SyntaxNode*)nIf.elseClause->clause);
if (!ecScope38 &&
    nIf.elseClause->clause->kind ==
        syntax::SyntaxKind::IfGenerate)
    ecScope38 = astBlock;
if (auto* e = emitBranch(*nIf.elseClause->clause, ngie,
                         ecScope38, branchPrefix, false))
    ngie->VpiElseStmt((UHDM::any*)e);
```

Every clause is load-bearing with a measured cell behind it:

* **`!ecScope38` first** — the fallback only fires when the existing lookup has
  already failed, so a clause that IS a `GenerateBlock` (a plain `else`) keeps
  the scope `findNested` found for it. a1 `gen_y2` is that cell: it was correct
  in PRISTINE and must not be touched.
* **`kind == IfGenerate`** — this is the ONLY clause kind that shares the outer
  if's enclosing scope. Any other clause kind either has its own scope or is
  not a chain, and handing it `astBlock` would be a lie.
* **`ecScope38 = astBlock`, not `body`** — the branches are members of the
  ENCLOSING GEN BLOCK. a2 `gen_f7b2x`/`gen_f7b2y`/`gen_f7b2z`, three levels
  down, are the cells: their scope is `gen_f7b2`, not the module body and not
  `gen_f7b`.
* **MONOTONE, and this is the one property worth stating plainly.** At module
  level `astBlock` is *already null* on the path that needs the body fallback,
  so the assignment is a **no-op there by construction** — the module-level
  chain cannot change, and a1's `gen_m1…gen_m4` cells confirm it did not. The
  patch can only ever turn a null scope into the correct non-null one; it can
  never replace a scope that was already found, and it constructs nothing.

---

## 1. THE TARGET, MEASURED — and the brief's framing answered by the SOURCE

`Earlgrey_0_1/default` at BASE `49475c9`, head measured by me before any edit
(**596 cmp lines**; LHS is golden, RHS is ours):

```
LHS named_begin: (work@padring.gen_mio_pads.gen_mio_input), id:128975
  |vpiStmt: \_ref_module: work@prim_pad_wrapper (i_mio_pad), line:118:9
  |vpiStmt: \_assignment: , id:128962, line:126:13, endln:126:23   <- ours lacks
  |vpiStmt: \_assignment: , id:128966, line:126:25, endln:126:34   <- ours lacks
  |vpiStmt: \_cont_assign: , line:127:14 …
  |vpiStmt: \_cont_assign: , line:128:14 …
```

`padring.sv:115-128` —

```systemverilog
    end else if (ConnectMioIn[k]) begin : gen_mio_input     // 2nd `else if`
      prim_pad_wrapper #(.AttrDw(AttrDw)) i_mio_pad ( … );
      logic unused_out, unused_oe;                          // line 126
      assign unused_out   = mio_out_i[k];                   // line 127
      assign unused_oe    = mio_oe_i[k];                    // line 128
    end else begin : gen_mio_tie_off
```

inside `for (genvar k = 0; k < NMioPads; k++) begin : gen_mio_pads`.

**Column 13 is `unused_out` and column 25 is `unused_oe`** — 6 spaces, `logic`
at 7-11, `unused_out` at 13-22, `,` at 23, `unused_oe` at 25. The two
`assignment`s golden carries are **one per DECLARATOR of the declaration on line
126**, not the two `assign` statements on 127-128 (those are `cont_assign`s and
we already emit both, byte-identically). The census prints them adjacent, which
is what makes the reading unambiguous.

### the brief's candidate families, each answered by the census

| candidate | verdict |
|---|---|
| "declaration inits become assignment statements" | **half right, and the half that matters is wrong.** Golden stmt-ifies EVERY declarator, initialised or not: a1 `gen_d3` has `logic d3_bare;` → `assignment@120:13-120:20` (name span, no Rhs) beside `logic d3_init = 1'b0;` → `assignment@121:13-121:27` (decl..init span, Rhs constant). There is no init here at all. |
| "a continuous assign" | **no.** The `assign`s on 127/128 are `cont_assign` objects and both sides emit them identically — they are IN the head's own statement list on both sides. |
| "an unused-lint pattern like `assign unused_out = …` nearby" | **no.** Nothing keys on the name or the lint idiom; `gen_mio_output`, the branch immediately above with a `cont_assign` and no declaration, is byte-identical on both sides. |
| **§ 66's MIRROR question — "does golden emit decl-init assignment statements in DEF-view gen listings where our block emitter drops them?"** | **Measured and ANSWERED, and the answer is the OPPOSITE of § 66.** In a def-view gen listing golden emits an `assignment` for a written initialiser (a1 `gen_d3` `d3_init`, `d3_y`) — where § declInitWrittenNewNoStmt66 found that a SUBROUTINE-body declaration with a written `new` init emits NO statement. Two positions, two answers, and the arm carries both shapes so the next pass does not have to re-derive it. Our emitter already had the gen-listing rule right; the mirror was never the defect. |

### WHERE the head actually is

`emitDefGenStmts`' `emitBranch` gates five loops on `astBlock`:

| line | loop | needs the scope for |
|---|---|---|
| 24376 | gen-block LOCALPARAMs | the `ParameterSymbol` |
| **24646** | **gen-block VARIABLE DECLs** | **the `VariableSymbol` — THE HEAD** |
| 26198 | CASE-GENERATE item scopes | the item's `GenerateBlock` member |
| 26259 | NESTED IF-GENERATE branch scopes | the branch's `GenerateBlock` member (recursive) |
| 26293 | gen-block PROCESSES | the `ProceduralBlockSymbol` |

`findNested`'s own comment names the trap and stops one step short of it:

> *"An else-if CHAIN reaches here with no astBlock … the chain branches are
> SIBLING GenerateBlocks of **the module body**, so fall back to searching there
> (r5p_gpr gen_default)."*

That sentence is TRUE for `r5p_gpr`, whose chain is at module level. It is FALSE
for every chain inside a generate scope, and there is no diagnostic — the lookup
returns null and five loops quietly `continue`.

### the head after the patch: CLEARED

```
596 cmp lines  ->  17 cmp lines
LHS: <null>
RHS: ref_typespec: (work@prim_prince.p_fwd_d64.data_state_round), id:127562
     |vpiParent: \_ref_obj: (work@prim_prince.p_fwd_d64.data_state_round), line:91:69
     |vpiActual: \_logic_typespec: , line:110:59, endln:110:64
```

An unrelated family (a SURPLUS `ref_typespec` on a function-local ref in
`prim_prince.sv`) in an unrelated file. Residue **R1**.
`Earlgrey_0_1/default` stays `CMP_NOTEQUAL` — its ROW does not move, by design;
its BYTES do.

---

## 2. REFUTATIONS

**F1 — `findNested`'s own written law is FALSE outside module level, and it is
the whole defect.** *"The chain branches are SIBLING GenerateBlocks of the module
body."* Measured on 39 branches across two arms and 4 corpus blocks: inside a
generate scope they are siblings of the ENCLOSING GEN BLOCK's members and the
module body knows nothing about them. The comment was written from one witness
(`r5p_gpr gen_default`) that happens to be at module level, and the two cases are
written with identical characters. a1's `gen_m3` against `gen_w3` is the
separating pair: same 4-branch chain, same 2nd-`else-if` position, same
declaration, same file — one is at module level and correct in PRISTINE, one is
inside a `for (genvar …)` and empty.

**F2 — my own first instinct, "widen `findNested`'s body fallback to search
nested scopes recursively", was wrong and the a2 fence would have caught it.**
A recursive body search would match a GenerateBlock by SYNTAX anywhere in the
design, and the same branch syntax is instantiated once per gen-for iteration —
it would have bound a chain branch to an arbitrary iteration's scope. Threading
`astBlock` binds it to the iteration the caller already chose (the first
non-uninstantiated entry), which is the scope every already-correct sibling
branch uses. a2 `gen_f7` (a chain inside a chain inside a chain inside a gen-for)
is the cell that separates them.

**F3 — "the head is about `new`/initialisers, so § 66 owns it" — REFUTED, and
the boundary is clean in the other direction too.** § declInitWrittenNewNoStmt66
lives in `StmtEmit.cpp` and governs SUBROUTINE-BODY declarations whose WRITTEN
init is a `new` call. This head is a GENERATE-BLOCK declaration with NO
initialiser at all, in `ModuleEmit.cpp`'s def-view listing, and the patch does
not touch `StmtEmit.cpp`. The mirror question the brief asked is answered in § 1
and the two laws point OPPOSITE ways, which is why they are two laws.

**F4 — a measurement-instrument defect I introduced and FIXED before landing,
and it had already silently dropped 40% of the census.** `blkcen38.py`'s first
version keyed each block's row on a `def`/`elab` VIEW taken from the last
column-0 `|uhdmallModules:` / `|uhdmtopModules:` section marker. On a
single-module arm that is sound; on Earlgrey the dump carries **190
`|uhdmallModules:`, 40 `|uhdmallPackages:`, 40 `|uhdmtopPackages:` and 10
`|uhdmtopModules:` markers, interleaved**, so a running two-state machine
mislabels huge regions. Filtering on `def` returned **3321 of 5553 blocks** and
had silently dropped `work@ibex_cs_registers.g_pmp_registers` — a DEF-view block
it had labelled `elab`. The number that caught it was `pred38.py`'s source scan
naming `ibex_cs_registers.sv` as a candidate the object census did not list. The
census is view-agnostic now and asserts the two sides' row counts equal
(**5553 = 5553**) before reading a row. **The fence in § 4 is computed with the
FIXED instrument**; the 3321-row run is reported here only as the defect.

**F5 — the a2 fence found FOUR MORE defects of the same law, not an over-fire,
and that is the opposite of what a fence usually returns.** The four non-head
categories were built to catch damage from the widened reach. Golden's answer in
every one of them is that the newly reached branch should carry the same
statements the served branch carries, so all four are **fixed, not broken**:
localparams (`gen_f1b`, `gen_f1c`), processes (`gen_f2b`, `gen_f2c`, including
their inner `begin` blocks), case-generate items inside a chain branch
(`gen_f3b0`, `gen_f3bd`, `gen_f3c2`, `gen_f3cd`) and the type policy
(`gen_f4b`, `gen_f4c`). The fence's real service was proving the type policy did
NOT change: a module-local typedef, a bare imported type and an unpacked array
over a user type stay OUT in the new position exactly as in the old.

**F6 — the `Scoreboard` byte mover is NOT this patch, and I proved it rather
than citing the rule.** GATE 5's surelog half reports 2 movers. The standing rule
says same-size = flake; the proof is stronger: running the **PRISTINE** binary on
`Scoreboard` three times produced **two different md5s** (`5470021a…` twice-over
across builds, `d24170f7…`), the patched binary produced a **third**
(`814cba97…`), and every one of the four states has **MULTISET DISTANCE 0** from
every other with identical line counts (1 094 789) and identical status
(`CMP_NOTEQUAL`). The pristine binary disagrees with ITSELF, the content is
identical and only the ORDER moves — the documented `SourceLocation`-across-
macro-buffers nondeterminism. **1 real mover in 2311 databases.**

**F7 — `pred38.py` is HONESTLY WEAK and the fence that binds is a different
one.** The source-text scan cannot see WHICH emitter compiles a branch, and a
module-level chain (already correct) is written with the same characters as one
inside a gen-for. On Earlgrey it names 3 candidate branches where 4 blocks
actually move, and one of its three (`ibex_cs_registers.sv:759 g_pmp_g1`) is a
**false positive**: that chain sits under `if (PMPEnable)` with `PMPEnable = 0`
and **neither golden nor we emit `g_pmp_g1` anywhere in the design** (0
occurrences in both 4.8M-line dumps). It is kept because it is the only
instrument that shows the written population against the actual reach — and
because its false positive is what exposed **F4**.

---

## 3. THE GRID, CELL FOR CELL

`arm38.sh a1_chain.sv` / `a2_fence.sv`, census through `blkcen38.py`, keyed on
the block's fullname. LHS always golden. Statement lists are compared as ORDERED
`kind@span[lhsname]` sequences, so a missing, added or reordered statement is
one readable row.

### 3a. a1_chain.sv — the WITNESS and its axes (34 block names, 44 DEF rows)

| cell | shape | GOLDEN | PRISTINE | PATCHED | verdict |
|---|---|---|---|---|---|
| **`gen_w3`** | **`logic w3_out, w3_oe;` in the 2nd `else if` of a 4-branch chain inside a gen-for — PADRING'S OWN POSITION** | 2 `assignment` + 2 `cont_assign` | **the 2 `assignment`s MISSING** | = golden | **FIXED** |
| `gen_w2` | same, 1st `else if` | 2 + 2 | 2 missing | = golden | **FIXED** |
| `gen_w4` | same, the final `else`, plus a RANGED `logic [WD-1:0]` | 3 + 3 | 3 missing | = golden | **FIXED** |
| `gen_w1` | same, the `if` BLOCK of the same chain | 2 + 2 | **= golden** | same | ok — the `if` block's scope was always found |
| `gen_x2` … `gen_x5` | a FIVE-branch chain: 1st, 2nd, **3rd** `else if` and the `else` | 2 each | 2 missing each | = golden | **FIXED ×4** |
| `gen_x1` | its `if` block | 2 | = golden | same | ok |
| **`gen_y1` / `gen_y2`** | **a PLAIN `if / else` in the same gen-for — the else clause is a GenerateBlock, not an IfGenerate** | 2 / 2 | **= golden BOTH** | same | ok — **the fence the gate's `kind` conjunct protects** |
| `gen_z1` | a bare `if` with NO else, in a gen-for | 2 | = golden | same | ok |
| **`gen_m1` … `gen_m4`** | **the SAME 4-branch chain at MODULE LEVEL** | 2 each | **= golden ALL FOUR** | same | ok — **the module-body fallback, and the proof the patch is a no-op there** |
| `gen_d2` | THREE declarators on one declaration, padring position | 3 | 3 missing | = golden | **FIXED** |
| `gen_d3` | bare + **WRITTEN INIT** + mixed (`logic d3_x, d3_y = 1'b1;`) | 4 (init one spans decl..init, carries an unparented Rhs) | 4 missing | = golden | **FIXED** — and the § 66 mirror answer |
| `gen_d4` | ranged logic ×2, `integer` ×2, `int`, unpacked array | 6 | 6 missing | = golden | **FIXED** |
| `gen_d1` | ONE declarator, in the `if` block | 1 | = golden | same | ok |
| `gen_n2` | a chain branch holding a NESTED if-generate | 2 `assignment` + the `gen_if_else` | the 2 missing; **the `gen_if_else` was emitted** | = golden | **FIXED** |
| **`gen_n2a`** | **the THEN branch of a chain nested INSIDE a chain branch** | 2 | 2 missing | = golden | **FIXED — the recursive compounding** |
| `gen_n2b` / `gen_n2c` | its `else if` and `else` | 2 / 2 | missing | = golden | **FIXED ×2** |
| `gen_n3` | the outer chain's final `else` | 2 | 2 missing | = golden | **FIXED** |
| `gen_n1` | the outer chain's `if` block | 2 | = golden | same | ok |
| `gen_p` | the GEN-FOR BODY's own declaration, no if at all | 2 + 1 | = golden | same | ok |
| `gen_n2f` | a gen-for NESTED inside a chain branch | **nothing in the DEF view** | nothing | nothing | ok — an AGREED ABSTENTION, both sides |

**FIXED = 15 block names (38 statement objects). unchanged-correct = 19.
STILL WRONG = 0. REGRESSIONS = 0.**
`diff` of the WHOLE a1 DEF census, golden vs patched: **IDENTICAL, 0 rows.**
`uhdm-cmp`: **`CMP_FAIL` (280 lines) → `PASS_CMP`.**
Whole-dump multiset distance to golden: **924 → 122** (golden-only 861 → **6**).

**The separating pair is `gen_m3` against `gen_w3`.** Same chain, same branch
position, same declaration, same file — the ONLY difference is that one sits
inside `for (genvar k …)`. Golden's answer is the same for both; ours was not.
**The ENCLOSING SCOPE, not any property of the branch or its contents, is the
whole discriminator**, which is why every axis in the table turns out not to be
an axis.

### 3b. a2_fence.sv — the OVER-FIRE FENCE (58 block names, 61 DEF rows)

Every cell puts a NON-HEAD category in the newly reachable position.

| cell | shape | GOLDEN | PRISTINE | PATCHED | verdict |
|---|---|---|---|---|---|
| **`gen_f1b` / `gen_f1c`** | **LOCALPARAMS in a chain branch** (typed `int`, UNTYPED, `logic [3:0]`, genvar-valued) | 4 / 2 `param_assign` | **0 / 0** | = golden | **FIXED ×2 — a 2nd defect of the law** |
| `gen_f1a` | the same four in the `if` block | 4 | = golden | same | ok |
| **`gen_f2b` / `gen_f2c`** | **PROCESSES in a chain branch** (`always_comb`, `initial`, `always_ff`, `always_latch`) + their inner `begin` blocks | 4 / 2, plus 2 / 1 inner-block rows | **0 / 0, inner rows ABSENT** | = golden | **FIXED ×2 — a 3rd defect** |
| `gen_f2a` | the same in the `if` block | 3 + 1 | = golden | same | ok |
| **`gen_f3b0` / `gen_f3bd` / `gen_f3c2` / `gen_f3cd`** | **a CASE-GENERATE inside a chain branch — its ITEMS' contents** | 2 each | **0 each** | statements = golden | **FIXED ×4 — a 4th defect** |
| `gen_f3a0` / `gen_f3ad` | the same case-generate in the `if` block | 2 each | statements = golden | same | ok on statements; **name WRONG in PRISTINE AND PATCHED** — residue **R2** |
| **`gen_f4b` / `gen_f4c`** | **the TYPE POLICY in the new position**: module-local typedef, bare wildcard-imported type, `pkg::t` ×3, user-typed unpacked array, built-in unpacked array | 4 / 1 — **only the 3 package-QUALIFIED and the built-in array** | 0 / 0 | = golden | **FIXED ×2, and the policy is UNCHANGED** |
| `gen_f4a` | the identical 7 declarations in the `if` block | 4 | = golden | same | ok — **the control that pins the policy** |
| **`gen_f5b` / `gen_f5c`** | **INSTANCE + CONT-ASSIGN + declaration in a chain branch** | `assignment`, `ref_module`, `cont_assign` — IN THAT ORDER | `ref_module`, `cont_assign` (**the declaration missing, order otherwise right**) | = golden, declaration restored at index 0 | **FIXED ×2 — and the source-order key holds** |
| `gen_f5a` | the same in the `if` block | 3 | = golden | same | ok |
| **`gen_f6ub` / `gen_f6uc`** | **a chain inside a module-level `if (1) begin : …` block** | 2 each | 0 each | = golden | **FIXED ×2 — the enclosing construct is not the axis** |
| `gen_f6ua` | its `if` block | 2 | = golden | same | ok |
| **`gen_f6c0b` / `gen_f6c0c`** | **a chain inside a CASE-GENERATE ITEM** | 2 each | 0 each | statements = golden | **FIXED ×2** (name is R2) |
| `gen_f6c0` / `gen_f6c0a` / `gen_f6cd` | the same item's own block and `if` branch | — | statements = golden | same | ok on statements; name is **R2** |
| **`gen_f7b` / `gen_f7b1` / `gen_f7b2` / `gen_f7b2x` / `gen_f7b2y` / `gen_f7b2z` / `gen_f7b3` / `gen_f7c`** | **DEPTH: a chain inside a chain inside a chain, inside a gen-for** | 1-2 each | **0 each — the loss compounds** | = golden | **FIXED ×8** |
| `gen_f7a` | the outermost `if` block | 1 | = golden | same | ok |
| `gen_f6ra`/`gen_f6rb`/`gen_f6rc` | the same chain inside an explicit `generate … endgenerate` region | **nothing in the DEF view** | nothing | nothing | ok — an AGREED ABSTENTION, both sides |

**STATEMENT LISTS: 24 leaves were WRONG in PRISTINE; ALL 24 are golden-identical
after the patch. STILL WRONG = 0. REGRESSIONS = 0.**
**NAMES: 9 case-item block fullnames are wrong — before AND after — and 5 of
those 9 are wrong in the SERVED position too** (`gen_f3a0`, `gen_f3ad`,
`gen_f6c0`, `gen_f6c0a`, `gen_f6cd` have CORRECT statements and the wrong name in
PRISTINE), which is the proof that the name defect is **pre-existing and a
different law**. The patch writes no name anywhere.
Whole-dump multiset distance to golden: **1698 → 849**.
a2's `uhdm-cmp` head is **17 lines before AND after, character-identical** — an
untyped gen-localparam `ref_typespec` surplus in the SERVED block `gen_f1a`,
which the patch cannot reach (residue **R3**).

### 3c. per-shape cost, stated rather than netted

Neither arm reaches distance 0, and the arithmetic is honest about why:

| arm | shapes changed | to EXACT golden parity | moved AWAY | what the away-shapes are |
|---|---|---|---|---|
| a1 | 436 | 425 | **11** | weak-tail declaration typespecs (`logic_typespec` at the decl's type span, `range`, `constant`) that we duplicate per declaration and golden shares — **the served position already did this**, so the newly emitted branches inherit it |
| a2 | 594 | 518 | **76** | the same, plus **R2**'s case-item fullname and **R3**'s untyped-localparam `ref_typespec` now also minted for the new branches |

Every away-shape is a PRE-EXISTING defect of the served position PROPAGATED into
the newly reached branches — the patch reproduces the old emitter's behaviour
exactly, warts included. None is cmp-visible in a1 (`PASS_CMP`), and a2's cmp
head is unchanged.

---

## 4. THE MOVER FENCE — computed from the DUMPS, and it closes EXACTLY

The fence is not a source pattern (F7). `cenpred38.sh` censuses golden and
PRISTINE and reports the blocks where our statement list is SHORTER:

> **PREDICTION (`cenpred38.sh` on the golden and PRISTINE Earlgrey dumps, before
> the build): movers = 10 statement objects across 4 block names.**
> * `work@padring.gen_mio_pads.gen_mio_input` — golden 5 / ours 3 → **2**
> * `work@padring.gen_mio_pads.gen_mio_tie_off` — golden 8 / ours 5 → **3**
> * `work@padring.gen_dio_pads.gen_dio_input` — golden 5 / ours 3 → **2**
> * `work@padring.gen_dio_pads.gen_dio_tie_off` — golden 8 / ours 5 → **3**
>
> and the FOUR blocks the same census shows differing for another reason —
> `work@hmac`, `work@hmac_core`, `work@ibex_multdiv_fast`,
> `work@ibex_multdiv_slow`, all one-column end-span defects with EQUAL statement
> counts — **must be byte-identical after the patch**. Any other mover is an
> OVER-FIRE and fails the pass.

Note what is NOT predicted: `gen_mio_output` and `gen_dio_output`, the FIRST
`else if` of each chain. They lost their scope too — they simply have nothing in
them that needs it (one `cont_assign` each), so they never differed and they
must not move. They did not.

Measured, PRISTINE dump vs PATCHED dump (both `sed 1d`, whole design):

```
$ diff o_earl.dump p_earl.dump
REMOVED lines: 0     ADDED lines: 260     HUNKS: 6
o lines 4654959      p lines 4655219
```

**6 hunks in 4.65 million lines, 0 removals, and every changed line anchors at
padring.sv `126:*`, `130:*`, `131:*`, `178:*`, `182:*` or `183:*`** — the 10
declarators of the 4 predicted blocks and nothing else. The post-patch census
against golden reports **`PREDICTION: 0 statement objects missing across 0 block
names`**, and the four other-reason blocks are still exactly four.

Each of the 10 was read against golden and is **byte-for-byte golden's print**;
the target's group verbatim (`g == p`, asserted in code, 18 lines):

```
                  \_assignment: , line:126:13, endln:126:23
                    |vpiParent:
                    \_named_begin: (work@padring.gen_mio_pads.gen_mio_input)
                    |vpiOpType:82
                    |vpiBlocking:1
                    |vpiLhs:
                    \_logic_var: (work@padring.gen_mio_pads.gen_mio_input.unused_out), line:126:13, endln:126:23
                      |vpiParent:
                      \_assignment: , line:126:13, endln:126:23
                      |vpiTypespec:
                      \_ref_typespec: (work@padring.gen_mio_pads.gen_mio_input.unused_out)
                        |vpiParent:
                        \_logic_var: (…unused_out), line:126:13, endln:126:23
                        |vpiFullName:work@padring.gen_mio_pads.gen_mio_input.unused_out
                        |vpiActual:
                        \_logic_typespec: , line:126:7, endln:126:12
                      |vpiName:unused_out
                      |vpiFullName:work@padring.gen_mio_pads.gen_mio_input.unused_out
```

### per-shape, against GOLDEN, by MULTISET (`msdist.sh`, dumps `sed 1d`)

| | golden-only | ours-only | MULTISET DISTANCE |
|---|---|---|---|
| pristine vs golden | 238875 | 70386 | **309261** |
| patched vs golden | 238619 | 70390 | **309009** |
| delta | **−256** | **+4** | **−252** |

The pristine figure `309261` and the line count `4654959` are **bit-identical to
the numbers r10earl37's README recorded for its own PATCHED build** — an
independent confirmation that this pass' PRISTINE reproduces the landed baseline
`49475c9`.

### ADDED and REMOVED accounted separately, per distinct line

**131 distinct line shapes changed. 110 of them reach EXACT golden parity
(|g−p| = 0).** The closure and the honest cost:

| line shape | golden | pristine | patched | \|g−o\| | \|g−p\| |
|---|---|---|---|---|---|
| `|vpiLhs:` (that indent) | 3000 | 2990 | 3000 | 10 | **0** |
| `|vpiStmt:` (that indent) | 675 | 665 | 675 | 10 | **0** |
| `|vpiOpType:82` | 240 | 230 | 240 | 10 | **0** |
| `|vpiBlocking:1` | 197 | 187 | 197 | 10 | **0** |
| `|vpiName:unused_out` / `unused_oe` | 8 / 8 | 4 / 4 | 8 / 8 | 4 / 4 | **0 / 0** |
| `\_named_begin: (…gen_mio_tie_off)` / `(…gen_dio_tie_off)` | 8 / 8 | 5 / 5 | 8 / 8 | 3 / 3 | **0 / 0** |
| `\_named_begin: (…gen_mio_input)` / `(…gen_dio_input)` | 5 / 5 | 3 / 3 | 5 / 5 | 2 / 2 | **0 / 0** |
| `\_logic_typespec: , line:130:7, endln:130:12` | 6 | 4 | 6 | 2 | **0** |
| … 102 further shapes to parity | | | | | **0 each** |
| `|UINT:1` (that indent) | 2746 | **2757** | 2759 | 11 | **13** |
| `|vpiDecompile:1` (that indent) | 2682 | **2691** | 2693 | 9 | **11** |
| **SUM over all 131 changed shapes** | | | | **20190** | **19938** |

`20190 − 19938 = −252`, which is the whole-design multiset delta **to the unit**
— so no line outside the 131 changed shapes moved at all, and the accounting
closes.

**Two shapes moved the wrong way, by 2 each, and the cost is stated rather than
netted.** `|UINT:1` and `|vpiDecompile:1` at that indent were already a SURPLUS
before the patch (2757 > 2746, 2691 > 2682): they are the folded `1` of the
`AttrDw-1` range bound in `logic [AttrDw-1:0] unused_attr;`, and emitting the two
new `unused_attr` declarations necessarily emits two more of each. Golden pays
the same price for the same object — the surplus is a population difference
elsewhere (residue **R4**), pre-existing and 5× larger than this patch's
contribution.

---

## 5. THE FIVE GATES, each with the number I measured

**BASE printed and grep-checked on every binary.** Both worktrees report
`git rev-parse HEAD` = `49475c9e2eb54516fe3202ae29f1edabe9c5683f` (grep-asserted
against the literal, not eyeballed), and `git status --porcelain` in the PRISTINE
worktree is **empty**.

| binary | md5 | 32-hex asserted |
|---|---|---|
| PRISTINE 49475c9 (built here) | `dfc46cad6152aa06c368d3c63729a128` | yes |
| PATCHED | `d2d5f35fba29af8a46a58a91c9c951fd` | yes |

**GATE 1 — BUILD.** Absolute path `/tmp/wt_r10earl38/build/slang-uhdm`. Waited
for the link line (`[ 88%] Linking CXX executable slang-uhdm` → `[100%] Built
target slang_uhdm`); `grep -icE 'error:'` = **0** on both builds. md5 taken in a
SEPARATE step from the build, 32-hex-checked, and it differs from pristine.
Recorded because it nearly went wrong twice: the first `cmake` configure picked
`-G Ninja` (absent) and the FAILED cache then poisoned two retries — a build that
never ran reports `EXIT=1`, not a stale binary, and both were caught by reading
the log rather than the file's existence. **GREEN.**

**GATE 2 — GOLDENS.** `tests/check_goldens.sh` with **`SLANG_UHDM` exported
FIRST and echoed with its md5**: **23 PASS / 0 FAIL**. Negative control
`SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL**. **GREEN.**

**GATE 3 — uhdm2rtlil, `--mode both`, `--jobs 2`.**

```
[default]   CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2   -> 679/50/2  EXPECTED
[testflags] CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2   -> 679/50/2  EXPECTED
dump (testflags): 496 match / 183 differ / 52 blank            -> 496/183/52 EXPECTED
ct8rows vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
```
The committed baseline carries **testflags rows only** (`awk` count of
non-testflags baseline rows = **0**), so the row gate is fed the testflags
projection: 731 rows against 731. The default-mode dump histogram is
`492 match / 187 differ / 52` and is **not** part of any committed gate — stated
so it is not mistaken for a regression against a baseline that does not contain
it. **GREEN.**

**GATE 4 — surelog, BOTH modes, `--jobs 2`.**

```
[default]   CMP_EQUAL 467   CMP_NOTEQUAL 13   -> 467/13  EXPECTED
[testflags] CMP_EQUAL 463   CMP_NOTEQUAL 10   -> 463/10  EXPECTED
ct8rows vs results/golden_surelog.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
dump histograms UNCHANGED both modes:
  default   327 blank / 242 differ / 225 match   (base == fresh)
  testflags 331 blank / 298 differ / 165 match   (base == fresh)
```
`SURELOG_FAIL` = 25 (default) / 23 (testflags) and `DEFERRED` = 5 / 5,
**byte-identical to the committed baseline's own counts** — so the documented
detail-row race under concurrent sweeps did not fire and no isolated re-run was
owed. `Earlgrey_0_1/default` stays `CMP_NOTEQUAL` and `testflags` stays
`SLANG_REJECT`: its ROW does not move, its BYTES do, which is exactly the
target. **GREEN.**

**GATE 5 — BYTE VERIFIER**, `r10oth6repro/byteverify.sh`, patched vs the
PRISTINE `49475c9` I built, **both corpora BOTH modes**, `SELFCHECK=1
SELFCHECK1=1`, movers attributed per-shape against GOLDEN by MULTISET with
ADDED/REMOVED counted separately (§ 4), and the movers PREDICTED from the dumps
first (§ 4).

```
uhdm2rtlil, BOTH modes:
  PATH_SETS_IDENTICAL (1358 paths)
  MOVERS: 0 / 1358
  SELFCHECK  1357 / 1358 flagged   (the one fixed file matches itself)
  SELFCHECK1 1                     (exactly the one corrupted file)

surelog, BOTH modes:
  PATH_SETS_IDENTICAL (953 paths)
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  <- THE TARGET, predicted
  MOVER ./default/Scoreboard-59431470/slang.uhdm    <- the documented FLAKE, F6
  MOVERS: 2 / 953
  SELFCHECK  952 / 953 flagged
  SELFCHECK1 3                     (1 corrupted + the 2 reported movers)
```

**ONE real mover in 2311 databases, and it is the target.** The `Scoreboard`
mover is attributed by measurement, not by rule (F6): the pristine binary
produces two different md5s across three runs of its own, all four observed
states have multiset distance 0 from each other, identical line counts and
identical status. Both sides of the target mover were `cmp`-checked against the
databases § 1 and § 4 analysed: **`PATCHED_DB_IDENTICAL_TO_ANALYSED`** and
**`PRISTINE_DB_IDENTICAL_TO_ANALYSED`** — the analysis and the gate measure the
same bytes. **GREEN.**

### CANARIES

| check | result |
|---|---|
| `canaries.sh` vs `golden_surelog.csv` | **ok=52 changed=0 absent=0** unknown-names=7 (the u2r-only names, expected) |
| `canaries.sh` vs `gate_uhdm2rtlil.csv` (testflags projection) | **ok=8 changed=0 absent=0** unknown-names=25 (expected) |
| `ctcan2.sh` EXPECT_UNKNOWN=1 (surelog), baseline FIRST | **PASS** — ok=58 changed=0 absent=0 unknown-patterns=1 |
| `ctcan2.sh` EXPECT_UNKNOWN=6 (u2r), baseline FIRST, mode-matched | **PASS** — ok=1 changed=0 absent=0 unknown-patterns=6 |
| `canaudit.sh <canaries.sh> <ctcan2.sh>` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| `InterfaceModPort` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh |
| `BlackParrotComplex` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh |
| `Earlgrey_0_1` BY NAME | base `default/CMP_NOTEQUAL testflags/SLANG_REJECT` == fresh |

The four SLANG-FENCED names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) are dispatched by no driver here — asserted by `canaudit.sh`, not by
a sentence.

### BOUNDARIES — checked, no collision

* **§ declInitWrittenNewNoStmt66** (declaration-initializer STATEMENT drops for
  `new` inits) lives in `src/StmtEmit.cpp` at its two call sites (1419, 3189) and
  governs SUBROUTINE bodies. This patch touches `src/ModuleEmit.cpp` ONLY, adds
  no statement-drop predicate, and the head's declaration has no initialiser at
  all. The mirror question the brief posed is ANSWERED in § 1 and the two laws
  point opposite ways. **No collision.**
* **§ genCaArgPkgParamValueFolds33** and **earl37's
  § genConnDottedActualIsHierPath37** own other gen-listing families — the
  gen-scope cont-assign argument fold and the gen-scope PORT-CONNECTION actual
  (`ModuleEmit.cpp` ~2358 and ~25505). This patch is at ~26281 and constructs no
  expression; a2's `gen_f5b`/`gen_f5c` cells carry a `ref_module` with named port
  connections in the newly reached position and their `HighConn`s are
  golden-identical.
* **LIVE PASSES.** `r10svs15` touches `src/ModuleEmit.cpp` at `@@ -21334` and
  `@@ -21382` (`emitCheckerInst` / `emitNamedClockingBlocks`); `r10uvm67` at
  `@@ -20789` (`drainFuncRet`). Mine is `@@ -26281` inside `emitDefGenStmts`.
  Neither has a single hit for `emitDefGenStmts`, `findNested` or `elseClause`.
  **Disjoint hunks, disjoint functions, apply in any order.**
* **OPS NOTE, reported not hidden:** during this pass the MAIN TREE acquired
  uncommitted modifications to `include/UhdmExporter.h`, `src/ModuleEmit.cpp` and
  `src/UhdmExporter.cpp` plus an untracked `tools/probe/r10svs15repro/` — another
  live agent's work, **not mine** (`git diff | grep -c
  genChainBranchScopeThreads38` = 0 in the main tree). Every gate here passed
  `SLANG_UHDM` explicitly to `/tmp/wt_r10earl38/build/slang-uhdm`, and
  `scripts/`, `results/` and `tests/` in the main tree are unmodified, so no gate
  read a foreign binary or a foreign baseline.

---

## 6. RANKED RESIDUES

**R1 — the NEW HEAD, and it is a SURPLUS-OBJECT family.** `Earlgrey_0_1/default`
after this pass: `LHS: <null>` against
`RHS: ref_typespec (work@prim_prince.p_fwd_d64.data_state_round)`, **17 cmp
lines** — we hang a `ref_typespec` on a function-local `ref_obj` where golden
hangs nothing, `prim_prince.sv:91` inside the function `p_fwd_d64`, with the
actual typespec pointing at a `logic_typespec` from line 110. A FUNCTION-BODY
family, not a generate one, and the shallowest head this design has had.

**R2 — a NAMED case-item block's fullname is the BARE LABEL in golden and the
full scoped path in ours.** a2 `gen_f3a0` (`case (k) 0: begin : gen_f3a0`):
golden's `named_begin` prints `(gen_f3a0)` and carries `vpiFullName:gen_f3a0`;
ours prints `(work@fence38.gen_f3.gen_f3a.gen_f3a0)`. **PRE-EXISTING and
untouched** — 5 of the 9 affected blocks are wrong in the SERVED position, where
this patch changes nothing. It is adjacent to the existing comment *"A case-item
begin carries NO fullname (Surelog)"*, which is right for an UNNAMED case-item
begin and evidently wrong for a NAMED one; `a2_fence.sv` already carries 9 cells
across two nesting depths, so the next pass has its witness. Corpus population
unmeasured; this is the cheapest true next step in the same emitter.

**R3 — an UNTYPED gen localparam gets a `ref_typespec` from us and none from
golden.** a2 `gen_f1a`'s `localparam F1A_U = 8;` — golden gives the `parameter`
no `vpiTypespec` at all, we give it a `ref_typespec` → `int_typespec` spanning
the whole declaration. PRE-EXISTING in the served position and now also minted
for `F1B_U` / `F1C_U`; it is a2's `uhdm-cmp` head both before and after,
character-identical. Fixing it is a one-conjunct change in the localparam arm
(`typedP2`) and `a2_fence.sv` carries typed and untyped side by side.

**R4 — the weak-tail DECLARATION-TYPESPEC duplication, which this patch scales
up.** § 3c's away-shapes and § 4's `|UINT:1` / `|vpiDecompile:1` rows. Golden
SHARES one `logic_typespec` per declared TYPE across the declarators of a
declaration and across branches; we mint one per declarator. Pre-existing (the
served position already did it), cmp-INVISIBLE (a1 is `PASS_CMP` with 11 such
shapes still off), and it grows in proportion to how many declarations the
def-view listing emits — so this pass made it 4 shapes larger on Earlgrey while
removing 256 golden-only lines. Cataloguing it so the net `−252` is not mistaken
for "nothing moved the wrong way".

**R5 — the four OTHER-REASON blocks the census names, fully localised and
untouched.** `work@hmac` (2 rows), `work@hmac_core` (1), `work@ibex_multdiv_fast`
(5), `work@ibex_multdiv_slow` (4): every one is an `assignment` whose END COLUMN
is ONE character short of golden's (`168:24` vs `168:25`,
`399:38` vs `399:39`, `108:45` vs `108:46`). All are procedural-block statements,
all have EQUAL statement counts on both sides, and all are byte-identical before
and after this patch. A one-character span law with 12 census rows already
localised on Earlgrey — a cheap, well-fenced next target.

**R6 — a `generate … endgenerate` region wrapping a gen-for emits NO DEF-view
named_begin listing for its branches, on EITHER side.** a2's `gen_f6ra` /
`gen_f6rb` / `gen_f6rc` appear in the ELAB view only. Recorded as a measured
AGREED ABSTENTION (not a defect) because it is the one cell in either grid where
the patch could have been expected to fire and correctly did not, and because it
is the shape a future widening of this law must not disturb.

---

## 7. THE FILES IN THIS DIRECTORY

| file | what it is |
|---|---|
| `arm38.sh` | one arm's golden + ours + dumps + cmp. r10earl37's `arm37.sh` carried forward verbatim (prints the binary md5 on every run; `sed 1d` on both dumps; existence-guards every tool because `uhdm-cmp` exits 0 on a missing input; runs in its own scratch dir because Surelog synthesizes `builtin.sv` into the CWD) |
| `a1_chain.sv` | **THE WITNESS AND ITS AXES** — 34 DEF block names crossing the CHAIN POSITION (`if` block / 1st / 2nd / 3rd `else if` / final `else`), the ENCLOSING CONSTRUCT (gen-for / module level / nested chain / nested gen-for / plain `if-else` / bare `if`), the DECLARATOR COUNT (1 / 2 / 3), the WRITTEN INITIALISER (bare / `= const` / mixed) and the TYPE (scalar / ranged / `integer` / `int` / unpacked array). `gen_m3` vs `gen_w3` is the separating pair and it isolates the ENCLOSING SCOPE as the only discriminator |
| `a2_fence.sv` | **THE OVER-FIRE FENCE** — 58 DEF block names putting each of the FOUR non-head scope-gated categories in the newly reachable position: localparams (typed/untyped/genvar-valued), processes (`always_comb`/`always_ff`/`always_latch`/`initial`), case-generates, and the TYPE POLICY (module-local typedef, bare imported, `pkg::t`, user-typed unpacked array) against a served-position control — plus instances + cont-assigns (statement ORDER), three enclosing constructs, and a three-deep chain. It found four MORE defects of the same law and zero over-fires (F5) |
| `blkcen38.py` | **THE GENERATE-BRANCH STATEMENT-LIST CENSUS** — one row per block with its ORDERED `vpiStmt` list rendered as `kind@span[lhsname]`. Purpose-built because the defect is a VECTOR-SIZE mismatch, which shifts a line diff for the rest of the block. Back-reference prints (a block under `|vpiParent:`) are dropped. **Carries F4's fix: the census is VIEW-AGNOSTIC by default**, because Earlgrey's dump has 190 `|uhdmallModules:` markers and a running `def`/`elab` state machine silently dropped 2232 of 5553 blocks |
| `cenpred38.sh` | **THE OBJECT-LEVEL MOVER FENCE** — censuses golden and ours and splits the differing rows into MISSING (this law's predicted movers) and OTHER (must stay byte-identical). Predicted 10 objects in 4 blocks; 10 in 4 moved |
| `pred38.py` | the SOURCE-TEXT population instrument. **Kept with its weakness stated (F7, R6): it cannot see which emitter compiles a branch, so a module-level chain looks identical to a broken one; on Earlgrey it names 3 candidates for 4 moving blocks and one of the 3 is a false positive.** Its false positive is what exposed F4 |
| `README.verifier.md` | THIS pass's verifier placeholder — no verdict, written by the implementer, listing exactly what an independent verifier must re-measure |

Reused unchanged and by ABSOLUTE path:
`r10uvm55repro/{msdist.sh,ctcan2.sh,canaudit.sh}`,
`r10uvm52repro/canaries.sh`, `r10oth6repro/byteverify.sh`,
`r10oth8repro/ct8rows.sh`.
