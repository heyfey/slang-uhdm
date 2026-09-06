# r10uvm179 — § `recvCallArgRefVarLocalNeverBinds179` — **A `ref_var` SUBROUTINE LOCAL PASSED TO A CALL ON A HIERARCHICAL RECEIVER IN EXPRESSION POSITION BINDS NOTHING IN THE DEF-PACKAGE LISTING** — the SimpleUVM ×2 29-line head CLEARED

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted**
and **NO CORPUS ROW CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `cf42ecc3` |
| pristine binary | md5 `3eb10767c383f6ca2086f359842a4e98`, built from this pass's OWN worktree at a clean `cf42ecc3` and frozen `chmod 555` before any sweep — its own 956-row surelog sweep reproduced `results/golden_surelog.csv` **row for row** |
| patched binary | md5 `9af644fd7023a6661a2976fbd0c0033a`, frozen `chmod 555`.  The patch applied to a **FRESH `cf42ecc3` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on |
| production surface | `src/ExprEmit.cpp` — **TWO code lines** (one gated assignment) inside `refVarLocalNoBind5`, plus the decode; `include/UhdmExporter.h` — comments only.  Nothing else. |
| probe surface | `tools/probe/r10uvm179repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SimpleUVM default and testflags, 29 cmp lines, ONE head each — CLEARED.**  The head OBJECT changed (an over-bound `ref_obj::Actual_group` → the whole `module_inst work@top`, whose failing field is `task_call(run_test)::Task`, §10), so the line count is now that object's decompile size, 664681. |
| every other row's head | cmp log unchanged — SeqDriver ×2 **33**, Scoreboard/default **95**, MiniAmiq ×2 **33**, BuildUVMPkg ×2 **52**, Earlgrey_0_1 **31 / 48**, Rggen/default **0**. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against the committed baselines AND this pass's own pristine sweeps.  Status histograms byte-identical. |
| byte movers | **9 / 956** surelog, **ALL NINE PREDICTED BY NAME before the patched sweep ran**; **0 / 1358** uhdm2rtlil, also predicted (that corpus holds no cell of this face at all). |
| what each mover is | the SAME four dump lines in all nine: two removed `vpiActual` edges, `uvm_sequencer::item_done::t` and `uvm_sequencer_param_base::send_request::param_t`.  Scoreboard/default's ORDER-BLIND diff is those four lines and nothing else, so the COIN did not flip. |
| the whole-corpus face (956 databases, both sides) | golden face keys 10314; **FACEDIFF 78 → 60**; MOVED 18, **TOGOLD 18, AWAY 0, MOVED-WRONG 0**.  uhdm2rtlil: **0 face rows in 1358 databases**. |
| the census (nine UVM row-modes, EVERY family, 1 352 945 rows per binary) | ARG disagreeing 14499 → **14481**; REF (every reference in the database) 48679 → **48661**; **OBJ MOVED 0 lines** — nothing created, destroyed or re-typed.  **TOGOLD 18, AWAY 0, MOVED-WRONG 0** in both moving families. |
| the grids (4 arms × 2 views, one Surelog golden each) | DEF **TOGOLD 11, AWAY 0, MOVED-WRONG 0**; ELAB **TOGOLD 11, AWAY 0, MOVED-WRONG 0**. |
| the WIDE boundary (4909 sources × 2 views) | `LISTED=4909 FENCED_SKIPPED=0 PROCESSED=4909 MOVED=30 ASYMMETRIC_OUTPUT=0 PROCESSED-ASSERT-OK`.  8 are this pass's own arms; the other 22 belong to the two passes whose law this one extends, and **two of their arm-views went CMP_EQUAL** (`r10buvm5 a1_refvarbind`, `r10v107 v107_b12`: 29 cmp lines → **0**). |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `cf42ecc3` worktree; its
956-row surelog sweep reproduced the committed baseline **row for row**
(`ct8rows` PASS, 0 differing rows, status AND dump).  `rowheads.sh` on that
sweep:

```
SimpleUVM      default         29      1     cmp rc=255
SimpleUVM      testflags       29      1     cmp rc=255
```

which is the brief's number to the byte.  The pristine cmp log
(`head_pris_SimpleUVM.default.cmp`) is

```
LHS: <null>
RHS:
decompile:
ref_var: (uvm_pkg::uvm_sequencer_param_base::send_request::param_t), id:147021, line:270:7, endln:270:14
…
```

`BaseClass.h`'s **SINGULAR** `SafeCompare` prints `LHS: <null>` with a full RHS
when OURS holds a value and golden's is null (RESUME.md §9) — so **we BIND an
edge golden leaves BARE**, and the direction of the fix is SUPPRESS.

### THE OCCURRENCE MAP AND THE ONE EXTRA BINDING

Because the head is the MIRROR shape (`LHS: <null>`), `ct179own` was given a
**MIRROR REFERENCE SCAN** — every edge of OURS that lands on the head, printed
beside the same edge of golden's counterpart.  That is the whole decode, with no
walk (`OWNER.r10uvm179.txt`):

```
HEAD LHS = <null>
HEAD RHS = ref_var(param_t)@270:7-270:14#147021
MIRROR REFERENCE SCAN:
  ours   begin()@272:3-274:6                      edge 100 (vector index 0)
      golden begin()@272:3-274:6      -> vector size 1, [0] = ref_var(param_t)@270:7   AGREES
  ours   function(uvm_sequencer_param_base::send_request)@267:1  edge 100 (vector index 0)
      golden function(…)@267:1        -> vector size 1, [0] = ref_var(param_t)@270:7   AGREES
  ours   ref_obj(param_t)@281:13-281:20            edge 700 (singular)
      golden ref_obj(param_t)@281:13  -> singular  ref_var(param_t)@270:7               AGREES
  ours   ref_obj(param_t)@297:26-297:33            edge 700 (singular)
      golden ref_obj(param_t)@297:26  -> singular  <null>                <-- THE EDGE
  ours   ref_typespec()@0:0                        edge 81 (singular)
      golden ref_typespec()@0:0       -> singular  ref_var(param_t)@270:7               AGREES
