# r10uvm204 — § `cloneForInitVarBind204` — **A WILDCARD-IMPORT CLONE BODY'S REFERENCE TO THE ENCLOSING `for` LOOP'S INIT-DECLARED VARIABLE BINDS THAT VARIABLE** — the SeqDriver ×2 and MiniAmiq ×2 29-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here and are named only inside `canaudit.sh`'s own `FENCED=` line,
which `predict204.sh` reads at run time so this pass's artifacts never spell
them.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `a4b4caa8` |
| pristine binary | md5 `c086973114a864cf56a951af381599db`, built from this pass's OWN worktree at a clean `a4b4caa8` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `ffc12515dbb721aaba8405a22c4155e2`, frozen `chmod 555` |
| production surface | `src/UhdmExporter.cpp` ONLY — one new probe (`forInitVar204`) in the clone-binding climb and one call site in it. **+73 / −0 lines, one file, no new exporter state, no new flag, no object re-pointed outside the law.** |
| probe surface | `tools/probe/r10uvm204repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default and testflags, 29 cmp lines, ONE head each → 112**; **MiniAmiq default and testflags, 29 → 112**. ONE object in all four row-modes before (§ 1) and a DIFFERENT object of a DIFFERENT family after (§ 8, R0). A cmp line count is the HEAD OBJECT'S DECOMPILE SIZE (RESUME.md §7), not a distance. |
| every other row's head | unchanged, both binaries — SimpleUVM ×2 1327654, Scoreboard/default 95, BuildUVMPkg ×2 **0**, Earlgrey_0_1 386 / **0**, Rggen/default **0**. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against **this pass's own pristine sweeps** (1588 surelog rows, 731 + 731 uhdm2rtlil rows). Against the committed baseline exactly one row-SIDE differs, `Earlgrey_0_1,testflags` `CMP_EQUAL/differ` → `CMP_EQUAL/`, and this pass's own PRISTINE sweep reads it the same way: a uhdm-dump TIMEOUT under sweep load, not a model change. **NO ROW WAS CONVERTED.** |
| the four protected CMP_EQUAL row-modes | `BuildUVMPkg` ×2, `Earlgrey_0_1,testflags`, `Rggen,default` — **CMP_EQUAL, and BOTH CSV columns byte-identical between pristine and patched** (§ 7), rowheads 0 lines / 0 heads on both binaries. |
| byte movers | **5 / 956** surelog — the FOUR the prediction named BY NAME from the pristine databases alone, plus Scoreboard/default, the ~50/50 COIN, whose ORDER-BLIND dump diff is **0 content lines**. **0 / 1358** uhdm2rtlil. |
| the attribution | each of the four law rows: uhdm-dump ORDER-BLIND diff **154 lines, PLAIN == ORDER-BLIND**, with **12 `\|vpiActual:` lines ADDED and 0 removed**, `class_var` lines 76 added / 64 removed, **0 class_var lines naming anything but `::cb`**, and the only 2 non-law lines are the dump's own filename header. |
| the corpus population | **6 SITES × 2 clone copies = 12 new bindings per moved row-mode**, plus **32 sites × 2 = 64 re-pointed** shadowing cells, and **none anywhere else in either corpus**. |
| the census (12 row-modes, golden-vs-golden calibrated FIRST on every one) | SeqDriver ×2 and MiniAmiq ×2 **TO-GOLDEN 12** span-stripped / **76** with spans left in; **AWAY-GOLDEN 0, MOVED-WRONG 0** on both readings. SimpleUVM ×2, Scoreboard/default, **BuildUVMPkg ×2**, **Earlgrey_0_1 ×2**, **Rggen/default**: every mover column **0**. Scoreboard/testflags and Rggen/testflags have no golden and are reported `SKIP-NOFILE`, never silently skipped. |
| the grid (5 arms × 2 views, one REAL Surelog golden each) | **TO-GOLDEN 12 in the def views + 4 in the elab views = 16 total, AWAY-GOLDEN 0, MOVED-WRONG 0** in every arm in every view. **Arm E, the minimised head, is 29 cmp lines / ONE head — the corpus head's exact shape — on the pristine binary and `CMP_EQUAL` 0/0 on the patched one.** Arm D, the no-wildcard-import control, is **BYTE-IDENTICAL on both binaries in both views**. |
| the a-priori prediction | `strict` non-zero on **exactly four row-modes over 948 scanned surelog databases** — `SeqDriver` ×2 and `MiniAmiq` ×2, 12 cells each — and on **none of the 1358** uhdm2rtlil ones. |
| the WIDE boundary (5315 arms, both views, both binaries) | `MOVED_ARMS` are **this pass's OWN grid arms and nothing else**; `RC_DIFFS 0`. Arm D does not move, which is what makes the four that do a positive control rather than a leak. |
| goldens | 23 PASS / 0 FAIL on both binaries; `/bin/false` 23 FAIL (the negative control). |
| what the brief got RIGHT and what it got WRONG | The head IS the for-loop init variable, and it IS the object golden lists and we do not reach. But the brief's question (1) framing — "which container holds golden's `class_var` and our null (the for_stmt's init assignment Lhs, the scope's Variables listing, or both)" — is answered **NEITHER**: both sides emit the `assignment`'s `Lhs`, cell for cell, in all 491 for-loops of SeqDriver, and NEITHER side lists it in any `Variables()` anywhere. The container is a **third** thing the brief did not offer: `ref_obj::Actual_group` on the clone body's method-call PREFIX. And it is **NOT the HOME listing** the brief's R0 asserted — golden leaves the home unbound exactly as we do; the whole defect is in the CLONE. § 2. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `a4b4caa8` worktree; it came
out **byte-identical** to the main tree's binary at that commit
(`c0869731…`). Its 956-row surelog sweep and both 731-row uhdm2rtlil sweeps
reproduce the committed baselines row for row (the one informational dump-column
cell in `GATES.r10uvm204.txt` §4 excepted, which the pristine sweep shows too),
and `check_goldens.sh` reads 23 PASS / 0 FAIL with the `/bin/false` negative
control at 23 FAIL, before a line of code was written.

`rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         29      1
SeqDriver      testflags       29      1
MiniAmiq       default         29      1
MiniAmiq       testflags       29      1
```

and all four are the same object (`head_pris_*.cmp`):

```
LHS: class_var: (uvm_pkg::uvm_reg_field::do_predict::cb), line:1135:27, endln:1135:29
     |vpiParent: \_assignment: , line:1135:15, endln:1135:43
     |vpiTypespec: \_ref_typespec -> class_typespec (unnamed) @1135:15-1135:26
     |vpiName:cb   |vpiFullName:uvm_pkg::uvm_reg_field::do_predict::cb
