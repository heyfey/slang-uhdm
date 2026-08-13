# r10uvm63 — § assocIndexTsSigned63, the briefed 14-line head **CLEARED on all THREE target rows** — 7 movers, exactly the 7 predicted from a corpus census taken BEFORE the patch, and the brief's own clue (h) **REFUTED: golden does NOT parent the index typespec**

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard` **DID
NOT CONVERT**: they are `CMP_NOTEQUAL` before and after. No conversion was
expected from this pass and none happened. `results/gate_uhdm2rtlil.csv` (**731**
rows) and `results/golden_surelog.csv` (**1588** rows) are byte-identical to the
committed baselines in **both** my sweeps, pristine and patched.

**SECOND LINE.** The briefed head — `integer_typespec @312:48-312:55`, golden
`|vpiSigned:1`, ours nothing — is **GONE from all three target row-modes**
(`SimpleUVM/default`, `SimpleUVM/testflags`, `Scoreboard/default`). All three now
head on the *same different object*, one much deeper in the same class, which was
masked behind it.

**THIRD LINE, and it is the one the brief asked me to decide.** The brief's
measurement list item (h) asked whether golden parents the INDEX typespec, on the
model of § arrayElemTsSignedParented9, which stamps **both** `vpiParent` and
`vpiSigned` at the ELEMENT site. **Golden does not.** Across 50 measured index
cells in four scopes, golden's index typespec is **UNPARENTED in every single
one**; the only index cells that print `vpiParent` are those whose object *is a
typedef's own listing object*, where the parent is the typedef declaration and
has nothing to do with the index position. Stamping `VpiParent` here — the
obvious transcription from the sibling law — would have been a **measured
over-fire on every cell this pass clears**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; `ct63arm.sh` and `rowheads.sh` print that they did on every run.

Base **40a7068**. Worktree `/tmp/wt_r10uvm63`; pristine control worktree
`/tmp/wt_r10uvm63pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print `40a7068f95dee6af49e526ebf03674e589eec8fb`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 40a7068) | `2372ca526cf1e50195a17b0e44288b61` | my own build of the base commit |
| **FINAL (shipped)** | **`0d39f5e53e66646aa39ecede4b3f4baa`** | every gate number below was measured on THIS binary |

BUILD DIR (absolute): `/tmp/wt_r10uvm63/build`. The link line
(`[100%] Linking CXX executable slang-uhdm`) was waited for and read before any
md5 was taken; both md5s were asserted in their own command, and both are 32 hex
digits. `git stash` was never used. The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched — `canaudit.sh` proves it mechanically (FENCE-BREACH=0).
`GOLDEN_DEFER` left **UNSET** (echoed as `[UNSET]` at both sweep launches; **5
DEFERRED** in both surelog modes, as in the baseline). slang was not patched.

---

## 0. THE LAW

### § assocIndexTsSigned63

*The **INDEX TYPESPEC** of an **ASSOCIATIVE ARRAY** carries `vpiSigned` = **the
index type's RESOLVED signedness**, and carries **NOTHING ELSE**. It is not
parented. Nothing else conditions it — not the scope (class, module, package,
interface all read identically), not the index SLOT (the `vpiIndexTypespec` of
dimension 1 and the `STRING:associative` marker constant of dimensions 2..N read
identically), not whether the array itself was reached through a typedef.*

* **DIRECTION: ADD ONLY.** The patch mints no object, deletes none, re-parents
  none, and moves no span. The only dump-line shape it can produce is
  `|vpiSigned:1` — **measured**, not asserted: across all 7 mover databases
  `mv63.sh` reports `REMOVED line instances=0` and exactly one ADDED shape,
  `  |vpiSigned:1`.
* `grep -rn 'assocIndexSignedAtom63' src/ include/` → **5 hits**: the
  declaration, the definition, one reference inside the law comment, and **three
  call sites** — `assocIndexTs` (`src/UhdmExporter.cpp`), § assocIdxSiteFour43
  (`src/TypeEmit.cpp`), § assocIdxSiteFive44 (`src/ParamEmit.cpp`). Those three
  are every producer of the index rule that can reach a predefined-integer index.

### STATED GATE == CODE GATE — read off the source, not the comment

| | |
|---|---|
| **the whole gate** | `if (!ts \|\| !ic.isSigned()) return ts;` then a `switch` on `ts->UhdmType()` with cases for `int` / `integer` / `short_int` / `long_int` / `byte` typespec |
| **not in the gate** | no scope test · no view parameter · no typedef test · no declarator test · no `time` case · no name test |
| `src/UhdmExporter.cpp` (`assocIndexTs`) | `ic.kind == PredefinedIntegerType` → `assocIndexSignedAtom63(ic, predefIntTypespec(ic, sym))` |
| `src/TypeEmit.cpp` (site four) | `ick.kind == PredefinedIntegerType` → `assocIndexSignedAtom63(ick, predefIntTypespec(ick, sym))` |
| `src/ParamEmit.cpp` (site five) | `ick.kind == PredefinedIntegerType` → `assocIndexSignedAtom63(ick, predefIntTypespec(ick, vs))` |

