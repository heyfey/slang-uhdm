# r10uvm61 — the briefed head **CLEARED on all THREE target row-modes**, and the brief's own framing — "$bits **(and sibling sys-func)** fold" — is **REFUTED BY MEASUREMENT: `$bits` is the ONLY member of the family that folds anywhere**

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after. No conversion was
expected from this pass alone and none happened.

**SECOND LINE, and it is the number a reader will react to.** On
`SimpleUVM/default` the cmp goes **42 lines → 20 402 lines**. That is **NOT a
regression**, and I did not discover it by argument — I proved it:

* the briefed head (`constant @145:55-145:70` vs our `sys_func_call ($bits)`)
  is **GONE**;
* the newly-exposed head is a **`class_defn (uvm_pkg::uvm_set_get_dap_base)`
  SUBTREE** — 10 207 LHS lines on its own, because *a head is a SUBTREE and
  depth is NOT monotone*;
* that region of the database is **byte-identical between my pristine and my
  patched binary** (multiset of every line naming `uvm_set_get_dap_base`:
  `6f43676624650471baa8248d64c9c503` on both);
* and the **whole-dump multiset distance to golden IMPROVES**, 144 828 →
  144 580.

The strongest form of that proof is §4.2: I took the per-shape multiset delta
between the pristine and patched SimpleUVM dumps — **289 distinct shapes moved,
and every single one is a `$bits`-fold artifact; the count of shapes that are
NOT explainable as a `$bits` fold is `0`.** The patch cannot have created the
new head because the patch changed nothing outside the folds it was written to
make.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; `arm61.sh` prints that it did on every run.

Base **8633a1e**. Worktree `.claude/worktrees/r10uvm61`; pristine control
worktree `.claude/worktrees/r10uvm61pris`, configured and built by me at the
same commit. Both `git rev-parse HEAD` print
`8633a1e6dc9031e3c13862813864f900c324fdf2`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 8633a1e) | `29223f08cef6b087c932fb9b30a40bba` | my own build of the base commit |
| **FINAL (shipped)** | **`e8e672f8151fa7732b08168e6df91811`** | every gate number below was measured on THIS binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) were **READ ONLY**. The four
slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) were never dispatched. `GOLDEN_DEFER` left **UNSET**.

---

## 0. THE LAW, in a form a future pass can grep for

### § bitsOwnClassPropFold61

*Surelog reduces `$bits(X)` to a **bare unsized-decimal constant** —
`UINT:<width>`, `vpiSize` **64**, `vpiConstType` **9**, `vpiDecompile` the
digits, and **NO typespec** — exactly when **X is a SIMPLE UNQUALIFIED
identifier naming a property DECLARED DIRECTLY IN the class body that
LEXICALLY CONTAINS the method being compiled**. Nothing else about the call
matters: not the class, not the macro, not the statement nesting, not the call
whose argument the result is.*

* **DIRECTION**: **ADD ONLY** where it fires — it deletes a `sys_func_call`
  plus its argument `ref_obj` and puts one `constant` in their place.
* **PREDICATE**: `UhdmExporter::bitsOwnClassPropFold61` (`src/ExprEmit.cpp`
  ~1213), with two dedicated helpers, `readsClassParam61` (~1163) and
  `typeReadsClassParam61` (~1186).
* **STATED GATE == CODE GATE.** Read off the source, not the comment. The gate
  is a conjunction of exactly these, in this order:
  `currentSubSym` non-null · `currentSubSym->outOfBlockIndex == SymbolIndex(0)` ·
  the sub's parent scope is a `ClassType` · the argument is
  `ExpressionKind::NamedValue` · its symbol is `SymbolKind::ClassProperty` ·
  `sym.getParentScope() == home` · `r9DimsLiteral` on the type syntax and on
  each dimension syntax · `!readsClassParam61` on the same two ·
  `srlgFullySpecType` · `!typeReadsClassParam61` · and finally the width is
  derivable (`isIntegral() && getBitWidth() > 0`, or a fixed-size unpacked
  array of integral elements via `getBitstreamWidth()`).
