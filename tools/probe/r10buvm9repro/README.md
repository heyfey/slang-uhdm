# r10buvm9 — § sharedTdRefNoRestamp9 — **THE BuildUVMPkg HEAD CLEARED**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `79efb64` (`git log --oneline -1` in the worktree) |
| worktree | `/tmp/wt_r10buvm9` |
| pristine binary | md5 `ec401fc9f5510140460b9658dfc59dc9` |
| patched binary | md5 `7c41b38a41a4b4459fe1fc568dba6cdc` |
| production surface | `include/UhdmExporter.h`, `src/TypeEmit.cpp`, `src/StmtEmit.cpp`, `src/TaskFuncEmit.cpp` |
| probe surface | `tools/probe/r10buvm9repro/` only |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass.**  What it does is CLEAR THE HEAD that buvm8 exposed:

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` lines, default / testflags | **644 323** | **17** |
| heads (`grep -c '^LHS:'`) | 1 | 1 |
| head object | `LHS: <null>` / `RHS: package(uvm_pkg) #2` (the DEF-view package, printed whole) | `ref_typespec(uvm_field_flag_t)#1710` / `RHS: <null>` |

The two modes' cmp logs are **byte-identical** to each other on both binaries.
The new head is a 17-line object where the old one printed the entire def
package, and it is the object the pristine ladder already named as **rung 2**.

## 1. THE HEAD, DECODED

buvm8 left the head referrer-bisected to
`enum_typespec(recursion_state_e)@18219` and counted **12** typespecs inside our
elaborated `uvm_pkg` whose `vpiInstance` disagrees with golden.  The census
(`r10buvm9cen`, `TS` / `PKGTS` / `PKG` / `REFTS` rows out of
`Serializer::AllObjects()`, never out of dump TEXT) reproduces that 12 EXACTLY
and splits it in two:

| sub-family | objects | golden | ours (pristine) |
|---|---|---|---|
| **B** — listed in a **CLASS** listing | `enum_typespec recursion_state_e` (uvm_policy), `struct_typespec m_verbosity_setting`, `struct_typespec uvm_cmdline_parsed_arg_t` (uvm_component) | **NONE** | the **DEF** uvm_pkg |
| **A** — listed in the **ELABORATED** package listing | 6 `class_typespec` (`uvm_event_pool`, `uvm_{reg,reg_bd→no,mem,reg_field,vreg,vreg_field}_cb_iter`), 3 `enum_typespec` (`UVM_SEQ_ARB_TYPE`, `uvm_sequence_state`, `uvm_sequence_state_enum`) | the **ELAB** uvm_pkg | the **DEF** uvm_pkg |

