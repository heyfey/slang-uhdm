# r11u27 — the NON-TERNARY cont-assign fold's three encodings, decoded and gated

Base commit `9b9fbf2e`, worktree `/tmp/wt_r11u27`.  Pristine binary md5
`58e64809ae74496d897279f045173b01` — the OPS-stated main-tree md5 at the base,
reproduced byte for byte by my own build from source.  Law binary md5
`1aa44227d521692d9125726594f5bfa1`.  The judge is the official `uhdm-cmp`
through `scripts/verify_golden.py`; everything in this directory is
measurement-only.  **`results/*.csv` ARE NOT EDITED BY THIS PASS.**

## HEADLINE — SAY IT LOUDLY: **ZERO CORPUS ROWS CONVERT, AND ZERO MOVE**

r11u25's R0 is the target and the brief warned the corpus footprint could be
LARGE.  The census came FIRST, on PRISTINE databases over both corpora and
both modes, and it is what decides this pass.

| corpus | databases scanned | flagged | byte movers under the law |
|---|---|---|---|
| uhdm2rtlil | 1608 | 372 | **0 / 1608** |
| Surelog suite | 960 | 126 | **3 / 960**, every one the proven UVM coin |

**uhdm2rtlil stays 768 CMP_EQUAL / 36 CMP_NOTEQUAL / 67 SLANG_REJECT in BOTH
MODES and the Surelog suite stays 469/14 default and 465/12 testflags.**
`Earlgrey_0_1` is **byte-identical on the two binaries in both modes** —
`8bdf25272e08` / `59d0ee6d10c3` — and §5 shows cell by cell WHY, from the law's
own trace, not from the absence of a delta.  `Rggen` is `d66b516b88c8` on both.

What the pass buys is **143 grid arms converting on legal SV at `uhdm-cmp` rc 0,
147 at the cell level, 0 REGRESS, 0 MOVED-WRONG**, r11u25's R0/R4/R5 closed,
and — on the 2976-file boundary — **17 cells of EARLIER passes' committed arms
moving ONTO golden, 0 AWAY**, with `r11u23repro/grid/f07_genlocal_rhs_constop`
going from 31 cmp lines to `uhdm-cmp` rc 0.

## 1. THE 13 FACE-3 ARMS, RE-MEASURED ON MY OWN PRISTINE BUILD

r11u25's R0 named 13 arms plus `r11`, `m08` and `m14`.  All of them reproduce
on my own build at `9b9fbf2e` against the real v1.87 golden
(`surelog -parse -nobuiltin -nocache -sv dut.sv`), own-scope gen-local
`logic [31:0] lv` unless the row says otherwise:

| arm | Rhs | golden | ours (pristine) |
|---|---|---|---|
| `u01` | `32'd2 + 32'd3` | `INT:5` ct 7 size **32** | the operation (op 24) |
| `u02` | `$clog2(33)` | `UINT:6` ct 9 size 64 | the `sys_func_call` |
| `u03` | `K + 1` | `UINT:10` ct 9 size 64 | the operation |
| `u04` | `{16'd1, 16'd2}` | `BIN:<32 bits>` ct 3 size 32 | the operation (op 33) |
| `u05` | `2 + 3` | `UINT:5` ct 9 size **64** | the operation |
| `u06` | `-(32'd1)` | `INT:-1` ct 7 size 32 | the operation |
| `u07` | `32'd5` | the literal ct 1 | IDENTICAL |
| `u08` | `K` | the param's own constant | IDENTICAL |
| `u09` | `$bits(a)` | `UINT:32` ct 9 size 64 | IDENTICAL |
| `u10` | `32'd1 << 3` | `UINT:8` ct 9 size 64 | the operation |
| `m01` (`r11`) | the same add at MODULE scope | `INT:5` ct 7 size 32 | **`UINT:5` ct 9** |
| `u12` | gen-local NET | `INT:5` ct 7 size 32 | the operation |
| `u13` | ANCESTOR gen-local | `INT:5` ct 7 size 32 | the operation |
| `m08`/`m01` | R5's module-scope `INT` vs `UINT` | `INT:5` ct 7 | `UINT:5` ct 9 |
| `m14` | R4's `'1` on a 128-bit target | `BIN:<128 ones>` ct 3 size 128 | `UINT:0` ct 9, decimal decompile |

## 2. DECODE — the encoding key is the LEAF's WRITTEN BASE, and nothing else

`UhdmWriter::writeCont_assign` (Surelog v1.87 `UhdmWriter.cpp:2243-2277`) runs
the SAME `reduceExpr` on a non-ternary Rhs that § genCaTernaryFoldGenScope22
decoded on a ternary one, and then

```cpp
if (res && res->UhdmType() == uhdmconstant) {
  if (cloned == false) { assign = clone_tree(assign); cloned = true;
                         res = adjustSize(tps, …, (constant*)res, true); }
  assign->Rhs((constant*)res); }
