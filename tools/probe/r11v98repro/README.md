# r11v98 — adversarial verification of r11u98, and the one shape it got wrong

**VERDICT: ACCEPT WITH FIX.**  Every headline number in r11u98's report
reproduces bit-for-bit from a fresh `cc9efa23` in this verifier's own
worktrees, with binaries this verifier built.  Thirty-one purpose-built
adversarial arms on real v1.87 goldens found exactly one shape in which the
patch writes an object golden does not have — an interface that falls through
to the module emission path — and this pass ships the one-predicate fix inside
LAW B1's own gate.

Base `cc9efa23`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil v0.68).

| binary | md5 | what |
|---|---|---|
| pristine | `bad3448ad7399ab90d528c9b0801d239` | built by this verifier at `cc9efa23`, `-j 2`; **`cmp`-identical** to the main tree's `build/slang-uhdm` and to the OPS pin |
| r11u98 as submitted | `422d5feeec51c70674a26906c8311aea` | `/tmp/r11u98.patch` applied to a FRESH `cc9efa23` (2 `M` + 47 `A`, 0 conflicts) and rebuilt — **bit-for-bit the md5 the implementer claimed** |
| r11u98 + this fix | `534aa1d5c630bc1530e15a30341eb6fa` | what `r11u98.verified.patch` builds |

Both frozen `chmod 555` before any sweep; every `cmds.txt` audited by absolute
binary PATH (u2r 1742 + 1742 + 1742, surelog 1581 + 1581 + 1581 — the only
`slang-uhdm` path in each set that is not the golden cache is the frozen
binary that sweep was meant to run).  `src/ParamEmit.cpp`, `src/EmitHelpers.h`
and `src/ExprEmit.cpp` untouched.  `results/*.csv` never written.

---

## 1. THE FIX — § `caModGenClassNotIfaceHome98V`

`src/ModuleEmit.cpp`, inside LAW B1's own gate, so LAW B1 stays droppable
alone and `R11U98_OFF=1` still drops everything.

```
-        if (m->UhdmType() == UHDM::uhdmmodule_inst) {
+        if (m->UhdmType() == UHDM::uhdmmodule_inst) {
+            const bool ifaceHome98V = inst.isInterface();
...
-                        if (!modGenClassOff98())
+                        if (!modGenClassOff98() && !ifaceHome98V)
                             clist95.push_back(&mem.as<ClassType>());
```

**Why.**  `UhdmType() == uhdmmodule_inst` is NOT "this home is a module".
`useInterfacePath` is `isInterface() && isSimpleInterfaceBody(body)`
(`src/EmitHelpers.h:2890-2910`), and `isSimpleInterfaceBody` is FALSE for an
interface that holds a CHILD INSTANCE — such an interface is emitted through
`emitModuleDef` and reaches LAW B1's block wearing a `module_inst`.  Golden
still files ITS classes at the DESIGN ROOT with a null container, because
`ResolveSymbols::createFastLookup`
(`~/git-repos/Surelog/src/DesignCompile/ResolveSymbols.cpp:79-90`) has no
`paInterface_declaration` case and does not stop there — LAW B2's own road.

**Measured, on a real v1.87 golden** (`grid/v27_ifacenestinst`:
`interface outer (); inner u_in (); generate if (1) begin : g class Cgen; ...`
— legal SV, `ours_rc=0` on both binaries):

| | pristine | r11u98 as submitted | r11u98 + fix |
|---|---|---|---|
| CELL OURS-ONLY | **0** | **1** — `class_defn (work@outer::Cgen)` on `work@outer` | **0** |
| SUBTREE OURS-ONLY | 0 | 1 | 0 |
| CELL GOLD-ONLY | 1 (`work@Cgen` at the design root) | 1 | 1 |
| database | — | — | **byte-identical to the pristine binary's** |

That is the one pristine-right → patched-wrong shape in 31 arms.  `uhdm-cmp`
cannot see it (the interface-emitted-as-module kind divergence masks it: 260
cmp lines either way), which is exactly why the set-wise arbiter is carried
beside the judge.

**The fix is inert everywhere else**: across r11u98's own 20-arm grid and all
30 buildable arms of this verifier's grid, the fixed binary's databases are
`cmp`-identical to the submitted binary's on **49 of 50** arms — the one
exception being `v27` itself.  The three control grids are unchanged
(§4).

