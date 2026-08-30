# r10earl102 — § `elabRhsArrayTsSubBoundFolds102`

**An unpacked-array PARAMETER declared in a PACKAGE folds the `<param> - <literal>`
bound of its unpacked RANGE dimension on the array_typespec its `param_assign`
RHS OPERATION carries — the same fold its own `Ranges` already get — while a
MODULE's or an INTERFACE's own parameter keeps the symbolic `op11` on both.**
`Earlgrey_0_1` went from **58 (default) / 62 (testflags) cmp lines, 1 head** to
**34 / 34, 1 head** in both modes, byte-identical logs; the queued
`pinmux_pkg.sv:20` range-bound head is cleared. Two Earlgrey databases moved,
both predicted by name from pristine databases; nothing else in 2314 databases
moved a byte.

Everything in this directory is **MEASUREMENT ONLY**. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.

* BASE COMMIT `091da09`, branch `auto5h`. Worktree `/tmp/wt_r10earl102`
  (`git rev-parse HEAD` = `091da098a6f2b28cbe0a877192ba4a9ad55f11c8`).
* Pristine binary md5 `2eaa7a60ddb4894e841d4255ec147fa1` — **the same md5
  r10earl101 landed**, so the base is confirmed, not assumed.
  Patched binary md5 `6842c35d388cd6458aafc87ceefd6896`. Both frozen
  `chmod 555` at immutable paths before any sweep; every `cmds.txt` audited BY
  BINARY PATH (0 of 3035 name the main-tree binary).
* Production diff: `include/UhdmExporter.h` (+9, one flag), `src/ParamEmit.cpp`
  (+26, one call site) and `src/TypeEmit.cpp` (+17, one guard). Nothing else in
  `src/` or `include/` is touched. `slang` is NOT patched. `results/*.csv` were
  READ ONLY.

---

## 1. The head, and its OWNER, decoded before a line of law was written

`rowheads.sh` on this pass's own pristine build: `Earlgrey_0_1` **58 cmp lines
(default) / 62 (testflags), 1 head each** — re-measured, not carried forward,
and equal to `r10earl101repro/PREDICT_R0.txt`'s hand-off numbers.

```
pinmux_pkg.sv:18   parameter int NStraps  = 2;
pinmux_pkg.sv:20   parameter int MioStrapPos [0:NStraps-1] = '{1, 0};

LHS (golden)  constant   20:32-20:39   vpiDecompile:1 vpiSize:64 INT:1 vpiConstType:7
RHS (ours)    operation  20:32-20:41   vpiOpType:11
                 ref_obj  NStraps  (work@top_earlgrey.u_pinmux.NStraps)  20:32-20:39
                 constant 1        UINT:1 / 64 / ct 9                    20:40-20:41
both under the SAME parent range 20:29-20:42
```

`range::Compare`
(`~/git-repos/UHDM/build/generated/src/range.cpp:78-93`) reads **VpiSize, then
`Left_expr`, then `Right_expr`**, and the two sides' `Right_expr` are different
KINDS — so the head is the bound EXPRESSION itself, not a field of it. The
LEFT bound (`constant 0`) is equal on both sides, which is why the walk reaches
the right one at all.

### The owner (`own102`, the containment scan — `OWNER.r10earl102.txt`)

The head print names the object, not who holds it. `own102` walks the whole
arena for every object whose `Ranges()` vector CONTAINS the head's parent range,
and for every `range` whose `Left_expr`/`Right_expr` IS the head, and resolves
each. **One container on each side, and it is not the parameter:**

```
golden  range#595840  <- array_typespec#595839 20:13-20:42        containers=1
                      <- ref_typespec{work@top_earlgrey.u_pinmux}
                      <- operation 20:45-20:52        (the '{1, 0} pattern)
                      <- param_assign 20:17-20:52
                      <- module_inst work@top_earlgrey.u_pinmux
ours    range#462870  <- the IDENTICAL chain, object for object
```

So the owner is the **`param_assign`'s RHS OPERATION's own `array_typespec`** in
the ELABORATED instance — **not** the parameter's `Ranges` and **not** the
parameter's own `array_typespec`. Both of those are already exactly golden
(census §3), which is precisely why the head sat where it did.

---

## 2. THE LAW

