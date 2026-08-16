# r10earl45 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PARTIAL.**

Every number in the implementer's report reproduced **exactly** — from
worktrees I created at `dcf67d7`, binaries I built myself, and instrument runs
I drove. Both binaries came out **bit-identical** to the implementer's
(`3fa0e6b3e9e5c89252a7fee88c61c4b7` patched,
`d8055b9293cceed38956d86d157caf7c` pristine), so every downstream figure below
is a re-derivation and not a re-reading. The five gates are green on my runs
too, the 186-line head is cleared, the 64-line witness is byte-exact, and the
delivered grids contain **zero** regressions.

**The verdict is PARTIAL and not PASS because of ONE finding, F-1**, produced
by probes I wrote: **§ elabPatternFirstRowElemSize45 as coded stamps
`vpiSize` on unpacked-array pattern rows nested under a STRUCT-keyed or
REPLICATED assignment pattern, where golden stamps nothing.** Four measured
`MATCH -> DIFFER` cells, all *caused by this patch*, on a cmp-compared field
(`expr::Compare` reads `VpiSize`). The stated law says the stamp is placed
"by the OUTERMOST pattern" and "not depth >= 2"; the code's `!wasInPattern`
does not mean that, because `inAssignPattern` is set **only** by the
`SimpleAssignmentPattern` case. **STATED GATE != CODE GATE on this shape.**

Its corpus population is **measured 0** (0 movers in 1358 uhdm2rtlil
databases; Earlgrey's per-shape multiset is `ADDED 1 shape / 2 instances,
REMOVED 0`, i.e. no extra stamp landed anywhere in the design), so **no gate,
no scoreboard row and no byte in either corpus moves because of it**. That is
why this is PARTIAL and not FAIL: the change is landable the moment the gate
is corrected, and the correction is two lines.

The pass rejected its own **arm 2** for a defect of exactly this size — four
stamps, zero verdict impact, visible only in bytes. F-1 is the same defect
class, one generation later, and it is *visible in a grid verdict*.

---

## 0. WHAT I DID, AND ON WHAT

| | |
|---|---|
| base | **`dcf67d7`** — the brief's base. Fresh `git worktree add --detach`; NOT the implementer's trees, NOT an earlier session's |
| patched tree | `/tmp/wt_ve45chk` — `git apply /tmp/r10earl45.patch`; `git status --porcelain` = `M src/ExprEmit.cpp` + `?? tools/probe/r10earl45repro/`, nothing else |
| pristine tree | `/tmp/wt_ve45chkpris` — untouched `dcf67d7`, `git status --porcelain` EMPTY |
| patch md5 | **`138ab494b3da855afb2abd2c06fc0391`** — matches the delivered value |
| patch shape | 19 files, `2300 insertions(+), 13 deletions(-)` |

```sh
git worktree add --detach /tmp/wt_ve45chk     dcf67d7
git worktree add --detach /tmp/wt_ve45chkpris dcf67d7
cd /tmp/wt_ve45chk && git apply --check /tmp/r10earl45.patch && git apply /tmp/r10earl45.patch
```

`git apply --check` is clean at `dcf67d7` **and at the current branch head
`61d5e36`** (third throwaway worktree). `git diff --stat dcf67d7 61d5e36 --
src/ExprEmit.cpp` is **empty**: the file this pass edits has not moved under it
while the pass was in flight.

---

## 1. THE FIVE GATES, RUN INDEPENDENTLY

### GATE 1 — BUILD

```sh
cmake -S /tmp/wt_ve45chk     -B /tmp/wt_ve45chk/build     -DCMAKE_BUILD_TYPE=Release
cmake --build /tmp/wt_ve45chk/build -j 2          # ABSOLUTE paths, -j 2
cmake -S /tmp/wt_ve45chkpris -B /tmp/wt_ve45chkpris/build -DCMAKE_BUILD_TYPE=Release
cmake --build /tmp/wt_ve45chkpris/build -j 2      # run AFTER, never concurrently
```

| | patched | pristine |
|---|---|---|
| lines matching ` error:` | **0** | **0** |
| link line waited for | `[100%] Linking CXX executable slang-uhdm` | same |
| **md5, asserted separately** | **`3fa0e6b3e9e5c89252a7fee88c61c4b7`** | **`d8055b9293cceed38956d86d157caf7c`** |
| base printed + grep-checked | `dcf67d7` | `dcf67d7` |

**Both md5s bit-identical to the implementer's**, in different directories, on
a different day, by a different agent. Every instrument below prints the md5 of
the binary it invoked, and every printed md5 in this report is one of these two.

### GATE 2 — GOLDENS

```sh
SLANG_UHDM=/tmp/wt_ve45chk/build/slang-uhdm ./tests/check_goldens.sh   # PASS=23 FAIL=0
SLANG_UHDM=/bin/false                       ./tests/check_goldens.sh   # PASS=0  FAIL=23
```

### GATE 3 — uhdm2rtlil, BOTH modes, BOTH binaries

`sweeps45.sh`, strictly sequential, `--jobs 2`, one `verify_golden.py` per
(corpus, mode, binary), `GOLDEN_DEFER` unset by the driver, `SLANG_UHDM`
exported.

```
u2r default   pat/pris : 679 CMP_EQUAL  50 SLANG_REJECT  2 SURELOG_FAIL
u2r testflags pat/pris : 679 CMP_EQUAL  50 SLANG_REJECT  2 SURELOG_FAIL
dump column (testflags, both binaries): 496 match  183 differ  52 blank
```

`ct8rows.sh` vs the committed `results/gate_uhdm2rtlil.csv`:
**`0 differing ROWS (0 diff row-sides)`** on the patched CSV *and* on the
pristine CSV; both histograms unchanged. `diff` of the sorted pat/pris CSVs is
**empty in both modes**.

### GATE 4 — surelog, BOTH modes, BOTH binaries

```
SL default   : 469 CMP_EQUAL  11 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
SL testflags : 465 CMP_EQUAL   8 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
               3 NO_DATABASE  1 NO_UHDM  1 TIMEOUT  2 UNTRANSLATABLE
```

`ct8rows.sh` vs the committed `results/golden_surelog.csv` (both modes
concatenated, header once): **`0 differing ROWS`**; both STATUS histograms and
both DUMP-column histograms byte-identical to the baseline. `diff` of the
sorted pat/pris CSVs **empty in both modes**. The target's rows are unchanged:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,
```

**Its ROW does not move; its BYTES do** — which is the entire reason gate 5
exists.

**I did not trust `sweeps45.sh`'s own binary readback** (see F-5: it prints the
GOLDEN CACHE path, not the binary). I read each sweep's `cmds.txt` myself:

```
uhdm2rtlil_pat  -> /tmp/wt_ve45chk/build/slang-uhdm
uhdm2rtlil_pris -> /tmp/wt_ve45chkpris/build/slang-uhdm
surelog_pat     -> /tmp/wt_ve45chk/build/slang-uhdm
surelog_pris    -> /tmp/wt_ve45chkpris/build/slang-uhdm
```

### GATE 5 — BYTE VERIFIER, both corpora, BOTH modes, patched vs PRISTINE

```
uhdm2rtlil : patched=1358 pristine=1358  PATH_SETS_IDENTICAL  MOVERS: 0 / 1358
             SELFCHECK=1 -> 1357 / 1358    SELFCHECK1=1 -> 1
surelog    : patched= 953 pristine= 953   PATH_SETS_IDENTICAL  MOVERS: 2 /  953
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  patched=30f3697ed591 pristine=115906084178
  MOVER ./default/Scoreboard-59431470/slang.uhdm    patched=15c2f6dbcf23 pristine=7ec9925c250e
             SELFCHECK=1 ->  952 /  953    SELFCHECK1=1 -> 3
```

Both mandatory negative controls fire on both corpora, so a "no movers"
reading is a measurement and not an alignment failure. `SELFCHECK1 = 3 = the
corrupted file + the two movers`, `= 1` where there is no mover — exactly what
that control's message says to expect. **Every hash above is character-for-
character the implementer's**, from my own sweeps.

### 1.1 THE MOVER RULE, APPLIED PER MOVER

```
SIZE Earlgrey_0_1/default  patched 49940586  pristine 49940578  ->  +8  NONZERO = REAL
SIZE Scoreboard/default    patched 11123420  pristine 11123420  ->   0  PROVES NOTHING
```

**Earlgrey** is REAL by the stated rule, and the per-shape multiset accounts
for it object-for-object — **two `|vpiSize:32` lines added, nothing removed, in
a 4 655 216-line dump**, i.e. 4 bytes per stamp.

**Scoreboard was ARBITRATED, twice over, and I did not reuse the
implementer's arbitration.**

1. *Content*: I dumped both databases. `uhdm-cmp` is **CMP_EQUAL**, the two
   dumps have the **same line count (1 095 477)**, and `shapes45.sh` reports
   **`ADDED shapes=0 instances=0  REMOVED shapes=0 instances=0`** — the 78
   differing diff-sides are **one block of 39 `bit_typespec` lines relocated**
   inside the weakly-referenced tail. **A permutation, not a content change.**
