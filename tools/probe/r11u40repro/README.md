# r11u40 — § ovHopBareActualElabFold40

**AN OVERRIDE ACTUAL THAT CROSSES AN INTERFACE-PORT HOP IS REDUCED AT
ELABORATION LIKE ANY OTHER: THE CHILD'S ELABORATED `param_assign` Rhs IS THE
CONSTANT AND EVERY ELABORATED RANGE BOUND READING THE PARAMETER FOLDS THROUGH
IT.  ONLY AN ACTUAL THE REDUCER CANNOT EVALUATE KEEPS THE WRITTEN EXPRESSION.**

Base `e305f3d7`.  LHS is ALWAYS golden.  Judge: `uhdm-cmp`
(`/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp`, v1.87).
Pins per `SUPPORT_MATRIX.md`: slang upstream-master `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

---

## 1. THE HEAD, RE-MEASURED AT `e305f3d7`

Own pristine binary (md5 `ffc677a78847fe65baac4b65f0a930c0`, byte-identical to
the main tree's `build/slang-uhdm` at the base), own sweep, own workdir,
`SLANG_UHDM` exported per binary and the `cmds.txt` audited by binary PATH
(`slang: /tmp/r11u40_pris.bin`).  Both rows carry EXACTLY ONE head
(`grep -c '^LHS:'` = 1).

```
iface_param_2level  (u2r, default and testflags)   dut.sv:16  `logic [SYS_DAT-1:0] reg_data;`

LHS (golden)                                 RHS (ours)
constant: , line:16:10, endln:16:17          operation: , line:16:10, endln:16:19
|vpiParent: \_range: 16:9..16:22             |vpiParent: \_range: 16:9..16:22
|vpiDecompile:31                             |vpiOpType:11
|vpiSize:64                                  |vpiOperand: \_hier_path: (s.CFG.BUS.DAT) 16:10..16:17
|INT:31                                      |   |vpiTypespec: \_ref_typespec:
|vpiConstType:7                              |   |   (work@iface_param_2level.u.u_inner.reg_data.s.CFG.BUS.DAT)
                                             |vpiOperand: \_constant UINT:1
