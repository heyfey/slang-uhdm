# r10buvm3 — `§ aggMemberAggTdSharesListing3`: the **BuildUVMPkg head CLEARED on BOTH modes** (94 cmp lines → **34**), **ONE cell** moved in a 1.08 M-line database, and the root cause is a **GLOBAL FLAG THAT LEAKS**

**FIRST LINE, as the standing rules demand.** `BuildUVMPkg` **DID NOT CONVERT**:
`CMP_NOTEQUAL` before and after, in both modes, and no conversion was expected.
`results/gate_uhdm2rtlil.csv` (**731** rows) and `results/golden_surelog.csv`
(**1588** rows) are **byte-identical to the committed baselines** — whole ROW,
dump column included — **0 differing ROWS on both**. I did not promote any CSV.

**SECOND LINE.** The briefed head is **GONE from BOTH `BuildUVMPkg` row-modes**,
and the two modes' `uhdm-cmp` outputs are **byte-identical to each other**
before and after. The head was

```
LHS golden: struct_typespec (uvm_pkg::m_uvm_factory_type_pair_t), id:5567,
            line:11947:40, endln:11947:65   (a NAMED, package-listed struct typespec)
RHS ours  : logic_typespec , id:18577, line:11965:5, endln:11965:30
            |vpiParent: typespec_member (orig) @11965:31-11965:35
```

and it is now the **same object on both sides**: golden's listing typespec,
bound through `uvm_default_factory::m_inst_typename_alias_t`'s member `orig`.
`BuildUVMPkg` 94 → **34** cmp lines, **both modes**.

