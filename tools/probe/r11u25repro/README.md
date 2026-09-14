# r11u25 — the NON-TERNARY faces of the cont-assign clone, and why the corpus never sees them

Base commit `822420d0`, worktree `/tmp/wt_r11u25`.  Pristine binary md5
`66dc9cdb3437a4d220daef493a145fdd` — the OPS-stated main-tree md5 at the base,
reproduced byte for byte by my own build from source.  Law binary md5
`58e64809ae74496d897279f045173b01`.  The judge is the official `uhdm-cmp`
through `scripts/verify_golden.py`; everything in this directory is
measurement-only.  **`results/*.csv` ARE NOT EDITED BY THIS PASS.**

## HEADLINE — SAY IT LOUDLY: **ZERO CORPUS ROWS CONVERT, AND ZERO MOVE**

The census came FIRST and it is what decides this pass.  Both faces were
counted on PRISTINE databases over both corpora and both modes BEFORE a line of
the law was written, and then every flagged database was re-run under the law
binary:

| corpus | databases scanned | flagged | of those, byte-identical under the law |
|---|---|---|---|
| uhdm2rtlil | 1608 | 18 | **18 / 18** |
| Surelog suite | 960 | 5 | **5 / 5** |

**uhdm2rtlil stays 768 CMP_EQUAL / 36 CMP_NOTEQUAL / 67 SLANG_REJECT in BOTH
MODES and the Surelog suite stays 469/14 default and 465/12 testflags.**
`byteverify` measures **0 movers of 1608** u2r databases and **4 of 960**
surelog databases, all four the proven UVM coin (§6).  `Earlgrey_0_1` is
**byte-identical on the two binaries in both modes** — `8bdf25272e08` /
`59d0ee6d10c3` — and §5 shows cell by cell WHY, from the law's own trace, not
from the absence of a delta.

What the pass buys is **23 grid arms converting on legal SV, 25 at the cell
level, 0 REGRESS**, and two of r11u23's standing residues closed.  A pass that
moves the scoreboard by zero is worth landing only because every cell it could
have moved was named a priori and measured; the whole of §4 is that argument.

## 1. THE FACES, RE-MEASURED ON MY OWN PRISTINE BUILD

r11u23's R1 named five witnesses (`g01`, `g02`, `f01`, `f07`, `f08`).  All five
reproduce on my own build against the real v1.87 golden
(`surelog -parse -nobuiltin -nocache -sv dut.sv`), and the grid separates them
into **three faces, only two of which this pass lands**.

### FACE 1 — the FILL SIZE (`caUnbasedRhsUnboundKeepsRaw25`)

`assign <lhs> = '0;` with no ternary anywhere.  Golden against pristine:

| arm | Lhs | golden | ours (pristine) |
|---|---|---|---|
| `p01` | own-scope gen-local `logic [31:0]` | `BIN:0` `'0` ct 3 size **-1** | the same at **32** |
| `p02` | the same, `'1` | `BIN:1` `'1` ct 3 size **-1** | **`UINT:4294967295` ct 9** at 32 |
| `p03` | the same, `'x` | `BIN:X` `'X` ct 3 size -1 | IDENTICAL |
| `p04` | the same, `'z` | `BIN:Z` `'Z` ct 3 size -1 | IDENTICAL |
| `p05` | own-scope gen-local NET | -1 | 32 |
| `p06` | an ANCESTOR gen scope's local | -1 (and `vpiActual` PRESENT) | 32 (and absent) |
| `p16` | an INTERFACE's gen scope | -1 | 32 |
| `p18` | a bare `var bv;` | -1 | 1 |
| `p24` | an `int` gen-local | -1 | 32 |
| `p25`/`p26`/`p27`/`p28` | `'1` at 64 / 8 / 1 / 128 bits | `BIN:1` `'1` ct 3 **-1** in all four | 64 / 8 / 1 / 128 |
| `p19`/`p20`/`p21`/`p22`/`p23`/`p30` | gen-for / nested ×3 / gen-case / unnamed `genblk` / a CHILD instance's gen scope / `assign #1` | -1 | 32 |

**THE WIDTH NEVER ENTERS.**  `p25`-`p28` are the proof: golden's object is the
same `BIN:1` at -1 whether the target is 1, 8, 64 or 128 bits.  That is
`CompileHelper::adjustSize` being a NO-OP, not a re-size.

