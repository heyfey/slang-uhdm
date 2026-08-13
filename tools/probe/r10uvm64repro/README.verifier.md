# r10uvm64 — ADVERSARIAL VERIFICATION of § blkLocalSameCtrlDepthWindowBinds64

## VERDICT: **PASS**

Every number in the implementer's report reproduces on binaries **I built
myself**, and the two binaries came out **bit-identical to theirs** (`494f6bab…`
patched, `8a7c07f4…` pristine), so their gate numbers were taken on the binaries
they named. The briefed 31-line head is cleared on **all three** target rows,
the five gates are green, § blockLocalSameCtrlDepthArgBinds57's and
r10uvm63's arms hold, and the patch is **STATED GATE == CODE GATE**: one
disjunct and nothing else.

I built **three new arms** (`v1_prod.sv`, `v2_ctx.sv`, `v3_loopwin.sv`, 322
cells) specifically to hunt the **empty product cells** the implementer's arms
leave open — the block-shape × initialiser × var-kind product, and the whole
subroutine/window context axis. **The law survives all of them**: 67 further
cells move `bare → BIND` and golden is `BIND` on every one, **zero** cells move
the wrong way, and the `while`-is-not-a-window discriminator generalises to
`do-while`, `repeat`, `foreach` and the `for` header.

I found **three residues no arm in this pass measured** (all **pre-existing**,
all identical on the pristine binary, none caused or worsened by the patch) and
**two reporting slips** in the README's residue section. **No code defect.**

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)`.

---

## 0. BASE, BINARIES, AND WHAT I RE-BUILT

`auto5h` is still at **957974d** — no landing intervened, so I verified at the
briefed base, which is also where this patch lands.

```
git rev-parse HEAD (main tree)      -> 957974dabc7aacfb75ce00295ef363f70b189be0
git -C /tmp/wt_v64     rev-parse HEAD -> 957974dabc7aacfb75ce00295ef363f70b189be0
git -C /tmp/wt_v64pris rev-parse HEAD -> 957974dabc7aacfb75ce00295ef363f70b189be0
git apply --check -v /tmp/r10uvm64.patch  -> rc=0   ;  git apply -> rc=0
md5 /tmp/r10uvm64.patch = 21027ad1fdfaa86e6c31ab22e923b934   (2192 lines)
```

| tree | what | md5 of `build/slang-uhdm` |
|---|---|---|
| `/tmp/wt_v64` | patch applied, configured + built by me | **`494f6babd956ea73f323c1da7b3eda31`** |
| `/tmp/wt_v64pris` | pristine 957974d control, built by me | **`8a7c07f418d3a567de0b24c6a5e90fe3`** |
| implementer's `/tmp/wt_r10uvm64/build` | re-hashed by me | `494f6babd956ea73f323c1da7b3eda31` ✓ |
| implementer's `/tmp/wt_r10uvm64pris/build` | re-hashed by me | `8a7c07f418d3a567de0b24c6a5e90fe3` ✓ |
| `~/git-repos/slang-uhdm/build/slang-uhdm` (main tree) | — | `8a7c07f418d3a567de0b24c6a5e90fe3` |

The build is **reproducible to the byte** here: my independent configure+build of
the same source produced the same two md5s. The main tree's binary is itself a
pristine 957974d build, which is a third confirmation of base integrity.

Link lines were waited for and read; **0 `error:`** in both logs; both md5s
asserted in their own command and both 32 hex digits.

```
grep -cE 'error:' /tmp/v64_build_p.log /tmp/v64_build_c.log      -> 0 , 0
grep 'Linking CXX executable slang-uhdm' both logs               -> [100%] present
grep 'Built target slang_uhdm$'          both logs               -> [100%] present
```

**ONE OPS TRAP I HIT AND FIXED, AND EVERY FUTURE VERIFIER SHOULD KNOW IT.**
`scripts/verify_golden.py` line 53 defaults `SLANG_UHDM` to
`~/git-repos/slang-uhdm/build/slang-uhdm` — the **MAIN TREE** binary — *not* to
the tree the sweep is launched from. My first two sweep launches (from inside the
worktrees, without the env var) were therefore both measuring the **main tree**
binary. I killed them, deleted their workdirs and relaunched all four sweeps with
`SLANG_UHDM=<absolute path>` **printed at launch**. Had I not, "0 movers" would
have been guaranteed and meaningless.

---

## 1. PATCH HYGIENE AND THE GATE ITSELF

`git apply --numstat`: **20 files, +2037 / −17**.

* Production: **`include/UhdmExporter.h`** (+16/−4, comment only) and
  **`src/ExprEmit.cpp`** (+55/−13, one live line plus comments).
* 18 files under `tools/probe/r10uvm64repro/` and nothing else:
  `git apply --numstat | grep -v '^(include/UhdmExporter.h|src/ExprEmit.cpp|tools/probe/r10uvm64repro/)'`
  → **NONE**.
* `results/` untouched in the patch and in both worktrees
  (`git status --porcelain results/` empty).
* `git stash list` has two entries, both dated **2026-07-24** on `eb225cd waves
  33-35`, weeks before this base. **Not attributable to r10uvm64.**

### STATED GATE == CODE GATE — read off my own worktree

```c
bool blkLocalWindowBind64 =
    (classArgBindDepth12 > 0 || !classMethodNoBind) &&
    blkLocalSameCtrlDepth57(nv.symbol);