`time` is **doubly excluded** on purpose: `isSigned()` is false for it *and* the
switch has no `time_typespec` case, matching `makeTypespec`. Golden reads ABSENT
for `[time]` in every arm (b1 c06 / b2 m06 / b4 p06).

**The `isSigned()` in the gate is on the CANONICAL type, so it pierces an alias.
That is the same choice § arrayElemTsSignedParented9 made for the element
typespec and the OPPOSITE of § arrayVarSignedWritten8's "as written" predicate
for the array_var. The three carriers still disagree and the predicates are still
NOT merged.**

---

## 1. WHAT WAS MEASURED BEFORE ANY CODE WAS WRITTEN

### 1.1 The head, on my own pristine build, before touching anything

```
rowheads.sh /tmp/ctl_wd_sl_40a7068 …  SimpleUVM Scoreboard SeqDriver BuildUVMPkg
  SimpleUVM   default     14 cmp lines  1 head
  SimpleUVM   testflags   14 cmp lines  1 head
  Scoreboard  default     14 cmp lines  1 head
  Scoreboard  testflags   SKIP-NOFILE (SLANG_REJECT, no database — reported, not hidden)
  SeqDriver   default/testflags  85  1 head   (another law)
  BuildUVMPkg default/testflags  58  1 head   (another law)
```

The head itself, verbatim — the brief's description confirmed exactly:

```
LHS:  integer_typespec: , id:192201, line:312:48, endln:312:55
      |vpiSigned:1
RHS:  integer_typespec: , id:53826,  line:312:48, endln:312:55
      (nothing)
```

Same span, same id-position, one field. The witness is
`uvm-1.2/src/base/uvm_recorder.svh:312` —
`local static uvm_recorder m_recorders_by_id[integer];` — an associative array
indexed by `integer`, a class property of `uvm_pkg::uvm_recorder`. Column 48 is
the `integer` keyword inside the brackets, confirmed against the source line.

### 1.2 THE FIELD-POLICY GRID, cell for cell

`ct63cells.py <arm.sv> <g.dump> <o.dump>` descends `array_typespec` →
`vpiIndexTypespec` → `ref_typespec` → `vpiActual` (and, for the INNER slot, the
`STRING:associative` marker constant → `vpiTypespec` → …), then re-finds the
typespec **at its fullest occurrence** and reads own-child-depth fields. It does
not grep a kind. Under `vpiActual` the index typespec *always* prints as a bare
header, so reading fields there would have reported every cell as empty on both
sides — a perfect-looking, perfectly wrong table.

**GOLDEN's policy. The three declaration scopes are CELL-FOR-CELL IDENTICAL.**
(`G`=golden, `sgn`=`vpiSigned`, `par`=`vpiParent`. Arm b1 = CLASS property,
b2 = MODULE variable, b4 = PACKAGE variable.)

| index as written | G kind | G sgn | G par | b1 class | b2 module | b4 package |
|---|---|---|---|---|---|---|
| `integer` | `integer_typespec` | **1** | – | c01 | m01 | p01 |
| `int` | `int_typespec` | **1** | – | c02 | m02 | p02 |
| `byte` | `byte_typespec` | **1** | – | c03 | m03 | p03 |
| `shortint` | `short_int_typespec` | **1** | – | c04 | m04 | p04 |
| `longint` | `long_int_typespec` | **1** | – | c05 | m05 | p05 |
| `int signed` | `int_typespec` | **1** | – | c20 | m20 | – |
| `byte signed` | `byte_typespec` | **1** | – | c21 | m21 | – |
| `time` | `time_typespec` | – | – | c06 | m06 | p06 |
| `int unsigned` | `int_typespec` | – | – | c07 | m07 | p07 |
| `byte unsigned` | `byte_typespec` | – | – | c08 | m08 | – |
| `integer unsigned` | `integer_typespec` | – | – | c09 | m09 | – |
| `shortint unsigned` | `short_int_typespec` | – | – | c10 | m10 | – |
| `longint unsigned` | `long_int_typespec` | – | – | c11 | m11 | – |
| `bit` | `bit_typespec` | – | – | c12 | m12 | p08 |
| `logic` | `logic_typespec` | – | – | c13 | m13 | – |
| `reg` | `logic_typespec` | – | – | c14 | m14 | – |
| `bit [7:0]` | `bit_typespec` | – | – | c16 | m16 | – |
| `logic [7:0]` | `logic_typespec` | – | – | c17 | m17 | – |
| `bit signed [7:0]` | `bit_typespec` | **1** | – | c18 | m18 | – |
| `logic signed [7:0]` | `logic_typespec` | **1** | – | c19 | m19 | – |
| `string` | `string_typespec` | – | – | c15 | m15 | p09 |
| class handle | `class_typespec` | – | – | b3 f09 | – | – |

