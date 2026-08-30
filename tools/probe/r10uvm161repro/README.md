# r10uvm161 — § `assertCondIsAClassMethodWindow161` — **AN IMMEDIATE ASSERTION'S CONDITION AND A CASE ITEM EXPRESSION ARE `classMethodNoBind` WINDOWS, EXACTLY AS AN `if` / `case` CONDITION IS** — the SimpleUVM ×2 **29-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `fe4a739` |
| pristine binary | md5 `83258cd958cb88be667bf6729dcb0b9d`, built from this pass's own worktree at a clean `fe4a739` and frozen `chmod 555` before any sweep |
| patched binary | md5 `015180bcb928448e2c561c0857cebd2f`, frozen `chmod 555`. The patch applied to a **FRESH `fe4a739` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on. Restoring the patched sources after the third-binary experiment and rebuilding reproduced the same md5 too |
| production surface | `src/StmtEmit.cpp` (one 8-line RAII helper and four one-line uses), `include/UhdmExporter.h` (the law) — **116 inserted lines, 0 deleted** |
| probe surface | `tools/probe/r10uvm161repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | head |
|---|---|---|---|
| **SimpleUVM default / testflags** | **29** | **29** | the `chandle_var compiled_regex` head is **GONE**; the head is now a **DIFFERENT object**, `LHS: <null> / RHS: io_decl(action)` — a **PRE-EXISTING** ONLY-OURS binding this pass UNMASKED, proved byte-identical in the pristine database (§7) |
| SeqDriver default / testflags | 17 | 17 | 1 unchanged, head log BYTE-IDENTICAL (the database MOVED; its `compiled_regex` cell was masked by an earlier head) |
| Scoreboard default | 145 | 145 | 1 unchanged, head log BYTE-IDENTICAL (same) |
| MiniAmiq default / testflags | 106 | 106 | 1 unchanged, head log BYTE-IDENTICAL (same) |
| BuildUVMPkg default / testflags | 321 | 321 | 1 unchanged, head log BYTE-IDENTICAL |
| Earlgrey_0_1 default / testflags | 132 / 26594 | 132 / 26594 | 1 unchanged, head log BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** — both corpora, both modes; surelog `CMP_NOTEQUAL` stays **10 default + 9 testflags**, uhdm2rtlil stays `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2`, status histograms IDENTICAL to this pass's own pristine sweep |
| byte movers | — | **7 / 956** surelog — **all seven PREDICTED BY NAME from the pristine databases before the patched sweep ran** — and **0 / 1358** uhdm2rtlil |
| the corpus census (7 moved DBs) | — | **13 cells moved, 13 TOWARD-EXACT, 0 MISMATCH, 0 AWAY; 0 `VAR` / `CNT` lines moved** |
| the grid (4 arms, both views) | — | golden-vs-patched **DIFF 0 / 0 / 0 / 1** (arms A/B/C/D); **64 cells moved, all TOWARD; MOVED-WRONG 0, AWAY 0, RESHAPE 0**; the one arm-D residue is pre-existing and unchanged |
| the WIDE boundary (4590 arms, both views) | — | **MOVED_ARMS 10, RC_DIFFS 0** — 4 are this pass's own grid (the positive control), 4 carry 5 TOWARD cells, 2 are refuted as a build-layout artifact by a THIRD binary built from the UNPATCHED source |

Counts are **DEPTH, not distance**: a cmp line count is the HEAD OBJECT'S
decompile size (RESUME.md §7). SimpleUVM reads 29 before and 29 after because
the two heads' decompiles happen to be the same size — they are DIFFERENT
OBJECTS (§7). `Scoreboard/testflags` is `SLANG_REJECT` and `Rggen/testflags`
has no golden — both print SKIP-NOFILE and are COUNTED, never read as
perfection.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this worktree's own pristine sweep reproduced the brief
exactly — **SimpleUVM default and testflags, 29 cmp lines, 1 head each** — and
`head_pris_SimpleUVM.default.cmp` is **byte-identical** to the head r10uvm160
predicted (`r10uvm160repro/head_pat_SimpleUVM.default.cmp`):

```
LHS:
chandle_var: (uvm_pkg::uvm_component_name_check_visitor::visit::compiled_regex)
              @257:18-257:32
 |vpiParent:  \_begin: (…::visit) @259:3-260:58
 |vpiTypespec:\_ref_typespec -> \_chandle_typespec @257:10-257:17
