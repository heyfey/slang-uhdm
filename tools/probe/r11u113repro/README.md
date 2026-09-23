# r11u113 — the typed package parameter's range bound, the cast to a type parameter, the inline enum member, the ranged repetition and the var_select index stamp

**ONE TARGET ROW CONVERTS, BOTH MODES (TWO ROW-MODES).** `arb_idx_cast` reads 0
uhdm-cmp lines and 0 heads with the LAW binary, and `CMP_EQUAL` in the LAW
sweep:

```
results/golden_uhdm2rtlil.csv:  arb_idx_cast,default,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:  arb_idx_cast,testflags,CMP_NOTEQUAL,decompile:,,
results/gate_uhdm2rtlil.csv:    arb_idx_cast,testflags,CMP_NOTEQUAL,decompile:,,
LAW sweep:                      arb_idx_cast,{default,testflags},CMP_EQUAL,,,differ
```

* uhdm2rtlil: 798/6/67 -> **799/5/67** in both modes.
* Surelog: unchanged (478/5 default, 473/4 testflags).
* `results/*.csv` were NOT edited. The master promotes.

The other two target rows stay `CMP_NOTEQUAL`, each with its face cleared
and a NEW head (section 6): ibex_icache 36 -> 17, ibex_pmp 36 -> 64 (a
fenced ParamEmit head, unmasked).

Base `d18793fc`. Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

| binary | md5 | what |
|---|---|---|
| pristine | `b089e2991b5751d12a492cfe89e29fa2` | own worktree at `d18793fc`, `-j 2`, equals the OPS pin |
| **LAW** | `cafc6a91ff8edc82f96f359099b2dc88` | this patch; the same md5 when the patch is applied to a FRESH `d18793fc` and rebuilt |

Every law reads its own kill switch from the environment; `R11U113_OFF=1`
drops them all, and then the LAW binary reproduces the pristine database byte
for byte on every grid arm (`evidence/DROPS113.txt`).