bool ctrlBodyNoBind28 = curSubClassScope9 && !curSubOob9 &&
                        ctrlBodyDepth28 > 0 &&
                        !blkLocalWindowBind64;
```

The **only** semantic change in the whole patch is `classArgBindDepth12 > 0` →
`(classArgBindDepth12 > 0 || !classMethodNoBind)`. No var-kind term, no
initialiser term, no block-shape term, no name term, no new member, no new
counter. `blkLocalSameCtrlDepth57` (ExprEmit.cpp:239) is **not inside any hunk**:
declared once (`UhdmExporter.h:3194`), defined once (`ExprEmit.cpp:239`), called
from exactly one site (`ExprEmit.cpp:7254`).

### THE MECHANICAL ARGUMENT, CHECKED RATHER THAN ACCEPTED

The claim "`!classMethodNoBind` *is* the condition window" is only sound if
`classMethodNoBind` cannot be false for any *other* reason inside this branch. I
read every assignment:

```
grep -rn 'classMethodNoBind = false' src/   -> StmtEmit.cpp:2305 (if_else cond)
                                               StmtEmit.cpp:2325 (if_stmt cond)
                                               StmtEmit.cpp:2599 (case  cond)
                                               all three: "// condition refs DO bind"
TaskFuncEmit.cpp:5087  classMethodNoBind = classScope && !oob;   (set)
TaskFuncEmit.cpp:5243  classMethodNoBind = savedCMNB;             (restored)
TaskFuncEmit.cpp:5093-4 curSubClassScope9 = classScope; curSubOob9 = oob;  (SAME SITE)
TaskFuncEmit.cpp:5244-5 restored at the SAME SITE
```

`classMethodNoBind` and `curSubClassScope9`/`curSubOob9` are set and restored at
**the same two lines** of the same function, from the same two operands. So
inside the `curSubClassScope9 && !curSubOob9` branch, `classMethodNoBind` is true
**by construction** unless one of the three condition sites cleared it —
including the member's `= false` initialiser, which cannot be reached with
`curSubClassScope9` true. The three dangerous look-alikes are all excluded by a
*different* term of the same predicate: an **out-of-body** method
(`classMethodNoBind` false for its whole body) is excluded by `!curSubOob9`; a
**`$unit`** function and a **module/package** function (also false throughout)
are excluded by `curSubClassScope9`. `b2_modtwin.sv` measures exactly those three
and does not move a single cell — I re-ran it and the dumps are **byte-identical**
between the two binaries (only the workdir path differs).

`casex` / `casez` / `case … inside` all flow through the one patched case
handler (`StmtEmit.cpp:2570-2601` sets `VpiCaseType` and then clears
`classMethodNoBind` once), so they are windows too — measured in §3 below, not
assumed.

---

## 2. THE HEAD — THE BRIEF WAS WRONG AND THE IMPLEMENTER WAS RIGHT

I censused **both** sides before accepting any missing-object claim, as the
standing law requires.

```
grep -c 'integer_var: (uvm_pkg::uvm_recorder::get_handle::handle)'
  golden  /tmp/v64_sb_g.dump -> 4          ours PRISTINE -> 3      ours PATCHED -> 4
