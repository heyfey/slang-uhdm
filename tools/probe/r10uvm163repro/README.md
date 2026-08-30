# r10uvm163 — § `classPropSpecForeignPkgHome163`

*A **class PROPERTY** typed by a written, **UNQUALIFIED** `G #(...)` carries the
specialization listing — `vpiParameter` + `vpiParamAssign` — exactly when
Surelog's three `getClassDefinition` probes all MISS, i.e. when `G`'s home
**package** is not the declaring class's home package (walking THROUGH
enclosing classes), and `G` is not one of the three built-ins Surelog registers
under a bare name.*

Base commit **578ffc2**. LHS is **always** golden (Surelog); RHS is always
ours. The judge is `~/git-repos/UHDM/build/bin/uhdm-cmp` and nothing else;
every instrument in this directory is measurement-only and links the same
generated `Compare`. slang was NOT patched; `results/*.csv` were READ ONLY.

---

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **Scoreboard default** | **145** cmp lines, 1 head | **95**, 1 head — a **DIFFERENT** object (R0) |
| SeqDriver default / testflags | 29, 1 head | 29 — head log **BYTE-IDENTICAL** |
| SimpleUVM default / testflags | 29, 1 head | 29 — **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 106, 1 head | 106 — **BYTE-IDENTICAL** |
| BuildUVMPkg default / testflags | 29, 1 head | 29 — **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 58 / 62, 1 head | 58 / 62 — **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this base's own pristine control CSVs (1588 surelog row-modes + 1358 u2r × 2 modes), status column **and** dump column |
| byte movers | — | **1 / 956** surelog — the one database predicted BY NAME; **0 / 1358** uhdm2rtlil |
| the law's corpus population | **1** wrong cell in 1 database (9 UVM row-modes censused, 4 418 joined cells) | **0** — WRONG→RIGHT 1, **RIGHT→WRONG 0**, **AWAY 0**, **RESHAPE 0** |
| the three grids, 2 views each | — | **TO-GOLDEN 36, MOVED-WRONG 0, AWAY 0** |
| wide boundary | — | 4643 arm files × 2 views, 7 moved, **every one re-measured against golden: MOVED-WRONG 0, AWAY 0** (`BOUNDARY.r10uvm163.txt`) |

No row was converted. Scoreboard/`default` is RESUME.md §9's documented ~50/50
COIN, so `coin163.sh` ran the row **five times per binary**: three distinct
databases each side, **145 cmp lines on all five pristine runs and 95 on all
five patched runs** — the move is the law, not the coin.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reads Scoreboard/`default`
**145 cmp lines, one `^LHS:`**:

```
LHS: class_typespec: (uvm_analysis_imp), line:9:3, endln:9:19
     |vpiParent: \_class_var: (work@my_scoreboard::m_imp), line:9:42, endln:9:47
     |vpiName:uvm_analysis_imp
     |vpiParameter: \_type_parameter: (…::uvm_analysis_imp::T)  @110:31-110:32
                    |vpiActual: \_int_typespec: @9:22-9:25
     |vpiParameter: \_type_parameter: (…::uvm_analysis_imp::IMP)   (NO SPAN)
                    |vpiActual: \_class_typespec: (my_scoreboard) @9:20-9:41
     |vpiParamAssign: @110:31-110:32   vpiLhs = uvm_pkg::uvm_analysis_imp::T
     |vpiParamAssign:  (NO SPAN)       vpiLhs = uvm_pkg::uvm_analysis_imp::IMP
     |vpiClassDefn: \_class_defn: (uvm_pkg::uvm_analysis_imp)
RHS: <null>
```

The cell is `Scoreboard/design.sv:9`,
`uvm_analysis_imp #(int, my_scoreboard) m_imp;` — a property of the `$unit`
class `my_scoreboard`, of a generic that lives in `uvm_pkg`.

### 1a. WHICH EDGE — decided by the owner-finder, not by the cmp text

`RHS: <null>` is ambiguous by construction: UHDM's **vector** `SafeCompare`
sets the OWNER as LHS and leaves RHS unset, which prints byte for byte what a
missing **singular** object prints (RESUME.md §9, head decoding). `ct163own`
runs the OFFICIAL whole-design `Compare`, recovers our counterpart by
(kind, name, line:col, holder name) — **exactly one match, asserted** — and
walks `class_typespec::Compare`'s own field order
(`~/git-repos/UHDM/build/generated/src/class_typespec.cpp:206-234`):

