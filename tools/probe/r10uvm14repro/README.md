# r10uvm14repro — UVM pass 14 purpose-built pairs

Run one with `tools/probe/r10uvm13run.sh <dir>` (needs `SLANG_UHDM` exported).
It writes `gd/ge` (golden def/elab) and `sd/se` (ours) plus `.txt` dumps into
the directory and prints both diff sizes.

Pass 13's `r10uvm13repro/t17` is the first member of this family and is
re-used unchanged.

| dir | what it pins | status |
|---|---|---|
| t17 (pass 13) | `imp.method(arg);` / `return imp.method(arg);` on a handle whose type is an unspecialized type PARAMETER | § droppedCall14 lands shapes A/B/C/D/F byte-identical in BOTH views; shape E (`r = m_imp.f(1,2)`, LITERAL actuals) is the residue |
| t18 | the `UVM_MS_IMP_COMMON` shape: `if (req_imp == null) $cast(req_imp, imp);` — a CONDITION comparing an unspecialized type parameter against `null`, plus if+assignment / if+return / if+block / else arms | § invalidChild14 lands ALL of them; the whole remaining t18 diff is the int_typespec cluster (naming + set + order), which is not this pass |
| t19 | the `uvm_pair` shapes: `first = new;` on a type-param property, a dotted call inside a `$sformat` ARGUMENT, two dotted calls under `&&`, and a dotted ACTUAL (`first.copy(rhs_.first)`) | the three dotted-call shapes land; `first = new;` does NOT (golden: `assignment{Lhs=hier_path(first), Rhs=method_func_call(new) loc-less}`) |

## The model (§ droppedCall14 / § invalidChild14)

slang type-checks the DEFAULT specialization of a generic class, so
`class impc #(type IMP = int); IMP m_imp; ... m_imp.put(a);` binds `m_imp` as
`int`, finds no member `put`, and returns a bad statement.  The reference tool
does no such check at this level.  Two independent recoveries:

* **`InvalidStatement::child` / `InvalidExpression::child`** — a COMPOUND node
  is bad when any of its parts is, and slang hands back the partially built
  node (`badStmt(comp, result)`), populated apart from the bad part.  Simply
  re-entering `emitStmt` on the child recovers the whole if/else, its
  condition operands and its branches.  `emitExpr` already did this for
  expressions.
* **Syntax re-entry** — a call whose member LOOKUP failed has no partial node
  at all, and `Expression::create` deliberately does not set `syntax` on an
  `InvocationExpression`, so neither the Invalid node nor its child can name
  the call.  The only route back is the enclosing STATEMENT's syntax: find the
  invocation whose callee starts exactly where the surviving receiver does
  (`findDroppedCallAt14`).

Emitted shapes, all measured (t17 + t19):

| position | shape |
|---|---|
| STATEMENT (`m_imp.put(arg);`) | `method_func_call` named after the METHOD, spanned at the method identifier; `vpiPrefix` = an UNBOUND `ref_obj` for the receiver with the prefix-joined fullname; actuals under the PLAIN prefix, and a plain-identifier actual BINDS its io_decl |
| EXPRESSION (`return m_imp.try_put(arg);`) | `hier_path` named `<recv>.<method>` spanning the WHOLE call, over a name-only `ref_obj` and a `method_func_call`; the path opens a NAME SCOPE — every actual is UNBOUND and its fullname nests under `<prefix>::<recv>.<method>` |
| DOTTED actual (`first.copy(rhs_.first)`) | a `hier_path` over two `ref_obj`s; the BASE stays name-only, the LEAF alone carries the scoped fullname (same `argPfx` as above) |

## Measured (UVM-4, default mode, body residue via `r10uvm7b`)

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM | TOTAL | `Stmts SIZE` |
|---|---|---|---|---|---|---|
| HEAD 505a625 | 4113 | 4588 | 10292 | 6995 | 25988 | 498 |
| § droppedCall14 only | 4027 | 4500 | 10205 | 6907 | 25639 | 474 |
| + § invalidChild14 | 4051 | 4521 | 10226 | 6928 | 25726 | 387 |

`invalidChild14` costs +87 on the pair-count proxy while cutting the
`Stmts` SIZE gap by 22%: it does not make anything wrong, it POPULATES
statement lists that were empty, so pre-existing shape gaps inside those
statements start being counted.  Ranked residue it exposed (SeqDriver, vs
`droppedCall14` alone): `int_typespec vs int_typespec` +12 (golden names the
int_typespec after the type-parameter ALIAS — `this_rsp_type` — where we emit
it unnamed), `method_func_call vs <null>` +10 (`super.new(...)` with a
type-param-typed actual, and `prop = new;`), `io_decl vs <null>` +4,
`class_typespec` naming +2.