**The two SLOTS also read identically** (arm b3, `[string][integer]` and friends):

| cell | slot | G kind | G sgn | G par |
|---|---|---|---|---|
| `f10_md_si` `[string][integer]` | OUTER | `string_typespec` | – | – |
| | INNER | `integer_typespec` | **1** | – |
| `f11_md_is` `[integer][string]` | OUTER | `integer_typespec` | **1** | – |
| | INNER | `string_typespec` | – | – |
| `f12_md_ii` `[integer][int]` | OUTER | `integer_typespec` | **1** | – |
| | INNER | `int_typespec` | **1** | – |
| `f13_md_sb` `[string][byte]` | OUTER | `string_typespec` | – | – |
| | INNER | `byte_typespec` | **1** | – |

**vpiParent is `–` in every row of both tables. That is 50 golden cells and zero
exceptions.** The only golden index cells that DO print `vpiParent` are the ones
whose object is a **typedef's own listing object** (b3 `?line17`..`?line23`, a
typedef'd INDEX; b4 `?line32`..`?line36`, a `typedef int T[integer];` whole-array
name). Those are parented **by the typedef declaration**, and their existence is
what makes the distinction measurable rather than assumed.

### 1.3 The four refutations this grid produced

1. **`vpiParent` does NOT carry over from § arrayElemTsSignedParented9.** Above.
   The brief's item (h) is answered NO.
2. **There is no typedef gate, unlike § 9.** § 9 gates on
   `cp.getType().kind != TypeAlias` because golden's object for a whole-array
   typedef is a bare `array_typespec` with neither field. **The index position has
   no such cell**: for `typedef int T[integer]; T q;` golden's index object is the
   *typedef's* `integer_typespec` and it carries `vpiSigned:1` (b4 `?line32`). A
   typedef gate here would have suppressed a flag golden emits.
3. **The law is NOT scope-bound**, which is the axis § 9 was bound on
   (class right / module wrong) and § arrayVarSignedWritten8 was bound on
   (declaration scope vs subroutine scope). Here class, module, package and
   interface all read the same, so the gate carries no scope term.
4. **The pre-existing asymmetry in our own source was a DEFECT, not an
   invariant.** `src/TypeEmit.cpp` carried this exact switch since pass 43 and its
   comment defended the asymmetry in as many words: *"this site sets VpiSigned …
   and assocIndexTs does not, so routing everything through it would … add one at
   the other three sites."* Golden **wants** the flag at those sites. That comment
   is corrected in place rather than left to rot.

### 1.4 THE CORPUS CENSUS — the mover prediction, made before the patch existed

`census63.sh <workdir> <out>` dumps every database a sweep produced and counts
index-slot occurrences of the five signed-atom KINDS. It is deliberately a
**SUPERSET**: our own pre-patch dump cannot tell `[int]` from `[int unsigned]`,
because the missing flag is exactly what this pass adds.

```
surelog corpus  (/tmp/ctl_wd_sl_40a7068) : 953 databases scanned, NO_DUMP=0, 9 CANDIDATE rows
uhdm2rtlil      (/tmp/r63_pris_wd_u2r)   : 679 databases scanned, NO_DUMP=0, 0 CANDIDATE rows
```

The scanner's window shape is itself a corrected instrument: a first version used
a fixed 3-line offset and reported **ZERO** index typespecs on an arm whose grid
shows 21. It now keys on `|vpiActual:` inside a slack window, and the arm control
(b1 → 12 atom-kind index typespecs, matching the grid's 5 signed + 5 unsigned +
2 explicit-`signed` cells) is re-run before any corpus scan.

The 9 candidates, then narrowed by **reading all seven source declarations**:

```
uvm-1.2 has exactly SIX assoc dims with a signed-atom index, all class properties:
  base/uvm_recorder.svh:312        [integer]   <- THE HEAD
  base/uvm_tr_stream.svh:386       [integer]
  base/uvm_resource.svh:955        [int]
  seq/uvm_sequencer_base.svh:50    [int]
  seq/uvm_sequencer_base.svh:53    [int]
  seq/uvm_sequence_base.svh:144    [int]
Surelog tests/DynArrayKind/dut.sv:6  `int assoc [int];`  -- MODULE scope
```

