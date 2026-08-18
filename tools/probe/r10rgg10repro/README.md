# r10rgg10 — § genLpPortConnRead10: an instance PORT CONNECTION reads a parameter, a PARAMETER OVERRIDE does not

**MEASUREMENT-ONLY directory.** The official `uhdm-cmp` remains the sole
acceptance judge. **BASE `66f9c73`.** `results/*.csv` was READ ONLY and is
untouched. **Rggen still does NOT pass `uhdm-cmp`, and NO CORPUS ROW WAS
CONVERTED** — this pass says so up front.

Target: `default:Rggen`'s official head after r10rgg9 (76 cmp lines, 1 head) —
the typespec hanging off the ELAB `param_assign` of a gen-scope localparam:

```
rggen-sample/block_0.sv:449-451
    if (1) begin : g_bit_field_1
      localparam bit [7:0] INITIAL_VALUE = 8'hab;
      ...
        .i_value            (INITIAL_VALUE),
```

golden gives that constant a **LOC-LESS `logic_typespec` with BARE `UINT:7` /
`UINT:0` bounds**; we gave it the declaration's located `bit_typespec` with
fully shaped `sz=64/ct=9/dec=7` bounds.

**RESULT. THE HEAD IS CLEARED.**

* `rowheads.sh` (official `uhdm-cmp`, Rggen default): **76 cmp lines / 1 head
  → 36 / 1 head**, and the head object moves to a DIFFERENT FAMILY (the port
  connection's own folded constant — see § 7, R0).
* The parameter census over the WHOLE Rggen database (9794 parameter rows,
  DEF + ELAB) goes from **13 differing rows → 12**, with **0 golden-only and
  0 ours-only**, and the one row that changed is exactly the head.
* Corpus: **uhdm2rtlil 0 movers over 1358 databases, 0 differing ROWS** in
  either mode against my own base AND against the committed
  `results/gate_uhdm2rtlil.csv` testflags slice (679/50/2, byte-identical).

---

## 1. THE HEAD, decoded from the GOLDEN DATABASE FIRST

`uhdm-cmp`'s head prints the differing TYPESPEC, not its owner, so the owner
was read out of the golden dump before any code was written:

```
golden, ELAB gen_scope work@rggen.u_block_0.g_register_2.g_bit_field_1
  parameter INITIAL_VALUE
    vpiTypespec -> ref_typespec(...INITIAL_VALUE) -> bit_typespec @450:18-450:27   <- SAME on both sides
  param_assign
    vpiRhs -> constant 8'hab sz 8 HEX:ab ct 5 @450:44-450:49
       vpiTypespec -> ref_typespec(work@rggen.u_block_0.g_register_2.g_bit_field_1)
          -> logic_typespec  NO LOCATION  { [ UINT:7 : UINT:0 ] , both bounds BARE }
```

The head object is therefore the **param_assign Rhs constant's** typespec, not
the parameter's own; ours pointed BOTH refs at one located `bit_typespec`, which
is why the cmp dump showed the offending object parented at the
`...INITIAL_VALUE` ref.  The DEF view (`named_begin` under `gen_if`) carries a
constant with **no typespec at all** on both sides and never moved.

A bare bound is a constant with `VpiValue` and **nothing else** — no
`vpiSize`, no `vpiConstType`, no `vpiDecompile` — which is exactly what
`CompileHelper::setRange` mints (§ 2).

## 2. THE LAW

> **§ genLpPortConnRead10.** Surelog's `CompileHelper::getObject`
> (`CompileExpression.cpp:305-323`) resolves a NAME to its `param_assign`,
> takes **`passign->Rhs()` — THE SHARED DECLARATION CONSTANT** — and then, if
> the enclosing `ModuleInstance` has a value for that name, calls
> `setRange(constant, value)`.  `CompileHelper::setRange`
> (`CompileHelper.cpp:5417`) **REPLACES that constant's typespec IN PLACE**
> with a fresh `logic_typespec` — no location — carrying one range whose
> bounds are bare `UINT:<lrange>` / `UINT:<rrange>` constants, and it does so
> **only when `lr || rr`**, i.e. only for a parameter whose Value carries a
> packed RANGE.  The Value's range is set in exactly one place,
> `CompileHelper::valueRange` (`CompileHelper.cpp:5410`,
> `DesignElaboration.cpp:2544`), off the DECLARATION typespec's first packed
> range.
>
> The clause this pass adds: **an instance PORT CONNECTION is one of the
> expressions Surelog compiles WITH an instance, so it takes that path — and a
> parameter OVERRIDE is not.**
>
> Rggen block_0 is the natural experiment, two adjacent bit-field blocks with
> one localparam apiece and no other difference that matters:
>
> ```
> g_bit_field_0 (183)  localparam bit [3:0] INITIAL_VALUE = 4'h0;
>                        .INITIAL_VALUE (INITIAL_VALUE)   PARAMETER actual
>                        -> golden keeps the declaration bit_typespec
> g_bit_field_1 (450)  localparam bit [7:0] INITIAL_VALUE = 8'hab;
>                        .i_value       (INITIAL_VALUE)   PORT actual
>                        -> golden BARE loc-less logic_typespec
> ```
>
> and the whole Rggen database agrees: of 2419 ELAB gen-scope parameter rows,
> **exactly ONE** carries the bare shape — the one whose only read is a port
> connection.

## 3. THE GRIDS — the axis was found by REFUTING the obvious ones

`8'hab` is the ONLY NONZERO localparam initializer in Rggen's two sample
blocks, so "nonzero value" was the cheap hypothesis.  **Grid A refuted it.**

**Grid A** (`gen_grid10.py`, 630 cells = 5 scopes x 9 declared types x 7
initializer kinds x 4 read kinds, 756 ELAB rows, NODB 0 / NOSLANG 0) —
golden's class, tabulated per axis:

| axis | BARE-LOGIC cells | DECL cells | verdict |
|---|---|---|---|
| scope (modbody / genif named / genif unnamed / genfor / gennest) | 56 each | 35 each | **BLIND** |
| value (zero / nz / nzdec / unsized / expr / concat / call) | 40 each | 25 each | **BLIND** |
| declared type | bit8 70, bit4 70, logic8 35, sbit8 35, bitN 35, bit8p 35 | bit1 35, int 140, untyped 33 | **the RANGE matters** (`if (lr\|\|rr)`) |
| read | port 210, ca 70 | none 70, pactual 70 | **THE AXIS** |

**Grid B** (`gen_gridb10.py`, 320 cells = 4 homes x 5 types x 2 values x 8 read
kinds; 312 OK, 8 NODB — the 8 are `bit1 x portcat`, which selects a bit out of
a scalar and is illegal SV, counted not hidden) separates the read kinds
cleanly, because Grid A's `pactual` cell wrapped its read in a size cast and so
tested something else.  Golden, identical in all 4 homes and at both values:

| read | source | golden |
|---|---|---|
| `none` | — | declaration typespec |
| `pov` | `sink #(.W(IV)) u (.i_value('0));` | declaration typespec |
| `portcast` | `sink #(8) u (.i_value(8'(IV)));` | declaration typespec |
| `portplain` | `sink #(8) u (.i_value(IV));` | **BARE loc-less logic** |
| `portcat` | `sink #(8) u (.i_value({4'h0,IV[3:0]}));` | **BARE** |
| `ca` | `assign w = IV;` | **BARE** |
| `caexpr` | `assign w = IV + 1;` | **BARE** |
| `both` | `sink #(.W(IV)) u (.i_value(IV));` | **BARE** (the port read wins) |

and `bit1` (no range) / `int` / untyped stay on the declaration typespec in
every one of the 8 read kinds — `setRange`'s `if (lr || rr)`, measured.

**Grid C** (`gen_gridc10.py`, 80 cells) walks the read axis to its edges and
confirms the `if (instance)` half of the mechanism:

| read | golden | note |
|---|---|---|
| `proc_always` / `proc_initial` | declaration | a process body is compiled at DEFINITION level — no instance, no rewrite |
| `caonly` / `gencond` | **BARE** | |
| `portnamed` / `portpos` / `nestedport` | **BARE** | positional and named alike; a port connection in a NESTED gen block counts |
| `nestedca` | declaration | a cont-assign in a NESTED gen block does NOT |
| `caidx` (`assign w[IV[0]] = 1'b0;`) | declaration | an LHS index read does not |
| `funcall` (`assign w = f(IV);`) | declaration | a function-call argument does not |

## 4. THE FIX

One arm, in `ModuleEmit.cpp`'s `pendingGenLpTs` drain — the place r10earl58 and
r10rgg8 already put the gen-scope localparam typespec decisions.  The drain
already bound the bare loc-less clone when a **cont-assign** in the gen scope
read the localparam (`caRead9`, § genLpCaSharedBareTs).  This pass adds the
other read Surelog honours:

* an `Instance` / `InstanceArray` member of the scope (arrays walked element by
  element — an arrayed instantiation is an instance too),
* its `getPortConnections()` only — **never its parameter overrides**,
* counted when the connection expression, **after IMPLICIT conversions are
  stripped**, IS the parameter (`portplain`, `portpos`, `portnamed`), or when a
  select of the parameter appears anywhere inside it (`portcat`),
* and NOT when the read sits under an EXPLICIT cast (`portcast`), because
  stripping only implicit conversions leaves the `ConversionExpression` in the
  way — which is exactly what golden does.

`§ detachedInstNoConns` is honoured: a def-only instance has no parent scope and
asking it for connections segfaults.

Nothing else changed: **95 added lines in `src/ModuleEmit.cpp`, 0 removed, 0
other production files.**

## 5. GATES

| gate | result |
|---|---|
| build both, md5 separately | base `86ca434a02813b5b2120e547f2d11f96`, patched `5d6b499c0878ce483f92310ada5bb782` |
| goldens, patched | **23 PASS / 0 FAIL** |
| goldens, base | 23 PASS / 0 FAIL |
| goldens, `SLANG_UHDM=/bin/false` (negative control) | **0 PASS / 23 FAIL** |
| uhdm2rtlil, base, both modes | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL per mode; the testflags slice is **byte-identical to the committed `results/gate_uhdm2rtlil.csv`, 0 differing rows** |
| uhdm2rtlil, patched, both modes | **0 differing ROWS vs my own base AND vs the committed baseline** (status AND dump column) |
| uhdm2rtlil byteverify, SELFCHECK=1 | selfcheck 0 movers; **base vs patched: 0 MOVERS over 1358 databases**, 0 only-in-A, 0 only-in-B |

The surelog corpus, the byteverify mover attribution and the canaries are § 11.

## 6. THE GRID SCORE OF THE PATCH

Scored by re-reading only the OURS side of the already-compiled grids
(`reours10.sh` — the golden side of a grid is immutable, same Surelog, same
sources), against the same golden census:

| grid | OK | **FIXED** | **BROKEN** | STILL |
|---|---|---|---|---|
| B (312 cells) | 544 | **24** | **0** | 56 |
| C (80 cells) | 104 | **8** | **0** | 24 |

Every FIXED row is a gen-scope home (`work@top.g`, `work@top.u_c.g`) with a
`portplain` / `portpos` / `portnamed` / `portcat` / `both` read — the shape the
law names — at both values and for `bit [7:0]`, `logic [7:0]` and
`parameter bit [7:0]` alike.  **BROKEN is zero on both grids.**

The STILL rows are the pass's NAMED RESIDUES (§ 7).

## 7. RESIDUES AND THE NEXT HEAD

**R0 — THE NEW HEAD of `default:Rggen` (36 cmp lines, 1 head).** It is a
DIFFERENT FAMILY: the port connection's own folded constant.

```
.i_value            (INITIAL_VALUE),          block_0.sv:468:30-468:43
  golden : constant  HEX:ab   vpiSize 8   vpiConstType 5   vpiDecompile 8'hab
  ours   : constant  UINT:171 vpiSize 64  vpiConstType 9   vpiDecompile 171
```

Golden's port-actual fold keeps the parameter's STORED Value — its encoding,
its width and its decompiled spelling (`ExprBuilder`'s `sval->uhdmValue()` /
`getSize()` / `vpiValType()` / `decompiledValue()`, `CompileExpression.cpp:966+`)
— at the port-actual span; ours folds through the generic 64-bit `get_value`
int64.  It is a separate object from the `param_assign` Rhs constant (different
id, different location), so this pass's law does not reach it.

**R1 — the same law at MODULE-BODY scope, unfixed.** Grid B/C say golden gives
the bare loc-less rewrite to a module-body parameter read by a plain instance
port connection too (`portplain`/`portpos`/`portnamed`/`nestedport`/`both`,
32 grid cells), and we still give it the declaration typespec.  That path is
`ParamEmit.cpp`'s `readFold9` arm via `paramCaFoldRead`, whose instance arm
harvests **only SELECT bases** out of a port connection
(`srlgHarvestSelBases50`) — correct for a parameter OVERRIDE (`#(.S(I3))` is
golden-LOCATED, its own cited cell) and wrong for a port CONNECTION.  Left
alone here deliberately: it is a corpus-wide surface and this pass's target was
the head.

**R2 — two OVER-FIRES of ours, pre-existing and unchanged.** Golden keeps the
declaration typespec and we bind the bare clone when the only read is
* a function-call argument in a cont-assign (`assign w = f(IV);`) — 8 grid-C
  cells, all four homes;
* an LHS index (`assign w[IV[0]] = 1'b0;`) in a gen scope — 4 grid-C cells.

**R3 — unrelated, found by the census.** A `parameter` (not `localparam`)
declared inside a generate block gets `vpiLocalParam 1` from us and `0` from
golden (grid B's `bit8par` gen cells).

## 8. THE PREDICTION, filed BEFORE the patched sweep was read

Two independent predictions, both on record before the patched corpus run:

1. **`predict10.py`** — a deliberately OVER-INCLUSIVE syntactic scan of both
   corpora's sources for the shape the law needs (a ranged parameter declared
   in a generate context and named in a port-connection actual).  It listed
   **15 surelog tests** (`Ariane`, `Ariane2024`, `AzadiRTL`, `BitSelect`,
   `Earlgrey`, `EarlgreyPackParam`, `ElabCParam`, `Ibex`, `IncompTitan`,
   `Opentitan`, `Rggen`, `Tnoc`, `Unisim`, `YosysIce40`, `YosysTests`) and
   **2 uhdm2rtlil tests** (`ParameterRangeUsingDot`, `rp32`).
2. **`predictdb10.sh`** — the DATABASE-level prediction, run on the PRISTINE
   base workdir: for each of those names it joins the golden census against the
   base census and prints every ELAB gen-scope parameter row where golden is
   bare-loc-less and ours is not.  Result:

```
-- tests-scanned=31 PREDICTED-ROWS=1 SKIP-NOFILE=22 UNKNOWN=0
PREDICT Rggen/default gen_scope ELAB|work@rggen.u_block_0.g_register_2.g_bit_field_1|gen_scope|INITIAL_VALUE
```

The 22 SKIP-NOFILE arms are all named and all legitimate — every one is a row
whose base status is `SLANG_REJECT`, `SURELOG_FAIL` or `NO_DATABASE`
(Ariane, Ariane2024, AzadiRTL, Earlgrey, Ibex, IncompTitan, Opentitan, Tnoc,
Unisim, YosysIce40, YosysTests, and `Rggen/testflags`), so there is no database
to compare on one side.  `Earlgrey_0_1` (CMP_NOTEQUAL, both modes),
`BitSelect`, `EarlgreyPackParam` and `ElabCParam` WERE scanned and predicted
NOTHING.

**THE PREDICTED MOVER SET IS EXACTLY ONE ROW: `default/Rggen`.**

## 9. BOUNDARY

`boundary10.sh` compiles EVERY source arm — subdirectories included — of the
34 precedent repro directories this law can reach (`r10rgg1/2/5/6/7/8`,
`r10rggen6…9`, `r10vrgg2…9`, `r10earl45…60`) with BOTH binaries and compares
the databases byte-wise:

```
-- files=996 identical=898 MOVERS=0 uncompilable=98 asymmetries=0
```

**0 movers, 0 asymmetries.**  The 98 uncompilable files are the same
multi-file arms r10rgg9 recorded (each one printed and COUNTED, never skipped).

**POSITIVE CONTROL — an arm agreeing is not an arm testing.**  The same driver
over this pass's own 12 cells (`cells/`):

```
MOVER  cells/topgen__bit8__nz__portplain/top.sv
MOVER  cells/childgen__logic8__nz__portcat/top.sv
-- files=12 identical=10 MOVERS=2 uncompilable=0 asymmetries=0
```

so the comparator provably sees THIS pass's difference, and the ten cells that
must NOT move (`pov`, `portcast`, `ca`, `proc_always`, `caidx`, `funcall`,
`bit1`, `int`, `nestedca`, `nestedport`-at-module-body) do not.

## 10. THE INSTRUMENTS

| file | what it measures |
|---|---|
| `pcensus10.cpp` / `build10.sh` | THE CENSUS: every `parameter` in a database, DEF (allPackages + allModules + allInterfaces, gen-scope arrays included) and ELAB (topModules), keyed `(view, owning-scope full path, scope KIND, name)`, reporting `vpiLocalParam`, the parameter's own typespec shape, the `param_assign` Rhs shape, and THE HEAD'S FIELD — the Rhs constant's typespec shape, with each range bound printed as `value/bare|[sz,ct,dec]` and `/LL` when it has no location. Rggen: **9794 rows on each side, 0 golden-only, 0 ours-only.** It does NOT walk the DEF view's `named_begin` generate bodies (those hang off `gen_if` statement trees, not off a scope's Parameters vector); the DEF constant carries no typespec at all there and is byte-identical on both sides, checked by hand in the dump. |
| `gen_grid10.py` + `run_grid10.sh` + `cell10.sh` + `score10.py` | Grid A, 630 cells: scope x declared type x initializer x read. |
| `gen_gridb10.py` + `scoreb10.py` | Grid B, 320 cells: home x type x value x **8 read kinds**. |
| `gen_gridc10.py` | Grid C, 80 cells: the read axis at its edges. |
| `reours10.sh` + `scorepat10.py` | FIXED/BROKEN/STILL scoring of a patch against an already-compiled grid. |
| `predict10.py` / `predictdb10.sh` | the two predictions of § 8. |
| `boundary10.sh` | the precedent-arm boundary of § 9 (and its positive control). |
| `gates10.sh`, `ct10rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the mandatory gates. |
| `cells/` | the 12 arm cells the law is stated on. |

### Two instrument bugs found and fixed before any number was believed

1. `run_grid10.sh` first used an EXPORTED shell function with `xargs`; `export -f`
   does not survive into the children in this environment and the grid measured
   **cells=0**.  Replaced with a separate `cell10.sh` FILE.
2. The rewrite then put `</dev/null` on the **xargs** command instead of on the
   child — which REPLACES the pipe, so xargs read no arguments and the grid
   measured **cells=0 again**.  Both are recorded in the scripts' comments, and
   the `cells=`/`OK=`/`NODB=`/`NOSLANG=` assert line exists so a driver that
   reaches nothing can never read as perfection.

## 11. THE CORPUS, AND THE TWO MOVERS

| gate | result |
|---|---|
| surelog, base, both modes | **byte-identical to the committed `results/golden_surelog.csv`, 0 differing ROWS over 1588** (470/11/5/283/25 default, 466/9/5/3/1/284/23/1/2 testflags) |
| surelog, patched, both modes | **0 differing ROWS vs my own base AND vs the committed baseline**, status AND dump column |
| surelog byteverify, SELFCHECK=1 | selfcheck 0 movers over 956; **base vs patched: 2 MOVERS over 956 databases**, 0 only-in-A, 0 only-in-B |
| canaries.sh (surelog / u2r) | ok=52 changed=0 / ok=8 changed=0 |
| ctcan2.sh (surelog) | ok=58 changed=0 (unknown-patterns=1 = `2DFunctionArg`, the documented u2r-only expectation) |
| canaudit.sh | audited=29 UNCOVERED=0 FENCE-BREACH=0, self-tests live |
| byte pins | `SVSwitch 4842211c4030` ✓, `YosysVerx 6ccda350c24a` ✓, `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` byte-identical in both modes ✓ |

**BOTH MOVERS ARE NAMED AND ATTRIBUTED.**

* `default/Rggen` — **THE ONE THE PREDICTION CARRIED**, filed from the pristine
  databases before the patched sweep ran (§ 8).  76 cmp lines → 36.
* `default/Scoreboard` — **THE COIN, NOT THIS PATCH, and proved so.**  The
  standing brief already calls `Scoreboard/default` a ~50/50 coin; here is the
  measurement.  The **BASE** binary alone, on its own command line, produced
  **THREE distinct databases**: `be641696…` (the base sweep artifact),
  `93089c7a…` (base run 1) and `366f571b…` (base runs 2-7).  The PATCHED
  sweep's artifact is `93089c7a…` — **byte-identical to one the BASE binary
  produced by itself**, and four consecutive patched runs all landed on
  `366f571b…`, the base's other face.  The row's status and dump column are
  unchanged (`CMP_NOTEQUAL` / `SLANG_REJECT`), its head is unchanged (24 cmp
  lines / 1 head before and after), and the mover is order-blind.

The other six named rows are unchanged, head for head:

| row | mode | base | patched |
|---|---|---|---|
| SeqDriver | default / testflags | 24 / 24 | 24 / 24 |
| SimpleUVM | default / testflags | 24 / 24 | 24 / 24 |
| Scoreboard | default | 24 | 24 |
| MiniAmiq | default / testflags | 24 / 24 | 24 / 24 |
| BuildUVMPkg | default / testflags | 29 / 29 | 29 / 29 |
| Earlgrey_0_1 | default / testflags | 29 / 30 | 29 / 30 |
| **Rggen** | **default** | **76** | **36** |

(each 1 head; `Scoreboard/testflags` and `Rggen/testflags` are SKIP-NOFILE and
COUNTED — both are non-CMP rows with no slang database.)

## 12. WHAT THIS PASS DOES **NOT** CLAIM

* Rggen does **not** pass `uhdm-cmp`.  **NO CORPUS ROW WAS CONVERTED** in
  either corpus, in either mode, and `results/*.csv` was never written.
* The law is implemented for **gen-scope** localparams only.  Its module-body
  twin is measured, named and left (§ 7, R1).
* The census does not cover the DEF view's `named_begin` generate bodies; that
  slice was checked by hand in the dump instead (§ 10).

## 13. HOW TO REPRODUCE

```sh
git worktree add /tmp/wt_r10rgg10 66f9c73 && git apply /tmp/r10rgg10.patch   # in it
cmake -S /tmp/wt_r10rgg10 -B /tmp/r10rgg10_build_pat -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build /tmp/r10rgg10_build_pat -j 2
bash tools/probe/r10rgg10repro/build10.sh                       # the census tool
python3 tools/probe/r10rgg10repro/gen_gridb10.py /tmp/r10rgg10_gridb
bash    tools/probe/r10rgg10repro/run_grid10.sh /tmp/r10rgg10_gridb \
        /tmp/r10rgg10_base_bin /tmp/r10rgg10_gridbout
bash    tools/probe/r10rgg10repro/reours10.sh  /tmp/r10rgg10_gridb \
        /tmp/r10rgg10_pat_bin  /tmp/r10rgg10_gridbout pat
python3 tools/probe/r10rgg10repro/scorepat10.py /tmp/r10rgg10_gridbout
bash    tools/probe/r10rgg10repro/gates10.sh {gold|goldneg|u2r|sl} {base|pat}
bash    tools/probe/r10rgg10repro/rowheads.sh <workdir> <outdir> Rggen
```

---

## 14. VERIFIER CORRECTIONS (vrgg10, adversarial verification of this pass)

Every headline number above REPRODUCES bit-for-bit (both md5s, 76→36, the row
gates, the two movers, the prediction) — see `vrgg10/GATES.txt`.  Two claims in
this README are CORRECTED by measurement, and one production defect was found
and fixed before landing:

1. **§ 4's select rule was too wide and the shipped patch was WRONG where the
   PRISTINE BASE WAS RIGHT** on legal SV: inside a **user** function/task call
   argument, golden's rewrite fires only when the argument IS the select (or
   another such call).  `f8({4'h0,IV[3:0]})`, `f8(8'(IV[3:0]))`,
   `f8(IV[3:0]+1)`, `f8(~IV[3:0])`, `f8({2{IV[3:0]}})`,
   `f8(1'b1?IV[3:0]:4'h0)`, `h2(8'h0,{4'h0,IV[3:0]})`, `f8(g8({4'h0,IV[3:0]}))`
   are all golden-DECLARATION.  12 grid cells regressed.  Fixed by
   § genLpCallArgSelBlocks10v; see `vrgg10/VERIFIER.md` + `vrgg10/CALLARG_LAW.txt`.
2. **§ 4's stated reason for the `portcast` cell is REFUTED.**  It is not that
   "an EXPLICIT size cast is golden-LOCATED": `8'(IV[3:0])`,
   `8'({4'h0,IV[3:0]})` and `8'(f8(IV[3:0]))` are all golden-BARE.  The
   discriminator on a cast is BARE NAME vs SELECT, not the cast.
3. **§ 7's R1 is incomplete.**  "never its parameter overrides" holds for a bare
   name only: `#(.W(IV[3:0]))`, `#(.W({4'h0,IV[3:0]}))` and `#(.W(f8(IV[3:0])))`
   are golden-BARE.  So is an instance-array RANGE read, `sink u [IV[1:0]:0]`.
   Both are UNDER-fires (safe) and are named residues.
