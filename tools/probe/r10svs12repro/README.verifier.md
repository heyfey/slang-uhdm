# r10svs12 — ADVERSARIAL VERIFIER RECORD

**VERDICT: PASS.** Every number in the implementer's report reproduces — including
both binary md5s, all four sweep CSVs row-for-row, the nine mover shapes with
GOLDEN's counts, and the Scoreboard flake. The 54-line SVSwitch head is CLEARED
and its ADVANCE direction is proved twice, independently of the implementer's
argument. **No code defect, no regression on any cell I could construct, and the
patch applies clean to the CURRENT head as well as to ed1e6ce.**

**THREE REPORTING DEFECTS, none of which moves a gate, all of which must be
corrected in the landing message or the write-up:**

1. **The law's stated dichotomy is REFUTED on a third connection style the pass
   never measured: `.*`.** Golden's broadcast port for `if1 w1[4](.*)` is
   NAMELESS, spans the `.*` token and carries a `constant` HighConn; ours is
   formal-named with a `ref_obj`. `hasOrderedConns` is FALSE for a wildcard, so
   the "NAMED" branch swallows it. STATED GATE == CODE GATE therefore FAILS on
   exactly this cell: the code gate is *ordered vs not-ordered*, the stated law
   is *ORDERED vs NAMED*, and they disagree precisely where `.*` lives. NOT a
   regression (pristine == shipped on those cells) — a new, undisclosed residue
   (F5, arm `v1_wildpass.sv`).
2. **R8 / §6.7's "the only cell in this grid where we emit an object golden lacks
   at the CONTAINER level" is FALSE.** `d1 h3` and `d4 e1` are the same shape as
   `m5`, and this pass renamed their phantom ports too. THREE such cells, not
   one; the write-up lists h3 and e1 as bare "absence cells" and never says our
   side builds the container (F6).
3. **`census12.sh` UNDER-SCANS the surelog corpus.** Its default roots are
   `Surelog/third_party/tests` + `uhdm2rtlil/test`, but the corpus is
   `Surelog/{tests,third_party/tests}` — **695 of 765 surelog test dirs were
   never looked at**. The omitted root yields TWO more upper-bound carriers
   (`Gates`, `LibraryIntercon`), so census-predict is **15** test dirs, not 13.
   Neither moved, so no conclusion changes — but an upper bound that skips 91% of
   a corpus is not an upper bound, and §6.6's "`census12.sh` does not name
   [InterfaceModPort]" is VACUOUS: the script never entered its root (F7).

Base `ed1e6ce` (**stated: I applied the patch to a FRESH `ed1e6ce` worktree**,
`/tmp/wt_r10svs12v`, and built a separate PRISTINE `ed1e6ce` at
`/tmp/wt_r10svs12vpris`). LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

---

## 0. PATCH HYGIENE AND PROVENANCE

```
$ md5sum /tmp/r10svs12.patch ; cat /tmp/r10svs12.patch.md5
7bb9d8dd5a2cb7bd4f50d6915eba94eb  /tmp/r10svs12.patch      <- matches the stated md5
7bb9d8dd5a2cb7bd4f50d6915eba94eb
$ wc -l /tmp/r10svs12.patch                     2495   (as stated)
$ grep "^diff --git" | 21 files, ALL under src/ or tools/probe/r10svs12repro/
$ git -C /tmp/wt_r10svs12v apply --check -v /tmp/r10svs12.patch   # 21 "Checking patch" lines, no error
$ git -C /tmp/wt_r10svs12v diff --numstat -- src     43  5  src/ModuleEmit.cpp
   '+' lines in the src hunk = 43 ; of those, comment lines = 33  -> 10 executable (as stated)
$ grep -nE '^\+.*[ \t]+$' /tmp/r10svs12.patch        (no trailing whitespace)
   no results/*.csv touched; GOLDEN_DEFER appears only in prose
$ git -C /tmp/wt_r10svs12v diff -U0 -- src/ModuleEmit.cpp | grep '^@@'
   all five hunks inside emitModuleArray (2254..2357)
$ diff <(git show ed1e6ce:src/EmitHelpers.h) src/EmitHelpers.h   -> IDENTICAL
   hasOrderedConns UNCHANGED; its other four call sites (:2542 :2605 :8672 :24134) untouched
```

