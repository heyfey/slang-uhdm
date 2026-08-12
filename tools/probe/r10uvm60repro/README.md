# r10uvm60 — the head **CLEARED AND ADVANCED on all THREE target row-modes**, and **the brief's difference (3) — "vpiConstType 9 vs ABSENT" — was MEASURED FIRST and came back REFUTED: both sides stamp 9, the dump just prints ours after a nested block**

**FIRST LINE, as the brief demands.** `SimpleUVM` and `Scoreboard` **DID NOT
CONVERT**: they are `CMP_NOTEQUAL` before and after, and the surelog scoreboard
is **unchanged at 467/13 (default) + 463/10 (testflags)**, `0` differing ROWS
against the committed baseline. What DID happen is that the briefed head is
**gone on all three target row-modes** and each advanced to a **different law's**
head:

| row | mode | cmp lines | heads | verdict |
|---|---|---|---|---|
| **SimpleUVM** | **default** | 50 → **42** | 1 | **head CLEARED, advanced** |
| **SimpleUVM** | **testflags** | 50 → **42** | 1 | **head CLEARED, advanced** |
| **Scoreboard** | **default** | 50 → **42** | 1 | **head CLEARED, advanced** |
| BuildUVMPkg | default / testflags | 58 → 58 | 1 | head unchanged (another law); **bytes moved** |
| SeqDriver | default / testflags | 85 → 85 | 1 | head unchanged (another law); **bytes moved** |
| Scoreboard | testflags | — | — | SKIP-NOFILE (`SLANG_REJECT`, no database — reported, not hidden) |

ONE law landed — **§ tfBodyConstArgNoFormalTs60** with its predicate
**§ tfBodyConstArgNeedsEvaldBody60** — **7 byte movers** (the seven UVM row-modes
that produce a database), **988 ADDED / 7832 REMOVED** dump-line instances,
**0 real OVER-FIRES** (the 7 reported are the 7 injected SELFCHECK shapes), and
**981 spurious `ref_typespec` objects deleted** design-wide with the constants
they hung on resized back to Surelog's written width.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; `arm60.sh` prints that it did on every run.

Base **904fbd8**. Worktree `.claude/worktrees/r10uvm60`; pristine control
worktree `.claude/worktrees/r10uvm60pris`, configured and built by me at the same
commit. `git -C .claude/worktrees/r10uvm60 rev-parse HEAD` and the same for
`…pris` both print `904fbd8bf75ea7284f4ea7d4f17ef3ef44994321`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 904fbd8) | `68a223dae1fb08b6ce4dacccf947efe6` | my own build of 904fbd8 — **byte-identical to the main tree's `build/slang-uhdm` as it stood at 12:19**, which is what makes it a valid control |
| **FINAL (shipped)** | **`cfaeff91ad25b0c0f513c764ea1039bc`** | every gate number below was measured on THIS binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) were **READ ONLY** — row counts are
lines-minus-one because `wc -l` counts the header. The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched (`canaudit.sh`: FENCE-BREACH=0). `GOLDEN_DEFER` left UNSET: **5
DEFERRED** in both surelog modes, as in the baseline.

**TWO OPS FACTS, DISCLOSED.**

1. **A first gate-4 sweep ran the WRONG BINARY and was thrown away.** Launched as
   `SLANG_UHDM=$PWD/... setsid nohup python3 …` in a compound command, the
   surelog sweep's `cmds.txt` recorded
   `slang: /home/heyfey/git-repos/slang-uhdm/build/slang-uhdm` — the MAIN TREE's
   binary, not my worktree's. It was caught by the standing rule *print and
   grep-check every binary*: `grep -o "slang:.*slang-uhdm" cmds.txt` on the
   produced workdir. The sweep was deleted and re-run with
   `setsid nohup env SLANG_UHDM=<absolute> …`, verified the same way before any
   number was read. **No gate number in this document comes from that sweep.**
