# r10uvm28 — UVM pass 28

Pass 27's ranked **#1** was `class_var uvm_default_table_printer`, read off the
design-level head; the per-element localizer said 1143 Scoreboard package
listing elements were failing and put 269 of them on a single object, `string_var
'v' 79:12`. That object turned out not to be half of a mismatched pair at all.
**`CompareContext` records `m_failedLhs` and `m_failedRhs` INDEPENDENTLY**
(`BaseClass.h`:187-199): a scalar POINTER that is null on one side sets only
ONE of them, and `r10uvm27l` printed the compared element in place of the unset
side, so "golden `function`, ours `string_var 'v'`" actually meant *golden had
`nullptr` here and we have an extra pointer to `v`*. The pointer is
`ref_obj::Actual_group` — **reference binding**, a field no shape census this
campaign has ever projected and one `uhdm-cmp` descends into.

| metric | HEAD f764866 | this pass |
|---|---|---|
| `r10uvm28m.sh` differing binding keys, UVM-4 (`BINDTOTAL`) | **11082** | **5910** (-47%) |
| — of which EXTRA (we bind, golden bare) | 5892 | 1979 |
| — of which MISSING (golden binds, we bare) | 5190 | 3931 |
| `r10uvm27m.sh` CTORTOTAL | 0 | **0** (held) |
| `r10uvm26m.sh` VARTOTAL | 0 | **0** (held) |
| `r10uvm23m.sh` class listings | 36 | **36** (held) |
| `r10uvm27l` failing package-listing elements, Scoreboard | 1143 | 1142 |

**0 movers**: all 7 UVM-4 rows stay `CMP_NOTEQUAL`. Master gates on the final
tree: goldens **23/23**; u2r testflags (732 rows) and Surelog both-modes (1589
rows) **byte-identical** to the committed baselines (`diff | wc -l` = 0 each,
dump column included).

Build every probe with the **STATIC** UHDM libs:

    g++ -std=c++20 -O2 tools/probe/r10uvm28g.cpp -o /tmp/r10uvm28g \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SLANG_UHDM=<build> R10G=/tmp/r10uvm28g \
      tools/probe/r10uvm28run.sh tools/probe/r10uvm28repro/t38a
    R10G=/tmp/r10uvm28g tools/probe/r10uvm28m.sh <sweep workdir>   # the metric

---

## 0. The probes this pass added

* **`r10uvm28a`** — `r10uvm27l` with the asymmetry made visible: prints
  `<null>` for the unset side and the **vpiParent chain** of the set one.
  Re-reading pass 27's own residue through it splits 1143 elements into 524
  "extra pointer on our side", 393 "missing pointer" and 226 real pairs — a
  partition the old localizer could not express. **Use this, not `r10uvm27l`.**
