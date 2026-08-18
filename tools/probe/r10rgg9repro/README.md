# r10rgg9 — § srlgCondOpInstValueTernFold9: a cont-assign ternary with a constant predicate folds, PER INSTANCE, to a loc-less INT

**MEASUREMENT-ONLY directory.** The official `uhdm-cmp` remains the sole
acceptance judge. **BASE `0168d0a`.** `results/*.csv` was READ ONLY and is
untouched. **Rggen still does NOT pass `uhdm-cmp`, and NO CORPUS ROW WAS
CONVERTED** — this pass says so up front.

Target: `default:Rggen`'s official head after r10rgg8 (122 cmp lines, 1 head) —

```
assign write_data[0] = (WRITABLE) ? {WORDS{register_if.write_data}} : '0;
                                                  rggen_register_common.sv:68
```

golden replaces that RHS with ONE **LOC-LESS** `constant INT:0 vpiSize 64
vpiConstType 7` at the two elaborated instances whose `WRITABLE` override is 0
(`u_block_0.g_register_2` and `g_register_4`), and keeps the ternary at the
other 42 instances and in the DEF view. We kept it everywhere.

**RESULT. THE HEAD IS CLEARED and the whole `cont_assign` surface of Rggen is
now IDENTICAL to golden.**

* `rowheads.sh` (official `uhdm-cmp`, Rggen default): **122 cmp lines / 1 head
  → 76 / 1 head**, and the head object moves to a DIFFERENT FAMILY entirely (a
  parameter's typespec — see § 6). Read the line count correctly: it is the
  SIZE OF THE HEAD OBJECT'S SUBTREE, never a distance.
* The `cont_assign` census over the WHOLE Rggen database (7620 cont_assigns,
  both views) goes from **2 differing rows → 0**, with **0 golden-only and 0
  ours-only**.
* Corpus: **uhdm2rtlil 0 movers over 1358 databases; surelog 1 mover over 956 —
  `default/Rggen`, THE ONLY NAME THE PREDICTION CARRIED**, filed from golden +
  pristine base databases before the patched sweep was read. **0 differing ROWS
  on either corpus, either mode**, against the committed baselines AND against
  my own base (which itself reproduces `results/golden_surelog.csv` byte for
  byte, 0 rows over 1588).
* The 57-cell golden grid: **FIXED 41, OK 214, BROKEN 0, STILL 6**, NODB 0,
  NOSLANG 0, and `rcaudit9.sh` records rc=0 for both binaries on all 57 cells
  (**0 rc=139**).
* Boundary over r10rgg1/2/5/6/7/8 + r10vrgg2…8 (694 files): **3 movers, and all
  three are r10rgg1's OWN ternary cells — its named residue R3 — every one of
  which moves base-WRONG → patched-EQUALS-GOLDEN (FIXED 4, BROKEN 0).**

---

## 1. THE HEAD, decoded from the GOLDEN DATABASE FIRST

```
LHS golden: constant (NO location)   INT:0  vpiSize 64  vpiConstType 7
              < cont_assign @rggen_register_common.sv:68:11-68:78
RHS ours  : operation @68:29  vpiOpType 32 (vpiConditionOp)
              vpiOperand ref_obj (work@rggen_register_common.WRITABLE)
              vpiOperand operation (multi-concat {WORDS{register_if.write_data}})
              vpiOperand constant '0
```

`caprobe9` reads the two objects side by side and shows that **only the Rhs
differs**: the Lhs is the same `bit_select write_data @68:11-68:24` with the
same `UINT:0` index and, decisively, **no typespec on either side** — which is
what lets golden's reduce keep its own 64-bit width (§ 2, clause 4).

`cacensus9` is a census of EVERY `cont_assign` in the database — DEF
(`uhdmallModules` + `uhdmallInterfaces`) and ELAB (`uhdmtopModules`) — keyed
`(view, instance path, line:col, Lhs name)` and reading only shapes and the
value fields `Compare` reads, with the ternary's OPERAND shapes one level down.

| | golden vs BASE | golden vs PATCHED |
|---|---|---|
| rows compared | 7620 | 7620 |
| differing | **2** | **0** |
| golden-only / ours-only | 0 / 0 | 0 / 0 |

and the census also settles, before any code, WHY only two:

```
44 ELAB instances carry `68:11 write_data`; 42 keep the ternary.
   The 2 that fold are exactly the 2 with `.WRITABLE (0)` in block_0.sv
   (lines 412 and 630) — and the DECLARATION says `WRITABLE = 1`.
257 ELAB+DEF cont_assigns in Rggen have a vpiConditionOp RHS.  Golden folds
   ONE site.  Every other one is refused by the operand gate (§ 2, clause 3):
   `(active) ? register_if.valid : '0`, `(backdoor_valid) ? read_mask[1] :
   read_mask[0]`, `(busy) ? bus_if.valid : '0` — a bare NET somewhere in the
   conditional.
```

## 2. THE LAW

> **§ srlgCondOpInstValueTernFold9.** Surelog's
> `UhdmWriter::writeCont_assign` reduces every ELABORATED `cont_assign` RHS it
> has not already simplified (`UhdmWriter.cpp`, the trailing
> `if (simplified == false)` arm — the same arm § ifaceDotEnumConstFold1 and
> § srlgUnvaluedActualLitRetFold8 transcribed), and for a `vpiConditionOp` that
> reduction is `ExprEval::reduceExpr`'s conditional arm, which evaluates the
> predicate, reduces the TAKEN arm, and REPLACES the RHS with
> `constant("INT:" + get_value(arm))`, `vpiSize 64`, `vpiConstType vpiIntConst`,
> **and no location at all.**
>
> Four clauses, each measured, none assumed:
>
> 1. **THE ARM IS PICKED FROM THE *INSTANCE*, AND r10rgg8's CLAUSE 1 DOES NOT
>    TRANSFER.** `writeCont_assign` passes `netlist->getParent()` — the
>    **ModuleInstance** — as `reduceExpr`'s value scope, and
>    `CompileHelper::getValue` consults `instance->getValue(name)` FIRST.
>    r10rgg8's `evalFunc` looks its parameters up in the `DesignComponent` and
>    provably ignores overrides; this reduce provably honours them. Cell
>    `p_ov10` (declaration `P = 1`, instance `.P(0)`) FOLDS and `p_ov01`
>    (declaration 0, instance 1) KEEPS — the exact opposite of r10rgg8's
>    `f_override1`/`f_override0` pair, on the same shape of source. **The brief
>    warned not to assume the transfer; the grid refuted it.**
> 2. **THE VALUE IS `get_value()`'s int64, AND THE OBJECT IS ALWAYS THE SAME.**
>    `INT:<v> / vpiSize 64 / vpiConstType 7 / no location`, whatever the arm's
>    own width or encoding (`4'hF` → 15, `4'b1010` → 10, `-1` → -1 SIGNED,
>    `64'hDEAD_BEEF_CAFE_BABE` → -2401053089206453570, `"ab"` → 24930,
>    `$clog2(9)` → 4, `{4{1'b1}}` → 15). `'1` folds to `INT:1`, never to the
>    conditional type's all-ones: the reducer sees the SOURCE object
>    (`BIN:1`, `vpiSize -1`), not slang's propagated width.
>    **The other outcome of the same arm**: when `get_value` POISONS — above 64
>    bits, or an x/z bit under `strict = true` — `ExprEval` does
>    `result = the_val` and writeCont installs THE ARM'S OWN CONSTANT OBJECT,
>    with its own encoding, width and location (`a_over64`, `a_xz`).
> 3. **THE OPERAND GATE READS ALL THREE OPERANDS, THE UNTAKEN ARM INCLUDED.**
>    `reduceExpr` walks every operand before it looks at the opcode: a
>    `constant`, an `operation` / `func_call` / `sys_func_call` / `bit_select` /
>    `hier_path` / `var_select` / `enum_var` passes unchecked, a `ref_obj`
>    passes only when `getValue(name)` finds a value, and anything else
>    (a `part_select`, a pattern, …) abandons the whole reduce. Cell `l_vecbit`
>    (`vec[0] = (P) ? sig : '0`, `P = 0`, taken arm a constant) is the isolating
>    refusal — the arm that is NOT taken is a bare net. Rggen's own lines 61-63
>    and 65 are the corpus instances, and they are why this head's family is
>    two objects and not 257.
> 4. **`tps` NULL IS WHY THE SIZE IS 64, AND THE DEF VIEW NEVER FOLDS.**
>    `adjustSize(tps, ...)` runs on the reduced constant and is a no-op when the
>    LHS carries no typespec — an unpacked-array bit_select (the head), a
>    part-select, a concat, an interface member. A PLAIN `ref_obj` LHS instead
>    takes writeCont's earlier `lhs->UhdmType() == uhdmref_obj` branch, where
>    the constant IS sized to the target (`l_plainnet`: `INT:0 sz 8`) — already
>    modelled by § elabCaTernaryFoldIntConst22, already matching on the base
>    binary, and deliberately untouched here. 14/14 DEF rows keep the operation.

