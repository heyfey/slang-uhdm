# r10uvm136 — § `classPropPackedStructIsStructVar136` — **THE PACKED-STRUCT CLASS PROPERTY THAT CAME OUT A `bit_var`** — SimpleUVM ×2 / Scoreboard-default: the `mem_range` head CLEARED, 9 cells in 9 databases, 0 corpus rows changed

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `73d4acc` |
| pristine binary | built from a clean worktree at `73d4acc`, frozen `chmod 555` before any sweep; its `SimpleUVM/default` head log reproduces the master's `/tmp/simpleuvm_head_73d4acc.cmp` **byte for byte** (`diff` clean, ids included) |
| patched binary | frozen `chmod 555` before any sweep |
| production surface | `src/UhdmExporter.cpp` ONLY — **two `else if` arms** (and their comment) inside the class-property variable-kind decode |
| probe surface | `tools/probe/r10uvm136repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SimpleUVM default / testflags** | 64 cmp lines, head = `bit_var (uvm_pkg::uvm_reg_map_info::mem_range)` vs golden's `struct_var` | **head CLEARED** — a NEW head, a different kind at a different file and line |
| **Scoreboard default** | 64 cmp lines, the same head | **the same new head** |
| SeqDriver default / testflags | 17 cmp lines, 1 head | head log **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 80, 1 head | head log **BYTE-IDENTICAL** |
| BuildUVMPkg default / testflags | 60, 1 head (the `$bits`-over-a-call head — **not** this pass's) | head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 21302 / 21926, 1 head | head log **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this pass's own pristine sweep |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the nine **PREDICTED BY NAME** from the pristine databases before the patched sweep ran |
| the law's corpus population | 9 wrong cells (one per UVM database) | **0** |
| the law's grid population (DEF view) | 34 wrong cells | **0** — `MOVED-WRONG 0`, `AWAY 0`, one-sided sets `0/0` |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduces the master's head log
line for line (`diff` clean, object ids included). The head is
`uvm_reg_map.svh:29`:

```systemverilog
class uvm_reg_map_info;
   ...
   uvm_reg_map_addr_range mem_range;      // line 29
```

typed by the **package** typedef at `uvm_reg_model.svh:408`:

```systemverilog
typedef struct packed {
  uvm_reg_addr_t min;      // `typedef bit unsigned [`UVM_REG_ADDR_WIDTH-1:0] uvm_reg_addr_t` — 2-state
  uvm_reg_addr_t max;
  int unsigned stride;
  } uvm_reg_map_addr_range;
```

```
LHS (golden)                                            RHS (ours, pristine)
struct_var (uvm_pkg::uvm_reg_map_info::mem_range)       bit_var (uvm_pkg::uvm_reg_map_info::mem_range)
  vpiTypespec -> ref_typespec -> struct_typespec          vpiTypespec -> ref_typespec -> struct_typespec
                 (uvm_pkg::uvm_reg_map_addr_range)                       (uvm_pkg::uvm_reg_map_addr_range)
  vpiName / vpiFullName / vpiAutomatic:1 / vpiVisibility:1   ...identical...
