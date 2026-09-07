# r10uvm190 — § `enumBaseTdCloneDanglingRange190` — **AN ENUM WHOSE BASE IS A PACKAGE TYPEDEF TAKES A `clone_tree` COPY OF THAT TYPEDEF'S TYPESPEC, SO THE COPY OWNS ITS PACKED RANGE AND THE PARAMETER REFERENCE INSIDE IT NEVER BINDS** — the BuildUVMPkg ×2 33-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list — `predict190.sh` reads that list rather than
spelling the names, and the wide boundary compiles `tools/probe` arms
exclusively and dispatches no corpus test at all.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `66b345c7` |
| pristine binary | md5 `bf7949d3f308a2554f9de94269ef7536`, built from this pass's OWN worktree at a clean `66b345c7` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own binary at that commit** |
| patched binary | md5 `87696feb462e1f8b22a80eb29d5f0564`, frozen `chmod 555` |
| production surface | `src/TypeEmit.cpp` only (four file-static helpers + the two `Ranges` lines in `buildEnumTs`; nothing deleted) |
| probe surface | `tools/probe/r10uvm190repro/` only |

---

## READ THIS FIRST — the numbers

| | pristine | patched |
|---|---|---|
| `BuildUVMPkg` cmp lines, default / testflags | **33 / 33** | **300 / 300** |
| `BuildUVMPkg` heads (`grep -c '^LHS:'`) | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp md5, both modes | `492bbfad6a5e` | `9e6c829fce41` |
| head object | an EXTRA `constant` of ours under a package `param_assign`, `LHS: <null>` | a **different object and a different kind**: `function(uvm_pkg::uvm_root::get)` vs our `function(get)` (**R0**) |
| the other ten head-set cmp logs | — | **byte-identical between the two binaries** |
| corpus enum-base-clone census (`TDCE`, 35 cells × golden 302) | 31 match | **35** — **TO-GOLDEN 4, AWAY-GOLDEN 0, CHANGED-STILL-WRONG 0, WRONG-KEPT 0** |
| corpus all-clone census (`TDC`, 4085 cells) | 3611 match | **3613** — TO-GOLDEN 2, AWAY 0, STILL-WRONG 0 |
| corpus `param_assign` Rhs census (`PA`, 18396 cells) | 14847 match | **14847** — **0 changed cells** (the brief's framing, refuted; § 1) |
| grid cells, four arms × real Surelog goldens (TDCE) | 59 match | **75** — **TO-GOLDEN 16, AWAY-GOLDEN 0, CHANGED-STILL-WRONG 0** |
| byte movers | — | **3 / 956** surelog (BuildUVMPkg ×2, **predicted by name from pristine databases first**, + 1 PROVEN COIN), **0 / 1358** u2r |
| boundary | — | 5100 listed = 5100 processed, **13 moved arms**: 4 this pass's own, 6 earlier passes' that move **TO-GOLDEN 19 / AWAY 0** in total (one of them goes CMP-EQUAL), 3 the decoded `.bss` ADDRESS this pass did not write |

---

## 1. THE BRIEF'S FRAMING, REFUTED FIRST

The brief named the head as *"a singular compare naming OUR `param_assign`
right side (a constant for an untyped package parameter) that golden does not
carry — either golden's assignment has no Rhs or golden has no such assignment
in that listing; DECODE WHICH FIRST."*

**It is NEITHER.** Golden carries the `param_assign` **and** its `Rhs`, in
BOTH package listings, agreeing with ours on every compared field:

```
ct190cen, golden vs ours, uvm_pkg AllPackages listing, positional:
  DEFPKG  instance.Param_assigns  package uvm_pkg::  UVM_FIELD_FLAG_RESERVED_BITS
          PARAM TYPED:int_typespec  7856:11-7856:44
          golden RHS=constant dec=28 sz=64 val=UINT:28 ct=9
          ours   RHS=constant dec=28 sz=64 val=UINT:28 ct=9
  ELABPKG (the same row, sz=32 on both sides)
```

and the whole 41-entry `Param_assigns` listing is identical position for
position on both sides in both listings. Corpus-wide the `PA` census scores
**0 changed cells** between the two binaries, so this pass writes no
`param_assign` `Rhs` anywhere.

**Surelog's Rhs-presence rule, decoded anyway** (the brief's question 2), so
the next pass does not have to re-derive it —
`CompileHelper::compileParameterDeclaration`, `CompileHelper.cpp:3725-3915`:

```cpp
ParamAssign* assign = new ParamAssign(fC, name, value, …);
UHDM::param_assign* param_assign = s.MakeParam_assign();
component->addParamAssign(assign);
param_assigns->push_back(param_assign);          // ALWAYS listed
if (param) { param_assign->Lhs(param); … }
if (value) {                                     // ONLY when written
  …
  param_assign->Rhs(rhs);                        // CompileHelper.cpp:3912
}
```

so the `param_assign` is listed for every declarator and carries an `Rhs`
exactly when the declaration has a written initializer — in EVERY listing and
in both views. The second list the same arm builds for a `Package` /
`FileContent` at `instance == nullptr` (`component->getOrigParam_assigns()`,
`CompileHelper.cpp:3755-3763`), which holds an UN-REDUCED `Reduce::No` Rhs and
a `clone_tree` of the parameter, has **no reader anywhere in Surelog** (the
only mentions are its own writer plus the accessors in
`Common/PortNetHolder.h:73-77`) and never reaches the database: golden's
BuildUVMPkg holds 89 `param_assign` objects on a FLAT `Serializer::AllObjects()`
walk and the structured listing walk finds the same 89.

The head is therefore **not a `param_assign` question at all**, and § 2 names
what it is. `UhdmWriter.cpp:1216-1222` (`writePackage`) copies
`pack->getParam_assigns()` into the package verbatim, which is why both of
golden's package listings agree with ours here.

---

## 2. THE HEAD, DECODED FROM THE PRISTINE LOG AND THEN FROM THE JUDGE

`heads_pris/BuildUVMPkg.default.cmp`, 33 lines, md5 `492bbfad6a5e`,
`grep -c '^LHS:'` = 1, byte-identical to the testflags log:

```
LHS: <null>
RHS ours    constant: , id:24, @7856:42-7856:44
            |vpiParent: \_param_assign: , id:23, @7856:11-7856:44
            |vpiDecompile:28  |vpiSize:64  |UINT:28  |vpiConstType:9
            |vpiTypespec: \_ref_typespec: (uvm_pkg), id:25
                            |vpiActual: \_int_typespec: , id:26, @7856:1-7856:44
```

`LHS: <null>` with a full RHS is `BaseClass.h`'s SINGULAR `SafeCompare`
(`:191-193`) naming the VALUE — golden's edge is null where ours is not. The
`RHS` block is the OBJECT the judge stopped on; it is **not** the owner, and
the printed `vpiParent` is a dump field, not the edge that failed.

### 2.1 The owner is NOT the `param_assign`

