# r10uvm81 — TWO LAWS

**BASE 7f31e65.** Production surface: `src/ExprEmit.cpp` **only** — law 2 is one
line inside `emitExpr`'s generic `ElementSelect` arm, law 1 is two file-static
predicates plus one call site at the tail of the same function's `NamedValue`
arm. Probe surface: `tools/probe/r10uvm81repro/` only.

```
§ selIdxNestPrefixJoinsByScope80    src/ExprEmit.cpp, ElementSelect index prefix
§ pkgSubRefBindsPkgVarOverFormal81  src/ExprEmit.cpp, NamedValue tail
```

**Result, up front.**

* **Law 2** — r10uvm80's held-back fifth joint law — **LANDS**. Re-gated from
  scratch at 7f31e65: the same **10** byte movers, the same per-name numbers to
  the unit, `names-golden-LACKS = 0` on every one, and **SVSwitch moves by
  EXACTLY the four golden names the canary amendment names**.
* **Law 1** — the new 3-row head — **CLEARS the head OBJECT on all three rows**.
  `uhdm-cmp`'s head was never a package-variable KIND bug at all: both sides emit
  `string_var uvm_pkg::val` identically. The head is a **`vpiActual` BINDING**:
  golden points `uvm_sequencer_base::set_arbitration`'s `val` at the hoisted
  PACKAGE variable, we pointed it at the function's own `io_decl`.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and every script here.

Binaries (all `-j 2`, md5 taken separately):

| tag | md5 | contents |
|---|---|---|
| pristine | `4339982c4a4547d0f8e3d9ae35e82d2d` | a FRESH build of 7f31e65 |
| law2-only | `ef1dcff4de60f3e4933f26a6d9e77455` | 7f31e65 + law 2 |
| **final** | `fbe701bf6eca45dbb73f1fb9b0fbeb8b` | 7f31e65 + law 2 + law 1 |

---

# PART A — LAW 1, § pkgSubRefBindsPkgVarOverFormal81

## A.1 THE HEAD, and what my brief said it was

The 60-line head shared by SimpleUVM/default, SimpleUVM/testflags and
Scoreboard/default:

```
LHS (golden)  string_var: (uvm_pkg::val)  line:802:12  |vpiParent: \_package: uvm_pkg
                                          |vpiAutomatic:1 |vpiVisibility:1
RHS (ours)    io_decl:    (val)           line:1381:68 |vpiParent: \_function:
                                          (uvm_pkg::uvm_sequencer_base::set_arbitration)
```

r10uvm80's residue R0 — and the brief I was handed — read this as a **KIND and
PARENT** defect: "when does golden emit a package-scope declaration as a
VARIABLE vs an `io_decl`". **That reading is REFUTED by the artifact.** Dumping
`uvm_pkg`'s `vpiVariables` listing out of both databases and diffing it:

```
$ diff <golden uvm_pkg Variables>  <ours uvm_pkg Variables>
PKG VARS IDENTICAL   (33 entries each, byte for byte)
```

We already emit `string_var uvm_pkg::val` at `802:12`, parented to the package,
`vpiAutomatic:1 vpiVisibility:1`, with the same `string_typespec` at `802:5`.
There is nothing to fix about the package's listing.

`UHDM::BaseClass::Compare` (BaseClass.cpp:170) reports the first pair whose
`VpiType` differs, and `SafeCompare` walks vectors INDEX-WISE — so the pair the
cmp printed is one object compared against one object. Following it back through
both dumps:

```
uvm_pkg::uvm_sequencer_base::set_arbitration          (uvm_sequencer_base.svh:1381)
    function void uvm_sequencer_base::set_arbitration(UVM_SEQ_ARB_TYPE val);
      m_arbitration = val;                            <- 1382:19, the reference
    endfunction

golden  ref_obj(…set_arbitration::val) |vpiActual: \_string_var (uvm_pkg::val) @802:12
ours    ref_obj(…set_arbitration::val) |vpiActual: \_io_decl   (val)           @1381:68
```

`uvm_pkg::val` is `uvm_phase.svh:802`'s `string val;` — a **block local of the
OUT-OF-BODY constructor `uvm_phase::new`**, which Surelog HOISTS into the
package's variable listing. It has nothing to do with `set_arbitration`; the two
merely share the name `val`. Golden binds the reference to the hoisted package
variable **in preference to the function's own formal**, and that is what the
head is.

## A.2 THE MECHANISM — Surelog's last writer wins, and one early binder

Two Surelog sites, read out of the source and then confirmed cell by cell on
purpose-built goldens (§A.4).

**(1) `UhdmWriter::lateBinding`** (`UhdmWriter.cpp:3357`+). For every reference
that reached late binding it writes, in this order, **with no early exit between
the blocks**:

