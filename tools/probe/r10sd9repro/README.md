# r10sd9 — the ELEMENT-TYPESPEC IDENTITY defect: § classPropElemTsFollowsScalarTd9

**sd8's V-R1 is closed on the corpus and its standing counterexample `vgrid8/v1`
is DISSOLVED.** On all four UVM designs the element-typespec identity census goes
`IDENT_MATCH +10` and `GOLD-SET/OURS-NULL 11 → 1` (`7 → 1` on `BuildUVMPkg`), which
is the direction sd8's `ct8pop` key could not see at all (its F2). Seven databases
move, all seven predicted from the artifact first, all seven with a nonzero size
delta, and — unlike sd8 — the multiset distance to golden **IMPROVES** on every
one of them.

| | |
|---|---|
| BASE | `cf86237` (grep-checked `=1` in both worktrees) |
| worktrees | `/tmp/wt_r10sd9` (delivered), `/tmp/wt_r10sd9pris` (pristine control, `git status --porcelain` = 0) |
| delivered binary | md5 `34a24bb3eea7d84ccd6175c0a710f0bc` |
| pristine binary | md5 `9e59033458a8ba77f4b54ea2161c5dc6` |
| production files | `src/UhdmExporter.cpp`, `src/TypeEmit.cpp`, `include/UhdmExporter.h` |
| probe files | `tools/probe/r10sd9repro/` |

---

## 1. THE LAW

> **§ classPropElemTsFollowsScalarTd9** — the ELEMENT TYPESPEC of an
> unpacked-array declaration is **the object the SCALAR declaration of that same
> element type would bind**, and nothing else. When the element type is written
> as a **TYPEDEF NAME** that means the typedef's own registered object — the
> LISTING typespec for a class / struct / union / enum aggregate, and the
> per-declaration NAMED CLONE of that listing object for an integer atom
> (§ tdVecNamedClone42's kind gate) — carrying the typedef's NAME, the
> typedef's SPAN and the listing object's `vpiInstance`. Only an element written
> as a **BARE type** resolves to the underlying class or built-in.

**The discriminator the brief asked for, cell by cell** (grid `g1`, one dump):

| element type as WRITTEN | golden's element typespec | ours BEFORE | ours AFTER |
|---|---|---|---|
| typedef of CLASS, package-level (`tcls`) | `class_typespec(px::tcls)@10:11` `TOP:px` | `class_typespec(kx)@0:0` `<null>` | **== golden** |
| typedef of BUILT-IN, package-level (`tint`) | `int_typespec(tint)@11:11` `TOP:px` | `int_typespec()@18:5` `<null>` | **== golden** |
| typedef of STRUCT, package-level (`tstr`) | `struct_typespec(px::tstr)@12:11` `TOP:px` | **already == golden** | **HELD** |
| typedef of ENUM (grid `g6`) | listing object | **already == golden** | **HELD** |
| typedef of CLASS, CLASS-level (`this_t`) | `class_typespec(this_t)@10:11` `TOP:px` | `class_typespec(kx)@0:0` `<null>` | **NAME == golden**, span/stamp residue R1 |
| **BARE class** (`kx`) | `class_typespec(kx)@21:5` `<null>` | `class_typespec(kx)@0:0` `<null>` | **UNCHANGED** (span residue R3) |

**It is NOT "an array element binds the typedef".** It is "an array element binds
what its own SCALAR binds", and that is the sentence that survives the grid:
`g5_chain_td` shows a CHAINED typedef binding the listing object in the class arm
and **refusing to clone** in the atom arm — because that is exactly what
§ tdChainNoClone43 already makes the SCALAR do. A law phrased over "the typedef"
would have predicted a clone there and been wrong.

**And it is NOT a type-parameter law.** `g7_typeparam_control` separates the two:
`typedef T t_type; t_type a_alias[$]` MOVES (golden and we now agree on the name
`t_type`), while the raw `T a_param[$]` next to it **cannot** move — the declared
type is the parameter, not a `TypeAlias`, so `sharedAliasTs` returns null. That
is the corpus shape of `uvm_sequencer_param_base::m_last_req_buffer` /
`m_last_rsp_buffer`, and they are the two rows this pass leaves on the floor
**by construction**, not by omission.

### 1.1 The four `uvm_report_handler` spellings, scored individually

All four are class properties of `uvm_report_handler`, all four are golden
`GOLD-SET/OURS-NULL` rows in sd8's F2 list, and they are **two different arms**:

| property | written element type | golden | ours BEFORE | ours AFTER |
|---|---|---|---|---|
| `severity_id_actions` | `uvm_id_actions_array` (pkg typedef of `uvm_pool#(...)`) | `class_typespec(uvm_pkg::uvm_id_actions_array)@29:9` `ALL:adpcm_pkg` | `class_typespec(uvm_pool)@0:0` `<null>` | **== golden** |
| `severity_id_verbosities` | `uvm_id_verbosities_array` | `class_typespec(uvm_pkg::uvm_id_verbosities_array)@29:9` `ALL:adpcm_pkg` | `class_typespec(uvm_pool)@0:0` `<null>` | **== golden** |
| `severity_id_file_handles` | `uvm_id_file_array` | `class_typespec(uvm_pkg::uvm_id_file_array)@29:9` `ALL:adpcm_pkg` | `class_typespec(uvm_pool)@0:0` `<null>` | **== golden** |
| `sev_id_overrides` | `uvm_sev_override_array` | `class_typespec(uvm_pkg::uvm_sev_override_array)@29:9` `ALL:adpcm_pkg` | `class_typespec(uvm_pool)@0:0` `<null>` | **== golden** |
| `severity_actions` | `uvm_action` (pkg typedef of `int`) | `int_typespec(uvm_action)@272:9` `TOP:uvm_pkg` | `int_typespec()@67:3` `<null>` | **== golden** |
| `severity_file_handles` | `UVM_FILE` (pkg typedef of `int`) | `int_typespec(UVM_FILE)@313:9` `TOP:uvm_pkg` | `int_typespec()@77:3` `<null>` | **== golden** |

The four `*_array` names all resolve to the same generic class `uvm_pool`, which
is precisely why the old code — which read the **canonical** type — collapsed
four distinct golden identities into one wrong one. The two `int` spellings show
the OTHER arm: golden's object is not the listing entry but a per-declaration
clone, named for the alias, spanned at the typedef's `int` token, carrying the
listing object's `vpiInstance` and a `vpiTypedefAlias` ref back to it.

---

## 2. STATED GATE == CODE GATE

**STATED, in three places and nowhere else:**

1. `classElemVar` (the class-property element factory), **CLASS-HANDLE arm** — if
   the written element type is a `TypeAlias` with a registry entry
   (`sharedAliasTs`) and that entry is a `class_typespec`, bind it; otherwise
   keep the existing fresh, unlocated mint named for the resolved class.
2. `classElemVar`, **INTEGER-ATOM arm** — if the written element type is a
   `TypeAlias` with a registry entry, bind `tdVecNamedClone42`'s per-declaration
   named clone of it at position 0 and give the clone `vpiParent` -> its own
   element var; otherwise leave the actual typespec null so the caller's
   `predefIntTypespec` mint runs exactly as before.
3. `classElemVar`, **ON-DEMAND PRELUDE** — `emitClassDefn` walks VARIABLES before
   it calls `emitClassTypedefs`, so a class's OWN nested typedefs are not yet in
   `typedefTs` when this factory runs; force `buildClassTypedefTs` for a
   class-nested element alias first, under the identical package-or-class gate
   `makeTypespec` already carries for the scalar path.
4. `makeTypespec`'s § arrayElemTypedefTs15 arm — when the unpacked-array element
   alias's canonical leaf is a `ClassType` and `typedefTs` has no entry (which is
   ALWAYS, for a class-handle typedef: § classTdTopOnlyShare50's own comment says
   those are registered in `pkgTopTypedefTs` alone), return the `pkgTopTypedefTs`
   entry if it is a `class_typespec`.

