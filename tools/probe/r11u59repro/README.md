# r11u59 — the elaborated pattern re-size writes a SIZE, not a value

Base commit `4c5747e2` (v1.87 pass 57).  Pins per `SUPPORT_MATRIX.md`: slang
upstream-master `7d61e0ad1`, UHDM v1.87, Surelog v1.87
(`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil corpus v0.68.  Every
golden in this directory is a real Surelog v1.87 run and every arm records
`golden_rc` AND `ours_rc`.

**r11v58's R2 lands, and it lands corpus-invisible.**  The landed
`§ patElabUintResize` note claimed the elaborated element is "re-sized to ITS
MEMBER's bit width **and the value masked**".  The second conjunct is refuted
at the producer and on an eight-arm golden grid; the two writes it authorised
are removed.  The census over both corpora says **no cell in the ELABORATED
PACKAGE listing — the only listing this arm reaches — carries an over-wide
value**, so the change moves no corpus byte; it lands anyway, on a green grid,
because the moment a corpus row grows that face the mask writes a wrong
`vpiDecompile`, and `expr::Compare` reads `vpiDecompile` FIRST.

The measurement half (R0, the FLATTEN) ships as census only, as the brief
directs: **2 corpus rows** (4 row-mode cells) carry a completed-walk FLAT
listing where ours is TAGGED, and both are already `CMP_NOTEQUAL` in both modes.
`TAGGED->FLAT` — the dangerous direction — is **0** corpus-wide.

And the corpus does carry the law's own face once, in a listing the masking arm
cannot reach: `DefaultTag`'s elaborated module parameter holds `UINT:15` at
`vpiSize:2` and `UINT:20` at `vpiSize:3` in golden, ours matches it cell for
cell, and the row is `CMP_EQUAL` in both modes.  That row is what this law
protects.

---

## 1. The witness, re-measured at the base

Frozen pristine binary `/tmp/r11u59_pris.bin`, md5
`6c1de538ed7301d71a3d704c392123f3` — byte-identical to the main tree at
`4c5747e2`.  Patched `/tmp/r11u59_pat.bin`, md5
`fd9480af20aeb844dce0fe2ec7d8fee1`.  Both `chmod 555` before any sweep.

`va15_refmask` (r11v58's R2 arm), elaborated listing (`uhdmtopPackages`),
`pk::BASE`, read by `cen59` (`vpiSize` / `vpiConstType` / `vpiDecompile` — the
three fields the judge reads on a constant):

| cell | golden | ours at `4c5747e2` | ours patched |
|---|---|---|---|
| `M` (`logic [7:0]` ← `BIG` = 300) | `size=8 ct=9 dec=300` | `size=8 ct=9 dec=**44**` | `size=8 ct=9 dec=**300**` |
| `W` (`logic [127:0]` ← `128'(0)`) | `size=128 ct=9 dec=` | `operation size=128` | `operation size=128` |
| `Z` (`int unsigned` ← `unsigned'(64)`) | `size=64 ct=9 dec=64` | `size=64 ct=9 dec=64` | `size=64 ct=9 dec=64` |

The DEF listing (`uhdmallPackages`) reads `M size=64 ct=9 dec=300` on BOTH
sides, at the base and patched: the divergence was elaborated-only, which is
what put it inside `§ patElabUintResize`.

`va14_maskrepl` re-run at the base is **unchanged on every cell** — its
over-wide 300 is written as a LITERAL, and the landed arm's `refMem9` filter
excludes literals, so the mask never reached it.  That is why r11v58 could see
the divergence on `va15` and not on `va14`.

## 2. The producer, decoded line by line

### 2a. The stamp writes ONE field

`CompileHelper::adjustOpSize`
(`Surelog/src/DesignCompile/CompileHelper.cpp:5114`) has four arms — struct,
array, logic, and the fallthrough — and every one of them ends in the same two
lines (`:5153-5154`, `:5170-5171`, `:5188-5189`, `:5199-5200`):

```cpp
      // Fix the size of the member:
      adjustUnsized(any_cast<constant*>(cop), ncsize);
      cop->VpiSize(ncsize);
```

`cop->VpiSize(ncsize)` is the only unconditional write, and it writes VpiSize.
`CompileHelper::adjustUnsized` (`:5091`) is the only line in the whole stamp
that can touch a value, and it opens with

```cpp
  int32_t csize = c->VpiSize();
  if (csize == -1) {
```

so it returns immediately for every SIZED constant, and even at `-1` it acts
only when `get_uvalue` reads 1.  **There is no mask.**  `vpiValue`,
`vpiDecompile` and `vpiConstType` survive the re-size untouched.

### 2b. Which fields the judge reads

`expr::Compare` (`~/git-repos/UHDM/build/generated/src/expr.cpp:90,95`) reads
`VpiDecompile` and then `VpiSize`; `constant::Compare` (`constant.cpp:66`)
reads `VpiConstType`.  **`VpiValue` is read by no generated `Compare`.**  So the
landed arm's `VpiValue("UINT:"+masked)` was judge-invisible and its
`VpiDecompile(masked)` was the whole of the damage — it wrote `44` where golden
reads `300`, on the field the judge reads first.

### 2c. The flatten-vs-tag rule (R0's half of the same read)

`expandPatternAssignment` returns the FLATTENED clone when its positional walk
completes (`CompileHelper.cpp:5494-5497`) and the ORIGINAL tagged tree on
either exit — the width bail (`shift >= 64`) or `invalidValue`
(`:5423`).  Golden's elaborated listing is therefore FLAT exactly where the
walk completed and TAGGED exactly where it bailed, which is r11u58's reading
and is what the flatten census below keys on.

### 2d. A THIRD exit, measured here

The positional loop (`:5407-5442`) runs, per operand,
`reduceExpr` → `eval.get_uvalue` → `adjustOpSize` → `if (invalidValue) return
result;`.  `invalidValue` is a single bool that is **not reset between
operands**, and the `return` comes AFTER the stamp.  `wa3_signed` cuts the
face: with members `SB SN UN SW` fed `300 / -5 / -5 / -300`, golden stamps
`SB`→8 and `SN`→8 and then leaves `UN` and `SW` at 32 — their substituted
sizes, not their member widths of 8 and 16.  **A NEGATIVE element value ends
the walk, after being stamped.**  That is a new member of r11v58's R3 family
and it is recorded, not implemented.

## 3. The golden grid

Eight arms, one real Surelog v1.87 run each, all cut inside the BAILED state (a
128-bit member ends the walk, which also keeps the elaborated listing tagged so
every cell is readable by member name).  `golden_rc=0 ours_rc=0` on every arm
and every binary (`rc59.txt`).  Cells are `size/value/decompile`.

### 3a. WIDTHS — `wa1_widths`

| cell | member | golden ELAB | ours at base | ours patched |
|---|---|---|---|---|
| `M1` ← `BIG`=300 | `logic` (1) | `1/UINT:300/300` | `1/UINT:0/0` | **`1/UINT:300/300`** |
| `M4` ← `BIG` | `logic [3:0]` | `4/UINT:300/300` | `4/UINT:12/12` | **`4/UINT:300/300`** |
| `M8` ← `BIG` | `logic [7:0]` | `8/UINT:300/300` | `8/UINT:44/44` | **`8/UINT:300/300`** |
| `M16` ← `HUGE`=70000 | `logic [15:0]` | `16/UINT:70000/70000` | `16/UINT:4464/4464` | **`16/UINT:70000/70000`** |
| `M32` ← `GIANT`=5000000000 | `int unsigned` | `32/UINT:5000000000/5000000000` | `32/UINT:705032704/705032704` | `32/UINT:705032704/705032704` |

**A value three hundred times too wide for its one-bit member is still 300 in
golden.**  Four cells go byte-exact; `M32` does NOT move, because slang had
already truncated 5000000000 to the 32-bit member type upstream of this arm —
the mask was the identity there.  That is a separate residue and it is named as
one below, not claimed.

### 3b. BASES — `wa2_bases`

The same 300 reaching five 8-bit members through references written decimal /
hex / binary / octal / sized-decimal.  Golden keeps the REFERENCE's own
encoding verbatim at the member size:

```
GOLD  D=8/UINT:300/300  H=8/HEX:12C/32'h12C  B=8/BIN:100101100/32'b100101100
      O=8/-/32'o454      S=8/DEC:300/16'd300
BASE  D=8/UINT:44/44     H=8/UINT:44/44      B=8/UINT:44/44
      O=8/UINT:44/44     S=8/UINT:44/44
PAT   D=8/UINT:300/300   H=8/UINT:300/300    B=8/UINT:300/300
      O=8/UINT:300/300   S=8/UINT:300/300
```

`D` goes byte-exact.  `H`/`B`/`O`/`S` move from the masked 44 to the right
NUMBER under the wrong ENCODING: our exporter emits every substituted element
as a decimal `UINT` (`ct=9`) where golden keeps `ct=5/3/4/1`.  Those four cells
are **still wrong after the change and were wrong before it** — an
encoding residue of the r11u55 reduce-table family, named in §7 and not
claimed as a move toward golden.

### 3c. SIGNEDNESS — `wa3_signed`

```
GOLD  SB=8/UINT:300/300  SN=8/INT:-5/-5  UN=32/INT:-5/-5  SW=32/INT:-300/-300
BASE  SB=8/UINT:44/44    SN=8/UINT:251/251  UN=8/UINT:251/251  SW=16/UINT:65236/65236
PAT   SB=8/UINT:300/300  SN=8/UINT:-5/-5    UN=8/UINT:-5/-5    SW=16/UINT:-300/-300
```

On the judged field, `vpiDecompile`, all four cells go **exactly to golden**
(`300 / -5 / -5 / -300`), where the mask had written `44 / 251 / 251 / 65236`.
`std::stoull` accepts a leading minus and wraps, so the landed arm had been
silently masking a two's-complement residue onto a negative element; the change
leaves the element exactly as our own DEF listing already carried it (`UINT:-5`,
`dec -5`), which is the invariant the `§ patElabUintResize` note states.  The
remaining divergences on these cells — `ct 9` against golden's `7`, and the
sizes 8/16 against golden's 32/32 — are the encoding residue and §2d's
negative-bail exit.

### 3d. LITERAL vs REFERENCE vs ENUM vs CAST — `wa4_litref`

Golden gives all four `8/UINT:300/300`.  At the base, the literal `LIT` was
already right (the `refMem9` filter never touched it) and `REF`/`ENU`/`CST`
read `44`; patched, all four read `300`.  **Three cells to golden**, and the
arm shows the `refMem9` split is a SIZE-side rule with no value side at all.

### 3e. THE FITTING CONTROL — `wa5_fitctl`, and `va14_maskrepl`

Every value fits its member.  Golden re-sizes and changes nothing else; our
pristine and patched listings are **identical, cell for cell** (`A=8/UINT:7/7
H=8/UINT:31/31 B=8/UINT:11/11 S=8/UINT:9/9 O=1/UINT:1/1`).  This is the arm
that proves the removal is the identity wherever a value fits — which is what
makes the corpus zero below believable.  `va14_maskrepl` is unchanged the same
way.

### 3f. THE ONE VALUE THE PRODUCER DOES REWRITE — `wa6_unsized`

`adjustUnsized`, cut directly.  Golden's DEF listing carries `U1=-1/BIN:1/'1`
and `U0=-1/BIN:0/'0`; its ELAB listing carries `U1=8/UINT:255/255` (the
all-ones mask at the member width, with `vpiConstType` rewritten to 9) and
`U0=8/UINT:0/0`.  We write `U1=8/BIN:1/'1` in both binaries.  That is a
**MISSING** write, not a wrong one; it is recorded as a residue and NOT
implemented, because the census finds no corpus cell that carries it.

