# r11u50 — § pkgSubstEncIsReduceTable50

**A SUBSTITUTED PACKAGE PARAMETER'S `INT:`/`UINT:` PICK IS
`ExprEval::reduceExpr`'S OPERATOR TABLE READ OFF THE PARAMETER'S OWN
INITIALIZER — THE SAME TABLE § rangeBoundReduceEnc33 ALREADY USES FOR THE BOUND
ITSELF, NOT THE NARROWER `paramIntEnc` MARKER.**

Base `70f84b03`. One law, three call sites, one corpus mover pair, both mode
columns scored, every gate green.

---

## 1. THE HEAD, RE-MEASURED AT THE BASE

TRIAGE2's C7 ([tools/probe/r11u44repro/TRIAGE2.md:528](tools/probe/r11u44repro/TRIAGE2.md#L528))
is **two tests, four rows, and NOT one head**: the judged field and OUR answer
are shared (`vpiConstType` 9, a plain `UINT` rendering, at a size that already
agrees) but golden's answer differs per arm. Both re-measured against the
pinned Surelog v1.87 goldens with the frozen pristine binary
(`md5 acbe2f0ed8915eb33dec990178ffd794`), one head each
(`grep -c '^LHS:'` = 1):

**Arm (a) — `ibex_icache`, 60 cmp lines, both modes**
(`ibex/rtl/ibex_icache.sv:87`, `logic [IC_TAG_SIZE-1:0] fill_tag_ic0;`, under a
`vpiSubOp` the producer does not fold):

```
LHS (golden)                         RHS (pristine)
constant  87:10-87:21                constant  87:10-87:21
|vpiParent -> operation 87:10-87:23  |vpiParent -> operation 87:10-87:23
|vpiDecompile:22  |vpiSize:32        |vpiDecompile:22  |vpiSize:32
|INT:22                              |UINT:22
|vpiTypespec -> int_typespec 396:13  |vpiTypespec -> int_typespec 396:13
|vpiConstType:7                      |vpiConstType:9
```

`ibex_pkg.sv:396` is
`parameter int unsigned IC_TAG_SIZE = ADDR_W - IC_INDEX_W - IC_LINE_W + 1;`
= 32 − 8 − 3 + 1 = 22. Full head at
[evidence/HEAD.ibex_icache.pristine.cmp](evidence/HEAD.ibex_icache.pristine.cmp).

**Arm (b) — `struct_member_cfg_width`, 64 cmp lines, both modes**
(`dut.sv:21`, `parameter cfg_pkg::cfg_t CFG = cfg_pkg::build_config()`, under a
`param_assign`): golden
`|vpiDecompile:64'b000…0011 |BIN:000…0011 |vpiConstType:3` at 64 where we write
`|vpiDecompile:274877906947 |UINT:274877906947 |vpiConstType:9`.
[evidence/HEAD.struct_member_cfg_width.pristine.cmp](evidence/HEAD.struct_member_cfg_width.pristine.cmp).

**This pass lands arm (a) ALONE.** Arm (b) decodes to a DIFFERENT producer
(§ 6), it is measured, its grid is committed, and it is R0.

---

## 2. THE PRODUCER, DECODED

