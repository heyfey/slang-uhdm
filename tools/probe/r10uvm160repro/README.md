# r10uvm160 — § `badConcatOperandsFromSyntax160` — **A CONCATENATION SLANG REJECTED KEEPS NONE OF ITS OPERANDS, NOT EVEN THE ONES IT HAD ALREADY BOUND: `ConcatenationExpression::fromSyntax` THROWS `buffer` AWAY AND HANDS BACK AN *EMPTY* CONCAT** — the SimpleUVM ×2 + Scoreboard/default **67-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `6b24843` |
| worktree | `/tmp/wt_r10uvm160` |
| pristine binary | md5 `904532d3885d6362d6f515c3db951771`, built from this worktree at a clean `6b24843` and frozen `chmod 555` before any sweep |
| patched binary | md5 `995b3d45726c2a9aef48b76b87f497a2`, frozen `chmod 555`. `/tmp/r10uvm160.patch` applied to a FRESH `6b24843` worktree and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on |
| production surface | `src/ExprEmit.cpp` (the law, its two builders and the one call site in `case ExpressionKind::Invalid`), `src/StmtEmit.cpp` (`droppedCallShapeOk14`, a three-line accessor so the shape pass and the mint pass ask ONE predicate), `include/UhdmExporter.h` (three declarations) |
| probe surface | `tools/probe/r10uvm160repro/` only |


## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **67** | **29** | 1 — a **NEW object**, `chandle_var compiled_regex` (§7) |
| **Scoreboard default** | **67** | **145** | 1 — a **NEW object**, `class_typespec uvm_analysis_imp` (§7). Counts are DEPTH, not distance: the new head's decompile is simply bigger |
| SeqDriver default / testflags | 17 | 17 | 1 unchanged, head log BYTE-IDENTICAL |
| MiniAmiq default / testflags | 106 | 106 | 1 unchanged, head log BYTE-IDENTICAL |
| BuildUVMPkg default / testflags | 1371 | 1371 | 1 unchanged, head log BYTE-IDENTICAL |
| Earlgrey_0_1 default / testflags | 36 | 36 | 1 unchanged, head log BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** — both corpora, both modes; surelog `CMP_NOTEQUAL` stays **10 default + 9 testflags** and uhdm2rtlil stays `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2`, status histograms IDENTICAL to this pass's own pristine sweep | |
| byte movers | — | **9 / 956** surelog — **all nine PREDICTED BY NAME from the pristine databases before the patched sweep ran** — and **0 / 1358** uhdm2rtlil | |
| the corpus census (9 moved DBs, five row families, both views) | — | **41 cells TOWARD; WRONG 0, RESHAPE 0, ONLY-A 0**; the OP family's TOWARD is **23**, exactly the 23 cells the prediction named | |
| the grid (6 arms, both views, five row families) | — | **106 TOWARD, WRONG 0, AWAY 0 (as the judge measures it), RESHAPE 0, ONLY-A 0** | |
| the WIDE boundary (4462 arms, both views) | — | **MOVED_ARMS 12, RC_DIFFS 0** — 6 are this pass's own grid (the positive control), 3 go to **CMP_EQUAL**, 1 is re-measured TOWARD, 2 are refuted as a build-layout artifact by a THIRD binary (`BOUNDARY.r10uvm160.txt`) | |

Counts are **DEPTH, not distance**: a cmp line count is the HEAD OBJECT'S
decompile size (RESUME.md §7). `Scoreboard/testflags` is `SLANG_REJECT` and
`Rggen/testflags` has no golden — both print SKIP-NOFILE and are COUNTED, never
read as perfection.


---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this worktree's own pristine sweep reproduced the brief
exactly — **SimpleUVM default/testflags and Scoreboard/default, 67 cmp lines,
1 head each** — and `head_pris_SimpleUVM.default.cmp` is **byte-identical** to
the head r10uvm158 predicted (`r10uvm158repro/head_pat_SimpleUVM.default.cmp`).

```
LHS:
decompile:
operation: , id:155851, line:121:19, endln:121:67
|vpiParent:
\_assignment: , id:155849, line:121:7, endln:121:67
|vpiOpType:33
|vpiOperand:  \_constant: "uvm_reg_predictor #(" 121:20-121:42
|vpiOperand:  \_hier_path: (t.get_type_name), 121:44-121:61
                |vpiActual: \_ref_obj: (t)                       121:44-121:45
                |vpiActual: \_method_func_call: (get_type_name)  121:46-121:59
|vpiOperand:  \_constant: ")" 121:63-121:66
RHS: <null>
```

Source — `uvm-1.2/src/reg/uvm_reg_predictor.svh:54` and `:117-124`:

```systemverilog
class uvm_reg_predictor #(type BUSTYPE=int) extends uvm_component;   // :54
  virtual function string get_type_name();                            // :117
    if (type_name == "") begin
      BUSTYPE t;
      t = BUSTYPE::type_id::create("t");
      type_name = {"uvm_reg_predictor #(", t.get_type_name(), ")"};   // :121 <- THE HEAD
    end
    return type_name;
  endfunction
```

### (1) WHICH `SafeCompare` PRINTED THE NULL — DECIDED BY MEASUREMENT

`LHS: <object> / RHS: <null>` is printed by **two different arms** of
`BaseClass::SafeCompare` (`~/.local/include/uhdm/BaseClass.h`) and the cmp log
cannot tell them apart:

* the **SINGULAR** overload with `rhs == nullptr` (`:191-193`) sets
  `m_failedLhs` to the **VALUE** and leaves `m_failedRhs` unset — here that
  would be `assignment::Rhs` with OUR concatenation missing entirely;
* the **VECTOR** overload's `(lhs != nullptr) && !lhs->empty() && (rhs == nullptr)`
  arm (`:217-219`) sets `m_failedLhs` to the **OWNER** (`lhs_obj`) and also
  leaves `m_failedRhs` unset — here that is the `operation`'s own
  `vpiOperand` vector with our vector NULL.

`ct160own.cpp` settles it. It runs the real `design::Compare`, finds OUR
counterpart by kind+span+opType+parent-kind (exactly one match), reads the
ENCLOSING assignment's singular `Rhs` edge on both sides, and then walks
`operation::Compare`'s own field order
(`~/git-repos/UHDM/build/generated/src/operation.cpp:98-129`). On the
**corpus row** `default/SimpleUVM-1dc93a62`:

```
HEAD LHS = operation()@121:19-121:67#155851
HEAD RHS = <null>
OUR counterpart = operation()@121:19-121:67#81482
enclosing assignment::Rhs   LHS=operation()@121:19-121:67  RHS=operation()@121:19-121:67
operation::Compare field order:
   VpiType      LHS=2251  RHS=2251
   VpiOpType    LHS=33    RHS=33
   VpiReordered / VpiFlattened / VpiOpStrong  equal
-> Operands     LHS=3     RHS=null    [VECTOR overload, RHS NULL -> m_failedLhs = the OWNER]
   Attributes   LHS=null  RHS=null
```

**THE FIELD IS `operation::Operands`, THE VECTOR OVERLOAD, RHS NULL, OWNER = THE
`operation`.** The singular `assignment::Rhs` alternative is RULED OUT by
measurement: our assignment carries the operation. The same three lines come
out of the 24-line committed witness `g160_f_witness.sv`.

**WHY OUR VECTOR IS *NULL* AND NOT *EMPTY*.** Our emitter always calls
`op->Operands(s.MakeAnyVec())`, i.e. it stores a present-but-EMPTY vector; the
UHDM serializer restores an empty vector as a NULL one. `ct160cen`'s census
prints `-1` for a NULL vector and `0` for an empty one, and every one of these
cells reads `-1` after the round trip — which is what puts the head on the
`:217` arm rather than on the size-mismatch arm at `:209`.

---

## 2. THE LAW

> **§ `badConcatOperandsFromSyntax160`** — *a CONCATENATION one of whose
> operands slang binds bad comes back as an `InvalidExpression` wrapping a
> `ConcatenationExpression` with an **EMPTY operand span**:
> `ConcatenationExpression::fromSyntax` breaks out of its walk at the first bad
> operand and then **throws `buffer` away**, so the operands it had ALREADY
> BOUND are lost with it. It is the only `badExpr` in slang's expression
> library that hands back an emptied CONTAINER; every other compound bad path
> returns `badExpr(comp, result)` with the parts intact, which is why
> § `droppedCall14`'s child unwrap already recovers those and why a bad operand
> hurts NOWHERE ELSE. Surelog binds nothing at this level and emits every
> written operand. Rebuild the operand list from the WRITTEN SYNTAX, which
> `Expression::create` left on the Invalid node.*

### THE SLANG MECHANISM, READ NOT GUESSED

`slang/source/ast/expressions/OperatorExpressions.cpp` (`e4e8a2d`):

```cpp
    for (auto argSyntax : syntax.expressions) {                       // :1919
        Expression* arg = &create(comp, *argSyntax, context);
        buffer.push_back(arg);
        if (arg->bad()) { errored = true; break; }                    // :1925-1928
    }
    ...
    if (errored) {                                                    // :1993
        return badExpr(comp, comp.emplace<ConcatenationExpression>(
            comp.getErrorType(), std::span<Expression*>{},            //  <-- EMPTY
            syntax.sourceRange()));                                   // :1994-1996
    }
```