```cpp
if (auto decls = func->Io_decls())  { for (…) if (name) { ref->Actual_group(decl); break; } }
if (auto vars  = func->Variables()) { for (…) if (name) { ref->Actual_group(decl); break; } }
if (auto params= func->Parameters()){ for (…) if (name) { ref->Actual_group(decl); break; } }
if (const UHDM::instance* inst = func->Instance())
  if (inst->UhdmType() == uhdmpackage)                       // <-- the PACKAGE block
    if (pack->Variables()) { for (…) if (name) { ref->Actual_group(n); break; } }
if (ref->Actual_group()) break;
```

Each `break` leaves only its own `for`. **The package block is the LAST writer
and it overwrites the formal.** A MODULE subroutine is immune because that block
is guarded by `inst->UhdmType() == uhdmpackage`.

**(2) `CompileHelper::bindVariable`** (`CompileStmt.cpp:3089`). At COMPILE time
it walks `scope->VpiParent()` upward and, at a `function`/`task`, checks
`Variables()` **before** `Io_decls()`. Anything it resolves never enters the
late-binding pool and is therefore immune to (1). This is why a subroutine
**LOCAL** named `val` keeps the local (arm c4 cell E) while a **FORMAL** does
not — and it is also the whole of the exception in §A.4.3.

## A.3 THE LAW

> A reference inside a **PACKAGE-SCOPE subroutine** — a package function/task or
> an out-of-body class method, i.e. one whose `vpiInstance` is the package —
> whose simple name also names a variable in that package's `vpiVariables`
> listing binds **the package variable**, displacing the subroutine's own
> **FORMAL** (`io_decl`). Three gates, each MEASURED, none derived:
>
> * **FORMAL only.** A subroutine LOCAL, a module net, an enum constant and an
>   already-unbound reference are all untouched — the displaced binding must be
>   an `io_decl`.
> * **THE SUBROUTINE MUST BE THE PACKAGE'S OWN.** A package that wildcard-imports
>   another materialises a COPY of the imported subroutines *and* CLONES of its
>   variables; in that COPY the formal SURVIVES. (A CLONE variable displaces
>   perfectly well — for the importing package's OWN subroutines. Arm c8 splits
>   the two.)
> * **AN `if` CONDITION / `case` EXPRESSION KEEPS THE FORMAL** — unless a
>   conditional, loop, `case` or `fork` statement stands between it and the
>   subroutine body, in which case the package variable wins again.

The third gate is (2) above, exactly: `compileConditionalStmt`
(`CompileStmt.cpp:1322`) compiles its predicate with `pexpr = pstmt`, the
**enclosing** statement — the `if_stmt` object does not exist yet — so
`bindVariable` starts its parent walk from something whose `VpiParent` is
already set and reaches the function's `Io_decls()` EARLY. Every other position
(an assignment's operands, a `while`/`for` condition, a return expression, a
call argument) is compiled against an object whose own `VpiParent` is still
null, the walk dies at once, and the reference goes to late binding. And when a
conditional/loop statement stands in between, ITS `VpiParent` is the one still
null (its caller sets it after the body is compiled), so the chain breaks there
too and the predicate falls back into the pool.

## A.4 THE GRIDS

Five purpose-built goldens, run with `ct81arm.sh` (golden + BOTH binaries in ONE
scratch dir, so `uhdm-dump`'s absolute paths for Surelog's synthesized
`builtin.sv` are identical across the three reads). Every cell below is read off
the artifact with `r10uvm81cen` in `R10UVM81_LIST=1` mode, which counts each
object ONCE — a dump reprints an object at every reference and the corpus head
alone is printed three times.

### A.4.1 arm `c4_pkgbind81.sv` — WHICH declarations, WHICH subroutines

| cell | site | golden | base | patched |
|---|---|---|---|---|
| A `set_val::val` | out-of-body method, formal vs **HOISTED** pkg var | `string_var p81::val` | io_decl | **= golden** |
| B `set_pdecl::pdecl` | out-of-body method, formal vs **DECLARED** pkg var | `int_var p81::pdecl` | io_decl | **= golden** |
| C `set_free::freearg` | no collision (CONTROL) | `io_decl` | io_decl | io_decl |
| D `tset_val::val` | out-of-body **TASK** | `string_var p81::val` | io_decl | **= golden** |
| E `loc_val::val` | method **LOCAL** named `val` | the **LOCAL** `int_var` | local | local |
| F `inbody_val::val` | **IN-BODY** method | *(no actual)* | none | none |
| G `inbody_free::freearg` | in-body control | *(no actual)* | none | none |
| H `pf_val::val` | **plain package function** | `string_var p81::val` | io_decl | **= golden** |
| I `pf_pdecl::pdecl` | plain pkg fn, **LVALUE** | `int_var p81::pdecl` | io_decl | **= golden** |
| J `pf_free::freearg` | control | `io_decl` | io_decl | io_decl |
| K `mf_val::val` | **MODULE** fn, formal vs module var `val` | `io_decl` | io_decl | io_decl |
| L `mf_free::freearg` | module control | `io_decl` | io_decl | io_decl |

