# r10uvm31 — UVM pass 31

Pass 30's ranked **#2** was "the io_decl TYPESPEC family — `IOTOTAL2` 3509, the
new metric's whole remainder", with the instruction to **census by PAIR CLASS
first**. Doing that turned one 3509-line number into a ranked table of nine
independent families, and the largest CROSS-TEST one — 210 rows on all four
UVM-4 tests — turned out to have a single structural key that a purpose-built
pair settles in every cell: **an out-of-body definition of a parameterised
class's method cannot see its own class's type parameters.**

| metric | HEAD 3a3174b | this pass |
|---|---|---|
| `r10uvm30iom.sh` io_decl deep projection (`IOTOTAL2`) | **3509** | **3089** (-12%) |
| — BuildUVMPkg / Scoreboard / SeqDriver / SimpleUVM | 203 / 212 / 2822 / 272 | 163 / 152 / 2602 / 172 |
| `r10uvm31m.sh` the same residue counted ONCE per formal (`PAIRTOTAL`, new) | **1753** | **1543** |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm28m.sh` `BINDTOTAL` | 5910 | **5910** (held) |
| `r10uvm27m.sh` CTORTOTAL / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |

**0 movers**: all 7 UVM-4 rows stay `CMP_NOTEQUAL`, and the `r10uvm28a`
element head is **unchanged on all four** (still the `uvm_printer::print_field`
binding MISS on three of them and `uvm_field_flag_t` on BuildUVMPkg) — recorded
honestly. Master gates: goldens **23/23**; u2r testflags (731 rows) diff
**EMPTY** vs `results/gate_uhdm2rtlil.csv` (679/50/2); Surelog both modes
(1589 rows) whole-row diff **EMPTY** incl. the DUMP column vs
`results/golden_surelog.csv` (default 465/284/25/15/5, testflags 461/…),
`SLANG_REJECT` membership unchanged, every canary held.

Build the probes with the **STATIC** UHDM libs:

    g++ -std=c++20 -O2 tools/probe/r10uvm31io.cpp -o /tmp/r10uvm31io \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SLANG_UHDM=<build> R10IO=/tmp/r10uvm31io \
      tools/probe/r10uvm31run.sh tools/probe/r10uvm31repro/t41b
    R10IO=/tmp/r10uvm30io tools/probe/r10uvm31m.sh <sweep workdir>   # the metric

`r10uvm31run.sh` writes **only** to `/tmp/r10uvm31arm/<arm>/`; it never creates
an `out/` directory inside the repo tree.

---

## 0. The probes this pass added

* **`r10uvm31pair.py`** — joins two `r10uvm30io` censuses **by row key** and
  classifies the residue by PAIR CLASS: `ts/KIND`, `ts/NAME`, `ts/INST`, plus a
  population report and per-class examples. `IOTOTAL2` is a raw `diff` line
  count: it doubles every pair and orders nothing. This is what made the
  ranking below possible, and it is a two-minute run.
* **`r10uvm31io`** — `r10uvm30io` plus **typespec object identity** (`ts#<n>`,
  a dense per-file index) and an `--objects` mode listing every DISTINCT
  actual typespec with its kind/name/instance and a USE COUNT. A per-row
  census cannot tell "1197 wrong stamps" from "one shared object seen 1197
  times", and the two have completely different fixes — on SeqDriver it is
  the second (golden has SIX `uvm_hdl_path_slice` objects where we have TWO).
* **`r10uvm31m.sh`** — the pair census as a UVM-4 metric (`PAIRTOTAL`).

## 1. The law

### § oobParamClassTypeParamFormalUnsupported31

> An **out-of-body definition** of a method of a class that has **type
> parameters** is compiled in the PACKAGE's scope, where those parameters are
> not visible: a formal written as a bare parameter name falls through
> Surelog's `CompileType` catch-all to an **`unsupported_typespec` named as
> written**, instanced at the package the CLASS is declared in.

