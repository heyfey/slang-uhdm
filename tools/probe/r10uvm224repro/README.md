# r10uvm224 — § ifaceDefNetTypespecIsTheModuleRule224

**An interface definition's net is typed by the module definition's rule.**

Base commit `e492c4e0`.  Head target: MiniAmiq ×2, the last workable
`CMP_NOTEQUAL` row-mode pair, 17 cmp lines and one head in both modes.

---

## 1. THE QUESTION THE PASS WAS SET, ANSWERED FIRST

> Measure whether the head and the `Array_nets` vector are ONE law or two, and
> predict the successor either way.

**TWO LAWS.**  All four combinations of (typespec right/wrong) × (array_net
present/absent) occur on golden in one five-line arm, so neither implies the
other in either direction:

| declaration (empty-parens interface) | golden's net typespec | golden's `Array_nets` |
|---|---|---|
| `Cb224 w_cls224;`        (no dimension) | **NONE** | none |
| `Cb224 w_clsdyn224 [];`  (dynamic)      | **NONE** | **one** |
| `tc224_t e_tipk224 [1:0];` (fixed)      | **NONE** | **one** — and the PRISTINE build already got this array_net right while getting the typespec wrong |
| `int e_intdyn224 [];`    (dynamic)      | `int_typespec` | **one** |

`w_cls224` has no unpacked dimension at all and still loses its typespec; the
head fires with no array involvement whatever.  `e_intdyn224` is a dynamic
array whose typespec golden KEEPS; the vectoring law fires with the typespec
already correct.

**This pass lands the TYPESPEC law.  The vectoring law is R0 for the
successor** — and it is now the head, measured (see §5).

---

## 2. THE LAW

A **definition-view** net omits its typespec when the component's header is
**NON-ANSI** — a genuine non-ANSI port list, or **EMPTY PARENS** — and the
net's declared type is written as a **bare type name** with no initializer.

That is not a new rule.  It is the rule our MODULE definition writer has
modelled since r10svs10 (`namedTypeNet`).  Our INTERFACE definition writer had
no such gate and typed every net unconditionally.  This pass gives both writers
**one predicate**, `defNetOmitsTypespec224`.

Golden, measured (arm `a3_headerform`, and the module column agrees on every
cell of `a2_kindgrid` / `a4_predicates`):

```
interface/module x();   empty parens      bare name -> NO typespec
                (pa);   non-ANSI list     bare name -> NO typespec
   (input logic clk);   ANSI              bare name -> typespec
                    ;   no parens at all  bare name -> typespec
```

and, in an empty-parens interface, what counts as a bare name:

```
Cb224 / CTop224          class, wildcard-imported or $unit        NONE
sp224_t / su224_t        typedef'd packed / unpacked struct       NONE
en224_t / ti224_t        typedef'd enum / typedef of `int`        NONE
loc224_t                 typedef declared IN the interface        NONE
var d_bare224;           no written type at all                   NONE
p224b::Cb224             PACKAGE-QUALIFIED class name             class_typespec
td224_t d_init224 = 0;   bare name WITH an initializer            int_typespec
int / logic [3:0] / real / string / wire                          their typespec
```

**THE FENCE.**  The imported-package data that
§ wildcardImportCopiesPkgVarsToDefNets223 hoists into a def-view net list KEEPS
its typespec on both roads, class handles and typedefs included, because the
DECLARATION lives in the package and not in the non-ANSI-header component.
Arm `a6_hoisted` is exact on the pristine and the patched binary alike, and
this pass does not touch `emitImportedPkgVarNets`.

### 2.1 The one exception — an ASSOCIATIVE dimension with a BUILT-IN index

Transplanting the module rule verbatim moved **two interface cells AWAY from
golden**.  That is how the exception was found (grid `a9_kinds`, first patched
run), and it is why the grid is scored three-way and not two-way.

```
t x [string] / [int] / [logic] / [bit] / [*]          golden KEEPS the typespec
t x [string][2] / [2][string] / [string][]            golden KEEPS the typespec
t x [t] / [<local typedef>] / [pkg::t] / [pkg::int_t] golden DROPS it
t x / x [] / x [$] / x [2] / x [1:0]                  golden DROPS it
var x [string]                                        golden DROPS it
```

Arm `a13_assoc` reorders the five dimension forms and the answer does not move,
so it is the **dimension** and not the compile order.  Any level of the
unpacked chain suffices.  The exception is confined to the bare-name clause it
was measured against: it does not reprieve `var d;`, an explicit port's net, or
a `type` parameter argument — `a14`'s `var v_varas224 [string]` is golden's own
control and golden drops it.

