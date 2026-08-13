# r10sd4 — the PACKAGE WALL, READ instead of inferred: § classHomedTypeTsNoPkgInstance4

**The BuildUVMPkg wall is CLEARED — 1 366 893 cmp lines → 94, both rows — by
one predicate at two call sites, and the whole change is TWO dump lines and ONE
`vpiInstance` slot.** The SeqDriver wall is *not* cleared; it is a **different
head with a different owner, a different arm site and a different emitter
function**, all three now named, and that is R1.

The pass's real product is the localization method. Three passes (`r10sd1`,
`r10sd2`, `r10sd3`) inferred this head from suppression experiments and got the
arm, the relation and the owner class wrong in ways that each looked like a
result. This pass **read the caller** — a gdb hardware watchpoint on
`CompareContext::m_failedRhs` — and every earlier inference that contradicted
the readout is refuted below with the measurement that killed it.

| | |
|---|---|
| BASE | `38f308e` (printed and grep-checked in both worktrees) |
| worktrees | `/tmp/wt_r10sd4` (delivered), `/tmp/wt_r10sd4pris` (pristine control), `/tmp/wt_r10sd4dbg` (throwaway tap; **not** delivered) |
| delivered binary | md5 `3c43e9f28022dc732c0e840400eb54a4` |
| pristine binary | md5 `129c3164f6f62f6c9cefda43aa3608fd` |
| production files | `src/TaskFuncEmit.cpp` only (+36 −2) |
| probe files | `tools/probe/r10sd4repro/` |

---

## 1. THE LAW

> **§ classHomedTypeTsNoPkgInstance4** — a typespec whose **TYPE is declared
> inside a class** never carries a package `vpiInstance`, **whatever scope the
> DECLARATION that uses it sits in**. Only a type homed in the package (or the
> module) takes the home instance.
>
> It bites in the array-local helpers because our emission creates **ONE
> typespec per typedef and SHARES it**: a class method's queue / dynamic /
> associative **local** stamps the home package — correctly, by
> § queueLocalElemTsInstance40 and § assocLocalArrayVar40, *for a package-homed
> element type* — onto the very object the class's own **data member** points
> at, and the data member is where `uhdm-cmp` reaches it.

**The head this closes**, named object for object (§3):

```
BuildUVMPkg   golden  struct_typespec(m_inst_typename_alias_t)@11964:11-11968:4  Instance <null>
              ours    same key                                                   Instance TOP:uvm_pkg
              owner   struct_var@11973:38  <-  array_var(m_inst_aliases)
                                           <-  class_defn(uvm_default_factory)
```

`m_inst_typename_alias_t` is a `typedef struct` declared **inside**
`class uvm_default_factory`; `m_inst_aliases[$]` is that class's own queue data
member. The stamp arrives from the class's **out-of-body method locals** of the
same type, through the shared typespec.

---

## 2. STATED GATE == CODE GATE

**STATED:** the element typespec of a queue / dynamic-array (site 1) or
associative-array (site 2) declaration takes `tsInst` **unless the element type
is class-homed**. Nothing else changes: `tsInst` itself, the `!elemTs->Instance()`
guard, both array shapes, both `promoteNamed` views and every other consumer are
untouched.

**CODE** (`src/TaskFuncEmit.cpp`):

```cpp
static bool classHomedType4(const Type* t) {
    if (!t) return false;
    if (const Scope* sc = t->getParentScope())
        if (sc->asSymbol().kind == SymbolKind::ClassType) return true;
    if (const Scope* sc = t->getCanonicalType().getParentScope())
        if (sc->asSymbol().kind == SymbolKind::ClassType) return true;
    return false;
}

// site 1 of 2 — makeQueueDynArrayVar
-    if (elemTs && tsInst && !elemTs->Instance())
+    if (elemTs && tsInst && !elemTs->Instance() && !classHomedType4(qelem0))
         elemTs->Instance(tsInst);

// site 2 of 2 — makeAssocArrayVar
-    if (elemTs && tsInst && !elemTs->Instance())
+    if (elemTs && tsInst && !elemTs->Instance() && !classHomedType4(elem0))
         elemTs->Instance(tsInst);
```

The predicate tests **both** the written type and its canonical type, because a
`typedef` inside a class reaches the site as a `TypeAliasType` in some paths and
as the aliased `StructType` in others; either spelling must answer the same.

**The second site was MEASURED, not generalised.** Grid cell `q11` is the
associative twin of `q9` and was run on the pristine binary *before* the code was
written; golden is `<null>` there too (§4). Had it disagreed, the gate would have
gone on site 1 alone.