Cell K is the load-bearing control: the module twin never moves, which is
Surelog's `inst->UhdmType() == uhdmpackage` guard. Cell E is the one that
refutes "the package listing beats everything": a LOCAL is bound EARLY.

**All 25 reference bindings this arm carries equal golden after the patch, and
the 13 that were already right did not move.**

### A.4.2 arm `c5_bindpos81.sv` — WHERE in the subroutine, 29 cells

| position | top level | one `begin` deep |
|---|---|---|
| assignment RHS | **pkg var** | **pkg var** |
| assignment LHS | **pkg var** | **pkg var** |
| `if` CONDITION | **io_decl** | **io_decl** |
| `while` condition | **pkg var** | **pkg var** |
| `case` EXPRESSION | **io_decl** | **io_decl** |
| call argument | **pkg var** | **pkg var** |
| `for` condition | **pkg var** | **pkg var** |
| `return` expression | **pkg var** | — |

plus an out-of-body **task** (`if` condition → io_decl at both depths, assignment
→ pkg var), a NON-colliding formal in all five positions (io_decl everywhere),
and the module twin (io_decl everywhere). **All 58 reference bindings in this arm
equal golden after.**

### A.4.3 arm `c6_condshape81.sv` — the SHAPE of the condition, 16 cells

Bare ref, depth-1 operation, depth-2 operation, unary, under a call, `if…begin`,
`if/else`, bare `case` expression, depth-1 and depth-2 case expressions: **every
one keeps the `io_decl`**, and the `return val;` control takes the package
variable. The condition's shape is NOT the discriminator. **All 32 reference
bindings in this arm equal golden after.**

### A.4.4 arm `c7_uvminit81.sv` — the EXCEPTION to the exception

`uvm_init` is the corpus cell that broke the simple rule: three of its four `cs`
references take `uvm_pkg::cs` and the fourth — `if(cs == null)` — keeps the
formal. Reproduced statement for statement, and then laddered:

| cell | site | golden |
|---|---|---|
| F1 | `if ((val != actual) && (val != 0))` inside `else begin` inside `if…begin` | **pkg var** *(= BuildUVMPkg 9812:12/30)* |
| F2 | `if (val == 0) begin` at the body's top level | **io_decl** *(= 9827:6)* |
| F3 | `val = dcs;` inside that begin | **pkg var** *(= 9829:5)* |
| F4 | `sink = val;` top level | **pkg var** |
| F5/F6 | the same conditions, TOP LEVEL, no enclosing begins | **io_decl** |
| F7/F8 | the same conditions, ONE plain `begin` deep | **io_decl** |
| G0–G3 | `if` condition at plain-`begin` depth **0, 1, 2, 3** | **io_decl** at every depth |
| H2 | `if` condition inside two **IF-BRANCH** begins | **pkg var** |
| I1/I2 | `if` condition inside a **for-loop body**, depths 1 and 2 | **pkg var** |

**Depth is NOT the discriminator — G0…G3 prove that. The KIND of the enclosing
statement is.** A chain of plain blocks keeps the formal; one conditional or
loop STATEMENT anywhere above the predicate hands it to the package variable.
**All 53 reference bindings in this arm equal golden after.**

### A.4.5 arm `c8_impclone81.sv` — the import-clone split, on ONE golden

```
p89::c89::sv89::val   p89's OWN subroutine, p89's OWN `val`            -> p89::val
q89::c89::sv89::val   the COPY of p89's subroutine materialised in q89 -> io_decl
q89::d89::qv89::val   q89's OWN subroutine, seeing q89's CLONE of `val`-> q89::val
```

This is SeqDriver's `adpcm_pkg` verbatim (`package adpcm_pkg; import uvm_pkg::*;`)
and it is the cell that **refuted my first implementation**: I had gated on "the
package variable is this package's OWN", which is exactly backwards — a clone
displaces fine, an imported SUBROUTINE copy does not. Fixed before landing.
**All 11 reference bindings in this arm equal golden after.**

### STATED GATE == CODE GATE

`ct81gate.py <src/ExprEmit.cpp>` asserts every clause of both laws against the
CODE with **comments stripped first** (a guard that greps its own write-up is
this campaign's oldest trap, and these two laws are carried mostly by comment
text) and against a **SLICE** of the file, not the whole of it (`ExprEmit.cpp` is
20 k lines; `SymbolKind::Package` occurs 32 times in it, so a whole-file count
measures the FILE and not the LAW — that mis-count was caught by running the
audit, and fixed).

