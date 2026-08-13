# r10svs13 — ADVERSARIAL VERIFIER RECORD

**VERDICT: PASS, with six reporting corrections and one landing-hygiene fix that
must happen before this lands.**

Every quantitative claim in the implementer's report reproduces on binaries I
built myself from `/tmp/r10svs13.patch` applied to a **FRESH `550eac3`** worktree
— both md5s to the digit, all four sweep CSVs row-for-row, the grid cell for
cell, the 325 mover shapes with GOLDEN's column, the census, the canaries, and
the three-hunk database delta at its exact line numbers. The **UNCONVERTED**
verdict is correct: `SVSwitch` stays `CMP_NOTEQUAL` in both modes, and GATE 4 is
therefore read with the 0-row-side expectation, which is what both binaries give.

The law is **stronger than the pass proved**. I wrote **14 cells it never wrote**
across two new arms and one over-fire probe, including the `.*` WILDCARD cell
that broke r10svs12's stated gate, a program in a for-generate and an
if-generate, two array ports on one program, a program two levels down, and both
port-dimension forms. **All 14 behave exactly as `§ progPortIfaceArrayUnowned13`
predicts; 8 converged, 6 module controls held, none regressed.** The one
conceivable over-fire cell — a program OWNING a non-port `interface_array` — is
closed by MEASUREMENT rather than by citing the LRM: slang rejects it outright,
and Surelog, which accepts it, gives that program `Interfaces=0
Interface_arrays=0` anyway.

Combined grid: **45 cells, EQ 26 → 44, DIF 19 → 1, NOT ONE CELL REGRESSED.**

**MY BYTE VERIFIER FOUND 2 MOVERS, NOT 3.** `Scoreboard/default` was
**byte-identical on my two binaries** (md5 `1aa19acbfee33ae6`, size 11133994 on
both) — a **fourth** distinct hash for that row, and independent confirmation
that the implementer's third printed mover was the named flake and not a mover
at all. My `SELFCHECK1` is therefore 3 (2 real + 1 corrupted), not 4.

Base: **`550eac3`** — stated plainly, I applied the patch to a fresh `550eac3`
worktree (`/tmp/wt_r10svs13ver`) and built a separate PRISTINE `550eac3`
(`/tmp/wt_r10svs13verp`). I *also* checked the patch against the CURRENT head
`3076437` and it applies clean there (§2.4). LHS is ALWAYS golden (Surelog); RHS
is ALWAYS ours.

---

## 1. FINDINGS, numbered, each with its command

### F1 — LANDING HYGIENE, MUST FIX: the patch ships the PREVIOUS pass's verifier record, verdict and all

```
$ cd /tmp/wt_r10svs13ver/tools/probe
$ md5sum r10svs12repro/README.verifier.md r10svs13repro/README.verifier.md
df94a066d1a958e5a125883f8b4db699  r10svs12repro/README.verifier.md
df94a066d1a958e5a125883f8b4db699  r10svs13repro/README.verifier.md
$ cmp r10svs12repro/README.verifier.md r10svs13repro/README.verifier.md   # identical
$ head -3 r10svs13repro/README.verifier.md
# r10svs12 — ADVERSARIAL VERIFIER RECORD
**VERDICT: PASS.** Every number in the implementer's report reproduces — ...
```

`tools/probe/r10svs13repro/README.verifier.md` in the deliverable patch is a
**byte-identical copy** of `r10svs12repro/README.verifier.md`: 513 lines of the
PREVIOUS pass's verifier record, titled for **r10svs12**, asserting **VERDICT:
PASS**, quoting base **`ed1e6ce`** and r10svs12's binary md5s. `README.md` §8
lists it as "the verifier's own notes, carried" — so it is deliberate, not an
accident, and that makes it worse: had this landed unamended, r10svs13's probe
directory would carry a PASS verdict that no r10svs13 verifier had written, over
a base commit this pass never touched, and the two `GOLDEN_DEFER` mentions the
implementer reports as "prose" (§1013, §1083 of the patch) are lines of that
stale file. **This file, which you are reading, replaces it.** No gate moves.

### F2 — MECHANISM: law clauses (b) and (c) are NOT independent; (b) is the load-bearing one

The law states three clauses — not in `Interface_arrays()`, no `vpiParent`, no
`vpiFullName` — and the write-up presents them as three producer decisions read
off one branch. Two of them are one decision:

```
$ sed -n '48,60p' ~/git-repos/UHDM/build/generated/src/instance_array.cpp
std::string_view instance_array::VpiFullName() const {
  if (!vpiFullName_) {
    const std::string fullName = ComputeFullName();
    if (!fullName.empty()) {
      const_cast<instance_array*>(this)->VpiFullName(fullName);   // LAZY, SELF-CACHING
$ sed -n '100,112p' ~/git-repos/UHDM/templates/BaseClass.cpp    # ComputeFullName walks VpiParent()
$ sed -n '114,120p' ~/git-repos/UHDM/build/generated/src/instance_array.cpp
    case vpiFullName: { std::string_view fullname = VpiFullName();
      if (!fullname.empty() && (VpiName() != fullname)) { ... }   # suppressed when == VpiName
```

`VpiFullName()` is a **lazy self-caching getter** that synthesizes from
`ComputeFullName()`, which **walks `vpiParent`**. Had the pass dropped only the
explicit `VpiFullName(prefix + "." + name)` and kept `VpiParent(m)`, the first
read (uhdm-dump does read it) would have **synthesized and cached**
`work@top.TC.output_intf` and the dump would look unchanged. What actually
suppresses the fullname is dropping the **PARENT**: with no parent
`ComputeFullName()` returns the bare `output_intf`, and
`GetVpiPropertyValue(vpiFullName)` prints nothing when the fullname equals
`VpiName`. Clause (c) is only observable because clause (b) holds. The code does
both and the behaviour is correct; the write-up's decomposition is not.

### F3 — §5.6's "the 110 FARTHER shapes have ONE cause" is INCOMPLETE, and the gap is a second real residue

```
$ ./msthree.sh <golden> <pris slang.uhdm> <ship slang.uhdm> > msthree.txt   # 325 shapes
$ python3 - # classify the 110 FARTHER rows
FARTHER 110
    96  carries work@top.TC.output_intf     <- the naming prefix (= their R2)
     4  bare-field absorbers (|vpiParent: x2, |vpiRange:, |vpiSize:64)
    10  NEITHER
```

The write-up says every FARTHER shape is a `work@top.TC.output_intf` line, a
header carrying that fullname, or one of three named absorbers. **Ten are none of
those**, and one of the ten is a distinct structural difference, not a naming
one:

```
ADDED  OBJ ind 4  GOLD 2  PRIS 2  SHIP 6   \_program: work@testcase (work@top.TC), ...
```

Measured cause, both sides, on the island's first element:

```
GOLDEN  elem[0] vpiParent -> \_interface_array: (a)        # the WRAPPER
OURS    elem[0] vpiParent -> \_program: work@leaf2p (work@top.p1)   # the PROGRAM
```

**Our island is only PARTLY unowned: the wrapper lost its parent, its four
elements did not.** Golden parents the elements at the wrapper; we still parent
them at the program, which is why the program's own header gains four extra
back-pointer reprints at the island's new indent. It is the same producer
decision as the naming (both follow golden's port-rooted view of the detached
island), which is why they move together — and it is **arm-wide and exactly
quantified** by the reprint gap:

```
arm a1   \_interface_array: occurrences  GOLDEN 38  OURS 22   gap 16 = 4 program cells x 4 elements
arm a3                                   GOLDEN 57  OURS 33   gap 24 = 6 program cells x 4 elements
```

Not compared (§2.3 verifies no `Compare` reads `vpiParent`), so no gate moves —
but R2 is TWO residues, not one, and the second one is the reason the byte block
does not shrink further.

### F4 — minor citation slip: one `udpShapedInstantiation` line number is the PRISTINE one

```
$ grep -n "udpShapedInstantiation(" /tmp/wt_r10svs13ver/src/ModuleEmit.cpp   # SHIPPED
1162: 1197: 2570: 8732:
$ grep -n "udpShapedInstantiation(" /tmp/wt_r10svs13verp/src/ModuleEmit.cpp  # PRISTINE
1162: 1197: 2570: 8696:
```

§6.3 gives the sites as "1162, 1197, 2570, 8696" and says "after this pass".
`8696` is pre-patch; post-patch it is `8732`. The **count is four** and the
"no fifth call site" refutation stands.

### F5 — minor: R4's span wording

R4 says our `interface_array` range span is "one column wider". Measured on the
SVSwitch island: golden `line:18:107, endln:18:108`, ours `line:18:106,
endln:18:109` — wider at **both** ends (ours spans the `[4]` brackets, golden
spans only the `4`). Two columns, not one. Dump-only; identical on both binaries.

### F6 — framing: the law's third clause is a statement about GOLDEN that the CODE cannot make here

```
$ sed -n '5633,5636p' src/ModuleEmit.cpp
bool progInst = !isTop && defMap[&def].mod && ... == UHDM::uhdmprogram;
UHDM::instance* m = progInst ? (UHDM::instance*)s.MakeProgram()
                             : (UHDM::instance*)s.MakeModule_inst();
$ grep -n "instGetInterfaceArrays\|instSetInterfaceArrays" -r src   # ONE call-site pair
src/EmitHelpers.h:1758  src/EmitHelpers.h:1765  src/ModuleEmit.cpp:8309  src/ModuleEmit.cpp:8312
```