`ct190own` (r10uvm164's mirror scan) enumerates every edge of OURS that lands
on the head and prints golden's counterpart's SAME edge
(`OWNER.pristine.r10uvm190.txt`):

```
  ours   param_assign()@7856:11-7856:44#23        edge vpiType=82 (singular)
      golden param_assign()@7856:11-7856:44#1559  -> singular constant()@7856:42-7856:44#1563
      golden param_assign()@7856:11-7856:44#61362 -> singular constant()@7856:42-7856:44#61366
  ours   ref_obj(UVM_FIELD_FLAG_RESERVED_BITS)@7859:14-7859:42#267   edge vpiType=700
      golden ref_obj(…)@7859:14-7859:42#61377     -> singular constant()@7856:42-7856:44#61366
  ours   ref_typespec()#25                        edge vpiType=81 (the constant's own parent)
```

Every referrer's golden counterpart is NON-NULL, so the mirror scan alone
cannot name the owner. `param_assign::Compare` compares `Rhs` **before** `Lhs`
(`~/git-repos/UHDM/build/generated/src/param_assign.cpp:112-113`), which is
what made the `param_assign` the plausible suspect — and it is wrong.

### 2.2 Masking the OFFICIAL `Compare` names it

`ct190mask` pre-seeds `m_visited` and re-runs the official `design::Compare`
(`DECODE.r10uvm190.txt`). Masking only ever SUPPRESSES comparisons, so it can
never reveal an EARLIER head:

```
BASE                                LHS=<null> RHS=constant()@7856:42-7856:44#24
MASK family kind=param_assign line=7856 size=2   head SAME    (owner NOT here)
MASK family kind=*            line=7856 size=8   head SAME    (owner NOT here)
MASK family kind=ref_obj      line=7859 size=30  head CHANGED (owner IS here)
```

A single-object mask reads "not the owner" for all thirty, because the walk
then pairs our object against the NEXT twin. LEAVE-ONE-OUT settles it:

```
KEEP ref_obj(UVM_FIELD_FLAG_RESERVED_BITS)@7859:14-7859:42#61385 head SAME  <== owner
KEEP ref_obj(UVM_FIELD_FLAG_RESERVED_BITS)@7859:14-7859:42#61511 head SAME  <== owner
(the other 28 change the head)
```

**The head is `ref_obj::Actual_group`** — `ref_obj.cpp:150`,
`SafeCompare(lhs->Actual_group(), rhs->Actual_group())` with golden's null.

### 2.3 The two objects, side by side

```
uvm_pkg.sv
  7856  parameter UVM_FIELD_FLAG_RESERVED_BITS = 28;
  7859  typedef bit [UVM_FIELD_FLAG_RESERVED_BITS-1 : 0] uvm_field_flag_t;
  7880  typedef enum uvm_field_flag_t { UVM_BIN = 'h1000000, … } uvm_radix_enum;
  7930  typedef enum uvm_field_flag_t { UVM_DEEP = (1<<16), … } uvm_recursion_policy_enum;
```

GOLDEN — the enum's base is a per-declaration clone with its OWN range:

```
bit_typespec(uvm_field_flag_t)#61382                 <- enum_typespec(uvm_radix_enum).Base_typespec
  Ranges[0] range#61383
     Left_expr operation#61384
        Operands[0] ref_obj(UVM_FIELD_FLAG_RESERVED_BITS)#61385   *** NO vpiActual ***
        Operands[1] constant#61386
     Right_expr constant#61387
  Typedef_alias -> ref_typespec#61388 -> bit_typespec(uvm_pkg::uvm_field_flag_t)#61381
                                            Ranges[0] range#61376
                                               operation#61378
                                                  ref_obj#61377 -> constant#61366   *** BOUND ***
```

OURS — one range subtree SHARED by the listing object and both clones:

```
bit_typespec(uvm_field_flag_t)#271                   <- enum_typespec(uvm_radix_enum).Base_typespec
  Ranges[0] range#265        <-- THE SAME OBJECT the listing object #264 lists
     operation#266
        ref_obj#267 -> constant#24                   *** BOUND ***
  Typedef_alias -> ref_typespec#272 -> bit_typespec(uvm_pkg::uvm_field_flag_t)#264
                                          Ranges[0] range#265  (the same one again)
```

`typespec::Compare` walks `Typedef_alias` BEFORE `Ranges`
(`typespec.cpp:12` then `bit_typespec.cpp:14`), so the listing object's bound
reference is compared first and PASSES, and the walk then reaches the clone's
own range — where golden dangles and we do not.

---

## 3. THE LAW, DECODED FROM SURELOG

`CompileHelper::compileDatastructureTypespec`, the `SimpleType` arm,
`CompileType.cpp:882-896`:

```cpp
} else if (const SimpleType* sit = datatype_cast<const SimpleType*>(dt)) {
  result = sit->getTypespec();
  if (parent_tpd && result) {
    ElaboratorContext elaboratorContext(&s, false, true);
    if (typespec* new_result = any_cast<typespec*>(
            UHDM::clone_tree((any*)result, &elaboratorContext))) {
      … new_result->Typedef_alias()->Actual_typespec(result);
      result = new_result;
    }
  }
```

An enum's BASE is one more caller of that arm (`CompileType.cpp:~1319`, the
`paEnum_base_type` case runs the base name through `compileTypespec`), which is
how § `enumBaseTdAliasClone10` already established that the base is a LAW-S
clone carrying a `Typedef_alias`. `clone_tree` is a DEEP copy, so the clone
gets its **own** `range` / `operation` / `ref_obj` objects.

