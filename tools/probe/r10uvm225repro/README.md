# r10uvm225 — § ifaceDefArrayNetIsAnyUnpackedDim225

**An interface definition's `Array_nets()` carries one array_net per WRITTEN
unpacked dimension, of every kind — and no other holder carries any.**

Base commit `b4e6f61d`.  Head target: MiniAmiq ×2, the last workable
`CMP_NOTEQUAL` row-mode pair, 713053 cmp lines and one head in both modes.

---

## 1. THE QUESTIONS, ANSWERED IN ORDER

### (1) RE-MEASURED FIRST, on this pass's own pristine build

```
MiniAmiq  default   713053 cmp lines  1 head        testflags  713053  1
          LHS: interface_inst work@svaunit_vpi_interface
          RHS: <null>
```

the two cmp logs byte-identical (`ed1744b60687`).  Golden's copy of that
interface carries **5 `vpiArrayNet` and 1 `vpiProcess`** we do not, and the
line count is the head OBJECT's decompile size, not a distance.

The five, named: `uvm_random_seed_table_lookup` **twice** — `uvm_seed_map
uvm_random_seed_table_lookup [string];` (uvm_misc.svh:328), reaching the
interface on both of its wildcard-import roads — and `sva_info`, `cover_info`,
`property_info`, the interface's own
`svaunit_concurrent_assertion_info x [];` dynamic arrays
(svaunit_vpi_interface.sv:87/90/93).  So the head is **two container kinds at
once**: an imported ASSOCIATIVE array and three own DYNAMIC arrays, and the
interface is UNINSTANTIATED (`-parse`, no top).

**THE BOTH-SIDES CENSUS.**  `anetcen225.py` reads every `array_net` a holder
owns, IN VECTOR ORDER, with its `vpiSize`, its per-range bound
decompile/value/size/constType and index typespec, and the INNER element net's
kind, `vpiNetType` and typespec — the field r10v224's R-C recorded
`netcen224.py` as blind to.  `basenet225.py` reads the holder's `Nets()`
beside it, because the producer builds the inner net as a COPY of the base
net.  Both are keyed POSITIONALLY, which is what the judge compares.

The base slots' fate in `Nets()`: **untouched.**  The plain element net stays
in `Nets()` exactly as before — golden keeps it there too (a1's 22 nets, our
22, one DIFF that is pre-existing) — and this law only adds the `Array_nets()`
vector beside it.  The ELAB view: **untouched**, and measured so (a10, a12,
a13, a2 all instantiate their interface; our elaborated `Array_nets()` is the
same two cells before and after).

### (2) THE PRODUCER, RE-VERIFIED

`UhdmWriter::writeNets` (Surelog `src/DesignCompile/UhdmWriter.cpp:903-943`),
quoted in the patch's own comment:

```cpp
if (instance == nullptr && parent &&
    parent->UhdmType() == uhdminterface_inst) {
  if (const NodeId unpackedDim = orig_net->getUnpackedDimension()) {
    int32_t unpackedSize = 0;
    if (std::vector<range*>* ranges = m_helper.compileRanges(
            mod, fC, unpackedDim, …, unpackedSize, false)) {
      array_net* anet = s.MakeArray_net();
      anet->VpiName(orig_net->getName());
      anet->Ranges(ranges);  anet->VpiSize(unpackedSize);
      fC->populateCoreMembers(orig_net->getNodeId(),
                              orig_net->getNodeId(), anet);
      logic_net* elem = s.MakeLogic_net();
      elem->VpiName(orig_net->getName());
      elem->VpiNetType(dest_net->VpiNetType());          // :923
      if (dest_net->Typespec()) { …copy the ACTUAL… }    // :925-930
      anet->Nets({elem});  iface->Array_nets()->push_back(anet);
```

Three facts follow, and all three were then measured rather than inferred:

* the gate is **`getUnpackedDimension()` and nothing else** — not the array
  KIND, not the element type, not the header form, not instantiation;
