# r10sd3 — § instanceIsNeverAClassDefn2 CLOSED, and the fix direction read off golden's cells

`r10sd2` proved the law and shipped it unfixed. This pass **fixes it**, and the
two things it had to decide first were decided by measurement, not by the law's
negative phrasing:

1. **What does golden put in those slots?** Not NULL — the class's **HOME
   PACKAGE**, in 30 of the 31 SeqDriver keys. The one key where golden *is* NULL
   is the in-body method, and the grid shows that is a second rule, not noise.
2. **Where do we mint them?** **Not** `ParamEmit.cpp` / `TaskFuncEmit.cpp`, which
   is where `r10sd2` §2 pointed. **One line**, in `ModuleEmit.cpp` —
   `drainFuncRet`, the per-reference return-name local. Found by tapping every
   one of the emitter's 179 `Instance()` setter calls, not by grepping casts.

The surplus population goes to **ZERO on all four UVM designs in both modes**,
which is the pass's success criterion, and the two SeqDriver rows' 1.4 M-line
head is measured **before and after** and is **unmoved** — the bonus question,
answered in the negative, by a real binary rather than an in-memory mutation.

| | |
|---|---|
| BASE | `19730ce` (printed and grep-checked in both worktrees) |
| worktrees | `/tmp/wt_r10sd3` (delivered), `/tmp/wt_r10sd3pris` (pristine control), `/tmp/wt_r10sd3dbg` (throwaway tap; **not** delivered) |
| delivered binary | md5 `eb2d9506c9c64c69afc90c16c3f49d08` |
| pristine binary | md5 `d90af4f662bab7e66f24bfe6258a8f9b` |
| patch | `/tmp/r10sd3.patch`, md5 in §10 |
| production files | `include/UhdmExporter.h` (+10), `src/ModuleEmit.cpp` (+22 −2), `src/TaskFuncEmit.cpp` (1 line) |

---

## 1. THE LAW

> **§ retNameLocalInstIsHomeNotClass3** — the per-reference **return-name LOCAL**
> variable that `drainFuncRet` mints for a body reference to a function's own
> name takes the **subroutine's own** `vpiInstance` — `emitTaskFuncs`' `tsInst`:
> the home **package** for a package-scope routine and for an **out-of-body**
> class method, and **nothing** for an in-class body or a class with no package
> home. It never takes the **listing owner**, which for a class method is the
> `class_defn`.
>
> The parent law it serves, measured by `r10sd2` and re-measured here:
> **§ instanceIsNeverAClassDefn2** — Surelog's `vpiInstance` names a scope that
> can hold an instance (a `package` in either view, a `module_inst`, an
> `interface_inst`, the `design`). It **NEVER** names a `class_defn`.

### 1.1 The population, before and after, both sides, both modes

`ct3cls.cpp` — the decode instrument — keys every object carrying a singular
`Instance()` by `(uhdmType | VpiName | line:col-endline:endcol)` and keeps the
whole **multiset** of instance states per key on each side. (`VpiFile` is
excluded from the key: our emission leaves it empty, and a file-keyed census of
these databases shares 35 of 20 397 keys and reads green — `r10sd2` R7.)

| design / mode | golden `class_defn` | ours BEFORE | ours AFTER |
|---|---|---|---|
| `default/SeqDriver` | 0 | **428** | **0** |
| `testflags/SeqDriver` | 0 | **428** | **0** |
| `default/SimpleUVM` | 0 | **216** | **0** |
| `testflags/SimpleUVM` | 0 | **216** | **0** |
| `default/Scoreboard` | 0 | **216** | **0** |
| `default/BuildUVMPkg` | 0 | **203** | **0** |
| `testflags/BuildUVMPkg` | 0 | **203** | **0** |

`testflags/Scoreboard` is `SLANG_REJECT` at baseline and produces no database —
counted as SKIP, never as agreement.

**The counts are 428 / 216 / 216 / 203, and that is the r10sd2-VERIFIER's F1
correction, independently reproduced here.** `r10sd2`'s own README says
`428 / 214 / 214 / 203`; three fresh emissions plus the sweep artifact all read
**216** on SimpleUVM and Scoreboard. The record's 214 is `428 / 2`, a number
derived by halving SeqDriver rather than read off its own census.

