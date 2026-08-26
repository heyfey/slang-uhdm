# r10v151 — ADVERSARIAL VERIFICATION of r10uvm151
## § `stmtBuiltinBodyIsBareRecvCall151` — **VERDICT: ACCEPT AS SHIPPED**

MEASUREMENT ONLY.  The official `uhdm-cmp` is the sole acceptance judge.
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
BASE `1c45a507`.  Verifier worktrees `wt_v151` (patched) + `wt_v151pris`
(pristine), both built from scratch here, `-j 2`, md5 taken separately, both
frozen `chmod 555` at immutable paths before any sweep.

## 1. The headline numbers, reproduced BIT-FOR-BIT

Both binaries were rebuilt independently in this verifier's own worktrees and
came out **byte-identical to the implementer's**:

    pristine  md5 50992c1d030a3cfa83f37a54a8b25f1f
    patched   md5 df4708693277d41ddbb48a8f99fd7052

Everything below is this verifier's own measurement, not a re-reading of the
implementer's evidence.

| claim | implementer | verifier | verdict |
|---|---|---|---|
| patch md5 / applies clean on FRESH `1c45a507` | `915760c5…` | same, `git apply -3` rc 0, 0 conflict markers | REPRODUCED |
| surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` + `tools/probe/r10uvm151repro/` | identical; **no `results/*.csv` edit**, no stray file, no fenced-test name | REPRODUCED |
| goldens | 23/0 both binaries, `/bin/false` 0/23 | 23/0 both, 0/23 | REPRODUCED |
| u2r both modes | 679/50/2, ct8rows 0 rows | 679/50/2; **0 differing ROWS** over 731 vs committed baseline AND vs own pristine, both modes | REPRODUCED |
| surelog `--mode both` | histogram unchanged, ct8rows 0 rows over 1588 | identical histogram; **0 differing ROWS over 1588** vs committed baseline AND vs own pristine; NO row converted | REPRODUCED |
| cmds.txt audit | 3035 files, 2981 name the frozen binary, 54 have no `slang:` line | identical, per binary PATH; never the main-tree binary | REPRODUCED |
| byteverify SELFCHECK=1 | MOVERS 9/956 + 0/1358, PATH_SETS_IDENTICAL | identical, and the nine are the nine named a priori | REPRODUCED |
| mover order-blind design-section lines | 18 / 58 / 18 / 38 / 18 (df) and 18 / 58 / 38 / 18 (tf) | identical, and every line is one of the law's two objects | REPRODUCED |
| canaries | 52/8 ok, changed 0; ctcan2 PASS ×2; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 | identical | REPRODUCED |
| protected DBs | byte-identical; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | identical, both modes | REPRODUCED |
| wide boundary | 4227 files × 2 views, MOVED 12, BREACH 0, RC-MISMATCH 0 | own run over 4235 files (the 4227 + this dir's 8 arms) × 2 views: **BREACH 0, RC-MISMATCH 0**, MOVED 24 = the implementer's 10 + this verifier's 12 + `r10v99repro/v99_b7_order.sv` ×2 | REPRODUCED |
| implementer's own grid | 218 cells converted, RIGHT→WRONG 0, AWAY 0 | re-run here: **218** on KIND, RIGHT→WRONG 0 and AWAY 0 in every arm, view and column; arm C def 1135→675, elab 1405→705 | REPRODUCED |
| heads | 36→60 / 36→36 / 36→163 / 36→106, 68→68, Earlgrey unchanged | identical, ONE `^LHS:` each | REPRODUCED |

**The head, on this verifier's own pristine binary:** SEVEN row-modes
(SeqDriver ×2, SimpleUVM ×2, Scoreboard/default, MiniAmiq ×2) all carry the
same object — `LHS: func_call: (m_time_settings), line:3436:9, endln:3436:52`
against our `method_func_call: (sort)` + `vpiPrefix`.  Patched, every one of
the seven is a **different object** (SimpleUVM's 36→36 is a coincidence of
depth, not a stalled head: its head is now `enum_const (UVM_CVR_ALL)` @279:7).
BuildUVMPkg 68→68 is the SAME object with only `id:` shifted by one.

**The decode, checked against Surelog itself** (not carried forward):
`grammar/SV3_1aParser.g4:3186` `subroutine_call` really does offer
`(constant_bit_select DOT identifier)*` and `… (DOT method_call_body)?`;
`CompileHelper.cpp:4224` really does test `paConstant_bit_select` and mint the
`method_func_call` + prefix; `CompileHelper.cpp:4316` really does fall out as
`MakeFunc_call()` + `VpiName(name)` + `populateCoreMembers(Tf_call_stmt,
Tf_call_stmt, …)`; `array_method_name` at `:3247` really is
`identifier | unique_call | and_call | or_call | xor_call` with
`unique_call: UNIQUE;` — LEXER TOKENS, so the four keyword names can never
take the identifier road.  Disjunct 1 is exact on slang's side too:
`IteratorCallInfo` is set at `CallExpression.cpp:522` for exactly
`withClauseMode == Iterator` **and** a written `withClause` **and** a receiver.

## 2. Breaking the law — 11 adversarial arms × 2 views, none self-confirming

`armsv151.sh` (this dir) runs each `v151_*.sv` under Surelog, the pristine and
the patched binary in both views, scores the call-shape cells with the
implementer's `ct151cen`/`score151.py`, and reports the AUTHORITATIVE
order-blind design-section row set from `dumpsect151.sh`.  Names, numbers,
letters and orders are varied deliberately (RESUME §9: a grid that names
everything `a_t/b_t/c_t` is self-confirming).

    arm 1  every array-method face the brief names (sort rsort reverse shuffle
           find find_index find_first find_last find_first_index
           find_last_index unique unique_index sum product min max), each with
           and without a `with` clause and with and without `()`, plus a
           PARENS-LESS `with`, a NAMED iterator `q.find(uu) with (uu != 0)`,
           and `with` clauses reading `item`, `item.index`, a member, a CALL,
           a string compare, a constant and an outer member
    arm 2  receivers: struct member, indexed with a VARIABLE / EXPRESSION /
           DOTTED index, indexed obj.field, dynamic, fixed unpacked,
           associative, `super.`-rooted, `this.`-rooted, and the expression
           twins of the keyword forms
    arm 2p PACKED-array reductions (slang REFUSES them: "invalid member access
           for type 'bit[7:0]'", all six cells — the face is unreachable)
    arm 3  homes: a $unit class, a class in a MODULE / PROGRAM / INTERFACE, a
           NESTED class, a PARAMETERIZED class with two specializations, a
           module instantiated THREE times
    arm 4  the MUST-STAY control: push_back push_front insert delete pop_front
           pop_back size num exists first next last, string len/substr/itoa/
           toupper/atoi, enum name/next/num, constraint_mode, rand_mode,
           randomize() — statement AND expression
    arm 5  containers: do..while, foreach, fork..join_any, `case … inside`,
           labelled begin, function body, always_comb, final, after `#1`,
           and one cell written THREE TIMES in a row
    arm 6  collisions: a queue named `sort`, one named `reverse`, one sharing
           its name with a package FUNCTION, one differing from a method only
           in CASE, locals named `item` and `find`
    arm 7  randomize: 12 statement spellings and 7 expression spellings,
           including `void'(o.randomize() with {…})` and the SCOPE form
    arm 8  the `getTaskFunc(name)` branch — a receiver whose base name also
           names a package FUNCTION and one that names a package TASK
    arm 9  spacing: `mesh9 [3]`, `mesh9[3] .rsort()`, `lane9 . sort()`,
           `lane9.  unique()`, a subscript that is a CALL, a compound subscript
    arm a  name derivation: spaced subscripts, a NEWLINE inside the subscript,
           package-scoped receivers

**RESULT: `RIGHT->WRONG 0` in every arm, every view and every column** (11
arms × 2 views; arm 2p produces no database on either binary and is scored as
such, not as perfection).  The order-blind DESIGN-SECTION distance from golden
**falls or stays equal in every single arm-view** — it never rises:

    arm 1  737→487 / 787→487     arm 2  697→607 / 739→643
    arm 3  662→542 / 930→686     arm 4  501→501 / 501→501  (must-stay: frozen)
    arm 5  681→513 / 763→523     arm 6  589→493 / 619→503
    arm 7  570→514 / 580→514     arm 8  553→497 / 565→497
    arm 9  554→498 / 558→498     arm a  634→602 / 634→602

Fences measured, not assumed: MULTI-COMPONENT receivers (`blob.vq`,
`larr[0].lq`, `h.inner`) keep `method_func_call(<field>){prefix <root>}` and
are byte-identical pristine→patched; `this.`- and `super.`-rooted receivers
are untouched (golden mints `hier_path (this.dyn2)` / `(super.bq)`, we mint
`method_func_call(this)` / `(super)` — WRONG→WRONG, residue R1); every
EXPRESSION position is untouched; every non-array built-in method in arm 4 is
RIGHT→RIGHT on all six columns in both views with a **frozen** row set.

Two source shapes are REFUSED by the tools and are recorded rather than left
silently unmeasured:
 * `mk2().lq.sort() with (item);` — a CALL-RESULT receiver: Surelog's own
   parser raises PA0207;
 * `q.find() with (item>0).size()`, `(q.find() with (item>0)).size()` and
   `q.find() with (item>0)[0]` — all three PA0207 (the implementer's R3,
   confirmed here: 10 syntax errors, `surelog` rc 3);
 * `q.map() with (…)` — slang's OTHER `WithClauseMode::Iterator` face
   (`ArrayMethods.cpp:968`) is 1800-2023-only and slang refuses it at the
   campaign's default std, so disjunct 1's `map` face is unreachable.

## 3. The two things this verification FOUND (both lateral, neither a regression)

**F1 — `getTaskFunc(name)` HITS when the receiver's base name also names a
subroutine** (arm 8).  The implementer's decode says the lookup at
`CompileHelper.cpp:4239` misses "because the name is a VARIABLE".  It misses
only when no subroutine wears that name.  Measured:

    int fname8[$];  // also a package FUNCTION   golden FC(fname8)  FUNC=1
    int tname8[$];  // also a package TASK       golden TC(tname8)  FUNC=1
    int plain8[$];  // the control               golden FC(plain8)  FUNC=0

Patched gives `FC(<recv>) FUNC=0` for all three.  The control converts
completely; the function-collision cells convert on KIND/NAME/PFX/NARG/WITH
and keep `FUNC` wrong (WRONG→WRONG); the task-collision cells convert on
NAME/PFX/NARG/WITH and are wrong on KIND (`FC` where golden says `TC`) — the
scorer calls that AWAY because pristine (`MFC(sort){prefix tname8}`), patched
and golden are three different values, but patched is strictly nearer
(design-section distance 553→497 def, 565→497 elab).  **Corpus incidence
zero**, proved two ways: MOVERS measured 9 = predicted 9 (a collision cell
would move bytes and appear as an UNPREDICTED mover), and every `func_call`
line ADDED across all nine movers is a clean bare identifier
(`m_time_settings` ×4, `checks_details`, `lof_tests`).

**F2 — a receiver written with WHITESPACE before its subscript keeps that
whitespace in the call's NAME** (arms 9 and a).  `mesh9 [3].sort() with
(item);` → golden `FC(mesh9)`, patched `FC("mesh9 [3]")`; `mine10  [ 2 ]` →
`FC("mine10  [ 2 ]")`.  `builtinRecvStepSelectors74`'s text/tree cross-check
refuses the spaced split, so `bn151` falls back to `recvNm0`, the whole first
dot-component.  Pristine's answer was `MFC(sort){prefix "mesh9 [3]"}` — the
same garbage text in the PREFIX — so this is WRONG→WRONG-differently, **not**
pristine-right→patched-wrong; the design-section distance still falls
(554→498, 634→602).  The TIGHT form, the NEWLINE-in-subscript form, the
variable / expression / DOTTED / call-valued subscripts and the spaced *dot*
forms (`mesh9[3] .rsort()`, `lane9 . sort()`, `lane9.  unique()`) are all
exactly right including span.  **Corpus incidence zero** (same proof as F1).

Neither finding is a regression, so per the brief no fix was applied and the
implementer's patch ships unchanged; both are ranked as residues R3 and R4 in
the verifier report.

## 4. Reproduce

    PRI=<pristine> PAT=<patched> CEN=<ct151cen> WD=<scratch> bash armsv151.sh

`ct151cen`, `score151.py` and `dumpsect151.sh` are the implementer's, in
`../r10uvm151repro/`; this dir adds only the arms and this file.