2. *Distribution*: I ran the test alone, three times per binary.

```
        run1          run2          run3
pat     7ec9925c250e  9e81eef41804  c5bff137b702
pris    7ec9925c250e  9e81eef41804  15c2f6dbcf23     (all 11 123 420 B)
```

**Four distinct hashes across six runs; the PATCHED binary produces
`7ec9925c250e` — the hash the sweep flagged as the PRISTINE side — and the
PRISTINE binary produces `15c2f6dbcf23`, the hash the sweep flagged as the
PATCHED side.** The distributions overlap **both ways** on my runs, exactly as
they did on the implementer's, which is the documented emitter nondeterminism
(`SourceLocation` compares across macro buffers flipping per run under parallel
parse). **ONE real mover in 2 311 databases, and it is the target.**

**CANARIES, DATABASES COMPARED BY NAME** (their CSV rows are `CMP_EQUAL`+
`differ`, i.e. blind to byte changes):

```
InterfaceModPort    default/testflags  BYTE-IDENTICAL (38003 B)
BlackParrotComplex  default/testflags  BYTE-IDENTICAL (48433 / 50584 B)
YosysOldOr          default/testflags  BYTE-IDENTICAL (14783104 B)
SVSwitch            default/testflags  BYTE-IDENTICAL (247237 B)
all 8 genscope canaries (gen_test9, genvar_loop_decl_2/_3,
  paramod_genscope_child, genscope_cells, gen_test4,
  indexed_partsel_array, EnumConcat)   BYTE-IDENTICAL
```

Both binaries' md5s were **re-asserted unchanged after the last gate**.

---

## 2. EVERY NUMBER IN THE REPORT, RE-DERIVED

LHS is always golden: the immutable cache
`~/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm`, dumped by me,
`sed 1d` on both sides.

| quantity | claimed | **mine** |
|---|---|---|
| pristine Earlgrey cmp head | 186 lines | **186**, `diff` vs committed `r10earl44repro/r6_nexthead44.cmp` **EMPTY** |
| patched Earlgrey cmp head | 64 lines | **64**, `diff` vs committed `r6_nexthead45.cmp` **EMPTY** |
| pristine db bytes | 49 940 578 | **49 940 578** |
| patched db bytes | 49 940 586 | **49 940 586 (+8, NONZERO)** |
| pristine dump lines | 4 655 214 | **4 655 214** |
| patched dump lines | 4 655 216 | **4 655 216 (+2)** |
| `shapes45.sh` pris→pat | ADDED 1 shape / 2 instances `[        \|vpiSize:32]`; REMOVED 0 | **verbatim identical** |
| msdist golden↔pristine | 238460 / 70226 / **308686** | **238460 / 70226 / 308686** |
| msdist golden↔patched | 238458 / 70226 / **308684** | **238458 / 70226 / 308684** |
| exact line `        \|vpiSize:32` | golden 1018, ours 1016 → 1018 | **1018 / 1016 / 1018** |
| census Q1 | golden 51 646 / ours 51 473 | **51 646 / 51 473** |
| census Q2 | common 50 972, g-only 674, o-only 501 | **50 972 / 674 / 501** |
| census Q3 | depth0 None/None 533; depth1 None/None 25; depth1 **32/None 2** | **533 / 25 / 2** |
| census Q4 | `prim_keccak` 52:5-52:32 and 193:5-193:32, depth=1, g=32 o=None | **exactly those two** |
| census Q5 pris → pat | 2 → **0** | **2 → 0** |
| grid `a1_earl45` op75 | ROWS 136, non-MATCH 20 → 2 | **136, 20 → 2** |
| grid `v45_order` op75 | ROWS 77, non-MATCH 14 → 4 | **77, 14 → 4** |
| grid `v45_expr` `--all` | ROWS 71, non-MATCH 13 → 12 | **71, 13 → 12** |
| goldens | 23/0, `/bin/false` 0/23 | **23/0, 0/23** |
| u2r | 679/50/2 ×4, dump 496/183/52, ct8rows 0 rows | **all reproduced** |
| surelog | 469/11 and 465/8, FAIL 25/23, DEFER 5/5, ct8rows 0 rows | **all reproduced** |
| byte verifier u2r | MOVERS 0/1358, SELFCHECK 1357, SELFCHECK1 1 | **0/1358, 1357, 1** |
| byte verifier surelog | MOVERS 2/953 (Earlgrey +8 REAL; Scoreboard 0 delta, arbitrated), SELFCHECK 952, SELFCHECK1 3 | **2/953, same two paths, same four md5 prefixes, 952, 3 — and I re-arbitrated Scoreboard independently (§ 1.1)** |
| canaries u2r | ok=8/0/0 | **ok=8 changed=0 absent=0, unknown-names=25** |
| canaries SL | ok=52/0/0 | **ok=52 changed=0 absent=0, unknown-names=7** |
| ctcan2 u2r / SL | `EXPECT_UNKNOWN=6` / `=1` PASS, guard exercised | **PASS/PASS; `=0` exits 6 on BOTH** |
| canaudit | audited=29 UNCOVERED=0 FENCE-BREACH=0 | **29 / 0 / 0** |
| `census45_pristine.txt` | — | **identical to my run as a multiset**; one tie-order line swap (F-4) |

