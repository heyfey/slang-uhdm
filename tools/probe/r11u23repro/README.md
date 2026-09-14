# r11u23 — the unbound half of the cont-assign ternary fold, and the LHS BINDING that travels with it

> **AMENDED BY THE ADVERSARIAL VERIFIER — read
> [tools/probe/r11v23repro/README.md](../r11v23repro/README.md) first.**
> The binary this document measures is NOT the binary that landed. r11v23
> found FIVE arms that go pristine-`CMP_EQUAL` -> law-`CMP_NOTEQUAL` on legal
> SV and five more away-golden installs, all from two defects:
> `genCaUnboundTernConcatFence23` tested the concat operand's slang AST KIND
> where `reduceExpr` tests its UHDM `VpiSize() == 64` (an unsized decimal, an
> enum value and a genvar are all written at 64), and
> `caLhsUnboundOwnLocal23`'s namesake walk saw only `Net`/`Variable`
> namesakes. Both are fenced in the landed patch. Consequently the
> "`0 REGRESS` / `AWAY-GOLDEN 0` / `MOVED-WRONG 0`" claims below, and this
> document's §7 R7 and R9, describe the UNAMENDED law; r11v23's §2 and §5
> carry the corrected model, the corrected verdicts (`h09` also CONVERTS) and
> the corrected residues. Everything else here — the producer decode, the
> corpus conversion, the census and the gate transcript — re-measured clean
> on the verifier's own binaries.

Base commit `5346c1e9`, worktree `/tmp/wt_r11u23`.  Pristine binary md5
`b46b0f3e573c5b435bb827c097e47091` — the OPS-stated main-tree md5 at the base,
reproduced byte for byte by my own build from source.  Law binary md5
`63a492555c0733b54ecd0214e801becb`.  The judge is the official `uhdm-cmp`
through `scripts/verify_golden.py`; everything in this directory is
measurement-only.  **`results/*.csv` ARE NOT EDITED BY THIS PASS.**

## A CORPUS ROW CONVERTS, IN BOTH MODES

    genscope_outer_reg_inner_ff,default,CMP_NOTEQUAL,decompile:,,
      ->  genscope_outer_reg_inner_ff,default,CMP_EQUAL,,,differ

    genscope_outer_reg_inner_ff,testflags,CMP_NOTEQUAL,decompile:,,
      ->  genscope_outer_reg_inner_ff,testflags,CMP_EQUAL,,,differ

**uhdm2rtlil goes 767 -> 768 CMP_EQUAL and 37 -> 36 CMP_NOTEQUAL in BOTH
MODES.**  It is the ONLY row that moves in either corpus: the surelog suite
stays 469/14 default and 465/12 testflags, and the byte verifier finds exactly
**2 movers of 1608** u2r databases (that row, both modes) and **5 of 960**
surelog databases, all five the proven UVM coin, convicted twice and never by a
count (§6).  `Earlgrey_0_1` is **byte-identical on the two binaries in both
modes** — `8bdf25272e08` / `59d0ee6d10c3` — and the reason is MEASURED cell by
cell, not argued (§5).  `results/*.csv` are left untouched; the promotion is
the integrator's.

## 1. THE NINE ARMS, RE-MEASURED ON MY OWN PRISTINE BUILD — AND THE BRIEF'S FRAMING CORRECTED

`grid/a01`-`a10` are BYTE-VERBATIM copies of the arms r11u22 committed for its
R0 (`r11u22repro/grid/{c01,c02,c05,c06,c07,c15,a07,a08,c03,c16}/dut.sv`),
re-run against the golden this pass's runner built itself
(`surelog -parse -nobuiltin -nocache -sv`), one head per row
(`grep -c '^LHS:'` on **stderr**).  Every arm `golden_rc=0 ours_rc=0`.
Golden's cont_assign Rhs and its Lhs `vpiActual`, read with `carhs23.py`:

| arm | r11u22 name | Lhs | golden Rhs | golden `vpiActual` | pristine cmp |
|---|---|---|---|---|---|
| `a01` | `c01` | a gen-LOCAL `logic [31:0]` | `'0` `BIN:0` ct 3 **size -1** | **absent** | 77 lines |
| `a02` | `c02` | the same, `32'd5` arm | `INT:5` ct 7 **size 64** | **absent** | 77 |
| `a03` | `c05` | a BIT-SELECT `o2[0]` | `'0` size -1 | (n/a) | 65 |
| `a04` | `c06` | a CONCAT `{o2,o3}` | `'0` size -1 | (n/a) | 72 |
| `a05` | `c07` | a MEMBER `o2.m` | `'0` size -1 | ref_obj | 77 |
| `a06` | `c15` | declared in the ENCLOSING gen scope | `'0` size -1 | **logic_var** | 66 |
| `a07` | `a07` | an INTERFACE gen scope | `'0` size -1 | logic_var | 73 |
| `a08` | `a08` | an INTERFACE at module scope | a constant | absent | 15 |
| `a09` | `c03` | a gen-local with a MODULE NAMESAKE | `'0` **size 4** | logic_var | 75 |
| `a10` | `c16` | a bare `var bv;` | `'0` size -1 | logic_var | 63 |