Applied to Rggen:

```
parameter bit WRITABLE = 1;                                   // the DECLARATION
assign write_data[0] = (WRITABLE) ? {WORDS{register_if.write_data}} : '0;
u_block_0.g_register_2 / g_register_4 override .WRITABLE(0)
=> those TWO elaborated cont_assigns get a LOC-LESS INT:0 sz 64 ct 7;
   the other 42 instances and the DEF view keep the operation.
```

## 3. THE GRID — 57 cells against REAL SURELOG

`GRID.md` carries the whole table (and `GRID_TABLE.md` the raw per-cell join,
`SCORE.txt` every role and every view). The results that shaped the predicate:

* **`p_ov10` / `p_ov01` forced clause 1** and refuted the transfer of r10rgg8's
  declaration rule. `p_split`, `p_three`, `c_deep` and `c_headshape` then show
  the split happening INSIDE one definition, instance by instance.
* **`l_vecbit` isolated clause 3** to one token: identical to `l_plainnet1`
  except for the LHS, both KEEP, and the only unvaluable thing in either is the
  arm that is not taken.
* **`a_neg` is the cell that caught my first value model.** The first patched
  binary folded `-1` to `4294967295`, because slang's sibling propagation made
  the leaf UNSIGNED. § elabCaTernaryFoldIntConst22 already carried the
  `setSigned(true)` clause for a negated leaf; transcribing it fixed the cell.