**COLLISION CHECK (F13).** The patch also applies clean to the CURRENT head
`575f51d`, which already carries `r10earl35` (4296917) and `r10uvm64` (575f51d):

```
$ git worktree add --detach /tmp/wt_r10svs12vhead 575f51d && git apply --check /tmp/r10svs12.patch
APPLIES CLEAN TO HEAD 575f51d
$ git show 4296917 -- src/ModuleEmit.cpp | grep '^@@'   ->  @@ -298 ... @@ -852 ...   (far from 2254)
$ git show 575f51d --stat | grep '^ src'                ->  src/ExprEmit.cpp only
```

`§ udpShapedConnNoIfaceNet11`'s connection-site net minting is byte-untouched
(the `nets.find(rsym)` binding is the only line of it the changed block reads,
and it is unchanged).

---

## 1. GATE 1 — BUILD, and FULL BINARY-LEVEL REPRODUCIBILITY (F1)

Both binaries configured and built from scratch by me (`cmake -S . -B build`,
Release, the cache's own compiler/`slang_DIR`/`UHDM_DIR`), link line waited for,
md5 asserted SEPARATELY as 32 hex:

```
                     md5(build/slang-uhdm)               32-hex   HEAD                                      porcelain
ship /tmp/wt_r10svs12v     0ba389807cb1de8f416942e491c2afa5   OK   ed1e6ce87c89dfc870f8d00cb97d86cce30a4045   M src/ModuleEmit.cpp + ?? tools/probe/r10svs12repro/
pris /tmp/wt_r10svs12vpris d4890e6fd39981373e5497b9eaf67e31  OK   ed1e6ce87c89dfc870f8d00cb97d86cce30a4045   <EMPTY>
compiler "error:" lines: 0 / 0     "Linking CXX executable slang-uhdm" + "Built target slang_uhdm": both logs
```

**BOTH md5s ARE BIT-FOR-BIT THE ONES THE IMPLEMENTER QUOTED.** That is the
strongest provenance result available here: the shipped binary is reproducible
from the patch alone.

BASE MARKER, both directions, on the binaries these gates quote:

```
grep -c arrayBcastPortPositionalNoFormal12 src/ModuleEmit.cpp     ship 3   pris 0
strings <ship> | grep -c arrayBcastPortPositionalNoFormal12       0        <- correctly stated UNAVAILABLE, not quoted
BEHAVIOUR  d3 k1 port vpiName    ship <EMPTY>       pris clk      (a name REMOVED)
BEHAVIOUR  d3 k1 port span       ship 32:11-32:16   pris NOSPAN   (a span ADDED)
CONTROL    d3 k2 (NAMED)         both binaries      clk / 34:11-34:22
cmp <ship> <pris>  -> DIFFER
```

## 2. GATE 2 — GOLDENS

```
SLANG_UHDM=<ship>      tests/check_goldens.sh -> PASS=23 FAIL=0
SLANG_UHDM=<pris>      tests/check_goldens.sh -> PASS=23 FAIL=0
SLANG_UHDM=/bin/false  tests/check_goldens.sh -> PASS=0  FAIL=23   (control FIRES)
```

## 3. GATE 3 — u2r `testflags --jobs 2`, own out/workdir

```
SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
    --jobs 2 --out /tmp/v12_u2r_{ship,pris}.csv --workdir /tmp/v12wd_u2r_{ship,pris}

SHIP  679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL   dump 496 match / 183 differ / 52 blank
PRIS  identical
ct8rows.sh results/gate_uhdm2rtlil.csv <fresh>:  0 differing ROWS (0 diff row-sides)  BOTH binaries
```

## 4. GATE 4 — surelog `--mode both --jobs 2`, `GOLDEN_DEFER` UNSET

**THE WORLD IS THE UNCONVERTED ONE, SAID FIRST (F2).** The two SVSwitch rows are
byte-identical to the committed baseline on BOTH binaries:

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

so the unconverted expectation applies, and it is met exactly:

```
SHIP  default   467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
      testflags 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL
                + 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM
PRIS  identical, status for status
dump histograms UNCHANGED vs baseline in both modes
      default   327 blank / 242 differ / 225 match      testflags 331 / 298 / 165
ct8rows.sh results/golden_surelog.csv <fresh>: 0 differing ROWS (0 diff row-sides)  BOTH binaries
```

**No `results/*.csv` was written by me.** Nothing converted, so there is nothing
for the MASTER to promote.

My four sweep CSVs are **row-for-row identical** to the four the implementer kept
(`/tmp/r10svs12_{u2r,sl}_{ship2,pris2}.csv`), after normalising workdir paths:
`0` differing row-sides on each of the four (F1).

## 5. GATE 5 — BYTE VERIFIER, both corpora BOTH modes, vs MY OWN pristine ed1e6ce

```
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh /tmp/v12wd_{u2r,sl}_ship /tmp/v12wd_{u2r,sl}_pris

u2r     PATH_SETS_IDENTICAL (679)  MOVERS 0 / 679   SELFCHECK 678/679   SELFCHECK1 1
surelog PATH_SETS_IDENTICAL (953)  MOVERS 3 / 953   SELFCHECK 952/953   SELFCHECK1 4
  ./default/Scoreboard-59431470/slang.uhdm    ship=1ba839e9c608 pris=0163f3d48653   <- FALSE MOVER, §5.1
  ./default/SVSwitch-db796243/slang.uhdm      ship=4765452ab634 pris=65bf286fe24c
  ./testflags/SVSwitch-db796243/slang.uhdm    ship=4765452ab634 pris=65bf286fe24c
```

The two SVSwitch mover hashes are the implementer's, to the byte. **2 real
movers**, both the target, both modes; each binary's two mode databases are
`cmp`-identical, and the two `o.dump` md5s are `410069adae1ee78764f55c2dc4872bab`
(ship) / `37a64565dacdc7f8c9b681cbaf27ed8a` (pris) — again the implementer's.

### 5.1 `Scoreboard/default` — FALSE MOVER, and my run is a STRONGER proof (F11)

Three reps per binary, argv taken verbatim from the workdir's `cmds.txt`, run
from the test's own directory:

```
ship rep1 0163f3d486538b8a   rep2 0163f3d486538b8a   rep3 0163f3d486538b8a   bytes 11133449 x3
pris rep1 9cf807ea56e4e00d   rep2 9cf807ea56e4e00d   rep3 1ba839e9c6080f2e   bytes 11133449 x3
```

**THE BINARY ASSIGNMENT IS REVERSED FROM THE IMPLEMENTER'S RUN.** They measured
`9cf807ea`/`0735c667`/`1ba839e9` on the SHIPPED binary and `0163f3d4`/`1ba839e9`
on the PRISTINE one; I measured `0163f3d4` on the SHIPPED one and
`9cf807ea`+`1ba839e9` on the PRISTINE one. Same hash population, opposite
binaries, one size on all six runs. Content, measured:

```
msdist  ship_rep1 vs pris_rep1 (different md5s, different binaries) : 0   (1095684 lines both)
msdist  pris_rep1 vs pris_rep3 (different md5s, SAME binary)        : 0
msdist  the two SWEEP databases the verifier flagged                : 0
```

Nondeterminism, not a mover, on six instruments.

### 5.2 MOVERS PER SHAPE, BY MULTISET, vs GOLDEN's own count

`msmovers.sh <golden.uhdm> <pris slang.uhdm> <ship slang.uhdm>` — nine shapes,
the entire delta, and I re-counted every one directly with `grep -Fxc` on the
indent-exact line:

```
                                                                     GOLD PRIS SHIP
ADDED   (ind 4) \_port: , line:38:33, endln:38:38                       1    0    1
ADDED   (ind 8) \_port: , line:38:33, endln:38:38                       1    0    1
ADDED   (ind 6) \_ref_obj: (work@top.output_intf.Clock) 38:33-38:38     1    0    1
REMOVED (ind 4) \_port: (clock)                                         0    1    0
REMOVED (ind 8) \_port: (clock)                                         0    1    0
REMOVED (ind 6) \_ref_obj: (…output_intf.clock.Clock) 38:33-38:38       0    1    0
BARE FIELD lines (non-attributable)
ADDED   (ind 8) |vpiFullName:work@top.output_intf.Clock                 1    0    1
REMOVED (ind 8) |vpiFullName:work@top.output_intf.clock.Clock           0    1    0
REMOVED (ind 6) |vpiName:clock                                         29   26   25
```

Eight of nine land on GOLDEN's count exactly; the ninth is the AGGREGATE the
implementer flagged as a partial — GOLD 29 / PRIS 26 / SHIP 25 reproduces to the
unit, so the honest reading (our wrong line was masking a pre-existing deficit of
four) is confirmed rather than taken on trust.

The whole design delta, `diff -u` on the two `o.dump`s, is those **9 lines and
nothing else** (5 removed, 4 added; 25699 → 25698). Content instruments:

```
                        PRIS   SHIP
MULTISET DISTANCE       1333   1326
golden-only instances    476    473
ours-only instances      857    853
cmp HEAD DEPTH            54   1603   (a DEPTH, not a distance)
```

## 6. THE HEAD: CLEARED, AND THE DIRECTION PROVED TWICE (F3)

Pristine head, verbatim — the brief's head to the id:

```
LHS: / decompile: / port: , id:1164, line:38:33, endln:38:38
  |vpiParent: \_module_array: (work@output_interface), id:1161, 38:18-38:29
```

Shipped head:

```
LHS: <null>
RHS: program: work@testcase (work@top.TC), id:2954, 44:1-44:47
```

Both modes' `cmp.txt` are byte-identical on both binaries. Direction, twice:

* **compare order** — `design::Compare` reaches `AllModules()` at generated
  `design.cpp:302` and `TopModules()` at `:308`; six vectors apart.
* **dump location, which needs no argument at all** — the changed hunk is at
  `o.dump:16279`, under `|uhdmallModules:` (16172); the new head's program is at
  `o.dump:16898`, under `|uhdmtopModules:` (16876). The old head was in the DEF
  view, the new one is in the ELAB view.

A third, independent argument: `cmp` reports the FIRST divergence, our elab
program subtree is byte-identical on the two binaries (the whole delta is the
9 lines above), so if the new head were compared EARLIER it would have been the
pristine head too. It was not. **The head advanced.**

### 6.1 LOCALIZATION — the implementer's field audit is CORRECT (F4)

Read off the generated comparators myself:

```
BaseClass::Compare (UHDM/templates/BaseClass.cpp:163)  VpiType, VpiName, VpiDefName.  Nothing else.
ref_obj::Compare  (generated/src/ref_obj.cpp:122)      VpiType, basetype_t, VpiName, VpiDefName,
                                                       VpiGeneric, Actual_group, VpiStructMember.
                                                       ** NO VpiFullName **
ports::Compare    (generated/src/ports.cpp)            basetype_t, VpiPortIndex, VpiName, VpiPortType,
                                                       VpiScalar, VpiVector, VpiConnByName, VpiDirection,
                                                       VpiSize, VpiExplicitName, High_conn, Low_conn,
                                                       Typespec, Instance, Module_inst.
No comparator anywhere reads vpiLineNo / vpiColumnNo.
```

So the 54-line head was the port's `vpiName` alone, and r10svs11's R1 ("two
differences, both compared") is refuted as the implementer says. **And the fix is
better than the compared-field audit requires**: on the shipped binary arm `d1`
cell `h1`'s ENTIRE port subtree is byte-identical golden-vs-ours, so no
uncompared-but-real field is left over either.

**CAVEAT ON THE GRID'S "COMPARED EQ" COLUMN (F14):** that tally reads only the
port's `vpiName` and the HighConn's `VpiType`, while `ports::Compare` reads
twelve more fields. It is sound here (h1 is byte-identical), but it is a PROXY
and must not be read as "cmp-equal".

### 6.2 R1's successor head — confirmed, cell for cell

```
program::Compare field order (generated/src/program.cpp):
  basetype_t, VpiIndex, VpiType, Default_clocking, Instance_array, Interfaces,
  Expr_dist, Interface_arrays, Process, Cont_assigns, Clocking_blocks, Ports, …
golden elab `program work@testcase` subtree = 126 dump lines ; ours = 607  (delta 481)
own-indent field labels:  ours carries |vpiInterfaceArray:, golden does not;
                          NEITHER side carries |vpiInterface:  (so Interfaces() is not the failure)
the extra object: interface_array: (work@top.TC.output_intf) 18:95-18:106, 480 lines, vpiSize 4
```

R1 is exactly where the implementer put it, and it is pre-existing: our elab
program subtree is byte-identical on the two binaries.

## 7. THE GRID, RE-MEASURED, PLUS TEN CELLS THE PASS NEVER LOOKED AT

All four arms re-run on both of MY binaries (`TAG=v12pris|v12ship`), read with
`d1read.sh`. **The 34-cell grid reproduces exactly**: the pris→ship diff is
precisely h1, h10, m1, k1 (DIF→EQ), e3 (three fields → span only), m5 (DIF
content changed), m9 (name/span/fullname → golden's, HighConn kind remains), and
nothing else. **Not one cell regressed.** h8/h9/m7/m8 (the `ref_module` controls)
and k3–k7 (the `ifaceArr` fence) are byte-identical on both binaries.

Arm cmp heads, as a cross-check that no arm head went BACKWARD:

```
d1  pris/ship head both = module_inst work@top (vector-size failure elsewhere)   dump 201 -> 181
d2  pris/ship head both = module_inst work@top                                   dump 179 -> 161
d3  pris head = k1's port 32:11-32:16   ship head = k3's CONTAINER 36:5  (FORWARD) dump 241 -> 232
d4  pris/ship head both = module_inst work@top                                   dump 544 -> 539
```

### 7.1 EMPTY-PRODUCT HUNT — three phantom-container cells, not one (F6)

`portread.py` prints `OBJECT NOT FOUND on LHS golden side` and STOPS, so an
"absence cell" never reveals what OUR side built. Read our side directly:

```
d1 h3  if2 a3[4](Clock, Rst)   golden 0 containers   OURS 1 container, 2 ports
       pris: clk / NOSPAN / work@top.a3.clk.Clock  +  rst / NOSPAN / …a3.rst.Rst
       ship: <EMPTY> / 43:11-43:16 / work@top.a3.Clock  +  <EMPTY> / 43:18-43:21 / …a3.Rst
d4 e1  ifE e1[4](\Cl$ck , Rst) golden 0 containers   OURS 1 container, 2 ports
       pris: clk / NOSPAN / …e1.clk.Cl$ck  +  r$t / NOSPAN / …e1.r$t.Rst
       ship: <EMPTY> / 27:11-27:17 / …e1.Cl$ck  +  <EMPTY> / 27:20-27:23 / …e1.Rst
d2 m5  leaf3 #(1) b5[4](Clock, Rst)  golden 0        OURS 1 container, 2 ports   (the ONE cell §6.7 discloses)
d2 m3  leaf2 b3[4](Clock, Rst)       golden 0        OURS 0                      (genuinely symmetric)
```

h3 and e1 are interface arrays, so `udpFormInstantiation`'s container gate never
fires for them (`!useInterfacePath` guards it) — which is *why* they exist on our
side and why they belong in R8 alongside m5. The write-up's "the only cell in
this grid" is false, and the correct residue is **three** cells wide.

### 7.2 TEN NEW PORT CELLS (arms `v1_wildpass.sv`, `v2_posedges.sv`) (F5, F9)

Both arms run on both binaries; the containers are keyed by span as in `d1read.sh`.

```
cell  instantiation                     style        GOLDEN name / span / hc            PRIS  SHIP
w1    if1 w1[4](.*)                     WILDCARD     "" / 47:11-47:13 / constant(".*")  DIF   DIF   <- F5
w2    leaf1 w2[4](.*)                   WILDCARD     "" / 49:13-49:15 / constant(".*")  DIF   DIF   <- F5
w3    subif w3[4](wif)                  positional   "" / 52:13-52:16 / ref_obj …w3.wif DIF   EQ
      (actual is a SCALAR INTERFACE instance — the InterfaceModPort family)
w4    subifarr w4[2](warr)              positional   "" / 55:16-55:20 / ref_obj …w4.warr DIF  EQ
      (actual is an INTERFACE ARRAY through a module port — THE BRIEF'S NAMED IN-LAW SHAPE)
w5    if1 w5[3:0](Clock)                positional   "" / 57:13-57:18 / ref_obj …w5.Clock DIF EQ
x1    leaf2 x1[4](Clock, )              positional   "" / 44:13-44:18 / ref_obj …x1.Clock DIF EQ
      (EMPTY trailing terminal; golden mints ONE port, not two — so does ours)
x2    if2 x2[4](Clock, )                positional   "" / 46:11-46:16 / ref_obj …x2.Clock DIF EQ
x3    if1 x3[2][2](Clock)               positional   "" / 48:14-48:19 / ref_obj …x3.Clock DIF EQ
x4    leaf1 x4[4](x4inst.q)             positional   "" / 51:13-51:21 / hier_path        DIF   DIF*
x5    leaf1 x5[4]({Vec[0]})             positional   "" / 53:13-53:21 / operation  ours NONE DIF DIF
```

* **SIX MORE CELLS CONVERGE** (w3, w4, w5, x1, x2, x3) — including the two the
  brief actually cared about: an interface instance and an **interface array**
  reaching a module-array port positionally. The law's blast radius is wider than
  the write-up measured and it lands correctly everywhere it lands.
* `x4` **ADVANCES**: name and span become golden's and the fullname loses the
  formal; what remains is golden `hier_path` vs our `ref_obj` — the same
  HighConn-KIND residue as `m9` (R4).
* `x5` is R6's MODULE-array twin (a concatenation actual: `getSymbolReference()`
  is null, we mint no port where golden mints a nameless one with an `operation`
  HighConn). DIF-identical on both binaries — a fence, not a regression.
* **`w1`/`w2` are the refutation (F5).** Golden's `.*` port:

```
    \_port: , line:47:11, endln:47:13
      |vpiHighConn:
      \_constant: , line:47:11, endln:47:13
        |vpiDecompile:.*
        |STRING:.*
ours (BOTH binaries):
    \_port: (clk)            |vpiName:clk
      \_ref_obj: (work@top.w1.clk.clk) …
```

  Golden gives `.*` a NAMELESS port at the `.*` token with a string constant for
  a HighConn. The shipped law routes `.*` into its "NAMED" branch because
  `hasOrderedConns` is false for a `WildcardPortConnection`, so all three fields
  stay wrong. The rule golden actually follows is closer to *"only an explicit
  `.formal(...)` names the port"*, i.e. THREE styles, not two. Nothing regressed
  — but the law statement and the "STATED GATE == CODE GATE" claim need the third
  branch written down, and this is the highest-value new residue.

### 7.3 r10svs11's arms hold, and TWO of them ADVANCE (F10)

```
arm            pris dump / head            ship dump / head
c1_childkind   508 / module_inst           508 / module_inst        (identical)
c2_udpshape    807 / module_inst           807 / module_inst        (identical)
v1_gaps        434 / module_inst           434 / module_inst        (identical)
v2_gaps2       182 / port: , 18:12-18:17   173 / bit_var work@top.z1.m.clk   ADVANCED
v3_arr         767 / port: , 15:11-15:16   740 / interface_inst work@top.h1[0] ADVANCED
c3_ifacearray 1062 / (seed arm)            999                       improved
```

The two moving arms' PRISTINE heads are the *same nameless-broadcast-port shape*
as the SVSwitch head, and both CLEAR. `c3_ifacearray.sv`, the ops-named seed arm,
improves by 63 dump lines with no regression.

## 8. CANARIES — `InterfaceModPort` BY NAME, FIRST

```
InterfaceModPort    baseline default/testflags = CMP_EQUAL,,,differ
                    SHIP  = IDENTICAL      PRIS = IDENTICAL      GATE-5 byte-UNMOVED
BlackParrotComplex  baseline = CMP_EQUAL,,,differ ; SHIP/PRIS IDENTICAL ; byte-UNMOVED
u2r  canaries.sh    PRIS ok=8 changed=0 absent=0 (unknown-names=25, expected)
                    SHIP ok=8 changed=0 absent=0
     ctcan2.sh      PRIS/SHIP ok=1 changed=0 absent=0 unknown-patterns=6  EXPECT_UNKNOWN=6
     canaudit.sh    audited=29  UNCOVERED=0  FENCE-BREACH=0  (4 fenced names dispatched by no driver)
```

§6.6's reading of the source is CORRECT: `Surelog/tests/InterfaceModPort/top.v`
instantiates `mem_if miff(clk); memory_ctrl U_ctrl(miff); memory_model
U_model(miff); test U_test(miff);` — four SCALAR instances; `grep -nE '\[[^]]*\]\s*\('`
over the file returns NOTHING, so there is no instance array. But note **it is
still in-family in a way the pass did not test**: my `w3` cell is precisely
`memory_ctrl U_ctrl(miff)` promoted to an array, and it CONVERGES. The brief's
premise was about the right neighbourhood even though the file has no array.

## 9. CENSUS — RE-RUN, AND IT UNDER-SCANS (F7)

```
$ ./census12.sh            (its DEFAULT roots)
third_party/tests : 11 of 70   black-parrot Icarus OVMSwitch SVSwitch Tnoc UtdSV
                               UVMSwitch Verilator XilinxUnisimLibrary Yosys YosysTestSuite
uhdm2rtlil/test   :  2 of 734  arraycells simple_instance_array
$ ./census12.sh "$HOME/git-repos/Surelog/tests"      # THE ROOT THE DEFAULT OMITS
Surelog/tests     :  2 of 695  Gates LibraryIntercon
```

The surelog corpus is `Surelog/{tests,third_party/tests}` (703 + 70 dirs); the
script's default reads only the 70. **Census-predict is 15 test dirs, not 13**,
and the verifier found movers in 1. The two newly named carriers are accounted
for rather than assumed:

```
Gates            gate-primitive array -> no module_array   GATE-5: byte-UNMOVED both modes
LibraryIntercon  SLANG_REJECT in both modes (no database at all)
```

No conclusion changes — the byte verifier covers all 953 databases regardless —
but the "UPPER BOUND" framing does not survive skipping 91% of the corpus, and
§6.6 must drop "`census12.sh` does not name it" as evidence about
`InterfaceModPort`.

## 10. NIT (F8) — R7's arithmetic

The escaped-identifier span over-run is **+4 on the NAMED cells** (`e2` golden
`29:24-29:39` vs ours `29:24-29:35`; `e4` `33:11-33:26` vs `33:11-33:22`) but
**+5 on `e3`** (golden `31:11-31:22`, ours `31:11-31:17`), and line 31 is 19
columns wide so the over-run past the line end is +3, not +4. Uncompared either
way; the residue's substance (a pre-existing, style-independent Surelog escaping
artifact) is confirmed on both binaries.

## 11. RANKED RESIDUES AFTER THIS PASS

1. **R1 (unchanged, still first by a wide margin)** — the successor SVSwitch
   head: our elab `program work@testcase` carries an `interface_array
   (work@top.TC.output_intf)` (480 dump lines) that golden's does not;
   `program::Compare`'s `Interface_arrays()` with a null LHS. 481 of our 853
   ours-only line instances.
2. **R-NEW (F5) — the `.*` WILDCARD connection style**, third branch of the law:
   golden = nameless port at the `.*` token with a `constant(".*")` HighConn;
   ours = formal-named port with a `ref_obj`. Compared (the port's `vpiName` and
   the HighConn's `VpiType` both differ), and it is a one-line extension of the
   gate this pass already wrote. **Ranked immediately after R1** because it is
   compared, cheap, and in the very block just touched.
3. **R2/R3** — `.clk()` empty named actual (we emit no port) and the `.clk`
   shorthand (we emit a spurious HighConn); both already modelled by the
   `ref_module` writer (`emptyConn9`, the `!npcS->openParen` continue). One
   commit if taken together.
4. **R4 (widened by x4)** — a positional conn with a SELECT or HIERARCHICAL
   actual gets golden `bit_select`/`hier_path` and our `ref_obj`. `VpiType`, so
   compared. Two cells now (`m9`, `x4`), one cause: the select branch is gated on
   `npcA`, which a positional conn never has.
5. **R6 (widened by x5)** — non-`NamedValue` actuals: an INTERFACE array skips
   them all (`k3`–`k7`, 5 cells) and a MODULE array skips the ones
   `getSymbolReference()` cannot resolve (`x5`, concatenation). Vector-SIZE
   failures, so compared.
6. **R8 (widened to THREE cells, F6)** — we build a def-view container golden
   does not: `m5` (module array, positional, readable `#()`), `h3` and `e1`
   (INTERFACE arrays with ≥2 positional terminals, where the udp-form container
   gate cannot fire). Container-level, `udpFormInstantiation`'s territory.
7. **R5** — golden omits the formal in a `bit_select` HighConn's fullname even
   for a NAMED conn (`m10`, `k4`). Dump-only.
8. **R7 (F8)** — Surelog's escaped-id span over-run. Uncompared.
9. **R9** — the SVSwitch row's remaining multiset distance 1326 (golden-only 473,
   ours-only 853).

## 12. WHAT I RAN, AND CLEANUP

Worktrees: `/tmp/wt_r10svs12v` (patched ed1e6ce, mine) and
`/tmp/wt_r10svs12vpris` (pristine ed1e6ce, mine); `/tmp/wt_r10svs12vhead`
(patch-check against 575f51d) removed. Sweep CSVs kept at
`/tmp/v12_{u2r,sl}_{ship,pris}.csv`; SVSwitch cmp/dumps at
`/tmp/r10svs12v_{default,testflags}_{ship,pris}.{cmp.txt,g.dump,o.dump}`; grid
readings at `/tmp/r10svs12v_grid_{pris,ship}.txt`; Scoreboard reps at
`/tmp/r10svs12_sb/`. **The four sweep workdirs `/tmp/v12wd_{u2r,sl}_{ship,pris}`
were DELETED per the ops rule.** Arm workdirs
`/tmp/r10svs12_arm_v12{pris,ship}_*` (including the two new arms) are kept for
re-reading with `TAG=v12ship ./d1read.sh`.

New files this record adds to the repro dir: `v1_wildpass.sv`, `v2_posedges.sv`,
`README.verifier.md`.
