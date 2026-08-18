# r10rgg11 — § genLpPortConnValue11: a PORT ACTUAL that is a bare parameter name COPIES that parameter's own param_assign Rhs, in a GENERATE BLOCK exactly as in a MODULE BODY

**MEASUREMENT-ONLY directory.** The official `uhdm-cmp` remains the sole
acceptance judge.  **BASE `5a76eab`.**  `results/*.csv` was READ ONLY and is
untouched.  **Rggen still does NOT pass `uhdm-cmp`, and NO CORPUS ROW WAS
CONVERTED** — this pass says so up front.

Target: `default:Rggen`'s official head after r10rgg10 (36 cmp lines, 1 head) —
the folded constant of the port connection `.i_value (INITIAL_VALUE)` at
`rggen-sample/block_0.sv:468:30-468:43`, in the gen scope
`g_register_2.g_bit_field_1` whose only declaration is
`localparam bit [7:0] INITIAL_VALUE = 8'hab;`:

```
golden : constant  HEX:ab   vpiSize 8   vpiConstType 5   vpiDecompile 8'hab
ours   : constant  UINT:171 vpiSize 64  vpiConstType 9   vpiDecompile 171
```

**RESULT. THE HEAD IS CLEARED.**

* `rowheads.sh` (official `uhdm-cmp`, Rggen default): the head object moves to a
  **DIFFERENT FAMILY** — a `range` bound holding an unreduced user function call
  (§ 8, R0).  36 cmp lines → 104; a cmp line count is the head OBJECT'S
  decompile size, so that number is **not** a progress metric and is not
  reported as one.  The arbiter is the whole-dump diff below.
* **The whole-dump path-normalised diff of Rggen, base vs patched, is FOUR
  LINES — the head constant's four fields, and nothing else**
  (`DUMPDIFF_rggen_base_vs_pat.txt`, over 1,580,412 dump lines a side).
* Port-actual census over the WHOLE Rggen database: **25 → 24 differing ELAB
  port-connection rows**, golden-only 33 → 32, ours-only 37 → 36.
* Corpus: **0 movers over 1358 uhdm2rtlil databases**; **2 movers over 956
  surelog databases**, both named and attributed (§ 7).
* **0 differing ROWS** in either corpus, either mode, status AND dump column,
  against the committed baselines AND against my own base sweeps.

---

## 1. THE HEAD, decoded from the PRISTINE cmp LOG

`HEAD_R0_BEFORE_default_Rggen.cmp`, verbatim (LHS is ALWAYS golden):

```
LHS:  constant, id:36546, line:468:30, endln:468:43
      |vpiParent:  \_port: (i_value), id:36294, line:28:39, endln:28:46
      |vpiDecompile:8'hab  |vpiSize:8  |HEX:ab  |vpiConstType:5
RHS:  constant, id:28446, line:468:30, endln:468:43
      |vpiParent:  \_port: (i_value), id:28443, line:28:39, endln:28:46
      |vpiDecompile:171    |vpiSize:64 |UINT:171 |vpiConstType:9
```

**THE OWNER, read off the parent chain and confirmed by census, is the PORT's
own `High_conn`** — not the `param_assign` Rhs of the child's parameter (that
is r10rgg10's object, id 36546 is a different object at a different span), and
not a parameter override.  `pcensus11` keys every port connection by
`(view, owning-instance full path, port index, port name)` and finds it exactly
once, in the ELAB view only:

```
ELAB|PORT|work@rggen.u_block_0.g_register_2.g_bit_field_1.u_bit_field|10|i_value
  golden constant(HEX:ab,sz=8,ct=5,dec=8'hab)/LOC
  ours   constant(UINT:171,sz=64,ct=9,dec=171)/LOC
```

The **DEF view never moves**: golden's `uhdmallModules` listing keeps a
`ref_obj (work@top.g.u.i_value.IV)` for the same connection, and so do we,
before and after (checked in the dump on the 9-line minimal cell as well as in
Rggen).

## 2. THE LAW

