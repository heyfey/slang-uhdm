# r10uvm62 — the briefed head **CLEARED on all THREE target rows** (20 402 cmp lines → **14**), and the brief's own clue list is **REFUTED BY THE COMPARATOR'S SOURCE: `vpiParent` is compared NOWHERE — 233 `Compare` methods, ZERO read it**

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after. No conversion was
expected from this pass and none happened.

**SECOND LINE.** On all three target row-modes the cmp goes
**20 402 lines → 14 lines**, one head → one head, and the head OBJECT changes
identity from `class_defn (uvm_pkg::uvm_set_get_dap_base)` to a two-object
`integer_typespec` pair. That is the largest single advance this row has had.

**THIRD LINE, and it is the one that mattered most.** The brief handed me three
clues and named the third — *"`vpiParent: work@env` differences (cmp-VISIBLE —
the likely failing pair)"* — as the likely answer. **It is not cmp-visible at
all.** `BaseClass::Compare` reads exactly three things (`VpiType`, `VpiName`,
`VpiDefName`) and **not one of the 233 `Compare` bodies in UHDM reads
`VpiParent`** — measured, `0`. The real failing pair was a field the clue list
never mentioned, because the dump does not print an *absent* field:
**`class_defn::VpiEndLabel`**, golden `uvm_set_get_dap_base`, ours empty.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; `arm62.sh` prints that it did on every run.

Base **75bfb7e**. Worktree `.claude/worktrees/r10uvm62`; pristine control
worktree `.claude/worktrees/r10uvm62pris`, configured and built by me at the
same commit. Both `git rev-parse HEAD` print
`75bfb7e3abe769746b16f1ae9a3082aea5c35bb6`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 75bfb7e) | `5cf09f5121afbb14a66eacfc84bd859b` | my own build of the base commit |
| **FINAL (shipped)** | **`4cb75fc8f5e3b665538161e9f9db1687`** | every gate number below was measured on THIS binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) were **READ ONLY**. The four
slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) were never dispatched. `GOLDEN_DEFER` left **UNSET**. slang was not
patched.

---

## 0. HOW THE FAILING PAIR WAS LOCALIZED — before any theory, as the brief ordered

The head was a **20 402-line, 10 207-line-per-side `class_defn` SUBTREE**. The
brief warned that the line count is DEPTH, not location, and that the region's
multiset distance to golden is only 22 lines. Neither number locates anything.
Three steps, no hypotheses:

1. **Split the cmp at the `RHS:` marker** and diff the two blocks with object
   ids stripped. That produced 5 399 diff lines — still not an answer, but it
   showed the *shapes* in play: `int_typespec` spans, `function` end-columns
   (`55:16` vs `55:44`), and a `class_typespec` whose `vpiParent` reads
   `work@env` on one side and the class on the other. **Those are the brief's
   three clues, and they are ALL of the diff. If one of them were the failing
   pair, the head would be that object, not the class.**

2. **Read the comparator instead of guessing.** `class_defn::Compare`
   (`UHDM/build/generated/src/class_defn.cpp:141`) is a fixed sequence:
   `basetype_t::Compare` → `VpiVirtual` → `VpiAutomatic` → `Extends` →
   `Task_funcs` → `Constraints` → `Deriveds` → `Class_typespecs` →
   **`VpiEndLabel`**. `m_failedLhs` is written at the DEEPEST failing point and
   never overwritten on the way out, so *the head being the `class_defn` itself
   means every one of those recursive vectors PASSED* and the failure is one of
   the class's own scalar fields.

