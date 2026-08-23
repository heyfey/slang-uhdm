# r10uvm111 — § pkgVarInitCmViewClone111

**THE MiniAmiq 348-LINE HEAD (both modes) CLEARED.**

LHS is always golden (Surelog); RHS is always ours.

---

## 1. The head, and what it actually was

`raw/head_pris_default_MiniAmiq.cmp` (re-measured on this pass's own pristine
build; byte-identical, modulo ids, to the copy uvm101 committed):

```
LHS: function: (svaunit_pkg::uvm_root::get)  vpiParent: package svaunit_pkg
     vpiName: uvm_root::get
RHS: function: (uvm_pkg::uvm_root::get)      vpiParent: class_defn uvm_pkg::uvm_root
     vpiName: get
```

The brief framed this as a MISSING CLONE — golden carrying a copy of the
imported class's out-of-body method that we do not build.  **That framing is
refuted, and the refutation is the pass.**  We already build the clone, in both
views, at the right slot, with the right name and parent:

* `svaunit_pkg`'s DEF-view `vpiTaskFunc` listing: 894 entries in golden, 894 in
  ours, and the ordered name lists are IDENTICAL — `svaunit_pkg::uvm_root::get`
  sits at index 213 in both.
* `svaunit_pkg`'s ELABORATED listing: the same, 894 vs 894, identical order.

What differs is a **BINDING**.  `svaunit_pkg` carries a wildcard-import copy of
`uvm_pkg`'s package variable `uvm_top`, whose initializer is
`uvm_root::get()`.  Golden points that `func_call`'s `vpiFunction` at
`svaunit_pkg`'s OWN `uvm_root::get` listing entry; we pointed it at the
class_defn's method.  Compare reads `VpiName`, so `uvm_root::get` vs `get` is a
head; it never reads `VpiParent`, so the clone-vs-share question is invisible
and was never the defect.

`ct111id.cpp` (this pass's identity oracle — the text dump prints references by
SYNTHESISED fullname and cannot answer an identity question) reads the cells off
golden by `UhdmId`.

## 2. THE LAW

> A **package-scope variable initializer**'s scope-resolved `C::m()` call binds
> the `C::m` **`vpiTaskFunc` listing entry of the package VIEW it lives in**,
> where that view has one; where the view has none, it keeps the `class_defn`'s
> method.

Four-cell golden table, MiniAmiq (`uvm_top`, `uvm_root::get`) — and the same
four cells hold in SeqDriver, SimpleUVM, Scoreboard:

| view | package | golden binds | does the view carry a `C::m` entry? |
|---|---|---|---|
| DEF | `uvm_pkg` (home) | the home's own DEF listing entry | yes |
| DEF | importer (`svaunit_pkg`/`adpcm_pkg`) | the importer's DEF import-clone | yes |
| TOP | importer | the importer's ELABORATED import-clone | yes |
| TOP | `uvm_pkg` (home) | the **class_defn's method** | **no** |

The fourth row is not an exception — it is the same rule.  The ELABORATED home
package lists `class_defn`s instead of `C::m` clones (§ emitPackageClassMethod-
Clones), so the by-name scan misses and the class method stands.

### Surelog producer

`CompileHelper::getTaskFunc`, `src/DesignCompile/CompileExpression.cpp:349`:

1. if the name contains `::`, treat the head as a PACKAGE name —
   `design->getPackage("uvm_root")` is null for a CLASS, so a `C::m` spelling
   falls straight through this branch;
2. `while (comp) { for (tf : comp->getTask_funcs()) if (tf->VpiName() == name) return tf; ... }`
   — a linear scan of **the current component's own listing**, before parents,
   before file contents, before packages, before instances.

A package's listing entry for an out-of-body class-method definition is named
`C::m` verbatim (`UhdmWriter.cpp:1237-1274`), and
`CompileHelper::importPackage` (`CompileHelper.cpp:299-330`) `clone_tree`s the
imported package's WHOLE `Task_funcs` vector into the importer when `inPackage`
is true.  So step 2 hits the current package's own copy — home-owned or
import-cloned — and never reaches the class.

## 3. The fix

`src/ParamEmit.cpp` `UhdmExporter::bindPkgVarInitClassMethodClones111`, called
from `src/UhdmExporter.cpp` **immediately after `drainScopedCallBind26()`**,
once per package view of `AllPackages` and `TopPackages`.

