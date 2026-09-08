# r10v223 — ADVERSARIAL VERIFICATION of r10uvm223

Verdict: **ACCEPT WITH FIX.** The law is right and the head moves exactly as
claimed; one cell of the patch was **pristine-right → patched-wrong on legal
SV** and is fixed here, in the same arm, gated.

Base commit `8eebf86e`. Worktrees `/tmp/wt_v223` (patched + fix) and
`/tmp/wt_v223pris` (pristine), scratch `/tmp/v223_*`, binaries frozen at
`/tmp/v223_bin/{pris,pat,fix}.bin`.

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Both binaries built by this verifier from its own worktrees, `-j 2`:

| binary | md5 |
|---|---|
| pristine (`8eebf86e`) | `127920b3fce552846e1e8f8ac595c0b8` — **byte-identical to the main tree's `build/slang-uhdm`** |
| patched (`/tmp/r10uvm223.patch`, md5 `572b94f05e6d3ed81a177fb2f1f3de0d`) | `042d957f9f100891fc1ac25c6b3a3d5f` |
| patched + this verifier's fix | `3a8d774326e1c5523f420e7d50fc41cc` |

The implementer's two md5s are reproduced exactly, so the build is
deterministic and the measurements below are on the same objects.

**THE HEAD** (`rowheads.sh`, official `uhdm-cmp`, LHS = golden, one head per
row asserted by `grep -c '^LHS:'`), measured on this verifier's own sweeps:

| row | pristine | patched |
|---|---|---|
| MiniAmiq / default | **1 388 494 cmp lines, ONE head** | **17 cmp lines, ONE head** |
| MiniAmiq / testflags | **1 388 494, ONE head** | **17, ONE head** |
| SeqDriver, SimpleUVM, Scoreboard/default, BuildUVMPkg, Earlgrey_0_1, Rggen/default | 0 / rc 0 | 0 / rc 0 |

The head object, measured on the three dumps directly:

```
work@svaunit_vpi_interface (definition view)   vpiNet  vpiArrayNet  vpiProcess
GOLDEN                                            71         5           1
PRISTINE                                           5         0           0
PATCHED                                           71         0           0
```

and the 71 nets are **equal to golden slot for slot as an ORDERED sequence**
(kind + name + span, 71 of 71) — verified independently here, not taken from
the report. The new head (`LHS: <null>` on our `sva_info` `ref_typespec`) is
**pre-existing**: the pristine database carries the same five
`work@svaunit_vpi_interface.sva_info` lines, and the patched database has the
same five. Only the mask lifted.

Census MiniAmiq, order-blind whole-dump, path-normalised: **+1070 lines, −0**.
Against golden: MISSING **−996**, EXTRA **+74**; **no EXTRA line disappeared**,
and the 74 new ones are typespec identity/span headers plus four `|vpiName:`
and two `class_defn` back-references — no generated `Compare` reads a span,
and the judge proved it by walking all 66 new nets and returning equal.

---

## 2. THE FINDING — § interfaceDefViewNeverLateBinds223v

**An interface definition's reference to a wildcard-imported name STAYS BARE.
The patch made it bind to the newly hoisted net. Golden does not.**

`arms/v19_uninst_refactual/dut.sv` — one package, one interface and one
module that both import it and both USE the imported name:

| | golden | pristine | patched | fixed |
|---|---|---|---|---|
| `work@m_v19` cont-assign ref → `lv19` | `vpiActual → logic_net work@m_v19.lv19` | same | same | same |
| `work@if_v19` cont-assign ref → `lv19` | **no `vpiActual` at all** | **none — MATCHES** | `vpiActual → logic_net work@if_v19.lv19` — **DIFFERS** | **none — matches again** |

`ref_obj::Compare` reads `Actual_group` (RESUME §9 names it: buvm13/15's
heads were exactly this field), so the cell is judge-visible, and the patch
moved it AWAY from golden on legal SV.

