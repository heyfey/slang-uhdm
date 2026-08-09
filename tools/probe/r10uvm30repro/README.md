# r10uvm30 — UVM pass 30

Pass 29's ranked **#1** was the `io_decl` FORMAL-DEFAULT head, `IOTOTAL` 1617,
with the note that "golden keeps 152 `ref_obj` defaults and DROPS 77, and
`UVM_HIER` appears on BOTH sides of that split, so the rule is positional, not
name- or kind-based". It is neither positional nor kind-based. The whole key is
the **written spelling of the formal's DATA TYPE** together with whether the
formal carries its **own direction keyword** — a Surelog `tf_port_item`
artifact, and a single 2×2 that explains all 89 value-diff keys on Scoreboard.
The 107 io_decl rows golden has and we lacked entirely were a *second*, unrelated
gap: **pure virtual prototypes carry their formals**, which
`§ pureVirtRet10`'s aside had asserted they do not (that aside was never
measured).

| metric | HEAD af17f91 | this pass |
|---|---|---|
| `r10uvm29iom.sh` io_decl formal-default diff, UVM-4 (`IOTOTAL`) | **1617** | **2** (-99.9%) |
| — BuildUVMPkg / Scoreboard / SeqDriver / SimpleUVM | 294 / 353 / 617 / 353 | 2 / **0** / **0** / **0** |
| `r10uvm30iom.sh` deep io projection (`IOTOTAL2`, new; +typespec +value) | **5605** (627/690/3406/882) | **3509** |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm28m.sh` `BINDTOTAL` | 5910 | **5910** (held) |
| `r10uvm27m.sh` CTORTOTAL / BODYOTHER | 0 / 680 | **0 / 435** |
| `r10uvm26m.sh` VARTOTAL | 0 | **0** (held) |
| `r10uvm23m.sh` class listings | 36 | **36** (held) |

Three of the four UVM-4 tests now have a **byte-identical formal-default
census**; BuildUVMPkg's 2 remaining rows are the known `tf 2` class-listing
residue (`local function automatic int unsigned ceil` inside `uvm_reg_map`,
which golden does not list and we do), not a default-value question.

The BODYOTHER move is honest but narrow: `r10uvm27s` prints `io=<n>` per
task_func, and § pureVirtIoDecls30 makes that column agree on 245 prototypes.
No body STATEMENT changed.

**0 movers**: all 7 UVM-4 rows stay `CMP_NOTEQUAL`. Master gates: goldens
**23/23**; u2r testflags (731 rows) and Surelog both-modes (1589 rows)
`diff | wc -l` = **0** against `results/gate_uhdm2rtlil.csv` and
`results/golden_surelog.csv`, dump column included, `SLANG_REJECT` membership
unchanged, every canary held.

Build the probes with the **STATIC** UHDM libs:

    g++ -std=c++20 -O2 tools/probe/r10uvm30io.cpp -o /tmp/r10uvm30io \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SLANG_UHDM=<build> R10IO=/tmp/r10uvm30io \
      tools/probe/r10uvm30run.sh tools/probe/r10uvm30repro/t40a
    R10IO=/tmp/r10uvm30io tools/probe/r10uvm30iom.sh <sweep workdir>   # the metric

`r10uvm30run.sh` writes **only** to `/tmp/r10uvm30arm/<arm>/`; it never creates
an `out/` directory inside the repo tree.

---

## 0. The probes this pass added

* **`r10uvm30io`** — the io_decl FORMAL census. `r10uvm29io` printed a row only
  for a method that HAS an `Io_decls()` vector, so the 107-row population
  deficit was invisible in it (a method whose formals we drop entirely prints
  nothing on our side and nothing to diff against), and it projected only the
  default's KIND and NAME, so a value-only pair (`REAL:1.5` vs `REAL:1.500000`)
  was invisible too. This one prints `io[-] <none>` for an empty vector,
  walks packages **and modules** (the control that proved the law is a
  subroutine rule, not a class-method rule), and projects per formal:
  `vpiDirection`, the ACTUAL typespec's kind / name / `vpiInstance`, the
  io_decl's own range count, and the default's kind / name / value / decompile.
* **`r10uvm30iom.sh`** — the same census as a UVM-4 metric (`IOTOTAL2`).
  `r10uvm29iom` stays valid and stays the headline number; this one is the
  strictly finer instrument and is what pass 31 should carry.
* **`r10uvm30pv`** — the PACKAGE/MODULE-scope variable initializer census,
  written as a CONTROL (§5) and worth keeping: it is `r10uvm29v` for the scope
  outside `class_defn`.

## 1. The three laws

Every cell of every law was read BOTH directions off a purpose-built pair:
`t40a` (the 20-cell shape matrix + the pure-virtual block), `t40b` (the
built-in / inline / scoped / non-class-scope controls) and `t40c` (the
boundary spellings t40a and t40b left open).

### § noDirNamedTypeDefaultDropped30

> A subroutine formal written with **no `tf_port_direction` keyword of its
> own** whose data type is a **bare type IDENTIFIER** loses its default value
> entirely. Every other spelling keeps it.

| written | golden `vpiExpr` |
|---|---|
| `e40_t e = E1` | **dropped** |
| `input e40_t e = E1` | `ref_obj 'E1'` |
| `i40_t k = 3` (typedef of `int`) | **dropped** |
| `s40_t s = "x"` (typedef of `string`) | **dropped** |
| `h40 h = null` / `pc40#(int) h = null` | **dropped** |
| `s40_t v = '{a:1}` / `e40_t e = e40_t'(1)` | **dropped** |
| `int k = 3`, `bit[3:0]`, `logic`, `logic[7:0]`, `byte`, `int unsigned`, `real`, `time`, `string` | kept |
| `chandle h = null`, `event e = null` | **kept** |
| `enum int {A0,A1} v = A1` (inline anon), `struct packed {..} v = 2'b10` | kept |
| `q40b::f40_t v = q40b::F1`, `q40b::g40 h = null` (SCOPED) | kept |
| `virtual if40c vi = null` | kept |
| `f(input string s, e40_t e=E1)` — INHERITED direction | **dropped** |
| `f(ref int q, input e40_t e=E1)` | kept |

