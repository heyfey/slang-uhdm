# r10earl67 — § genLpBitSelIdxOneHopFold67

**BASE `502642d`.  Earlgrey_0_1, BOTH modes.  The head earl66 named as R0 is
CLEARED, and with it the largest single family on the ladder (1,995 cells);
the new head is in `PREDICT_R0.txt`.**

Pristine binary md5 `560a8eb9f2b4afcb5ea7f4e48a732169`,
patched binary md5 `ddf27fe553b2aeb4852d73f8de32abba`.
Golden caches (immutable, read-only): `00d4794526e44dc553f3` (default),
`d7348d2d2fe67abe767b` (testflags).

---

## 1. The head, decoded before any code

```
LHS: constant  id:310350  142:34-142:36
     |vpiParent -> bit_select (…gen_tree[0].gen_level[0].gen_nodes.req_tree)
     |vpiDecompile:1  |vpiSize:32  |INT:1  |vpiConstType:7
     |vpiTypespec -> ref_typespec -> int_typespec (105:20-105:32)
RHS: ref_obj (…gen_tree[0].gen_level[0].gen_nodes.C0) id:251945  142:34-142:36
     |vpiName:C0     (NO vpiActual — unbound in our elaborated cont_assign)
```

`bit_select::Compare` (UHDM/build/generated/src/bit_select.cpp) compares
`VpiConstantSelect` and then runs the **singular**
`SafeCompare(lhs->VpiIndex(), rhs->VpiIndex(), context)`.  Both operands are
**non-null** with **different `UhdmType`**, so `BaseClass::Compare`'s type test
fails first and BaseClass.h:188's `(lhs != nullptr) && (rhs != nullptr)` arm
names **both** sides in full — neither the `<null>` singular arm nor a vector
size mismatch.  Read the MK line, not the shape (RESUME §9).

The owner is `prim_arbiter_tree.sv:142`

```systemverilog
assign sel = ~req_tree[C0] | req_tree[C1] & rr_q[NumLevels-1-level];
```

inside the `gen_nodes` branch of a generate-**if**, itself inside the
`gen_level` for-generate, itself inside the `gen_tree` for-generate.  **The
brief's premise that `C0`/`C1`/`Pa` are declared in `gen_nodes` is wrong and
the source refutes it**: lines 104-106 declare them in **`gen_level`**, one gen
scope OUT from the read.  That single fact is the whole pass — it makes the
head a **distance-1** cell, and distance 1 is the one distance
§ genLpUseFoldParentScope47 (r10earl47) already measured golden to substitute
at.

Also refuted before any code: the brief asks why an `int unsigned` localparam
folds to `INT:1 vpiConstType 7`.  It does not fold to its declared signedness
at all — the fold is a **COPY of the localparam's own `param_assign` Rhs
constant**, whose INT encoding our emitter already mints
(§ genLpFoldSignedStructural46, a structurally-signed initializer).  Nothing in
this pass re-derives an encoding; `GRIDS_67.txt` §D records the eight declared
types measured on golden and the patched binary reproduces all eight.

> **Golden folds a read of a gen-scope localparam declared ONE gen scope up to
> a copy of that localparam's own folded constant, carrying its LOCATED
> declaration typespec, when the read is the INDEX of a bit_select in an
> ELABORATED gen-scope cont_assign; we keep an unbound `ref_obj`.**

## 2. The census: 1,995 cells, and the whole superfamily

Direct `.uhdm` reader, never `uhdm-dump` (Earlgrey's dump is >1 GB — the
earl61-66 rule).  `tscen67` extends `r10earl66repro/tscen66.cpp` with the
referenced object's **full name** (`afn=`) and the typespec's **signedness**,
so a cell can be classified by the DISTANCE between the read and the
declaration without a second pass.  `nospan67.sh` strips `span=`/`tsspan=`/
`afn=` before scoring: earl60's `attrv60.py` lesson says a span-carrying
payload hides real flips inside STILL-WRONG.

**Calibration first (RESUME §9):** the golden re-read is byte-identical and the
golden-vs-golden multiset join is **0 differing cells / 162,259**.

Whole-design kind-pair join, pristine binary, default mode:

```
  87915  G=ref_obj              O=ref_obj
  49215  G=constant             O=constant
  17011  G=bit_select           O=bit_select
   2222  G=constant             O=ref_obj      <-- the "golden folds / we do
   1616  G=var_select           O=var_select        not" SUPERFAMILY
   1045  G=<none>               O=ref_obj
```

and the superfamily splits by position and referenced symbol exactly as
earl66's `PREDICT_R0.txt` predicted:

| cells (def / tf) | sec | site | position | symbol |
|---:|---|---|---|---|
| **1995 / 1995** | **ELAB** | **cont_assign** | **bit-select idx** | **`C0` 792, `C1` 792, `Pa` 411 — THIS PASS** |
| 89 / 89 | ELAB | cont_assign | whole Rhs | `offset` (genvar) |
| 87 / 0 | ELAB | cont_assign | `op11[]` | `IDW`, `STIDW` |
| 32 / 32 | ELAB | cont_assign | `op33[]` | `MioPeriphHasSleepMode` |
| 16 / 16 | ELAB | High_conn | bit-select idx | `N` |
| 3 / 3 | ELAB | High_conn | ips base | `DataBitWidth` |
| 0 / 261 | ELAB | cont_assign | `hp[]/idx` | `i` (genvar, in a hier_path) |

**Every one of the 1,995 is a `gen_nodes` read of a `gen_level` localparam** —
one hop, no exceptions, in both modes (`sfam67.py`, and the per-scope breakdown
in §2 of this pass's own run log).

## 3. Where it comes from, decoded not guessed

Two independent decodings agree:

* **Surelog.** `NetlistElaboration` compiles an ELAB gen-scope cont_assign in
  the *instance* context with `Reduce::Yes`; an identifier that `getValue`
  answers is replaced by a `Value`-built constant carrying the parameter's own
  typespec (`CompileExpression.cpp` value arm).  `C0`'s initializer is
  `Base1 + 2*offset` — an OPERATION, not a constant — so a Rhs *clone* would
  have produced an operation.  Golden shows a constant: it is the VALUE arm,
  and the typespec it attaches is the **declaration's**, which is why the
  `int_typespec` at `105:20-105:32` (the `int unsigned` of the declaration) is
  LOCATED where earl65's High_conn twin carries none.
* **Golden itself**, on `a1_tree67.sv` — a 70-line minimisation of
  `prim_arbiter_tree`'s nested `gen_tree` / `gen_level` / `gen_nodes` — which
  reproduces the distance ladder cell for cell (`GRIDS_67.txt` §A):
  distance 0 keeps the ref, **distance 1 folds**, distances 2 and 3 keep it, a
  GENVAR at distance 1 keeps it, a MODULE localparam and a PACKAGE parameter in
  the very same index position keep it.

That ladder is *identical* to the one r10earl47 measured on prim_keccak five
passes ago.  So the law already existed in this codebase and had a helper:
`genLpUseFoldBound47`.  What earl47 wrote about itself is the whole diagnosis:

> "The SELECT BOUND restriction is this pass's, not golden's: the four bound
> positions are the whole Earlgrey_0_1 population of this shape and the other
> positions are ranked residues."

The bit-select INDEX is one of those other positions, and by pass 66 it had
become the biggest family on the ladder.

## 4. The law and the code

> **§ genLpBitSelIdxOneHopFold67** — CALL SITE **5 of 5** of
> § genLpUseFoldParentScope47.  A read of a gen-scope localparam whose
> declaring gen scope is the IMMEDIATE PARENT of the use site's emission scope
> path is replaced, **in the INDEX of a bit_select inside an ELABORATED
> gen-scope cont_assign (Lhs or Rhs), and outside any USER call's argument
> list**, by a use-site copy of that localparam's fold constant with its own
> declaration typespec.

Three files, +78 lines, no behaviour outside the gate:

* `include/UhdmExporter.h` — one new flag, `inGenScopeCa67`.
* `src/ModuleEmit.cpp` — an RAII guard raising it for the whole of an ELAB
  gen-scope cont_assign's expression emission (`emitBlock`'s cont_assign loop,
  so Lhs and Rhs alike; cleared on every exit from the iteration, `continue`
  included).  `inGenScopeCaRhs`, which already existed, covers only the Rhs and
  golden folds on **both** sides (arm cell `assign out[Pa] = sel;`).