> **§ genLpPortConnValue11.**  An instance PORT CONNECTION whose WHOLE actual is
> a bare parameter name is, in golden's elaborated view, a **COPY OF THAT
> PARAMETER'S OWN `param_assign` Rhs constant** — `VpiValue`, `VpiSize`,
> `VpiConstType` and `VpiDecompile` carried over verbatim — relocated at the
> READ SITE's span.  It is **NOT** a fresh evaluation of the parameter's value.
>
> Surelog's mechanism is `CompileHelper::compileExpression`'s identifier branch
> (`CompileExpression.cpp:2880-2883` for the netlist `param_assign`,
> `2948-2951` for the component one): the netlist's `param_assign` for that
> name is found, `substituteAssignedValue` accepts it, and the result is
> `UHDM::clone_tree(param_ass->Rhs())` followed by
> `fC->populateCoreMembers(child, child, result)` — the clone is re-spanned at
> the identifier.  A `Value`-built constant (`sval->uhdmValue()` /
> `getSize()` / `vpiValType()` / `decompiledValue()`, the shape the brief
> proposed) **cannot** be the source: `LValue::uhdmValue()` has no `HEX:` case
> at all (`Value.cpp:880-921` — Hexadecimal falls to the `INT:` default) and
> `LValue::vpiValType()` maps Hexadecimal to `vpiIntConst`, so it could never
> produce `HEX:ab` / `vpiConstType 5`.  The declaration constant can and does.
>
> **THE HOME IS NOT THE AXIS.**  Golden treats a MODULE-BODY parameter and a
> GENERATE-BLOCK parameter identically.  **We did not**: our module-body arm
> (`ModuleEmit.cpp` ~10406, keyed on `elabParamPa`) already copied the
> `param_assign` Rhs, but a gen-scope parameter never reaches `elabParamPa` —
> gen scopes build their `param_assign`s in `emitGenScopes`, not in
> `emitParameters` — so the actual fell through to `ExprEmit.cpp:8746`'s
> `genvarConnFold` arm and folded a generic **64-bit UINT**.
>
> `genvarConnFold`'s 64-bit fold is **the GENVAR law and stays**: golden gives
> a bare genvar port actual `UINT:<i> sz 64 ct 9` (cell
> `cells/genvar__bare__portplain`, measured on both sides), and a genvar has no
> `param_assign`, so it never enters the new map.

## 3. THE GRIDS

### Grid A — 192 cells: **2 homes × 8 declared types × 12 initializers**, read fixed at `portplain`

`gen_grid11.py <dir> A`; 192 OK, 0 NODB, 0 NOSLANG.  Types
`bit[7:0] / logic[7:0] / bit signed[7:0] / int / untyped / bit / bit[31:0] /
byte`; initializers `8'hab / 8'b10101011 / 8'd171 / 171 / -3 / 8'h0a+8'ha1 /
BASE+1 / {4'ha,4'hb} / f8(8'hab) / $clog2(300) / 'hab / 1'b1`.

**The law stated as an identity and tested on each side independently**
(`law11.py`, `LAW_identity_gridA.txt`):

> *port actual == that parameter's own ELAB `param_assign` Rhs, field for field*

| side | HOLDS | BREAKS |
|---|---|---|
| **golden** | **180 / 192** | 12 |
| ours, BASE | 96 | 96 |

and the split on our side is **exactly the home**: all 96 `mod` cells hold, all
96 `genif` cells break.  Golden's 12 breaks are **HOME-BLIND** — the same six
`(type,init)` cells in *both* homes (`int×{bin8,cat,dec8,sizedone}`,
`bit32×dec8`, `bit1×dec8`) — which is what proves the home is not the axis and
that the exceptions belong to a different mechanism (§ 8, R2).

Golden's shape per axis, read off `GRID_A.txt`:

| initializer | golden's port actual | note |
|---|---|---|
| `8'hab`, `'hab` | `HEX:ab`, ct 5, **size = the DECLARED width**, decompile re-rendered `<size>'hab` | `bit[31:0]` → `32'hab`; `bit` → `1'hab` |
| `8'b10101011`, `{4'ha,4'hb}` | `BIN:10101011`, ct 3, sz 8, `8'b10101011` | the LITERAL's own width, declared width ignored |
| `8'd171` | `INT:171`, ct 7, sz 8, `171` | |
| `171`, `8'h0a+8'ha1`, `BASE+1`, `$clog2(300)` | `UINT:<n>`, ct 9, size = declared width | |
| `-3` | `INT:-3`, ct 7, size = declared width | |
| `f8(8'hab)` | **`func_call`, NOT folded at all** | a call initializer is never reduced |