```

so golden's installed object is `reduceExpr`'s MINT, `adjustSize`d at
`Bits(tps)` when the Lhs has a typespec and **untouched when it has none**
(`CompileHelper.cpp:4073`, `if (ts == nullptr) return result;`).

### 2a. THE LEAF

`CompileHelper::compileExpression` (`CompileExpression.cpp:495-563`) writes a
BASED literal `<n>'<base><digits>` as

| base | value string | `vpiConstType` | `VpiSize` |
|---|---|---|---|
| `d` | `DEC:` | 1 `vpiDecConst` | the written size, or **-1** when omitted |
| `h` | `HEX:` | 5 `vpiHexConst` | " |
| `b` | `BIN:` | 3 `vpiBinaryConst` | " |
| `o` | `OCT:` | 4 `vpiOctConst` | " |

and an UNBASED one (`5`) as `UINT:` ct 9 at **64** (`INT:` ct 7 only when the
text carries a leading `-`).  The dump confirms it to the character: `32'd2` is
`DEC:2 ct 1 size 32`, `2` is `UINT:2 ct 9 size 64`.

### 2b. THE OPERATOR TABLE — `ExprEval::reduceExpr` read case by case

| shape | value | constType | VpiSize | measured on |
|---|---|---|---|---|
| Add/Plus (2 operands) | `val0+val1` | **`INT:` iff either reduced operand's ct is 7/6/2/1, else `UINT:`** | `max(size0,size1)` | Ua09 Ua11 Ua13 Ua30 Ua38 X17 X21 X22 |
| Sub / Mult / Div / Mod / Power | int64 | `INT:` always | **64** | Ua01 Ua02 Ua03 Ua04 X09 X13 X14 X15 |
| BitAnd / BitOr / LogAnd / LogOr | uint64 | `UINT:` | 64 | Ua05 Ua06 Ua21 X05 |
| the four shifts | uint64 | `UINT:` | 64 | Ua18 Ua19 X10 |
| unary `-` | `-val0` | `INT:` | the OPERAND's size | X12 (64) X24 (32) |
| unary `~` | masked | `UINT:` | the OPERAND's size | Ua23 |
| unary `!` | `!val` | `UINT:` | 64 | Ua22 |
| the six comparisons | 0/1 | `BIN:` | **1** | Ua20 X02 X03 X04 |
| concat / replication | the bit string | `BIN:` | the natural total width | Ua25 Ua26 W05 |

`ExprEval.cpp:3260-3300` is the add arm and its `unsignedOperation` loop is the
whole key: *if either reduced operand is a constant of ct `vpiIntConst` /
`vpiStringConst` / `vpiRealConst` / `vpiDecConst`, take the signed branch.*
`32'd2 + 32'd3` is two `DEC:` leaves → `INT:5` at `max(32,32)`; `2 + 3` is two
`UINT:` leaves → `UINT:5` at `max(64,64)`.  Nothing else separates them.

### 2c. THE PARAMETER OPERAND — measured, one arm per declaration

`P + P` at module scope, golden, with `P + 32'd1` as the control (the `32'd1`
flips every one of them to `INT:` on its own):

| declaration | golden `P + P` | so P contributes |
|---|---|---|
| `parameter int P = 9` | `UINT:18` | ct 9 (the unbased mint) |
| `parameter int P = -3` | `INT:-6` | ct 7 |
| `parameter P = 9` / `localparam P = 9` / `localparam int P = 9` | `UINT:18` | ct 9 |
| `parameter P = 32'hA` | `UINT:20` | ct 5 (HEX — not in the signed set) |
| `parameter P = 4'b1010` | `UINT:20` | ct 3 (BIN) |
| **`parameter P = 32'd9`** | **`INT:18`** | **ct 1 (DEC)** |
| **`parameter logic [7:0] P = 8'd9`** | **`INT:18`** | **ct 1 (DEC)** |
| `parameter byte P = 9` | `UINT:18` | ct 9 |

