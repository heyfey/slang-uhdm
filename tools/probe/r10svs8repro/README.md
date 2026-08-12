# r10svs8 — § covergroupBuiltinCall8 — the SVSwitch 158-line head CLEARED in BOTH modes; **the brief's proposed FIX SHAPE refuted: this is not an interface-method arm, it is ONE CLAUSE on the class-method arm**

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order — every driver here passes them that way.

Base **a060719** (`git rev-parse HEAD` printed in §4 GATE 1 for BOTH worktrees).

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine a060719) | `365219cb664f4498d52c9aa68f605ba7` | my own full build of pristine a060719 in `.claude/worktrees/r10svs8pris` (`git status --porcelain` EMPTY) — see the TIMING NOTE in §4 GATE 1 |
| FINAL (gated, shipped) | `4e5d371eddeaf9bdbc1ce08bd73019a0` | every gate below ran on this binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` and
`results/golden_surelog.csv` were **read only**.

---

## 0. HEADLINE

* **THE BRIEF'S FIX SHAPE IS WRONG, and the correct one is smaller.** The brief
  said the INTERFACE-method-through-port arm "is the shape to copy", and pointed
  at r10svs7's `residue_R1_prototype.diff.txt`, which gates a COPY of that arm on
  `SymbolKind::CovergroupBody`. I re-derived it and it is **refuted by two
  measured cells and one hazard**:

  1. **a4 F4 `this.cgi8.sample();`** — golden emits `method_func_call: (this)`
     located at `cgi8`, with vpiPrefix the STRING constant `"this"`. The
     prototype's flat `<recv>.<method>` copy emits a call named `sample` with a
     ref_obj prefix named `this`. WRONG OBJECT.
  2. **a4 F5 `h8.cgi8.sample();`** — golden emits `method_func_call: (cgi8)`
     prefix `h8`, the method's own name and arguments DROPPED (Surelog's
     `compileTfCall` reads only the first two names). The prototype emits
     `method_func_call: (sample)` with a prefix ref_obj named `h8.cgi8`. WRONG
     OBJECT.
  3. The prototype splits `rawText(expr.sourceRange)` on its **last `.`**. An
     ESCAPED IDENTIFIER MAY CONTAIN A DOT — arm a5 cell G1 writes
     `\cg.esc8 .sample();` and golden's prefix is `vpiName:cg.esc8`. A
     source-text split is a name-reading gate on input it cannot parse.

  **The real law is that Surelog has no covergroup-aware call path at all.**
  Golden's object for a covergroup built-in call is byte-identical IN SHAPE to
  golden's object for a USER class-method call written beside it — including all
  four of the class arm's sub-shapes (flat statement, expression hier_path,
  `this`-rooted, deep receiver). So the fix is **one OR-clause on the existing
  class-method arm's parent-scope gate**, and the arm's four laws
  (§ deepRecvCall11, § thisRecvCall11, § callParenSpan11,
  § classInBodyRecvCallArgNoBind52) then apply unchanged and correctly.
  **89 inserted lines, 78 of which are the NOTE blocks; the executable change is
  one predicate and one `||`.**

* **THE SVSwitch HEAD IS CLEARED, BOTH MODES, and the rows did NOT move.**

  ```
  SVSwitch,default,CMP_NOTEQUAL,decompile:,,
  SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
  ```

  byte-identical to `results/golden_surelog.csv`; **no `results/*.csv` was
  touched by this pass.** What moved is the head, identically in both modes:

  ```
  BEFORE (control a060719, BOTH modes)      AFTER (FINAL, BOTH modes)
  LHS: begin: (work@coverage::sample),      LHS: ref_obj: (work@Environment::
       id:2104, line:36:1, endln:36:26           reset::input_intf), line:63:16
  cmp HEAD DEPTH=158  heads=1               cmp HEAD DEPTH=48   heads=1
  ```

  MULTISET distance to golden **1393 -> 1384**, both modes; our dump grew 11
  lines and golden-only line instances fell **507 -> 497**.

* **SVSwitch did NOT convert, and this was expected.** The new head is exactly
  the brief's predicted **R2** — `Environemnt.sv:63`, `@(input_intf.clock)`,
  golden `ref_obj (…::input_intf)` vs our two-element
  `hier_path (input_intf.clock)`. It is a different family (virtual-interface
  event-control naming) and is not this law's. Ranked R1 in §7.

* **THE MOVERS ARE EXACTLY THE PREDICTED OBJECTS AND NOTHING ELSE**, over both
  corpora, with both negative controls green (§4 GATE 5). Per shape, ADDED /
  REMOVED separately: **4 object lines ADDED, 0 REMOVED**, identical in both
  modes (§5).

* **THE ESCAPED-IDENTIFIER SPAN GAP IS NOT MINE — PROVED ON THE CONTROL
  BINARY.** Arm a5 leaves one residual: for an escaped receiver our
  `method_func_call` and its prefix `ref_obj` end **5 columns short** of golden.
  Arm a6 writes the identical call on a plain CLASS handle — a shape that has
  taken this same arm since long before this pass — and the **CONTROL** binary
  shows **the identical +5 gap** (golden `32:20-32:25` vs ours `32:15-32:20`).
  It belongs to the escaped-identifier span law (r10svs7's residue R5b). This
  pass only made it VISIBLE for covergroup receivers, which previously emitted
  no object at all. Ranked R3.

---

## 1. THE LAW

### § covergroupBuiltinCall8

**NAME AS IN THE CODE**, two greppable sites, both in `src/ExprEmit.cpp`:

| site | grep | what it does |
|---|---|---|
| the PREDICATE | `grep -n '§ covergroupBuiltinCall8 — whether' src/ExprEmit.cpp` | `static bool covergroupBuiltinCall8(const SubroutineSymbol&)` |
| the GATE | `grep -n 'NOTE § covergroupBuiltinCall8' src/ExprEmit.cpp` | ONE extra OR-clause on the EXISTING class-method arm's parent-scope gate |

**STATED GATE == CODE GATE.**

* STATED: *the callee's immediately-enclosing scope is a `CovergroupBody`, and
  the call has a receiver.*
* CODE:
  ```cpp
  static bool covergroupBuiltinCall8(const slang::ast::SubroutineSymbol& sub) {
      const slang::ast::Scope* psc = sub.getParentScope();
      return psc && psc->asSymbol().kind == slang::ast::SymbolKind::CovergroupBody;
  }
  ...
  if (auto psc0 = sub.getParentScope();
      psc0 &&
      (psc0->asSymbol().kind == SymbolKind::ClassType ||
       covergroupBuiltinCall8(sub)) &&
      call.thisClass()) {
  ```
  Nothing else is read — **no name, no syntax, no source text, no type**. The
  `call.thisClass()` requirement is the arm's PRE-EXISTING clause and is
  UNCHANGED; it is non-null for every covergroup built-in call in the grid
  (MEASURED on all five arms with an instrumented build, §2.1).

**NO NAME-READING GATE EXISTS HERE — which is the point.** The standing rule
requires escaped identifiers to be tested on any name-reading gate. This gate
reads a SCOPE KIND, so escaped identifiers cannot reach it; and the arm it feeds
derives the receiver from the BOUND expression's symbols, not from source text.
Arm a5 G1 (`\cg.esc8 .sample();`, an escaped covergroup name CONTAINING a dot)
confirms the consequence: our prefix `ref_obj` carries `vpiName:cg.esc8`,
byte-equal to golden. Only the SPAN differs, and §0/§2.6 attribute that to the
pre-existing span law on the control binary.

**THE LAW, exactly.**

> Surelog does not distinguish a covergroup BUILT-IN method call (`sample`,
> `set_inst_name`, `get_coverage`, `get_inst_coverage`, `start`, `stop`) from a
> USER class-method call. Its `compileTfCall` sees a dotted invocation and emits
> the same objects for both, in every position: flat `method_func_call` +
> unbound prefix `ref_obj` as a STATEMENT; `hier_path` `<recv>.<method>` in
> EXPRESSION position; the `this`-rooted and deep-receiver forms unchanged.
> Therefore a covergroup built-in call takes the class-method arm ENTIRE, and
> the only correct change is to admit it to that arm.

**WHY THE PARENT SCOPE AND NOT THE NAME.** The name is provably not a
discriminator: the corpus itself (`third_party/tests/SVSwitch/Coverage.sv`)
declares `task sample(packet pkt)` on the very class that owns the covergroup,
so the enclosing task and the built-in share the identifier. Arm a1 C5 and arm
a5 G3/G4 write user methods named `sample`; all stay `SymbolKind::ClassType` and
all are byte-unchanged by this pass.

**WHAT THE PREDICATE COVERS, read out of slang** (`source/ast/symbols/CoverSymbols.cpp`):
`sample` is added by `CovergroupType::fromSyntax` (`body->addMember(sample.symbol)`),
and `set_inst_name`/`get_coverage`/`get_inst_coverage`/`start`/`stop` by
`addBuiltInMethods(*this, /*isCovergroup=*/true)` in the `CovergroupBodySymbol`
constructor — all six on the SAME body, so ONE predicate reaches all six, and
the grid EXECUTES all six.

**DELIBERATELY EXCLUDED: `Coverpoint` and `CoverCross`**, which slang also gives
built-ins (`addBuiltInMethods(*this, false)`). Arm a3 cell E7
(`cgc8.cpc8.get_coverage()`) is the EXECUTED abstain control: parent-scope kind
`Coverpoint`, already matched golden before this pass, byte-unchanged after.

---

## 2. THE GRID — cell for cell, every cell EXECUTED

Driver: `ct8arm.sh <arm>.sv <wd>` (golden = Surelog `-parse -nocache`, ours =
`$SLANG_UHDM`, both dumps `sed 1d`). Reader: `ct8cell.sh <wd> <regex> [n]`,
which matches on CONTENT and never on a line number, and prints the side banners
on every run.

**LEGEND.** *EQ* = ours is byte-identical to golden for that cell's subtree.
CONTROL = pristine a060719; FINAL = the shipped binary.

### 2.1 The mechanism, MEASURED not assumed

A temporary `getenv("R10SVS8_PROBE")` build printed, for every non-system call,
the callee name, its parent-scope kind, the statement-context flag and whether
`call.thisClass()` is non-null. **The probe was removed before the gated build**
(`git diff` contains no `getenv`). What it established:

```
a1  sample        pscKind=90 (CovergroupBody) stmtCtx=1 thisClass=1   x3
a1  touch touch2  pscKind=22 (ClassType)      stmtCtx=1 thisClass=1
a3  start/stop/set_inst_name  pscKind=90  stmtCtx=1  thisClass=1
a3  get_coverage / get_inst_coverage  pscKind=90  stmtCtx=0  thisClass=1
a3  get_coverage (coverpoint, E7)     pscKind=91 (Coverpoint)  thisClass=1
a4  sample x5     pscKind=90  stmtCtx=1  thisClass=1
a4  plain8        pscKind=48 (InstanceBody)  thisClass=0
a5  sample (user, h5.sample())  pscKind=22  thisClass=1
a5  sample (user, bare)         pscKind=22  thisClass=0
```

Two facts follow, and both are load-bearing: **`thisClass()` is non-null for
every covergroup built-in call**, so the arm's pre-existing clause needs no
change; and **Coverpoint is a DIFFERENT kind (91)**, so E7 is genuinely outside
the gate rather than merely untested.

### 2.2 Arm a1 — `a1_witness.sv`, the corpus shape and the IN-LAW controls

| cell | source | golden | ours CONTROL | ours FINAL |
|---|---|---|---|---|
| **C1** `cg8.sample();` in a class TASK — **the corpus shape** | l.40 | `method_func_call: (sample) @40:11-40:17`, `vpiPrefix -> ref_obj (work@a1::cov8::samp8::cg8) @40:7-40:10`, no vpiFunction | **NOTHING** (`unsupported: user function call`) | **EQ** |
| **C2** same call in a class FUNCTION | l.44 | same objects, scoped to `fsamp8` | NOTHING | **EQ** |
| **C3** `p8.touch();` USER method — IN-LAW | l.48 | `method_func_call: (touch)` + `ref_obj (…::inlaw8::p8)` | **already EQ** | **EQ, unchanged** |
| **C4** `this.touch2();` USER method — IN-LAW | l.57 | `method_func_call: (touch2)` | **already EQ** | **EQ, unchanged** |
| **C5** the corpus's own NAME COLLISION: a class task named `sample` calling the covergroup's `sample` | l.59-62 | both objects present | the call ABSENT | **EQ** |

**C1 == C3 is the whole discovery.** The two golden subtrees differ only in the
identifiers; the object graph is the same. C3 already matched golden on the
CONTROL binary, which is what proves the class arm ALREADY builds golden's
covergroup object — it was simply never reached.

**a1 RESIDUAL AFTER THE PATCH: ORDERING ONLY.** `diff <(sort g.dump) <(sort
o.dump)` = **0 lines**, MULTISET DISTANCE **0**, 842 lines both sides. The
surviving `cmp` head is the `class_defn`'s child ORDER (golden lists this arm's
members in the reverse of our order — the same pre-existing arm artefact
r10svs7 §2.2 recorded).

### 2.3 Arm a2 — `a2_args.sv`, ARGUMENTS (`covergroup c with function sample(...)`)

| cell | source | golden's object | FINAL |
|---|---|---|---|
| **D1** `cga8.sample(3);` | l.31 | mfc + ONE `vpiArgument -> constant @31:19-31:20`, `vpiDecompile:3`, **`vpiParent` = the mfc** | **EQ** |
| **D2** `cga8.sample(w8);` | l.35 | mfc + `vpiArgument -> ref_obj (…::d2_8::w8)` | **EQ** |
| **D3** `cgb8.sample(3, w8);` | l.39 | TWO `vpiArgument`s in written order, constant then ref_obj | **EQ** |
| **D4** `cgb8.sample(w8 + 1, 7);` | l.43 | operation + constant actuals | **EQ** |
| **D5** `this.user8(3, w8);` USER — IN-LAW | l.51 | mfc `(user8)` with the IDENTICAL argument shape | **already EQ; unchanged** |

**D3 == D5 cell for cell.** The literal is parented AT the call on both, which
is what the class arm's existing `forceConstParent` handling already does — no
new argument code was written for this pass.

**ARM a2 AFTER THE PATCH: `PASS_CMP`, heads=0.** Residual dump content 26 lines,
all of it the pre-existing `class property type: CovergroupType` declaration
residue (R2 below), none of it a call object.

### 2.4 Arm a3 — `a3_builtins.sv`, the OTHER five built-ins + the ABSTAIN control

| cell | source | position | golden | ours CONTROL | ours FINAL | verdict |
|---|---|---|---|---|---|---|
| **E1** `cgc8.start();` | l.36 | STATEMENT | `method_func_call: (start)` + prefix ref_obj | **NOTHING** | **EQ** | in gate |
| **E2** `cgc8.stop();` | l.40 | STATEMENT | `method_func_call: (stop)` + prefix | NOTHING | **EQ** | in gate |
| **E3** `cgc8.set_inst_name("n8");` | l.44 | STATEMENT | mfc + `vpiArgument -> constant "n8"` + prefix | NOTHING | **EQ** | in gate |
| **E4** `r8 = cgc8.get_coverage();` | l.48 | EXPRESSION | `hier_path (cgc8.get_coverage) @48:12-48:31`, elements ref_obj + mfc | **ALREADY PRESENT**, span `48:29` | **EQ, span now 48:31** | in gate — **and the span IMPROVED** |
| **E5** `r8 = cgc8.get_inst_coverage();` | l.52 | EXPRESSION | same shape | already present, span short | **EQ** | in gate |
| **E6** `$display("cov=%f", cgc8.get_coverage());` | l.56 | ARGUMENT | `hier_path` as `vpiArgument` @56:26-56:45 | already present, span `56:43` | **EQ** | in gate |
| **E7** `r8 = cgc8.cpc8.get_coverage();` | l.60 | EXPRESSION | 3-element `hier_path (cgc8.cpc8.get_coverage)` | already present, span `60:34` vs golden `60:36` | **byte-unchanged** — still `60:34` | **ABSTAIN control PASSES**: parent scope is `Coverpoint` (91), never enters my clause |

**THE STATEMENT/EXPRESSION SPLIT IS THE REAL SHAPE OF THE DEFECT, and it is a
CORRECTION of the brief.** The brief described the head as "emitExpr's call
fallback chain has no arm for the kind". Measured: **EXPRESSION-position
covergroup built-in calls were ALREADY emitted** before this pass (E4/E5/E6/E7),
by a different path, and only **STATEMENT-position** calls were dropped. The
corpus head is statement position, which is why it looked total.

**AND THE PATCH FIXES A SPAN IT WAS NOT AIMED AT.** E4/E5/E6 now enter the class
arm and pick up its § callParenSpan11 (the hier_path runs through the closing
paren): golden `48:31`, control `48:29`, FINAL `48:31`. E7 does NOT, because it
is a Coverpoint — so E7 keeps the short span, which is exactly what an abstain
control is supposed to demonstrate.

**ARM a3 AFTER THE PATCH: `PASS_CMP`, heads=0.**

### 2.5 Arm a4 — `a4_context.sv`, CONTEXT — the two cells that REFUTE the brief's fix shape

| cell | source | golden | ours CONTROL | ours FINAL | verdict |
|---|---|---|---|---|---|
| **F1** module `initial`, module-scope cg instance | l.23 | `method_func_call: (sample) @23:9-23:15`, prefix `ref_obj (work@a4.cm8)` | NOTHING | **EQ** | the law is NOT class-scoped |
| **F2** module `always` | l.27 | same, parented at the `begin` | NOTHING | **EQ** | |
| **F3** module-scope TASK | l.31 | same, prefix `ref_obj (work@a4.mtask8.cm8)` | NOTHING | **EQ** | |
| **F4** `this.cgi8.sample();` | l.51 | **`method_func_call: (this) @51:12-51:16`** (located at `cgi8`), `vpiPrefix` a **STRING constant `"this"`** | NOTHING | **EQ** | **§ thisRecvCall11's statement form — the brief's prototype gets this WRONG** |
| **F5** `h8.cgi8.sample();` | l.61 | **`method_func_call: (cgi8) @61:10-61:14`**, prefix `ref_obj (…::f5_8::h8)`, the method name and args DROPPED | NOTHING | **EQ** | **§ deepRecvCall11's statement form — the prototype gets this WRONG too** |
| **F6** `plain8();` non-covergroup module task | l.39 | plain call | already EQ | **EQ, unchanged** | MUST-ABSTAIN control (`thisClass()==0`), PASSES |

F4 and F5 are the cells that decide the whole pass. A fresh arm modelled on the
flat `<recv>.<method>` shape — which is what the interface-method arm is, and
what r10svs7's prototype copies — cannot produce either object, because both
require Surelog's `compileTfCall` name-splitting rules that ONLY the class arm
implements. Widening the class arm gets them for free and correct.

**ARM a4 AFTER THE PATCH: `PASS_CMP`, heads=0.**

### 2.6 Arm a5 — `a5_escaped.sv`, ESCAPED IDENTIFIERS; and arm a6 — the ATTRIBUTION

| cell | source | golden | ours FINAL |
|---|---|---|---|
| **G1** `\cg.esc8 .sample();` — escaped cg name CONTAINING a dot | l.40 | mfc `(sample) @40:21-40:27`, prefix `ref_obj (…::g1_8::cg.esc8) @40:7-40:20`, **`vpiName:cg.esc8`** | objects and **BOTH NAMES byte-EQ**; spans `40:16-40:22` / `40:7-40:15` — **5 columns short** |
| **G2** `\escg8 .sample();` — escaped, no dot | l.44 | mfc `@44:19-44:25`, ref_obj `@44:7-44:18` | names EQ; spans 5 columns short |
| **G3** `h5.sample();` USER method named `sample` — IN-LAW | l.48 | mfc `(sample)` + prefix `ref_obj (…::g3_8::h5)` | **already EQ on the CONTROL; byte-unchanged** |
| **G4** bare `sample();` USER, no receiver — IN-LAW | l.56 | (`thisClass()==0`, outside the arm) | **already EQ; byte-unchanged** |

The G1 name is the decisive one: `cg.esc8` survives with its dot intact, because
the arm reads the bound receiver's SYMBOL. The brief's prototype would have split
the raw text `\cg.esc8 .sample` on its last `.` — which happens to work for this
spelling but is defeated by an escaped name ENDING in a dot, and is in any case
the wrong instrument.

**ARM a6 — `a6_escinlaw.sv` — WHOSE SPAN DEFECT IS IT? Measured on the CONTROL.**
The same escaped-receiver call on a plain CLASS handle, a shape that has taken
this arm since long before this pass:

| cell | source | golden (CONTROL run) | ours CONTROL | ours FINAL |
|---|---|---|---|---|
| **H1** `\h.esc8 .touch();` | l.32 | mfc `@32:20-32:25`, ref_obj `@32:7-32:19` | mfc `@32:15-32:20`, ref_obj `@32:7-32:14` — **+5 gap** | identical to CONTROL |
| **H2** `\hesc8 .touch();` | l.36 | mfc `@36:19-36:24`, ref_obj `@36:7-36:18` | mfc `@36:14-36:19`, ref_obj `@36:7-36:13` — **+5 gap** | identical to CONTROL |
| **H3** `h8.touch();` unescaped | l.40 | — | **EQ** | **EQ** |

**VERDICT: the +5 gap is PRE-EXISTING and NOT this law's.** It is present on the
CONTROL binary for class handles, it is a constant 5 columns regardless of the
escaped name's length (`\h.esc8` 7 chars and `\hesc8` 6 chars both gap by 5), and
`a6`'s whole `o.dump` is **byte-identical between the CONTROL and the FINAL
binary** after path normalisation — i.e. **this pass does not move the in-law arm
at all.** Ranked R3. (The same arm also shows a pre-existing escaped `class_var`
endln defect, golden `27:22` vs ours `28:3` — same owner.)

### 2.7 The corpus cell itself — `third_party/tests/SVSwitch/Coverage.sv:36`

```
LHS golden                                    RHS ours, FINAL
\_begin: (work@coverage::sample), 36:1-36:26  \_begin: (work@coverage::sample), 36:1-36:26
  ...                                           ...
  |vpiStmt:                                     |vpiStmt:
  \_method_func_call: (sample), 36:17-36:23     \_method_func_call: (sample), 36:17-36:23
    |vpiParent: \_begin: (work@coverage::…)       |vpiParent: \_begin: (work@coverage::…)
    |vpiName:sample                               |vpiName:sample
    |vpiPrefix:                                   |vpiPrefix:
    \_ref_obj: (work@coverage::sample::           \_ref_obj: (work@coverage::sample::
               switch_coverage), 36:1-36:16                  switch_coverage), 36:1-36:16
      |vpiName:switch_coverage                      |vpiName:switch_coverage
      |vpiFullName:work@coverage::sample::…         |vpiFullName:work@coverage::sample::…
