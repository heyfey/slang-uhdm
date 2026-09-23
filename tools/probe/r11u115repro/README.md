# r11u115 — the typespec line, third round: the generate-scope fold's typespec and the interface port view's declaration fold

**ONE TARGET ROW CONVERTS (surelog, default mode).** `Rggen/default` reads 0
uhdm-cmp lines and 0 heads with the LAW binary, and `CMP_EQUAL` in the LAW
sweep:

```
results/golden_surelog.csv:  Rggen,default,CMP_NOTEQUAL,decompile:,,
LAW sweep:                   Rggen,default,CMP_EQUAL,,,differ
```

* Surelog: 479/4 -> **480/3** default; testflags unchanged at 474/3
  (`Rggen,testflags` is `SURELOG_FAIL` at the base and stays so).
* uhdm2rtlil: unchanged, 800/4/67 both modes. `ibex_icache` stays
  `CMP_NOTEQUAL`: both of its faces cleared, and a NEW head is unmasked
  (section 6).
* `results/*.csv` were NOT edited. The master promotes.

Base `6158f101`. Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

| binary | md5 | what |
|---|---|---|
| pristine | `792f69ec51a24e96b5658b66d1bb8690` | own worktree at `6158f101`, `-j 2`; equals the main tree's binary |
| **LAW** | `1d5daafa48a3addbf3249413c0d9e104` | this patch; the same md5 when the patch is applied to a FRESH `6158f101` and rebuilt |

Every law reads its own kill switch from the environment. `R11U115_OFF=1`
drops them all, and then the LAW binary reproduces the pristine database byte
for byte on every grid arm-form (310/310, `evidence/DROPS115.txt`).

**Surface.** `src/ExprEmit.cpp` (faces 1 and 3) and `src/ModuleEmit.cpp`
(face 2). Every helper and switch is a file-local `static` in the file that
uses it. `ParamEmit.cpp`, `EmitHelpers.h`, `StmtEmit.cpp`, `include/` and
`results/` are not in the patch. Everything else is
`tools/probe/r11u115repro/`.

---

## 1. The two rows at `6158f101` (Q1)

These are uhdm-cmp runs with LHS = golden, one head per row. Full text is in
`evidence/HEADS115.base.txt`.

| row | lines | head: golden (LHS) vs ours (RHS) |
|---|---|---|
| ibex_icache (u2r, both modes) | 17 / 1 | LHS: `ref_typespec (work@ibex_icache)` on the folded constant @ibex_icache.sv 759:38-759:53, actual `int_typespec` @ibex_pkg.sv 393:13-393:25. The constant is the replication count `{{IC_LINE_BEATS_W{1'b0}},fill_spec_done}` in the ternary arm of the gen-for `gen_fbs[0]` cont_assign. RHS: `<null>`. |
| Rggen (surelog, default) | 64 / 1 | LHS: `constant UINT:32` (decompile `32`, size 32) @4:33-4:42 under the `param_assign` 4:17-4:42 of `work@rggen.u_block_0.u_adapter.register_if[0]`, ts ref -> `int_typespec` 4:13-4:16. RHS: the same constant with **`UINT:64`** (decompile `64`) and the same ts ref. |

## 2. The producer's rules and our sites (Q2)

### FACE 1: a folded typed package parameter read in a generate-scope elaborated cont_assign

* **The producer.** `CompileHelper::compileExpression`'s identifier arm
  (Surelog `src/DesignCompile/CompileExpression.cpp:2918-2927`) swaps a
  parameter read for a copy of its value. The copy carries the parameter's
  own declaration typespec (`res->Typespec(tps_rt)`) wherever the read is
  reached from. A generate block is a scope, not a compilation mode.
* **Our site.** `src/ExprEmit.cpp`, the package-parameter fold in
  `emitExpr`'s NamedValue arm. There, `caOpFold9` (§ caOpFoldTs /
  § caOpFoldElabTs72) walks operations up to the cont_assign. It required
  `contAssignView != 0`, and the elaborated gen-scope cont_assign never sets
  that flag (`inGenScopeCaRhs` marks it instead).