`m` at the sole call site is `MakeProgram()` or `MakeModule_inst()` — never an
`interface_inst`. So the `uhdminterface_inst` arm of `EmitHelpers.h`'s three-way
dispatch is **unreachable from this branch**, and the reachable meaning of the
code gate is exactly *"module_inst OWNS, program DOES NOT"*. The law paragraph
and the in-code comment both assert "a `module_inst` and an `interface_inst`
parent OWN it normally", which is true of GOLDEN and untestable in our producer —
as §3.4/R3 elsewhere admit. **STATED GATE == CODE GATE holds on the reachable
domain**; the sentence overstates on the unreachable one.

---

## 2. WHAT I REPRODUCED

### 2.1 Patch hygiene and provenance

```
$ md5sum /tmp/r10svs13.patch           48dcfe946b7e4b20e82426027337c3d4   <- matches
$ wc -l /tmp/r10svs13.patch            2720                               <- matches
$ git apply --stat        21 files: src/ModuleEmit.cpp + tools/probe/r10svs13repro/ ONLY
$ git -C /tmp/wt_r10svs13ver apply -v  21 "Applied patch ... cleanly", no fuzz
$ git diff --stat 550eac3 -- .         src/ModuleEmit.cpp | 50 +   43 insertions(+), 7 deletions(-)
$ git diff --name-only 550eac3 -- results | wc -l     0     <- no results/*.csv touched
$ grep -cE '^\+.*[ \t]+$' /tmp/r10svs13.patch          0     <- no trailing whitespace
added lines 43 / comment lines 30 / EXECUTABLE 13     <- exactly as stated
```

Two hunks, both inside `emitInstance`'s iface-ARRAY-port branch:
`@@ -8203,10 +8203,34 @@` and `@@ -8271,12 +8295,24 @@`.

### 2.2 GATE 1 — BUILD, both binaries, md5 asserted separately, base printed and grep-checked

```
SHIP  /tmp/wt_r10svs13ver   [100%] Linking CXX executable slang-uhdm / Built target slang_uhdm
      rc=0  compiler "error:" lines 0
      md5 = ef883dda0ad1d34756d14d7d24fd6277   32-HEX ASSERT len=32 OK   <- MATCHES
      HEAD = 550eac3556355af2077f492891b5af45bed36c0d
      porcelain =  M src/ModuleEmit.cpp / ?? tools/probe/r10svs13repro/ (+ my own bld.log, cfg.log)
PRIS  /tmp/wt_r10svs13verp  [100%] Linking CXX executable slang-uhdm / Built target slang_uhdm
      rc=0  compiler "error:" lines 0
      md5 = 76e80298abdf4b2792ddc68f271798de   32-HEX ASSERT len=32 OK   <- MATCHES
      HEAD = 550eac3556355af2077f492891b5af45bed36c0d   porcelain EMPTY (bar my logs)
SOURCE grep-check   progPortIfaceArrayUnowned13:  ship src = 2, pris src = 0
SYMBOL grep-check   strings|grep -c on BOTH binaries = 0, SAID OUT LOUD — the law name is
                    comment-only, so a symbol grep would be a guard that does not guard.
```

**Both md5s are bit-for-bit the implementer's.** An independently reproduced
Release binary md5 is the strongest provenance statement available here, and it
also re-confirms the base: the pristine binary reproduces
`410069adae1ee78764f55c2dc4872bab` for SVSwitch's `o.dump`, the hash r10svs12
reports as its own SHIPPED value.

**BEHAVIOURAL BASE MARKER, two-directional** (`basemark.sh`, run on both):

```
                                                  PRIS   SHIP
a1 cell p1 (PROGRAM)  Interface_arrays               1      0     (a vector EMPTIED)
a1 tail `\_interface_array: (a)` at INDENT 0         0      4     (objects UNOWNED)
a1 cell m1 (MODULE)   Interface_arrays  CONTROL      1      1     (Interfaces 5 on both)
```

*Build note, for the record:* my first attempt built both worktrees
concurrently at `-j5` and `cc1plus` was **OOM-killed** on `ModuleEmit.cpp`
(15 GB box). The wrapper script exited 0 anyway. I rebuilt the shipped tree
alone after `rm build/slang-uhdm`, so the link line is real. Anyone re-running
these gates should build **sequentially**.

### 2.3 The compared-field claims, checked against the generated comparators

