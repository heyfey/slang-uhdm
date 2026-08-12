# r10earl33 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PARTIAL.**

The brief's success criterion is **MET** and every headline number I could
re-derive **reproduces to the digit** — including both binary md5s, the 1-of-953
byte mover, its eight-shape attribution, the msdist delta and the hier_path
census. But the second shipped law, **§ genScopeBareArgKeepsRef33**, silently
**DESTROYS a `vpiActual -> enum_const` binding that `a060719` produced correctly
and that GOLDEN HAS**, on three independent arms — including `a3_ctx.sv`, the
arm the report calls "byte-identical except the over-fire it now fixes". The
defect is invisible to `cells33.py` because that reader never looks at
`vpiActual`, which is also why the report calls the affected cells "exact".
0 corpus rows and 0 corpus bytes are affected today, so this is a **latent
regression plus a false claim**, not a gate failure.

Binaries built by me, from a **fresh** `a060719` worktree pair:

```
worktree BASE (both)  a060719294b588fdfc85918775a5ad49603dd569   printed + grep-checked
pristine  /.../worktrees/r10earl33vpris/build/slang-uhdm  md5=365219cb664f4498d52c9aa68f605ba7
patched   /.../worktrees/r10earl33v/build/slang-uhdm      md5=899b52d9ca7ce8b9fb74f4040344201b
```

Both md5s are **bit-identical to the implementer's** (`BASELINE=365219cb...`,
`FINAL=899b52d9...`). That is the strongest possible corroboration of the patch:
an independent configure + build of the same tree reproduces the same binary.

---

## 1. WHAT REPRODUCED EXACTLY