```

**FIVE edges land on the object; FOUR agree; ONE is an extra binding.**  Both
`Variables()` vectors are size 1 on both sides, the `$cast(param_t, t)` argument
at 281:13 is bound on both sides, and the `ref_typespec` back-edge agrees.  The
head is `ref_obj::Actual_group` at `uvm_sequencer_param_base.svh:297:26`, and it
is one field wide.

**THIS CONFIRMS r10v177's R0 CORRECTION AND REFUTES r10uvm177's OWN R0** a
second, independent way.  r10uvm177 directed the next pass to stop listing the
`param_t` object at all; the occurrence map shows both `vpiVariables` vectors
already agree, so deleting the entry would have moved two agreeing cells AWAY
from golden.  The verifier's committed `R0.r10v177.txt` was right.

The site, `uvm-1.2/src/seq/uvm_sequencer_param_base.svh:267-298`:

```systemverilog
function void uvm_sequencer_param_base::send_request(uvm_sequence_base sequence_ptr,   // 267
                                                     uvm_sequence_item t,
                                                     bit rerandomize = 0);
  REQ param_t;                                                                          // 270
  …
  if (m_req_fifo.try_put(param_t) != 1) begin                                           // 297
```

and its sibling, `uvm_sequencer.svh:284`, `if (m_req_fifo.try_get(t) == 0)`.

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, AND GOLDEN MEASURED BEFORE THE WINDOW WAS WRITTEN

The rule is **TWO-STAGE**, and neither stage alone explains the corpus.

### (1) COMPILE TIME — on this road the bind ALWAYS fails

`CompileHelper::compileComplexFuncCall`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:5039`) is what
`compileExpression` reaches for a call in EXPRESSION position.  Its hierarchical
arm builds a `hier_path` over the receiver steps and a `method_func_call` for the
final name, and the ORDER of three statements is the whole story
(`:5678-5708`):

```cpp
fcall = s.MakeMethod_func_call();
fcall->VpiName(methodName);
fC->populateCoreMembers(dotedName, dotedName, fcall);
if (VectorOfany *arguments = compileTfCallArguments(
        component, fC, List_of_arguments, compileDesign, reduce,
        fcall, instance, muteErrors)) {          // :5682  pexpr == fcall
  fcall->Tf_call_args(arguments);
}
elems->push_back(fcall);
…
if (fcall != nullptr) fcall->VpiParent(path);    // :5689  PARENTED ONLY NOW
…
path->VpiParent(pexpr);                          // :5708
```

`compileExpression`'s name arm (`CompileExpression.cpp:2982-3000`) then runs
`bindVariable(component, pexpr, name, …)`, and
`CompileHelper::bindVariable` (`CompileStmt.cpp:3089-3151`) has arms only for
`uhdmfunction`, `uhdmtask`, `uhdmbegin` and `uhdmmodule_inst`; for anything else
it recurses on `scope->VpiParent()` — still **null** — and returns at `:3092`.
**Nothing on this road is eagerly bound**; every argument goes to
`component->needLateBinding(ref)`.

