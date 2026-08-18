# r10uvm90 — § `invalidCtorCallArgsUnwrap90` — **THE SEVEN-ROW-MODE UVM HEAD CLOSED, 89 → 24**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
PASSES cmp**.

## The headline

r10uvm89 left ONE head on all seven live UVM row-modes, and named it
`method_func_call(super.new)` **MISSING-OURS**. It is gone.

| row-mode | cmp lines | head |
|---|---|---|
| SeqDriver ×2 / SimpleUVM ×2 / MiniAmiq ×2 / Scoreboard-default | 89 → **24** | `method_func_call(super.new)` `<rhs-null>` → `int_typespec` **VpiName** `this_rsp_type` vs `this_req_type` |
| BuildUVMPkg ×2 | 29 → **29** | unchanged (`io_decl(severity)`) — but **27 objects moved per mode**, said out loud |
| Earlgrey_0_1 ×2 (9743/33), Rggen-default (66) | unchanged | untouched, and **provably byte-untouched** |

**243 objects to golden over 9 databases — 27 in EVERY ONE of them**, every one
an ADDITION and every one measured by name: the 26 `uvm_pkg::uvm_*_imp::new`
`super.new` calls, plus one bare `new` in `uvm_pkg::uvm_class_pair::create`.
`ARGS-NULL-OURS` goes **26 → 0** in every mover and no join class ever gets
worse.

## THE BRIEF'S FRAMING IS REFUTED: the object was NEVER MISSING

The brief and r10uvm89's README read the head as a **missing object**. It is
not. **We emitted the `method_func_call(super.new)`; its ARGUMENT VECTOR WAS
NULL.** (ctladder gets it half right and is worth quoting for that: its rung
prints `FIELD=<rhs-null>` — exactly the truth — beside
`SHAPE=MISSING-OURS`, which is the half that misleads.) Three independent
proofs, and the fix depended on knowing which one it was:

1. **THE PRISTINE DUMP.** `g90_a1_witness.sv` reproduces the head in one file;
   pristine's `work@w1imp::new` body holds
   `\_method_func_call: (super.new)` with `vpiParent` and `vpiName` and **no
   `vpiArgument` at all**, in a `begin` that also holds both assignments.
2. **THE COMPARATOR'S OWN HEADER.** `BaseClass.h:202` — the VECTOR overload of
   `SafeCompare` — has this arm:
   ```
   } else if ((lhs != nullptr) && !lhs->empty() && (rhs == nullptr)) {
       context->m_failedLhs = lhs_obj;      // THE OWNER, not an element
       return 1;                            // m_failedRhs left UNSET
   ```
   so a golden-populated / ours-NULL vector prints the **OWNER** as `LHS` and
   `RHS: <null>`. That is byte-for-byte the head r10uvm89 recorded.
3. **THE OWNER'S COMPARE ORDER.** `tf_call::Compare`
   (`UHDM/build/generated/src/tf_call.cpp:87`) reads
   `Scope`, then **`Tf_call_args` (the vector), then `VpiName`** — the argument
   vector is the FIRST vector-valued field of the object, which is why this one
   fact was the head of seven row-modes and not a residue behind something else.

## The law

> A `NewClassExpression`'s `constructorCall` may be an **`InvalidExpression`
> WHOSE CHILD IS THE `CallExpression`** — bound arguments and all. Read the
> arguments through that one indirection; Surelog type-checks nothing and emits
> them regardless of whether slang's assignment conversion succeeded.

### The decode, from slang

`CallExpression::fromArgs`
(`slang/source/ast/expressions/CallExpression.cpp:306`) builds the call
**first** and wraps it **after**:

```
SmallVector<const Expression*> boundArgs;
bool bad = !bindArgs(argSyntax, symbol.getArguments(), symbol.name, range, context, boundArgs);
auto result = comp.emplace<CallExpression>(&symbol, ..., boundArgs.copy(comp), ...);
if (bad)
    return badExpr(comp, result);            // <-- result IS the child
```

and `bindArgs` (`:200`, tail at `:274-280`) fills `boundArgs` for **every**
formal whether or not the actual converted:

```
if (!expr) { bad = true; }
else { bad |= expr->bad(); boundArgs.push_back(expr); }   // PUSHED ANYWAY
```

`NewClassExpression::fromSyntax`
(`AssignmentExpressions.cpp:684-698`) then stores whatever `fromArgs` returned
and **still creates the NewClass node** — which is exactly why our emitter's
`case ExpressionKind::NewClass` arm already built the `method_func_call`, and
built it with no arguments: its gate was `cc9->kind == ExpressionKind::Call`,
and `cc9` was `Invalid`.

`resolveNewClassTarget` (`AssignmentExpressions.cpp`, quoted in full in the
in-code comment) is **not** the failing step for `super.new`: the
`SuperKeyword` branch resolves the base class, skips the `isAbstract` and
`isInterface` refusals outright (`if (!isSuperClass && ...)`) and returns a good
`classType`. The failure is in the ARGUMENTS.

