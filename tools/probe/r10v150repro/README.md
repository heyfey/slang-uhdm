# r10v150 — adversarial verification of r10uvm150 (§ `rootCallEatsTheChain150`)

**VERDICT: ACCEPT.** Every headline number in the implementer's report was
reproduced bit-for-bit on this verifier's own worktrees, own builds and own
frozen binaries. Seven new arms — none of them a copy of the implementer's
grid — were fired at the law across receiver shapes × call kinds × argument
counts × contexts × homes × instance counts × both dump views. **BROKEN = 0,
AWAY-GOLDEN = 0, and no pristine-right → patched-wrong cell was found on any
legal SystemVerilog the golden producer accepts.** No fix was required, so the
production surface ships unchanged.

Base commit `074c38c`. Worktrees `/tmp/wt_v150` (patched) and `/tmp/wt_v150pris`
(pristine), built independently at `-j 2`; binaries frozen `chmod 555` before
any sweep; `SLANG_UHDM` exported explicitly per binary and **every** `cmds.txt`
audited by binary PATH.

## 1. The builds are reproducible

| binary | md5 | implementer reported |
|---|---|---|
| pristine `074c38c` | `84ed00899ed5a2726a1ea002040c79cb` | `84ed0089…` ✓ |
| patched | `2b2afc39a45bbab21defe3ea6b4cce50` | `2b2afc39…` ✓ |

Same warning count (20 pre-existing `-Wnarrowing`), 0 errors, no new warning.

## 2. The head

`rowheads.sh` on this verifier's own sweeps: **BuildUVMPkg 68 → 30 cmp lines,
both modes, ONE head.** Every other row unchanged (SeqDriver / SimpleUVM /
Scoreboard / MiniAmiq 62, Earlgrey 29 and 50, Rggen 0). **All 24 committed head
logs reproduce byte-for-byte** modulo object ids and the workdir path —
Scoreboard/default, a ~50/50 coin, landed on the same face.

The implementer's **refutation of the brief is correct and I re-measured it**.
The pristine head is *not* a `hier_path` with a missing element: golden's
`if_stmt` condition at `uvm_pkg.sv:29217` is a bare
`func_call (uvm_root::get) @29217:10-18` carrying only its `vpiFunction`, and
ours was a bare `method_func_call (uvm_report_enabled) @29217:26-44` with three
arguments. Mirror images: golden keeps the RECEIVER and drops the METHOD, we
kept the METHOD and dropped the RECEIVER.

**Whole-dump check, re-run here**: `uhdm-dump` of BuildUVMPkg pristine vs
patched, id- and path-normalised, ORDERED — **3 hunks**, one of them the dump
banner; every changed line names source line 29217, 29218, 29526, 29527, 38754
or 9008 and nothing else. Both `if_stmt` subtrees are `patched == golden: True`
and were `pristine == golden: False`, **including `vpiParent` and
`vpiFullName`** (a strictly stronger test than the judge applies).

**R0 confirmed**: the new head is `class_typespec (uvm_report_handler)` at
`uvm_pkg.sv:38763` — golden carries `VpiName` and `vpiInstance -> package
uvm_pkg`, ours carries neither (`class_typespec: ,` with only `vpiClassDefn`),
owner `class_var uvm_pkg::rh` @`38763:22-24`.

## 3. The gates (see `VERIFIED.r10uvm150.txt` for the full record)

All green, all re-run by the verifier:

* goldens 23/0 on **both** binaries; `/bin/false` 0 PASS / 23 FAIL;
* `cmds.txt` audit: 2981/2981 name `/tmp/v150_pris.bin` on the pristine sweeps
  and 2981/2981 name `/tmp/v150_pat.bin` on the patched sweeps, zero others;
* uhdm2rtlil **679 / 50 / 2** in both modes; `ct8rows` PASS ×3;
  `byteverify SELFCHECK=1` **MOVERS 0/1358**, SELFCHECK 1357/1358;
* surelog 1588 rows, histograms identical, `ct8rows` vs
  `results/golden_surelog.csv` **PASS — 0 differing rows, status AND dump
  column**; **NO ROW CONVERTED** (BuildUVMPkg is `CMP_NOTEQUAL` before and
  after); `results/*.csv` only ever READ in both worktrees;
