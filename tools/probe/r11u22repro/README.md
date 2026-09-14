# r11u22 — the cont-assign ternary fold gets its generate-scope home, and it inherits golden's operand gate instead of our module-scope one

Base commit `40b5e0f3`, worktree `/tmp/wt_r11u22`.  Pristine binary md5
`d9ceb85d37a97fa6c77d1cc50da3c65a` — the OPS-stated main-tree md5 at the base,
reproduced byte for byte by my own build from source.  Law binary md5
`c80243213f2fdff761bf8188c7148aa7`.  The judge is the official `uhdm-cmp`
through `scripts/verify_golden.py`; everything in this directory is
measurement-only.  **`results/*.csv` ARE NOT EDITED BY THIS PASS.**

**r11u19's R0 IS CLOSED.**  `f07` — the brief's named witness, still committed
at `tools/probe/r11u19repro/grid/f07_genif_tern_fill0/dut.sv` — went from
**73 cmp lines to `uhdm-cmp` rc 0** against the real v1.87 golden, measured by
`bndattr22.sh` on the boundary run:

    r11u19repro/grid/f07_genif_tern_fill0/dut.sv  golden_rc=0
        pris_rc=0 cmp_rc=255 cmplines=73
        law_rc=0  cmp_rc=0   cmplines=0

**NO CORPUS ROW CONVERTS, AND NO CORPUS ROW REGRESSES.**  uhdm2rtlil reads
**766 CMP_EQUAL / 38 CMP_NOTEQUAL / 67 SLANG_REJECT in BOTH modes**, byte-identical
to the committed baselines, with **0 byte movers of 1608 databases**; the surelog
suite reads **469/14 default and 465/12 testflags**, with **4 byte movers of 960**,
all four the proven UVM coin.  This is a GROUNDWORK landing: the law is decoded
from the producer, gate-verified on a 101-arm golden grid where **56 arms convert
and 0 regress**, and its corpus footprint is measured at exactly zero — not
assumed.  §5 names, by count and by kind, the 1314 generate-scope ternary cells
of `Earlgrey_0_1` that the law REACHES and DECLINES, which is why that row stays
`CMP_EQUAL` in both modes.

## 1. THE HEAD, RE-MEASURED ON MY OWN PRISTINE BUILD