```

**Only the UHDM CLASS of the variable object differs.** The bound
`ref_typespec`, the `struct_typespec` it resolves to, its name, its member list
and its `vpiInstance` were ALREADY golden's on every one of the nine cells (§4's
census proves it cell by cell) — which is why this pass touches no typespec
linkage at all.

`variables::Compare` is reached through `BaseClass::Compare`, whose FIRST
comparison is the object's `UhdmType()`; a `bit_var` and a `struct_var` first-fail
there, before a single field is read. That is the whole head.

The brief also named BuildUVMPkg ×2 as carrying this head. **They do not, at
`73d4acc`.** Re-measured on this pass's own pristine build, BuildUVMPkg's head in
both modes is the `$bits` over `abstractions.size()` (a sister pass's head), 60
cmp lines, and its head log is byte-identical before and after this patch. The
head this pass clears is on **three row-modes**: SimpleUVM ×2 and
Scoreboard/default. (The nine UVM databases all CARRY the wrong cell — see §4 —
but in six of them a different first-failure masks it.)

---

## 2. THE DECODED MODEL — Surelog's variable class FOLLOWS THE TYPESPEC KIND

Not a guess and not a heuristic: two mirror-image **closed dispatches** in
Surelog, both keyed on the UHDM typespec's `UhdmType()` and neither of them
looking at 2-state vs 4-state, at declaration order, or at whether a typedef was
written at all.

**(a) The NAMED-type route — `CompileHelper::getSimpleVarFromTypespec`**
(`src/DesignCompile/CompileType.cpp:78`). Its arms:

| typespec kind | variable minted | line |
|---|---|---|
| `uhdmstruct_typespec` | `MakeStruct_var` | CompileType.cpp:201 |
| `uhdmunion_typespec` | `MakeUnion_var` | CompileType.cpp:182 |
| `uhdmlogic_typespec` | `MakeLogic_var` | CompileType.cpp:159 |
| `uhdmarray_typespec` | recurse on the index typespec | CompileType.cpp:219 |
| (a `packedDimensions` list is present) | the result is WRAPPED in a `MakePacked_array_var` | CompileType.cpp:190, :206 |

It is reached for a class property from `compileVariable`'s `slStringConst`
arm (`CompileType.cpp:345` — a bare typedef name), its `paClass_scope` arm
(`:567`, `:599` — `pkg::T` and `cls::T`), and from
`ElaborationStep::makeVar_`'s `SimpleType` branch (`ElaborationStep.cpp:1852`).

**(b) The ANONYMOUS route — `makeVar_`'s `DummyType` branch**
(`ElaborationStep.cpp:1786-1791`), for `struct packed {...} p;` written inline:

```cpp
UHDM_OBJECT_TYPE ttps = tps->UhdmType();
if      (ttps == uhdmenum_typespec)   var = s.MakeEnum_var();
else if (ttps == uhdmstruct_typespec) var = s.MakeStruct_var();
else if (ttps == uhdmunion_typespec)  var = s.MakeUnion_var();
else if (ttps == uhdmpacked_array_typespec) { ... MakePacked_array_var ... }
...
else                                  var = s.MakeLogic_var();
```

The same table, read off the same field. **A packed struct is a struct_var in
golden because its TYPESPEC is a `struct_typespec` — full stop.**

**Where WE went wrong.** `UhdmExporter::emitClassDefn`'s property kind decode
asked slang's *canonical type* instead, and in slang **a packed struct IS
integral**. So the property fell into the `ct.isIntegral()` arm and the
2-state/4-state split picked the class:

```cpp
else if (ct.isIntegral()) {
    ...
    v = ct.isFourState() ? s.MakeLogic_var() : s.MakeBit_var();   // <- mem_range landed here
}
```

`uvm_reg_map_addr_range` is 2-state (`bit`-based `uvm_reg_addr_t` + `int
unsigned`), so it came out a `bit_var`; a 4-state packed struct came out a
`logic_var` (arm A cells `k02_ps4` / `k03_ps4m`). The UNPACKED struct/union
arms two lines further down were already right — the packed ones simply never
reached them.

**THE LAW.** *A class property whose canonical type is a PACKED STRUCT is a
`struct_var`, and a PACKED UNION is a `union_var` — decided ahead of the
integral arm, on the canonical kind alone, and changing nothing but the object's
UHDM class.*

Ordering, deliberately: the new arms sit **after**
§ `classScopedTypedefPropIsBareLogicVar73`, so a CLASS-qualified packed-struct
typedef stays that law's bare `logic_var` (its arm a4 cell `c_qual_pstruct`),
and **after** the `EnumType` arm, which is unaffected.

---

## 3. THE GRID — 8 arms, 96 golden cells, every dimension the brief named

Each arm is built by Surelog (golden) and by both frozen binaries, in **both
views**, censused with `cen136` and scored with `score136.py`
(`FIXED` / `STILL-WRONG` / `MOVED-WRONG` / `AWAY` + the one-sided sets).
The census key is `(SITE, IDX, property name)` — never a span, never a file:
our objects carry an empty `VpiFile` and spans are dump fidelity, not
judge-visible (RESUME §9).

| arm | dimension | cells | AGREE | FIXED | STILL-WRONG | MOVED-WRONG | AWAY | one-sided |
|---|---|---|---|---|---|---|---|---|
| `g136_a_kinds.sv` | **typedef KIND** — packed struct 2-state / 4-state / mixed, unpacked struct, packed union, unpacked union, enum, `logic [N]`, `bit [N]`, `int`, `string`, a 2-deep typedef chain, a class handle, and the ANONYMOUS packed-struct / `logic [N]` / `bit` controls | 16 | 10 | **6** | 0 | **0** | **0** | 0/0 |
| `g136_b_order.sv` | **DECLARATION ORDER / HOME of the typedef** — a typedef whose FILE LINE is larger than the using class's but whose `include` puts it in scope first (the head's own `uvm_reg_model.svh:412` shape), a same-file one, a cross-package one QUALIFIED and WILDCARD-imported, an in-class typedef, and a class declared after the typedefs | 10 | 3 | **7** | 0 | **0** | **0** | 0/0 |
| `g136_c_props.sv` | **PROPERTY KIND** — plain / `static` / `rand` / `randc` / `local` / `protected` / `const` with an initializer / fixed array / queue / dynamic / associative / multi-declarator (`c14_two, c15_three`) | 20 | 12 | **8** | 0 | **0** | **0** | 0/0 |
| `g136_d_homes.sv` | **HOMES** — `$unit` class, package class, module class (and a `$unit` typedef used from a module class), **3 instances** of the module home | 5 | 1 | **4** | 0 | **0** | **0** | 0/0 |
| `g136_e_edge.sv` | **EDGES** — virtual class, base class, extended class, PARAMETERIZED class, a `type` parameter, a NESTED class, a 3-deep typedef chain, a struct nested in a struct, a struct with an enum field, a specialized class handle | 11 | 1 | **8** | 2 | **0** | **0** | 0/0 |
| `g136_f_packedarr.sv` | **PACKED ARRAYS** — the FENCE arm: packed arrays over a struct (1-D and 2-D), a union, an ENUM, and the `bit` / `logic` / `logic`-typedef leaves that must NOT move | 9 | 4 | **1** | 4 | **0** | **0** | 0/0 |
| `g136_z_control.sv` | **THE NEGATIVE CONTROL** — 22 properties covering every kind the law must not touch (unpacked struct/union, enum, class handle, all six integer atoms, `real`, `shortreal`, `string`, `chandle`, plain vectors, all four array kinds, a virtual interface, an `event`); **not one packed struct anywhere** | 25 | **25** | 0 | 0 | **0** | **0** | 0/0 |
| `sub/g136_a_kinds.sv` | the same arm A in a SUBDIRECTORY (a top-level glob would have run nothing and printed green) | 16 | 10 | 6 | 0 | 0 | 0 | 0/0 |
| **TOTAL (DEF view, arm A counted once)** | | **96** | **56** | **34** | **6** | **0** | **0** | **0/0** |

**DEF / ELAB.** `elab136.sh` runs Surelog a SECOND time with `-elabuhdm` so the
elaborated view gets a golden of its own, and re-scores arms A / C / E / Z there:
`FIXED 22, STILL-WRONG 2, MOVED-WRONG 0, AWAY 0, ONLY-GOLDEN 0, ONLY-OURS 1`.
The single one-sided cell is a **surplus object of OURS that golden does not have
at all** (the elaborated view emits the inner class of a specialized
parameterized class twice — a PRE-EXISTING duplicate, present identically in the
pristine build); its kind changing is invisible to golden, and it is scored
one-sided rather than as an `AWAY` because there is no golden value to move away
from.

**An arm agreeing is not an arm testing.** Arm Z is the proof the gate can see:
25 cells, all agreeing before AND after, and the boundary gate reads it
`ELAB-SAME` while every packed-struct arm reads `ELAB-MOVED`. The grid also
deliberately varies names, case, digits and declaration orders (`wire_range_ps2`,
`NibblePair_ps4`, `MIN_A`/`max_b`, `PRE_RANGE_PS`, `cellSpan_F`, …) rather than
naming everything `a_t`/`b_t`/`c_t` over `A`/`B`/`C`.

### 3a. What the FENCE holds (arm F, verbatim)

| cell | written type | golden | ours, pristine AND patched |
|---|---|---|---|
| `f01_pastruct` | `cellSpan_F [1:0]` | `packed_array_var` | `bit_var` |
| `f02_pastruct2d` | `cellSpan_F [1:0][2:0]` | `packed_array_var` | `bit_var` |
| `f03_paunion` | `cellWrap_F [3:0]` | `packed_array_var` | `bit_var` (**and its typespec is a `bit_typespec`, not the `packed_array_typespec` golden binds**) |
| `f04_paenum` | `pick_e [1:0]` | `packed_array_var` | `bit_var` |
| `f05_pabit` | `bit [1:0][7:0]` | `bit_var` | `bit_var` ✔ |
| `f06_palogic` | `logic [1:0][3:0]` | `logic_var` | `logic_var` ✔ |
| `f07_patypedef` | `nib_t [2:0]` | `logic_var` | `logic_var` ✔ |
| `f08_scalarctl` | `cellSpan_F` | `struct_var` | **FIXED** by this law |
| `f09_bitvecctl` | `bit [7:0]` | `bit_var` | `bit_var` ✔ |

The packed-array half is left ALONE on purpose, and it is R0: its corpus reach is
**zero** (0 cells in 956 surelog + 1358 uhdm2rtlil databases — §4), one of its
four moving cells needs a TYPESPEC fix this pass is not making, and a code gate
that no longer matches the a-priori predictor would make the mover prediction
unfalsifiable. Golden's `packed_array_var` in this position carries **no
`vpiElement` and no `vpiRange`** — the same six fields our `bit_var` carries — so
the fix, when it comes, is again a class swap; it needs its own census and its
own arm.

---

## 4. THE CENSUS — every class-property variable in BOTH corpora

`cen136.cpp` emits one `CELL` per variable in a `class_defn`'s `vpiVariables`
(plus one `ELEM` per `array_var` element variable): the parent chain, the index
in the listing, the variable's UHDM class / name / `vpiSigned` / `vpiAutomatic` /
`vpiVisibility` / `vpiRandType` / range count, and the typespec it binds (kind,
name, `vpiInstance`, member-name list).

**Golden-vs-golden calibration FIRST**, then `wide136.sh` over every database in
a sweep, reading each row's OWN golden out of that row's `cmds.txt` (never
guessed; the cache DIRECTORY is turned into `.../golden.uhdm`, since handing a
Serializer a directory restores nothing):

| corpus | databases | databases with a golden | class-property cells whose VARIABLE CLASS disagrees |
|---|---|---|---|
| surelog | 956 | 956 | **9** |
| uhdm2rtlil | 1358 | 1358 | **0** |

and all nine are the same pair, in the same direction:

```
PAIR  9  struct_var -> bit_var
```

There is **no cell anywhere in either corpus** where golden holds a
`bit_var`/`logic_var` and we hold a `struct_var`/`union_var` — so the AWAY
direction has no population to be wrong in.

**The join is honest.** `cover136.sh` is the coverage control a multiset join
owes: it prints, per row, the golden cell count, ours, and the ONE-SIDED counts
in both directions. On all nine UVM databases:

| row | golden cells | our cells | only-golden | only-ours |
|---|---|---|---|---|
| default/SimpleUVM | 1234 | 1234 | 0 | 0 |
| default/Scoreboard | 1245 | 1245 | 0 | 0 |
| default/SeqDriver | 1349 | 1349 | 0 | 0 |
| default/MiniAmiq | 1647 | 1647 | 0 | 0 |
| default/BuildUVMPkg | 1029 | 1029 | 0 | 0 |
| testflags/SimpleUVM | 1234 | 1234 | 0 | 0 |
| testflags/SeqDriver | 1349 | 1349 | 0 | 0 |
| testflags/MiniAmiq | 1647 | 1647 | 0 | 0 |
| testflags/BuildUVMPkg | 1029 | 1029 | 0 | 0 |

11,613 cells joined, not one dropped.

---

## 5. THE PREDICTION — nine movers, BY NAME, from PRISTINE databases only

`pred136.sh` runs `cen136` over every OURS database in a sweep and flags every
class-property cell whose variable class is `bit_var`/`logic_var` while the
typespec it binds is a `struct_` / `union_` / `packed_array_typespec` — exactly
the population the law rewrites, computed **before the patched binary ever ran a
sweep**. It reads no patched artifact.

```
surelog     DBS_SCANNED=956   CELLS=9   DBS_WITH_CELLS=9
uhdm2rtlil  DBS_SCANNED=1358  CELLS=0   DBS_WITH_CELLS=0
```

The nine, named:

| database | cell |
|---|---|
| `default/BuildUVMPkg` | `uvm_pkg::uvm_reg_map_info::mem_range` — `bit_var` on `struct_typespec uvm_pkg::uvm_reg_map_addr_range` |
| `default/MiniAmiq` | the same cell |
| `default/Scoreboard` | the same cell |
| `default/SeqDriver` | the same cell |
| `default/SimpleUVM` | the same cell |
| `testflags/BuildUVMPkg` | the same cell |
| `testflags/MiniAmiq` | the same cell |
| `testflags/SeqDriver` | the same cell |
| `testflags/SimpleUVM` | the same cell |

(`Scoreboard/testflags` has no golden in the cache — `SKIP-NOFILE`, as it is for
every pass on these rows.)

**ONE property, in nine databases, is the entire corpus population of this law.**

---

## 6. THE FILES

| file | what it is |
|---|---|
| `cen136.cpp` | the census: one `CELL` per class-property variable (+ `ELEM` per array element variable) — parent chain, listing index, UHDM class, name, `vpiSigned`/`vpiAutomatic`/`vpiVisibility`/`vpiRandType`, range count, and the bound typespec's kind / name / `vpiInstance` / member-name list. Keyed without spans and without files. |
| `score136.py` | the scorer: `FIXED` / `STILL-WRONG` / `MOVED-WRONG` / `AWAY` plus the ONE-SIDED sets, over a golden / pristine / patched triple. A key golden has fewer rows at is scored one-sided (a SURPLUS object of ours), never as an `AWAY`. |
| `arm136.sh` | build ONE arm with Surelog and both frozen binaries, in both views; census each; score with the OFFICIAL `uhdm-cmp`. Copies the arm's own `*_inc*.svh` siblings by the arm's basename prefix (never a bare glob). |
| `elab136.sh` | the DEF/ELAB half: Surelog run a second time with `-elabuhdm` so the elaborated view has a golden of its own. |
| `bound136.sh` | the boundary gate: compiles EVERY `.sv` under a COPY of the arms directory, **top level AND subdirectories**, in both views, with both binaries; file list on fd 3, every child `</dev/null`, `PROCESSED` asserted against `LISTED`, scratch keyed on the RELATIVE path, and every rc printed (rc=139 is a segfault `verify_golden` would have called a `SLANG_REJECT`). |
| `pred136.sh` | the A-PRIORI mover predictor (§5) — reads pristine databases only. |
| `wide136.sh` | the wide census (§4) over every database in a sweep, golden read from each row's own `cmds.txt`. |
| `cover136.sh` | the join-coverage control (§4) — a multiset join that drops rows would report "9 disagreements" just as happily. |
| `g136_a_kinds.sv` … `g136_z_control.sv` | the eight grid arms (§3). |
| `head_pris_*_*.cmp` | the pristine head log per row-mode. The two `Earlgrey_0_1` logs are TRUNCATED to their first 120 lines with the true line count stated in the file's first two lines (their full logs are ~21k lines of cascade). |
| `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`, `rowheads.sh` | the standard gate battery, copied unmodified. |

Build the census reader with:

```
g++ -O2 -std=c++17 cen136.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen136
```

---

## 7. WHAT MOVED, AND WHAT THE NEW HEAD IS

`byteverify.sh SELFCHECK=1` against this pass's OWN pristine sweep:

```
surelog     databases patched=956  pristine=956  PATH_SETS_IDENTICAL   MOVERS 9 / 956
uhdm2rtlil  databases patched=1358 pristine=1358 PATH_SETS_IDENTICAL   MOVERS 0 / 1358
```

The nine are the nine predicted by name in §5. `attr136.sh` attributes each one
with `uhdm-dump` **path-normalised and SORTED** — order-blind, which is the only
sound attribution on `Scoreboard/default` (a ~50/50 coin per invocation, RESUME
§9). Every one of the nine reads the same:

```
2 lines OUT   <  \_bit_var:    (uvm_pkg::uvm_reg_map_info::mem_range), line:29:27, endln:29:36
2 lines IN    >  \_struct_var: (uvm_pkg::uvm_reg_map_info::mem_range), line:29:27, endln:29:36
```

A pure substitution. Every added line is one golden also emits — **AWAY 0**.
No removed line is one golden emits — **MOVED-WRONG 0**. Nothing outside the
law's own cell moved in any database.

The wide census re-run on the PATCHED surelog corpus closes the loop:

```
DBS_SCANNED=956  DBS_WITH_GOLDEN=956   KIND_DISAGREEING_CELLS=0
```

**The new head.** SimpleUVM ×2 and Scoreboard/default drop 64 -> 32 cmp lines and
first-fail on a completely different object, at a different file and line —
`uvm_reg_block.svh:1914`, the `return UVM_FRONTDOOR;` of
`uvm_reg_block::get_default_path`:

```
LHS (golden)                                RHS (ours)
constant  1914:11-1914:24                   ref_obj (…get_default_path::UVM_FRONTDOOR)
  vpiDecompile:0  vpiSize:64                  vpiParent -> return_stmt 1914:4-1914:10
  INT:0  vpiConstType:7                       vpiName:UVM_FRONTDOOR
