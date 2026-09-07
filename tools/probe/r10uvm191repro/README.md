# r10uvm191 — § `cloneNewArrayHierBaseBindsOwnDecl191` — **A WILDCARD-IMPORT CLONE BINDS THE `hier_path` BASE WRITTEN INSIDE A `new[...]` ARGUMENT, AND OUR PARENT WALK COULD NOT SEE IT** — the SeqDriver ×2 / MiniAmiq ×2 55-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `6873bc3f` |
| pristine binary | md5 `fb17fb4d8223169f2abb2b55cf560ea2`, built from this pass's OWN worktree at a clean `6873bc3f` and frozen `chmod 555` before any sweep |
| patched binary | md5 `38c6f72a288d129d4fa9ee0ec3377394`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` (record the clone's `new[...]` call's would-be parent), `src/UhdmExporter.cpp` (ONE hop, taken by the owning-subroutine walk and by the block-local climb), `include/UhdmExporter.h` (the law and the map) |
| probe surface | `tools/probe/r10uvm191repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default/testflags AND MiniAmiq default/testflags, 55 cmp lines, ONE `^LHS:` each, the SAME object in all four row-modes → cleared** (55 → 58 lines, still ONE head, a NEW object). |
| corpus rows changed | **0** — both corpora, both modes. `ct8rows` PASS against the committed baselines AND against this pass's own pristine sweep, status AND dump column. |
| byte movers | **surelog 5 / 956** — the FOUR predicted by name from the pristine databases alone, plus `Scoreboard/default`, whose ORDER-BLIND dump diff is **0 content lines** (the svunit_pkg `vpiTaskFunc` COIN, RESUME §9). **0 / 1358** uhdm2rtlil. |
| the a-priori prediction | `LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4 CELLS=32` — SeqDriver ×2, MiniAmiq ×2, **8 cells each**, and nothing else. On uhdm2rtlil `LISTED=1358 PROCESSED=1358 NOGOLDEN=0 PREDICTED=0`, and byteverify agrees at 0. |
| the corpus population | the BASE of a `hier_path` written in a dynamic-array `new[...]` argument inside a wildcard-import clone: **4 keys × 2 clone listings = 8 cells** per moving row-mode, in two UVM subroutines. |
| the census (nine UVM row-modes) | SeqDriver ×2 and MiniAmiq ×2 **TOWARD 8 / AWAY 0 / MOVED-WRONG 0 / ONLY-OURS-MOVED 0**; SimpleUVM ×2, Scoreboard/default and BuildUVMPkg ×2 score **TOWARD 0 / AWAY 0 / MOVED-WRONG 0** and are untouched. Calibrated golden-vs-golden-vs-golden FIRST: every column 0 but UNTOUCHED, on every row. |
| the grid (3 arms × both views × two keyings) | arm A (the FACE axis) **TOWARD 28 def / 8 elab**; arm B (the CONTEXT axis) **TOWARD 2 def / 0 elab**; arm C (the DECLARATION-SCOPE axis) **TOWARD 20 def / 0 elab** (face-blind). **AWAY 0 and MOVED-WRONG 0 in every arm, every view, both keyings.** Each calibrated golden-vs-golden-vs-golden at every column 0 first. |
| the WIDE boundary (5106 arm files × both views) | `LISTED=5106 FENCED_SKIPPED=0 PROCESSED=5106 PROCESSED-ASSERT-OK`, **MOVED 16 arm-views**: this pass's own three arms (6), the three DECODED static-address false movers (6, whose whole diff is two constants shifting by exactly 4096 and whose reference census does not move a single row), and TWO arms that hold this law's own cells — r10uvm186's `g186_a_argdecl.sv` and r10v186's `v186_c_kinds.sv` — each re-scored against its OWN Surelog golden at **AWAY 0 / MOVED-WRONG 0**, same head object on both binaries. |
| what the corpus itself fences | `bits = new[m_packed_size]` (uvm_packer.svh:475) — a CLASS PROPERTY under the identical `new[...]` — is BARE in golden's clone and stays BARE on both binaries, and so is the class-property receiver `m_hoard191.size()` in arm A and `m_wain191.size()` in arm C. |
| the patch reproduces | applied to a FRESH `6873bc3f` worktree with `git apply -3` (three files, all "cleanly", 0 conflict markers) and built there, the tree produces md5 `38c6f72a288d129d4fa9ee0ec3377394` — the very binary every number above was measured on. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `6873bc3f` worktree, ran
its 23/23 goldens (`/bin/false` 0/23), and reproduced the committed baselines
row for row — surelog `937/567/48/19/10/3/2/1/1`, uhdm2rtlil `679/50/2` in both
modes, `ct8rows` PASS on all of them, status AND dump column — before a line of
code was written. `rowheads.sh` on that sweep (`HEADS.r10uvm191.txt`):

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         55      1
SeqDriver      testflags       55      1
SimpleUVM      ×2          664681      1
Scoreboard     default         95      1
MiniAmiq       default         55      1
MiniAmiq       testflags       55      1
BuildUVMPkg    ×2              33      1
Earlgrey_0_1   default/tf   31 / 37     1
Rggen          default    CMP_EQUAL
```

The head, identical on all four row-modes (`head_pris_*.cmp`):

```
LHS (golden)
array_var: (uvm_pkg::uvm_phase::get_adjacent_predecessor_nodes::predecessors)
           id:14293, line:1664:8-1664:20