### 2.1 ZERO REGRESSIONS IN THE DELIVERED GRIDS — BY DIRECTION, NOT BY COUNT

A falling count does not prove nothing rose. I asserted the two grids' key
sets **identical** first, then classified every verdict change by direction:

```
a1_earl45  : 18 changes, ALL DIFFER->MATCH, 0 MATCH->DIFFER
v45_order  : 10 changes, ALL DIFFER->MATCH, 0 MATCH->DIFFER
v45_expr   :  1 change,     DIFFER->MATCH,  0 MATCH->DIFFER
```

### 2.2 THE INSTRUMENT A VERDICT CANNOT REPLACE

The arm-2 defect is invisible to a verdict, because golden has **no object** at
those spans and the row is `DIFFER` either way. So I did not use verdicts: I
extracted the **OURS-side field line** of every row of every probe, on both
binaries, and diffed those.

```
a1_earl45  : 19 OURS-side field lines changed
v45_order  : 10
v45_expr   :  1   (g45x_table only)
```

Every one is a `sz=` gain or loss where the law says. The point of the
exercise: **`a45x_exprflat`, `c45x_concat`, `d45x_mixed`, `e45x_descexpr` do
NOT appear** — arm 3's `vpiAssignmentPatternOp` predicate is confirmed at field
level on the four cells whose verdicts are blind to it — and neither do
`l45o_ca`, `m45o_arg`, `j45o_default`, `k45o_repl`, `h45o_flat`, `o45_var`,
`n45_pkg`, `l45_packed`. **The `inParamInit` / `!paramInitPkg` gates hold at
FIELD level, not merely at verdict level.**

---

## 3. THE VERIFIER'S OWN PROBES

Three files, 20 cells, all on gates the delivered probes do not reach:
`tools/probe/r10earl45repro/w45v.sv`, `x45v.sv`, `y45v.sv`, driven by
`varm45v.sh` (an absolute-path arm driver, so a verifier probe
need not live inside the patched tree).

### 3.1 Where the law is CONFIRMED on new ground

| cell | question | golden | pristine | patched |
|---|---|---|---|---|
| `w45_repl_row0` | row 0 written as a **REPLICATION** — arm 3 refuses to stamp a `vpiMultiAssignmentPatternOp` | no size | ✔ | **✔ — arm 3 right on a cell never tested** |
| `w45_repl_desc` | descending; replication lands at `front()`, the pattern row at `back()` | `sz=32` on the pattern row only | ❌ | **✔** |
| `w45_one_desc` | ONE row, descending outer (`int T [0:0][2:0]`), `front()==back()` | `sz=32` | ❌ | **✔** |
| `w45_if` | the table inside an **INTERFACE** | `sz=32` | ❌ | **✔** |
| `w45_default_row0` | row 0 is `'{default:9}` | `sz=32` | ❌ | **✔** |
| `w45_povr_top` | module parameter **overridden at instantiation** | `sz=32` | ❌ | **✔ (size); span mismatch PRE-EXISTING, orthogonal** |
| `w45_enum` | element is a 2-state packed **enum** | **`sz=2`** | ❌ | **✔ — the leaf-width rule at a width nothing else reaches** |
| `w45_three_packedleaf` | `logic [3:0][7:0] T [2][2]`: the strip must stop at the packed vector | `sz=32` | ❌ | **✔** |
| `x45_table_pstruct` | 2-D of packed structs | `sz=16` | ❌ | **✔** |
| `y45_plain` | the control | `sz=32` | ❌ | **✔** |