Sub-family **B** is the head (`typespec::Compare` reads `Instance`, and
`SafeCompare(lhs, rhs==nullptr)` names the TARGET of the edge, so golden's NULL
prints as `LHS: <null>` and ours prints the whole package it points at —
uvm83's lesson, exactly).

Two numbers make the census trustworthy before any code:

* golden-vs-golden first: over **163** class-listed named typespecs golden
  stamps **9** (all `class_typespec`) and leaves **154** bare; over the
  **137**-entry `uvm_pkg` listing pair (89 ELAB + 48 DEF) golden stamps EVERY
  entry with the package that holds the listing.
* the same join pristine-vs-golden: **12** disagreements, **all** of them
  `→ DEF`, out of **6 239** uniquely-keyed typespecs (and 0 disagreements over
  all 48 DEF-listing entries).

### the mechanism, read out of the object model

`REFTS` rows say it in one line.  For arm `v2` cell `b1`:

```
golden  REFTS act=struct_typespec:b1_s:#266 actinst=-              < ref_var(v) < begin < if_stmt < function(f1)    < class_defn(b1) < package(q9)#1
golden  REFTS act=struct_typespec:b1_s:#266 actinst=-              < ref_var(v) < begin < if_stmt < function(b1::f1) < package(q9)#138
ours    REFTS act=struct_typespec:b1_s:#5   actinst=package:q9:#2  < ref_var(v) < begin < if_stmt < function(f1)    < class_defn(b1) < package(q9)#3
ours    REFTS act=struct_typespec:b1_s:#5   actinst=package:q9:#2  < ref_var(v) < begin < if_stmt < function(b1::f1) < package(q9)#2
```

BOTH sides SHARE one object across the class's method and the package's
out-of-body definition.  `makeTypespec` returns that SHARED object, and
`StmtEmit.cpp`'s block-item-local site then did

```cpp
auto* ts = makeTypespec(bm);
if (pkgScopeInst) ts->Instance(pkgScopeInst);
```

so the stamp did not instance the LOCAL's typespec — it re-instanced the
**declaring scope's own listing entry**, with the DEF package, because an
out-of-body class method's `tsInst`/`pkgScopeInst` IS the home package
(§ `scopedTdUnsupTsHomePkgInstance83`) and the class body is emitted while the
def view is live.  The three head objects are exactly the class-scope typedefs
whose ONLY use is a block-item local inside a NESTED block of an out-of-body
method: `uvm_pkg.sv:41181` `if(first) begin ... m_verbosity_setting setting;`,
`41272` `foreach(values[idx]) begin uvm_cmdline_parsed_arg_t t;`, `41444`
`fork begin m_verbosity_setting setting = ...`.

**The same question was already being asked one site over.**
`TaskFuncEmit`'s SUBROUTINE-BODY-local site has carried `sharedClassTypedef9`
since IOClassStruct — the identical identity test, class-scoped.  A nested
`begin` takes StmtEmit's path instead and never asked; the RETURN-type and
FORMAL sites only ever asked `foreignSharedTs`, which fences a typedef homed in
ANOTHER package and says nothing about one homed here.

## 2. THE LAW

> **§ sharedTdRefNoRestamp9** — a REFERENCE to a typedef (a formal, a return
> type, a subroutine body local, a **nested-block** local) never re-stamps
> `vpiInstance` on the **SHARED typespec object** that typedef owns — the object
> its DECLARING scope's own listing holds (`typedefTs`, or its elaborated twin
> in `pkgTopTypedefTs`).  Surelog creates that object ONCE, where the typedef is
> WRITTEN, and stamps it there.
> The test is by **POINTER IDENTITY**, which is what keeps every CLONE path
> (wildcard-import subroutine copies, § `pkgImportCloneLastWriter32`'s
> aggregates, a freshly minted twin) outside the law: a clone is not the shared
> object and still takes its stamp.

The law does **not** claim the whole (scope × kind) grid.  Every fence below was
written only after a measurement REFUTED the wider rule, and the arm that caught
it is named:

| cell | reference-site stamp | what refuted the wider rule |
|---|---|---|
| `PkgClassTs` — PACKAGE scope, `class_typespec` | **REMOVED** (the law) | — |
| `PkgOther` — PACKAGE scope, any other kind | **KEPT** | claiming it turned Scoreboard's and SimpleUVM's `uvm_pkg::uvm_severity` from golden's ELAB to the DEF twin — an OVER-FIRE in `attrib9.sh` |
| `ClassOther` — CLASS scope, any other kind | **REMOVED** (the law) | — |
| `ClassKeyTs` — CLASS scope, `class_typespec`, at sites 1-3 | **KEPT** | claiming it turned uvm83's `v83_a03` / `v83_a23` `zbase::c_t` from golden's ELAB to NONE |
| `ClassKeyTs` at site 4 | **REMOVED** (the shipped answer) | re-claiming it moved uvm83's `v83_a12` `plain_td` from NONE to the DEF package |

The two KEPT cells are kept for the same reason: golden's answer there is a
**LISTING** fact — § `classKeyTsScopeOwner35`'s "the vpiInstance follows the LAST
package to list the object" — and our emitter currently reaches it THROUGH a
reference-site stamp.  Fencing it is a regression, not a fix.  Closing either
cell properly is a law of its own with its own census; BuildUVMPkg golden shows
the class half is genuinely MIXED (**9** stamped, **135** bare, in ONE design).

