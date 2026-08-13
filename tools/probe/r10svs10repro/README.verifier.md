# r10svs10 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PASS.** Every load-bearing number in the implementer's report
reproduces on binaries I built myself from fresh 2ee7a58 worktrees, and both of
my binaries are **byte-identical** (md5) to the ones they reported. The
conversion claim is honest — I re-ran both modes and quote the rows. The five
gates are green under the **UNCONVERTED** expectation, which is the right one.

I found **no defect**. I record **five findings (F1–F5)**, all documentation /
measurement-precision, none of which changes behaviour or any gate; and **four
new results (N1–N4)** from checks the implementer did not run, one of which
(N1) supplies a *stronger* proof of their most contestable claim than the one
they offered.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours, in every table here.

| | |
| --- | --- |
| Base | `2ee7a58` — **still HEAD**; no landing intervened (`git rev-parse HEAD` = `2ee7a58e8ba…`) |
| Worktrees | `/tmp/wt_vsvs10` (patched), `/tmp/wt_vsvs10pris` (pristine control) — both created detached at 2ee7a58 by me |
| Patch | `/tmp/r10svs10.patch`, md5 **`2bd90cd69c4ad6459be585251f48234a`** = delivered md5; 2009 lines; `git apply --check` clean |
| Shipped binary | md5 **`0d674d37edf10aa6178b5163e7f9518f`** = reported |
| Pristine binary | md5 **`875d3cd6218c135a8fcc6da3c4c3cf19`** = reported |

---

## 1. THE CONVERSION CLAIM — RE-RUN, NOT TAKEN ON TRUST

**I am in the UNCONVERTED world.** I ran the harness myself on my own binary:

```
SLANG_UHDM=/tmp/wt_vsvs10/build/slang-uhdm python3 scripts/verify_golden.py \
  --corpus surelog --mode both --filter '^SVSwitch$' --jobs 2 \
  --out /tmp/vsvs10_svswitch.csv --workdir /tmp/vsvs10_wd_svs

SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

Both rows are **byte-identical** to the committed authoritative baseline, which
I read and never wrote (`results/golden_surelog.csv:1304-1305`):

```
1304:SVSwitch,default,CMP_NOTEQUAL,decompile:,,
1305:SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

**Dump column value: EMPTY (blank) in both rows** — each row ends `decompile:,,`
with nothing after the last comma. `git status --porcelain results/` is empty in
both the main tree and my worktree: **no `results/*.csv` was touched.**

SVSwitch instruments, my measurement (`svsgen.sh`, both modes, identical):

| instrument | pristine `875d3cd6` | shipped `0d674d37` | reported |
| --- | --- | --- | --- |
| row, both modes | CMP_NOTEQUAL | CMP_NOTEQUAL | ✓ not a conversion |
| cmp HEAD DEPTH (a SUBTREE, not a distance) | 17 | 2680 | ✓ |
| cmp heads (`grep -c ^LHS:`) | 1 | 1 | ✓ ONE head |
| dump content `+/-` | 1918 | 1912 | ✓ |
| MULTISET distance to golden | 1368 | 1354 | ✓ |
| o.dump lines (golden 25318) | 25698 | 25720 | ✓ |
| both modes identical | yes | yes | ✓ |

**The brief's 17-line head IS CLEARED.** The pristine head is exactly the
brief's target; the shipped head is a different, larger subtree:

```
PRISTINE head (17)   LHS ref_typespec: (work@testcase.env), id:3791
                         \_logic_net: (work@testcase.env) 20:13-20:16
                         \_class_typespec: (Environment) 20:1-20:12
                     RHS: <null>
SHIPPED head (2680)  LHS module_inst: work@top … RHS module_inst: work@top
```

Our new emission is **verbatim golden's shape** — I read it out of the raw
dumps rather than trusting the summary:

```
+    |vpiTypespec:
+    \_ref_typespec: (work@testcase.env)
+      |vpiParent:
+      \_logic_net: (work@testcase.env), line:20:13, endln:20:16
+      |vpiFullName:work@testcase.env
+      |vpiActual:
+      \_class_typespec: (Environment), line:20:1, endln:20:12
```

