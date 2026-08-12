# r10uvm59 — INDEPENDENT VERIFIER REPORT (the missing verify pass)

**VERDICT: PARTIAL.** Every number in the implementer's `README.md` reproduced on
binaries I built myself — both md5s **bit-for-bit**, all five gates, the 7-mover
set with `REMOVED=0`, the head advance `15 -> 58` on both BuildUVMPkg rows, the
three byte-identical uvm-1.2 `.cmp` files, the msdist distances to the line, the
whole-database census, every arm cell count and every canary. Patch hygiene is
clean and the disclosed OPS SLIP left **no** residue: the patch applied to a
*fresh* `81b8e0c` in `/tmp` produced the shipped binary `167d5696…`
**bit-for-bit**, which is only possible if the shipped binary came from an
uncontaminated tree.

**PARTIAL, not PASS, for three reasons:**

* **F1 — the gate is TOO WIDE on the LVALUE axis.** An unbound `::`-scoped
  **assignment target** mints the READ form (`T::sprop`) where golden writes
  § staticScopedLvalueBad48's `FIRST::@@BAD_SYMBOL@@` over the whole lvalue: a
  **new wrong object**, in a cell the implementer's negative control structurally
  could not see (every `::` lvalue in `v3_negctl` is BOUND), reproduced in **two
  independent** silent populations, and it makes those arms **worse** by
  uhdm-cmp's own measure (15 -> 28 cmp lines). Zero corpus reach today — which is
  why all five gates remain valid — and I **built and gated the fix** (§6): it
  clears both arms to cmp 0 with golden's exact spans, leaves `v3_negctl`, three
  more arms and all 7 movers' databases byte-identical, and keeps goldens 23/23.
* **F2 — the stated population is wrong.** "The DEFAULT specialization and
  nothing else" is false: any **uninstantiated scope** silences the same lookup,
  so an `if (0)` generate block is a second, un-modelled population — where the
  law is *correct*, and where F1's over-fire also lives with no type parameter in
  the file.
* **F2b — `ADDED=109` is not the measured number; it is 102.** `mv58.sh` sums its
  own injected SELFCHECK shape into ADDED (7 movers x 1). Proven from the source
  and from the dump-line growth.

The record also needs an undocumented `cells59.py` filter to reproduce its grid
(F2c), and the escaped-qualifier span is wrong in a way no gate can see (F3).

LHS is **ALWAYS** golden (Surelog); RHS is **ALWAYS** ours. `uhdm-cmp` is
`~/.local/bin/uhdm-cmp` taking `(golden, ours)`.

---

## 0. WHAT I BUILT, AND THE md5 ASSERTION AS A SEPARATE COMMAND

Two worktrees of my own at `81b8e0c` (`git worktree add … 81b8e0c --detach`),
each configured and built with an **absolute** build path; the build log carries
`Linking CXX executable slang-uhdm` **once** and ` error:` **zero** times for
both.

```
$ grep -c 'Linking CXX executable slang-uhdm' /tmp/v59/ctrl_build.log /tmp/v59/pat_build.log
/tmp/v59/ctrl_build.log:1
/tmp/v59/pat_build.log:1
$ grep -c ' error:' /tmp/v59/ctrl_build.log /tmp/v59/pat_build.log
/tmp/v59/ctrl_build.log:0
/tmp/v59/pat_build.log:0
```

md5 asserted in a **separate** command, baseline validated as 32 hex first
(malformed = exit 9):

```
BASELINE md5s are 32 hex: OK
BUILD DIRS (absolute): /tmp/v59/ctrl/build /tmp/v59/pat/build
7922a457a58565ff014f9c440b585eb6  /tmp/v59/ctrl/build/slang-uhdm
167d5696053b4b58b4e85c9cf168fcd5  /tmp/v59/pat/build/slang-uhdm
CONTROL mine=7922a457a58565ff014f9c440b585eb6  claimed=7922a457a58565ff014f9c440b585eb6  MATCH
FINAL   mine=167d5696053b4b58b4e85c9cf168fcd5  claimed=167d5696053b4b58b4e85c9cf168fcd5   MATCH
MD5 CHANGED ctrl->pat: PASS
81b8e0c0f3dc63a2aa935fbda8f3196c1d6292f4   (both worktrees)
```

**This is also the OPS-SLIP verdict.** A build in `/tmp/v59/pat` — a path the
implementer never used — reproduces `167d5696…` byte-for-byte, so the shipped
binary is a pure function of `81b8e0c + /tmp/r10uvm59.patch`. The main tree is
additionally clean *now*: `git status --short` prints only `?? locbug/`,
`md5sum src/ExprEmit.cpp` equals `git show HEAD:src/ExprEmit.cpp | md5sum`
(`c11ffefc40e9b2898f1f2463f2452325`), and
`grep -rn 'invalidScopedCallRef59\|typeParamScopedCallRef59' src/ include/`
returns **0** — no pass-59 code leaked into any committed commit.

---

## 1. PATCH HYGIENE

