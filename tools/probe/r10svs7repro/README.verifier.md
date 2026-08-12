# r10svs7 — ADVERSARIAL VERIFIER REPORT — § covergroupNewCall7

**VERDICT: PASS** — every number in the implementer's write-up reproduced on a
binary I built myself from a FRESH 8633a1e checkout + `/tmp/r10svs7.patch`, all
five gates are green, the byte verifier moves exactly the two SVSwitch rows and
nothing else, and the brief's own mechanism is confirmed REFUTED by reading
slang's source. **Five findings below**; none of them is a gate failure and none
of them reaches a comparable corpus database today, but **F1 is a real defect of
the stated law** and should be closed (or explicitly fenced in the law's comment)
before or at landing.

LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours. Every dump pair is `sed 1d`'d.

---

## 0. MY OWN BINARIES — independently built, BASE printed and grep-checked

| binary | worktree | `git rev-parse HEAD` | md5 |
|---|---|---|---|
| PRISTINE control | `.claude/worktrees/r10svs7vp` (clean, `git status --porcelain` EMPTY) | `8633a1e6dc9031e3c13862813864f900c324fdf2` | `29223f08cef6b087c932fb9b30a40bba` |
| PATCHED | `.claude/worktrees/r10svs7v` (`M src/ExprEmit.cpp`, `?? tools/probe/r10svs7repro/`) | `8633a1e6dc9031e3c13862813864f900c324fdf2` | `25bae76c95acf5cbb298296fe5af8e7f` |
| R1 PROTOTYPE (throwaway, removed) | `.claude/worktrees/r10svs7vproto` | `8633a1e6dc…` | `bc4908d1d2af31daae59a5e176dc2a5f` |

Both md5s are **bit-for-bit the implementer's** (`25bae76c…` / `29223f08…`), and
the pristine one equals the main-tree `build/slang-uhdm` — so the control is
valid and the build is reproducible across worktrees. Patch applied clean:

```
$ git apply --check /tmp/r10svs7.patch   ->  APPLY_CHECK_OK
$ md5sum /tmp/r10svs7.patch              ->  c458337dd7acbcc6cd26fe3f432db917
$ git apply --stat /tmp/r10svs7.patch    ->  src/ExprEmit.cpp | 76 +++ (75 ins / 1 del)
                                             + 16 files under tools/probe/r10svs7repro/ ONLY
```

No `results/*.csv` in the patch; `git diff HEAD -- results/` in the main tree is
EMPTY. `git stash` never used.

---

## 1. EVERY NUMBER, REPRODUCED

### The rows — FIRST, verbatim from MY OWN fresh sweep

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

byte-identical to `results/golden_surelog.csv` and to my pristine sweep.
**SVSwitch did NOT convert. CONFIRMED.**

### The head — I re-ran SVSwitch myself in BOTH modes

Command (the harness's own, read out of `cmds.txt`): `-f filelist --single-unit`
for `default`, `--timescale 1ns/1ns -f filelist --single-unit` for `testflags`;
golden from the harness cache (`a3cf5937…` / `4535580a…`).

| | pristine | patched |
|---|---|---|
| cmp rc | 255 | 255 |
| heads (`grep -c '^LHS:'`) | 1 | 1 |
| cmp lines (HEAD DEPTH) | **13** | **158** |
| MULTISET distance to golden | **1402** | **1393** |
| `diff -u` content | **1946** | **1945** |
| our dump lines | 25686 | 25697 (+11) |
| golden-only line instances | 517 | **507** |

**Identical in both modes** (`cmp_pat_default.log` and `cmp_pat_testflags.log`
are the same file after path-normalisation). Head 1 (`method_func_call: (new),
id:2099` / `RHS: <null>` @ `Coverage.sv:30`) is GONE; the new head is
`begin: (work@coverage::sample) … line:36:1` — exactly as reported.

The unsupported-construct log difference is the reported one, executed on both
binaries over the corpus test itself:

```
$ diff pris_testflags.log pat_testflags.log
3d2
<   expression kind: NewCovergroup
```

### Movers per shape, ADDED / REMOVED separate (`msmovers.sh`)

```
OBJECT lines (\_ marker):
ADDED   +1  \_assignment: , line:30:1, endln:30:24
ADDED   +1  \_hier_path: (switch_coverage)          (x2 — tree + flat listing)
ADDED   +1  \_method_func_call: (new)
ADDED   +1  \_ref_obj: (work@coverage::new::switch_coverage), line:30:1, endln:30:16
REMOVED     (none)
```

and I re-derived the non-attributability claim independently, by differencing the
two binaries' **excess-over-golden** tables (per distinct dump line,
`ours_count - golden_count` where positive):

```
$ diff ex_pris.txt ex_pat.txt
2c2
< +10	  |vpiParent:
---
> +11	  |vpiParent:
```

**One line differs, and it is a bare field line.** No object line entered excess
on the corpus database. CONFIRMED.

### GATE 2 — goldens

```
SLANG_UHDM=<my patched>  tests/check_goldens.sh  ->  PASS 23  FAIL 0
SLANG_UHDM=/bin/false    tests/check_goldens.sh  ->  PASS  0  FAIL 23
```
(run from the repo root, per the standing rules.)

### GATE 3 — uhdm2rtlil testflags, `--jobs 2`, my own `--out`/`--workdir`

```
[testflags] 731 tests  CMP_EQUAL: 679  SLANG_REJECT: 50  SURELOG_FAIL: 2
ct7rows.sh results/gate_uhdm2rtlil.csv <mine>:
  WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  DUMP histogram testflags: 52 blank / 183 differ / 496 match  — base == fresh
  PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog BOTH modes, `--jobs 2`

```
[default]   794 tests  CMP_EQUAL: 467  CMP_NOTEQUAL: 13  DEFERRED: 5
                       SLANG_REJECT: 284  SURELOG_FAIL: 25
[testflags] 794 tests  CMP_EQUAL: 463  CMP_NOTEQUAL: 10  DEFERRED: 5
                       SLANG_REJECT: 286  SURELOG_FAIL: 23  NO_DATABASE: 3
                       UNTRANSLATABLE: 2  TIMEOUT: 1  NO_UHDM: 1
ct7rows.sh results/golden_surelog.csv <mine>:
  WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  DUMP histograms  default 242 differ / 225 match   testflags 298 differ / 165 match
                   — base == fresh in both modes
  PASS: every row byte-identical to the committed baseline
```

**The UNCONVERTED numbers are the right ones.** SVSwitch stayed `CMP_NOTEQUAL`
in both modes, so the conversion-adjusted variant (468/12 + 464/9, 4 differing
row-sides) does NOT apply, and no `results/*.csv` was touched by either of us.

### GATE 5 — byte verifier vs MY OWN pristine 8633a1e build

```
surelog   : databases patched=953 pristine=953   PATH_SETS_IDENTICAL (953 paths)
            MOVER ./default/SVSwitch-db796243/slang.uhdm    119237c36e21 vs 2af0c522d0d4
            MOVER ./testflags/SVSwitch-db796243/slang.uhdm  119237c36e21 vs 2af0c522d0d4
            MOVERS: 2 / 953
            SELFCHECK 952 / 953      SELFCHECK1 = 3 (2 real + 1 corrupted)
uhdm2rtlil: databases patched=679 pristine=679   PATH_SETS_IDENTICAL (679 paths)
            MOVERS: 0 / 679
            SELFCHECK 678 / 679      SELFCHECK1 = 1 (0 real + 1 corrupted)
```

Even the per-file md5 prefixes match the implementer's report. The
**Scoreboard/default bistability did not fire in my run either**, so no reps were
needed to attribute the movers.

### CANARIES

```
ctcan2.sh golden_surelog.csv  <mine>  EXPECT_UNKNOWN=1 -> ok=58 changed=0 absent=0 unknown=1  PASS
ctcan2.sh gate_uhdm2rtlil.csv <mine>  EXPECT_UNKNOWN=6 -> ok=1  changed=0 absent=0 unknown=6  PASS
canaries.sh <mine sl>  golden_surelog.csv  -> ok=52 changed=0 absent=0 unknown-names=7
canaries.sh <mine u2r> gate_uhdm2rtlil.csv -> ok=8  changed=0 absent=0 unknown-names=25
canaudit.sh canaries.sh ctcan2.sh -> audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
  (UnsignedParam / HierPathEval / FileLocalParam / TopParam: dispatched by NO driver)

BY NAME, from my own CSV:
  InterfaceModPort   default/testflags   CMP_EQUAL,,,differ
  BlackParrotComplex default/testflags   CMP_EQUAL,,,differ
  SVSwitch           default/testflags   CMP_NOTEQUAL,decompile:,,
```

---

## 2. THE MECHANISM CLAIM — I read slang myself; the REFUTATION HOLDS

`~/git-repos/slang/source/ast/expressions/AssignmentExpressions.cpp:668-676`
opens `NewClassExpression::fromSyntax` with exactly the quoted branch, and
`NewCovergroupExpression::fromSyntax` (:741-756) binds the actuals through
`CallExpression::bindArgs` and returns a **real** `NewCovergroupExpression` — it
reaches `badExpr` only when `bindArgs` itself fails. `resolveNewClassTarget` (the
routine whose two `badExpr` branches § invalidNewCallFromSyntax55 recovers from)
is only reached AFTER that branch falls through. **The brief's "slang refuses to
bind covergroup `new()`" is false, and the implementer's diagnosis is right.**

**Gate disjointness, verified in the code and not by assertion.**
`sourceIsNewClassExpr55` (`src/ExprEmit.cpp:461-476`) returns true only for
`ExpressionKind::NewClass` or for `ExpressionKind::Invalid` carrying
`NewClassExpressionSyntax`. `NewCovergroup` is neither, so the OR-ed clause can
never capture a pass-55 cell and pass-55's clause can never capture a covergroup.
STATED GATE == CODE GATE for both halves.

**§ invalidNewCallFromSyntax55's arms still pass, byte-for-byte.**
`tools/probe/r10uvm55repro/gold.sh a1` run with BOTH binaries:

```
patched  ours.uhdm md5 c5a5ca10e6ee1d970dac221fe9d21aa4   cmp rc=255 lines=22 heads=1
pristine ours.uhdm md5 c5a5ca10e6ee1d970dac221fe9d21aa4   cmp rc=255 lines=22 heads=1
$ cmp patched/ours.uhdm pristine/ours.uhdm  ->  identical
```

**No collision with the live passes.** `git diff -U0` hunk headers:
`r10uvm61` touches `src/ExprEmit.cpp` at 1161 / 11191 / 11209 (+`include/UhdmExporter.h`);
`r10earl32` at 4524 / 4528 / 5710 / 10545 (+`ParamEmit.cpp`); this patch at
**3936** and **15830**. Disjoint textually, and neither law reads the
`NewCovergroup` kind. **NO COLLISION TO REPORT** — see F5 for one merge-ordering
note about r10earl32's base.

**Residue R1 — I built the prototype and re-measured it.** Applied
`residue_R1_prototype.diff.txt` to a fresh 8633a1e, built
(`bc4908d1d2af31daae59a5e176dc2a5f`), ran SVSwitch in both modes:
cmp **158 -> 48 lines, heads=1, still rc=255**, and head 3 is

```
LHS: ref_obj: (work@Environment::reset::input_intf), id:1680, line:63:16, endln:63:32
     |vpiParent: \_event_control: , id:1679, line:63:14, endln:63:32
```

i.e. **R1 and R2 are both exactly as described**, and the prototype is correctly
NOT in the patch. Worktree removed after measuring.

**Residue R6 — confirmed** (`GOLDEN_ONLY=1 ct7arm.sh p3_ctorstmt.sv`): golden's
`function new()` keeps only the LAST of its two assignments, the non-ctor
`function void go()` keeps both. See F4 for a line-number nit in its write-up.

---

## 3. FINDINGS — numbered, each with the command that produced it

### F1 — REAL DEFECT, latent: the emit half emits one `vpiArgument` per **FORMAL**, not per **WRITTEN ACTUAL**

**Arm: `v1_defaultargs.sv` (new, in this directory).** A covergroup with
DEFAULT-valued formals, `covergroup cgd (int a = 5, int b = 7)`:

```
$ SLANG_UHDM=<patched> ./ct7arm.sh v1_defaultargs.sv /tmp/svs7v/v1_pat
$ ./ct7cell.sh /tmp/svs7v/v1_pat 'assignment: , line:34' 20
```

| cell | source | golden's mfc args | OURS (patched) |
|---|---|---|---|
| **G1** | `g1 = new;` | **NONE** | **TWO** constants `5` @**22:27** and `7` @**22:38** — spans pointing at the covergroup DECLARATION |
| **G2** | `g2 = new(1);` | ONE: `1` @39:14 | **TWO**: `1` @39:14 **+ `7` @22:38** |
| **G3** | `g3 = new(1, 2);` | TWO: `1`, `2` | **EQ** (control) |
| **G4** | `g4 = new(.b(9));` | ONE: `9` @49:17 | **TWO**, and in the WRONG ORDER: `5` @22:27 **then** `9` |

MECHANISM: `CallExpression::bindArgs` fills `expr = formal->getDefaultValue()`
for every unwritten formal (`~/git-repos/slang/source/ast/expressions/
CallExpression.cpp:258-260`), so `NewCovergroupExpression::arguments` is
FORMAL-length, not source-length. The neighbouring `case ExpressionKind::NewClass:`
arm in the same switch does **not** have this problem because
§ writtenCallArgs16 recounts the actuals off the syntax
(`nw9 = nsy9->argList ? nsy9->argList->parameters.size() : 0`) and truncates.
**The new arm is the same shape as its neighbour in every respect EXCEPT the one
guard that neighbour needed.** The stated law says "the covergroup's ACTUALS as
ordinary `vpiArgument` children … the same object the bound `NewClass` arm emits";
in these cells the code and the stated law disagree, and golden sides with the
stated law.

**REACH — measured, not assumed. Zero, today.**
* Byte verifier: 0 movers outside the two SVSwitch rows over 953 + 679 databases.
* Source survey of both corpora for a covergroup with formals:
  `grep -rInE '^[[:space:]]*covergroup[[:space:]]+[A-Za-z_][A-Za-z_0-9]*[[:space:]]*\('`
  → 19 sites; only two carry a DEFAULT (`bit_toggle_cg(string name, bit
  toggle_cov_en = 1)`, Opentitan + Ibex `dv_base_env_cov.sv:12`), both instantiate
  it with **all** actuals written (`bit_toggle_cg = new(name, toggle_cov_en);`),
  and both tests are `SLANG_REJECT` in both modes.

**MITIGATING, and worth stating fairly:** the identical over-fire ALREADY EXISTS
at the sibling site `src/ModuleEmit.cpp:5888` (the module-scope covergroup
declaration-initializer arm), on BOTH binaries — arm `v2_places.sv` cell **H1**
(`cgp h1 = new;`) shows golden with a bare `method_func_call (new)` and ours,
**pristine and patched alike**, with a spurious `constant 5 @11:27`. So the new
arm replicates a pre-existing gap rather than inventing one.

**RECOMMENDATION:** either carry § writtenCallArgs16's syntax recount into the
`NewCovergroup` arm (the syntax is `NewClassExpressionSyntax` here too, so it is
the same three lines), or state the boundary explicitly in the law's NOTE so the
next pass does not read the current comment as "measured". Not a landing blocker
on this corpus.

### F2 — SCOPE NIT on the "no object line is in excess" claim: true for the corpus database, FALSE for an escaped identifier

**Arm: `v3_lhsforms.sv` cell J5** (`\esc_j5 = new();` inside a class method).
Differencing the excess-over-golden tables for that arm, pristine vs patched:

```
$ diff ex3_pris.txt ex3_pat.txt
2a3
> +1	  \_assignment: , line:44:7, endln:44:22
```

i.e. the patch DOES put one OBJECT line into excess here. It is not a structural
over-emit — both sides carry the same five occurrences — it is the **pre-existing
escaped-identifier span defect (the write-up's R5b)**: golden's assignment ends
at `44:26`, ours at `44:22`, so the artefact `hier_path`'s parent line is a
different string on the two sides and cannot cancel. The patch therefore
**enlarges R5b's footprint by one dump occurrence per escaped covergroup
assignment**, with zero corpus reach. The implementer's claim is correct as
stated *about the SVSwitch database*; it does not generalise, and the write-up
does not claim that it does.

### F3 — R4's scope is narrower than written

`this.<cg> = new()` with a **NAMED covergroup-type** class property (arm
`v3_lhsforms.sv` cell J2, `this.j2 = new;`): golden emits a `logic_var
(work@v3::kls::j2)` and **no statement**; ours emits **neither the variable nor
the statement** — so for this sub-cell ours already agrees with golden about the
statement, for the wrong reason (R3's `class property type: CovergroupType` drop
swallows it). R4's "ours emits it" holds for the EMBEDDED form the implementer
measured (a3 E4), not for the named-type form. Refinement of a residue, not a
defect of the pass.

### F4 — documentation nit: `README.md` §2.1's line numbers are off by one

`p3_ctorstmt.sv` has `p = 1;` at **l.25** and `q = 2;` at **l.26**, and golden's
single surviving constructor assignment is `line:26:7` — the README says l.24 /
l.25 and `line:25:7`. The R6 substance is confirmed exactly; only the citations
are shifted.

```
$ grep -n 'p = 1' p3_ctorstmt.sv         -> 25:      p = 1;
$ grep -E '\\_assignment: ' /tmp/svs7v/p3/g.dump | sort -u
        \_assignment: , line:26:7, endln:26:12      <- new(): the LAST only
        \_assignment: , line:29:7, endln:29:12      <- go(): both kept
        \_assignment: , line:30:7, endln:30:12
```

### F5 — merge-ordering note (not a collision)

`r10earl32`'s worktree sits on `981f2e3`, and `git merge-base --is-ancestor
8633a1e 981f2e3` is FALSE — that pass is not based on this pass's base. Its
`ExprEmit.cpp` hunks do not touch either of r10svs7's sites, so there is no
textual conflict, but whoever lands both should confirm the base relationship
rather than assume a fast-forward.

---

## 4. EMPTY PRODUCT CELLS I HUNTED — and what they say

New arms in this directory, all run with BOTH binaries. `EQ` = ours byte-identical
to golden for that cell's subtree.

| arm / cell | shape | verdict |
|---|---|---|
| `v1` G1/G2/G4 | covergroup with DEFAULTED formals, under-written call | **OVER-FIRE — F1** |
| `v1` G3 | all formals written | EQ |
| `v2` H1 | module-scope DECLARATION initializer, defaulted formal | over-fire, **PRE-EXISTING** (`ModuleEmit.cpp`), both binaries |
| `v2` H2 | `h2arr[0] = new(1)` — ARRAY-ELEMENT Lhs (`bit_select`, so the re-parent must NOT fire) | mfc + args EQ; Lhs residual is a pre-existing span (`22:12` vs `22:13`) |
| `v2` H3 | `hh.hc = new(3)` — through ANOTHER object's handle (Lhs already a `hier_path`) | mfc + args EQ; pre-existing span residual |
| `v2` H4 | EMBEDDED covergroup in the CONSTRUCTOR (the corpus shape) | EQ. NB slang REJECTS the assignment anywhere else: `error: cannot assign to read-only variable 'emb'` |
| `v2` H5 | STATIC method context (`o.hc = new(2)`) | EQ |
| `v2` K1/K2/K3/K4 | class handle `new(9)` / bare `new` / `derived` chaining `super.new` / `int k4[] = new[4]` | **byte-identical to pristine** — MUST-ABSTAIN holds |
| `v3` J1 | implicit-`this` property in a NON-constructor method | **byte-identical to golden** |
| `v3` J2 | `this.<named-cg> = new` | see F3 |
| `v3` J3 | STATIC property from a static method | EQ |
| `v3` J4 | inside an `if` (not the block's last statement) | **byte-identical to golden**, `if_stmt` parent and all |
| `v3` J5/J6 | ESCAPED covergroup / ESCAPED class handle | objects and names EQ; span residue F2 |
| `v4` M1 | STRING literal + int literal actuals | **byte-identical to golden** |
| `v4` M2 | OPERATOR-expression actual (`w + 1`) | **byte-identical to golden** — `forceConstParent` does not leak to operands |
| `v4` M3 | PARAMETER-reference actual | **byte-identical to golden** |

Whole-arm distances (MULTISET, golden vs ours), pristine -> patched:
`a1` 326-content -> **0**, `a2` 368 -> **0** (pure ordering, confirming the
implementer's 163/163 and 184/184), `v2` 129 -> **79**, `v3` 110 -> **68**,
`v4` 158 -> **60**. The law improves every arm it touches and regresses none.

---

## 5. RANKED RESIDUES (verifier's ranking)

1. **R1 — SVSwitch head 2**, `Coverage.sv:36` `switch_coverage.sample()`
   (`CovergroupBody` parent scope absent from the call fallback chain).
   **Independently re-measured: 158 -> 48 cmp lines, both modes.** Rank 1: it is
   the whole of the next head and its prototype already exists.
2. **R2 — SVSwitch head 3**, `Environemnt.sv:63` `@(input_intf.clock)`: golden one
   `ref_obj` named for the whole dotted text, ours a two-element `hier_path`.
   **Quoted from my own prototype run.** SVSwitch needs at least R1 + R2.
3. **F1 — the written-actual guard** on the covergroup `new` arm (and its
   pre-existing twin in `ModuleEmit.cpp`). Zero reach today, three lines to fix,
   and it is the kind of latent over-fire that becomes a mystery mover later.
4. **R3** — a class property of a NAMED covergroup type is dropped entirely
   (`class property type: CovergroupType`); golden emits a `logic_var` with
   `vpiExpr -> mfc(new)` at the class_defn. Confirmed on `v3` (golden line 529,
   ours nothing).
5. **R5b / F2** — escaped-identifier end-column spans; pre-existing, now with one
   more dump occurrence per escaped covergroup assignment.
6. **R4 (as refined by F3)**, **R5**, **R6** — as written.

---

## 6. REPRODUCING THIS REPORT

```
git worktree add -f .claude/worktrees/r10svs7v  --detach 8633a1e
git worktree add -f .claude/worktrees/r10svs7vp --detach 8633a1e
(cd .claude/worktrees/r10svs7v && git apply /tmp/r10svs7.patch)
for w in r10svs7v r10svs7vp; do cmake -S .claude/worktrees/$w -B .claude/worktrees/$w/build \
    -DCMAKE_BUILD_TYPE=Release && cmake --build .claude/worktrees/$w/build -j 8; done
# gates 3/4/5 (from the repo ROOT, absolute SLANG_UHDM):
SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus surelog    --mode both      --jobs 2 --out <csv> --workdir <wd>
SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 --out <csv> --workdir <wd>
tools/probe/r10svs7repro/ct7rows.sh results/golden_surelog.csv <csv>
SELFCHECK=1 SELFCHECK1=1 tools/probe/r10svs7repro/byteverify.sh <wd_patched> <wd_pristine>
# the new verifier arms:
SLANG_UHDM=<bin> tools/probe/r10svs7repro/ct7arm.sh v1_defaultargs.sv /tmp/x_v1
tools/probe/r10svs7repro/ct7cell.sh /tmp/x_v1 'assignment: , line:34' 20
```

My sweep workdirs (`/tmp/svs7v/wd_*`) were deleted after the gates; the CSVs and
the arm workdirs were kept for the citations above. The throwaway prototype
worktree `r10svs7vproto` was removed with `git worktree remove --force`.

**One main-tree side effect I did NOT cause but did verify:** `scripts/__pycache__/`
and `tools/probe/r10earl31repro/__pycache__/` are present and untracked
(interpreter bytecode, no content edit), as the implementer declared;
`git diff HEAD -- results/` is EMPTY, so no baseline CSV was touched by anyone.