Why the copy's reference dangles for ever — the generated
`ref_obj::DeepCopy` (`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:104-111`):

```cpp
void ref_obj::DeepCopy(ref_obj* clone, BaseClass* parent, CloneContext* context) const {
  …
  if (!clone->Actual_group()) clone->Actual_group(elaboratorContext->m_elaborator.bindAny(VpiName()));
  if (!clone->Actual_group()) clone->Actual_group((any*) Actual_group());
```

the copy inherits whatever binding existed **at clone time** — and at clone
time (definition compile) the source is still bare, because the typedef listing
object's reference is bound LATER, by the WRITER:
`UhdmWriter::lateBinding`, `UhdmWriter.cpp:3294-3297`:

```cpp
for (UHDM::ref_obj* ref : mod->getLateBinding()) {
  if (ref->Actual_group()) continue;
  …
```

`mod->getLateBinding()` is the list of ref_objs the COMPILER minted. The
clone's ref_obj was never on that list, so nothing ever binds it.

**This is § `pkgTdCloneRefNoBind18`'s cell at the ENUM-BASE position.** That
flag (`tdCloneRefNoBind18`, declared in `include/UhdmExporter.h:3029`) already
states the rule — *"Surelog re-mints the typedef's own range expression into
the clone WITHOUT re-resolving it, so a bound operand that names a package
parameter stays DANGLING there — while the very same operand inside the
typedef LISTING object binds that parameter's def constant"* — and it is
honoured at the formal / return / body-local clone positions, where the
clone's range is RE-MINTED from syntax and the flag can reach the reference.
The enum-base clone re-minted nothing: `buildEnumTs` handed the clone the
listing object's own `Ranges` vector.

### 3.1 What we did

`src/TypeEmit.cpp`, `buildEnumTs`, both arms (bit and logic):

```cpp
-  if (o0->Ranges())
-      n0->Ranges(o0->Ranges());
+  if (o0->Ranges())
+      n0->Ranges(cloneRangeVecNeedsCopy190(o0->Ranges())
+                     ? cloneRangeVecUnbound190(s, o0->Ranges(), n0)
+                     : o0->Ranges());
```

with four file-static helpers above the function: a SCANNER
(`cloneRangeCopyable190` / `cloneRangeVecNeedsCopy190`) and a COPIER
(`cloneRangeNode190` / `cloneRangeVecUnbound190`) that reproduces
`range` / `operation` / `constant` / `ref_obj` field for field and gives the
copied `ref_obj` NO `Actual_group`.

### 3.2 THE GATE — one condition, two clauses

Object SHARING is invisible to every generated `Compare` (no Compare body
reads `VpiParent`, and identity is never a compared field), so re-minting a
subtree that holds no bound reference would move zero cells and only churn
objects. The copy is made **only** when

1. the shared range vector holds at least one reference that is **BOUND**, and
2. every node in it is one the copier reproduces field for field
   (`range` / `operation` / `constant` / `ref_obj`).

Anything else keeps the shared vector byte for byte as before this pass. Arm A
cell `a9` is the ABSTAIN control — a `{1'b1,1'b0}` bound whose operation holds
only constants: no reference, gate declines, cell unchanged and still matching
whatever it matched before.

### 3.3 What the gate does NOT reach, and why that is right

In the ELABORATED view golden's clone references are **BOUND**
(`ref(PW,BOUND:parameter)`, arm A), and so are ours — because by the time the
elaborated clone is built our listing object's reference is not yet bound
either, so clause 1 is false and the clone shares, and the shared reference is
then bound for both. The one elab cell where golden dangles is the
CROSS-PACKAGE read (`ref(pkx190::XW,BARE)`, arm A cell `a7`), where our
reference IS already bound at clone time — clause 1 fires and the cell goes
TO-GOLDEN. The gate is a model of Surelog's TIMING (copy whatever binding
exists at clone time; nothing binds the copy afterwards), and the grid says it
reproduces golden in 16 of 16 moved cells with 0 away.