RHS: <null>
```

uvm-1.2 `reg/uvm_reg_field.svh:1135` is
`for (uvm_reg_cbs cb = cbs.first(); cb != null; cb = cbs.next())` and `:1136` its
single bare body statement `cb.post_predict(this, m_mirrored, field_val, ...)`.

---

## 2. THE EDGE — WHICH CONTAINER, AND WHERE

`RHS: <null>` is the SINGULAR `SafeCompare` overload's `rhs == nullptr` branch
(`~/.local/include/uhdm/BaseClass.h:187-199`): it sets `m_failedLhs` to the
golden VALUE and leaves `m_failedRhs` unset. So the FIELD is a SINGULAR field
that points at that `class_var` in golden and is null in ours — never a vector
(the vector overload names the OWNER), and never the variable's own payload.
`ct204own --refs` enumerates every referrer on the golden side and `--twin`
every referrer of our object at the same kind/name/line/column:

```
GOLDEN referrers of class_var(cb)@uvm_reg_field.svh:1135:27 (9)
  REF .Lhs           assignment@1135:15  < for_stmt < begin < begin
                       < function(do_predict) < class_defn(uvm_reg_field) < package(uvm_pkg)
  REF .Actual_group  ref_obj(cb)@1135:45   the loop CONDITION, home def view
  REF .Actual_group  ref_obj(cb)@1135:57   the loop INCREMENT, home def view
  REF .Actual_group  ref_obj(cb)@1135:57   < ... < function(uvm_reg_field::do_predict) < package(adpcm_pkg)   [clone 1]
  REF .Actual_group  ref_obj(cb)@1135:45   [clone 1]
  REF .Actual_group  ref_obj(cb)@1136:13   [clone 1]   <-- THE EDGE
  REF .Actual_group  ref_obj(cb)@1135:57   [clone 2]
  REF .Actual_group  ref_obj(cb)@1135:45   [clone 2]
  REF .Actual_group  ref_obj(cb)@1136:13   [clone 2]   <-- THE EDGE

