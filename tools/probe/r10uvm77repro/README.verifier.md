# r10uvm77 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PARTIAL — the law is RIGHT, the head is GENUINELY CLEARED on all
three rows, and every headline number reproduces bit-for-bit; but the shipped
probe carried TWO MEASURED OVER-FIRES on legal SystemVerilog, one of which is a
CLASS REGRESSION against a cell our own pristine binary got RIGHT. Both are
FIXED here, both fixes are strictly conservative, and the corpus output of the
re-cut is BYTE-IDENTICAL to the first cut. Deliverable:
`/tmp/r10uvm77.verified.patch`.**

Verifier worktrees `/tmp/wt_v77` (patched) and `/tmp/wt_v77pris` (pristine),
both `git rev-parse HEAD = 024b1b5221a060ac95510ce6dd6f806940840070`, pristine
porcelain EMPTY. LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

---

## 0. REPRODUCTION — what came back bit-for-bit

Applying `/tmp/r10uvm77.patch` (md5 `3ca8cb8cd079bb62ba9033e12a555a7e`,
`git apply --check` clean) to a fresh 024b1b5 and building `-j 2`:

| quantity | claimed | measured | |
|---|---|---|---|
| patched binary md5 | `ffa7d00fb5a07ab1c6fca7639b2719fe` | **identical** | ✓ |
| pristine binary md5 | `a72eeb765b73c70687aaa58f1f3cca89` | **identical** | ✓ |
| goldens patched / `/bin/false` | 23-0 / 0-23 | **23-0 / 0-23** | ✓ |
| u2r testflags | 679 / 50 / 2, dump 496/183/52 | **identical**, patched AND pristine | ✓ |
| u2r row gate | 0 rows | **0 ROWS, 0 row-sides** over 731 | ✓ |
| surelog default | 469 / 11 / 25 / 5 | **identical** | ✓ |
| surelog testflags | 465 / 8 / 23 / 5 | **identical** | ✓ |
| surelog row gate | 0 rows | **0 ROWS, 0 row-sides** over 1588, both builds | ✓ |
| surelog dump histograms | 225/244/325, 165/300/329 | **identical** | ✓ |
| byte verifier u2r | 0 / 679, SELFCHECK1 = 1 | **0 / 679, SELFCHECK1 = 1** | ✓ |
| byte verifier surelog | 7 / 953, SELFCHECK1 = 8 | **7 / 953, SELFCHECK1 = 8**, same 7 paths | ✓ |
| mover size deltas | +694 ×2, +517, +519, +174, +192, +296 | **all seven exact, all NONZERO** | ✓ |
| moved line KINDS | only `method_func_call` / `ref_obj` / `vpiFullName` | **32 / 32 / 29, nothing else** | ✓ |
| `mvgold77` attribution | 99 rows, 90 golden-exact, 9 in two families | **99, 90, 9 — identical** | ✓ |
| heads | 26 → 142 ×3, SeqDriver 1422687 → 1422695, BuildUVMPkg 94 → 94, ApbSlave/SVSwitch 0/0 | **every number identical** | ✓ |
| canaries / ctcan2 / canaudit | 9, 52, 1(6), 58(1), audited=31 UNCOVERED=0 FENCE-BREACH=0 | **identical** | ✓ |

**The head really is cleared.** Pristine's SimpleUVM-default head is
`ref_obj (uvm_pkg::uvm_sequencer_base::grant_queued_locks::status) @664:87` vs
our `method_func_call (status)`; patched has **zero occurrences of `status`** in
all three cmps and one shared new head object,
`part_select arb_sequence_q @681:23`. I confirmed both named residues on it
myself: golden carries `|vpiConstantSelect:1` and our side carries **0**
occurrences (R2), and the index ref is
`…grant_queued_locks::arb_sequence_q::b` in golden against
`…grant_queued_locks.arb_sequence_q::b` in ours — a `.` for a `::` at exactly
one joint (R3).

**The two NOT-GOLDEN families are exactly as described**, checked against the
golden dumps directly:

* **R4** — golden SimpleUVM carries
  `ref_obj: (uvm_pkg::uvm_reg_shared_access_seq::body::get_full_name)` at
  **line 116:65** where we put it at 143:90. Same class, same fullname, only
  the macro coordinate differs.