---

## 3. HOW THE OWNER WAS FOUND — and why three passes could not find it

### 3.1 The cost model that made the search trivial

`design::Compare` **aborts at the first failure**, so one whole-design compare of
the SeqDriver pair costs **~1.5 ms** — the 1.4 M cmp lines are the failing
object's SUBTREE DUMP, not a traversal count. `r10sd2` built a ddmin because it
assumed the opposite. Measured here: `m_visited` holds **1613** objects when the
baseline compare returns, out of **316 922** reachable and ~400 k serialized.

That collapses the whole problem: every candidate pool this campaign has argued
about can be scanned **exhaustively, one object at a time**, in seconds
(`ct4scan`). Three pools were scanned and all three agree:

| pool | size | singleton killers | wall time |
|---|---|---|---|
| golden objects with a NULL singular `Instance()` | 34 299 | 4 | 8 s |
| every REACHABLE golden object | 316 922 | **16** | 7 min |
| **`m_visited` after the baseline run** | **1613** | **16** | **2 s** |

The `m_visited` pool is the one that cannot miss and cannot be padded: every
generated `Compare` opens with `m_visited.insert(this)`, so the owner is
necessarily in it. It returns the identical 16 killers the 317 k-object scan
returns — a **negative control on the pool itself**.

### 3.2 …and why the killers still do not name the owner

They do not, and this is the trap that cost `r10sd2` its conclusion. The kill
test asks "did the head's SIGNATURE go away?", and **Surelog emits every package
TWICE** (def view in `uhdmallPackages`, elab view in `uhdmtopPackages`), so a
failure suppressed in one view **recurs with the same shape and the same
`m_failedRhs` POINTER** in the other. Measured (`ct4mut2` section [D]):

```
suppress golden ALL-view uvm_pkg -> r=-1 lhs=<null> rhs=package(uvm_pkg)  visited 1613 -> 2143
suppress golden TOP-view uvm_pkg -> r=-1 lhs=<null> rhs=package(uvm_pkg)  visited 1613 -> 2005
```

Identical triple; **only `m_visited` moves**. `r10sd2` §4.1 seeded exactly these
objects, read "byte-identical", and concluded *the vector arm is ruled out*. The
arm conclusion happens to be right (§3.4) and **the reason recorded for it is
not**.

### 3.3 Two mutation scans that returned NOTHING, and that is the finding

Both were run on OUR side, one slot at a time — the form sd2's bulk mutation
could not take, since bulk nulling flips the arm to an introduced earlier
failure (`r10sd2` §4.4.2, reproduced here as 15 `INTRODUCED` rows):

* **`ct4mut2`** — all **6818** of our objects whose singular `Instance()` **is
  the failing RHS pointer**, nulled one at a time, restore control clean:
  **0 removed the head.** (`ct4ref` proves 6818 is the complete population: a
  154-relation sweep of the whole database finds `vpiInstance` slots and
  `design.uhdmtopPackages[]` and nothing else pointing at that object.)
* **`ct4vec`** — all **25** vectors `package::Compare` walks, nulled on our
  failing package, both views: **0 removed the head.** That rules out the VECTOR
  arm on that container, by measurement.

So the head is a singular `vpiInstance` slot that is **not** any of the 6818 —
a contradiction, and the point at which inference was abandoned.

### 3.4 The readout

`SafeCompare` is a `static inline` in `BaseClass.h` and has no symbol of its own,
but `CompareContext::m_failedRhs` is a plain member. `ct4bt` + `ct4bt.gdb` put a
**hardware watchpoint** on it and stop at the store:

```
#0  UHDM::typespec::Compare(...)          <-- generated/src/typespec.cpp:94
#1  UHDM::bit_typespec::Compare(...)          SafeCompare(lhs->Instance(), rhs->Instance())
#2  UHDM::variables::Compare(...)
#3  UHDM::bit_var::Compare(...)
#4  SafeCompare<UHDM::variables>(...)         <-- scope::Compare's Variables vector
#5  UHDM::scope::Compare(...)
#6  UHDM::class_defn::Compare(...)
#7  UHDM::type_parameter::Compare(...)
```

**It IS the singular `vpiInstance` arm, and the owner is a `typespec`** — so
sd2's relation was right and its localization was not. `libuhdm.a` carries no
DWARF, so the objects were recovered by scanning the stopped frame's stack
through a pointer-identity oracle compiled into the probe (`SHOW1`), which names
any word that is a live object in either serializer:

```
SeqDriver     GOLDEN bit_typespec@26:1-26:4                     OURS bit_typespec@26:1-26:4
              GOLDEN bit_var(uvm_start_uvm_declarations)@26:5-26:31   OURS  ...@26:5-26:35
              class_defn(adpcm_seq_item)  <- type_parameter(T)  <- class_typespec(type_id)@440:12
BuildUVMPkg   GOLDEN struct_typespec(m_inst_typename_alias_t)@11964:11-11968:4   OURS same key
              struct_var@11973:38  <- class_defn(uvm_default_factory)
```

**Why `ct4mut2` missed it.** OUR `bit_typespec@26:1-26:4` is a **shared** object
compared at two positions: at the earlier one golden's twin holds a package, so
nulling it introduces an `r=1` failure *there* and the tool classified it as
`INTRODUCED`. Sharing is the mechanism of BOTH heads, and it is invisible to any
instrument that reasons per key instead of per object.

### 3.5 The emitter site

`r10sd4_tap.py` (this pass's tap; `r10sd3`'s wrapped the ARGUMENT, this one
wraps the **OWNER**, recovered by scanning backward over a balanced postfix
expression) rewrites all **175** `->Instance(` setters. One throwaway build, one
run per design:

```
BuildUVMPkg   SD4OWN src/TaskFuncEmit.cpp:1128   m_inst_typename_alias_t|11964:11-11968:4
SeqDriver     SD4OWN src/ParamEmit.cpp:20498     |26:1-26:4      (x2, one per package view)
```

**Two different sites for the two walls.** `TaskFuncEmit.cpp:1128` is
`makeQueueDynArrayVar` — this pass's fix. `ParamEmit.cpp:20498` is the
package-variable emitter, and its stamp is **correct** (golden's package-listed
copies carry the package); SeqDriver's defect is downstream of it, in the
listing that shares that object into a class (§7 R1).

---

## 4. THE GRID — golden's rule, cell for cell

`ct4grid.sh` over `grid/q*.sv`; LHS always golden; `sed 1d` both dumps; per-arm
scratch dir. `PRIS` = `38f308e`, `NEW` = delivered. The scored cell is the
element typespec's `vpiInstance`, read with `ct4key` (whole multiset per key,
both sides).

| cell | shape | golden | OURS pris | OURS new | cmp pris → new | dump pris → new |
|---|---|---|---|---|---|---|
| `q9_clstype_oob_local` | **typedef in the CLASS**, used as class queue member **and** oob-method local | **`<null>`** | `TOP:p9` | **`<null>`** | CMP_FAIL → CMP_FAIL | **58 → 56** |
| `q10_pkgtype_oob_local` | the SAME program, typedef moved to the PACKAGE | `ALL:p10 TOP:p10` | `ALL:p10 TOP:p10` | unchanged | PASS_CMP → PASS_CMP | 42 → 42 |
| `q11_clstype_assoc_local` | q9's **ASSOCIATIVE** twin (site 2) | **`<null>`** | `TOP:p11` | **`<null>`** | CMP_FAIL → CMP_FAIL | **72 → 70** |
| `q1_cls_member_queue_struct` | class queue member, **no method local** | `<null>` | `<null>` | `<null>` | PASS_CMP → PASS_CMP | 26 → 26 |
| `q2_pkg_func_queue` | § queueLocalElemTsInstance40's own precedent: package free function local | `ALL:p2 TOP:p2` | same | unchanged | PASS_CMP → PASS_CMP | 4 → 4 |
| `q3_oob_method_queue` | oob class-method local, **package-homed** element | package | same | unchanged | PASS_CMP → PASS_CMP | 26 → 26 |
| `q4_inbody_method_queue` | in-body class-method local (`tsInst` null already) | — | — | unchanged | PASS_CMP → PASS_CMP | 36 → 36 |
| `q5_pkg_var_queue` | package-scope queue variable, no class | package | same | unchanged | PASS_CMP → PASS_CMP | 6 → 6 |
| `q6_mod_cls_member_queue` | class in a MODULE (no home package at all) | `<null>` | `<null>` | unchanged | PASS_CMP → PASS_CMP | 2 → 2 |
| `q7_cls_member_dynarray` | the DYNAMIC-array spelling of q1 | `<null>` | `<null>` | unchanged | PASS_CMP → PASS_CMP | 16 → 16 |
| `q8_cls_member_queue_pkgtype` | class queue member, **package-homed** element type | package | same | unchanged | PASS_CMP → PASS_CMP | 2 → 2 |

