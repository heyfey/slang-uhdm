# r10uvm156 — § `classHandleRetTsNameUnlessSameHomeComponent156`

*A function's **class-handle RETURN** typespec carries the type name **as
written** at the return-type token — unless Surelog's
`design->getClassDefinition` fallback resolves the class first, which it does
exactly when the returned class's **home design component** is the declaring
scope's, and then the object is minted fresh and stays **anonymous**.*

Base commit **edf82ef**. LHS is **always** golden (Surelog); RHS is always
ours. The judge is `~/git-repos/UHDM/build/bin/uhdm-cmp` and nothing else;
every instrument in this directory is measurement-only and links the same
generated `Compare`. slang was NOT patched; `results/*.csv` were READ ONLY.

---

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SeqDriver default / testflags** | **22** cmp lines, 1 head | **17**, 1 head — a **DIFFERENT** object (R0 below) |
| SimpleUVM default / testflags | 163, 1 head | 163 — head log **BYTE-IDENTICAL** |
| Scoreboard default | 163, 1 head | 163 — **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 106, 1 head | 106 — **BYTE-IDENTICAL** |
| BuildUVMPkg default / testflags | 56, 1 head | 56 — **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 31 / 36, 1 head | 31 / 36 — **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this base's own pristine control CSVs (1588 surelog row-modes + 1358 u2r × 2 modes) |
| byte movers | — | **5 / 956** surelog — **exactly the five predicted BY NAME from pristine data**; **0 / 1358** uhdm2rtlil |
| the law's corpus population | **57** wrong cells in 5 databases (9 row-modes measured) | **0** — WRONG→RIGHT 57, **RIGHT→WRONG 0**, **AWAY 0** |
| the predicate scored on GOLDEN itself | — | **5305 / 5305**, MISS **0** |
| the grid, four arms × two views | — | **RIGHT→WRONG 0, AWAY 0** in every arm-view; **62 WRONG→RIGHT** |
| wide boundary | — | 4403 arm files × 2 views, 29 moved, **every one re-measured against golden: RIGHT→WRONG 0, AWAY 0** (`BOUNDARY.r10uvm156.txt`) |

No row was converted.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reads SeqDriver **22 cmp
lines, one `^LHS:`, both modes** (`head_pris_SeqDriver.*.cmp`, the two logs
identical but for object ids):

```
LHS:  class_typespec: (uvm_object_wrapper), line:444:21, endln:444:39
      |vpiName:uvm_object_wrapper
      |vpiClassDefn: \_class_defn: (uvm_pkg::uvm_object_wrapper)
RHS:  class_typespec: , line:444:21, endln:444:39
      |vpiClassDefn: \_class_defn: (uvm_pkg::uvm_object_wrapper)
```

`typespec::Compare` (`~/git-repos/UHDM/build/generated/src/typespec.cpp`)
reads `VpiName` **first**, before `Typedef_alias` and before `Instance`, so
the whole head is that one missing string. Both sides carry the same
`vpiClassDefn` edge and the same span.

### The owner, found with a direct reader over both databases

`444:21-444:39` is `uvm_object_defines.svh:444`, inside the
`` `m_uvm_object_registry_internal `` macro:

```systemverilog
`define m_uvm_object_registry_internal(T,S) \
   typedef uvm_object_registry#(T,`"S`") type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \   <- line 444, cols 21..38
     return type_id::get(); \
   endfunction