### 3g. The arms that must not move, and do not

`wa5_fitctl`, `wa6_unsized`, `va14_maskrepl` and all eight of r11u58's own
arms (`xd1` … `xd8`) produce byte-identical elaborated listings under both
binaries.  `xd1`…`xd8` were re-run under the pristine binary for the flatten
census's positive control and their cmp line counts are unchanged from the
r11u58 README (`xd1` 14, `xd2` 8, `xd2b` 38, `xd3` 5, `xd4` 74, `xd5` 14,
`xd6` 5, `xd8` 5).

## 4. THE LAW — § patElabNoMask59

At `src/ParamEmit.cpp`, inside the landed `§ patElabUintResize` arm and gated
by exactly its conditions (`topView && structPat && structWidePkg &&
inPackage`, an `vpiAssignmentPatternOp` Rhs, a slang
`StructuredAssignmentPatternExpression` init, a `PackedStructType` parameter,
the member-width map, the `refMem9` reference filter, the `UINT:` prefix test
and the `stoull` parse):

> the elaborated package struct-pattern element is **re-sized** to its member's
> bit width and **nothing else is written** — `vpiValue`, `vpiDecompile` and
> `vpiConstType` carry the substituted value verbatim, exactly as
> `adjustOpSize`'s `adjustUnsized(cop, ncsize); cop->VpiSize(ncsize);` leaves
> them.  The producer's single exception, `adjustUnsized` on an UNSIZED element
> holding 1, is measured (`wa6_unsized`) and deliberately not implemented.

