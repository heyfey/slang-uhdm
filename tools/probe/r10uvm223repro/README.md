# r10uvm223 — § wildcardImportCopiesPkgVarsToDefNets223

**An interface definition's net list opens with the MATERIALIZED
imported-package data, exactly as a module's and a `program`'s do.**

Base commit `8eebf86e`. One production conjunct: the module road's own hoist,
moved into a member and called by `emitInterfaceDef`.

---

## 1. THE LAW

Surelog runs ONE producer for every definition-view holder.
`CompileHelper::importPackage` (`src/DesignCompile/CompileHelper.cpp:127-197`)
copies the imported package's registries into the IMPORTING SCOPE's, and its
Nets arm, `:183-190`, is

```cpp
auto& netSet = def->getSignals();
for (auto& net : netSet) {
  if (!object_name.empty()) { if (net->getName() != object_name) continue; }
  scope->getSignals().push_back(net);
}
```

`scope` is the importing `DesignComponent`. **The function asks nothing about
the holder's kind.** An interface is a `ModuleDefinition` in Surelog exactly as
a module is, `CompileModule::collectModuleObjects_` runs the same
`paPackage_import_item` arm for it (`CompileModule.cpp:600-604`, plus the
FILE-scope pre-pass at `:570-580`), and `UhdmWriter::writeInterface`'s
`mod->getSignals()` (`UhdmWriter.cpp:1679`) hands that one vector to the same
`writeNets` that `writeModule`'s `mod->getSignals()` (`:1457`) hands it.

Our `emitModuleDef` had carried that hoist since r10apb2/apb3 — the listing
`collectImportedPkgVars` / `collectMaterializedPkgs` build
(`src/EmitHelpers.h:2204`, `:2346`), with its multiplicities (a module-scope
`import p::*` copies once, a file-scope one twice, both together three times),
its transitive hop (`§ transitiveImportRidesTheHoist217`) and its
out-of-body-constructor locals (`§ oobCtorLocalsRideTheImport203`). A
`program` takes the module road and had it too. **Only `emitInterfaceDef` did
not ask.**

The production change:

```cpp
    auto* nets = s.MakeNetVec();
+   emitImportedPkgVarNets(body, iface, prefix, info, nets);
    UHDM::VectorOfarray_net* ifaceArrayNets9 = nullptr;
```

`emitImportedPkgVarNets` is `emitModuleDef`'s own loop, moved out verbatim.
No new listing, no new order rule, no new flag, no new counter.

**AND THE TRILOGY'S FACT, CONFIRMED IN THE SOURCE:** `writeInterface` never
calls `lateBinding` — the only two calls belong to `writeModule` (`:1572`,
`:1622`). uvm222's R0 attributed the 66 nets to `lateBinding`'s implicit-net
fallback; that is **REFUTED**. Every one of them carries its uvm-1.2
DECLARATION's own span (a `bit_typespec` at `26:1-26:35`, a `string_typespec`
at `223:1-223:7`, …), and the interface definition's net list is settled
entirely at COMPILE time by the import copy.

---

## 2. THE HEAD

| | |
|---|---|
| re-measured on this pass's own pristine build FIRST | **MiniAmiq ×2, 1 388 494 cmp lines / ONE head each**, the two logs byte-identical — uvm222's R0 reproduced exactly. Every other row at BASE: SeqDriver ×2 **0**, SimpleUVM ×2 **0**, Scoreboard/default **0**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**. The pristine binary is byte-identical to the main-tree build at `8eebf86e` (md5 `127920b3fce5…`). |
| after | **MiniAmiq ×2, 17 cmp lines / ONE head each**, logs byte-identical. `LHS: <null>` — a `ref_typespec` under OUR `sva_info` net. **R0.** |

`instance::Compare` (`generated/src/instance.cpp:335-337`) reads `Task_funcs()`
then `Nets()`. The pristine head was a `Nets()` VECTOR SIZE mismatch, 71 vs 5,
which names the OWNER — so the 1 388 494 lines were that interface instance's
whole decompile, not a distance. The patched walk goes **into** the net list
and gets to net #69 before it stops:

```
GOLDEN   vpiNet 71   vpiArrayNet 5   vpiProcess 1
PRISTINE vpiNet  5   vpiArrayNet 0   vpiProcess 0
PATCHED  vpiNet 71   vpiArrayNet 0   vpiProcess 0
```

