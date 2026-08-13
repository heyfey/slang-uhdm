# r10svs11 — ADVERSARIAL VERIFIER RECORD

**VERDICT: PASS.** No defect found in the shipped change. Every number in the
implementer's report reproduced independently, including both binary md5s;
the conversion claim (SVSwitch **DID NOT CONVERT**) is correct; the five gates
are green under the UNCONVERTED expectation; and my own empty-cell hunt found
**nine additional cells the pass fixes** that the implementer's grid never
measured, plus **one counterexample to the law AS STATED** which I prove cannot
be a regression.

Verified against **current head = BASE = `957974d`** (`git rev-parse HEAD` in
`/home/heyfey/git-repos/slang-uhdm` = `957974dabc7aacfb75ce00295ef363f70b189be0`,
identical to the brief's base), branch `auto5h`. The patch was applied to a
**fresh worktree of 957974d** that I created, and both binaries were built by me
from scratch.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, everywhere below.

---

## 0. WHAT I BUILT, AND THE STRONGEST SINGLE RESULT

```
worktree /tmp/wt_r10svs11v      patch applied   rev-parse 957974d
                                porcelain: ` M src/ModuleEmit.cpp` + `?? tools/probe/r10svs11repro/`
worktree /tmp/wt_r10svs11vpris  pristine        rev-parse 957974d   porcelain EMPTY
```

```
cmake -S <wt> -B <wt>/build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=/home/heyfey/.local \
      -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++
cmake --build <wt>/build -j 6
```

Both logs carry `[100%] Linking CXX executable slang-uhdm` **followed by**
`[100%] Built target slang_uhdm`, and `grep -c "error:"` = **0** on both.

```
SHIP  md5 = d4890e6fd39981373e5497b9eaf67e31    32-hex asserted separately: OK
PRIS  md5 = 8a7c07f418d3a567de0b24c6a5e90fe3    32-hex asserted separately: OK
                                                DISTINCT: OK
```

**BOTH MD5s ARE BYTE-IDENTICAL TO THE IMPLEMENTER'S.** An independent
worktree, an independent configure, an independent build — same two hashes. That
is the tightest possible reproduction of GATE 1, and it also means every
downstream measurement below is made on literally the same two binaries the
report describes.

BASE marker, printed and grep-checked on both:

```
grep -c udpShapedConnNoIfaceNet11 src/ModuleEmit.cpp        ship 2   pris 0
grep -c 'udpShapedInstantiation(child|inst)' src/ModuleEmit.cpp  ship 4   pris 2
```

---

## 1. THE CONVERSION CLAIM — REPRODUCED, ROWS QUOTED FIRST

`svsgen.sh` through the harness itself, both modes, on each binary:

```
SHIP   SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SHIP   SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
PRIS   SVSwitch,default,CMP_NOTEQUAL,decompile:,,
PRIS   SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
BASE   SVSwitch,default,CMP_NOTEQUAL,decompile:,,      (results/golden_surelog.csv)
BASE   SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

**SVSwitch DID NOT CONVERT — the report says so first and it is right.** No
`results/*.csv` was written by me or by the patch (`git status --porcelain
results/` EMPTY).

Every SVSwitch instrument, reproduced to the digit, identical in both modes
(`cmp.txt` byte-identical mode-to-mode on both binaries, checked with `cmp -s`):

| instrument | PRIS (mine) | SHIP (mine) | report |
|---|---|---|---|
| cmp HEAD DEPTH | 2680 | **54** | 2680 → 54 ✓ |
| dump content ± | 1912 | 1891 | 1912 → 1891 ✓ |
| o.dump lines | 25720 | 25699 | ✓ (golden 25318 ✓) |
| golden-only line instances | 476 | 476 | unchanged ✓ |
| ours-only line instances | 878 | 857 | −21 ✓ |
| MULTISET DISTANCE | 1354 | 1333 | ✓ |

---

## 2. LOCALIZATION — INDEPENDENTLY CONFIRMED, INCLUDING THE "WHICH FAMILY" CALL

The brief demanded the VECTOR-SIZE vs OWN-FIELD decision be made first. It is a
**vector-size mismatch**, and I confirmed it three ways rather than taking it:

1. **Both sides of the pristine head print the CONTAINER.** `cmp.txt` line 3 is
   `module_inst: work@top … id:4376` (LHS) and line 1321 is `module_inst:
   work@top … id:20` (RHS) — the `r=1 failLhs=<container>` signature, not an
   element pair.
2. **Depth-0 census, span-keyed, both sides** (`netread.py`, indent-walked so
   `vpiParent`/`vpiActual` reprints are not counted):

   ```
   vpiParent 1/1   vpiProcess 1/1   vpiModuleArray 1/1   vpiRefModule 3/3
   vpiNet    1/4   <-- THE ONLY DIFFERING FAMILY, and it differs in SIZE
   ```
   The three extras are `work@top.{mem_intf,input_intf,output_intf}` at
   44:14-44:22 / 44:23-44:33 / 44:34-44:45 — the actual spans of
   `testcase TC (mem_intf,input_intf,output_intf);` (top.sv:44).
3. **`Nets()` really is the FIRST failing comparison**, read off the generated
   source rather than argued: `instance::Compare` compares `Nets()` at
   `UHDM/build/generated/src/instance.cpp:336`, and `module_inst::Compare`
   reaches `instance::Compare` through `basetype_t::Compare` at
   `module_inst.cpp:370` — i.e. *before* `Module_array()` (`:398`),
   `Process()` (`:403`) and `Ref_modules()` (`:417`). The empirical proof is the
   advance itself: the shipped head is the `port` of `module_array`, which is
   compared at `:398`, strictly after `Nets()`.

**The brief's two named suspects are REFUTED, as the report says.** R2
(parameterized-class name span) and R3 (interface-class handle) cannot be the
pair: the failing comparison is `lhs->size() - rhs->size()` on an integer, and
neither shape appears in `work@top` at all.

---

## 3. THE GRID — REPRODUCED CELL FOR CELL ON BOTH BINARIES

I ran `gridread.sh` for all three arms against **both** binaries (see §7 F5 for
a trap this exposed).

| arm | cells | golden n / ours n PRIS | golden n / ours n SHIP | EQ pris→ship | DIFF pris→ship |
|---|---|---|---|---|---|
| c1_childkind | 9 | 9 / 9, all BOTH | 9 / 9, all BOTH | 9 → 9 | 0 → 0 |
| c2_udpshape | 19 | 10 / 10 with **5 GOLDEN-ONLY + 5 OURS-ONLY** | 10 / 10, all BOTH | 9 → 19 | 10 → 0 |
| c3_ifacearray | 8 | 4 / 7, **3 OURS-ONLY** | 4 / 4, all BOTH | 5 → 8 | 3 → 0 |
| **total** | **36** | | | **23 → 36** | **13 → 0** |

The c2 pristine split is exactly the report's two-directional claim, and I read
the names off the dump rather than the table:

* **OURS-ONLY (the OVER-MINT, 5)** — `e2a e2b e3a e3b e3c`: all-interface
  udp-shaped lists, `mixed9` false, golden mints nothing. SVSwitch's own shape.
* **GOLDEN-ONLY (the UNDER-MINT, 5)** — `e6i e7i e8i e12i e14i`: operation-first,
  literal-first, single-terminal-with-a-free-port, empty-terminal, and
  `#(1,2,3)`. Golden mints all five; the old predicate minted none.

Dump content on the arms moved the right way and never the wrong way:
c1 508→508, c2 853→**807**, c3 1083→**1062**.

**Not one cell regressed.** Every cell EQ on pristine is EQ on shipped.

---

## 4. THE FIVE GATES, RUN INDEPENDENTLY UNDER THE RIGHT EXPECTATION

### GATE 1 — BUILD
§0. Absolute paths, link line waited for, md5 asserted separately, 32-hex
checked, both worktrees' `rev-parse` and `status --porcelain` printed.

### GATE 2 — GOLDENS + negative control
```
SLANG_UHDM=/tmp/wt_r10svs11v/build/slang-uhdm tests/check_goldens.sh   ->  23 PASS / 0 FAIL
SLANG_UHDM=/bin/false                          tests/check_goldens.sh   ->   0 PASS / 23 FAIL
```

### GATE 3 — u2r `testflags --jobs 2`, own `--out`/`--workdir`
```
SHIP  679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL   dump 496 match / 183 differ / 52 blank
PRIS  679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL   dump 496 / 183 / 52
WHOLE-ROW vs results/gate_uhdm2rtlil.csv:  SHIP 0 row-sides   PRIS 0 row-sides
ct8rows.sh: 731 ROWS both, "PASS: every row byte-identical to the committed baseline"
```

### GATE 4 — surelog `--mode both --jobs 2`, `GOLDEN_DEFER` UNSET
**UNCONVERTED WORLD — stated first, and the numbers are the unconverted ones:**
```
SHIP  default   467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
      testflags 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL
                (+ 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM)
PRIS  identical in every bucket, both modes
dump histograms: default 327 blank / 242 differ / 225 match  — IDENTICAL to baseline
                 testflags 331 blank / 298 differ / 165 match — IDENTICAL to baseline
WHOLE-ROW vs results/golden_surelog.csv:  SHIP 0 row-sides   PRIS 0 row-sides
ct8rows.sh: 1588 ROWS both, "PASS: every row byte-identical to the committed baseline"
```
This is the `467/13` + `463/10` UNCONVERTED expectation the ops rules name,
met exactly, with the histograms unchanged and 0 rows.

### GATE 5 — BYTE VERIFIER, both corpora, vs the pristine 957974d I built
```
u2r      PATH_SETS_IDENTICAL (679)   MOVERS 0 / 679
         SELFCHECK 678/679 flagged   SELFCHECK1 = 1
surelog  PATH_SETS_IDENTICAL (953)   MOVERS 2 / 953
         SELFCHECK 952/953 flagged   SELFCHECK1 = 3  (= 2 real movers + 1 corrupted)

  MOVER ./default/SVSwitch-db796243/slang.uhdm    ship 65bf286fe24c  pris a3af5adfe82e
  MOVER ./testflags/SVSwitch-db796243/slang.uhdm  ship 65bf286fe24c  pris a3af5adfe82e
```

**MY SWEEP FLAGGED EXACTLY 2 MOVERS, NOT 3 — `Scoreboard/default` DID NOT MOVE
AT ALL FOR ME.** That independently settles the report's false-mover argument
from the other side. Stronger still, the ops rule's own instruments:

```
my SHIP Scoreboard/default   md5 1ba839e9c6080f2eecca070cd45a7a5e  bytes 11133449
my PRIS Scoreboard/default   md5 1ba839e9c6080f2eecca070cd45a7a5e  bytes 11133449
```

The two binaries produced the **same hash** in my run — and `1ba839e9…` is
precisely the hash the report identified as being emitted by **both** binaries
in its 3-rep. Same byte size on my two runs and on all six of theirs.
`Scoreboard/default` is a FALSE MOVER, confirmed on an instrument the
implementer did not have (a second, independent sweep).

**MOVERS: 2 real, both the target, both modes.** Census-predict was run before
the verifier and reproduces: `29 of 70` surelog dirs, `53 of 734` u2r dirs — an
upper bound overshooting by 41× and reported as such (but see F2).

### 4.1 Per-shape movers vs GOLDEN, by MULTISET (`sed 1d` on every dump)

`msmovers.sh` on the SVSwitch triple. **ADDED shapes: NONE.**

| | GOLD | PRIS | SHIP |
|---|---|---|---|
| REMOVED +1 `\_logic_net: (work@top.mem_intf) 44:14-44:22` | **0** | 1 | **0** |
| REMOVED +1 `\_logic_net: (work@top.input_intf) 44:23-44:33` | **0** | 1 | **0** |
| REMOVED +1 `\_logic_net: (work@top.output_intf) 44:34-44:45` | **0** | 1 | **0** |
| REMOVED +3 `\_module_inst: work@top … 12:1-73:10` | **28** | 31 | **28** |

Counted by `grep -Fc` against golden's own dump, ADDED and REMOVED separately,
never netted. **All four land on golden's count EXACTLY.** Non-attributable
absorbers, listed not counted: `|vpiNet:` −3, `|vpiParent:` −3, `|vpiNetType:1`
−3, and one `|vpiName:` + `|vpiFullName:` per net. 6 object-line instances + 15
field-line instances = **21**, closing `878 → 857` exactly.

### 4.2 CANARIES — baseline FIRST, mode-matched, the two named ones BY NAME
```
PRIS-u2r      canary rows: ok=8   changed=0 absent=0 unknown-names=25
PRIS-surelog  canary rows: ok=52  changed=0 absent=0 unknown-names=7
SHIP-u2r      canary rows: ok=8   changed=0 absent=0 unknown-names=25
SHIP-surelog  canary rows: ok=52  changed=0 absent=0 unknown-names=7
ctcan2 surelog  EXPECT_UNKNOWN=1 -> ok=58 changed=0 absent=0 unknown-patterns=1  PASS
ctcan2 u2r      EXPECT_UNKNOWN=6 -> ok=1  changed=0 absent=0 unknown-patterns=6  PASS
canaudit        audited=29  UNCOVERED=0  FENCE-BREACH=0                          PASS
```
The pristine CSVs were run through the canaries **before** the shipped ones, and
each against its own corpus's committed baseline. By name, before any aggregate:
```
InterfaceModPort    base default/testflags CMP_EQUAL,,,differ   ship IDENTICAL
BlackParrotComplex  base default/testflags CMP_EQUAL,,,differ   ship IDENTICAL
```
Both rows carry `differ` in the dump column, so the CSV alone is blind inside
them — GATE 5's 0/679 and 2/953 is what actually covers them, and it does.

---

## 5. PATCH HYGIENE, PREDECESSOR ARMS, LIVE AGENTS

**Hygiene — clean.** `git apply --check` succeeds against a fresh 957974d
worktree; md5 `2cd50b3391783802fc225d6d89f39bfb` matches
`/tmp/r10svs11.patch.md5`. 17 files, **1784 insertions / 11 deletions**. Every
path is either `src/ModuleEmit.cpp` or under `tools/probe/r10svs11repro/` —
the "outside the allowed set" filter prints nothing, and `results/`/slang hits
are **0**.

The executable delta really is four lines. Mechanically extracted (all `+`
lines that are not comment, all `-` lines that are not comment):

```
ADD: +            if (udpShapedInstantiation(child))
ADD: +                continue;
ADD: +        if (udpShapedInstantiation(child))
ADD: +            continue;
DEL: -            {  bool mixed9 = false; … if (hasOrderedConns(child) && mixed9) continue; }   (8 lines)
```

No dead code left behind: `hasOrderedConns` still has 5 call sites in
`ModuleEmit.cpp` (6 before, the removed one is `mixed9`'s) plus its definition.
`udpShapedInstantiation` itself is **unchanged** — I diffed `EmitHelpers.h`
between the worktrees and it is byte-identical.

**STATED GATE == CODE GATE.** The two gates are literally
`if (udpShapedInstantiation(child)) continue;`, read out of the built source, and
the scalar one sits in exactly the slot `mixed9` occupied (before the
`ifaceConnNet` duplicate check), so the clause ordering is unchanged. No
name-reading gate is involved, so the escaped-identifier rule is vacuous here.

**r10svs10's arms hold.** All four, on both binaries, every instrument identical:
```
c0_onethis   ship/pris  PASS_CMP  DUMP_MATCH
c1_scopetop  ship/pris  PASS_CMP  DUMP_DIFF content=44  hunks=4
c2_header    ship/pris  PASS_CMP  DUMP_DIFF content=10  hunks=4
c3_kinds     ship/pris  CMP_FAIL  lines=7782  DUMP_DIFF content=114 hunks=27
```
The predecessor's grid is untouched by this pass.

**Live agents — NO COLLISION.**
* `r10uvm64` (`/tmp/wt_r10uvm64`) touches `src/ExprEmit.cpp` +
  `include/UhdmExporter.h`. **No file overlap.**
* `r10earl35` (`.claude/worktrees/r10earl35`) touches `src/ModuleEmit.cpp` —
  the **same file**, at hunks `@@ -300`, `@@ -304`, `@@ -307`, `@@ -855`,
  `@@ -861`; r10svs11's are at `@@ -1097` and `@@ -1142`. ~200 lines apart, and
  functionally disjoint (pkg-struct typespec in the module header vs
  connection-site nets). **Proved rather than argued**: I applied
  `/tmp/r10svs11.patch` to a fresh 957974d worktree and then
  `git apply --check`'d r10earl35's ModuleEmit diff on top — **clean**. Either
  order lands. Report as same-file, sequence-only.

---

## 6. EMPTY PRODUCT CELLS — THE HUNT, AND WHAT IT FOUND

The grid's axes are (terminal count) × (first-terminal syntax) × (all-interface
vs mixed) × (list kind) × (`#()` shape). `udpShapedInstantiation` has branches
the grid never reaches, and — decisively — **`mixed9` and
`udpShapedInstantiation` disagree on some of them**, so those cells are
SHIP ≠ PRIS with nothing measured. I built three arms for them
(`v1_gaps.sv`, `v2_gaps2.sv`, `v3_arr.sv`, all in this directory) and read every
cell against golden on **both** binaries.

### 6.1 NINE MORE CELLS, ALL FIXED BY THE PASS

| cell | shape | GOLDEN | PRIS | SHIP | |
|---|---|---|---|---|---|
| w1i | `kp #(.P1(1)) v1 (w1i, Clock)` — **NAMED** `#()` override | MINT 46:18 | NONE | MINT 46:18 | **FIXED** |
| z1 | `k2 z1 (arr[0], x1)` — **element-select first, ALL-INTERFACE** | NONE | MINT | NONE | **FIXED** |
| z2 | `k2 z2 (y1.MP, y2)` — **member-access first, ALL-INTERFACE** | NONE | MINT | NONE | **FIXED** |
| t1 | `a3m t1 (Clock, h1)` — **ARRAY actual SECOND** in a udp list | NONE | MINT | NONE | **FIXED** |
| h3 | `a2m t2 (h2, h3)` — all-array udp-shaped list | NONE | MINT | NONE | **FIXED** |
| w6b, w8b | scalar all-interface udp lists at a second site | NONE | MINT | NONE | **FIXED** ×2 |
| **w6a** | **ANCHOR (scalar):** `k2 v6 (w6a,w6b)` udp **then** `k1 v7 (.m(w6a))` | MINT **57:11** | MINT **56:8** | MINT **57:11** | **FIXED — including the SPAN** |
| **h2** | **ANCHOR (array):** `a2m t2 (h2,h3)` udp **then** `a1m t3 (.m(h2))` | MINT **22:12** | MINT **21:9** | MINT **22:12** | **FIXED — including the SPAN** |

The two ANCHOR cells matter most. The implementer's grid **excluded them by
construction** — "every interface instance in every arm is connected to exactly
one child, so the multiple-children clause cannot confound any cell". That kept
the grid clean but left the interaction between the new skip and the
`ifaceConnNet` first-site anchor entirely unmeasured, in **both** minting loops.
Measured here, golden anchors the single net at the **non-udp** site; pristine
anchored it at the udp site, so pristine was wrong in the **span** as well as
the count; and the shipped binary lands on golden's span exactly, scalar and
array alike. **The law generalises past what the pass claimed for it.**

Five further cells (`w3i` element-select-first mixed, `w4i` member-access-first
mixed, `w5i` `#(1)`, `w8a` named-site-first, `z3`/`f`-style named controls) are
EQ on both binaries and confirm nothing regressed on the branches that already
agreed.

### 6.2 ONE COUNTEREXAMPLE TO THE LAW AS STATED — and why it is not a defect

See F1 below. It is real, it is pre-existing, and I prove it cannot be a
regression.

---

## 7. NUMBERED FINDINGS

### F1 — the stated MECHANISM is falsified on the `ConcatenationExpression` branch — **NOT A REGRESSION, RESIDUE**  *(severity: MEDIUM as a law, ZERO as a defect of this pass)*

The law says a udp-parsed instantiation mints **NONE** of its actuals' nets,
because "compileUdpInstantiation never reaches the parent implicit-net fallback".
A concatenation is a `net_lvalue` by the LRM and `isNetLvalueSyntax` accepts it,
so the law predicts NONE. Golden **MINTS**.

Reduced to 10 lines (`/tmp/r10svs11v_scratch/ast_probe/p.sv`):

```systemverilog
interface ifa(input bit clk); logic sig; modport MP(input clk, output sig); endinterface
module kim2(input logic [1:0] a, ifa.MP m);  logic q; endmodule
module top();
  bit Clock;  ifa w2i(Clock);
  kim2 v2 ({Clock, Clock}, w2i);
endmodule
```

The antecedent holds — Surelog's own parser says so, same instrument the
implementer used:

```
$ surelog -parse -nocache -d ast p.sv
n<> u<132> t<Net_lvalue>        p<137> c<126> s<136> l<9:10> el<9:24>
n<> u<138> t<Udp_instantiation> p<139> c<119>        l<9:1>  el<9:31>
```

And the consequent fails. Golden's `work@top` has **no `ref_module` for `v2`**
(1 ref_module total, the interface instance's, at 8:5) — consistent with the
udp parse — **yet it carries the connection-site net anyway**:

```
\_logic_net: (work@top.w2i), line:9:26, endln:9:29
  |vpiName:w2i   |vpiFullName:work@top.w2i   |vpiNetType:1
```

Span 9:26-9:29 is `w2i` **in the connection list**, and the object is
structurally identical to a known connection-site net (compare c2's `e1i`). So
on this one branch golden's `ref_module` rule and its connection-site-net rule
**decouple**: the parse is a `udp_instantiation` and the net is minted anyway.

**Why it is not a defect of this pass.** Both binaries answer NONE here — I
measured it isolated and in `v1_gaps.sv`, on ship and on pris. And it is not
luck: a concatenation terminal can only bind a **non-interface** port, so any
concat-first list necessarily has a non-interface connection, so `mixed9` is
necessarily TRUE and `hasOrderedConns` is TRUE, so **pristine skipped this
entire branch too**. Ship ≡ pris on the whole `ConcatenationExpression` branch,
by construction, not by sampling. Corpus reach is 0 (GATE 5: the only movers are
the two SVSwitch rows).

**Action:** none for this pass; rank it as a residue. The next pass working this
rule should narrow the predicate's net-side reading to a *simple* net_lvalue
(identifier / select / member-access) and leave the concat form minting —
note that would fork `udpShapedInstantiation` between its `ref_module` use and
its net use, which is exactly the consolidation tension the report's own R3
names.

*Command:* `svs11arm.sh v1_gaps.sv <dir>` then
`netread.py <dir>/g.dump <dir>/o.dump --obj 'module_inst: work@top ' --field vpiNet`;
`surelog -parse -nocache -d ast p.sv`.

### F2 — `census.sh` scans 9% of the surelog corpus and reports it as "the surelog corpus"  *(severity: LOW — instrument/documentation)*

`census.sh`'s default `ROOTS` is
`$HOME/git-repos/Surelog/third_party/tests $HOME/git-repos/uhdm2rtlil/test`.
The surelog corpus is **both** `tests/` and `third_party/tests/`
(GOLDEN_EQUIVALENCE.md §1; 794 rows per mode). The omitted root holds **695**
test dirs against `third_party/tests`'s 70.

```
$ census.sh "$HOME/git-repos/Surelog/tests"
---- /home/heyfey/git-repos/Surelog/tests: 18 of 695 test dirs pass BOTH necessary conditions
     (SimpleInterface, SplitFile, OneNetModPortGeneric, OneNetRange, UnitTest, …)
```

So "surelog corpus : 29 of 70 test dirs" is an upper bound over **70 of 765**
dirs, and **18 further upper-bound carriers were never named**. The report's
§6.6 self-criticism ("over-counted by a factor of 41") is the right lesson
pointed the wrong way — the census also **under-scanned by 10×**, and the header
of the script itself says a filter that misses a carrier is worse than one that
over-reports.

**No verdict impact:** the census is explicitly non-authoritative, and GATE 5
covered all **953** surelog databases including every one of those 18, finding
exactly 2 movers. Fix the `ROOTS` default before the next pass cites it.

*Command:* `census.sh` (default) and `census.sh "$HOME/git-repos/Surelog/tests"`;
`ls -d ~/git-repos/Surelog/tests/*/ | wc -l`.

### F3 — a pre-existing `ref_module` gap on the named-`#()` branch, newly visible  *(severity: LOW — PRE-EXISTING, not this pass)*

While censusing `vpiRefModule` for §6, golden and ours disagree by one on both
binaries:

```
kp #(.P1(1)) v1 (w1i, Clock);      golden: ref_module at 46:14-46:16
                                   ours  : ABSENT   (ship AND pris)
```

`udpShapedInstantiation` correctly answers *false* for a NAMED override (it
exceeds `delay2`), and this pass uses that answer correctly for the **net** —
cell `w1i` is one of the nine it fixes (§6.1). But the **`ref_module`** call site
(`ModuleEmit.cpp:2478`) still drops the object. So the pre-existing call site is
wrong on a branch the new call sites get right. Untouched by this patch and
byte-invisible in the corpus (0 movers), but it is a concrete, minimal,
already-reduced next target and it belongs on the ladder.

*Command:* `netread.py <v1_gaps>/g.dump <v1_gaps>/o.dump --obj 'module_inst: work@top ' --field vpiRefModule`.

### F4 — `c3_ifacearray.sv` cells f3 and f6 are the same cell  *(severity: COSMETIC)*

```
// f3 array actual, NAMED connection  -> NOT udp-shaped
a1m v3 (.m(g3i));
// f6 array actual, 1 ordered terminal, NAMED-list control
a1m v6 (.m(g6i));
```
The comment on f6 says "1 ordered terminal" but the code is a **named** list,
identical in shape to f3 — same child, same formal, same connection style. The
arm therefore has 7 signal cells of which one is a duplicate. It does not change
`EQ 5 → 8 / DIFF 3 → 0` (both cells read MINT/MINT/MINT), but the arm claims
more axis coverage than it has, and a genuine "1 ordered terminal with an array
actual" control already exists as f1.

### F5 — `gridread.sh` silently ignores its workdir argument  *(severity: COSMETIC, but it is a live measurement trap)*

```sh
SRC=${1:?arm source}
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/r10svs11_arm_$B          # hard-coded; $2 is never read
```
`svs11arm.sh` *does* honour a second argument; its wrapper does not. Running
`gridread.sh <arm>` for the shipped binary and then for the pristine one
**overwrites the same directory**, so anyone who later reads
`/tmp/r10svs11_arm_<arm>/{g,o}.dump` gets whichever binary ran last. I hit this
during §6 and re-ran everything through `svs11arm.sh` with explicit distinct
directories. The implementer's own cell numbers are unaffected (they are printed
inline by each run, and I reproduced all 36 independently), but the artefacts
left on disk are not what a reader would assume. One-line fix:
`D=${2:-/tmp/r10svs11_arm_$B}`.

