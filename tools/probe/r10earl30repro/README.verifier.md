# r10earl30 — ADVERSARIAL VERIFIER REPORT

## VERDICT: **PASS**

Every number in the implementer's report reproduced on a **fresh 81b8e0c tree
that I patched and built myself**, and the two things I was told to hunt —
an empty product cell and an over-fire — are **not there**. I built 30 new
product cells the implementer's grid never covered; the rule fires on 15 of
them and **all 15 land exactly on golden, 0 move away**. The claimed
non-conversion of `Earlgrey_0_1/default` is correct and I reproduced the
row byte-for-byte.

I did find **three things worth recording** — one refutation of a stated
mechanism claim (F13), one new residue class (F14), and one extension of the
implementer's own R3 (F15). **None of them is a defect in the shipped patch**;
all three are abstentions or documentation, and I say so explicitly below.

```
patched  binary md5 0321a165b730e917c15a55fb12039e3c   (matches implementer)
pristine binary md5 7922a457a58565ff014f9c440b585eb6   (32 hex, matches baseline)
patch    /tmp/r10earl30.patch  md5 2205217d315f7ea06460141928901d21  (matches)
```

My trees (both at `81b8e0c`, built by me, independent of the implementer's):

```
/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl30v        (patched)
/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl30vpris    (pristine control)
```

---

## THE ONE-LINE JUDGEMENT ON THE LAW

`§ enumSubstIntConst30` is **two lines of code** (the same line at two sites)
that add the missing `INT:` arm to a `BIN:/HEX:/OCT:/DEC:` ternary chain, so a
constant minted by copying an `enum_const`'s value derives `vpiConstType` from
that value instead of falling through to `vpiUIntConst`. The gate is
`v.rfind("INT:", 0) == 0` and nothing else.

**Stated gate == code gate: confirmed.** I read both hunks (`src/ExprEmit.cpp`
~5169, `src/ModuleEmit.cpp` ~23806). There is no context, scope, view or
base-type predicate anywhere in the change, so every unmeasured origin abstains
by construction — which is exactly why my 30 new cells could not break it.

**The prefix-collision trap is handled.** `"UINT:0".rfind("INT:", 0) == 0` is
false (`rfind` with `pos = 0` anchors at position 0), so `UINT:` does **not**
fall into the new arm. Proved empirically, not by reading: Earlgrey's **75,252
`(UINT:, 9)` constants are unchanged, exactly** (F7).

---

## NUMBERED FINDINGS

### F1 — GATE 1 reproduced bit-for-bit, in four independent builds

```
$ cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build build -j 6
$ grep -c "Linking CXX executable slang-uhdm" /tmp/v30_build.log   -> 1     (patched)
$ grep -icE "error:"                          /tmp/v30_build.log   -> 0
$ grep -c "Linking CXX executable slang-uhdm" /tmp/v30p_build.log  -> 1     (pristine)
$ grep -icE "error:"                          /tmp/v30p_build.log  -> 0
```

md5 asserted as a **separate** command, every binary's path printed:

```
.../r10earl30v/build/slang-uhdm       0321a165b730e917c15a55fb12039e3c   <- mine, patched
.../r10earl30vpris/build/slang-uhdm   7922a457a58565ff014f9c440b585eb6   <- mine, pristine
.../r10earl30/build/slang-uhdm        0321a165b730e917c15a55fb12039e3c   <- implementer's
.../r10earl30pris/build/slang-uhdm    7922a457a58565ff014f9c440b585eb6   <- implementer's
```

BASE grep-checked on all four: `git rev-parse --short HEAD` = `81b8e0c` in every
tree; `md5sum src/ExprEmit.cpp src/ModuleEmit.cpp` splits them into exactly two
groups (patched `96b76b61…,6d6b3541…`; pristine `415efa3b…,a40ac0d9…`).
Baseline is 32 hex characters. **MD5 CHANGED: PASS.**

### F2 — GATE 2 reproduced, with the negative control

```
$ SLANG_UHDM=$PWD/build/slang-uhdm ./tests/check_goldens.sh | grep -cE "^PASS"   -> 23   FAIL -> 0
$ SLANG_UHDM=/bin/false           ./tests/check_goldens.sh | grep -cE "^PASS"   -> 0    FAIL -> 23
```

`SLANG_UHDM` pinned — the harness defaults it to the main tree, exactly as the
implementer warned.

### F3 — GATE 3 reproduced exactly, plus a control they did not run

```
$ SLANG_UHDM=... verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 \
      --out /tmp/v30_u2r_patched.csv --workdir /tmp/v30wd_u2r_patched
  CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
  dump column: 496 match / 183 differ / 52 blank
$ ./tools/probe/r10oth8repro/ct8rows.sh results/gate_uhdm2rtlil.csv /tmp/v30_u2r_patched.csv
  baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
  WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  PASS: every row byte-identical to the committed baseline
```

**My addition:** the patched and pristine u2r CSVs are **byte-identical**
(`cmp v30_u2r_patched.csv v30_u2r_pris.csv` → identical), which is the CSV-level
statement matching GATE 5's 0/679.

### F4 — GATE 4 reproduced exactly; the row does **NOT** convert

```
$ SLANG_UHDM=... verify_golden.py --corpus surelog --mode both --jobs 2 \
      --out /tmp/v30_sl_patched.csv --workdir /tmp/v30wd_sl_patched
  [default]   CMP_EQUAL: 467  CMP_NOTEQUAL: 13  DEFERRED: 5  SLANG_REJECT: 284  SURELOG_FAIL: 25
  [testflags] CMP_EQUAL: 463  CMP_NOTEQUAL: 10  DEFERRED: 5  SLANG_REJECT: 286  SURELOG_FAIL: 23
              NO_DATABASE: 3  UNTRANSLATABLE: 2  TIMEOUT: 1  NO_UHDM: 1
$ ./tools/probe/r10oth8repro/ct8rows.sh results/golden_surelog.csv /tmp/v30_sl_patched.csv
  1589 lines = 1588 ROWS both sides ; 0 differing ROWS (0 diff row-sides)
  dump: default 225 match / 242 differ / 327 blank ; testflags 165 match / 298 differ / 331 blank
  PASS: every row byte-identical to the committed baseline
```

**Default is 467/13, NOT 468/12.** The implementer's headline is correct. The
row, re-run by me in both modes:

```
-- fresh (my patched build):
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,
-- committed results/golden_surelog.csv:
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,
```

Byte-identical. No conversion-adjusted expectation is needed. `results/*.csv`
were only ever read: `git status --short results/ scripts/ tests/` = **0 lines**
in my patched tree.

My **pristine** sweep also reproduces the committed surelog baseline at **0
differing ROWS**, which is what makes GATE 5 meaningful.

### F5 — GATE 5 reproduced, and my run is *cleaner* than theirs

```
$ ./tools/probe/r10oth6repro/byteverify.sh /tmp/v30wd_u2r_patched /tmp/v30wd_u2r_pris
  PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
  SELFCHECK  = 678 / 679 flagged    SELFCHECK1 = 1
$ ./tools/probe/r10oth6repro/byteverify.sh /tmp/v30wd_sl_patched /tmp/v30wd_sl_pris
  PATH_SETS_IDENTICAL (953 paths)
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  patched=60455a1c30c3 pristine=a5e4b8d46499
  MOVERS: 1 / 953
  SELFCHECK  = 952 / 953 flagged    SELFCHECK1 = 2   (= 1 real + 1 injected)
```

**I get 1 surelog mover, they got 2.** `Scoreboard` did not move in my run at
all. That is not a discrepancy against them — it is the *strongest* possible
confirmation of their §5.1: the Scoreboard "mover" is per-run instability that
simply did not fire this time. See F16 for the direct proof.

### F6 — THE HEAD IS CLEARED. cmp 36 → 17, both heads quoted

Golden from the harness cache (`00d4794526e44dc553f3`), `uhdm-cmp` run by me:

```
$ uhdm-cmp golden.uhdm <pristine>/slang.uhdm   -> lines=36  heads=1
$ uhdm-cmp golden.uhdm <patched>/slang.uhdm    -> lines=17  heads=1
```

The head at pristine — **the assigned target, exactly as the brief described it**:

```
LHS: decompile:  constant: , id:78700, line:389:36, endln:389:50
     |vpiDecompile:0  |vpiSize:3  |INT:0  |vpiConstType:7
RHS: decompile:  constant: , id:78639, line:389:36, endln:389:50
     |vpiDecompile:0  |vpiSize:3  |INT:0  |vpiConstType:9
```

The head at patched — **a different object, a different field**:

```
LHS: decompile:  ref_typespec: (work@dm_csrs.csr_read_write.dmi_req_i.data[4'h2 - 1:0].data), id:78753
     |vpiParent: \_constant: , id:78752, line:408:65, endln:408:69
     |vpiActual: \_logic_typespec: , id:78754, line:25:14, endln:25:25
RHS: <null>
```

ONE head per run on both sides (`grep -c "^LHS:"` = 1). The assigned field is
gone from the head; the new head is the implementer's R1.

### F7 — the Earlgrey census reproduces cell-for-cell under an **independently written reader**

I did not use their `dumpread.py`/`ctcensus.py`. I wrote `vcensus.py`, which
attributes fields with an **explicit open-object stack** rather than their
forward-scan-with-subtree-skip, and which has its own `--selfcheck` (it passes,
and it also proves a nested `int_typespec`'s `vpiConstType:99` does **not** leak
into the parent constant). Same answers by a different route:

| VALUE | ct | GOLDEN | OURS BEFORE | OURS AFTER |
|---|---|---|---|---|
| BIN: | 3 | 16791 | 16703 | 16703 |
| DEC: | 1 | 567 | 567 | 567 |
| HEX: | 5 | 17877 | 17809 | 17809 |
| **INT:** | **7** | **22937** | **19670** | **19682** |
| **INT:** | **9** | **0** | **12** | **0** |
| INT: | none | 64 | 64 | 64 |
| STRING: | 6 | 1125 | 1125 | 1125 |
| **UINT:** | **9** | **77171** | **75252** | **75252** |

`(INT:, 9)` is **0 in golden**, `12 → 0` in ours, and `(INT:,7)` goes
`19670 → 19682 = 19670 + 12`. **Exact.** Every one of their §4 numbers is
reproduced. (Their `NOVAL: 18847/15431` bucket is the bare back-reference object
headers my reader excludes: `136628 + 18847 = 155475`, their total. The two
readers reconcile completely.)

Dump line counts: golden 4,823,448 / ours 4,654,873 **before and after** — the
complete dumps, so their §7 partial-dump defect is not in play here.

### F8 — 12 movers, at exactly the 12 reported spans, **12/12 landing on golden**; R1 proved pre-existing

Whole-design patch effect:

```
$ diff /tmp/v30_earl_ob.dump /tmp/v30_earl_oa.dump | grep -cE '^[<>]'   -> 24
     12 |vpiConstType:7
     12 |vpiConstType:9
$ grep -c "408:65" /tmp/earl.eff   -> 0
```

**The patch's entire effect on this database is 12 `vpiConstType` lines and
nothing else** — no other field, no span, no re-parenting. And `408:65` (the new
head) is **nowhere** in that effect, so **R1 is pre-existing: PROVED
independently.**

Span-keyed three-way join, all 12 (`G`/`B`/`A` = golden / before / after, as
`value/ct/size/decompile`):

```
134:24-134:38  G=INT:0/7/3/0  B=…/9/…  A=…/7/…   LANDS-ON-GOLDEN
149:24-149:46  G=INT:4/7/3/4  B=…/9/…  A=…/7/…   LANDS-ON-GOLDEN
193:20-193:42  G=INT:2/7/3/2  B=…/9/…  A=…/7/…   LANDS-ON-GOLDEN
198:20-198:41  G=INT:3/7/3/3  B=…/9/…  A=…/7/…   LANDS-ON-GOLDEN
389:36-389:50  G=INT:0/7/3/0  B=…/9/…  A=…/7/…   LANDS-ON-GOLDEN   <- THE WITNESS
390:24-390:38  G=INT:1/7/3/1  B=…/9/…  A=…/7/…   LANDS-ON-GOLDEN   <- dm::CmdErrBusy (non-zero)
400:36-400:50  400:36 … 411:24, 575:25, 602:41   LANDS-ON-GOLDEN (all)
SUMMARY: 12/12 land exactly on golden
```

**0 moved away, 0 over-fire.** Four distinct `dm::cmderr_e` members including the
brief's requested non-zero `dm::CmdErrBusy`, across three contexts.

### F9 — multiset distance reproduces exactly

```
$ msdist.sh (@7c7eaa6, md5 7c0d46b5da124cfe37d27eddc95eb7e7) g.dump o.dump
  BEFORE  MULTISET DISTANCE 309605
  AFTER   MULTISET DISTANCE 309589      (-16)
```

Their number, to the digit. Attribution was done per-shape span-keyed (F8), not
from raw `diff -u` counts.

### F10 — the grid reproduces cell-for-cell on all six of their arms; g4_ctrl is **byte-identical**

Measured with **my** reader, on **my** builds:

| arm | golden (INT:,7) | golden (INT:,ct≠7) | ours BEFORE 7/9 | ours AFTER 7/9 |
|---|---|---|---|---|
| g1_ctx | 14 | **0** | 1 / 13 | **14 / 0** |
| g2_origin | 7 | **0** | 2 / 2 | **4 / 0** |
| g3_base | 16 | **0** | 0 / 16 | **16 / 0** |
| **g4_ctrl** | 5 | **0** | 5 / 0 | **5 / 0** |
| g5_scope | 7 | **0** | 0 / 7 | **7 / 0** |
| g6_iface | 2 | **0** | 0 / 2 | **2 / 0** |

Every cell matches their §3.0 table. `(INT:, ct≠7)` is **0 in golden in all six
arms**. Per-arm patch effect, paths normalized:

```
g1_ctx     changed-sides=26  kinds: |vpiConstType:7 |vpiConstType:9
g2_origin  changed-sides=4   kinds: |vpiConstType:7 |vpiConstType:9
g3_base    changed-sides=32  kinds: |vpiConstType:7 |vpiConstType:9
g4_ctrl    changed-sides=0   kinds: <none>          <- BYTE-IDENTICAL (cmp -s)
g5_scope   changed-sides=14  kinds: |vpiConstType:7 |vpiConstType:9
g6_iface   changed-sides=4   kinds: |vpiConstType:7 |vpiConstType:9
```

= 13 / 2 / 16 / 0 / 7 / 2 objects, their numbers exactly. **The over-fire
control is byte-identical, not merely equal in count.**

The **second call site really fires**: `g6_iface` changes 2 objects, and golden's
two `INT:` constants there (spans `21:14-21:20` and `23:14-23:20`, `INT:0`/`INT:2`,
size 3) read **ct=7** — so both movers land on golden's field. After the patch our
whole g6 cross-tab (`HEX:5 ×1, INT:7 ×2, UINT:9 ×44`, 47 constants) is
**identical to golden's**. The `HEX:` member stays 5 and the unsized-decimal
member stays 9, as they claimed.

### F11 — **MY EMPTY-PRODUCT-CELL ARM: 30 new cells, 15 fires, 15 land on golden, 0 away**

This is the finding I was told to hunt for, and the answer is negative.
`v7_empty.sv` (in this directory) holds the cells their four-axis grid never
built, all at the witness's context (right operand of `==` in `always_comb`):

`int unsigned`, `byte unsigned`, `shortint unsigned`, `longint`,
`longint unsigned`, `integer`, a **negative** member (`= -1`), an implicit member
**immediately following** an unsized-decimal member, **expression** members
(`PP + 1`, `PP * 2`), **unbased-unsized** literals (`'0`, `'1`), a **signed based**
literal (`4'sd1`), `bit`/`logic` with **no range**, a **>32-bit** value
(`64'd5000000000`), and a `reg [3:0]` base.

```
$ SLANG_UHDM=<patched>  ./arm30.sh v7_empty.sv   -> DUMP_DIFF content=141
$ SLANG_UHDM=<pristine> ./arm30.sh v7_empty.sv   -> DUMP_DIFF content=171
$ diff (normalized o.dumps) | grep -cE '^[<>]'   -> 30
     15 |vpiConstType:7
     15 |vpiConstType:9        <- and NOTHING else
```

Span-keyed three-way verdict over all 30 cells:

```
MOVER-ONTO-GOLDEN : 11   (longint, integer, bit, logic, reg[3:0], and the
                          implicit-after-unsized-decimal cell -- my best
                          over-fire candidate, which the rule gets RIGHT)
MOVER-PARTIAL     :  4   (vpiConstType lands on golden; a *decompile*
                          divergence remains -- that is their R3, see F15)
MOVER-AWAY        :  0   <== THE RESULT
ABSTAIN-MATCH     : many (already equal to golden, untouched)
ABSTAIN-DIVERGE   : 10   (pre-existing, identical before and after)
```

**Zero cells moved away from golden. Zero over-fire.** The negative control
holds here too: `H0 = 0` (unsized decimal) is `UINT:0 ct=9 sz=64` in golden and
in ours, before and after.

### F12 — the over-fire direction does not exist at the layer that feeds the rule

The rule can only over-fire if **our** `enum_const` value says `INT:` where
**golden's** says something else. I checked that directly, per span, on the
`enum_const` objects themselves:

```
v7_empty arm:  enum_const spans matched with the SAME encoding      : 43
               OURS = INT: while GOLDEN != INT:  (over-fire direction) : 0
               OURS != INT: while GOLDEN = INT:  (abstention)          : 24
Earlgrey    :  enum_const spans where the PREFIX SET disagrees        : 0
```

Every encoding disagreement points the **safe** way — we lack `INT:`, so we do
not fire and keep the pre-patch answer. On the target design the per-span
encodings agree with golden **exactly** (the aggregate `INT: 1474 vs 1410`
difference is pure object *multiplicity*, 343 duplicate objects across views —
an object-count residue, not an encoding one).

### F13 — REFUTATION of their §2 mechanism claim (documentation, not a defect)

Their §2 states: *"The `enum_const` objects themselves are **byte-identical**
between golden and ours on every arm."* That is true on **their six arms** and on
**Earlgrey** (F12), but it is **false in general**, and my arm shows it:

```
v7_empty enum_const cross-tab:
  golden : BIN: 4   INT: 56   UINT:  7   (67 objects)
  ours   : BIN: 10  INT: 35   UINT: 22   (67 objects)
```

21 `enum_const` objects carry a different value encoding than golden's. **This
does not touch the patch's correctness** — every one of those disagreements is in
the abstaining direction (F12) — but the claim as written is broader than the
evidence supports, and a future pass that widens either call site must not rely
on it. Scope the claim to "on the measured arms".

### F14 — NEW RESIDUE (mine): unsigned integer-atom enum bases abstain where golden wants 7

The single largest block of missed gain in my arm, and it is a clean class:

| enum base | golden enum_const | golden folded ct | ours enum_const | ours folded ct |
|---|---|---|---|---|
| `int unsigned` | `INT:0` / `INT:1` | **7** | `UINT:0` / `UINT:1` | 9 (abstains) |
| `byte unsigned` | `INT:` | **7** | `UINT:` | 9 (abstains) |
| `shortint unsigned` | `INT:` | **7** | `UINT:` | 9 (abstains) |
| `longint unsigned` | `INT:` | **7** | `UINT:` | 9 (abstains) |

8 cells (spans `60:19, 61:19, 62:19, 63:19, 64:19, 65:19, 68:19, 69:19`). The
**signed** atoms (`int`, `longint`, `integer`, `byte`) all produce `INT:` on both
sides and all move correctly — so the divergence is specifically that we encode
an *unsigned integer-atom* enum base's member as `UINT:` where Surelog encodes it
`INT:`. This is the same root cause as their R5 (the *value* is wrong one layer
upstream), extended to a new origin class; fixing the value gives the const type
for free, exactly as they argue. **Correctly abstained by the shipped rule.**

Also in this class, and also correctly abstained: a **negative** member
(`G0 = -1`: golden `INT:-1 ct=7 sz=64`, ours `BIN:1111…1 ct=3 sz=32`) and
**expression** members (`I0 = PP+1`: golden `UINT:6 ct=9`, ours `BIN:00000110
ct=3`) — where golden itself is not self-consistent across views (`I1 = PP*2`
reads `INT:10 ct=7` in one view and `UINT:10` in another).

### F15 — their R3 is real, accurately described, and **wider than they measured**

The one-liner they say is already in-tree is there **verbatim**:

```cpp
// src/ExprEmit.cpp ~3129 (pristine)
if (val.rfind("INT:", 0) == 0 && dec.find('\'') != std::string::npos)
    dec = val.substr(4);
```

And the corroboration they cite is real at both sites — `src/ExprEmit.cpp` ~3137
and `src/ParamEmit.cpp` ~12643 both already carry `INT: -> vpiIntConst`. Their
"transcription, not a guess" framing is accurate.

**My extension:** R3 is not limited to `3'd0`. My four `MOVER-PARTIAL` cells show
it also covers a **signed based** member and a **64-bit based** member:

```
80:19  golden dc=1              ours dc=4'sd1              (K0 = 4'sd1)
86:19  golden dc=5000000000     ours dc=64'd5000000000     (N0 = 64'd5000000000)
```

In all four, `vpiConstType` lands on golden and only `VpiDecompile` remains —
which is compared *first*, so R3 is what keeps those cells' heads alive. Worth
folding into R3's statement.

### F16 — the Scoreboard mover is nondeterminism: **proved with the unpatched binary alone**

Their §5.1 point 4, reproduced independently by me. Four runs of the **pristine
7922a457…** binary on identical Scoreboard inputs, same command line:

```
UNPATCHED binary md5: 7922a457a58565ff014f9c440b585eb6
run 1  0b955173a977f5ea0d8af0dbae35455a  size=11146883
run 2  1e7fc54075e42c3e2abbb6a1ef0dcb22  size=11146883
run 3  0b955173a977f5ea0d8af0dbae35455a  size=11146883
run 4  1e7fc54075e42c3e2abbb6a1ef0dcb22  size=11146883
```

**Both** md5s the implementer's byte verifier attributed to "patched" and
"pristine" are outputs the **unpatched** binary produces, alternating, at
identical file size. The row carries **zero** information about this patch —
and in my own sweep it did not move at all (F5). Campaign memory
*emitter-nondeterminism* covers the mechanism.

### F17 — the golden invariant holds at corpus scale (my own scan)

The law rests on an invariant of the **oracle**, so I checked it on golden only,
across the harness's whole golden cache, with my own reader
(`vinv.sh` / `vinv2.sh`, results in `/tmp/v30inv*`):

```
golden databases scanned      : 1,123   (of 3,657 real cache entries, 31%)
golden constants scanned      : 1,874,738
golden (INT:, ct == 7)        : 185,155
golden (INT:, ct != 7)        : 0
INVARIANT VIOLATIONS          : 0
```

plus `Earlgrey_0_1` separately at 136,628 constants and `(INT:,9) = 0` (F7), and
`(INT:, ct≠7) = 0` in all seven arms (F10, F11). I could not scan the full cache
in the time available — the remainder is UVM-scale databases at minutes each, and
16 orphaned `.tmp` staging dirs (7.5 GB of the 12 GB cache) are copies of a single
database — so this is a **sample, not an exhaustive proof**. It is nonetheless
**12× the evidence the implementer offered** (1.87M golden constants vs their
155k, across 1,123 databases they did not look at), and it found **no
counterexample**: the `(INT:, ct≠7)` cell is empty everywhere I looked.

### F18 — canaries all reproduce

```
$ EXPECT_UNKNOWN=6 ctcan2.sh results/gate_uhdm2rtlil.csv /tmp/v30_u2r_patched.csv
    ok=1  changed=0 absent=0 unknown-patterns=6   PASS
$ EXPECT_UNKNOWN=1 ctcan2.sh results/golden_surelog.csv /tmp/v30_sl_patched.csv
    ok=58 changed=0 absent=0 unknown-patterns=1   PASS
$ bash tools/probe/r10uvm52repro/canaries.sh results/gate_uhdm2rtlil.csv /tmp/v30_u2r_patched.csv
    ok=8  changed=0 absent=0 unknown-names=25
$ bash tools/probe/r10uvm52repro/canaries.sh results/golden_surelog.csv /tmp/v30_sl_patched.csv
    ok=52 changed=0 absent=0 unknown-names=7
$ bash tools/probe/r10uvm55repro/canaudit.sh <canaries.sh> <ctcan2.sh>
    audited=29  UNCOVERED=0  FENCE-BREACH=0   PASS
    UnsignedParam / HierPathEval / FileLocalParam / TopParam: not dispatched by any driver (OK)
```

BY NAME on my surelog CSV:

```
InterfaceModPort,default,CMP_EQUAL,,,differ      InterfaceModPort,testflags,CMP_EQUAL,,,differ
BlackParrotComplex,default,CMP_EQUAL,,,differ    BlackParrotComplex,testflags,CMP_EQUAL,,,differ
```

### F19 — patch hygiene: clean

```
$ git apply --check /tmp/r10earl30.patch    (fresh 81b8e0c)  -> clean
$ git apply --stat  /tmp/r10earl30.patch
   src/ExprEmit.cpp                        |  40 ++      <- 1 code line + comment
   src/ModuleEmit.cpp                      |  22 +       <- 1 code line + comment
   tools/probe/r10earl30repro/*            | 1397 ++     <- 12 probe files
   14 files changed, 1459 insertions(+)
$ grep -E "^diff --git" patch | grep -cE " b/(results|scripts|tests)/| b/.*slang/"   -> 0
$ git status --short results/ scripts/ tests/    BEFORE apply -> empty
                                                 AFTER  apply -> empty (0 lines)
```

No `results/`, no `scripts/`, no `tests/`, no slang patching, no harness edit.
`verify_golden.py` and `check_goldens.sh` are untouched. Production change is
**2 executable lines**; the rest of both hunks is comment.

### F20 — no boundary collision

`r10svs4` owns SVSwitch `hier_path` index-presence/element-kind; `r10uvm59` owns
type-parameter-scoped static-call REF_OBJS. The patch touches neither
`hier_path` nor `ref_obj` — both hunks only set `VpiConstType` on a
freshly-minted `constant`. **SVSwitch is byte-unchanged**: it is not in the byte
verifier's mover list (F5), whose only entry is `Earlgrey_0_1/default`.
`SVSwitch` stays `CMP_NOTEQUAL` in both modes, identical to baseline.

### F21 — one reconciled bookkeeping nit (not an error)

Their R2 says golden has "51 constants there and we have 47" on `g6_iface`. Raw
`\_constant:` header counts are golden 51 / ours 47; **unique objects carrying
fields** are 47 / 47. Both readings are right — golden's extra 4 headers are the
**back-references** created by the very object-sharing R2 describes, which is
itself corroboration for R2. No correction needed, but the two numbers count
different things.

---

## WHAT I COULD NOT BREAK

* **A blanket 9→7.** Not what was shipped. The 77,171 `(UINT:,9)` golden
  constants on the target are untouched, exactly (F7).
* **The brief's four-axis model.** I re-tested axis (d) hardest, with nine enum
  base types their `g3_base` never built (F11). Base type still does not
  discriminate: every `INT:`-valued cell reads 7 in golden regardless of width,
  signedness, atom-ness or range-ness. **The brief's model is refuted, and the
  implementer was right to refuse to encode it.** Had they gated on base type,
  F14's unsigned-atom cells would have been forced to 7 on a *value* we know is
  wrong — a guess dressed as a rule.
* **The empty product cells.** 30 built, 15 fired, 15 landed, 0 away (F11).
* **The over-fire direction.** Does not exist at the `enum_const` layer that
  feeds the rule (F12).

---

## RANKED RESIDUES (mine, merged with theirs)

**R1 — `Earlgrey_0_1/default`'s new head: missing `ref_typespec` + wrong span on
a folded package PARAMETER**, `dm_csrs.sv:408:65`. Confirmed by me at cmp depth
17, `RHS: <null>`, and **proved pre-existing** (F8: `408:65` is not among the 12
changed spans). Golden ends col 69, we end col 78. Belongs to the campaign's
*typespec-linkage* cluster. **The next target for this design.** Their ranking is
correct.

**R2 — the *value* of a folded enum member for UNSIGNED INTEGER-ATOM enum bases**
(F14, new). `int/byte/shortint/longint unsigned` members encode `UINT:` for us and
`INT:` for Surelog, so the shipped rule abstains and we keep ct 9 where golden
has 7. 8 measured cells. This is their R5's mechanism on a new, cleanly-delimited
origin class, and it is the **highest-leverage extension of § enumSubstIntConst30**:
fix the value and the const type follows for free. I rank it above their R5
because the class is crisp and the arm already exists (`v7_empty.sv` cells
`60:19`–`69:19`).

**R3 — `§ enumSubstDecBare` at `ExprEmit.cpp` ~5165**, their R3, **widened by F15**
to signed-based (`4'sd1`) and 64-bit based (`64'd5000000000`) members, not only
`3'd0`. The fix is one line already written at `ExprEmit.cpp` ~3129 (quoted in
F15). `VpiDecompile` is compared *before* `vpiConstType`, so this is what holds
those cells' heads open. Deliberately unshipped here — different field,
uncensused reach — and I agree with that call.

**R4 — the interface elab `cont_assign` fold is loc-less and un-shared**
(their R2). Confirmed: golden folds at the written span in the DEF view and
shares one object into elab; we mint a fresh loc-less one per elab view. An
object-COUNT/SPAN law. Corroborated by the back-reference count in F21.

**R5 — their R5**, the value of a folded enum-typed / sized package parameter
(`g2_origin` c6/c7 and `13:33`). 3 cells. Same mechanism as my R2 above.

**R6 — `enum_const` object multiplicity**: 343 duplicate `enum_const` objects
across views on Earlgrey at spans where the encoding agrees exactly (F12). A
per-view duplication residue, invisible to any const-type work.

**R7 — pre-existing shape divergences at folded-enum contexts** (their R4):
extra localparam-initializer constant + span `59:27` vs `59:29`; a `UINT:7`
constant we emit for `logic [p1::E3:0]`; the in-package fold `PKGHIT`. Plus,
from my arm: unbased-unsized members decompile `'b0`/`'b1` in golden vs `'0`/`'1`
in ours, and golden is **self-inconsistent across views** for expression members
(`I1 = PP*2` reads `INT:10 ct=7` in one view, `UINT:10` in another) — a fact any
future pass on expression-valued members must confront before choosing a target.

**R8 — `Scoreboard` per-run output instability** (their R6), re-proved in F16
with the unpatched binary and now pinned to two exact md5s at one file size.
Worth fixing at the source (a stable sort key) so the byte verifier is exact
everywhere.

**R9 — the two patched sites still fall through to `vpiUIntConst` for an
unrecognized prefix** (e.g. a hypothetical `SCAL:`/`REAL:`/`TIME:` enum_const
value), whereas the analogous `ParamEmit.cpp` ~12643 site computes `0` and
**abstains** instead. Pre-existing at both patched sites and unchanged by this
patch; no such prefix occurs on any `enum_const` in the arms or on Earlgrey
(`BIN:/HEX:/INT:/UINT:` only). Recorded so the inconsistency is a choice next
time rather than an accident.

---

## HOUSEKEEPING

Sweep workdirs deleted: `/tmp/v30wd_u2r_patched`, `/tmp/v30wd_u2r_pris`,
`/tmp/v30wd_sl_patched`, `/tmp/v30wd_sl_pris`, `/tmp/v30wd_earl_*`,
`/tmp/v30inv*`, `/tmp/v30sbdet`, `/tmp/v30arm_*`, and my Earlgrey dumps. My two
worktrees are left in place for the integrator; nothing outside them and my own
`/tmp` scratch was written, and `/tmp/claude-1000` was not touched.

New files I added, all under `tools/probe/r10earl30repro/` in **my** worktree
(not in the implementer's deliverable patch):

| file | what it is |
|---|---|
| `vcensus.py` | my **independent** field reader + `(value-prefix, vpiConstType)` cross-tab, explicit open-object stack, own `--selfcheck` |
| `v7_empty.sv` | **the empty-product-cell arm** — 30 cells their grid skipped (F11) |
| `vinv.sh` / `vinv2.sh` | the corpus-scale golden-invariant scan over the harness golden cache (F17) |
| `README.verifier.md` | this report |