A CHAINED typedef takes no clone at all (§ `enumBaseTdChainNoClone10`) and is
untouched: arm C cell `c6` is byte-identical on both binaries and matches
golden in both views.

---

## 4. THE GRIDS — four arms, one REAL Surelog golden each, BOTH views

`grid190.sh` builds `surelog -parse` and `surelog -elabuhdm` goldens plus both
binaries' databases, records EVERY rc (an rc=139 segfault must never read as a
result) and censuses all six. `GRIDS.r10uvm190.txt` carries the raw output.

| arm | what it varies | TDCE cells match pris → pat | TO-GOLDEN | AWAY | STILL-WRONG |
|---|---|---|---|---|---|
| `probe0.sv` | the head's own shape in twenty lines | 6 → 8 of 8 | 2 | 0 | 0 |
| `grid190/g190_a_bounds.sv` | the BOUND: parameter-under-an-operation, BARE parameter, localparam, literal, two operands, parameter read twice, cross-package, `logic` base, concatenation | 24 → 32 of 36 | 8 | 0 | 0 |
| `grid190/g190_b_homes.sv` | the HOME: package / module / class, **and the other clone positions** (formal, return, body local, array element, plain variable) | 8 → 9 of 11 | 1 | 0 | 0 |
| `grid190/g190_c_order.sv` | THREE enums over ONE typedef, an anonymous enum base, declaration ORDER, name CASE, a CHAINED typedef, a scalar base, an `int` base | 21 → 26 of 28 | 5 | 0 | 0 |

Arm B is the arm that convicts an over-wide law: the SAME typedef is used at
the formal / return / body-local / array-element / plain-variable clone
positions, and in the wider `TDC` census exactly ONE key moves there — the
enum-base one. Arm C is the arm that TESTS rather than agrees: three enums
share one typedef, so a law that fixed only the first would leave two bound;
`TO-GOLDEN 5` covers all of them.

The cells that stay WRONG in arms A and B are named, not hidden:

* `t_bare` (arm A a2) — golden's FOLDED sibling constant is `sz=32`, ours
  `sz=64`. A bare-parameter bound's fold WIDTH, wrong before and after, a
  different family (**R2**).
* `t_cat` (arm A a9) — golden folds `{1'b1,1'b0}` to `BIN:10` size 2, we fold
  it to `UINT:2` size 64. Wrong before and after; the gate deliberately
  abstains here (**R3**).
* `tc_t` elab (arm B b3) — golden lists 2 clones of the class-scope typedef,
  we list 4. A clone-MULTIPLICITY residue, untouched (**R4**).

---

## 5. THE CORPUS CENSUS

`cen190.sh` runs `ct190cen` over BOTH sides of every test directory in a
`verify_golden` workdir, the golden found through each test's OWN `cmds.txt`.
`CALIBRATION`: the golden census is BYTE-IDENTICAL between the pristine run
and the patched run (md5 `77eb8afceef19fe8dc428a2d62b429d5` both), so every
movement below is ours. 1573 dirs, 50 without a golden, 617 without one of
ours, 279158 golden rows, 22516 of ours (the same COUNT on both binaries).

| section | what it is | golden | ours pris → pat | TO-GOLDEN | AWAY | STILL-WRONG |
|---|---|---|---|---|---|---|
| `TDCE` | the enum-base clones — this law's exact population | 302 | 31 → **35** of 35 | 4 | 0 | 0 |
| `TDC` | every typedef-alias clone, any position | 80842 | 3611 → 3613 of 4085 | 2 | 0 | 0 |
| `PA` | every `param_assign`'s Rhs presence | 198014 | 14847 → 14847 of 18396 | 0 | 0 | 0 |

`TDCE` **WRONG-KEPT is 0**: after this pass every enum-base clone cell in the
whole surelog corpus agrees with golden. `TDC`'s 470 WRONG-KEPT and `PA`'s
3549 WRONG-KEPT are pre-existing families this pass does not touch (`PA`
records **0 changed cells**, the machine statement of § 1).