```

Status at the base, quoted from the pass's own sweep:

```
iface_param_2level,default,CMP_NOTEQUAL,decompile:,,
iface_param_2level,testflags,CMP_NOTEQUAL,decompile:,,
```

**IT IS NOT THE ROW'S LAST CELL.**  Whole-dump distance at the base,
banner stripped: **949** differing lines of 2851 (543 order-blind) in
`default` and the same 949 in `testflags`.  The head is the largest single
class in that diff — the
sorted-diff line histogram puts `hier_path (s.CFG.BUS.DAT)` at 35 occurrences,
ahead of every other kind — but it is not the whole of it.  The row was
therefore predicted, BEFORE the code was written, to CONVERT (judge-equal) and
NOT to reach `match` in the dump column.  It does exactly that (§6): **745**
differing dump lines (255 order-blind) after the law.

The `param_assign` beside it is the SAME law and was measured at the same time:

```
work@iface_param_2level.u.u_inner.SYS_DAT   param_assign 14:39..14:50
LHS (golden)  constant 14:49..14:50  |vpiDecompile:32 |vpiSize:32 |UINT:32 |vpiConstType:9
RHS (ours)    hier_path (s.CFG.BUS.DAT) 22:20..22:33, four ref_obj actuals, vpiExpr -> work@iface_param_2level.u.s
```

Golden's constant sits at the FORMAL's own default-initialiser span
(`parameter int unsigned SYS_DAT = 8`, the `8` at 14:49), carries the declared
`int unsigned` width 32 and `vpiUIntConst`, and its `ref_typespec` is named for
the INSTANCE with the formal's `int_typespec` as actual — the shape the
ordinary (non-hop) override path already mints.

## 2. THE PRODUCER, DECODED

The head is on the NETLIST-ELABORATION road, not the definition compile.  Every
line cited from the pinned Surelog v1.87 sources.

| step | file:line | what it does |
|---|---|---|
| `NetlistElaboration::elab_ports_nets_`, nets pass | `NetlistElaboration.cpp:3049` | calls `elabSignal(sig, instance, child, …, Reduce::Yes)` for every signal of the ELABORATED instance |
| `NetlistElaboration::elabSignal` | `NetlistElaboration.cpp:2050`, signature at `:2055` | takes that `Reduce` |
| the packed dimension | `NetlistElaboration.cpp:2196` | `compileRanges(comp, fC, packedDimension, …, reduce, nullptr, child, …)` — `child` is the elaborated instance, i.e. the VALUE SCOPE |
| the unpacked dimension | `NetlistElaboration.cpp:2201` | the same, for `unpackedDimension` |
| the reduction itself | `CompileExpression.cpp:3963` `compileRanges`, the `Reduce::Yes` test at `:4032` | hands each bound to `UHDM::ExprEval::reduceExpr` |
| a NAME leaf | `CompileExpression.cpp:980` | `CompileHelper::getValue`'s instance arm mints the operand from the instance's STORED `Value` |
| the `vpiSubOp` arm | `~/git-repos/UHDM/templates/ExprEval.cpp:3443` | size 64, `vpiIntConst` — exactly the head's `INT:31 @64 ct7` |

The elaborated `param_assign`'s Rhs prints that same stored `Value`, which is
why the two objects always agree: a constant Rhs ⇔ a folded bound.

**The PACKAGE pass is the control that proves the road.**
`NetlistElaboration::elaboratePackages` calls `elabSignal` with
`Reduce::No` (`NetlistElaboration.cpp:106`, `:117`) — a different `reduce` at a
different call site — and the DEFINITION module's own copy of the bound is
built by the definition compile, which is why golden keeps
`op11(ref_obj W, constant 1)` there on every grid arm.

**The hop does not enter the decision.**  `g1_hop40` puts nine differently
reached overrides on one child and golden folds the child's elaborated bound on
all nine (§3).

## 3. THE GOLDEN GRID

Four arms, `grid/`, each compiled by BOTH producers with BOTH rcs recorded:
`golden_rc=0 ours_rc=0` on all four for the pristine binary and for the law
binary, Surelog `[FATAL] : 0 [ERROR] : 0` on all four.

Every arm gives each instance a DISTINCT parameter value, so the design-level
typespec POOL's multiset of bound encodings attributes each cell to its arm
without an owner chain — `uhdm-dump` prints a pooled typespec's content once
and every later reference abbreviated, so a pool-keyed census is the only one
that can see these objects at all.

### `g1_hop40` — THE HOP KIND (the decisive arm)

One child (`inner40`, `logic [W-1:0] reg_data`) reached nine ways.  Golden's
ELABORATED bound, read at `26:9`:

| arm | how `W` is overridden | golden | ours, pristine | ours, law |
|---|---|---|---|---|
| `u_a` | a MODPORT port, member depth 3 (`s.CFG.BUS.DAT`) — the corpus shape | `INT:31@64 ct7` | `op11(hier_path,constant)` | `INT:31@64 ct7` |
| `u_b` | a MODPORT port, a plain `int unsigned` parameter (`s.PW`) | `INT:11` | `INT:11` | `INT:11` |
| `u_c` | a PLAIN interface port, member depth 3 | `INT:31` | `INT:23` | `INT:23` |
| `u_d` | the parent's own module parameter | `INT:19` | `INT:19` | `INT:19` |
| `u_e` | an EXPRESSION of the parent's module parameter | `INT:21` | `INT:21` | `INT:21` |
| `u_f` | the parent's own STRUCT parameter's member | `INT:27` | `INT:27` | `INT:27` |
| `u_g` | a PACKAGE parameter | `INT:17` | `INT:17` | `INT:17` |
| `u_h` | a modport port RE-PASSED one level further | `INT:31` | `INT:13` | `INT:13` |
| `u_i` | an interface ARRAY element's modport (`sarr[1].sub`) | `INT:31` | `INT:15` | `INT:15` |
| — | the DEFINITION view (`uhdmallModules|work@inner40`) | `op11(ref_obj,constant)` | same | same |

Golden FOLDS on all nine.  The def copy keeps on all three binaries.

`u_c`, `u_h` and `u_i` also expose a SEPARATE fact, R1 below: golden's value
there is 31, i.e. the interface DEFINITION's default `CFG.BUS.DAT = 32`, even
though the connected instances carry 24, 14 and 16 — and the interfaces' OWN
bounds (`18:9`) do fold to 23, 13 and 15, so the override actual and the
interface instance disagree inside one golden database.  That is a VALUE law,
not a fold law; this pass does not touch it and those three cells are wrong
before and after.

### `g2_site40` — THE SITE INSIDE THE CHILD

One child carrying a `W`-derived bound at eleven sites, instantiated twice: the
modport hop (32) and a module parameter (20, the control).  Golden folds at
every site on both arms.  Our pristine keeps the operation at four of them and
the law clears all four: the PORT dim (`24:44`), the body VARIABLE (`25:9`), the
body NET (`26:9`) and the body TYPEDEF (`29:17`).  The unpacked SIZE and RANGE
dims, the struct MEMBER dim, the generate block, the function, the localparam
and the RE-PASS to a grandchild already folded in the pristine binary and do
not move.

### `g3_shape40` — THE WRITTEN BOUND SHAPE

Twelve written bounds over `W` under the same two arms.  Golden folds every one
of them under the hop, through `reduceExpr`'s own operator table:

```
[W-1:0]        INT:31@64 ct7      [W:0]            UINT:32@64 ct9
[W+1:0]        UINT:33@64 ct9     [W*2-1:0]        INT:63@64 ct7
[2*W-1:0]      INT:63@64 ct7      [W/2-1:0]        INT:15@64 ct7
[(W>>1)-1:0]   INT:15@64 ct7      [$clog2(W)-1:0]  INT:4@64 ct7
[7:0]          UINT:7@64 ct9 (a LITERAL — the control, unmoved)
```

### `g4_view40` — THE VIEW, and WHICH ACTUALS REACH THE ROAD

Five instances of one child: no override at all (the declaration default 8), the
bare hop, the hop inside an EXPRESSION, the hop inside a GENERATE loop, and the
same hop written twice in one module.  **This arm carries the one shape golden
KEEPS** and is why the law is stated as "only an actual the reducer cannot
evaluate":

```
#(.W(s.CFG.BUS.DAT + 4))   golden param_assign Rhs : operation op24( hier_path s.CFG.BUS.DAT , 4 )
                           golden elaborated bound : op11( op24( hier_path s.CFG.BUS.DAT , 4 ) , 1 )