The STATEMENT road does not share the defect: `compileTfCall`'s dotted arm sets
`fcall->VpiParent(pexpr)` at `CompileHelper.cpp:4231`, **before**
`compileTfCallArguments` at `:4329` — which is why r10uvm176's face BINDS — and
so does `compileComplexFuncCall`'s `this.`/handle arm (`:5176` before `:5180`).

### (2) WRITE TIME — the late binder binds most of them and skips exactly one kind

`UhdmWriter::lateBinding` (`src/DesignCompile/UhdmWriter.cpp:3294`) walks the
REFERENCE's parent chain, which is complete by then, and binds what it finds —
**but every arm carries the same guard**:

```cpp
if (decl->UhdmType() == uhdmref_var) continue;     // :3387 :3397 :3442 :3452 :3556 …
```

so a `ref_var` DECLARATION can never answer.  The walk falls through to the
module-level mint at `:3982-4004` (a `logic_net` named after the reference), and
that mint is **guarded on the scope being a module/interface/program**:

```cpp
if (m && (m->UhdmType() == uhdmmodule_inst || … uhdminterface_inst || … uhdmprogram)) {
  logic_net* net = s.MakeLogic_net(); … ref->Actual_group(net);
}
```

`lateBinding(s, pack, p)` is called for a PACKAGE at `:1304`, where that guard is
false — **so in the package's own listing the reference is left BARE**.  (For a
class definition the call is commented out entirely, `:1067`; the class-body copy
gets its wire because the importing module inherits the package's unbound list,
which is § `oobRefVarLocalHoistNet107`'s decode.)

### THE COROLLARY, AND THE MEASUREMENT THAT SAVED THE LAW

"Nothing binds on this road" would be **FALSE**, and a window written on it would
have been a disaster.  Over SimpleUVM/default's **1076** face cells (every
argument of a `method_func_call` that is an element of a `hier_path`), **golden
BINDS 512**:

| golden's actual | cells |
|---|---|
| `io_decl` (a FORMAL) | 294 |
| `logic_net` (the mint) | 54 |
| `int_var` | 46 |
| `string_var` | 46 |
| `class_var` | 30 |
| `enum_const` | 18 |
| `array_var` | 14 |
| `bit_var` / `struct_var` / `enum_var` | 4 / 4 / 2 |

Span-blind, the **whole 1076-cell face agrees with ours except TWO cells** —
`try_get`'s `t` and `try_put`'s `param_t`, both under `HOME=…/package:uvm_pkg`,
golden BARE and ours `BOUND=ref_var`.  That is § `refVarLocalWindowBinds5`'s own
**RESIDUE R1**, written at the predicate's declaration in
`include/UhdmExporter.h` with these two corpus cells named
(`uvm_pkg 54020, 54474`).  This pass closes it.

### THE RECEIVER AXIS IS LIVE, AND GOLDEN MAKES NO DISTINCTION ON IT

Arm B (`g179_b_recv.sv`) reads every receiver shape off ONE golden, DEF view,
all in the FACE position with the same `ref_var` argument:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| `b01` | `s.ask(v)` — one class PROPERTY (**the corpus shape**) | **BARE** | BOUND `ref_var` | **BARE** |
| `b02` | a body-LOCAL handle, `loc.ask(v)` | **BARE** | BOUND `ref_var` | **BARE** |
| `b04` | an `a.b` CHAIN, `mid.leaf.ask(v)` | **BARE** | BOUND `ref_var` | BOUND — residue R2 |
| `b05` | an INDEXED receiver, `bank[1].ask(v)` | **BARE** | BOUND `ref_var` | BOUND — residue R2 |
| `b06` | `this.s.ask(v)` | agreed | agreed | agreed |
| `b07` | NO receiver | agreed | agreed | agreed |
| `b11`/`b14`/`b15` | the STATEMENT twins of b01/b04/b05 | BOUND | BOUND | BOUND |
| `b20`/`b21` | a VIRTUAL-INTERFACE receiver — r10uvm176's own face | agreed | agreed | **unmoved** |

**Golden treats every hierarchical receiver alike**: the law is the ROAD, not the
receiver's arity.  Our emitter raises the counter this window reads at ONE of the
four `MakeHier_path` arms inside the Call case, so `b04`/`b05` are left as a
named residue rather than fixed by a term no measurement of this pass's own
corpus population demanded (§11 R2).

