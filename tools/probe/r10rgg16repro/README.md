# r10rgg16 — § ifacePortViewActualScopeGate16: an interface PORT VIEW whose connection ACTUAL is not declared in the INSTANTIATING SCOPE carries NO `param_assign`s

**MEASUREMENT-ONLY directory.**  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `5723484`.**  `results/*.csv` was READ ONLY and is untouched.
**Rggen still does NOT pass `uhdm-cmp`, and NO CORPUS ROW WAS CONVERTED** —
this pass says so up front.  The production change is ONE gate in
`src/ModuleEmit.cpp` (111 inserted lines, of which 42 are the law's comment);
everything else here is instrument or evidence.

Target: `default:Rggen`'s official head after r10rgg15 — 683 cmp lines
(342 on stderr + 341 on stdout), 1 head, at `5723484`:

```
LHS: <null>
RHS: interface_inst: work@rggen_bus_if
       (work@rggen.u_block_0.g_register_15.u_register.bus_if), id:152571,
       file:.../rggen-sample/block_0.sv, line:2289:0
     |vpiParent: module_inst work@rggen_external_register
                 (work@rggen.u_block_0.g_register_15.u_register)
```

**RESULT.  THE HEAD IS CLEARED, and it was a family of ONE in Rggen.**

* `uhdm-cmp` (official, Rggen default): the head object moves to a **DIFFERENT
  FAMILY** (§ 8, R0) — 683 → 97+96 cmp lines.  A cmp line count is the head
  OBJECT's decompile size, so that number is **not** a progress metric and is
  not reported as one.  The arbiters are the whole-dump diff and the census.
* **r10rgg15's decode of this head was WRONG and is corrected here (§ 1).**  It
  read `LHS: <null>` as the SINGULAR `SafeCompare` mirror and concluded "a
  SPURIOUS OBJECT golden does not emit".  It is the **VECTOR** overload's
  `lhs == nullptr && rhs != nullptr && !rhs->empty()` arm, which names the
  **CONTAINER**: golden emits that `interface_inst` too — with the SAME name,
  defname, 4 parameters, 1 modport and 8 variables — and differs only in
  leaving its `vpiParamAssign` vector NULL where we filled it with four.
* **The whole-dump path-normalised diff of Rggen, base vs patched, is 86
  removed / 0 added lines over 1,580,844 dump lines a side — the four
  `param_assign` subtrees of that one `interface_inst`, and NOTHING ELSE**
  (`DUMPDIFF_rggen_base_vs_pat.txt`).
* Census of every `interface_inst` in the whole Rggen database, both views
  (806 golden keys / 806 ours): golden-vs-ours **differing 1 → 0**.
  Golden-vs-golden calibration: **806 / 806 identical against a FRESH
  `surelog -parse` run** whose database is byte-identical to the cached golden.
* Corpus: **0 byte movers over 1,358 uhdm2rtlil databases** and **1 byte mover
  over 956 surelog databases — `default/Rggen`, the target, and nothing else**.
  **Both numbers were PREDICTED BY NAME from the PRISTINE databases BEFORE the
  patched sweep existed** (`PREDICT_db_*.txt`).
* **0 differing ROWS** in either corpus, either mode, status AND dump column,
  against the committed baselines AND against my own base sweeps.
* Wide boundary over a COPY of the WHOLE `tools/probe` tree, no path filter:
  **3,095 sources, 2,962 identical, 6 movers — five of them this pass's OWN
  grid cells (the positive control), the sixth `r10earl61repro/v2_v61.sv`,
  which this pass's law NAMES and which is verified to move TO GOLDEN** —
  0 asymmetries (`BOUNDARY.txt`).

---

## 1. THE HEAD, decoded from the PRISTINE cmp LOG and `BaseClass.h`

`HEAD_R0_BEFORE_default_Rggen.cmp` is the verbatim pristine log (LHS is ALWAYS
golden).  Read the two `SafeCompare` overloads, not the framing carried
forward:

```c++
// SINGULAR                                  // VECTOR
} else if ((lhs == nullptr) &&               } else if ((lhs == nullptr) &&
           (rhs != nullptr)) {                          (rhs != nullptr) && !rhs->empty()) {
  context->m_failedRhs = rhs;                  context->m_failedRhs = rhs_obj;   // the CONTAINER
```

Both print `LHS: <null>` with a full RHS.  The discriminator is whether the
printed RHS is a VALUE at a slot or the OWNER of a vector — and the dump
settles it: **golden's `work@rggen.u_block_0.g_register_15.u_register` lists
TWO `vpiInterface` children, `register_if` and `bus_if`, exactly as we do.**

```
GOLD u_register vpiInterface        OURS u_register vpiInterface
  interface_inst work@rggen_register_if (...u_register.register_if)   [both]
  interface_inst work@rggen_bus_if      (...u_register.bus_if)        [both]
```

The object is NOT spurious.  Its FIELD LIST is where the sides part:

```
golden  ...u_register.bus_if : par=4  pa=0  mp=1  var=8
ours    ...u_register.bus_if : par=4  pa=4  mp=1  var=8
```

`interface_inst::Compare` reaches `Param_assigns` through the vector overload;
golden's vector is NULL, ours holds four, so `m_failedLhs` is never set and
`m_failedRhs` is the `interface_inst` itself.  **THE FAILING FIELD IS
`Param_assigns`, AND NOTHING ELSE.**

The four are `ADDRESS_WIDTH`, `BUS_WIDTH`, `RGGEN_ACCESS_DATA_BIT` and
`RGGEN_ACCESS_NON_POSTED_BIT` — precisely the four `extra-ours` keys r10rgg15's
`param_assign` census reported and mis-attributed to a spurious object.

---

## 2. THE SITE, and the mechanism read off SURELOG

```
rggen.sv:112       rggen_bus_if #(8, 32) register_15_bus_if();     <- a real INSTANCE
rggen.sv:269       block_0 u_block_0 ( ... .register_15_bus_if(register_15_bus_if) )
block_0.sv:145     rggen_bus_if.master register_15_bus_if          <- block_0's own PORT
block_0.sv:2288    generate if (1) begin : g_register_15
block_0.sv:2299        rggen_external_register u_register ( ... .bus_if(register_15_bus_if) )
rggen_external_register.sv:13   rggen_bus_if.master bus_if         <- the FORMAL
```

Surelog does not COMPUTE a port copy's parameter values; it CLONES them off the
interface instance the port connects to:

* `NetlistElaboration::elab_ports_nets_` (NetlistElaboration.cpp:2743) sees the
  modport signal, calls `getInterfaceInstance_(instance, sigName)` and then
  `propagateIfaceParams_` (line 681), which copies `refInst`'s
  `netlist->param_assigns()` into the copy's netlist — **only if the lookup
  hit**;
* `getInterfaceInstance_` (line 699) resolves the actual by NAME among
  **`instance->getParent()->getAllSubInstances()`** — the sub-instances of the
  copy's IMMEDIATE parent ModuleInstance, and nothing above it;
* `UhdmWriter::writeElabParameters` (UhdmWriter.cpp:442) then writes
  `m->Param_assigns(netlist->param_assigns())` **inside
  `if (netlist->param_assigns())`**, while the `Parameters` clones of the
  definition are written unconditionally.  A miss therefore yields exactly what
  golden shows: `par=4`, `pa` UNSET.

**A GENERATE BLOCK IS A ModuleInstance OF ITS OWN.**  `u_register`'s parent is
`g_register_15`, whose sub-instances are `{u_register}`.  `register_15_bus_if`
is a sub-instance of `block_0`, one level up, so the lookup MISSES and golden
propagates nothing.  Move the very same instantiation out of the generate block
and the lookup hits.

---

## 3. THE GRID — the law measured on GOLDEN, five cells, twelve rows

`cells/g1..g5`, run with `cell16.sh`; the payload is `pvcensus16`'s
`PV=/par=/pa=/mp=/var=/PK=/GK=` tuple (`GOLDEN_SHAPES_grid.txt`).

| cell | actual's home | instantiating scope | golden `pa` |
|---|---|---|---|
| g1 c1 | named iface instance, same scope | module body | **KEPT** |
| g1 c2 | named iface instance, module body | gen-if | **NONE** |
| g1 c3 | named iface instance, same gen block | gen-if | **KEPT** |
| g1 c4 | named iface instance, module body | gen-for | **NONE** |
| g2 | as g1, with the def MULTI-parameterized (two tuples) | — | identical to g1 |
| g3 c1 | enclosing module's own iface PORT (passthrough) | module body | **KEPT** |
| g3 c2 | enclosing module's own iface PORT (passthrough) | gen-if | **NONE** ← Rggen |
| g4 c1 | modport expression `inst.mp` | module body | **KEPT** |
| g4 c2 | modport expression `inst.mp` | gen-if | **NONE** |
| g4 c3 | interface-ARRAY element `arr[0]` | module body | **NONE** |
| g4 c5 | PLAIN (non-modport) interface port | module body | **NONE** |
| g5 c1 | named iface instance, same gen block | gen-if | **KEPT** |
| g5 c2 | named iface instance, OUTER gen block | inner gen-if | **NONE** |
| g5 c3 | named iface instance, module body | inner gen-if (2 up) | **NONE** |

Two rows are the mechanism showing through in shapes the brief did not name:

* **`arr[0]` at MODULE scope is a MISS too** (g4 c3).  An interface array's
  sub-instances are named `arr[0]`, `arr[1]`, …; `getInterfaceInstance_`
  matches the actual's BASE identifier `arr`, which equals no sub-instance
  name.  So the discriminator is *not* "gen scope" — gen scope is the way the
  miss usually manifests.  (Our array-element views already drop their
  param_assigns through `§ ifaceArrayElemPortViewNoPa`; the gate agrees.)
* **A PLAIN interface port NEVER propagates** (g4 c5, module scope, `pa=0`):
  the `sig->getInterfaceDef()` arm at NetlistElaboration.cpp:2833 calls
  `elab_interface_` and never calls `getInterfaceInstance_` at all.  That is a
  SECOND, independent law; this pass does NOT take it — see R-A in § 8.

`GRID_SCORES.txt`, base vs patched vs golden, order-blind on the whole tuple:
**FIXED 10, BROKEN 0, STILL-WRONG 1, STILL-RIGHT 31.**  The single STILL-WRONG
is g4 c5, the plain-port law above, deliberately left.

---

## 4. THE PRODUCTION CHANGE

`src/ModuleEmit.cpp`, `UhdmExporter::emitInterfaceInstance` — one new first arm
on the port-view `Param_assigns` chain, and the predicate that feeds it:

```
    if (portView && actualOutOfScope16) {
        iface->Param_assigns(nullptr);
    }
    else if (portView && !inst.arrayPath.empty()) {          // unchanged from here down
```

`actualOutOfScope16` finds the `InterfacePortSymbol` of `portView` whose
connection resolves to `inst`, reads the actual's BASE identifier off the parse
tree exactly as Surelog does (`.p` shorthand → the FORMAL name; `a.mp` → `a`;
`arr[i]` → matches nothing), walks past any instance-ARRAY scope, and asks
`Scope::find` on the INSTANTIATING scope for a direct member of kind `Instance`
or `InterfacePort`.  A hit changes nothing; only a MISS drops the vector.

Deliberately declined, so that no unmeasured cell can move:

* **POSITIONAL connections** — Surelog compares the ACTUAL's name against the
  FORMAL's for those, a different rule no cell of this pass exercises.
* **An actual whose syntax is neither an identifier, a scoped name, nor an
  indexed name** — the predicate stays false.
* **A scope that is not an instance body or a generate block** (the design
  root) — not a Surelog `ModuleInstance`.

---

## 5. THE CENSUS INSTRUMENT

`pvcensus16.cpp` (build with `build16.sh`) reads a `.uhdm` DIRECTLY with the
same STATIC `~/.local` UHDM that the sweeps, `uhdm-cmp` and `uhdm-dump` use, and
emits one row per `interface_inst` in both views — `DEF` (`uhdmallModules` +
`uhdmallInterfaces`) and `ELAB` (`uhdmtopModules`, gen scopes, interface arrays
and nested interfaces walked) — keyed `(view, full path)` with the payload
`PV / par / pa / mp / var / PK / GK`.

`PV` (is this a PORT VIEW?) reads `vpiInstance == null`, which is true of
Surelog's port copies AND of ours, so the flag is comparable ACROSS SIDES; `PK`
and `GK` are the parent and grandparent KINDS, which is how "inside a gen
scope" is scored without trusting a path string.  `UhdmName()`'s `string_view`
is materialised before every `printf` (the trap that turned r10rgg11/12/13's
census files binary and made `grep` print nothing).

**CALIBRATION FIRST, as the campaign requires.**  A FRESH `surelog -parse` run
of the Rggen command line into my own `-odir` produced a database
**byte-identical** to the cached golden (md5 `98176c6e44638c913a47fd319fa3729f`
both), and the census of the two is **806 / 806 identical, 0 differing keys**.
NEGATIVE CONTROL: the same census, golden vs PRISTINE ours, reports the one
differing key that is this pass's head — and on the grid it reports 11 —
so the instrument is not blind.

---

## 6. THE GATES (all mandatory legs; `gates16.sh`)

| leg | result |
|---|---|
| build both, md5 after `Built target` | base `2d41c4ca7ca6140f25d751004fca13cd`, patched `1a26bbc9c08bd1fa45695b2a3a013305` |
| goldens, `SLANG_UHDM` exported to the PATCHED binary | PASS 23 / FAIL 0 |
| goldens negative control, `SLANG_UHDM=/bin/false` | PASS 0 / FAIL 23 |
| uhdm2rtlil testflags status histogram | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL |
| uhdm2rtlil testflags rows vs `results/gate_uhdm2rtlil.csv` | 0 differing / 731 |
| uhdm2rtlil testflags rows vs my OWN base sweep | 0 differing / 731 |
| uhdm2rtlil default rows vs my OWN base sweep | 0 differing / 731 |
| uhdm2rtlil byteverify, SELFCHECK=1 | MOVERS 0 / 1358, selfcheck 1357/1358 |

| surelog both-modes status histogram | 936 CMP_EQUAL / 20 CMP_NOTEQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 NO_UHDM / 1 TIMEOUT |
| surelog rows vs `results/golden_surelog.csv` | **0 differing / 1588** |
| surelog rows vs my OWN base sweep | **0 differing / 1588** |
| surelog byteverify, SELFCHECK=1 | **MOVERS 1 / 956 — `default/Rggen`, PREDICTED BY NAME**, selfcheck 955/956 |
| canary rows, surelog | ok=52 changed=0 absent=0 |
| canary rows, uhdm2rtlil | ok=8 changed=0 absent=0 |
| `ctcan2.sh` supplementary canaries, both corpora | PASS / PASS |
| `canaudit.sh canaries.sh ctcan2.sh` | PASS, audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected databases by md5 | InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME**; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |

**NO CORPUS ROW WAS CONVERTED and `results/*.csv` was NOT edited.**  The one
byte mover is `default/Rggen`, which stays `CMP_NOTEQUAL` on a different head.

### 6b. The WHOLE-CORPUS interface_inst census (`corpuscensus16.py`)

Golden vs ours, every database that has a golden AND at least one
`interface_inst`, on the full `PV/par/pa/mp/var/PK/GK` payload:

| corpus | databases | with an `interface_inst` | DIFFERING, base | DIFFERING, patched |
|---|---|---|---|---|
| uhdm2rtlil | 1358 | 130 | **0** | **0** |
| surelog | 956 | 61 | **3** | **2** |

The three base rows are `default/Rggen` (this pass's head) and
`default+testflags/SeqDriver`.  After the patch **Rggen is gone and NOT ONE
`pa` MISMATCH REMAINS ANYWHERE IN EITHER CORPUS**; the two SeqDriver rows are a
MODPORT-COUNT residue in a different family (`work@adpcm_if`: golden `mp=0`,
ours `mp=1`, on both the DEF shell and `work@top_tb.ADPCM`) — see R-N2 in § 8.

The surelog legs, the surelog byteverify, the canary battery and the boundary
are in § 7.  Every leg exported `SLANG_UHDM` EXPLICITLY to the named binary and
every `cmds.txt` was audited by binary PATH (both `verify_golden.py` and
`tests/check_goldens.sh` silently fall back to the MAIN-TREE build otherwise —
RESUME §9).

---

## 7. THE INSTRUMENTS

```
build16.sh      build pvcensus16 against the STATIC ~/.local UHDM
pvcensus16.cpp  the interface_inst census, DEF + ELAB (§ 5)
predict16.py    the PRISTINE-database mover predictor, two-tier (§ 6)
score16.py      order-blind 3-way grid scorer on the whole payload tuple
cell16.sh       one grid cell: surelog -parse + slang --single-unit + uhdm-cmp
gates16.sh      the four mandatory sweep legs, SLANG_UHDM exported per leg
ct16rows.sh     differing-row counter, status AND dump columns
boundary16.sh   the wide boundary (subdirectories included, asymmetries loud,
                the four slang-fenced test names never dispatched)
canaries.sh / ctcan2.sh / canaudit.sh   the canary battery and its audit
cells/g1..g5    the golden grid (§ 3); they double as the boundary's positive
                control
```

Reproduce:

```
bash build16.sh
for c in g1 g2 g3 g4 g5; do bash cell16.sh "$PWD/cells/$c" <base-bin>;     done
for c in g1 g2 g3 g4 g5; do bash cell16.sh "$PWD/cells/$c" <pat-bin> .pat; done
python3 score16.py cells/g1 cells/g2 cells/g3 cells/g4 cells/g5
python3 predict16.py <base-workdir> PREDICT.txt
```

---

## 8. RESIDUES AND THE NEXT HEAD

**R0 — THE NEW HEAD of `default:Rggen` (194 cmp lines: 97 stderr + 96 stdout,
1 head).  It is r10rgg15's R-C, promoted by this pass.**

```
LHS: hier_path: (register_if[12].value[0+:1]), id:259425, line:356:42, endln:356:78
     |vpiParent: port (i_sw_write_enable)
     |vpiActual: bit_select (register_if[12])   <- vpiName register_if,
     |                                             vpiIndex constant INT:12
     |vpiActual: indexed_part_select (register_if[12].value[0+:1])
```

`block_1.sv:356`'s
`.i_sw_write_enable (register_if[6+7*i+6].value[0+1*l+:1])`: golden's port
actual is a `hier_path` whose FIRST element is a `bit_select` carrying a FOLDED
`vpiIndex` constant, where we emit a plain `ref_obj` and a second element — 48
objects on our side against golden's 24 over the 24 rows.  The fix is
STRUCTURAL, not a constant re-encoding.  **`Path_elems` is a VECTOR field, so
its size mismatch will name the `hier_path` CONTAINER, exactly like this pass's
head did — decode it from `hier_path::Compare` before naming a field.**

**RE-RANKING of the rest** (the brief asked for it explicitly):

* **R-A — 810 census rows, still the biggest Rggen family and now the biggest
  ENCODING piece.**  Golden's ELAB view keeps `op11[ref(WIDTH), UINT:1]` in
  gen-scope INTERFACE VARIABLE range bounds where we fold to `const INT:<n>`.
  **Unchanged, and it still outranks R-B/R-E on row count**, but it is now
  ranked BELOW R0 because R0 is the actual head.
* **R-B — the 7 signed `START_ADDRESS` rows** (golden `UINT:84/80/76/...` at
  `sz=7`, ours `UINT:-44/-48/...`).  A pure `toString` signedness fix with a
  census that scores it exactly.  Unchanged.
* **R-C is now R0** (above).
* **R-D — `decompileHelper` SPACING in a kept-symbolic hier_path name.**
  Unchanged.
* **R-E — a gen-scope LOCALPARAM index in a cont_assign IS folded by golden**,
  plus r10rgg15's g4 finding (a gen-scope `localparam bit [W-1:0] L_gen = '0`
  reads golden `BIN:0 sz w dec "<w>'b0"` where we emit `UINT:0 dec "0"`).
  Unchanged.
* **R-F / R-G** (r10rgg15's `'1`-into-a->64-bit-formal and the BASED-unsized
  override actual).  Unchanged, both still zero corpus reach.

**TWO NEW residues, both MEASURED here and both deliberately declined:**

* **R-N1 — a PLAIN (non-modport) interface port view NEVER carries
  `param_assign`s, whatever the def's parameterization.**  Surelog's
  `sig->getInterfaceDef()` arm (NetlistElaboration.cpp:2833) calls
  `elab_interface_` and never calls `getInterfaceInstance_` at all, so nothing
  is ever propagated.  Our emitter already encodes this, but only under
  `!multiParamIface`: a def instantiated with SEVERAL distinct parameter tuples
  skips the arm and keeps the vector.  **Measured on `cells/g4` c5
  (`work@top.u5.p`, module scope: golden `pa=0`, ours `pa=2`) — the single
  STILL-WRONG cell of this pass's grid.**  Zero reach in either corpus (the
  whole-corpus census above is clean), which is exactly why it was left: taking
  it would have moved no corpus cell and widened the blast radius of a pass
  whose head is elsewhere.  `cells/g4` is the arm it should be developed on.