`DynArrayKind` is at **module** scope, where the flag was *already* stamped by
site four, so it was predicted **NOT** to move. Verified directly, before the
sweeps: its two databases are **byte-identical** across the two binaries. **That
same check is the behaviour-neutrality control for the TypeEmit refactor** — if
the shared helper differed in any way from the inline clause it replaced, this
database would have moved.

**PREDICTION, recorded before gate 5 ran: uhdm2rtlil 0 movers; surelog exactly 7
— `default/{BuildUVMPkg, Scoreboard, SeqDriver, SimpleUVM}` and
`testflags/{BuildUVMPkg, SeqDriver, SimpleUVM}`** (`Scoreboard/testflags` is
`SLANG_REJECT` and emits no database).

---

## 2. THE GRID AFTER THE PATCH

Arm b1 (CLASS), the 5 target cells: `DIFFER` → `same`, all five.

```
b1 CLASS   pristine: cells=23 same=10 DIFFER=9 UNMEASURED=4
           patched : cells=23 same=15 DIFFER=4 UNMEASURED=4
b2 MODULE  pristine: cells=23 same=15 DIFFER=4 UNMEASURED=4
           patched : cells=23 same=15 DIFFER=4 UNMEASURED=4   <- UNCHANGED, as required
b3 NAMED   pristine: cells=33 same=11 DIFFER=6 UNMEASURED=16
           patched : cells=33 same=16 DIFFER=1 UNMEASURED=16
b4 SCOPE   pristine: cells=29 same=3  DIFFER=6 UNMEASURED=20
           patched : cells=29 same=8  DIFFER=1 UNMEASURED=20
```

**b2 is the control and it did not move**: the module twin already passed every
signed-atom cell before this pass, so a change there would have meant the
refactor was not behaviour-preserving.

The **4 remaining b1 `DIFFER`s and the 1 in b3/b4 are all OTHER laws**, named and
ranked in §6: `bit`-based index kinds coming out `logic_typespec` (c12/c16/c18,
m12/m16/m18, p08), signed packed vectors (c18/c19, m18/m19), and one
`struct_typespec` `vpiParent` (b3 `?line23`). None of them is a signed-atom cell.

`UNMEASURED` never counts as agreement: it is a cell where one side emits **no
object at that span** (`-NOOBJ-`), which is a louder reading than an absent field
and is tallied separately. All 4 in b1/b2 are the `int signed` / `byte signed`
**span** residue (golden spans the keyword only, we span `int signed`); the 16 in
b3 and 20 in b4 are the typedef-index and dyn-container-typedef **object
identity** residues. Both are pre-existing and ranked.

---

## 3. THE FIVE GATES

### GATE 1 — BUILD

```
BUILD DIR (absolute) : /tmp/wt_r10uvm63/build
link line            : [100%] Linking CXX executable slang-uhdm   (waited for, then read)
errors in build log  : 0
FINAL   md5 : 0d39f5e53e66646aa39ecede4b3f4baa   (32 hex, asserted in its own command)
PRISTINE md5: 2372ca526cf1e50195a17b0e44288b61   (32 hex, asserted in its own command)
both worktrees: git rev-parse HEAD = 40a7068f95dee6af49e526ebf03674e589eec8fb
```

### GATE 2 — GOLDENS

```
SLANG_UHDM=<final>     ./tests/check_goldens.sh   rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false  ./tests/check_goldens.sh   rc=1  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir`

```
testflags  679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump       496 match      183 differ        52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv -> 0 differing ROWS (0 diff row-sides)
baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
PASS: every row byte-identical to the committed baseline
```

My **PRISTINE** sweep reproduces the committed baseline at **0 differing ROWS**
too — which is what makes gate 5's byte comparison meaningful.

### GATE 4 — surelog, `--mode both --jobs 2`

```
default    467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
dump       default   225 match / 242 differ / 327 blank
           testflags 165 match / 298 differ / 331 blank
ct8rows.sh results/golden_surelog.csv -> 0 differing ROWS (0 diff row-sides)
baseline 1589 lines = 1588 ROWS ; fresh 1589 lines = 1588 ROWS
PASS: every row byte-identical to the committed baseline
```

The pristine sweep also reproduces this baseline at **0 differing ROWS**.

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs my own pristine 40a7068

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
             SELFCHECK 678/679 flagged         SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 7 / 953
             SELFCHECK 952/953 flagged         SELFCHECK1 = 8  (= 7 real + 1 injected)
