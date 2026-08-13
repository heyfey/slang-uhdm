# r10uvm66 — ADVERSARIAL VERIFICATION of § declInitWrittenNewNoStmt66

**VERDICT: PASS.** Every number in the implementer's report reproduced on binaries
I built myself — including both md5s **bit-for-bit** — the briefed head is
**CLEARED on all three target rows** (262 → 33 cmp lines, `grep -cF get_link` = 0),
all five gates are green independently, and the per-object audit gives
**OVER-FIRE 0** and **0 SAME→DIFF over 17,456 whole-design cells across two
databases**. The law's DIRECTION, its two call sites, and its constructor
exclusion are all confirmed, and the constructor exclusion is *finer* than the
report claims — I measured the split it never measured and the implementation
gets both halves right.

**But the gate is ONE TERM SHORT, again, in exactly the way this pass diagnosed
in the clause it replaced.** `CopyClassExpression` — `T v = new src;` — is a
WRITTEN `new` construction, golden DROPS it exactly as it drops `new()` and
`new[n]`, and the shipped predicate does not list it. Measured on my arm
`v1_qualcopy.sv` cells **w05/w06**. It has **0 corpus sites**, so it moves no
gate and blocks nothing; it is finding 1 and residue 1 below.

Base: the patch was applied to a **FRESH `3076437`** worktree (`/tmp/wt66v`),
with a pristine control at the same commit (`/tmp/wt66vp`). It **also
`git apply --check`s clean on the CURRENT branch head `45716d3`**, and the two
intervening commits (r10svs13 `42c42f6`, r10earl36 `45716d3`) touch **neither**
`src/StmtEmit.cpp` **nor** `include/UhdmExporter.h` — so there is no collision
with either live pass. `results/*.csv` were only ever read (`git status
--porcelain results/` empty at the end).

---

## 0. WHAT I REPRODUCED, AND WITH WHAT

| | value | reproduced? |
|---|---|---|
| patch md5 | `c33acf9847e9ed7da059d16fc0c888ca` | yes — and re-`git diff`ing my applied worktree against `3076437` regenerates a 2944-line patch with the **same md5**, so the deliverable round-trips |
| `git apply --check` on fresh `3076437` | clean | yes (also clean on `45716d3`) |
| patch scope | `include/UhdmExporter.h`, `src/StmtEmit.cpp`, `tools/probe/r10uvm66repro/*` only | yes — 21 files, 2780 insertions, 7 deletions, nothing else |
| CONTROL binary md5 | `c7f318688961a24d51d9a4d958bcf2ad` | **yes, bit-for-bit, from my own build** |
| SHIPPED binary md5 | `a79347834ca32a31f144147b9734a469` | **yes, bit-for-bit, from my own build** |

Both builds: absolute build dirs `/tmp/wt66v/build`, `/tmp/wt66vp/build`;
`[100%] Linking CXX executable slang-uhdm` → `[100%] Built target slang_uhdm`
read in each log **before** any md5; `grep -c "error:"` = **0** in both; each md5
taken in its **own** command and matched against `^[0-9a-f]{32}$`. Both trees
`git rev-parse HEAD` = `3076437e5f47ab92f85712b8139cf5c41115b0da`, **grep-checked**
against that literal, not eyeballed. BINARY IDENTITY CHECKED MECHANICALLY, not
by filename: `strings -a build/slang-uhdm | grep -c declInitWrittenNewNoStmt66`
= **1** on the patched binary and **0** on the control. `git stash` never used;
`GOLDEN_DEFER` `[UNSET]` at every launch; the four slang-fenced names never
dispatched (`canaudit.sh` FENCE-BREACH=0); slang not patched.

### STATED GATE == CODE GATE — read off the diff with comments stripped

`git diff 3076437 -- src/StmtEmit.cpp include/UhdmExporter.h`, non-comment lines,
is **exactly**: `class VariableSymbol;` forward decl · the declaration · a
**7-line** body (`dt = vs.getDeclaredType()` · `isyn = dt->getInitializerSyntax()`
· `!isyn → false` · `return isyn->kind == NewClassExpression || isyn->kind ==
NewArrayExpression`) · call site 1 **replacing** `if (init && init->kind ==
ExpressionKind::NewClass)` · call site 2 `continue`. **No** change to
`initCount`/`eff9`, to the wrapper decision, or to the anchor. `grep -rn` gives
**1 declaration, 1 definition, 2 call sites**. `emitCtorBody27`'s `EK_BID` arm
(read at `StmtEmit.cpp:888`) emits its assignment **unconditionally** — the
constructor exclusion is a real absence, not a gated one.