#(.W(s.CFG.BUS.DAT))       golden param_assign Rhs : constant UINT:32 @32 ct9
                           golden elaborated bound : constant INT:31 @64 ct7
```

Neither gated arm can see the expression shape — both require the initialiser
to be a BARE member-access chain — so the law is written in the producer's terms
and the expression cell is untouched (it is already folded, wrongly, in the
pristine binary; R2).

**ONE CELL IS NOT ON THIS GRID.**  A hierarchical read of a sibling MODULE
INSTANCE's parameter (`#(.W(u_hold.HP))`) is refused by slang outright —
*"reference to 'HP' by hierarchical name is not allowed in a constant
expression"*, `dut.sv:45:13`, `ours_rc=3` — and an arm whose compile fails
teaches error recovery, not golden, so the arm was removed and the
interface-port hop, which is the corpus's own shape, is what the grid carries.

### The score (gold × pristine × law, per cell)

`score40.py` reports both axes; `rangecensus40.py` is the census AND the SHAPE
LISTER (an operation prints as `op<type>(<operand kinds>)`, a constant as
`<TAG>:<v>@<size>ct<ct>`, so a "kept the operation" difference and a "size"
difference can never be confused).  A cell present on one side only is its own
bucket and is printed.

| arm | axis | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG | UNMOVED |
|---|---|---|---|---|---|---|
| `g1_hop40` | SET | 0 | **0** | 3 | 14 | 76 |
| `g2_site40` | SET | 3 | **0** | 1 | 4 | 47 |
| `g3_shape40` | SET | 8 | **0** | 1 | 3 | 36 |
| `g4_view40` | SET | 0 | **0** | 0 | 6 | 22 |
| **total** | SET | **11** | **0** | **5** | 27 | 181 |
| `g1_hop40` | MULTISET | 0 | **0** | 3 | 15 | 75 |
| `g2_site40` | MULTISET | 3 | **0** | 1 | 5 | 46 |
| `g3_shape40` | MULTISET | 8 | **0** | 1 | 3 | 36 |
| `g4_view40` | MULTISET | 0 | **0** | 0 | 6 | 22 |
| **total** | MULTISET | **11** | **0** | **5** | 29 | 179 |

