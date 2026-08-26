# r10v156 — ADVERSARIAL VERIFICATION of r10uvm156
### § `classHandleRetTsNameUnlessSameHomeComponent156`

**VERDICT: ACCEPT AS SHIPPED.** Base `edf82ef`. Every headline number of the
implementer's report was reproduced **bit-for-bit** from independently built
binaries, and no pristine-right → patched-wrong cell was found on any legal SV
this verifier could construct. No production line was changed; there is no
`.verified.patch`.

LHS is ALWAYS golden (Surelog). The judge is
`~/git-repos/UHDM/build/bin/uhdm-cmp` and nothing else; everything here is
measurement-only. `results/*.csv` were READ ONLY; no row was converted; the
four slang-fenced tests were never dispatched and are not spelled in any
driver in this directory.

---

## 1. Independent reproduction

Two fresh worktrees at `edf82ef`, both configured and built `-j 2`, md5 taken
separately, both frozen `chmod 555` before any sweep:

| binary | md5 | implementer's claim |
|---|---|---|
| pristine `edf82ef` | `204e3c3e9ce9cdacf386d387be11a247` | same |
| patched (`/tmp/r10uvm156.patch`, md5 `48f6f1d541446de4de7fa99fc2c1c692`) | `481c1f103e6dc360c6dfc242a24f30e6` | same |

The patch applies clean on a fresh `edf82ef` (`git apply -v`, rc 0, every hunk
reported); surface is `src/TaskFuncEmit.cpp` + `include/UhdmExporter.h` +
`tools/probe/r10uvm156repro/` only.

Reproduced independently, every number identical:

* **Heads** (`rowheads.sh` over this verifier's own sweeps): SeqDriver
  **22 → 17**, one `^LHS:`, both modes; SimpleUVM ×2 / Scoreboard / MiniAmiq ×2
  / BuildUVMPkg ×2 / Earlgrey ×2 head logs **byte-identical** to pristine.
  Every committed `head_pris_*.cmp` and `head_pat_*.cmp` reproduces
  character-for-character modulo object ids and the workdir path.
* **R0** confirmed verbatim: `ref_typespec (adpcm_pkg::adpcm_tx_seq)`, parent a
  `constant` at `162:24-162:34`, actual an `int_typespec` at `217:1-217:38`,
  `RHS: <null>`.
* **Predicate scored on golden itself**: `OK=5305 MISS=0`, fences
  `new=2875 builtin=9 alias=748` — exact.
* **Census** PART 0 (`SeqDriver/default` golden: return **855 anonymous /
  106 NAMED**, 9748 cells), PART 2 (WRONG→RIGHT 7+7+21+21+1 = **57**,
  **RIGHT→WRONG 0**, ONLY-OURS moved 0), PART 3 (**AWAY introduced = 0**; the
  one `AWAY(spelling)` cell per row-mode is `uvm_derived_callbacks`'s
  `this_super_type` PROPERTY at `34:9`, and it reads the SAME with the
  pristine database in the patched slot) — all exact.
* **Corpus**: `ct8rows` **0 differing rows** on both corpora in both modes,
  against the committed baselines *and* against this verifier's own pristine
  control CSVs, whole row (status **and** dump column). Per-mode status
  histograms identical to the implementer's record
  (default 471/283/25/10/5, testflags 466/284/23/9/5 + 3/2/1/1).
* **Movers**: predicted BY NAME from PRISTINE databases with a predictor
  written independently from the law as stated — **5 databases**
  (`{default,testflags}/SeqDriver-32af76aa`, `{default,testflags}/MiniAmiq-544c7f61`,
  `default/Scoreboard-59431470`), **0** in uhdm2rtlil. `byteverify SELFCHECK=1`
  then read **MOVERS 5 / 956** and **0 / 1358**, selfcheck 955/956 and
  1357/1358. Order-blind whole-dump attribution: the only kinds on every
  mover's diff are `class_typespec` and `|vpiName`, at
  `uvm_object_defines.svh:444:21 / 472:21 / 487:21`, `410:13`, and
  `svaunit_concurrent_assertion_info` `288:13`.
* **cmds.txt audit, file by file**: 1523 + 1523 + 1458 + 1458 binary
  references across the four workdirs, every one to the correct frozen binary.
  No main-tree binary anywhere.
* **Goldens** 23 PASS / 0 FAIL on BOTH binaries with `SLANG_UHDM` exported
  explicitly to each; `/bin/false` 0 PASS / 23 FAIL.
* **Canaries** `ok=52` / `ok=8`, `changed=0`; `ctcan2` PASS both;
  `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`. Protected databases
  byte-identical pristine↔patched: `InterfaceModPort`, `BlackParrotComplex`,
  `YosysOldOr`; `SVSwitch` pins `4842211c4030`, `YosysVerx` pins
  `6ccda350c24a`.
* **Wide boundary, re-run from a copy of the whole probe tree**:
  `LISTED=4407 PROCESSED=4407 PRODUCED_DBS=4260 MOVED_ARMS=33 RC_DIFFS=0` —
  the implementer's 29 movers exactly, plus this verifier's four new arms
  (the positive control that the gate can see). **All 33 moved arms were
  rebuilt against golden with Surelog in BOTH views and re-scored:
  RIGHT→WRONG 0, AWAY 0, MOVED-WRONG 0, 168 WRONG→RIGHT.**
* **Must-stay controls all byte-identical, both views**: `r10uvm153repro`,
  `r10v153repro`, `r10uvm140repro`, `r10v140repro`, `r10uvm98repro`,
  `r10v98repro`, `r10uvm97repro`, `r10v97repro`, `r10uvm139repro`,
  `r10earl96repro`, `r10vearl96repro`, `r10uvm112repro`, `r10uvm114repro`,
  `r10uvm146repro`, and the boundary-fenced `r10uvm89repro`,
  `r10uvm77/78/79repro`, `r10buvm14repro`, `r10uvm84/85repro` — **0 movers**.

---

## 2. THE ARMS THIS VERIFIER ADDED (faces the pass did not put to golden)

Run with `r10uvm156repro/arm156.sh` (Surelog + both frozen binaries, both
views) and scored with its `score156.py` / `away156.py`. **RIGHT→WRONG 0 and
AWAY 0 in all four arms × both views.**

### `v156_ifc.sv` — interface classes, a class in a GENERATE scope
* **A class declared inside a generate block, returned from a function in the
  SAME generate block** — golden leaves it **ANONYMOUS**, and so does the
  patch. `homeComp156`'s walk THROUGH the gen-scope to the module's
  `DefinitionSymbol` is the right answer, measured, not assumed.
* `interface class` — **Surelog rejects it** (`[ERR:CP0317] Undefined type`),
  so golden carries no cell there. Ours names it; unmeasurable, outside the
  comparable field, and the arm's cmp line count does not change.
* An ordinary class in a package returned from a far package: WRONG→RIGHT.

### `v156_fwd.sv` — forward declaration, typedef-of-typedef, specializations
* A **forward-declared** class (`typedef class Fwdv6;`) returned from the SAME
  package: golden anonymous, patched anonymous. From a FAR package: golden
  `Fwdv6`, patched `Fwdv6` (+ `vpiInstance` = the home package on the free
  function) — WRONG→RIGHT.
* A **typedef of a typedef** of a class: fence 3 holds, unchanged (R4).
* A **return typed by a TYPE PARAMETER** (`function U r_tp();`): unchanged,
  no name written — § 87 keeps its ground.
* `Parv6#(int)` / `Parv6#(bit)` — **one and two specializations**: same-package
  ones stay anonymous (golden agrees); the far-package one is named `Parv6`,
  which is golden's exact spelling (golden's span is the bare identifier,
  ours the whole `#(...)` — a PRE-EXISTING span residue, unchanged).

