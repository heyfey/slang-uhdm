# r10v161 — the ADVERSARIAL VERIFIER of r10uvm161

**Verdict: ACCEPT-WITH-FIX.** The law is right, the head really clears, every
headline number reproduces bit-for-bit — and the shipped patch was
**pristine-right / patched-wrong on legal SystemVerilog** at two cell families,
both fixed here. `/tmp/r10uvm161.verified.patch` is what should land.

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities.
slang was **NOT** patched; `results/*.csv` were **READ ONLY**; **no row was
converted**; `GOLDEN_DEFER` stayed unset; the four slang-fenced tests were
never dispatched and are named nowhere here.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, everywhere below.

| | |
|---|---|
| BASE | `fe4a739` |
| pristine binary | md5 `83258cd958cb88be667bf6729dcb0b9d`, built by this verifier in its OWN clean worktree — **the implementer's pristine md5, exactly** |
| the SHIPPED patch's binary | md5 `015180bcb928448e2c561c0857cebd2f` — **the implementer's patched md5, exactly** |
| the VERIFIED binary | md5 `99081ba5cce75436b441441f1807524e` = the shipped patch **plus the two fixes below** |
| production surface added by the verifier | `include/UhdmExporter.h` (two counters + the two laws), `src/StmtEmit.cpp` (the window raises a depth), `src/ExprEmit.cpp` (one RAII guard, five one-line uses, two suppression terms) |

## 1. WHAT REPRODUCED

Built both binaries from scratch in this verifier's own worktrees; **both md5s
are the implementer's**, so every number below is measured on the same artifact
the report describes.

* **The head clears, and the next head is what the report says.** SimpleUVM
  default and testflags go from the `chandle_var compiled_regex` head to
  `LHS: <null> / RHS: io_decl(action)@347:51`. The other six row families' head
  logs are **byte-identical**.
* **R0a is PRE-EXISTING, verified independently.** This verifier's own census
  reads `ref_obj(action)@350:25` in the **pristine** database already carrying
  `ACT=io_decl:action` where golden carries `ACT=NONE`, and the whole of
  `format_action` is byte-identical between pristine and patched. Its seven
  siblings at `:355-361` are `ACT=NONE` on every side. The report's claim holds.
* **The prediction reproduces bit for bit.** The implementer's own
  `ct161pred` over this verifier's 956 pristine surelog databases and 1358
  pristine uhdm2rtlil databases: **7 rows / 13 cells** and **0 / 0**, exactly
  the seven rows named. `byteverify` then reported **exactly those seven**
  (**7/956**) and **0/1358**, with the comparator's negative control flagging
  955/956 and 1357/1358.
* **The corpus census is 13 TOWARD-EXACT, 0 AWAY** across five cell families
  (references, listings, listing counts, whole-object identity, typespec
  actuals) — including `Scoreboard/default`, attributed order-blind.
* **The implementer's four grid arms** end at REF **DIFF 0 / 0 / 0 / 1**, every
  moved cell TOWARD, exactly as reported.
* **Their two "refuted" boundary arms do not move under this verifier's binary
  at all** (`r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv`) —
  independent corroboration that those two track the binary's own SIZE and not
  the law.

Full battery in `VERIFIED.r10v161.txt`: goldens 23/0 and 0/23; u2r 679/50/2
both modes; surelog histograms identical to this verifier's own pristine sweep;
`ct8rows` PASS against the committed baselines **and** against the own pristine
sweep, on both corpora, both modes; every `cmds.txt` audited BY BINARY PATH
(1458 + 1523 per binary, zero main-tree leakage); canaries ok=52 / ok=8
changed=0; `ctcan2` PASS twice; `canaudit` audited=29 UNCOVERED=0
FENCE-BREACH=0; the five protected databases byte-identical with `SVSwitch`
`4842211c4030` and `YosysVerx` `6ccda350c24a` on their pins.

## 2. WHAT BROKE — and why the report missed it

`§ assertCondIsAClassMethodWindow161` makes an assertion condition and a case
item expression take **the same code path as an `if` condition**. The report's
safety argument was: *our emitter is already right on every `if`-column cell,
so copying that column cannot move a cell golden leaves bare.*

**That premise is false, and this verifier measured it false three times.** The
`if` column is itself wrong at three referent shapes, and the window faithfully
copies each error into two new positions. Two of the three are fixed here.

The report's own arms could not see any of it, and the reason is visible in the
arm sources: `g161_c_sites.sv`'s NAMED-block cell reads `bollard161`, a local
declared **in the function**, not in the named block — the one named-block shape
that golden *does* bind; and `g161_b_notmove.sv`'s eighteen referent kinds
include no CAST and no CONCATENATION at all.

### FIX 1 — `§ castOperandNeverBindsInWindow161v`

> **A cast's operand is never eagerly bound, at any depth under the cast.**