* `src/ExprEmit.cpp` — the call site, in the plain `ElementSelect` arm, ahead
  of the index emission.

### The two fences, and how each was found

**(1) `inGenScopeCa67` — the ELAB port `High_conn` must NOT fold with a
typespec.**  Measured on `a1_tree67.sv` before the code: golden's
`.o(idx_tree[Pa])` High_conn index is `constant INT:0 sz 32 ct 7` **with no
typespec at all**, while the cont_assign twin two lines away carries the
located `int_typespec`.  That is § connIpsPkgParamBoundNoTs65's position x view
split, and `expr::Compare` **walks `Typespec()`** (generated `expr.cpp`), so an
un-gated call site would have MINTED A NEW HEAD where none existed.  The flag
is the fence; the 19 remaining ELAB High_conn cells stay on their pristine arm
and are ranked R3.

**(2) The USER-call-argument depth — found by building the gate WITHOUT it.**
`a2_types67.sv` cell

```systemverilog
assign c_arg = |{w[Ku], f2(w[Ku] ? w : ~w)};
```

scored the first patched binary **2 pristine-RIGHT -> patched-WRONG per view**:
golden keeps an unbound `ref_obj` at `Ku` inside the `f2(...)` argument list
while folding the identical `w[Ku]` one operand to its left.  This is the
r10v66 verifier's `§ connCallArgKeepsEnumRef66v` in a new dress, with the same
mechanism (`compileTfCallArguments` compiles each argument with `pexpr = call`;
the identifier arm under a non-null `pexpr` binds through `bindVariable` and
never reaches the `getValue` substitution).

`a3_calls67.sv` was then written to settle the *spelling* of that fence, and it
refutes a plain `callArgDepth == 0`: golden **folds** inside a SYSTEM call's
argument (`$signed({15'b0, w[Ku]})`) while keeping the ref in a bare user call
and in a call nested inside a call.  The test is therefore the USER-call depth,
`callArgDepth - sysCallArgDepth22`, which is the same split
§ genCaSysCallArgBinds22 / § genProcParamFoldQualCallArg20 already carry for
the sibling process fold at `ExprEmit.cpp` ~9570.

**The fence was hunted corpus-wide before the code too** (`fencescan67.sh`,
`predict67.py`): over **2,314 pristine databases** (1,358 u2r + 956 surelog)
only THREE carry a cell of the candidate shape —
`Earlgrey_0_1` (both modes), `rp32_r5p_mouse_soc_simple_top` (u2r, both modes,
1 cell) and `GenScopeHierPath3` (surelog/testflags, 21 cells).  The last two
are **CMP_EQUAL rows** and are the fence: both are byte-identical between the
two binaries after the pass (byteverify, and `ct8rows` 0 differing rows on
status AND dump), because the candidate cells there are module parameters and
genvars, which the one-hop path lookup and `genLpFoldByPath` refuse by
construction.

## 5. Arms (the grid), scored against golden

`a1_tree67.sv` — the head's own shape minimised: nested `gen_tree`/`gen_level`
for-generates with `localparam int unsigned Pa/C0/C1` from the genvars, read in
the `gen_nodes` generate-if branch, x distances 0/1/2/3 x positions (bit-select
index Rhs and Lhs, ips base, ips width, part-select bounds, concat,
replication, ternary predicate, operation operand, bare read) x contrast
symbols (genvar, module localparam, package parameter, a child instance's own
port parameter) x 2 levels x 1-2 offsets.
`a2_types67.sv` — declared type (int unsigned / int / logic[3:0] / bit[3:0] /
untyped / integer) x Rhs shape (genvar expression / literal / from another
localparam) x home (for-generate body, generate-if body) x 3 unrollings, plus
every NEIGHBOURING site the call site could reach by accident: port High_conn,
parameter override, param_assign Rhs, variable initializer, `always_comb`,
function body, call argument.
`a3_calls67.sv` — the call-argument fence at four spellings.

`score67.py` 3-way multiset join (golden / pristine / patched), payload reduced
to the fields the judge reads and **carrying no span**:

```
ARM a1_tree67   plain view  cells 323  STILL-RIGHT 278  TO-GOLDEN 15  AWAY 0  MOVED-WRONG 0
ARM a1_tree67   elab  view  cells 344  STILL-RIGHT 191  TO-GOLDEN 15  AWAY 0  MOVED-WRONG 0
ARM a2_types67  plain view  cells 189  STILL-RIGHT 156  TO-GOLDEN 28  AWAY 0  MOVED-WRONG 0
ARM a2_types67  elab  view  cells 189  STILL-RIGHT 141  TO-GOLDEN 28  AWAY 0  MOVED-WRONG 0
ARM a3_calls67  plain view  cells  82  STILL-RIGHT  64  TO-GOLDEN  6  AWAY 0  MOVED-WRONG 0
ARM a3_calls67  elab  view  cells  82  STILL-RIGHT  55  TO-GOLDEN  6  AWAY 0  MOVED-WRONG 0
```

**Zero AWAY-GOLDEN and zero MOVED-WRONG in every arm and every view.**  The
negative controls all held: distance 0, distance 2, distance 3, the genvar, the
module localparam, the package parameter, the port High_conn, the param_assign
Rhs, the variable initializer and the bare/nested call arguments are all
STILL-RIGHT or unchanged.

## 6. Gates (all run in this worktree, both binaries frozen at 555)

| gate | result |
|---|---|
| build both, md5 | `560a8eb9…` pristine / `ddf27fe5…` patched |
| `tests/check_goldens.sh` (SLANG_UHDM exported per binary) | **PASS 23 / FAIL 0** on BOTH binaries |
| negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** |
| u2r testflags / default, both binaries | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL |
| `ct8rows` u2r tf vs **committed** `results/gate_uhdm2rtlil.csv` | **PASS, 0 differing rows** |
| `ct8rows` u2r tf + def vs this pass's own pristine sweep | **PASS, 0 differing rows** |
| `byteverify SELFCHECK=1` u2r (1358 DBs) | **MOVERS 0 / 1358**, selfcheck 1357/1358 |
| surelog `--mode both` (1588 rows, 956 DBs) | status histogram **IDENTICAL** to pristine (470/466 CMP_EQUAL, 11/9 NE) |
| `ct8rows` surelog vs **committed** `results/golden_surelog.csv` | **PASS, 0 differing rows** (status AND dump) |
| `ct8rows` surelog vs this pass's own pristine sweep | **PASS, 0 differing rows** |
| `byteverify SELFCHECK=1` surelog (956 DBs) | **MOVERS 3 / 956** = `Earlgrey_0_1` default + testflags (the PREDICTED set) + `Scoreboard`/default, the documented ORDER COIN (order-blind diff **0 lines**, unsorted 94) |
| Earlgrey both modes | head **CLEARED**, 46 -> 32 lines, 1 head each, AFTER logs **byte-identical** |
| whole-design census, both modes | **1,995 TO-GOLDEN, 0 AWAY-GOLDEN, 0 MOVED-WRONG**, and those 1,995 are the ONLY cells that changed |
| golden-vs-golden calibration | 0 differing cells / 162,259; golden re-read byte-identical |
| corpus fence scan (2,314 pristine DBs) | 3 databases carry the shape; the 2 that are not Earlgrey are CMP_EQUAL and byte-identical after |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS / PASS |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected DBs by md5 | InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME** (both modes); SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| `rowheads.sh` | **only Earlgrey moved** (46 -> 32); SeqDriver/SimpleUVM/Scoreboard/MiniAmiq 17, BuildUVMPkg 29, Rggen 64 unchanged |
| WIDE boundary (2,997 `.sv`, PROCESSED == LISTED, both views, both binaries) | **16 differing** = this pass's 3 arms x 2 views + 5 earlier passes' arms x 2 views, all scored below |
| per-DIRECTORY boundary (1,387 dirs, both views) | **13 differing** = `r10earl67repro` + `r10earl47/56/58repro` x 2 views + the KNOWN order coin (§6b) |

`cmds.txt` audited by BINARY PATH in every arm (1458 u2r + 1523 surelog lines
per binary, every one `/tmp/r10earl67_p{ristine,atched}.bin`), `SLANG_UHDM`
exported explicitly per binary, `GOLDEN_DEFER` unset, `results/*.csv` never
written.  The 2 `rc=-11` rows in the surelog sweep are present on BOTH binaries
— pre-existing, not introduced.

### 6b. The boundary movers, scored not listed