* **`a_over64` and `a_xz` are the arm-object install**, and adding them took
  STILL from 9 to 6.
* **`c_proc` is the negative control**: a procedural assignment is never seen by
  `writeCont_assign`, golden keeps the operation in both views, and so do we —
  before and after.

## 4. THE IMPLEMENTATION — 1 file, +210 lines, no new emission machinery

| where | what |
|---|---|
| `src/ModuleEmit.cpp`, `emitContAssigns` | `ternFold9` / `ternArm9`, computed just before the def-share decision from `operandOk9` (clause 3, the `constantOperands` loop transcribed CLOSED) and `leafValue9` (clause 2, `get_value` transcribed); `!ternFold9 && !ternArm9` added to the share test's non-plain-LHS disjunct; the constant minted immediately after `UHDM::any* rhs = nullptr;` |

The predicate is gated on `topView && shareWithDef && !plainLhs && !dottedLhs
&& !ifaceDotFresh && !callIdxLhs && !selLitLhs && !callFold &&
!elabReadNoValue9 && !unbasedShareRhs && !caReuseParamConst9 && !sysFold`, i.e.
**it fires only where the ELAB cont_assign was being SHARED from the def view
whole.** Every site that already minted a fresh elab cont_assign keeps the
shape it had, which is why the plain-LHS ternary law (`l_plainnet`,
`l_plainnet_i`) and every other fold law are untouched — proven by the 694-file
boundary run and by 0 differing rows on both corpora.