The join is a MULTISET join (`score190.py`): one typedef gives many identical
clone rows — BuildUVMPkg's `uvm_field_flag_t` gives thirty — and a
last-writer dict would drop all but one.

---

## 6. THE GATES, THE MOVERS AND THE BOUNDARY

`GATES.r10uvm190.txt`, `MOVERS.r10uvm190.txt`, `BOUNDARY.r10uvm190.txt`.

* goldens 23 PASS / 0 FAIL on BOTH binaries with `SLANG_UHDM` exported
  explicitly to each; `SLANG_UHDM=/bin/false` gives 0 PASS / 23 FAIL.
* u2r `testflags` + `default`: `ct8rows` PASS against `results/gate_uhdm2rtlil.csv`
  and against this pass's own pristine sweep — every row byte-identical,
  status AND dump column. 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL.
* surelog `--mode both` (1588 rows): `ct8rows` PASS against
  `results/golden_surelog.csv` and against this pass's own pristine sweep.
  **NO ROW CONVERTED.**
* every `cmds.txt` audited BY BINARY PATH (`slang:   /tmp/r10uvm190_bin/pat.bin`).
* byte movers: **u2r 0 / 1358**; **surelog 3 / 956**, `PATH_SETS_IDENTICAL`,
  `SELFCHECK` 955/956 flagged (the instrument can see).
  * `default/BuildUVMPkg`, `testflags/BuildUVMPkg` — **PREDICTED BY NAME**
    from PRISTINE databases alone before the patched sweep ran
    (`predict190.sh`: PREDICTED MOVERS = 2, and seven further rows that carry a
    bound reference in a NON-enum-base clone are listed as `NOT-A-MOVER` and
    none of them moved).
  * `default/Scoreboard` — the recorded ~50/50 COIN. Attributed ORDER-BLIND:
    `uhdm-dump` both sides, workdir path normalised, SORTED — 1100381 lines
    each side, **diff = 0 lines**. Its cmp log is byte-identical too.
  * BuildUVMPkg attributed line by line: sorted whole-dump diff
    **REMOVED 0 / ADDED 58**, and the 58 added lines are exactly
    2 × { `range`, `operation`, `ref_obj`(no `vpiActual`), 2 `constant` } —
    one new range subtree per enum-base clone. Nothing else in the design moved.