```
patched   src/ExprEmit.cpp  -> 17/17 PASS, exit 0
pristine  src/ExprEmit.cpp  -> AUDIT CANNOT RUN: law site(s) absent, exit 4
```

## A.5 THE CENSUS — a complete inventory, and an EXACT prediction

`r10uvm81cen.cpp` opens a `.uhdm` with UHDM's own `Serializer` and walks
`Serializer::AllObjects()`, emitting one `BIND` row per reference that carries a
`vpiActual`. `ct81cen.sh` runs it over a WHOLE verify_golden workdir, GOLDEN and
OURS, and joins per database on `(ref line:col, ref fullname)` — **not** on the
file, because our side leaves `vpiFile` EMPTY on every class-member object and a
file-bearing key joins nothing (r10uvm80 paid for that one). The join is a
**MULTISET with a per-actual-kind histogram**, so a per-object regression inside
a shared key cannot be masked; the corpus head's key carries **two** objects.

Three populations:

* **FMISS** — golden binds a `variables`, ours an `io_decl` (the defect).
* **FOVER** — ours binds a `variables`, golden an `io_decl` (an over-fire).
* **XDIFF** — the two sides disagree on the actual in any OTHER way.

**CALIBRATION FIRST**: golden-vs-golden through the real driver reads
`grefs=18807 orefs=18807 FMISS=0 FOVER=0 XDIFF=0`.

### The BASE inventory (surelog corpus, both modes, 953 databases)

**FMISS 17 rows / 30 objects. FOVER 0. XDIFF 36 313 rows.** Every skipped
directory was accounted for: of the 620 SKIP-NOFILE dirs, **570 are golden-only
and 50 are neither — `ours-only(no golden)=0`**, so the census covers 100 % of
our surelog databases and this is an inventory, not a sample.

| object | rows | belongs to this law |
|---|---|---|
| `uvm_pkg::uvm_sequencer_base::set_arbitration::val` (x2 objects each) | 7 | **yes** |
| `uvm_pkg::uvm_init::cs` @9812:12, @9812:30, @9829:5 (x2 each) | 6 | **yes** (BuildUVMPkg only) |
| `addr` @1491:44 — golden binds a nameless `logic_net work@top.addr` | 4 | **no** (the module-hoist family) |

### THE PREDICTION, written before the patched sweep existed

**7 databases move; 26 reference objects re-point from an `io_decl` to a package
variable; FMISS 17 → 4 rows (30 → 4 objects, the `addr` residue); FOVER stays 0;
the uhdm2rtlil corpus cannot move at all.**

| database | predicted objects |
|---|---|
| default/SimpleUVM, testflags/SimpleUVM | 2 each |
| default/Scoreboard | 2 |
| default/SeqDriver, testflags/SeqDriver | 2 each |
| default/BuildUVMPkg, testflags/BuildUVMPkg | 8 each |

**The uhdm2rtlil corpus is an impossibility proof**: the same census over all
**679** u2r databases (21 261 golden bindings) reads **FMISS=0 and FOVER=0** —
there is no disagreement of this kind anywhere in it, so law 1 cannot move a byte
there.

## A.6 REFUTATIONS