```

i.e. golden FOLDS a returned enum constant to its value and we return an
unfolded `ref_obj`. That is **R0**.

## 8. RESIDUES

* **R0 — the returned enum constant is not folded.** `uvm_reg_block.svh:1914`
  `return UVM_FRONTDOOR;` — golden a `constant` (`vpiConstType:7`, `vpiSize:64`,
  `INT:0`, `vpiDecompile:0`), ours a `ref_obj` named after the enumerator. The
  new head on SimpleUVM ×2 and Scoreboard/default, 32 cmp lines each.
* **R1 — the packed-ARRAY class property is a `packed_array_var` in golden.**
  §3a's table: `f01_pastruct`, `f02_pastruct2d`, `f03_paunion`, `f04_paenum`
  (a struct, a 2-D struct, a union and an ENUM leaf), plus `e05_packedArr` /
  `e06_arrTypedef`. Six grid cells, **zero** corpus cells. Golden's object in
  this position carries no `vpiElement` and no `vpiRange` — the same six fields
  our `bit_var` carries — so it is again a class swap; but `f03_paunion` also
  binds the WRONG TYPESPEC on our side (`bit_typespec` where golden has
  `packed_array_typespec`), so the half needs its own census and its own arm.
* **R2 — a duplicated inner class in the ELAB view.** The elaborated view emits
  the nested class of a SPECIALIZED parameterized class twice (arm E
  `e10_innerclass`); golden emits it once. Pre-existing, identical in the
  pristine build, and invisible to every corpus row (the corpus is DEF-view for
  these tests). Scored as a one-sided cell, never as an `AWAY`.
* **Not a residue, a correction to the brief.** The brief named BuildUVMPkg ×2
  as carrying this head and put the head on five row-modes with 64 cmp lines
  each. Re-measured on this pass's own pristine build at `73d4acc`, BuildUVMPkg's
  head in both modes is the `$bits`-over-a-call head (60 cmp lines) — a sister
  pass's. This head was on **three** row-modes. All nine UVM databases carried
  the wrong `mem_range` cell; six of them had a different first failure in front
  of it.
