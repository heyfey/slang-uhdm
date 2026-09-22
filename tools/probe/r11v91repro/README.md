# r11v91 — ACCEPT-WITH-FIX. The road is the WRITTEN SCOPE, the home is a PACKAGE and only a package, and a clone with no typespec gives the reader its vote back.

**VERDICT: ACCEPT-WITH-FIX.**  r11u91's three laws are real, decoded correctly
at the producer, and every headline number reproduces bit for bit.  LAW B and
LAW C are clean as shipped.  **LAW A, as shipped, is PRISTINE-RIGHT ->
PATCHED-WRONG on legal SystemVerilog in two independent classes**, found by
breaking the law's gate against real Surelog v1.87 goldens: **AWAY 25 /
MOVED-WRONG 25 cells** on five arms the implementer's grid does not contain.
Both classes are fixed here, minimally, inside the pass's own ground; the
fixed binary scores **TO 151 / AWAY 0 / MOVED-WRONG 0 / WRONG2 0** over 65
arms and keeps every one of the implementer's 80 TO cells to the unit.

Deliverable `/tmp/r11u91.verified.patch`.  Base `0522e347`; pins per
`SUPPORT_MATRIX.md`.

| binary | md5 | what |
|---|---|---|
| pristine | `bf80949e9090df504e2cfbcf8520e1b3` | built in this verifier's own worktree — byte-identical to the main tree at the pin |
| law (as shipped) | `b082887a90d6b36b04792aaa2c78a2bd` | `/tmp/r11u91.patch` rebuilt from scratch — the implementer's md5, reproduced |
| **fixed** | `e8c67d2f1e679a87035c57afb1b98264` | this patch |
| pad control | see §5 | pristine + `volatile char v91vpad[16384]`, NO law code |

---

## 1. THE TWO BREAKS, ON REAL GOLDENS

### 1.1 THE IMPORTED NAME IS NOT THE SCOPED NAME — `v5_road2way91`

The decoded road is `CompileExpression.cpp:2729-2751`, the **`paPackage_scope`**
arm: it fires on `pkg::name`, the WRITTEN scope.  The shipped gate
(`red91HopHomeIsPackage91`) keys on the SYMBOL'S HOME instead.  A name brought
in by `import pkg::*` resolves to the same slang `ParameterSymbol` with the
same package parent scope — and golden reads the two DIFFERENTLY.  One module,
one package parameter, both readers side by side:

```
   package v5p;  localparam int KI = 16'd5;  localparam logic [11:0] KU = 16'd6;

   reader                           golden        pristine   law (shipped)
   logic [7:0] G1 = v5p::KI         32 ts/S       8  ts=-    32 ts/S   <- TO
   logic [7:0] G2 = KI   (imported)  8 ts=-       8  ts=-    32 ts/S   <- MOVED-WRONG
   logic [7:0] G3 = v5p::KU         12 ts=-       8  ts=-    12 ts=-   <- TO
   logic [7:0] G4 = KU   (imported)  8 ts=-       8  ts=-    12 ts=-   <- MOVED-WRONG
```

`G2` is wrong on BOTH fields and `G4` on the width; the pristine binary is
GOLDEN on both.  `v2_pkgroad91` `W1` is the same class.

### 1.2 `$unit` IS NOT A PACKAGE — `v5_road2way91` `G5`, `v2_pkgroad91` `W6`

The shipped `red91HopHomeIsPackage91` also accepts `SymbolKind::CompilationUnit`,
asserted from `CompileHelper.cpp:3718` and never measured.  REFUTED:

```
   localparam int KUNIT = 16'd13;          // at $unit
   logic [7:0] G5 = KUNIT       golden  8 ts=-   pristine 8 ts=-   law 32 ts/S
   logic [7:0] G6 = $unit::KUNIT golden a ref_obj — golden does not fold it at all
```

### 1.3 A CLONE WITH NO TYPESPEC LEAVES THE READER ITS VOTE — `v1_pkgsign91` `V5`

