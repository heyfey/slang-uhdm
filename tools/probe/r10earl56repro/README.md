# r10earl56 — § genScopeOwnParamNoSelFold56

**Earlgrey_0_1/default's head OVER-FOLD cleared: the gen-scope cont-assign
select-bound parameter fold had no scope test at all, so it folded the USE
SITE'S OWN gen-scope localparam — the one hop § genLpUseFoldParentScope47
proves golden does NOT substitute. 254 objects to golden, 0 away, and the
new head was PREDICTED IN ADVANCE down to golden's own object id.**

Head: **46 cmp lines → 20**, 1 head → 1 head. (`cmp` LINE COUNT IS HEAD DEPTH,
never a distance.)

Corpus effect: **254 cells to golden, 0 away, 0 reshaped**, DEF view
byte-identical, and 36 grid cells across five arms moving the same way.

> **A REGRESSION WAS FOUND AND FIXED BEFORE LANDING, and the pass's own census
> did not see it.** The first build of this law fenced every gen-scope-declared
> parameter under `inPsBound`, including refs NESTED INSIDE a bound operation,
> and broke **107 pristine-right cells** at `prim_fifo_sync.sv:127:48`. The
> select-bound census reported `AWAY-GOLDEN = 0` for that build — it reads a
> slot's DIRECT child, which is `operation` on both sides. The WHOLE-DUMP mover
> reader (`dmov56.sh`) is what caught it, and it is now part of the harness.
> See "§ THE REGRESSION" below; the arm that witnesses it is `a5_earl56.sv`.

---

## THE HEAD (R0 of the pass, cleared)

```
LHS(golden): ref_obj (work@top_earlgrey.u_dm_top.i_dm_csrs.i_fifo
                      .gen_normal_fifo.PTRV_W)  id:291403  70:38-70:44
             < indexed_part_select(fifo_wptr) 70:35-70:44 < cont_assign
             < gen_scope(gen_normal_fifo) < module_inst(i_fifo)
RHS(ours)  : constant  id:235789  70:38-70:44  UINT:1 sz32
             ts -> ref_typespec{…gen_normal_fifo} -> int_typespec@55:16-55:28
```

`hw/ip/prim/rtl/prim_fifo_sync.sv`:

```systemverilog
end else begin : gen_normal_fifo
  localparam int unsigned PTRV_W    = $clog2(Depth) + ~|$clog2(Depth);   // 55
  ...
  assign wptr_value = fifo_wptr[0+:PTRV_W];                              // 70
  assign rptr_value = fifo_rptr[0+:PTRV_W];                              // 71
```

We hand back a constant where golden keeps the parameter REFERENCE. It is the
**direction-reversed** member of the family earl54 measured at 2 036 pristine
rungs (`constant>ref_obj`, golden folds / we keep): this pass's cells are
`ref_obj>constant`, golden keeps / we fold.

## THE LAW — AND THE DISCRIMINATOR THE BRIEF ASKED FOR

> **§ genScopeOwnParamNoSelFold56 — the ELAB gen-scope cont-assign
> select-bound parameter fold (`genCaLhsParamFold && inPsBound`) ABSTAINS when
> the reference IS THE BOUND ITSELF and the parameter's IMMEDIATE DECLARING
> SCOPE IS A GENERATE BLOCK. Gen-scope-declared parameters are
> § genLpUseFoldParentScope47's business and NOBODY ELSE'S.**

The question "where does golden fold a param ref in a select bound and where
does it keep the ref_obj" has **two independent answers, and both were
measured**:

**AXIS 1 — the DECLARING SCOPE (this is a scope test, NOT a distance test).**

| the parameter is declared… | golden | why |
|---|---|---|
| in the use site's OWN gen scope (**d0**) | **ref_obj** | ← THE HEAD |
| exactly ONE gen scope out (**d1**) | **constant** | § genLpUseFoldParentScope47, which folds it before this arm is reached |
| TWO or more gen scopes out (**d2+**) | **ref_obj** | earl47 measured it; we were folding it |
| in the enclosing MODULE (`parameter` or `localparam`) | **constant** | folds at ANY nesting depth — 2 name hops, 3, doesn't matter |
| in a PACKAGE | **constant** | same |
| a GENVAR | **ref_obj** | never in `genLpFoldByPath` |

