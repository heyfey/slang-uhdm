# r11u102 — the comparison is an operand, the call is its own answer, and an unknown digit is a miss

**THREE FOLD-ROAD LAWS LAND, ONE BATCH, SEVEN FLAGS, EACH DROPPABLE ALONE.**
r11v100's RV100-3, RV100-4 and RV100-5, each decoded from the producer's own
source, gridded on real Surelog v1.87 goldens, and landed on this pass's ground
(`src/EmitHelpers.h`, `src/ExprEmit.cpp`). `ParamEmit.cpp`, `ModuleEmit.cpp`,
`UhdmExporter.cpp`, `include/` and `results/` are **absent from the patch**.

| § | flag(s) | what |
|---|---|---|
| § cmpOperandUnderIntMint102 (LAW A, RV100-3) | `cmpOp102` | a COMPARISON as a direct operand of `**`, `*`, `/`, `%`, `-`, unary `-` (and of a `+` that already mints `INT:`) reduces to its digit, and the landed INT mint stands. One call site wider, as pass 97 did. |
| § ndaCallFoldIsEvalFunc102 (LAW B, RV100-4) | `ndaUser102`, `ndaClog102` | a user constant call / a `$clog2`, written as the WHOLE right-hand side of a net declaration, folds to the producer's LOCATION-LESS constant. |
| § pkgCallMintIsTheReturnMint102 (LAW B's package face, r11u100's R4) | `pkgCall102` | a package parameter initialized by a user call holds the RETURN EXPRESSION's mint, not the return type's sign. |
| § unknownOperandDeclinesFold102 (LAW C, RV100-5) | `xDecl102`, `basedX102`, `xRef102` | a `'x`/`'z` (and, own flag, a based x/z literal) under an operator leaves the producer's operation unreduced, so a read of that parameter is the `ref_obj` golden writes, not our `UINT:0`. |

Base `f2e5ebc8`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87 in `~/.local`, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68). Every golden is a real Surelog v1.87 run, every arm
records `slrc` / `ourrc` / `slerr`: **30 arms, 60 arm-runs, every one
`0 0 0`** (`evidence/ARMS102.txt`).

| binary | md5 | |
|---|---|---|
| pristine | `cea7806d57a4afa1d21a15f5a938caa0` | built in this pass's worktree at `f2e5ebc8` — the ops-brief md5 |
| **law** | `9dc12cbbe5c80a4ab754523b67d12a8b` | this patch; every sweep, arm and boundary below ran on it |
| all seven flags false | `f953869f8551ff0f5e18211961b9b9b0` | its dumps are byte-identical (path-normalised) to PRISTINE's on all 30 arms |

---

## 1. THE WITNESSES AT `f2e5ebc8`, BY NET NAME

The verifier's `v1..v4` arms were not committed; the cells were rebuilt from the
brief's text into six new arms (`grid/q1..q6`). Read through the net-decl-assign
road (golden | pristine), `evidence/CELLS102.txt`:

```
wCPC   int CPC = (3 < 4) ** 3            G INT:1  ct7              P UINT:1 ct9
wFP    wire [63:0] wFP = q2p::fp(3)      G INT:9  ct7 sz64 NO LOC  P func_call
wCL    wire [63:0] wCL = $clog2(q2p::P512)  G UINT:9 ct9 sz64 NO LOC  P sys_func_call
wPFS   int PFS = fs(4)  (fs = a + 1)     G UINT:5 ct9              P INT:5 ct7
wCPX   int CPX = 2 ** 'x                 G ref_obj q3p::CPX -> parameter   P UINT:0 ct9
```