```
HEAD LHS = class_typespec(uvm_analysis_imp)@9:3-9:19
HEAD RHS = <null>
counterpart candidates in OURS: 1
holder Typespec edge: golden=present ours=present      <- the competing reading, REFUTED
   NAME   VpiName          LHS=uvm_analysis_imp   RHS=uvm_analysis_imp
   SINGLE Typedef_alias / Instance / Extends      both <null>
   VECTOR Variables / Task_funcs / Constraints    both null
-> VECTOR Parameters            LHS=2        RHS=null
   VECTOR Param_assigns         LHS=2        RHS=null
   SINGLE Class_defn            the SAME class_defn on both sides
```

So the head is **the `Parameters` vector, index 0, of a `class_typespec` we
already emit** with the right name, the right span and the right
`vpiClassDefn` — not a missing typespec, and not the class_var's singular
`Typespec` edge, which both sides carry. `Param_assigns` is the same deficit
one field later.

---

## 2. THE DECODED MODEL (Surelog, read line by line, then measured)

`CompileHelper::compileTypespec`'s `slStringConst` case
(`~/git-repos/Surelog/src/DesignCompile/CompileType.cpp:1896-1918`) tries three
probes before anything else:

```cpp
ClassDefinition* cl = design->getClassDefinition(typeName);
if (cl == nullptr) cl = design->getClassDefinition(StrCat(component->getName(), "::", typeName));
if (cl == nullptr)
  if (const DesignComponent* p = valuedcomponenti_cast<const DesignComponent*>(component->getParentScope()))
    cl = design->getClassDefinition(StrCat(p->getName(), "::", typeName));
if (cl) { class_typespec* tps = s.MakeClass_typespec();
          tps->VpiName(typeName); tps->Class_defn(cl->getUhdmDefinition());
          fC->populateCoreMembers(type, type, tps); result = tps; }   // NO parameters
```

and only when all three MISS does it fall through to
`compileDatastructureTypespec` (`CompileType.cpp:902-1000`), **the only writer
in Surelog of a `class_typespec`'s `Parameters` / `Param_assigns`**.

`Design::addClassDefinition` is keyed by the QUALIFIED name
(`ResolveSymbols.cpp:100-195`): a **package** class is registered
`<pkg>::<name>` while the ClassDefinition's own `getName()` is the SHORT name;
a `$unit` class is `work@<name>`; a module/program class is
`work@<mod>::<name>`. A class property is compiled with the **ClassDefinition**
as the component (`CompileClass.cpp:294` passes `m_class`), and a
ClassDefinition's parent scope is its **CONTAINER** — the enclosing package /
module / program, and for a NESTED class its **outer class's** container, not
the outer class (`ClassDefinition::ClassDefinition`'s
`DesignComponent(container ? container : fC, nullptr)`, with
`CompileClass.cpp:693` passing `m_class->getContainer()`).

So probe 2 can never spell a package class's key, and probe 3 spells
`<home package>::<G>` and hits exactly when the declaring class's home package
IS `G`'s home package.

> ### § classPropSpecForeignPkgHome163
>
> A **class property** whose type is written as an **unqualified** `G #(...)`
> carries the specialization listing unless one of Surelog's three probes can
> spell `G`'s registry key — i.e. unless **`G`'s home package is the declaring
> class's home package**, walking THROUGH enclosing classes, or `G` is one of
> the three built-ins Surelog registers under a bare name.
>
> The listing is Surelog's ordered-argument loop: one `type_parameter` + one
> `param_assign` per **written ordered argument**, paired with
> `getOrderedParameters()[i]` where `i` counts **all** formals and the loop
> stops at `index < formal.size()`; a **value** formal's argument pushes
> nothing; a **named**-argument spelling produces none at all.

### 2.1 WHY r10uvm53 GOT THE OTHER HALF

`§ classPkgGenericSpecListing53` (`r10uvm53repro/README.md` §3b) read the same
three probes and keyed on "the generic lives in a PACKAGE", suppressing the
listing for **every** package generic. Its decisive cell, `a3/dut.sv`'s
`e2_unitclass_pkggeneric`, is spelled