```

The 7 movers are **exactly the 7 predicted in §1.4**, no more and no fewer:

```
default/{BuildUVMPkg, Scoreboard, SeqDriver, SimpleUVM}
testflags/{BuildUVMPkg, SeqDriver, SimpleUVM}
```

**The mover set is complete BY CONSTRUCTION, not by sampling.** The patch can
only add a `vpiSigned` flag, so any database that would gain one *must* differ in
bytes; the verifier compares **all 953** and `SELFCHECK1` proves it detects a
**one-byte** change. `DynArrayKind`, the one census candidate predicted not to
move, did not move.

### CANARIES

```
canaudit.sh canaries.sh ctcan2.sh   audited=29  UNCOVERED=0  FENCE-BREACH=0   PASS
ctcan2.sh  uhdm2rtlil  EXPECT_UNKNOWN=6  ok=1   changed=0 absent=0 unknown=6   PASS
ctcan2.sh  surelog     EXPECT_UNKNOWN=1  ok=58  changed=0 absent=0 unknown=1   PASS
canaries.sh uhdm2rtlil  ok=8   changed=0 absent=0   unknown-names=25 (the surelog-only names)
canaries.sh surelog     ok=52  changed=0 absent=0   unknown-names=7  (the u2r-only names)
InterfaceModPort   base==fresh  default,CMP_EQUAL,,,differ  testflags,CMP_EQUAL,,,differ
BlackParrotComplex base==fresh  default,CMP_EQUAL,,,differ  testflags,CMP_EQUAL,,,differ
```

Both scripts were run on **both** corpora — neither supersedes the other, and
`ctcan2.sh` exists precisely because `canaries.sh`'s NAMES list does not carry
every brief-named canary. Note the two take their arguments in **opposite
order** (`ctcan2.sh <base> <fresh>`, `canaries.sh <fresh> <base>`).

### DETERMINISM, and the KNOWN Scoreboard/default FLAKE

The new code path is deterministic — 3 emissions each, 1 distinct hash each:

```
detcheck.sh <final> 3 b1_idxkind.sv   distinct hashes=1  NO_OUTPUT=0
detcheck.sh <final> 3 b3_named.sv     distinct hashes=1  NO_OUTPUT=0
detcheck.sh <final> 3 b4_scope.sv     distinct hashes=1  NO_OUTPUT=0
```

The standing `Scoreboard/default` multi-stability flake is **REAL, PRE-EXISTING,
and attributed with reps** as the rules require:

```
Scoreboard/default, 3 runs each
  PRISTINE 2372ca52…  496d6b56 / a5927f09 / 496d6b56   distinct=2   bytes 11133677 (all 3)
  PATCHED  0d39f5e5…  163e8524 / 2d8e07e9 / 86262614   distinct=3   bytes 11133687 (all 3)
```

**Both** binaries are multi-stable, so the flake is not this patch. The byte SIZE
is stable within each binary and differs by a deterministic **+10 bytes** — which
is what keeps the Scoreboard mover attribution valid despite the unstable hash,
and is consistent with the 5 added `vpiSigned` flags that `mv63.sh` reports for
that database. (Cross-check: my pristine 40a7068 size, 11133677, is exactly the
size r10uvm62 recorded for its own *patched* binary. The base is what it claims.)

---

## 4. THE MOVERS, PER SHAPE, BY MULTISET

`mv63.sh <golden> <pristine> <patched>` reports the multiset distance to golden
before and after, ADDED and REMOVED **separately and never netted**, the ADDED
shapes normalised, and a three-way count of each added line text.

**All 7 movers, not a sample:**

```
row                          dist pristine  dist patched   gain  ADDED  REMOVED  ADDED shape
default/SimpleUVM              144529        144534         -5     5       0     |vpiSigned:1
testflags/SimpleUVM            144525        144530         -5     5       0     |vpiSigned:1
default/Scoreboard             134813        134818         -5     5       0     |vpiSigned:1
default/BuildUVMPkg             81221         81227         -6     6       0     |vpiSigned:1
testflags/BuildUVMPkg           81221         81227         -6     6       0     |vpiSigned:1
default/SeqDriver              367728        367723         +5     5       0     |vpiSigned:1
testflags/SeqDriver            367728        367723         +5     5       0     |vpiSigned:1
                                                            ---    --      -
                                                                  38       0