| claim | my measurement | command |
|---|---|---|
| patch applies clean to fresh a060719 | `git apply --check` **rc=0**; md5 `ef231269a50be4a586e22b9316e7bc53`; 1811 lines | `git apply --check --verbose /tmp/r10earl33.patch` |
| production = 2 files, 175 insertions / 3 deletions | **exact** | `git diff --stat a060719 -- src include` |
| no `results/` `scripts/` `tests/` in the patch | **0 files** | `grep '^diff --git' /tmp/r10earl33.patch \| grep -cE ' b/(results\|scripts\|tests)/'` |
| `constArgBodyEvald60` / `VpiConstType` / `MakeRef_typespec` in added PRODUCTION lines | **0** | strip the tools half with `awk`, then `grep -cE` |
| `a3_ctx.sv`, `v4_more.sv`, `arm33.sh`(=`arm32.sh`), `mv33.sh`(=`mv32.sh`) adopted VERBATIM | **byte-identical**, all four | `diff tools/probe/r10earl32repro/... .../r10earl33repro/...` |
| `cells33.py --selfcheck` | **PASS**, rows=2, the two views kept apart | `python3 cells33.py --selfcheck` |
| grid `b1_gen 31->20`, `b2_init 28->14`, `b3_text 8->5`, `v4_more 13->9` | **exact, all four** | `cells33.py <g> <o>` on my own pristine/patched arm runs |
| **v4_more 30:19 / 35:19 fold to golden's exact constants** (THE SUCCESS CRITERION) | **MET** — kind, span, decompile, parent and ts all equal in the `allModules` view | `cells33.py ... --only 30,35` |
| F4's statement REFUTED (elab already folded; the bare sibling at 30:31 was a WRONG `constant` in the elab views) | **CONFIRMED** on the pristine build | same |
| pre-r10earl32 (`266d3a6`) gave golden's answer at `a3_ctx` 46:18 | **CONFIRMED**, md5 `663899bcad3b7696f1d3f9fa972ec085` printed | `arm33.sh a3_ctx.sv` with the r10svs3pris binary |
| GATE 1 link line = 1, `error:` = 0, both builds | **exact** | `grep -c "Linking CXX executable slang-uhdm"` / `grep -icE "error:"` |
| GATE 2 goldens 23/0 rc=0 and `/bin/false` 0/23 rc=1, `GOLDEN_DEFER` unset | **exact** | `SLANG_UHDM=... ./tests/check_goldens.sh` |
| GATE 3 u2r testflags **679/50/2**, dump **496/183/52**, 0 differing rows | **exact** | `verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2` + `ct8rows.sh` |
| GATE 4 surelog **467/13/5/284/25** + **463/10/5/286/23**, dump **225/242/327** + **165/298/331**, 0 differing rows | **exact** | `verify_golden.py --corpus surelog --mode both --jobs 2` + `ct8rows.sh` |
| GATE 5 u2r **0 / 679**, SELFCHECK 678/679, SELFCHECK1 = 1 | **exact** | `SELFCHECK=1 SELFCHECK1=1 byteverify.sh` |
| GATE 5 surelog **1 / 953** = `default/Earlgrey_0_1`, SELFCHECK 952/953, SELFCHECK1 = 2 | **exact**, and the md5 prefixes match: `patched=fb053a2d299b pristine=dcc8b974f5a1` | same |
| movers per shape: 8 ADDED all present in golden at that exact span (incl. the two `golden=32` rows), 8 REMOVED all `golden=0 && ours_after=0`, **no bare field line in the delta** | **exact, shape for shape** | manual `comm` + `grep -Fxc` census of the two dumps, plus `SELFCHECK=1 mv33.sh` (both fabricated controls fire correctly) |
| msdist **309519 -> 309507 (-12)**, dump length **4,654,895 unchanged**, golden 4,823,448 | **exact** | `r10uvm55repro/msdist.sh` md5 `7c0d46b5da124cfe37d27eddc95eb7e7` |
| Earlgrey head UNMOVED, cmp logs **byte-identical**, 1 head / 154 lines | **exact** (`cmp -s` equal) | `uhdm-cmp` on both databases vs the cached golden |
| head census: golden 36 `region_cfgs[8]...` vs ours 48 `region_cfgs[MpRegions]...`; 172 vs 176 identifier-indexed hier_path names | **exact, all four numbers** | `grep -c` / `grep -o ... \| sort -u \| wc -l` on the two dumps |
| canaries: ctcan2 u2r `EXPECT_UNKNOWN=6` ok=1/0/0; surelog `EXPECT_UNKNOWN=1` ok=58/0/0; `r10uvm52repro/canaries.sh` u2r ok=8/0/0, surelog ok=52/0/0; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 | **exact** | as named, by absolute path |
| `InterfaceModPort`, `BlackParrotComplex`, `FuncStructVal(-Simple)`, `SVSwitch`, `Earlgrey_0_1`, `ArianeElab`, `ForElab`, `BitsOp`, `ParamOverload3`, `Ibex` byte-identical BY NAME | **exact, all ten** | `grep "^<name>," ` both CSVs |
| `Earlgrey_0_1/default` does NOT convert (467/13) | **confirmed** | GATE 4 histogram |
| `UnsignedParam` / `HierPathEval` / `FileLocalParam` / `TopParam` never dispatched | **confirmed** | `canaudit.sh` FENCE-BREACH=0 |
| pred33.sh's `A&C&D` = 0 / 7 / 225 and 0 u2r candidate dirs | **exact** | `./pred33.sh /tmp/e33v_pred` |
| the seven OTHER r10earl32 arms unchanged | **byte-identical**, path-normalised, all seven (`a1_kind a2_type a4_text a5_init v1_esctext v2_pos v3_nosubst`) | `arm32.sh` x2 + `diff` with the workdir path `sed`-normalised |

**Nothing in the gate battery failed.** The findings below are all things the
gates and the shipped reader cannot see.

---

## 2. FINDINGS

### F1 — REGRESSION. § genScopeBareArgKeepsRef33 destroys the `enum_const` clone § genNestedScopePkgParamNoFold24 mints, on cells that were GOLDEN-EXACT at a060719