## 5. THE PREDICTION, AND IT WAS EXACT

`cand9.py` reads the PRISTINE base databases and reports every test whose
ELABORATED view carries a 3-operand `operation(op=32)` at all — the upper
bound, **36 (test, mode) cells over 19 names** on the surelog corpus, 0 on
uhdm2rtlil. `predict9.py` then censuses GOLDEN (found through each workdir's
OWN `cmds.txt`) against the pristine base for those cells and reports every row
golden folds and we do not. **No patched binary is dispatched by either tool.**

```
-- corpus=uhdm2rtlil scanned=1358 PREDICTED-ROWS=0 PREDICTED-NAMES=0
-- corpus=surelog    scanned=36   PREDICTED-ROWS=2 PREDICTED-NAMES=1
-- NAMES: Rggen
```

Measured afterwards by `byteverify.sh` (SELFCHECK=1, base-vs-base 0 movers):
**uhdm2rtlil 0 movers / 1358; surelog 1 mover / 956, `default/Rggen`.** The
documented `Scoreboard` ~50/50 COIN did not flip on this run. The mover is
attributed row-for-row in `GATES.txt`: exactly the two predicted cont_assigns,
and the patched census then agrees with golden on all 7620.

## 6. THE NEW R0 — the next pass's head, characterized

```
LHS golden: logic_typespec (NO location, no parent shown)
              vpiRange -> range with vpiLeftRange constant UINT:7
                                     vpiRightRange constant UINT:0
              (both range bounds BARE: no decompile, no size, no constType)
RHS ours  : bit_typespec @rggen-sample/block_0.sv:450:18-450:27
              < ref_typespec (work@rggen.u_block_0.g_register_2
                              .g_bit_field_1.INITIAL_VALUE)
              vpiRange -> range @450:22 with LOCATED constants
                          UINT:7 sz64 ct9 @450:23 and UINT:0 sz64 ct9 @450:25
```