The element FILTER is untouched, so **the set of cells that receive a size is
bit-for-bit what it was at `4c5747e2`**; the only difference is the two value
fields that stop being written.  The diff is two deleted writes and one
`(void)` on the now-unused parse result, plus the law's comment.

## 5. Census, movers predicted BY NAME, and the positive control

Instruments: `cen59.cpp` (the element/shape census, reading `design::
AllPackages / TopPackages / AllModules / TopModules`), `cenrun59.sh` (the sweep
driver — the golden database is served from `~/.cache/slang-uhdm-goldens` and
its directory is recovered from each row's `cmds.txt`), `pred59.py` (the
a-priori mover predictor and the two censuses).

### 5a. GOLDEN-VS-GOLDEN FIRST

`cen59` marks a cell **OVERWIDE** when its `UINT` value does not fit the
`vpiSize` it sits at — the exact face the mask acted on.

| corpus | rows read | golden pattern cells | OVERWIDE | rows with OVERWIDE |
|---|---|---|---|---|
| uhdm2rtlil (both modes) | 1742 | 17287 | **0** | **0** |
| surelog (both modes) | 1581 (1530 goldens read) | 92081 | **8** | **1** (`DefaultTag`, both modes) |
| **the grid (positive control)** | 8 | 92 | **13** | **6** |

