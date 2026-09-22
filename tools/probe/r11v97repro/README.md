# r11v97 — the adversarial verification of r11u97, the one AWAY it closes, and the scorer the patch shipped without

**VERDICT: ACCEPT WITH FIX.** Every headline number in the r11u97 report
reproduces on binaries this verifier built itself, including both md5s and one
of the five drop binaries. One class of **pristine-right → patched-wrong**
cells survived the implementer's grid, its census and its 8307-arm wide
boundary; it is found here by two verifier arms and closed by a sixth § block
of eleven lines. A second, separate defect is in the deliverable rather than in
the emitter: the committed `loc97v.py` is a FOUR-field reader that cannot
regenerate the FIVE-field numbers in `evidence/GRID97.score` and
`evidence/BOUNDARY97.classes`. `/tmp/r11u97.verified.patch` is what ships.

| binary | md5 | what |
|---|---|---|
| pristine | `54d56dd004635a3c0a59112c3f88e571` | built in `/tmp/wt_v11u94pris` at `fdaccc06` — the ops-brief md5 |
| law, AS DELIVERED | `457297442d61fd7c085ec369c46e3ad2` | `/tmp/r11u97.patch` on a fresh `fdaccc06` — the implementer's md5, reproduced |
| **law, VERIFIED** | `6c59dd0993310c075d8e971a8535ea15` | the same patch plus § cmpBinIsTheWidthRenderingHome97v and the scorer restore |
| chain reverted | `f0bace529e70e6bacef573703365a08c` | rebuilt independently — the implementer's drop md5, reproduced byte for byte |

---

## 1. THE DEFECT

LAW C's `BIN:` branch writes the decompile `<psym.getType().getBitWidth()>'b<v>`
unconditionally. That is golden only where `CompileHelper::adjustSize` actually
re-renders `reduceCompOp`'s one-bit answer at the declaration's width. **Two
declared types never reach that branch**, and on both of them golden keeps
`VpiSize(1)` and a decompile the law overwrites:

| package declaration | golden | pristine | r11u97 | verified |
|---|---|---|---|---|
| `time QTM = (3 < 4)` | `BIN:1 sz1` d **`1'b1`** | d `1` | d **`64'b1`** | d `1` |
| `time QTMF = (4 < 3)` | `BIN:0 sz1` d **`1'b0`** | d `0` | d **`64'b0`** | d `0` |
| `logic [2:0][3:0] CPA = (3<4)` | `BIN:1 sz1` d **`1`** | d **`1`** | d **`12'b1`** | d **`1`** |
| `logic [1:0][1:0] QPA2` | `BIN:1 sz1` d **`1`** | d **`1`** | d **`4'b1`** | d **`1`** |
| `logic [1:0][1:0][1:0] QPA3` | `BIN:1 sz1` d **`1`** | d **`1`** | d **`8'b1`** | d **`1`** |
| `typedef logic[2:0][3:0] QTPA` | `BIN:1 sz1` d **`1`** | d **`1`** | d **`12'b1`** | d **`1`** |
| `logic [2:0][3:0] QPAF = (4<3)` | `BIN:0 sz1` d **`0`** | d **`0`** | d **`12'b0`** | d **`0`** |

The five packed-array rows are **AWAY**: the PRISTINE binary is already golden
on the decompile and the law moves it off. The two `time` rows are
**MOVED-WRONG**: wrong before, differently wrong after. Arms `k1_ctype94v` and
`k7_cwidth94v`, real Surelog v1.87, every cell `slrc=0 ourrc=0 slerr=0`, read
through the net-decl-assign road.

**Scored per cell on the four fields, `nda97.py` — the implementer's own
arbiter for that road:**

| binary | arm | TO | AWAY | MWRONG |
|---|---|---|---|---|
| r11u97 as delivered | `k1_ctype94v` | 64 | **1** | **2** |
| r11u97 as delivered | `k7_cwidth94v` | 36 | **4** | **6** |
| **verified** | `k1_ctype94v` | 60 | **0** | **0** |
| **verified** | `k7_cwidth94v` | 24 | **0** | **0** |

