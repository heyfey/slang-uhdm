# r10earl39 — ADVERSARIAL VERIFIER REPORT — § defGenProcArgNoFormalTs39

**VERDICT: PASS** (with two corrections to the implementer's reported numbers,
neither of which changes the verdict, and one residue newly SEPARATED).

Verified by an independent verifier who built BOTH binaries from its own fresh
worktrees of `983cf4b`, re-ran every gate, and re-derived every number rather
than re-reading it.

| | |
|---|---|
| BASE | `983cf4b` (repo HEAD at verification time — stated, as required) |
| PATCH | `/tmp/r10earl39.patch` md5 `f6a72e7eb9d4f7dcb76401e2cf0c045c`, 84148 bytes |
| PRISTINE binary | `/tmp/wt_e39vpris/build/slang-uhdm` md5 `d1e122cf2a4999c362efa0ef536765c7` |
| PATCHED binary | `/tmp/wt_e39v/build/slang-uhdm` md5 `bbee9562c6a92d50d76199f32bf20f22` |
| VERIFIED PATCH | `/tmp/r10earl39.verified.patch` (adds this file + `v1_r2sep.sv`; production hunk BYTE-IDENTICAL) |

**Both md5s reproduced bit-exactly on independent worktrees.** That is the
strongest single hygiene fact available and it means every number below is a
number for the delivered source.

---

## 1. THE LAW HOLDS, AND ITS MECHANISM IS CONFIRMED IN THE SOURCE

`git apply --check` clean against a fresh `983cf4b`; 11 files, 1617 insertions,
**0 deletions**; one production file. The patch regenerated from my own worktree
is **byte-identical** to the delivered one (same md5, same 84148 bytes).

**STATED GATE == CODE GATE — verified character by character:**

```cpp
if (isFunc && !inProcessEmit && !inGenScopeProc &&
    !defGenProcessEmit &&                              // <-- the ONE added conjunct
    !caCondReduceStop && argCtxOk && !pkgScopedRef &&
```

51 inserted lines in `src/ExprEmit.cpp`, of which **1 is code and 50 are
comment**. Single hunk `@@ -11347,7 +11347,58 @@`.

Two structural claims I checked in the source rather than accepting:

* **`defGenProcessEmit` has exactly ONE writer in the tree** —
  `src/ModuleEmit.cpp:26451/26455` — and it is set only around the
  `emitProcess(...)` call inside `emitDefGenStmts`' process loop, whose item
  filter is `AlwaysBlock | AlwaysCombBlock | AlwaysFFBlock | AlwaysLatchBlock |
  InitialBlock`. **A generate CONT-ASSIGN is genuinely not covered**, so the
  law's carve-out is a property of the code, not a hope.
* **The memoising-getter second effect is real.** `UHDM/scripts/classes.py:73-82`
  generates, for `vpiFullName` only:
  ```cpp
  if (!vpiFullName_) { const std::string fullName = ComputeFullName();
                       if (!fullName.empty()) const_cast<...>(this)->VpiFullName(fullName); }
  ```
  and `ComputeFullName()` (`UHDM/templates/BaseClass.cpp:100`) is a `VpiParent()`
  walk. In `emitDefGenStmts`, `p->VpiParent(b)` runs **after** `emitProcess`
  returns — so a read during emission freezes a truncated name. Confirmed
  mechanism, confirmed ordering.

### The brief's two anchors were wrong — I re-measured, the implementer is right

I wrote the brief, so I checked its refutation hardest. Both corrections hold:

* `prim_prince.sv:88` is `always_comb begin : p_fwd_d64`, inside
  `if (DataWidth == 64) begin : gen_fwd_d64` (line 87) inside
  `for (genvar k = 1; ...) begin : gen_fwd_pass` (line 85). **`p_fwd_d64` is not
  a function.** The brief's "function-local vs function-ARG" axis does not exist
  in this cell.
* `prim_prince.sv:110` is a bare `end`. The real anchor is
  `prim_cipher_pkg.sv:110` col 59 = `logic`, the **callee's formal** of
  `prince_mult_prime_64bit`. Verified by `awk 'NR==110 {print substr($0,59,6)}'`.

