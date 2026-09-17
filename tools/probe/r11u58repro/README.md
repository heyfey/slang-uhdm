# r11u58 — ROAD D decoded: the elaborated PACKAGE pattern's member-width stamp

Base commit `cfcaecd5` (v1.87 pass 56).  Pins per `SUPPORT_MATRIX.md`: slang
upstream-master `7d61e0ad1`, UHDM v1.87, Surelog v1.87
(`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil corpus v0.68.  Every
golden in this directory is a real Surelog v1.87 run and every arm records
`golden_rc` AND `ours_rc` (`rc58.txt`).

**Road D lands, gated on the READ, with the producer's own BAIL.**  The r11u54
pair refuted the brief's view-only reading (a build that stamped on the view
alone moved eighteen equal rows away) and left one open question: the
const-function read is NECESSARY (`wd2` vs `wd3`) and, they measured, NOT
SUFFICIENT, because `FuncStructVal` has that exact shape and golden leaves its
elements at the compiled sizes.  **That last clause is refuted here.**
`FuncStructVal` IS in the flipped state — its elaborated `cva6_config_pkg::cva6_cfg`
reads `XLEN` 32, `NrCommitPorts` 32 … `TvalEn` **1** against a definition
listing that reads 64 for every one of them — and it stops partway through,
because the producer's per-operand walk RETURNS at the first member wider than
64 bits.  The missing conjunct was never a property of the design; it is the
loop's own exit.

---

## 1. The witness, re-measured at the base

Frozen pristine binary `/tmp/r11u58_pris.bin`, md5
`2fa585e9ec9f6ccea23c8fee77b6fa7f` — byte-identical to the main tree at
`cfcaecd5`.  Patched `/tmp/r11u58_pat.bin`, md5
`8e6071209329cff27b3589297d32d1fd`.  Both `chmod 555` before any sweep.

`StructParamFuncBodyFieldCompare` (surelog, `CMP_NOTEQUAL` in both modes at the
base, detail `decompile:`), head by the official `uhdm-cmp`:

```
LHS (golden, ELABORATED package)          RHS (ours, pristine)
constant: , line:30:23                    constant: , line:30:23
|vpiParent: \_operation: 29:32..32:37     |vpiParent: \_sys_func_call: ($unsigned)
|vpiDecompile:64                          |vpiDecompile:64
|vpiSize:32                               |vpiSize:64
|UINT:64 |vpiConstType:9                  |UINT:64 |vpiConstType:9
```

`expr::Compare` reads `VpiDecompile` then `VpiSize`, so the judged failure is
the SIZE, 32 against 64, on the elaborated package copy of `cfg_pkg::Base`.
The whole elaborated cell table (SHAPE LISTER `sz58.py`, member widths from
`user_cfg_t`):

| element | member | golden DEF | golden ELAB | ours (pristine) |
|---|---|---|---|---|
| `XLEN: unsigned'(64)` | `int unsigned` (32) | 64 | **32** | 64 |
| `NrRules: unsigned'(2)` | `int unsigned` (32) | 64 | **32** | 64 |
| `Length: 1024'({64'b0,64'b0})` | `logic [15:0][63:0]` (1024) | no size | **vpiSize:1024** | no size |

Order-blind whole-dump residue against the row's own golden: **345 golden-only
/ 339 ours-only**, reproducing r11u54's reading exactly.

**ARITHMETIC, PREDICTED LOUDLY BEFORE THE BUILD: ADVANCE, NOT CONVERT.**  Three
cells is the whole of road D on this row.  Behind them stand the C3 family
(the anonymous `localparam type it_t = struct packed {…}`, whose
`struct_typespec` golden spans `42:26..42:32` unnamed while ours carries two
spans) and road E at module scope (the `Cfg.XLEN` hier_paths inside the `INT`
localparam).  345/339 does not go to 0/0 by fixing three sizes.

---

## 2. The producer, decoded line by line

### 2a. The call that does it

`CompileHelper::getValue` (`Surelog/src/DesignCompile/CompileExpression.cpp:871`)
takes a `::`-qualified name down its PACKAGE arm (`:884` splits on `"::"`,
`:889` resolves the `Package`).  At `:921-952` it walks that package's OWN
`param_assign` vector and, for a `vpiAssignmentPatternOp` Rhs:

```cpp
    rhs = expandPatternAssignment(ts, (expr *)rhs, component,
                                  compileDesign, instance);     // :941
    param->Rhs(rhs);
    reorderAssignmentPattern(component, lhs, rhs, compileDesign, instance, 0);
```

`ts` is the package parameter's own Lhs typespec.  `param` is the ELABORATED
package's `param_assign` (`FunctorCompilePackage::operator()`,
`CompilePackage.cpp:61-71`, compiles `Reduce::Yes` into `uhdmtopPackages` and
the un-elab copy into `uhdmallPackages`), so this writes into the very listing
road D's head lives in — and never into the definition listing, which is a
different object.  Measured: `wd2`/`wd3`/the witness all have DEF = 64/64/no
size on both sides, unchanged by everything below.