**Why the implementer's instruments missed it.** `loc97v.py` captures a
constant with the regex `\_constant: .*line:(\d+):(\d+)` — and **golden's
packed-array constant has NO SOURCE RANGE AT ALL** (`\_constant:` bare,
measured). The view-keyed reader therefore never compared the five AWAY cells;
it reads `AWAY=0` on both arms. Only the net-name-keyed `nda97.py` sees them.
A second scorer with a different key is what convicted this, exactly as
r11v96's own §3 says.

The fix is `§ cmpBinIsTheWidthRenderingHome97v`: a whitelist of the declared
types on which the re-render was MEASURED —
a `PredefinedIntegerType` that is not `Time`, a `ScalarType`, or a
`PackedArrayType` over a `ScalarType`. Outside it the law declines and the
site writes what pristine wrote. GOLDEN WRITES NOTHING ON A MISS: the two
unmodelled renderings (`1'b<v>` for `time`, the bare digit for a
multi-dimensional packed array) are recorded as RV97-1 rather than transcribed
from two cells each. `declInt97` needs no gate — it already asks for a signed
`int` and nothing else. **The home covers every type the implementer measured**
(`int`, `integer`, `shortint`, `longint`, `byte`, `byte unsigned`,
`int unsigned`, a typedef of any of them, `bit`, `logic`, the implicit type,
`logic [3:0]`, `logic [0:7]`, `logic signed [0:0]`, `bit [7:0]`, `reg [7:0]`,
`logic signed [31:0]`, `bit signed [31:0]`, a typedef of a one-dimensional
vector): **`z3_cmpfam97` still reads TO=120 and `z6_pahome97` TO=13, unchanged.**

## 2. THE SECOND DEFECT — THE SCORER THE PATCH SHIPPED

`evidence/GRID97.score` is headed "view-keyed 5-field" and
`evidence/BOUNDARY97.classes` "five fields", and the README says `loc97v.py`
"splits the value into its PREFIX and its DIGITS". **The committed
`loc97v.py` has `FIELDS = ('v', 'ct', 'sz', 'd')` and does not split.** Run as
shipped it reads `z3` TO=105 where the evidence says 120, `z6` 12 against 13,
`v1` 9 against 10 — every arm's totals off by a factor of exactly 5/4.

Restoring the split (`FIELDS = ('vp', 'vd', 'ct', 'sz', 'd')`, the value
partitioned at its colon) reproduces **every line of `GRID97.score`,
`SWAPCTL97.score` and `BOUNDARY97.classes` exactly**, so the evidence is
sound and only the shipped file is the wrong revision. The verified patch
restores it. Without the split the boundary's `g7_add66` and `a6_misc66` cells
— golden `INT:18`/`INT:26`, pristine `UINT:17`/`UINT:13`, law `INT:17`/`INT:13`
— score as MOVED-WRONG, which is the artefact §5.9 of the pass README describes
and the shipped reader cannot avoid.

## 3. WHAT REPRODUCED, EXACTLY

* **Both md5s**, and the chain-drop binary's md5 as well
  (`f0bace529e70e6bacef573703365a08c`), each built here from a fresh
  `fdaccc06` worktree with `-j 2`.
* **The patch applies clean** to a fresh `fdaccc06` (`git apply -3` rc 0, no
  conflict marker), and its production surface is `src/EmitHelpers.h` +
  `src/ExprEmit.cpp` and nothing else — `ModuleEmit.cpp`, `ParamEmit.cpp` and
  `results/*.csv` are all ABSENT.
* **All 11 implementer arms plus 8 verifier arms, on three binaries — 52
  arm-runs, every one `slrc=0 ourrc=0 slerr=0`** (`evidence/ARMS97V.txt`).