**Surface.** `src/TypeEmit.cpp` (face 1, face 3), `src/UhdmExporter.cpp` (face
3's design-final instance mirror), `src/ExprEmit.cpp` (face 2, face 5),
`src/ModuleEmit.cpp` (face 4). Every helper and switch is a file-local
`static` in the `.cpp` that uses it, except the one free function
`r11u113InlineEnumBaseInstance()` (TypeEmit.cpp), which UhdmExporter.cpp
declares locally. `ParamEmit.cpp`, `EmitHelpers.h`, `include/` and `results/`
are absent from the patch; the rest of it is `tools/probe/r11u113repro/`.

---

## 1. The three rows at `d18793fc` (Q1)

`three113.sh <pristine> pris` (and `rowcmp113.sh` on the sweep databases):
uhdm-cmp, LHS golden, one head per row, the same count in both modes. Full
heads: `evidence/HEADS113.base.txt`.

| row | lines | head: golden (LHS) vs ours (RHS) |
|---|---|---|
| ibex_pmp | 36 | LHS `constant UINT:33 sz32 ct9` @34:10-34:22 under the `range` of `region_start_addr`'s elaborated `logic_typespec` (34:3-34:25), no typespec. RHS the same constant at **sz64**. |
| ibex_icache | 36 | LHS `constant UINT:1 sz32 ct9` @138:22-138:37 (the inner range bound of `fill_ext_cnt_q`'s typespec). RHS the same at **sz64**. |
| arb_idx_cast | 18 | LHS `unsupported_typespec (idx_t)` @26:36-26:41, parent `ref_typespec (work@dut.gen_levels[1].gen_level[0].gen_first_level)`. RHS `integer_typespec` @26:36-26:41, no name, no value. |

Measured on golden: the range-bound constant carries NO ref_typespec on the
elaborated variable's typespec copy (the DEF-view element typespec 34:3-34:85
carries it, and ours already matches that copy).

## 2. The producer's rules and our sites (Q2)

### FACE 1 — the typed parameter's bare read as a range bound (§ typedPkgBoundElabSize113)

* **The producer.** `CompileHelper::compileExpression`'s identifier arm
  (`CompileExpression.cpp:3027-3045`, pinned Surelog) mints the folded read
  from the instance's stored `Value`: `VpiSize(sval->getSize())`,
  `VpiConstType(sval->vpiValType())`. A package / `$unit` / generate-scope
  parameter's stored value was `adjustSize`d against its DECLARED typespec, so
  the size is the type's width.
* **Our site.** `makeTypespec`'s `emitBound` lambda, the non-operation `else`
  arm, `src/TypeEmit.cpp` (the arm chain `elabPortIntBoundParam109` /
  `unitBoundParam` / `ovW82` / `boundParam` / `elabModPar`). A package
  parameter matched none of them and fell to the final `else` at the unsized
  64.
* **The law.** A new arm before that final `else`: a bare `IdentifierName`
  bound on a Variable / Net / Port declaration, resolved in the DECLARING
  symbol's own scope (`Lookup::unqualified`, per-instance by construction), to
  an EXPLICITLY typed, integral (width 1..64), non-genvar parameter homed in a
  Package, the CompilationUnit or a GenerateBlock, whose initializer is not a
  based literal (`basedLitOrigin50`). It writes size = the declared width,
  `UINT:`/ct 9 or `INT:`/ct 7 by `pkgSubstIntEnc50` (the reduce table), no
  typespec. Not in a struct-member typespec (`structMemberTsCtx`).

### FACE 2 — the cast to a type parameter's type (§ genCaTypeParamCastUnsupported113)

* **The producer.** The `paCast` arm (`CompileExpression.cpp:2659-2710`)
  compiles the target with `compileTypespec`; inside a generate scope the
  type-parameter name is not a data type of the scope's component, so the
  catch-all (`CompileType.cpp:1624-1634`) files an `unsupported_typespec` NAMED
  as written at the name token and queues `needLateTypedefBinding`, which never
  resolves a type parameter (`UhdmWriter.cpp:2576-...` walks functions,
  packages and typedef listings only). The elaborated gen-scope cont_assign is
  the def object carried over (`NetlistElaboration.cpp:765-772`).
* **Our site.** `src/ExprEmit.cpp`, the cast arm's `CastExpression` branch
  (the `defGenProcessEmit || dpiOwnTdCast170` unsupported-typespec mint). The
  elaborated copy went through the "non-literal cast size" arm, bound the name
  as an EXPRESSION (bad: it is a type), and fell to the value-less
  `integer_typespec`.
* **The law.** `inGenScopeCaRhs && !defGenProcessEmit`, parent = the
  cont_assign, the cast IS the assignment's right-hand side (syntax), the
  target is an `IdentifierName` that resolves (from `castSiteScope57`) to a
  `TypeAlias` whose syntax is a `TypeAssignment` (a type parameter, not a
  typedef) -> the same named `unsupported_typespec` the def view mints.

### FACE 3 — the inline anonymous enum member (§ structInlineEnumMemberTs113)

* **The producer.** The member compile (`CompileType.cpp:1052-1180`, the
  `paEnum_base_type` arm) mints an `enum_typespec` with no name and no
  location, its vpiBaseTypespec a ref (fullname = the member ref's) to a
  located, unparented base typespec, plus one located `enum_const` per name.
* **Our site.** `buildStructTs`' member loop, `src/TypeEmit.cpp`:
  `makeTypespec(fm, memberTypeSyn)` passes a syntax override, which skips
  makeTypespec's enum arm (`!typeSynOverride`) and lands on a flat
  `logic_typespec` spanning `enum ... {...}`.
* **The law.** A member whose declared type is an anonymous `EnumType` written
  as `EnumType` syntax is built by `buildEnumTs(..., implicitBaseRef=true)`
  (golden's no-base int enum carries a bare base ref, grid e04). In a PACKAGE
  typedef golden's base typespec carries the enum's vpiInstance (e03); the
  member stamps run later, in ParamEmit (fenced), so a design-final mirror in
  UhdmExporter.cpp (`r11u113InlineEnumBaseInstance`, after
  `clearAnonClassTsInstance`) copies the enum's Instance onto a base that has
  none, only for enums this law built. Unions are not touched.

### FACE 4 — the ranged repetition's range operand (§ propDeclRangedRepRangeOperand113)

* **The producer.** The repetition arms push a `range` operand whose bounds are
  the compiled constants; range and constants are UNPARENTED and located; a
  literal bound is `UINT:<n>` sz64 ct9, `$` is `STRING:$` sz1 ct10.
* **Our site.** `emitAssertionExpr`'s `Simple` arm, `src/ModuleEmit.cpp`: only
  a `BitSelect` count was read; a `SimpleRangeSelect` produced no operand.
* **The law.** In the property-declaration home (`propDeclScope`), a
  `SimpleRangeSelect` whose bounds are integer literals or `$` pushes the range
  (decided before any Make call).

### FACE 5 — the typed package parameter under a var_select index operation (§ caVarSelIdxOpFoldTs113, § genCaBitSelIdxOpFoldTsParse113)

This is the NEXT head of ibex_icache once face 1 lands (see section 6).

* **The producer.** Pass 112's decode: `CompileExpression.cpp:2918-2927`
  stamps the parameter's declaration typespec on the substituted read wherever
  it is reached from.
* **Our site.** `src/ExprEmit.cpp`, § caSelIdxOpFoldTs112's `selIdx112` walk
  (operations, one select, operations, the cont_assign). It admitted only a
  `bit_select` and only `contAssignView != 0` (the module-scope cont_assign).
* **The laws.** (a) § caVarSelIdxOpFoldTs113: the select may be a
  `var_select`, in the module-scope cont_assign AND in the elaborated
  gen-scope one (`inGenScopeCaRhs`); the ref is named after the var_select.
  (b) § genCaBitSelIdxOpFoldTsParse113: a gen-scope `bit_select` too, but ONLY
  without `--elabuhdm` (`!elabUhdmView121`). Pass 112's gates carry over (typed,
  unqualified, imported package parameter).

## 3. The golden grid (Q3)

All goldens are real pinned Surelog v1.87 runs (`grid113.sh`, both forms:
`-parse -nobuiltin -nocache -sv` and `-parse -elabuhdm -nobuiltin`), written by
`mkgrid113.py`. Every scored arm reads golden `rc=0`. Our side reads `rc=4` on
the pristine binary for every face-2 arm (an `Invalid` expression: the type
name bound as an expression), and `rc=0` on the LAW binary for every arm the
law covers. Three arms are slang-rejected (`rc=3`: e09 undeclared `B`, q10/q11
`sequence must not admit an empty match`) and are not scored.

| dir | arms | varies |
|---|---|---|
| `grid/b` | 38 | parameter type {int unsigned, int, integer, byte, shortint, longint, bit [7:0], logic [7:0], logic [31:0], untyped} x home {package, package localparam, module header, module localparam, generate localparam, `$unit`, parameter of parameter} x position {left, right, both} x declaration {var, net, reg, input/output port, struct member, typedef, unpacked, packed+unpacked, 2-D inner/outer, child instance, gen scope} + based-literal, expression, negative-value and qualified controls + the two corpus shapes (b23 pmp, b24 icache) |
| `grid/c` | 28 | cast to a type parameter x scope {module, gen-if, gen-else, nested gen-if, gen-for} x kind {header, body `localparam type`, body `parameter type`, overridden, int / struct default} x operand {name, concat, literal, genvar select, localparam select, ternary arms, under `+`} x home {cont_assign, always_comb, bit-select Lhs} + typedef / package-type controls + the corpus row (c01) |
| `grid/e` | 12 | inline enum member x {module typedef, package typedef, anonymous struct var, `localparam type`, nested struct, int enum, dims, union, port, typed-enum control} |
| `grid/q` | 15 | property declaration x `[*1:3]` `[*0:2]` `[=1:2]` `[->1:2]` `[*1:$]` `[*0:$]` `[*]` `[+]`, `##1` tail, `\|=>`, `disable iff`, no clock, inline-assert control |
| `grid/v` | 18 | typed package parameter under a select-index operation x {var_select, bit_select} x {module, gen-for, gen-if} x {`-`, `+`, `int`, untyped, qualified, under `~` / `==` / `&`, bare select Rhs, always_comb} + the ibex_icache shape (v11) |

Measured golden answers:

| face | golden |
|---|---|
| 1 | Every explicitly typed non-module parameter read bare: size = declared width (32 / 16 / 8 / 64), `UINT` ct 9 (`INT:-1` ct 7 for `int P = -1`), NO typespec, signed `int` included; untyped 64 (already ours); based literal `INT:5` ct 7 (abstained); qualified `pk::P` carries a ts ref at `pk::` (abstained); module parameters already golden. |
| 2 | The elaborated gen-scope cont_assign keeps `unsupported_typespec (<name>)` for every direct cast; under a ternary it RESOLVES in a loop generate (c25/c27, the default's `logic_typespec`) and does not in an if-generate (c06); module scope (c03) and always_comb (c13) resolve. |
| 3 | `enum_typespec` (no name, no location) + base ref + located consts; package typedef: enum and base both carry the package instance; no written base: a bare base ref. |
| 4 | `range` operand, unparented, located; literal `UINT` sz64 ct9; `$` `STRING:$` sz1 ct10. |
| 5 | var_select: stamped in module, gen-for and gen-if, both forms. Gen-scope bit_select: stamped in the parse-only form, not under `-elabuhdm` (v13-v16, v18). Untyped (v05) and qualified (v06) differ otherwise. |

## 4. The laws, each droppable alone (Q4)

`drops113.sh`: the LAW binary with one switch set, every grid arm, the
parse-only form, compared byte for byte (`evidence/DROPS113.txt`).

| switch | law | arms that move when dropped |
|---|---|---|
| `R11U113_OFF` | all | 79; **= pristine on every arm** |
| `R11U113_RBND_OFF` | § typedPkgBoundElabSize113 | b: 29 arms |
| `R11U113_TPCAST_OFF` | § genCaTypeParamCastUnsupported113 | c: 18 arms |
| `R11U113_ENUM_OFF` | § structInlineEnumMemberTs113 | e: 9 arms |
| `R11U113_REPRNG_OFF` | § propDeclRangedRepRangeOperand113 | q: 9 arms |
| `R11U113_VSIDX_OFF` | § caVarSelIdxOpFoldTs113 | v01-v04, v08-v11 |
| `R11U113_GSBS_OFF` | § genCaBitSelIdxOpFoldTsParse113 | v13-v18 |

Each switch moves only its own face's arms.

## 5. Census and the a-priori mover set (Q5)

`sig113.cpp` (via `cen113.sh`) reads each row's golden and PRISTINE databases
and counts one signature per face (each a superset of its law's gates):

* R1S: bare range-bound constants (parent range under a typespec) sized 1..63.
* C2U: cast operations whose target is an `unsupported_typespec`.
* E3M: `enum_typespec` parented by a `typespec_member`.
* Q4R: `range` operands of an operation.
* V5T / B5T: typed constants under an operation under a var_select / bit_select.

Positive control: grid b01 / c02 / e02 / q01 / v02 / v13 each read golden 1-2,
pristine 0 (C2U 1: the def view), LAW = golden. Results (`evidence/CENSUS113.txt`):

* **Calibration** (golden read as both sides): 0 rows of 1608 (u2r) and 960
  (surelog).
* **Reach, pristine** (+ = golden holds more):
  * u2r: exactly the three target rows: arb_idx_cast C2U+4, ibex_icache R1S+6
    V5T+2, ibex_pmp R1S+6 (both modes).
  * surelog: MiniAmiq R1S+100 and SeqDriver R1S+100 (both modes),
    Scr1SvTests C2U+1; negatives SeqDriver/SimpleUVM C2U-1, BiasValue/testflags
    R1S-1. The UVM R1S gap is part of a pre-existing typespec-population gap
    (MiniAmiq/default: golden 6951 range-bound constants, ours 2698), in
    CMP_EQUAL rows. None of these shapes is inside a law's gate (a class /
    subroutine home, not a Variable / Net / Port of a module).
* E3M and Q4R: no corpus delta anywhere; faces 3 and 4 are grid-only
  (corpus-invisible), as the brief says.

**PREDICTED MOVERS BY NAME:** arb_idx_cast, ibex_icache, ibex_pmp x 2 modes
(u2r); in surelog NOTHING except the UVM family's documented 0/4-line class
(MiniAmiq, SeqDriver, SimpleUVM, and Scoreboard/default's coin).

## 6. The laws measured (Q6)

**Sweeps.** Both corpora, both modes, `--jobs 3`, own workdirs with
same-length tags (`pris` / `lawx`), `SLANG_UHDM` exported, every `cmds.txt`
naming its frozen binary (u2r 1742/1742 `lawx.bin`, surelog 1531 `lawx.bin`
rows with a slang run; pristine 3273 `pris.bin`). `evidence/ROWS113.txt`:

* Pristine = the committed baselines status-for-status and row-for-row, except
  Earlgrey_0_1's dump column (blank-on-timeout draw) and the LowMem log path.
* LAW = the baselines except the two converted row-modes quoted at the top
  (plus the same Earlgrey dump-column draw and LowMem log path). All twenty-one
  earlier conversion rows stay `CMP_EQUAL` in both modes.

**byteverify** (`SELFCHECK=1`, identical path sets; `evidence/BYTEVERIFY113.txt`):

* u2r **6/1608**: arb_idx_cast, ibex_icache, ibex_pmp x 2 modes.
* surelog **4/960**: MiniAmiq x 2, SeqDriver/testflags (each an order-blind 4
  lines, `UINT:<line>` + `vpiDecompile:<line>`: the documented line-number
  class), Scoreboard/default (0 lines order-blind: the order coin). Every UVM
  row stays `CMP_EQUAL`. The surelog census is identical pristine vs LAW.
* **Exactly the prediction.**

**Protected databases, both modes, byte-identical to pristine**
(`evidence/CANARIES113.txt`): Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`,
SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort
`59a365f3ce2c`, BlackParrotComplex, YosysOldOr.

**Canary battery:** canaries ok=51 changed=1 (Earlgrey_0_1/testflags dump
column, the timeout draw; its database is byte-identical) and ok=8 changed=0;
ctcan2 PASS (both); canaudit UNCOVERED=0 FENCE-BREACH=0.

**Goldens:** 23/0 (pristine and LAW), `/bin/false` 0/23.

**Per cell** (`cells113.py` = pass 112's scorer; `rbc113.py` for the
range-bound constants, which sit in the `weaklyReferenced` tail; `dist113.py`
the order-blind whole-dump distance):

* The 6 moved target databases (`TO / AWAY / MOVED-WRONG`): arb 4/0/0 x 2
  (dist 457 -> 447), ibex_icache 8/0/0 x 2 (dist 7496 -> 7472; range-bound
  cells only_ours 7 -> 1), ibex_pmp 0/0/0 x 2 in the path cells and 6 TO in the
  range-bound cells (only_ours 7 -> 1, only_gold 96 -> 90).
* Grid: 162 arm-forms scored, **TO 486, AWAY 0, MOVED-WRONG 0**
  (`evidence/SCORE113.txt`); the face-1 tail cells are all TO (rbc
  only_ours -> 0 on every b arm but b07).
* **Controls.** `ctl113.sh`: 1302 compiles of every `.sv` under r11u112repro,
  v11u112repro, r11u110repro, v11u110repro, r11u109repro, r11u108repro,
  v11u108repro, r11u107repro, r11u106repro, v11u94repro, both forms
  (`evidence/CTL113.txt`). Byte-identical except 27 named cells, each a face
  of this pass, each scored against its golden (`evidence/SCORE113.ctl.txt`,
  AWAY 0, MOVED-WRONG 0 everywhere):
  * r11u112 f/g01_arb (face 2) 18 -> 0; f/r01 r02 r04 r07 r08 r09 (face 1,
    pass 112's R1b arms) 36 -> 0; r03/r05/r06 unchanged, as predicted.
  * v11u112 brk4/p q19 q20, brk/p b5d_reps (face 4) 84 -> 0.
  * v11u112 brk/k b3b, brk2/k m08 (face 3, pass 110's V2) 82/66 -> 36 (the
    next head is the `'0` fill's size, pre-existing).
  * v11u112 brk/f b1e_genfor_ca (face 5b) 17 -> 0 (u2r form; elab unchanged).
  * v11u112 brk6/f b1p_param_lut (face 5a): TO 4, AWAY 0, dist 48 -> 36; the
    cmp count RISES 17 -> 88 because the cleared head unmasks a pre-existing
    one (`LUT[P-1]` over a module parameter, golden folds it to `1'b0`).

**The three rows, after** (`evidence/HEADS113.law.txt`, both modes equal):

| row | before | after | next head |
|---|---|---|---|
| arb_idx_cast | 18 | **0** | **converted** |
| ibex_icache | 36 | 17 | Face 1 cleared the 138:22 bound; the head it unmasked (LHS `ref_typespec (work@ibex_icache.gen_tag_match[0].tag_rdata_ic1)` on the folded `IC_TAG_SIZE` @500:55 in `~tag_rdata_ic1[way][IC_TAG_SIZE-1]`, RHS `<null>`) is face 5, landed. NEXT: LHS `ref_typespec (work@ibex_icache)` -> `int_typespec` @ibex_pkg 393:13 on the folded `IC_LINE_BEATS_W` @759:38 (the replication count `{IC_LINE_BEATS_W{1'b0}}` inside the `fill_alloc[fb] ? ... : ...` ternary of the gen-for `gen_fbs[0]` cont_assign; golden re-parents it at the package param_assign), RHS `<null>` — § caOpFoldElabTs72's gen-scope half (residue R0b) |
| ibex_pmp | 36 | 64 | LHS `constant HEX:00000FFF ct5 sz32 32'h00000FFF` @ibex_pkg 240:72 (the `param_assign` Rhs of ibex_pmp's typed parameter over `DmAddrMask = 32'h00000FFF`), RHS `UINT:4095 ct9` — a ParamEmit head (fenced, sister pass r11u111) |

## 7. Residues (ranked)

* **R-pmp — the typed parameter's based-literal override carries its hex
  encoding** (ibex_pmp 64, the new head): ParamEmit.cpp, fenced to r11u111.
* **R1c — face 1's other homes.** A module typedef over such a range (b07):
  size moved to golden's 32, but golden's copies also carry a ts ref named
  after the typedef. A based-literal initializer (b20: golden `INT:5` ct 7) and
  a qualified `pk::P` (b14) are abstained.
* **R2b — face 2 under a ternary / an operation and outside a gen scope.**
  c06 (if-generate ternary: golden unsupported), c18 (`idx_t'(a) + 1`: golden
  unsupported), c25/c27 (loop-generate ternary: golden resolves to the
  default's `logic_typespec` 1:67-1:80) and the module scope / always_comb
  (c03, c13, c16: golden resolves to the default's `logic_typespec`, ours an
  `integer_typespec`). arb_idx_cast's `gen_other_levels` copies are c25's
  shape (judge-invisible in that row).
* **R3b — face 3's multiplicity.** In a `localparam type` struct (e01, e07,
  b3b, m08) golden builds the enum once and shares it between the struct's
  copies; we build one per struct build (our struct is already built more times
  than golden's), so the whole-dump distance rises (e07 113 -> 143) while the
  judge count falls (82 -> 0 / 36). Judge-invisible; "clone, never share".
* **R5b — face 5's other shapes.** An UNTYPED package parameter (v05: golden's
  typespec is an unsigned int ours is not) and a qualified `pk::P` (v06).
* **R-surelog — the UVM rows' range-bound population** (MiniAmiq, SeqDriver:
  golden 6951 range-bound constants vs ours 2698, judge-invisible).

* **R0b — ibex_icache's next head** (17 lines): a typed package parameter as
  a REPLICATION COUNT under a ternary in an elaborated gen-for cont_assign
  (`ibex_icache.sv:759`), golden `ref_typespec (work@ibex_icache)` -> the
  parameter's `int_typespec`, ours `<null>`. § caOpFoldTs / § caOpFoldElabTs72
  (`src/ExprEmit.cpp`, `caOpFold9`) gate on `contAssignView != 0`, which the
  gen-scope elaborated cont_assign does not set. On this pass's ground
  (ExprEmit); not decoded here (the ternary arm fold, § genCaTernaryFoldGenScope22,
  stands in the way and needs its own grid).

R0 = R0b (ibex_icache, ExprEmit, this ground); R-pmp is the sister pass's.

## Scripts

| script | what |
|---|---|
| `mkgrid113.py` | writes the grid |
| `three113.sh` | the three rows, both modes, uhdm-cmp |
| `rowcmp113.sh` | uhdm-cmp of named rows on an existing sweep (writes no database) |
| `grid113.sh` | golden + ours per arm, both forms, cmp |
| `score113.sh` + `cells113.py` + `dist113.py` | per-cell scoring and order-blind distance, A -> B |
| `rbc113.py` / `blk113.py` | range-bound constant cells / located block multiset |
| `drops113.sh` | per-switch drops |
| `ctl113.sh` | control byte compare |
| `sweep113.sh` | both corpora, both modes |
| `cen113.sh` + `sig113.cpp` | census |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the r10uvm221 battery |
