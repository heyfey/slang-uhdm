# r10svs7 — § covergroupNewCall7 — the SVSwitch head CLEARED in BOTH modes; **the brief's diagnosis REFUTED: slang BINDS this `new`, it does not refuse it**; SVSwitch did NOT convert because clearing head 1 revealed head 2 (a different family, decoded and prototype-verified below)

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order — every driver here passes them that way.

Base **8633a1e** (`git rev-parse HEAD` printed in §6 for BOTH worktrees).

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 8633a1e) | `29223f08cef6b087c932fb9b30a40bba` | my own full build of pristine 8633a1e in `.claude/worktrees/r10svs7pris` — **byte-identical to the main-tree `build/slang-uhdm`**, which is what makes it a valid control |
| FINAL (gated, shipped) | `25bae76c95acf5cbb298296fe5af8e7f` | every gate below ran on this binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) were **read only**; row counts come
from `ct7rows.sh`'s lines-minus-header arithmetic, never from bare `wc -l`.

---

## 0. HEADLINE — honest, and the first line is a refutation

* **THE BRIEF'S MECHANISM IS WRONG, and the correct one is simpler.** The brief
  said "slang refuses to bind covergroup instantiation `new()` … the bound AST
  carries an invalid/absent call", i.e. § invalidNewCallFromSyntax55's family one
  spelling over. **It does not.** `NewClassExpression::fromSyntax`
  (`slang/source/ast/expressions/AssignmentExpressions.cpp`) opens with

  ```
  // The new keyword can also be used to create covergroups.
  if (syntax.scopedNew->kind == SyntaxKind::ConstructorName && assignmentTarget &&
      assignmentTarget->isCovergroup()) {
      return NewCovergroupExpression::fromSyntax(comp, syntax, context, *assignmentTarget);
  }
  ```

  and only *falls through* to `resolveNewClassTarget` — the routine whose two
  `badExpr` branches pass 55 recovers from — for everything else. So there is no
  `InvalidExpression`, no `badExpr`, and **nothing to recover from the syntax**:
  slang produces a fully BOUND `NewCovergroupExpression` whose actuals are bound
  by `CallExpression::bindArgs` against `CovergroupType::getArguments()`.
  The defect was that `emitExpr` **had no arm for the kind at all**; the
  `default:` label noted it and returned nullptr. EXECUTED, both binaries, on the
  corpus test itself:

  ```
  $ <pristine> -f filelist --single-unit -o m.uhdm ; grep -A4 'unsupported constructs' m.log
  slang-uhdm: unsupported constructs encountered:
    class property type: CovergroupType
    expression kind: NewCovergroup      <-- THE HEAD.  Not "expression kind: Invalid".
    user function call
  $ <FINAL> ... same command
  slang-uhdm: unsupported constructs encountered:
    class property type: CovergroupType
    user function call
  ```

  Consequence for the boundary: **§ invalidNewCallFromSyntax55 is UNTOUCHED in
  its predicate and its emit half.** Its Lhs half is the ONE site this pass
  shares, and it was widened in place (one clause), not forked — see §1.

* **THE SVSwitch HEAD IS CLEARED, BOTH MODES, and the rows did NOT move.**

  ```
  SVSwitch,default,CMP_NOTEQUAL,decompile:,,
  SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
  ```

  byte-identical to `results/golden_surelog.csv`; **no `results/*.csv` was
  touched by this pass.** What moved is the head, identically in both modes:

  ```
  BEFORE (control 8633a1e, BOTH modes)        AFTER (FINAL, BOTH modes)
  LHS:                                        LHS:
  decompile:                                  decompile:
  method_func_call: (new), id:2099            begin: (work@coverage::sample), id:2104,
  |vpiParent:                                       line:36:1, endln:36:26
  \_assignment: , id:2096, line:30:1,         |vpiParent:
                       endln:30:24            \_task: (work@coverage::sample), id:2100
  |vpiName:new                                ... 158 lines ...
  RHS: <null>
  cmp HEAD DEPTH=13  heads=1                  cmp HEAD DEPTH=158  heads=1
  ```

  cmp length is a head-DEPTH measure, not a distance; the distance FELL —
  MULTISET distance to golden **1402 -> 1393**, `diff -u` content **1946 ->
  1945**, both modes (§4).