The rule this replaces read the drop off `= null` alone (`r10uvm7/c5`:
`f1(input K k=null)` keeps the `vpiNullConst`, `f2(K k=null)` does not) and
generalised it to every no-direction `null`. The null was incidental: the
`chandle`/`event` cells are no-direction nulls that golden **keeps**, and the
scoped-class and virtual-interface cells are two more. The generalisation was
therefore both too wide (four cells) and far too narrow (89 keys).

It is a **subroutine** rule, not a class-method rule: the same cells drop in a
package function, a module function, a module task and at `$unit` scope, in
extern prototypes and out-of-body definitions alike, for functions and tasks.
Reach on Scoreboard: every `uvm_radix_enum radix=UVM_NORADIX` (`uvm_comparer`,
`uvm_printer`, `uvm_recorder`), `uvm_predict_e kind=UVM_PREDICT_DIRECT` and
`uvm_path_e path=UVM_FRONTDOOR` (`uvm_reg::predict`), `uvm_hier_e hier=UVM_HIER`
(`uvm_reg_map::get_base_addr` and its four siblings) and every
`uvm_reg_addr_t offset=0` — while the 152 `input uvm_path_e
path=UVM_DEFAULT_PATH`-shaped ones stay, and `int has_coverage=UVM_NO_COVERAGE`
(no direction, but a BUILT-IN type) stays too. That last cell is what refutes
the direction-keyword-alone reading, and `UVM_HIER` on both sides of the split
is what refutes the enum-kind reading; both had to be in the same matrix to
settle it.