**A CORRECTION TO THE r11u54 READING.**  That README says
`substituteAssignedValue` refuses a pattern "unless `-parametersubstitution` is
given, which our sweeps never pass".  The polarity is the other way round:
`CommandLineParser.cpp:387` initialises `m_parametersubstitution(**true**)`, and
only `--disable-feature=parametersubstitution` (`:977`) clears it.  So the guard
at `:927` PASSES by default and `:941` runs.  (Road B's landed law is unaffected
— it is a measured law and §4 of that README says so.)

**AND THE SITE IS PROVED, NOT CORRELATED.**  Run `wd3` a second time with
`--disable-feature=parametersubstitution` and NOTHING ELSE changed
(`golden_rc=0`, `gold.nosub.dump`): golden's elaborated listing reverts to
`A=64 B=64 C=64 D=32 E=64 L=no size` — `wd2`'s answer, cell for cell.  The only
code that flag reaches is `substituteAssignedValue`'s `substitute` at
`CompileExpression.cpp:93`, i.e. the guard on `:941`.  That is a source-level
switch for the whole law, and it is the positive control the producer decode
needs.

### 2b. What `expandPatternAssignment` writes, and where

`CompileHelper::expandPatternAssignment` (`CompileHelper.cpp:5207`):

1. `rhs = eval.flattenPatternAssignments(s, tps, rhs);` (`:5234`).  UHDM
   `templates/ExprEval.cpp:751` CLONES the operation (`opres`) but **shares the
   element objects** — `recursiveFlattening` pushes each `tagged_pattern`'s own
   `Pattern()` — and then does `for (auto o : *flattened) o->VpiParent(opres);`.
   That is the "re-parented to the pattern operation" the brief reports, and it
   is judge-invisible (no generated `Compare` reads `VpiParent`).
2. Because the CLONE's operand list is untagged, the `taggedPattern` test at
   `:5253` answers NO and the POSITIONAL arm at `:5404` runs.  For each operand:

   ```cpp
   expr* vexp = reduceExpr(cop, invalidValue, …);
   uint64_t v  = eval.get_uvalue(invalidValue, vexp);
   int32_t csize = adjustOpSize(tps, cop, opIndex, rhs, …);
   if (invalidValue) { return result; }
   patternSize += csize;
   for (int32_t i = 0; i < csize; i++) {
     if (valIndex > (int32_t)(size - 1)) break;
     int shift = (csize - 1 - i);
     if (shift < 0 || shift >= 64) { return result; }      // <<<< THE BAIL
     …
   }
   ```
3. `CompileHelper::adjustOpSize` (`:5114`), struct arm, walks `stps->Members()`
   to `opIndex` and does

   ```cpp
   int32_t ncsize = Bits(mtps, …);          // the MEMBER's own width
   adjustUnsized(any_cast<constant*>(cop), ncsize);
   cop->VpiSize(ncsize);                    // IN PLACE, on the SHARED element
   ```

   `adjustUnsized` (`:5091`) acts only on an UNSIZED `'1`/`'0` (`VpiSize()==-1`),
   so an ordinary element keeps its value, its `vpiDecompile` and its
   `vpiConstType`: **`VpiSize` is the only field written**, which is why the
   judged head is a size and nothing else.
4. `expandPatternAssignment` RETURNS its original `result`, so the package's own
   listing keeps whatever shape it had.  The TAGS survive when
   `ExprEval::getValue`'s separate write-back (`templates/ExprEval.cpp:337-347`,
   gated on `op->Typespec()`) is refused — the SYMBOLIC-MEMBER-DIM case, which
   is `wd3`'s, `FuncStructVal`'s and the witness's.

**So the stamp and the flatten are two effects of ONE read.**  The flatten needs
the pattern op to carry a typespec; the stamp does not.

### 2c. THE BAIL is the missing conjunct

`shift = csize - 1 - i` with `i == 0` is `csize - 1`, so `csize >= 65` returns
on the FIRST iteration — *after* `adjustOpSize` has already stamped that
operand.  **The first element whose member is wider than 64 bits is stamped and
then ends the walk; every element after it keeps its compiled size.**

