# r11u112 — the property keeps its body, the module function's typedef is copied, the named-type struct is a net, the generate part-select is a var_select, and the folded index keeps its parameter's type

**FOUR TARGET ROWS CONVERT, BOTH MODES (EIGHT ROW-MODES).** Each reads 0 uhdm-cmp
lines and 0 heads with the LAW binary, and `CMP_EQUAL` in the LAW sweep:

```
results/golden_surelog.csv:     SequenceInst,default,CMP_NOTEQUAL,decompile:,,
results/golden_surelog.csv:     SequenceInst,testflags,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:  const_cast_signext,{default,testflags},CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:  packed_array_struct,{default,testflags},CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:  unpacked_elem_partsel_comb,{default,testflags},CMP_NOTEQUAL,decompile:,,
results/gate_uhdm2rtlil.csv:    the same three rows, testflags, CMP_NOTEQUAL,decompile:,,
LAW sweep:                      all eight row-modes -> CMP_EQUAL,,,differ
```

* uhdm2rtlil: 794/10/67 -> **797/7/67** in both modes.
* Surelog: 477/6 -> **478/5** (default) and 472/5 -> **473/4** (testflags).
* `results/*.csv` were NOT edited. The master promotes.

The other three targeted rows stay `CMP_NOTEQUAL`, each with its face cleared
and a NEW head (section 6): arb_idx_cast 46 -> 18, ibex_icache 17 -> 36 (the
ibex_pmp face, fenced), ibex_pmp 36 (fenced, unchanged).

Base `1d7a03b8`. Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

| binary | md5 | what |
|---|---|---|
| pristine | `b3dc863277c4f1340e9058c8b78f2f01` | own worktree at `1d7a03b8`, `-j 2`, equals the OPS pin |
| **LAW** | `8515ddf0478b481965fbb772bf9c0248` | this patch; the same md5 when the patch is applied to a FRESH `1d7a03b8` and rebuilt |

Every law reads its own kill switch from the environment; `R11U112_OFF=1`
drops them all and then the LAW binary reproduces the pristine database, byte
for byte, on every grid arm (`evidence/DROPS112.txt`).

**Surface.** `src/ModuleEmit.cpp` (faces 2-return, 3, 4, 5) and
`src/ExprEmit.cpp` (faces 1, 2-cast). Every helper and switch is a file-local
`static` in the `.cpp` that uses it. `ParamEmit.cpp`, `EmitHelpers.h`,
`TypeEmit.cpp`, `UhdmExporter.cpp`, `include/` and `results/` are absent from
the patch; the rest of it is `tools/probe/r11u112repro/`.

---

## 1. The seven rows at `1d7a03b8` (Q1)

`seven112.sh <pristine> pris`: uhdm-cmp, LHS golden, one head per row, the
same count in both modes. Full heads: `evidence/HEADS112.base.txt`.