The **pristine MODULE road is wrong about this too** (`work@m224r`,
`work@m224s`: golden keeps, we dropped), so the shared predicate carries the
exception and the module road is corrected with the interface road.  No corpus
row exercised that cell — the a-priori predictor reports **zero** `PRED224 MOD`
cells over both corpora.

### 2.2 What was REFUTED, loudly

"One producer, therefore one rule for every holder" is **FALSE for the
PROGRAM**.  `UhdmWriter::writeNets` (UhdmWriter.cpp:812) really is called from
`writeModule` (:1458), `writeInterface` (:1680) and `writeProgram` (:1818) with
the same arguments — but arm `a7_program` compiles `program prg224_ep();`,
the very form that strips under a module and an interface, and golden **KEEPS**
the typespec on all three of its bare-named nets while we strip all three.
That is a pre-existing, three-cell, untouched gap (DIFF=3 on both binaries) and
it is R2 below.  **The interface = module claim stands on its own
measurement, not on the shared-producer argument.**

The resolution asymmetry itself — why `compileTypespec` resolves a bare
`slStringConst` under one header form and not another, and under an associative
dimension and not a queue — is recorded as MEASURED.  This pass did not trace
it to a line.  See `DECODE.r10uvm224.txt` §4.

---

## 3. THE PATCH

One production file, `src/ModuleEmit.cpp`:

* `assocBuiltinIndexDim224` — the measured associative discriminator, walking
  the unpacked dimension chain.
* `defNetOmitsTypespec224` — the def-view net typespec gate, now ONE predicate.
  The module/program writer's four clauses (`namedTypeNet`, `typeParamArgNet`,
  the explicit-port net, `hasBareImplicitType`) move into it unchanged, plus
  the associative reprieve.
* the module/program call site is rewired to it (a pure refactor except for the
  reprieve), and the interface definition writer gains it — on the net AND on
  the array_net's inner element net, because Surelog copies the base net's
  typespec onto the element and only when the base has one
  (`if (dest_net->Typespec())`, UhdmWriter.cpp:923-930).

---

## 4. THE A-PRIORI PREDICTION, AND THE u2r ZERO

A third binary (`PREDICTOR.instrumentation.txt`) reports the cells the law
would move and then takes the pristine answer, so its databases are pristine.
That is PROVEN, not asserted: byteverify predictor-vs-pristine reads
**MOVERS 0/1358** on uhdm2rtlil and **MOVERS 0/956** on surelog.

* **uhdm2rtlil: HIT-ROWS 0, CELLS 0.**  The law reaches no uhdm2rtlil row, in
  either mode.  The zero is proven before the patched sweep, and the patched
  sweep then read MOVERS 0/1358.
* **surelog: HIT-ROWS 2, CELLS 6** — MiniAmiq in both modes, three cells each,
  named: `work@svaunit_vpi_interface.{sva_info,cover_info,property_info}`.
* **Zero `PRED224 MOD` cells anywhere.**

The prediction and the measured mover set are the same set.

**A first predictor was WRONG and said so loudly.**  Its reconstruction of the
pristine module gate was `omit || assocBuiltinIndexDim224(sym)`, which also
strips a BUILT-IN-typed associative array (`int assoc [string]`) that pristine
keeps — `namedTypeNet` is false there.  It moved `DynArrayKind` in both modes
(`module top;`, no parens: a row the law cannot reach) and byteverify convicted
it at MOVERS 3/956.  A predictor that is not byte-pristine predicts nothing, so
it was rebuilt to compute the pristine answer from the predicate itself with
the reprieve switched off, and then read MOVERS 0/956.

---

## 5. THE HEAD MOVED, AND THE SUCCESSOR IS MEASURED

```
PRISTINE  MiniAmiq default 17 lines / 1 head   testflags 17 / 1  (logs identical)
          LHS: <null>
          RHS: ref_typespec (work@svaunit_vpi_interface.sva_info)
                 -> class_typespec (svaunit_concurrent_assertion_info) 87:4-87:37

PATCHED   MiniAmiq default 713053 / 1          testflags 713053 / 1
          LHS: interface_inst work@svaunit_vpi_interface
          RHS: <null>
```

The head OBJECT changed.  `LHS` = the owner with `RHS` unset is the VECTOR
overload's signature (RESUME §9), and golden's copy of that interface carries
**5 `vpiArrayNet` and 1 `vpiProcess`** we do not.  The line count is the new
head object's decompile size, not distance.