`FuncStructVal` is that arm in the corpus and it is decisive.  Members in order:
… `DmBaseAddress` (64), `TvalEn` (`bit`, 1), `NrPMPEntries` (32),
**`PMPCfgRstVal` (`logic [15:0][63:0]`, 1024)**, `PMPAddrRstVal`,
`PMPEntryReadOnly`, `NOCType`, `NrNonIdempotentRules` (32) …  Golden, DEF
against ELAB, `sz58.py` on one Surelog v1.87 run with the test's own `.sl`
flags:

| element | member | golden DEF | golden ELAB |
|---|---|---|---|
| `XLEN: unsigned'(CVA6ConfigXlen)` | 32 | 64 | **32** |
| `NrCommitPorts` … `NrLoadBufEntries` | 32 | 64 | **32** |
| `HaltAddress: 64'h800` | 64 | 64 | 64 |
| `TvalEn: unsigned'(CVA6ConfigTvalEn)` | `bit` 1 | 64 | **1** |
| `NrPMPEntries: unsigned'(…)` | 32 | 64 | **32** |
| **`PMPCfgRstVal: {16{64'h0}}`** | **1024** | 1024 | 1024 — **the walk returns here** |
| `NrNonIdempotentRules: unsigned'(2)` | 32 | 64 | **64** |
| `NrExecuteRegionRules: unsigned'(3)` | 32 | 64 | **64** |
| `NrCachedRegionRules: unsigned'(1)` | 32 | 64 | **64** |
| `MaxOutstandingStores: unsigned'(7)` | 32 | 64 | **64** |
| the four `1024'({…})` cast ops | 1024 | no size | **no size** |