*Placement is a measurement, not a preference.*  A `C::m()` in a package
variable initializer is emitted before the package has any `task_func` at all,
so § classScopeCallOfOutOfBodyMethodIsFuncCall26 DEFERS the link and makes it —
to the class_defn's method — at the very end of the run.  Placed inside
`emitPackage` (the first revision of this pass) the law moved the ONE cell that
happens to be bound at emission (the importer's ELABORATED view) and read
`Function() == nullptr` on the other three.  The corrected placement moves all
of them.

**Fence.** Only a `func_call` ALREADY bound to a CLASS_DEFN-parented method
moves, and only onto a listing entry whose `VpiName` is the call's name
EXACTLY.  Free-function calls keep their binding (clone and home share one
`VpiName` there, so the cell is invisible to Compare anyway); an unbound call
stays unbound.  No NAME is written anywhere — the memory *"naming is
context-dependent; do not uniformly fix `pkg::pkg::` names, it breaks
goldens/RefPkgParamInEnum"* is respected by construction: this pass re-points
one link at one site and writes no text.

## 4. Evidence

* `GRID.txt` — a **purpose-built Surelog golden** (`g111_a.sv`, 42 lines: a home
  package with two `extern static` out-of-body methods and two variable
  initializers, a WILDCARD importer, and an EXPLICIT importer).  Ten golden
  cells: 6 TO-GOLDEN, 4 ALREADY-RIGHT, 0 AWAY.  The explicit-import package is
  the decisive negative cell — it materialises no `C::m` listing entry, and
  golden leaves its call on the class method, exactly as the law predicts.
* `SCORE.uvm9.txt` — `score111.py` over the nine UVM databases: 22 cells,
  **TO-GOLDEN 15, ALREADY-RIGHT 7, AWAY-GOLDEN 0, STILL-WRONG 0**.
* `PREDICTION.txt` — `pred111.cpp` evaluated the law's own predicate on 956 +
  1358 PRISTINE databases and named the mover set BY NAME before the patched
  sweep; `byteverify` then measured exactly those seven and nothing else.
* `GATES.txt` — the whole landing battery.
* `BOUNDARY.acquittal.txt` — four boundary combinations over a copy of the
  whole probe tree, a positive control, and the acquittal of every differing
  arm.
* `raw/` — the pristine and patched MiniAmiq heads, and the positive-control
  diff.

## 5. Instruments (measurement only; the official `uhdm-cmp` is the judge)

* `ct111id.cpp` — the identity oracle: for every package view, which object each
  variable/param initializer `func_call` binds, BY `UhdmId`, next to that view's
  `C::m` listing entries.  Build:
  `g++ -O2 -std=c++17 ct111id.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct111id`
* `pred111.cpp` — the a-priori mover predictor (the law's predicate, evaluated
  on a pristine database).  Same build line.
* `predall.sh` — pred111 over a whole verify_golden workdir.
* `score111.py` — TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG per cell, by SHAPE
  (`PKGLIST` = the callee's `VpiName` is the full `C::m`; `CLASSM` = it is `m`
  alone), because ids are not comparable across producers.
* `fc111.py` — a whole-dump census of every call -> callee binding, keyed by
  (section, container, call name, field, callee).  It is what first showed the
  head was a binding and not a missing object.
* `attrib111.sh` — order-blind mover attribution.
* `bound111.sh` — the boundary gate (a verbatim copy of `r10uvm109repro/bound109.sh`).
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` / `ct8rows.sh` / `byteverify.sh` /
  `rowheads.sh` — the standard gates, copied for this pass.

## 6. Residues

* **R0 (next head, MiniAmiq both modes, 46 lines).**  `hier_path
  (gp.m_byte_enable)` where golden has a bare `ref_obj gp`, at
  `uvm_reg_tlm_adapter::reg2bus`'s `gp = ...` — the dotted-lvalue receiver
  collapse family, i.e. the head SeqDriver already carried at this base.
* **R-tf111.** The same `C::m` view-local binding question for calls written in
  a **package function or task BODY** (not a variable initializer) is NOT
  touched here.  `fc111.py` measures the surrounding family: in `svaunit_pkg`
  golden binds free-function calls (`uvm_hdl_deposit`, `uvm_is_match`,
  `uvm_split_string`, `uvm_pkg::m_uvm_string_queue_join` — 20 distinct callees
  over 1990 `func_call` objects in MiniAmiq alone) to the HOME
  objects while we bind the importer's clones.  Every one of those cells is
  invisible to Compare (clone and home share one `VpiName`), which is why they
  are a residue and not a gate, but they say the body rule differs from the
  initializer rule and the difference is not yet decoded.
* **R-bind111.** `this_type::add_typewide_sequence` is bound by us and UNBOUND
  in golden, in `uvm_pkg` and in every importer, in both views — 1 cell per
  package view across all five UVM rows.  Judge-visible only if the call is ever
  reached; it is not the head today.
* **R-buvm111.** BuildUVMPkg golden binds `uvm_root::get` five times and
  `uvm_reg_block::get_root_blocks` once in `uvm_pkg`'s ELABORATED view where we
  bind them fewer times; those calls are in bodies, not initializers (R-tf111's
  family).
* **R-addr111 (a latent defect, NOT this pass's).** The right bound of an
  ASSOCIATIVE-array (`[string]`) typedef range carries an ADDRESS: on
  `tools/probe/r10buvm22repro/g22.sv` the constant reads `22392217` under one
  binary and `22396313` under another — a one-page shift, deterministic per
  binary, identical with this law switched ON and OFF in the SAME binary.  It
  reaches no corpus row today, but any pass whose boundary gate touches an
  associative-array typedef will see it.