OURS  the same three home referrers (.Lhs, @1135:45, @1135:57) on our own
      class_var, and the SAME three on each of our two clone copies — but
      NO @1136:13 anywhere: ours carries <null>.
```

`ct204own --acg=cb` lays the four listings side by side. The two writers agree
everywhere except one cell:

| listing | `cb` @1135:45 (cond) | @1135:57 (inc) | @1136:13 (body prefix) |
|---|---|---|---|
| `uvm_pkg` / `class_defn uvm_reg_field` (def view) | BOUND / BOUND | BOUND / BOUND | **`<null>` / `<null>`** |
| `uvm_pkg` / `function uvm_reg_field::do_predict` | BOUND / BOUND | BOUND / BOUND | **`<null>` / `<null>`** |
| `adpcm_pkg` clone ×2 (`import uvm_pkg::*`) | BOUND / BOUND | BOUND / BOUND | **BOUND / `<null>`** |

**So the head is a CLONE law, not a home law**, and the brief's R0 got that
backwards. Golden's home listings leave the body reference bare exactly as we do;
only the wildcard-import clone binds it — the same rule
§ `pkgCloneHierBind9` / § `pkgCloneLocalRefBind37` already model for hier_path
bases, method-call prefixes and ordinary refs. In the clone golden binds the
HOME object rather than minting a copy; no generated `Compare` reads
`VpiParent` (RESUME.md §9), so sharing-vs-copying is invisible to the judge and
binding our own clone copy is equivalent — arm E proves it, going `CMP_EQUAL`.

The ABLATION prints "REFUTED — the judge stopped on the same pair again". That
verdict is an ARTEFACT, not evidence: masking the golden head only skips its
`Compare`, and the `rhs == nullptr` branch fires **before** `Compare` is ever
reached. A null-RHS head cannot be ablated.

**What the brief's two candidate containers actually do.** `ct204own --forinit`
tallies every one of SeqDriver's **491** for-loops on both sides:

```
GOLDEN  lhs=class_var ts=class_typespec 122 | lhs=int_var ts=int_typespec 306
        lhs=bit_var 8 | lhs=ref_var ts=<no-ref_typespec> 55 | FOR_STMTS=491 INIT_STMTS=491
