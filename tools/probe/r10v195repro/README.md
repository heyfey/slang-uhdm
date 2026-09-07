# r10v195 — adversarial verification of r10uvm195 (§ `cloneTfOwnVarListingIsUnbound195`) — **ACCEPT WITH FIX**

**MEASUREMENT-ONLY probes.** Nothing here is an acceptance judge. The official
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities. slang was **NOT** patched; `results/*.csv` were **READ
ONLY** and **NOT EDITED**; `GOLDEN_DEFER` stayed unset; the four slang-fenced
tests were never dispatched and are named nowhere in this directory.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `c3e022a3` |
| pristine | `4a42bc7a0018bc97d6d57ceebe1a0a9d` — rebuilt from a fresh `c3e022a3` worktree by the verifier, **byte-identical** to the implementer's and to the main tree's |
| implementer's patched | `19a1a55b008635113366cdd8b93375ff` — rebuilt by the verifier from `/tmp/r10uvm195.patch`, **byte-identical** to the implementer's |
| verified | `1b5bf424b2c8674a6c730e16f212b3de` — the patch with ONE pass moved past `cloneStmtHomeVarRef17()` |
| all three | frozen `chmod 555` before any sweep |

---

## 1. VERDICT

**ACCEPT WITH FIX.** The law is right, the decode is right, the head clears, and
every headline number reproduced bit-for-bit on binaries the verifier built.
One defect: the pass ran **one pass too early**, which silently switched off
§ `cloneStmtHomeVarRef17` for exactly the variables it touches and left **34
self-referential `ref_var`s per moving row-mode** in SeqDriver and MiniAmiq
where golden and the pristine binary both bind the **elaborated home**
declaration. Fixed by moving the block after `cloneStmtHomeVarRef17()`; nothing
else changed. `FINDING.selfcycle.r10v195.txt` carries the proof.

---

## 2. REPRODUCED BIT-FOR-BIT (verifier's own binaries, own sweeps)

* both binaries rebuilt; both md5s **match the implementer's exactly**.
* goldens: pristine **23 PASS / 0 FAIL**, patched **23/0**, verified **23/0**,
  `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**.
* `ct8rows`, patched **and** verified, against the committed baselines **and**
  the verifier's own pristine sweep: **PASS on all six comparisons** (u2r
  testflags, u2r default, surelog `--mode both`, 1588 rows, status AND dump).
  **No row converted in either direction.**
* byte movers, patched **and** verified, vs the verifier's own pristine sweep:
  **surelog 4 / 956** (`SeqDriver` ×2, `MiniAmiq` ×2 — the predicted set;
  Scoreboard/default did not flip its coin in these runs), **u2r 0 / 1358**,
  `PATH_SETS_IDENTICAL` both corpora.
* binary audit: **0** of the 3035 `cmds.txt` files in each sweep name the
  main-tree binary; 2981 name the frozen binary, and the other 54 are the rows
  whose slang side never runs — the same 54 on every binary.
* rowheads on the verified binary: SeqDriver ×2 and MiniAmiq ×2 **29/1 → 198/1**,
  and the 198-line head log is **byte-identical to the implementer's**
  `head_pat_SeqDriver.default.cmp`. SimpleUVM ×2 664681/1, Scoreboard/default
  95/1, Earlgrey_0_1/default 31/1 unchanged; **BuildUVMPkg ×2, Earlgrey_0_1/
  testflags and Rggen/default STAY `CMP_EQUAL` (0 lines, 0 heads)**.
* canaries on the verified binary: surelog `ok=52 changed=0 absent=0`, u2r
  `ok=8 changed=0 absent=0`, both `ctcan2` **PASS**, `canaudit` **audited=29
  UNCOVERED=0 FENCE-BREACH=0**; `InterfaceModPort` ×2 / `BlackParrotComplex` ×2
  / `YosysOldOr` ×2 **SAME**, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`.
* census, re-derived with a scorer that reports **MOVED-WRONG separately**
  (the implementer's `score195.py` prints it merged into `MOVED/STILL-WRONG`,
  so a cell made wrong a *different* way would not appear in its summary):
  golden-vs-golden calibration **AGREE = KEYS, every other column 0** on all
  seven measured row-modes; **TO-GOLDEN 17 / AWAY-GOLDEN 0 / MOVED-WRONG 0** on
  SeqDriver ×2 and MiniAmiq ×2, **0 / 0 / 0** on SimpleUVM, BuildUVMPkg and
  Scoreboard — identical for the patched and the verified binary.
* the implementer's five grid arms, re-run against fresh Surelog goldens in
  both views: **TO-GOLDEN 8 / 4 / 8 / 0 / 1 per view = 42 over both views,
  AWAY-GOLDEN 0, MOVED-WRONG 0**, arm E `29/1 → 0/0 CMP_EQUAL`, arm D
  byte-identical on every binary in both views. All reproduced.
