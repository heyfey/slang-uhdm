# r10uvm143 — § `hpIdxClassBodyNeverLateBinds143` — **A CLASS BODY'S LATE-BINDING POOL IS NEVER DRAINED** — the `uvm_objection::wait_for` head CLEARED on three row-modes, 9 databases, 0 corpus rows changed

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `41e67d5` (= UVM pass 141) |
| pristine binary | built from a clean worktree at `41e67d5`, frozen `chmod 555` before any sweep; its head logs reproduce the brief's head object for object |
| patched binary | frozen `chmod 555` before any sweep |
| production surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` ONLY — one new helper and five one-line calls |
| probe surface | `tools/probe/r10uvm143repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SimpleUVM default / testflags** | 29 cmp lines, head = `LHS: <null>` vs our `io_decl (obj)` on `uvm_pkg::uvm_objection::wait_for` | **head CLEARED** — 62 lines on a NEW head object of a different family |
| **Scoreboard default** | 29, the same head | **head CLEARED**, the same new head |
| SeqDriver default / testflags | 26, 1 head | head log **BYTE-IDENTICAL** — its cell sits below the head |
| MiniAmiq default / testflags | 26, 1 head | head log **BYTE-IDENTICAL** |
| BuildUVMPkg default / testflags | 55, 1 head | head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 110 / 142, 1 head | head logs **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL), byte-identical |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this pass's own pristine sweeps |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the nine **PREDICTED BY NAME** from the pristine databases before the patched sweep ran, each a **2-line** order-blind dump delta |
| the law's corpus population | 9 wrong cells in 9 databases | **0** — and the select COUNT is unchanged in every one (a binding is removed, never an object) |
| the law's whole-design cell census (SimpleUVM/default) | `AGREE 125 / OURS-OVERBOUND 1 / OURS-UNDERBOUND 0` | `AGREE 126 / OURS-OVERBOUND 0 / OURS-UNDERBOUND 0`, `ONLY-GOLDEN-CELL 244` and `ONLY-OURS-CELL 15` **unchanged** |
| the law's grid population | 28 wrong cells over four arms × two views | **0** — `TO-GOLDEN 28`, `AWAY-GOLDEN 0`, `MOVED-WRONG 0`, object counts unchanged |
| golden calibration | — | **0 bound cells** in 2,977 of 2,981 golden readings, over **8,045** in-class-body path selects; the 4 exceptions are all SLANG_REJECT rows (R2) |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`uvm-1.2 src/base/uvm_objection.svh:897` writes a task **inside the class body**
whose second formal carries a default value:

```systemverilog
task wait_for(uvm_objection_event objt_event, uvm_object obj=null);
   ...
   if (m_events[obj].waiters == 0)          // 915
     m_events.delete(obj);
endtask
```

```
LHS: <null>
RHS: io_decl: (obj), line:897:60, endln:897:63
     |vpiParent: task (uvm_pkg::uvm_objection::wait_for)
```

**THE BRIEF'S FRAMING IS REFUTED, AND THE MEASUREMENT IS WHY.** The brief read
this `LHS: <null>` as the VECTOR `SafeCompare` on an `Io_decls` size mismatch —
"golden's `Io_decls` is SHORTER than ours, a surplus io_decl for a defaulted
formal". It is not:

* golden's `wait_for` has **exactly two** `io_decl`s (`objt_event`, `obj`) and so
  does ours, and **neither side gives `obj` a `vpiExpr`** for its `=null`;
* a whole-design census of **every** subroutine's `vpiIODecl` listing on
  SimpleUVM/default — 4,809 subroutine rows, keyed on name × direction ×
  default-value presence, in listing order — is **byte-identical** between
  golden and ours: `0` only-golden rows, `0` only-ours rows. (A default value
  is not the axis either way: the sibling `wait_for_total_count(uvm_object
  obj=null, int count=0)` gets `count:1:E` on BOTH sides and `obj:1:-` on
  both.) `CENSUS.iodecl.r10uvm143.txt` has it.

This is the SINGULAR `SafeCompare` overload's MIRROR (RESUME §9): golden's
`ref_obj::Actual_group` is **null** where ours points at that `io_decl`. The
owner is the reference `obj` at **915:19** — the INDEX of the `bit_select`
`m_events[obj]` inside the `hier_path` `m_events[obj].waiters`. `ct143own.cpp`
proves it by masking: seeding *that one golden object* into a fresh
`CompareContext::m_visited` and re-running the OFFICIAL `design::Compare` moves
the head (to `parameter (UVM_STR_CRC_POLYNOMIAL)`), and that is precisely the
head the patched binary reads.