**RF-1 — "the head is a package-variable KIND/PARENT defect" (my brief's model)
— REFUTED BY THE ARTIFACT.** The two `uvm_pkg` variable listings are byte
identical, all 33 entries. Had I implemented the brief I would have rebuilt a
listing that was already right and left the head standing. §A.1.

**RF-2 — "the package listing always beats the subroutine's own declarations" —
REFUTED by arm c4 cell E.** A subroutine LOCAL named `val` keeps the local, in
golden and in ours, because `bindVariable` resolves it EARLY. Only the FORMAL
moves.

**RF-3 — "gate on the package variable being this package's OWN" — REFUTED by
arm c8, and it was in the code before the arm was written.** A clone
materialised by a wildcard import displaces a formal perfectly well; what does
NOT displace is the imported SUBROUTINE copy. The first implementation had this
exactly backwards. The corpus caught it too: the FIRST patched sweep produced
**4 FOVER rows** (`adpcm_pkg::…::set_arbitration::val` x2 modes and
`uvm_pkg::uvm_init::cs` @9827:6 x2 modes) where the base had zero, and both
families were fixed before landing. **This is the pass's over-fire, found and
closed by the census, not by luck.**

**RF-4 — "the exception is about nesting depth" — REFUTED by arm c7's ladder.**
`if` conditions at plain-`begin` depths 0, 1, 2 and 3 all keep the formal; one
if-branch or loop-body block at depth 2 hands it over. Depth measures nothing
here; the enclosing statement's KIND is the whole of it.

**RF-5 — "read slang's own binding" — not applicable, and worth saying.** slang
resolves `val` in `set_arbitration` to the formal, correctly. Golden is
*wrong* here, in the plain-language sense; this campaign's target is byte
equivalence with Surelog, so the law transcribes Surelog's overwrite and says so.

---

# PART B — LAW 2, § selIdxNestPrefixJoinsByScope80, RE-GATED AT 7f31e65

> The prefix a SELECT's index subtree hands to what is **NESTED** under it is
> `joinRef(prefix, <the select's base name>)`, never a hard `"."`.

The FIFTH site of the joint family (r10uvm77 the trailing-step refs, r10uvm78 the
doubled part-select prefixes, r10uvm79 the hier-path tail AND the path-scoped
index, this the prefix that index subtree passes DOWN). r10uvm80 measured it,
held it back because two of its ten movers are canaries, and committed it as
`tools/probe/r10uvm80repro/law2_selIdxNestPrefixJoinsByScope80.diff`. It applies
CLEAN on 7f31e65 (`git apply --check` exit 0) and is re-gated here from scratch.

## B.1 arm `c3_deepjoint81.sv` — r10uvm80's eight cells plus the brief's three

d1–d8 are r10uvm80's verbatim so the two passes' numbers stay comparable.
r10uvm81 adds the cells the brief asks for, all of them r10uvm79's V-R1 names:

| cell | expression | golden | base | patched |
|---|---|---|---|---|
| d9 | `iarr[midx[midx[midx[midx[i]]]]].f` — **DEPTH 4** | `…::iarr[].f::midx::midx::midx::midx` | `.`-joined | **= golden** |
| d10 | `iarr[midx[midx[midx[i]]]].f = 2` — **LVALUE at depth 3** | `::`-joined | `.`-joined | **= golden** |
| d11 | `fn81(iarr[midx[midx[i]]].f)` — nested select as a **CALL ARGUMENT** | `::`-joined | `.`-joined | **= golden** |
| d12 | `fn81(midx[midx[midx[i]]])` — depth-3 index as a call argument | `…::midx::midx::midx` | `.`-joined | **= golden** |
| d13 | `iarr[midx[fn81(midx[i])]].f` — call argument **under** the index | `::`-joined | `.`-joined | **= golden** |
| d14 | MODULE twin of d9 (depth 4) | `work@mdeep81.sarr[].f.mi.mi.mi.mi` | = | **byte-identical** |
| d15 | MODULE twin of d10 (lvalue) | `.`-joined | = | **byte-identical** |
| d16 | MODULE twin of d11 (call argument) | `.`-joined | = | **byte-identical** |

Arm c3's per-NAME judge: fullname multiset distance **64 → 16**,
**names-golden-LACKS = 0**, 11 golden names newly produced. The `mdeep81` name
multiset is **identical in golden, base and patched** at every one of the new
cells — `joinRef` returns `.` for a `.`-first prefix, so the module world does not
move at depth 4, at an lvalue or under a call argument either.

## B.2 LAW 2 ALONE, on the corpus, at 7f31e65

Measured with the law2-only binary swept over both corpora and byte-compared
against the PRISTINE sweep, so every number is law 2 alone.

| gate | result |
|---|---|
| surelog rows (1588) | `ct8rows.sh` **0 differing ROWS** |
| uhdm2rtlil rows (731) | `ct8rows.sh` **0 differing ROWS**, 679/50/2 |
| byteverify u2r | **0 / 679 movers** |
| byteverify surelog | **10 / 953 movers**, `SELFCHECK 952/953` |

The ten: `default+testflags` × {SimpleUVM, SeqDriver, BuildUVMPkg, SVSwitch},
plus `default/Scoreboard` and `default/Earlgrey_0_1` — **the same ten databases
r10uvm80 reported, at a base three commits later.**

### Every mover judged per NAME (`mv81.sh`)

| database | NAME-multiset distance to golden, pristine → law2 | names introduced that golden LACKS | GOLDEN names newly produced |
|---|---|---|---|
| SimpleUVM (both modes) | 5 348 → **4 930** | **0** | 79 |
| Scoreboard/default | 5 307 → **4 889** | **0** | 79 |
| SeqDriver (both modes) | 13 806 → **13 028** | **0** | 141 |
| BuildUVMPkg (both modes) | 4 900 → **4 608** | **0** | 65 |
| SVSwitch (both modes) | 74 → **64** | **0** | 4 |
| Earlgrey_0_1/default | 18 727 → **18 667** | **0** | 15 |

**Every number reproduces r10uvm80's table to the unit.** `mv81.sh` also prints
the per-BINDING attribution: across all ten databases **0 bindings end at
something other than golden's**; 4 land on keys golden has no *bound* twin for,
and each of those 4 is the SAME object under its new `::` name (the paired `.`
key disappears in the same run, and the per-NAME judge's `names-golden-LACKS = 0`
says golden owns the new name).

### THE CANARY AMENDMENT — met exactly

```
default/SVSwitch   NAME-multiset distance to golden   pristine 74 -> patched 64
                   names introduced that golden LACKS                        0
                   GOLDEN names newly produced                               4
                     work@Receiver::start::bytes::size
                     work@packet::byte_pack::bytes::i
                     work@packet::byte_unpack::bytes::size
                     work@packet::byte_unpack::bytes::i
```

Four names, the four the amendment names, `work@Receiver::start::bytes::size`
among them — cell **C** of `joinRef`'s own comment table in `src/EmitHelpers.h`,
the cell whose comment records that golden writes it with `::` and that a wrong
repair once broke it. SVSwitch's CSV row is **byte-identical** (0 differing rows
over 1588, `canaries.sh` `changed=0`), so the movement is invisible to every CSV
instrument and only the byte verifier sees it. `InterfaceModPort`,
`BlackParrotComplex` and `YosysOldOr` are **not movers at all**.