---

## 1. GATES, RUN INDEPENDENTLY

| gate | claimed | mine |
|---|---|---|
| 1 BUILD | md5s above | **identical** |
| 2 GOLDENS | 23/0; `/bin/false` 0/23 | **23/0; 0/23** |
| 3 u2r testflags | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL; dump 496 match / 183 differ / 52 blank; `ct8rows` 0 rows | **identical**, 731/731 rows, **0 differing ROWS** vs `results/gate_uhdm2rtlil.csv` |
| 3 u2r default | dump 492 / 187 / 52 | **identical** |
| 4 surelog default | 467 / 13 / 5 DEFERRED / 284 / 25 | **identical** |
| 4 surelog testflags | 463 / 10 / 5 DEFERRED / 286 / 23 / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM | **identical** |
| 4 `ct8rows` vs `results/golden_surelog.csv` | 1588 rows, 0 differing ROWS, histograms identical | **identical** (default 327 blank/242 differ/225 match; testflags 331/298/165) |
| 5 byte verifier, surelog | 7 / 953 movers; SELFCHECK 952/953; SELFCHECK1 = 8 | **identical, and the mover NAMES are the predicted 7** |
| 5 byte verifier, u2r | 0 / 1358; SELFCHECK 1357/1358; SELFCHECK1 = 1 | **identical** |

The pristine control sweep gives the **same** status/dump histograms in both
modes, so those figures are properties of the corpus, as claimed.

**MOVER SET, by name, mine:** `default/{BuildUVMPkg, Scoreboard, SeqDriver,
SimpleUVM}` + `testflags/{BuildUVMPkg, SeqDriver, SimpleUVM}` — the predicted 7,
no more, no fewer. `SimpleConstraint` did **not** move; `BlackParrotComplex` did
**not** move.

**CENSUS-PREDICT, re-run by me from source:** u2r corpus **0 sites in 0 files**
(→ 0 movers, confirmed by the byte verifier); `uvm-1.2/src` **61 sites in 19
files**; `tests/SimpleConstraint` **1 site**, `top.sv:51 frame_t frame = new();`
(already covered pre-patch → predicted not to move, did not);
`tests/BlackParrotComplex` **0 sites**. All four figures match the report.

### CANARIES

```
canaries.sh vs surelog baseline : ok=52 changed=0 absent=0 unknown-names=7   PASS
ctcan2.sh EXPECT_UNKNOWN=1 (sl) : ok=58 changed=0 absent=0 unknown=1         PASS
canaries.sh vs u2r baseline     : ok=8  changed=0 absent=0 unknown-names=25  PASS *
ctcan2.sh EXPECT_UNKNOWN=6 (u2r): ok=1  changed=0 absent=0 unknown=6         PASS *
canaudit.sh canaries.sh ctcan2.sh: audited=29 UNCOVERED=0 FENCE-BREACH=0     PASS
BY NAME, whole row, diffed against the committed baseline: InterfaceModPort,
BlackParrotComplex, SimpleConstraint, SVSwitch, ApbSlave, SeqDriver,
BuildUVMPkg, SimpleUVM, Scoreboard -> BY-NAME IDENTICAL
```

`*` **finding 6**: those two reproduce **only against a testflags-only extract**.
Run the way the sentence reads — the both-modes fresh CSV against the
testflags-only committed baseline — `ctcan2.sh` prints `absent=1` and exits
**`FAIL: a supplementary canary moved.`** The report states the extract for
`ct8rows` ("stated, not hidden") but not for the canary rows.

### DETERMINISM — and I proved the flake is ORDER-ONLY, which the report asserts

`Scoreboard/default`, **4** reps each (the brief asked ≥3):