* **R9** — golden SeqDriver at `664:87` holds **4** objects: 2 named
  `uvm_pkg::…::grant_queued_locks::status` and 2 named
  `adpcm_pkg::…::grant_queued_locks::arb_sequence_q::status`. Pristine held 4,
  **all `method_func_call`**; patched holds 4 `ref_obj`, **2 byte-identical to
  golden** and 2 short one prefix segment. Strictly closer, not a regression.

**RF-3 is TRUE and I re-measured it independently.** Running
`r10svs2repro/w4_classbuiltin.sv` through Surelog, golden emits
`\_ref_obj: (randomize), line:17:19, endln:17:28` for the parens-less
`this.randomize` and `\_method_func_call: (randomize), line:18:19` for the
parens-ful one. r10svs2's F3 quoted the RHS as if it were golden. Golden's
`this` element also sits at `17:19-17:28`, i.e. on the MEMBER — confirming R1's
stated span defect as well.

**Boundaries: no breach.** All 6 `r10uvm74repro` arms and all 12
`r10uvm76repro` arms are `pris`/`pat` **byte-identical**. Of r10svs2's 11 arms,
**10 are byte-identical** — including `w4_classbuiltin`, `w2_spacedot` and
`w3_macrodeep`.

---

## FINDINGS

### F1 — `o.randomize with { … }` IS A WRITTEN CALL AND THE SHIPPED PROBE BROKE IT. **CODE FIXED.**

**This is the one real regression in the pass**: a cell where our PRISTINE
binary had the class RIGHT and the patch made it WRONG.

IEEE 1800's `randomize_call` makes the argument list **optional in front of a
constraint block**:

```
randomize_call ::= randomize [ ( [ … ] ) ] [ with [ ( [ … ] ) ] constraint_block ]
```

so `o.randomize with { a > 5; };` is parens-less and still emphatically a call.
The shipped probe scans forward for `(`, finds `w`, and reads PARENS-LESS.
Site 1's `!withExpr9` does **not** cover it — `withExpr9` is only ever assigned
from `getIteratorInfo()`, the ARRAY-LOCATOR `with`, never from a randomize
constraint block — and sites 2 and 3 have no `with` guard at all.

Measured on the new arm `v77x1_randwith.sv` (`o.randomize with { a > 5; }`):

```
GOLDEN    \_method_func_call: (randomize)          |vpiWith: \_constraint: (work@top77x1)
PRISTINE  \_method_func_call: (randomize), 25:11   <- class CORRECT
FIRST CUT \_ref_obj: (work@top77x1.randomize), 25:11   <- class BROKEN
```

**The pass's own instruments were structurally blind to it.** The arm's
dump-distance went 45 → **43**, i.e. *improved*, because that cell was already
differing on span/`vpiWith` for pre-existing reasons, so flipping its CLASS
added no lines. A line-count or head-depth reading reports this regression as
progress. Only a per-cell CLASS comparison against golden sees it — the same
lesson RF-2 records, at a shape RF-2's census never enumerated.

Corpus reach is 0 (Gate 5 sees 7 movers, all attributed, none a randomize), but
`obj.randomize with {…}` is ordinary constrained-random testbench idiom.

### F2 — THE COMMENT BLIND SPOT IS A NET REGRESSION AND HAS TWO SPELLINGS, NOT ONE. **CODE FIXED.**

README residue R5 names `x.m /*c*/ ()`, calls it "the one form it gets wrong",
and describes it as unmeasured. Measured on `v77x2_comment.sv`, against golden:

| cell | written | golden | pristine | first cut |
|---|---|---|---|---|
| 23:15 | `o.meth /* c */ ()` | `method_func_call` | **= golden** | **`ref_obj` — WRONG** |
| 24:15 | `o.meth // c` ⏎ `()` | `method_func_call` | **= golden** | **`ref_obj` — WRONG** |
| 26:15 | `o.meth /* c */ ;` | `ref_obj` | wrong | = golden ✓ |

Two corrections to the README. First, the **LINE-comment spelling is a second
instance** and is not mentioned anywhere. Second, this is **not a "blind spot",
it is a NET REGRESSION on the arm**: pristine had **one** wrong cell (3 dump
lines), the first cut has **two** (6 dump lines). The law fixes one cell here
and breaks two.

### F1+F2 FIX — `§ parensProbeSkipsTriviaAndWith77`

One function, `methodParensWritten77`. The scan now steps over `/*…*/` and
`//…` as well as whitespace, and reads a following `with` keyword (word-boundary
checked) as PARENS-FUL; the window starts at 4096 so a comment can be stepped
over, and a comment that runs past the window REFUSES (reads PARENS-FUL). The
anchor check is untouched.