* **THE VALUE COMES FROM THE SAME PREDICATE THAT OPENED THE GATE.** The
  pre-existing fold path evaluates the call in a ROOT `ASTContext`, which
  cannot answer for a class property (there is no instance to read). Without
  the added `staticBits9` arm the gate would open and then emit a
  `sys_func_call` anyway — the classic stated-gate/code-gate split. The arm is
  guarded by the same `ownPropFold61` flag the gate set.
* **PLACEMENT IS LOAD-BEARING**: the override sits **AFTER** the
  `if (curPkgEmitSym && !pkgEmitTopView) bitsKeep = true;` package-def guard.
  uvm-1.2 declares every class inside `uvm_pkg`, so a check placed *before* it
  is switched straight back off for the very cells the corpus needs — including
  the witness. Measured, not assumed: golden folds `$bits(m_b)` in
  `c1_pkg::inblock_c::r1` while still keeping `$bits(t)` in the package's own
  def listing (arms c1 R1 and c2 line 11).
* `grep -rn 'bitsOwnClassPropFold61\|readsClassParam61\|typeReadsClassParam61\|ownPropFold61' include/ src/`
  → **22 hits across 2 files** (`include/UhdmExporter.h`, `src/ExprEmit.cpp`).

**PATCH HYGIENE.** `git diff 8633a1e --stat` → **2 production files,
+256 / −1**. `src/TaskFuncEmit.cpp` — r10uvm60's territory, which owns
`subBodyEvaluated60` and the formal-typespec/resize stamping of constant
ACTUALS — is **untouched (0 diff lines)**, and the two laws never meet: this
predicate never reads the evaluated-body set, and pass 60's sites are call
ACTUALS rather than `$bits` calls. `grep -cE "VpiConstType|covergroup|clocking"`
over the added lines → **0**, so § enumSubstIntConst30's boundary is not
crossed and neither is r10svs7's covergroup-new recovery. r10earl32 owns
pkg-param folds in **USER**-func-call arguments; this fires only under
`name == "$bits"`, a SYSTEM call, and only for a class property — different
path, no collision.

### The FAMILY boundary — the brief's phrase "(and sibling sys-func)" is REFUTED

`c3_sibling.sv` puts **`$size`, `$clog2`, `$high`, `$low`, `$left`, `$right`,
`$countones`, `$dimensions`, `$unpacked_dimensions`, `$increment`,
`$isunknown`** on the SAME member, in the SAME in-block method, beside a
`$bits` that folds. **Golden keeps every one of them a `sys_func_call`, and so
do we — 0 differing cells.** `$bits` is the only type query that folds
anywhere in this family, so the predicate is called only under
`name == "$bits"` and no sibling writer was touched.

---

## 1. THE GRID, cell for cell

`arm61.sh <arm.sv> <out> <bin>` builds golden + ours and cmps (LHS golden
first); `arm61e.sh` is the same with `-elabuhdm`/`--elabuhdm` on both sides.
`foldgrid.sh <armdir>` prints, per SOURCE LINE, whether each side has a
`sys_func_call` (SYMBOLIC) or a `constant` (with value/size/const-type/
typespec) — censusing **both** sides for **both** shapes, so a cell present on
one side only prints `ABSENT`, never blank.

`bitscensus.py` is the corpus instrument. It is **span-free by necessity**: the
UHDM dump prints **no file per object** and uvm-1.2 is hundreds of files, so
`line:145:55` is ambiguous across the design; every key is a **scope path**.
It also **builds the indentation tree** and counts only definitional
occurrences, because the dump repeats each object under every back-reference
edge (`vpiParent`, `vpiActual`, …) and a raw `grep -c` double-counts.

### 1.1 `c1_scope.sv` — THE DISCRIMINATOR

Same question in every row — `$bits(<a class member>)` — differing only in where
the method body is written and what the operand is.