|vpiParent: begin (…get_adjacent_predecessor_nodes) 1664:4-1664:32
|vpiTypespec: -> ref_typespec -> array_typespec 1664:8-1664:31
|vpiName:predecessors
|vpiArrayType:3
|vpiReg: -> bit_var (…predecessors) 1664:8-1664:20
RHS: <null>
```

### DECODING THE JUDGE — which of sixteen referrers it stopped on

`RHS: <null>` with a present LHS is `BaseClass.h`'s SINGULAR `SafeCompare`
naming a VALUE (RESUME §9), not the vector overload — so a reference of OURS is
BARE where golden's is bound.

`ct191hpb own` runs the OFFICIAL `design::Compare` and then scans BOTH
databases with `GetByVpiType` — the generated, kind-agnostic edge accessor, so
no field is named by hand and none can be missed — for every edge that lands on
the head object. Golden's answer, with the listing and the face of each
referrer:

```
begin ()@1664:4                       vpiType=100 [2]   package:uvm_pkg/ELAB   (the declaration)
function (…nodes)@1662:1              vpiType=100 [1]   package:uvm_pkg/ELAB   (the declaration)
bit_var ()@1664:8                     vpiType=81        package:uvm_pkg/ELAB   (vpiReg)
ref_typespec ()                       vpiType=81        package:uvm_pkg/ELAB
bit_select (predecessors)@1669:6      vpiType=700       package:adpcm_pkg/ELAB  NAME    FOREACH
bit_select (predecessors)@1679:15     vpiType=700       package:adpcm_pkg/ELAB  NAME    FOREACH
ref_var    (predecessors)@1675:16     vpiType=700       package:adpcm_pkg/ELAB  NAME    FOREACH
ref_obj    (predecessors)@1677:13     vpiType=700       package:adpcm_pkg/ELAB  NAME    CALLARG
ref_obj    (predecessors)@1685:16     vpiType=700       package:adpcm_pkg/ELAB  HPBASE  NEWARG   <-- OURS IS BARE
ref_var    (predecessors)@1686:13     vpiType=700       package:adpcm_pkg/ELAB  NAME    FOREACH
   …and the identical six again in package:adpcm_pkg/DEF
