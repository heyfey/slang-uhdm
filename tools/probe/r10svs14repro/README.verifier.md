# r10svs14 — ADVERSARIAL VERIFIER RECORD

**VERDICT: PASS, with one SUBSTANTIVE finding, one landing-hygiene MUST-FIX, and
four reporting corrections.**

Every quantitative claim in the implementer's report reproduces on binaries I
built myself from `/tmp/r10svs14.patch` applied to a **FRESH `42c42f6`** worktree —
both md5s to the digit, all four sweep CSVs row-for-row, the 83-cell grid cell for
cell, the three-way per-shape mover table with GOLDEN's column, the 17-dir census,
the two-directional base marker, every canary, and the whole-database delta at its
exact line count. The **UNCONVERTED** verdict is correct and I re-derived it from
the harness myself: `SVSwitch` stays `CMP_NOTEQUAL` in both modes, so GATE 4 is
read with the **0-row-side** expectation, which is what both binaries give.

**THE SUBSTANTIVE FINDING (F2).** I wrote **68 cells the pass never wrote**, on the
three header-port data types its own §6.9 named as "a prediction, not a
measurement". The prediction is **REFUTED**: for `time`, `realtime` and
`shortreal`, Surelog models the interface's ANSI header port as a **`logic_net`**
while we model it as a `time_var` / `real_var` / `short_real_var`. The HOME view
was already wrong for those three; the deleted `SymbolKind::Net` filter
**accidentally MASKED it on the dup**, and `§ ifaceDupVarsAreHomeVars14` now
propagates it. **Three dup cells go EQ → DIF.** The report's "0 REGRESSED" is true
inside its 83 cells and **false outside them**. Exposure is **zero** in both
corpora (0 files carry such a header port), no gate moves, and no local filter can
fix it — `real` is a `real_var` in golden and must stay listed, so the split is in
our home view's net/var class, not in the dup. It is R3 below.

Every other adversarial probe came back in the patch's favour, several of them
**stronger than the pass claimed**: 12 prior-pass arm files (r10svs11/12/13) all
move toward golden with **zero removed lines**, one of them (`v3_arr`) from cmp
head 348 to **0**, which partly closes §6.9's third bullet.