### An HONEST note, carried from r10uvm80

Law 1's corpus movers were predicted EXACTLY from the artifact before the build;
**law 2's cannot be**, and that is stated rather than papered over. Every textual
detector for "a `.` where golden writes `::`" fires on golden too (golden's own
`iarr[].f::midx` contains `].f`, and r10uvm78's RF-1 established that a `.` inside
a `::` scope is legitimate in 768 golden objects). What IS predicted, and
verified on every one of the ten movers, is the **DIRECTION**: name-multiset
distance strictly DOWN, and **zero** names produced that golden does not have.

---

# PART C — GATES (the final binary, law 1 + law 2)

**GATE 0 — the pristine binary reproduces the COMMITTED baselines exactly**
(baseline FIRST, before any patched number was read):

| corpus | rows | whole-row diff vs committed baseline |
|---|---|---|
| uhdm2rtlil, testflags | 731 | **0 differing ROWS** (679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL) |
| surelog, both modes | 1588 | **0 differing ROWS** |

**GATE 1 — build.** All three binaries built `-j 2`, `Built target slang_uhdm`,
md5s in the table at the top (taken in a separate command).

**GATE 2 — goldens.** `23 PASS / 0 FAIL`; negative control
`SLANG_UHDM=/bin/false` → `0 PASS / 23 FAIL`.

**GATE 3 — uhdm2rtlil.** 731 rows, `679 CMP_EQUAL / 50 SLANG_REJECT /
2 SURELOG_FAIL`, `ct8rows.sh` **0 differing ROWS**, dump histogram unchanged
(52 / 183 differ / 496 match). `canaries.sh` ok=9 changed=0 absent=0
unknown-names=25 (expected 25 on a u2r csv); `ctcan2.sh EXPECT_UNKNOWN=6` PASS.

**GATE 4 — surelog, `--mode both`.** 1588 rows, `ct8rows.sh` **0 differing ROWS**,
status and dump histograms identical. `canaries.sh` ok=52 changed=0 absent=0
unknown-names=8 (expected 8 on a surelog csv); `ctcan2.sh EXPECT_UNKNOWN=1`
ok=58 changed=0 PASS; `canaudit.sh` audited=31 UNCOVERED=0 FENCE-BREACH=0.

**GATE 5 — the byte verifier, both negative controls, EVERY mover named.**

| corpus | paths | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|---|
| uhdm2rtlil | 679 | **0** | 678/679 | 1 (= 1 corruption + 0 movers) |
| surelog | 953 | **10** | 952/953 | 11 (= 1 corruption + 10 movers) |

Attribution below (§C.1) is per NAME and per BINDING for all ten.

**GATE 6 — the heads.**

| row | pristine cmp lines | final | heads |
|---|---|---|---|
| SimpleUVM/default | 60 | **52** | 1 |
| SimpleUVM/testflags | 60 | **52** | 1 |
| Scoreboard/default | 60 | **52** | 1 |
| SeqDriver/default | 52 | 52 | 1 (cmp byte-identical with ids stripped) |
| SeqDriver/testflags | 52 | 52 | 1 (same) |
| BuildUVMPkg/default | 94 | 94 | 1 (same) |
| BuildUVMPkg/testflags | 94 | 94 | 1 (same) |
| SVSwitch (both) | 0 / 0 heads | 0 / 0 heads | CMP_EQUAL throughout |

