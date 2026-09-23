# r11u104 — the reader's width reaches the fold, and the seven digit flags turn on

**THREE FACES OF ONE HAND-OFF LAND, EACH BEHIND ITS OWN GATES.** r11u100's R0
(the reading width that the digit laws needed), its R2 / r11v100's RV100-2 /
r11v94's RV94-4 / r11u91's R4 (the SIZE face), and r11u100's two held laws
(§ uintArmWrittenDigitsMasked100, § bareUnsizedDecIsMaskedDigits100), whose
seven flags are now ON. The law is § readerWidthIsTheSecondAdjust104.
`ModuleEmit` hands the reading NET's width to the package-parameter fold site
at all three net-declaration homes: the module body, a generate scope and an
interface. The fold site then runs the producer's SECOND `adjustSize`: it
masks a `UINT:` value (LAW A) and writes the reader's width as the size
(LAW C). With that width in hand the seven digit flags go ON (LAW B), and
every cell that convicted them in r11u100 is now golden.

Base `63dfc6fc`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68). Every golden in this directory is a real Surelog
v1.87 run. **All 51 grid arms read `slrc=0 ourrc=0 slerr=0` on both binaries
(102 arm-runs, `evidence/ARMS104.txt`).**

| binary | md5 | what |
|---|---|---|
| pristine | `3c74f9e404ec5a3d56b951c905e15069` | own worktree at `63dfc6fc`; matches the brief's md5 |
| **LAW** | `05698a590b36ef354872669983ba99a8` | this patch. Applied to a FRESH `63dfc6fc` and rebuilt: identical |
| `f1ffd6e4` | `f1ffd6e46e7107ed58108623654e1755` | the patch without the `ubShift104` decline. It ran the full gate set too |
| exploration | `468de9f5e00e80c0f2455813e3b65de9` | the shipped source with its thirteen gates read from an env list (drops only) |

**Surface.** Production code is `src/ModuleEmit.cpp` (the hand-off at three
sites), `src/ExprEmit.cpp` (the fold site: the flags, the coupling and the
second resize) and `src/EmitHelpers.h` (the helpers and the § block). The rest
of the patch is `tools/probe/r11u104repro/`. `UhdmExporter.cpp` (the sister
pass's file), `ParamEmit.cpp` (line-sensitive), `include/` and `results/` are
all ABSENT.

---

## 1. THE CELLS AT `63dfc6fc`, BY NET NAME (question 1)

All re-run on the pristine binary against a fresh golden. The full listing is
in `evidence/CELLS104.txt`. Format: golden → pristine.

**The narrow readers of `p4_fence100`.** These are r11u100's conviction cells.
The third value in each row is the r11u100 reading: the seven flags ON with no
width.

```
w8BLB   wire [7:0]         = p4p::BLB   G UINT:255 sz8          P INT:-1 sz8          flags-no-width UINT:9223372036854775807
wNBLB   wire signed [31:0] = p4p::BLB   G UINT:4294967295 sz32  P INT:-1 sz32         flags-no-width UINT:9223372036854775807
wNUBLB  wire [31:0]        = p4p::BLB   G UINT:4294967295 sz32  P INT:-1 sz32         flags-no-width UINT:9223372036854775807
w8BADD  wire [7:0]         = p4p::BADD  G UINT:1 sz8            P UINT:1 sz8 (right)  flags-no-width UINT:4294967297  (AWAY)
wNBADD  wire signed [31:0] = p4p::BADD  G UINT:1 sz32           P UINT:1 sz32 (right) flags-no-width UINT:4294967297  (AWAY)
w8CPW   wire [7:0]         = p4p::CPW   G INT:8 sz8             P INT:8 sz32          (the SIZE face)
wNBADDU (p2_uintdig100) 32-bit read of longint BADDU  G UINT:1 sz32   P UINT:1   flags-no-width UINT:4294967297 (AWAY)
wNBLBARE (p3_bare100)   32-bit read of longint BLBARE G UINT:4294967295 sz32  P INT:-1
```

**The power / fold SIZE cells** (`x2_minusedge94v`, `p1_powtop100`). In every
cell golden's size is the READER's and ours is the declaration's:

```
wB128  64-bit  reads logic [127:0] B128 = -3        G INT:-3 sz64     P sz128
wBH2   32-bit  reads logic [7:0] BH2 = 8'hF0-8'h01  G INT:239 sz32    P sz8
wBN    32-bit  reads logic [3:0] BN = 20-1          G INT:19 sz32     P sz4
wBCAT / wBNN   32-bit reads 8-bit                   G sz32            P sz8
wCPOW / wUPOW  64-bit reads int CPOW = 2**3         G INT:8 sz64      P sz32     (wNPOW, a 32-bit read, already equal)
wPU8   64-bit  reads logic [7:0] PU8 = 10**3        G INT:1000 sz64   P sz8
wPBY   64-bit  reads byte PBY = 5**3                G INT:125 sz64    P sz8
```

**`k6_width94v`.** Every net-declaration cell (`wR1 wW1 wW2 wWM wWMC`, all
32-bit readers of `INT:` shapes) is already EQUAL, and it stays equal. `wBT`
(`$bits(pk)`) is golden `UINT:4294967288` on both sides; that is a different
road. The select cells `wi ws wr` are not constants.

## 2. THE DECODE — two resize passes, and where our side holds the width (question 2)

**The producer.** A net declaration's initializer is compiled UNREDUCED
(`ElaborationStep::exprFromAssign_`,
`~/git-repos/Surelog/src/DesignCompile/ElaborationStep.cpp:1623-1625`,
`Reduce::No`). `UhdmWriter::writeCont_assign` (`UhdmWriter.cpp:2090-2299`)
takes `tps` = the NET's typespec (`:2099-2102`), reduces the right-hand side
(`:2257-2264`) and hands the constant to `adjustSize(tps, …, uniquify=true)`
(`:2274-2276`). The package parameter's value object has ALREADY been through
`adjustSize` at its own declaration. So `CompileHelper::adjustSize`
(`CompileHelper.cpp:4065-4249`) runs TWICE:

```
size = Bits(net ts)  (vpiDecConst keeps its own; an invalid Bits keeps its own)   :4080-4089
vpiUIntConst    value &= getMask(size), re-rendered unsigned; VpiSize(size)       :4106-4118
vpiBinaryConst  logic ts, orig > size: keep the LOW `size` digits, bare decompile  :4119-4146
every OTHER type (INT, HEX, OCT, …)  VpiSize(size), the VALUE untouched           :4243-4245
and nothing at all when get_value refuses the constant — HEX/OCT/BIN wider than 64
(~/git-repos/UHDM/templates/ExprEval.cpp:1947-2010)
```

A `vpiIntConst` VALUE is never masked. That is why r11u100's `INT:` road (the
power arm) was right at every reader, and why its SIZE was not.

