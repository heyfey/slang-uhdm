# r10uvm60 — ADVERSARIAL VERIFIER — **VERDICT: PARTIAL**

**The CODE is safe and every single number in the implementer's report reproduces
exactly, on a binary I built myself from the patch (same md5). The LAW it states
is REFUTED IN BOTH DIRECTIONS by three cells the grid never built** — two of them
shapes where the patched binary is WRONG and the PRISTINE binary was RIGHT, one
of them the very cell the report declares "CANNOT EXIST". Corpus price of all
three: **ZERO objects across 1 632 databases**, measured, not argued — which is
why this is PARTIAL (land it, correct the law next) and not FAIL.

Base **904fbd8**. My worktrees: `.claude/worktrees/r10uvm60v` (patched, branch
`r10uvm60vwt`) and `.claude/worktrees/r10uvm60vpris` (detached pristine). Both
`git rev-parse HEAD` = `904fbd8bf75ea7284f4ea7d4f17ef3ef44994321`.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| binary | md5 | mine == implementer's? |
|---|---|---|
| CONTROL pristine 904fbd8 | `68a223dae1fb08b6ce4dacccf947efe6` | **YES** |
| FINAL patched | `cfaeff91ad25b0c0f513c764ea1039bc` | **YES** |

I applied `/tmp/r10uvm60.patch` (md5 `844c26684fc9596cefff04fa34a85676`, verified
before use) to a fresh 904fbd8 worktree, configured and built it myself, and the
three production files md5 to `6fcda637…` / `7f55bd58…` / `3396f121…` — the
implementer's values — and the linked binary is **byte-identical** to theirs.
The patch also **`git apply --check`s cleanly onto the CURRENT main tree
(`981f2e3`, r10svs5 landed)** — no textual collision with the clocking pass.

---

## 1. EVERY NUMBER, REPRODUCED INDEPENDENTLY

All five gates were run on **my** build, from **my** sweeps, with the binary
printed and grep-checked out of each workdir's `cmds.txt`.

| gate | implementer | **mine** | command |
|---|---|---|---|
| 1 BUILD | link 1 / errors 0 | **link 1 / errors 0**, rc 0 | `cmake --build build -j 6` in both worktrees |
| 1 md5 | CONTROL `68a223da…`, FINAL `cfaeff91…` | **identical**, asserted in a separate command | `md5sum …/r10uvm60v{,pris}/build/slang-uhdm` |
| 1 determinism | 3 runs / 1 hash | **3 runs / 1 hash, 0 NO_OUTPUT** (`30908b26010d3099`) | `detcheck.sh <final> 3 <SimpleUVM argv>` |
| 2 GOLDENS | 23/0 | **rc 0, PASS=23, FAIL=0** | `SLANG_UHDM=<final> ./tests/check_goldens.sh` |
| 2 negative | `/bin/false` 0/23 | **rc 1, PASS=0, FAIL=23** | same with `SLANG_UHDM=/bin/false` |
| 3 u2r testflags | 679/50/2, dump 496/183/52, 0 rows | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL; dump 496 match / 183 differ / 52 blank; 0 differing ROWS** | `verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2` + `ct8rows.sh results/gate_uhdm2rtlil.csv` |
| 4 surelog default | 467/13/5/284/25 | **467 / 13 / 5 / 284 / 25** | `verify_golden.py --corpus surelog --mode both --jobs 2` |
| 4 surelog testflags | 463/10/5/286/23 (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM) | **identical, every bucket** | same sweep |
| 4 dump | 225/165 match | **default 225 match / 242 differ / 327 blank; testflags 165 / 298 / 331** | `ct8rows.sh results/golden_surelog.csv` |
| 4 rows | 0 differing ROWS | **0 differing ROWS (0 diff row-sides)**, and my **PRISTINE** sweep also reproduces the committed baseline at **0 rows** | `ct8rows.sh` on both CSVs |
| 5 u2r bytes | 679 paths, MOVERS 0, SELFCHECK 678/679, SELFCHECK1=1 | **679 / 0 / 678 / 1** | `SELFCHECK=1 SELFCHECK1=1 byteverify.sh wd_u2r_pat wd_u2r_pris` |
| 5 surelog bytes | 953 paths, MOVERS 7, SELFCHECK 952/953, SELFCHECK1=8 | **953 / 7 / 952 / 8**, and the **same seven names** | `… byteverify.sh wd_sl_pat wd_sl_pris` |
| heads | SimpleUVM d/t 50→42, Scoreboard d 50→42, SeqDriver 85→85, BuildUVMPkg 58→58, Scoreboard t SKIP-NOFILE | **all seven rows identical, both binaries measured** | `rowheads.sh wd_sl_{pris,pat} …` |
| per-shape | ADDED 988 / REMOVED 7832, OVER-FIRE 7, UNDER-FIRE 104, SELFCHECK PASS | **988 / 7832 / 7 / 104 / PASS**, and **all 7 OVER-FIREs are literally `\_FABRICATED_SHAPE_THAT_GOLDEN_CANNOT_HAVE`** — 0 real | `SELFCHECK=1 mv60.sh` |
| span-free | 403→139, 405→127, 445→165, 413→127, IMPROVED ×7 | **identical on all 7 movers** | `ARGTS60B=… szall60.sh` |
| canaries | canaudit 29/0/0; ctcan2 sl 58 ok / u2r 1 ok; canaries 52 ok + 8 ok; changed=0 | **identical, every count** | `canaudit.sh`, `EXPECT_UNKNOWN=1/6 ctcan2.sh`, `canaries.sh` |
| by name | InterfaceModPort, BlackParrotComplex CMP_EQUAL/differ ×2 modes | **confirmed in my own CSV** | `grep -E "^(InterfaceModPort\|BlackParrotComplex)," sl_pat.csv` |