**AWAY-GOLDEN is 0 on every arm and on both axes: nothing that agreed with
golden stopped agreeing.**

**THE FIVE MOVED-WRONG, named and attributed.**  Every one is a cell that was
unequal before and after, and in every one the law's own half landed exactly on
golden while a DIFFERENT, pre-existing residue keeps the cell unequal:

* `g1_hop40` `24:30`, `25:30`, `26:9` — the port dims and the body variable.
  The law replaced `op11(hier_path,constant)` with golden's own `INT:31@64 ct7`
  (arm `u_a`); the cells stay unequal because `u_c`/`u_h`/`u_i` still carry
  `INT:23`/`INT:13`/`INT:15` where golden carries three more `INT:31`.  That is
  R1, the VALUE residue, and it is identical before and after.
* `g2_site40` `29:17` — the body TYPEDEF's bound.  Golden carries three copies
  of that typespec (`INT:19`, `INT:31`, `op11(ref_obj,constant)`); our pool
  carries two, and after the law both of ours read `INT:31`.  The missing
  `op11(ref_obj,constant)` def copy is absent in the pristine binary too — the
  typespec-POOL copy-count residue (`r11u35repro/README.md` R4), not this law.
* `g3_shape40` `19:9` — the BARE `[W:0]`.  The hop half is now exactly golden's
  `UINT:32@64 ct9`; the CONTROL half (the module-parameter arm) is golden
  `UINT:20@32` against our `UINT:20@64`, an ENCODING residue of
  § rangeBoundStoredWidth82's family that predates this pass and is untouched
  by it.

## 4. WHAT WAS WRITTEN

Two production files plus the header; **no line removed**.

* `include/UhdmExporter.h` — the law and the declaration of
  `ovHopBareActualFolds40`, with the netlist-elaboration road cited line by
  line and the def-side laws it must not disturb named.
* `src/TypeEmit.cpp` — the predicate (`p.getValue()` is an integer without
  unknowns), and the gate on `makeTypespec`'s `ovHierParam` arm, added as the
  LAST conjunct of the arm's existing `&&` chain so the shape tests
  short-circuit before any value is forced.
* `src/ParamEmit.cpp` — the same gate on `emitParameters`' `ovHierInit` arm,
  applied AFTER the shape test has already selected the arm.  `getValue()`
  forces a parameter's evaluation, and asking it of every parameter that has an
  initialiser is the blanket binding RESUME.md §9 records as a Heisenbug; asked
  of the handful the arm would otherwise keep symbolic, it is not.

