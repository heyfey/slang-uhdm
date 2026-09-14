# r11u19 — an assignment pattern folds on a `logic` target, and a fill literal keeps its own encoding through a conditional fold

Base commit `aa69cb57`, worktree `/tmp/wt_r11u19`. Pristine binary md5
`0691f7273455a3628c2de8fcc773ef90` — the OPS-stated main-tree md5 at the base,
reproduced exactly by my own build from source. Law binary md5
`6166b657e186a803fef6a93289357d8f`. The judge is the official `uhdm-cmp`
through `scripts/verify_golden.py`; everything in this directory is
measurement-only. `results/*.csv` ARE NOT EDITED BY THIS PASS.

**THREE TESTS CONVERT, SIX ROW-MODES**, each confirmed at `uhdm-cmp` rc 0
against the golden the sweep itself used:

    uhdm2rtlil   ibex_alu          tern_fill_literal        (both modes)
    surelog      Earlgrey_0_1                               (both modes)

**`ibex_alu` IS THE ROW THE BRIEF NAMED AS THE CANDIDATE, AND IT CONVERTS.**
u2r reads **765 CMP_EQUAL / 39 CMP_NOTEQUAL / 67 SLANG_REJECT in BOTH modes**
against the base's 763/41/67; the surelog suite reads **469/14 default** and
**465/12 testflags** against 468/15 and 464/13.

## 1. THE HEAD, RE-MEASURED ON MY OWN PRISTINE BUILD

`uhdm-cmp` run directly on the golden the sweep itself used, one head per row
(`grep -c '^LHS:'` on **stderr**), identical in both modes, 29 cmp lines:

    ibex_alu   LHS golden  constant @ 1312:34-1312:48  vpiDecompile:2'd0 vpiSize:2 UINT:0
               RHS ours    operation @ 1312:34         vpiOpType:75 + tagged_pattern
                                                       (pattern constant '0, size -1,
                                                        BIN:0, constType 3; typespec
                                                        ref -> string_typespec "default")