**Every added case makes the probe read PARENS-FUL, so the fix strictly SHRINKS
the firing set and no converged cell can regress.** That is not an argument, it
is measured — the re-cut's corpus databases are **byte-identical to the first
cut's**: the same 7 movers with the same patched md5s
(`ed74ef854ede`, `367202ac4e30`, `278a2f64709a`, `cde8eb2ced51`, `f731e782ff87`,
`a00b613e8e32`), the same 99/90/9 attribution, the same heads. The four corpus
cells survive because their following text is `inside`, `==`, `)` and `<`:

```
664:  … item.process_id.status inside {process::KILLED, process::FINISHED});
755:  if ((arb_sequence_q[i].process_id.status == process::KILLED) ||
```

After the fix: `v77x1_randwith` moves only the legitimate cell (6 → **3** dump
lines moved) and `v77x2_comment` goes to **PASS_CMP + DUMP_MATCH** — the whole
arm byte-identical to golden, better than pristine *and* better than the first
cut.

### F3 — `s5_negctl`, r10svs2's OWN NEGATIVE-CONTROL ARM, MOVES. Direction favourable; the pass did not report it.

The pass ran exactly one of r10svs2's eleven arms (`w4_classbuiltin`) and
reported it byte-identical. I ran all eleven. **`s5_negctl` moves**, at cell
`r = o.val;` (user method, no parens, expression context):

```
pristine  \_method_func_call: (val), 24:11
patched   \_ref_obj: (work@holder::f::val), 24:11  + |vpiFullName
golden    \_ref_obj: (work@holder::f::val), line:24:11, endln:24:14
```

Patched is **exactly golden**; the arm goes 13 → 10 dump lines from golden. So
this is a convergence and it closes r10svs2's residue R1 as RF-4 claims — but a
boundary owner's arm named "negative control" moving is a fact that belongs in
the report, and a one-of-eleven sample cannot establish "the boundary is inert".

### F4 — the arm statistic for `c3_kind` is wrong: 62 → 59 is really **65 → 59**.

Re-measured with the pass's own `ct77arm.sh` and its own binary:
`DUMP_DIFF content=65`. The improvement is **−6, not −3**. Non-load-bearing and
in the pass's own favour, but STATED == MEASURED. `c1` (30 → 21), `c2`
(9 → 0, PASS_CMP + DUMP_MATCH), `c4` (22 → 13) and `v77w4` (byte-identical) all
reproduce exactly.

### F5 — the Gate 1 "= main-tree binary" corroboration is not reproducible, and was never sound.

The README argues the pristine worktree "really is the base commit" because its
binary is md5-identical to `/home/heyfey/git-repos/slang-uhdm/build/slang-uhdm`.
The main tree is now at `3a7a6a6` (three commits past 024b1b5) and its binary is
`3925b8fe80afa09d524f7d42ac0f468c` ≠ `a72eeb76…`. The claim was time-dependent
on a tree the pass does not control — exactly the failure mode MEMORY's
"Alias population: REFUTED" note warns about. The sound evidence is the one
also given: `rev-parse HEAD` = 024b1b5 with EMPTY porcelain. I verified that
directly. **No impact on the patch; the citation should be dropped.**

### F6 — internal inconsistency: "4 movers" vs 7.

README §opening says "**4 movers on the surelog corpus**"; §4 Gate 5 says
**7**. It is 4 test NAMES across 7 database-mode PATHS. The gate figure is the
right one.

---

## WHAT I COULD NOT BREAK

Product cells I filled that the pass left empty, all of which **confirm** it:

* **`v77x4_scope.sv` — the `joinRef` fullname across five enclosing scopes.**
  The pass measured two (a function and a module `initial`). I measured an
  in-body class method, an **out-of-body** class method, a **package**
  function, a **task** body, and a **generate block** (two instances). All
  eight moved cells are **byte-identical to golden**, including the
  instance-qualified `work@top77x4.gblk[0].status` and
  `x4pkg::x4c::oob::status`. The one join is right well beyond where it was
  tested.
* **`super.`-rooted** (`v77x3_recvkind.sv` cell 1) — does not move; site 2's
  `superRoot11` holds and site 3's `NamedValue` test excludes it. Golden wants
  a name-only `ref_obj` pair there, the same regime as `this.` — so R1 should
  be widened to "`this`/`super`-rooted".
* **static `::` receiver** (`x3d::smeth`, parens-less) — does not move. buvm1's
  boundary is not breached.
