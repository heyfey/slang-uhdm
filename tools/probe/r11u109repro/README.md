# r11u109 — the struct pattern's VALUE keeps its void-typed cast, the anonymous packed array is a net, the type-parameter port keeps its wrapper

**ALL SIX TARGET ROWS CONVERT, BOTH MODES.** Each reads 0 uhdm-cmp lines and
0 heads with the LAW binary, and each reads `CMP_EQUAL` in the sweep:

```
results/golden_uhdm2rtlil.csv: anon_struct_packed_dim,{default,testflags},CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv: cva6_struct_param_field,{default,testflags},CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv: type_param_unpacked_port,{default,testflags},CMP_NOTEQUAL,decompile:,,
results/gate_uhdm2rtlil.csv:   the same three rows, testflags, CMP_NOTEQUAL,decompile:,,
results/golden_surelog.csv:    StructParamFieldRange,{default,testflags},CMP_NOTEQUAL,decompile:,,
results/golden_surelog.csv:    StructParamFuncBodyFieldCompare,{default,testflags},CMP_NOTEQUAL,decompile:,,
results/golden_surelog.csv:    StructParamPatternInitCast,{default,testflags},CMP_NOTEQUAL,decompile:,,
LAW sweep:                     all nine rows x {default,testflags} -> CMP_EQUAL,,,differ
```

* uhdm2rtlil: 790/14/67 → **793/11/67** in both modes.
* Surelog: 474/9 → **477/6** (default) and 469/8 → **472/5** (testflags).
* `results/*.csv` were NOT edited. The master promotes.

No other row changes status, and every row but these nine is byte-identical
to the committed baselines. The exceptions are environment only:
`Earlgrey_0_1`'s dump column reads blank in both LAW sweeps (its databases are
byte-identical to pristine, `8bdf25272e08` / `59d0ee6d10c3`), and the
LowMemLib/LowMemPkg log-path text differs.

Base `d92bab05`. Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

| binary | md5 | what |
|---|---|---|
| pristine | `a4029f5ad059cd302ee38b299e6f1250` | own worktree at `d92bab05`, `-j 2`, equals the OPS pin |
| **LAW** | `d5a934d3e59f3ef9da0066603d009438` | this patch; the same md5 when `/tmp/r11u109.patch` is applied to a FRESH `d92bab05` and rebuilt |

The LAW binary is also the explore binary. Every law reads its own kill
switch from the environment, and `R11U109_OFF=1` turns them all off. With
`R11U109_OFF=1` the LAW binary reproduces the pristine dumps on every grid arm
(`evidence/DROPS109.txt`).

**Surface.** Production code touches four files:

* `src/EmitHelpers.h` holds every § block, helper and switch.
* `src/ModuleEmit.cpp` has the face-4, face-5 and face-1 sites.
* `src/ExprEmit.cpp` has the hier_path site.
* `src/ParamEmit.cpp` has five call sites, each **appended to an existing
  line**. The diff is 5 lines changed and 0 added; the file stays at 33717 lines
  and every `__LINE__` below the edits keeps its value.

`TypeEmit.cpp`, `UhdmExporter.cpp`, `include/` and `results/` are absent from
the patch. The rest of the patch is `tools/probe/r11u109repro/`.

---

## 1. The six rows at `d92bab05` (Q1)

Run with `six109.sh <pristine> base`: uhdm-cmp, LHS golden, one head per row,
the same in both modes. Full heads are in `evidence/HEADS109.base.txt`.

