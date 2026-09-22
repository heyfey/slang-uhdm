# r11v94 — the adversarial verification of r11u94, and the one gate it was missing

**VERDICT: ACCEPT WITH FIX.**  r11u94's three laws are decoded right at the
pinned producer and reproduce bit for bit, but LAW A fires on one shape it was
never measured on and turns a PRISTINE-RIGHT cell WRONG there.  The fix is one
predicate and one condition, `§ pkgSynConcatKeepsNoTs94v`; with it the grid
reads **TO 160 / AWAY 0 / MOVED-WRONG 0** over 24 arms and every gate is green.

| binary | md5 | what |
|---|---|---|
| pristine | `f8ea201098701fd023fe53946c621514` | built in this verifier's own worktree — byte-identical to the main tree at `80c9a2f5` and to the ops-brief md5 |
| r11u94 law (as delivered) | `9e4189217a70f8e0ac1707d564e5c4ab` | `/tmp/r11u94.patch` applied to a FRESH `80c9a2f5` and built here — **the implementer's md5, reproduced byte for byte** |
| **verified** | `80bbf8773a72f91a11e6694bef9d5f2c` | the law plus `§ pkgSynConcatKeepsNoTs94v` — the deliverable |
| LAW C reverted | `4a389a122354470270512451e75716c5` | **the implementer's drop-C md5, reproduced byte for byte** |
| 16 KB pad control | `2e92e42603e6d62dc924be0b89aef3be` | pristine source + an inert 16384-byte array, for the false-mover control |

---

## 1. THE REGRESSION, AND WHY THE LANDED GRID COULD NOT SEE IT

`red91PkgCloneHasTs91` was given `dk91 >= 1 -> true`: a kind-2 package
declaration (implicit, wearing a signing keyword or a dimension) CARRIES the
synthesized `int_typespec`, so the package answers the sign face and the
reader's declaration gets no vote.  That is right for every initializer the
r11u94 grid holds — a literal leaf, a name chain, an operation, a call, a cast.
It is WRONG whenever the initializer contains a **CONCATENATION** or a
**REPLICATION**: there the typespec never reaches the package parameter's
elaborated constant, the clone is bare, `DesignElaboration.cpp:2568`'s fill-in
runs after all and the READER votes.

Measured on real Surelog v1.87 goldens (`slrc=0 ourrc=0 slerr=0`), arms
`x4_syncross94v`, `x5_binface94v`, `x6_concatvote94v`.  `P` = pristine,
`L` = the r11u94 law as delivered, `V` = verified:

| package declaration | reader | golden | P | L | V |
|---|---|---|---|---|---|
| `signed KSK = {4'd1,4'd2}` | `logic [7:0]` | `ts=-` | `ts=-` | **`/S`** | `ts=-` |
| `signed PCD = {4'd1,4'd2}` | `logic [7:0]` | `ts=-` | `ts=-` | **`/S`** | `ts=-` |
| `signed PCH = {4'h1,4'h2}` | `logic [7:0]` | `ts=-` | `ts=-` | **`/S`** | `ts=-` |
| `signed PCB = {4'b0001,4'b0010}` | `logic [7:0]` | `ts=-` | `ts=-` | **`/S`** | `ts=-` |
| `signed PRP = {2{4'd3}}` | `logic [7:0]` | `ts=-` | `ts=-` | **`/S`** | `ts=-` |
| `signed PCN = {4'd1,4'd2} + 0` | `logic [7:0]` | `ts=-` | `ts=-` | **`/S`** | `ts=-` |
| `signed PTC = 1 ? {4'd1,4'd2} : 8'd0` | `logic [7:0]` | `ts=-` | `ts=-` | **`/S`** | `ts=-` |
| `signed PSC = {4'd1,4'd2} >> 1` | `logic [7:0]` | `ts=-` | `ts=-` | **`/S`** | `ts=-` |
| `signed PCC = PCD2` (a CHAIN) | `logic [7:0]` | `ts=-` | `ts=-` | **`/S`** | `ts=-` |
| `unsigned PCU2 = {4'd1,4'd2}` | **`signed [15:0]`** | `/S` | `/S` | **`ts=-`** | `/S` |