### 1.2 Where the 428 went (SeqDriver, `default`)

`ct3cls` section [A], the whole-database state totals:

| state | GOLDEN | OURS before | OURS after | Δ|deficit| |
|---|---|---|---|---|
| `<null>` | 34299 | 32039 | 32043 | **+4 closer** |
| `ALL:uvm_pkg` | 3489 | 3375 | 3481 | **106 closer** |
| `TOP:uvm_pkg` | 11290 | 6712 | 6818 | **106 closer** |
| `ALL:adpcm_pkg` | 1052 | 1544 | 1650 | 106 further (R3) |
| `TOP:adpcm_pkg` | 929 | 1403 | 1509 | 106 further (R3) |
| `OTHER:class_defn(*)` | **0** | **428** | **0** | **CLEARED** |

`4 + 106 × 4 = 428`, exactly. The 4 that became NULL are the **in-body** key
(`uvm_tlm_generic_payload`, the single `GOLDEN_NULL_ONLY` key) — and golden is
NULL there too. The `adpcm_pkg` pair moving further out is **not new breakage**:
adpcm_pkg already ran +492 / +474 long before this pass (`r10sd2` R3, the
`TOP:`-view deficit survey), and these 212 slots are the UVM classes re-listed
inside `adpcm_pkg` by the package-clone pass. R3 is unchanged in kind and is
re-ranked here as R2.

### 1.3 THE DECODE — what golden holds at the SAME key

This is the measurement the brief demanded before any code was written.
`ct3cls` section [B], `default/SeqDriver`, pristine binary:

| verdict | KEYS | SLOTS |
|---|---|---|
| `GOLDEN_NONNULL_ONLY` (golden holds a **package**, never a null) | **30** | **424** |
| `GOLDEN_NULL_ONLY` | 1 | 4 |

and cell for cell (section [C]):

```
  bit_typespec||2049:10-2049:13  ours class_defn x12      (uvm_reg.svh: function bit uvm_reg::has_reset)
      golden: ALL:uvm_pkg=1 TOP:uvm_pkg=4
      ours  : <null>=1 ALL:uvm_pkg=1 OTHER:class_defn(uvm_reg)=12 TOP:uvm_pkg=3
  bit_typespec||446:12-446:15    ours class_defn x4       (uvm_tlm2_generic_payload.svh: in-body do_compare)
      golden: <null>=1
      ours  : <null>=1 OTHER:class_defn(uvm_tlm_generic_payload)=4
```

**The fix direction is therefore RE-POINT, not NULL**, and the discriminator
between the two is **out-of-body-ness**, which is exactly what `tsInst` already
encodes. Had the law's negative phrasing ("never a class_defn") been implemented
as "null it", 424 of the 428 slots would have been made wrong in a new way.

`ct3site.cpp` closes the last degree of freedom — *which* package object:

```
HOME SCOPE the class_defn would re-point to (its VpiParent chain)
   428  TOP:uvm_pkg
```

All 428 class_defns live under the **elaborated** package (the def-view package
carries no `Class_defns` at all — `r10sd2` §3), so "the class's home scope" is
unambiguous and is view-matched by construction.

---

## 2. STATED GATE == CODE GATE

**STATED:** the per-reference return-name local's typespec takes the
subroutine's own instance (`tsInst`, captured at push time as
`PendingFuncRet::tsInst3`) instead of the listing owner (`pf.inst`). Nothing
else changes: every other consumer of `pf.inst` — the `pkgOnly` phase gate at
`ModuleEmit:20564`, the view detection at `20689`/`20756`/`20853`, the per-view
keys at `20790` — still reads `pf.inst`.

**CODE:**

```cpp
// src/ModuleEmit.cpp, drainFuncRet
-                if (pf.inst)
-                    ts->Instance(pf.inst);
+                if (pf.tsInst3)
+                    ts->Instance(pf.tsInst3);

// src/TaskFuncEmit.cpp, the push site (ONE token added at the end)
              tf, classScope, pkgImportCloneEmit, tsInst});

// include/UhdmExporter.h, PendingFuncRet
+        UHDM::instance* tsInst3 = nullptr;
```

`tsInst` is `emitTaskFuncs`' own local, unchanged since `r10uvm-era`:

```cpp
UHDM::instance* tsInst = (pkgScope && !classScope) ? (UHDM::instance*)m
                                                  : (oob ? oobHomePkg : nullptr);
```

so for a **non-class** scope the new expression is **identical** to the old one
(`oobDefs` is only populated when `classScope`, so `oob` implies `classScope`).
The change is a strict narrowing to class methods, and that is why the corpus
outside the four UVM rows does not move (§5).

---

## 3. HOW THE SITE WAS FOUND — the tap, and the refutation of r10sd2 §2

`r10sd2` §2 named the candidate emission sites by grepping C-style casts:
`ParamEmit.cpp:12912/12915/14858/14870` and `TaskFuncEmit.cpp:3453-3455`.
**None of them is the site.** All four `ParamEmit` sites take a `package*` out of
`pkgDefMap`/`pkgTopMap` (`std::map<const void*, UHDM::package*>` —
`UhdmExporter.h:3851/3855`), so they cannot hold a `class_defn` at all, and the
`TaskFuncEmit` site propagates an existing `Instance()` rather than minting one.
A cast is evidence of a *type mismatch*, not of *this* type mismatch.

What found it: `r10sd3_tap.py` rewrites **every** `->Instance(<arg>)` setter call
in `src/*.cpp` — 179 of them — to `->Instance(sd3tap(__FILE__,__LINE__,<arg>))`,
where `sd3tap` records the site whenever the value's `UhdmType()` is
`uhdmclass_defn`. One throwaway build, one SeqDriver run:

```
SD3TAP /tmp/wt_r10sd3dbg/src/ModuleEmit.cpp:20876 n=1
SD3TAP ...:20876 n=100  n=200  n=300  n=400  n=500
```

**One site, 526 stamps** (428 survive into the database; the rest are objects a
later pass re-stamps or that never reach a listing). The tap is a debug artifact
and is **not** in the delivered patch; `r10sd3_tap.py` and the header snippet it
installs are reproduced in `TAP.md` so the next pass can rebuild it in one step.

**An ops trap this cost, recorded:** the first tap accumulated into a
function-local `static std::map` and printed from a namespace-scope destructor.
The map is destroyed **first**, so the dump read freed memory and printed
`SD3TAP 0Re<garbage> 526` — a plausible-looking count attached to an unreadable
key. Leak the map (or print at tap time) instead.

---

## 4. THE GRID — golden's rule, cell for cell

`ct3grid.sh` over `grid/g*.sv`; LHS is always golden; each arm in its own scratch
dir; `sed 1d` on both dumps. `PRIS` = pristine `19730ce`, `NEW` = delivered.

| cell | shape | golden `vpiInstance` on the return-name local | OURS pris | OURS new | class_defn pris → new |
|---|---|---|---|---|---|
| `g1_pkg_oob` | package class, **out-of-body** method | **`package p1`** | `class_defn (p1::c1)` | **`package p1`** | **2 → 0** |
| `g2_pkg_inbody` | package class, in-body method | (no instanced ts at all) | — | — | 0 → 0 |
| `g3_unit_oob` | **`$unit`** class, out-of-body method | **`<null>`** | `class_defn (work@c3)` | **`<null>`** | **1 → 0** |
| `g4_mod_inbody` | **module** class, in-body method | (none) | — | — | 0 → 0 |
| `g5_pkg_oob_locals` | package class, oob method, string/bit/int/integer + foreach locals | **`package p5`** | `class_defn (p5::c5)` | **`package p5`** | **2 → 0** |
| `g6_pkg_two_classes` | **two** classes, one package, both oob | **`package p6`** (both) | `class_defn` ×2 names | **`package p6`** (both) | **4 → 0** |
| `g7_pkg_mixed` | ONE class with an oob **and** an in-body method | oob: `package p7`; in-body: none | `class_defn (p7::c7)` on the oob one only | **`package p7`** | **2 → 0** |
| `g8_pkg_virtual_extends` | base + derived, virtual in-body `do_cmp`, `super.` call | (none) | — | — | 0 → 0 |

**Eight cells, and the discriminator is isolated by `g7`**: one class, one
package, one view — the out-of-body method's return-name local is instanced and
the in-body one's is not. `g6` kills "the stamp is the class": two different
classes, one package, and golden names the **same package object** for both.
`g3` kills "always the home package": a `$unit`-homed class has no package and
golden writes NULL, which is what `tsInst` produces.