> **§ elabRhsArrayTsSubBoundFolds102** — On the `array_typespec` that an
> unpacked-array parameter's `param_assign` **RHS OPERATION** carries in an
> ELABORATED module instance, a RANGE-form unpacked-dimension bound written
> `<parameter> - <literal>` is **FOLDED** to the value — `INT:<v>`,
> `vpiSize 64`, `vpiConstType 7`, anchored at the **LEFT OPERAND's** span —
> **when, and only when, the ARRAY PARAMETER ITSELF is declared in a PACKAGE.**
> A MODULE's or an INTERFACE's own parameter keeps the symbolic `op11` there,
> **even when the sizing identifier is itself a package parameter.**
>
> It reaches **the RANGE spelling only**. The SIZE spelling `[N]` on the very
> same object keeps `op11(<the sizing param's value at its own width>, 1)` in
> golden and is untouched. A BARE identifier bound `[0:N]` folds to a different
> constant shape (UINT at the parameter's width) and is left alone — a named
> residue, not this law.

Surelog's side of it: `CompileHelper::compileRanges`
(`src/DesignCompile/CompileExpression.cpp:3940`) reduces **both** bounds through
`reduceExpr` when `reduce == Reduce::Yes` and neither when it is `Reduce::No`;
`UHDM::ExprEval::reduceExpr`'s `vpiSubOp` arm
(`templates/ExprEval.cpp:3343`) mints exactly `INT:<v>` / size 64 /
`vpiIntConst`. A package is compiled once with its parameters valued, and the
materialized import copy in a module instance is a `clone_tree` of the
**elaborated** package's objects — the same § `PackageEval` /
`DefaultPatternInt` split this tree already encodes for the `[N]` spelling.
A module's own parameter is cloned out of a def view compiled with
`Reduce::No`, so its `op11` survives into every instance.

### 2.0 It is NOT one gate away from § `unpackedParamSel`

The brief asked whether this head is the same fold machinery reaching ranges.
It is not, and the answer was read out of the code before anything was written.
`unpackedParamSel` (`src/ModuleEmit.cpp:20852`) is a **continuous-assign RHS**
question: when an assignment's right side is an ELEMENT SELECT of an
unpacked-array parameter (`LP[0]`, `P[i][j]`), the elaborated view re-emits it
FOLDED to the element constant, so it must not share the def view's
`var_select` / `bit_select`. It is computed from `ae.right()`, it decides
object SHARING, and it never reaches a `range`. This head is a RANGE-SITE law
in `buildUnpackedRanges` / `emitParameters`, on the dimension of the declaration
rather than on a select of the array. The two families touch the same
declaration and nothing else; the u2r rows § `unpackedParamSel` converted are
part of this pass's must-not-move half and stay CMP_EQUAL (u2r 679/50/2 in
BOTH modes, `ct8rows` PASS on both, `byteverify` 0/1358).

### 2.1 STATED GATE == CODE GATE

| stated clause | code |
|---|---|
| only the RHS OPERATION's array_typespec | `rhsOpArrayTsSubFold102` is set and restored around the ONE `makeUnpackedArrayParamTs` call in `ParamEmit.cpp` that builds it |
| only when the array parameter is declared in a PACKAGE | `pkgOwnedArr102 = !inPackage && ps.getParentScope()->asSymbol().kind == SymbolKind::Package` |
| only the RANGE spelling | the flag is read inside `mkBound`, which the SIZE spelling `continue`s past before reaching |
| only `<param> - <literal>` | the guard sits on the `SubtractExpression` arm; the `IdentifierName` arm above it returns first and is unchanged |
| the folded shape | falls through to the shared fold at the end of `mkBound`, which already writes `INT:<v>` / 64 / ct 7 at `es.left->sourceRange()` |

Three files, 51 inserted lines, one deleted. The `§` is greppable and appears
in exactly three places: the flag's declaration (`include/UhdmExporter.h`), the
call site (`src/ParamEmit.cpp`) and the guard (`src/TypeEmit.cpp`).

---

## 3. THE GRID — and the reading it REFUTED

`grid102.sh` builds a Surelog golden for each arm in both views, runs both
frozen binaries, and joins a **compare-visible, depth-keyed, deduped** census of
every unpacked-dimension bound (`ct102cen` + `cen102.py`). Full table:
`GRID.r10earl102.txt`.

Six arms, both views, 4619-source wide boundary aside:

| arm | axis |
|---|---|
| `g1_form102` | bound FORMS on a package parameter: `N-1`, bare `N`, `N+1`, `$clog2`, `$bits(t)-1`, a literal, `NB-NA`, LEFT position, BOTH bounds, a nested select |
| `g2_home102` | HOMES: package-imported / module localparam / module parameter / OVERRIDDEN module parameter / gen scope / interface / **three instances of one span** |
| `g3_kind102` | DECLARATION KINDS: parameter, localparam, typed parameter, `'{default:}`, the SIZE spelling, a literal, **two dimensions** |
| `g4_neg102` | the MUST-NOT-MOVE half: `param_array_wildcard`'s own shape, a bare-ref bound, the SIZE spelling, array variables and nets |
| `g5_class102` | the CLASS home beside a package control |
| `g6_mix102` | **the distinguisher**: a MODULE's own array sized by an IMPORTED PACKAGE parameter |

**The first law written was WRONG and the grid convicted it.** Reading only the
FLIP list of `g2_home102` (an arm AGREEING is not an arm TESTING — RESUME §9), a
blanket "the RHS array_typespec always folds" was implemented and measured:
**TO-GOLDEN 3, AWAY-GOLDEN 9.** Golden holds `op11(ref_obj LN, UINT:1)` on
`LARR` / `MARR` / `OVARR` (module) and `op11(ref_obj IN, UINT:1)` on `IARR`
(interface) at that very site, in all three instances; the blanket law folded
all nine.

`g6_mix102` then separated the two surviving readings:

```
                                    golden, E view, rhsts>ats[0]R
SPKG          [0:SN-1]  package array,  package size  FOLDED  INT:2 / 64 / ct 7
MIX_PKGSIZE   [0:SN-1]  MODULE  array,  PACKAGE size  op11(UINT:3 @32, UINT:1)
MIXP_PKGSIZE  [0:SN-1]  MODULE  param,  PACKAGE size  op11(UINT:3 @32, UINT:1)
MIX_MODSIZE   [0:LOCN-1] MODULE array,  module  size  op11(ref_obj LOCN, UINT:1)
```

so the discriminator is **the array parameter's own home**, not the sizing
parameter's — and in every one of these four cells golden's RHS row is
**identical to its own E-view PARAM row**, which is the structural fact the law
states. The corrected law scores, over the whole grid, both views:

```
TO-GOLDEN 14   AWAY-GOLDEN 0   STILL-WRONG 0   MOVED-NO-GOLDEN 0
ADDED 0        REMOVED 0
```