Three references to the same formal, three different answers, all in one task —
which is what makes the law falsifiable:

| site | shape | golden | ours (pristine) |
|---|---|---|---|
| 899:10 `if (obj==null)` | plain operand | `io_decl` | `io_decl` |
| 903:17 `m_events[obj] = new` | bare bit_select index (lvalue) | bare | bare |
| **915:19 `m_events[obj].waiters`** | **hier_path element index** | **bare** | **`io_decl`** |

## 2. THE DECODED MODEL — the reference is handed a PARENTLESS hier_path, and a class never drains its pool

Two facts in Surelog, both cited, together are the whole law.

**(a) `CompileExpression.cpp:5583`** compiles a `hier_path` element's index with
the `path` object itself as `pexpr`:

```cpp
if (expr *index = (expr *)compileExpression(
        component, fC, Expression, compileDesign, reduce, path, instance, muteErrors)) {
  bit_select *select = s.MakeBit_select();
  select->VpiIndex(index);
```

and `path->VpiParent(pexpr)` is executed only **after** the element loop ends
(`CompileExpression.cpp:5708`). So while the index compiles, the hier_path has
**no parent**. The eager binder

```cpp
UHDM::any* CompileHelper::bindVariable(DesignComponent*, const UHDM::any* scope, ...)   // CompileStmt.cpp:3089
```

answers only for a `function` / `task` / `begin` / `module_inst` scope and
otherwise recurses on `scope->VpiParent()` — from a parentless `hier_path` it
reaches null on the first hop and returns null. Every reference minted under
such an index therefore goes on the component's **late-binding pool**
(`component->needLateBinding(ref)`, CompileExpression.cpp:5778/5784/5786/
5802/5807/5809).

**(b) `UhdmWriter::lateBinding` (UhdmWriter.cpp:3294) is what drains that pool**,
and it *does* find a formal there — the `uhdmtask` branch at :3437 walks
`ta->Io_decls()` by name. It is called for **packages** (`:1304`) and **modules**
(`:1575`, `:1623`, `:2072`, and `:4785` for an elaborated instance). For a
**class definition it is COMMENTED OUT**:

```cpp
    // Activate when hier_path is better supported
    // lateTypedefBinding(s, classDef, c);
    // lateBinding(s, classDef, c);            // UhdmWriter.cpp:1066-1067
```

and `writeProgram` (`:1795-1900`) never calls it at all.

> **§ `hpIdxClassBodyNeverLateBinds143`** — a reference minted anywhere under a
> `hier_path` element's INDEX carries a `vpiActual` exactly when the body that
> wrote it is compiled into a component whose late-binding pool is drained — a
> package, a module, or an elaborated instance — and **never** when it is
> written INSIDE a class body. The kind of index, the direction of the formal,
> the presence of a default value and the position of the path are all
> irrelevant.

### The corpus said it before the arms did

The **only four** `io_decl`-bound hier_path element indices in golden's
SimpleUVM are

```
uvm_default_factory::register              uvm_factory.svh:911
uvm_component::m_add_child                 uvm_component.svh:135
uvm_component::get_tr_stream               uvm_component.svh:2652
uvm_sequencer_base::stop_phase_sequence    uvm_sequencer_base.svh:115
```

and **every one of the four is declared `extern` and defined out of body**, so
Surelog compiles it at `uvm_pkg` scope where the pool IS drained. `wait_for` is
written in the class body. That split was measured on golden **before** any arm
was written, and the arms then reproduce it on names that look nothing like UVM's.

### What the law does NOT claim

`UhdmWriter::lateBinding` refuses a `ref_var` / `ref_obj` candidate in every
branch (`if (decl->UhdmType() == uhdmref_var) continue;` at :3315, :3324,
:3335, :3344, :3387, :3397, :3418, :3426, :3442, :3452, :3465, :3473 …), so a reference that already wears one was
bound by a **different** mechanism and this law is silent about it. The emitter
and the predictor carry that guard, and it is not cosmetic: it is the whole of
`LocalScopeHierPath/testflags` (a **CMP_EQUAL** row), where
`foreach (path.slices[j])` inside an in-body class method binds `j` to the
foreach loop variable's `ref_var` **in golden too**. Arm D is that shape, and
its databases are **byte-identical** pristine vs patched in both views.

