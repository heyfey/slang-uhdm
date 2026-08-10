# r10uvm35 — UVM pass 35

Pass 34 ranked `this_type` first for the third pass running — 58 rows, 85% of
the io_decl residue — and left the decode half-written: "golden holds three
objects per test, their `vpiInstance` is the last importer of `uvm_pkg`, start
from t46a (D) plus a second importer".  This pass wrote that second importer
cell, and the first thing it said is that **pass 34's reading was upside down
in one place and one place only**: the importer that owns the object is not the
LAST one to *use* it, it is the last one to *list* it, and the NAME comes from
the FIRST — because `UhdmWriter::writePackage` re-stamps a package's WHOLE
typedef listing unconditionally *after* `writeDataTypes` has already qualified
the name first-writer-wins.  Two importers whose names are ANTI-SORTED against
their declaration order separate all four candidate rules in one golden.

| metric | HEAD eb15654 | this pass |
|---|---|---|
| `r10uvm31m.sh` pair census (`PAIRTOTAL`) | **68** | **12** (-82%) |
| — BuildUVMPkg / Scoreboard / SeqDriver / SimpleUVM | 3 / 15 / 33 / 17 | **0 / 0 / 12 / 0** |
| `r10uvm30iom.sh` (`IOTOTAL2`) | **139** | **27** (-81%) |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm28m.sh` `BINDTOTAL` | 5910 | **5910** (held, 1979/3931) |
| `r10uvm27m.sh` CTORTOTAL / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL` and the `r10uvm28a`
element head is byte-identical pre/post (still `uvm_printer::print_field` on
SeqDriver / Scoreboard / SimpleUVM, `uvm_field_flag_t` on BuildUVMPkg).
**Three of the four tests now have a ZERO io_decl typespec residue** — the
whole remaining 12 is SeqDriver, and it is one family (§ 3).

Reproduce:

    g++ -std=c++20 -O2 tools/probe/r10uvm35ti.cpp -o /tmp/r10uvm35ti \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    # one arm, golden + ours, with the OWNERSHIP column
    SL=$HOME/git-repos/Surelog/build/bin/surelog
    ( cd /tmp/a47 && $SL -parse -d uhdm tools/probe/r10uvm35repro/t47a/dut.sv )
    /tmp/r10uvm35ti /tmp/a47/slpp_all/surelog.uhdm --rows

---

## 0. The probe and the arms

**`r10uvm35ti`** — `r10uvm34ti` plus the column that decoded this pass: for
every io-reachable typespec it prints **every listing that contains the
object** (`DESIGN[i]`, `DEFPKG:p[i]`, `ELABPKG:p/CLS:c[i]`, `DEFMOD:[i]`,
`TOPMOD:m[i]`, `ALLCLS/CLS:c[i]`), plus the `vpiClassDefn` and the UhdmIds.
Surelog stamps `vpiInstance` **in the listing writers**, so "who lists it" IS
the decode of "who owns it" — and no pass-30..34 probe could ask it.

Three arms, because the three cells are three different *designs*, not three
different declarations:

* **`t47a`** — one package of classes (`pcls47`) and **two package importers
  whose names are anti-sorted against their declaration order**: `zz47`
  declared first, `aa47` second.  Plus a module importer, the UVM socket shape
  (`sock47`/`sockb47`, a base specialised on the derived class's own
  parameter), and three controls: an ordinary package typedef (`plain47_t`), a
  class with NO class-scope typedef (`nocls47`) and a plain class-typed formal
  (`base47 b`).
* **`t47b`** — the same plus a `$unit`-scope import (the Scoreboard /
  SimpleUVM shape), to rank the design against the packages.
* **`t47c`** — no package importer at all, only a MODULE one (the BuildUVMPkg
  shape, one importer short).

## 1. The law

### § classKeyTsScopeOwner35

> A class-scope TYPEDEF's typespec (`this_type`, `type_id`, …) is listed by
> nothing but its own `class_defn` until an import publishes it
> (§ importPublishesPackageClasses24).  Its **name** is qualified by the FIRST
> package that lists it; its **vpiInstance** is the DEF view of the **LAST**
> package that lists it; with no package importer the **DESIGN** owns it (name
> left bare), with only a module importer the first DEF **module** does, and
> with no importer at all it keeps a NULL instance and a BARE name.

The mechanism is two writers, not one.  `UhdmWriter::writeDataTypes` (:775)
qualifies the name only for a package parent and stamps the instance
FIRST-writer-wins and never for a `class_defn` parent:

```cpp
if (parent->UhdmType() == uhdmpackage)
  if (tps && tps->VpiName().find("::") == std::string::npos)
    tps->VpiName(StrCat(parent->VpiName(), "::", tps->VpiName()));
if (!tps->Instance())
  if (parent->UhdmType() != uhdmclass_defn) tps->Instance((instance*)parent);
```

and then `writePackage` (:1189-1192) does