---

## 8. WHAT I COULD NOT BREAK

Stated plainly, because a verifier that only lists findings overstates them:

* The **law's predicate is right on every one of the 51 cells now measured**
  (36 from the implementer + 15 from me) **except the concat branch of F1**, and
  that branch is provably unreachable as a regression.
* The **two-directional** claim about `mixed9` is real and I reproduced both
  directions by name (5 over-mints, 5 under-mints).
* The **anchor** interaction the grid excluded turns out to be a place the pass
  is *more* right than it claimed (§6.1).
* The **census** was run before the verifier, the **canaries** baseline-first and
  mode-matched, `results/*.csv` untouched, `GOLDEN_DEFER` unset, sweeps at
  `--jobs 2` with my own `--out`/`--workdir`, and **no `git stash` anywhere**.
* The report's **six refutations all hold**, including the awkward one against
  its own first law (interface-port count), and including the observation that
  the deleted clause's cited golden survives its deletion — I checked
  `iface_method_call` and `load_and_derive` **by name and byte**, both
  BYTE-IDENTICAL between the two binaries, not merely absent from a mover list.

---

## 9. RANKED RESIDUES (mine, merged with the report's)

1. **R1 — the successor head, 54 cmp lines, both modes: the `port` of
   `module_array (work@output_interface)`.** Confirmed verbatim from my own
   `cmp.txt`. Golden `port: , id:1164, 38:33-38:38` with an **empty `vpiName`**
   and highconn `work@top.output_intf.Clock`; ours `port: (clock), id:2636` with
   **no span at all** and highconn `work@top.output_intf.clock.Clock`
   (the formal interposed). Three compared differences on one object. Highest
   value by a distance: one object, 54 lines, and it is the shape every
   interface-array design has.