```

`BuildUVMPkg`'s two modes produce the **same database bytes** (patched md5
`fa9c60887ef3` in both), which is why their numbers are identical; `SeqDriver`'s
two modes differ in bytes but not in this law's effect.

**ADD-ONLY HOLDS on every row: REMOVED = 0, and the only ADDED shape anywhere is
`  |vpiSigned:1`.**

### THE MULTISET DISTANCE ROSE ON FOUR ROWS AND FELL ON ONE. That is the INSTRUMENT, and it is measured rather than excused.

`msdist.sh` compares **multisets of line TEXTS**. `  |vpiSigned:1` is one of the
commonest lines in a UVM dump and every instance is interchangeable to a
multiset, so the sign of the "gain" depends only on which side already had a
surplus of that text:

```
row                    [  |vpiSigned:1]   golden  pristine  patched   which way the distance moves
default/SimpleUVM                          2155     2440     2445     ours ALREADY +285 -> RISES
testflags/BuildUVMPkg                      1979     2287     2293     ours ALREADY +308 -> RISES
testflags/SeqDriver                        3514     3351     3356     ours was -163    -> FALLS
```

**Same patch, same law, opposite sign — and the sign is predicted exactly by the
three-way count.** The multiset cannot see *which* object holds a line; that is
precisely the blindness `uhdm-cmp` does not have. So the `gain == ADDED`
arithmetic is **reported, never used as a pass/fail** (the instrument was
corrected mid-pass to say so, and to print the three-way count instead of a
verdict). The 285/308 surpluses are a *different* law over-stamping `vpiSigned`
elsewhere; ranked R4 and untouched here.

### PER-OBJECT ACCOUNTING — every candidate named, including the non-movers

`acct63.py` lists every index-slot typespec in a real database with its
`vpiSigned` state on all three sides. `default/SimpleUVM`, 104 index-slot keys,
the 7 signed-atom ones:

| slot | span | source | golden | pristine | patched | verdict |
|---|---|---|---|---|---|---|
| OUTER | `312:48` | `uvm_recorder.svh:312 [integer]` | `1` | – | `1` | **MOVED — THE HEAD** |
| OUTER | `386:47` | `uvm_tr_stream.svh:386 [integer]` | `1` | – | `1` | **MOVED** |
| OUTER | `50:47` | `uvm_sequencer_base.svh:50 [int]` | `1` | – | `1` | **MOVED** |
| OUTER | `53:47` | `uvm_sequencer_base.svh:53 [int]` | `1` | – | `1` | **MOVED** |
| OUTER | `144:31` | `uvm_sequence_base.svh:144 [int]` | `1,1` | `1` | `1,1` | **MOVED ×1** (two objects at one span) |
| OUTER | `955:38` | `uvm_resource.svh:955 [int]` | `1` | `1` | `1` | unchanged — already correct |
| INNER | `955:38` | same object via the marker slot | `1` | `1` | `1` | unchanged |

```
OCCURRENCES MOVED = 5   HELD-BACK = 0
```

**`OCCURRENCES MOVED = 5` equals the `ADDED = 5` line count `mv63.sh` reports for
the same database, and `diff pristine.dump patched.dump` names the same five
objects. Three instruments, one number.**

**HELD-BACK = 0 is the strongest statement in this pass**: there is no index
typespec anywhere in that database that golden signs and we still leave unsigned.

**`acct63.py` was CORRECTED mid-pass and the correction is the finding worth
keeping.** Its first version read each span's *fullest* listing occurrence — the
rule `ct63cells.py` uses on the arms — and reported **4** moved objects against a
dump diff showing **5** added lines. The cause is a **same-span collision**:
`uvm_sequence_base.svh:144` has **two distinct typespec objects at the identical
span** (def view and elab view), one already signed by another producer. Picking
one occurrence silently merged the pair and hid a genuine mover. It now reports
every occurrence as a **vector** (`[1,-] → [1,1]`), so a collision is visible
instead of resolved. The arms keep one declaration per line so this cannot arise
there — but a real database is not an arm, and *the discrepancy between two
instruments is what caught it*, not a code reading.

---

## 5. THE HEAD, BEFORE AND AFTER

```
TEST         MODE       PRISTINE            PATCHED
SimpleUVM    default    14  1 head          31  1 head   <- briefed head CLEARED
SimpleUVM    testflags  14  1 head          31  1 head   <- briefed head CLEARED
Scoreboard   default    14  1 head          31  1 head   <- briefed head CLEARED
Scoreboard   testflags  SKIP-NOFILE (SLANG_REJECT, no database — reported, not hidden)
SeqDriver    default/testflags  85 -> 85    (another law; bytes moved)
BuildUVMPkg  default/testflags  58 -> 58    (another law; bytes moved)
```

**14 → 31 is NOT a regression.** Head depth is a SUBTREE size and is not
monotone — the campaign's standing law. The head **OBJECT** changed identity, and
all three rows now head on the *same* new object:

```
PRISTINE head (all 3 rows):
  integer_typespec @312:48-312:55   golden |vpiSigned:1 / ours nothing      <- CLEARED

PATCHED head (all 3 rows, identical object):
  LHS: integer_var: (uvm_pkg::uvm_recorder::get_handle::handle) @343:18-343:24
       |vpiParent -> assignment @343:18  |vpiTypespec -> integer_typespec @343:10
       |vpiName:handle  |vpiSigned:1
  RHS: <null>