* the ranges are whatever **`compileRanges`** makes of the whole written
  dimension chain, which is why each kind has its own bound shape;
* the inner element net is a **COPY of the base net** — its net type
  unconditionally, its typespec only when the base has one — and it is never
  `populateCoreMembers`'d, so it is LOC-LESS.

Inner-net fields per kind × instantiated vs uninstantiated are in §4 (R-B).

### (3) THE GOLDEN GRID

13 arms, `grid225/`, every arm compiled with the canonical golden-side Surelog
(the one `scripts/verify_golden.py` names) and with each pinned binary, **every
rc recorded on both sides, all zero**, `LISTED 13 PROCESSED 13`.

**THE FENCE'S FIRST FACE.**  `a3_module` and `a4_program` put the identical
eleven declarations under a MODULE (empty parens AND no parens) and a PROGRAM:

```
golden array_nets    module 0    program 0    interface DEF one per written dim
```

`golden=0` for both holders, on both binaries, before and after.  The producer's
`parent->UhdmType() == uhdminterface_inst` gate is exact, and this law can
never reach a module or a program.

**THE KIND GRID** (`a1_ifkinds`, empty parens, uninstantiated; 18 golden cells):

| written | array_net | range bounds (left | right) |
|---|---|---|
| *(no dimension)* | **none** | — |
| `[1:0]` | yes | `UINT:1`/64/9 at its token \| `UINT:0`/64/9 at its token |
| `[2]` | yes | `UINT:0`/64/9 LOC-LESS \| an `N-1` operation (opType 11) |
| `[]` | yes | `UINT:0`/64/9 on the `[` \| `STRING:unsized`/0/6 on the `[` |
| `[$]` | yes | `UINT:0`/64/9 LOC-LESS \| `STRING:$`/1/10 at the `$` |
| `[$:3]` | yes | `STRING:$`/1/10 at the `$` \| `UINT:3`/64/9 at its token |
| `[string]` `[int]` `[logic]` `[bit]` `[byte]` `[shortint]` `[integer]` `[bit[7:0]]` `[logic[3:0]]` | yes | `UINT:0`/64/9 LOC-LESS \| `STRING:associative`/0/6 LOC-LESS **+ a `vpiTypespec` ref (fullname = the ARRAY_NET's) onto the index typespec** |
| `[*]` | yes | the same marker with **NO** index typespec |
| `[<local typedef>]` `[<pkg::type>]` `[<class handle>]` | yes | **NOT a marker** — `UINT:0`/64/9 LOC-LESS \| an opType-11 operation over a bare `ref_obj` (name = the written index, fullname = `<array_net>.<index>`) and an unparented `INT:1`/64/7 |

`vpiSize` reads **1 in every def-view cell of every arm** — `[2:5]`, `[4]`,
`[W]`, `[PN]`, `[1:0][2][3]` included (125 golden cells; the only `vpiSize 2`
in the whole grid is an ELABORATED array_net).  A NAMED index bracket is
compiled by `compileRanges` as an EXPRESSION, not a type, which is why it takes
the SIZE model — for a class handle exactly as for a typedef.

**HOLDERS AND VIEWS**

```
a5_imported   the wildcard-imported package data § wildcardImportCopiesPkgVars-
              ToDefNets223 hoists gets an array_net TOO, once per import copy,
              AHEAD of the interface's own declarations, in Nets() order —
              three copies of six names across if225_imp1/2/3.  TWO of
              MiniAmiq's golden five are this cell.
a6_headerforms  empty parens / ANSI / genuine non-ANSI / no parens — 16 golden
              cells, the same answer in all four.  The array_net law is NOT
              gated on the header form (the typespec law of r10uvm224 is).
a2/a10/a12/a13  an INSTANTIATED interface: the DEF view answers the same law;
              the ELAB view has its own, narrower one (R2).
a14_tdhide    `typedef tv arr_t [1:0]; arr_t x;` — a typedef that HIDES the
              dimension gets NO array_net, and `arr_t y [2]` gets exactly ONE
              range, the written one.
a12_modport   a modport interface (the InterfaceModPort shape) answers the law
              and no modport object moves.
```

### (4) SLANG, DECODED

Our gate was `getCanonicalType().kind == FixedSizeUnpackedArrayType`, so every
DYNAMIC, QUEUE and ASSOCIATIVE container was dropped, the hoisted import copies
got none at all, and a typedef-hidden dimension got a RANGE-LESS array_net
golden does not list.  The patch is in `src/ModuleEmit.cpp`,
`src/TypeEmit.cpp` and `include/UhdmExporter.h`:

* **`writtenUnpackedDims225`** — the WRITTEN-dimension gate, answered BEFORE
  anything is minted (see §5's orphan).
* **`makeIfaceDefArrayNet225`** — the array_net, its ranges and its LOC-LESS
  inner element net; the caller wires the inner typespec, which is the
  producer's `if (dest_net->Typespec())` copy.
* **`buildUnpackedRanges` gains a `NonFixedDimHook225`** — it answered only
  fixed-size levels and BROKE at the first other one; with a hook it asks the
  hook for that level, stores the level's element type and carries on, so a
  MIXED chain (`[1:0][string]`, `[string][1:0]`, `[][2]`, `[string][]`,
  `[1:0][2][3]`) keeps one range per written dimension in written order.  The
  whole measured fixed-dimension law (param folds, `[N]` operations, package-
  parameter substitution) stays in ONE place and is untouched.
* **the HOISTED copies** get theirs at the interface call site, in `Nets()`
  order, ahead of the interface's own — their inner net copies the hoisted base
  net verbatim, because the hoisted road has its own net-type rule and this law
  does not touch it.

**R-A — THE ASSOCIATIVE REPRIEVE'S CLASS-INDEX OVER-FIRE, LANDED.**
r10uvm224 wrote the reprieve as "the index type is not a `TypeAlias`", one
predicate wider than golden: a class handle is a legal associative index and is
not a TypeAlias, so `tv x [C];` kept its def-view typespec where golden drops
it.  `assocIdxIsBuiltin225` states the rule POSITIVELY instead — a written
built-in keyword or the `[*]` wildcard — and it is re-measured here over
fourteen index forms in an interface and three in a module (`a7_associdx`,
`a11_clsidx`):

```
KEEP  [string] [int] [logic] [bit] [byte] [shortint] [integer]
      [bit[7:0]] [logic[3:0]] [*]
DROP  [<local typedef>] [<typedef of string>] [pkg::<typedef>]
      [<class handle>] [<derived class>] [pkg::<class>]
      [<enum typedef>] [<packed-struct typedef>]
```

All 7 `a11_clsidx` cells and all 14 `a7_associdx` cells go TO-GOLDEN.

**R-B — THE INNER ELEMENT NET'S `vpiNetType`, DECODED WHOLE.**
The producer copies the base net's, and `nets::Compare` reads that field
(`UHDM/build/generated/src/nets.cpp:277`).  Golden's def-view base net answers:

```
                                  UNINSTANTIATED   INSTANTIATED
inline `logic [3:0] x [dim]`            36              36
a VECTOR TYPEDEF `tv_t x [dim]`       none              36   <-- the split
int / real / string / class handle    none            none
a packed- or unpacked-struct typedef  none            none
an enum typedef                       none            none
a package-qualified packed struct     none               1   (R3)
```

measured on `a1`/`a6`/`a8` (uninstantiated) against `a2`/`a10`/`a12`/`a13`
(instantiated) — the same discriminator r10v224's `v12_innernt` found on one
arm, now read across seven.  The pristine build stamped a bare `36` on every
inner net and r10v224's fix carved out only the struct-element form; this law
answers the whole field: the base net's value, plus the instantiated
vector-typedef `36`.  A literal copy alone would have moved **5 `a13` cells,
3 `a12` and 2 `a10` AWAY**, because our BASE net does not yet carry that 36 —
that base-net half is **R1**, and it is not this pass.

**THE TYPEDEF'S HOME IS NOT PART OF THAT GATE, and the wide boundary is what
said so.**  The first cut transcribed `netTypeFor`'s module-road exclusion of a
PACKAGE-scoped alias, and the boundary re-score convicted it: **AWAY 10**, five
arms × two views, every one an INSTANTIATED interface declaring
`<pkg typedef> x [dim];` through a wildcard import (`grid224/a8_instantiated`,
`grid224/a9_kinds`, `vgrid224/v7_inst`, `v11_multiinst`, `v12_innernt`).
`v12_innernt` states the whole rule on one golden in one file: `tvc_t x [1:0]`
with `tvc_t` from package `p224vc` reads `36` in the instantiated interface and
NOTHING in the uninstantiated one.  The exclusion was removed and the boundary
re-run to **AWAY 0**.  A predicate transcribed from a sibling law is a guess
until an arm measures it.

**The index typespec's KIND** is corrected at this call site only: golden reads
`bit_typespec` for `[bit]` and `[bit[7:0]]` where the shared `assocIndexTs`
factory hands back `logic_typespec` for every non-predefined integral.  Neither
object carries a range or a sign, so the whole difference is the kind.  The
factory also serves class properties, package and module variables and the
elaborated listings, none of which this pass measured — that wider correction
is **R-G**.

**R-C, honoured.** `innernt224.py` was run beside every census of this grid,
and the field it exists to catch is folded into `anetcen225.py` itself.

### (5) THE CENSUS, AND THE TWO THINGS IT CAUGHT

**THE A-PRIORI PREDICTION, made before the patched sweep was scored.**
`R10E225_DBG=1` makes the emitter name on STDERR every cell this law touches —
each array_net it MINTS (with `pris=` telling whether the pristine gate would
have minted one at all), each one the written-dimension gate REMOVES, and each
R-A verdict that differs from r10uvm224's — and it writes NOTHING to the
database, proved by hand (the same source compiled with and without the
variable gives byte-identical `.uhdm` files).  `predict225.sh` replays the
EXACT command line the harness recorded in every row's `cmds.txt`, into scratch
of its own:

```
uhdm2rtlil  LISTED 1462  PROCESSED 1462  HIT_ROWS 0
surelog     LISTED 1573  PROCESSED 1573  HIT_ROWS 2
              default/MiniAmiq   5 lines    testflags/MiniAmiq   5 lines
              all ten: MINT … pris=0, i.e. objects that did not exist before
              zero REMOVE, zero RA-FLIP, anywhere in either corpus
```

so **the u2r zero was PREDICTED before it was measured**, and the surelog mover
set was named down to the cell.  byteverify then read **MOVERS 0/1358** on
uhdm2rtlil and **2/956** on surelog — the same two rows, and nothing else.
The predicted set and the measured set are the same set.

**THE ORPHAN THE CENSUS CAUGHT, and it is the pass's sharpest ops lesson.**
The first patched build read **MOVERS 130/1358 on uhdm2rtlil** with `ct8rows`
still PASS and every status still `CMP_EQUAL` — and the uhdm-dump of a mover
was IDENTICAL to pristine line for line.  The cause: `makeIfaceDefArrayNet225`
minted its `array_net` and its range vector BEFORE asking the
written-dimension gate, and `s.Make…` hands out an object the serializer then
WRITES, so every def-view interface net in the corpus left an orphan array_net
in the file.  It is invisible to `uhdm-cmp` (nothing references it) and
invisible to a dump diff (nothing prints it), and only the byte gate sees it.
The gate now runs FIRST (`writtenUnpackedDims225`), and the same row is
byte-identical again.  **A `Make…` call is a write; never mint on a path that
can still decline.**

### (6) THE LAW GATED — AND THE BOUNDARY'S OWN CONVICTION

All gates green; the numbers are in `GATES.r10uvm225.txt`.  In one line:
goldens 23/0 and `/bin/false` 0/23; uhdm2rtlil 679/50/2 in both modes with
`ct8rows` at zero differing rows against the committed baseline AND both of
this pass's own pristine controls, and byteverify **0/1358**; surelog 476/5 +
470/5 with **zero differing STATUS rows over 1588** against the committed
baseline and against this pass's own pristine control, whole-row `ct8rows`
PASS outright, and byteverify **2/956** — the two MiniAmiq row-modes, both
predicted by name; the nine converted row-modes and Rggen/default at judge rc
**zero** on both columns (rowheads); canaries 52/8 changed=0, ctcan2 both PASS,
canaudit PASS; the five protected databases byte-identical with SVSwitch on
`4842211c4030` and YosysVerx on `6ccda350c24a`.

**THE GOLDEN GRID, three-way** (`armdelta225.sh`, keyed on
holder × name × occurrence, comparing every field `anetcen225.py` records):

```
TO-GOLDEN 114    AWAY 0    STILL-WRONG 15    SAME-RIGHT 11
```

and positionally — the way the judge compares the vector — `MISSING 123 /
EXTRA 17 / DIFF 6 / SAME 8` becomes `MISSING 21 / EXTRA 14 / DIFF 4 /
SAME 112` out of 125 golden cells.  The 15 STILL-WRONG are all pre-existing
base-net and elab-view residues, named in §4's residue list.

**THE WIDE BOUNDARY** — the only gate that convicts a corpus-invisible
regression:

```
LISTED 5619   PROCESSED 5619   RC_DIFFS 0   MOVED_ARMS 170 (85 sources x 2 views)
re-scored against a FRESH Surelog per moved arm:
   TO-GOLDEN 538   AWAY 0   STILL-WRONG 66   SAME-RIGHT 246
   9 arms whose own Surelog compile fails — error recovery, not golden
```

170 moved arms is what a WIDE law looks like: every probe arm in the tree with
an interface declaring an unpacked signal.  **The boundary earned its keep**:
its first run read **AWAY 10** and convicted the package-typedef exclusion in
R-B (see above).  No must-stay family moved, and no arm moved on any axis but
this law's.

**NO CONVERSION IS CLAIMED and `results/*.csv` were NOT edited.**  MiniAmiq
stays `CMP_NOTEQUAL` in both modes: the ladder did not bottom out — it moved
one rung, and the next rung is R0.

---

## 2. THE HEAD MOVED — AND IT IS PROVED, NOT ASSERTED

The patched MiniAmiq cmp log is **byte-identical to the pristine one**
(`ed1744b60687`, both modes, 713053 lines, one head).  That is not a
non-result: the head is the VECTOR overload's `LHS: <the owner>` /
`RHS: <null>` signature (RESUME §9), which prints **the same two lines
whichever of the owner's vectors failed**.

`ct225field.cpp` (MEASUREMENT-ONLY; `uhdm-cmp` remains the sole judge) walks
`instance::Compare`'s and `interface_inst::Compare`'s own field sequences in
source order through ONE `CompareContext`, exactly as the shipped walk does,
and names the field:

```
PRISTINE   Nets       golden=71  ours=71  agrees
           Array_nets golden=5   ours=null  <-- DISAGREES
           …          Process    golden=1   ours=null  (not reached)
           FIRST-DISAGREEING-FIELD Array_nets

PATCHED    Nets       golden=71  ours=71  agrees
           Array_nets golden=5   ours=5     agrees
           Variables … Interface_arrays     agrees
           Process    golden=1   ours=null  <-- DISAGREES
           FIRST-DISAGREEING-FIELD Process
```

The five array_nets **compare EQUAL under the shipped `Compare`**, not merely
under this pass's census.  MiniAmiq's five, field for field, are identical to
golden's (`MINIAMIQ.anet.txt`).

**THE SUCCESSOR, PREDICTED BOTH WAYS.**  It was predicted before the run that
the head object would NOT change and the failing field would advance to
`Process` (golden 1, ours 0) — r10uvm224's R1 — because `Process` is the next
null vector on the same owner and every field between it and `Array_nets` is
null-on-both.  Had the array_nets disagreed instead, the head would have stayed
`Array_nets` with the SAME 713053 lines, which is exactly why the field probe
exists.  Both readings were prepared; the measured one is `Process`.

---

## 3. FILES

* `grid225/` (13 arms), `grid225.sh` — the golden grid and its driver.
* `anetcen225.py` — the array_net census (vector-positional, inner-net
  `vpiNetType` included).
* `basenet225.py` — the base-net census, the precondition of the inner copy.
* `gscore225.sh` — golden-vs-ours per arm; `armdelta225.sh` — the THREE-WAY
  score (TO-GOLDEN / AWAY / STILL-WRONG / SAME-RIGHT).
* `ct225field.cpp` — the head-field probe of §2.
* `predict225.sh` — the a-priori mover prediction (`R10E225_DBG=1`).
* `bound225.sh` — the wide boundary.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the gate copies run here.
* `GATES.r10uvm225.txt`, `GRID.r10uvm225.txt`, `ARMDELTA.r10uvm225.txt`,
  `PREDICT.r10uvm225.txt`, `BOUNDARY.r10uvm225.txt`, `HEADFIELD.r10uvm225.txt`,
  `MINIAMIQ.anet.txt`.

---

## 4. RESIDUES

* **R0 — THE NEW MiniAmiq HEAD: THE INTERFACE DEFINITION'S `Process()`,
  golden 1, ours 0.**  Now the head, both modes, MEASURED by name
  (`HEADFIELD.r10uvm225.txt`), with the same VECTOR-overload signature and the
  same 713053 lines — the cmp log does not change when this rung is taken
  either, so the successor MUST run the field probe and not the line count.
  It is r10uvm224's R1 (uvm223's R2): golden's uninstantiated
  `svaunit_vpi_interface` lists its `initial` as one `vpiProcess` and we list
  none.  `interface_inst::Compare` reaches it after `Interface_arrays` and
  before `Ports`, and every field between `Array_nets` and it is null on both
  sides in this row — so `Process` is the whole remaining distance to the next
  object.  A narrow, well-fenced arm: one `initial` block in a definition view
  nobody elaborates.
* **R1 — THE BASE NET'S `vpiNetType` IS THE OTHER HALF OF R-B.**  Golden gives
  a def-view interface net whose written element type is a VECTOR TYPEDEF
  `vpiNetType 36` when the interface is INSTANTIATED; we give it none, so
  `basenet225.py` reads 17 DIFF cells across `a2` (3), `a10` (2), `a12` (3) and
  `a13` (9).  This pass answers the field on the array_net's INNER element net
  — the object it owns — and does NOT touch the base net, because that is a
  law over every def-view interface net and needs its own grid and its own
  a-priori census.  The full measured table is in §1(4).  A package-qualified
  packed struct is a third value there (`1`, vpiWire) and our
  `isPkgStructType(descendUnpacked=true)` does not descend a DYNAMIC array, so
  `a10`'s `s_dynpq225` is wrong on both binaries.
* **R2 — THE ELABORATED INTERFACE VIEW'S `Array_nets()` IS A DIFFERENT,
  NARROWER LAW.**  Golden's elaborated interface lists an array_net **only for
  a PACKED-STRUCT element**, and then for every container kind: `a10`'s
  `work@top225_se.u_se225` lists `s_fixsp225`, `s_dynsp225`, `s_qsp225`,
  `s_assp225` and `s_dynpq225` and NOTHING else — not the unpacked-struct one,
  not the typedef or int ones.  We list the two FIXED struct arrays (one of
  them an unpacked struct golden does not list) and no dynamic/queue/assoc.
  4 MISSING + 1 EXTRA on one arm.  UNTOUCHED by this pass and measured so: our
  elaborated cells are the same before and after.  Its producer is
  `NetlistElaboration::elabSignal`, not `writeNets`.
* **R3 — THE HOISTED IMPORT LIST DROPS A FIXED UNPACKED PACKAGE VARIABLE.**
  `collectImportedPkgVars`'s `modelled` filter excludes
  `FixedSizeUnpackedArrayType` (and the unpacked struct/union) by design —
  "the unpacked aggregates still are not [modelled]" — so golden's six hoisted
  nets in `a5_imported`'s `if225_imp1` are five for us, and the array_net that
  would ride the sixth is missing with it.  That is a BASE-NET gap on
  § wildcardImportCopiesPkgVarsToDefNets223's road, not this law's: 4 of
  `a5`'s 9 STILL-WRONG cells are it (1 + 3 import copies).  MiniAmiq's own
  hoisted pair is ASSOCIATIVE and is listed, which is why the head still moved.
* **R4 — THE HOISTED NET'S OWN `vpiNetType` DOES NOT DESCEND THE CONTAINER.**
  `emitImportedPkgVarNets` stamps 36 for a four-state integral declaration by
  asking the WHOLE declared type, so `tvq225_t pg_astv225 [string]` (canonical
  `AssociativeArrayType`, not integral) gets none where golden gives 36 —
  and, since the inner element net copies the base verbatim, the array_net's
  inner net inherits it.  4 more of `a5`'s STILL-WRONG cells.  Cheap, and it
  belongs to the hoist law.
* **R-G — `assocIndexTs` ANSWERS `logic_typespec` FOR A TWO-STATE INDEX.**
  Golden reads `bit_typespec` for `[bit]` and `[bit[7:0]]`.  Corrected at this
  pass's call site only (a measured, zero-blast-radius local mint); the shared
  factory also serves class properties, package and module variables and the
  elaborated listings, none of which this pass measured.
* **R5 — A PORTED INTERFACE WITH NO TOP-LEVEL MODULE IN THE DESIGN SEGFAULTS
  THE PRISTINE BINARY.**  `interface ifx(input logic clk); int x; endinterface`
  alone in a file exits **139** on the pristine build (and on the patched one);
  adding ANY module — even an empty one — makes it exit 0.  The non-ANSI form
  crashes too, the empty-parens and no-parens forms do not.  Found while
  building this grid (arm `a6_headerforms` crashed until a `module top225_hdr;`
  was added, which is why every arm here carries a top) and PRE-EXISTING.  No
  corpus row reaches it, so it costs nothing today, but `verify_golden.py`
  records rc=139 as `SLANG_REJECT` wearing the last stderr warning — a future
  row of this shape would be silently mis-classified.
* **R6 — A `$unit`-SCOPE `typedef int` / `typedef string` IS A SLANG_REJECT**
  ("typedef target: PredefinedIntegerType" / "StringType",
  `UhdmExporter.cpp:6220`), while the same typedef inside a component or a
  package is fine — the `$unit` typedef listing has a narrower kind gate than
  the component one (`TypeEmit.cpp:13797`).  Every grid arm here declares its
  atom typedefs inside the component for that reason.  A standing fence, in the
  same family as r10v224's R-D (`typedef t a [string]` is a reject too).
* **R7 — A NON-ANSI INTERFACE PORT'S NET SORTS LAST FOR US, FIRST FOR GOLDEN**
  (r10uvm224's R4, unchanged and visible again in `a6_headerforms`'
  `if225_na`: golden's net list is `pa225, n_dyncls225, …` and ours is
  `n_dyncls225, …, pa225`, so the whole list is shifted by one slot and every
  typespec reads against the wrong neighbour).  The MULTISET is exact; only the
  order differs.  It costs `a6` nothing in the array_net census because the
  array_nets follow declaration order on both sides.