(the SIZE face — golden `sz64` where we write the parameter's `sz32` on a
package-parameter read — is r11u91's R4, fenced in `ModuleEmit`, untouched.)

---

## 2. THE PRODUCER, DECODED

### 2.1 LAW A — the comparison under the power

`reduceExpr` reduces each operand FIRST and reads it with `get_value`
(`~/git-repos/UHDM/templates/ExprEval.cpp:3765-3785`, the power arm; the mult,
div, mod, sub and minus arms share the shape). A comparison operand reduces
through `reduceCompOp` (`ExprEval.cpp:1639`) to `BIN:<0|1>`, and `get_value`
of that string is the digit, so `(3 < 4) ** 3` IS `1 ** 3` and mints `INT:1`.
Ours: the landed `red100IntMintTop100` fires, `red72Int64` answers `Unknown` for
the comparison BY DESIGN (§ intCompareIsMinusOne97: it is read by three emitters
for widths, ranges and selects), and the site wrote slang's store as `UINT:`.

**The widening is ONE CALL SITE** — the package-parameter fold in
`ExprEmit.cpp`, where `minus94` is computed — and `red72Int64` is **byte-for-
byte unchanged**. `red102CmpOperandInt64` reads a comparison operand through the
landed `red97CompValue97` (the producer's SIGNED int64 compare, operands on the
digit roads) and the other operand through `red72Int64(inArm)`, one level deep,
with the producer's own arithmetic (the power arm is § patPowCastArtefact73's
double cast, copied, not shared). A comparison buried deeper
(`((3 < 4) * 2) ** 3`) DECLINES.

### 2.2 LAW B — the call-fold road

Surelog's netlist elaboration compiles a net-declaration RHS with `Reduce::Yes`.

* **A user call** — `CompileExpression.cpp:3208-3291` (`paSubroutine_call`):
  `if (reduce == Reduce::Yes) … result = EvalFunc(…)` (`:3267`, `:3280`),
  which is `EvalFunc.cpp:48-85` -> `ExprEval::evalFunc` (`ExprEval.cpp:6106`);
  only on `invalidValue` does the `func_call` survive.
* **A `$clog2`** — `compileClog2` (`CompileExpression.cpp:5013-5058`):
  `reduceExpr` + `get_value` on the argument, the shift loop, and
  `c->VpiValue("UINT:" + …)` (`:5043`) at `VpiSize(64)`, `vpiUIntConst`.
* **WHY NO LOCATION** — the answer is a constant minted INSIDE the reducer
  (`evalFunc`'s return value, `reduceExpr`'s operator arms, `compileClog2`'s
  `s.MakeConstant()` at `:5042`), and none of them sets a source range: of the
  68 golden cells where pristine wrote a call (`q2`, `q4`, `q5`, `q6`), **65 are
  `\_constant:` with no `line:`**. The other three are the LEAF returns —
  `fz()` = `return 7` (`wFZ`, `w1FZ`) and `fid(4)` = `return a` (`wFID`) —
  where `evalFunc` hands back the leaf's own constant and golden keeps ITS
  range (the `7` inside the body, 31:39; the actual `4`, 69:39). The law writes
  them location-less too: a span `Compare` never reads (residue R8). RV97-2
  therefore applies, and this pass scores by NET NAME (`nda102.py`).
* **WHAT `evalFunc` HANDS BACK** (`ExprEval.cpp:6319-6385`): the `return`
  statement (`:6006`) stores the REDUCED return expression; for a
  `logic_typespec` return (`:6363`) the value is MASKED to the return width
  and re-rendered `UINT:`; for any other return type the reduced constant is
  handed back AS MINTED — `INT:` for `** * / % -` and unary minus, `UINT:` for
  a `+` of UINT operands, a bare literal, a formal bound to one — and NEVER
  masked to the return type (`int fbig(10) = a ** 10` is golden
  `INT:10000000000`, `byte fby(100) = a * 2` golden `INT:200`).
* **THE NET'S WIDTH** — `adjustSize` (`CompileHelper.cpp:4065`; the UINT branch
  `:4107`) masks a `vpiUIntConst` to the net and leaves a `vpiIntConst` alone;
  the size is the net's. Measured: `[3:0] = fs(20)` golden `UINT:5 sz4`,
  `[3:0] = fm(20)` golden `INT:60 sz4`, `[0:0] = fz()` golden `UINT:1 sz1`.
  The net's width IS reachable at this site: slang wraps the net-declaration
  initializer — widening AND narrowing — in an implicit conversion to the net's
  type (measured with `slang --ast-json`: `wire [7:0] w8 = fs(300)` is
  `Conversion logic[7:0] ( Conversion logic signed[31:0] ( Call int ) )`), and
  the OUTERMOST one is the one read.