```

Our **pristine** dump carries that `integer_var` at 807677 with `vpiParent
assignment @343:18-343:40`, its `ref_typespec`, its `vpiActual →
integer_typespec @343:10`, its `vpiName`/`vpiFullName`/`vpiSigned:1` — the same
fields golden has at 813964. **The brief's "we emit NO object for this local" and
"the whole integer_var IS absent from our dump" are FALSE.** Golden's *fourth*
occurrence (813:…44) is the back-reference under `ref_obj @346:75`'s
`vpiActual`; ours PATCHED now has it, byte for byte:

```
ours patched 807805  \_ref_obj: (…::get_handle::handle), line:346:75, endln:346:81
             807810    |vpiActual:
             807811    \_integer_var: (…::get_handle::handle), line:343:18, endln:343:24
```

**The brief's suspected bail is also FALSE.** I re-ran the emitter on the
Scoreboard argv and read its own note list first:

```
slang-uhdm: unsupported constructs encountered:
  expression kind: UnboundedLiteral
  system method call: size
grep -nE '343|get_handle' <emitter stderr>   -> nothing
```

The other three uses of `handle` stay bare on both sides after the patch
(349:28, 350:36, 352:17: `vpiActual` count 0 in golden **and** 0 in ours).

### THE HEAD IS CLEARED ON ALL THREE TARGET ROWS

`rowheads.sh`, my own two sweeps:

| row | pristine cmp lines | patched | new head |
|---|---|---|---|
| SimpleUVM / default | **31** (1 head) | **13** | `begin (uvm_pkg::uvm_recorder::do_open) @547:18-547:25`, RHS `<null>` |
| SimpleUVM / testflags | **31** | **13** | same |
| Scoreboard / default | **31** | **13** | same |
| Scoreboard / testflags | SKIP-NOFILE (SLANG_REJECT, no database) | — | reported, not hidden |
| SeqDriver / both | 85 | **85** | unchanged (`class_typespec (adpcm_pkg::type_id)`) — moved bytes, not its head |
| SVSwitch / both | 2680 | **2680** | unchanged |

---

## 3. EMPTY PRODUCT CELLS — MY THREE NEW ARMS

The implementer's `b3_kinds.sv` walks three axes **one at a time**: the 9 var
kinds only as `if`-begin + literal initialiser, the 4 initialisers only as `int`
+ `if`-begin, the shapes only as `int` + literal. The **product was never
opened**, and neither was the subroutine/window context axis. Both are exactly
where a "no term on this axis" claim goes wrong unseen.

### `v1_prod.sv` — BLOCK SHAPE × INITIALISER × VAR KIND, 48 product cells

3 shapes (`if`-begin, `else`-begin, plain `begin` nested inside an `if`-begin,
all at `ctrlBodyDepth28 == 1`) × 4 initialisers (none / literal / **CALL** /
operation) × 4 kinds (`int`, `string`, class handle, `logic[7:0]`), each read in
an `if` CONDITION at depth 1.

```
pristine: cells=161 same=113 DIFFER=48   (all 48 product cells golden BIND, ours bare)
patched : cells=161 same=161 DIFFER=0
```

**All 48 interaction cells: golden BIND, patched BIND.** No axis and no
interaction of axes carries a term. The claim is now supported at the product,
not just on the margins.

### `v2_ctx.sv` — THE CONTEXT AXIS (107 cells)

| cell | context | GOLDEN | pristine | patched |
|---|---|---|---|---|
| t01 | class **TASK** condition, d1 | BIND | bare | **BIND** |
| w01 | depth **2 == 2** condition | BIND | bare | **BIND** |
| x01/x02/x03 | **casex** / **casez** / **case-inside** condition | BIND | bare | **BIND** |
| f01/f02 | cond in if-begin, and a **fork block** local's cond | BIND | bare | **BIND** |
| s01 | **`static`** block-local in a cond | BIND | bare | **BIND** |
| n01 | condition inside the **constructor `new`** | BIND | bare | **BIND** |
| y01 | **virtual** method condition | BIND | bare | **BIND** |
| z01 | **static** class method condition | BIND | bare | **BIND** |
| q01 | class declared in a **PACKAGE** (the corpus shape) | BIND | bare | **BIND** |
| r01 | class declared in a **MODULE** | BIND | bare | **BIND** |
| k01/k02/k03 | **do-while** cond / **repeat** count / **foreach** body | bare | bare | bare |
| **j01** | **CASE-ITEM expression**, d1 | **BIND** | bare | **bare** ← new residue V1 |
| **a01** | immediate **`assert`** condition, d1 | **BIND** | bare | **bare** ← new residue V2 |
| **nfarg** | body local in **`new`**'s condition at **depth 0** | **bare** | **BIND** | **BIND** ← new residue V3 |

```
pristine: cells=107 same=91  DIFFER=16
patched : cells=107 same=104 DIFFER=3      (13 cleared, 0 new, all 3 pre-existing)
```

### `v3_loopwin.sv` — WINDOWS INSIDE LOOP BODIES, AND THE HEADER POSITIONS (54 cells)

| cell | context | GOLDEN | pristine | patched |
|---|---|---|---|---|
| L01/L02 | local declared in a **`while` body**, read in an if / case cond there (d1==1) | BIND | bare | **BIND** |
| M01 | local declared in a **`for` body**, read in an if cond there | BIND | bare | **BIND** |
| Q01/Q02 | **`unique case`** / **`priority if`** condition | BIND | bare | **BIND** |
| E01 | leading `if` of an if/else-if chain | BIND | bare | **BIND** |
| E02 | the **`else if`** condition (depth becomes 2) | bare | bare | bare |
| H01/H02 | block-local in a **`for` HEADER** (cond and init) | bare | bare | bare |

```
pristine: cells=54 same=48 DIFFER=6   ->   patched: cells=54 same=54 DIFFER=0
```

**The `while`-is-not-a-window discriminator is not a one-cell fluke**: every
control statement that does not clear `classMethodNoBind` — `while`, `do-while`,
`repeat`, `foreach`, and the `for` header — is golden **bare** and stays bare.
The gate gets six more of these right for the mechanical reason, not by luck.

**Across my three arms: 322 cells, 70 DIFFER pristine → 3 DIFFER patched. 67
cells cleared, every one golden-BIND, 0 cells moved against golden, 0 new
DIFFERs.**

---

## 4. THE IMPLEMENTER'S OWN GRID, REPRODUCED CELL FOR CELL

```
b1_cond     pristine cells=66 same=59 DIFFER=7  ->  patched same=65 DIFFER=1
b2_modtwin  pristine cells=41 same=32 DIFFER=9  ->  patched same=32 DIFFER=9  (dumps byte-identical)
b3_kinds    pristine cells=48 same=33 DIFFER=15 ->  patched same=48 DIFFER=0
```

The six b1 cells that clear are exactly c01 40:11, c14 61:13, c12 64:13, c30
102:11, c31 103:16, c36 108:11; the one that remains is c08 82:11
(`c08_nmdblk`, golden bare / ours BIND) — residue R1, unchanged by the patch.
`b3_kinds` reaches 48/48. `b2_modtwin` does not move.

### § blockLocalSameCtrlDepthArgBinds57's arms — HOLD, and one IMPROVES

`r10uvm57repro/arm.sh` + `cells.py`, 13 arms, both binaries:

| arm | pristine | patched |
|---|---|---|
| b1_argctrl | 0/57 | 0/57 |
| b2_shape | 0/58 | 0/58 |
| **b3_bound** | **1/50** | **0/50** ← one UNDERBIND fixed (`pb3::shp::f::cndv` 56:13, golden B, ours b→B) |
| b4_open | 2/66 | 2/66 (cell table **identical**) |
| b5_pos | 0/46 | 0/46 |
| a1/a2/a4/a7/a8 | 0 | 0 |
| v1_prodcell | 2/81 | 2/81 (cell table **identical**) |
| v2_loopvar, v3_exprsib | 0 | 0 |

§57's arms are strictly improved or unchanged. **The README says "§57's own cell
list is unchanged"; in fact one §57 arm cell moves `bare → BIND` correctly** —
which *supports* the widening, and is worth recording rather than glossing.

### r10uvm63 (§ assocIndexTsSigned63) — HOLDS, byte for byte

All five arms, path-normalised dumps, pristine vs patched:

```
b1_idxkind b2_modtwin b3_named b4_scope b5_sublocal
  differing dump lines = 0   0   0   0   0