OURS    identical, kind for kind, count for count
```

and every single one is `notlisted` — the init variable is in **no** `Variables()`
listing, on **either** side. Both candidate containers are ruled out by
measurement, not by argument.

---

## 3. DECODE — SURELOG

`~/git-repos/Surelog/src/DesignCompile/CompileStmt.cpp`, `compileForLoop()`
(`:2822-3032`), compiles the two grammatical init forms in two separate loops:

* **`paFor_variable_declaration`** (`:2849-2884`) — `for (T v = e; ...)`:
  `compileVariable(component, fC, Data_type, …)` compiles the variable **from the
  written type**, `assign_stmt->Lhs(var)` is the ONLY place it goes, and it is
  pushed onto `VpiForInitStmts` (never the singular `VpiForInitStmt`). Written as
  a class name directly it is a `class_var` bound to an UNNAMED `class_typespec`
  spanning the written type — the head's `1135:15-1135:26` is the eleven
  characters `uvm_reg_cbs`.
* **`paList_of_variable_assignments`** (`:2885-2928`) — `for (v = e; ...)`:
  `compileVariable(…, Hierarchical_identifier, …)` compiles from the IDENTIFIER,
  so that Lhs variable carries **no typespec at all**. It is an artefact of the
  assignment, not a declaration, and golden binds body references to the real
  declaration elsewhere in the subroutine, never to it. **THIS IS THE FENCE.**
* neither — `VpiForInitStmts` stays null.

`DECODE.r10uvm204.txt` carries the quoted source of both.

---

## 4. DECODE — SLANG-UHDM, AND WHY THE CLIMB MISSED

`src/StmtEmit.cpp` `StatementKind::ForLoop` (`:4383-4560`) builds the identical
shape: § `classLoopVar11` mints the variable with `makeReturnVar`, binds
`makeTypespec(*lv)`, sets `init->Lhs(v)` and registers `netMap[lv] = v`; the
plain-assignment arm mints a bare `ref_var` with no typespec. slang populates
`loopVars` for the declaration form and `initializers` for the assignment form
and never both (`source/ast/statements/LoopStatements.cpp:118-133`).

`src/UhdmExporter.cpp`'s clone-binding block (`:7280-7712`) is where the binding
is written. `bind9` — the one lookup every clone-body binding goes through —
CLIMBS from the reference to the owning `task_func` and consults, at each level:

```
loopVar37(a9, nm9)   a `foreach_stmt`'s VpiLoopVars ref_var      (§ pkgCloneLoopVarBind37)
blockVar9(a9, nm9)   a begin / named_begin / fork's Variables()
```

and only then the subroutine-level name map `pkgCloneBodyLocals9[tf]`, built from
`funcMap` in `src/TaskFuncEmit.cpp:6788-6834`.

**A `for_stmt` is neither.** Its declared init variable is in no `Variables()`
listing (§ 2) and it is not a foreach loop variable, so the climb walked straight
past it. Two defects followed:

* **(a) THE HEAD.** A loop declared inside a nested block never reaches
  `funcMap` at all — "a body's BLOCK-local declarations never reach funcMap" is
  the comment on `blockVar9` itself — so the reference stayed BARE. All six
  corpus sites are exactly that: a `case`-item or `if` `begin` block containing
  `for (uvm_reg_cbs cb = …) cb.<method>(…);`.
* **(b) THE SHADOWING.** A loop declared at the subroutine's OWN statement level
  DOES reach the map, but the map is keyed by NAME and is LAST-WRITER-WINS, so
  `uvm_vreg::write` (uvm-1.2 `uvm_vreg.svh:1250` and `:1271`, both declaring
  `cb`) bound EVERY reference in BOTH loops to `:1250`'s variable. Golden binds
  each loop's own. The judge cannot see it (the two objects agree in every
  compared field), and the same climb repairs it.

---

## 5. THE LAW — ONE GATED PROBE IN AN EXISTING CLIMB

```
§ cloneForInitVarBind204
    a `for` loop's INIT-DECLARED variable is the SECOND clone-body binding target
    that lives in no `Variables()` listing anywhere, and so the THIRD probe the
    clone-binding climb needs.  Consulted in the SAME innermost-out climb as
    `loopVar37` and `blockVar9`, at every level, before the subroutine-level name
    map — which is what makes shadowing come out right.
