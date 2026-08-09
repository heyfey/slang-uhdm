# r10uvm26 — UVM pass 26

Pass 25's ranked **#1** and **#2** are **decoded, purpose-built and
implemented**, and the whole variable-listing residue of the UVM-4 — in BOTH
package views, in every package, clones included — is now **byte-identical to
golden**.  A **third** law came out of the head that surfaced behind them.

| metric | HEAD 2ba1353 | this pass |
|---|---|---|
| `r10uvm26_vm.sh` variable listings (`DEFPKG`+`ELABPKG`, all 4 tests) | **144** | **0** |
| … of which `vpiAutomatic` | 128 | 0 |
| … of which `uvm_top`'s `vpiExpr` | 16 | 0 |

The UVM-4's first failing pair moved **twice** as a consequence, which is the
honest measure of the three laws:

| test | head at 2ba1353 | after laws 1+2 | after law 3 |
|---|---|---|---|
| Scoreboard (default) | `class_var uvm_default_table_printer` | `string_typespec` @ uvm_printer.svh:1189 | `begin` in `uvm_tree_printer::new` |
| SimpleUVM (both) | `class_var uvm_default_table_printer` | same | same |
| SeqDriver (both) | `package adpcm_pkg` | unchanged | unchanged |
| BuildUVMPkg (both) | `class_typespec uvm_id_verbosities_array` | unchanged | unchanged |

Gate on the final tree: goldens **23/23 PASS**; u2r testflags (732 rows) and
Surelog both-modes (1589 rows) **byte-identical** to the committed baselines
(`diff | wc -l` = 0 each, dump column included) — so SLANG_REJECT membership,
every canary and every `dump=match` are unchanged. **0 movers**: the four tests
stay `CMP_NOTEQUAL` on a NEW first pair this pass measured (see the ranking).

    V=<r10uvm26v build> bash /tmp/r10uvm26_vm.sh <sweep workdir>   # the metric
    V=<r10uvm26v build> bash /tmp/r10uvm26_arm.sh tools/probe/r10uvm26repro/t36a

Build the probe with the **STATIC** UHDM libs (a shared `-luhdm` restores
Surelog's `.uhdm` with NULL vector contents and the census silently measures
nothing):

    g++ -std=c++20 -O2 tools/probe/r10uvm26v.cpp -o /tmp/r10uvm26v \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

`r10uvm26v` extends `r10uvm25v` with the MODULE views (`DEFMOD`/`ELABMOD`),
which is what settled the import-hoist arm of law 1.

---

## 1. `§ packageVarAutomaticIsDataDeclShape26`

> `vpiAutomatic` on a PACKAGE-scope variable is decided by **which grammar rule
> Surelog's parser matched**, not by the variable's kind.

`CompileHelper::compileDataDeclaration` (`CompileHelper.cpp`:2293) computes
`is_static = (component is ModuleDefinition || Program)` — **false for a
package** — while `compileNetDeclaration` (:2186/:2199) calls `sig->setStatic()`
**unconditionally**, and `makeVar_`'s tail (`ElaborationStep.cpp`:2350) writes
`VpiAutomatic(!sig->isStatic())`.  So the question is only ever *did this
declaration match `net_declaration` or `data_declaration`* — and a declaration
whose written data type is a bare (or `::`-qualified) type **identifier** matches
`net_declaration` (the user-defined-nettype ambiguity).  A keyword-spelled type,
a `const`/`var` qualifier, or a `new` initializer (`new` is not in the
`net_decl_assignment` grammar) each force `data_declaration` and with it the
automatic lifetime.

Measured on `t36a`/`t36b`, both views, with both negative controls:

| declaration | golden |
|---|---|
| `C c = new();` / `C c = new(3);` | **1** |
| `const C c = C::get();` | **1** |
| `var C c;` | **1** |
| `C c;` / `C c = other;` / `C c = null;` / `C c = C::get();` | **0** |
| `int` / `logic` / `string` / inline `enum {..} e` | **1** |
| a TYPEDEF'd enum (`le_t e;`), incl. `pk::le_t` | **0** |
| `const li_t i;` (typedef'd int, const) | **1** |

That is uvm_pkg's nine exactly: the five `= new()`
(`uvm_default_{table,tree,line}_printer`, `uvm_default_packer`,
`uvm_default_comparer`) and the four `const` handles (`uvm_resources`,
`uvm_top`, `uvm_test_done`, `uvm_cmdline_proc`) — against `uvm_default_printer`
(`= uvm_default_table_printer`, a plain reference) and the eight `uvm_phase
*_ph` (no initializer), which golden leaves at 0.  A blanket "package variables
are automatic" rule would have been wrong on nine objects per view.

**The lifetime is baked into the `Signal` at the DECLARING package's
data-declaration compile**, so every clone inherits it verbatim: `t36c`
measures an importing PACKAGE's copy and an importing MODULE's hoist and both
read the home package's value, even though the module's OWN `int m_own = 2;` is
static (auto=0) in the same listing.

**The same parse rule decides the SPAN** (`t36d`): a `data_declaration`
variable spans the whole declarator — name token through initializer — because
its Signal is built on the `variable_decl_assignment` node, while a
`net_declaration` one spans the **name alone**.  Restricted to a package's own
members: a hoisted out-of-body constructor local is a subroutine statement (a
different Surelog path) and keeps the declarator span.

## 2. `§ classScopeCallOfOutOfBodyMethodIsFuncCall26`

> `§ staticScopedCall12`'s bare `ref_obj` is the **degraded** form, and what
> degrades is a NAME LOOKUP: a `Class::f()` call is a REAL `func_call`/
> `task_call` — qualified name, `vpiFunction`/`vpiTask`, arguments, spanning the
> CLASS-NAME TOKEN alone — exactly when `f` is defined **OUT OF BODY**.

`CompileExpression.cpp`:5273 asks `getTaskFunc("<Class>::<f>")` first and falls
through to `compileExpression`'s `paClass_scope` `ref_obj` (:3390) only when it
misses (:5375).  `getTaskFunc` keys on the **literal** name, and the only
declaration that registers a task_func called `Class::f` is an out-of-body
definition (`function extern_c::get(); ... endfunction`, the body of an `extern`
prototype) — an in-body method is registered as plain `f` inside the class, so
its qualified lookup always misses.

`t36d` builds both arms and both controls (in-body static getter vs extern
prototype + out-of-body body, each called `const` and non-`const` at package
scope) and golden splits exactly that way in BOTH views.

This also **explains the "measured and rejected" note** at ExprEmit's bound-call
arm: golden's five qualified names are `uvm_root::get` and
`uvm_{reg,reg_field,mem}::get_max_size` — every one an `extern static function`
with an out-of-body body — while `uvm_coreservice_t::get`, whose 143 call sites
that experiment minted wrongly, is defined IN BODY.  The rule was never
"qualified spelling keeps the qualifier".

A package-variable initializer is emitted before the package's task_funcs
exist, so the link is deferred (`drainScopedCallBind26`, next to
`drainBodyOpArgTs`).

## 3. `§ stringCastKeepsStringTypespec26`

The pair laws 1+2 exposed: `uvm_printer.svh`:1189
`s = {s, string'(knobs.separator[0]), linefeed};` — golden `string_typespec`,
ours `logic_typespec`.  ExprEmit's cast-target fallback had arms for
byte/int/`bit'` and a catch-all logic one; the STRING keyword had none, though
Surelog compiles the written `paString_type` node into a string_typespec like
any other string declaration.  `t36e` measures a string cast in a package
FUNCTION body (the wrong shape), one at MODULE scope (already right through
another path) and the `int'`/`logic'`/`bit'` negative controls, which keep their
own arms.

---

## RANKED for pass 27

1. **`uvm_tree_printer::new`'s `begin` block** — the NEW head of
   `Scoreboard`(default) and `SimpleUVM`(both modes) after law 3, a BODY
   residue (`uvm_printer.svh`:1130-1136, an out-of-body constructor):
   `begin: (uvm_pkg::uvm_tree_printer::new)`.  `r10uvm7b` is the body-residue
   probe for this class of work.
2. **SeqDriver** — its head is NOT a package-listing size or order difference:
   `r10uvm26c` (this pass, 25 vectors per package view) reads **IDENTICAL** for
   builtin/uvm_pkg/adpcm_pkg in BOTH views, and the package ORDER matches too.
   What the reported pair actually says is an **Instance()-stamp divergence** —
   golden's object is instanced at `adpcm_pkg` where ours is at `uvm_pkg`, and
   `typespec::Compare` chases `Instance()`, so the walk descends into different
   package views and reports the two packages as the failing pair.  Find the
   object holding the wrong stamp (a shared typespec or class listing entry
   reachable from the design walk) — do not re-census the listings.
3. **BuildUVMPkg** — unchanged head, `class_typespec
   'uvm_pkg::uvm_id_verbosities_array'` (its uvm is `1800.2-2017-1.0`, a
   DIFFERENT source tree from the other three's `uvm-1.2` — decode it there).
4. **The `t36b` net-vs-var residue, 2 objects** — `const li_t i = 5;` (a
   `const` typedef'd int) is a VAR in golden and we drop it, while `ls2_t s;`
   (a typedef'd string) is a NET in golden and we emit a var.  Same § ...26
   parse rule, now on the net-vs-var side rather than the lifetime side:
   `const`/`var`/`new` force the var, a bare identifier type forces the net.
   Cheap, fully reproduced, and it is the SAME predicate already implemented —
   only the consumer differs.
5. Unchanged from pass 25: `var 34` class-listing remainder, `tf 2`
   (BuildUVMPkg), the `t33d` extern-prototype listing entry, hier_path
   root-degradation, `::`-qualified iterated names.