The trace stays a SUPERSET predictor: `R11U98MODGENCLASS` still fires on the
guarded site and now carries `iface=1`, so no census can go blind on this
shape.  `cellcen98.py` matches on `startswith`, so the added field is
compatible.

---

## 2. REPRODUCED, BIT FOR BIT

Every number below was re-measured by this verifier; none is carried forward.

### 2a. the five committed witnesses at `cc9efa23`

`g1_progclassnames` **46** · `g2_modclassnames` **46** · `h1_modgenclass`
**70** · `h4_modfinalgen` **29** · `h3_ifacegentask` **318** — all five
exactly as the brief states, `golden_rc=0 ours_rc=0` on every arm, and all
five read **0** on the law binary and on the fixed binary.

### 2b. the switch ledger (r11u98's 20-arm grid, this verifier's runs)

| switch | total | claimed |
|---|---|---|
| pristine | **1797** | 1797 |
| law, all on | **159** | 159 |
| `R11U98_OFF=1` | **1797** | 1797 |
| `R11U98_CLASSKEY_OFF=1` | **481** | 481 |
| `R11U98_MODGENCLASS_OFF=1` | **531** | 531 |
| `R11U98_IFACECLASS_OFF=1` | **1120** | 1120 |
| `R11U98_GENFINAL_OFF=1` | **188** | 188 |

`R11U98_OFF=1` on the FIXED binary reproduces the pristine database **BYTE
FOR BYTE on 50/50 arms** of both grids (r11u98's 20 + this verifier's 30).

### 2c. the control grids

| grid | arms | pris | fix | databases `cmp`-identical | movers |
|---|---|---|---|---|---|
| r11u95 | 35 | **171** | **72** | **33/35** | `c10_modgenclass`, `c8_modfinalgen` |
| r11v95 | 30 | **932** | **522** | **27/30** | `x17_ifacegentask`, `x30_progclassnames`, `x31_modclassnames` |
| r11u93 | 53 | **185** | **185** | **53/53** | none |