RHS: <null>
```

Source — `uvm-1.2/src/base/uvm_traversal.svh:243-262`:

```systemverilog
class uvm_component_name_check_visitor extends uvm_visitor#(uvm_component); // :243
  virtual function void visit(NODE node);                                   // :255
    static chandle compiled_regex;                                          // :257
    if(compiled_regex==null)                                                // :259
      compiled_regex=uvm_dpi_regcomp(get_name_constraint());                // :260
    assert(compiled_regex!=null);                                           // :262
```

### (1) WHAT THE JUDGE ACTUALLY FAILED ON — DECIDED BY MEASUREMENT, AND IT IS **NOT** A LISTING

The brief read this head as a **static method-local's LISTING**. It is not.
`RHS: <null>` on a **VALUE** is `BaseClass.h`'s **SINGULAR** `SafeCompare`
(`:190-193`), never a `scope::Variables` vector — the vector overload with a
null RHS names the OWNER (the `begin`) as LHS, and a size mismatch sets BOTH
containers (RESUME.md §9). So the failing edge could not be read off
`scope::Compare`'s field order at all, and `ct157own`/`ct160own`'s
one-kind field walk could not find it.

`ct161own.cpp` answers it three ways, and the third is the one that decides:

* a **parent-chain probe** — each ancestor of the head matched globally and
  asked whether its OWN `Compare` reproduces the design-level head;
* a **generic child descent** by `VpiParent`;
* **the REFERENCE SCAN**, which needs no walk: `GetByVpiType` is the generated,
  kind-agnostic edge accessor (a switch over the vpi relation constants), so
  *every* edge of *every* golden object can be enumerated and the ones that
  land ON the head printed together with our counterpart's same edge.

On the corpus row `default/SimpleUVM-1dc93a62` the scan prints FIVE golden
edges onto the head object and ONE of them disagrees:

```
golden begin()@259:3-260:58      edge vpiType=100 (vpiVariables, index 0)
  ours begin()@259:3-260:58   -> vector present size 1, [0] = chandle_var(compiled_regex)   SAME
golden function(visit)@255:2     edge vpiType=100 (vpiVariables, index 0)
  ours function(visit)@255:2  -> the same listing                                            SAME
golden ref_obj(compiled_regex)@259:6   edge vpiType=700 (vpiActual, singular)
  ours -> chandle_var(compiled_regex)                                                        SAME
golden ref_obj(compiled_regex)@262:10  edge vpiType=700 (vpiActual, singular)
  ours -> <null>                                                             <-- THE HEAD
golden ref_typespec()  edge vpiType=81 (singular)
  ours -> chandle_var(compiled_regex)                                                        SAME
```

**THE LISTING IS ALREADY EXACT.** Both the `begin` and the `function` list the
`chandle_var`, in golden and in ours, at the same index, with the same
`vpiAutomatic` stamp (0 — § `tfItemLocalAutomaticIsNotWrittenStatic139`'s
written-`static` rule, already correct). The failing edge is
`ref_obj::Actual_group` on the reference at **`:262:10`, inside the
`assert (compiled_regex != null)` CONDITION**.

The six `compiled_regex` references in that class read, cell for cell:

| reference | position | golden | ours (pristine) |
|---|---|---|---|
| 259:6 | operand of an `if` CONDITION | `chandle_var` | `chandle_var` ✓ |
| 260:4 | LHS of an assignment inside the `if` body | `<null>` | `<null>` ✓ |
| **262:10** | **operand of an `assert` CONDITION** | **`chandle_var`** | **`<null>`** ✗ |
| 266:23 | argument of a `func_call` inside an `if` body | `<null>` | `<null>` ✓ |
| 284:25 / 285:9 | elements of a `hier_path` | `<null>` | `<null>` ✓ |

One cell out of six. Everything else about this variable — its kind, its
typespec, its `vpiAutomatic`, both of its listings — was already golden's.

Two further pieces of the inherited framing are **refuted by the source and by
measurement**, and are recorded here so no later pass re-derives them:

* **the home is NOT a generic class's default specialization.**
  `uvm_traversal.svh:243` reads
  `class uvm_component_name_check_visitor extends uvm_visitor#(uvm_component);`
  — it carries **no parameter list at all**; `NODE` is the *base* class's type
  parameter, already bound to `uvm_component`. So § `badBlockKeepsItsScope158`'s
  population (a `begin` slang bound bad in silence inside a default
  specialization nothing specializes) is not this head's family, and nothing
  here is a recovered block item.
