# r10uvm125 — § `outArgConvLvalue125` — **A CONVERTING OUTPUT/INOUT ACTUAL IS STILL JUST THE LVALUE** — the SimpleUVM ×2 / Scoreboard-default / BuildUVMPkg ×2 **46-line head CLEARED**

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `b39fd59` |
| pristine binary | reproduced the main tree's `build/slang-uhdm` at `b39fd59` BYTE FOR BYTE (md5 `6738536fb5b14c9db80873c8707411b5`), frozen `chmod 555` before any sweep |
| patched binary | md5 `9eeb7f38678c006f7d2bb3ac4d9cfd84`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` — **one predicate**, in the § `outArgLvalue17` arm |
| probe surface | `tools/probe/r10uvm125repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **46** | **12** | 1 — a **NEW HEAD, a different object and a different family** |
| **Scoreboard default** | **46** | **12** | 1 — the same new head |
| **BuildUVMPkg default / testflags** | **46** | **12** | 1 — the same new head |
| SeqDriver default / testflags | 28 | 28 | 1 unchanged, head log **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 28 | 28 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 240 / 268 | 240 / 268 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes | |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the nine **PREDICTED BY NAME** from the PRISTINE databases before the patched sweep ran | |
| direction, all 9 movers | — | **TO-GOLDEN 7/13/15 per row, AWAY-GOLDEN 0** | |
| the wrapper family, all nine DBs | 7–15 wrong cells each | **0** | |

`head_pris_*_*.cmp` are the whole 46-line pristine heads; `head_pat_*_*.cmp` are
the new 12-line ones. `head_pris_default_{SeqDriver,MiniAmiq}.cmp` are the two
row-modes whose head this pass leaves untouched.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduces the master's head log
for SimpleUVM/default **line for line** (ids aside). Scoreboard/default carries
the SAME head object at the same file/line; BuildUVMPkg carries it at its own
1800.2 `pp_output` line (74328).

```
LHS (golden)                                       RHS (ours)
ref_obj: (…backdoor_read_func::slice) @2074:44-49  operation: @2074:44-2074:49
|vpiParent:                                        |vpiParent:
\_func_call: (uvm_hdl_read) @2074:21-2074:50       \_func_call: (uvm_hdl_read) @2074:21-2074:50
|vpiName:slice                                     |vpiOpType:82
|vpiActual:                                        |vpiOperand:
\_bit_var: (…slice) @2072:30-2072:35               \_ref_obj: (…slice) @2074:44-2074:49
                                                     |vpiParent:
                                                     \_assignment: @2074:15-2074:50
                                                     |vpiName:slice
                                                     |vpiActual:
                                                     \_bit_var: (…slice) @2072:30-2072:35
```

`uvm-1.2 src/reg/uvm_mem.svh:2074` is

```systemverilog
              ok &= uvm_hdl_read(hdl_path, slice);
```

inside `uvm_mem::backdoor_read_func`, where `slice` is declared two lines above
as `uvm_reg_data_t slice;`.

**vpiOpType 82 decoded from the headers, not from memory.**
`~/.local/include/uhdm/sv_vpi_user.h:394`:

```c
#define vpiAssignmentOp                   82 /* Normal assignment */
```

(`vpi_user.h:234`'s `vpiRhs 82` is a *property* code, a different namespace —
this is an `operation`'s `VpiOpType`, so `sv_vpi_user.h` is the table that
applies.) So we hand the call an **assignment operation with ONE operand**, and
the operand's parent is the **enclosing `ok &= …` assignment**, not the operation
and not the call.

---

## 2. THE DECODED MODEL

### 2.1 Where OURS comes from

`src/ExprEmit.cpp`, the `ExpressionKind::Assignment` arm of `emitExpr`, already
carries § `outArgLvalue17`:

> an OUTPUT / INOUT actual is not an assignment in the model, it is the bare
> lvalue. slang binds one as a SYNTHESIZED `AssignmentExpression` carrying the
> copy-back (`left = <EmptyArgument>`) … Surelog lists the written lvalue and
> nothing else.