## 3. THE PRODUCTION CHANGE

`include/UhdmExporter.h` declares, and `src/ExprEmit.cpp` defines,

```cpp
void UhdmExporter::hpIdxClassNoBind143(UHDM::any* ix);
```

a subtree walk that, while `inBodyClassMethod88` is set, clears
`Actual_group` on every `ref_obj` reachable through an index — through
operations, nested `bit_select` / `var_select` / `part_select` /
`indexed_part_select` indices, `func_call` / `method_func_call` /
`sys_func_call` arguments and receivers, and nested `hier_path` elements —
skipping any reference already bound to a `ref_var` / `ref_obj`.

`inBodyClassMethod88` is **not new**: it is § `pkgVarBindsOnlyThroughInstance88`'s
`classScope && !oob`, set once in `TaskFuncEmit.cpp:3024` off the same two
locals that decide `pkgScopeInst`. The two laws are the same axis seen from two
sides (that one through `func->Instance()`, this one through the un-drained
pool), so the gate and the mechanism it models cannot drift apart.

It is called at the **five** places where a hier_path element's index is emitted
from a slang expression: the two `emitMixedHierPath` builders (base select and
member select), the class-method-receiver path builder, and the two single-dim
`chain` arms. Each call is one line immediately before the element is pushed.

## 4. THE GRID

See `ARMS.r10uvm143.txt` for the scored tables. Four arms, both views, judged by
`uhdm-cmp` and scored cell-by-cell by `score143.py`:

* **arm A** (`g143_a_shapes.sv`) — 9 positions/kinds inside one class body.
  Golden: 9/9 bare. TO-GOLDEN 6, AWAY 0, MOVED-WRONG 0.
* **arm B** (`g143_b_owners.sv`) — **the owner axis**: free package function and
  task, out-of-body class function and task, module function and task, in-body
  class function and task, program task, pure-virtual prototype. Golden binds
  the first six, leaves the in-body pair and the program's DEFINITION-view cell
  bare, and binds the program's `-elabuhdm` cell.
* **arm C** (`g143_c_index.sv`) — 13 index shapes × in-body vs out-of-body twin,
  including `output` / `inout` / `ref` formals, an operation index, a call-argument
  index, a nested select index, a class-handle key and a formal used three times.
  TO-GOLDEN 7, AWAY 0, MOVED-WRONG 0.
* **arm D** (`g143_d_foreach.sv`) — the `ref_var` cell the law must not touch:
  byte-identical before and after.

## 5. GATES

All green — `GATES.r10uvm143.txt` has the full battery, `MOVERS.r10uvm143.txt`
the nine attributed movers, `BOUNDARY.r10uvm143.txt` the 4,106-arm boundary,
`PREDICT.r10uvm143.txt` the a-priori prediction and `GOLDCAL.r10uvm143.txt` the
corpus-wide golden calibration.

The wide boundary compiled **4,106** arms (LISTED == PROCESSED, 3,962 databases
produced, RC_DIFFS 0). Seven moved: this pass's own three (the positive control)
and four earlier-pass arms, each re-measured against golden — `g1_thisidx`
(2 cells TO-GOLDEN), `v1_lvincdecshape` (1), `c1_nestedidx` (1, § `hpMidSelIdxAtPath79`'s
own head cell: only its `vpiActual` moves, its name/parent/span do not), and
`g22.sv`, where **no cell of this law moved at all** — its only delta is the
binary-layout-dependent garbage number in a pre-existing associative-array
range defect, with a byte-identical `uhdm-cmp` head log in both views.

## 6. RESIDUES AND R0