```

The three probes are **disjoint by node kind** (`foreach_stmt` / the `begin`
family / `for_stmt`), so their order among themselves cannot decide anything;
what matters is that all three run at every level before the name map. The
`if (fv204 != e9)` guard is `loopVar37`'s own guard, and it is load-bearing: it
is what stops the init `assignment`'s own `ref_var` Lhs (the typedef-alias form)
from being bound to ITSELF, a self-cycle the pristine binary had and golden does
not (arm A, `TO-GOLDEN`).

**THE FENCE — the DECLARATION form only.** The probe requires the init Lhs
variable to carry a bound `Typespec()->Actual_typespec()`. Both writers give the
plain-assignment form's Lhs no typespec at all (§ 3), so `for (v = e; ...)`
grows no binding target. Measured on arm A, all 28 `pa204` cells across golden,
pristine and patched are **byte-identical**: every reference binds the real
`int_var pa204@33:13` declaration, the loop's own Lhs artefact is bound in the
clone and null in the home views, and **the patch changes none of it**.

The whole change is inside `if (!pkgCloneBodyLocals9.empty())` and reached only
after `pkgCloneBodyLocals9.find(tf9)` succeeds — the wildcard-import clone gate.
Arm D (no wildcard import) is byte-identical on both binaries in both views.

---

## 6. THE GRID — 5 arms × 2 views, one REAL Surelog golden each

`grid204.sh` builds the golden and BOTH binaries' databases in BOTH views, echoes
every command AND ITS BINARY PATH into `cmds.txt`, records every rc (an rc=139
segfault must never read as a result) and NAMES a missing database. Full output:
`GRIDS.r10uvm204.txt`.

| arm | what it decides | def view | elab view |
|---|---|---|---|
| **A** `g204_a_forms` | the six INIT FORMS in a clone body — class declaration (bare body and `begin` body), typedef-alias declaration, builtin declaration, **plain assignment**, **multiple declared inits**, **no init** — each with a bare-name, a method-prefix and a dotted-member reference | TO-GOLDEN 2, AWAY 0, MOVED-WRONG 0 | TO-GOLDEN 4, AWAY 0, MOVED-WRONG 0 |
| **B** `g204_b_ctx` | the CONTEXTS — package FREE subroutine, OUT-OF-BODY class method (nested one block deeper: the head's shape), IN-BODY class method, MODULE task, MODULE `initial` body | pristine head is `class_var cN204` / `RHS: <null>`, **the corpus head's exact shape**; TO-GOLDEN 2, AWAY 0, MOVED-WRONG 0 | byte-identical |
| **C** `g204_c_shadow` | SHADOWING — two SIBLING loops declaring the same name at the subroutine's own level (the `uvm_vreg::write` shape), a NESTED loop redeclaring an outer loop's name, and a subroutine LOCAL carrying a loop variable's name | `CMP_EQUAL` on both binaries; TO-GOLDEN 4, AWAY 0, MOVED-WRONG 0 — the judge cannot see the repair, the census can | byte-identical |
| **D** `g204_d_noimport` | THE CONTROL — the same declarations with NO wildcard import anywhere | **BYTE-IDENTICAL** on both binaries | **BYTE-IDENTICAL** |
| **E** `g204_e_head` | the MINIMISED CORPUS HEAD — `uvm_reg_field.svh:1123-1140` reduced to an out-of-body method, a `case`-item `begin` block, and a `for` loop whose single bare body statement calls a method through the loop handle | **29 cmp lines / ONE head → `CMP_EQUAL` 0 / 0**; TO-GOLDEN 4, AWAY 0, MOVED-WRONG 0 | byte-identical |

Golden-vs-golden calibration ran on every arm in every view: every mover column
0. The arm-level whole-dump attribution (order-blind, path- and id-normalised)
names every moved line:

```
A def   6 lines: 2 REMOVED `vpiActual -> ref_var cC204` self-cycles (+ header)
A elab 12 lines: 5 REMOVED self-cycles (+ header)
B def   6 lines: 2 ADDED   `vpiActual -> class_var cN204`  (+ header)
C def  10 lines: 4 class_var cbC204 re-pointed to the loop's own (+ header)
E def  10 lines: 4 ADDED   `vpiActual -> class_var cbE204` (+ header)
D def/elab, B/C/E elab: BYTE-IDENTICAL
```

---

## 7. THE GATES

Full battery with every number in `GATES.r10uvm204.txt`. In one line: goldens
23/0 on both binaries with the `/bin/false` control at 23 FAIL; uhdm2rtlil
679/50/2 in both modes with `ct8rows` 0 differing rows against the committed
baseline AND against this pass's own pristine sweep; surelog `ct8rows` 0
differing rows against this pass's own pristine sweep over all 1588 rows and one
informational DUMP-COLUMN cell against the committed baseline that the pristine
sweep shows too; `byteverify SELFCHECK=1` 5/956 surelog and 0/1358 uhdm2rtlil,
every mover named and attributed; canaries `ok=51 changed=1` where the one
changed row is that same dump-column cell and the PRISTINE sweep scores it
identically; `ctcan2` PASS on both corpora; `canaudit` PASS; SVSwitch
`4842211c4030` and YosysVerx `6ccda350c24a` **PINS HELD**; InterfaceModPort,
BlackParrotComplex and YosysOldOr byte-identical.

**The four protected CMP_EQUAL row-modes, both columns, scored explicitly:**

```
                           committed baseline        pristine            patched