`grep -rn 'badExpr(comp\(ilation\)\?, comp\(ilation\)\?\.emplace' source/ast/`
returns exactly **two** hits: this one and the streaming concatenation at
`:2272`. Everything else — `BinaryExpression`, `ConditionalExpression`,
`AssignmentExpression::fromComponents` (`AssignmentExpressions.cpp:401`),
`CallExpression` — keeps its parts.

Two facts make the recovery possible and are the whole handle:

* `Expression::create` stamps `result->syntax = &syntax` (`Expression.cpp:1002`)
  on the **Invalid node** — so the written `ConcatenationExpressionSyntax` is
  still reachable (the emptied child's own `syntax` is null);
* the emptied child keeps the concatenation's **own `sourceRange`**, which is
  the span our pristine database already emits.

### WHAT SURELOG DOES (why golden has all the operands)

Surelog's expression compiler is SYNTAX-DIRECTED and binds nothing at this
level: its `paConcatenation` arm walks the written operand nodes and compiles
each one through `compileExpression`. A concatenation whose operands slang
could not type therefore still comes out of Surelog with every operand it was
written with — including, for the head, § `droppedCall14`'s dotted-call
`hier_path`, whose exact shape (`CompileExpression.cpp:5455`'s `hier_path`
mint, its `paMethod_call_body` step and the `the_name` stamp at `:5706`) that
law already decoded and already builds.

### WHICH CONCATENATIONS THIS ACTUALLY REACHES (the population, measured)

A bad operand normally carries a **REPORTED** diagnostic, and a reported error
makes the whole test `SLANG_REJECT`, which is out of the campaign's scope by
decision. The population this law reaches is the operand that binds bad **in
silence**: the body of a **GENERIC CLASS's DEFAULT specialization**, which
nothing in the source specializes and which slang therefore never diagnoses —
our emitter is what asks for it
(`GenericClassDefSymbol::getDefaultSpecialization`), after the diagnostics have
been collected.

Grid arm A proves the boundary by construction: its `a5` cell was written first
as `ps.nosuch160()` on a plain `string`, our own binary answered
`error: unknown built-in method 'nosuch160' on type 'string'`, and the cell was
REWRITTEN as the SILENT spelling (a local whose type parameter defaults to
`string`). An arm our own tool refuses is not an arm that measures anything.

### THE OPERAND OBJECTS, MEASURED CELL FOR CELL AGAINST THE ACCEPTED TWIN

Grid arm B writes twelve operand kinds TWICE inside one generic class: once in
a concatenation slang ACCEPTS (`ok_*`) and once in the same concatenation with
one trailing operand slang rejects (`bd_*`). **Every `ok_*` cell is
byte-identical between golden and our PRISTINE binary** — so the accepted twin
is an ORACLE, and golden's object inside the REJECTED concatenation is
field-for-field the accepted twin's. The corpus says the same thing at
`uvm_misc.svh:708` (accepted) against `:721` (rejected), in the SAME method,
with the SAME operand kinds.

| written form | object |
|---|---|
| `"text"` | `constant`, `vpiConstType` 6, decompile = the raw quoted text, size = 8 × inner length, parented exactly as the concat arm parents a DIRECT literal operand |
| `ident` | `ref_obj`, `vpiName` = the identifier, `vpiFullName` = `<prefix>::<identifier>`, UNBOUND — and golden emits that same bare ref for a **formal**, a **method local**, a **class property**, a **class type parameter**, a **class localparam** and a **PACKAGE parameter** alike (arm B, six cells) |
| `recv.meth(args)` | § `droppedCall14`'s EXPRESSION form: `hier_path` over [`ref_obj` recv, `method_func_call` meth] |
| `recv.field` | `hier_path` over [`ref_obj` recv, `ref_obj` field] |
| `Qual::name`, `Qual::call()` | § `typeParamScopedCallRef59`'s object: ONE `ref_obj` named `<first written segment>::<final identifier>`, spanning the qualifier alone |

### STATED GATE == CODE GATE

`emitBadConcatFromSyntax160` fires **only** when the expression is `Invalid`,
its child is a `Concatenation` **whose operand span is EMPTY**, the Invalid
node's syntax is a `ConcatenationExpression` with at least one written operand,
`inLhs` is false, and **every** written operand is one of the five shapes
above. Nothing else — no home test, no view test, no type-parameter test.

**ALL OR NOTHING**, and that is a measurement, not a taste: `operation::Compare`
reads the operand vector's SIZE first, so a HALF-rebuilt list would only move
the head from `RHS: <null>` to a size mismatch. The shape pass runs BEFORE
anything is minted (serializer GC is off, so an abandoned object would still
reach the database), and it asks § `droppedCall14`'s OWN predicate through the
new `droppedCallShapeOk14` accessor so the two passes cannot drift.

**AND NO `noteUnsupportedAt` ON THE WAY OUT.** The first cut noted the
abstained operand kind; `unsupportedKinds` is what `uhdm_main` turns into a
NON-ZERO EXIT CODE and a stdout line, and `verify_golden.py` reads a non-zero
rc as `SLANG_REJECT`. Measured: with the note in place, grid arm B's binary
exited **4** where the pristine one exited **0**. The abstention is visible
where it belongs — in the database, as the unchanged empty operand vector.

---

## 3. THE CHANGE

**`src/ExprEmit.cpp`** — the law, the slang and Surelog citations, the measured
operand table, and two functions:

```cpp
UHDM::any* UhdmExporter::emitBadConcatOperand160(const ExpressionSyntax& os,
        UHDM::BaseClass* op, const std::string& prefix, NetMap& netMap, bool mint);
UHDM::any* UhdmExporter::emitBadConcatFromSyntax160(const Expression& e,
        UHDM::BaseClass* parent, const std::string& prefix, NetMap& netMap);
```

plus ONE call site inside `case ExpressionKind::Invalid`, placed AFTER
§ `droppedCall14` and § `droppedIdxRecvCall26` (neither can match a
`Concatenation` child) and immediately BEFORE the plain child unwrap it
replaces:

```cpp
if (auto* r160 = emitBadConcatFromSyntax160(expr, parent, prefix, netMap))
    return r160;
```

**`src/StmtEmit.cpp`** — `droppedCallShapeOk14`, a three-line accessor over the
existing file-static `droppedCallShape14`.

`emitBadConcatOperand160`'s `mint` parameter is what makes the two passes ONE
piece of code: with `mint == false` every branch returns a NON-NULL SENTINEL
(`(UHDM::any*)1`) as soon as it recognises the shape and mints nothing, so the
shape pass and the mint pass cannot disagree about which operands are modelled.
The sentinel never leaves the `if` that tests it — the shape pass's only caller
is `if (!emitBadConcatOperand160(..., /*mint=*/false)) return nullptr;` — and no
path can produce a SHORT operand list, because every branch's shape test and
mint test are the same expression.

**Nothing else changed.** When the law abstains, the unwrap still stands and the
object is byte-for-byte what it is today — which is what the 0/1358 uhdm2rtlil
byte gate and the 4450 unmoved boundary arms measure.

**FENCES (all measured, all must-stay):**

* an **LVALUE** concatenation returns above the mint (`inLhs`): the cont-assign
  FIRST-OPERAND span anchor and § `staticScopedLvalueBad48`'s placeholder are
  not modelled here (arm E `e8`).
* a **NON-EMPTY** bad concat child — slang's UNPACKED-ARRAY arm at
  `OperatorExpressions.cpp:1905-1907` keeps what it bound — is left to the
  existing unwrap (arm E `e10`).
* § `droppedCall14` / § `droppedIdxRecvCall26` / § `invalidNewCallFromSyntax55` /
  § `typeParamScopedCallRef59` are all reached from the SAME `Invalid` arm and
  none of their predicates was touched; the two dotted-operand builders here
  ARE § 14's own (`emitDroppedArg14`, `emitDroppedCall14`, both with
  `bind = false`), so a recovered operand is the object those laws already
  gate-verified.