`git apply --stat` (FULL output, nothing truncated):

```
 include/UhdmExporter.h                   |   10
 src/ExprEmit.cpp                         |  106 +++++
 src/UhdmExporter.cpp                     |   16 +
 tools/probe/r10uvm59repro/README.md      |  620 ++++++++++++++++++++++++++++++
 tools/probe/r10uvm59repro/a1_witness.sv  |   69 +++
 tools/probe/r10uvm59repro/a2_position.sv |  116 ++++++
 tools/probe/r10uvm59repro/a3_scope.sv    |   92 ++++
 tools/probe/r10uvm59repro/a4_bind.sv     |  115 ++++++
 tools/probe/r10uvm59repro/arm59.sh       |   54 +++
 tools/probe/r10uvm59repro/cells59.py     |   75 ++++
 tools/probe/r10uvm59repro/rhsown59.py    |   69 +++
 tools/probe/r10uvm59repro/v1_elab.sv     |   49 ++
 tools/probe/r10uvm59repro/v2_lonedecl.sv |   56 +++
 tools/probe/r10uvm59repro/v3_negctl.sv   |  100 +++++
 14 files changed, 1547 insertions(+)
```

* `git status --short results/ scripts/ tests/` — **empty before AND after**
  every sweep I ran. `results/*.csv` read-only, `verify_golden.py` /
  `check_goldens.sh` untouched, `GOLDEN_DEFER` unset (**5 DEFERRED** in both
  surelog modes, as in the baseline).
* **No slang header, no third-party file**: every `diff --git` path is
  `include/UhdmExporter.h`, `src/{ExprEmit,UhdmExporter}.cpp`, or
  `tools/probe/r10uvm59repro/*`.
* `git apply -v` applied all 14 files **cleanly** at `81b8e0c`.
* Also applies to current `HEAD` (`63ff1fb`) with offsets only
  (`UhdmExporter.h` +9, `ExprEmit.cpp` +240) and the Invalid arm's ordering is
  preserved there: at HEAD the arm's `noteUnsupportedAt("expression kind:
  Invalid")` is line 15793 and the § 55 arm still returns immediately above it.
  `r10svs4`'s § copyClassIsNewCall4 is at 15193, a *different* arm — no
  collision. Gate numbers were nonetheless measured at `81b8e0c`, so a rebase
  onto HEAD deserves a re-gate.
* `grep -rn 'typeParamScopedCallRef59\|invalidScopedNameSyntax59\|invalidScopedCallRef59' include/ src/`
  → **11 hits across 3 files** — the claim, reproduced.

### THE STATED GATE IS THE GATE IN THE CODE

Read off `src/ExprEmit.cpp` (not the comment): `invalidScopedNameSyntax59` is
`kind == Invalid` ∧ `!InvalidExpression::child` ∧ `scopedChainRootName48(e.syntax)
!= null`, and `invalidScopedCallRef59` adds `splitScopedName12` succeeding.
Four conjuncts, nothing else. Both call sites verified **EXECUTED**:

* site 1 (`emitExpr`'s Invalid arm) — the six corpus objects (§2, mover table);
* site 2 (`emitClassPropInit29`) — arm `a2` cell P12:
  `\_ref_obj: (p59a2::w59::m_prop::Tregistry::get), line:108:24, endln:108:35`
  present in the patched dump at the same dump line as golden, **absent** in the
  control dump (`grep -n m_prop <a2 out>/{pat,ctrl}/o.dump`).

`splitScopedName12`'s fifth (implicit) conjunct is worth naming because it is
what makes the § 55 interaction safe: `scopedSegId12` accepts only
`IdentifierName` / `ClassName` / `IdentifierSelectName`, so a `ConstructorName`
right-hand segment (`T::new()`) **cannot** pass. Measured, not assumed (F4b).

---

## 2. THE FIVE GATES — every number re-measured on my own `167d5696…`

| gate | claimed | **measured** | verdict |
|---|---|---|---|
| 1 BUILD | link 1 / errors 0 / md5 `7922a457…` -> `167d5696…` | identical | PASS |
| 2 GOLDENS | rc=0 23/0 ; `SLANG_UHDM=/bin/false` rc=1 0/23 | `rc=0 PASS=23 FAIL=0` ; `rc=1 PASS=0 FAIL=23` | PASS |
| 3 u2r testflags | 679 / 50 / 2 ; dump 496 match 183 differ 52 blank ; 0 rows | identical, `0 differing ROWS (0 diff row-sides)`, 731 ROWS both | PASS |
| 4 surelog both | default 467/13/5DEF/284/25 ; testflags 463/10/5DEF/286/23 (+3 NO_DATABASE, 2 UNTRANSL, 1 TIMEOUT, 1 NO_UHDM) ; dump 225/242/327 and 165/298/331 ; 0 rows | identical, `0 differing ROWS`, 1588 ROWS both | PASS |
| 5 BYTE VERIFIER | u2r `PATH_SETS_IDENTICAL (679)` 0 movers, SELFCHECK1=1 ; surelog `(953)` **7** movers, SELFCHECK1=**8** | identical, and the 7 mover PATHS are exactly `{SimpleUVM,BuildUVMPkg,SeqDriver}×{default,testflags}` + `Scoreboard,default` | PASS |

Commands: `SLANG_UHDM=/tmp/v59/pat/build/slang-uhdm python3 scripts/verify_golden.py
--corpus {surelog --mode both, uhdm2rtlil --mode testflags} --jobs 2 --out … --workdir …`;
`tools/probe/r10oth8repro/ct8rows.sh results/{golden_surelog,gate_uhdm2rtlil}.csv …`;
`SELFCHECK=1 SELFCHECK1=1 tools/probe/r10oth6repro/byteverify.sh <pat wd> <ctrl wd>`.
The **pristine** sweeps I ran with `7922a457…` also reproduce both committed
baselines with `0 differing ROWS`, which is what makes gate 5 meaningful.

`BuildUVMPkg` did **NOT** convert: both rows are byte-identical to
`results/golden_surelog.csv` lines 170-171
(`BuildUVMPkg,{default,testflags},CMP_NOTEQUAL,decompile:,,`).

### CANARIES (all reproduced)

```
ctcan2.sh  u2r     EXPECT_UNKNOWN=6 -> ok=1  changed=0 absent=0 unknown-patterns=6  PASS
ctcan2.sh  surelog EXPECT_UNKNOWN=1 -> ok=58 changed=0 absent=0 unknown-patterns=1  PASS
r10uvm52repro/canaries.sh u2r     -> ok=8  changed=0 absent=0 unknown-names=25
r10uvm52repro/canaries.sh surelog -> ok=52 changed=0 absent=0 unknown-names=7
r10uvm55repro/canaudit.sh -> audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
```

(`canaries.sh` / `canaudit.sh` are not executable in the tree; run them with
`bash`. `./…` gives *Permission denied*, which must not be mistaken for a pass.)

### HEADS, and the byte-identity claims

`tools/probe/r10uvm55repro/rowheads.sh <wd> <out> SimpleUVM BuildUVMPkg SeqDriver Scoreboard`:

| test | mode | control | patched |
|---|---|---|---|
| **BuildUVMPkg** | default / testflags | 15 cmp lines, 1 head | **58**, 1 head |
| SimpleUVM | default / testflags | 50, 1 | 50, 1 |
| SeqDriver | default / testflags | 85, 1 | 85, 1 |
| Scoreboard | default | 50, 1 | 50, 1 |
| Scoreboard | testflags | SKIP-NOFILE (SLANG_REJECT) | same |

`cmp -s` on the `.cmp` files: **SimpleUVM ×2, SeqDriver ×2, Scoreboard,default
are BYTE-IDENTICAL** (bytes moved, heads did not); only the two BuildUVMPkg
`.cmp` files differ. The old head (`ref_obj …Tregistry::get`@14104:24-35,
`RHS: <null>`) is **GONE**; the new head is R1
(`ref_obj …uvm_pkg::uvm_deferred_init`@14107:7-16 vs our
`hier_path (uvm_pkg::uvm_deferred_init.push_back)`@14107:7-50) — exactly as
reported.

### MOVER ATTRIBUTION, PER SHAPE (`SELFCHECK=1 mv58.sh`)

```
movers=7   ADDED instances=109   REMOVED instances=0
OVER-FIRE shapes=9  UNDER-FIRE shapes=0
SELFCHECK PASS: the injected shape was reported OVER-FIRE on every mover
```

9 = 7 fabricated (one per mover) + **2 real, both the bare field line
`|vpiRhs:`** (golden 7491 / ours 7557 after, i.e. the pre-existing surplus of
7553 plus the 4 correct additions) — the bare-field-line absorber, never
attributable. Its honest per-owner replacement, `rhsown59.py vpiRhs <span>
g.dump o.dump n.dump`, on the real BuildUVMPkg dumps:

| owner | golden | pristine | FINAL |
|---|---|---|---|
| `14058:5` / `14104:16` / `14120:16` / `61837:7` | vpiRhs YES | vpiRhs **NO** | vpiRhs **YES** |

`NO-MATCH dumps: 0` on all four. Every one of the six added object shapes reads
`golden=1 ours=1 covered`; every `|vpiName:` / `|vpiFullName:` / `\_assignment:` /
`\_method_func_call:` shape reads `covered`; **0 REMOVED**.

### CENSUS AND DISTANCE (BuildUVMPkg, both sides, indentation preserved)

```
lines containing 'Tregistry::get':   golden 15   pristine 0   FINAL 12
'line:14096' ref_obj Tregistry::get: golden 1    FINAL 0        (their R2, unfixed — confirmed)
msdist.sh (md5 7c0d46b5da124cfe37d27eddc95eb7e7 == git show 7c7eaa6: == git show 81b8e0c:)
  pristine  golden-only 53726  ours-only 28649  DISTANCE 82375  (g 1101386 / o 1076309)
  FINAL     golden-only 53703  ours-only 28662  DISTANCE 82365  (g 1101386 / o 1076345)
```

All six numbers match the report to the digit.

### ARM CELL TABLES (`cells59.py`, control vs patched, my runs)

| arm | control | patched | their claim |
|---|---|---|---|
| a1_witness | 5 diff | 2 diff | (R8 unmasked) ✓ |
| a2_position | **13** | **0** | 13 -> 0 ✓ |
| a3_scope | 3 | 2 | CMP EQUAL, 2 pre-existing rows ✓ (cmp 15 -> **0**) |
| a4_bind | 7 | 1 | 7 -> 1 ✓ |
| v1_elab | 1 | 0 | 1 -> 0 ✓ |
| v2_lonedecl | 3 | 2 | 3 -> 2 ✓ |
| v3_negctl | — | — | `ours.uhdm` **BYTE-IDENTICAL** across binaries ✓ |

(The report's `v3_negctl` md5 `9c351433…` is path-dependent and cannot be
reproduced outside their worktree; mine is `840f0d8e8761…` on **both** binaries,
which is the substantive claim.)

---

## 3. FINDINGS, most severe first

### F1 — **OVER-FIRE: the gate is too wide on the LVALUE axis** (fix before landing)

An unbound `::`-scoped **assignment target** now gets the READ form. Golden
writes § staticScopedLvalueBad48's placeholder over the **whole** lvalue.

```sh
# cell: vcells/c01_lvalue.sv  (generic class, T defaults to int)
#   x1:  T::sprop = 3;            <- unbound  (the cell nobody measured)
#   x2:  conc59::sint = 3;        <- bound    (in-cell control)
vcells/vrun.sh <abs>/vcells/c01_lvalue.sv <outdir> <slang binary>
```

```
GOLDEN  \_ref_obj: (p59c01::gen59::x1::T::@@BAD_SYMBOL@@), line:12:7, endln:12:15
CONTROL (nothing — the assignment had no vpiLhs at all)
PATCHED \_ref_obj: (p59c01::gen59::x1::T::sprop),          line:12:7, endln:12:10
cmp lines 15 -> 28   (heads 1 -> 1)
golden's own count of the patched shape, grep -Fxc, indent stripped: 0   => OVER-FIRE
the BOUND control x2 is untouched: golden and ours both `conc59::@@BAD_SYMBOL@@`@16:7-19
```

Independently reproduced **outside** any generic class, in the second silent
population (F2), with an unknown *package* qualifier:

```sh
# cell: vcells/f01_lvuninst.sv   `if (0) begin : gblk … nosuchpkg59::sig = 1; end`
GOLDEN  \_ref_obj: (work@top59f01.gblk.nosuchpkg59::@@BAD_SYMBOL@@), line:6:7, endln:6:23
PATCHED \_ref_obj: (work@top59f01.gblk.nosuchpkg59::sig),            line:6:7, endln:6:20
cmp lines 15 -> 28
```

Why the campaign's own instruments missed it: `v3_negctl`'s two `::` lvalues
(`c8`, `c9`) are **bound**, so slang never yields `Invalid` there and the arm is
structurally blind to the cell; and the corpus has no such site, so gates 3-5
are silent. **The over-fire is real but has zero corpus reach today** — this is
why I still call all five gates valid.

**Fix (built and gated in §6): one guard inside `invalidScopedCallRef59`, the
same gate already used at `ExprEmit.cpp:3422` — plus a span, which §6 explains:**

```c++
if (inLhs && assignTargetParent48(parent))
    return scopedLvalueBadRef48(e, parent, prefix);   // + setLoc, see §6
```

#### F1's THIRD golden sub-shape, measured here (`vcells/k01_lvflavour.sv`)

The lvalue law is not one shape. On the **shipped** binary (`167d5696…`), five
flavours of the same spelling:

| cell | source | golden | shipped |
|---|---|---|---|
| y1 | `T::sprop = 3;` | `ref_obj T::@@BAD_SYMBOL@@`@10:7-15 | `T::sprop`@10:7-10 **over-fire** |
| y2 | `T::sprop += 1;` | `ref_obj T::@@BAD_SYMBOL@@`@14:7-15 | `T::sprop`@14:7-10 **over-fire** |
| **y3** | `T::sprop++;` | **`ref_obj T`**@18:7-15 — the **FIRST SEGMENT ALONE** | `T::sprop`@18:7-10 **over-fire, THIRD shape** |
| y4 | `sink(T::sprop)` output arg | `ref_obj T::sprop`@22:12-15 | **= golden** |
| y5 | `int y = T::sprop;` read | `ref_obj T::sprop`@26:15-18 | **= golden** |

y4 is the load-bearing negative: an output argument is an lvalue that is **not**
an assignment's `Lhs`, and golden takes the READ form there — so the missing
conjunct is exactly `assignTargetParent48` (whose UHDM-type switch admits
`assignment` / `assign_stmt` / `cont_assign` and nothing else), not
"lvalue-ness". y3 is outside that switch too, so the fix in §6 closes y1/y2 and
leaves y3 alone.

**And y3 is NOT this pass's debt — it is § staticScopedLvalueBad48's own,
identical in the BOUND half.** `vcells/k02_incbound.sv`, every cell bound
(`conc59::sint`, a concrete class, no `Invalid` anywhere):

```
z1  conc59::sint++;    golden ref_obj conc59@10:7-19        ours conc59::sint@10:7-15   <- SAME gap
z2  conc59::sint += 1; golden conc59::@@BAD_SYMBOL@@@14:7-19 ours = golden
z3  conc59::sint = 3;  golden conc59::@@BAD_SYMBOL@@@18:7-19 ours = golden
```

So after the F1 fix the unbound half behaves **exactly** like the already-landed
bound half — same two shapes right, same one shape (increment -> bare first
segment) left over for the lvalue law. `k02`'s database is byte-identical on the
shipped and fixed binaries, confirming the fix does not touch the bound path.

### F2 — **THE STATED POPULATION IS WRONG**: there is a SECOND silent species, and it is where F1 lives

`README.md` §2.4 states the corpus population is the generic class's DEFAULT
specialization "and nothing else". That is false. slang suppresses the
`UnknownClassOrPackage` diagnostic in **any** uninstantiated scope
(`~/git-repos/slang/source/ast/Lookup.cpp:766`,
`if (!context.scope->isUninstantiated())`), so an **uninstantiated generate
block** produces `kind==Invalid` + a `::`-rooted syntax with **no** type
parameter and **no** generic class anywhere:

```sh
# vcells/e01_uninstgen.sv:  module top; if (0) begin : gblk … j = nosuchpkg59::nosuchfn(1); end
control  cmp lines 15   patched cmp lines 0        <- the arm became CMP EQUAL
added:   \_ref_obj: (work@top59e01.gblk.nosuchpkg59::nosuchfn), line:11:11, endln:11:24
golden:  the SAME object, same span
```

The **behaviour is correct** — this is the law generalising properly, and it is
evidence *for* keying on the syntax rather than the qualifier. The defect is in
the **model**: the gate's blast radius is larger than documented, and every
axis measured only inside a generic class (position, lvalue-ness, `$unit`,
statement-vs-expression) has an unmeasured twin in this population. F1 is the
first thing that fell out of looking there.

### F2b — **`ADDED=109` IS THE INSTRUMENT PLUS ITS OWN NEGATIVE CONTROL: the real number is 102**

`tools/probe/r10uvm58repro/mv58.sh` appends the fabricated SELFCHECK shape to
`$key.added` **before** summing it:

```sh
[ "${SELFCHECK:-0}" = 1 ] && printf '1\t\\_FABRICATED_SHAPE_THAT_GOLDEN_CANNOT_HAVE: , line:1:1\n' >> "$OUT/$key.added"
na=$(awk -F'\t' '{s+=$1}END{print s+0}' "$OUT/$key.added")
tot_add=$((tot_add+na))
```

So with `SELFCHECK=1` every mover's ADDED is inflated by exactly 1. My own run,
summed per mover with the fabricated line separated out:

```
BuildUVMPkg.default  real ADDED=36  fabricated=1     (README says 37)
SeqDriver.default    real ADDED=6   fabricated=1     (README says 7)
=> real total = 36x2 + 6x5 = 102, not 109;  REMOVED = 0 (unaffected)
```

Independent cross-check that needs no instrument at all: with REMOVED=0 the ADDED
total must equal the dump-line growth, and `msdist.sh` prints
`1076345 - 1076309 = 36` for BuildUVMPkg. The implementer subtracted the
injection from the OVER-FIRE count ("9 = 7 fabricated + 2 real") but not from
ADDED. The substantive claims are unaffected. Future passes: run `mv58.sh`
**twice** and quote the un-instrumented total.

### F2c — the grid tables need an UNDOCUMENTED filter to reproduce

`cells59.py`'s **default** pattern (`::.*::`) on the shipped binary gives
a2 **4** differing cells, a4 **9**, v1 **1**, v2 **5** — not the 0 / 1 / 0 / 2 the
README tabulates. Those numbers require the subject-name filter
`'::(get|getn|sprop|create_by_type|eget|pf59)\b'`, which the README states for
`v3_negctl` only. With that filter every claimed count reproduces exactly (§2).
A reproducibility gap in the record, not a defect in the law.

### F3 — **ESCAPED QUALIFIER: the span is wrong, and uhdm-cmp cannot see it**

The builder reads name text (`valueText()`) and derives the span from token
locations. The name half is right (golden also strips the backslash); the
**span** half is not, and it is invisible to every gate because uhdm-cmp
blacklists `vpiLineNo`/`vpiColumnNo` — `c10`'s cmp reads **0 lines** while the
dump disagrees:

```sh
# vcells/c10_esc.sv, vcells/h03_escspan.sv
\Tesc ::get()          golden endln 10:27   ours 10:23     (new object, this law)
\Tesc ::g()            golden endln  7:27   ours  7:23
\Tesc ::getlongername()golden endln 11:27   ours 11:23     (end is NOT id-length-dependent)
\esc59 ::get()  BOUND  golden endln 18:28   ours 18:24     (§ staticScopedCall12, PRE-EXISTING:
                                                            the CONTROL binary prints 18:24 too)
T::\getesc ()   escaped FINAL id: golden 14:15-18 == ours 14:15-18   (only the QUALIFIER shifts)
```

So: golden's end = **our end + 4** whenever the *qualifier* is escaped, whatever
the final identifier's length. **Pre-existing** in `splitScopedName12`'s
consumer, **propagated** to a new object population by this pass. Corpus reach
today: **zero** (the only corpus file with an escaped-identifier `::` match is
`Surelog/tests/SplitFile/svaunit_pkg.sv:4006`, and it is a `"…\t%s::%s\n"`
format string in a row that is `SLANG_REJECT` in both modes).

### F4 — INVALID-SPECIES SWEEP: the four-conjunct gate excludes every other species I could reach

The dangerous axis the brief named. Result: **no spurious ref_obj from any
non-scoped or non-silent species**, because slang *rejects the design* for the
concrete-qualifier failures — they never reach the emitter at all. Each cell run
on both binaries with `vcells/vrun.sh`:

| species | cell | slang | our side |
|---|---|---|---|
| unresolved **package** member | `c02` `p59c02::nosuchfn(1)` | **hard error**, no database | unreachable |
| unresolved **class** member (concrete) | `c03` `conc59::nosuch()` | **hard error** | unreachable |
| bad member on a `::`-rooted **chain** | `c04` `conc59::get().nosuchmethod()` | **hard error** | unreachable |
| unresolved **dotted / undeclared** ref | `c08` `c.nosuchfield`, `nosuchthing` | **hard error** | unreachable |
| `::` **root unknown** at module level | `c13` uninstantiated-*looking* module | **hard error** (`unknown class or package`) | unreachable |
| **DOT** rooted at a type parameter | `d07` `T.nosuch` | silent Invalid | **no fire** (no `::`), cmp 35 -> 35 ✓ |
| **`$unit::`** scope | `h01` `$unit::nosuchfn(1)` | silent Invalid | **no fire** (`scopedSegId12` rejects `UnitScope`); golden HAS `ref_obj $unit::nosuchfn`@9:11-18 -> residue |
| **CAST** over an unbound scoped call | `c05` `int'(T::get())`, `$bits(T::get())` | silent | fires, **cmp 39 -> 0** ✓ |
| **SELECT** on an unbound scoped ref | `d02` `T::sarr[1]` | silent | fires, object == golden `@7:15-18` ✓ |
| **CHAIN** off an unbound scoped call | `d03` `T::get().inst(2)`, `T::stat.inst(2)` | silent | fires, **cmp 15 -> 0** ✓ (golden collapses; R3's concrete twin still open) |
| **STATEMENT** position ×4 (bare, with args, in a `begin`, in `if`/`else`) | `c12` | silent | fires, **cmp 15 -> 0**, all seven spans == golden ✓ |
| **MACRO-written** spelling (arg-macro and whole-statement macro) | `c11` | silent | fires, spans == golden `10:15-18`, `14:15-18` ✓ |
| **CONSTANT** expression | `d06` `localparam int L = T::WIDTH;` | silent | **no fire**, cmp 17 -> 17 (residue, pre-existing) |
| **cont_assign** position | `g02` `assign w = nosuchpkg59::wfn(1);` in `if (0)` | not Invalid at all | unchanged (we emit an unnamed `func_call`; golden `ref_obj`) -> residue |
| **CONSTRAINT** / **EXTENDS** / **type** position | `d09`, `d05`, `d04` | — | byte-identical across binaries ✓ |
| **CONCATENATION** with an unbindable operand (their R5) | `c09` | silent | **byte-identical** across binaries ✓ |

### F4b — § invalidNewCallFromSyntax55 interaction: no double-fire, at EITHER call site

```sh
# vcells/c07_new.sv  and  vcells/h02_propnew.sv
o = conc59::new(3);   golden method_func_call(new)+ref_obj conc59 ; ours unchanged, cmp text
                      byte-identical control vs patched
v = new();  (T v)     golden method_func_call(new)              ; ours unchanged
T v = T::new();       golden emits NOTHING at that line         ; ours emits NOTHING
                      -> the ConstructorName segment is refused by scopedSegId12: NO over-fire
T v = Tregistry::type_id::create("n")   golden ref_obj Tregistry::create@25:13-33
                                        ours  ref_obj Tregistry::create@25:13-33  (middle segment
                                        dropped, three segments, EXACT match)
h02 (class PROPERTY inits, call site 2): p1 `conc59::new(3)`, p2 `T::new()`, p3 `new()` all
      unchanged; only p4 `T::get()` gains the object, == golden @12:12-15
```

### F5 — THE DROP HALF is right, including the case that could have leaked a child

Golden's unbound `ref_obj` has **no children** in every cell I measured, and our
builder emits none. The sharpest test is an **already-emittable** inner object
inside the dropped argument list:

```sh
# vcells/g01_innerbound.sv:  T v = T::getn(conc59::get(), 7);
golden : ONE \_ref_obj: (…x1::T::getn), line:11:13, endln:11:16   (conc59::get GONE)
ours   : the same ONE object, and NO conc59::get anywhere        cmp 15 -> 0
```

I found **no** cell where golden keeps a child we drop, nor the reverse.

---

## 4. WHAT I COULD NOT MEASURE

* `Scoreboard,testflags` produces no database (`SLANG_REJECT`) — reported, not
  hidden, in both my sweeps and theirs.
* `a3` cell S6 (`pkg::Tparam::get()`) and a non-class explicit specialization are
  slang **hard errors**, as the report states; I re-confirmed the second
  (`c13`-style module-level `::` with an unknown root is also a hard error, so it
  is not a third population).
* HEAD (`63ff1fb`) + patch was **not** gated — only `git apply --check`ed and
  read for arm ordering.

---

## 5. RANKED RESIDUES (theirs re-confirmed, mine added)

| # | residue | reach | evidence |
|---|---|---|---|
| **V1** | **F1**, the lvalue over-fire | 2 arm cells, 0 corpus rows | `c01` x1, `f01`; fix measured in §6 |
| **V2** | **F3**, escaped-qualifier span (+4), uhdm-cmp-blind | 3 arm cells, 0 corpus rows; pre-existing in § staticScopedCall12 | `c10`, `h03` |
| **V2b** | golden's **THIRD** lvalue sub-shape: `X::y++` -> bare `ref_obj X` over the whole lvalue. **PRE-EXISTING**, identical in the bound half (`k02` z1), so it is § staticScopedLvalueBad48's residue, not pass 59's | `k01` y3, `k02` z1 | survives the F1 fix by design |
| **V3** | `$unit::x` gets no object (golden does) | `h01`; `scopedSegId12` has no `UnitScope` case | cmp 15 -> 15 |
| **V4** | `cont_assign` RHS: we emit an unnamed `func_call`, golden a `ref_obj` — never reaches the Invalid arm | `g02` | cmp 40 -> 40 |
| **V5** | `T::CONST` in a constant expression gets no object | `d06` | cmp 17 -> 17 |
| R1 | BuildUVMPkg's NEW head: `::`-rooted chain whose tail is a BUILT-IN queue method | 2 of 7 UVM row-modes | reproduced verbatim |
| R2/R4 | nested-`begin` and lone-`VariableDeclaration` drops (corpus 14096) | golden 1 / ours 0 at `line:14096` | reproduced |
| R3 | `::`-rooted chain whose ROOT IS A CALL, concrete flavour | `v3_negctl` c11 | reproduced (`d03` shows the *unbound* twin is now correct) |
| R5-R9 | concat-operand loss, no-default generic, extern double return var, shared typespec | unchanged, byte-identical across binaries | reproduced |

---

## 6. THE FIX FOR F1, BUILT AND MEASURED

A third worktree at `81b8e0c` + the patch + the delta below (absolute build dir,
`Linking CXX executable slang-uhdm` = 1, ` error:` = 0), and then a **fourth**
worktree that re-applied the saved delta and rebuilt it to the **same md5**.

The delta is left here as `f1fix.verifier.patch` (20 lines, all inside
`invalidScopedCallRef59`). It has **two** halves, and the second one is the
reason a one-liner would not have been enough:

```c++
if (inLhs && assignTargetParent48(parent)) {
    auto* b59 = scopedLvalueBadRef48(e, parent, prefix);
    if (b59 && e.syntax)
        setLoc(b59, e.syntax->sourceRange());   // <- REQUIRED
    return b59;
}
```

`scopedLvalueBadRef48` spans `whole.sourceRange`, and an `InvalidExpression`'s
`sourceRange` is **EMPTY** — pass 59's own decode says so. My first build proved
it: the placeholder came out with the right name and **no location at all**,
`\_ref_obj: (…x1::T::@@BAD_SYMBOL@@)` with no `line:` — and `uhdm-cmp` still
printed **0** because it blacklists `vpiLineNo`/`vpiColumnNo`. The span has to
come from the SYNTAX. (First build `a67d20f9…`, corrected build
`f242bf1a324de8d95c4b5f97ab400404`; both md5s asserted in a separate command,
link 1 / errors 0.)

| check | result |
|---|---|
| md5 (separate command) | `f242bf1a324de8d95c4b5f97ab400404`, differs from `167d5696…`; **rebuilt from the saved `f1fix.verifier.patch` in a second worktree and reproduced bit-for-bit** |
| `k01_lvflavour` | y1/y2 -> golden's `T::@@BAD_SYMBOL@@` name **and** span; y4/y5 (READ forms) untouched; y3 (increment) unchanged, see V2b |
| `k02_incbound` (all-bound) | database **BYTE-IDENTICAL** to the shipped binary's — the bound path is untouched |
| `c01_lvalue` (F1's own arm) | cmp **28 -> 0**; `T::@@BAD_SYMBOL@@`@12:7-12:15 == golden, bound control untouched |
| `f01_lvuninst` (F1's second population) | cmp **28 -> 0**; `nosuchpkg59::@@BAD_SYMBOL@@`@6:7-6:23 == golden |
| `v3_negctl` `ours.uhdm` | **BYTE-IDENTICAL** to the shipped binary's |
| `a1_witness` / `a2_position` / `a3_scope` | `ours.uhdm` **BYTE-IDENTICAL** to the shipped binary's (cmp 108 / 108 / 0 unchanged) |
| goldens | `rc=0 PASS=23 FAIL=0` |
| the 7 movers' databases vs the SHIPPED binary's | **IDENTICAL, all 7** (filtered sweep `--filter '^(BuildUVMPkg\|SimpleUVM\|SeqDriver\|Scoreboard)$' --mode both --jobs 2`, own out/workdir; its 8 rows equal the committed baseline rows) |

So the fix is **provably free** on everything pass 59 measured — the entire
change is confined to a cell the corpus does not contain — and it closes the one
finding that keeps this verdict at PARTIAL. Recommendation: **land pass 59 with
`f1fix.verifier.patch` folded in**, and add `c01_lvalue.sv` + `f01_lvuninst.sv`
(in `vcells/`) to the arm set as the lvalue axis's permanent guard.

---

## 6b. THE DEAD VERIFY AGENT'S REPORT EXISTS, AND WE AGREE INDEPENDENTLY

Discovered **after** all of the above was measured (I opened it only while
cleaning up worktrees): the agent that died on the 529 had already written a
complete 478-line report at
`/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10uvm59v/tools/probe/r10uvm59repro/README.verifier.md`
(that worktree is at `81b8e0c` with the patch applied and its `src/ExprEmit.cpp`
is byte-identical to mine, md5 `86a44cc5ce33a012977cc7318356a4e6`). Its verdict
is also **PARTIAL**, and its two substantive findings are **my F1 and my F2b**,
reached by different instruments (its own `vmv59.py` and arms `w1_lvalue`,
`w2_scopekind`, `w2b_scopekind`, `w3_lvflavour`, `w4_constctx`). Two independent
verifications converging on the same over-fire is the strongest statement
available about F1, and its extra pricing work should be kept:

* its corpus census for F1 — pp `uvm_pkg.sv:27097` `super_type::m_typename = tname;`
  is the corpus's **only** candidate lvalue site and slang **binds** it
  (`BAD_SYMBOL` line census golden 21 / pristine 21 / FINAL 21; 26 source sites,
  all concrete or bound) — is the proof behind "0 corpus rows today";
* its F5 (call site 2 carries no "package qualifier keeps the call" test,
  unreachable only because slang hard-errors) and F6 (constant context clean; a
  pre-existing unprefixed `param_assign` `ref_obj (T::CV)`) are worth carrying
  forward.

**Where I extend it** (cells it did not build):

1. **F2**, the second silent population — its §F4 asserts *"only lookups through
   a type parameter are deferred by slang; everything else is a hard error …
   and can never reach the `Invalid` arm"*. `vcells/e01_uninstgen.sv` refutes
   that: an **unknown package** inside `if (0) begin … end` is silent
   (`Lookup.cpp:766`), reaches the arm, and is emitted **correctly**. Its F1
   therefore reaches further than "type-parameter cells" —
   `vcells/f01_lvuninst.sv` shows the over-fire there with no type parameter in
   the file.
2. **F3**, escaped-identifier spellings — untested by both the implementer and
   that verifier, though the campaign's standing rule demands it whenever a gate
   reads name text.
3. **The fix is now BUILT AND GATED** (§6), not just specified: it confirms that
   agent's predicted `Invalid::sourceRange`-is-empty trap (my first build minted
   a location-less placeholder that `uhdm-cmp` still called equal), and it
   measures the blast radius as zero on the 7 movers, the arms and the goldens.
4. `vcells/k01_lvflavour.sv` reproduces its `w3` flavour table on my binaries and
   pins the **third** golden sub-shape (`T::sprop++` -> bare `ref_obj T`).

## 7. FILES I LEFT BEHIND

* `README.verifier.md` — this report.
* `f1fix.verifier.patch` — the measured fix for F1.
* `vcells/` — my 31 hunt cells (`c*`, `d*`, `e*`, `f01`, `g*`, `h*`, `k*`) and
  `vrun.sh`, the one-file golden+ours+dump+cmp runner they were measured with
  (`vrun.sh <abs .sv> <outdir> <slang-binary>`; the binary is never defaulted, a
  missing database is exit 6, both dumps go through `sed 1d`).

All sweep workdirs, the mover dumps and the control/fix worktrees under
`/tmp/v59` were deleted after the numbers above were recorded (only the patched
worktree holding this report survives); `/tmp/claude-1000` was never touched, and
no `git stash` was ever used.