`genScopeBareArg33` clears `fcArgFold32`, which sends a bare package-parameter
call argument into the § fcArgBareImportRef **carve-out** at `src/ExprEmit.cpp`
~4683. That carve-out returns an **UNBOUND** ref (`VpiFullName` + `VpiParent` +
`setLoc`, no `Actual_group`) and it sits **~450 lines ABOVE** law 24 at
`src/ExprEmit.cpp:5136`. So for a bare pkg-param call argument in a NESTED
elaborated gen scope, **law 24 no longer runs at all** — and law 24 is the arm
that mints golden's per-instance `enum_const` clone.

Measured, three independent sources, with the two binaries above:

```
b1_gen.sv  116:17  (k13, "BARE in a NESTED gen scope (24) x2", ELABORATED view)
  GOLDEN            ref_obj (work@k33top.u1.gnout.gnin[0].P) + |vpiActual: \_enum_const: (P)
                    the enum_const carries  |HEX:380  |vpiDecompile:12'h380  |vpiSize:12
  a060719 (PRIS)    IDENTICAL TO GOLDEN, both instances
  PATCHED           |vpiActual: and the enum_const object are GONE

a3_ctx.sv  58:30  (r10earl32's OWN container arm, nested gen scope)
  GOLDEN / PRIS     ref_obj (work@c32top.ua.gouter[0].ginner.P) + enum_const   IDENTICAL
  PATCHED           binding gone

v6_tfnest.sv 40:25 (MY arm, a fresh for-inside-if gen CA)   x2 instances
  GOLDEN / PRIS     ref + enum_const IDENTICAL;   PATCHED  binding gone
```

Command:
`grep -B8 "_enum_const: (P" <dump> | grep -E '\_ref_obj:|\_enum_const: \(P'`
plus the raw subtree at `sed -n "${n},$((n+7))p"` for each side.

Whole-arm `enum_const (P)` line census, golden / ours-pristine / ours-patched:

```
b1_gen    golden 10   pris 4   pat 0     (golden binds 5 refs: 41:32 x2, 104:15, 116:17 x2)
a3_ctx    golden  4   pris 2   pat 0
v6_tfnest golden  8   pris 4   pat 0
v5_holes  golden 12   pris 0   pat 0     (under-fire only — see F2)
```

Multiset distance to golden, per arm, pristine -> patched (the `msdist.sh`
measure: indentation stripped, workdir path normalised, sum of |dg-do|):

```
b1_gen    669 -> 630     b2_init 1210 -> 1160     b3_text 878 -> 857     v4_more 287 -> 269
a3_ctx    477 -> 487     (+10  WORSE)
v6_tfnest 141 -> 155     (+14  WORSE — this arm's delta is PURE LOSS, no gain at all)
v5_holes  247 -> 213
```