### The corpus site

`uvm-1.2 src/tlm1/uvm_tlm_imps.svh:205-211`, macro `UVM_IMP_COMMON(MASK,TYPE_NAME,IMP)`:

```
  local IMP m_imp;
  function new (string name, IMP imp);
    super.new (name, imp, UVM_IMPLEMENTATION, 1, 1);
```

In the **DEFAULT specialization** of every `uvm_*_imp` class the type parameter
`IMP` is `int`, so the second actual is an `int` handed to
`uvm_port_base::new`'s `uvm_component parent` formal
(`src/base/uvm_port_base.svh:232`). `Expression::bindArgument` refuses it,
`bad` goes true, the call is wrapped, and **the diagnostic is suppressed**
inside a generic class's default specialization — so the database builds and
five arguments vanish **silently**. Arm a1 reproduces the diagnostic verbatim
when the class IS instantiated: `error: value of type 'IMP' (aka 'int') cannot
be assigned to type 'w1comp'`.

### The MACRO IS NOT THE AXIS — golden vs golden, measured first

The two UVM trees hold the SAME 26 classes, one with the macro **unexpanded**
(uvm-1.2, `super.new` at `uvm_tlm_imps.svh:208`) and one **already expanded** by
Surelog's preprocessor (1800.2-2017 `pp_output`, the same statement at
`uvm_pkg.sv:46240`). Both goldens carry the **IDENTICAL 26 objects with the
IDENTICAL 5-argument shape**:

```
26 NARGS=5  ref_obj:name*bound > ref_obj:imp*bound > ref_obj:UVM_IMPLEMENTATION*bare > constant > constant
```

so neither the macro, nor the `0:0` span of the call, nor the space in
`super.new (` is the term. Ours now equals golden **span for span** in BOTH
trees (`208:16-208:20` and `46240:16-46240:20`).

### The one shape golden gives NO arguments, and why the gate is not "always emit"

Golden itself carries **238** argument-less `new`/`super.new` objects in
SeqDriver (`x = new;`, `super.new()`) against our pristine **268**. The
population the law moves is only the class where golden has a POPULATED vector
and we have a NULL one — the join's `ARGS-NULL-OURS`, **26 per row-mode**, every
single one a `uvm_pkg::uvm_*_imp::new` — plus the one `uvm_class_pair` key the
attribution found. 268 → **241**, and the 3 that remain above golden's 238 are
the join's `OURS-ONLY` objects: `new` calls golden has no counterpart for at all,
which no argument law can reach. The other 238 the law CANNOT touch, because it
never turns a populated vector into a different one and never turns a null one
into a populated one unless slang bound arguments it was hiding: when `cc9` is
already a `Call`, or is `Invalid` with no child, the arm is byte-for-byte what it
was.

### The ARITY shapes cannot reach a database — measured, not assumed

`too few arguments` / `too many arguments` / `argument '<x>' does not exist` are
**NOT** suppressed in a generic class's default specialization. `g90_a3_arity.sv`
carries one cell of each and **slang-uhdm REFUSES THE FILE** (3 errors, NO
OUTPUT, both binaries). So a database can only ever contain a
**CONVERSION**-failed constructor call, which is exactly the population the
unwrap reaches. The file is kept as the refutation.

### A SECOND sub-shape found by the attribution, not by the brief

`uvm_pkg::uvm_class_pair::create`'s `v = new(name)` is wrapped for a different
reason: `uvm_class_pair #(type T1=int, T2=int)`'s constructor formals default to
`null`, and it is the **FORMAL'S DEFAULT VALUE** that fails to convert to `int`.
Golden emits ONE argument (the one written); § `writtenCallArgs16`'s
written-count truncation, already in the arm, produces exactly one. It is ONE
join key holding TWO objects, and it moves in ALL NINE movers
(`ARGS-DIFFER` 44 → 42 objects in BuildUVMPkg; in the uvm-1.2 rows the key stays
in `ARGS-DIFFER` only because golden's span is `414:21` where ours is `418:21` —
a span, which cmp does not judge). It is the 27th changed object in every
database.

## The arms

`arm90.sh <src>` = Surelog golden + BOTH binaries in ONE scratch dir; LHS is
always golden. `three90.sh <wd>` prints the GOLDEN/PRISTINE/PATCHED argument
table off `ct90cen`.

