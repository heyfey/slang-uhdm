# r10rgg13 — § genLpPaCallArgCopy13: the ARGUMENT of a MULTIDIMENSIONAL parameter's `param_assign` call is a COPY of the read parameter's own declaration constant

**MEASUREMENT-ONLY directory.**  The official `uhdm-cmp` remains the sole
acceptance judge.  **BASE `49634d2`.**  `results/*.csv` was READ ONLY and is
untouched.  **Rggen still does NOT pass `uhdm-cmp`, and NO CORPUS ROW WAS
CONVERTED** — this pass says so up front.

Target: `default:Rggen`'s official head after r10rgg12 (64 cmp lines, 1 head) —
the argument constant of the `param_assign` Rhs `func_call` at
`rggen-sv-rtl/rggen_or_reducer.sv:62:62-62:63` (the `N` in
`localparam bit [N-1:0][15:0] SUB_N_LIST = get_sub_n_list(N);`), in the instance
`work@rggen.u_block_0.g_register_6.…u_read_data_mux.g.u_reducer` (`N` overridden
to `2`):

```
golden : constant  INT:2   vpiSize 32  vpiConstType 7   vpiDecompile 2
ours   : constant  UINT:2  vpiSize 32  vpiConstType 9   vpiDecompile 2
```

**RESULT.  THE HEAD IS CLEARED.**

* `rowheads.sh` (official `uhdm-cmp`, Rggen default): **64 → 36 cmp lines**, and
  the head object moves to a **DIFFERENT FAMILY** (§ 9, R0).  A cmp line count is
  the head OBJECT's decompile size, so that number is **not** a progress metric
  and is not reported as one.  The arbiters are the whole-dump diff and the
  census below.
* **The whole-dump path-normalised diff of Rggen, base vs patched, is 22 removed
  / 22 added lines over 1,580,844 dump lines a side — the ELEVEN head constants'
  `VpiValue` and `VpiConstType`, and nothing else**
  (`DUMPDIFF_rggen_base_vs_pat.txt`).
* Call-argument census over the WHOLE Rggen database (42,307 keys, both views +
  the package view): **FIXED 22, BROKEN 0, MOVED-STILL-WRONG 0** on the
  Compare-visible fields; 868 → 846 differing keys.
* **The positive-control cell `cells/pc1` goes from 64 cmp lines / 1 head to
  0 cmp lines / 0 heads — it PASSES the official `uhdm-cmp` outright.**
* Corpus: **0 movers over 1358 uhdm2rtlil databases**; **2 movers over 956
  surelog databases — `default/Rggen` (the target, predicted) and
  `default/Scoreboard`, which is THE DOCUMENTED COIN and is PROVED so**
  (`COIN_scoreboard.txt`).
* **0 differing ROWS** in either corpus, either mode, status AND dump column,
  against the committed baselines AND against my own base sweeps.

---

## 1. THE HEAD, decoded from the PRISTINE cmp LOG

`HEAD_R0_BEFORE_default_Rggen.cmp`, verbatim (LHS is ALWAYS golden):

```
LHS: constant, id:60462, line:62:62, endln:62:63
     |vpiParent: \_param_assign: id:60457, 3:17-3:26         <- N's OWN param_assign
     |vpiDecompile:2  |vpiSize:32  |INT:2
     |vpiTypespec: \_ref_typespec: (work@rggen.….u_reducer), id:60463
                     |vpiActual: \_int_typespec: id:60464, 3:13-3:16   <- N's own `int`
     |vpiConstType:7
RHS: constant, id:43160, line:62:62, endln:62:63
     |vpiParent: \_func_call: (get_sub_n_list), id:43158, 62:47-62:61
     |vpiDecompile:2  |vpiSize:32  |UINT:2
     |vpiTypespec: \_ref_typespec: (work@rggen.….u_reducer), id:43161
                     |vpiActual: \_int_typespec: id:10096, 8:55-8:58    <- the FORMAL's `int`
     |vpiConstType:9
```