| line | row | golden | PRISTINE ours | **FINAL ours** |
|---|---|---|---|---|
| 15/16 | **in-block method, own member** (`bit`/`int`) | **UINT:1 / UINT:32**, sz 64, ct 9, bare | SYMBOLIC ✗ | **folds ✓** |
| 28/29 | **OUT-OF-BLOCK** body (`extern` + `C::m`) | SYMBOLIC | SYMBOLIC | **SYMBOLIC ✓** |
| 38/39 | function **LOCAL** | SYMBOLIC | SYMBOLIC | **SYMBOLIC ✓** |
| 40 | own member, *same body* as 38/39 | **UINT:1** | SYMBOLIC ✗ | **folds ✓** |
| 48/49 | function **FORMAL** | SYMBOLIC | SYMBOLIC | **SYMBOLIC ✓** |
| 50 | own member, same body | **UINT:1** | SYMBOLIC ✗ | **folds ✓** |
| 59/60 | **TYPE** argument (`$bits(byte)`, `$bits(tw_t)`) | UINT:8 / UINT:12 | folds | **folds ✓** (pre-existing, untouched) |
| 61 | own member, same body | **UINT:1** | SYMBOLIC ✗ | **folds ✓** |
| 71/72 | class **PARAMETER / LOCALPARAM** | SYMBOLIC | SYMBOLIC | **SYMBOLIC ✓** |
| 73 | own member, same body | **UINT:1** | SYMBOLIC ✗ | **folds ✓** |
| 84 | own **UNPACKED array** `bit m_arr[4]` | **UINT:4** | SYMBOLIC ✗ | **folds ✓** |
| 85 | own packed `logic [7:0]` | **UINT:8** | SYMBOLIC ✗ | **folds ✓** |
| 86 | own **CLASS HANDLE** | SYMBOLIC | SYMBOLIC | **SYMBOLIC ✓** |
| 93/94 | **INHERITED** member | SYMBOLIC | SYMBOLIC | **SYMBOLIC ✓** |
| 102 | `this.m_b` (explicit prefix) | SYMBOLIC | SYMBOLIC | **SYMBOLIC ✓** |

Rows 38/40, 48/50, 71/73 are the sharp ones: **the same body, the same call,
one operand folding and the next not**. That is what forces the law to be about
the OPERAND'S DECLARATION rather than about the method, the class, or the
macro. Rows 28/29 are what forces the out-of-block arm, and they are not
academic — `uvm_component::do_print`, `uvm_packer::pack_bytes`,
`uvm_transaction::do_record` and `uvm_sequencer_param_base::do_print` are all
written out-of-block in uvm-1.2 and golden keeps all 17 of their `$bits` calls.

**FINAL: `c1_scope` has ZERO differing cells.** Multiset distance to golden
**151 → 31** (def), **225 → 91** (elab).

### 1.2 `c2_context.sv` — the CONTEXT axis, and the NEGATIVE CONTROL

Package function, package local, module function, module local, module task,
`always_comb`, `initial`, continuous assign, module-level parameter
initialiser, packed-dimension bound, module variable initialiser.

**Every module/package cell already matched golden before this pass and still
does.** Our side already folds `$bits(<module var>)` in module functions,
always blocks, initials, cont-assigns and param inits, and already keeps it for
a module-function LOCAL — exactly as golden does. **The entire difference
between the two implementations was confined to CLASS bodies**, which is why
the law is a class law.

**`c2_context`'s dump is BYTE-IDENTICAL between the pristine and the patched
binary** (`cmp -s` on `o.dump`: identical), and its multiset distance is
**53 → 53**. This is the untouched control that proves the patch cannot reach
non-class code.

### 1.3 `c3_sibling.sv` — the FAMILY axis (the refutation)

| line | function on the SAME member, SAME in-block method | golden | ours |
|---|---|---|---|
| 12 | `$bits` | **folds, UINT:8** | **folds ✓** |
| 13–23 | `$size` ×2, `$clog2`, `$high`, `$low`, `$left`, `$right`, `$countones`, `$dimensions`, `$unpacked_dimensions`, `$increment` | **SYMBOLIC, all 11** | **SYMBOLIC, all 11 ✓** |
| 25 | `$isunknown` | SYMBOLIC | SYMBOLIC ✓ |
| 40–48 | the same list in an **OUT-OF-BLOCK** body, `$bits` included | **SYMBOLIC, all 9** | **SYMBOLIC, all 9 ✓** |

Multiset distance **39 → 30**; the only residual cell is line 24, a
**pre-existing and unrelated** residue (`$typename(m_pk).len()` — we drop the
method call on a `$typename` result; ABSENT on our side before and after).

