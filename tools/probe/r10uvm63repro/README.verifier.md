# r10uvm63 — ADVERSARIAL VERIFICATION of § assocIndexTsSigned63

## VERDICT: **PASS**

Every number in the implementer's report reproduces on binaries I built myself.
The briefed head is cleared on all three target rows, the five gates are green,
the sibling laws hold, and no collision exists with the live passes. I found
**two reporting slips and two evidence gaps**, all of which I closed by
measurement; **none is a code defect**, and none changes the verdict.

**The one substantive gap: the patch shipped two call sites that no arm
measured** (`src/TaskFuncEmit.cpp:1280` and `:2232`, the subroutine-local and
formal-argument writers), on the *one axis where the sibling signedness law is
already known to invert*. I built the missing arm (`b5_sublocal.sv`) and
measured it: **golden's policy there is identical, and the patch is exactly
right on all 12 cells** — 12 `vpiSigned:1` added, 12 that golden also has, 0
that golden lacks. The claim was correct; it was merely unsupported. It is
supported now.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)`.

---

## 0. WHICH BASE I VERIFIED AT, AND WHY

**`auto5h` had advanced to `2ee7a58` (r10svs9 landed) before I started.** The
implementer measured at `40a7068` and reported a rebase-check. I did not take
that on trust and I did not verify at the stale base: **I verified at the
current head `2ee7a58`**, which is where this patch will actually land.

```
git rev-parse HEAD                     -> 2ee7a58e8baa07d589428d4b6239afb5d84f379a
git apply --check -v /tmp/r10uvm63.patch  -> rc=0   (applies clean to CURRENT head)
```

Consequence to read carefully: **my absolute distances differ from the
implementer's, and they should.** r10svs9 moved the same seven UVM databases,
so e.g. `default/SimpleUVM` multiset distance is `144521` for me and `144529`
for them. **The deltas that carry the finding are identical** — same gain, same
ADDED count, same shape, on every row. That agreement across two different
bases is stronger evidence than a match at one base.

My worktrees (both at `2ee7a58`, pristine one `git status` CLEAN):

| tree | branch | md5 of `build/slang-uhdm` |
|---|---|---|
| `/tmp/wt_v63` (patched) | `v63wt` | **`e4314e391fcb436653a69953a12d821b`** |
| `/tmp/wt_v63pris` (control) | detached | **`875d3cd6218c135a8fcc6da3c4c3cf19`** |

I also re-hashed the implementer's own binaries; **both reproduce their claimed
values exactly**, so their gate numbers were taken on the binaries they said:

```
0d39f5e53e66646aa39ecede4b3f4baa  /tmp/wt_r10uvm63/build/slang-uhdm      (claimed FINAL)
2372ca526cf1e50195a17b0e44288b61  /tmp/wt_r10uvm63pris/build/slang-uhdm  (claimed PRISTINE)
```

---

## 1. PATCH HYGIENE

`git apply --numstat`: **23 files, +2168 / -29**.

* **4 production files** — `include/UhdmExporter.h`, `src/ParamEmit.cpp`,
  `src/TypeEmit.cpp`, `src/UhdmExporter.cpp`.
* **19 files under `tools/probe/r10uvm63repro/` only.**
* **Nothing outside scope.** No `results/*.csv` touched, in the patch or in
  either worktree (`git status --porcelain results/` empty in both, and in the
  main tree).
* **`git stash` not used by this pass.** Two stash entries exist in the repo,
  but they are dated **2026-07-24** and reference `eb225cd waves 33-35` —
  three weeks before this pass's base commits (both dated 2026-08-12). Not
  attributable to r10uvm63.
* Patch md5 **`a5cf806cc1957dba01a9edbfd14dd2a4`** — reproduced.

### STATED GATE == CODE GATE — read off my worktree, not the report

```c
UHDM::typespec* UhdmExporter::assocIndexSignedAtom63(const Type& ic,
                                                     UHDM::typespec* ts) {
    if (!ts || !ic.isSigned())
        return ts;
    switch (ts->UhdmType()) { /* int, integer, short_int, long_int, byte */ }
    return ts;
}
```

No scope test, no view test, no typedef test, no `time` case, no name test —
as stated. **Three call sites**, and I checked the gate's operand at each:

| site | file | operand | canonical? |
|---|---|---|---|
| `assocIndexTs` | `UhdmExporter.cpp:1794` | `ic` | `idx.getCanonicalType()` ✓ |
| § assocIdxSiteFour43 | `TypeEmit.cpp:14930` | `ick` | `dims[0].indexType->getCanonicalType()` ✓ |
| § assocIdxSiteFive44 | `ParamEmit.cpp:20533` | `ick` | `idx->getCanonicalType()` ✓ |

All three gate on the **canonical** index type, so the predicate is the same
predicate at every site — the report's claim, verified rather than assumed.

### THE ALIASING QUESTION THE REPORT DID NOT ASK, AND ITS ANSWER

The one way this patch could have been quietly catastrophic is if
`predefIntTypespec` returned a **shared or cached** object: stamping
`VpiSigned` on a shared typespec would leak signedness into every other
position that points at it, and the corpus might not exercise the leak. I read
it (`src/ParamEmit.cpp:2108`):

```c
case PredefinedIntegerType::Integer: ts = s.MakeInteger_typespec(); break;
```

**It mints a FRESH object on every call.** There is no registry, no cache, no
reuse. The stamp cannot escape the object the caller just received. Separately,
the typedef/shared-alias path (`sharedAliasTs` / § arrayElemTdClone42) returns
*above* the `PredefinedIntegerType` arm in `assocIndexTs`, so a registry-shared
alias is never reached by the new code — which is also what
§ sharedAliasNoStamp41 (`TaskFuncEmit.cpp`) demands of any stamp on this path.
**ADD-ONLY is structurally sound, not just empirically observed.**

### THE FOURTH `predefIntTypespec` SITE IS CORRECTLY UNTOUCHED

`grep -rn 'predefIntTypespec(' src/ include/` gives 7 hits: the decl, the def,
the 3 patched sites, `UhdmExporter.cpp:1027` (the **ELEMENT** site owned by
§ arrayElemTsSignedParented9) and `ParamEmit.cpp:10754`. I read the last one —
it is a **const-call parameter-fold** typespec, not an index position. Leaving
both alone is correct.

---

## 2. COLLISIONS — none

| law / pass | status |
|---|---|
| § arrayElemTsSignedParented9 (`UhdmExporter.cpp:1027`) | patch hunks are at `1794` and `1800+`. **Disjoint.** Arms re-run below. |
| § arrayElemTdClone42 (`sharedAliasTs` branch of `assocIndexTs`) | not inside any hunk; the only change in that function is the `return` line of the *later* `PredefinedIntegerType` arm. **Untouched.** |
| § bitsOwnClassPropFold61 / § endBlockLabelAllOwners62 | not in any hunk. |
| **r10svs9** (landed mid-pass, now `2ee7a58`) | patch applies `rc=0` to the new tip; all gates below measured **on** that tip. **No collision.** |
| **r10earl34** (live, hier_path naming) | touches `src/ExprEmit.cpp` only — **disjoint** from all 4 files. |

### § arrayElemTsSignedParented9's arms still hold

`ct9arm.sh`, my two binaries, dump-diff content vs golden:

| arm | pristine | patched |
|---|---|---|
| b1_ctrl | 31 | 31 |
| b2_elemkind | 368 | 368 |
| b3_typedef | 387 | 387 |
| **b4_arraykind** | 430 | **429** |
| b6_scope | 21 | 21 |

Four identical; `b4_arraykind` moves by **one line**, and I checked its
direction rather than assuming it: the only content change is a single
`+  |vpiSigned:1`, and the signed-line counts go **golden 68 / ours 62 → 63**.
It moved *toward* golden. § 9's arm is improved, not regressed.

---

## 3. THE FIVE GATES, RUN INDEPENDENTLY

### GATE 1 — BUILD

```
BUILD DIR (absolute): /tmp/wt_v63/build
link line           : [100%] Linking CXX executable slang-uhdm   (waited for, read)
errors              : 0        rc: PATCHED_RC=0 / PRIS_RC=0
both worktrees      : git rev-parse HEAD = 2ee7a58e8baa07d589428d4b6239afb5d84f379a
```

md5s asserted in their own commands, both 32 hex (table in §0).

> **Ops note, recorded because it cost real time and could bite the next agent:**
> my first attempt ran the two builds concurrently at `-j14` and **both were
> OOM-killed** (`cc1plus: fatal error: Killed signal`) — this box has 15 GB and
> another agent's worktrees (`wt_v34b`, `wt_v34bpris`) were building at `-j5`,
> with the big translation units peaking ~1.6 GB each. The compound command's
> `echo` made the failure report `exit code 0`. Rebuilt **sequentially at
> `-j3`**; both clean. A build "completing" is not a built binary — check for
> the artifact.

### GATE 2 — GOLDENS

```
GOLDEN_DEFER=[UNSET]
SLANG_UHDM=/tmp/wt_v63/build/slang-uhdm  ./tests/check_goldens.sh -> rc=0  PASS=23 FAIL=0
SLANG_UHDM=/bin/false                    ./tests/check_goldens.sh -> rc=1  PASS=0  FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir`

```
testflags  679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL     (patched AND pristine)
ct8rows.sh results/gate_uhdm2rtlil.csv  -> 0 differing ROWS (0 diff row-sides)
  baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
  dump histogram base : 496 match / 183 differ / 52 blank
  dump histogram fresh: 496 match / 183 differ / 52 blank
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both --jobs 2`

```
default    467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
  (patched AND pristine identical)
