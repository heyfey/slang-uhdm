# r10uvm16repro — UVM pass 16 purpose-built pairs

Run one with `tools/probe/r10uvm13run.sh <dir>` (needs `SLANG_UHDM` exported).
It writes `gd/ge` (golden def/elab) and `sd/se` (ours) plus `.txt` dumps into
the directory and prints both diff sizes.  Copy the directory somewhere
writable first — the runner drops artifacts next to `t.sv`.

| dir | what it pins | status |
|---|---|---|
| t26 | a package's scalar typedefs (`bit`/`logic`/`int`) at every variable-like site — free-function formal / local / return, task formal, class property, class-method formal / local, package variable, module variable and net — seen from the DECLARING package AND from a package that `import`s it wildcard | § importCloneBareTdAlias16 lands the io_decl and Variables halves in both views; the STATEMENT half is decoded and **not** fixed (see § cloneStmtHomeVarRef16 below) |

## The laws

### § importCloneBareTdAlias16 (`TypeEmit.cpp`, `UhdmExporter.h`, `TaskFuncEmit.cpp`)

LAW S (committed) gives every variable-like binding of a package SCALAR typedef
a BARE per-declaration copy whose `Typedef_alias` points back at the QUALIFIED
listing object `p::t`.  That is the HOME body's shape.  Inside a **wildcard-
import CLONE** body the alias target is bare as well.