* **the LISTING is not the axis.** `ct161cen`'s `VAR` and `CNT` families —
  every `vpiVariables` entry with its `vpiAutomatic` stamp, and every scope's
  listing COUNT including scopes that list nothing — score **DIFF 0,
  ONLY-G 0, ONLY-O 0** on all four grid arms in both views, and **0 lines
  moved** in all seven moved corpus databases. The `static chandle` local is
  listed on the synthesised `begin` AND on the `function`, at index 0 on both,
  with `vpiAutomatic 0` (§ `tfItemLocalAutomaticIsNotWrittenStatic139`'s
  written-`static` rule), in golden and in ours, before and after this pass.

---

## 2. THE LAW

> **§ `assertCondIsAClassMethodWindow161`** — *the six `condBindDepth5` window
> positions and the `classMethodNoBind` window positions are **the same set**.
> An **immediate assert / assume / cover CONDITION** and a **case ITEM
> EXPRESSION** bind an IN-BODY class method's ordinary locals and formals
> exactly as an `if` or `case` CONDITION does. The § `refVarLocalWindowBinds5`
> v-fix added both positions to the COUNTER and neither to the FLAG, so that
> law's `ref_var` half bound there and every already-resolved kind stayed
> bare.*

DIRECTION: **ADD** (a `vpiActual` that was absent) — never delete, never
reshape. The flag is only ever CLEARED and restored, so a body that already
bound keeps binding.

### THE SURELOG MECHANISM, READ NOT GUESSED

A reference is bound eagerly by `CompileHelper::bindVariable`
(`Surelog/src/DesignCompile/CompileStmt.cpp:3089-3149`), which walks the
`pexpr` it is handed **up its `VpiParent` chain** and reads `Variables()` /
`Io_decls()` off the `uhdmfunction` / `uhdmtask` it reaches, `Variables()` off
a `uhdmbegin`, and `Variables()` / `Nets()` off a `uhdmmodule_inst`.

Whether that walk ARRIVES is decided by ONE thing — whether the object handed
in as `pstmt` already carries its own `VpiParent`:

```cpp
// compileConditionalStmt, CompileStmt.cpp:1321
UHDM::any* cond_exp = compileExpression(component, fC, Cond_predicate,
                                        compileDesign, Reduce::No, pstmt, instance);
…
compileStmt(component, fC, If_branch_stmt, compileDesign, Reduce::No, cond_stmt, …);
//                                                                    ^ parent still null

// compileSimpleImmediateAssertion, CompileAssertion.cpp:269 / :285
UHDM::any* expr = compileExpression(component, fC, Expression, compileDesign,
                                    Reduce::No, pstmt, instance);
…
if_stmts = compileStmt(component, fC, if_stmt_id, compileDesign, Reduce::No, pstmt);
…
astmt->Expr((UHDM::expr*)expr);
if (expr) expr->VpiParent(astmt);            // :306 — re-parented only AFTERWARDS
```

**The two are the same shape.** The assertion's CONDITION is compiled with the
enclosing, already-parented `pstmt`, so `bindVariable` climbs into the `begin`
and the `function` and finds the local; the ACTION BLOCK is a statement and
binds late — which inside a class body means not at all. The deferred twin
(`:360`, `:379-380`) does the same. `compileCaseStmt` compiles the case
CONDITION at `:1445-1446` and **every ITEM EXPRESSION at `:1504-1506`** with
`pstmt`, and the item's CLAUSE at `:1513` with the `case_item`;
`case … inside` is the exception — its members are compiled against the
synthesized `inside` OPERATION (`:1543`), which is parentless. That split is
already decoded in our own tree by `condPredEarlyBound81` (`src/ExprEmit.cpp`).

### GOLDEN vs GOLDEN FIRST — THE TWO COLUMNS ARE IDENTICAL, 18 OF 18