```
$ grep -n "SafeCompare" ~/git-repos/UHDM/build/generated/src/program.cpp
215 Interfaces   217 Interface_arrays   218 Process  219 Cont_assigns
220 Clocking_blocks   221 Ports                       <- 217 -> 221 is FOUR fields
$ sed -n '/instance_array::Compare/,/^}/p' .../instance_array.cpp | grep -c VpiFullName   0
$ grep -rn "VpiFullName().compare" .../generated/src/*.cpp | wc -l                        0
$ grep -rn "VpiParent()" .../generated/src/*.cpp | grep -ci compare                       0
$ sed -n '163,187p' ~/git-repos/UHDM/templates/BaseClass.cpp
   BaseClass::Compare reads VpiType, VpiName, VpiDefName.  Nothing else.
```

**Confirmed exactly as reported**: `Interface_arrays()` is the only compared half
of the law; `VpiFullName` is compared by **no** comparator anywhere, and
`vpiParent` by none. The head ADVANCE is 217 → 221 by compare order, four fields
inside the same `program` object — a direction argument, not a depth argument.

### 2.4 The head, cleared and advanced — both binaries, both modes

```
$ ./svsgen.sh <out> <binary>                            # the harness builds both argvs
                                    PRIS        SHIP        GOLDEN
row default / testflags        CMP_NOTEQUAL  CMP_NOTEQUAL      -    <- UNCONVERTED, said first
cmp HEAD DEPTH (not a distance)     1603         484            -
cmp HEAD OBJECT                program TC   iface tail dup      -
dump content +/-                    1882        1352            -
o.dump lines                       25698       25694        25318
o.dump md5                     410069ad...  8417bab6...        -
```

Head text, verbatim:

```
PRIS  LHS: <null>
      RHS: program: work@testcase (work@top.TC), id:2954, line:44:1, endln:44:47
SHIP  LHS: interface_inst: work@mem_interface (work@top.mem_intf), id:2472, line:26:0
      RHS: interface_inst: work@mem_interface (work@top.mem_intf), ... line:26:0
```

`line:26:0` with no `endln` = the **col-0 TAIL DUPLICATE**, and the new head is
two-sided (both sides print the object) where the old one was a one-sided vector.
Mode-to-mode: the two `slang.uhdm` are byte-identical (`cmp` run) and the two
`cmp.txt` are byte-identical, on **both** binaries.

**R1 measured directly, and PROVEN pre-existing:**

```
GOLDEN tail dup (ind 0, subtree 33)  Variables = 5:  bit_var clock FIRST, then 4 logic_var
OURS   tail dup (ind 0, subtree 31)  Variables = 4:  the 4 logic_var, clock MISSING
HOME view (ind 2, subtree 177)       Variables = 5 on BOTH sides, byte-identical
```

The tail dup sits at shipped line 21954, **outside all three changed hunks**
(hunk 2 ends at 17013, hunk 3 starts at 22626), so this pass did not cause it.

**The whole pris→ship database delta is THREE HUNKS**, at the reported
coordinates, net **−4** lines:

```
@@ -16933,487 +16933,6 @@   the 481-line wrapper subtree LEAVES the program
@@ -17494,7 +17013,7 @@      the port Low_conn ref's shallow reprint is renamed
@@ -23107,6 +22626,483 @@     ...and REAPPEARS at indent 0 in the weaklyReferenced tail
```

Tail placement verified positionally: `\_weaklyReferenced:` is at ship line
21566 and the island at 22629 (golden 21565 / 22305).

**And the patch applies clean to the CURRENT head too**: `git apply --check` on a
`3076437` worktree, rc=0. The only source change landed since `550eac3` is
r10uvm65's `src/TaskFuncEmit.cpp` (+93) — **a different file. No collision with
r10uvm65; none observed with r10earl36.**

### 2.5 THE GRID — 31 cells, both binaries, cell for cell

Reproduced from the pass's own arms and reader (`gridread13.sh`, `iaread.py`):

```
arm  cells   EQ          DIF        design-wide |vpiInterfaceArray:  GOLD / PRIS -> SHIP
a1      8    4 ->  8     4 -> 0        6 / 10 -> 6
a2      8    8 ->  8     0 -> 0        0 /  0 -> 0     (the SCALAR control: byte-identical)
a3     12    6 -> 12     6 -> 0        9 / 15 -> 9
a4      3    2 ->  2     1 -> 1        5 /  4 -> 4     (h1 pre-existing, OPPOSITE direction)
      ----  ---------   --------
       31   20 -> 30    11 -> 1
arm dump content:  a1 3852->1904   a2 874->874   a3 6290->3270   a4 887->887
```

Every cell verdict, every `Interfaces`/`Interface_arrays` pair and every census
line matches the report. **Not one cell regressed.**

**The `parse` column, re-derived independently** with `surelog -parse -nocache
-d ast` and mapped by source line — this is the pass's refutation of its own
brief, and it holds on all 20 cells:

```
a1  l35 p1 Udp_instantiation   l36 p2 Module   l37 p3 Module   l38 p4 Module
    l39 m1 Udp_instantiation   l40 m2 Module   l41 m3 Module   l42 m4 Module
a3  s1p/s1m Module   s2p/s2m Udp   s3p/s3m Module   s4p/s4m Udp   s5p/s5m Module   s6p/s6m Module
SVSwitch top.sv:44  `testcase TC (mem_intf,input_intf,output_intf);`  -> Udp_instantiation
```

So on the witness itself the brief's premise is true (udp-shaped) and its
conclusion false: `m1` and `s2m`/`s4m` are equally udp-shaped and golden OWNS
their wrapper, while `p2`/`p3`/`p4` and `s1p`/`s3p`/`s5p`/`s6p` are
`Module_instantiation`s and golden owns nothing. **The udp axis predicts nothing;
the parent's kind predicts every cell.** Using the udp predicate would have left
7 of 10 program cells wrong and broken 3 of 10 module cells, as stated.

**And the object is NOT spurious** — verified on golden's own arm dump, not
argued: golden's `a1` `g.dump` carries **4** indent-0 `\_interface_array: (a)`
listings in its `weaklyReferenced` tail (lines 3750, 4219, 4688, 5150), one per
program cell, named `(a)` with no fullname. Ours now carries 4 as well. Deleting
the wrapper would have traded a one-sided vector for a one-sided `Actual_group`.

### 2.6 MY OWN 14 CELLS — the empty-product-cell hunt

`/tmp/r10svs13v_arms/v1_hunt.sv`, `v3_genscope.sv`, `v2_localdecl.sv`, run
through the pass's own arm driver and reader on both binaries.

```
v1_hunt.sv  (9 cells)                            GOLD if/iarr   PRIS      SHIP
w1  leaf2p w1(.*)          program, WILDCARD        0 / 0        DIF 0/1   EQ 0/0
w2  leaf2m w2(.*)          module,  WILDCARD        5 / 1        EQ        EQ
x1  leafAAp x1(a, c2)      program, TWO arr ports   0 / 0        DIF 0/2   EQ 0/0
x2  leafAAm x2(a, c2)      module,  TWO arr ports   8 / 2        EQ        EQ
y2  top.y1.y2              program TWO levels down  0 / 0        DIF 0/1   EQ 0/0
z1  leaf1Sp z1(a1)         program, [1] dimension   0 / 0        DIF 0/1   EQ 0/0
z2  leaf1Sm z2(a1)         module,  [1] dimension   1 / 1        EQ        EQ
z3  leaf1Rp z3(a)          program, [3:0] range     0 / 0        DIF 0/1   EQ 0/0
z4  leaf1Rm z4(a)          module,  [3:0] range     4 / 1        EQ        EQ
      cells 9   EQ 4 -> 9   DIF 5 -> 0
      design-wide labels  GOLD 12  PRIS 18 -> SHIP 12  (EXACT)
      cmp HEAD DEPTH 967 -> 50    dump content 5466 -> 2828

v3_genscope.sv  (5 cells)                        GOLD if/iarr   PRIS      SHIP
gblk[0].gp   program in a for-generate             0 / 0        DIF 0/1   EQ 0/0
gblk[1].gp   second genvar iteration               0 / 0        DIF 0/1   EQ 0/0
iblk.ip      program in an if-generate             0 / 0        DIF 0/1   EQ 0/0
gblk[0].gm / iblk.im   the module controls         5 / 1        EQ        EQ
      cells 5   EQ 2 -> 5   DIF 3 -> 0
      design-wide labels  GOLD 4  PRIS 7 -> SHIP 4  (EXACT)
      cmp HEAD DEPTH -   dump content 3200 -> 1710
```

**`w1` is the cell that matters most.** r10svs12's stated gate broke on exactly
`.*`, because `hasOrderedConns` is false for a wildcard and the "NAMED" branch
swallowed it. This law reads **one enum and no syntax at all**, so `.*` cannot
reach it — and the cell proves it rather than assuming it. The gen-scope cells
matter for the same reason: `genvarConnFold` re-writes connection prefixes all
over this file, and the gate is blind to it.

**`v2_localdecl.sv` — the over-fire cell, CLOSED BY MEASUREMENT.** §3.4 argues
from LRM 24.3 that a program can only ever carry a PORT-VIEW
`interface_array`, so the gate needs no second clause. Measured:

```
$ SLANG_UHDM=<either binary> ./svs13arm.sh v2_localdecl.sv ...
NO_OUTPUT
v2_localdecl.sv:11:3: error: cannot instantiate an interface in a program
```

slang rejects it, so no such object can exist in our database whatever the gate
says. And Surelog, which **accepts** the file, gives it:

```
golden  program work@top.g1  Interfaces=0  Interface_arrays=0
golden  module  work@top.g2  Interfaces=2  Interface_arrays=0
```