The reason is Surelog's, and it is not a special case: `UhdmWriter::
writeDataTypes` (`UhdmWriter.cpp:791`) prefixes a typespec with `<pkg>::` only
while walking a package's own `datatypeMap`, mutating the object in place and
skipping anything that already contains `::`.  A clone's whole chain is
re-minted against the IMPORTING package, so no object in it is ever the one
that got prefixed.

Read out of both sides of t26 with `r10uvm16b` (io_decl / variable typespec
plus its alias chain):

```
golden DEFPKG[p_decl]/free_fn   io0 = #122 bt -> #104 p_decl::bt   (home)
golden DEFPKG[p_imp]/free_fn    io0 = #366 bt -> #368 bt           (clone)
golden ELABPKG[p_decl]/free_fn  io0 = #29  bt -> #11  p_decl::bt
golden ELABPKG[p_imp]/free_fn   io0 = #194 bt -> #196 bt
ours   (before)                 io0 = #568 bt -> #75  p_decl::bt   at all four
```

We bound the qualified object at all four because LAW S's per-listing-object
memo hands the SAME bare copy to the home body and the clone; uhdm-cmp does not
compare identity but it does compare `VpiName` one level down through
`Typedef_alias`, so the clone needs its own object.  `bareScalarTdCopyOf` was
split so the mint step (`bareScalarTdCopyOfFresh16`) can be reused unmemoized.

Measured on the UVM-4: SeqDriver 8349 -> 7933 body residue.  It is the only one
of the four with a `package ... ; import uvm_pkg::*;` — the other three import
at module scope and do not move.  On the SeqDriver naming census the
`golden BARE / ours QUALIFIED` direction goes 623 -> 86 rows.

### § writtenCallArgs16 (`EmitHelpers.h`, `ExprEmit.cpp`)

slang materialises a DEFAULTED formal as a full argument expression, located at
the declaration's default; Surelog lists only the actuals WRITTEN at the call
site.  The `func_call` / `task_call` path has carried this rule since the
ApbSlave probe (`write(addr, data)` is two arguments, not five) — the eight
METHOD-call argument loops in `ExprEmit` did not.

This is the whole of the pass-15 head row `method_func_call vs
method_func_call | deeper` (1511 pairs on SeqDriver).  `deeper` was where the
projection stopped, so pass 16 extended the instrument first: `r10uvm16c`'s
`callSlot` drills a call's Prefix, its resolved callee and its Arguments
vector.  The 1511 then split as

| n | slot |
|---|---|
| 385 | `Args/SIZE 1 vs 2` |
| 249 | `Args/SIZE 2 vs 3` |
| 186 | `Args/SIZE 4 vs 5` |
| 158 | `Args/SIZE 2 vs 4` |
| 92 | `Args/SIZE 1 vs 4` |

— every one of them GOLDEN SHORTER.  Source check: `uvm_printer::print_object(
string name, uvm_object value, byte scope_separator=".")` called as
`print_object("", this)`; `print_time`, `print_generic`,
`uvm_component::set_domain(uvm_domain domain, int hier=1)`,
`find_by_name`.  Read the INVOCATION SYNTAX, which is the only place the
distinction survives; a call with no invocation syntax falls back to the bound
count so the helper can never trim a real argument.  Applies only where
`arguments()` excludes the receiver: a BUILT-IN method passes its receiver as
`arguments()[0]`, so those two sites keep counting the bound list.

Measured: UVM-4 total 21461 -> 19873 (-7.4%), all four tests moving.

### § writtenCallArgs16 — the constructor arm (`ExprEmit.cpp`, NewClass)

A `new(...)` carries its actual list on `NewClassExpressionSyntax::argList`,
not on an `InvocationExpressionSyntax`, so the shared helper cannot read it.
The residual `Args/SIZE 2 vs 3` block after the method fix was ENTIRELY `new`
calls (`uvm_domain::new(name)` against `uvm_phase::new(name, phase_type=
UVM_PHASE_SCHEDULE, parent=null)`), all reported at 0:0 because the node is
synthesized.  Counted from the new-expression's own syntax.

Measured: 19873 -> 19466 (-2.0%).  Residual Args/SIZE across the UVM-4: 125.

## Decoded, NOT fixed

### § cloneStmtHomeVarRef16

In golden, a wildcard-import clone body's STATEMENT references split by kind:
a reference to one of the body's own FORMALS binds the clone's own `io_decl`,
but a reference to a body LOCAL binds the **elaborated HOME body's** variable
object, whose typespec is the qualified-aliased one.  From t26,
`DEFPKG[p_imp]/free_fn`'s `loc_b = fa;`:

```
golden lhs.act = #52  bit_var loc_b  ts #47 bt -> #11 p_decl::bt   (ELAB HOME)
golden rhs.act = #364 io_decl fa     ts #366 bt -> #368 bt         (own clone)
ours   lhs.act = #105 bit_var loc_b  ts #589 bt -> #588 bt         (own clone)
```

So landing § importCloneBareTdAlias16 moves the clone's Stmt rows from
`golden BARE / ours QUALIFIED` to `golden QUALIFIED / ours BARE` — the census
direction flips 102 -> 156 while the other direction falls 623 -> 86, a net
725 -> 242 on SeqDriver.  Fixing it means rebinding a clone body's local refs
across bodies (the `pkgCloneHierBind9` machinery's inverse) and was left for a
later pass; it is worth ~150 rows.

### The other-direction naming rows that are NOT this

`uvm_hdl_data_t` appears in BOTH census directions (16 `golden QUALIFIED /
ours BARE` at `uvm_hdl_deposit`-family FORMALS in the HOME views, 7 the other
way), which is what killed the "per-typedef shape" reading — the discriminator
is the SITE, not the typedef.  The 16 home-view rows are a separate residue.

## Tools

* `r10uvm16a.cpp` — census of typespec OBJECTS by name substring: id, kind,
  name, line:col, parent, `vpiInstance`, and which package/module `Typespecs()`
  vectors list it.  This is what showed golden carries exactly ONE qualified
  `uvm_pkg::uvm_reg_addr_t` and ~50 bare siblings.
* `r10uvm16b.cpp` — per-package `Task_funcs` io_decl / variable typespec
  IDENTITY plus the `Typedef_alias` chain, plus each assignment's Lhs/Rhs
  `Actual_group`.  The instrument both laws above were read off.
* `r10uvm16c.cpp` — `r10uvm15c` plus `callSlot`: splits a call-vs-call
  `deeper` into `Prefix/…`, `Callee/…`, `Args/SIZE n vs m`, `Arg/…`.
* `r10uvm16m.sh` / `r10uvm16p.sh` / `r10uvm16rank.sh` / `r10uvm16g.sh` /
  `r10uvm16acen.sh` — the measuring set, re-pointed at this worktree and at
  `/tmp/r10uvm16_u4w`.

Build the probes with:

    g++ -O2 -std=c++20 -I$HOME/.local/include -o /tmp/r10uvm16_c \
        tools/probe/r10uvm16c.cpp -L$HOME/.local/lib64 \
        -luhdm -lcapnp -lkj -lpthread

## Measured (UVM-4, default mode, body residue via `r10uvm7b`)

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM | TOTAL |
|---|---|---|---|---|---|
| HEAD 418f7fd | 3955 | 3890 | 8349 | 5683 | 21877 |
| § importCloneBareTdAlias16 | 3955 | 3890 | 7933 | 5683 | 21461 |
| + § writtenCallArgs16 | 3674 | 3581 | 7406 | 5212 | 19873 |
| + the constructor arm | 3564 | 3486 | 7302 | 5114 | 19466 |

-11.0% overall.  Goldens 23/23, u2r testflags and Surelog both-modes status
columns byte-identical to the committed baselines at every step.

## Ranked residue for pass 17 (UVM-4 `whycls`, after this pass)

| n | pair | first differing property |
|---|---|---|
| 880 + 742 | `Stmt` io_decl vs `<null>` / `<null>` vs io_decl | presence — 196 + 183 of them in ELABPKG[uvm_pkg] CLASS methods alone, i.e. BOTH directions in ONE view: a which-object question, not bind-vs-no-bind. Needs an actual-identity drill (`r10uvm16b`'s `.act` column extended to whole bodies) |
| 678 | `Stmt` logic_net vs `<null>` | presence |
| 614 | `Stmt` ref_obj vs operation | VpiType |
| 613 | `Stmt` mfc vs func_call | VpiType — the call-KIND half the arg fix does not touch |
| 603 + 600 | `Stmt` package / function vs `<null>` | presence |
| 567 + 392 | `<null>` vs class_typespec | presence |
| 540 + 357 + 347 + 317 | operation vs constant, both ways | VpiType — t24 (pass 15) says a typespec-POINTER choice |
| 460 + 319 | class_typespec vs class_typespec | VpiName |
| 459 + 424 | `<null>` vs ref_obj | presence |
| 449 + 448 | `<null>` vs class_var / string_var | presence |
| 387 / 330 | `Stmts` / `Io_decls` SIZE | |
| 335 | class_var vs int_var | VpiType |
| 125 | mfc Args/SIZE | the § writtenCallArgs16 remainder |