**A parameter operand contributes the constType of ITS OWN INITIALIZER
LITERAL, unchanged by the declared type**, and the SIZE of its declared type.
An initializer that is not one plain literal (or one negated literal) is
DECLINED.

### 2d. THE TWO INSTALLS, and the width ladder that proves them apart

* **UNBOUND** (an own-scope generate-local Lhs — `bindVariable` cannot find it,
  so `tps` is null): golden's object IS the raw mint.  `Uw01`/`Uw08`/`Uw64`/
  `Uw128` all carry golden's `INT:5` at **32** on 1-, 8-, 64- and 128-bit
  targets, and their `_unsized` twins all carry `UINT:5` at **64**.  THE LHS
  WIDTH NEVER ENTERS.
* **BOUND**: `adjustSize` runs.  A `vpiIntConst` matches NO branch of that
  function and falls to its final `else { c->VpiSize(size); }`
  (`CompileHelper.cpp:4243`) — the VALUE is left alone and only the size
  becomes `Bits(tps)`.  `Mw01_constop` is the proof: golden writes **`INT:5`
  into a ONE-BIT target**, where this emitter's `tryFoldConst` (slang's
  context-typed arithmetic over the ASSIGNMENT) gives `UINT:1`.

### 2e. THE DECLINES, each a measured arm where golden INSTALLS the operation

* the BINARY XOR family and the case/wildcard/implication comparisons —
  `reduceExpr`'s switch has no `case` (`Ua07` `^` op 30, `X01` `~^` op 31);
  § genTernOpsEvalable22 is that fence, reused unchanged;
* **UNARY PLUS** — `case vpiPlusOp` shares the BINARY add arm and its
  `operands.size() == 2` guard, so `+x` falls through and the operation comes
  back (`X11`, golden op 2 on both halves);
* a BIN / HEX / OCT leaf WIDER THAN 64 BITS — `get_value` and `get_uvalue` both
  set `invalidValue` outright above 64 (`ExprEval.cpp:1673` / `:1750`), which
  poisons the reduce and makes `invalidValue == false` refuse the write:
  **`W02` `128'h2 + 128'h3` is golden's OPERATION** where `W01`
  `128'd2 + 128'd3` (a `DEC:` leaf, no such guard) is golden's `INT:5` at 128;
* a STRING / REAL leaf, a user FUNCTION call, a select, a hier_path, a cast and
  the unary reductions — not transcribed, so the law answers nothing.

### 2f. THE MINT FENCE — and it cost an AWAY-GOLDEN cell to find

`reduceExpr` MINTS a fresh constant only on its OPERATION arms.  A **bare LEAF
Rhs** — a literal, a parameter, an enum member — is handed back as THE STORED
OBJECT, which golden only re-sizes.  The first law binary ignored that and the
2976-file boundary convicted it on `tools/probe/r10uvm154repro/g154_d_inst.sv`:

    assign o = pk_d154::D_ALL;      // enum bit [31:0] { D_ALL = -1 }
    golden   INT:-1          pristine INT:-1          law (before the fence) INT:4294967295