**`q9` vs `q10` IS the discriminator, and they are the same program.** One line
moves — the `typedef` — and golden's answer flips from `<null>` to the package.
`q8` closes the other degree of freedom in the other direction: a class **data
member** whose element type is package-homed keeps the stamp, so the rule keys on
the **TYPE's home**, not on the DECLARATION's.

**Cell-for-cell verdict on the fixed cells** (`ct4key`, delivered binary):

```
q9   GOLDEN struct_typespec(t9_t)@8:13-8:40  inst=<null>
     OURS   struct_typespec(t9_t)@8:13-8:40  inst=<null>      <== EQUAL
q11  GOLDEN struct_typespec(t11_t)@7:13-7:40 inst=<null>
     OURS   struct_typespec(t11_t)@7:13-7:40 inst=<null>      <== EQUAL
```

`q9`/`q11` still `CMP_FAIL`, on a **different, unchanged shape** —
`LHS: ref_var(p9::c9::f9::l9)` — before and after. That is a residue (R4), not a
regression: the dump content **falls** (58→56, 72→70) and the scored cell
converges.

**EMPTY PRODUCT HUNT — clean.** Every cell produces both a golden and an ours
database (no `SURELOG_FAIL`), and every cell carries at least one instanced
typespec on the thinner side, so no `unchanged` verdict is agreement that costs
nothing. The three cells that move (q9, q11, and the BuildUVMPkg rows) are
**exactly** the cells whose element type is class-homed **and** whose type is also
used by a method local; `q1`/`q7` prove the class-member-alone case was already
right and must not move, and they do not.

---

## 5. THE MOVERS

### 5.1 Census-predict, made BEFORE the sweeps

`predict4.sh` reads **source only** and scores (a) an unbounded/associative
dimension and (b) a `typedef` between `class`/`endclass`; the third condition —
a non-null `tsInst`, i.e. a package free function or an out-of-body method — is
not visible without elaborating and the predicate says so. Result: **35
candidate rows, stated as an UPPER BOUND**, the four UVM designs among them.

The prediction with teeth was made from the artifact instead, before any sweep:
**`ct4reach`'s reachable `vpiInstance` census on the two target designs**, which
says BuildUVMPkg moves **one slot** and SeqDriver moves **none**.

### 5.2 The two target designs, before and after (reachable, per shape)

`ct4reach` section [A], `default`, golden held fixed:

| design | state | GOLDEN | OURS pris | OURS new |
|---|---|---|---|---|
| **BuildUVMPkg** | `<null>` | 22763 | 23629 | **23630** |
| | `ALL:uvm_pkg` | 3613 | 3411 | 3411 |
| | `TOP:uvm_pkg` | 4081 | 3547 | **3546** |
| **SeqDriver** | `<null>` | 34290 | 31299 | 31299 |
| | `ALL:adpcm_pkg` | 1052 | 1539 | 1539 |
| | `ALL:uvm_pkg` | 3489 | 3331 | 3331 |
| | `TOP:adpcm_pkg` | 929 | 1403 | 1403 |
| | `TOP:uvm_pkg` | 11290 | 6742 | 6742 |

**ONE slot moves on BuildUVMPkg. ZERO on SeqDriver.** One slot clears a
1 366 893-line head.

### 5.3 Per-shape movers, by MULTISET, ADDED and REMOVED separately

`msdist.sh`, `default/BuildUVMPkg`, `sed 1d` both dumps:

```
                golden-only   ours-only   MULTISET DISTANCE
pristine 38f308e     53330       26289          79619
delivered            53330       26287          79617   (-2)
```

| shape | ADDED (ours gains) | REMOVED (ours loses) |
|---|---|---|
| `vpiInstance -> TOP:uvm_pkg` | — | **1** |
| `vpiInstance -> <null>` | **+1** | — |
| dump lines (`\|vpiInstance:` + its `\_package:` line) | **0** | **2** |

**REMOVE-only**, and the size delta agrees: `11097299 → 11097287`, **−12 bytes**,
identical in both modes.

### 5.4 The four target rows

| row | pristine `38f308e` | delivered | head LHS / RHS |
|---|---|---|---|
| `default/BuildUVMPkg` | **1366893** | **94** | was `<null>` / `package uvm_pkg`; now `struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)@11947:40` / `<null>` |
| `testflags/BuildUVMPkg` | **1366893** | **94** | same, head byte-identical to `default` |
| `default/SeqDriver` | 1414847 | 1414847 | `<null>` / `package uvm_pkg` — **UNMOVED** (R1) |
| `testflags/SeqDriver` | 1414847 | 1414847 | same |