* **What the grid showed (section 3).** Every operand position stamps in both
  forms: replication count (bare, in a concat, under `+`, in a ternary arm),
  concat element, ternary arm, shift amount, `==`, `+`, `-`, and a
  SYSTEM-FUNCTION argument (`q + $clog2(P)`, module scope too). A BARE
  var_select index (`q[fb][P]`) also stamps; that is ibex_icache's second
  face, unmasked once the first cleared.
* **Controls.**
  * A user-function argument `f(P)` keeps a ref_obj on both sides.
  * A NESTED generate block does not fold at all (§ genNestedScopePkgParamNoFold24).
  * Module parameters, module localparams and generate localparams do not stamp.
  * An UNTYPED package parameter stamps, but golden's materialised typespec is
    unsigned and ours signed (a ParamEmit object, residue R5b).
  * A QUALIFIED `pk::W` in a generate scope folds BARE in golden, where we keep
    the ref_obj (a fold-decision residue).

### FACE 2: the interface port view's param_assign value

* **The producer.**
  * A port view is a FRESH `ModuleInstance` of the interface definition whose
    parent is the RECEIVING instance. It is elaborated from the definition
    (`NetlistElaboration.cpp:1913-1934`).
  * The connected instance's param_assigns are copied onto it only by
    `propagateIfaceParams_` (`:798-815`). That copy happens only when
    `getInterfaceInstance_` (`:817-970`) finds the actual among the
    sub-instances of the receiver's IMMEDIATE parent. The search never
    matches an `arr[i]` element, and it misses an actual that is declared
    outside that parent scope.
  * The fresh copy's value lookup is `ModuleInstance::getValue`
    (`src/Design/ModuleInstance.cpp:143-192`). It climbs param_assigns
    through non-module instances and stops at the first MODULE
    instantiation, which is the receiver.
* **Our site.** `src/ModuleEmit.cpp`, `emitInterfaceInstance`, in the
  `ifaceDefaultScope` arm. That is the arm of pass 111's prototype and of the
  § ifacePortViewParamAssignsOnly restamp. The named-modport switch
  `namedModportPortView9` is also in this function.
  * The restamp copied only LITERAL defaults, and it copied the declaration
    literal even when the receiver declared the same name.
  * An expression default kept the CONNECTED instance's value.
  * Every named-modport view was treated as the connected-instance view, even
    when `actualOutOfScope16` (already computed in this function) showed that
    Surelog's lookup misses.

## 3. The golden grid (Q3)

All goldens are real pinned Surelog v1.87 runs, in both forms:
`-parse -nobuiltin -nocache -sv` (u2r) and `-parse -elabuhdm -nobuiltin`
(elab). Every one of the 310 arm-forms reads golden `rc=0` with `[ERROR] : 0`.
`mkgrid115.py` writes `grid/r` and `grid/i`. `grid/c3` holds copies of pass
112's arms (r11u113repro `c03 c06 c13 c16 c18 c25 c27 b07`, v11u113repro
`t04 t09`). `grid115.sh` runs golden and ours per arm and records `rc` for
both. The table is in `evidence/GRID115.txt`.

Our `rc=4` is the exporter's "unsupported constructs: expression kind
Invalid" exit. It is not an SV compile failure, and the database is written.
On the c3 arms it is the type name bound as an expression, which is exactly
the face under test.