2. **The MAIN TREE MOVED under me mid-pass** (r10svs5 landed: HEAD `80892a3`, a
   fresh `build/slang-uhdm` md5 `7067d4c9…` at 12:24). That is why the discarded
   sweep's databases differed from pristine at all — and it is also why the
   control claim above is time-stamped. My worktrees stay pinned at **904fbd8**,
   the brief's base, and the deliverable diff is against 904fbd8.

---

## 0. THE LAWS, in a form a future pass can grep for

### § tfBodyConstArgNoFormalTs60

*A **CONSTANT** actual of a call written **inside a subroutine body** carries the
formal's `ref_typespec` — and is resized to the formal's width — **only when
Surelog's evaluator actually RAN that body**. Everywhere else it stays exactly
what the literal's own written form makes it: a bare unsized decimal is
`UINT:<v>` at **size 64** with `vpiConstType 9`, and it carries **NO typespec at
all**.*

* **DIRECTION**: **REMOVE ONLY** at the sites it fires on — it deletes a
  `ref_typespec` and restores a `vpiSize`. It adds no object anywhere: measured
  **988 ADDED line instances** across 7 movers, every one of them the *text* of a
  restored `|vpiSize:64` / re-keyed parent line, and **0 real over-fires**.
* **PREDICATE**: `constArgBodyEvald60` (`src/ExprEmit.cpp` ~10173) =
  `currentSubSym && subBodyEvaluated60(*currentSubSym)`.
* **STATED GATE == CODE GATE.** Read off the source, not the comment: the
  `argCtxOk` arm that stamps constants inside a subroutine body now reads
  `(!pkgScopeInst && callArgDepth == 1 && a->UhdmType() == UHDM::uhdmconstant &&
  constArgBodyEvald60 && !intFormal)` — **one added conjunct, nothing else
  touched**. The `pkgTopEmit` arm above it is UNCHANGED (it already carried
  `pkgBodyEvald9`, the one-hop form of the same idea).
* The formal-width **resize** and the **signed re-encode** live INSIDE the same
  `if`, so suppressing the stamp suppresses the resize by construction — which is
  why one conjunct fixes both cmp-visible fields.

### § tfBodyConstArgNeedsEvaldBody60

*The set of bodies Surelog's evaluator descends into is the **TRANSITIVE
CLOSURE** over call edges of two seeds: a subroutine called as the **DIRECT rhs
of a continuous assignment**, and a subroutine called inside a **parameter
initialiser**. Two levels deep still counts.*

* **IMPLEMENTATION**: `UhdmExporter::subBodyEvaluated60` (`src/TaskFuncEmit.cpp`
  ~537), one cached `std::set`, built once on first use. Seeds are the existing
  `contAssignRhsCallees9` / `paramInitCallees9` sets (both design-wide), forced
  into existence by calling `pkgSubCalledAsContAssignRhs` /
  `pkgSubEvaluatedFromParamInit` once; the closure then walks each seed body's
  `CallExpression`s.
* **WHY TRANSITIVE, and it is not a guess**: `b6_reached.sv` row R5 — `r5_inner`
  is called ONLY by `r5_outer`, and only `r5_outer` is a cont-assign rhs. Golden
  **stamps** `g60(1)` inside `r5_inner`. A one-hop predicate calls that cell bare
  and **under-fires** on it.
* `grep -rn 'tfBodyConstArgNoFormalTs60\|tfBodyConstArgNeedsEvaldBody60\|subBodyEvaluated60\|constArgBodyEvald60\|evaldBodies60' include/ src/`
  → **15 hits across 3 files**.

### The decoded mechanism (read, not guessed)