**THE DECODE, in the same source the pass's own law cites.**
`UhdmWriter::writeModule` (`UhdmWriter.cpp:1402-1625`) calls
`lateBinding(s, mod, m)` twice, at `:1575` and `:1623` — that pass is what
resolves a module definition view's bare references to the module's own
hoisted copies. `UhdmWriter::writeInterface` (`:1626-1794`) **never calls it**
— the only other calls in the file belong to `writePackage` (`:1304`),
`writeElabProgram` (`:2072`) and `:4785`. The interface definition therefore
gets the LISTING (`writeNets` on `mod->getSignals()`, `:1679`) and never the
BINDING. That is the same fact the pass used to refute uvm222's R0; its
consequence for the binding side had not been applied.

**THE FIX** (production, 3 lines of behaviour):
`emitImportedPkgVarNets` gains a `bindRefs` parameter; the module/`program`
call site passes `true`, `emitInterfaceDef` passes `false`, and the
`info.nets[iv9] = n9` registration — the def-view name-binding map, and
nothing else — is keyed on it. The nets themselves, their order, their
typespecs and every other field are untouched, which the arms confirm: the
fixed and patched databases are **byte-identical on 16 of the 19 scorable
arms**, and on the other three the whole delta is the two lines of the
over-binding:

```
<       |vpiActual:
<       \_logic_net: (work@if_v19.lv19), line:5:15, endln:5:19
```

`arms/v20_refsites` measures **every reference site** — cont-assign, `always`,
function body, task body — for an uninstantiated and an instantiated
interface:

| | golden | pristine | patched | fixed |
|---|---|---|---|---|
| uninstantiated `if_v20u`, 4 refs | 4 bare | 4 bare | 3 bare + **1 bound** | **4 bare — GOLDEN EXACT** |
| instantiated `if_v20i`, 3 refs | 3 bound (to the ELAB variables) | 3 bare | 2 bare + 1 bound to the DEF net | 3 bare (= pristine) |