ct8rows.sh results/golden_surelog.csv -> 0 differing ROWS (0 diff row-sides)
  baseline 1589 lines = 1588 ROWS ; fresh 1589 lines = 1588 ROWS
  dump default  : 225 match / 242 differ / 327 blank   (base == fresh)
  dump testflags: 165 match / 298 differ / 331 blank   (base == fresh)
PASS: every row byte-identical to the committed baseline
```

`GOLDEN_DEFER` UNSET, **5 DEFERRED** in both modes, as in the baseline.

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs my own pristine `2ee7a58`

```
U2R      : PATH_SETS_IDENTICAL (679)  MOVERS: 0 / 679
           SELFCHECK 678/679   SELFCHECK1 = 1
SURELOG  : PATH_SETS_IDENTICAL (953)  MOVERS: 7 / 953
           SELFCHECK 952/953   SELFCHECK1 = 8   (1 corruption + 7 real movers)
```

The 7 movers are **exactly** the 7 claimed databases:

```
default/BuildUVMPkg  default/Scoreboard  default/SeqDriver  default/SimpleUVM
testflags/BuildUVMPkg  testflags/SeqDriver  testflags/SimpleUVM
```

---

## 4. THE HEAD, ON ALL THREE TARGET ROWS

`rowheads.sh`, my own workdirs, before and after:

| test | mode | pristine | patched |
|---|---|---|---|
| **SimpleUVM** | default | 14 (1 head) | **31 (1 head)** |
| **SimpleUVM** | testflags | 14 (1 head) | **31 (1 head)** |
| **Scoreboard** | default | 14 (1 head) | **31 (1 head)** |
| Scoreboard | testflags | SKIP-NOFILE (SLANG_REJECT, reported not hidden) | same |
| SeqDriver | both | 85 (1) | 85 (1) — unchanged |
| BuildUVMPkg | both | 58 (1) | 58 (1) — unchanged |

**The head is CLEARED, not renumbered** — I checked identity, not depth:

```
grep -c '312:48'   pristine: 4 / 4 / 4      patched: 0 / 0 / 0
```

Pristine head verbatim: `integer_typespec: , id:192201, line:312:48,
endln:312:55` + `|vpiSigned:1`, RHS carrying nothing. Patched successor on all
three rows is the *same* object — `integer_var:
(uvm_pkg::uvm_recorder::get_handle::handle), id:147053, line:343:18` with
**`RHS: <null>`** — i.e. residue R1, confirmed.

**14 → 31 is not a regression**: head depth is a subtree, and the successor is a
different, deeper object that the cleared head was masking.

**KNOWN FLAKE handled.** `Scoreboard/default` is MULTI-STABLE, so I ran it
**3 reps**: `6cb457074ecf0dd28311562e3cbbed4e` on all three, identical.
I also ran a **determinism check** on `SimpleUVM` — 3 fresh emissions,
`0467f50cf7b56c461285b9f720abc795` every time and equal to the sweep artifact.
No nondeterminism is polluting the mover reading.

---

## 5. MOVERS — PER SHAPE, AND THE ARITHMETIC SLIP

`mv63.sh` on all 7, ADDED/REMOVED never netted:

| row | dist pristine | dist patched | gain | ADDED | REMOVED | shape |
|---|---|---|---|---|---|---|
| default/SimpleUVM | 144521 | 144526 | −5 | 5 | 0 | `\|vpiSigned:1` |
| testflags/SimpleUVM | 144517 | 144522 | −5 | 5 | 0 | `\|vpiSigned:1` |
| default/Scoreboard | 134805 | 134810 | −5 | 5 | 0 | `\|vpiSigned:1` |
| default/BuildUVMPkg | 81209 | 81215 | −6 | 6 | 0 | `\|vpiSigned:1` |
| testflags/BuildUVMPkg | 81209 | 81215 | −6 | 6 | 0 | `\|vpiSigned:1` |
| default/SeqDriver | 367720 | 367715 | +5 | 5 | 0 | `\|vpiSigned:1` |
| testflags/SeqDriver | 367720 | 367715 | +5 | 5 | 0 | `\|vpiSigned:1` |
| | | | | **37** | **0** | |

**ADD-ONLY HOLDS: REMOVED = 0 on every row, and the only ADDED shape anywhere
is `  |vpiSigned:1`.**

### An INDEPENDENT instrument the pass did not use: file size

Adding a `vpiSigned` flag costs a fixed 2 bytes in the serialized database. If
the patch did anything *else* — re-parenting, re-spanning, re-arena-ing — the
size deltas would not be a clean multiple of the ADDED count. They are:

```
BuildUVMPkg  +12 = 6 x 2      Scoreboard +10 = 5 x 2
SeqDriver    +10 = 5 x 2      SimpleUVM  +10 = 5 x 2
TOTAL +74 bytes = 37 x 2
```

**A third instrument agreeing on 37 to the byte.**

### FINDING 1 (reporting slip, not a measurement error): the total is 37, not 38

The report's summary says "**38 lines total**". **It is 37.** The
implementer's *own* per-row table (`README.md` lines 405–417) lists
`5,5,5,6,6,5,5`, which sums to **37**; only the hand-written total row says 38.
My per-row values are identical to theirs, and the size-delta arithmetic
(74 bytes / 2) independently gives 37. **The measurement is right; the addition
is wrong.** No gate depends on it.

### FINDING 2 (reporting slip): "rose on four rows and fell on one"

The table shows the distance **rose on 5 rows and fell on 2** (or, by distinct
test: rose on 3, fell on 1). The prose sentence matches neither counting. The
table is authoritative and correct.

### The "distance rose" explanation itself is SOUND

I verified the mechanism rather than accepting the excuse. `msdist.sh` compares
**multisets of line texts**; `  |vpiSigned:1` is interchangeable, so the sign of
the change depends only on which side already held a surplus of that text:

* `SimpleUVM` golden 2155 / ours 2440 → **ours already in surplus** → each
  correct add *raises* the distance.
* `SeqDriver` golden 3514 / ours 3351 → **ours below** → each add *lowers* it.

Same patch, opposite sign, for a reason that is a property of the instrument.
Demoting `gain == ADDED` from a pass/fail to a reported number is the correct
call, and it was **disclosed** rather than buried.

### PER-OBJECT ACCOUNTING — the instrument that actually decides

`acct63.py` on `default/SimpleUVM` (1.1 M-line dumps, all three sides):

```
OUTER int_typespec      144:31-144:34   g=1,1  p=1     q=1,1   MOVED x1 (now matches golden)
OUTER int_typespec      50:47-50:50     g=1    p=-     q=1     MOVED x1 (now matches golden)
OUTER int_typespec      53:47-53:50     g=1    p=-     q=1     MOVED x1 (now matches golden)
OUTER integer_typespec  312:48-312:55   g=1    p=-     q=1     MOVED x1 (now matches golden)  <-- THE HEAD
OUTER integer_typespec  386:47-386:54   g=1    p=-     q=1     MOVED x1 (now matches golden)
-- index-slot keys=104  OCCURRENCES MOVED=5  HELD-BACK=0  (golden has no object there: 2)
```

**HELD-BACK = 0** — there is no index typespec golden signs that we still leave
unsigned. `OCCURRENCES MOVED = 5 == ADDED = 5`. The same-span collision the
implementer disclosed (`uvm_sequence_base.svh:144`, two objects at one span, one
already signed) is visible in the `1,1 / 1 / 1,1` vector, exactly as documented
— their mid-pass correction of this instrument was real and necessary.

### The predicted non-mover

`DynArrayKind` was predicted not to move (module scope, already stamped — the
behaviour-neutrality control for the `TypeEmit` refactor). **Verified
byte-identical in both modes.** The b2 module arm likewise reads
**102 → 102 dump-diff lines, unchanged**, which is the same control from the
other direction.

---

## 6. EMPTY PRODUCT CELLS — index kind x scope x typedef x multi-dim

I reproduced the implementer's grids and then hunted the cells their product
missed.

### Reproduced, cell-for-cell

`ct63cells.py`, my binaries — **DIFFER counts match the report exactly**:

| arm | pristine DIFFER | patched DIFFER |
|---|---|---|
| b1 (class, 21 index kinds) | 9 | **4** |
| b2 (module twin) | 4 | **4** (neutrality control) |
| b3 (named / multi-dim) | 6 | **1** |
| b4 (package / iface / typedef) | 6 | **1** |

And the refutation the brief asked about is confirmed on my own run: in b1's
grid **`G parent` reads `no` on every one of the 23 cells**, before and after.
**Golden does not parent the index typespec.** Stamping `VpiParent` — the
obvious transcription from § arrayElemTsSignedParented9 — would have been an
over-fire on every cell this pass clears. The refutation is correct and it is
the pass's sharpest result.

### FINDING 3 — THE UNMEASURED AXIS: SUBROUTINE-LOCAL AND FORMAL-ARGUMENT SCOPE

**This is the finding that mattered.** `assocIndexTs` has five callers. Two of
them live in `src/TaskFuncEmit.cpp` (lines **1280** and **2232**) — the
subroutine-local variable writer and the formal-argument writer. **No arm b1–b4
contains a single function-local, task-local, or formal-argument associative
array.** Those two call sites received the new stamp with **no golden
measurement behind them**.

That is not a pedantic gap. `src/UhdmExporter.cpp`'s own
§ arrayVarSignedWritten8 comment records, as a *measured* result, that the
sibling signedness law **inverts at exactly this scope**:

> "IT IS THE OPPOSITE AT SUBROUTINE/BLOCK-LOCAL SCOPE — arm a9 cells
> n01/n02/n03 show golden putting `vpiSigned:1` on the ELEMENT and nothing on
> the array_var there — which is why this law is scope-bound and
> TaskFuncEmit.cpp's `reg0->VpiSigned(true)` sites are deliberately left alone."

So a law claiming "no scope term" was shipped without measuring the one scope
where its closest sibling flips. **I built the missing arm**
(`b5_sublocal.sv`, added in this directory) covering function-local, task-local,
class-method-local, and formal-argument associative indices across the signed
atoms, `time`, `int unsigned`, `bit`, `string`, and a multi-dim
`[string][integer]`.

**GOLDEN'S POLICY AT SUBROUTINE SCOPE IS IDENTICAL.** Read from golden's
top-level typespec listing (the only occurrence that carries an object's own
fields):

| cell | span | golden | ours (patched) |
|---|---|---|---|
| `s01_integer[integer]` fn-local | 33:19 | `vpiSigned:1` | `vpiSigned:1` ✓ |
| `s02_int` / `s03_byte` / `s04_shortint` / `s05_longint` | 34–37 | `vpiSigned:1` | `vpiSigned:1` ✓ |
| `s06_time` | 38:16 | absent | absent ✓ |
| `s07_intu` (`int unsigned`) | 39:16 | absent | absent ✓ |
| `s09_string` | 41:18 | absent | absent ✓ |
| `s10_md_si[string][integer]` INNER | 42:25 | `vpiSigned:1` | `vpiSigned:1` ✓ |
| `a01_integer` … `a03_byte` **formal args** | 61–63 | `vpiSigned:1` | `vpiSigned:1` ✓ |
| `a06_time` / `a07_intu` / `a09_string` formal args | 64–67 | absent | absent ✓ |
| `k01_integer` … `k03_byte` **class-method local** | 73–75 | `vpiSigned:1` | `vpiSigned:1` ✓ |
| `k06_time` / `k07_intu` / `k09_string` | 76–79 | absent | absent ✓ |

And **every one of these golden index objects is UNPARENTED**, so refutation (h)
holds at subroutine scope too.

Measured effect of the patch on b5: dump-diff **602 → 598**, hunks **17 → 11**,
and the shape diff between my pristine and patched runs is

```
12 x  +  |vpiSigned:1        (and nothing else)
```

**12 = exactly the signed-atom index cells in the arm** (6 fn-local incl. the
multi-dim inner + 3 formal + 3 class-method). **All 12 are lines golden also
has; 0 are lines golden lacks.** No over-fire.

**Conclusion: the law's "no scope term" clause is TRUE on the axis that was
never measured, and the two unmeasured call sites are correct.** The verdict is
unchanged, but the evidence base for it was incomplete as delivered and is
complete now.

### FINDING 4 — the law statement's "It is not parented" needs the typedef carve-out

The one-line law says the index typespec "**is not parented**". In arm b4 that
is true for every declaration-site cell, but golden **does** print `vpiParent`
on cells `?line32`–`?line36` — the objects belonging to a *typedef's own
listing* (`typedef int t01_ai_t[integer];`). I confirmed: `G parent = yes` on
all five.

The implementer **does** document this carve-out precisely, in the code comment
at the definition ("the only index cells where golden prints `vpiParent` are the
ones whose object *is a typedef's own listing object*"). Only the compressed
one-line statement omits it. **No impact today** — our side emits `-NOOBJ-` at
those cells, so nothing is compared — but if residue R6 is ever fixed and we
start emitting those objects, the parent clause needs its exception or the fix
will under-fire. Recording it so that pass does not have to rediscover it.

### FINDING 5 — a residue the list does not name: INTERFACE scope emits no index typespec at all

Arm b4 contains interface cells `i01`–`i04` (lines 39–42). Golden emits them
with the standard policy (`integer`→1, `byte`→1, `int unsigned`→absent,
`string`→absent, all unparented). **Our side emits no index typespec object
there at all** — `gocc=4 oocc=0`, identically **before and after** the patch, so
the extractor scores them `UNMEASURED` rather than `DIFFER` and they are easy to
read past.

This means the law's "…not scope (class/module/package/**interface** read
identically)" is supported **on the golden side only**; on our side the
interface cell is not yet reachable. Pre-existing, not caused by this patch, and
not named in the residue list (R6 covers module-scope inner + dyn-container
typedef identity). Added as R4 below.

### Cells I checked and found genuinely covered

`typedef`'d index (returns above the arm via `sharedAliasTs`/§ 42 — verified by
reading, and b3 `f01`–`f08` measures it); class-handle index (b3 `f09`);
multi-dim inner slot at class, module, package **and** subroutine scope;
`bit`/`logic`/`reg`; unsigned spellings of all five atoms; explicit `signed`
spellings; packed vectors signed and unsigned; `string`; `time`. **Every one of
the 7 producers is now behind an arm** — the 5 `assocIndexTs` callers plus the
`TypeEmit` and `ParamEmit` hand copies.

---

## 7. CANARIES

```
canaries.sh  surelog : ok=52 changed=0 absent=0  unknown-names=7   (expected 7)
canaries.sh  u2r     : ok=8  changed=0 absent=0  unknown-names=25  (expected)
ctcan2.sh    surelog : EXPECT_UNKNOWN=1 -> ok=58 changed=0 absent=0  PASS rc=0
ctcan2.sh    u2r     : EXPECT_UNKNOWN=6 -> ok=1  changed=0 absent=0  PASS rc=0
canaudit.sh          : audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS rc=0
                       UnsignedParam / HierPathEval / FileLocalParam / TopParam
                       not dispatched by any driver (OK)