`g161_b_notmove.sv` reads **eighteen referent kinds TWICE** out of the same
in-body class method: once from an `if` CONDITION (the window our emitter
already opens, so its cells are the pristine-correct control) and once from an
ASSERTION CONDITION. Golden's two columns agree on every one:

| referent | `if` condition | `assert` condition |
|---|---|---|
| plain local (`int`) | `int_var` | `int_var` |
| **`static` local** | `int_var` | `int_var` |
| formal | `io_decl` | `io_decl` |
| class-handle local | `class_var` | `class_var` |
| enum local | `enum_var` | `enum_var` |
| `$bits(<local>)` system-call argument | `int_var` | `int_var` |
| class property | bare | bare |
| `static` property | bare | bare |
| `const` property | bare | bare |
| INHERITED property | bare | bare |
| class-handle property | bare | bare |
| property array element (`bit_select`) | bare | bare |
| queue method call (`que.size()`) | bare | bare |
| enum property | bare | bare |
| enum constant | bare | bare |
| class localparam | bare | bare |
| package parameter | bare | bare |
| package variable | bare | bare |
| `this.<prop>` (a `hier_path` element) | bare | bare |

`g161_d_item.sv` does the same for the CASE ITEM column (local and formal
BOUND; property, static property, package variable, package parameter and enum
constant BARE; `casex` binds; `case … inside` bare), and for the EVENT CONTROL
column, which this pass deliberately does **not** touch: an event LOCAL is
golden-BOUND and ours is bound, an event PROPERTY is golden-bare and ours is
bare, a local inside a `posedge` is golden-BOUND and ours is bound —
§ `evCtrlBindPos108` already carries it.

**That is the safety proof.** Our emitter is already right on every `if`-column
cell; golden's assertion and case-item columns are that same column; so making
the two positions take the same code path cannot move a cell golden leaves
bare. It is a proof by MEASUREMENT of both producers, not by shape.

### STATED GATE == CODE GATE

The flag is cleared at the FOUR positions `src/StmtEmit.cpp` names
`SITE 1-4 of 4` — the non-`inside` case ITEM expression loop and the three
immediate-assertion CONDITION lambdas — and nowhere else. **No kind test, no
home test, no depth test.** § `controlBodyNoBind28`'s `ctrlBodyDepth28` still
decides the depth half (an assertion one control body deeper stays bare) and
§ 12 / § 57 / § 64 keep their own rules; the boundary arm
`r10uvm64repro/v2_ctx.sv` is the live witness that §64's same-depth
block-local carve-out now fires in this window too, exactly as golden does.

---

## 3. THE CHANGE

`include/UhdmExporter.h` — the law, its Surelog citations, the gate and the
measured cells (83 lines of comment, no code).

`src/StmtEmit.cpp` — one RAII helper beside `CondWindow5`, and four one-line
uses:

```cpp
struct MethodWindow161 {
    bool* p;
    bool saved;
    explicit MethodWindow161(bool& f) : p(&f), saved(f) { f = false; }
    ~MethodWindow161() { *p = saved; }
};
```

It is the RAII form of the
`bool sX = classMethodNoBind; classMethodNoBind = false; … ; classMethodNoBind = sX;`
block the three `if` / `if_else` / `case` CONDITION sites already spell by
hand, so the two sites this pass adds read the same as the three that were
there. **116 inserted lines, 0 deleted, 0 changed.**

---

## 4. THE PREDICTION, MADE FROM THE PRISTINE DATABASES BEFORE ANY PATCHED ONE EXISTED