Implementation: `TaskFuncEmit.cpp`, the io_decl default arm — `NamedType` over
an `IdentifierName` or a `ClassName`, with no `FunctionPortSyntax::direction`.
A `ScopedName` is not one, and a builtin keyword type, an inline enum/struct
and a `virtual` interface are other `DataTypeSyntax` kinds entirely, so the
predicate needs no type-system query at all.

### § pureVirtIoDecls30

> A **pure virtual** prototype carries its FORMALS, with the same io_decl a
> defined method's formal gets.

`§ pureVirtRet10` wrote "only the body and the io_decls are absent" as an
aside; t40a reads golden's `pure virtual function void pv_defint(int k = 3)`
with a full io_decl: name, `vpiDirection`, a `ref_typespec` to the same
typespec object an IN-CLASS method's formal takes (`int_typespec` with **no**
`vpiInstance`; a named typedef's is the shared, already-stamped one), and the
default under § noDirNamedTypeDefaultDropped30 exactly as elsewhere
(`pv_defenum(e40_t e=E1)` drops it, `pv_definput(input e40_t e=E1)` keeps it).
The prototype takes no `funcMap` / `subMap` registration — nothing binds a
pure virtual's formals, there being no body.

Reach: the **entire** 107-row io_decl population deficit, on every UVM-4 test —
`uvm_factory` 39 rows, `uvm_recorder` 19, `uvm_report_server` 18,
`uvm_coreservice_t`, `uvm_tr_database`, `uvm_visitor_adapter`,
`uvm_set_get_dap_base`, `uvm_link_base`, `uvm_structure_proxy`,
`uvm_port_component_base`, `uvm_reg_adapter`, `uvm_subscriber`,
`uvm_resource_base`, `uvm_visitor`, `uvm_comparer` — every one of them an
abstract UVM base class. Reading the golden-only rows as a population and
grouping them by CLASS was the whole decode: eighteen class names, all
abstract, is not a coincidence that a value census could have produced.

### § formalRealDefaultRawValue30

> A REAL formal default's `vpiValue` is the **source text**.

The io_decl half of § classPropRealInitRawValue29. t40c reads golden
`REAL:1.5` / `REAL:1.0e-9` / `REAL:3.0` for `real`, `realtime` and `shortreal`
alike, with and without an `input` keyword, always equal to the decompile —
where the shared RealLiteral arm printed `REAL:1.500000` and, for `1.0e-9`,
`REAL:0.000000`. Two Scoreboard formals reach it. Confined to the io_decl arm;
the negated spelling (`real r = -2.5`) is an operation whose operand golden and
we already agree on, so only the bare literal moves.

This one is a metric lesson as much as a law: `IOTOTAL` was **0** on Scoreboard
while these two rows were still wrong, because `r10uvm29iom` projected the
default's kind and name and not its value. A census that stops one field short
of what `Compare` reads will report a closed head.

## 2. What the pass deliberately did NOT model

* **`var` in a `tf_port_item`.** `var e40_t e = E1` and `var int k = 3` come
  out of Surelog as an io_decl with an EMPTY name, direction `inout`, no
  typespec and a `ref_obj` named after the FORMAL as its `vpiExpr` (t40c) — a
  parse failure, not a model. No UVM formal is written that way.
* **The unqualified-parameter FOLD** (see §5 #3): golden keeps `ref_obj 'P40'`
  where we fold `int k = P40` to a constant, and — the mirror — FOLDS
  `q40b::F1` to `constant INT:1` where we keep a `ref_obj`. Both cells are
  settled in t40a/t40b, but the same disagreement reaches expression BODIES
  (`UVM_STREAMBITS` inside `uvm_comparer::compare_field`), so it is a folding
  law, not an io_decl law, and it wants its own pass and its own census.

## 3. Adjacent findings this census surfaced (unfixed)

* The io_decl **TYPESPEC** family, now the whole of `IOTOTAL2` 3509 — golden
  names a formal's typespec where we leave it bare (`string_typespec 's40_t'`
  vs `''`, `class_typespec 'p40c::pcint_t'` vs `'pc40'`, `logic_typespec
  'uvm_pkg::uvm_hdl_data_t'` vs `'uvm_hdl_data_t'`), gives an
  `interface_typespec` where we give a `logic_typespec` (a `virtual` interface
  formal), a `time_typespec` where we give a `real_typespec` (`realtime`), and
  an `unsupported_typespec 'RSP'`/`'REQ'` where we resolve the parameterised
  formal to `class_typespec 'uvm_sequence_item'` (30 rows on Scoreboard).