`w45v` grid `--all`: **ROWS 139, non-MATCH 25 → 19**, 7 OURS-side field lines
changed, **all 7 toward golden**.

### 3.2 THE ENTRY-GATE WIDENING IS INERT OUTSIDE THE LAW

`(operands->size() > 1 || nestedOpsPre9)` dropped its `&& !isUnpackedArr`, so
a ONE-operand unpacked pattern whose operand is an operation enters the
`inParamInit && !paramInitDef` block **for the first time**. I probed exactly
that: `w45_one_expr` (`int T [1] = '{1344/64}`) and `w45_one_concat`
(`logic [7:0] T [1] = '{{4'h1,4'h2}}`). **Neither produces a single changed
byte.** Reading the block confirms why: with one operand the reorder needs
`size > 1`; the leaf-resize loop only touches `constant` operands; and
`o->VpiParent(op)` rewrites a value the child already carries from
`emitExpr(*el, op, ...)`. **The widening's whole observable effect is
`m45_one`.**

---

## 4. FINDINGS

### F-1 — OVER-FIRE, INTRODUCED BY THIS PATCH: an unpacked-array pattern nested under a STRUCT-keyed or REPLICATED pattern is stamped, and golden stamps nothing there. FOUR `MATCH -> DIFFER` CELLS.

`inAssignPattern` is set in exactly three places in the tree
(`ExprEmit.cpp:14469` — the `SimpleAssignmentPattern` case — and
`ParamEmit.cpp:9479, 10264`). **`StructuredAssignmentPattern`
(`ExprEmit.cpp:14736`) and `ReplicatedAssignmentPattern` (`14695`) do NOT set
it.** So `!wasInPattern` does not mean "this op IS the outermost pattern"; it
means "this op is not inside a *Simple* pattern". An unpacked-array pattern
sitting under a struct key or a replication therefore reads
`wasInPattern == false`, is mistaken for the outermost pattern, and stamps its
own first row.

```sh
SLANG_UHDM=/tmp/wt_ve45chkpris/build/slang-uhdm tools/probe/r10earl45repro/varm45v.sh \
    tools/probe/r10earl45repro/y45v.sv /tmp/y45_pris
SLANG_UHDM=/tmp/wt_ve45chk/build/slang-uhdm     tools/probe/r10earl45repro/varm45v.sh \
    tools/probe/r10earl45repro/y45v.sv /tmp/y45_pat
python3 tools/probe/r10earl45repro/grid45.py \
    /tmp/y45_pat/g.dump /tmp/y45_pat/o.dump
# ROWS 38  NON-MATCH 6 (pristine) -> 7 (patched)
```

| cell | shape | golden | pristine | patched |
|---|---|---|---|---|
| `y45_struct_key` 16:30 **d=2 i=0** | `struct { int m [2][3]; } H = '{m: '{'{1,2,3},'{4,5,6}}}` | **no size** | MATCH (none) | **`sz=32` — DIFFER** |
| `y45_struct_key3` 22:30 **d=2 i=0** | the same with three unpacked levels | **no size** | MATCH (none) | **`sz=32` — DIFFER** |
| `x45_in_struct` 31:34 **d=2 i=0** | independent second probe, same shape | **no size** | MATCH (none) | **`sz=32` — DIFFER** |
| `y45_repl_table` 29:38 **d=1 i=0** | `int T [2][2][3] = '{2{'{'{1,2,3},'{4,5,6}}}}` | **no size** | MATCH (none) | **`sz=32` — DIFFER** |

The field is `VpiSize`, which `expr::Compare` **does** read (I extracted the
body), so these are genuine `uhdm-cmp` divergences and not dump display. In
`y45v` the net grid effect is `NON-MATCH 6 -> 7`: the patch takes one cell
(`y45_struct_key3` 22:51, which the OLD refuted rule over-stamped) and gives
back two — **the over-stamp moves from index 1 to index 0, it does not go
away**, on shapes the law claims not to touch.

**What the law says vs what the code does.** The law: *"stamped by the
OUTERMOST pattern on its own FIRST OPERAND, never by a nested op on itself …
NOTHING ELSE is stamped: … not depth >= 2"*. The code stamps a **depth-2** op
in three of the four cells above.