* **a parens-less step inside a CAST** (`int'(p.status)`) — moves, and lands
  **exactly on golden**. This is the shape that defeated `expr.syntax->kind`
  (r10svs2's four u2r rows); the text probe gets it right, which is direct
  support for the pass's choice of gate.
* **`thisRoot11` really does return unconditionally** on all three arms, so
  sites 2 and 3 are structurally unreachable for a `this` receiver — checked in
  the code, as the README claims. Sites 2 and 3 are both under `!callStmtCtx0`.
  STATED GATE == CODE GATE holds.
* **`rawText` is bounds-safe** (`if (end > text.size() || start > end) return ""`),
  so the forward scan cannot run off the buffer; the halving loop is a correct
  response to that contract.

---

## RANKED RESIDUES (revised)

**R1 — the `this`- AND `super`-ROOTED path regime.** Unchanged in rank and now
wider than the pass stated: golden makes every element of a `this`- *or*
`super`-rooted path a NAME-ONLY `ref_obj` at the MEMBER's span. Measured on
r10svs2's `w4` (`this`) and on `v77x3_recvkind` (`super`, where we emit no
hier_path at all).

**R2 / R3 — the new head**, `vpiConstantSelect:1` on the `part_select` and the
`.`-for-`::` joint in `joinRef`. One object, one pass. Both re-confirmed here.

**R4 — the macro-span divergence** (golden line 116 vs our 143). Objects agree
exactly; verified against the golden dump.

**R5 — RETIRED.** Both comment spellings are fixed; the probe now reads them as
written calls.

**R5′ (new, was the second half of R5) — `q . size`, spaces around the dot.**
Still refused by `anchorOk`, still r10svs2's F2. Unchanged.

**R6 / R7 / R8 / R9** — unchanged from the pass's list; R9's arithmetic
independently confirmed above.

**R10 (new) — `withExpr9` is narrower than the word "with".** It is derived
only from `getIteratorInfo()`. The fix here handles the randomize case in the
probe, which is the right place for a *text* question, but any future law that
reasons about "does this call have a `with` clause" from `withExpr9` alone
inherits F1's hole.

---

## FILES ADDED BY THE VERIFIER

| file | role |
|---|---|
| `v77x1_randwith.sv` | **F1** — `randomize with {…}`, the parens-less written call |
| `v77x2_comment.sv` | **F2** — block- and line-comment before the parens, plus the genuinely parens-less control |
| `v77x3_recvkind.sv` | `super.`, static `::`, and a parens-less step inside a CAST |
| `v77x4_scope.sv` | the `joinRef` fullname across five enclosing scopes |
| `v77arm.sh` | arm driver: golden + BOTH binaries in ONE scratch dir |

---

## FIVE GATES ON THE RE-CUT — all green

1. **BUILD** `-j 2`, link line reached, 0 errors. Re-cut md5
   `c801d9dd84dd2e9874a8982c6cca75ac`; pristine `a72eeb765b73c70687aaa58f1f3cca89`.
   Both worktrees at 024b1b5, pristine porcelain empty.
2. **GOLDENS** 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` → 0 PASS.
3. **u2r testflags** 679 / 50 / 2, dump 496/183/52, **0 differing ROWS**.
4. **surelog both modes** 469/11/25/5 and 465/8/23/5, **0 differing ROWS** over
   1588, all four histograms identical.
5. **BYTE VERIFIER** `SELFCHECK=1 SELFCHECK1=1`, PATH_SETS_IDENTICAL both
   corpora. u2r **0 / 679** (SELFCHECK1 = 1); surelog **7 / 953**
   (SELFCHECK1 = 8 = 7 + 1) — the same 7 databases with the same md5s as the
   first cut. `mv77` deltas all NONZERO and identical; `mvgold77` 99 rows,
   90 golden-exact, 9 in the two named families.

Canaries: `canaries.sh` ok=9 / ok=52, changed=0 absent=0; `ctcan2.sh` ok=1
(EXPECT_UNKNOWN=6) and ok=58 (EXPECT_UNKNOWN=1), changed=0; `canaudit.sh`
audited=31 UNCOVERED=0 FENCE-BREACH=0. `InterfaceModPort`,
`BlackParrotComplex`, `SVSwitch`, `ApbSlave` and the four UVM names checked BY
NAME with `diff` — all 16 rows byte-identical to `results/golden_surelog.csv`.
All sweep workdirs deleted.