```cpp
writeDataTypes(pack->getDataTypeMap(), p, typespecs, s, true);
writeImportedSymbols(pack, s, typespecs);
for (auto tp : *typespecs) tp->Instance(p);   // UNCONDITIONAL
```

— the § pkgImportAggCloneLastWriter32 mechanism, one object family over — with
packages written **elaborated first, def second** (:4944 then :4979), after the
design's FileContent pass (:4871) and before the module passes.

`t47a` reads all of that off ONE golden: `class_typespec 'zz47::this_type'`
(first writer, source order) `@aa47` DEF (last writer, source order — *not* the
`std::map` name order the DataTypeMap itself uses, which would have said
`zz47`).  `t47b` adds the `$unit` import and the packages still win, so the
design is a fallback and not a winner.  `t47c` drops the packages and the DEF
module takes it, bare-named.  And BuildUVMPkg — nobody imports `uvm_pkg` — is
the null cell on the real corpus.

The UVM-4 are one law with three answers, and we had all three wrong:

| test | importer | golden | ours (HEAD) |
|---|---|---|---|
| SeqDriver | package `adpcm_pkg` | `'adpcm_pkg::this_type'` @adpcm_pkg | @uvm_pkg!top / null |
| Scoreboard | `$unit` | `'this_type'` @design | @uvm_pkg / null |
| SimpleUVM | `$unit` | `'this_type'` @design | @uvm_pkg / null |
| BuildUVMPkg | none | `'this_type'` @null | @uvm_pkg / null |

**SCOPE, and the control that sets it.**  Only a representative whose SIMPLE
NAME is not its class's own name.  `t47a`'s `u_no(nocls47 n)` and
`u_cl(base47 b)` cells say golden mints a FRESH, unlisted, null-instance
`class_typespec` for an ordinary class-typed formal — in the importing package
too — even though `nocls47` is itself a published class key whose
representative is named `zz47::nocls47`.  Without that guard the law reads
"every class-typed formal follows the last importer", which is 0 rows right and
thousands of rows wrong.

**The regression that wrote the second guard.**  The first run of this law
nulled `uvm_pkg::uvm_tlm_time` and `uvm_pkg::uvm_port_list` — pass 34's own
`§ pkgContainerTdFormalListing34` objects, which are ALSO class
representatives — and cost BuildUVMPkg 25 rows (3 -> 25) while the other three
tests improved.  Those objects are ordinary entries of `uvm_pkg`'s own listing,
so a package stamped them in golden too; the law governs only objects that NO
non-class scope listed **before** the publication.  `importPublishesPackageClasses24`
therefore snapshots the pre-publication listings and hands them to the new pass.

### § classRepDupFormalFollowsRep35 (the same law's second arm)

> An UNLISTED per-specialization DUPLICATE of one of those objects — same
> `vpiClassDefn`, same written name, `listed=0` — is not a distinct object in
> golden at all: the formal binds the representative, so it carries the
> representative's NAME and OWNER.