A distance model cannot state this: a module parameter read two gen scopes deep
folds and a gen localparam read two gen scopes deep does not. **The scope CLASS
of the declaration is the discriminator**, and inside the gen-scope class the
distance rule is earl47's one-hop.

**AXIS 2 — DIRECT bound vs NESTED IN AN OPERATION.**

| the reference sits… | golden |
|---|---|
| AS the bound (`din[0 +: L1]`, `din[L1:1]`, `din[L1]`) | AXIS 1 decides |
| inside a bound OPERATION (`din[L1-1:0]`) | the reducer runs over the operation and its answer is INDEPENDENT of axis 1 — d1 `PTR_WIDTH-2` at prim_fifo_sync.sv:127:48 folds its operand to a `constant`, and a2's d0 `L1-1` folds the WHOLE operation |

So the law is fenced on the direct bound, and `parent` is the exact test: call
sites 3/4 hand `emitExpr` the SELECT for a direct bound and the `operation` for
a nested one.

### The grid, golden's answers (a1/a2, both ELAB copies, 5 positions)

| position | d0 typed | d0 untyped | d0 `parameter` kw | d1 | d2 | dM | dM untyped | module `parameter` | dP |
|---|---|---|---|---|---|---|---|---|---|
| ips WIDTH | **ref** | **ref** | **ref** | const | **ref** | const | const | const | const |
| ips BASE | **ref** | **ref** | — | const | — | const | — | — | — |
| part_select bare bound | **ref** | — | — | const | — | — | — | — | — |
| part_select OPERATION bound | const | const | — | const | — | const | const | const | const |
| bit_select INDEX | **ref** | **ref** | — | const | **ref** | const | — | — | — |

and the fences, each with a measured witness:

* **cont-assign only.** Every PROCEDURAL read at d0 (a2 `pc_ipsw`/`pc_ipsb`/
  `pc_bit` in `always_comb`, `pf_ipsw` in `always_ff`, a4's named-block `nb`)
  is already `ref_obj` on our side — a different arm, untouched.
* **a FOR-generate body is not special.** a2 `g4[0..1].f_*` at d0 are `ref_obj`
  in golden and were already `ref_obj` for us (`blkInLoop3` turns
  `genCaLhsParamFold` off there); `g4[i].fo_ipsw` at d1 folds on both sides.
* **the ELAB listing only.** The DEF (`uhdmallModules`) subtree of the Earlgrey
  dump is **byte-identical** between the two binaries — the earl38 fence.

### Positions the fence ALSO reaches, and golden agrees at every one

a3/a4 exist to find them, and each was a real over-fold we now fix:

* a select bound inside a **function-call argument** (`f56(din[0 +: L1])`) — d0,
  golden `ref_obj`.
* the **cont-assign LHS** select (`lhs_t[0 +: L1]`, `lhs_t[31:L1]`) — d0,
  golden `ref_obj` in both the width and the right bound.
* a d0 localparam with a **NON-LITERAL initializer** — the corpus's own
  `$clog2(Depth) + ~|$clog2(Depth)` shape (a4 `PW`) and one whose init reads a
  sibling localparam (`PW1 = PW + 1`). This mattered: the one-hop law needs the
  localparam REGISTERED in `genLpFoldByPath`, and a shape those two ModuleEmit
  sites skipped would have left the d1 cell with nobody to fold it. a4 measures
  that d1 with a non-literal init still folds on both sides.

## WHY EARL47 MEASURED THE LAW AND STILL LEFT THE HEAD STANDING

§ genLpUseFoldParentScope47 states "distance 0 — golden keeps a `ref_obj`" and
cites its own a1/b1 rows for it, so the d0 answer has been on record for nine
passes. It did not catch this head because **all five earl47 arms put their d0
cells inside a FOR-generate body** (`for (genvar x = 0; x < 3; x++) begin :
gen_x`), and `ModuleEmit` sets `genCaLhsParamFold = !blkInLoop3` — the fold is
already OFF in a loop body. The corpus head is in an **IF-generate**
(`gen_normal_fifo`), where the flag is on. Re-run three-way with this pass's two
binaries, earl47's grid does not move at all:

| earl47 arm | UNMOVED-GOOD | TO-GOLDEN | AWAY-GOLDEN | STILL-WRONG |
|---|---:|---:|---:|---:|
| a1_earl47 | 106 | 0 | **0** | 0 |
| a2_earl47 | 204 | 0 | **0** | 0 |
| a3_earl47 | 112 | 0 | **0** | 0 |
| b1_earl47 | 72 | 0 | **0** | 0 |
| v47v_prefixkinds (the F1 contract) | 48 | 0 | **0** | 0 |

which is the correct answer: the one-hop law's own grid has no direct-bound d0
or d2 cell OUTSIDE a loop body, so this pass has nothing to move there. a2's
6 / b1's 4 / v47v's 10 UNMOVED-BAD are pre-existing and identical in both
binaries.

## § THE REGRESSION — 107 CELLS, CAUGHT BY THE WHOLE-DUMP DIFF

`prim_fifo_sync.sv:127`, inside `gen_depth_gt1` (a gen scope NESTED in
`gen_normal_fifo`):

```systemverilog
assign storage_rdata = storage[fifo_rptr[PTR_WIDTH-2:0]];
```

`PTR_WIDTH` is `gen_normal_fifo`'s localparam — **d1** — and the reference is
inside the OPERATION `PTR_WIDTH-2` that is the left bound of a `part_select`
that is itself the INDEX of a `bit_select`. Golden's ELAB copy holds a **folded
constant** there (`UINT:2`, `vpiSize:32`, ts ref scoped by the select base
`…storage.fifo_rptr`, actual `int_typespec@56:16-56:28`) and the PRISTINE binary
matched it **field for field**. The un-fenced first build turned all 107 of them
into `ref_obj`s.

**Both of this pass's instruments called that build clean:**

| instrument | first (broken) build | fixed build |
|---|---|---|
| `census56.py` select-bound census, Earlgrey | agree 30 404, DISAGREE 2 101, **AWAY-GOLDEN 0** | agree 30 404, DISAGREE 2 101, AWAY-GOLDEN 0 |
| `dmov56.sh` whole-dump movers | **254 `ref_obj(PTRV_W)` + 107 `ref_obj(PTR_WIDTH)`** | **254 `ref_obj(PTRV_W)` and NOTHING ELSE** |

The census numbers are IDENTICAL across the two builds. That is the finding
worth carrying forward: **a slot-keyed census cannot see below the slot**, and a
pass that ships on one alone can ship a regression with a clean gate. `a5_earl56.sv`
now reproduces the shape in a 70-line arm (golden's `h1.h2.stor.ptr` left bound
at 38:27 is a `constant` in the instance-scoped copy and an `operation` in the
flat one — the corpus cell exactly), and its movers are only the three BARE
cells.

## THE PATCH

Two hunks: a 12-line predicate in `src/ExprEmit.cpp` beside
§ genLpUseFoldParentScope47's definition, its declaration in
`include/UhdmExporter.h`, and ONE condition added to the existing `if`:

```cpp
bool directBound56 =
    parent && (parent->UhdmType() == UHDM::uhdmpart_select ||
               parent->UhdmType() == UHDM::uhdmindexed_part_select);
if (genCaLhsParamFold && inPsBound &&
    nv.symbol.kind == SymbolKind::Parameter &&
    !(directBound56 && genScopeDeclaredParam56(nv.symbol))) {   // § …56
```

No new object is minted anywhere: the fence lets the ordinary ref path run, and
`ref_obj::Compare` then finds golden's fields already matched — the arms prove
it (a4's head ADVANCED off the `PW` ref_obj to an unrelated `int_typespec`
instead of getting shallower on a name/actual mismatch, which was the one named
risk in `PREDICT_R0.txt`).

## CENSUS: PREDICTED 254, MOVED 254

`census56.py` keys every `bit_select` / `part_select` / `indexed_part_select` /
`var_select` bound slot on **(view, the select's own VpiFullName, line:col,
slot, occurrence)** and reports the slot's kind.

> **TWO INSTRUMENT CORRECTIONS, both made before any number was believed.**
> (1) The span was first folded into the header regex as an optional trailing
> group; the non-greedy name group swallowed it and EVERY key came out `?:?`,
> which merged every select on the same signal into one occurrence chain and
> invented an a2 bit_select disagreement that does not exist. (2) The ELAB
> listing holds each gen-scope assign **TWICE** — an instance-scoped copy
> (`…u_s.din`) and a flat one (`…u_s.gen_norm.din`) — and keying on the LHS
> alone reported the SECOND copy's answer for the first, i.e. exactly the
> opposite of golden's. The occurrence index is part of the key.

**CALIBRATION FIRST, golden vs golden** (a detector that flags everything is a
broken detector): `census56.py g.dump g.dump` on a1 gives
**agree=153, DISAGREE=0, ONLY-GOLD=0, ONLY-OURS=0**.

Earlgrey_0_1/default, golden vs ours:

| | predicted | measured |
|---|---:|---:|
| TO-GOLDEN (pristine wrong → patched right) | **254** | **254** |
| AWAY-GOLDEN (pristine right → patched wrong) | 0 | **0** |
| STILL-WRONG | 0 | **0** |
| agree | 30 150 → 30 404 | 30 404 |
| DISAGREE | 2 355 → 2 101 | 2 101 |
| ONLY-GOLD / ONLY-OURS (pre-existing, unrelated) | unchanged | 1 198 / 1 275, **identical in both binaries** |

The 254 are `prim_fifo_sync.sv` 70:35 (127 cells) and 71:35 (127 cells) — every
elaborated `gen_normal_fifo` in the design, and **nothing else in the database
had the `G=ref_obj / O=constant` shape except the two residues below.**

### The arms, three-way (golden / pristine / patched)

`census56.py --attrib` joins two runs so the four outcomes a two-way diff
conflates are separated. **AWAY-GOLDEN is 0 on every arm** — that is the only
regression class, and this campaign has shipped a "gate clean" claim with 22 of
them before.

| arm | UNMOVED-GOOD | TO-GOLDEN | AWAY-GOLDEN | STILL-WRONG | UNMOVED-BAD |
|---|---:|---:|---:|---:|---:|
| a1 (the distance grid × 5 positions) | 142 | **8** | **0** | 0 | 3 |
| a2 (d2, for-generate, procedural, `parameter` kw) | 96 | **8** | **0** | 0 | 2 |
| a3 (call args, LHS selects, var_select) | 63 | **6** | **0** | 0 | 4 |
| a4 (non-literal inits, the regression hunt) | 72 | **8** | **0** | 0 | 6 |
| a5 (nested-in-operation bounds) | 93 | **6** | **0** | 0 | 0 |

36 cells to golden, and every one is a DIRECT select bound whose parameter its
own gen scope (or a gen scope two hops out) declares. `CENSUS_PREDICT56.txt`
predicted 8/8/6/8 for a1-a4 — **exact** — and was written before the patched
binary was RUN.

The `KEY-ONLY-ONE-SIDE` rows a3 (10) and a4 (2) report are golden-only DEF
cells with `pris=None pat=None`: present in golden's dump and in NEITHER of
ours, i.e. pre-existing missing objects, provably untouched.

### Whole-dump movers, per arm (`dmov56.sh`, workdir path normalised)

| arm | changed lines | ADDED objects | REMOVED objects |
|---|---:|---|---|
| a1 | 104 | 8 `ref_obj` (D0W ×4, D0U ×4) | 12 `constant`, 8 `int_typespec`, 4 `ref_typespec` |
| a2 | 104 | 8 `ref_obj` (P1, L1, L2) | 12 `constant`, 8 `int_typespec`, 4 `ref_typespec` |
| a3 | 76 | 6 `ref_obj` (L1) | 9 `constant`, 6 `int_typespec`, 3 `ref_typespec` |
| a4 | 104 | 8 `ref_obj` (PW, PW1) | 12 `constant`, 8 `int_typespec`, 4 `ref_typespec` |
| a5 | 78 | 6 `ref_obj` (K1) | 9 `constant`, 6 `int_typespec`, 3 `ref_typespec` |

> The normalisation is not cosmetic: the first run of this check reported ~280
> changed lines per arm and a hundred `module_inst` "movers", because **dump
> paths embed the workdir** and the two sides run in different directories. A
> fence check that cannot tell a path from a defect proves nothing (earl55's
> lesson, re-learned here on a different instrument).

## THE WHOLE-DESIGN BLAST RADIUS

Earlgrey_0_1/default, pristine 4 701 626 dump lines → patched 4 699 086:

```
changed-lines=4064  hunks=635
REMOVED (pristine-only)        ADDED (patched-only)
  508 int_typespec  LINE=55      127 ref_obj  NAME=PTRV_W  LINE=70
  254 constant      LINE=70      127 ref_obj  NAME=PTRV_W  LINE=71
  254 constant      LINE=71
  254 ref_typespec  (…gen_normal_fifo)
```

**Every removed object is at prim_fifo_sync.sv:55/70/71 and every added one is a
PTRV_W ref_obj.** No other file, no other identifier, no other line. That is the
same fact the census states as "TO-GOLDEN 254, AWAY 0" and gate 5 states as
"1 mover in N databases".

**DEF view**: the `uhdmallModules` subtree, 1 046 333 lines, md5
`aa8f3c3b52a3fbd00c0c7984fcf3ca85` on **BOTH** binaries. The earl38 fence holds.

## THE NEW HEAD WAS PREDICTED (`PREDICT_R0.txt`)

Written before the patched binary produced a single database, from
`lad_pris12.txt` — a 12-rung PRISTINE ladder (8.0 s). The pristine ladder's
FIRST TWO rungs are both this pass's shape (70:38 and 71:38 in the same gen
scope), so the new head had to be **rung 3**:

```
PREDICTED  L int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27 #985050
           R integer_typespec@:72:45-72:51 #235805
           KINDP=ref_typespec  FIELD=VpiType
MEASURED   L int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27 id:985050  UINT:2
           R integer_typespec@:72:45-72:51 id:235799
```

Golden's object id is **exact (985050)**, as are the kinds, the span, the parent
kind and the mechanism. Ours is `#235799`, not the predicted `#235805` — the
patched database renumbers, and `PREDICT_R0.txt` said so in advance (earl55's
lesson, applied). R0 of pass 57 is `assign depth = (full) ? DepthW'(Depth) : …`
at prim_fifo_sync.sv:72 — the 333-rung PRE-EXISTING `int_typespec >
integer_typespec` family LADDER54.md named, **not this pass's law**.

## RESIDUES (measured, named, NOT fixed)

* **R1 — the 2 `WordSelW` cells**, `flash_phy_core.sv:192:20` in
  `u_flash_eflash.gen_flash_banks[0|1].i_core.gen_prog_data`:
  `if (addr_i[0 +: WordSelW] == i)` inside an `always_comb`. `WordSelW` is a
  PACKAGE parameter (`flash_phy_pkg.sv:43`), so the fence's scope test
  correctly abstains — and the fold there comes from the PROCEDURAL arm, not
  this one. Golden `ref_obj`, ours `constant`. Pristine == patched.