Nothing else changes: no name, span, parent or instance is written on any shared
object, no listing is reached, and the fresh-mint paths are byte-for-byte the old
ones on every input that does not satisfy the gate.

**CODE** — `git diff cf86237 --numstat`: `src/UhdmExporter.cpp` **+87/−7**,
`src/TypeEmit.cpp` **+26/−0**, `include/UhdmExporter.h` **+6/−1**. Of the 113
inserted lines, **86 are comment**; the executable change is 27 lines.

```cpp
// (1) classElemVar, CLASS-HANDLE arm
    UHDM::typespec* sh9 = sharedAliasTs(elemType);
    if (sh9 && sh9->UhdmType() == UHDM::uhdmclass_typespec)
        ts = sh9;
    else { /* the old fresh mint, unchanged */ }

// (2) classElemVar, INTEGER-ATOM arm
    if (declKey9)
        if (auto* sh9 = sharedAliasTs(elemType))
            if (auto* cl9 = tdVecNamedClone42(elemType, (const void*)declKey9,
                                              sh9, /*posKey=*/0)) {
                cl9->VpiParent(v);
                ts = cl9;
            }

// (3) classElemVar, ON-DEMAND PRELUDE  (transcribed from makeTypespec)
    if (elemType.kind == SymbolKind::TypeAlias && !typedefTs.count(&elemType))
        if (auto* osc9 = elemType.getParentScope();
            osc9 && osc9->asSymbol().kind == SymbolKind::ClassType) {
            auto& ocl9 = osc9->asSymbol().as<ClassType>();
            if (auto* opsc9 = ocl9.getParentScope();
                opsc9 && (opsc9->asSymbol().kind == SymbolKind::Package ||
                          opsc9->asSymbol().kind == SymbolKind::ClassType))
                buildClassTypedefTs(ocl9, std::string(ocl9.name));
        }

// (4) makeTypespec, § arrayElemTypedefTs15's class-typedef sibling
    if (el9->getCanonicalType().kind == SymbolKind::ClassType &&
        !typedefTs.count(el9))
        if (auto c9 = pkgTopTypedefTs.find((const void*)el9);
            c9 != pkgTopTypedefTs.end() && c9->second &&
            c9->second->UhdmType() == UHDM::uhdmclass_typespec)
            return c9->second;
```

