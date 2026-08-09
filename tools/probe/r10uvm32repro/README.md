# r10uvm32 — UVM pass 32

Pass 31's ranked **#1** was "SeqDriver's 1197 `io_decl` `INST` rows — TWO shared
objects with the wrong LAST WRITER", with the instruction to decode **when
Surelog mints a fresh typespec object per use vs shares one**.  Doing that with
a new census — of the **package TYPEDEF LISTINGS** rather than of the io_decl
rows — collapsed the whole family to **one field on one object**, and then to
**two laws that are the two halves of the same question**.

| metric | HEAD 06dd0a8 | this pass |
|---|---|---|
| `r10uvm31m.sh` pair census (`PAIRTOTAL`) | **1543** | **397** (-74%) |
| — BuildUVMPkg / Scoreboard / SeqDriver / SimpleUVM | 80 / 76 / 1301 / 86 | 80 / 76 / **155** / 86 |
| `r10uvm30iom.sh` (`IOTOTAL2`) | **3089** | **797** (-74%) |
| — per test | 163 / 152 / 2602 / 172 | 163 / 152 / **310** / 172 |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm28m.sh` `BINDTOTAL` | 5910 | **5910** (held, 1979/3931) |
| `r10uvm27m.sh` CTORTOTAL / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL` and the `r10uvm28a`
element head is unchanged — recorded honestly.  Master gates on the worktree
binary: goldens **23/23**; u2r testflags (732 rows) diff **EMPTY** vs
`results/gate_uhdm2rtlil.csv`; Surelog **both** modes (1589 rows) whole-row diff
**EMPTY** including the DUMP column vs `results/golden_surelog.csv`.

Build the probes with the **STATIC** UHDM libs:

    g++ -std=c++20 -O2 tools/probe/r10uvm32td.cpp -o /tmp/r10uvm32td \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SLANG_UHDM=<build> R10IO=/tmp/r10uvm30io OUTROOT=/tmp/r10uvm32arm \
      tools/probe/r10uvm31run.sh tools/probe/r10uvm32repro/t42a
    /tmp/r10uvm32td /tmp/r10uvm32arm/t42a/slpp_all/surelog.uhdm   # golden
    /tmp/r10uvm32td /tmp/r10uvm32arm/t42a/ours.uhdm               # ours

`OUTROOT` keeps pass 31's runner out of `/tmp/r10uvm31arm`; nothing is ever
written inside the repo tree.

---

## 0. The probes this pass added

* **`r10uvm32td`** — the **package TYPEDEF-LISTING** census: one `LIST` line per
  `Typespecs()` entry of every package / module in every view (kind, name,
  `vpiInstance`, dense object index), then one `OBJ` line per DISTINCT object
  with the **ordered list of the listings that contain it**.  That last column
  *is* the "who wrote last" evidence, and it is what turned pass 31's
  1197-row-shaped problem into a three-line diff.  Every io_decl census this
  campaign has built looks at the CONSUMERS of these objects; none of them
  could see the producers.
* **`r10uvm32io`** — `r10uvm31io` plus the **instance VIEW marker**: `@uvm_pkg`
  becomes `@uvm_pkg!top` when the instance carries `vpiTop`.  The def and the
  elaborated package share a name, so "does an import COPY's formal name the
  def or the elaborated home package?" is simply unreadable without it — and
  the answer (`!top`) decided the shape of law 2.
* **`t42a`** — one 60-line source with an enum, a packed-struct and a vector
  typedef in `pa42` and **four** importers of it, one of which uses nothing and
  one of which (`pe42`, last) imports **explicitly and by type name only**.

## 1. The laws

### § pkgImportAggCloneLastWriter32

> An imported package typedef is listed by **every** importer, and all of them
> share ONE second-generation object (the home package's own def listing keeps
> a separate first-generation one).  Surelog stamps that shared object's
> `vpiInstance` as it writes each package's data-type table, so the **LAST
> package to list it owns it for the whole design** — in every view, including
> the home package's own ELABORATED listing and every module listing.

