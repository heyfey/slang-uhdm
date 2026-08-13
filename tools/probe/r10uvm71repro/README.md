# r10uvm71 — `§ ctorBodyLocalsNotOnFunc71`: the 593-line head **CLEARED on all THREE target rows**, and the brief's own diagnosis is **REFUTED** — the object the cmp printed was never a surplus vector ENTRY, it was the CONTAINER

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after, and no conversion
was expected. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) are **byte-identical** to the
committed baselines — whole ROW, dump column included — **0 differing ROWS** on
both.

**SECOND LINE.** The briefed head is **GONE from all three target row-modes**.
`SimpleUVM/default`, `SimpleUVM/testflags` and `Scoreboard/default` each sat at
**593** cmp lines on the head `LHS: <null>` against our
`function (uvm_pkg::uvm_objection::new) @127:3-143:14`. All three now sit on a
head in a different family, a different file and a different SHAPE
(`LHS:` non-null against `RHS: <null>` — the mirror image).

**THIRD LINE, and it is worth more than the patch. THE BRIEF'S DIAGNOSIS WAS
WRONG IN ITS FIRST WORD, AND THE CENSUS IT ORDERED IS WHAT PROVED IT.** The
brief opened:

> "So OUR `class_defn(uvm_objection)` task_func vector carries an entry golden's
> does not."

It does not. **Golden and ours agree on that vector exactly** — 32 entries, the
same names in the same order, `new` at slot `[0]` — and design-wide **269 of 332
class_defns carry `new` on BOTH sides**, the same 269. There is no surplus
entry, no missing entry, no re-homed object; `ct71where.py` finds the function
in the *same four places* in both databases. Everything the brief asked to
decode ("does golden list new() for ANY class_defn", "declared vs inherited",
"extern vs in-body", "is it re-homed") has the same answer on both sides and
none of it was the defect.

The mis-reading has a precise mechanical cause, and it is reusable. `uhdm-cmp`
prints `LHS: <null>` from **two** places in UHDM's `SafeCompare`
(`templates/BaseClass.h:187` and `:202`):

| form | fires when | **what it prints as RHS** |
|---|---|---|
| scalar | `lhs == nullptr`, `rhs != nullptr` | the object **AT THE SLOT** |
| **vector** | `lhs` vector **`nullptr`**, `rhs` vector non-null **and non-empty** | **`rhs_obj` — the CONTAINING OBJECT** |

In the vector form *the printed object is not the entry, it is the container*.
The standing rules' own instruction — "a MISSING/SURPLUS VECTOR ENTRY can shift
every later slot, so census the WHOLE vector BY NAME" — is exactly right as
method, and following it is what refuted the premise it was attached to: the
vector was identical, so the object had to be a container, and the only vector
a `function` contains is its own.

**FOURTH LINE.** The real defect: golden's
`function (uvm_pkg::uvm_objection::new)` has **no `vpiVariables` vector at
all**, while ours carries three — `clp`, `cs_`, `trace_args` — *which are also
listed on the body `begin` block, and that block is byte-identical on both
sides*. We were **double-booking** the constructor's body locals. And the split
is not "subroutines don't carry variables": golden puts variables on **665**
non-constructor subroutines in SimpleUVM and **we already matched all 665**. The
line is drawn at **constructors, and nowhere else**.