3. **Census the class's own top-level fields on both sides.** One line of awk
   over the two blocks:

   ```
   golden: 10 vpiMethod, 6 vpiDerivedClasses, 2 vpiVirtual, 2 vpiTypedef,
           2 vpiParent, 2 vpiParameter, 2 vpiName, 2 vpiFullName,
           2 vpiExtends, 2 vpiEndLabel
   ours  : ... identical ... and ZERO vpiEndLabel
   ```

   (the ×2 is cmp printing each side's subtree twice.) **`|vpiEndLabel:` is the
   only top-level field golden has and we do not.** Source:
   `uvm-1.2/src/dap/uvm_set_get_dap_base.svh:82` — `endclass : uvm_set_get_dap_base`.

**Why the three clues could never have been the answer, stated mechanically
rather than by elimination** — this is the durable finding of the pass:

```
233 Compare methods (232 generated + BaseClass::Compare)
  VpiParent   reads inside Compare bodies : 0
  VpiFile / span reads                    : 0   (campaign prior art, re-confirmed)
  VpiEndLabel reads inside Compare bodies : 8   (exactly the 8 owning types)
BaseClass::Compare compares: VpiType, VpiName, VpiDefName.  Nothing else.
```

The campaign's standing note — *"of the known clues only PARENT-family fields
can be the failing pair"* — is **REFUTED**. Parents are as invisible to
`uhdm-cmp` as spans and file paths. All three briefed clues are **dump-only
residue**, and they remain so after this pass.

---

## 1. THE LAW, in a form a future pass can grep for

### § endBlockLabelAllOwners62

*A **written end-block label** — `endclass : N`, `endprogram : N`,
`join|join_any|join_none : N` — is stamped verbatim as `vpiEndLabel` on the
UHDM object that owns the construct. The label is the **token's own text**,
bare: never the `::`-qualified fullname, never the object's `vpiName` when no
label is written. **NOTHING ELSE conditions it** — not the enclosing scope, not
the qualifier (`virtual`, parameterized, `extends`, `implements`), not
nesting, not the view.*

* **DIRECTION**: **ADD ONLY.** The patch mints no object, deletes none,
  re-parents none, and moves no span. The only dump-line shape it can produce
  is `|vpiEndLabel:<name>`.
* **THE OWNER SET IS EXHAUSTIVE AND WAS READ, NOT GUESSED.** Eight UHDM types
  own a `vpiEndLabel` slot (`~/git-repos/UHDM/model/*.yaml`, and the same eight
  are the only `Compare` bodies that read it): `class_defn`, `module_inst`,
  `interface_inst`, `program`, `package`, `named_begin`, `named_event`,
  `named_fork`. Before this pass we handled **four** (`module_inst`,
  `interface_inst`, `package`, `named_begin`); we now handle **seven**.
  `named_event` has no `end`-label syntax in SystemVerilog and is a
  **structurally empty** cell, not an omission.
* `grep -rn 'endBlockLabelAllOwners62' include/ src/` → **3 hits across 3
  files** — one at each call site, which is the whole point: one law, three
  writers, no shared helper invented for three lines.

### STATED GATE == CODE GATE — read off the source, not the comment

| site | file:line | the conjunction, in order |
|---|---|---|
| **class** | `src/UhdmExporter.cpp` ~722 (`emitClassDefn`) | `cls.getSyntax()` non-null · `syn->as_if<ClassDeclarationSyntax>()` non-null · `cds->endBlockName` non-null → `cd->VpiEndLabel(ebn->name.valueText())` |
| **program** | `src/ModuleEmit.cpp` ~608 (`emitModuleDef`) | `body.getSyntax()` non-null · kind **is not** `ModuleDeclaration` · kind **is** `ProgramDeclaration` · `.blockName` non-null → `instSetEndLabel(m, …)` |
| **named block / fork** | `src/StmtEmit.cpp` ~933 (`emitStmt`) | already inside `bs.blockSymbol && !name.empty()` (a NAMED block) · `stmt.syntax` non-null · `BlockStatementSyntax::isKind(kind)` (Sequential **or** Parallel) · `.endBlockName` non-null → `named_fork` if `isFork`, else `named_begin` |

There is **no scope test, no qualifier test, no view parameter, and no
name-matching test** in any of the three. That is deliberate: §1.1–§1.3 measure
every one of those axes and none of them discriminates.

### The two pre-existing defects the census exposed, both fixed here

* **`program` — a stated-gate/code-gate split of exactly the kind this campaign
  keeps paying for.** `instSetEndLabel` in `src/EmitHelpers.h:1773` has ALWAYS
  had a `UHDM::program` arm. Its only caller sat inside
  `if (syntax->kind == SyntaxKind::ModuleDeclaration)`, so **the program arm was
  dead code** and every labelled program silently lost its label. The fix is a
  separate `else if` rather than a widened kind test, because the
  `ModuleDeclaration` branch also REWRITES the span (`mr0` → the `module`
  keyword) and a program's span must not move here.
* **`named_fork` — an explicit `if (!isFork)` that threw the fork case away.**
  A `ParallelBlockStatement` is the same `BlockStatementSyntax` with the same
  `endBlockName`, and `named_fork` owns a `vpiEndLabel` slot that `fork_stmt`
  does not. Golden labels **all three** join flavours.

### BOUNDARIES — checked, not assumed

`git diff 75bfb7e --stat` → **3 production files, +37 / −4**.
`src/ExprEmit.cpp` (§ bitsOwnClassPropFold61's territory, and the owner of the
`$bits` residue R2 grid) is **untouched, 0 diff lines**;
`src/TaskFuncEmit.cpp` (§ tfBodyConstArgNoFormalTs60, evaluated-body arg
typespecs) is **untouched, 0 diff lines**. `grep -cE
"VpiConstType|covergroup|clocking|sample|generate" ` over the added lines →
**0**, so r10svs8's covergroup-sample cell and r10earl33's generate-fold cell
are not crossed. The added code reads no fold set, no constant, no typespec and
no parameter: it reads one syntax token and writes one string.

---

## 2. THE GRID, cell for cell

`arm62.sh <arm.sv> <out> <bin>` builds golden + ours and cmps (LHS golden
first); `arm62e.sh` is the same with `-elabuhdm`/`--elabuhdm` on both sides.
`elgrid.sh <armdir>` is the pass's instrument: it censuses **both** sides for
**all eight** end-label-owning types and prints, per object, `LABEL:<v>` /
`NOLABEL` / `NO-OBJECT` — so a cell present on one side only can never read as
blank, and "golden has no label here" can never be confused with "we emit no
object here".

### 2.1 `c1_endlabel.sv` — THE DISCRIMINATOR

Every labelled class has an **unlabelled twin in the same scope**, so the
discriminator cannot be the scope; every scope appears twice, so it cannot be
the qualifier.

| row | shape | golden | PRISTINE ours | **FINAL ours** |
|---|---|---|---|---|
| R1 | package class, bare `endclass` | NOLABEL | NOLABEL | **NOLABEL ✓** |
| R2 | package class, `endclass : A_lbl` | LABEL:A_lbl | NOLABEL ✗ | **LABEL:A_lbl ✓** |
| R3 | `virtual class`, labelled | LABEL:V_lbl | NOLABEL ✗ | **LABEL ✓** |
| R4 | `virtual class`, bare | NOLABEL | NOLABEL | **NOLABEL ✓** |
| R5 | **parameterized** `#(type T)`, labelled (the witness's shape) | LABEL:P_lbl | NOLABEL ✗ | **LABEL ✓** |
| R6 | parameterized `#(int W)`, bare | NOLABEL | NOLABEL | **NOLABEL ✓** |
| R7 | `extends`, labelled | LABEL:E_lbl | NOLABEL ✗ | **LABEL ✓** |
| R8 | `extends`, bare | NOLABEL | NOLABEL | **NOLABEL ✓** |
| R9 | labelled class with an **extern/out-of-block** method | LABEL:X_lbl | NOLABEL ✗ | **LABEL ✓** |
| R10 | **module-local** class, labelled | LABEL:M_lbl | NOLABEL ✗ | **LABEL ✓** |
| R11 | module-local, bare | NOLABEL | NOLABEL | **NOLABEL ✓** |
| R12/13 | **NESTED**, outer AND inner labelled | LABEL:N_out / LABEL:N_in | NOLABEL ✗ ×2 | **LABEL ✓ ×2** |
| R14/15 | nested, both bare | NOLABEL ×2 | NOLABEL ×2 | **NOLABEL ✓ ×2** |
| R17 | **compilation-unit** class, labelled | LABEL:U_lbl | NOLABEL ✗ | **LABEL ✓** |
| R18 | compilation-unit, bare | NOLABEL | NOLABEL | **NOLABEL ✓** |

**FINAL: `c1_endlabel` has ZERO differing cells (9 → 0).** cmp lines
**138 → 18**; the head moves off `class_defn (p1::E_lbl)` onto an unrelated
`int_typespec`. The label value is invariably the **bare written token** —
`LABEL:A_lbl` for a class whose UHDM name is `p1::A_lbl`.

### 2.2 `c2_neighbours.sv` — ALL EIGHT OWNERS, labelled and bare

| owner type | labelled | bare | golden | PRIS ours | **FINAL** |
|---|---|---|---|---|---|
| `package` | `endpackage : pk_lbl` | ✔ | LABEL / NOLABEL | **already correct** | ok |
| `interface_inst` | `endinterface : if_lbl` | ✔ | LABEL / NOLABEL | **already correct** | ok |
| `module_inst` | `endmodule : m_lbl` | ✔ | LABEL / NOLABEL | **already correct** | ok |
| `named_begin` | `end : nb_lbl` | ✔ | LABEL / NOLABEL | **already correct** | ok |
| `named_begin` inside an unnamed fork (`guard_lbl`) | ✔ | — | LABEL | **already correct** | ok |
| **`program`** | `endprogram : pg_lbl` | ✔ | LABEL / NOLABEL | **NOLABEL ✗** | **LABEL ✓** |
| **`named_fork`** | `join_none : nf_lbl` | ✔ | LABEL / NOLABEL | **NOLABEL ✗** | **LABEL ✓** |
| `named_event` | — | — | *no end-label syntax exists* | — | structurally empty |

**FINAL: ZERO differing cells (2 → 0).** cmp lines **66 → 114**: the head
ADVANCED off `program (work@pg_lbl)` onto `named_fork (work@m_lbl.nf_lbl)`,
which now fails on a **different field** — see residue **R2**.

### 2.3 `c3_edge.sv` — the OVER-FIRE / UNDER-FIRE traps

| row | shape | golden | PRIS ours | **FINAL** |
|---|---|---|---|---|
| `q::Forker` | labelled class holding the **uvm_objection fork shape** | LABEL | NOLABEL ✗ | **LABEL ✓** |
| `q::Impl` | class **`implements`** an interface class, labelled | LABEL | NOLABEL ✗ | **LABEL ✓** |
| `q::WithCon` | labelled class with an **extern constraint** + `rand` | LABEL | NOLABEL ✗ | **LABEL ✓** |
| `q::Joiner` | labelled class holding all three join flavours | LABEL | NOLABEL ✗ | **LABEL ✓** |
| `guard` | `fork : guard … join_none : guard` **inside a class task** | LABEL:guard | NOLABEL ✗ | **LABEL ✓** |
| `f_all` | `join : f_all` | LABEL | NOLABEL ✗ | **LABEL ✓** |
| `f_any` | `join_any : f_any` | LABEL | NOLABEL ✗ | **LABEL ✓** |
| `f_bare` | `fork : f_bare … join_none` (no label) | **NOLABEL** | NOLABEL | **NOLABEL ✓** — the over-fire trap, held |
| `inner` | labelled `begin` inside a labelled fork | LABEL | LABEL | **LABEL ✓** |
| `prog_host` | `endprogram : prog_host` | LABEL | NOLABEL ✗ | **LABEL ✓** |
| `work@prog_host::InProg` | labelled class **inside a program** | LABEL | NOLABEL ✗ | **LABEL ✓** |
| `work@prog_host::InProg_bare` | bare class inside a program | NOLABEL | NOLABEL | **NOLABEL ✓** |
| `iface_host` / `top_c3` | `endinterface :` / `endmodule :` | LABEL | LABEL | **LABEL ✓** |

**FINAL: 13 → 4 differing cells, and all four remaining are PRE-EXISTING
OBJECT-EXISTENCE residues, not label cells** — filed as **R3**/**R4**:

* `q::IC`, `q::IC_bare` — **interface classes**: golden emits **NO `class_defn`
  at all**; we emit one. (Our `q::IC` now carries `LABEL:IC`. This cannot change
  any cmp verdict: `Class_defns` vector sizes already differ, so the comparison
  fails strictly earlier. Declared, not hidden.)
* `work@InIface`, `work@InIface_bare` — a **class declared inside an
  interface**: golden emits it, we emit **no object**.

### 2.4 The VIEW axis — the law is **NOT view-split**

`arm62e.sh` (both sides `-elabuhdm`) reproduces c1, c2 and c3 **cell for cell**:
9/2/13 differing cells pristine, and the same rows. One predicate, both views,
no `elabView` parameter. Related and measured in c3: an **elaborated child
instance never carries an end label** (`work@top_c3.ih` is NOLABEL in golden
even though `endinterface : iface_host` is written) — the label lives on the
**definition** object only, which is where all three of our writers put it.

### 2.5 A cell that CANNOT EXIST

There is no `endclass : <wrong name>` row: SystemVerilog requires the label to
match, slang rejects a mismatch outright, and no database holding one ever
reaches the emitter. Label *value* is therefore not an axis this predicate can
be wrong about — which is why the writers take the token text and do not
cross-check it against `VpiName`.

---

## 3. THE CORPUS CENSUS — predicted from source BEFORE coding, then measured

`elgrid.sh` runs on the SimpleUVM/default dumps directly (8.8 s over
1.14 M lines). **Span-free by necessity**: uvm-1.2 is hundreds of files and the
dump prints no file per object, so every key is TYPE + NAME.

| SimpleUVM/default | golden | PRISTINE ours | **FINAL ours** |
|---|---|---|---|
| end-label-owning objects censused (distinct TYPE+NAME keys) | 355 | 355 | 355 |
| keys carrying a `vpiEndLabel` | **55** | **4** | **55** |
| raw `vpiEndLabel` **dump-line instances** | **57** | **6** | **57** |
| **DIFFERING CELLS** | — | **51** | **0** |

The key count is 2 lower than the line count on each side because two
`named_begin`s (`foreach_value`, `foreach_addr`) occur twice under the same
fullname — **an object is not a dump occurrence**, and this instrument keys by
object. The line-instance delta `57 − 6 = 51` is exactly the ADDED count §5
measures independently.

The 51 pristine misses were **50 `class_defn` + 1 `named_fork`**, every one of
them `golden=LABEL / ours=NOLABEL`. **Zero over-fires and zero `NO-OBJECT` rows
in either direction** — this field had no other failure mode in the corpus.

**Source-side prediction, made before the patch was written and confirmed
exactly**: `grep -rhE 'endclass[[:space:]]*:' uvm-1.2/src` → **50**;
`grep -rhE 'join(_any|_none)?[[:space:]]*:'` → **1**. 50 + 1 = **51**, which is
precisely the ADDED-shape count measured in §4.

`uhdm2rtlil` corpus, predicted **0 movers** before running: that corpus has
**0 files** with `endclass :`, **0** with `endprogram :`, **0** with a labelled
join, and only 3 files containing a class at all. Measured: **0 / 679.**

---

## 4. THE FIVE GATES — every number measured on `4cb75fc8f5e3b665538161e9f9db1687`

### GATE 1 — BUILD

```
BUILD DIR (absolute): /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10uvm62/build
link lines ('Linking CXX executable slang-uhdm'): 1
compiler errors (' error:'):                      0
worktree HEAD: 75bfb7e3abe769746b16f1ae9a3082aea5c35bb6
pristine HEAD: 75bfb7e3abe769746b16f1ae9a3082aea5c35bb6
```

The md5 assertion ran as a **SEPARATE command**, with the baseline validated as
32 hex characters first:

```
BASELINE md5 is 32 hex: OK
CONTROL(pristine 75bfb7e) = 5cf09f5121afbb14a66eacfc84bd859b
FINAL                     = 4cb75fc8f5e3b665538161e9f9db1687
MD5 CHANGED: PASS
```

`detcheck.sh`, FINAL binary, SimpleUVM's own command line, 3 runs:
**1 distinct hash (`7c792e45f9f2dd5e`), 0 NO_OUTPUT, bytes 11128961 all three.**
The patch adds **no container** — it is three token reads and three string
writes, with no map or set to iterate — so the alias-population trap in the
campaign memory cannot apply, and it was measured anyway.

**THE Scoreboard/default MULTI-STABILITY FLAKE, attributed with reps as the
standing rules require. It is REAL and PRE-EXISTING:**

```
Scoreboard/default, 3 runs each
  PRISTINE 5cf09f51…  5964f675 / 5964f675 / 3e47f189   distinct=2   bytes 11133612 (all 3)
  PATCHED  4cb75fc8…  496d6b56 / cb35a356 / a5927f09   distinct=3   bytes 11133677 (all 3)
```

Both binaries are multi-stable, so the flake is **not this patch**; the byte
SIZE is stable within each binary and differs between them by a deterministic
**65 bytes**, which is what keeps the Scoreboard mover attribution valid despite
the unstable hash.

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

`GOLDEN_DEFER` left UNSET: **5 DEFERRED** in both modes, as in the baseline. The
pristine sweep also reproduces the baseline at **0 differing ROWS**.

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs my own pristine 75bfb7e build

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
             SELFCHECK 678/679 flagged         SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 7 / 953
             SELFCHECK 952/953 flagged         SELFCHECK1 = 8  (= 7 real + 1 injected)
```

The 7 movers are exactly the rows that produce a UVM database:

```
default/{BuildUVMPkg, Scoreboard, SeqDriver, SimpleUVM}
testflags/{BuildUVMPkg, SeqDriver, SimpleUVM}
```

**The mover set is COMPLETE BY CONSTRUCTION, not by sampling.** The patch can
only ADD a `vpiEndLabel`, so any database that would gain one *must* differ in
bytes; the verifier compares **all 953** databases and `SELFCHECK1` proves it
detects a **one-byte** change. There is no database it could have missed.

### THE HEADS — measured on BOTH binaries, all four UVM tests, both modes

```
TEST           MODE       PRISTINE        PATCHED
SimpleUVM      default    20402  1 head      14  1 head   <- head CLEARED
SimpleUVM      testflags  20402  1 head      14  1 head   <- head CLEARED
Scoreboard     default    20402  1 head      14  1 head   <- head CLEARED
Scoreboard     testflags  SKIP-NOFILE (SLANG_REJECT, no database — reported, not hidden)
SeqDriver      default       85  1 head      85  1 head   (another law; bytes moved)
SeqDriver      testflags     85  1 head      85  1 head   (another law; bytes moved)
BuildUVMPkg    default       58  1 head      58  1 head   (another law; bytes moved)
BuildUVMPkg    testflags     58  1 head      58  1 head   (another law; bytes moved)
```

**HEAD IDENTITY, not just head count** — the head object's own line, read out of
each cmp:

| row | PRISTINE head | PATCHED head |
|---|---|---|
| SimpleUVM/default | `class_defn: (uvm_pkg::uvm_set_get_dap_base), id:129` | `integer_typespec: , id:192201, line:312:48` |
| SimpleUVM/testflags | `class_defn: (uvm_pkg::uvm_set_get_dap_base), id:129` | `integer_typespec: , id:192213, line:312:48` |
| Scoreboard/default | `class_defn: (uvm_pkg::uvm_set_get_dap_base), id:129` | `integer_typespec: , id:191855, line:312:48` |
| SeqDriver ×2 | `class_typespec: (adpcm_pkg::type_id)` | **unchanged** |
| BuildUVMPkg ×2 | `ref_obj: (…::uvm_deferred_init)` | **unchanged** |

All three target heads are **the briefed object** before and **a different
object of a different type** after. The head is **cleared, not renumbered**.

### CANARIES

```
canaudit.sh canaries.sh ctcan2.sh   audited=29  UNCOVERED=0  FENCE-BREACH=0
ctcan2.sh  u2r  EXPECT_UNKNOWN=6 -> ok=1  changed=0 absent=0 unknown-patterns=6  PASS
ctcan2.sh  sl   EXPECT_UNKNOWN=1 -> ok=58 changed=0 absent=0 unknown-patterns=1  PASS
canaries.sh sl  -> ok=52 changed=0 absent=0 unknown-names=7   (the 7 u2r-only names)
canaries.sh u2r -> ok=8  changed=0 absent=0 unknown-names=25  (the 25 surelog-only names)
BY NAME: InterfaceModPort   default CMP_EQUAL/differ   testflags CMP_EQUAL/differ   OK
         BlackParrotComplex default CMP_EQUAL/differ   testflags CMP_EQUAL/differ   OK
         SimpleUVM CMP_NOTEQUAL both modes; Scoreboard CMP_NOTEQUAL/SLANG_REJECT — all AT BASELINE
```

---

## 5. MOVERS ATTRIBUTED — per shape, vs GOLDEN, by MULTISET

`mv62.sh` (`REUSE=1` supported) strips object ids before taking the multiset —
they are arena ordinals that shift the moment an object count changes. ADDED and
REMOVED are line **instances**, counted separately. `UNATTRIB` is the number of
changed DISTINCT SHAPES not matching `^ *[|]vpiEndLabel:` — and unlike a fold
pass, this attribution pattern is **exact**, not a twenty-alternative
approximation, because the patch adds one field line and can do nothing else.

```
TEST           MODE       | msdist to GOLDEN pris->pat  |  ADDED  REMOVED | UNATTRIB
SimpleUVM      default    |  144580 -> 144529  IMPROVED |     51        0 |    0
SimpleUVM      testflags  |  144576 -> 144525  IMPROVED |     51        0 |    0
Scoreboard     default    |  134864 -> 134813  IMPROVED |     51        0 |    0
SeqDriver      default    |  367784 -> 367728  IMPROVED |     56        0 |    0
SeqDriver      testflags  |  367784 -> 367728  IMPROVED |     56        0 |    0
BuildUVMPkg    default    |   81273 ->  81221  IMPROVED |     52        0 |    0
BuildUVMPkg    testflags  |   81273 ->  81221  IMPROVED |     52        0 |    0
movers examined: 7   SKIPPED: 0
```

**Every mover IMPROVES against golden; REMOVED is 0 everywhere; UNATTRIB is 0
everywhere.** The distance improvement equals the ADDED count exactly on all
seven rows — every added line closes a gap, none opens one.

The shape sets decompose cleanly: SimpleUVM/Scoreboard = the **50 uvm-1.2
`endclass :` labels + `guard`**; SeqDriver = those 51 **plus its own five**
(`adpcm_driver`, `adpcm_seq_item`, `adpcm_sequencer`, `adpcm_test`,
`adpcm_tx_seq`); BuildUVMPkg = 52, a different uvm subset that additionally
reaches `m_uvm_sqr_seq_base`, `uvm_printer_element_proxy`,
`uvm_run_test_callback`.

---

## 6. RANKED RESIDUES

| # | residue | evidence | why not fixed here |
|---|---|---|---|
| **R1** | **THE NEW HEAD on all three rows**: `integer_typespec @312:48` — golden carries `vpiSigned:1`, we do not. It is the **INDEX typespec of an associative array**, `uvm_recorder.svh:312` `protected static uvm_recorder m_recorders_by_id[integer]`, reached through `array_typespec → vpiIndexTypespec → ref_typespec → vpiActual`, and it has **NO `vpiParent`**. Its sibling at `131:17`, the *element* `integer_typespec` which DOES have a `vpiParent` (`integer_var m_ids_by_recorder`), carries `vpiSigned:1` on **both** sides | `heads_pat/*.cmp` — 14 lines, 2 objects, the entire head is `\|vpiSigned:1` present/absent; both sides' dumps read at `o2.dump:1048247` and `1048262` | a signedness/typespec-construction family, not a label family. **The single highest-value next target on this row** — it is a 14-line head with the failing field already named, and the `integer` keyword's signedness is knowable from slang |
| **R2** | **`named_fork` is missing `vpiJoinType`.** Golden stamps `vpiJoinType:1` on a **named** fork; we stamp the join type only on the unnamed `fork_stmt`. **2 objects in SimpleUVM**, both `join_none`: `uvm_objection::m_execute_scheduled_forks::guard` and `uvm_phase::execute_phase::master_phase_process` | c2's patched head is exactly this (`named_fork (work@m_lbl.nf_lbl)`, sole diff `\|vpiJoinType:1`); corpus census in §3's companion run: golden `{JOIN1}`, ours `{NOJOIN}` on both objects | one line away, and in the same statement I already edited — but it is a **different field of a different family**, and this pass runs ONE head. **Its value grid is complete above: `vpiJoinType` = 1 for `join_none`, and the c3 arm already carries `join`/`join_any`/`join_none` rows so the next pass can read the other two values off `a_c3/g.dump` without writing a new arm** |
| **R3** | **interface classes**: golden emits **no `class_defn`** for `interface class IC; … endclass`; we emit one (and now label it) | `c3_edge.sv` rows `q::IC`, `q::IC_bare`; PRE-EXISTING — the objects are present in the pristine dump too | we emit an object golden does not have; the `Class_defns` vector size already differs, so this changes no verdict. A deletion rule, not a label rule |
| **R4** | **a class declared INSIDE an `interface`** is emitted by golden and **not by us at all** | `c3_edge.sv` rows `work@InIface`, `work@InIface_bare`; PRE-EXISTING | an object-existence rule in the interface writer; unrelated to this field |
| **R5** | the three briefed clues remain, and are now **proved cmp-invisible**: `function` end-columns `55:16` vs `55:44`, `int_typespec` spans `80:45` vs `32:44`, `class_typespec` `vpiParent` `work@env` vs the class | §0's count: 0 of 233 `Compare` bodies read `VpiParent`; 0 read spans or files | **dump-only residue by construction.** Worth fixing for dump fidelity, worth ZERO for cmp. Do not spend a head on them |

---

## 7. WHAT THE BRIEF GOT RIGHT AND WRONG

| brief's claim | verdict |
|---|---|
| the head is `class_defn (uvm_pkg::uvm_set_get_dap_base)`, 1 head, 20 402 cmp lines, pre-existing and masked behind the `$bits` head | **CONFIRMED** exactly, on all three row-modes, on my own pristine build |
| "LOCALIZE first — the cmp head line count is depth, not location" | **CONFIRMED and load-bearing.** The 20 402 lines contained ~5 400 id-normalised diff lines, and **not one of them was the failing pair** |
| "`vpiParent: work@env` differences (**cmp-VISIBLE — the likely failing pair**)" | **REFUTED, mechanically.** `VpiParent` is read by **0 of 233** `Compare` bodies. The campaign note that "only PARENT-family fields can be the failing pair" is wrong in the same way |
| function end-columns and `int_typespec` spans are cmp-invisible | **CONFIRMED** — and they are ALSO the whole visible diff, which is why the clue list could not have led to the answer |
| the region's multiset distance to golden is only 22 dump lines | **CONFIRMED in spirit**: the entire fix is **one absent field line per class**, 51 line-instances design-wide |
| candidate families: "method io_decl/return-var parenting, class_typespec parent policy, pure-virtual prototype formals" | **ALL THREE REFUTED.** `Task_funcs` and `Class_typespecs` both COMPARED EQUAL — the head could not have been the class if they had not |
| "the law must come from the measured pair, not the clue list" | **CONFIRMED, and it is the whole lesson of the pass** |
| SUCCESS = the failing pair identified and cleared on all three rows | **DONE**: 20 402 → 14 cmp lines, head object changed type, on all three |

## 8. FILES

```
tools/probe/r10uvm62repro/
  README.md          this file
  c1_endlabel.sv     the discriminator arm (labelled/bare twins in every scope)
  c2_neighbours.sv   all eight vpiEndLabel-owning types, labelled and bare
  c3_edge.sv         over-fire traps: interface class, implements, extern
                     constraint, join flavours, class-in-interface,
                     class-in-program, the uvm_objection fork shape
  arm62.sh/arm62e.sh build golden+ours and cmp, def view / elab view
  elgrid.sh          THE INSTRUMENT: both-sides census of all eight owner types,
                     LABEL/NOLABEL/NO-OBJECT, indentation-tree keyed
  mv62.sh            movers per shape vs golden by multiset, exact attribution
  msdist.sh byteverify.sh manifest.sh rowheads.sh ct8rows.sh
  canaries.sh ctcan2.sh canaudit.sh detcheck.sh
```

**Two defects in `elgrid.sh` were found by auditing the instrument against its
own output and are fixed in the shipped copy**, because a census that silently
drops rows is worse than no census:

1. `nopen` was not initialised, so awk used the **empty string** as the first
   array subscript and `nopen++` jumped to 1 — **the first end-label-owning
   object in every dump was dropped** and a nameless `NO-OBJECT/NO-OBJECT` row
   appeared in its place.
2. The first stack rewrite (needed because the flat version was O(objects²) and
   could not finish a 1.14 M-line dump) popped frames only on OBJECT lines. But
   `vpiEndLabel` is printed **after** the object's children, so the stack top was
   usually a child — **three labels golden certainly has turned into
   `ORPHAN-ENDLABEL`**. The orphan counter, added as a guard, is what made the
   regression visible; field lines now pop too, and the rewritten instrument
   reproduces the original numbers exactly (9 / 2 / 13) on all six arm runs.