* **SVSwitch did NOT convert, and the brief's premise that this was "the LAST
  head" was false.** Clearing head 1 exposed head 2 — `Coverage.sv:36`,
  `switch_coverage.sample()`, a covergroup METHOD CALL, a different family — and
  I built a throwaway prototype that clears head 2 as well, which then exposed
  head 3 in a THIRD family (`Environemnt.sv:63`, an `event_control` over a
  virtual-interface path). Both are decoded, with the prototype's measured
  result, in §7 R1/R2. **I did not land head 2's fix**: it is a different law,
  it does not convert the row, and landing two laws in one pass would have made
  the byte-verifier movers unattributable.

* **THE MOVERS ARE EXACTLY THE PREDICTED OBJECTS AND NOTHING ELSE.** Over BOTH
  corpora — 953 surelog databases + 679 uhdm2rtlil databases — the byte verifier
  reports **2 movers total**, `SVSwitch,default` and `SVSwitch,testflags`, with
  both negative controls green (§5). Per shape, ADDED / REMOVED separately:
  **5 object lines ADDED, 0 REMOVED**, all five predicted (§5.2).

* **ONE OPS FACT WORTH CARRYING, measured before it could contaminate an arm.**
  Surelog keeps only the **LAST** statement of a class CONSTRUCTOR body; a
  non-`new` class method keeps them all. Probe `p3_ctorstmt.sv` (quoted in
  §2.1). My first `a1_witness.sv` put three cells in one constructor and Surelog
  silently deleted two of them — which would have read as "golden drops
  covergroup `new`". Every arm here uses **one statement per constructor**.
  SVSwitch's own `function new()` has exactly one statement, which is why the
  corpus head is unaffected by this.

---

## 1. THE LAW

### § covergroupNewCall7

**NAME AS IN THE CODE**, two greppable sites, both in `src/ExprEmit.cpp`:

| site | grep | what it does |
|---|---|---|
| EMIT half | `grep -n '§ covergroupNewCall7 (emit half)' src/ExprEmit.cpp` | the new `case ExpressionKind::NewCovergroup:` arm |
| Lhs half | `grep -n '§ covergroupNewCall7 (Lhs half)' src/ExprEmit.cpp` | ONE extra clause on § invalidNewCallFromSyntax55's EXISTING re-parent gate |

**STATED GATE == CODE GATE.**

* EMIT half. STATED: *the expression kind is exactly
  `ExpressionKind::NewCovergroup`.* CODE: `case ExpressionKind::NewCovergroup:`.
  Nothing else is read — no syntax, no name, no context, no type — so there is
  no name-reading gate here; the object's `vpiName` is the literal string
  `"new"`.
* Lhs half. STATED: *the stripped RHS expression's kind is
  `ExpressionKind::NewCovergroup`.* CODE:
  `stripImplicitConv(*rhsExpr).kind == ExpressionKind::NewCovergroup`, OR-ed
  onto the existing `sourceIsNewClassExpr55(...)`. The two kinds are DISJOINT,
  so the in-law cells can never take my clause and mine can never take theirs.

**ESCAPED IDENTIFIERS — TESTED, NOT REASONED ABOUT (arm a4).** The emit half
reads no name, but the Lhs half hands the Lhs ref's OWN name to the artefact
`hier_path` (`hp->VpiName(((UHDM::ref_obj*)lhs)->VpiName())`), and that line is
now reached by covergroup handles. `a4_escaped.sv` constructs an ESCAPED
covergroup `\esc_cg7 = new();` (F1) and an ESCAPED class handle `\esc_h7 =
new();` (F2, the in-law control for the same line):

| cell | golden | ours CONTROL | ours FINAL |
|---|---|---|---|
| **F1** `\esc_cg7 = new();` | `vpiRhs -> mfc (new)`; Lhs under `hier_path: (esc_cg7)` — the name UNESCAPED | no `vpiRhs`; Lhs at the assignment | **the objects and both names EQ**; the only residual is a SPAN (`assignment` endln golden **26:28** vs ours **26:24**, `ref_obj` endln **26:21** vs **26:20**) |
| **F2** `\esc_h7 = new();` in-law | `hier_path: (esc_h7)` | already EQ | **byte-identical to the CONTROL** — the whole `o.dump` differs only in the workdir path |

The F1 span gap is **PRE-EXISTING and dump-only**: the CONTROL binary already
produced `26:24`/`26:20` before this pass (golden counts the space that
terminates an escaped identifier; we do not). Recorded as a residue of the
escaped-identifier span law, not of this one.

