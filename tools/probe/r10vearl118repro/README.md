# r10earl118 — ADVERSARIAL VERIFIER — **ACCEPT WITH FIX**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY** and nothing was
promoted; **NO corpus row converted in either direction** and both
`Earlgrey_0_1` rows and both `BuildUVMPkg` rows are quoted verbatim in
`GATES.r10vearl118.txt`.  `GOLDEN_DEFER` stayed unset.  The four slang-fenced
tests were never dispatched and are named only inside `canaudit.sh`'s own
`FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `c3e022a3`, verifier worktrees `/tmp/wt_vearl118` (patched→fixed), `/tmp/wt_vearl118pris` (clean), `/tmp/wt_vearl118nf` (the cut) |
| pristine binary | md5 `4a42bc7a0018bc97d6d57ceebe1a0a9d` — built by the verifier from a clean `c3e022a3` worktree, **byte-identical to the main tree's build** |
| implementer's patched binary | md5 `726b1d9e36054ae5bd68799d77c6c43b` — **REPRODUCED bit-for-bit** by applying `/tmp/r10earl118.patch` to a fresh `c3e022a3` and rebuilding |
| **VERIFIED binary (SHIPPED)** | md5 **`a32df35b524071be0685e1d5acf983c5`** — the implementer's patch with the fence widened (§2), frozen `chmod 555` before any sweep |
| NO-FENCE cut | md5 `1afae577863016698b0e548df314cbba` — **the implementer's third binary md5, REPRODUCED**: removing the whole namesake walk from the fixed source and from the submitted source yields the SAME binary, which is itself proof that the fix touches the fence and nothing else |
| verdict | **ACCEPT WITH FIX.**  The law, the head, the decode and every headline number reproduce.  One face broke: a namesake in an ENCLOSING GENERATE scope (§2).  Fixed, gated, shipped as `/tmp/r10earl118.verified.patch` |

---

## 1. What reproduced, number for number

Every number below was re-measured by the verifier on its own binaries and its
own sweep workdirs (`/tmp/vearl118_wd/{pris,pat,fix}_{sl,u2r}`), never on the
implementer's artifacts.

* **The head.**  Earlgrey_0_1/default: pristine head is `LHS: <null>` /
  `RHS: logic_var (work@top_earlgrey.u_pinmux.gen_mio_periph_in[0].data_mux)` —
  golden has NO actual and we emit one.  After the patch **the head object is
  GONE** and the new head is the folded `constant` (`vpiDecompile:63`,
  `UINT:63`, `vpiSize:8`) against our unfolded cast `operation` at
  `padctrl.sv:39:24` — the implementer's R0, verbatim.  `rowheads.sh`:
  31 lines/1 head → 56 lines/1 head, every other named row byte-identical,
  `Earlgrey_0_1/testflags` 0 lines **rc=0** before and after.
  (`HEAD_BEFORE_*.cmp`, `HEAD_AFTER_*.cmp`.)
* **The framing correction stands.**  The failing field is
  `cont_assign::Lhs → ref_obj::Actual_group` — the SINGULAR `SafeCompare`, ours
  non-null against golden's null.  Golden's default database *does* hold the
  `logic_var`; only the pointer is absent.  Confirmed independently: the
  Earlgrey `logic_var` NAME population is **12671 on both binaries, diff 0**
  (`POPULATION_Earlgrey.r10vearl118.txt`), and on arm `a1_bind118` golden,
  pristine and patched each hold **37** unique `logic_var` names.
* **Rows.**  0 differing rows of 1588 surelog and of 731+731 u2r, whole row
  including the dump column, against the committed baselines AND pristine-vs-
  patched AND pristine-vs-fixed.  Status histograms identical
  (`940/16/10/3/1/567/48/1/2` surelog, `679/50/2` u2r).  **No conversion.**
* **Byte movers.**  surelog **3 / 956** and u2r **0 / 1358**, all three
  attributed order-blind (`ATTRIB_MOVERS.r10vearl118.txt`):
  `default/Earlgrey_0_1` = **256 lines, exactly 128 × `|vpiActual:` + 128 ×
  `\_logic_var:`, ZERO added lines** — the law's cells and nothing else;
  `testflags/Earlgrey_0_1` = **0 dump lines** (arena order only);
  `default/Scoreboard` = raw 170 / **order-blind 0**, the documented COIN.
* **Gates.**  goldens 23/0 on all three binaries, `/bin/false` 0/23; **9105**
  `cmds.txt` (six workdirs: 1573 surelog + 1462 u2r each) audited by binary
  PATH, each naming its own frozen binary and **0** naming the main-tree
  binary; canaries `ok=52` / `ok=8`, changed=0; ctcan2 PASS ×2; canaudit
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`; `SVSwitch 4842211c4030`,
  `YosysVerx 6ccda350c24a`, the three canary databases byte-identical.