### 1.4 `c4_edge.sv` — the OVER-FIRE traps

This arm is where the pass earned its keep: **two real over-fires were caught
and fixed BEFORE the patch was measured against the corpus.**

| line | row | golden | first patch | **FINAL** |
|---|---|---|---|---|
| 17 | member declared **after** the method | UINT:5 | folds ✓ | **folds ✓** |
| 27/28/29 | **`static` / `const` / `rand`** properties | UINT:6/7/10 | folds ✓ | **folds ✓** |
| 38 | parameterized class, **fixed**-width member | UINT:4 | folds ✓ | **folds ✓** |
| **39** | parameterized class, **`logic [W-1:0]`** | **SYMBOLIC** | **UINT:8 — OVER-FIRE** | **SYMBOLIC ✓** |
| 48 | **never-instantiated** param class, fixed member | UINT:4 | folds ✓ | **folds ✓** |
| **49** | never-instantiated, `logic [W-1:0]` | **SYMBOLIC** | **UINT:16 — OVER-FIRE** | **SYMBOLIC ✓** |
| **53** | `W`-dependent via a class **TYPEDEF** | **SYMBOLIC** | **UINT:8 — OVER-FIRE** | **SYMBOLIC ✓** |
| **54** | `W`-dependent via a packed **STRUCT field** | **SYMBOLIC** | **UINT:10 — OVER-FIRE** | **SYMBOLIC ✓** |
| 55 | fixed-width typedef in the same class | UINT:4 | folds | **folds ✓** |
| 59 | inside nested `if`/`for` blocks | UINT:3 | folds ✓ | **folds ✓** |
| 70 | **`super.m_base`** | SYMBOLIC | SYMBOLIC ✓ | **SYMBOLIC ✓** |
| 71 | own member of a **derived** class | UINT:4 | folds ✓ | **folds ✓** |
| 80 | the **`new` constructor** body | UINT:11 | folds ✓ | **folds ✓** |
| 95/96/97 | packed **struct** / **enum** / typedef **alias** | UINT:7/2/13 | folds ✓ | **folds ✓** |
| 98 | `string` member | SYMBOLIC | SYMBOLIC ✓ | **SYMBOLIC ✓** |
| **115** | **`real` member** | **UINT:32** | SYMBOLIC | **SYMBOLIC — declared UNDER-FIRE, see §5 R3** |
| 111 | class declared in a **MODULE**, not a package | UINT:14 | folds ✓ | **folds ✓** |

Row 71 against rows 93/94 of `c1` is the pair that pins the inheritance arm
precisely: **being in a derived class is fine; it is the MEMBER being inherited
that blocks the fold.**

Multiset distance **394 → 188** (def), **646 → 397** (elab).

**Row R1 as originally written — the member declared AFTER the querying method
— IS A CELL THAT CANNOT EXIST.** slang rejects it outright
(`error: identifier 'm_late' used before its declaration`) and the arm would
not build. Declaration order is therefore not an axis this predicate can be
wrong about: no database holding such a reference ever reaches the emitter. The
row was rewritten in declaration order and kept.

### 1.5 The VIEW axis — the law is **NOT view-split**

The campaign's prior-art note (r10oth2: *DEF view never folds an operation but
folds bare unbased literals; ELAB folds everything except two ExprEval bails*)
raised the question of whether this head sits in a view-split rule. **It does
not.** `arm61e.sh` (both sides `-elabuhdm`) on `c1_scope` and `c4_edge`
reproduces the def-view grid **cell for cell**, with the same single residual
cell (`real`). One predicate, both views, no `elabView` parameter.

### 1.6 The FOLD FORM, decoded per cell — not transcribed

The brief warned that the fold form is context-dependent (§ psBoundPkgParamTs31
measured golden *stamping* `ref_typespec` on folds in part-select bounds;
r10earl32 is measuring size-12 ct-5 typed forms in user-func-arg folds). **In
this cell it is invariably the BARE form**, and I verified it on every folding
cell of every arm and on the corpus witness, not on one example:

```
vpiDecompile:<digits>   vpiSize:64   UINT:<digits>   vpiConstType:9   (no vpiTypespec)
```