**THE LAW, exactly.**

> An `ExpressionKind::NewCovergroup` emits **the same object the bound
> `case NewClass` arm emits for a plain `new`**: a **LOC-LESS**
> `method_func_call` with `vpiName` `"new"`, `vpiParent` = the caller's parent,
> **no** `vpiFunction`, **no** `vpiPrefix`, **no** file/line, and the
> covergroup's actuals as ordinary `vpiArgument` children emitted through
> `emitExpr` (with `forceConstParent` set for a literal actual, exactly as the
> NewClass arm does, because Surelog parents such a constant AT the call).
> An assignment whose RHS is that expression re-parents its `ref_obj` Lhs through
> the artefact `hier_path` — the identical re-parent a class-handle `= new()`
> already took.

**WHY THE LHS HALF IS THE SAME SITE AND NOT A COPY.** Surelog's rule is a SOURCE
rule about the word `new`: it never type-checks the target, so a covergroup
handle cannot take a different Lhs shape from a class handle, and measurement
says it does not (a1 C1/C2, a2 D3, a3 E3, and the corpus head itself).

---

## 2. THE GRID — cell for cell, every cell EXECUTED

Driver: `ct7arm.sh <arm>.sv <wd>` (golden = Surelog `-parse -nocache`, ours =
`$SLANG_UHDM`, both dumps `sed 1d`). Reader: `ct7cell.sh <wd> <regex> [n]`,
which matches on CONTENT and never on a line number, and prints the side banners
on every run.

**LEGEND.** *EQ* = ours is byte-identical to golden for that cell's subtree.

### 2.1 The hazard that had to be measured FIRST

`p3_ctorstmt.sv` (in this directory), one class, two methods, two statements each — GOLDEN only:

| method | statements written | statements in golden |
|---|---|---|
| `function new()` | `p = 1;` (l.24), `q = 2;` (l.25) | **ONE**: `assignment line:25:7` — the LAST |
| `function void go()` | `p = 3;` (l.28), `q = 4;` (l.29) | **TWO**: `line:28:7` and `line:29:7` |

Pre-existing, orthogonal, and NOT touched by this pass. It is recorded because
it silently deletes arm cells.

### 2.2 Arm a1 — `a1_witness.sv`, the corpus shape and the IN-LAW controls

| cell | source | golden | ours CONTROL | ours FINAL |
|---|---|---|---|---|
| **C1** `cg1 = new();` embedded covergroup | l.31 | `vpiRhs -> method_func_call (new)` loc-less; Lhs `ref_obj` whose `vpiParent` is `hier_path (cg1)` | **NO `vpiRhs` at all**; Lhs parented directly at the `assignment` | **EQ** |
| **C2** `cg2 = new;` (no parens) | l.41 | same objects, same spans | same defect | **EQ** |
| **C3** `h1 = new();` CLASS handle — IN-LAW | l.48 | mfc + `hier_path (h1)` | **already EQ** | **EQ, unchanged** |
| **C4** `h2 = new;` CLASS handle — IN-LAW | l.55 | mfc + `hier_path (h2)` | **already EQ** | **EQ, unchanged** |

**The whole a1 residual is ORDERING.** After the patch the removed/added line
MULTISETS are identical — `removed=163 added=163`, `diff` of the two sorted
multisets = **0 lines**. (Golden lists the module's `vpiClassDefn` children in
the reverse of our order in this arm; that is a pre-existing artefact of the arm,
not of the corpus.)

### 2.3 Arm a2 — `a2_args.sv`, ARGUMENTS

| cell | source | golden's mfc | FINAL |
|---|---|---|---|
| **D1** `cgd1 = new(3)` | l.24 | one `vpiArgument -> constant` `line:24:18-19`, `vpiDecompile:3`, **`vpiParent` = the mfc** | **EQ** |
| **D2** `cgd2 = new(w)` | l.35 | one `vpiArgument -> ref_obj (work@a2::refargs::new::w)` | **EQ** |
| **D3** `cgd3 = new(3, w)` | l.46 | TWO `vpiArgument`s in written order, constant then ref_obj | **EQ** |
| **D4** `h = new(3)` CLASS handle — IN-LAW | l.58 | mfc + `hier_path (h)` + arg | **already EQ; unchanged** |

D1 is what makes `forceConstParent` part of the law rather than a copy-paste:
without it the constant would carry no `vpiParent` and D1 would differ.
**The whole a2 residual is ORDERING too**: `removed=184 added=184`, multiset diff
**0 lines**.