### STATED GATE == CODE GATE

**STATED:** at four sites — StmtEmit's block-item local (SITE 1), TaskFuncEmit's
return type (2), formal (3) and subroutine-body local (4) — before stamping
`vpiInstance`, ask `sharedTypedefTsRef9(declSym, ts)`.  It returns
`NotShared` unless `ts` is pointer-identical to the entry `typedefTs` (or
`pkgTopTypedefTs`) holds for `declSym.getDeclaredType()->getType()`, and then
classifies by the type's parent scope kind (Package / ClassType; anything else is
`NotShared`) crossed with `ts->UhdmType() == uhdmclass_typespec`.  Sites 1-3 skip
the stamp on `PkgClassTs` and `ClassOther`; site 4 skips on everything except
`NotShared` and `PkgOther`.  Nothing else changes — no name, span, parent,
expression or listing is touched, and no new predicate is introduced (the
identity map and the scope kind were both already read at site 4).

**CODE:** `src/TypeEmit.cpp` (the predicate, one function),
`include/UhdmExporter.h` (the enum + the law), `src/StmtEmit.cpp` (1 hunk),
`src/TaskFuncEmit.cpp` (3 hunks, one of which REPLACES the old
`sharedClassTypedef9` computation with the shared predicate).

## 3. THE ARM GRID — golden vs PRISTINE vs PATCHED

`arm9.sh` prints golden-vs-ours per LISTED, NAMED typespec; `grid9.sh` prints the
three-way cell with a verdict.  Both run Surelog and BOTH binaries in the SAME
directory (a UHDM database records the source file's ABSOLUTE path — buvm8's
`bndarms` trap).

| arm | cells | pristine DIFF | patched DIFF |
|---|---|---|---|
| `v1inst9.sv` — class-scope typedef × reach (member / oob return / oob local / oob formal / in-body / qualified) | 9 | 1 | **0** |
| `v2inst9.sv` — the NESTED-block local (`if` / `foreach` / `fork` / two levels / qualified / in-body / plain) | 9 | 6 | **0** |
| `v3inst9.sv` — PACKAGE-scope plain typedef × the same reaches (the FENCE arm) | 20 | 0 | **0** |
| `v4inst9.sv` — parameterized-class-specialization typedef and typedef-OF-typedef | 12 | 7 | **4** (R1) |