So the fix restores exact golden agreement where golden is bare, and is
judge-neutral where golden binds the elaborated variable (neither the def net
nor a null actual equals a `logic_var` named `work@top.u_if.<name>`; that is
R4's family, named below and untouched by either binary).

---

## 3. THE ADVERSARIAL GRID — 20 arms, every rc recorded

`v223grid.sh` (the pass's driver, re-pointed at `arms/`), `cells223.py`,
`gscore223.py`. Compiled with the CANONICAL golden-side Surelog — the one
`scripts/verify_golden.py` names, `$HOME/git-repos/Surelog/build/bin/surelog`
— and with each frozen binary. Cells are the depth-keyed
`(owner, field, kind, name, span)` listing of each instance's direct
`vpiNet`/`vpiArrayNet`/`vpiVariables`/`vpiProcess` children; columns are
order-blind MISSING/EXTRA. **Golden's own listing is byte-identical across all
three runs (asserted).**

| arm | the face it attacks | pris | patched/fixed | verdict |
|---|---|---|---|---|
| `v1_pkg_nodata` | a package with ONLY typedefs, parameters, enum, class, function, task | 0/0 | 0/0 | **UNCHANGED, the two databases byte-identical — the must-stay-EMPTY face** |
| `v2_expl_nonvar` | EXPLICIT import of a typedef / parameter / class / function; and of the one real variable | 1/0 | **0/0** | TOWARD, ORDERED-EQUAL; the non-data interface `if_v2a` **did not move at all** |
| `v3_collide` | two packages declaring the SAME name, both wildcard-imported | 4/0 | **0/0** | TOWARD, ORDERED-EQUAL |
| `v4_shadow` | the interface declares its own net with an imported name's spelling | 2/0 | **0/0** | TOWARD, ORDERED-EQUAL; the local `sv4` ref still binds the LOCAL net |
| `v5_escaped` | escaped identifiers in the package and the interface name | 3/1 | **1/1** | TOWARD; the 1 EXTRA is a PRE-EXISTING span-only residue on the interface's OWN net, identical on both binaries |
| `v6_export` | `export p::*` re-export, imported one hop later | 5/0 | **0/0** | TOWARD, ORDERED-EQUAL |
| `v7_filescope_noimport_iface` | a FILE-SCOPE import and an interface that imports NOTHING of its own | 10/0 | **0/0** | TOWARD, ORDERED-EQUAL — the file-scope copy reaches an interface that never names the package, and the DOUBLING is reproduced |
| `v8_inst_uninst` | the same shape instantiated and not | 9/0 | **3/0** | TOWARD; both def views EXACT, the 3 are R4 (elab) |
| `v9_dyncontainers` | assoc / dynamic / queue / fixed / unpacked-struct in the package and in the interface | 17/0 | **13/0** | TOWARD; the 13 are R1 and R5, both measured on BOTH roads and unchanged |
| `v10_paramiface` | a parameterized interface instantiated TWICE with different parameters | 6/0 | **4/0** | TOWARD; no double-mint; the 4 are R4 |
| `v11_nested_iface` | an interface declared INSIDE a module | Surelog **rc 3, no golden** | same | **UNSCORABLE — printed loudly** (slang accepts it, Surelog refuses it, so no input can reach golden here) |
| `v12_virtual_iface` | a `virtual interface` typedef in the imported package, cycling back | 2/0 | **1/0** | TOWARD; the 1 is R4 |
| `v13_gen_iface` | generate block + modport, instantiated inside a generate loop | 6/0 | **4/0** | TOWARD; the 4 are R4 |
| `v14_pkg_chain_diamond` | a DIAMOND package graph, both ends imported | 7/0 | **0/0** | TOWARD, ORDERED-EQUAL — no de-duplication, exactly as golden |
| `v15_uses_noimport` | scope-resolved `pkg::name` with NO import, beside an importing interface that USES the name | 3/0 | **1/0** | TOWARD; the scoped-only interface mints NOTHING; the 1 is the R2 process |
| `v16_oobctor` | an out-of-body constructor's locals riding the import (§ 203) onto the INTERFACE road | 5/0 | **0/0** | TOWARD, ORDERED-EQUAL |
| `v17_dpi_export_iface` | DPI import + export, clocking block, modport, assertion, covergroup | 4/2 | **2/2** | TOWARD; the 2 EXTRA are PRE-EXISTING (an `always` we mint from the assertion), identical on both binaries |
| `v18_refactual` | one top, so the judge can walk past the design — an INSTANTIATED interface's ref | 4/0 | **2/0** | TOWARD; the binding cell is §2's |
| `v19_uninst_refactual` | the finding's own five-line repro | 1/0 | **0/0** | TOWARD, ORDERED-EQUAL |
| `v20_refsites` | every reference site (assign / always / function / task) × inst and uninst | — | — | the binding table in §2 |

**EXTRA never rises in any arm on either binary. REMOVED = 0 in every arm
(path-normalised whole-dump: the law only ADDS).** Per-owner, the only owners
whose cell list changed are `work@<iface> (work@<iface>)` — interface
DEFINITION views. No module, no package, no `program`, no elaborated instance
owner moved in any arm.

---

## 4. GATES — RE-RUN HERE, ON THE FIXED BINARY

Every sweep used this verifier's own `--out`/`--workdir`, `SLANG_UHDM`
exported per binary, and **every `cmds.txt` audited by binary PATH**: surelog
1523 slang lines / 1573 files and uhdm2rtlil 1458 / 1462, **100 % on the
intended frozen binary, zero on the main-tree one**.

| gate | pristine | patched | **fixed** |
|---|---|---|---|
| `tests/check_goldens.sh` | — | 23 PASS / 0 FAIL | **23 / 0** |
| negative control (`SLANG_UHDM=/bin/false`) | — | 0 PASS / 23 FAIL | **0 / 23** |
| uhdm2rtlil testflags / default | 679/50/2 both | 679/50/2 both | **679/50/2 both** |
| `ct8rows` u2r vs committed baseline | — | PASS (0 rows) | **PASS (0 rows)** |
| `ct8rows` u2r vs own pristine, both modes | — | PASS / PASS | **PASS / PASS** |
| `SELFCHECK=1 byteverify` u2r | — | **0 / 1358** | **0 / 1358** |
| surelog default / testflags | 476 CMP_EQUAL + 5 NE / 470 + 5 | same | **same** |
| `ct8rows` surelog vs own pristine | — | PASS (0 rows) | see below |
| `SELFCHECK=1 byteverify` surelog | — | **3 / 956** | see below |
| ten protected CMP_EQUAL row-modes | all rc 0 | all rc 0 | all rc 0 |
| pins | — | `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort`/`BlackParrotComplex`/`YosysOldOr` byte-identical | same |

**THE THREE SURELOG MOVERS, ATTRIBUTED.** `MiniAmiq/default` and
`MiniAmiq/testflags` are the law (predicted; +1070/−0 lines, census above).
The third is `Scoreboard/default`, and it is **THE COIN**: the two dumps have
the SAME line count (1 100 422) and their path-normalised **order-blind diff
is 0 lines** — RESUME §9's ~50/50 `vpiTaskFunc` order flip, not a mover.

**`InterfaceModPort` IS AN INSTANTIATED-INTERFACE TEST AND IT DID NOT MOVE** —
byte-identical in both modes on all three binaries. The fence is *measured*,
not assumed: its two interfaces (`mem_interface`, `mem_if`,
`tests/InterfaceModPort/top.v`) contain no `import` at all, so the hoist is
empty there.

**ONE BASELINE-ROW DELTA, NOT CAUSED BY EITHER PATCH — do NOT touch
`results/*.csv`.** `ct8rows` of any of this verifier's surelog sweeps against
the committed `results/golden_surelog.csv` reports exactly one differing row:

```
< Earlgrey_0_1,testflags,CMP_EQUAL,,,differ
> Earlgrey_0_1,testflags,CMP_EQUAL,,,
```

The STATUS is `CMP_EQUAL` on both; only the dump column blanked. It reproduces
on the **PRISTINE** binary alone, re-run by itself with `--jobs 1` on an
otherwise idle machine, so it is not the patch and not load: `verify_golden.py`
records `''` when `uhdm-dump` exceeds its 180 s timeout, and `uhdm-dump` on
that 95 MB database takes **250 s wall** here. `ct8rows` pristine-vs-patched
and pristine-vs-fixed are **0 differing rows**, which is the gate that speaks
about the patch. The same artifact is the single `changed=1` in
`canaries.sh` (`Earlgrey_0_1 testflags CMP_EQUAL/differ -> CMP_EQUAL/`).

Canaries and audits: `canaries.sh` u2r **ok=8 changed=0**, surelog **ok=51
changed=1** (the row above, environmental); `EXPECT_UNKNOWN=1/6 ctcan2.sh`
**PASS ×2**; `canaudit.sh canaries.sh ctcan2.sh` in the pass's own repro dir
**audited=29 UNCOVERED=0 FENCE-BREACH=0**, and the four slang-fenced names
appear nowhere in this verifier's directory either.

---

## 5. THE WIDE BOUNDARY

`bound223.sh` over a COPY of the whole probe tree, subdirectories included,
both views, every rc recorded.

* pristine vs patched: `LISTED = PROCESSED = 5573`, `RC_DIFFS = 0`,
  `MOVED_ARMS = 66` (33 files × 2 views) — 13 files this verifier's own arms,
  10 the pass's own, **10 foreign**.
* pristine vs fixed: `LISTED = PROCESSED = 5593`, `RC_DIFFS = 0`,
  `MOVED_ARMS = 70` (35 files × 2 views: the same set plus this verifier's two
  later arms).

**EVERY FOREIGN MOVED ARM RE-SCORED AGAINST GOLDEN** (re-compiled with the
canonical golden-side Surelog; the verdict column is NEWLY-MISSING — a golden
cell the PRISTINE run matched and the new run does not):

| arm | pristine miss/extra | new miss/extra | cured | **NEWLY-MISSING** |
|---|---|---|---|---|
| `r10uvm217repro/grid217/g217_d_importer.sv` | 6/0 | 3/0 | 3 | **0** |
| `r10uvm88repro/v88_b3_scopes.sv` | 6/0 | **0/0** | 6 | **0** |
| `r10v209repro/arms/v209_p_ifprog.sv` | 10/0 | 5/0 | 5 | **0** |
| `r10v214repro/arms214/va5_modctx.sv` | 3/1 | 2/1 | 1 | **0** |
| `r10vbuvm19repro/vg19k.sv` | 9/0 | 6/0 | 3 | **0** |
| `r10vbuvm33repro/v33c.sv` | 5/4 | 4/4 | 1 | **0** |
| `r10vearl100repro/v3_gen100.sv` | 7/5 | 6/5 | 1 | **0** |
| `r10buvm34repro/g34a3.sv` | 3/10 | 2/10 | 1 | **0** (Surelog rc 4 — golden partial, printed loudly) |
| `r10v144repro/v144_b_ctor.sv` | 3/0 | **0/0** | 3 | **0** (Surelog rc 4) |
| `r10vbuvm27repro/v27_a_homes.sv` | 10/0 | 8/0 | 2 | **0** (Surelog rc 4) |

**10 / 10 TOWARD GOLDEN. NEWLY-MISSING 0 everywhere. EXTRA unchanged in every
arm.** Every one of the ten is an interface that wildcard-imports a package —
the law's own shape — and the cells that moved are, verbatim, imported-package
nets in an interface DEFINITION view (`work@if3.c3`, `work@if3.n3`;
`work@ip209.pp_own` …). Nothing else moved anywhere in 5593 files.

**MUST-STAY FLOOR.** Zero moved arms in `r10uvm216repro`, `r10uvm218repro`,
`r10uvm220repro`, `r10uvm221repro`, `r10uvm222repro` or their verifier
directories — so § `ifaceOwnCallCalleeFormRoutes222`,
§ `uninstIfaceEnumConstNoActual221`, § `uninstIfaceForeachHdrUnresolved220`,
§ `uninstIfaceBodyBindsInMethodWindow218` and § `dpiExportListedAtExportItem216`
are re-run BYTE-IDENTICAL in both views, which is stronger than re-scoring
them. Zero in `buvm3-15` and `sd8-12`.

**ONE CORRECTION TO THE PASS README (§8).** Its sentence "zero moved arms in
… the uvm82-91 / buvm3-15 / sd8-12 families" is **wrong for uvm88**:
`r10uvm88repro/v88_b3_scopes.sv` DOES move, in both views — the pass's own
foreign-arm table lists it two paragraphs earlier. The arm is fine (6/0 → 0/0,
NEWLY-MISSING 0, only the law's cells), but the floor sentence must be
corrected before landing; the rule is "only cells your law names may move",
not "nothing moves".

---

## 6. RESIDUES (this verifier's ranking)

* **R0 — our `sva_info`/`cover_info`/`property_info` nets carry a typespec
  golden's do not.** 17 cmp lines, ONE head, both MiniAmiq row-modes, the two
  logs byte-identical. PRE-EXISTING and independently confirmed here: the
  pristine database carries the identical five `sva_info` `ref_typespec` lines.
  All three are the interface's DYNAMIC arrays, which ties it to R1 —
  Surelog types an unpacked-dimension signal's element through the ARRAY_NET,
  not the net.
* **R1 — `Array_nets()` 5 vs 0**, `Nets()`'s immediate successor in
  `instance::Compare`. Confirmed in Surelog source: `writeNets`
  (`UhdmWriter.cpp:894-940`) mints an `array_net` plus a loc-less inner element
  net when `instance == nullptr && parent->UhdmType() == uhdminterface_inst`,
  for ANY signal with an unpacked dimension. `arms/v9_dyncontainers` measures
  it on both roads: golden's interface lists array_nets for the assoc,
  dynamic, queue, fixed and unpacked-struct signals — the interface's OWN
  (`ifa9`, `ifd9`) as well as the imported ones — and golden's module lists
  none. **Wider than the imported-net story; needs its own grid and its own
  a-priori census.**
* **R2 — an interface definition view's process.** golden 1, ours 0 for an
  uninstantiated interface (`arms/v15_uses_noimport`: golden gives
  `work@if_v15_uses` its `always_comb`, we give it none). Untouched by both
  binaries.
* **R3 — the instantiated interface's def-view references bind the ELABORATED
  variable.** `arms/v20_refsites`/`v18_refactual`: golden's `work@if_v20i`
  refs carry `vpiActual → logic_var work@top_v20.u_if.<name>`; ours carry none
  (pristine and fixed) — and this is the same producer as R4. The
  `ifaceFnRefFixups` machinery already in `emitInterfaceDef` is the obvious
  hook, and the cell is judge-read (`ref_obj::Actual_group`).
* **R4 — an instantiated interface's ELABORATED view omits the imported
  variables** (`v8`, `v10`, `v12`, `v13`, `v17`: golden lists `iv8`, `is8`,
  `lv8` … as `vpiVariables` beside the interface's own). The module road's
  elab half already does it. Definition-view-only was the right scope for this
  pass; the elab half is where every instantiated-interface canary lives.
* **R5 — an interface definition view over-binds its OWN nets.** golden leaves
  an UNINSTANTIATED interface's def-view references entirely bare (arm `v19`:
  golden 2 bound / 2 bare, all four bare ones inside the interface; ours 3/1),
  and we bind the interface's own net. PRE-EXISTING on both binaries, the same
  `lateBinding` distinguisher as §2 — §2 fixed the half the patch introduced;
  this is the half that was always there.
* **R6 — `modelled()` drops fixed-size unpacked arrays and unpacked structs on
  BOTH roads** (`v9`: golden's `work@m_v9` lists `fx9`/`us9` as a net AND an
  `array_var`, we list neither, identically on both binaries).
* **R7 — an explicit import's copy sorts after the wildcard's** (the pass's
  R3; multiset exact, slot order not). Not re-measured adversarially here
  beyond confirming `v2_expl_nonvar` is ordered-equal in the single-import
  shapes.
* **R8 — escaped-identifier span** on an interface's own net
  (`v5_escaped`: golden `9:9-9:21`, ours `9:9-10:3`). Pre-existing, dump
  fidelity only.

---

## 7. FILES

| file | what |
|---|---|
| `arms/v1…v20/dut.sv` | the twenty adversarial arms, one directory each |
| `v223grid.sh` | the grid driver (the pass's, re-pointed at `arms/`); every arm's rc on both sides, a non-zero one printed loudly |
| `cells223.py`, `gscore223.py` | the cell scorer and the ordered/multiset arm scorer (copied unchanged from the pass) |
| `refactual223.py` | the reference-binding counter: `ref_obj` nodes with and without a `vpiActual`, by indentation |
| `VERIFIED.r10uvm223.txt` | every gate number on all three binaries, the cmds.txt audits, the movers and their attribution |
| `GRID.r10v223.txt`, `BOUNDARY.r10v223.txt`, `FOREIGN.r10v223.txt` | the grid scores, the two wide boundaries, the foreign-arm re-scoring |
