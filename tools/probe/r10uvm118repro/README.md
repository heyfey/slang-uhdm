# r10uvm118 — § implicitStrConcatNoCast118: a cast operation exists in golden if and only if a `'` was written

**MEASUREMENT-ONLY directory.** The official `~/git-repos/UHDM/build/bin/uhdm-cmp`
remains the sole acceptance judge. **BASE `9ac2763`.** `results/*.csv` was READ
ONLY and is untouched — **no row was converted**; the master promotes rows, not
this pass.

**The head r10uvm117 named as R0 — SimpleUVM (both modes) and Scoreboard
(default), 17 cmp lines, one head, the same object in all three rows — is
CLEARED,** and every other named row's head is unchanged.

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_*.cmp` are the verbatim pristine logs, reproduced from a build of
`9ac2763` in this pass's own worktree whose md5 equals the main tree's binary at
`9ac2763`.

```
LHS (golden)   <null>
RHS (ours)     ref_typespec (uvm_pkg::uvm_sequence_library::execute)
               |vpiParent -> operation 115:55-115:100
               |vpiActual -> logic_typespec   (NO location, NO name)
```

**Which arm.** Read the generated `Compare` order before naming the field:

```c++
// UHDM/build/generated/src/expr.cpp
int32_t expr::Compare(...) {
  basetype_t::Compare(...)                            // VpiType/VpiName/VpiDefName
  lhs->VpiDecompile().compare(rhs->VpiDecompile())
  lhs->VpiSize() - rhs->VpiSize()
  SafeCompare(lhs->Typespec(), rhs->Typespec(), ...)  // <-- THE HEAD
}
// UHDM/build/generated/src/operation.cpp
int32_t operation::Compare(...) {
  basetype_t::Compare(...)      // via expr::Compare, i.e. AFTER the typespec
  lhs->VpiOpType() - rhs->VpiOpType()   // <-- never reached
  ... Operands() ...
}
// BaseClass.h:187-199, singular overload, lhs == nullptr && rhs != nullptr:
//   sets m_failedRhs only -> the `LHS: <null>` spelling.
```

`expr::Compare` reaches `Typespec()` **before** `operation::Compare` ever looks
at `VpiOpType`, so a **surplus OPERATION** reported as a bare typespec
mismatch. The object is not a stray typespec at all:

| | golden | ours |
|---|---|---|
| concat operand | `operation` **vpiConditionOp (32)**, 3 operands | `operation` **vpiCastOp (67)**, 1 operand |
| that operation's typespec | — | `ref_typespec` -> loc-less nameless `logic_typespec` |
| the ternary itself | the operand | nested one level deeper under the cast |

**Which object.** `uvm_sequence_library.svh:775`, inside the OUT-OF-BODY class
task `uvm_sequence_library::execute` (`:749`):

```systemverilog
  `uvm_info("SEQLIB/EXEC",{"Executing ",(seq_or_item.is_item() ? "item " : "sequence "),
                           seq_or_item.get_name()," (",seq_or_item.get_type_name(),")"},UVM_FULL)
```