### 2.1 COVERAGE OF THE CODE'S OWN GUARDS — declared, not assumed

| guard | fires on the corpus? | what proves it |
|---|---|---|
| (1) `sh9 && kind == class_typespec` | **FIRES BOTH WAYS** | 8 class rows per UVM design take the share; grid `g1`'s `a_bare` and `g7`'s `a_param` take the else-branch and are byte-unchanged |
| (2) `declKey9` non-null | **never rejects** | the only two callers of `classElemVar` both pass `&cp`; kept because the default argument makes a null caller expressible |
| (2) `sharedAliasTs` + `tdVecNamedClone42` | **FIRES BOTH WAYS** | 2 int rows per UVM design clone; grid `g5`'s `ti2` chain is REFUSED by § tdChainNoClone43 and stays on the old mint |
| (3) package-or-class owner gate | **never rejects on the corpus** | every class-nested alias reached is package-homed; grid has no `$unit` class cell, so this guard's only coverage is the transcription it comes from |
| (4) `!typedefTs.count(el9)` | **never rejects** | a class-handle typedef is never in `typedefTs` by construction (§ classTdTopOnlyShare50); carried so the arm cannot preempt the `typedefTs` lookup two lines below it if that ever changes |

Two of the five guards are **carried but unexercised**, and they are named here
because an unexercised guard that goes unmentioned is how a stated gate stops
being the code gate (sd8 F4's lesson, applied to this pass's own table).

---

## 3. THE DECODE

### 3.1 The instrument sd8's verifier did by hand — `ct9id`

sd8 F2 re-keyed `ct8pop`'s `d1 var/ts` cell **by hand** because that key carries
the typespec's KIND+NAME, so the rows where the two sides *disagree about the
identity* never join. `ct9id` does it mechanically: key = *(owner full name +
span, variable name, element ordinal)*, value = *(kind, name, span, instance
view)*. An `array_var` carries exactly one element variable on both sides, so the
key is total.

| design | pristine | delivered |
|---|---|---|
| `SeqDriver` | `shared=147 IDENT_MATCH=71 IDENT_DIFF=76 STAMP_MATCH=132` **`GOLD_SET_OURS_NULL=11`** `OURS_SET_GOLD_NULL=4` | `IDENT_MATCH=81 IDENT_DIFF=66 STAMP_MATCH=142` **`GOLD_SET_OURS_NULL=1`** `OURS_SET_GOLD_NULL=4` |
| `SimpleUVM` | `shared=141 IDENT_MATCH=65 … GOLD_SET_OURS_NULL=11` | `IDENT_MATCH=75 … GOLD_SET_OURS_NULL=1` |
| `Scoreboard` | `shared=143 IDENT_MATCH=65 … GOLD_SET_OURS_NULL=11` | `IDENT_MATCH=75 … GOLD_SET_OURS_NULL=1` |
| `BuildUVMPkg` | `shared=146 IDENT_MATCH=69 … GOLD_SET_OURS_NULL=7` | `IDENT_MATCH=79 … GOLD_SET_OURS_NULL=1` |

`BOTH_SET_VIEW_DIFF` is **0 on all four, on both binaries** — the patch creates no
new stamp disagreement anywhere. `OURS_SET_GOLD_NULL` is **4 → 4**: sd8's R1, the
shared aggregate import clone, deliberately untouched.

**`IDENT_DIFF` is 76 → 66 and NOT 76 → 0, and the 66 are named**: 62 of them are
`class_typespec <- class_typespec` rows whose NAME already agrees and whose SPAN
is ours-`@0:0-0:0` against golden's real one — sd8 R4's `@0:0` family, a
different law. Splitting `IDENT_DIFF` by name-vs-span is what makes the
13-row figure in sd8 F2 reproducible: **name/kind diffs 13 → 3**.

### 3.2 The 13 rows, before and after, on `SeqDriver`