### Grid B — 324 cells: **4 homes × 3 types × 3 initializers × 9 read kinds**

`gen_grid11.py <dir> B`; 324 OK, 0 NODB, 0 NOSLANG.  Homes
`mod / genif / genfor / pkg`; reads
`portplain / portcat / portcast / portsel / portcall / pov / ca / proc / none`.

| read | what golden does with a bare gen-scope parameter | ours, BASE |
|---|---|---|
| `portplain` `.i_value(IV)` | the param_assign Rhs copy | **64-bit UINT — THE BUG** |
| `pov` `#(.W(IV))` | the same copy (at the FORMAL's width) | **already correct** — the override actual's `param_assign` Rhs is SAME in **36 / 36** `pov` cells |
| `ca` `assign w = IV;` | the same copy | **already correct** — 36 cells, 27 SAME; the 9 DIFF are all DECLARATION-constant residues (§ 9 R3), not the read |
| `proc`, `none` | (no read of IV at the port) | SAME |
| `portcat`, `portcast`, `portsel`, `portcall` | golden folds the **WHOLE EXPRESSION** to one constant | we keep the tree (§ 8, R1) — a different family, untouched here |

The `pov` and `ca` rows answer two of the brief's questions with measurements:
a **parameter OVERRIDE actual** and a **cont-assign RHS** take the SAME
copy-the-declaration law, and we already implement both — so rgg8/rgg9's
"cont-assigns go through the 64-bit `get_value`" reading does **not** hold for a
gen-scope localparam read.

## 4. THE FIX

Two edits, **43 added lines, 0 removed, 0 files other than
`src/ModuleEmit.cpp` and `include/UhdmExporter.h`**:

1. a symbol-keyed index of the gen-scope `param_assign`s
   (`genLpPaBySym11`), filled at the two places `emitGenScopes` already fills
   the path-keyed `genLpFoldByPath` — so genvars, which have no `param_assign`
   and never reach those sites, are structurally excluded;
2. one `else if` in the port-connection arm at `ModuleEmit.cpp` ~10434, after
   the `$unit` and `elabParamPa` branches, using the same `src9` copy that arm
   already performs.

Keyed strictly on the WHOLE actual being the bare name
(`stripImplicitConv(*expr).kind == NamedValue`), which is why the concat / cast
/ select / call-argument shapes of Grid B are untouched.

## 5. THE GRID SCORE OF THE PATCH

`reours11.sh` re-reads only OUR side (the golden side of a grid is immutable),
`scorepat11.py` classifies every row OK / FIXED / BROKEN / STILL.

| grid | rows scored | OK | **FIXED** | **BROKEN** | STILL |
|---|---|---|---|---|---|
| A, port rows | 192 | 62 | **36** | **0** | 94 |
| A, **ALL census rows** | 1344 | 1125 | **36** | **0** | 183 |
| B, port rows | 324 | 170 | **12** | **0** | 142 |
| B, **ALL census rows** | 2160 | 1932 | **12** | **0** | 216 |

**BROKEN is zero on both grids and on every censused row family, not only on
the port rows.**  Every FIXED row is a `genif`/`genfor` home with a `portplain`
read — the shape the law names.

## 6. GATES

| gate | result |
|---|---|
| build both, md5 separately | base `f8908264f24f59f9ca3c19826a244eae`, patched `917997b9a0e23553ddba33dba679ca69` |
| goldens, base | 23 PASS / 0 FAIL |
| goldens, patched | **23 PASS / 0 FAIL** |
| goldens, `SLANG_UHDM=/bin/false` (negative control) | **0 PASS / 23 FAIL** |
| uhdm2rtlil, base, both modes | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL per mode; the testflags slice **byte-identical to the committed `results/gate_uhdm2rtlil.csv`, 0 differing ROWS** |
| uhdm2rtlil, patched, both modes | **0 differing ROWS** vs the committed baseline AND vs my own base, status AND dump column |
| uhdm2rtlil byteverify, SELFCHECK=1 | selfcheck 0 movers; **base vs patched 0 MOVERS over 1358**, 0 only-in-A, 0 only-in-B |
| surelog, base, both modes | **byte-identical to the committed `results/golden_surelog.csv`, 0 differing ROWS over 1588** (470/11/5/283/25 default; 466/9/5/3/1/284/23/1/2 testflags) |
| surelog, patched, both modes | **0 differing ROWS** vs the committed baseline AND vs my own base |
| surelog byteverify, SELFCHECK=1 | selfcheck 0 movers over 956; **base vs patched 2 MOVERS**, both named (§ 7) |
| canaries.sh (surelog / u2r) | ok=52 changed=0 / ok=8 changed=0 |
| ctcan2.sh (surelog, `EXPECT_UNKNOWN=1`) | ok=58 changed=0, unknown-patterns=1 = the documented u2r-only `2DFunctionArg` |
| canaudit.sh | audited=29 **UNCOVERED=0 FENCE-BREACH=0**, both self-tests live |
| byte pins | `SVSwitch 4842211c4030` ✓, `YosysVerx 6ccda350c24a` ✓, `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` byte-identical in both modes ✓ |

Named-row heads, base → patched (each 1 head; `Scoreboard/testflags` and
`Rggen/testflags` are SKIP-NOFILE and COUNTED — non-CMP rows with no slang
database):

| row | mode | base | patched |
|---|---|---|---|
| SeqDriver | default / testflags | 176 / 176 | 176 / 176 |
| SimpleUVM | default / testflags | 176 / 176 | 176 / 176 |
| Scoreboard | default | 176 | 176 |
| MiniAmiq | default / testflags | 176 / 176 | 176 / 176 |
| BuildUVMPkg | default / testflags | 31 / 31 | 31 / 31 |
| Earlgrey_0_1 | default / testflags | 29 / 30 | 29 / 30 |
| **Rggen** | **default** | **36** | **104 (NEW FAMILY, § 8 R0)** |

## 7. THE PREDICTION, filed BEFORE the patched sweeps were read

1. **`predict11.py`** — a deliberately OVER-INCLUSIVE syntactic scan of both
   corpora for the shape the law needs (a parameter declared in a file that has
   a generate context, named as the WHOLE actual of a port connection):
   **44 candidate tests, FENCED-SKIP=4** (`PREDICT_sources.txt`).
2. **`predictdb11.sh`** — the DATABASE-level prediction, run on the PRISTINE
   BASE workdirs: every ELAB port actual that is, on OUR side, the 64-bit UINT
   fold this law replaces, and differs from golden.  That predicate is an
   over-inclusive superset of the law, which is the safe direction.

```
uhdm2rtlil : -- dirs-scanned=1358 SKIP-NOFILE=104 FENCED-SKIP=0 PREDICTED-ROWS=0
surelog    : -- dirs-scanned=948  SKIP-NOFILE=617 FENCED-SKIP=8 PREDICTED-ROWS=1
             PREDICT default/Rggen ELAB|PORT|...g_bit_field_1.u_bit_field|10|i_value
                     OURS=constant(UINT:171,sz=64,ct=9,dec=171)/LOC
                     GOLD=constant(HEX:ab,sz=8,ct=5,dec=8'hab)/LOC
```

**POSITIVE CONTROL** (`PREDICT_db_POSITIVE_CONTROL.txt`): the same driver over a
one-test workdir finds that row — a predictor that reaches nothing must never
read as a clean prediction.

**THE PREDICTED MOVER SET IS EXACTLY ONE ROW: `default/Rggen`.**  The sweeps
produced exactly that row plus `default/Scoreboard`, which is
**THE COIN, NOT THIS PATCH**, and is proved so in `COIN_scoreboard.txt`: the
PATCHED binary run alone reproduces the BASE artifact's bytes 6/6, and the two
sweep faces differ by 92 raw dump lines and **0 order-blind** lines — the
documented `svunit_pkg` `vpiTaskFunc` ORDER flip.  Its row status, dump column
and head count are unchanged.

## 8. BOUNDARY

`boundary11.sh` compiles EVERY source arm — subdirectories included — of the 38
precedent repro directories this law can reach (`r10rgg1…10`, `r10vrgg2…9`,
`r10rggen6…9`, `r10earl45…60`) with BOTH binaries and compares byte-wise:

```
-- files=1202 identical=1097 MOVERS=7 uncompilable=98 asymmetries=0
```

**AN ARM THAT MOVES IS NOT ENOUGH — IT HAS TO MOVE TOWARD GOLDEN.**
`scorearms11.sh` rebuilds the golden for each of the 7 and classifies every
ELAB port-actual row (`BOUNDARY_MOVERS_SCORED.txt`):

```
-- arms=7 OK=32 FIXED=9 BROKEN=0 STILL=0
```

All seven are r10rgg10's and vrgg10's own cells — the sibling law's arms, i.e.
exactly the shape this law names — including `g8_deepnest`, `g8_recurse` (three
nested levels) and `g8_defonly`.  The 98 uncompilable files are the same
multi-file arms r10rgg9/r10rgg10 recorded, each printed and COUNTED.

**POSITIVE CONTROL** — the same driver over this pass's own 14 cells:

```
MOVER cells/genfor__bit8__hex8__portplain/top.sv
MOVER cells/genif__bit8__hex8__portplain/top.sv
MOVER cells/genif__int__hex8__portplain/top.sv
MOVER cells/genif__untyped__unsized__portplain/top.sv
-- files=14 identical=10 MOVERS=4 uncompilable=0 asymmetries=0
-- arms=14 OK=8 FIXED=3 BROKEN=0 STILL=4
```

so the comparator provably sees THIS pass's difference, and the ten cells that
must NOT move — `mod`, `portcat`, `portcast`, `portsel`, `portcall`, two `pov`,
`ca`, `pkg`, and **`genvar__bare__portplain`** — do not.

## 9. RESIDUES AND THE NEXT HEAD

**R0 — THE NEW HEAD of `default:Rggen` (104 cmp lines, 1 head).  A DIFFERENT
FAMILY: an unreduced USER FUNCTION CALL inside a packed RANGE BOUND.**

```
rggen-sv-rtl/rggen_or_reducer.sv:66:9-66:21   (the range of a local vector)
  golden : range Left_expr = operation op 11 (vpiSubOp) @66:10-66:18
             [ func_call get_next_n(constant BIN:...10, sz 400, ct 3) ,
               constant UINT:1 sz 64 ]
             — the call is NOT reduced; the whole subtraction survives
  ours   : range Left_expr = constant INT:0 vpiSize 64 vpiConstType 7 @66:10-66:16
```
Instance: `work@rggen.u_block_0.g_register_6.u_register.u_register_common.
u_read_data_mux.g.u_reducer`.  This head was ALREADY WRONG in the base and was
merely masked by the port-actual head — proved by the whole-dump diff of § 0,
which shows the ONLY base→patched change in the entire Rggen database is the
four fields of the cleared head.

**R1 — the WHOLE-EXPRESSION port-actual fold, corpus-wide and unfixed.**  Grid B
says golden folds a port actual that is a concat, a cast, a part-select or a
function call over a parameter to ONE constant
(`{4'h0,IV[3:0]}` → `BIN:00001011` sz 8; `8'(IV)` → `UINT:171` sz 8;
`IV[3:0]` → `BIN:1011` sz 4; `f8(IV)` → `UINT:171` at the declared width), where
we keep operation 33 / operation 67 / `part_select` / `func_call`.  **132 of
the 144** grid-B cells in those four reads disagree (the 12 that agree are the
`f8(IV)` cells whose parameter initializer is itself a call, so golden keeps a
`func_call` too).  This is the same family r10scr13's NOTE (a) recorded (`.g(UP + UI)`);
it is a corpus-wide surface and is deliberately left: this pass's target was the
head, and the fix keys on the bare name so it cannot touch it.

**R2 — golden's own 12 law-breaks, HOME-BLIND and unmodelled.**  For
`int×{8'b…, {4'ha,4'hb}, 8'd171, 1'b1}`, `bit[31:0]×8'd171` and `bit×8'd171`
golden's port actual keeps the LITERAL's own encoding and size
(`BIN:10101011` sz 8) where the ELAB `param_assign` Rhs was re-typed to the
declared type (`INT:-85` sz 32).  Both homes, identically.  We now copy the
`param_assign` Rhs in all of them, so these are STILL rows, never BROKEN ones.

**R3 — the DECLARATION constant's own residues, inherited by construction.**
Whatever our gen-scope `param_assign` Rhs still gets wrong, the port actual now
gets wrong too — and it was wrong before as well, differently.  The measured
ones (Grid A/B, `ELAB|PA` rows) are: the decompile is not re-rendered at the
declared width (`8'hab` where golden writes `32'hab` for an `int`/`bit[31:0]`
parameter), and `{…}` / `f(…)` / `expr` initializers fold to `UINT:-85`-style
signed digits where golden keeps `BIN:10101011` / a `func_call` / `UINT:171`.
That is the rgg8/rgg9 declaration-constant family, not this read law.

**R4 — `pkg` home, 3 of 9 `portplain` cells.**  A package parameter read as a
port actual is already right in 6 of 9; the three misses are R3 shapes
(`int×8'hab` decompile, `untyped×{expr,unsized}` size).

## 10. THE INSTRUMENTS

| file | what it measures |
|---|---|
| `pcensus11.cpp` / `build11.sh` | THE CENSUS: every instance PORT CONNECTION actual (`port->High_conn()`) in a database, DEF (`allModules`+`allInterfaces`) and ELAB (`topModules`, gen scopes walked), keyed `(view, owning-instance full path, port index, port name)`, plus every `cont_assign` Rhs and every `param_assign` Rhs in the same scopes; a constant prints exactly the fields `constant::Compare` reads. Rggen: 19,577 golden rows / 19,581 ours. |
| `gen_grid11.py` + `run_grid11.sh` + `cell11.sh` | Grid A (192 cells) and Grid B (324 cells). |
| `score11.py` | golden-vs-ours per cell, one row family at a time. |
| `law11.py` | THE IDENTITY TEST of § 3, run on each side independently. |
| `reours11.sh` + `scorepat11.py` | FIXED / BROKEN / OK / STILL of a patch against an already-compiled grid. |
| `predict11.py` / `predictdb11.sh` | the two predictions of § 7 (both carry the FENCE). |
| `boundary11.sh` + `scorearms11.sh` | the precedent-arm boundary of § 8, its positive control, and the toward-golden scoring of every mover. |
| `gates11.sh`, `ct11rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the mandatory gates. |
| `cells/` | the 14 arms the law is stated on, including the genvar arm that must NOT move. |

### One instrument bug, found and fixed before any number was believed

`pcensus11.cpp` first passed `UhdmName()`'s **`string_view`** straight to
`printf("%s")`.  That wrote raw bytes plus NULs, the census file became
**BINARY**, and `grep` then printed **NOTHING AT ALL** for patterns that do
match — a silent zero that reads exactly like "no such rows".  Materialise a
`std::string` first; the fix carries that comment in the source.

## 11. WHAT THIS PASS DOES **NOT** CLAIM

* Rggen does **not** pass `uhdm-cmp`.  **NO CORPUS ROW WAS CONVERTED** in either
  corpus, in either mode, and `results/*.csv` was never written.
* 36 → 104 cmp lines is **not** a regression and **not** progress: it is the
  next head object's decompile size.  The claim that rests on evidence is the
  four-line whole-dump diff.
* The law is implemented for the ELAB port-connection actual only.  Its DEF
  twin does not exist (golden keeps a `ref_obj` there and so do we), and the
  whole-expression fold of R1 is named and left.

## 12. HOW TO REPRODUCE

```sh
git worktree add /tmp/wt_r10rgg11 5a76eab && git apply /tmp/r10rgg11.patch   # in it
cmake -S /tmp/wt_r10rgg11 -B /tmp/r10rgg11_build_pat -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build /tmp/r10rgg11_build_pat -j 2
bash    tools/probe/r10rgg11repro/build11.sh                      # the census tool
python3 tools/probe/r10rgg11repro/gen_grid11.py /tmp/r10rgg11_gridA A
bash    tools/probe/r10rgg11repro/run_grid11.sh /tmp/r10rgg11_gridA \
        /tmp/r10rgg11_base_bin /tmp/r10rgg11_gridAout
bash    tools/probe/r10rgg11repro/reours11.sh  /tmp/r10rgg11_gridA \
        /tmp/r10rgg11_pat_bin /tmp/r10rgg11_gridAout /tmp/r10rgg11_gridAoutPAT
python3 tools/probe/r10rgg11repro/scorepat11.py /tmp/r10rgg11_gridAout \
        /tmp/r10rgg11_gridAoutPAT
bash    tools/probe/r10rgg11repro/gates11.sh {gold|goldneg|u2r|sl} {base|pat}
bash    tools/probe/r10rgg11repro/rowheads.sh <workdir> <outdir> Rggen
```