* **`r10uvm28e`** — CUT-BISECTION. `CompareContext` never records the object
  that HELD the differing member, and vpiParent does not answer it (the holder
  of a pointer is usually not the pointee's parent). `m_visited` is keyed on
  the LHS and short-circuits a subtree, so cutting the OWNER — or any ancestor
  — clears the failure and cutting anything else does not: walk golden's
  subtree, cut one object at a time, and the DEEPEST clearing cut is the owner.
  This is what named `ref_obj 'v' 84:10` in four seconds.
* **`r10uvm28f`** — the per-task_func reference-binding census (kind, name,
  line:col, `Actual_group`), for reading one routine.
* **`r10uvm28g`** — the GLOBAL binding census and the pass's metric input. Two
  design decisions matter: every task_func is tagged with the **view** it was
  reached from (the two package views hold different objects for the same
  routine and Surelog binds them differently — keying by name alone merges them
  and makes the law unreadable), and each row carries the three enclosing
  object kinds with `operation` op-types, because the rule is positional.
* **`r10uvm28d`** — the subtree dump. Kept, but note `visit_object` on a UVM
  task_func recurses through typespecs into the whole design and prints ~1.1M
  lines; `r10uvm28f`/`g` are the usable projections.

The 2x2 that drove the pass (`ELABPKG`, golden vs ours, by target kind) put
**399 constructor `io_decl` references** in a single cell — the largest — and
scattered the rest of the ordinary-method residue across both directions.

---

## 1. `§ superNewFormalBinds28`

> An argument of `super.new(...)` that names one of the constructor's own
> FORMALS binds to that io_decl. An argument naming a body LOCAL or a class
> PROPERTY stays bare.

This is **not** § classArgBind12: an ordinary call in the same constructor binds
formals *and* locals (t38a `mm(lb)` → `int_var:lb`), `super.new` binds formals
alone. Measured on t38b, which feeds `super.new` each operand class in turn:

| cell | golden |
|---|---|
| `super.new(a, s)`, `a`/`s` formals | `io_decl:a`, `io_decl:s` |
| `super.new(lb, "z")`, `lb` a bare local | bare |
| `super.new(p, "z")`, `p` a class property | bare |
| `super.new(a + 1, "z")` | binds THROUGH the operation |
| `super.bm(a)` (ordinary super method) | binds (already ours) |
| port-less ctor, out-of-body ctor | same as their twins |

Code: a `SuperNewArg28` counter raised over the `NewClassExpression` argument
loop, read in the ref gate as a symbol-KIND test (`FormalArgument`) rather than
as another arg-bind depth.

## 2. `§ controlBodyNoBind28`

> An IN-BODY class method's binding windows — the if/case CONDITION carve-out
> and § classArgBind12's call arguments — are **top-level only**. Inside the
> BODY of a conditional or loop statement nothing binds. A plain `begin`/`end`
> block is transparent.

t38c repeats one condition and one call argument at each nesting depth:
`top` binds (both sides agree), `in_begin` binds, and `in_for`, `in_while`,
`in_if` and `in_foreach` bind **nothing** in golden while we bound all of them.
`uvm_scope_stack::get`'s `if (v != "" && …)` — the 269-element head — is
exactly the `in_for` cell.

**The first cut of this law was REFUTED by its own gate** and the refutation is
the useful part. Suppressing on `curSubClassScope9` alone took `BINDTOTAL` from
9480 to **45827**: golden binds heavily inside control bodies in the UVM
(`uvm_component::lookup`'s `comp = top;` inside an `if`), and every such method
is defined **OUT OF BODY**, where Surelog compiles in the home package's scope
and binds everywhere (`curSubOob9`, already modelled). t38d — assignments at
each depth, the cell t38c omitted — confirms an in-body method binds nothing in
an assignment at any depth. The guard is therefore
`curSubClassScope9 && !curSubOob9 && ctrlBodyDepth28 > 0`, and t38b's
`s_oob::new` (binds `p = a`) was carrying that discriminator in plain sight one
arm earlier.

Code: a `CtrlBody28` counter raised in `StmtEmit.cpp` at exactly the seven
places a control statement takes a substatement (if/else arms, for, foreach,
while, do-while, repeat, forever, case items) and nowhere else.

## 3. `§ builtinMethodArgBinds28`

> A BUILT-IN method call's arguments are an ordinary § classArgBind12 window.

`m_stack.push_back(s)` binds `s` to the method's io_decl and a body local to its
var; the RECEIVER (`m_stack`) and a class PROPERTY stay bare, `$display`'s
arguments never bind, and inside a control body law 2 still wins. All five cells
plus the out-of-body control are t38e. § classArgBind12 opened its window on the
user-subroutine arms only and a queue/array/string built-in takes a different
emission arm. After laws 1-2 this was the Scoreboard/SimpleUVM head
(`uvm_scope_stack::set`, 269 elements).

---

## RANKED for pass 29

Measured with `r10uvm28a` on Scoreboard after this pass (1142 elements) and
`r10uvm28m.sh` (`BINDTOTAL` 5910):

1. **`class_var` inline initializers — 240+28+26 elements, the new head.**
   Golden's `class_var 'scope' 256:19` (`uvm_status_container`) carries a
   `method_func_call 'new'` where ours carries nothing: a class PROPERTY
   declared `= new()` keeps its constructor call as the variable's `vpiExpr`.
   Same shape on `uvm_packer::scope`, `uvm_printer::knobs`. Not a binding
   question — census `variables::Expr` across the class listings first.
2. **`ref_obj 'uvm_callbacks::m_register_pair' 60:49` — 166 elements** over
   `bit_var m_register_cb_*` (the `uvm_register_cb` macro expansion): golden
   binds the qualified name, we leave it null. Related to the pass-17 note that
   a `::`-qualified spelling inside a class method renders as something other
   than a named func_call — decode where that spelling goes.
3. **The remaining binding residue, 5910 keys** (`extra` 1979 / `miss` 3931),
   now measurable per cell with `r10uvm28g` + the 2x2. SeqDriver alone holds
   3171 misses against ~200 for each other test — census SeqDriver's own tree
   (its `adpcm_pkg` Instance-stamp head, pass 27's #2, may be the same object).
   Largest named cells left: `method_func_call/function/class_defn` 57 (a
   single-statement method body), `operation#15/begin/if_stmt` 10.
4. **`class_typespec` EXTRAS — 67+47+39 elements**, all
   `class_var <parameterised-pool>` properties (`uvm_object_string_pool`,
   `uvm_set_before_get_dap`): golden has NO typespec pointer where we have one.
   Same family as pass 27's #3 (`uvm_id_verbosities_array`, still the largest
   real pair at 94).
5. Unchanged: BuildUVMPkg's `tf 2` remainder and the `var 34` class-listing
   remainder (`r10uvm23m` = 36), the `t36b` net-vs-var residue (2 objects),
   `t33d`'s extern-prototype listing entry, hier_path root-degradation.

**Method note for the next pass.** Two of this pass's three laws were found by
projecting a field nothing had projected before, and the third by taking a gate
REGRESSION seriously instead of tuning around it. When a localizer reports a
pair, check which side the tool actually set before believing it is a pair.
