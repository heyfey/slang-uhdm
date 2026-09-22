# r11v93 — ADVERSARIAL VERIFICATION of r11u93 (ACCEPT WITH FIX)

**Verdict: ACCEPT WITH FIX.**  Every headline number in the implementer's
report reproduces bit-for-bit from binaries I built myself.  Both laws are
correctly decoded from the pinned producer.  Breaking them on **19 fresh v1.87
goldens** found **three faces of LAW B mis-transcribed**, all three fixed here,
each riding the gate of the face it corrects (so every original switch still
drops its face alone, and `R11U93_OFF=1` still reproduces pristine to the
byte):

| # | what the r11u93 patch does | what golden does | arms |
|---|---|---|---|
| F1 | PREPENDS the port-declaration nets as a block | INTERLEAVES them with the body's by SOURCE ORDER | `v1_ifnetbeforeport` 23, `v10_ifportmid` 23, `v18_ifnetbeforeport_str` 22, `v15_ifdeclafterbody` (order part) |
| F2 | suppresses the mint's `vpiNetType` only when the STRENGTH law erased the body declaration | suppresses it whenever no body net declaration was walked AFTER the port declaration | `v15_ifdeclafterbody` 15 |
| F3 | lets § `ifaceDefArrayNetIsAnyUnpackedDim225` mint an ARRAY ELEMENT net for the port-declaration net | never — the producer builds that Signal with `unpackedDimension = InvalidNodeId` | `v19_ifportunpacked` **205 -> 272, the one arm the patch made WORSE ON THE JUDGE**, `v21_ifportunpacknobody` |