Every head is `grep -c '^LHS:' == 1`. `SeqDriver`'s databases are
**byte-identical** between the two binaries in both modes (17962228 / 17962655),
so its non-movement is an identity, not a measurement.

---

### 5.5 SIZE-DELTA over 3 reps on BOTH binaries (the MOVER RULE)

A hash difference proves nothing here; the size does. `BuildUVMPkg` re-emitted
from its own source with its own argv, three times per binary:

| binary | size (3 reps) | distinct md5s | verdict |
|---|---|---|---|
| pristine `38f308e` | **11097263** ×3 | **3** | hash-unstable, size-stable |
| delivered | **11097251** ×3 | **3** | hash-unstable, size-stable |

**SIZE-DELTA −12, constant.** A REAL mover by the standing law.

**New observation, extending sd2 R8 / sd3 F5:** `BuildUVMPkg` is hash-unstable
too — 3 distinct hashes at one fixed size on **both** binaries. Until now only
`default/Scoreboard` was recorded as hash-unstable. Any pass reading a
`BuildUVMPkg` byte difference as evidence must read the SIZE.

### 5.6 The seven live UVM rows, both binaries

| row | pristine | delivered |
|---|---|---|
| `default/BuildUVMPkg` | 1366893 | **94** |
| `testflags/BuildUVMPkg` | 1366893 | **94** |
| `default/SeqDriver` | 1414847 | 1414847 |
| `testflags/SeqDriver` | 1414847 | 1414847 |
| `default/SimpleUVM` | 389 | 389 |
| `testflags/SimpleUVM` | 389 | 389 |
| `default/Scoreboard` | 389 | 389 |

`testflags/Scoreboard` is `SLANG_REJECT` at baseline and produces no database —
counted as SKIP by `rowheads.sh`, never as agreement. **Nothing regressed; one
row-pair moved, by two orders of magnitude.**

**A baseline correction for the next pass:** `SimpleUVM`/`Scoreboard` are at
**389** lines here, not the 54 `r10sd3` recorded at `19730ce` nor the 112 `r10sd2`
recorded at `6e1c27a`. Four passes have landed since. Re-measure before quoting.

---

## 6. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line waited for, md5 asserted separately, 32-hex baseline | `/tmp/wt_r10sd4` and `/tmp/wt_r10sd4pris`, both `BASE 38f308e…` grep-checked (`rev-parse \| grep -c` = 1), both ` error:` count **0**, both `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen **before** any md5 was read; delivered **`3c43e9f28022dc732c0e840400eb54a4`**, pristine **`129c3164f6f62f6c9cefda43aa3608fd`** — 32 hex each, **different**, as a real patch requires |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | testflags j2 679/50/2, dump 496/183/52, `ct8rows` 0 rows | default **679 / 50 / 2**, testflags **679 / 50 / 2**; dump **496 match / 183 differ / 52 blank**, base == fresh; `ct8rows` **0 differing ROWS (0 row-sides)**, `PASS: every row byte-identical` |
| **4 surelog** | both j2 469/11 + 465/8 (FAIL 25/23, DEFER 5/5), histograms unchanged, 0 rows | default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT**; testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM); `ct8rows` **0 differing ROWS**, all **4 dump histograms identical** (default 225 match / 244 differ / 325 blank; testflags 165 / 300 / 329) |
| **5 BYTE VERIFIER** | both corpora both modes vs PRISTINE built here, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | u2r **0 / 1358 movers**, surelog **2 / 953**, `PATH_SETS_IDENTICAL` both; SELFCHECK **1357/1358** and **952/953**; SELFCHECK1 **1** and **3** (= 1 corruption + the 2 real movers); CSVs **IDENTICAL** on both corpora. The 2 movers are `default/BuildUVMPkg` and `testflags/BuildUVMPkg` — **exactly the predicted set** (§5.1/§5.2), judged by SIZE-DELTA **−12** over 3 reps on both binaries (§5.5) |

`GOLDEN_DEFER` was printed `[UNSET]` before the sweeps. All sweeps `--jobs 2`
with private `--out`/`--workdir`, `SLANG_UHDM` **pinned and verified by reading
`cmds.txt`** (r10sd2-verifier F4). `results/*.csv` were READ ONLY
(`git status --porcelain -- results` = 0). No `git stash`.