The `?:` lands at the MACRO's own span — `uvm_message_defines.svh:115:55-115:100`,
inside `` `define uvm_info(ID, MSG, VERBOSITY) `` — which is why the head prints a
line number that is nowhere near the task.

---

## 2. Question 1 — the census: WHICH operations carry a typespec, golden vs ours

`ct118cen.cpp` emits ONE ROW PER `operation` object out of a `.uhdm`:
`OPT` / `NOPS` / `SPAN` / `PAR` (parent kind, plus the parent's opType when the
parent is an operation) as KEY, and the `Actual_typespec`'s KIND / located-ness /
name as the scored PAYLOAD. `HOME` (nearest task / function / process /
cont_assign / param_assign / scope, by `vpiFullName`), `REGION` (the home class:
module process / initial-final / gen scope / class in-body method / class
out-of-body function / class out-of-body TASK / package function / package task /
free function / cont-assign / param-init) and `MACRO` (1 when the operation's
line falls OUTSIDE its home's line range, i.e. the span comes from a macro
definition file) ride along for the split but are **not** in the join key.

**Three keying traps this instrument avoids**, each already paid for elsewhere in
this campaign:

1. **`VpiParent` is not a key beyond its KIND.** No generated `Compare` reads it.
2. **Nesting DEPTH is not a key.** This pass's whole subject is an operation WE
   INSERT; a depth-keyed census would report the entire subtree beneath it as
   moved. `SPAN+OPT+NOPS+PAR` joins the surviving cells and leaves the inserted
   one as a clean ours-only row.
3. **`Serializer::AllObjects` can name objects that are not in the dump tree**
   (uvm97's lesson). `ROOT=` records where the parent walk ends, so an
   unreachable object is visible as such and is never silently scored.

`join118.py` is a MULTISET join (a last-writer dict drops colliding rows).

### The answer, over the NINE UVM databases (both modes; Scoreboard/testflags is SKIP-NOFILE)

| database / mode | ops with a typespec, golden | ours | BOTH-SAME | MOVED-WRONG | **OURS-ONLY** | **GOLDEN-ONLY** |
|---|---:|---:|---:|---:|---:|---:|
| SeqDriver / default    | 68 | 81 | 55 | 13 | **13** | **0** |
| SeqDriver / testflags  | 68 | 81 | 55 | 13 | **13** | **0** |
| SimpleUVM / default    | 48 | 55 | 41 | 7  | **7**  | **0** |
| SimpleUVM / testflags  | 48 | 55 | 41 | 7  | **7**  | **0** |
| Scoreboard / default   | 48 | 55 | 40 | 8  | **7**  | **0** |
| MiniAmiq / default     | 71 | 84 | 57 | 14 | **13** | **0** |
| MiniAmiq / testflags   | 71 | 84 | 57 | 14 | **13** | **0** |
| BuildUVMPkg / default  | 37 | 44 | 29 | 8  | **7**  | **0** |
| BuildUVMPkg / testflags| 37 | 44 | 29 | 8  | **7**  | **0** |

Two facts the census establishes and that the whole pass rests on:

> **EVERY operation-carried typespec in EVERY one of these databases — golden's
> and ours alike — sits on a `vpiCastOp` operation. There is no other
> operation-typespec population to disturb** (earl72's and earl75's
> `ref_typespec` families live on CONSTANTS, not on operations, and are
> therefore structurally out of this census).

> **The GOLDEN-ONLY column is 0 in all nine**, and the ours-only cells are
> exactly the whole cast surplus (`ourscast - goldcast == OURS-ONLY` in every
> row). There is nothing to "add"; this law only REMOVES.

`MOVED-WRONG` is a **pre-existing, untouched** population: cast typespecs whose
NAME differs (`uvm_reg_data_t` / `uvm_reg_cvr_t` vs our `uvm_pkg::…`) plus one
golden `unsupported_typespec` alternate. Its count is identical before and after.

### The ours-only population, split by HOME

Four distinct SOURCE SITES, each appearing once per class view (in-body and
out-of-body) and once per package the UVM tree is compiled into
(`uvm_pkg`, plus `adpcm_pkg` / `svaunit_pkg` in SeqDriver / MiniAmiq):

| site | home REGION | MACRO |
|---|---|---|
| `uvm_sequence_library.svh:775` `(seq_or_item.is_item() ? "item " : "sequence ")` | class OUT-OF-BODY **TASK** (+ its in-body view) | **1** (`uvm_message_defines.svh:115`) |
| `uvm_phase.svh:1071` `(s.len()>0?".":"")` | class OUT-OF-BODY **FUNCTION** (+ in-body) | 0 |
| `uvm_phase.svh:642` `(i == aa.num()-1) ? "" : ", "` | class in-body function | 1 |
| `uvm_reg_model.svh:398` `(i == 0) ? "" : ", "` | **PACKAGE FUNCTION** | 0 |

Every one of them has `PAR=operation:33` — **the parent is a CONCATENATION**.
That is not a coincidence; it is the mechanism (§3).

### Corpus-wide, a-priori, out of PRISTINE databases only

`pred118.sh` runs `ct118cen` on OUR pristine `.uhdm` and on the golden the
workdir's own `cmds.txt` names, for **every** database in both corpora, and
counts the family fingerprint — a `vpiCastOp` whose `Actual_typespec` is a
LOC-LESS, NAMELESS `logic_typespec` **and whose parent is a concatenation**:

| corpus | databases measured | golden family cells | ours family cells |
|---|---:|---:|---:|
| surelog | 956 | **0** | 46, in exactly **9** databases (the table above) |
| uhdm2rtlil | 1358 | **0** | **0** |

so the mover set was PREDICTED BY NAME before the patched binary was swept:
**the nine UVM databases and nothing else.**

The over-approximating stage-1 fingerprint (loc-less logic cast, parent
unconstrained) flagged ONE extra uhdm2rtlil database, `static_cast_simple`
(8 cells) — whose cells have `PAR=operation:67`, a `9'(unsigned'(s1))` nested
reinterpret, target type NOT string. Stage 2 refuted it by the `isString()`
fence, and it did not move.

---

## 3. Question 2 — OUR MINT, and Question 3 — GOLDEN'S REFUSAL

### Ours

`src/ExprEmit.cpp`, `case ExpressionKind::Conversion:`. The case opens with

```c++
if (conv.isImplicit()) return emitExpr(conv.operand(), parent, prefix, netMap);
```

and `ConversionExpression::isImplicit()` is `conversionKind <
ConversionKind::StreamingConcat`. slang's
`ConcatenationExpression::fromSyntax` (`source/ast/expressions/OperatorExpressions.cpp:1982`)
walks a concatenation that has at least one STRING-typed operand and wraps
**every** non-string operand:

```c++
expr = &ConversionExpression::makeImplicit(context, comp.getStringType(),
                                           ConversionKind::Explicit, *expr,
                                           nullptr, {});