---

## 3. THE BUG IN OUR EMITTER, IN ONE SENTENCE

`refVarLocalNoBind5` (`src/ExprEmit.cpp:651`) opens § 5's binding window on
`classArgBindDepth12 > 0 || condBindDepth5 > 0`, and at
`uvm_sequencer_param_base.svh:297` **both halves are satisfied for the wrong
reason**: the call sits in an `if` CONDITION (so `condBindDepth5` is up) and the
local is declared in the subroutine's own declaration section read at
`ctrlBodyDepth28 == 0` (so the depth matches).  The window then binds a reference
that Surelog could never have bound.

**THE PATCH IS TWO CODE LINES**, in that predicate:

```cpp
    if (recvUserMethodArgDepth107 > 0 && pkgDefViewBody9)
        window = false;
```

It reads **THE COUNTER § `oobRefVarLocalHoistNet107` ALREADY RAISES** at exactly
the arm Surelog's road corresponds to (`src/ExprEmit.cpp:21495`, the one-name
class-receiver call in EXPRESSION position) — not a new counter — so the two
readers of that counter are the two halves of one Surelog behaviour and cannot
drift apart: `§ 107` says where the reference goes when a module hoists the body
(the minted wire), this law says it goes nowhere when none does.
DIRECTION: **SUPPRESS** a `vpiActual` that was present; never reshape, never
delete an object (the nine-row OBJ census moves 0 lines).

---

## 4. THE `pkgDefViewBody9` CONJUNCT — WHAT IT NAMES, AND THAT IT IS INERT

`pkgDefViewBody9` is true while the package's UN-ELABORATED listing is being
emitted, the class-method clones `emitPackageClassMethodClones` appends
included.  That is the listing golden leaves bare, and in an `--elabuhdm` run it
is only HALF of what golden writes — arm A `f_cond`, ELAB view, package home:

```
golden    BARE                       and    BOUND=ref_var:v
pristine  BOUND=ref_var:v            and    BOUND=ref_var:v
patched   BARE                       and    BOUND=ref_var:v      <- golden's multiset, exactly
```

**A HOME-BLIND INTERMEDIATE WAS BUILT AND MEASURED** (md5
`f515307642e289633b96e449a18113c4`, kept only as evidence, never gated and never
shipped).  On arm A in both views and on MiniAmiq/default it produces a
**byte-identical database**: the elaborated package copy and the import clones
are produced by CLONING an already-bound object rather than by re-emitting the
expression, so this predicate is never called for them and **the conjunct is
INERT on every cell this pass could measure**.  It is kept for exactness with the
listing the decode names — the same standing r10uvm176 §4 gave its `':'`
conjunct, which likewise had no golden cell of its own — and it is reported as
inert rather than dressed up as load-bearing.

The import clones are the cells that made this worth checking.  MiniAmiq's
golden holds the same source line THREE times and answers differently in each:

```
HOME=function:item_done/class_defn:uvm_sequencer            golden BARE      ours BARE
HOME=function:uvm_sequencer::item_done/package:svaunit_pkg  golden BOUND ×2  ours BOUND ×2   <- import clone
HOME=function:uvm_sequencer::item_done/package:uvm_pkg      golden BARE      ours BOUND      <- THE MOVER
```

and the patched binary moves the third and leaves the first two exactly as they
were.

---

## 5. THE POSITION, ARGUMENT-KIND, DEPTH AND HOME GRIDS

Arm A (`g179_a_face.sv`), ONE golden, DEF view; `*` marks a cell this law moves:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| `a01` * | `if (s.ask(v) == 0)` — **THE FACE** | BARE | BOUND `ref_var` | **BARE** |
| `a04` * | `case (s.ask(v))` | BARE | BOUND `ref_var` | **BARE** |
| `a05` * | `assert (s.ask(v) == 0)` | BARE | BOUND `ref_var` | **BARE** |
| `a02` | `s.take(v);` STATEMENT position | BOUND `ref_var` | BOUND | BOUND |
| `a03` | `w = s.ask(v);` assignment RHS | BARE | BARE | BARE |
| `a06` | `while (s.ask(v) == 99)` | BARE | BARE | BARE |
| `a07` | `w = s.ask(v) + 1;` an OPERAND | BARE | BARE | BARE |
| `a10` | `if (free179(v) == 0)` RECEIVER-LESS | BOUND `ref_var` | BOUND | BOUND |
| `a12` | `if ($cast(v, plain))` | BOUND `ref_var` | BOUND | BOUND |
| `a14` | `free179v(v);` receiver-less STATEMENT | BOUND `ref_var` | BOUND | BOUND |
| `a15` | `qv.push_back(v);` BUILT-IN, STATEMENT | BOUND `ref_var` | BOUND | BOUND |
| `a16` | `if (amap.exists(v))` BUILT-IN, CONDITION | BARE | BOUND `ref_var` | BOUND — residue R1 |
| `a20`/`a21` | the same two positions with a RESOLVABLE local type | BOUND `class_var` | BOUND | BOUND |
| `ib_cond` | the IN-BODY twin of the face | BARE | BARE | BARE (§ 52 owns it) |