```

The r10uvm63 verifier's own in-tree arm `b5_sublocal.sv` (the TaskFuncEmit
subroutine-local / formal writers) is **untouched**. No collision.

---

## 5. THE FIVE GATES, RUN BY ME

### GATE 1 — BUILD
`/tmp/wt_v64/build` (absolute), link line read, 0 errors, both md5s 32-hex and
asserted separately, both worktrees at 957974d. See §0.

### GATE 2 — GOLDENS
```
SLANG_UHDM=/tmp/wt_v64/build/slang-uhdm ./tests/check_goldens.sh   rc=0  PASS=23 FAIL=0
SLANG_UHDM=/bin/false                    ./tests/check_goldens.sh   rc=1  PASS=0  FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own out/workdir
```
patched : 679 CMP_EQUAL  50 SLANG_REJECT  2 SURELOG_FAIL ; dump 496 match/183 differ/52 blank
pristine: identical
ct8rows.sh results/gate_uhdm2rtlil.csv <fresh>  -> 0 differing ROWS (0 diff row-sides)  BOTH sweeps
732 lines = 731 ROWS both sides
```

### GATE 4 — surelog, `--mode both --jobs 2`, `GOLDEN_DEFER` echoed `[UNSET]`
```
default   467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags 463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
          3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
dump default 225 match/242 differ/327 blank ; testflags 165/298/331   — histograms UNCHANGED
ct8rows.sh results/golden_surelog.csv <fresh>  -> 0 differing ROWS   BOTH sweeps
1589 lines = 1588 ROWS both sides
```

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs MY OWN pristine 957974d
```
uhdm2rtlil : PATH_SETS_IDENTICAL (679)  MOVERS 0/679   SELFCHECK 678/679   SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953)  MOVERS 7/953   SELFCHECK 952/953   SELFCHECK1 = 8
```
The 7 movers are exactly
`default/{BuildUVMPkg,Scoreboard,SeqDriver,SimpleUVM}` +
`testflags/{BuildUVMPkg,SeqDriver,SimpleUVM}`, and `BuildUVMPkg`'s two modes
share the patched database bytes (`e1d3438bffe4` in both) — as reported.