* WIDE BOUNDARY, pristine vs **verified**, every `.sv`/`.v` under a copy of
  `tools/probe`, both views:
  `LISTED=5185 PROCESSED=5185 PRODUCED_DBS=10032 MOVED_CELLS=12 RC_DIFFS=0`,
  **MOVED_ARMS=6** — the same six arms the implementer reports for pristine vs
  patched (the pass's own four, `r10v105repro/v105_b5.sv`,
  `r10v179repro/v179_f_nomod.sv`). **The fix moves no additional arm.** Both
  earlier-pass arms rescored against their own real goldens on all three
  binaries: `v179_f_nomod` **29/1 → 0/0 `CMP_EQUAL`, TO-GOLDEN 2 / 0 / 0** and
  `v105_b5` **TO-GOLDEN 1 / 0 / 0**, identical patched and verified.

---

## 3. THE DEFECT (full proof in `FINDING.selfcycle.r10v195.txt`)

`§ pkgCloneLocalRefBind37`'s `bind9(o37, o37)` binds a clone body `ref_var` to
the clone's OWN listing object — to itself. `§ cloneStmtHomeVarRef17`
(`src/TypeEmit.cpp:8285`) is what repairs that, keying a clone's variables by
declaration site `"name@line:col"` and refusing an ambiguous key
(`ow.dup`, `:8313-8319`, `:8375-8376`). The twin § 195 mints carries the SAME
name, line and column, so a twin minted **before** § 17 puts two objects under
one key, § 17 skips the remap, and the self-reference survives.

Measured, on the head's own object (`ct195list`, SeqDriver/default):

```
GOLDEN  adpcm_pkg /begin/task:uvm_root::run_test  actual -> #16195  (uvm_pkg HOME)
PRIS    adpcm_pkg /begin/task:uvm_root::run_test  actual -> #96774  (uvm_pkg HOME)
PAT     adpcm_pkg /begin/task:uvm_root::run_test  actual -> ITSELF          <<<
FIX     adpcm_pkg /begin/task:uvm_root::run_test  actual -> #96774  (uvm_pkg HOME)
```

whole-database (`ct195selfall`, `ref_var` / bound / SELF):

```
SeqDriver/default   GOLDEN 2980/886/0   PRIS 2944/882/0   PAT 2978/882/34   FIX 2978/882/0
MiniAmiq/default    GOLDEN    -         PRIS 3152/882/0   PAT 3186/882/34   FIX 3186/882/0
```

Neither guard instrument could see it. `uhdm-cmp` walks into the cycle and its
visited set short-circuits the compare — which is worse than blindness: on
`v195_c_chain.sv` the implementer's binary reports **0 cmp lines** while the
verified binary reports the 29-line `RHS: <null>` head that is really there.
The pass's census payload is the actual's `<kind>:<name>@<span>`, and the
clone's own object and the home's share all three, so the join reads **AGREE**
on all 34 cells (`score195v.py` patched-vs-verified: AGREE on every key, every
arm, both views).

**The fix**: move the § 195 block to run after `cloneStmtHomeVarRef17();`,
carrying `pkgCloneBodyLocals9.clear()` with it, keeping the
`if (!pkgCloneBodyLocals9.empty())` guard. No logic change. The self-cycles go
to 0 on every arm and both corpus rows, the head still clears to the same
198-line object, and every gate above stays green.

Also corrected: the two RESUME.md §3b table rows the patch rewrites had lost
their trailing `|`, which breaks the markdown table.

---

## 4. THE ARMS (`v195_*.sv`, `grid3.sh`, `grid195v.sh`, `score195v.py`)