Three of the brief's four grid axes are correctly **REFUTED as discriminators**.

---

## 2. THE HEAD IS CLEARED — MEASURED, NOT ASSERTED

PRISTINE head (17 lines) is **exactly** the object my brief described:

```
LHS: <null>
RHS: ref_typespec: (work@prim_prince.p_fwd_d64.data_state_round), id:127562
     \_ref_obj: ... line:91:69, endln:91:85
     |vpiActual: \_logic_typespec: , id:22371, line:110:59, endln:110:64
```

PATCHED head is a **different family**: `var_select
(prim_cipher_pkg::PRINCE_ROUND_CONST)` at `106:29`, and **LHS is now populated**
— i.e. the surplus is gone and the new head is a golden-only object (R1). The
shipped witness `r1_nexthead.cmp` is **byte-identical** to my independently
measured `cmp.log`.

| instrument | PRISTINE | PATCHED | claim | verdict |
|---|---|---|---|---|
| Earlgrey cmp lines | 17 | 100 | 17 → 100 | **exact** |
| Earlgrey dump lines | 4 655 219 | 4 655 093 | −126 | **exact** |
| dump diff removed / added / hunks | — | 154 / 28 / 18 | 154 / 28 / 18 | **exact** |
| msdist to golden | 309 009 | 308 941 | −68 | **exact** |
| census (def-view gen process) | 18 stamped / 12 bare | **0 / 30** | golden 0 / 30 | **exact parity** |
| census TOTALS | surplus 4, keyonly 362 | **surplus 0 missing 0** | surplus 0 missing 0 | **exact** |
| arm `DUMP_DIFF` / hunks | 524 / 41 | 306 / 21 | 524→306, 41→21 | **exact** |

**The cmp log growing 17 → 100 is head DEPTH, correctly declared as such.** Every
distance instrument moves the right way.

### The accounting closes to the unit, independently

`predlines39.py` run on the PRISTINE dump alone (a genuine pre-build prediction)
prints `PREDICTED MOVER OBJECTS: 18` / `PREDICTED LINES REMOVED: 126 (0 added)`.
Measured `154 − 28 = 126`. The 18 subtrees × 7 lines = 126; the extra 28 removed
and 28 added are **14 `ref_obj`s × 2 lines** — the fullname repair. The removed
strings are the truncated `work@prim_prince.p_fwd_d64.data_state_round` (the
exact string quoted in my brief) and the added ones are the full
`work@prim_prince.gen_fwd_pass.gen_fwd_d64.p_fwd_d64.data_state_round`.

**All 22 distinct added line shapes verified present VERBATIM in the golden
dump** (`grep -qxF` against a 4 823 448-line golden dump I generated myself):
**22 / 22, 0 missing.** All 28 added lines are in `prim_prince`.

---

## 3. THE GRID, RE-DERIVED FROM MY OWN DUMPS

Independent census of `a1_argts.sv` (G = golden, O = pristine, P = patched):

```
MOVED = 22    HOLD = 31    OTHER = 3
```

**All 22 MOVED cells go `ts=1 → ts=0` with golden at 0 — exact parity, 0
regressions.** Coverage confirmed cell-for-cell: gen-for body, gen-if, gen-else
(untaken), gen-case item + default, nested gen-for>gen-if, `always_comb` /
`always_ff` / `always_latch` / `always @*` / `initial`, and actual kinds var-ref,
gen-local, bit-select, part-select, constant, operation, nested call, depth-2,
`int` formal, typedef formal.

**No empty product cells.** Every cell the README names is present in my census
with the claimed values.

**The separating pairs are genuine, and one is exceptionally clean:**

* **g1 vs g1e share the IDENTICAL span `84:25`** — the same source process seen
  through the DEF emitter (`gen_for/always`, MOVED) and the ELAB emitter
  (`gen_scope_array/gen_scope/always`, `0/0/0`). Source text held exactly fixed;
  only the emitter differs. **This isolates THE EMITTER.**