```

**Golden's clone listing holds SIX bound references to that object and ours
holds FIVE** — every one but the `hier_path` BASE of `predecessors.size()`
inside the `new[...]` argument. `ct191hpb refs` reads the same fact off the two
databases side by side, one row per reference, and there is nothing else in it:

| listing | 1669:6 | 1675:16 | 1677:13 | 1679:15 | **1685:16 (HPBASE/NEWARG)** | 1686:13 |
|---|---|---|---|---|---|---|
| `uvm_pkg/DEF` (HOME) | bare/bare | bare/bare | bare/bare | bare/bare | **bare/bare** | bare/bare |
| `uvm_pkg/ELAB` (HOME) | bare/bare | bare/bare | bare/bare | bare/bare | **bare/bare** | bare/bare |
| `adpcm_pkg/DEF` (CLONE) | bound/bound | bound/bound | bound/bound | bound/bound | **bound / BARE** | bound/bound |
| `adpcm_pkg/ELAB` (CLONE) | bound/bound | bound/bound | bound/bound | bound/bound | **bound / BARE** | bound/bound |

Two cells. `ct191hpb skip` — r10uvm184's VISITED-SET skip, which pre-seeds a
golden object into `CompareContext::m_visited` so every generated `Compare`
returns early on it, WITH NO EDIT TO EITHER DATABASE — confirms the edge is
singular: seeding the `array_var` moves the head to its own
`array_typespec @1664:8` with `RHS: <null>` (the same missing binding showing
through one field over) and then out of the subroutine entirely.

**The instrument this pass had to build first.** A dynamic-array `new[...]`
call carries NO `VpiParent` — on BOTH sides in the home listing and on OUR side
in every listing (§ `newArray11` models Surelog's unparented `fcall`) — so a
parent walk from anything underneath it reaches no listing at all, and the home
listing, both clone copies and the elaborated module collapse into ONE
unattributable bucket. `ct191hpb` therefore builds a CONTAINMENT index (one
top-down pass from `design` over the generated edge accessors) and hops it ONLY
where the parent chain is dead. Taking the containment root outright instead
was measured and rejected: it put golden's four HOME-listing `predecessors`
references under `adpcm_pkg/ELAB`.

---

## 2. THE DECODED MODEL

> **§ `cloneNewArrayHierBaseBindsOwnDecl191`.** In a WILDCARD-IMPORT **clone**
> of a package subroutine, the **BASE** of a `hier_path` written inside a
> DYNAMIC-ARRAY `new[...]` argument **binds the body's own declaration** —
> exactly like every other reference in that clone body. At HOME it stays
> BARE in both views, and a CLASS PROPERTY at the identical face stays BARE
> everywhere.

### WHICH ROAD BINDS GOLDEN'S BASE — measured, and it is § 184's, not § 186's

r10uvm186 attributed its own cell to a PARENTED-COPY WALK: Surelog's
`clone_tree` gives the cloned `new` call a parent, so a `VpiParent`-walking
binder succeeds in the clone and fails at home. That framing predicts the right
answer for a DIRECT NAME but it is **not** what binds a `hier_path` base, and
this pass read the producer rather than carrying the framing forward.

* **`hier_path::DeepClone`** (`~/git-repos/UHDM/templates/clone_tree.cpp:895`)
  has NO name lookup for the FIRST element at all. It handles `this` and
  `super`, then resolves each LATER element against the PRECEDING one's
  `Actual_group`. The base can never be bound there.
* **`UhdmWriter::lateBinding`** (`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:3294`)
  DOES walk `ref->VpiParent()`, and its `uhdmbegin` arm would find
  `predecessors` in the enclosing `begin`'s `Variables()`. But it iterates
  `mod->getLateBinding()` — the HOME's ORIGINAL `ref_obj` POINTERS, copied into
  the importer BY POINTER (`CompileHelper::importPackage`,
  `CompileHelper.cpp:190-193`) — so the only object it can ever reach is the
  home one, whose chain dies at the unparented `new`. That is exactly why
  golden's HOME listing is BARE in both views.
* **`ref_obj::DeepCopy`**, the GENERATED one
  (`~/git-repos/UHDM/build/generated/src/ref_obj.cpp`), is the binder:

  ```cpp
  elaboratorContext->m_elaborator.enterRef_obj(clone, nullptr);
  basetype_t::DeepCopy(clone, parent, context);
  if (!clone->Actual_group())
    clone->Actual_group(elaboratorContext->m_elaborator.bindAny(VpiName()));
  if (!clone->Actual_group())
    clone->Actual_group((any*) Actual_group());
  ```

  `bindAny` is a pure NAME lookup over the ELABORATOR'S SCOPE STACK, which
  `function::DeepClone` pushed with `enterTask_func(clone, nullptr)` before it
  cloned the body (`clone_tree.cpp:514`); that scope is the subroutine's own
  `Variables()`, its `Io_decls()` and its return name
  (`ElaboratorListener.cpp:1051-1102`). **It never reads `VpiParent`.**
  `importPackage` runs exactly that `clone_tree` over every imported subroutine
  listing (`CompileHelper.cpp:317-323`), which is why the clone binds and the
  never-cloned home listing does not.

**This decode also explains the corpus fence with no extra rule.**
`enterTask_func` collects a CLASS's `Variables()` only when the task_func's
`VpiParent` is a `class_defn`; an OUT-OF-BODY method hoisted into the package
listing has a package parent, so class properties are not in the scope at all —
and golden accordingly leaves `bits = new[m_packed_size]` (uvm_packer.svh:475),
`m_hoard191.size()` and `m_wain191.size()` BARE in the clone while binding
every subroutine-scope name beside them.

**The corpus population, read off the two databases (`ct191hpb newhp`).** All
19 `new[...]` `hier_path`s in the SeqDriver pair, one row per path with every
element and its actual:

| listing | subroutine | path | golden's base | golden's element after it |
|---|---|---|---|---|
| `adpcm_pkg` ×2 | `uvm_phase::get_adjacent_predecessor_nodes` | `predecessors.size` @1685:16 | `array_var (predecessors) @1664:8` | BARE |
| `adpcm_pkg` ×2 | `uvm_phase::get_adjacent_successor_nodes` | `successors.size` @1714:16 | `array_var (successors) @1693:8` | BARE |
| `adpcm_pkg` ×2 | `uvm_reg_map::get_physical_addresses` | `local_addr.size` @1467:19 | `array_var (local_addr) @1408:20` | BARE |
| `adpcm_pkg` ×2 | `uvm_reg_map::get_physical_addresses` | `sys_addr.size` @1491:26 | `array_var (sys_addr) @1472:23` | BARE |
| `uvm_pkg` ×2 (HOME) | the same four | the same four | **BARE** | BARE |
| `uvm_pkg/ELAB` | `add_slice`, `pre_randomize`, `reg2bus` | `slices.size`, `m_extensions.num`, `gp.get_streaming_width` | **BARE** | BARE |

Every element AFTER the base is a `method_func_call` (the parens-ful `.size()`),
which is why § `builtinArrayReadBindsMintedFuncCall182`'s mint — a `ref_obj`
element only — has no corpus cell here and golden leaves all of them bare.

### WHY OURS MISSED IT

Our model of `bindAny` is `pkgCloneHierBind9` (`src/UhdmExporter.cpp`), and it
finds the owning subroutine by walking `VpiParent` up from the `hier_path`,
using that walk as its "am I in a clone body" test. § `newArray11` deliberately
leaves the dynamic-array `new` `method_func_call` UNPARENTED. So the walk dies
ONE LINK below the assignment, `ownerTf9` returns null, and the base is never
even offered to the bind — along with everything else under that call. Every
other face in the same clone body has a live chain and already binds on both
sides. **The `new[...]` argument is the only place in the corpus where the
chain is cut.**

---

## 3. WHAT SHIPPED — ONE HOP, TAKEN IN TWO PLACES

`src/ExprEmit.cpp`, the `NewArray` arm — the call still gets NO parent
(that is § `newArray11`'s model and golden's home listing agrees); what is
recorded is the parent Surelog's own `clone_tree` gives the CLONED call:

```cpp
if (pkgImportCloneEmit && parent)
    newArrayCloneOwner191[mfc] = (UHDM::any*)parent;