Cells worth naming:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| v2 `b1`/`b2`/`b3` | struct td, block-item local of `if` / `foreach` / `fork`, OUT-OF-BODY | NONE | DEF | **NONE** |
| v2 `b6` | + a class-member queue of the same type (the full uvm shape) | NONE | DEF | **NONE** |
| v2 `b8`/`b9` | qualified spelling / two nesting levels | NONE | DEF | **NONE** |
| v2 `b4` | the same, IN-BODY method | NONE | NONE | NONE (`tsInst` is null there) |
| v2 `b7` | the same, TOP-level body local | NONE | NONE | NONE (site 4's shipped test) |
| v1 `a8` | class-scope struct as an OUT-OF-BODY FORMAL | NONE | DEF | **NONE** |
| v4 `d1_t`/`d2_t`/`d7_t` | `typedef pc9#(T) d` at package scope, oob nested local / top local / RETURN | ELAB | DEF | **ELAB** |
| v4 `d3_t`/`d4_t`/`d5_t`/`d6_t` | in-body local / unreferenced / class member / oob formal | ELAB | ELAB | ELAB |
| v4 `d0_e`/`d8_t`/`d9_t`/`d10_t` | **typedef-OF-typedef** (`typedef d0_e d8_t`) | ELAB | DEF | DEF (**R1**) |
| v3 `c1..c10` | package-scope struct/enum td, every reach | = golden | = golden | = golden |

## 4. RESIDUES, each measured and left deliberately

* **R1 — THE TYPEDEF-OF-TYPEDEF (alias-chain) FAMILY, and it is the next head's
  family.**  `v4` `d8_t`/`d9_t`/`d10_t` are DEF on both binaries and `d10_t` is
  **referenced NOWHERE**, so no reference site can be the writer: this is the
  alias-chain instance propagation (`TypeEmit` ~696, `cl->Instance(base->Instance())`
  and friends) carrying a DEF-pass base's stamp into the elaborated alias.
  On BuildUVMPkg it is exactly the **3** surviving objects —
  `uvm_pkg::UVM_SEQ_ARB_TYPE` (`typedef uvm_sequencer_arb_mode UVM_SEQ_ARB_TYPE`),
  `uvm_pkg::uvm_sequence_state` and `uvm_pkg::uvm_sequence_state_enum`
  (`typedef uvm_sequence_state uvm_sequence_state_enum`) — plus
  `uvm_pkg::uvm_severity_type` on Scoreboard / SimpleUVM.  **Untouched by this
  pass and unchanged by it.**
* **R2 — a class-scope ENUM typedef we do not LIST at all** in the small arms
  (`v1` `a1_e`/`a2_e`/`a3_e`/`a7_e`, `v2` `b5_e`: golden NONE, ours MISSING).
  Present identically on the PRISTINE binary; a listing-population difference,
  not a `vpiInstance` one, and not this law's family.  It does NOT occur on
  uvm_pkg (`recursion_state_e` IS listed there).
* **R3 — the two KEPT grid cells** of §2 (`PkgOther`, `ClassKeyTs` at sites 1-3).
  Each is a law of its own; each has a named arm that would catch a wrong fix.
* **R4 — uvm83's `v83_a04`/`a05`/`a20`/`a22` `zbase::c_t`/`far_t`** (golden ELAB,
  ours DEF on BOTH binaries).  A pre-existing `ClassKeyTs` residue, **byte-for-byte
  unchanged** by this pass.
* **R5 — a struct-MEMBER typespec binding defect this pass makes VISIBLE.**
  `uvm_comparer::state_info_t`'s member `state` should bind
  `uvm_policy::recursion_state_e` and binds an anonymous `bit_typespec` in ours.
  Pre-existing (same object id in the pristine database), previously hidden
  behind the head's mask; see §5.

## 5. THE LADDER — the head ADVANCED by exactly ONE RUNG, 0 rungs lost

`tools/probe/r10ladder1repro/ctladder` (the official `design::Compare` run to
fixpoint by masking each head).  Calibration on this pass's golden against
itself: **0 rungs on 183 142 objects**.

| | pristine | patched |
|---|---|---|
| rungs (fixpoint) | **247** | **341** |
| stop | FIXPOINT | FIXPOINT |
| secs | 243 | 362 |
| rung 1 | `<null>` / `package(uvm_pkg)#2`, bisected to `enum_typespec(recursion_state_e)#144162` | `ref_typespec#1710` < `bit_typespec(uvm_field_flag_t)` — **= pristine rung 2** |
| rung 2 | `ref_typespec#1710` < `bit_typespec(uvm_field_flag_t)` | `bit_var@21545` < `array_var(compare_map)` — **= pristine rung 3** |

Rung-list diff by LHS object: **exactly rung 1 removed, 0 of the other 246
pristine rungs lost, 95 ADDED.**

**The +95 is the INSTRUMENT, not a regression, and it is measured rather than
argued.**  To get past its rung 1 the pristine ladder had to MASK
`enum_typespec(recursion_state_e)#144162`, and a masked LHS object compares equal
instantly for every later rung — so everything reached THROUGH it was hidden.
The patched walk never needs that mask and reaches them.  The very first added
rung is that object itself, on a **different field**:

```
RUNG 34  FIELD=VpiType  SHAPE=KIND:enum_typespec>bit_typespec
  L  enum_typespec(recursion_state_e)#144162 < class_defn(uvm_policy) < package(uvm_pkg)#1
  R  bit_typespec@:21030:6-21030:23#11139    < typespec_member(state)
                                             < struct_typespec(state_info_t)
                                             < class_defn(uvm_comparer) < package(uvm_pkg)#2742
```

`uvm_comparer`'s `state_info_t` member `state` binds golden's shared
`recursion_state_e` object and binds an ANONYMOUS `bit_typespec` in ours — a
struct-MEMBER typespec binding defect with nothing to do with `vpiInstance`.
It is **PRE-EXISTING**: object `#11139` is present with the same id and the same
ancestor chain in the PRISTINE database (`r10buvm9cen` `TS` row quoted in §8's
reproduce block), and it appears **0 times** in the pristine ladder because that
ladder masked its LHS at rung 1.  This pass made it VISIBLE, not real.

## 6. THE FIVE GATES

| # | gate | result |
|---|---|---|
| 1 | build BOTH binaries, `-j 2`, md5 separately | pristine `ec401fc9f5510140460b9658dfc59dc9`, patched `7c41b38a41a4b4459fe1fc568dba6cdc`. **The deliverable was then applied to a THIRD, untouched `79efb64` worktree (`/tmp/wt_r10buvm9_verify`, `git apply --check` clean) and built from scratch: md5 `7c41b38a41a4b4459fe1fc568dba6cdc` — the patch reproduces the binary every reading above was taken with, bit for bit.** |
| 2 | `tests/check_goldens.sh` + negative control | **23** PASS on the pristine, the patched AND the from-scratch reproduction; `SLANG_UHDM=/bin/false` → **0** PASS |
| 3 | uhdm2rtlil, both modes | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in each mode on each binary; `ct9rows.sh` pristine-vs-patched = **0 differing ROWS** over 1 462 |
| 4 | Surelog suite, `--mode both` | `ct9rows.sh` patched vs the COMMITTED `results/golden_surelog.csv` = **0 differing rows** over 1 588 (status AND dump column); same against the pristine sweep |
| 5 | `byteverify.sh SELFCHECK=1 SELFCHECK1=1` | surelog **9 / 955** movers, u2r **0 / 1 358**; every mover PREDICTED BY NAME first and attributed; controls 954/955 + `SELFCHECK1`=10 (1 corruption + the 9 real movers) and 1357/1358 + `SELFCHECK1`=1 |

The canary battery, all pristine-vs-patched:

* `canaries.sh` — surelog `ok=52 changed=0 absent=0`, u2r `ok=16 changed=0 absent=0`.
* `ctcan2.sh` (the SUPPLEMENTARY list `canaries.sh` cannot see) — surelog
  `ok=58 changed=0` with `EXPECT_UNKNOWN=1`, u2r `ok=2 changed=0` with
  `EXPECT_UNKNOWN=6`; both PASS.
* `canaudit.sh canaries.sh ctcan2.sh` — `audited=29 UNCOVERED=0 FENCE-BREACH=0`,
  and both of its self-tests fire, so "every brief-protected name is checked" is a
  RUN and not a sentence.  The four slang-fenced names are dispatched by no
  driver here.