Sharp, object-level attribution on `a3_ctx` (bare field lines named as the
non-attributable absorbers the campaign's own instrument requires):

```
GAINED (golden has it, we now emit it):
  \_ref_obj: (work@c32top.ua.gblk.P), line:46:18, endln:46:19      <- the 46:18 fix, real
LOST (golden has it, we no longer emit it):
  \_enum_const: (P)  x2                                            <- the 58:30 clone
  \_ref_obj: (work@c32top.ua.gouter[0].ginner.P), line:58:30       <- its vpiParent stub
```

**Three report claims are refuted by this**, verbatim:

* delivery message: "`a3_ctx` byte-identical except the over-fire it now fixes" —
  **false**; the a3_ctx delta also contains the 58:30 binding loss, and the arm
  ends **+10 farther** from golden.
* `README.md` 2.1 k13 "ref OK | ref OK" and 7 BOUNDARIES
  "genNestedScopePkgParamNoFold24 keeps its container ... both arms return
  **above** the gate this pass edits" — **false**: law 24 is at 5136, the gate is
  at 4683; law 24 returns *below* it and is now shadowed for every call-argument
  position. "It is a ref before and after" is true only of the object KIND.
* `src/ExprEmit.cpp` ~4668: "b1 k13 111:17 proves law 24 still owns the nested
  cell" — the cell proves the opposite once `vpiActual` is read.

**The report's own defence is the defect.** 7 says the collision is justified
"by restoring the answer the code gave **before** r10earl32". I ran the pre-32
binary (`266d3a6`, md5 `663899bcad3b7696f1d3f9fa972ec085`): at 58:30 it emits the
ref with **no** `enum_const` either. So the pre-32 answer was the *worse* one at
this cell; r10earl32 accidentally **improved** it by letting law 24 see call
arguments for the first time, and this pass undoes that improvement.

**Reach: ZERO on both corpora today.** The whole Earlgrey shape delta contains no
`enum_const` line (see 1's mover table) and u2r moved 0/679. Latent, not live.

**The fix is one clause**, inside this pass's own gate — subtract law 24's
container from law 33's:

```cpp
const bool genScopeBareArg33 =
    fcArgPos32 && !fcArgQual33 && (inGenScopeCaRhs || inGenScopeProc) &&
    !genNestedScopeEmit24;
```

then re-measure b1 k13 / a3 58:30 / v6 40:25, which must go back to
ref + enum_const.

### F2 — UNDER-FIRE, unreported. Every ref the law *does* land is UNBOUND where golden binds it

Even where the law is a clear improvement, the object is not "exact". Golden
attaches an `enum_const` clone to **every** bare pkg-param call-arg ref in an
elaborated gen scope; we attach none.

```
v4_more 30:31 x2    golden ref + enum_const(HEX:380, 12'h380, size 12)   ours ref, unbound
b1_gen  41:32 x2    same                                                 ours ref, unbound
b1_gen 104:15       same                                                 ours ref, unbound
v5_holes 42:20 x2 (TASK call), 51:20 x2, 52:25 x2                        ours ref, unbound
```

The report calls these cells "**exact**" (README 2.1 k5' / k11' "exact x2",
delivery message "the target cells ... now exact"). They are exact **on kind,
span, name, fullname and parent** and wrong on the binding. Same missing object
as F1: F1 is where we *lost* one we already had, F2 is where we never minted one.

### F3 — THE INSTRUMENT CANNOT SEE ITS OWN DEFECT: `cells33.py` never reads `vpiActual`

`cells33.py`'s row is `(kind, span, decompile, vpiParent kind, vpiTypespec,
name, size)` — `rows()` at ~line 117. `vpiActual` on the ARGUMENT is not read at
any depth (only inside a `ref_typespec`). So F1 and F2 are structurally
invisible to it, and its `--selfcheck` — a genuine improvement over `cells32.py`,
and it passes — does not cover this axis either. Every "exact" verdict in
`README.md` 2 is an equality of that 7-tuple, not of the object. Inherited from
`cells32.py`, but this is the first pass whose law changes exactly that field.

### F4 — STATED GATE != CODE GATE, three separate places

1. **The r10earl32 comment the patch edits around was left standing and is now
   false.** `src/ExprEmit.cpp` ~4608, unmodified by this patch:
   > "STATED GATE == CODE GATE. The gate is exactly two things: (1) ... (2) ...
   > There is **NO context flag**, NO view test, NO import test and **NO TEXT
   > TEST** here — the qualified/bare split lives entirely inside the carve-out
   > body, **unchanged**."

   After this patch `fcArgFold32` is **three** things, the new term
   `genScopeBareArg33` is a **context flag** (`inGenScopeCaRhs || inGenScopeProc`)
   combined with a syntax-kind discriminator, and the carve-out body's split
   *is* changed (site 3). A reader who trusts the standing comment reads the
   wrong gate.

2. **"DEF-VIEW generate-block cont-assign" is narrower than `inDefGenCaExpr`.**
   The flag has **two** set-sites and only one is the def view:
   `src/ModuleEmit.cpp:25934` (def listing) and **`src/ModuleEmit.cpp:12541`,
   inside the ELABORATED `gen_scope` loop** — the genIfMisevalCaFromSyntax
   fallback that re-emits an elab gen cont-assign from syntax when slang cannot
   bind the assignment (its own comment: "the elab view reuses that path").
   genCaArgPkgParamValueFolds33 therefore fires in an **elaborated** gen scope
   too, in that fallback. No grid cell measures it; `pred33.sh`'s condition C
   cannot separate the two views. Not a demonstrated defect — a demonstrated gap
   between the stated gate and the code gate.

3. **Every cell coordinate cited in the two new production comment blocks is
   stale** — they name an earlier revision of `b1_gen.sv`:
   `36:19 / 44:19 / 51:19 / 54:19 / 73:23 / 74:26 / 83:37 / 130:19` (TypeEmit)
   and `36:32`, `111:17` (ExprEmit). The shipped file's cells are
   `41:19 / 49:19 / 56:19 / 59:19 / 78:23 / 79:26 / 88:37 / 149:19`, `41:32`,
   `116:17` — e.g. `b1_gen.sv:36` is a blank line and `:130` is the `gesc` loop
   header. The README's tables use the right numbers; only the source comments
   are wrong, and the source comments are what the next pass reads.

### F5 — THE SOURCE FENCE COVERS ONLY ONE OF THE TWO SHIPPED LAWS

`pred33.sh` states in its own header that the bare spelling "cannot reach it at
all", and computes `A&C&D` with **A = a `::`-qualified name in a call argument
list**. Correct for genCaArgPkgParamValueFolds33 (TypeEmit, ScopedName arm);
**wrong for genScopeBareArgKeepsRef33**, which fires only on `IdentifierName` —
the bare spelling — in `ExprEmit`. Its fence is `B & C` (import + generate),
which `pred33.sh` computes and then discards as "FYI".

```
                    A&C&D (what was fenced)     B&C (the bare arm's real fence)
uhdm2rtlil                  0                        28 files / 19 test dirs
Surelog tests               7                        33 files
Surelog third_party       225                      1095 files
```

`comm -12 /tmp/e33v_pred/B_u2r /tmp/e33v_pred/C_u2r | wc -l`. u2r's 19 dirs
include `ImportedFunctionCallAsInstantiatedModulePortValueInsideGenFor`,
`ParameterInitializedByOperationOnPackageParametersAndUsedInGenscope` and
`SubmoduleInGenScopeWithGenScopeParametrizedByParameterFromTopModule` — exactly
the shape.

So the report's headline — "**A&C&D = 0 for the whole uhdm2rtlil corpus: this
pass predicts ZERO u2r movers**", with "FALSIFIER: every measured byte mover must
be in that list" — is a prediction for **half the patch**. The outcome (0 u2r
movers) is right; the prediction claimed to have anticipated it did not cover the
arm that could have produced them. GATE 5's "predict movers from source-derived
data FIRST" is half-satisfied.

### F6 — the head census has one error, on the subtree the brief told you to census

`README.md` 6's table gives golden's element 2 as `ref_obj (region_cfgs[8].base)`.
It is not. From my own `uhdm-cmp` log, LHS vs RHS:

```
GOLDEN   \_ref_obj: (base), id:83559, line:315:33, endln:315:37
           |vpiName:base                      <- and NO vpiFullName at all
OURS     \_ref_obj: (region_cfgs[MpRegions].base), id:82246, 315:33-315:37
           |vpiName:base
           |vpiFullName:region_cfgs[MpRegions].base
```

The head subtree therefore carries a **second, independent** difference: golden
leaves the middle hier_path element's `vpiFullName` unset and we synthesise one.
Element 3 does carry a fullname on both sides. Everything else in 6 — the
`cont_assign` parent, the index constant (8 / size 32 / UINT / ct 9 / span
315:22-315:31), the index's `vpiParent` (`param_assign@28:18` vs our
`bit_select`) and the ts-ref owner — I confirm exactly. The R9 characterisation
(Surelog re-lexes the name off the REDUCED tree) is sound and correctly not
forked into this pass; it just needs one more line.

### F7 — a3_ctx's "BEFORE" number is a stale baseline

`README.md` 2.0 prints `a3_ctx | 16 cells | 7 before | 1 after`. Measured with
`cells33.py` on my own pristine `a060719`, `a3_ctx` is **2 before, 1 after**:

```
$ python3 cells33.py /tmp/e33v/a3_ctx_pris/{g,o}.dump   ->  CELLS total=16 cell-diffs=2
$ python3 cells33.py /tmp/e33v/a3_ctx_pat/{g,o}.dump    ->  CELLS total=16 cell-diffs=1
```

The `7` is r10earl32's own 3.0 number for that arm — measured with the
**view-collapsing `cells32.py`** (10 cells, not 16) against a **pre-r10earl32
base (981f2e3)**. Mixing it with this pass's 16-cell / 1-after figures produces
"7 -> 1", which the report then calls "the sharpest number in the pass". The
same-instrument, same-baseline number is **2 -> 1: one cell fixed** — and, per
F1, one object lost. The other four "before" numbers (`31 / 28 / 8 / 13`) I
reproduce exactly, so this is the only stale one.

### F8 — EMPTY PRODUCT CELLS, HUNTED (generate x call-kind x qualified/bare x view)

Two new arms, `tools/probe/r10earl33repro/v5_holes.sv` and `v6_tfnest.sv`, driven
by the pass's own `arm33.sh` / `cells33.py`, run on both binaries:

| product cell | shipped grid | measured here | result |
|---|---|---|---|
| **`task_call`** argument, bare, ELAB gen process | absent — the gate names `uhdmtask_call`, no cell exercised it | v5 42:20 x2 | pristine `constant` (wrong) -> patched `ref_obj` = golden's kind/name. **The gate's task half is correct.** |
| `task_call` argument, **qualified**, elab gen process | absent | v5 43:20 x2 | folds, equal before and after OK |
| bare read reached by an **EXPLICIT** (non-wildcard) import | absent — every shipped bare cell uses `import p::*` | v5 51:20 / 52:25 x2 | patched matches golden's kind/name OK (the law is import-form-agnostic, as it should be) |
| bare pkg-param call arg in a **FUNCTION BODY** declared inside a gen block (law 24 excludes `currentTf`; law 33 does not) | absent | v6 27:17 x2 | **unchanged** before/after — the flags are not live there, so the missing `!currentTf` is harmless. Golden keeps a ref (`work@...gtf[0].inner.P`); we fold. **A fourth container of the same family, pre-existing, unreported — V4 below.** |
| bare pkg-param call arg in a gen-scope **LOCALPARAM initialiser** (law 24 excludes `inParamInit`; law 33 does not) | absent | v6 38 | not reachable — the flags are cleared before param emission OK |
| `sys_func_call` argument in a def-view gen CA | b1 k9 88:23 | re-measured | equal both sides, untouched OK |
| `inDefGenCaExpr` in the **ELAB** miseval fallback (`ModuleEmit.cpp:12541`) | absent | not constructible from a legal source in my budget | **still empty — F4.2** |
| a **local shadow** defeating the symbol-identity half of gate (3) | absent | — | **still empty**; the code is right by inspection, nothing measures it |

No over-fire was found in any product cell I could build. Both arms are left in
the repro directory.

---

## 3. RANKED RESIDUES (mine, on top of the report's R1-R9, which I do not dispute)

* **V1 — the `enum_const` binding on gen-scoped pkg-param call-arg refs.** F1's
  regression and F2's under-fire are one law: golden binds every such ref to a
  per-instance clone carrying the parameter's own `HEX` / `vpiDecompile` /
  `vpiSize`. 5 measured objects lost, 11 measured objects never minted. **Highest
  value: it is a regression, it is one clause, and it is inside this pass's own
  gate.**
* **V2 — `cells33.py` must read `vpiActual` on the argument.** Until it does,
  every "exact" in this family is an equality of seven fields. One line in
  `rows()`. Without it V1 cannot be regression-tested.
* **V3 — the stale STATED-GATE comment at `src/ExprEmit.cpp` ~4608** and the
  stale cell coordinates in both new comment blocks (F4.1, F4.3).
* **V4 — a bare pkg-param call argument inside a FUNCTION declared in a generate
  block.** Golden keeps a gen-scoped ref (`work@j33top.u1.gtf[0].inner.P`), we
  fold a constant with a formal ts. Pre-existing, unchanged by this pass,
  measured for the first time here (v6 27:17 x2). The fourth container of the
  19 / 24 / 33 family.
* **V5 — `pred33.sh` needs a second fence** (`B & C`) for the bare arm, or the
  falsifier claim must be scoped to law 1 only (F5).
* **V6 — the head's second field**: golden leaves the middle hier_path element's
  `vpiFullName` unset (F6). Belongs with R9.
* **V7 — the ELAB `inDefGenCaExpr` reach** (`ModuleEmit.cpp:12541`) needs a cell
  before anyone widens or narrows that flag (F4.2 — and the report's own R2 wants
  to widen it).

---

## 4. WHAT I DID NOT FIND

* **No over-fire anywhere.** Every cell that moved, moved toward golden on kind,
  span, name and parent. The seven other r10earl32 arms are byte-identical.
* **No corpus impact from F1.** 0/679 u2r, 1/953 surelog, and the single mover's
  entire shape delta is the eight `prim_present.sv` span edits — no `enum_const`,
  no `ref_typespec`, no `vpiConstType`, no bare field line.
* **No boundary breach.** tfBodyConstArgNeedsEvaldBody60, r10earl31/30,
  r10uvm61, r10svs8: 0 touched lines, 0 changed goldens. The one declared
  collision with fcArgPkgParamValueFolds32 is real and is reported; F1 is a
  *second*, undeclared collision — with genNestedScopePkgParamNoFold24, whose
  container the pass claims to preserve.
* **No harness or CSV edit.** `verify_golden.py`, `check_goldens.sh` and
  `results/*.csv` untouched; `GOLDEN_DEFER` unset; no `git stash`.

---

## 5. RECOMMENDATION

**Land after the F1 clause.** The core is sound, the target cells are on golden,
the byte reach is one database and fully attributed, and the build is
bit-reproducible. But it ships a regression against `a060719` on
genNestedScopePkgParamNoFold24's own container, documents it as an abstention
that "still wins", and asserts it with an instrument that cannot see the field
that moved. Add `&& !genNestedScopeEmit24` to `genScopeBareArg33`, teach
`cells33.py` to read `vpiActual`, correct the four false statements named in F1,
F4.1, F5 and F7 — then it is a clean PASS.

---

### FILES AND ARTEFACTS

```
worktrees          .claude/worktrees/r10earl33v (patched)   .claude/worktrees/r10earl33vpris (pristine)
shipped arms       tools/probe/r10earl33repro/{b1_gen,b2_init,b3_text,v4_more,a3_ctx}.sv
NEW verifier arms  tools/probe/r10earl33repro/{v5_holes,v6_tfnest}.sv
arm runs           /tmp/e33v/<arm>_{pris,pat}/                       (deleted after this report)
sweeps             /tmp/e33v_sw/{u2r,sl}_{pat,pris}.csv + wd_*       (deleted after this report)
Earlgrey dumps     /tmp/e33v_eg/{g,pris,pat}.dump, cmp_{pris,pat}.log (deleted)
golden database    ~/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
```