The sizes are the brief's R0 exactly — a fill at `VpiSize` **-1**, a value-able
fold as `INT:` at **64** — and they hold on my own build.

**BUT THE BRIEF'S NAMED CONVERSION CANDIDATE IS REFUTED AS A FOLD, AND THE ROW
CONVERTS FOR A DIFFERENT REASON.**  `genscope_outer_reg_inner_ff`'s head,
re-measured on my pristine build against the real v1.87 golden — 1 head, 15 cmp
lines — is NOT the ternary:

    LHS: <null>
    RHS: logic_var (work@genscope_outer_reg_inner_ff.gen_arbiter.gen_int_rr.rr_d)

An id-blind whole-dump diff of the two databases is **three hunks and the
cont_assign is not one of them**: golden's ternary at `dut.sv:26` and ours are
the SAME operation.  Golden cannot fold it — the condition is `gnt_i && |req_i`,
a signal, and the untaken arm `rr_q` is a bare `ref_obj` the operand gate
refuses.  What differs is that the cont_assign's **Lhs `ref_obj` carries a
`vpiActual` in ours and NONE in golden**, and `ref_obj::Compare` reads
`Actual_group`.  Reproduced as arm `a11`, which converts.

## 2. DECODE — ONE PRODUCER ARM, READ PAST `if (var)`, AND THE CLONE IS THE MECHANISM

`UhdmWriter::writeCont_assign` (Surelog v1.87 `UhdmWriter.cpp:2090`) runs for
EVERY instance.  `CompileHelper::bindVariable` (`CompileStmt.cpp:3094`)
switches on `uhdmfunction` / `uhdmtask` / `uhdmbegin` / `uhdmmodule_inst` and
tail-recurses on `scope->VpiParent()` for everything else, so from a
`gen_scope` it searches the enclosing module_inst's `Nets()` and `Variables()`
BY NAME and never sees a gen-LOCAL declaration.

```cpp
if (lhs->UhdmType() == uhdmref_obj) {
  any* var = bindVariable(mod, m, lhs->VpiName(), …);
  if (var) { …the BOUND arm r11u22 landed…
             ref_obj* ref = (ref_obj*)lhs;
             ref->Actual_group(var);            // :2165 — INSIDE `if (var)`
             cloned = true; } }
…
if (simplified == false) {                       // :2243 — THE UNBOUND ARM
  any* res = reduceExpr((expr*)rhs, invalidValue, …);
  if (invalidValue == false)
    if (res && (res->UhdmType() == uhdmconstant)) {      // A CONSTANT ONLY
      if (cloned == false) {
        assign = clone_tree(assign);  lhs = assign->Lhs();  cloned = true;
        res = adjustSize(tps, …, (constant*)res, true);
        res->VpiParent(assign); }
      assign->Rhs((constant*)res); } }
if (simplified == false && cloned == false) {            // :2283
  DetectUnsizedConstant detector;  …listenAny over the whole Rhs…
  if (detector.unsizedDetected()) {                      // ANY VpiSize == -1
    assign = clone_tree(assign); assign->VpiParent(m); cloned = true; } }
```

### § genCaUnboundTernFold23 — `tps` IS NULL, so NOTHING is re-encoded and NOTHING is re-sized

Reaching `:2243` with an operation Rhs REQUIRES `tps == nullptr`: a non-null
`tps` sends the ternary through the `if (tps)` flatten arm at `:2178`, which
sets `simplified`.  `CompileHelper::adjustSize` returns `c` UNTOUCHED on
`ts == nullptr` (`CompileHelper.cpp:4218`).  Three outcomes, measured arm by
arm on golden:

1. **A FILL ARM** keeps `VpiSize` **-1** and its RAW encoding.  `g01`-`g04`
   read our mint beside Surelog's with no ternary in the way:

   | fill | golden, unbound | ours, raw | the law |
   |---|---|---|---|
   | `'0` | `BIN:0` `'0` ct 3 size **-1** | `BIN:0` `'0` ct 3 size **32** | restore the size |
   | `'1` | `BIN:1` `'1` ct 3 size **-1** | **`UINT:4294967295` ct 9 size 32** | restore the whole encoding |
   | `'x` | `BIN:X` `'X` ct 3 size -1 | IDENTICAL | nothing |
   | `'z` | `BIN:Z` `'Z` ct 3 size -1 | IDENTICAL | nothing |

   This is § caTernFillArmKeepsEncoding19 run BACKWARDS, and `'1` is where the
   two homes visibly part: the BOUND half re-encodes it to `UINT:<mask>` at the
   Lhs width (r11u22 `b01`), the UNBOUND half must not touch it at all (`c02`).
   `'x`/`'z` are the control that the two mints already agree where golden does
   nothing.