The g1 dump diff is the cleanest single witness — pristine vs golden:

```
 \_bit_typespec: , line:8:12, endln:8:15
   |vpiParent:
   \_ref_typespec: (p1::c1::f1::f1)
   |vpiInstance:
-  \_package: p1 (p1::)              <- GOLDEN
+  \_class_defn: (p1::c1)            <- OURS (pristine)
```

and with the delivered binary that hunk is **gone**: `DUMP_DIFF content 18 → 16`
on g1, `31 → 29` on g5, `36 → 32` on g6, `24 → 22` on g7, `249 → 247` on g3.
Every cell's cmp verdict is unchanged (`g1/g2/g4/g5/g6/g7/g8 PASS_CMP`;
`g3 CMP_FAIL` at 378 lines both binaries — its head is the `$unit`-class shape,
R5, not this law).

**EMPTY PRODUCT HUNT — clean.** No cell is vacuous: six of the eight carry at
least one class_defn-valued slot on the pristine side (2/0/1/0/2/4/2/0 = 11
slots across the grid), so `g2/g4/g8`'s "0 → 0" is read as a **control** and
labelled as one, never as a pass. Every cell produces both a golden and an ours
database (no `SURELOG_FAIL`).

---

## 5. THE MOVERS

### 5.1 Census-predict, made BEFORE the sweeps

`predict.sh` reads **source only** — no artifact — and marks a row a candidate if
it has (a) a package **and** an out-of-body subroutine definition, or (b) any
mention of UVM (whose `uvm_pkg.sv` is one package holding ~1000 out-of-body class
methods; a scan of the test directory alone misses all four UVM rows and is the
reason this predicate has two arms). Result: **2 u2r candidates**
(`func_typename_ret`, `hello-uvm`) and **59 surelog candidate rows**, the four
UVM designs among them.

That is an **upper bound**, stated as one: the predicate cannot see whether a
candidate's class methods ever *reference their own return name*, which is what
actually mints the object. The prediction with teeth is the one from §1.1: **the
four UVM databases, 428 / 216 / 216 / 203 slots, and nothing else measurably.**

### 5.2 Byte verifier, both corpora, both modes, vs the PRISTINE built here

| corpus | movers | paths | SELFCHECK | SELFCHECK1 |
|---|---|---|---|---|
| `uhdm2rtlil` | **0** | 1358 | 1357 / 1358 | 1 |
| `surelog` | **7** | 953 | 952 / 953 | 8 |

`PATH_SETS_IDENTICAL` on both. The seven surelog movers are **exactly** the seven
live UVM rows and nothing else:

```
MOVER ./default/BuildUVMPkg-*/slang.uhdm
MOVER ./default/Scoreboard-*/slang.uhdm
MOVER ./default/SeqDriver-*/slang.uhdm
MOVER ./default/SimpleUVM-*/slang.uhdm
MOVER ./testflags/BuildUVMPkg-*/slang.uhdm
MOVER ./testflags/SeqDriver-*/slang.uhdm
MOVER ./testflags/SimpleUVM-*/slang.uhdm
```

**Judged by SIZE-DELTA, never by hash inequality** (the scoreboard is
multi-stable and `default/Scoreboard` is hash-unstable with the *same* binary on
both sides — `r10sd2` R8), **3 reps on BOTH binaries**, each row re-emitted from
its own test directory with its own `cmds.txt` argv:

| design | pristine size (3 reps) | delivered size (3 reps) | SIZE-DELTA | hash stable? |
|---|---|---|---|---|
| `SeqDriver` | 17962372 ×3 | 17962228 ×3 | **−144** | yes, both binaries |
| `SimpleUVM` | 11118646 ×3 | 11118556 ×3 | **−90** | yes, both binaries |
| `Scoreboard` | 11122938 ×3 | 11122848 ×3 | **−90** | **no** — 3 distinct hashes on the pristine binary at one fixed size (R8); the SIZE is the discriminator and it is stable |
| `BuildUVMPkg` | 11097319 ×3 | 11097258 ×3 | **−61** | yes, both binaries |

All four are **real** movers: the size is constant within a binary and differs
between binaries. Scoreboard is the cell that proves why the standing law says
SIZE — its hash moves with the binary held fixed.

