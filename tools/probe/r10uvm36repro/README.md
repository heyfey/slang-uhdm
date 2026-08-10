# r10uvm36 — UVM pass 36

Pass 35 left a residue of **12 pairs, all on SeqDriver**, and called it "one
family in three spellings — inside a wildcard-import COPY a formal's typespec
is BARE and instanced at the HOME package, where we name it as the copy's own
package listing does and instance it at the importer".  That reading was
right, and all three spellings fell this pass.  **The io_decl typespec family
is CLOSED on all four UVM tests.**

| metric | HEAD e89d22c | this pass |
|---|---|---|
| `r10uvm31m.sh` pair census (`PAIRTOTAL`) | **12** | **0** |
| — BuildUVMPkg / Scoreboard / SeqDriver / SimpleUVM | 0 / 0 / 12 / 0 | **0 / 0 / 0 / 0** |
| `r10uvm30iom.sh` (`IOTOTAL2`) | 27 | **3** (-89%; all BuildUVMPkg, all POPULATION — § 4) |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm28m.sh` `BINDTOTAL` | 5910 | **5910** (held, 1979/3931) |
| `r10uvm27m.sh` CTORTOTAL / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL` and the `r10uvm28a`
element head is byte-identical pre/post on all four (still
`uvm_printer::print_field` on SeqDriver / Scoreboard / SimpleUVM,
`uvm_field_flag_t` on BuildUVMPkg).