```

`RHS: <null>` — **we emit no object at all**. Source:
`uvm-1.2/src/base/uvm_recorder.svh:343`, `integer handle = get_inst_id();` — a
**function-local variable declared with an initialiser inside an `else begin`
block**. This is a MISSING-OBJECT defect that was masked behind the signedness
head; it is not created by this pass (the patch's only possible dump effect is an
added `vpiSigned` line, and `REMOVED = 0` on every mover proves nothing was
dropped). Ranked **R1**.

---

## 5.1 REBASE-CHECK — **r10svs9 LANDED MID-PASS**, and it moves the SAME seven UVM databases

The brief listed r10svs9 as live and asked for a rebase-check. **It landed while
this pass was measuring**: `auto5h` advanced from my base `40a7068` to
**`2ee7a58`** (§ parensLessEventPathBaseRef9), and its own commit message says
*"seven UVM databases moved on the same law"* — **the same seven databases this
pass moves**. That is a potential collision and was treated as one rather than
assumed away.

**Textual overlap**: r10svs9 touches `src/StmtEmit.cpp` (+113) and
`include/UhdmExporter.h` (+17). This pass also touches `include/UhdmExporter.h`.
`git apply --check` onto `2ee7a58` reports **rc=0**, all 23 files, no conflict.

**Behavioural check — not inferred from the file list, MEASURED.** Two fresh
builds at the new tip, and the three target rows re-run against golden:

| binary | md5 | base |
|---|---|---|
| rebased PRISTINE | `875d3cd6218c135a8fcc6da3c4c3cf19` | `2ee7a58` |
| rebased PATCHED | `e4314e391fcb436653a69953a12d821b` | `2ee7a58` + this patch |

```
ON TOP OF r10svs9 (2ee7a58)        PRISTINE          PATCHED
  SimpleUVM  default               14  1 head        31  1 head
  SimpleUVM  testflags             14  1 head        31  1 head
  Scoreboard default               14  1 head        31  1 head
  Scoreboard testflags             SKIP-NOFILE (SLANG_REJECT) — reported, not hidden

rebased PRISTINE head : integer_typespec @312:48-312:55 |vpiSigned:1  <- STILL the briefed head
rebased PATCHED  head : integer_var (uvm_pkg::uvm_recorder::get_handle::handle)
                        @343:18, RHS: <null>                          <- the SAME successor head