```

— a COMPILER-INSERTED conversion nevertheless **tagged `Explicit`**, so
`isImplicit()` is FALSE and the drop never fired. `makeImplicit`
(`ConversionExpression.cpp:442`) never assigns `result->syntax`, so the
conversion carries **no cast syntax at all**; the arm therefore fell all the way
through to the cast mint, whose catch-all
(`else { auto* lts = s.MakeLogic_typespec(); cts = lts; }`) gave it a
**loc-less, nameless `logic_typespec`** — the `string` target is a `StringType`,
which no arm above the catch-all claims **without written `string'` syntax** —
and the `ref_typespec` wrap named it after `prefix`, i.e. the enclosing
subroutine. That is the head's `(uvm_pkg::uvm_sequence_library::execute)`
verbatim.

**The mint's own whole population** is the census above: it is reached only
through this case, and every cell it produced in either corpus carries the
loc-less-logic fingerprint — 87 cells in 9 surelog databases, 0 in uhdm2rtlil,
**0 of them agreeing with golden**. There is no agreeing half to preserve.

The pre-existing guard one line above already knew this family — but only for a
STRING-LITERAL operand:

```c++
// A COMPILER-INSERTED string conversion of a string literal (the implicit
// string context of {NAME, "efgh"}) carries no cast syntax — Surelog emits the
// bare string constant, no cast op.
```

The operand KIND was never the discriminator. The MECHANISM is.

### Golden

Surelog's expression compiler is **syntax-directed**. `vpiCastOp` is minted in
exactly ONE place in the whole of Surelog:

```c++
// Surelog/src/DesignCompile/CompileExpression.cpp:2637-2690
case VObjectType::paConstant_cast:
case VObjectType::paCast: {
  NodeId Casting_type = fC->Child(child);
  ...
  UHDM::operation *operation = s.MakeOperation();
  operation->VpiOpType(vpiCastOp);
  ...
  if (UHDM::typespec *tps = compileTypespec(component, fC, Simple_type, ...))
```