### CENSUS — the pre-patch prediction, re-run by me on MY pristine sweeps

Arm control first (a scanner that finds nothing where the grid moves is
measuring nothing):

```
b1_cond 41->35 delta 6   (grid moved 6)     v1_prod 148->100 delta 48  (grid 48)
b3_kinds 35->20 delta 15 (grid moved 15)    v2_ctx   64->51 delta 13  (grid 13)
b2_modtwin 9->9 delta 0  (grid moved 0)     v3_loopwin 33->27 delta 6 (grid 6)
```

```
uhdm2rtlil: 679 databases, NO_DUMP=0,  5 CANDIDATE rows  -> rp32_r5p_{alu,bru,mdu,wbu} (45 each), rsp_gen_minimal (3)
surelog   : 953 databases, NO_DUMP=0, 22 CANDIDATE rows  -> counts 8447/7849/7835/6268/119/118/39/8/8/8/8/4/2/2/2/2/2/1
```
Identical to the implementer's list, count for count. **The 7 actual movers are
a subset of the 22, and the u2r half predicted 0 movers and got 0.**

### CANARIES
```
canaudit.sh canaries.sh ctcan2.sh   audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
ctcan2.sh  u2r      EXPECT_UNKNOWN=6  ok=1   changed=0 absent=0 unknown=6  PASS
ctcan2.sh  surelog  EXPECT_UNKNOWN=1  ok=58  changed=0 absent=0 unknown=1  PASS
canaries.sh u2r      ok=8   changed=0 absent=0 unknown-names=25
canaries.sh surelog  ok=52  changed=0 absent=0 unknown-names=7
InterfaceModPort    base==fresh  default CMP_EQUAL/differ   testflags CMP_EQUAL/differ
BlackParrotComplex  base==fresh  default CMP_EQUAL/differ   testflags CMP_EQUAL/differ
SimpleUVM/SeqDriver/BuildUVMPkg/SVSwitch base==fresh (CMP_NOTEQUAL both modes)
Scoreboard          base==fresh  default CMP_NOTEQUAL  testflags SLANG_REJECT
```
The four slang-fenced names were never dispatched (FENCE-BREACH=0).

