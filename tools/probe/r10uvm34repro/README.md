# r10uvm34 — UVM pass 34

Pass 33's ranked list put `this_type` first (58 rows, 42%) and the three
"probably cheapest after it" families second, third and fourth.  This pass took
**the three cheap ones plus a fourth nobody had ranked**, because one purpose-
built arm (`t46a`) reads all of them off ONE golden — and because the first
thing `t46a` said about `this_type` is that its remaining diff is a single
field on a single object, which is a pass of its own, not a rider.

| metric | HEAD 03bca95 | this pass |
|---|---|---|
| `r10uvm31m.sh` pair census (`PAIRTOTAL`) | **137** | **68** (-50%) |
| — BuildUVMPkg / Scoreboard / SeqDriver / SimpleUVM | 18 / 33 / 51 / 35 | **3 / 15 / 33 / 17** |
| `r10uvm30iom.sh` (`IOTOTAL2`) | **277** | **139** (-50%) |
| — per test | 39 / 66 / 102 / 70 | 9 / 30 / 66 / 34 |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm28m.sh` `BINDTOTAL` | 5910 | **5910** (held, 1979/3931) |
| `r10uvm27m.sh` CTORTOTAL / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL` and the `r10uvm28a`
element head is unchanged (still `uvm_printer::print_field` on SeqDriver /
Scoreboard / SimpleUVM and `uvm_field_flag_t` on BuildUVMPkg).

Reproduce:

    g++ -std=c++20 -O2 tools/probe/r10uvm32io.cpp -o /tmp/r10uvm32io \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SLANG_UHDM=<build> R10IO=/tmp/r10uvm32io OUTROOT=/tmp/r10uvm34arm \
      tools/probe/r10uvm31run.sh tools/probe/r10uvm34repro/t46a

`r10uvm34ti` is the new probe (see §3).

---

## 0. The arm

**`t46a`** — one 175-line source, four shapes, every cell with its control,
and **exactly ONE importer** (`q46`), because pass 33 learned that a
three-importer arm masks a one-importer bug:

* **(A)** seven package typedefs over one class `el46` — associative, queue,
  dynamic, fixed-unpacked, associative-of-STRUCT, associative-of-INT and the
  plain class alias — each used as a formal, each with the directly-written
  control (`c_map(ref el46 m[string])`) beside it.
* **(B)** a class used as a NAMESPACE (`ns46`, `nsx46`) holding twelve
  typedefs of every target shape, each written as `C::t` in a formal; plus a
  parameterised base (`base46 #(type NODE46)`, `basei46 #(type IP46=int)`)
  and derived classes that write the base's parameter as a formal, with
  `d_cls(el46)` / `di_ctl(int)` as controls and `ns46use46::e_scq(nsq46_t)` —
  an ordinary INHERITED typedef — as the control for "inheritance is not the
  trigger".
* **(C)** `pv46`, seven `pure virtual` prototypes (queue, string queue, fixed
  unpacked, dynamic, associative, `[$][$]`, plain int) each with the same
  formal on a DEFINED method.
* **(D)** `this_type` in three shapes — the class that declares it
  (`self46`), a derived class that only inherits it (`sub46`), and a plain
  class (`other46`) — cells only, see §3.

## 1. The laws

### § pureVirtIoRanges34

> A `pure virtual` prototype's formal carries the SAME io_decl **Ranges** a
> defined method's does.

§ pureVirtIoDecls30 gave the prototype its `io_decl`s (a 107-row deficit) but
built them from a hand-written mini-path that never emitted the ranges.  `t46a`
reads it in one line — golden gives `p_str(output string q[$])` the same
`[0:$]` its control `n_str` gets, and the same for the fixed-unpacked, dynamic,
associative and `[$][$]` cells.

Implementation: the four range arms (unpacked / dynamic / queue /
§ assocIoRange9 associative) move out of the io_decl loop into one
`emitIoRanges34` lambda and are called from both sites.  The instance the
associative index typespec takes is `nullptr` from the prototype arm — exactly
what the ordinary path computes for an in-class method.

