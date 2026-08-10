# r10uvm33 — UVM pass 33

Pass 32's ranked **#1** was "the DPI-import formal name — 76 rows, all four
tests, FULLY DECODED, what is missing is only the *site*", and its ranked **#3**
was "`struct_typespec uvm_hdl_path_slice` INST — 20 rows; law 2 over-firing or
law 1 missing a second object; `r10uvm32td` + `r10uvm32io --objects` settles it
in ONE run, do it first as a 10-minute check."

Both were exactly as advertised.  The 10-minute check took one run and named a
**one-branch hole** in pass 32's own law; the DPI law needed a purpose-built
2x2 (`t43a`) that turned "make LAW S skip DPI" into a precise emission-site
rule with four NOT cells.  Then pass 32's ranked **#2** (the socket formals
whose type-parameter default arrives unnamed) turned out to be the SAME
question one spelling over, and a second arm (`t44a`) collapsed it and the
`uvm_tlm_time` family together.  Then pass 32's ranked **#4** — the
`int_typespec 'this_rsp_type'` LAST-WINS name, decoded at pass 31 and never
implemented — turned out to have been decoded **wrong**, and a fifth arm
(`t45a`) replaced the model and closed it.  Five laws, five arms,
**PAIRTOTAL 397 -> 137 (-65%)**.

| metric | HEAD 27242d3 | this pass |
|---|---|---|
| `r10uvm31m.sh` pair census (`PAIRTOTAL`) | **397** | **137** (-65%) |
| — BuildUVMPkg / Scoreboard / SeqDriver / SimpleUVM | 80 / 76 / 155 / 86 | **18 / 33 / 51 / 35** |
| `r10uvm30iom.sh` (`IOTOTAL2`) | **797** | **277** (-65%) |
| — per test | 163 / 152 / 310 / 172 | 39 / 66 / 102 / 70 |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm28m.sh` `BINDTOTAL` | 5910 | **5910** (held, 1979/3931) |
| `r10uvm27m.sh` CTORTOTAL / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL` and the `r10uvm28a`
element head is unchanged on all four (still `uvm_printer::print_field` on
three and `uvm_field_flag_t` on BuildUVMPkg) — recorded honestly.

Master gates on the worktree binary: goldens **23/23**; u2r testflags (731
tests) diff **EMPTY** vs `results/gate_uhdm2rtlil.csv` (679/50/2); Surelog
**both** modes (1589 rows) whole-row diff **EMPTY** including the DUMP column
vs `results/golden_surelog.csv`, `SLANG_REJECT` membership unchanged.  And
because every law here can reach non-UVM designs, the CSV-blind check pass 32
introduced was run again: `uhdm-dump` of OUR output, a pristine-HEAD binary vs
this one, for the **11 non-UVM `CMP_NOTEQUAL` tests in both modes** —
**20/20 dumpdiff = 0** (the dump's first line is its own `<path>:` banner and
is dropped).  Every gate above was re-run **whole** after `t45a`'s law landed.

Reproduce:

    g++ -std=c++20 -O2 tools/probe/r10uvm32io.cpp -o /tmp/r10uvm32io \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SLANG_UHDM=<build> R10IO=/tmp/r10uvm32io OUTROOT=/tmp/r10uvm33arm \
      tools/probe/r10uvm31run.sh tools/probe/r10uvm33repro/t43a   # (t44a, t45a)
    /tmp/r10uvm32td /tmp/r10uvm33arm/t43a/slpp_all/surelog.uhdm   # golden
    /tmp/r10uvm32td /tmp/r10uvm33arm/t43a/ours.uhdm               # ours

---

## 0. The arm this pass added

**`t43a`** — one 110-line source that pins the DPI-import formal in every cell
a site rule needs, each with its plain-SV control written in the same breath:

* `p43n` — a package with a DPI import and a vector typedef that **NOBODY
  imports**.  This is the cell that names the POINTER: with no importer there
  is no second-generation listing object, and golden still binds a listing
  object (`p43n::n_t`@p43n**!top**), so the rule is "the ELABORATED home
  listing", not "the last importer's copy".
* `p43v` — ten DPI shapes over six typedefs: `context` and plain, `function`
  and `task`, `input`/`output`, a `logic` vector, a `bit` vector, an UNRANGED
  `int`, an ALIAS-OF-ALIAS, an `enum` and a packed `struct`, plus a DPI return
  type; and `pv_lit`/`pv_task`/`pv_en`/`pv_st`/`pv_ret` as the controls.
* `p43x` — a DPI import over a typedef imported from ANOTHER package.
* `p43a`/`p43b` — two more importers, so the import-COPY half has cells.
* `top43a` — a DPI import declared inside a MODULE, and a `$unit`-scope one.

**`t44a`** — the TYPE-PARAMETER DEFAULT and the CLASS-ALIAS typedef as a
formal, six type-parameter kinds (`enum`/`struct`/vector/class/class-ALIAS/
`int`) each with the directly-written control beside it, plus the same
class-alias written directly in a plain class, in a package function and in a
`typedef`'d specialization.

**`t45a`** — the class-scope TYPE-PARAMETER typespec GROUP, eight cells each
with its control: parameters declared out of order (`ord45`), a group of ONE
with all three formal spellings (`one45`), a PLAIN `typedef int` sitting
between two parameter typedefs (`mix45`), a `shortint` group and a CLASS group
(`kind45`), `int` and `integer` in one class (`two45`), an explicit
specialization (`spec45`), a same-typed parameter with NO typedef (`nod45`),
and a derived class over a parameterised base (`der45`).  **Golden and ours
are now byte-identical over the whole arm** — every `ts#` index included, so
the OBJECT-SHARING is right and not just the names.

## 1. The laws

### § dpiImportFormalListingTd33

> A **DPI IMPORT**'s formal typed by a typedef declared in the **SAME package**
> binds that package's **ELABORATED typedef LISTING object** — the qualified
> `p::t` one — in **every** view, where the identical formal of a plain SV
> subroutine takes a fresh per-declaration BARE clone.

`t43a` golden, the two rows side by side in p43v's own DEF listing:

    DEFPKG p43v::::dv_lit io[1] 'value' logic_typespec 'p43v::v_t' @p43b  ts#5
    DEFPKG p43v::::pv_lit io[1] 'value' logic_typespec 'v_t'      @p43v  ts#21

and `r10uvm32td` says `ts#5` is the object listed by
`DEFPKG:p43x,DEFPKG:p43a,DEFPKG:p43b,ELABPKG:p43v,…` — the second-generation
import clone whose `vpiInstance` the LAST importer owns
(§ pkgImportAggCloneLastWriter32).  Our sharing graph was **already identical
to golden's**; only which object the io_decl pointed at differed.

The cells, all read off the one golden:

| written | golden |
|---|---|
| `import "DPI-C" context function int dv_lit(string, v_t)` | the **listing** object, qualified |
| the same **without** `context` (`dv_np`) | identical — `context` is irrelevant |
| `import "DPI-C" context task dv_task(...)` | identical — task-vs-function is irrelevant |
| `output`/`inout` formals (`dv_out`) | identical |
| a `bit` typedef, an UNRANGED `int` typedef, an ALIAS-OF-ALIAS | identical, each its own listing object |
| a plain SV `function`/`task` with the same formal | a **bare per-declaration clone** |
| a typedef imported from ANOTHER package (`p43x::dx_lit`) | a bare clone — **no law** |
| a DPI import inside a MODULE (`dm_lit`) | a bare clone — **no law** |
| an `enum`/`struct` typedef (`dv_en`, `dv_st`) | `unsupported_typespec` named as written **in the DEF view of its own package only** — the ELAB view binds the shared listing object.  Not modelled (see §2). |