* **R2, the pre-existing SEGFAULT, reproduced.**  `a4_procsegv118.sv.txt`
  extracted and run: rc **139** under `--elabuhdm` and rc 4 without, on
  **pristine, patched and fixed alike**.  Not this pass's, and not cured by it.

---

## 2. THE BREAK — a namesake in an ENCLOSING GENERATE scope

The submitted fence walks the enclosing scopes for a namesake and **skips
generate blocks**, on the model that `bindVariable`
(`Surelog/src/DesignCompile/CompileStmt.cpp:3089-3151`) knows
function/task/begin/module_inst only.  That model is incomplete: `:2165` is only
ONE of the two ways a target keeps an actual.  The other is the clone leg
itself — `ref_obj::DeepCopy`
(`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:104-110`) runs
`bindAny(VpiName())` on the clone, and **that** name walk sees every ENCLOSING
scope, generate blocks included, while still not seeing the assigning scope's
own local.

Arm `v4_ancname.sv`, one generate block per row, every row an own-scope
generate-local target with a CAST Rhs, scored against the GOLDEN database:

| row | shape | GOLDEN | pristine | submitted patch | verdict then |
|---|---|---|---|---|---|
| `a_var` | namesake one gen level UP | **binds** `ab[0].a_var` | binds | `<null>` | **AWAY-GOLDEN** |
| `e_late` | same, ancestor declared textually LATER | **binds** | binds | `<null>` | **AWAY-GOLDEN** |
| `f_deep` | namesake TWO gen levels up | **binds** | binds | `<null>` | **AWAY-GOLDEN** |
| `b_net` | ancestor namesake is a NET | **binds** the net | binds a var | `<null>` | **MOVED-WRONG** |
| `d_sib` | namesake in a SIBLING gen block | `<null>` | binds | `<null>` | TO-GOLDEN |
| `a_free` | no namesake anywhere | `<null>` | binds | `<null>` | TO-GOLDEN |

and the same break in `v2_fenceface.sv` (`anc_ns`, two gen levels).  The
official judge agrees: on `v2_fenceface` the submitted binary's cmp head *is*
`LHS: logic_var (work@v2_fenceface.ob[0].anc_ns)` — golden holds an actual we
had just removed.  Golden's own dump names the bound object:

```
\_ref_obj: (work@v4_ancname.ab[0].an.a_var), line:19:14, endln:19:19
  |vpiActual:
  \_logic_var: (work@v4_ancname.ab[0].a_var), line:15:17, endln:15:22
```

**THE FIX** (`src/ModuleEmit.cpp`, inside the same fence, no new call sites):
the walk skips **only the assigning scope itself** and reads every enclosing
scope, generate blocks included —

```c++
-   if (qs118.kind != SymbolKind::GenerateBlock &&
-       qs118.kind != SymbolKind::GenerateBlockArray)
+   if (q != static_cast<const Scope*>(&blk))
        if (const Symbol* hit118 = q->find(nm118)) { ... }
```

A sibling generate block is not on that chain, so `d_sib` stays suppressed.
Widening a fence can only ever restore PRISTINE behaviour, so it introduces no
new risk of its own — and it introduces none in fact: **the fixed binary's
databases are byte-identical to the submitted patch's across all 956 surelog
and all 1358 u2r databases** (`byteverify` MOVERS 0/956, 0/1358), the head
still clears with the same successor head, and `Earlgrey_0_1/testflags` still
compares rc=0.

**The fence is load-bearing, and more so than the pass claimed.**  The NO-FENCE
cut re-scored on `a3_fence118` + `v2_fenceface` + `v4_ancname`
(`NOFENCE.r10vearl118.txt`): **AWAY-GOLDEN 7, MOVED-WRONG 3** (the submitted
narrow fence: 3 and 1; the fixed fence: **0 and 0**).