* § `classArgBind12`'s window is opened by hand around the operand loop, the
  same window the bound concat arm opens.
* the DIRECT-literal parenting decision is transcribed from the two places that
  make it in the bound path (the concat arm's per-operand window and the
  `StringLiteral` arm's test), so a recovered literal is parented exactly as its
  accepted twin.

---

## 4. THE PREDICTION, MADE FROM THE PRISTINE DATABASES BEFORE ANY PATCHED ONE EXISTED

`predsweep160.sh` + `predjoin160.py` census BOTH pristine sides of every row of
a `verify_golden` workdir and print every OPERATION, ASSIGNMENT Rhs, call
ARGUMENT list, CONDITION and `hier_path` element list whose golden side is
PRESENT and ours ABSENT or TRUNCATED — plus the mirror buckets.

```
surelog    : rows=956  SKIP-NOFILE=617  PRED-TOWARD 25  PRED-AWAY 0  PRED-TRUNC 2  PRED-GROW 14
uhdm2rtlil : rows=1358 SKIP-NOFILE=104  PRED-TOWARD  0  PRED-AWAY 0  PRED-TRUNC 0  PRED-GROW  0
```

All 25 `PRED-TOWARD` cells are `vpiOpType 33` — **the concatenation is the only
context in the whole corpus that loses anything**, which is arm C's result over
again. They live at three sites:

| site | golden's operands | rows |
|---|---|---|
| `uvm_pkg::uvm_reg_predictor::get_type_name` `121:19-121:67` (BuildUVMPkg: `::type_name` `61838:21`) | `constant, hier_path(t.get_type_name), constant` | 9 |
| `uvm_pkg::uvm_utils::get_config` `721:27` and `726:27` | `constant, ref_obj(FIELD), constant, ref_obj(TYPE::type_name), constant` | 14 |
| `uvm_pkg::uvm_registry_common::create` `14061:13-14064:70` | 12 operands, two of them nested `operation`s (a ternary) | 2 |

`predmovers160.py` splits them with a predicate evaluated on GOLDEN's own
operand kind list — the five modelled shapes can only ever produce a
`constant`, a `ref_obj` or a `hier_path` — giving **RECOVER 23 / ABSTAIN 2**
and this **mover set, BY NAME**:

```
MOVER default/BuildUVMPkg   MOVER default/MiniAmiq   MOVER default/Scoreboard
MOVER default/SeqDriver     MOVER default/SimpleUVM
MOVER testflags/BuildUVMPkg MOVER testflags/MiniAmiq MOVER testflags/SeqDriver
MOVER testflags/SimpleUVM
```

i.e. **9 databases on surelog, 0 on uhdm2rtlil**. (`Scoreboard/testflags` is
`SLANG_REJECT` and has no `slang.uhdm`; it is one of the 617 SKIP-NOFILE rows,
counted, never read as agreement.)

`byteverify.sh --selfcheck` then measured **MOVERS 9 / 956** on surelog and
**0 / 1358** on uhdm2rtlil — the predicted set exactly, with no unpredicted
mover and no predicted non-mover.

**The two other pristine buckets are NOT this law and were left alone**, which
the patched sweep confirms cell for cell:
`PRED-TRUNC` is Earlgrey's `work@top_earlgrey.u_hmac.u_hmac` `119:5` op75
(golden `constant(0),constant(0)`, ours `constant('0)`) — an unbased literal
inside an assignment pattern, r10earl99's head, byte-identical here;
`PRED-GROW` is `uvm_report_fatal`/`uvm_report_warning`'s DEFAULT-ARGUMENT
filling (golden 5 args, ours 7), untouched.

---

## 5. THE GRID — 6 ARMS, BOTH VIEWS, THREE WAYS

`grid160.sh` builds Surelog's golden, our pristine and our patched database for
each arm in BOTH views (12 commands per arm, each echoed into the arm's own
`cmds.txt` with its binary PATH and its own `rc=` line — **all 72 returned
rc=0**, so no cell is a segfault wearing a result). `score160.py` scores every
cell three ways over five row families.

| arm | what it varies |
|---|---|
| `g160_a_badkind.sv` | WHAT MAKES THE OPERAND BAD: a method call on an int-typed type-parameter local (the corpus head), a member select on it, a `::` scoped name and a `::` scoped call on the type parameter, a call on a `string`-defaulted type-parameter local, a BAD ARGUMENT inside a GOOD call, nested bad-in-good-in-bad, a one-operand concat — plus two NEGATIVE CONTROLS (an index select, which slang BINDS, and a call on a real class handle) |
| `g160_b_operand.sv` | WHAT THE OTHER OPERANDS ARE: twelve kinds × (ACCEPTED twin, REJECTED twin) — literal, class type parameter, class localparam, class property, method local, formal, package parameter, dotted call, bare call, ternary, nested concat, dotted name |
| `g160_c_context.sv` | WHERE THE BAD SUB-EXPRESSION SITS: ten contexts — bare assignment Rhs, CONCAT operand, binary operand, ternary arm, call argument, condition, return value, case selector, system-call argument, bare statement |
| `g160_d_home.sv` | WHERE THE REJECTED CONCATENATION LIVES: in-body method, out-of-body method, task, static method, two type parameters — plus the two controls that must NOT move (a specialization whose argument is a REAL class, a NON-parameterized class) and an explicit specialization beside the default in ONE database |
| `g160_e_edge.sv` | COUNTS, ORDER AND EDGES: bad FIRST / LAST, two bad, three all bad, one operand, two rejected concats in one method, rejected-inside-rejected, an LVALUE concat, a REPLICATION operand, an UNPACKED-ARRAY concat, a concat in CALL-ARGUMENT position, an ACCEPTED control, a second generic class |
| `g160_f_witness.sv` | THE REDUCED CORPUS WITNESSES — `uvm_reg_predictor.svh:54,117-124`, `uvm_utils::get_config`'s call-argument concat, and the `` `uvm_warning `` MACRO face. Pristine **67 cmp lines / 1 head** in the def view (the SAME 67 the corpus rows report) and 71 / 1 in elab; patched **0 / 0 in BOTH views** |

**GRID TOTALS (6 arms, both views, five row families, `--nospan`):**

```
RIGHT=151  TOWARD=106  WRONG=0  STILL=7  RESHAPE=0
ONLY-G=31  AWAY=2  ONLY-OURS=3  ONLY-A=0
```

* **`WRONG = 0`** — no cell that was right pristine is wrong patched.
* **`RESHAPE = 0`, `ONLY-A = 0`** — nothing changed shape and nothing was deleted.
* **`AWAY = 2`, and the JUDGE says otherwise on the very same database.** Both
  are arm F's `` `uvm_warning `` macro cell, and they pair with 2 `ONLY-G`
  cells for the SAME objects at golden's macro-BODY span. `uhdm-cmp` judges
  `g160_f_witness.sv`'s patched database **EQUAL — 0 cmp lines, 0 heads — in
  BOTH views**, where the pristine one is 67 and 71 lines with a head. **The
  AWAY column is 0 as the acceptance judge measures it**; the census's 2 are a
  SPAN-KEY artifact, because no generated `Compare` reads
  `VpiLineNo`/`VpiColumnNo` (RESUME.md §9). The same 2-cell pattern appears 14
  times over in the corpus census and is decoded there (§8).
* **arm C is the scoping result**: of ten contexts, **only the CONCAT one
  moved**. The other nine are `RIGHT` on BOTH binaries — slang keeps the parts
  of every other compound bad node, so § `droppedCall14`'s unwrap already had
  them.
* **arm D's two controls stayed `RIGHT`**, and its five generic homes all
  recovered (17 TOWARD, 0 anything else).

---

## 6. THE RESIDUES THIS PASS DOES NOT CLOSE (each MEASURED, none guessed)

**R1 — five operand shapes are DELIBERATELY not modelled, and the law abstains
on the WHOLE concatenation when it meets one.** All seven grid `STILL` cells
are exactly these, and every one of them is `A == B` — untouched:

| cell | the operand the law refuses |
|---|---|
| `b_operand bd_bc` | a BARE call `gname()` → golden `func_call` |
| `b_operand bd_nc`, `e_edge e7` | a NESTED concatenation → golden `operation` |
| `b_operand bd_tn` | a TERNARY → golden `operation(vpiConditionOp)` |
| `e_edge e9` | a REPLICATION → golden `operation(vpiMultiConcatOp)` |
| `a_badkind a6`, `a7` | a call whose ACTUAL is itself a call — § `droppedCall14`'s own shape test refuses those actuals, and this law asks that test |

The corpus cost of R1 is exactly **2 cells**: BuildUVMPkg's
`uvm_pkg::uvm_registry_common::create` (`uvm_registry.svh:563`, both modes),
whose 12-operand message holds two ternaries. Adding a ternary operand means
emitting a bound `obj.get_type_name()` from syntax, which is a different law.

**R2 — a rejected concatenation still loses its SPAN when it is a macro
ARGUMENT.** Golden reports the objects of a `` `uvm_warning({...}) `` at the
macro BODY (`uvm_message_defines.svh:133`), we report them at the macro
argument (`uvm_misc.svh:664` / `:675`). It is PRE-EXISTING — our pristine
database already spans the enclosing `func_call` `132:8-132:293` where golden
spans `132:8-133:185` — and it is DUMP-ONLY: `uhdm-cmp` never reads a span, and
arm F's macro cell is judged EQUAL. 16 lines per uvm-1.2 row in the whole-dump
diff (§8).

**R3 — a rejected block still loses its own span and its type-param local's
`int_typespec` span**, r10uvm158's R1 and R3/R4 unchanged. Visible in every
grid arm's dump, read by no generated `Compare`.

**R4 — `uvm_report_fatal` / `uvm_report_warning` still get 7 arguments where
golden gets 5** (our DEFAULT-ARGUMENT filling adds `constant("")` and
`constant(0)`). Pristine `PRED-GROW`, 14 cells, byte-identical after this pass.

**R5 — an ASSOCIATIVE-ARRAY typedef's emitted "size" is a leaked pointer.**
`typedef C22 ka_cls_t[string];` produces a `range` whose right operand is
`operation(vpiSubOp)` over `constant(UINT 22552281) - 1`. The value tracks the
BINARY's memory layout: three builds give two values, and the one that agrees
with this pass's patched binary is a build of DIFFERENT SOURCE (the main tree at
`400a941d`). It is what moved two boundary arms and it is refuted in full in
`BOUNDARY.r10uvm160.txt`. No corpus database reaches it (0/1358 uhdm2rtlil byte
movers; the 9 surelog movers are the 9 predicted).

---

## 7. THE NEXT HEAD (R0)

The head moves to **TWO different objects**, and they are named here from the
patched sweep with `ct160own`:

**R0a — SimpleUVM default and testflags, 29 cmp lines, 1 head each (the same
object; only serializer ids differ):**

```
LHS: chandle_var: (uvm_pkg::uvm_component_name_check_visitor::visit::compiled_regex)
                  @257:18-257:32
     |vpiParent:  \_begin: (…::visit) @259:3-260:58
     |vpiTypespec: \_ref_typespec -> \_chandle_typespec @257:10-257:17
RHS: <null>
parent chain: begin @259:3-260:58 < function(visit)@255:2 < class_defn(
              uvm_component_name_check_visitor)@243:1 < package(uvm_pkg) < design
```

Source — `uvm-1.2/src/base/uvm_traversal.svh:255-262`, inside
`class uvm_component_name_check_visitor #(type NODE=uvm_component)`:

```systemverilog
  virtual function void visit(NODE node);
    static chandle compiled_regex;                       // :257   <- THE HEAD
    if(compiled_regex==null)
      compiled_regex=uvm_dpi_regcomp(get_name_constraint());
```

A **`static` METHOD-LOCAL** declared inside a generic class's method: golden
lists it, we do not. The next pass must decode which `SafeCompare` printed the
null (`ct160own.cpp` prints the parent chain but only walks `operation`'s field
order — extend it to `scope`'s, as `r10uvm157repro/ct157own.cpp` does) and
whether the missing listing is the `begin`'s `scope::Variables` or the
function's.

**R0b — Scoreboard/default, 145 cmp lines, 1 head, a DIFFERENT object:**

```
LHS: class_typespec: (uvm_analysis_imp) @9:3-9:19
     |vpiParent: \_class_var: (work@my_scoreboard::m_imp) @9:42-9:47
     |vpiParameter: \_type_parameter: (work@my_scoreboard::m_imp::uvm_analysis_imp::T)
                    @110:31-110:32
RHS: <null>
```

Scoreboard/default is the ~50/50 COIN (RESUME.md §9), so a resumed pass must
re-measure it on its own pristine build before believing this line.

---

## 8. THE CORPUS CENSUS — 9 MOVED DATABASES, THREE WAYS

`scoreall160.sh` censuses golden, our pristine and our patched database for each
moved row and scores every OP / ASGN / ARG / COND / HP cell
(`CENSUS.r10uvm160.txt`). Summed over the 9 rows and both views:

| family | RIGHT | TOWARD | WRONG | STILL | RESHAPE | AWAY | ONLY-A |
|---|---|---|---|---|---|---|---|
| OP | 61822 | **23** | 0 | 5118 | 0 | 0 | 0 |
| ASGN | 53378 | 0 | 0 | 13 | 0 | 0 | 0 |
| ARG | 90541 | **9** | 0 | 14 | 0 | 14 | 0 |
| COND | 57838 | 0 | 0 | 4 | 0 | 0 | 0 |
| HP | 50966 | **9** | 0 | 2 | 0 | 14 | 0 |

**The 23 OP cells are EXACTLY the 23 the prediction named**, and
`WRONG = RESHAPE = ONLY-A = 0` in every row and every family.

**THE 28 `AWAY` CELLS ARE THE MACRO-SPAN ARTIFACT, and every one of them pairs
with an `ONLY-G` cell for the same object.** All 28 are
`uvm_pkg::uvm_utils::find` / `find_all`'s `` `uvm_warning({...}) `` at
`uvm_misc.svh:663-664` and `:674-675` — a fourth and fifth rejected
concatenation the span-keyed prediction could not see, because our enclosing
`operation` sits at `132:50-664:100` and golden's at `132:50-133:82`. Golden's
operand list and ours are now **identical, operand for operand**:

```
G  132:50-133:82   op33  4  constant("Instance of type '"), ref_obj(TYPE::type_name),
                             constant(" not found in component hierarchy beginning at "),
                             hier_path(start.get_full_name)
O  132:50-664:100  op33  4  <the same four>      (pristine: NOPS = -1)
```

and the 14 `ARG` + 14 `HP` `AWAY` cells are the `method_func_call(get_full_name)`
and `hier_path(start.get_full_name)` inside them, which golden reports at
`133:56-133:77` / `133:62-133:75` and we report at `664:78-664:99` /
`664:84-664:97`. Arm F's macro cell builds exactly this shape and `uhdm-cmp`
judges it **EQUAL**.

**THE ORDER-BLIND WHOLE-DUMP DIFF** closes the attribution (Scoreboard/default
is a coin, so order-blind is the only sound instrument):

```
row                              added  deleted   order-blind distance to golden
default/BuildUVMPkg                 27        0     67020 -> 66993   TOWARD
default/MiniAmiq                   153        0    341453 -> 341332  TOWARD
default/Scoreboard                 153        0    117134 -> 117013  TOWARD
default/SeqDriver                  153        0    324504 -> 324383  TOWARD
default/SimpleUVM                  153        0    126840 -> 126719  TOWARD
testflags/BuildUVMPkg               27        0     67020 -> 66993   TOWARD
testflags/MiniAmiq                 153        0    341453 -> 341332  TOWARD
testflags/SeqDriver                153        0    324504 -> 324383  TOWARD
testflags/SimpleUVM                153        0    126836 -> 126715  TOWARD
```

**ZERO deleted lines on every row, and the distance to golden falls on every
row.** On BuildUVMPkg all 27 added lines are golden lines verbatim. On each
uvm-1.2 row, 137 of the 153 are; the remaining **16 are listed line by line in
`DUMPDIFF.r10uvm160.txt`** and are the R2 macro-span twins — the same
`hier_path`, `method_func_call`, `ref_obj`, `constant` and `operation` objects
golden holds at line 133.

---

## 9. THE GATES

All green; the full battery with its numbers is `GATES.r10uvm160.txt`. In one
line: goldens **23/0** and `/bin/false` **0/23**; uhdm2rtlil **679/50/2** both
modes with **0 differing rows** against BOTH the committed baseline and this
pass's own pristine sweep, and **0/1358 byte movers**; surelog status histograms
**identical to this pass's own pristine sweep** with **0 differing rows over
1588** and **9/956 byte movers, all 9 predicted by name**; canaries **52/8 ok,
0 changed**, `ctcan2` PASS both corpora, `canaudit` **audited=29 UNCOVERED=0
FENCE-BREACH=0**; the six protected databases byte-identical with
`SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on their pins; the wide
boundary **LISTED=4462 PROCESSED=4462 PRODUCED_DBS=4315 MOVED_ARMS=12
RC_DIFFS=0**, six of the twelve being this pass's own positive control, three
(`r10uvm158repro/g158_f_witness.sv`, `r10uvm59repro/vcells/c09_concat.sv`,
`r10v158repro/arms/probe0.sv`) moving from 67 / 49 / 67 cmp lines to
**CMP_EQUAL**, one (`r10v103repro/arms/v103_b5.sv`) re-measured TOWARD (188 →
168 order-blind, 23 added, 0 deleted) and two refuted as R5's build-layout
artifact.

**NO CORPUS ROW CONVERTED.** `CMP_NOTEQUAL` stays 10 (default) + 9 (testflags)
on surelog; `results/*.csv` were read only.

---

## 10. FILE MAP

| file | what it is |
|---|---|
| `ct160cen.cpp` | the census — one row per `operation` (opType, NULL-vs-EMPTY operand count, ordered operand list), per `assignment`/`assign_stmt`/`cont_assign` (Lhs / Rhs kind), per call (argument vector), per condition-bearing statement, per `hier_path` (element vector) |
| `ct160own.cpp` | the OWNER-FINDER — runs the real `design::Compare`, names the head, recovers OUR counterpart, checks the enclosing `assignment::Rhs` edge, and walks `operation::Compare`'s own field order marking the first test that can return |
| `score160.py` | the three-way cell scorer (RIGHT / TOWARD / WRONG / STILL / RESHAPE / ONLY-G / AWAY / ONLY-OURS / ONLY-A), `--rows OP\|ASGN\|ARG\|COND\|HP\|ALL`, `--nospan` |
| `predjoin160.py`, `predsweep160.sh`, `predmovers160.py` | the a-priori prediction from the PRISTINE databases only, and the RECOVER/ABSTAIN split that names the mover set |
| `scoreall160.sh` | the corpus census over the moved rows |
| `dumpdiff160.sh` | the whole-dump, path-normalised, ORDER-BLIND diff with the distance-to-golden verdict |
| `grid160.sh`, `g160_*.sv` | the six grid arms and their builder |
| `bound160.sh` | the wide boundary gate |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the standing instruments, copied unchanged |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the official `uhdm-cmp` head logs for all seven named rows, both modes, measured on THIS worktree's own pristine and patched sweeps |
| `PREDICT.r10uvm160.txt`, `CENSUS.r10uvm160.txt`, `DUMPDIFF.r10uvm160.txt`, `GRID.r10uvm160.txt`, `BOUNDARY.r10uvm160.txt`, `GATES.r10uvm160.txt` | the measurements |