BuildUVMPkg,default        CMP_EQUAL,,,differ        (same)              (same)
BuildUVMPkg,testflags      CMP_EQUAL,,,differ        (same)              (same)
Earlgrey_0_1,testflags     CMP_EQUAL,,,differ        CMP_EQUAL,,,        CMP_EQUAL,,,
Rggen,default              CMP_EQUAL,,,differ        (same)              (same)
```

All four stay `CMP_EQUAL`; pristine and patched are byte-identical on every one,
including the dump column. `Earlgrey_0_1,testflags`'s dump column reads empty in
BOTH of this pass's sweeps — the uhdm-dump timeout, not the model.

---

## 8. WHAT THE PATCHED HEAD IS — R0

SeqDriver ×2 and MiniAmiq ×2 now read **112 cmp lines, one head**; MiniAmiq's two
modes are byte-identical and SeqDriver's two differ only in the testbench's own
path (`head_pat_*.cmp`):

```
LHS: bit_typespec: (uvm_reg_addr_t), line:73:10, endln:73:31
     |vpiParent: \_ref_typespec: (adpcm_pkg::uvm_reg::get_address::addr::uvm_reg_addr_t)
     |vpiName:uvm_reg_addr_t
     |vpiInstance: \_package: uvm_pkg
     |vpiRange: \_range: 73:23-73:31  (63 downto 0)
RHS: bit_typespec: (uvm_pkg::uvm_reg_addr_t), line:73:10, endln:73:31
     |vpiName:uvm_pkg::uvm_reg_addr_t
     |vpiInstance: \_package: uvm_pkg
     |vpiRange: \_range: 73:23-73:31  (63 downto 0)