Reproduce (probe: pass 35's `r10uvm35ti`, unchanged):

    g++ -std=c++20 -O2 tools/probe/r10uvm35ti.cpp -o /tmp/r10uvm36ti \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SL=$HOME/git-repos/Surelog/build/bin/surelog
    ( cd /tmp/a48 && $SL -parse -d uhdm tools/probe/r10uvm36repro/t48a/dut.sv )
    /tmp/r10uvm36ti /tmp/a48/slpp_all/surelog.uhdm --rows --name 48

---

## 0. The arms

Three cells, one per spelling.  Each carries its own CONTROL in the same
golden, because every one of these laws is a `NOT` away from re-owning a whole
corpus family.

* **`t48a`** — `home48` declares a ranged scalar typedef `w48_t` and a plain
  `int` one `u48_t`, plus a FREE FUNCTION taking each.  Two wildcard importers
  ANTI-SORTED against declaration order (`zz48` first, `aa48` second) plus a
  module importer.  Free functions (not class methods) so the clone bodies
  exist in the importers' DEF *and* ELAB listings — the def/top split pass 35's
  class cell could not show, because classes hang off top packages only.
* **`t48b`** — an enum typedef `de48_t` and an ALIAS OF IT `ae48_t`
  (`typedef de48_t ae48_t;`), each used as a formal of a free function, same
  two anti-sorted importers.  `de48_t` is the control that keeps § 2 from
  being written for every enum.
* **`t48c`** — a class `c50` with a class-scope `typedef c50 this_type;`, a
  method declared `extern static` and DEFINED OUT OF BODY taking
  `(k50_t key, this_type lib)`, and one wildcard importer.  `k50_t` (an
  ordinary package typedef, the OTHER formal of the very same cloned body) is
  the control for § 3.

## 1. § lawSCopyHomeInstance36 — 7 of the 12

> A LAW-S bare per-declaration COPY of a package scalar typedef is instanced at
> the typedef's **HOME** package: the **DEF** view inside the home package's own
> DEF listing, the **ELABORATED (top)** view in EVERY other view — the home's
> own elaborated listing, every importer's def AND elab listings, and every
> module listing.

`t48a` reads all four cells off one golden:

    DEFPKG home48::w48_to_string  io0  w48_t  @home48!def   <- the ONE def cell
    DEFPKG zz48::w48_to_string    io0  w48_t  @home48!TOP   (clone body)
    DEFPKG aa48::w48_to_string    io0  w48_t  @home48!TOP   (clone body)
    DEFPKG zz48::z48              io0  w48_t  @home48!TOP   (zz48's OWN body)
    ELABPKG {home48,zz48,aa48}::* io0  w48_t  @home48!TOP
    DEF/TOPMOD work@mm48::*       io0  w48_t  @home48!TOP

and we wrote **five different wrong answers** for those rows —
`@home48!def`, `@aa48!def`, `@zz48!def`, `@zz48!TOP`, `@aa48!TOP` — across
eight of `t48a`'s sixteen rows, from five mint and re-stamp paths.  Pass 35 had
decoded one of them correctly (`bareScalarTdCopyOfFresh16` ends with
`cp->Instance(src->Instance())` and `src` is often the § otherTds IMPORT CLONE,
owned by the LAST importer) — but a fix at that funnel is masked twice over:
some of those objects are copies a *later* pass re-pointed, so an in-place
stamp is overwritten.  This is pass 17's "enumerate the MINT SITES" trap in its
purest form, so the law is applied the way pass 32's is — **design-final and
object-wise**, after `pkgImportCloneLastWriter32`, over the io_decl-reachable
copies.  The first cut of that pass, which found a copy's home by walking its
`Typedef_alias` chain alone, still measured only **four of t48a's eight** wrong
rows: a CLONE-body copy's alias target is a BARE copy carrying no alias of its
own (§ importCloneBareTdAlias16), so the chain dead-ends before the listing
object and the home has to be RECORDED at the funnel instead.

Mechanics: `bareScalarTypedefVarTs` already computes, for every registered
package scalar typedef listing object, the package symbol that declared it —
it just threw the symbol away.  `pkgScalarTdHome36` keeps it, and adds the
wildcard-import CLONE listing objects (which `note` cannot see: they are not
registered typedefs, and their own instance is the importer's).
`bareScalarTdCopyOfFresh16` — the one funnel every LAW-S mint path goes
through — records `lawSCopyHome36[copy]`, a copy of a copy inheriting the
home.  The design-final pass then walks the io_decls of every package (def and
elab), module and class view and stamps each reached copy: home DEF if the
ONLY view that reaches it is the home package's own DEF listing, home TOP
otherwise.

Membership in `pkgScalarTdHome36` doubles as "this object IS a listing
object", which the pass never touches — pass 32's objects included.

## 2. § enumAliasHomeDefFollowsImporter36 + § importCloneAliasEnumBareName36 — 3 of the 12

SeqDriver's `UVM_SEQ_ARB_TYPE` rows come from
`typedef uvm_sequencer_arb_mode UVM_SEQ_ARB_TYPE;` — an ALIAS OF AN ALIAS,
which LAW S deliberately excludes from taking a copy at all ("golden binds ONE
shared `p::at` object everywhere").  `t48b` says that exception holds for the
HOME bodies only, and splits into two halves:

    (a) DEFPKG home49::use_ae48 io0  enum_typespec 'home49::ae48_t' @aa49!def
        ours (before)                                              @home49!def
    (b) DEFPKG/ELABPKG {zz49,aa49}::use_ae48 io0  'ae48_t'         @home49!TOP
        ours (before)                              'home49::ae48_t'@home49!TOP
    CONTROL: the DIRECT enum `de48_t` keeps 'home49::de48_t' in the clone
        bodies (QUALIFIED) and @home49!def in the home body — matched already.

**(a)** is the last-writer law one object over.  The clone branch in
`ParamEmit` *already documents why*: "an enum-ALIAS typedef gets exactly ONE
typespec object in the design: the home package never LISTS it, so the import
copy is also what the home package's own aggregates bind" — and it re-points
the home package's aggregate MEMBERS onto the import copy but left its FORMALS
bound to our separate def-view object, which then kept the home package as its
owner.  Recorded in `enumAliasHomeOwner36` and stamped beside
§ pkgImportAggCloneLastWriter32; deliberately NOT put in that pass's own map,
which also gates § importCopyAggFormalOwnCopy32's private copy.

**(b)** is § importCloneBareTdAlias16 one typespec KIND over, for the same
stated reason ("the clone's chain is re-minted against the IMPORTING package,
so nothing in it is the object `writeDataTypes` prefixed").  The private copy
§ importCopyAggFormalOwnCopy32 already takes in a clone body is renamed bare
when — and only when — the typedef is an alias of an alias.

## 3. § classScopedTdImportCopyUnsupported36 — 2 of the 12

> Inside a wildcard-import CLONE, a formal typed by the class's OWN class-scope
> typedef degrades to `unsupported_typespec` named AS WRITTEN, instanced at the
> HOME package's ELABORATED view.

The row exists at all only because a class method DEFINED OUT OF BODY is a
PACKAGE-scope item, so an importer clones it as a package subroutine — and in
that copy `this_type` has no class scope to resolve against.  `t48c`:

    DEFPKG  aa50::::c50::m50 io1  unsupported_typespec 'this_type' @home50!TOP
    ELABPKG aa50::::c50::m50 io1  the same, a SECOND object
    DEFPKG  aa50::::c50::m50 io0  int_typespec 'k50_t' @home50!TOP  <- CONTROL

while every non-clone view — the home's own out-of-body copy, the class views,
the module views — keeps the `class_typespec 'aa50::this_type'@aa50`
§ classKeyTsScopeOwner35 gives it, which we already matched.  This is
§ dpiImportCopyFormalUnsupported33 with the predicate moved from "the
subroutine is a DPI import" to "the formal's type is a class-scope typedef",
and it reuses that law's emission site verbatim (including the
`importCopyTsCollect` hand-off that re-points the object at the elaborated
home package once both views exist).

## 4. What is left, measured

* **`IOTOTAL2` = 3, all BuildUVMPkg, and the PAIR census cannot see any of
  them** — they are a POPULATION difference, not a pair:

      < ELABPKG uvm_pkg::uvm_reg_map:: io[-] <none>
      > ELABPKG uvm_pkg::uvm_reg_map::ceil io[0] 'a' in ts=int_typespec''
      > ELABPKG uvm_pkg::uvm_reg_map::ceil io[1] 'b' in ts=int_typespec''

  golden holds an UNNAMED, io-less task_func where we emit `uvm_reg_map`'s
  local `ceil` with its two formals.  Same object as the `IOTOTAL`-2 residue.
  A naming/listing question, not a typespec one.
* **The 5910 binding keys are now the whole game** (extras 1979 / misses
  3931; SeqDriver holds 3171 of the misses).  The element head on
  Scoreboard/SeqDriver/SimpleUVM is a binding MISS (`L function 'print_field'
  <- class_defn 'uvm_printer'` / `R <null>`), BuildUVMPkg's is
  `bit_typespec uvm_field_flag_t` under `DEFPKG uvm_pkg var[2]
  uvm_deferred_init`.  Pass 35's unmodelled DESIGN / MODULE class-key
  LISTINGS are one standing lead into it — and this pass measured a second,
  much bigger one, **which is where pass 37 should start**.

  Joining the `r10uvm28g` census key-by-key on SeqDriver and splitting the
  MISSES by VIEW says they are not spread at all:

      MISS by view+package            EXTRA by view+package
        1401  DEFPKG  adpcm_pkg         218  ELABPKG adpcm_pkg
        1395  ELABPKG adpcm_pkg         216  DEFPKG  adpcm_pkg
         214  BOTH    uvm_pkg           186  DEFPKG  uvm_pkg
         161  ELABPKG uvm_pkg           182  ELABPKG uvm_pkg
           2  DEFPKG  uvm_pkg

  **88% of SeqDriver's misses are in the `adpcm_pkg` WILDCARD-IMPORT CLONE
  bodies, mirrored almost exactly between the two views** (1401/1395 — a
  shared-object or shared-emission-path signature).  And by golden's TARGET
  they are overwhelmingly the clone body's OWN locals and loop variables:

       664  ref_var:i       DEFPKG adpcm_pkg::uvm_component::get_children
                            ref_obj 'i' 1860:35 -> G:ref_var 'i', ours bare
       176  ref_var:j       ...::uvm_component::m_set_cl_verb
       176  logic_net:this  BOTH uvm_pkg::uvm_component::apply_config_settings
        92  ref_var:blk_    ...::uvm_reg_block::get_block_by_name
        88  ref_var:index   ...::uvm_default_factory::find_override_by_name
        72  io_decl:value   ...::uvm_bitstream_to_string (a bit_select base)
        70  array_var:args / 68 fields / 66 addrs / 64 succ / 60 rg_ / 60 range

  i.e. **§ pkgCloneHierBind9 is written too narrowly**: it binds only "the
  first `Path_elems` entry of a `hier_path` and a `method_func_call`'s
  `Prefix`, when the name is one of that body's own formals/locals", and
  golden binds ORDINARY `ref_obj`/`ref_var`/`bit_select` bases to those same
  locals as well.  Widening that one pass is worth ~2800 keys on SeqDriver
  alone before any new law is needed.  The EXTRA side is a different and much
  smaller family, evenly spread over all four views and dominated by implicit
  function-return variables we bind and golden leaves bare
  (`string_var:convert2string` 159, `bit_var:XupdateX` 84,
  `string_var:get_full_name` 57).
* Unchanged and still open: the MODULE arm of § classKeyTsScopeOwner35
  (t47c), the sharing residue (golden has ONE socket object for 10-17
  formals, we keep one per specialization), `INITTOTAL`-52, the unqualified-
  parameter FOLD (t40a), `r10uvm23m` tf=2/var=34, t36b net-vs-var, t33d,
  hier_path root degradation.

## 5. Method notes

* **A control per law, in the same golden, every time.**  `de48_t` beside
  `ae48_t` is what keeps § 2 from bare-naming every enum clone copy in the
  corpus; `k50_t` beside `this_type` in the very same cloned body is what
  keeps § 3 from degrading every clone formal.  Both controls cost three
  lines of arm.
* **The def/top split needs a FREE FUNCTION cell.**  Pass 35's class arm could
  only ever show the elaborated view, because a class hangs off the top
  package; `home48`'s free functions put the same typedef in an importer's DEF
  listing and in its ELAB listing at once, and that is the whole reason the
  "home DEF is the only def cell" clause could be written at all.
* **One law, five wrong answers.**  Before believing a one-line fix at a mint
  site, count the objects: `t48a` had five distinct wrong instances for one
  typedef, so the fix had to be a design-final stamp over recorded objects,
  not an edit at the funnel.  The funnel is still where the RECORD is taken.
* **Read the comment above the line you are about to change.**  Both § 2(a)
  and § 1 were already described, correctly, in comments written by earlier
  passes — § 2(a) even names the mechanism ("the home package never LISTS it")
  and then fixes only the aggregate members.

## 6. Gate

* goldens **23 PASS**
* u2r testflags: **byte-identical** to `results/gate_uhdm2rtlil.csv` (732 lines)
* Surelog both modes: **byte-identical** to `results/golden_surelog.csv`
  (1589 lines) — zero status changes, `SLANG_REJECT` membership unchanged,
  none of the five pinned giants flaked
* byte verifier (the CSV is blind inside an already-NOTEQUAL row): the 11
  non-UVM `CMP_NOTEQUAL` tests, both modes, `slang.uhdm` compared against a
  pristine-HEAD binary built in this worktree — **20/20 identical, exactly 2
  skips** (Earlgrey_0_1 testflags SLANG_REJECT, Rggen testflags SURELOG_FAIL
  emit no database)
* `r10uvm28a` element head byte-identical pre/post on all four tests