* canaries: `canaries.sh` ok=52 changed=0 (surelog) and ok=8 changed=0 (u2r);
  `ctcan2.sh` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` audited=29
  UNCOVERED=0 **FENCE-BREACH=0**.
* protected databases: `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`
  byte-identical; `SVSwitch` `4842211c4030`; `YosysVerx` `6ccda350c24a`.
* wide boundary: 5100 listed = 5100 processed, 4936 databases produced,
  **RC_DIFFS = 0**, 13 moved arms — 4 this pass's own (the POSITIVE CONTROL,
  so the gate can see), 6 earlier passes' arms that this law legitimately
  reaches, and 3 that are the decoded `.bss` static-address false mover.

### 6.1 The six earlier-pass arms, each re-measured against its own golden

| arm | verdict |
|---|---|
| `r10uvm114repro/g114_e_enumbase.sv` | TO-GOLDEN 4 / AWAY 0 / STILL-WRONG 0 — 36 of 36 cells now golden's |
| `r10uvm114repro/g114_f_twopkg.sv` | TO-GOLDEN 1 / AWAY 0 — cmp def **33 lines → 0 lines, rc 255 → 0: the arm's DEF view is now EQUAL** |
| `r10uvm114repro/g114_h_ops.sv` | TO-GOLDEN 11 / AWAY 0 / STILL-WRONG 0 (37 → 48 of 52); cmp def 33 → 36 lines, the head OBJECT changed |
| `r10uvm188repro/probe0.sv` | TO-GOLDEN 1 / AWAY 0 — cmp def 33 → 28 lines |
| `r10uvm188repro/grid188/g188_a_shapes.sv` | TO-GOLDEN 1 / AWAY 0 — cmp def 33 → 28 lines |
| `r10vbuvm28repro/gv28_c_edges.sv` | TO-GOLDEN 1 / AWAY 0 — cmp 20 → 20 lines |

### 6.2 The three false movers

`r10uvm154repro/l154_noenum.sv`, `r10uvm185repro/grid185/g185_e_kinds.sv` and
`r10buvm22repro/g22.sv` are r10uvm188's recorded residue **R2**: the range of
an ASSOCIATIVE dimension carries a `.bss` STATIC ADDRESS as a `UINT` constant
where golden reads `STRING:associative`.

```
l154 / g185   pristine UINT:22621945   patched UINT:22626041   (+4096 = one page)
g22           pristine UINT:22621089   patched UINT:22625185   (+4096 = one page)
```

Wrong before, wrong after, in the SAME way. The tell the campaign already
records — zero movement in the pass's own population — holds: all three have
**TDCE rows = 0**, and their cmp verdicts are unchanged (92/92 and 17/17 lines,
both views; `g22.sv` exits rc=4 on BOTH binaries and has no comparable golden).

### 6.3 The must-stay floor, scored in both columns

| | arms listed | arms moved |
|---|---|---|
| `r10uvm187repro` (§ `pkgScalarTdParamDefDefer187`) | 6 | **0** |
| `r10uvm170repro` (arms and fences) | 5 | **0** |
| `r10earl111repro` (int-whitelist arms) | 6 | **0** |
| `r10uvm185repro` | 5 | 1 — the `.bss` address of § 6.2; cmp 92/92 both views UNCHANGED, TDCE population 0 |
| `r10uvm188repro` (render arms) | 4 | 2 — both TO-GOLDEN 1 / AWAY 0 / STILL-WRONG 0 |
| `r10uvm82repro` / `r10uvm91repro` | 7 / 5 | **0 / 0** |
| `r10buvm3repro` / `r10buvm15repro` | 4 / 9 | **0 / 0** |
| `r10sd8repro` / `r10sd12repro` | 37 / 108 | **0 / 0** |

---

## 7. THE HEAD AFTER — AND R0

```
BuildUVMPkg default and testflags, 300 cmp lines, ONE head each,
both cmp logs BYTE-IDENTICAL to each other (md5 9e6c829fce41)

LHS golden  function: (uvm_pkg::uvm_root::get), id:60621, @38754:1-38757:12
            |vpiParent: \_package: uvm_pkg, id:60163
            |vpiName:uvm_root::get
            |vpiFullName:uvm_pkg::uvm_root::get
RHS ours    function: (get), id:94911, @38754:1-38757:12
            |vpiParent: \_class_defn: (uvm_root), id:94678 < package uvm_pkg
            |vpiName:get
```

**R0** — a `VpiName` head on a class METHOD's LISTING. Golden lists the same
`uvm_root::get` function object TWICE under TWO names: `function(get)` in the
`class_defn(uvm_root).Task_funcs` listing (`#786`, index 33 of 60) and
`function(uvm_root::get)` in the PACKAGE's own listing (`#60621`), and the
judge stopped where golden's package-scope, CLASS-QUALIFIED copy pairs with our
class-scope, BARE-named one. `ct190own` on the patched database
(`OWNER.patched.r10uvm190.txt`) shows the split cleanly: our
`func_call(uvm_root::get)@9855` has TWO golden counterparts, one bound to
`function(get)#786` and one to `function(uvm_root::get)#60621`. This is a
task/function LISTING-and-NAMING law, a different object and a different kind
from this pass's — decode WHICH LISTING pairs with which before writing
anything. Independent confirmation that it is the next head: masking golden's
whole 30-member `ref_obj@7859` family in the PRISTINE database already produced
exactly this pair (`DECODE.r10uvm190.txt`).

**R1 — the clone COUNT.** Golden's BuildUVMPkg holds 62 `bit_typespec` objects
at `7859:9-7859:49` and we hold 61; the corpus `TDC` census carries 4085 of our
clone rows against 80842 of golden's. A clone-MULTIPLICITY family (how many
per-declaration copies each listing object gets), wholly untouched here and
visible in arm B's `tc_t` elab cell (golden 2, ours 4).

**R2 — a bare-parameter bound's FOLD WIDTH.** `typedef bit [PW : 0]` (arm A
`a2`): golden's folded sibling constant is `sz=32`, ours `sz=64`. Wrong before
and after.