This is `compileConst`'s unsized-decimal encoding — the same form
§ tfBodyConstArgNoFormalTs60 landed one pass earlier, and the same rule
§ enumSubstIntConst30 records for `UINT:` at size 64 → const type 9. **Note it
does not vary with the member's width**: a 1-bit `bit` folds to `vpiSize:64`
`UINT:1`, not to `vpiSize:1`.

---

## 2. THE CORPUS CENSUS — predicted BEFORE coding, then measured

The brief asked for a `$bits` census on the existing UVM dumps before writing
any code, and it is what produced the law. On `SimpleUVM/default`:

| | golden | pristine ours |
|---|---|---|
| `$bits` dump-line instances | 74 | 128 |
| **distinct `$bits` sites** (scope+span, tree-deduped) | **28** | **54** |

Set-differenced by scope, that census immediately falsified the obvious
hypotheses and pointed at the real one:

* `uvm_pkg::uvm_component::do_print` holds **6 `$bits` on BOTH sides** — golden
  does not fold there, so "class methods fold" is wrong;
* `uvm_pkg::uvm_report_message::do_print` appears **on BOTH lists at once** —
  golden folds three of its four and keeps the fourth, so the discriminator is
  **per-site, not per-scope**;
* the kept one is `$bits(l_verbosity)`, a **function local**; the folded three
  are `_severity`, `_verbosity`, `_line`, all **class members**;
* and every scope where golden keeps a member's `$bits`
  (`uvm_component`, `uvm_packer`, `uvm_transaction`, `uvm_sequencer_param_base`,
  `uvm_reg_block`) turned out to be written **out-of-block** — confirmed by
  reading each definition header out of uvm-1.2.

### 2.1 The mover prediction, and what was measured

**Predicted** from that census: the fold should newly fire on the 37 in-block
own-member sites and on nothing else; `$bits(byte)`-style TYPE arguments in
`uvm_packer` are already-existing gaps and must not move.

**Measured**, pristine → final on `SimpleUVM/default`:

| | count |
|---|---|
| distinct `$bits` sites, golden | 28 |
| distinct `$bits` sites, **pristine** ours | 54 |
| distinct `$bits` sites, **final** ours | 17 |
| **sites the patch newly folded** | **37** |
| **NEW over-fires** (golden keeps + pristine kept + final folds) | **0** |

The 37 land in exactly the scopes the census named:

```
 4 uvm_barrier::do_print              7 uvm_default_report_server::do_print
 2 uvm_event_base::do_print           3 uvm_exhaustive_sequence::{do_compare,do_print,do_record}
 1 uvm_get_to_lock_dap::do_print  <-- THE BRIEFED WITNESS
 3 uvm_random_sequence::{do_compare,do_print,do_record}
 3 uvm_report_message::do_print       1 uvm_report_message::m_record_core_properties
 1 uvm_set_before_get_dap::do_print   1 uvm_simple_lock_dap::do_print
11 uvm_tlm_generic_payload::do_record
```

Two residues remain visible in that census and **both are honest, both are
under-fires, and neither is caused by this patch**:

* **17 sites golden keeps and we do not have at all** — `$bits(byte)` and
  `$bits(uvm_reg_data_t)` in `uvm_packer`/`uvm_reg_block`. These are
  **PRE-EXISTING**: the identical 17 are missing from the **pristine** dump
  (`comm -23 bits_g.key bits_pris.key` = 17). Filed as **R4**.
* **6 sites golden folds and we still keep** — all
  `$bits(m_byte_enable[i])` in `uvm_tlm_generic_payload::do_record`, an
  **ElementSelect**, not a bare name. Filed as **R2**, with its full measured
  value grid in §5 so the next pass can implement it without re-deriving it.

---

## 3. THE FIVE GATES — every number measured on `e8e672f8151fa7732b08168e6df91811`

### GATE 1 — BUILD

```
BUILD DIR (absolute): /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10uvm61/build
link lines ('Linking CXX executable slang-uhdm'): 1
compiler errors (' error:'):                      0
worktree HEAD: 8633a1e6dc9031e3c13862813864f900c324fdf2
pristine HEAD: 8633a1e6dc9031e3c13862813864f900c324fdf2
```