---

## 3. The arm grid — 7 arms × 2 views × golden + 2 binaries

`GRID_FIXED.r10vearl118.txt` (fixed binary, all seven arms, 214 cells):

```
TO-GOLDEN 30   AWAY-GOLDEN 0   MOVED-WRONG 0   SAME_AGREE 168   STILL-WRONG 6
```

Every ELABORATED cell is `SAME_AGREE`: the clone's `bindAny` re-binds on both
sides under `--elabuhdm`, so the law needs no mode flag — the implementer's
claim, re-measured.  `GRID_PATCHED.r10vearl118.txt` is the same grid on the
submitted binary (its own three arms: TO-GOLDEN 11, AWAY 0, STILL-WRONG 1 —
reproduced exactly), and `GRID_V4_PATCHED.r10vearl118.txt` is where it breaks.

The verifier's arms and what each was built to break:

| arm | faces |
|---|---|
| `v1_castform.sv` | CAST FORMS whose Surelog `operation` might carry no `Typespec`, so the clone leg never runs and golden would KEEP the binding: `signed'`/`unsigned'` sign casts, a PARAMETER-width cast, a packed-STRUCT cast, an ENUM cast, a cast that FOLDS, a cast of a bare ref, of a part-select, a 1-bit cast, a cast UNDER a ternary, a cast as an OPERAND, `$signed` inside a cast, and a non-cast control |
| `v2_fenceface.sv` | every namesake kind `bindVariable` can and cannot see — module-body VAR and NET, a PORT, a PARAMETER, a LOCALPARAM, a TYPEDEF, an ANCESTOR GEN scope, the PARENT INSTANCE's body, and no namesake at all — inside a child instance and two generate levels deep |
| `v3_shape.sv` | generate SHAPES: an UNNAMED if-generate, a CASE-generate, a module INSTANTIATED inside a generate scope, an unpacked-array element target, three generate levels, and a module-body target of a gen-instantiated module |
| `v4_ancname.sv` | the ANCESTOR-GENERATE namesake matrix that broke the patch (§2) |

Sign casts (`c1`, `c2`) and casts that are not the Rhs's top operation (`c9`,
`c10`) are `SAME_AGREE` — golden binds them and the flag does not fire, so the
`vpiCastOp` test is exactly as wide as golden is.  Every other cast form scores
TO-GOLDEN, including the ENUM, packed-STRUCT and PARAMETER-width spellings the
implementer never tried.

The six residual `STILL-WRONG` cells are pre-existing on BOTH binaries and are
listed as residues in §5.

---

## 4. The wide boundary — 5187 files, and the earlier passes re-scored