That is `assign imd_val_we_o = '{default: '0};` (`ibex_alu.sv:1312`) inside the
`g_no_alu_rvb` generate block, over the MODULE's `output logic [1:0]
imd_val_we_o` at `:25` — r11u17's R0 verbatim. Its keyed reference census over
the judge-reachable elaborated listing is **0 differing keys of 203** on the
pristine binary (calibration: golden-vs-golden 0 of 203; positive control: arm
`q03` reads 1 of 3, `logic_net` vs `array_net`), so the head is a CONSTANT-FOLD
surface and not a binding one.

## 2. DECODE — TWO PRODUCERS READ AT THE PIN, TWO LAWS

### § genCaPackedPatternFold19 — the fold is a LOGIC-TYPESPEC law, not a "packed" one

`UhdmWriter::writeCont_assign` (Surelog v1.87
`src/DesignCompile/UhdmWriter.cpp:2090`) walks `netlist->cont_assigns()` for
EVERY instance — a gen scope is an instance like any other — and its `if (tps)`
arm (`:2178`) runs

```cpp
expr* tmp = eval.flattenPatternAssignments(s, tps, (expr*)rhs);
if (tmp->UhdmType() == uhdmoperation) {
  …clone_tree(assign)…
  if (opType == vpiAssignmentPatternOp || opType == vpiConditionOp)
    if (m_helper.substituteAssignedValue(rhs, m_compileDesign))
      rhs = m_helper.expandPatternAssignment(tps, (expr*)rhs, mod, …);
```

`CompileHelper::expandPatternAssignment` (`CompileHelper.cpp:5207-5500`) mints a
constant in **exactly one** of its arms:

| `tps->UhdmType()` | result |
|---|---|
| `uhdmlogic_typespec` | ONE `constant`, `VpiSize(Bits(tps))`, `UINT:<v>`, decompile `<size>'d<v>`, **no VpiConstType** |
| `uhdmstruct_typespec` | `result = rhs` — NO FOLD |
| `uhdmpacked_array_typespec` | a `packed_array_var`, and ONLY when the element typespec is an ENUM |
| anything else | `result = rhs` — NO FOLD |

Measured on golden, gen scope and module body alike (`caPatLogicTarget19`
carries this table):

    logic [1:0]        FOLD 2'd0 (p01/p02)    bit [1:0]      NO (q06/t07)
    logic [1:0][3:0]   FOLD 8'd0 (q01/t05)    int / byte     NO (q07/q10/t08)
    logic signed [3:0] FOLD 4'd0 (s12/t25)    enum           NO (q08/t09)
    typedef logic[3:0] FOLD 4'd0 (q09/t11)    packed struct  NO (q02/t06)
                                              s_t [1:0]      NO (q11/t27)
                                              unpacked       NO (q03/q05/t26)

**`tps` IS `bindVariable`'s ANSWER, AND THAT IS THE WHOLE SCOPE FENCE.**
`CompileHelper::bindVariable` (`CompileStmt.cpp:3095`) switches on
`function` / `task` / `begin` / `module_inst` ONLY, so from a `gen_scope` it
falls through to the enclosing `module_inst` and finds MODULE-BODY nets,
variables and ports — never a gen-LOCAL declaration (arm `t02`: golden keeps
the pattern), and never anything at all from an INTERFACE body (arms
`r12`/`t04`: golden keeps it in an interface's gen scope AND at interface module
scope). `caLhsAdjustBind106` (r10earl106) already decodes exactly that
predicate and hands back the declaration's width, so it is reused rather than
re-derived.

**WHAT GOLDEN REFUSES, arm by arm, and this law leaves alone:**
a REPLICATED pattern (`vpiMultiAssignmentPatternOp`, op 76 — `t23`); a NESTED
pattern operand, because `expandPatternAssignment`'s untagged arm reduces every
operand and `get_uvalue` on a sub-pattern sets `invalidValue`, which
`return result`s the tree unfolded (`t24`, and its module-body twin `s06` is the
PRISTINE binary getting that shape wrong); and any Lhs that is not a whole name
— a part-select (`t19`/`r08`), a bit-select (`r07`) or a concat (`r09`), where
`writeCont_assign` never fills `tps`.

**OUR EMITTER ALREADY DID THIS AT MODULE SCOPE AND NOT IN A GEN SCOPE.** `p02`
is `uhdm-cmp` EQUAL on the pristine binary and `p01` — the same assignment one
`begin`/`end` deeper — is the 29-line head. The two homes run the SAME Surelog
code; this pass is the gen-scope half of it, written beside the landed
§ genCaReplWholeFold78 in `emitGenScopes`.

### § caTernFillArmKeepsEncoding19 — the fill fence is in UHDM's own source

r11u17's R1. UHDM v1.87's `ExprEval::reduceExpr`, `vpiConditionOp` arm
(`templates/ExprEval.cpp:3878-3903`), tests the selected arm before collapsing
it:

```cpp
bool the_val_is_fill = false;
if (the_val && the_val->UhdmType() == uhdmconstant)
  the_val_is_fill = (((constant *)the_val)->VpiSize() == -1);
if (localInvalidValue == false && !the_val_is_fill) { … result = <INT:val, 64> … }
else result = the_val;
```

An UNBASED-UNSIZED literal (`'0` `'1` `'x` `'z`, `VpiSize` -1) is handed BACK
UNCHANGED and never becomes `INT:<val>`. `writeCont_assign:2153-2157` then runs
`adjustSize(tps, …, (constant*)rhstmp, uniquify=true)`, whose `orig_size == -1`
tail is

```cpp
if (orig_size == -1) {              // '1, '0
  uint64_t uval = (uint64_t)val;
  if (uval == 1) {                  // '1 ONLY
    …clone…
    if (size <= 64) { UINT:getMask(size), the same decimal decompile, vpiUIntConst; }
    else            { BIN:<size ones>, same decompile, vpiBinaryConst; }
  }
  c->VpiSize(size);                 // '0 AND '1 alike
}
```

and the WHOLE body sits under `if (!invalidValue)`, where `invalidValue` is
`ExprEval::get_value`'s — which cannot parse `BIN:X` / `BIN:Z`. Measured on
golden, one arm per outcome:

| arm | selected fill | golden | pristine |
|---|---|---|---|
| `e02` 32-bit, `e04` 1-bit, `f04` 4-bit, `f05` true-arm | `'0` | the literal UNTOUCHED, sized at the Lhs width: `BIN:0`, `vpiDecompile:'0`, constType 3, LOCATED | loc-less `INT:0`, decompile `0`, constType 7 |
| `f01` 32-bit, `f12` 1-bit | `'1` | `UINT:4294967295` / `UINT:1`, decimal decompile, constType 9, at the Lhs width | loc-less `INT:…`, constType 7 |
| `f02` | `'x` | UNTOUCHED ENTIRELY, `VpiSize` still **-1**, `BIN:X`, constType 3 | the whole ternary kept |

**THE OPERAND GATE IS WHAT TELLS `f11` FROM `e02`.** `ExprEval::reduceExpr`
computes `constantOperands` over ALL operands of the operation
(`ExprEval.cpp:3121-3145`) — including the arm it does not select — and a
`part_select` is not in its whitelist, so golden REFUSES to reduce
`f11` / `f03` at all. Our `§ elabCaTernaryFoldIntConst22` has no operand gate
and folds `f11` anyway; that is a PRE-EXISTING residue this pass does not
touch. The fix is written so that the INT fold merely ABSTAINS on a fill arm
and the install rides § elabCaTernaryArmInstall92's existing `operandOk92`
descent, which IS that gate — so `f11` is byte-unchanged and `e02` converts.

## 3. THE GOLDEN GRID — 92 arms, every rc recorded

`grid/` carries one `dut.sv` per arm; `run.sh <binary> <tag>` builds the GOLDEN
(`surelog -parse -nobuiltin -nocache -sv`) and ours (`--single-unit
--nobuiltin`) and records **both** return codes plus the head count and cmp line
count; `table.sh` is the three-column table and `shapes.sh` the per-cell census.
`GRID.r11u19.txt` is the table.

**Every arm is `golden_rc=0`.** 90 of 92 are `ours_rc=0` on BOTH binaries; `p03`
(`'{default:'0}` on a SCALAR `logic`) and `q13` (a packed ENUM array target) are
`ours_rc=3` — slang REFUSES them — on BOTH binaries, so they teach ERROR
RECOVERY, not golden, and carry no verdict.

**19 arms CONVERT to `uhdm-cmp` rc 0, 1 arm improves, 0 arms regress.**

**AN ARM AGREEING AT rc 0 IS NOT AN ARM TESTING THE LAW**: every verdict below
is read off the per-cell CA-shape census (`shape.py`, the cont-assign analogue
of r11u15's `refcen.py`), never off the cmp rc. The census prints `[DIFF]` for a
cell whose ONLY difference is golden's `vpiParent` — the ternary clone the
`'0` came from — which is why `e02`/`e04`/`f02`/`f04`/`f05` read `1/1` in the
table while `uhdm-cmp` reads rc 0: **no generated `Compare` reads `VpiParent`**.

### LAW 1 axes — target kind x scope x pattern kind x value

| arm | shape | golden | pristine | law |
|---|---|---|---|---|
| `p01` | gen-if, module `logic [1:0]`, `'{default:'0}` | `2'd0` | operation 75 | `2'd0` ✔ |
| `r06` | the same beside an unpacked sibling | `2'd0` (the sibling NOT folded) | operation | `2'd0` ✔ |
| `r10` | a gen-if ELSE arm | `2'd0` | operation | `2'd0` ✔ |
| `t05` | packed 2-D `logic [1:0][3:0]` | `8'd0` | operation | `8'd0` ✔ |
| `t10` | a for-generate | `2'd0` | operation | `2'd0` ✔ |
| `t11` | a typedef'd `logic [3:0]` | `4'd0` | operation | `4'd0` ✔ |
| `t12` | POSITIONAL `'{1'b0,1'b1}` | `2'd1` | operation | `2'd1` ✔ |
| `t15` | a gen-if in a CHILD instance | `2'd0` | operation | `2'd0` ✔ |
| `t20` | `'{default: P}`, `P = 1` | `8'd255` | operation | `8'd255` ✔ |
| `t22` | `'{default:'1}` | `2'd3` | operation | `2'd3` ✔ |
| `t25` | `logic signed [3:0]` | `4'd0` | operation | `4'd0` ✔ |
| `t14` | a NESTED gen-if | `2'd0` | operation | `2'd0` ✔ (new head, §7) |
| `t21` | `'{default:'0, 0:1'b1}` | `4'd1` | operation | `4'd1` ✔ (new head, §7) |
| `t02` | a GEN-LOCAL target, no namesake | operation | operation | operation |
| `t06` | a packed STRUCT target | operation | operation | operation |
| `t07`/`t08`/`t09` | `bit [1:0]` / `int` / enum | operation | operation | operation |
| `t19`/`r07`/`r08`/`r09` | part-select / bit-select / concat Lhs | operation | operation | operation |
| `t23` | a REPLICATED pattern (op 76) | op 76 | op 76 | op 76 |
| `t24` | a NESTED pattern operand | operations | operations | operations |
| `t26`/`t27` | unpacked and packed-struct arrays | operation | operation | operation |
| `r12`/`t04` | an INTERFACE gen scope / module scope | operation | operation | operation |
| `q04` | a gen-scope unpacked-array NET | operation | operation | operation |

### LAW 2 axes — fill kind x Lhs width x branch x context

| arm | shape | golden | pristine | law |
|---|---|---|---|---|
| `e02`/`e04`/`f04` | `'0` on a 32-/1-/4-bit Lhs | the literal, sized | `INT:0` loc-less | the literal, sized ✔ |
| `f05` | `'0` in the TRUE branch | the literal, sized | `INT:0` | the literal ✔ |
| `f01`/`f12` | `'1` on a 32-/1-bit Lhs | `UINT:<mask>` ct 9 | `INT:<mask>` ct 7 | `UINT:<mask>` ✔ |
| `f02` | `'x` | the literal, size **-1** | the whole ternary | the literal ✔ |
| `f03` | `'z`, a part-select true arm | the whole ternary | the same | the same |
| `f06` | a part-select Lhs | — | — | unchanged, EQUAL |
| `f08` | a nested ternary under a bare-ref arm | the whole ternary | the same | the same |
| `f09`/`f10` | procedural / net-decl-assign | the whole ternary | the same | the same |
| `e01`/`e03` | a SIZED `1'b0` / `32'd0` arm | `INT:0` sized | the same | the same |
| `e05` | a bare-ref true arm | the whole ternary | the same | the same |
| `f11` | `'0` with a part-select true arm | the whole ternary | we fold `INT:0` | UNCHANGED (R3) |
| `f07` | the gen-scope twin of `e02` | the literal, sized | the whole ternary | UNCHANGED (R2) |

## 4. PREDICTION — the mover set BY NAME, a priori, with a positive control

`pred19.py` reads **PRISTINE databases only**; a database with no flagged cell
cannot move. Two deliberate SUPERSETS:

* **LAW 1** — an ELABORATED `gen_scope` `cont_assign` whose Rhs is a
  `vpiOpType:75` operation and whose Lhs is a whole `ref_obj`. It cannot see the
  target typespec kind, a nested operand, or whether our own `tryFoldConst`
  succeeds.
* **LAW 2** — any `cont_assign` whose Rhs is a `vpiOpType:32` operation carrying
  a `vpiSize:-1` constant anywhere in its operand subtree. It cannot evaluate
  the condition, apply the operand gate, or see the Lhs shape.

**A SECTIONING BUG THIS PASS FOUND AND FIXED** — `|uhdmallModules:` and
`|uhdmtopModules:` are REPEATED keys, once per module, not two contiguous
sections; a scan that cut at "the next `|uhdm` line" covered almost nothing on
a real design (Earlgrey_0_1's dump has 149916 lines before the first
`|uhdmallModules:` and hundreds more after) and initially reported LAW2 0 on a
database that DID move. `pred19.py` walks the whole dump instead.

**POSITIVE CONTROL** — the grid arms, scored from their own pristine dumps: it
fires on **all 19** real movers and is silent on 18 of 24 known non-movers. A
scan that could not see would have been silent on the movers too.

Over the **1608 PRISTINE u2r databases**, before the law binary was consulted,
it flags **18 databases (9 rows x 2 modes)** — `PRED.u2r.txt`. The four
measured movers are among them. The five rows flagged and NOT moved are
byte-identical on the two binaries and are the over-approximation by name:

    gen_struct_access           LAW1 1  a gen-scope pattern onto a STRUCT target
                                        (r10earl113's own witness — the
                                         logic-target fence spares it)
    genscope_outer_reg_inner_ff LAW2 2  the fill is in a PROCESS
    pkg_localparam_partsel      LAW2 2  `assign o_o = sel_i ? … : '0;` — the
                                        condition is a SIGNAL, never constant
    ibex_icache                 LAW2 6
    ibex_register_file_fpga     LAW2 6
    iface_member_port           LAW2 2
    realexpr                    LAW2 3

## 5. THE CORPUS — every mover named and attributed

**uhdm2rtlil, `byteverify.sh SELFCHECK=1` against my own pristine workdir:
4 movers of 1608**, `PATH_SETS_IDENTICAL`, self-check 1607/1608.

    default+testflags/ibex_alu          45 order-blind lines (12 added, 33 removed)
    default+testflags/tern_fill_literal  6 order-blind lines ( 3 added,  3 removed)

`ibex_alu`'s 45 lines are the two laws' cells and NOTHING else:

    LAW 1  1312:34  the whole `operation vpiOpType:75` + `tagged_pattern` +
                    `string_typespec (default)` + `ref_typespec
                    (work@ibex_alu.g_no_alu_rvb)` subtree -> ONE `constant`
                    `vpiDecompile:2'd0 vpiSize:2 UINT:0`, golden's object field
                    for field
    LAW 2   269:74  `assign bfp_mask   = (RV32B != RV32BNone) ? … : '0;`
            275:79  `assign bfp_result = (RV32B != RV32BNone) ? … : '0;`
                    loc-less `INT:0 / decompile 0 / constType 7`
                    -> located `BIN:0 / decompile '0 / constType 3`

`tern_fill_literal` is a purpose-built repro of this very fill law (its header
quotes the same UHDM `vpiConditionOp` fence) and its single moved cell is
`assign o_constcond = IS32 ? narrow(a) : '1;` at `26:43`: loc-less `INT:255`
constType 7 -> located `UINT:255` constType 9 — `adjustSize`'s `'1` clone arm,
`getMask(8) = 255`.

**surelog: 5 movers of 960** (self-check 959/960).

    default+testflags/Earlgrey_0_1   16 order-blind lines (8 added, 8 removed)
    default+testflags/MiniAmiq, testflags/SeqDriver    the proven UVM coin

`Earlgrey_0_1`'s 16 lines are TWO LAW-2 cells and nothing else — its own copy
of `ibex_alu.sv`, at `247:59` (`bfp_mask`) and `253:87` (`bfp_result`), each a
loc-less `INT:0 / 0 / ct 7` becoming golden's located `BIN:0 / '0 / ct 3`.
The row converts, so every moved line is TOWARD GOLDEN.

The coin is convicted twice, and never by a count — §8 of `GATES.r11u19.txt`:
`pred19` flags ZERO cells in all three pristine coin databases, and the
PRISTINE binary ALONE produced THREE different databases in four runs on
MiniAmiq's own command line, every pristine-vs-pristine order-blind delta the
SAME 4-line shape (one constant's `UINT` + `vpiDecompile`, drawing 0 / 1114 /
1133). The pristine-vs-law delta on each of the five is that identical shape.
Pinned by NAME and CLASS.

**AWAY-GOLDEN 0 / MOVED-WRONG 0.**

## 6. THE BOUNDARY — 901 committed files, `PROCESSED == LISTED`

`bnd19.sh` compiles a file list with BOTH binaries, normalises the dump
(workdir path, object ids, output filename) and sorts it order-blind, reading
the list on fd 3 with children `</dev/null`. `BND.list.txt` is every committed
`.sv` under `tools/probe` that has an `assign` AND a generate block or a
ternary-with-fill, plus the r11u15 / r11u17 / r11v17 grids and the landed
verifier arms `q{d,e,f}22.sv`, `v2_seltrack.sv` and `v2_kind94.sv`.

**POSITIVE CONTROL**: `MOVED=1 norm_delta=29` on a known mover and `0` on a
known non-mover — the gate can see.

**PROCESSED=901 LISTED=901 MOVED=8**, every moved file `pris_rc=0 law_rc=0`.
Each scored against the REAL v1.87 golden by `bndattr19.sh`:

| file | pristine | law |
|---|---|---|
| `r10v92repro/v4_arm.sv` | cmp 14 lines | **rc 0 EQUAL** |
| `r10rgg9repro/cells/l_plainnet/dut.sv` | cmp 16 lines | **rc 0 EQUAL** |
| `r10earl92repro/g3_arm92.sv` | cmp 14, CA shapes 13/20 | cmp 8, CA shapes 12/20 |
| `r10earl92repro/g5_home92.sv` | cmp 23 | cmp 23, FOUR cells now golden's exact `'0`/`BIN:0`/ct 3 |
| `r11u17repro/grid/d01`, `d05` | cmp 29 | **rc 0 EQUAL** (R0's own arms) |
| `r11u17repro/grid/e02`, `e04` | cmp 16 | **rc 0 EQUAL** (R1's own arms) |

`g5_home92.sv` is the only mover whose cmp count does not fall, and the per-key
report shows NO verdict flipped from SAME to DIFF: its four moved cells match
golden on every judge-read field and differ only in `vpiParent`.
**AWAY-GOLDEN 0 / MOVED-WRONG 0.**

## 7. WHERE THE HEADS LAND NOW

* `ibex_alu` converts; its judge-reachable ref census stays **0 of 203** and its
  CA-shape census goes **3 of 106 -> 2 of 106**, the two remaining being the
  `vpiParent` artefact on the `bfp_mask` / `bfp_result` fill constants.
* `t14` (a nested gen-if) moves from 29 cmp lines to **15 on a NEW OBJECT**: a
  `logic_net work@top.we` golden has and we do not (`RHS: <null>`). Its CA-shape
  census is 0 of 1 — the fold is right and the residue is a nested-gen-block
  net-declaration face.
* `t21` (`'{default:'0, 0:1'b1}`) keeps a 10-line head on the DEFINITION
  listing's index tag: golden `integer_typespec INT:0`, ours
  `string_typespec (0)`. Its ELAB CA shape is 0 of 1.

## 8. Residues

* **R0 — `f07`: the ternary fold has no GEN-SCOPE home.** Golden folds
  `assign o2 = (P != PNone) ? … : '0;` inside a generate block exactly as at
  module scope (the literal, sized at the Lhs width), and we keep the whole
  ternary: both § elabCaTernaryFoldIntConst22 and § elabCaTernaryArmInstall92
  live in `emitContAssigns`, whose only callers pass an `InstanceBodySymbol`.
  73 cmp lines, wrong at pristine, unchanged here. **This is the next head.**
* **R1 — the fill constant carries no `vpiParent`.** Golden's installed arm is a
  clone that still points at the ternary operation it came from; ours is
  unparented. Judge-invisible (no generated `Compare` reads `VpiParent`) and
  therefore not chased, but it is what the CA-shape census prints as `[DIFF]`
  on `e02`/`e04`/`f02`/`f04`/`f05` and on `ibex_alu`'s two cells.
* **R2 — `f11`: our ternary fold has NO OPERAND GATE.** `ExprEval::reduceExpr`
  computes `constantOperands` over every operand (`ExprEval.cpp:3121`), so a
  `part_select` in the arm golden does NOT select still blocks the whole fold;
  § elabCaTernaryFoldIntConst22 folds anyway. Wrong at pristine on both
  binaries, unchanged.
* **R3 — `p09`/`p10`/`s10`/`t13`/`t16`: an UNVALUABLE pattern default folds to
  ZERO in golden.** `expandPatternAssignment` reads
  `defaultval = eval.get_value(invalidValue, reduceExpr(tp->Pattern(), …))` into
  a SHADOWED local `invalidValue` and never tests it, so `'{default: 'x}`,
  `'{default: 'z}` and `'{default: a[0]}` all fold to all-zeros at the target
  width. We keep the pattern. Wrong at pristine at module scope AND in a gen
  scope; this pass keeps the two homes consistent by declining both.
* **R4 — `t01`: `'{default: 2}` is ALL-ONES in golden.**
  `values[i] = defaultval` treats the whole default as a per-bit flag, so any
  nonzero default fills with ones (`8'd255`); we fold `8'd0`. Wrong at pristine
  at module scope, unchanged.
* **R5 — `s01`/`s02`/`s04`/`s06`/`q11`/`q06`/`q08`: the MODULE-SCOPE pattern fold
  is wider than golden's.** At module scope the pristine binary folds a
  positional packed-STRUCT pattern (`s02` `3'd5`), a NESTED packed-2D pattern
  (`s06` `8'd15`), a `bit [1:0]` target (`q06`), an enum target (`q08`) and a
  packed-struct ARRAY (`q11`) where `expandPatternAssignment` returns the tree
  unfolded. The gen-scope law written here carries the correct typespec and
  nesting fences from the start, so the two homes now DISAGREE with each other
  in golden's favour on the gen-scope side. Wrong at pristine, unchanged.
* **R6 — `r01`/`t18`: a NET-DECL-ASSIGN pattern folds in golden.**
  `wire [1:0] w = '{default:'0};` is `2'd0` in golden at module scope and in a
  gen scope alike; net-decl-assign cont_assigns are built in a different loop
  and neither law reaches them. Wrong at pristine, unchanged.
* **R7 — `t03`: a gen-LOCAL target with a MODULE NAMESAKE folds at the
  NAMESAKE's width.** `bindVariable` binds BY NAME, so golden folds
  `'{default:'0}` on a 2-bit gen-local `we` to `4'd0` — the 4-bit module-body
  namesake's width. `caLhsAdjustBind106` requires the Lhs symbol's own parent
  scope to be an `InstanceBodySymbol`, so this pass declines the cell rather
  than move it to a differently-wrong constant. Wrong at pristine, unchanged.
* **R8 — `q03`/`q05`/`q12`/`t26`: an UNPACKED target's pattern operand.** Golden
  keeps a `tagged_pattern` (sized 32 / -1 by the target) where we emit a bare
  `constant`. A separate family; wrong at pristine, unchanged.
* **R9 — `s07`/`t17`: `expandPatternAssignment`'s `vpiConditionOp` arm.** Golden
  expands a pattern in EACH BRANCH of a ternary and folds both
  (`a[0] ? '{default:'0} : '{default:'1}` -> `2'd0` / `2'd3` inside a surviving
  ternary); we keep both patterns. Wrong at pristine, unchanged.

## 9. Instruments

* `shape.py` — THE SHAPE LISTER: every `cont_assign` in the judge-reachable
  elaborated listing, keyed by (owner kind, Lhs, line:col), with the Rhs OBJECT
  KIND and its size / value / decompile / constType / opType. It is the
  cont-assign analogue of `refcen.py` and the arbiter for every grid verdict.
* `refcen.py` / `refall.py` / `armcen.sh` — r11u15's ref census, copied
  byte-for-byte from `r11u17repro`, used for the head calibration in §1.
* `run.sh` / `table.sh` / `shapes.sh` — the 92-arm grid runner, its table
  (`GRID.r11u19.txt`) and the per-cell reports (`SHAPES.{pris,law}.txt`).
* `pred19.py` / `predrun.sh` — the a-priori mover prediction (§4), computed from
  pristine databases and scored on the grid arms as its positive control.
* `bnd19.sh` — the boundary runner (§6), fd-3 file list, `PROCESSED == LISTED`.
* `bndattr19.sh` — builds the REAL v1.87 golden for one moved file and prints
  the OFFICIAL `uhdm-cmp` verdict for pristine and law, so every boundary
  mover's DIRECTION is measured, not argued.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the r10uvm221 battery, copied byte-for-byte unmodified.

## 10. Gates

`GATES.r11u19.txt` carries the transcript. All green: both binaries built
`-j 2` with md5s taken separately and the pristine one equal to the OPS-stated
main-tree md5; goldens 23/0 on both and 0/23 under `/bin/false`; every
`cmds.txt` audited by binary path (1742 + 1742 + 1581 + 1581); u2r both modes
and surelog both modes with only the law-named rows differing, each quoted; my
own pristine sweeps byte-identical to the committed baselines; byteverify
4/1608 and 5/960 with every mover named a priori and attributed; canaries,
ctcan2, canaudit, rowheads and the five protected databases; and the 901-file
boundary with a positive control, AWAY-GOLDEN 0 / MOVED-WRONG 0.

## 11. THE DOC EDIT THIS LANDING IMPLIES

The patch surface is production + `tools/probe/r11u19repro/` only, as briefed,
so the scoreboard edit is NOT in it. It is stated here exactly, because it must
ride with the landing commit.

    SUPPORT_MATRIX.md
      | Surelog suite | default   | 798 | 469 | 14 |
      | Surelog suite | testflags | 798 | 465 | 12 |
      | uhdm2rtlil    | default   | 871 | 765 | 39 |
      | uhdm2rtlil    | testflags | 871 | 765 | 39 |

    GOLDEN_EQUIVALENCE.md §3.3
      | uhdm2rtlil | default   | 871 | CMP_EQUAL=765 SLANG_REJECT=67 CMP_NOTEQUAL=39 | 804 | 765 (95.1%) |
      | uhdm2rtlil | testflags | 871 | CMP_EQUAL=765 SLANG_REJECT=67 CMP_NOTEQUAL=39 | 804 | 765 (95.1%) |
      (and the surelog rows to 469/14 and 465/12)

If another pass lands between this one and integration, re-derive both tables
from the integrator's own sweep rather than applying these numbers blind.
