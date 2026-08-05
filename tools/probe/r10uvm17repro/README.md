# r10uvm17repro — UVM pass 17 purpose-built pairs

Run one with `tools/probe/r10uvm13run.sh <dir>` (needs `SLANG_UHDM` exported).
It writes `gd/ge` (golden def/elab) and `sd/se` (ours) plus `.txt` dumps into
the directory and prints both diff sizes.  Copy the directory somewhere
writable first — the runner drops artifacts next to `t.sv`.

| dir | what it pins | status |
|---|---|---|
| t27 | `super.<method>(...)` in statement and expression position: void function, int function on an assignment rhs, bit function in an `if` condition, task, no-argument call | § superMethodCall17 — **FIXED**, the call shape is byte-identical in both views |
| t28 | a package typedef whose packed RANGE BOUND is an EXPRESSION (a macro literal minus one, and a parameter minus one), bound at a free-function formal / local / return, a class-method formal / return, a wildcard-import clone, a module function and a module variable — seen from all six views | § pkgTdRangeViewFold17 — **DECODED, NOT FIXED** (see below) |
| t29 | an OUTPUT / INOUT / REF actual at a call site, statement position and `while` / `if` condition, plain and INDEXED | § outArgLvalue17 — **FIXED**, one binding-presence row left |

## The laws

### § cloneStmtHomeVarRef17 (`TypeEmit.cpp`, `TaskFuncEmit.cpp`, `UhdmExporter.h`, `UhdmExporter.cpp`)

Decoded but deferred by pass 16 (`cloneStmtHomeVarRef16`).  A wildcard-import
CLONE body's STATEMENT references split BY KIND: a reference to one of the
body's own FORMALS binds the clone's own `io_decl`, but a reference to a body
LOCAL binds the **ELABORATED HOME body's** variable object, whose typespec is
the qualified-aliased one.  From t26 (pass 16), `DEFPKG[p_imp]/free_fn`'s
`loc_b = fa;`:

```
golden lhs.act = #52  bit_var loc_b  ts #47 bt -> #11 p_decl::bt   (ELAB HOME)
golden rhs.act = #364 io_decl fa     ts #366 bt -> #368 bt         (own clone)
ours   lhs.act = #105 bit_var loc_b  ts #589 bt -> #588 bt         (own clone)
```

The counterpart is keyed by **(name, line, column)**: a clone's variable and
the home's come from the SAME declaration, so those three agree exactly, while
a name alone collides across shadowing blocks (`uvm_reg::do_check` declares
`acc` twice, once per foreach block).  Ambiguous keys bind nothing, and the
swap is refused when the two objects are not the same UHDM kind.

**Ordering is load-bearing.** The pass must run AFTER `pkgCloneHierBind9`, not
next to `importCloneBareTdAlias16` where it started: `pkgCloneHierBind9` fills a
hier_path BASE and a method-call PREFIX that golden binds only inside a clone,
and it necessarily binds the clone's own object.  Placed before it, exactly the
refs that were still null got re-bound to the clone afterwards — measured on
SeqDriver's `uvm_phase::execute_phase`, where `cs`/`top`/`state_chg` moved but
the `state_chg.m_phase = this` family did not.

Reach, on SeqDriver: 2254 clone-variable remappings, 5036 references rewritten.
It closes the class-method half of the census too — golden's clone binds
`ELABMOD[work@top_tb]/execute_phase`'s objects (i.e. the class_defn method's),
which is what `subMap[<method symbol>].tf` resolves to; free package
subroutines resolve through `pkgElabSubTf`.

Body residue: 19466 -> 19416.  Small, because uhdm-cmp compares VpiName and
kind, and a clone variable and its home twin differ only through the typespec
NAME one level down — i.e. only where LAW S / § importCloneBareTdAlias16 gave
them different names.  It is the correct model regardless, and it removes the
136-row direction flip pass 16 introduced.

### § superMethodCall17 (`ExprEmit.cpp`)

`super.<m>(args)` is a **method_func_call** named after the METHOD, located at
the METHOD TOKEN, whose `vpiPrefix` is an UNPARENTED STRING constant `super`
spanning the keyword — and it carries **no** `vpiFunction` / `vpiTask` link.
A TASK takes the same `method_func_call` shape; there is no `method_task_call`
in this arm.  Read off t27:

```
golden  method_func_call: (vf), line:30:13, endln:30:15
          vpiArgument   ref_obj a  (bound to the caller's own io_decl)
          vpiName       vf
          vpiPrefix     constant, line:30:7, endln:30:12
                          vpiDecompile super / vpiSize 5 / STRING:super
                          vpiConstType 6 (vpiStringConst)
ours    func_call: (vf), line:30:7, endln:30:18   + vpiFunction -> B::vf
```

Surelog reaches it through `compileTfCall`'s `paImplicit_class_handle` arm with
`rootName="super"` — the same arm § thisRecvCall11 decoded for `this`.  slang
binds the call straight to the BASE-CLASS `SubroutineSymbol` with a **null
`thisClass()`**, so the receiver survives only in the SYNTAX; that is why the
existing `call.thisClass()` branch (which already computes a `superRoot11`)
never saw these.  Detection matches EXACTLY `super.<id>`: the callee's
`ScopedNameSyntax` has a `Dot` separator, its left is a `SuperHandle` and its
right an `IdentifierName`.  A deeper `super.a.m()` is Surelog's four-way
rootName arm and is deliberately left alone.

The arguments are emitted under `ClassArgBind12` — a USER call's actuals bind
their actual even inside a class method, and the first cut of this arm dropped
that, losing the `vpiActual -> io_decl` on every super-call argument.

Measured: 19416 -> 18826 (-3.0%), all four tests moving.  On SeqDriver the
`method_func_call vs func_call` / `vs task_call` / `vs hier_path` block was
217 + 9 + 12 rows and is gone from the top of the ranking.

### § outArgLvalue17 (`ExprEmit.cpp`)

An OUTPUT / INOUT actual is not an assignment in the model, it is the bare
lvalue.  slang binds one as a SYNTHESIZED `AssignmentExpression` carrying the
copy-back (`left = <EmptyArgument>`), which the call-argument arm then rendered
as `operation(vpiAssignmentOp)` at the assignment's span.  Surelog lists the
written lvalue and nothing else.  t29, both directions of the shape:

```
golden  ref_obj 't' 29:23          ours  operation '' 29:23
golden  bit_select 'arr' 40:27     ours  operation '' 40:23
```

A `ref` formal never takes this form — slang passes the actual straight through
— so `q.byref(loc)` was already equal and nothing there changes.  The guard is
on the RIGHT being an `EmptyArgument`, which is the only thing that synthesized
copy-back can be, so a written embedded assignment (`f((i = 3))`) still takes
the `operation(82)` arm § the comment above it describes.

Measured: 18826 -> 18420 (-2.2%), all four tests moving.  On SeqDriver the
`Stmt | ref_obj vs operation` row was 624 and is gone from the top-22.

## Decoded, NOT fixed

### § pkgTdRangeViewFold17 — the `operation vs constant` family (~680 rows)

t28 reproduces it exactly and in BOTH directions, which is what makes it a
model rather than a residue:

| view | golden | ours |
|---|---|---|
| `DEFPKG[p28]` (home package DEF listing, its free fns and its `C::m` clones) | **operation** (`PW-1` symbolic) | constant 7 |
| `DEFPKG[q28]` (wildcard-import clone), `ELABPKG[*]`, `ELABPKG[*]::<class>`, `DEFMOD[]`, `ELABMOD[*]` | **constant** (7 / 63) | operation |