**THE FAILING FIELD IS `VpiConstType` (7 vs 9), AND NOTHING ELSE.**  Read the
order off the generated code, not off the dump:
`constant::Compare` (`UHDM/build/generated/src/constant.cpp:58-71`) calls
`expr::Compare` FIRST (`expr.cpp:83-102`), which reads **`VpiDecompile`**
(`2` == `2`), **`VpiSize`** (32 == 32), then `SafeCompare(Typespec())`, and only
then does `constant::Compare` read **`VpiConstType`**.
`ref_typespec::Compare` reads `VpiName` (both are the instance fullname, equal),
`VpiDefName` (both empty) and `Actual_typespec`; both actuals are `int_typespec`
and `int_typespec::Compare` reads `Cast_to_expr`, `VpiSigned` and `Ranges` —
so **the two DIFFERENT typespec objects compare EQUAL**, which is why `uhdm-cmp`
reported the failure ON THE CONSTANTS and not on the typespecs.
**`VpiValue` is never read by any generated `Compare`; `VpiParent` never is
either.**  The pass is therefore decided by `VpiConstType`, and the two
Compare-invisible columns are used here only as census WITNESSES.

## 2. THE LAW

> **§ genLpPaCallArgCopy13.**  In a **MULTIDIMENSIONAL** parameter's elaborated
> `param_assign` Rhs, a call ARGUMENT that is a bare parameter name is a
> **COPY OF THAT PARAMETER'S OWN `param_assign` Rhs CONSTANT** — `VpiValue`,
> `VpiSize`, `VpiConstType` and `VpiDecompile` carried over verbatim, re-spanned
> at the identifier — **not** a fresh constant minted from the parameter's value.
>
> **SURELOG'S MECHANISM** (`CompileExpression.cpp:2856-2910`, the netlist arm;
> `2916-2975` is the component twin).  The identifier branch does, in order:
> ```
> if ((reduce == Reduce::Yes) && instance) sval = instance->getValue(name);
> if (sval == nullptr || !sval->isValid()) {                    // THE CLONE ARM
>    for (param_assign* param_ass : *inst->getNetlist()->param_assigns())
>      if (name matches &&
>          ((reduce == Reduce::Yes) ||
>           (param_ass->Rhs() && param_ass->Rhs()->UhdmType() == uhdmconstant)))
>        if (substituteAssignedValue(param_ass->Rhs(), compileDesign)) {
>          result = UHDM::clone_tree(param_ass->Rhs(), &elaboratorContext);
>          result->VpiParent(param_ass);
>          fC->populateCoreMembers(child, child, result);
> } else {                                                      // THE VALUE ARM
>    c->VpiValue(sval->uhdmValue());   c->VpiDecompile(sval->decompiledValue());
>    c->VpiConstType(sval->vpiValType()); c->VpiSize(sval->getSize()); }
> ```
> A multidimensional parameter's initializer is compiled with **`Reduce::No`**
> (`CompileHelper::isMultidimensional` gates the reduce — the fact
> `elabMdimParamInit` already models), `sval` is never fetched, and the CLONE ARM
> runs.  With `Reduce::Yes` the VALUE ARM runs instead.  **THAT IS THE WHOLE
> AXIS**, and § 3's grids and § 7's fence are what establish it.
>
> **THE VALUE ARM CANNOT BE THE SOURCE WHERE THE LAW FIRES.**
> `LValue::uhdmValue()` has no `HEX:` case at all (`Value.cpp:880-921` —
> Hexadecimal falls into the `INT:` default) and `LValue::vpiValType()` maps
> Hexadecimal to `vpiIntConst`, so it could never produce grid A's golden
> `HEX:03 sz 32 ct 5` for `#(.P(8'h03))` nor `BIN:0101 sz 4 ct 3` for
> `#(.P(4'b0101))`.  The declaration constant can and does.
>
> **THE HOME IS AN AXIS HERE, unlike r10rgg11's port actual.**  Golden does NOT
> substitute in a **gen-scope-homed** or **package-homed** `param_assign` — it
> keeps a bare `ref(P)` — because the substitution reads that scope's OWN
> netlist `param_assign`s.  Measured on grid B: `genif__*`, `genfor__*` and
> `pkg__*` keep `ref(P)` in golden in all twelve cells.
>
> **THE TYPESPEC IS DELIBERATELY NOT MOVED** (§ 4, clause 2 and § 7).