```

**R0 — THE NEXT HEAD is a NAMING head of a different family.** uvm-1.2
`uvm_pkg.sv`-included `base/uvm_reg_model.svh:73` is
`typedef bit [`UVM_REG_ADDR_WIDTH-1:0] uvm_reg_addr_t;`. Golden's
`bit_typespec` for that package typedef, reached through a **clone body local's**
`ref_typespec` (`adpcm_pkg::uvm_reg::get_address::addr`), carries the **BARE**
name `uvm_reg_addr_t`; ours carries the **QUALIFIED** `uvm_pkg::uvm_reg_addr_t`.
Everything else on the pair agrees, `vpiInstance` (`package uvm_pkg`) included,
so it is the NAME alone — `VpiName` is the first field `BaseClass::Compare`
reads. Note that § `importCloneBareTdAlias16` already models "the clone bodies
are the ones whose package-typedef alias chain stays BARE all the way down"
(`src/TaskFuncEmit.cpp`, `pkgImportCloneTfs16`); this is that same law reaching a
`bit_typespec` it does not currently cover. Start from `pkgImportCloneTfs16`'s
membership and from `ct204cen`'s `AGALL|`/`FI|` machinery, which already keys
every clone listing by package. **Read RESUME.md §9's warning first: naming is
CONTEXT-DEPENDENT and a uniform requalification fix is a known dead end.**

---

## 9. RESIDUES

* **R1 — the TYPEDEF-ALIAS loop variable.** `for (LeafAlias204 cC204 = …)` (arm
  A form 3): golden leaves EVERY reference to it unresolved and the elaborated
  view mints an implicit `logic_net` for the name, in the def view and in the
  clone alike; we bind them to our `ref_var`. That is why arm A does not go
  `CMP_EQUAL` — its head is that implicit net, which belongs to the IMPLICIT-NETS
  family (the sister pass's SimpleUVM head), not to this law. This pass's only
  movement there is TO-GOLDEN: the self-cycle removal. Corpus incidence of the
  alias form inside a clone: zero in the four UVM row-modes.
* **R2 — the SECOND declarator of a multiple-init loop.** `for (int a = 0, b = 1;
  …)` is ONE `For_variable_declaration` node to Surelog, so golden emits ONE init
  assignment and does not model `b` at all (its references go to an implicit
  net); slang gives us both declarators and we emit TWO init assignments. Arm A
  form 6 and the `t1` probe both show it (`INIT_STMTS` 6 vs 7). A `for_stmt`
  init-arity law, orthogonal to this one. Unmoved.
* **R3 — `for (; cond; step)` is unsupported.** With both `loopVars` and
  `initializers` empty, `src/StmtEmit.cpp:4556` takes
  `noteUnsupported("for init form")` and the loop emits with no init statements
  at all; golden emits none either, so the cell agrees, but the binary exits 4
  and the arm records `rc=4` on BOTH binaries. Arm A form 7. Unmoved.
* **R4 — golden SHARES the loop variable, we COPY it.** Golden's clone
  references bind the HOME `class_var` (id 29552 on SeqDriver); ours bind the
  clone's own copy. Invisible to the judge (no generated `Compare` reads
  `VpiParent`, and the two objects agree in every compared field — arm E goes
  `CMP_EQUAL`), and closing it would need the same sharing split
  § `cloneStmtHomeVarRef17` owns. Deliberately not attempted.
* **R5 — the home listings' body reference stays bare.** Both writers leave
  `@1136:13` null in `uvm_pkg`'s def view and in its own package listing. That is
  golden's shape, it is ours, and the clone gate is what keeps it that way.
* **R6 — the census is stricter than the judge.** `AGALL|` keys carry the whole
  owner chain, so a begin-nesting difference between the two writers reads as
  `STILL-WRONG` even where the judge is satisfied (arm E elab is `CMP_EQUAL` on
  both binaries with 26 such keys). The columns that decide a pass —
  `AWAY-GOLDEN` and `MOVED-WRONG` — are 0 on every row-mode and every arm on both
  readings.

---

## 10. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm204repro
g++ -O2 -std=c++17 ct204cen.cpp  -I ~/.local/include -I ../r10ladder1repro \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct204cen
g++ -O2 -std=c++17 ct204own.cpp  -I ~/.local/include -I ../r10ladder1repro \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct204own
g++ -O2 -std=c++17 ct204pred.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct204pred

# THE EDGE, on the head's own row (this is the decode of record)
/tmp/ct204own <golden.uhdm> <ours.uhdm> --refs        # golden's 9 referrers
/tmp/ct204own <golden.uhdm> <ours.uhdm> --twin        # ours, at the same span
/tmp/ct204own <golden.uhdm> <ours.uhdm> --acg=cb      # the four listings side by side
/tmp/ct204own <golden.uhdm> <ours.uhdm> --forinit     # all 491 for-loops, both sides

# the grid (one real Surelog golden per arm, both views, both binaries)
for a in grid204/g204_*.sv; do
  CEN=/tmp/ct204cen bash grid204.sh "$a" <PRISTINE> <PATCHED> /tmp/w_$(basename $a .sv)
done
python3 score204.py /tmp/w_g204_e_head/cen.g.def.txt /tmp/w_g204_e_head/cen.a.def.txt \
                    /tmp/w_g204_e_head/cen.b.def.txt --show

# the a-priori prediction, from a completed PRISTINE sweep workdir
PRED=/tmp/ct204pred bash predict204.sh <pristine workdir> /tmp/pred.txt

# the corpus census over the UVM row-modes (golden-vs-golden calibrated first)
CEN=/tmp/ct204cen bash cen204.sh <pristine workdir> <patched workdir> /tmp/cen

# the mover attribution (order-blind; Scoreboard/default is a coin)
bash attrib204.sh <pristine wd> <patched wd> /tmp/attrib '^(SeqDriver|MiniAmiq|Scoreboard)$'

# the WIDE boundary, from a COPY of the probe tree
PRIS=<pristine> PATCHED=<patched> bash bound204.sh <copy of tools/probe> /tmp/bound

# the guards
bash canaudit.sh canaries.sh ctcan2.sh
```