Exactly inverted, at the same site, for both bound shapes (a macro literal
minus one, `` `MW-1 ``, and a parameter minus one, `PW-1`).

The LISTING objects already agree: golden's and our `p28::pt` in the DEF
package are both SYMBOLIC, and both elaborated listings are FOLDED.  What
differs is the **per-declaration named clone** — the one at the formal's type
token (`pt@16:29`) that carries a `Typedef_alias` back to the listing.  Golden
mints one per view and it shares its own view's listing range:

```
golden DEFPKG[p28]  free28 io1 = #143 pt@16:29 -> #123 p28::pt   (#143 symbolic)
golden ELABPKG[p28] free28 io1 = #59  pt@16:29 -> #43  p28::pt   (#59  folded)
ours   DEFPKG[p28]  free28 io1 = #35  pt@16:29 -> #15  p28::pt   (#35  FOLDED)
ours   ELABPKG[p28] free28 io1 = #134 pt@16:29 -> #15  p28::pt   (#134 SYMBOLIC)
```

Two things are wrong and both live at `TaskFuncEmit.cpp` ~2110 (the typedef'd-
formal arm) and its variable/return siblings: the clone is built by
`makeTypespec` from the SYNTAX — so its fold state follows `makeTypespec`'s
context, not the listing — and `mainTs = typedefTs[&at]` hands BOTH views the
DEF listing, where golden's elab clone aliases the ELABORATED one.  A fix has
to do both halves (range FROM the view's own listing, alias TO it); doing only
the range half would be a guess against the view discriminator the pair just
established, and the arm is shared with every non-UVM corpus member, so it was
left for pass 18 with the pair in hand.

## Tools

* `r10uvm17a.cpp` — package/class `Task_funcs` listing (`list` mode) and a
  per-reference OWNER census (`refs` / `refid`): for every `ref_obj`, which
  body it sits in and which body its `Actual_group` belongs to.  This is the
  instrument § cloneStmtHomeVarRef17 was read off and the one that showed the
  pass had to run after `pkgCloneHierBind9`.
* `r10uvm17m.sh` / `r10uvm17p.sh` / `r10uvm17rank.sh` — the pass-16 measuring
  set re-pointed at this worktree (`R10B` defaults to `/tmp/r10uvm17_b`, the
  `r10uvm7b` build; pass `R10B=/tmp/r10uvm17_c` for the `r10uvm16c` drill).

Build the probes with:

    g++ -O2 -std=c++20 -I$HOME/.local/include -o /tmp/r10uvm17_a \
        tools/probe/r10uvm17a.cpp -L$HOME/.local/lib64 \
        -luhdm -lcapnp -lkj -lpthread

## Measured (UVM-4, default mode, body residue via `r10uvm7b`)

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM | TOTAL |
|---|---|---|---|---|---|
| HEAD d8c370f | 3564 | 3486 | 7302 | 5114 | 19466 |
| § cloneStmtHomeVarRef17 | 3564 | 3486 | 7252 | 5114 | 19416 |
| + § superMethodCall17 | 3469 | 3365 | 7043 | 4949 | 18826 |
| + § outArgLvalue17 | 3398 | 3290 | 6902 | 4830 | 18420 |

-5.4% overall.  Goldens 23/23, u2r testflags (732 rows) and Surelog both-modes
(1588 rows) byte-identical to the committed baselines at every step.

## Ranked residue for pass 18 (UVM-4 `whycls`, after this pass)

| n | pair | first differing property |
|---|---|---|
| 880 + 749 | `Stmt` io_decl vs `<null>` / `<null>` vs io_decl | presence, BOTH directions — still the pass-16 which-object question; needs the `r10uvm17a refid` drill widened to io_decls |
| 678 | `Stmt` logic_net vs `<null>` | presence — golden binds a `logic_net 'this'@902:36` inside ELAB class methods |
| 604 + 357 + 347 + 346 | operation vs constant, all four slots | § pkgTdRangeViewFold17 above — **DECODED**, t28 in hand |
| 604 + 600 + 366 | `Stmt` / `Variables` package or function vs `<null>` | presence |
| 567 + 392 | `<null>` vs class_typespec | presence |
| 491 + 448 + 428 | `<null>` vs class_var / string_var / ref_obj | presence |
| 460 + 319 | class_typespec vs class_typespec | VpiName — both directions (`uvm_pkg::uvm_event_pool` vs anonymous, `adpcm_pkg::this_type` vs `this_type`) |
| 459 | `Io_decls` `<null>` vs ref_obj | presence |
| 387 / 330 | `Stmts` / `Io_decls` SIZE | |
| 365 | `Stmt` constant vs constant | |
| 335 | `Stmt` class_var vs int_var | VpiType |