```
FIXED (10):
  uvm_callbacks_base::m_this_type          class_typespec(uvm_callbacks_base) -> (adpcm_pkg::this_type) ALL:adpcm_pkg
  uvm_port_base::m_imp_list                class_typespec(uvm_port_base)      -> (adpcm_pkg::this_type) ALL:adpcm_pkg
  uvm_port_base::m_provided_by             "                                  -> "
  uvm_port_base::m_provided_to             "                                  -> "
  uvm_report_handler::severity_id_actions      class_typespec(uvm_pool) -> (uvm_pkg::uvm_id_actions_array)     ALL:adpcm_pkg
  uvm_report_handler::severity_id_verbosities  "                        -> (uvm_pkg::uvm_id_verbosities_array) ALL:adpcm_pkg
  uvm_report_handler::severity_id_file_handles "                        -> (uvm_pkg::uvm_id_file_array)        ALL:adpcm_pkg
  uvm_report_handler::sev_id_overrides         "                        -> (uvm_pkg::uvm_sev_override_array)   ALL:adpcm_pkg
  uvm_report_handler::severity_actions         int_typespec()           -> (uvm_action) TOP:uvm_pkg
  uvm_report_handler::severity_file_handles    int_typespec()           -> (UVM_FILE)   TOP:uvm_pkg
LEFT, AND WHY (3):
  uvm_enum_wrapper::map                        bit_typespec() vs golden enum_typespec(uvm_pkg::uvm_active_passive_enum)
  uvm_sequencer_param_base::m_last_req_buffer  class_typespec(uvm_sequence_item) vs golden class_typespec(rsp_type)
  uvm_sequencer_param_base::m_last_rsp_buffer  "
```

All three are **class TYPE PARAMETERS**, not typedefs — `protected T map[string]`,
`protected RSP m_last_rsp_buffer[$]`. Golden spells them with a typedef's name
because Surelog's type-parameter path reuses the alias object; the declared type
in the source is the parameter, so no registry lookup can reach them. Grid cell
`g7` is that refutation in 14 lines of SystemVerilog and it is delivered with the
pass.

### 3.3 WHY THE CLASS-NESTED HALF NEEDED AN ORDERING FIX, and how it was found

The first patch fixed only 6 of the 10. The four `this_type` rows did not move,
and the reason is ORDER, not policy: `emitClassDefn` emits `vpiVariables` and
only afterwards calls `emitClassTypedefs`, so `typedefTs` is EMPTY for the class's
own nested typedefs at the moment the element factory runs. `makeTypespec`
already carries an on-demand `buildClassTypedefTs` for exactly this reason (its
`IOClassStruct` comment); transcribing it into `classElemVar` moved the other
four. The measured sequence is in this directory's own record: `IDENT_MATCH`
71 → 77 with the first two arms, 77 → **81** once the prelude was added.

---

## 4. THE GRID — golden's rule, cell for cell

`ct9grid.sh` over `grid9/g*.sv`, both binaries, every cell scored on THREE
measures (cmp verdict + head count, dump content, and the `ct9id` row census).

| cell | shape | cmp pris → new | dump content | `ct9id` `IDENT_MATCH` / `GOLD_SET_OURS_NULL` |
|---|---|---|---|---|
| **`g1_pkgtd_kinds`** | **THE CORE CELL** — scalar+array of class / int / struct typedef, bare class, class-nested typedef, in ONE class | CMP_FAIL → CMP_FAIL | **141 → 111** | **1/4 → 4/1** |
| **`g2_spellings`** | one class typedef, ALL FOUR array spellings (assoc, dyn, queue, **fixed**) | PASS_CMP → PASS_CMP | **46 → 22** | **0/4 → 4/0, EVERY ROW EXACT** |
| **`g3_pkgvar_module`** | the `makeTypespec` half: PACKAGE and MODULE variables, no class property | CMP_FAIL → CMP_FAIL | **411 → 363** | 0/0 → 0/0, all three names now == golden (span residue R2) |
| `g4_foreign_td_control` | **NEGATIVE CONTROL**: typedef declared in a BASE class | PASS → PASS | 24 → 24 | **`ct9id` `diff`-IDENTICAL** |
| `g5_chain_td` | typedef CHAIN to a class and to an int | CMP_FAIL → CMP_FAIL | **69 → 63** | 0/2 → 1/1; the int chain REFUSES to clone (§ tdChainNoClone43) |
| `g6_enum_td_control` | **NEGATIVE CONTROL**: enum typedef element (already shared) | PASS → PASS | 16 → 16 | **`ct9id` `diff`-IDENTICAL** |
| `g7_typeparam_control` | **REFUTATION CELL**: type parameter vs typedef-of-type-parameter | CMP_FAIL → CMP_FAIL | **92 → 88** | typedef-of-param name FIXED; raw param UNMOVED |

**EMPTY-PRODUCT HUNT.** `g4` and `g6` are the two cells that score nothing in the
moved column, and both are judged by something that costs: whole-design
`PASS_CMP` on both binaries **and** an unchanged dump-content count **and** a
`diff`-identical row census with a non-empty population (`golden_rows=1` each,
printed).

**DETERMINISM.** `detcheck.sh` with the delivered binary on `g1`, `g2` and `g4`:
**3 runs each, 1 distinct sha256, 0 NO_OUTPUT**.

### 4.1 THE STANDING COUNTEREXAMPLE, SCORED — `vgrid8/v1`

sd8's verifier delivered `vgrid8/v1` as the cell any refinement of § …8 must
score. **The row it names is now EXACT.**

```
CLS qa::ca :: ma        <- THE CLASS COPY, F1's cell
  GOLDEN  class_typespec (pa::ta) @8:11-8:13  inst=ALL:qa
  PRISTINE class_typespec (ka)    @9:3-9:5    inst=<null>
  DELIVERED class_typespec (pa::ta) @8:11-8:13 inst=ALL:qa   == GOLDEN
```