**The abstention, measured:** an actual the reducer cannot evaluate keeps the
written expression (`g4_view40`'s `#(.W(s.CFG.BUS.DAT + 4))`).  Neither arm can
reach it, and the predicate says so in the producer's own terms rather than
relying on that.

## 5. INSTRUMENTS

* `rangecensus40.py` — the census AND the SHAPE LISTER, one row per range
  bound (view, holder chain, loc, side, shape+encoding), inherited from
  `r11u35repro`.
* `cmpcensus40.py` — pairs two listings (SAME / DIFF / OURS-MISSING /
  GOLD-MISSING).
* `score40.py` — the three-way cell score on both axes.
* `pred40.py` — the A-PRIORI mover predictor, with `--selftest` as its POSITIVE
  and NEGATIVE control.  Half (a) reads the SOURCES for a bare dotted override
  actual; half (b) reads the PRISTINE DATABASE for the two arms' own output —
  S1 a `hier_path` that is the IMMEDIATE `vpiRhs` child of a `param_assign`,
  S2 a `hier_path` in a range bound carrying its OWN `vpiTypespec`.
  *Immediacy is load-bearing*: the loose form of S1 names 35 u2r rows
  (`jeras_union` 48 hits, `rp32_r5p_alu` 134), and seven of them were armed on
  both binaries and are **byte-identical** — their Rhs hier_paths are nested
  under other emissions, not this arm's.  The typespec on S2 is load-bearing
  the same way: the DEFINITION view's own `[CFG.BUS.DAT-1:0]` bound is a bare
  hier_path in BOTH producers.
* `run40.sh` — the two-sided grid runner (inherited from `r11u35repro/run35.sh`
  unmodified except its default `GRID`); both producers, both rcs recorded.
* `heads40.sh` / `dumpdiff40.sh` / `attr40.sh` — the head per row, the
  whole-dump distance beside it, and ORDER-BLIND mover attribution.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` —
  the current-generation battery, byte-identical copies of `r11u35repro`'s.
* `grid/` — the four arms with their `CENSUS.gold` / `CENSUS.pris` /
  `CENSUS.law` and `SCORE.txt`.  The `slpp_all` trees, the `.uhdm` databases
  and the raw dumps are regenerable and are not committed.
* `evidence/` — the re-measured heads, the a-priori prediction, the byte
  verifier's output and the gate log.

## 6. GATES

All in `evidence/GATES.r11u40.txt`, every one against the pass's OWN pristine
binary and OWN pristine workdirs.

| gate | result |
|---|---|
| pristine worktree build | md5 `ffc677a78847fe65baac4b65f0a930c0` — byte-identical to the main tree's `build/slang-uhdm` at `e305f3d7`, which is the md5 the brief names |
| law build | md5 `c6b54054bd2c8080d3056fe468082b1b` |
| goldens | 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (negative control) |
| pristine sweeps | u2r 777/27/67 in EACH mode — `ct8rows` **PASS, every row byte-identical** to the committed `results/gate_uhdm2rtlil.csv`; surelog 474/9 + 469/8 of 798, histograms identical to `results/golden_surelog.csv` |
| u2r both modes, law | **778/26/67 in EACH mode**; `ct8rows` names exactly ONE differing row in each mode and in both directions — the conversion, quoted below |
| surelog both modes, law | **474/9 + 469/8 of 798 — every status AND dump histogram identical** to the pristine sweep and to `results/golden_surelog.csv`; the only differing rows are `LowMemLib`/`LowMemPkg` (each carries the WORKDIR PATH inside its `SURELOG_FAIL` detail string, and the two sweeps used two workdirs — not a row move) and `Earlgrey_0_1`/testflags, resolved below |
| byteverify u2r | **2 / 1608** movers, SELFCHECK 1607/1608, both PREDICTED BY NAME a priori |
| byteverify surelog | **6 / 960** movers, SELFCHECK 959/960 — NONE of them this law's, each attributed and each reproduced by a POSITIVE CONTROL below |
| canaries | `canaries.sh` u2r ok=8 changed=0, surelog ok=51 changed=1 (resolved below); `ctcan2.sh` PASS ×2; `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected databases | every one byte-UNCHANGED against the pass's own pristine, and every OPS pin matched: `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort 59a365f3ce2c`, `Earlgrey_0_1 8bdf25272e08` / `59d0ee6d10c3`, plus `BlackParrotComplex` and `YosysOldOr` |
| `rowheads.sh` | 0 heads and 0 cmp lines on every UVM-family row and on `Earlgrey_0_1`, both modes (`Scoreboard`/testflags SKIP-NOFILE, as expected) |
| landed range-bound laws | `genscope_struct_member` and `latch_perf_counters` (§ rangeBoundReduceEnc33's conversions) stay `CMP_EQUAL,,,match` in both modes; `StructParamFieldRange`, `StructParamFuncBodyFieldCompare`, `StructParamPatternInitCast`, `cva6_struct_param_field`, `mem_packed_2d_byte_write` (§ typeParamAnonAggMemberNoReduce35's witnesses) are unchanged — their def-side bounds do NOT fold |
| `results/*.csv` | untouched |

**THE CONVERSION, predicted by name before the code was written and quoted in
full:**

```
< iface_param_2level,default,CMP_NOTEQUAL,decompile:,,
> iface_param_2level,default,CMP_EQUAL,,,differ
< iface_param_2level,testflags,CMP_NOTEQUAL,decompile:,,
> iface_param_2level,testflags,CMP_EQUAL,,,differ
```

Both go to `CMP_EQUAL` with **0 heads** (`grep -c '^LHS:'` = 0, cmp 0 lines) and
stay `differ` in the dump column — exactly as §1 predicted from the 951-line
whole-dump distance, before the code was written.

**EVERY MOVER, NAMED A PRIORI AND ATTRIBUTED.**  `pred40.py`
(`--selftest` PASS, positive and negative control) named `iface_param_2level`
on both u2r modes and `BlackBePipeInt` on both surelog modes;
`byteverify.sh` reports `iface_param_2level` ×2 and nothing else.
`BlackBePipeInt` is the one over-prediction and it was ARMED on both binaries:
`CMP_EQUAL,,,differ` before and after in both modes, database md5
`6ccd7e81eb27` on both — **byte-identical**.  Order-blind attribution
(`attr40.sh`, `evidence/ATTR.iface_param_2level.txt`) is **20 lines** and puts
the whole of the mover at **source lines 14, 15 and 16 only** — the parameter
declaration and the two signal declarations that read it:

```
< (law)       constant 14:49..14:50   the param_assign Rhs, at the FORMAL's default span
< (law)       constant 15:46..15:53   |  the two port dims
< (law)       constant 15:78..15:85   |
< (law)       constant 16:10..16:17   the reg_data bound — THE HEAD
> (pristine)  hier_path (s.CFG.BUS.DAT) x8, and the `- 1` constants they were operands of
```

Nothing else in the database changed, in either mode.

**THE SIX SURELOG BYTE MOVERS ARE NOT THIS LAW, AND THE POSITIVE CONTROL IS
DECISIVE.**  They are `MiniAmiq` ×2, `SeqDriver` ×2, `Scoreboard`/default and
`SimpleUVM`/default.  Order-blind attribution gives each of the five non-
`Scoreboard` rows a SINGLE `UINT:<n>` / `vpiDecompile:<n>` pair — the
r11u33 R7 class, the uninitialised read on `uvm_misc.svh:642 typedef TYPE
types_t[$]`'s `array_typespec` right bound, which varies per INVOCATION on
EITHER binary — and `Scoreboard`/default **0 lines order-blind**, the
documented `svunit_pkg` `vpiTaskFunc` ORDER coin.  Running the PRISTINE binary
a SECOND time moves exactly those rows in exactly those classes:

```
MiniAmiq   default   pristine#2 27419f6011b4   pristine#1 95b568b24f2e   MOVED  order-blind 20
MiniAmiq   testflags pristine#2 27419f6011b4   pristine#1 94efe3445fdc   MOVED  order-blind  4
SeqDriver  default   pristine#2 7418903bbab2   pristine#1 172de5deecfd   MOVED  order-blind  4
SeqDriver  testflags pristine#2 05df6c25a21b   pristine#1 a0936c23eb23   MOVED  order-blind  4
Scoreboard default   pristine#2 e70775324004   pristine#1 1621aec6c9f3   MOVED  order-blind  0
SimpleUVM  default   pristine#2 f533c0ef831e   pristine#1 49d8efe2729b   MOVED  order-blind  4
```

`MiniAmiq`/default's PRISTINE second run lands on `27419f6011b4` — **the same
md5 the LAW binary produced**, which a real law difference cannot do.  Every
UVM row stays `CMP_EQUAL` with 0 heads (`rowheads.sh`), and every one of these
databases is pristine-nondeterministic by design, order-blind to the 0-or-4-line
class the OPS rules name.

**THE ONE CHANGED CANARY, resolved.**
`Earlgrey_0_1,testflags,CMP_EQUAL,,,differ` -> `CMP_EQUAL,,,` is the
`uhdm-dump` TIMEOUT coin: `verify_golden.py:626-635` records the dump column as
`''` on `TimeoutExpired` and its `--timeout` defaults to 180 s, while that
database takes ~309 s to dump on this machine.  The pass's OWN PRISTINE sweep
read the same blank, so the pristine-vs-law row diff carries NO `Earlgrey` row
at all, and the DATABASE is byte-identical to the OPS pin `59d0ee6d10c3`.  Its
STATUS never moved.

## 7. RESIDUES

* **R0 — THE NEXT HEAD on this row: `iface_param_2level` is judge-equal and
  still 745 dump lines from golden (255 order-blind, down from 949 / 543).**  The law's own cells
  are gone from that diff: the order-blind move is **20 lines**, the five
  `hier_path` emissions and the constants that replaced them (§6).  What
  remains is the `p::bus_t` / `p::cfg_t` typespec pool and the interface
  parameter's `struct_typespec` `vpiInstance` chain — a different family, and
  the row's status no longer depends on it.
* **R1 — THE VALUE A MEMBER READ LENDS ACROSS AN INTERFACE PORT.**  Surelog
  resolves `#(.W(s.CFG.BUS.DAT))` against the interface DEFINITION's default
  parameter value, NOT against the connected instance's override; slang
  resolves it against the instance.  `g1_hop40` holds the proof in one
  database: `u_c`, `u_h` and `u_i` are connected to interfaces carrying
  `CFG.BUS.DAT` = 24, 14 and 16, the interfaces' OWN bounds fold to 23, 13 and
  15 — and the children's bounds fold to 31, the DEFAULT's answer, on all
  three.  Three cells on the grid, no corpus witness found (the corpus's
  interfaces are instantiated without an override, which is why this pass's
  conversion is not affected), and it is a VALUE law on
  `DesignElaboration`'s override evaluation, not a fold law.
* **R2 — an override actual the reducer FAILS on, which we fold.**
  `g4_view40`'s `#(.W(s.CFG.BUS.DAT + 4))`: golden keeps `op24(hier_path, 4)`
  in the elaborated `param_assign` Rhs and `op11(op24(...), 1)` in the bound;
  our pristine binary folds both to `INT:35`, and this law does not change that
  (neither arm can see the shape).  Closing it means modelling WHICH
  expressions Surelog's `reduceExpr` gives up on over a hier_path leaf — a
  third kind of change, with its own census owed.
* **R3 — the typespec-POOL copy COUNT.**  `g2_site40` `29:17` reads it plainly:
  golden carries three pool copies of the body typedef's bound typespec where
  we carry two, and the def-view `op11(ref_obj,constant)` copy is absent from
  ours on both binaries.  It predates this pass, no fold decision reaches it,
  and it is `r11u35repro/README.md` R4's own subject.
* **R4 — the BARE-NAME bound's stored width off the hop.**  `g3_shape40`
  `19:9`: the module-parameter control arm is golden `UINT:20@32` and ours
  `UINT:20@64`, identical before and after this pass.  That is the
  fold-ENCODING-at-equal-size face (§ rangeBoundStoredWidth82 /
  § rangeBoundReduceEnc33's name arm), which a sister pass owns; this pass
  stayed inside its own movers and did not touch it.