**GATE 7 — boundaries.** All six `.sv` arms here run through both binaries. Law
1's five arms carry **179 reference bindings between them and every one equals
golden after the patch** (25 / 58 / 32 / 53 / 11), with **zero** cells left
disagreeing; law 2's module twins (c3 d8 / d14 / d15 / d16) are byte-identical in
all three columns.

## C.1 THE TEN MOVERS, ATTRIBUTED — PER LAW, PER NAME, PER BINDING

The three sweeps make the split mechanical: a database whose FINAL bytes equal
its LAW2-ONLY bytes took nothing from law 1.

| database | pristine | law2-only | final | law 1 moved it? |
|---|---|---|---|---|
| default/BuildUVMPkg | e56d6e8d16cf | c3751425c954 | 130e5ef58ded | **yes** |
| testflags/BuildUVMPkg | e56d6e8d16cf | c3751425c954 | 130e5ef58ded | **yes** |
| default/Scoreboard | 2e4216a44e48 | e88983c84a53 | eff9d48e6b82 | **yes** |
| default/SeqDriver | 18149e325ff8 | 1fd7485a6821 | 1b35bd9540b3 | **yes** |
| testflags/SeqDriver | dc1f7e1f1add | b5d2e7b70ddf | 206840a2ba0e | **yes** |
| default/SimpleUVM | d41da03dd144 | 2dbf85001a5f | 46fa06d06b1e | **yes** |
| testflags/SimpleUVM | 8150e74cb078 | 3833d6d5be49 | 40f58f92dacc | **yes** |
| default/Earlgrey_0_1 | 3d1f57715d76 | 01174353eb45 | **01174353eb45** | no — law 2 only |
| default/SVSwitch | de7ab46e3f2e | 4842211c4030 | **4842211c4030** | no — law 2 only |
| testflags/SVSwitch | de7ab46e3f2e | 4842211c4030 | **4842211c4030** | no — law 2 only |

**Law 1 alone** (`mv81.sh <law2-only workdir> <final workdir>`; `namecmp80.py`'s
column headers read `law1`/`law1+2` because it is r10uvm80's script carried
forward unchanged — in THIS invocation those two columns are *law2-only* and
*final*), 7 databases,
**13 binding keys / 26 reference objects, EVERY ONE `-> GOLDEN`, and NOT ONE
OTHER BINDING IN THE CORPUS CHANGED**:

| database | keys | objects | the objects |
|---|---|---|---|
| default/SimpleUVM | 1 | 2 | `…set_arbitration::val` @1382:19 → `string_var uvm_pkg::val` @802:12 |
| testflags/SimpleUVM | 1 | 2 | same |
| default/Scoreboard | 1 | 2 | same |
| default/SeqDriver | 1 | 2 | same |
| testflags/SeqDriver | 1 | 2 | same |
| default/BuildUVMPkg | 4 | 8 | `…set_arbitration::val` @53460:19 → `string_var uvm_pkg::val`; `uvm_init::cs` @9812:12, @9812:30, @9829:5 → `class_var uvm_pkg::cs` @39601:21 |
| testflags/BuildUVMPkg | 4 | 8 | same |

**7 databases, 26 objects — the prediction of §A.5, exactly.** Each key carries
two objects (the package view and the module hoist), which is why the census's
multiset join was built that way and a set-valued join would have reported 13.

Law 1's NAME-multiset distance to golden is **UNCHANGED** on all seven
(`4608 → 4608`, `4889 → 4889`, `13028 → 13028`, `4930 → 4930`) with
`names-golden-lacks = 0` — an independent confirmation that this law re-points
bindings and touches no name.

**GATE 8 — the census, re-run on the final sweep** (order-blind, and the
authority under the Scoreboard-coin rule):