The md5 assertion ran as a **SEPARATE command**, with the baseline validated as
32 hex characters first:

```
BASELINE md5 is 32 hex: OK
CONTROL(pristine 8633a1e) = 29223f08cef6b087c932fb9b30a40bba
FINAL                     = e8e672f8151fa7732b08168e6df91811
MD5 CHANGED: PASS
```

`detcheck.sh` on the FINAL binary, SimpleUVM's own command line, 3 runs:
**1 distinct hash (`83a76e7a569a4951`), 0 NO_OUTPUT.** The patch adds **no
container at all** — it is pure predicate logic over slang symbols, with no map
or set to iterate — so the alias-population trap in the campaign memory cannot
apply here, and it was measured anyway.

**THE Scoreboard/default BISTABILITY FLAKE, attributed with reps as the brief
requires.** It is **REAL and PRE-EXISTING**:

```
Scoreboard/default, 3 runs each
  PRISTINE 29223f08…  hashes: 3d9ff7ae / e9f7838a / 3d9ff7ae   distinct=2   bytes 11136761 (all 3)
  PATCHED  e8e672f8…  hashes: 74b37365 / 913223a3 / 74b37365   distinct=2   bytes 11133612 (all 3)
```

Both binaries are bistable, so the flake is **not this patch**; and the byte
SIZE is stable within each binary and differs between them by a deterministic
**3 149 bytes**, which is what makes the Scoreboard mover attribution valid
despite the bistable hash.

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
as well — which is what makes gate 5's byte comparison meaningful.

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

**No conversion, as predicted and as the brief expected.** `GOLDEN_DEFER` left
UNSET: **5 DEFERRED** in both modes, as in the baseline. The pristine sweep also
reproduces the baseline at **0 differing ROWS**.

### GATE 5 — BYTE VERIFIER, both corpora, vs my own pristine 8633a1e build

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
             SELFCHECK 678/679 flagged         SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 7 / 953
             SELFCHECK 952/953 flagged         SELFCHECK1 = 8  (= 7 real + 1 injected)