**Our side.** The reading width exists in exactly one place: `ModuleEmit`'s
`dt->getType()` at each net-declaration site. That is where the landed
`implicitConvTargetSigned` hand-off already sits
(`src/ModuleEmit.cpp:32035`). There
are two other sites with the same shape: the generate scope
(`src/ModuleEmit.cpp:22195`) and the
interface cell
(`src/ModuleEmit.cpp:41872`). r11u100
measured that an implicit-conversion hook reads the SOURCE width, so that road
is closed. The hand-off is one variable, `ndaReaderWidth104`
(`src/EmitHelpers.h:10929`). Each site
sets it around its one `emitExpr` call and restores it afterwards. It is
nonzero only for a plain integral vector net or a predefined-integer net
(`ndaReaderWidthFor104`). The fold site reads it only when the constant is the
WHOLE right-hand side: its parent is a `cont_assign` whose
`VpiNetDeclAssign()` is already set, because every site sets that flag before
it emits.

## 3. THE GOLDEN GRID (question 3)

There are 51 arms, all scored per cell, per field and on BOTH keys (question 6).
`score104.py` is the NET-NAME key: every `cont_assign` at any depth, keyed on
the LHS name plus the view (the multiset trap is closed). `loc97v.py` is the
five-field VIEW-KEYED location key.

* **`r1_readw104`**: 22 package declarations × 10 readers = 220 cells. The
  declarations cover the five UINT arms, bare leaves of 2^31 and 2^63, a byte,
  an `int` name hop, the INT mint (`**`, `*`, `-`, a negative), a 128-bit
  declaration, an untyped declaration, and HEX, BIN, OCT and based-DEC
  literals. The readers are widths 1/4/8/16/32/64/65/128, signed and unsigned.
* **`r2_homes104`**: the homes. These are a range-less `wire`, a literal delay
  AND a NAMED delay, an imported bare read, a parenthesized read, a generate
  block, a written `assign` (def and elaborated view), `p::X + 0`, an explicit
  cast, and a module localparam (a different road, kept as a control).