* **R2 — the CALL-ARGUMENT over-fold with a MODULE localparam.**
  a3 `mc_arg` / a4 `marg` (`f56(din[0 +: MW])`): golden keeps `ref_obj(MW)`
  where the same module localparam in a plain cont-assign bound one line away
  FOLDS. That is a CONTEXT discriminator (the `!inPsBound` twin arm already
  carries `callArgDepth == 0`; this arm does not) and a separate law. Not taken:
  its corpus population is unmeasured and it would put the fold decision on a
  second axis in the same pass.
* **R3 — the 2 099 OPPOSITE-direction slots**, i.e. the family this pass's head
  is the reversed member of. The cleanest member is the **bit_select INDEX at
  d1**: golden folds, we keep the ref (a1 `n_bit`, a2 `d1_bit`, a4 `z1_bit`).
  § genLpUseFoldParentScope47 has FOUR call sites and none of them is a
  bit_select index; adding a fifth is a one-position extension of an existing
  law and is the obvious next pass. Deliberately not bundled here: it moves the
  fold in the OTHER direction, and mixing both directions in one pass makes an
  AWAY-GOLDEN unattributable.
* **R4 — an LHS-ips DEF-view SPAN residue** (a3/a4: golden's `mlhs`/`lhs_t`
  indexed_part_select starts at column 12, ours at 17). Pristine == patched.