and two of the three package listings follow it (`TOP:pa`, `TOP:qa` both exact,
identity AND stamp). Whole-cell dump content **146 → 130**. The cell stays
`CMP_FAIL` on both binaries with the SAME head it had before — `logic_var(pa::ma)`
vs `ref_var(pa::ma)`, the element VARIABLE's kind, an unrelated defect — which is
why v1 is scored on the census and not on the verdict. `v2`, `v3` and all six of
sd8's `grid8` cells are **byte-unchanged** between the two binaries.

---

## 5. THE MOVERS

### 5.1 Census-predict, made FIRST and from the ARTIFACT — `ct9pred` / `ct9scan.sh`

`ct9pred` pairs each database with the golden its own `cmds.txt` names and counts
element-typespec rows where golden names a typedef, we name the resolved type,
and our database already contains a listing typespec of that kind and name.
**Calibrated before use**: golden-vs-golden **0**, golden-vs-pristine `SeqDriver`
**13**, golden-vs-delivered `SeqDriver` **3**.

Run over every PRISTINE database, before any delivered database was compared:

| corpus | databases scanned | with rows | rows |
|---|---|---|---|
| surelog | **953** | **7** | **91** (13 each) |
| uhdm2rtlil | **1358** | **0** | **0** |

```
PREDICT default/BuildUVMPkg   default/Scoreboard   default/SeqDriver   default/SimpleUVM
        testflags/BuildUVMPkg testflags/SeqDriver  testflags/SimpleUVM
```

Delivered score over the same 953: the same 7 databases, **3 rows each = 21**.
Predicted movers = 7 databases, 70 rows converted. **The byte verifier found
exactly those seven databases, name for name, and exactly zero in uhdm2rtlil.**

`ct9pred`'s own limit is stated in its header and is why the delivered score is
part of the procedure: the 3 residual rows per design are TYPE-PARAMETER shapes
that no artifact-side clause can distinguish from typedefs, because the
distinction lives in the source.

### 5.2 The MOVER RULE — size delta on every mover

| row | pristine | delivered | Δ |
|---|---|---|---|
| `default/SeqDriver` | 18 021 771 | 18 021 280 | **−491** |
| `testflags/SeqDriver` | 18 022 188 | 18 021 694 | **−494** |
| `default/Scoreboard` | 11 145 719 | 11 145 637 | **−82** |
| `default/SimpleUVM` | 11 141 521 | 11 141 435 | **−86** |
| `testflags/SimpleUVM` | 11 141 859 | 11 141 774 | **−85** |
| `default/BuildUVMPkg` | 11 105 941 | 11 105 834 | **−107** |
| `testflags/BuildUVMPkg` | 11 105 941 | 11 105 834 | **−107** |

All seven nonzero: **REAL movers** by the standing law. `testflags/Scoreboard` is
`SLANG_REJECT` at baseline (`use of undeclared identifier 'my_scoreboard'`,
verified in both CSVs), produces no database, and is a **SKIP** — never
agreement.

### 5.3 Per-shape movers by MULTISET, ADDED and REMOVED separately

`ct7shape.py`, `sed 1d` + workdir-path normalisation on all three dumps.

| design | ADDED / REMOVED total | shapes IMPROVED | shapes WORSENED | msdist pris → new |
|---|---|---|---|---|
| `SeqDriver` | 38 / 146 | **13** | 2 | 359 594 → **359 484 (−110)** |
| `SimpleUVM` | 34 / 46 | **13** | **0** | 140 221 → **140 145 (−76)** |
| `Scoreboard` | 34 / 46 | **13** | **0** | 130 523 → **130 447 (−76)** |
| `BuildUVMPkg` | 37 / 49 | **13** | **0** | 77 937 → **77 855 (−82)** |

The transcription, identical on all four: `class_typespec` ADDED 8 / REMOVED 16,
`int_typespec` ADDED 8 / REMOVED 4, `vpiClassDefn` REMOVED 8, `class_defn`
REMOVED 8, `vpiName` REMOVED 8 — eight fresh class mints and two fresh atom mints
replaced by eight shared listing objects and two named clones — plus the clones'
`vpiTypedefAlias` / `ref_typespec` / `vpiInstance` / `vpiParent` / `vpiFullName`
ADDED 2 each.

**THE COST, STATED PLAINLY: `SeqDriver` worsens on TWO shapes.**
`vpiClassDefn` 961 → 969 (+8) and `vpiActual` 4899 → 4903 (+4), and both are the
instrument artefact sd8's V-R7 named rather than a defect: the changed lines are
BARE marker lines keyed only by indentation (`  |vpiClassDefn:`), golden runs
LONG on them (9913 to our 8952), so deleting eight correct objects of ours widens
that deficit by eight no matter where they were. Named, not netted: the three
other designs have **zero** worsened shapes, and every design's whole-design
msdist improves.