Read, not guessed: Surelog's `paCast` arm
(`CompileExpression.cpp:2637-2646`) compiles the operand with `pexpr`
**literally `nullptr`**, and `bindVariable` (`CompileStmt.cpp:3092`) opens with
`if (scope == nullptr) return nullptr;`. Both spellings take that arm — the
`'()` type/size cast (the `vpiCastOp` branch, `:2662`) and the signedness cast
(`$signed`/`$unsigned`, minted at `:2649-2661`).

Seven cells were golden-BARE, pristine-BARE and **shipped-BOUND**: `int'(local)`,
`int'(formal)`, `bit'`, `unsigned'`, a size cast, an enum cast, and a cast in a
case ITEM. Their un-cast controls at the same depth in the same window keep
binding. `BREAK.r10v161.txt` D1 has the table.

The term is **scoped to the window § 161 opens** and cannot reach the `if` /
`case`-CONDITION column, which keeps its pre-existing behaviour untouched —
that column is r10uvm161's own **R0a**, a separate law with its own corpus
cells (the SimpleUVM head above is one of them).

**The first cut of this fix was itself convicted** by arm D: bumping the window
depth unconditionally suppressed a MODULE function's `assert (int'(loc) == 1)`,
which golden **binds**. The shipped term raises the depth only when the window
actually lifts a set `classMethodNoBind`, so it is inert outside an in-body
class method.

### FIX 2 — `§ namedBlkLocalNoBind144v` extended to the § 161 window

> **A local declared in a named `begin` is invisible to `bindVariable`.**

`bindVariable` (`CompileStmt.cpp:3089-3149`) switches on the scope object's
`UhdmType()` with cases for `uhdmfunction`, `uhdmtask`, `uhdmbegin` and
`uhdmmodule_inst` — and **no case for `uhdmnamed_begin`**. Its `default:` arm
falls through to the parent, so a named block is *stepped over*: a local
declared **in** it is never searched for, while one declared further out is
still found through it.

That law is already decoded and in the tree (r10v144, and r10buvm15 re-used
it); its gate simply asks `classArgBindDepth12 > 0`, and § 161 opens a window
§ 12 knows nothing about. **The change is one disjunct on that existing gate.**
Six cells were golden-BARE, pristine-BARE and shipped-BOUND (a named block's
own local, two nested named blocks, a named `fork` arm, a case item, and arm
B's `b38`); the controls that must keep binding — an unnamed block's local, a
function local read from inside a named block, an unnamed block inside a named
one and vice versa, in a function, a task, a static method, a constructor and a
generic class — all still bind.

### The two fixes move ZERO corpus cells

None of the 13 predicted-and-measured corpus cells is a cast operand or a
named-block local. `byteverify` on the **verified** binary reports the same
**7/956** and **0/1358**, and the corpus census is the same **13 TOWARD-EXACT,
0 AWAY**. The fixes are legal-SV-only corrections.

## 3. THE ARMS

| arm | what it measures | golden vs pristine | vs SHIPPED | vs VERIFIED |
|---|---|---|---|---|
| **A** `v161_a_statics.sv` | the brief's whole static-local face matrix (chandle/int/string/handle/queue/array/event/initialised/unwritten/two-in-one/nested begin/named begin/fork/loop/constructor/static method/out-of-body/task/shadowing a property/default specialization + two specializations/package fn/module fn/initial), each with its automatic and unwritten twin, read OUTSIDE any window — **MUST-STAY** | REF DIFF 18 | DIFF 18, **MOVED 0** | DIFF 18, **MOVED 0** |
| **B** `v161_b_assert.sv` | the same faces read from an assertion CONDITION, ×5 assertion kinds, in a task/static method/constructor/virtual method/begin/named begin/fork/loop/out-of-body/package fn/module fn/initial | REF DIFF 60 | DIFF 2, **AWAY 2** | **DIFF 0, AWAY 0**, TOWARD 60 |
| **C** `v161_c_overbind.sv` | the over-bind hunt: 24 referent kinds × (`if` column, assert column), 13 case-ITEM kinds, casex/casez/`case … inside`, every depth control, every expression shape | REF DIFF 56 | DIFF 15, **AWAY 4** | DIFF 11, **AWAY 0**, TOWARD 45 |
| **D** `v161_d_break.sv` | the discriminator arm — each away against its `if`-column mirror, plus the out-of-body and module-function columns | REF DIFF 35 | DIFF 41, **AWAY 21** | DIFF 21, **AWAY 0**, TOWARD 14 |
| **E** `v161_e_fixedges.sv` | the edges of both fixes: casts nested in calls/casts/operations/concats/replications/selects/indices/`inside`/ternaries/`$bits`; `$signed` as a SYSTEM CALL vs as a CAST; named blocks in every nesting and every method kind; the module-function control | — | — | **AWAY 0** for everything the two fixes own |
| **F/G** `v161_f_concat.sv`, `v161_g_catshape.sv` | the third family, R0b below | — | — | the residue, characterised |

`VAR`, `CNT`, `OBJ` (a whole-database object-identity census) and `TYP` (every
`ref_typespec`'s actual) are **MOVED 0 on every arm and on all seven moved
corpus databases** — nothing but a reference's `vpiActual` moves anywhere.

The wide boundary over a COPY of the whole probe tree,
**LISTED 4595 / PROCESSED 4595 / MOVED_ARMS 12 / RC_DIFFS 0**: four are the
implementer's arms and four are this verifier's (the positive controls —
`v161_a_statics.sv`, the must-stay matrix, is the one that does **not** move),
and the remaining four are censused against a per-arm Surelog golden at
**10 cells, 10 TOWARD, 0 AWAY**. Every committed must-stay arm set named in the
brief (r10uvm160/158/139/145/155/157/146/114/89/77/84, r10buvm14) was listed and
did not move.

## 4. RESIDUES, RANKED

**R0b — THE CONCATENATION OPERAND (the top residue; this pass's own, still
open).** Inside a class method, golden leaves a **concatenation's** operands
BARE and our emitter binds them. It is PRE-EXISTING in the `if` column
(`if ({a,b} == 0)`: golden bare, pristine bound), and the § 161 window carries
it into the assert column and the case-ITEM column — six new cells in arm F.
**Zero corpus cells**, which is why it did not have to block this landing.
Arm G pins the predicate on 40 cells: walk up to the first `vpiConcatOp`(#33)
or `vpiMultiConcatOp`(#34) ancestor; a #33 whose own parent is a #34 BINDS
(`{2{a}}`), everything else under a #33 is BARE — including a #33 under a #33,
a #33 under a func_call, an operation under a #33, and a #34 under a #33
(`{a,{2{b}}}`). The exception rests on three rows and wants its own arm set and
its own read of Surelog's `paMultiple_concatenation` arm before it becomes a
law, so it is **recorded, not guessed at**.

**R0a — the CAST in the `if` / `case`-CONDITION column** (the implementer's
R0a, confirmed and sharpened). The general law is now READ from Surelog rather
than inferred: `paCast` passes `pexpr == nullptr`
(`CompileExpression.cpp:2643`), so a cast operand is never eagerly bound
*anywhere*, not merely "the cast operation's parent is not yet set". Closing it
generally — instead of scoping it to § 161's window as FIX 1 does — clears the
SimpleUVM `io_decl(action)@347:51` head as well. That is the next pass's work,
and FIX 1 is deliberately written so it can be un-scoped in one edit.

**R1 — the named block in the `if` column and out-of-body.** The same
`uhdmnamed_begin` gap, PRE-EXISTING (arm D 53:11, 97:13, 135:13: golden bare,
pristine bound). § 144v's `curSubClassScope9 && !curSubOob9` keeps the
out-of-body half out; arm D 135:13 shows golden is bare there too, so that
guard is over-tight by one cell.

**R2 — `case … inside` item multiplicity** and **R3 — two elab `case_item`
parenting residues**: the implementer's R1/R2, reproduced unchanged, 0 corpus
cells. **R4 — the pointer-valued constant** on an associative-array typedef's
right range: real, but it did not even fire under this verifier's binary.
**R5 — `Earlgrey_0_1/testflags` reads 26594 cmp lines at `fe4a739`** with all
three binaries here and the row's status never moves; a head-DEPTH observation
for the Earlgrey family, not a regression.

## 5. FILE MAP

| file | what it is |
|---|---|
| `ctv161cen.cpp` | the verifier's OWN census, deliberately wider than the implementer's: `REF` (every object that can carry a `vpiActual`, including `ref_var` / `chandle_var` / `ref_module` and the four `ref_obj`-derived selects), `VAR`, `CNT`, plus `OBJ` — a whole-database object-identity census, the RESHAPE detector the implementer's census does not have — and `TYP`, every `ref_typespec`'s actual. The home chain carries each ancestor operation's `VpiOpType`. |
| `scorev161.py` | the three-column scorer: golden / pristine / patched, classifying every moved cell **TOWARD / AWAY / SIDEWAYS / RESHAPE**. `AWAY` is the verdict that convicts. |
| `gridv161.sh` | builds one arm's six databases (Surelog golden + two binaries × def/elab), echoing every command WITH ITS BINARY PATH into `cmds.txt` and recording every rc. |
| `v161_a_statics.sv` | ARM A — the static-local face matrix, must-stay. |
| `v161_b_assert.sv` | ARM B — the population. |
| `v161_c_overbind.sv` | ARM C — the over-bind hunt. |
| `v161_d_break.sv` | ARM D — the discriminator arm; both fixes' cells and controls. |
| `v161_e_fixedges.sv` | ARM E — the edges of the two fixes. |
| `v161_f_concat.sv`, `v161_g_catshape.sv` | ARMS F/G — R0b, characterised. |
| `VERIFIED.r10v161.txt` | every gate with its number, and the boundary attribution. |
| `BREAK.r10v161.txt` | every arm's table, cell by cell, with the convicted cells and their controls. |