* **R0 (the NEXT head on SimpleUVM ×2 + Scoreboard/default, 62 cmp lines).**
  A KIND mismatch at the `design (work@top)` level. Golden's object is

  ```
  parameter: (UVM_STR_CRC_POLYNOMIAL)  uvm_misc.svh:368:11-368:33
  |vpiParent: design (work@top)            <-- the DESIGN's own listing
  |HEX:04c11db6
  |vpiTypespec: ref_typespec -> int_typespec  368:1-368:48
  |vpiName:UVM_STR_CRC_POLYNOMIAL
  |vpiImported:uvm_pkg                     <-- an IMPORT stamp
  ```

  ours is

  ```
  constant: 368:36-368:48
  |vpiParent: param_assign 368:11-368:48 < package (uvm_pkg) < design (work@top)
  |vpiDecompile:32'h04c11db6  |vpiSize:32  |HEX:04c11db6
  ```

  `uvm_misc.svh:368` is `parameter UVM_STR_CRC_POLYNOMIAL = 32'h04c11db6;`
  inside `uvm_pkg`, reached from `work@top` through the wildcard import.
  Golden HOISTS the imported package parameter into the DESIGN's listing as a
  `parameter` object wearing `vpiImported:uvm_pkg`; we present the package's
  `param_assign` RHS `constant` at that slot instead. That is the next pass's
  head. (`ct143own.cpp` named it A-PRIORI by masking this pass's head cell
  before the patch existed — an independent confirmation that this pass's one
  cell was the only thing above it.)
* **R1 — the PROGRAM half, and the VIEW it depends on.** `writeProgram`
  (UhdmWriter.cpp:1795-1900) never drains the pool either, so a program's
  path-element index is bare in the **definition** view; but `writeInstance`
  (`:4785`) drains it for the **elaborated** instance, so the same cell IS bound
  under `-elabuhdm`. Arm B measures both (`work@foundryProg.progTask.lot`:
  golden bare in the def view, bound in the elab view; ours bound in both).
  This pass does NOT implement the program half: our emitter has no view-keyed
  gate here, and the measured corpus population is **zero** — the predictor
  found no such cell in any of the 2,314 pristine databases. One arm cell,
  scored `STILL-WRONG`, said so loudly rather than hidden.
* **R2 — the four `-elabuhdm` goldens that DO bind inside a class body.**
  `CoresSweRV`, `CoresSweRVMP`, `Opentitan` (121 bound cells each, UVM
  1800.2-2017-1.0) and `IndexPartSelectBind` (1). They are the same
  `writeInstance` view-dependence as R1. **Every one of them is a
  `SLANG_REJECT` row** — we emit no database at all — so they have zero reach
  for this pass and cannot be regressed by it; they are the population a future
  view-keyed refinement of this law would have to satisfy.
* **R3 — the hier_path SHAPE families this pass deliberately does not touch.**
  On SimpleUVM/default the shared in-class path-index cells split
  `AGREE 125 / OURS-OVERBOUND 1 (the head) / OURS-UNDERBOUND 0`, but golden has
  **244** such cells we do not build at all and we have **15** it does not
  (`ONLY-GOLDEN` / `ONLY-OURS`) — our hier_paths differ from golden's in SHAPE
  and SPAN in ways that belong to §§ `hpMidSelIdxAtPath79`, `hpTrailSelIdxDecompiled89`
  and `hpIdxOpPrettyPrint92`, not here. Arm D's three `Reed::*` cells are the
  same residue in miniature (ONLY-GOLDEN before and after).

## 7. THE INSTRUMENTS

| file | what it is |
|---|---|
| `ct143own.cpp` | head locator: prints the official `Compare`'s failed pair with parent chains, and masks named GOLDEN objects into a fresh `CompareContext` to convict an owner |
| `pred143.cpp` | a-priori predictor / golden calibrator: walks the same subtree the emitter walks and names every cell the law will strip (`--` golden must read 0) |
| `score143.py` | arm scorer: TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG / ONLY-GOLDEN / ONLY-OURS, keyed WITHOUT any span |
| `arm143.sh` | builds one arm with Surelog (both views) and both frozen binaries, records every rc, runs the official `uhdm-cmp` |
| `bound143.sh` | the wide boundary over a COPY of the whole probe tree, subdirectories included, `LISTED == PROCESSED` asserted |
| `attrib143.sh` | order-blind (sorted, path-normalised) whole-dump attribution of every byte mover |
| `cen143.py` | whole-design cell census of hier_path element indices, joined per (reference fullname, own loc): AGREE / OURS-OVERBOUND / OURS-UNDERBOUND / ONLY-GOLDEN-CELL / ONLY-OURS-CELL |
| `iocen143.awk` | the `vpiIODecl` listing census that refuted the brief's framing (name × direction × default-value presence, in order) |
| `refcen143.awk` | reference census: name, loc, enclosing object, field, vpiParent kind, vpiActual kind |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the standard gate battery, copied unmodified |