### 2.4 Arm a3 — `a3_context.sv`, every OTHER position

| cell | source | golden | ours CONTROL | ours FINAL | verdict |
|---|---|---|---|---|---|
| **E1** `cgt cgh = new;` at a class-property DECLARATION | l.31 | `logic_var cgh` with `vpiExpr -> method_func_call (new)` parented **at the class_defn** | **the whole variable is ABSENT** (`class property type: CovergroupType`) | still absent | **residue R3** — a DECLARATION law, not an expression law; my arm is `emitExpr` and never runs here |
| **E2** `cgt mv = new;` at MODULE scope | l.34 | `logic_var mv` + `vpiExpr -> method_func_call (new)`, UNPARENTED | **already EQ** (`src/ModuleEmit.cpp`, `grep 'ctCE.kind == SymbolKind::CovergroupType'`) | **EQ, unchanged** | in-law control, PASSES |
| **E3** `mi = new;` in a module `initial` | l.38 | `vpiRhs -> mfc (new)`; Lhs `ref_obj` under `hier_path (mi)` | no `vpiRhs`; Lhs at the assignment with `vpiActual -> logic_net` | **EQ** | **the law is NOT class-scoped** |
| **E4** `this.cg4 = new();` | l.47 | **golden emits NO STATEMENT AT ALL** | ours emits the assignment (pre-existing) | ours emits it, now with a `vpiRhs` | **residue R4**, § thisSuperNewAssignNoStmt3's territory |
| **E5** `q = new[4];` dynamic array | l.54 | `array_var` + no statement | **already EQ** | **EQ, unchanged** | MUST-ABSTAIN control, PASSES: `NewArray` is a different kind with its own arm |

E4 is a REFUTATION of a comment, stated plainly: `src/StmtEmit.cpp`
(`grep -n 'NewCovergroupExpression is deliberately NOT included'`) says a
covergroup handle "is not assignable through `this.` in this corpus". It is
assignable in the LANGUAGE, and when it is, **golden drops the statement** just
as it does for a class handle. That comment's *abstention* is still the right
call for r10svs7 (it is a STATEMENT-LIST law, not an expression law, and the
corpus does not write the shape), but its stated REASON is wrong. Left to its
owner; ranked R4.

### 2.5 The corpus cell itself — `third_party/tests/SVSwitch/Coverage.sv:30`

```
LHS golden                                   RHS ours, FINAL
\_assignment: , line:30:1, endln:30:24       \_assignment: , line:30:1, endln:30:24
  |vpiOpType:82  |vpiBlocking:1                |vpiOpType:82  |vpiBlocking:1
  |vpiRhs:                                     |vpiRhs:
  \_method_func_call: (new)                    \_method_func_call: (new)
    |vpiParent: \_assignment: …30:1…             |vpiParent: \_assignment: …30:1…
    |vpiName:new                                 |vpiName:new
  |vpiLhs:                                     |vpiLhs:
  \_ref_obj: (work@coverage::new::switch_      \_ref_obj: (work@coverage::new::switch_
             coverage), line:30:1, endln:30:16            coverage), line:30:1, endln:30:16
    |vpiParent: \_hier_path: (switch_coverage)   |vpiParent: \_hier_path: (switch_coverage)
    |vpiName:switch_coverage                     |vpiName:switch_coverage
    |vpiFullName:work@coverage::new::switch_…    |vpiFullName:work@coverage::new::switch_…
```

Golden emits **no variable** for the embedded covergroup `switch_coverage` in
`class_defn work@coverage` (its `vpiVariables` holds only `class_var pkt`), and
neither do we — so E1's residue does NOT reach the corpus.

---

## 3. WHAT I DID NOT DO, AND WHY

* **§ invalidNewCallFromSyntax55's predicate and emit half: UNTOUCHED.** Read
  first (`grep -n 'invalidNewCallFromSyntax55' src/ExprEmit.cpp` → 436, 3930,
  16286 on the control) and `tools/probe/r10uvm55repro/README.md` §2/§2a read in
  full. Extending its *syntax* recovery would have been the wrong fix twice
  over: the expression is BOUND, so the recovery has no work to do, and its
  predicate demands `e.kind == Invalid`, which is false here.