### 1.1 Head depth 17 → 2680 is NOT a regression — independently proven

I did not accept "head is a subtree" as an argument. Three checks:

1. **Our own delta is 22 lines and is PURE ADDITION.**
   `diff -u pristine.o.dump shipped.o.dump` → 22 content lines, **every one a
   `+`**; the `-` set is empty. No object anywhere was removed or altered.
2. **The delta is not inside `work@top`.** Both hunks land in
   `program: work@testcase` (@7031) and the design-level typespec pool (@25606).
   The `work@top` subtree the new head roots at is untouched.
3. **The new head does not mention the new objects at all.**
   `grep -cE 'testcase\.(env|spkt)'` over the 2680-line head = **0**.

The successor head is therefore **pre-existing and merely unmasked** by
Compare's `m_visited` short-circuit moving past the cleared head. Confirmed.

---

## 2. THE FIVE GATES, INDEPENDENTLY

### GATE 1 — BUILD ✅
Configured and built both worktrees myself; **waited for the link line** in each
(`[100%] Linking CXX executable slang-uhdm`), `BUILD_RC=0`, **0 errors**.
md5 asserted **separately** from the build, 32-hex checked, and **both match the
reported values exactly** — a stronger result than agreement, since the build is
reproducible bit-for-bit.

BASE printed and grep-checked for **every** binary:
`git rev-parse HEAD` = `2ee7a58e8ba…` in both worktrees; `git status --porcelain`
**empty** in the pristine one, and exactly `M src/ModuleEmit.cpp` +
`?? tools/probe/r10svs10repro/` in the patched one.

The implementer is right that a **deletion adds no symbol**, so a `strings` grep
would be a guard that does not guard. My base markers are behavioural + source:

| marker | shipped | pristine |
| --- | --- | --- |
| `grep -c classHandle src/ModuleEmit.cpp` | **1** (the law name in a comment) | **6** |
| arm `c1` cell `work@msub.b1` | `TS(K)` | `NONE` |

**STATED GATE == CODE GATE.** The report's quoted gate is character-for-character
what is in my built tree at `src/ModuleEmit.cpp:950`:
```cpp
if (!it.port && !explicitPortNet && !implicitNet &&
    !namedTypeNet && !typeParamArgNet && !hasBareImplicitType(*it.sym)) {
```

### GATE 2 — GOLDENS ✅
`SLANG_UHDM=…/wt_vsvs10/build/slang-uhdm bash tests/check_goldens.sh` → **23 PASS
/ 0 FAIL**. Negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL**.
`GOLDEN_DEFER` printed and **UNSET**.

### GATE 3 — u2r ✅
`--corpus uhdm2rtlil --mode testflags --jobs 2`, my own `--out`/`--workdir`:

```
CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
dump histogram: 496 match  183 differ  52 (blank)
ct8rows vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
```
**Pristine control: 0 rows** — the environment is not drifting.

### GATE 4 — surelog, BOTH modes ✅ (UNCONVERTED expectation — the right one)

```
default   : CMP_EQUAL 467   CMP_NOTEQUAL 13
testflags : CMP_EQUAL 463   CMP_NOTEQUAL 10
ct8rows vs results/golden_surelog.csv: 0 differing ROWS (0 diff row-sides)
```

`467/13 + 463/10` is the brief's **UNCONVERTED** figure exactly, and is **not**
the conversion figure (`468/12 + 464/9`). **Histograms unchanged in both the
STATUS and the DUMP column, both modes** (dump: default 225/242/327, testflags
165/298/331, base == fresh). **Pristine control: 0 rows.**