Deliverable `/tmp/r11u93.verified.patch`.  Surface: `src/ModuleEmit.cpp` +
`include/UhdmExporter.h` (the implementer's six lines, untouched) +
`tools/probe/r11u93repro/` (the implementer's, untouched) +
`tools/probe/r11v93repro/` (this dir).  `src/ParamEmit.cpp`,
`src/EmitHelpers.h`, `src/ExprEmit.cpp` untouched; `results/*.csv` never
written.

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `f8ea201098701fd023fe53946c621514` | my own build of `80c9a2f5` — `cmp`-identical to the main tree's `build/slang-uhdm` and to the OPS pin |
| `lawx.bin` | `406d16b57a8f6bd850da28e0d05d85ba` | the implementer's patch, unmodified — **the md5 they reported, reproduced independently** |
| `fix3.bin` | `eba9bde1c8cdf7b513038def87750379` | the patch + F1 + F2 + F3 (**the verified patch**) |

---

## 1. THE HEADLINE NUMBERS, REPRODUCED

Every one of these was re-measured, not copied.  Both binaries built `-j 2` in
my own worktrees at `80c9a2f5`, frozen `chmod 555`, every `cmds.txt` audited by
absolute binary path (0 of 1742 u2r + 0 of 960 surelog used another binary).

| claim | implementer | verifier | |
|---|---|---|---|
| pristine md5 | `f8ea2010…` | `f8ea2010…` | SAME, and `cmp`-identical to the main tree |
| law md5 | `406d16b5…` | `406d16b5…` | SAME |
| goldens | 23 PASS / 0 FAIL | 23 / 0 | SAME |
| `/bin/false` negative control | 0 / 23 | 0 / 23 | SAME |
| u2r testflags | 788 / 16 / 67 | 788 / 16 / 67 | SAME |
| u2r default | 788 / 16 / 67 | 788 / 16 / 67 | SAME |
| surelog default | 474 / 9 | 474 / 9 | SAME |
| surelog testflags | 469 / 8 | 469 / 8 | SAME |
| byteverify u2r | MOVERS 0 / 1608 | 0 / 1608 | SAME |
| byteverify surelog | MOVERS 5 / 960 | 5 / 960 | SAME, same five names |
| conversion rows | all CMP_EQUAL both modes | all CMP_EQUAL both modes | SAME on all three binaries |
| grid, pristine | 2717 cmp lines | 2717 | SAME |
| grid, law | 185 (`n11` 113 + `pa9` 72) | 185, same two arms | SAME |
| `R11U93_OFF=1` | 2717 + DBs byte-identical 53/53 | 2717 + 53/53 | SAME |
| switch ledger | 2094/215/457/215/1148/808 | identical, all six | SAME |
| the five movers' class | UINT/vpiDecompile line numbers | 4 lines each, order-blind | SAME |

The two surelog rows that differ from the committed CSV (`LowMemLib`,
`LowMemPkg`, `SURELOG_FAIL` on both sides) carry the workdir path inside the
`detail` column, and `Earlgrey_0_1`'s DUMP column reads blank in both modes on
**my pristine sweep as well as the law's** — environment, not the patch.  Law
vs my own pristine sweep: only the two workdir-path rows differ, both corpora,
both modes.

### the surelog movers, attributed FOUR ways (independently)

Three sweeps of three different patched binaries against the SAME pristine
sweep drew THREE DIFFERENT MOVER SETS out of the same family — which is the
attribution, before any dump is opened:

```
r11u93 (lawx) 5:  MiniAmiq d+tf   SeqDriver d+tf   SimpleUVM d
+F1+F2 (fix2) 4:  MiniAmiq d+tf   SeqDriver d+tf
+F3    (fix3) 5:  MiniAmiq d+tf   SeqDriver d+tf   Scoreboard d
```

1. **ORDER-BLIND** (paths normalised, ids stripped, both sides sorted):
   **exactly 4 differing lines on every `MiniAmiq`/`SeqDriver` draw**, every
   one a `UINT:`/`vpiDecompile:` LINE-NUMBER pair — the documented class — and
   **0 lines on `Scoreboard/default`**, the pure ORDER draw RESUME §9 names.
   No structural object, no vector size, no name, in any draw.
2. **TRACE**: `R11U93_NETDBG=1` fires **0** times on all five, and 0 times on
   `Scoreboard` and `BuildUVMPkg` too.  Positive control: it fires on
   `n4_nonansi_plain_if` (4 `R11U93IFMINT` lines) and on `p7_proggennda`
   (2 `R11U93PROGFLAT` + 1 `R11U93PROGGEN`).
3. **THE PRISTINE BINARY IS NONDETERMINISTIC THERE**: three consecutive runs of
   `pris.bin` on `MiniAmiq/default` gave `b5707eb2501f`, `b5707eb2501f`,
   `57c9e5c36c48` — two md5s in three runs, and **neither equals the md5 the
   same binary wrote during the sweep** (`3b108bca76c9`).

Every protected database, **law AND the fixed binary** against my own pristine
sweep, both modes: `SVSwitch 4842211c4030` SAME, `YosysVerx 6ccda350c24a` SAME,
`InterfaceModPort 59a365f3ce2c` SAME, `BlackParrotComplex e3e354129d5a` /
`73a10e8217e5` SAME, `YosysOldOr d68e0796d62c` SAME,
`Earlgrey_0_1 8bdf25272e08` / `59d0ee6d10c3` SAME.  Canaries `ok=52 changed=0`
(surelog, against my own pristine sweep) and `ok=8 changed=0` (u2r);
`ctcan2.sh` PASS on both; `canaudit.sh` PASS, FENCE-BREACH 0.  The four fenced
names: 0 occurrences in the whole verified patch.

### the gates re-run on the FIXED binary (`fix3.bin`)

goldens 23/0 (`/bin/false` 0/23); u2r 788/16/67 BOTH modes with every row-join
PASS (`results/gate_uhdm2rtlil.csv`, both modes of
`results/golden_uhdm2rtlil.csv`, and my own pristine sweep) and byteverify
**0 / 1608**; surelog 474/9 + 469/8 with only `LowMemLib`/`LowMemPkg`'s
workdir-path `detail` differing from my pristine sweep; byteverify surelog
5 / 960, all five the UVM coin, attributed above.  `cmds.txt` audit: of 1581
surelog + 1742 u2r, every one that invokes slang names `/tmp/v11u93_bin/fix3.bin`
and nothing else; the 50 that name no binary are the golden-side-only arms
(identical count in all three sweeps).

---

## 2. THE DECODE, RE-READ IN THE PINNED PRODUCER

Every citation in the implementer's report was opened and checked.  All hold:

* `CompileProgram::collectObjects_`'s `stopPoints` is
  `{paClass_declaration}` and nothing else (`CompileProgram.cpp:95-98`), and
  its switch has **no generate case** — while `collectModuleObjects_`
  (`CompileModule.cpp:529-546`) and `collectInterfaceObjects_`
  (`CompileModule.cpp:1026-1047`) both stop at every generate node.  LAW A's
  decode is exact.
* `collectInterfaceObjects_` (lines 1026-1533) contains **zero**
  `case VObjectType::paPort:` (the module's is `CompileModule.cpp:613`), so
  `setDirectionAndType`'s `found == false` arm
  (`CompileHelper.cpp:1673-1682`) pushes the same `Signal` onto
  `getPorts()` **and** `getSignals()`.  The closing dedup
  (`CompileModule.cpp:1517-1531`) only appends ports MISSING from the signal
  list.  LAW B's decode is exact.
* `mapLowConns` is called by `writeModule` (`UhdmWriter.cpp:1461`) and
  `writeProgram` (`1821`) and **not** by `writeInterface` (`1626-1794`).  Exact.

**What the decode also says, and the patch did not read** (`CompileHelper.cpp:2158-2163`):

```cpp
    Signal* portRef = nullptr;
    for (auto& port : component->getPorts()) {
      if (port->getName() == fC->SymName(signal)) {
        port->setType(fC->Type(NetType));        // <-- the mint's vpiNetType
```

The port `Signal` is typed **from the net declaration's side, as the walk
reaches it**.  Two consequences the r11u93 grid could not see, because every
one of its arms writes all its port declarations above all its body
declarations:

* the two groups are ONE source-order stream, not a front block (F1);
* a net declaration walked BEFORE the port declaration finds `getPorts()`
  empty and types nothing (F2).

And one the patch read past, four lines above the `found == false` arm it DID
read (`CompileHelper.cpp:1674-1677`): the minted Signal is built with
`/* unpackedDimension */ InvalidNodeId`, so it can never carry an array net
(F3).

---

## 3. THE VERIFIER GRID — 19 golden arms (+2 slang-rejected), all goldens regenerated by the pinned Surelog

`GRID=tools/probe/r11v93repro/grid bash tools/probe/r11u93repro/rr93.sh <bin> <tag>`
(the implementer's runner, unchanged; both rc values recorded per arm).

| arm | what it writes | pris | law | fixed |
|---|---|---|---|---|
| `v1_ifnetbeforeport` | a body `wire mid` ABOVE the port declarations | 138 | **23** | **0** |
| `v10_ifportmid` | a body `wire mid` BETWEEN the two port declarations | 138 | **23** | **0** |
| `v18_ifnetbeforeport_str` | v1 + a strength body re-declaration | 130 | **22** | **0** |
| `v15_ifdeclafterbody` | the port declarations BELOW both body declarations | 108 | **15** | **0** |
| `v19_ifportunpacked` | `output [31:0] o [2];` over `wire [31:0] o [2];` | 205 | **272** | **8** |
| `v21_ifportunpacknobody` | the same port declaration with NO body declaration | 97 | 97 | **6** |
| `v3_ifportreg` | `output reg [31:0] o;` (a VARIABLE port declaration) | 104 | 0 | 0 |
| `v12_ifmultiinst` | TWO instances of the same non-ANSI interface | 110 | 0 | 0 |
| `v17_ifinout` | an `inout` + an `input` port declaration | 110 | 0 | 0 |
| `v16_ifportdeclnetonly` | `output wire [31:0] o;`, no body re-declaration | 0 | 0 | 0 |
| `v6_proggenassign` | a standalone `assign` in a program's generate block | 56 | 0 | 0 |
| `v13_progtwogen` | two generate blocks with a body net between them | 70 | 0 | 0 |
| `v4_proggeninit` | an `initial` in a program's generate block | 78 | 57 | 57 |
| `v5_proggentask` | a function + a task in a program's generate block | 64 | 64 | 64 |
| `v11_progclass` | a class in a program's generate block | 57 | 57 | 57 |
| `v7_progforzero` | a `for (genvar i=0;i<0;i++)` in a program | 56 | 56 | 56 |
| `v14_modgeninit` | THE CONTROL: the same block in a MODULE home | 0 | 0 | 0 |
| `v2_ifportdeclnet` | `output wire o;` + a body `wire o` — SLANG rejects (`ours_rc=3`) | — | — | — |
| `v9_ifinout` | an `inout` mis-connected — SLANG rejects (`ours_rc=3`) | — | — | — |
| `v20_ifporttypedef` | a TYPEDEF-typed port declaration — SLANG rejects (`ours_rc=3`) | — | — | — |

Totals over the 18 golden arms: **pristine 1521, law 1543, fixed 248.**
`R11U93_OFF=1` on the fixed binary reads **1521** — the pristine total, to the
line — and its databases are **byte-identical to the pristine binary's on
17/17 arms** and on **53/53** of the implementer's own grid.  The fixed binary
reproduces the implementer's grid total (185) and its two residue arms exactly,
and its databases there are `cmp`-identical to the r11u93 binary's on 53/53.

The two residual arms: `v19` 8 lines and `v21` 6 lines are PRE-EXISTING faces
nothing here claims — the elaborated view's array-net ORDER (golden lists the
unpacked `o` LAST, we list it in source order) and the empty port connection
`.o()`'s `operation`.  Per-net on both: `MATCH=12/7 DIFF=0 GOLD-ONLY=0
OURS-ONLY=0`, set-wise `AWAY=0`.

### the cells, quoted

```
v1  gold work@ifc vpiNet = [mid|3:15, o|4:17, p|5:17, o|6:15, p|7:15]
    law                  = [o|4:17, p|5:17, mid|3:15, o|6:15, p|7:15]   <- mid displaced
    fixed                = [mid|3:15, o|4:17, p|5:17, o|6:15, p|7:15]   <- golden

v10 gold                 = [o|3:17, mid|4:15, p|5:17, o|6:15, p|7:15]
    law                  = [o|3:17, p|5:17, mid|4:15, o|6:15, p|7:15]

v15 gold                 = [o|3:15, p|4:15, o|5:17, p|6:17]
    law                  = [o|5:17, p|6:17, o|3:15, p|4:15]
    gold mint o@5:17     prints vpiName/vpiFullName and NOTHING else
    law  mint o@5:17     prints |vpiNetType:1                            <- a field golden lacks
```

`v15`'s `vpiNetType` is the campaign's own break rule — GOLDEN WRITES NOTHING
ON A MISS — so F2 is not a refinement, it is a correction.

### the TYPE face, all four readings that fix the rule

| arm | body declaration | golden's mint |
|---|---|---|
| `pb13_ifnoansiplainnouse` | none at all | NO `vpiNetType` |
| `pb3_ifnoredecl` | only `p` re-declared | `o` NONE, `p` `vpiNetType:1` |
| `n3_strnonansi_if` | `o` strength-erased | `o` NONE, `p` `vpiNetType:1` |
| `v15_ifdeclafterbody` | present but ABOVE the port declaration | NO `vpiNetType` |

The first three the r11u93 gate already reads correctly (the first two because
`netTypeFor` returns 0 by itself).  Only the fourth needed the widening.

---

## 4. THE FIXES

`src/ModuleEmit.cpp` only, inside `collectNetOrder93` and the two mint writers.

* **F1 — `ifPortSrcOrdOff93()` / the merge.**  `collectNetOrder93` no longer
  prepends `front`; it merges the mints into the base listing's leading
  (location-sorted) run by SOURCE LOCATION, exactly the way LAW A already
  merges a program's flattened declarations.  `R11U93_IFPORTSRCORD_OFF=1`
  restores the prepend (verifier grid: 234 -> 317), and `R11U93_OFF=1`
  restores pristine.
* **F3 — `mintNoArray93`.**  The def road's
  § `ifaceDefArrayNetIsAnyUnpackedDim225` block is skipped for a
  port-declaration mint.  THE DECODE IS IN THE SAME ARM THE MINT COMES FROM:
  `setDirectionAndType`'s `found == false` branch constructs the Signal with
  `/* unpackedDimension */ InvalidNodeId`
  (`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:1674-1677`), so
  `writeNets`' array branch (`UhdmWriter.cpp:903-943`) cannot reach it.  On
  `v19_ifportunpacked` golden's `work@ifc` lists FIVE nets — two mints, two
  body declarations, ONE element net for the BODY's array — and the r11u93
  binary wrote a SIXTH: **the only arm in this verification where the patch
  made the JUDGE worse than the base** (205 -> 272) and the only per-net
  `OURS-ONLY` it produced (0 -> 1), i.e. an object golden does not have.
* **F2 — `mintUntyped93(sym, portDeclLoc)`.**  The mint's net type is
  suppressed when the strength law erased the body declaration **or** when a
  body declaration exists and is written BEFORE the port declaration.  Both
  mint writers (def road and elab road) call it.  It is inside the existing
  `R11U93_IFPORTTYPE_OFF` face, so that switch still drops the whole TYPE rule
  alone (verifier grid: 234 -> 264).

**Blast radius, measured, not argued**: with F1+F2 the databases are
`cmp`-identical to the r11u93 binary's on **53 of 53** implementer grid arms
and differ on exactly the **4** verifier arms the fixes target.

---

## 5. THE CENSUS, RE-RUN INDEPENDENTLY

My own scanner (not the pass's), over the FULL Surelog corpus — the
implementer's source census scanned `Surelog/tests` only and left
`Surelog/third_party/tests` (11886 files) out; its conclusion survives the
wider scan:

```
Surelog/tests               files=843    iface headers=24   NON-ANSI(with port decls)=0   programs=11  with generate=0
Surelog/third_party/tests   files=11886  iface headers=203  NON-ANSI=0                    programs=16  with generate=0
uhdm2rtlil/test             files=2925   iface headers=28   NON-ANSI=0                    programs=0   with generate=0
POSITIVE CONTROL r11u93 grid  files=110  iface headers=42   NON-ANSI=36  programs=48  with generate=28
POSITIVE CONTROL r11v93 grid  files=34   iface headers=20   NON-ANSI=20  programs=12  with generate=12
```

The one header my looser first pass flagged, `tnoc_flit_if` in
`Surelog/tests/InterfType` and `InterfTypeBad`, is
`interface tnoc_flit_if (tnoc_types types);` with an EMPTY body — no port
declaration is ever walked, so no `Signal` is minted.  Its database is
byte-identical between the two binaries.

**Predicted mover set: EMPTY.  Measured: empty** (u2r 0/1608; surelog's 5 are
the UVM coin, attributed above).

---

## 6. RESIDUES (ranked) — what the next pass should take

1. **LAW A FLATTENS ONLY NETS AND VARIABLES.  THE CLASS IS WIDER THAN THE
   IMPLEMENTER'S R0.**  `CompileProgram.cpp`'s switch also has cases for
   `paInitial_construct` (:314), `paFinal_construct`, `paTask_declaration`,
   `paFunction_declaration`, `paLocal_parameter_declaration` (:257),
   `paParameter_declaration`, `paClass_declaration`, `paContinuous_assign`,
   `paAssertion_item`, `paProperty_declaration`, `paSequence_declaration` —
   and the walk descends into the generate block for ALL of them.  We drop the
   scope and re-home only `Net` and `Variable`, so everything else golden
   flattens onto the program **vanishes from our database**:

   | arm | golden puts it on the program | pristine | patched | set-wise arbiter |
   |---|---|---|---|---|
   | `v4_proggeninit` | `vpiProcess` -> `initial` | in the gen scope | NOWHERE | CONV=6 **AWAY=11** |
   | `v5_proggentask` | `vpiTaskFunc` -> `f_gen`, `t_gen` | in the gen scope | NOWHERE | CONV=0 **AWAY=14** |
   | `pa9_proggenparam` (theirs) | `vpiParameter LP` + `param_assign` | in the gen scope | NOWHERE | CONV=0 AWAY=10 |

   The JUDGE does not regress on any of them (78->57, 64->64, 72->72) and the
   per-cell arbiters are blind here (`cacell93.py` scores `cont_assign` cells
   only), so this is not an accept-blocker — but the disclosed residue is
   "the parameter"; the measured residue is **every member kind but two**, and
   it is 25 more AWAY lines than reported.  I did not fix it: the parameter
   vector is `ParamEmit.cpp` (the sister's ground), processes and task/funcs
   are outside ModuleEmit's listing code, and the obvious conservative
   alternative — dropping the scope only for blocks we can fully re-home —
   cannot be written without an allow-list that a genvar `ParameterSymbol`
   (slang models a loop genvar as one) would silently push `pa4_progfor` out of.
   **R0 for the next pass: flatten the program's generate block completely, or
   gate the drop on completeness.**

2. **A ZERO-ITERATION GENERATE LOOP IN A PROGRAM IS NOT FLATTENED**
   (`v7_progforzero`, 56 lines on both binaries).  Golden lists the loop's one
   written net (`w_loop@6:19`) because the producer walks the SYNTAX once and
   never evaluates the bound; `programGenDecls93` reads
   `GenerateBlockArraySymbol::entries[0]`, and slang leaves `entries` EMPTY
   when the loop runs zero times, so nothing is listed.  Not a regression
   (pristine listed nothing either) and corpus-invisible.  **R1.**

3. **`n11_ansistr`** (113 lines, r11v90's R0) and the pass-82/83/85/87/88/89/90/92
   residues stand unmoved on all three binaries.

4. **A HAZARD I COULD NOT REACH, recorded so nobody re-derives it.**
   `ifaceMintNet93` is cleared at the top of each interface net listing, but
   `emitInterfaceInstance` emits a NESTED interface view
   (`src/ModuleEmit.cpp:41444`) BEFORE its own port loop reads the map
   (`~41503`), so a nested emission would clear the outer view's mints.  The
   reaching shape needs an interface that has BOTH a non-ANSI net port and an
   interface-typed port; SV has no non-ANSI interface-port declaration and the
   two header styles cannot be mixed, and a header port with no port
   declaration is rejected by the pinned Surelog (`pb18_ifnodecl`,
   `golden_rc=4`), so I could not build an arm that reaches it.  The failure
   mode would be a silent revert to the base `Low_conn`, never an invention.

5. **Two front-end facts** (the implementer's, re-confirmed): a net declared
   DIRECTLY in a program's generate region segfaults the pinned Surelog
   (`pa11_proggenregion`, `golden_rc=139`), and a module instantiated in a
   program's generate block is rejected by slang while Surelog accepts it
   (`pa10_proggenmod`).

---

## 7. HOW TO RE-RUN THIS VERIFICATION

```bash
H=tools/probe/r11v93repro
GRID=$H/grid bash tools/probe/r11u93repro/rr93.sh <binary> <tag>       # the 17 arms
GRID=$H/grid bash tools/probe/r11u93repro/sw93.sh <pristine> <law>     # the ledger (R11U93_OFF must read 1219)
python3 tools/probe/r11u93repro/lister93.py  <gold.dump> <ours.dump>   # the shape lister
python3 tools/probe/r11u93repro/netcell93.py <gold.dump> <ours.dump>   # per net entry + per holder ORDER
python3 tools/probe/r11u93repro/setaway93.py <g.pris> <o.pris> <g.law> <o.law>
R11U93_IFPORTSRCORD_OFF=1 <binary> dut.sv …                            # drop F1 alone
R11U93_IFPORTTYPE_OFF=1   <binary> dut.sv …                            # drop the TYPE face (F2 included)
```
