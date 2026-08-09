# r10uvm29 — UVM pass 29

Pass 28's ranked **#1** and **#2** were read as two different problems: a
`class_var` whose golden `vpiExpr` is a `method_func_call 'new'` we do not
emit, and a `ref_obj 'uvm_callbacks::m_register_pair'` golden "BINDS" while we
"null". They are **one** problem. Neither is a binding question at all —
golden leaves `Actual_group` null on that `ref_obj` too. Both are the SAME
missing field: a class-property **declaration initializer**. The emitter's
initializer arm (`emitClassDefn`) was a five-kind whitelist — `NamedValue`,
`IntegerLiteral`, unary-minus-over-`IntegerLiteral`, `StringLiteral`,
`RealLiteral` — and everything else was dropped silently.

| metric | HEAD cc81777 | this pass |
|---|---|---|
| `r10uvm29m.sh` class-property initializer diff, UVM-4 (`INITTOTAL`) | **404** | **52** (-87%) |
| — BuildUVMPkg / Scoreboard / SeqDriver / SimpleUVM | 81 / 107 / 108 / 108 | 17 / 11 / 12 / 12 |
| `r10uvm28m.sh` `BINDTOTAL` | 5910 | **5910** (held) |
| `r10uvm27m.sh` CTORTOTAL / BODYOTHER | 0 / 680 | **0 / 680** (held) |
| `r10uvm26m.sh` VARTOTAL | 0 | **0** (held) |
| `r10uvm23m.sh` class listings | 36 | **36** (held) |
| golden `vpiExpr`-bearing class properties matched, Scoreboard | 197 of 228 | **260 of 263** |

**0 movers**: all 7 UVM-4 rows stay `CMP_NOTEQUAL`. Master gates: goldens
**23/23**; u2r testflags (732 rows) and Surelog both-modes (1589 rows)
`diff | wc -l` = **0** against `results/gate_uhdm2rtlil.csv` and
`results/golden_surelog.csv`, dump column included, `SLANG_REJECT` membership
unchanged, every canary held.

Build the probes with the **STATIC** UHDM libs:

    g++ -std=c++20 -O2 tools/probe/r10uvm29v.cpp -o /tmp/r10uvm29v \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SLANG_UHDM=<build> R10V=/tmp/r10uvm29v \
      tools/probe/r10uvm29run.sh tools/probe/r10uvm29repro/t39a
    R10V=/tmp/r10uvm29v  tools/probe/r10uvm29m.sh  <sweep workdir>   # the metric
    R10IO=/tmp/r10uvm29io tools/probe/r10uvm29iom.sh <sweep workdir> # pass 30's

`r10uvm29run.sh` writes **only** to `/tmp/r10uvm29arm/<arm>/` — unlike
`r10uvm28run.sh`, it never creates an `out/` directory inside the repo tree.

---

## 0. The probes this pass added

* **`r10uvm29v`** — the class-property INITIALIZER census: every `class_defn`
  variable in every view, plus a RECURSIVE projection of its `vpiExpr` onto the
  fields `uhdm-cmp` reads (kind / name / defname / decompile / size /
  constType / op-type / `Tf_call_args` / `Function()` / `Scope()` / `Prefix()`
  / `Actual_group`), with `line:col`. This is the projection the whole pass
  rests on: `r10uvm27cv` already printed the KIND of the expr, and reading its
  Scoreboard diff — **31 golden initializers against 0 extras of ours** — was
  the entire decode brief.
* **`r10uvm29m.sh`** — the metric. Diffs that census golden-vs-ours with the
  `@line:col` suffix **stripped**: `uhdm-cmp` compares no span, and the nine
  `uvm_register_cb` macro expansions each land in a different column, which
  would otherwise have hidden the real movement under location noise.
* **`r10uvm29io` / `r10uvm29iom.sh`** — the formal-DEFAULT census, written as a
  *control* (see §5) and kept as pass 30's metric.

## 1. The four laws

Each cell of each law was read BOTH directions off a purpose-built pair; the
arms are `t39a` (the shape matrix), `t39b` (the cells t39a left open) and
`t39c` (the three shapes t39a could not settle).

### § classPropNewInit29

> `T p = new;` / `= new()` / `= new(args)` keeps the constructor call as the
> variable's `vpiExpr`.