Two further numbers I measured that the report did not:

* **Whole-dump multiset distance, SimpleUVM default** (not just the SIZECELL
  cells): pristine **145 725** → patched **144 870**. Improves.
  `msdist.sh sv_g.dump sv_{pris,pat}.dump`
* **Head identity, not just head count.** The pristine head IS the briefed object
  (`constant @150:156`, parent `func_call (uvm_report_error) @149:8-150:158`,
  `vpiSize:64 UINT:1 vpiConstType:9`, no typespec) and the patched head is a
  DIFFERENT object (`constant @145:55` under `method_func_call (print_field_int)`
  vs our `sys_func_call ($bits)`). **The head is cleared, not merely renumbered.**

**Brief difference (3) — "vpiConstType 9 vs ABSENT" — is FALSE, and the
implementer's refutation is CORRECT.** I read the pristine cmp's RHS block
verbatim: it ends `|vpiConstType:9` after the `vpiTypespec:` block. No const-type
writer was touched, so **§ enumSubstIntConst30's boundary is never crossed**
(`grep -E "VpiConstType|VpiSize|clocking"` over the production diff: **no hits**).

---

## 2. PATCH HYGIENE

* 3 production files, **+92 / −1** lines; the only semantic edit is **one added
  conjunct** (`constArgBodyEvald60`) in `argCtxOk`'s second disjunct. The
  `pkgTopEmit` arm is untouched. **STATED GATE == CODE GATE** — verified by
  reading `src/ExprEmit.cpp` ~10170-10215, not the comment.
* `git status` in my worktree: exactly `include/UhdmExporter.h`,
  `src/ExprEmit.cpp`, `src/TaskFuncEmit.cpp` modified + the untracked probe dir.
  **`results/*.csv` untouched; `git stash` never used; `GOLDEN_DEFER` unset**
  (5 DEFERRED in both modes, as in the baseline).