uvm-1.2's `uvm_error(ID, MSG)` expands to
`uvm_report_error (ID, MSG, UVM_NONE, `uvm_file, `uvm_line, "", 1);`, and
`uvm_report_error`'s **seventh formal is `bit report_enabled_checked = 0`**
(`uvm_globals.svh:215`, `uvm_report_object.svh:186`). Slang propagates that
1-bit type into the literal, so `expr.type->getBitWidth()` is 1; our arg-typespec
site then *also* forced `VpiSize(formal width)` and hung the formal's
`bit_typespec` on the literal through a fresh `ref_typespec` whose `vpiFullName`
is the **enclosing method's** (`uvm_pkg::uvm_get_to_lock_dap::set`) — the "method
name on an integer literal" the brief flagged. Surelog performs no such binding
for a body it never evaluates: it keeps `compileConst`'s own answer, `UINT:1` at
size 64, `vpiConstType 9`, no typespec.

---

## 1. THE BRIEF, CLAIM BY CLAIM — one REFUTED, one reclassified

| brief's claim | verdict | measurement |
|---|---|---|
| (1) LOCATION: golden 150:156 vs ours 149:331 | **CONFIRMED, and cmp-INVISIBLE** — filed as dump-only residue **R1** with its mechanism named in §5 | `b7_multiline.sv` reproduces it; the arm is **CMP EQUAL with a 44-line multiset delta that is ENTIRELY `line:`/`endln:` fields** |
| (2) SIZE 64 vs 1 — COMPARED | **CONFIRMED and FIXED** | span-free cell proof: `CLASS_METHOD UINT size=1 ct=9 TS` golden **0**, pristine **143**, final **0**; the same 143 land in `size=64 ct=9 bare` (1503 → 1646) |
| (3) `vpiConstType` **9 vs ABSENT** | **REFUTED** | **both sides stamp 9.** The brief read the dump's nesting: our `vpiConstType:9` prints *after* the `vpiTypespec:` block, so it looks absent. `argts60` reads the FIELD: pristine `ct=9`, golden `ct=9`. § enumSubstIntConst30's boundary is therefore never crossed — no const-type writer was touched |
| (4) SPURIOUS `ref_typespec` naming a METHOD | **CONFIRMED and FIXED** | it is the FORMAL's `bit_typespec` (`uvm_globals.svh:215:32`) hung by our arg-typespec site; the `vpiFullName` is the enclosing scope's by that site's own naming rule |
| "at least TWO are cmp-visible" | **CONFIRMED** — exactly two (size, typespec); the const type was never a difference and the spans are not compared | 50-line head → 42-line head, a different object |
| "FOUR differences … may be more than one law" | **ONE law, not four** | one added conjunct removes the typespec AND restores the size; the location is a separate, cmp-invisible mechanism |

---

## 2. THE GRID, cell for cell

All arms live in this directory; `arm60.sh <arm.sv> <out> <bin>` builds golden +
ours and cmps (LHS golden first), `arm60e.sh` is the same with `-elabuhdm` /
`--elabuhdm` on both sides. `argts60 <db> rows` prints one line per call actual
(scope, kind, size, value, `vpiConstType`, typespec) — the instrument every table
below is read from.

### 2.1 Before: what the arms measured on the PRISTINE binary

| arm | axis | golden | pristine ours |
|---|---|---|---|
| `a1_witness.sv` | the head, minimally: two-line macro body, `1` on a `bit` formal, class method in a package | `size=64 ct=9 ts=-` | `size=1 ct=9 ts=bit_typespec` — **the head reproduced with a 9-line multiset delta and nothing else** |
| `b1_scope.sv` | **scope**: class method / pkg function / module function / module always / `new` / static / extern-oob / `$unit` class | **every cell bare, size 64** | stamped in class method, `new`, static, `$unit` class **and module function**; bare in pkg function, module always, the oob twin |
| `b2_formal.sv` | **formal type**: `bit`, `logic[3:0]`, `int`, `byte`, `string`, `bit[63:0]`, `logic`, `byte signed` | **every cell bare, size 64** (string 8) | stamped+resized for every VECTOR formal (1, 4, 64, 1); `int`/`byte`/`string` already bare |
| `b3_actual.sv` | **actual form**: `1`, `1'b1`, `64'd1`, `4'd1`, `'1`, `1+1`, var ref, localparam ref, enum member | bare, sizes **64 / 1 / 64 / 4 / -1**, ct **9 / 3 / 1 / 1 / 3** | every constant resized to **1** and stamped; the three refs and the operation already bare |
| `b4_macro.sv` | **macro geometry**: none / one-line body / two-line body / literal on the body's 2nd line / literal from a macro ARG / literal from a nested macro | bare, size 64, **all six identical** | stamped+resized, **all six identical** → **the macro is NOT the discriminator** |
| `b5_negctl.sv` | NEGATIVE CONTROL: module CA/always/pkg-CA-rhs/body-op cells | — | **dumps byte-identical, cmp EQUAL, before and after** |
| `b6_reached.sv` | **THE DISCRIMINATOR** (below) | — | — |