**Golden's program owns no interface view of any kind — port or local.** The law
generalizes further than the pass claimed, and the missing second clause is
missing because it is unnecessary in both tools.

### 2.7 GATE 2 — GOLDENS with the negative control

```
SLANG_UHDM=<ship>      tests/check_goldens.sh   rc=0   PASS=23 FAIL=0
SLANG_UHDM=<pris>      tests/check_goldens.sh   rc=0   PASS=23 FAIL=0
SLANG_UHDM=/bin/false  tests/check_goldens.sh   rc=1   PASS=0  FAIL=23   <- control FIRES
```

The pass's own caveat is correct and worth repeating: none of the 23 goldens
instantiates a program with a whole interface-ARRAY port, so they prove this law
broke nothing and cannot confirm it. §2.5/§2.6 and GATE 5 are what confirm it.

### 2.8 GATE 3 — u2r `testflags --jobs 2`, both binaries

```
$ ct8rows.sh results/gate_uhdm2rtlil.csv /tmp/r10svs13v_u2rship.csv
731 ROWS both.  679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
dump: 496 match / 183 differ / 52 blank
WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)   PASS
$ ... /tmp/r10svs13v_u2rpris.csv    (pristine control)  0 differing ROWS   PASS
```

### 2.9 GATE 4 — surelog `--mode both --jobs 2`, `GOLDEN_DEFER` UNSET

**THE WORLD IS THE UNCONVERTED ONE, SAID FIRST.** `SVSwitch` is `CMP_NOTEQUAL`
in both modes in the fresh CSV, exactly as in the committed baseline, so the
expectation is **0 row-sides**, not 2 per mode.

```
default   : 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
testflags : 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL
            + 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM
dump histograms UNCHANGED:  default 327 / 242 differ / 225 match
                            testflags 331 / 298 differ / 165 match
WHOLE-ROW diff vs results/golden_surelog.csv:  0 differing ROWS   PASS   (SHIP)
                                               0 differing ROWS   PASS   (PRIS control)
diff(ship.csv, pris.csv) = EMPTY                                        (as the unconverted world requires)
```

BY NAME, first, as the rules require — baseline and fresh, both modes,
IDENTICAL:

```
InterfaceModPort     default/testflags  CMP_EQUAL,,,differ   ==  CMP_EQUAL,,,differ
BlackParrotComplex   default/testflags  CMP_EQUAL,,,differ   ==  CMP_EQUAL,,,differ
SVSwitch             default/testflags  CMP_NOTEQUAL,decompile:,,  ==  CMP_NOTEQUAL,decompile:,,
```

CANARIES, on **both** binaries' CSVs:

```
surelog  canaries.sh   ok=52 changed=0 absent=0 unknown-names=7   (SHIP and PRIS)
u2r      canaries.sh   ok=8  changed=0 absent=0 unknown-names=25  (SHIP and PRIS)
surelog  ctcan2.sh  EXPECT_UNKNOWN=1  ok=58 changed=0 absent=0 unknown=1  PASS (both)
u2r      ctcan2.sh  EXPECT_UNKNOWN=6  ok=1  changed=0 absent=0 unknown=6  PASS (both)
canaudit.sh ./canaries.sh ./ctcan2.sh   audited=29 UNCOVERED=0 FENCE-BREACH=0  PASS
```

Every number matches the report.

**CENSUS-PREDICT** reproduces, and `census13.sh` **has fixed** the under-scan the
r10svs12 verifier reported in `census12.sh` — it now walks
`Surelog/{tests,third_party/tests}`, all 761 dirs:

```
$ ./census13.sh
surelog: ariane  Google  SVSwitch  Verilator     -> 4 of 761 test dirs
u2r    :                                          -> 0 of 734 test dirs
UPPER BOUND: 4
```

and all three non-movers' explanations reproduce verbatim:

```
ariane     `program testbench ()`                     EMPTY port list; rows SURELOG_FAIL x2
Google     `program prog(input wire a, input wire b)` no INTERFACE port; SLANG_REJECT / TIMEOUT
Verilator  `program Prog (input si)`                  no INTERFACE port; SLANG_REJECT x2
```

### 2.10 GATE 5 — BYTE VERIFIER, both corpora both modes, vs a PRISTINE 550eac3 built here

```
$ SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh <ship wd> <pris wd>
u2r     : PATH_SETS_IDENTICAL (679)  MOVERS: 0 / 679
          SELFCHECK 678/679 flagged   SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953)  MOVERS: 2 / 953
          ./default/SVSwitch-db796243/slang.uhdm    patched=98b682118031 pristine=4765452ab634
          ./testflags/SVSwitch-db796243/slang.uhdm  patched=98b682118031 pristine=4765452ab634
          SELFCHECK 952/953 flagged   SELFCHECK1 = 3   (= 2 real movers + 1 corrupted)
```