It reads a WRITTEN `'` out of the parse tree. Surelog has **no type-propagation
pass that inserts conversion nodes**: a concatenation's operands are compiled
from their own parse nodes, so a `?:` operand stays a bare `vpiConditionOp`
operation and an implicitly-string-typed operand stays whatever it was written
as. (`NetlistElaboration.cpp:254` and `CompileHelper.cpp:3301` only CONSUME an
existing `vpiCastOp`; `roundtrip.cpp:184` prints one back as `type'`.)

**So the boundary is a LAW, not a patch:** *a cast operation exists in golden if
and only if a `'` was written.* It is not about the home at all — the arm below
measures thirteen homes and golden emits zero cast operations in every one of
them.

---

## 4. The law

**§ implicitStrConcatNoCast118 — a COMPILER-INSERTED string conversion (slang's
`ConcatenationExpression::fromSyntax` string-context wrap: `ConversionKind::
Explicit`, NO syntax, target `string`) is NOT a cast. It emits its operand
exactly as written — no `vpiCastOp` operation, no typespec — whatever the
operand's shape and whatever home the concatenation sits in. The one fence is
the WRITTEN `'`.**

```c++
if (expr.type && expr.type->isString() &&
    (stripImplicitConv(conv.operand()).kind == ExpressionKind::StringLiteral ||
     conv.conversionKind == ConversionKind::Explicit) &&
    (!effCastSyn || effCastSyn->kind != syntax::SyntaxKind::CastExpression))
    return emitExpr(stripImplicitConv(conv.operand()), parent, prefix, netMap);
```

The first disjunct is the pre-existing string-literal rule, left standing
verbatim so nothing that passes today can change answer for a new reason; the
second is this law. THREE fences, all measured on the arms below:

* **`expr.type->isString()`** — the target must be the `string` type. This is
  what keeps `static_cast_simple`'s eight loc-less-logic casts
  (`9'(unsigned'(s1))`, a nested reinterpret whose target is integral) out, and
  it is why that database did not move.
* **`conv.conversionKind == ConversionKind::Explicit`** — a `StreamingConcat` or
  `BitstreamCast` conversion keeps its own already-measured arms
  (§ castOverStreamKeepsCast29 sits directly below and is untouched).
