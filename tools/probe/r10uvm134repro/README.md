# r10uvm134 — § `foreachLoopListStopsAtFirstSelect134`

**The head cleared:** MiniAmiq (both modes, 80 cmp lines, 1 head) —
`uvm_phase.svh:1730`'s

```systemverilog
    foreach (successors[s])
      foreach (successors[s].m_predecessors[pred])
```

Golden's inner `foreach_stmt` lists **`ref_var 'successors'`** in its
`Variable()` slot, spanned at the bare identifier and bound through a
`ref_typespec` to the DECLARATION's `array_typespec` (`:1724:15-27`); we listed
the whole written reference as a `hier_path (successors[s].m_predecessors)`
whose `Path_elems` are `bit_select(successors[s])` and `ref_obj(m_predecessors)`.

```
LHS (golden):                                      RHS (ours):
ref_var: (…::successors), 1730:16-1730:26          hier_path: (successors[s].m_predecessors), 1730:16-1730:44
|vpiTypespec: ref_typespec                         |vpiActual: bit_select (successors[s])
  |vpiActual: array_typespec, 1724:15-1724:27      |             |vpiIndex: ref_obj (s)
|vpiName:successors                                |vpiActual: ref_obj (m_predecessors)
```

`foreach_stmt::Compare` (UHDM `build/generated/src/foreach_stmt.cpp`) reads
`Variable()` FIRST, before `VpiLoopVars()` and `VpiStmt()`, so the whole
80-line MiniAmiq head is that one slot.

**Head after:** MiniAmiq both modes **80 → 56**, 1 head, at
`uvm_phase.svh:1740` (`foreach (pred.m_predecessors[next_pred])` — golden's
loop variable is `int_var`/`int_typespec`, ours `class_var`; a DOTTED loop
list, a different law: **R0** below).  Every other row's head is unchanged:
SeqDriver 17, SimpleUVM 64, Scoreboard/default 64, BuildUVMPkg 60,
Earlgrey_0_1 150, Rggen/default 0.

---

## 1. The decoded model (Surelog)

`CompileStmt.cpp`'s **`paFOREACH`** arm builds the `Variable()` slot with

```c++
UHDM::any* var = compileVariable(
    component, fC, fC->Child(Ps_or_hierarchical_array_identifier),
    compileDesign, Reduce::No, for_each, nullptr, false);   // :529
```

— the whole loop-list array identifier goes to `compileVariable`, and that
function reads the node list **left to right by SIBLING TYPE only**
(`CompileType.cpp:288-311`):

```c++
NodeId Packed_dimension = fC->Sibling(variable);              // :278
if (fC->Type(variable) == VObjectType::slStringConst &&
    fC->Type(Packed_dimension) == VObjectType::slStringConst) {  // :288
  UHDM::hier_path* path = s.MakeHier_path();
  … push ref_obj(variable);  fC->populateCoreMembers(variable, variable, obj);
  while (fC->Type(Packed_dimension) == VObjectType::slStringConst) {  // :300
    … push ref_obj(Packed_dimension);  (NO populateCoreMembers)
    Packed_dimension = fC->Sibling(Packed_dimension);
  }
  path->VpiFullName(fullName);  return path;                  // :309-310
}
```

A `[` between two names is **neither `slStringConst` nor anything the loop
steps over**, so the walk stops there.  Everything from the first index select
onwards — the select itself AND every `.member` written after it — is
invisible to the slot.  What survives is either