| row | lines | head: golden (LHS) vs ours (RHS) |
|---|---|---|
| const_cast_signext | 17 | LHS `ref_typespec (imm_t)`, parent a `logic_typespec (imm_t)` copy @14:11-14:30, actual the typedef's own `logic_typespec (imm_t)`. RHS `<null>` (we cast to the shared typedef: no alias). |
| ibex_icache | 17 | LHS `ref_typespec (work@ibex_icache.round_robin_way_q)` on the folded `IC_NUM_WAYS` @519:56-519:67, actual `int_typespec` @ibex_pkg 387:13-387:25. RHS `<null>` (constant UINT:2 sz32, no typespec). |
| ibex_pmp | 36 | LHS `constant UINT:33 sz32` @34:10 (a range bound of `region_start_addr`'s element typespec). RHS the same constant at sz64. |
| arb_idx_cast | 46 | LHS `constant INT:1 sz32 ct7` @28:64 with a ref_typespec to the localparam's `int_typespec` @22:18-22:30. RHS `ref_obj Idx1` (unfolded, unbound). |
| unpacked_elem_partsel_comb | 91 | LHS `var_select cl_rdata` @20:24-20:56 under the DEF-view gen_for cont_assign, indexes [ref_obj i, indexed_part_select cl_rdata]. RHS `<null>` (the cont_assign had no vpiRhs). |
| packed_array_struct | 499 | LHS `<null>`, RHS the elab `module_inst` whose `vpiVariables[0]` is `struct_var scalar_sig` (golden: `struct_net scalar_sig` + `packed_array_net arr`, no variables). |
| SequenceInst | 122 | LHS `operation op51` @9:28-9:69 (`\|=>`) over op54 @9:29 [ref_obj start_event -> logic_net, UINT:0, op61 ...]. RHS `ref_obj rst` @9:23 (the `disable iff` condition). |

## 2. The producer's rules and our sites (Q2)

### FACE 5 — the property declaration's `disable iff` (§ propDeclDisableIffSkip112)

* **The producer.** `CompileHelper::compilePropertyDeclaration`
  (`~/git-repos/Surelog/src/DesignCompile/CompileAssertion.cpp:501-530`,
  Surelog commit 486e98426a, inside the v1.87 pin) selects the property_spec
  children BY NODE TYPE: a leading `paClocking_event` is vpiClockingEvent, the
  following `paExpression_or_dist` (the `disable iff` condition) is SKIPPED, and
  the next sibling is the vpiPropertyExpr. No vpiDisableCondition is written.
  The inline `assert/assume/cover property` road (`:147-250`) is unchanged.
* **Our site.** `emitModuleDef`'s property-declaration loop, `src/ModuleEmit.cpp`
  (the `DisableIff` unwrap after the clocking unwrap). Our
  `AssertionExprKind::DisableIff` arm (the v1.86 truncation model, "the spec's
  vpiPropertyExpr is the rst ref alone") stays for the inline road.
* **Body fence.** The kept body goes through `emitAssertionExpr`, and two of its
  sub-shapes are not golden there (a ranged delay `##[1:2]`, a sequence
  instance). The law declines those bodies (`propBodyFenced112`) so no cell
  moves to a shape golden does not hold.

### FACE 2 — the module-local typedef inside a module function (§ modFnLocalTdCastClone112, § modFnLocalTdRetClone112)

* **The producer.** Surelog compiles a module subroutine's body per
  (subroutine, view). A typedef-named cast target or return type resolved
  through `compileTypespec`'s TypeDef arm is CLONED, named after the typedef and
  aliased to the shared object.
* **The cast half.** `src/ExprEmit.cpp`, the cast gate's named-typedef arm
  ("$UNIT function bodies AND module-scope cast sites both mint the fresh
  self-named clone"). That gate had no module-function home. The law mints the
  same `bypassTypedefShare` clone (no instance) for a logic, bit or int typedef
  declared in the subroutine's own module body.
* **The return half.** `drainFuncRet`, `src/ModuleEmit.cpp` (called from the
  two sites the brief names). The body-local return variable took the SHARED
  typedef object and re-parented it. The law mints the `$unit`-typedef pair:
  clone (no instance) -> alias `<local>.t` -> second clone carrying
  vpiInstance = the module.
* In the `-elabuhdm` form golden binds the body reference to the function's own
  vpiReturn variable, which the judge reaches first, so the return half is
  judge-invisible there (grid t05/t14 elab: 0 lines before and after).

### FACE 3 — the type-parameter struct declaration's kind (§ tpStructKindNet112)

* **The producer.** `NetlistElaboration::elabSignal`
  (`NetlistElaboration.cpp:2050-2153`). A data-typed Signal with no net keyword
  starts as a variable. The typespec dispatch's `uhdmstruct_typespec` arm then
  re-asserts `isNet` and runs the LOOSE member scan (logic or struct members
  mean net). For a type-parameter NAME the scanned typespec is the parameter's
  DEFAULT, so the default decides the kind. Written packed dims are a separate
  `compileRanges`: they wrap the `struct_net` in a `packed_array_net` with no net
  type and no typespec on the wrapper.
* **Our sites** (`src/ModuleEmit.cpp`, `emitInstance`):
  * **Scalar cell.** `typeParamTyped` demoted every type-parameter declaration
    whose default is not in `typeParamDefaultTs`. Only the HEADER port list fills
    that table, so a body `localparam type` became a `struct_var`.
  * **Dims cell.** § tpDefaultStructIsNet41's packed half calls
    `emitPackedStructArrayNet`, which finds the element typespec only through
    `typedefTs`. An ANONYMOUS struct default has no entry there, so the call
    returned null. The law LENDS `typedefTs` the parameter's resolved struct
    typespec for that one call and removes it afterwards (no TypeEmit edit).
* **The gate** is a keyword-less, uninitialised body Variable written as a
  type-parameter name whose parameter is local or not overridden, and whose
  struct passes the loose scan (or 41's default-decides test).

### FACE 4 — the generate-scope element part-select (§ defGenElemIpsVarSel112)

* **Golden.** A `var_select x` spanning the whole select, with vpiIndex = the
  bit indexes (scoped `<scope>.x.i`) followed by one `indexed_part_select x`:
  * fullname `<scope>.x.x`, vpiDefName `x`, vpiConstantSelect 1, type 1/2;
  * its BASE is scoped through `<scope>.x.x` and its WIDTH through `<scope>.x`;
  * a constant base or width is unparented.
* **Ours.** TypeEmit's syntax var_select chain admits only bit and simple-range
  selectors and ABSTAINS on `+:` / `-:`, so the DEF-view cont_assign carried no
  vpiRhs.
* **The fix site.** `TypeEmit.cpp` is fenced, so the law builds the shape at the
  def gen-block cont_assign site in `emitDefGenStmts`' `emitBranch`
  (`src/ModuleEmit.cpp`). It hands every sub-expression to the same
  `emitSyntaxExpr`, handles both parse shapes (`IdentifierSelectName` and
  nested `ElementSelectExpression`), and decides before any Make call.
* **Gated to a LOOP generate** (see residue R4b).

### FACE 1 — the folded parameter read keeps its parameter's type

* **The producer.** `CompileHelper::compileExpression`'s identifier arm
  (`CompileExpression.cpp:2880-3040`) has two outcomes:
  * a clone of the parameter's `param_assign` Rhs that carries the parameter's
    own declaration typespec (`res->Typespec(tps_rt)`, `:2918-2927` /
    `:2985-2996`);
  * a constant minted from the instance's evaluated value `sval` (`:3027-3040`),
    sized by the value (32 for an int) and WITHOUT a typespec unless it is
    signed. This is the ibex_pmp range bound.
* **§ caSelIdxOpFoldTs112** (ibex_icache; `src/ExprEmit.cpp`, the
  imported-parameter fold stamp).
  * The landed stamps covered a DIRECT bit-select index (§ selFold9) and an
    operation chain reaching the cont_assign (§ caOpFoldTs). An operation under
    a cont-assign bit_select fell between the two.
  * The law walks operations, then one bit_select, then operations, to the
    cont_assign. It names the ref after the select and clones the parameter's
    typespec per reference (the § caFold9 rule).
  * Gated to a TYPED package parameter read unqualified.
* **§ genLpIdxOpOperandFold112** (arb_idx_cast; `src/ExprEmit.cpp`).
  * § genLpUseFoldParentScope47 measured golden substituting a ONE-HOP
    gen-scope localparam "in an operation operand" too, and § 67 wired only the
    bare bit-select index.
  * The law arms the same `genLpUseFoldBound47` for the OPERANDS of a
    bit-select index operation and of a var_select's element indexes (bare or
    operation), in the elaborated gen-scope cont_assign. It uses § 67's fences.
* **The shared helper for pair P.** The one this pass would have put in
  `EmitHelpers.h` is the stamp predicate "a folded read of a TYPED parameter
  keeps its declaration typespec as a per-reference ref_typespec, whatever the
  select/operation depth". Here it is `caSelIdxOpFoldTs112` plus its position
  walk (`selIdx112`); ParamEmit's param_assign-RHS home (Rggen) is the same
  producer line (`:2918-2927`). The master can unify the two after both land.
* **ibex_pmp** (the `sval` road, sized 32, no typespec) is a range bound of a
  variable's typespec, built by `makeTypespec` / `sharedTypespec` in
  `TypeEmit.cpp`. That file is FENCED, so this face stops at the decode
  (residue R1b).

## 3. The golden grid (Q3)

All goldens are real pinned Surelog v1.87 runs (`grid112.sh`, both forms:
`-parse -nobuiltin -nocache -sv` and `-parse -elabuhdm -nobuiltin`). Every
scored arm reads golden `rc=0`. Arm p08 was first written with an inline
`assume ... disable iff` that Surelog REJECTS (rc 4); that statement was removed
(an arm whose compile fails teaches error recovery). g01 (the arb_idx_cast
copy) reads `rc=4` on OUR side on both binaries: an `Invalid` expression is
reported unsupported and the database is written, which is the corpus row's own
condition.

| dir | arms | varies |
|---|---|---|
| `grid/p` | 11 | property decl x {clock+disable, disable only, clock only, neither} x body {`\|=>`, `\|->`, `##1`, `not`, formals, two props, ranged delay, sequence instance} + the inline-assert control p08 |
| `grid/t` | 14 | module typedef x {logic signed/unsigned, parameter bound, bit, int, struct} x {function cast, `return` cast, task cast, return only, cast only, two functions, child instance, module-scope cast control} |
| `grid/k` | 23 | type parameter {body localparam, body `parameter type`, header default, header overridden, alias of a typedef} x members {all logic, nested struct, int, bit, union} x spelling {none, `wire`, `var`} x dims {none, one, two, unpacked} x {assign, comb, ff, init, child} |
| `grid/v` | 11 | `x[i][B +: W]` x {`-:`, constant base, literal width, two bit indexes, packed 2-D, gen-if, nested gen, module scope, always_comb, simple range control} |
| `grid/f` | 43 | f: imported pkg param in a cont-assign bit-select index {`-`,`+`,`*`, nested under `&`} x {int unsigned, int, untyped, logic[3:0]} x {header/body import, qualified, module param, always_comb}; g: gen localparam at distance {0,1,2} x {bit_select, var_select} x {bare, op, concat, lhs, else branch, untyped}; r: range bounds (the fenced ibex_pmp face) |

Measured golden answers:

| face | golden |
|---|---|
| 5 | Every property DECLARATION with `disable iff`: vpiClockingEvent (if written) + the property expression; no disable condition. The inline assert (p08) is unchanged. |
| 2 | A cast in a module function/task to that module's typedef: a fresh `<kind>_typespec(t)` (no instance) aliased to the typedef, for logic/bit/int alike. The body-local return var (non-elab form): clone -> alias `<local>.t` -> instanced clone. t07/t08 (bit/int) keep a head at the function's vpiReturn (residue R2b). |
| 3 | Loose-net struct (all logic / nested struct), local or not overridden: `struct_net` (nt 0), dims `packed_array_net` of `struct_net`s. `wire`: `struct_net` nt 1 with the dims DROPPED. `var`: `struct_net` nt 0, dims dropped. int/bit member: `struct_var` / `packed_array_var` of `struct_var`s with a typespec. Union: `union_var` / `packed_array_var`. |
| 4 | `var_select` with [bit indexes..., indexed_part_select] in every loop-generate arm; gen-if also var_select. |
| 1 | Imported typed package parameter under an operation in a cont-assign bit-select index: constant + ref_typespec (named after the select) -> the parameter's typespec, in every position measured; qualified `pk::P` stays bare; a module parameter / always_comb / bare index were already golden. One-hop gen localparam operand: `constant INT:<v> sz32 ct7` + ref_typespec -> the localparam's typespec; distance 0 and 2 keep the reference. |

## 4. The laws, each droppable alone (Q4)

`drops112.sh`: the LAW binary with one switch set, every grid arm in the
non-elab form, compared byte for byte (`evidence/DROPS112.txt`).

| switch | law | arms that move when dropped |
|---|---|---|
| `R11U112_OFF` | all | 53; **= pristine on every one** |
| `R11U112_PROPDIS_OFF` | § propDeclDisableIffSkip112 | p01 p02 p03 p06 p07 p09 p10 |
| `R11U112_TDCAST_OFF` | § modFnLocalTdCastClone112 | t01-t04 t06-t10 t13 |
| `R11U112_TDRET_OFF` | § modFnLocalTdRetClone112 | t01-t03 t05 t07 t08 t10 t13 t14 |
| `R11U112_TPNET_OFF` | § tpStructKindNet112 | k01-k03 k07 k12 k13 k15-k17 k19 k20 |
| `R11U112_GENIPS_OFF` | § defGenElemIpsVarSel112 | v01-v04 v07 v10 |
| `R11U112_SELIDXTS_OFF` | § caSelIdxOpFoldTs112 | f01 f03 f04 f06 f09 f11 f12 |
| `R11U112_GENLPOP_OFF` | § genLpIdxOpOperandFold112 | g01 g11 g13 g14 g16-g21 |

## 5. Census and the a-priori mover set (Q5)

`sig112.cpp` (via `cen112.sh`) reads each row's golden and PRISTINE databases
and counts one signature per face. Each signature is a superset of its law's
gates:

* F2C: cast ops whose typespec actual has a Typedef_alias.
* F2R: return locals under a ref_obj whose typespec actual has an alias.
* F3N: struct_net / packed_array_net objects under a module_inst.
* F4V: var_selects ending in an indexed_part_select.
* F1T: typed constants under an operation under a bit_select.
* F5P: property_decl specs whose expression is an operation.

Results (`evidence/CENSUS112.txt`):

* **Calibration** (golden read as both sides): **0 rows** of 2568.
* **Positive control / corpus reach, pristine** (+ = golden holds more). Exactly
  the target rows, and no other row carries a positive delta:
  * SequenceInst F5P +1 / +2
  * const_cast_signext F2C +1 F2R +1
  * packed_array_struct F3N +2
  * unpacked_elem_partsel_comb F4V +1
  * arb_idx_cast F1T +2
  * ibex_icache F1T +1
* Negative deltas are the UVM family (F2R) and Earlgrey_0_1/testflags (F2R, F4V).
  There we clone more objects than golden shares: the multiset trap,
  judge-invisible, and unmoved by the laws (the LAW-sweep census shows the same
  negative deltas).

**PREDICTED MOVERS BY NAME:**

* the six targeted rows that carry a law face, x 2 modes (ibex_pmp predicted
  UNMOVED: its face is fenced);
* the UVM family's documented 0/4-line class (MiniAmiq, SeqDriver, SimpleUVM,
  and Scoreboard/default's coin).

**Nothing else.**

## 6. The laws measured (Q6)

**Sweeps.** Both corpora, both modes, `--jobs 3`, own workdirs with
same-length tags (`pris` / `lawf`), `SLANG_UHDM` exported, every `cmds.txt`
naming its frozen binary (u2r 1742/1742 `lawf.bin`; surelog 1531 `lawf.bin`
rows with a slang run).

* Pristine = the committed baselines status-for-status and row-for-row, except
  the LowMem log-path text.
* LAW = the baselines except the eight converted row-modes quoted at the top
  (plus the same LowMem log-path text). Earlgrey_0_1's dump column is not blank
  in this draw.

**byteverify** (`SELFCHECK=1`, identical path sets; `evidence/BYTEVERIFY112.txt`):

* u2r **10/1608**: the five moved target rows x 2 modes (arb_idx_cast,
  const_cast_signext, ibex_icache, packed_array_struct,
  unpacked_elem_partsel_comb).
* Surelog **7/960**:
  * SequenceInst x 2;
  * MiniAmiq x 2, SeqDriver x 2 and SimpleUVM/default, each an order-blind 4
    lines (`UINT:0 <-> UINT:1461` + `vpiDecompile:0 <-> 1461`: the documented
    line-number class; every UVM row stays `CMP_EQUAL`).
* **Exactly the prediction.**

**Protected databases, both modes, byte-identical to pristine:**

* Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`
* SVSwitch `4842211c4030`
* YosysVerx `6ccda350c24a`
* InterfaceModPort `59a365f3ce2c`
* BlackParrotComplex
* YosysOldOr

**Canary battery** (`evidence/CANARIES112.txt`):

* canaries ok=52/8 changed=0
* ctcan2 PASS (both)
* canaudit UNCOVERED=0 FENCE-BREACH=0

**Goldens:** 23/0 (pristine and LAW), `/bin/false` 0/23.

**Per cell** (`cells112.py` = `r11u109repro/cells109.py`; typespec clones sit
in the `weaklyReferenced` tail and are judged by the cmp count instead):

* The 12 moved target databases: **TO 311, AWAY 0, MOVED-WRONG 0**
  (`evidence/MOVERS112.cells.txt`).
  * Whole-dump distance to golden, order-blind: SequenceInst 76 -> 4 / 143 ->
    26, packed_array_struct 203 -> 156, unepc 60 -> 18, const_cast 179 -> 122,
    arb 501 -> 457, ibex_icache 7506 -> 7496.
* Grid: 128 moved arm-forms, **all AWAY 0, MOVED-WRONG 0**
  (`evidence/SCORE112.txt`).
* **Controls.** `ctl112.sh`: 948 compiles of every `.sv` under r11u109repro,
  r11u106repro, v11u94repro, r11u108repro, v11u108repro, r11u107repro, the
  main tree's (staged) r11u110repro/grid, and this grid, both forms.
  * Byte-identical except this grid (106) and 22 named control cells
    (`evidence/CTL112.txt`).
  * r11u108repro/grid/f4 c01-c03 c06-c09 c11 c12 are pass 107's own face-2
    arms: every one 17 -> 0 lines. c12/elab is 17 -> 50, the same masked
    pre-existing call-fold head as t01/elab.
  * r11u107repro/grid t10_body_tp_struct 293/301 -> 0 and t08_tp_ustruct
    (88 = 88, TO 15): face 3.
  * All are scored TO with AWAY 0.

**The seven rows, after** (`evidence/HEADS112.law.txt`, both modes equal):

| row | before | after | next head |
|---|---|---|---|
| SequenceInst | 122 | **0** | converted |
| const_cast_signext | 17 | **0** | converted |
| packed_array_struct | 499 | **0** | converted |
| unpacked_elem_partsel_comb | 91 | **0** | converted |
| arb_idx_cast | 46 | 18 | LHS `unsupported_typespec (idx_t)` @26:36 (the `idx_t'(sel)` cast in `gen_levels[1]…gen_first_level`), RHS `integer_typespec` @26:36 — a type-parameter cast target (residue R5) |
| ibex_icache | 17 | 36 | LHS `constant UINT:1 sz32` @138:22, the range bound of `fill_ext_cnt_q`'s element typespec, RHS the same at sz64. This is R1b, the ibex_pmp face. |
| ibex_pmp | 36 | 36 | unchanged (R1b, fenced) |

## 7. Residues (ranked)

* **R1b — the typed package parameter's range bound is sized by its type**
  (ibex_pmp 36, ibex_icache 36; grid f/r01 r02 r04 r07-r09).
  * The producer is the `sval` road: size = the value's (32), no typespec.
  * The site is `makeTypespec` / `sharedTypespec`'s range-bound constant,
    `src/TypeEmit.cpp`, which is FENCED to the typespec ground.
  * `pkgVarDimBoundEnc82` (TypeEmit) already encodes it for the
    packed-struct-array declaration copy only.
  * An arithmetic bound (`[P-1:0]`, r03), a module parameter (r05) and an
    untyped parameter (r06) are already golden.
* **R1c — an untyped package parameter under the index operation**
  (grid f05). Golden stamps too, but its typespec is an UNSIGNED int_typespec
  and our materialised one (ParamEmit) is signed. § caSelIdxOpFoldTs112 declines
  untyped parameters, so the cell stays at 17 lines instead of moving to a wrong
  sign.
* **R5 — arb_idx_cast's type-parameter cast target** (18 lines): golden
  `unsupported_typespec (idx_t)` in `gen_levels[1]`, ours an `integer_typespec`.
* **R2b — bit / int module typedef, the function's own vpiReturn** (grid t07,
  t08: 17 lines). Our `bit_var` sits at the typedef span with the shared
  typespec. The site is TaskFuncEmit.cpp (outside this pass's files).
* **R3 — face 3's other spellings**, each measured, each a different shape:
  * `wire` / `var` + dims drop the dims (k04, k05);
  * a non-net member makes a `packed_array_var` of `struct_var`s with a typespec
    (k06, k11);
  * a union (k10);
  * an initializer (k18/u2r);
  * an overridden parameter (k21-k23).
* **R4b — face 4 in an if-generate** (grid v05). Golden is the same var_select,
  but there our base-expression `off_i` comes out BOUND (golden unbound). This
  is a pre-existing def gen-if binder, so the law is gated to loop generates.
* **R5b — property bodies the face-5 fence declines** (grid p10's `##[1:2]`,
  p11's sequence instance). Their `emitAssertionExpr` shapes differ from golden
  inline as well.
* **R6 — t01/elab and c12/elab**: golden keeps the module function CALL where we
  fold it (a masked pre-existing face; not a corpus form for these rows).

R0 = R1b (two rows, one site, fenced to the typespec ground).

## Scripts

| script | what |
|---|---|
| `seven112.sh` | the seven rows, both corpora and modes, uhdm-cmp |
| `grid112.sh` | golden + ours per arm, both forms, cmp |
| `score112.sh` | per-cell scoring, pris -> law |
| `drops112.sh` | per-switch drops |
| `ctl112.sh` | control byte compare |
| `sweep112.sh` | both corpora, both modes |
| `cen112.sh` + `sig112.cpp` | census |
| `kinds112.cpp` | net / var shape lister |
| `tsref112.cpp` | typespec referrer lister |
| `cells112.py` | the pass-108 cell scorer |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the r10uvm221 battery |