### 5.3 Per-shape mover analysis, by MULTISET, ADDED and REMOVED separately

Per shape, `default/SeqDriver`, `sed 1d` on both dumps, `msdist.sh` (a
multiset distance, not an LCS count):

```
                     golden-only   ours-only   MULTISET DISTANCE
pristine 19730ce        264346      101324           365670
delivered               264333      101311           365644          (-26)
```

The `vpiInstance` shape itself, from `ct3cls` [A] (the only shape that moves):

| shape | ADDED (ours gains) | REMOVED (ours loses) |
|---|---|---|
| `vpiInstance -> class_defn(*)` | — | **428** |
| `vpiInstance -> ALL:uvm_pkg` | +106 | — |
| `vpiInstance -> TOP:uvm_pkg` | +106 | — |
| `vpiInstance -> ALL:adpcm_pkg` | +106 | — |
| `vpiInstance -> TOP:adpcm_pkg` | +106 | — |
| `vpiInstance -> <null>` | +4 | — |

### 5.4 The SeqDriver head — the BONUS measurement, answered

| row | pristine `19730ce` | delivered | head LHS / RHS |
|---|---|---|---|
| `default/SeqDriver` | **1414877** | **1414877** | `<null>` / `package uvm_pkg id:6040` |
| `testflags/SeqDriver` | **1414877** | **1414877** | `<null>` / `package uvm_pkg id:6052` |
| `default/SimpleUVM` | 54 | 54 | `int_var (uvm_pkg::uvm_tr_stream::get_recorders)@371:13` / `logic_var` same span |
| `testflags/SimpleUVM` | 54 | 54 | same |
| `default/Scoreboard` | 54 | 54 | same |
| `default/BuildUVMPkg` | 58 | 58 | `ref_obj (…uvm_deferred_init)@14107:7` / `hier_path (uvm_pkg::uvm_deferred_init.push_back)` |
| `testflags/BuildUVMPkg` | 58 | 58 | same |

**The SeqDriver head does NOT clear**, byte for byte, same RHS object id. This
independently confirms `r10sd2` §4.4 hypothesis 1 — which reached the same
verdict by nulling the 428 slots **in memory** — with a real binary that
**re-points** them instead. The head is a different `vpiInstance` slot; sd2's R1
(set-valued ddmin over the 34 `class_typespec` chokepoints) remains the
instrument that will close it.

Every head is `grep -c '^LHS:' == 1`; the 1 414 877 is **subtree size**, not
distance.

**A baseline correction for the next pass:** the other three rows' heads have
moved again since `r10sd2` recorded them. SimpleUVM/Scoreboard are **54** lines
on an `int_var`/`logic_var` `@371:13` shape, not the 112-line
`func_call`/`method_func_call` `@343` shape sd2 measured at `6e1c27a` (uvm69/70
landed in between). Any pass quoting sd2's numbers without re-measuring
mis-reads its own baseline — the same trap sd2 recorded against its own brief.

---

## 6. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line waited for, md5 asserted separately, 32-hex baseline | `/tmp/wt_r10sd3` and `/tmp/wt_r10sd3pris`, both `BASE 19730ce…` grep-checked (`rev-parse \| grep -c` = 1), both `error:` count **0**, both `Linking CXX executable slang-uhdm` seen before any md5 was read; delivered **`eb2d9506c9c64c69afc90c16c3f49d08`**, pristine **`d90af4f662bab7e66f24bfe6258a8f9b`** — 32 hex each, **different**, as a real patch requires |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | testflags j2 679/50/2, dump 496/183/52, `ct8rows` 0 rows | default **679 / 50 / 2**, testflags **679 / 50 / 2**; dump **496 match / 183 differ / 52 blank**, base == fresh; `ct8rows` **0 differing ROWS (0 row-sides)**, `PASS: every row byte-identical` |
| **4 surelog** | both j2 469/11 + 465/8 (FAIL 25/23, DEFER 5/5), histograms unchanged, 0 rows | default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT**; testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM); `ct8rows` **0 differing ROWS**, all **4 dump histograms identical** (default 225 match / 244 differ / 325 blank; testflags 165 / 300 / 329) |
| **5 BYTE VERIFIER** | both corpora both modes vs PRISTINE built here, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | u2r **0 / 1358**, surelog **7 / 953**, `PATH_SETS_IDENTICAL` both; SELFCHECK **1357/1358** and **952/953**; SELFCHECK1 **1** and **8**. The 7 movers are the 7 live UVM rows — **the predicted set** (§5.1/§5.2), judged by SIZE-DELTA over 3 reps on both binaries (§5.3) |