| dir | arms | what varies |
|---|---|---|
| `r/f` | 13 | gen-for, positions p01-p13 (the ibex shape; replication count bare / in a concat / under `+` / in a ternary arm; concat element; ternary arm; shift amount; `==`; `+`; `-`; user-function argument; sys-function argument) |
| `r/i`, `r/m`, `r/n` | 11 / 11 / 6 | the same positions in a gen-if, at module scope, and in a gen-if nested in a gen-for |
| `r/k`, `r/mk` | 21 / 12 | parameter kind x {p01, p02, p09}: int unsigned with a literal initializer, int, untyped, logic [3:0], qualified, module header parameter, module localparam, gen localparam, body import; the module-scope twins |
| `r/v` | 14 | a bare var_select index: module, gen-for, gen-if, under `\|`, ternary arm, always_comb, untyped, qualified, int, Lhs; module-localparam and bit_select controls |
| `r/x` | 1 | the ibex_icache shape verbatim |
| `i` | 56 | interface `itf #(A=16, B=32, C=B, D=A*2)`, element `#(8,32,64)`. Varies: element vs whole array vs single instance; modport vs plain port; named vs positional connection; receiver in the module, a gen-if, a gen-for or an inner gen block; receiver parameters (header/body, int/bit/longint/negative/string/type, A/B/C/D shadowed, an ancestor's A); interface localparams; parenthesised and operation defaults; named-modport actual out of scope / a passthrough port / the same gen block |
| `c3` | 10 | pass 112's R2b/R2c/R1c arms |

**Measured golden answers:**

| face | golden |
|---|---|
| 1 | Gen-for and gen-if stamp `ref_typespec -> the parameter's typespec` on every operation position and on a sys-function argument, in both forms, for int unsigned (literal or `$clog2` initializer), int and logic[3:0]. At module scope the operation positions already matched; the sys-function argument and the bare var_select index did not. A bare var_select index stamps (named after the var_select) at module scope, gen-for, gen-if and in always_comb, on the Lhs too. |
| 2a | A port view that does not read the connected instance takes these values. A literal or bare-name default takes the RECEIVER's same-named VALUE parameter: header or body, any integral type; UINT ct 9, or INT ct 7 when negative. An expression default the receiver does not shadow folds at the DECLARATION: a bare name (even parenthesised) reads the definition's value (`C = B` -> 32 with a receiver `B = 40`), and an operation reads the receiver-substituted scope (`D = A*2` -> 10; `C = B + 0` -> 40). No shadowing from a type parameter, a variable, an ancestor's parameter, or onto an interface LOCALPARAM. |
| 2b | A named-modport view whose actual is not declared in the receiver's instantiating scope is a fresh copy, not the connected view: n05, o01, o06, o07, o08, and o02/o03, which are Rggen's passthrough of the enclosing module's own port from a gen-if. Golden gives the declaration/receiver values and no `vpiOverriden`. The controls o04 (passthrough from the module body) and o05 (actual in the same gen block) keep the connected values. |
| 3 | The type-parameter cast keeps `unsupported_typespec` in three more places: parenthesised (t04); under a ternary or operation in an IF-generate with no enclosing loop (c06, c18); for a `localparam type` of an OUTER gen block (t09). Under a loop (c25, c27, arb_idx_cast's if-in-for `gen_other_levels`) and at module scope or in always_comb (c03, c13, c16) it resolves to the default's `logic_typespec` (not landed, R2b). |

## 4. The laws, each droppable alone (Q4)

`drops115.sh` runs the LAW binary with one switch set on every grid arm-form
(310) and compares bytes (`evidence/DROPS115.txt`).

| switch | law (file) | arm-forms moved by the drop |
|---|---|---|
| `R11U115_OFF` | all | 194; **= pristine on 310/310** |
| `R11U115_GSOP_OFF` | § genCaOpFoldElabTs115 (ExprEmit): `caOpFold9` also fires for `contAssignView == 0 && inGenScopeCaRhs && !defGenProcessEmit`, typed package parameters only | 62 (r/f, r/i, r/k typed, r/x) |
| `R11U115_SYSARG_OFF` | § caSysArgOpFoldTs115 (ExprEmit): a sys-func argument under an operation chain of a module or gen-scope cont_assign; per-reference clone; re-parented at the package param_assign as golden does | 6 (p12 x m/f/i) |
| `R11U115_VSBARE_OFF` | § caVarSelBareIdxTs115 (ExprEmit): a bare var_select index in a module or gen-scope cont_assign Rhs; parented at the var_select, ref named after it | 14 (r/v) |
| `R11U115_PVRECV_OFF` | § pvRecvShadow115 (ModuleEmit, `pvFold115`) | 58 |
| `R11U115_PVEXPR_OFF` | § pvExprDefaultFold115 (ModuleEmit, `pvFold115`) | 104 |
| `R11U115_NMPOOS_OFF` | § namedModportOutOfScopeFresh115 (ModuleEmit): `namedModportPortView9 &= !actualOutOfScope16` | 14 (n05, o01-o03, o06-o08) |
| `R11U115_TPPAREN_OFF` | § genCaTypeParamCastParen115 (ExprEmit): unwrap the parenthesis slang hands as the conversion's syntax, only for a type-parameter target in the gen-scope cont_assign | 2 (t04) |
| `R11U115_TPIFOP_OFF` | § genIfCaTypeParamCastUnderOp115 (ExprEmit): under an operation chain in an if-generate with no enclosing loop | 4 (c06, c18) |
| `R11U115_TPOUTER_OFF` | § genCaTypeParamCastOuterBlock115 (ExprEmit): r11v113's generate-home fence narrowed to the cast's OWN block | 2 (t09) |

Each switch moves only its own face's arms.

**Pass 111's prototype, as landed, is not the whole face.** The prototype read
every non-literal default in the receiver-substituted scope and wrote `UINT:`.
On the grid that is MOVED-WRONG in four places:

* `C = B` with a receiver `B` (e13: golden 32, prototype 40);
* an operation default (`D`: golden `INT:` ct 7);
* s10 (an operation default the receiver shadows);
* s16 (a string receiver value).

The landed `pvFold115` keeps the value kind and abstains on s10 and s16.

## 5. Census and the a-priori mover set (Q5)

`cen115.cpp` (via `cen115.sh`, scored by `censcore115.py`) reads each row's
golden and our database. It records two signatures:

* F1: constants reached from a cont_assign Rhs through operations, one
  sys-func argument, or as a var_select index. Split typed/untyped and
  gen/module. It is a containment walk: golden re-parents replication counts.
* PV: the multiset of interface_inst param_assign values.

Pass 112's `sig113` gives the face-3 signature C2U. Results are in
`evidence/CENSUS115.txt`.

* **Calibration** (golden read as both sides): 0 rows of 1608 (u2r) and 0 of
  960 (surelog).
* **Positive control:** grid arms p01, x01, v02, p12, e04, o01 and s04 read a
  delta on pristine, and 0 on the LAW binary (two residuals are explained
  there). The nested control r/n reads 0 on both.
* **Reach, pristine.**
  * u2r: the typed deltas are ONLY ibex_icache: `G_OP_T+20 G_VS_T+16` in both
    modes. ibex_multdiv_* and multiplier show an untyped multiplicity only.
  * surelog: the PV deltas are ONLY Rggen/default (95/95). The ours-only PV
    of GenForIfaceLocalparamBound and its siblings, and the Earlgrey/BasicOh
    F1 lines, are pre-existing and outside every gate.
  * C2U (face 3): arb_idx_cast +2 (its judge-invisible `gen_other_levels`
    copies, which resolve in golden and are outside the law), Scr1SvTests +1,
    SeqDriver/SimpleUVM -1 (a `$unit` / class shape, outside the gate).
    Face 3 is grid-only.

**PREDICTED MOVERS BY NAME:** ibex_icache x 2 modes (u2r) and Rggen/default
(surelog), plus the UVM family's documented 0/4-line class. Nothing else.

**LAW census:** the ibex_icache and Rggen deltas are 0. Every other row's
signature is identical to pristine.

## 6. The laws measured (Q6)

**Sweeps.** Both corpora, both modes, `--jobs 3`, own workdirs with
same-length tags (`pris` / `lawy`), `SLANG_UHDM` exported. Every `cmds.txt`
names its frozen binary: pris.bin 3273 slang runs, law8.bin 1742 u2r + 1531
surelog. Results are in `evidence/ROWS115.txt`.

* Pristine sweep = committed baselines, row for row. The only exceptions are
  Earlgrey_0_1's dump column (blank-on-timeout draws).
* LAW sweep = committed baselines, except the conversion quoted at the top
  and the same Earlgrey dump-column draw (testflags).
* `ct8rows.sh`: PASS vs `gate_uhdm2rtlil.csv`, vs `golden_uhdm2rtlil.csv`
  (both modes), and vs the pristine u2r CSVs. Surelog shows exactly Rggen
  plus the Earlgrey dump column.
* All twenty-four earlier conversion rows stay `CMP_EQUAL` in both modes.
  arb_idx_cast, cfg_func_width_loop and LargeValue2Struct are byte-identical
  (not movers).

**byteverify** (`SELFCHECK=1`, identical path sets; `evidence/BYTEVERIFY115.txt`):

* u2r **2/1608**: ibex_icache default and testflags.
* surelog **7/960**:
  * Rggen/default;
  * MiniAmiq x 2, SeqDriver x 2 and SimpleUVM/default: each an order-blind
    4 lines of `UINT:<line>` / `vpiDecompile:<line>`, the documented
    line-number class;
  * Scoreboard/default: 0 lines order-blind, the order coin.
  * Every UVM row stays `CMP_EQUAL`.
* **Exactly the prediction.**

**Protected databases, both modes, byte-identical to pristine**
(`evidence/CANARIES115.txt`):

* Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`
* SVSwitch `4842211c4030`
* YosysVerx `6ccda350c24a`
* InterfaceModPort `59a365f3ce2c`
* BlackParrotComplex and YosysOldOr: SAME

**Battery:**

* canaries: ok=51 changed=1 (Earlgrey_0_1/testflags dump column, the timeout
  draw; its database is byte-identical), and ok=8 changed=0.
* ctcan2: PASS (both).
* canaudit: UNCOVERED=0 FENCE-BREACH=0.

**Goldens:** 23/0 (LAW and pristine); `/bin/false` 0/23.

**Per cell.** The scorer is `cells115.py`: pass 109's scorer, with
param_assign cells now keyed on the Lhs parameter NAME. Golden's port-view
Lhs is the DEFINITION's parameter object (`work@itf.C`). Distance is from
`dist115.py`.

* **Targets:**
  * ibex_icache x 2: TO 80, AWAY 0, MOVED-WRONG 0; distance 7472 -> 7120.
  * Rggen/default: TO 188, AWAY 0, MOVED-WRONG 0; distance 76532 -> 76158.
  * All tail cells are TAIL-TO.
* **Grid, pristine -> LAW** (`evidence/SCORE115.txt`): 194 arm-forms moved.
  TO 1280, **AWAY 0**; tail 491 TAIL-TO.
  * The only MOVED-WRONG (16) are w04/w05, the PLAIN interface-array port.
    Golden lists ONE view `u.p` there; ours lists `u.p[0]` / `u.p[1]` (that
    arm's pre-existing 94-line `array_typespec` head), so the path keys
    differ.
  * Element-name-normalised, those four arm-forms read TO 2, AWAY 0,
    MOVED-WRONG 0 each: our C moved 64 -> 32, which is golden's `u.p` value.
* **Controls.** `ctl115.sh` compiles every `.sv` under r11u113, v11u113,
  r11u112, v11u112, r11u111, v11u111, r11u110, v11u110, r11u109, r11u108,
  v11u108, r11u107, r11u106, r11u105 and v11u94 in both forms: 2096 compiles,
  2058 SAME (`evidence/CTL115.txt`). The 14 DIFF are this pass's named cells:
  * r11u113 c06/c18 and v11u113 t04/t09: face 3, the grid/c3 copies, TO.
  * r11u111 f4 d01/d02/d03: face 2's witnesses. d02 goes 64 -> **0**
    (TO 2). d01/d03 stay at 90 lines, a plain-array-port shape: MOVED-WRONG 2
    path-keyed, TO 2 / 0 / 0 element-name-normalised, distance 211 -> 209.
    d04 (the literal control) is SAME.
  * RC rows carry the same rc on both binaries (slang rejects; the
    pre-existing v11u112 m07 segfault).

**The two rows, after** (`evidence/HEADS115.law.txt`; the intermediate heads
are in `evidence/HEADWALK115.txt`):

| row | before | after | next head |
|---|---|---|---|
| Rggen/default | 64 / 1 | **0 / 0** | **CONVERTS.** Head walk: 64 (face 2a: VALUE_WIDTH 64 -> 32, ADDRESS_WIDTH 16 -> the receiver's 8). Then 142 (`g_register_15.u_register.bus_if`, a named-modport view passed the enclosing module's own port from a gen-if; ours `vpiOverriden:1`). Face 2b clears it to 0. |
| ibex_icache (both modes) | 17 / 1 | 50 / 1 | Face 1 cleared the 759:38 replication count. The head that unmasked (ibex_icache.sv 766:54 `fill_ext_cnt_q[fb][IC_LINE_BEATS_W]`, the bare var_select index, 17 lines) is face 1c, also landed. NEXT: LHS `ref_obj (…gen_fbs[0].gen_data_buf[0].g_fill_data_nr…BUS_SIZE)` @976:31-976:39 bound to an `enum_const (BUS_SIZE)`; RHS our folded `constant UINT:32` with a ts ref -> `int_typespec` @ibex_pkg 383:13. That is the Lhs index `b*BUS_SIZE` of `fill_data_q[fb][b*BUS_SIZE+:BUS_SIZE] <=` inside an `always_ff` of a NESTED gen block. The constant is byte-identical in the pristine database: pre-existing, only unmasked. |

## 7. Residues (ranked)

* **R0: ibex_icache's next head** (50 lines). A nested-gen-scope PROCESS LHS
  index reading a package parameter: golden keeps the ref_obj and binds a
  per-reference `enum_const`, while we fold. § genNestedScopePkgParamNoFold24
  (ExprEmit ~15604) excludes `inLhs`. That exclusion needs its own grid
  (procedural Lhs in nested gen blocks), and Earlgrey carries the same
  family. On this ground.
* **R2b: the type-parameter cast that RESOLVES** (c03 module scope, c13/c16
  always_comb, c25/c27 loop-gen ternary, arb_idx_cast's `gen_other_levels`).
  Golden writes the default's `logic_typespec`; ours an `integer_typespec`.
  Judge-invisible in the corpus. It needs the type parameter's default-type
  typespec at the cast site.
* **R-shadow-op** (s10): an OPERATION default the receiver shadows gets
  golden `UINT:<v>` WITH a ts ref, which the (C) face of
  § ifacePortViewPaFoldsDeclDefault strips. Declined.
* **R-plainarr** (w04, w05, d01, d03): golden lists ONE port view for a plain
  interface-ARRAY port; we list one per element. Pre-existing 90/94-line
  `array_typespec` head.
* **R5b / R-qual / R1v** (face 1's declined kinds):
  * untyped package parameter: signedness of the materialised typespec,
    ParamEmit (fenced);
  * qualified `pk::P` in a gen scope: golden folds bare, we keep the ref_obj;
  * var_select index in always_comb (v05) or on an Lhs (v13, v14): golden
    stamps both; not this law's emission context.
* **R1c** (b07): a module typedef home. Golden folds `P` in a typedef copy
  with a ts ref; we keep the ref_obj. TypeEmit; unchanged.
* **t09**: the cast now carries golden's placeholder, but the arm's head is a
  structural `named_begin` (234 lines).
* **Exactness (not Compare fields).** Golden names a gen-scope
  replication-count / sys-arg stamp `work@<instance>` and re-parents the
  replication count at the package param_assign. We use the gen-scope prefix
  and the operation parent, as § caOpFoldTs recorded for module scope.

R0 = the ibex_icache nested-gen process-LHS head (ExprEmit, this ground).

## Scripts

| script | what |
|---|---|
| `mkgrid115.py` | writes `grid/r` and `grid/i` (`grid/c3` are copies of pass 112's arms) |
| `grid115.sh` | golden + ours per arm, both forms, rc recorded, uhdm-cmp |
| `pv115.py` | port-view param_assign values from a dump |
| `score115.sh` + `cells115.py` + `dist115.py` | per-cell A -> B against golden + order-blind distance |
| `drops115.sh` | per-switch drops |
| `ctl115.sh` | control byte-compare over earlier passes' arms |
| `sweep115.sh` | both corpora, both modes |
| `rows115.py` | row joins |
| `ob115.sh` | order-blind mover attribution |
| `cen115.cpp` + `cen115.sh` + `censcore115.py` | census |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the r10uvm221 battery |