* **The grid**, with the split restored: `z1` 34, `z2` 40, `z3` 120, `z4` 2,
  `z5` 12, `z6` 13, `v1` 10, `v5` 12, `y1`/`y2`/`y4` 0 — the implementer's
  table cell for cell, on the AS-DELIVERED binary AND on the verified one.
  `nda97.py` agrees: 34/40/105/2/12/12/9/12.
* **The census**: `ADD97 120  ADDW97 178  AGREE97 12795  BWL97 23  CMP97 19
  CMPF97 7922  UDC97 310  UNB97 208  UNBF97 28327  UNBO97 40`, 57 candidates,
  `SELFTEST PASS`, the same two unsighted negative controls. `predict97.py`
  names 27 u2r rows (including `ibex_icache`, class `ADD97`) and 26 surelog
  ones, and names none of the three surelog byteverify movers.
* **The gates**: goldens 23/0 on all three binaries and 0/23 on `/bin/false`;
  u2r `788/16/67` in six sweeps with both-mode `DIFF=0` and the testflags gate
  byte-identical; surelog `474/9 + 469/8` on all three with every histogram
  cell identical; **9969 `cmds.txt` audited by absolute binary path across
  the six sweeps — 0 name the main tree**; conversion rows `measured=13 SKIP-NOFILE=1`, every one 0 cmp
  lines / 0 heads / rc=0 on all three binaries; `canaudit` `audited=29
  UNCOVERED=0 FENCE-BREACH=0`; every protected database at its pin and
  byte-identical across pristine, law and verified in both modes.
* **Byteverify.** u2r `MOVERS 2/1608`, both `ibex_icache`, 20 diff lines per
  mode (5 `|UINT:22`→`|INT:22` + 5 `|vpiConstType:9`→`:7`), golden 19 `INT:22`
  against 3 `UINT:22` where pristine is 8/13 and the law 13/8 — **the mover is
  TO GOLDEN**, and `verified vs law` is `MOVERS 0/1608`. Surelog `MOVERS
  5/960`, a DIFFERENT DRAW on each binary, every one order-blind-attributable
  to the same single `|UINT:`/`|vpiDecompile:` pair with `|INT:` 0,
  `vpiConstType` 0, `vpiSize` 0, `Typespec` 0, `|BIN:` 0 — and one of them
  (`Scoreboard/default`) reads ZERO order-blind lines, the pure list-order coin.
* **The coin's positive control**, reproduced without a pad binary: the
  PRISTINE binary run four times on MiniAmiq/default's own invocation produced
  **four different databases**, whose order-blind diff is that same pair.
* **The wide boundary**: 8307 arms, **8059 SAME / 28 DIFFERS / 220 NODB**,
  every NODB `prc == lrc` (216 × rc=3, 4 × rc=139); **NULL boundary 28 SAME /
  0 DIFFERS**; `r11v38repro/arms/v2_paenc.sv` absent from the list, so the
  `param_assign` fence really closed it; and the 22 committed arms score
  **TO=50, AWAY=0, MOVED-WRONG=0**, identical to `BOUNDARY97.classes` line for
  line. The three page-boundary false movers read delta **exactly 4096** with
  `|INT:`/`vpiConstType`/`vpiSize`/`Typespec` all 0.
* **The chain widening earns its place.** Rebuilt with `chn97 = false`, `z1`
  falls 34→32 and `z5` 12→2 with **MOVED-WRONG 8** across the implementer's
  eight arms — their `DROP97` row exactly — and this verifier's `k8_portdf94v`
  adds 2 more.

## 4. WHAT THE VERIFIER MEASURED THAT THE IMPLEMENTER DID NOT