**THIRD LINE, and it is the finding worth more than the patch.** The defect is
not in any typespec rule. `buildClassTypedefTs` sets the **GLOBAL**
`bypassTypedefShare = true` around the *whole* `buildStructTs` / `buildUnionTs`
call for a class-scope aggregate typedef. That flag exists for the typedef's
**own target type** (a chained `typedef other_td_t f_t;` must mint its own
object rather than share `other_td_t`'s) — but it is a member of the exporter,
not a parameter, so it **leaked into every MEMBER the aggregate declares**.
`makeTypespec`'s share is gated on `!bypassTypedefShare`, so a member written
with a struct typedef's name **fell through the entire function** and came back
as the generic tail's loc-only `logic_typespec` spanning the written type name.
The fix does not add a rule: it **lifts the ban for exactly the members the ban
was never meant to cover**, so `makeTypespec` runs its own, already-correct
share (including its DEF-vs-ELABORATED listing choice and
`§ pkgTdRangeViewFold18`'s `defClone` exception).

**FOURTH LINE — a claim in my own brief that I REFUTED before writing code.**
The brief proposed this head might be the residue of pass 73's
`§ classScopedTypedefPropIsBareLogicVar73` (a class-scoped typedef *property*
emitted as a bare logic var). **It is not.** Pass 73's shape is a **VARIABLE**;
this head is a **`typespec_member`**, one level inside the typedef's own body,
and the two go through different code. Arm `a3_overfire.sv` carries pass-73's
shape (`class plain`, `us_t m_direct; ps_t m_pdirect;`) as a CONTROL: those
cells read `logic_var` where golden reads `struct_var` **on both binaries,
unchanged** — pass 73's residue is still there, untouched, exactly as it should
be.

**FIFTH LINE — a second law I wrote, MEASURED, and then DELETED.** The same
construct has a second divergence: our member `ref_typespec` fullnames lose the
package qualifier (`uvm_default_factory::m_inst_typename_alias_t::orig` vs
golden's `uvm_pkg::…`), because the two callers of `buildClassTypedefTs` pass
**different display names** and which one gets there first is a build-order
coin. I implemented the obvious fix (make the on-demand caller ask
`classDefnFor` for the class_defn's own `VpiName`), built it, and measured it:
the patched UVM database was **byte-identical** to the one without it — the
class_defn is not registered yet at on-demand time, so the fix is **inert**. I
reverted it rather than ship dead code. Filed as **residue R1** with the reason
the naive fix cannot work.

Base **d853e76**. Worktree `/tmp/wt_r10buvm3`; the pristine control is built
from the same worktree at the base commit before any edit.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine d853e76) | `67d1e2fc290e1429b50a60a5d9b02f8c` | my own build of the base commit |
| **SHIPPED (patched)** | **`6c040b053ce3745df0a9ff6e72d1287f`** | every number below was measured on THIS binary |

> **ONE HONESTY NOTE ABOUT THAT md5.** I first shipped
> `05872aff938685ec88b8b5b45743c4b6`, whose predicate was still named
> `aggMemberIsSharedStructTd3` while it had already been widened to unions — the
> exact "the citation does not cover what it claims" trap this campaign keeps
> losing passes to. Renaming it to `aggMemberIsSharedAggTd3` changes the mangled
> symbol and therefore the binary, so **every gate below was re-run on the
> renamed binary rather than inherited.** The two binaries were also proved
> behaviourally identical first — all **347** sd-family cells and the full
> `uvm_pkg.sv` database compare **byte-identical** between them — but a proof
> is not a re-run, so the sweeps were re-run too.

BUILD DIR (absolute): `/tmp/wt_r10buvm3/build`, `-j 2`, `CMAKE_BUILD_TYPE=Release`,
`/opt/rh/gcc-toolset-14/root/usr/bin/c++`. `[100%] Linking CXX executable
slang-uhdm` **and** `[100%] Built target slang_uhdm` were each grep-counted = 1
and `error:` counted = 0 in each build log before any md5 was taken; each md5
was asserted against `^[0-9a-f]{32}$` in its own command.

> **CONTROL ANCHOR, and its caveat stated up front.** The main tree's
> `build/slang-uhdm` is **also** `67d1e2fc290e1429b50a60a5d9b02f8c`, and
> `git diff --stat d853e76 HEAD -- src/` is **EMPTY** (the ~10 landings since
> the base are probe/README-only), so that agreement is real rather than
> lucky. It is still a **shared mutable object** (r10buvm2's verifier was
> burned by exactly this), so the control every number below leans on is **my
> own build in my own worktree**, not that binary.

`git stash` was never used. `results/*.csv` were only ever READ. slang was not
patched. `GOLDEN_DEFER` was left **UNSET** and echoed as `[UNSET]` at the sweep
launch. The four slang-fenced tests (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) were never dispatched — `canaudit.sh` proves it
mechanically (**FENCE-BREACH=0**).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script
in this directory.

---

## 0. THE LAW

### § aggMemberAggTdSharesListing3

*A **member of an aggregate typedef declared inside a CLASS**, whose written
type names a **STRUCT or UNION typedef**, binds that typedef's **OWN LISTING
TYPESPEC** — the same object the package's `vpiTypedef` entry holds — through
its `ref_typespec`'s `vpiActual`. It does **not** mint a fresh object, and it is
**not** affected by `bypassTypedefShare`, which `buildClassTypedefTs` holds for
the typedef's own target type and which has no business reaching the members.*

This is `§ classPropElemTsFollowsScalarTd9`'s law ("the element typespec is the
typedef's object; the typedef binds the LISTING") **one level down**, at a
`typespec_member` instead of a variable.

The predicate is `UhdmExporter::aggMemberIsSharedAggTd3`
(`src/TypeEmit.cpp`), called at **BOTH** member loops that exist —
`buildStructTs` and `buildUnionTs` — and it lifts the ban for that one
`makeTypespec` call only:

```cpp
bool unban3 = bypassTypedefShare && aggMemberIsSharedAggTd3(fm);
if (unban3) bypassTypedefShare = false;
fts = makeTypespec(fm, memberTypeSyn);
if (unban3) bypassTypedefShare = true;
```

**THREE GATE HALVES, each measured on arm `a2_kindgrid.sv` (§2.2):**

1. the member's **written** type must be a `TypeAlias` — an anonymous inline
   `struct {int z;} c_anon;` member keeps its own fresh object (**EQ on both
   binaries**);
2. its canonical type must be a **struct or union** — the two kinds whose
   listing object this pair of builders produces. The vector (`c_vec`),
   alias-of-alias (`c_val`), class-handle (`c_kh`) and plain-vector (`c_lg`)
   members all have their own arms and are **EQ on both binaries**; the enum
   (`c_en`) and unpacked-array (`c_arr`) members are **NE on both binaries**
   (residues R2/R3 — golden gives them the listing too, but their existing arms
   mint CLONES in other contexts and widening the gate to them is a different
   law with a different clone question);
3. the listing object must already exist and be a **NAMED** `struct_typespec`
   or `union_typespec` — an unnamed one is an anonymous nested build, not a
   listing.

**The returned object is a REGISTERED listing typespec**, so
`§ sharedAliasNoStamp41` applies unchanged: this arm adds a **SHARER**, and no
caller stamps or re-spans it. Proven by the corpus delta in §3.1 — the shared
object's own line is untouched in the patched dump.

---

## 1. THE CORPUS: ONE CELL, AND IT IS THE HEAD

### 1.1 PREDICTION, made and written down BEFORE the gates

`predict.py` (this directory) is a source-text predictor for the law's
population: class spans → aggregate typedefs inside them → member lines whose
leading type identifier is a struct/union typedef name. It is honest about
being loose in both directions and it says so in its own header.

> **The first spelling of its `TD` regex used `[^;]*?` to reach the closing
> brace. A struct body is FULL of semicolons, so it could never match, and the
> predictor reported ZERO member-cells on a corpus that provably has one.** A
> predictor that reads clean because its regex cannot match is the worst kind
> of instrument; the fix is in the file with that note attached.

| corpus root | files | member-cells |
|---|---|---|
| `Surelog/tests` + `Surelog/third_party/tests` + `uhdm2rtlil/test` | 0 | **0** |
| `Surelog/third_party/UVM/1800.2-2017-1.0` | 2 (`pp_output/uvm_pkg.sv`, `src/base/uvm_factory.svh`) | **1** — `m_inst_typename_alias_t :: m_uvm_factory_type_pair_t orig` |
| `Surelog/third_party/UVM/uvm-1.2` | 0 | **0** (`m_inst_typename_alias_t` does not exist in uvm-1.2 — grepped) |

**PREDICTED MOVERS:** `BuildUVMPkg` (both modes) and any other row that
compiles the 1800.2 `uvm_pkg.sv` and produces a database. **PREDICTED
NON-MOVERS:** the entire `uhdm2rtlil` corpus (**0** cells), and
`SimpleUVM` / `Scoreboard` / `SeqDriver`, which are uvm-1.2 rows.

Six `.sl` files reference `1800.2-2017-1.0`: `BuildUVMPkg`, `CoresSweRV`,
`CoresSweRVMP`, `Monitor`, `Opentitan`, `Earlgrey`.

### 1.2 THE HEAD, BOTH MODES

`rowheads.sh` on my own patched sweep workdir:

| TEST | MODE | CMPLINES pristine | CMPLINES patched | HEADS |
|---|---|---|---|---|
| BuildUVMPkg | default | 94 | **34** | 1 |
| BuildUVMPkg | testflags | 94 | **34** | 1 |
| SimpleUVM | default / testflags | 60 | 60 | 1 |
| Scoreboard | default | 60 | 60 | 1 |
| SeqDriver | default / testflags | 60 | 60 | 1 |

(`Scoreboard/testflags` has no database in either sweep — `SKIP-NOFILE`, counted
by the script, pre-existing on both binaries.)

`cmp -s BuildUVMPkg.default.cmp BuildUVMPkg.testflags.cmp` → **byte-identical**,
confirming the brief's "byte-identical DBs across modes" for this row.

### 1.3 THE DESIGN-WIDE DELTA: FOUR DUMP LINES

Direct run of both binaries on `UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv
--single-unit`, `uhdm-dump | sed 1d`, **1 075 764 → 1 075 761 lines**:

```
-          \_logic_typespec: , line:11965:5, endln:11965:30
+          \_struct_typespec: (uvm_pkg::m_uvm_factory_type_pair_t), line:11401:9, endln:11402:49
-\_logic_typespec: , line:11965:5, endln:11965:30
-  |vpiParent:
-  \_typespec_member: (orig), line:11965:31, endln:11965:35
```

That is the **whole** movement in a 1.08 M-line database: the member binds the
listing, and the now-unreferenced fresh object stops being emitted.
`msdist.sh` (resync-immune multiset distance to golden) **76548 → 76547**.

---

## 2. THE ARMS

All arms are run by `ct3arm.sh` (LHS golden = Surelog `-parse -nocache`, RHS
ours) and scored by `pndiff.sh`, which **NORMALIZES THE WORKDIR PATH OUT** of
both dumps before diffing — `uhdm-dump` embeds the absolute path of every source
file, and an unnormalized pristine-vs-patched diff reads as a hundred-line
over-fire that is entirely the two scratch directory names. `pndiff.sh` also
asserts that the two runs' GOLDEN dumps are equal after normalization, so a
mis-set-up comparison is fatal rather than green.

`cells.py` is the judge for the grids: a **span-keyed** table of every
`typespec_member`'s resolved `vpiActual`, golden beside ours, EQ/NE per cell.
Per-shape aggregation masks named lines; a span-keyed cell table cannot.

> **`cells.py`'s first version reported `None` for every cell** — its "stop at
> the next `typespec_member`" test fired on the **`vpiParent` back-reference**
> the nested `ref_typespec` carries to the member itself. A table of `None`s
> compares EQ everywhere and reads exactly like a clean grid. The fix (compare
> INDENT, not text) is in the file with that note attached.

### 2.1 `a1_member.sv` — the head shape, reduced

The head reduced to 47 lines: a package unpacked struct typedef `pair_t` and its
packed twin `ppair_t`, used as members of a **class-scope** struct typedef.

| golden-vs-ours dump content | pristine | patched |
|---|---|---|
| `a1_member` | 90 | **80** |

Movers (both to golden's exact object, span for span):

```
orig  @20:12  logic_typespec @20:5-20:11  ->  struct_typespec (p::pair_t)  @8:9-9:37
porig @28:13  logic_typespec @28:5-28:12  ->  struct_typespec (p::ppair_t) @11:9-12:39
```

### 2.2 `a2_kindgrid.sv` — the MEMBER-KIND grid (24 cells)

`cells.py`, patched binary. **NE=7 → NE=6** is the wrong summary; the table is:

| cell | member kind | golden | ours (pristine) | ours (patched) |
|---|---|---|---|---|
| `c_us` | **unpacked struct td** | `struct_typespec (q::us_t)` | `logic_typespec` | **EQ** |
| `c_ps` | **packed struct td** | `struct_typespec (q::ps_t)` | `logic_typespec` | **EQ** |
| `c_un` | **union td** | `union_typespec (q::un_t)` | `logic_typespec` | **EQ** |
| `c_local` | **class-LOCAL struct td** | `struct_typespec (local_t)` | `logic_typespec` | **EQ** |
| `c_en` | enum td | `enum_typespec (q::en_t)` | `bit_typespec` | NE (**R2**, unchanged) |
| `c_arr` | unpacked-array td | `array_typespec (arr_t)` | `array_typespec` (unnamed) | NE (**R3**, unchanged) |
| `c_vec` | vector td | `logic_typespec (vec_t)` | = | EQ both |
| `c_val` | alias-of-alias | `logic_typespec (q::vecal_t)` | = | EQ both |
| `c_kh` | class handle | `class_typespec (kh)` | = | EQ both |
| `c_lg` | anonymous vector | `logic_typespec` | = | EQ both |
| `c_anon` | anonymous inline struct | `struct_typespec` (unnamed) | = | EQ both |
| `c_s`, `k`, `z`, `n*` | string / int | = | = | EQ both |
| `a`,`b`,`u`,`v` | members of the **PACKAGE-scope** typedefs | = | = | EQ both |
| `u_ps`,`u_un`,`u_vec2`,`u_lg` | members of a **class-scope UNION typedef** | present | **ours has no `vpiActual` at all** | NE (**R4**, unchanged) |

**Four movers, all landing exactly on golden's object; eleven controls that do
not move; three residues that do not move either.**

### 2.3 `a3_overfire.sv` — the positions the law must NOT reach

Package-scope struct and union typedefs with struct-typedef members; a
package-scope struct variable; a **module**-scope struct typedef with
struct-typedef members (no class, so no `bypassTypedefShare`); pass 73's
class-property shape.

| golden-vs-ours dump content | pristine | patched |
|---|---|---|
| `a3_overfire` | 125 | **120** |

The **only** movement is a cell the law DOES name and I put in this file on
purpose: `pc #(int W)::gbox_t::g_us` — a **parameterized** class's nested struct
typedef. `logic_typespec @27:19-23` → `struct_typespec (r::us_t) @5:9-5:34`,
which is golden's object. **Every other cell in the file, including all four
package-scope aggregate members, the module-scope ones and pass 73's
`m_direct`/`m_pdirect`, is byte-identical between the two binaries.**

### 2.4 `v1_tdorder.sv` — the BUILD-ORDER axis

`buildClassTypedefTs` runs either **on demand** (from `makeTypespec`, mid
variable emission) or **in order** (from `emitClassTypedefs`). This arm forces
three different orders for the same member shape: an in-order class (`f1`), a
class forced on demand by an earlier-sorted class's property (`f2` via
`a_first`), and a class whose own function local references its nested typedef
(`f3`).

| | pristine | patched |
|---|---|---|
| golden-vs-ours content | 59 | **44** |
| `cells.py` NE | 3 | **0 — every cell EQ** |

All three orders bind the same listing object `struct_typespec (s3::pr_t)
@12:9-12:34`. **The law is build-order independent**; residue R1's name prefix
is not, which is exactly why R1 is filed separately.

---

## 3. THE FIVE GATES

### GATE 1 — BUILD

Both md5s in the header. **DETERMINISM** (`detcheck.sh`, patched binary, 3 runs
each): `a1_member.sv` → **1 distinct hash**, 0 NO_OUTPUT; `a2_kindgrid.sv` →
**1 distinct hash**, 0 NO_OUTPUT.

### GATE 2 — GOLDENS

`SLANG_UHDM=<patched> tests/check_goldens.sh` → **PASS 23 / FAIL 0**.
Negative control `SLANG_UHDM=/bin/false` → **PASS 0 / FAIL 23**.

### GATE 3 — uhdm2rtlil

Both binaries, `--mode testflags --jobs 2`, own `--out`/`--workdir`, `cmds.txt`
binary re-verified by `sweeps.sh` after each sweep.

| | CMP_EQUAL | SLANG_REJECT | SURELOG_FAIL |
|---|---|---|---|
| pristine | 679 | 50 | 2 |
| **patched** | **679** | **50** | **2** |

`ct8rows.sh <committed baseline> <fresh>` (**baseline first**), whole ROW
including the dump column: **0 differing ROWS / 731** for **both** binaries.
`canaries.sh` ok=8 changed=0 absent=0; `ctcan2.sh EXPECT_UNKNOWN=6` ok=1
changed=0 absent=0 → **PASS**.

### GATE 4 — surelog, `--mode both`

`ct8rows.sh` against `results/golden_surelog.csv`: **0 differing ROWS / 1588**,
whole row, dump column included. Status histograms identical to the baseline in
both modes (default 469 EQ / 11 NEQ / 5 DEFERRED / 284 REJECT / 25 SL_FAIL;
testflags 465 / 8 / 5 / 3 NO_DATABASE / 1 NO_UHDM / 286 / 23 / 1 TIMEOUT /
2 UNTRANSLATABLE) and so are both dump-column histograms.
`canaries.sh` ok=52 changed=0 absent=0; `ctcan2.sh EXPECT_UNKNOWN=1` ok=58
changed=0 absent=0 → **PASS**. `canaudit.sh` audited=29 **UNCOVERED=0
FENCE-BREACH=0**.

### GATE 5 — BYTE VERIFIER

`byteverify.sh` with **both** negative controls.

| corpus | databases | **MOVERS** | SELFCHECK | SELFCHECK1 |
|---|---|---|---|---|
| uhdm2rtlil (testflags) | 679 = 679, PATH_SETS_IDENTICAL | **0** | 678/679 flagged ✔ | 1 = 1 corrupt + 0 real ✔ |
| surelog (both modes) | 953 = 953, PATH_SETS_IDENTICAL | **3** — see below | 952/953 flagged ✔ | 4 = 1 corrupt + 3 real ✔ |

**EVERY MOVER NAMED AND ATTRIBUTED. THERE ARE THREE, AND ONLY TWO ARE MINE.**

```
MOVER ./default/BuildUVMPkg-bf853d43/slang.uhdm    patched=13e28cc8f10f pristine=7b0a179176dc
MOVER ./testflags/BuildUVMPkg-bf853d43/slang.uhdm  patched=13e28cc8f10f pristine=7b0a179176dc
MOVER ./default/Scoreboard-59431470/slang.uhdm     patched=39b16b051945 pristine=26b11f4c480c
```

* **The two `BuildUVMPkg` movers are the patch**, attributed to
  `§ aggMemberAggTdSharesListing3` firing on the single corpus cell
  `uvm_default_factory::m_inst_typename_alias_t::orig`; §1.3 shows the four-line
  dump delta that IS the difference between those md5s. The two modes' patched
  databases share an md5 prefix — **byte-identical across modes**, as the brief
  said this row is. **DETERMINISM PROVED, not assumed**: `detcheck.sh` on
  `uvm_pkg.sv --single-unit`, 3 runs each, gives **1 distinct hash on the
  pristine binary and 1 on the patched one**.

* **The `Scoreboard/default` mover is NOT the patch — it is the campaign's known
  emitter nondeterminism**, and I did not attribute it by assertion. Three
  independent facts:
  1. the **FIRST** patched sweep (binary `05872aff…`) produced Scoreboard
     `26b11f4c480c` — **identical to the pristine sweep** and to the
     pre-existing `/tmp/ctl_wd_sl_d853e76` control workdir. The two patched
     sweeps disagree **with each other** on this row;
  2. `scbdet.sh` (this directory) runs Scoreboard's exact command line six times
     on **ONE** binary: the **PRISTINE** binary alone yields **3 distinct
     hashes** (2+2+2), and the patched one yields **3 distinct hashes**
     (3+1+2). A row that produces three answers from one unchanged binary
     cannot be evidence about a patch;
  3. `Scoreboard`'s CSV row is byte-identical to the committed baseline in every
     sweep (GATE 4), so nothing about its status or dump column moved either.

  This is the memory note *"Emitter nondeterminism — SourceLocation compares
  across macro buffers flip per run under parallel parse"*, reproduced here on
  demand. It is **pre-existing and unrelated**, and `MOVERS: 2 / 953` would have
  been the honest headline number had the flake not landed on this particular
  run — which is exactly why the flake is reported rather than re-rolled away.

**THE PREDICTION'S OTHER FIVE CANDIDATES, RESOLVED MECHANICALLY.** §1.1
predicted movement in any row compiling the 1800.2 `uvm_pkg.sv` *that produces a
database*. The other five all fail that clause, and I checked rather than
assumed:

| row | default | testflags | databases in the sweep |
|---|---|---|---|
| CoresSweRV | SURELOG_FAIL | SLANG_REJECT | **0** |
| CoresSweRVMP | SURELOG_FAIL | SLANG_REJECT | **0** |
| Monitor | SLANG_REJECT | SLANG_REJECT | **0** |
| Opentitan | SLANG_REJECT | SLANG_REJECT | **0** |
| Earlgrey | SLANG_REJECT | SLANG_REJECT | **0** |

So the prediction resolves to **exactly `BuildUVMPkg` × 2**, which is exactly
what the verifier found — plus one nondeterministic flake the prediction could
not have named and which the controls above disown.

### 3.1 THE sd-FAMILY BOUNDARY

`sdbound.sh` runs **every** `.sv` cell in the committed
`tools/probe/r10sd{8,9,10,11,12}repro/{grid*,vgrid*,qgrid*}` directories on both
binaries and compares the **DATABASE BYTES**. That is a superset of all five
directories' bespoke scorers: equal bytes means every element-kind table,
claim/reach table and slot table any of them could build is equal too.

**347 cells, MOVERS = 0**, NO_OUTPUT(both) = 4 (`vgrid11/v2_param_owner.sv` and
`vgrid11/v6_unit_scope.sv`, each appearing under both sd11 and sd12 — pre-existing
on **both** binaries). Comparator negative control: a single flipped byte is
seen. `r10sd12repro/ct12grid.sh` was also run natively with `PRIS`/`PATCHED`:
**5 cells, 0 differing** on all three of its measures.

---

## 4. THE NEW HEAD — R0

`BuildUVMPkg`, both modes, 34 cmp lines, **byte-identical between the modes**:

```
LHS golden: ref_obj (uvm_pkg::uvm_default_factory::set_type_override_by_type::original_type),
            id:5905, line:12509:31, endln:12509:44
            |vpiParent: method_func_call (new), id:5904
            |vpiActual: io_decl (original_type) @12450:82-12450:95
RHS ours  : constant , id:19244, line:12370:39, endln:12370:41
            |vpiParent: method_func_call (new), id:19243
            |vpiDecompile:""  |STRING:  |vpiConstType:6
```

**CHARACTERIZED, not just quoted.** The source is `uvm_pkg.sv:12509`:

```systemverilog
override = new(.orig_type(original_type),
               .orig_type_name(original_type.get_type_name()),
               .ovrd_type(override_type), ...);
```

against `uvm_factory_override::new` at `uvm_pkg.sv:12370`:

```systemverilog
function new (string full_inst_path="", string orig_type_name="",
              uvm_object_wrapper orig_type=null, ...);
```

* **golden's `vpiArgument` list is the WRITTEN list, in WRITTEN ORDER, actuals
  only**: `[ref_obj original_type @12509:31, hier_path
  original_type.get_type_name @12510:36, …]`.
* **ours is slang's canonical FORMAL-ORDER list with DEFAULTS FILLED IN**:
  `[constant "" @12370:39 (the `full_inst_path` default, from the DECLARATION),
  hier_path original_type.get_type_name, ref_obj original_type, ref_obj
  override_type, …]`.

So R0 is: **a constructor call written with NAMED arguments must be emitted as
the written argument list in source order, never as the elaborated
formal-ordered list with defaults**. Its first unequal pair is argument 0.
`BuildUVMPkg` is **NOT** on the shared five-row head and did **NOT** pass — it
has moved to its own, new, cleanly-characterized head.

---

## 5. RESIDUES

**R1 — the class-typedef ALIAS PREFIX is a BUILD-ORDER COIN.**
`buildClassTypedefTs`'s `clsName` becomes `syntaxRefPrefix`, the `aliasFull`
handed to `buildStructTs`, and pass 50's `Typedef_alias` fullname. The in-order
caller (`emitClassTypedefs`) passes the class_defn's **qualified** `VpiName`;
the two on-demand callers pass the **bare** slang symbol name. Golden is
qualified in every cell measured (`p::f::alias_t::orig`,
`uvm_pkg::uvm_default_factory::m_inst_typename_alias_t::orig`, and pass 50's own
committed witness `uvm_pkg::uvm_pool::this_type`). **The obvious fix is inert
and I proved it**: making the on-demand callers ask `classDefnFor(cls)` for the
class_defn's name produced a **byte-identical** UVM database, because the
class_defn is not registered yet when the on-demand path runs. A real fix must
RECONSTRUCT the display name (`pkg::cls`, `work@cls`, class-nested unknown), and
that is a name change with wide latent reach — its own measured pass.
`uhdm-cmp` does not compare `ref_typespec::VpiFullName` (proved here: the UVM
head walked straight past seven such mismatches), so R1 can move bytes but can
never convert a row.

**R2 — an ENUM typedef member of a class-scope aggregate typedef.**
`a2_kindgrid` `c_en`: golden `enum_typespec (q::en_t) @12:1-12:55` (the
listing), ours `bit_typespec @25:5-25:9`. Deliberately outside the gate: the
enum member path already mints CLONES under `structCloneMemberRefParent`, and
choosing between clone and share is a different law.

**R3 — an UNPACKED-ARRAY typedef member.** `c_arr`: golden
`array_typespec (arr_t) @15:9-15:59`, ours an unnamed `array_typespec`. Same
reason as R2.

**R4 — a class-scope UNION TYPEDEF is never built.**
`buildClassTypedefTs`'s aggregate branch lists `UnpackedStructType`,
`PackedStructType`, `FixedSizeUnpackedArrayType`, `PackedArrayType`,
`ScalarType` and `PredefinedIntegerType` — **`PackedUnionType` and
`UnpackedUnionType` are absent**, so a `typedef union {...} u_t;` inside a class
produces no listing typespec at all and falls out at `if (!ts) continue`.
`a2_kindgrid`'s four `u_*` cells read `None` on our side for exactly this
reason, on **both** binaries. (This pass's law handles a union typedef used as a
MEMBER; it does not create the missing class-scope union LISTING.)

**R5 — the shared listing object's own SPAN.** Golden's
`m_uvm_factory_type_pair_t` typespec is spanned at its **first USE**
(`11947:40-11947:65`, the `m_matches_type_pair` argument); ours is spanned at
the **typedef declaration** (`11401:9-11402:49`). Both sides now bind the SAME
object and `uhdm-cmp` walked past it, so `struct_typespec::Compare` does not
read line numbers — but the spans do differ and a dump comparison sees it. Not
touched here: re-spanning a shared listing object is precisely
`§ sharedAliasNoStamp41`'s forbidden move.

**R6 — a `class_typespec` member of a PACKAGE-scope struct typedef carries a
`vpiParent` golden does not.** `a1_member` `class_typespec (ow) @8:17-8:19`:
golden has no `vpiParent`, ours parents it at `typespec_member (m_type)`.
Present on **both** binaries, unchanged by this pass.

---

## 6. FILES

| file | what it is |
|---|---|
| `a1_member.sv` | the head shape reduced (unpacked + packed struct td members) |
| `a2_kindgrid.sv` | the 24-cell member-KIND grid (4 movers, 11 controls, 3 residues) |
| `a3_overfire.sv` | the positions the law must not reach + pass 73's shape |
| `v1_tdorder.sv` | the build-order axis (in-order / on-demand / function-local) |
| `ct3arm.sh` | one-arm golden-vs-ours driver |
| `pndiff.sh` | pristine-vs-patched arm delta, **workdir path normalized out** |
| `cells.py` | span-keyed `typespec_member` → resolved `vpiActual` table, EQ/NE |
| `predict.py` | corpus-wide source-text predictor for the law's population |
| `sdbound.sh` | the sd8–sd12 boundary, checked by DATABASE BYTES (347 cells) |
| `sweeps.sh` | the four sweeps, `--jobs 2`, `GOLDEN_DEFER` echoed |
| `rowheads.sh` | per-row cmp lines / head count for a named subset |
| `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the row/canary gates |
| `byteverify.sh` | the byte verifier with both negative controls |
| `detcheck.sh`, `msdist.sh` | determinism; resync-immune dump distance |
| `scbdet.sh` | the Scoreboard NONDETERMINISM control (one binary, N runs, count hashes) |