The residual nonzero arms are exactly the documented residues and nothing
else: `a20_proggenparam` 72 (r11u95 R0, fenced in `src/ParamEmit.cpp` — the
sister's ground), `x12_proggenimportfn` 203 + `x26_progimportbodyfn` 241 (R3),
`x2_proggenassert` 64 (R4), `x8_proggendupname` 14 (R5).  **The landed
pass-93/95 flattening laws and the three verifier fixes are untouched.**

### 2d. the decode, checked line by line in the pinned sources

* `StringViewCompare::operator()` is a bare `a < b`,
  `ClassNameClassDefinitionMultiMap = std::multimap<std::string,
  ClassDefinition*, StringViewCompare>` — `Surelog/include/Surelog/Common/Containers.h:12-18,33-34`. **CONFIRMED.**
* `writeClasses` walks that map straight into `m->Class_defns(dest_classes)`,
  `UhdmWriter.cpp:1077-1084`, `:1465` module, `:1848` program. **CONFIRMED.**
* `createFastLookup`'s file walk: `types` include `paInterface_declaration`,
  `stopPoints` do NOT; the module case collects with stop set
  `{paClass_declaration, paModule_declaration}` and files the bare `name` on
  the module (`:194`); the program case stops only at a class (`:156`); an
  interface falls to `default:` and collects nothing; a file-scope class is
  built with a **null container** (`:160-166`).
  `ResolveSymbols.cpp:72-210`. **CONFIRMED.**
* the design-root filter `if (!c->VpiParent()) writeClass(...)`,
  `UhdmWriter.cpp:5181-5194`, over `m_design->getClassDefinitions()` fed by
  `CompileDesign.cpp:272-277`. **CONFIRMED.**

The brief's two framings that r11u98 corrected are both correct as corrected:
`h1`'s golden dump carries **zero** `uhdmallClasses` lines, and `c8`/`h4` is a
missing `final_stmt` subtree, not a naming face.

### 2e. the class listing has exactly one writer per home

`Class_defns(` is written in four places only — the builtin package
(fixed list), `emitPackageClasses` (already name-sorted, and it is the
precedent for R0's `getDefaultSpecialization`), and the def-view block LAW A
now sorts.  **There is no elaborated-view class listing**, so LAW A's reach is
complete; `g2`/`v24` (a child instance and a top) both convert to 0.

---

## 3. THE ADVERSARIAL GRID — 31 arms, every golden regenerated by Surelog v1.87

`grid/` holds every source; `rr98.sh` runs them (both rc values per arm).
**23 arms CONVERT to 0, 0 arms regress on the class face, 1 new defect found
(`v27`, §1), 2 arms are mask cascades and 1 is a compile-reject control.**

| arm | what it breaks | pris | fix |
|---|---|---|---|
| `v01_ifacenoinst` | an interface with classes that is NEVER instantiated | 163 | **0** |
| `v03_moddupclass` | the SAME class name in a module body AND its generate block | 134 | **0** |
| `v04_modifelse` | BOTH arms of a generate `if/else` carry a class | 84 | **0** |
| `v05_modcasegen` | a CASE generate, two arms, two classes | 128 | **0** |
| `v06_progthree` | a PROGRAM body, three classes M/Z/A | 46 | **0** |
| `v10_ifaceforclass` | an interface `for` generate, bound 2 — ONE copy | 280 | **0** |
| `v11_ifaceif0class` | an UNTAKEN `if (0)` arm in an interface | 234 | **0** |
| `v12_modgenchild` | a MODULE instantiated in a generate block keeps ITS classes | 46 | **0** |
| `v13_keyorder` | `A_`, `AB`, `A1` — `'1'`=49 < `'B'`=66 < `'_'`=95 | 46 | **0** |
| `v14_twoiface` | two interfaces + a `$unit` class: design-root order | 414 | **0** |
| `v15_ifacemodportclass` | an interface with a MODPORT and a gen-block class | 282 | **0** |
| `v16_modgenifaceinst` | an INTERFACE instantiated in a module's generate block | 220 | **0** |
| `v18_modclassmany` | five classes, mixed case and digits | 46 | **0** |
| `v19_ifacenestclass` | nested generate blocks in an interface, Zdeep/Adeep | 240 | **0** |
| `v20_modgenmixed` | one block holding `final` + `initial` + `always` + a class | 142 | **0** |
| `v21_modgentwoclass` | two classes in ONE generate block, Z then A | 78 | **0** |
| `v22_ifacebodygen` | an interface body class AND a gen-block class | 211 | **0** |
| `v23_modfinaltwo` | TWO `final` constructs in one generate block | 41 | **0** |
| `v24_topmodclass` | the TOP module itself declares Zclass then Aclass | 46 | **0** |
| `v25_ifacearrclass` | an interface ARRAY instance whose interface holds classes | 218 | **0** |
| `v26_modgenclassnodef` | a module with a gen-block class, never instantiated | 56 | **0** |
| `v30_ifaceclassnamedup` | TWO interfaces declaring the SAME class name + a `$unit` one | 414 | **0** |
| `v08_ifacefinalgen` | a `final` in an INTERFACE generate block (LAW B3's other home) | 29 | **0** |
| `v09_progfinalgen` | **CONTROL** — a `final` in a PROGRAM generate block | 0 | 0 |
| `v17_proggenclass` | **CONTROL** — the pass-95 program face, already right | 0 | 0 |
| `v02_ifacechild` | **REJECT CONTROL** — slang refuses a module in an interface (`ours_rc=3` on both binaries) | — | — |
| `v07_modgenparamclass` | a PARAMETERIZED class in a module's generate block — **R0's face, not claimed** | 91 | 91 |
| `v27_ifacenestinst` | **THE DEFECT** (§1) — non-simple interface, gen-block class | 260 | 260 |
| `v28_ifacenestbody` | non-simple interface, BODY classes — **PRE-EXISTING** ours-only, 2 on BOTH binaries | 252 | 252 |
| `v29_modinnerdecl` | a NESTED MODULE DECLARATION, classes in both | 46 | 59 |
| `v31_ifacenestfinal` | non-simple interface, `final` in a generate block | 563 | 585 |

**`v29` and `v31` are MASK CASCADES, not regressions** (RESUME §9: a cmp line
count is not comparable across a change that removes a cascade mask; the
whole-dump diff is the arbiter):

* `v29` — LAW A puts `work@sub`'s listing in golden's order (`[Aouter,
  Zouter]`, CELL DIFF 2 → 0), which removes the first head and exposes the
  NEXT one: a `ref_module work@innermod` on `work@sub` that golden does not
  write.  That object is **byte-identical on both binaries** (`grep -n
  ref_module` gives the same two lines on pristine and law), so the patch
  neither caused nor worsened it — see R2.
* `v31` — LAW B3 adds the def-view `final_stmt` subtree.  Golden HAS it
  (`final_stmt` count 4; pristine wrote 2, the law writes 4) under its own
  `named_begin (work@outer.g)`.  The move is TOWARD golden.

### the score, per CELL and per SUBTREE, by this verifier's OWN scorer

`clscore98v.py` (written here, not r11u98's `classcell98.py`) re-parses each
dump, keys a **CELL** as one `(holder, index)` slot of a `vpiClassDefn` /
`uhdmallClasses` vector and a **SUBTREE** as one class name under one holder,
order-blind.  Summed over **167 arms** of five grids (r11u98's 20 + this
grid's 31 + r11u95's 35 + r11v95's 30 + r11u93's 53, minus the arms that hold
no listing):

| | pristine | r11u98 + fix |
|---|---|---|
| CELL OK | 27 | **100** |
| CELL DIFF | 37 | **1** |
| CELL GOLD-ONLY | 42 | **5** |
| CELL OURS-ONLY | **4** | **4** |
| SUBTREE MATCH | 64 | **101** |
| SUBTREE GOLD-ONLY | 42 | **5** |
| SUBTREE OURS-ONLY | **4** | **4** |

**MOVED-WRONG 0, AWAY 0.**  OURS-ONLY is **unchanged at 4 on both binaries** —
all four are pre-existing (`v28`×2, `v29`×2) and none is this pass's.  With
the submitted binary it would have read 5.  The surviving CELL DIFF is `g9`'s
R0; the 5 GOLD-ONLY are `g9`, `v07`, `v27`, `v28`×2.

---

## 4. THE GATES, re-run on the FIXED binary

1. **BUILD** — pristine `bad3448…`, `cmp`-identical to the main tree at
   `cc9efa23`; r11u98 as submitted rebuilds to `422d5f…` from a FRESH
   `cc9efa23`; fixed `534aa1d5c630bc1530e15a30341eb6fa`.  Both `-j 2`, md5
   separately, frozen before any sweep.
2. **GOLDENS** — **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` **0 PASS /
   23 FAIL**.
3. **uhdm2rtlil, BOTH MODES** — **788 / 16 / 67** in all six sweeps (pristine,
   submitted, fixed × two modes); row-join PASS against
   `results/gate_uhdm2rtlil.csv` and against this verifier's own pristine
   sweeps.  **No row moved.**
4. **surelog, `--mode both`** — **474/9 default + 469/8 testflags on all three
   binaries, histograms identical.**  Against the committed
   `results/golden_surelog.csv` the fixed binary moves **exactly two rows**,
   both quoted in full:

   ```
   < LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/m187base/sl/wd/testflags/LowMemLib-f068a766/slpp_all/surelog.log".,,
   > LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/v11u93_wd/vsfx/testflags/LowMemLib-f068a766/slpp_all/surelog.log".,,
   < LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/m187base/sl/wd/testflags/LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
   > LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/v11u93_wd/vsfx/testflags/LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
   ```

   `SURELOG_FAIL` on both sides, differing only in the workdir path inside
   `detail`.  **NO ROW CONVERTED; `results/*.csv` needs no edit.**
   `Earlgrey_0_1`'s DUMP COLUMN drew both ways across this verifier's three
   sweeps (blank on the pristine sweep's default row, `differ` on the fixed
   sweep's) — the OPS environment draw; **its DATABASE is the pin and it is
   exact** (§6).
5. **BYTEVERIFY `SELFCHECK=1`** against this verifier's own pristine
   workdirs — u2r **0 / 1608** (and **0 / 1608** fixed-vs-submitted), surelog
   **6 / 960**, `PATH_SETS_IDENTICAL` on both, SELFCHECK flagging 1607/1608
   and 959/960 (the comparator can see).  The six are the documented UVM coin,
   attributed THREE independent ways in §5.
6. **CANARIES** — `canaries.sh` surelog against the committed CSV **ok=52
   changed=0**; u2r **ok=8 changed=0**; `ctcan2.sh` PASS on both corpora;
   `canaudit.sh` PASS.  The battery scripts r11u98 ships are **byte-identical
   to `r10uvm221repro`'s** (the OPS-named generation) — checked with `diff`,
   not by eye; `ct8rows.sh`, `byteverify.sh`, `rowheads.sh`, `subtree95.py`
   and `setaway95.py` are byte-identical to r11u95's.
7. **FENCES** — the four slang-fenced names: **0** in `git diff cc9efa23 --
   src include`; the only substring hit anywhere in the patch is the
   uhdm2rtlil test `SizeOfUnsignedParameter`, which is not a fenced test.
   `results/*.csv` never written; the sister's three files untouched.

### the byte pins, read out of the sweep workdirs

| name | mode | pristine | submitted | fixed | OPS value |
|---|---|---|---|---|---|
| SVSwitch | both | `4842211c4030` | `4842211c4030` | `4842211c4030` | `4842211c4030` |
| YosysVerx | both | `6ccda350c24a` | `6ccda350c24a` | `6ccda350c24a` | `6ccda350c24a` |
| InterfaceModPort | both | `59a365f3ce2c` | `59a365f3ce2c` | `59a365f3ce2c` | `59a365f3ce2c` |
| Earlgrey_0_1 | default | `8bdf25272e08` | `8bdf25272e08` | `8bdf25272e08` | `8bdf25272e08` |
| Earlgrey_0_1 | testflags | `59d0ee6d10c3` | `59d0ee6d10c3` | `59d0ee6d10c3` | `59d0ee6d10c3` |
| BlackParrotComplex | default / testflags | `e3e354129d5a` / `73a10e8217e5` | same | same | SAME |
| YosysOldOr | both | `d68e0796d62c` | same | same | SAME |

No conversion row moved: `SeqDriver`, `MiniAmiq`, `SimpleUVM`, `BuildUVMPkg`,
`Earlgrey_0_1` are `CMP_EQUAL` in both modes on all three binaries,
`Scoreboard` is `CMP_EQUAL`/default (`SLANG_REJECT`/testflags, as committed),
and `Rggen`/default is `CMP_NOTEQUAL` at `cc9efa23` and stays — it is
`CMP_NOTEQUAL` in the committed CSV too, so r11u98's blanket phrase "all seven
conversion rows CMP_EQUAL both modes" is loose; what holds, and what matters,
is that **no row moved**.

---

## 5. THE SIX SURELOG BYTE MOVERS — the coin, proved three ways

`MiniAmiq` (both modes), `SeqDriver` (both modes), `SimpleUVM`/default,
`Scoreboard`/default — the same six r11u98 named.

1. **THE TRACE** — `R11U98_NETDBG=1` replaying each arm's own `cmds.txt` argv
   in the test's own directory: **0 `R11U98` lines on all six**, and on
   `BuildUVMPkg` beside them.  Positive control, same trace, same binary, on
   the grid: `h1` prints `R11U98MODGENCLASS name=C iface=0`, `g2` prints
   `R11U98CLASSKEY home=work@sub n=2 was=Zclass,Aclass, now=Aclass,Zclass,`,
   `h9` prints `R11U98IFACECLASS name=C`, `h4` prints `R11U98GENFINAL
   home=work@sub`.
2. **ORDER-BLIND** (sorted, workdir-normalised dumps): five carry **exactly 4**
   payload lines and every one is a `|UINT:` / `|vpiDecompile:` LINE-NUMBER
   pair (`UINT:0` against `UINT:514` on MiniAmiq); `Scoreboard`/default carries
   **0** — the pure order draw.  Exactly the 0-or-4-line class the OPS names.
3. **THE PRISTINE BINARY DISAGREES WITH ITSELF.**  Three consecutive runs of
   the pristine binary on `Scoreboard`'s own argv in its own directory:

   ```
   pris run1 1621aec6c9f3
   pris run2 1621aec6c9f3
   pris run3 e70775324004
   byteverify called: patched=1621aec6c9f3  pristine=e70775324004
   ```

   **One binary wrote both sides of the reported "mover".**

---

## 6. THE CENSUS — independently re-measured, and the zero explained

`srcscan98v.py` (this verifier's own scanner, written here) over both corpora,
`third_party` included, with a positive control:

```
POSITIVE CONTROL (r11u98 grid + this grid)  lawa_module=24 lawa_program=4
                                            lawb_class=52 lawb_final=14
Surelog/tests               lawa_module=3   (ClassFuncProto, SimpleClass1, UnitClass)
Surelog/third_party/tests   lawa_module=2   (UnitAmiqEth, Google/8.22)
uhdm2rtlil/test             ALL ZERO
```

The scanner's `lawb_iface` hits in `third_party` are all `interface class`
DECLARATIONS (SV interface classes), not interface homes holding classes — a
false-positive class this verifier checked by hand and discounted; the true
count is 0, agreeing with r11u98's scanner.

**The gap is explained from the committed CSV, not asserted.**  Every test
name that carries a LAWA site is `SLANG_REJECT` in
`results/golden_surelog.csv` in BOTH modes — quoted:

```
UnitClass      SLANG_REJECT  error: redefinition of 'F001'
SimpleClass1   SLANG_REJECT  error: duplicate definition of 'uvm_pkg'
ClassFuncProto SLANG_REJECT  error: enum value 32'd1953461359 is out of range
Google         SLANG_REJECT (default) / TIMEOUT (testflags)
UnitAmiqEth    SLANG_REJECT  error: use of undeclared identifier 'client_data'
```

No database is produced for any of them, so no LAWA site can become a mover.
**Predicted mover set: EMPTY.  Measured: u2r 0/1608, surelog 6/960, all six
the coin.**  A-posteriori this is also the stronger census: a law that fired
anywhere in either corpus would have moved bytes, and outside the six coin
arms nothing moved.

---

## 7. THE WIDE ARM BOUNDARY — 4457 arms, every mover accounted

`bnd98.sh` with the pristine and the FIXED binary over `tools/probe`:

```
BOUNDARY listed=4457 processed=4457 moved=96 rc-or-db-anomalies=0
PROCESSED==LISTED
```

**LISTED is 4457, not r11u98's 4316, because this verifier's own grid runs left
141 `slpp_all/lib/work` source copies inside the committed grid directories;
22 of the 96 movers are those copies.  Excluding them the mover set is
EXACTLY 74 — r11u98's number.**

`attrib98v.sh` classifies every one of the 96 (trace / `R11U98_OFF=1` revert /
pristine self-disagreement over three runs):

| n | class | proof |
|---|---|---|
| **85** | THE LAW | the trace names a site AND `R11U98_OFF=1` reproduces the pristine database byte for byte |
| **2** | law-gated, untraced | `R11U98_OFF=1` reverts byte for byte; id-normalised dumps IDENTICAL (`r10uvm117repro`, `r10uvm196repro/grid196`) |
| **1** | binary-dependent, not gate-dependent | `r10v144repro` — 21 bytes of 146523, same size, id-normalised dumps IDENTICAL |
| **5** | COIN | the pristine binary disagrees with ITSELF over three runs of the same argv (`r10uvm130repro`, `r10v109repro`, `r10v117repro`, `r10v130repro`, `r10v209repro/arms`) |
| **3** | r11u95's residue R2 | the 8-digit image-size `UINT` (`23343993`/`23343137` against `23368633`/`23367777`); `R11U98_OFF=1` cannot reach it — `r10buvm22repro`, `r10uvm154repro`, `r10uvm185repro/grid185`, **exactly the three arms r11u95's README names** |

Traced faces: `IFACECLASS` alone 30, `CLASSKEY` alone 24, `MODGENCLASS` alone
10, `GENFINAL` 7, `CLASSKEY+IFACECLASS` 6, `CLASSKEY+IFACECLASS+MODGENCLASS` 4,
`IFACECLASS+MODGENCLASS` 3, `CLASSKEY+MODGENCLASS` 3.

**JUDGED AGAINST REGENERATED v1.87 GOLDENS** — every one of the 96 movers had
its golden rebuilt by the pinned Surelog v1.87 and both databases run through
`uhdm-cmp` (`BOUNDARY.judge.r11v98.txt`):

```
BETTER 48    SAME 46    WORSE 0    (2 produce no golden on either binary)
```

**No arm regresses on the judge anywhere in the probe tree.**  (BETTER is
higher than r11u98's 27 because this mover set includes the 22 `slpp_all`
copies of converting grid arms.)

---

## 8. RESIDUES (ranked)

1. **R0 — a module/program home does not list its PARAMETERIZED classes.**
   Confirmed independently, and WIDENED: `g9_modclassparam` 159 on both
   binaries (a module body), and this verifier's `v07_modgenparamclass` 91 on
   both (a parameterized class in a module's GENERATE block — the same miss
   through LAW B1's road).  slang models the declaration as a
   `GenericClassDefSymbol`; `emitPackageClasses`
   (`src/UhdmExporter.cpp:2867-2871`) and the design root already take the
   `getDefaultSpecialization` road and are the precedent.  Minting a
   specialization during the DEF phase is the Heisenbug RESUME §9 warns about,
   so it needs its own pass.  CORPUS-INVISIBLE.  **R0.**
2. **LAW B2 DOES NOT REACH AN INTERFACE THAT FELL THROUGH TO THE MODULE
   PATH.**  `v27_ifacenestinst` (a gen-block class) and `v28_ifacenestbody`
   (body classes) keep CELL GOLD-ONLY 1 and 2: golden publishes `work@Cgen` /
   `work@Zbody` + `work@Abody` at the design root and we publish nothing,
   because the `AllClasses` block walks `defs` under `useInterfacePath`.
   Widening that predicate to `inst98->isInterface()` is one token and would
   close both, and `v28`'s PRE-EXISTING ours-only (the unconditional body-class
   push in `emitModuleDef`, 2 cells on BOTH binaries at the base) wants the
   same guard this pass added for the generate face.  NOT shipped here: it is
   a widening, not a regression fix, it is corpus-invisible, and it needs its
   own byte-pin measurement.  **Ranked first among the follow-ups.**
3. **A NESTED MODULE DECLARATION IS A WHOLLY UNCLAIMED ZONE.**
   `v29_modinnerdecl`: golden names it `work@sub::innermod`, we name it
   `work@innermod`; golden writes NO `ref_module` for it on the parent, we do;
   golden lists NONE of its classes (the outer collect stops at a nested
   module and the file walk stops at the outer module), we list two.  All
   three are IDENTICAL on the pristine binary — pre-existing, and LAW A only
   made the arm's first head go away and the next one visible (46 → 59 cmp
   lines, a mask cascade).  Corpus-invisible.
4. **r11u95 / r11v95 residues, unmoved and re-measured**: `a20_proggenparam`
   72 (r11u95 R0, `src/ParamEmit.cpp`, the sister's ground);
   `x12_proggenimportfn` 203 + `x26_progimportbodyfn` 241 (R3);
   `x2_proggenassert` 64 (R4); `x8_proggendupname` 14 (R5).
5. **A PROGRAM DEF STILL BUILDS GENERATE PLACEHOLDERS NOBODY CAN REACH** —
   r11u98's R4, confirmed: `v09_progfinalgen` reads **0 on the pristine
   binary**, because `instSetGenStmts` drops the whole vector for a program
   home.  LAW B3's home restriction is therefore right, and the cleanup is a
   pass of its own.

---

## 9. HOW TO RE-RUN

```bash
GRID=tools/probe/r11v98repro/grid bash tools/probe/r11u98repro/rr98.sh <binary> <tag>
python3 tools/probe/r11v98repro/clscore98v.py <gold.dump> <ours.dump> --rows
python3 tools/probe/r11v98repro/srcscan98v.py <dir> …
bash    tools/probe/r11u98repro/bnd98.sh <pristine> <fixed> <outdir> tools/probe
bash    tools/probe/r11v98repro/attrib98v.sh          # needs /tmp/<pass>_movers.txt
R11U98_OFF=1 / R11U98_CLASSKEY_OFF=1 / R11U98_MODGENCLASS_OFF=1 /
R11U98_IFACECLASS_OFF=1 / R11U98_GENFINAL_OFF=1 / R11U98_NETDBG=1 <binary> …
```

`attrib98v.sh` hard-codes nothing but its own scratch root and reads the
binaries from `/tmp/v11u93_*.bin`; edit those two lines for another pass.
