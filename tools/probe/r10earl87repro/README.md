# r10earl87 — § `impOvNameSetShadow87`

**THE MATERIALIZED-IMPORT `vpiOverriden` STAMP IS A NAME-SET HIT, NOT A
PROPERTY OF THE PARAMETER.**

The head at base `8877c49` was `Earlgrey_0_1`, **both modes**, 150 cmp lines,
one head, the same object in each: the ELABORATED `param_assign` of
`flash_ctrl_pkg.sv:12:18` `PagesPerBank` — a WILDCARD-IMPORTED package
localparam that `u_flash_ctrl.u_flash_erase_ctrl` materializes. Golden carries
`vpiOverriden:1`; we carried nothing. `param_assign::Compare`
(`~/git-repos/UHDM/build/generated/src/param_assign.cpp:94-116`) reads
`VpiConnByName`, then **`VpiOverriden`**, then `Rhs`, then `Lhs` — so the head
field is decided BEFORE the Rhs is looked at, and the Rhs (a `constant UINT:256`
size 32 with an `int_typespec` ref) already agreed.

---

## 1. Question 1 — DECODING SURELOG: where the stamp is made

Three producers set `vpiOverriden` on an elaborated `param_assign`, all inside
`NetlistElaboration::elab_parameters_`:

| site | condition |
|---|---|
| `NetlistElaboration.cpp:327` | `inst_assign->VpiOverriden(instance->isOverridenParam(paramName))` — opens EVERY row |
| `NetlistElaboration.cpp:556` | `m_helper.isOverloaded(inst_assign->Rhs(), …)` |
| `NetlistElaboration.cpp:571` | `m_helper.isOverloaded(tps, …)` on the DECLARED typespec — r10earl85's § `paOvFoldedRangeNoStamp85` |

**This head is the FIRST one, and it is a bare name lookup.**

```
  ModuleInstance::isOverridenParam(std::string_view name)      // ModuleInstance.cpp:392
      -> m_overridenParams.find(name) != end                   //   std::set<std::string>
  ModuleInstance::setOverridenParam(name)                      // ModuleInstance.cpp:388
      <- DesignElaboration.cpp:2182/2198/2216/2232/2238/2247/2251/2295/2299/2347/2363
         where `name` is the FORMAL parameter name of an override written at
         the instantiation.
```

The set holds *names*, not parameters. Nothing in it says which row it is
answering.

And the imported copies are in the very same vector the loop walks.
`CompileHelper::importPackage` (`CompileHelper.cpp:240-280`) clones every
`ParamAssign` of a wildcard-imported package into the **importing module's own**
`ParamAssignVec` (`scope->addParamAssign(clone)`), tagging the cloned `Lhs`
`parameter` with `VpiImported(pack_name)`. `elab_parameters_` then walks
`mod->getParamAssignVec()` once per elaborated instance and opens each row with
`isOverridenParam(paramName)`, where `paramName` is that row's own name.

> **THE LAW.** In an elaborated instance, a materialized WILDCARD-import copy
> whose NAME collides with a FORMAL that this instantiation overrode inherits
> that formal's `vpiOverriden:1`. Nothing else about the copy matters.

### The purpose-built goldens that decide it

Every arm is built with **Surelog** (golden) and with the two FROZEN binaries;
`pacen87` censuses all three; `score87.py` joins them as a MULTISET.