| population | base | final | predicted |
|---|---|---|---|
| **FMISS** | 17 rows / 30 objects | **4 rows / 4 objects** | 4 rows / 4 objects |
| **FOVER** | 0 | **0** | 0 |
| **XDIFF** | 36 313 rows | 35 167 rows | (law 2's renamings; strictly down) |

The four survivors are the `addr` family named in R1 — *the exact four rows
predicted, in the exact four databases predicted.*

**GATE 9 — the SVSwitch canary, on the FINAL binary.** `default/SVSwitch`'s
final database is **byte-identical to the law2-only one**, so law 1 contributes
zero bytes to it; the per-name judge on the final binary reads
`74 → 64 | new-names-golden-lacks=0 | golden-names-newly-produced=4`, the four
names of the amendment. `InterfaceModPort`, `BlackParrotComplex` and
`YosysOldOr` are not movers.

---

# PART D — RESIDUES (ranked)

**R0 — THE NEW HEAD, and the three target rows have converged onto SeqDriver's.**
The head cut is `60 → 52` cmp lines on SimpleUVM/default, SimpleUVM/testflags and
Scoreboard/default; the head OBJECT is gone from all three. What is now the head
of those three is what was ALREADY the head of SeqDriver/default and
SeqDriver/testflags — **five rows now share ONE head**, `md5 b8d1857dbc1c` with
the ids stripped:

```
uvm_resource_pool::sort_by_precedence   (uvm_resource_db.svh:955)
    uvm_resource_types::rsrc_q_t all;        <- an UNRESOLVED class-typed queue

LHS (golden)  class_var: (uvm_pkg::uvm_resource_pool::sort_by_precedence::all)
              |vpiParent: \_array_var (same fullname, same 955:34-955:37 span)
              |vpiTypespec -> ref_typespec -> unsupported_typespec
                              (uvm_resource_types::rsrc_q_t) @955:5
RHS (ours)    ref_var:   (uvm_pkg::uvm_resource_pool::sort_by_precedence::all)
              …every other field byte-equal, including the unsupported_typespec…
```

It is a **one-word KIND** difference on the ELEMENT variable of a queue whose
element type did not resolve: golden mints a `class_var` under the `array_var`,
we mint a `ref_var`. Span, fullname, parent and typespec are all already right.
The obvious next question is what golden keys that choice on — the queue's
element type being a CLASS the emitter could not resolve (`unsupported_typespec`)
versus one it could — and whether the same split governs the `ref_var` elements
`makeQueueDynArrayVar` mints elsewhere. BuildUVMPkg's head is untouched and
different (`struct_typespec uvm_pkg::m_uvm_factory_type_pair_t` @11947:40).

**R1 — the `addr` binding family, 4 objects.** SimpleUVM and SeqDriver, both
modes: `uvm_reg_map::get_physical_addresses`'s formal `addr` @1405:69, whose
reference at 1491:44 golden binds to a NAMELESS `logic_net work@top.addr` — an
implicit wire the hoisting module mints — where we bind the io_decl. That is the
`classPropRefs` / hoisted-net family (§ withIterRefBindsHoistNet75's
neighbourhood), NOT the package-listing family: golden's actual is a `net`, and
`nets` are not in `pack->Variables()`. Deliberately untouched: mixing the two is
how a one-line law becomes a two-law regression.

**R2 — a `fork` arm above an `if` predicate is UNMEASURED.** `condPredEarlyBound81`
treats `ParallelBlockStatement` like a conditional (the predicate falls through
to the package variable). No corpus row and no arm reaches that cell; it is
listed so the next pass knows the claim is a CHOICE and not a measurement.

**R3 — the XDIFF population: 36 313 rows at base, 35 167 after** (both sides
bind, differently, in some way that is neither of this law's two directions —
the drop is law 2's renamings moving keys, not law 1). Untouched by this pass and
untouched BY it. Its head families, by golden's actual kind:
`logic_net` 6 362, `io_decl` 2 919, `ref_var` 1 809, `enum_const` 1 666,
`int_var` 1 370, `class_var` 930. The `logic_net` column is the biggest single
target left in this instrument's field of view (golden 6 362 vs ours 10 302 —
we over-bind implicit wires by a wide margin) and it is a whole pass of its own.

---

# PART E — FILES

| file | role |
|---|---|
| `r10uvm81cen.cpp` | the census instrument (`Serializer::AllObjects()`, references + `vpiActual`); also carries r10uvm80's `NAMES` mode, unchanged, so the per-NAME canary numbers stay comparable across passes |
| `build81.sh` | builds it against the static UHDM in `~/.local` |
| `ct81cen.sh` | whole-workdir golden-vs-ours binding join; FMISS / FOVER / XDIFF per database |
| `ct81arm.sh` | golden + BOTH binaries in ONE scratch dir; cmp/heads/LCS-diff/multiset distance |
| `ct81gate.py` | STATED GATE == CODE GATE, comment-stripped and SLICED, with a real negative control |
| `mv81.sh` | attributes every byte mover, per NAME and per BINDING |
| `c3_deepjoint81.sv` | law 2's grid — r10uvm80's d1–d8 plus depth-4 / lvalue / call-argument cells |
| `c4_pkgbind81.sv` | law 1: which declarations, which subroutines (23 cells) |
| `c5_bindpos81.sv` | law 1: WHERE in the subroutine (29 cells) |
| `c6_condshape81.sv` | law 1: the SHAPE of the condition (16 cells) |
| `c7_uvminit81.sv` | law 1: the `uvm_init` miniature and the depth ladder (22 cells) |
| `c8_impclone81.sv` | law 1: the import-clone split (9 cells) |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `msdist.sh` `rowheads.sh` `namecmp80.py` | the standard gates, carried forward unchanged |