### 2.2 `b6_reached.sv` — the discriminator, and the cell that refuted "class methods"

Same call `g60(1)` (bare `1`, `logic [3:0]` formal) in six bodies; only how the
body is REACHED changes. Golden, def view:

| row | how the body is reached | golden | pristine ours | FINAL ours |
|---|---|---|---|---|
| R1 | **is** a continuous-assign rhs | **STAMPED, size 4** | stamped, size 4 | **stamped, size 4** ✓ |
| R2 | called from `always_comb` | **bare, size 64** | stamped, size 4 ✗ | **bare, size 64** ✓ |
| R3 | called from `initial` | **bare, size 64** | stamped, size 4 ✗ | **bare, size 64** ✓ |
| R4 | called from a `localparam` initialiser | **STAMPED, size 4** | stamped, size 4 | **stamped, size 4** ✓ |
| R5 | **two levels** under a cont-assign | **STAMPED, size 4** | stamped, size 4 | **stamped, size 4** ✓ |
| R6 | class method as a cont-assign rhs | **cell CANNOT EXIST** — slang rejects it (`-Wdynamic-non-procedural`); the method is never reached, both sides bare | bare | bare |

R2/R3 are the head's shape in a **module function**, with no class and no macro
anywhere: `arm60.sh b6_reached.sv` is a **second, 71-line witness of the same
head**. R5 is the cell that forced the predicate to be TRANSITIVE. R6 is why the
first hypothesis — "a class method never stamps" — is **the wrong law even though
it clears the head**: class-ness is not the discriminator, unreachability is, and
a class method is merely unreachable *by the language*.

### 2.3 After: every arm, both views

| arm | def-view multiset distance to golden (pristine → FINAL) | elab-view |
|---|---|---|
| `a1_witness` | 9 → **0** (byte-identical) | cmp EQUAL |
| `b1_scope` | 45 → **0** | — |
| `b2_formal` | 68 → **0** | cmp EQUAL |
| `b3_actual` | 43 → **0** | — |
| `b4_macro` | 54 → **0** | — |
| `b5_negctl` | **0 → 0** (untouched control) | **0 → 0** |
| `b6_reached` | 28 → **10** (residue R2: a `class_var` / `class_typespec` END COLUMN, unrelated) | cmp EQUAL |
| `b7_multiline` | — → **44, all of it `line:`/`endln:`** (residue R1) | — |

Every arm that had a head has **cmp lines 0 / heads 0** on the final binary.

### 2.4 The SIZE and CONST-TYPE policy the grid establishes

Golden's constant actual, in a body it did not evaluate, is **exactly
`compileConst`'s answer for the written token** and nothing about the call
matters:

| written actual | golden `vpiSize` | golden value | golden `vpiConstType` |
|---|---|---|---|
| `1` (unsized decimal) | **64** | `UINT:1` | **9** (vpiUIntConst) |
| `1'b1` | 1 | `BIN:1` | 3 |
| `64'd1` | 64 | `DEC:1` | 1 |
| `4'd1` | 4 | `DEC:1` | 1 |
| `'1` | **-1** | `BIN:1` | 3 |
| `"s"` | 8 | `STRING:s` | 6 |
| `null` | 64 | `UINT:0` | 11 |