Its test was `ae.right().kind == ExpressionKind::EmptyArgument` — a **kind-only**
test, and that is the bug. `Expression::bindLValue`
(`slang/source/ast/Expression.cpp:289-297`) mints the placeholder **with the
FORMAL's type**:

```c++
auto rhsExpr = comp.emplace<EmptyArgumentExpression>(rhs, lhs.sourceRange);
return AssignmentExpression::fromComponents(comp, std::nullopt, assignFlags, lhs, *rhsExpr, …);
```

and `fromComponents` runs that placeholder through `convertAssignment` against
the **actual's** type. When the two differ the synthesized right side is
`Conversion(<EmptyArgument>)`, not the `EmptyArgument` itself. slang names both
shapes in one predicate — `AssignmentExpressions.cpp:449-453`:

```c++
bool AssignmentExpression::isLValueArg() const {
    return right().kind == ExpressionKind::EmptyArgument ||
           (right().kind == ExpressionKind::Conversion &&
            right().as<ConversionExpression>().operand().kind == ExpressionKind::EmptyArgument);
}
```

The kind-only test caught the first shape and missed the second. A missed
`AssignmentExpression` then fell through to the arm below it, whose `argCtx9`
branch (parent is a `func_call`/`task_call`/`method_*_call`/`sys_*_call`) mints
`operation(vpiAssignmentOp=82)` and parents the lvalue ref at
`enclosingAssign` — which is precisely the object and the parent the head shows.

### 2.2 Why GOLDEN can never hold this object

Surelog compiles a call argument **from its syntax**; there is no copy-back to
encode. `Surelog/src/DesignCompile/CompileExpression.cpp:2459-2528`, the
`paVariable_lvalue` arm, is the only place an argument-position lvalue can
become an operation:

```c++
case VObjectType::paVariable_lvalue: {
  UHDM::any *variable = compileExpression(component, fC, fC->Child(child), …);
  NodeId op = fC->Sibling(child);
  if (op) {
    …
    if (vopType) {                                   // ++ / -- : op is NOT 82
      …  operands->push_back(variable);              // one operand, other opType
    } else if (opType == VObjectType::paExpression) {// a WRITTEN `(x = y)`
      operation->VpiOpType(vpiAssignmentOp);
      operands->push_back(variable);
      …
      if (UHDM::any *rexp = compileExpression(…rval…)) operands->push_back(rexp);
    }
  } else {
    result = variable;                               // <-- a call argument
  }
```

An `op82` is minted **only** when the lvalue node has a `paExpression` sibling —
i.e. only when the source text really wrote an assignment expression — and that
arm **always pushes a second operand**. The one-operand arm above it never uses
opType 82. A plain call argument has no sibling at all and takes the
`result = variable` exit: **the bare lvalue**.

So a **one-operand `operation` of type 82 is unreachable in Surelog's writer**.
Measured, not argued: across the nine UVM databases golden holds **zero** op82
arguments of **any** operand count, while we held 7–15 per database, **all**
one-operand, **all** `dir=out` (`CENSUS.r10uvm125.txt` §A).

### 2.3 THE LAW

> § `outArgConvLvalue125` — an OUTPUT / INOUT actual is the bare lvalue **whether
> or not the copy-back needs a conversion**. The synthesized copy-back's right
> side is `EmptyArgument` when the actual's type matches the formal's and
> `Conversion(EmptyArgument)` when it does not; both are lvalue arguments, and
> neither is an object in the model. Emit `ae.left()` at the call's parent.
> **The inner-ref parent question disappears with the wrapper**: there is no
> inner ref, and the single surviving `ref_obj` parents at the CALL, which is
> where golden parents it in every direction and every shape.

Production change, whole:

```c++
-            if (ae.right().kind == ExpressionKind::EmptyArgument)
+            if (ae.isLValueArg())
                 return emitExpr(ae.left(), parent, prefix, netMap);
```

