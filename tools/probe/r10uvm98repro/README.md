# r10uvm98 — § `bareTdNameFirstWriterWins98` — the seven-row-mode UVM head CUT FROM ~99,000 CMP LINES TO 50

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `b924c9e` |
| worktree | `/tmp/wt_r10uvm98` |
| pristine binary | md5 `3546f230b2c6b009b563c45026e18d49`, frozen `chmod 555` |
| patched binary | md5 `7cd93275a5d3314647139ffc911d1f6c`, frozen `chmod 555` |
| production surface | `src/TypeEmit.cpp` (one hook in `makeTypespec` + four helpers) and `include/UhdmExporter.h` (the table and the declarations) |
| probe surface | `tools/probe/r10uvm98repro/` only |

## READ THIS FIRST — the head

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| SeqDriver default / testflags | **99,202** | **50** | 1 |
| MiniAmiq default / testflags | **99,202** | **50** | 1 |
| SimpleUVM default / testflags | **99,106** | **108** | 1 |
| Scoreboard default | **99,106** | **108** | 1 |
| BuildUVMPkg default / testflags | 52 | **52** | 1 (unchanged) |
| Earlgrey_0_1 default / testflags | 46 | **46** | 1 (unchanged) |
| Rggen default | 64 | **64** | 1 (unchanged) |
| corpus rows changed | — | **0** (both corpora, both modes) | |

`head_pris_default_SeqDriver.head60.cmp` is the first 60 lines of the old head
(two whole `class_defn` objects, `uvm_pkg::uvm_algorithmic_comparator` vs
`uvm_pkg::uvm_port_base`); `head_pat_default_SeqDriver.cmp` is the whole new
one, 50 lines, a different family entirely (**R0**, below).

## The law

> **§ `bareTdNameFirstWriterWins98` — A TYPEDEF NAME SURELOG CANNOT RESOLVE
> BINDS, DESIGN-WIDE, TO THE FIRST DECLARATION OF THAT BARE NAME.**
>
> `CompileHelper::compileDatastructureTypespec`
> (`src/DesignCompile/CompileType.cpp:722`) resolves a written type name from
> the component being compiled with `component->getDataType(typeName)`. That is
> `DesignComponent::getDataType` (`src/Design/DesignComponent.cpp:108`) and it
> walks the **LEXICAL parent-scope chain and nothing else**. `ClassDefinition`
> *does* have a base-class-walking lookup — `getBaseDataType`
> (`src/Testbench/ClassDefinition.cpp:189`) — but its **only caller in the whole
> Surelog tree** is `ElaborationStep::bindDataType_`
> (`src/DesignCompile/ElaborationStep.cpp:907`), the VARIABLE binder. The
> TYPESPEC path never asks it. So an **INHERITED** typedef name written in a
> derived class body is NOT FOUND: `compileTypespec` falls through the
> class-definition and interface fallbacks to `CompileType.cpp:1053`, mints an
> `unsupported_typespec` carrying the written name, and registers the reference
> with `component->needLateTypedefBinding(...)`.
>
> `ElaborationStep::bindTypedefs_` (`ElaborationStep.cpp:102`) then repairs it.
> It builds ONE `defs` vector, in this order —
> **FileContents** (`design->getAllFileContents()`), **packages**
> (`getPackageDefinitions()`), **modules** (`getModuleDefinitions()`, keyed
> `lib@name`), **programs**, **classes** (`getClassDefinitions()`, a multimap
> keyed on the FULLY QUALIFIED class name) — walks it once compiling each
> typedef's typespec, and fills
> `std::map<std::string, typespec*> specs` with
> `specs.emplace(typd->getName(), ts)` (`:240`, `:265`, `:276`).
> **`emplace` is FIRST-WRITER-WINS.** The three tail loops (`:328` packages,
> `:359` modules, `:386` classes) then walk every component's
> `getLateTypedefBinding()` list, read the placeholder's name and swap in
> `specs.find(need)->second`.
>
> A bare typedef name therefore has ONE design-wide meaning for every reference
> Surelog failed to resolve: **the first declaration of that name in `defs`
> order**. It is a Surelog bug. **Golden is the spec, bugs included** — we
> MODEL it, we do not fix it.
>
> **THE FENCE IS THE RULE ITSELF.** A name declared by exactly ONE component is
> its own first writer, so the model is the **IDENTITY** there. That is why the
> whole `uhdm2rtlil` corpus — 681 of whose 1,358 databases DO carry
> class-typespec-typed sites — cannot move a single byte.
>
> **GATE, three questions, all measured on golden:**
> 1. **SPELLING** — only a BARE identifier can be left unresolved. A
>    class-scoped spelling (`q1base98#(int)::rank_t`) goes down
>    `compileTypespec`'s class_scope arm and binds CORRECTLY (arm `a4` `qual`).
> 2. **HOME** — only a CLASS-nested typedef can be out of `getDataType`'s
>    reach; a package / `$unit` / module typedef is on the lexical chain of
>    everything that can see it. An INTERFACE class is not in the list
>    `bindTypedefs_` walks at all (vsd11).
> 3. **REACH** — Surelog's condition exactly: found on the LEXICAL chain
>    (the declaring class itself, or an enclosing class for a nested one)
>    ⇒ resolved ⇒ nothing moves.