whole-row CSV diff, rebased pristine vs rebased patched : IDENTICAL
```

**NO COLLISION.** r10svs9 does not touch the index typespec, this pass does not
touch event controls, and the two laws compose: on the new tip the briefed head
is still present before the patch and still cleared after it, with the identical
successor head. The gate numbers in §3 were measured at my declared base
`40a7068`; this section is the evidence that they carry forward to `2ee7a58`
unchanged.

---

## 6. RANKED RESIDUES

**R1 — the new head on all three target rows: a function-local `integer handle =
get_inst_id();` emits NO variable object.** `uvm_recorder.svh:343`, inside
`function integer get_handle()`'s `else begin` block. Golden emits an
`integer_var` parented to the initialiser `assignment`; we emit nothing, so
`RHS: <null>`. One object, three rows, and it is the next head. Highest value in
this cluster by a wide margin.

**R2 — `bit`-family index kinds come out `logic_typespec`.** Golden's index
object for `[bit]`, `[bit [7:0]]` and `[bit signed [7:0]]` is a
**`bit_typespec`**; ours is `logic_typespec` (b1 c12/c16/c18, b2 m12/m16/m18,
b4 p08 — class, module AND package, so the module-twin table is already here).
`VpiType` is a compared field. The producer is `assocIndexTs`'s `ic.isIntegral()`
fallback, which mints `MakeLogic_typespec()` for every integral kind. **Not
touched here**: it is a KIND defect, not a signedness one, and this pass ships
one head.

**R3 — signed packed-vector indices are unsigned on our side.** `[logic signed
[7:0]]` reads golden `logic_typespec` + `vpiSigned:1` against our
`logic_typespec` + absent (b1 c19, b2 m19); `[bit signed [7:0]]` is wrong in both
kind and signedness (c18/m18). Same producer as R2, the `isIntegral()` fallback.
**Deliberately NOT absorbed**, and the reasoning is measured: the corpus census
found **zero** occurrences of a signed packed-vector index in either corpus, so
shipping it would be an unmeasured-in-corpus change; and for the `bit` half the
KIND is already wrong (R2), so signing it would clear no cmp line. It is a
sibling of r10oth9's recorded R1 residue but a **different producer** (`assocIndexTs`,
not `makeTypespec`) — do not merge the two without measuring both.

**R4 — we carry a SURPLUS of `vpiSigned` somewhere else.** `default/SimpleUVM`
has 2440 `  |vpiSigned:1` lines against golden's 2155 — **285 too many**, before
this pass. §4 quotes it because it is what makes the multiset distance rise on a
correct add. Some other law stamps `vpiSigned` on objects golden leaves bare; a
pass that finds it would move four of these five distances the other way.

**R5 — `int signed` / `byte signed` index SPAN.** Golden spans the index typespec
at the **keyword alone** (`39:21-39:24` for `int signed`) while we span the whole
`int signed` (`39:21-39:31`); b1 c20/c21, b2 m20/m21. Inconsistent with
`int unsigned`, where golden spans the *whole* phrase and we match. Our objects
now carry the correct `vpiSigned`, so this is span only.

**R6 — dyn-container-typedef index objects live at the wrong place.** For
`typedef int T[integer]; T q;` golden's index typespec is the **typedef's own**
object (spanned at the typedef, parented to it, and shared by every user); we
mint a fresh one at each USE site (b4: golden at `?line32`, ours at `?line46`,
`?line50`, `?line55`). Object identity, not a field. Related: at **module** scope
we emit **no INNER index typespec at all** for a multi-dim assoc array (b3
`g10`..`g13` all `-NOOBJ-`), and no index object for a class-handle index
(`g09_cls`).

**R7 — `struct_typespec` index loses `vpiParent`** (b3 `?line23`): golden parents
the typedef's `struct_typespec`, we do not. One cell, unrelated producer.

**R8 — arm-only, and it is a NEW head I exposed in arm b4, not in the corpus.**
With the package cells fixed, b4's head becomes `array_var (pk63::p01_integer)`:
golden carries `|vpiSigned` on the **array_var** at PACKAGE scope and we carry
none. That is § arrayVarSignedWritten8's carrier, whose law was measured over
class properties and module variables; **package scope was evidently not in that
table.** No corpus row exercises it (gates 3 and 4 are at 0 differing rows), so it
is recorded, not fixed.

---

## 7. HOW TO RE-RUN

```
ct63arm.sh <arm.sv> <wd>            # golden + ours + dumps + cmp; GOLDEN_ONLY=1 for golden alone
                                    # SLANG_UHDM is NEVER defaulted
ct63cells.py <arm.sv> <g.dump> <o.dump>    # THE GRID, per cell, both sides
acct63.py <g.dump> <p.dump> <q.dump>       # per-object mover accounting on a real database
census63.sh <workdir> <out>         # the corpus mover PREDICTION
mv63.sh <golden> <pristine> <patched> <label>   # per-shape movers, ADDED/REMOVED, three-way count
byteverify.sh <patched-wd> <pristine-wd>        # SELFCHECK=1 SELFCHECK1=1 are mandatory
ct8rows.sh <baseline.csv> <fresh.csv>           # whole-row gate, dump column included
ctcan2.sh / canaries.sh / canaudit.sh           # canaries, and the audit of the canaries
detcheck.sh <bin> <N> <args...>                 # determinism
rowheads.sh <workdir> <out> <name>...           # heads for named rows
```

Arms: `b1_idxkind.sv` (class, 21 index kinds), `b2_modtwin.sv` (module twin of
all 21), `b3_named.sv` (typedef indices + the multi-dim INNER slot),
`b4_scope.sv` (package, dyn-container typedef, interface).

**BOUNDARIES HONOURED.** § arrayElemTsSignedParented9 owns the ELEMENT typespec
and was not touched — its `predefIntTypespec` call site in `emitClassDefn` is
read but unmodified, and this pass's law is deliberately *narrower* than its
sibling (no `vpiParent`, no typedef gate), both differences measured. r10oth9-R1
(signed bit/logic ELEMENT typespecs via `makeTypespec`) was **not absorbed**; its
index-position sibling is ranked R3 with the module-twin table attached, so a
future pass has the evidence without this one having taken the risk.
§ bitsOwnClassPropFold61 and § endBlockLabelAllOwners62 untouched.
§ arrayElemTdClone42's INDEX half returns *above* the arm this pass changed, so a
typedef'd index never reaches it — read, then verified by arm b3's typedef cells
being unchanged. **r10svs9 landed mid-pass and was rebase-checked by building it:
no collision, §5.1.** No collision with r10earl34 either: the patch touches
index-typespec signedness and nothing in hier_path naming.

`git stash` was never used by this pass. `git stash list` in the repo shows two
entries; both predate this session and belong to other worktrees
(`worktree-wf_83e72744`, `worktree-wf_b605ddcc`). They are recorded here so the
next reader does not mistake them for this pass's.