**GATE-3 trap, re-encoded:** `results/gate_uhdm2rtlil.csv` holds **testflags rows
only**; the fresh both-modes CSV is filtered to testflags before `ct8rows.sh`
sees it, or all 731 default rows read as ADDED.

**CANARIES**

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names **7** (the documented u2r-only names) |
| `canaries.sh` u2r | at baseline | **ok=8 changed=0 absent=0**, unknown-names **25** (documented) |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1`, baseline FIRST, mode-matched | **ok=58 changed=0 absent=0 unknown-patterns=1**, PASS |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6`, testflags-only CSV | **ok=1 changed=0 absent=0 unknown-patterns=6**, PASS |
| `canaudit.sh` | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, PASS — run against **THIS directory's** scripts |
| fenced names | dispatched by no driver | `UnsignedParam` `HierPathEval` `FileLocalParam` `TopParam` — all four **not dispatched by any driver** |
| `InterfaceModPort`, `BlackParrotComplex` **by name** | at baseline | both **CMP_EQUAL in BOTH modes** |
| the four UVM names **by name** | at baseline | `SeqDriver` / `SimpleUVM` / `BuildUVMPkg` **CMP_NOTEQUAL both modes**; `Scoreboard` CMP_NOTEQUAL (default) / SLANG_REJECT (testflags) |

**An ops note on `canaudit`.** Run against `r10sd3repro/`'s scripts it reports
`FENCE-BREACH=4` — the four fenced names appear in that directory's
`README.verifier.md`, a **record**, not a driver. Run against this directory it
is **0**. The script scans the whole directory the drivers live in, so a prose
mention of a fenced name trips it; that is a property of the audit, not a breach.

**BOUNDARIES.**

* `§ classTdSpecParamsForeignHome1` (`UhdmExporter.cpp ~2682`, sd1's b1–b28
  grid): **untouched by construction** — `UhdmExporter.cpp` is not in this
  patch's file set.
* Live pass `r10uvm72` (func-call binding, `ExprEmit.cpp` / `TaskFuncEmit.cpp`):
  **`src/TaskFuncEmit.cpp` is SHARED and this pass touches it. COLLISION,
  REPORTED as the standing rules require.** This pass's hunks are at
  `TaskFuncEmit.cpp:1097` (a new file-static predicate) and two one-token
  conditions at `1155` / `1345`, all inside `makeQueueDynArrayVar` /
  `makeAssocArrayVar` — the array-local helpers, not the call-binding paths.
  An integrator resolving a conflict keeps both; the predicate is self-contained
  and the two conditions only append `&& !classHomedType4(...)`.
* Live pass `r10earl43` (override Rhs fold, `ParamEmit.cpp`): **file-set
  intersection empty.**
* `r10sd2`-verifier **F3** (`design.Param_assigns`/`Parameters` NULL vs 45 on
  SimpleUVM/Scoreboard): **not disturbed** — those rows' databases are
  byte-identical between the two binaries (byte verifier, 0 movers outside
  BuildUVMPkg), so nothing in that family can have moved.

---

## 7. RESIDUES, RANKED

1. **R1 — the SeqDriver wall, both rows, 1 414 847 lines. FULLY LOCALIZED,
   different mechanism, ready to close.** Owner pair, arm and site are all named
   (§3.4/§3.5). It is **not** a stamping bug: `ParamEmit.cpp:20498`'s stamp on
   the package-listed `bit_typespec@26:1-26:4` is correct. The defect is
   **object SHARING at the import-into-class listing**:
   `src/ModuleEmit.cpp:~4097`,
   `if (auto* v23 = pv23->Variables()) ... vars23->push_back(x23);`
   pushes the imported package's **own variable objects** into the importing
   class's `Variables`. Golden emits a **distinct class-scope copy**, and
   `ct4key` gives its cells outright:

   | | copies | `vpiInstance` on the typespec | `bit_var` span |
   |---|---|---|---|
   | golden, package listing (x4: ALL/TOP x uvm_pkg/adpcm_pkg) | 4 | the package | `@26:5-26:35` (declarator) |
   | golden, `module_inst` listing | 1 | `<null>` | `@26:5-26:35` |
   | golden, **class_defn** listing (adpcm_driver/seq_item/sequencer/test/tx_seq) | **5** | **`<null>`** | **`@26:5-26:31` (NAME span)** |
   | ours, all listings | 5 | the package on 4 | `@26:5-26:35` everywhere |

   So the fix is a **clone** at that push, with the NAME span and an unstamped
   typespec. Golden emits 10 `bit_typespec@26:1-26:4` (4 package + 6 null) to our
   6 (4 + 2). Largest item left on these two rows, and the grid cell it needs is
   a package variable imported into a package that declares classes.