`a06` is the discriminator that proves the window and not "any condition" is the
mechanism: a `while` condition raises no `condBindDepth5`, golden is bare, and we
were bare before and after.  `a02` vs `a01` is the STATEMENT/EXPRESSION split the
Surelog decode predicts, read off one golden.

Arm C (`g179_c_arg.sv`), argument kinds × control-body depths:

| cell | argument | depth | golden | patched |
|---|---|---|---|---|
| `c00` * | the `ref_var` local | 0 | BARE | **BARE** |
| `c01`/`c02` | the same local | 1 / 2 | BARE | BARE (§ 5's depth gate already) |
| `c10`/`c11` | a FORMAL (`io_decl`) | 0 / 1 | agreed | unmoved |
| `c20` | a class PROPERTY | 0 | agreed | unmoved |
| `c30` | a LITERAL | 0 | agreed | unmoved |
| `c40`/`c41` | a RESOLVED local (not a `ref_var`) | 0 / 1 | agreed | unmoved |
| `c60` * | inside a NESTED call, `s.askn(s.ask(v))` | 0 | BARE | **BARE** |
| `c70` * | one of TWO arguments, `s.ask2(v, iprop)` | 0 | BARE | **BARE** |
| `c80` * | declared IN the block that raised the depth | 1==1 | BARE | **BARE** |

Arm C's DEF **and** ELAB both reach **DIFF 0** — every cell in the arm agrees
with golden after the law.

Arm D (`g179_d_home.sv`), the homes:

| cell | home | golden | patched |
|---|---|---|---|
| `d01` | IN-BODY method of a package class | BARE | BARE (§ `classInBodyRecvCallArgNoBind52`) |
| `d02` * | OUT-OF-BODY FUNCTION of a package class — **the corpus home** | BARE | **BARE** |
| `d03` * | OUT-OF-BODY TASK of a package class | BARE | **BARE** |
| `d04` | a PACKAGE FREE FUNCTION (resolvable local) | agreed | unmoved |
| `d05` | a `$unit` class's out-of-body method | BARE | BOUND — residue R3 |
| `d06` | an INTERFACE's own function | pre-existing, mirror direction | unmoved |
| `d07` | **a MODULE FUNCTION — THE CONTROL** | agreed | **unmoved** |
| `d08` | a MODULE PROCESS | agreed | **unmoved** |

The module cells cannot move and the arm says why: `refVarLocalNoBind5` fires
only when the emitted DECLARATION is a `ref_var`, and a module function's local
is resolved.  A HOME conjunct would therefore have been an unmeasured predicate,
and § 5 is deliberately home-blind ("a `ref_var` local in EVERY method —
out-of-body definitions included, which is where the whole corpus population
lives").

**Grid totals, both views, every family: TOGOLD 11, AWAY 0, MOVED-WRONG 0.**
Arm D's DEF head moved from this law's cell to a pre-existing `$unit`-class
parenting difference (29 → 406 cmp lines, a bigger OBJECT), and arm C's DEF head
shrank 29 → 22.

---

## 6. THE CENSUSES

**Whole-corpus FACE** (`wface179.sh` / `cen179.sh --face`, `WFACE.r10uvm179.txt`)
— every argument of a call that is an ELEMENT OF A `hier_path`, over ALL 956
comparable surelog databases and ALL 1358 uhdm2rtlil databases, BOTH SIDES:

```
surelog : golden face keys 10314   FACEDIFF 78 -> 60
          MOVED=18  TOGOLD=18  AWAY=0  MOVEDWRONG=0
          golden rows IDENTICAL across the pristine and patched runs
u2r     : 0 face rows in 1358 databases  -> the corpus cannot move, and did not
```

**Nine UVM row-modes, EVERY family** (`cen179.sh`, `CENSUS.r10uvm179.txt`) —
1 352 945 rows per binary:

```
ARG  keys golden=114044 ours=114199 | disagreeing 14499 -> 14481 | MOVED=18 TOGOLD=18 AWAY=0 MOVEDWRONG=0
REF  keys golden=461077 ours=458295 | disagreeing 48679 -> 48661 | MOVED=18 TOGOLD=18 AWAY=0 MOVEDWRONG=0
OBJ  keys golden=812    ours=810    | disagreeing   329 ->   329 | MOVED=0
```

**OBJ MOVED = 0** is the statement that nothing was created, destroyed or
re-typed.  The 18 movers are named in full in `CENSUS.r10uvm179.txt`: two cells
× nine row-modes.

**The prediction** (`PREDICT.r10uvm179.txt`, `predict179.sh`) was made from the
pristine databases alone, BEFORE the patched sweep ran, and named the nine
databases and the two callees.  It also named what would NOT move: the 16
`exists` cells (a BUILT-IN method, a different emitter arm) and the 96
`m_find_*` cells, whose `vpiActual` comes from § `hierCallArgTakesBase39`'s
design-final back-patch and agrees with golden on both binaries.  None of them
moved.

---

## 7. THE GATES (`GATES.r10uvm179.txt`)

* build both, `-j 2` only, md5s taken separately and recorded.
* 23 golden dump tests: pristine **23/0**, patched **23/0**,
  `SLANG_UHDM=/bin/false` **0/23** (the negative control).  `SLANG_UHDM` exported
  EXPLICITLY to each binary.
* uhdm2rtlil, testflags: `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2`;
  `ct8rows` **PASS** against `results/gate_uhdm2rtlil.csv` and against this
  pass's own pristine sweep, testflags **and** default.
* surelog, `--mode both`: `ct8rows` **PASS** against `results/golden_surelog.csv`
  and against this pass's own pristine sweep — **0 differing rows over 1588**,
  status AND dump column.  **NO ROW CONVERTED.**  The two status histograms are
  identical in every bucket, `SLANG_REJECT 567` included, which is also the check
  that no rc=139 segfault was introduced.
* byte movers: 9/956 and 0/1358, every one predicted BY NAME and attributed
  line-by-line by an order-blind path-normalised dump diff (§ READ THIS FIRST).
* canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r); `ctcan2` PASS
  ×2; `canaudit` `audited=29 UNCOVERED=0 FENCE-BREACH=0` PASS; the protected
  databases byte-identical by name, with `SVSwitch 4842211c4030` and
  `YosysVerx 6ccda350c24a` on the pin.
* every sweep and every arm ran a FROZEN binary at an immutable path and every
  `cmds.txt` was audited BY BINARY PATH: **0** of 1573+1462 name the main-tree
  binary.
* every arm command's `rc` is recorded in its own `cmds.txt`; **all 24 grid
  commands are rc=0**.

---

## 8. THE BOUNDARY AND THE FLOOR (`ARMS.r10uvm179.txt`)

```
LISTED=4909 FENCED_SKIPPED=0 PROCESSED=4909 MOVED=30 NO_OUTPUT_PAIRS=380
PROCESSED-ASSERT-OK          ASYMMETRIC_OUTPUT=0
```

Every SEGFAULT line in the log is PAIRED (`$PRI` and `$PAT`, same arm, same
view): pre-existing, not introduced, which is exactly what `ASYMMETRIC_OUTPUT=0`
reports.

Of the 30 moved arm-views, **8 are this pass's own** `g179_*` arms — the positive
control that proves the gate can see.  The other **22 belong to the two passes
whose law this one extends**: r10buvm5 (`a1_refvarbind`) and r10uvm107 / r10v107
(`g107_a1`, `v107_b1 b3 b4 b5 b7 b8 b9 b10 b12`).  **Not one arm of r10uvm176,
r10uvm177, r10uvm175, r10uvm172, r10uvm171, r10uvm170, r10uvm165, r10uvm164,
r10uvm161, r10uvm124, r10uvm89, r10uvm77-79, r10uvm82-91, r10buvm3-4/6-15 or
r10sd8-12 moved** — the must-stay floor the brief names is intact, and the
r10uvm176 vif cells are in this pass's own arm B (`b20`/`b21`) as well, unmoved.

All eleven moved files were rebuilt against a FRESH Surelog golden and scored,
DEF and ELAB, every family:

| arm | cmp DEF pristine → patched | ARG/REF verdict |
|---|---|---|
| `a1_refvarbind` (r10buvm5) | 29 → **0 (CMP_EQUAL)** | TOGOLD 1, AWAY 0, MW 0 |
| `v107_b12` | 29 → **0 (CMP_EQUAL)** | TOGOLD 1, AWAY 0, MW 0 |
| `g107_a1` | 29 → 3542 (new, bigger head object) | TOGOLD 2, AWAY 0, MW 0 |
| `v107_b1` | 29 → 3170 | ARG TOGOLD 3, REF TOGOLD 6, AWAY 0, MW 0 |
| `v107_b3` | 29 → 449 | TOGOLD 1, AWAY 0, MW 0 |
| `v107_b4` | 29 → 510 | TOGOLD 1, AWAY 0, MW 0 |
| `v107_b5` | 29 → 29 | TOGOLD 1, AWAY 0, MW 0 |
| `v107_b7` | 29 → 1038 | TOGOLD 2, AWAY 0, MW 0 |
| `v107_b8` | 29 → 2118 | TOGOLD 3, AWAY 0, MW 0 |
| `v107_b9` | 29 → 33 | TOGOLD 9, AWAY 0, **MW 1** |
| `v107_b10` | 29 → 33 | TOGOLD 8, AWAY 0, **MW 2** |

**THE THREE MOVED-WRONG CELLS ARE REPORTED, NOT HIDDEN.**  They are
`v107_b9 pm_pkg9` and `v107_b10 pm_pkg10 / pm_unit10` — a body local whose NAME
is also a PACKAGE (or `$unit`) PARAMETER:

```
GOLDEN    BOUND=constant: ×2        (pm_unit10: BOUND=parameter:pm_unit10 ×2)
pristine  BOUND=logic_net  +  BOUND=ref_var
patched   BOUND=logic_net  +  BARE
```

Golden binds the PARAMETER, because `UhdmWriter::lateBinding`'s function/task arm
searches `Io_decls → Variables → Parameters → Instance()'s Variables` with NO
early exit, so the package listing is the LAST WRITER
(§ `tfItemLocalLosesToPkgVar148` / § `pkgSubRefBindsPkgVarOverFormal81`).
**Neither binary does**: the cell was wrong before (an eager `ref_var` binding
that hid the question) and is wrong after (bare).  This law did not create it and
must not paper over it by keeping a second wrong answer.  It has **ZERO corpus
cells** — the 956-database face census scores AWAY 0 and MOVED-WRONG 0 — and it
is handed on as residue R4 / R0b, because it is now VISIBLE where before it was
masked.

---

## 9. R0 — THE NEXT HEAD ON THIS ROW

**SimpleUVM default and testflags, 664681 cmp lines, ONE head each.**  The count
is the head OBJECT's decompile size, not a distance: the object is now the whole
`module_inst work@top`.  `ct179own`'s PARENT-CHAIN PROBE and DESCENT
(`OWNER.next.r10uvm179.txt`) take it down to the pair that actually fails:

```
design::Compare r=1        (it was -1 before: a DIFFERENT pair fails now)
HEAD LHS = module_inst()@44:1-71:10        HEAD RHS = <null>
DESCENT
  [0] module_inst()@44:1-71:10             vs module_inst()@44:1-71:10
  [1] initial()@50:3-57:6                  vs initial()@50:3-57:6
  [2] begin()@50:11-57:6                   vs begin()@50:11-57:6
  [3] task_call(run_test)@56:5-56:15       vs task_call(run_test)@56:5-56:15
  STOP: the edge is a FIELD of the pair above
OWNER PAIR   task_call(run_test)@56:5
    tf_call::Tf_call_args   LHS=null                       RHS=null
    task_call::Task         LHS=task(run_test)@38:1-44:8   RHS=task(run_test)@38:1-44:8
```

so the next head is **inside `uvm_pkg::run_test`** (`uvm-1.2/src/base/uvm_globals.svh:38-44`),
reached from `testbench.sv:56`'s `run_test("hello_world_test");`.  The two
`task` objects have the same face and the same span, so the difference is a field
of the task or of its body, and the instrument to name it is `ct179own` run with
the DESCENT started at that pair (or `ctladder` masked on it).
Direction: unknown until that field is read — decode before deciding.

**R0b — the shadowed-parameter cell** (§8's three arm cells, residue R4): in the
def-package listing, a now-bare reference whose name is also a package or `$unit`
PARAMETER should take § `tfItemLocalLosesToPkgVar148`'s last-writer binding to
that parameter.  It has three measured arm cells and a decoded Surelog
mechanism, and no corpus cell yet — a clean, small, fully-instrumented head.

---

## 10. RESIDUES, ranked

* **R1 — a BUILT-IN method call on the same road.**  `if (amap.exists(v))`, arm A
  `a16`: golden BARE in the package listing and a `logic_net` in the class-body
  one, exactly like the user-method cells; we bind the `ref_var` in both.  Our
  emitter reaches built-in method calls through a DIFFERENT arm
  (`builtinMethodRecv1`), which raises neither `recvUserMethodArgDepth107` nor
  § 107's net pooling, so closing it is a two-sided change and a pass of its own.
  **16 corpus cells** (`visited.exists(succ)` in `uvm_phase::sync`/`unsync`,
  MiniAmiq and SeqDriver, both modes) — all of them under an IMPORT CLONE home
  where golden agrees with us, so the corpus reach of the FIX is currently zero
  and the arm is the only witness.  Named in `PREDICT.r10uvm179.txt`.
* **R2 — a DEEP or INDEXED receiver.**  Arm B `b04` (`mid.leaf.ask(v)`) and `b05`
  (`bank[1].ask(v)`): golden BARE, we bind, before and after.  Our emitter mints
  a `hier_path` at FOUR arms under `!callStmtCtx0` and raises
  `recvUserMethodArgDepth107` at one; widening the counter widens § 107's net
  pooling with it, which is why it is a separate, measured decision.  **Zero
  corpus cells** — every corpus receiver on this road is one plain name.
* **R3 — a `$unit` class's out-of-body method.**  Arm D `d05`: golden parents the
  body at the DESIGN and leaves it bare; we parent it at the `class_defn` and
  bind.  `pkgDefViewBody9` cannot name that home because a `$unit` class has no
  package.  **Zero corpus cells.**
* **R4 — the shadowed PARAMETER**, §8 and §9's R0b.  Three arm cells, zero corpus
  cells, now visible because this law removed the binding that masked it.
* **R5 — the ELAB multiplicity**, a measurement note rather than a defect: with
  `--elabuhdm` golden's package home carries TWO copies of the reference and the
  patched binary reproduces both, but our OBJ counts still differ from golden's
  in the ELAB view for reasons that predate this law (`score179.py --set` is why
  the ELAB grids are scored as sets).

---

## 11. FILES

| file | role |
|---|---|
| `g179_a_face.sv` | arm A — THE FACE, the six other positions, and the neighbours that share the window but not the road |
| `g179_b_recv.sv` | arm B — the RECEIVER SHAPES (property / local / chain / indexed / `this.` / vif / none) and their STATEMENT twins |
| `g179_c_arg.sv` | arm C — the ARGUMENT KINDS × the CONTROL-BODY DEPTHS 0-2 |
| `g179_d_home.sv` | arm D — the HOMES, including the MODULE-FUNCTION and MODULE-PROCESS controls |
| `grid179.sh` | the arm driver — Surelog golden + both frozen binaries, both views, every rc, the official judge on each arm-view |
| `ct179cen.cpp` | the census (`Serializer::AllObjects`): ARG / REF / OBJ families; `--face` REDEFINED for this law (a call parented by a `hier_path`) and a new `HP<n>/…` RECEIVER key |
| `cen179.sh` | the census over a `verify_golden` workdir, both sides, the row folded into the key |
| `wface179.sh` | the LAW'S FACE over a whole workdir, both sides, with the mover columns |
| `predict179.sh` | the A-PRIORI mover prediction from pristine databases alone (direction INVERTED from r10uvm176's) |
| `score179.py` | the multiset join and the TOGOLD / AWAY / MOVED-WRONG columns |
| `ct179own.cpp` | the owner-finder — r10uvm176's, plus this pass's **MIRROR REFERENCE SCAN** for an `LHS: <null>` head |
| `bound179.sh` | the WIDE boundary gate |
| `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the gates |
| `GATES / GRID / CENSUS / WFACE / PREDICT / BOUNDARY / ARMS / OWNER*.txt` | the evidence |
| `head_pris_SimpleUVM.*.cmp`, `head_pat_SimpleUVM.default.cmp` | the head, before and after (the patched log is 32 MB and only its first 120 lines are kept — the count is the new object's decompile size) |