Broken out by listing — and this is the line the law turns on:

| view | surelog OVERWIDE | uhdm2rtlil OVERWIDE |
|---|---|---|
| `elabpkg` (the ONLY view `§ patElabUintResize` reaches) | **0** | **0** |
| `elabmod` | **8** | 0 |

**AND THE CORPUS CARRIES THE LAW'S OWN FACE, ALREADY EQUAL.**  The eight are
`DefaultTag`'s elaborated `work@top` parameter `X`, four positional elements in
both modes:

```
golden  #0 size=2 ct=9 UINT:15 dec=15   #1 size=3 ct=9 UINT:10 dec=10
        #2 size=3 ct=9 UINT:15 dec=15   #3 size=3 ct=9 UINT:20 dec=20
ours    identical, cell for cell, in both binaries        DefaultTag: CMP_EQUAL x2
```

A 15 at `vpiSize:2` and a 20 at `vpiSize:3`, in the corpus, in golden, kept —
the producer's no-mask rule measured on a real row rather than a purpose-built
one.  Our exporter already matches it because the masking arm is gated
`inPackage` and never reaches the module view.  **`DefaultTag` is therefore a
row this law PROTECTS**: it is exactly what regresses the day anyone widens the
masking arm past the package listing.

**A ZERO WITH ITS POSITIVE CONTROL.**  The same census, same binary, same
invocation, reads 13 OVERWIDE golden cells on the grid — `wa1` M1/M4/M8/M16/M32,
`wa2` D, `wa3` SB, `wa4` LIT/REF/ENU/CST, `va14` L, `va15` M — and reads 0 on
`wa5_fitctl`, the arm built to fit.  The corpus zero is a measurement, not a
silence.

### 5b. THE MOVERS, PREDICTED BY NAME

The predictor inverts the mask arithmetic against golden, because post-mask our
own database can no longer show what was masked:

> a cell is a PREDICTED MOVER ⟺ ours is a `constant` with `vpiConstType 9` at
> `0 < vpiSize < 64`, golden's `vpiDecompile` parses as an integer `g`, ours
> parses as `u`, and `u == g mod 2**size` with `u != g`.

On the grid it names **14 cells across 5 arms**, by name, including every one
of the 13 cells that actually moved plus `wa1 M32` (which the arithmetic cannot
distinguish from a mask, because slang's upstream truncation produces the same
residue — the predictor is a SUPERSET, which is the safe direction for a gate).
On the corpus it names **0 cells in 0 rows**, on 32 candidate rows that carry a
reachable cell at all.

**PREDICTED CORPUS MOVER SET: EMPTY, BOTH CORPORA, BOTH MODES.**

### 5c. THE FLATTEN CENSUS (R0) — measurement only

A pattern where golden's elaborated listing reads FLAT and ours reads TAGGED is
one completed-walk cell of R0.

*Positive control first*: over r11u58's own eight grid arms the census reports
**10 such cells in 6 arms** — `xd3` `BASE`, `xd8` `S1`/`S2`/`S5`, `xd4`
`R1`/`R2`/`R5`, `xd6` `P2`, `xd2b` `BASE`, `xd2` `BASE` — reproducing the R0
arm list published in the r11u58 and r11v58 READMEs, cell for cell.

*The corpus*, joined on (view, owner, param):