`f07` reproduced as grid arm `a01`, `uhdm-cmp` run on the golden the grid runner
itself built (`surelog -parse -nobuiltin -nocache -sv`), one head per row
(`grep -c '^LHS:'` on **stderr**), **73 cmp lines** — the brief's number exactly:

    a01  LHS golden  constant @ 7:56-7:58  vpiDecompile:'0 vpiSize:32 BIN:0 constType 3
         RHS ours    operation vpiOpType:32 (the whole ternary), operands
                       operation 15 (P != PNone), INT:0 sz 32 ct 7
                       operation 4  ~(32'hffffffff << s)
                       constant   vpiDecompile:'0 vpiSize:-1 BIN:0 ct 3

That is `assign o2 = (P != PNone) ? ~(32'hffff_ffff << s) : '0;` inside
`if (1) begin : gb`, over the module's `output logic [31:0] o2`.  Its
MODULE-SCOPE twin (`a02`, the same statement one `begin`/`end` shallower) is
`uhdm-cmp` EQUAL on the PRISTINE binary: the two homes run the SAME Surelog
code and only ours had one of them.

## 2. DECODE — ONE PRODUCER, READ AT THE PIN, THREE FENCES

### § genCaTernaryFoldGenScope22 — the fold is `writeCont_assign`, and the scope is `bindVariable`

`UhdmWriter::writeCont_assign` (Surelog v1.87
`src/DesignCompile/UhdmWriter.cpp:2090`) walks `netlist->cont_assigns()` for
EVERY instance — a generate scope is an instance like any other — and its FIRST
arm (`:2121`) is the only one that can write a NON-constant back:

```cpp
if (lhs->UhdmType() == uhdmref_obj) {
  UHDM::any* var = m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
  if (var) { if (rhs->UhdmType() == uhdmoperation) { …clone_tree(assign)…
      any* rhstmp = m_helper.reduceExpr((expr*)rhs, invalidValue, …);
      …tps = the BOUND VAR's Actual_typespec…
      if ((invalidValue == false) && rhstmp) {
        if (rhstmp->UhdmType() == uhdmconstant)
          rhstmp = m_helper.adjustSize(tps, …, (constant*)rhstmp, true);
        assign->Rhs((expr*)rhstmp); } } } }
```

`CompileHelper::bindVariable`'s scope-walking overload (`CompileStmt.cpp:3095`)
switches on `function` / `task` / `begin` / `module_inst` and NOTHING ELSE, so
from a `gen_scope` it falls through to the enclosing `module_inst` and finds
MODULE-BODY nets, variables and ports — never a gen-LOCAL declaration, never a
declaration in an ENCLOSING gen scope, and never anything from an INTERFACE
body.  `caLhsAdjustBind106` (r10earl106, verifier-amended in r10v106) already
decodes exactly that predicate and hands back `Bits(tps)`, so it is REUSED
rather than re-derived — the same reuse § genCaPackedPatternFold19 made one
pass ago.

`var == nullptr` does NOT mean "no fold": the function's trailing
`if (simplified == false)` arm (`:2247`) reduces the Rhs for ANY Lhs shape and
installs the result when it is a CONSTANT, with `tps` null so `adjustSize`
returns at once (`CompileHelper.cpp:4072`).  Measured on golden, one arm per
shape, and **this pass does NOT implement that half** (residue R1):

| arm | Lhs | golden |
|---|---|---|
| `c01` | a GEN-LOCAL `logic [31:0]` | the `'0` literal at `VpiSize` **-1** |
| `c02` | the same, `32'd5` arm | `INT:5` at **64** |
| `c05`/`c06`/`c07` | bit-select / concat / member Lhs | the unsized literal |
| `c15` | declared in the ENCLOSING gen scope | the unsized literal |
| `a07` | an INTERFACE gen scope | the unsized literal |

### THE THREE OUTCOMES, and they are `reduceExpr`'s `vpiConditionOp` arm read down

`UHDM/templates/ExprEval.cpp:3863-3903`:

```cpp
expr* cond = reduceExpr(operands[0], invalidValue, …);
int64_t condVal = get_value(invalidValue, cond);
if (invalidValue) break;                       // NO FOLD AT ALL
expr* the_val = reduceExpr(condVal ? operands[1] : operands[2], localInvalidValue, …);
bool the_val_is_fill = the_val && the_val->UhdmType() == uhdmconstant &&
                       ((constant*)the_val)->VpiSize() == -1;
if (localInvalidValue == false && !the_val_is_fill) {
  val = get_value(localInvalidValue, the_val);
  if (localInvalidValue == false) result = <INT:val, size 64>;
  else                            result = the_val;
} else                            result = the_val;
```

1. **A FILL ARM** (`'0` `'1` `'x` `'z`, `VpiSize` -1) is handed back UNCHANGED
   and then re-encoded by `adjustSize`'s `orig_size == -1` tail
   (`CompileHelper.cpp:4219-4241`) — § caTernFillArmKeepsEncoding19 verbatim,
   in its gen-scope home.  Golden, arm by arm: `'0` keeps `BIN:0` /
   `vpiDecompile:'0` / constType 3 SIZED at the Lhs width (`a01` 32, `b04` 1,
   `b05` 4, `b24` 72); `'1` becomes `UINT:<getMask(size)>` constType 9 at that
   width (`b01` 32 -> 4294967295, `b22` 1 -> 1) or `BIN:<size ones>` constType 3
   above 64 (`b23`); `'x` and `'z` are UNTOUCHED at `VpiSize` **-1**
   (`b02`/`b03`), because the whole body sits under `if (!invalidValue)` and
   `get_value` cannot parse `BIN:X` / `BIN:Z`.
2. **A VALUE-ABLE ARM** becomes ONE fresh `INT:<val>` constant, LOCATION-LESS
   and PARENT-LESS, sized by `adjustSize`'s final `else { c->VpiSize(size); }`
   at `Bits(tps)` — § elabCaTernaryFoldIntConst22's shape, in its gen-scope home.
3. **ANYTHING ELSE** is `result = the_val`, THE ARM OBJECT ITSELF, installed —
   § elabCaTernaryArmInstall92's shape, in its gen-scope home.

### THE OPERAND GATE — INHERITED FROM GOLDEN, NOT COPIED FROM OUR MODULE SCOPE

`ExprEval::reduceExpr` computes `constantOperands` over ALL THREE operands of
the conditional, **the untaken arm included** (`ExprEval.cpp:3121-3145`), and
abandons the ENTIRE reduce unless every one is a `constant`, an `operation`, a
`sys_func_call`, a `func_call`, a `bit_select`, a `hier_path`, a `var_select`,
an `enum_var`, or a `ref_obj` WHOSE NAME HAS A VALUE.  `part_select` and
`indexed_part_select` are NOT on that list, and the walk is ONE LEVEL DEEP.

The brief asked this pass to decide the question rather than copy our wider
module-scope behaviour, and the measurement settles it: **the PRISTINE gen-scope
emitter has no fold at all, so it AGREES with golden on every gated-out cell.
A gate-less copy of § elabCaTernaryFoldIntConst22 would have REGRESSED six
already-equal arms.**  Each is measured on golden and on both binaries:

| arm | shape | golden | pristine | law |
|---|---|---|---|---|
| `b12` | `f11`'s gen-scope twin: `'0` taken, `a[7:0]` UNTAKEN | KEEPS the ternary | KEEPS (EQUAL) | UNCHANGED |
| `d19` | `8'd5` taken, a BARE part-select untaken | KEEPS | KEEPS (EQUAL) | UNCHANGED |
| `d17` | `32'd5` taken, a BARE SIGNAL untaken | KEEPS | KEEPS (EQUAL) | UNCHANGED |
| `d12` | `'0` taken on a packed-2D Lhs, part-select untaken | KEEPS | KEEPS (EQUAL) | UNCHANGED |
| `e08` | a part-select TAKEN | KEEPS | KEEPS (EQUAL) | UNCHANGED |
| `b25`/`d11` | a bare signal in a ternary CHAIN | KEEPS | KEEPS (EQUAL) | UNCHANGED |

and against them `d18` — the untaken operand is `{24'd0, a[s +: 8]}`, an
OPERATION with an indexed part-select INSIDE it — where golden DOES fold
(`INT:5`), because the gate reads only the operand's own kind.  That pair is the
gate's whole content, and `f11`'s module-scope residue (r11u19 § R2) is left
exactly as it was.

### TWO MORE PRODUCER FENCES, and both would otherwise be MOVED-WRONG cells

* **THE SYSTEM-FUNCTION LIST.**  `ExprEval` implements a CLOSED set (the vrgg9
  list: `$clog2 $bits $size $high $low $left $right`); a reduce that needs one it
  does not implement hands the `sys_func_call` BACK.  Arm `d01` is golden
  INSTALLING `$countones(32'hff)` where slang's own `tryEval` folds it to 8;
  arm `d06` is the same fact on the CONDITION, where golden keeps the whole
  ternary.
* **THE OPERATOR SWITCH.**  `reduceExpr`'s operation switch
  (`ExprEval.cpp:3146-4880`) has a `case` for `vpiAdd/Sub/Mult/Div/Mod/Power/
  BitAnd/BitOr/LogAnd/LogOr/Not/BitNeg/Minus/Plus/the six comparisons/the four
  shifts/the six unary reductions/Inside/Concat/MultiConcat/Cast/Condition/the
  assignment patterns` and DEFAULTS — returning THE OPERATION UNTOUCHED — for
  everything else.  The absentees a real design writes are the BINARY XOR family,
  the case/wildcard/implication comparisons and the streaming operators, and each
  is measured as an arm golden INSTALLS rather than folds: `e01` `^` (op 30),
  `e02` `===` (op 16), `e11` `==?` (op 69), `e12` `->` (op 50), `e03`
  `{<<8{…}}` (op 72), and `e04` — the xor NESTED under a handled `+`, where
  golden installs the WHOLE add because `get_value` on the returned operation
  invalidates and the outer arm `break`s.  Against them `e06` `inside` (op 95)
  -> `INT:1` and `e10` `**` (op 43) -> `INT:8`, which ARE in the switch.
  `e07` is the same fact on the CONDITION.

### THE VALUE MODEL — `ExprEval`'s int64 arithmetic, not slang's context-typed evaluation

The two DISAGREE, and every disagreement would be a MOVED-WRONG cell.  Measured
on golden, one arm per row:

| arm | expression | golden | slang `tryEval` |
|---|---|---|---|
| `g01` | `32'd2 - 32'd3` | `INT:-1` | 4294967295 |
| `g02` | `-K`, `K = 1` | `INT:-1` | 4294967295 |
| `d13` | `-32'sd1` | `INT:-1` | 4294967295 |
| `g03` | `-32'sd5 / 32'sd2` | `INT:-2` | 2147483645 |
| `g04` | `32'shFFFFFFFF` | `INT:4294967295` | -1 |
| `d20` | `64'hFFFF_FFFF_FFFF_FFFF` | `INT:-1` | 18446744073709551615 |

`reduceExpr` reads every LEAF through `get_value`, which parses the constant's
own VALUE STRING — so a LITERAL is its written bit pattern read UNSIGNED
(`HEX:ffffffff` -> 4294967295, `g04`) while a PARAMETER or an ENUM member is
whatever Surelog wrote for the DECLARATION (`g07` `parameter int K = -1` and
`g08` `EN = -3` are both golden `INT:-<n>`) — and then combines them with plain
C++ `int64_t` operators.  `genTernInt64Eval22` is that machine, transcribed, and
it ANSWERS NOTHING for every operator it has not transcribed; a `nullopt` where
golden WOULD have folded makes the law DECLINE the cell rather than install a
differently-wrong object.  `vpiConcatOp` / `vpiMultiConcatOp` / `vpiInsideOp`
ARE answered, because they are bit-string operations whose result `get_value`
reads back unchanged (`d09` `{16'd1,16'd2}` -> `INT:65538`, `d10` `{4{8'h0f}}`
-> `INT:252645135`, `e06` -> `INT:1`, all three golden AND law).

## 3. THE GOLDEN GRID — 101 arms, every rc recorded

`grid/` carries one `dut.sv` per arm; `run.sh <binary> <tag>` builds the GOLDEN
(`surelog -parse -nobuiltin -nocache -sv`) and ours (`--single-unit
--nobuiltin`) and records **both** return codes plus the head count and the cmp
line count; `table.sh` is the three-column table (`GRID.r11u22.txt`),
`shapes.sh` the per-cell census (`SHAPES.{pris,law}.txt`) and
`VERDICTS.r11u22.txt` the scored verdict per arm.

**Every arm is `golden_rc=0`.**  100 of 101 are `ours_rc=0` on BOTH binaries;
`c11` (an IMPLICIT net driven from inside a generate block) is `ours_rc=3` on
BOTH — slang REFUSES it — so it teaches ERROR RECOVERY, not golden, and carries
no verdict.

**56 arms CONVERT to `uhdm-cmp` rc 0, 9 improve, 3 move to golden's exact object
with an unchanged cmp count, 32 are unchanged, 0 regress.**

**AN ARM AGREEING AT rc 0 IS NOT AN ARM TESTING THE LAW**: every verdict is read
off the per-cell CA-shape census (`shape.py`), never off the cmp rc.  The census
prints `[DIFF]` for a cell whose ONLY difference is golden's `vpiParent` — the
ternary clone the object came from — which is why `a01`/`b02`/`e02`/`e12`/`d07`
read `1/1` in the table while `uhdm-cmp` reads rc 0 on several of them: **no
generated `Compare` reads `VpiParent`** (r11u19 § R1).

### SCOPE — the fold reaches every generate shape (fill `'0`, module-body Lhs)

| arm | shape | golden | pristine | law |
|---|---|---|---|---|
| `a01` | gen-if (the head) | the `'0` literal, sized 32 | the whole ternary | CONVERT |
| `a02` | the MODULE-SCOPE twin | the same | EQUAL already | UNCHANGED |
| `a03` | a gen-if ELSE arm | sized 32 | ternary | CONVERT |
| `a04` | a for-generate | sized 32 | ternary | CONVERT |
| `a05` | a NESTED gen-if | sized 32 | ternary | IMPROVE 64 -> 15 cmp lines, NEW head |
| `a06` | a gen-if in a CHILD instance | sized 32 | ternary | CONVERT |
| `a09` | a gen-if INSIDE a for-generate | sized 32 | ternary | IMPROVE 64 -> 15, NEW head |
| `a10` | a for-generate with a GENVAR condition | sized 32 | ternary | CONVERT |
| `f02` | an UNNAMED generate block (`genblk1`) | sized 32 | ternary | CONVERT |
| `a07` | an INTERFACE gen scope | the literal at size **-1** | ternary | UNCHANGED (R1) |
| `a08` | INTERFACE module scope | a constant | — | UNCHANGED (R2) |

`a05`/`a09`'s head MOVES to a NEW OBJECT — a `logic_net work@top.o2` golden has
and we do not (`RHS: <null>`) — which is r11u19 `t14`'s nested-gen-block
net-declaration face, not this law's.

### ARM KINDS

| arm | selected arm | golden | law |
|---|---|---|---|
| `b01`/`b22`/`b23` | `'1` on 32 / 1 / 72 bits | `UINT:4294967295` ct 9 / `UINT:1` ct 9 / `BIN:<72 ones>` ct 3 | CONVERT |
| `b02`/`b03` | `'x` / `'z` | UNTOUCHED, `VpiSize` **-1** | CONVERT |
| `b04`/`b05`/`b06`/`b24` | `'0` at 1 / 4 / true-branch / 72 bits | the literal, sized | CONVERT |
| `b07`/`b08` | `32'd0` / `1'b0` | `INT:0` sized 32 / 1 | CONVERT |
| `b16`/`b21`/`d14`/`g07`/`g08` | a param / an enum / an enum param / `K=-1` / `EN=-3` | `INT:9` / `INT:1` / `INT:1` / `INT:-1` / `INT:-3` | CONVERT |
| `b17`/`g09` | `$clog2(33)` / `$clog2(W)+32'd1` | `INT:6` / `INT:7` | CONVERT |
| `d02`/`d05` | a constant user FUNCTION / `$bits(a)` | `INT:4` / `INT:32` | cell **0 of 1** (the row's head is the `function` / `sys_func_call` face, cmp count unchanged) |
| `d04`/`d09`/`d10`/`e06`/`e10` | `2+3` / a concat / a replication / `inside` / `**` | `INT:5` / `65538` / `252645135` / `1` / `8` | CONVERT |
| `g01`/`g02`/`g06`/`g07`/`g08` | `2-3` / `-K` / `2-3` on a signed Lhs / `K=-1` / `EN=-3` | `INT:-1` x4, `INT:-3` | CONVERT |
| `d13`/`g03`/`g05`/`g04` | `-32'sd1` / `-5/2` / `-1` on a signed Lhs / `32'shFFFFFFFF` | `INT:-1` / `INT:-2` / `INT:-1` / `INT:4294967295` | cell **0 of 1** (head on the `ref_typespec` face, 7-8 lines, unchanged) |
| `d20` | `64'hFFFF_FFFF_FFFF_FFFF` | `INT:-1` at size 64 | CONVERT |
| `b09`/`b11`/`b19`/`e01`/`e03`/`e04`/`e09`/`e11` | an OPERATION arm | the operation INSTALLED | CONVERT |
| `e02`/`e12` | `===` / `->` arms | the operation INSTALLED | golden's exact object modulo `vpiParent`; cmp count unchanged |
| `b13`/`d25` | `a[0]` / `mem[1]` | the select INSTALLED | CONVERT |
| `b15` | an inner ternary with a signal condition | the INNER ternary INSTALLED | CONVERT |
| `b20`/`d03` | a >64-bit literal / `4'bxx` | the LITERAL installed as itself | CONVERT |
| `d07` | `1.5` on a `real` Lhs | the REAL constant installed as itself | golden's exact object modulo `vpiParent`; cmp count unchanged |
| `d01` | `$countones(32'hff)` | the `sys_func_call` INSTALLED | IMPROVE 74 -> 8 |
| `d15` | condition `'1` | the TRUE arm installed | CONVERT |
| `b14` | a BARE `hier_path` arm | KEEPS the ternary | UNCHANGED (EQUAL) |
| `d08` | `"AB"` | `INT:16706` | UNCHANGED (R4) |
| `f01` | `PA[1]`, `PA = 32'h0003_0004` | `INT:0` (golden's own select decode) | UNCHANGED (R5) |
| `d16` | `int'(7)` | `INT:7` | UNCHANGED (R6) |

### LHS KINDS

| arm | Lhs | golden | law |
|---|---|---|---|
| `c10`/`c12`/`c13`/`c14` | a module `wire` / `bit [31:0]` / `int` / scalar `logic` | the literal sized 32/32/32/1 | CONVERT |
| `d21` | a COMMA-LIST `assign a = …, b = …` | KEEPS both cells (the untaken arm is a bare signal — the operand gate) | UNCHANGED (EQUAL), both cells (r11v22: this row read "CONVERT (both)"; `VERDICTS.r11u22.txt:72` and the byte A/B both say the two cells are declined and the databases are identical) |
| `d22` | `logic signed [7:0]` | the untaken part-select gates it out | UNCHANGED (EQUAL) |
| `f03` | THREE cells in one gen scope, one foldable | only the foldable one moves | CONVERT |
| `c01`/`c02`/`c05`/`c06`/`c07`/`c15` | gen-local / bit-select / concat / member / outer-gen-scope | the UNSIZED tail fold | UNCHANGED (R1) |
| `c03` | a gen-local with a MODULE NAMESAKE | `BIN:0` at the NAMESAKE's 4 bits | UNCHANGED (R3) |
| `c16` | a bare `var bv;` (no typespec) | the literal at `VpiSize` **-1** | UNCHANGED (R3) |
| `c08`/`c09` | a net-decl-assign / a process | KEEPS | UNCHANGED (EQUAL) |
| `c04` | a part-select Lhs | — | UNCHANGED (EQUAL) |
| `c11` | an IMPLICIT net in a gen scope | — | `ours_rc=3` BOTH binaries, NO VERDICT |

## 4. PREDICTION — the mover set BY NAME, a priori, with a positive control

`pred22.py` reads **PRISTINE databases only**; a database with no flagged cell
cannot move.  It is a deliberate SUPERSET: every ELABORATED `gen_scope`
`cont_assign` whose Rhs is a `vpiOpType:32` operation and whose Lhs is a whole
`ref_obj`.  It cannot see whether `bindVariable` binds, it cannot apply the
operand gate over the untaken arm, it cannot evaluate the condition, and it
cannot tell an installable arm from a declined one.  It walks the WHOLE dump
(`|uhdmallModules:` / `|uhdmtopModules:` are REPEATED keys, r11u19's own
sectioning bug).

**POSITIVE CONTROL** (`PRED.gridctl.txt`) — scored on the 101 grid arms from
their own PRISTINE dumps: it fires on **all 68** arms that really move bytes,
**0 misses**, and is silent on 8 of the 32 non-movers (the other 24 are the
by-design over-approximation).  A scan that could not see would have been silent
on the movers too.

Over the **1608 PRISTINE u2r databases** it flags 2 rows x 2 modes
(`PRED.u2r.txt`); over the **960 PRISTINE surelog databases**, 2 rows x 2 modes
(`PRED.sl.txt`).  **None of the four rows moved**, and the `R11U22_CELLDBG=1`
trace names why, cell by cell:

    uhdm2rtlil  genscope_outer_reg_inner_ff  dut.sv:26
        R11U22CELL … scope=…gen_arbiter.gen_int_rr bind=0 w=0 fold=0 arm=0 fill=0
        `assign rr_d = (gnt_i && |req_i) ? … : rr_q;` — `rr_d` is declared
        INSIDE `gen_int_rr`, so `bindVariable` never finds it (R1).
    uhdm2rtlil  ibex_compressed_decoder     ibex_compressed_decoder.sv:202
        R11U22CELL … scope=…gen_gets_expanded bind=1 w=2 fold=0 arm=0 fill=0
        `assign gets_expanded_o = valid_i ? gets_expanded : INSTR_NOT_EXPANDED;`
        — the condition is a SIGNAL and never values.
    surelog     Earlgrey_0_1   1085 (default) / 1406 (testflags) flagged cells
    surelog     Scr1SvTests    4 flagged cells

## 5. THE CORPUS — every mover named and attributed, and the non-movers too

**uhdm2rtlil, `byteverify.sh SELFCHECK=1` against my own pristine workdir:
0 movers of 1608**, `PATH_SETS_IDENTICAL`, self-check 1607/1608.

**surelog: 4 movers of 960** (self-check 959/960):

    default+testflags/MiniAmiq, default+testflags/SeqDriver

All four are the PROVEN UVM COIN, and the conviction is **twice, never by a
count**:

1. `pred22` flags **ZERO cells** in all four pristine coin databases, so the law
   cannot reach them.
2. The PRISTINE binary ALONE produced **three different databases in three runs**
   of MiniAmiq's own command line (`464ddfc9…`, `fad2316c…`, `2440ab77…`), and
   every pristine-vs-pristine order-blind delta is the SAME 4-line class — one
   constant's `UINT` and its `vpiDecompile`, drawing 1082 / 1178 / … .  The
   pristine-vs-law delta on each of the four movers is that identical shape:

        MiniAmiq  default    4 lines   UINT:1408 -> UINT:1116 (+ decompile)
        MiniAmiq  testflags  4 lines   UINT:799  -> UINT:1134
        SeqDriver default    4 lines   UINT:889  -> UINT:0
        SeqDriver testflags  4 lines   UINT:820  -> UINT:0

   Pinned by NAME and by CLASS.

**WHY `Earlgrey_0_1` DOES NOT MOVE, and it is measured, not argued.**  The
`R11U22_CELLDBG=1` trace on Earlgrey's own command line reaches **1314
generate-scope cont_assigns whose Rhs is a ternary** — 1041 with a BOUND
module-body Lhs, 273 unbound — and folds, installs or fills **NONE of them**:

    1041  bind=1 fold=0 arm=0 fill=0
     273  bind=0 fold=0 arm=0 fill=0

and the pristine dump says which fence stops which: **934 of the 1314 are
refused by the OPERAND GATE alone** (889 carry a bare `ref_obj` arm, 65 a
`logic_var` arm, 1 an `enum_const`), and the remaining 380 pass the operand gate
but their conditions are signal comparisons that never value.  The two Earlgrey
databases are byte-identical on the two binaries in both modes
(`8bdf25272e08`, `59d0ee6d10c3`) and the row stays `CMP_EQUAL` with 0 cmp lines
and 0 heads.

**AWAY-GOLDEN 0 / MOVED-WRONG 0.**

## 6. THE BOUNDARY — 1336 files, `PROCESSED == LISTED`

`bnd22.sh` compiles a file list with BOTH binaries, normalises the dump
(workdir path, object ids, output filename) and sorts it order-blind, reading
the list on fd 3 with children `</dev/null`.  `BND.list.txt` is every COMMITTED
`.sv` under `tools/probe` that has an `assign` AND a ternary or a generate
construct — **1235 files** — plus this pass's own 101 grid arms.

**POSITIVE CONTROL**: `a01` reads `norm_delta=67` and its module-scope twin
`a02` reads `0`, as do `b10` / `b12` / `d17` — the gate can see, and it does not
cry wolf.

**PROCESSED=1336 LISTED=1336 MOVED=72**, every moved file `pris_rc=0 law_rc=0`.
68 are this pass's own grid arms.  The **four COMMITTED movers** are each scored
against the REAL v1.87 golden by `bndattr22.sh`:

| file | pristine | law |
|---|---|---|
| `r11u19repro/grid/f07_genif_tern_fill0/dut.sv` | cmp 73 lines | **rc 0 EQUAL** (R0's own arm) |
| `r10earl106repro/g3_val106.sv` | cmp 17, CA shapes 15/29 | cmp 17, CA shapes **14/29** |
| `r10earl59repro/v59w6_more59.sv` | cmp 29, CA shapes 3/11 | cmp 29, CA shapes **2/11** |
| `r10v92repro/v8_gen.sv` | cmp 75, CA shapes 5/7 | cmp 75, CA shapes 5/7 |

Per-key verdict flips, computed cell by cell: `g3_val106` one `DIFF -> SAME`
(`48:34 work@g3_val106.n_terx.n_ter`), `v59w6_more59` one `DIFF -> SAME`
(`25:14 work@a1.u_sub.g_a.g_b.mn_ternc`), **zero `SAME -> DIFF` anywhere**.
`v8_gen`'s two moved cells (`26:14` and `31:14`) now match golden on every
judge-read field and differ only in `vpiParent`, so its count does not fall.
**AWAY-GOLDEN 0 / MOVED-WRONG 0.**

## 7. WHERE THE HEADS LAND NOW

* `f07` / `a01` converts, and so do the eight other generate shapes of §3.
* `a05` and `a09` (a gen-if nested in a gen-if, and a gen-if inside a
  for-generate) move from 64 cmp lines to **15 on a NEW OBJECT**: a `logic_net
  work@top.o2` golden has and we do not (`RHS: <null>`) — r11u19 `t14`'s
  nested-gen-block net-declaration face, which is now the head of both arms.
* `d01` moves from 74 cmp lines to **8** on a new object (the installed
  `sys_func_call`'s own `ref_typespec`).
* `d13` / `g03` / `g04` / `g05` keep a 7-8 line head on a `ref_typespec` — the
  typespec-linkage family — while their CA cells read **0 of 1** against golden.

## 8. Residues

* **R0 — THE UNBOUND HALF.**  `writeCont_assign`'s trailing
  `if (simplified == false)` arm folds the ternary for ANY Lhs shape and installs
  the constant with `tps` null, so `adjustSize` returns at once: golden keeps the
  `'0` literal at `VpiSize` **-1** and an `INT:` fold at **64**, parented at the
  cont_assign rather than at the ternary.  Seven measured arms — `c01`/`c02`
  (a gen-LOCAL Lhs), `c05`/`c06`/`c07` (bit-select / concat / member Lhs),
  `c15` (a declaration in the ENCLOSING gen scope) and `a07` (an INTERFACE gen
  scope) — plus the uhdm2rtlil witness `genscope_outer_reg_inner_ff` (`dut.sv:26`,
  `bind=0`) and **273 of Earlgrey_0_1's 1314 gen-scope ternary cells**.  This is
  the natural next head of the family: a second, UNSIZED install path beside the
  one this pass landed.  Wrong at pristine, unchanged here.
* **R1 — the installed object carries no `vpiParent`.**  Golden's arm is a clone
  that still points at the ternary operation it came from; ours is parented at
  the cont_assign or unparented.  Judge-invisible (no generated `Compare` reads
  `VpiParent`), inherited verbatim from r11u19 § R1, and it is what the CA-shape
  census prints as `[DIFF]` on `a01`/`b02`/`d07`/`e02`/`e12` and on `v8_gen`'s
  two boundary cells.
* **R2 — `a08`: an INTERFACE at MODULE scope.**  `bindVariable` has no
  `uhdminterface_inst` case, so an interface's own cont_assign takes the unbound
  tail too; our `emitContAssigns` runs its module-scope laws there regardless
  (`ModuleEmit.cpp` ~30247 passes an interface body).  A PRE-EXISTING
  module-scope residue this pass neither touches nor inherits.
* **R3 — `c03`/`c16`: `bindVariable` binds BY NAME, and to a TYPESPEC-LESS
  declaration.**  Golden folds a gen-local `lv` at the 4-bit MODULE NAMESAKE's
  width (`c03`, `BIN:0` size 4), and installs the raw `'0` at `VpiSize` -1 on a
  bare `var bv;` whose declaration carries no typespec (`c16`).
  `caLhsAdjustBind106` requires the Lhs symbol's OWN parent scope to be an
  `InstanceBodySymbol` and the declaration to carry a typespec, so this pass
  DECLINES both rather than move them to a differently-wrong object — the same
  choice r11u19 made for its own R7.  Wrong at pristine, unchanged.
* **R4 — `d08`: a STRING arm folds to its BYTES.**  `get_value` reads
  `STRING:AB` as an integer, so golden is `INT:16706` sized 32 where this
  emitter mints the string constant.  Declined, not installed.
* **R5 — `f01`: golden's own SELECT decode.**  `PA[1]` of
  `parameter logic [1:0][15:0] PA = 32'h0003_0004` is golden `INT:0` where
  slang's `tryEval` says 3.  A select arm that VALUES is declined; one that does
  not is installed (`b13`/`d25`), which is the shape the corpus carries.
* **R6 — `d16`: a `vpiCastOp` arm.**  `int'(7)` is golden `INT:7`;
  `genTernInt64Eval22` has not transcribed `reduceExpr`'s cast arm, so the cell
  is declined.  The same decline covers a `vpiBitNegOp` arm (whose mask comes
  from the operand's TYPESPEC, `ExprEval.cpp:3660`) and the unary reductions.
* **R7 — `e05`: a module VARIABLE with a constant initializer has a VALUE to
  golden.**  `ExprEval`'s `getValue(name, inst, …)` finds `int vv = 7;` and
  folds the arm to `INT:7`; `kindOf22` (and § elabCaTernaryArmInstall92's
  `kindOf92` before it) refuses every non-parameter `NamedValue`, so the operand
  gate breaks the chain.  Wrong at pristine at module scope AND in a gen scope,
  unchanged; the two homes stay consistent.
* **R8 — `f11` at MODULE scope still has no operand gate** (r11u19 § R2,
  restated because this pass deliberately did NOT copy that behaviour into the
  gen scope).  The two homes now DISAGREE with each other in golden's favour on
  the gen-scope side, exactly as r11u19's § R5 records for the pattern fold.

## 9. Instruments

* `pred22.py` / `predrun.sh` — the a-priori mover prediction (§4), computed from
  PRISTINE databases and scored on the 101 grid arms as its positive control.
* `shape.py` — THE SHAPE LISTER: every `cont_assign` in the judge-reachable
  ELABORATED listing, keyed by (owner kind, Lhs, line:col), with the Rhs OBJECT
  KIND and its size / value / decompile / constType / opType.  Copied byte for
  byte from `r11u19repro`; it is the arbiter for every grid and boundary verdict.
* `run.sh` / `table.sh` / `shapes.sh` — the 101-arm grid runner, its table
  (`GRID.r11u22.txt`) and the per-cell reports (`SHAPES.{pris,law}.txt`);
  `VERDICTS.r11u22.txt` is the scored verdict per arm.
* `bnd22.sh` — the boundary runner (§6), fd-3 file list, `PROCESSED == LISTED`.
* `bndattr22.sh` — builds the REAL v1.87 golden for one moved file and prints the
  OFFICIAL `uhdm-cmp` verdict for pristine and law, so every boundary mover's
  DIRECTION is measured, not argued.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the r10uvm221 battery, copied byte-for-byte unmodified.
* `R11U22_OFF=1` restores the pristine behaviour in the SHIPPED binary (the
  switch is in the law's ENTRY GUARD, so the OFF binary makes no serializer
  object at all); `R11U22_CELLDBG=1` names EVERY gen-scope cont_assign whose Rhs
  is a ternary, the declined ones included.

## 10. Gates

`GATES.r11u22.txt` carries the transcript.  All green: both binaries built
`-j 2` with md5s taken separately and the pristine one BYTE-IDENTICAL to the
OPS-stated main-tree md5; goldens 23/0 on both and 0/23 under `/bin/false`;
every `cmds.txt` audited by binary PATH (1742 u2r + 1581 surelog, 0 naming the
main-tree binary); u2r both modes byte-identical to the committed baselines;
surelog both modes with three differing rows quoted in full, none a status move;
byteverify 0/1608 and 4/960 with every mover named a priori and attributed;
canaries, ctcan2, canaudit, rowheads, the A/B gate and the seven protected
databases; and the 1336-file boundary with a positive control,
AWAY-GOLDEN 0 / MOVED-WRONG 0.

## 11. THE DOC EDIT THIS LANDING IMPLIES

**NONE.**  Both scoreboards are unchanged by this landing — uhdm2rtlil stays
766/38/67 in both modes and the surelog suite stays 469/14 and 465/12 — so
`SUPPORT_MATRIX.md` and `GOLDEN_EQUIVALENCE.md` §3.3 are already correct at
40b5e0f3 and must NOT be edited.  The landing's own numbers are the ones in this
file.