* 15 grep hits of the new identifiers across 3 files — matches the claim.
* **The gate reads NO names and NO raw text**: `subBodyEvaluated60` is a
  membership test on a `std::set<const SubroutineSymbol*>`. That is why the
  escaped-identifier and `` ` `` `` -pasting cells (arm `v7`, §3.4) behave
  identically — the standing "if any gate reads names, test escaped/macro
  spellings" rule is satisfied *by construction*, and I tested it anyway.
* Pointer-keyed set → **determinism**: the set is only ever queried, never
  iterated to produce output, and the closure's RESULT is order-independent.
  Measured (3 runs, 1 hash) rather than argued, per the memory note.
* **No collision** with r10svs5 (clocking path components: not touched, patch
  applies onto its landed commit) or r10earl31 (ref_typespec on FOLDED
  constants: this law only ever *removes* a ref_typespec on a **call-argument**
  constant; zero Earlgrey-family movers). **Stated limit:** `Earlgrey_nexysvideo`
  and `Earlgrey_Verilator_01_05_21` are `DEFERRED` and were **not run** by any
  gate here, so the r10earl31 family is only covered through `Earlgrey_0_1`,
  `Earlgrey`, and the other non-deferred rows — all 0-row, 0-mover.

---

## 3. NUMBERED FINDINGS

Arms are `tools/probe/r10uvm60repro/v1_reach.sv … v7_macroesc.sv` (mine); each
was run with `arm60.sh <arm> <out> <bin>` on **both** binaries and read with
`argts60 <db> rows`.

### FINDING 1 — **the seed set is INCOMPLETE: golden evaluates bodies reached from a GENERATE-IF CONDITION and from a PACKED-DIMENSION BOUND. The patch UNDER-FIRES there, and the PRISTINE binary was RIGHT.** (severity: law-wrong, corpus price 0)

`v1_reach.sv` holds six identical bodies (`return x + g60(1)`, `logic [3:0]`
formal) differing ONLY in how the body is reached. Golden, def view:

| row | reach | GOLDEN | PRISTINE | **PATCHED** |
|---|---|---|---|---|
| w1 (line 17) | **generate-if CONDITION** | **STAMPED, size 4** | stamped ✓ | **bare, size 64 ✗** |
| w2 (18) | module-level variable initialiser | bare, 64 | stamped ✗ | bare ✓ |
| w3 (19) | **packed-dimension bound `logic [w3(4'd1):0]`** | **STAMPED, size 4** | stamped ✓ | **bare, size 64 ✗** |
| w4 (20) | operand (not the whole rhs) of a cont-assign | bare, 64 | stamped ✗ | bare ✓ |
| w5 (21) | localparam inside a generate block | STAMPED, 4 | stamped ✓ | stamped ✓ |
| w6 (22) | expression in a variable initialiser | bare, 64 | stamped ✗ | bare ✓ |

Isolated, each in its own arm so the cmp verdict is about that cell alone:

* `v4_dim.sv` — **pristine: 36 cmp lines, head is an unrelated `range` constant.
  Patched: 50 cmp lines and THE HEAD IS THIS CONSTANT** (`LHS constant @10:22
  size 4 + ref_typespec(work@v4_dim.w3)` vs our bare 64). Dump distance
  **4 → 13**. The patch *creates* a head where pristine had none.
* `v3_genif.sv` — same shape, patched head is the constant; dump distance
  **6 → 15**.

Mechanism: a generate-if condition and a dimension bound are **elaboration-time
constant expressions**, exactly like the param initialiser seed. The stated law
("transitive closure of two seeds") is a strict subset of the true set. This is
the *same* failure mode that already cost this code one regression once —
`pkgSubEvaluatedFromParamInit`'s own comment records that cont-assign-only had to
be widened to include param initialisers after `EvalFunc` demoted.

**PRICE: 0 objects.** Corpus-wide census of the PATCHED sweep (`census60.sh`,
both corpora, golden read from each test's own `cmds.txt`):
`surelog: 953 databases censused, GOLDEN_MISSING 0, tests with a tf-body
constant TS: 0` and `uhdm2rtlil: 679 censused, 1 hit — const_fold_func
ourTS=1 goldTS=1`. **Golden itself stamps that cell exactly once in 1 632
databases, and we match it.** Any corpus occurrence of the w1/w3 shape would have
flipped bytes and appeared as a mover; the movers are exactly the 7 UVM
databases. So this finding is a **future-risk / law-correctness** finding, not a
measured regression.

### FINDING 2 — **the cell the report calls IMPOSSIBLE ("R6: a class method can never enter the evaluated set") EXISTS, via the very transitivity the pass introduced — and golden is BARE there while we STAMP.** (severity: law-wrong, corpus price 0)

`v2_class.sv`: a plain module function `caller` **is** a cont-assign rhs (seed)
and calls `c62::sm`, a **class static method**. The transitive closure therefore
puts a CLASS METHOD in `evaldBodies60`, and we stamp its `h62(1)`:

```
GOLD  17:25 CLASS_METHOD call=h62 constant size=64 UINT:1 ct=9 ts=-
PAT   17:25 CLASS_METHOD call=h62 constant size=4  UINT:1 ct=9 ts=bit_typespec   <-- OVER-FIRE
```

Refutation (d) of the report — "class-ness is not the discriminator,
unreachability is" — is therefore **itself refuted**: made reachable, the class
method still does not stamp.

### FINDING 3 — **the real mechanism is POISONING, not reachability: one unreducible callee makes golden abandon the WHOLE body, including a constant actual sitting beside it in the seed function itself.** (severity: mechanism-correction)

`v5_class2.sv` separates the two explanations. `caller` is a cont-assign rhs and
holds BOTH `c65::sm(x)` and its own `g65(1)`; `caller2` is the identical control
with no class call:

```
GOLD  18:25 CLASS_METHOD call=h65 size=64 ts=-      (inside the class method)
GOLD  31:31 MOD_FUNC     call=g65 size=64 ts=-      (inside caller — the SEED body!)
GOLD  35:22 MOD_FUNC     call=g65 size=4  ts=logic_typespec   (caller2, control)
PAT   31:31 MOD_FUNC     call=g65 size=4  ts=logic_typespec   <-- OVER-FIRE
```

So golden's rule is **"the body was actually REDUCED"**, and a call the evaluator
cannot execute aborts the reduction for the entire body — the same family as the
existing `precUnreduced9` / `siblingCallArg9` left-to-right abort laws already in
this file. `§ tfBodyConstArgNeedsEvaldBody60` should be restated as: *seeds =
every elaboration-time constant context (cont-assign rhs, param initialiser,
generate condition, dimension bound, …); closure over call edges; and the walk
must ABORT on a callee the evaluator cannot run (class methods among them).*
Both corrections are corpus-neutral by FINDING 1's census.

### FINDING 4 — **the RESIZE half still over-fires in EVALUATED bodies: golden resizes only the UNSIZED DECIMAL, keeps a sized literal's written width, expands `'1` to the formal width by VALUE, and does not stamp a NARROWER sized literal at all.** (severity: residue, pre-existing, cmp-visible)

The grid varied the literal only in bodies nothing evaluates (`b3`, all bare) and
varied the reach only with a bare `1` (`b6`). The product cell is `v6_evalform.sv`
— every row inside a cont-assign-rhs callee:

| written actual | GOLDEN | OURS (pristine == patched) |
|---|---|---|
| `g4(1)` unsized decimal | size 4, `UINT:1`, ts | size 4, ts ✓ |
| `g4(1'b1)` | **size 1**, `BIN:1`, ts | size **4** ✗ |
| `g4(4'd3)` | size 4, `DEC:3`, ts | ✓ |
| `g4('1)` | size 4, **`BIN:1111`**, ts | value **`BIN:1`** ✗ |
| `g8(8'hAB)` | size 8, `HEX:AB`, ts | ✓ |
| `g8(3'b101)` narrower than formal | size **3**, **ts = -** | size 8, **stamped** ✗ |
| `gi(7)`, `gs("s")` | 64 / 8, bare | ✓ |

`cmp -s` says the pristine and patched databases for this arm are **byte-identical**
— pre-existing, untouched by this pass, and correctly out of its scope. Filed as
residue **V-R3**.

### FINDING 5 — **the report's taxonomy of the 104 UNDER-FIREs is incomplete: three of them are NAMED `vpiFullName` lines, not bare fields and not macro spans.** (severity: write-up accuracy)

```
REMOVED x1 golden=13 ours=12 UNDER-FIRE |vpiFullName:uvm_pkg::uvm_test_done_objection::all_dropped
REMOVED x1 golden=3  ours=2  UNDER-FIRE |vpiFullName:uvm_pkg::uvm_objection::m_forked_drain
REMOVED x1 golden=7  ours=6  UNDER-FIRE |vpiFullName:uvm_pkg::uvm_simple_sequence::body
```

I decoded one to closure: golden's third `m_forked_drain` line belongs to a
**`ref_obj` under a `delay_control`** (`uvm_objection.svh:751`) that we do not
emit for an unrelated reason; ours was the **spurious `ref_typespec`** on a
constant. Two different objects producing the same dump text — a **text
collision**, so the "under-fire" is a pre-existing deficit that our own bug was
masking, not damage from this patch. The conclusion (0 real under-fires) stands;
the stated taxonomy ("bare field lines + macro-span shapes") needs this third
family added.

### FINDING 6 — the macro / token axes: **NOTHING is wrong there, and the patch takes that arm to CMP EQUAL.** (severity: none — a confirmation)

`v7_macroesc.sv` builds the four macro geometries the grid skipped: **nested
macro two levels deep**, an **argument on the next source line**, a callee name
built by **`` ` `` `` token pasting**, and **escaped identifiers** for both callee
and formal. Golden is bare/size 64 in all four.

```
pristine : cmp rc=255  cmp lines=50  heads=1     (stamped + resized in all four)
PATCHED  : cmp rc=0    cmp lines=0   heads=0     EQUAL
```

The only residual delta is a **column** on the escaped-identifier call (golden
`45:31`, ours `45:27`) — residue R1's family, cmp-invisible. This is the
strongest positive evidence in the pass: a 4-cell macro/token arm that goes from
one head to fully equal.

---

## 4. WHAT I CONFIRM OF THE IMPLEMENTER'S OWN CLAIMS

* **Head cleared and advanced on all three target row-modes** — confirmed by
  object identity, not by line count.
* **NO CONVERSION** — confirmed; SimpleUVM/Scoreboard stay CMP_NOTEQUAL and the
  scoreboards are unchanged to the row.
* **Refutation (a)** (`vpiConstType` was never a difference) — **confirmed
  verbatim from the cmp text.** Fixing the brief's item (3) would have written a
  second const-type writer over a correct one.
* **Refutation (b)** (64 is the unsized-decimal encoding, formal-independent) —
  confirmed by `v6` (`gi(7)` → 64 on an `int` formal; `g4(1'b1)` → 1).
* **Refutation (e)** (`const_fold_func` forbids the wide "delete the arm"
  reading) — confirmed: `ourTS=1 goldTS=1`, and its `loop(2)` still carries
  `size=4 ts=logic_typespec` after the patch.
* **Refutation (f)** (one hop is not enough) — confirmed by b6 R5.
* **Refutations (d) and R6 — REFUTED by FINDINGS 2 and 3.**
* The disclosed ops facts (a discarded wrong-binary sweep; the main tree moving
  to `80892a3`) are consistent with what I see: the main tree is now `981f2e3`,
  and **zero r10uvm60 identifiers exist in it** (`grep -rn … src/ include/` in the
  main tree: 0 hits).

---

## 5. RANKED RESIDUES (mine, merged with theirs)

| # | residue | evidence | price |
|---|---|---|---|
| **V-R1** | **the seed set / abort rule** — FINDINGS 1-3. The law needs generate-if + dimension seeds AND an abort on unreducible callees | `v1_reach.sv`, `v3_genif.sv`, `v4_dim.sv`, `v2_class.sv`, `v5_class2.sv` | **0 objects today**; both corrections corpus-neutral, so a follow-up can land them on measurement alone |
| **V-R2** | **the new head** (= their R2): golden folds `$bits(m_locked)` to `UINT:1` size 64 in `print_field_int`, we emit the `sys_func_call` — identical on SimpleUVM ×2 and Scoreboard | `rh_pat/SimpleUVM.default.cmp` head, verified by me | highest-value next target, all three target rows |
| **V-R3** | **resize policy in EVALUATED bodies** — FINDING 4 (sized literal width, `'1` value, narrower-than-formal not stamped) | `v6_evalform.sv` | pre-existing; 3 wrong cells out of 9 |
| **V-R4** | macro-buffer / escaped-identifier **LOCATION** (= their R1) — also visible on an escaped identifier with no macro at all | `v7_macroesc.sv` (`45:31` vs `45:27`), `b7_multiline.sv` | dump-only; 233 Compare methods read zero location fields |
| **V-R5** | `INT:`-encoded constant actuals golden mints and we never do (their R3, 12 + 11) | `szall60.sh` tables | separate law |
| **V-R6** | `size=0 ct=0` pair; STRING multiplicity; def/elab twin (their R4-R6) | same | separate laws |
| **V-R7** | **coverage limit, not a residue**: the two `DEFERRED` Earlgrey giants run in NO gate here | `sl_pat.csv` | any r10earl31 interaction there is unmeasured by construction |

---

## 6. OPS, DISCLOSED

* My own slip, caught and corrected: the first four build/configure logs were
  written under `/tmp/claude-1000/...` (the harness scratchpad) before I applied
  the standing "never touch /tmp/claude-1000" rule; all four were **deleted** and
  everything else lives in `/tmp/v60v/`. No gate number depends on their location.
* Every sweep's binary was **printed and grep-checked out of the workdir itself**:
  `wd_sl_pat` 1523/1523 `cmds.txt` name `…/r10uvm60v/build/slang-uhdm`,
  `wd_sl_pris` 1523/1523 name `…/r10uvm60vpris/…`, `wd_u2r_pat` 729/729,
  `wd_u2r_pris` 729/729. No cross-contamination.
* `results/*.csv` READ ONLY. `git stash` never used. `GOLDEN_DEFER` unset.
  Fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`)
  never dispatched — `canaudit.sh`: audited=29, UNCOVERED=0, **FENCE-BREACH=0**.
* Sweeps ran `--jobs 2` into my own `--out`/`--workdir`; `/tmp/v60v/wd_*` deleted
  after the last number was read.

## 7. FILES I ADDED (this worktree's probe dir)

`v1_reach.sv` (reach axis, 6 rows) · `v2_class.sv` (scope × reach product) ·
`v3_genif.sv`, `v4_dim.sv` (the two under-fire cells, isolated) ·
`v5_class2.sv` (poisoning vs class-ness) · `v6_evalform.sv` (evaluated body ×
literal form) · `v7_macroesc.sv` (nested macro / continuation arg / `` ` `` ``
pasting / escaped identifiers) · this file.

## 8. BOTTOM LINE

**PARTIAL. Land it** — the patch is byte-reproducible, deterministic, clears the
briefed head on all three row-modes by object identity, improves all 7 movers on
every instrument, and costs **0** objects anywhere else in 1 632 databases.
**Then fix the law**: § tfBodyConstArgNeedsEvaldBody60 is not "the transitive
closure of two seeds" — it is *every elaboration-time constant context*, closed
over call edges, **aborted by the first callee the evaluator cannot run**. Three
constructed cells say so, and all three cost nothing to correct.
