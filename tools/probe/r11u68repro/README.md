# r11u68 — § patBailStopsMemberStamp68 + § caSubstMemberStampAllEnc68

**TWO GATED SIZE-HALF LAWS AT THE SAME PRODUCER PAIR.**

**LAW A — `expandPatternAssignment` STOPS STAMPING THE MEMBER WIDTH AT THE
FIRST OPERAND ITS REDUCE OR `get_uvalue` REFUSES, AND EVERY OPERAND AFTER IT
KEEPS `reduceExpr`'S OWN SIZE.**

**LAW B — `adjustOpSize` WRITES THE MEMBER WIDTH ON EVERY OPERAND IT REACHES,
WHATEVER THAT OPERAND'S ENCODING, AND `adjustSize` RE-SIZES FROM THERE — SO A
16-BIT BASED LITERAL ON AN 8-BIT MEMBER IS GOLDEN `vpiSize:8` WITH ITS OWN
DIGITS INTACT.**

Base `ff5541cd` (v1.87 pass 65). Pins per `SUPPORT_MATRIX.md`: slang
`7d61e0ad1`, UHDM v1.87 (`18837c10ed3d`, verified `git log -1` in the pinned
tree), Surelog v1.87 (`0445655ee703`, likewise), uhdm2rtlil v0.68. Every golden
here is a real Surelog v1.87 run; every arm records `slrc` / `ourrc` / `slerr`
(all `0`); three binaries were built in this pass's own worktree and frozen
`chmod 555` before any sweep — the pristine (md5 `82111bbd435be0d05af1580b2222a687`,
byte-identical to the main tree's `build/slang-uhdm` at `ff5541cd`, which is the
hash the brief states), an intermediate, and the one that ships.

**LAW A: 2126 grid cells, 0 DIFF golden-vs-golden; SIZE TO 103, AWAY 0,
MOVED-WRONG 0, and the ENCODING projection is TO 0 / AWAY 0 / MOVED-WRONG 0 —
the control that proves this law moves `VpiSize` and nothing else.**
**LAW B: 198 cont_assign cells, 0 DIFF golden-vs-golden; SIZE TO 29, VAL TO 5,
FULL TO 32, AWAY 0, MOVED-WRONG 0.**
**Corpus movement ZERO in both corpora and both modes, predicted BY NAME before
the sweeps and proved sighted by a positive control.** This is CORRECTNESS
GROUNDWORK: no corpus row is at the head of either defect today.

---

## 1. THE TARGET RESIDUES, RE-MEASURED AT `ff5541cd` (question 1)

### LAW A — r11u66's R0, the 14 `ENC-TO` cells and r11v66's `a1` `ctl`

Re-run on the frozen pristine binary with the size-aware shape lister
(`shape68.py` — `shape.py` plus the `DEC:` value line the r11u66 copy could not
see, which is why a `vpiDecConst` operand printed with an empty value there).
All 23 size cells the bail model owns reproduce:

| arm | cell | golden | pristine |
|---|---|---|---|
| `v9` | `PN` op1 (`b: -4`) | `const/64@7=INT:-4` | `const/8@7=INT:-4` |
| `v9` | `PSW` op1 (`b: -1`) | `const/64@7=INT:-1` | `const/32@7=INT:-1` |
| `x1_optable` | `C` op11…op17 (`ter`,`cst`,`clg`,`nmul`,`negs`,`zsub`,`nzer`, all past the `KU ^ 3` bail) | `const/64` ×7 | `const/32` ×7 |
| `g2_fncall66` | `C` op4…op8 (past the `f_neg(6)` bail) | `const/64` ×5 | `const/32` ×5 |
| `g3_neg66` | `C` op1, op4…op7, op9, op10, op12 | `const/16` / `const/64` ×7 | `const/32` / `const/16` / `const/8` |
| `a1_ovf66` | `C` op5 (`ctl: K - 1`, past the `n8: 0-300` bail) | `const/64@7=INT:199` | `const/32@7=INT:199` |

### LAW B — r11u56's R0, the five standing `e3_base56` cells

`score56.py` through `caread55.py`, ELAB view, at the base (26 cells, 21 SAME,
5 DIFF — the same five r11u56 left):