```

> Note on the brief's shorthand "ctcan2 EXPECT_UNKNOWN=6/=1": the **surelog**
> csv expects **1** and the **u2r** csv expects **6**, not the reverse. I ran it
> inverted first and it correctly **FAILED** both ways — the guard works.

Named canaries, byte-level, by name:

```
default/InterfaceModPort-a10293bb     BYTE-IDENTICAL (59a365f3ce2c)
testflags/InterfaceModPort-a10293bb   BYTE-IDENTICAL (59a365f3ce2c)
default/BlackParrotComplex-5bed297d   BYTE-IDENTICAL (e3e354129d5a)
testflags/BlackParrotComplex-5bed297d BYTE-IDENTICAL (73a10e8217e5)
```

No conversion claimed and none occurred: `SimpleUVM` and `Scoreboard` are
`CMP_NOTEQUAL` before and after.

---

## 8. RANKED RESIDUES (mine)

**R1 — the new head, all three rows.** `integer handle = get_inst_id();`
(`uvm_recorder.svh:343`), a function-local variable with an initialiser inside
`else begin`: golden emits an `integer_var`, we emit **nothing** (`RHS:
<null>`). Confirmed on all three target rows and now the sole head. **The next
pass's target.**

**R2 — `bit`-family indices come out `logic_typespec`.** `VpiType` is compared,
so these are live `DIFFER` cells (b1 `c12`/`c16`, b4 `?line28`) in class,
module, package *and* subroutine tables. Largest remaining index-position
cluster.

**R3 — signed packed-vector indices unsigned on our side** (b1 `c18`/`c19`).
Correctly **not absorbed** by this pass: zero corpus occurrences, and for the
`bit` half the kind is already wrong (R2) so signing it would clear no cmp line.
Sibling of r10oth9-R1, different producer — do not merge without the module-twin
table.

**R4 (NEW, mine) — interface-scope assoc arrays emit no index typespec at all.**
Golden emits them with the standard policy; we emit `-NOOBJ-`. Pre-existing and
unchanged by this patch, but it means the law's "interface" clause is currently
unverifiable on our side. Cheap to probe: arm b4 already contains the cells.

**R5 — dyn-container-typedef index object identity.** For `typedef int
T[integer]; T q;` golden's index object is the **typedef's own listing object**
(carrying `vpiParent` → the typedef declaration); ours is a per-declaration mint
at the declarator span. Both now carry the right `vpiSigned`, so only identity
and span differ. **See FINDING 4** — fixing this one activates the parent
carve-out.

**R6 — `int signed` / `byte signed` index span.** Golden spans the keyword only
(`39:21-39:24`); we span the whole `int signed` (`39:21-39:31`), which makes the
cells read `UNMEASURED` rather than comparable.

**R7 — we carry ~285 surplus `vpiSigned` lines vs golden in SimpleUVM** from
some other law (golden 2155 / ours 2445). This is what makes the multiset
distance rise, and it is a real over-stamp *somewhere else* worth its own pass.

**R8 — `struct_typespec` index loses `vpiParent`**; and b4's package arm
suggests golden puts `vpiSigned` on the **array_var at package scope**, an axis
§ arrayVarSignedWritten8's table did not cover. No corpus row exercises either.

---

## 9. WHAT I RAN — commands

```bash
# hygiene
git apply --numstat /tmp/r10uvm63.patch ; git apply --check -v /tmp/r10uvm63.patch   # rc=0 @ 2ee7a58
md5sum /tmp/r10uvm63.patch                       # a5cf806cc1957dba01a9edbfd14dd2a4