(plus the comment block that records the mechanism). The three other
`EmptyArgument` pre-unwrap sites in `ExprEmit.cpp` (~18150, ~18206, ~18679) are
left alone deliberately: each of them, on a miss, calls `emitExpr` on the
`Assignment` itself, which reaches this arm and now returns the same object with
the same parent — the pre-unwrap is an optimisation, not a second law, and
touching it would widen the surface for no measured effect (the wide boundary
below confirms nothing else moved).

---

## 3. THE CORPUS SITES, AND THE CONTROL TWO STATEMENTS ABOVE THE HEAD

| site | actual's declared type | formal | shape |
|---|---|---|---|
| `uvm_mem.svh:2074` `ok &= uvm_hdl_read(hdl_path, slice)` | `uvm_reg_data_t` = `bit unsigned [63:0]` | `output uvm_hdl_data_t` = `logic [1023:0]` | CONVERTING → wrapped |
| `uvm_reg.svh:2725` `ok &= uvm_hdl_read(…path, val)` | `uvm_reg_data_t` | idem | CONVERTING → wrapped |
| `uvm_reg.svh:2732` `ok &= uvm_hdl_read(…path, slice)` | `uvm_reg_data_t` | idem | CONVERTING → wrapped |
| `uvm_reg_mem_hdl_paths_seq.svh:138` `if (!uvm_hdl_read(p_,d))` | `uvm_reg_data_t` | idem | CONVERTING → wrapped |
| MiniAmiq's `get_cover_statistics_dpi` @512:56 | — | output | CONVERTING → wrapped |
| **`uvm_mem.svh:2068` `ok &= uvm_hdl_read(hdl_path, val)`** | **`uvm_hdl_data_t`** | idem | **MATCHING → already plain** |

The last row is the **in-corpus differential control**, six lines above the head
in the same function: same callee, same `ok &= …` statement shape, same
direction, same argument position — the *only* difference is that the actual's
type matches the formal's, so slang leaves the placeholder bare and
§ `outArgLvalue17` already unwrapped it. Its cell is byte-identical to golden's
in the pristine build **and** in the patched one:

```
GOLDEN  ref_obj(val)|parent=func_call@2068:21-2068:48|span=2068:44-2068:47  dir=out
OURS    ref_obj(val)|parent=func_call@2068:21-2068:48|span=2068:44-2068:47  dir=out
```

That pair is what makes the conversion the distinguisher rather than the callee,
the statement shape or the direction.

---

## 4. THE CENSUS (`CENSUS.r10uvm125.txt` for the full tables)

`cen125.cpp` emits one cell per `Tf_call_args` element of every `tf_call`:
`SITE | CALL | IDX | PAYLOAD | dir`, with the **inner-operand parent kind as its
own column** and **no object ids** in the key. Two joins score it — `score125.py`
on `(SITE, CALL, IDX)` and `wrap125.py` on `(CALL, IDX)` with a shape-reduced
payload, both as **multisets**.

Golden-vs-golden calibration is implicit and total here: the join is exact on
17 049–28 677 cells per row before the patch, and every op82 cell faces
`GOLD=PLAIN:ref_obj`.

| row-mode | ours op82 args | one-operand | golden op82 args | after |
|---|---|---|---|---|
| SeqDriver def/tf | 13 | 13 | **0** | 0 |
| SimpleUVM def/tf | 7 | 7 | **0** | 0 |
| Scoreboard default | 7 | 7 | **0** | 0 |
| MiniAmiq def/tf | 15 | 15 | **0** | 0 |
| BuildUVMPkg def/tf | 7 | 7 | **0** | 0 |

`SAME` rises by **exactly** the number `MOVED-WRONG` falls, in both joins, on
every row: **TO-GOLDEN 7/13/15, AWAY-GOLDEN 0, MOVED-WRONG introduced 0**, and
`ONLY-GOLDEN` / `ONLY-OURS` are unchanged to the cell.

### The ONE-SIDED SET (this pass REMOVES objects)

`cnt125.cpp` counts every UHDM kind in the whole database. The complete
patched-minus-pristine delta, on all nine movers, is:

```
  operation      -7 / -13 / -15   (op82 leaves the kind set ENTIRELY)
  ref_typespec   -1
  every other kind   0
```