So the brief's "64 suggests time/longint context" is **refuted**: 64 is simply
Surelog's encoding of an **unsized decimal literal** (the same rule
§ enumSubstIntConst30 records for `UINT:` at size 64 → const type 9), and the
formal's type does not enter. In an **evaluated** body the formal's width DOES
overwrite it (`loop(2)` → `UINT:2` at size 4) — that is § tfBodyConst-
ArgNeedsEvaldBody60's whole content.

---

## 3. THE FIVE GATES, each number measured on `cfaeff91…`

### GATE 1 — BUILD

```
BUILD DIR (absolute): /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10uvm60/build
link lines ('Linking CXX executable slang-uhdm'): 1
compiler errors (' error:'):                      0
worktree HEAD: 904fbd8bf75ea7284f4ea7d4f17ef3ef44994321
pristine HEAD: 904fbd8bf75ea7284f4ea7d4f17ef3ef44994321
```

The md5 assertion ran as a **SEPARATE command**, with the baseline validated as
32 hex characters first:

```
BASELINE md5 is 32 hex: OK
CONTROL(pristine 904fbd8) = 68a223dae1fb08b6ce4dacccf947efe6
FINAL                     = cfaeff91ad25b0c0f513c764ea1039bc
MD5 CHANGED: PASS
```

`detcheck.sh` on the FINAL binary, SimpleUVM's own command line, 3 runs:
**1 distinct hash, 0 NO_OUTPUT** — the fix is deterministic (it adds a
pointer-keyed `std::set` used only for MEMBERSHIP, never iterated for output, so
the alias-population trap in the campaign memory does not apply).

### GATE 2 — GOLDENS

```
SLANG_UHDM=<final> ./tests/check_goldens.sh   rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false ./tests/check_goldens.sh rc=1  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir`

```
testflags  679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump       496 match      183 differ        52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv -> 0 differing ROWS (0 diff row-sides)
baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
PASS: every row byte-identical to the committed baseline
```

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

My PRISTINE sweeps of both corpora reproduce the committed baselines exactly
(**0 differing ROWS each**), which is what makes gate 5's byte comparison
meaningful.

### GATE 5 — BYTE VERIFIER, both corpora, vs my own pristine 904fbd8 build

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
             SELFCHECK 678/679 flagged         SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 7 / 953
             SELFCHECK 952/953 flagged         SELFCHECK1 = 8  (= 7 real + 1 injected)
```

The 7 movers are exactly the UVM rows that produce a database:
`{SimpleUVM, BuildUVMPkg, SeqDriver} × {default, testflags}` + `Scoreboard,default`.

### CANARIES

```
canaudit.sh canaries.sh ctcan2.sh   audited=29  UNCOVERED=0  FENCE-BREACH=0
ctcan2.sh  u2r  EXPECT_UNKNOWN=6 -> ok=1  changed=0 absent=0 unknown-patterns=6  PASS
ctcan2.sh  sl   EXPECT_UNKNOWN=1 -> ok=58 changed=0 absent=0 unknown-patterns=1  PASS
canaries.sh sl  -> ok=52 changed=0 absent=0 unknown-names=7   (the 7 u2r-only names)
canaries.sh u2r -> ok=8  changed=0 absent=0 unknown-names=25  (the 25 surelog-only names)
BY NAME: InterfaceModPort   default CMP_EQUAL/differ   testflags CMP_EQUAL/differ   OK
         BlackParrotComplex default CMP_EQUAL/differ   testflags CMP_EQUAL/differ   OK