`g4_neg102` moves NOTHING in either view (TO-GOLDEN 0 / AWAY 0): the
`param_array_wildcard` shape it reproduces verbatim has no RHS array_typespec at
all on either side, and its two pre-existing elab-view flips (golden binds the
def-view `DAM` bound ref's `Actual_group` to `IFN`, we leave it unbound) are
byte-identical before and after.

Two golden facts recorded as REFUTED readings, not dressed up:

* **"golden always folds the RHS typespec"** — refuted by `g3_kind102`'s
  `K_SIZE [KN]`, where golden holds `op11(UINT:2 @32, INT:1)` and **we already
  match it exactly**; the SIZE spelling never enters `mkBound`.
* **"the SIZING parameter's home decides"** — refuted by `g6_mix102` above.

---

## 4. THE MOVER PREDICTION (made from PRISTINE databases only)

`ct102cen` walks every scope root's parameters — the parameter's own `Ranges`,
the `array_typespec` its `Typespec()` names, and the `array_typespec` the
`param_assign` RHS carries — plus every `array_var` / `array_net` as the
must-not-move control half, and emits **both bounds of every range as their own
row**. The payload is compare-visible only (kind, size, constType, decompile,
value, opType, and a `ref_obj`'s `Actual_group`, which `ref_obj::Compare`
reads); the span goes on a separate `SPN` row and is never joined. A PACKAGE
appears TWICE in both producers (`AllPackages` and `TopPackages`) under one
`VpiFullName`, so the two are keyed apart as `PD` / `PE` — without that split
one silently overwrote the other and the join printed a false collision.

Run over BOTH corpora on the PRISTINE binary before a line of the law was
written (`CEN_u2r_pris.txt`, `CEN_sl_pris.txt`):

```
uhdm2rtlil   1358 databases.  WHOLE CENSUS  BOTH-SAME 932  FLIP 0
                              ONLY-GOLDEN 0  ONLY-OURS 0
             rhsts population: golden FOLDED / ours FOLDED  50
                               golden OP     / ours OP      22   <- must not move
             THE LAW'S CELLS (golden FOLDED / ours OP):  ZERO.
             The corpus has NO cell of this shape: nothing to fix, nothing to
             break — and the FLIP-0 whole census is the CALIBRATION of the
             instrument on 679 CMP_EQUAL databases.

surelog       956 databases.  WHOLE CENSUS  BOTH-SAME 4226  FLIP 18
                              ONLY-GOLDEN 16  ONLY-OURS 18
             rhsts population: golden FOLDED / ours FOLDED 236
                               golden OP     / ours OP     206   <- must not move
                               golden FOLDED / ours OP      18   <- THE LAW
             THE LAW'S CELLS: EIGHTEEN, all of them Earlgrey_0_1, NINE PER MODE,
             and all of them one declaration — pinmux_pkg.sv:20 MioStrapPos —
             in its nine elaborated instances:
                 work@top_earlgrey.u_pinmux
                 work@top_earlgrey.u_pinmux.gen_wkup_detect[0..7].i_pinmux_wkup
```

**PREDICTION: EXACTLY TWO DATABASES MOVE — `Earlgrey_0_1` default and
testflags. uhdm2rtlil: ZERO movers.** The 442 surelog + 72 u2r `rhsts` rows the
law must NOT touch are the must-not-move half, named by their counters above.

---

## 5. WHAT ACTUALLY MOVED

`byteverify.sh SELFCHECK=1`, patched vs this pass's OWN pristine sweep, both
binaries frozen at immutable paths:

```
uhdm2rtlil  MOVERS 0 / 1358      <- as predicted
                                 (SELFCHECK 1357/1358 flagged, PATH_SETS_IDENTICAL)
surelog     MOVERS 3 /  956      <- the two predicted Earlgrey databases,
    ./default/Earlgrey_0_1          plus Scoreboard/default, the KNOWN
    ./testflags/Earlgrey_0_1        svunit_pkg vpiTaskFunc order coin
    ./default/Scoreboard         (SELFCHECK 955/956 flagged, PATH_SETS_IDENTICAL)
```

`Scoreboard/default` attributed ORDER-BLIND: the two workdir-normalised dumps
sort to **0 differing lines** (94 lines differ unsorted) — the documented ~92-line
`vpiTaskFunc` list flip, not a law effect.

`Earlgrey_0_1` attributed line by line from the whole workdir-normalised dumps
(244 MB default, 360 MB testflags):

```
default    189 changed lines    testflags   207 changed lines
```

and **every one of them is one of the nine cells' own subtree**: the removed
`operation 20:32-20:41` with its `ref_obj NStraps` (and, in testflags only, that
ref's `|vpiActual:` line to the `NStraps` parameter at 18:17-18:24 — the whole
of the pristine 58-vs-62 split) against the added `constant 20:32-20:39
INT:1 / 64 / ct 7`. Nothing outside those nine subtrees differs in either dump.

### The census re-scored over the SAME fixed universe

`censcore102.py` asserts the GOLDEN side byte-identical between the two runs
before scoring anything (`GOLDEN-SIDE-IDENTICAL`), then joins golden × pristine ×
patched per database (`CEN_sl_score.txt`, `CEN_u2r_score.txt`):

```
surelog     TO-GOLDEN 18  AWAY-GOLDEN 0  STILL-WRONG 0  MOVED-NO-GOLDEN 0
                          ADDED 0  REMOVED 0
            census movers: default__Earlgrey_0_1 9, testflags__Earlgrey_0_1 9
            WHOLE CENSUS   BOTH-SAME 4226 -> 4244    FLIP 18 -> 0
                           ONLY-GOLDEN 16 -> 16      ONLY-OURS 18 -> 18
uhdm2rtlil  TO-GOLDEN 0   AWAY-GOLDEN 0  STILL-WRONG 0  MOVED-NO-GOLDEN 0
                          ADDED 0  REMOVED 0
            WHOLE CENSUS   BOTH-SAME 932 -> 932       FLIP 0 -> 0
```

**The entire measured population of unpacked-array-parameter dimension bounds is
now EXACTLY golden on both corpora**: 4244 + 932 rows agreeing, ZERO flips, and
the two one-sided sets unchanged to the row (they are pre-existing and named in
§7 R2/R3). Both one-sided sets are printed in `CEN_sl_pris.txt`.

---

## 6. GATES

| gate | result |
|---|---|
| build both, md5s | pristine `2eaa7a60ddb4894e841d4255ec147fa1`, patched `6842c35d388cd6458aafc87ceefd6896` |
| goldens, patched | **PASS 23 / FAIL 0** (`SLANG_UHDM` exported explicitly) |
| goldens, pristine | PASS 23 / FAIL 0 |
| goldens, negative control | `SLANG_UHDM=/bin/false` → PASS 0 / **FAIL 23** |
| u2r status, both modes | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, unchanged |
| `ct8rows` u2r tf vs committed baseline | PASS — every row byte-identical |
| `ct8rows` u2r tf / def vs this pass's own pristine | PASS, PASS |
| `byteverify SELFCHECK=1` u2r | MOVERS **0 / 1358** |
| surelog status | 471/10 + 466/9 CMP_EQUAL/CMP_NOTEQUAL, unchanged |
| `ct8rows` surelog vs committed baseline | PASS — **0 differing rows over 1588** |
| `ct8rows` surelog vs this pass's own pristine | PASS |
| `byteverify SELFCHECK=1` surelog | MOVERS 3 / 956 = the 2 predicted + the attributed coin |
| `rowheads.sh` | Earlgrey 58/62 → **34/34, one head, logs BYTE-IDENTICAL between modes**; SeqDriver 29, SimpleUVM 29, Scoreboard/default 145, MiniAmiq 106, BuildUVMPkg 321, Rggen 0 — every other row unchanged |
| `canaries.sh` | surelog ok=52 changed=0; u2r ok=8 changed=0 |
| `ctcan2.sh` | PASS (surelog, `EXPECT_UNKNOWN=1`) and PASS (u2r, `EXPECT_UNKNOWN=6`) |
| `canaudit.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| protected DB md5s | InterfaceModPort / BlackParrotComplex / YosysOldOr SAME in both modes; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** — all 12 pins SAME |
| `cmds.txt` audit | 1462 u2r + 1573 surelog per side; **0 name the main-tree binary**; the rest name the frozen pass binaries (the 4 + 50 unnamed are the SURELOG_FAIL / no-database rows) |
| GOLDEN_DEFER | UNSET throughout |
| `results/*.csv` | READ ONLY — no row converted, nothing edited |

### The wide boundary

`wide102.sh`: every `.sv` / `.v` under a COPY of `tools/probe` at any depth
(**4619 files**, the pass's six arms included), both views, both frozen
binaries, workdir-normalised `uhdm-dump` byte-compare, list on fd 3, children
`</dev/null`, `PROCESSED` asserted. `FENCED=` is EMPTY: the list was filtered
against the four brief-fenced test names before a single child ran and NONE of
the 4619 sources matched, so none was dispatched and none is spelled in any
artifact here.

```
PROCESSED=4619 identical=8856 DIFFERING=10 no_output=372     (PROCESSED == LISTED)

DIFFERING=10, and EVERY ONE is this pass's OWN arm:
   plain/elab  g1_form102   g2_home102   g3_kind102   g5_class102   g6_mix102

g4_neg102 -- the MUST-NOT-MOVE arm, which reproduces param_array_wildcard's own
shape verbatim -- is NOT in that list, in either view.  NO EARLIER-PASS ARM
MOVES AT ALL.

rc histogram, split BY SIDE, symmetric side for side:
   A rc=0 8493   rc=3 358   rc=4 373   rc=139 14
   B rc=0 8493   rc=3 358   rc=4 373   rc=139 14
```

The ten moving arms are also the gate's own POSITIVE CONTROL: a boundary that
reaches nothing prints green, and this one demonstrably sees the law.
Full artifacts: `BOUNDARY_WIDE.txt` / `.tally` / `.diff` / `.rc_histogram` /
`.rc_by_side` / `.signal`.

---

## 7. RESIDUES this pass MEASURED and deliberately did not take

**R0 — see `PREDICT_R0.txt`.**

**R1 — A MODULE's or INTERFACE's own unpacked-array parameter's `[0:N-1]` bound
is FOLDED BY US AND SYMBOLIC IN GOLDEN, on the parameter's own `Ranges` and
`array_typespec`, in BOTH views.** Measured on `g2_home102` (`LARR`, `MARR`,
`OVARR`, `IARR` — 26 flips per view after this pass) and `g6_mix102`
(`MIX_PKGSIZE`, `MIXP_PKGSIZE`, `MIX_MODSIZE` — 14 flips per view). Golden
substitutes a PACKAGE sizing parameter's value there (`op11(UINT:3 @32,
UINT:1)`) and holds a bound `ref_obj` for a module one. It is the exact mirror
of this pass's law and it is **corpus-null**: the surelog and u2r censuses show
ZERO such cells (the corpora's module-owned unpacked-array parameters all size
by a literal). Its own law, its own census. § `modUnpackedDimBareRef` covers
only the BARE-identifier spelling of it today.

**R2 — A PACKAGE DEF listing folds bounds golden keeps in their original syntax.**
`g1_form102`'s `PD` rows: golden holds `ref_obj NA` for `[0:NA]`, `op24` for
`[0:NA+1]`, a `sys_func_call` for `[0:$clog2(NB)]`, `op11(sys_func_call,1)` for
`[0:$bits(w_t)-1]`, `op11(ref,ref)` for `[0:NB-NA]` and a `bit_select` for
`[0:PARR[0]]`, and we fold every one. § `PackageEval` covers only the
`<ident> - <literal>` and bare-`<ident>` spellings. 16 flips per view, 0 corpus
cells. Untouched by this pass (its guard never fires in a package view).

**R3 — The ELABORATED-view fold ENCODING for the non-subtract forms.**
`g1_form102` `E`/`PE`: golden writes `UINT:<v>` at the sizing parameter's own
width for a bare reference (`sz 32`, ct 9) and `UINT` at 64 for `+`, `$clog2`
and a select, where we write `INT:<v>` / 64 / ct 7 throughout. Present
identically on both binaries (24 flips per view), 0 corpus cells. It is why
this pass's guard is restricted to `SubtractExpression`: folding the bare-`N`
arm as well would have moved a cell from one wrong shape to another
(MOVED-WRONG), which the arms measured before a line was written.

**R4 — The census's own two one-sided sets, unchanged by this pass.**
`ONLY-GOLDEN 16` = MiniAmiq's `svaunit_vpi_interface` associative / unsized
`array_net` dims (`STRING:associative`, `STRING:unsized`), which we do not emit;
`ONLY-OURS 18` = the `AES_PERMIT` / `SBOX_FWD` / `SBOX_INV` rows of an
EMPTY-NAMED elaborated `module_inst` in our testflags Earlgrey — a parenting /
naming residue of another family that the census keys on the owner's fullname.
Both are byte-identical before and after.

**R5 — `g4_neg102`'s two elab-view flips**: golden binds the DEF-view `DAM`
bound `ref_obj`'s `Actual_group` to the `IFN` parameter; we leave it unbound.
Present identically on both binaries in the `-elabuhdm` view only, 0 corpus
cells (the `param_array_wildcard` row is CMP_EQUAL and stays so). Its own law.

**R6 — the pre-existing probe/boundary segfaults.** Recorded by earl82 R6 …
earl101 R5; `byteverify` proves none of them is a mover. See
`BOUNDARY_WIDE.rc_histogram` / `.rc_by_side` for this pass's own symmetry check.

---

## 8. FILES

| file | what it is |
|---|---|
| `own102.cpp` | the OWNER finder: every `Ranges()` container of an object, every `range` it is a bound of, every `ref_typespec` that names it, each with its parent chain |
| `ct102cen.cpp` | the unpacked-dimension bound census (compare-visible payload, depth-keyed, `PD`/`PE` package split, `SPN` spans on separate rows, plus an arena-wide `TALLY`) |
| `cen102.py` | the two- and three-way multiset join for ONE database pair |
| `cenrun102.sh` | runs `ct102cen` over a whole `verify_golden` workdir, golden path read from each test's OWN `cmds.txt` |
| `censcore102.py` | the corpus scorer: asserts the golden side identical, then the population tally and TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / MOVED-NO-GOLDEN / ADDED / REMOVED |
| `grid102.sh` | the arm driver: Surelog golden + both binaries + census join per arm × view |
| `g1..g6_*102.sv` | the six arms (§3) |
| `wide102.sh` | the 4619-source wide boundary |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the gates, copied verbatim from their owning passes so `canaudit` can audit them here |
| `HEAD_BEFORE_*.cmp`, `HEAD_AFTER_*.cmp` | the official `uhdm-cmp` head logs, both modes |
| `OWNER.r10earl102.txt` | `own102` on the old head (both sides) and on the new one |
| `GRID.r10earl102.txt` | the arm table on both binaries + the three-way score |
| `CEN_{sl,u2r}_pris.txt` | the PREDICTION (pristine only) |
| `CEN_{sl,u2r}_score.txt` | the three-way corpus score |
| `BOUNDARY_WIDE.*` | the wide boundary's tally, diff list, rc histogram and per-side rc |
| `PREDICT_R0.txt` | the prediction and the NEXT HEAD |