* **R-N2 — SeqDriver's `work@adpcm_if` carries a MODPORT we invent.**  Golden
  `mp=0` on both the DEF shell `work@adpcm_if` and the elaborated
  `work@top_tb.ADPCM`; we list one.  Two databases (`default` +
  `testflags/SeqDriver`), 4 keys, and it is the ONLY interface_inst payload
  mismatch left in either corpus.  SeqDriver's own head is elsewhere
  (99,202 cmp lines), so this is not its blocker — but it is a small, sharply
  bounded, fully-instrumented family (`corpuscensus16.py` scores it in one
  run).

---

## 9. WHAT THIS PASS CORRECTS IN THE RECORD

r10rgg15's README § 9 declared this head **"a SPURIOUS OBJECT, and the census
already named it: the FOUR `extra-ours` keys … the fix is to not emit the
instance (or to not list it), and the census key set is the acceptance test:
extra-ours must go 4 → 0."**

That framing was wrong in a way that would have cost a pass: **golden emits the
`interface_inst`, and deleting it would have broken 806 census keys to fix
one.**  The four `extra-ours` keys were not an extra OBJECT but the four
`param_assign`s hanging off an object BOTH sides emit — a `param_assign` census
keyed by owning-scope path cannot tell those apart, which is precisely the
"slot-keyed censuses are BLIND below the slot" trap RESUME §9 warns about.  The
decode that settled it was two greps of the two dumps for the owner's
`vpiInterface` list, and it should have been the FIRST step, not the fifth.