A leaf that names a package parameter is replaced by the parameter's **stored
`Value`**: `CompileHelper::getValue`'s instance arm mints
`c->VpiSize(sval->getSize())` / `c->VpiConstType(sval->vpiValType())`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp`), and that stored
value is what `UHDM::ExprEval::reduceExpr`
(`~/git-repos/UHDM/templates/ExprEval.cpp`) made of the initializer. Its
per-operator arms each stamp the result themselves, and TWO landed laws already
transcribe that table in full:

* § rangeBoundReduceEnc33 (r11u33), [src/TypeEmit.cpp:18444](src/TypeEmit.cpp#L18444)
  — `vpiSubOp`/mult/div `INT` at 64 unconditionally, `vpiAddOp` `UINT` at
  `max(size)` **and the SIGNED arm instead when either reduced operand is
  vpiInt/String/Real/Dec**, the shifts and the system calls `UINT`;
* § dimExprBoundFold79 / § dimExprLeafBoundInit79v (`dimRedCt79`,
  `dimRedCtExpr79`), [src/TypeEmit.cpp:18254](src/TypeEmit.cpp#L18254) — the
  same table as a walk, with a NAME arm that follows the referenced parameter's
  own initializer and an ABSTENTION (0) on every node reduceExpr does not fold.

The substituted-leaf side, however, asked a **strictly smaller** question:
`analyzeParamEnc` ([src/ParamEmit.cpp:24085](src/ParamEmit.cpp#L24085)) marks
`paramIntEnc` only for a `/`, a `%`, a signed `**`, or a **TOP-LEVEL** `-`, and
§ defNetBoundPkgIntEnc read that marker at all three substitution sites. The
missing arms are exactly: a `-` BELOW the top, a `*`, a unary `-`, an unsigned
`**` — and, in the other direction, a shift or a bitwise arm ABOVE an
arithmetic one, where the marker fires and reduceExpr does not.

---

## 3. THE GOLDEN GRID (Surelog v1.87 = golden, every arm rc recorded)

Two grids, one package parameter per initializer SHAPE, each read once as
`logic [<P>-1:0] cNN;` so the leaf lands under a `vpiSubOp`. BOTH views are
scored: the DEF listing (`uhdmallModules`) keeps the operation with the
substituted leaf — the head's exact shape — and the ELABORATED listing folds the
whole bound. **Calibration golden-vs-golden first: g1 48 cells 0 DIFF, g2 34
cells 0 DIFF, g3 11 rows 0 DIFF.** Every arm compiled clean (`surelog rc=0`, 0
`[ERR`; our binary rc=0).

### g1 — [grid/g1_enc50.sv](grid/g1_enc50.sv), 24 cells × 2 views = 48

| cell | package parameter | golden DEF leaf | pristine | law |
|---|---|---|---|---|
| c01 | `L_LIT = 22` | `UINT:22` ct 9 | same | same |
| c02 | `L_SUB = A32 - B8` | `INT:24` ct 7 | same | same |
| **c03** | `L_SBAD = A32 - B8 - C3 + 1` | **`INT:22` ct 7** | `UINT` ct 9 | **INT ct 7** |
| c04 | `L_ADD = A32 + B8` | `UINT:40` ct 9 | same | same |
| **c05** | `L_MUL = B8 * C3` | **`INT:24` ct 7** | `UINT` ct 9 | **INT ct 7** |
| c06 | `L_DIV = A32 / B8` | `INT:4` ct 7 | same | same |
| c07 | `L_MOD = A32 % C3` | `INT:2` ct 7 | same | same |
| c08 | `L_CLOG = $clog2(A32)` | `UINT:5` ct 9 | same | same |
| c09 | `L_POW = 2 ** C3` | `INT:8` ct 7 | same | same |
| **c10** | `L_ADDR = 1 + (A32 - B8)` | **`INT:25` ct 7** | `UINT` ct 9 | **INT ct 7** |
| **c11** | `L_ADDL = (A32 - B8) + 1` | **`INT:25` ct 7** | `UINT` ct 9 | **INT ct 7** |
| c12 | `L_PAR = (A32 - B8)` | `INT:24` ct 7 | same | same |
| c13 | `L_REF = L_SUB` | `INT:24` ct 7 | same | same |
| c14 | `L_RADD = L_SUB + 1` | `INT:25` ct 7 | same | same |
| c15 | `L_RUAD = L_ADD + 1` | `UINT:41` ct 9 | same | same |
| c16 | `L_CSUB = $clog2(A32) - 1` | `INT:4` ct 7 | same | same |
| c17 | `L_SCL = A32 - $clog2(B8)` | `INT:29` ct 7 | same | same |
| **c18** | `L_NEG = -B8 + 40` | **`INT:32` ct 7** | `UINT` ct 9 | **INT ct 7** |
| **c19** | `L_MSUB = (A32 - B8) * 2` | **`INT:48` ct 7** | `UINT` ct 9 | **INT ct 7** |
| c20 | `L_DSUB = (A32 - B8) / 2` | `INT:12` ct 7 | same | same |
| **c21** | the c03 shape DECLARED `int` | **`INT:22` ct 7** | `UINT` ct 9 | **INT ct 7** |
| **c22** | the c03 shape UNTYPED | **`INT:22` ct 7** | `UINT` ct 9 | **INT ct 7** |
| **c23** | the c03 shape `logic [31:0]` | **`INT:22` ct 7** | `UINT` ct 9 | **INT ct 7** |
| c24 | `L_SSUB = S32 - B8` (signed left) | `INT:24` ct 7 | same | same |

The elaborated half of all 24 folds to `INT:<N-1>` at 64 on both sides and is
untouched. **Pristine 39/48 → law 48/48, nine cells CONVERT, 0 MOVED-WRONG, 0
AWAY.** c21/c22/c23 prove the pick is **declaration-type blind** — the same
written initializer answers `INT` under `int unsigned`, `int`, an implicit type
and `logic [31:0]` alike.

### g2 — [grid/g2_conf50.sv](grid/g2_conf50.sv), the shapes where the table and the marker DISAGREE, 17 cells × 2 views = 34

| cell | package parameter | golden DEF leaf | pristine | law |
|---|---|---|---|---|
| **d01** | `M_SHD = (A32 / B8) << 1` | **`UINT:8` ct 9** | `INT` ct 7 | **UINT ct 9** |
| d02 | `M_SHS = (A32 - B8) >> 1` | `UINT:12` ct 9 | same | same |
| d03 | `M_AND = A32 & 60` | `UINT:32` ct 9 | same | same |
| d04 | `M_ANS = (A32 - B8) & 60` | `UINT:24` ct 9 | same | same |
| d05 | `M_NEG = -B8` (read `[M_NEG+40-1:0]`) | a nested operation | same | same |
| **d06** | `M_UPW = A32 ** 1` | **`INT:32` ct 7** | `UINT` ct 9 | **INT ct 7** |
| d07 | `M_VEC = 32'd40 - 8` | `INT:32` ct 7 | same | same |
| d08 | `M_HEX = 32'h28` | `HEX:28` ct **5** | `UINT:40` ct 9 | unchanged |
| d09 | `M_XOR = A32 ^ 60` | a `ref_obj` (UNFOLDED) | `UINT:28` | unchanged |
| d10 | `M_CMP = (A32 > B8) + 39` | `UINT:40` ct 9 | same | same |
| d11 | `M_CAT = {8'd0, 8'd40}` | a `ref_obj` (UNFOLDED) | `UINT:40` | unchanged |
| d12 | `M_CST = int'(A32 - B8)` | `UINT:24` ct 9 | same | same |
| d13 | `M_TRN = A32 ? 40 : 8` | `UINT:40` ct 9 | same | same |
| **d14** | `M_CHN = M_SHD + 24` | **`UINT:32` ct 9** | `INT` ct 7 | **UINT ct 9** |
| d15 | `M_CHM = M_AND + 8` | `UINT:40` ct 9 | same | same |
| d16 | `M_BIT = $bits(A32) + 8` | `UINT:40` ct 9 | same | same |
| **d17** | `M_MUL = 5 * 8` | **`INT:40` ct 7** | `UINT` ct 9 | **INT ct 7** |

**Pristine 26/34 → law 30/34, four cells CONVERT, 0 MOVED-WRONG, 0 AWAY.**

d01 and d14 are the cells that move the OTHER way, and golden agrees with the
table both times: the marker's "a `/` anywhere ⇒ `INT`" is wrong under a shift,
because `reduceExpr`'s shift arm stamps `UINT` at 64 whatever it reduced.

**THE ABSTENTION IS THE FENCE, and the four surviving g2 cells are it.** d08 is
golden `HEX` ct 5 — the table answers `vpiHexConst`, an encoding this
decimal-digit encoder cannot spell, so it declines (the same based-literal
refusal `pkgVarDimBoundEnc82` and `ovActualStoredWidth82` already make). d09,
d11 are golden `ref_obj`: an UNFOLDED bound, a different question entirely, and
the table REFUSES `^` and a concat (returns 0). All four were wrong before the
law and are **byte-unchanged** by it.

> **VERIFIER CORRECTION (r11v50).** As first written this paragraph was true for
> three base letters out of four. `vecBaseCt79` maps `'d` to `vpiIntConst`,
> which PASSES the helper's `ct50 ==` filter, so a bare `32'd40` / `'d40`
> package parameter — and a NAME reading one — flipped from `UINT:40` ct 9 to
> `INT:40` ct 7 where golden writes a THIRD encoding, `DEC:40` **ct 1**
> (measured on real v1.87 goldens: `r11v50repro/grid/b3_dbase50.sv` e02/e03/e04
> /e05 and `b1_break50.sv` c01/c02; no cell regressed, but four bytes per cell
> moved with no golden licence). § pkgSubstEncBasedLitAbstain50v in
> `pkgSubstIntEnc50` restores the abstention through bare NAME hops, costs none
> of the thirteen conversions — `32'd32 + 8` is an ADD at the top and still
> converts — and makes the sentence above true as written. See
> [tools/probe/r11v50repro/README.md](../r11v50repro/README.md) §3.

Combined: **82 cells, pristine 65 right → law 78 right, +13, 0 MOVED-WRONG, 0
AWAY.** Scores at [evidence/GRID.g1.*.txt](evidence/) and
[evidence/GRID.g2.*.txt](evidence/).

---

## 4. WHAT WAS WRITTEN

One helper, three call sites, **no line of behaviour removed**.

* [src/TypeEmit.cpp](src/TypeEmit.cpp) — `pkgSubstIntEnc50`, the law and its
  decode, placed directly above `pkgBoundValueConst9`. It reads `paramIntEnc`
  first (the FALLBACK) and then lets `dimRedCtExpr79` — § dimExprLeafBoundInit79v's
  own walk, unchanged and not copied — overrule it **only when the table answers
  `vpiIntConst` or `vpiUIntConst`**.
* the three § defNetBoundPkgIntEnc readers now ask that one helper:
  `pkgBoundValueConst9` (the substituted constant every bound/leaf site
  shares), the def-view NET-bound arm (`~TypeEmit.cpp:14950`), and the elab PORT
  -bound arm (`~TypeEmit.cpp:5412`, § elabPortIntBound109's encoding half).
* [include/UhdmExporter.h](include/UhdmExporter.h) — the declaration and the
  one-paragraph law.

---

## 5. CENSUS, PREDICTION AND GATES

### The a-priori mover prediction, and the subset argument

[predict50.py](predict50.py) reads only SOURCES: every test one of whose files
declares, inside a `package … endpackage`, a parameter whose initializer holds
an operator the table and the marker can disagree on (a `*`, a `**`, any `-`, a
`/`, a `%`, or a NAME whose own initializer does, to a fixpoint). It is a
SUPERSET by construction — it never asks whether the parameter is ever
substituted — so the measured movers must be a SUBSET of it.

*Positive control:* run on the two grids it names every parameter whose cell
moves (`L_SBAD`, `L_MUL`, `L_ADDR`, `L_ADDL`, `L_NEG`, `L_MSUB`, `L_TINT`,
`L_TUNT`, `L_TLOG`, `M_SHD`, `M_UPW`, `M_CHN`, `M_MUL`) and none of the cells
that do not (`L_LIT`, `L_ADD`, `L_CLOG`, `L_RUAD`, `M_AND`, `M_XOR`, `M_CMP`,
`M_CAT`, `M_TRN`, `M_BIT`).

*Predicted, before the corpus sweeps:*
**u2r — a subset of 20 tests**, every `ibex_*` row (20 candidate package
parameters in `ibex_pkg.sv`, `prim_sha2_pkg.sv`; `cva6_equiv` is not a
discovered test and no `project.f` references it).
**surelog — a subset of 28 tests**: AmiqEth, Ariane, Ariane2024, ArianeElab,
ArianeElab2, AzadiRTL, BitsOp, BlackParrot, BlackParrotMuteErrors, BlackUcode,
BlackUnicore, ClassParam, ClassScope, Earlgrey, Earlgrey_0_1,
Earlgrey_Verilator_01_05_21, Earlgrey_Verilator_0_1, Earlgrey_nexysvideo,
HierPathStructTypespec, IncompTitan, Kmac, NyuziProcessor, Opentitan,
PackageParam, Rsd, SplitFile, Tnoc, Zachjs — **Earlgrey_0_1 among them**
(`flash_ctrl_pkg::FlashTotalPages = NumBanks * PagesPerBank`, a multiply the
marker never marked), so its hard byte pin was the risk this pass carried.
Lists at [evidence/PREDICT.*](evidence/).

*Measured:* **u2r MOVERS 2 / 1608 — `ibex_icache`, both modes, and nothing
else. surelog MOVERS 3 / 960 — MiniAmiq/default, SeqDriver/default,
SeqDriver/testflags, all three the documented per-invocation coin.**
Both are subsets; Earlgrey_0_1 did not move a byte.

### Mover attribution (order-blind, `uhdm-dump` sorted, workdir normalised)

Both `ibex_icache` databases carry a size delta of 0, so the size rule proves
nothing and the attribution is the sorted diff: **exactly 4 lines each**, and
they are the law's own cell —

```
<  |UINT:22            >  |INT:22
<  |vpiConstType:9     >  |vpiConstType:7
```

The three surelog movers are 4 order-blind lines each, one
`UINT`/`vpiDecompile` LINE-NUMBER pair, moving BOTH ways (0↔1506, 1162↔0,
620↔953). **POSITIVE CONTROL: the same frozen pristine binary, run a second
time, draws its own set on the same three databases — and its
`default/SeqDriver` lands on `2fb39f8b4130`, the very hash the law binary
produced.** `default/SimpleUVM` is byte-identical across both pristine runs (the
documented 0-line draw). Full attribution at
[evidence/MOVERS.attribution.txt](evidence/MOVERS.attribution.txt).

### The keyed constant census, and the SHAPE LISTER beside it

[cenc50.py](cenc50.py) keys every `constant` by (owner kind, the typespec it
refers to, `vpiSize`, value tag, `vpiConstType`) — the pair the head turns on.
Golden-vs-golden calibrates at **0 lines** on both witnesses.

* `ibex_icache`: golden 2947 constants in 60 distinct shapes; the join against
  ours has **14 differing shape rows before the law and 14 after** — the law
  moves exactly one cell inside one of them
  (`owner=operation ts=int_typespec size=32`: `INT` 6→7, `UINT` 142→141) and
  touches nothing else. The other 13 rows are residue this law does not claim.
* `struct_member_cfg_width`: golden 85 constants in 11 shapes, 8 differing rows
  before AND after — **the law does not touch this row at all**, exactly as
  arm (b)'s separate producer says it should not.

[evidence/SHAPES.*.golden.txt](evidence/) are the shape listers.

### ADVANCE vs CONVERT, predicted loudly and confirmed

**Neither row converts, and the census arithmetic said so before the sweep.**
`ibex_icache` carries 2947 golden constants against 2829 of ours across 14
differing keyed shapes; one cell cannot close that. `struct_member_cfg_width`
keeps 4 `range` constants and 2 `typespec_member` cells golden has and we do
not, on top of arm (b)'s own head. Measured after the law:
`ibex_icache` **ADVANCES** — its head moves from `ibex_icache.sv:87` to
`ibex_icache.sv:1020:45` and its cmp line count from 60 to 64 (§ 6, R0b);
`struct_member_cfg_width` is **unchanged at 64 lines**.

### The gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `acbe2f0ed8915eb33dec990178ffd794` = the main tree at the base, byte-identical; law `16656aa852b6d7701be0233ba50c147c` |
| (2) goldens | `PASS=23 FAIL=0`; `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| (3) u2r both modes | `783 CMP_EQUAL / 21 CMP_NOTEQUAL / 67 SLANG_REJECT` ×2, **every row byte-identical** to `results/gate_uhdm2rtlil.csv`, to `results/golden_uhdm2rtlil.csv` (both modes) and to my own pristine sweep |
| (4) surelog `--mode both` | `474/9` default + `469/8` testflags, status histograms identical to `results/golden_surelog.csv`; the only differing row-sides are the two `SURELOG_FAIL` detail strings that quote the WORKDIR PATH (`LowMemLib`, `LowMemPkg`), which differ between the committed baseline and my pristine control as well |
| (5) byteverify SELFCHECK=1 | u2r `MOVERS 2/1608`, SELFCHECK `1607/1608` flagged; surelog `MOVERS 3/960`, SELFCHECK `959/960` flagged; `PATH_SETS_IDENTICAL` both |
| canaries | `ok=52 changed=0 absent=0` (surelog), `ok=8 changed=0 absent=0` (u2r); `ctcan2` PASS ×2; `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| rowheads | SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg / Earlgrey_0_1 all `0 lines 0 heads`; Rggen `64 lines 1 head` (unchanged) |
| protected DBs | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1 default `8bdf25272e08` / testflags `59d0ee6d10c3`, BlackParrotComplex and YosysOldOr — every one identical to pristine |
| UVM family | BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard all still `CMP_EQUAL` |

`results/*.csv` untouched. **No row converts, so no baseline row is promoted.**

---

## 6. RESIDUES, and R0

* **R0 — ARM (b), AND IT IS THE OVERRIDE ACTUAL'S OWN ENCODING.**
  [grid/g3_asm50.sv](grid/g3_asm50.sv) puts one packed-struct parameter built by
  a member-assigning constant function in six holders and reads its
  `param_assign` Rhs. Calibration 11 rows 0 DIFF; golden vs pristine **9 SAME, 2
  DIFF**, and the split is exact:

  | holder | golden | pristine |
  |---|---|---|
  | `r50::CFG` package localparam | `BIN` ct 3, decompile BARE | same |
  | `work@tb52.u2.P` module parameter, NOT overridden | `BIN` ct 3, decompile `64'b…` | same |
  | `work@tb52.u5.L` localparam reading the package one | `BIN` ct 3, `64'b…` | same |
  | `work@tb52.u6.M` module localparam calling it | `BIN` ct 3, `64'b…` | same |
  | **`work@tb52.u3.P` OVERRIDDEN with the same call** | **`BIN` ct 3, `64'b…`** | `UINT:274877906947` ct 9 |
  | **`work@tb52.u4.P` OVERRIDDEN with `64'h0000_0020_0000_0005`** | **`HEX:0000002000000005` ct 5, `64'h…`** | `UINT:137438953477` ct 9 |

  § pkgStructFuncAssembleBin (r11u9) and § modStructFuncAssembleBin already give
  every NON-overridden holder golden's answer; the OVERRIDDEN one is written by
  the override-actual Rhs emitter, which re-decimalises. The law to write is
  **an overridden struct-typed parameter's elaborated `param_assign` Rhs carries
  the OVERRIDE ACTUAL'S OWN encoding** — the assembled `BIN:` bits when the
  actual is that member-assembling call, the literal's own base letter when it
  is a based literal. `struct_member_cfg_width` is the u3 shape exactly
  (`tb` instantiates `#(.CFG(cfg_pkg::build_config()))`), 64 cmp lines, both
  modes, unchanged by this pass. Its row also keeps 4 `range` and 2
  `typespec_member` constants golden has and we do not, so the row needs both.

* **R0b — `ibex_icache`'s NEW head, the SAME question one site over.**
  `ibex_icache.sv:1020` `{IC_LINE_BEATS{fill_hit_q[i]}}` — a REPLICATION COUNT
  inside a statement. `ibex_pkg.sv:392` is
  `IC_LINE_BEATS = IC_LINE_BYTES / BUS_BYTES`, a DIVIDE, which even the old
  marker marks; golden writes `INT:2` ct 7 and we write `UINT:2` ct 9, so that
  producer consults NEITHER predicate and hard-writes `UINT:`. It is the fourth
  site of the substitution family (after the dimension bound, the `param_assign`
  and the operation leaf this pass closed) and the next one-liner in the chain
  — but the row is far from converting: 14 differing keyed constant shapes,
  2947 golden constants against 2829 of ours.

* **R1 — d08, the based-literal package parameter.** `32'h28` read at a bound is
  golden `HEX:28` ct 5, and this decimal-digit encoder cannot spell it. The
  table already knows the answer (`vecBaseCt79` returns `vpiHexConst`); what is
  missing is a renderer, not a decode. Deliberately declined: the same refusal
  `pkgVarDimBoundEnc82` and `ovActualStoredWidth82` both make, and guessing
  moves a wrong cell to a differently wrong one.

* **R2 — d09 / d11, the bounds golden does NOT fold.** `M_XOR = A32 ^ 60` and
  `M_CAT = {8'd0, 8'd40}` keep a `ref_obj` in golden's def listing where we
  substitute a value. That is a FOLD question, not an encoding one — `reduceExpr`
  has no arm for either — and it is pre-existing, untouched, and a different
  family's road.

---

## 7. REPRODUCING

```bash
# the grids (both producers, rc recorded; CALIBRATE first)
cd <scratch> && cp <repo>/tools/probe/r11u50repro/grid/g1_enc50.sv .
~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv -d uhdm g1_enc50.sv
$SLANG_UHDM g1_enc50.sv --single-unit -o ours.uhdm
uhdm-dump slpp_all/surelog.uhdm > g.raw; uhdm-dump ours.uhdm > o.raw
python3 - <<'EOF' > names.txt          # declLine cellName, g1 starts at 38
for i in range(1, 25): print('%d c%02d' % (37 + i, i))
EOF
python3 gread50.py g.raw g.raw names.txt | tail -1      # CALIBRATION: DIFF 0
python3 gread50.py g.raw o.raw names.txt                # the 24x2 grid
# g2 is the same with `28 + i` and 17 cells; g3 uses asmread50.py (no names file)

# the keyed constant census + the SHAPE LISTER
python3 cenc50.py g.raw g.raw CALIB        # must print LINES 0
python3 cenc50.py g.raw o.raw <test>
python3 cenc50.py --shape g.raw

# the a-priori prediction and its positive control
python3 predict50.py ~/git-repos/uhdm2rtlil/test
python3 predict50.py --files grid/g1_enc50.sv grid/g2_conf50.sv
```
