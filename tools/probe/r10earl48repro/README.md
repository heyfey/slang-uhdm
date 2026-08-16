# r10earl48 — § elseArmFirstItemReplaces48

> **ERRATUM (verifier, `README.verifier.md`).** Three statements below are
> corrected there and the code that landed differs accordingly:
> **(1)** the FIRST-ITEM clause is one kind short — an **empty item `;`** is an
> ITEM, golden keeps the level when one stands before the if-generate, and the
> version of `elseArmSurvivor48` in this README's patch promoted anyway
> (a REGRESSION: the pristine binary matched golden there). Fixed —
> `README.verifier.md` §F1, arm `v48v_emptyitem.sv`.
> **(2)** R1's "EMPTY promoted block ⇒ NOTHING AT ALL" is about a truly empty
> `begin end`; a block holding only `;` is **promoted** by golden (§F2, arm
> `v48v_emptyitem2.sv` `y3`) and is fenced separately as R1b.
> **(3)** R6 is inert, not "collapsed by the same rule": a miseval-taken arm's
> children are all `isUninstantiated`, so the law cannot fire there (§F7.1).
> Everything else in this file reproduced number for number on an independently
> built pair of binaries.

**THE HEADLINE: the 644-line Earlgrey head is CLEARED and the row ADVANCES to a
66-line head in a different file.** The design-wide census, run on the pristine
pair before a line of code was written, said the whole population is
`work@prim_present` and **no other module in the design** — 31 `gen_enc` levels
to delete, 31 `gen_d64` levels to re-parent and re-span, 31 `gen_k128` sub-trees
to drop — and predicted `GOLDEN-ONLY 0 / OURS-ONLY 0` afterwards. The patched
run measured **exactly that**: `shared 5182, GOLDEN-ONLY 0, OURS-ONLY 0, span
disagreements 0`. Per-top-module, the elaborated block of `prim_present` is the
**only** one whose bytes moved; the other nine — including `top_earlgrey`'s
3 366 051-line tree — are **byte-identical**, and so is the whole DEF view.