**Named canaries, BY NAME, first:**
```
InterfaceModPort   default/testflags  CMP_EQUAL,,,differ   baseline == fresh
BlackParrotComplex default/testflags  CMP_EQUAL,,,differ   baseline == fresh
```
`canaries.sh`: surelog `ok=52 changed=0 absent=0`, u2r `ok=8 changed=0 absent=0`.
`ctcan2.sh`: surelog `EXPECT_UNKNOWN=1` → `ok=58 changed=0 unknown=1` PASS; u2r
`EXPECT_UNKNOWN=6` → `changed=0 unknown=6` PASS. `canaudit.sh`:
**audited=29 UNCOVERED=0 FENCE-BREACH=0**, and the four slang-fenced names
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched by
no driver — I never dispatched them either.

### GATE 5 — BYTE VERIFIER, both corpora, both modes ✅

```
u2r     : PATH_SETS_IDENTICAL (679)  MOVERS: 0 / 679
          SELFCHECK 678/679   SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953)  MOVERS: 5 / 953
          SELFCHECK 952/953   SELFCHECK1 = 6
```
All four control numbers match the report. The 5 flagged paths are the reported
ones: `Scoreboard/default`, `SimpleUVM` ×2 modes, `SVSwitch` ×2 modes.

**MOVERS: 4 real, per-shape vs GOLDEN by MULTISET, ADDED/REMOVED separately.**

| database | distance to golden | ADDED object shapes | REMOVED |
| --- | --- | --- | --- |
| SVSwitch (both modes) | 1368 → **1354** | 10, **all ON-GOLDEN exactly** | **none** |
| SimpleUVM (both modes) | 144521 → **144512** | 5, **all ON-GOLDEN exactly** | **none** |

I verified "lands on GOLDEN's own count exactly" per shape rather than accepting
it — for each moved shape I printed `GOLD / PRIS / SHIP`. Every `\_`-marked
object shape lands. SimpleUVM's carrier is `testbench.sv:47 env environment;`,
a carrier the brief did not name; the implementer names it correctly.

---

## 3. N1 — Scoreboard/default: FALSE MOVER, with a STRONGER proof than reported

This was the most contestable claim in the report, so I re-derived it. 3-rep on
each binary, plus 4 extra pristine reps:

| | observed md5s (12-char) | size |
| --- | --- | --- |
| shipped | `1df12766ef22`, `c64f2fe81fec`, `7cfa3a567877` | 11133439 (all) |
| pristine | `4da8d507fa65`, `1df12766ef22`, `7cfa3a567877` | 11133439 (all) |

* **≥3 distinct hashes per binary** — matches the KNOWN FLAKE profile.
* **ONE size on every one of the 10+ observations** — the prescribed size-delta
  discriminator says false mover. (Contrast r10svs9, where this row was real and
  carried a −237-byte delta.)
* **The hash sets INTERSECT**, and the intersection contains the decisive
  witness: **`1df12766ef22` — the hash `byteverify.sh` attributed to the PATCHED
  side — is produced by the PRISTINE binary** (rep 4). That is direct proof the
  flagged difference is run-to-run noise, not the patch.
* **MULTISET distance 0 across binaries** (ship rep1 vs pris rep7, different
  md5s) **and 0 within the pristine binary alone** (pris rep4 vs rep7, different
  md5s) — 1095679 lines each side, `golden-only 0 / ours-only 0`.

**N1 is a correction in the implementer's favour on substance and against them on
detail:** their specific witness sentence, "`c64f2fe8` produced by both", did
**not** reproduce for me — I observed `c64f2fe8` on the shipped binary only. The
*structural* claim is nonetheless confirmed, by a different and better witness.
Recorded as **F1** below.

---

## 4. FINDINGS (F1–F5) — none blocking, none behavioural

**F1 — the Scoreboard witness hash does not reproduce.** Report: "the hash sets
intersect (`c64f2fe8` produced by both)". In 7 of my runs `c64f2fe8` appeared on
the shipped binary only; the intersection witness is `1df12766ef22` /
`7cfa3a567877`. The *conclusion* (false mover) is confirmed and in fact
strengthened — see N1. A per-run hash is not a stable citation and should not be
quoted as one; the size-invariance and the multiset-0 result are the durable
evidence.
`for rep in 1..7; verify_golden.py --filter '^Scoreboard$' --mode default; md5sum; stat -c %s`