`uvm_tlm_b_initiator_socket #(T) extends uvm_port_base #(uvm_tlm_if #(T))`
makes slang specialise the base once per socket, so each socket's
`connect(this_type provider)` reaches its OWN `this_type` alias and we minted a
fresh bare null-instance object — **8 rows on every test**, and the reason
SeqDriver's socket rows differed in NAME as well as instance.  `t47a`'s
`sock47`/`sockb47` reproduce it exactly (`defnid` equal to the
representative's, `tsid` 20 objects later, `listed=0`).

We give the duplicate the representative's name and instance rather than
re-pointing the `ref_typespec`: those are every field uhdm-cmp reads through
it, and the duplicate may carry specialization-specific links the
representative does not.  The SHARING itself (golden: ONE object for ten to
seventeen formals across unrelated classes; ours: one per specialization) is a
residue the io_decl census cannot see.

## 2. What this pass did NOT model (measured, recorded)

* **The MODULE arm of § classKeyTsScopeOwner35** (`t47c`): golden gives the
  first DEF module_inst.  Zero rows on the UVM-4 — SeqDriver's `top_tb` does
  list the objects (`DEFMOD:[7]`, `TOPMOD:work@top_tb[7]`) but `adpcm_pkg`
  beats it — and the whole corpus is in its blast radius.
* **The DESIGN and MODULE class-key LISTINGS themselves.**  Golden's Scoreboard
  design carries the published keys at `DESIGN[7]/[58]/[92]`, the very indices
  `adpcm_pkg` uses on SeqDriver, and golden's SeqDriver modules carry them too;
  we publish into package and class listings only (`listed=8` where golden says
  `10`, `listed=2` where golden says `3`).  Invisible to the io_decl census,
  almost certainly part of the 3931 binding misses.  This pass computes the
  design owner from the `$unit` import instead of from a listing it does not
  build.
* **Explicit-import publication** is folded into the `$unit` set (Surelog's
  `importPackage` does not filter), but every measured cell is a wildcard.

## 3. RANKED for pass 36

Residue **12 = 0 / 0 / 12 / 0**, all SeqDriver, and it is ONE family in three
spellings — **the wildcard-import COPY names a formal's typespec BARE and
instances it at the HOME package**, where we name it as the copy's own package
listing does and instance it at the importer:

1. **The LAW-S bare-copy home instance — 7 rows** (`uvm_integral_t`), unchanged
   rank from pass 34 but no longer un-reproduced: **`t47a`'s `plain47_t` cell
   is a 100-line repro** — golden `int_typespec 'plain47_t'@pcls47!top`, ours
   `@aa47`, on the HOME package's own class method.  The decode is one line:
   `bareScalarTdCopyOfFresh16` (TypeEmit ~5432) ends with
   `cp->Instance(((typespec*)src)->Instance())`, and `src` is the
   § otherTds IMPORT CLONE minted per importer (ParamEmit ~17053,
   `cl8->Instance((instance*)up)`), so the copy inherits the IMPORTER where
   golden's names the typedef's HOME package **in the copy's own view** — which
   is exactly what the comment above that line already claims it does.  The fix
   is a recorded home-instance per listing object, not a new predicate.  WHOLE-
   CORPUS BLAST RADIUS: land it only with the byte verifier below.
2. **`UVM_SEQ_ARB_TYPE` — 3 rows.**  Two NAME rows in the import copies
   (`DEFPKG`/`ELABPKG adpcm_pkg::::uvm_sequencer_base::set_arbitration`, golden
   bare `'UVM_SEQ_ARB_TYPE'`@uvm_pkg, ours `'uvm_pkg::UVM_SEQ_ARB_TYPE'`) and
   the mirror INST row in `DEFPKG uvm_pkg::::` (golden @adpcm_pkg, ours
   @uvm_pkg).  Same "bare + home in the copy, qualified + last-importer at
   home" shape as (1), one typespec kind over.
3. **`this_type` in the import copy — 2 rows.**  `DEFPKG`/`ELABPKG
   adpcm_pkg::::uvm_sequence_library::m_check`: golden
   `unsupported_typespec 'this_type'`@uvm_pkg!top, ours the (now correct)
   `class_typespec 'adpcm_pkg::this_type'`@adpcm_pkg.  The import copy degrades
   what the home listing resolves — the § dpiImportCopyFormalUnsupported33 /
   § oobParamClassTypeParamFormalUnsupported31 shape, one spelling over.
4. **Once those 12 are gone the io_decl typespec family is CLOSED** (3509 at
   pass 30 -> 139 at 34 -> 27 now) and the **5910 binding keys** are the whole
   remaining game: still the element HEAD on all four, SeqDriver holds 3171 of
   the 3931 misses, and this pass hands it a lead — the missing DESIGN /
   MODULE class-key listings in § 2.
5. smalls, unchanged: `INITTOTAL`-52 remainder, the unqualified-parameter FOLD
   (t40a), `r10uvm23m` tf=2/var=34, t36b net-vs-var, t33d, hier_path root
   degradation.

## 4. Method notes

* **Anti-sort the two cells you cannot otherwise separate.**  Four rules fit
  every single-importer golden in this campaign — first/last writer x
  source/name order — and one arm with `zz47` declared before `aa47`
  distinguishes all four in one line of output.  The answer was a SPLIT
  (name from the first, instance from the last), which no single-importer cell
  could ever have shown and which pass 34 guessed one way.
* **"Who lists it" is the decode of "who owns it".**  Every ownership law in
  this campaign — LAW S, pass 16's clone stamps, pass 32's last writer, this
  one — is a listing writer stamping as it walks.  The probe that prints the
  listings answered in one run what four passes of instance-printing probes
  could not.
* **Run the wrong law once on the real corpus — a third time.**  Eight
  synthetic cells agreed on the wide predicate; BuildUVMPkg went 3 -> 25 and
  named the two objects (`uvm_tlm_time`, `uvm_port_list`) that the
  pre-publication snapshot now excludes.  Note the shape: the regression was on
  the test with the FEWEST rows and the SIMPLEST design, because it is the one
  with no importer to hide the mistake.
* **A control is worth a law.**  `u_no`/`u_cl` cost four lines of arm and
  stopped a predicate that would have re-owned every class-typed formal in the
  corpus.

## 5. Gate

* goldens **23 PASS**
* u2r testflags: **byte-identical** to `results/gate_uhdm2rtlil.csv` (732 lines)
* Surelog both modes: **byte-identical** to `results/golden_surelog.csv`
  (1589 lines) — zero status changes, `SLANG_REJECT` membership unchanged, none
  of the five pinned giants flaked
* byte verifier (the CSV is blind inside an already-NOTEQUAL row): the 11
  non-UVM `CMP_NOTEQUAL` tests, both modes, `slang.uhdm` compared against a
  pristine-HEAD binary — **20/20 identical, exactly 2 skips** (Earlgrey_0_1
  testflags SLANG_REJECT, Rggen testflags SURELOG_FAIL emit no database)
* `r10uvm28a` element head byte-identical pre/post on all four tests