```
DIFF work@dut.u_n.o8    G 16'b1010010111000011 vpiSize:8  ct 3  O 11000011           vpiSize:8  ct 3
DIFF work@dut.u_n.o9    G 16'd4660            vpiSize:8  ct 1  O 16'd4660           vpiSize:16 ct 1
DIFF work@dut.u_n.o12   G 16'b1010010111000011 vpiSize:8  ct 3  O 11000011           vpiSize:8  ct 3
DIFF work@dut.u_w.o8    G 16'b1010010111000011 vpiSize:8  ct 3  O 16'b1010010111000011 vpiSize:16 ct 3
DIFF work@dut.u_w.o9    G 16'd4660            vpiSize:8  ct 1  O 16'd4660           vpiSize:16 ct 1
```

`o8`/`o9` are the 16-bit `'b` and `'d` literals on the **8-bit** members `nb` /
`nd`, read at an 8-bit (`u_n`) and a 32-bit (`u_w`) Lhs; `o12` is the NAME `B16`
on a 16-bit member.

---

## 2. THE TWO PRODUCERS, DECODED (question 2)

Read independently in the pinned trees.

### `expandPatternAssignment`'s operand walk — LAW A's producer

`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:5407-5441`:

```c++
for (any* op : *operands) {
  expr* cop = (expr*)op;
  expr* vexp = reduceExpr(cop, invalidValue, ...);
  uint64_t v = eval.get_uvalue(invalidValue, vexp);
  int32_t csize = adjustOpSize(tps, cop, opIndex, rhs, ...);
  if (invalidValue) { return result; }
  ...
}
```

`adjustOpSize` (`:5114-5203`) writes `cop->VpiSize(<member bits>)` — the object
IN the operand list, which is the object the elaborated `op75` carries — and
`:5203` returns it. The `if (invalidValue) return result;` sits on the NEXT
line, so the operand that trips the flag IS re-sized and every operand after it
is never reached. Two causes raise the flag; the walk's landed model
(`nestBailK`) covers a third (a member whose value is itself a pattern).

**CAUSE 1 — `get_uvalue` refuses the reduced operand**
(`~/git-repos/UHDM/templates/ExprEval.cpp:2058-2160`). It refuses when the
reduce did not hand back a constant at all, and otherwise when the encoding's
own `NumUtils::parse*` scan finds no valid LEADING digit. The scans are
`strtol`-shaped, so an unknown digit BEHIND a valid one survives. The
`expr->VpiSize() > 64` clauses of the same function are NOT the literal's
declared width — see §6 R2.

**CAUSE 2 — `reduceExpr` leaves an OPERATION.** Its operation switch has no arm
for some operators, and `ExprEval.cpp:4185-4314`'s `vpiCastOp` arm folds only
six target typespec kinds (`int`, `long_int`, `bit`, `short_int`, `integer`,
`enum`) and breaks with `result` unchanged for every other.

### `adjustOpSize` + `adjustSize` — LAW B's producer

`adjustOpSize` (`CompileHelper.cpp:5114-5203`), struct arm:

```c++
int32_t ncsize = Bits(mtps, ...);      // the MEMBER's width
adjustUnsized(any_cast<constant*>(cop), ncsize);
cop->VpiSize(ncsize);
```

No encoding test anywhere: `VpiValue` and `VpiConstType` are untouched, and
`adjustUnsized` is the only value writer (it fires on `'1` alone). `adjustSize`
(`:4065-4246`) then runs from THAT size, and its arms read it:

| the constant | `adjustSize` | result |
|---|---|---|
| `vpiUIntConst` | `:4101-4116` masks to the Lhs width | the Lhs width |
| `vpiDecConst` | `:4093-4096` — `size` is never recomputed | **the member width, at every Lhs** |
| `vpiBinaryConst` + a LOGIC typespec | `:4136-4148` drops the leading digits when `orig_size > size` | min, digits rewritten |
| `vpiBinaryConst` + an INT typespec | `:4215` `VpiSize(min(orig_size, size))` | min, **digits untouched** |
| `vpiHexConst` / `vpiOctConst` / the rest | `:4243` `c->VpiSize(size)` | the Lhs width (the FENCE: unmoved by this law) |

---

## 3. THE GOLDEN GRID (question 3)

Twenty packed-parameter arms and nine cont_assign arms; the six `b*`/`c1` arms
are this pass's, the rest are the committed r11u66 / r11v66 / r11u56 / r11v55
grids re-run unmodified as CONTROLS. Every arm compiles clean on BOTH sides
(`surelog rc=0`, 0 `[ERR`, our binaries `rc=0`).
**CALIBRATION GOLDEN-VS-GOLDEN FIRST: 2132 packed cells and 198 cont_assign
cells, 0 DIFF in all three projections on all 29 arms.**  2126 of the packed
cells are SCORED; the other 6 sit in the two SHAPE-MISMATCH rows of §5.