The catch-all itself is not new — `TypeEmit`'s covergroup-handle and
cover-cross arms already model it ("an unsupported_typespec carrying the
WRITTEN type name"). What is new is that an out-of-body definition reaches it.

The discriminator is **exactly** out-of-body-ness, and golden proves it in one
place: the elaborated `uvm_pkg` lists `uvm_sequencer::item_done` **twice** —

    ELABPKG uvm_pkg::uvm_sequencer::item_done io[0] 'item'
        class_typespec 'uvm_sequence_item'            <- the PROTOTYPE listing
    ELABPKG uvm_pkg::uvm_sequencer::item_done io[0] 'item'
        unsupported_typespec 'RSP' @uvm_pkg           <- the DEFINITION listing

and we already agreed with the first line before this pass.

Every cell read BOTH directions off `t41b`:

| written, in an out-of-body definition | golden |
|---|---|
| `seq31 #(type REQ=ven_t)::e_req(input REQ t)` | **`unsupported_typespec 'REQ'`** |
| `seqc31 #(type REQ=base31)::e_creq(input REQ t)` (CLASS default) | **`unsupported_typespec 'REQ'`** |
| `e_mixed(input lit_t a, input REQ t)` | `lit_t` RESOLVED, `REQ` **unsupported** |
| `e_deflt(input REQ t = null)` | **unsupported**, and it KEEPS its default |
| `e_concrete(input lit_t a)` | resolved |
| in-body `i_req(input REQ t)` (not out-of-body) | resolved |
| `plainx31::e_plain(input ven_t a)` (class NOT parameterised) | resolved |
| `vparam31 #(int W)::e_w(input logic [W-1:0] a)` (VALUE parameter) | resolved |
| in-class `pure virtual pv_cls(PT s)` in a parameterised class | resolved |

The **instance** is the package the class is DECLARED in, not the one the
listing sits in: the import COPIES (`DEFPKG adpcm_pkg::::uvm_sequencer::put`,
and `p31a`/`p31b`'s copies in the arm) still read `@uvm_pkg` / `@p31v`. That
is 20 of the law's 210 rows and needed its own pointer (`oobDeclPkg31`),
because `oobHomePkg` deliberately names the CLONE target in a package clone
pass. Measuring the law without it read 190/210 — the same
**two-pointer** shape Earlgrey pass 16 recorded.

Reach: **210 io_decl rows**, all four UVM-4 tests, every view — every
`uvm_sequencer` REQ/RSP method (`get`, `get_next_item`, `peek`, `put`,
`item_done`, `item_done_trigger`, `m_last_req_push_front`, …).
`IOTOTAL2` 3509 -> 3089 is exactly 210 x 2.

Implementation: `TaskFuncEmit.cpp`, one new first arm in the io_decl typespec
if-chain plus the `oobClassTypeParamName31` lambda. The predicate is a scope
lookup, not a type query: the formal's `NamedType`/`IdentifierName` text is
looked up in the CLASS scope and must resolve to a `TypeParameter`.

## 2. What the pass deliberately did NOT model (measured, both directions)

* **A typedef OF a type parameter** (`typedef REQ this_r_t;` used as a formal).
  `t41b`: unsupported in the import COPIES of the definition, RESOLVED in the
  declaring package's own listing — an asymmetry no predicate at this site can
  express. Reach in UVM: 0 rows directly, but see `this_rsp_type` in §3.
* **`uvm_resource_types::rsrc_q_t`** (21 rows) — a SCOPED name into another
  class, a different catch-all.
* **`STRUCTURE` / `NODE`** (12 rows) — `uvm_structure_proxy #(type STRUCTURE)`'s
  and `uvm_visitor #(type NODE)`'s **pure virtual** formals as listed under a
  DERIVED class. `t41b`'s `pv31 #(type PT)` refutes the obvious reading: an
  in-class pure virtual in a parameterised class that nobody extends RESOLVES.
  The key is the derived class's flattened listing, not pure-virtual-ness.

## 3. RANKED for pass 32 — the pair census, post-patch (rows, not IOTOTAL2)

Run `R10IO=/tmp/r10uvm30io tools/probe/r10uvm31m.sh <workdir>`; the table is
`scratchpad roll2` over the four `.g.io`/`.o.io` pairs.

1. **`INST` `enum_typespec` pkg-vs-pkg — 1148 rows**, SeqDriver only, and 75%
   of everything left. Golden `@adpcm_pkg` where we say `@uvm_pkg`. `t41a`/`t41b`
   reproduce it at small scale and `r10uvm31io --objects` explains it: an
   enum/struct typedef's typespec is **one SHARED object per (view, subroutine
   copy) group**, and its `vpiInstance` is **LAST-WRITER-WINS over the whole
   compile** — `t41b` has TWO importers of `p31v` and the single `ven_t` object
   reads `@p31b`, the LAST one, from every view including `p31a`'s own
   function. A **vector** typedef is the opposite: it gets a per-declaration
   CLONE whose instance is the typedef's HOME package everywhere (`lit_t` is
   `@p31v` even in `p31a::a_lit`, where we stamp `@p31a` — that mirror is the
   7-row `INST logic_typespec` class). Both are pure Surelog object-lifetime
   artifacts; decide deliberately whether to emulate them before writing code.