* BuildUVMPkg lists `uvm_reg_map::ceil` (a `local function automatic`) where
  golden does not — the known `tf 2` residue, now also the only 2 rows of
  `IOTOTAL`.

## 4. Method note

Two habits did the work. First, **census the population before the values**:
the brief said to read the keep-vs-drop rule, and the 107 golden-only rows
would have been read as more of the same had they not been split out as
"missing KEYS" vs "differing VALUES" first — they are two laws with nothing in
common. Second, **write the control arm in the same breath as the matrix**:
t40b's package/module/`$unit` cells are what turned "a class-method rule" into
"a subroutine rule" for free, and its `chandle`/`event` cells are what turned a
patch that *adds* a condition into one that *replaces* an existing law.

## 5. RANKED for pass 31

1. **The 5910 binding keys** (`extra` 1979 / `miss` 3931), unchanged — and now
   the head. With the formal-default rows gone, `r10uvm28a`'s first Scoreboard
   row is `L function 'print_field' <- class_defn 'uvm_printer'  R <null>`
   under `uvm_default_table_printer`: golden binds a pointer to
   `uvm_printer::print_field` that we leave null. SeqDriver alone holds 3171
   misses against ~200 elsewhere; `r10uvm28g` + `r10uvm28e` cut-bisection
   remain the tools. (The `uvm_default_table_printer` variable itself is NOT
   the defect — `r10uvm30pv` reads its `method_func_call 'new'` byte-identical
   on both sides, 78 rows, diff 0, and t40d confirms package/module/`$unit`
   `= new()` in every spelling. The design head names an object, not a field.)
2. **The io_decl TYPESPEC family — `IOTOTAL2` 3509** (203/212/**2822**/272),
   the new metric's whole remainder and the largest single number this pass
   leaves. SeqDriver's 2822 is worth a census of its own before any code; the
   five shapes are listed in §3 and every one of them is reproduced in
   `t40b`/`t40c`, so a purpose-built decode is already half written.
3. **The unqualified-parameter FOLD**, both directions, settled cells in hand:
   `int k = P40` → golden `ref_obj 'P40'`, ours `constant UINT:7` (t40a);
   `q40b::f40_t v = q40b::F1` → golden `constant INT:1`, ours `ref_obj 'F1'`
   (t40b). It reaches BODIES too — `r10uvm28a` row `var[6]` on Scoreboard is
   `ref_obj 'UVM_STREAMBITS'` vs `constant` inside
   `uvm_comparer::compare_field`. High value, high blast radius: measure the
   fold sites corpus-wide before touching one.
4. **`class_typespec` EXTRAS 67+47+39** and `uvm_id_verbosities_array` (94),
   still BuildUVMPkg's head (`class_typespec 'uvm_pkg::uvm_id_verbosities_array'`
   vs `class_typespec 'uvm_pool'`), unchanged by this pass.
5. **`INITTOTAL` 52** — the three unsettled families and three KIND pairs of
   pass 29's §2/§3; and the unchanged smalls: BuildUVMPkg's `tf 2`
   (`uvm_reg_map::ceil`), the `var 34` class-listing remainder
   (`r10uvm23m` = 36), `t36b` net-vs-var, `t33d`'s extern-prototype entry,
   hier_path root-degradation.