```

---

## 4. MOVERS ATTRIBUTED — per shape, and then SPAN-FREE per owner

### 4.1 Per-shape (`mv60.sh`, = r10uvm58's `mv58.sh` reused unchanged)

```
movers=7   ADDED instances=988   REMOVED instances=7832
OVER-FIRE shapes=7   UNDER-FIRE shapes=104
SELFCHECK PASS: the injected shape was reported OVER-FIRE on every mover
```

**All 7 OVER-FIRES are the 7 injected SELFCHECK shapes — ZERO real ones.**

The **104 UNDER-FIREs are all unattributable by construction**, in two families,
and this is the honest limit of a span-keyed attributor here:

* **bare field lines** — `|vpiParent:`, `|vpiTypespec:`, `|vpiActual:`,
  `|vpiSize:1`. The standing rule applies verbatim: **never attribute a bare
  field line**, it has no owner once indentation is stripped and its count is a
  whole-database aggregate. Deleting 130–145 correct `ref_typespec` objects
  necessarily removes one `|vpiTypespec:` + one `|vpiActual:` + one `|vpiParent:`
  each, and ours already ran a **pre-existing deficit** against golden on those
  lines (`|vpiTypespec:` golden 10771 / ours 9876 AFTER, i.e. still short), so the
  correct removals read as "golden has more".
* **`\_constant: , line:149:221, endln:149:222`-style parent lines** — the text
  of these shapes CONTAINS A MACRO-EXPANDED SPAN, and golden's and our spans for
  the same object **disagree by construction** (residue R1). No span-keyed
  instrument can align them, so their counts are noise, not evidence.

### 4.2 SPAN-FREE per-owner proof (`szcmp60.py`, `szall60.sh`) — the instrument that CAN decide

Because R1 makes spans unusable as keys, the size/typespec claim is proved as a
MULTISET over span-free cells `(scope, value-prefix, vpiSize, vpiConstType,
has-typespec)`. Run for **every** mover:

```
BuildUVMPkg default/testflags : distance to golden 403 -> 139   IMPROVED
Scoreboard  default           : 405 -> 127                      IMPROVED
SeqDriver   default/testflags : 445 -> 165                      IMPROVED
SimpleUVM   default/testflags : 413 -> 127                      IMPROVED
movers examined: 7
```

SimpleUVM's table, every cell that moved (GOLD / PRIS / PAT):

| cell | GOLD | PRIS | FINAL |
|---|---|---|---|
| `CLASS_METHOD UINT size=1 ct=9 **TS**` | **0** | **143** | **0** |
| `CLASS_METHOD UINT size=0 ct=11 **TS**` (a `null` actual) | **0** | **2** | **0** |
| `CLASS_METHOD UINT size=64 ct=9 bare` | 1733 | 1503 | **1646** (= 1503 + 143) |
| `CLASS_METHOD UINT size=64 ct=11 bare` | 36 | 36 | 38 (= 36 + 2) |

The 143 + 2 objects moved **out of a cell golden holds ZERO of** and **into the
cell golden holds them in**. The last row is the only cell where our count now
exceeds golden's, and it is **pre-existing object multiplicity, not this
patch**: our total over both `ct=11` cells is **38 before and 38 after**, and at
the two positions concerned (`993:36`, `1047:40`, both non-macro) golden reads
`size=64 val=UINT:0 ct=11 ts=-` — **exactly what we now emit**.

### 4.3 The movers were PREDICTED from source-derived data BEFORE the build

`census60.sh` censuses every database a sweep produced plus its own golden and
counts the cell the law removes:

| corpus | databases | tests with a tf-body constant TS (PRISTINE) | golden's count there | FINAL |
|---|---|---|---|---|
| surelog | **953** | **7** — `SimpleUVM` 145, `Scoreboard` 141, `SeqDriver` 142, `BuildUVMPkg` 133 (×modes) = **981 objects** | **0 in all 7** | **0 tests** |
| uhdm2rtlil | **679** | **1** — `const_fold_func`, ourTS=**1** | goldTS=**1** | **still 1** ✓ |

`GOLDEN_MISSING: 0` on both runs. The prediction — **7 movers, all UVM; 0 in
u2r; the one legitimate cell preserved** — is exactly what gate 5 then measured.
And a **400-golden sample of the corpus** (`argts60`, method calls included) says
the same thing about golden itself:

```
constants as call actuals, golden, 400 databases:
  CLASS_METHOD  40095 bare / 0 TS      PKG_FUNC  35084 bare / 0 TS
  MOD_FUNC         24 bare / 0 TS      TF_ORPHAN     14 bare / 0 TS
  CLASS_BODY       11 bare / 0 TS      MOD_BODY     288 bare / 68 TS