`GOLDEN_DEFER` was printed as `[UNSET]` before every sweep. All sweeps
`--jobs 2` with private `--out`/`--workdir`, `SLANG_UHDM` **pinned and verified
by reading `cmds.txt`** (r10sd2-verifier F4: `verify_golden.py` silently defaults
it to the MAIN-TREE binary). `results/*.csv` were READ ONLY. No `git stash`.

**GATE-3 trap, re-encoded:** `results/gate_uhdm2rtlil.csv` holds **testflags rows
only**; the fresh both-modes CSV is filtered to testflags before `ct8rows.sh`
sees it, or all 731 default rows read as ADDED.

**CANARIES**

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names **7** (the documented u2r-only names) |
| `canaries.sh` u2r | at baseline | **ok=8 changed=0 absent=0**, unknown-names **25** (documented) |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1`, mode-matched | **ok=58 changed=0 absent=0 unknown-patterns=1**, PASS |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6`, testflags-only CSV | **ok=1 changed=0 absent=0 unknown-patterns=6**, PASS |
| `canaudit.sh` | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, PASS |
| fenced names | dispatched by no driver | `UnsignedParam` `HierPathEval` `FileLocalParam` `TopParam` — **not dispatched by any driver** |
| `InterfaceModPort`, `BlackParrotComplex` **by name** | at baseline | both `OK CMP_EQUAL/differ`, **both modes** |
| the four UVM names **by name** | at baseline | `SeqDriver`, `SimpleUVM`, `BuildUVMPkg` `OK CMP_NOTEQUAL` both modes; `Scoreboard` `OK CMP_NOTEQUAL`(default) / `SLANG_REJECT`(testflags) |

**BOUNDARIES.**