It is exactly the **loc-less `method_func_call 'new'`** `emitExpr`'s NewClass
arm already builds — `VpiUserDefn` 0, no `Prefix`, no `Function`, no `Scope`,
line 0:0 — with the arguments as `vpiArgument` and, when there are none, **no
argument vector at all**: bare `new` and `new()` are byte-identical in golden.
11 uvm_pkg properties in Scoreboard (`uvm_status_container::scope`,
`uvm_packer::scope`, `uvm_printer::knobs`/`m_scope`, `uvm_transaction::events`,
`uvm_object::__m_uvm_status_container`, ...). This was the pass-28 head at
240+28+26 elements.

### § classPropScopedCallIsRefObj29

> A call written through a **CLASS** `::` scope is not a call in the model: it
> degrades to a bare `ref_obj`.

| written | golden `vpiExpr` |
|---|---|
| `base39::mk()` | `ref_obj 'base39::mk'`, `Actual_group` **null** |
| `cls39#(int)::sf()` | `ref_obj 'cls39::sf'` — parameterisation dropped |
| `q39b::kb39#(2)::sf(1,"s")` | `ref_obj 'q39b::sf'` — **middle segment and both arguments dropped** |
| `q39b::qf39(4)` (PACKAGE qualifier) | `func_call 'q39b::qf39'`, `vpiFunction` bound, argument kept |

So the name is `<leftmost segment identifier>::<rightmost segment text>` and
the discriminator is what the qualifier RESOLVES to, not how it is spelled —
the missing half of ExprEmit's § staticScopedCall12 note ("qualifying
unconditionally MINTED 290 wrong names, `uvm_coreservice_t::get` alone 143;
decode where the other spelling goes"). It goes here. `vpiFullName` is
`<property fullname>::<that name>` (the same rule the NamedValue arm already
followed) and the span runs from the head of the scoped name **through the
last `::`** — Surelog's class_scope span, the one `makeClassScopeTs` uses.

Reach: the 9 `bit m_register_cb_*` the `uvm_register_cb` macro plants
(`uvm_callbacks#(T,CB)::m_register_pair(...)`) plus
`uvm_heartbeat_callback::cs = uvm_coreservice_t::get()` — pass 28's ranked #2,
166 elements.

### § classPropCallInit29

> Any other call stays a `func_call` with `vpiFunction` bound and its written
> arguments — but its ACTUALS carry no formal-typespec ref.

`emitExpr` already builds that shape, so the only work is *when*: the six UVM
cases (`uvm_component_registry::me = get()`,
`uvm_reg_field::m_predefined = m_predefine_policies()`, `uvm_resource::my_type`,
`uvm_resource_pool::rp`, `uvm_object_registry::me`,
`uvm_tlm_extension::m_my_tlm_ext_type`) all call a **static method of their own
class**, which does not exist in `subMap` while the property list is being
built. Hence the deferred drain: the initializers are collected during the
property loop and emitted immediately after `emitTaskFuncs` compiled the class
body. The formal-typespec carve-out (`classPropInitCtx29`, one more clause
beside `propDeclScope` in ExprEmit's stamp gate) came straight off t39a, where
golden's `pkgf39(2)` actual is a bare constant and ours carried an
`int_typespec` ref — `expr::Compare` reads `Typespec()`, so that alone would
have traded one difference for another.

### § classPropRealInitRawValue29 (a correction, not an addition)

> A class-property REAL initializer's `vpiValue` is the **source text**.

`%f` is not a rendering of the double Surelog ever produces here: t39c reads
`REAL:1.5`, `REAL:1.0e-12`, `REAL:3.0`, `REAL:1e6` — always equal to the
decompile — and the same inside a `vpiMinusOp` (`real r = -2.5` →
`REAL:2.5`, a negated-real cell the minus arm did not handle at all).
`uvm_tlm_time`'s `real Tp = 1.0e-12` had been printing **`REAL:0.000000`**: a
REAL PAIR, not a missing object, and the kind of difference a shape census that
stops at "both sides have a constant" cannot see. Only the class-property arm
is changed; ExprEmit's shared RealLiteral arm keeps `%f` (the corpus depends on
it, and the param-fold decompile is explicitly `%f`).