```

`ct156cen` enumerates every `class_typespec` in a database, finds its holder
by a REVERSE scan (every object `X` and relation `T` with
`X.GetByVpiType(T)` yielding it) and resolves a `ref_typespec` holder one
step further to the ref's own `VpiParent` — the object that actually declares
the type. On golden it prints, for that one span:

```
name=uvm_object_wrapper  hold=class_var  chain=function(get_object_type)<class_defn(adpcm_seq_item)<package(adpcm_pkg)<design
name=uvm_object_wrapper  hold=class_var  chain=function(get_object_type)<class_defn(adpcm_tx_seq)<package(adpcm_pkg)<design
name=-                   hold=class_var  chain=function(get_object_type)<class_defn(uvm_cause_effect_link)<package(uvm_pkg)<design
name=-                   hold=class_var  chain=function(get_object_type)<class_defn(uvm_mem_access_seq)<package(uvm_pkg)<design
…  (and so on for every uvm_pkg class)
```

So the owner is the **function's `Return` variable's typespec**, and golden
itself splits the population at the same span: **named in the test's own
package, anonymous inside `uvm_pkg`.** That is the whole law, and it was
visible before a line of code was written.

---

## 2. THE DECODED MODEL (Surelog, read line by line, then measured)

`CompileHelper::compileFunction` builds a function's return variable at
`src/DesignCompile/CompileStmt.cpp:2400-2408`:

```cpp
var = any_cast<variables*>(compileVariable(component, fC, Return_data_type,
                                           compileDesign, Reduce::No, …));
```

`CompileHelper::compileVariable` (`src/DesignCompile/CompileType.cpp:250`)
first computes

```cpp
ts = compileTypespec(component, fC, declarationId, compileDesign, …);   // :317-329
```

whose own `slStringConst` class arm mints a `class_typespec` **and writes the
name** (`:1913-1917`, `tps->VpiName(typeName)`). Then, in the
`slStringConst` case of its own switch, **three arms compete**:

| arm | site | what wins |
|---|---|---|
| **A** | `:337-357` `component->getDataType(typeName)` → `getSimpleVarFromTypespec` | keeps `ts` — the **NAMED** object. This is the TYPEDEF face. |
| **B** | `:361-386` `design->getClassDefinition(typeName)`, then `<component>::<typeName>`, then `<component's parent scope>::<typeName>` | on a HIT mints a **FRESH `class_typespec` with `Class_defn` and NO `VpiName`** and throws `ts` away. **This is the anonymous object.** |
| **C** | `:387-399` otherwise, when `ts` is a class_typespec | wraps `ts` — the **NAMED** object. |

So the only question is *does arm B's three-form lookup hit*.
`Design::addClassDefinition` (`src/Design/Design.cpp:519`) keys the registry by
the class's QUALIFIED name, and Surelog's own compile log spells those keys —
from `g156_a_mech.sv`'s `sl.log`:

```
Compile class "ph156::sib156"              <- a PACKAGE class:   <pkg>::<name>
Compile class "work@mod156::modCls156"     <- a MODULE class:    work@<mod>::<name>
Compile class "work@prg156::prgCls156"     <- a PROGRAM class:   work@<prog>::<name>
Compile class "work@ifCls156"              <- an INTERFACE class: NO qualifier
Compile class "work@unitCls156"            <- a $unit class:      NO qualifier
```

The three lookup forms can therefore only hit when the returned class and the
declaring scope share a **package, module or program**; an interface class and
a `$unit` class are unreachable through them.

> ### § classHandleRetTsNameUnlessSameHomeComponent156
>
> A function's **class-handle RETURN** typespec carries the type name **as
> written** at the return-type token, except when the returned class's **home
> design component** — the first enclosing **package, module or program**,
> walking THROUGH class / subroutine / block scopes, with an **interface** and
> **$unit** counting as *no home* — is the declaring scope's, in which case the
> object is minted fresh and stays **anonymous**.

### 2.1 Golden says it, in ten homes, both views

`g156_a_mech.sv` puts the same question to every home; the full table is in
`GRID.r10uvm156.txt`. The three rows that pin the law down:

| site | returned class | golden |
|---|---|---|
| `pkgHome156::r_sib` — package class method | a class of the **SAME package** | **anonymous** |
| `pkgHome156::r_far` — the same method | a class of a **far package** | **`wrapA156`** |
| `ifHome156::r_if` — **interface** class method | a class of the **SAME interface** | **`ifCls156`** — named |

