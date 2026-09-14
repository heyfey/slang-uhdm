# r11u21 — a parameter that reads a member of an assembled struct parameter
# folds to that member's bit slice, and everything that depends on such a read
# loses its Rhs typespec

Base `11416eb7` (matrix-1.87).  Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.
ONE law, two arms.

**ONE TEST CONVERTS — say it plainly: `param_nested_struct_field_width` moves
`CMP_NOTEQUAL` -> `CMP_EQUAL` in BOTH modes.**  The committed baseline rows it
replaces are

```
results/gate_uhdm2rtlil.csv:557     param_nested_struct_field_width,testflags,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:557   param_nested_struct_field_width,default,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:1428  param_nested_struct_field_width,testflags,CMP_NOTEQUAL,decompile:,,
```

and this pass measures `param_nested_struct_field_width,<mode>,CMP_EQUAL,,,differ`
in both.  `results/*.csv` is UNTOUCHED by the patch; the promotion is the
integrator's to make.

It is the row the r11u20 landing named as its R0, and it is the **only** law
mover in either corpus: u2r byteverify reads 1 / 804 per mode, surelog reads
the proven UVM coin family and nothing else.

---

## 1. The head, RE-MEASURED at this base

Measured on this pass's own pristine build (md5
`e234b1297f348201f0cf9350691decc9`, byte-identical to the main tree at
`11416eb7`), official `uhdm-cmp`, LHS always golden, ONE head per run, both
modes identical (29 cmp lines / 1 head in each).

| side | object |
|---|---|
| golden (LHS) | `constant` at `36:37-36:40` — the span of the BASE NAME `CFG` alone — `vpiDecompile:00000000000000000000000000000011` (BARE), `vpiSize:32`, `BIN:…0011`, `vpiConstType:3`, a **NAMELESS** `ref_typespec` -> the struct MEMBER's own `int_typespec` at `7:5-7:17`, and NO `vpiParent` |
| ours (RHS) | `constant` at `36:37-36:51` — the span of the WHOLE read `CFG.u.sidWidth` — `vpiDecompile:3`, `vpiSize:32`, `UINT:3`, `vpiConstType:9`, a `ref_typespec` named `work@dut` -> the LOCALPARAM's own `int_typespec` at `36:16-36:19`, parented at the `param_assign` |

### It is NOT the row's last cell — the ladder says so, and names the rest

`ctladder` (`tools/probe/r10ladder1repro/ctladder.cpp`, MEASUREMENT-ONLY; the
official `uhdm-cmp` stays the judge) calibrates **0 rungs golden-vs-golden** on
this row and reads **3 rungs** against the pristine database, every one of them
in the ELABORATED module's `param_assign` list:

```
RUNG 1  constant@36:37 vs constant@36:37   FIELD=VpiDecompile  "…0011" vs "3"     <- SID_W  = CFG.u.sidWidth
RUNG 2  constant@37:37 vs hier_path(CFG.derived)  FIELD=VpiType                    <- DATA_W = CFG.derived
RUNG 3  <null> vs ref_typespec  FIELD=<lhs-null> on constant@38:37-39:51           <- NOUT   = CFG.u.dataWidth / CFG.u.sidWidth
```

and the whole-listing census (`pacen21.py`) adds the fourth, which rung 3's
cascade mask hid: `NLOG = $clog2(NOUT)` carries a `ref_typespec` golden does not
have.  **Four cells, one law** — §2 decodes it and §6 measures all four moving
together.

---

## 2. § paAsmMemberSliceFold21 — the producer and its key

`NetlistElaboration::elab_parameters_`
(Surelog v1.87 `src/DesignCompile/NetlistElaboration.cpp:513-575`) mints the
elaborated Rhs constant out of the instance's own VALUE for the parameter, and
for a parameter whose initializer READS A STRUCT-PARAMETER FIELD that Value is
what UHDM's `ExprEval::decodeHierPath` -> `hierarchicalSelector`
(`templates/ExprEval.cpp:2228-2402`) returned.  Its FIRST arm (~2331) is the one
that fires: the base is a CONSTANT carrying a `struct_typespec`, so the member is
sliced straight out of the packed bits —

