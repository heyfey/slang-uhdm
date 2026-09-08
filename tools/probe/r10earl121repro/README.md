# r10earl121 — § `genCaPatKeepTagDefView121` — **THERE ARE TWO PATTERN FLATTENS AND THEY BELONG TO DIFFERENT TOOLS: SURELOG'S WRITER FLATTENS IN EVERY MODE BUT ONLY WHERE `bindVariable` FINDS THE Lhs TYPESPEC, WHILE `cont_assign::DeepClone`'S FLATTEN — THE ONLY ONE A GEN-LOCAL WHOLE-NAME TARGET HAS — LIVES IN UHDM'S `ElaboratorListener` AND RUNS UNDER `-elabuhdm` ALONE** — so in the DEFAULT view golden keeps the `tagged_pattern` wrappers there, and the Earlgrey_0_1 **default** head `LHS: tagged_pattern @tlul_socket_m1.sv:109:19` / `RHS: hier_path(tl_h_i[0].a_valid)` CLEARED (386 → 31 cmp lines, and the head OBJECT is gone), on the exact next head r10earl120's R0 named

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY**, **nothing was promoted** and **NO CORPUS ROW
CONVERTED** in either direction — `BuildUVMPkg` (both modes),
`Earlgrey_0_1/testflags` and `Rggen/default` are all quoted below still
`CMP_EQUAL` with 0 cmp lines, on BOTH binaries.  `GOLDEN_DEFER` stayed unset.
The four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own `FENCED=` list, which `widerun121.sh` reads so the boundary
filter cannot drift from the audit.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `c7a9d46c` |
| pristine binary | md5 `56588c9fb921b2f7454ec8d10bfe1f7e`, built from this pass's OWN worktree at a clean `c7a9d46c` and frozen `chmod 555` before any sweep.  (A main-tree byte comparison was NOT available: at the time the main tree carried a sister pass's uncommitted `src/ParamEmit.cpp` edit, so its `build/slang-uhdm` is not a `c7a9d46c` binary.  The pristine here is a fresh checkout of the base commit and nothing else.) |
| patched binary (SHIPPED) | md5 `5bbe3900b4c2d433fb0b42a4a035706d`, frozen `chmod 555`.  **REPRODUCED**: the pass's patch applied to a FRESH `c7a9d46c` worktree and rebuilt there gives the SAME md5 — the patch IS the artifact every number below was measured on |
| the head | **Earlgrey_0_1/default, 386 cmp lines, ONE head → 31 cmp lines, ONE head, and the head OBJECT IS GONE.**  Before: `LHS: tagged_pattern` (`tlul_socket_m1.sv:109:19-109:36`) / `RHS: hier_path(tl_h_i[0].a_valid)` — r10earl120's R0.  After: a DIFFERENT object, `LHS: logic_var (…gen_host_fifo[0].shifted_id)` (`tlul_socket_m1.sv:94:21`) / `RHS: <null>`.  Counts are DEPTH, not distance (RESUME.md §7) |
| production surface | `src/ModuleEmit.cpp`, `include/UhdmExporter.h`, `uhdm_main.cpp` — **+89 lines, of which SIX are code**.  Nothing existing was edited or removed |

---

## 1. THE JUDGE, DECODED FIRST — a **KIND** head, both sides present

`HEAD_BEFORE_Earlgrey_default.cmp` holds the pristine head in full.  Both sides
are present, so this is neither of the null shapes RESUME.md §9 warns about; the
two objects simply have different `VpiType`s and `basetype_t::Compare` stops
there.  What it names, field by field:

```
LHS (golden)  tagged_pattern @109:19-109:36
              |vpiParent   -> operation @108:26-119:6      (the vpiAssignmentPatternOp)
              |vpiPattern  -> hier_path (tl_h_i[0].a_valid) @109:19-109:36
              |vpiTypespec -> ref_typespec
                                 vpiFullName work@top_earlgrey.u_xbar_main.u_sm1_17.gen_host_fifo[0]
                                 vpiActual   string_typespec (a_valid) @109:7-109:14
RHS (ours)    hier_path (tl_h_i[0].a_valid) @109:19-109:36  -- the BARE member value
```