and the same answer holds at an `extern` **prototype**, at the **out-of-body
body**, at a **package / module / program / interface FREE function**, and for
a method returning **its own class**.

### 2.2 vpiInstance rides with the name, and it already did

Golden's NAMED return typespec in a **package free function** or an
**out-of-body body** carries `vpiInstance` = the home package (`g156_a_mech`
lines 42 / 45 / 50 / 51); the same return inside a **class method** carries
none (lines 20 / 32 / 36 / 61 / 80 / 93). That is `tsInst` — the exporter's
existing "the instance every typespec minted for THIS subroutine takes"
(`TaskFuncEmit.cpp`, `pkgScope && !classScope ? m : (oob ? oobHomePkg :
nullptr)`) — read verbatim. The pre-existing guard
`if (class_typespec && VpiName().empty()) useInst9 = nullptr;` therefore does
the right thing on its own once the name is written: **no new instance
predicate was added, and none was needed.** All 57 corpus cells are class
methods and golden gives all 57 `inst=-`; ours does too.

### 2.3 What is NOT this law — three fences, every one MEASURED

* **A CONSTRUCTOR.** Its return typespec is built at the
  `classScope && sub.name == "new"` site and never reaches this mint. The
  predicate asserts the fence anyway so a future re-order cannot widen the
  law silently. 2875 golden cells are fenced here; our implicit-`new` return
  objects remain a separate wrong population (**R1**).
* **A class Surelog registers under its BARE name.**
  `Builtin::addBuiltinClasses`
  (`~/git-repos/Surelog/src/DesignCompile/Builtin.cpp:385-392`) builds the
  ClassDefinition as `work@process` but calls
  `design->addClassDefinition(name, def)` with the **short** name, so arm B's
  FIRST form hits for `mailbox` / `process` / `semaphore` **from anywhere**.
  Golden leaves builtin.sv's own `static function process self();`
  **anonymous** although its home differs from nothing.
  **NECESSARY, and found by scoring rather than by reasoning:** the first cut
  of this pass fenced only slang's synthesized `std` package
  (`isBuiltinStdClass`) and the arm caught `process` being NAMED at
  `builtin.sv:34:21`, which is 9 corpus cells (one per UVM row-mode) golden
  leaves bare. Both faces are now tested.
* **A return written through a TYPEDEF** (`static function type_id
  get_type();`). That is arm A: a different object with a
  context-dependent spelling (golden reads `adpcm_pkg::type_id` on one class
  and plain `type_id` on the next in the SAME database — the naming DEAD END,
  RESUME.md §9). It does not reach this mint; the fence only records the
  boundary. 748 golden cells.

---

## 3. THE PREDICATE SCORED ON GOLDEN ITSELF, BEFORE ANY CODE

`pred156.py` runs the predicate over golden's own class-handle return
typespecs in all nine UVM row-mode databases and asks whether it reproduces
golden's own naming:

```
in-scope cells                     5305
predicate agrees with golden       5305        MISS 0
fenced: constructors 2875, builtin.sv 9, alias-named 748
```

The **9 MISSes of the first cut were all `process::self()`** — which is how
the builtin.sv fence was found.

---

## 4. WHAT SHIPPED

`src/TaskFuncEmit.cpp` and the law in `include/UhdmExporter.h`. No new
exporter state, no new instance predicate, one new member function and two
file-local helpers:

* `homeComp156(const Scope*)` — the home design component, walking THROUGH
  class / subroutine / block scopes, returning `nullptr` for an **interface**
  body and for `$unit`;
* `writtenTypeName156(const SyntaxNode*)` — the type name AS WRITTEN
  (`IdentifierName` / `ClassName`, and `"<left>::<right>"` for a
  `ScopedName`). **An unmeasured spelling returns empty**, i.e. leaves the
  object anonymous, which is the pristine behaviour;
* `UhdmExporter::classHandleRetTsName156` — the three fences and the
  home test, then the written name.

At the mint (`TaskFuncEmit.cpp`, the class-handle return arm):