Five earlier passes' arms move, and every one of them is a cell **this law
names** — a one-hop gen-scope localparam read as a bit-select index — so each
was rebuilt through Surelog and scored against golden:

```
r10earl58repro/a1_earl58.sv   plain/elab   TO-GOLDEN 10  AWAY 0  MOVED-WRONG 0
r10earl47repro/a2_earl47.sv   plain/elab   TO-GOLDEN  6  AWAY 0  MOVED-WRONG 0
r10earl56repro/a1_earl56.sv   plain/elab   TO-GOLDEN  1  AWAY 0  MOVED-WRONG 0
r10earl56repro/a2_earl56.sv   plain/elab   TO-GOLDEN  1  AWAY 0  MOVED-WRONG 0
r10earl56repro/a4_earl56.sv   plain/elab   TO-GOLDEN  1  AWAY 0  MOVED-WRONG 0
```

`a1_earl58` first scored **2 MOVED-WRONG**, and the label was a KEY ARTEFACT,
not a defect: the two cells live in an **UNNAMED** generate block, which our
emitter numbers `genblk2` and Surelog numbers `genblk7`, so the positional key
does not join and golden reads `<none>`.  Reading what golden holds at the
corresponding key shows `constant UINT:4 sz 32 int_typespec@13:16-13:28` — **the
exact object the patched binary now emits**.  Normalising the unnamed-block
index turns the arm into 10 TO-GOLDEN / 0 AWAY / 0 MOVED-WRONG.  That is
earl60's `attrv60.py` lesson for the third pass running, and the unnamed-block
NAMING difference is a pre-existing residue this pass neither creates nor
touches.

`r10uvm75repro`, `r10uvm76repro` and `r10uvm88repro` differ in the
per-directory arm and are the documented `vpiTaskFunc` list-order coin: the
patched-vs-pristine diff is **order-blind ZERO** on all five (dir, view) cells
while the unsorted diff is 6-25 lines.  The 20 `rc=139` signals the wide
boundary raises and the 10 the per-directory boundary raises appear on **both**
binaries, paired one-for-one — pre-existing.

## 7. Instruments (measurement only; the official `uhdm-cmp` is the judge)

* `tscen67.cpp` — whole-design expression census, direct `.uhdm` reader,
  positional route key; payload = the constant's four judge fields + typespec
  kind/name/**signedness**, and for a `ref_obj` its `Actual_group` kind, that
  actual's value/decompile/size and its **full name** (`afn=`, which is what
  makes the DISTANCE measurable).  Extends `r10earl66repro/tscen66.cpp`.
* `cen67.sh` — normalises the span FILE part so golden and ours join.
* `nospan67.sh` — strips `span=`/`tsspan=`/`afn=` from a census before scoring,
  so no judge-invisible field can hide a real flip inside STILL-WRONG.
* `sfam67.py` — the (golden kind, ours kind) pair census, and the ranked
  "golden folds / we do not" superfamily by (sec, site, position, symbol).
* `predict67.py` — predicts the movable cells from a PRISTINE census ALONE, by
  proving the one hop either from the ref's own `afn=` or, when we leave the
  ref UNBOUND (which is what Earlgrey's head does), from a `PA_<name>` row
  under the parent path.  It predicted 1,995 + 2 for Earlgrey/default before
  the patched binary existed; the 2 (`AddrW`) are module-level cont_assigns the
  heuristic over-counts and the real gate refuses three ways over.
* `fencescan67.sh` — the corpus-wide fence scan built on `predict67.py`.
* `score67.py` — 3-way multiset join, TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG /
  STILL-RIGHT / STILL-WRONG (from `r10earl66repro/score66.py`).
* `runarm67.sh` — one arm, Surelog + one binary in BOTH views.
* `earl67.sh` — one Earlgrey run, one binary, md5 printed, golden from cache.
* `vwide67.sh` / `vdir67.sh` — the recursive and per-directory boundaries; list
  on fd 3, children `</dev/null`, PROCESSED asserted.
* `armscore66.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`,
  `byteverify.sh`, `rowheads.sh` — the standard battery.
* `GRIDS_67.txt` — the full distance x position x type x call-spelling grid as
  measured on golden.
* `HEAD_R0_{BEFORE,AFTER}_{default,testflags}.cmp` — the four cmp logs.