**Why UVM's own counter-example is the proof.**  Golden leaves
`uvm_hdl_force_time`'s `uvm_hdl_data_t value` **bare** while
`uvm_hdl_deposit`/`force`/`read`/`release_and_read` — the same formal, the same
package, adjacent lines of `uvm_hdl.svh` — are all qualified.  The one
structural difference is that `uvm_hdl_force_time` is a plain SV **task** and
the other four are DPI imports.  Any predicate wider than DPI-ness would have
inverted that row, and a corpus gate would never have said so.

Implementation: `TaskFuncEmit.cpp`, a new FIRST arm in the io_decl typespec
if-chain (`sub.flags.has(MethodFlags::DPIImport)` + `pkgHomedTdAlias18` + the
typedef's home package == the subroutine's).  Two details earn their lines:

* **No `stampPkgFormalTs`.**  That object's `vpiInstance` belongs to the
  listing law; re-stamping it here is exactly the inversion
  § importCopyAggFormalOwnCopy32 had to undo last pass.
* **LAW S must skip it** (`dpiListingIoRt33`).  Pass 32 measured a DPI *guard*
  inside LAW S as a strict no-op and reverted it, correctly — but the reason it
  was a no-op (the io_decl held a clone, not a listing object) stops being true
  the moment this arm binds the real thing, and LAW S would rebind it straight
  back to a bare copy.  The note pass 32 left at that arm is now the fix.
* The ELABORATED listing does not exist during the **DEF** pass (packages are
  emitted def-view first), so the def object is bound and the existing
  `pkgForeignTsTopFixups` drain re-points it — the same two-step a foreign
  package typedef already uses.

### § dpiImportCopyFormalUnsupported33 — the other half

> A wildcard/explicit **import COPY** of a DPI import degrades every
> **typedef** formal to an `unsupported_typespec` named as written, instanced
> at the ELABORATED home package.  Builtin-typed formals (`string path`) are
> untouched, and the copies of plain subroutines keep their clones and their
> shared aggregate listings.

    DEFPKG p43a::::dv_lit io[1] 'value' unsupported_typespec 'v_t'  @p43v!top
    DEFPKG p43a::::pv_lit io[1] 'value' logic_typespec       'v_t'  @p43v!top

Reach: the 8-row `KIND unsupported<-logic_typespec` class
(`DEFPKG adpcm_pkg::::uvm_hdl_deposit`, both package views).  The new
typespec joins `importCopyTsCollect`, so the ordinary clone fixup gives it the
elaborated home instance.

Together the two DPI arms are **PAIRTOTAL 397 -> 313** (84 rows: 76 NAME + 8
KIND, exactly the pass-32 prediction) and `IOTOTAL2` 797 -> 629.  The three
arms in order: **397 -> 313 -> 284 -> 197**.

### § pkgImportAggCloneLastWriter32, the CREATION cell (pass 33)

> Pass 32's record of "who listed this import clone last" was written only on
> the path where the clone **already exists**.  A STRUCT clone whose typedef
> has exactly **one** importer takes the creation path, which `continue`s
> early — so it was never recorded, and *neither* half of pass 32 fired for it.

The 10-minute check, one run of `r10uvm32td` + `r10uvm32io --objects` on
SeqDriver, settled pass 32's own open question ("law 2 over-firing, or law 1
missing a second object?") in four lines:

    golden  OBJ struct_typespec 'uvm_pkg::uvm_hdl_path_slice' inst=adpcm_pkg
                listings=DEFPKG:adpcm_pkg,ELABPKG:uvm_pkg,ELABPKG:adpcm_pkg,DEFMOD:,TOPMOD:work@top_tb
    ours    OBJ struct_typespec 'uvm_pkg::uvm_hdl_path_slice' inst=uvm_pkg
                listings=<identical>

Identical sharing graph, one field different: **law 1 missing an object**, not
law 2 over-firing.  Without the record the design-final stamp never runs AND
the wildcard subroutine-clone pass drags the shared object home instead of
taking law 2's private copy — which is why the observed instance was the
typedef's HOME package.