Every mover in the patched sweep is attributed: MiniAmiq's 33 dump lines are
the three `ref_typespec` blocks and their three now-unreferenced tail
`class_typespec` objects and nothing else, order-blind, identical in both
modes; Scoreboard/default is 92 raw lines and **0 order-blind** — the recorded
svunit_pkg `vpiTaskFunc` ORDER coin at exactly its recorded size.

---

## 6. GATES

All green; the numbers are in `GATES.r10uvm224.txt`.  In one line: goldens
23/0 and /bin/false 0/23; uhdm2rtlil 679/50/2 in both modes with ct8rows at
zero differing rows against the committed baseline AND both controls;
surelog 476/5 + 470/5 with ct8rows at **zero differing rows over 1588 against
the committed baseline outright**; byteverify 0/1358 and 3/956 with every mover
named and attributed; the nine converted row-modes (and Rggen/default) at judge
rc zero on BOTH columns; canaries 52/8 changed=0, ctcan2 both PASS, canaudit
audited=29 UNCOVERED=0 FENCE-BREACH=0; the five protected databases identical
with SVSwitch on `4842211c4030` and YosysVerx on `6ccda350c24a`.

**NO CONVERSION IS CLAIMED and `results/*.csv` were not edited.**  MiniAmiq
stays `CMP_NOTEQUAL` in both modes: the ladder did not bottom out — it moved
one rung, and the next rung is named in R0.

---

## 7. THE GRID AND THE BOUNDARY

15 arms, every rc recorded on both sides, all zero.  `grid224.sh` builds,
`gscore224.sh` scores against golden, `armdelta224.sh` scores three-way:

```
CELLS WRONG   pristine 142 -> patched 79
THREE-WAY     TO-GOLDEN 63    AWAY 0    STILL-WRONG 79
```

Every typespec DIFF cell cleared except `a7_program`'s three (pre-existing,
untouched).  All 79 remaining wrong cells are vector residues.

The wide boundary: LISTED 5594, PROCESSED 5594, RC_DIFFS 0, 19 moved sources —
11 of them this pass's own arms, 3 the campaign's known static-address false
movers (re-proved on all four cheap tells), 4 moved TOWARD golden and verified
cell by cell against a fresh Surelog, and 1 an error-recovery arm named as one.
No must-stay family moved.  Details in `GATES.r10uvm224.txt` §10.

---

## 8. FILES

* `DECODE.r10uvm224.txt` — the decoded model, the golden grid tables, and what
  was refuted.
* `GATES.r10uvm224.txt` — the whole battery with its numbers.
* `PREDICTOR.instrumentation.txt` — the third binary, verbatim, and the first
  predictor's failure.
* `PREDICT.stage.surelog.txt`, `PREDICT.stage.uhdm2rtlil.txt` — the a-priori
  prediction.
* `grid224/` (15 arms), `grid224.sh`, `gscore224.sh`, `netcen224.py`,
  `cells224.py`, `armdelta224.sh` — the golden grid and its three-way scorer.
* `bound224.sh`, `bscore224.sh`, `BOUNDARY.r10uvm224.txt`,
  `BOUNDARY.score.r10uvm224.txt` — the wide boundary and the re-score.
* `predwrap224.sh`, `predcollect224.sh` — the predictor shim and collector.
* `head_pris_MiniAmiq.*.cmp`, `head_pat_MiniAmiq.*.head400.cmp`,
  `CENSUS.MiniAmiq.mover.txt`, `CENSUS.Scoreboard.coin.txt` — the head before
  and after, and the attribution.
* `GRID.*`, `ARMDELTA.r10uvm224.txt` — the scored grid.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the gate copies run here.

---

## 9. RESIDUES