`rt125.cpp` names the single `ref_typespec`:
`operation@138:38-138:39 | logic_typespec | uvm_pkg::uvm_hdl_data_t` — the
typespec our emitter stamps on the wrapper at
`uvm_reg_mem_hdl_paths_seq.svh:138`, where the call sits in an `if (!…)`
condition. It dies with its operation. **No golden object is lost** — golden
never had an op82 argument to begin with.

---

## 5. THE GRID (`ARMS.r10uvm125.txt`)

Four arms, each built with Surelog and with both frozen binaries in **both**
views:

* `g125_a_dirs.sv` — **directions × conversion**: output/same-type (control),
  output/narrowing, output/int, output inside the corpus's own `ok &= f(…)`
  compound statement, inout/converting, `ref`/same-type, a **task** call, and a
  bare `void'(f(…))` statement call.
* `g125_b_shapes.sv` — **argument shapes** for a converting formal: bare ref,
  bit-select, part-select, indexed part-select, struct member, array element,
  `this.`-qualified property, plus a **widening** actual and three same-type
  controls.
* `g125_c_kinds.sv` — **call kinds**: DPI import function, DPI import task,
  package free function, package task, `method_func_call`, `method_task_call`,
  `$value$plusargs`, `$sscanf`.
* `g125_d_homes.sv` — **homes × instances**: module task, module function,
  `initial`, `always`, generate block, in **three** differently parameterised
  instances.

| arm | pristine | patched |
|---|---|---|
| a_dirs | SAME 9, WRONG 6, OG 0, OO 0 | **SAME 15, WRONG 0**, OG 0, OO 0 |
| b_shapes | SAME 16, WRONG 10, OG 0, OO 0 | **SAME 25, WRONG 1**, OG 0, OO 0 |
| c_kinds | SAME 11, WRONG 6, OG 0, OO 0 | **SAME 17, WRONG 0**, OG 0, OO 0 |
| d_homes | SAME 8, WRONG 8, OG 0, OO 0 | **SAME 16, WRONG 0**, OG 0, OO 0 |

30 of 31 pristine-wrong cells converted, **0 away**, ONLY-GOLDEN and ONLY-OURS
empty throughout. The **ELAB view scores the same conversions** (6→0, 10→1,
6→0, 8→0) with its ONLY-OURS column unchanged by the patch. The one residual is
recorded as **R-B** below.

---

## 6. THE WIDE BOUNDARY (`bound125.sh`, `GATES.r10uvm125.txt` §6)

Every `.sv`/`.v` arm committed under `tools/probe/`, **subdirectories included**,
built with both frozen binaries in both views and compared **byte for byte**.

```
LISTED=3784  PROCESSED=3784 (asserted equal)  RC_DIFF=0
cells 7568 = 3784 × 2 views;  3777 of the arms live in subdirectories
SAME 7266   NO_DB 294 (both binaries reject identically, rc equal on every one)
BYTES_DIFFER 8  — EXACTLY this pass's own four grid arms, in both views
```

Those eight are the **positive control**: the gate can see the change, and it
sees it nowhere else. Every arm of uvm77-79, uvm82-91, buvm3-15, sd8-12 and
uvm93-123 is byte-identical under this law. The file list is read on fd 3 with
children `</dev/null`, scratch is keyed on the **relative** path (three arms are
named `dut.sv`), `rc` is recorded per cell, and no path filter is applied.

---

## 7. GATES (all green — `GATES.r10uvm125.txt` verbatim)

goldens 23/0 on both binaries and 0/23 for the `/bin/false` negative control;
uhdm2rtlil 679/50/2 in both modes with **0 differing rows** against the committed
baseline and against this pass's own pristine sweep, **0 / 1358 byte movers**;
surelog 471/283/25/10/5 default and 466/284/23/9/5/3/2/1/1 testflags — the
status histogram identical to pristine, **0 differing rows over 1588** against
`results/golden_surelog.csv`, **no row converted**, **9 / 956 byte movers, all
nine predicted by name**; canaries `ok=52` / `ok=8` `changed=0`; both `ctcan2`
PASS; `canaudit` `audited=29 UNCOVERED=0 FENCE-BREACH=0`; InterfaceModPort,
BlackParrotComplex and YosysOldOr byte-identical, SVSwitch pinned at
`4842211c4030`, YosysVerx at `6ccda350c24a`. Every `cmds.txt` was audited by
binary **path**: 1523/1523 surelog and 1458/1458 uhdm2rtlil name the frozen copy,
**0** name the main tree's `build/slang-uhdm`.