`grid3.sh` compiles ONE REAL SURELOG GOLDEN and **three** binaries (pristine,
implementer's, verified) in BOTH views, echoes every command with its binary
path and its rc, and reports each database's SELF count beside its cmp line and
head counts. `score195v.py` is the implementer's multiset join with MOVED-WRONG
split out of STILL-WRONG.

| arm | face | result |
|---|---|---|
| `v195_a_explicit.sv` | **EXPLICIT** `import P::f;` of a free function and of a task **into a package**. Surelog clones on `inPackage` ALONE (`CompileHelper.cpp:315-327`); `object_name` only FILTERS which member is imported — so this is the same production as the wildcard one. The implementer's arm D imports a **class**, so its `task_func` loop skips every subroutine and the face is untested there. | **residue, not a regression**: 29 cmp lines / 1 head, identical on all three binaries; golden binds the clone body entries (`ACT=ref_var:tr_p195v@10:13`) and we leave them null. Neither § 37 nor § 195 covers it, because both are gated on `pkgImportCloneEmit`, which is WILDCARD-only. **R1 below.** |
| `v195_b_reads.sv` | ordinary locals (`int`, `string`) that golden lists and MUST stay listed; an **initialized** process local (`process p = null;`); a `semaphore`; process locals **written and READ in the body**; a function with a return value | **def 29/1 → 0/0 `CMP_EQUAL`**, TO-GOLDEN 4 / 0 / 0 both views, ordinary locals AGREE on every binary. Patched SELF=8, verified SELF=0, golden SELF=0. The body references keep binding the home. |
| `v195_c_chain.sv` | **CHAINED** wildcard import (a clone of a clone: `river195v` imports `brook195v::*` which imports `spring195v::*`), three importers of one home, three process locals in one subroutine | TO-GOLDEN 15 (def) / 20 (elab), AWAY 0, MOVED-WRONG 0 on both binaries. **This is the arm that convicts the self-cycle**: patched 0 cmp lines with SELF=30, verified 29 cmp lines with SELF=0 — the implementer's binary was not equal, it was *masked*. The exposed head is a `ref_typespec` deficit shared by both binaries (golden 198 dump mentions, ours 102, pristine 72). **R2 below.** |
| `v195_d_tfitem.sv` | the § 139 TF-ITEM faces: `function automatic`/`static` with no parens, a task with a **body io declaration**, a **named** begin and a **nested** begin at function level, a subroutine whose only local is the process | **def 31/1 → 0/0 `CMP_EQUAL`**, TO-GOLDEN 6 / 0 / 0 both views. The paren-less shapes take the **in-place** branch (no twin minted, `SELF` never rises there); the nested/named-begin shapes take the twin branch. Patched SELF=4, verified SELF=0. |
| `v195_e_nonpkg.sv` | a **module**, a **program** and an **interface** wildcard-importing the same package — Surelog pushes the HOME object (`sfuncs->push_back(func)`, `:326`), so nothing this law owns may move | **byte-identical outcome on all three binaries** (417 cmp lines / 1 head in def, 421 in elab — a pre-existing residue of `process` locals in a module `initial`, present on the PRISTINE binary too), TO-GOLDEN 0, AWAY 0, MOVED-WRONG 0, SELF 0 everywhere. |

---

## 5. RESIDUES THE VERIFICATION ADDS

**R1 — the law is narrower than its producer.** `importPackage` clones on
`inPackage`, not on wildcard-ness, so `import P::f;` into a package is the same
clone. Ours is gated on `pkgImportCloneEmit` (wildcard only), so both § 37's
body binding and § 195's omission miss it: `v195_a_explicit.sv` shows golden
binding two clone body entries we leave null, 29 cmp lines, on every binary.
Corpus incidence is zero today (the movers are all `adpcm_pkg`), which is why
no row moves — but the next design that writes an explicit package-to-package
subroutine import walks into it.

**R2 — the twin has no `ref_typespec` of its own.** `*tw = *rv` copies the
`Typespec()` pointer, so golden's separate `ref_typespec` per listing entry
becomes one object shared by two parents. Not compare-visible today (no
generated `Compare` reads `VpiParent`, and both sides reach the same
`Actual_typespec`), and shared by the implementer's and the verified binary
alike — but on `v195_c_chain.sv` golden shows 198 `ref_typespec` dump mentions
against our 102, and that arm's remaining head is `RHS: <null>`.

**R3 — instrument debt, and it is the reusable lesson.** Two of this pass's
three guards were structurally unable to see a wrong `vpiActual` *target*: a
census payload of `<kind>:<name>@<span>` cannot separate a clone's own object
from its home (same three), and `uhdm-cmp` cannot separate a self-cycle from a
correct binding (the visited set stops the walk). Any future law that rewrites
a `vpiActual` should carry an identity-level probe — `ct195self` /
`ct195selfall` here — beside the census.

---

## 6. FILES

* `FINDING.selfcycle.r10v195.txt` — the defect, its mechanism, and the fix.
* `v195_a_explicit.sv`, `v195_b_reads.sv`, `v195_c_chain.sv`,
  `v195_d_tfitem.sv`, `v195_e_nonpkg.sv` — the adversarial arms.
* `grid3.sh` — golden × pristine × patched × verified, both views, rc-recorded,
  SELF counted per database. `grid195v.sh` — the two-binary form.
* `score195v.py` — the multiset join with MOVED-WRONG split out.
* `ct195self.cpp` — every `ref_var` of a NAME with its `vpiActual` identity and
  a `SELF=` verdict. `ct195selfall.cpp` — the whole-database SELF census.
* `boundary195v.sh` — the wide boundary (fd-3 file list, children `</dev/null`,
  scratch keyed on the RELATIVE path, PROCESSED asserted, every rc recorded).
* `GATES.r10v195.txt` — the gate transcript.