**R3 — a CONCATENATION bound.** `typedef bit [{1'b1,1'b0} : 0]` (arm A `a9`):
golden folds to `BIN:10` size 2, we fold to `UINT:2` size 64. The gate
deliberately abstains on this shape (its operation holds no reference), so the
cell is untouched.

**R4 — the dump's synthesised `vpiFullName` on a clone's reference.** The two
new `ref_obj`s print as
`uvm_pkg::uvm_pkg::uvm_field_flag_t::UVM_FIELD_FLAG_RESERVED_BITS` where
golden's clone refs print `uvm_field_flag_t.UVM_FIELD_FLAG_RESERVED_BITS`.
`VpiFullName` is synthesised by `uhdm-dump` from the parent chain and is read
by NO generated `Compare`, so it is invisible to the judge; recorded because a
naming residue is often a PARENTING residue and the next pass in this area
should know it is there.

**R5 — the `.bss` static address** (§ 6.2, r10uvm188's R2, unchanged): still
makes every boundary gate in this campaign report three spurious movers on any
patch that grows the binary by a page. Worth fixing on its own.

---

## 8. THE FILES

| file | what it is |
|---|---|
| `ct190cen.cpp` | the census: `PA` (every `param_assign`'s Rhs presence, keyed on the listing + Lhs + kind matrix), `TDC` (every typedef-alias clone's packed-range bounds and reference binding) and `TDCE` (the enum-base clones only, reached FROM the enum so the position is known) |
| `ct190own.cpp` | the MIRROR owner-finder, carried verbatim from `r10uvm164repro/ct164own.cpp` |
| `ct190path.cpp` | the lock-step DESCENT through both databases with a fresh `CompareContext` per child pair, with a cycle guard for `GetByVpiType`'s upward edges |
| `ct190mask.cpp` | FAMILY and LEAVE-ONE-OUT masking of the official `design::Compare` — the instrument that actually named this head's owner |
| `build190.sh` | builds all four, linking UHDM statically out of `~/.local` |
| `cen190.sh` | the corpus-wide census driver (golden found through each test's OWN `cmds.txt`) |
| `score190.py` | the golden × pristine × patched MULTISET join and its verdict |
| `predict190.sh` | the mover set, named from PRISTINE databases alone; reads the fence list out of `canaudit.sh` rather than spelling it |
| `grid190.sh` | the arm driver — one REAL Surelog golden per arm, both views, every rc recorded |
| `bound190.sh` | the wide boundary gate |
| `probe0.sv` | the head's own shape in twenty lines |
| `grid190/g190_a_bounds.sv` | 9 bound shapes |
| `grid190/g190_b_homes.sv` | 3 homes + the five OTHER clone positions of the same typedef |
| `grid190/g190_c_order.sv` | order / case / sharing / chaining / scalar / atom — the arm that TESTS rather than agrees |
| `DECODE.` `OWNER.pristine.` `OWNER.patched.` `MASK.` `HEADS.` `GATES.` `GRIDS.` `CENSUS.` `PREDICT.` `MOVERS.` `BOUNDARY.` `BOUNDARY_MOVERS.r10uvm190.txt` | the evidence |

## 9. REPRODUCING

```sh
./build190.sh                                          # the four instruments
CEN=/tmp/r10uvm190_cen/ct190cen ./predict190.sh <pristine wd> PREDICT.txt
CEN=/tmp/r10uvm190_cen/ct190cen ./grid190.sh probe0.sv <pris> <patched> <wd>
python3 score190.py <wd>/g.cen <wd>/a.cen <wd>/b.cen --section=TDCE
CEN=/tmp/r10uvm190_cen/ct190cen ./cen190.sh <workdir> <prefix>
ct190mask <golden> <ours> family   ref_obj 7859
ct190mask <golden> <ours> leaveout ref_obj 7859
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq \
                                 BuildUVMPkg Earlgrey_0_1 Rggen
PRIS=… PATCHED=… ./bound190.sh <copy of tools/probe> <outdir>
bash canaudit.sh canaries.sh ctcan2.sh
```