---

## 8. RESIDUES AND R0

**R0 — THE NEW HEAD (SimpleUVM ×2, Scoreboard/default, BuildUVMPkg ×2, 12 lines,
1 head).** An unparented typespec at `68:7-68:13`:

```
LHS: string_typespec:  , line:68:7, endln:68:13
RHS: logic_typespec:   , line:68:7, endln:68:13
```

`uvm-1.2 src/reg/sequences/uvm_reg_bit_bash_seq.svh:68` is
`` string mode[`UVM_REG_DATA_WIDTH]; `` — an **unpacked array of `string`**
whose element typespec golden types `string` and we type `logic`. BuildUVMPkg
carries the same object at its own `pp_output` line 80061. The object is
unparented in both producers, so uvm123's `ctx123.cpp` head decoder (walking an
unparented object's context) is the instrument to start from.

**R-B — the `this.`-qualified actual's hier_path SPAN** (`g125_b_shapes.sv`, one
cell). Both producers give a `hier_path` parented at the `func_call`; only the
span differs (golden `42:17-42:26` covering `this.narr`, ours `42:17-42:21`
covering `this.`). Compare reads `VpiType`/`VpiName`/`VpiDefName` and per-kind
fields and **never** `VpiFile`/line/col, so this is **dump-only and invisible to
the judge**. It is pre-existing — pristine wrapped the same actual in op82,
which merely masked it — and it is adjacent to uvm124's method-call
receiver name/span family rather than to this law.

**R-C — the three `EmptyArgument` pre-unwrap sites** (`ExprEmit.cpp` ~18150,
~18206, ~18679) still test the bare kind. They are now redundant rather than
wrong (a miss falls through to this law), and were left untouched to keep the
surface at one predicate; a later pass that reworks those arms should fold them
into `isLValueArg()`.

---

## 9. THE FILES

| file | what it is |
|---|---|
| `cen125.cpp` | the CALL-ARGUMENT census: one cell per `Tf_call_args` element of every `tf_call`, keyed without ids, with the inner-operand parent kind as its own column and the formal direction read off the callee's `io_decls`. |
| `score125.py` | multiset join on `(SITE, CALL, IDX)` — SAME / MOVED-WRONG / ONLY-GOLDEN / ONLY-OURS. |
| `wrap125.py` | multiset join on `(CALL, IDX)` with a shape-reduced payload (`PLAIN:<kind>` / `OP<n>x<k>:<inner>`), so it joins across producers without depending on either one's block spans; prints the shape cross-tab. |
| `cnt125.cpp` | whole-database object-kind counter (op types broken out) — the ONE-SIDED SET scorer for a pass that removes objects. |
| `rt125.cpp` | `ref_typespec` identity listing, to name the single removed `ref_typespec`. |
| `pred125.sh` | the A-PRIORI mover predictor: scans every pristine database in a workdir for one-operand op82 arguments. |
| `arm125.sh` | builds one grid arm with Surelog and both frozen binaries in both views, censuses and scores it with the official `uhdm-cmp`. |
| `wide125.sh` | the nine-database census driver (reads the golden path out of each row's own `cmds.txt` and turns the cache DIRECTORY into `…/golden.uhdm`). |
| `bound125.sh` | the wide boundary gate (fd-3 list, `</dev/null` children, PROCESSED asserted, relative-path scratch, rc per cell, no path filter). |
| `g125_{a_dirs,b_shapes,c_kinds,d_homes}.sv` | the grid. |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the whole head logs, before and after. |
| `rowheads.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`, `byteverify.sh` | carried forward unchanged, so the battery RUNS from this directory. |
