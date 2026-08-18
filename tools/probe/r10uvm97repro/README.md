# r10uvm97 — § `classNestedTdOneObjectPerSurelogTypedef97` — the seven-row-mode UVM head's `vpiTypedefAlias` removed, and the mis-bind behind it UNMASKED

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` are the
authorities for every number below. slang was **NOT** patched; `results/*.csv`
were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `65468af` |
| worktree | `/tmp/wt_r10uvm97` |
| pristine binary | md5 `52288f8c72dbd24e0e0fac2f130f1dfa`, frozen `chmod 555` |
| patched binary | md5 `06be7ee0142fe96780b0b631282dee00`, frozen `chmod 555` |
| production surface | `src/UhdmExporter.cpp` (one dedup inside `drainClassNestedTdGroups54` + one field at the collector) and `include/UhdmExporter.h` (the field) |
| probe surface | `tools/probe/r10uvm97repro/` only |

## READ THIS FIRST — the head MOVED, and it got BIGGER

| | pristine | patched |
|---|---|---|
| SeqDriver / SimpleUVM / Scoreboard / MiniAmiq (7 row-modes) cmp lines | **17** | **99,106 / 99,202** |
| heads (`grep -c '^LHS:'`) | 1 | **1** |
| BuildUVMPkg both modes | 29 lines / 1 head, md5 `3b9be2e42f1c` | **unchanged** |
| Earlgrey_0_1 both modes, Rggen/default | 36 lines / 1 head | **unchanged** |
| corpus rows changed | — | **0** (both corpora, both modes) |

This is **the same slot, a LATER field**. `class_typespec::Compare` runs
`typespec::Compare` (VpiName, **Typedef_alias**, Instance) and then its own
fields, ending with `SafeCompare(Class_defn)`. The pristine head died on
`Typedef_alias`; the patched one gets past it and dies on `Class_defn`, whose
operands are two whole `class_defn` objects — hence 99k lines for ONE head.

**The pass is therefore a judgement call and it is stated out loud**: it
removes a real, decoded, golden-verified difference (§ below, 9 databases,
grid FIXED 5 / BROKE 0, boundary TO-GOLDEN) and in doing so unmasks a DEEPER
mis-bind that was hiding behind it (**R0**, fully decoded below — only **9
cells** in SeqDriver's whole database). If the master would rather keep a
readable 17-line head until R0 lands, this patch can be held behind R0's pass;
R0's fix makes our duplicate object unreachable, so it clears this head from
the corpus too — but the alias itself would still be wrong (arms a1/a4 prove
it on golden with no corpus row involved).

## The law

> **§ `classNestedTdOneObjectPerSurelogTypedef97` — ONE GROUP MEMBER PER
> SOURCE DECLARATION.**
>
> Surelog compiles a parameterized class **ONCE, generically**. A
> `ClassDefinition`'s `TypeDefMap` is a `std::map<std::string, TypeDef*>`, so
> `typedef uvm_port_base #(IF) this_type;` written inside
> `virtual class uvm_port_base #(type IF=uvm_void)` is exactly **one**
> `TypeDef`, and `ElaborationStep::bindTypedefs_`
> (`src/DesignCompile/ElaborationStep.cpp:102`) gives it exactly **one**
> typespec — a bare `class_typespec` from `compileTypespec`'s
> `ClassDefinition` arm (`src/DesignCompile/CompileType.cpp:903-915`:
> `MakeClass_typespec` + `Class_defn` + `VpiName(typeName)` +
> `populateCoreMembers(type, type, ref)`), renamed to the typedef's own name by
> `ts->VpiName(typd->getName())`, with **NO `clone_tree` and NO
> `Typedef_alias`** — whatever number of specializations the design
> instantiates.
>
> The alias road is a DIFFERENT branch: `compileTypespec`'s `SimpleType` arm
> (`CompileType.cpp:880-896`, buvm18/20's decode) clones and hangs a
> `Typedef_alias` when a **TypeDef** was walked through to reach it, and
> `bindTypedefs_`'s `DataType::Category::DUMMY` branch does the same for a
> forward-declared target. **Neither is the class road**: the `ClassDefinition`
> arm returns before any clone, which is exactly why a class-handle typedef's
> alias in golden is always a SECOND, DIFFERENT declaration pointing at the
> first (§ `pkgClassTd9`, § `classNestedClassTdJoinsPkgGroup50`,
> § `classNestedClassTdGroupNoAnchor54`) and never a self-clone.
>
> slang elaborates a parameterized class **once per specialization**, so it
> hands us one `TypeAliasType` per specialization. Pass 54's collector pushed
> the SAME written declaration into `classNestedTd54` once per specialization,
> the group then had two "members", and the drain aliased copy 2 to copy 1.
> **Golden has nothing to alias**, so `typespec::Compare`'s `Typedef_alias`
> walk names ours with `LHS: <null>` — the cmp head of all seven UVM row-modes
> at `65468af`.
>
> **GATE — the identity is the DECLARING class's GENERIC class (the `ClassType`
> itself when it is not a specialization) plus the typedef's own name, keyed on
> the POINTER, never on the `surelogClassKey54` STRING.** Arm
> `g97_a5_samename.sv` REFUTES the string key: two classes both named `dup97e`,
> one per module, both spell `work@dup97e`, and golden gives their same-named
> typedefs a REAL group (a base plus an aliased clone) that a string-keyed
> dedup would silently drop.
>
> **GATE, second half — added by the ADVERSARIAL VERIFIER**
> (§ `classNestedTdDupCopiesFollowTheirDeclaration97v`; see
> `tools/probe/r10v97repro/`). The duplicate identity decides ONLY how many
> members the group really has and whether a member is a copy of the BASE's own
> declaration. Dropping the duplicates of a **non-base** member is REFUTED:
> golden has ONE object for that declaration and it **is** aliased, we have N
> copies, and nothing says which of them the class's `vpiTypedef` listing and
> its use sites read. The first cut un-aliased the LISTED copy and turned a
> PASSING database into a failing one on purpose-built golden — arms
> `v97_c1_mixedgroup.sv` / `v97_c4_specparams.sv`, official `uhdm-cmp`
> PASS -> 1 head / 17 lines, BOTH views.

## The head, decoded from the pristine cmp log first

```
LHS: <null>
RHS:
ref_typespec: (uvm_pkg::uvm_port_base::this_type), id:298130
|vpiParent:
\_class_typespec: (adpcm_pkg::this_type), id:112685, line:199:11, endln:199:24
|vpiFullName:uvm_pkg::uvm_port_base::this_type
|vpiActual:
\_class_typespec: (adpcm_pkg::this_type), id:52512, line:199:11, endln:199:24
```

`LHS: <null>` with RHS set is `BaseClass.h:194`'s SINGULAR arm
(`lhs == nullptr && rhs != nullptr`, `m_failedRhs` only), so it names a VALUE
we set that golden leaves EMPTY. The OWNER is the `class_typespec` id 112685
and the FIELD is `typespec::Compare`'s `Typedef_alias`, walked before
`Instance`. Both operands of the alias are class_typespecs with the **same
name and the same span** — the give-away that this is a self-clone of ONE
declaration, not a cross-class clone.

`uvm-1.2 base/uvm_port_base.svh:199` is `  typedef uvm_port_base #(IF) this_type;`
and columns 11..24 are the 13 characters `uvm_port_base` — the target class's
NAME token, the span both sides give the object.

### Which object, and reached through WHAT (measured, not assumed)

`ct97cen` over the pristine SeqDriver pair:

| | golden | ours |
|---|---|---|
| `class_defn` `Typespecs` LISTING rows | **742** | **742** (identical) |
| `class_typespec`s carrying a `Typedef_alias` OUTSIDE any listing | **0** | **1** |
| objects at `199:11-199:24` named `this_type` | **1** (id 318164, no alias) | **2** (52512 no alias, **112685 aliased**) |

A referrer walk (`p1`) names the reachable site exactly:

| site | golden binds | ours binds |
|---|---|---|
| `uvm_port_base::{connect,m_add_list,m_check_relationship}` formal `provider`, and every `uvm_port_base` property / local | id 318164 `this_type` @199:11, `defn=uvm_port_base` | id 52512, the same shape |
| `uvm_tlm_{b,nb}_*_socket::connect` formal `provider` — **8 sites** | id 317912 `this_type` **@74:11**, `defn=uvm_pkg::uvm_algorithmic_comparator` | **id 112685** @199:11, `defn=uvm_port_base`, **aliased** |

Those 8 sites are the only ones that CAN show the head: `m_visited` is keyed on
the **LHS**, so golden's 318164 is absorbed at the first `uvm_port_base` site
and every later comparison against it returns 0. Golden's 317912 is a
different object and is still unvisited when the sockets are walked.

## The corpus census, made BEFORE the patch, from PRISTINE databases

`ct97cen.cpp` + `cen97.sh` + `join97.py`: one row per typespec listed in a
`class_defn`'s `Typespecs()` (`SITE=LISTING`) plus one row per `class_typespec`
carrying a `Typedef_alias` anywhere else (`SITE=ALIASED`), multiset-joined on
**(SITE, OWNER, NAME, KIND)** — never on the ID and never on the SPAN (golden
and we legitimately locate a shared class typedef at different declarations,
and no generated `Compare` reads a span). The value is the JUDGED shape:
alias present / `Class_defn` / `Instance`.

```
PRISTINE, all 956 surelog databases:  keys same 5275   DIFF cells 41   dbs 9
PATCHED , all 956 surelog databases:  keys same 5275   DIFF cells 32   dbs 4
```

The nine DIFF databases are exactly the nine movers, one alias cell each:

```
default/{BuildUVMPkg,MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}
testflags/{BuildUVMPkg,MiniAmiq,SeqDriver,SimpleUVM}
```

All nine alias cells CONVERTED; `same` is unchanged at **5,275**, so the patch
**over-fires nowhere**. The 32 residual cells are 8 per database in
SeqDriver/MiniAmiq only and are a DIFFERENT, pre-existing family (**R1**): the
`vpiInstance` of the eight `uvm_pkg` class-typedef clones, golden
`package uvm_pkg`, ours `package adpcm_pkg` / `svaunit_pkg`. Untouched here,
and currently masked by R0.

## The mover set, PREDICTED BY NAME first

`pred97.cpp` + `predict97.sh` read **only OUR PRISTINE databases** and name
every `class_typespec` carrying the exact shape the patch removes: a
`Typedef_alias` whose `Actual_typespec` is another `class_typespec` with the
SAME `VpiName`, the SAME `Class_defn` and the SAME span, **and** whose alias
ref's `VpiFullName` is `<the BASE's own declaring class>::<bare name>` — the
last test is what separates it from the 53 legitimate `type_id` clones every
UVM database carries (golden has those too; without the test the raw signature
counts 54 on SimpleUVM against golden's 53 and the prediction drowns).

```
surelog:    PREDICTED 9 / 956 databases, 1 cell each   (the nine listed above)
uhdm2rtlil: PREDICTED 0 / 1358 databases              <- THE FENCE
```

**The u2r fence is total**: no uhdm2rtlil database carries the shape at all,
so no `CMP_EQUAL` row there can move — and `byteverify SELFCHECK=1` measured
`MOVERS 0 / 1358`. On surelog `byteverify` measured `MOVERS 9 / 956`, that
exact set, **zero unpredicted movers**, and all nine were already
`CMP_NOTEQUAL` rows.

Each mover's path-normalised, id-stripped whole-dump diff is **exactly 7
lines** — the removed `|vpiTypedefAlias:` and its 6-line `ref_typespec` block —
**the same count ORDERED and ORDER-BLIND**, except `Scoreboard/default`, whose
ordered diff is 127 lines and whose ORDER-BLIND diff is the same 7: the known
~50/50 COIN flipped, and the law's share of the move is 7 lines there too.

## The grid, golden-side, both views (`three97.sh`, `GRID.r10uvm97.txt`)

| arm | what it pins | def | elab |
|---|---|---|---|
| `g97_a1_selftd.sv` | the head, minimised: `typedef port97a #(IF) this_type;` inside `class port97a #(type IF)`, TWO live specializations, derived classes writing the INHERITED name as a formal | CELLS 4 OK 3 **FIXED 1** BROKE 0 STILL 0 | same |
| `g97_a2_realgroup.sv` | **NEGATIVE/FENCE** — a GENUINE group: three DISTINCT classes typedef'ing one target, plus a one-member group | CELLS 5 **all ALREADY-OK** | CELLS 7 all OK |
| `g97_a3_kinds.sv` | **NEGATIVE** — struct / enum / `int` / vector / type-parameter typedefs in a generic class with two specializations | CELLS 6 **all ALREADY-OK** | same |
| `g97_a4_plainclass.sv` | a PLAIN class's self typedef (one ClassType, no duplicate ever), plus `typedef gen97d#(int) spec97d;` and `typedef plain97d oth97d;` inside a generic class | CELLS 7 OK 5 **FIXED 2** BROKE 0 | CELLS 8 OK 6 FIXED 2 BROKE 0 |
| `g97_a5_samename.sv` | **THE DEDUP-KEY REFUTATION** — two classes named `dup97e` in two modules, same typedef name; golden groups them for real | CELLS 3 all OK | CELLS 4 OK 3 STILL 1 (pre-existing, byte-unchanged) |

`BROKE` is **0** in all ten runs. `a4` shows the law is not about `this_type`
at all: a typedef of ANOTHER class and a typedef of a SPECIALIZATION inside a
class with two specializations carry the same self-clone alias, and both are
removed.

**An independently written arm confirms it**: the wide boundary's only
non-own mover is `r10uvm35repro/t47a/dut.sv` (14 lines, both views), an arm a
PREVIOUS pass wrote for this very shape; scored three-way against golden it is
**FIXED 1 / BROKE 0 / STILL 0** — TO-GOLDEN.

## Gates

`GATES.r10uvm97.txt` has the full transcript. Summary: goldens **23/0** on both
binaries and **0/23** for `/bin/false`; u2r **679/50/2** both modes and
`ct8rows` **PASS, 0 differing rows** against the committed baseline AND against
the pristine sweep; surelog `--mode both` with the **identical status histogram**
to the pristine sweep and `ct8rows` **PASS, 0 differing rows over 1588** —
**no row converted, nothing promoted**; `byteverify SELFCHECK=1` u2r
**0 / 1358**, surelog **9 / 956**, all nine predicted by name first; canaries
`ok=56` / `ok=9` `changed=0`, `ctcan2` PASS on both, `canaudit audited=33
UNCOVERED=0 FENCE-BREACH=0`; pins `InterfaceModPort` / `BlackParrotComplex` /
`YosysOldOr` **SAME**, `SVSwitch` **4842211c4030**, `YosysVerx` **6ccda350c24a**;
wide boundary **LISTED=2958 PROCESSED=2958 PROCESSED-ASSERT-OK**,
`RC_PAIRS_COMPARED=5916`, **RC_DIFF 0**, **ASYMMETRIC_OUTPUT 0**, **MOVED=6**
(4 own arms + the 2 TO-GOLDEN cells above).

## Residues, named for the queue

**R0 — THE NEW HEAD, all seven UVM row-modes (99,106 / 99,202 cmp lines,
1 head).** An INHERITED class-typedef NAME written in a derived class binds, in
golden, to a **FOREIGN** class's typespec:

```
LHS  class_defn: (uvm_pkg::uvm_algorithmic_comparator)   <- golden
RHS  class_defn: (uvm_pkg::uvm_port_base)                <- ours
```

reached through `class_typespec::Compare`'s last field, `SafeCompare(Class_defn)`,
from the `provider` formal of `uvm_tlm_{b,nb}_*_socket::connect` — eight sites
that write the `this_type` their base `uvm_port_base` declares. Golden binds all
eight to `uvm_algorithmic_comparator::this_type`
(`comps/uvm_algorithmic_comparator.svh:74`), we bind them to
`uvm_port_base::this_type` (`base/uvm_port_base.svh:199`).

**The mechanism, read off Surelog**: Surelog does not resolve an INHERITED
typedef name inside a derived class body — it leaves an `unsupported_typespec`
placeholder and late-binds it in `ElaborationStep::bindTypedefs_` through the
`specs` map, a `std::map<std::string, typespec*>` keyed on the **BARE** typedef
name and filled **first-writer-wins** while walking `defs` in the order
FileContents → packages → modules → programs →
`design->getClassDefinitions()` (a multimap keyed on the FULLY QUALIFIED class
name). `uvm_pkg::uvm_algorithmic_comparator` is the alphabetically first
`uvm_pkg` class that declares a `this_type`, so it wins the name for the whole
design. **We must MODEL this mis-resolution, not fix it** (golden is the spec,
bugs included).

**It is a small, tight family** — measured over the WHOLE SeqDriver database
with `p4` (every `io_decl` / `variables` whose typespec resolves to a
`class_typespec`, keyed on owner fullname + span): **4,453 common sites, 9
`Class_defn` disagreements**, all nine binding to
`uvm_algorithmic_comparator` in golden (8 from the sockets, 1 from
`uvm_sequence_library`). Everything else already agrees.

**It is not a regression of this pass**: pristine and patched bind the same
objects at all nine sites (the whole-dump diff of every mover is the 7 alias
lines and nothing else). R0 was simply MASKED by the alias.

**R1 — the class-typedef `vpiInstance` family** (32 census cells: 8 per
database on SeqDriver/MiniAmiq, both modes). Golden carries
`vpiInstance -> package uvm_pkg` on the eight aliased `uvm_pkg` class-typedef
clones (`uvm_callbacks::this_type`, `uvm_derived_callbacks::this_{super,user}_type`,
`uvm_object_string_pool::this_type`, `uvm_pool::this_type`,
`uvm_sequencer::this_type`, `uvm_sequencer_param_base::this_type`,
`uvm_sequence::sequencer_t`); we carry the TEST package (`adpcm_pkg` /
`svaunit_pkg`). PRE-EXISTING and byte-identical on both binaries. Masked behind
R0 today (`typespec::Compare` reads `Instance` right after `Typedef_alias`, and
`m_visited` absorbs it while both packages are already visited).

**R2 — `g97_a5_samename.sv` elab**: we mint TWO aliased copies of
`m2_97e::dup97e::n97e` where golden has one. A DEF/ELAB duplicate of a
MODULE-nested class, not a specialization duplicate, so the pointer key does not
(and must not) collapse it. Corpus-invisible: no corpus database has two
same-named classes in two modules.

**R3 — `g97_a3_kinds.sv` cmp head (64 lines, both views, byte-unchanged by this
pass)**: pre-existing and outside this family.

## Files

```
ct97cen.cpp    the class-nested typedef census (build line at the top)
cen97.sh       run it over a whole verify_golden workdir, golden vs ours
join97.py      the multiset join, key = (SITE, OWNER, NAME, KIND)
pred97.cpp     the a-priori mover predictor, from OUR PRISTINE databases only
predict97.sh   run it over a workdir and name every (mode, test) that carries
               the shape
three97.sh     three-way arm scorer, golden / pristine / patched, rc recorded
bound97.sh     the wide boundary gate (fd-3 list, children </dev/null,
               PROCESSED asserted, per-cell rc compared, both views)
g97_a1..a5     the five golden arms
CENSUS / GRID / GATES / BOUNDARY / PREDICT .r10uvm97*.txt   the measurements
head_pris_default_SeqDriver.cmp            the head, before (17 lines)
head_pat_default_SeqDriver.head60.cmp      the head, after (first 60 lines of
                                           99,202 — R0's class_defn pair)
byteverify.sh canaries.sh ctcan2.sh canaudit.sh ct8rows.sh rowheads.sh pins97.sh
               carried forward unchanged from r10uvm96repro / r10oth{4,8}repro
```