**F2 — "GRID — 122 cells, 4 arms" is 122 cells across THREE arms.** My totals:
c0=10, c1=23, c2=42, c3=57 → **132**. The reported 122 = c1+c2+c3, and
EQ 86→105 likewise excludes c0's 10 (which are 10 EQ on both binaries). c0 is
reported separately and correctly as `DUMP_MATCH`. **The DIFF figure 36 → 17 is
exact and unaffected**, and that is where all the evidence lives.
`python3 ctsread.py <arm>/g.dump <arm>/o.dump --all | tail -1`

**F3 — 15 of the 122 grid cells are Surelog builtin-library artifacts, and one is
a true EMPTY PRODUCT CELL.** Five cells per arm × 3 arms come from `builtin.sv`
and the arm's own constructor argument, not from any declared arm signal:
`work@mailbox::new`, `work@semaphore::new`, `work@process::self`, `work@K::new`,
and `work@mailbox::try_put`. The last has span `-` and value `NONE` on **both**
sides — it can never move and proves nothing. The honest arm-cell count is
**107**, and the EQ figures carry 15 free EQs. **All 15 are EQ on both binaries,
so DIFF 36→17 and "not one cell regressed" are untouched.**
`grep -cE 'work@(mailbox|semaphore|process|K)::' /tmp/vs_c<n>_s.txt`

**F4 — "34 insertions are the comment" is 36.** `git diff --numstat` gives
37 insertions / 35 deletions; `grep -c '^+ *//'` gives **36** comment
insertions, leaving exactly **1** non-comment insertion (the reflowed `if`
line). The substance — the change is one clause deletion plus a comment — is
right; the arithmetic is off by two.

**F5 — an r10svs9 arm is dead, and the report does not say so.** `v1_ctxclock.sv`
is `SURELOG_FAIL` (10 syntax errors) on **both** binaries, so it measures
nothing. It is r10svs9's arm, not this pass's, and it is identical on both
sides — no regression — but anyone re-running the r10svs9 arm set as a
non-regression check should know one of them is vacuous.
`SLANG_UHDM=… bash r10svs9repro/svs9arm.sh v1_ctxclock.sv`

### Ops note (reported by the implementer, confirmed harmless here)
They clobbered `/tmp/pris_build.log`, a name r10uvm63 was also using, then
renamed to `r10svs10_*`. I verified `/tmp/wt_r10uvm63` is intact and its diff
scope is unchanged (`include/UhdmExporter.h`, `src/ParamEmit.cpp`,
`src/TypeEmit.cpp`, `src/UhdmExporter.cpp`). Self-reporting this was correct.

---

## 5. PATCH HYGIENE, BOUNDARIES, LIVE PASSES

**Hygiene ✅.** `git apply --stat`: `src/ModuleEmit.cpp` + 17 files under
`tools/probe/r10svs10repro/`, **nothing else**. `git diff --name-only 2ee7a58`
in my patched worktree returns exactly `src/ModuleEmit.cpp`; there are no
untracked files outside the probe dir; **no `results/*.csv` in the patch.**

**§ classPropNoStampShared50 — UNDISTURBED ✅.** It lives in
`src/UhdmExporter.cpp`, which **the patch does not touch at all** (the only
production file changed is `ModuleEmit.cpp`); I diffed the region and it is
identical to pristine. I did not stop at file-level disjointness, because the
real risk is the *new* net path re-parenting a shared typespec — the exact
failure § classPropNoStampShared50 guards. Three checks:

* The new code pushes to `pendingNetTs`, **not** `pendingClassPropTs`.
* In `materializeDefNetTs` the only `VpiParent`-on-typespec branch is gated
  `pn.rt->VpiParent()->UhdmType() == uhdmport`. Our new ref_typespecs have
  `vpiParent = logic_net` (verified in the dump), so **that branch cannot fire**.
* **Direct pointer-identity evidence:** our emitted `class_typespec (Environment)`
  carries **no `vpiParent`**, rendering byte-identical to golden's. Had we
  re-parented a shared object, the object-shape counts would have broken — instead
  all 10 land exactly, and `|vpiParent:` moved **toward** golden (954→956/960).