## The head, decoded from the pristine cmp log first

```
LHS  class_defn: (uvm_pkg::uvm_algorithmic_comparator), id:224   <- golden
RHS  class_defn: (uvm_pkg::uvm_port_base),             id:52503  <- ours
```

reached through `class_typespec::Compare`'s LAST field, `SafeCompare(Class_defn)`
(`typespec::Compare` walks VpiName, `Typedef_alias`, `Instance` first — pass 97
cleared the alias, and VpiName/Instance agree). A referrer walk (`/tmp` probe,
reproduced by `ct98cen`) names the sites exactly — 11 `provider` formals in
SeqDriver:

| site | golden binds | ours (pristine) |
|---|---|---|
| `uvm_port_base::{connect,m_check_relationship,m_add_list}` — **3 sites**, the class's OWN `this_type` | id 318164 @`uvm_port_base.svh:199:11`, `defn=uvm_port_base` | the same shape (AGREE) |
| `uvm_tlm_{b,nb}_{initiator,target,passthrough_initiator,passthrough_target}_socket::connect` — **8 sites**, the INHERITED `this_type` | id 317912 @`uvm_algorithmic_comparator.svh:74:11`, `defn=uvm_pkg::uvm_algorithmic_comparator` | id 112685 @`199:11`, `defn=uvm_port_base` |

`uvm_pkg::uvm_algorithmic_comparator` is the alphabetically first `uvm_pkg`
class declaring a `this_type` (`comps/uvm_algorithmic_comparator.svh:74`), so it
wins the name for the whole design. **We already carried the winner's object**:
SeqDriver's pristine database has exactly two `class_typespec`s whose
`Class_defn` is `uvm_algorithmic_comparator`, one of them
`(adpcm_pkg::this_type) @74:11-74:37, inst=adpcm_pkg::, no alias` — the same
shape as golden's 317912. The fix points the eight sites at it.

## The grid, golden-side, both views (`three98.sh`, `GRID.r10uvm98.txt`)

Scored twice: `FIELD=DEFN` is `class_typespec::Compare`'s LAST field — the
head's field, the one this pass moves — and `FIELD=ALL` is the whole judged
value (VpiName, `Typedef_alias`, `Instance` too, which carry pre-existing
families R2/R3 that would otherwise drown the signal).