2. **R2 — the placement of `classHomedType4`.** The predicate is inserted between
   `makeQueueDynArrayVar`'s doc comment and its signature, so that comment now
   reads as if it documented the predicate. **Code motion only, no behaviour** —
   deliberately NOT fixed here, because every number in this record was measured
   on the binary the delivered patch builds and a cosmetic edit would have made
   the patch and the measurements describe different binaries. One-line move for
   the integrator.
3. **R3 — the `TOP:` view deficit is untouched and is still the biggest number on
   these designs** (sd2 R3 / sd3 R3): `TOP:uvm_pkg` 11290 golden vs 6742 ours on
   SeqDriver (−4548), 4081 vs 3546 on BuildUVMPkg (−535); `adpcm_pkg` runs
   **long** on both views (+487 / +474). This pass moved it by one.
4. **R4 — `q9`/`q11` still `CMP_FAIL` at their new heads**,
   `LHS: ref_var(p9::c9::f9::l9)` — a class-method queue LOCAL emitted as a
   `ref_var` where golden has something else. Unchanged by this pass (same head
   before and after) and now a 12-line ready-made reproducer sitting in the grid.
5. **R5 — the new BuildUVMPkg head, 94 lines, both rows.**
   `LHS: struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)@11947:40-11947:65`
   / `RHS: <null>`: golden carries a struct typespec in a listing where we carry
   nothing. 94 lines is two orders of magnitude cheaper than anything these rows
   have offered before.