and the 71 match golden **slot for slot** (kind + name + span, ordered
sequence, 71 of 71) — not as a multiset. The official judge itself walked nets
#1..#68, each one's `ref_typespec` and that ref's `Actual_typespec`, and
returned equal on every one.

**THE NEW HEAD IS PRE-EXISTING, NOT MINTED HERE.** Golden's `sva_info` net
carries no `vpiTypespec` at all; the PRISTINE ours database already carried
one (`ref_typespec` → `class_typespec(svaunit_concurrent_assertion_info)`,
`87:4-87:37`), verbatim. The law only lifted the size mismatch that had been
masking it.

---

## 3. THE 66, AND WHY THERE ARE 66

`svaunit_vpi_interface.sv:26-27` writes

```systemverilog
import svaunit_pkg::*;
import uvm_pkg::*;
```

and `svaunit_pkg` itself wildcard-imports `uvm_pkg`, so its signal vector
ALREADY holds `uvm_pkg`'s 33 entries when the interface imports it. Surelog
never de-duplicates — `importPackage` appends the vector AS IT STANDS — so the
interface's list is **33 twice**, then its own five declared variables. Ours
now reads exactly that. The 33 are `uvm_pkg`'s own variable listing
(`uvm_start_uvm_declarations` @26:5 … `s_spaces` @25:14); `DECODE.r10uvm223.txt`
names all of them.

---

## 4. THE A-PRIORI PREDICTION — THE PASS'S HARDEST GATE

`predict223.sh`, `PREDICTOR.instrumentation.txt`,
`PREDICT.stage.surelog.txt`, `PREDICT.stage.uhdm2rtlil.txt`.

A database-side signature cannot decide this law: the FILE-SCOPE import road
leaves **no object in either database** (grid arm a8 — neither golden nor ours
writes an `import_typespec` for it). So the prediction was computed by a THIRD
binary whose OBSERVABLE BEHAVIOUR IS PRISTINE: with `SLANG223_PRED=1` it
declines the mint and only reports the hoist's size per interface definition.
`predict223.sh` re-runs EVERY row-mode's OWN recorded slang command line and
asserts, per row, that the database it writes is byte-identical to the
pristine sweep's.

| corpus | rows | databases byte-identical to pristine | DB-DIFFERING | HIT-ROWS |
|---|---|---|---|---|
| uhdm2rtlil | 1458 | **1358 / 1358** | **0** | **0** |
| surelog | 1523 | **956 / 956** | **0** | **2** |

```
HIT default   MiniAmiq  ifaces=1  hoisted=66
HIT testflags MiniAmiq  ifaces=1  hoisted=66
```

**THE u2r ZERO IS PROVEN, NOT ARGUED:** no uhdm2rtlil design has an interface
definition that materialises even one imported package variable. The patched
sweep then measured `byteverify` **0 / 1358** and **2 / 956 — the two names,
a priori**.

One ops note paid for here: the two corpora share twelve test names, and a
name-only directory lookup compiled seven surelog rows from the *uhdm2rtlil*
sources and read them as movers. The lookup is corpus-tagged now.

---

## 5. THE GOLDEN GRID

`grid223/`, `grid223.sh`, `cells223.py`, `gscore223.py`,
`GRID.rc.r10uvm223.txt`, `GRID.cells.r10uvm223.txt`,
`GRID.score.r10uvm223.txt`.

Thirteen arm SUBDIRECTORIES compiled with the **canonical golden-side
Surelog** — the one `scripts/verify_golden.py` names,
`$HOME/git-repos/Surelog/build/bin/surelog` — and with both binaries; **every
arm's rc on both sides is recorded** and a non-zero one is printed loudly.

Cells are the depth-keyed `(owner, field, kind, name, span)` listing of each
instance's direct `vpiNet` / `vpiArrayNet` / `vpiVariables` / `vpiProcess`
children; the columns are order-blind MISSING/EXTRA.