```

`src/UhdmExporter.cpp`, inside `pkgCloneHierBind9` — one helper, used by the
owning-subroutine walk and by the block-local climb:

```cpp
auto up191 = [&](const UHDM::BaseClass* o) -> const UHDM::BaseClass* {
    if (!o) return nullptr;
    if (const UHDM::BaseClass* p9 = o->VpiParent()) return p9;
    auto h191 = newArrayCloneOwner191.find((const UHDM::any*)o);
    return h191 == newArrayCloneOwner191.end() ? nullptr : h191->second;
};
```

`ownerTf9` walks with `up191`; `bind9`'s innermost-out climb (the one that
consults `loopVar37` and `blockVar9`) walks with `up191`. Nothing else changes:
the window, the symbol half, the clone registry `pkgCloneBodyLocals9` and every
other law asked through `ownerTf9` are exactly what they were.

**The `vpiParent` FIELD IS NOT WRITTEN.** It is read by no generated `Compare`
(RESUME §9), but it IS what the uhdm dump synthesises fullnames from, so
writing it would move dump bytes this pass has no evidence for.

**Why the climb needed the hop too, and how that was caught.** With the hop in
`ownerTf9` alone, THREE of the four corpus keys moved and `sys_addr` @1491:26
stayed bare: `sys_addr` (uvm-1.2 `uvm_reg_map.svh:1472`) is declared in the
`else begin … end` BLOCK, so it is found by `blockVar9` on the climb and not by
the subroutine-level map. Arm C is the minimal reproducer and scores that face
explicitly (named block, unnamed block, nested block, `for`-body block).

**What the gate still refuses**, unchanged:

* the HOME listings, both views — `pkgCloneBodyLocals9` has no entry for a home
  `task_func`, so `bind9` returns before the map matters;
* a CLASS PROPERTY at the identical face — `bind9`'s targets are the
  subroutine's own locals and formals, a block local and a foreach loop
  variable, and a class property is in none of them;
* the EXPLICIT-import copy (`importCloneEmit`), which neither the map nor
  `pkgCloneBodyLocals9` names (R1);
* every position that is not a dynamic-array `new[...]` argument — the map is
  keyed on that call and on nothing else (arm B measures nine such positions).

---

## 4. THE GOLDEN GRID — three arms, one real Surelog golden each, both views

Every arm is CALIBRATED golden-vs-golden-vs-golden first (every column 0 but
UNTOUCHED) and scored TWICE. The FACE column of the census key is a SHAPE fact
that predates this pass — golden renders a `foreach` index inside a `new[...]`
path as a `bit_select` BASE and we render it as a later `Path_elems` entry — so
face-keyed those two rows do not join, and a reference whose ACTUAL moved to
exactly golden's object scores ONLY-OURS-MOVED. Both keyings are reported.

| arm | view | UNTOUCHED | TOWARD | AWAY | MOVED-WRONG | ONLY-OURS-MOVED |
|---|---|---|---|---|---|---|
| A face-keyed | def | 209 | **28** | **0** | **0** | **0** |
| A face-blind | def | 209 | **28** | **0** | **0** | **0** |
| A face-keyed | elab | 290 | **8** | **0** | **0** | **0** |
| A face-blind | elab | 288 | **8** | **0** | **0** | **0** |
| B face-keyed | def | 161 | **2** | **0** | **0** | **0** |
| B face-blind | def | 163 | **2** | **0** | **0** | **0** |
| B face-keyed | elab | 211 | **0** | **0** | **0** | **0** |
| B face-blind | elab | 209 | **0** | **0** | **0** | **0** |
| C face-keyed | def | 163 | **18** | **0** | **0** | 2 |
| C face-blind | def | 163 | **20** | **0** | **0** | **0** |
| C face-keyed | elab | 237 | **0** | **0** | **0** | **0** |
| C face-blind | elab | 233 | **0** | **0** | **0** | **0** |

### Arm A `g191_a_face.sv` — the FACE axis

One row per receiver kind in ONE out-of-body class method, plus a free package
function, plus the in-body control that is never cloned. Golden's clone answer,
cell by cell:

| cell | written | golden's clone | ours pristine | ours patched |
|---|---|---|---|---|
| A1 | `new[bag191.size()]` ASSOC | `array_var (bag191)` | BARE | **golden's** |
| A2 | `new[rope191.size()]` QUEUE | `array_var (rope191)` | BARE | **golden's** |
| A3 | `new[slab191.sum()]` UNPACKED | `array_var (slab191)` | BARE | **golden's** |
| A4 | `new[limb191.size()]` DYNAMIC | `array_var (limb191)` | BARE | **golden's** |
| A5 | `new[m_hoard191.size()]` **CLASS PROPERTY** | **BARE** | BARE | **BARE** |
| A6 | `new[m_tally191.size()]` **CLASS PROPERTY** | **BARE** | BARE | **BARE** |
| A7 | `new[rope191.size]` PARENS-LESS, base | `array_var (rope191)` | BARE | **golden's** |
| A7′ | the `size` ELEMENT of A7 | `func_call (size)` — § 182's MINT | BARE | **golden's** |
| A8′ | `nook191.size`, queue OF STRUCT with a `size` member | `typespec_member (size)` — § 10 beats the mint | BARE | **golden's** |
| A9′ | `crate191.size` struct member | `typespec_member (size)` | BARE | **golden's** |
| A10′ | `crate191.hasp191` struct member | `typespec_member (hasp191)` | BARE | **golden's** |
| A11/A14 | `new[fml_a]`, DIRECT NAME | § 186's own cells | already right | UNTOUCHED |
| A12 | `new[pkgtally191]` PACKAGE variable | outside the silence | already right | UNTOUCHED |

The three laws asked through the same owning-subroutine test — § 9's name bind,
§ `pkgCloneMember10` and § `builtinArrayReadBindsMintedFuncCall182` — all fire
in the window once the chain is whole, **and golden agrees with every one of
them**, including the order § 182's decode names (the struct member beats the
mint, the mint beats nothing). In the ELAB view the BASE cells were already
right on the pristine binary (UHDM's elaborator re-clones the whole design), so
only the four element cells move there — the same asymmetry § 182 recorded.

### Arm B `g191_b_ctx.sv` — the CONTEXT axis

The same receivers and the same method calls written in every OTHER position a
clone body can put them: a plain statement rhs, an operation operand, a USER
call's argument, a SYSTEM call's argument, a select INDEX, an `if` condition, a
`foreach` array reference, a `while` condition, a `case` selector, a CLASS
`new(...)` and a method call's argument. **Exactly ONE cell moves** — the
`dyn191 = new[tally191.size()]` window — and all eleven others are UNTOUCHED in
both views. This is the arm that makes "the law moved nothing outside its
window" a measured column.

### Arm C `g191_c_scope.sv` — the DECLARATION-SCOPE axis

Every declaring scope at the same face. Face-blind, DEF view, all TOWARD:

```
43:18 lvl191    a FUNCTION-LEVEL local
44:18 fml_arr   a FORMAL dynamic array
51:20 nbl191    a NAMED-block local          <- the sys_addr face
56:20 ubl191    an UNNAMED-block local       <- the sys_addr face
60:22 deep191   a NESTED unnamed-block local
66:20 forl191   a `for`-BODY block local
69:20 shelf191  a bit_select BASE
69:29 ix191     a foreach INDEX
70:18 shelf191  a bit_select BASE (member read)
79:18 purl191   a FREE package function
```

and the two fences do not move: `45:18 m_wain191` (a CLASS PROPERTY) and
`46:18 pkgcask191` (a PACKAGE variable) are **BARE in golden, BARE pristine,
BARE patched**, in all four listings.

---

## 5. THE A-PRIORI PREDICTION (over all 956 surelog + 1358 u2r databases)

`predict191.sh` replays a COMPLETED PRISTINE sweep workdir: for every row it
reads the row's OWN golden out of the row's `cmds.txt` (never guessed) and asks
`ct191hpb pred` the law's question of that pair alone — *is there a `hier_path`
BASE under a dynamic-array `new[...]` argument that golden BINDS and the
pristine database leaves BARE?* A row with no such key cannot move. The
predicate is a SUPERSET of the shipped gate (a database cannot say whether a
listing is a WILDCARD-import clone or an EXPLICIT-import copy, and it asks
nothing about the symbol half), so it can OVER-name and never UNDER-name — in
particular it WOULD name an explicit-import copy (R1) if the corpus held one.

```
PREDICT default/MiniAmiq-544c7f61   cells=8
PREDICT default/SeqDriver-32af76aa  cells=8
PREDICT testflags/MiniAmiq-544c7f61 cells=8
PREDICT testflags/SeqDriver-32af76aa cells=8
LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4 CELLS=32