### `v156_scope.sv` — scoped spellings, derived virtual returns, `$unit`
* A **`$unit` free function** returning a `$unit` class: golden `Unitv6`,
  patched `Unitv6` — WRONG→RIGHT.
* A **virtual method return in a derived class**, a **static extern
  out-of-body**: unchanged, golden agrees.
* Scoped `pdv6::DerDv6` from another package, in a class method and in a free
  function: patched writes golden's name and golden's `vpiInstance` exactly.
* **THE COUNTEREXAMPLE — see §3.**

### `v156_shadow.sv` — a user class that SHADOWS a builtin name
`class process;` / `class semaphore;` in a package, returned across a package
boundary, run BOTH with `-nobuiltin` and with Surelog's builtins on. Not a
regression in either configuration: with builtins on the patched cmp is
**shorter** (26 → 22 lines) and the surviving head is a PRE-EXISTING
`vpiClassDefn` binding residue (Surelog binds the class-method return to
`builtin.sv`'s `work@process`, we bind it to the user's class) that § 156 does
not touch. `builtin.sv`'s own `process::self()` stays anonymous — fence 2
holds on both faces.

---

## 3. THE LAW IS FALSIFIED IN ONE CORNER (a missed cell, NOT a regression)

`v156_scope.sv:17` — a **package free function returning a class of its OWN
package written with the scope qualifier**:

```systemverilog
package pdv6;
  class DerDv6 extends BaseDv6; … endclass
  function pdv6::DerDv6 pf_same_scoped(); return null; endfunction   // line 17
  function DerDv6       pf_same_bare();   return null; endfunction   // line 18
endpackage
```

| line | written as | golden | pristine | patched |
|---|---|---|---|---|
| 17 | `pdv6::DerDv6` | **`pdv6::DerDv6`, `vpiInstance` = `pdv6`** | anonymous | **anonymous** |
| 18 | `DerDv6` | anonymous | anonymous | anonymous |

The law says "same home component ⇒ anonymous" and answers line 17 anonymous.
Golden **names** it. The implementer's own decode already contains the reason:
a **scoped** name is a `paClass_scope` node handled at `CompileType.cpp:1524`
and never reaches the `slStringConst` switch where arm B lives, so a scoped
return type can never be claimed by `design->getClassDefinition` — it is
**always NAMED**, home or no home. Three independent measurements agree:
`g156_a_mech:51` (`ph156::sib156`, far package, NAMED), `v156_scope:23/25`
(`pdv6::DerDv6`, far package, NAMED), and `v156_scope:17` (same package,
still NAMED).

**This is a STILL-WRONG cell, not a RIGHT→WRONG one** — pristine leaves it
anonymous too — so it is a residue, not a defect in the patch.

**Corpus incidence: ZERO.** Over the nine UVM row-mode goldens, the count of
non-constructor, non-alias-named class-handle return cells that golden names
with a scoped spelling while `dhome == ohome` is **0** (the only same-home
scoped names golden writes are the 28–32 implicit-constructor cells per
database, which are fenced out of this law and are residue R1). The fix — test
the written spelling for `::` BEFORE the home test — is a two-line change with
no measured corpus gain, so it is left as ranked residue **V1** rather than
forced into a landing.

---

## 4. FILES

* `v156_ifc.sv`, `v156_fwd.sv`, `v156_scope.sv`, `v156_shadow.sv` — the four
  adversarial arms.
* `REMEASURE.r10v156.txt` — every one of the 33 boundary movers rebuilt
  against golden in both views and scored (`score156.py` + `away156.py`).