`CompileHelper.cpp:3744-3750` hangs the package parameter's declared typespec
on its elaborated constant **only when it has one**.  A PLAIN implicit package
declaration whose chain bottoms out at a LITERAL leaves the constant bare, the
clone is bare, `DesignElaboration.cpp:2568`'s fill-in DOES run, and
`valueRange`'s third argument is the READER's typespec.  The shipped law
REPLACES the declaration read unconditionally and so drops the flag:

```
   package v1p;  localparam PIMP = 16'd11;            // implicit, no typespec

   logic signed [15:0] V5 = v1p::PIMP
        golden 16 INT:11 int_typespec/S
        pristine  16 INT:11 int_typespec/S   <- ALREADY GOLDEN
        law       16 INT:11 ts=-             <- AWAY
```

The UNSIGNED reader of the same shape (`p1_pkgin91` `R5`) is bare either way,
which is why the landed grid could not see it.  `v6_scoperoad91` `N2` separates
the two faces cleanly and is the sharpest cell in the pass:

```
   logic signed [31:0] N2 = v6p::MIMP    over  localparam MIMP = 8'd5
        golden    8 int_typespec/S     the PACKAGE's width, the READER's sign
        pristine 32 int_typespec/S     sign right, width wrong
        law       8 ts=-               width right, sign wrong
        FIXED     8 int_typespec/S     both
```

---

## 2. THE FIX — three edits, all inside the pass's own ground

`§ modPkgFedHopStore91v`, `src/EmitHelpers.h` + one call site in
`src/ParamEmit.cpp`.  `src/ExprEmit.cpp` (LAW B) is NOT touched.

1. `red91HopHomeIsPackage91` drops the `CompilationUnit` arm — a Package and
   only a Package.
2. `red91InitIsScopedName91` (new): the initializer's expression syntax must be
   `SyntaxKind::ScopedName`, the established idiom at `ExprEmit.cpp:15947`.
   `red91PkgFedInner91` requires it.  A MACRO-expanded `pkg::X` still carries
   ScopedName syntax and still takes the law (`v6_scoperoad91` `N1`, golden
   `32 ts/S`, fixed `32 ts/S`).
3. `red91PkgCloneHasTs91` (new): walks the package hop's chain and answers
   whether the clone carries a typespec at all.  The SIGN call site replaces
   the landed declaration read only when it does; otherwise it falls through
   to `red87StoreSigned87`, i.e. to the pre-patch answer.  The WIDTH face is
   unchanged — `adjustSize` keeps a `vpiDecConst`'s own width whether or not a
   typespec rode along, measured on `p3_pkgsize91` `QIM`, `v1_pkgsign91` `V5`
   and `v6_scoperoad91` `N2`/`N3`.

Nothing else moves: the width-face `continue` when `red91PkgStoreSize91`
declines is behaviour-preserving against the base, because
`red89OvrStoreSize89` requires `isOverridden()` and `red91PkgFedInner91`
requires `!isOverridden()` — the base would have reached `continue` too.

---

## 3. THE GRID, 65 ARMS, PER CELL

Committed arms from r11u81/86/87/89/91 + r11v81/86/89, plus this verifier's
six.  **All 130 arm-runs read `slrc=0 ourrc=0 slerr=0`.**

| binary | TO | AWAY | MOVED-WRONG | WRONG2 |
|---|---|---|---|---|
| law (as shipped) | 138 | **25** | **25** | 0 |
| **fixed** | **151** | **0** | **0** | **0** |

Per moving arm, fixed: `p1 24  p2 10  p3 14  p4 28  w4 4` — **the
implementer's 80 to the unit** — plus `v1 12  v2 6  v4 12  v5 6  v6 35`.
As shipped the same five landed arms score identically and the verifier's arms
carry the 25 AWAY cells (`v1 2  v2 4  v5 6  v6 13`).

**THE SCORER'S POSITIVE CONTROL**: scoring the same databases with the two tags
SWAPPED turns every TO cell into AWAY *and* MOVED-WRONG — `TO=0 AWAY=116
MWRONG=116` over the nine moving arms.  `AWAY=0` is a measurement.