* **`r3_otherhomes104`**: every other home the fold site serves, each read
  narrower than the parameter. These are a module localparam, a parameter
  default, an override, a port connection, a written assign, an operand, a
  select index, procedural code, a function return, a concatenation and an
  interface's net declaration.
* **`r4_edges104`**: unknown leaves (`'x`, `'z`, a name hop to one, `8'b1x0x…`,
  a 4-state `integer`), and the net kinds that must carry NO width: enum,
  packed struct, unpacked array, `int` variable, `logic` variable.
* **Controls:** every committed arm of r11u96, r11u97, r11u100 and r11u102, and
  of r11v94, r11v96, r11v97 and r11v102 (47 arms).

**Measured rule (golden, `r1_readw104`):**

| declared value | reader W | golden |
|---|---|---|
| `UINT:` (any arm / leaf) | any | value `& getMask(W)`, size W. `BLB` reads 255 at 8, 15 at 4, 1 at 1, 65535 at 16, and the full value at 64/65/128 |
| `INT:` (`**` `*` `-`, a negative) | any | value UNCHANGED, size W. `CSUB = -4294967296` at W=1 is `INT:-4294967296 sz1` |
| `HEX:ABC` (12-bit) | any | decompile `12'hABC` unchanged, size W |
| `BIN:10101010` (8-bit) | < 8 | the low W digits, bare decompile, size W (`n4` `BIN:1010 d1010 sz4`, `n1` `BIN:0 sz1`) |
| `BIN:10101010` | ≥ 8 | unchanged, `sz8 d8'b10101010` |
| an unknown LEAF (`'x`, `'z`) | any | unchanged `BIN:X sz32`, even at an 8-bit reader |

**The homes all take the resize (`r2_homes104`):** a range-less wire (W=1),
BOTH delays (the named-delay `cloned` path does not skip it), the imported
read, the parenthesized read, the generate block and the interface.

**THE SCORE, law vs pristine, 51 arms (`evidence/GRID104.score`).**

| key | TO | AWAY | MOVED-WRONG |
|---|---|---|---|
| NAME (`score104.py`) | **833** | **0** | **0** |
| LOC (`loc97v.py`, five fields, per view) | **925** | **0** | **0** |
| **tags swapped** (the positive control) | 0 / 0 | **833 / 925** | **833 / 925** |

Per field (NAME key): `sz` 313 (LAW C), `vd`/`d` 162 each (LAW A + LAW B),
`vp`/`ct` 98 each (LAW B: the `neg91` suppression). The conviction arms are
`p2_uintdig100` TO 77, `p3_bare100` TO 81 and `p4_fence100` TO 47 / 57, all
with AWAY 0 and MOVED-WRONG 0. `r1_readw104` scores TO 361 / 350.

**The r11u100 conviction, reproduced and cleared.** With the seven flags ON
and the width withheld, the grid reads what r11u100 recorded: `p2_uintdig100`
AWAY 2 / MOVED-WRONG 2, `p4_fence100` AWAY 4 / MOVED-WRONG 10, and on the wider
grid `r1_readw104` AWAY 52 / MOVED-WRONG 108. With the width (the shipped law)
every one of those cells is golden. They are quoted per cell in
`evidence/CELLS104.txt` ("THE CONVICTION CELLS").

**Unscoreable moves, listed rather than claimed.** On four cells golden writes
a `ref_obj` and both binaries write a constant. The law moves only the SIZE of
that invented constant: `b2_cmpbrk94` wCCAS, `b3_xhomes94` wCCX,
`b4_pkgcall94` wQDEF and `q1_cmppow102` wCPCEQ go from sz32 to sz64. The shape
mismatch is pre-existing. In `b1_callbrk94`, a call ARGUMENT
`fs(b1p::PB200)` moves from `INT:-56` to `UINT:200`, the producer's digits.
That argument sits inside a net-declaration cell golden does not write at all.

## 4. THE LAWS, EACH GATE DROPPABLE ALONE (question 4)

In `src/ExprEmit.cpp:16219` (the flags) and at the resize
(`src/ExprEmit.cpp:17490`):