```
VpiValue("BIN:" + mbits);  VpiDecompile(mbits);      <- BARE, no `<w>'b`
VpiSize(mbits.size());     VpiConstType(vpiBinaryConst);
Typespec -> ref_typespec -> THE MEMBER'S OWN typespec
```

FIRST DECLARED MEMBER OCCUPIES THE MSBs; a nested read recurses, so the offsets
simply add.  `CompileHelper::adjustSize`
(`src/DesignCompile/CompileHelper.cpp:4065-4218`) then re-renders that constant
against the **Lhs parameter's** typespec and at :4130 REPLACES its `ts` with the
constant's own — the member's — so only `VpiSize` (and, for a logic member, a
truncation) ever sees the Lhs width.

**The second arm is the same road's other answer.**  Every OTHER parameter whose
value depends on such a read — `CFG.derived + 1`, `$clog2(NOUT)`, a bit select of
a member — reduces to the value's plain encoding and carries **NO
`ref_typespec` at all**, where an untainted sibling in the same module carries
the parameter's own.  The dependence is TRANSITIVE.

This is the same producer arm § caAsmMemberSliceFold (r11u16) decoded for the
elaborated CONTINUOUS ASSIGNMENT; that law is a read-only input here and its two
converted rows are re-measured untouched (§5).

### The golden grid (Surelog v1.87, one arm per directory, every rc recorded)

`grid.sh` runs `surelog -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`, then
both binaries, then the official `uhdm-cmp`.  **Every arm below compiled
`slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.**  Cells are read by `pacen21.py`
(keyed on section x instance x the `param_assign` Lhs FULL name — never on a
span, never on an id; the full name is what keeps `u0.LA` and `u1.LA` apart).

| arm | shape | golden cell |
|---|---|---|
| `t1` | the corpus shape with the CONTROLS beside it | `M1` (`CFG.derived`, one level) and `M2` (`CFG.u.sidWidth`, nested) are BIN slices at the member width with a BARE ref -> the member's `int_typespec` and the span of `CFG` alone; `T1` (`CFG.derived + 1`) and `T2` (`$clog2(T1)`) keep their UINT value and carry **NO ts**; the untainted `C1` (`5`), `C2` (`C1+1`), `C3` (`$clog2(C1)`) all keep `(work@dut)` -> the Lhs `int_typespec` |
| `t2` | the base is a LITERAL (assignment-pattern) struct parameter | golden does **not** slice: `A1`/`B1` are plain `UINT` decimals WITH the Lhs typespec — the selector's constant arm never fires because the base's elaborated Rhs is an operation.  DECLINED; the arm is **byte-identical** pristine and patched |
| `t3` | the base OVERRIDDEN, and the read one instance down | `u0.LA` and `u1.LA` both slice, each out of THEIR OWN instance's assembled constant (`3` and `9`); `u0.LB`/`u1.LB` (`K.b + 1`) carry no ts |
| `t4` | the read in a PACKAGE localparam, through a WILDCARD IMPORT, and written QUALIFIED | the ELABORATED **package** listing does NOT reduce (`pk::PA` stays a `hier_path`, `pk::PB` an `operation`) — FENCED; the module's import copy `PA` and its own `MA` DO slice; `MB` (`pk::C.b`) takes the qualified road and keeps a `<w>'b` decompile — FENCED |
| `t5` | MEMBER TYPESPEC KINDS x WIDTH MISMATCH (10 cells) | `int unsigned` 32 under a 32-bit Lhs -> 32; `int` SIGNED -5 under a SIGNED Lhs -> `INT:-5` ct 7; `logic [7:0]` under a 32-bit Lhs -> size 8 UNCHANGED; `logic [39:0]` under 32 / 8 / 16-bit Lhs -> value AND decompile truncated to the LOW Lhs digits; `byte` -> 8, `bit` -> 1, enum -> 2, all UNCHANGED; `int unsigned` under a 64-bit Lhs -> 32, NOT widened |
| `t6` | the read as a type-parameter range bound, a net range, `$bits` | `SW = CFG.a` slices; the landed § typeParamDefaultBoundNoReduce18 cells (`sel_t`, `dir_t`) are untouched and stay CMP-agreeing |
| `t7` | a NON-local module parameter defaulted to a member read, plus an override | `u0.N`, `u0.M`, `u1.N` slice; `u1.M` is OVERRIDDEN and keeps the literal it already had |
| `t8` | a member written through a size cast of an untyped enum | intended as a bail; MEASURED NOT A BAIL — the assembler folds it and golden slices.  An extra positive arm, honestly relabelled |
| `t9` | **THE BAIL** — a function that writes NESTED members (`c.u.a = 3`), which our own package assembler does not reduce | golden slices, our base's elaborated Rhs is still a `func_call`, so the drain writes NOTHING: the arm is **byte-identical** pristine and patched |
| `t10` | the LHS side: UNTYPED localparam, `int unsigned` Lhs over a SIGNED member, generate-scope localparam | untyped Lhs -> `adjustSize` returns at its first line and the member width stands; `UU` (unsigned Lhs, signed member) is golden `INT:4294967291` and needs `adjustSize`'s `VpiSigned(false)` write onto the SHARED member typespec — DECLINED; `g.GA` in a generate scope takes the `<w>'b` road with a NAMED ref and a parent — FENCED |
| `t11` | TAINT PROPAGATION | `Y = X + 1` and `W = $clog2(Y)` reading the folded `X` carry NO ts — the taint is transitive; `Z = X` (a BARE reference to a folded parameter) inherits that constant's encoding AND a NAMED ref — the § asmEncFollowsRef shape, FENCED; the untainted `P`/`Q`/`R` are untouched |