Plus § classPropUnbasedUnsizedInit29 (`'1` fills the property width and prints
one unsigned decimal — `uvm_spell_chkr::max` → 4294967295 at size 32) and
§ classPropPatternInit29 (a concatenation and an assignment pattern ride the
`operation` emitExpr builds; the assoc/queue/dynamic arm enqueues its property
explicitly because it `continue`s past the scalar initializer block —
`uvm_sequence_library`'s `int seqs_distrib[string] = '{default:0}` is
byte-identical to golden, `tagged_pattern` and index typespec included).

## 2. What the pass deliberately did NOT model

All three were MEASURED and none has a settled law. Guessing one would have
traded a missing object for a wrong one:

* **BASED literals.** `int k_wide = 8'hff` → golden `HEX:ff`, decompile
  `8'hff`, size **32**; `bit[3:0] k_narrow = 8'hff` → same value, size **4**;
  but `int k_bin = 4'b1010` → `BIN:1010`, size **4**, not 32. The value form is
  clear (source spelling + base constType, where our IntegerLiteral arm prints
  decimal UINT); the SIZE rule is not. No UVM-4 property reaches this shape —
  Scoreboard's constant initializers are name-for-name identical — so it costs
  nothing today and would have cost a wrong size if guessed.
* **TIME literals.** Under one `timescale 1ns/1ps`: `9200s` → 9200×10^12,
  `5ns` → 5×10^6, `7ps` → 7, `realtime 1.5ns` → 1×10^6. Three different
  scale factors and a truncation; not the design precision, not the literal's
  own unit. One property (`uvm_root::phase_timeout`).
* **A SIMPLE assignment pattern's element constants** size at the element width
  (`int a_dyn[] = '{4,5}` → size 32) where emitExpr gives 64. No UVM property
  reaches it (`'{default:0}` builds a `tagged_pattern`, which matches).

## 3. Two adjacent bugs this census surfaced (unfixed, both pre-existing)

* `uvm_mem_mam_cfg::mode`/`locality` and `uvm_sequence_request::request` are
  `logic_var` in golden and `enum_var` in ours; `uvm_reg_map_info::mem_range`
  is `struct_var` in golden and `bit_var` in ours — property KIND, three
  objects, likely the "typedef the declaring class cannot see" degradation
  `classAssocElemVar` already models for array elements.
* A fixed-size unpacked-array property (`int a_fixed[3]`) is DROPPED from our
  variables listing entirely (t39c; golden lists it with an operation#75
  initializer), and an `array_var` of an `int` element carries `vpiSigned` in
  golden and not in ours.

## 4. Method note

The pass's whole yield came from projecting **one field nothing had projected
before** (`variables::Expr`, recursively) and reading the census diff as a
2×2 — 31 golden-only initializers, **0** of ours golden lacks. That asymmetry
is what said "this is a whitelist gap, not a shape disagreement", and it is why
`t39a` could be written as a 16-cell matrix decoded in a single Surelog run
instead of one hypothesis per pass.

## 5. RANKED for pass 30

1. **`io_decl` FORMAL DEFAULTS — `IOTOTAL` 1617 (294/353/617/353), and the new
   design head.** The moment § classPropInit29 cleared the class_var head the
   localizer's first row became `L <null> R ref_obj 'UVM_NORADIX'` — an EXTRA
   pointer on a METHOD FORMAL's default value. **Confirmed pre-existing, not
   introduced**: `r10uvm29io` on the pre- and post-patch Scoreboard databases
   is byte-identical (6685 rows both), so the object was always there and only
   became reachable. The law is NOT "enum-constant defaults are dropped":
   golden keeps 152 `ref_obj` defaults (`UVM_DEFAULT_PATH` ×86, `UVM_HIER` ×36)
   and drops 77 others — and `UVM_HIER` appears on BOTH sides of that split, so
   the rule is positional, not name- or kind-based. Golden's io_decl listings
   are also 107 rows LONGER than ours on Scoreboard. Census with `r10uvm29io`
   and build the 2×2 before any code.
2. **The 5910 binding keys** (`extra` 1979 / `miss` 3931), unchanged — SeqDriver
   alone holds 3171 misses against ~200 elsewhere; `r10uvm28g` + `r10uvm28e`
   cut-bisection remain the tools, and pass 27 #2's adpcm_pkg Instance-stamp
   object may be the same head.
3. **`class_typespec` EXTRAS 67+47+39** — parameterised-pool properties where
   golden has NO typespec pointer (`uvm_id_verbosities_array` still the largest
   real pair at 94, BuildUVMPkg's head).
4. **The class-property remainder, `INITTOTAL` 52** — the three unsettled
   families of §2 plus the three KIND pairs of §3.
5. Unchanged: BuildUVMPkg's `tf 2` and the `var 34` class-listing remainder
   (`r10uvm23m` = 36), `t36b` net-vs-var (2 objects), `t33d`'s
   extern-prototype entry, hier_path root-degradation.