* **g2 (`gen_if_else/always`, MOVED) vs g6 (`gen_if/cont_assign`, `0/0/0`)** —
  same gen-if, procedural vs continuous. The control does not move.
* Golden's two `ts=1` cells in the arm (`70:30` module cont-assign, `177:32`
  ELAB gen cont-assign) are **untouched**.

The 3 OTHER rows are: **R2 × 2** (`192:39`, surplus survives — honestly declared
by the implementer) and one **golden-only** `190:44` `param_assign` row absent
from both our sides (pre-existing missing, identical in O and P, not this patch).

---

## 4. FIVE GATES — RE-RUN INDEPENDENTLY

**GATE 1 BUILD — GREEN.** Both binaries built from my own fresh `983cf4b`
worktrees with absolute paths; waited for the anchored link line; `error:` = 0 on
both; md5 taken in a separate step and asserted 32-hex; pristine
`git status --porcelain` = 0 lines. **Both md5s match the implementer's exactly**,
which also settles the "comment-only rebuild produced the same md5" claim.

**GATE 2 GOLDENS — GREEN.** `SLANG_UHDM` exported and echoed with its md5:
**23 PASS / 0 FAIL**. Negative control `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL**.

**GATE 3 uhdm2rtlil, `--mode both --jobs 2`, own out/workdir — GREEN.**
default **679/50/2**, testflags **679/50/2**; dump histogram **496 match / 183
differ / 52 blank**. The committed baseline carries **0 non-testflags rows**, so
the row gate is the testflags projection: **732 vs 732, `diff` empty — 0
differing rows.** Pristine CSV also equals the committed baseline, and
`diff pat pris` is empty.

**GATE 4 surelog, both modes, `--jobs 2`, run SEQUENTIALLY — GREEN.**
default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED**;
testflags **465 / 8 / 23 / 5**. `diff` against committed `results/golden_surelog.csv`:
**0 differing lines (1589 vs 1589)**. Dump histograms **unchanged both modes**
(default 325/244/225, testflags 329/300/165). `GOLDEN_DEFER` left unset.
`Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,` is **byte-identical** to
baseline — the row does not move, the bytes do. Another agent's surelog sweeps
had finished before mine started, so the documented detail-row race did not apply.

**GATE 5 BYTE VERIFIER — GREEN, with a correction (see F1).**

```
uhdm2rtlil : 1358 = 1358  PATH_SETS_IDENTICAL   MOVERS: 0 / 1358
surelog    :  953 =  953  PATH_SETS_IDENTICAL   MOVERS: 2 /  953
    MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm   <- the target, REAL
    MOVER ./default/Scoreboard-59431470/slang.uhdm     <- FLAKE, arbitrated below
```

Controls: u2r `SELFCHECK=1` → 1357/1358, `SELFCHECK1=1` → 1. surelog
`SELFCHECK=1` → 952/953, `SELFCHECK1=1` → **3** (= 1 corrupted + the 2 observed
movers), which is the instrument's stated contract.

**CANARIES.** `canaries.sh`: surelog **ok=52 changed=0**, u2r **ok=8 changed=0**.
`ctcan2.sh` baseline-first and mode-matched: surelog `EXPECT_UNKNOWN=1` **PASS**
(58 ok, 0 changed), u2r `EXPECT_UNKNOWN=6` **PASS**. `InterfaceModPort` and
`BlackParrotComplex` BY NAME: 2 rows each in surelog, identical to baseline; **0
rows in u2r — vacuous there, and the implementer stated that**. The four
slang-fenced names appear in `README.md` prose only and in **0 drivers**.

**BOUNDARIES.** § genChainBranchScopeThreads38: `a1_chain.sv` **`PASS_CMP` on both
binaries** (identical `DUMP_DIFF 178/10`); `a2_fence.sv` **`heads=1 lines=17`,
`DUMP_DIFF 989/68` on both**, `cmp.log` **byte-identical** and `o.dump`
**byte-identical after workdir-path normalisation**. Live passes: **SeqDriver,
SimpleUVM and BuildUVMPkg are all byte-identical** between binaries — **no
collision** with r10sd1 or r10uvm68.

---

## 5. NUMBERED FINDINGS

### F1 — MATERIAL, RESOLVED: the surelog byte verifier reports **2 movers, not 1**, and the multi-stability arbitration WAS owed

The implementer reported `MOVERS: 1 / 953` and wrote *"`Scoreboard` not a mover —
no multi-stability arbitration owed."* **In my run `Scoreboard/default` is a
mover.** The standing rules name `Scoreboard` as multi-stable and require size
plus 3 reps before attributing, so I performed the arbitration.

```
$ ls -la .../Scoreboard-59431470/slang.uhdm       # SAME SIZE both sides
patched 11122522    pristine 11122522             -> same-size = flake signature