Those last five rows are exactly the cells the landed `§ patElabUintResize`
comment in `src/ParamEmit.cpp` reads as "a LITERAL element keeps its 64 …
`NrNonIdempotentRules: unsigned'(2)` and its three siblings in FuncStructVal",
and calls "a second, unfound condition".  **They are not literals-versus-
references.  They are AFTER THE BAIL.**  (`HaltAddress: 64'h800` is a literal
BEFORE the bail and it is at its member width; the old gate could not see the
difference because a 64-bit member's compiled size already equals its width.)

---

## 3. The golden grid

Runner `run54.sh` inherited unmodified from r11u54; SHAPE LISTER `sz58.py`
(element-by-element `vpiSize` per listing section) with `shape54.py` under it;
residues by `armdiff58.sh`, newly-unmatched sets by `armdelta58.sh`.  Every
`xd*` arm is new and every one compiled `golden_rc=0 ours_rc=0` (`rc58.txt`).

### 3a. THE BAIL, PREDICTED BEFORE IT WAS RUN — `xd1`

`xd1_bail_width` is `wd3`'s reader over members `A`(32) `W`(**128**) `B`(32)
`D`(8) `F`(16), with the wide member in the MIDDLE.  The prediction written
into the arm's header before the run: *A stamped to 32, W stamped to 128, and
B / D / F keep their compiled 64 / 32 / 8.*

| cell | compiled (DEF) | golden ELAB | ours pristine | ours patched |
|---|---|---|---|---|
| `A: 64` → `int unsigned` | 64 | **32** | 64 | **32** ✓ |
| `W: 128'({64'b0,64'b0})` → `logic[127:0]` | no size | **128** | no size | **128** ✓ |
| `B: unsigned'(64)` → `int unsigned` | 64 | **64** | 64 | 64 ✓ |
| `D: 32'(5)` → `logic[7:0]` | 32 | **32** | 32 | 32 ✓ |
| `F: 8'(3)` → `logic[15:0]` | 8 | **8** | 8 | 8 ✓ |

### 3b. THE WIDTHS, both directions — `xd5` (r11u51 V4's `vd1`, re-cut inside the flipped state)

| cell | member | golden DEF | golden ELAB | pristine | patched |
|---|---|---|---|---|---|
| `A: 64` | `logic [7:0]` | 64 | **8** | 64 | **8** ✓ |
| `B: 64` | `logic [15:0]` | 64 | **16** | 64 | **16** ✓ |
| `C: 32'd7` | `logic [63:0]` | 32 | **64 (WIDENS)** | 32 | **64** ✓ |
| `D: 64` | `int unsigned` | 64 | **32** | 64 | **32** ✓ |
| `W: 128'({…})` | `logic [127:0]` | no size | **128** | no size | **128** ✓ |

`vpiDecompile:32'd7` / `DEC:7` / `vpiConstType:1` survive the widening on both
sides — `adjustUnsized` writes nothing for a sized constant.  **V4's law holds
inside the flipped state, unchanged.**

### 3c. WHICH READ triggers — `xd4`, `xd8`, `xd6`

Five identical package pattern localparams per arm, one reader kind each.

"stamped" on our side means the element sizes now equal golden's; where golden
also FLATTENS we still emit the tagged tree (R0 in §7), so those rows are
scored TOWARD-golden on the cells and unchanged on the shape.

| arm/cell | the only reader | golden ELAB | patched |
|---|---|---|---|
| `xd8` `S1` | call arg in a module PARAMETER PORT default | flat + **stamped** | stamped (tagged) |
| `xd8` `S2` | call arg in a module body LOCALPARAM | flat + **stamped** | stamped (tagged) |
| `xd8` `S5` | call arg in an instance `#(…)` OVERRIDE actual | flat + **stamped** | stamped (tagged) |
| `xd8` `S3` | the same call in a `cont_assign` | tagged, **compiled sizes** | unmoved ✓ |
| `xd8` `S4` | the same call in an `always_comb` | tagged, **compiled sizes** | unmoved ✓ |
| `xd4` `R3` | call arg in the parameter's OWN package, UNQUALIFIED | tagged, **compiled sizes** | unmoved ✓ |
| `xd4` `R4` | a whole read as a module localparam initialiser | tagged, **compiled sizes** | unmoved ✓ |
| `xd4` `R5` | only `pk::R5.A`, a MEMBER SELECT | flat + **stamped** | unmoved (residue §7) |
| `xd6` `P1` | a whole read as a module parameter default | tagged, **compiled sizes** | unmoved ✓ |
| `xd6` `P2` | only `pk::P2.A`, a MEMBER SELECT | flat + **stamped** | unmoved (residue §7) |
| `xd6` `P3` | **NOBODY** | tagged, **compiled sizes** | unmoved ✓ |

So the read must be QUALIFIED (it is the `::` arm at `CompileExpression.cpp:884`
that owns `:941`) and must stand in a PARAMETER context.  `xd6` is the
must-not-move control: golden's elaborated listing there equals its definition
listing cell for cell, and the patched binary leaves all three parameters alone.

### 3d. THE NON-CONSTANT operand is NOT a second bail — `xd2` / `xd2b`

Both arms put an ENUM reference element in the middle (`xd2b` declares the enum
package AFTER the reader, FuncStructVal's own forward-reference face).  Golden
stamps straight through it: `xd2b`'s `N` comes out a `ref_obj (pk::pq::EA)`
carrying **`vpiSize:2`** — its member's width — and `B`/`D`/`F` after it are
stamped too.  `reduceExpr` resolves the reference, so `invalidValue` stays
false and `:5404`'s `if (invalidValue) return result;` never fires.  **Recorded
as a refuted candidate, not dressed up:** the width bail is the only exit this
grid could make fire, and `FuncStructVal`'s cut is at `PMPCfgRstVal` (1024),
three members before its `NOCType` ref.

### 3e. The arms that must not move, and do not

`wd2_tagged_wrapkinds` (r11u54's own counter-arm: six wrapper kinds, no
const-function read — golden keeps every compiled size and our pristine already
matched all six), `vd1_pattern_width`, `wd1_member_kinds`, `xd6`: **byte-
identical between the two binaries**, id- and path-normalised, the only differing
line being `uhdm-dump`'s own header naming the file.

---

## 4. THE LAW — § pkgElabPatMemberStamp58

> In the ELABORATED PACKAGE listing, a struct-pattern parameter whose
> package-qualified name `pkg::NAME` is written as an ARGUMENT OF A CALL inside
> a PARAMETER context (a parameter port default, a body localparam, or an
> instance `#(…)` override actual) has each pattern element's `VpiSize`
> re-stamped to THAT MEMBER's bit width, in both directions, with the value,
> the `vpiDecompile` and the `vpiConstType` untouched — and a non-constant
> element (a cast operation) takes the stamp too.  The walk runs in MEMBER
> DECLARATION order and STOPS, after stamping it, at the first member wider
> than 64 bits; every element after that keeps its compiled size.  A pattern
> that does not name every member the walk reaches stamps nothing (the
> producer's `flattenPatternAssignments` returns the original on an unmatched
> field, and its untagged arm — the only caller of `adjustOpSize` — then never
> runs; the code checks presence over exactly the members the walk visits, and
> a `default:` element makes the check fail outright).  The DEFINITION listing is
> never touched, and neither is a parameter read only unqualified, read only as
> a whole initialiser, read only from a `cont_assign` or an `always_comb`, or
> not read at all.

One production site, `src/ParamEmit.cpp`, inside `emitParameters`' elaborated
package arm and immediately after the landed `§ patElabUintResize` block whose
open question it answers; one predicate, `pkgPatCallArgParam58` in
`src/TypeEmit.cpp`, one syntax walk in the shape of `hasScopedPkgRef`'s.  The
producer citation, the bail, the grid and the residues are in the comment above
the site.  The landed `§ patElabUintResize` block is left EXACTLY as it was —
its masking arm and its reference gate still run first, and where both apply
they compute the same width.

---

## 5. Census, movers predicted BY NAME, and the positive control

`pred58.py` is the a-priori prediction, run BEFORE the patched sweeps: a package
parameter whose Rhs is `'{…}` whose name is written as `pkg::NAME` inside a call
inside a parameter context, over both corpora, following `project.f` filelists.
It is a deliberate SUPERSET of the compiled gate (it does not check PACKED,
STRUCTURED, or that our exporter keeps the tagged tree).  **Nine directories:**

```
surelog     FuncStructVal                    cva6_config_pkg::cva6_cfg
surelog     FuncStructValSimple              cva6_config_pkg::cva6_cfg
surelog     ParamNoImport                    pkg::PWR_AST_RSP_DEFAULT
surelog     StructParamFuncBodyFieldCompare  cfg_pkg::Base
surelog     StructParamPatternInitCast       cfg_pkg::Base
surelog     Ariane2024                       cva6_config_pkg::cva6_cfg
surelog     AzadiRTL                         fpnew_pkg::DEFAULT_NOREGS, ::RV32F
surelog     ariane                           ariane_soc::ArianeSocCfg
uhdm2rtlil  cva6_equiv                       cva6_config_pkg::cva6_cfg
```

**POSITIVE CONTROL:** the dispatched witness `StructParamFuncBodyFieldCompare`
AND the must-not-move row `FuncStructVal` both fall out of the scan.  Four of
the nine produce no judged database at this pin (`Ariane2024` `SLANG_REJECT` /
`NO_DATABASE`, `AzadiRTL` `SLANG_REJECT` both modes, `ariane` is row `Ariane`
`SURELOG_FAIL`, `cva6_equiv` is not a discovered row).  The other four were
scored CELL BY CELL against golden with the two frozen binaries before the
sweeps:

| row | base status | pristine vs golden | patched vs golden | moved? |
|---|---|---|---|---|
| `FuncStructVal` | `CMP_EQUAL` ×2 | 57/57 cells equal | 57/57 cells equal | **0 cells** |
| `FuncStructValSimple` | `CMP_EQUAL` ×2 | `cmp rc=0` | `cmp rc=0` | no |
| `ParamNoImport` | `CMP_EQUAL` ×2 | `cmp rc=0` | `cmp rc=0` | no |
| `StructParamPatternInitCast` | `CMP_NOTEQUAL` ×2 | `XLEN` already 32 | unchanged | no |

Confirmed on the sweeps: `rowheads.sh` over the four gives `cmp rc=0 / 0 heads`
for `FuncStructVal`, `FuncStructValSimple` and `ParamNoImport` in both modes on
BOTH binaries, and `15 cmp lines / 1 head` for `StructParamPatternInitCast` in
both modes on both binaries.  The only byte mover among them is none: the
surelog `byteverify` names `StructParamFuncBodyFieldCompare` and the UVM coin,
and nothing else.

### 5a. THE EIGHTEEN NAMED ROWS — caution (a) answered from the sources

`cen58.py` scores the r11u54 pair's own list of the eighteen rows their
view-only build moved from `CMP_EQUAL` to `CMP_NOTEQUAL` (seventeen named there
plus a "(+1)", for which `NoReducTypespec` — the other row the
`§ patElabUintResize` note says regresses on a re-sized literal — stands in):

```
uhdm2rtlil  ff_dead_both_branches                                      GATED=-
uhdm2rtlil  ff_dead_guarded_reset                                      GATED=-
uhdm2rtlil  struct_param_repl_count                                    GATED=-
uhdm2rtlil  iface_scalar_localparam                                    GATED=-
uhdm2rtlil  iface_nested_param_field                                   GATED=-
uhdm2rtlil  iface_struct_field_param_width                             GATED=-
uhdm2rtlil  iface_struct_field_partsel                                 GATED=-
uhdm2rtlil  ImportedDoubleCastedParameter                              GATED=-
uhdm2rtlil  TypedefStructParamWithRangeInSubmodule                     GATED=-
uhdm2rtlil  NestedStructArrayParameterInitializedByPatternPassedAsPort GATED=-
surelog     AssignmentPatternInAssignmentPattern                       GATED=-
surelog     Earlgrey_0_1              (18 package pattern params)      GATED=-
surelog     FuncStructVal                       GATED=cva6_config_pkg::cva6_cfg
surelog     GenForIfaceLocalparamNestedGen                             GATED=-
surelog     GenForStructParamBound                                     GATED=-
surelog     GenIfIfaceParamStructField                                 GATED=-
surelog     InterfaceParamOverrideProp                                 GATED=-
surelog     NoReducTypespec                                            GATED=-
```

**Seventeen of the eighteen carry NO gated read at all** — `Earlgrey_0_1`
declares eighteen package pattern parameters and not one of them is passed
whole to a call in a parameter context — so the gate cannot reach them.  The
one that is gated, `FuncStructVal`, is the arm that taught the bail, and it is
scored above at 57/57 cells with zero movers.

---

## 6. Gates — all green

1. **Builds.**  Pristine `2fa585e9ec9f6ccea23c8fee77b6fa7f`, byte-identical to
   the main tree at `cfcaecd5`; patched `8e6071209329cff27b3589297d32d1fd`.
   Both `-j 2`, md5'd separately, frozen `chmod 555` before any sweep.  Every
   `cmds.txt` audited BY BINARY PATH: 1531 surelog arms and 1742 uhdm2rtlil arms
   per workdir, each naming exactly one binary — `/tmp/r11u58_pris.bin` in the
   pristine workdirs, `/tmp/r11u58_pat.bin` in the patched ones — with no third
   path anywhere.
2. **Goldens.**  `check_goldens.sh` **23 PASS / 0 FAIL on both binaries**;
   `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (negative control).
3. **uhdm2rtlil, both modes.**  `ct8rows.sh` patched vs
   `results/gate_uhdm2rtlil.csv`, vs each mode half of
   `results/golden_uhdm2rtlil.csv`, and vs this pass's own pristine sweep:
   **PASS, 0 differing rows, all four joins.**  785 CMP_EQUAL / 19
   CMP_NOTEQUAL / 67 SLANG_REJECT in both modes, on both binaries — the
   committed baseline exactly.
4. **surelog, `--mode both`.**  **474 CMP_EQUAL / 9 CMP_NOTEQUAL (default) +
   469 / 8 (testflags) on BOTH binaries** — the committed baseline exactly, and
   every other status bucket unchanged too.  Patched against THIS PASS'S OWN
   pristine sweep: **exactly two differing rows**, `LowMemLib,testflags` and
   `LowMemPkg,testflags`, whose `SURELOG_FAIL` detail column echoes the workdir
   path — a path artifact, not a status change.  Against
   `results/golden_surelog.csv` both binaries differ in the same three rows:
   those two, plus `Earlgrey_0_1,testflags`'s dump column reading `differ` ->
   blank, which reads the same way under the PRISTINE binary (the documented
   `uhdm-dump` timeout draw).  Its status stays `CMP_EQUAL` and its database
   byte pin holds.
5. **byteverify `SELFCHECK=1`**, patched vs this pass's OWN pristine workdirs:
   * uhdm2rtlil **MOVERS 0 / 1608**, `PATH_SETS_IDENTICAL`, SELFCHECK 1607/1608;
   * surelog **MOVERS 6 / 960**, `PATH_SETS_IDENTICAL`, SELFCHECK 959/960 —
     `StructParamFuncBodyFieldCompare` in both modes (**PREDICTED BY NAME**,
     §5) and `MiniAmiq` / `SeqDriver` in both modes (the UVM coin, §6a).
6. **Canaries.**  All six protected databases SAME between the two binaries and
   at their stated values: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`
   (both hard byte pins, both modes), InterfaceModPort `59a365f3ce2c`,
   BlackParrotComplex `e3e354129d5a` / `73a10e8217e5`, YosysOldOr
   `d68e0796d62c`, Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`.
   `canaries.sh` ok=8 changed=0 (u2r) and ok=51 changed=1 (surelog) — the one
   changed row is `Earlgrey_0_1,testflags`'s dump column, which changes the same
   way under the pristine binary.  `ctcan2.sh` PASS on both corpora.
   `canaudit.sh` (r10uvm221repro) **audited=29 UNCOVERED=0 FENCE-BREACH=0**.
   `rowheads.sh`: SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg /
   Earlgrey_0_1 all `cmp rc=0`, 0 heads, both modes (SKIP-NOFILE on
   Scoreboard/tf and Rggen/tf as expected).
7. `results/*.csv` untouched.  Patch surface: `src/ParamEmit.cpp`,
   `src/TypeEmit.cpp`, `include/UhdmExporter.h`, `tools/probe/r11u58repro/`.
   Fence-name scan over the four slang-fenced names 0/0/0/0; no fenced test was
   ever dispatched; no shared `/tmp/ctl_wd_*` control was read; `GOLDEN_DEFER`
   unset; the patch applies clean on a fresh `cfcaecd5` and reproduces
   `src/ParamEmit.cpp` md5 `cca5f6c7db0baa738933f5b3227498e4`,
   `src/TypeEmit.cpp` `4c69789faed8c9edc098d2790655d9e0` and
   `include/UhdmExporter.h` `65e8e4509f773f78df1950b04535c391`.

### 6a. The movers, named and attributed

**`StructParamFuncBodyFieldCompare`, both modes — the law's own, and it moves
TOWARD golden only.**  Official `uhdm-cmp` head, pristine against patched:

```
pristine HEAD                             patched HEAD
LHS constant @30:23                       LHS constant (id only)
    |vpiDecompile:64 |vpiSize:32              |vpiDecompile:63 |vpiSize:64 |INT:63
RHS constant @30:23                       RHS operation @43:12..43:22
    |vpiParent: \_sys_func_call ($unsigned)   |vpiParent: \_range: 43:11..43:25
```

The road-D head is GONE and the new head is the `logic [Cfg.XLEN-1:0]` range
bound inside the anonymous `it_t` struct — TRIAGE2's C3 / road-E-at-module-scope
family, which the brief named as standing behind it.  cmp lines 36 -> 74 in both
modes, and the LINE COUNT GOING UP IS THE NEW HEAD'S OWN SIZE, not a regression:
the head OBJECT changed.  Order-blind whole-dump residue against the row's own
golden, both modes: **345/339 -> 344/339**, with **NEW-ours-only 0** and the
three golden lines `|vpiSize:1024`, `|vpiSize:32`, `|vpiSize:32` GAINED.  Two
`|vpiSize:64` lines become golden-only and that is the MULTISET TRAP, named:
golden carries FOUR `|vpiSize:64` at that indent, our pristine dump carried four
and our patched dump carries two, so the two are SCALAR FIELD lines our wrong
64s used to satisfy — not golden objects we stopped producing.
**TO-GOLDEN 3 cells, AWAY-GOLDEN 0, MOVED-WRONG 0.  ADVANCE, not CONVERT,
exactly as predicted from the arithmetic in §1.**

**`MiniAmiq` and `SeqDriver`, both modes — the documented UVM coin, with a
positive control.**  Order-blind (sorted, path- and id-normalised) each is
**exactly 4 lines**, the `UINT`/`vpiDecompile` line-number class:
`default/MiniAmiq` 1391 -> 1379, `testflags/MiniAmiq` 1342 -> 0,
`default/SeqDriver` 941 -> 766.

POSITIVE CONTROL, and it is decisive: the PRISTINE binary run a SECOND time into
a third workdir (`--filter 'MiniAmiq|SeqDriver|SimpleUVM|Scoreboard|BuildUVMPkg'`)
moves SIX of its own eight UVM databases against the first pristine sweep —
`default/MiniAmiq` `1327b324978c` -> `acf15da5e189`, `default/SeqDriver`
`87ff63ff81de` -> `2fb39f8b4130`, `default/SimpleUVM` `d4f8cd018f2d` ->
`778dc1340fee`, `default/Scoreboard` `1621aec6c9f3` -> `e70775324004`,
`testflags/MiniAmiq` `069b4973fc24` -> `fcdba0c5b8e5`, and **`testflags/SeqDriver`
`5cd52fa166c8` -> `05df6c25a21b`, which is BYTE-IDENTICAL to what the PATCHED
binary produced**.  A hash the patched binary "produced" is therefore a draw the
pristine binary also produces.  `BuildUVMPkg` draws identical in both modes and
`testflags/SimpleUVM` too — the 0-or-4-line class including its 0-line draw.
All of these rows are and stay `CMP_EQUAL` with 0 heads.

---

## 7. Residues left standing, and R0

* **R0 — the FLATTEN half of the same read.**  Every arm where golden stamps
  *and* flattens (`xd3`, `xd8` `S1`/`S2`/`S5`, `xd4` `R1`/`R2`, `xd6` `P2`,
  `xd2b`) our exporter keeps the tagged tree, because none of the three landed
  flatten triggers (`hasScopedPkgRef`, `hasMemberSelectOf`,
  `evalFuncWholeReads26`) answers yes for a call-argument or a
  `pkg::NAME.member` read.  The producer says they are ONE call: `:941`'s
  `expandPatternAssignment` does the stamp and `ExprEval::getValue`'s
  `:337-347` write-back does the flatten, both off the same qualified read, the
  second gated on `op->Typespec()`.  The stamp is landed alone here because it
  is the witness's shape (symbolic member dim ⇒ no typespec ⇒ tags survive);
  the flatten is the next cut and its golden cells are all measured above.
* **The MEMBER-SELECT trigger for the stamp** (`xd6` `P2`, `xd4` `R5`).  Golden
  stamps off a `pkg::NAME.member` read too.  Not taken: on those arms golden
  also flattens, so stamping alone does not reach golden's shape, and the
  blast radius (every member-selected package struct parameter) is far wider
  than the witness's.
* **`xd4` `R3`** — a call argument written UNQUALIFIED inside the parameter's
  own package does not stamp.  The `::` arm at `CompileExpression.cpp:884` is
  the reason; the unqualified path (`component->getParam_assigns()`, `:1100`)
  has the same `expandPatternAssignment` call and does not reach it here.  Not
  chased.
* **The multiset trap, named where it bites.**  On the witness, three golden
  lines are GAINED (`|vpiSize:1024`, `|vpiSize:32` ×2) and two `|vpiSize:64`
  lines become golden-only.  Golden carries FOUR `|vpiSize:64` at that indent
  and our patched dump carries two, where our pristine dump carried four — so
  the two "lost" lines are SCALAR FIELD lines our wrong 64s used to satisfy in
  the multiset, not golden objects we stopped producing.  `armdelta58.sh`
  reports **NEW-golden-only = 0 on every grid arm**, which is the test that
  matters.
* The `§ patElabUintResize` masking arm (it masks the value; the producer does
  not) is untouched and unexamined here.

## 8. Ops record

Worktree `/tmp/wt_r11u58` at `cfcaecd5`; scratch `/tmp/r11u58_*`; grid
`/tmp/r11u58_grid`; workdirs `/tmp/r11u58_wdp` (this pass's own pristine
control), `/tmp/r11u58_wdr` (patched) and `/tmp/r11u58_wdctl` (the UVM
nondeterminism positive control).  Binaries frozen at
`/tmp/r11u58_pris.bin` and `/tmp/r11u58_pat.bin`, `chmod 555`.  No shared
`/tmp/ctl_wd_*` control was read; nothing was written outside the worktree and
this pass's own prefixed scratch.

## 9. Instruments (all measurement-only; the judge is `uhdm-cmp`)

* `sz58.py` — the SHAPE LISTER: every `param_assign`'s pattern elements with
  their kind and `vpiSize`, per listing section (`uhdmallPackages` = DEF,
  `uhdmtopPackages` = ELAB).
* `shape58.sh` — the three-way (golden / pristine / patched) driver over it.
* `armdiff58.sh` — order-blind, path-normalised residue per arm.
* `armdelta58.sh` — the NEWLY-UNMATCHED sets between two binaries on one arm;
  `NEW-golden-only` is the away-move test and `id:` is normalised out.
* `pred58.py` — the a-priori mover prediction, by name, with the two witnesses
  as its positive control.
* `cen58.py` — the exclusion census over the eighteen named must-not-move rows.
* `run54.sh` / `shape54.py` — inherited from r11u54, unmodified.

---

## 10. VERIFIER AMENDMENT (r11v58) — two conditions the law above is missing

The adversarial verification of this pass (`tools/probe/r11v58repro/README.md`)
reproduced every number in §1–§6 and confirmed the producer decode line by line,
and it found two faces where the gate as submitted moved cells AWAY from golden
on legal SV.  Both are fixed in the landed code and both carry a golden arm:

1. **The read must stand in a scope the producer ELABORATES.**  `getValue` runs
   only from `ExprEval`'s value functor, i.e. only when a parameter is REDUCED,
   and Surelog reduces a parameter only in an elaborated scope.  A parameter
   context reached only through `generate if (0)` — a module instantiated only
   in a dead branch (`r11v58repro/grid/va3_deadgen`) or a parameter inside an
   uninstantiated generate block of a live module (`va9_deadblock`) — is
   compiled but never reduced: golden leaves that package parameter TAGGED at
   its COMPILED sizes.  `pkgPatCallArgParam58` now arms only on parameter
   declarators and instance override lists that the elaborated hierarchy really
   carries.

2. **A NESTED assignment-pattern element ends the walk and is NOT stamped.**
   `CompileHelper.cpp:5423`'s `if (invalidValue) return result;` is the width
   bail's sibling exit, and it fires BEFORE the element it stops at is stamped.
   Measured in `r11v58repro/grid/va12_nested`: golden stamps `A` to 32, leaves
   the nested `N` with no `vpiSize` at all and the following `D` at its compiled
   32.  The stamp loop now breaks at such an element before adding it.

The §4 law therefore reads, in full: *… in the ELABORATED PACKAGE listing, a
struct-pattern parameter whose `pkg::NAME` is written as an argument of a call
inside a parameter context THAT THE ELABORATED DESIGN CARRIES …; the walk runs
in member declaration order and stops, after stamping it, at the first member
wider than 64 bits, and stops, WITHOUT stamping it, at the first element that is
itself an assignment pattern.*
