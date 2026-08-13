# r10uvm68 — `§ atomVarSignedWritten68`: the 58-line head **CLEARED on all THREE target rows**, 15 objects / 16 dump lines, exactly as predicted — and **the brief's "ONE law may clear both" hypothesis is REFUTED: golden stamps the typespec and omits it on the variable, and the typespec was already right**

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after, and no conversion
was expected. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) are **byte-identical** to the
committed baselines — whole ROW, dump column included — **0 differing ROWS** on
both.

**SECOND LINE.** The briefed head is **GONE from all three target row-modes**
(`SimpleUVM/default`, `SimpleUVM/testflags`, `Scoreboard/default`). All three
were `58` cmp lines with the identical head
`int_var uvm_pkg::uvm_text_recorder::m_set_attribute::file @1038:18` whose ONLY
divergence was an extra `|vpiSigned:1` on our side; all three now sit at `112`
cmp lines on a new head in a different family — golden
`func_call (open_recorder)@343:13` versus our
`method_func_call (m_do_open)@343:27`. `58 → 112` is **HEAD DEPTH, not
distance**: the head object changed, so the old divergence is gone.

**THIRD LINE, and it is the finding worth more than the law. THE BRIEF'S SIBLING
HYPOTHESIS IS REFUTED, AND THE REFUTATION *IS* THE DISCRIMINATOR.** The brief
said:

> "The SIBLING `int_typespec (UVM_FILE)@313:9` carries `vpiSigned:1` on our side
> too — check whether golden omits it there as well; **if so ONE law may clear
> both.**"

**Golden carries `vpiSigned:1` on that typespec too.** Not "as well omitted" —
*stamped*, and stamped on **64 of 64** named `int_typespec` objects in the
SimpleUVM golden, `UVM_FILE@313:9` among them (§2.3). There is nothing to clear
there; our typespec was already right. The two carriers on ONE declaration
**disagree**, and that disagreement is the whole law:

| carrier | keys on | `typedef int UVM_FILE; UVM_FILE file;` |
| --- | --- | --- |
| the VARIABLE (`int_var`) | the type **AS WRITTEN** | **NO `vpiSigned`** ← this pass |
| the TYPESPEC (`int_typespec`) | the **RESOLVED** type | `vpiSigned:1` (already correct) |

That is the exact structure `§ arrayElemTsSignedParented9` (r10oth9) found for
arrays, and this pass is its **scalar sibling** — the brief's guess at the
*family* was right and its guess at the *cell* was wrong. Had I "cleared both",
I would have removed 10 correct `int_typespec` flags in SimpleUVM alone and
opened a new divergence where none existed.