**EACH LAW DROPPABLE ALONE**, two further binaries built in their own fresh
`0522e347` worktrees from the VERIFIED patch's own hunks:

| binary | md5 | LAW A grid (10 arms) | `q12_ndaparamenc` (LAW B) |
|---|---|---|---|
| full (fixed) | `e8c67d2f1e67…` | TO=151 AWAY=0 MWRONG=0 | `cmp_rc 0`, heads 0 |
| LAW A reverted (ExprEmit only) | `689381e90a61f472603164e8668c41c8` | **TO=0**, AWAY=0, MWRONG=0 | `cmp_rc 0`, heads 0 |
| LAW B reverted (EmitHelpers+ParamEmit only) | `c1f0df6827ff79a773be25d640b5daef` | TO=151 AWAY=0 MWRONG=0 | **`cmp_rc 255`, heads 1, 16 cmp lines** |

The LAW-A-reverted md5 `689381e90a61…` is **the implementer's own reported
value to the byte** — independent confirmation that this fix touches nothing
on LAW B's side.  LAW C ships no production bytes; dropping it deletes a file.

`v4_pkgdepth91` pins the recursion caps: a nine-hop package chain DECLINES on
both faces (golden 24, both binaries 8 — STILL, never MOVED-WRONG), a
cross-package hop answers (`32 ts/S`, golden), an `'h` leaf declines, and the
gen-block home reads the same as the module home.

---

## 4. LAW B AND LAW C — CLEAN AS SHIPPED

`v3_negfold91`, thirteen written forms of a negative package parameter read
through the `§ pkgParamFoldWidthAlways` fold: **TO 5 / AWAY 0**, every negative
cell moving `UINT:0 ct9 -> INT:-n ct7`.  The declines are the documented ones —
an UNSIGNED declared type over `-3` (ours `UINT:253`, a VALUE residue) and `-0`
— and the POSITIVE controls (`int PP = 3` -> `UINT:3`, a const-function call
already `INT:`) do not move.  Narrow signed types (`bit signed [3:0]`,
`byte`, `logic signed [7:0]`) move the value and const type and leave the
pre-existing width residue standing alone, exactly as named a priori.
**`q12_ndaparamenc` CONVERTS on the official judge: `cmp_rc 255 -> 0`, heads
`1 -> 0`, 16 cmp lines -> 0.  It is a PROBE ARM, not a corpus row.**
`n1_pkgneg91` `MATCH 3/DIFF 12 -> MATCH 10/DIFF 4`; no cell leaves MATCH (one
DIFF cell becomes UNSCORED where the dumper abbreviates our side).  Its
whole-dump diff is **18 changed lines, 9 value + 9 `vpiConstType`, nothing
else** (the implementer's "19" counted the dump's own header line).

The census reproduces to the unit: `AGREE91 15154  OVR89 17  SGN87 4
UNR87 270  NEG91 4  NEGW91 74`, `PKI91 / WID91 / WIDL89 / CHN89` all zero,
`SELFTEST PASS` with the RV89-3 hole measured per setter (5 `WID91`-only,
2 sighted by both).  The re-keyed `PKI91` class is a SUPERSET of both the
shipped gate and the fixed one, so the a-priori mover set stays EMPTY after
the fix.  Of `NEGW91`'s 16 tests only `Earlgrey_0_1` and
`HierPathStructTypespec` produce databases (verified row by row against the
sweep CSVs); all three parameters fold POSITIVE.

---

## 5. GATES, ON THE FIXED BINARY

1. **BUILD** `-j 2`, md5 separate, both binaries frozen `chmod 555` before any
   sweep.  Pristine `bf80949e…` byte-identical to the main tree.
2. **GOLDENS** `23 PASS / 0 FAIL`; `SLANG_UHDM=/bin/false` -> `0 PASS / 23 FAIL`.
3. **uhdm2rtlil** `788 / 16 / 67` in all four sweeps; both-mode 1742-row join
   vs `results/golden_uhdm2rtlil.csv` **DIFF=0** on both binaries; testflags
   gate `PASS: every row byte-identical`.  All 1742 `cmds.txt` name the frozen
   binary by absolute path, **0 naming the main tree**.