one AWAY-GOLDEN cell, **invisible to the cont-assign cell lister** (whose slot
reads blank on that object — RESUME §9's "slot-keyed censuses are blind below
the slot"), found only by the boundary's whole-dump normalised diff.
`caFoldMintShape27` admits only `BinaryOp` / `UnaryOp` / `Concatenation` /
`Replication`.  The controls were already on the grid and already EQUAL on the
PRISTINE binary — `u07`/`m07` (`32'd5`), `u08`/`m08` (`K`), `Ua33`/`Ma33`
(`(32'd5)`), `Ua34`/`Ma34` (`5`) — so the fence costs **no arm** (143 rc-
converts and 147 cell-converts with and without it) and removes the whole
class.  `g154_d_inst.sv` is byte-identical on the two binaries under it.

## 3. THE LAWS — three, one machine, everything else reused

* **`caFoldEnc27`** (`ModuleEmit.cpp`, beside `genTernInt64Eval22`) — the
  ENCODING channel: §2a's leaf table, §2c's parameter rule and §2b's operator
  table, returning `false` (DECLINE) for everything else.  `caLeafEnc27` reads
  the written base off the literal's own source text, because that is the only
  thing that decides it.
* **LAW A, the BOUND half** (the module / elaborated cont-assign install):
  re-encodes ONLY cells this emitter ALREADY folds, and ONLY when the machine
  proves `ct == vpiIntConst`.  `UINT:` and `BIN:` are the two encodings this
  emitter already reproduces on every measured arm (`Ma05` `Ma06` `Ma11` `Ma12`
  `Ma16` `Ma18`-`Ma20` `Ma25` `Ma26` `Mw*`), so touching them could only move a
  cell that is already right.  It installs the producer's VALUE too, never a
  re-prefixing of ours: `Ma14` is golden `INT:-1` where we had
  `UINT:4294967295`.
* **LAW B, R4** — a module-scope `'1` on a target WIDER THAN 64 BITS:
  `adjustSize`'s `orig_size == -1` tail (`CompileHelper.cpp:4225`) splits on the
  width, `UINT:<mask>` at or below 64 (`W08`, which we already match) and
  `BIN:<size ones>` ct 3 above it (`m14` `W09` `W10` `W13` `W14`).  This is
  § caTernFillArmKeepsEncoding19's own over-64 branch, already committed at the
  gen-scope ternary site, reaching the plain module-scope mint.
* **LAW C, the UNBOUND half**: installs the RAW mint where the producer's
  `adjustSize` is a no-op.  The fence is r11u25's `caLhsBindVariableFinds25`
  INVERTED — only a target `bindVariable` CANNOT find reaches the null-typespec
  arm — which is exactly why this half is corpus-invisible (§5).

**WHAT IS REUSED VERBATIM**: `genTernOpsEvalable22` (the operator-switch
fence), `genTernSysEvalable22` (the system-function fence),
`genTernConcatSafe23` (the concat fence), `genTernInt64Eval22` (the int64 value
machine), `caLhsAdjustBind106` (the bound width) and `caLhsBindVariableFinds25`
(the bind fence).  `reduceExpr` is the same call on the ternary and non-ternary
arms, so the ternary halves § genCaTernaryFoldGenScope22 /
§ genCaUnboundTernFold23 / § caTernFillArmKeepsEncoding19 are not touched — a
`ConditionalOp` Rhs is refused at every r11u27 entry guard, so the laws are
disjoint from them by construction.

## 4. THE GOLDEN GRID — 245 arms, every rc recorded

`grid/` carries one `dut.sv` per arm (`mkgrid27.py` + `mkgrid27b.py`
regenerate them); `run27.sh <binary> <tag>` builds the GOLDEN and ours and
records BOTH return codes plus the head count and the cmp line count.
`GRID.pris.txt` / `GRID.law.txt` are the two runs, `shapes27.sh` +
`carhs27.py` THE SHAPE LISTER (one line per ELABORATED `cont_assign`: the Lhs
kind / name / line:col, its `vpiActual`, and the Rhs object with size / value /
decompile / constType / opType), `SHAPES.{pris,law}.txt` its output and
`SHAPEVERDICT.txt` the per-arm scoring.

**Every arm is `golden_rc=0` AND `ours_rc=0` on BOTH binaries.**

**By `uhdm-cmp` rc: 143 CONVERT, 0 REGRESS, 0 WORSE, 102 UNCHANGED.**

**AN ARM AGREEING AT rc 0 IS NOT AN ARM TESTING THE LAW**, so every verdict is
also read off the per-cell CA-shape census: **147 CONVERT, 0 REGRESS, 0
MOVED-STILL-DIFF, 71 EQUAL-BOTH, 27 DIFF-UNCHANGED.**

The axes: the operand-shape ladder (40 shapes × bound and unbound) × the Lhs
home (module var / module net / port / own-scope gen-local var / gen-local NET
/ ancestor gen-local / module-body NAMESAKE / interface gen scope / interface
body / bit-select / part-select / bare `var`) × the scopes (gen-if, gen-for,
gen-case, nested, unnamed `genblk`, a CHILD instance, two instances of one
child, a delayed assign, two cells in one block where only one is foldable) ×
the target width (1 / 8 / 32 / 64 / 128) × the parameter-declaration ladder
(10 declarations × 3 uses) × the over-64 branch (14 arms) × 24 further
operators.

`s07_iface_gen` deserves its own line: an interface's GENERATE scope is
unbound, because `bindVariable`'s scope walk stops dead at an `interface_inst`
(§ caLhsAdjustBind106's own note), so LAW C installs the raw `INT:5` at 32 and
the arm **converts to rc 0**.

## 5. THE CENSUS, AND WHY THE CORPUS DOES NOT MOVE — ATTRIBUTED, NOT ASSUMED

`pred27.py` reads **PRISTINE databases only**; a database with no flagged cell
cannot move.  Two separable, deliberately-superset faces:

* **FB** — an ELABORATED `cont_assign` whose Lhs is a whole `ref_obj` and whose
  Rhs is ALREADY a `constant`: a cell this emitter folds, so the law can only
  RE-ENCODE it.  Split by the encoding we currently carry, because LAW A can
  only turn `UINT:`(9) into `INT:`(7) — **FB9 is the movable set**.
* **FU** — an ELABORATED `gen_scope` `cont_assign` whose Lhs is a whole
  `ref_obj` and whose Rhs is still an `operation`: the cells LAW C could
  install a constant into.

Neither can see the operand shapes that decide golden's branch, nor the bind
fence, so both over-flag by design.

| corpus | scanned | flagged | FB9 | FB7 | FB3 | FBX | FU |
|---|---|---|---|---|---|---|---|
| uhdm2rtlil (both modes) | 1608 | 372 | 422 | 38 | 322 | 182 | 666 |
| Surelog suite (both modes) | 960 | 126 | 383 | 12 | 1170 | 774 | 9868 |

The sharpest rows are the gates: `Earlgrey_0_1` testflags carries FB9 32 /
FB3 227 / FU 6333 and default FB9 32 / FU 3352; `Rggen` default FB9 53 / FB3
266 / FU 72; `YosysOldOr` FB9 26 / FB3 44 both modes; `YosysVerx` FB3 104 both
modes; `net_types` FB9 20; `param_no_default` FB9 16; `DoubleLoop` FB9 20;
`gen_test5` FU 255 per mode; `ibex_alu` FB3 36.  **PRED.u2r.txt** and
**PRED.sl.txt** carry every flagged row by name.

**POSITIVE CONTROL** — the census scored on the 245 grid arms from their own
PRISTINE dumps: it fires on **every one of the 147 arms that really move, 0
misses**, is silent on 35 of 243, and the 62 it flags without a move are the
by-design over-approximation.  A scan that could not see would have been silent
on the movers too.

### WHY THEY DO NOT MOVE — the two cell traces

`R11U27_CELLDBG=1` prints one line for EVERY cont_assign reaching either fold
site, the DECLINED ones included, with each fence's answer.  Both predicates
are computed OUTSIDE the A/B switch, so both binaries name the same cells.

    default/Earlgrey_0_1  cells=185 bnd=47 enc=2 ct7=0 | gen=5182 bvf0=1026 genenc=1 genval=0
    default/Rggen         cells=230 bnd=92 enc=0 ct7=0 | gen=117  bvf0=13   genenc=1 genval=0
    default/Scr1SvTests   cells=73  bnd=73 enc=0 ct7=0 | gen=4    bvf0=0    genenc=0 genval=0
    default/WireType      cells=40  bnd=40 enc=0 ct7=0 | gen=0
    testflags/net_types   cells=40  bnd=40 enc=0 ct7=0
    testflags/param_no_default cells=16 bnd=16 enc=0 ct7=0
    testflags/ibex_alu    cells=6   bnd=6  enc=0 ct7=0

`Earlgrey_0_1`'s bound site is reached on **185 cells** and its generate site on
**5182**, **1026 of them the very shape LAW C targets** (`bvf=0`, a target
`bindVariable` cannot find) — and `ct7 = 0` and `genval = 0` on every one of
them.  The corpus's constant cont-assign folds are unsigned-branch shapes and
bare leaves; not one is an `INT:`-branch mint.  That is the explanation the
byte-identical database cannot give by itself.

**POSITIVE CONTROL for the traces** (`CELLDBG.poscontrol`, reproduced by
`celldbg27.sh` on the grid): `m01` prints `bnd=1 w=32 enc=1 ct=7` (it moves),
`Ma05` (`32'd6 & 32'd3`) prints `enc=1 ct=9` (it does not), `u01` prints
`bvf=0 enc=1 ct=7 sz=32 val=1`, `Ua05` prints `bvf=0 enc=1 ct=9 sz=64 val=1`,
`s25_twocells` names three DIFFERENT fences on the three cells of one block
(line 7 fires, line 8 `enc=0`, line 9 `bvf=1`), and `u08` — a BARE parameter
Rhs — prints **NOTHING**, the mint fence refusing it before any machine runs.
The gate can see, and it does not cry wolf.

## 6. THE GATES — all green

1. **Both binaries built `-j 2`, md5s taken separately.** Pristine
   `58e64809ae74496d897279f045173b01`, BYTE-IDENTICAL to the OPS-stated
   main-tree md5 at `9b9fbf2e`.  Law `1aa44227d521692d9125726594f5bfa1`.
2. **Goldens 23 PASS / 0 FAIL** on BOTH binaries; `SLANG_UHDM=/bin/false`
   gives 0 PASS / 23 FAIL.
3. **u2r both modes**: 768 / 36 / 67, **zero differing rows** against the
   committed baseline AND against my own pristine sweeps, both modes;
   byteverify **0 movers of 1608**, SELFCHECK 1607/1608.
4. **surelog `--mode both`**: 469/14 default and 465/12 testflags, unchanged.
   Four differing rows against the committed baseline, all four quoted in the
   transcript: two SURELOG_FAIL detail strings that embed the WORKDIR PATH
   (`LowMemLib`, `LowMemPkg` — not judge verdicts), and `Earlgrey_0_1`'s DUMP
   COLUMN reading blank in BOTH modes on a uhdm-dump timeout draw, which OPS
   names explicitly; its STATUS stays `CMP_EQUAL` and its database is
   byte-identical on the two binaries (`8bdf25272e08` / `59d0ee6d10c3`), which
   is the pin.
5. **byteverify surelog: 3 of 960**, every one the proven UVM coin
   (`MiniAmiq` both modes, `SeqDriver` testflags), convicted TWICE — an
   order-blind 4-line line-number-class delta (`UINT:<n>` + `vpiDecompile:<n>`
   pairs) and the PRISTINE binary run a SECOND time against its own first run
   reproducing the identical 4-line class on all four rows (`coin27.sh`).  The
   COUNT is a per-run draw: the pre-fence law binary drew 4, this one 3.
6. **Every `cmds.txt` audited by binary PATH**: 1581 surelog + 1742 u2r,
   **0 naming the main-tree binary** (50 surelog files carry no slang line at
   all — rows the golden side never produced a database for).
7. **Canaries** ok=50 changed=2 against the committed baseline (both changes
   the `Earlgrey_0_1` dump column of gate 4) and ok=51 changed=1 against my own
   pristine sweep; u2r ok=8 changed=0; `ctcan2` PASS on both corpora;
   `canaudit.sh` PASS; `rowheads.sh` **byte-for-byte identical** to the same
   script over my own pristine workdir, with `Earlgrey_0_1` at 0 heads / cmp
   rc 0 in both modes.
8. **The seven protected databases**, law vs pristine, md5, with the OPS byte
   pins hit exactly: `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` in
   BOTH modes; `InterfaceModPort 59a365f3ce2c`; `BlackParrotComplex`,
   `YosysOldOr` SAME; `Earlgrey_0_1 8bdf25272e08 / 59d0ee6d10c3`;
   `Rggen d66b516b88c8`; `Scr1SvTests c71d6e17de6f / c5bdbceb5ab7`.
9. **The 2976-file boundary** (`BND.list.txt` = r11u25's 2731 committed arms
   plus this pass's 245 grid arms), every file the same rc on both binaries,
   `PROCESSED == LISTED`, 0 rc mismatches, 157 movers of which 148 are this
   pass's own grid arms — which is the boundary's own positive control, the
   gate demonstrably seeing a moved cell.  All **9 COMMITTED movers scored
   against the REAL golden cell by cell**, multiset-aware (`bndscore27.sh`;
   the same Lhs name recurs once per INSTANCE, so a list compare reads one
   instance's move as a whole-key move):
   **TO-GOLDEN 17 / AWAY-GOLDEN 0 / MOVED-WRONG 0**, with one
   STILL-WRONG-CHANGED cell (`r10v87repro/arms/va6_typedefparam87.sv`'s `o`,
   golden `INT:100`, wrong on BOTH binaries at 9 and 6, whose ENCODING moves
   from `UINT:` onto golden's `INT:`).  By the official `uhdm-cmp` against the
   same golden: `r11u23repro/grid/f07_genlocal_rhs_constop` **CONVERTS to
   rc 0** (31 cmp lines → 0), `r10earl_repro/qb23.sv` IMPROVES 31 → 18, the
   other seven are unchanged, **none worse**.
10. **`R11U27_OFF=1` reproduces the pristine bytes exactly** on 13 of 13 arms
    spanning both laws (`m01`, `Ma14`, `Mw01`, `u01`, `u04`, `Ua20`, `m14`,
    `W09`, `Pp05_sized_d_Mp`, `s25_twocells`, `X13_hex_sub_U`,
    `V02_child_gen_add`, `s07_iface_gen`).
11. **The patch applies clean on a FRESH `9b9fbf2e`** and rebuilds from that
    fresh worktree to the same law md5 (§8).

### THE FENCED-TEST AUDIT — read this before running the integrator's grep

`awk '/^diff --git/{f=$4} /UnsignedParam/{print f}' $P | grep -v canaudit |
grep -c .` returns **2, not 0**, and both hits are the SAME uhdm2rtlil row
`SizeOfUnsignedParameter` inside `PRED.u2r.txt` — a SUBSTRING collision with
the fenced surelog row name, not a fenced row:

    +default/SizeOfUnsignedParameter-499af5fe/slang.uhdm FB9=1 FB7=0 FB3=0 FBX=0 FU=0
    +testflags/SizeOfUnsignedParameter-499af5fe/slang.uhdm FB9=1 FB7=0 FB3=0 FBX=0 FU=0

The check that settles it, and it is ZERO:

    grep -cE '(^|[^a-zA-Z])(UnsignedParam|HierPathEval|FileLocalParam|TopParam)(-[0-9a-f]{8}|/|,|$)' $P   # 0

`PRED.sl.txt` — the SURELOG-suite census, where those four rows live — names
**none** of them.  No fenced test is dispatched, named or measured by this
pass; the only other occurrence in the patch is `canaudit.sh`'s own
`FENCED="…"` list, which OPS permits.

### THE SCOREBOARD MOVE THIS LANDING IMPLIES — FOR THE INTEGRATION COMMIT

**NONE.**  uhdm2rtlil stays 768 CMP_EQUAL / 36 CMP_NOTEQUAL / 67 SLANG_REJECT
in both modes and the Surelog suite stays 469/14 and 465/12.  `results/*.csv`,
`GOLDEN_EQUIVALENCE.md` §3.3 and `SUPPORT_MATRIX.md`'s baseline table are all
still correct exactly as committed, so this landing implies no document edit
and makes none.  What it buys is on the grid and the boundary: r11u25's R0, R4
and R5 closed, 147 grid arms and 17 committed boundary cells moving onto
golden, and 0 cells anywhere moving away from it.

## 7. Residues

* **R0 — the fold DECISION, not the encoding.**  `s09_modnet_from_gen`,
  `s10_port_from_gen`, `s21_signed_lhs`, `s14_bitsel_lhs`, `s15_partsel_lhs`:
  golden FOLDS a constant cont-assign Rhs where this emitter keeps the whole
  operation — a module NET or PORT target written from inside a generate scope
  (the gen-scope path never calls `tryFoldConst`), a `logic signed` module
  target, and a bit-select / part-select Lhs (which `caLhsAdjustBind106`
  refuses because it is not a `NamedValue`).  Golden's object is exactly what
  §2 predicts (`INT:5` ct 7 at 32, at the NAMESAKE's 4 bits for `s11`); what is
  missing is the decision to fold at all.  **This is the next head**: it is a
  larger surface than the encoding — it would ADD folds where we currently
  emit operations — and it must be censused on its own before a line is
  written.
* **R1 — the int64 value machine's 64-bit horizon.**  `Ma38`, `Ua38`, `W01`,
  `W06` (`128'd2 + 128'd3`): `caFoldEnc27` answers `INT:` at 128 and
  `genTernInt64Eval22` DECLINES, because `genTernRawBits22` refuses a leaf
  wider than 64 bits.  Golden's value (5) fits an int64 perfectly well; only
  the LEAF READ does not.  Widening the leaf read to a 64-bit VALUE of a
  wider-typed literal would close four arms; it is untouched here because the
  same read is shared with the two landed ternary laws.
* **R2 — `W02`, our over-fold of a >64-bit unsigned-branch add.**  Golden keeps
  the OPERATION for `128'h2 + 128'h3` (§2e) and the pristine binary folds it to
  `UINT:5` at 128.  Closing it means SUPPRESSING an existing fold, which is a
  different kind of change from installing one; measured and left alone.
* **R3 — the unary reductions and `~` on the UNBOUND half.**  `Ua23` (`~32'd0`
  → golden `UINT:4294967295` at 32), `X06`/`X07`/`X08` (`&`/`|`/`^` reductions
  → golden `UINT:<v>` at 64): `caFoldEnc27` answers for `~` and
  `genTernInt64Eval22` does not; neither answers for the reductions.  Four arms.
* **R4 — `u02`/`m02`, a bare `$clog2` Rhs.**  Golden folds the whole
  `sys_func_call` to `UINT:6` (at 64 unbound, at the Lhs width bound); the
  mint fence (§2f) refuses a bare Call deliberately, because a Call at the top
  level is the very shape the `g154` class was found on.  Two arms.
* **R5 — `s08_iface_mod`.**  An INTERFACE BODY's `cont_assign` is absent from
  our ELABORATED view altogether (golden carries it with `INT:5` ct 7 at 32 and
  `vpiActual` absent); a different family, identical on both binaries.
* **R6 — pre-existing over- and under-folds at module scope, untouched.**
  `Ma07` (`32'd6 ^ 32'd3`) and `X01` (`~^`) and `X11` (`+x`) and `Ma24`
  (`{16'd1, 2}`): golden INSTALLS the operation and we fold.  `Ma39`
  (`int'(7)`) and `X23` (`"AB"`): golden folds and we keep the operation.
  `Ma21`/`X05` (`&&`, `||`): golden `UINT:1` at 32, ours `BIN:1` at 1.  All six
  are identical on the two binaries.
* **R7 — `s11_namesake`** (r11u22's R3 verbatim): `bindVariable` binds BY NAME,
  so golden folds a 32-bit gen-local `lv`'s Rhs at the 4-bit MODULE NAMESAKE's
  width and BINDS the Lhs.  Both fences refuse the cell explicitly.

## 8. Instruments

* `mkgrid27.py` / `mkgrid27b.py` — regenerate all 245 arms into `$GRID`
  (default: this directory's `grid/`, which is their committed output).
* `run27.sh` — the two-sided grid runner (golden + a chosen binary, both rcs);
  `GRID.pris.txt` / `GRID.law.txt`.
* `carhs27.py` + `shapes27.sh` — THE SHAPE LISTER and its golden-vs-ours table
  (r11u25's `carhs25.py` unmodified: it reads the dump's own nesting, so a
  `param_assign`'s Rhs is never mistaken for a `cont_assign`'s).
  `SHAPES.{pris,law}.txt`, `SHAPEVERDICT.txt`.
* `pred27.py` / `predrun27.sh` — the census (§5), from PRISTINE databases,
  scored on the 245 grid arms as its positive control.  `PRED.u2r.txt`,
  `PRED.sl.txt`.
* `celldbg27.sh` (surelog suite) / `traceu2r27.sh` (uhdm2rtlil) — the cell
  traces of §5, run in each row's own source directory with the sweep's exact
  command line.  `CELLDBG.earlgrey.txt`.
* `bnd27.sh` / `bndattr27.sh` / `bndscore27.sh` — the 2976-file boundary, its
  golden-side attributor and the multiset-aware cell-by-cell direction scorer.
* `coin27.sh` — the SECOND conviction of a UVM-coin byte mover: the PRISTINE
  binary run again against its own first run.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the r10uvm221 battery, copied byte-for-byte unmodified.
* `R11U27_OFF=1` restores the pristine behaviour in the SHIPPED binary — the
  switch is in the ENTRY GUARD of all three laws, so the OFF binary consults no
  fence and installs nothing.  It is INDEPENDENT of `R11U22_OFF`,
  `R11U23_OFF` and `R11U25_OFF`.  `R11U27_CELLDBG=1` is the two cell traces.