* `byteverify SELFCHECK=1` on the surelog corpus **MOVERS 2/956** — exactly the
  two `BuildUVMPkg` databases `PREDICT.r10uvm150.txt` named BY NAME before the
  patched sweep, and nothing else;
* canaries ok=52/0 and ok=8/0, ctcan2 PASS ×2, canaudit `audited=29
  UNCOVERED=0 FENCE-BREACH=0` in **both** repro directories; protected DBs
  identical, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`; the fenced four
  never dispatched and never spelled in either directory.

**The census is subsumed by a stronger instrument.** `byteverify` compared
*every* database of *both* corpora — 956 + 1358 — and found exactly two movers.
That is a superset of the nine-UVM-database census the implementer ran, and it
settles the "did anything else move" question without a key design at all.

## 4. Breaking the law — seven new arms (`ARMS.r10v150.txt`)

Axes the implementer's grid did **not** visit, all added here:

| arm | what it attacks |
|---|---|
| `v150_a.sv` | homes: a **`$unit`-scope class**, an **INTERFACE**, a **PROGRAM**, a class declared **inside a module**; a chain as a **ternary condition** and both its branches; a chain as a **`case` selector**; `always_comb` |
| `v150_b.sv` | the SAME chain written **inside a macro** and **inline** — they must render identically; plus a macro that expands to the ROOT ONLY (control) |
| `v150_c.sv` | a chain **as an argument whose own argument is a chain**; `while` condition; `for` condition and body; a **`fork` arm**; bare-root and scoped-root statements whose method is a **task** and a **void function**; the **out-of-body** function home |
| `v150_d.sv` | **inheritance** (base-name vs derived-name qualifier, `super.`, `this.`, bare method), a **typedef alias** root, a **parameterised class** root explicit and `#()`; and the must-stay controls: NAME-rooted 3-element `hier_path`, indexed base, trailing property, **builtin `size()`/`sum()`** |
| `v150_e.sv` | a **class constructor**, **named root arguments** `f(.aa(1),.bb(2)).m()`, a trailing **function called without parentheses** `f().g`, a **concatenation**, a **`foreach` body**, an **assignment pattern**, an **immediate assert**, a **generate block** |
| `v150_g.sv` | **declaration initialisers**: a class MEMBER initialiser, a PACKAGE variable, a MODULE variable, `always_comb`, an instance-port driver |
| `v150_f1/f3` | a **nested-scope root** `pkg::Cls::f().m()` (Surelog parses it — the implementer never tested it) and a **builtin method on a call receiver** `f().size()` |

`v150_f2.sv` (`f().arr[1]`) and `v150_f4.sv` (`(Cls::f()).m()`) are GRAMMAR
FENCES — Surelog's own parser refuses both (`[SNT:PA0207]`), so no golden
exists; our binary parses them and the boundary gate proves neither database
moved.

**Per-cell score, JUDGE language, identical in DEF and ELAB:**

| verdict | cells (both views summed) |
|---|---|
| **FIXED** (was wrong, now byte-identical to golden) | **84** |
| RIGHT (already right, stayed right) | 4 |
| TOWARD (moved toward golden, blocked by a pre-existing residue) | 8 |
| UNMOVED (untouched — the must-stay controls and the pre-existing residues) | 20 |
| **BROKEN** | **0** |
| **AWAY / SIDEWAYS / MOVEDWRONG** | **0** |

Whole-dump judge-language distance to golden fell in **every** arm, in **both**
views (`wdist.py` table at the end of `ARMS.r10v150.txt`). The two arms that did
not move are `v150_f3` (builtin receiver — pristine-vs-patched diff is the dump
BANNER and nothing else) and the standalone controls.

The 8 TOWARD cells are two pre-existing residues this pass merely un-hides:

* **`p1`/`p2`/`p3`** — the PROGRAM home. The call object is byte-identical to
  golden; the residual two lines are `vpiInstance -> program`, which golden
  anchors at the INSTANTIATION (`45:3-16`) and we anchor at the program
  DECLARATION (`28:1-34:11`) — the same in the pristine binary.