* **`!effCastSyn || effCastSyn->kind != CastExpression`** — a WRITTEN
  `string'(x)` keeps its cast operation and its typespec
  (§ stringCastKeepsStringTypespec26's object), including inside a string
  concatenation, and including the nested-cast `castSynOverride` route.

**Neither fence can suppress an object golden makes: in the fenced regions
golden has a cast because a `'` was written, and this law never touches those.**

---

## 5. Question 3 measured on golden — three purpose-built arms

`arm118.sh` builds each arm with Surelog (`-parse -nobuiltin -nocache -d uhdm`)
and with BOTH FROZEN binaries in BOTH views, censuses all five databases and
scores every operation.

### `g118_a1_homes.sv` — 19 rows, THIRTEEN HOMES

class in-body function / in-body task / OUT-OF-BODY function / **OUT-OF-BODY
TASK** (the corpus head's own home) / package function / package task / free
(`$unit`) function / module `always_comb` / `initial` / `final` / `always_ff` /
module function / module task / gen-`for` process / gen-`for` function /
gen-`if` process / param-init, and three MACRO-EXPANDED spans (in-body, package
function, module process).

| | operations | BOTH-SAME | MOVED-WRONG | OURS-ONLY | GOLDEN-ONLY |
|---|---:|---:|---:|---:|---:|
| golden | 81 | — | — | — | — |
| pristine, def view | 107 | 55 | 0 | 52 | 26 |
| **patched, def view** | **81** | **81** | **0** | **0** | **0** |

**Golden emits ZERO `vpiCastOp` in the whole file — in every one of the thirteen
homes, macro-expanded or not — and the patched binary emits zero too, matching
golden on all 81 operations.** The pristine binary emitted 26 of them (52
ours-only + 26 golden-only is the same 26 cells counted from both sides: the
inserted cast is ours-only, and the ternary underneath it changes parent so its
golden twin reads golden-only).

### `g118_a2_operands.sv` — WHICH OPERANDS, and the WRITTEN-cast controls

| row | operand in the string concat | golden | pristine | patched |
|---|---|---|---|---|
| O1 | `?:` of two string literals (the head shape) | no cast | cast | **no cast** |
| O2 | `?:` of two SAME-width literals | no cast | cast | **no cast** |
| O3 | `?:` with an EMPTY-string arm (uvm_phase / uvm_reg_model) | no cast | cast | **no cast** |
| O4 | NESTED `?:` | no cast | cast | **no cast** |
| O5 | inner `{"a","bb"}` concatenation | no cast | cast | **no cast** |
| O6 | `{3{"ab"}}` replication | no cast | cast | **no cast** |
| O7 | a plain string LITERAL (control: already right) | no cast | no cast | no cast |
| O8 | implicitly-typed package parameter `PP = "pp"` | no cast | cast | **no cast** |
| O9 | `?:` inside a nested concat | no cast | cast | **no cast** |
| O10 | the whole concat as a `$display` ARGUMENT | no cast | cast | **no cast** |
| **W1** | **written `string'(v)` inside the string concat** | **cast** | cast | **cast (kept)** |
| **W2** | **written `string'((n>0?8'd1:8'd2))`** | **cast** | cast | **cast (kept)** |
| **W3** | **written `string'(v)` outside any concat** | **cast** | cast | **cast (kept)** |
| **W4** | **written `int'(...)` in a NON-string concat** | **cast** | cast | **cast (kept)** |
| **W5** | **written `8'(...)` in a NON-string concat** | **cast** | cast | **cast (kept)** |
| N1 | `?:` operand of a plain integral concat | no cast | no cast | no cast |
| N2 | replication in a plain integral concat | no cast | no cast | no cast |

Cast counts: **golden 5, pristine 14, patched 5** — and the five patched casts
sit on golden's five spans exactly (41:23, 43:23, 45:19, 47:19, 49:19).
`MOVED-WRONG` is 3 both before and after: `string'(x)`'s target typespec is
`string_typespec` in golden and `integer_typespec` in ours — a **pre-existing,
separate residue** this pass does not touch and does not disturb (R1 below).

### `g118_a3_mixed.sv` — earl72 / earl75 POSITIVE CONTROLS in the same compile

Seven `P*` rows (cont-assign replication-count fold, module-body `always_comb`
fold, gen-scope `always_comb` fold, gen-scope `initial` and gen-scope for-stmt —
earl75's two fences — a function-body fold, and the QUALIFIED-read negative
control) interleaved with four `S*` string-concat rows.

| | operations | BOTH-SAME | MOVED-WRONG | OURS-ONLY | GOLDEN-ONLY |
|---|---:|---:|---:|---:|---:|
| pristine, def view | 57 | 47 | 0 | 10 | 5 |
| **patched, def view** | **52** | **52** | **0** | **0** | **0** |

and the earl72 / earl75 committed arms themselves
(`r10earl75repro/g1_gsproc75.sv`, `r10earl72repro/g1_pos72.sv`,
`r10earl72repro/g2_origin72.sv`) are **byte-identical** under the two binaries in
both views. The constant-fold `ref_typespec` stamps are untouched.

### The patch is provably ONE-SIDED

An indentation-blind, sorted whole-dump diff of pristine vs patched over all
three arms, in BOTH views:

```
A1 def 0 added / A1 elab 0 added
A2 def 0 added / A2 elab 0 added
A3 def 0 added / A3 elab 0 added
```

**Not one dump line is ADDED anywhere.** The removed lines are exactly the
`\_operation … |vpiOpType:67`, its `|vpiTypespec / \_ref_typespec / |vpiActual /
\_logic_typespec` and the `|vpiInstance / \_package` stamp the catch-all put on
that typespec. (uvm109's lesson — a pass that REMOVES objects must score
one-sided sets — is satisfied by construction here.)

---

## 6. Result

| row / mode | before | after |
|---|---|---|
| SimpleUVM / default | **17 cmp lines, 1 head** | **76 cmp lines, 1 head** |
| SimpleUVM / testflags | **17 cmp lines, 1 head** | **76 cmp lines, 1 head** |
| Scoreboard / default | **17 cmp lines, 1 head** | **76 cmp lines, 1 head** |
| SeqDriver x2 / MiniAmiq x2 / BuildUVMPkg x2 | 56 | 56 — the SAME head object (buvm34's scoped-foreach loop variable at `uvm_sequence_library.svh:496:44`), byte-identical except the arena `id:` numbers, which shift by exactly the count of objects this law removes (15 in SeqDriver / MiniAmiq, 12 in BuildUVMPkg) |
| Earlgrey_0_1 default / testflags | 32 / 36 | 32 / 36 (unchanged) |
| Rggen / default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) |

`HEAD_BEFORE_SimpleUVM_default.cmp` is **byte-identical to the master's
`/tmp/simpleuvm_head_9ac2763.cmp`**, so the pass measured the object the master
named. The line count went UP because the head OBJECT changed — a cmp line count
is the head's decompile DEPTH, never a distance. All three cleared rows land on
the SAME new head object (ids apart), which is R0 below.

The family is **CLOSED CORPUS-WIDE**: the operation-typespec census reports
`OURS-ONLY 0 / GOLDEN-ONLY 0` in all nine UVM databases after the patch (it was
7/7/7/13/13/7/7/13/13 ours-only and 0 golden-only before), and the corpus-wide
family count goes 87 cells in 9 databases -> **0 cells in 0 databases** over 956
surelog databases, with `0 -> 0` over 1358 uhdm2rtlil databases. The
`BOTH-SAME` and `MOVED-WRONG` populations are unchanged in every one of the nine,
so nothing that was right became wrong and no pre-existing residue moved.

---

## 7. Gates

All green — `GATES.r10uvm118.txt` has every number. In one line: both binaries
built `-j 2` and frozen `chmod 555` before any sweep, with the pristine one
rebuilding to the main tree's own md5 at `9ac2763`; **every `cmds.txt` audited by
binary PATH — 1523 of 1573 (surelog) and 1458 of 1462 (uhdm2rtlil) carry a
`slang:` line and every single one names the frozen patched binary, 0 name the
main-tree binary**; goldens 23/0 on BOTH binaries and 0/23 on `/bin/false`;
uhdm2rtlil **679/50/2 in both modes with 0 differing rows** against the committed
baseline AND against the control, byte movers **0/1358**; surelog **0 differing
rows over 1588** with status histograms identical to the control in both modes
(5-way default, 9-way testflags) — **no row converted and `results/*.csv` not
edited**, `GOLDEN_DEFER` unset; byte movers **9/956, exactly the nine databases
PREDICTED BY NAME from the pristine databases first**, every one attributed
order-blind with **ADDED=0**; 52 + 8 canary rows unchanged, both supplementary
canary suites PASS, `canaudit` audited=29 UNCOVERED=0 FENCE-BREACH=0 (the four
slang-fenced tests never dispatched and never named); all five protected
databases byte-identical with `SVSwitch 4842211c4030` and
`YosysVerx 6ccda350c24a` on their pins; the WIDE boundary over 3659 probe
sources x 2 views x 2 binaries is **DIFFERING=0** with an identical rc histogram
and a positive control that proves the gate can see (6 of 6 moved cells found,
and earl75's arm two directories deep IDENTICAL); and every other named row's
head is unchanged while three row-modes go 17 -> 76.

---

## 8. Residues and R0

**R0 — the next head, the SAME object in all three cleared row-modes
(SimpleUVM x2 + Scoreboard/default = 76 cmp lines, one head).**
`HEAD_AFTER_*.cmp`. `uvm_sequence_library.svh:778`:

```systemverilog
   `uvm_do_on_pri_with(seq_or_item, ..., { ... })      // seq_or_item.randomize() with {...}
```

a `hier_path` at 299:54 (macro span) under an operation at 299:53:

| | golden | ours |
|---|---|---|
| `hier_path` VpiName | **`seq_or_item`** (the trailing `.randomize` is NOT in the name) | `seq_or_item.randomize` |
| `ref_obj` VpiFullName | `uvm_pkg::uvm_sequence_library::execute::seq_or_item` | empty |
| `method_func_call` | **carries `vpiWith` -> `constraint` (`uvm_pkg::uvm_sequence_library::execute`)**, and NO span | no `vpiWith`; span 299:66-778:9 |

Three separate laws in one object: (a) an inline-constraint `randomize() with`
call is NOT a name component of the hier_path — golden's decompiled name stops
before it (the uvm89 / uvm92 closed-dispatch family, whose oracle
`r10uvm92repro/ct92cen.cpp` already links the real
`UHDM::ExprEval::prettyPrint`); (b) the `randomize` `method_func_call` must carry
a `constraint` under `vpiWith`, which we do not emit at all; (c) our
`method_func_call` span runs to `778:9` (the whole `with` block) where golden's
is span-less. Head it as ONE head object; (b) is almost certainly what the judge
reaches first once (a) is fixed, since `hier_path::Compare` reads `VpiName` (a
TEXT law) before it walks `Path_elems`.

**R1 — `string'(x)`'s cast TARGET typespec.** `g118_a2_operands.sv` rows W1/W2/W3
measure it on purpose-built golden: golden's written `string'(v)` carries a
**`string_typespec`** and ours an **`integer_typespec`**, in a module process, in
and out of a string concatenation. § stringCastKeepsStringTypespec26's arm is
gated on `effCastSyn->as<CastExpressionSyntax>().left->kind ==
syntax::SyntaxKind::StringType`, and this spelling does not reach it — the
`currentScope || castBindScope` arm above claims the row first and binds the
target as a SIZE expression. 3 MOVED-WRONG cells on the arm, unchanged by this
pass, invisible in the corpus today (no corpus database has a written
`string'(...)` in a comparable row). Cheap, self-contained, purpose-built golden
already written.

**R2 — the OTHER loc-less-logic cast family: a nested reinterpret.**
`uhdm2rtlil/static_cast_simple` `dut.sv:28-33`
`assign n4 = 9'(unsigned'(s1));` gives us **8** cast operations golden does not
have (ours 48 casts, golden 40), each a loc-less nameless `logic_typespec` whose
PARENT is another `vpiCastOp`. It is NOT this law's family (the target type is
integral, not `string`, so the `isString()` fence excludes it) and it did not
move. slang merges an inner `signed'`/`unsigned'` into the size conversion and
`wrapSignCast9` re-materialises it as a `$signed`/`$unsigned` sys_func_call —
but a second, syntax-less reinterpret conversion survives beside it. The row is
CMP_EQUAL today, so this is a byte residue, not a head.

**R3 — the pre-existing cast-typespec NAME population.** The `MOVED-WRONG` column
of the census (7 / 7 / 8 / 14 / 8 cells per UVM database, unchanged before and
after): golden names a `bit_typespec` `uvm_reg_data_t` / `uvm_reg_cvr_t` where we
name it `uvm_pkg::uvm_reg_data_t` / `uvm_pkg::uvm_reg_cvr_t`, and one golden
`enum_typespec uvm_pkg::uvm_severity` has an `unsupported_typespec uvm_severity`
alternate we never emit. A typedef-naming family, not a cast family; MEMORY's
"naming is context-dependent" dead-end applies, so it needs its own measured
split before anyone touches it.

**Instruments this pass leaves behind, reusable as-is:**
`ct118cen.cpp` (one row per `operation`, judge-visible payload, HOME/REGION/
MACRO/ROOT split, three keying traps documented in its header) is the census
reader for ANY operation-or-operation-typespec head; `join118.py` is a multiset
join with a configurable key; `pred118.sh` is the a-priori mover predictor
pattern — a *shape fingerprint* counted on PRISTINE databases only, which named
this pass's mover set exactly and refuted the one over-approximated candidate by
reading its source; `arm118.sh` scores an arm against Surelog in both views;
`vwide118.sh` is earl75's wide boundary with a positive control added.