### 2.3 LAW C — the unknown operand

Surelog compiles `'x` / `'z` to `BIN:X` / `BIN:Z` at `VpiSize(-1)`
(`CompileExpression.cpp:662-681`, from `paX`/`paZ`,
`SV3_1aTreeShapeListener.cpp:874`), and a based `1'bx` / `4'hx` to an x/z digit
string. Every operator arm reads its operands with `get_value`, whose default is
`strict = true` (`~/.local/include/uhdm/ExprEval.h:97`) and whose binary parse
fails on the digit (`ExprEval.cpp:1947-1980`), so the operation is NOT reduced;
the parameter holds the unreduced operation and a read of it has no value to
substitute — golden writes a `ref_obj` to the parameter. slang converts the
4-state answer into the 2-state `int` (0), and our fold wrote that `UINT:0`. The
decline walks unary/binary operands and NAME hops (a hop propagates the
position, § redWideLeafPositionNotDepth72v); it never walks a conditional (the
untaken `'x` of `1 ? 2 : 'x` is golden `UINT:2`), a concatenation or a cast. The
ref it writes is the shape § fcArgQual33 already measured for a call argument:
`pkg::P` named `pkg::P`, bound to the package parameter, spanning the qualifier;
a bare imported `P` named `P`, bound to nothing.

---

## 3. THE GOLDEN GRID — 30 arms

Six new arms plus the 24 control arms of r11u100 (`p1..p4`), r11u97 (`z1..z6`),
r11v97 (`k1..k8`), r11v96 (`v1 v2 v5`), r11u96 (`y1 y2 y4`).

* `q1_cmppow102` — the comparison family (`< > <= >= == !=`, signed-64,
  `'1`, nested, parenthesized) x every landed operator (`** * / % - +`,
  unary `-`) x both positions, plus `&&`, `!`, `?:`, `===` and name-hop controls.
* `q2_callfold102` — 27 call bodies x return types (`int`, `int unsigned`,
  `logic [7:0]`, `longint`, `shortint`, `byte`, `integer`) x argument shapes
  (literal, pkg param, expression, module param) x readers (64/32/4/1 bits);
  eleven `$clog2` argument shapes; `$bits`, `$signed`, `f()+1`, `int'(f())`.
* `q3_xpow102` — `'x`/`'z` x 21 operators x both positions, a name hop, based
  `1'bx`/`4'hx`, the untaken ternary, the bare leaf, the 4-state declaration.
* `q4_homes102` / `q5_homes2102` / `q6_varinit102` — the homes: a child
  instance twice (one override), a parameter default, an operation operand, a
  select index, a written `assign`, an interface body, `if`/`for` generate
  blocks, variable initializers.

### 3.1 THE SCORE (`evidence/GRID102.score`)

| scorer | TO | AWAY | MOVED-WRONG |
|---|---|---|---|
| `nda102.py` — NET-NAME key, 8 fields (kind, value prefix, digits, ct, size, decompile, ref name, ref actual), per view | **800** | **0** | **0** |
| the same, tags SWAPPED (positive control) | 0 | **800** | **800** |
| `loc97v.py` — location key, 5 fields, per view | 106 | **0** | **0** |

The location scorer sees 106 of the 800 — LAW B's constants have no location and
LAW C's cells stop being constants; RV97-2's lesson, measured.