`t42a` and `t43a` both have THREE importers, so their second importer took the
already-exists path and **masked the hole entirely**; UVM has exactly one
(`adpcm_pkg` imports `uvm_pkg`).  The ENUM arm falls THROUGH to the record and
never had it.  One `if` before the struct arm's `continue`:
**PAIRTOTAL 313 -> 284**, SeqDriver 111 -> 82 (`uvm_hdl_path_slice` 20 +
`uvm_printer_row_info` 9).

### § tdListingFormalAsWritten33

> Surelog compiles a formal's **written type name** against the scope's
> data-type table, so the formal keeps the TYPEDEF it names.  We resolve the
> slang `Type`, which canonicalises two spellings away and loses the listing
> object with them:
> **(a)** a formal written as one of the class's own **TYPE PARAMETERS** is
> emitted exactly as if the parameter's ARGUMENT had been written directly, and
> **(b)** a formal written as a package **CLASS-ALIAS** typedef binds that
> alias's listing object, not the class it aliases.

`t44a` proves (a) by object identity, not by name: golden's `f_pe(PE p)` in
`tp44 #(type PE = e44_t)` binds the **same `ts#3`** as the directly-written
control `g_pe(e44_t p)`, and the same for `PS`/`s44_t` — where we minted an
anonymous `enum_typespec` (and, for the struct, an anonymous *`logic`*
typespec).  (b) reads off `fn_alias(alias44_t d)` / `h_alias` / `g_pa`:
golden `class_typespec 'p44::alias44_t'@p44!top`, ours `'base44'`.

Reach: `enum_typespec 'uvm_pkg::uvm_tlm_phase_e'` vs our EMPTY name, **15 rows
on every one of the four tests** (`uvm_tlm_if #(type P=uvm_tlm_phase_e)`'s
`nb_transport_fw`/`bw` and every socket that inherits them), plus
`class_typespec 'uvm_pkg::uvm_tlm_time'` vs our `'uvm_time'`
(`typedef uvm_time uvm_tlm_time;`, `tlm2/uvm_tlm_time.svh:210`), **23 rows** on
BuildUVMPkg.  `PAIRTOTAL` 284 -> **197**, and `t44a` goes from 21 diff lines to
**one**.

Two implementation notes:

* The name lookup walks **out of** the class scope: `h_alias(alias44_t d)`
  inside a class writes a name its enclosing PACKAGE declares.
* The kind test reads the **slang** type, not the UHDM object, because a
  package class-alias typedef has **no def listing at all** (`t44a`:
  `p44::alias44_t` is listed by `ELABPKG:p44` only) — in the def pass there is
  nothing yet to inspect, and that is precisely the case that must still
  register the deferred re-point.
* Only the aggregate/class kinds are bound.  A **vector** type-parameter
  default gets a per-declaration CLONE in golden, a different object from the
  control's (`t44a` `f_pv`: golden `logic_typespec 'v44_t'`, ours anonymous) —
  rebuilding a clone from a type the syntax does not name is a different job,
  and it is `t44a`'s single remaining diff line with no measured UVM reach.

### § classTypeParamTdGroupLastWins33c

> A class holds **ONE typespec per distinct RESOLVED TYPE among its own TYPE
> PARAMETERS THAT HAVE A TYPEDEF**.  Every formal written as one of those
> parameters, or as one of those typedefs, binds that single object, and its
> NAME is the typedef of the **LAST such parameter in PARAMETER-DECLARATION
> ORDER**.  A typedef that is not of a type parameter, a parameter with no
> typedef, and a formal written as the bare builtin each keep their own object.