* **r10svs6 (fixed-array class properties), r10uvm60 (tf-body constant-arg
  typespecs), r10uvm61 ($bits folding in class-method bodies), r10earl32
  (pkg-param folds in user-func-call args): no overlap.** My diff touches two
  hunks of `src/ExprEmit.cpp`, neither in a typespec, a fold or an argument
  typespec path. NO COLLISION TO REPORT.
* **Head 2's fix: prototyped, measured, NOT landed** (§7 R1).

---

## 4. THE FIVE GATES — every number EXECUTED

### GATE 1 — BUILD

Absolute paths, link line waited for, md5 asserted separately, 32 hex each.

```
CONTROL  /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10svs7pris/build/slang-uhdm
         [100%] Linking CXX executable slang-uhdm     (8 CXX objects, full build)
         md5 29223f08cef6b087c932fb9b30a40bba
         == md5 of the main-tree /home/heyfey/git-repos/slang-uhdm/build/slang-uhdm
         git rev-parse HEAD = 8633a1e6dc9031e3c13862813864f900c324fdf2
FINAL    /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10svs7/build/slang-uhdm
         [100%] Linking CXX executable slang-uhdm
         md5 25bae76c95acf5cbb298296fe5af8e7f
         git rev-parse HEAD = 8633a1e6dc9031e3c13862813864f900c324fdf2
         git status --short:  M src/ExprEmit.cpp   /   ?? tools/probe/r10svs7repro/
```

### GATE 2 — GOLDENS

```
SLANG_UHDM=<FINAL>  tests/check_goldens.sh   ->  PASS 23   FAIL 0
SLANG_UHDM=/bin/false tests/check_goldens.sh ->  PASS  0   FAIL 23     (negative control)
```

### GATE 3 — uhdm2rtlil, testflags, `--jobs 2`

```
[testflags] 731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
DUMP column   52 (blank)   183 differ   496 match
ct7rows.sh vs results/gate_uhdm2rtlil.csv:
  WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, BOTH modes, `--jobs 2`

```
[default]   794 tests  CMP_EQUAL: 467  CMP_NOTEQUAL: 13  DEFERRED: 5
                       SLANG_REJECT: 284  SURELOG_FAIL: 25
[testflags] 794 tests  CMP_EQUAL: 463  CMP_NOTEQUAL: 10  DEFERRED: 5
                       SLANG_REJECT: 286  SURELOG_FAIL: 23  NO_DATABASE: 3
                       NO_UHDM: 1  TIMEOUT: 1  UNTRANSLATABLE: 2
DUMP histograms: default 242 differ / 225 match   testflags 298 differ / 165 match
                 — IDENTICAL to the committed baseline in both modes
ct7rows.sh vs results/golden_surelog.csv:
  WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  PASS: every row byte-identical to the committed baseline