```cpp
if (auto rn156 = classHandleRetTsName156(sub, rct9); !rn156.empty())
    cts9->VpiName(rn156);
```

Three superseded comments were corrected **in place** rather than carried
forward (the campaign rule): the mint's own "an ANONYMOUS class_typespec",
§ 87's "the anonymity of a class-handle return is otherwise the law (SeqDriver
golden: 1986 uninstanced anonymous objects)" — the true SeqDriver figure is
**855 anonymous return typespecs against 106 named ones** — and the
`useInst9` note, which now records that golden's newly named returns take
their instance by exactly the line that was already there.

---

## 5. THE MOVER SET, PREDICTED BY NAME BEFORE THE PATCHED SWEEP

`movers156.py` over the PRISTINE databases of both corpora named **five
databases and no others**:

```
  default/SeqDriver-32af76aa      testflags/SeqDriver-32af76aa
  default/MiniAmiq-544c7f61       testflags/MiniAmiq-544c7f61
  default/Scoreboard-59431470
  uhdm2rtlil: none, in either mode
```

`byteverify.sh SELFCHECK=1` then found **MOVERS 5 / 956** — those five —
and **0 / 1358** on uhdm2rtlil. `PREDICT.r10uvm156.txt` records why the
predictor's per-database CELL counts are a superset (it reads the UHDM parent
chain; production reads the slang symbol's scope, which keeps our
import-clone copies of a `uvm_pkg` out-of-body method anonymous).

### Attribution, order-blind, whole dump

`dumpdiff156.sh` path-normalises and SORTS both dumps, so a pure ORDER flip
reads 0 lines. Every mover's entire diff is class_typespec identity lines and
`|vpiName:` lines, and **nothing else**:

```
default/SeqDriver-32af76aa     35 lines   kinds: class_typespec, |vpiName
testflags/SeqDriver-32af76aa   35 lines   kinds: class_typespec, |vpiName
default/MiniAmiq-544c7f61     105 lines   kinds: class_typespec, |vpiName
testflags/MiniAmiq-544c7f61   105 lines   kinds: class_typespec, |vpiName
default/Scoreboard-59431470     5 lines   kinds: class_typespec, |vpiName
```

The cells are `uvm_object_wrapper` at `uvm_object_defines.svh:444:21` /
`472:21` / `487:21` and `uvm_object` at `410:13` — the
`` `uvm_object_utils `` / `` `uvm_component_utils `` expansions inside the
TEST's own package (`adpcm_pkg`, `svaunit_pkg`, `work@my_scoreboard`) — plus
MiniAmiq's two interface-scope `svaunit_concurrent_assertion_info` returns.

---

## 5b. THE WIDE BOUNDARY

`bound156.sh` compiles **every** committed probe arm — 4403 `.sv`/`.v` files,
subdirectories included — with both frozen binaries in both views:
`LISTED=4403 PROCESSED=4403 PRODUCED_DBS=4256 MOVED_ARMS=29 RC_DIFFS=0`.
The four `g156_*.sv` are the positive control, and 25 earlier-pass arms moved.

**Every one of the 25 was re-measured against golden** (`remeasure156.sh`
rebuilds golden with Surelog in both views and scores each cell):
**RIGHT→WRONG 0 and AWAY 0 in every moved arm-view**, 62+ WRONG→RIGHT.

Five cells scored "ONLY-OURS moved" — a key that did not pair with golden — so
each was checked against golden's own dump rather than waved through. All five
pair on a **pre-existing span or parent residue**, and the name this pass
wrote is golden's character for character:

| arm | golden | ours, after |
|---|---|---|
| `r10uvm56repro/v3_hierpath.sv` 56:13 / 64:13 | `class_typespec (p3v::h3)` @56:13-56:**18** | `p3v::h3` @56:13-56:**20** |
| `r10v150repro/v150_a.sv` 16:10 | `(Cell_A)` | `Cell_A` |
| `r10v150repro/v150_f1.sv` 9:22 | `(fp1::LL)` @9:22-9:**27** | `fp1::LL` @9:22-9:**29** |
| `r10vbuvm32repro/vb32h1.sv` 16:10 | `(chain32)` | `chain32` |