# build (SEQUENTIAL -j3 — concurrent -j14 OOMs on this box)
git worktree add /tmp/wt_v63 -b v63wt 2ee7a58 ; git worktree add /tmp/wt_v63pris --detach 2ee7a58
cmake -S /tmp/wt_v63 -B /tmp/wt_v63/build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
      -DUHDM_DIR=$HOME/.local/lib64/cmake/UHDM -Dslang_DIR=$HOME/.local/lib64/cmake/slang
make -C /tmp/wt_v63/build -j3 ; make -C /tmp/wt_v63pris/build -j3
md5sum /tmp/wt_v63/build/slang-uhdm ; md5sum /tmp/wt_v63pris/build/slang-uhdm

# gates
SLANG_UHDM=/tmp/wt_v63/build/slang-uhdm ./tests/check_goldens.sh
SLANG_UHDM=/bin/false                   ./tests/check_goldens.sh
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 \
        --out /tmp/v63_u2r_patch.csv --workdir /tmp/v63_wd_u2r_patch
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 2 \
        --out /tmp/v63_sl_patch.csv --workdir /tmp/v63_wd_sl_patch     # + pristine twins
./tools/probe/r10uvm63repro/ct8rows.sh results/gate_uhdm2rtlil.csv /tmp/v63_u2r_patch.csv
./tools/probe/r10uvm63repro/ct8rows.sh results/golden_surelog.csv   /tmp/v63_sl_patch.csv
SELFCHECK=1 SELFCHECK1=1 ./tools/probe/r10uvm63repro/byteverify.sh <patched_wd> <pristine_wd>