```
LAW A  rdMask104   the UINT value face: & getMask(W), decompile re-rendered
LAW C  rdSize104   the size face of every branch (UINT / INT / HEX / OCT / our DEC; BIN only when narrowing, logic decl)
hand-off  rdWidth104 (module body)  rdGen104 (generate scope)  rdIfc104 (interface)  — ModuleEmit
LAW B  add100 and100 or100 shl100 shr100 bare100 bname100 — flipped ON
       udRoad104: at a net declaration's WHOLE right-hand side the digit road runs only when the
       width arrived AND rdMask104 will apply it; otherwise it declines (the cell stays pristine's)
declines  an unknown LEAF initializer (golden keeps BIN:X — r4 wCUX/wCUXN, q3 wCUXB/wCUZB);
          ubShift104: a shift over an unbased-unsized operand (golden never reduces '1 << 1:
          z1 wU1SHL, k4 wA8, k1 wCSHLU — golden ref_obj), so the digit road writes nothing new
```

**Drops (`evidence/DROP104.txt`, the exploration binary on 51 arms).** Every
one of the thirteen gates was dropped alone, and every drop reads AWAY 0 /
MOVED-WRONG 0 on BOTH keys:

| gate OFF alone | NAME TO | LOC TO |
|---|---|---|
| none (shipped) | 833 | 925 |
| add100 / and100 / or100 / shl100 / shr100 | 783 / 809 / 811 / 777 / 821 | 857 / 899 / 893 / 869 / 905 |
| bare100 / bname100 | 519 / 777 | 543 / 865 |
| rdMask104 / rdSize104 | 335 / 516 | 429 / 620 |
| rdWidth104 / rdGen104 / rdIfc104 | 42 / 823 / 819 | 148 / 915 / 911 |
| ubShift104 | 833 (its cells are unscoreable: `f1ffd6e4`) | 925 |
| all seven digit flags (the width faces alone) | 355 | 341 |
| all thirteen | 0; dumps byte-identical to pristine on 51/51 | 0 |

**The seven flags flipped one at a time** (that flag ON with the width, the
other six OFF): add100 TO 405, and100 379, or100 377, shl100 411, shr100 367,
bare100 613, bname100 (rides bare100) 669. Every one has AWAY 0 and
MOVED-WRONG 0. The exploration binary with every gate ON writes dumps
byte-identical to the shipped law on 51/51 arms.