| arm | what it crosses | pristine MISS/EXTRA | patched | verdict |
|---|---|---|---|---|
| `a1_iface_wild` | interface × wildcard import of a package holding int / string / vector / fixed array / assoc array / typedef / parameter / function | 8 / 0 | **4 / 0** | TOWARD |
| `a2_iface_expl` | EXPLICIT `import p::name` alone, and explicit + wildcard together | 4 / 0 | **0 / 0** | TOWARD (multiset exact; see R3 for the slot order) |
| `a3_module_wild` | the MODULE road, uninstantiated and instantiated | 4 / 0 | 4 / 0 | **UNCHANGED — the two databases are byte-identical** |
| `a4_inst_iface` | an INSTANTIATED interface (the fence's first face) | 4 / 0 | **2 / 0** | TOWARD; def view now EXACT, elab view is R4 |
| `a5_chain` | importing BOTH ends of a package chain (the corpus shape) | 3 / 0 | **0 / 0** | TOWARD, ORDERED-EQUAL |
| `a6_pkg_import` | a package that imports a package, imported once | 2 / 0 | **0 / 0** | TOWARD, ORDERED-EQUAL |
| `a7_prog` | a `program` and an interface importing the same package | 1 / 0 | **0 / 0** | TOWARD, ORDERED-EQUAL (the program half was already exact) |
| `a8_unit` | a COMPILATION-UNIT (file-scope) import, interface + module | 2 / 0 | **0 / 0** | TOWARD, ORDERED-EQUAL — the DOUBLING reproduced |
| `a9_assoc` | the four container shapes (assoc / dynamic / queue / fixed) | 10 / 0 | **7 / 0** | TOWARD; R1 and R2 are what remains |
| `a10_ports` | an interface with PORTS × a wildcard import | 5 / 1 | **3 / 1** | TOWARD; def view EXACT including the ORDER (imported, then ports, then body) |
| `a11_modport` | an interface with a MODPORT (the InterfaceModPort shape) | 3 / 0 | **2 / 0** | TOWARD; def view EXACT |
| `a12_noimport` | an interface and a module that import NOTHING | 0 / 0 | 0 / 0 | **UNCHANGED, byte-identical — the must-stay-empty fence** |
| `a13_ifaceproc` | an interface's `initial`/`always`, uninstantiated and instantiated | 2 / 0 | 2 / 0 | **UNCHANGED, byte-identical** (this is R2's own arm) |
| `a7b_class_reject` | a CLASS-scope package import | Surelog rc 0, **slang rc 3, no database** | same | unreachable |

**EXTRA never rises in any arm. Golden's own listing is identical on both
runs (asserted by `gscore223.py`).** Whole-dump, per arm: **REMOVED = 0** in
every one of the thirteen — the law only adds.