`r10uvm32td` on `t42a`'s golden, all three kinds:

    OBJ ts#0 enum_typespec 'pa42::aen_t'  inst=pa42  listings=DEFPKG:pa42
    OBJ ts#3 enum_typespec 'pa42::aen_t'  inst=pe42  listings=DEFPKG:pb42,
             DEFPKG:pc42,DEFPKG:pd42,DEFPKG:pe42,ELABPKG:pa42,…,TOPMOD:work@top42a

`pe42` is the decisive cell: its import is **explicit and type-only**, so it has
no wildcard subroutine clone and never mentions the types.  The **LISTING** is
what stamps, not any use of the type.  (`pc42`, which imports and uses nothing,
is the same cell one position earlier and agrees.)

We already followed this for VECTOR/scalar/class-alias clones — ParamEmit's
`otherTds` arm re-stamps on every importer and `t42a`'s `avec_t` reads `pe42` on
both sides.  The AGGREGATE arm stamped only the FIRST importer, at creation, and
then the wildcard subroutine-clone pass moved it again (see law 2), so every
enum/struct import clone came out owned by the typedef's **home** package.

Reach: SeqDriver's entire `INST enum_typespec` family — `uvm_status_e` 367,
`uvm_path_e` 289, `uvm_hier_e` 153, `uvm_severity` 113, `uvm_radix_enum` 69,
`uvm_predict_e`/`uvm_check_e` 39 each, … — plus the struct ones, golden
`@adpcm_pkg` where we said `@uvm_pkg`.

Implementation: `pkgImportCloneOwner32` is **recorded** during the def pass and
**applied design-final** (`pkgImportCloneLastWriter32`, called last among the
instance passes in `UhdmExporter.cpp`), precisely because the passes that follow
would overwrite an in-place stamp.  The vector arm records too, where it is a
no-op — if the design-final pass had ever MOVED a vector clone, the record and
the long-standing law would have disagreed loudly.

### § importCopyAggFormalOwnCopy32 — the other half

Applying law 1 alone measured **1543 -> 623**, and the same `t42a` run showed
why it stopped there: it had *inverted* one smaller family.  A **wildcard-import
SUBROUTINE CLONE**'s formals keep `vpiInstance` = the HOME package (the
long-standing `importCopyTsInst` law), and until now they got it by re-stamping
the very object law 1 had just given to the last importer.  One object cannot
carry both — and golden does not ask it to.  `r10uvm32io --objects` on `t42a`:

    DEFPKG pb42::a_use io[0] 'e'  enum_typespec 'pa42::aen_t' @pa42!top  ts#3  uses=1
    DEFPKG pb42::b_use io[0] 'e'  enum_typespec 'pa42::aen_t' @pe42      ts#6  uses=7

`a_use` is pb42's CLONE of pa42's function; `b_use` is pb42's own.  Surelog
mints a **fresh typespec per clone formal** beside the shared listing object,
and — the `!top` marker earns its keep here — that fresh one names the
**ELABORATED** home package, which is why the fix is a private copy for the
existing stamp to write rather than a re-bind to the home package's own def
listing object.

`aggImportCloneCopy32` is deliberately **shallow**: it shares the enum-constant
vector / member vector / `Typedef_alias` with the original, so every field
`uhdm-cmp` reads through the copy is the same object it was before and only
`vpiInstance` splits.  Aggregates only — a scalar/vector formal already holds a
per-declaration LAW-S copy and never touched the shared object.

Together: **1543 -> 397**, `t42a`'s io census 42 -> 16 diff lines.

## 2. What this pass did NOT model (measured, recorded in code)

* **§ dpiImportFormalKeepsListingTd32 — attempted, MEASURED AS A NO-OP,
  REVERTED.**  Golden names a DPI IMPORT's formal `uvm_pkg::uvm_hdl_data_t` (the
  qualified LISTING object) where the identical formal of a plain package
  function is bare — pass 31 ranked it #2 at 76 rows and `t41b` §(e) settles the
  2x2 (`d_lit` qualified / `p_lit` bare, both in the declaring package).  The
  obvious implementation — make LAW S (`bareScalarTypedefVarTs`) skip a DPI
  import's `io_decl`s — changes **nothing**: the io_decl never held the listing
  object, because TaskFuncEmit's per-formal typedef-CLONE arms run first and
  hand LAW S an object that is not in `pkgScalarTd`.  Verified end to end
  (`PAIRTOTAL` 397 and `IOTOTAL2` 797 both unchanged) and then reverted rather
  than landed as untested code; a note sits at the LAW-S io arm so pass 33 does
  not re-derive it.  **The law has to be applied at the io_decl EMISSION site**
  — bind the shared object instead of minting the clone.