**2 MOVERS, both the target, both modes, one hash per binary across the two
modes — and the mover hashes are the implementer's to the digit.** `Scoreboard`
never appeared: in my sweeps it produced

```
1aa19acbfee33ae6  11133994  <ship wd>/default/Scoreboard-59431470/slang.uhdm
1aa19acbfee33ae6  11133994  <pris wd>/default/Scoreboard-59431470/slang.uhdm
```

a **fourth** distinct hash for that row (the implementer saw `c71ab4fab332bb2c`,
`31586294781f692e`, `a6441eb4dfed…`), at the same constant size, **identical
across my two binaries**. That independently settles the implementer's call: the
row is the named nondeterministic flake, it is not a mover, and its handling
(3 reps on both binaries, MULTISET DISTANCE 0 four ways) was the right response.
Census over-count is 4:1 at the test-dir level — 4 predicted, 1 moved — with all
three non-movers explained above.

### 2.11 MOVERS PER SHAPE, BY MULTISET, against GOLDEN

```
$ ./msthree.sh <golden.uhdm> <pris slang.uhdm> <ship slang.uhdm>
TOTAL SHAPES MOVED                325
  CLOSER to GOLDEN's count        214
  SAME distance                     1
  FARTHER                         110      <- see F3: 96 naming + 4 absorbers + 10 relocation
  SHIP count == GOLDEN EXACTLY    204
$ ./msmovers.sh <golden> <pris> <ship>
MULTISET DISTANCE   PRISTINE 1326  ->  PATCHED 864
golden-only line instances  473 -> 244
ours-only   line instances  853 -> 620
```

All four `interface_array` object shapes land on golden's count **exactly**, and
the bare label goes to golden's 0:

```
ADDED   OBJ ind 0  GOLD 1 PRIS 0 SHIP 1   \_interface_array: (output_intf) 18:95-18:106
ADDED   OBJ ind 8  GOLD 1 PRIS 0 SHIP 1   \_interface_array: (output_intf) 18:95-18:106
REMOVED OBJ ind 4  GOLD 0 PRIS 1 SHIP 0   \_interface_array: (work@top.TC.output_intf)
REMOVED OBJ ind 8  GOLD 0 PRIS 1 SHIP 0   \_interface_array: (work@top.TC.output_intf)
REMOVED FLD ind 4  GOLD 0 PRIS 1 SHIP 0   |vpiInterfaceArray:
```

**§6.5's `msmovers.sh` display defect is real and I reproduced it.** Line 43
pipes the printed row through `sed -E 's/\t +/\t/'`, stripping the key's
indentation from the DISPLAY (the counting key keeps it, so the numbers are
sound). On this relocation it prints indistinguishable duplicate rows:

```
ADDED   +1  \_bit_var: (work@top.TC.output_intf[0].clock), line:58:38, endln:58:43
ADDED   +1  \_bit_var: (work@top.TC.output_intf[0].clock), line:58:38, endln:58:43
```

`msdist.sh` (lines 36–37) does **not** strip and is unaffected, confirming the
"same blindness, one file over" reading. Leaving `msmovers.sh` byte-unchanged and
adding `msthree.sh` was the right call.

### 2.12 BOUNDARIES — both named laws' arms re-run on both binaries

```
$ r10svs12repro/gridread.sh   d1_ifacearrayport d2_modarrayport d3_hcshape d4_escaped
                              v1_wildpass v2_posedges        (the verifier's arms too)
   all 6 arms: cmp HEAD DEPTH, dump content and hunk counts IDENTICAL on both binaries
   (2086/181, 1958/161, 125/232, 1038/539, 94/1132, 48/411)
$ r10svs11repro/gridread.sh   c1_childkind c2_udpshape c3_ifacearray v1_gaps v2_gaps2 v3_arr
   all 6 arms IDENTICAL on both binaries (348/508, 2390/807, 348/999, 1378/434, 60/173, 348/740)
$ git diff 550eac3 -- src | grep -cE "arrayBcastPortPositionalNoFormal12|udpShapedConnNoIfaceNet11"   0
```

`§ arrayBcastPortPositionalNoFormal12` (`emitModuleArray`) and
`§ udpShapedConnNoIfaceNet11` (connection-site nets) are untouched and their
arms — including `d1_ifacearrayport.sv`, which has an interface-ARRAY port and a
MODULE parent — are byte-invariant. **No collision.**

---

## 3. RANKED RESIDUES