# 3 reps, SAME binary, same command (from cmds.txt):
PATCHED  rep1 8debd9be5872  rep2 8efa3d8a2906  rep3 8efa3d8a2906
PRISTINE rep1 c7d29a6824a9  rep2 8efa3d8a2906  rep3 8efa3d8a2906
```

**A fixed binary produces different bytes across runs, and the two binaries'
value sets OVERLAP (both reach `8efa3d8a2906`) at identical size.** `Scoreboard`
is therefore a **FLAKE, not a mover** — consistent with the emitter-nondeterminism
memory. Earlgrey by contrast shows a real **size delta** (49 940 223 →
49 938 801, −1422 bytes).

**Consequence:** the implementer's *conclusion* (exactly one real mover, the
target) is **correct**, but the statement "no arbitration was owed" is **wrong as
written** — it was owed, and it was luck that their sweep did not surface it.
This does not affect the verdict; it is recorded so the next pass does not treat
"Scoreboard was clean once" as evidence. `SELFCHECK1=1` returning 3 rather than 2
follows from the same cause.

### F2 — MINOR, CONSERVATIVE: the ELAB-twin count is understated

README §3 says "the full census carries **19 more**" ELAB twins. My census counts
**22 ELAB twin rows at `0/0/0`**, plus 2 golden-stamped ELAB rows left unchanged.
The error is an **undercount** — there is more confirming evidence than claimed,
not less. No conclusion changes.

### F3 — LAW REFINEMENT: "procedural ⇒ never stamped" is FALSE in golden; the generate-scoped law is what is true

I re-ran the census with a **broader** filter than `cenpred39.sh` uses (any
generate construct anywhere before a process, not just `gen_if|gen_if_else|gen_case`):

```
ANY-generate-then-process (golden):  stamped=0  bare=85     <- law holds, wider population
ANY process context      (golden):   stamped=2  bare=177    <- TWO golden stamps
```

The two golden stamps are `dm::csrw` @`388:47` and `dm::csrr` @`427:47`, both
**module-level `always`** with an **operation** actual under
`case_stmt/begin/begin/begin`. **We stamp them too, and golden stamps them — the
two sides AGREE and the patch leaves them alone.** This is a valuable real-corpus
over-fire control (the patch demonstrably does not strip legitimate process-context
stamps), and a warning that the law must stay scoped to **generate**; the blanket
generalisation would be refuted by Earlgrey's own golden.

### F4 — RESIDUE R2 **SEPARATED** (the implementer declared it not separated; the "module-local" hypothesis is REFUTED)

The implementer honestly flagged R2 as confounded: `a1_argts`'s `mf39(in39)` is
**both** module-local **and** operation-nested, and named the two missing cells. I
built them (`v1_r2sep.sv`, shipped in the verified patch) as a clean 2×2:

| cell | shape | golden | ours | verdict |
|---|---|---|---|---|
| A | pkg fn, **whole RHS** | **1** | 1 | agree |
| B | pkg fn, **operation-nested** | **0** | 1 | **SURPLUS** |
| C | module-local fn, **whole RHS** | **1** | 1 | agree |
| D | module-local fn, **operation-nested** | **0** | 1 | **SURPLUS** |

**The discriminator is OPERATION-NESTING, not callee locality.** Golden stamps a
cont-assign call actual when the call **is** the whole RHS (pkg *and*
module-local alike) and bares it when the call is **nested inside an operation**
(pkg *and* module-local alike). The implementer's suspicion that module-locality
mattered is **refuted**; the axis they could not separate is now separated. This
also explains golden's `module_inst/cont_assign/func_call` split of 57 bare / 28
stamped.

R2's real law is therefore: *a cont-assign call actual carries no formal typespec
when the call is operation-nested.* It is a **different site** from this pass's
(the process path), so it is correctly left to a future pass.

### F5 — the fence's filter is narrower than the law, with no effect here

`cenpred39.sh`'s regex matches `gen_if|gen_if_else|gen_case` followed by a
process, so a **gen-for-BODY-only** def-view process would escape the fence. The
law does cover it (arm cell `g1`, MOVED). My broader re-run (F3) shows golden 0
stamped on the wider population too, so **the fence did not under-count on
Earlgrey**; recorded so the filter is widened if a design with gen-for-body
processes is targeted.

### F6 — ops note (mine, not the implementer's)

My first Earlgrey reading was taken while `uhdm-dump` was still writing and gave
a nonsense `+86 178` line delta. Re-read after process exit: `−126`. This is
exactly the trap the harness header comments warn about; recorded because a
verifier publishing that first number would have been badly wrong.

---

## 6. RANKED RESIDUES (verifier's ranking)

1. **R1 — the next head on this row, decoded and witnessed.**
   `prim_prince.sv:105-106` def-view gen **cont-assign**: golden builds
   `var_select` + `vpiIndex ref_obj k` + `vpiIndex part_select`; we emit one
   `ref_obj` whose `vpiName` is the whole written text. Witness
   `r1_nexthead.cmp` verified byte-identical to my measurement. Fix belongs in
   `emitSyntaxExpr`'s select path.
2. **R2 — NOW SEPARATED (F4).** Operation-nested cont-assign call actuals take no
   formal typespec. Population is real (golden 57 bare / 28 stamped). Ready to
   implement with `v1_r2sep.sv` as its arm.
3. **R4 — the memoising-getter trap is a CLASS of defect** and is `cmp`-invisible
   (`ref_obj::Compare` never compares `VpiFullName`). Confirmed in the UHDM
   generator. Every `VpiFullName()` read that precedes parenting should be
   audited; this pass repaired 14 instances as a side effect.
4. **R3 — earl38's R3 is a different family, REFUTED as this one.** Its surplus
   hangs on a `parameter` object (`work@fence38.gen_f1.gen_f1a.F1A_U`), not a
   call argument; `a2_fence` is byte-identical before and after. Correctly left open.
5. **R5 — design-wide typespec-ref deficit** (~3100 on Earlgrey), the reason a
   few shapes read AWAY in msdist while the whole-design delta still closes.
6. **R6 — the u2r corpus has ZERO population for this law** (0/1358 movers). Its
   green is a fence, not a confirmation. Correctly stated by the implementer.
7. **New — golden-only `param_assign` row** at `190:44` in the arm, absent from
   both our sides in both binaries. Pre-existing missing object, unrelated to
   this pass.

---

## 7. WHAT I COULD NOT BREAK

I attempted to falsify the law on four fronts and failed on all four: a broader
census filter (F3) still gives golden 0 stamps under generate; the ELAB twins are
byte-unchanged at the identical span (`84:25`); the cont-assign controls (`g6`,
`m2`, `g6e`) do not move; and the two legitimate golden process-context stamps in
Earlgrey survive the patch untouched. The one-conjunct change does exactly what
it says and nothing else.

**VERDICT: PASS.** The 17-line head on `Earlgrey_0_1/default` is cleared, the
grid is cell-for-cell to golden parity, all five gates are green on independently
built binaries, the two boundary arms hold byte-for-byte, and the two reporting
errors found (F1, F2) are a mis-attributed flake and a conservative undercount —
neither changes the result.