**THE KEY IS A `string_typespec` NAMED AFTER THE MEMBER, LOCATED AT THE KEY's OWN
SPAN** (`109:7-109:14` is `a_valid`, the value is at `109:19-109:36`), hung off
the `tagged_pattern` through a `ref_typespec` whose `VpiFullName` is the
enclosing gen-scope instance path.  `tagged_pattern::Compare`
(`~/git-repos/UHDM/build/generated/src/tagged_pattern.cpp:81-97`) reads
`VpiName`, `Pattern` and `Typespec`, in that order.

The source is `tlul_socket_m1.sv:108`, inside `for (genvar i…) begin :
gen_host_fifo`:

```systemverilog
 89    for (genvar i = 0 ; i < M ; i++) begin : gen_host_fifo
 90      tlul_pkg::tl_h2d_t hreq_fifo_i;          // <== the target, GEN-LOCAL
...
108      assign hreq_fifo_i = '{
109        a_valid:    tl_h_i[i].a_valid,         // <== the head
...
118        d_ready:    tl_h_i[i].d_ready
119      };
```

and its sibling eleven lines later, `assign hrsp_fifo_i[i] = '{…}` at `:240`, is
already `tagged_pattern` on BOTH sides — the two differ ONLY in the Lhs.

---

## 2. THE DECODE — READ IN SURELOG'S AND UHDM'S OWN SOURCE, NOT INFERRED

**WHO MINTS THE TAG.**  `CompileHelper::compileAssignmentPattern`
(`Surelog/src/DesignCompile/CompileExpression.cpp:3671-3838`) wraps EVERY keyed
pattern item in a `tagged_pattern`.  A bare member name has no
`Constant_primary` under its key, so the `slStringConst` arm at `:3782-3800`
fires and the tag typespec is a **`string_typespec` named after the key** —
exactly the object the head names.  Positional patterns take the `!with_key`
path at `:3736-3745` and get no wrapper at all.

**WHO REMOVES IT.**  Only `UHDM::ExprEval::recursiveFlattening`
(`~/git-repos/UHDM/build/generated/src/ExprEval.cpp:652-745`), which switches on
the TAG's typespec kind: `int_typespec`, `integer_typespec` and
`string_typespec` are unwrapped (`flattened->push_back(tp->Pattern())`),
everything else keeps its wrapper.  A member-name key is a `string_typespec`, so
**if the flatten runs, the wrapper always goes**; a surviving wrapper means the
flatten NEVER RAN.  `recursiveFlattening` has exactly one caller,
`ExprEval::flattenPatternAssignments` (`:750-935`).

**THE TWO CALLERS OF THE FLATTEN, AND THIS IS THE WHOLE LAW.**

1. **Surelog's writer.**  `UhdmWriter::writeCont_assign`
   (`Surelog/src/DesignCompile/UhdmWriter.cpp:2177-2219`) calls
   `eval.flattenPatternAssignments(s, tps, rhs)` and re-points the operand
   vector.  It is the INSTANCE-TREE writer and is **not conditioned on
   `-elabuhdm` at all** — but the whole block sits inside `if (tps)`, and `tps`
   comes from `bindVariable` (`CompileStmt.cpp:3089-3148`), whose scope walk
   knows `function` / `task` / `begin` / `module_inst` and **nothing else**: a
   `gen_scope` falls to the default and it recurses to the parent.  So a target
   declared in the MODULE BODY is found even from inside a generate block, and a
   target declared INSIDE the generate block is never found.  That is
   § `genScopeCaPatNoFirstSize113`'s fence verbatim, already committed here as
   `genCaLhsGenLocal113`.

2. **UHDM's elaborator.**  `cont_assign::DeepClone`
   (`~/git-repos/UHDM/templates/clone_tree.cpp:803-820`) runs the same flatten
   when the Lhs is a `ref_obj` whose `Actual_group` is a `struct_var` —
   § `patCaFlatLhsWholeName116`'s decode.  That code belongs to
   `UHDM::ElaboratorListener`, and `uhdm_main.cpp` runs it (exactly as
   `UhdmWriter.cpp:5195-5199` does) **only under `--elabuhdm`**.