---

## 3. Where it is implemented

* the RECORD (`src/ParamEmit.cpp`, at the top of `emitParameters`' per-parameter
  body, immediately after the elaborated `param_assign` is minted) — purely
  SYNTACTIC: the shape of the written initializer and the slang types it names.
  It sits there and not at the tail of the emit chain because several of the
  family's own arms `continue` out of the loop before the tail (measured: `u1.LA`
  of grid `t3` and both import copies of `t4` never reached a tail site);
* `UhdmExporter::drainPaAsmMemberSlice` + `paAsmBaseBits` (`src/ParamEmit.cpp`),
  called from `src/UhdmExporter.cpp` IMMEDIATELY AFTER `drainCaAsmMemberSlice()`
  and for the identical reason: that is where both assemble arms have applied the
  producer's own bail rule and the base's elaborated `param_assign` Rhs finally
  SAYS whether it assembled;
* the model, the fences and every measured witness are written at the
  `SrlgPaMemSel` declaration in `include/UhdmExporter.h`.

Two details the measurement forced:

* the drain MINTS A FRESH `ref_typespec` rather than re-pointing the one standing
  there: the generic fold's own ref is still in `pendingParamTs`, and
  `patchParamTypespecs` rebinds its Actual long after this drain — grid `t1`'s
  `M2` came out pointing at the LOCALPARAM's `int_typespec` when the existing ref
  was reused;