### DETERMINISM, AND THE Scoreboard/default FLAKE — 3 REPS EACH BINARY
```
detcheck.sh <patched> 3 : b1_cond, b3_kinds, v1_prod, v2_ctx, v3_loopwin
                          distinct hashes = 1 each, NO_OUTPUT = 0
Scoreboard/default, same argv, same cwd, 3 reps each:
  PRISTINE 8a7c07f4  0735c667 / 1ba839e9 / 1ba839e9   distinct=2   bytes 11133449 (all 3)
  PATCHED  494f6bab  31586294 / 1aa19acb / 31586294   distinct=2   bytes 11133994 (all 3)
```
**I reproduce the flake on BOTH binaries** (the implementer saw 3 hashes pristine
and 1 patched; I see 2 and 2 — the flake is multi-stable, so rep-to-rep hash
counts are not a signal). What matters holds exactly: the **byte SIZE is stable
within each binary** and matches the implementer's two sizes to the byte,
**+545** patched. The Scoreboard mover attribution stands on the size, not the
hash, and my patched md5 `31586294781f` is the same one the byte verifier flagged.

---

## 6. THE MOVERS, PER SHAPE, BY MULTISET — ALL SEVEN, ALL REPRODUCED

`mv64.sh`, LHS always golden, `sed 1d` both sides, ADDED/REMOVED never netted:

| row | dist pristine | dist patched | gain | ADDED | REMOVED |
|---|---|---|---|---|---|
| default/SimpleUVM | 144517 | 144463 | +54 | 116 | **0** |
| testflags/SimpleUVM | 144513 | 144459 | +54 | 116 | **0** |
| default/Scoreboard | 134810 | 134770 | +40 | 116 | **0** |
| default/SeqDriver | 367715 | 367603 | +112 | 116 | **0** |
| testflags/SeqDriver | 367715 | 367603 | +112 | 116 | **0** |
| default/BuildUVMPkg | 81215 | 81115 | +100 | 118 | **0** |
| testflags/BuildUVMPkg | 81215 | 81115 | +100 | 118 | **0** |

Every figure identical to the report. The **sign** of the distance is data, not a
verdict; the gain is positive on all seven anyway.

**ADDED shapes, aggregated by kind, with a residual bucket the report did not
print** (my `/tmp/v64shapes.sh`):

| row | `\|vpiActual:` | class_var | enum_var | bit_var | int_var | string_var | ref_var | integer_var | **other shapes** |
|---|---|---|---|---|---|---|---|---|---|
| default/SimpleUVM | 58 | 26 | 8 | 8 | 6 | 5 | 3 | 2 | **0** |
| default/Scoreboard | 58 | 26 | 8 | 8 | 6 | 5 | 3 | 2 | **0** |
| default/SeqDriver | 58 | 26 | 8 | 8 | 6 | 5 | 3 | 2 | **0** |
| default/BuildUVMPkg | 59 | 20 | 7 | 13 | 11 | 6 | 2 | – | **0** |
| testflags/{SimpleUVM,SeqDriver} | 58 | | | | | | | | **0** |
| testflags/BuildUVMPkg | 59 | | | | | | | | **0** |

`58+58+58+58+58+59+59 = ` **408 shipped `vpiActual` edges**, and the
"other shapes" column being **0** on every row is an independent proof that the
patch's dump footprint is *exactly* the field plus the header of its target —
nothing re-parented, nothing renamed, nothing minted.

### THE ONE ADDED LINE WHOSE GOLDEN COUNT IS ZERO — RUN DOWN, NOT WAVED THROUGH

`mv64.sh`'s three-way column shows one added text with `golden=0`:
`\_bit_var: (uvm_pkg::uvm_reg_mem_hdl_paths_seq::check_reg::d), line:137:32`.
On its face that is an over-bind. It is not:

```
golden 986521  \_ref_obj: (…check_reg::d), line:138:38   |vpiParent: \_func_call: (uvm_hdl_read)
               |vpiActual: -> \_bit_var: (…check_reg::d) 137:32     [24-space indent]
ours   979705  \_ref_obj: (…check_reg::d), line:138:38   |vpiParent: \_operation:
               |vpiActual: -> \_bit_var: (…check_reg::d) 137:32     [26-space indent]
```

Golden has the **same edge**; our `ref_obj` sits under a different **parent**
(`operation` vs `func_call`) and therefore at a different indent, and the
multiset key preserves indentation, so the text differs. A **pre-existing
parent-shape residue**, not a wrong binding — and the per-cell audit, which keys
on (name, span), calls it `BIND` on both sides.

### WHOLE-DESIGN PER-CELL AUDIT, MY OWN INSTRUMENT

`/tmp/v64audit.py` re-uses `ct64cells.py`'s scanner with `NAMEKEY=1` and joins
**golden / pristine / patched** on one key:

| design | keys only in pristine | only in patched | cells MOVED | direction | golden agrees | golden DISAGREES |
|---|---|---|---|---|---|---|
| default/SimpleUVM | **0** | **0** | **58** | all bare→BIND | **58** | **0** |
| default/Scoreboard | **0** | **0** | **58** | all bare→BIND | **58** | **0** |
| default/SeqDriver | **0** | **0** | **58** | all bare→BIND | **58** | **0** |
| default/BuildUVMPkg | **0** | **0** | **59** | all bare→BIND | **59** | **0** |

**233 binding decisions changed across four designs, 233 of them right, 0 keys
gained or lost, 0 BIND→bare.** Whole-design DIFFER vs golden falls
147→**89** (SimpleUVM), 125→**67** (Scoreboard), 243→**185** (SeqDriver),
143→**84** (BuildUVMPkg). The report's SimpleUVM figures — **89 DIFFER = 48
over + 41 under**, **5681 UNMEASURED** — reproduce to the unit on my
independently written joiner.

---

## 7. FINDINGS

Numbered, each with the command that produced it. **None is a code defect.**

**F1 (reporting slip, README §6 R3).** The out-of-body residue is stated as
"**two** cells" ("we bind all four"). The arm actually shows **7 DIFFER cells**
inside `b2c::o1` — 59:26, 60:5, 60:9, 61:9, 61:23, 62:20, 64:10, all golden
**bare** and ours **BIND** — which is also what the README's own arm total (9 =
2 in `u1` + 7 in `o1`) implies. The residue is bigger than R3 claims.
`python3 ct64cells.py /tmp/v64arm_p_b2_modtwin/{g,o}.dump | grep DIFFER`

**F2 (reporting slip, README §6 R4).** "5 cells on arm b2" of out-of-body ref
naming: the instrument prints **NAME-DIFFERS=10** (`o1.r` ×5, `o1.farg`,
`o1.o01_blkloc` ×2, `o1.bodyloc`, `o1.prop`). Same command as F1.

**F3 (new residue V1, under-bind).** A **CASE-ITEM expression** is a window in
golden and not in us: `case (farg) j01_blkloc: …` at depth 1 — golden **BIND**,
we are **bare** (pristine and patched alike). `StmtEmit.cpp:2599` restores
`classMethodNoBind` immediately after the case *condition*, so the item
expressions are emitted with the silence back in force.
`ct64arm.sh v2_ctx.sv` → cell `j01 92:9`.

**F4 (new residue V2, under-bind).** An **immediate `assert` condition** is a
window in golden and not in us: `assert (a01_blkloc == 3) …` at depth 1 — golden
**BIND**, we are **bare**. There is no `classMethodNoBind = false` on the
assertion path. Same arm, cell `a01 133:15`.

**F5 (new residue V3, over-bind).** In the **constructor `new`**, a
**method-body local** read in a **depth-0** condition is golden **bare** while
the identical cell in an ordinary method (b1 c06 `bodyloc` 79:9) is golden
**BIND**. We BIND both. So `new` is its own scope axis for §28's neighbourhood.
Same arm, cell `nfarg 142:9` vs `b1_cond` cell `79:9`.

