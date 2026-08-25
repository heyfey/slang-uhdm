# r10earl91 — § `inlineUnpackedArrayPatternNoFirstSize91`

**THE EARLGREY `hier_path` `VpiSize` HEAD CLEARED IN BOTH MODES.**
`Earlgrey_0_1` default and testflags, **110 / 142** cmp lines and ONE head each
at `c887390`; the head object is the `hier_path` `reg2hw.cfg0.prescale.q` in
`rv_timer.sv:56`'s `'{...}` assignment pattern — golden leaves its `VpiSize`
UNSET and we stamped **12**. After the pass the object is **GONE from both
logs** (`grep -c 56:24` = 0) and the head is a different, deeper cell
(**250 / 278** lines, still ONE head each).

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `c887390`, branch `auto5h`.** `results/*.csv` was **READ ONLY** and is
untouched — **NO ROW WAS CONVERTED** (`Earlgrey_0_1` stays `CMP_NOTEQUAL` in
both modes; its head is cleared, the design has more — see `PREDICT_R0.txt`).
slang was **NOT** patched. Production surface: **`src/ExprEmit.cpp` only.**

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_Earlgrey_{default,testflags}.cmp` are the verbatim pristine logs
from this pass's own build of `c887390` (binary md5
`1fe90f78fd44f1a6c8774c47b717095c`).

```
hw/ip/rv_timer/rtl/rv_timer.sv:29   logic [11:0] prescaler [N_HARTS];
hw/ip/rv_timer/rtl/rv_timer.sv:56   assign prescaler = '{reg2hw.cfg0.prescale.q};

LHS (golden)  hier_path (reg2hw.cfg0.prescale.q) id 1008881  56:24-56:46
              |vpiParent: operation 56:22-56:47   (the '{...} pattern)
              ... NO vpiSize
RHS (ours)    the same object, id 335701, EVERY OTHER FIELD IDENTICAL —
              the four Path_elems ref_objs (reg2hw / cfg0 / prescale / q),
              their spans, their names, the trailing element's vpiFullName
              work@top_earlgrey.u_rv_timer.q, and vpiName
              reg2hw.cfg0.prescale.q — plus  |vpiSize:12
```

**THE ARM, decoded the way RESUME §9 demands.** `hier_path::Compare`
(`UHDM/build/generated/src/hier_path.cpp:110-125`) delegates FIRST to
`basetype_t::Compare`, and `hier_path`'s basetype chain reaches
`expr::Compare`, whose scored lines are `VpiDecompile` (`expr.cpp:89`),
**`VpiSize`** (`:95`) and `Typespec` (`:100`) — **all three BEFORE**
`hier_path`'s own `Path_elems` / `Root_value` / `VpiName`. So the head is a
`VpiSize` mismatch on the hier_path itself — 12, the width of `prescale.q` —
and NOT a Path_elems or a naming defect. The two modes' logs differ only in
that testflags' golden binds the elements' `vpiActual`s; the FAILING FIELD is
the same one, so there is ONE R0.

`g1_head91.sv` reproduces the head from nothing: 22 hier_paths, **ONE cell
differs**, and it is this one.

---

## 2. Question 1 — the Surelog decode, read out of the source

1. **The elaborated cont_assign's pattern RHS is re-materialised.**
   `UhdmWriter::writeCont_assign` (`UhdmWriter.cpp:2178-2218`) runs
   `ExprEval::flattenPatternAssignments` and then, for a
   `vpiAssignmentPatternOp`, `CompileHelper::expandPatternAssignment`.
2. **`expandPatternAssignment`'s UNTAGGED arm** (`CompileHelper.cpp:5238-5257`)
   walks the operands:
   ```cpp
   expr* vexp  = reduceExpr(cop, invalidValue, ...);
   uint64_t v  = eval.get_uvalue(invalidValue, vexp);
   int32_t csize = adjustOpSize(tps, cop, opIndex, rhs, ...);
   if (invalidValue) { return result; }        // <-- AFTER adjustOpSize
   ```
   The size is written **before** the `invalidValue` check, which is exactly
   why an UNREDUCIBLE first operand still gets a size and the walk then stops.
   That is the emitter's existing law: *"a re-emitted OUTERMOST pattern sizes
   its FIRST operand."*
3. **`CompileHelper::adjustOpSize`** (`CompileHelper.cpp:4944-5035`) dispatches
   on the ASSIGN TARGET's typespec and writes `cop->VpiSize(ncsize)` in every
   branch **BUT ONE**:
   ```cpp
   } else if (rtps->UhdmType() == uhdmarray_typespec) {
     array_typespec* atps = (array_typespec*)rtps;
     if (const ref_typespec* ert = atps->Elem_typespec()) {   // <-- THE GATE
       int32_t ncsize = Bits(ert->Actual_typespec(), ...);
       adjustUnsized(any_cast<constant*>(cop), ncsize);
       cop->VpiSize(ncsize);
     }
   }
   ```
   The `uhdmstruct_typespec` branch sizes per member, the `uhdmlogic_typespec`
   branch writes `fullSize / innerSize`, and the `else` branch writes
   `Bits(rtps)` — all unconditionally. Only the **array** branch can leave the
   operand untouched, and only when `Elem_typespec()` is NULL.
4. **AN UNPACKED ARRAY DECLARED INLINE HAS A BARE `array_typespec`.** Measured,
   not assumed: `g2_first91`'s golden dump holds **22 `array_typespec` objects
   with no ranges, no location and no `Elem_typespec`** — one per inline
   unpacked declaration in each of the two views — next to a separate
   `logic_typespec` carrying the element's `[11:0]` range. So the `if` fails,
   the size is never written, and **every operand keeps whatever size it
   already had**.
5. **A TYPEDEF'd unpacked array is the other half.** Surelog DOES fill that ref
   (`ElaborationStep.cpp:211`, `UhdmWriter.cpp:752` and `:3195`), golden sizes
   operand 0 at the element width, and this emitter already lands on it. That
   is why the predicate below is the **SPELLING** — `expr.type`'s OWN kind —
   and not the canonical kind.

---

## 3. Question 2 — THE CENSUS, both corpora

Two instruments, two different keys, one answer. Both read a `.uhdm` DIRECTLY
(earl61's direct-reader pattern; Earlgrey's dump is >1 GB and RESUME §9 forbids
a whole-dump diff there), and both dispatch nothing.

* **`ct91cen`** enumerates EVERY `hier_path` and prints exactly what
  `hier_path::Compare` reads. KEY = `SPAN + PKIND + POP + OPIDX + CTX +
  PORTPAR + LHSK + LHSTS + CALLARG + INSEL + ROOT` (+ `INST` on arms).
  PAYLOAD = `SZ DEC NAME NEL ELEMS RV TS TSN TSRG`, no span-derived field
  (earl60's `attrv60` lesson).
* **`ct91pat`** enumerates EVERY operand of EVERY assignment-pattern / concat
  operation **BY POSITION** — the whole denominator the law's site can reach,
  not just hier_paths — so a cell that changed KIND is still found under the
  same key.

### The hier_path census (`CENSUS.hier_path.txt`)

| | surelog (166 dbs, both modes) | uhdm2rtlil (314 dbs) |
|---|---:|---:|
| SZ-BOTH-0 | 52 618 | 3 334 |
| SZ-BOTH-SET (values agree) | 4 | 2 |
| **SZ-OURS-ONLY** (we size, golden does not) | **4** | **0** |
| **SZ-GOLD-ONLY** (golden sizes, we do not) | **0** | **0** |
| SZ-VALUE-DIFF | 0 | 0 |
| GOLDEN-ONLY / OURS-ONLY / SHAPE-DIFF | 3 298 / 3 844 / 51 | 6 / 18 / 0 |

**ALL FOUR `SZ-OURS-ONLY` CELLS ARE IN `Earlgrey_0_1`** — two in `default`,
two in `testflags` — at `rv_timer.sv:56:24` (SZ 12, `prescaler`) and
`rv_timer.sv:57:24` (SZ 8, `step`), both `PKIND=operation POP=75 OPIDX=0
CTX=CONTASSIGN`. **`SZ-GOLD-ONLY` is 0 in both corpora**: golden never sizes a
hier_path anywhere, so an AWAY-GOLDEN cell is not merely absent here, it is
structurally impossible for this object kind.

The four `SZ-BOTH-SET` controls are the shape that *does* carry a size on both
sides — `FuncAlias` / `GenStructAccess` (surelog) and `gen_struct_access`
(u2r), all `'{f1: pipe[3].f1[63:0], f2: ...}` into a **packed struct**, golden
`SZ=64` and ours `SZ=64`. They are `StructuredAssignmentPattern` cells against
a struct target and this law cannot reach them; the AFTER census asserts they
did not move.

### The pattern-operand census (`CENSUS.pattern.txt`)

| | surelog | uhdm2rtlil |
|---|---:|---:|
| **SZ-EXTRA-PAT0** (same object, ours sized, golden bare) | **4** | **0** |
| SZ-MISSING-PAT0 (golden sized, ours bare) | 1 | 6 |
| SZ-DIFF-PAT0 (both sized, different value) | 0 | 2 |
| BOTH-SAME / MOVED-WRONG | 36 132 / 5 699 | 2 812 / 56 |
| GOLDEN-ONLY / OURS-ONLY | 4 697 / 5 480 | 16 / 20 |

The four `SZ-EXTRA-PAT0` cells are the same four. The `SZ-MISSING` /
`SZ-DIFF` cells belong to OTHER laws (a STRUCT-typed pattern target at
`rv_timer.sv:211`, ranked **R1**); this law only ever REMOVES a size on an
inline-unpacked-array target, so it cannot reach them, and the AFTER census
asserts they did not move.

---

## 4. Question 3 — the law

**§ `inlineUnpackedArrayPatternNoFirstSize91` — a re-emitted (elaborated)
OUTERMOST `'{...}` assignment pattern does NOT size its first operand when the
pattern's TARGET TYPE is an UNPACKED ARRAY SPELLED INLINE. Surelog models such
a declaration's typespec as a BARE `array_typespec` with no `Elem_typespec`,
and that is the one branch of `CompileHelper::adjustOpSize` which leaves
`cop->VpiSize()` untouched — so every operand keeps the size it already had:
0 for a reference / select / operation / hier_path, its own written width for
a sized literal, and 64 for an unsized decimal. A TYPEDEF'd unpacked array,
and every PACKED or STRUCT target, keep the stamp.**

Shipped in `src/ExprEmit.cpp` as **one predicate at ONE call site** — the
`SimpleAssignmentPattern` arm's `reemitting` first-operand stamp. **It only
ever WITHHOLDS a size**; it writes no value, no encoding, no typespec, no
parent, and it cannot add an object.

### The fences, each a negative control MEASURED ON GOLDEN

| | fence | measured |
|---|---|---|
| (a) | **the target must be an unpacked array SPELLED INLINE** | `g4 h1` (`typedef logic [11:0] wd_t [2]; wd_t h1;`) and `g4 h2` (`typedef sm_t sma_t [2];`): golden **DOES** size operand 0 (12 and 8) and both binaries agree, before and after. Corpus witness: u2r's `assignment-pattern` reaches the site with `tgtKind=TypeAlias` and `szOld=szNew=192` |
| (b) | **not a PACKED target** | `g2 pk_hp` (`logic [1:0]`) golden sizes operand 0 at **1** (`fullSize/innerSize`), `g4 h5` (`logic [1:0][11:0]`) at **2** — `adjustOpSize`'s `uhdmlogic_typespec` branch, untouched here (the value we write there is wrong; ranked **R2**) |
| (c) | **not a STRUCT target** | `g2 s_hp`, `g4 h6`: the `flattenPatternAssignments` path (§ `patFlatAdjustStopsAtUnvaluable27`), untouched. Corpus witnesses `AssignRhsFlat` and `PatternOrder` reach the site with `tgtKind=UnpackedStructType` and `szOld=szNew=1` |
| (d) | **the OUTERMOST pattern only** | `g1 P10` (`'{'{...}}` into `logic [11:0] nest [1][1]`) and `g3 t10`: the inner pattern is guarded by `wasInPattern` and was already agreeing on both sides, before and after |
| (e) | **the ELAB view only** | every arm's DEF-view copy of every cell carries `SZ=0` on BOTH sides before and after; the stamp lives behind `reemitting` |
| (f) | **the PARAMETER-INITIALIZER pattern is a different producer** | `g4 H4` / `s91::PP` (`localparam logic [11:0] H4 [2] = '{12'd6, 12'd7}`) — § `elabPatternFirstRowElemSize45`'s site, the `inParamInit && !paramInitDef` block further down the same arm: byte-identical on both sides, before and after |
| (g) | **a procedural assignment** | `g3 t13`, `g4 h9` (`always_comb x = '{...}`): one copy, `SZ=0` both sides, before and after |

### The first-operand grid (`g2_first91.sv`), golden, ELAB, target `logic [11:0] x [1]`

| operand 0 | golden | pristine (elab copy) | patched |
|---|---|---|---|
| `reg2hw.cfg0.prescale.q` (hier_path) | **no size** | 12 | **= golden** |
| `v12` (ref_obj) | no size | 12 | **= golden** |
| `arr12[0]` (bit_select) | no size | 12 | **= golden** |
| `din[7:0]` (part_select) | no size | 12 | **= golden** |
| `v12 + 12'd1` (operation) | no size | 12 | **= golden** |
| `12'(...)` (cast) | no size | 12 | **= golden** |
| `12'd5` (a SIZED literal) | 12 (its OWN width) | 12 | = golden |
| `5` (an UNSIZED decimal) | **64** | 12 | **= golden (64)** |
| a nested `'{...}` (`st_t sa [1]`) | no size | 20 | **= golden** |

### The target-declaration grid (`g3_targets91.sv`), golden, ELAB, operand 0

| target | golden | patched |
|---|---|---|
| `logic [11:0] t1 [NH]` (the head's own shape) | **none** | = golden |
| `logic [11:0] t2 [0:0]` | none | = golden |
| `logic [11:0] t3 [1:0]` (DESCENDING) | none | = golden |
| `logic [11:0] t4 [2]` | none | = golden |
| `logic t5 [2]` (SCALAR element) | none | = golden |
| `logic [NW-1:0] t6 [1]` (PARAMETERISED width) | none | = golden |
| `w_t t7 [1]` (TYPEDEF'd ELEMENT, inline dim) | none | = golden |
| **`wa_t t8`** (TYPEDEF'd UNPACKED ARRAY) | **12** | **12 — KEPT** |
| `sm_t t9 [1]` (unpacked array of PACKED STRUCT) | none | = golden |
| `logic [11:0] ta [1][1]` (2-D) | none | = golden (already agreed) |
| `logic [1:0][5:0] tb [1]` (PACKED-ARRAY element) | none | = golden |
| `logic [11:0] tc [1]`, root an INTERFACE member | none | = golden |

### The home grid (`g4_homes91.sv`)

Golden sizes nothing, and the patch lands on golden, in every home measured: a
module body, a `for`-generate with **three instances**, an `if`-generate's own
gen-local net, and an `always_comb`. The typedef'd spellings (`wd_t`,
`sma_t`) keep the stamp in every home.

---

## 5. Question 4 — the arms

`arm91.sh` builds each arm with Surelog (`-parse -nobuiltin -nocache -d uhdm`)
and with BOTH FROZEN binaries, censuses all three with `ct91pat --inst`, and
scores every cell three ways as a MULTISET. Every child gets `</dev/null` and
its rc is recorded. Full output: `ARMS.r10earl91.txt`.

| arm | what it holds | KEYS | SAME→SAME | WRONG→RIGHT | **RIGHT→WRONG** | EXACT | TO-GOLDEN | **AWAY** |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| `g1_head91.sv` | the head minimised + **ELEVEN PARENTS** for one dotted read | 9 | 8 | 1 | **0** | 1 | 0 | **0** |
| `g2_first91.sv` | **THE FIRST-OPERAND GRID**: 8 operand kinds × 6 target kinds | 55 | 37 | 8 | **0** | 8 | 1 | **0** |
| `g3_targets91.sv` | **THE TARGET-DECLARATION GRID**: 13 unpacked spellings | 43 | 30 | 9 | **0** | 9 | 1 | **0** |
| `g4_homes91.sv` | **THE HOME / TYPEDEF / NEGATIVE-CONTROL GRID** | 55 | 48 | 2 | **0** | 2 | 0 | **0** |

**`RIGHT→WRONG` 0 and `AWAY` 0 on every arm.** The two `TO-GOLDEN` cells are
the `unpacked array of packed struct` shape where golden holds ONE elaborated
copy of the pattern and we hold TWO (a PRE-EXISTING count defect, ranked
**R4**): every one of our objects now carries golden's payload.

**THE TWO VIEWS.** The arms above are scored against a Surelog golden built
with Surelog's own default flags, so their DEF and ELAB copies both live in one
database and are keyed apart by the census (`PORTPAR`, and the copy count).
The `--elabuhdm` view is measured where a matching golden exists: the
**corpus**, where `Earlgrey_0_1`/**testflags** IS the `--elabuhdm` run and its
two cells cleared exactly like `default`'s (`CENSUS.hier_path.txt`), and the
**wide boundary**, which compares both views of all 4099 sources binary to
binary. Scoring an `--elabuhdm` arm against a plain Surelog golden joins
nothing (the key sets differ) and is deliberately not claimed here.

`g1_head91.sv` also answers the parent grid the brief asked for, on golden:
the SAME `reg2hw.cfg0.prescale.q` read carries **no `VpiSize` under any of the
eleven parents** — an assignment-pattern element, a nested pattern, a
replicated pattern, a concatenation, a bare cont_assign RHS, an operation
operand, a select base, a cast operand, a `$unsigned` argument, a port
`High_conn` (both `module_inst` and `ref_module` views) and a procedural
assignment.

---

## 6. The gates

All green — `GATES.r10earl91.txt` has the full battery. In one line: goldens
**23/0** and **0/23** on the negative control; uhdm2rtlil **679/50/2** in both
modes with **0 differing rows** and **0 byte movers / 1358**; surelog
**471+466 CMP_EQUAL / 10+9 CMP_NOTEQUAL** with **0 differing rows over 1588**
and **2 byte movers / 956** — the two `Earlgrey_0_1` databases this pass
PREDICTED BY NAME from the pristine census AND from the pristine cell trace;
canaries `ok=52` / `ok=8` `changed=0`, both `ctcan2` PASS, `canaudit`
`audited=29 UNCOVERED=0 FENCE-BREACH=0`, all five protected databases
byte-identical (`SVSwitch` `4842211c4030`, `YosysVerx` `6ccda350c24a`).

**THE MOVERS ARE ATTRIBUTED THREE WAYS, and all three are exact.**

* **A run-time A/B gate.** The patched binary run with `R10E91_OFF=1` (the law
  disabled, everything else identical) re-runs Earlgrey's own two command
  lines in its own directory and reproduces the PRISTINE database **byte for
  byte in both modes** — `43a8d277a6fc` and `02496164d2f6`, the pristine
  sweep's own hashes — while the law ON gives `b78f6e7ceabb` / `88e7443dcde5`,
  the patched sweep's own. **100 % of each mover's byte delta is this law**,
  and the same gate holds on all four arms.
* **The two direct-reader censuses**, fixed-universe, with the GOLDEN side
  ASSERTED UNCHANGED (all 230 + 316 + 166 + 314 `.gold` files byte-identical
  before and after): hier_path `SZ-OURS-ONLY` **4 → 0**, `SZ-GOLD-ONLY`
  **0 → 0**, `SZ-BOTH-SET` **4 → 4**, `SZ-BOTH-0` 52 618 → 52 622, every
  one-sided set unchanged; pattern `SZ-EXTRA-PAT0` **4 → 0**,
  `SZ-MISSING-PAT0` 1 → 1, BOTH-SAME 36 132 → 36 134, MOVED-WRONG
  5 699 → 5 697. uhdm2rtlil: **every bucket of both censuses unchanged**.
  **WRONG→RIGHT 4, RIGHT→WRONG 0, AWAY-GOLDEN 0, STILL-WRONG 0.**
* **The run-time cell trace over every command line in both corpora**
  (`PREDICT_TRACE.*`): 10 + 6 cells REACH the site, 4 + 2 change their answer,
  and the two u2r cells are proved NON-movers by byte-identity **and** decoded
  (`struct_pattern_loop`'s based-literal operand is re-zeroed by ModuleEmit's
  unpacked-array cont-assign arm immediately afterwards — ranked **R3**).

**THE WIDE BOUNDARY** (`vwide91.sh`, list on fd 3, children `</dev/null`,
PROCESSED asserted): **LISTED = PROCESSED = 4099** `.sv`/`.v` sources at any
depth under a copy of `tools/probe`, both views, both frozen binaries,
workdir-normalised dump byte-compare, rc histogram SYMMETRIC side for side
(7513/7513 rc=0, 14/14 rc=139, 336/336 rc=3, 335/335 rc=4). **12 differing
cells; eight are this pass's own four arms in both views.** Of the rest:

| file | verdict |
|---|---|
| `r10earl61repro/v4_v61.sv` | **This law.** D4 is `t61_t ua [1:0]; assign ua = '{'{…}, '{…}};` — an INLINE unpacked array of packed structs. Re-scored against a fresh Surelog golden: the one moved cell goes `SZ=12 → SZ=0`, which is golden's; `RIGHT->WRONG 0`, `AWAY 0`. Its residual difference is a PRE-EXISTING typespec the operand carries and golden's does not |
| `r10buvm22repro/g22.sv` | **NOT this law** — the A/B gate proves it: `R10E91_OFF=1` on the patched binary still prints the PATCHED dump hash (`021e46c32a3c`), identical to law-ON, while the pristine binary prints `7b98184cd3c5`. Both binaries exit `rc=4` and emit no comparable database. It is the pre-existing garbage numeric literal whose value TRACKS THE BINARY'S CODE LAYOUT that r10earl84's R5 recorded, and it moved for earl84, earl89 and earl90 the same way |

So **every earlier-pass arm that moved was re-measured against a fresh golden
and moves TOWARD it**; `RIGHT->WRONG 0` and `AWAY 0` on both.

---

## 7. Files

| | |
|---|---|
| `ct91cen.cpp` | the hier_path census; direct `.uhdm` reader, dispatches nothing |
| `ct91pat.cpp` | the assignment-pattern OPERAND census, keyed by POSITION |
| `cen91.sh` | runs either over a whole `verify_golden` workdir, golden path from each test's OWN `cmds.txt` |
| `hpsz91.py` | the hier_path `VpiSize` presence scorer (`SZ-OURS-ONLY` / `SZ-GOLD-ONLY` / …) |
| `score91.py` | the multiset join + the SIZE-PRESENCE family extractor (`--family`) |
| `score3_91.py` | the 3-way per-cell verdict (SAME→SAME / WRONG→RIGHT / **RIGHT→WRONG** / EXACT / **AWAY**) |
| `patrows91.py` | the flat side-by-side operand table (golden vs ours, per span/idx/kind/size) |
| `arm91.sh`, `bdscore91.sh` | one arm / one boundary mover: three databases, three-way score |
| `predict91.sh`, `dirmap91.sh` | the mover prediction: every pristine command line re-run under `R10E91_OFF=1 R10E91_CELLDBG=1`, in the test's own directory. `dirmap91.sh` rebuilds the workdir-suffix → source-directory map and is where the FENCE lives: the four slang-fenced tests' directories are OMITTED, listed only as opaque sha1[:8] hashes, so the driver prints `FENCED-SKIP` and runs nothing |
| `vwide91.sh`, `bdlist91.sh` | the wide boundary and its file list |
| `g1_head91.sv` … `g4_homes91.sv` | the purpose-built goldens |
| `HEAD_BEFORE_*.cmp`, `HEAD_AFTER_*.cmp` | the verbatim `uhdm-cmp` logs, both modes |
| `CENSUS.*`, `ARMS.*`, `GATES.*`, `PREDICT_*`, `BOUNDARY_WIDE.*`, `SCORE.boundary_movers.txt` | the measurements |
| `PREDICT_R0.txt` | the mover prediction and the NEXT HEAD, decoded |

Build the census tools with
`g++ -O2 -std=c++17 ct91cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct91cen`
(and the same for `ct91pat.cpp`).

`R10E91_OFF=1` disables the law at run time in the shipped binary and
`R10E91_CELLDBG=1` names every cell that REACHES the first-operand stamp with
BOTH answers; they are the A/B gate and the mover predictor every attribution
here rests on. The predicate is computed OUTSIDE the `OFF` switch so the
neutral binary still names both answers.