Reach: **16 rows, 4 on every UVM-4 test** — `uvm_report_server::get_id_set`,
`get_severity_set`, `uvm_reg_transaction_order_policy::order` and
`uvm_structure_proxy::get_immediate_children`, every one of them a
`pure virtual` with a queue formal.  Nobody had ranked this family: the pair
census showed it as four one-row `ts/OTHER` classes whose kind+name+instance
were IDENTICAL on both sides, because the projection puts `iorng=` in the same
column as the typespec.

### § pkgContainerTdFormalListing34

> A package typedef whose target is a **CONTAINER of a class** binds the
> package's typedef LISTING object, exactly as a class ALIAS does — the
> § tdListingFormalAsWritten33 (b) rule, one container over.

`typedef uvm_port_component_base uvm_port_list[string];` /
`get_connected_to(ref uvm_port_list list)`: golden
`class_typespec 'uvm_pkg::uvm_port_list'@uvm_pkg`, ours `'uvm_port_component_base'`
— we resolve through the alias and name the ELEMENT class, and we mint a fresh
object per declaration where golden shares one.  `t46a` shows all four
container kinds behave identically (associative, queue, dynamic, fixed
unpacked) and that a container over a STRUCT or an INT is a **different object
kind** in golden (`array_typespec 'p46::smap46_t'@q46`,
`array_typespec 'imap46_t'@p46!top`) — deliberately left, no UVM reach.

Reach: **20 rows** on all four tests.

### § baseClassTypeParamFormalUnsupported34

> A formal written as a TYPE PARAMETER the class does not itself declare — one
> it only INHERITS from a parameterised base — degrades to an
> `unsupported_typespec` NAMED AS WRITTEN, with NO `vpiInstance`, its own
> object per declaration.

The same catch-all § oobParamClassTypeParamFormalUnsupported31 found for an
out-of-body definition, one scope over.  `t46a` pins it on the SPELLING, not
on the resolved type: `deri46 extends basei46 #(int)` writing
`di_node(IP46 n)` degrades where `di_ctl(int n)` does not, and an ordinary
INHERITED typedef (`ns46use46::e_scq(nsq46_t q)`) resolves normally.

Implementation note that cost a build: slang's derived-class scope answers
`find("NODE46")` with the BASE's own `TypeParameterSymbol` (not a
`TransparentMemberSymbol` wrapper, which was the first guess and measured
zero).  The discriminator is `getParentScope() != &body`.

Reach: **12 rows**, three on every test —
`uvm_component_proxy::get_immediate_children`'s two `STRUCTURE` formals and
`uvm_component_name_check_visitor::visit`'s `NODE`, parameters of
`uvm_structure_proxy` / `uvm_visitor`.

### § classScopedTdFormalUnsupported34

> A formal written as a typedef reached through a **CLASS SCOPE**
> (`uvm_resource_types::rsrc_q_t`) keeps its written text and degrades to an
> `unsupported_typespec` — exactly when that typedef's **WRITTEN TARGET is
> itself a NAME**.  A typedef of a type declared IN PLACE resolves, named by
> its own simple name, array dimensions included.

Twelve cells, all in one class, all off one golden:

| written | golden |
|---|---|
| `typedef el46 nsq46_t;` | `unsupported_typespec 'ns46::nsq46_t'` |
| `typedef st46_t nss46_t;` | `unsupported_typespec 'nsx46::nss46_t'` |
| `typedef el46 nsc46_t[string];` | `unsupported_typespec 'nsx46::nsc46_t'` |
| `typedef el46 nsl46_t[$];` | `unsupported_typespec 'nsx46::nsl46_t'` |
| `typedef int nsi46_t;` | `int_typespec 'nsi46_t'` |
| `typedef enum int {…} nse46_t;` | `enum_typespec 'nse46_t'` |
| `typedef logic [7:0] nsv46_t;` | `logic_typespec 'nsv46_t'` |
| `typedef string nst46_t;` | `string_typespec 'nst46_t'` |
| `typedef struct packed {…} nsp46_t;` | `struct_typespec 'nsp46_t'` |
| `typedef struct {…} nsu46_t;` | `struct_typespec 'nsu46_t'` |
| `typedef int nsm46_t[string];` | `array_typespec 'nsm46_t'` |
| `typedef int nsn46_t[4];` | `array_typespec 'nsn46_t'` |