Two of them are the **scoped** spelling on arms this pass did not author —
independent confirmation that golden writes the WRITTEN qualified name at the
return-type token and that `writtenTypeName156` reproduces it.

---

## 6. GATES

All green; the full record with the two binary md5s, the status histograms and
the `cmds.txt` binary audit is `GATES.r10uvm156.txt`. Summary: goldens
**23 PASS / 0 FAIL** on both binaries with `SLANG_UHDM` exported to each and
**23 FAIL** on the `/bin/false` negative control; **0 differing rows** on both
corpora in both modes against the committed baselines *and* against this
base's own pristine control CSVs, status column **and** dump column;
byte movers **5 / 956** and **0 / 1358**, every one predicted by name;
canaries `ok=52` / `ok=8`, `changed=0`; `ctcan2` PASS on both corpora;
`canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`. **The four slang-fenced
tests were never dispatched and are not spelled in any driver here.**

---

## 7. RESIDUES AND R0

* **R0 (the next head).** SeqDriver ×2, **17** cmp lines, ONE `^LHS:`, on a
  NEW object — a `ref_typespec (adpcm_pkg::adpcm_tx_seq)` whose `vpiParent` is
  a `constant` at `162:24-162:34` and whose `vpiActual` is an
  `int_typespec` at `217:1-217:38`, with **`RHS: <null>`**: the SINGULAR
  `SafeCompare` shape (RESUME.md §9's buvm13/15 framing), i.e. an edge to a
  typespec we do not carry on that constant. Both modes byte-identical but for
  object ids. See `head_pat_SeqDriver.default.cmp`.
* **R1 — the IMPLICIT constructor's return typespec.** Golden leaves the
  return typespec of a class's implicit `new` **anonymous** (span `0:0-0:0`,
  no `Class_defn`); we name it `<pkg>::<class>` at the
  `classScope && sub.name == "new"` mint. **205 cells** across the nine UVM
  row-modes (21-27 per database), an AWAY that is **PRE-EXISTING and
  unchanged by this pass** — both the pristine and the patched census read the
  same names. It is a different mint site and a different Surelog arm
  (`CompileStmt.cpp:2373-2382` for a WRITTEN constructor;
  `TestbenchElaboration.cpp:281/313` for the synthesized ones), and golden is
  not uniform there either (3 cells per database ARE named
  `uvm_pkg::uvm_component`-style), so it needs its own measurement.
* **R2 — the out-of-body method's duplicate return object.** Our class
  listing holds TWO return typespecs where golden holds one (the prototype
  copy wearing the definition's span). 104 cells per UVM row-mode, differing
  from golden **only in multiset COUNT** — name and instance agree on both
  sides, before and after. Visible in the arms as the two
  "MOVED, STILL WRONG" cells, where this pass fixed the NAME on both copies
  and the INSTANCE on one.
* **R3 — a scoped `pkg::C` return inside a CLASS, and a NESTED-class
  return, are `unsupported_typespec` in golden and `class_typespec` in ours**
  (`g156_a_mech` lines 21 / 33 and 39 / 43). An owner-KIND question, not a
  name one: the judge fails on `UhdmType` before it reads a name, so the names
  this pass writes on those two arm cells are neither TO-GOLDEN nor AWAY. The
  corpus incidence of a scoped class-handle return is zero in the mover set.
* **R4 — the TYPEDEF'd return's spelling is context-dependent.** Golden
  writes `adpcm_pkg::type_id` on one class's `get_type` and plain `type_id` on
  the next class's in the SAME database (`uvm_object_defines.svh:440:12`).
  748 golden cells wear an alias name; they are fenced out of this law and the
  spelling rule is UNMEASURED. Do not "fix" it uniformly — RESUME.md §9's
  naming dead end.