| arm | question | golden's answer |
|---|---|---|
| `g1_ovimp87.sv` | does the collision alone do it? `pk1::{PA,PB,PC,PD}` wildcard-imported into `leaf(PA,PB,PE)`, instantiated with PA / with PA+PB / bare | imported `PA` **OV=1** under `.PA(7)`, **OV=0** in the bare instance; imported `PB` OV=1 only in the `.PB(8)` instance; imported `PC`/`PD` (no local twin) **always OV=0** |
| `g2_kinds87.sv` | which IMPORT KINDS reach it? wildcard body import / explicit import / package-qualified reference / **header** wildcard import / parent-only import | wildcard body (`k1`) and **header** (`k5`, `rstmgr_ctrl`'s shape) both stamp; qualified reference and parent-only import materialize NOTHING, so there is no row to stamp |
| — | explicit import of a colliding name | **ILLEGAL** — `import pk2::QA;` beside a local `QA` is a redefinition error (slang `-Wredefinition`). A collision can ONLY come from a wildcard import. |
| `g3_decl87.sv` | which DECLARATION KINDS? package `localparam` vs `parameter`; typed `int` / implicit / `logic [7:0]`; a collision with a module **localparam**; a name with no twin | all four declaration kinds stamp identically; the module-**localparam** collision (`RE`) does **NOT** stamp (a localparam cannot be overridden); `RF` (no twin) does not stamp |
| `g4_homes87.sv` | which HOMES? module / interface / gen-if / gen-for / instances 1-2-3 deep | every one stamps: `u_if` (interface), `g_if.u_g`, `g_for[0..1].u_f`, `u_d1`, `u_d1.u2`, `u_d1.u2.u3` |
| `g5_earl85shadow87.sv` | the Earlgrey shape verbatim (r10earl85's `g4_shadow85`) | 2 cells, exactly the corpus head's shape |
| `g6_earl85noshadow87.sv` | **r10earl85's NEGATIVE CONTROL** (package name changed) | golden keeps `vpiOverriden:1` on the `PageAddrMask` row, and so do we — unchanged by this pass |
| `g7_earl85parentimp87.sv` | **r10earl85's SECOND NEGATIVE CONTROL** (import in the PARENT only) | golden OV=1, we agree; **nothing moves at all** |

`ELAB ONLY`: golden's DEF listings carry `OV=0` on every row of every arm, so
the gate reads the PHYSICAL view (`!defViewOrig9`), never `topView` —
§ `modDefImportShape` flips `topView` on for a DEF listing of a module WITH a
parameter port list (which `flash_erase_ctrl` has) to borrow the elaborated
SHAPE for its import copies, and that flip must not carry the stamp.

---

## 2. Question 2 — THE CENSUS, both corpora

`pacen87.cpp` reads a `.uhdm` **DIRECTLY** (Earlgrey's `uhdm-dump` is >1 GB —
earl61's direct-reader pattern) and enumerates **EVERY** `param_assign`.
KEY = `SPAN + VIEW + HOME + PNAME + INST`; PAYLOAD = only fields a generated
`Compare` reads, **with no span-derived field** (earl60/earl69: a span-carrying
payload hides a real flip; `--spans` adds a SEPARATE `TSPAN=` column for
DIAGNOSIS only, which `score87.py` strips). It extends `pacen86` with `IMP=`,
the Lhs `parameter`'s `VpiImported` — `parameter::Compare`
(`parameter.cpp:182`) reads it, so it belongs in a compare-visible payload and
it is what identifies a materialized import copy.

### PRISTINE (`8877c49`) vs golden, both corpora — the fixed universe

| | uhdm2rtlil (1358 DBs read, 504 hold a `param_assign`) | surelog (956 DBs read, 461 hold one) |
|---|---|---|
| BOTH-SAME | 68 714 | 45 428 |
| **FAMILY-OVSTAMP** — `vpiOverriden` the ONLY disagreement | **0** | **16** |
| FAMILY-IMPID — `IMP`/`LLP` the only disagreement | 0 | 28 |
| FAMILY-OPKEPT (earl85 R3) | 0 | 2 |
| FAMILY-SUBFOLD / TREE-OTHER | 0 / 0 | 0 / 0 |
| OTHER-DIFF | 6 | 1 810 |
| ONLY-GOLDEN / ONLY-OURS | 70 / 24 | 8 898 / 9 628 |
| **GATE-REACHABLE** — every ELAB row whose Lhs carries `vpiImported` | **28** | **6 528** |
| **GATE-COLLIDE** — of those, name also overridden in this instance | **0** | **16** |

**GATE-COLLIDE AND FAMILY-OVSTAMP ARE THE SAME SIXTEEN CELLS, cell for cell.**
The predicate the law tests and the family it is meant to clear coincide
exactly: there is no row it can move by accident, and no row of the family it
cannot reach. GATE-REACHABLE is counted WITHOUT asking whether the row already
agrees (earl66: a census keyed on the shape you intend to change is blind to
the rows you would change by accident), and 6 512 + 28 of those rows carry a
name this instance did not override, so the lookup misses them.

The 16 are 8 sites x 2 modes, all `Earlgrey_0_1`:

```
  flash_ctrl_pkg.sv:12:18 PagesPerBank   u_flash_ctrl.u_flash_erase_ctrl   <- THE HEAD
  flash_ctrl_pkg.sv:13:18 WordsPerPage   u_flash_ctrl.u_flash_erase_ctrl
  flash_ctrl_pkg.sv:18:18 AddrW          u_flash_ctrl.u_flash_erase_ctrl
  flash_ctrl_pkg.sv:11:18 NumBanks       u_flash_ctrl.u_flash_mp
  flash_ctrl_pkg.sv:22:18 AllPagesW      u_flash_ctrl.u_flash_mp
  flash_ctrl_pkg.sv:28:18 MpRegions      u_flash_ctrl.u_flash_mp
  rstmgr_pkg.sv:7:18      PowerDomains   u_rstmgr.i_lc_src
  rstmgr_pkg.sv:7:18      PowerDomains   u_rstmgr.i_sys_src
```

`flash_erase_ctrl` declares `AddrW`, `WordsPerPage`, `PagesPerBank` and
wildcard-imports `flash_ctrl_pkg`, which declares all three; `flash_mp`
declares `MpRegions`, `NumBanks`, `AllPagesW` and imports the same package;
`rstmgr_ctrl` declares `PowerDomains` and header-imports `rstmgr_pkg`, which
declares it. All three instantiations override the colliding formals
(`flash_ctrl.sv:266-271`, `rstmgr.sv:133-147`).

---

## 3. Question 3 — the law

### § `impOvNameSetShadow87` (`src/ParamEmit.cpp`, in `emitParameters`)

```
  bool impNameOv87 = false;
  if (!defViewOrig9 && isImported && !inPackage && !funcScope && !overridden)
      for (auto& om7 : body.members())
          if (om7.kind == SymbolKind::Parameter && om7.name == ps.name &&
              isOverriddenParam(om7)) { impNameOv87 = true; break; }
  if (topView && !cliOv &&
      (overridden || derivedOv9 || impNameOv87 || (!hasDefault && boundInit)))
      pa->VpiOverriden(true);
```

`isImported` (`ps.getParentScope() != &body`) is already this loop's name for
"this occurrence is a materialized import copy" — `collectImportedParams`
appends one occurrence per import item to `paramSyms`. The law reads the
IMPORTING body's own members, which is exactly the scope
`DesignElaboration` filled the name set from.

**It only ever ADDS a stamp, and only on a name the same body already carries
an overridden parameter for.** r10earl85's § `paOvFoldedRangeNoStamp85` only
ever REMOVES one, and it is reached through `derivedOv9`, a different
disjunct: the two cannot interfere. Both of earl85's negative controls are
re-run here as arms `g6`/`g7` and neither moves.

---

## 4. The grids — the numbers

`score87.py` joins GOLDEN / PRISTINE / PATCHED as a multiset and reports two
scores. The whole-payload bucket calls a cell `WRONG->OTHER` when it was wrong
in TWO independent fields and only one of them moved — which reads like a
MOVED-WRONG when it is a strict improvement — so a **FIELD-LEVEL** 3-way was
added: it scores every payload field separately, and `AWAY-GOLDEN` then means
what it says.

| arm | whole-payload | FIELD-level |
|---|---|---|
| `g1_ovimp87` | SAME 24, W2R 0, R2W 0, W2O 3, STILL 9 | **TO-GOLDEN 3, AWAY 0, MOVED-WRONG 0** (OV x3) |
| `g2_kinds87` | SAME 24, W2R 2, R2W 0, W2O 0, STILL 2 | **TO-GOLDEN 2, AWAY 0, MOVED-WRONG 0** (OV x2) |
| `g3_decl87` | SAME 25, W2R 0, R2W 0, W2O 5, STILL 15 | **TO-GOLDEN 5, AWAY 0, MOVED-WRONG 0** (OV x5) |
| `g4_homes87` | SAME 26, W2R 2, R2W 0, W2O 5, STILL 7 | **TO-GOLDEN 7, AWAY 0, MOVED-WRONG 0** (OV x7) |
| `g5_earl85shadow87` | SAME 16, W2R 2, R2W 0, W2O 0, STILL 2 | **TO-GOLDEN 2, AWAY 0, MOVED-WRONG 0** (OV x2) |
| `g6_earl85noshadow87` | SAME 18, W2R 1, R2W 0, W2O 0, STILL 1 | **TO-GOLDEN 1, AWAY 0, MOVED-WRONG 0** (OV x1) |
| `g7_earl85parentimp87` | SAME 16, W2R 0, R2W 0, W2O 0, STILL 0 | **nothing moved** |

**RIGHT->WRONG 0 in every arm. 20 fields moved in total (3+2+5+7+2+1+0), every
one of them `OV`, every one TO-GOLDEN.** The `WRONG->OTHER` and `STILL-WRONG` rows are the
two named residues below (R1 and R3), measured pristine == patched.

---

## 5. The gates — all green (`GATES.r10earl87.txt` has the full battery)

Both binaries were FROZEN at immutable paths (`chmod 555`) BEFORE any sweep and
every `cmds.txt` was audited BY BINARY PATH — 2 981 pristine and 2 673 patched
`cmds.txt`, 100 % naming the frozen binary and nothing else:
`pristine 58e40a645b33f5b6a09322e71a884033`,
`patched  c0c6be0ea94c54d9e0b1bed0fe986801`.

* golden dumps **23 PASS / 0 FAIL** on BOTH binaries; `SLANG_UHDM=/bin/false`
  **0 PASS / 23 FAIL** (the negative control that proves the harness is
  actually running the binary it is handed).
* **uhdm2rtlil**, testflags vs the committed baseline AND both modes vs this
  pass's own pristine: **0 differing ROWS** (status AND dump column); status
  `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2` in both modes, unchanged;
  byte movers **0 / 1358**.
* **surelog**, both modes vs the committed baseline AND vs this pass's own
  pristine: **0 differing ROWS / 1588**. Status histogram unchanged
  (`CMP_EQUAL 937, SLANG_REJECT 567, SURELOG_FAIL 48, CMP_NOTEQUAL 19,
  DEFERRED 10, NO_DATABASE 3, UNTRANSLATABLE 2, TIMEOUT 1, NO_UHDM 1`).
  **NO ROW CONVERTED** — `results/*.csv` untouched.
  Byte movers **2 / 956**: `default/Earlgrey_0_1` and `testflags/Earlgrey_0_1`,
  BOTH PREDICTED BY NAME from the pristine census before the patched sweep ran.
* **THE RUN-TIME A/B GATE.** The patched binary run with `R10E87_OFF=1` (the law
  disabled, everything else identical) reproduces the PRISTINE Earlgrey database
  BYTE FOR BYTE in both modes (`bbcfbcd412a6` default, `a8e579ba7375`
  testflags, on both binaries), so 100 % of each mover's byte delta is this law
  and nothing else. Law ON: `feb743d6f254` / `22dc13775f8d`, the same md5s the
  sweep produced.
* **THE OFFICIAL JUDGE, ours against ours.** `uhdm-cmp <pristine> <patched>` on
  the Earlgrey databases prints exactly ONE head in each mode, and it is the
  head cell: `param_assign` 12:18-12:65 `PagesPerBank`, `vpiOverriden` absent
  on the left and `:1` on the right (`OURS_vs_OURS_{default,testflags}.cmp`).
* canaries `ok=52 changed=0` / `ok=8 changed=0`; `ctcan2` PASS / PASS;
  `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0**;
  `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` byte-identical,
  `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` pins matched.

### The corpus re-score, fixed universe (`CENSUS.*.txt`)

| surelog | before | after |
|---|---|---|
| BOTH-SAME | 45 428 | **45 444** |
| **FAMILY-OVSTAMP** | **16** | **0** |
| FAMILY-IMPID | 28 | 28 (R1) |
| FAMILY-OPKEPT | 2 | 2 (R3) |
| OTHER-DIFF | 1 810 | 1 810 |
| ONLY-GOLDEN / ONLY-OURS | 8 898 / 9 628 | 8 898 / 9 628 |
| GATE-REACHABLE / GATE-COLLIDE | 6 528 / 16 | 6 528 / 16 |

uhdm2rtlil is unchanged in every bucket (BOTH-SAME 68 714, OTHER-DIFF 6).

`cen3way87.py`, golden vs pristine vs patched, per DATABASE as a multiset,
with the golden side asserted identical between the two censuses
(`golden-side keys that changed: 0`):

```
  surelog     CELL  SAME=45428 WRONG->RIGHT=16 RIGHT->WRONG=0 WRONG->OTHER=0
                    STILL-WRONG=1840
              FIELD TO-GOLDEN=16 AWAY-GOLDEN=0 MOVED-WRONG=0   (OV x16)
  uhdm2rtlil  CELL  SAME=68714 WRONG->RIGHT=0 RIGHT->WRONG=0 WRONG->OTHER=0
              FIELD nothing moved
```

The 16 `WRONG->RIGHT` cells are listed BY NAME in `CENSUS.3way.surelog.txt`
and are exactly the 16 the prediction named.

---

## 6. The wide boundary — the gate that convicts what the corpus cannot

`vwide87.sh` over a COPY of `tools/probe` at ANY depth, both views, both frozen
binaries, workdir-normalised whole-dump byte-compare; the file list is read on
**fd 3**, children get `</dev/null`, every rc is recorded, and **PROCESSED is
asserted equal to LISTED**.

```
PROCESSED=3907 (== LISTED)  identical=7474  DIFFERING=26  no_output=314
rc histogram: rc=0 14350   rc=3 600   rc=4 650   rc=139 28
```

The 28 `rc=139` are 14 files x BOTH binaries — perfectly symmetric, i.e.
pre-existing segfaults, not this pass's (`BOUNDARY_WIDE.signals`).

All 26 differing cells are accounted for, and **14 of them are NOT this pass's
own arms**, so each was re-measured AGAINST GOLDEN with `arm87.sh` +
`score87.py`:

| file | whole-payload | FIELD-level |
|---|---|---|
| `r10earl87repro/g1..g6` (this pass, 12 cells) | see §4 | TO-GOLDEN 20, AWAY 0 |
| `r10earl60repro/v60b_earl60.sv` | SAME 41, W2R 1, R2W 0, W2O 1, STILL 11 | **TO-GOLDEN 2, AWAY 0, MOVED-WRONG 0** (OV x2) |
| `r10v81repro/v8_shape2_81.sv` | SAME 6, W2R 0, R2W 0, W2O 1, STILL 1 | **TO-GOLDEN 1, AWAY 0, MOVED-WRONG 0** (OV x1) |
| `r10v85repro/arms/va3_shadow85.sv` | SAME 39, W2R 0, R2W 0, W2O 1, STILL 5 | **TO-GOLDEN 1, AWAY 0, MOVED-WRONG 0** (OV x1) |
| `r10v85repro/arms/va8_ov85.sv` | SAME 38, W2R 0, R2W 0, W2O 5, STILL 31 | **TO-GOLDEN 5, AWAY 0, MOVED-WRONG 0** (OV x5) |
| `r10v85repro/arms/va9_ovedge85.sv` | SAME 16, W2R 0, R2W 0, W2O 2, STILL 16 | **TO-GOLDEN 2, AWAY 0, MOVED-WRONG 0** (OV x2) |
| `r10earl85repro/g4_shadow85.sv`, `g5_noshadow85.sv` | identical to this pass's `g5`/`g6` (the same files) | TO-GOLDEN 3, AWAY 0 |

Every earlier-pass arm that moves carries the same collision shape, and every
one of them moves TOWARD golden: **33 `OV` fields moved across the whole
boundary, RIGHT->WRONG 0, AWAY-GOLDEN 0, MOVED-WRONG 0.** `g7`
(r10earl85's parent-only-import negative control) does NOT appear in the
differing list at all — it must not move, and it does not.

---

## 7. The head

| | before (`8877c49`) | after |
|---|---|---|
| `Earlgrey_0_1` default | 150 cmp lines, 1 head | 21 302 cmp lines, 1 head |
| `Earlgrey_0_1` testflags | 150 cmp lines, 1 head | 21 926 cmp lines, 1 head |

Counts are DEPTH, not distance. **The head OBJECT changed**, which is why the
line count went up: the new head is a whole `module_inst` and `uhdm-cmp` prints
its entire decompile on both sides. The old head object is GONE — read
`HEAD_BEFORE_Earlgrey_default.cmp` against
`HEAD_AFTER_Earlgrey_default.decode.txt`. Both modes still sit on the SAME
object. Every other measured row head is unchanged (`SeqDriver` 17,
`SimpleUVM` 64, `Scoreboard` 64, `MiniAmiq` 294, `BuildUVMPkg` 60, `Rggen` 0).

---

## 8. Question 4 — the Rhs span: MEASURED, and deliberately NOT taken

Golden's ELAB Rhs `constant` for a materialized import copy spans the WHOLE
written Rhs; ours stops at its first sub-expression. Measured on all 8 sites
(`pacen87 --spans`, the DIAGNOSIS-only `TSPAN=` column):

```
  flash_ctrl_pkg.sv:11  NumBanks     = top_pkg::FLASH_BANKS            golden 11:36-11:56  ours 11:36-11:45
  flash_ctrl_pkg.sv:12  PagesPerBank = top_pkg::FLASH_PAGES_PER_BANK   golden 12:36-12:65  ours 12:36-12:45
  flash_ctrl_pkg.sv:13  WordsPerPage = top_pkg::FLASH_WORDS_PER_PAGE   golden 13:36-13:65  ours 13:36-13:45
  flash_ctrl_pkg.sv:18  AddrW        = BankW + PageW + WordW           golden 18:36-18:57  ours 18:36-18:49
  flash_ctrl_pkg.sv:22  AllPagesW    = BankW + PageW                   golden 22:36-22:49  ours 22:36-22:41
  flash_ctrl_pkg.sv:28  MpRegions    = 8                               golden 28:36-28:37  ours 28:36-28:37   <- AGREES
  rstmgr_pkg.sv:7       PowerDomains = pwrmgr_pkg::PowerDomains        golden  7:36-7:60   ours  7:36-7:48
```

The bare literal AGREES; every compound Rhs keeps its LEFT sub-expression's
span in ours (`BankW + PageW` for the three-term sum, `BankW` for the two-term
one, the package qualifier for a scoped name).

**It is the same site — and it is not taken.** No generated `Compare` reads
`VpiFile`/`VpiLineNo`/`VpiColumnNo` (RESUME.md §9), so the judge cannot see it;
and the correct rule ("a folded ELAB constant carries the span of the WHOLE
written Rhs") is not a property of import copies at all — its reachable
population is the 6 528 GATE-REACHABLE rows plus every other folded ELAB
constant in both corpora, not these 16. Taking a judge-invisible span change
with that blast radius inside this pass would put bytes in motion that this
pass's law does not name, which the mover rule forbids. Recorded as R2.