**R1 (next head, blocking, PRE-EXISTING).** The col-0 TAIL DUPLICATE of a
modport-connected `interface_inst` omits the interface's own port variable from
`Variables()`: golden's `work@top.mem_intf` tail dup lists 5 (`bit_var clock`
first), ours 4. The HOME views carry 5 on both sides and are byte-identical.
484 cmp lines, both modes, byte-identical on both binaries, and structurally
outside all three of this pass's hunks. **Agreed with the implementer, verified
independently.**

**R2 (biggest remaining byte block, NOT compared) — and it is TWO residues.**
The unowned island is rooted at the PORT in golden and at the INSTANCE PATH in
ours, in two separate carriers:
* **R2a NAMING** — elements `output_intf.output_intf[i]` vs
  `work@top.TC.output_intf[i]`, and everything inside them; 96 of the 110 FARTHER
  shapes.
* **R2b PARENTAGE (new, F3)** — golden parents the island's elements at the
  **wrapper**; we still parent them at the **program**. Quantified arm-wide by
  the reprint gap (a1 38 vs 22 = 4 cells x 4 elements; a3 57 vs 33 = 6 x 4) and
  visible in the mover table as `\_program: (work@top.TC)` at ind 4 GOLD 2 →
  SHIP 6. Same producer decision as R2a, which is why they must be fixed
  together. Neither is compared (`instance_array::Compare` omits `VpiFullName`;
  no `Compare` reads `vpiParent`), and the design still closes 462 lines with
  both standing.

**R3 (one cell, opposite direction).** An `interface_inst` parent's port-view
`interface_array` is MISSING on our side (a4 h1: golden 1, ours 0), because `m`
in `emitInstance` is only ever a `module_inst` or a `program` (F6) and
`emitInterfaceInstance` never reaches this branch. Golden gives that wrapper a
path-qualified fullname (`work@top.h1.a`), i.e. an `interface_inst` parent owns
it exactly like a module. Unchanged by this pass.

**R4 (cosmetic, both views).** Our `interface_array` range subtree is 2 lines
longer in every cell: our folded `INT:1` bound carries a `vpiParent` golden's
does not, and our range span is wider at both ends (F5). Uncompared, identical
on both binaries.

**R5 (informational).** Golden reprints the wrapper more often than we do in
every arm (a1 38 vs 22, a3 57 vs 33, a4 12 vs 10) with own-listing counts equal.
This is not an independent residue — it is R2b and R3 measured a different way —
and it is the cheapest instrument for tracking them.

**NOT PROVEN, and the pass says so correctly (§6.7).** The island's compared
fields remain UNPROVEN EQUAL: after the fix `program::Compare` fails at
`Ports()` on `ports[0]` (`mem_intf`)'s `High_conn`, so `output_intf`'s
`Low_conn` — and the island — is never reached by the comparator on this test.
R1 must clear before the island's `VpiName`/`VpiSize`/`Ranges`/`Instances`
equality becomes a `Compare` result instead of a dump observation.

---

## 4. WHAT MUST HAPPEN BEFORE THIS LANDS

1. **Delete or replace `tools/probe/r10svs13repro/README.verifier.md`** (F1).
   This file does that; if the master lands from the patch as-is, the stale
   r10svs12 record lands with it.
2. Correct §5.6's "the 110 FARTHER shapes have ONE cause" and split R2 into
   R2a/R2b (F3) — the parentage half is the reason the byte block stalls.
3. Correct the (b)/(c) independence claim in §2's law paragraph (F2) and the
   `8696` line number in §6.3 (F4).
4. Optional, one sentence: say that the "an `interface_inst` parent OWNs it
   normally" clause describes golden and is unreachable in our producer (F6).

None of these moves a gate. The code is right, minimal (13 executable lines, one
enum, no syntax), transcribes a rule this file already carried for the sibling
vector, and is now verified on 45 cells instead of 31.

---

## 5. ARTIFACTS

```
worktrees   /tmp/wt_r10svs13ver   (patched 550eac3, md5 ef883dda0ad1d34756d14d7d24fd6277)
            /tmp/wt_r10svs13verp  (pristine 550eac3, md5 76e80298abdf4b2792ddc68f271798de)
            /tmp/wt_r10svs13verh  (3076437, apply-check only)
CSVs        /tmp/r10svs13v_{u2rship,u2rpris,slship,slpris}.csv
grids       /tmp/r10svs13v_grid_{pris,ship}.txt
my arms     /tmp/r10svs13v_arms/{v1_hunt.sv,v2_localdecl.sv,v3_genscope.sv}
witness     /tmp/r10svs13v_svs_{ship,pris}/   (dumps, cmp.txt, row.csv)
shapes      /tmp/r10svs13v_msthree.txt  /tmp/r10svs13v_msmovers.txt
parse       /tmp/r10svs13v_ast/
```

Sweep workdirs (`/tmp/r10svs13v_wd_*`, ~2 GB) DELETED after GATE 5.