### 5.4 The seven live UVM rows — head tuples on BOTH binaries

| row | pristine | delivered | cmp lines |
|---|---|---|---|
| `default/SeqDriver` | `class_var(access_record)@483:34` / `struct_var(access_record)@483:34` | **identical object** | **56 → 56** |
| `testflags/SeqDriver` | same | **identical object** | **56 → 56** |
| `default/SimpleUVM` | `part_select: arb_sequence_q@681:23` both sides | **identical object** | 142 → 142 |
| `testflags/SimpleUVM` | same | **identical** | 142 → 142 |
| `default/Scoreboard` | same | **identical** | 142 → 142 |
| `default/BuildUVMPkg` | `struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)@11947:40` / `logic_typespec@11965:5` | **identical** | 94 → 94 |
| `testflags/BuildUVMPkg` | same | **identical** | 94 → 94 |

Every head is `grep -c '^LHS:' == 1`. **R0 — `SeqDriver`'s head does NOT move**:
the seven databases move BYTES and move the object census without moving any
head, because every object this pass touches is a CLASS-LISTING element typespec
and every one of the seven heads is reached earlier (a subroutine-local
`class_var`/`struct_var` on `SeqDriver`, a `part_select` on `SimpleUVM`/
`Scoreboard`, a package `struct_typespec` on `BuildUVMPkg`). The only difference
in the seven cmp logs between the two binaries is the arena `id:` of the RHS
objects, which shifts because fewer objects are minted.

---

## 6. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line waited for, md5 asserted separately, 32-hex | both worktrees `BASE cf86237` grep-checked **=1**; both ` error:` count **0**; `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen **before** any md5 was read; delivered **`34a24bb3eea7d84ccd6175c0a710f0bc`**, pristine **`9e59033458a8ba77f4b54ea2161c5dc6`** — 32 hex each, different. Pristine worktree `git status --porcelain` = **0 lines** |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | 679/50/2, dump 496/183/52, `ct8rows` 0 rows | default **679/50/2**, testflags **679/50/2**, BOTH binaries; dump testflags **496 match / 183 differ / 52 blank**; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv` (testflags-filtered first — the 731-row trap) → **0 differing ROWS (0 row-sides)**; pristine-vs-delivered → **0 rows**; pristine-vs-committed → **0 rows** |
| **4 surelog** | both j2 469/11 + 465/8, FAIL 25/23, DEFER 5/5, histograms unchanged, 0 rows | default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT**; testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM), BOTH binaries. All four dump histograms **identical** to committed (default 225 match/244 differ/325 blank; testflags 165/300/329). `ct8rows` vs committed `results/golden_surelog.csv` → **0 differing ROWS**; pristine-vs-delivered → **0 rows**; pristine-vs-committed → **0 rows** |
| **5 BYTE VERIFIER** | both corpora, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | surelog **7 / 953**, u2r **0 / 1358**; `PATH_SETS_IDENTICAL` both; SELFCHECK **952/953** and **1357/1358**; SELFCHECK1 **8** and **1** — arithmetic consistent (1 corruption + 7 real; 1 corruption + 0 real). The 7 are **exactly the predicted set** (§5.1), all with nonzero SIZE-DELTA (§5.2); per-shape movers are the transcription and nothing else (§5.3) |

`GOLDEN_DEFER` printed **`[UNSET]`** before the sweeps. All sweeps `--jobs 2` with
private `--out`/`--workdir`. **`SLANG_UHDM` pin verified by reading `cmds.txt`
exhaustively on all FOUR trees**: surelog 1573 cmds files / **1523 `slang:` lines,
1523 name the right binary, 0 name any other**; u2r 1462 / **1458, 1458 / 0**.
`results/*.csv` READ ONLY (`git status --porcelain -- results` = 0 lines). No
`git stash`. slang not patched.

### 6.1 CANARIES

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names 7 (documented u2r-only names) — vs committed **and** vs this pass's pristine sweep |
| `canaries.sh` u2r | at baseline | **ok=8** vs committed (testflags-filtered), **ok=16** vs pristine (both modes), changed=0 absent=0 |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1`, baseline FIRST | **ok=58 changed=0 absent=0 unknown-patterns=1**, **PASS**, vs committed and vs pristine |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6`, testflags-only CSV | **ok=1 changed=0 absent=0 unknown-patterns=6**, **PASS** |
| `canaudit.sh` | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, **PASS**, run against THIS directory's scripts |
| fenced names | dispatched by no driver | `UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` — all four **not dispatched by any driver** |
| `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`, `SVSwitch` databases | **byte-identical** | all four, **both modes**, `cmp -s` **BYTE-IDENTICAL** between the two binaries |

### 6.2 BOUNDARIES — every one RE-RUN on BOTH binaries, none cited

* **sd8 `grid8` (6 cells) and `vgrid8` (3 cells)** — verdict, head count and dump
  content **identical between the two binaries on 8 of 9**; `v1` is the ninth and
  it moves **in sd8's verifier's own direction** (§4.1).