`widerun118.sh` over a copy of `tools/probe` at any depth (the pass's 5183
files plus this directory's four arms), both views, fixed vs pristine:

```
PROCESSED=5187 identical=9954 DIFFERING=26 no_output=394     PROCESSED==LISTED
rc per side IDENTICAL:  0:9587  3:378  4:393  139:16   (A=fixed, B=pristine)
```

The 16 rc=139 SIGNAL cells appear on BOTH sides — pre-existing, not this pass's.
Sectioned at the `weaklyReferenced` marker
(`BOUNDARY_SECTIONED.r10vearl118.txt`): the **7 elaborated-view** differences
have **reachable=0** (tail only, unreachable to the judge), and the **19
plain-view** differences are **242 reachable lines, every one of them PRESENT
IN PRISTINE ONLY** — a removed `|vpiActual:` and the object it pointed at,
**0 lines added**.

All 19 differing files re-scored against GOLDEN
(`BOUNDARY_ARMS.r10vearl118.txt`): **TO-GOLDEN 53, AWAY-GOLDEN 0,
MOVED-WRONG 0**.  That includes twelve EARLIER passes' arms — r10earl97's
`g3_home97`, r10earl104's `g5_gscope104`, five of r10earl105's, r10earl106's
`g1_home106`, r10earl_repro's `pf19`, r10v123's `v123_f_multi`, r10vearl106's
`va7_mix106`, r10vearl113's `v3_lhs113` — each of which was wrong on the
pristine binary all along and is now right.  earl110–117's arms and fences are
untouched (they never enter the differing set).

---

## 5. Residues, ranked

* **R0 (unchanged, the next head)** — Earlgrey/default at `padctrl.sv:39:24`:
  golden folds the cast to a `constant` (`vpiDecompile:63`, `UINT:63`,
  `vpiSize:8`) where we keep the `operation` (`vpiOpType:67`).  That is
  `writeCont_assign`'s `reduceExpr → adjustSize` leg
  (`UhdmWriter.cpp:2255-2278`) in the NON-elaborated view.
* **R1 (unchanged)** — the unsized-constant clone leg (`assign s1 = din ^ '1;`,
  `DetectUnsizedConstant` at `UhdmWriter.cpp:2286+`) is golden-unbound too and
  we still bind it.  Measured on `a2_bind118`, no corpus population.
* **R2 (unchanged)** — the pre-existing `--elabuhdm` SEGFAULT on a generate-
  scope PROCESS casting `$bits(<its own target>)`, rc 139 on all three
  binaries.  It reaches the harness as a `SLANG_REJECT` wearing a warning.
* **R3 (NEW, verifier)** — **identity, not presence**: where an ancestor
  namesake exists, golden binds the ref to the ANCESTOR's object and we bind it
  to the own-scope one (`v2_fenceface` `net_ns`/`prt_ns`, `v4_ancname` `b_net`
  — golden a `logic_net`, ours a `logic_var`).  Pre-existing on the pristine
  binary, invisible in both corpora, and a kind-level difference the judge DOES
  read.  Whoever takes the next generate-scope binding pass should take it.
* **R4 (NEW, verifier)** — a generate-local target whose name shadows an
  enclosing LOCALPARAM: golden replaces the assign's whole LHS with a folded
  `constant` and we emit a `ref_obj` (`v4_ancname` `c_par`).  A fold family, not
  a binding family; wrong on both binaries.
* **R5** — the widened walk also reads `$unit` / package scopes, which
  `bindAny` may not; a gen-local named after a `$unit` variable would keep a
  binding golden might drop.  No corpus population (0 movers), no arm found; a
  missed fix at worst, never a regression, since lifting the fence only
  restores pristine behaviour.

---

## 6. What is in this directory

| file | what it is |
|---|---|
| `v1_castform.sv` `v2_fenceface.sv` `v3_shape.sv` `v4_ancname.sv` | the verifier's four arms (§3) |
| `GRID_PATCHED.r10vearl118.txt` | the implementer's three arms on the SUBMITTED binary — reproduced exactly |
| `GRID_VERIFIER_ARMS_PATCHED.r10vearl118.txt` `GRID_V4_PATCHED.r10vearl118.txt` | the verifier's arms on the SUBMITTED binary — where AWAY-GOLDEN 3 / MOVED-WRONG 1 appear |
| `GRID_FIXED.r10vearl118.txt` | all seven arms on the SHIPPED binary — AWAY 0, MOVED-WRONG 0 |
| `NOFENCE.r10vearl118.txt` | the NO-FENCE cut on the fence arms — AWAY 7, MOVED-WRONG 3 |
| `GATES.r10vearl118.txt` | the whole landing battery, re-run: binaries, goldens, cmds audit, rows, histograms, movers, canaries, protected DBs, wide boundary |
| `ATTRIB_Earlgrey_default.r10vearl118.diff` `ATTRIB_MOVERS.r10vearl118.txt` | the three byte movers, attributed order-blind |
| `POPULATION_Earlgrey.r10vearl118.txt` | the Earlgrey `logic_var` NAME population, pristine vs fixed (12671 = 12671, diff 0) |
| `HEAD_BEFORE_*.cmp` `HEAD_AFTER_*.cmp` | the Earlgrey/default head, before and after |
| `BOUNDARY_WIDE.*` `BOUNDARY_SECTIONED.*` `BOUNDARY_ARMS.*` | the wide boundary: tally, rc by side, diff list, signals, the sectioned reachable/tail split, the golden re-scoring |
| `grid118.sh` `cen118.cpp` `wide118.sh` `widerun118.sh` | the pass's instruments, re-run unmodified by the verifier |
| `attrib_v118.sh` | the order-blind mover attribution driver (`WD=`/`A=`/`B=` parameterised) |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | the gate scripts this verification RAN, carried so the audit passes here |