and the PACKAGE-scoped control says the `::` alone is not the trigger:
`q46use::qc_pkg(p46::acls46_t)` binds the ordinary shared listing object.

**The first reading of these cells was wrong and the corpus said so.**  With
only the first eight cells written, "class / struct / container degrade,
scalar / enum / string resolve" fits every one of them — and running it
inverted a real UVM row: `uvm_resource_base::init_access_record`, whose
`uvm_resource_types::access_t` is an unpacked STRUCT that golden RESOLVES.
Cells (i)–(l) were written afterwards to hold the corrected predicate, and
they separate `typedef st46_t nss46_t` (a name → degrade) from
`typedef struct {…} nsu46_t` (declared in place → resolve), which no cell
written before the regression could.

Reach: **21 rows**, 5–6 on every test.

### The pure-virtual arm takes all three typespec laws

`uvm_port_component_base::get_connected_to` is a `pure virtual`, and it is 4 of
§ pkgContainerTdFormalListing34's 20 rows.  The prototype arm therefore runs
the two unsupported predicates and the listing bind before falling back to
`makeTypespec` — the prototype is not a different compile, it is the same
declaration without a body.  (This is why the listing bind was lifted out of
the io_decl if-chain into a named `writtenPkgTdListingTs34`.)

## 2. What this pass did NOT model (measured, recorded)

* **`this_type`** — the whole remaining 58 rows.  See §3.
* **A container typedef over a STRUCT or a BUILTIN** used as a formal:
  golden binds an `array_typespec` listing object (`t46a` `a_sm`, `a_im`);
  0 rows in UVM.
* **The IMPORTING package's spelling of every one of these laws** (`t46a`'s
  four `q46use` cells): `writtenPkgTdAlias33`'s and
  `classScopedUnsupName34`'s name lookup walks enclosing scopes with
  `Scope::find`, which does not resolve a WILDCARD IMPORT, so a formal written
  in `q46` as `amap46_t` or `ns46::nsq46_t` misses both laws.  4 rows on the
  arm, **0 on the UVM-4** (every target row is inside `uvm_pkg` itself).  This
  is a pre-existing limit of the pass-33 lambda, not new.
* **The LAW-S bare-copy home instance** — unchanged at 7 rows
  (`uvm_integral_t` INST on SeqDriver); `t43a` is still its arm and the whole
  corpus is still in its blast radius.
* `t46a`'s three small residues with no UVM reach: `e_scq`'s `@p46!top`
  instance and `b_scv`'s (the same LAW-S family), and `b_sct`'s missing
  `'nst46_t'` name on a string typedef.

## 3. RANKED for pass 35 (post-patch pair census, rows)

Residue **68 = 3 / 15 / 33 / 17**, and it is now ONE family plus two smalls.