4. **Surelog `--mode both`** `474 / 9` + `469 / 8` on both binaries, bucket
   histograms identical to the committed baseline to the unit.  Both sweeps
   draw **exactly the four documented environment rows** and the same four:
   `Earlgrey_0_1` default + testflags (DUMP COLUMN blank, status `CMP_EQUAL`,
   databases at their pins) and `LowMemLib` / `LowMemPkg` testflags
   (`SURELOG_FAIL` both sides, DETAIL embedding the sweep's own workdir).
   All 1531 `cmds.txt` audited by absolute binary path.  **The
   `YosysOpenSparc,default TIMEOUT` row the implementer reported did NOT
   recur** — sweeps run one pair at a time, which corroborates their
   environment attribution.
5. **byteverify, both corpora** — u2r `MOVERS 0 / 1608`; surelog
   `MOVERS 6 / 960`, `PATH_SETS_IDENTICAL`, `SELFCHECK 959/960`.  All six are
   the UVM coin, attributed ORDER-BLIND on path-normalised sorted dumps:
   `default/Scoreboard` moves **0 sorted lines** (a pure ORDER draw) and the
   other five each move **exactly one `UINT`/`vpiDecompile` pair holding a line
   number** — **zero `vpiSize`, zero `Typespec`, zero `vpiConstType` lines**,
   the three fields the laws write.  **COIN POSITIVE CONTROL**: the PRISTINE
   binary alone, five runs of MiniAmiq's own invocation writing to this
   verifier's OWN `-o` path, gives **five distinct databases**
   (`c8a5aa245267`, `5bf5141771a3`, `09a0fc9b894c`, `e151c32cd0f3`,
   `892e33d41868`).  No sweep database was overwritten.
6. **Canaries and pins.**  surelog `ok=50 changed=2` (the two `Earlgrey_0_1`
   dump-column cells — **the same two on the PRISTINE sweep**); u2r
   `ok=8 changed=0`; `ctcan2` PASS both corpora; `canaudit` PASS
   `audited=29 UNCOVERED=0 FENCE-BREACH=0`.  Every protected database at its
   pin AND byte-identical between pristine and fixed: SVSwitch `4842211c4030`,
   YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1
   `8bdf25272e08` / `59d0ee6d10c3`, BlackParrotComplex `e3e354129d5a` /
   `73a10e8217e5`, YosysOldOr `d68e0796d62c`.
7. **The conversion rows**, official `uhdm-cmp`, golden as LHS:
   `measured=13 SKIP-NOFILE=1 UNKNOWN-NAME=0`, every one **0 cmp lines /
   0 heads** — BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
   ParamOverloading, Earlgrey_0_1.
8. **WIDE BOUNDARY**, every `*.sv` under `tools/probe`: **8176 arms, 7918 SAME,
   42 DIFFERS, 216 NODB**, every NODB `prc == lrc` (212 x rc=3, 4 x rc=139).
   The 42 are exactly three classes and no fourth line kind:
   * **34 with real dump lines** — LAW B's `INT`/`UINT`/`vpiConstType`
     (+`vpiDecompile`) and LAW A's `int_typespec`/`ref_typespec`/`vpiSigned`/
     `vpiSize` scaffolding.  Typespec writes are **ADD-only: 118 added,
     2 removed**, and **UNEXPLAINED-REMOVALS = 0** — the only two removals in
     the whole boundary are `p1_pkgin91` at `41:43`, the `R8` cell where
     golden writes no typespec (the module's pattern and the sink's copy).
   * **8 whose DUMPS ARE IDENTICAL and whose bytes differ** only by dead
     `UINT:-<n>` serializer-string-table entries the pristine binary interned
     and nothing references (`UINT:-3`, `-4`, `-5`, `-1`, `-56`).  Measured
     with `strings | sort | diff`; judge-invisible.
   * **3 page-boundary arms** (`r10buvm22repro/g22.sv`,
     `r10uvm154repro/l154_noenum.sv`, `r10uvm185repro/grid185/g185_e_kinds.sv`)
     moving an address-derived `UINT` by **exactly 4096**
     (`23249433 -> 23253529`, and `23248577 -> 23252673` in g22).  **THE 16 KB
     PAD POSITIVE CONTROL** — a PRISTINE build carrying nothing but
     `volatile char v91vpad[16384] = {1}` appended to `uhdm_main.cpp` and NO
     law code (`a93830476c4c7d609a7a8739acd9a577`) — moves the same three from
     pristine to `23265817` / `23264961`, **exactly +16384, the pad's own
     size**, four times the law binary's page.  (The initialiser puts the array
     in `.data`, so there is no alignment tail; the implementer's `.bss`
     variant measured +16416.)  The value tracks the LOADED IMAGE, not the
     emitter's semantics.