* **LAW C REACHES EVERY READING HOME BUT THE FENCED ONE, AND GOLDEN AGREES AT
  EVERY ONE OF THEM** (`k5_homes94v`). The implementer measured the
  `cont_assign` road and fenced `param_assign`; nothing measured the rest.
  A package parameter whose initializer is a comparison, read through a
  PROCEDURAL assignment (21:21), a FUNCTION return (24:12), a CASE item
  (36:19 and 37:22), a bit-select INDEX (29:18), an indexed part-select base
  (30:24) and a TERNARY condition (32:28) **all move, and all move TO GOLDEN**
  — golden is `INT:-1 ct7 d -1` (and `BIN:0 ct3 d 32'b0` for the false cell) at
  every one, where pristine wrote `UINT:1 ct9 d 1`. The module `localparam`
  initializer (22) and the instance PARAMETER OVERRIDE (28) do NOT move: the
  `param_assign` fence holds. TO=31, **AWAY=0, MOVED-WRONG=0** over the whole
  dump, and every non-constant home's RHS OBJECT KIND is unchanged.
* **LAW A ON THE SHARED WIDTH/RANGE ROAD IS RIGHT, AND THE MOVE IS TOWARD
  GOLDEN** (`k6_width94v`). `red72Int64` is read for widths, ranges and
  selects; put `'1 - 4294967288` under a net range bound, a packed dimension,
  an indexed part-select base, a bit-select index and a `$bits` argument, and
  golden reads the DIGIT too: `INT:-4294967287` where pristine wrote `INT:7`.
  TO=12, AWAY=0, and the range/select OBJECTS themselves are unmoved.
* **THE WIDENED NAME GUARD'S REAL BOUNDARY** (`k8_portdf94v`). The § block
  claims "an OVERRIDDEN parameter and a defaulted port still fail BOTH tests".
  A DEFAULTED PORT PARAMETER WHOSE DEFAULT IS ITSELF A DIGIT-LAW EXPRESSION
  (`parameter int SP = '1 * 2`) fails the old test and **passes the new one** —
  slang's evaluation of the default IS the store. Measured with every default
  taken and every default overridden, at the module home and the package home:
  TO=4, **AWAY=0, MOVED-WRONG=0**. The claim's wording is too strong; its
  conclusion survives.
* **THE CHAIN WIDENING OVER EVERY OTHER DIVERGING ROAD** (`k2_chain94v`): the
  `**` cast artefact (`2 ** 40`, `2 ** 63`), the shifts, a MASKED narrow store,
  a multiply past the declared width, a based HEX leaf, an enum member. Only
  two cells move (`SHLC`, `BIGDC`) and both TO golden; AWAY=0, MOVED-WRONG=0.
* **LAW B'S OPERAND PREDICATE ON TWELVE SHAPES z2 DOES NOT CARRY**
  (`k3_addop94v`): a two-hop name, a double unary minus, the based DECIMAL on
  the RIGHT, a ternary child, an explicit cast child, `$clog2` over an
  INT-minting argument, a wide add whose reduce and store disagree
  (`2147483647 * 2 + 2` golden `INT:4294967296`, pristine `UINT:0`), a 64-bit
  add and a deep add chain — TO=26/28, AWAY=0, MOVED-WRONG=0.
* **LAW A UNDER LAW C AND UNDER LAW B** (`k4_unbop94v`): `'1` on both sides of
  a comparison, under `**` either way, under `>>`, divided and modded by
  itself, at a `byte` declaration, and as the child of an INT-minting parent —
  TO=27/32, AWAY=0. `'1 >> 1` is golden UNFOLDED and stays a shape mismatch on
  both binaries, unmoved.
* **A STRING-OPERAND COMPARISON IS ON THE ROAD** (`k1_ctype94v` `CSTRC`):
  `int CSTRC = ("ab" < "ac")` is golden `INT:-1` and the law reaches it. So is
  a `$clog2` comparison, a `**` comparison and a `<<` comparison. A REAL-
  operand comparison (`(3.0 < 4.0)`) correctly declines on both binaries.

## 5. THE RESIDUES THIS VERIFICATION ADDS (ranked)