```

**Zero** constant actuals inside ANY subroutine body carry a typespec in that
sample; the only stamped constants live at module-body level. The `const_fold_func`
cell is the whole-corpus exception, and it is an EVALUATED body — which is the
law.

---

## 5. RANKED RESIDUES

| # | residue | evidence | why not fixed here |
|---|---|---|---|
| **R1** | **MACRO-BUFFER LOCATION**: for a macro whose **INVOCATION ARGUMENTS SPAN SOURCE LINES**, golden's expanded-buffer column WRAPS onto the macro definition's NEXT line while ours keeps accumulating on the same line — golden `150:156`, ours `149:331`; golden's `func_call` ends `150:158`, ours `149:333` | `b7_multiline.sv`: golden's four trailing literals sit at `15:51, 15:83, 15:159, 16:58`, ours at `15:51, 15:83, 15:109, 15:159`. The arm is **CMP EQUAL** with a **44-line delta that is entirely `line:`/`endln:`** | **Dump-only**: 233 Compare methods read zero location fields. It is ALSO the reason §4.1's attributor cannot key those lines. Fixing it means re-deriving macro columns (`getFullyOriginalRange`) and the campaign memory warns this family is order-sensitive under parallel parse |
| **R2** | the **NEW head** on all three target rows: golden FOLDS `$bits(m_locked)` to `UINT:1` size 64 in `print_field_int("lock_state", m_locked, $bits(m_locked))` (`uvm_get_to_lock_dap.svh:145`); we emit the `$bits` `sys_func_call` | `rh_pat2/SimpleUVM.default.cmp`, 42 lines, 1 head, identical on SimpleUVM×2 and Scoreboard | a different law ($bits fold inside a class method arg) — the highest-value next target, and it is worth **87 objects** in SimpleUVM's `size=64 ct=9` cell alone |
| **R3** | `CLASS_METHOD INT size=64 ct=7 bare`: golden 12, ours **0** (and `PKG_FUNC` 11 vs 0) — golden holds `INT:`-encoded constant actuals we never mint | `szall60.sh` tables, all 7 movers | separate law (an `INT:` encoding for negative/`int`-typed actuals); no interaction with this one |
| **R4** | `CLASS_METHOD size=0 ct=0 bare`: golden 2, ours 0 | same tables | separate law |
| **R5** | `STRING` cell drift (`size=0` 702/705, `size=8` 45/49, `PKG_FUNC size=8` 20/24) — ours emits a few more string constants than golden | same tables | object multiplicity, pre-existing, unchanged by this pass |
| **R6** | ELAB-view twin: `MOD_FUNC ref_obj TS` +1 and 2 extra class-method constant copies in `b6_reached`'s elab listing | `argts60` rows diff on `p_earm_b6_reached` | def/elab duplication law, cmp-invisible here |
| **R7** | `class_var` / `class_typespec` END COLUMN for `c66 h = new();` (golden `51:17`, ours `51:9`) — b6's remaining 10-line delta | `p_arm_b6_reached` dump diff | unrelated span law, dump-only |

---

## 6. REFUTATIONS, stated plainly

1. **"vpiConstType 9 vs ABSENT" (brief difference 3) — FALSE.** Both sides write
   9. The brief was reading dump nesting, not fields. Had I "fixed" it, I would
   have written a second const-type writer over a correct one and crossed
   § enumSubstIntConst30's boundary for nothing.
2. **"This is a MACRO-BUFFER family" — FALSE for the cmp-visible half.**
   `b4_macro`'s six geometries are IDENTICAL on both sides, and `b6_reached`
   reproduces the head with **no macro at all**. The macro is real only in
   residue R1.
3. **"64 suggests time/longint context or INT sizing" — FALSE.** 64 is Surelog's
   encoding of an unsized decimal literal, independent of the formal.
4. **"A class method never binds a formal typespec" (my own first hypothesis) —
   INSUFFICIENT AND WRONG.** It clears the head, but `b2_formal`/`b1_scope` show
   the same over-fire in a **module function**, and `b6_reached` R1/R4/R5 show
   golden stamping *inside* subroutine bodies whenever it evaluated them. Landing
   the class-only gate would have left a measured over-fire in place and still
   mis-modelled the mechanism.
5. **"Delete the tf-body constant arm entirely" (the wide reading of my own
   400-golden census) — REFUTED BY THE COUNTEREXAMPLE.** `const_fold_func`'s
   `help_mul = inp * loop(2)` is a tf-body constant that golden DOES stamp
   (goldTS=1). The whole-corpus census found it before any code was written; a
   blanket suppression would have regressed a CMP_EQUAL u2r test.
6. **"One hop is enough" — REFUTED.** `b6_reached` R5 stamps two levels under a
   cont-assign.
7. **`Scoreboard,default` is NOT claimed as clean evidence of anything by
   itself** (campaign memory: recorded macro-buffer nondeterminism). It is
   reported as a mover and its head measured, alongside SimpleUVM's two
   row-modes, which are deterministic (`detcheck.sh`, 3 runs, 1 hash).

---

## 7. FILES IN THIS DIRECTORY

| file | role |
|---|---|
| `a1_witness.sv` | the head, minimal (macro + class method + `bit` formal) |
| `b1_scope.sv` … `b4_macro.sv` | the scope / formal-type / actual-form / macro-geometry axes |
| `b5_negctl.sv` | negative control: the stamping cells that must not move |
| `b6_reached.sv` | **the discriminator** (R1…R6) and a macro-free witness of the head |
| `b7_multiline.sv` | residue R1's mechanism: a multi-line macro INVOCATION |
| `argts60.cpp` | THE instrument: per-actual rows, `(scope, kind, TS)` cells, and span-free SIZECELLs; walks `Serializer::AllObjects` and counts `method_func_call`/`method_task_call` as well as `func_call`/`task_call` |
| `census60.sh` | whole-corpus prediction of the law, ours vs each test's own golden |
| `szcmp60.py` / `szall60.sh` | the span-free per-owner proof, per mover |
| `arm60.sh` / `arm60e.sh` | one arm, def view / elab view |
| `msdist.sh` | resync-immune dump distance (**verbatim from `7c7eaa6`**, md5 `7c0d46b5da124cfe37d27eddc95eb7e7`) |
| `mv60.sh` | per-shape mover attribution (r10uvm58's, unchanged) |
| `byteverify.sh`, `manifest.sh` | GATE 5, with `SELFCHECK` and `SELFCHECK1` |
| `ct8rows.sh` | the whole-row CSV gate |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canaries and the audit of the canaries |
| `detcheck.sh` | determinism of one binary on one input |

---

## 8. THE DELIVERABLE

```
/tmp/r10uvm60.patch   (git diff vs 904fbd8; its md5 is reported with the pass,
                       NOT quoted here — this file is INSIDE the patch, so any
                       md5 written here would describe a different file)
  production : src/ExprEmit.cpp  src/TaskFuncEmit.cpp  include/UhdmExporter.h
  probe      : tools/probe/r10uvm60repro/ only
```

The patch was **applied to a fresh detached worktree of 904fbd8** and the three
production files then md5-matched the files the FINAL binary was built from,
byte for byte:

```
6fcda637c0b67bc3228288a14100860d  src/ExprEmit.cpp
7f55bd589755fd604a65a980d560e05f  src/TaskFuncEmit.cpp
3396f121f5934f42b62d02534852a836  include/UhdmExporter.h
```

`results/*.csv` were never written. `git stash` was never used. The sweep
workdirs under `/tmp/r10uvm60/` were deleted after the last measurement was
read; the patch lives outside them.