**Population: measured 0 in both corpora.** GATE 5 reports `MOVERS 0 / 1358`
on uhdm2rtlil, and Earlgrey's per-shape multiset is `ADDED 1 shape / 2
instances, REMOVED 0` — no extra stamp landed anywhere in a 4.65-million-line
design, even though 32 corpus files (Earlgrey's `hmac.sv` among them) contain a
keyed pattern whose value is itself a pattern. So **no gate moves, no
scoreboard row moves, no corpus byte moves**. This is a latent defect on a
legal construct, not a live regression — hence PARTIAL, not FAIL.

**The correction is local.** `!wasInPattern` needs to mean what it says. Either
give the two other pattern cases the same save/set/restore of
`inAssignPattern` (widest blast radius — `wasInPattern` also drives the
constant re-parenting and the `VpiSize(1)` stamp, so that route needs its own
grid), or keep this law's gate honest without touching the flag:

```cpp
// § 45 gate, in addition to !wasInPattern
bool nestedUnderAnyPattern45 =
    parent && parent->UhdmType() == UHDM::uhdmoperation &&
    (((UHDM::operation*)parent)->VpiOpType() == vpiAssignmentPatternOp ||
     ((UHDM::operation*)parent)->VpiOpType() == vpiMultiAssignmentPatternOp ||
     ((UHDM::operation*)parent)->VpiOpType() == vpiConcatOp);