2. **F1 — the concat-first counterexample.** Small, reduced to 10 lines, and it
   is the one place the decoded law is known to be wrong. Fixing it forks
   `udpShapedInstantiation`'s two readings, which is worth knowing before R3's
   consolidation is attempted.
3. **F3 — the `ref_module` named-`#()` gap.** Already minimal, already reduced,
   pre-existing.
4. **R2 (report's) — SVSwitch's remaining 1333** (golden-only 476 / ours-only
   857). Reproduced. Nothing in any grid here accounts for it.
5. **F2 / F4 / F5 — instrument hygiene**: census `ROOTS`, the duplicate c3 cell,
   the `gridread.sh` workdir argument. Cheap, and each one is the kind of
   "cited guard that does not cover what the citation claims" this campaign has
   paid for twice.
6. **R3 (report's) — `udpShapedInstantiation` now has FOUR call sites from ONE
   law stated only in comments.** F1 and F3 together are evidence the four sites
   are *already* drifting apart in what they should mean. Still correctly
   deferred under no-premature-extraction, but the deferral now has a measured
   cost attached to it.

---

## 10. HOUSEKEEPING

* Sweep workdirs `/tmp/r10svs11v_wd_{u2r,sl}_{ship,pris}` **DELETED**, as are
  the transient arm dirs and the throwaway collision worktree.
* Retained: `/tmp/wt_r10svs11v` (patched) and `/tmp/wt_r10svs11vpris` (pristine),
  the two independently built binaries whose md5s match the implementer's, plus
  `/tmp/r10svs11v_scratch` (15 MB) holding the SVSwitch pairs, the gap-arm dumps
  and the AST probe.
* New arms written into this directory by the verifier: `v1_gaps.sv`,
  `v2_gaps2.sv`, `v3_arr.sv`. They are not in `/tmp/r10svs11.patch`; the master
  should fold them plus this file into the landing commit if it wants the
  empty-cell evidence carried forward.
* Deliverable unchanged and re-verified: `/tmp/r10svs11.patch`, md5
  `2cd50b3391783802fc225d6d89f39bfb`, `git apply --check` clean on a fresh
  957974d.

**VERDICT: PASS.** No defect. Land it.