**F6 (number I could not reproduce; not load-bearing).** README §2's
"shared keys **25818 / 25879 / 26088 / 27857**" do not reproduce: my joiner
reports **26286 / 26362 / 36887 / 26109** shared `ref_obj` keys for the same four
designs. Every *load-bearing* column of that table — 58/58/58/59 moved, 0 keys
added or lost, golden agreeing on all of them — reproduces exactly, as do the
report's SimpleUVM DIFFER (89 = 48+41) and UNMEASURED (5681) figures. The most
likely cause is that their join keyed on the table's **printed short name**
(`ct64cells.py` prints `name.split('::')[-1]`) rather than the full name, which
merges keys; the count is a denominator, not a finding.

**F7 (ops hazard, not the patch).** `verify_golden.py` silently defaults
`SLANG_UHDM` to the **main-tree** binary. Any sweep launched from a worktree
without the env var measures the wrong build. See §0. The implementer's numbers
are unaffected — I reproduced all of them with explicit paths — but this is the
cheapest possible way for a future pass to report a false "0 movers".

---

## 8. RANKED RESIDUES (mine, after the patch)

1. **R1 / F5 — DEPTH-0 over-binds are now the top of this family.** Two
   measured shapes: a **NAMED**-block local in a condition at depth 0 (b1 c08,
   golden bare / ours BIND) and a **constructor body local** in a condition at
   depth 0 (v2 `nfarg`, golden bare / ours BIND). Both DELETE-direction, both
   outside §28/§57/§64, and the named/unnamed discriminator at depth 0 is
   already visible in the same arm (c11 unnamed is golden BIND). Best next head.
2. **F3 / F4 — the window set is still incomplete on the ADD side**: CASE-ITEM
   expressions and immediate-`assert` conditions are golden windows we do not
   open. Both are one-line `classMethodNoBind` clears in `StmtEmit.cpp` in
   principle — but each needs its own arm and its own corpus census first,
   because "any condition-looking position" is exactly the over-fire §64's
   `while` cell refutes.
3. **R2 — `$unit` function has no condition carve-out at all**
   (§ unitSubNoBind9): 2 cells on b2 `u1` (23:7 depth 0, 28:9 depth 1). The
   depth-1 half is §64's exact shape; the depth-0 half is not, so it is its own
   head.
4. **F1 — out-of-body method over-binds 7 cells** on a `$unit`-scope class
   (bigger than R3 states).
5. **F2 / R4 — out-of-body ref naming** (`o1.farg` vs `farg`), 10 NAME-DIFFERS
   on the arm.
6. **R5 — the new head on all three target rows**: an empty
   `begin (uvm_pkg::uvm_recorder::do_open) @547:18-547:25` golden emits and we
   do not. Reproduced; a different law.
7. **R6 — the whole-design remainder**: SimpleUVM/default 89 DIFFER (48 over /
   41 under) and 5681 UNMEASURED object-identity spans; Scoreboard 67, BuildUVMPkg
   84, SeqDriver 185. Not decomposed, and the report does not claim R1–R4 account
   for them. Also **one pre-existing parent-shape residue** named concretely by
   §6 above: our `ref_obj @138:38` parents at an `operation` where golden parents
   at the `func_call`.

---

## 9. FILES I ADDED

| file | what it is |
|---|---|
| `v1_prod.sv` | the **product** arm: block shape × initialiser × var kind, 48 interaction cells in the condition window |
| `v2_ctx.sv` | the **context** arm: task, depth 2==2, casex/casez/case-inside, case-item, do-while/repeat/foreach, fork, assert, static local, `new`, virtual, static method, package-scope and module-scope classes |
| `v3_loopwin.sv` | windows nested in **loop bodies**, the `for`-HEADER positions, `else if`, `unique case`, `priority if` |
| `README.verifier.md` | this record |

Sweep workdirs (`/tmp/v64_wd_*`), arm scratch (`/tmp/v64arm_*`, `/tmp/v57_*`,
`/tmp/v63_*`) and the big dumps were deleted after measurement.
`/tmp/claude-1000` untouched; slang not patched; `results/*.csv` only ever read.