## 3. THE GRIDS

`gen_grid13.py` builds all three; `run_grid13.sh` builds BOTH databases per cell
and censuses them with `acensus13`; `score13.py` classifies every census row.

### Grid A — 24 cells: 6 ARGUMENT SHAPES × 4 FORMAL TYPES, each × 6 OVERRIDE shapes

`mid` declares `localparam bit [P-1:0][15:0] LP = flp(<ARG>);` and is
instantiated six times: `#(.P(2))`, `#(.P(8'h03))`, `#(.P(4'b0101))`,
`#(.P(1+3))`, `#(.P(TOPP))` and un-overridden (declaration default `8'h07`).

Golden's ELAB argument, read off `GOLDEN_SHAPES_gridA.txt`:

| argument written | golden's argument object |
|---|---|
| `P` (bare parameter) | **the COPY**: P's own Rhs field for field, `/P:param_assign@3:17`, typespec `int_typespec@3:13` — **in all four formal types**, `int` / `bit [7:0]` / `logic [P-1:0]` / bare-implicit |
| `Q` (bare **localparam**) | the same COPY, of `Q`'s own `param_assign` (`/P:param_assign@8:18`) |
| `P+1` | `op24[ <the COPY>, UINT:1 ]` — the bare name INSIDE the operation is substituted too (we keep `ref(P)`; § 9 R-C) |
| `3` (literal) | `UINT:3 sz 64`, **no typespec at all** (we stamp the formal's and re-size; § 9 R-C) |
| `ARRP[1]` (select) | `bitsel(ARRP)` unsubstituted — **ours agrees** |
| `fnest(P)` (nested call) | `fcall:fnest(ref(P))` — the depth-2 bare name is NOT substituted; **ours agrees** |

The override encoding is carried verbatim: `4'b0101` → `BIN:0101 sz 4 ct 3`,
`8'h03` → `HEX:03 sz 32 ct 5`, `1+3` → `UINT:4 sz 32 ct 9`.

### Grid B — 12 cells: 4 HOMES (module / gen-if / gen-for / package) × 3 localparam types

`p2dp` (`bit [P-1:0][15:0]`), `p2dfix` (`bit [1:0][15:0]`, no P dependency) and
`int` (the control golden FOLDS whole).  `mod__p2dp` and `mod__p2dfix` take the
copy — so the axis is **multidimensionality, not P-dependence** — and every
`genif` / `genfor` / `pkg` cell keeps a bare `ref(P)` in golden.

### Grid C — 3 cells: the DECLARATION DEFAULT (`1` / `8'h07` / `2+5`)

The un-overridden instance copies its declaration default with that default's own
encoding.

### Scores of the patch (all census rows of all grids, `SCORE_grid{A,B,C}.txt`)

| grid | rows | OK | **FIXED** | **BROKEN** | STILL | MOVED-STILL-WRONG |
|---|---|---|---|---|---|---|
| A, Compare-visible | 3964 | 3789 | **6** | **0** | 169 | **0** |
| B, Compare-visible | 548 | 426 | **12** | **0** | 110 | **0** |
| C, Compare-visible | 492 | 478 | **14** | **0** | 0 | **0** |
| A/B/C, ALL printed columns | 5004 | 4505 | 16 | **0** | 467 | 16 |

**BROKEN is zero on every grid and on every censused row family, not only on the
ARG rows.**  The two lines count the SAME 32 moved objects: with all columns they
split 16 FIXED (the enclosing `PA` rows, whose whole printed value became golden's)
and 16 `MOVED-STILL-WRONG` (the same constants seen through the `ARG` key, where
the only remaining difference is the two columns no `Compare` reads — `vpiParent`
and the typespec's file/line); with `--cmpvis` all 32 are FIXED.
`score13.py --cmpvis` is the mode every uhdm-cmp claim in this write-up is made
in, and the head clearing is its independent confirmation.

## 4. THE FIX

**One edit in `src/ExprEmit.cpp` (one `else if` branch of 4 assignments plus two
helper functions) and two declarations in `include/UhdmExporter.h`.  No other
file.**  In the `elabParamArgFold` arm (ExprEmit ~14290), between the existing
multidimensional-argument branch and the existing UINT fold:

```cpp
else if (auto* sc13 = elabMdimParamInit && argIntFormal13(arg)
                          ? paCallArgCopySrc13(psy9, sub, argIdx) : nullptr) {
    c9->VpiValue(std::string(sc13->VpiValue()));
    c9->VpiSize(sc13->VpiSize());
    c9->VpiConstType(sc13->VpiConstType());
    c9->VpiDecompile(std::string(sc13->VpiDecompile()));
}
```

THE GATE, four clauses, **each named by a corpus row that would otherwise move**:

1. **`elabMdimParamInit`** — Reduce::No, § 2.  THE FENCE IS
   **`uhdm2rtlil/func_upto`, CMP_EQUAL in both modes, 1024 rows of this exact
   shape**: `localparam [HI:LO] C_CONST = F(A_CONST, B_CONST)` is SINGLE
   dimension, its call still survives, and golden's actuals there are VALUE-arm
   constants wearing the FORMAL's `logic_typespec` — byte for byte what we
   already emit.  `uhdm2rtlil/const_func_block_var` is the second such row.
2. **the formal is a predefined INTEGER type** (`argIntFormal13`).  THE POSITION
   RESTRICTION IS OURS.  Golden's copy also carries a typespec and **which one is
   not uniform**: Rggen's wears the PARAMETER's `int_typespec` (3:13),
   `Surelog/FuncInModule`'s wears the FORMAL's (10:55).  Both are `int_typespec`,
   so `typespec::Compare` cannot tell them apart — but for a NON-integer formal
   they are different KINDS (grid A: golden `int_typespec`, ours `bit_typespec` /
   `logic_typespec`), the value copy alone cannot make such a row right, and
   retargeting the typespec is exactly what clause 1's fence forbids (`func_upto`
   would go from `logic_typespec` to `int_typespec` on 1024 CMP_EQUAL rows).
   `int` is the only formal type this corpus holds at this position.
3. **the parameter has an ELABORATED `param_assign` in THIS instance whose Rhs IS
   a constant** — the literal text of Surelog's own guard.  `elabParamPa` models
   `inst->getNetlist()->param_assigns()` and holds module-instance parameters
   only, so grid B's gen-scope and package homes cannot enter the arm.
4. **the formal is not BARE-IMPLICIT** — § elabCallFormal's window
   (`ParamEmit.cpp` ~13342) re-binds the PARAMETER'S OWN Rhs to such a formal and
   re-runs `adjustSize` on it, so copying that Rhs would carry a value this
   exporter rewrote for a different law (grid A's `funtyp__*`: our `P` is
   `HEX:07 sz 1` where golden's is `HEX:07 sz 32`).

The multidimensional-argument branch (r10rgg2/5's `satArrArgFirstElem5` and the
BIN-vector hand-over) is **untouched**: the new branch is an `else if` after it,
so a multidimensional ARGUMENT never reaches the copy.  Rggen's own
`get_next_n(SUB_N_LIST)` and `get_offset_list(SUB_N_LIST)` are exactly that case
and are byte-identical before and after.

## 5. GATES

| gate | result |
|---|---|
| build both, md5 separately (after `Built target`) | base `cddfb450fab71ea1d2820f0f2366ad7f`, patched `02e1ee388232ba895cb220d77873e879` |
| goldens, base | 23 PASS / 0 FAIL |
| goldens, patched | **23 PASS / 0 FAIL** |
| goldens, `SLANG_UHDM=/bin/false` (negative control) | **0 PASS / 23 FAIL** |
| uhdm2rtlil, base, both modes | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL per mode; the testflags slice **byte-identical to the committed `results/gate_uhdm2rtlil.csv`, 0 differing ROWS** |
| uhdm2rtlil, patched, both modes | **0 differing ROWS** vs the committed baseline AND vs my own base, status AND dump column |
| uhdm2rtlil byteverify, `SELFCHECK=1` | selfcheck 0 movers; **base vs patched 0 MOVERS over 1358**, 0 only-in-A, 0 only-in-B |
| surelog, base, both modes | **byte-identical to the committed `results/golden_surelog.csv`, 0 differing ROWS over 1588** (470/11/5/283/25 default; 466/9/5/3/1/284/23/1/2 testflags) |
| surelog, patched, both modes | **0 differing ROWS** vs the committed baseline AND vs my own base |
| surelog byteverify, `SELFCHECK=1` | selfcheck 0 movers over 956; **base vs patched 2 MOVERS — `default/Rggen` (the target) and `default/Scoreboard` (THE COIN, proved in `COIN_scoreboard.txt`)** |
| canaries.sh (surelog / u2r) | ok=52 changed=0 absent=0 / ok=16 changed=0 absent=0 |
| ctcan2.sh (surelog, `EXPECT_UNKNOWN=1`) | ok=58 changed=0, unknown-patterns=1 = the documented u2r-only `2DFunctionArg` |
| canaudit.sh | audited=29 **UNCOVERED=0 FENCE-BREACH=0**, both self-tests live |
| byte pins | `SVSwitch` / `YosysVerx` / `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` — all covered by the 0-mover u2r byteverify, the 2-named-mover surelog byteverify and the canary battery |

Every `cmds.txt` of every workdir used above was audited by BINARY PATH
(`/tmp/r10rgg13_bin/slang-uhdm-{base,pat}`), not by the string `slang-uhdm`.

Named-row heads, base → patched (each 1 head; `Scoreboard/testflags` and
`Rggen/testflags` are SKIP-NOFILE and COUNTED — non-CMP rows with no slang
database):

| row | mode | base | patched |
|---|---|---|---|
| SeqDriver | default / testflags | 164 / 164 | 164 / 164 |
| SimpleUVM | default / testflags | 164 / 164 | 164 / 164 |
| Scoreboard | default | 164 | 164 |
| MiniAmiq | default / testflags | 164 / 164 | 164 / 164 |
| BuildUVMPkg | default / testflags | 84 / 84 | 84 / 84 |
| Earlgrey_0_1 | default / testflags | 64 / 64 | 64 / 64 |
| **Rggen** | **default** | **64** | **36 (NEW FAMILY, § 9 R0)** |

## 6. THE PREDICTION, filed BEFORE the patched sweeps were read

`predictdb13.sh` runs the call-argument census on both sides of every PRISTINE
BASE workdir and prints every ELAB `param_assign`-Rhs call argument that is, on
OUR side, a CONSTANT parented at the `func_call` — i.e. every row where the fold
this pass replaces actually fired, whether or not it disagrees with golden.  That
predicate is an OVER-INCLUSIVE superset (it does not test that the written actual
was a bare name, nor Reduce::No, nor the formal's type).

```
uhdm2rtlil : dirs-scanned=1358 SKIP-NOFILE=104 FENCED-SKIP=0 PREDICTED-ROWS=2050
             over exactly FOUR test-modes: {default,testflags}/func_upto (1024
             rows each) and {default,testflags}/const_func_block_var (1 each).
             TIGHT SUBSET (golden's copy marker `/P:param_assign@` present):  0
surelog    : dirs-scanned=948  SKIP-NOFILE=617 FENCED-SKIP=8 PREDICTED-ROWS=30
             over exactly TWO tests: default/Rggen (26) and FuncInModule (2/mode).
             TIGHT SUBSET: 15 — Rggen's 13 `get_sub_n_list` arguments and
             FuncInModule's one per mode.
```

**POSITIVE CONTROL** (`PREDICT_db_POSITIVE_CONTROL.txt`): the same driver over a
one-test Rggen workdir finds those 26 rows — a predictor that reaches nothing must
never read as a clean prediction.

**THE PREDICTION AND THE OUTCOME.**  u2r's four test-modes are all single-
dimension (`func_upto`'s `[HI:LO]`, `const_func_block_var`'s `integer`), gate
clause 1 excludes them, and the sweep produced **0 movers over 1358** — the tight
prediction exactly.  On surelog the tight set named `Rggen` and `FuncInModule`;
`Rggen` moved and **`FuncInModule` did not, because there the copy and the mint
agree field for field** (`N`'s Rhs is `UINT:4 sz 32 ct 9` and so is the fold of
`N`'s value), so the law fires and writes the same bytes — visible in the census
(`FuncInModule`'s golden argument already carries the copy marker while every
Compare-visible field already matched).  No other database in either corpus moved.

## 7. BOUNDARY

`boundary13.sh` compiles EVERY source arm — subdirectories included — of the 48
precedent repro directories this law can reach (`r10rgg1…12`, `r10vrgg2…11`,
`r10rggen6…9`, `r10earl40…62`) with BOTH binaries and compares byte-wise:

```
-- files=1279 identical=1180 MOVERS=0 uncompilable=99 asymmetries=0
```

**ZERO precedent arms move.**  The 99 uncompilable files are the same multi-file
arms r10rgg9…12 recorded, each printed and COUNTED.

**POSITIVE CONTROL** — the same driver over this pass's own five cells:

```
MOVER  tools/probe/r10rgg13repro/cells/pc1/top.sv
-- files=5 identical=4 MOVERS=1 uncompilable=0 asymmetries=0
```

so the comparator provably sees THIS pass's difference, and the four cells that
must NOT move do not.  `scorearms13.sh` then rebuilds the golden for each of the
five and classifies EVERY census row (`BOUNDARY_POSITIVE_CONTROL_SCORED.txt`):

```
ARM cells/pc1/top.sv OK=38 FIXED=3 BROKEN=0 STILL=4   <- the law, fired
ARM cells/pc2/top.sv OK=37 FIXED=0 BROKEN=0 STILL=3   <- clause 1 (func_upto shape)
ARM cells/pc3/top.sv OK=17 FIXED=0 BROKEN=0 STILL=4   <- clause 3 (gen-scope home)
ARM cells/pc4/top.sv OK=23 FIXED=0 BROKEN=0 STILL=4   <- clause 2 (non-int formal)
ARM cells/pc5/top.sv OK=23 FIXED=0 BROKEN=0 STILL=4   <- clause 4 (bare-implicit formal)
-- arms=5 NOGOLD=0 OK=138 FIXED=3 BROKEN=0 STILL=19
```

and `pc1` under the OFFICIAL judge goes **64 cmp lines / 1 head → 0 / 0**.

## 8. WHAT THE CENSUS INSTRUMENT ADDS, AND ITS TWO TRAPS

`acensus13.cpp` walks every `param_assign` Rhs in the DEF (`allModules` +
`allInterfaces`), ELAB (`topModules`, gen scopes walked) and PKG (`allPackages`,
the r10vrgg11 verifier's view) listings and emits one row per CALL ARGUMENT,
keyed `(view, instance full path, param_assign name, callee chain, arg index)`,
alongside PA / PORT / CA / RANGE rows so a law that moves a NEIGHBOURING family
cannot hide.  Its value column prints the Compare-visible constant fields plus
two WITNESS columns:

* `/P:<parent kind>@<l:c>` — **THE COPY MARKER**.  `result->VpiParent(param_ass)`
  is the clone arm's signature, and `vpiParent` is read by NO generated
  `Compare`, which is exactly what makes it a clean witness.
* `/T:<typespec kind>@<l:c>` — typespec IDENTITY by location.

Both are stripped by `score13.py --cmpvis` for every claim about the judge.
Traps inherited and re-paid: `UhdmName()` returns a `string_view` and printing it
raw turns the census file BINARY (r10rgg11); the multiset join is a
`defaultdict(list)`, never a last-writer dict (RESUME §9); `run_grid13.sh` and
`cell13.sh` delete `slpp_all` because `slpp_all/lib/work/<src>.sv` is a COPY of
the arm and manufactures phantom boundary movers (r10rgg12 § 10).

## 9. RESIDUES AND THE NEXT HEAD

**R0 — THE NEW HEAD of `default:Rggen` (36 cmp lines, 1 head).  A DIFFERENT
FAMILY: a `bit_select` INDEX constant whose `vpiDecompile` still carries the
GENVAR TEXT.**

```
rggen-sample/block_0.sv:1748:36-1748:38, in
work@rggen.u_block_0.g_register_10.g[0].u_register.register_if
  golden : constant  UINT:10  sz 64  ct 9  vpiDecompile "10"
  ours   : constant  UINT:10  sz 64  ct 9  vpiDecompile "10+i"    (span 36-40)
```
The VALUE is right and the SIZE is right; `expr::Compare` fails on
`VpiDecompile` — we fold a gen-for index to the right number but render the
UNSUBSTITUTED SOURCE TEXT, and we keep the whole `10+i` span where golden keeps
the folded token's.  This is the same family as the 24 `hier_path` port rows
(`register_if[6+7*i+6].value[0 + 1 * l+:1]` vs golden's
`register_if[19].value[1+:1]`) — a genvar-substitution-in-decompile law, and the
census makes it 25 objects.

**R-A — the BIGGEST Rggen family, 810 census rows, untouched and now RE-MEASURED
against this pass's question.**  Golden's ELAB view keeps
`op11[ref(WIDTH), UINT:1]` — a range bound with a BARE, unsubstituted parameter
reference — where we fold to `const INT:<n>`; all of them are interface
(`rggen_bit_field_if` / `rggen_register_if`) variables inside gen scopes.
**It is NOT the mirror of this pass's law and the grids say so**: grid A's `expr`
cells show golden SUBSTITUTING a bare parameter under an operation when that
operation is a CALL ARGUMENT in a `param_assign` Rhs (`op24[<the copy>, UINT:1]`),
while R-A's identical `op11[ref, UINT:1]` shape in a RANGE BOUND keeps the ref.
The discriminator is the POSITION, not the operation — and R-A's home is a
GEN-SCOPE-homed declaration, the same home grid B shows refuses substitution.
846 of the 846 remaining Compare-visible differing keys are R-A (810), R0's
`hier_path` family (24) and R-B below (12).

**R-B — 12 `param_assign` value rows**: 7 `START_ADDRESS` constants rendering
signed on our side (`UINT:-44` vs golden `UINT:84` at `sz=7`), 4 ELAB
`param_assign` rows we emit and golden does not (`…u_register.bus_if`), and 1
`BIN:0` whose size is 64 where golden's is 2.  Unchanged by this pass.

**R-C — the OTHER argument shapes of grid A, measured and deliberately left.**
Golden substitutes the bare parameter INSIDE an operation argument (`P+1`) where
we keep `ref(P)`; and a LITERAL argument carries NO typespec and keeps
`compileConst`'s own 64-bit size in golden where we stamp the formal's typespec
and re-size to the formal's width.  Both are `Reduce::No` consequences of the
same identifier branch (no `evalFunc` ran, so nothing stamped).  ZERO corpus
reach today (the predictor found no such row in either corpus).

**R-D — the single-dimension twin of this law.**  `cells/pc2` shows golden's
argument in a `Reduce::Yes` initializer ALSO carrying the declaration constant's
encoding (`BIN:0110 ct 3` vs our `UINT:6 ct 9`) but WITH the formal's typespec and
width.  Extending the copy there is the natural next step; it is NOT taken in this
pass because its blast radius is the 2050 predicted rows of § 6 including
`func_upto`'s 1024 CMP_EQUAL ones, and this pass's head does not need it.
`cells/pc2` is the arm it should be developed on.

## 10. THE INSTRUMENTS

| file | what it measures |
|---|---|
| `acensus13.cpp` / `build13.sh` | THE CENSUS: every CALL ARGUMENT inside a `param_assign` Rhs in DEF / ELAB / PKG, plus PA / PORT / CA / RANGE rows, with the copy marker and typespec identity.  Rggen: 42,303 golden rows / 42,307 ours. |
| `gen_grid13.py` + `run_grid13.sh` + `cell13.sh` | Grid A (24 cells × 6 instances), Grid B (12), Grid C (3), and the single-cell driver. |
| `score13.py` | golden-vs-ours and the OK/FIXED/BROKEN/STILL/MOVED-STILL-WRONG three-way, with `--cmpvis` (Compare-visible fields only) and `--only=<kind>`. |
| `reours13.sh` | re-reads ONLY our side of an already-built grid (the golden side is immutable). |
| `predictdb13.sh` | the database-level prediction of § 6 (carries the FENCE). |
| `boundary13.sh` + `scorearms13.sh` | the precedent-arm boundary of § 7, its positive control, and the toward-golden scoring of every mover. |
| `dumpdiff13.sh` | the whole-dump path-normalised base-vs-patched diff. |
| `gates13.sh`, `ct13rows.sh`, `tfslice13.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the mandatory gates. |
| `cells/` | `pc1` (the positive control: the law in miniature, and it PASSES cmp), `pc2`/`pc3`/`pc4`/`pc5` (one per gate clause, all must NOT move). |

`tfslice13.sh` exists because the committed `results/gate_uhdm2rtlil.csv` is
TESTFLAGS-ONLY and python's `csv.writer` defaults to `\r\n`: a byte-identical
slice written that way read as **731 differing rows** before the trap was found.

## 11. WHAT THIS PASS DOES **NOT** CLAIM

* Rggen does **not** pass `uhdm-cmp`.  **NO CORPUS ROW WAS CONVERTED** in either
  corpus, in either mode, and `results/*.csv` was never written.
* 64 → 36 cmp lines is **not** progress: it is the next head object's decompile
  size.  The claims that rest on evidence are the 22-line whole-dump diff, the
  22-FIXED / 0-BROKEN census, the `pc1` cell passing the official judge, and the
  two 0-differing-row corpus gates.
* The law is implemented for the ELAB view of a MULTIDIMENSIONAL parameter's
  initializer, an INTEGER formal, a module-instance-homed `param_assign` and a
  non-bare-implicit formal.  Each restriction is measured (§ 4) and each has an
  arm in `cells/`.  The DEF view has no twin: golden keeps `ref(N)` there and so
  do we, before and after.

## 12. HOW TO REPRODUCE

```sh
git worktree add /tmp/wt_r10rgg13 49634d2 && git apply /tmp/r10rgg13.patch   # in it
cmake -S /tmp/wt_r10rgg13 -B /tmp/r10rgg13_build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build /tmp/r10rgg13_build -j 2
bash    tools/probe/r10rgg13repro/build13.sh                      # the census tool
python3 tools/probe/r10rgg13repro/gen_grid13.py /tmp/r10rgg13_gridA A
bash    tools/probe/r10rgg13repro/run_grid13.sh  /tmp/r10rgg13_gridA \
        /tmp/r10rgg13_bin/slang-uhdm-base /tmp/r10rgg13_gridAout
bash    tools/probe/r10rgg13repro/reours13.sh   /tmp/r10rgg13_gridA \
        /tmp/r10rgg13_bin/slang-uhdm-pat /tmp/r10rgg13_gridAout /tmp/r10rgg13_gridAoutPAT
python3 tools/probe/r10rgg13repro/score13.py /tmp/r10rgg13_gridAout/golden.cen \
        /tmp/r10rgg13_gridAout/ours.cen /tmp/r10rgg13_gridAoutPAT/ours.cen --cmpvis --rows
bash    tools/probe/r10rgg13repro/gates13.sh {gold|goldneg|u2r|sl} {base|pat}
bash    tools/probe/r10rgg13repro/rowheads.sh <workdir> <outdir> Rggen
```