# head + movers
./tools/probe/r10uvm63repro/rowheads.sh <wd> <out> SimpleUVM Scoreboard SeqDriver BuildUVMPkg
./tools/probe/r10uvm63repro/mv63.sh <golden> <pristine> <patched> <label>
python3 tools/probe/r10uvm63repro/acct63.py g.dump p.dump q.dump

# arms (incl. my new b5)
SLANG_UHDM=<bin> ./tools/probe/r10uvm63repro/ct63arm.sh b5_sublocal.sv <wd>
python3 tools/probe/r10uvm63repro/ct63cells.py b1_idxkind.sv g.dump o.dump

# canaries
./canaries.sh <fresh.csv> <baseline.csv>
EXPECT_UNKNOWN=1 ./ctcan2.sh results/golden_surelog.csv   /tmp/v63_sl_patch.csv
EXPECT_UNKNOWN=6 ./ctcan2.sh results/gate_uhdm2rtlil.csv  /tmp/v63_u2r_patch.csv
./canaudit.sh ./canaries.sh ./ctcan2.sh
```

All sweep workdirs (`/tmp/v63_wd_*`) and arm scratch dirs deleted. Worktrees
`/tmp/wt_v63` and `/tmp/wt_v63pris` retained. The main tree was never written to.

---

## 10. RECOMMENDATION

**LAND IT.** The law is correct, the gate is the stated gate, the direction is
provably add-only, and the head is cleared on all three rows with zero
regressions across 1632 database comparisons.

Two items to fold in before the commit message is written:

1. **Correct the total from 38 to 37** (the report's own table already says 37,
   and the size-delta check confirms it to the byte), and fix "rose on four rows
   and fell on one" to **rose on 5 rows, fell on 2**.
2. **Take `b5_sublocal.sv` with the patch.** It is the arm that turns the
   "no scope term" clause from an assertion into a measurement, on the one axis
   where the sibling law is known to invert. Without it, the two
   `TaskFuncEmit.cpp` call sites remain shipped-but-unmeasured in the durable
   record even though they are correct.