| row | lines | head: golden (LHS) vs ours (RHS) |
|---|---|---|
| cva6_struct_param_field | 60 | LHS: `operation` op67 @29:28-29:40, vpiSize 64, typespec ref → `void_typespec` @29:28-29:31, operand `UINT:1` sz64 ct9 dc`1`. RHS: `constant UINT:1` sz64 ct9 (no decompile) @29:28-29:40. The parent is the elab `param_assign I`'s op75. |
| StructParamFieldRange | 60 | The same face @27:28. |
| StructParamFuncBodyFieldCompare | 164 | LHS: `op29` @47:13 sz64 [`op22` [op67 void, `op11` [Base's element `64` sz32 @30:23, `UINT:1`]], op67 void]. RHS: `constant UINT:9223372036854775809` sz64. |
| StructParamPatternInitCast | 15 | LHS `<null>`, RHS `constant 32'd64` (DEC:64 sz32 ct1) @21:40. This is `cfg_pkg::user_cfg_t.XLEN`'s **Actual_value**. Golden stamps only `cfg_t` (the builder's own type). |
| type_param_unpacked_port | 208 | LHS: `array_typespec` (vpiArrayType 1, range `[N-1:0]` = op11 over `ref_obj work@dut.in_i.N` and `UINT:0`, elem ref → `struct_typespec pk::resp_t`) on the DEF port `in_i`. RHS: `struct_typespec pk::resp_t`. |
| anon_struct_packed_dim | 12216 | LHS: the elab `module_inst`, whose `vpiVariables[0]` is `logic_var vvm`. RHS: the same `module_inst` with `struct_var content_q` first. The whole-dump distance is **316** (order-blind, ids and workdir stripped). |

## 2. The producer's roads and our sites (Q2)

### FACE 1 — the pattern VALUE (§ spVoidCastValue109, § spVoidCastCaseB109, § spCastBinQuirk109)

**The producer.** `NetlistElaboration::elab_parameters_` (Surelog
`src/DesignCompile/NetlistElaboration.cpp:243-271`) compiles the instance's
complex value with `Reduce::Yes`.

* A cast `Cfg.XLEN'(1)` compiles its type through `CompileType.cpp:1795-1824`.
  * The type NAME is `Cfg`.
  * `getValue("Cfg")` returns the parameter's value.
  * If the value is a constant, it gets an `integer_typespec` carrying that
    constant's value (`:1815`). Otherwise it gets a `void_typespec` spanning
    `Cfg` (`:1820`).
* **Case A** (the value is a pattern operation: cva6, FieldRange):
  * The void cast never reduces, so the cast survives with its written literal,
    and every operation above it survives too.
  * A void-free subexpression IS folded by the compile-time reduce, into the
    evaluator's own constant.
  * `reduceExprTree` plus `flattenPatternAssignments` (`:369-431`) leave all of
    it in place.
* **Case B** (the value is a `struct_var`: FuncBody's bailed builder):
  * The cast is still void.
  * A member read `Cfg.XLEN` is not foldable at compile time. It stays an
    operation, and `reduceExprTree` swaps the read for the member's stamped
    leftover, the caller pattern's own element object (§ r10fsv2 L1).
* **Case C** (the value is an assembled BIN constant: PatternInitCast's `Cfg`):
  * The cast gets an `integer_typespec` whose value is `BIN:0…01000000`, and
    the cast reduce reads its WIDTH as that digit string in DECIMAL: 1000000
    bits.
  * A member read in the tree is replaced by the member's BIN slice (no
    location, no parent, ts ref → the member's typespec), and the operations
    stay.
* **The size stamp.** `expandPatternAssignment`'s untagged walk
  (`CompileHelper.cpp:5404-5441`) calls `adjustOpSize` in member order.
  * It RETURNS at the first operand that does not reduce (the bail).
  * The bail operand and every earlier one are sized to the member width.
  * Every later one keeps its own width.
  * Case C trees reduce, so they never bail.

**Our site.** ParamEmit's struct-pattern walk folds every member value
(`§ patMemberCastNoDecomp`'s cast arm).

* The law lives in `src/ModuleEmit.cpp` `emitInstance`, as a post-pass after
  `mintParamOpClones`.
* It is deferred to the design-final drain (`runDeferred109()`, appended to
  both exits of ParamEmit's `stampEvalFuncLeftovers`), because the drain's
  assemble arms decide whether `Cfg`'s value is a constant or a `struct_var`.
* It rebuilds only the operands whose setter reads such a cast (or a case-C
  member read), and declines the whole parameter on any unmodelled shape.

### FACE 2 — the package pattern (§ memLeftStampOwnType109, § pkgPatCallArgFlat109)

1. **The stamp.** `ExprEval::setValueInInstance` (UHDM `templates/ExprEval.cpp`
   ~5385) stamps `r.<m> = …` on the local's own struct object.
   * Ours (`stampEvalFuncLeftovers`, ParamEmit) matched struct typespecs by
     MEMBER NAME LIST, so `user_cfg_t {XLEN}` was stamped next to `cfg_t {XLEN}`.
   * The law requires a named package struct to be the builder's return typedef.
   * The site is `src/ParamEmit.cpp:3751`, an appended condition.
   * The next head (11 lines) was golden's flat `uhdmtopPackages` `Base` op
     (typespec, flat operands) against our tagged tree.
2. **The flatten.** `cfg_pkg::Base` is read as the ARGUMENT of a call inside a
   parameter default. That is road D (`pkgPatCallArgParam58`):
   `CompileHelper::getValue`'s package arm reaches `ExprEval::getValue`'s
   in-place write-back (`templates/ExprEval.cpp:337-347`).
   * Our SCOPED-REFERENCE rule excluded every read inside a parameter
     declaration.
   * The site is `src/ParamEmit.cpp:14386`, an appended condition. It is fenced
     to narrow (≤ 64-bit) named patterns whose setters are all integer literals
     (§ pkgPatAllLit109; see the boundary, §6).
   * The flat walk records its operands as the L1 element objects
     (`:16031`, appended). Without the record, `cfg_t.XLEN`'s Actual_value fell
     back to a `UINT:64` slice where golden has the `32'd64` element (the
     32-line step in `evidence/HEADS109.steps.txt`).
   * The next head after this face was face 1 case C.

### FACE 3 — the evaluator's operator digits (§ evalOpDigits109, § bitsAnonVecOne109)

`ExprEval::reduceExpr` (UHDM `templates/ExprEval.cpp`):

* `+` (:3260-3326): `UINT` unless an operand's reduced constant is
  INT/STRING/REAL/DEC, at the wider operand's size.
* shifts (:3149, :3236) and `&`/`|` (:3331-3366): `UINT` size 64.
* `$bits(<vector type>)` evaluates as 1 bit.

**Our site.** The pass-106 fold helpers in `src/EmitHelpers.h`
(`spOpTsBound106` / `spOpTsFold106` / `utdVarFold106`) now take the bound's
WRITTEN syntax.

* The encoding comes from `boundReduceEnc33`, TypeEmit's existing § 33/§ 79
  table. It is reached read-only through `boundEncHook109`, published by
  `emitInstance`.
* A fallback leaf table covers literals, struct-member reads (the member's
  setter literal) and nested operators.
* An override fence: an ADD over an OVERRIDDEN parameter is refused unless one
  operand is an unsized literal. Grid `f3` `u1` a08/a09 have golden size 32
  where the stored-width model reads 64.

### FACE 4 — the type-parameter port wrapper (§ tpUnpPortKeepsWrapper109)

This is probe-located. `src/ModuleEmit.cpp` `emitInstance`'s top-port writer
builds the def-view `array_typespec` (`defPts = ats`). The type-parameter share
then overwrote it (`defPts = <default ts>`) for every type-parameter port.

* The law keeps the wrapper and points its ELEMENT at the shared default.
* The site is `src/ModuleEmit.cpp:28975`.
* u04 (`logic [7:0]` default): golden's DEF port IS the wrapper, so no gate is
  needed. Its new head is a pre-existing ELAB face (residue R3).

### FACE 5 — the anonymous packed array's kind (§ anonPackedAggDimNet109) and its next head (§ hpElemSelBaseVarSel109)

**The kind.** `NetlistElaboration::elabSignal` (`:2050`) starts from
`isNet = true`.

* An anonymous aggregate has no data-type object, so only `isVar()` (the `var`
  keyword) clears it.
* The typespec is a `packed_array_typespec`, so the struct member scan never
  runs.
* The net arm `subnettype == paStruct_union` (`:2572`) mints a `struct_net`
  with NO net type.
* `var` goes to the variable road: `packed_array_var`.
* Ours went through `makeVar`'s anonymous-array arm: a `struct_var` (a union:
  `logic_var`).
* The site is `src/ModuleEmit.cpp:12853`, before `makeVar`.

**The next head** (200 lines) was
`hier_path tq[gi].is_page[2 - gx][0:0]`.

* Golden's shape is `bit_select tq[gi]` followed by `var_select is_page`
  [op11(2, gx), part_select is_page [0:0]].
* We wrote one `part_select` named `is_page[2-gx]`. That is the dotted-text
  arm, taken because ExprEmit's var_select arm
  (§ selChainElemShapeIsSyntactic147) admitted only a plain-name base.
* The law admits a base that is ONE element select of a variable, net or
  formal, in an rvalue only.
* It declines an operator index that reads a select (golden's decompiler
  renders `k[0]+0` as ` + 0` in the path name).
* The site is `src/ExprEmit.cpp:30176`.

## 3. The golden grid (Q3)

All grid goldens are real Surelog v1.87 runs (`grid109.sh`: testflags form,
`--nobuiltin`). Every arm reads `rc=0` on both binaries, except `f23_default`,
where golden's Surelog crashes (rc 139). That arm was dropped: an arm whose
compile fails teaches error recovery.

Arms are under `grid/`:

* `f1/`: face 1 cases A/B/C (35 arms).
  * `p01-p09`: two/three members, reorder, no reader, plain/literal casts,
    plain value, shift/or.
  * `f02-f24`: XLEN 32, constant first/after, child override, `+ << ~ | -`,
    inner param, VLEN, based literals, positional, param, shift-sub, shift-add.
  * `b01-b04`: case B.
  * `c01-c06`: case C, XLEN 64/3/8, plain `64`.
* `f3/f3_adds109.sv`: 22 bound shapes in a default and an overridden instance.
* `f5/`: `k01-k30`, anonymous packed struct/union × keyword-less/`var`/`wire`/
  `tri` × dims × assign/comb/ff/unread × member kinds × child/iface/gen/init/
  signed/unpacked.
* `hp/`: `h01-h14`, the hier_path select shapes.
* Also re-run as controls: `r11u107repro/grid` (55 arms), `v11u94repro/grid`
  plus `r11u106repro/grid` (13 arms).

Measured golden answers:

| face | golden, measured |
|---|---|
| 1A | Casts `op67` with `void_typespec`@type-name and the literal operand. Ops above them kept. Void-free subexpressions folded (`(Cfg.XLEN - 1)` → `INT:63`, `(Cfg.VLEN + 1)` → `INT:65`). The bail operand and earlier ones are sized to the member (32 when XLEN is 32); later ones keep their own. |
| 1B | The same casts. `(Cfg.XLEN - 1)` stays `op11[<Base element>, 1]`. |
| 1C | A bare cast is a constant at the member width (a reducible operand). A cast in a tree is a constant at width = decimal(BIN digits) (1000000 / 11 / 1000), `UINT:0` when ≥ 64. The member read is a BIN slice. Every tree root is sized (no bail). |
| 3 | `UW+1` `UINT:17` sz64. `UW+32'd1` `INT:17` sz32. `UW+IW` `UINT:32` sz32. `LW+1` (8'd) `INT` sz64. `Cfg.B+1` (8'd4) `INT:5`. `Cfg.W2+1` (8) `UINT:9`. `>>`, `<<`, `&`, `|`, `>>>` `UINT` sz64. `$bits(logic[..])-1` `INT:0`, `-2` `INT:-1`. `^` keeps the op (declined). |
| 4 | Every type-param unpacked port's DEF typespec is the wrapper (u01 pkg default, u02 chained, u05 literal range, u04 logic default). |
| 5 | Keyword-less / `wire` / `tri` + dims → `struct_net` (no net type). `var` + dims → `packed_array_var`. No dims → the existing member scan (already golden). Interface, gen scope, initializer, signed and unpacked-dim arms each have a different head and are declined. |
| hp | `x[i].m[j][r]`, `x[i].m[j]+:w`, `x[i].m[j][k][r]`, a constant index, an unpacked base, a nested member, a port base and a function formal all give `var_select`. An lvalue, a two-select base, and an arithmetic-over-select index give other names (declined). |

## 4. The laws, each droppable alone (Q4)

Every law has a switch `R11U109_<X>_OFF`, and `R11U109_OFF` drops all of them.
Results are in `evidence/DROPS109.txt`: the LAW binary with one switch set,
dumps compared path-normalised over all 134 grid arms, plus the tw106 walk for
`f3`.

| switch | law | the arms that move when dropped |
|---|---|---|
| `OFF` | all | 72 grid arms + 7 f3 arms; **= pristine on every arm** |
| `TPUNP_OFF` | § tpUnpPortKeepsWrapper109 | u01 u02 u04 u05 |
| `ANONNET_OFF` | § anonPackedAggDimNet109 | the 27 k/a anonymous-dim arms |
| `HPVS_OFF` | § hpElemSelBaseVarSel109 | h01-h06 h08 h10 h11 h13 |
| `VOIDCAST_OFF` | § spVoidCastValue109 (all of face 1) | 27 f1 arms |
| `VOIDCASTB_OFF` | § spVoidCastCaseB109 | b01-b04 |
| `CASTBIN_OFF` | § spCastBinQuirk109 | c01 c05 (the trees) |
| `STAMPTYPE_OFF` | § memLeftStampOwnType109 | c01-c06 |
| `PKGCALLFLAT_OFF` | § pkgPatCallArgFlat109 (+ its record) | c01-c06 |
| `OPDIGITS_OFF` | § evalOpDigits109 | f3: b1 b2 b3 b5 f3_adds s1 |
| `BITSONE_OFF` | § bitsAnonVecOne109 | f3: b5 b6 f3_adds |

## 5. Census and the a-priori mover set (Q5)

`sig109.py`, run through `cen109.sh`, reads each row's golden and PRISTINE
dumps and prints a DATABASE signature per face:

* F4: a DEF port whose golden typespec is `array_typespec` and ours is not.
* F5: an elab object that is ours `struct_var`, golden `struct_net` /
  `packed_array_var`.
* HP: more `part_select`s whose `vpiName` holds `[` in ours than in golden.
* F1: golden has more elab `void_typespec`s.
* F2S: ours stamps a typespec_member golden leaves bare, keyed per section.
* F2F: ours has more `uhdmtopPackages` tagged patterns.

Every signature is a SUPERSET of its law's gates (see §6 for what actually
moved).

* **Calibration** (golden read as both sides): **0 rows** of 3324 (756 lack
  both databases: SLANG_REJECT / SURELOG_FAIL / NO_UHDM).
* **Positive control** (the six base rows): anon_struct F5 3, HP 4; cva6 /
  FieldRange F1 4; FuncBody F1 8; PatternInitCast F2S 1, F2F 2;
  type_param_unpacked_port F4 2.
* **Corpus reach** (`evidence/CENSUS109.txt`, positive differential
  signatures, both corpora, both modes): the six target rows, plus two rows
  that sit outside the gates:
  * `packed_array_struct` (F5 1) declares `my_t [2:0] arr` with
    `localparam type my_t = struct packed {…}`. The written type is a NAMED
    type parameter, not the anonymous `struct` syntax the law requires.
  * `stamped_gen_param` (F2F 6) is a pre-existing tagged-vs-flat difference
    whose reads are member selects (`q2::IMPL.UnitTypes[grp]`), never a call
    argument in a parameter context.

**PREDICTED MOVERS BY NAME:** the six target rows × 2 modes, and the UVM
family's documented 0/4-line class (MiniAmiq, SeqDriver, SimpleUVM, and
Scoreboard/default's coin). **Nothing else.** `packed_array_struct` and
`stamped_gen_param` are predicted UNMOVED; the sweep confirms both.

## 6. The laws measured (Q6)

**Sweeps.** Both corpora, both modes, own workdirs with same-length tags
(`pris` / `lawy`), `--jobs 3`, `SLANG_UHDM` exported. Every `cmds.txt` names
its own frozen binary.

* Pristine = the committed baselines, row for row. The only differences are
  the LowMem log paths.
* LAW = the baselines except the nine converted rows (quoted at the top).

**byteverify** (`SELFCHECK=1`, identical path sets; `evidence/BYTEVERIFY109.txt`):

* u2r: **6/1608**, exactly the three target rows × 2 modes.
* Surelog: **12/960**:
  * the three target rows × 2;
  * MiniAmiq ×2, SeqDriver ×2 and SimpleUVM/default, each an order-blind 4
    lines (2 `|UINT` + 2 `|vpiDecompile`: the documented line-number class);
  * Scoreboard/default, 0 lines order-blind (the coin).
* Every UVM row stays `CMP_EQUAL` (rowheads: 0 lines).
* That is **exactly the prediction.**

**Per cell** (`cells109.py`: ancestor-object path × field; derived names
stripped; a `param_assign` keyed by its Lhs; objects printed in the
`weaklyReferenced` section scored separately as TAIL, because their content
has no containment path; merged same-kind lists judged by multiset distance to
golden):

* The 12 target databases: **TO 606, AWAY 0, MOVED-WRONG 0**
  (`evidence/MOVERS109.cells.txt`).
  * Whole-dump distance (order-blind): anon 316 → 39, cva6 / FieldRange
    392 → 357, tpup 231 → 143, FuncBody 615 → 486, PatternInitCast 654 → 542.
    The rest is spans, full names and fields no Compare reads.
* Grid, 134 arms: **TO 1649, AWAY 0, MOVED-WRONG 0**. The swap control reads
  AWAY 1649 (`evidence/GRID109.cells.txt`).
* Bound cells via the name-keyed walker (`r11u106repro/score106.py`), 14 f3
  arms: TO 67, AWAY 0, MWRONG 0. The swap control reads AWAY 67
  (`evidence/GRID109.f3tw.txt`).
* All 27 cells the verifier convicted or gave back are now TO: its 21
  MOVED-WRONG plus its six add cells (`c09_lplus`, `c01_xplus`, `c03_bplus`,
  `c06_divplus`, `s1 c03_plus`, `b5 c03_uminus`).

**Wide boundary.** Every `*.sv`/`*.v` under `tools/probe`, run by the
path-neutral `bnd109.sh` with `-P 3` and children fed `</dev/null`
(`evidence/BOUNDARY109.arms`):

* **8845 arms**: 8562 SAME, **51 DIFFERS**, 232 NODB (227 rc 3/3, 5 rc
  139/139; prc = lrc on every arm).
* Every DIFFERS arm was scored against a fresh Surelog v1.87 golden, with
  `slrc=0 slerr=0` and the NULL re-run SAME on 51/51.
* Generic cells: **TO 605, AWAY 0, MOVED-WRONG 0** (TAIL moves 277).
* Bound cells (tw106): **TO 113, AWAY 0, MWRONG 0**.
* Three UVM-ish arms (`r10uvm154 l154_noenum`, `r10uvm185 g185_e_kinds`,
  `r10buvm22 g22`) differ only in a `weaklyReferenced` array_typespec bound
  constant.
  * The value is layout garbage (`23463417` vs `23500537`).
  * With `R11U109_OFF=1` the LAW binary writes the LAW bytes, not the pristine
    ones: a binary-layout effect, not a law.
* **The first LAW draft (`4111faee…`) was convicted here.**
  `r11v59repro/grid/xv3_flat` had one MOVED-WRONG cell: the call-argument
  flatten reached a pattern with a signing cast and parameter-read setters,
  where our flat walk's element arms are not golden's.
  * § pkgPatAllLit109 is that conviction.
  * Every sweep, grid and the whole boundary were re-run on the shipped LAW.

**Gates.**

* goldens 23/0; `/bin/false` 0/23.
* `canaries.sh`: Surelog ok=50 changed=2 (Earlgrey's dump COLUMN only), u2r
  ok=8.
* `ctcan2` PASS ×2; `canaudit` PASS.
* Database pins, pristine = LAW in both modes: SVSwitch `4842211c4030`,
  YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
  BlackParrotComplex `e3e354129d5a` / `73a10e8217e5`, YosysOldOr
  `d68e0796d62c`, Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`.

**The six rows, cmp lines before → after, both modes** (`evidence/SIX109.txt`;
the next heads at each step are in `evidence/HEADS109.steps.txt`):

| row | base | after | the steps |
|---|---|---|---|
| cva6_struct_param_field | 60 | **0** | face 1A |
| StructParamFieldRange | 60 | **0** | face 1A |
| StructParamFuncBodyFieldCompare | 164 | **0** | 1A declines (a struct_var value), then 1B |
| StructParamPatternInitCast | 15 | **0** | 15 → 11 (the stamp: next is golden's flat `Base`) → 32 (the flatten: next is `cfg_t.XLEN`'s element) → 120 (the record: next is the INT tree) → 0 (case C, once the pass was deferred to the drain) |
| type_param_unpacked_port | 208 | **0** | face 4 |
| anon_struct_packed_dim | 12216 | **0** | 12216 → 200 (the kind: next is the hier_path `tq[gi].is_page[2 - gx][0:0]`) → 0 |

## RESIDUES (ranked)

* **R1 — the dotted hier_path NAME.** Golden's decompiler renders a
  bit-select index inside a path name without its base (`tq[k[0]].pg[k[1]]` →
  `tq[[0]].pg[1]`, and `k[0]+0` → ` + 0`).
  * The hp law gives h01/h02 golden's element SHAPE (TO 45 each), but the name
    stays wrong on both binaries.
  * h12 (an operator over a select) is declined.
* **R2 — the flat walk's element arms** for a call-argument-flattened package
  pattern: a signing cast (`unsigned'(64)`, where golden keeps the literal's
  decompile) and a parameter read (where golden's constant carries the
  parameter's typespec). They are why § pkgPatAllLit109 fences the flatten.
  The witness is `r11v59repro/grid/xv3_flat`.
* **R3 — u04's next head.** A top module's type-param unpacked port with a
  `logic` default is golden `array_var` in the ELAB listing; ours is
  `array_net` + `logic_net`. This is pre-existing and was masked by face 4's
  DEF head.
* **R4 — face 5's declined spellings.**
  * `wire`/`tri` + dims: the DEF net's head (a15 / k08 / k26, pre-existing).
  * An interface body (k21).
  * A gen scope (k22: we emit no such object).
  * An initializer (k23: golden moves the value to a net-decl assign).
  * `signed` (k24: a different typespec).
  * An unpacked declarator dimension (k25: golden `array_net` of
    `struct_net`).
* **R5 — face 1's declined shapes.**
  * A non-literal cast operand (`Cfg.XLEN'(W)`, f10: golden writes W's value
    `UINT:7` sz32).
  * A `default:` setter (Surelog crashes, f23).
  * `f06_child`'s overridden-Cfg param head (pre-existing).
  * `p08_plainval` (`'{x: 1, y: Cfg.XLEN + 1}`, a pre-existing face).
* **R6 — face 3's declined digits.**
  * `^` (golden keeps the op).
  * An ADD over an overridden parameter's stored width without an unsized
    operand.
  * The M home's explicit-range add/shift bounds (not measured here).

## Reproducing

```bash
git worktree add /tmp/wtp d92bab05 && git worktree add /tmp/wtl d92bab05 && (cd /tmp/wtl && git apply /tmp/r11u109.patch)
for d in /tmp/wtp /tmp/wtl; do cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
   -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; cp $d/build/slang-uhdm /tmp/$(basename $d).bin; chmod 555 /tmp/$(basename $d).bin; done
R=/tmp/wtl/tools/probe/r11u109repro
bash $R/six109.sh /tmp/wtl.bin lawx                                   # the six rows
bash $R/grid109.sh $R/grid/f1 /tmp/g109_f1 pris=/tmp/wtp.bin lawx=/tmp/wtl.bin   # likewise f5 hp and r11u107repro/grid
bash $R/scorearm109.sh /tmp/g109_f1/p01_base pris lawx                # per cell (cells109.py)
LAW=/tmp/wtl.bin PRIS=/tmp/wtp.bin bash $R/drops109.sh               # the switches
WDROOT=/tmp/wd109 bash $R/sweep109.sh pris /tmp/wtp.bin; WDROOT=/tmp/wd109 bash $R/sweep109.sh lawx /tmp/wtl.bin
SELFCHECK=1 bash /tmp/wtl/tools/probe/r10oth4repro/byteverify.sh /tmp/wd109_lawx/sl /tmp/wd109_pris/sl
# census: cen109.sh <row dir> <out> per row, sig109.py underneath
# boundary: BND_PRIS/BND_LAW/BND_ROOT/BND_OUT + xargs -a <list> -P 3 bnd109.sh; then bndscore109.sh per DIFFERS arm
```