```

**467/13 and 463/10 — the UNCONVERTED numbers.** SVSwitch did not convert, so
the conversion-adjusted variant (468/12 + 464/9) does NOT apply and no
`results/*.csv` was edited.

### GATE 5 — BYTE VERIFIER, both corpora, vs the PRISTINE 8633a1e I built myself

```
surelog   : databases patched=953 pristine=953   PATH_SETS_IDENTICAL (953 paths)
            MOVER ./default/SVSwitch-db796243/slang.uhdm    119237c36e21 vs 2af0c522d0d4
            MOVER ./testflags/SVSwitch-db796243/slang.uhdm  119237c36e21 vs 2af0c522d0d4
            MOVERS: 2 / 953
            SELFCHECK  (every file vs one fixed file): 952 / 953 flagged   [PASS]
            SELFCHECK1 (one file corrupted): 3 = 2 real + 1 corrupted      [PASS]
uhdm2rtlil: databases patched=679 pristine=679   PATH_SETS_IDENTICAL (679 paths)
            MOVERS: 0 / 679
            SELFCHECK: 678 / 679                                          [PASS]
            SELFCHECK1: 1 = 0 real + 1 corrupted                          [PASS]
```

**KNOWN FLAKE, addressed:** `Scoreboard,default` is bistable. It did **not**
appear as a mover in this run, so no reps were needed to attribute it; the two
movers are the two SVSwitch rows and nothing else.

### 5.2 MOVERS PER SHAPE, by MULTISET, ADDED and REMOVED SEPARATELY

`msmovers.sh <golden.uhdm> <pristine slang.uhdm> <patched slang.uhdm>` — DUMPS
with `sed 1d`, never the `.uhdm` binaries. **Identical output for both modes:**

```
MULTISET distance to GOLDEN   PRISTINE: golden-only 517  ours-only 885  TOTAL 1402
MULTISET distance to GOLDEN   PATCHED : golden-only 507  ours-only 886  TOTAL 1393

OBJECT lines (\_ marker):
ADDED   +1  \_assignment: , line:30:1, endln:30:24
ADDED   +1  \_hier_path: (switch_coverage)          (in-tree occurrence)
ADDED   +1  \_hier_path: (switch_coverage)          (flat-listing occurrence, other indent)
ADDED   +1  \_method_func_call: (new)
ADDED   +1  \_ref_obj: (work@coverage::new::switch_coverage), line:30:1, endln:30:16
REMOVED     (none)

BARE FIELD lines — NON-ATTRIBUTABLE absorbers, listed and NOT counted:
ADDED +1 |vpiActual:   |vpiName:new   |vpiName:switch_coverage
         |vpiParent: (x2)   |vpiRhs:
```

**Every one of the five object lines is an object golden HAS**: the ours-side
file grew by 11 lines, `golden-only` fell by **10**, and the single remaining
ours-only instance is the bare field line `  |vpiParent:` at depth 2 —
established by differencing the per-shape excess-over-golden tables of the two
binaries, whose ONLY difference is:

```
< +10   |vpiParent:        (pristine)
> +11   |vpiParent:        (patched)
```

i.e. **no OBJECT line is in excess on our side**, and the one non-matching
addition is exactly the class of line the measurement law calls non-attributable.

### CANARIES

```
ctcan2.sh  golden_surelog.csv   sl_pat.csv    EXPECT_UNKNOWN=1 -> ok=58 changed=0 absent=0 unknown=1  PASS
ctcan2.sh  gate_uhdm2rtlil.csv  u2r_pat.csv   EXPECT_UNKNOWN=6 -> ok=1  changed=0 absent=0 unknown=6  PASS
canaries.sh sl_pat.csv  golden_surelog.csv  -> ok=52 changed=0 absent=0 unknown-names=7   (surelog: expected 7)
canaries.sh u2r_pat.csv gate_uhdm2rtlil.csv -> ok=8  changed=0 absent=0 unknown-names=25  (u2r: expected 25)
canaudit.sh canaries.sh ctcan2.sh -> audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS

BY NAME, quoted:
  InterfaceModPort     default   OK  CMP_EQUAL/differ
  InterfaceModPort     testflags OK  CMP_EQUAL/differ
  BlackParrotComplex   default   OK  CMP_EQUAL/differ
  BlackParrotComplex   testflags OK  CMP_EQUAL/differ
  SVSwitch             default   OK  CMP_NOTEQUAL/
  SVSwitch             testflags OK  CMP_NOTEQUAL/
```

The four SLANG-FENCED names (UnsignedParam, HierPathEval, FileLocalParam,
TopParam) are dispatched by NO driver in this directory — asserted by
`canaudit.sh`, not by a sentence.

---

## 6. REPRODUCING

```
tools/probe/r10svs7repro/
  ct7arm.sh      one arm: surelog golden + ours + cmp + dump distance (SLANG_UHDM required, no default)
  ct7cell.sh     read ONE cell out of an arm workdir, by CONTENT, with side banners
  ct7rows.sh     THE ROW GATE: whole-row diff vs a committed baseline + histograms
  byteverify.sh  GATE 5, with both negative controls (SELFCHECK / SELFCHECK1)
  msdist.sh      resync-immune MULTISET dump distance (golden vs ours)
  msmovers.sh    per-shape movers for ONE database, ADDED / REMOVED separate
  ctcan2.sh canaries.sh canaudit.sh   the canaries and the AUDIT of the canaries
  a1_witness.sv a2_args.sv a3_context.sv a4_escaped.sv   the grid
  p3_ctorstmt.sv the HAZARD probe (Surelog keeps only the LAST ctor statement)
```

```
SLANG_UHDM=<binary> ./ct7arm.sh a1_witness.sv /tmp/x_a1
./ct7cell.sh /tmp/x_a1 'assignment: , line:31:7' 16
```

---

## 7. RANKED RESIDUES

| # | residue | evidence | who |
|---|---|---|---|
| **R1** | **SVSwitch head 2 — `Coverage.sv:36`, `switch_coverage.sample()`.** golden emits `method_func_call (sample)` @36:17-36:23 with `vpiPrefix -> ref_obj (work@coverage::sample::switch_coverage)` @36:1-36:16; ours emits NOTHING (`unsupported: user function call`). MECHANISM: the built-in `sample` is added to a `CovergroupBodySymbol` (`slang/source/ast/symbols/CoverSymbols.cpp`, `MethodBuilder sample(comp, "sample"sv, …); body->addMember(sample.symbol);`), so `sub.getParentScope()->asSymbol().kind == SymbolKind::CovergroupBody`, a kind absent from the fallback chain in `src/ExprEmit.cpp` — it falls to the final `else { noteUnsupportedAt("user function call", …); return nullptr; }`. FIX SHAPE, **prototype-verified**: the INTERFACE-method-through-port arm immediately below (`grep -n 'INTERFACE method calls through a port' src/ExprEmit.cpp`) already builds precisely golden's object; gating a copy of it on `SymbolKind::CovergroupBody` CLEARS head 2. Prototype diff kept in this directory as `residue_R1_prototype.diff.txt` (built, run, measured — NOT landed, NOT gated). | `residue_R1_prototype.diff.txt`; cmp head 158 lines -> 48 lines, both modes | next pass — **rank 1**, it is the whole of SVSwitch's next head |
| **R2** | **SVSwitch head 3** (revealed only by R1's prototype): `Environemnt.sv:63`, `@(input_intf.clock)` — golden's `event_control` holds ONE `ref_obj (work@Environment::reset::input_intf)` @63:16-63:32 named for the WHOLE dotted text; ours builds a two-element `hier_path (input_intf.clock)`. A virtual-interface event-control naming law, third family. | the same prototype run, quoted in `residue_R1_prototype.diff.txt`'s header | next-but-one; **SVSwitch needs at least R1+R2 to convert** |
| **R3** | a class PROPERTY of a NAMED covergroup type (`cgt cgh = new;`) is dropped entirely (`unsupported: class property type: CovergroupType`); golden emits a `logic_var` with `vpiExpr -> method_func_call (new)` parented at the **class_defn**. A DECLARATION law (`emitClassDefn`), sibling to the module-scope arm that already exists in `src/ModuleEmit.cpp`. NOT in the corpus: the corpus writes the EMBEDDED covergroup form, for which golden emits no variable at all. | arm a3 cell E1 | whoever owns class-property emission |
| **R4** | `this.<cg> = new();` — golden emits NO STATEMENT; ours does. § thisSuperNewAssignNoStmt3's RHS half keys on the SYNTAX kind `NewClassExpression`, which this shape HAS, so the miss is in its LHS half, and its comment's stated reason ("a covergroup handle is not assignable through `this.`") is REFUTED by arm a3 cell E4. Not in the corpus. | arm a3 cell E4 | § thisSuperNewAssignNoStmt3's owner |
| **R5b** | ESCAPED-identifier SPANS: golden's `assignment` / `ref_obj` end columns run one past ours for an escaped name (arm a4 F1: 26:28 vs 26:24, 26:21 vs 26:20). PRE-EXISTING on the control binary, dump-only, untouched here. | arm a4 cell F1, both binaries | span owner |
| **R5** | module-scope covergroup handle spans: golden `logic_var mv` ends at **34:15** (through the initializer), ours at **34:9** (the name token); and `cgt mi;` is a `logic_net` in golden, a `logic_var` in ours. Dump-only, pre-existing, untouched. | arm a3, E2 region | span/kind owner |
| **R6** | Surelog keeps only the LAST statement of a class CONSTRUCTOR body (§2.1). Ours keeps them all. Not in the corpus (SVSwitch's `new` has one statement) but it WILL bite any future arm that does not know it. | `p3_ctorstmt.sv` | recorded, not claimed |

---

## 8. THE DIFF

`src/ExprEmit.cpp` only, two hunks:

1. a new `case ExpressionKind::NewCovergroup:` arm, inserted immediately after
   `case ExpressionKind::NewClass:` and before `case
   ExpressionKind::AssertionInstance:`, carrying the § covergroupNewCall7 NOTE
   block with the slang citation;
2. one extra OR clause on § invalidNewCallFromSyntax55's Lhs-half gate, with its
   own § covergroupNewCall7 (Lhs half) NOTE naming the four cells and the corpus
   site that justify it.

Nothing else in `src/` is touched; nothing outside my worktree was written.