* `§ classTdSpecParamsForeignHome1` (`UhdmExporter.cpp ~2682`, typedef
  specializations, sd1's b1–b28 grid): **untouched** — `UhdmExporter.cpp` is not
  in this patch's file set at all.
* Live pass `r10uvm70` (bare-unsigned return var) — **`src/TaskFuncEmit.cpp` is
  SHARED and this pass touches it. COLLISION, REPORTED as the standing rules
  require.** The hunk is **one line**, at `TaskFuncEmit.cpp:5158`, appending a
  single initializer token (`tsInst`) to the existing `pendingFuncRet.push_back`
  aggregate. It adds no statement, changes no control flow and reads no new
  state. It will textually conflict only with an edit to that same
  `push_back` initializer; an integrator resolving it keeps both changes and
  the trailing `, tsInst` — the field is last in `PendingFuncRet`.
* Live pass `r10earl41` (`TypeEmit.cpp` / `ExprEmit.cpp`): **file-set
  intersection empty.**
* `sd2`-verifier **F3** (`design.Param_assigns` / `Parameters` NULL vs 45 on
  SimpleUVM/Scoreboard, masked behind their `AllModules` head): **verified
  untouched.** `ct3cls` [A] shows those rows' `OTHER:design()` cells identical
  before and after (SimpleUVM 34 golden / 35 ours both binaries; Scoreboard
  34 / 0 golden and 35 `design(force_time)` ours both binaries), and the
  design-object families are not in this patch's reach.

---

## 7. RESIDUES, RANKED

1. **R1 — the SeqDriver head, both rows, 1 414 877 lines. STILL OPEN, and now
   proved not to be this law** (§5.4, with a real binary rather than sd2's
   in-memory mutation). sd2's localization stands: a **singular `vpiInstance`**
   slot, NULL in golden, holding our **`TopPackages`** copy of `uvm_pkg`, inside
   `class_defn(uvm_coreservice_t)@49:9-113:9`, reachable only through
   `class_typespec@199:3-199:20` (`uvm_globals.svh`) but by ≥ 2 disjoint routes
   below it. The instrument that will finish it is a **set-valued ddmin** over
   the 34 `class_typespec` chokepoints — `ct2owner.cpp` (carried forward here)
   already has the operator and the pool; only the subset search needs widening.
   **And there is now a much cheaper way to get its site once it is localized:
   the tap (§3).**
2. **R2 — `adpcm_pkg` runs LONG on both views and this pass added 212 to it**
   (`ALL:` +492 → +598, `TOP:` +474 → +580 against golden). Same mechanism as
   sd2's R3 in mirror image: our package-clone pass re-lists the UVM classes
   inside the importing package, so their out-of-body method locals take
   `adpcm_pkg` where golden takes `uvm_pkg`. The census that scores it is one
   `ct3cls` line. Cheapest next survey, and the only place this pass moved a
   number the wrong way.
3. **R3 — `TOP:uvm_pkg` is still 4472 short on SeqDriver** (11290 golden vs 6818
   ours), 644 / 589 / 534 short on the other three. This pass closed 106 of it.
   One mechanism — which package VIEW an emitted typespec is stamped with —
   plausibly explains R1 too, since the head's RHS is precisely a `TOP:` object.
4. **R4 — we emit MORE objects than golden at the very keys this law lives on.**
   `bit_typespec||2049:10-2049:13`: golden 5 objects, ours 9 (grid g1: golden 3,
   ours 5). The extra copies are `weaklyReferenced` and cmp-invisible, but they
   are why `ALL:p1` reads 5 vs golden's 4 in g1 **after** the fix — the stamp is
   right, the population is not. A per-view duplication survey would score it.
5. **R5 — `g3_unit_oob`: `CMP_FAIL` at 378 lines, both binaries.** A `$unit`-scope
   class with an out-of-body method: a 10-line reproducer of the `$unit`-home
   family (same family as sd2's R5 / uvm67 residue 2). Untouched here; the cell
   is ready-made.
6. **R6 — `r10sd2` §2's named emission sites are all wrong** (§3). Recorded so no
   pass re-greps casts expecting to find this family there. The general lesson:
   a C-style cast marks a type mismatch, not *the* type mismatch; the tap is
   cheap (one build) and decisive.
7. **R7 — the `VpiFile` blind spot survives** (sd2 R7): our emission leaves
   `VpiFile` empty on nearly every object, so a file-keyed census of these
   databases shares 35 of 20 397 keys and reads green. `ct3cls`/`ct3site` exclude
   it from the key and `ct3site` recovers the file from **golden's** twin.
8. **R8 — `default/Scoreboard` is hash-unstable with the SAME binary on both
   sides** (sd2 R8). It is a real mover in this pass (its class_defn population
   goes 216 → 0), so the hash difference is not evidence either way; the
   evidence is the census.

---

## 8. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct3cls.cpp` | **THE DECODE INSTRUMENT.** Span-keyed, multiset `vpiInstance` census that, for every key where OUR multiset holds a `class_defn`, prints GOLDEN's multiset for the same key and classifies it (`GOLDEN_NULL_ONLY` / `GOLDEN_NONNULL_ONLY` / `GOLDEN_MIXED` / `KEY_ABSENT_IN_GOLDEN`). One run answers "null it or re-point it". |
| `ct3site.cpp` | Parent-chain shapes and source files of every `class_defn`-valued slot (file recovered from golden's twin — ours is empty), plus the **home-scope histogram**: which object "the class's home scope" resolves to, view included. |
| `predict.sh` | Source-only mover prediction, run before the sweeps. Two arms (package+out-of-body, or any UVM mention) — the second exists because the four UVM rows spell the shape in `third_party/UVM`, not in their own test directory. |
| `ct3arm.sh` / `ct3grid.sh` | Single-arm and grid drivers. LHS always golden, `sed 1d` both dumps, missing-input guards (uhdm-cmp exits 0 on a missing file), per-arm scratch dir (Surelog synthesises `builtin.sv` into the CWD). `ct3grid.sh` scores each cell with `ct3cls`. |
| `grid/g1…g8.sv` | The eight cells of §4. |
| `TAP.md` | The throwaway `Instance()` tap of §3 — the rewriter, the header snippet, the static-destruction trap, and how to rebuild it in one step. |
| `ct2view.cpp` `ct2inst.cpp` `ct2owner.cpp` `ct2vclsdefn.cpp` `ct2design.cpp` `ct2pkgv.cpp` `ct2mut.cpp` | carried forward from `r10sd2repro` unchanged (`ct2owner.cpp` is R1's instrument; `ct2vclsdefn.cpp` is the verifier's F2 addition). |
| `byteverify.sh` `manifest.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `msdist.sh` `rowheads.sh` `dumptree.py` `census.py` `slots.py` `cells.py` `ct2rels.inc` | carried forward unchanged. |

---

## 9. REFUTATIONS, STATED PLAINLY

1. **"The law says `vpiInstance` is never a `class_defn`, so null those slots" is
   WRONG** — and it is the reading the law's own phrasing invites. Golden holds
   the **home package** in 424 of the 428 SeqDriver slots (§1.3). Nulling would
   have replaced one wrong value with another in 30 of 31 keys.
2. **`r10sd2` §2's emission sites are REFUTED** (§3). `ParamEmit.cpp:12912/12915/
   14858/14870` read `package*` maps and cannot hold a class_defn;
   `TaskFuncEmit.cpp:3453-3455` propagates rather than mints. The site is
   `ModuleEmit.cpp:20876`, in a file sd2 never named.
3. **`r10sd2`'s count `428 / 214 / 214 / 203` is REFUTED; it is
   `428 / 216 / 216 / 203`** — the verifier's F1, reproduced here independently
   on freshly emitted databases. 214 is `428/2`.
4. **"It is one rule" is REFUTED.** There are two, and `g7` separates them inside
   a single class: out-of-body → the home package; in-body → nothing. The UVM
   census contains exactly one witness of the second (`uvm_tlm_generic_payload`,
   4 slots) and it would have been dismissed as noise without the grid.
5. **"Fixing the class_defn slots may clear the SeqDriver head" — REFUTED, by
   measurement, before and after** (§5.4). Unmoved at 1 414 877 lines with the
   same RHS object id. sd2 reached the same answer by mutation; this is the
   same answer from a shipped binary.
6. **"`pf.inst` is the instance the return local wants" is REFUTED** — it is the
   **listing owner**, and the two coincide for every scope except a class. That
   is why the fix adds a field rather than changing `pf.inst`: four other
   consumers of `pf.inst` (§2) genuinely want the listing owner.
7. **A `static` map printed from a `static` destructor is not a measurement**
   (§3): the map is destroyed first and the printout is a plausible count on a
   garbage key.

---

## 10. THE PATCH

`/tmp/r10sd3.patch` — `git diff` vs `19730ce`, `include/` + `src/` +
`tools/probe/r10sd3repro/` only. Reproducible with:

```sh
cd /tmp/wt_r10sd3 && git add -A tools/probe/r10sd3repro
git diff 19730ce --binary -- include src tools/probe/r10sd3repro > /tmp/r10sd3.patch
md5sum /tmp/r10sd3.patch
```

md5: **deliberately NOT recorded in this file.** The patch contains this file,
so any md5 written here is stale the moment it is written — a self-referential
number that reads like a checksum and cannot be one. The md5 is delivered with
the patch (the pass's final report) and is reproducible in one line with the
command above.

**PATCH HYGIENE.** Applies clean to a fresh `19730ce` (`git apply --check`
rc=0), reproduces `tools/probe/r10sd3repro/` **byte-for-byte** (`diff -r` empty),
and leaves exactly **4** porcelain entries: the three production files and the
probe directory. `git diff 19730ce -- src include` is the three files of §2 and
nothing else. The throwaway tap worktree (`/tmp/wt_r10sd3dbg`) contributes
nothing to the patch; its method is `TAP.md` + `r10sd3_tap.py` (documentation and
a rewriter, not a build input).

## 11. LANDING NOTE

`src/TaskFuncEmit.cpp` is shared with live pass `r10uvm70` — the collision is
declared in §6 BOUNDARIES rather than hidden. This pass's hunk there is one
line: appending `, tsInst` to the existing `pendingFuncRet.push_back` aggregate
initializer at `TaskFuncEmit.cpp:5158`. Both changes can be kept; the new field
is last in `PendingFuncRet`, so the appended initializer stays last.

This directory's `README.verifier.md`, when written, must be **this** pass's —
`r10sd2repro/README.verifier.md` is that pass's record and is not carried
forward here (its F1/F2/F3 findings are cited in §1.1, §5.4 and §6 by name).