Base commit `42c42f6`. Current branch head is `45716d3` (r10earl36 landed
`src/TypeEmit.cpp` after this pass's base) and the patch **`git apply --check`s
CLEAN there too**, so it needs no rebase.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here.

---

## 0. WHAT I BUILT, AND THE BASE OF EVERY BINARY I QUOTE

```
worktree                   git rev-parse HEAD                        porcelain
/tmp/wt_svs14v    (ship)   42c42f6b568463a800f7855115598873ee9f4caa   M src/ModuleEmit.cpp
                                                                     ?? tools/probe/r10svs14repro/
/tmp/wt_svs14vp   (pris)   42c42f6b568463a800f7855115598873ee9f4caa   <EMPTY>
/tmp/wt_svs14v_rb (rebase) 45716d32f8bedb149dac4be776e38afb1148e71c   <EMPTY>  (apply --check only)

md5(/tmp/wt_svs14v/build/slang-uhdm)  = 56adb99b1fcf35bff90a416d199cf650   32-HEX OK (len=32)
md5(/tmp/wt_svs14vp/build/slang-uhdm) = 1ca164075ce693c54c9d04045ae4624d   32-HEX OK (len=32)
```

**Both md5s are the implementer's, to the digit** — the build is bit-reproducible
across worktrees, which is itself a check that nothing in the patch depends on a
path or a timestamp. `Linking CXX executable slang-uhdm` + `Built target
slang_uhdm` were waited for in both builds; `error:` lines 0; compiler warning
count **identical at 20/20** (all pre-existing `-Wnarrowing` in `ExprEmit.cpp` /
`ModuleEmit.cpp`), so the 25 deleted executable lines left no unused parameter
behind. Source-level base marker: `grep -c ifaceDupVarsAreHomeVars14
src/ModuleEmit.cpp` = **1** ship / **0** pris; `cmp` of the two binaries DIFFERS.

`basemark.sh`, the pass's behavioural two-directional marker, run by me on both:

```
BIN=/tmp/wt_svs14vp/build/slang-uhdm md5=1ca164075ce693c54c9d04045ae4624d
  DUP work@top.c1  2: ['logic_var d', 'logic_var e']          <- COUNT 2, FIRST logic_var d
  HOME work@top.c1 3: ['bit_var clock', 'logic_var d', 'logic_var e']   <- CONTROL B
  DUP work@top.c2  2: ['logic_var d', 'logic_var e']          <- CONTROL A
BIN=/tmp/wt_svs14v/build/slang-uhdm  md5=56adb99b1fcf35bff90a416d199cf650
  DUP work@top.c1  3: ['bit_var clock', 'logic_var d', 'logic_var e']   <- COUNT 3, FIRST bit_var clock
  HOME work@top.c1 3: ['bit_var clock', 'logic_var d', 'logic_var e']   <- CONTROL B unchanged
  DUP work@top.c2  2: ['logic_var d', 'logic_var e']          <- CONTROL A unchanged
```

Both directions and both controls behave exactly as §5.1 states.

---

## 1. CONVERSION VERDICT — RE-DERIVED, NOT ACCEPTED

Committed baseline, quoted FIRST from the read-only `results/golden_surelog.csv`
(lines 1304–1305), then my own fresh sweep of the **shipped** binary:

```
committed  SVSwitch,default,CMP_NOTEQUAL,decompile:,,
           SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
fresh ship SVSwitch,default,CMP_NOTEQUAL,decompile:,,
           SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

**SVSwitch DID NOT CONVERT.** The world is the UNCONVERTED one; GATE 4's
expectation is **0 row-sides per mode**, and that is what both binaries give. No
`results/*.csv` was touched by me either.

### 1.1 The head, both binaries, measured by me

```
                     PRISTINE                            SHIPPED
cmp HEAD DEPTH       484                                 31          (both modes)
cmp HEAD OBJECT      interface_inst work@mem_interface    bit_var
                     (work@top.mem_intf) line:26:0        (work@top.output_intf[0].clock)
                     — the col-0 TAIL DUP                 LHS only, RHS <null>
o.dump md5           8417bab6ec5e1e2e351875153f21b394    51688c74c86c77153ef2212d61154cf0
o.dump lines         25694                                25700        (golden 25318)
dump content +/-     1352                                 1346
MULTISET DISTANCE    864                                  864
  golden-only            244                                 241
  ours-only              620                                 623
slang.uhdm md5-12    98b682118031                         a9b96265ef3d
```

Every one of these is the implementer's number. `g.dump` md5
`886fbfeb40956c7ced8b702809981c64` and `o_pris.dump` md5 `8417bab6…` are the two
hashes **r10svs13** reports, so the pristine binary I built is `42c42f6` itself and
not a look-alike. Both modes are byte-identical on both binaries (`cmp` run).

### 1.2 THE HEAD ADVANCED — and I checked the reach two independent ways

The direction claim rests on the comparator's field order. Read off the generated
source, not quoted from the report:

```
$ grep -n 'Programs()' ~/git-repos/UHDM/build/generated/src/instance.cpp
332:  if ((r = SafeCompare(lhs, lhs->Programs(), rhs, rhs->Programs(), context)) != 0) return r;
$ grep -n 'basetype_t::Compare\|Ports()\|Interfaces()\|Interface_arrays()' .../module_inst.cpp
370:  if ((r = basetype_t::Compare(other, context)) != 0) return r;
400:  Ports()      401:  Interfaces()      402:  Interface_arrays()
$ grep -n 'Ports()' .../program.cpp        221:  SafeCompare(... Ports() ...)
```

`Programs()` (332, reached through `basetype_t::Compare` at 370) precedes
`Interfaces()` (401) in the same invocation. **CONFIRMED: the head moved forward.**

Then I walked the failing object's ancestor chain in golden's dump by indent
column, which is the part a report can only assert:

```
16870  \_module_inst: work@top (work@top)
17512    |vpiInterface:                       <- Interfaces(), i.e. module_inst.cpp:401
17513    \_interface_inst: work@output_interface (work@top.output_intf[1])
17593      \_clocking_block: (work@top.output_intf[1].cb)
17609        \_event_control:
17613          \_operation:
17618            \_ref_obj: (work@top.output_intf[1].cb.clock)  -> |vpiActual: the bit_var
```

The owning field label is literally `|vpiInterface:`, and the program subtree
(`\_program: work@testcase (work@top.TC)`, line 16891) is a **sibling**, not an
ancestor. Independently: `cb.clock` appears **0 times** inside either side's
interface-array island subtree (golden lines 22305+, ours 22635+), so the object
is not reachable from inside `Programs()`. **The §1.4 reach claim holds.**

### 1.3 R1, the new head, verified at the byte level in golden

```
golden  output_intf[0].cb.clock   no vpiActual
        output_intf[1].cb.clock   vpiActual -> \_bit_var: (work@top.output_intf[0].clock)
        output_intf[2].cb.clock   vpiActual -> \_bit_var: (work@top.output_intf[0].clock)
        output_intf[3].cb.clock   vpiActual -> \_bit_var: (work@top.output_intf[0].clock)
        mem_intf.cb.clock         no vpiActual
ours    all four + the scalar     no vpiActual   (identical on BOTH binaries)
```

Exactly the `§ modportExprPort` "first elaborated instance" quirk the report names,
element **[0]** and elements 1..3 only. **PRE-EXISTING and unrelated to this law.**

---

## 2. THE FIVE GATES, INDEPENDENTLY, UNDER THE UNCONVERTED EXPECTATION

| gate | ship | pris | control |
|---|---|---|---|
| 1 BUILD | rc=0, link line, md5 asserted separately, 32-hex | rc=0, same | porcelain EMPTY on pris; `cmp` differs |
| 2 GOLDENS | **23 PASS / 0 FAIL** rc=0 | **23 / 0** rc=0 | `SLANG_UHDM=/bin/false` → **0 / 23, rc=1** (fires) |
| 3 u2r testflags j2 | 679 / 50 / 2; dump 496 match / 183 differ / 52 blank; **0 rows** | identical; **0 rows** | whole-row incl. dump column |
| 4 surelog both j2 | default 467/13/5/284/25; testflags 463/10/5/286/23 (+3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM); histograms unchanged; **0 rows** | identical; **0 rows** | `GOLDEN_DEFER` verified **UNSET** |
| 5 BYTE VERIFIER | u2r **0 / 679**, surelog **2 / 953** | — | SELFCHECK 678/679 and 952/953; SELFCHECK1 **1** and **3** |

Dump histograms, both modes, both binaries, identical to the committed baseline:
`default 327 blank / 242 differ / 225 match`, `testflags 331 / 298 / 165`.

The two movers, and there is no third:

```
MOVER ./default/SVSwitch-db796243/slang.uhdm    patched=a9b96265ef3d pristine=98b682118031
MOVER ./testflags/SVSwitch-db796243/slang.uhdm  patched=a9b96265ef3d pristine=98b682118031
MOVERS: 2 / 953
```

**Ship CSV and pris CSV are byte-identical to each other** on the surelog corpus
(`diff` of the sorted bodies, rc=0), which is a stronger statement than each being
0 rows against the baseline.

**AN OPS NOTE ON THE RACE, since the rules require attribution before excuses.**
A FOREIGN sweep (`r10earl37`, `--jobs 2`) was running on this machine during my
ship sweep — load average peaked at 7.3. Despite that, `SURELOG_FAIL` stayed at
25/23, `TIMEOUT` at 1 (`Google,testflags`) and every row matched the committed
baseline, so **no isolated re-run was needed** and nothing here is attributed to
load. `Scoreboard`, the three-hash flake r10svs13 had to chase, produced a
byte-identical database on both my binaries and did not appear as a mover.

### 2.1 Movers per shape, by multiset, against GOLDEN — reproduced exactly

```
                                                                     GOLD PRIS SHIP
ADDED  OBJ  ind 2  \_bit_var: (work@top.input_intf.clock) 38:37         2    1    2
ADDED  OBJ  ind 2  \_bit_var: (work@top.mem_intf.clock) 16:35-16:40     2    1    2
ADDED  OBJ  ind 2  \_bit_var: (work@top.output_intf[0].clock) 58:38     2    1    2
ADDED  FLD  ind 2  |vpiVariables:                                      38   44   47
TOTAL SHAPES MOVED  4
```

Whole-database delta, pristine → shipped: **3 hunks, +6 lines, 0 removals**, and
the six lines are three `\_bit_var:` / `|vpiVariables:` pairs. Nothing else moved.

### 2.2 THE ABSORBER ATTRIBUTION IS EXACT — I made §5.6 arithmetic

§5.6 blames the `|vpiVariables:` excess on R2's minted program port-view dups. I
broke the indent-2 label count down **by owning top-level object**:

```
owner (indent-0 tail object)                      GOLD  PRIS  SHIP
interface_inst (work@top.TC.input_intf)              0     4     4   <- MINTED, golden has none
interface_inst (work@top.TC.mem_intf)                0     5     5   <- MINTED, golden has none
interface_inst (work@top.input_intf)                 4     3     4   <- converged
interface_inst (work@top.mem_intf)                   5     4     5   <- converged
interface_inst (work@top.output_intf[0])             4     3     4   <- converged
TOTAL                                               38    44    47
```

`44 = 38 + 9 − 3` and `47 = 38 + 9`. **The entire excess is the two minted objects,
to the line**, and the three closed deficits are the three movers. §5.6's
refutation of its own headline ("multiset 864 → 864, and here is why") is correct
and now arithmetically closed.

### 2.3 Canaries, both binaries

```
canaries.sh   surelog  ok=52 changed=0 absent=0 unknown-names=7   ship AND pris
canaries.sh   u2r      ok=8  changed=0 absent=0 unknown-names=25  ship AND pris
ctcan2.sh     surelog  ok=58 changed=0 absent=0 unknown=1 (EXPECT_UNKNOWN=1)  both
ctcan2.sh     u2r      ok=1  changed=0 absent=0 unknown=6 (EXPECT_UNKNOWN=6)  both
canaudit.sh            audited=29  UNCOVERED=0  FENCE-BREACH=0
```

`InterfaceModPort` checked **BY NAME FIRST**, and its databases are
**byte-identical** ship vs pris in **both** modes (md5 `59a365f3ce2c`);
`BlackParrotComplex` likewise (`e3e354129d5a` / `73a10e8217e5`). All four rows are
byte-identical to the committed baseline (`CMP_EQUAL,,,differ`).

---

## 3. THE GRID — REPRODUCED CELL FOR CELL, THEN EXTENDED BY 68 CELLS

I re-ran both arms on both binaries in **my own** workdirs
(`/tmp/svs14v_arm_{pris,ship}_b{1,2}`) with the pass's own `dupread.py` and a
path-retargeted copy of `grid14.sh`, so the golden-identity assertion still fired.

```
arm       CELLS  held  CONVERGED  REGRESSED  stillDIF        implementer's claim
b1           36    31       5          0         0           36 / 31 / 5 / 0 / 0   MATCH
b2           25    16       3          0         6           25 / 16 / 3 / 0 / 6   MATCH
witness      22   (EQ 9 -> EQ 12)      0        10           EQ 9 -> 12            MATCH
```

Every individual cell value matched too, including the five b1 converged lists
(`c1` 3 = clock,d,e; `c4` int_var n; `c6` bit_var a,b; `c8` clock alone from an
EMPTY vector; `c9` no-modport) and b2's `d1` order refutation (`logic_var dat`
FIRST, `bit_var clk` SECOND, on both views, on both binaries).

### 3.1 EMPTY PRODUCT CELLS — HUNTED, NONE FOUND

`b1`'s "36 cells" from nine interfaces looked like an inflated product (9 × 3 = 27
is what the prose enumerates). It is not: `dupread.py` emits **four** own-listings
per interface — the DEF view, the elaborated HOME view, the col-0 tail DUP, and the
receiving port's own view — 9 × 4 = 36, and I printed all 36 with their keys. b2's
25 and the witness's 22 are likewise fully enumerated, the witness's 10 remaining
DIF being 4 island-naming (R4) + 6 minted `work@top.TC.*` (R2). **No cell in §3 is
asserted rather than produced.**

### 3.2 THE 68 CELLS THE PASS DID NOT WRITE — AND THE REGRESSION IN THEM

§6.9 bullet 2: *"It did not prove anything about `time`/`real`/`chandle`/`var
logic` header ports … the law is stated in terms of the home object's class
precisely so that they need no new rule — but that is a prediction, not a
measurement."* I measured it. Two new arms
(`v1v_kinds.sv`, 9 interfaces / 36 cells; `v2v_kinds2.sv`, 8 interfaces / 32 cells),
same shape as b1: modport, bare dot-free re-pass, one type per interface.

```
header port type      golden's home object    golden DUP lists it?  PRIS  SHIP  verdict
input real r          real_var                 YES                  DIF   EQ    CONVERGED
input byte b          byte_var                 YES                  DIF   EQ    CONVERGED
input integer x       integer_var              YES                  DIF   EQ    CONVERGED
input longint x       long_int_var             YES                  DIF   EQ    CONVERGED
input shortint x      short_int_var            YES                  DIF   EQ    CONVERGED
input int x           int_var                  YES                  DIF   EQ    CONVERGED
input e_t e (enum)    enum_var                 YES                  DIF   EQ    CONVERGED
input nib_t n (bit)   bit_var                  YES                  DIF   EQ    CONVERGED
input var logic v     logic_var                YES                  EQ    EQ    held (already right)
output bit o          bit_var                  YES                  EQ    EQ    held (already right)
input logic x         logic_net                no                   EQ    EQ    held
input sp_t sp         struct_net               no                   EQ    EQ    held
input logic signed[3:0] logic_net              no                   EQ    EQ    held
--------------------------------------------------------------------------------------
input time t          logic_net  (!)           no                   EQ    DIF   REGRESSED
input realtime x      logic_net  (!)           no                   EQ    DIF   REGRESSED
input shortreal x     logic_net  (!)           no                   EQ    DIF   REGRESSED
```

```
arm            CELLS  held  CONVERGED  REGRESSED  stillDIF   msdist PRIS -> SHIP
v1v_kinds         36    29       4          1         2        342 -> 338
v2v_kinds2        32    21       5          2         4        191 -> 185
```

**The mechanism, read out of golden's own dump** (not inferred): for `time`,
`realtime` and `shortreal` Surelog's home view puts the header port under
`|vpiNet:` as a **`logic_net`** —

```
golden, HOME view of  interface m1_if(input realtime x); logic d;
    |vpiVariables:
    \_logic_var: (work@top.m1.d)          <- ONE variable
    |vpiNet:
    \_logic_net: (work@top.m1.x)          <- the realtime port is a NET
$ grep -oE '\\_[a-z_]+: \(work@top\.m1\.x\)' g.dump | sort | uniq -c
      5 \_logic_net: (work@top.m1.x)
$ ... ours
      5 \_real_var: (work@top.m1.x)
```

so **our HOME view is already wrong for those three** (wrong class AND wrong
vector), the deleted `it.sym->kind == SymbolKind::Net` filter **masked it on the
dup**, and copying the home now propagates it. `real` is the discriminator that
kills any local fix: golden makes `real` a `real_var` and DOES list it, so a
"skip the float/time classes" guard in `makeIfaceRefDup` would break `real`,
`m8` and `k1`. **The fix belongs to the home view's net/var class for
`time`/`realtime`/`shortreal`**, and until then this law makes one wrong view into
two. That is R3.

**Bounding it, so it is a residue and not an alarm.** Corpus exposure is **zero**:

```
$ grep -rlE 'interface[[:space:]]+\w+[[:space:]]*\([^)]*\b(time|realtime|shortreal)\b' \
      ~/git-repos/Surelog/tests ~/git-repos/Surelog/third_party/tests ~/git-repos/uhdm2rtlil/test | wc -l
0
```

and the byte verifier's 2/1632 confirms it independently. **Both new arms are still
net CLOSER to golden** (msdist 342→338 and 191→185; `diff -u` content 528→522 and
343→337), because the 9 converged cells outweigh the 3 regressions.

`chandle`, the fourth type §6.9 names, is **UNREACHABLE**: slang rejects it —
`error: 'chandle' is not a valid type for a port` (`v3v_chandle.sv`) — so that
clause of the bullet is closed, not open.

### 3.3 TWELVE PRIOR-PASS ARMS — AND THEY ALL MOVE THE RIGHT WAY

The pass measured its own two arms and the witness. I ran every `.sv` in
`r10svs11repro`, `r10svs12repro` and `r10svs13repro` on **both** binaries.

```
arm (prior pass)        content PRIS -> SHIP   cmp head PRIS -> SHIP   added / removed
c1_childkind  (svs11)      508 -> 492            348 -> 60             16 / 0
c2_udpshape   (svs11)      807 -> 771           2390 -> 2390           36 / 0
c3_ifacearray (svs11)      999 -> 987            348 -> 60             12 / 0
v1_gaps       (svs11)      434 -> 416           1378 -> 1378           18 / 0
v2_gaps2      (svs11)      173 -> 165             60 -> 60              8 / 0
v3_arr        (svs11)      740 -> 734            348 -> **0**           6 / 0
a1_ifarrport  (svs13)     1904 -> 1900            32 -> 32              4 / 0
a2_scalariface(svs13)      874 -> 870            348 -> 60              4 / 0
a3_udpboundary(svs13)     3270 -> 3266           404 -> 404             4 / 0
a4_parentkinds(svs13)      887 -> 885            141 -> 141             2 / 0
v1_hunt       (svs13)     2828 -> 2820            50 -> 50              8 / 0
v3_genscope   (svs13)     BYTE-IDENTICAL (untouched)
d1..d4, v1, v2 (svs12)    ALL SIX BYTE-IDENTICAL (untouched)
v2_localdecl  (svs13)     slang-reject on BOTH binaries (deliberate arm)
```

**Content strictly DOWN in 11 of 11 movers, ZERO removed lines anywhere**, every
single delta line an added `\_*_var:` / `|vpiVariables:` pair (0 lines of any other
shape, checked by pattern), and `v3_arr` now compares **EQUAL** (cmp head 348 → 0).
Resync-immune multiset distance on six sampled arms: **CLOSER 4** (446/449/230/368
from 454/485/248/374), **SAME 2**, **WORSE 0**.

This partly closes §6.9's third bullet. "Byte convergence is UNPROVEN" is true *on
the witness*, where R2's absorber cancels it; on eleven arm databases it is
**proven**, and `§ udpShapedConnNoIfaceNet11`'s and
`§ progPortIfaceArrayUnowned13`'s own arms are among them.

### 3.4 InterfaceModPort as an IN-LAW CONTROL — measured, not asserted

The brief asks for InterfaceModPort's own shapes as controls. §5.4.1 argues by
construction; I measured the cells and then checked the source.

```
$ dupread.py g.dump o_ship.dump --all        (InterfaceModPort, default mode)
CELLS 7   EQ 6   DIF 1
  DUP  work@mem_if  work@interface_modports.U_ctrl.sif    EQ   (11 vars)
  DUP  work@mem_if  work@interface_modports.U_model.mif   EQ   (11 vars)
  DUP  work@mem_if  work@interface_modports.U_test.tif    DIF  golden ABSENT / ours 11  <- R2
  DUP  work@mem_if  work@interface_modports.miff          EQ   (11 vars)
  HOME work@mem_if  work@interface_modports.miff          EQ
  HOME work@mem_if  work@mem_if                           EQ   (0 vars)
  HOME work@mem_interface  work@mem_interface             EQ   (0 vars)
ship o.dump md5 == pris o.dump md5 (f354e0c0587f…)  -> ZERO byte movement
```

And the structural reason, from the test source:

```
$ grep -n 'mem_interface' ~/git-repos/Surelog/tests/InterfaceModPort/top.v
1:interface mem_interface(input bit clock);
21:endinterface :mem_interface        <- DECLARED, NEVER INSTANTIATED
$ ... the instantiated one:  mem_if miff(clk);   interface mem_if (input wire clk);
```

The only `bit`-header-port interface in the protected canary is **never
instantiated** (so it has no tail dup at all), and the one that is instantiated is
`input wire clk` → `logic_net`, excluded by the old rule and the new one alike
(= arm cell `c2`). **InterfaceModPort cannot move**, and its one DIF cell is R2,
already declared out of scope. The single 1 DIF is the same object the report
names (`U_test.tif`).

---

## 4. THE CODE — READ, NOT SKIMMED

```cpp
auto* vars = s.MakeVariablesVec();
if (home && home->Variables())
    for (auto* hv : *home->Variables())
        vars->push_back(hv);
if (!vars->empty())
    dup->Variables(vars);
```

* **STATED GATE == CODE GATE.** There is no gate. The claim is literally true.
* **THE ORDER DEPENDENCY IS SAFE, and it is the one thing that could have broken
  silently.** The new code reads `home->Variables()` **eagerly**, whereas the
  sibling rule `§ ifaceDupSharesHomePorts` three lines below is explicitly
  **deferred** (`pendingIfaceDupPorts`) because ports are drained late. So I
  checked the ordering rather than trusting it: `iface->Variables(vars)` is set at
  **line 23555** and the sole `makeIfaceRefDup` call is at **line 23877** in the
  same function — 322 lines earlier, and `grep -n '\->Variables('` shows **no
  later writer** to that vector. Safe today; it is an ordering invariant that a
  future deferred-variable drain would break silently, and it is not asserted in
  code.
* **THE DOUBLING PREDICATE REALLY IS ONE RULE NOW.** `tailDupShell` is created only
  when `wantTailDup`, and both of its producers pass `portView == nullptr`
  (`forceTailDup` at line 8549 with `/*portView=*/nullptr`, and the sibling scan at
  23116 guarded by `if (!portView …)`). So `home` is always the **non-port-view**
  home view, whose `dblVars9` is exactly the `boundToPlainGenericIfacePort(inst, …)`
  the deleted block recomputed. The two copies could not disagree in the shipped
  configuration, and now there is one.
* **NO ALIASING HAZARD.** The dup gets its own vector holding the home's object
  pointers — the same sharing shape as before. The one other place that copies this
  field (`tw->Variables(v)` at 5544, the interface twin) does `*v = *src->…` into a
  fresh vector and never mutates the source.
* **THE COMMENT'S OWN CHECK IS TRUE.** `grep -c 'makeIfaceRefDup(' src/ModuleEmit.cpp`
  = **3**, exactly as the comment claims (definition, comment, one call).
* **NO BOUNDARY COLLISION.** The patch is **ONE HUNK** (`@@ -22497,40 +22497,57 @@`).
  `§ progPortIfaceArrayUnowned13` lives at 8207/8298 — untouched.
  `§ udpShapedConnNoIfaceNet11`'s connection-site nets — untouched. Live
  `r10uvm66` is `src/StmtEmit.cpp` + `include/UhdmExporter.h`; live `r10earl37` is
  `src/ModuleEmit.cpp` at `@@2356`, `@@25482`, `@@25543`; landed `r10earl36` is
  `src/TypeEmit.cpp`. **No overlap with any of them**, and the patch
  `git apply --check`s clean on `45716d3`.

---

## 5. NUMBERED FINDINGS

**F1 — LANDING-HYGIENE MUST-FIX. The patch ships the PREVIOUS pass's verifier
record, misfiled as this pass's.**

```
$ md5sum tools/probe/r10svs1{3,4}repro/README.verifier.md
32dc5424f379e89869ba76ce5aa9e1ec  tools/probe/r10svs13repro/README.verifier.md   (already committed at 42c42f6)
32dc5424f379e89869ba76ce5aa9e1ec  tools/probe/r10svs14repro/README.verifier.md   (NEW in the patch)
$ diff tools/probe/r10svs13repro/README.verifier.md tools/probe/r10svs14repro/README.verifier.md
(identical)
$ head -1 tools/probe/r10svs14repro/README.verifier.md
# r10svs13 — ADVERSARIAL VERIFIER RECORD
```

663 of the patch's 2852 insertions are a byte-identical duplicate of a file
already in the tree, titled for the wrong pass and reporting against base
`550eac3`. §8 describes it as "the verifier's own notes, carried", so it was
deliberate — but under `r10svs14repro/` it reads as **this** pass's verifier
record, which it is not. **This file replaces it.** The master must take my
version, not the shipped one.

**F2 — SUBSTANTIVE. Three cells REGRESS, on the exact shapes §6.9 predicted away;
"0 REGRESSED" is scoped to the pass's own 83 cells.** Full evidence in §3.2. The
correct statement is: *0 regressed in 83 cells; 3 regressed in 68 cells the pass
did not write* (`time`, `realtime`, `shortreal` header ports), *all on shapes with
zero occurrences in either corpus*, root cause a pre-existing HOME-view net/var
class error that the deleted filter was accidentally masking. This does not block
landing — no gate, no canary and no corpus database moves — but it must be
recorded as R3 and the report's headline must be qualified.

```
$ bash armrun.sh tools/probe/r10svs14repro/v1v_kinds.sv     # then dupread.py g.dump o_{pris,ship}.dump --all
DUP work@top.k2   EQ->DIF  REGRESSED   golden ['logic_var d'] / pris ['logic_var d'] / ship ['time_var t','logic_var d']
$ bash armrun.sh tools/probe/r10svs14repro/v2v_kinds2.sv
DUP work@top.m1   EQ->DIF  REGRESSED   (realtime)
DUP work@top.m2   EQ->DIF  REGRESSED   (shortreal)
```

**F3 — REPORTING CORRECTION. "5 executable lines replace 34" is wrong in both
numbers; it is 3 replacing 25.**

```
$ awk 'NR<=95' /tmp/r10svs14.patch | grep '^+' | grep -v '^+++' | grep -vcE '^\+\s*(//|$)'    -> 3
$ awk 'NR<=95' /tmp/r10svs14.patch | grep '^-' | grep -v '^---' | grep -vcE '^-\s*(//|$)'     -> 25
   (50 added lines, 47 of them comment; 33 deleted lines, 8 of them comment)
```

The two surviving lines it counts (`auto* vars = …`, `if (!vars->empty()) …`) are
unchanged context. The change is smaller than advertised, which only strengthens
it — but the number is quoted in the summary and should be right.

**F4 — REPORTING CORRECTION. The stated mechanism over-generalises: slang does NOT
model "an interface's ANSI header port as a NetSymbol whatever its data type".**
It is DIRECTION-dependent. Cell `k9` is `interface k9_if(output bit o, input logic
i)`, and the **pristine** binary already listed `bit_var o` on the dup (EQ → EQ) —
so an OUTPUT header port of a variables-class type is a `VariableSymbol` and
survived the deleted filter; only INPUT header ports take the `NetSymbol` path
(b1's `output reg r` is excluded by the *class* rule, not the kind rule, which is
why it looked consistent). The **law** is untouched by this — copying the home is
precisely what makes the mechanism's exact shape irrelevant — but the sentence in
the code comment and in §2 is not true as written.

**F5 — REPORTING CORRECTION. Internal line-number inconsistency.** §1.3 cites
`module_inst.cpp:367` for the `basetype_t::Compare` call and §1.4 cites `:370`; the
generated source says **370**. Trivial, but §1.4's whole direction argument rests
on that line.

**F6 — CONFIRMATION, STRONGER THAN CLAIMED.** Twelve prior-pass arms, §3.3: eleven
move, all toward golden, **zero removed lines**, one reaching cmp head 0. §6.9's
"byte convergence UNPROVEN" is closed on eleven databases.

**F7 — CONFIRMATION.** InterfaceModPort measured cell-for-cell as an in-law
control and the structural immunity confirmed at source (§3.4): its `bit`-port
interface is never instantiated. Zero byte movement, rows identical.

**F8 — CONFIRMATION.** §5.6's absorber attribution is exact to the line
(§2.2): `44 = 38 + 9 − 3`, `47 = 38 + 9`, the `+9` being the two minted
`work@top.TC.*` objects. R2 is the whole excess.

**F9 — CONFIRMATION.** The `NAME` ops trap (refutation f) is real in this
environment: `env | grep '^NAME='` prints `NAME=tsungtso-ca`. `svsgen.sh` now uses
`TESTNAME`, guards the empty row (`|| { echo "NO ROW"; exit 6; }`), and I ran it
end-to-end on the shipped binary: `31` cmp lines and `1346` content in **both**
modes, row `CMP_NOTEQUAL` in both.

**F10 — CONFIRMATION.** No empty product cells anywhere in §3 (§3.1): 36 = 9 × 4,
and all 83 keys printed.

**F11 — CONFIRMATION.** `chandle`, the fourth type §6.9 leaves open, is
unreachable: slang rejects it as a port type. That clause is closed.

---

## 6. RANKED RESIDUES

**R1 — the new head. BLOCKING, PRE-EXISTING, 31 cmp lines, both modes.** Golden
binds `work@top.output_intf[1..3].cb.clock` to element **[0]**'s `bit_var`
(`§ modportExprPort`'s "first elaborated instance" quirk) and leaves `[0]`'s own
and the scalar `mem_intf.cb.clock` unbound; we leave all five unbound. Verified at
the byte level in golden, §1.3. Byte-identical on both binaries.

**R2 — we MINT program port-view `interface_inst` objects golden lacks entirely.**
Six fullnames in SVSwitch (`work@top.TC.{mem_intf,input_intf,output_intf[0..3]}`,
golden has **zero** of each), one in InterfaceModPort (`U_test.tif`), one in arm b2
(`x4.p`). Sits **on `§ progPortIfaceArrayUnowned13`'s declared boundary** and was
correctly NOT touched. It is the whole cause of the `|vpiVariables:` absorber
excess (§2.2) and therefore the reason the multiset distance did not move.

**R3 — NEW, mine. HOME-VIEW net/var class for `time` / `realtime` / `shortreal`
interface header ports.** Golden: `logic_net` under `|vpiNet:`. Ours: `time_var` /
`real_var` / `short_real_var` under `|vpiVariables:`. Pre-existing on the home
view; **newly propagated to the col-0 dup by this law** (3 cells EQ → DIF, §3.2).
Zero corpus exposure. **No local fix exists** — `real` must stay listed — so the
fix is the home view's class mapping for exactly those three types, after which
`§ ifaceDupVarsAreHomeVars14` becomes correct there for free.

**R4 — svs13's island naming.** Golden names the interface-array island's elements
port-relative (`output_intf.output_intf[i]`), we name them by instance path
(`work@top.TC.output_intf[i]`): 4 witness cells, unchanged by this pass.

**R5 — non-ANSI header-port ORDER on the HOME view.** b2 `d2`: golden `clk, dat`,
ours `dat, clk`, DIF on the home AND the dup on both binaries.

**R6 — unbound-generic-port DOUBLING over-fires on the HOME view**, and this law
now propagates it to the dup: b2 `d3` dup goes `[dat, dat]` → `[clk, dat, clk,
dat]` against golden's `[clk, dat]`. Multiset distance unchanged at 2 in both
directions (so not a regression by that metric) but the raw listing is **2 lines
longer** than pristine's. Disclosed by the implementer as CHANGED-NOT-CONVERGED;
I confirm the numbers and that b2's arm-level msdist is unchanged (284 → 284).

---

## 7. WHAT I RAN, AND WHAT IS LEFT ON DISK

Sweeps: `scripts/verify_golden.py --corpus surelog --mode both --jobs 2` and
`--corpus uhdm2rtlil --mode testflags --jobs 2`, once per binary, the two surelog
sweeps **SEQUENTIAL**. My four sweep workdirs (`/tmp/svs14v_wd_*`, **790 MB**) were
**DELETED** after GATE 5 read them. Kept: the four CSVs (`/tmp/svs14v_{sl,u2r}_{ship,pris}.csv`),
the witness and InterfaceModPort dumps and cmp reports (`/tmp/svs14v_scratch/{wit,imp}`),
the two arm workdirs per binary (`/tmp/svs14v_arm_{pris,ship}_b{1,2}`) and the
fifteen extra arm workdirs (`/tmp/svs14v_arm2_*`). Both binaries remain in
`/tmp/wt_svs14v{,p}/build/slang-uhdm` with the md5s in §0.

**New files this record adds to `tools/probe/r10svs14repro/`** (verifier artifacts,
outside the delivered patch):

```
README.verifier.md   this record (REPLACES the misfiled svs13 copy — F1)
v1v_kinds.sv         verifier arm 1 — 9 header-port kinds §6.9 left unmeasured, 36 cells
v2v_kinds2.sv        verifier arm 2 — bounds the k2 regression across 8 more kinds, 32 cells
v3v_chandle.sv       verifier arm 3 — chandle is not a legal port type (negative result)
```

---

## 8. VERDICT

**PASS.** The law is right, the localization is right, the head advanced and I
proved the direction from the generated comparators and the dump's own ancestor
chain rather than from the report. Five gates green on binaries I built, under the
correct UNCONVERTED expectation, with both negative controls firing. Two movers in
1632 databases, both the target, and the whole database delta is three two-line
insertions. The protected canary cannot move and I showed why from its source.
Eleven prior-pass arms move further toward golden with zero removed lines.

**Land it with two conditions:** (1) **F1** — drop the misfiled
`README.verifier.md` and take this file in its place; (2) **F2/R3** — amend the
"0 REGRESSED" headline to name its 83-cell scope and record R3, because
`§ ifaceDupVarsAreHomeVars14` propagates a home-view class error on
`time`/`realtime`/`shortreal` header ports that the deleted filter was masking.
F3, F4 and F5 are corrections to the write-up, not to the code.