* **sd7 `grid7` (6 cells) + `grid7v` (3 cells)** — **all nine identical** on both
  binaries, verdict and dump content.
* **sd6 `grid6` (6 cells)** — **all six identical**.
* **sd4 `qgrid4` (13 cells)** — **8 identical, 5 MOVED, and every moved line is
  attributed and is an IMPROVEMENT.** `q1`, `q7`, `q9`, `q11`, `qv12` each drop
  exactly 2 dump-content lines, and in every one of the five the ONE line pair
  that disappears is the same:
  ```
  golden  \_class_defn: (pN::cN)            <- the struct_typespec's vpiParent
  ours    \_struct_var: (pN::cN::mN)        <- BEFORE
  (gone)                                    <- AFTER: we now agree with golden
  ```
  These are CLASS-NESTED **struct** typedef elements, and they move for the same
  reason the `this_type` rows do: § classPropElemTsFollowsScalarTd9's ON-DEMAND
  half makes `sharedAliasTs` succeed where the pre-existing struct arm was
  already asking and getting null, so the write-phase mint no longer runs and the
  listing object (parented at the `class_defn`, as golden has it) is bound
  instead. **Zero new difference lines appear in any of the five.**
* **live passes.** No file overlap is known to this pass; `src/UhdmExporter.cpp`,
  `src/TypeEmit.cpp` and `include/UhdmExporter.h` are the whole production
  surface, and the hunks are `classElemVar` / `classAssocElemVar` (~1820–1960),
  `makeTypespec`'s § arrayElemTypedefTs15 arm (~960) and one declaration.

---

## 7. REFUTATIONS

### 7.1 The brief's "13 slots" is 10, and the other 3 are not typedefs at all

The brief (from sd8 V-R1/F2) frames the defect as 13 mis-keyed slots of which 11
are `GOLD-SET/OURS-NULL`. Both numbers reproduce exactly. But **the 13 are not one
family**: 10 are typedef spellings this law reaches and 3 are class TYPE
PARAMETERS it provably cannot (§3.2), and the split is not visible from either
artifact — it lives in the declared type in the source. `g7_typeparam_control`
delivers the refutation as a cell so the next pass does not re-derive it.

### 7.2 "Fixing identity is expected to DISSOLVE sd8's F1 counterexample" — TRUE, and measured

The brief's expectation is confirmed on the row F1 names (§4.1): no second gate
was needed, and § importCopyElemVarTsNoInstance8's `srcPkgName` gate was neither
touched nor widened. `g6_typedef_elem_import` — the cell that caught sd8's own
over-fire — is byte-unchanged.

### 7.3 "The SeqDriver head may move" — IT DOES NOT, on any of the seven rows

Measured, not assumed: all seven head OBJECTS are identical between the two
binaries; only arena `id:` numbers shift. **R0 = sd8's R3 / V-R3, unchanged.**
This pass buys 70 converted census rows and 1 552 dump lines across four designs
and buys **no head**, and that is reported rather than dressed up.

### 7.4 MY OWN INSTRUMENT WAS WRONG FIRST, AND THE GRID DID NOT CATCH IT — the corpus did