| corpus | golden elab patterns | joined | `TAGGED->TAGGED` | `FLAT->FLAT` | **`FLAT->TAGGED`** | `TAGGED->FLAT` |
|---|---|---|---|---|---|---|
| uhdm2rtlil | 1657 (802 pkg / 855 mod) | 768 | 320 | 446 | **2** | **0** |
| surelog | 1150 | 607 | — | — | **2** | **0** |

`TAGGED->FLAT` is zero on both corpora: **we never flatten where golden tags**,
so nothing the pattern machinery of r11u55/r11u48 and the pass-57 stamp rely on
is at risk from the reverse direction.  The 889 (u2r) and 543 (surelog)
unjoined golden patterns are ones whose (owner, param) key our database does not
carry at that view at all — a limitation of the join, stated rather than hidden;
they are a superset of R0, not a part of it.

**THE WHOLE OF R0 IN THE CORPUS IS TWO ROWS (four row-mode cells), and both are
ALREADY `CMP_NOTEQUAL` in both modes**:

1. `StructParamPatternInitCast` (surelog, `CMP_NOTEQUAL` detail `decompile:`,
   both modes) — `cfg_pkg::Base`, ONE element:
   `golden FLAT #0 size=32 ct=1 DEC:64 dec=32'd64` against
   `ours TAGGED XLEN size=32 ct=1 DEC:64 dec=32'd64`.  **All three judged
   fields already agree**; the entire residue on this pattern is the
   `tagged_pattern` wrapper.  This is the cleanest flatten target in the corpus:
   nothing to compute, one node to drop.
2. `stamped_gen_param` (uhdm2rtlil, `CMP_NOTEQUAL` detail `decompile:`, both
   modes) — `q2::IMPL`, THREE elements:
   `golden FLAT 4/HEX:9/4'h9 · 36/BIN:010101101010 · 2/BIN:11/2'b11` against
   `ours TAGGED 4/HEX:9/4'h9 · `**`12`**`/BIN:010101101010 · 2/BIN:11/2'b11`.
   Two of three cells agree; the middle one's `vpiSize` is 12 where golden reads
   **36**, which is `adjustOpSize`'s LOGIC arm (`CompileHelper.cpp:5173-5192`,
   `ncsize = Bits(rtps,…,false) / Bits(rtps,…,true)`) — the packed-array
   dimension count, not the element width.  So this row needs the flatten AND
   that one size rule.

### 5d. PER-ROW RESIDUE ARITHMETIC — the flatten is an ADVANCE, not a conversion

Order-blind, path- and id-normalised whole-dump residue against each row's own
golden, with the `tagged_pattern` line counts that bound the flatten's effect
(one `tagged_pattern` object is three dump lines):

| row | golden-only | ours-only | `tagged_pattern` golden / ours | lines the flatten can remove |
|---|---|---|---|---|
| `StructParamPatternInitCast` / default | 295 | 421 | 9 / 12 | 3 of 421 |
| `stamped_gen_param` / default | 1098 | 280 | 9 / 18 | 9 of 280 (+1 golden-only on the 12→36 size) |

**NEITHER ROW CONVERTS ON THE FLATTEN.**  Said plainly so the next pass is not
dispatched on a promise: the flatten half is worth two rows' worth of shape
correction out of residues of 716 and 1378 lines, and the rest of both rows is
other families.

### 5e. THE DISPATCHABLE BRIEF (one paragraph)

> Implement the FLATTEN half of the r11u58 read at the same site as
> `§ pkgElabPatMemberStamp58`: when the producer's positional walk COMPLETES —
> no member wider than 64 bits, no nested assignment-pattern element, no element
> whose value `reduceExpr`/`get_uvalue` cannot produce (the negative-value face
> `wa3_signed` measures) — `expandPatternAssignment` returns
> `ExprEval::flattenPatternAssignments`'s clone
> (`CompileHelper.cpp:5494-5497`), whose operand list is POSITIONAL: the
> `tagged_pattern` wrappers are gone and the element objects are the same
> objects, re-parented to the clone (judge-invisible; no generated `Compare`
> reads `VpiParent`).  The corpus cut is exactly two rows —
> `StructParamPatternInitCast` (`cfg_pkg::Base`, one element whose three judged
> fields already match: drop the wrapper and the pattern is golden) and
> `stamped_gen_param` (`q2::IMPL`, three elements, one of which also needs
> `adjustOpSize`'s LOGIC arm, `Bits(full)/Bits(inner)` = 36 where we write 12).
> Both are `CMP_NOTEQUAL` in both modes today, so neither can regress a status;
> neither converts either.  `TAGGED->FLAT` is 0 across both corpora, so the
> landed pattern machinery is not at risk from over-flattening — the danger is
> the other way, and the eighteen named rows of pass 57 plus the `DefaultTag`
> and `FuncStructVal` cells are the set to re-score.  Re-run this pass's
> `cen59` + `pred59.py --flat` as the before/after census; its positive control
> is r11u58's own grid, where it reads 10 `FLAT->TAGGED` cells in 6 arms.

## 6. Gates — all green

1. **Builds.**  Pristine `6c1de538ed7301d71a3d704c392123f3`, **byte-identical to
   the main tree at `4c5747e2`**; patched `fd9480af20aeb844dce0fe2ec7d8fee1`.
   Both `-j 2`, md5'd separately, `chmod 555` before any sweep.  (The patched
   binary was rebuilt once after a comment correction and came out with the SAME
   md5 — a comment-only change, byte-identical object code.)  Every `cmds.txt`
   audited BY BINARY PATH: **1581 surelog arms and 1742 u2r arms per workdir,
   one path each, no third path.**