**r10svs9 arms HOLD ✅.** Its landed law (§ parensLessEventPathBaseRef9) does not
regress: `a2_base` 2512/52 and `a4_spine` 58/88 are **identical** on both
binaries, `v3_esc` 60 identical. `a1_parens` **improved** (content 20→9). The
seed spec `b5_newassign` is the target: `heads=1 depth 17, content 57` →
**`heads=0, content 24`**. Its b1–b4 refutations stand; I re-derived none of them.

**Live passes — NO COLLISION ✅.** Base is still 2ee7a58; neither has landed.
Production-file sets are **disjoint**: r10svs10 `src/ModuleEmit.cpp`; r10earl34
`src/ExprEmit.cpp`; r10uvm63 `include/UhdmExporter.h`, `src/ParamEmit.cpp`,
`src/TypeEmit.cpp`, `src/UhdmExporter.cpp`. **Rebase note for the master:**
r10uvm63 edits `UhdmExporter.cpp`, which owns the `pendingNetTs` drain that our
new ref_typespecs now flow through. There is no textual conflict, but whichever
lands second should re-run the SVSwitch + SimpleUVM mover check.

---

## 6. THE LAW — verified, including its refutations

`§ classHandleWriteKeepsTs10` deletes a 33-line predicate. **The brief's stated
law-shape ("ours drops the ref_typespec exactly when the variable is ASSIGNED")
is REFUTED, and I confirm the refutation cell-for-cell**, on my binaries:

* **c1 — scope kind and top-ness both REFUTED.** Golden keeps the link in **all
  ten** design-scope cells — top module, non-top module, top program, non-top
  program, interface — **assigned and unassigned alike**. DIFF 4 → **0**.