Pass 31 decoded this off ONE cell (`t41b`'s `imp31`) and wrote it down as *"one
`int_typespec` for the whole listing, named after the LAST int-resolving
typedef"*.  Both halves of that sentence are wrong, and `t45a` says so in two
lines:

    // ord45 #(type A = int, type B = A, type C = A)
    //   typedef C c_t;   typedef A a_t;   typedef B b_t;   <- LAST TYPEDEF b_t
    ELABPKG p45::ord45::f_td  io[0..2] -> int_typespec 'c_t' ts#8   (golden)
    ELABPKG p45::ord45::f_par io[0..2] -> int_typespec 'c_t' ts#8   (golden)

`c_t` is the FIRST typedef declared and the typedef of the LAST PARAMETER.
`imp31` could not tell the two readings apart because its typedefs are written
in parameter order — and neither can UVM, which is why the pass-31 model would
have produced the right 48 rows for the wrong reason and then mis-fired on the
first out-of-order class in the corpus.

The second correction cost a measured regression and is the more valuable one.
Modelling "every parameter of the group's type" (the obvious reading of "one
typespec for the whole listing") **removed the 48 target rows and added 24 new
ones on BuildUVMPkg alone**: `uvm_master_imp #(REQ=int, RSP=int, IMP=int,
REQ_IMP=IMP, RSP_IMP=IMP)` has FIVE `int` parameters and only three typedefs,
and golden gives `get(output REQ t)`/`peek`/`put` their own **anonymous**
`int_typespec` while `new`'s three typedef-aliased parameters share the named
one.  `t45a` cell (H) (`nod45`) is that cell, written after the corpus taught
it: golden `n_td(na_t, nb_t)` -> one `int_typespec 'nb_t'`, `n_par(N q)` ->
`int_typespec ''`, its own object.

The rest of `t45a`, all read off one golden and all matching after the fix:

| cell | golden |
|---|---|
| `one45 #(type A=int)`, group of ONE | `g_par(A x)` binds the SAME object as `g_td(a1_t x)`, named `a1_t` |
| `g_raw(int x)` / `mix45::h_raw(int x)` | own anonymous object — the bare builtin is NOT in the group |
| `mix45`'s `typedef int m_plain_t` between two parameter typedefs | its own object, its own name — membership is type-parameter-ness, not the resolved type |
| `kind45` | a `shortint` group of two (`t_t` wins) and a CLASS group of two (`v_t` wins) — the law is not about `int` |
| `two45 #(A=int, B=integer, C=A)` | `x_t`/`z_t` share one `int_typespec 'z_t'`; `y_t` keeps its own `integer_typespec` — the key is the RESOLVED type |
| `spec45` | the group re-forms per SPECIALIZATION |
| `der45` | the derived class's own `int` formal is untouched |

Implementation: `TaskFuncEmit.cpp`, in three pieces — the group table built
once per listing from `body.members()` (parameters in declaration order, the
typedef→parameter link read off the **written syntax** because slang has
already canonicalised `typedef A a_t;` and `typedef int a_t;` to the same
type), a SHARE arm in the io_decl if-chain, and a NAME step just before
`io->Typespec`.  Three details earn their lines:

* The group key is the **canonical** type: `type B = A` hands back A's own
  type-parameter alias, and reading that as a distinct key is what made the
  first build fix only `one45` and leave `ord45` untouched.
* A parameter whose type is a **package typedef** is out (`pkgHomedTdAlias18`),
  and so are the aggregate kinds.  `t41b`'s `seqx31 #(type REQ = ven_t);
  typedef REQ this_r_t;` shows why: golden renames the PACKAGE's shared `ven_t`
  listing object to `p31v::this_r_t` for the whole compile (`p31a::a_ven` reads
  it too).  That is a real law, with a whole-corpus blast radius and a
  different owner (§ tdListingFormalAsWritten33) — nothing here may touch a
  package listing object.
* **In-body only.**  An out-of-body formal written as a type parameter is
  already owned by § oobParamClassTypeParamFormalUnsupported31 above.

## 2. What this pass did NOT model (measured, recorded)

* **The DEF-view AGGREGATE degradation.**  A DPI import's `enum`/`struct`
  typedef formal is `unsupported_typespec 'ven_t'@p43v` in the DEF view of its
  own package but the shared listing object in the ELAB view (`t43a`, both
  cells; pass 32 saw the same off `t41b`).  A view-asymmetric degradation with
  **zero** reach in UVM — 2 pairs on `t43a`, 0 on the UVM-4.
* **The LAW-S bare-copy HOME instance** — now `t43a`'s largest residue (24 of
  its 34 pairs) and the 7-row `INST logic_typespec uvm_integral_t` class on
  SeqDriver.  Golden's per-declaration bare copy of a package typedef carries
  the **home** package (`@p43v!top`) wherever we carry the *importing* package
  (`@p43a`/`@p43b`/`@p43x`), the module (nothing), or — since law 1 — the
  last-importer instance the copy was cloned from.  Stated as a law it is
  clean: *the bare copy's instance is the home package listing's own view*
  (def only inside the typedef's home DEF listing, elaborated everywhere
  else) — which is exactly `pkgTdOwnDefView`.  Deliberately NOT attempted this
  pass: it re-stamps EVERY package-typedef bare copy in the corpus (Earlgrey,
  rp32, jeras_union all live here) for 7 measured UVM rows, and the honest
  order is to land the two clean laws first.  `t43a` is already the arm for it.
* **`t43a`'s one aggregate copy row** (`DEFPKG p43x::::pv_st`, golden
  `@p43v!top` and ours `@p43b`) — the same "1 row of 24" pass 32 recorded on
  `t42a`, a formal reaching the io_decl typespec through a different arm.
* **The PACKAGE-typedef spelling of the group law** — `t41b`'s `this_r_t`
  (above).  Golden's rename of a package's shared listing object by a
  class-scope typedef of a type parameter is real and reaches `p31a::a_ven`,
  but its blast radius is every package typedef in the corpus.  Excluded by
  predicate, not by accident; `t41b` is the arm for it.
* **Two typedefs of the SAME parameter**, and a formal written as a type
  parameter of an *enclosing* generic class.  No cell, no measured reach; the
  code takes the later typedef and would decline the second, and both should
  get cells before anything depends on them.

## 3. RANKED for pass 34 (post-patch pair census, rows, not `IOTOTAL2`)

Residue 137 = 18 / 33 / 51 / 35.  `this_type` is now **42% of everything left**
and is the only cluster with double digits on more than one test; after four
passes on the io_decl typespec, `IOTOTAL2` is 277 from 3509 at pass 30, and the
pass after `this_type` should weigh the 5910 binding keys against what remains.

1. **`this_type` — 58 rows (42%), four shapes, one arm should settle all four.**
   `ts/OTHER` **11 rows** on Scoreboard and 11 on SimpleUVM: golden and ours
   print the same kind+name+inst, so the pair is in a field the census projects
   but the printout collapses — read it with `r10uvm32io --objects` FIRST, it is
   the cheapest thing in this list and the biggest single family;
   `ts/INST` **3 / 4 / 10+3 / 6** (`uvm_sequence_library::m_check`, golden
   `@adpcm_pkg` ours `@uvm_pkg`, plus a 3-row no-instance variant on SeqDriver)
   — still smells like the creation-path hole pass 33 fixed for structs, one
   level over on a CLASS typespec;
   `ts/NAME` **8 rows** on SeqDriver (`adpcm_pkg::this_type` vs our bare
   `this_type`) and `ts/KIND` 2 (`unsupported_typespec 'this_type'`).
   A `t46` over `typedef this_type` inside a parameterised class in an IMPORTED
   package, with ONE importer (pass 33's creation-path lesson), should read all
   four off one golden.
2. **`unsupported_typespec 'uvm_resource_types::rsrc_q_t'` — 21 rows**, 5-6 on
   every test (a SCOPED name into another class, pass 31 §2).  One catch-all
   predicate; `'STRUCTURE'`/`'NODE'` (3/test, 9 rows) is the same shape from
   pass 31 §2 and may share it.
3. **`class_typespec 'uvm_pkg::uvm_port_list'` — 20 rows**, 2 on BuildUVMPkg and
   6 on each of the other three, golden qualified-and-instanced where we name
   the ELEMENT class `uvm_port_component_base`.  `uvm_port_list` is
   `typedef uvm_port_base ... uvm_port_list[string]` — an ASSOCIATIVE-ARRAY
   typedef used as a formal, i.e. § tdListingFormalAsWritten33 one container
   over.  Probably the cheapest law left after (1).
4. **The LAW-S bare-copy home instance** (§2 above) — 7 rows on SeqDriver
   (`uvm_integral_t`) and `t43a`'s largest residue, but the whole corpus is in
   its blast radius; `t43a` is already the arm, and it wants a pass of its own
   with the full dump-byte verifier.
5. Unchanged from pass 32: the **5910 binding keys** (still the element HEAD on
   all four), the **unqualified-parameter FOLD** (t40a), the **INITTOTAL-52**
   remainder and the smalls (`r10uvm23m` 36, BuildUVMPkg `tf 2`, t36b, t33d,
   hier_path root-degradation).

## 4. Method notes

* **A reverted no-op is a decoded law with the wrong address.**  Pass 32 built
  the DPI guard, measured zero, reverted it and wrote down *why* it measured
  zero.  That note — "TaskFuncEmit's per-formal typedef-CLONE arms run first" —
  is the entire content of this pass's arm placement.  Reverting without the
  note would have cost pass 33 the same day.
* **The corpus's own counter-example beats a synthetic control.**  `t43a` has
  ten purpose-built cells, but the row that pins the predicate on DPI-ness is
  `uvm_hdl_force_time` — a plain task sitting in the middle of five DPI imports
  in the real source, which golden already treats differently.  Read the
  residue for rows that DON'T differ before writing the predicate.
* **"Cheapest first" was right, and it was cheap.**  Pass 32 ranked the struct
  INST family third and predicted the exact probe pair that would settle it.
  It took one run and produced the single highest-yield line of the patch
  (29 rows for one `if`).  Rank by *cost to decide*, not only by row count.
* **Prove a "binds the same object" law by OBJECT IDENTITY, not by name.**
  `t44a`'s decisive line is that golden's `f_pe(PE p)` and `g_pe(e44_t p)` are
  the same `ts#3`.  A name-only census would have said "golden names it
  `p44::e44_t`" and invited a rename, which is the one implementation that
  would have been wrong (Compare recurses `Instance()` from the object it
  actually holds).
* **A three-importer arm can MASK a one-importer bug.**  Both `t42a` and `t43a`
  were built to make "last writer" observable and therefore have three
  importers each — and that is precisely why neither of them reproduces the
  creation-path hole.  When a law is about *which* writer wins, keep a
  one-writer cell too.
* **A "fully decoded, never implemented" item is NOT decoded.**  Pass 32 ranked
  `this_rsp_type` fourth and called it settled by `t41b` §(c).  Both halves of
  that one-cell reading were wrong — the winner is the last PARAMETER's typedef,
  not the last typedef, and the group is the typedef-ALIASED parameters, not all
  of them.  `imp31` writes its typedefs in parameter order and gives every
  parameter a typedef, so it cannot separate either pair.  **A law decoded from
  one cell has as many readings as the cell has coincidences**; build the 2x2
  before believing the note, even when the note is your own.
* **The regression was the second cell.**  The wrong-but-plausible model
  measured PAIRTOTAL 197 -> 233: it took the 48 target rows AND added 84.  The
  +24 class on BuildUVMPkg named the missing predicate outright
  (`get(output REQ t)` — a parameter with no typedef), and `t45a` cell (H) was
  written afterwards to hold it.  Measuring the intermediate build was worth
  more than the arm: **run the wrong law once, on the real corpus, and read
  what it breaks.**