The byte verifier found **one corpus cell the census never predicted** —
`IfGen3`, in both surelog modes, with a **ZERO size delta** — and it too moves
toward golden (multiset distance 77→35 and 117→35, span now golden's exactly).
It is the MOVER RULE's own case: zero proved nothing, and three solo runs of
each binary proved the change real. The fourth mover, `Scoreboard`, is proved
**not** real by the same instrument — the PRISTINE binary produces the
"patched" database 2 runs in 8.

**And the brief's two open questions both have hard answers.**

* *Naming-only or structural?* **STRUCTURAL, and LOSSY.** Golden has no
  `gen_enc` object at all: `gen_d64`'s `gen_scope_array` hangs directly off
  `gen_round[i]`'s `gen_scope`, its span changes from the `begin..end` to its
  first member's, and `gen_enc`'s SECOND generate child — `gen_k128`, holding
  `assign round_key[k+1] = prim_cipher_pkg::present_update_key128(...)` — is
  **gone with its whole sub-tree**. `present_update_key128` appears **0** times
  in golden's elaborated region, and now **0** times in ours.
* *Which if-generates flatten?* Not "unnamed-else", not "directly-inside-for",
  not "single-branch". **A PLAIN-ELSE arm whose FIRST member item is an
  if-generate**, and nothing else. Three purpose-built arms put 24 shapes on
  one page against Surelog and every other candidate is refuted by a row.

* BASE COMMIT `a6e4932`, branch `auto5h`. Worktrees `/tmp/wt_r10earl48`
  (patched, branch `r10earl48wt`) and `/tmp/wt_r10earl48pris` (pristine,
  detached `a6e4932`). Both trees' `git rev-parse HEAD` printed and
  grep-checked: `a6e4932dec6ed191d26cc256e8377b66e5a240f3`.
* Patched binary md5 `e99e73e91ad94071fa61639f222c8054`,
  pristine binary md5 `d44ed8d2fb93787d4d333d98c00da7f6`.
* Production diff: **`src/ModuleEmit.cpp` only** (+109 / −1, three hunks).
  `include/UhdmExporter.h` is NOT touched — the law needs no new member. `slang`
  is NOT patched. `results/*.csv` were READ ONLY. `GOLDEN_DEFER` was never set.
* **OPS NOTE.** The MAIN TREE `/home/heyfey/git-repos/slang-uhdm` moved off
  `a6e4932` to `3a7a6a6` while this pass ran (another agent's landing). Nothing
  in this pass was read from or written to it after the arms were authored;
  every build, sweep, arm and gate ran out of the two worktrees, whose BASE was
  printed and grep-checked on every build.

---

## 1. THE LAW

> **§ elseArmFirstItemReplaces48** — In the ELABORATED view, a TAKEN
> **PLAIN-ELSE** generate arm is **REPLACED** by the taken block of its **FIRST
> member ITEM**, when that item is an **IF-generate**. The arm's level
> disappears; the promoted block hangs where the arm hung, under its **OWN**
> name; and **every other member of the arm — generate or not — is DROPPED**.
>
> A **THEN** arm never collapses. An **ELSE-IF** arm never collapses. If the
> arm's first member is anything but an if-generate — a localparam, a module
> instance, a for-generate, a case-generate — the level stands. If the promoted
> block is **UNNAMED**, the level stands. The rule applies to **unnamed** else
> arms and **recursively**.
>
> A **THEN-branch** promotion re-spans at its own first member's item (a
> localparam counts); an **ELSE-branch** promotion keeps its `begin..end`.

The `§` is greppable and appears in exactly **three** places in the production
tree, all in `src/ModuleEmit.cpp` and nowhere else in `src/` or `include/`:
line 11927 (the `elseArmLeaf48` set + the `elseArmSurvivor48` definition,
immediately above `collapseIfLeaf9`), line 12175 (the span arm inside
`emitBlock`) and line 14940 (the ONE call site, the first statement of
`pushGenBlk9`).

`pushGenBlk9` is the single choke point through which **every** elaborated
generate block passes — the module-level loop, the nested-generate loop inside
`emitBlock`, and its own recursion — so one insertion covers module scope, gen
scope and interface scope, and gives the recursion (a1 `t_e7`) for free.

### 1.1 STATED GATE == CODE GATE

Every clause above is one line of `elseArmSurvivor48` / its call site:

| stated clause | code |
|---|---|
| a PLAIN-ELSE arm | `syn->kind == GenerateBlock && syn->parent->kind == ElseClause` — an ELSE-IF arm's block hangs off the nested `IfGenerate` instead, so this ONE test does the whole then / else-if / else discrimination |
| (never a loop iteration) | `blk.getArrayIndex()` → `nullptr` |
| its FIRST member ITEM | `item` is set from the first non-`TransparentMember`/`EmptyMember`/`Genvar` member's top-level syntax inside `syn` (`while (ms->parent && ms->parent != syn) ms = ms->parent;`) |
| must be an IF-generate | `gm.kind != GenerateBlock \|\| ms->kind != IfGenerate` → `nullptr` (a for-generate arrives as `GenerateBlockArray`, a case-generate's item is a `CaseGenerate`) |
| every other member is DROPPED | `else if (ms != item) break;` — the loop stops at the first member of a different item, and nothing after it is ever emitted |
| an if/else pair contributes BOTH blocks | members of the SAME `item` keep being scanned; the instantiated one wins |
| the promoted block must be NAMED | `b2.isUnnamed` → skipped, so `survivor` stays null and the level stands |
| and instantiated, and a `begin..end` | `b2.isUninstantiated`, `b2.getSyntax()->kind != GenerateBlock` → skipped |
| and non-EMPTY | the trailing loop returns `survivor` only if it has one non-trivial member |
| under its OWN name, where the arm hung | `pushGenBlk9(*surv48, surv48->getExternalName(), parentFull, parentObj, out)` — same `parentFull`, same `parentObj`, same `out` |
| RECURSIVELY | that call is `pushGenBlk9` itself |
| a THEN-branch promotion re-spans | `ssyn48->parent->kind == IfGenerate` → `elseArmLeaf48.insert(surv48)`; `emitBlock` turns that into `underCase9 = true` |
| an ELSE-branch promotion keeps `begin..end` | that insert does NOT happen when `ssyn48->parent->kind == ElseClause` |
| a localparam counts for the span | the member-skip becomes `(!unnamedIf9 && !elseArm48 && kind == Parameter)` |

**FENCED OUT — stated, not implemented.** Golden ALSO emits **NOTHING AT ALL**
for the arm when the first item has no taken block (a2 `u4`, `u5`) or when its
taken block is EMPTY (a2 `u9`). Those are content-destroying and have **0
Earlgrey_0_1 cells** (the census's OURS-ONLY population is 100 % prim_present),
so this pass keeps the level there and states the gap as **R1**. The code says
so in the same words: `elseArmSurvivor48` returns `nullptr` on both.

### 1.2 Why the FIRST-ITEM test and not a content test

The natural rule to write is "an else arm with no non-generate content
collapses". It is **wrong twice**, and a3 measures both:

* `v5` puts the `wire d3; assign d3` **after** the gen child. Golden collapses
  anyway **and drops the wire and the assign**. A content test would have kept
  the level.
* `u6`/`u7` put a localparam / a module instance **before** the gen child.
  Golden keeps the level. A "no content" test agrees here — but only by
  accident, because what actually matters is that the FIRST item is not an
  if-generate. `v3` (a for-generate first, an if-generate second) and `v6` (a
  case-generate first) have **no non-generate content at all** and golden keeps
  the level in both.

One position test explains all five rows. No content test explains any four of
them together.

---

## 2. THE TARGET, AND WHAT IT ACTUALLY WAS

`prim_present.sv:51-118`, elaborated with the module's defaults
(`DataWidth=64, KeyWidth=128, NumRounds=31, Decrypt=0` — `prim_present` is a
TOP module in Earlgrey_0_1, never instantiated):

```systemverilog
  for (genvar k = 0; k < NumRounds; k++) begin : gen_round   // 51
    logic [DataWidth-1:0] data_state_xor, data_state_sbox;   // 52
    assign data_state_xor = ...;                             // 54
    if (Decrypt) begin : gen_dec                             // 58  NOT taken
      ...
    end else begin : gen_enc                                 // 91  TAKEN ELSE
      if (DataWidth == 64) begin : gen_d64                   // 93  <- FIRST ITEM
        assign data_state_sbox = ...sbox4_64bit(...);        // 94-95
        assign data_state[k+1] = ...perm_64bit(...);         // 96-97
      end else begin : gen_d32 ... end
      if (KeyWidth == 128) begin : gen_k128                  // 103 <- SECOND ITEM
        assign round_key[k+1] = ...present_update_key128(...);// 105
      end else if (KeyWidth == 80) ... else ... end
    end
  end
```

Golden's `gen_round[0]` gen_scope holds: two `logic_var`s, the genvar
`parameter k`, the line-54 `cont_assign`, and **one** `vpiGenScopeArray` —
`gen_d64`, at span `94:9-95:95` (its first statement's item, `assign` keyword
through semicolon). We held `gen_enc` at `91:14-116:8`, with `gen_d64` at
`93:28-99:10` and `gen_k128` at `103:...` inside it.

**What uhdm-cmp actually reads** (checked in the generated UHDM sources, not
assumed): `BaseClass::Compare` = VpiType, VpiName, VpiDefName;
`gen_scope_array`/`gen_scope` add VpiFullName and the child vectors. The head
therefore sat on the very first `vpiGenScopeArray` of `gen_round[0]`: golden's
`gen_d64` against our `gen_enc`, name for name.

---

## 3. THE GRID, SHAPE FOR SHAPE

Three purpose-built arms, 24 shapes. LHS is ALWAYS golden (Surelog).
`grid48.py` reads the **uhdmtopModules region ONLY** — the DEF region carries
the very same names under `named_begin` and is identical on both sides, so
merging the views would have hidden the entire phenomenon (r10earl47 R-4 burned
exactly that way). Saved as `grid48_<arm>_{pristine,patched}.txt`.

| arm row | shape | golden | pristine ours | patched ours |
|---|---|---|---|---|
| a1 `t_then` | THEN arm, gen-only, 1 gen child (`genblk_order`) | `t_then.t_then_c` **KEPT** | ✓ | ✓ |
| a1 `t_t2` | THEN arm, gen-only, 2 gen children | **KEPT**, both children | ✓ | ✓ |
| a1 `t_e1` | ELSE arm, gen-only, 1 gen child | **`t_e1_c`** at module level, span 62:7-62:15 | `t_e1.t_e1_c` ✗ | ✓ exact |
| a1 `t_e2` | ELSE arm, gen-only, **2** gen children | **`t_e2_c1` only**, `t_e2_c2` DROPPED | both, nested ✗ | ✓ exact |
| a1 `t_e3` | ELSE arm, wire+assign THEN a gen child | **KEPT** | ✓ | ✓ |
| a1 `t_e4` | **ELSE-IF** arm, gen-only, 1 gen child | `t_e4.t_e4_c` **KEPT** | ✓ | ✓ |
| a1 `t_e5` | UNNAMED else arm, gen-only, 1 child | `t_e5_c`, span **102:7-102:15** | hoisted, span 101:12-103:8 ✗ | ✓ exact |
| a1 `t_e6` | ELSE arm whose only child is a FOR loop | **KEPT** (`t_e6.t_e6_l[0..1]`) | ✓ | ✓ |
| a1 `t_e7` | ELSE arm whose only child is another ELSE arm | **`t_e7_c`**, collapsed TWICE | 3 levels ✗ | ✓ exact |
| a1 `t_l` | the EXACT prim_present shape, in a for-generate | `t_l[i].t_l_d64` at 136:9-136:17, `t_l_k128` DROPPED | 3 levels + k128 ✗ | ✓ exact |
| a2 `u1` | else arm, promoted child **UNNAMED** | `u1.genblk1` **KEPT** | ✓ | ✓ |
| a2 `u2` | UNNAMED else arm, 1 named child | `u2_c` span **55:7-55:15** | span 54:12-56:8 ✗ | ✓ exact |
| a2 `u3` | UNNAMED else arm, **2** named children | `u3_c1` only, `u3_c2` DROPPED | both ✗ | ✓ exact |
| a2 `u4` | else arm, only gen child NOT taken | **NOTHING** | `u4` (empty) ✗ | `u4` ✗ **R1** |
| a2 `u5` | else arm, first child not taken, second taken | **NOTHING** | `u5`, `u5.u5_c2` ✗ | same ✗ **R1** |
| a2 `u6` | else arm, LOCALPARAM before the gen child | **KEPT** | ✓ | ✓ |
| a2 `u7` | else arm, MODULE INSTANCE before the gen child | **KEPT** | ✓ | ✓ |
| a2 `u8` | else arm whose only child is a CASE-generate | **KEPT** | ✓ (span R2) | ✓ (span R2) |
| a2 `u9` | else arm, promoted child EMPTY | **NOTHING** | `u9`, `u9.u9_c` ✗ | same ✗ **R1** |
| a2 `u10` | else arm nested under an ELSE-IF arm | `u10_ei.u10_c` **COLLAPSED** | 3 levels ✗ | ✓ exact |
| a2 `u11` | the same shape in an **INTERFACE**, 2 children | `u11_c1` only | both, nested ✗ | ✓ exact |
| a3 `v1` | standalone EMPTY named if-generate | **KEPT** (empty gen_scope) | ✓ | ✓ |
| a3 `v2` | else arm, first item is an if/**ELSE** pair | **`v2_e`**, span **30:14-32:8** (begin..end) | nested ✗ | ✓ exact |
| a3 `v3` | else arm, FIRST item a FOR-generate | **KEPT**, all three children | ✓ | ✓ |
| a3 `v4` | else arm, FIRST item an if-gen, second a FOR | **`v4_c`**, `v4_l[0..1]` DROPPED | all ✗ | ✓ exact |
| a3 `v5` | else arm, gen child FIRST, wire+assign AFTER | **`v5_c`**, the wire+assign DROPPED | all ✗ | ✓ exact |
| a3 `v6` | else arm, FIRST item a CASE-generate | **KEPT** | ✓ (span R2) | ✓ (span R2) |
| a3 `v7` | else arm, promoted child holds ONLY a localparam | **`v7_c`**, span **91:7-91:29** | nested ✗ | ✓ exact |

Whole-arm verdicts, measured by `grid48.py`'s own path-set counters:

| arm | pristine | patched |
|---|---|---|
| a1 | 19 differing paths, 1 span disagreement | **0 and 0** |
| a2 | 13 differing paths, 3 span disagreements | **5 and 1**, and all six are R1/R2 |
| a3 | 14 differing paths, 1 span disagreement | **0 and 1**, the one is R2 |

`v1` is the control that kills the obvious reading of `u9`: an empty named
if-generate block at module level **does** get an (empty) `gen_scope` in golden.
It is only the PROMOTED empty block that vanishes.

---

## 4. THE CENSUS — PREDICTED FIRST, THEN MEASURED

`census48.py` walks the **uhdmtopModules region** of both whole-design dumps and
collects every `gen_scope_array` DECLARATION's `vpiFullName` and span (a
`gen_scope_array` printed as a `vpiParent` back-reference carries no `vpiName:`
line and is skipped). It then reports, for every OURS-ONLY path, whether
deleting **exactly one** component yields a GOLDEN path — the brief's question
made into an instrument.

It was run on the **pristine** pair first and the prediction written from that
artifact is committed verbatim as `CENSUS_PREDICT.txt`.

**MEASUREMENT ERROR, FOUND AND FIXED BEFORE IT COUNTED.** The first pristine
census was run against an `o.dump` that `uhdm-dump` was **still writing**
(222 MB of the final 240 MB; `wc -l` read 4 199 404 where the finished file has
4 655 864). The census was re-run on the completed file and the output is
**byte-identical** (`diff` empty) — the truncation had fallen inside the
trailing typespec section, after the whole `uhdmtopModules` region — but the
first reading was not entitled to be believed and is recorded here rather than
quietly dropped. `census48_pristine.txt` is the re-run.

### 4.1 The prediction (from the ARTIFACT, before the patched binary ran)

| population | cells |
|---|---|
| `work@prim_present.gen_round[i].gen_enc` levels to delete | 31 |
| `…gen_enc.gen_d64` → `…gen_d64`, re-parented + re-spanned | 31 |
| `…gen_enc.gen_k128` sub-trees to drop entirely | 31 |
| **any other module of the design** | **0** |

Predicted result: `GOLDEN-ONLY 0, OURS-ONLY 0, shared 5182, span
disagreements 0`. Predicted **non**-movers, named so a move would be a failed
prediction: the 5151 shared elab gen paths of every other module, the whole DEF
view, the genscope canaries by name, and jeras_tcb_gpio's interface collapse.
Predicted line arithmetic: **NEGATIVE** (this pass deletes).

### 4.2 The measurement (`census48_patched.txt`)

| census row | pristine | patched |
|---|---|---|
| golden elab `gen_scope_array` fullnames | 5182 | 5182 |
| ours elab `gen_scope_array` fullnames | 5244 | **5182** |
| shared | 5151 | **5182** |
| GOLDEN-ONLY | 31 (`gen_round[i].gen_d64`) | **0** |
| OURS-ONLY explained by ONE dropped level | 62 (all `gen_enc`) | **0** |
| OURS-ONLY not so explained | 31 (`…gen_enc.gen_k128`) | **0** |
| shared paths with a different span | 0 | **0** |
| `present_update_key128` in the elab region, golden / ours | 0 / 93 | 0 / **0** |

**Predicted exactly, measured exactly, nothing in the other direction.**

**THE CENSUS COVERED Earlgrey_0_1 ONLY, AND IT MISSED ONE.** `census48.py` was
run on the target design and on nothing else, so its prediction is a prediction
about Earlgrey and the README says so. The two CORPORA were not censused in
advance, and the byte verifier found a corpus cell the prediction never
mentioned: `IfGen3`, in both modes (§5.3.1). It moves TOWARD golden and its
shape is a3 `v7`'s exact row, but it was found by a gate rather than predicted
by an instrument, and that is a gap in this pass's method, not a success of it.
A corpus-wide census — the same script pointed at every `slang.uhdm` a sweep
produces — is the obvious next instrument and it does not exist yet.

### 4.3 Isolation, per top module (the strongest non-mover statement available)

The elaborated region is ten `|uhdmtopModules:` blocks. Comparing them line for
line, pristine against patched:

```
  work@prim_sync_reqack        970 ->     970   IDENTICAL
  work@prim_keccak            8305 ->    8305   IDENTICAL
  work@prim_present          12188 ->    8840   *** DIFFERS ***   (= -3348, the whole NET)
  work@prim_prince            3960 ->    3960   IDENTICAL
  work@prim_gate_gen          1884 ->    1884   IDENTICAL
  work@tlul_assert_multiple    812 ->     812   IDENTICAL
  work@sram2tlul               863 ->     863   IDENTICAL
  work@jtag_mux               6175 ->    6175   IDENTICAL
  work@padring               58219 ->   58219   IDENTICAL
  work@top_earlgrey        3366051 -> 3366051   IDENTICAL
```

and the **DEF view** — everything before the first `|uhdmtopModules:`, 1 196 437
lines including all 190 `uhdmallModules` blocks — is **byte-identical** (`cmp`
silent). § genChainBranchScopeThreads38's `emitDefGenStmts` is a different
function and this pass proves by bytes that it was not reached.

Golden's own `work@prim_present` elaborated block is **8840 lines**; ours is now
**8840 lines**, and the unified-diff content between them fell from **9858** to
**558** lines (§6 R3).

### 4.4 The line arithmetic, independently

`shapes48.sh` (multiset, ADDED and REMOVED separately, never a diff alignment):

```
ADDED shapes=791 instances=2604   REMOVED shapes=1686 instances=5952   NET=-3348
a lines=4655864  b lines=4652516
```

Every ADDED/REMOVED shape belongs to `prim_present` or to the
`prim_cipher_pkg::` objects its assigns reference: the only `work@` prefix
appearing anywhere in the 2477 moved shapes is `work@prim_present`, the only
`::` prefix is `prim_cipher_pkg::`, and the only `line:` numbers are
prim_present.sv's 52/91/93/94/95/96/97/107/108 and prim_cipher_pkg.sv's
141/172/231/232/336/354.

`msdist.sh` against golden: **306 492 → 301 038**, i.e. **−5454**. (The pristine
figure reproduces r10earl47's published post-pass distance exactly.) The
distance to golden went DOWN by more than the number of lines this pass
deleted, because the surviving lines were re-named onto golden's spelling.

`slang.uhdm`: 49 939 877 → **49 887 749** bytes (**−52 128**), md5
`09b53b21d06dbd0d18127237992f87ce` → `fa1540060d27b1af8784b77ee95b459b`.

---

## 5. THE FIVE GATES

Every gate was run on the FINAL binary, md5
`e99e73e91ad94071fa61639f222c8054`. No source was edited after the gates began.

| gate | result |
|---|---|
| **1 BUILD** | `/tmp/r10earl48/bld48.sh <worktree>`, ABSOLUTE paths, `-j 2`; `[100%] Linking CXX executable slang-uhdm`; **0** lines matching ` error:`; md5 asserted SEPARATELY afterwards, 32 hex; binary mtime `10:14:14` vs `ModuleEmit.cpp` `10:11:23` — no gate stands on a stale binary. BASE printed and grep-checked on BOTH trees: `a6e4932dec…` |
| **2 GOLDENS** | `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| **3 u2r** | §5.1 |
| **4 surelog both modes** | §5.2 |
| **5 BYTE VERIFIER** | §5.3 |

`GOLDEN_DEFER` was left UNSET throughout (`sweeps48.sh` unsets it explicitly so
an inherited value cannot leak in). `verify_golden.py` SILENTLY DEFAULTS
`SLANG_UHDM`, so every sweep EXPORTED it and the binary each sweep ACTUALLY
invoked was read back out of that sweep's own `cmds.txt` with the r10earl47
fix (`grep -oE '/[^ ]*/build/slang-uhdm'`, not the golden-cache path).

### 5.1 GATE 3 — the uhdm2rtlil corpus, both modes, both binaries

```
uhdm2rtlil default   pat : 679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
uhdm2rtlil testflags pat : 679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
uhdm2rtlil default   pris: 679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
uhdm2rtlil testflags pris: 679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
```

`ct8rows.sh results/gate_uhdm2rtlil.csv <fresh testflags csv>` (the committed
authoritative baseline is READ ONLY and carries 731 testflags rows, which is
why the fresh side is the testflags CSV and not a concatenation):

```
baseline: 732 lines = 731 ROWS      fresh: 732 lines = 731 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  testflags  base :  52 blank / 183 differ / 496 match
  testflags  fresh:  52 blank / 183 differ / 496 match
PASS: every row byte-identical to the committed baseline
```

The PRISTINE sweep was checked against the same committed baseline as a
control: **0 differing rows**. The sorted patched/pristine CSVs `diff` **EMPTY
in both modes**.

### 5.2 GATE 4 — the surelog corpus, both modes

```
baseline: 1589 lines = 1588 ROWS      fresh: 1589 lines = 1588 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  default    469 CMP_EQUAL   11 CMP_NOTEQUAL   5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
  testflags  465 CMP_EQUAL    8 CMP_NOTEQUAL   5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
             3 NO_DATABASE  1 NO_UHDM  1 TIMEOUT  2 UNTRANSLATABLE
---- DUMP-column histogram, base -> fresh, IDENTICAL in both modes
  default    325 blank / 244 differ / 225 match
  testflags  329 blank / 300 differ / 165 match
PASS: every row byte-identical to the committed baseline
```

`469/11` and `465/8`, `FAIL 25/23`, `DEFER 5/5`, every histogram unchanged, and
the sorted patched/pristine CSVs `diff` EMPTY in both modes.

### 5.3 GATE 5 — the byte verifier, both corpora, both modes

`SELFCHECK=1 SELFCHECK1=1 byteverify48.sh <pat root> <pris root>`, one workdir
ROOT per (corpus, binary) with BOTH modes inside it:

```
uhdm2rtlil   PATH_SETS_IDENTICAL (1358 paths)     MOVERS: 0 / 1358
  SELFCHECK  1357 / 1358 flagged        SELFCHECK1  1  (= 0 real + 1 corrupted)

surelog      PATH_SETS_IDENTICAL (953 paths)      MOVERS: 4 / 953
  MOVER ./default/Earlgrey_0_1-71da2fd7   patched=fa1540060d27  pristine=09b53b21d06d
  MOVER ./default/IfGen3-98ee3f07         patched=f7252eab60f1  pristine=2315deb2acf7
  MOVER ./testflags/IfGen3-98ee3f07       patched=8f5e37c7a1d7  pristine=48765b7e1295
  MOVER ./default/Scoreboard-59431470     patched=307fdd7029de  pristine=51045a62d0e4
  SELFCHECK   952 / 953 flagged          SELFCHECK1  5  (= 4 real + 1 corrupted)
```

Both negative controls behave exactly as specified.

#### The MOVER RULE applied to all four, one at a time

| mover | size delta | verdict |
|---|---|---|
| `Earlgrey_0_1` default | **−52 128 B** (49 939 877 → 49 887 749) | **REAL by size.** The target. §4. |
| `IfGen3` default | **0 B** | **REAL, and ZERO PROVED NOTHING — the rule's own case.** §5.3.1 |
| `IfGen3` testflags | **0 B** | **REAL.** §5.3.1 |
| `Scoreboard` default | **0 B** | **NOT REAL: multi-stability, PROVED by running the SAME binary repeatedly.** §5.3.2 |

The verifier's Earlgrey database is **byte-identical to the standalone
`earl48.sh` run** (`fa1540060d27b1af8784b77ee95b459b` on both sides of the
comparison, and `09b53b21d06dbd0d18127237992f87ce` for the pristine one, which
is also the database r10earl47 shipped) — Earlgrey is BYTE-DETERMINISTIC under
both binaries, so every Earlgrey number in §4 was produced by the bytes the gate
measured.

#### 5.3.1 IfGen3 — a REAL mover with a ZERO size delta, and it moves TOWARD golden

`Surelog/tests/IfGenenerate/test3/dut3.sv`:

```systemverilog
  if (level == NUM_LEVELS-1) begin : g_last_level
  end else begin                       // <- UNNAMED plain-else arm
    if (1) begin : all_true            // <- FIRST item, a NAMED if-generate
      localparam int POWER = 2**level; //    its first member
      for (genvar l = 0; l < 2**level; l++) begin : g_level end
    end
  end
```

`level=4`, `NUM_LEVELS=$clog2(64)=6`, so the else arm is taken. The law promotes
`all_true` — which we already emitted at module level through `genHoists9` — and
re-spans it at its localparam. The elab gen PATHS are unchanged (17 shared, 0
either-only, before and after); the only difference is the span:

| | golden | pristine ours | patched ours |
|---|---|---|---|
| `work@lzc.all_true` span | **15:7-15:40** | 14:12-18:8 ✗ | **15:7-15:40** ✓ |

`14:12, endln:18:8` and `15:7, endln:15:40` happen to serialise to the SAME
NUMBER OF BYTES, which is exactly why the size delta is 0 and why the rule says
zero proves nothing. Two independent proofs that it is real anyway:

* **DETERMINISM.** Three solo runs of each binary on this test: pristine
  `2315deb2acf7` ×3, patched `f7252eab60f1` ×3. Both stable, stably different,
  and equal to the values the gate reported.
* **DIRECTION.** Multiset distance to its own mode's golden cache:
  default **77 → 35**, testflags **117 → 35**. Both DOWN. `a3 v7` is the arm
  row that predicted this exact shape (a promoted block whose first member is a
  localparam) and it was written before this mover was known.

The CSV row is `CMP_EQUAL / differ` on both sides, which is why gate 4 sees 0
rows: `BaseClass::Compare` does not read line numbers. The byte verifier is the
only instrument that could see this, and it did.

#### 5.3.2 Scoreboard — NOT this pass, and the proof is the SAME binary disagreeing with itself

The dump difference is 92 lines and it is a **REORDERING of the design-level
`vpiTaskFunc` list** (46 `svunit_pkg::` class methods moved as a block); no
generate object appears in it, and the size delta is 0. Run repeatedly, ALONE,
on this machine:

```
patched  binary, 3 runs : 307fdd7029de ×1 , 51045a62d0e4 ×2
pristine binary, 8 runs : 307fdd7029de ×2 , 51045a62d0e4 ×6
```

**Both binaries produce BOTH databases.** The brief's "Scoreboard multi-stable"
is not quoted here, it is re-measured: the value the sweep recorded for the
patched side is one the PRISTINE binary also produces, and vice versa. This
mover is the coin, not the law.

#### 5.3.3 Named-database canaries, checked BY NAME

`bynames.sh` reports `ABSENT-PRISTINE` / `NO-DATABASE` separately so a name with
no database can never read as a mover.

```
surelog : InterfaceModPort BlackParrotComplex YosysOldOr SVSwitch SimpleUVM
          SeqDriver BuildUVMPkg Scoreboard Earlgrey_0_1 IfGen3
          -> identical=14  moved=4 (the four above)  absent=0
u2r     : gen_test4 gen_test5 gen_test9 genvar_loop_decl_2 genvar_loop_decl_3
          paramod_genscope_child genscope_cells LocalParamInNestedForLoops
          int_types genblk_order jeras_tcb_gpio (+ InterfaceModPort / SVSwitch,
          surelog-only, reported NO-DATABASE rather than skipped)
          -> identical=26  moved=0  absent=0
```

**`genblk_order` and `jeras_tcb_gpio` are byte-identical** — the two corpus
tests whose shapes this law could plausibly have touched (§6 R5, §7 R-9), named
and checked rather than argued.

#### 5.3.4 Canary scripts

| check | result |
|---|---|
| `canaries.sh` vs committed u2r baseline | `ok=8 changed=0 absent=0`, 25 unknown-names (all surelog-only, expected) |
| `canaries.sh` vs committed surelog baseline | `ok=52 changed=0 absent=0`, 7 unknown-names (all u2r-only, expected) |
| `ctcan2.sh` u2r, baseline FIRST, `EXPECT_UNKNOWN=6` | `ok=1 changed=0 absent=0 unknown-patterns=6` → PASS |
| `ctcan2.sh` surelog, baseline FIRST, `EXPECT_UNKNOWN=1` | `ok=58 changed=0 absent=0 unknown-patterns=1` → PASS |
| `canaudit.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0` → PASS |

#### 5.3.5 THE BOUNDARY LAWS, PROVED INERT BY BYTES

`bndarms48.sh` re-runs **every `.sv` arm of all four boundary laws** with BOTH
binaries and compares the whole `o.dump` (not a cmp head, not a count):

```
  r10earl38repro/a1_chain  a2_fence  v1_outside          o.dump IDENTICAL   (§ genChainBranchScopeThreads38)
  r10earl45repro/a1_earl45 v45_expr v45_order w45v x45v y45v   IDENTICAL   (§ elabPatternFirstRowElemSize45)
  r10earl46repro/a1_earl46 b1_earl46 v46v_digits v46v_gaps     IDENTICAL   (§ genLpFoldSignedStructural46)
  r10earl47repro/a1_earl47 a2_earl47 a3_earl47 b1_earl47 v47v_prefixkinds  IDENTICAL   (§ genLpUseFoldParentScope47)
  BOUNDARY ARMS: identical=18 differing=0
```

The brief's specific worry — *"its distance law counts GENERATE scopes: if the
flatten changes scope paths, the genLpFoldByPath keys and the distance-1 test
must stay consistent (measure!)"* — is measured three ways and holds:

1. all five § 47 arms including `v47v_prefixkinds` are byte-identical;
2. `work@prim_keccak`'s whole elaborated block, which carries all **72** cells
   § 47 moved, is byte-identical (§4.3);
3. `prim_present`'s `gen_enc` declares **no** localparam, so no
   `genLpFoldByPath` key changes; the only paths this pass rewrites belong to
   `gen_d64`, whose own localparams do not exist either. The 93 constants that
   remain in `prim_present` (R3) are MODULE parameters, outside
   `genLpFoldByPath` by construction.

---

## 6. RANKED RESIDUES

Ranked by Earlgrey_0_1 cells first, then by how sharply the shape is
characterised. Every count is measured.

**R0 — THE NEXT HEAD, `sram2tlul.sv:15`, 66 lines.** Committed witness
`r6_nexthead48.cmp`. Golden folds the whole `[TlBaseAddr+32-1 : …]` range
expression to a bare `constant UINT:31`; we keep the `operation` with its two
folded operands (`UINT:32` + `UINT:1`, opType 11). A WHOLE-EXPRESSION range
fold, not a gen-scope question, and the row's next law. The head depth fell
644 → **66**.

**R1 — the VANISHING arm: 3 arm shapes, 0 Earlgrey cells.** When a plain-else
arm's first item has **no taken block** (a2 `u4`, `u5`) or its taken block is
**EMPTY** (a2 `u9`), golden emits **NOTHING AT ALL** for the arm — in `u5` that
loses `u5_c2` and its wire, which ARE elaborated. Deliberately not implemented:
it destroys design content and the census proves Earlgrey_0_1 has **zero** cells
of it (100 % of the OURS-ONLY population was prim_present). Five arm paths stand
because of this fence and they are the only ones a2 has left.

**R2 — the CASE-generate item span, 0 Earlgrey cells, 2 arm cells,
PRE-EXISTING.** a2 `u8_c` (golden 117:10-119:10, ours 118:9-118:17) and a3
`v6_c` (golden 74:10-76:10, ours 75:9-75:17): golden spans a taken case-item
`begin..end` block at the **block**, we span it at its first member. Identical
before and after this pass — the `underCase9` arm of `emitBlock` is older than
this law and was not touched.

**R3 — 93 prim_present module-parameter fold cells: right digits, wrong parent
AND wrong typespec name.** After this pass the ONLY remaining difference inside
`work@prim_present`'s elaborated block is 31×3 constants in the `round_key`
part-select ranges (`54:59`, `54:72`, `54:81`): golden parents each at the
enclosing `operation` and names its `ref_typespec`
`work@prim_present.gen_round[i].round_key.round_key`, while we parent at the
`param_assign` and name it `work@prim_present`. This is r10earl47's R3/R4
family — ParamEmit's MODULE-parameter fold carrier, not this law's — and it is
now the whole of the 558-line residual diff for that module.

**R4 — the unnamed-else / genHoists9 overlap is decided by ORDER, not by a
test.** `§ elseArmFirstItemReplaces48` is consulted BEFORE `genHoists9`, so an
UNNAMED plain-else arm whose first item is a named if-generate now takes the
new path (a2 `u2`/`u3`, both matching golden). An unnamed else arm whose first
item is NOT an if-generate still takes the old hoist. The two rules are not
unified and the unmeasured cell — an unnamed else arm with an unnamed first
child and a second child — has no arm row and no corpus cell.

**R5 — `collapseIfLeaf9` (the interface law) is left byte-for-byte alone and
now PARTIALLY OVERLAPS this one.** jeras_tcb_gpio's `bus.gen_dly` is a plain-
else arm whose first item is the named `gen_rsp`, so both rules would promote
`gen_rsp`; the interface rule runs first (at the module-level loop) and wins, so
the new law is INERT there — confirmed by gate 3's 0 rows. a2 `u11` shows the
case the interface rule CANNOT reach (two taken children) and the new law does.
Merging them is deferred: it would change an interface population that no head
currently sits on.

**R5b — `IfGen3` is the law's ONE corpus cell, and it is a WIN, not a residue.**
Both modes, byte-deterministic, distance to golden 77→35 and 117→35, span now
golden's exactly (§5.3.1). It is listed here because gates 3 and 4 CANNOT see
it — the CSV row is `CMP_EQUAL / differ` before and after — so a reader who
trusts only the row gates would never learn that this pass changed a corpus
database at all.

**R6 — `emitSurelogMisevalGenIf` / `genIfUnitMisevalFalse` are untouched.** The
new test runs on the block that reaches `pushGenBlk9`, i.e. AFTER the miseval
re-decision has picked an arm, so a re-decided arm is collapsed by the same rule
as a normally decided one. No arm measures that combination and Earlgrey has no
cell of it.

---

## 7. REFUTATIONS, STATED PLAINLY

**R-1. The brief's census expectation — "likely many across prim_* IPs" —
is REFUTED.** The whole design-wide population is `work@prim_present`, 31
iterations, and **no other module**. `prim_keccak`, `prim_prince`,
`prim_gate_gen`, `jtag_mux`, `padring`, `sram2tlul`, `tlul_assert_multiple`,
`prim_sync_reqack` and the entire `top_earlgrey` tree agree with golden on all
5151 shared gen paths and on every span, before the patch as well as after.

**R-2. "Naming-only" is REFUTED.** Golden has no `gen_enc` object; `gen_d64`'s
`vpiParent` is `gen_round[i]`'s `gen_scope`; the span changes; and `gen_k128`'s
entire `cont_assign` sub-tree is absent. `present_update_key128` occurs 0 times
in golden's elaborated region. A rename would have left all three intact.

**R-3. "Unnamed-else arms are what flatten" — REFUTED.** `gen_enc` is NAMED and
it flattens; a1 `t_e5` and a2 `u2`/`u3` show unnamed ones flatten too, so the
name of the ARM is not the discriminator at all. What must be named is the
PROMOTED CHILD (a2 `u1`: an unnamed child keeps the whole level).

**R-4. "Directly-inside-a-for-generate" — REFUTED.** a1 `t_e1`/`t_e2`, a2
`u10`/`u11` and a3 `v2`/`v4`/`v5`/`v7` all collapse at MODULE scope, inside an
INTERFACE, and under an ELSE-IF arm. a1 `t_l` shows the for-generate case is
just one more instance, not the condition.

**R-5. "Single-branch (no else) if-generates flatten" — REFUTED.** `gen_enc`'s
own if HAS a taken sibling (`gen_dec`), and a1 `t_then`, a2 `u6`/`u7`/`u8` and
a3 `v1`/`v3`/`v6` are single-branch shapes that do NOT flatten. The presence or
absence of an else on the OUTER if is not read by the law at all.

**R-6. "An else arm with only generate content collapses" — REFUTED by a3, and
it is the refutation that changed the code.** `v3` (for-generate first) and `v6`
(case-generate first) have NO non-generate content and golden keeps the level;
`v5` HAS non-generate content and golden collapses and drops it. The gate is the
FIRST ITEM's kind, not the block's content — §1.2.

**R-7. "Empty gen scopes vanish" — REFUTED by a3 `v1`.** A standalone empty
named if-generate block gets an empty `gen_scope` in golden. Only a PROMOTED
empty block vanishes (a2 `u9`), which is why R1 is fenced as a property of the
promotion and not of emptiness.

**R-8. The first census reading was not entitled to be believed.** It was taken
from a dump `uhdm-dump` had not finished writing. Re-running it on the complete
file reproduced it byte for byte, but the re-run is what §4 quotes. A census on
a partial artifact is exactly the shape of mistake that produces a confident
wrong prediction.

**R-8b. My own prediction was INCOMPLETE, and a gate caught it.** The census is
Earlgrey-only; `IfGen3` moved in both surelog modes and appears nowhere in
`CENSUS_PREDICT.txt`. It moves toward golden on both goldens (77→35, 117→35) and
matches golden's span exactly, so it is a win — but it was an UNPREDICTED win,
and an unpredicted mover is indistinguishable from an unpredicted regression
until it is opened. §4.2 states the gap rather than folding the mover into the
prediction after the fact.

**R-9. Nothing here says `collapseIfLeaf9`, `genHoists9`, the `underCase9` span
rule or `emitDefGenStmts` are right.** All four are left byte-for-byte alone.
The new test is the FIRST statement of `pushGenBlk9` and returns `nullptr` for
every shape it does not recognise, so no existing path can be overridden by it
except the one measured overlap (R4, R5).

---

## 8. REPRODUCING

```sh
# pristine + patched worktrees at a6e4932, both built -j 2
/tmp/r10earl48/bld48.sh /tmp/wt_r10earl48pris
/tmp/r10earl48/bld48.sh /tmp/wt_r10earl48

# the head, before and after
SLANG_UHDM=/tmp/wt_r10earl48pris/build/slang-uhdm ./earl48.sh /tmp/r10earl48/wd_pris
SLANG_UHDM=/tmp/wt_r10earl48/build/slang-uhdm     ./earl48.sh /tmp/r10earl48/wd_pat

# the grid (LHS always golden), per arm
SLANG_UHDM=<bin> ./arm48.sh a1_earl48.sv /tmp/r10earl48/arm_a1
python3 grid48.py /tmp/r10earl48/arm_a1/g.dump /tmp/r10earl48/arm_a1/o.dump

# the census, both sides, design-wide (ELAB region only)
uhdm-dump <golden.uhdm> | sed 1d > g.dump
python3 census48.py g.dump /tmp/r10earl48/wd_pris/o.dump   # pristine
python3 census48.py g.dump /tmp/r10earl48/wd_pat/o.dump    # patched

# movers, per shape, by MULTISET, ADDED and REMOVED separately
./shapes48.sh /tmp/r10earl48/wd_pris/o.dump /tmp/r10earl48/wd_pat/o.dump
./msdist.sh   g.dump /tmp/r10earl48/wd_pat/o.dump
```

`README.verifier.md` is the VERIFIER's to author and is deliberately absent
here.