* **c2 — the decisive arm; the discriminator is the HEADER FORM.** Golden's
  answers, with assignment varied *within* each header form so it cannot hide
  behind the confound:

  | header form | ASSIGNED | never assigned | golden |
  | --- | --- | --- | --- |
  | `module f_none;` | f1 | f2 | **TS(K) / TS(K)** |
  | `module g_empty();` | g1 | g2 | NONE / NONE |
  | `module h_nonansi(a);` (OneThis's shape) | h1 | h2 | **NONE / NONE** |
  | `module i_ansi(input logic a);` | i1 | i2 | **TS(K) / TS(K)** |

  Golden answers **identically for the assigned and the unassigned handle in
  every single header form**. Assignment does no work anywhere. The rule that
  does the work — `namedTypeNet` — already sat three lines below the strip.
* **The strip was incoherent on its own terms — I reproduced this directly.**
  On the PRISTINE binary, arm c3 `m_forms`: `n1` (assigned in `initial`) and
  `n2` (in `always`) were stripped → DIFF, while **`n3` (assigned in a TASK) and
  `n4` (in a FUNCTION) kept their typespec → EQ**, because the visitor scanned
  only `ProceduralBlock` members. Golden gives `TS(K)` to all of n1–n8. The
  split was an artifact of the traversal, not a rule.
* **The ScopedName carve-out was dead weight — confirmed.** c2 `j1`/`j2`
  (`pk::SK`) are `TS(pk::SK)` on both sides with no clause of their own: a
  `ScopedName` is not an `IdentifierName`, so `namedTypeNet` declines and the
  net is typed like any other. Its siblings `j3`/`j4` (typedef'd `K_t`, a bare
  identifier) are `NONE` on both sides — the same rule, the other way.
* **c0 — the producer's own citation survives.** `c0_onethis.sv` is
  `DUMP_MATCH` on **both** binaries: OneThis is `module top(a, o); input a;`, a
  non-ANSI header, so `namedTypeNet` strips it with or without the deleted code.
  The comment it justified was justifying the wrong rule.

**"Not one cell regressed" — verified mechanically, not by eye.** Across c1/c2/c3
I diffed the pristine and shipped cell tables keyed by (scope, name, span, kind):
**0 cells went EQ → DIFF**, and the key sets are identical (0 pristine-only,
0 shipped-only). Every changed cell was DIFF in pristine.

---

## 7. RESIDUES, RANKED

**R1 — SVSwitch successor head, `work@top`, 2680 lines, both modes.**
Pre-existing and proven so (§1.1); it is now the head on this row and the next
target. Highest rank because it is the whole remaining SVSwitch distance.

**R2 — parameterized-class name span (4 cells, NEWLY VISIBLE).** Golden spans the
bare class name, we span the parameterization: `q2` golden `TS(P)@48:3-48:4` vs
ours `48:3-48:8` (`P#(2)`); `q7` golden `TS(P3_t)@19:9-19:10` vs ours
`19:9-19:14`. The object did not exist before this pass, so this is newly
visible, **not a regression** — the cell went `NONE` → present-with-wrong-span,
i.e. strictly closer to golden. I agree with the implementer that this is the
**highest-value new arm: UVM is built from parameterized classes**, so this shape
will recur at scale. It did not cost anything here (all 15 real mover shapes
landed on golden), but a corpus with parameterized class handles at design scope
would surface it as new DIFF content.

**R3 — interface-class handle (3 cells, NEWLY VISIBLE).** Golden emits
`unsupported_typespec`; we now emit `class_typespec (IC)`. Both differ from each
other; before the pass we emitted `NONE`. A divergence of *kind* rather than of
presence — worth a dedicated arm before this shape reaches a real database.

**R4 — declaration-initializer `class_typespec` span (`n9`, `k1`).**
**PRE-EXISTING**: byte-identical DIFF on both binaries. Golden's signal span
covers the initializer (`31:5-31:15`), ours stops at the name (`31:5-31:7`).

**R5 — escaped-identifier declarator span (`\esc.two`, 4 columns).**
**PRE-EXISTING**, identical on both binaries; this is r10svs9's R3, unchanged.

**R6 — bare-field absorber drift.** SVSwitch's ours-only line count rises +4
(`|vpiActual:` +2, `|vpiTypespec:` +2 at one indent level). I accounted for
**every unit**: golden-only −18 and ours-only +4 sum exactly to the −14 distance
gain, and all 4 are the arithmetically necessary shadow of adding 2
`ref_typespec` objects onto a **pre-existing** indent-level imbalance (golden
puts 402 `|vpiActual:` at indent 8, we put 381). Not introduced by this pass;
dump-only; no object shape is affected.

---

## 8. WHAT I DID NOT VERIFY

* I did not re-derive r10svs9's b1–b4 refutations (the brief forbids it).
* I did not run the implementer's `census.sh` to completion. Their own report
  says the surelog census did not finish and **its number must not be quoted** —
  I confirm the tool over-counts as they describe: `ctscensus.py` matches elab
  twins by **name tail** (`any(cn.split('.')[-1] == tail …)`), so any net named
  `env` matches any `class_var` named `env` anywhere, and it does not model
  `namedTypeNet`, so it counts non-ANSI-header nets that golden strips too. The
  self-criticism is accurate. **The byte verifier supersedes it**: it covers
  **every** database in both corpora (679 + 953) and found 4 real movers, so
  completeness does not depend on the census.

---

## 9. VERDICT

**PASS.** The head is cleared, the law is right, the refutations hold —
including the three the implementer turned against their own brief, producer, and
census, all of which I reproduced. No conversion is claimed and none occurred;
the gates are green under the UNCONVERTED expectation. No object shape regressed
in any database, no cell regressed in any arm, nothing was removed anywhere, and
the two databases that moved both moved onto golden's own counts exactly.

The five findings are precision defects in the write-up, not in the change. The
one I would ask the master to carry forward is **F1**: cite size-invariance and
multiset-0 for the Scoreboard flake, never a per-run hash.

**Deliverable stands:** `/tmp/r10svs10.patch`, md5
`2bd90cd69c4ad6459be585251f48234a`, clean at 2ee7a58.