| arm | what it pins | golden's answer | def | elab |
|---|---|---|---|---|
| `g98_a1_inherit.sv` | **THE HEAD, MINIMISED.** `ccc98 extends bbb98` writing the INHERITED `this_type` as a FORMAL / RETURN / method LOCAL, with an alphabetically earlier `aaa98` also declaring it; plus the INT typedef `my_t` the same way | all bind **`p98a::aaa98`**, and `my_t` binds `aaa98`'s `int` where the base says `bit` — **the law is about the NAME, not the kind**; `bbb98`'s own uses stay on `bbb98` | FIXED 3 BROKE 0 | FIXED 2 BROKE 0 |
| `g98_a2_fence.sv` | **THE FENCE** — a name declared by exactly ONE class | binds the declaring class | **FIXED 0 BROKE 0 STILL 0** | FIXED 0 BROKE 0 |
| `g98_a3_homes.sv` | a PACKAGE-level and a `$unit`-level typedef of the same name racing a class's own | `apkg98::pkgwin_t` (**byte**) and the `$unit` `int` both BEAT the class — groups 1 and 0 precede group 4 | FIXED 1 BROKE 0 | FIXED 1 BROKE 0 |
| `g98_a4_order.sv` | four classes in three packages declaring `rank_t`; the reference in the last; the QUALIFIED spelling beside it | the winner is **`apk98::w9cls98`**, the smallest FULLY-QUALIFIED class name design-wide; the qualified `q1base98#(int)::rank_t` stays CORRECT | FIXED 1 BROKE 0 | FIXED 0 BROKE 0 |
| `g98_a5_oob.sv` | the SECOND unresolved shape: a class's OWN name in an OUT-OF-BLOCK method definition | the OOB definition's TWO io_decl copies mis-bind to `a0win98`; the in-class PROTOTYPE beside them does NOT — **NOT modelled here, residue R1** | FIXED 2 BROKE 0 | FIXED 1 BROKE 0 |
| `g98_a6_sites.sv` | a `new()` argument, THREE live specialisations of the declaring class, a module-home class, a `$unit`-home class | `new()`'s argument and the method local both bind the winner | FIXED 2 BROKE 0 STILL 0 | FIXED 0 BROKE 0 |

**`BROKE` is 0 in all 24 runs** (6 arms × 2 views × 2 scoring fields).
`a2`, the fence, moves NOTHING — the model is the identity when a name has one
meaning, which is the whole safety argument.

Golden also answers two questions this pass deliberately leaves alone: a class
PROPERTY written as an inherited typedef name gets **no typespec at all** in
golden (a bare `logic_var`), and a class-handle RETURN keeps golden's
typedef-object naming that our anonymous-return law does not model (**R2**).

## The corpus census, three-way, keyed on what the judge reads

`ct98cen.cpp` + `cen98.sh` + `join98.py`. One row per site whose typespec is a
`class_typespec` — `IODECL` / `VAR` / `RETURN` / `PARAM` / `TPARAM` / `MEMBER`,
plus `LISTING` for each entry of a `class_defn`'s `Typespecs()` vector. Key =
(SITE, OWNER's vpiFullName); value = (VpiName, **Class_defn**, alias present,
Instance) — **never the span and never the file**, because no generated
`Compare` reads them and golden legitimately locates a shared class typedef at a
different declaration.

**Calibrated golden-vs-golden FIRST**: SeqDriver's default and testflags goldens
join at **`same 11431 / DIFF 0`**, MiniAmiq's at **`same 12285 / DIFF 0`** — the
key is view-general and the instrument manufactures no cells.

```
                          DEFN                                  ALL
default/SeqDriver    cells 6092 TO-GOLDEN 8 AWAY 0   cells 6092 TO-GOLDEN 8 AWAY 0
testflags/SeqDriver  cells 6092 TO-GOLDEN 8 AWAY 0   cells 6092 TO-GOLDEN 8 AWAY 0
default/SimpleUVM    cells 4616 TO-GOLDEN 8 AWAY 0   cells 4616 TO-GOLDEN 8 AWAY 0
testflags/SimpleUVM  cells 4616 TO-GOLDEN 8 AWAY 0   cells 4616 TO-GOLDEN 8 AWAY 0
default/MiniAmiq     cells 6436 TO-GOLDEN 8 AWAY 0   cells 6436 TO-GOLDEN 8 AWAY 0
testflags/MiniAmiq   cells 6436 TO-GOLDEN 8 AWAY 0   cells 6436 TO-GOLDEN 8 AWAY 0
default/Scoreboard   cells 4619 TO-GOLDEN 8 AWAY 0   cells 4619 TO-GOLDEN 8 AWAY 0
default/BuildUVMPkg  cells 4818 TO-GOLDEN 8 AWAY 0   cells 4818 TO-GOLDEN 8 AWAY 0
testflags/BuildUVMPkg cells 4818 TO-GOLDEN 8 AWAY 0  cells 4818 TO-GOLDEN 8 AWAY 0
```