* **The IMPORT COPY of a DPI import** degrades every formal to
  `unsupported_typespec` named as written (`t41b` `p31a::d_lit`; UVM's
  `DEFPKG adpcm_pkg::::uvm_hdl_deposit`, 8 rows).  A DPI import with an **enum**
  formal is `unsupported_typespec` in the DEF view of its own package but the
  shared enum object in the ELAB view — an asymmetry with **zero** reach in UVM.
* **`t42a`'s remaining 8 pairs** are all the pre-existing LAW-S bare-copy
  instance family (`avec_t` `@pa42` in golden, `@pb42`/`@pd42`/`@pe42` in ours)
  plus ONE struct row (`DEFPKG pb42::a_use io[1]`) where the private copy did
  not fire — a formal that reaches the io_decl typespec through a different arm
  of the if-chain.  1 row of 24; unchased.

## 3. RANKED for pass 33 (post-patch pair census, rows not `IOTOTAL2`)

1. **The DPI-import formal name — 76 rows**, all four tests, now the largest
   family on three of them and #1 on SeqDriver (36).  Fully decoded (§2 above);
   what is missing is only the *site*.  Golden
   `logic_typespec 'uvm_pkg::uvm_hdl_data_t'@adpcm_pkg` vs our
   `'uvm_hdl_data_t'@uvm_pkg`.  Note the instance half comes free once the
   formal binds the listing object, because law 1 already owns that field.
2. **`class_typespec 'uvm_pkg::uvm_tlm_time'` vs our `'uvm_time'` — 23 rows**
   (BuildUVMPkg's #1) and **`enum_typespec 'uvm_pkg::uvm_tlm_phase_e'` vs our
   EMPTY name — 15 rows** on all four.  Both are `uvm_tlm_if`/socket formals; a
   type-parameter default that is a typedef arriving unnamed (pass 31's §3.3).
3. **`struct_typespec uvm_hdl_path_slice` INST — 20 rows** on SeqDriver, golden
   `@adpcm_pkg` and ours `@uvm_pkg`, at `add_hdl_path`/`format_row` in CLASS
   listings (not import clones).  This is law 2 firing where it should not, or
   law 1 not reaching a second struct object; `r10uvm32td` + `r10uvm32io
   --objects` will say which in one run, and it is the cheapest of the three.
4. **`int_typespec 'this_rsp_type'` LAST-WINS — 12 rows** per test (pass 31 §3.4,
   `t41b` §(c)) and `class_typespec 'adpcm_pkg::this_type'` INST 10 + NAME 8.
5. Unchanged from pass 31: the **5910 binding keys** (still the element HEAD on
   all four — `uvm_printer::print_field`), the **unqualified-parameter FOLD**
   (t40a), the **INITTOTAL-52** remainder and the smalls (`r10uvm23m` 36,
   BuildUVMPkg `tf 2`, t36b, t33d, hier_path root-degradation).

## 4. Method notes

* **Census the PRODUCERS, not only the consumers.**  Eleven passes of io_decl
  censuses had looked at where these typespecs are *used*.  One 90-line probe
  over `scope::Typespecs()` showed the two generations of listing object, the
  exact sharing graph (identical to golden already!) and the single field that
  differed — and the same probe printed OUR side, so the diff was three lines.
* **A one-line purpose-built cell can be worth a whole pass.**  `pe42` — three
  explicit `import pa42::t;` lines and an unused function — is the entire reason
  the law reads "the listing stamps" rather than "the last user stamps", and it
  cost nothing.  Neither corpus contains that shape.
* **The partial fix measured as an inversion, not as a null.**  Law 1 alone was
  +920/-200 rows.  Pass 31's TWO-POINTER law says to enumerate the pointers
  before judging a null result; the sibling rule this pass adds is to look at
  *which rows moved* even when the total improved, because the 200 that got
  worse are what named law 2.
* **Revert a no-op.**  The DPI guard compiled, gated clean and did nothing.  A
  clean gate is not evidence for a law; the metric is.