1. **`this_type` — 58 rows (85% of what is left).**  `r10uvm34ti` (the new
   probe: it prints the FULL identity of a typespec's `vpiInstance`, which
   r10uvm30io cannot — that probe renders a null `Instance()` and an
   `Instance()` whose `VpiName` is EMPTY identically) settles what the four
   shapes are:
   * golden holds **three** `this_type` objects per test, at
     `uvm_algorithmic_comparator.svh:74`, `uvm_port_base.svh:199` and
     `uvm_sequence_library.svh:330`.  The first is shared by **ten to
     seventeen** formals across UNRELATED classes — every socket
     `connect(this_type provider)` and `uvm_sequence_library::m_check` — i.e.
     Surelog resolves a formal's written `this_type` against a scope table in
     which every class-scope `typedef … this_type` collapses onto ONE entry,
     and only a class that DECLARES `this_type` itself gets its own.
   * that object's `vpiInstance` is **the last importer of `uvm_pkg`**:
     `adpcm_pkg` on SeqDriver, **the `design` object** (`VpiName` empty,
     `VpiFullName` `work@my_scoreboard_unit_test`) on Scoreboard and SimpleUVM
     where the import is at `$unit` scope, and **null** on BuildUVMPkg where
     nobody imports.  `t46a`'s (D) cells reproduce the package case exactly:
     golden `class_typespec 'q46::this_type'@q46`, ours the right NAME and no
     instance — so on the arm the whole family is ONE missing stamp.
   * the two residual KIND rows are the import COPY
     (`DEFPKG adpcm_pkg::::uvm_sequence_library::m_check`), where golden writes
     `unsupported_typespec 'this_type'@uvm_pkg!top`.
   Start from `t46a` (D) plus a second importer cell, and check whether the
   class-scope typedef clone has the § pkgImportAggCloneLastWriter32 owner
   record at all — the naming already carries the importer prefix, so only the
   instance is missing.
2. **The LAW-S bare-copy home instance — 7 rows** (SeqDriver
   `uvm_integral_t`).  Unchanged rank, unchanged warning: whole-corpus blast
   radius, `t43a` is the arm, wants the full dump-byte verifier.
3. **`UVM_SEQ_ARB_TYPE` — 3 rows** (SeqDriver only): golden
   `enum_typespec 'UVM_SEQ_ARB_TYPE'@uvm_pkg` where we write
   `'uvm_pkg::UVM_SEQ_ARB_TYPE'` in the import copies, and the mirror-image
   INST row in `DEFPKG uvm_pkg`.  A naming asymmetry between the def listing
   and the import copy; cheapest thing left after (1).
4. Then the io_decl typespec family is DONE (`IOTOTAL2` 3509 at pass 30 ->
   139) and the next pass should weigh the **5910 binding keys** (still the
   element HEAD on all four; SeqDriver holds 3171 of the misses) against the
   `INITTOTAL`-52 remainder and the smalls.

## 4. Method notes

* **A pair class whose two sides PRINT identically is a field the projection
  flattens, not a mystery.**  Pass 33 ranked `ts/OTHER` first and said to read
  it with `--objects`.  Half of it (the 4 rows/test) was `iorng=`, sitting in
  the same census column as the typespec; the other half was a null
  `Instance()` versus an `Instance()` with an EMPTY name, which every probe
  from pass 30 on renders the same way.  Neither needed a law — one needed a
  new *projection* (`r10uvm34ti`) and the other needed reading the raw row.
* **Run the wrong law once on the real corpus — again.**  Pass 33 wrote that
  note; this pass earned it a second time, and in the cheapest possible way:
  eight synthetic cells all agreed on a predicate that one UVM row
  (`access_t`) inverted, and the corrected predicate reads off the WRITTEN
  SYNTAX rather than the resolved type — which is, in hindsight, exactly the
  form every § …AsWritten law in this campaign has taken.
* **The controls are what make one arm serve four laws.**  `t46a` has 55 io
  rows of which only ~20 are targets; every other row is a control, and three
  of them (`di_ctl`, `e_scq`, `qc_pkg`) are the ones that stopped a predicate
  from being written too wide.
* **Check whether the second emission site exists before measuring reach.**
  The `uvm_port_list` family looked like 20 rows through the io_decl chain and
  landed 16 — the other 4 are on `pure virtual` prototypes, which have their
  own hand-written formal path.  Two sites, one law: the classic
  MINT-SITE masking this campaign keeps re-discovering.