| binary | distinct sha256 | bytes, every rep |
|---|---|---|
| pristine `c7f31868…` | **3** | 11 133 116 |
| shipped `a7934783…` | **3** | 11 122 503 |

Sizes exactly as reported (Δ = **−10 613**), stable within each binary → flake,
per the standing rule. The report saw 2 distinct hashes for the shipped binary in
3 reps; with 4 reps I see 3. Same phenomenon, more samples — **it is not
one-sided**, so "worse on pristine" was an artefact of sample size.

**The part that matters, and it was asserted rather than measured:** the *dump* is
also nondeterministic (3 distinct dumps in 3 reps) — but `sort dump | md5sum` is
**byte-identical across all three**, and `msdist.sh` between two runs of the SAME
binary is **MULTISET DISTANCE 0**. So the nondeterminism is pure line ORDER, every
multiset instrument (`msdist.sh`, `mv66.sh`, `mvrem66.sh`) has a **zero noise
floor**, and "the dump is the content authority" is now a measurement.
`uhdm-cmp` is stable too: `Scoreboard/default` gives **33 lines / 1 head /
`get_link` 0** in **all three** reps.

---

## 2. THE HEADLINE, INDEPENDENTLY

```
rowheads.sh, PRISTINE   SimpleUVM default 262/1   testflags 262/1   Scoreboard default 262/1
rowheads.sh, SHIPPED    SimpleUVM default  33/1   testflags  33/1   Scoreboard default  33/1
grep -cF get_link on all three fresh cmp logs: 0   0   0
Scoreboard/testflags: SKIP-NOFILE (SLANG_REJECT, no database) — counted, not hidden
```

New head, all three rows: `constant @410:30-410:60  INT:115199` under
`param_assign @410:11-410:62`, `ref_typespec (uvm_pkg)` → `int_typespec
@410:1-410:62`. A fold/typespec family, i.e. the report's residue 4, confirmed.
SimpleUVM's two cmp logs are md5-identical; Scoreboard's differs only in ids.

**CENSUS.** The report's child-by-child census of `begin @255:7-255:29` is
correct in both fields — golden `Stmts=[method_func_call set@255:15,
return_stmt@256:7]` with `ce_link.vpiParent` = the BEGIN, ours a surplus leading
`assignment@254:29-254:48` owning the variable — and I re-derived it from the two
dumps rather than from the report.

### The arms, cell for cell