* **RV97-1 — THE TWO DECLARED TYPES THAT DO NOT RE-RENDER.** `time` is golden
  `BIN:<v> sz1` with the decompile `1'b<v>`, and a MULTI-DIMENSIONAL packed
  array (and a typedef of one) is golden `BIN:<v> sz1` with the BARE digit and
  **no source range at all**. Both are fenced here; both are two measured
  renderings away from being transcribed, and the packed-array one wants the
  no-location constant explained before anything is written there.
* **RV97-2 — `loc97v.py` CANNOT SEE A GOLDEN CONSTANT WITH NO SOURCE RANGE.**
  Its capture regex requires `line:`. That is exactly the shape of the
  packed-array cells above, and it is why a view-keyed score read `AWAY=0`
  over five real AWAY cells. Any future scorer on this road needs a second key.
* **RV97-3 — two of the 22 committed boundary arms have a golden that does not
  compile.** `r10earl60repro/vfe_v60.sv` and `r10vearl71repro/v3_enc71.sv`
  read `slrc=4 slerr=2`. Both score TO=0 AWAY=0 MWRONG=0 so nothing rests on
  them, but an arm whose GOLDEN COMPILE FAILS teaches error recovery, not
  golden, and they should be re-cut or dropped from the scored set.
* **RV97-4 — LAW A has no flag.** Every other face of the patch drops by a
  `constexpr bool` at one call site; LAW A drops only by removing its block
  from `red72Int64`. Give it one when the next digit pass touches that road.
* **The implementer's R1–R7 all stand**, re-measured here: `XPOW` still mints
  `INT:` at the top (R1); `'1 + 0` / `'1 & 3` still carry the wrong digits
  (R2); the bare `'1` / `'0` are still `INT:-1` / `UINT:0` against golden
  `UINT:4294967295` / `BIN:0` (R3); `int CCHN = CLT` is still `UINT:1`
  against golden `BIN:1 d 32'b1` (R4); the elaborated `param_assign` view still
  writes the bare digit (R5); the SIZE face is untouched throughout (R6); and
  R7 is the whole of both corpora's byteverify flag lists and of the three
  page-boundary arms.

## 6. REPRODUCING

```bash
git worktree add /tmp/wt_v11u94pris fdaccc06 && git worktree add /tmp/wt_v11u94 fdaccc06
(cd /tmp/wt_v11u94 && git apply -3 /tmp/r11u97.verified.patch)
for d in /tmp/wt_v11u94pris /tmp/wt_v11u94; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done                      # 54d56dd004635a3c…  and  6c59dd0993310c07…
# the arms: r11u97repro/grid/*.sv + r11v96repro/grid/{v1_amulbrk96v,v5_unbased96v}.sv
#           + r11u96repro/grid/{y1_muldiv96,y2_unsized96,y4_bail96}.sv
#           + r11v97repro/grid/k[1-8]_*.sv, through r11u86repro/run66.sh,
#           tags pris / lawx / fixd (SAME LENGTH), scored with r11u97repro/{nda97,loc97v}.py;
#           swap the last two arguments for the positive control.
# the corpora: verify_golden.py --corpus {uhdm2rtlil,surelog} --jobs 3, own workdirs,
#           SLANG_UHDM exported per binary; join87.py / ct8rows.sh / byteverify.sh.
# the boundary: BND_PRIS / BND_LAW / BND_ROOT=<worktree>/tools/probe / BND_OUT,
#           xargs -P 2 -n 1 bash r11u91repro/bnd72.sh < the *.sv list; NULL: BND_LAW=BND_PRIS.
# the coin control: run ONE binary four times on MiniAmiq/default's own cmds.txt invocation.
# the drop: constexpr bool chn97 = false -> f0bace529e70e6ba…, z1 32 / z5 2 / MWRONG 8.
```

Evidence: `evidence/{ARMS97V.txt, GRID97V.score, CELLS97V.txt, GATES97V.txt,
MOVERS97V.txt, BOUNDARY97V.txt, CENSUS97V.txt, DROP97V.txt}`.