**The wide boundary (`evidence/BOUNDARY104.classes`).** This covers every
`*.sv` under `tools/probe`: 8544 arms, 8284 SAME, 30 DIFFERS and 230 NODB.
Every NODB arm has `prc == lrc` (226 × rc=3, 4 × rc=139). The null boundary
(pristine against itself over the first run's 31 DIFFERS arms) reads 31 SAME,
so none of them is a run-to-run coin. Of the 30 DIFFERS arms:

* **23** are in the scored grid (AWAY 0).
* **4** are size-only arms (`q4_negpkg94 q5_negedge94 q6_negwid94
  v3_negfold91`), scored against a fresh golden: **TO 28, AWAY 0**.
* **3** are the static-address class (`g22 l154_noenum g185_e_kinds`), with
  `|UINT` + `|vpiDecompile` only. The **16 KB-pad positive control** moves the
  same cells by the same 16384 bytes.

## 5. CENSUS AND THE A-PRIORI MOVER SET (question 5)

`census104.py` works from the DATABASES, golden first. It dumped every
pristine row database of both corpora in both modes and read every
`cont_assign` by net name. A cell is in **REACH** when its initializer text is
a NAME and we write a constant there. A cell is a **CANDIDATE** when golden's
size differs from ours, or golden's value differs where ours is `UINT:`.
**Calibration:** golden read against golden gives 0 candidates in both
corpora. **Positive control** (`--pair`): `r1_readw104` 111 SIZE + 14 VALUE,
`p4_fence100` 9 + 7, `x2_minusedge94v` 5.

```
uhdm2rtlil  1608 databases  REACH 208 cells / 96 row-databases  CANDIDATES 10, every one a written-assign @asn
            cell no hand-off reaches -> PREDICTED 0 rows
Surelog      960 databases  REACH 134 cells / 22 row-databases  CANDIDATES 0 -> PREDICTED 0 rows
```

The size face turns out to be corpus-INVISIBLE at this pin. The 342 REACH
cells (NAME-initialized constants; a superset that also counts module
parameters, enum members and written assigns) are all already golden in size
and in `UINT:` value. The only exceptions are the 10 written-assign candidates,
which no hand-off reaches. LAW B's own prediction (`predict104.py`,
r11u100's SHAPE-meets-DIGIT classes, now ON) names 11 Surelog rows and 0
uhdm2rtlil rows. **Only `Earlgrey_0_1` among the 11 has a database at this
pin.** It stays byte-identical at its pins `8bdf25272e08` / `59d0ee6d10c3`.

**ibex_icache, predicted by name and measured.** It STAYS CMP_NOTEQUAL in both
modes with the same single head, and its database is byte-identical
(`9c1ffd34e983` / `4440db2c6af1`). The remaining head is NOT the size face. It
is the folded bit-select index `round_robin_way_q[IC_NUM_WAYS-1]`
(`ibex_icache.sv:519`), where golden carries a `ref_typespec` to the package
parameter's `int_typespec` and we carry none. **No row converts.**

## 6. GATES (`evidence/GATES104.txt`, `evidence/MOVERS104.txt`)

* **Build:** pristine `3c74f9e4` matches the brief. The law is `05698a59`,
  identical from a fresh apply, with 0 new warnings.
* **Goldens:** 23/0 on both binaries, and `/bin/false` gives 0/23.
* **uhdm2rtlil, both modes, both binaries:** `788/16/67`. The 1742-row join
  against `results/golden_uhdm2rtlil.csv` gives DIFF=0, and the testflags gate
  PASSes. All 3484 `cmds.txt` name their own frozen binary.
* **Surelog both modes:** `474/9 + 469/8` on both binaries, with every
  histogram cell equal. The whole-row join differs only on LowMemLib and
  LowMemPkg (the DETAIL holds the sweep's own path) and on Earlgrey_0_1's dump
  column (the timeout draw), and the pristine sweep reads the same rows. **No
  status moved on any row.**
* **byteverify:** uhdm2rtlil MOVERS **0 / 1608**, as predicted. Surelog
  **3 / 960**: MiniAmiq default + testflags and SeqDriver testflags. Each one is
  a single `|UINT:` / `|vpiDecompile:` pair (the uvm_pkg range-bound coin, R7),
  with INT, size, const-type and typespec at 0. Running the pristine binary four
  times on MiniAmiq's own invocation writes four different databases.
* **Canaries:** Surelog `ok=50 changed=2`, where both changes are Earlgrey's
  dump column and pristine reads the same. u2r `ok=8 changed=0`. ctcan2 PASSes
  in both corpora. canaudit reads `audited=29 UNCOVERED=0 FENCE-BREACH=0`.
* **Every protected database** is byte-identical AND at its brief pin in both
  modes: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort
  `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a`/`73a10e8217e5`, YosysOldOr
  `d68e0796d62c`, Earlgrey_0_1 `8bdf25272e08`/`59d0ee6d10c3`.
* **Conversion rows** (official `uhdm-cmp`, golden LHS): 13 measured plus 1
  SKIP-NOFILE (Scoreboard/testflags). Each shows 0 cmp lines / 0 heads.
* **`results/*.csv` UNTOUCHED.** No fenced test was dispatched.

## 7. RESIDUES, RANKED

* **R0 — THE MODULE-PARAMETER ROAD OF THE SAME SECOND RESIZE.** A net
  declaration that reads a MODULE localparam goes through `substNdaParamRefs`
  in `ModuleEmit`, not through this fold site, and golden masks it at the
  reader just the same. `wMLB_mod8` (`localparam longint MLB =
  9223372036854775807` read by 8 bits) is golden `UINT:255`, where both
  binaries write `UINT:9223372036854775807`. `wMLIT_mod8` is golden
  `UINT:44 sz8`, where both write `UINT:300 sz32` (`r2_homes104`). The fix is
  the same `red104ReaderResize104` call on the substituted constant, in the
  same file, with the width already in hand.
* **R1 — the written `assign` home.** `writeCont_assign` resizes a written
  assign's reduced RHS too. Its elaborated view keeps `INT:-1` where golden
  writes `UINT:9223372036854775807` (`r3_otherhomes104` aBLB64@asn#2). The
  def-view cell moved TO golden with the flags, and golden's def-view `aCPW`
  cell is `sz8` (reader) where we write `sz32`.
* **R2 — the based-literal ENCODING at the read.** `logic [8:0] O9 = 9'o777`
  is golden `UINT:511` (masked at the reader) where we write `OCT:777`, and
  `logic [7:0] D8 = 8'd200` is golden `INT:200` where we write `DEC:200`. The
  size moved TO golden on both, and the value and type did not. `p3_bare100`
  `wBBIN`'s decompile is also golden `64'b1010` where we write `4'b1010`.
* **R3 — r11u100's R3 and R4 stand:** `&&` / `||` / `?:` (`wCLAND wCLOR
  wCTERN`), the const-call arm (`wFADDS wFADDU`, whose size is now golden), a
  name hop through a UINT-arm parameter (`wCNADD`: `longint CNADD = BADD` is
  golden `UINT:4294967297`), and an explicit cast (`wCASTB`).
* **R4 — a packed-struct net** (`r4_edges104` `wST_s`) is golden `UINT:44 sz8`.
  It is withheld on purpose: `ndaReaderWidthFor104` hands no width to a
  struct, enum or array net.
* **R5 — the unknown-literal values** (`'x` → golden `BIN:X`, ours `UINT:0`)
  and the based-X leaf (`8'b1x0x0000`, ours a `ref_obj`). The resize declines
  there, and the value faces are r11u102's.
* **R6 — the ref-vs-constant shape cells** that golden leaves unreduced (the
  four NOFOLD size moves in section 3, plus `CXOR`) are pre-existing.

---

## 8. REPRODUCING

```bash
git worktree add /tmp/wtp 63dfc6fc && git worktree add /tmp/wtl 63dfc6fc
(cd /tmp/wtl && git apply -3 /tmp/r11u104.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm      # 3c74f9e4… / 05698a59…
  cp $d/build/slang-uhdm /tmp/$(basename $d).bin; chmod 555 /tmp/$(basename $d).bin
done
# ---- the grid: 51 arms, golden once per arm, SAME-LENGTH tags -------------
G=/tmp/g104 && mkdir -p $G && R=/tmp/wtl/tools/probe
cp $R/r11u104repro/grid/*.sv $R/r11u100repro/grid/*.sv $R/r11u102repro/grid/*.sv \
   $R/r11u97repro/grid/*.sv $R/r11u96repro/grid/*.sv $R/r11v94repro/grid/*.sv \
   $R/r11v96repro/grid/*.sv $R/r11v97repro/grid/*.sv $R/r11v102repro/grid/*.sv $G/
G=$G bash $R/r11u104repro/grid104.sh pris /tmp/wtp.bin pris   # baseline tag
G=$G bash $R/r11u104repro/grid104.sh lawx /tmp/wtl.bin        # TOTAL NAME TO=833 AWAY=0 | LOC TO=925 AWAY=0
python3 $R/r11u104repro/cells104.py $G/p4_fence100.sv $G/p4_fence100.{g,pris,lawx}.dump
# the swap control: score104.py / loc97v.py with the last two dumps reversed -> AWAY 833 / 925
# ---- the drops: replace each `constexpr bool <gate> = true;` by an env read (R104OFF list) ----
# ---- census, a priori, from the PRISTINE sweep workdirs ---------------------
python3 $R/r11u104repro/census104.py --gg <pristine u2r wd>      # 0 candidates (calibration)
python3 $R/r11u104repro/census104.py <pristine u2r wd> <pristine sl wd>
python3 $R/r11u104repro/predict104.py <pristine sl wd>           # the 11 digit-flag rows by name
# ---- sweeps per binary, then byteverify (SELFCHECK=1 r11u91repro/byteverify.sh <law wd> <pris wd>)
# ---- wide boundary: xargs -a <armlist> -P 3 -n 1 bash r11u91repro/bnd72.sh (BND_PRIS/BND_LAW/BND_ROOT/BND_OUT)
```

Evidence: `evidence/{GRID104.score, SWAPCTL104.score, DROP104.txt,
CELLS104.txt, CENSUS104.txt, PREDICT104.txt, ARMS104.txt, GATES104.txt,
MOVERS104.txt, BOUNDARY104.arms, BOUNDARY104.classes, BINARIES104.txt}`.
Drivers: `run104.sh` (arm driver), `grid104.sh`, `nda104.py` (the reader),
`score104.py`, `cells104.py`, `census104.py`, `predict104.py`, and the canary
battery copied from `r10uvm221repro` (`canaries.sh ctcan2.sh canaudit.sh`).

---

## 9. VERIFIER (v11u94): ACCEPT WITH FIX

The adversarial verifier found three shapes where the second resize moved golden-right fields wrong: a name hop
over a based-literal leaf, a direct read of a typed signed binary literal whose top bit is set, and a binary
literal wider than its declaration. The shipped law scored 11 AWAY cells (16 fields) and 131 MOVED-WRONG fields
on 10 new arms. Three gates now close them: `hopLit104v`, `sgnBin104v` and `binWide104v`, in
`src/EmitHelpers.h` beside `red104HopOverBasedLeaf104`, and at the resize call in `src/ExprEmit.cpp`.
The 51-arm grid above is byte-identical with them. The arms, scores, drop matrix and gates are in
`verifier/README.md`.