| arm | cells | reading |
|---|---|---|
| `g90_a1_witness.sv` | 4 (`w1imp` head + 3 controls) | **FIXED=1 BROKE=0**; patched equals golden byte for byte, `W1_IMPLEMENTATION`'s unbound `ref_obj` and both constants included |
| `g90_a2_shapes.sv` | 7 | **FIXED=3 BROKE=0**, and the whole arm goes **CMP_FAIL → PASS_CMP**. Fixed: positional type mismatch (b1), a BARE `new(...)` with a mismatched actual (b4, golden's args `*bare`), a mismatched actual that is an EXPRESSION (b6, golden emits an `operation`). Unmoved controls: a clean generic `super.new` (b8), a non-generic one (b9), and a **PORT-LESS** constructor (b10) whose first element § `constructorBodyElementShift27` eats on BOTH sides |
| `g90_a3_arity.sv` | 3 | **NO_OUTPUT on both binaries** — the refutation above |

## The gates

All in `GATES.r10uvm90.txt`. Headlines: goldens **23/0** on both binaries and
**0/23** with `/bin/false`; surelog **1588 rows, 0 differing** against the
committed baseline on BOTH binaries; uhdm2rtlil **679/50/2, 0 differing** in
both modes; byteverify **9 movers / 956** on surelog and **0 / 1358** on
uhdm2rtlil, with `SELFCHECK`=955/956 and `SELFCHECK1`=10 (9 real + 1 corrupted);
the five named pins **all SAME** (`SVSwitch 4842211c4030`, `YosysVerx
6ccda350c24a` — the brief's own pin values); canaries **0 changed** in both
corpora with `canaudit.sh` reporting `UNCOVERED=0 FENCE-BREACH=0`; and the
**WIDE boundary gate** compiles **2303** arm sources from all 188 probe
directories with **MOVED=2** — this pass's own two arms and nothing else.

## The mover set, PREDICTED BY NAME FIRST

`pred90.sh` reads PRISTINE bytes only: 2165 argument-less `new` objects over 17
rows — the CANDIDATE set. `pred90b.sh` sharpens it against GOLDEN (never against
the patched sweep) to the `ARGS-NULL-OURS` class: **9 rows, 234 objects**.
`byteverify.sh` then found **exactly those 9 databases**, by name, and no others
— the DATABASE prediction was exact, and the OBJECT prediction was 234 against
the 243 the attribution measured (the `uvm_class_pair` key per database is
invisible to that class). Both numbers are in `PREDICT.r10uvm90.txt`.
The four candidate rows predicted NOT to move (`SVSwitch`, `ClassMini`,
`ClassTypeParam`, `ClassParamAsParam`) did not.

Every mover is a **PURE ADDITION**: the order-blind dump comparison
(`sort`ed, ids stripped, paths normalised) is **994 lines added, 0 removed** on
all nine.

And the multi-head ladder says the same thing without looking at the family at
all (`LADDERS.r10uvm90.txt`, MEASUREMENT-ONLY): `default/SeqDriver` **429 → 402**
rungs and `default/BuildUVMPkg` **165 → 139**, i.e. **27 and 26 rungs REMOVED and
ZERO ADDED** — every other family's rung count is byte-identical across the two
ladders. ctladder's 27 rungs on SeqDriver and ct90cen's 27 changed objects there
are two instruments agreeing on one number by two different mechanisms.

## R0 — the new head, on all seven row-modes at once

```
uvm-1.2 src/tlm1/uvm_imps.svh:232-238
  232   class uvm_blocking_master_imp #(type REQ=int, type RSP=REQ, type IMP=int,
  233                                   type REQ_IMP=IMP, type RSP_IMP=IMP)
  234     extends uvm_port_base #(uvm_tlm_if_base #(REQ, RSP));
  235     typedef IMP     this_imp_type;
  236     typedef REQ_IMP this_req_type;
  237     typedef RSP_IMP this_rsp_type;

LHS golden  int_typespec (this_rsp_type)  @232:70-232:73  < class_defn(uvm_blocking_master_imp)
RHS ours    int_typespec (this_req_type)  @236:11-236:18  < class_defn(uvm_blocking_master_imp)
FIELD VpiName   SHAPE TEXT:this_rsp_type|this_req_type
```

A **typespec-list identity** fact in the `uvm_*_master_imp` /
`uvm_*_slave_imp` family (six classes). Golden's element is named for the
`this_rsp_type` typedef but SPANS the class HEADER's `type RSP_IMP=IMP` default
(`232:70-232:73`, the `IMP` token); ours is named for `this_req_type` and spans
the TYPEDEF STATEMENT's referenced type (`236:11-236:18`, the `REQ_IMP` token).
So the two sides disagree on **which typedef of the three the class_defn's
typespec vector holds at that slot, and on which written token it is built
from** — Surelog appears to key the element on the PARAMETER it resolves to,
where we key it on the typedef. ctladder's SeqDriver census (MEASUREMENT-ONLY, `LADDERS.r10uvm90.txt`) puts this
family at **6 rungs** in the PATCHED ladder, behind
`<null>|<lhs-null>|EXTRA-OURS` (74) and `constant|VpiSize|INT:G<O` (20) — and it
is the one uhdm-cmp reaches first.