6. **R6 — the "deepest killer" heuristic is UNSOUND in these databases and must
   not be reused** (§3.2). It named `class_defn(adpcm_seq_item)` as the owner —
   a `class_defn`, whose `Compare` body (generated `class_defn.cpp:159-163` plus
   `scope`'s 17 vectors) contains **no singular slot that can hold a package at
   all**. The contradiction was visible without the watchpoint and is the cheapest
   available check on any suppression-derived answer: *can the named class's
   `Compare` body even issue the arm you claim?*
7. **R7 — `ct2rels.inc` does not cover every relation `Compare` descends**
   (`Instance_items`, `Deriveds` have no listed relation id), so any BFS built on
   it under-reaches. `ct4scan`'s `serial` and `visited` modes exist to not depend
   on it, and `visited` is strictly better: it is 200x smaller and provably
   complete.
8. **R8 — `VpiParent` is unset on most of our typespecs** (sd2 R7's sibling), so
   the home-scope census (`ct4law`) reads a large `<no-parent>` row on our side
   and only golden's column carries a law. It is why the decode was done with
   `ct4key` on named keys rather than with a global parent-chain census.

---

## 8. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct4bt.cpp` + `ct4bt.gdb` | **THE INSTRUMENT THAT ENDED THE GUESSING.** A gdb hardware watchpoint on `CompareContext::m_failedRhs`, plus a pointer-identity oracle (`SHOW1`) gdb calls on every register and 4096 stack words to name the objects in the stopped frame. Answers "which arm, which owner" by reading, not inferring. |
| `ct4scan.cpp` | Exhaustive SINGLETON suppression scan, four pools (`nullinst` / `all` / `serial` / `visited`). Replaces ddmin outright: `Compare` costs 1.5 ms, so a linear scan is exhaustive where a search is not. `visited` is the pool that cannot miss. |
| `ct4own.cpp` | Orders killers by the `m_visited` traversal oracle (B is BELOW A iff suppressing A stops B being visited) and looks up OUR twin by span key. **Kept as the record of a WRONG method** — its "deepest killer" answer is refuted in R6, and its header says so. |
| `ct4mut2.cpp` | SINGLE-slot mutation of OUR side over every object whose `Instance()` IS the failing RHS pointer, with a restore control, separating INTRODUCED-earlier failures from real ones. Its **zero** is the finding that broke the singular-slot reading open. Also carries the duplicate-view diagnostic [D] that explains sd2's "byte-identical". |
| `ct4vec.cpp` | Nulls each of the 25 vectors `package::Compare` walks, both views, with an other-view control. Rules out the VECTOR arm by measurement. |
| `ct4ref.cpp` | 154-relation sweep of BOTH databases for every singular slot and vector membership referencing the failing object. Proves the 6818-object population is complete. |
| `ct4reach.cpp` | REACHABILITY-filtered, span-keyed, multiset `vpiInstance` census + per-key suppression. Its `[A]` table is this pass's mover scoreboard. Its `[S]/[K]` sections are **kept as a WRONG method**: per-key surplus is not the Compare pairing, and it found 0 killers among 1205 candidates. |
| `ct4key.cpp` | **THE DECODE INSTRUMENT.** Every copy at one span key, both sides, with `vpiInstance` and the full owner chain. One run answers "does golden null this object, or emit a different copy per context?". |
| `ct4law.cpp` | home-scope x `vpiInstance` census, splitting class MEMBER from class METHOD. Prints its own caveat (R8). |
| `ct4arm.sh` / `ct4grid.sh` / `grid/q1…q11.sv` | the eleven cells of §4. |
| `predict4.sh` | source-only mover prediction, run before the sweeps, stated as an upper bound. |
| `r10sd4_tap.py` | the OWNER tap (§3.5). DEBUG artifact; the rewriter is delivered, the tapped build is not. |
| `ct2*.cpp` `ct3*.cpp` `byteverify.sh` `manifest.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `msdist.sh` `rowheads.sh` `dumptree.py` `census.py` `slots.py` `cells.py` `TAP.md` | carried forward from `r10sd2repro`/`r10sd3repro` unchanged. |

---

## 9. REFUTATIONS, STATED PLAINLY

1. **`r10sd2` §4.1's reason for ruling out the VECTOR arm is REFUTED.** It seeded
   golden's package objects, read the head "byte-identical", and concluded the
   container is not a package. The head is byte-identical there because the
   **other package view reproduces the same shape with the same RHS pointer** —
   only `m_visited` moves (1613 → 2143 / 2005). The arm conclusion survives; the
   evidence given for it never supported it. The arm is ruled out **here** by
   nulling all 25 of the package's vectors (`ct4vec`).
2. **`r10sd2` R1's localization is REFUTED in its specifics.** It named
   `class_typespec@199:3-199:20 (uvm_globals.svh) → class_defn(uvm_coreservice_t)`
   as the chokepoint every path goes through, and the "34 parallel
   `class_typespec` chokepoints" as the wall. Measured: that object's
   `Instance()` is **`<null>` on BOTH sides**, so it is not the slot; and the
   exhaustive scan needs no set-valued ddmin at all because it is not a search.
   The relation (`vpiInstance`) and the arm (SINGULAR) were right.
3. **The brief's instruction — "set-valued ddmin over the 34 chokepoints" — was
   NOT the way in, and would not have worked.** A set-valued search is still a
   search over a kill test that is blind to view duplication (§3.2). What was
   needed was a smaller pool (`m_visited`, 1613) and a different question
   (read the caller).
4. **"The owner is the deepest killer" is REFUTED** (R6). It names
   `class_defn(adpcm_seq_item)`, whose `Compare` body cannot issue a
   package-valued singular `SafeCompare`.
5. **"Null it and the head moves" is not a complete test on a SHARED object**
   (§3.4). Our `bit_typespec@26:1-26:4` is compared at two positions; nulling it
   fails the earlier one first, so the real owner reported as `INTRODUCED` and
   the scan read **0 real candidates** while the owner was in the list.
6. **The law's negative phrasing "class scope → no instance" is NOT the law.**
   Golden stamps **338** class-scope typespecs with a package on SeqDriver
   (`ct4law`), and `q8` shows a class **data member** keeps the stamp when its
   element type is package-homed. The rule keys on the **TYPE's home scope**.
   Implementing the phrasing would have nulled hundreds of correct slots.
7. **The four target row-modes are NOT one head.** The brief treats the wall as
   a single defect on four rows. It is two defects on two rows each, with two
   owners, two emitter files and two mechanisms — and only measurement separates
   them.

---

## 10. THE PATCH

`/tmp/r10sd4.patch` — `git diff` vs `38f308e`, `src/` + `tools/probe/r10sd4repro`
only. Reproducible with:

```sh
cd /tmp/wt_r10sd4 && git add -A tools/probe/r10sd4repro
git diff 38f308e --binary -- include src tools/probe/r10sd4repro > /tmp/r10sd4.patch
md5sum /tmp/r10sd4.patch
```

md5 is delivered with the pass's final report and NOT written here: this file is
inside the patch, so any md5 recorded here is stale the moment it is written
(`r10sd3` §10's rule, kept).