Base **730f4bf**. Worktree `/tmp/wt_r10uvm71`; pristine control worktree
`/tmp/wt_r10uvm71pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print `730f4bf9b7b389550c42a65e444a44958619d8f1`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 730f4bf) | `c932a66fcafdab8b3f3931adb1657f0c` | my own build of the base commit |
| **SHIPPED (patched)** | **`fb78247bbcfe28d39510111bd33252e2`** | every number below was measured on THIS binary |

BUILD DIRS (absolute): `/tmp/wt_r10uvm71/build`, `/tmp/wt_r10uvm71pris/build`,
both `-j 2`. `[100%] Linking CXX executable slang-uhdm` → `[100%] Built target
slang_uhdm` was read before any md5 was taken; every md5 was asserted in its own
command against `^[0-9a-f]{32}$`. **The control is anchored three ways**: the
MAIN TREE's `build/slang-uhdm` at `HEAD == 730f4bf` is *also*
`c932a66fcafdab8b3f3931adb1657f0c`, and both pristine sweeps reproduce the
committed baseline CSVs byte for byte (0 differing ROWS on 731 and on 1588).
`git stash` was never used. `results/*.csv` were only ever READ. slang was not
patched. `GOLDEN_DEFER` was left **UNSET** (echoed as `[UNSET]` at every sweep
launch). The four slang-fenced tests (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) were never dispatched — `canaudit.sh` proves it
mechanically (`FENCE-BREACH=0`).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script
in this directory.

---

## 0. THE LAW

### § ctorBodyLocalsNotOnFunc71

*A **CLASS CONSTRUCTOR** carries **NO `vpiVariables` vector**. Its body locals
are listed on the **BODY SCOPE** alone — the `begin` block, which already lists
them and is byte-identical to golden's — and where a constructor has no body
scope at all, golden keeps only the `ref_obj` **USE** and mints no variable
object. This holds for **every declaration form**: in-body, out-of-body
`extern` (and for **all three** of that constructor's prints, including the
PACKAGE-parented definition), parameterized class, `automatic`-written locals,
constructors that call `super.new`, virtual/abstract classes, nested classes,
and classes declared in a package, a module, or `$unit`. **EVERY OTHER
SUBROUTINE IS UNTOUCHED** — ordinary method, `static` method, task, out-of-body
method, package function, module function — and that is not an assumption:
golden puts `vpiVariables` on **665** non-constructor subroutines in SimpleUVM
and we matched all 665 **before** this pass and all 665 **after** it.*

```
uvm-1.2/src/base/uvm_objection.svh
127    function new(string name="");     <- the head
128      uvm_cmdline_processor clp;      <- listed on the function AND the begin
129      uvm_coreservice_t cs_ ;         <-   by us; on the begin ALONE by golden
130      string trace_args[$];
```

The other four carriers, **found by the census, not by the brief**:
`uvm_component::new` (3), `uvm_cmdline_processor::new` (3),
`uvm_port_base::new` (2), `uvm_heartbeat::new` (1). **Twelve variables across
five constructors are the ENTIRE population in SimpleUVM** (§1.3), and all five
were named before a line of code was written.

### Where this sits

Every earlier pass in this family asked *what does this object look like*. This
one asks *does this object's CONTAINER own a vector at all* — and the answer
turns on a distinction the dump **cannot print**: `SafeCompare` treats a
**null** vector and an **empty** vector as different, and `uhdm-dump` shows
neither. That is why the shape survived so long behind other heads, and why the
fix is about whether the vector is **CREATED**, not about what goes in it.

### STATED GATE == CODE GATE — read off the source, not the comment

ONE predicate, at ONE site, in `src/TaskFuncEmit.cpp`:

```bash
grep -n "ctorBodyLocalsNotOnFunc71" src/TaskFuncEmit.cpp   # 2 hits (both comments)
grep -n "ctorNoVars71" src/TaskFuncEmit.cpp                # 2 hits: the decl and the use
```

The code gate is **exactly this, and nothing else**:

```cpp
bool ctorNoVars71 =
    (sub.flags & MethodFlags::Constructor) != MethodFlags::None;
if (!fvars->empty() && !ctorNoVars71)
    tf->Variables(fvars);
```

* **CORRECTED BY THE VERIFIER (see `README.verifier.md`).** This pass first
  shipped `sub.name == "new" && (classScope || oob)`. Both halves of that
  spelling were wrong:
  * the NAME test **over-fires**. An ESCAPED IDENTIFIER is exempt from keyword
    rules, so `function int \new (int a);` is an ORDINARY class method that
    slang also names `"new"`; golden KEEPS its body local on the function and
    the name gate deleted it (arm `a4_escnew.sv`: golden 1, base 1, name gate
    **0**). No corpus source uses `\new`, so every gate stayed green over a
    real regression.
  * `|| oob` was **dead**. `oobDefs` is populated only inside `if (classScope)`
    (:1555) and `isOutOfBody` reads that local vector, so `oob` implies
    `classScope` — proved statically and then measured: a `classScope`-only
    build is byte-identical to the shipped one on a1, a2, a3 **and** on
    SimpleUVM (multiset 0/0).
* `MethodFlags::Constructor` is slang's own answer and is already used twice in
  this file (:1032, :2631). It is set on the in-body constructor AND on the
  out-of-body DEFINITION, so all **three** prints of arm a1's `c_oob::new` —
  including the package-parented one, that arm's own cmp head — are covered.
  Measured: the flag gate is byte-identical to the shipped gate on a1, a2, a3
  and content-identical across all 953 surelog + 679 u2r databases.

### The one thing the patch does NOT change, deliberately

The `$bits(<formal>)` io_decl binder below the site used to read
`tf->Variables()`. A constructor no longer HAS one, so the binder would have
silently stopped running for constructors — a behaviour change smuggled in under
a cosmetic one. The collected vector is hoisted into `fvarsAll71` and the binder
reads **that**, so its input is **identical for constructor and non-constructor
alike, before and after**. The gate changes what is EMITTED and nothing else.

---

## 1. THE CENSUS, BOTH SIDES, SPAN-KEYED — RUN FIRST, BEFORE ANY CODE

### 1.1 The brief's premise, measured and REFUTED

`ct71census.py` lists the WHOLE `vpiMethod` vector of every `class_defn` by
name, in order, merging an object's several full prints and REPORTING rather
than silently reducing any disagreement between them.

| measurement | golden | ours (pristine) |
|---|---|---|
| `class_defn` objects (full prints merged) | **332** | **332** |
| `class_defn` carrying `new` | **269** | **269** |
| `uvm_objection`'s vector length | **32** | **32** |
| `new`'s slot in it | **[0]** | **[0]** |
| `VECTOR_DISAGREE` | **0** | **0** |

The two 32-entry vectors are the same names in the same order. `ct71where.py`
then found the function in the **same four places** on both sides (one FULL
print under `vpiMethod`, three back-references). **Not surplus, not missing, not
re-homed.** The first census I ran keyed on `vpiTaskFunc` and returned `0` on
**both** sides — the vector is `vpiMethod`, and a census that reads zero on both
sides is telling you that you are counting the wrong thing, not that the sides
agree.

### 1.2 The real shape: the CONTAINER's own vector

`ct71fields.py` prints one object's immediate fields. The head, both sides:

| | golden | ours (pristine) |
|---|---|---|
| `vpiParent` | `class_defn uvm_objection` | same |
| **`vpiVariables`** | **— absent —** | **`clp`, `cs_`, `trace_args` (3)** |
| `vpiReturn` | `class_var …::new @127:23` | same |
| `vpiIODecl` | `io_decl name @127:23` | same |
| `vpiStmt` | `begin …::new` | same |

And the `begin` block those three are *supposed* to live on is **identical on
both sides** — 4 variables (`clp`, `cs_`, `trace_args` as `string_var` AND as
`array_var`) and 10 statements, same kinds, same spans, same order. We were not
missing a home for them; we were giving them a second one.

### 1.3 The census-PREDICTION, made before any code was written

`ct71subvars.py` asks the membership question design-wide, one side per run, and
`--tsv` emits one line per subroutine **including the zero-variable ones**, so a
plain `diff` NAMES the disagreeing subroutines instead of leaving a count delta
to be guessed at.

| | golden | ours (pristine) |
|---|---|---|
| subroutine objects (merged) | **3915** | **3915** |
| with `vpiVariables` | 665 | **670** |
| …of those, also on their body stmt | 661 | 666 |
| **constructors (290) with `vpiVariables`** | **0** | **5** |
| **NON-constructors with `vpiVariables`** | **665** | **665** |
| `SUBR_DISAGREE` | 0 | 0 |

The name-keyed diff is **ten lines long and every one of them is a `new`**:

```
< function uvm_pkg::uvm_cmdline_processor::new  0     > ... 3
< function uvm_pkg::uvm_component::new          0     > ... 3
< function uvm_pkg::uvm_heartbeat::new          0     > ... 1
< function uvm_pkg::uvm_objection::new          0     > ... 3
< function uvm_pkg::uvm_port_base::new          0     > ... 2
```

**PREDICTION, recorded before the patched sweep existed** (`ct71predict.py`,
run against the PRISTINE workdirs only — a mover list produced afterwards
predicts nothing):

* **surelog: exactly 7 movers**, by name —
  `default/{SimpleUVM, Scoreboard, SeqDriver, BuildUVMPkg}` and
  `testflags/{SimpleUVM, SeqDriver, BuildUVMPkg}`.
  `Scoreboard/testflags` is `SLANG_REJECT` and has no database.
* **uhdm2rtlil: 0 movers** — 679 databases scanned, not one constructor in the
  corpus carries the vector.
* 953 + 679 databases scanned, **`DUMP_FAIL=0`** on both.

---

## 2. THE GRID, CELL FOR CELL

Two arms, both UVM-free. LHS is ALWAYS golden.

### 2.1 arm a1 — the DECLARATION-FORM axis (`a1_ctor.sv`, package classes)

| cell | written | golden | pristine | **final** |
|---|---|---|---|---|
| in-body ctor | `c_base::new` | 0 | **2** | **0** ✓ |
| ctor calling `super.new` | `c_super::new` | 0 | **1** | **0** ✓ |
| parameterized-class ctor | `c_param::new` | 0 | **1** | **0** ✓ |
| `automatic`-local ctor | `c_auto::new` | 0 | **1** | **0** ✓ |
| **out-of-body `extern` ctor** | `c_oob::new` | 0 | **1** | **0** ✓ |
| — ordinary method | `c_base::meth_with_locals` | 2 | 2 | 2 = |
| — `static` method | `c_base::stat_with_locals` | 1 | 1 | 1 = |
| — task | `c_base::task_with_locals` | 1 | 1 | 1 = |
| — out-of-body method | `c_oob::oob_meth` | 0,1 | 0,1 | 0,1 = |
| — inherited-only class's method | `c_inh::inh_meth` | 1 | 1 | 1 = |
| — parameterized-class method | `c_param::par_meth` | 1 | 1 | 1 = |
| — package function | `p1::pkg_fn` | 1 | 1 | 1 = |
| — module function | `work@a1.mod_fn` | 1 | 1 | 1 = |
| — 18 builtin `mailbox`/`semaphore`/`process` subroutines | | 0 | 0 | 0 = |

`diff` of the FINAL per-subroutine table against GOLDEN's: **empty — every cell
matches golden.** The arm's cmp head was `LHS:<null>` vs
`function (p1::c_oob::new)` — **my shape, on the out-of-body print** — and it
**cleared** (213 → 18 cmp lines; the new head is an `int_typespec` on
`c_param::W`, a different family).

`c_inh` declares **no** constructor; golden lists none for it and neither do we,
before or after. Nothing to move, and nothing moved.

### 2.2 arm a2 — the SITE axis (`a2_site.sv`)

| cell | site | golden | pristine | **final** |
|---|---|---|---|---|
| `c_unit::new` | **`$unit`-scope class** | 0 | **1** | **0** ✓ |
| `c_mod::new` | **module-scope class** | 0 | **1** | **0** ✓ |
| `c_outer::new` | class in a module | 0 | **1** | **0** ✓ |
| `c_outer::c_inner::new` | **NESTED class** | 0 | **1** | **0** ✓ |
| `c_virt::new` | **virtual (abstract) class** | 0 | **1** | **0** ✓ |
| `c_concrete::new` | derived, calls `super.new` | 0 | **1** | **0** ✓ |
| `c_bare::new` | ctor with **NO** body locals | 0 | 0 | 0 = |
| — `c_unit::unit_meth` | control | 1 | 1 | 1 = |
| — `c_mod::mod_meth` | control | 1 | 1 | 1 = |
| — `c_concrete::must_impl` | control (virtual override) | 1 | 1 | 1 = |
| — `c_virt::must_impl` | control (**pure** virtual) | 0 | 0 | 0 = |
| — 18 builtin subroutines | | 0 | 0 | 0 = |

Six constructors across five sites, all six moved to golden; **every control
unchanged**. a2's cmp head was also `LHS:<null>` vs `function (work@c_unit::new)`
and it **cleared** (the new head is a `class_defn` ordering residue on
`c_bare`, unrelated).

`c_bare` is the **byte-identity cell**: a constructor with nothing to remove
must be untouched, and it is.

### 2.3 The patch is a PURE DELETION — measured, not asserted

SimpleUVM's whole database, control vs final, compared as a **MULTISET of
whitespace-normalised lines** (positional `diff` reports re-indentation as
change and would have overstated this by an order of magnitude):

```
MULTISET content delta: removed=30 added=0
  15 x |vpiVariables:              <- 12 variables + 3 for uvm_component::new's
   1 x \_class_var:  128:27  (clp)    SECOND full print (elab + def views)
   1 x \_class_var:  129:23  (cs_)
   1 x \_array_var:  130:12  (trace_args)
   ... 9 more, all inside the five constructors
```

**Nothing was added. Nothing outside the five constructors was touched** — the
diff mentions exactly six fullnames, all of them `…::new` or a local inside one.
And design-wide, `diff` of the FINAL per-subroutine variable table against
GOLDEN's is **empty across all 3915 subroutines**.

---

## 3. THE HEAD, before and after

`rowheads.sh` on the pristine and the final workdir. LHS is ALWAYS golden.

| row | CONTROL cmp lines | head object (CONTROL) | FINAL cmp lines | head object (FINAL) |
|---|---|---|---|---|
| **SimpleUVM/default** | **593** | `LHS:<null>` vs our `function (uvm_pkg::uvm_objection::new) @127:3` | **389** | `function (uvm_pkg::uvm_report_enabled)` vs `RHS:<null>` |
| **SimpleUVM/testflags** | **593** | *same* | **389** | *same* |
| **Scoreboard/default** | **593** | *same* | **389** | *same* |
| SeqDriver/default | 1414881 | `LHS:<null>` vs our `package uvm_pkg @28:1` | 1414833 | **same head OBJECT** |
| SeqDriver/testflags | 1414881 | *same* | 1414833 | *same* |
| BuildUVMPkg/default | 58 | `ref_obj (…uvm_deferred_init) @14107:7` | 58 | **unchanged** |
| BuildUVMPkg/testflags | 58 | *same* | 58 | **unchanged** |
| Scoreboard/testflags | — | `SLANG_REJECT`, no database | — | *same* |

* **All three target rows CLEARED.** The head object changed family, file **and
  SHAPE** — it is now the MIRROR (`LHS:` non-null against `RHS: <null>`), which
  is the strongest possible evidence that the old shape is gone rather than
  displaced. The new head is byte-identical across all three rows (first 14
  lines, ids normalised, `cmp` equal pairwise).
* **`593 -> 389` is HEAD DEPTH, not distance.** The head OBJECT changed, so the
  old divergence is gone; the number is the decompile size of whatever is next.
* **SeqDriver did NOT regress.** Its head is the same `package uvm_pkg` object
  as before (pass 2's `§ instanceIsNeverAClassDefn2` head, still open) —
  verified by `cmp` on the first 6 lines with ids normalised. `-48` lines is the
  decompile of that one head shrinking by the 12 variables this pass removed.
* **BuildUVMPkg is unmoved at 58**, head object `cmp`-identical: its carriers
  sit BEHIND a `hier_path` head this pass does not touch. Its database still
  moves (42 lines removed) — **a head is not a distance.**


---

## 4. THE FIVE GATES

### GATE 1 — BUILD

`cmake --build build -j 2` -> `[100%] Linking CXX executable slang-uhdm` /
`[100%] Built target slang_uhdm`, read before any md5 was taken. Then, in a
SEPARATE command:

```
PRISTINE=c932a66fcafdab8b3f3931adb1657f0c
FINAL=fb78247bbcfe28d39510111bd33252e2
OK: pristine reproduces the committed 730f4bf binary byte-for-byte
OK: BINARY md5 CHANGED c932a66fcafdab8b3f3931adb1657f0c -> fb78247bbcfe28d39510111bd33252e2
32-hex OK
```

### GATE 2 — GOLDENS

`tests/check_goldens.sh` on the FINAL binary: **23 PASS / 0 FAIL**.
NEGATIVE CONTROL `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the control
fires.

### GATE 3 — uhdm2rtlil, `testflags`, `--jobs 2`

**679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump column
**496 match / 183 differ / 52 blank**. WHOLE-ROW judge (`ct8rows.sh`) against
the committed baseline:

```
baseline: 732 lines = 731 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

The PRISTINE sweep was run through the same judge and is **also** 0 differing
ROWS — the control is anchored on the corpus, not just on the binary.

### GATE 4 — surelog, `--mode both`, `--jobs 2`

`default` **469 CMP_EQUAL / 11 CMP_NOTEQUAL** / 5 DEFERRED / 284 SLANG_REJECT /
25 SURELOG_FAIL; `testflags` **465 CMP_EQUAL / 8 CMP_NOTEQUAL** / 5 DEFERRED /
286 SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE /
1 TIMEOUT / 1 NO_UHDM. Dump column 225 match / 244 differ (default), 165 match /
300 differ (testflags). Every figure equals the expected one, and **both
histograms are unchanged**. WHOLE-ROW judge:

```
baseline: 1589 lines = 1588 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

`GOLDEN_DEFER` was left UNSET: the 5 memory-giant tests read `DEFERRED` in both
modes, exactly as the baseline does. The PRISTINE sweep is likewise 0 differing
ROWS.

### GATE 5 — BYTE VERIFIER, both corpora, BOTH modes, vs the PRISTINE 730f4bf workdirs I built

`SELFCHECK=1 SELFCHECK1=1 byteverify.sh <patched-wd> <pristine-wd>`:

```
surelog / both modes:
  databases: patched=953 pristine=953
  PATH_SETS_IDENTICAL (953 paths)
  MOVERS: 7 / 953
  SELFCHECK: 952 / 953 flagged        SELFCHECK1: 8

uhdm2rtlil / testflags:
  databases: patched=679 pristine=679
  PATH_SETS_IDENTICAL (679 paths)
  MOVERS: 0 / 679
  SELFCHECK: 678 / 679 flagged        SELFCHECK1: 1
```

Both negative controls fire on both corpora (`SELFCHECK1`'s 8 = the 7 real
movers plus the one corrupted file).

#### 4.1 THE MOVERS WERE PREDICTED BY NAME BEFORE THE PATCHED SWEEP RAN

§1.3's prediction was **7 on surelog and 0 on uhdm2rtlil**, named, and computed
from the PRISTINE workdirs alone. **The sweep produced exactly those seven and
nothing else** — same names, same modes.

**One statement worth more than the table: NOT ONE `CMP_EQUAL` DATABASE MOVED A
BYTE, IN EITHER CORPUS.** The only 7 databases that changed are the 4 UVM tests
(x modes), all `CMP_NOTEQUAL` before and after. There is therefore no room for a
silent regression inside the 183 + 244 + 300 rows whose dump column reads
`differ`.

#### 4.2 MOVERS PER-SHAPE, BY MULTISET — and every one is a PURE DELETION

`mv71.sh` sorts whitespace-stripped dump lines and diffs the MULTISETS, because
a positional `diff` reports re-indentation as change (it read this patch's
SimpleUVM delta as "210 removed / 180 added"; the content delta is 30/0).

| mover | REMOVED | **ADDED** | size delta |
|---|---|---|---|
| `default/SimpleUVM` | 30 | **0** | −134 |
| `default/Scoreboard` | 30 | **0** | −142 |
| `default/SeqDriver` | 42 | **0** | −199 |
| `default/BuildUVMPkg` | 42 | **0** | −222 |
| `testflags/SimpleUVM` | 30 | **0** | −134 |
| `testflags/SeqDriver` | 42 | **0** | −185 |
| `testflags/BuildUVMPkg` | 42 | **0** | −222 |

**ADDED=0 on all seven.** Every removed line is a `|vpiVariables:` label or a
variable declaration inside one of the five constructors — no other shape
appears in any of the seven diffs.

**THE NOISE FLOOR, measured rather than assumed.** The standing rules warn that
`Scoreboard/default` is nondeterministic and that a ZERO size delta PROVES
NOTHING. So the floor was measured: two sweeps of the **same pristine binary**
into two workdirs gave `Scoreboard/default` **byte-identical** databases —
`REMOVED=0 ADDED=0, size delta 0`. Against that floor, Scoreboard's patched
delta (30 lines, −142 bytes, ADDED=0) is unambiguously real. Every one of the
seven has a NONZERO size delta, and the per-shape content analysis — the
authority named in the rules — agrees with the size reading on all seven.


---

## 5. RESIDUES, RANKED

Ranked by what a next pass would gain.

1. **THE NEW HEAD ON ALL THREE TARGET ROWS — `func_call` binding, ~154 sites,
   and it is NOT this family.** Golden and ours agree on the
   `function (uvm_pkg::uvm_report_enabled)` object field for field (same
   `vpiVariables`, `vpiReturn`, three `vpiIODecl`s, `vpiStmt`, `vpiInstance`).
   The head is `SafeCompare`'s **SCALAR** form: golden holds a pointer to the
   function where ours holds null. Counted directly, golden reaches it from
   **1093** back-references and ours from **939** — **~154 `func_call` sites
   whose `vpiFunction` golden binds and we leave unbound**. This is the
   call-binding family (`§ invalidNewCallFromSyntax55`'s neighbourhood), not the
   variable-ownership family this pass owns, and it is **PRE-EXISTING**: the
   control-vs-final dump diff mentions `uvm_report_enabled` **zero times**.
2. **Subroutine `endln` spans, design-wide.** Visible all through §1.3's
   span-keyed table: golden ends a method at its PROTOTYPE
   (`get_type_name 119:3-119:10`) where we end it at its BODY
   (`119:3-121:14`). It is pervasive (1614 of the 3915 rows differ on span
   alone, against **10** on variable count) and it is why the census had to be
   re-keyed on name. Cheap to characterise, probably one anchor choice.
3. **`c_auto::new`'s `vpiReturn` span** (arm a1): golden anchors the
   constructor's return `class_var` at `124:17-124:39` — a span on the
   DECLARATION line — where ours carries none. Adjacent to
   `§ retNameLocalInstIsHomeNotClass3`; one cell, already isolated in the arm.
4. **arm a2's residual head**: a `class_defn (work@a2::c_bare)` ordering/parent
   divergence under `module_inst work@a2` — module-scope class listing, unrelated
   to this pass.
5. **arm a1's residual head**: `int_typespec` on `p1::c_param::W`, the
   parameterized-class parameter typespec family.


---

## 6. THE CANARIES

| guard | result |
|---|---|
| `canaries.sh` surelog | **ok=52 changed=0 absent=0**, unknown-names=7 (the u2r-only names, the documented number) |
| `canaries.sh` uhdm2rtlil | **ok=8 changed=0 absent=0**, unknown-names=25 (the surelog-only names) |
| `ctcan2.sh` surelog, `EXPECT_UNKNOWN=1` | **ok=58 changed=0 absent=0**, unknown-patterns=**1** — PASS |
| `ctcan2.sh` uhdm2rtlil, `EXPECT_UNKNOWN=6` | **ok=1 changed=0 absent=0**, unknown-patterns=**6** — PASS |
| `canaudit.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** — PASS |
| `InterfaceModPort` BY NAME | `default` + `testflags` both `CMP_EQUAL/differ`, **byte-identical to baseline** |
| `BlackParrotComplex` BY NAME | `default` + `testflags` both `CMP_EQUAL/differ`, **byte-identical to baseline** |

`canaudit.sh` also asserts mechanically that the four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched
by **no driver in this directory** — `FENCE-BREACH=0`.

**BOUNDARIES.** The pass touches ONE site in `src/TaskFuncEmit.cpp`. The live
passes named in the brief are `r10buvm1` (ExprEmit), `r10earl41`
(TypeEmit/ExprEmit/EmitHelpers/UhdmExporter.h) and the ParamEmit/EmitHelpers
constructor-ordering idioms — **no collision**: nothing outside
`TaskFuncEmit.cpp` is edited, and inside it the edit is 3 hunks in one function.
The named owners are untouched and their arms unaffected:
`§ invalidNewCallFromSyntax55` owns new()-**call bind refusals** (this pass
changes no call and no binding — §5 residue 1 shows the call-binding population
is byte-identical before and after); `§ retNameRecvCollapse69`,
`§ implicitRetSigningIsIntVar70` and `§ retNameLocalInstIsHomeNotClass3` own the
**return variable**, which this pass never touches — `vpiReturn` is present and
unchanged on every constructor in both arms and in SimpleUVM, and the loop this
pass gates explicitly skips `sub.returnValVar` (`TaskFuncEmit.cpp:4486`, pre-
existing).

**LANDING HYGIENE.** No `README.verifier.md` was carried forward from any
earlier pass — this directory deliberately contains none, so no stale verifier
file can be mistaken for this pass's. Every script here was RUN in this pass;
`detcheck.sh`/`msdist.sh` were copied in from r10uvm70 and then **deleted**
rather than shipped unrun, because an uncited guard that never ran is the same
defect as a cited guard that does not exist.


---

## 7. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm71repro
# the grid, either binary
SLANG_UHDM=<bin> ./ct71arm.sh a1_ctor.sv /tmp/x_a1
SLANG_UHDM=<bin> ./ct71arm.sh a2_site.sv /tmp/x_a2
python3 ct71subvars.py /tmp/x_a1/g.dump --tsv    # golden;  --list for detail
python3 ct71subvars.py /tmp/x_a1/o.dump --tsv    # ours; diff the two on cols 1,2,4

# the census that refuted the brief (ONE SIDE per run)
python3 ct71census.py <dump> --class 'uvm_pkg::uvm_objection'   # the vpiMethod vector
python3 ct71where.py  <dump> function 'uvm_pkg::uvm_objection::new'
python3 ct71fields.py <dump> function 'uvm_pkg::uvm_objection::new'
python3 ct71subvars.py <dump>                                  # the population

# the mover PREDICTION, from a PRISTINE workdir, before the patched sweep
python3 ct71predict.py <pristine verify_golden workdir>

# the head on the target rows
./rowheads.sh <verify_golden workdir> <outdir> SimpleUVM Scoreboard SeqDriver BuildUVMPkg
```