2. **A VALUE-ABLE ARM** is `reduceExpr`'s own fresh constant at **`VpiSize(64)`**
   (`ExprEval.cpp:3888-3895`), `INT:<v>`, the decimal decompile, `vpiIntConst`
   — the Lhs width never enters.  Golden, one arm per row: `c05` `32'd5`->5/64,
   `c06` `{31'd0,1'b0}`->0/64, `c07` a param->9/64, `c08` `$clog2(33)`->6/64,
   `c09` an enum->1/64, `c10` `2+3`->5/64, `c11` `{16'd1,16'd2}`->65538/64,
   `c12` `2-3`->**-1**/64, `c13` `64'hffff…ffff`->**-1**/64,
   `c26` `{4{8'h0f}}`->252645135/64, `c28` `**`->8/64, `c29` a constant
   function->4/64, `c30` `$bits(a)`->32/64, `e06`/`e07`->5/64,
   `h04` `{32'd5}`->5/64, `h07` `inside`->1/64, `h08` `{K,K}`->38654705673/64,
   `h10` a cast enum->1/64.

3. **`result = the_val` INSTALLS THE ARM OBJECT — but ONLY when it is a
   CONSTANT**, and that fence is the whole difference from the bound half.
   Golden's three: `c19` a 72-bit literal (`HEX:` size 72), `c20` `32'bx`
   (`BIN:x` size 32), `c21` a real (`REAL:1.5` size 64 ct 2).
   **An arm `reduceExpr` hands back UNREDUCED is NOT a constant, so NOTHING is
   written back and golden KEEPS THE WHOLE TERNARY**: `c14` `^`, `c15` `===`,
   `c16` `$countones`, `c17` `{31'd0,a[0]}`, `c18` an inner ternary, `c23` a
   bare signal, `c24` a hier_path, `e05` an untaken bare part-select.  The
   BOUND half INSTALLS every one of those (r11u22 outcome 3); this half
   DECLINES them, and the two homes are correct to disagree.

### § genCaUnboundTernLhsNoActual23 — THE CLONE IS WHAT DROPS THE LHS BINDING

`ref->Actual_group(var)` is the only place `writeCont_assign` binds and it is
inside `if (var)`.  An UNBOUND Lhs ref is bound later by
`UhdmWriter::lateBinding` (`UhdmWriter.cpp:3299`) walking
`mod->getLateBinding()` — a list of the **ORIGINAL** refs.  Both clone sites
mint a FRESH `cont_assign` whose Lhs ref is not in that list, so a cloned
cell's Lhs keeps NO `vpiActual` at all.  Measured on golden, own-scope
gen-local Lhs in a gen scope:

    NO CLONE -> vpiActual PRESENT   b01 b02 b04 b05 b06 b13 b14 b18 b19 b20
                                    c14 c16 c17 c18 c23 c24 c27 e05
                                    f18 f20 f21 f22 h01 h02 h05
    CLONED   -> vpiActual ABSENT    b03 f01 f02 f06 f07 f08 f10 f13 f17 f19
                                    + every folding c/d/e/h arm
                                    + a11 e01 e02 e04 (NO FOLD, but an unsized
                                      `'0` in the Rhs: DetectUnsizedConstant)

and the ANCESTOR case is the exception that proves it is the LIST and not the
clone alone: `a06` and `f14` are cloned and **STILL BOUND**, because an
ancestor-gen-scope name is already resolved before `writeCont_assign` runs and
`clone_tree` copies the pointer.  **The predicate is OWN-SCOPE ONLY.**

`caLhsUnboundOwnLocal23` is that fence, and it is deliberately NARROWER than
"not `caLhsAdjustBind106`": that predicate is also false for shapes the
producer BINDS — a `time` Lhs, an implicit net, a bare `var d;` (`a10`), a
MODULE-BODY NAMESAKE (`a09`, where golden folds the 32-bit gen-local's `'0` at
the 4-bit module `lv`'s size) — and calling those unbound would move them to a
differently-wrong object.  All of them stay DECLINED, exactly as wrong as
pristine left them.

### § genCaUnboundTernConcatFence23 — AND IT COST A MOVED-WRONG CELL TO FIND

The first law build **REGRESSED `c27`** (`{31'd0, 32'd3 inside {32'd1,32'd3}}`)
from 15 cmp lines to 101: golden KEEPS that ternary and the law folded it to
`INT:1`.  The grid caught it before any gate ran.  The producer reason is in
`reduceExpr`'s `vpiConcatOp` arm (`ExprEval.cpp:4079-4110`):

```cpp
case vpiIntConst:  /* and vpiUIntConst */
  if (operands.size() == 1 || (size != 64)) { …append the bits… }
  else { c1 = nullptr; }               // THE WHOLE CONCAT DIES
```

and EVERY arithmetic / bitwise / comparison / reduction / `inside` arm of
`reduceExpr` mints its answer at `VpiSize(64)` (36 `VpiSize(64)` sites).  A
nested CONCAT operand is skipped by the `operType != vpiConcatOp` guard and
reaches the `else { c1 = nullptr; break; }` tail as a non-constant; a SELECT
operand is either not whitelisted by `constantOperands` at all (`part_select`,
`h01`) or simply does not value (`c17`).  In each case `result` is the
OPERATION, `get_value` on it invalidates, and golden keeps the ternary.

What DOES fold is the operand **Surelog already reduced at COMPILE time**, so
the UHDM tree holds a plain sized constant — `h03` `{16'd0, 16'd1 + 16'd2}` ->
`INT:3`, `h09` `{16'd0, 16'($clog2(33))}` -> 6, `h10` a cast enum -> 1, `h08`
`{K,K}` -> 38654705673, `c11` -> 65538.  This emitter cannot see which
sub-expressions Surelog folded before writing, so the fence is deliberately
CONSERVATIVE: a multi-operand concat's operands must each be a LITERAL, a fill,
or a parameter/enum/genvar reference (through casts).  `h03` and `h09` are
therefore **MISSES**, declined and left exactly as wrong as pristine left them,
never installed differently-wrong.  Measured:

    FOLD     c06 c11 c26 h04 h08 h10
    DECLINE  c15 c17 c27 h01 h02 h03 h05 h06 h09

The walk is RECURSIVE because the poison propagates upward: `32'd1 + {16'd0,
<an inside>}` breaks its own add exactly as the bare concat breaks itself.

### WHAT IS REUSED VERBATIM

The operand gate over all three operands including the untaken one
(`genTernKindOf22`), the condition read through the transcribed `ExprEval`
machine (`genTernCondTrue22`, with r11v22's § genTernCondSameMachine22
amendment), the closed system-function list (`genTernSysEvalable22`), the
operator-switch fence (`genTernOpsEvalable22`) and the int64 value machine
(`genTernInt64Eval22`) are the SAME objects the bound half calls, because
`reduceExpr` is the same call on both arms.  An untranscribed operator still
answers `nullopt` and the cell is DECLINED.  Only the INSTALL differs.

## 3. THE GOLDEN GRID — 112 arms, every rc recorded

`grid/` carries one `dut.sv` per arm (`mkgrid23.py` regenerates them);
`run23.sh <binary> <tag>` builds the GOLDEN and ours and records BOTH return
codes plus the head count and the cmp line count.  `GRID.pris.txt` /
`GRID.law.txt` are the two runs, `VERDICTS.r11u23.txt` the scored verdict,
`carhs23.py` THE SHAPE LISTER (one line per ELABORATED cont_assign: Lhs kind /
name / line:col, its `vpiActual`, and the Rhs object with size / value /
decompile / constType / opType) and `SHAPES.{pris,law}.txt` its output.

**Every arm is `golden_rc=0` AND `ours_rc=0` on BOTH binaries.**

**By `uhdm-cmp` rc: 39 CONVERT, 1 IMPROVE, 72 UNCHANGED, 0 REGRESS, 0 WORSE.**

**AN ARM AGREEING AT rc 0 IS NOT AN ARM TESTING THE LAW**, so every verdict is
also read off the per-cell CA-shape census: **43 arms CONVERT at the shape
level, 0 REGRESS, 0 MOVED-STILL-DIFF** — every cell the law touched landed on
golden's exact object, none on a third one.  The four shape-converts that are
not rc-converts (`c21` a real, `c22` a string, `c30` `$bits`, `d09`, `e04`)
have their remaining head on another family's face.

The arm families: Lhs home (own-scope gen-local var / ancestor gen-local /
gen-local NET / module net / module var / port / namesake / interface body /
interface gen scope / bit-select / concat / member / unpacked element /
part-select / bare `var`); Rhs kind against the `vpiActual` face (whole ref,
operation, literal, bit-select, hier_path, ternary, constant call, gen-local
ref); the three fold outcomes across 30 arm kinds; scopes (gen-if, gen-else,
gen-for, gen-case, nested x3, gen-if-in-gen-for, unnamed `genblk`, child
instance, two instances with different parameters, comma list, interface);
conditions (constant, parameter, genvar, gen-local localparam, signal, fill,
the untaken-operand gate x3); and the concat fence (10 arms).

**`d09_two_instances` is the per-instance proof**: `sub` is instantiated twice
with different parameters, and after the law instance `u1` (P = PNone, the `'0`
arm) folds to the fill at -1 exactly like golden while instance `u2`
(P = PBal, an operation arm) keeps the whole ternary exactly like golden.  All
three of its CA cells now match golden; its remaining 37-line head is an
`enum_typespec` face.

## 4. PREDICTION — the mover set BY NAME, a priori, with a positive control

`pred23.py` reads **PRISTINE databases only**; a database with no flagged cell
cannot move.  It is a deliberate SUPERSET: every ELABORATED `gen_scope`
`cont_assign` whose Rhs is a `vpiOpType:32` operation and whose Lhs is a whole
`ref_obj`.  It cannot see the own-scope fence, it cannot apply the operand gate
over the untaken arm, it cannot evaluate the condition, and it cannot tell an
installable arm from a declined one.  Per cell it also records `ACT=1` (our
pristine Lhs already carries a `vpiActual`, so only such a cell can LOSE one)
and `UNS=1` (a `vpiSize:-1` constant somewhere in the Rhs — the
`DetectUnsizedConstant` clone trigger).

**POSITIVE CONTROL** (`PRED.gridctl.txt`) — scored on the 112 grid arms from
their own PRISTINE dumps: it fires on **all 43** arms that really move, **0
misses**, and is SILENT on **47** of the 112 (the select-Lhs arms
`a03`/`a04`/`a05`/`d11`/`d12`, `a08`, and every non-ternary `b`/`f`/`g` arm);
the other 22 it flags without a move are the by-design over-approximation.  A
scan that could not see would have been silent on the movers too.

Over the **1608 PRISTINE u2r databases** (`PRED.u2r.txt`) it flags 2 rows x 2
modes and NOTHING ELSE:

    default+testflags/genscope_outer_reg_inner_ff   LAW=1 ACT=1 UNS=1   -> CONVERTS
    default+testflags/ibex_compressed_decoder       LAW=1 ACT=1 UNS=0   -> PREDICTED NON-MOVER
        `assign gets_expanded_o = valid_i ? gets_expanded : INSTR_NOT_EXPANDED;`
        — the condition is a SIGNAL so nothing folds, and UNS=0 so nothing
        clones.  Byte-identical on the two binaries, as predicted.

Over the **960 PRISTINE surelog databases** (`PRED.sl.txt`), 2 rows x 2 modes:
`Earlgrey_0_1` (1085 default / 1406 testflags flagged cells) and `Scr1SvTests`
(4).  **Both are measured NON-MOVERS, cell by cell — §5.**

## 5. WHY `Earlgrey_0_1` DOES NOT MOVE, AND IT IS COUNTED, NOT ARGUED

`R11U22_CELLDBG=1` on Earlgrey's own command line (the trace now prints the
unbound half's answers beside the bound half's, for EVERY gen-scope ternary
cell including the declined ones) reaches **1314 cells**:

    1041  bind=1 fold=0 arm=0 fill=0 ub=0 uarm=0 ufill=0 unb=0
     248  bind=0 fold=0 arm=0 fill=0 ub=0 uarm=0 ufill=0 unb=0
      25  bind=0 fold=0 arm=0 fill=0 ub=1 uarm=0 ufill=0 unb=0

The law's own-scope gen-local fence matches **25** of them — and on every one
`uarm=0 ufill=0 unb=0`: no fold is installed (their conditions are signal
comparisons that never value) and no unsized constant sits in their Rhs, so the
law takes NO ACTION.  The 14 cells `pred23` flagged as `UNS=1` are all in the
`ub=0` set.  The databases confirm it:

    Earlgrey_0_1 default    pristine 8bdf25272e08   law 8bdf25272e08   SAME
    Earlgrey_0_1 testflags  pristine 59d0ee6d10c3   law 59d0ee6d10c3   SAME

and `rowheads.sh` reads **cmp rc=0, 0 heads in BOTH modes**.  `Scr1SvTests`'s
four cells are all `bind=1 ub=0` and its database is byte-identical
(`c71d6e17de6f`) on both binaries.

## 6. THE CORPUS — every mover named, predicted, and attributed

**uhdm2rtlil, `byteverify.sh SELFCHECK=1` against my own pristine workdir:**

    PATH_SETS_IDENTICAL (1608 paths)
    MOVER ./default/genscope_outer_reg_inner_ff-e6115fca/slang.uhdm
    MOVER ./testflags/genscope_outer_reg_inner_ff-e6115fca/slang.uhdm
    MOVERS: 2 / 1608      SELFCHECK: 1607 / 1608 flagged

**Exactly the predicted row, and it CONVERTS** — measured directly against the
real v1.87 golden built for it: pristine `cmp_rc=255`, **1 head, 15 cmp lines**;
law `cmp_rc=0`, **0 heads, 0 lines**.  `ct8rows.sh` against
`results/gate_uhdm2rtlil.csv` prints **1 differing ROW**, quoted at the top of
this file; against the committed default half, the same one row.

**surelog: 5 movers of 960** (self-check 959/960): `default/MiniAmiq`,
`default/Scoreboard`, `default/SeqDriver`, `testflags/MiniAmiq`,
`testflags/SeqDriver`.  All five are the PROVEN UVM COIN, and the conviction is
**twice, never by a count**:

1. `pred23` flags **ZERO cells** in all five pristine coin databases, and
   `R11U22_CELLDBG=1` on MiniAmiq's own command line prints **0 gen-scope
   ternary cells** — the law cannot reach them.
2. The PRISTINE binary ALONE produced **three different databases in three
   runs** of MiniAmiq's own command line (`b3e215ded8ae`, `cdd84dbbb1bf`,
   `4e9716e5080f`), and the pristine-vs-pristine order-blind delta is the SAME
   4-line class as the law-vs-pristine one — one constant's `UINT` and its
   `vpiDecompile`.  Law-vs-pristine, order-blind:

        default/MiniAmiq     4 lines   UINT:533  -> UINT:1201  (+ decompile)
        default/SeqDriver    4 lines   UINT:1416 -> UINT:0
        testflags/MiniAmiq   4 lines   UINT:827  -> UINT:0
        testflags/SeqDriver  4 lines   UINT:731  -> UINT:0
        default/Scoreboard   **0 lines** — a pure list-ORDER flip

   Pinned by NAME and by CLASS; the COUNT is the draw.

**Against my OWN pristine surelog sweep the CSVs differ in exactly two rows,
and both are the workdir PATH STRING inside a `SURELOG_FAIL` detail**
(`LowMemLib`, `LowMemPkg` — `/tmp/r11u23_wd_pris/...` against
`/tmp/r11u23_wd_law/...`).  Every status, every dump-column verdict and
`Earlgrey_0_1` itself are identical.  Against the COMMITTED baseline those two
plus `Earlgrey_0_1,testflags`, whose DUMP column reads `differ` in the baseline
and empty in both of my sweeps — `verify_golden.py:625-632` initialises
`dump = ''` and swallows a `uhdm-dump` TimeoutExpired, so a slow dump blanks
the column.  STATUS is `CMP_EQUAL` on both binaries in both modes and
`rowheads.sh` reads 0 heads.

**AWAY-GOLDEN 0 / MOVED-WRONG 0.**

## 7. THE BOUNDARY — 1548 files, `PROCESSED == LISTED`

`bnd23.sh` compiles a file list with BOTH binaries, normalises the dump
(workdir path, object ids, output filename), sorts it order-blind, reads the
list on fd 3 with children `</dev/null` and asserts `PROCESSED == LISTED`.
`BND.list.txt` is every COMMITTED `.sv`/`.v` under `tools/probe` that has an
`assign` AND a ternary or a generate construct — 1436 files — plus this pass's
own 112 grid arms.

**`PROCESSED=1548 LISTED=1548 MOVED=47`**, and **not one file's rc differs
between the two binaries** (1518 rc 0, 15 rc 3, 15 rc 4 — the same on both).
43 of the 47 are this pass's own grid arms.

**POSITIVE CONTROL**: `r11u22repro/grid/c01_genlocal_fill0` (the UNBOUND arm)
reads `norm_delta=73` while its module-scope twin `a02_mod_fill0` reads **0**,
`a01_genif_fill0` (r11u22's own converted BOUND head) **0**, `b01_fill1_32`
**0**, `b12_untaken_partsel` **0**, `d17_untaken_baresig` **0**, this pass's
`b02_genlocal_rhs_op` (gen-local, no ternary) **0**, `c14_xor_arm` (gen-local
ternary, no fold, no unsized) **0**, and `f12_modulenet_tern_fold` (the BOUND
half's own shape) **0**.  The gate can see, it does not cry wolf, and the
bound half is untouched.

The **four COMMITTED movers** are each scored against the REAL v1.87 golden by
`bndattr23.sh`, and then cell by cell with the SHAPE LISTER:

| file | pristine | law |
|---|---|---|
| `r11u22repro/grid/c01_genlocal_fill0/dut.sv` | cmp 77 lines | **rc 0 EQUAL** (r11u22's R0 arm) |
| `r11u22repro/grid/c02_genlocal_sized/dut.sv` | cmp 77 lines | **rc 0 EQUAL** (r11u22's R0 arm) |
| `r10earl99repro/g3_home99.sv` | cmp 29, CA cells 1/N differing | cmp 29, CA cells **0/N** |
| `r10vearl99repro/v99_home.sv` | cmp 339, CA cells 2/N differing | cmp 339, CA cells **1/N** |

`g3_home99`'s `assign inner = sel ? d : '{a:'1, b:'0};` and `v99_home`'s
`assign gw = s ? '{a3:'1,b5:'0} : '{a3:3'd1,b5:5'd1};` are gen-local STRUCT
variables with a ternary Rhs carrying `'1`/`'0` fills: the fold declines (the
conditions are signals) and § genCaUnboundTernLhsNoActual23 drops the Lhs
`vpiActual` — golden has none.  **One `DIFF -> SAME` each, `SAME -> DIFF` 0
everywhere.**  `v99_home`'s remaining cell is its MODULE-scope `w`, untouched.

## 8. Residues

* **R1 — the SAME two faces on a NON-TERNARY Rhs, measured and left standing.**
  The clone fires for any Rhs, so the fold sizes and the dropped binding reach
  further than this law does.  Golden against pristine, each on its own arm:
  `g01` `assign lv = '0;` -> golden `'0` at **-1**, ours at 32; `g02`
  `assign lv = '1;` -> golden `BIN:1` `'1` ct 3 at **-1**, ours
  `UINT:4294967295` ct 9 at 32; `f01` the same inside a fold; `f07`
  `32'd2 + 32'd3` and `f08` `$clog2(33)` -> golden drops the `vpiActual`, ours
  keeps it; `f02` `a | '0`, `f10` `{a, '0}`, `f13` `a ^ 'x` and `f19`
  `'{default:'0}` -> golden drops it on the unsized clone alone, ours keeps it.
  This law is gated to a TERNARY Rhs deliberately: a bare `assign x = '0;` in a
  gen scope is among the commonest lines in real RTL and its corpus exposure is
  not this pass's measured set.  Wrong at pristine, unchanged here.
* **R2 — `f14`: an ANCESTOR gen-local with a LITERAL Rhs loses a binding golden
  keeps.**  `assign ov = '0;` in `g2` where `ov` is declared in `g1`: golden
  `vpiActual = logic_var`, ours absent.  § genCaLiteralRhsLhsNoBind22's second
  writer (`ModuleEmit.cpp` ~20180, `isLiteralExpr` guarding `bindGenLocal9`)
  is not ancestor-aware, where § genCaConstRhsLhsNoBind25 beside it explicitly
  is.  Its TERNARY twin `a06` is correct on both binaries.  A PRE-EXISTING
  module-family residue this pass neither touches nor inherits.
* **R3 — the fold on a NON-`ref_obj` Lhs.**  `a03` a bit-select, `a04` a
  concat, `a05` a member, `d11` an unpacked-array element (r11v22's RV4),
  `d12` a part-select: the whole `if (lhs->UhdmType() == uhdmref_obj)` block is
  skipped, `tps` stays null and the trailing arm folds anyway — golden's `'0`
  at -1 on every one.  `caLhsUnboundOwnLocal23` requires a whole `NamedValue`,
  so all five are DECLINED.  `pred23` is silent on them, so they are outside
  this law's containment as well as its surface.
* **R4 — `a07`/`a08`: the INTERFACE.**  `bindVariable` has no
  `uhdminterface_inst` case, so an interface's cont_assign takes the unbound
  tail too (golden `'0` at -1 in both) while its Lhs KEEPS a `vpiActual` in the
  gen scope (`a07`, `b15`) and has none at module scope (`a08`).  The fold face
  is r11u22's R1; the binding face is a third rule.  Declined.
* **R5 — `a09`/`a10`: `bindVariable` binds BY NAME and to a TYPESPEC-LESS
  declaration.**  Golden folds a gen-local `lv` at the 4-bit MODULE NAMESAKE's
  width (`a09`, `'0` size 4) and installs the raw `'0` at -1 on a bare
  `var bv;` (`a10`).  Both are BOUND cells with a null or unusable typespec, so
  `caLhsUnboundOwnLocal23` refuses them explicitly rather than treat them as
  unbound.  r11u22's R3 verbatim; wrong at pristine, unchanged.
* **R6 — `c22` a STRING arm and `c30` `$bits`.**  `get_value` reads
  `STRING:AB` as an integer, so golden is `INT:16706` at 64 where this emitter
  mints the string constant; `genTernInt64Eval22` has no `$bits` transcription.
  Both DECLINED (r11u22 R4 / its sys-function fence).  Their CA cells
  nevertheless converge because the fold path reaches them by another route —
  `c30` converges at the shape level and its head is elsewhere.
* **R7 — `h03`/`h09`: the CONCAT FENCE over-declines.**  Golden folds
  `{16'd0, 16'd1 + 16'd2}` and `{16'd0, 16'($clog2(33))}` because Surelog
  reduced those operands BEFORE writing them, and this emitter cannot see which
  sub-expressions it reduced.  Declined as MISSES, never installed
  differently-wrong (§2).
* **R8 — the installed constant carries no `vpiParent`.**  Golden's is
  `res->VpiParent(assign)` on the clone; ours is parented where `emitExpr` put
  it.  Judge-invisible — no generated `Compare` reads `VpiParent` — and
  inherited verbatim from r11u19 R1 / r11u22 R1.
* **R9 — the BOUND half has the concat fence's twin defect.**  § 2's `c27` fact
  applies to `genTernInt64Eval22` wherever it is called, so r11u22's landed
  bound-half law will fold a `{31'd0, <inside>}` arm golden keeps.  No corpus
  or boundary arm exhibits it (both were re-run: `f12` and every r11u22 grid
  arm read `norm_delta=0`), and OPS keeps this pass inside its own movers, so
  it is RECORDED and not touched.

## 9. Instruments

* `mkgrid23.py` — regenerates all 112 arms into `$GRID`; `grid/` is its output,
  committed.
* `carhs23.py` — THE SHAPE LISTER: one line per ELABORATED `cont_assign`, keyed
  by (Lhs kind, name, line:col), with its `vpiActual` and the Rhs object's
  kind / size / value / decompile / constType / opType.  It reads the dump's
  own nesting, so a `param_assign`'s Rhs is never mistaken for a
  `cont_assign`'s.  It is the arbiter for every grid and boundary verdict.
* `actual23.py` — the FACE A census used for the first decode (per-arm
  `vpiActual` table).
* `pred23.py` / `predrun23.sh` — the a-priori mover prediction (§4), computed
  from PRISTINE databases and scored on the 112 grid arms as its positive
  control.
* `run23.sh` — the grid runner (inherited from r11u19/r11u22 unmodified except
  the default `GRID`); `GRID.{pris,law}.txt`, `VERDICTS.r11u23.txt`,
  `SHAPEVERDICT.txt` and `SHAPES.{pris,law}.txt` are its records.
* `bnd23.sh` / `bndattr23.sh` — the boundary runner and its golden-scored
  attributor (§7), inherited with only the default paths changed.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the r10uvm221 battery, copied byte-for-byte unmodified.
* `R11U23_OFF=1` restores the pristine behaviour in the SHIPPED binary — the
  switch is in the law's ENTRY GUARD, so the OFF binary mints no serializer
  object, sets no flag and reaches no binding site.  It is INDEPENDENT of
  `R11U22_OFF`, which still switches the bound half.  `R11U22_CELLDBG=1` names
  EVERY gen-scope cont_assign whose Rhs is a ternary — the declined ones
  included — and now prints `ub` / `uarm` / `ufill` / `unb` beside the bound
  half's `bind` / `w` / `fold` / `arm` / `fill`.

## 10. Gates

`GATES.r11u23.txt` carries the transcript.  All green:

1. **Both binaries built `-j 2`, md5s taken separately**; the pristine one is
   `b46b0f3e573c5b435bb827c097e47091`, BYTE-IDENTICAL to the OPS-stated
   main-tree md5 at `5346c1e9`.  Law `63a492555c0733b54ecd0214e801becb`.
2. **Goldens 23 PASS / 0 FAIL** on BOTH binaries; `SLANG_UHDM=/bin/false`
   gives 0 PASS / 23 FAIL.
3. **u2r both modes**: 768 / 36 / 67, one differing row, quoted, and it is the
   conversion; byteverify 2 movers of 1608, both that row.
4. **surelog `--mode both`**: 469/14 default and 465/12 testflags, unchanged;
   three differing rows against the committed baseline, all three quoted in §6
   and none a judge verdict; byteverify 5 of 960, every one named a priori and
   attributed twice.
5. **Every `cmds.txt` audited by binary PATH**: 1581 surelog + 1742 u2r,
   **0 naming the main-tree binary** (50 surelog files carry no slang line at
   all — rows the golden side never produced a database for).
6. **Canaries** ok=52 changed=0 against my own pristine surelog sweep
   (ok=51 changed=1 against the committed baseline: `Earlgrey_0_1/testflags`'s
   dump column, §6); u2r ok=8 changed=0; ctcan2 PASS on both corpora;
   `rowheads.sh` green with `Earlgrey_0_1` at 0 heads in both modes.
7. **The seven protected databases**, law vs pristine, md5, with the OPS byte
   pins hit exactly: `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` in
   BOTH modes; `InterfaceModPort 59a365f3ce2c`; `BlackParrotComplex`,
   `YosysOldOr` SAME; `Earlgrey_0_1 8bdf25272e08 / 59d0ee6d10c3`.
8. **The 1548-file boundary** with a positive control, every file the same rc
   on both binaries, and all four committed movers scored against the REAL
   golden cell by cell: **AWAY-GOLDEN 0 / MOVED-WRONG 0**.
9. **`R11U23_OFF=1` reproduces the pristine bytes exactly** on `a01`, `a11`,
   `c02`, `e01`, `h02` and `d09`.
10. **The patch applies clean on a FRESH `5346c1e9`** and rebuilds from that
    fresh worktree to the same law md5.

## 11. THE SCOREBOARD MOVE THIS LANDING IMPLIES — FOR THE INTEGRATION COMMIT

uhdm2rtlil goes **767 -> 768 equal / 37 -> 36 not-equal in BOTH MODES**.  The
surelog rows are unchanged at 469/14 and 465/12.

This pass does NOT edit `results/*.csv` (OPS: they are read-only to a pass) and
therefore does NOT hand-edit the tables DERIVED from them — `GOLDEN_EQUIVALENCE`
§3.3 says in its own heading "GENERATED, do not hand-edit numbers", and a table
that contradicts its committed source data is worse than one refreshed beside
the promotion.  The integration cycle (RESUME §6) already puts both steps in the
SAME commit as this patch.  The three edits, spelled out so nothing has to be
re-derived:

1. Promote the two rows in `results/golden_uhdm2rtlil.csv` and the testflags one
   in `results/gate_uhdm2rtlil.csv`:

        genscope_outer_reg_inner_ff,default,CMP_NOTEQUAL,decompile:,,
          ->  genscope_outer_reg_inner_ff,default,CMP_EQUAL,,,differ
        genscope_outer_reg_inner_ff,testflags,CMP_NOTEQUAL,decompile:,,
          ->  genscope_outer_reg_inner_ff,testflags,CMP_EQUAL,,,differ

2. `python3 scripts/accounting.py --md` then reads — verified by running it
   against the promoted CSVs in this worktree and then reverting them:

        | uhdm2rtlil | default   | 871 | CMP_EQUAL=768 SLANG_REJECT=67 CMP_NOTEQUAL=36 | 804 | 768 (95.5%) |
        | uhdm2rtlil | testflags | 871 | CMP_EQUAL=768 SLANG_REJECT=67 CMP_NOTEQUAL=36 | 804 | 768 (95.5%) |

   which replaces the two uhdm2rtlil rows of `GOLDEN_EQUIVALENCE.md` §3.3
   (the two Surelog rows are unchanged).

3. `SUPPORT_MATRIX.md`'s baseline table: both uhdm2rtlil rows become
   `| 871 | 768 | 36 |`.