* **two or more bare names** → the `hier_path` branch, over the **PREFIX only**
  (`o.ls[i].lv` is golden's `hier_path 'o.ls'`, two `Path_elems`), or
* **a single name** → the fall-through `ref_var` branch
  (`CompileType.cpp:421-432`), whose typespec is
  `compileTypespec(declarationId)` plus `needLateTypedefBinding(ref)` when that
  came back `unsupported` — i.e. **exactly what a BARE `foreach` over that one
  name would have produced**, in every home and both views.

An `paImplicit_class_handle` (`this.`) is stripped BEFORE the count
(`CompileType.cpp:267-272`: `variable = fC->Sibling(variable)`) and never
counts as a name, and it also suppresses the typespec (`decl_type` stays
`paImplicit_class_handle`, so `ts` is left null at `:318-320`) — which is
§ `classPropIterThisRefVar21`'s already-measured `this.q[i]` shape.

### The law

> **§ foreachLoopListStopsAtFirstSelect134.**  A `foreach` loop list is read
> only as far as its **first index select**.  Strip a leading `this.`; walk the
> dotted segments left to right and stop **after** the first segment that
> carries a selector; the names that remain are the whole of the iterated
> reference.  Two or more names give golden's `hier_path` over that PREFIX; a
> single name gives the `ref_var` branch, typed exactly as a bare `foreach`
> over that name — **and the LOOP VARIABLES follow the same truncated
> reference**, not the drilled member.

Probe-verified against Surelog in both views (`g134_c_shapes.sv`, and the
hand arms in §5):

| written loop list | golden `Variable()` |
|---|---|
| `foreach (flat[z])` | `ref_var 'flat'` |
| `foreach (this.flat[z])` | `ref_var 'flat'`, **no typespec** |
| `foreach (solo.rv[z])` | `hier_path 'solo.rv'` |
| `foreach (solo.rone.pv[z])` | `hier_path 'solo.rone.pv'` |
| `foreach (bigs[z7].rv[z8])` | **`ref_var 'bigs'`** |
| `foreach (bigs[z9].rs[za].pw[zb])` | **`ref_var 'bigs'`** (3 deep) |
| `foreach (solo.rs[zc].pv[zd])` | **`hier_path 'solo.rs'`** (truncated) |
| `foreach (this.bigs[ze].rv[zf])` | **`ref_var 'bigs'`**, no typespec |

and the loop-variable half, measured on `g134_b_homes.sv` and on the corpus:
`foreach (ms[s].m_arr[t])` in a module types `t` from **`ms`'s** element
(golden `class_var`), not from `m_arr`; `uvm_phase.svh:1730`'s `pred` is
golden's `array_var` over the subroutine-local `successors`
(§ `foreachLocalArrayVar20`), not a `class_var` over `m_predecessors`.

---

## 2. What shipped

`src/StmtEmit.cpp`, the `StatementKind::ForeachLoop` arm, is a **pure rewrite
of the reference the arm reads** (`arrRef134`).  Walk the member/select chain
from the ROOT outwards; if an `ElementSelect` appears strictly inside it, keep
the sub-expression it selects.  Everything downstream — `arrSym`, the
`this`/dotted split (`arrThis21` / `arrDotted21` / `arrMember9`), the typespec
gates (`classPropArr9`, `classPropRes21`, `tfLocalArr20`, `dropArrTs19`,
`scopedArr33`, `pendingForeachArrayTs`), and the loop-variable typing — is
**unchanged** and simply sees the shorter reference.  Four call sites move
from `fe.arrayRef` to `arrRef134`.

The rewrite is **gated on the whole reference being a `MemberAccess`**, so a
loop list with no dot — `a[i][j]`, whose leading groups slang folds into the
array reference and `foldedIdx` peels back off — is untouched by construction.

---

## 3. Mover prediction — BY NAME, a priori, from the PRISTINE databases

`pred134.sh` runs `ct134cen` over every `slang.uhdm` in a verify_golden
workdir and names the databases that *can* move: those whose pristine census
holds a `foreach_stmt` whose `Variable()` is a `hier_path` **whose written text
contains a `[`**.  Over the whole surelog corpus (**956 databases, 0 census
failures**) exactly **nine** rows qualify:

```
default   BuildUVMPkg selpaths=2  foreach=773     testflags BuildUVMPkg selpaths=2  foreach=773
default   MiniAmiq    selpaths=13 foreach=1458    testflags MiniAmiq    selpaths=13 foreach=1458
default   Scoreboard  selpaths=2  foreach=739     testflags SeqDriver   selpaths=4  foreach=1345
default   SeqDriver   selpaths=4  foreach=1345    testflags SimpleUVM   selpaths=2  foreach=737
default   SimpleUVM   selpaths=2  foreach=737
```

The 44 cells are two sites only:

* `uvm_phase.svh:1730` `successors[s].m_predecessors` — 2–4 listings in each of
  the five UVM tests (34610 in BuildUVMPkg's `pp_output`);
* MiniAmiq's AMIQ checker, 9 more cells:
  `lof_checks[check_index].checks_details` /
  `a_lof_used_checks[check_index].checks_details` /
  `lof_checks[an_index].checks_details`.

`byteverify.sh SELFCHECK=1` then found **exactly those nine databases and no
others** (MOVERS 9/956; u2r MOVERS 0/1358).

---

## 4. Census — every foreach in the nine UVM databases × both modes

`ct134cen.cpp` prints one row per `foreach_stmt` the `UhdmListener` reaches,
**deduped by `UhdmId`** and tagged with the first listing root that reached it.
`score134.py` joins golden/pristine/patched as a **multiset** on the id-free
key `HOME|PATH|SPAN|NLV|LVNAMES` and scores `VKIND VNAME VTS VTSNAME LVKINDS
LVTS` (all read by `Compare`) plus `VFULL`/`VSPAN` (dump-only —
`VpiFullName`/`VpiLineNo` are never read).  Driver: `uvmcen134.sh` (golden path
read from each row's OWN `cmds.txt`; every rc recorded).

The key **calibrates clean on all nine databases**: `ONLY-GOLDEN 0`,
`ONLY-OURS 0`, `AWAY 0` in every column — golden and ours join 1:1.

| row | mode | foreach cells | VKIND W→R | VNAME W→R | VTS W→R | LV W→R | **RIGHT→WRONG** |
|---|---|---|---|---|---|---|---|
| SeqDriver | default | 1345 | 4 | 4 | 4 | 1 | **0** |
| SeqDriver | testflags | 1345 | 4 | 4 | 4 | 1 | **0** |
| SimpleUVM | default | 737 | 2 | 2 | 2 | 1 | **0** |
| SimpleUVM | testflags | 737 | 2 | 2 | 2 | 1 | **0** |
| Scoreboard | default | 739 | 2 | 2 | 2 | 1 | **0** |
| MiniAmiq | default | 1458 | 13 | 13 | 13 | 1 | **0** |
| MiniAmiq | testflags | 1458 | 13 | 13 | 13 | 1 | **0** |
| BuildUVMPkg | default | 773 | 2 | 2 | 2 | 1 | **0** |
| BuildUVMPkg | testflags | 773 | 2 | 2 | 2 | 1 | **0** |
| **total** | | **9365** | **44** | **44** | **44** | **9** | **0** |

The nine `LVKINDS` conversions are the `pred` loop variable of
`uvm_phase.svh:1730`: golden `array_var`/`array_typespec`, pristine
`class_var`/`class_typespec (uvm_phase)`.  The one `LVKINDS` cell still wrong
in each row is the NEW HEAD at `:1740` (`next_pred`, golden `int_var`) —
untouched by this pass.

---

## 5. Grid — 5 files × {DEF, ELAB}, 259 foreach cells

`arms134.sh` runs every `g134_*.sv` under Surelog (golden), the pristine and
the patched binary in both views and scores with `ct134cen` + `score134.py`
(each arm in its OWN subdirectory keyed on its relative path; file list on
fd 3; children `</dev/null`; `PROCESSED` asserted; every rc recorded).

| arm | what it varies | view | cells | VKIND W→R | R→W |
|---|---|---|---|---|---|
| `g134_a_kinds` | array kinds (dynamic/queue/fixed) × key types (string/int/enum/class) × element kinds | def / elab | 16 / 32 | 8 / 16 | 0 / 0 |
| `g134_b_homes` | in-class method, OUT-OF-BODY method, package free function, package task, module initial, module function, interface, program | def / elab | 22 / 38 | 11 / 19 | 0 / 0 |
| `g134_c_shapes` | 12 loop-list shapes (bare, 2-dim, `this.`, dotted-2, dotted-3, indexed-root, 3-deep, dotted-indexed-dot, `this.`-indexed-dot, `this.`-dotted-indexed-dot, LOCAL, FORMAL) | def / elab | 20 / 40 | 5 / 10 | 0 / 0 |
| `g134_d_bodies` | body shapes: member read, method call, element read, index-only, nested foreach, empty, labelled block | def / elab | 15 / 30 | 8 / 16 | 0 / 0 |
| `g134_e_mult` | 1–3 instances of a parameterised module + three repeats of the shape in one subroutine (the multiset join must not collapse them) | def / elab | 14 / 32 | 7 / 16 | 0 / 0 |
| **total** | | | **259** | **116** | **0** |

`ONLY-GOLDEN 0`, `ONLY-OURS 0`, `AWAY 0`, `RIGHT→WRONG 0` in every column of
every arm-view.  Names are deliberately unalike (`Grain`/`Bin134`,
`Pebble`/`Rock`/`Boulder`, `Twig`/`Branch`, `Cog`/`Gear`, index names
`u1..u8`, `z1..zl`, `d1..df`, `h1..hg`) — a grid that calls everything
`a_t`/`b_t`/`c_t` over `A`/`B`/`C` is self-confirming.

---

## 6. Boundary — 719 files × both views, 1438 file-views

`bound134.sh` compiles every `.sv`/`.svh` under **every probe tree that
contains a `foreach`** (116 files) plus the whole of the brief's must-stay
trees — `r10uvm77-79`, `r10uvm82-91`, `r10uvm84/85`, `r10uvm89`, `r10uvm113`,
`r10uvm122`, `r10uvm131`, `r10buvm3-15`, `r10buvm14`, `r10buvm33/34`,
`r10sd8-12` — with the pristine and the patched binary and diffs the two
uhdm-dumps whole (workdir-normalised).  A file whose dump moved must be
attributable on TWO independent counts: its `ct134cen` census must have moved
too (a dump change with a frozen foreach census is a BREACH), **and** its
SOURCE must contain the law's syntactic predicate `foreach (x[i].y…`
(otherwise the law cannot reach it — also a BREACH).

```
LISTED=719 PROCESSED=719 MOVED=10 BREACH=0 RC-MISMATCH=0 NORUN=19
PROCESSED-ASSERT-OK
BOUNDARY PASS
```

The ten moved file-views are the five `g134_*.sv` arms of THIS pass.  **No
foreign arm moved in either view** — every `buvm33`/`buvm34` foreach cell,
every `uvm84/85` `this.`/`super.` cell, every `uvm89`/`buvm14` hier_path cell
and every `sd8-12` arm is byte-identical.  `NORUN=19` are arm-views that
produce no database on EITHER binary (equal rc, recorded).  Positive control
(`CTRL=1` on the arm tree): the gate fires on all 10 arm-views.

The 4 slang-fenced tests are never dispatched: `canaudit.sh` audits 29 names,
`UNCOVERED=0 FENCE-BREACH=0`.

---

## 7. Gates (all green, on my OWN pinned build and workdirs)

1. **build** both binaries `-j 2`; md5 separately; both frozen `chmod 555` at
   immutable paths before any sweep; every `cmds.txt` in both sweeps audited by
   binary PATH (2981 hits each, one binary per sweep, no main-tree leak).
2. **goldens** `23 PASS / 0 FAIL`; negative control `SLANG_UHDM=/bin/false` →
   `23 FAIL`.
3. **uhdm2rtlil** testflags and default `679 CMP_EQUAL / 50 SLANG_REJECT /
   2 SURELOG_FAIL` (status histogram checked — a rc=139 segfault would show as
   SLANG_REJECT); `ct8rows` **0 differing rows** against the committed baseline
   AND against my own pristine sweep, both modes; `byteverify SELFCHECK=1`
   **MOVERS 0 / 1358**.
4. **surelog** `--mode both`: 937 CMP_EQUAL / 567 SLANG_REJECT / 48
   SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 2
   UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM — **identical to pristine**;
   `ct8rows` **0 differing rows over 1588** against the committed baseline and
   against my own pristine sweep.  **No row converted** (MiniAmiq stays
   CMP_NOTEQUAL at a shallower head).
5. **byteverify SELFCHECK=1** on surelog: **MOVERS 9 / 956** — precisely the
   nine names `pred134.sh` predicted a priori, and no others.

Canaries: `canaries.sh` `ok=52 changed=0` (surelog) and `ok=8 changed=0`
(u2r); `ctcan2.sh` PASS both; `canaudit.sh` PASS.  Byte pins hold: SVSwitch
`4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort /
BlackParrotComplex / YosysOldOr byte-identical to the pristine control in both
modes.

**Mover attribution, ORDER-BLIND** (sorted, path-normalised whole dumps —
Scoreboard/default is a ~50/50 coin and may only be attributed this way):

| database | mode | order-blind differing lines | unattributed |
|---|---|---|---|
| BuildUVMPkg | default / testflags | 74 / 74 | 0 |
| MiniAmiq | default / testflags | 408 / 408 | 3 |
| Scoreboard | default | 74 | 0 |
| SeqDriver | default / testflags | 142 / 142 | 3 |
| SimpleUVM | default / testflags | 74 / 74 | 1 |

Every differing line is the law's own object: the `hier_path` subtree replaced
by `ref_var` + `ref_typespec` → (`unsupported_typespec` in the DEF listing,
the declaration's `array_typespec` in the ELAB one), and the `pred` loop
variable `class_var`→`array_var`.  The "unattributed" column is the
`vpiInstance:` back-pointer line of each newly minted `unsupported_typespec`
in the **weakly-referenced orphan tail** (unreachable to the judge), one per
new typespec.

---

## 8. Residues

* **R0 (next head).** MiniAmiq ×2, 56 cmp lines, `uvm_phase.svh:1740` —
  `foreach (pred.m_predecessors[next_pred])`, a **DOTTED** loop list whose
  `Variable()` both sides agree on (`hier_path`).  Golden's LOOP VARIABLE is
  `int_var` + a bare `int_typespec`; ours is `class_var` +
  `class_typespec 'uvm_phase'`.  Source-first this is
  `UhdmWriter::swapForSpecifiedVar` (`UhdmWriter.cpp:2490`) feeding a
  `hier_path` to `decodeHierPath` **as written** (`:2511`) and falling through
  to the `:2550` `int_var` default when the walk answers nothing — the same
  fallback § `foreachScopedArrayLoopVarIntFallback34` decoded for the
  `::`-written spelling.  One `LVKINDS` cell per UVM row (9 over the nine
  databases), and it is the ONLY `LVKINDS` cell still wrong there.
* **R1 (corpus-invisible).** `foreach (this.<a>.<b>[i]…)` — after stripping
  `this.` **two** names remain, so golden builds a `hier_path 'a.b'`; we still
  take § `classPropIterThisRefVar21`'s unconditional `this.` → `ref_var` arm
  and answer `ref_var 'b'`.  4 cells in `g134_c_shapes` (`s_thisdotidxdot`,
  both views); **zero** in either corpus (`pred134.sh` over 956 databases finds
  no such cell).  Left alone deliberately: the fix needs a `this`-stripping
  `hier_path` builder and would reach `uvm84/85`'s protected `this.`/`super.`
  cells.
* **R2 (dump-only).** Our loop-list `hier_path` carries a real span where
  golden's carries none (`compileVariable` calls `populateCoreMembers` on the
  first `Path_elems` entry only, never on the path), and our `this.`-rooted
  `ref_var` spans the NAME where golden spans the `this` token.  `VpiLineNo` is
  never read by `Compare`; both predate this pass and it converts 44 `VSPAN`
  cells while creating none.
* **R3 (pre-existing, named by § `foreachHierPathAlwaysRes21`).** An INTERFACE-
  or PROGRAM-homed foreach keeps an unresolved `ref_var` loop variable in
  golden while we list a resolved one — 4 cells in `g134_b_homes`, wrong before
  and after, unchanged by this pass.

---

## 9. Instruments (all measurement-only; the judge is `uhdm-cmp`)

| file | what it is |
|---|---|
| `ct134cen.cpp` | the FOREACH census: one row per `foreach_stmt`, deduped by `UhdmId`, with the `Variable()` slot's kind/name/typespec and the loop variables' kinds/typespecs |
| `score134.py` | multiset join on `HOME\|PATH\|SPAN\|NLV\|LVNAMES`; scores 6 judged columns + 2 dump-only ones; `RIGHT→WRONG` and `AWAY` must be 0 |
| `pred134.sh` | a-priori mover prediction BY NAME from the pristine databases of a workdir |
| `uvmcen134.sh` | the census over the named rows of two workdirs, each scored against its OWN golden (path read from that row's `cmds.txt`) |
| `arms134.sh` | the `g134_*.sv` grid under Surelog + both binaries, both views |
| `bound134.sh` | the wide boundary gate (census-confined + source-predicate attribution, positive control via `CTRL=1`) |
| `g134_a_kinds.sv` `g134_b_homes.sv` `g134_c_shapes.sv` `g134_d_bodies.sv` `g134_e_mult.sv` | the grid |

Build the census with

```
g++ -O2 -std=c++17 ct134cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct134cen
```