`a7b` is the arm that makes the gate exact at the holder boundary. Surelog
copies a class-scope import into a `ClassDefinition`, not into any net list;
slang refuses the construct outright ("package import not allowed in class
declaration", rc 3, no database). The construct cannot reach this emitter on
any input. **The rc IS the measurement.**

---

## 6. THE CENSUS AND THE MOVER

`CENSUS.MiniAmiq.wholedump.txt`, `CENSUS.MiniAmiq.added-lines.txt`,
`CENSUS.MiniAmiq.newly-extra.txt`, `HEAD.fields.r10uvm223.txt`.

Whole-dump order-blind diff, pristine vs patched MiniAmiq (1.89 M lines):
**1070 added, 0 REMOVED**, all 1070 attributable to the 66 new nets and their
typespec chains.

Against GOLDEN, order-blind multiset:

| | MISSING (golden-only) | EXTRA (ours-only) |
|---|---|---|
| pristine | 260 521 | 96 648 |
| patched | 259 525 | 96 722 |
| | **−996** | +74 |

Zero existing EXTRA lines disappeared. The 74 newly-appearing ones are the
typespec IDENTITY lines of the 66 new nets — 68 `\_<kind>_typespec:` headers
whose SPAN differs (`class_typespec (uvm_root)` reads `315:7-315:15` for us
and `315:7-315:41` for golden, i.e. golden's re-created typespec spans the
whole declaration), plus 4 `|vpiName:uvm_phase` and 2 a `class_defn`
back-reference. **No generated `Compare` reads VpiFile/VpiLineNo/VpiColumnNo**
(RESUME §9), and the judge proved it here: it walked all 66 of those nets and
their actual typespecs and returned equal.

---

## 7. GATES

`GATES.r10uvm223.txt` carries every number. In one line: build both, md5s
recorded, the pristine binary byte-identical to the main tree at `8eebf86e`;
goldens **23/0** with the negative control **0/23**; u2r **679/50/2 both
modes**, `ct8rows` PASS against the committed baseline and this pass's own
pristine in both modes, `byteverify` **0/1358**; surelog **476/5 + 470/5**,
`ct8rows` PASS against the committed baseline and this pass's own pristine,
`byteverify` **2/956 = exactly the two row-modes named BY NAME a priori**; the
ten protected CMP_EQUAL row-modes CMP_EQUAL on BOTH binaries at judge **rc 0**
(both columns scored explicitly); canaries **ok=52 / ok=8, changed=0**,
`ctcan2` PASS ×2, `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0**; all
pins SAME with `InterfaceModPort` byte-identical, `SVSwitch 4842211c4030` and
`YosysVerx 6ccda350c24a` on their pinned values. Every sweep's `cmds.txt`
audited BY BINARY PATH.

**NO CONVERSION.** MiniAmiq stays `CMP_NOTEQUAL` in both modes — **the ladder
has NOT bottomed out**: 17 cmp lines remain on a new head. `results/*.csv`
untouched.

`InterfaceModPort` is an INSTANTIATED-INTERFACE test and it did not move: its
two interfaces import no package at all, so the hoist is empty there. The
fence is measured, not assumed.

---

## 8. THE WIDE BOUNDARY

`bound223.sh`, `BOUNDARY.r10uvm223.txt`, `bscore223.sh`, `bcells223.sh`,
`armdelta223.sh`, `ARMSCORE/ARMCELLS/ARMDELTA.r10uvm223.txt`.

`LISTED = PROCESSED = 5559`, `RC_DIFFS = 0`, `MOVED_ARMS = 40` (20 arms ×
2 views). Twenty of the forty views are this pass's own grid arms;
`a3_module_wild`, `a12_noimport` and `a13_ifaceproc` did **not** move.

The ten foreign arms are, every one of them, **an interface that
wildcard-imports a package** — the law's own shape, found in ten unrelated
passes' arm sets. Re-compiled against the canonical golden-side Surelog and
re-scored:

| arm | def NEWLY-MISSING / cured | elab |
|---|---|---|
| `r10uvm217repro/grid217/g217_d_importer.sv` | 0 / 36 | 0 / 33 |
| `r10uvm88repro/v88_b3_scopes.sv` | 0 / 60 | 0 / 58 |
| `r10v209repro/arms/v209_p_ifprog.sv` | 0 / 66 | 0 / 63 |
| `r10v214repro/arms214/va5_modctx.sv` | 0 / 10 | 0 / 9 |
| `r10vbuvm19repro/vg19k.sv` | 0 / 30 | 0 / 24 |
| `r10vbuvm33repro/v33c.sv` | 0 / 11 | 0 / 9 |
| `r10vearl100repro/v3_gen100.sv` | 0 / 28 | 0 / 25 |

**TOWARD-GOLDEN 14 / 14 scorable arm-views. NEWLY-MISSING 0 everywhere.
AWAY 0, BROKEN 0.** The 182 newly-appearing EXTRA lines over all fourteen
views are structural filler (`|vpiParent:` ×86, `|vpiActual:` ×14,
`|vpiTypespec:` ×5, `|vpiClassDefn:` ×6, `|vpiNet:` ×3) and span-only typespec
headers (`\_int_typespec:` ×28, `\_string_typespec:` ×12, `|vpiSigned:` ×24,
`|vpiSize:` ×4) — no new named object golden lacks.

`bcells223.sh`'s blunter verdict column calls any rise in EXTRA "AWAY-GOLDEN",
which a MINT law necessarily triggers; `armdelta223.sh` is the arm's real
verdict — whether a golden line we USED to match stopped being matched — and
it is 0 on all fourteen.

Three arms are **unscorable and printed loudly**: `r10buvm34repro/g34a3.sv`,
`r10v144repro/v144_b_ctor.sv` and `r10vbuvm27repro/v27_a_homes.sv` are
rejected by **Surelog** (rc 4), so there is no golden; an arm whose compile
fails teaches error recovery, not golden (uvm215's lesson). All three are the
law's exact shape all the same, and slang's rc is identical on both binaries
(`RC_DIFFS = 0`).

**THE MUST-STAY FLOOR HELD.** Zero moved arms in `r10uvm216repro`,
`r10uvm218repro`, `r10uvm220repro`, `r10uvm221repro`, `r10uvm222repro` or
their verifier dirs, and zero in the buvm3-15 / sd8-12 families.
*(CORRECTED BY THE VERIFIER, r10v223: this sentence originally read "zero in the
uvm82-91 / buvm3-15 / sd8-12 families", which is wrong for uvm82-91 —
`r10uvm88repro/v88_b3_scopes.sv` DOES move in both views, as this README's own
foreign-arm table above records. The floor rule is "only cells your law names
may move", and it holds: the arm is 6/0 → 0/0 against golden with
NEWLY-MISSING 0, and the two cells that moved are imported-package nets in an
interface definition view. See `tools/probe/r10v223repro/BOUNDARY.r10v223.txt`.)*
The four slang-fenced tests are never dispatched (`canaudit`: each of the four
names "not dispatched by any driver (OK)", FENCE-BREACH 0).

---

## 9. FILES

| file | what |
|---|---|
| `DECODE.r10uvm223.txt` | the head both sides, the full cell census, the Surelog decode with the non-mints, the emitter site, the order rule. |
| `PREDICTOR.instrumentation.txt`, `predict223.sh`, `PREDICT.stage.*.txt` | the a-priori prediction and the pristine-behaviour binary that computed it. |
| `grid223/`, `grid223.sh`, `cells223.py`, `gscore223.py`, `GRID.rc.r10uvm223.txt`, `GRID.cells.r10uvm223.txt`, `GRID.score.r10uvm223.txt` | the golden grid, every arm's rc, every cell, the order-blind score. |
| `CENSUS.MiniAmiq.wholedump.txt`, `CENSUS.MiniAmiq.added-lines.txt`, `CENSUS.MiniAmiq.newly-extra.txt` | the mover, attributed line by line. |
| `HEAD.fields.r10uvm223.txt` | the head object's field counts, three databases, and the slot-for-slot net-list match. |
| `head_pris_MiniAmiq.*.head220.cmp`, `head_pat_MiniAmiq.*.cmp` | the head on both binaries, both modes (the pristine head's first 220 lines — the whole log is 1.39 M lines of one object's decompile; the patched head is 17 lines and is kept whole). |
| `BOUNDARY.r10uvm223.txt`, `bound223.sh`, `bscore223.sh`, `bcells223.sh`, `armdelta223.sh`, `ARMSCORE/ARMCELLS/ARMDELTA.r10uvm223.txt` | the wide boundary and the re-scoring of every moved arm. |
| `GATES.r10uvm223.txt` | every gate number, both binaries. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, copied unchanged from their canonical homes. |

---

## 10. RESIDUES

* **R0 — THE NEW MiniAmiq HEAD: OUR `sva_info` NET CARRIES A TYPESPEC GOLDEN
  DOES NOT.** 17 cmp lines, one head, both row-modes, logs byte-identical.
  `LHS: <null>` / `RHS: ref_typespec (work@svaunit_vpi_interface.sva_info)`
  → `class_typespec (svaunit_concurrent_assertion_info) 87:4-87:37`, under
  our `logic_net sva_info` at `87:38-87:46`. **PRE-EXISTING** — the pristine
  database carries it verbatim and golden's `sva_info` net has only
  `vpiParent`/`vpiName`/`vpiFullName`. Its three siblings `sva_info`,
  `cover_info`, `property_info` are the interface's three DYNAMIC arrays
  (`svaunit_concurrent_assertion_info x[];`), which is the tell: Surelog's
  `writeNets` only types a net from `orig_net->getTypeSpecId()`, and for an
  unpacked-dimension signal the element typespec rides the ARRAY_NET instead
  (see R1). Declining the typespec on a def-view interface net whose declared
  type has an unpacked dimension is the obvious next arm — and it must be
  measured, because a FIXED-size array net in the same position may not
  behave the same way.
* **R1 — THE INTERFACE DEFINITION'S `Array_nets()`: golden 5, ours 0**, and it
  is `Nets()`'s immediate successor in `instance::Compare`. DECODED:
  `UhdmWriter::writeNets` (`UhdmWriter.cpp:894-940`) has an arm gated
  `instance == nullptr && parent->UhdmType() == uhdminterface_inst` that mints
  an `array_net` (plus a LOC-LESS inner element net) for **any** signal with
  an UNPACKED DIMENSION — which is why a MODULE definition gets none and an
  interface definition gets one per unpacked signal, imported ones included.
  Ours mints one only when the canonical type is `FixedSizeUnpackedArrayType`,
  so all three DYNAMIC containers (`[]`, `[$]`, `[string]`) are dropped. Arm
  `a9_assoc` is the measured grid: golden's `work@if223l` lists four
  array_nets (assoc, dynamic, queue, fixed) and `work@m223l` lists none.
  MiniAmiq's five are `uvm_random_seed_table_lookup` twice (the imported
  associative array) and `sva_info`/`cover_info`/`property_info`. **A WIDE
  law — it reaches every interface with an unpacked signal — and it needs its
  own grid and its own a-priori census.**
* **R2 — AN UNINSTANTIATED INTERFACE'S DEFINITION VIEW LISTS NO PROCESS.**
  golden 1, ours 0, the successor after `Array_nets()`. Arm `a13_ifaceproc`
  isolates it on a five-line repro and it is UNTOUCHED by this pass (the two
  databases are byte-identical): golden gives `work@if223p` (uninstantiated)
  its `initial` AND its `always`, and gives `work@if223q` (instantiated) its
  `initial` in both the def and the elab view; we emit the process for the
  INSTANTIATED interface's def view and nothing for the uninstantiated one.
  A narrow, well-fenced arm.
* **R3 — AN EXPLICIT IMPORT'S COPY SORTS AFTER THE WILDCARD'S, NOT AT ITS OWN
  SOURCE SLOT.** Arm `a2_iface_expl`, `if223c` (`import p223b::pv_two223;`
  then `import p223b::*;`): golden's net list is `pv_two223, pv_one223,
  pv_two223, own223c` — the explicit item's copy first, at its own line —
  while ours is `pv_one223, pv_two223, pv_two223, own223c`. The MULTISET is
  exact (this pass took the arm from 4 missing to 0); only the slot order
  differs. PRE-EXISTING in `collectMaterializedPkgs`, which accumulates
  wildcard packages and never interleaves the explicit items; the module road
  has the same shape and no corpus row exercises it. Its own arm and its own
  grid.
* **R4 — AN INSTANTIATED INTERFACE'S ELABORATED VIEW DOES NOT LIST THE
  IMPORTED PACKAGE VARIABLES.** Arms `a4_inst_iface`, `a10_ports`,
  `a11_modport`: golden's `work@top223d.u_if223` lists `iv_one223`,
  `iv_two223` as `vpiVariables` beside the interface's own, and ours lists
  only its own. This pass is DEFINITION-VIEW ONLY; the module road's elab
  half already does this (`a3`'s `work@top223c.u223b` is exact on both
  binaries), so the fix is the second call site — but it must be measured
  separately, because `InterfaceModPort` and every other instantiated-
  interface canary lives there.
* **R5 — THE FIXED-SIZE UNPACKED ARRAY IS DECLINED BY THE HOIST ITSELF,
  ON BOTH ROADS.** `collectImportedPkgVars`' `modelled()` predicate
  (`src/EmitHelpers.h:2346`) drops `FixedSizeUnpackedArrayType`,
  `UnpackedStructType` and `UnpackedUnionType`. Arm `a1` (`pv_arr223 [4]`)
  and arm `a9` (`lv_fixed223 [3]`) show it on the INTERFACE road and arm `a3`
  (`mv_arr223 [2]`) shows the identical gap on the MODULE road, unchanged on
  both binaries. PRE-EXISTING, shared, and not this law's business.
* **R6 — THE RE-CREATED TYPESPEC'S SPAN IS THE TYPE NAME, NOT THE WHOLE
  DECLARATION.** `class_typespec (uvm_root)` reads `315:7-315:15` for us and
  `315:7-315:41` for golden; 68 of the 74 newly-appearing EXTRA census lines
  are this. No generated `Compare` reads a span, so it is dump fidelity only
  — and the judge demonstrated it by walking all 66 of these typespecs and
  returning equal. PRE-EXISTING on the module road for the same reason.