2. **`NAME` `logic_typespec` qual — 76 rows**, all four tests, and the cheapest
   real law left: golden names `uvm_pkg::uvm_hdl_data_t` where we say
   `uvm_hdl_data_t`, and **every** such subroutine is a **DPI IMPORT**. `t41b`
   §(e) settles all three cells: a DPI import in its declaring package names a
   vector typedef formal **package-qualified** (`p31v::lit_t`); the same import
   with an ENUM typedef formal gets `unsupported_typespec 'ven_t'` (that is the
   8-row `KIND unsupported<-logic_typespec` class's sibling); the IMPORT COPY of
   a DPI import degrades every formal to `unsupported_typespec` named as
   written; and a plain package function with the identical formals is the
   control and RESOLVES on both sides.
3. **`NAME` `enum_typespec` empty-ours — 64 rows**, all four tests:
   `uvm_pkg::uvm_tlm_phase_e` vs our EMPTY name. `t41b` reproduces it as
   `ELABPKG p31v::seq31::e_req` -> golden `enum_typespec 'p31v::ven_t'@p31b`,
   ours `enum_typespec ''` — a type-parameter default that is a typedef, in the
   specialization's class listing, arrives at us unnamed.
4. **`NAME` `int_typespec` other — 48 rows**: `this_rsp_type` where we say
   `this_imp_type`/`this_req_type`. `t41b` §(c) settles it — a parameterised
   class holds **ONE `int_typespec` for the whole listing**, named after the
   LAST int-resolving typedef of a type parameter declared in it, and the
   formals written as the PARAMETERS (`IMP`, `REQ_IMP`) point at that same
   object; a group of one (`shortint`, a class) keeps its own name.
5. **`NAME` `class_typespec` other 55 + qual 8**, `INST class_typespec`
   13+10+3, `INST struct_typespec` 29 — and the unchanged smalls from pass 30
   (BuildUVMPkg's `tf 2` `uvm_reg_map::ceil`, `r10uvm23m` 36, `t36b`, `t33d`,
   hier_path root-degradation) and the pass-30 ranked items this pass did not
   touch: the 5910 binding keys (still the element HEAD on all four) and the
   unqualified-parameter FOLD.

## 4. Method notes

* **The pair census paid for itself in one run.** `IOTOTAL2` said "3509, mostly
  SeqDriver". The join by row key said "1148 of it is one field on one test,
  and 210 of it is one structural law on all four" — and only the second is
  worth a patch. A metric that cannot be grouped cannot be ranked.
* **Census the OBJECTS, not only the rows.** `r10uvm31io --objects` is what
  turned SeqDriver's 1197 `INST` rows from "1197 wrong stamps" into "two shared
  objects with the wrong last writer", which is the difference between a
  patchable law and an emulation project.
* **Write the control in the same breath as the cell.** `t41b`'s
  `plainx31` / `vparam31` / in-body `i_req` cells cost three lines each and are
  the whole reason the predicate is `oob && type-parameter` and not something
  wider that a corpus gate would have caught much later, or not at all.