9. `results/*.csv` UNTOUCHED.  None of the four slang-fenced names appears in
   any file of this patch and none was ever dispatched.  `ModuleEmit.cpp` is
   NOT in the patch.  Surface: `src/EmitHelpers.h`, `src/ExprEmit.cpp`,
   `src/ParamEmit.cpp`, `tools/probe/r11u91repro/`, `tools/probe/r11v91repro/`.

---

## 6. RESIDUES (r11u91's R1–R7 all stand; these are the verifier's additions)

* **RV91-1 — THE IMPORTED PACKAGE READ, unfixed by anyone.**  `logic [7:0] N =
  KI` with `import pkg::*` is golden the READER's width and BARE, which both
  the pristine and the fixed binary already write, so there is nothing to win
  — but the SIGNED imported reader is untested and the `$unit::` scoped read
  is golden a `ref_obj` where both binaries write a folded constant
  (`v5_road2way91` `G6`, a SHAPE residue on both binaries, pre-existing).
* **RV91-2 — THE PACKAGE CHAIN PAST DEPTH 8.**  `v4_pkgdepth91` `Y3`, a
  nine-hop package chain, is golden `24` (the outer hop's `Bits`) and both
  binaries write the reader's `8`.  `red91PkgStoreSize91` returns `Bits` for a
  `dk==1` hop and does not need the inner answer at all, so the cap could be
  lifted for the written-type case at no risk; no measured corpus cell wants
  it.
* **RV91-3 — THE ENUM PACKAGE HOP'S CONST TYPE.**  `logic [7:0] W4 = pkg::WE`
  over `localparam e_t WE = EB` is golden `8 INT:2 ct7` and both binaries write
  `8 UINT:2 ct9`.  The width and typespec are golden already on both; only the
  encoding is wrong, and it is the enum-read road's ground, not this pass's.

**RV91 R0: the implementer's R1 stands unchanged — the implicit-signed package
declaration's synthesized typespec width (golden 32, `getBitWidth()` 16,
ours 8), refused on both faces by `red91PkgDeclKind91` returning `-1`.**

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp 0522e347 && git worktree add /tmp/wtl 0522e347
(cd /tmp/wtl && git apply -3 /tmp/r11u91.verified.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done            # bf80949e9090…  and  e8c67d2f1e67…
# the grid: r11u91repro's §7 recipe, plus this directory's grid/*.sv, tags the
# SAME LENGTH (pris / fixd); every arm must read slrc=0 ourrc=0 slerr=0
#   TO=151 AWAY=0 WRONG2=0 MWRONG=0
# the swap control on the nine moving arms must read AWAY=116 MWRONG=116
# the negative fold: v3_negfold91.sv through both binaries, then
#   python3 nda91v.py <g.dump> <pris.dump> <fixd.dump>     # TO=5 AWAY=0
# the corpora, byteverify, canaries, conversions, boundary: r11u91repro's §7,
# with the workdir tags the same length and the sweeps run ONE PAIR AT A TIME.
```

Evidence: `evidence/{GRIDV91.fixed.score, GRIDV91.unfixed.score, CELLSV91.txt,
NEGCELLS91V.txt, BOUNDARYV91.classes}`.