```

Note the corpus's own name collision: the enclosing TASK is `work@coverage::sample`
and the built-in is `sample`. The gate reads a scope kind, so it is unaffected.

---

## 3. WHAT I DID NOT DO, AND WHY

* **§ covergroupNewCall7's two halves: UNTOUCHED.** Read first
  (`tools/probe/r10svs7repro/README.md` in full, plus its written-formal-set arg
  filter). It owns covergroup `new`; this pass owns covergroup METHOD CALLS. The
  two are different `ExpressionKind`s (`NewCovergroup` vs `Call`) reached through
  different `case` labels, and my diff does not enter its `case` at all.
* **r10svs7's `residue_R1_prototype.diff.txt`: RE-DERIVED AND REJECTED**, not
  copied. It was correctly labelled a hypothesis; §0 and §2.5 give the two cells
  that refute it and §2.6 gives the hazard it would have carried in. Its
  MEASURED prediction — SVSwitch head `158 -> 48`, both modes — is REPRODUCED
  exactly by this (different) fix, which is a useful cross-check that both
  approaches reach the same head even though only one builds golden's objects
  for F4/F5.
* **r10uvm61 ($bits folds): LANDED MID-PASS — CHECKED, NO COLLISION.** The brief
  listed it as live; it landed as `75bfb7e` while I was gating, and it edits the
  SAME FILE (`src/ExprEmit.cpp`, +284). Measured rather than assumed:

  ```
  r10uvm61 hunks : @@ -1160,6  (its srlgBitsFoldArg helper region)
                   @@ -11366,6 @@ -11383,7   (the $bits fold inside emitExpr)
  my hunks       : @@ -383,6   (the static-helper region)
                   @@ -9173,8  (the class-method call gate)
  its two SymbolKind::ClassType references are inside its OWN new helpers
  (the fold's home-class check), not in any call gate.
  git apply --check /tmp/r10svs8.patch  on 75bfb7e  ->  APPLY_CHECK_OK
  git diff a060719 75bfb7e -- results/  ->  EMPTY
  ```

  Disjoint regions, no textual conflict, and — decisively for the row gates —
  **`results/*.csv` is byte-identical between a060719 and 75bfb7e**, so GATE 3
  and GATE 4 compared against the correct committed baselines even though the
  main tree moved under them. **Honest limit:** my binaries are built from
  a060719, so the COMBINED a060719+r10uvm61+r10svs8 behaviour is not gated by
  me. The two laws share no predicate, no scope kind and no `case` label, but an
  integrator landing both should re-run the byte verifier on the merge.
* **The Coverpoint / CoverCross built-ins: DELIBERATELY OUT.** They already match
  golden (E7), and admitting them would have moved a passing cell for no reason.
* **The escaped-identifier span law: NOT touched**, and §2.6 proves it is not
  mine to fix here.

---

## 4. THE FIVE GATES — every number EXECUTED

### GATE 1 — BUILD

Absolute paths, link line waited for, md5 asserted separately, 32 hex each.

```
CONTROL  /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10svs8pris/build/slang-uhdm
         [100%] Linking CXX executable slang-uhdm      (full configure + build)
         md5 365219cb664f4498d52c9aa68f605ba7
         == md5 of the main-tree /home/heyfey/git-repos/slang-uhdm/build/slang-uhdm
         git rev-parse HEAD = a060719294b588fdfc85918775a5ad49603dd569
         git status --porcelain: EMPTY
FINAL    /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10svs8/build/slang-uhdm
         [100%] Linking CXX executable slang-uhdm
         md5 4e5d371eddeaf9bdbc1ce08bd73019a0
         git rev-parse HEAD = a060719294b588fdfc85918775a5ad49603dd569
         git status --short:  M src/ExprEmit.cpp   /   ?? tools/probe/r10svs8repro/
```

**TIMING NOTE — stated because the naive version of this claim no longer
reproduces, and the campaign has been burned by exactly this before ("check each
binary's BASE before attributing any delta").** At the moment I built, three
independent `md5sum` runs printed the SAME 32 hex digits —
`365219cb664f4498d52c9aa68f605ba7` — for `r10svs8pris/build/slang-uhdm`,
`r10svs8/build/slang-uhdm` (before my edit) and the main-tree
`build/slang-uhdm`. **The main tree has since moved on**: it is now at
`75bfb7e` (r10uvm61 landed mid-pass) and its `build/slang-uhdm` is
`5cf09f5121afbb14a66eacfc84bd859b`. So the CONTROL's validity does NOT rest on
the main-tree comparison — it rests on its own worktree's
`git rev-parse HEAD = a060719…` with an EMPTY `git status --porcelain`, which is
re-checkable at any time. The main-tree equality was corroboration valid at
measurement time and is recorded as such, not as a live assertion.

### GATE 2 — GOLDENS

```
SLANG_UHDM=<FINAL>    tests/check_goldens.sh  ->  PASS 23   FAIL 0
SLANG_UHDM=/bin/false tests/check_goldens.sh  ->  PASS  0   FAIL 23   (negative control)
```
Run from the repo root, per the standing rules.

### GATE 3 — uhdm2rtlil, testflags, `--jobs 2`, own `--out`/`--workdir`

```
[testflags] 731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
DUMP column   52 (blank)   183 differ   496 match
ct8rows.sh vs results/gate_uhdm2rtlil.csv (731 ROWS, header not counted):
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
                 — IDENTICAL to the committed baseline in BOTH modes
ct8rows.sh vs results/golden_surelog.csv (1588 ROWS):
  WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  PASS: every row byte-identical to the committed baseline
```

**467/13 and 463/10 — the UNCONVERTED numbers, as the brief required.**
SVSwitch stayed `CMP_NOTEQUAL` in both modes; R2 did not fall and was never
expected to. **No `results/*.csv` was edited.**

### GATE 5 — BYTE VERIFIER, both corpora, vs the PRISTINE a060719 I built myself

```
surelog   : databases patched=953 pristine=953   PATH_SETS_IDENTICAL (953 paths)
            MOVER ./default/SVSwitch-db796243/slang.uhdm    e77036f7f80e vs 119237c36e21
            MOVER ./testflags/SVSwitch-db796243/slang.uhdm  e77036f7f80e vs 119237c36e21
            MOVERS: 2 / 953
            SELFCHECK  (every file vs one fixed file): 952 / 953 flagged   [PASS]
            SELFCHECK1 (one file corrupted): 3 = 2 real + 1 corrupted      [PASS]
uhdm2rtlil: databases patched=679 pristine=679   PATH_SETS_IDENTICAL (679 paths)
            MOVERS: 0 / 679
            SELFCHECK: 678 / 679                                          [PASS]
            SELFCHECK1: 1 = 0 real + 1 corrupted                          [PASS]
```

**KNOWN FLAKE, addressed:** `Scoreboard,default` is bistable (proven three
times). It did **not** appear as a mover in this run, so no reps were needed to
attribute anything; the two movers are the two SVSwitch rows and nothing else.

### CANARIES

```
ctcan2.sh  golden_surelog.csv   sl_fin.csv    EXPECT_UNKNOWN=1 -> ok=58 changed=0 absent=0 unknown=1  PASS
ctcan2.sh  gate_uhdm2rtlil.csv  u2r_fin.csv   EXPECT_UNKNOWN=6 -> ok=1  changed=0 absent=0 unknown=6  PASS
canaries.sh sl_fin.csv  golden_surelog.csv  -> ok=52 changed=0 absent=0 unknown-names=7   (surelog: expected 7)
canaries.sh u2r_fin.csv gate_uhdm2rtlil.csv -> ok=8  changed=0 absent=0 unknown-names=25  (u2r: expected 25)
canaudit.sh canaries.sh ctcan2.sh -> audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS

BY NAME, quoted, fresh sweep vs committed baseline (identical):
  InterfaceModPort     default   CMP_EQUAL/differ        baseline CMP_EQUAL/differ
  InterfaceModPort     testflags CMP_EQUAL/differ        baseline CMP_EQUAL/differ
  BlackParrotComplex   default   CMP_EQUAL/differ        baseline CMP_EQUAL/differ
  BlackParrotComplex   testflags CMP_EQUAL/differ        baseline CMP_EQUAL/differ
  SVSwitch             default   CMP_NOTEQUAL/           baseline CMP_NOTEQUAL/
  SVSwitch             testflags CMP_NOTEQUAL/           baseline CMP_NOTEQUAL/
```

The four SLANG-FENCED names (UnsignedParam, HierPathEval, FileLocalParam,
TopParam) are dispatched by NO driver in this directory — asserted by
`canaudit.sh` (`FENCE-BREACH=0`), not by a sentence.

---

## 5. MOVERS PER SHAPE, by MULTISET, ADDED and REMOVED SEPARATELY

`msmovers.sh <golden.uhdm> <pristine slang.uhdm> <patched slang.uhdm>` — DUMPS
with `sed 1d`, never the `.uhdm` binaries. **Identical output for both modes:**

```
MULTISET distance to GOLDEN   PRISTINE: golden-only 507  ours-only 886  TOTAL 1393
MULTISET distance to GOLDEN   PATCHED : golden-only 497  ours-only 887  TOTAL 1384

OBJECT lines (\_ marker):
ADDED   +1  \_begin: (work@coverage::sample), line:36:1, endln:36:26
ADDED   +1  \_method_func_call: (sample), line:36:17, endln:36:23   (in-tree occurrence)
ADDED   +1  \_method_func_call: (sample), line:36:17, endln:36:23   (flat-listing occurrence)
ADDED   +1  \_ref_obj: (work@coverage::sample::switch_coverage), line:36:1, endln:36:16
REMOVED     (none)

BARE FIELD lines — NON-ATTRIBUTABLE absorbers, listed and NOT counted:
ADDED +1 |vpiFullName:work@coverage::sample::switch_coverage   |vpiName:sample
         |vpiName:switch_coverage   |vpiParent: (x2)   |vpiPrefix:   |vpiStmt:
```

**Every one of the four object lines is an object golden HAS**, and no object
line entered EXCESS on our side. Established independently by differencing the
two binaries' per-shape **excess-over-golden** tables (per distinct dump line,
`ours_count - golden_count` where positive; 456 rows each):

```
$ diff ex_pris.txt ex_fin.txt
333c333
< +25	          |vpiParent:
---
> +26	          |vpiParent:
```

**ONE line differs, and it is a bare field line.** The ours-side file grew by 11
lines while `golden-only` fell by **10**; the single non-matching addition is
exactly the class of line the measurement law calls non-attributable.

---

## 6. REPRODUCING

```
tools/probe/r10svs8repro/
  ct8arm.sh      one arm: surelog golden + ours + cmp + dump distance (SLANG_UHDM required, no default)
  ct8cell.sh     read ONE cell out of an arm workdir, by CONTENT, with side banners
  ct8rows.sh     THE ROW GATE: whole-row diff vs a committed baseline + histograms
  byteverify.sh  GATE 5, with both negative controls (SELFCHECK / SELFCHECK1)
  msdist.sh      resync-immune MULTISET dump distance (golden vs ours)
  msmovers.sh    per-shape movers for ONE database, ADDED / REMOVED separate
  ctcan2.sh canaries.sh canaudit.sh   the canaries and the AUDIT of the canaries
  a1_witness.sv  the corpus shape + the user-method IN-LAW controls
  a2_args.sv     `with function sample(...)` actuals
  a3_builtins.sv the other five built-ins + the Coverpoint ABSTAIN control
  a4_context.sv  module/initial/always/this-rooted/deep-receiver contexts
  a5_escaped.sv  escaped identifiers (incl. one CONTAINING a dot) + user `sample`
  a6_escinlaw.sv the ATTRIBUTION arm: the same escaped call on a CLASS handle
```

```
SLANG_UHDM=<binary> ./ct8arm.sh a1_witness.sv /tmp/x_a1
./ct8cell.sh /tmp/x_a1 'task: \(work@a1::cov8::samp8\)' 22
```

---

## 7. RANKED RESIDUES

| # | residue | evidence | who |
|---|---|---|---|
| **R1** | **SVSwitch head 3 — `Environemnt.sv:63`, `@(input_intf.clock)`.** Golden's `event_control` holds ONE `ref_obj (work@Environment::reset::input_intf)` @63:16-63:32, named for the WHOLE dotted text; ours builds a two-element `hier_path (input_intf.clock)` @63:16-63:32 whose first element is `ref_obj (input_intf)` @63:16-63:26. A virtual-interface event-control NAMING law — the object count and the span already agree, only the shape and the name do not. This is the brief's predicted R2 and it is now the WHOLE of SVSwitch's remaining head: 48 cmp lines, 1 head, identical in both modes. | `/tmp/r10svs8_cmp_fin_default.log` head, reproduced by the §6 recipe on the corpus test | **next pass — rank 1; SVSwitch converts on this one if nothing else hides behind it** |
| **R2** | a class PROPERTY of a NAMED covergroup type is dropped entirely (`unsupported: class property type: CovergroupType`), which is the ONE unsupported-construct line every arm here still prints. Inherited unchanged from r10svs7 (its R3). Golden emits a `logic_var` with `vpiExpr -> method_func_call (new)` parented at the class_defn. A DECLARATION law in `emitClassDefn`, sibling to the module-scope arm in `src/ModuleEmit.cpp` (`grep 'ctCE.kind == SymbolKind::CovergroupType'`). NOT in the corpus: SVSwitch writes the EMBEDDED covergroup form, for which golden emits no variable at all. | every arm's `slang.log`, `unsupported(ours): 1`; arm a2/a3 residual dump content (26 lines) is entirely this | whoever owns class-property emission |
| **R3** | **ESCAPED-IDENTIFIER SPANS on a method receiver.** For an escaped receiver our `method_func_call` and its prefix `ref_obj` end **5 columns short** of golden, constant regardless of the name's length. **PROVED PRE-EXISTING**, not this law's: arm a6 writes the identical call on a plain CLASS handle and the **CONTROL** binary shows the same +5 gap (`32:20-32:25` golden vs `32:15-32:20` ours), and a6's whole `o.dump` is byte-identical between CONTROL and FINAL. This pass only made the gap VISIBLE for covergroup receivers, which previously emitted no object at all. Sibling of r10svs7's R5b. Also visible on an escaped `class_var` endln (golden `27:22`, ours `28:3`). Not in the corpus. | arm a5 G1/G2 (FINAL) + arm a6 H1/H2 (CONTROL **and** FINAL) | escaped-identifier span owner |
| **R4** | **A COVERPOINT's built-in `get_coverage()` keeps the SHORT hier_path span** — golden `60:12-60:36`, ours `60:12-60:34` — because `Coverpoint` is deliberately outside § covergroupBuiltinCall8 and therefore never picks up § callParenSpan11. The covergroup-level twin (E4) was fixed as a side effect: `48:29 -> 48:31 = golden`. Closing R4 is probably one more scope kind on the same predicate, but it MUST be measured on its own arm first — CoverCross has a body kind of its own and was not gridded here. Not in the corpus. | arm a3 cells E4 (fixed) vs E7 (unchanged), all three binaries quoted in §2.4 | next pass, cheap; same predicate |
| **R5** | Surelog keeps only the LAST statement of a class CONSTRUCTOR body (r10svs7 §2.1). Every arm here obeys it (one statement per `new`), so it bit nothing; it is re-recorded because it silently deletes arm cells and will bite the next author who does not know it. | r10svs7's `p3_ctorstmt.sv` | recorded, not claimed |
| **R6** | Arm a1's surviving `cmp` head is pure ORDERING: golden lists that arm's `class_defn` children in the reverse of our order, MULTISET DISTANCE **0** over 842 lines. A pre-existing arm artefact (r10svs7 §2.2 saw the same thing), NOT a corpus behaviour — the corpus databases show no such reversal. | `diff <(sort g.dump) <(sort o.dump)` = 0 lines on `/tmp/r10svs8_fin_a1_witness` | recorded, not claimed |

---

## 8. THE DIFF

`src/ExprEmit.cpp` only, two hunks, **89 insertions / 1 deletion**:

1. `static bool covergroupBuiltinCall8(const SubroutineSymbol&)` — the predicate,
   inserted between § inClassScope12 and § staticScopedChainDrops48, carrying the
   slang citation for all six built-ins and the Coverpoint/CoverCross exclusion
   with its executed control;
2. the class-method arm's parent-scope gate, widened by ONE OR-clause, with the
   `NOTE § covergroupBuiltinCall8` block naming the cells that justify it (a1
   C1==C3, a2 D3==D5, a4 F4, a4 F5) and the escaped-identifier hazard that rules
   out a source-text split.

The executable change is one predicate and one `||`; the other 78 lines are the
NOTE blocks. Nothing else in `src/` is touched; nothing outside my worktree was
written; no `results/*.csv` was modified.