Base **df0cdae**. Worktree `/tmp/wt_r10uvm68`; pristine control worktree
`/tmp/wt_r10uvm68pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print `df0cdae49428e3317fdfc59bef8c0800b53dc998`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine df0cdae) | `fc59a2414877316104c88c8c1fe43b77` | my own build of the base commit |
| **SHIPPED (patched)** | **`c7900a56e4ed369ce31987a75c105171`** | every number below was measured on THIS binary |

BUILD DIRS (absolute): `/tmp/wt_r10uvm68/build`, `/tmp/wt_r10uvm68pris/build`.
`[100%] Linking CXX executable slang-uhdm` → `[100%] Built target slang_uhdm`
was read before any md5 was taken; every md5 was asserted in its own command
against `^[0-9a-f]{32}$`. `git stash` was never used. `results/*.csv` were only
ever READ. slang was not patched. `GOLDEN_DEFER` was left **UNSET** (echoed as
`[UNSET]` at both sweep launches). The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched — `canaudit.sh` proves it mechanically (FENCE-BREACH=0).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script
in this directory.

**A NOTE THE MAIN TREE FORCED.** At the start of this pass
`/home/heyfey/git-repos/slang-uhdm` had `src/ModuleEmit.cpp` **staged as
modified** (another live pass integrating) while `HEAD` still read `df0cdae`, so
the main tree's `build/slang-uhdm` (`d1e122cf2a4999c362efa0ef536765c7`) is **NOT
a df0cdae binary** and was never used for a single number here. Everything was
measured against `fc59a241…`, which I built from scratch in my own pristine
worktree. This is the campaign's stale-binary trap catching a *real* stale
binary rather than a hypothetical one — **print and grep-check every binary's
BASE** is not ceremony.

---

## 0. THE LAW

### § atomVarSignedWritten68

*`vpiSigned` on a **SCALAR PREDEFINED-INTEGER-ATOM variable object** at
**SUBROUTINE / STATEMENT scope** keys on the atom being **WRITTEN AT THE
DECLARATION**. A type **NAME** — a typedef at any chain depth, written
package-qualified or reached by wildcard import — carries no signing syntax, so
Surelog's `compileVariable` computes no signedness and the variable object gets
**nothing**. This holds for all five signed atoms (`int`, `integer`,
`shortint`, `longint`, `byte`) and at **every** declaration site a subroutine
has: the return variable (in-class, out-of-body `extern`, package-homed,
DPI-import prototype and PURE VIRTUAL prototype alike), a body local, a
`begin` / named-`begin` / `fork` / `initial` / `always_comb` block local, and a
for-header loop variable. The **TYPESPEC** the variable points at goes the
OTHER way and is already correct: it keys on the **RESOLVED** type and IS
stamped.*

```
uvm-1.2/src/base/uvm_object_globals.svh
313  typedef int UVM_FILE;
uvm-1.2/src/base/uvm_recorder.svh
1037  if (open_file()) begin
1038     UVM_FILE file = m_text_db.m_file;      <- the head: golden gives the
1039     $fdisplay(file, "...", ...);              int_var NO vpiSigned, we did
1040  end
```

This is the third member of a family the campaign has now decoded three times,
and the three rules are NOT the same rule:

| carrier | law | keys on |
| --- | --- | --- |
| module- / class-scope variable | `namedTy9` (r10c15, `makeVar`) | the type **AS WRITTEN** — already correct at df0cdae |
| `array_var` | `§ arrayVarSignedWritten8` (r10oth8) | the ELEMENT type **AS WRITTEN** |
| array ELEMENT typespec | `§ arrayElemTsSignedParented9` (r10oth9) | the element type **RESOLVED** |
| **subroutine/statement-scope atom variable** | **`§ atomVarSignedWritten68`** | the type **AS WRITTEN** |
| scalar atom TYPESPEC | *(no law needed — already correct)* | the type **RESOLVED** |

### STATED GATE == CODE GATE — read off the source, not the comment

One predicate, `clearNamedAtomSigned68`, in `src/EmitHelpers.h`, applied
**post-factory** at **7 call sites**:

```bash
grep -n "atomVarSignedWritten68"   src/EmitHelpers.h src/TaskFuncEmit.cpp src/StmtEmit.cpp src/ModuleEmit.cpp
grep -c "clearNamedAtomSigned68("  src/EmitHelpers.h src/TaskFuncEmit.cpp src/StmtEmit.cpp src/ModuleEmit.cpp
#   src/EmitHelpers.h:1  (the definition)
#   src/TaskFuncEmit.cpp:4  src/StmtEmit.cpp:2  src/ModuleEmit.cpp:1  (the 7 sites)
```

The code gate is **exactly three tests**, in this order, and nothing else:

```cpp
if (!v) return;                                                       // (0) null-safe
if (declared.kind != SymbolKind::TypeAlias) return;                   // (1) reached through a NAME
if (declared.getCanonicalType().kind != SymbolKind::PredefinedIntegerType) return;  // (2) an ATOM
v->VpiSigned(false);
```

* **(1) is FLAT, not recursive, and that is measured, not assumed.** slang models
  `typedef c1_t c2_t;` as a `TypeAlias` whose target is another `TypeAlias`, so
  one test covers a chain of any depth (arm a3 `x_td1` depth 1 and `x_td3`
  depth 3, both golden `-`, both now ours `-`). No `PackedArrayType` descent is
  needed here — unlike `§ arrayVarSignedWritten8`'s clause (b) — because a
  packed wrapper makes the canonical type a `PackedArrayType` and test (2)
  rejects it before test (1) can matter.
* **(2) narrows to `PredefinedIntegerType` deliberately.** `bit` / `logic` /
  `reg` and packed vectors never carry the flag on the VARIABLE at this scope on
  either side, and a **named `time`** carries nothing on either side (arm a2
  `t_time` / `r_time`, both `-` before and after). Widening (2) would extend the
  edit past the population it was measured on.
* **`VpiSigned(false)` is how this emitter clears the flag** — `makeVar` already
  writes `VpiSigned(pit.isSigned && !namedTy9)`. `vpiSigned` is a plain bool with
  no unset state and the dump prints it only when true.

### WHY POST-FACTORY, and why that is the safe half of the design

`makeReturnVar` is the natural home for the gate and **must not have it**:
it is ALSO the **ELEMENT-REG factory** (`TypeEmit`'s `emitArrayVar`,
`TaskFuncEmit`'s queue/dynamic block-item arms, `ParamEmit`'s package array,
`StmtEmit`'s block array arm — six call sites), and those sites hand it an
**array ELEMENT type**, which can itself be a typedef alias. Element-variable
signedness is `§ arrayVarSignedWritten8` / `§ arrayElemTsSignedParented9`
territory, **fenced by this pass's brief**. Gating inside the factory would have
changed it silently. Two of the seven sites therefore carry an explicit
element-guard:

* **site 4** (`TaskFuncEmit`, the tf-item / block-item local) is gated on
  `lt9 == &fmv.getDeclaredType()->getType()` — the loop above it descends into
  array elements, and when it has descended the object is an element var, not
  the declaration's own.
* **site 5** (`StmtEmit`, the block-item local) sits in the `else` arm *after*
  the array/queue arm that mints its own element reg; that arm is untouched.

The measurement that this fence holds is **`--list` on both sides plus the corpus
byte verifier**: no `array_var`, no element `vpiReg`, no `bit_var`, no
`logic_var` and no typespec population moved by a single object on any of the
four UVM databases (§2.2), and `u2r` moved **0 of 1358 databases** (§5).

### The seven sites, each with the arm cell that demands it

| # | file | what declares the variable | arm cell |
|---|---|---|---|
| 1 | `src/TaskFuncEmit.cpp` | PURE VIRTUAL prototype's synthesized return var | a5 `18:25` `pv_ret` |
| 2 | `src/TaskFuncEmit.cpp` | DPI-IMPORT prototype's synthesized return var | a5 `27:27` |
| 3 | `src/TaskFuncEmit.cpp` | THE ordinary return var (in-class / `extern` body / package / module) | a5 `12:12` `pkf`, `21:10` `V5::ex_ret`, `29:12` `selfref`; a1 `f_ret_t`, `f_mret_t` |
| 4 | `src/TaskFuncEmit.cpp` | subroutine BODY local | a1 `t_loc` `t_loci` `t_tsk` `t_mfloc`; a5 `22:13` `ex_loc` |
| 5 | `src/StmtEmit.cpp` | BLOCK-item local (`begin`, named `begin`, `fork`, `initial`, `always_comb`) | a1 `t_blk` `t_ini`; a5 `33:9` `ac_loc`, `37:9` `nb_loc`, `40:13` `fk_loc` |
| 6 | `src/StmtEmit.cpp` | FOR-HEADER loop variable | a1 `t_for` |
| 7 | `src/ModuleEmit.cpp` | `drainFuncRet`'s per-reference body-local return var | a5 `29:12` `selfref` (elab view) |

**Site 6 is the one a "just gate makeReturnVar" patch would have missed
entirely**: the for-header arm does NOT go through `makeReturnVar` for an
integer atom — `intLoopVar` mints the var itself and the pre-existing line
stamps the flag off the **canonical** type, which is precisely the
typedef-piercing this law forbids. Arm a1's `t_for` is the cell that caught it.

### COLLISION CHECK — one ADJACENCY, no collision

**Site 7 is the object `§ retLocalPkgRangeBind67` owns** (`drainFuncRet`'s
per-reference body local, pass 67, just landed, the pass this head came from).
It is a **different field on the same object**: 67 sets `tfTypeScope` *before*
compiling the return type so a range bound binds; this clears a flag on the
variable *after* the factory. They do not read or write each other's state, and
the comment at site 7 says so at the site. `§ bitsOwnClassPropFold61`
(class-param fold refusals) is untouched. `r10sd1`'s SeqDriver
`class_typespec` slot and `r10earl38`'s `§ genChainBranchScopeThreads38`
(`ModuleEmit ~26281`) are in different regions of `ModuleEmit.cpp` from site 7
(`~20622`); `git apply --check` results are in §7.

---

## 1. THE CENSUS, BOTH SIDES, SPAN-KEYED — RUN FIRST, BEFORE ANY CODE

The standing rules require the census before the theory, and it is what made
this pass cheap: **the discriminator fell out of one table.**

`ct68census.py` on the SimpleUVM/default GOLDEN dump (1 140 700 content lines,
`sed 1d`), every variable kind × whether its typespec is NAMED (reached through
a typedef / type parameter) or ANON (written at the declaration) × `vpiSigned`:

```
$ python3 ct68census.py g_simpleuvm_default.dump      # LHS = GOLDEN
bit_var          ANON:bit_typespec          signed=-     685
bit_var          NAMED:bit_typespec         signed=-     193      <- 193/193 NAMED, ZERO stamped
byte_var         ANON:byte_typespec         signed=-     9
byte_var         ANON:byte_typespec         signed=1     8
int_var          ANON:int_typespec          signed=-     380
int_var          ANON:int_typespec          signed=1     596
int_var          NAMED:int_typespec         signed=-     34       <- 34/34 NAMED, ZERO stamped
integer_var      ANON:integer_typespec      signed=-     2
integer_var      ANON:integer_typespec      signed=1     45
logic_var        NAMED:logic_typespec       signed=-     15       <- 15/15 NAMED, ZERO stamped
long_int_var     ANON:long_int_typespec     signed=-     4
time_var         ANON:time_typespec         signed=-     31
```

**In 1.14 M lines of golden there is not ONE counterexample**: no variable whose
typespec is NAMED carries `vpiSigned`, in any of the three kinds where the shape
occurs (242 objects). That is the whole law, read off golden before a line was
written.

`ct68ctrex.sh` then took the hunt to **every golden this pass can reach** — all
EIGHT UVM databases (both modes of `SimpleUVM`, `Scoreboard`, `SeqDriver`,
`BuildUVMPkg`) and the five arm goldens:

```
DUMP                     NAMEDOBJS  COUNTEREXAMPLES
g_bp_def / g_bp_tf            2114 / 2114        0 / 0
g_sb_def / g_sb_tf            1984 / 1983        0 / 0
g_sd_def / g_sd_tf            2970 / 2970        0 / 0
g_simpleuvm_default / g_su_tf 1990 / 1990        0 / 0
the five arm goldens          13,17,10,2,14      0 each
---- NAMED-typespec variable OBJECTS examined: 18171   COUNTEREXAMPLES: 0
LAW HOLDS on every dump given
```

**18 171 golden objects, 0 counterexamples.** The script exits 4 rather than
report on 0 objects, so "0 out of 0" cannot be mistaken for this.

The same table on OUR pristine side names the mover population exactly:

```
$ python3 ct68census.py p_simpleuvm_default.dump      # RHS = OURS, pristine
int_var          NAMED:int_typespec         signed=-     17
int_var          NAMED:int_typespec         signed=1     15       <- THE MOVERS
```

`--list int_var` splits those 32 objects with no ambiguity at all:

| our `vpiSigned` | count | `vpiParent` kind | what they are |
|---|---|---|---|
| `-` (already right) | **17** | `class_defn` × 17 | CLASS PROPERTIES — already gated by `makeVar`'s `namedTy9` |
| `1` (**the movers**) | **15** | `function` 8 / `assignment` 4 / `begin` 3 | SUBROUTINE-scope: return vars, initialised locals, block locals |

**17/17 vs 15/15 on one axis.** The gap is not "class vs subroutine" by
coincidence — it is precisely the boundary between the factory that already has
the gate (`makeVar`) and the factory that does not (`makeReturnVar` and the
for-header arm). The census located the code before the code was read.

### 1.1 The head, verbatim, and what is wrong with it

`uhdm-cmp golden ours` on SimpleUVM/default, pristine, is **58 lines**, and the
LHS and RHS blocks are byte-identical except for ONE line:

```
 int_var: (uvm_pkg::uvm_text_recorder::m_set_attribute::file), line:1038:18, endln:1038:22
 |vpiParent:      \_assignment: , line:1038:18, endln:1038:41
 |vpiTypespec:    \_ref_typespec: (...::file)
                    |vpiActual:  \_int_typespec: (UVM_FILE), line:313:9, endln:313:12
 |vpiName:file
 |vpiFullName:uvm_pkg::uvm_text_recorder::m_set_attribute::file
+|vpiSigned:1                                   <- RHS ONLY.  the entire head.
```

`int` IS signed in SystemVerilog, so the flag is semantically true and golden
still omits it. The question the brief posed — *what is Surelog's EMISSION
policy?* — is answered by §1 and §2: **written keyword yes, type name no.**

---

## 2. THE GRID, CELL FOR CELL

Six arms, **152 cells** (119 on the law's own population plus a6's 33 on the
FENCED array population), both sides listed at their own object depth, keyed on
the SOURCE SPAN (`KEY=span`) so a NAMING residue cannot drop a cell into
`UNMEASURED` on both sides and hide the disagreement — which is exactly what
happened to the DPI cell under a name key and is why the key mode exists.

| arm | what it grids | PRISTINE | PATCHED |
|---|---|---|---|
| `a1_scope.sv` | the SAME `int`, written vs typedef'd, at 15 SCOPES (class property, module var, class/module function return, method local, method local + init, begin-block local + init, task local, initial-block local, for-header) | cells=31 EQ=22 **DIFFER=9** | cells=31 **EQ=31 DIFFER=0** |
| `a2_atom.sv` | the ATOM axis at subroutine scope: `int` `integer` `shortint` `longint` `byte` `time` `int unsigned` `byte unsigned`, written vs typedef'd, as locals AND as returns | cells=33 EQ=23 **DIFFER=10** | cells=33 **EQ=33 DIFFER=0** |
| `a3_flavour.sv` | HOW the name is reached: typedef chain depth 1 and 3, `pkg::name` qualified, the same imported unqualified, `parameter type` | cells=22 EQ=14 **DIFFER=8** | cells=22 **EQ=22 DIFFER=0** |
| `a4_typaram.sv` | **NEGATIVE CONTROL**: a class TYPE PARAMETER bound to `int` — already a `ref_var` via `§ typeParamVarIsRefVar58`, which this law must not reach | cells=13 EQ=13 **DIFFER=0** | cells=13 **EQ=13 DIFFER=0** |
| `a5_proto.sv` | the sites a1–a3 do NOT reach: PURE VIRTUAL prototype, DPI-IMPORT prototype, `extern` out-of-body body + local, package function whose return NAME is referenced, `always_comb` local, named-`begin` local, `fork`-arm local | cells=20 EQ=10 **DIFFER=9** UNMEASURED=1 | cells=20 **EQ=19 DIFFER=0** UNMEASURED=1 |
| `a6_tdarray.sv` | **FENCE CONTROL**: a typedef'd atom as an ARRAY ELEMENT (fixed / dynamic / queue / assoc function local, block-item array local, unpacked-array return, class-property array, package array) — `§ arrayVarSignedWritten8` / `§ arrayElemTsSignedParented9` territory, which this law must NOT reach | cells=33 EQ=28 DIFFER=5 | cells=33 **EQ=28 DIFFER=5 — UNCHANGED, and our dump is BYTE-IDENTICAL** |
| **total** | | **152 cells, DIFFER=41** | **152 cells, DIFFER=5** |

**The 5 survivors are ALL in a6**, they are identical before and after, and they
are a defect in the FENCED area, ranked **R0** in §6 with the fix located and
deliberately not taken. On the 119 cells of the law's own population,
**DIFFER 36 → 0**.

`DIFFERKIND` (both sides emit an object of a different variable class) was **0
before and after** — this pass changes a FIELD and no object kind, and the arm
grid asserts it rather than assuming it. The single `UNMEASURED` cell is arm a5
`19:19`: golden emits a variable for the `extern` PROTOTYPE inside the class and
we emit none. That is an object-population residue, ranked **R3**, and it is
`-`/`absent` on the signedness axis either way.

### 2.1 The two rows of a1 that carry the whole law

```
cell     | GOLDEN                          | OURS pristine                  | OURS patched
p_loc    | int_var  signed=1  ANON:int_ts  | int_var  signed=1  ANON:int_ts | int_var  signed=1   EQ
t_loc    | int_var  signed=-  NAMED:int_ts | int_var  signed=1  ANON:int_ts | int_var  signed=-   EQ
```

`int p_loc;` and `myint_t t_loc;` are the SAME TYPE, one line apart, in the same
method. Golden gives one the flag and the other nothing. Every `p_*` cell in a1
is golden `1`; every `t_*` cell is golden `-`; there is no third case.

### 2.2 a2 proves the atom axis is UNIFORM, and bounds the edit

All five signed atoms behave identically — written `1`, named `-` — as locals
and as return types. `time` is `-` on BOTH sides in BOTH spellings, and
`int unsigned` / `byte unsigned` are `-` on both sides in both spellings. So
test (2) of the gate could not have been narrower (it must cover five atoms) and
must not be wider (`time` and the unsigned atoms need no help, and `bit`/`logic`
are a different population entirely).

### 2.3 THE REFUTATION, MEASURED: the typespec goes the OTHER WAY

`ct68census.py --ts`, both sides, SimpleUVM/default:

```
                       GOLDEN                     OURS (pristine == patched)
int_typespec  ANON  signed=1     543              681
int_typespec  ANON  signed=-     168              137
int_typespec  NAMED signed=1      64               10      <- BOTH sides stamp it
int_typespec  NAMED signed=-       0                0      <- NEITHER side omits it
logic_typespec NAMED signed=1     41               31
bit_typespec  NAMED signed=1       2                2
```

and by name, the exact object the brief pointed at:

```
GOLDEN: int_typespec UVM_FILE   @313:9-313:12  signed=1     (and 27 more UVM_FILE spans, all signed=1)
OURS:   int_typespec UVM_FILE   @313:9-313:12  signed=1
GOLDEN: int_typespec uvm_action @272:9-272:12  signed=1     (and 26 more, all signed=1)
OURS:   int_typespec uvm_action @272:9-272:12  signed=1
```

**64 golden named `int_typespec` objects, 64 stamped, 0 omitted.** The brief's
"if so ONE law may clear both" had no cell to stand on. The `64 vs 10` count gap
is a *typespec-population* residue (golden mints one per reference site, we share
one), ranked **R1**, and it is untouched by this pass — the patched `--ts` table
is byte-identical to the pristine one.

---

## 3. THE CENSUS-PREDICT, RUN BEFORE THE BYTE VERIFIER

`census68src.py` reads SOURCE TEXT and never UHDM. It takes the transitive
closure of typedef names whose base is a **signed** predefined atom, then counts
declarations through those names that are NOT at module/class/package member
scope (those are already gated and cannot move).

```
$ python3 census68src.py <uvm-1.2/src>
scanned files=145   signed-atom typedef NAMES=2          # UVM_FILE, uvm_action
  base/uvm_component.svh       sites=1     base/uvm_report_handler.svh  sites=6
  base/uvm_recorder.svh        sites=2     base/uvm_report_message.svh  sites=11
  base/uvm_report_catcher.svh  sites=5     base/uvm_report_server.svh   sites=1
  base/uvm_tr_database.svh     sites=1
---- PREDICTED SITES: RETURN=7 LOCAL=20 FORVAR=0  TOTAL=27  in 7 file(s)

$ python3 census68src.py <Surelog/tests> <Surelog/third_party/tests> <uhdm2rtlil/test>
scanned files=14611   signed-atom typedef NAMES=18
---- PREDICTED SITES: RETURN=15 LOCAL=58 FORVAR=0  TOTAL=73  in 25 file(s)
```

**THE PREDICTION, MADE BEFORE THE SWEEPS RAN:**

1. **`uhdm2rtlil` moves ZERO databases.** Not one of the 14 611 scanned files in
   the u2r corpus carries the shape. **MEASURED: 0 movers / 1358.**
2. The Surelog corpus can move only the UVM-linked tests plus `SplitFile`,
   `UnitThisNew`, `AmiqEth`, `Rsd`, `Tnoc`, `Verilator/t_package`.
   **MEASURED: §5.**
3. `SimpleUVM/default` moves **15 OBJECTS** and **16 dump LINE INSTANCES** — the
   two numbers differ because `uvm_component::m_set_cl_action::action` is printed
   FULLY TWICE (def view + elab view) and each print carries the flag.
   **MEASURED: 15 objects, 16 removed line instances, exact.**

STATED BOUNDS, so no number is over-read: the site count is EXACT on the shapes
the scanner recognises; it is a LOWER bound on dump-line movers (it counts
neither views nor `drainFuncRet` binding references) and an UPPER bound on any
site whose name is shadowed, whose file is in no test's source set, or which
slang rejects. 27 predicted UVM sites against 15 measured objects is that gap
working in the stated direction, and `-v` prints every site so the
classification is auditable.

---

## 4. PER-SHAPE MOVERS, BY MULTISET, ADDED AND REMOVED SEPARATELY

`mv68.sh <golden> <pristine> <patched>` on each target row-mode:

| row-mode | ADDED line instances | REMOVED line instances | removed shapes |
|---|---|---|---|
| `SimpleUVM/default` | **0** | **16** | `\|vpiSigned:1` at 4 indent depths, and NOTHING ELSE |
| `SimpleUVM/testflags` | **0** | **16** | ditto |
| `Scoreboard/default` | **0** | **16** | ditto |

**A REMOVE-ONLY law, and it is remove-only: ADDED == 0 on all three.**
`mv68.sh` prints `ADD-ONLY FALSIFIED` because its verdict line was written for
an ADD law (r10uvm67's); for a SUPPRESS law the honest reading of the same two
numbers is **REMOVE-ONLY HOLDS: ADDED == 0**. The instrument is quoted
unedited rather than reworded, and the mis-fitting verdict line is named here so
a future reader does not take it for a defect report.

### 4.1 THE MULTISET DISTANCE ROSE BY 2 WHILE THE HEAD CLEARED — and that is the instrument, not the patch

```
SimpleUVM/default    multiset distance to GOLDEN: pristine=143680  patched=143682   (+2)
SimpleUVM/testflags  multiset distance to GOLDEN: pristine=143676  patched=143678   (+2)
Scoreboard/default   multiset distance to GOLDEN: pristine=134013  patched=134013   ( 0)
```

`msdist.sh` compares MULTISETS OF LINE TEXTS and cannot see WHICH object holds a
line. The per-depth three-way count explains the +2 completely:

| indent depth | golden | pristine | patched | our surplus/deficit before → after | distance |
|---|---|---|---|---|---|
| 6 | 216 | 215 | 214 | −1 → −2 | **+1** |
| 8 | 141 | 145 | 143 | +4 → +2 | **−2** |
| 10 | 99 | 101 | 91 | +2 → **−8** | **+6** |
| 16 | 50 | 53 | 50 | +3 → **0 (exact)** | **−3** |
| | | | | | net **+2** |

At depths 8 and 16 we were OVER golden and the removals walk us toward it (depth
16 lands **exactly on golden's 50**). At depths 6 and 10 golden holds
`|vpiSigned:1` on OTHER objects we do not emit at all — the 64-vs-10 named
`int_typespec` deficit of §2.3 — so removing the flag from the RIGHT objects
deepens an UNRELATED deficit and the multiset charges us for it. **The authority
on whether the right object lost the flag is `uhdm-cmp`'s head (§0, cleared on
all three) and the per-object census (§4.2, exact), never this number.** It is
reported because hiding a rising distance would be the worse sin.

### 4.2 THE PER-OBJECT READING — the cell the law owns is EXACT

`ct68census.py`, SimpleUVM/default, the only rows that move:

```
                                      GOLDEN   PRISTINE   PATCHED
int_var  NAMED:int_typespec  signed=1     0        15         0     <- CLEARED, exactly
int_var  NAMED:int_typespec  signed=-    34        17        32     <- 17 -> 32
```

and **every other row of the whole variable table is byte-identical between
pristine and patched** — `int_var ANON signed=1` stays 564, `bit_var NAMED`
stays 170, `byte_var ANON signed=1` stays 8, `array_var` / element-`vpiReg`
populations do not move an object. That is the fence around
`§ arrayVarSignedWritten8` / `§ arrayElemTsSignedParented9` holding, measured
rather than promised.

The residual `34 vs 32` is **2 objects golden emits and we do not** (ranked
**R2**), not 2 objects with a wrong flag: our 32 are all `-`, golden's 34 are all
`-`.

### 4.3 THE TWO NON-TARGET UVM ROWS DID NOT REGRESS

`SeqDriver` and `BuildUVMPkg` keep the SAME head object, byte for byte, before
and after (§5.4). Their heads sit *earlier* in the Compare walk than this law's
site, so they move bytes without moving their head — which is exactly what §5
reports.

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

`/tmp/wt_r10uvm68/build` and `/tmp/wt_r10uvm68pris/build`, absolute paths.
`[100%] Linking CXX executable slang-uhdm` then `[100%] Built target
slang_uhdm` read before any measurement; `grep -c "error:"` = **0**. md5s
asserted in their own commands against `^[0-9a-f]{32}$`:

```
CONTROL  fc59a2414877316104c88c8c1fe43b77   32-HEX OK
SHIPPED  c7900a56e4ed369ce31987a75c105171   32-HEX OK
both worktrees: df0cdae49428e3317fdfc59bef8c0800b53dc998
pristine worktree `git status --porcelain`: EMPTY (no production edit at all)
patched worktree: M src/EmitHelpers.h  M src/ModuleEmit.cpp  M src/StmtEmit.cpp
                  M src/TaskFuncEmit.cpp   ?? tools/probe/r10uvm68repro/
```

`clearNamedAtomSigned68`: **1 definition (EmitHelpers.h), 7 call sites
(TaskFuncEmit 4, StmtEmit 2, ModuleEmit 1)**, and no other production line
changed.

### GATE 2 — GOLDENS, with the negative control

```
SLANG_UHDM=<shipped>  ./tests/check_goldens.sh   ->  PASS=23  FAIL=0
SLANG_UHDM=/bin/false ./tests/check_goldens.sh   ->  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--jobs 2`, own `--out` / `--workdir`

```
[testflags] 731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
            dump column: match 496   differ 183   (blank) 52
[default]   731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
            dump column: match 492   differ 187   (blank) 52   (no committed baseline for this mode)

ct8rows.sh results/gate_uhdm2rtlil.csv <testflags-only extract>:
  baseline 732 lines = 731 ROWS      fresh 732 lines = 731 ROWS
  WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  per-mode STATUS histogram   : identical
  per-mode DUMP histogram     : identical (52 blank / 183 differ / 496 match)
  PASS: every row byte-identical to the committed baseline
```

The committed u2r baseline is **testflags-only** (731 rows, not 1462), so the row
gate ran on a testflags-only extract and the fact is stated rather than hidden.
The `default` histogram is reported for completeness with no baseline to compare
against.

### GATE 4 — surelog, both modes, `--jobs 2`, `GOLDEN_DEFER` echoed `[UNSET]`

```
[default]   794 tests  CMP_EQUAL 469  CMP_NOTEQUAL 11  DEFERRED 5  SLANG_REJECT 284  SURELOG_FAIL 25
[testflags] 794 tests  CMP_EQUAL 465  CMP_NOTEQUAL  8  DEFERRED 5  SLANG_REJECT 286  SURELOG_FAIL 23
                       NO_DATABASE 3  UNTRANSLATABLE 2  TIMEOUT 1  NO_UHDM 1

ct8rows.sh results/golden_surelog.csv /tmp/r10uvm68_sl_pat.csv:
  baseline 1589 lines = 1588 ROWS      fresh 1589 lines = 1588 ROWS
  WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  per-mode STATUS histograms  : identical
  per-mode DUMP histograms    : identical
    default   325 blank / 244 differ / 225 match      (baseline and fresh)
    testflags 329 blank / 300 differ / 165 match      (baseline and fresh)
  PASS: every row byte-identical to the committed baseline
```

Required numbers met exactly: **469/11** and **465/8**, `SURELOG_FAIL` **25/23**,
`DEFERRED` **5/5**, histograms unchanged, **0 rows**.

The PRISTINE control sweep produced a CSV whose 1588 rows are **identical to the
patched sweep's** (`diff | wc -l` = **0**), so every status figure above is a
property of the corpus and of neither binary.

### GATE 5 — BYTE VERIFIER, both corpora, BOTH modes, vs the PRISTINE df0cdae I built

```
surelog  : PATH_SETS_IDENTICAL (953 paths)     MOVERS: 7 / 953
           SELFCHECK  952/953 flagged          SELFCHECK1 = 8   (= 7 real + 1 corrupted)
u2r      : PATH_SETS_IDENTICAL (1358 paths)    MOVERS: 0 / 1358
           SELFCHECK 1357/1358 flagged         SELFCHECK1 = 1   (= 0 real + 1 corrupted)
```

Both negative controls fire in both corpora, so `0 movers` in u2r is a
MEASUREMENT and not a mis-wired driver. The 7 are the census-predicted set
exactly, and nothing else:

```
MOVER ./default/BuildUVMPkg    MOVER ./default/Scoreboard    MOVER ./default/SeqDriver
MOVER ./default/SimpleUVM      MOVER ./testflags/BuildUVMPkg
MOVER ./testflags/SeqDriver    MOVER ./testflags/SimpleUVM
```

(`Scoreboard/testflags` is `SLANG_REJECT` in the baseline and emits no database,
so 4 tests give 7 rows, not 8.)

**AND THE PREDICTION'S OTHER HALF CHECKS OUT TOO.** §3 named six further
candidate test directories. None moved, and the reason is not luck:

```
AmiqEth default/testflags SLANG_REJECT     Tnoc        default/testflags SLANG_REJECT
Rsd     default/testflags DEFERRED         SplitFile   default/testflags SLANG_REJECT
UnitThisNew default/testflags SLANG_REJECT
```

Every one produces NO database on our side, so it cannot move bytes.
`Verilator/t_package.v` belongs to no test's source set at all — the exact bound
`census68src.py`'s docstring states ("it cannot know whether a file is in a
test's source set").

### 5.4 THE OTHER TWO UVM ROWS: bytes moved, heads did NOT

| row-mode | cmp lines pris → pat | head object pris → pat | ADDED | REMOVED | `int_var NAMED signed=1` G / P / Q |
|---|---|---|---|---|---|
| `SeqDriver/default` | 85 → **85** | `class_typespec (adpcm_pkg::type_id)@440:12` → **identical** | 0 | 18 | 0 / 16 / **0** |
| `SeqDriver/testflags` | 85 → **85** | identical | 0 | 18 | 0 / 16 / **0** |
| `BuildUVMPkg/default` | 58 → **58** | `ref_obj (…__deferred_init…)` id:161198 → **identical** | 0 | 17 | 0 / 14 / **0** |
| `BuildUVMPkg/testflags` | 58 → **58** | identical | 0 | 17 | 0 / 14 / **0** |

Their heads sit EARLIER in the Compare walk than this law's site, so they move
bytes without moving their head — and every removed line is `|vpiSigned:1`, 0
added, on both. `int_var NAMED signed=-` goes 17 → 33 (SeqDriver, golden 35) and
17 → 31 (BuildUVMPkg, golden 34), and **every other row of both census tables is
byte-identical between pristine and patched.**

Object-vs-line-instance reconciliation, stated because the two numbers differ and
must: SimpleUVM 15 objects / 16 lines, SeqDriver 16 / 18, BuildUVMPkg 14 / 17 —
the surplus is objects printed FULLY in more than one view.

### MULTI-STABILITY, and the size delta

`detcheck.sh`, `Scoreboard/default`, 3 runs each binary:

| binary | distinct sha256 | bytes (all runs) |
|---|---|---|
| pristine `fc59a241…` | **2** | 11 122 522 |
| shipped `c7900a56…` | **1** | 11 122 508 |

The pristine hash flake is **PRE-EXISTING** — the campaign's known emitter
nondeterminism (SourceLocation compares across macro buffers under parallel
parse) — and per the standing rule, **same size = flake**: the byte size is
stable within each binary across all three runs. The size DELTA is stable and
real: **−14 bytes**, the direction a SUPPRESS law predicts. The shipped binary
drew 1 distinct hash in 3 runs; that is not a claim that the flake is fixed,
only that it did not fire in these three draws.

### CANARIES

```
canaries.sh vs SURELOG baseline : ok=52  changed=0  absent=0  unknown-names=7   (the u2r-only names)
canaries.sh vs U2R baseline     : ok=8   changed=0  absent=0  unknown-names=25  (the surelog-only names)
ctcan2.sh EXPECT_UNKNOWN=1 (sl) : ok=58  changed=0  absent=0  unknown-patterns=1   PASS
ctcan2.sh EXPECT_UNKNOWN=6 (u2r): ok=1   changed=0  absent=0  unknown-patterns=6   PASS
canaudit.sh canaries.sh ctcan2.sh: audited=29  UNCOVERED=0  FENCE-BREACH=0        PASS
```

Both canary scripts were run against **both** baselines, **mode-matched**,
**baseline first**, and the expected-unknown counts were **stated to the script**
rather than read back out of it.

**AN OPS TRAP WORTH RECORDING, because it produced a false red first.** Run
against the FULL patched u2r CSV (1462 rows, both modes) both scripts reported
`absent=8` / `absent=1` and `ctcan2.sh` exited FAIL. Nothing had moved: the
COMMITTED u2r baseline is **testflags-only**, so every `default` row in the fresh
CSV has no baseline partner and is correctly reported ABSENT. Re-run against the
testflags-only extract, `absent=0` and PASS. **An ABSENT is a SCOPE mismatch
until proven otherwise** — and the guard did its job by refusing to call it OK.

BY NAME, both modes, printed side by side with the baseline:

```
InterfaceModPort    default CMP_EQUAL/differ   testflags CMP_EQUAL/differ   SAME
BlackParrotComplex  default CMP_EQUAL/differ   testflags CMP_EQUAL/differ   SAME
SVSwitch            default CMP_EQUAL/differ   testflags CMP_EQUAL/differ   SAME
ApbSlave            default CMP_EQUAL/differ   testflags CMP_EQUAL/differ   SAME
SimpleConstraint    default CMP_EQUAL/differ   testflags CMP_EQUAL/differ   SAME
SeqDriver           default CMP_NOTEQUAL       testflags CMP_NOTEQUAL       SAME
BuildUVMPkg         default CMP_NOTEQUAL       testflags CMP_NOTEQUAL       SAME
SimpleUVM           default CMP_NOTEQUAL       testflags CMP_NOTEQUAL       SAME
Scoreboard          default CMP_NOTEQUAL       testflags SLANG_REJECT       SAME
```

### THE FENCE CONTROL — arm a6, and it found a residue

`a6_tdarray.sv` is the arm the fence in §0 is claimed on: a typedef'd signed atom
used as an ARRAY element at every scope this pass touches — a FIXED / DYNAMIC /
QUEUE / ASSOCIATIVE function local, a block-item array local, an unpacked-array
return through an array typedef, a class-property array and a package array.

```
a6 PRISTINE : cells=33  EQ=28  DIFFER=5  DIFFERKIND=0  UNMEASURED=0
a6 PATCHED  : cells=33  EQ=28  DIFFER=5  DIFFERKIND=0  UNMEASURED=0
OUR DUMP, workdir path NORMALISED : IDENTICAL  -> THE FENCE HOLDS
```

Our dump is **byte-identical before and after** on this arm, so the gate did not
leak into `makeReturnVar`'s six ELEMENT-REG callers. (The raw `cmp` reported
DIFFER on the `file:` field alone, which EMBEDS THE WORKDIR — `dumptree.py`'s own
documented trap, handled by normalising the two workdir paths and named here
rather than quietly fixed.)

**The 5 surviving DIFFER cells are a genuine, previously unrecorded defect in the
FENCED area** — ranked **R0** — and they are identical before and after, so this
pass neither caused nor hid them.

---

## 6. RANKED RESIDUES

Ranked by tests-per-fix × confidence, most valuable first.

0. **`vpiSigned` on the ELEMENT `vpiReg` of a typedef'd-atom ARRAY at
   SUBROUTINE / BLOCK scope — the same "as written" law, ONE CARRIER OVER, and
   DELIBERATELY NOT FIXED HERE.** Arm a6 cells `18:11` `19:11` `20:11` `21:11`
   (a FIXED / DYNAMIC / QUEUE / ASSOCIATIVE function local of `ai6_t` where
   `typedef int ai6_t`) and `39:11` (a block-item array local): golden's element
   var is `-`, ours is `vpiSigned:1`, while the WRITTEN twins (`int w_fix[3]` …)
   agree on `1` and the CLASS-PROPERTY array agrees on `-`.
   **WHY NOT FIXED:** this pass's brief fences array-var signedness to
   `§ arrayVarSignedWritten8` / `§ arrayElemTsSignedParented9`, and those laws
   measured the element `vpiReg` at CLASS / MODULE scope only — r10oth8's own
   words are "golden's `vpiReg` element carries `vpiSigned` in ZERO of the 118
   class-property / module-variable arm cells". SUBROUTINE scope is genuinely
   UNMEASURED there, which is why it still carries the flag on our side.
   **THE FIX IS LOCATED:** the six ELEMENT-REG callers of `makeReturnVar`
   (`TypeEmit.cpp` ~14874, `StmtEmit.cpp` ~1302, `TaskFuncEmit.cpp` ~1191 /
   ~1470 / ~4685, `ParamEmit.cpp` ~20553) plus `TaskFuncEmit` ~4938's descended
   `lt9`; `clearNamedAtomSigned68` is already the right predicate and takes the
   ELEMENT's declared type. A pass that owns the array carriers should grid a6
   properly (it has only 5 cells today) and take it. **This is a COLLISION
   NOTICE, not a claim of ownership.**
1. **The named `int_typespec` POPULATION: golden 64, ours 10** on
   SimpleUVM/default (§2.3), with the same ratio on the other three UVM tests.
   Golden mints a fresh `int_typespec (UVM_FILE)` at EVERY reference site
   (28 distinct `UVM_FILE` spans, 27 distinct `uvm_action` spans); we share one
   object per typedef. Both sides stamp `vpiSigned:1` on all of them, so this is
   an OBJECT-COUNT residue and not a field residue — but it is what makes
   §4.1's multiset distance rise, and it is the largest remaining `vpiSigned`
   deficit in the UVM dumps.
2. **2 named `int_var` objects golden emits and we do not** — SimpleUVM 34 vs 32,
   SeqDriver 35 vs 33, BuildUVMPkg 34 vs 31. All of ours are correctly `-`; the
   gap is object population, not the flag. Same family as R3.
3. **The `extern` PROTOTYPE inside a class gets no variable from us** — arm a5
   cell `19:19`, golden emits an `int_var` for the in-class `extern function q_t
   ex_ret();` declaration and we emit none. The out-of-body definition's return
   var we DO emit and it is now correct. 1 cell, `UNMEASURED` before and after.
4. **A named `enum_var` carrying `vpiSigned:1` on BuildUVMPkg where golden has
   none — 1 object, PRE-EXISTING and unchanged by this pass** (census table
   §5.4: `enum_var NAMED:enum_typespec signed=1 = 1` in pristine AND patched,
   golden 0). This is the same "as written" law on a THIRD variable class, and
   the gate's test (2) deliberately does not fire on it because no arm here
   grids `enum` signedness. A one-object lead for whoever takes the enum family.
5. **Naming residues our side carries on the objects this pass fixed**, all
   unchanged by it: our `int_typespec` at subroutine scope is ANON where golden's
   is NAMED (every `t_*` cell in a1/a2/a3), and our DPI-import return var is
   named `dpi_ret` where golden names it `q_t` (arm a5 `27:27`). Neither is a
   signedness question, and `KEY=span` exists in `ct68cells.py` precisely so the
   second one could not hide the cell.
6. **The new head on all three target rows** (112 cmp lines): golden
   `func_call (open_recorder)@343:13` versus our
   `method_func_call (m_do_open)@343:27` in
   `uvm_tr_stream::open_recorder` (`uvm_tr_stream.svh:343`). A CALL-SHAPE
   divergence — golden resolves the call to the enclosing `open_recorder`
   function while we bind it to the `m_do_open` method one token later — in the
   same family as `§ parensLessCallIsPathRefObj` (r10svs2). **PRE-EXISTING and
   UNMASKED, not caused**: it is present in the pristine dump; the old head
   merely sorted ahead of it. This is the next pass's head.

---

## 7. THE PATCH, AND THE MANIFEST

**`/tmp/r10uvm68.patch`** — `git diff` vs `df0cdae`, production plus
`tools/probe/r10uvm68repro` only, nothing else.

```
27 files changed (4 production, 23 in tools/probe/r10uvm68repro)
  src/EmitHelpers.h    +66     the ONE predicate, clearNamedAtomSigned68
  src/TaskFuncEmit.cpp +22     sites 1-4
  src/StmtEmit.cpp     +16     sites 5-6
  src/ModuleEmit.cpp    +8     site 7
  tools/probe/r10uvm68repro/*  6 arms, 12 drivers, this README, README.verifier.md
```

**COLLISION CHECK — NO COLLISION, and it was checked against the head that
actually exists.**

```
git apply --check on a fresh df0cdae worktree                 -> CLEAN
git apply --check on branch head 983cf4b                      -> CLEAN
re-`git diff` of the applied df0cdae tree                     -> SAME md5 (round-trips)
apply + re-`git diff` on 983cf4b                              -> CLEAN; a DIFFERENT md5,
   because 983cf4b's own ModuleEmit.cpp blob is the diff base there.  That is
   expected and is NOT a collision: the apply-check is the collision statement.
```

The one commit that landed since my base is **`983cf4b` = r10earl38,
`§ genChainBranchScopeThreads38`**, one of the live passes my brief named. It
touches `src/ModuleEmit.cpp` around **~26281**; my site 7 is at **~20622**, so
the hunks apply unchanged. `src/EmitHelpers.h`, `src/StmtEmit.cpp` and
`src/TaskFuncEmit.cpp` were untouched by it.

`§ retLocalPkgRangeBind67` (site 7's object), `§ bitsOwnClassPropFold61` and
`r10sd1`'s SeqDriver `class_typespec` slot are all discussed in §0's collision
paragraph; the only relationship is the ADJACENCY at site 7, on a different
field of the same object.

### THE MANIFEST — every file here, and it RUNS

`./manifest.sh` prints it. Six ARM sources and twelve DRIVERS, plus this README
and `README.verifier.md`:

| file | what it is |
|---|---|
| `a1_scope.sv` | the SCOPE grid: one `int`, written vs typedef'd, at 15 scopes |
| `a2_atom.sv` | the ATOM grid: 5 signed atoms + `time` + 2 unsigned, locals and returns |
| `a3_flavour.sv` | HOW the name is reached: chain depth 1/3, `pkg::`, imported, `parameter type` |
| `a4_typaram.sv` | NEGATIVE CONTROL: a class type parameter (`ref_var`) this law must not reach |
| `a5_proto.sv` | the sites a1–a3 miss: pure virtual, DPI import, `extern` body, `always_comb`, named begin, fork, drain |
| `a6_tdarray.sv` | THE FENCE CONTROL: typedef'd atom as an ARRAY element at every scope (r10oth8/9's territory) |
| `ct68arm.sh` | the arm driver (`SLANG_UHDM` has NO default; `sed 1d` both dumps; missing input is fatal) |
| `ct68cells.py` | the cell grid, `KEY=name` or `KEY=span`, both sides, UNMEASURED never conflated with `-` |
| `ct68census.py` | the span-keyed one-side census: VARS table, `--list KIND`, `--ts` |
| `ct68ctrex.sh` | THE COUNTEREXAMPLE HUNT: refuses to report on 0 objects; 18 171 examined, 0 found |
| `census68src.py` | the census-predict, source text only, bounds stated in its docstring |
| `mv68.sh` | per-shape movers, ADDED and REMOVED never netted, three-way counts |
| `msdist.sh` | the resync-immune multiset distance (whitespace-preserving) |
| `ct8rows.sh` | the row gate: whole-row diff + per-mode status and dump histograms |
| `byteverify.sh` | the byte verifier with BOTH negative controls |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the three canary layers |
| `detcheck.sh` | per-binary determinism, N reps |
| `dumptree.py` | the shared dump parser (backrefs, workdir-embedding `file:`, indentation-as-depth) |
| `manifest.sh` | this table, generated |

## 8. WHAT THIS PASS REFUTED, PLAINLY

1. **"The sibling `int_typespec` may need the same clearing; ONE law may clear
   both."** **REFUTED, 64/64.** Golden stamps `vpiSigned:1` on every named
   `int_typespec`, `UVM_FILE@313:9` included, and so do we. Acting on the brief
   would have deleted 10 correct flags in SimpleUVM alone. The two carriers on
   one declaration disagree, and that disagreement is the law.
2. **"Candidate axes to grid: direct `int` vs typedef'd; class-method local vs
   class property vs module var; declaration-with-initialiser vs bare; var vs
   typespec object."** Three of the four axes are **NOT discriminators**:
   * *class-method local vs class property vs module var* — not an axis of
     GOLDEN's rule at all (golden omits the flag for a named type at ALL THREE);
     it is an axis of OUR BUG, because two of the three factories already had the
     gate. a1 `t_prop` / `t_mvar` are EQ before the patch and `t_loc` is not.
   * *declaration-with-initialiser vs bare* — **no effect on either side**
     (a1 `t_loc` vs `t_loci`, `p_loc` vs `p_loci`, all four agree with the rule).
   * *var vs typespec object* — a real axis, but the opposite way round from the
     brief's reading (item 1).
   Only **direct vs typedef'd** discriminates, and it does so on its own.
3. **`§ arrayVarSignedWritten8`'s predicate is NOT reusable here** — for the
   third time in this family. Its clause (b) whitelists a `ScalarType`
   (`bit`/`logic`/`reg`) and recurses through `PackedArrayType`; both would be
   wrong here, since at this scope `bit`/`logic` variables carry the flag on
   NEITHER side and a packed wrapper never reaches the atom arm. Reuse would have
   been a wider edit with no cell to justify it. **One family, four carriers,
   four predicates.**
4. **A "one-line fix in `makeReturnVar`" would have been wrong twice** — it would
   have missed the for-header arm (site 6, which never calls the factory for an
   atom) and it would have silently re-gated the six ELEMENT-REG call sites that
   belong to r10oth8/r10oth9. Neither is visible without the arm grid.

---

*The patch md5 is deliberately NOT quoted in this file: this README is INSIDE the
patch, so any md5 written here would be stale the moment it was written. It is
reported with the delivery.*