**BOTH FACES ARE THE SAME DECISION.**  Where the clone is bare the reader
votes, so the unsigned reader is golden BARE and the signed reader is golden
`/S`; the ungated law wrote the package's answer on both and got both wrong.
Declining the kind-2 answer in the has-a-typespec gate — which is what routes
the read back to the landed `red87StoreSigned87` — restores golden on both in
one place.

**THE WRITTEN SHAPE IS THE AXIS.**  `signed KSO = 3 + 4` keeps its typespec and
`signed PCN = {4'd1,4'd2} + 0` does not, while both are golden `sz=8 ct=9
UINT:` cells, so no reading of the VALUE, the CONST TYPE or the SIZE can
separate them.  The landed `have87 == vpiBinaryConst` decline reads OUR const
type and so catches the `'b` LEAF alone (`8'b1010`, where we also write BIN);
a concatenation is golden-binary while we write `UINT:`, and the decline misses
it.

**THE CONTROLS THAT MUST NOT MOVE, and do not:** `signed PLIT = 8'd18` is
golden `32 /S` where pristine writes `8 ts=-` — a full TO on the verified
binary; `signed PHX = 8'h1A` `8 /S`, `signed KSO = 3 + 4` `8 /S`,
`signed KSF = fq(4)` `8 /S`, `signed KSX = 8'(5)` `8 /S`, all TO; and
`signed PBL = 8'b1010` stays on the landed binary-const decline, unmoved.

## 2. THE FIX — `§ pkgSynConcatKeepsNoTs94v`, `src/EmitHelpers.h`

```
red94SynHasConcat94(syntax)   a SYNTAX walk for ConcatenationExpression /
                              MultipleConcatenation / StreamingConcatenation,
                              so every nesting is caught without enumerating
                              expression kinds
red94ExprHasConcat94(expr)    + an AST walk that follows a NAME into the
                              parameter it reads (the chain), through unary,
                              binary, conditional and conversion operands
red91PkgCloneHasTs91:  dk==2 -> !red94InitHasConcat94(Q)     (dk==1 unchanged)
```

Declining is the CONSERVATIVE direction: it restores the pristine behaviour and
never invents, so an unmeasured shape that trips the predicate loses a TO at
worst and can never become an AWAY.  `red91PkgStoreSize91` needs no change —
a concatenation is neither a `'d` vector leaf nor a name, so its existing gate
already declines, and the chain case recurses into the inner parameter.

## 3. WHAT WAS REPRODUCED, BIT FOR BIT

* **Both binary md5s**, built from the deliverable on fresh `80c9a2f5`
  worktrees: pristine `f8ea2010…` (= the main tree), law `9e418921…`.
* **The r11v91 controls at the base.**  `v5_road2way91` on the pristine binary:
  `[1] 32 INT:5 int_typespec/S`, `[2] 8 INT:5 ts=-`, `[3] 12 INT:6 ts=-`,
  `[4] 8 INT:6 ts=-`, `[5] 8 INT:13 ts=-`, `[6]` golden a `ref_obj` where we
  fold `8 INT:13` (RV91-1, untouched), `[7] 12 INT:6 ts=-`.
  `v3_negfold91`: `wNU8 G=INT:-3 ct7 sz32 d=-3` vs
  `PRIS=UINT:253 ct9 sz8 d=253`; `wNZ G=INT:0 ct7` vs `PRIS=UINT:0 ct9`.
