# r10uvm27 — UVM pass 27

Pass 26's ranked **#1** (`uvm_tree_printer::new`'s `begin` body residue) turned
out to be the visible corner of a whole compilation path we had never modelled:
Surelog compiles a class CONSTRUCTOR with
`CompileHelper::compileClassConstructorDeclaration` (`CompileStmt.cpp`:2165),
a routine that shares **no code** with `compileFunction`/`compileTask` and
differs from them in three measurable ways. All three are decoded, purpose-built
and implemented, and the **entire constructor-body residue of the UVM-4 — every
view, every package, clones included — is now byte-identical to golden.** A
fourth law came out of the head that surfaced behind them.

| metric | HEAD 1b1e853 | this pass |
|---|---|---|
| `r10uvm27m.sh` constructor rows (`::new`, all views, all 4 tests) | **142** | **0** |
| `r10uvm26m.sh` package-variable listings (pass 26's metric) | 0 | **0** (held) |
| `r10uvm23m.sh` class listings (pass 23's metric) | 36 | 36 (untouched) |
| `r10uvm27l` failing package-listing elements, Scoreboard | 1145 | 1143 |

**0 movers**: all 7 UVM-4 rows stay `CMP_NOTEQUAL`. Gate on the final tree:
goldens **23/23 PASS**; u2r testflags (732 rows) and Surelog both-modes (1589
rows) **byte-identical** to the committed baselines (`diff | wc -l` = 0 each,
dump column included), so SLANG_REJECT membership, every canary and every
`dump=match` are unchanged.

Build the probes with the **STATIC** UHDM libs (a shared `-luhdm` restores
Surelog's `.uhdm` with NULL vector contents and every census silently measures
nothing):

    g++ -std=c++20 -O2 tools/probe/r10uvm27s.cpp -o /tmp/r10uvm27s \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SLANG_UHDM=<build> tools/probe/r10uvm27run.sh tools/probe/r10uvm27repro/t37b
    R10S=/tmp/r10uvm27s tools/probe/r10uvm27m.sh <sweep workdir>   # the metric

---

## 0. The probes this pass added

* **`r10uvm27s`** — the task_func **body-SHAPE** census: for every task_func
  reachable from `AllPackages`/`TopPackages`/`AllClasses` (and every
  `class_defn`'s `Task_funcs`), one line giving the `Stmt` kind and, when it is
  a `begin`, the ordered kinds+names of its `Stmts`. This is the projection
  that makes the constructor laws readable without an 11 MB dump; every table
  below is a `diff` of two of its outputs.
* **`r10uvm27cv`** — the class-PROPERTY field census (`vpiConstantVariable`,
  `vpiAutomatic`, `vpiVisibility`, typespec kind, expr kind).
* **`r10uvm27l`** — the **package-listing localizer**, and the methodological
  point of this pass. `uhdm-cmp` reports ONE first-failing pair for the whole
  design, and its `CompareContext` marks objects visited, so **clearing an
  early failure can make a later one surface as if it were a regression**:
  Scoreboard's head went from `begin uvm_tree_printer::new` (pass 26) to
  `class_var uvm_default_table_printer` — pass 25's head spelling — even though
  nothing regressed. `r10uvm27l` compares each package listing ELEMENT BY
  ELEMENT with a fresh context (packages/designs/modules cut-seeded so
  `Instance()` recursion is a no-op) and prints the whole failing set, so the
  question is answerable: 1145 → 1143 elements, the two constructor rows gone
  and one `uvm_root::new` row replaced by a deeper pre-existing pair. **Do not
  read the design-level head as a per-pass metric without this cross-check.**
  `--why` adds the cmp-relevant scalar fields to each printed pair.

---

## 1. `§ constructorBodyElementShift27`

> A constructor that declares **no port list** loses its FIRST BODY ELEMENT,
> whatever that element is.

`compileClassConstructorDeclaration` reads `Tf_port_list = fC->Child(nodeId)`
(after stepping over a `class_scope` for an out-of-body definition) and only
*afterwards* works out where the statements begin. With no port list there is
no `tf_port_list` node, so what it grabs is the first body element, and the walk
it then runs (`Stmt = fC->Sibling(Tf_port_list)`, :2274) starts one element
late. Over the raw grammar element sequence

    { block_item_declaration } [ super.new [ list_of_arguments ] ]
    { function_statement_or_null }

— the argument list is its **own** element, present whenever the source wrote
the parentheses, `()` included —

    firstCounted = portList ? 0 : (elem[0] is a plain statement ? 0 : 1)
    nb           = number of NON-argument-list elements from firstCounted
    nb == 0  -> NO body statement
    nb == 1  -> the ONE element at firstCounted, emitted BARE (no begin)
    nb >  1  -> a `begin` over every element from index (portList ? 0 : 1)

and the `begin` gets **no span at all** (`populateCoreMembers` is never called
on it), only `vpiFullName`.

Measured, all in both package views (t37b/t37c/t37d, `-` = no port list):

| body | golden |
|---|---|
| `-` `a=1;` | bare `assignment` |
| `-` `a=1; c=2; d=3;` | `begin[a a]` — **first statement dropped** |
| `-` `super.new();` | **nothing** |
| `-` `super.new(); a=1;` | **nothing** (the walk lands on the argument list) |
| `-` `super.new; a=1;` | bare `assignment` (no parens = no ARGS element) |
| `-` `super.new(); a=1; c=2; d=3;` | `begin[a a a]` — super.new dropped |
| `-` `super.new(5); a=1; c=2; d=3;` | `begin[a a a]` |
| `-` `super.new(); begin a=1; c=2; end` | **nothing** |
| `-` `int t; super.new(); a=1; c=2;` | `begin[super.new a a]` — super.new **kept** |
| `-` `int t; a=1;` | bare `assignment` |
| `-` `int t; int u; a=1;` | `begin[u a]` (see law 2) |
| `-` `begin a=1; c=2; end` | that `begin` |
| `(int k)` `super.new(k); a=1; c=2; d=3;` | `begin[super.new a a a]` — unchanged |
| `(int k)` `a=1; c=2; d=3;` | `begin[a a a]` — unchanged |

`function new;` behaves exactly like `function new()`; both out-of-body arms
(`function C::new(); ...`) behave exactly like their in-body twins. This is
what `uvm_tree_printer::new` (`super.new(); knobs.size=0; ... x4`) is: golden's
`begin` holds the four assignments and no `super.new`, with no span.

## 2. `§ ctorDeclIsRhslessAssignment27`

> Inside a CONSTRUCTOR body, every surviving block-item declaration is a body
> STATEMENT: an `assignment` whose Lhs is the declared variable, with an Rhs
> only when the declaration has an initializer.

`compileFunction`/`compileTask` filter exactly that Rhs-less assignment back out
(`CompileStmt.cpp` ~2130: `if (stmt->Rhs() != nullptr) task->Stmt(st); else …`);
the constructor routine has no such filter. Measured on t37e for `int`,
`string` and unpacked-array locals (the array one lists its element reg before
the `array_var`, as the ordinary block wrapper does), with ordinary
function/task controls in the same file keeping the filtered shape.

This one is **independent of the port list** and is what
`uvm_component::new` (3 leading Rhs-less assignments), `uvm_port_base::new` (2)
and `uvm_cmdline_processor::new` (2) were missing on our side.

## 3. `§ qualifiedCtorLosesPortListAndBody27`

> A constructor written with any class-item qualifier (`local` / `protected` /
> `static`) has **no io_decls and no body at all**.

`CompileClass.cpp` advances `func_decl` past the qualifiers to CLASSIFY the
method (:455) but then hands `compileClassConstructorDeclaration` the
**unadvanced** `fC->Child(id)` (:585) — the qualifier node. `compileFunction`
re-runs `setFuncTaskQualifiers` internally (:2304) and so is immune. Every node
the constructor routine derives from `Tf_port_list = fC->Child(nodeId)` then
comes out invalid: no port list compiles, `nbStmts` is 0, and the return
`class_var`'s span (taken from `varId`) is lost too.

t37f measures three arms (`protected`+ports+super.new, `local`+ports,
`protected`+no ports) and two controls (the unqualified constructor twin, and a
`protected` ordinary method) and golden splits exactly that way. Reach: **all 21
`uvm_*_phase::new`**, every one `protected function new(string name="build");
super.new(name); endfunction`.

## 4. `§ constClassPropIsConstantVariable27`

> A `const` class PROPERTY carries `vpiConstantVariable`.

We stamped it on package, module and interface variables and never on a class
member. Orthogonal to `static` and to the visibility qualifiers — t37g measures
both qualifier orders, with and without an initializer, `local`/`protected`,
`int` and `string`, against the non-const and `rand` controls, and every `const`
spelling reads 1 while `vpiAutomatic` keeps its own (`static` ⇒ 0) rule.

Reach is one shared object per macro expansion but a wide one: `const static
string type_name` (`uvm_object_defines.svh`:428, the `uvm_object_utils`
expansion) alone was **161** of Scoreboard's failing package-listing elements,
because `variables::Compare` reads the field and every method whose body
mentions the class drags the object in.

---

## RANKED for pass 28

Measured with `r10uvm27l` on Scoreboard after this pass (1143 elements;
`bash /tmp/r10uvm27_hist.sh <loc output>` for the histogram):

1. **`function` vs `string_var 'v' 79:12` — 183 elements, the largest single
   class.** A CLASS-listing divergence reached from `uvm_pkg`'s Task_funcs:
   golden's element is a `function` where ours is one particular `string_var`,
   the same object every time. Localize which vector of which `class_defn`
   diverges (extend `r10uvm27l`'s `vec()` to `class_defn` listings) before
   theorizing — this is very likely ONE ordering/membership law, not 183.
2. **`class_typespec` vs `class_typespec` — 125 elements, same kind both
   sides**, so a scalar field or `Instance()`. `r10uvm27l --why` already prints
   the typespec's `Instance()`; this is probably the SAME stamp divergence
   ranked #2 for pass 27 on SeqDriver (below), now visible with a per-element
   localizer instead of a single head.
3. **SeqDriver — unchanged head, `package adpcm_pkg`.** Pass 26's finding
   stands (`r10uvm26c` reads all 25 vectors IDENTICAL in both views): an
   `Instance()`-STAMP divergence that makes `typespec::Compare` descend into
   different package views. Item 2 is the likely handle on it — do NOT
   re-census the listings.
4. **BuildUVMPkg — unchanged head, `class_typespec
   'uvm_pkg::uvm_id_verbosities_array'`** (its uvm is `1800.2-2017-1.0`, a
   DIFFERENT source tree — census that tree's shape before assuming uvm-1.2
   laws apply). Also its `tf 2` remainder in `r10uvm23m`.
5. **The `t36b` net-vs-var residue, 2 objects** (unchanged from pass 26's
   ranking #4): `const li_t i = 5;` is a VAR in golden and we drop it, `ls2_t
   s;` (typedef'd string) is a NET in golden and we emit a var. Same
   §…26 parse predicate, on the emission-KIND side.
6. Unchanged: `var 34` class-listing remainder (`r10uvm23m`), the `t33d`
   extern-prototype listing entry, hier_path root-degradation,
   `::`-qualified iterated names.