76 cmp lines, 1 head. A DIFFERENT FAMILY: a parameter's **typespec** —
`INITIAL_VALUE`'s declared type. Golden hands the elaborated parameter a BARE,
LOC-LESS `logic_typespec` whose range bounds are stripped constants; we emit a
LOCATED `bit_typespec` minted at the instantiation's `.INITIAL_VALUE (8'h00)`
type syntax, with fully-shaped located range constants. The axes a next pass
should measure first: `bit` vs `logic` typespec kind for an overridden
`parameter bit [N:0]`, whether the ELAB parameter's typespec is a fresh mint or
the definition's object, and where the range bounds lose their
size/decompile/constType.

## 7. RANKED RESIDUES

* **R1 — a cont-assign inside a GENERATE scope does not fold** (`c_gen`,
  `p_genvar`: golden folds, we keep the operation). The gen-scope cont-assign
  emission is a different code path from `emitContAssigns`, which takes an
  `InstanceBodySymbol`; the law was not wired into it. **This carries r10rgg8's
  R3 forward, now with two measured cells instead of one.** Neither corpus has
  a firing site (the prediction is 0 rows outside Rggen), so it costs nothing
  today — but a genvar-predicated ternary in a generate loop is common SV and
  this is the highest-value residue on the list.
* **R2 — a cont-assign inside an INTERFACE body never gets an ELAB fold at
  all** (`c_iface_body`). `emitContAssigns` is called for interfaces with
  `topView = false`, so no elab-view fold law reaches an interface's own
  cont_assigns. Structural, and wider than this pass.
* **R3 — a PORT HIGH-CONN ternary folds on golden to the ARM's own constant
  object** (`c_port`: `.i((P) ? {2{sig}} : '0)` → `constant BIN:0 sz -1 @7:29`),
  and a VAR-DECL INITIALIZER keeps the operation but we emit no row at all
  (`c_varinit`). Both were already wrong on the base binary; neither is this
  law's site.
* **R4 — `localparam int Z = (P) ? 3 : 4` read by a cont-assign** (`c_paraminit`):
  golden's ELAB cont_assign Rhs is the param's own `UINT:4 sz32 @7:22` fold and
  we emit `ref_obj(Z)`. Owned by the param-read reuse laws
  (§ elabCaReusesParamValueConst), measured here and not claimed.
* **R5 — the `strict`/encoding corners of `get_value` are modelled only by
  refusal.** A REAL arm, and any arm whose reduced constant is not an integer
  slang can hand back, refuse rather than fold. No grid cell and no corpus site
  is affected; named so a future pass knows the boundary is a choice.
* **R6 — carried untouched from r10rgg8:** its R2 (the size/encoding rules for
  a SIZED literal return), R4 (the nested-call unvalued binding reaches one
  level), R5 (`b_outformal` / `e_classmethod`, rejected by slang itself), and
  r10rgg1's R1/R2/R4 (the param-ref and `P + 1` reuse rows visible in
  `BOUNDARY.txt`'s STILL column).

## 8. FILES

| file | what it is |
|---|---|
| `gen_grid9.py` | writes ALL 57 cells (`cells/<cell>/dut.sv`) |
| `run_grid9.sh` | REAL SURELOG + any number of slang binaries per cell; NODB / NOSLANG printed and COUNTED |
| `gridscan9.cpp` | per-site shape reader: cont_assign / param_assign / procedural assignment / port high-conn / var-decl init, both views, per instance path, with ternary OPERAND shapes and a `[LOCLESS]` flag |
| `cacensus9.cpp` | the whole-database cont_assign census of § 1 |
| `caprobe9.cpp` | the full object dump of one cont_assign (Lhs shape, typespec, operands) at a named instance path and line |
| `score9.py` | the three-side join and the order-blind FIXED / BROKEN / STILL / OK verdict |
| `cand9.py` | the pristine-database candidate upper bound; no binary dispatched; fenced rows skipped BY NAME-HASH and counted |
| `predict9.py` | the mover PREDICTION from golden + pristine base; no patched binary; fenced rows skipped and counted |
| `rcaudit9.sh` | records the exit code of BOTH binaries on every grid cell (no rc=139) |
| `gates9.sh`, `ct9rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `boundary.sh`, `rowheads.sh` | the gate legs, carried forward |
| `GRID.md`, `GRID_TABLE.md`, `SCORE.txt` | the measured grid, the law's clause-by-clause evidence, the refuted clause |
| `GATES.txt` | every gate leg's output, the mover named and attributed |
| `CENSUS.txt` | the § 1 census, all three sides, with the golden-vs-golden calibration |
| `CANDIDATES_surelog.txt`, `PREDICT_*.txt` | the upper bound and the prediction, per corpus |
| `BOUNDARY.txt` | the 694-file boundary run, its 3 movers, and its rc histogram |
| `BYTEVERIFY_*.txt` | the mover gate, both corpora, with SELFCHECK |
| `RCAUDIT.txt` | the per-cell rc audit |
| `HEAD_R0_{BEFORE,AFTER}_default_Rggen.cmp` | the official `uhdm-cmp` head, both sides |

Reproduce:

```sh
python3 gen_grid9.py
g++ -O2 -std=c++17 gridscan9.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10rgg9_gridscan
GRIDSCAN=/tmp/r10rgg9_gridscan ./run_grid9.sh /tmp/g <base-bin> base <pat-bin> pat
python3 score9.py /tmp/g base pat | tail -1
```