* the pinned md5s hold, in BOTH modes, identical to pristine: SVSwitch
  `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
  BlackParrotComplex `e3e354129d5a` / `73a10e8217e5`, YosysOldOr `d68e0796d62c`.
* `detcheck.sh`, 3 runs each on `v2inst9.sv` and uvm83's `v83_a02`: **1 distinct
  hash, 0 NO_OUTPUT** on each.

**THE SEVEN-ROW HEAD SET (`headset9.sh`, MiniAmiq included), cmp LOGS compared
BYTE for BYTE — the only wall measurement that means anything once a row's
database moves.**  Four of the seven rows' databases DO move:

```
BuildUVMPkg  default/testflags   644323 -> 17 lines   CHANGED  (this pass)
SimpleUVM    default/testflags       68 lines         BYTE-IDENTICAL
SeqDriver    default/testflags       68 lines         BYTE-IDENTICAL
Scoreboard   default                 64 lines         BYTE-IDENTICAL
Earlgrey_0_1 default                 46 lines         BYTE-IDENTICAL
YosysVerx    default/testflags        0 lines         BYTE-IDENTICAL (CMP_EQUAL both)
MiniAmiq     default/testflags       64 lines         BYTE-IDENTICAL
```

`Scoreboard/testflags` and `Earlgrey_0_1/testflags` have no comparable pair
(SLANG_REJECT / no golden) and print `SKIP-NOFILE`, which is COUNTED, not hidden:
`measured=12 SKIP-NOFILE=2 UNKNOWN-NAME=0` on each side.  Head counts are 1 → 1
on every non-equal row and 0 → 0 on YosysVerx.

`GOLDEN_DEFER` was left **UNSET** and echoed by every sweep; each sweep had its
OWN `--out` and `--workdir` at `--jobs 2`, and each workdir's `cmds.txt` was
re-read afterwards to prove which binary actually ran.

**One ops note that belongs in the record.** `results/golden_uhdm2rtlil.csv`
disagrees with a fresh sweep on `ParameterSizeOfInstance` and
`paramod_genscope_child` (dump column `differ` → `match`, both modes) and on 100
`SLANG_REJECT` rows whose `detail` column holds a RELATIVE source path where a
fresh sweep writes an absolute one.  **All of them differ on the PRISTINE binary
too**, so the committed baseline is stale for them at `79efb64`; nothing was
promoted.  buvm8 recorded the same 2 dump-column rows.

## 7. THE MOVERS — predicted, then attributed

`predict9.sh` reads only the PRISTINE databases and names every object the law
COULD touch (RULE A: class-listed, stamped, not a `class_typespec`; RULE B: an
ELAB-listing entry stamped with a different package object).  Both rules
deliberately over-predict — a stamp written by a DECLARATION site looks identical
to a reference-site one — and that is stated where it is measured.

* surelog: **41** candidate databases of 955, **1 486** candidate objects.
* uhdm2rtlil: **32** candidate databases of 1 358, **260** candidate objects.

The byte verifier then found **9** movers on surelog and **0** on u2r — every one
inside the predicted set, **zero unpredicted, zero missed**:

| test | modes | verdicts (`attrib9.sh`) |
|---|---|---|
| BuildUVMPkg | default, testflags | CONVERTED **9**, residue 3 (R1), same 295, **OVER-FIRE 0** |
| SimpleUVM | default, testflags | CONVERTED **7**, residue 4, **OVER-FIRE 0** |
| Scoreboard | default | CONVERTED **7**, residue 4, **OVER-FIRE 0** |
| SeqDriver | default, testflags | CONVERTED **2**, residue 258 (pre-existing import-clone listing set), **OVER-FIRE 0** |
| MiniAmiq | default, testflags | CONVERTED **2**, residue 252, **OVER-FIRE 0** — `SLANG_REJECT` on BOTH binaries, so no cmp row moves |

`CONVERTED` = golden ≠ pristine and patched == golden.  `OVER-FIRE` = golden ==
pristine and patched ≠ golden; the verdict exists because it FIRED TWICE during
this pass (§2's table) and each time the fix was to narrow the law, not to
re-describe the result.

## 8. THE BOUNDARY GATE

`bndarms9.sh` compiles every arm source of the adjacent passes with BOTH binaries
in the SAME directory and byte-compares; where bytes move it prints both heads
against that arm's own Surelog golden.

```
15 repro dirs, 143 arms:  IDENTICAL=133  MOVED=8  REJECT-BOTH=2
```

Every one of the 8 is `grid9.sh`-attributed to a cell THIS LAW NAMES, and every
one moves TOWARD golden:

| arm | cmp lines pristine → patched | cell |
|---|---|---|
| `r10uvm83repro/v83_a19_pkgtd_control` | 56 → 56 | `pa19::pkg_c_t` `PkgClassTs` **CONVERTED** (DEF → ELAB) |
| `r10uvm83repro/v83_a20_task_multi` | 191 → **32** | `int_typespec b_t` `ClassOther` **CONVERTED** (DEF → NONE) |
| `r10buvm5repro/a2_windowgrid` | 3 923 → **0**, head 1 → **0** | `q5::bi5_t` `PkgClassTs` **CONVERTED** |
| `r10buvm5repro/v4_moreinds` | 2 789 → **0**, head 1 → **0** | `qy::biy_t` `PkgClassTs` **CONVERTED** |
| `r10buvm5repro/a1_refvarbind` | 3 473 → **29** | same cell |
| `r10buvm5repro/v3_windows` | 4 145 → **29** | same cell |
| `r10buvm5repro/v5_depthctl` | 2 383 → **29** | same cell |
| `r10buvm5repro/v1_spelling` | 5 229 → **410** | same cell |

`REJECT-BOTH` = `r10buvm8repro/v5kinds8` and `r10uvm83repro/v83_a15_reexport`,
slang-rejected by BOTH binaries and therefore COUNTED, not silently skipped.

**An instrument bug found and fixed here, because it is the campaign's own
failure mode.** `bndarms9.sh` inherited `2>/dev/null` on its head counters.
`uhdm-cmp` writes **the head itself to STDERR** (measured: 95 stdout lines / 96
stderr lines on `v83_a20`), so `grep -c '^LHS:'` printed **0 for every arm** — a
head counter that reads "no head" on a database that has one.  The first reading
of the boundary gate in this pass was taken with that broken counter and is
therefore discarded; the numbers above come from the fixed one.

## 9. FILES

| file | what |
|---|---|
| `r10buvm9cen.cpp`, `build9.sh` | the census instrument: every typespec's `vpiInstance` with its LISTING membership (`TS`), every package listing in ORDER (`PKGTS`), every package's VIEW (`PKG`), every `ref_typespec`'s actual + that actual's instance (`REFTS`) — the last one is what turns "shared or cloned" into a POINTER fact |
| `arm9.sh`, `grid9.sh` | one arm golden-vs-ours; the three-way golden/pristine/patched cell table with verdicts |
| `v1inst9.sv` … `v4inst9.sv` | the 50 grid cells |
| `predict9.sh` | names the candidate movers from the PRISTINE databases only, before any byte comparison |
| `attrib9.sh` | the golden ↔ pristine ↔ patched join for ONE corpus database, with the four verdicts |
| `bndarms9.sh` | the boundary gate over 15 adjacent passes' arms (head counter FIXED, see §7) |
| `headset9.sh` | the seven-row head set (MiniAmiq included), pristine vs patched, plus a BYTE comparison of the cmp LOGS |
| `allsweeps9.sh`, `sweeps.sh`, `ct9rows.sh`, `byteverify.sh`, `canaries.sh`, `canaudit.sh`, `ctcan2.sh`, `rowheads.sh`, `detcheck.sh` | the gates |

### reproduce

```sh
./build9.sh
BIN=<binary> ./arm9.sh v2inst9.sv
PRISTINE=<79efb64 bin> PATCHED=<patched bin> ./grid9.sh v4inst9.sv
./allsweeps9.sh                                       # four sweeps, one at a time, --jobs 2
./predict9.sh /tmp/r10buvm9_wds_pristine              # predict FIRST
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh /tmp/r10buvm9_wds_patched /tmp/r10buvm9_wds_pristine
./attrib9.sh <patched wd> <pristine wd> default/BuildUVMPkg-bf853d43/slang.uhdm
PRISTINE=... PATCHED=... ./bndarms9.sh ../r10uvm83repro ../r10buvm5repro ...
./headset9.sh <patched wd> <pristine wd> /tmp/r10buvm9_heads
```

The ladder is `tools/probe/r10ladder1repro/ctladder.cpp`, built with the line in
that directory's README and run `<golden> <ours>`.