```

The 7 movers are **exactly the set predicted from the source-side census** —
the UVM rows that produce a database:

```
default/{BuildUVMPkg, Scoreboard, SeqDriver, SimpleUVM}
testflags/{BuildUVMPkg, SeqDriver, SimpleUVM}
```

`0 / 679` on uhdm2rtlil is itself a prediction confirmed: that corpus has no
class method taking `$bits` of its own property.

### THE HEADS — measured on both binaries, all four UVM tests, both modes

```
TEST           MODE       PRISTINE        PATCHED
SimpleUVM      default      42  1 head    20402  1 head   <- head CLEARED
SimpleUVM      testflags    42  1 head    20402  1 head   <- head CLEARED
Scoreboard     default      42  1 head    20402  1 head   <- head CLEARED
Scoreboard     testflags    SKIP-NOFILE (SLANG_REJECT, no database — reported, not hidden)
SeqDriver      default      85  1 head       85  1 head   (another law; bytes moved)
SeqDriver      testflags    85  1 head       85  1 head   (another law; bytes moved)
BuildUVMPkg    default      58  1 head       58  1 head   (another law; bytes moved)
BuildUVMPkg    testflags    58  1 head       58  1 head   (another law; bytes moved)
```

**HEAD IDENTITY, not just head count** — this is the measurement that makes
"cleared" a fact rather than a hope. The head object's own line, read out of
each cmp:

| row | PRISTINE head | PATCHED head |
|---|---|---|
| SimpleUVM/default | `constant: , id:132727, line:145:55, endln:145:70` | `class_defn: (uvm_pkg::uvm_set_get_dap_base) …` |
| SimpleUVM/testflags | `constant: , id:132739, line:145:55, endln:145:70` | `class_defn: (uvm_pkg::uvm_set_get_dap_base) …` |
| Scoreboard/default | `constant: , id:132997, line:145:55, endln:145:70` | `class_defn: (uvm_pkg::uvm_set_get_dap_base) …` |

All three pristine heads are **the briefed object**; all three patched heads are
**a different object**. The head is **cleared, not renumbered**.

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

## 4. MOVERS ATTRIBUTED — per shape, vs GOLDEN, by MULTISET

### 4.0 All seven movers (`mv61.sh`, `REUSE=1`)

ADDED and REMOVED are line **instances**, counted separately, pristine →
patched. `UNATTRIB` is the number of changed distinct shapes that are **not**
attributable to a `$bits` fold — the column that has to be `0`.

```
TEST           MODE       | msdist to GOLDEN pris->pat    |  ADDED  REMOVED | UNATTRIB
SimpleUVM      default    |  144828 -> 144580   IMPROVED  |    190      372 |    0
SimpleUVM      testflags  |  144824 -> 144576   IMPROVED  |    190      372 |    0
Scoreboard     default    |  135120 -> 134864   IMPROVED  |    190      372 |    0
SeqDriver      default    |  368040 -> 367784   IMPROVED  |    190      372 |    0
SeqDriver      testflags  |  368040 -> 367784   IMPROVED  |    190      372 |    0
BuildUVMPkg    default    |   81417 ->  81273   IMPROVED  |    220      432 |    0
BuildUVMPkg    testflags  |   81417 ->  81273   IMPROVED  |    220      432 |    0
movers examined: 7   SKIPPED: 0
```

**Every mover IMPROVES against golden, and on every one of the seven the
unattributable count is ZERO.** Object ids are stripped before the multiset is
taken — they are arena ordinals that shift the moment the object count changes,
and leaving them in would make every line downstream of a fold read as a mover.

### 4.1 Per-shape multiset delta, pristine → final, SimpleUVM/default

`289` distinct dump-line shapes moved. Classified against a pattern set that
admits only `$bits`-fold artifacts (`|vpiName:$bits`, `|vpiArgument:`,
`|vpiParent:`, the folded members' `ref_obj` fullnames, the enclosing
`method_func_call`/`operation` parent lines, and the constant's own
`|vpiSize:64` / `|vpiConstType:9` / `|UINT:<n>` / `|vpiDecompile:<n>`):

```
shapes changed:              289
shapes NOT explainable as a $bits fold:   0
```

REMOVED are led by `|vpiName:$bits` (−14, −13, −4 at three depths) and the
argument `ref_obj` fullnames (`…do_record::m_address`,
`…::m_byte_enable_length`, `…::m_length`, `…::m_streaming_width`, −3 each);
ADDED are led by `|vpiSize:64` and `|vpiConstType:9` (+14, +13, +4) with their
`|UINT:32` / `|UINT:1` / `|UINT:64` values. That is the fold and nothing else.

### 4.2 Why this is the load-bearing measurement

The cmp-line count went **42 → 20 402**, which in isolation reads like a
catastrophe. §4.1 is the reason it is not: **a patch that changed only
`$bits`-fold shapes cannot have created a `class_defn` head.** The head was
always there, behind the briefed one, and the walk simply reaches it now. Its
content is a different family entirely — `int_typespec` spans, `function`
END-COLUMNS (`endln:55:16` golden vs `endln:55:44` ours), and a `vpiParent`
naming difference (`work@env` vs `uvm_set_get_dap_base`) — filed as **R1**.

---

## 5. RANKED RESIDUES

| # | residue | evidence | why not fixed here |
|---|---|---|---|
| **R1** | **the newly-exposed head**: `class_defn (uvm_set_get_dap_base)` — pure-virtual method `function` END-COLUMNS (`endln:55:16` vs `55:44`), `int_typespec` spans (`80:45` vs `32:44`), and a `vpiParent` named `work@env` vs the class | id-normalised diff of the head's LHS/RHS blocks, §4.2 | a span/parent-policy family, not a fold family; region byte-identical pris↔final so it is untouched by this pass. **The single highest-value next target on this row** |
| **R2** | **`$bits(<own class property>[i])` — the SELECT extension.** Golden folds it; we keep the call. 6 objects in SimpleUVM alone | `c5_select.sv`, full grid below | the GATING is identical to the landed law, but the **VALUE rule is quirky** and getting it wrong is a wrong-constant over-fire, strictly worse than the `sys_func_call` we emit today. It needs its own verification cycle |
| **R3** | **`real` member**: golden folds `$bits(<real>)` to **UINT:32**; the language and slang both say **64** | `c4_edge.sv` line 115 | I cannot derive Surelog's 32 from slang's type system. Emitting 64 would be a WRONG-VALUE over-fire; `isIntegral()` excludes `real` and `string` together. **Declared, not hidden** |
| **R4** | **17 `$bits(<TYPE>)` objects missing from our `uvm_packer`/`uvm_reg_block` output entirely** — `$bits(byte)`, `$bits(uvm_reg_data_t)` | `comm -23` of the site census; identical 17 absent from the **pristine** dump | pre-existing, a different mechanism (we do not emit the object at all, rather than folding it) |
| **R5** | `$typename(m_pk).len()` is ABSENT on our side | `c3_sibling.sv` line 24 | pre-existing; we drop a method call applied to a `$typename` result |
| **R6** | packed-dimension bound `logic [$bits(m_v)-1:0]`: golden keeps a symbolic `$bits`, we fold | `c2_context.sv` line 57 | pre-existing and **unchanged** by this pass (c2's dump is byte-identical pris↔final); belongs to the declaration-dimension path |

### R2's measured value grid — so the next pass need not re-derive it

`c5_select.sv`, in-block method, own class property, golden's fold value:

| written | member declaration | golden folds to | note |
|---|---|---|---|
| `$bits(m_pk[2])` | `logic [7:0] m_pk` | **UINT:8** | the **ROOT's** width, not the select's 1 |
| `$bits(m_pk[3:0])` | `logic [7:0]` | **UINT:8** | root width, not 4 |
| `$bits(m_pk[i +: 2])` | `logic [7:0]` | **UINT:8** | root width |
| `$bits(m_arr[i])` | `bit m_arr[4]` | **UINT:4** | the **WHOLE ARRAY**, not the element's 1 |
| `$bits(m_arr[1])` | `bit m_arr[4]` | **UINT:4** | constant index behaves the same |
| `$bits(m_parr[i])` | `logic [7:0] m_parr[4]` | **UINT:32** | whole array (4×8) |
| `$bits(m_s.a)` | `st_t m_s` (7 bits), `.a` 4 bits | **UINT:4** | here the **MEMBER's** width, not the root's |
| `$bits(m_sarr[i].b)` | select **then** member | **SYMBOLIC** | golden gives up |
| `$bits(m_q[i])` | `int m_q[$]` | **UINT:32** | the **ELEMENT's** width (root has no size) |
| `$bits(m_dyn[i])` | `int m_dyn[]` | **UINT:32** | element width |

and the negative controls all behave as the landed law predicts — out-of-block
selects **keep**, inherited-member selects **keep**, local/formal selects
**keep**, and a `W`-dependent select **keeps** while its fixed twin folds. So
the extension is *gated* by exactly § bitsOwnClassPropFold61 and differs only
in how the width is computed.

---

## 6. WHAT THE BRIEF GOT RIGHT AND WRONG

| brief's claim | verdict |
|---|---|
| golden replaces the `sys_func_call` with its constant in contexts ours does not | **CONFIRMED** |
| the fold constant is BARE, size 64, ct 9, `compileConst` form, NO typespec | **CONFIRMED**, and verified on every folding cell of five arms, not just the witness |
| independent of r10uvm60's evaluated-body set (`do_print` is not in it) | **CONFIRMED** — the two laws never meet; this predicate never reads `subBodyEvaluated60` and `tfBodyConstArgNoFormalTs60`'s sites are call ACTUALS, not `$bits` calls |
| "$bits **(and sibling sys-func)** fold" | **REFUTED.** `$bits` is the only one. 11 siblings measured in the same cell, none folds, on either side |
| "the implementer of pass 60 sized this family at ~87 objects in SimpleUVM's cell" | **not reproduced as stated**: the census finds **54** distinct `$bits` sites on our side and **37** movers. 87 is close to the *dump-line instance* delta, which double-counts back-references |
| axis (e): `$bits` on a parameter-dependent width in an UNELABORATED class | **MEASURED, and it is the pass's main over-fire trap**: golden keeps it in BOTH the elaborated specialization and the never-instantiated default, even though slang has a width for both |
| prior art: check whether the rule is view-split | **MEASURED: it is NOT** (§1.5) |