```systemverilog
class e2_holder;
  r53::rgc53#(r53::rcfg53) e2_unitclass_pkggeneric;   // a SCOPED name
endclass
```

— a `ScopedName`, which takes Surelog's `paPackage_scope` arm
(`CompileType.cpp:1522-1545`) and **never reaches the probe site at all**; in
golden that cell is not even a `class_var` (it is a `logic_var` — arm A cells
`a3`/`a5` reproduce it). Every other package-generic cell in r10uvm53's three
arms (`a1/c1..c5`, `a2/d2,d3`, `a3/e3`) declares the property in the SAME
package as the generic, where probe 3 genuinely hits. **The unqualified
foreign-home spelling — the corpus cell — was never measured**, and golden
gives it the listing.

Only the **PARAMETER** half of § 53 is narrowed. Its **SPAN** half
(`listingSite53`, the generic class's NAME-TOKEN span) is left exactly as it
was, and that is correct: golden gives a class property the name-token span
whether or not it also gives the listing — measured on both sides of every
arm-B cell (`b1_prop` is `44:5-44:13` in golden, in the pristine build and in
the patched one).

### 2.2 THE BUILT-IN FENCE, found by scoring rather than by reasoning

`Builtin::addBuiltinClasses`
(`~/git-repos/Surelog/src/DesignCompile/Builtin.cpp:385-392`) builds `mailbox` /
`process` / `semaphore` as `work@mailbox` but calls
`design->addClassDefinition(name, def)` with the **SHORT** name, so the FIRST
probe — the bare `typeName` one — hits them **from anywhere** and golden never
builds their listing. slang puts them in a synthesized `std` **package**, so
without a fence they read as a package generic in a foreign home.

The first cut of this pass shipped without it. All five UVM row-modes' heads
then collapsed onto ONE `LHS: <null>` **AWAY** object — our own listing on
`mailbox #(T) m;` at uvm-1.2 `uvm_tlm_fifo.svh:50:9`, inside
`uvm_pkg::uvm_tlm_fifo` — and SeqDriver's head went **29 → 55** cmp lines while
MiniAmiq's went **106 → 55**. This is the same fence r10uvm156 had to add to
`§ classHandleRetTsNameUnlessSameHomeComponent156`, for the same registry
reason. `isBuiltinStdClass` is the gate; arm B cells `b11_builtin_mailbox` /
`b12_builtin_semaphore` hold OUR side of it, and the corpus is golden's witness
(102 built-in candidate cells across six databases, **none of which moved**).

---

## 3. THE GRIDS — three arms, DEF and ELAB, every cell named

`arm163.sh` builds each arm with Surelog (both views) and with the two frozen
binaries (both views); `armcen163.sh` + `ct163cen` + `cells163.py` score every
cell three ways. **Both views agree everywhere.** Full tables in
`GRID.r10uvm163.txt`.

### arm A — `g163_a_mech.sv`, THE MECHANISM (spelling × home relation)

| cell | declaring class's home | generic's home | spelling | golden | pristine | patched |
|---|---|---|---|---|---|---|
| `a1_samepkg_unqual` | package `alpha163` | `alpha163` | unqualified | **no listing** | none | none — **HELD** |
| `a11_pkgnested_samepkg` | a class NESTED in an `alpha163` class | `alpha163` | unqualified | **no listing** | none | none — **HELD** |
| `a2_crosspkg_unqual` | package `beta163` | `alpha163` | unqualified | `TA:cfgBe163` | none | **TO-GOLDEN** |
| `a12_pkgnested_crosspkg` | a class nested in a `beta163` class | `alpha163` | unqualified | `TA:cfgBe163` | none | **TO-GOLDEN** |
| `a4_unitcls_pkggen_unqual` | `$unit` | `alpha163` | unqualified | `TA:cfgUnit163` | none | **TO-GOLDEN** — the Scoreboard shape |
| `a13_unitnested_pkggen` | a class nested in a `$unit` class | `alpha163` | unqualified | `TA:cfgUnit163` | none | **TO-GOLDEN** |
| `a7_unitcls_selfarg` | `$unit` | `alpha163` | `#(int, <own class>)` | `TA:int, TB:holdSelf163` | none | **TO-GOLDEN** — the Scoreboard TEXT |
| `a8_modcls_pkggen_unqual` | a class in module `top163` | `alpha163` | unqualified | `TA:cfgUnit163` | none | **TO-GOLDEN** |
| `a3_crosspkg_scoped`, `a5_unitcls_pkggen_scoped` | — | — | **SCOPED** | golden's object is a **`logic_var`**, not a class_var | ours unchanged | ours unchanged — a pre-existing owner-KIND residue (R3) |
| `a6`, `a9`, `a10` (`$unit` generic) | — | `$unit` | unqualified | 1 entry | **2** entries | 2 — **STILL**, untouched (R1) |

`a11` is the cell that decides the walk: a class nested in a package class is
SUPPRESSED in golden exactly like the un-nested one, which is Surelog's
container rule, not a lexical-parent rule.

### arm B — `g163_b_forms.sv`, THE DECLARATION FORMS

`k1_samehome_prop`, `k2_samehome_static`, `k3_samehome_local` (all same-home)
**HELD** with no listing; `b1_prop`, `b2_static`, `b3_local`, `b4_protected`,
`b5_rand` (all foreign-home) **TO-GOLDEN**. Deliberately left alone, each with
golden's own answer measured:

* `b10_pkgvar` — a **PACKAGE VARIABLE** of a foreign generic: golden gives it
  **NO listing** even though the probes miss, exactly like the same-home
  `k5_samehome_pkgvar`. That site is compiled with the PACKAGE as the
  component and behaves like the module-variable site § 53 already fenced. The
  law is gated on "the declaration's immediate parent scope is a ClassType",
  and both cells are unchanged (`nparam=-1` in the pristine and the patched
  database, byte for byte).
* `k6_modvar` / `k7_modvar_new` — § 53's `!declInInstance53`.
* `b6_fixed[3]`, `b7_queue[$]`, `b8_dyn[]` — golden holds an unnamed inner
  `class_var` under an `array_var` and puts the listing there; we have no such
  object on either side, before or after (a pre-existing PARENTING residue,
  R4).
* `b9_methodlocal` / `k4_samehome_methodlocal` — golden emits **no
  declaration-site class_typespec for a class-method local at all**, in either
  view, so there is nothing measured to move (R2).
* `b11_builtin_mailbox` / `b12_builtin_semaphore` — the built-in fence.

### arm C — `g163_c_types.sv`, THE LISTING'S CONTENT

Every cell is a `$unit` class property of an `epsilon163` generic, so the law
fires on all ten; golden's answer is Surelog's loop, clause by clause:

| cell | written | golden | patched |
|---|---|---|---|
| `c1_two_class_args` `#(cfgUn163, cfgUn163)` | 2 class args | `TA:class_typespec:cfgUn163, TB:class_typespec:cfgUn163` | identical |
| `c2_two_int_args` `#(int, int)` | 2 data-type args | `TA:int_typespec, TB:int_typespec` | identical |
| `c3_mixed_args` `#(int, cfgUn163)` | the Scoreboard spelling | `TA:int_typespec, TB:class_typespec:cfgUn163` | identical |
| `c4_one_arg_of_two` `#(int)` on a 2-formal class | 1 arg | **ONE** entry | identical |
| `c5_single_formal` `oneEp163#(int)` | 1 of 1 | `TA:int_typespec` | identical |
| `c6_typedef_arg` `#(nib163_t, cfgUn163)` | a typedef'd arg | `TA:logic_typespec:nib163_t, TB:class_typespec:cfgUn163` | identical |
| `c7_named_arg` `#(.TA(cfgUn163))` | NAMED | **no listing** | **HELD** |
| `c8_bare_default` | bare name | **no listing** | **HELD** (§ classTsDefaultSpecNoParams) |
| `c9_nonparam` | not parameterized | **no listing** | **HELD** |
| `c10_value_then_type` `valEp163#(4, cfgUn163)` on `#(int NN, type TA)` | value then type | **ONE** entry, bound to `TA` | identical |

`c4` and `c10` are why the site cannot reuse `emitClassTsParams`, which lists
every formal of the SPECIALIZATION and would give `c4` two entries and `c10`
the wrong pairing.

---

## 4. WHAT SHIPPED

* `src/TypeEmit.cpp` — the predicate at the class-handle mint
  (`grep -n foreignPkgHome163`): `propSite163` (a class property, not a
  built-in), the home-package walk THROUGH enclosing classes, and
  `suppressParams163`, which narrows **only** § 53's parameter half.
* `src/UhdmExporter.cpp` + `include/UhdmExporter.h` —
  `UhdmExporter::emitClassPropSpecParams163`, Surelog's ordered-argument loop:
  written ordered arguments only, index over ALL formals, the `paData_type` arm
  (the formal's own span on the `type_parameter` and the `param_assign`, the
  argument's own span on the actual) and the EXPRESSION arm (no spans, the
  actual at the whole `#(...)` text) — both faces visible in the head itself.

No new exporter state, no change to `emitClassTsParams` or to
`emitClassTdSpecParams1`.

---

## 5. THE MOVER SET, PREDICTED BY NAME BEFORE THE PATCHED SWEEP

`predsweep163.sh` runs `ct163cen` over **every** `slang.uhdm` of both PRISTINE
sweeps (956 + 1358) and `pred163.py` names the candidates from those databases
alone (`PREDICT.r10uvm163.txt`):

```
surelog:     103 candidate cells in 11 databases
             — 1 of them is the law's cell:
               default/Scoreboard-59431470  uvm_analysis_imp@9:3|m_imp@9:42
             — 102 are the BUILT-IN fence's population (mailbox / semaphore /
               process class properties: 10 per UVM row-mode, 6 in SVSwitch)
uhdm2rtlil:  0 candidate cells, so 0 movers
```

`byteverify.sh SELFCHECK=1` then found **MOVERS 1 / 956** — that database — and
**0 / 1358** on uhdm2rtlil. SVSwitch's protected database md5 stayed
`4842211c4030`, which is the built-in fence's corpus proof.

The prediction is deliberately a SUPERSET: a database cannot tell a bare `G x;`
from a suppressed `G#(T) x;` (§ 53 narrows BOTH to the name-token span and
gives BOTH an absent listing), so a candidate is a cell that MAY move; a
database with NO candidate CANNOT.

### Attribution, order-blind, whole dump

`dumpdiff163.sh` path-normalises and SORTS both dumps, so the row's documented
~92-line svunit_pkg ORDER flip reads 0 lines. The one mover's entire diff is
**52 lines, every one an ADDITION, and every one this law's**:

```
+ class_typespec (uvm_analysis_imp) @9:3-9:19        (4 parent lines)
+ type_parameter  …::uvm_analysis_imp::T   @110:31-110:32   + its ref_typespec
+ type_parameter  …::uvm_analysis_imp::IMP (no span)        + its ref_typespec
+ int_typespec    @9:22-9:25          (T's actual)
+ class_typespec (my_scoreboard) @9:20-9:41   (IMP's actual)
+ param_assign @110:31-110:32  Lhs = uvm_pkg::uvm_analysis_imp::T
+ param_assign (no span)       Lhs = uvm_pkg::uvm_analysis_imp::IMP
-- distinct KINDS on the diff: class_defn, class_typespec
```

character for character the head's LHS.

---

## 5b. THE CORPUS CENSUS

`ct163cen` + `score163.py` census **every** declaration-site `class_typespec`
(VpiParent is a variable) in the nine UVM row-modes, golden against ours, with
a MULTISET join — golden repeats a key up to four times where a package
variable's typespec is cloned per elaborated copy, and a dict-keyed census
would drop those rows and then manufacture ONLY-G phantoms (RESUME.md §9).
`CENSUS.r10uvm163.txt`:

| | pristine | patched |
|---|---|---|
| RIGHT | 2 478 | 2 479 |
| **WRONG** | **1** | **0** |
| RESHAPE | 0 | 0 |
| **AWAY** | **0** | **0** |
| ONLY-G / ONLY-O | 1 845 / 94 | 1 845 / 94 |

and **no ONLY-G row in any row-mode carries a listing**, so the census pairs
every listing golden has — the population really is one cell.

---

## 5c. THE WIDE BOUNDARY

`bound163.sh` compiles **every** committed probe arm — 4643 `.sv`/`.v` files,
subdirectories included — with both frozen binaries in both views:
`LISTED=4643 PROCESSED=4643 PRODUCED_DBS=4487 MOVED_ARMS=7 RC_DIFFS=0`.
The three `g163_*.sv` are the positive control. Of the other four
(`BOUNDARY.r10uvm163.txt`), **every one was re-measured against golden** with
Surelog rebuilt in both views: **MOVED-WRONG 0 and AWAY 0 in every arm-view**,
plus 1 WRONG→RIGHT in `r10uvm156repro/g156_b_forms.sv` and 1 in
`r10uvm23repro/t34g/t.sv`.

The two arms that scored TO-GOLDEN=0 are r10uvm154's **documented TAILONLY
layout artifact** (`r10uvm154repro/README.md` §7): `r10buvm22repro/g22.sv` and
`r10uvm154repro/l154_noenum.sv` differ between the two binaries ONLY in one
tail constant (`UINT` / `vpiDecompile` `22539993 → 22544089` and
`22539137 → 22543233`, both exactly **4096** apart), a binary-layout-derived
number that ANY code motion moves — `l154_noenum.sv` contains no construct this
law can reach. Both binaries are **EQUIDISTANT from golden** on them and hit
the **same head object**: 17506 / 17506 and 26436 / 26436 cmp lines for
`g22.sv`, 1632 / 1632 and 1636 / 1636 for `l154_noenum.sv`, with an id- and
value-normalised cmp diff of **0 lines** in every view.

---

## 6. GATES

All green; the full record with the two binary md5s, the status histograms and
the `cmds.txt` binary audit is `GATES.r10uvm163.txt`. Summary: goldens
**23 PASS / 0 FAIL** on both binaries with `SLANG_UHDM` exported to each and
**23 FAIL** on the `/bin/false` negative control; **0 differing rows** on both
corpora in both modes against the committed baselines *and* against this base's
own pristine control CSVs, status column **and** dump column; u2r
**679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in both modes; byte movers
**1 / 956** and **0 / 1358**, the one predicted by name; canaries `ok=52` /
`ok=8`, `changed=0`; `ctcan2` PASS on both corpora; `canaudit audited=29
UNCOVERED=0 FENCE-BREACH=0`; the five protected databases all unchanged, with
SVSwitch pinned at `4842211c4030` and YosysVerx at `6ccda350c24a`. **The four
slang-fenced tests were never dispatched and are not spelled in any driver
here.**

Every `cmds.txt` in all four sweep workdirs was audited by ABSOLUTE PATH and
names exactly one binary: `/tmp/…/pris.bin` for the pristine pair,
`/tmp/…/patc.bin` for the patched pair.

---

## 7. RESIDUES AND R0

* **R0 (the next head).** Scoreboard/`default`, **95** cmp lines, ONE `^LHS:`,
  on a NEW object, and the MIRROR shape — `LHS: <null>` with **our**
  `class_typespec (type_id)` at `uvm_object_defines.svh:483:12-483:34` printed
  as RHS, parented by `class_defn (work@my_scoreboard)`; it carries a
  `vpiTypedefAlias -> ref_typespec -> class_typespec (type_id)` and a
  `vpiParameter type_parameter T`. It is the `` `uvm_component_utils ``
  expansion's `typedef uvm_component_registry#(T,S) type_id;`. `ct163own`'s
  mirror walk shows **every vector on that parent is equal-size on both sides**
  (Variables 69/69, Parameters 90/90, Param_assigns 90/90, Typespecs 124/124,
  Task_funcs 899/899, Class_typespecs null/null), so the null is a SINGULAR
  edge reached INSIDE one of them — and `typespec::Compare` walks
  `Typedef_alias` FIRST (RESUME.md §9), which is where the next pass should
  look, in § `classTdSpecParamsForeignHome1` / § `pkgImportClassTdClone50`
  territory. **The object is unchanged by this pass**: 26 occurrences in the
  pristine database and 26 in the patched one, and it does not appear anywhere
  on the order-blind dump diff — a PRE-EXISTING deficit this pass unmasked.
  See `head_pat_Scoreboard.default.cmp`.
* **R1 — `emitClassTsParams` lists ALL formals where golden lists only the
  WRITTEN ordered arguments.** Arm A cells `a6`, `a9`, `a10`
  (`genUnit163#(cfgUnit163)` on a two-formal class) read 1 entry in golden and
  2 in ours, before and after. That is the OTHER branch of the mint — the one
  § 53 never suppressed, for `$unit` generics — and it is **left untouched
  deliberately**: the corpus census reads RESHAPE 0 in all nine row-modes, so
  it has zero corpus reach today, and changing the shared builder would move
  cells no arm here measures.
* **R2 — a class-METHOD LOCAL is unmeasured.** Surelog compiles one with the
  ClassDefinition as the component, so its probes behave exactly as a
  property's and a foreign-home local should carry the listing; but golden
  emits **no declaration-site class_typespec for a method local at all** in
  either view of arm B, so there is no witness. The law is gated on "the
  declaration's immediate parent scope is a ClassType" and leaves method locals
  with § 53's suppression — the safe direction, disclosed rather than guessed.
* **R3 — a SCOPED `pk::G#(..)` property is a `logic_var` in golden and a
  `class_var` in ours** (arm A `a3`, `a5`). An owner-KIND residue: the judge
  fails on `UhdmType` before it reads a listing, so those cells are neither
  TO-GOLDEN nor AWAY here. It is also the reason r10uvm53's decisive cell could
  not decide anything.
* **R4 — an ARRAY / QUEUE / DYNAMIC-array property of a specialization.**
  Golden holds an unnamed inner `class_var` under the `array_var` and puts the
  listing on ITS typespec (arm B `b6`/`b7`/`b8`, golden `nparam=1`); we put the
  element typespec on an `array_typespec` and have no such `class_var`. A
  PARENTING residue, unchanged by this pass.
* **R5 — § `classTdSpecParamsForeignHome1`'s home test has the same
  nested-class gap this pass closed for properties.** Its predicate (r10sd1,
  `src/UhdmExporter.cpp`) tests the declaring class's IMMEDIATE parent scope
  for Package-or-ClassType, where Surelog's probe 3 actually spells the
  CONTAINER (the enclosing package, skipping enclosing classes). Arm A's
  `a11_pkgnested_samepkg` shows golden's answer for the property site; the
  typedef site is the same `compileTypespec` arm, so the configuration "a
  typedef in a class nested in a package class, of that package's generic" is
  very likely mis-predicted there. It was **not touched**: it is a different
  site with its own gated grid, and this pass has no corpus witness for it.

---

## 8. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `g163_a_mech.sv` | arm A — the MECHANISM: spelling × home relation, 13 named cells including the three NESTED-class ones |
| `g163_b_forms.sv` | arm B — the DECLARATION FORMS, with same-home controls and the built-in fence cells |
| `g163_c_types.sv` | arm C — the LISTING's CONTENT: ten spellings against Surelog's ordered-argument loop |
| `arm163.sh` | builds one arm with Surelog and both frozen binaries, in BOTH views; every rc printed, every child `</dev/null` |
| `ct163cen.cpp` | the CENSUS reader: every declaration-site `class_typespec` and its listing; `--all` for the prediction's reach; `--selftest` |
| `score163.py` | the golden-vs-ours MULTISET join and its classes; `--selftest` |
| `cells163.py` | the three-way arm table (golden / pristine / patched) and its scores; `--selftest` |
| `armcen163.sh` | writes an arm's six listings and scores them |
| `cen163.sh` | censuses named row-modes of a verify_golden workdir, both sides |
| `predsweep163.sh` | censuses EVERY database of a sweep workdir |
| `pred163.py` | names the movers a priori from the PRISTINE databases; `--selftest` |
| `ct163own.cpp` | the OWNER-FINDER: which edge the judge printed, in both directions (§1a and R0) |
| `coin163.sh` | the COIN check — N runs of Scoreboard/default per binary |
| `dumpdiff163.sh` | ORDER-BLIND whole-dump attribution of one byte mover |
| `bound163.sh` | the WIDE BOUNDARY over every committed probe arm |
| `remeasure163.sh` | rebuilds golden for a moved arm and scores every cell |
| `gates163.sh` | the gate runner behind `GATES.r10uvm163.txt` |
| `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `rowheads.sh` | the campaign's standard gates, copied verbatim |
| `GRID` `CENSUS` `PREDICT` `GATES` `BOUNDARY` `.r10uvm163.txt` | the measurements |
| `head_pris_*.cmp` `head_pat_*.cmp` | the head logs for the seven named rows, before and after |