A GEN-LOCAL WHOLE-NAME STRUCT TARGET HAS ONLY CALLER (2).  Therefore its
wrappers survive in the DEFAULT view and vanish in the `-elabuhdm` view — and
r10earl116's model, which set `reemitting` on the Lhs SHAPE alone, was flattening
it in both.

**MEASURED, NOT ASSUMED**, by building r10earl116's OWN arm `q1_lhs116.sv` twice
with the harness Surelog (`~/git-repos/Surelog/build/bin/surelog`, spelled in
full — r10earl120's residue R4) and counting tags per pattern operation:

| `q1_lhs116` cell | Lhs shape | golden `-parse` | golden `-parse -elabuhdm` |
|---|---|---|---|
| c1 | whole-name gen-local struct VAR | **TAGGED** | FLAT |
| c5 | whole-name gen-local struct NET | **TAGGED** | FLAT |
| c6 | whole-name MODULE-scope target, written from a gen scope | FLAT | FLAT |
| c2 c3 c7 | `bit_select` / `var_select` Lhs | TAGGED | TAGGED |
| c4 | `hier_path` (member) Lhs | TAGGED | TAGGED |

The two views differ on c1 and c5 and NOWHERE ELSE, and c6 — the module-scope
target — is FLAT in both.  That is caller (1) versus caller (2), cell for cell.

**WHY `Earlgrey_0_1/testflags` IS `CMP_EQUAL` AND STAYS SO.**  Its own command
line is

```
+define+SYNTHESIS -f lowrisc_systems_top_earlgrey_0.1.scr -elabuhdm -parse -d coveruhdm -verbose
```

(`Surelog/third_party/tests/Earlgrey_0_1/sim-icarus/Earlgrey_0_1.sl`).
`verify_golden.py:369-370` translates `-elabuhdm` into our `--elabuhdm`, so in
that mode `elabUhdmView121` is set, the law declines, and the row is
byte-identical before and after — which the byte-mover gate confirms
independently (Earlgrey_0_1/**testflags** is NOT in the mover set).

---

## 3. WHAT WAS BUILT — SIX LINES

`src/ModuleEmit.cpp`, at r10earl116's own gate, one conjunct:

```cpp
if (patFlat9 && genCaLhsGenLocal113 && !elabUhdmView121)
    patFlat9 = false;
```

`include/UhdmExporter.h`: the flag and its setter.  `uhdm_main.cpp`: one call,
from the SAME `elabUhdm == true` test that later constructs the
`UHDM::ElaboratorContext`, so the flag can never disagree with whether that
listener actually runs.

Narrowing `patFlat9` (and not `patStruct9`) is deliberate and is r10earl116's own
instruction: the three things gated are `reemitting` (the flatten) and the two
that exist ONLY because of it — the arena orphan (`pendingPatternOrphans`) and
r10earl115's element-unbind record (`patCaElemUnbind115`, which `uhdm_main.cpp`
consumes under `--elabuhdm` only anyway).  `flattenPatternCaRhs` keeps its old
reach, because the binding work below the wrapper is written by
`CompileHelper::compileSelectExpression` at COMPILE time and golden has it on the
un-flattened carrier too — and it already descends through a `tagged_pattern`
(`src/ModuleEmit.cpp`, the `uhdmtagged_pattern` arm r10earl116 added).

---

## 4. THE GRID — 3 ARMS × 2 VIEWS × GOLDEN + BOTH BINARIES

`GRID.r10earl121.txt` holds the full table.  Golden is built BOTH ways with the
harness Surelog; ours with the two frozen binaries, with and without
`--elabuhdm`.

`a1_axis121.sv` — THE AXIS.  Five gen-scope continuous assigns whose target is a
whole-name struct var declared in that same generate block, over the member-value
forms `simple id / hier path / indexed select / literal / enum constant / NESTED
pattern` in ONE ten-column pattern, at generate depth 1, at depth 2, written from
an inner block into an outer block's target, and in a generate `if` instead of a
`for`:

| view | golden | pristine | patched |
|---|---|---|---|
| `-parse` (default) | ntag=6 on all five cells | **ntag=0** | **ntag=6** |
| `--elabuhdm` | ntag=0 | ntag=0 | ntag=0 |

and the arm's OFFICIAL `uhdm-cmp` verdict in the default view goes **50 cmp lines
(head `LHS: tagged_pattern` / `RHS: ref_obj` — the corpus head's own shape, in
130 lines of SystemVerilog) → 0 lines, CMP_EQUAL**.  In the `--elabuhdm` view it
is 58 before and 58 after, and the two dumps are **byte-identical**.  Member form
changes nothing, exactly as `recursiveFlattening`'s `string_typespec` arm says.

`a2_fence121.sv` — THE ARM THAT MUST MOVE NOTHING.  Ten cells, one per reason:
a MODULE-scope target written from a gen scope (`genCaLhsGenLocal113`'s own
fence — golden FLAT in both views), a gen-local target whose NAME is also
declared in the module body (r10vearl113's namesake half — golden FLAT in both),
a `bit_select` Lhs on a module-scope array (the corpus's `hrsp_fifo_i[i]` shape),
a `bit_select` on a gen-local array, a `hier_path` member Lhs, a POSITIONAL
pattern, a MODULE-scope continuous assign, an `always_comb`, a gen-scope
parameter initializer, and a REPLICATED pattern.  **Its whole-dump md5 is
identical between the two binaries in BOTH views** (`38cde55c…` plain,
`0765d1dd…` elab) and its `uhdm-cmp` count is 30 on all four cells.

`a3_net121.sv` — the gen-local struct **NET** flavour, alone.  Default view:
pristine ntag=0 → patched ntag=2 = golden's ntag=2 (TO-GOLDEN, 3 sites × 2
cells).  `--elabuhdm` view: byte-identical dumps.  Its `uhdm-cmp` count does not
move (30 on all four cells) because a PRE-EXISTING difference sits above it in
the walk — golden lists a `wire`-typed struct under the gen scope's
`vpiVariables` as a `struct_var` and we emit no `Variables` vector there at all,
so `gen_scope::Compare`'s vector `SafeCompare` names the gen_scope with
`RHS: <null>`.  That is residue R2 and it is the SAME FAMILY as the new corpus
head (R0), which is why the arm is carried rather than deleted.

---

## 5. THE CORPUS — PREDICTION FIRST, THEN THE CENSUS, THEN THE BYTES

`cen121.cpp` walks `Serializer::AllObjects` for every `vpiAssignmentPatternOp` /
`vpiMultiAssignmentPatternOp` operation and emits one `CELL` row per OPERAND,
keyed `home-instance-fullname | pattern-op span | operand index | operand span`
(the file is deliberately OUT of the key — our objects carry an EMPTY `VpiFile`,
RESUME.md §9), with the payload `TP|<tag ts kind>|<tag name>|<tag span>|<pattern
kind>` or `RAW|<kind>`.  Two guards that the first cut of this census needed:

* **`live=`** — `UhdmListener`'s own visited set.  `AllObjects` also holds
  objects no relation reaches, and counting them manufactures phantoms.
* **`bound=`** — does the PARENT's own compared relation point back at this
  operation?  Our emitter leaves a SUPERSEDED pattern operation parented at the
  same `cont_assign` as the live one, and BOTH are "reachable"; only the one the
  parent's `Rhs()` names is the one the judge reads.  With both guards the two
  sides of `Earlgrey_0_1/default` hold **exactly the same 569 live-bound pattern
  sites and 16 744 cells**, and the WHOLE-DESIGN form table differs in ONE cell:

```
                                 golden            pristine
ow=cont_assign gen=1 nest=0      58 TAGGED         29 TAGGED + 29 BARE
ow=cont_assign gen=0 nest=0      70 BARE, 13 TAGGED   identical
ow=param_assign / port / assignment / nested        identical throughout
```

The 29 that disagree are the `gen_host_fifo` assigns; the 29 that agree are the
`gen_idrouting` ones, whose ten cells are **byte-for-byte identical to golden's**
already — the same tag shape this law now emits, in the same module.

**THE PREDICTION, made from the PRISTINE databases alone** (`predict121.py`,
whose condition is the patch's term for term — see its docstring for the
mapping; the one term it cannot see, the namesake half of
`genCaLhsGenLocal113`, can only make it OVER-count):

```
surelog     PREDICT-MOVE  rows=1 sites=29
              default    Earlgrey_0_1   29 sites
uhdm2rtlil  PREDICT-MOVE  rows=0 sites=0
```

**THE CENSUS** (`CENSUS_sl.txt` / `CENSUS_u2r.txt`), three-way multiset join,
calibration first — the GOLDEN halves of the pristine and patched sweeps are
IDENTICAL (`score121.py` refuses to score otherwise), scored FOUR ways: two
KEYINGS (`SLOT` = site + operand index, the operand's own span moved into the
payload; `POSITIONAL` = the operand span in the key) × two PROJECTIONS (`WRAP` =
the wrapper only, the field this law owns; `CELL` = the wrapper AND the value it
wraps).  **All four are CLEAN on the corpus:**

```
surelog     TO-GOLDEN     290 keys      (29 sites x 10 keyed members)
            AWAY-GOLDEN     0 · MOVED-WRONG 0 · NOGOLD_MOVED 0   in ALL FOUR
            SAME_AGREE  51 358 (SLOT) / 55 094 (POSITIONAL) keys
            STILL-WRONG  8 754 (SLOT) /  1 450 (POSITIONAL) keys  (residue R3)
            MOVER ROWS: default Earlgrey_0_1 {'TO-GOLDEN': 290}   — the only row
uhdm2rtlil  TO-GOLDEN 0 · AWAY-GOLDEN 0 · MOVED-WRONG 0 · NOGOLD_MOVED 0
            not one cell moved, in either mode, in any of the four scorings
```

**THE BYTE MOVERS**: `byteverify.sh SELFCHECK=1` reports **0 / 1358** on
uhdm2rtlil and **2 / 956** on surelog:

* `./default/Earlgrey_0_1-71da2fd7/slang.uhdm` — **PREDICTED BY NAME**, above.
* `./default/Scoreboard-59431470/slang.uhdm` — the documented ~50/50 COIN
  (RESUME.md §9).  Attributed ORDER-BLIND (`ATTRIB_Scoreboard_coin.txt`): with
  both dumps path-normalised the raw diff is 81 lines and the **sorted diff is
  ZERO lines** — not one dump line differs in content, only in order.  And this
  law cannot reach it: `Scoreboard` has **no gen-scope pattern continuous assign
  at all** (0 `CA` rows in its census) and every one of its census keys scores
  `SAME_AGREE`.

**THE ATTRIBUTION** of the real mover (`attrib121.sh` → `ATTRIB_Earlgrey_default.txt`;
both dumps path-normalised, diffed RAW and ORDER-BLIND, then SECTIONED at
`|uhdmtopModules:` so the weaklyReferenced tail is never counted):

```
ORDER-BLIND diff BY SECTION   7656 < sec=10   11136 > sec=10   (the ELAB listing)
                              1 < sec=0 / 1 > sec=0  (the dump's own header line)
ADDED   string_typespec lines 580   REMOVED 0
        58 each for a_valid a_opcode a_param a_size a_source
                  a_address a_mask a_data a_user d_ready
ADDED   tagged_pattern lines  870   REMOVED 0
```

29 sites × 10 keyed members = 290 wrappers; each tag's `string_typespec` appears
twice per site in the dump (58 = 29 × 2 per member name), each `tagged_pattern`
three times (870 = 290 × 3).  Every one of them is an ADDITION, in the
judge-reachable elaborated section, and 290 is the number `predict121.py` printed
(29 sites) before the patched database existed.

---

## 6. THE GATES — ALL GREEN, AND NO ROW CONVERTED

In one line: goldens **23 PASS / 0 FAIL on BOTH binaries** and **0 PASS / 23 FAIL
on `/bin/false`**; uhdm2rtlil **679 / 50 / 2 in both modes**, `ct8rows` PASS
three ways (committed gate, and pristine-vs-patched in each mode) and **0 / 1358**
byte movers; surelog **1588 rows**, `ct8rows` pristine-vs-patched **PASS (0
differing rows, status AND dump)** and 2 / 956 byte movers, both attributed by
name; canaries 51 + 8 ok, `ctcan2` PASS twice, `canaudit` audited=29
UNCOVERED=0 FENCE-BREACH=0.  Protected databases, md5 patched vs pristine:
`InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr` **SAME** in both modes;
`SVSwitch` `4842211c4030` and `YosysVerx` `6ccda350c24a` pins hold in both modes.
Every `cmds.txt` was audited BY BINARY PATH: 1523/1523 surelog and 1458/1458
uhdm2rtlil slang invocations used this pass's frozen binaries (the 4 without a
slang line are the `SURELOG_FAIL` rows).

`rowheads.sh` on the seven named rows, pristine → patched:

```
SeqDriver      default 50/50    testflags 50/50
SimpleUVM      default 17/17    testflags 17/17
Scoreboard     default 95/95    testflags SKIP-NOFILE (expected)
MiniAmiq       default 50/50    testflags 50/50
BuildUVMPkg    default  0/0     testflags  0/0        <- CMP_EQUAL, stays
Rggen          default  0/0     testflags SKIP-NOFILE (expected)
Earlgrey_0_1   default 386 -> 31   testflags 0/0      <- CMP_EQUAL, stays
```

one head throughout.  **The four `CMP_EQUAL` row-modes are scored on BOTH
columns and all four stay `CMP_EQUAL` with 0 cmp lines.**  None of the three
tests even has a gen-scope pattern continuous assign (0 `CA` rows apiece), and
`Earlgrey_0_1/testflags` carries `-elabuhdm`, so the law declines there by
construction.

**The one row-side that differs from the COMMITTED baseline, quoted in full and
NOT a conversion:**

```
< Earlgrey_0_1,testflags,CMP_EQUAL,,,differ      (results/golden_surelog.csv)
> Earlgrey_0_1,testflags,CMP_EQUAL,,,            (BOTH of this pass's sweeps)
```

The STATUS is `CMP_EQUAL` on both sides; only the dump diagnostic column empties,
and **it empties in this pass's PRISTINE sweep too** — `ct8rows`
pristine-vs-patched is PASS on that row, and the canary scan reports the same one
`CHANGED` line for the PRISTINE binary.  It is a `uhdm-dump` TIMEOUT under
concurrent sweeps, the identical observation r10earl119 and r10earl120 recorded.
Nothing was promoted and `results/*.csv` was not edited.

---

## 7. THE WIDE BOUNDARY — EVERY COMMITTED ARM, BOTH VIEWS

`widerun121.sh` stages a COPY of `tools/probe`, lists every `.sv`/`.v` at ANY
depth, filters the fenced names out of the list BEFORE a child runs (reading the
list out of `canaudit.sh`'s own `FENCED=` line), reads the list on fd 3 with
children `</dev/null`, and asserts PROCESSED == LISTED.

```
LISTED=5276  FENCED_REMOVED=0  (of 5276 found)
PROCESSED=5276 identical=10065 DIFFERING=53 no_output=434
rc by side:  A/0 9721  A/139 16  A/3 418  A/4 397
             B/0 9721  B/139 16  B/3 418  B/4 397     <-- SYMMETRIC
             (the 32 rc=139 SIGNAL lines are 16 per side, all in the elab view)
PROCESSED==LISTED (5276)
```

**All 53 differing cells are in the PLAIN view; ZERO in `elab`** — the law is
default-view-only by construction, and the boundary says so independently.

`rescore121.sh` then REBUILDS EACH of the 53 against GOLDEN (harness Surelog,
spelled in full, same view on both sides) and scores it cell by cell, in the same
four ways as the corpus (`BOUNDARY_MOVERS.txt`):

```
SLOT x WRAP        TO-GOLDEN 1477   AWAY 0   MOVED-WRONG 0   NOGOLD_MOVED 0   CLEAN
SLOT x CELL        TO-GOLDEN 1471   AWAY 0   MOVED-WRONG 6   NOGOLD_MOVED 0
POSITIONAL x WRAP  TO-GOLDEN 1477   AWAY 0   MOVED-WRONG 0   NOGOLD_MOVED 28
POSITIONAL x CELL  TO-GOLDEN 1471   AWAY 0   MOVED-WRONG 6   NOGOLD_MOVED 28
```

**`AWAY-GOLDEN` is 0 in ALL FOUR**, and the two non-zero columns are named, not
waved at:

* **the 6 `MOVED-WRONG`** are all `r10earl114repro/t1_root114.sv`'s `gen_r7`
  cells, `assign r7_t = '{a_valid: LP_ONE.a_valid, …}` — a member read of a
  STRUCT LOCALPARAM.  Golden folds that VALUE to a `constant`; we keep a
  `hier_path`, before AND after.  What this pass changed there is only the
  wrapper, and it now matches golden's exactly
  (`TP|string_typespec|a_valid|170:22-170:29`), which is why the `WRAP`
  projection scores those six TO-GOLDEN.  A pre-existing VALUE-fold residue of
  another law.
* **the 28 `NOGOLD_MOVED`** are the VACATED positional keys of 28 cells that
  moved to golden's key.  cen121's positional key ends in the OPERAND's own
  span, and the operand is the object this law replaces: our bare `bit_select`
  for `arr_i[i]` carries `74:35-74:36` (the INDEX's span) where the
  `tagged_pattern` that now wraps it carries `74:29-74:37` — **which is golden's
  own key, verbatim**.  Re-keyed on the SLOT they are exactly the same 28
  TO-GOLDEN cells, counted once.  (And the span is a CENSUS field, not a judge
  field: no generated `Compare` reads `VpiLineNo`/`VpiColumnNo` — RESUME.md §9 —
  so this column can only ever be evidence about WHICH object is in the slot,
  never an acceptance term.)

**No differing arm got WORSE by the judge**: 15 of the 53 have a LOWER official
`uhdm-cmp` line count patched (NINE reach **0 = CMP_EQUAL**: `p1_pos115`,
`v1_decl113`, `v4_ctx113`, `w10_nsblk`, `w11_nssib`, `w12_deep2`, `w2_outergen`,
`w5_nestinst`, and this pass's `a1_axis121`), 38 are unchanged, **zero go up**.

**THE MUST-STAY FLOOR**, checked by name against the differing list:
r10earl120's arms, r10earl119's arms and its all-fences arm, § 106's arms and
fences, r10earl118's arms and fence, r10earl110/111/117's arms, and uvm82-91 /
buvm3-15 / sd8-12 are **NONE of them in the list**.  What moved is
r10earl112-116's gen-scope assignment-pattern family and the verifier arms built
for it — which IS this law's population; a law that moved none of them would not
be the law — plus `r10earl61`'s two and `r10vearl117repro/va3_scope117.sv`, all
re-scored above.

---

## 8. RESIDUES

* **R0 — THE NEXT HEAD, named and measured.**  `Earlgrey_0_1/default`, now 31
  cmp lines / 1 head: `LHS: logic_var (work@top_earlgrey.u_xbar_main.u_sm1_17.
  gen_host_fifo[0].shifted_id)` at `tlul_socket_m1.sv:94:21-94:31` against
  `RHS: <null>`.  `logic [IDW-1:0] shifted_id;` is declared at `:94` inside the
  same `gen_host_fifo` block and continuously assigned at `:96`; golden lists it
  on the gen scope and we do not reach it there.  It is PRE-EXISTING and merely
  unmasked.  `HEAD_AFTER_Earlgrey_default.cmp` holds it.  **It is the same family
  as R2** (`a3_net121`'s arm cell), so that arm is the reduced repro for whoever
  takes it.
* **R1 — THE `-elabuhdm` HALF OF THE Lhs SHAPE TEST IS STILL A PROXY.**
  `cont_assign::DeepClone` tests `Actual_group<struct_var>`; r10earl116's model
  tests "the Lhs is a whole-name reference", and this pass did not narrow that.
  Arm `a3_net121`'s `--elabuhdm` cell is where the two disagree: golden's
  elaborated `Actual_group` there is a `struct_net`, its flatten never runs, and
  golden stays TAGGED while we go FLAT (P = X = ntag 0, so this pass moved
  nothing there).  r10earl116's own `q1_lhs116` cell c5 — the same source
  construct in a different module — comes out `struct_var` and DOES flatten, so
  the discriminator is not the `wire` keyword alone.  Whoever takes it should
  start from those two cells side by side.
* **R2 — A GEN-LOCAL NET/VAR MISSING FROM THE GEN SCOPE'S `vpiVariables`.**
  Golden lists a `wire`-typed packed struct declared in a generate block under
  the gen scope's `Variables()` as a `struct_var`; we emit no `Variables` vector
  on that scope at all, so `gen_scope::Compare` names the gen_scope with
  `RHS: <null>`.  Present on BOTH binaries, in both views, in `a3_net121`.  R0 is
  the corpus instance of it.
* **R3 — THE `STILL-WRONG` CENSUS KEYS ARE NOT THIS LAW'S** (1 450 positional /
  8 754 slot-keyed on the surelog corpus; the two counts differ because a slot
  whose operand span disagrees is ONE slot-key and TWO positional keys).  They are
  pattern operands whose disagreement is the operand's own KIND or SPAN, not its
  wrapper — other passes' families.  Named here so the number is not mistaken for
  this law's residue.
* **R4 — THE TWO-SURELOG TRAP, re-paid once.**  Every golden in this directory
  was built with `~/git-repos/Surelog/build/bin/surelog`, the path
  `scripts/verify_golden.py` names, spelled in full.  The shell `surelog` alias
  is a DIFFERENT build (r10earl120's R4).

---

## 9. FILES

| file | what it is |
|---|---|
| `cen121.cpp` | THE CENSUS: every assignment-pattern OPERAND keyed by site and span, payload = wrapped-with-this-tag or bare-of-this-kind; per-site `SITE` rows carrying the FORM axes (owner statement, gen scope, nesting, operand and tag counts, op typespec, root, `live`, `bound`), and per-`cont_assign` `CA` rows carrying everything `cont_assign::DeepClone`'s gate and `bindVariable` read (Lhs kind, `Actual_group` kind, `agpar` = the target's DECLARING scope, the struct's member count) |
| `censweep121.sh` | runs it over a whole `verify_golden.py` workdir, golden path from each test's OWN `cmds.txt`, every rc logged |
| `predict121.py` | the mover set predicted BY NAME from the PRISTINE census alone, on the patch's own condition term for term |
| `score121.py` | the three-way multiset join; asserts the two sweeps' golden halves identical FIRST |
| `PREDICT_sl.txt` / `PREDICT_u2r.txt` | the predictions, made from the pristine databases |
| `CENSUS_sl.txt` / `CENSUS_u2r.txt` | the corpus three-way scores, calibration line first |
| `a1_axis121.sv` | THE AXIS ARM: five gen-local whole-name struct targets × six member-value forms × generate depth / shape |
| `a2_fence121.sv` | THE FENCE ARM: ten cells that must not move, one per reason |
| `a3_net121.sv` | the gen-local struct NET cell, alone, with residues R1 and R2 |
| `GRID.r10earl121.txt` | the scored arm grid (golden / pristine / patched, both views) with each arm's `uhdm-cmp` count and workdir-normalised dump md5 |
| `HEAD_BEFORE_*` / `HEAD_AFTER_*` | the official `uhdm-cmp` head of Earlgrey_0_1 in both modes, before and after |
| `attrib121.sh` / `ATTRIB_Earlgrey_default.txt` / `ATTRIB_Scoreboard_coin.txt` | the sectioned, path-normalised, ORDER-BLIND whole-dump attribution of the two byte movers |
| `wide121.sh` / `widerun121.sh` / `BOUNDARY_*` | the wide boundary over every committed arm, both views, with the fence filter, the rc histogram by side, and the differing list |
| `rescore121.sh` / `BOUNDARY_MOVERS.txt` | REBUILDS every differing arm×view against GOLDEN and scores it cell by cell, four ways (SLOT/POSITIONAL × WRAP/CELL), with the official `uhdm-cmp` count for all three sides |
| `GATES.r10earl121.txt` | the gates, every command and every number |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the gate scripts, carried so this directory reproduces the battery on its own |