### The BAIL DETECTOR — how every refusal below was read

Each detector row is ONE packed struct whose operand 0 is the CANDIDATE and
whose operands 1 and 2 are the SAME control `K + 1`, at an 8-bit member. The
control's golden size reads the producer's refusal directly: **8 = the walk
COMPLETED, 64 = it BAILED at the candidate.** `plain: 3` is the NO-BAIL
positive control in every arm, so a reader that calls everything a bail is
caught.

| arm | what it cuts | rows | golden bails |
|---|---|---|---|
| `b1_refuse68` | 28 candidate kinds across the whole table | 28 | 6 |
| `b2_faces68` | the CAST face, the SIGNEDNESS face (where slang's own evaluation and Surelog's reduce can disagree), the UNKNOWN-DIGIT face | 31 | 10 |
| `b3_ops68` | 27 operators + the unknown/width faces | 40 | 10 |
| `b6_cast68` | the cast TARGET table against `ExprEval`'s six typespec kinds | 10 | 4 |

**THE REFUSAL SET, measured (109 detector rows, every one a real v1.87
golden).** BAILS:

```
^  (op30)   ~^ / ^~ (op31)   === (op16)   !== (op17)   ==? (op69)   unary + (op2)
byte'(7)  logic'(1)  reg'(1)  time'(7)  <typedef logic[7:0]>'(7)    (op67)
-K  0-300  2-5  NEGP(= -5)  -8'sd1  KS-1  f_neg(6)                 (INT:<negative>)
1'bx  8'bx0000001  8'bz0000001  8'b?0000001  8'hX  8'oX  8'dX       (no valid leading digit)
96'h123456789ABCDEF012345678                                        (a >64-BIT VALUE)
```

COMPLETES (each one a cell a blanket law would have broken):

```
&  |  ~  &&  ||  !  every reduction operator  ==  !=  <  <=  >=  <<  <<<  >>  >>>
**  ?:  a concatenation  a replication  a $ call  a constant function call
int'  integer'  shortint'  longint'  bit'  <typedef bit[7:0]>'  e_t'  8'( )  32'( )
unsigned'  signed'  $unsigned  $signed
K-K (INT:0)   -0 (INT:0)   K*KS (INT:0)   KU-5 (INT:1)
8'shFF   8'sb11111111   1'sb1   SHF(= 8'shFF through a NAME)     <- slang calls all
                                                                    four NEGATIVE
8'b1x01  8'b1000000x  8'b1x000001     70'h5  65'h1  64'hFFFF…  96'b1  96'o1  65'd1
"ab"   E_A   '1   8'hA5   8'b10100101   8'd42
```

The four `8'shFF` / `1'sb1` rows are the reason LAW A does **not** use
r11v61's `bailElem61` as its negative test: that predicate asks slang whether
the value is signed-negative, and slang says yes for all four where golden
writes `HEX:FF` / `BIN:1` and completes the walk. This law reads the refusal off
OUR OWN EMITTED OPERAND instead — the same object the producer reads — and
across all 109 rows our `vpiConstType` and `vpiValue` are byte-identical to
golden's on every row the predicate answers.

### THE POST-BAIL SIZE TABLE — `reduceExpr`'s own answer

`b4_postsz68` and `b5_redsz68` put a guaranteed bail (`-1`) at operand 0 and
read the producer's size for 54 operand kinds against an 8-bit member that no
reduce answer collides with. `b4` also carries a `NOBAIL` twin of the same
struct, which found the model's own control: **golden's twin bails at `negk:
-K` (operand 6) and its operands 7 onward carry their own sizes in BOTH rows —
one model, two readings, no exception.**

```
3                    64      4'd3 / 1'b1 / 96'h1 / 8'd42 / 16'hBEEF  their own width
K + 1 (32,64)        64      "abc"                                   24 = 8 x chars
K + KU (32,32)       32      PB byte 8   PS shortint 16  PL longint 64
P8 + P8 (8,8)         8      PU untyped 32   PBIT bit[3:0] 4   P96 96   E_A 8
-PU                  32      - / * / / / % / ** / & / | / >> / >>>    64
-P8                   8      ?: / a cast / a $ call / a call          64
```

### LAW B's grid — `c1_stamp68`

Every base letter (`h`/`b`/`o`/`d` and the `'s` forms) × a 4- and a 16-bit
literal × an 8-, 16- and 24-bit member × an 8- and a 32-bit Lhs, plus NAME-hop
twins: 39 members × 2 instances = **78 cells** (40 SAME / 38 DIFF at the base).
Golden, read out of the elaborated `cont_assign` Rhs:

| encoding | golden's `vpiSize` | golden's value |
|---|---|---|
| `vpiDecConst` (`4'd9`, `16'd4660`, `16'sd4660`, a NAME reading one) | **the MEMBER width** — 8 / 16 / 24, at BOTH Lhs widths | untouched |
| `vpiBinaryConst`, a DIRECT unsigned literal | min(member, Lhs) | the bare digits when member > Lhs |
| `vpiBinaryConst`, SIGNED or through a NAME | min(member, Lhs) | **untouched, prefix and all** |
| `vpiHexConst` / `vpiOctConst` | the Lhs width | untouched |

---

## 4. THE TWO LAWS (question 4)

### LAW A — § patBailStopsMemberStamp68 ([src/ParamEmit.cpp](../../../src/ParamEmit.cpp))

Three functions beside `patNoFoldTarget`, and one pass over the finished
operand list just before `op2->Operands(opnds)`:

* **`patUvalueRefuses68(const UHDM::any*)`** — `ExprEval::get_uvalue`'s digit
  scan transcribed per encoding, read off the operand WE emitted. A non-constant
  refuses; `INT:`/`DEC:`/`UINT:` refuse a leading non-digit (which is how a
  minus sign refuses); `BIN:`/`HEX:`/`OCT:` refuse a leading unknown after the
  `'`/`s`/base `ltrim`; `STRING:` refuses past 64 characters; `REAL` always.
* **`patAstRefuses68(const Expression&)`** — the measured unfolded-operator set:
  `BinaryXor`, `BinaryXnor`, `CaseEquality`, `CaseInequality`,
  `WildcardEquality`, `WildcardInequality`, and unary `Plus`.
* **`patRedSz68(const Expression&, int)`** — the post-bail size table above.
  **0 = ABSTAIN**, which leaves today's member stamp standing: a STILL cell,
  never an AWAY one.