**`AWAY-GOLDEN 0` and `CHANGED-STILL 0` on all nine databases, on both the
head's field and the whole judged value: the model over-fires nowhere.**
BuildUVMPkg moves TO-GOLDEN too — its winner is a DIFFERENT class
(`uvm_pkg::uvm_abstract_component_registry` @13776:11 in the 1800.2 tree), which
is the table being computed per design rather than hard-coded.

The whole-design DEFN disagreement set on SeqDriver, measured before the patch,
is **9 keys out of 6,092** (set-valued join): the 8 socket `provider` formals
(all fixed) and `uvm_pkg::uvm_sequence_library::m_check::lib`, whose golden
multiset is `{uvm_algorithmic_comparator ×2, uvm_sequence_library ×1}` — the
OOB shape, **R1**.

## The mover set, PREDICTED BY NAME first (`PREDICT.r10uvm98.txt`)

`pred98.cpp` reads **only OUR PRISTINE databases** — never golden, never the
patched binary — and names every database in which some BARE typedef name (the
text after the last `::` of a `class_typespec`'s VpiName) has MORE THAN ONE
`Class_defn`. When a name has one meaning the first writer IS the declaration
the reference already resolves to, so a database it does not name **cannot
move**.

```
uhdm2rtlil: PREDICTED 0 / 1358 databases      <- THE FENCE, and it is NOT vacuous:
                                                 681 of the 1358 DO carry
                                                 class_typespec-typed sites
surelog   : PREDICTED 9 / 956  databases      (586 of the 956 carry such sites)
```

`byteverify SELFCHECK=1` then measured **`MOVERS 0 / 1358`** on uhdm2rtlil and
**`MOVERS 9 / 956`** on surelog — **exactly the nine predicted, zero
unpredicted**, and all nine were already `CMP_NOTEQUAL` rows:

```
default/{BuildUVMPkg,MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}
testflags/{BuildUVMPkg,MiniAmiq,SeqDriver,SimpleUVM}
```

Each mover's path-normalised, id-stripped whole-dump diff is **22 lines**
(20 on BuildUVMPkg), **the same count ORDERED and ORDER-BLIND**, except
`SeqDriver` (62/22) and `Scoreboard/default` (114/22) where the known ~50/50
COIN flipped — the law's share there is the same 22. The lines are: the eight
`\_class_typespec: (adpcm_pkg::this_type)` references moving from `199:11`
(`uvm_port_base`) to `74:11` (`uvm_algorithmic_comparator`), plus the
now-UNREACHABLE duplicate object disappearing from the dump — exactly what pass
97's README predicted would happen when R0 landed.

## Gates

`GATES.r10uvm98.txt` has the full transcript. Summary: goldens **23/0** on both
binaries and **0/23** for `/bin/false`; u2r **679/50/2** on both modes and both
binaries with `ct8rows` **PASS, 0 differing rows** against the committed
baseline AND against my own pristine sweep, and `cmds.txt` audited by binary
PATH (1458 lines each, nothing else); surelog `--mode both` with an identical
status histogram and `ct8rows` **PASS, 0 differing rows over 1588** against the
committed baseline AND against my own pristine sweep — **NO ROW CONVERTED,
nothing promoted**; `byteverify SELFCHECK=1` u2r **0/1358**, surelog **9/956**,
all nine predicted by name first and each attributed line by line; canaries
`ok=56` / `ok=9` `changed=0`, `ctcan2` PASS on both, `canaudit audited=33
UNCOVERED=0 FENCE-BREACH=0`; pins `InterfaceModPort` / `BlackParrotComplex` /
`YosysOldOr` **SAME**, `SVSwitch` **4842211c4030**, `YosysVerx`
**6ccda350c24a**, `SAME=10 MOVED=0`.

**Determinism**: the winner table walks `GenericClassDefSymbol::specializations()`,
an UNORDERED map, so the patched binary was run three times on SeqDriver —
`7a73ac1e62779043db5f0023fbaa93f2` ×3, byte-identical.

## The boundary (`BOUNDARY.r10uvm98.txt`)

From a **COPY** of the whole `tools/probe` tree, **no path filter**, `.sv`
**and** `.v`, fd-3 list, children `</dev/null`, PROCESSED asserted, rc recorded
and compared per cell, **both views**:

```
LISTED=3080 FENCED_SKIPPED=0 PROCESSED=3080 PROCESSED-ASSERT-OK
RC_PAIRS_COMPARED=6160  RC_DIFF=0  ASYMMETRIC_OUTPUT=0  MOVED=24
```

plus a second run over `r10uvm98repro` alone (arm `a6` was written after the
first run's tree copy was taken): `LISTED=6 PROCESSED=6 MOVED=10`.

**Every mover attributed, three-way against golden, BOTH views:**

| arm | verdict |
|---|---|
| own `g98_a1/a3/a4/a5/a6` (`a2`, the fence, never moves) | the law |
| `r10uvm34repro/t46a/dut.sv` | FIXED 1 BROKE 0 (def) |
| `r10uvm35repro/t47a/dut.sv` | **PASS_CMP -> PASS_CMP**, FIXED 4 BROKE 0 |
| `r10uvm35repro/t47b,t47c/dut.sv` | FIXED 1 BROKE 0 each |
| `r10uvm97repro/g97_a1_selftd.sv` | **PASS_CMP -> PASS_CMP**, FIXED 2 BROKE 0 |
| `r10v97repro/v97_c1_mixedgroup.sv` | **PASS_CMP -> PASS_CMP**, FIXED 0 **BROKE 0** — the verifier's protected regression arm |
| `r10v97repro/v97_c4_specparams.sv` | **PASS_CMP -> PASS_CMP**, FIXED 0 **BROKE 0** — the second protected arm |
| `r10v97repro/v97_c8_counts.sv` | **PASS_CMP -> PASS_CMP**, FIXED 5 BROKE 0 |

**No arm that passed `uhdm-cmp` pristine fails patched, in either view, and
`BROKE` is 0 on every one of the sixteen non-own cells.** uvm97's, buvm18/20's
and vsd11's typedef laws are all carried by these arms.

## Residues, named for the queue

**R0 — THE NEW HEAD, all seven UVM row-modes (50 lines SeqDriver/MiniAmiq,
108 SimpleUVM/Scoreboard, 1 head each).** A *different family entirely*: an
OPERATION-vs-`ref_obj` shape in `uvm_pkg::uvm_domain::jump`
(`uvm-1.2 base/uvm_domain.svh`, the `phase inside {UVM_PHASE_STARTED,
UVM_PHASE_CLEANUP}`-shaped expression at 199:38-199:101).

```
LHS  ref_obj: (uvm_pkg::uvm_domain::jump::UVM_PHASE_STARTED), id:261402, line:199:64-199:81
     |vpiParent: \_operation: id:261401, line:199:38-199:101
RHS  operation: id:25846, line:199:63-199:100, |vpiOpType:37
     |vpiParent: \_operation: id:25842, line:199:38-199:101
     |vpiOperand: ref_obj (UVM_PHASE_STARTED) @199:64-199:81
     |vpiOperand: ref_obj (UVM_PHASE_CLEANUP) @199:82-199:99
```

Golden FLATTENS the set-membership operand list into the parent operation and we
wrap it in an extra `vpiOpType:37` (`vpiListOp`) node. `head_pat_default_SeqDriver.cmp`
is the whole 50-line head.

**R1 — the OUT-OF-BLOCK half of this very law, NOT modelled.** Surelog compiles
`function bit cls::m(own_td_t p);` with the enclosing PACKAGE as the component,
so the class's own DataTypeMap is never consulted and the name mis-binds the
same way — while the in-class `extern` prototype beside it resolves correctly.
Measured on golden in arm `a5` (`oob_hot::p` = `{a0win98 ×2, b1own98 ×1}`) and
on the corpus at `uvm_pkg::uvm_sequence_library::m_check::lib`
(`{uvm_algorithmic_comparator ×2, uvm_sequence_library ×1}`, ours 3× the class's
own). It is **MASKED behind R0 today**: `m_visited` is keyed on the LHS and
golden points BOTH the socket sites and the two mis-bound `lib` copies at the
SAME object (id 317912), which the socket walk absorbs first. Modelling it needs
a per-copy decision (which of our three io_decl copies is the prototype's) that
this pass did not measure, so it was deliberately left out rather than guessed.

**R2 — a class-handle RETURN written as an inherited typedef name.** Golden
gives it the winner's typedef object, NAMED; our anonymous-return law
(§ "1986 uninstanced anonymous objects", TaskFuncEmit) gives it an unnamed mint.
Arm `a1` `inh_ret`, arm `a5` `c2der98::ret`. **No corpus reach**: every RETURN
disagreement on SeqDriver is the pre-existing `new` family (golden gives
`new`'s Return a class_typespec, we give it none), 21 keys.

**R3 — the class-typedef `vpiInstance` family** (pass 97's R1, unchanged and
untouched): golden carries `vpiInstance -> package uvm_pkg` on the eight aliased
`uvm_pkg` class-typedef clones, we carry the TEST package. Now the largest of
the `FIELD=ALL` STILL counts.

**R4 — a `$unit`-level winner is not applied.** When the first writer lives in a
compilation unit (arm `a3` `unit_t`), `fwWinnerTs98` finds no registered
typespec object for it and the hook falls through to the pristine behaviour —
a NO-OP, never a wrong bind. Golden's object there also carries a
`Typedef_alias` we do not mint. No corpus reach.

**R5 — a class PROPERTY written as an inherited typedef name** gets NO typespec
at all in golden (a bare `logic_var`, arm `a1` `inh_prop`); ours types it. Not
this family; recorded because the arm shows it.

## Files

```
ct98cen.cpp    the class-typespec BIND census (build line at the top).
               CEN98_ALL=1 widens it from class_typespec-typed sites to EVERY
               typespec kind — needed for the grid, where `typedef int my_t;`
               moves and never produces a class_typespec.
join98.py      the multiset join, key = (SITE, OWNER), --field DEFN|ALL|...
cen98.sh       run the census three-way (golden / pristine / patched) over a
               pair of verify_golden workdirs, golden read from each workdir's
               OWN cmds.txt
pred98.cpp     the a-priori mover predictor, from OUR PRISTINE databases only
predict98.sh   run it over a workdir and name every (mode, test) that CAN move
three98.sh     three-way arm scorer, golden / pristine / patched, rc recorded,
               FIELD=DEFN|ALL
attrib98.sh    attribute one mover: path-normalised id-stripped whole-dump diff,
               ORDERED and ORDER-BLIND
bound98.sh     the wide boundary gate (fd-3 list, children </dev/null,
               PROCESSED asserted, per-cell rc compared, both views, no path
               filter, .sv AND .v)
g98_a1..a6     the six golden arms
CENSUS / GRID / GATES / BOUNDARY / PREDICT .r10uvm98.txt   the measurements
head_pris_default_SeqDriver.head60.cmp   the OLD head (first 60 of 99,202)
head_pat_default_SeqDriver.cmp           the NEW head, whole (50 lines) = R0
byteverify.sh canaries.sh ctcan2.sh canaudit.sh ct8rows.sh rowheads.sh pins98.sh
               carried forward unchanged from r10uvm97repro / r10oth{4,8}repro
```