* **R5 — the a5 `store.din` operation bounds** where golden's instance-scoped
  copy keeps an `operation` and its flat copy does too, while the `stor.ptr`
  twin folds. The reducer's own rule for a bound OPERATION is not modelled by
  this pass at all — axis 2 is stated, not implemented.

## FILES

| file | what it is |
|---|---|
| `census56.py` | the select-bound census, keyed on (view, select fullname, line:col, slot, occurrence); the two instrument corrections above are why the key looks like that; `--attrib` is the three-way join whose AWAY-GOLDEN column is the number that must be 0 |
| `dmov56.sh` | **the whole-dump mover reader** — names every object that appeared or vanished, by kind / identifier / source line, with the workdir path normalised. This is the instrument that caught the 107-cell regression the census was blind to |
| `grid56.py` | the per-assignment bound reader used to read the golden grid off a1/a2 before any code was written |
| `a1_earl56.sv` | the DISTANCE GRID: d0 / d1 / dM / dP × ips width, ips base, part_select left+right, bit_select index, bare read; typed and untyped; a module-scope control module |
| `a2_earl56.sv` | d2, nested gen scopes, for-generate bodies, procedural reads, a bare part_select bound, operation bounds, a gen-scope `parameter`, a genvar |
| `a3_earl56.sv` | the BOUNDARY: var_select with a trailing select (call sites 1-2, which never set `inPsBound`), the `!inPsBound` twin arm, call arguments, LHS selects, and the same shapes with a MODULE localparam |
| `a4_earl56.sv` | the REGRESSION HUNT: non-literal initializers (the corpus's own `$clog2` shape), d1 out of a loop body, earl47's F1 named-block gate |
| `a5_earl56.sv` | **the caught regression as an arm**: references NESTED IN A BOUND OPERATION at d0/d1/d2, including the corpus's array-in-inner-scope / pointer-in-outer-scope shape |
| `arm56.sh` `armplain56.sh` | arm drivers, `-elabuhdm`/`--elabuhdm` on both sides and with neither |
| `earl56.sh` | the Earlgrey_0_1/default driver (golden from the immutable cache) |
| `CENSUS_PREDICT56.txt` `PREDICT_R0.txt` | written before the patched binary was RUN |
| `sweeps56.sh` `ct8rows.sh` `byteverify56.sh` `canaries.sh` `canaudit.sh` `ctcan2.sh` `rowheads.sh` `varm.sh` `vbndall56.sh` `ladcmp56.py` | carried-forward harness |

## GATE RESULTS (all five, exact numbers)

| gate | measurement | result |
|---|---|---|
| 1 build | both binaries, `-j 2`, md5 separately | pristine **`529992d9344c01b481702613684a5779`**, patched **`465c8c1d4c2bfe251357d197b59c8c50`** |
| 2 goldens | `tests/check_goldens.sh` | patched **23 PASS / 0 FAIL**; pristine 23/0; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (the negative control) |
| 3 u2r | `ct8rows.sh`, **baseline FIRST** | testflags: baseline vs pristine **0** differing rows, baseline vs patched **0**, pristine vs patched **0**. default: pristine vs patched **0**. Status **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** unchanged in both modes and both binaries; dump histograms identical (testflags 496 match / 183 differ / 52 blank, default 492 / 187 / 52) |
| 4 surelog | both modes concatenated, **1588 rows** | baseline vs pristine **0 differing rows**, baseline vs patched **0**, pristine vs patched **0**. `PASS: every row byte-identical to the committed baseline` in all three |
| 5 byteverify | `byteverify56.sh` + both controls | u2r 1358 paths **0 movers**; surelog 953 paths **2 movers**, both named and attributed below. Controls: SELFCHECK 1357/1358 and 952/953 flagged; SELFCHECK1 = 1 (u2r) and 3 (surelog = 1 corrupted + the 2 real) |

Gate 3's mode note is unchanged from earl55: `results/gate_uhdm2rtlil.csv` is a
**testflags-only** baseline, so the default mode's gate is pristine-vs-patched
plus the status and dump histograms.

### GATE 5's TWO MOVERS, both attributed

```
MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  patched=2e03b1496f9a pristine=5d2a9c1182c5
MOVER ./default/Scoreboard-59431470/slang.uhdm    patched=dcc60a23b500 pristine=5f31ee5e4051
```

1. **Earlgrey_0_1/default is this pass's own mover** — 254 objects, enumerated
   above. Its pristine md5 `5d2a9c1182c5` is **byte-identical to r10earl55's
   landed patched database**, which is how this pass knows its base is the
   committed state and not a rebuild artefact. The patched database re-runs to
   the same md5 `2e03b1496f9a`, so the 20-line head is not a coin.
   `Earlgrey_0_1/testflags` is `SLANG_REJECT` and has no database, which is why
   the surelog mover count is 2 and not 3.

2. **Scoreboard is PRE-EXISTING EMITTER NONDETERMINISM, and it was PROVED, not
   assumed.** The dump diff is 92 lines in 2 hunks: the SAME 23
   `svunit_pkg::…` task/function objects, same content, moved as a BLOCK from
   one position in a `vpiTaskFunc` list to another — the documented
   SourceLocation-across-macro-buffers ordering flip. Re-running the exact
   command from `cmds.txt`:

   | binary | runs | `dcc60a23b500` | `5f31ee5e4051` |
   |---|---:|---:|---:|
   | patched | 13 | 11 | **2** |
   | pristine | 11 | 11 | 0 (but the SWEEP run produced it) |

   **The patched binary produces BOTH md5s on its own**, including the one the
   pristine sweep produced, so neither value belongs to a binary. The CSV row is
   `CMP_EQUAL` with an identical dump column in both sweeps (gate 4: 0 differing
   rows), so nothing about the row moved either.

**Canaries**: `canaries.sh` **52 rows OK / 0 changed / 0 absent** on the surelog
CSV and **8 / 0 / 0** on the u2r CSV; `ctcan2.sh` **58 / 0 / 0** (surelog,
`EXPECT_UNKNOWN=1`) and **1 / 0 / 0** (u2r, `EXPECT_UNKNOWN=6`), both `PASS`;
`canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0** with UnsignedParam,
HierPathEval, FileLocalParam and TopParam dispatched by no driver here. The two
DATABASE PINS hold byte-exactly on **BOTH** binaries and **BOTH** modes:
**SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`**. `InterfaceModPort`,
`BlackParrotComplex` and `YosysOldOr` are byte-identical between the binaries
(gate 5 names every mover and none of them appears).

### HEADS, measured via the official driver on the SWEEP databases

`rowheads.sh <workdir> <out> <names…>`, LHS always golden, heads counted with
`grep -c '^LHS:'` anchored at column 0:

```
pristine  Earlgrey_0_1 default   46 lines   1 head   cmp rc=255
patched   Earlgrey_0_1 default   20 lines   1 head   cmp rc=255
```

and on the same run every canary row reads `0 lines / 0 heads / rc=0` on BOTH
binaries: YosysVerx, SVSwitch, BlackParrotComplex, InterfaceModPort, YosysOldOr,
each in both modes. `Earlgrey_0_1/testflags` prints `SKIP-NOFILE` and is COUNTED.

### WIDE BOUNDARY (`vbndall56.sh`)

**913 arms × 2 views = 1826 runs, 1790 identical, DIFFERING = 10** — and all ten
are `a1`…`a5_earl56.sv`, this pass's own arms, in BOTH views. **Nothing else in
the entire probe corpus moved**: earl47's one-hop grid, earl49's operand walk,
earl50's nine positions, earl51's member-LHS cast, earl52's adjustSize and
earl54's conn-repl arms are all byte-identical between the binaries. Signals are
symmetric — `patched=6 pristine=6`, four arms (`r10buvm8repro/v21shadow8.sv`,
`r10uvm67repro/c3_iface.sv`, `r10uvm67repro/v3_boundary.sv`,
`r10uvm84repro/v84x8_break.sv`) crash rc=139 on BOTH binaries, pre-existing.
`no_output=26`, symmetric by construction.

### BOTH VIEWS, and AWAY-GOLDEN is 0 in both

`armplain56.sh` runs Surelog and us with NEITHER flag:

| arm | plain TO-GOLDEN | plain AWAY-GOLDEN | plain STILL-WRONG | (elab TO-GOLDEN) |
|---|---:|---:|---:|---:|
| a1 | **4** | **0** | 0 | 8 |
| a2 | **4** | **0** | 0 | 8 |
| a3 | **3** | **0** | 0 | 6 |
| a4 | **4** | **0** | 0 | 8 |
| a5 | **3** | **0** | 0 | 6 |

The plain counts are exactly HALF the elaborated ones because the plain listing
holds ONE copy of each gen-scope assign where the elaborated one holds two (the
instance-scoped copy and the flat one). The law fires in both views, which is
why the wide boundary sweep reports `plain` AND `elab` for all five arms.

## LADDER: ONE matched pair, and an INSTRUMENT GAP CLOSED (`LADDER56.md`)

Both runs `--max=20000 --budget=420`, back-to-back, joined by `ladcmp56.py` on
the GOLDEN SITE including its `#UhdmId`.

| | rungs | stop | secs | maxvis |
|---|---:|---|---:|---|
| pristine | 1 037 | BUDGET | 420.2 | 472 231 / 783 183 |
| patched | 871 | BUDGET | 420.3 | 471 486 / 783 183 |

```
CLEARED = 166   NEW = 0   KEPT = 839
   constant|VpiType|KIND:constant>ref_obj   100
   ref_obj|VpiType|KIND:ref_obj>constant     66
```

> **THE 100 IS NOT A FIX, and this pass wrote the guard that says so.**
> `ladcmp56.py` calls a pristine rung CLEARED when its golden site is absent from
> the patched ladder — which under a WALL-CLOCK budget conflates "fixed" with
> "never reached". `ladidx56.py` splits them by PRISTINE RUNG INDEX:
>
> ```
> COMPARISON HORIZON = pristine rung 937
> CLEARED   (index <= horizon)  =  66   ref_obj>constant   idx 1..500
> UNREACHED (index >  horizon)  = 100   constant>ref_obj   idx 938..1037
> ```
>
> All 100 sit at indices 938-1037, past the patched walk's horizon. Reporting
> them would have been claiming 100 fixes in the OPPOSITE-direction family this
> pass explicitly does not touch — and the census (−254 exactly, AWAY 0) and the
> whole-dump diff (254 added ref_objs and nothing else) both say they are
> untouched.

The 66 real ones are **every PTRV_W rung the pristine ladder carried**, two per
`gen_normal_fifo` instance over the 33 instances reached inside the horizon, and
`PTRV_W` rungs in the patched ladder = **0**. `LADDER56.md` predicted
"CLEARED >= 2, all PTRV_W, all at 70:38 / 71:38" and "a CLEARED rung anywhere
else would be a finding" **before either run started** — both halves held.
Controls: `constant>operation` pristine 3 / patched 3 and
`tlul_fifo_sync.sv:76:69-76:91` 0 / 0, exactly where earl54 left it; the
opposite-direction `constant@131:29 > ref_obj(PTR_WIDTH)` rung is still KEPT,
which is the fence's own witness.

**BUDGET HONESTY**: 420 s per side, not earl55's 1 500 s, and the machine was NOT
idle (other agents' compiles were running through both runs). Both sides got the
same wall clock and comparable depth, and the join is only read up to the
horizon — but this is a quarter-length ladder and it says so.

## THE PATCH REBUILDS TO THE SAME BINARY FROM A FRESH BASE

`git worktree add /tmp/wt_r10earl56_fresh b2b5fa7`, `git apply --check` clean,
`git apply`, configure, `cmake --build -j 2` → md5
**`465c8c1d4c2bfe251357d197b59c8c50`**, byte-identical to the binary every gate
above was run with. The deliverable is not "the patch that happens to be in my
worktree": it is the patch that reproduces the measured binary.