LISTED=1358 PROCESSED=1358 NOGOLDEN=0 PREDICTED=0 CELLS=0
```

Every row that produced a pristine database was processed and every one had its
golden (`NOGOLDEN=0`), so the prediction covers the whole comparable
population. `byteverify.sh SELFCHECK=1` on the accepted patched sweeps then
reported **MOVERS 5 / 956** — those four plus the Scoreboard COIN — and
**0 / 1358** on uhdm2rtlil, matching `PREDICTED=0` exactly.

---

## 6. MOVER ATTRIBUTION, ORDER-BLIND AND NAMED

```
databases: patched=956 pristine=956 ; PATH_SETS_IDENTICAL (956 paths)
MOVER ./default/MiniAmiq-544c7f61     ./default/SeqDriver-32af76aa
MOVER ./testflags/MiniAmiq-544c7f61   ./testflags/SeqDriver-32af76aa
MOVER ./default/Scoreboard-59431470
MOVERS: 5 / 956   SELFCHECK: 955 / 956 flagged
```

The four are the four PREDICTED BY NAME. `Scoreboard/default` is the documented
svunit_pkg `vpiTaskFunc` COIN (RESUME §9): its path-normalised, ORDER-BLIND
dump diff (`uhdm-dump | sed 's#<workdir>##g' | sort`, both sides) is **0
content lines**, so nothing in it is this law's.

Protected databases: `InterfaceModPort`, `BlackParrotComplex` and `YosysOldOr`
byte-identical in both modes; `SVSwitch` pinned `4842211c4030`; `YosysVerx`
pinned `6ccda350c24a`.

### The WIDE boundary, and its two honest movers

`bound191.sh` compiles EVERY `.sv`/`.v` under a copy of `tools/probe` with both
binaries in both views and diffs the dumps:
`LISTED=5106 FENCED_SKIPPED=0 PROCESSED=5106 PROCESSED-ASSERT-OK`, **MOVED 16
arm-views**, in three groups:

1. **This pass's own three arms** (6 arm-views) — the grid above.
2. **The DECODED static-address false mover** (6 arm-views:
   `r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv`,
   `r10uvm185repro/g185_e_kinds.sv`). Their ENTIRE diff is two constants whose
   `vpiDecompile`/`UINT` value shifts by **exactly 4096** — one page — because
   the binary grew; filtering those two patterns leaves **0 differing lines**
   in every one of the six, and `ct191hpb cenall` on the same databases reports
   **0 changed reference rows**. Zero census movement is the tell (RESUME's own
   note on this artifact).
3. **Two arms that hold this law's own cells** —
   `r10uvm186repro/g186_a_argdecl.sv` (its `new[idxbag186[loc186]]` select base
   and its `new[fex186 + 1]` foreach index, both inside the clone) and
   `r10v186repro/v186_c_kinds.sv`. Each was re-run through `grid191.sh`
   against its OWN real Surelog golden and scored:

   | arm | view | TOWARD | AWAY | MOVED-WRONG | ONLY-OURS-MOVED |
   |---|---|---|---|---|---|
   | `g186_a_argdecl.sv` | def | 4 | **0** | **0** | **0** |
   | `g186_a_argdecl.sv` | elab | 2 | **0** | **0** | **0** |
   | `v186_c_kinds.sv` | def | 10 | **0** | **0** | **0** |
   | `v186_c_kinds.sv` | elab | 6 | **0** | **0** | **0** |

   with the SAME head object on both binaries in both views
   (`logic_net (work@top186a.loc186) @44:18` in def,
   `module_inst work@top186a` in elab). Every § `cloneNewArrayArgBindsOwnDecl186`
   cell, § `cloneBuiltinMethodArgBindsReceiver184`'s arms and its receiver-kind
   fence, § `retNameArgKeepsReturnVar184v`,
   § `builtinArrayReadBindsMintedFuncCall182`'s arms, uvm189's sentinel arms and
   the uvm181/183/185/187/188, uvm82-91, buvm3-15 and sd8-12 arms are otherwise
   byte-identical.

---

## 7. GATES

* build `-j 2`, md5 taken separately: pristine `fb17fb4d8223169f2abb2b55cf560ea2`,
  patched `38c6f72a288d129d4fa9ee0ec3377394`, both frozen `chmod 555` BEFORE any
  sweep, and every `cmds.txt` audited by BINARY PATH (0 of 1573 surelog and 0 of
  1462 uhdm2rtlil `cmds.txt` name the pristine binary in the patched workdirs);
* goldens **23 PASS / 0 FAIL** with `SLANG_UHDM` exported explicitly to the
  patched binary, and **0 PASS / 23 FAIL** with `SLANG_UHDM=/bin/false`
  (negative control); the pristine binary is 23/0 too;
* uhdm2rtlil `679/50/2` in BOTH modes, `ct8rows` **0 differing rows** against
  the committed `results/gate_uhdm2rtlil.csv` IN THIS WORKTREE and against this
  pass's own pristine sweep, status AND dump column;
* surelog `--mode both` `937/567/48/19/10/3/2/1/1`, `ct8rows` **0 differing rows
  over 1588** against the committed `results/golden_surelog.csv` IN THIS
  WORKTREE and against this pass's own pristine sweep. **NO ROW CONVERTED**;
  `results/*.csv` were read only;
* `byteverify.sh SELFCHECK=1` 5/956 and 0/1358, every mover named and
  attributed above, PREDICTED BY NAME from the pristine databases first;
* canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (uhdm2rtlil);
  `ctcan2` PASS with `EXPECT_UNKNOWN=1` / `EXPECT_UNKNOWN=6`;
  `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0`.

---

## 8. RESIDUES AND R0

* **R0 — the next head.** SeqDriver ×2 and MiniAmiq ×2, **58 cmp lines, ONE
  `^LHS:`**, the same object in all four row-modes. It is
  `int_var (uvm_pkg::uvm_phase::sync::visited.exists::succ) @1896:9-1896:16`
  against our `ref_var (succ) @1906:34-1906:38` — a VALUE mismatch, not a null:
  golden's object is parented at `method_func_call (exists) @1907:22` and named
  after the ARGUMENT while being SPANNED at the ARRAY's declaration
  (`int visited[uvm_phase]`, uvm_phase.svh:1896), and ours is the loop
  variable. This is **r10uvm184's R2 named in its own README**: an ARRAY
  receiver's built-in method binds its argument to an `int_var` NAMED AFTER THE
  ARGUMENT and spanned at the RECEIVER's declaration, which is a family of its
  own that § 184's STRING fence deliberately kept out. `head_pat_*.cmp`.
* **R1 — the EXPLICIT-import copy.** `import P::fn;` produces a copy that golden
  binds exactly like the wildcard clone, and this law cannot fire there because
  BOTH the map (`pkgImportCloneEmit`) and the registry `pkgCloneBodyLocals9` are
  wildcard-only. Surelog does not distinguish them — `importPackage`'s
  `object_name` filter selects WHICH task_func to clone, not HOW. **Corpus
  incidence: zero** — the superset predictor, which cannot tell the two apart,
  names no such cell in 956 + 1358 databases. (r10uvm186's R1, r10uvm184's R1
  and r10uvm189's R1 are the same face for their own laws.)
* **R2 — the element AFTER the base, in the corpus.** Every corpus `new[...]`
  path spells its method with parens, so the element after the base is a
  `method_func_call` that `bindable37` refuses and golden leaves BARE — the
  corpus has no cell for § 182's mint here. Arm A shows the PARENS-LESS
  spelling does take the mint in golden and now takes it here too, so the
  family is complete; there is simply nothing in UVM for it to move.
* **R3 — the `new[...]` clone's missing `vpiFullName`.** Unchanged and still
  r10uvm186's R2: golden's clone prints
  `vpiFullName:adpcm_pkg::uvm_packer::get_bytes::sz` on the argument where we
  print none, because the `NewArray` arm calls `stripRefFullNames11`
  unconditionally. Gating that strip makes the DEF-view clone byte-identical
  and costs one AWAY per key in the ELAB view; `VpiFullName` is read by no
  generated `Compare` (RESUME §9), so the axis is worth nothing to the judge and
  the AWAY is not worth taking.
* **R4 — the `foreach`-index SHAPE inside a `new[...]` path.** Golden renders
  `shelf191[ix191].gable191`'s index as the base of a `bit_select` (a SELBASE
  row) and we render it as a later `Path_elems` entry (an HPINNER row), which is
  why arm C's face-keyed score shows 2 ONLY-OURS-MOVED that the face-blind score
  turns into TOWARD: the ACTUAL we now write is exactly golden's
  `ref_var (ix191) @68:23`. The SHAPE difference is identical on both binaries
  and predates this pass; it belongs to whichever law owns
  `emitSyntaxExpr`'s indexed-member path.
* **R5 — a pointer-valued constant in an associative-array typedef range.**
  `typedef int ka_str_t[int];` (r10buvm22's `g22.sv:70`) makes our emitter write
  a `constant` whose `vpiSize:64` `UINT` value is a raw static ADDRESS
  (`22621945` pristine, `22626041` patched — exactly one 4096-byte page apart).
  It is the DECODED static-address false mover, identical on both binaries in
  every way that is not the address, present in three probe arms and in **zero**
  corpus rows. It is not this pass's, but it is worth naming: a constant that
  serialises a pointer is a latent nondeterminism in any pass that changes the
  binary's size.

---

## 9. REPRODUCING

```sh
g++ -O2 -std=c++17 ct191hpb.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
    -luhdm -lcapnp -lkj -o ct191hpb

./ct191hpb own    <golden.uhdm> <ours.uhdm>          # which field the judge stops on, both sides
./ct191hpb skip   <golden.uhdm> <ours.uhdm> [rounds] # the heads BEHIND the first one
./ct191hpb refs   <db.uhdm> <name>                   # every reference, its face, ctx, listing, actual
./ct191hpb newhp  <db.uhdm>                          # every new[...] hier_path, every element
./ct191hpb cenall <db.uhdm>                          # one row per bindable reference
./ct191hpb pred   <golden.uhdm> <ours.uhdm>          # the movable cells of this pair

CT191=./ct191hpb ./grid191.sh g191_a_face.sv  <pris.bin> <pat.bin> <workdir>
CT191=./ct191hpb ./grid191.sh g191_b_ctx.sv   <pris.bin> <pat.bin> <workdir>
CT191=./ct191hpb ./grid191.sh g191_c_scope.sv <pris.bin> <pat.bin> <workdir>
python3 score191.py <wd>/cen.g.<view>.txt <wd>/cen.a.<view>.txt <wd>/cen.b.<view>.txt [-v] [--noface]

CT191=./ct191hpb ./predict191.sh <PRISTINE workdir> <out.txt>
CT191=./ct191hpb ./cenall191.sh  <pris wd> <pat wd> <outdir> SeqDriver MiniAmiq SimpleUVM Scoreboard BuildUVMPkg
PRI=<pris.bin> PAT=<pat.bin> ROOT=<copy of tools/probe> BWD=/tmp/r10uvm191_bound ./bound191.sh
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
./canaries.sh <fresh.csv> <baseline.csv>;  EXPECT_UNKNOWN=<n> ./ctcan2.sh <baseline.csv> <fresh.csv>
bash canaudit.sh canaries.sh ctcan2.sh
```

Recorded outputs: `HEADS.r10uvm191.txt`, `GRID.r10uvm191.txt`,
`CENSUS.r10uvm191.txt`, `PREDICT.r10uvm191.txt`, `MOVERS.r10uvm191.txt`,
`BOUNDARY.r10uvm191.txt`, `GATES.r10uvm191.txt`, and the per-row
`head_pris_*.cmp` / `head_pat_*.cmp` (SimpleUVM's own 664681-line cmp log is a
depth artifact and is deliberately not carried here).