The pass keeps a running bail index; the operand that trips it is left with its
member stamp (the producer's `adjustOpSize` ran first), and each operand after
it takes `patRedSz68`'s answer.

**THE ABSTENTIONS, every one of them a deliberate STILL:**

* an operand kind `patRedSz68` does not answer — `'1`, a concatenation, a
  replication, a comparison: their VALUE is re-encoded at the member width by
  the branches that mint them, so moving the size alone would leave a bit string
  whose length contradicts it;
* `<<` and `<<<`, because the producer's arithmetic runs at 64 bits where
  slang's is self-determined (`KU << 40` is golden `UINT:6597069766656` and ours
  a masked `0` — r11v66's R-V1);
* **the VALUE GUARD** on the `UINT`/`INT` arms: the digits we WROTE must equal
  the setter's own evaluation, with pass 55's F2 rule for the unary minus. This
  is what keeps `~KU` (ours `UINT:249`, golden `UINT:4294967289`) out;
* a `default:`-SOURCED operand, which is a different producer —
  `'{default: -1}` over `int a; logic [7:0] b;` is golden `INT:-1` at **32**
  where the reduce table would answer 64 (`e5_deffill56` `P5`, and it is the
  cell the WIDE BOUNDARY convicted before the fence went in);
* `ifaceArrayDefFold`, for § patOperandEncReduceTable66's reason unchanged:
  where golden keeps the `tagged_pattern` TREE the producer never ran this walk.

### LAW B — § caSubstMemberStampAllEnc68 ([src/ModuleEmit.cpp](../../../src/ModuleEmit.cpp))

The pass-54/55 mint's member restamp loses its `vpiUIntConst` gate:

```c++
-  if (mw55 > 0 && c55->VpiConstType() == vpiUIntConst)
+  if (mw55 > 0 && (c55->VpiConstType() == vpiUIntConst ||
+                   !caIntTsBinOrigin68(*structParamSetter, 0)))
       c55->VpiSize(mw55);
```

**THE ONE DECLINE** is the binary setter whose constant golden re-sizes through
`adjustSize`'s `int_typespec` arm — a SIGNED based binary, and any based binary
reached through a NAME. That arm keeps the digits where W3 transcribes the
`logic_typespec` arm, which drops them. Without the decline the law rewrote
`4'sb1011` to a bare `1011` and `B16` on a 24-bit member to its unprefixed
digits: a value moved inside a law that claims only `VpiSize`. Both were caught
as MOVED-WRONG cells by `c1_stamp68` before they could ship.

No line of behaviour is removed; the diff adds to `src/ParamEmit.cpp`,
`src/ModuleEmit.cpp` and `include/UhdmExporter.h` and deletes the one gate above.

---

## 5. THE SCORE (question 4), AND THE CONTROLS

`cmp68.py` scores every packed cell in THREE projections — FULL, **SIZE** (the
half LAW A owns) and ENC (the landed encoding laws' half, riding as a control).
`ca68.py` does the same for the cont_assign cells (SIZE / VAL / FULL).

```
LAW A   2126 cells   SIZE TO 103  AWAY 0  MOVED-WRONG 0  STILL 73  SAME 1950
                     ENC  TO   0  AWAY 0  MOVED-WRONG 0  STILL 69  SAME 2057
                     FULL TO 103  AWAY 0  MOVED-WRONG 0  STILL 97  SAME 1926
LAW B    198 cells   SIZE TO  29  AWAY 0  MOVED-WRONG 0
                     VAL  TO   5  AWAY 0  MOVED-WRONG 0
                     FULL TO  32  AWAY 0  MOVED-WRONG 0
```

**`ENC TO 0 / AWAY 0 / MOVED-WRONG 0` is the load-bearing control**: across
2126 cells LAW A moved not one `vpiConstType` and not one value. The landed
grids it shares ground with re-run byte-identical except their named cells —
`g4_base66`, `g5_width66`, `g7_add66` and `a6_misc66` are **SAME in all three
projections on every cell**, `e1_enc56`/`e2_width56`/`e4_share56`/`vv3_default`/
`vv4_singleread`/`vv6_edge` are unmoved at the cont_assign Rhs, and
`vv4_singleread`'s whole database is **byte-identical** between the two
binaries. `vv4_singleread` and `vv6_edge` stay CONVERTED (`uhdm-cmp` rc 0,
heads 0, 0 cmp lines).

Of the 23 base cells of §1, **18 CONVERT** and 5 stay STILL — `g2_fncall66`'s,
where the bail is a constant FUNCTION CALL whose reduce the shared encoding
table does not answer (r11u66's R1; when that arm lands, this bail follows it
for free). `e3_base56` converts **4 of its 5** standing cells, the fifth being
the `int_typespec` digit residue the decline names.

### THE WIDE BOUNDARY

The nine cont_assign arms carry packed-parameter `op75` rows of their own, and
scoring THOSE with `cmp68.py` is what convicted the `default:`-fill cell before
it shipped. On the shipped binary: `e4_share56` SIZE TO 2, `vv3_default` SIZE
TO 1, every other arm SIZE TO 0, and **AWAY 0 / MOVED-WRONG 0 on all nine in
all three projections** (`e5_deffill56` now reads STILL 3 where the pre-fence
binary read MOVED-WRONG 1). Symmetrically, the twenty packed arms' cont_assign
Rhs cells are unmoved by LAW B except `c1_stamp68`'s and `e3_base56`'s.

### THE ALIGNMENT TRAP, and what it nearly cost

The first cut of the scorer joined operand lists BY INDEX and reported two
MOVED-WRONG cells on `e1_enc56`. They were phantoms: our walk emits NO operand
at all for an `'x`/`'z` setter (a pre-existing shape residue, §6 R4), so
golden's 20-operand list and our 19-operand list were being compared one slot
apart from index 10 on. Hand-aligned, those two cells are `INT:-5` 32→**16** and
`UINT:200` 8→**64**, both exactly golden — two more TO cells, not two
regressions. `cmp68.py` now refuses to score a length-mismatched row and prints
all three lists as SHAPE-MISMATCH evidence instead; **seven rows across four
arms** carry the residue — `b3_ops68` 2 (`xunsz`/`zunsz`), `e2_width56` 3,
`e1_enc56` 1 and `e5_deffill56` 1.

---

## 6. CENSUS, PREDICTION AND GATES (questions 5 and 6)

### The a-priori mover prediction, and its positive control

`census68.py` reads SOURCES only and is a SUPERSET by construction: it never
asks whether the pattern's parameter is struct-typed, whether the elaborated
copy flat-folds at all, whether any member width differs from the literal's, or
whether the setter survives the admission fences. `--selftest` scores 30
classification cases (every measured bail class must read as a refusal and every
measured NON-bail must not) and then requires every grid arm this pass measured
to be FOUND (the borrowed r11u66 / r11v66 arms only when `GRID=` points at a
directory holding them) — **SELFTEST PASS (0 bad)**, so the scanner is sighted.

Over both pinned corpora, **20009 parameter-pattern setter texts**: 19973
complete the walk, 31 are INT-arm candidates whose sign a source scan cannot
settle (`NEG?`) and 5 carry an unknown leading digit (`XLEAD`).

* **LAW A — 5 candidate tests**: `Earlgrey_Verilator_01_05_21`,
  `Earlgrey_nexysvideo`, `IncompTitan`, `Kmac` (all four through the same
  `1088/MsgWidth` and `InfoTypeSize[0] - 1` setters, which are INT-arm
  expressions whose values are POSITIVE and therefore complete the walk) and
  `rp32` (a `1'bx` setter — but it is the LAST element of its pattern, and only
  operands AFTER a refusal can move).
* **LAW B — 53 candidate tests** with a based-literal setter.

**PREDICTED MOVERS: NONE, in either corpus or either mode.**

### The measured movers

**uhdm2rtlil, BOTH MODES: `MOVERS: 0 / 1608`** (`byteverify.sh`, `SELFCHECK=1`
sights 1607/1608), `787 CMP_EQUAL / 17 CMP_NOTEQUAL / 67 SLANG_REJECT` in both
modes on both binaries, and `ct8rows.sh` prints **`PASS: every row
byte-identical to the committed baseline`** against `gate_uhdm2rtlil.csv`
(testflags), against `golden_uhdm2rtlil.csv` (both modes concatenated) and
against my own pristine sweep. The four landed witnesses this pass shares
ground with — `struct_member_cfg_width`, `iface_zero_width_field`,
`packed_struct_array_fifo`, `struct_param_pattern_packing` — are
`CMP_EQUAL,,,differ` in BOTH modes, exactly as committed.

**Surelog suite, BOTH MODES: `474 CMP_EQUAL / 9 CMP_NOTEQUAL` (default) and
`469 / 8` (testflags)** on both binaries — the committed baseline to the row.
The whole-row join against `results/golden_surelog.csv` moves **three rows, and
all three move on the PRISTINE sweep too**: `LowMemLib` and `LowMemPkg`
(testflags) carry the WORKDIR PATH inside their `SURELOG_FAIL` detail string,
and `Earlgrey_0_1`/testflags reads a blank dump column on this machine's
`uhdm-dump` timeout draw — the documented one, whose real pin is the DATABASE,
which holds. Law-vs-my-own-pristine moves only the two LowMem path rows.

`byteverify.sh` over the Surelog workdirs reports **`MOVERS: 5 / 960`**
(`SELFCHECK` sights 959/960), and all five are named a priori as the UVM
family's pristine nondeterminism, not as either law — attributed by the
ORDER-BLIND (sorted, workdir-normalised) `uhdm-dump` diff:

```
MiniAmiq/default    ORDER-BLIND-DIFF-LINES=4   UINT:1345 <-> UINT:1190
MiniAmiq/testflags  ORDER-BLIND-DIFF-LINES=4   UINT:680  <-> UINT:977
SeqDriver/default   ORDER-BLIND-DIFF-LINES=4   UINT:0    <-> UINT:1272
SeqDriver/testflags ORDER-BLIND-DIFF-LINES=4   UINT:676  <-> UINT:781
Scoreboard/default  ORDER-BLIND-DIFF-LINES=0   <- the pure ORDER coin
```

Each of the first four is **ONE `UINT:` / `vpiDecompile` LINE-NUMBER pair** and
nothing else — never a `vpiSize:`, never a `vpiConstType:`, never an encoding,
which is exactly what either of this pass's laws would look like if it had
fired. `Scoreboard/default` is 0 lines order-blind: the documented ~50/50
`svunit_pkg` `vpiTaskFunc` list flip, a COIN and not a mover at all. The same
0-or-4-line class r11u66 recorded; the PRE-FENCE binary drew the same four with
different line numbers (`evidence/MOVERS.orderblind.shipped.txt`), which is what a coin
looks like. All five rows stay `CMP_EQUAL` (`Scoreboard`/testflags is
`SLANG_REJECT` in the committed baseline too), and `BuildUVMPkg` and
`SimpleUVM` are **byte-IDENTICAL** in both modes.

**THE BYTE PINS, by name, law vs pristine:**

```
SVSwitch           default 4842211c4030  testflags 4842211c4030   SAME (the brief's pin)
YosysVerx          default 6ccda350c24a  testflags 6ccda350c24a   SAME (the brief's pin)
InterfaceModPort   default 59a365f3ce2c  testflags 59a365f3ce2c   SAME (the brief's pin)
BlackParrotComplex default e3e354129d5a  testflags 73a10e8217e5   SAME
YosysOldOr         default d68e0796d62c  testflags d68e0796d62c   SAME
Earlgrey_0_1       default 8bdf25272e08  testflags 59d0ee6d10c3   SAME (the brief's pins)
```

`canaries.sh` reads `ok=51 changed=1` on BOTH binaries — the one change is
`Earlgrey_0_1`/testflags's dump column, the timeout draw above, identical on
the pristine sweep. `ctcan2.sh` PASSES on both corpora, and `canaudit.sh`
prints `PASS: every brief-protected name and family is carried by a script that
RUNS here`. `tests/check_goldens.sh` is `23 PASS / 0 FAIL` with
`SLANG_UHDM=/bin/false` giving `0 PASS / 23 FAIL`. `results/*.csv` untouched;
`GOLDEN_DEFER` unset; no fenced test dispatched or named; every arm's `rc`
recorded on both sides.

**THE POSITIVE CONTROL for the byte instrument** — the two frozen binaries ARE
distinguishable to it, on this pass's own ground:

```
b1_refuse68  4f3ac15ab550 -> 34ac3fa29ba6   MOVED     c1_stamp68 1b42483dac14 -> 15b431f1d456 MOVED
b3_ops68     480d8a8c9294 -> 9a7a3d77ff9e   MOVED     e3_base56  5e0fb3466119 -> cabf135084e6 MOVED
b5_redsz68   b4edf6966215 -> c82bac08f849   MOVED     vv4_singleread          UNCHANGED (the fence)
x1_optable   dfad95b45d13 -> 94453fbdfec4   MOVED
v9           faa9d60a7437 -> 5a8a71cc6272   MOVED
g3_neg66     5cc7995dff99 -> b110bbbf1ac9   MOVED
```

so a corpus reading of ZERO is a measurement, not a blind instrument.

---

## 7. RESIDUES, and R0

* **R0 — THE CAST FACE OF THE REFUSAL SET, and it is fully decoded, just not
  claimed.** `ExprEval::reduceExpr`'s `vpiCastOp` arm
  (`~/git-repos/UHDM/templates/ExprEval.cpp:4185-4314`) folds a cast when and
  only when the target typespec is `int_typespec`, `long_int_typespec`,
  `bit_typespec`, `short_int_typespec`, `integer_typespec` (which is what a SIZE
  cast `N'(…)` carries) or `enum_typespec`; every other target breaks with
  `result` unchanged, the `op67` survives, `get_uvalue` refuses it and the walk
  returns. Measured cell for cell in `b6_cast68` and `b2_faces68` on real v1.87
  goldens — `byte'`, `logic'`, `reg'`, `time'` and a `typedef logic [7:0]` cast
  BAIL; `int'`, `integer'`, `shortint'`, `longint'`, `bit'`, a `typedef bit
  [7:0]` cast, an enum cast, `8'( )`, `32'( )`, `signed'`, `unsigned'`,
  `$signed` and `$unsigned` COMPLETE. What this pass declines to spend is the
  slang-side half: telling a named-type cast from a size cast needs the
  expression's own type NAME (a size cast's result type is anonymous), and
  guessing it would move sizes under operands golden folds. 12 `b6` cells and 6
  `b2` cells, all STILL, none AWAY, none in either corpus.
* **R1 — THE CONSTANT FUNCTION CALL'S BAIL.** `f_neg(6)` reduces to `INT:-6` in
  golden and `get_uvalue` refuses it, but our own operand reads `UINT:250`
  because `dimRedCtExpr79` answers 0 for a non-system call (r11u66's R1, still
  open). So `patUvalueRefuses68` does not see the refusal and
  `g2_fncall66`'s five post-bail cells stay STILL. **This residue closes for
  free the moment R1's call arm lands** — the bail is read off the encoding, so
  fixing the encoding fixes the bail.
* **R2 — THE >64-BIT OPERAND'S BAIL, and the naive reading is REFUTED.**
  `get_uvalue` refuses a `BIN`/`HEX`/`OCT` constant whose `expr->VpiSize()`
  exceeds 64, but the size it tests is the REDUCE PRODUCT's, not the literal's
  declared width: `96'b1`, `96'o1`, `70'h5`, `65'h1`, `65'd1` and
  `64'hFFFFFFFFFFFFFFFF` all COMPLETE the walk, and only
  `96'h123456789ABCDEF012345678` — 24 hex digits, a value that genuinely needs
  97 bits — bails (`b2` `w96`, `b3` `o96`/`d96`/`b70`/`h70`/`h64`/`h65`). Two
  cells, STILL, never AWAY. Closing it means modelling how Surelog sizes a
  based literal's compiled constant from its DIGITS, which no arm here measures.
* **R3 — WHOSE ARITHMETIC, one site further on.** `KU << 40` is golden
  `UINT:6597069766656` at 64 and ours a member-masked `UINT:0`; `~KU` is golden
  `UINT:4294967289` and ours `UINT:249`. This law's VALUE GUARD and its
  shift-left abstention keep both out, so they stay STILL at the size too. Same
  class as r11v66's R-V1 (`BIG * 2`): the producer computes at 64 bits where
  slang is self-determined.
* **R4 — THE MISSING `'x` / `'z` OPERAND.** Our packed walk emits NO operand at
  all where golden writes `UINT:0` for an unbased-unsized `'x` or `'z` setter
  (`b3_ops68` `xunsz`/`zunsz`, `e1_enc56` `uux`, `e2_width56`, `e5_deffill56`).
  It predates both laws, is untouched by both, and is what makes the seven
  SHAPE-MISMATCH rows of §5. One line of the `ectx.tryEval` guard
  (`!cvm.integer().hasUnknown()`) owns it.
* **R5 — THE `int_typespec` BINARY DIGIT ARM.** `adjustSize`'s `:4150-4215`
  branch keeps a based binary's own digits and sizes it `min(orig, Lhs)`, where
  § caStructParamPatternSubst55's W3 transcribes only the `logic_typespec`
  shrink. LAW B declines that class rather than model it, so `e3_base56`'s
  `o12` (`rb: B16` on a 16-bit member at an 8-bit Lhs, golden
  `16'b1010010111000011` `vpiSize:8`, ours `11000011`) and `c1_stamp68`'s
  `nb16`/`nb16w` stay STILL. Modelling it is a VALUE law, not a size one, and it
  is the natural companion to LAW B.
* **R6 — the comparison's `BIN:1`@1 encoding.** `x1_optable` `cmp` (`K > 2`) is
  golden `const/1@3=BIN:1` and we write `const/32@9=UINT:1`; `b1`/`b3` add
  `eqq`, `nee`, `gee`, `lee`, `lt` and `cbit`. `patRedSz68` abstains on every
  comparison for exactly this reason — the size cannot move under an encoding
  the walk has not converged. The same shared table question as r11u66's R1/R2.

---

## 8. REPRODUCING

```bash
git worktree add /tmp/wt ff5541cd && cd /tmp/wt && git apply -3 /tmp/r11u68.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2 && md5sum build/slang-uhdm

R=tools/probe/r11u68repro
G=/tmp/g68 && mkdir -p $G && cp $R/grid/*.sv $G/
cp tools/probe/r11u66repro/grid/*.sv tools/probe/r11v66repro/grid/*.sv $G/
cp $R/{run66.sh,cmp68.py,shape68.py,bail68.py,szdiff68.py} $G/
(cd $G && bash run66.sh b1_refuse68.sv law <binary>)         # rc for BOTH sides
(cd $G && python3 bail68.py b1_refuse68.g.dump b1_refuse68.law.dump)
(cd $G && python3 cmp68.py <arm>.g.dump <arm>.pris.dump <arm>.law.dump <arm>)

C=/tmp/c68 && mkdir -p $C && cp -r $R/ca/* $C/
cp -r tools/probe/r11u56repro/grid/* tools/probe/r11v55repro/grid/* $C/
cp $R/{run56.sh,ca68.py,caread55.py} $G/
(cd $C && GRID=$C bash $G/run56.sh <binary> law c1_stamp68)
(cd $C && CAREAD=$G/caread55.py python3 $G/ca68.py c1_stamp68/gold.law.dump \
          c1_stamp68/ours.pris.dump c1_stamp68/ours.law.dump c1)

GRID=$G python3 $R/census68.py --selftest   # the positive control (prints PASS)
python3 $R/census68.py                     # the a-priori candidate list
```

`run66.sh` and `run56.sh` drive Surelog v1.87 at
`~/git-repos/Surelog/build/bin/surelog` with `uhdm-dump` / `uhdm-cmp` from
`~/git-repos/UHDM/build/bin`. `cmp68.py` exits 4 on a golden dump with no
elaborated `op75` row and `ca68.py` exits 4 through `caread55.py` on a dump with
no `cont_assign` at all — a reader that reaches nothing can never read as
agreement.