| arm | pristine | shipped | multiset distance to golden |
|---|---|---|---|
| `a1_declinit` | A 39/**8** · B 44/**9** UNM 1 | A 47/**0** · B 53/**0** UNM 1 | 186 → **18** |
| `a2_slots` | A 31/**14** · B 47/**15** | A 44/**1** · B 62/**0** | 397 → **123** |
| `a3_count` | A 25/**7** · B 21/**6** | A 27/**5** · B 24/**3** | 200 → **151** |
| `a4_memberexpr` | — | cmp heads **0**, lines **0** | 36 → 36 (unchanged) |

Every arm total matches the report exactly. **Transitions, computed per cell:
DIFF→SAME 17 + 28 + 5 = 50, SAME→DIFF 0, no key appearing on one side only.**
The golden-only line direction *fell* in every arm (a1 12→2, a2 76→64, a3 77→75),
so the deletion never crossed golden at the arm level either.

I re-derived the load-bearing cells from the tables rather than trusting them:
**m07** (`ce; ce = new(name);` as a STATEMENT) is KEPT by golden and untouched —
the cell that separates this law from § thisSuperNewAssignNoStmt3; **m06/m17/m21**
KEPT, **m08/n10b** DROPPED — neither `class_var` nor `array_var` is a term;
**n09** (`= new;` no parens) and **n10** (`new[3](src)`) fixed; **n07** golden's
**EMPTY** wrapper `begin@128:10-128:24[]` matched exactly; **n02/n03** the
dynamic-array twins fixed, and I checked **n03**'s whole `initial` subtree
(`work@a2mod`, lines 227-230) is now **byte-identical** to golden, statement list
included. **a4**: both sides carry 18 `vpiExpr` and 13 `new` calls; its 106
residual dump lines are `class_typespec` field-ORDER, no `vpiExpr` among them —
the parens hypothesis is refuted, as claimed.

### The whole-design reverse audit — the instrument that would catch an over-delete

Run by me on **two** databases with a full-key variant of `ct66cells.py`:

| | SimpleUVM pre | SimpleUVM post | BuildUVMPkg pre | BuildUVMPkg post |
|---|---|---|---|---|
| A body signature | 2862 / **217** | 2893 / **186** | 3286 / **83** | 3319 / **50** |
| B variable vpiParent | 4825 / **620** UNM 101 | 4843 / **602** UNM 101 | 4762 / **623** UNM 77 | 4777 / **608** UNM 77 |
| DIFF→SAME | — | **49** | — | **48** |
| **SAME→DIFF** | — | **0** | — | **0** |
| UNMEASURED→DIFF | — | **0** | — | **0** |
| **OVER-FIRE** | **0** | **0** | — | — |
| UNDER-FIRE | **21** | **3** | — | — |

8625 keys on SimpleUVM and 8831 on BuildUVMPkg, identical key sets before and
after. The 3 residual under-fires are the named ones, and I read their source:
`uvm_component.svh:3381 static bit first = 1;`, `:3383 uvm_cmdline_processor clp
= uvm_cmdline_processor::get_inst();`, `:3467 static bit initialized = 0;` —
**no `new` on any right-hand side.** The 5 SimpleUVM rows that changed and are
still DIFF each lost exactly the surplus leading assignment and retain a
pre-existing unrelated defect (a nested `begin@113:4` span / `if_stmt` end
column) — the deletion in every one is toward golden.

### Movers per shape

`mv66.sh` on `default/SimpleUVM`: **gain 670, ADDED 49, REMOVED 1211**, distance
144362 → 143692 — the report's figures to the digit. **48 distinct ADDED texts,
all 48 "ours was BELOW golden", 0 above.** Residues 1 and 3 reproduce exactly:

| SimpleUVM `\_method_func_call: (new)` | golden | pristine | patched |
|---|---|---|---|
| total | 702 | 791 | 693 |
| under `\|vpiRhs:` | 341 | 398 | **343** |
| under `\|vpiParent:` | 320 | 362 | 319 |
| under `\|vpiExpr:` | **41** | **31** | **31 — UNCHANGED** |

| SeqDriver `add_hdl_path::concat` | golden | pristine | patched |
|---|---|---|---|
| CLONE-view object lines | 8 | 8 | **6** |
| clone `\|vpiParent:` / `\|vpiVariables:` / `\|vpiLhs:` | 4 / 4 / 0 | 2 / 4 / **2** | 2 / 4 / **0** |
| HOME-view object lines | **12** | 14 | **12 — exactly golden** |

---

## 3. NUMBERED FINDINGS

**1. THE GATE IS ONE TERM SHORT: `CopyClassExpression`.** *(real under-fire of
the stated law; 0 corpus sites; does not move a gate)*

`v1_qualcopy.sv` cell **w06** — `v1c ce = new src;` as the only declaration in a
method — golden emits **no** declaration assignment and parents `ce` on the
BEGIN, exactly as for `new()`/`new[n]`; the **patched** binary still emits
`assignment@71:14-71:26` and still parents `ce` on it. Cell **w05** repeats it
with a plain `new()` sibling, and the sibling moves while the copy form does not.
The law's headline reads "whose WRITTEN initializer is a `new` construction", the
copy form **is** one, and `src/ParamEmit.cpp:20302` already lists
`CopyClassExpression` beside the other two for its own `newInit26` decision — so
the omission is not even consistent inside the tree. The predicate's comment
states an exclusion for `NewCovergroupExpression` and says **nothing** about the
copy form, so this is an unstated omission, not a declared boundary — the same
species of error the pass corrected in the clause it replaced (`NewClass` only).
**0 corpus sites**: every `new <handle>` in `uvm-1.2/src` is inside a comment (3
hits, all commented), and every corpus occurrence
(`SVSwitch/Driver.sv:38 pkt = new gpkt;`, `Google/8.12--shallow_copy.sv:34`,
`Ibex`/`Opentitan` `riscv_instr.sv`) is a plain assignment STATEMENT, never a
declaration initializer.

```sh
cd tools/probe/r10uvm66repro
SLANG_UHDM=<shipped> ./ct66arm.sh v1_qualcopy.sv /tmp/w
python3 ct66cells.py /tmp/w/g.dump /tmp/w/o.dump | grep -E "w05|w06"
```

**2. `mvrem66.sh` EXITS `FAIL` ON A DATABASE IN THE PASS'S OWN MOVER SET, and
its crossing was decomposed one database over.** *(benign — I decomposed it —
but shipped red)*

```sh
bash tools/probe/r10uvm66repro/mvrem66.sh <golden> <pristine> <patched> BuildUVMPkg_default; echo $?
# ... INDENT-BLIND CROSSED  golden=11677 pristine=11679 patched=11672   |vpiConstType:6
# FAIL: INDENT-BLIND CROSSED rows above ...      exit 5
```

The bucket counts match the README's table exactly (verbatim 392 / 361 (333) /
**11** / 20; indent-blind 176 / 161 (148) / **1** / 14) — but §4.2 decomposes
family (a) on **SimpleUVM** and generalises, and on BuildUVMPkg the same family
behaves differently: `\_method_func_call: (new)` splits 2/378/389 (golden),
2/411/447 (pristine), 2/370/**391** (patched), i.e. the `vpiParent` half goes
**+33 → −8** there, not −1. I decomposed it: counting only the fields that OWN a
call (`vpiRhs`/`vpiExpr`), BuildUVMPkg is golden **391** / pristine 449 /
patched **393** — still **+2 above golden**, so nothing golden owns was deleted;
the `vpiParent` and `vpiConstType:6` deficits are child-population deficits that
pristine's +33 surplus was masking. Confirmed by the per-object audit on that
same database: 48 DIFF→SAME, **0 SAME→DIFF** over 8831 cells. Benign — but a
pass should not ship an instrument that exits non-zero on its own mover with the
justification measured on a different database.

**3. `ct66cells.py` TRUNCATES ITS PRINTED ROWS, so the printed table cannot be
audited for long names.** `ct66cells.py:173` prints `k[:42]`, `gv[:40]`,
`ov[:40]`. Counting uses the **full** values (verified: my full-key variant
reproduces every total to the digit), but on a UVM-scale run distinct cells print
identically (`function|uvm_pkg::uvm_algorithmic_comparat`) and a DIFF inside a
long statement list is invisible in the printed row. The instrument's own header
promises the span "is printed in its own column so a disagreement is still SEEN";
for long keys it is not. Any reader who parses the printed table — as I did first
— gets **UNDER-FIRE 7 instead of 21** from key collisions.

**4. EMPTY-PRODUCT CELLS: ~18 rows of every arm's SAME total measure nothing.**
`work@mailbox::*`, `work@process::*`, `work@semaphore::*` — slang's built-in
class stubs — appear as `-NONE-`/`-NONE-` SAME in **every** arm: a1 20 of 100
SAME rows are both-`-NONE-` (18 of them builtins), a2 19, a3 19, and my own arms
18 each. They are not authored cells and cannot fail. Plus two *authored* empty
products, both of which the report does disclose: **a1 m03** (the decl+init is
the whole body) is `-NONE-`/`-NONE-`, and **a1 a1ctor's `ce`** is
`-NOOBJ-`/`function@200:7` → keyed UNMEASURED, i.e. an ours-EXTRA object read as
"unmeasured" rather than as a DIFF. A new one my arm found: **v1 w04**
(`var v1c ce = new();`) — golden emits **no `class_var` at all**, so that cell is
`-NOOBJ-` too and the `var` qualifier is, strictly, still unmeasured.

**5. THREE a1 CELLS ARE MEASURED BUT NOT ITEMISED, AND ONE PROSE COUNT IS OFF BY
ONE.** `a1_declinit.sv` carries 27 cell tags; §2.1's table lists 24. **m23**
(package free function, `int x = a+1`), **m25** (module function), **m27** (a
module `initial`) are in the instrument's output — all SAME both sides, so
nothing is hidden — but never itemised. And §2.5's prose says "The 8 remaining
DIFF cells" while its own totals sum to **9** (a2 1 + a3 5 + a3 3).

**6. THE u2r CANARY NUMBERS NEED THE TESTFLAGS EXTRACT, AND THAT IS NOT STATED.**
See §1: run against the both-modes CSV, `ctcan2.sh` exits **FAIL**. The numbers
themselves are right.

**7. POSITIVE — THE SYNTAX KEYING IS STRONGER THAN THE REPORT CLAIMS, and I
measured it.** The report justifies reading `getInitializerSyntax()` instead of
the bound kind only as sharing "one vocabulary" with § 3. The real reason is
bigger, and it is in this tree already: `ExprEmit.cpp:497 sourceIsNewClassExpr55`
documents, with slang source citations, that slang **refuses to bind** `new` when
the target is an ABSTRACT class or not a class at all — shapes uvm-1.2 "hits
constantly" inside a generic class's DEFAULT specialization, where the diagnostic
is suppressed — and returns an `InvalidExpression` that still carries the
`NewClassExpressionSyntax`. For those, `init->kind == ExpressionKind::NewClass`
**structurally cannot fire** and the syntax keying does. My arm `v3_unbound.sv`
reproduces it (`class v3gen #(type T = v3abs); T h = new();`): pristine emits the
surplus `assignment@59:12-59:21` and parents `h` on it, golden and the **patched**
binary both keep only `[assignment@60:10-60:17]` with `h` on the BEGIN —
**DIFF→SAME, and unreachable by the old clause.** (Written at package scope
instead, the same line is a *hard* slang error with no database at all, and
`v3real h = new[3];` is 3 SYNTAX errors for Surelog; both cells were deleted from
the arm and that is recorded in its header rather than hidden.)

**8. POSITIVE — THE CONSTRUCTOR EXCLUSION IS CORRECT AND FINER THAN STATED.**
The report measures one constructor cell (a2 n01). `v2_ctornest.sv` measures the
boundary the exclusion actually has, and the implementation is right on every
side of it — **A 26/1 → 27/0, B 34/1 → 35/0, 0 SAME→DIFF**:

| cell | shape | golden | patched |
|---|---|---|---|
| x01 | ctor's OWN list, ported, `v2c ce = new();` | **KEEPS** the assignment, `ce` on it | same |
| **x02** | **the SAME decl one written `begin` deeper in the SAME ctor** | **DROPS** it, `ce` on the inner begin | **same — and this is call site 1 firing inside a constructor, which no cell in the pass measures** |
| x03 | control: nested `begin` in an ordinary method | DROPS | same |
| x04 | ctor's own list, `int d[] = new[3];` | **KEEPS** — the exclusion covers `new[]` too | same |
| x05 | the same one `begin` deeper | DROPS (was the arm's only pristine DIFF) | **fixed** |
| x06 | OUT-OF-BODY ctor definition | KEEPS | same |
| x07 | ctor led by `super.new(seed);`, decl in a nested block | list kept, nested decl dropped | same |

So "the class CONSTRUCTOR's own list is excluded" is exact — *the list*, not the
constructor — and the implementation gets that from having no ctor gate at site 1
and no predicate at `EK_BID`. It is right, and it was right by luck of structure
rather than by measurement; x02 is the cell that should have been in a2.

**9. BOUNDARIES HOLD, MEASURED NOT ARGUED.** Every arm of every neighbouring law
is **bit-identical** pre vs post — same cmp lines, same head count, same dump
content, on both binaries:

```
§ 65 (r10uvm65repro) b1_empty 96/8  b2_scopes 230/51  b3_taskport 110/118
                     v1_qualdrop 570/85  v2_views 18/61  v3_ports 13/100  v4_items 96/105
§ 64 (r10uvm64repro) b1_cond 1638/38  b2_modtwin 874/672  b3_kinds 2974/4
                     v1_prod 130/11  v2_ctx 798/86  v3_loopwin 1066/5
§ 62 (r10uvm62repro) c1_endlabel 235  c2_neighbours 26  c3_edge 150   (dump content +/-)
§ 3  (r10svs3repro)  a1_newlhs 25  a2_thisnew 97  a3_position 112
                     a4_ctorspan 109  a5_ctornest 33                  (dump content +/-)
```

`r10svs13` / `r10earl36` files were not written by the patch, and their commits do
not touch the two production files. **No collision.**

---

## 4. RANKED RESIDUES (mine, re-ranked)

1. **`CopyClassExpression` is not in the gate** (finding 1). A one-term fix with a
   measured cell (`v1 w05/w06`) and 0 corpus sites. Highest-ranked because it is
   the law's *own* stated scope, not a neighbouring family.
2. **`vpiExpr`-on-a-variable `new` deficit: golden 41, ours 31**, SimpleUVM,
   **unchanged** by this pass (31 → 31). Discriminator unknown; a4 refutes the
   written-parens hypothesis and I confirmed a4 is CMP-EQUAL with 18 `vpiExpr` on
   both sides. Note the adjacent asymmetry that may be the discriminator:
   `ModuleEmit.cpp:6691` gives a variable's `NewClass` initializer a
   `method_func_call` `vpiExpr` but has **no `NewArray` arm**, and
   `UhdmExporter.cpp:571` (`emitClassPropInit29`) is `NewClass`-only for the same
   field.
3. **§ tfItemDeclNoStmt (unowned)** — a `tf_item_declaration` never becomes a body
   statement whatever its initializer. Owns a2 n24, a3 p03/p07/p08/p09 and the 3
   residual whole-design under-fires. Confirmed: p03/p09 carry **no `new`** and
   are DIFF on the pristine binary, so `initCount`/`eff9` were correctly left
   alone.
4. **The new head, all three rows**: folded `constant INT:115199 @410:30` +
   `int_typespec @410:1-410:62` under a `param_assign`. A fold/typespec family.
5. **Package-clone `vpiParent` back-reference deficit** (SeqDriver, golden 4 /
   ours 2), unchanged; the HOME view is now exactly golden (12 = 12).
6. **A body of only uninitialised block-item decls**: golden emits an EMPTY
   `begin`, we emit none (a3 p01/p08/p09). Out of scope here — n07 and p03
   constrain the count in opposite directions.
7. **NEW, from my arms:** a `do_while`'s SPAN — golden `92:10-96:26`, ours
   `92:10-92:12` (v1 w09, DIFF on both binaries); and a **`var`-qualified** class
   handle local, for which golden emits **no variable object at all** (v1 w04,
   `-NOOBJ-`), so the `var` qualifier remains strictly unmeasured for this law.
8. 186 A / 602 B DIFF cells remaining on SimpleUVM, untriaged.

## 5. REFUTATIONS I CHECKED, AND THE ONE I ADD

Everything the report refutes, I re-measured and it holds: m07 (not § 3's law),
n01 (not all three sites), n02/n03 (the old clause was one term short), m06/m17/m21
vs m08/n10b (neither a class-handle nor a `new[]` law), n07 vs a3 p03 (the count
must not be gated), n09 (no-parens is the same construct), a4 (the parens
hypothesis for residue 1), and the removed-line instrument's own first rule.

**The one I add: "the gate reads the two SyntaxKinds § 3 reads, so the vocabulary
is complete."** It is not. § 3's RHS half needs only the two because its LHS half
(`this`/`super`) already scopes it; a DECLARATION has no LHS to scope it, so the
declaration form reaches a third written `new` — the copy form — and golden drops
that one too. Sharing a vocabulary with § 3 was the wrong completeness argument;
the right one is the enumeration of written `new` forms, and it has three members.

---

## 6. FILES

Arms I added, in this directory: **`v1_qualcopy.sv`** (qualifiers ×4, the COPY
form ×2, `foreach`/`do-while`/`repeat` bodies, a `virtual` method),
**`v2_ctornest.sv`** (the constructor exclusion's boundary, 7 cells),
**`v3_unbound.sv`** (the § 55 refused-bind shape, with the two cells neither tool
can compile recorded in its header). They are **not** part of
`/tmp/r10uvm66.patch`; they are the verification, and they use the pass's own
`ct66arm.sh` / `ct66cells.py` / `msdist.sh` unmodified.

Sweep workdirs (`/tmp/v66_slw_{pre,post}`, `/tmp/v66_u2rw_{pre,post}`) were
deleted after the byte verifier ran, as the standing rules require.