```

**I did not re-cut PRODUCTION code.** The fix changes emitted bytes and would
need all five gates re-run end to end, which is the pass owner's call, not the
verifier's — `/tmp/r10earl45.verified.patch` carries the delivered production
diff **byte-identical** and adds only this report and the three probes. The
four cells above are the regression test the fix must pass; `y45v.sv` and
`x45v.sv` are in the repro directory ready to run.

### F-2 — UNDER-FIRE: a NON-INTEGRAL leaf is stamped by golden and not by us. NOT NAMED ANYWHERE IN THE PASS.

`leaf->isIntegral()` is in the code gate with no probe behind it and no residue
naming it. Two independent cells:

| cell | shape | golden | ours (pristine AND patched) |
|---|---|---|---|
| `w45_real` 20:32 | `localparam real T [2][3]` | **`sz=32`** | **none** |
| `x45_flat_ustruct` 21:29 | `localparam su_t T [2]`, `su_t` = unpacked `struct {int c; int d;}` | **`sz=64`** | **none** |

Two consequences, the second more interesting than the first:

1. it is a **MISS, not a regression** — equally wrong on the pristine binary,
   and no gate could catch it, because a miss adds no bytes and the byte
   verifier is blind to it by construction;
2. **it refutes the law's VALUE clause outside the integral case.** The stated
   value is "the width after stripping every UNPACKED dimension", which for
   `real` is **64** — golden writes **32**. So "leaf bit width" is not the rule
   golden implements; it is a rule that coincides with golden's on every
   integral leaf measured (32, 8, 12, 16, 2, and 32 from a packed leaf) and
   disagrees on the first non-integral one tried.

Population of the `real` form: **0** —
`grep -rlE "(localparam|parameter)[^;]*\breal\b[^;]*\[[^]]*\]\s*\["` over
`Surelog/tests`, `Surelog/third_party/tests`, `uhdm2rtlil/test` returns
nothing. It belongs in the residue list; it is not there.

### F-3 — the new head's write-up overstates which fields `constant::Compare` reads.

The README says of the 64-line head: *"golden `INT:0`/`vpiConstType:7` vs ours
`UINT:0`/`vpiConstType:9` … **Both fields are read by `constant::Compare`**."*
They are not. Brace-counting extraction of the body:

```
constant::Compare -> VpiConstType         (plus, via expr: VpiDecompile, VpiSize, Typespec)
```

The **value** (`INT:0` / `UINT:0`) is dump display; the cmp-load-bearing field
in the new head is **`vpiConstType` alone**. This makes the next pass's target
*narrower*, and it should be stated that way.

While there I re-ran the pass's own central claim and **confirmed it**:
**232** `::Compare(const BaseClass` bodies, **0** containing `VpiParent`; and
`expr::Compare` **does** read `VpiSize`. (The brief says "233"; the implementer
and I both measure **232** — the brief is off by one, not the implementer.) So
the decision to treat the re-parenting axis as display and `vpiSize` as the
head is **correct and independently verified**.

### F-4 — `census45_pristine.txt` is not byte-stable across runs.

It is committed as "the artifact the prediction was made from". My re-run of
the same script on the same two dumps differs by a **two-line swap** in Q2
(`opType 72 None None 2` and `opType 75 32 None 2`, equal counts): the tally is
iterated from a `set`, so ties come out in hash order.

```sh
diff <(sort tools/probe/r10earl45repro/census45_pristine.txt) <(sort my_census_pris.txt)   # EMPTY
```

Cosmetic — but a committed artifact a later pass may `diff` byte-for-byte
(exactly as this pass `diff`s `r6_nexthead44.cmp`) should sort
deterministically. The `.cmp` witnesses do not have this problem.

### F-5 — `sweeps45.sh`'s "the binary the sweep ACTUALLY invoked" readback does not read the binary.

```sh
grep -o '[^ ]*slang-uhdm' "$c" | head -1
```

`head -1` picks the **first** match in `cmds.txt`, which is the golden cache
path `/home/heyfey/.cache/slang-uhdm-goldens/...`. Every one of my eight sweeps
printed `cmds.txt binary: /home/heyfey/.cache/slang-uhdm`. **The cited guard
does not check what the citation claims** — this campaign's signature failure
mode, in the very script whose header warns about it. I read the binaries out
myself (§ 1 GATE 4) and they are correct, so nothing downstream is affected;
the guard is what is broken, not the run.

### F-6 — three delivered cells are EMPTY PRODUCTS in the view where the law lives.

I tallied, per probe module and per dump section, how many op75 cells each cell
produces **on each side**:

| cell | comment claims | actually produces |
|---|---|---|
| `v45_order i45o_concat` | "nested patterns under a NON-pattern outermost (a concat)" | `localparam logic [63:0] T = {32'h1, 32'h2}` has **no nested pattern at all**, and **one** row, in `allModules` only. Vacuous twice over. |
| `a1_earl45 l45_packed` | "a PACKED 2-D pattern … this law must not touch it" | **one** row, `allModules` only. **No elab op on either side**, and the law only acts in the elab view — it can control nothing. |
| `v45_order m45o_arg` | "the second negative control on the `inParamInit` gate" | **zero** `topModules` rows: both sides fold the argument away, so no stamp is observable even if the gate were removed. |

All three are labelled honestly in the implementer's own grid tables ("(no
cell)", "(no elab op either side)", "folded on both sides in elab") — this is a
**naming** finding, not concealment. But § 2 of that README lists `l45_packed`
among "the positive controls this pass exists to survive", and **it survives
nothing**. The working controls for the packed path are `p45_arrofvec` and my
`w45_three_packedleaf` / `x45_flat_pvec`; the working control for `inParamInit`
is `l45o_ca`, proved unmoved at **field** level in § 2.2 (its verdict alone
proves nothing). **No cell was found to be *silently* empty.**

---

## 5. BOUNDARIES AND LIVE PASSES — CHECKED, NOT ASSERTED

| boundary | how | result |
|---|---|---|
| **§ importedConcatNoMdimReorder42** (ParamEmit, concat ORDER) | re-ran `arm42.sh` on `a1_earl42.sv` + `v42_overfire.sv` with BOTH binaries; compared `o.dump` **path-normalised** | **BYTE-IDENTICAL**; grids unchanged |
| **§ defConnPkgParamFold43** (ModuleEmit conn loop) | same, all four `r10earl43repro` probes | **BYTE-IDENTICAL**; grids `61/4`, `4/0`, `34/3`, `18/2` on both binaries |
| **§ scopedConnPkgParamSubst44** (ModuleEmit conn loop) | same, all three `r10earl44repro` probes | **BYTE-IDENTICAL**; grids `99/19`, `28/8`, `20/6` on both binaries |
| pass-44 head | `diff` my pristine Earlgrey `cmp.log` vs committed `r6_nexthead44.cmp` | **EMPTY** — the pass stands on the base the brief describes |
| **r10uvm73** | `git diff --stat dcf67d7 61d5e36 -- src/ExprEmit.cpp` | **empty**; 73 landed in `EmitHelpers.h` + `UhdmExporter.cpp`. No collision |
| **r10sd5** (`ModuleEmit.cpp` ~4097 clone) | the patch touches **no** `ModuleEmit.cpp` line | no collision |
| slang patched? | `git apply --stat` file list | `src/ExprEmit.cpp` + 18 files under `tools/probe/r10earl45repro/`, nothing else; `results/*.csv` untouched |

**Patch hygiene**: 18 new probe files (10 mode `100755`, 8 mode `100644`), one
modified production file, no `results/`, no other production path, and
**`README.verifier.md` correctly absent from the DELIVERED patch** — it is this
file, and it enters the tree through `/tmp/r10earl45.verified.patch`, whose
production diff is byte-identical to the delivered one (the verified patch
CONTAINS this file, so its md5 is reported in the verifier's final message and
deliberately not written here — it would be stale the moment it was). `GOLDEN_DEFER` unset throughout.

---

## 6. RANKED RESIDUES (the verifier's ranking)

1. **F-1 — the struct-keyed / replicated nesting over-fire.** The only item that
   must move before this lands cleanly. Two lines, four regression cells ready.
2. **R1 — the new head** (`prim_keccak.sv:60:31`, gen-scope `int` fold signed on
   golden, unsigned on us). Confirmed; `r6_nexthead45.cmp` byte-exact against my
   patched binary. **Narrower than stated: the cmp-visible field is
   `vpiConstType` alone (F-3).**
3. **F-2 — non-integral leaves (`real`, unpacked struct) are never stamped.**
   The one measured counterexample to the law's value clause.
4. **R2 — spurious `vpiReordered` on nested ops of an unpacked array of PACKED
   arrays.** Pre-existing; confirmed on `p45_arrofvec` and reproduced on my
   `w45_three_packedleaf` (4 cells) and `x45_flat_pvec` (2 cells). Earlgrey
   population 0.
5. **R4 — `'{default:N}` and cont-assign patterns: we emit ops golden folds
   away.** Confirmed. Note the pair is **not** symmetric: `'{default:9}` as a
   nested ROW is an object on both sides and is stamped by both
   (`w45_default_row0`); only the whole-array `'{default:7}` is folded by golden.
6. **R3 — missing `ref_typespec` on a struct-element array's outermost op.**
   Confirmed on `g45o_struct` and reproduced on `x45_table_pstruct`.
7. **F-5 / F-4 / F-6** — the instrument and write-up defects above.
8. **R5 / R6** — the decoded-but-inert constant-sharing mechanism, and the
   238 458 : 70 226 golden-only : ours-only asymmetry. Unchanged as conclusions.

---

## 7. WHAT WOULD HAVE CHANGED MY VERDICT, IN EITHER DIRECTION

**To PASS**: F-1 not existing, or existing only as a shape golden also emits no
object for. Neither is the case: golden emits the object and leaves it unsized,
and we now size it.

**To FAIL**: any of — a corpus byte mover other than the target (there is
none: 0/1358 on uhdm2rtlil, and the surelog side is accounted for under the
MOVER RULE); a `MATCH -> DIFFER` in any **delivered** grid (there is none, on
349 rows across four files); a boundary probe whose dump moved (there is none,
across all nine §42/§43/§44 probe files); a `ct8rows` row moving against either
committed baseline (0 and 0); or a gap between the stated gate and the code
gate on the shapes the law *does* claim (there is none — the three code changes
are exactly the three the write-up names; the gap is on shapes it claims **not**
to touch, which is F-1).

---

## 8. FILES

All four are **added to this directory by the verifier** and are in
`/tmp/r10earl45.verified.patch`.

| file | what it is |
|---|---|
| `README.verifier.md` | this report |
| `w45v.sv` | 11-cell boundary probe: replication rows (both orders), `real`, one-row descending, the two one-operand shapes the entry-gate widening newly admits, interface, `'{default:N}` as row 0, parameter override at instantiation, enum leaf, packed leaf at three unpacked dimensions |
| `x45v.sv` | 5-cell probe: 1-D arrays whose operands ARE patterns (packed struct, unpacked struct, packed vector), a table under a struct key, and the 2-D packed-struct control |
| `y45v.sv` | 4-cell probe isolating **F-1**: struct-keyed nesting at two depths, a table under a replication, and the plain control. **This is the regression test the F-1 fix must pass: `ROWS 38 NON-MATCH 6` on the pristine binary, `7` on the patched one; a correct fix returns it to `6` while leaving `y45_plain` at MATCH.** |
| `varm45v.sh` | absolute-path arm driver (`SLANG_UHDM` has no default, md5 printed, `sed 1d` on both dumps, db bytes printed), so a verifier probe need not live inside the patched tree |

```sh
# reproduce F-1 from scratch
SLANG_UHDM=<pristine> tools/probe/r10earl45repro/varm45v.sh \
    $PWD/tools/probe/r10earl45repro/y45v.sv /tmp/y45_pris
SLANG_UHDM=<patched>  tools/probe/r10earl45repro/varm45v.sh \
    $PWD/tools/probe/r10earl45repro/y45v.sv /tmp/y45_pat
python3 tools/probe/r10earl45repro/grid45.py /tmp/y45_pris/g.dump /tmp/y45_pris/o.dump | tail -1
python3 tools/probe/r10earl45repro/grid45.py /tmp/y45_pat/g.dump  /tmp/y45_pat/o.dump  | tail -1
```