`ct9id`'s `viewOf` used to label a non-package `vpiInstance` as
`"OTHER:" + i->VpiName()`. `vpiInstance` is typed `instance*` but a class-NESTED
typedef's listing typespec stores a **`design`** there — on BOTH sides — and a
`design` is not an `instance` in the installed UHDM, so that call reads through
the wrong vtable. The first delivered-side census therefore reported
**`BOTH_SET_VIEW_DIFF=0 → 4`** on `SimpleUVM` and `Scoreboard`: four brand-new
stamp disagreements that **did not exist**. The dumps of both sides read
`|vpiInstance:` / `\_design: (work@top)`, character for character. Fixed before
shipping (the label now leads with the object's `UhdmType`, read off the object);
re-measured, `BOTH_SET_VIEW_DIFF` is **0 on all four designs on both binaries**.
Kept in the source as a comment because a census that can invent a difference can
also hide one.

---

## 8. RESIDUES, RANKED

1. **R1 — the CLASS-NESTED class-handle typedef's LISTING OBJECT has the wrong
   SPAN and no `vpiTypedefAlias`/`vpiInstance` when its target class is NOT
   generic.** § classNestedClassTdJoinsPkgGroup50 gates on
   `ct.as<ClassType>().genericClass`, so `typedef kx this_t;` where `kx` is a
   plain class never joins `kx`'s package-level typedef group: grid `g1` reads
   golden `class_typespec(this_t)@10:11-10:13` `TOP:px` against ours
   `@22:13-22:15` `<null>`. The NAME is now right (this pass) and the rest is
   pass 50's gate. It is invisible on the corpus only because every UVM
   `this_type` targets a parameterized class. **Cheapest next item, and it is one
   condition.**
2. **R2 — the class-handle typedef's TOP listing object misses the
   `pendingPkgTsStretch` span stretch.** Grid `g3`: golden
   `class_typespec(pz::tcz)@9:11-**20:14**` (stretched to the first module-signal
   use declarator) against our `@9:11-9:13`. Every other package typedef kind
   gets the stretch at `src/ParamEmit.cpp:18990`; `pkgClassTd9`'s arm does not
   push. Three rows in one 20-line cell, zero on the corpus today.
3. **R3 — the BARE class element typespec has NO SPAN.** `classElemVar`'s
   fresh-mint arm (the else-branch this pass leaves alone) sets a name and no
   location: grid `g1` `a_bare` golden `class_typespec(kx)@21:5-21:7` vs ours
   `@0:0-0:0`, and 62 of `SeqDriver`'s 66 remaining `IDENT_DIFF` rows are that
   same `@0:0` shape. **This is sd8 R4 seen from the element side and it is now
   the largest single block in the census** — 62 rows per UVM design, all
   name-correct and span-empty.
4. **R4 — the per-declaration atom clone's `ref_typespec` `vpiFullName`.**
   Golden `px::cm::a_int::tint`, ours `tint` (grid `g1`, and the SCALAR has the
   same defect, so it is `tdVecNamedClone42`'s and not this pass's). Golden also
   gives the SCALAR clone a `vpiParent` we do not; this pass sets it on the
   ELEMENT clone only, because that is the position it measured.
5. **R5 — `uvm_enum_wrapper::map` and `uvm_sequencer_param_base::m_last_*_buffer`,
   the TYPE-PARAMETER element identity.** 3 rows per UVM design, `g7`'s
   `a_param` arm. Golden reuses the alias object for a raw type parameter; we
   resolve to the specialization. A different law with its own grid cell already
   written.
6. **R6 — sd8's R1 is still open and still 4 rows** (`OURS_SET_GOLD_NULL=4`,
   unchanged on all four designs): `uvm_component`'s `m_verbosity_settings` /
   `m_time_settings` and `m_uvm_applied_cl_action` / `m_uvm_applied_cl_sev`
   carry a stamp golden leaves null. Untouched here on purpose (shared aggregate
   import clone, § pkgImportCloneLastWriter32's law, sd8 §9.7's backfire risk).
7. **R7 — `ct9pred` cannot separate a typedef from a type parameter**, so its
   number is a superset and the delivered score is load-bearing (§5.1). Either
   teach it the `vpiTypedefAlias` shape or accept the two-run procedure and say
   so, as it now does in its own header.
8. **R8 — the multiset instrument still worsens on `vpiClassDefn`/`vpiActual`**
   for `SeqDriver` (§5.3), for sd8 V-R7's reason. Unchanged, and paired with the
   object census as required.

---

## 9. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct9id.cpp` | **THE ELEMENT-TYPESPEC IDENTITY CENSUS**, and the answer to sd8 F2: it re-keys `ct8pop`'s `d1 var/ts` cell on *(owner, variable, ordinal)* so the rows where the two sides disagree about the identity actually JOIN. Reports IDENT / STAMP separately and splits stamp disagreement into both directions. Its `viewOf` carries the § 7.4 defect note. Empty population = exit 5. |
| `ct9pred.cpp` | **ARTIFACT-BASED MOVER PREDICTION**, calibrated golden-vs-golden 0 / pristine 13 / delivered 3, with its own limit stated in its header (R7). |
| `ct9scan.sh` | `ct9pred` over every database of a sweep workdir, pairing each with the golden its own `cmds.txt` names. Zero databases = exit 5. |
| `ct9grid.sh` `grid9/g1…g7.sv` | the seven cells of §4 — the core cell, the four-spelling cell, the `makeTypespec` half, two negative controls and the type-parameter refutation cell. |
| `vsd8elem.cpp` | sd8's verifier's element-sharing/user-count probe, carried forward. |
| `ct8*.cpp` `ct8grid.sh` `grid8/` `vgrid8/` | sd8's kit, carried forward unchanged and RE-RUN as the boundary checks of §6.2. |
| `ct4*` `ct5*` `ct6*` `ct7*` `qgrid4/` `grid6/` `grid7/` `grid7v/` | sd4…sd7's kits, same treatment. |
| `byteverify.sh` `msdist.sh` `ct7shape.py` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `rowheads.sh` `manifest.sh` `dumptree.py` `census.py` `slots.py` `cells.py` `TAP.md` | carried forward unchanged. |

---

## 10. THE PATCH

`/tmp/r10sd9.patch` — `git diff` vs `cf86237`, `include/` + `src/` +
`tools/probe/r10sd9repro` only. Reproducible with:

```sh
cd /tmp/wt_r10sd9 && git add -A tools/probe/r10sd9repro
git diff cf86237 --binary -- include src tools/probe/r10sd9repro > /tmp/r10sd9.patch
md5sum /tmp/r10sd9.patch
```

The md5 is delivered with the pass's final report and NOT written here: this file
is inside the patch, so any md5 recorded here is stale the moment it is written.