Per arm: `q1` 82, `q2` 301, `q3` 226, `q4` 106, `q5` 48, `q6` 7 — and on the
CONTROLS, only this pass's own shapes move, every one to golden:
`p4_fence100 wFBARE` `INT:5 -> UINT:5` (golden `UINT:5`, r11u100's R4);
`z3_cmpfam97 wEMUL` `UINT:2 -> INT:2`, `wESUB` `UINT:0 -> INT:0` (golden INT);
`z4_xz97 wUXS/wUZS/wUXM` constant -> `ref_obj z4p::<P>` bound to the parameter
(golden). **The other 21 control arms are byte-identical (path-normalised)
between pristine and law**: every landed value law — § pkgParamMulDivModIsIntReduce96,
§ unsizedDecLeafWrittenDigits96, § unbasedUnsizedIsOneDigit97,
§ addMintFollowsOperandMint97, § intCompareIsMinusOne97,
§ chainStoreChecksTheInitializer97, § cmpBinIsTheWidthRenderingHome97v,
§ powTopIsIntReduce100 — stands exactly where its pass left it, and the seven
r11u100 digit flags stay OFF.

### 3.2 SELECTED CELLS (full list `evidence/CELLS102.txt`; G | pristine | law)

```
LAW A  wCPCU  (64'hFFFF_FFFF_FFFF_FFFF > 1) ** 3   INT:0 | UINT:1 | INT:0   (signed compare)
       wCPCT  ('1 < 2) ** 3                        INT:1 | UINT:0 | INT:1   ('1 is the digit)
       wCMCL  (3 < 4) * 4294967296                 INT:4294967296 | UINT:0 | INT:4294967296
       wCAMC  (3 < 4) + (2 * 3)                    INT:7 | UINT:7 | INT:7
       wCAC   (3 < 4) + 1                          UINT:2 | UINT:2 | UINT:2 (control)
LAW B  wFBIG  = fbig(10)  int, a ** 10             INT:10000000000 sz64 | func_call | same as G
       wF8O   = f8o(4)    logic[7:0], a * 100      UINT:144 | func_call | UINT:144
       w4FS / w4FM  [3:0] = fs(20) / fm(20)        UINT:5 sz4 / INT:60 sz4 | func_call | same as G
       w3CL   [2:0] = $clog2(P512)                 UINT:1 sz3 | sys_func_call | UINT:1 sz3
       cFP    child u0 (N=8) / u1 (N=33) fp(N)     INT:64 / INT:1089 | func_call | same as G
       iFP    interface body fp(3)                 INT:9 | func_call | INT:9
LAW C  wCPXN  CPXN = CPX + 1 (a name hop)          ref_obj q3p::CPXN | INT:1 | ref_obj q3p::CPXN
       wCPXI  wire = CPX (imported, bare)          ref_obj CPX (no actual) | UINT:0 | same as G
       wCBXH  4'hx + 1                              ref_obj | UINT:0 | ref_obj
       wCTERNX 1 ? 2 : 'x                           UINT:2 | UINT:2 | UINT:2 (control)
```

### 3.3 WHAT IS DECLINED, MEASURED (STILL cells, never AWAY)

* LAW A: `((3 < 4) * 2) ** 3` (buried two deep), `(1 && 1) ** 3`, `(!0) ** 3`
  (logical operands — golden `INT:1`, not the comparison family), `(3 === 3) ** 3`
  (golden leaves it UNFOLDED — a `ref_obj`; `===` has no reduce arm).
* LAW B: `fasg` (assignment to the function name), `floc` (a local), `fif` (an
  `if`), `fcl` (`$clog2` inside), `fcmp` (a comparison inside) — golden folds
  all five, the single-return gate declines them; the generate-scope homes
  (`gFP`, `fFP`, `gCL`, `fCL`) — golden folds, but that NDA cell is minted in
  `ModuleEmit`'s generate emitter without `ndaRhsEmit`, the sister's ground.
* LAW C: the `param_assign` home — `parameter int P_CPX = q4p::CPX` is golden the
  parameter's unreduced OPERATION, so a `ref_obj` there would be a new wrong
  shape: the law declines (`P_CPX` stays `UINT:0`/`INT:0`); the bare leaf
  `'x` / `'z` is golden `BIN:X` / `BIN:Z` (a different value road).

---

## 4. THE LAWS, EACH DROPPABLE ALONE (`evidence/DROP102.txt`)

Eight extra builds: all seven flags false, and each flag false alone.

| drop | vs PRISTINE (30 arms, path-normalised) | its own cells (drop -> law, name key) |
|---|---|---|
| all seven | **30/30 byte-identical** | — |
| `cmpOp102` | | TO=100 AWAY=0 MWRONG=0 (`q1` 37 cells, `q4` 5, `q5` 2, `z3` 2) |
| `xDecl102` | | TO=304 AWAY=0 MWRONG=0 (`q3` 29, `q4` 5, `q5` 2, `z4` 3) |
| `basedX102` | | TO=16 AWAY=0 MWRONG=0 (`q3` `wCBX`, `wCBXH`) |
| `xRef102` | | TO=74 AWAY=0 MWRONG=0 (the ref's name + actual on LAW C's cells) |
| `ndaUser102` | | TO=266 AWAY=0 MWRONG=0 (`q2` 31, `q4` 4, `q5` 3) |
| `ndaClog102` | | TO=126 AWAY=0 MWRONG=0 (`q2` 12, `q4` 4, `q5` 1, `q6` 1) |
| `pkgCall102` | | TO=4 AWAY=0 MWRONG=0 (`p4` `wFBARE`, `q4` `wPFS`) |

---

## 5. CENSUS, A PRIORI, BY NAME — and the gates

### 5.1 THE CENSUS (`ct102cen.cpp`, `evidence/CENSUS102.txt`)

Run over **every pristine database of both corpora, both modes (2568), BEFORE
the law sweep**, keyed on the sweep's own rows. Classes, each a strict superset
of its gate:

```
A   package param, comparison as a DIRECT operand of an INT-minting op     0
B1  net-decl-assign whose Rhs is a func_call                               122  (YosysOldOpen bcd_add x4, YosysRiscv carry_save_add x57, x2 modes)
B2  net-decl-assign whose Rhs is sys_func_call $clog2                        0
B3  package param_assign whose Rhs is a func_call                           28  (EvalFuncNamed MY_PARAM2, package_task_func Z, 12 struct configs)
C   package param, x/z digit reached through operations (loose)            824  (ibex_tracer INSN_* concats, BlackBePipeInt size-casts, PackImport)
C2  the same through unary/binary operators only = the law's own walk        0
```

**POSITIVE CONTROL** — the same tool on this pass's pristine arm databases:
`q1` 37 A, `q2` 36 B1 + 12 B2, `q3` 54 C2, `q4`/`q5`/`q6` all classes;
**GOLDEN CALIBRATION** — on golden databases every B1/B2 cell the law folds
reads 0 (`q2` golden: 0 B1, 0 B2), while the 122 corpus B1 cells read the SAME
122 in golden, pristine and law (golden keeps them: their actuals are signals,
which `red72Int64` refuses).

**PREDICTION: 0 rows for every law.** B1's cells carry non-constant actuals;
B3's two integral candidates are name-assignment / recursive bodies the
single-return gate declines, the rest are struct-typed configs off the integral
fold; C's 824 go through concatenations and casts the law does not walk. A text
scan of every corpus source for a net declaration `= $clog2(` finds none (the
positive control on `q2` finds 13).

### 5.2 THE GATES (`evidence/GATES102.txt`)

1. **BUILD** — pristine `cea7806d…` = the ops-brief md5; law `9dc12cbb…`; 0
   errors, 0 new warnings (20 = 20, the same pre-existing `-Wnarrowing` lines).
2. **GOLDENS** — 23/0 on pristine and law; `SLANG_UHDM=/bin/false` 0/23.
3. **uhdm2rtlil, both modes, both binaries** — `788 / 16 / 67` in all four
   sweeps; `join87.py results/golden_uhdm2rtlil.csv` (both modes, 1742 rows)
   **DIFF=0** on both; `gate_uhdm2rtlil.csv` testflags **PASS** on both.
4. **Surelog `--mode both`, both binaries** — `474 / 9` default and
   `469 / 8` testflags, every histogram cell identical on both. The whole-row
   join names `LowMemLib`/`LowMemPkg` testflags (DETAIL = the sweep's own
   workdir path, both binaries) and, on the law sweep only, `Earlgrey_0_1`
   both modes `CMP_EQUAL/differ -> CMP_EQUAL/` (the documented uhdm-dump
   timeout draw; its DATABASE is at its pin, below). **No status moved on any
   row of either corpus. No row converts.**
5. **byteverify, SELFCHECK=1, law vs this pass's own pristine workdirs** —
   uhdm2rtlil `MOVERS 0/1608` (predicted 0), `SELFCHECK 1607/1608`;
   Surelog `MOVERS 3/960`, `SELFCHECK 959/960`: `Scoreboard/default`,
   `SeqDriver/default`, `SeqDriver/testflags` — **none predicted, all three
   the documented UVM coin** (`evidence/MOVERS102.txt`): order-blind,
   path-normalised sorted dumps differ by 0 lines (Scoreboard, the svunit ORDER
   coin) and by exactly one `|UINT:` / `|vpiDecompile:` pair (SeqDriver both
   modes: `1067 -> 1095`, `670 -> 0`), with `|INT:` 0, `vpiConstType` 0,
   `vpiSize` 0, `ref_obj` 0 — none of the fields this pass writes.
   **POSITIVE CONTROL:** the PRISTINE binary run three times on SeqDriver's own
   invocation at one output path wrote three different databases, and two of
   them differ by the same single `|UINT:` / `|vpiDecompile:` pair (`0 -> 840`):
   r11u100's R7, latent on every binary.
6. **cmds.txt AUDIT** — 3323 per sweep; 3273 name the frozen binary by absolute
   path (the other 50 are rows where Surelog failed and no slang ran); **0 name
   the main tree**.
7. **CANARIES** — Surelog `ok=50 changed=2` on the law sweep (both "changed"
   are Earlgrey's DUMP COLUMN), `ok=52 changed=0` on pristine; u2r `ok=8
   changed=0`; `ctcan2` PASS both corpora; `canaudit.sh canaries.sh ctcan2.sh`
   (the copies here) `audited=29 UNCOVERED=0 FENCE-BREACH=0`. **Every protected
   database at its pin and identical between pristine and law, both modes**:
   `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort
   59a365f3ce2c`, `BlackParrotComplex e3e354129d5a / 73a10e8217e5`,
   `YosysOldOr d68e0796d62c`, `Earlgrey_0_1 8bdf25272e08 / 59d0ee6d10c3`.
8. **CONVERSION ROWS** (official `uhdm-cmp`, golden LHS, law sweep) —
   BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, Earlgrey_0_1,
   ParamOverloading, both modes: `measured=13 SKIP-NOFILE=1` (the documented
   Scoreboard/testflags), every one **0 cmp lines / 0 heads, cmp rc=0**.

### 5.3 THE WIDE BOUNDARY (`evidence/BOUNDARY102.arms`, `.classes`)

Every `*.sv` under `tools/probe` at `f2e5ebc8`: **8463 arms — 8231 SAME, 8
DIFFERS, 224 NODB** (220 x rc=3, 4 x rc=139, every one `prc == lrc`). **NULL
BOUNDARY** (pristine vs pristine over the 8): 8 SAME / 0 DIFFERS.

* `r10buvm22repro/g22.sv` (rc=4 both), `r10uvm154repro/l154_noenum.sv`,
  `r10uvm185repro/grid185/g185_e_kinds.sv` — the documented PAGE-BOUNDARY
  address-derived `UINT` (r11u91 §5.10): law `23376985 -> 23393369` (+16384).
  **POSITIVE CONTROLS:** the ALL-FLAGS-OFF binary moves the same three by
  +4096 and nothing else; a PRISTINE build with nothing but `volatile char
  v102pad[16384]` in `uhdm_main.cpp` (`a96996f1…`) moves the same three by
  **+16416** — exactly r11u91's measurement. The value tracks the loaded image.
* `r11u100repro/grid/p4_fence100.sv`, `r11u97repro/grid/z3_cmpfam97.sv`,
  `z4_xz97.sv` — the scored controls of §3.1, every cell to golden.
* `r10v133repro/v133_e_const.sv` — `$bits(EP133)`, `EP133 = cfz133()` returning
  the literal 8: `INT:8 ct7 -> UINT:8 ct9` (§ pkgCallMintIsTheReturnMint102).
  Its golden does NOT compile (`slrc=4`, `ERR:UH0700` on a different line, 20);
  re-cut without that line the golden compiles (`slrc=0`) and holds `UINT:8
  ct9` at the cell: loc97v TO=2 AWAY=0 MWRONG=0.
* `r11v94repro/grid/x4_syncross94v.sv` — `KSF = fq(4)` (`fq` returns `a + 1`):
  the pattern member of `A` moves `INT:5 ct7 -> UINT:5 ct9` = golden; the two
  `M6` `param_assign` cells at the same start location stay `INT:5` (golden
  `UINT:5` — that home is ParamEmit's, residue R1). loc97v's START-location
  multiset merges the three and prints MOVED-WRONG=2 (`{INT,INT} -> {INT,UINT}`
  against `{UINT,UINT}`); **per cell it is 1 TO + 2 STILL, AWAY 0,
  MOVED-WRONG 0**.

### 5.4 THE SHIPPED SOURCE IS THE MEASURED SOURCE

The deliverable applied with `git apply -3` to a FRESH `f2e5ebc8` worktree and
built there independently links to `9dc12cbbe5c80a4ab754523b67d12a8b`, byte for
byte. `results/*.csv` untouched; none of the four slang-fenced names appears in
any file of the patch.

---

## 6. RESIDUES

* **R1 — THE SAME TWO RULES AT PARAMEMIT'S SITES.** LAW A and LAW B's mint are
  landed at the package-parameter READ; ParamEmit's own `param_assign` emitters
  still write the old answer: the package listing's comparison-operand cells
  (`q1` topPackages `CPC`, `CPCC`, `CPCE`, `CPCF`, `CPCG`, `CPCGE`, `CPCL`,
  `CPCN0`, `CPCP`, `CPCT`, `CPCU`, `CPCX`, `CPC8`, `CNEGF`, `CAPC`, `CPCUR`,
  `CMCL`, and the pre-existing `CNEG` `UINT:4294967295` vs golden `INT:-1` —
  22 cells), the import copy (`work@q4_homes102.CPC`), and the call mint
  (`q4p::PFS`, the module default `P_PFS` and the direct-call default `P_FP`,
  where `userFold7` writes `INT:` unconditionally). One decode, measured cells,
  ParamEmit ground (line-sensitive).
* **R2 — THE GENERATE-SCOPE AND WRITTEN-ASSIGN HOMES OF LAW B** — golden folds
  `gFP`/`fFP`/`gCL`/`fCL` (generate NDA) and the elaborated `assign aFS =
  fs(4)` is golden `UINT:5` where ModuleEmit's `callFold` writes `INT:5`
  ("a call WITH arguments keeps the signed encoding"): the same return-mint rule,
  `ModuleEmit` ground (the sister's).
* **R3 — THE BODIES THE SINGLE-RETURN GATE DECLINES** (`fasg`, `floc`, `fif`,
  `fcl`, `fcmp`): golden folds them; the value needs `evalFunc`'s statement
  interpreter, not one return expression.
* **R4 — THE OFF-TABLE OPERANDS BEYOND COMPARISONS** — `(1 && 1) ** 3`,
  `(!0) ** 3` golden `INT:1` (ours `UINT:1`); `(3 === 3) ** 3` golden
  UNFOLDED (ours `UINT:1` — a GOLDEN-WRITES-NOTHING cell); `((3<4)*2) ** 3`.
* **R5 — LAW C's `param_assign` HOME AND BARE LEAF** — `P_CPX = q4p::CPX` is
  golden the parameter's unreduced operation; `int UXB = 'x` is golden
  `BIN:X ct3` (ours `UINT:0`).
* **R6 — THE SIZE FACE** (r11u91 R4 / RV100-2): fenced in ModuleEmit, untouched.
* **R7 — THE TWO LATENT COINS** (the SeqDriver `UINT` pair, the page-boundary
  `UINT`): unchanged, both re-proven here with positive controls.
* **R8 — THE LEAF-RETURN SPAN** — a call whose body returns a bare literal or a
  bare formal is golden the LEAF's constant, carrying the leaf's range (3 of 68
  cells: `wFZ`, `w1FZ` at 31:39, `wFID` at 69:39); ours is location-less.
  Judge-invisible (no `Compare` reads a span); every field that IS read matches.

**R0 — the next pass: R1.** ParamEmit's package `param_assign` and import-copy
emitters reading `red102CmpOperandInt64` and `red102CallFold102` — the helpers
this pass ships, the grid it measured (22 + 4 cells), the census classes
(`A`, `B3`) it built. Zero corpus rows are predicted for it too, so it is a
correctness pass on the family, not a conversion.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp f2e5ebc8 && git worktree add /tmp/wtl f2e5ebc8
(cd /tmp/wtl && git apply -3 /tmp/r11u102.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm      # cea7806d… / 9dc12cbb…
  cp $d/build/slang-uhdm /tmp/$(basename $d).bin; chmod 555 /tmp/$(basename $d).bin
done
# ---- the grid: 6 new arms + 24 controls, ONE golden per arm -------------------
G=/tmp/g102 && mkdir -p $G && R=/tmp/wtl/tools/probe
cp $R/r11u102repro/grid/*.sv $R/r11u100repro/grid/*.sv $R/r11u97repro/grid/z*.sv \
   $R/r11v97repro/grid/k*.sv $G/
cp $R/r11v96repro/grid/{v1_amulbrk96v,v2_bdecbrk96v,v5_unbased96v}.sv \
   $R/r11u96repro/grid/{y1_muldiv96,y2_unsized96,y4_bail96}.sv $G/
cd $G && ls *.sv | xargs -P 3 -I{} $R/r11u102repro/grid102.sh {} pris:/tmp/wtp.bin lawx:/tmp/wtl.bin
for a in $(ls *.sv | sed 's/\.sv$//'); do                 # every arm slrc=0 ourrc=0 slerr=0
  python3 $R/r11u102repro/nda102.py $a.g.dump $a.pris.dump $a.lawx.dump | tail -1   # TO=800 total, AWAY=0
  python3 $R/r11u102repro/nda102.py $a.g.dump $a.lawx.dump $a.pris.dump | tail -1   # swap: AWAY=800
  python3 $R/r11u100repro/loc97v.py $a.g.dump $a.pris.dump $a.lawx.dump | tail -1
done
# ---- the census, on the PRISTINE sweep databases, before the law sweep --------
g++ -O2 -std=c++17 $R/r11u102repro/ct102cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct102cen
#   ct102cen <slang.uhdm> <label>   over every slang.uhdm of both pristine workdirs
# ---- sweeps: verify_golden.py --jobs 3, own --out/--workdir, SAME-LENGTH tags --
#   export SLANG_UHDM=/tmp/wtp.bin (then /tmp/wtl.bin); u2r testflags + default, surelog --mode both
#   join87.py results/golden_uhdm2rtlil.csv <tf.csv> <def.csv>      DIFF=0
#   ct8rows.sh results/golden_surelog.csv <sl.csv>
#   SELFCHECK=1 r11u91repro/byteverify.sh <law wd> <pristine wd>
# ---- drops: flip one `constexpr bool <flag> = true` in src/ExprEmit.cpp, rebuild -
# ---- boundary: BND_PRIS=… BND_LAW=… BND_ROOT=…/tools/probe BND_OUT=… \
#        xargs -P 3 -n 1 bash r11u91repro/bnd72.sh < armlist
```

Tools: `nda102.py` (the name-keyed 8-field scorer, any depth, kind as a field),
`grid102.sh` (one golden per arm, then each binary, rc recorded), `ct102cen.cpp`
(the database census), `canaries.sh` / `ctcan2.sh` / `canaudit.sh` (the current
battery, copied). Evidence: `evidence/{ARMS102.txt, GRID102.score,
CELLS102.txt, DROP102.txt, CENSUS102.txt, GATES102.txt, MOVERS102.txt,
BOUNDARY102.arms, BOUNDARY102.classes, BINARIES102.txt}`.