* **The decode, at the pinned sources.**  `CompileType.cpp:1395-1437`
  (`paSigning_Signed` / `paSigning_Unsigned` / `paPacked_dimension`,
  `isVariable=false` -> `int_typespec`, `VpiSigned(true)` on the Signed arm
  alone) and `ExprEval.cpp:3407` / `:3443` (`vpiMinusOp` / `vpiSubOp` mint
  `"INT:" + std::to_string(val)` with `vpiIntConst`, `val` an unmasked
  `int64_t`; `vpiMinusOp` keeps `expr0`'s size, `vpiSubOp` stamps 64) against
  `:3260` (`vpiAddOp`, `UINT:` while both operands are unsigned constants).
  Both read and confirmed.
* **The grid.**  Every r11u94 arm keeps its exact count on the verified binary:
  `p1 32 EQ`, `p3 16 EQ`, `v1 16 EQ`, `v5 14 EQ + 2 SHAPE`, `v6 40 EQ`,
  `p4 2 TO`, `q1 22 TO`, `q2 24 TO`, `q3 26 TO`, `q7 14 TO` — the implementer's
  `GRID94.score` to the unit.
* **LAWS B/C per field:** `v3 5 / q4 24 / q5 13 / q6 20 = 62`, AWAY 0.
* **Droppability.**  A LAW-C-reverted binary built here links to
  `4a389a122354470270512451e75716c5` — the implementer's own drop-C md5 — and
  scores `3 / 18 / 9 / 12 = 42`, their table to the unit.  LAW C is therefore
  worth 20 fields and LAW B 42.
* **The instrument finding (R5) is real.**  `scripts/verify_golden.py:50` reads
  `~/git-repos/uhdm2rtlil/test`; `census91.py:265` defaults to
  `~/git-repos/uhdm2rtlil/tests`, which does not exist.
* **The census.**  `census94.py --selftest` PASS with its live negative
  control; the corpus run reads `AGREE94 12861`, 22 candidate tests;
  `predict94.py` names 20 `ibex_*` rows (u2r) and 15 Surelog rows.

## 4. THE VERIFIER'S OWN GRID — 24 arms, per cell and per field

```
TOTAL  TO=160  AWAY=0  STILL=62  WRONG2=0  EQ=309  SHAPE=2  MWRONG=0  UNPAIR=5
swap   TO=0    AWAY=160                              MWRONG=160
```

Six new arms, all `slrc=0 ourrc=0 slerr=0` on every binary:
`x1_synedge94v` (the synthesiser's edges: a hex/octal leaf under implicit
`signed`, a 64-bit literal with no dimension, a 64-bit dimension, a MULTI
packed dimension, a dimension wider than the reader, and implicit
signed/unsigned over a NEGATIVE — LAW A crossed with LAW B),
`x2_minusedge94v` (the minus family's edges), `x3_roads94v` (module, generate,
interface, function, net-decl-assign and the IMPORTED read),
`x4_syncross94v` (kind 2 over an operation, a call, a cast, a concatenation),
`x5_binface94v` and `x6_concatvote94v` (the fix's own grid).

Sharpest new golden cells:
* `signed A64 = 64'd5` is golden **`sz=32`** — `Bits` of a range-less
  `int_typespec`, not the literal's 64.  `signed [63:0] A64D = 8'd5` is 64 and
  `signed [1:0][7:0] AM = 16'd5` is 16.  The decode holds on all three.
* `logic [3:0] BN = 20 - 1` is golden **`INT:19`** under a FOUR-BIT
  declaration — the producer's `int64_t` is never masked, confirmed at the
  narrowest width the grid can write.
* `logic [127:0] B128 = -3` is golden `INT:-3` and the law reaches it.
* `unsigned AUN = -3` is golden `8 INT:-3 ts=-` and `signed ASN = -3` is
  `8 INT:-3 int_typespec/S` — the two laws meet on one cell and agree.

## 5. GATES, ALL ON THE VERIFIED BINARY

* **goldens** 23 PASS / 0 FAIL on pristine AND verified; `SLANG_UHDM=/bin/false`
  0 PASS / 23 FAIL.
* **uhdm2rtlil both modes both binaries** `788 / 16 / 67`.  The 1742-row
  both-mode whole-row join against `results/golden_uhdm2rtlil.csv` reads
  **DIFF 0 on both**, and **pristine against verified reads DIFF 0**.  The
  testflags gate against `results/gate_uhdm2rtlil.csv`: `PASS: every row
  byte-identical`.  All 3484 `cmds.txt` audited by ABSOLUTE binary path —
  1742 + 1742 name the frozen binaries, **0 name the main tree**.
* **Surelog `--mode both`, both binaries** `474 / 9` default and `469 / 8`
  testflags, every histogram cell identical.  The whole-row join against
  `results/golden_surelog.csv` names **exactly the four documented environment
  rows on BOTH binaries and no fifth** — `Earlgrey_0_1` default + testflags
  (the DUMP COLUMN, blank on BOTH binaries, the `uhdm-dump` timeout draw) and
  `LowMemLib` / `LowMemPkg` testflags (`SURELOG_FAIL`, DETAIL = the sweep's own
  workdir).  **Pristine against verified: 2 rows, both the workdir-path DETAIL.
  No status moved anywhere, in either direction.**
* **byteverify SELFCHECK=1** vs this pass's own pristine workdirs —
  u2r `MOVERS 2/1608` (ibex_icache both modes, predicted by name, verified
  TO GOLDEN against golden's own bytes), surelog `MOVERS 5/960` (the UVM coin,
  four lines each, order-blind, with a five-runs-five-databases positive
  control).  `evidence/MOVERS94V.txt`.
* **canaries / pins** — surelog `ok=50 changed=2` on BOTH binaries (the two are
  Earlgrey_0_1's dump column, and PRISTINE changes the same two), u2r
  `ok=8 changed=0 absent=0`, `ctcan2` PASS both corpora, `canaudit
  audited=29 UNCOVERED=0 FENCE-BREACH=0`.  **Every protected database at its
  ops-brief pin and byte-identical pristine <-> verified, both modes:**
  SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort
  `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a` / `73a10e8217e5`,
  YosysOldOr `d68e0796d62c`, Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`.
* **conversion rows, official `uhdm-cmp`, golden as LHS** — `measured=13
  SKIP-NOFILE=1`, every one `rc=0`, **0 cmp lines / 0 heads**: BuildUVMPkg,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, Earlgrey_0_1, ParamOverloading,
  both modes.
* **WIDE BOUNDARY**, every `*.sv` under `tools/probe`, 8217 arms:
  **7959 SAME, 42 DIFFERS, 216 NODB**, every NODB `prc == lrc`
  (212 x `rc=3`, 4 x `rc=139`).  **NULL BOUNDARY** (pristine against itself
  over all 42) reads **DIFFERS 0 / 42** — none of them is a run-to-run coin.
  THREE CLASSES: LAWS B/C (30 arms, `|INT`/`|UINT`/`vpiConstType`/
  `vpiDecompile`), LAW A (9 arms, the typespec scaffolding), and **three
  STATIC-ADDRESS FALSE MOVERS** with the 16 KB-pad positive control —
  `evidence/FALSEMOVERS94V.txt`.
  One committed boundary arm was re-measured against a fresh golden:
  `r11u38repro/grid/g2_paenc38.sv`, `parameter int unsigned NEG = 0 - 5`,
  pristine `INT:4294967291` -> verified `INT:-5`, and **golden reads `INT:-5`
  `vpiSize:32` at every one of its 15 cells** — TO GOLDEN.
* `results/*.csv` untouched; none of the four fenced names appears anywhere in
  the deliverable; `ModuleEmit.cpp` and `ParamEmit.cpp` are both ABSENT.

## 6. RESIDUES, RANKED

* **RV94-1 — `vpiMultOp`, `vpiDivOp` AND `vpiModOp` mint `INT:` too.**  The
  implementer's R0 named `*` and `/`; `%` is a third.  `int BMOD = 7 % 4` is
  golden `INT:3 ct7` where both binaries write `UINT:3 ct9` (`x2_minusedge94v`
  `wBMOD`), and `ExprEval.cpp:3479` (`vpiMultOp`) mints `INT:` in the same
  three lines as `vpiSubOp`.  `N * M` and `N / M` in a package parameter are
  far commoner in the corpus than a minus; this is the next head.
* **RV94-2 — the out-of-32-bit unsized decimal.**  `longint BLMIN =
  -9223372036854775807` is golden `INT:-9223372036854775807`; slang truncates
  the literal to 32 bits, so pristine writes `UINT:1` and the verified binary
  `INT:1`.  The const type moves TO golden and the VALUE moves wrong-to-wrong
  (`x2_minusedge94v` `wBLMIN`, the one `MOVED-WRONG` field in 24 arms).  It is
  NOT a pristine-right cell, so it is not a regression; the cure is a
  written-digits reader for the unsized decimal leaf, the analogue of the
  landed `red76BasedLeafDigits`.
* **RV94-3 — the concat class under an EXPLICIT type (kind 1).**
  `int JC = {4'd1,4'd2}` read by `logic [7:0]` is golden `ts=-` where BOTH
  binaries write `int_typespec/S` (`x6_concatvote94v` `O6`).  The same producer
  fact as `§ pkgSynConcatKeepsNoTs94v`, one kind over: pass-91's landed dk==1
  road is deliberately left alone here, and the predicate is already written
  and reusable.
* **RV94-4 — the SIZE face of LAWS B/C.**  Golden's size on the
  net-decl-assign road is 32 or 64 where ours is the reader's declared width
  (`wB128` 64 vs 128, `wBH2` 32 vs 8, `wBN` 32 vs 4).  r11u91's R4 / r11u94's
  R3, fenced, and why `nda94.py` scores per field.
* **RV94-5 — the dynamic array's range bound is a static address.**  Our
  emitter prints an uninitialized pointer-valued `UINT:` constant as the right
  range of `typedef int e_dyn[];` (g185_e_kinds.sv:46, l154_noenum.sv,
  g22.sv).  Latent on every binary, invisible to the judge today, and it is
  what makes those three arms move with binary layout.
* **RV94-6 — the binary leaf under a SIGNED reader.**  The landed
  `have87 == vpiBinaryConst` decline writes nothing rather than restoring the
  reader's vote; unmeasured, pre-existing, identical on both binaries.
* **RV94-7 — RV91-1**, `v5_road2way91` `[6]`: golden a `$unit::` `ref_obj`
  where we fold `8 INT:13`.  Untouched, as fenced.

## 7. WHAT IS IN THIS DIRECTORY

| file | what |
|---|---|
| `grid/x1_synedge94v.sv` … `x6_concatvote94v.sv` | the six verifier arms |
| `evidence/GRID94V.score` / `SWAPCTL94V.score` | the per-cell score and its swapped-tag positive control |
| `evidence/NDA94V.txt` | LAWS B/C per field, golden \| pristine \| verified |
| `evidence/DROP94V.txt` | the LAW-C-reverted binary's per-field score |
| `evidence/MOVERS94V.txt` | both corpora's movers, attributed, with the coin control |
| `evidence/FALSEMOVERS94V.txt` | the three static-address arms and the 16 KB-pad control |
| `evidence/BOUNDARY94V.classes` | the line-kind class of every differing boundary arm |
| `evidence/ARMS94V.txt` | `slrc` / `ourrc` / `slerr` for every arm run |

The drivers are r11u94's own (`run66.sh` from `r11u86repro`, `cells94.py`,
`nda94.py`, `score87v.py` from `r11u87repro`, `bnd72.sh`, `byteverify.sh`,
`canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `census94.py`, `predict94.py`) —
nothing is duplicated here.