2. **Goldens** `23 PASS / 0 FAIL` on the patched binary; `SLANG_UHDM=/bin/false`
   `0 PASS / 23 FAIL` (the negative control).
3. **uhdm2rtlil, both modes: 785 CMP_EQUAL / 19 CMP_NOTEQUAL / 67 SLANG_REJECT.**
   Whole-row joins (status AND dump column) against `results/gate_uhdm2rtlil.csv`,
   against both mode halves of `results/golden_uhdm2rtlil.csv`, and against this
   pass's own pristine sweep in each mode: **`PASS: every row byte-identical to
   the committed baseline` on all four.**  byteverify **MOVERS 0 / 1608**,
   `PATH_SETS_IDENTICAL`, selfcheck 1607/1608 (the gate can see).
4. **surelog `--mode both`: 474 CMP_EQUAL / 9 CMP_NOTEQUAL (default) + 469 / 8
   (testflags)** — the committed baseline, on BOTH binaries.  Against
   `results/golden_surelog.csv` and against this pass's own pristine sweep, the
   whole-row diff is **2 rows in each case and they are the same two**:
   `LowMemLib,testflags` and `LowMemPkg,testflags`, whose `SURELOG_FAIL` detail
   string embeds the workdir path (`.../m187base/sl/wd/...` vs
   `.../r11u59_wd{p,r}/sl/...`).  Every per-mode STATUS histogram and every
   per-mode DUMP-column histogram is identical baseline-to-fresh.
5. **surelog byteverify vs this pass's own pristine: MOVERS 3 / 960**,
   `PATH_SETS_IDENTICAL`, selfcheck 959/960.  None was predicted by the law, and
   none is the law — all three are the documented UVM nondeterminism, attributed
   ORDER-BLIND and with a positive control (§6a).
6. **The eighteen named rows of pass 57: 36 cells, every one `CMP_EQUAL` and
   the row string byte-identical between the pristine and patched sweeps —
   MOVED-WRONG 0.**  `FuncStructVal` and `StructParamFuncBodyFieldCompare` are
   among them; the latter's committed C3-family head is unchanged at **74 cmp
   lines / 1 head in both modes on both binaries**, and its database is one of
   the 957 that did not move a byte.
7. **Canaries.**  `canaries.sh` **ok=52 changed=0 absent=0** (surelog) and
   **ok=8 changed=0 absent=0** (u2r); `ctcan2.sh` `PASS` on both with
   `EXPECT_UNKNOWN=1` / `=6`; `canaudit.sh` **audited=29 UNCOVERED=0
   FENCE-BREACH=0**.  `rowheads.sh` on the patched sweep gives **`cmp rc=0 / 0
   heads`** for SeqDriver, SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg,
   Earlgrey_0_1 and FuncStructVal in both modes (`Scoreboard/testflags` is the
   expected `SKIP-NOFILE`).
8. **All six protected databases SAME between the two binaries and at their
   pins**: SVSwitch `4842211c4030` (both modes), YosysVerx `6ccda350c24a` (both),
   InterfaceModPort `59a365f3ce2c` (both), BlackParrotComplex `e3e354129d5a` /
   `73a10e8217e5`, YosysOldOr `d68e0796d62c` (both), Earlgrey_0_1
   `8bdf25272e08` / `59d0ee6d10c3`.
9. `results/*.csv` **untouched** (`git diff --name-only 4c5747e2` = one file,
   `src/ParamEmit.cpp`).  Fence-name scan over the four slang-fenced names:
   **0 / 0 / 0 / 0**; no fenced test dispatched; `GOLDEN_DEFER` unset.  The patch
   applies clean on a fresh `4c5747e2`.

**NO ROW CONVERTS; NO ROW REGRESSES; THIRTEEN GRID CELLS GO TO GOLDEN AND THE
CORPUS DOES NOT CARRY THE FACE.**  Scoreboard unchanged at 474/9 + 469/8 +
785/19/67 x2.

### 6a. The three movers, named and attributed

| database | pristine | patched | order-blind diff |
|---|---|---|---|
| `default/MiniAmiq` | `ae43dca6c711` | `683f6b789b59` | **4 lines**: `UINT:660`/`vpiDecompile:660` ↔ `UINT:1482`/`vpiDecompile:1482` |
| `testflags/MiniAmiq` | `da2371024182` | `85383e697294` | **4 lines**: `UINT:553`/`vpiDecompile:553` ↔ `UINT:997`/`vpiDecompile:997` |
| `default/Scoreboard` | `1621aec6c9f3` | `e70775324004` | **0 lines** |

Both MiniAmiq deltas are a single `UINT`/`vpiDecompile` PAIR carrying a LINE
NUMBER — the documented macro-buffer `SourceLocation` class — and Scoreboard is
the documented 0-line ORDER draw.  All three rows stay `CMP_EQUAL` (Scoreboard's
`testflags` row is the pre-existing `SLANG_REJECT`, unchanged).

**POSITIVE CONTROL (`/tmp/r11u59_wdctl`).**  The PRISTINE binary alone, re-run
twice on those rows and nothing else changed:

```
              sweep-pristine   ctl run 1      ctl run 2      sweep-patched
default/MiniAmiq    ae43dca6c711   7f3192b7b8a0   c24a31f15917   683f6b789b59
testflags/MiniAmiq  da2371024182   da2371024182   bc1dd5cef931   85383e697294
default/Scoreboard  1621aec6c9f3   1621aec6c9f3   1621aec6c9f3   e70775324004
```

**Four distinct MiniAmiq/default hashes out of one unchanged binary.**  The
mover set is nondeterminism, proved, not inferred from its being familiar.

### 6b. The grid boundary — the away-move test

`armdelta59.sh` (r11u58's `armdelta58.sh`, retagged and with the dump's
`… .uhdm: Restored design` header line normalised out) reports the NEWLY
unmatched sets per arm:

| arm | NEW-ours-only | GONE-ours-only | **NEW-golden-only** | GONE-golden-only |
|---|---|---|---|---|
| `wa1_widths` | 0 | 7 | **1** | 8 |
| `wa2_bases` | 10 | 10 | **0** | 0 |
| `wa3_signed` | 3 | 8 | **0** | 5 |
| `wa4_litref` | 0 | 6 | **0** | 6 |
| `wa5_fitctl` | 0 | 0 | **0** | 0 |
| `wa6_unsized` | 0 | 0 | **0** | 0 |

`wa1`'s single NEW-golden-only line is `|UINT:0`, and it is **THE MULTISET
TRAP, named and counted**: at that indent golden carries TWO `|UINT:0` (one of
them the `W` element constant we emit as a cast OPERATION instead), our pristine
dump carried ONE — the wrongly-masked `M1` cell reading 0 — and our patched dump
carries NONE.  The "lost" golden line is a scalar field line our wrong 0 used to
satisfy, not a golden object we stopped producing.  Proof, at that exact indent:
`gold 2 / pristine 1 / patched 0`.

`wa2`'s 10-for-10 exchange is the encoding residue of §3b: four cells whose
`vpiDecompile` goes `44` → `300` while golden reads `32'h12C` / `32'b100101100`
/ `32'o454` / `16'd300`.  **Those four cells are STILL-WRONG and are counted as
still-wrong**, not as movers toward golden.  `NEW-golden-only` is 0 there, so
nothing that matched stopped matching.

## 7. Residues left standing, and R0

* **R0 — THE FLATTEN (this pass's R0, measured in §5c–5e, NOT implemented).**
  Two corpus rows, four row-mode cells, both already `CMP_NOTEQUAL`:
  `StructParamPatternInitCast` (`cfg_pkg::Base`, wrapper only) and
  `stamped_gen_param` (`q2::IMPL`, wrapper plus one `12`→`36` size from
  `adjustOpSize`'s logic arm).  `TAGGED->FLAT` is 0 corpus-wide, so the landed
  pattern machinery is not at risk from the reverse direction.  The dispatchable
  paragraph is §5e.
* **R1 — the ENCODING of a substituted element** (`wa2_bases`, `wa5_fitctl`,
  `wa3_signed`).  Golden's element carries the referenced parameter's own
  `vpiConstType` and `vpiDecompile` verbatim (`HEX:12C` decompiling `32'h12C`,
  `DEC:9` decompiling `8'd9`, `BIN:1` decompiling `1'b1`, `INT:-5` decompiling
  `-5`); we write a decimal `UINT` for every one of them.  `constant::Compare`
  reads `VpiConstType` and `expr::Compare` reads `VpiDecompile`, so this is a
  two-field judged divergence on every non-decimal element, present at
  `4c5747e2` and untouched here.  It is the r11u55 reduce-table ground and it is
  the widest thing this grid found.
* **R2 — `adjustUnsized`, the producer's one value rewrite** (`wa6_unsized`).
  Golden turns an `'1` element into `UINT:255` decompiling `255` at an 8-bit
  member; we keep `BIN:1` / `'1`.  MISSING, never wrong.  Not implemented: the
  census finds no corpus cell with an unsized pattern element.
* **R3 — the NEGATIVE-value walk exit** (`wa3_signed`, §2d).  A member whose
  substituted value `get_uvalue` cannot produce ends the producer's walk after
  stamping it: golden leaves `UN` at 32 and `SW` at 32 where we stamp 8 and 16.
  A new, measured member of r11v58's R3 family; the pass-57 stamp does not know
  it.  Two cells on a purpose-built arm, zero in the corpus.
* **R4 — slang's upstream truncation** (`wa1_widths` `M32`).  A 5000000000 into
  a 32-bit member reaches this arm ALREADY truncated to 705032704, so no change
  at the masking site can reach it; golden reads `5000000000` at `vpiSize:32`.
  This is the arm's own cmp head and it is upstream of everything measured here.
* **The `W` cast operation.**  On every arm in this grid golden folds
  `128'(0)` to a `constant` and we emit the cast `operation`.  Pre-existing,
  unrelated, and it is what makes `wa1`'s multiset line readable (§6b).

**R0 for the next pass: the FLATTEN half, two rows, brief in §5e.**

## 8. Ops record

Worktree `/tmp/wt_r11u59` at `4c5747e2`; scratch `/tmp/r11u59_*`; workdirs
`/tmp/r11u59_wdp` (this pass's own pristine control), `/tmp/r11u59_wdr`
(patched) and `/tmp/r11u59_wdctl` (the UVM nondeterminism positive control).
Binaries frozen at `/tmp/r11u59_pris.bin` and `/tmp/r11u59_pat.bin`,
`chmod 555`.  No shared `/tmp/ctl_wd_*` control was read; nothing was written
outside the worktree and this pass's own prefixed scratch; the grid runs made
inside `tools/probe/r11u58repro` and `tools/probe/r11v58repro` (for the flatten
positive control and the `va14`/`va15` re-measurement) were removed with a
narrow `git clean -fdq` on those two directories and the tracked files there are
untouched.  `results/*.csv` untouched; `GOLDEN_DEFER` unset; no fenced test
dispatched.

## 9. Instruments (all measurement-only; the judge is `uhdm-cmp`)

* `cen59.cpp` — the ELEMENT + SHAPE census over one database: every
  assignment-pattern element of every `param_assign` in all four listings, with
  `vpiSize` / value field / `vpiDecompile` / `vpiConstType`, an `OVERWIDE` mark
  when the `UINT` value does not fit the size, and a `TAGGED`/`FLAT` shape line.
  Build: `g++ -O2 -std=c++17 cen59.cpp -I ~/.local/include -L ~/.local/lib64
  -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r11u59_cen59`.
* `cenrun59.sh` — the sweep driver over it (recovers each row's golden from the
  `golden cache hit` line of its `cmds.txt`).
* `pred59.py` — the golden-vs-golden OVERWIDE census, the a-priori mover
  predictor (the inverted mask join), and the flatten census.  Outputs kept as
  `CENSUS.surelog.txt` and `CENSUS.uhdm2rtlil.txt`.
* `sz59.py` — the dump-side SHAPE LISTER with the VALUE half (`sz58.py` prints
  sizes only); `shape54.py` and `sz58.py` are inherited unmodified.
* `armdiff59.sh` / `armdelta59.sh` — the per-arm order-blind residue and the
  away-move test.
* `run59.sh` — the grid runner (r11u58's `run54.sh` over this directory's arms).
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` — the current-generation battery,
  copied from `r10uvm221repro`.