* **`e2`** — `G4#(3)::gg().mm(72)` on a class SPECIALIZATION comes out with
  golden's name and golden's span but no `vpiFunction`. Its standalone control
  `s2` (`G4#(3)::gg()` with no chain) is missing `vpiFunction` in the PRISTINE
  binary too — the pre-existing § `classScopeCallOfOutOfBodyMethodIsFuncCall26`
  residue, confirming the implementer's `c3f`/`c10f` reading.

## 5. One finding, characterised and dismissed

A raw multiset of call objects in the arm dumps shows golden with MORE
`\_func_call:` header lines than the patched side. It is **not** a deficit: the
`uhdm-dump` prints a header line again for every `|vpiParent:` back-reference,
and (a) Surelog re-parents the FUNCTION DEFINITION to the call
(`CompileExpression.cpp:5285 tf->VpiParent(call)`), which we do not, and (b) our
scoped-call arm does not set `vpiParent` on its argument constants. **(b) is
PRE-EXISTING, proved on a STANDALONE scoped call with an argument and no chain
at all** (`g150_d.sv` `d2`, `src_9::mk1(21)`): the pristine binary already omits
it. The bare-root arm sets it and is byte-identical to golden. No generated
`Compare` reads `VpiParent`, so neither is visible to the judge.

## 6. The decoded model, checked against Surelog's source

Read, not taken on trust:
`CompileExpression.cpp:5039` `compileComplexFuncCall` dispatches once on the
FIRST node and never revisits it; `:5253` `paClass_scope` reads
`Class_type_name` / `Class_scope_name`, calls `getTaskFunc(basename)` at
`:5271`, spans the call with `populateCoreMembers(Class_type_name,
Class_type_name, call)` at `:5286` (the class-name token ALONE), takes
`List_of_arguments = fC->Sibling(Class_scope_name)` — the FIRST argument list —
and sets `result = call` at `:5373`, falling to a bare `compileExpression` at
`:5375` on a lookup miss; `:5154` `paImplicit_class_handle` takes
`Method = fC->Sibling(name)`, mints ONE `method_func_call`, and returns.
**Nothing on either road ever reads the sibling that carries `.method(args)`.**
The written form is the whole discriminator, and the patch's predicate reads
exactly that (a dot after a NAME is a `ScopedName`; a dot after a CALL is a
`MemberAccessExpression`).

## 7. Ranked residues left standing

1. **`.property` / `[index]` after a root call.** Golden emits the root call
   there too; we emit nothing (`noteUnsupported("member access base")`). That
   path is a `MemberAccess`, not a `CallExpression`, so this pass's arm never
   sees it. Corpus reach 0. Re-confirmed here on `v150_d n4` and `v150_e x2`'s
   neighbours.
2. **`vpiFunction` on a specialized class's scoped call** — pre-existing § 26,
   corpus reach 0.
3. **The PROGRAM `vpiInstance` anchor** — golden at the instantiation, ours at
   the declaration. Pre-existing, unrelated to this law, and a candidate head of
   its own.
4. **A builtin method on a call receiver** (`f().size()`) — untouched by this
   pass and still 12 judge-lines from golden (`v150_f3`).
5. **Surelog-refused deeper chains** (`Cls::f().a().b()`, `f().arr[1]`,
   `(Cls::f()).m()`) — no golden exists; `g150_e.sv`, `v150_f2.sv`,
   `v150_f4.sv` keep the shapes.

## 8. Files

| file | what it is |
|---|---|
| `v150_a.sv` … `v150_g.sv` | this verifier's seven golden arms |
| `v150_f2.sv` / `v150_f4.sv` | the two extra grammar fences |
| `v150arm.sh` | build one arm with Surelog + both frozen binaries, both views, dump all six databases, score with the official `uhdm-cmp` |
| `score2.py` | the JUDGE-language dump loader (drops `VpiParent`, both forms of `VpiFullName`, `VpiFile`, ids) |
| `score3.py` | the per-cell scorer with DISTANCE to golden |
| `wdist.py` | whole-dump judge-language distance, both views |
| `reach.py` | the independent corpus-wide reach scan |
| `bound150v.sh` | the wide boundary gate |
| `VERIFIED.r10uvm150.txt` / `ARMS.r10v150.txt` / `BOUNDARY.r10v150.txt` / `REACH.r10v150.txt` | the evidence |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the standing gates, carried so this directory runs on its own |