* a ONE-LEVEL read is still the symbolic `hier_path` the elab fold gate keeps
  (`src/ParamEmit.cpp`, the "an init reading a struct-param MEMBER keeps the
  hier_path" carve-out), so the drain replaces the Rhs there and MUTATES it where
  a nested read already folded to a constant.  Nothing is minted until the write
  is certain.

---

## 4. The mover set, PREDICTED BY NAME BEFORE THE PATCHED DATABASES WERE READ

`predL1_21.py` (L1, SOURCE-keyed — nothing in a database records that an
initializer was WRITTEN as a member read once the elaborated view folded it) and
`predL2_21.py` (L2, PRISTINE-DATABASE-keyed, with a POSITIVE CONTROL).

**L2's signature**, read off PRISTINE databases only: some `param_assign` Rhs is
a `BIN:` constant whose typespec Actual is a `struct_typespec` (the assembled
function-built struct parameter this family folds off), AND somewhere in the same
database a `hier_path` is named `<that parameter>.` .

* **u2r L2 predicted (14 names x 2 modes):** `param_nested_struct_field_width`,
  `struct_param_func_arg`, `struct_param_func_loop`, `struct_param_func_config`,
  `struct_param_field_shift`, `struct_param_pattern_packing`,
  `def_ctx_struct_param`, `latch_decoder_partial`, `latch_tlb_napot`,
  `portsel_struct_param`, `ff_dead_guarded_reset`, `ff_dead_both_branches`,
  `StructLocalParam`, `StructParameter`.  Nothing SKIPPED: all 1742 databases read.
* **surelog L2 predicted (5 names x 2 modes):** `FuncStructValSimple`,
  `StructParamPatternInitCast`, `ParamSubstituteComplex`,
  `GenForStructParamBound`, `NoReducTypespec`.  One database exceeded the
  detector's dump budget on the first run (`Earlgrey_0_1`/testflags) and was
  RE-READ with the budget lifted: it reports NOTHING, so the surelog list is
  complete.
* **L1 predicted** (deliberate supersets): 22 u2r directories and 45 surelog
  ones (25 under `Surelog/tests`, 20 under `Surelog/third_party/tests`), listed by running the script.
* **L2 POSITIVE CONTROL:** the same detector run over grid arm `t1`'s PRISTINE
  database reports `t1 <- CFG`.  A census zero from this detector is therefore a
  reading, not a silence.

Measured (`byteverify.sh SELFCHECK=1`, `tools/probe/r10oth4repro/byteverify.sh`,
patched vs this pass's OWN pristine workdirs):

* **u2r testflags: MOVERS 1 / 804**, selfcheck 803/804 —
  `param_nested_struct_field_width`.
* **u2r default: MOVERS 1 / 804**, selfcheck 803/804 — the same row.
  **Zero unpredicted movers.**
* **surelog: MOVERS 5 / 960**, selfcheck 959/960 — `MiniAmiq` x 2 modes,
  `SeqDriver` x 2 modes and `Scoreboard`/default: the PROVEN UVM COIN FAMILY and
  nothing else.  **No law mover on the surelog corpus at all.**

### Why 13 of the 14 predicted u2r names did not move, measured not asserted

L2 is keyed on "an assembled base ANYWHERE plus a member read ANYWHERE"; this law
owns only the reads that ARE the initializer of an elaborated `param_assign` in a
MODULE view.  Counting member reads inside parameter declarations over each
predicted test's sources:

```
param_nested_struct_field_width  3      every other predicted u2r name  0
```

The other thirteen read struct members in continuous assignments (§
caAsmMemberSliceFold's own territory, landed at pass 15), in port widths, or in
override actuals.

### Why none of the 5 predicted surelog names moved

* `FuncStructValSimple` — its three member-read parameter declarations are all
  COMMENTED OUT;
* `StructParamPatternInitCast`, `GenForStructParamBound` — no member read in any
  parameter declaration at all;
* `NoReducTypespec` (`parameter DEBUG = Cfg.NoSlvPorts`) and
  `ParamSubstituteComplex` (`parameter fmt_logic_t FpFmtMask = Features.FpFmtMask`)
  DO carry one, and the drain DECLINED both — their bases are not the
  member-by-member-const-function family, so the base's elaborated Rhs is not the
  assembled BIN of exactly the struct's packed width.  Both rows are CMP_EQUAL at
  pristine and golden's answer for `FpFmtMask` is the `<w>'b`-prefixed
  re-render (`5'b11000`), which an ungated law would have taken AWAY from golden.
  The family gate is what kept them.

### Coin attribution, ORDER-BLIND + POSITIVE CONTROL

Sorted, path-normalised `uhdm-dump`s of the five surelog movers:
`Scoreboard`/default **0** lines (a pure order flip); `MiniAmiq`/default,
`MiniAmiq`/testflags, `SeqDriver`/default and `SeqDriver`/testflags **4** lines
each, and each is one `UINT:<n>` plus its `vpiDecompile` — the line-number class.

POSITIVE CONTROL: the PRISTINE binary re-run three times on `MiniAmiq`/default
gives three DIFFERENT databases (`f5e6c567d76d`, `131fadd8d4d0`, `71c240ca493b`),
none equal to its own sweep hash (`e9183812b66f`).  Pinned by NAME and by the coin
CLASS, never by the count.

---

## 5. The directional census, and the shape lister beside it

Keyed directional census (`dircen21.py` over `pacen21.py`'s cells: `kind`,
`VpiDecompile`, `VpiSize`, `VpiConstType`, the value tag, and the Rhs
`ref_typespec`'s name and Actual — the judge-visible set, never a span, never an
id), golden vs pristine vs patched:

```
t1  SAME=16 TO=4  AWAY=0 MW=0 SW=0      t7   SAME=8  TO=3  AWAY=0 MW=0 SW=0
t2  SAME=12 TO=0  AWAY=0 MW=0 SW=2      t8   SAME=5  TO=1  AWAY=0 MW=0 SW=0
t3  SAME=9  TO=4  AWAY=0 MW=0 SW=0      t9   SAME=4  TO=0  AWAY=0 MW=0 SW=6
t4  SAME=9  TO=3  AWAY=0 MW=0 SW=4      t10  SAME=9  TO=3  AWAY=0 MW=0 SW=2
t5  SAME=14 TO=10 AWAY=0 MW=0 SW=0      t11  SAME=13 TO=3  AWAY=0 MW=0 SW=2
t6  SAME=6  TO=1  AWAY=0 MW=0 SW=1
```

**TO-GOLDEN 32, AWAY-GOLDEN 0, MOVED-WRONG 0 over the whole grid.**  The
`MOVED-WRONG` column earned its place: the first gated form left grid `t4`'s
`MB` (`pk::C.b`) moved onto a DIFFERENT wrong answer — every cell right except
the `<w>'b` decompile — and that measurement is what added the qualified-read
fence (slang spells both `a.b` and `a::b` as a `ScopedName`; only the separator
TOKEN tells them apart).

Per-row on the corpus mover (`rowcen21.sh`, against the row's OWN golden read out
of its `cmds.txt`):

| row | mode | result |
|---|---|---|
| `param_nested_struct_field_width` | testflags | SAME=10 **TO-GOLDEN=4 AWAY-GOLDEN=0 MOVED-WRONG=0 STILL-WRONG=0** |
| `param_nested_struct_field_width` | default | SAME=10 **TO-GOLDEN=4 AWAY-GOLDEN=0 MOVED-WRONG=0 STILL-WRONG=0** |

All fourteen `param_assign` cells of that row now match golden.

**SHAPE LISTER** (`shapes21.py`, the Rhs operand TREE to depth 3, beside the
cell census — a shape change that kept every cell would be invisible to the
census, and a cell change out of a different tree would be attributed wrong):

* patched vs GOLDEN on the converting row: **14 of 14 cells SAME**;
* patched vs PRISTINE: **exactly one shape moved** —
  `topModules work@dut.DATA_W  hier_path(ref_obj,ref_obj) -> constant`, the
  one-level read the elab fold gate kept symbolic.  The DEFINITION listing keeps
  its symbolic tree on both binaries, as golden does.

Scoreboard, both corpora, both modes:

| corpus | mode | pristine | patched |
|---|---|---|---|
| uhdm2rtlil | default | 764 / 40 / 67 | **765 / 39** / 67 |
| uhdm2rtlil | testflags | 764 / 40 / 67 | **765 / 39** / 67 |
| Surelog suite | default | 468 / 15 | 468 / 15 |
| Surelog suite | testflags | 464 / 13 | 464 / 13 |

---

## 6. Head movement on the target

| test | pristine head | patched head |
|---|---|---|
| `param_nested_struct_field_width` | `constant` at `36:37`, `UINT:3` ct 9 where golden has the `BIN:…0011` member slice (29 cmp lines, 1 head) | **CLEARED — 0 heads, 0 cmp lines, CMP_EQUAL in BOTH modes.  THE TEST CONVERTS.** |
| grid `t1` (the corpus shape plus its controls) | 1 head, 29 lines | **0 heads, CMP_EQUAL** |
| grid `t7` (a non-local parameter defaulted to a member read) | 1 head, 29 lines | **0 heads, CMP_EQUAL** |

All four of the row's cells moved together: `SID_W` and `DATA_W` to the member
slice, `NOUT` and `NLOG` by losing the `ref_typespec` golden does not carry.

---

## 7. Gates

| gate | result |
|---|---|
| pristine build md5 vs the main tree at `11416eb7` | `e234b1297f348201f0cf9350691decc9` — BYTE-IDENTICAL (the value the brief pins) |
| patched build md5 (this pass as submitted) | `342c26732c9fb64b02ccb31a63de9b4c` |
| patched build md5 (LANDED — carries the verifier's ARM TWO gate, § paAsmMemberSliceFold21v, `tools/probe/r11v21repro/README.md`) | `9403ed4f946e712e06fb707697e6e18c` |
| `tests/check_goldens.sh` (patched) | 23 PASS / 0 FAIL |
| `SLANG_UHDM=/bin/false` negative control | 0 PASS / 23 FAIL |
| u2r testflags vs `results/gate_uhdm2rtlil.csv` | ONE row differs and it is the CONVERSION, quoted in full at the top |
| u2r both modes vs `results/golden_uhdm2rtlil.csv` | TWO rows differ, the same conversion in each mode, quoted |
| u2r patched vs this pass's own pristine sweep, both modes | the same single row in each mode |
| u2r scoreboard | 764 / 40 / 67 pristine -> **765 / 39 / 67** patched, both modes |
| surelog patched | 468/15 default + 464/13 testflags — identical to this pass's pristine sweep AND to the committed baseline |
| surelog vs `results/golden_surelog.csv` and vs own pristine | 2 rows differ, BOTH only in the WORKDIR PATH inside a `SURELOG_FAIL` detail string (`LowMemLib`, `LowMemPkg`); 0 status moves, 0 dump-column moves |
| `byteverify SELFCHECK=1` u2r | 1 / 804 in EACH mode, selfcheck 803/804, the name predicted a priori, every moved cell TO-GOLDEN |
| `byteverify SELFCHECK=1` surelog | 5 / 960, selfcheck 959/960 — the proven coin family alone, attributed order-blind with a positive control |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS (ok=58 changed=0) / PASS (ok=1 changed=0) |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| HARD byte pins | `SVSwitch` `4842211c4030`, `YosysVerx` `6ccda350c24a` — both modes, both binaries |
| STATUS pins | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` (`e3e354129d5a` default / `73a10e8217e5` testflags), `YosysOldOr` `d68e0796d62c` — byte-identical pristine vs patched, both modes |
| `rowheads.sh` on the UVM / Earlgrey / Rggen rows | IDENTICAL pristine vs patched (12 measured, 2 SKIP-NOFILE as expected) |
| every `cmds.txt` audited BY BINARY PATH | 1531 + 871 + 871 pristine rows name the frozen pristine binary, 1531 + 871 + 871 patched rows name the frozen patched one, and NOTHING names any other `slang-uhdm` |
| grid arms | 11 arms, every one `slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0` |
| fence check (the four slang-fenced tests) | 0 hits in the production diff; 0 hits in `tools/probe/r11u21repro/`; no driver dispatches them |
| `results/*.csv` | UNTOUCHED |
| patch applies clean on a FRESH `11416eb7` worktree | yes, 0 conflicts, 0 `<<<<<<<` markers, and the committed source REBUILDS to the patched md5 |

---

## 8. Residues

* **R0 — a read of a member of a struct parameter the assembler did NOT build.**
  Grid `t9`: a package function that writes NESTED members (`c.u.a = 3`) leaves
  OUR package localparam's elaborated Rhs a `func_call` (golden: the assembled
  96-bit BIN), so every member read of it declines and the row's five cells stay
  wrong.  This is the § pkgStructFuncAssembleBin assembler's own gap, one level
  below this law, and it is the ready-made witness.
* **R1 — a member read written QUALIFIED (`pk::C.b`).**  Grid `t4` `MB`: golden
  answers it out of `CompileHelper::getValue`'s `name contains "::"` branch and
  renders the `<w>'b`-prefixed decompile with a NAMED ref and a parent; the bare
  read keeps the selector's own bare digits at the BASE NAME's span.  Fenced with
  the measurement; the two roads differ in exactly one judge-visible cell.
* **R2 — a member read held by a GENERATE-SCOPE localparam.**  Grid `t10` `g.GA`:
  golden `32'b…0011` ct 3 with a ref named `work@dut.g` and a parent, at the
  WHOLE read's span.  Same cells as R1, a different holder.  Fenced.
* **R3 — a SIGNED int member read into an UNSIGNED Lhs.**  Grid `t10` `UU`:
  `adjustSize` writes `VpiSigned(false)` onto the SHARED member `int_typespec`
  (CompileHelper.cpp:4130) and `int_typespec::Compare` reads `VpiSigned`, so the
  cell cannot be had without mutating a typespec other objects point at.
  Declined exactly as § caAsmMemberSliceFold declines it.
* **R4 — a BARE reference to a parameter this law folded.**  Grid `t11` `Z = X`:
  golden inherits the folded constant's BIN encoding and gives the ref a NAME —
  the § asmEncFollowsRef shape one level out, not this one.  Fenced.
* **R5 — the ELABORATED PACKAGE listing does not reduce a member read at all.**
  Grid `t4`: golden keeps `pk::PA`'s `hier_path` and `pk::PB`'s `operation` where
  we fold both.  `PA` already agreed; `PB` is a pre-existing fold this pass does
  not touch.
* **R6 — a LITERAL-pattern struct base.**  Grid `t2`: golden answers `P.derived`
  as a plain `UINT` at the Lhs width WITH the Lhs typespec (the selector's
  constant arm never fires), and we answer `UINT` at the struct width with none.
  Untouched, byte-identical.
* **R7 — the span and the parent of the second arm's constant.**  Golden's
  `T1`-shaped constant is LOCATION-LESS with a parent and its `T2`-shaped one
  carries the whole-expression span with none; we keep our own span and parent on
  both.  Judge-invisible (no generated `Compare` reads `VpiParent`, `VpiFile` or
  the line/column) — a dump residue only.

**R0 for the next pass: a package localparam built by a const function that
writes NESTED struct members (`c.u.a = 3; c.u.b = 32;`) is not assembled by
§ pkgStructFuncAssembleBin — golden's elaborated Rhs is the packed BIN at the
full struct width, ours is still the `func_call`, and every member read of such a
parameter then declines.  Grid arm `t9` is the ready-made witness and its five
golden cells are tabulated by `pacen21.py t9/gold.dump`.**

---

## 9. Files

| file | what it is |
|---|---|
| `grid.sh` | the golden grid runner: Surelog v1.87 + both binaries + official `uhdm-cmp` per arm, every rc recorded |
| `t1`–`t11` | the grid arms (§2); `t2` and `t9` are the DECLINE/BAIL arms and must stay byte-identical |
| `pacen21.py` | the KEYED cell census of every elaborated/definition `param_assign` Rhs, keyed on section x instance x Lhs FULL name |
| `dircen21.py` | the DIRECTIONAL census over those cells (TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG) |
| `rowcen21.sh` | `dircen21.py` on named SWEEP rows against each row's own golden, read out of its `cmds.txt` |
| `shapes21.py` | the SHAPE LISTER — the Rhs operand tree beside the cell census |
| `predL1_21.py`, `predL2_21.py` | the a-priori mover predictions (source-keyed L1, pristine-database-keyed L2 with a positive control) |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canary battery that RUNS here |