* **R0 — THE NEW MiniAmiq HEAD: THE INTERFACE DEFINITION'S `Array_nets()`,
  golden 5, ours 0**, and its `Process`, golden 1, ours 0.  Now the head, both
  modes, with the VECTOR-overload signature.  DECODED (uvm223 R1, re-measured
  here): `UhdmWriter::writeNets` (UhdmWriter.cpp:894-940) has an arm gated
  `instance == nullptr && parent->UhdmType() == uhdminterface_inst` that mints
  an `array_net` plus a LOC-LESS inner element net for **any** signal with an
  UNPACKED DIMENSION — so a MODULE definition gets none and an interface
  definition gets one per unpacked signal, imported ones included.  We mint one
  only for `FixedSizeUnpackedArrayType`, so every DYNAMIC, QUEUE and
  ASSOCIATIVE container is dropped.  MiniAmiq's five are
  `uvm_random_seed_table_lookup` twice (the imported associative array) and
  `sva_info` / `cover_info` / `property_info`.  This pass MEASURED the whole
  golden shape for the successor, in `grid224/a9_kinds`, `a13_assoc`,
  `a14_assocnest`, `a15_associndex`: the array_net carries `vpiSize:1`, one
  `vpiRange` PER unpacked level (`nranges=2` for `[string][2]`), a
  `STRING:associative` right bound for an associative dimension and a
  `STRING:$` one for a queue (both measured on golden, `a13_assoc`), and its
  inner element net copies
  the base net's typespec **and only when the base has one** — which is why
  this pass's law had to land first: the 51 ARRAYNET cells the grid still
  scores wrong now have the right typespec answer waiting for them.  **A WIDE
  law: it reaches every interface with an unpacked signal, and it needs its own
  grid and its own a-priori census.**
* **R1 — AN UNINSTANTIATED INTERFACE'S DEFINITION VIEW LISTS NO PROCESS**
  (uvm223 R2, untouched).  Golden 1, ours 0, and it is `Array_nets`'s immediate
  successor in `instance::Compare`.  MiniAmiq's is `svaunit_vpi_interface`'s
  `initial`.  A narrow, well-fenced arm.
* **R2 — THE PROGRAM ROAD KEEPS WHAT THE MODULE ROAD STRIPS.**  Arm
  `a7_program`: `program prg224_ep();` — empty parens — and golden gives
  `th224_t pe_td224`, `Ch224 pe_cls224` and `th224_t pe_dyn224` their
  typespecs, while our module/program writer strips all three.  DIFF=3 on the
  pristine and the patched binary alike.  It is the one holder that refutes
  "one rule for every holder", so it needs its own measurement of WHY —
  `writeProgram` shares `writeNets` but a Program is not a ModuleDefinition and
  `collectModuleObjects_` is not `collectInterfaceObjects_`.  Three cells, one
  arm, already committed.
* **R3 — AN INTERFACE THAT INSTANTIATES A CHILD IS EMITTED AS A `module_inst`.**
  Arm `a5_typeparam_explicit`: golden's `work@if224e` is an `interface_inst`;
  ours is a `module_inst` with the same name, nets and defname.  PRE-EXISTING
  and unmoved by this pass (the cell is STILL-WRONG on both binaries).  It also
  means the interface road's `typeParamArgNet` clause is currently unreachable
  through that shape, which is why the clause is transplanted on the strength
  of the module road's measurement rather than an interface arm of its own.
* **R4 — A NON-ANSI INTERFACE PORT'S NET SORTS LAST FOR US, FIRST FOR GOLDEN.**
  Arm `a3_headerform`, `interface if224_na(pa224); input pa224;`: golden's net
  list is `pa224, b_cls224, …` and ours is `b_cls224, …, pa224`.  The MULTISET
  is exact; only the slot order differs.  PRE-EXISTING, and the same shape as
  uvm223's R3 on the import road.
* **R5 — AN EXPLICIT PORT'S NET AND THE ELABORATED CONTAINER VARS.**  Arm
  `a11_ansiports` and every instantiated arm: golden's ELABORATED interface and
  module views list a dynamic/queue/associative container as an `array_var`
  and we list none (17 VAR cells across the grid), and an ANSI interface port's
  module-side object is a `logic_var` for golden and a `logic_net` for us.  A
  container-VARIABLE family, distinct from R0's container-NET family.
* **R6 — OUR RE-CREATED TYPESPEC'S SPAN IS THE TYPE NAME, NOT THE WHOLE
  DECLARATION** (uvm223 R6, unchanged, and visible again here: v143_l_unit's
  new `class_typespec (Lump)` reads `23:3-23:7` for us and `23:3-23:17` for
  golden).  No generated `Compare` reads a span, so it is dump fidelity only.
* **R7 — THE STATIC-ADDRESS FALSE MOVER IS STILL ALIVE AND STILL PAGE-GRANULAR**
  (uvm208 R5).  The same three arms, the same single `|UINT:` constant, delta
  4096 = one page for a binary that grew 184 bytes.  The four cheap tells were
  re-run and all four hold.  A future pass should expect it whenever the binary
  crosses a page boundary and should NOT re-derive the tells.