And the shapes golden DOES size, which this emitter already matches:

| arm | Lhs | golden | ours |
|---|---|---|---|
| `p07` | a MODULE NET reached from a gen scope | `BIN:0` size 32 | SAME |
| `p08` | a MODULE VAR reached from a gen scope | `BIN:0` size 32 | SAME |
| `p09` | a module PORT reached from a gen scope | `BIN:0` size 32 | SAME |
| `p10` | a gen-local with a 4-bit MODULE NAMESAKE | `BIN:0` size **4**, Lhs BOUND | size 32, Lhs unbound — **DECLINED** |
| `m01`-`m06`, `m13` | MODULE SCOPE, `'0`/`'1`/`'x`/`'z`, var / net / port / 8-bit | sized at the width | CMP_EQUAL on pristine |
| `p11`-`p15` | a bit-select / concat / member / part-select / unpacked element Lhs | -1 | -1 already |

**MODULE SCOPE IS NOT THIS LAW** and the brief's open question is answered by
measurement: the clone fires there too, but `bindVariable` FINDS a module-body
target, so `tps` is non-null, `adjustSize` runs, and golden sizes exactly as we
do.  `m01`-`m06` and `m13` are CMP_EQUAL on the PRISTINE binary.  A NON-`ref_obj`
Lhs (`p11`-`p15`) is not this law either — golden and pristine are both already
at -1 there, which is r11u23's R3 answered in the negative.

### FACE 2 — the DROPPED BINDING on a non-ternary Rhs (`caUnsizedRhsOwnLocalNoBind25`)

`DetectUnsizedConstant` clones the assign whenever ANY constant in the Rhs tree
has `VpiSize() == -1`, and a cloned Lhs ref is not in `mod->getLateBinding()`.
r11u23 gated that fact to a TERNARY Rhs as a corpus-exposure fence; it is not a
producer fence.  Own-scope gen-local `logic [31:0] lv`, one arm per row — and in
every one **the Rhs OBJECT is byte-identical on the two sides**, so the binding
is the only face:

| arm | Rhs | golden | ours (pristine) |
|---|---|---|---|
| `q01` | `a \| '0` | `vpiActual` ABSENT | `logic_var` |
| `q02` | `{a, '0}` | ABSENT | `logic_var` |
| `q03` | `a ^ 'x` | ABSENT | `logic_var` |
| `q04` | `'{default: '0}` | ABSENT | `logic_var` |
| `q05` | `a + '1` | ABSENT | `logic_var` |
| `q08` | `{28'd0, a[3:0] \| '0}` | ABSENT | `logic_var` |
| `q09` | `{'0, a}` | ABSENT | `logic_var` |
| `q16` | `(a & b) \| (a ^ '0)` | ABSENT | `logic_var` |

THE CONTROLS, every one measured on golden BEFORE the law was written and every
one ALREADY EQUAL on pristine:

| arm | shape | golden | why it is the control |
|---|---|---|---|
| `q13` | `a \| 32'd0` | **BINDS** | convicts the DETECTOR, not the operation |
| `q14` | a whole ref | BINDS | |
| `q15` | `$signed(a) * $signed(b)` | BINDS | |
| `q10` | a gen-local NET target | no actual either side | a Net is refused by the fence anyway |
| `q11` | an ANCESTOR gen scope's local | **BINDS** | the clone copies an already-resolved pointer — OWN-SCOPE ONLY |
| `q12` | a MODULE NET reached from the gen scope | **BINDS** | |
| `q17` | a gen-local with a MODULE-BODY NAMESAKE | **BINDS** | r11v23's namesake clause declines it |
| `q18` | a BIT-SELECT target | (no actual) | not a `NamedValue` |
| `q19` | `(a > b) ? a : (b \| '0)` | ABSENT | a ternary Rhs — § genCaUnboundTernLhsNoActual23 already owns it, EQUAL on both binaries |

### FACE 3 — the non-ternary FOLD.  MEASURED, DECODED ONLY AS FAR AS THE TABLE, **DECLINED** (R0)

`reduceExpr` also folds a non-ternary Rhs, and golden's installed object is NOT
one shape.  Own-scope gen-local `logic [31:0] lv`, golden against pristine:

| arm | Rhs | golden | ours (pristine) |
|---|---|---|---|
| `r01` | `32'd2 + 32'd3` | `INT:5` ct 7 size **32** | the operation |
| `r02` | `$clog2(33)` | `UINT:6` ct 9 size **64** | the `sys_func_call` |
| `r03` | `K + 1` | `UINT:10` ct 9 size 64 | the operation |
| `r04` | `{16'd1, 16'd2}` | `BIN:<32 bits>` ct 3 size 32 | the operation |
| `r05` | `2 + 3` | `UINT:5` ct 9 size 64 | the operation |
| `r06` | `-(32'd1)` | `INT:-1` ct 7 size 32 | the operation |
| `r09` | `$bits(a)` | `UINT:32` ct 9 size 64 | IDENTICAL (already folded) |
| `r10` | `32'd1 << 3` | `UINT:8` ct 9 size 64 | the operation |
| `r07` | `32'd5` | the literal, ct 1 | IDENTICAL |
| `r08` | `K` | `UINT:9` ct 32 | IDENTICAL |
| `r11` | the same add at MODULE scope | `INT:5` ct 7 size 32 | `UINT:5` ct **9** |
| `r12` | the same add, gen-local NET | `INT:5` ct 7 size 32 | the operation |
| `r13` | the same add, ANCESTOR gen-local | `INT:5` ct 7 size 32 | the operation |

`INT:` at 32 for a SIZED-literal arithmetic, `UINT:` at 64 for everything
`reduceExpr` mints itself, `BIN:` at 32 for a concat — three different encodings
chosen by which of Surelog's two folders got there first (the compile-time fold
before the write, versus `reduceExpr` at write time).  `r11` shows the
*bound* half has the same encoding face (`INT` vs `UINT`) independently.  This
is a pass of its own; it is **R0** and nothing here touches it.

## 2. DECODE — one producer arm, and the fence is `bindVariable`'s own question

`UhdmWriter::writeCont_assign` (Surelog v1.87 `UhdmWriter.cpp:2090`):

```cpp
if (lhs->UhdmType() == uhdmref_obj) {
  any* var = bindVariable(mod, m, lhs->VpiName(), …);   // CompileStmt.cpp:3094
  if (var) { … tps = the bound var's typespec …
             ref->Actual_group(var);          // :2165 — INSIDE `if (var)`
             cloned = true; } }
…
if (simplified == false) {                    // :2243
  any* res = reduceExpr((expr*)rhs, …);
  if (res && res->UhdmType() == uhdmconstant) {
    if (cloned == false) { assign = clone_tree(assign); cloned = true;
                           res = adjustSize(tps, …, (constant*)res, true); }
    assign->Rhs((constant*)res); } }
if (simplified == false && cloned == false) { // :2283
  DetectUnsizedConstant detector;  …listenAny over the WHOLE Rhs…
  if (detector.unsizedDetected())             // ANY VpiSize == -1
    { assign = clone_tree(assign); cloned = true; } }
```

`bindVariable` switches on `uhdmfunction` / `uhdmtask` / `uhdmbegin` /
`uhdmmodule_inst` and tail-recurses on `scope->VpiParent()` for everything else,
so from a `gen_scope` it searches the enclosing module_inst's `Nets()` and
`Variables()` BY NAME and never sees a gen-LOCAL declaration.  Two consequences,
and they are the two laws:

* **`tps` is NULL for a target it cannot find**, and
  `CompileHelper::adjustSize` returns `c` UNTOUCHED on `ts == nullptr`
  (`CompileHelper.cpp:4218`).  So the fill keeps `VpiSize` -1 and its raw
  `BIN:1` encoding.  § genCaUnbasedSizing (`ModuleEmit.cpp` ~19537,
  r10rggen7's law) transcribed the *bound* outcome with NO bind fence at all —
  it sized EVERY gen-scope unbased-unsized Rhs.  This pass adds the fence and
  nothing else: `caLhsBindVariableFinds25`.
* **The clone drops the late binding** regardless of the Rhs's shape.
  `caUnsizedRhsOwnLocalNoBind25` is r11u23's own
  `genTernHasUnsized23` + `caLhsUnboundOwnLocal23` with the `ConditionalOp`
  gate INVERTED, so the two laws are disjoint by construction and r11u23's
  witnesses cannot move.

`caLhsBindVariableFinds25` returns TRUE — "the producer WOULD find this target,
so the adjust happens and the sizing stands" — for anything that is not a
`NamedValue`, for a symbol whose parent scope is not a generate scope, and for a
generate-local whose NAME is also declared in an enclosing module body or in an
ANCESTOR INSTANCE's body.  That namesake walk is
§ genCaCastRhsOwnLocalLhsNoBind118's, whose r10earl118 verifier widened it to
climb into the parent instance (a walk that stopped at this module's own body
scored AWAY 4); it is reused, not re-invented.

**WHAT IS REUSED VERBATIM**: `caLhsUnboundOwnLocal23` (with r11v23's
any-namesake amendment) and `genTernHasUnsized23`, both called unchanged.  The
ternary halves § genCaUnboundTernFold23 / § genCaUnboundTernLhsNoActual23 /
§ genCaTernaryFoldGenScope22 and § caTernFillArmKeepsEncoding19 are not touched
— `caUnsizedNoBind25` is computed only when `genTernUnsizedNoBind23` is false
AND the Rhs is not a `ConditionalOp`.

## 3. THE GOLDEN GRID — 76 arms, every rc recorded

`grid/` carries one `dut.sv` per arm (`mkgrid25.py` regenerates them);
`run25.sh <binary> <tag>` builds the GOLDEN and ours and records BOTH return
codes plus the head count and the cmp line count.  `goldenonly25.sh` is the
golden-side-only runner.  `GRID.pris.txt` / `GRID.law.txt` are the two runs,
`VERDICTS.r11u25.txt` the scored verdict, `carhs25.py` THE SHAPE LISTER (one
line per ELABORATED `cont_assign`: the Lhs kind / name / line:col, its
`vpiActual`, and the Rhs object with size / value / decompile / constType /
opType), `SHAPES.txt` its golden/pristine/law output for all 76 arms and
`SHAPEVERDICT.txt` the per-cell scoring.

**Every arm is `golden_rc=0` AND `ours_rc=0` on BOTH binaries** (`GOLD.rc.txt`,
`GRID.{pris,law}.txt`).

**By `uhdm-cmp` rc: 23 CONVERT, 1 IMPROVE, 52 UNCHANGED, 0 REGRESS.**

**AN ARM AGREEING AT rc 0 IS NOT AN ARM TESTING THE LAW**, so every verdict is
also read off the per-cell CA-shape census: **25 arms CONVERT at the cell
level, 0 REGRESS, 2 MOVED-STILL-DIFF** — and both of those move TOWARD golden:

* `p06` (an ancestor gen-local, bare `'0`): size 32 -> **-1**, golden's exact
  object.  Its remaining cell difference is the ancestor `vpiActual` golden
  keeps and pristine already dropped — r11u23's R2, untouched here.
* `q07` (`~'0`): `vpiActual` `logic_var` -> **absent**, which is golden (golden
  clones).  Its remaining difference is that golden FOLDS `~'0` to
  `UINT:18446744073709551615` at -1 and we keep the operation — face 3.

The two cell-converts that are not rc-converts are `p18` (a bare `var bv;`) and
`p30` (`assign #1`): their CA cells land on golden's exact object and their
remaining heads are on other families' faces.

The arm families: the Lhs home (module var / module net / port / own-scope
gen-local var / gen-local NET / ancestor gen-local / module-body NAMESAKE /
interface body / interface gen scope / bit-select / concat / member /
part-select / unpacked element / bare `var`); the fill kind (`'0 '1 'x 'z`) ×
the target width (1 / 8 / 32 / 64 / 128); the scopes (gen-if, gen-for,
gen-case, nested ×3, unnamed `genblk`, a CHILD instance, a delayed assign, two
cells in one block where only one is a fill); the unsized-in-an-expression face
across nine Rhs shapes with eight controls; and 13 fold arms.

## 4. THE CENSUS — THE WHOLE POINT OF THIS PASS

`pred25.py` reads **PRISTINE databases only**; a database with no flagged cell
cannot move.  Two separable counts, both deliberate SUPERSETS:

* **F1F / F1O** — an ELABORATED `gen_scope` `cont_assign` whose Rhs is a
  `constant` at `VpiSize != -1` that looks like this emitter's mint of an
  unsized fill: `F1F` the decompile `'0`/`'1`/`'X`/`'Z`, `F1O` a value that is
  ALL ONES for its size (our `'1` mint loses the quoted decompile).  It cannot
  see whether `bindVariable` finds the target, so it over-flags every
  module-level and namesake Lhs.
* **F2** — an ELABORATED `gen_scope` `cont_assign` whose Lhs is a whole
  `ref_obj` ALREADY CARRYING a `vpiActual` (only such a cell can LOSE one) and
  whose Rhs subtree holds any constant at `VpiSize:-1`.  It cannot see the
  own-scope fence nor the namesake fence.

**POSITIVE CONTROL** — scored on the 76 grid arms from their own PRISTINE
dumps: it fires on **every one of the 25 arms that really move, 0 misses**, and
is SILENT on 49 of the 76 (`p03`/`p04`, every `m` arm, `p11`-`p15`, `p17`,
`q13`-`q15`, `q18`-`q20`, every `r` arm); the 5 it flags without a move
(`p07`/`p08`/`p09`/`p10`, `q17` and the ancestor/module-net controls) are the
by-design over-approximation.  A scan that could not see would have been silent
on the movers too.

### uhdm2rtlil — `SCANNED=1608 FLAGGED=18` (`PRED.u2r.txt`)

**`F2 = 0` across the WHOLE CORPUS, both modes.**  The dropped-binding face has
no uhdm2rtlil exposure at all.

`F1F`: `ibex_alu` 12, `ibex_icache` 6, `ibex_wb_stage` 2, per mode.  `F1O`: one
cell each in six more.  Every one of the 18 database-modes was re-run under the
LAW binary and measured **byte-identical** — the nine test names, both modes,
in §6.  `ibex_alu`'s twelve are `ibex_alu.sv:1297-1309`'s
`assign bitcnt_result = '0;` … `assign multicycle_result = '0;` inside
`g_no_alu_rvb`: the targets are MODULE-BODY signals, `bindVariable` finds them,
golden sizes them and so do we — the cell lister shows all 99 of `ibex_alu`'s
elaborated CA cells IDENTICAL to golden on the pristine binary already.

### Surelog suite — `SCANNED=960 FLAGGED=5` (`PRED.sl.txt`)

| database | F1F | F1O | F2 |
|---|---|---|---|
| `Earlgrey_0_1` default | 17 | 89 | **106** |
| `Earlgrey_0_1` testflags | 25 | 89 | 14 |
| `Rggen` default | 259 | 53 | 0 |
| `Scr1SvTests` default / testflags | 0 | 0 | 2 |

All five re-run under the LAW binary: **byte-identical**, `Earlgrey_0_1`
`8bdf25272e08` / `59d0ee6d10c3`, `Rggen` `d66b516b88c8`, `Scr1SvTests`
`c71d6e17de6f` / `c5bdbceb5ab7`.

## 5. WHY THEY DO NOT MOVE — ATTRIBUTED, NOT ASSUMED

A byte-identical database is not an explanation.  `R11U25_CELLDBG=1` prints one
line for EVERY elaborated gen-scope `cont_assign` whose Rhs carries an unsized
constant — the DECLINED ones included — with the two fences' answers:

    Earlgrey_0_1  289 cells   bvfind=0: 0   ub=1: 0   nobind=1: 0
    Rggen         817 cells   bvfind=0: 0   ub=1: 0   nobind=1: 0

Every single one of those 1106 cells is a target `bindVariable` FINDS.  The
corpus's real `assign x = '0;` lines in generate scopes assign to MODULE-BODY
signals — `rggen_bit_field:218`'s `sw_write_done`, `ibex_alu`'s twelve — which
is the very shape r10rggen7 measured § genCaUnbasedSizing on.  The fence keeps
all of them.

**POSITIVE CONTROL for the trace**: on `p01` and `q01` it prints
`ub=1 bvfind=0 nobind=1`, on `p07` (the module-net twin) `ub=0 bvfind=1
nobind=0`, and on `q13` (`a | 32'd0`, no unsized constant) it prints NOTHING.
The gate can see, and it does not cry wolf.

## 6. THE GATES — `GATES.r11u25.txt` carries the transcript.  All green.

1. **Both binaries built `-j 2`, md5s taken separately**; the pristine one is
   `66dc9cdb3437a4d220daef493a145fdd`, BYTE-IDENTICAL to the OPS-stated
   main-tree md5 at `822420d0`.  Law `58e64809ae74496d897279f045173b01`.
2. **Goldens 23 PASS / 0 FAIL** on BOTH binaries; `SLANG_UHDM=/bin/false`
   gives 0 PASS / 23 FAIL.
3. **u2r both modes**: 768 / 36 / 67, **zero differing rows** against the
   committed baseline and against my own pristine sweeps; byteverify
   **0 movers of 1608**, SELFCHECK 1607/1608.
4. **surelog `--mode both`**: 469/14 default and 465/12 testflags, unchanged.
   Three differing rows against the committed baseline, all three quoted in
   the transcript: two SURELOG_FAIL detail strings that embed the WORKDIR PATH
   (`LowMemLib`, `LowMemPkg` — not judge verdicts), and `Earlgrey_0_1`'s
   testflags DUMP COLUMN reading blank on a uhdm-dump timeout draw, which OPS
   names explicitly; its STATUS stays `CMP_EQUAL` and its database is
   byte-identical.  byteverify **5 of 960**, every one the proven UVM coin,
   convicted TWICE (order-blind 4-line line-number class, and the PRISTINE
   binary run a second time reproducing the same class on all three — one of
   them landing on the law binary's exact hash).
5. **Every `cmds.txt` audited by binary PATH**: 1581 surelog + 1742 u2r,
   **0 naming the main-tree binary** (50 surelog files carry no slang line at
   all — rows the golden side never produced a database for).
6. **Canaries** ok=51 changed=1 (that one row is the `Earlgrey_0_1/testflags`
   dump column of gate 4) against BOTH the committed baseline and my own
   pristine sweep; u2r ok=8 changed=0; ctcan2 PASS on both corpora;
   `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0; `rowheads.sh` byte-for-
   byte identical to the same script over my own pristine workdir, with
   `Earlgrey_0_1` at 0 heads / cmp rc 0 in both modes.
7. **The seven protected databases**, law vs pristine, md5, with the OPS byte
   pins hit exactly: `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` in
   BOTH modes; `InterfaceModPort 59a365f3ce2c`; `BlackParrotComplex`,
   `YosysOldOr` SAME; `Earlgrey_0_1 8bdf25272e08 / 59d0ee6d10c3`.
8. **The 2731-file boundary** with a positive control, every file the same rc
   on both binaries, `PROCESSED == LISTED`, and all 27 COMMITTED movers scored
   against the REAL golden cell by cell: **TO-GOLDEN 26 / AWAY-GOLDEN 0 /
   MOVED-WRONG 0**.  Eleven of them CONVERT to rc 0 — including nine of
   r11u23's own grid arms, the very ones its R1 recorded as standing wrong —
   and `r10vearl104/w5_cross104` goes from 36 differing cell-fields to 0.
9. **`R11U25_OFF=1` reproduces the pristine bytes exactly** on `p01`, `p02`,
   `p16`, `p28`, `q01`, `q04`, `q16` and `p23` — 8 / 8.
10. **The patch applies clean on a FRESH `822420d0`** and rebuilds from that
    fresh worktree to the same law md5.

### THE SCOREBOARD MOVE THIS LANDING IMPLIES — FOR THE INTEGRATION COMMIT

**NONE.**  uhdm2rtlil stays 768 CMP_EQUAL / 36 CMP_NOTEQUAL / 67 SLANG_REJECT
in both modes and the Surelog suite stays 469/14 and 465/12.  `results/*.csv`,
`GOLDEN_EQUIVALENCE.md` §3.3 and `SUPPORT_MATRIX.md`'s baseline table are all
still correct exactly as committed, so this landing implies no document edit
and makes none.  What it buys is on the boundary and the grid: two of r11u23's
residues closed, 25 grid arms and 11 committed arms of earlier passes moving
onto golden, and 0 cells anywhere moving away from it.

## 7. Residues

* **R0 — FACE 3, the non-ternary FOLD.**  §1's 13-arm table is the whole
  measurement: golden installs `INT:` at 32 for a sized-literal arithmetic,
  `UINT:` at 64 for anything `reduceExpr` mints itself, `BIN:` at 32 for a
  concat, and the MODULE-scope (bound) half has its own `INT`-vs-`UINT`
  divergence (`r11`).  `assign x = A + B;` with constant operands is among the
  commonest lines in real RTL, and installing one encoding where golden uses
  three would move cells AWAY.  Untouched; the next pass's target.
* **R1 — `q07` `~'0` and `q20` `{2{'0}}`.**  Golden folds them to constants
  this emitter does not mint: `UINT:18446744073709551615` at **-1**, and
  `BIN:00` at **-2** (a replication of a -1 fill sizes to -2).  The binding
  face still moves `q07` toward golden; neither converts.  Part of R0.
* **R2 — `p06`/`f14`: an ANCESTOR gen-local loses a binding golden keeps.**
  `assign ov = '0;` in `g2` where `ov` is declared in `g1`: golden
  `vpiActual = logic_var`, ours absent.  § genCaLiteralRhsLhsNoBind22's second
  writer (`ModuleEmit.cpp` ~20180, `isLiteralExpr` guarding `bindGenLocal9`) is
  not ancestor-aware where § genCaConstRhsLhsNoBind25 beside it explicitly is.
  This pass moves `p06`'s SIZE onto golden and leaves the binding exactly as
  pristine had it.  r11u23's R2 verbatim, inherited not incurred.
* **R3 — `p10`: `bindVariable` binds BY NAME.**  Golden folds a 32-bit
  gen-local `lv`'s `'0` at the 4-bit MODULE NAMESAKE's width (size **4**) and
  BINDS the Lhs.  Both fences refuse the cell explicitly rather than treat it
  as unbound; wrong at pristine, unchanged here.  r11u22's R3 verbatim.
* **R4 — `m14`: a MODULE-scope `'1` on a 128-bit target.**  Golden
  `BIN:<128 ones>` ct 3 size 128; ours `UINT:0` ct 9 with the decimal
  decompile `340282366920938463463374607431768211455`.  That is the BOUND
  half's `size > 64` branch of § caTernFillArmKeepsEncoding19 missing at the
  plain module-scope mint — a different family (`adjustSize` running, not
  skipped), measured here and left alone.
* **R5 — `m08`/`r11`: a module-scope constant fold's `INT` vs `UINT`.**
  `assign mv = 32'd2 + 32'd3;` at module scope is golden `INT:5` ct 7 and ours
  `UINT:5` ct 9, on an otherwise identical object.  Part of R0's encoding
  question, on the bound side.
* **R6 — `p12`/`p17`: the concat-Lhs and interface-module-scope arms keep a
  head after their CA cells converge.**  Both arms' `cont_assign` cells are
  byte-equal to golden on BOTH binaries; their heads are on other families.

## 8. Instruments

* `mkgrid25.py` — regenerates all 76 arms into `$GRID`; `grid/` is its output,
  committed.
* `goldenonly25.sh` — the golden-side-only runner (no dependency on our build);
  `GOLD.rc.txt` is its record, every arm `golden_rc=0`.
* `run25.sh` — the two-sided grid runner (inherited from r11u23 with only the
  default `GRID` changed); `GRID.{pris,law}.txt` and `VERDICTS.r11u25.txt`.
* `carhs25.py` — THE SHAPE LISTER (r11u23's `carhs23.py` unmodified): one line
  per ELABORATED `cont_assign`, keyed by (Lhs kind, name, line:col), with its
  `vpiActual` and the Rhs object's kind / size / value / decompile / constType /
  opType.  It reads the dump's own nesting, so a `param_assign`'s Rhs is never
  mistaken for a `cont_assign`'s.  It is the arbiter for every cell verdict.
  `SHAPES.txt` / `SHAPEVERDICT.txt` / `shapescore25.sh`.
* `pred25.py` / `predrun25.sh` — the census (§4), computed from PRISTINE
  databases and scored on the 76 grid arms as its positive control.
  `PRED.u2r.txt` / `PRED.sl.txt`.
* `cellcmp25.sh` — golden-vs-ours cell lister for one sweep workdir entry
  (it reads the golden straight out of the cache entry `cmds.txt` names).
* `bnd25.sh` / `bndattr25.sh` — the boundary runner and its golden-scored
  attributor (§6), inherited with only the default paths changed.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the r10uvm221 battery, copied byte-for-byte unmodified.
* `R11U25_OFF=1` restores the pristine behaviour in the SHIPPED binary — the
  switch is in the ENTRY GUARD of both faces, so the OFF binary consults no
  fence and sets no flag.  It is INDEPENDENT of `R11U22_OFF` and `R11U23_OFF`.
  `R11U25_CELLDBG=1` is the cell trace of §5.