`ct161pred.cpp` reads a PRISTINE database and names every cell the law can
move. Its four conditions are read off the database itself: an unbound
reference (which already excludes every out-of-body method, package function,
module function and process — those bind in the pristine database already);
inside an `immediate_assert`/`assume`/`cover`'s `Expr()` subtree or a
`case_item`'s `VpiExprs()` subtree, read as **EDGES** and never off
`vpiParent` (a case-item reference is re-parented to the enclosing scope by
BOTH producers, so its parent chain cannot tell it from an ordinary
statement's); at CONTROL DEPTH 0; and a NAME an enclosing scope lists the way
`bindVariable` reads it.

CALIBRATION on this pass's own arms — predicted vs the cells the patched
binary actually moved, per arm: **19/19, 6/6, 11/11, 3/3.**

Two terms were *forced* by measurement rather than assumed:

* the **case-item depth walk starts at the `case_stmt`, not the `case_item`** —
  item expressions are compiled with `pstmt`, so the case is not a control body
  for them; starting at the item counted the `case_stmt` and predicted ZERO
  cells where arm D measured three;
* a **`hier_path` ELEMENT binds nothing**, in every window and on both sides.
  Without that term the predictor named `FuncStructVal`'s eighteen
  `Cfg.<field>` assertion operands — and that database is **BYTE-IDENTICAL**
  under the two binaries (checked directly, `md5 3148ad7221d046b8a0199801a32b8794`
  from both). Golden leaves those eighteen bare too.

**THE PREDICTION** (`PREDICT.r10uvm161.txt`):

```
surelog     956 pristine databases  ->  7 rows, 13 cells
  default/MiniAmiq-544c7f61      4   compiled_regex 262:10, assertion 849:51,
                                     a_expression 1028:44, all_succeeded 1076:55
  default/Scoreboard-59431470    1   compiled_regex 262:10
  default/SeqDriver-32af76aa     1   compiled_regex 262:10
  default/SimpleUVM-1dc93a62     1   compiled_regex 262:10
  testflags/MiniAmiq-544c7f61    4   (the same four)
  testflags/SeqDriver-32af76aa   1   compiled_regex 262:10
  testflags/SimpleUVM-1dc93a62   1   compiled_regex 262:10
uhdm2rtlil 1358 pristine databases  ->  0 rows, 0 cells
```

**THE OUTCOME:** `byteverify` reported **exactly those 7 databases** and
**0 / 1358** on uhdm2rtlil. No unpredicted mover, in either corpus.

The corpus carries **no case-item cell at all** — that half of the law is
carried by purpose-built goldens (arms C and D) and by four boundary arms, and
moves zero corpus cells.

---

## 5. THE GRID — 4 ARMS, BOTH VIEWS, THREE WAYS

`grid161.sh` builds each arm with Surelog (golden) and with both binaries in
the `def` and `elab` views, echoing every command with its binary PATH into
`cmds.txt` and recording every rc. `ct161cen` censuses three cell families —
`REF` (every reference and the `vpiActual` it carries), `VAR` (every
`vpiVariables` listing entry with its `vpiAutomatic` stamp) and `CNT` (every
scope's listing COUNT, including scopes that list NOTHING, so "we list where
golden lists none" is a DIFF and never a silent gap). `score161.py` joins them.

| arm | what it measures | golden vs PRISTINE | golden vs PATCHED | moved |
|---|---|---|---|---|
| **A** `g161_a_win.sv` | the population: assertion conditions in an in-body class method under the TF-ITEM and BLOCK-ITEM productions, in a static method and in a task, for `assert`/`assume`/`cover`/`assert #0`/`assert final`; and the controls that must not move — the pass and else ACTION BLOCKS, one control body deeper, a `while` body, a `forever` body, an OUT-OF-BODY method, a package free function, a module function and an `initial` block | REF **DIFF 28** | REF **DIFF 0** | 28 |
| **B** `g161_b_notmove.sv` | eighteen referent kinds read TWICE — from an `if` condition and from an assertion condition | REF **DIFF 12** | REF **DIFF 0** | 12 |
| **C** `g161_c_sites.sv` | the other positions and the block shapes: case condition, case ITEM, event control, `while`/`for`/`do-while`/`repeat` conditions, and assertions inside a plain `begin`, a NAMED `begin` and a `fork` arm | REF **DIFF 20**, ONLY-O 1 | REF **DIFF 0**, ONLY-O 1 | 20 |
| **D** `g161_d_item.sv` | the CASE ITEM column and the EVENT CONTROL column across eight referent kinds, plus `casex` and `case … inside` | REF **DIFF 5**, ONLY-G 1, ONLY-O 4 | REF **DIFF 1**, ONLY-G 1, ONLY-O 4 | 4 |

`VAR` and `CNT` are **DIFF 0, ONLY-G 0, ONLY-O 0 on all four arms in both
directions** — the listings this pass was briefed to move were already exact
and this law does not touch them.

**64 cells moved in total; 65 golden-vs-ours DIFFs became 1.**
**MOVED-WRONG 0. AWAY 0. RESHAPE 0.** The single arm-D residue and the arm-C
`ONLY-O` are PRE-EXISTING and byte-for-byte unchanged (arm D: a `case … inside`
item where golden holds two copies of the reference and we hold one, plus two
elab parenting residues on an enum constant and a package parameter under a
`case_item`; arm C: an enum-constant `case_item` reference we carry and golden
re-parents). Arm-B's `ONLY-G`/`ONLY-O` disappear entirely under `--nospan`:
they are the `this.<prop>` hier_path SPAN residue of a different law, and no
generated `Compare` reads a line or a column (RESUME.md §9).

What golden does that arms A and C pin, and that the patched binary now
reproduces exactly:

* `assert` / `assume` / `cover` / `assert #0` / `assert final` conditions all
  BIND; the pass ACTION and the else ACTION are BARE;
* an assertion inside a **plain `begin`**, a **NAMED `begin`** and a **`fork`
  arm** at depth 0 all BIND — Surelog's `paSeq_block` / `paPar_block` arms run
  `scope->VpiParent(pstmt)` BEFORE compiling their children, so the chain is
  live — while one inside an `if` body, a `for` body, a `while` body, a
  `forever` body or a case ITEM's CLAUSE stays BARE;
* an out-of-body method, a package free function, a module function and a
  module `initial` block never set the flag and were already exact.

---

## 6. THE CORPUS CENSUS — 7 MOVED DATABASES, CELL FOR CELL

`CENSUS.r10uvm161.txt` censuses each moved database three ways (golden,
pristine, patched) and scores every moved cell against golden:

```
default/MiniAmiq-544c7f61     4 cells   4 TOWARD-EXACT
default/Scoreboard-59431470   1 cell    1 TOWARD-EXACT
default/SeqDriver-32af76aa    1 cell    1 TOWARD-EXACT
default/SimpleUVM-1dc93a62    1 cell    1 TOWARD-EXACT
testflags/MiniAmiq-544c7f61   4 cells   4 TOWARD-EXACT
testflags/SeqDriver-32af76aa  1 cell    1 TOWARD-EXACT
testflags/SimpleUVM-1dc93a62  1 cell    1 TOWARD-EXACT
------------------------------------------------------
                             13 cells  13 TOWARD-EXACT, 0 MISMATCH
        VAR / CNT lines moved: 0 in every one of the seven databases
```

Every cell went `ACT=NONE` → the object golden itself carries, with the SAME
home chain on both sides:

| database | reference | patched = golden |
|---|---|---|
| SimpleUVM / SeqDriver / Scoreboard / MiniAmiq | `compiled_regex` @262:10 | `chandle_var:compiled_regex` |
| MiniAmiq | `assertion` @849:51 (`CHECK_SVA_EXISTS`) | `class_var:assertion` |
| MiniAmiq | `a_expression` @1028:44 (`CHECK_THAT`) | `io_decl:a_expression` |
| MiniAmiq | `all_succeeded` @1076:55 (`CHECK_ALL_SVA_PASSED`) | `bit_var:all_succeeded` |

The three MiniAmiq extras are svunit's `svaunit_vpi_wrapper` checks — the same
law, a class handle, a formal and a `bit` local, all read from inside an
immediate assertion's condition in an in-body class method.

---

## 7. THE NEXT HEAD (R0) — AND WHY SimpleUVM STILL READS 29

**The `compiled_regex` head is CLEARED.** SimpleUVM's head is now a
**different object**, and it is an **ONLY-OURS** one — the mirror arm of the
singular `SafeCompare`:

```
LHS: <null>
RHS: io_decl: (action) @347:51-347:57
     |vpiParent: \_function: (uvm_pkg::uvm_report_handler::format_action) @347:3
     |vpiDirection:1  |vpiTypespec -> int_typespec (uvm_action) @272:9
```

**R0a — SimpleUVM default and testflags, 29 cmp lines, 1 head each.** The
reference is `uvm_report_handler.svh:350`, inside the in-body static method
`format_action`:

```systemverilog
  static function string format_action(uvm_action action);      // :347
    string s;
    if(uvm_action_type'(action) == UVM_NO_ACTION) begin          // :350  <- THE HEAD
```

`ref_obj(action)@350:25` carries `vpiActual -> io_decl(action)` in OURS and
`<null>` in GOLDEN — an **AWAY** cell. It is **PRE-EXISTING and was merely
UNMASKED**: in the PRISTINE database the very same `ref_obj` (#87509) already
carries the very same `io_decl` (#87499), and the pristine and patched
databases are identical on that edge. It could not be seen while the
`compiled_regex` difference came first in the walk (RESUME.md §9: masks
cascade). The next pass owns it: golden leaves a FORMAL bare when the `if`
CONDITION reads it through a **CAST** (`uvm_action_type'(action)`), while arm
B's plain `if (formal == …)` cell is golden-BOUND — the discriminator is the
cast operation, whose own `VpiParent` is not yet set when Surelog compiles its
operand. The seven other `action` references in the same function (`:355-361`,
all one control body deeper inside the `else begin`) are `<null>` on BOTH
sides and must stay so.

**R1 — the `case … inside` item multiplicity** (arm D, elab view): golden holds
TWO copies of the item reference under the synthesized `inside` operation and
we hold one. Pre-existing, unchanged, 0 corpus cells.

**R2 — two elab parenting residues on a `case_item`'s constant-valued
expressions** (arm D: an enum constant and a package parameter we leave under
the `case_item` where golden re-parents them to the enclosing scope).
Pre-existing, unchanged, 0 corpus cells.

**R3 — the pointer-valued constant on an ASSOCIATIVE-ARRAY typedef's right
range** (`typedef C22 ka_cls_t[string];`). Its `UINT` is an address that tracks
the binary's own size, so ANY patch that changes the binary size by a page
moves it in `r10buvm22repro/g22.sv` and `r10uvm154repro/l154_noenum.sv`.
Refuted here as a build-layout artifact (§8); worth closing on its own, since
it makes those two arms unusable as boundary evidence for every future pass.

**R4 — an OBSERVATION for the master, not a residue of this pass.**
`Earlgrey_0_1/testflags` reads **26594 cmp lines / 1 head** at BASE `fe4a739`,
with BOTH binaries, head log BYTE-IDENTICAL. r10uvm160's README records **36**
at ITS base `6b24843`, and `6b24843 → fe4a739` is `400a941d` (Earlgrey pass 99)
followed by this pass's base commit. The row's STATUS never moved
(`CMP_NOTEQUAL` in both sweeps, `ct8rows` PASS), so this is a HEAD-DEPTH change,
not a regression in the judge's verdict: the head object at `fe4a739` is a whole
elaborated `module_inst` (`work@top_earlgrey.u_hmac.u_sha2.u_pad`) and a cmp
line count is that object's decompile SIZE. Worth a look by whoever owns the
Earlgrey family; nothing in this pass touches it.
(`head_pris_Earlgrey_0_1.testflags.cmp` and its `head_pat_` twin are TRUNCATED
to 120 lines here — the full logs are 1.2 MB and byte-identical, md5
`2d9be700973ce3429f41e58f18f2574e` for both.)

**R5 — the EVENT CONTROL expression** is the sixth `condBindDepth5` site and
is left to § `evCtrlBindPos108`. Arm D measures that column agreeing cell for
cell with golden today, so there is nothing to close; it is recorded here so
the next reader does not have to re-derive it.

---

## 8. THE WIDE BOUNDARY — 4590 ARMS, BOTH VIEWS

`bound161.sh` compiles EVERY `.sv`/`.v` in a COPY of `tools/probe` — top level
AND subdirectories — with both binaries in both views and compares the
DATABASE BYTES. Every child gets `</dev/null`, the file list is read on fd 3,
scratch is keyed on the RELATIVE path, and `PROCESSED` is asserted against
`LISTED`.

```
LISTED=4590  PROCESSED=4590  PRODUCED_DBS=4438  MOVED_ARMS=10  RC_DIFFS=0
```

* **4 arms** are this pass's own `g161_*.sv` — the POSITIVE CONTROL. A gate
  reporting zero movers over its own law's arms cannot see.
* **4 arms carry 5 TOWARD cells**, each measured against a Surelog golden built
  for that arm: `r10buvm7repro/v7v_E_ctx.sv` (`assert (i == 0)`, local `int i`,
  golden `int_var`), `r10uvm64repro/v2_ctx.sv` (TWO cells — an assertion
  condition and a case ITEM expression, both reading a block local declared at
  the same control depth, §64's carve-out, golden `int_var` on both),
  `r10v121repro/v121_f.sv` (a formal in an in-body class TASK, golden
  `io_decl`), `r10v133repro/v133_h_more.sv` (a local, golden `int_var`).
* **2 arms are REFUTED** as a build-layout artifact — R3 above. A THIRD binary
  built from the **UNPATCHED `fe4a739` source** with 8 KB of padding added to
  `StmtEmit.cpp` (md5 `913785dcd0e55bc176eb98d748199014`, 22379384 bytes) moves
  the same three constants to a THIRD value and moves NOTHING else in either
  whole dump. An unpatched tree reproduces the arm, so the law does not reach
  it. `BOUNDARY.r10uvm161.txt` carries the three values and the three binary
  sizes side by side.

---

## 9. THE GATES

All green, on this pass's own pinned build and its own workdirs — the full
table is `GATES.r10uvm161.txt`. In one line: goldens **23/0** with the patched
binary and **0/23** with `/bin/false`; uhdm2rtlil **679/50/2** in both modes
with `ct8rows` **PASS** against the committed baseline AND against this pass's
own pristine sweep; surelog status histograms **identical** to the pristine
sweep with `ct8rows` **PASS** (**no row converted**, `results/*.csv` READ
ONLY); byte movers **7/956** and **0/1358**, all seven predicted by name, with
the comparator's negative control flagging **955/956** and **1357/1358**; every
`cmds.txt` audited BY BINARY PATH (1523 + 1458 per binary); canaries
**ok=52 changed=0** and **ok=8 changed=0**, `ctcan2` **PASS** on both corpora,
`canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0**; the five protected
databases byte-identical with `SVSwitch 4842211c4030` and
`YosysVerx 6ccda350c24a` matching their pins exactly.

---

## 10. FILE MAP

| file | what it is |
|---|---|
| `ct161own.cpp` | THE OWNER-FINDER. Parent-chain probe + generic `VpiParent` child descent + **the reference scan** (`GetByVpiType` over every edge of every object) that decided the head. |
| `ct161cen.cpp` | THE CENSUS. `REF` (every reference and its `vpiActual`), `VAR` (every listing entry with `vpiAutomatic`), `CNT` (every scope's listing COUNT, empty scopes included). |
| `ct161pred.cpp` | THE A-PRIORI PREDICTOR. Names every movable cell from a PRISTINE database; calibrated 19/19, 6/6, 11/11, 3/3 on this pass's own arms. |
| `ct161list.cpp` | A NAME QUERY over a database — kind, span, parent chain, listing, `vpiAutomatic`, `ref_obj::Actual_group`. |
| `score161.py` | The cell scorer (`--only REF|VAR|CNT`, `--nospan`). |
| `grid161.sh` | Builds one arm's six databases (golden + two binaries × two views) and censuses them. |
| `predsweep161.sh` | Runs the predictor over a whole `verify_golden` workdir. |
| `bound161.sh` | The wide boundary gate. |
| `g161_a_win.sv` | ARM A — the population and its controls. |
| `g161_b_notmove.sv` | ARM B — eighteen referent kinds, `if` column vs assertion column. |
| `g161_c_sites.sv` | ARM C — the other window sites and the block shapes. |
| `g161_d_item.sv` | ARM D — the case-item and event-control columns. |
| `GRID.r10uvm161.txt` | The four arms scored three ways. |
| `CENSUS.r10uvm161.txt` | The seven moved corpus databases, cell for cell, against golden. |
| `PREDICT.r10uvm161.txt` | The a-priori prediction over 956 + 1358 pristine databases. |
| `BOUNDARY.r10uvm161.txt` | 4590 arms; every mover attributed or refuted. |
| `GATES.r10uvm161.txt` | Every gate with its number. |
| `head_pris_*.cmp` / `head_pat_*.cmp` | The seven row families' heads, before and after. |
| `rowheads.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`, `byteverify.sh` | The shared gate scripts, carried so this directory runs on its own. |
