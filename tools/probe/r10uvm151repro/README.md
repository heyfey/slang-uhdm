# r10uvm151 — § `stmtBuiltinBodyIsBareRecvCall151` — **THE STATEMENT-POSITION `method_call_body` DEGENERATE** — uvm148's R0, the SeqDriver ×2 / SimpleUVM ×2 / Scoreboard / MiniAmiq ×2 head, **CLEARED ON ALL SEVEN ROW-MODES**

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; `GOLDEN_DEFER` stayed unset; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**; the four slang-fenced tests were
never dispatched and are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `1c45a507` (= UVM pass 148) |
| pristine binary | built from this worktree at `1c45a507`, frozen `chmod 555` before any sweep; its head log reproduces the brief's head object BYTE FOR BYTE (`head_pris_default_SeqDriver.cmp` is identical to the committed `r10uvm148repro/head_pat_default_SeqDriver.cmp`) |
| production surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` ONLY — one new predicate and one new block in the STATEMENT arm of the built-in method emitter |
| probe surface | `tools/probe/r10uvm151repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SeqDriver default / testflags** | **36** cmp lines, 1 head | **60**, 1 head — a **NEW** object (§ 8, R0) |
| **SimpleUVM default / testflags** | **36**, 1 head | **36**, 1 head — a **NEW** object (same size, different object) |
| **Scoreboard default** | **36**, 1 head | **163**, 1 head — a **NEW** object |
| **MiniAmiq default / testflags** | **36**, 1 head | **106**, 1 head — a **NEW** object |
| BuildUVMPkg default / testflags | 68, 1 head | 68 — the **SAME** head object; only `id:` numbers shifted by one |
| Earlgrey_0_1 default / testflags | 29 / 50, 1 head | 29 / 50 — head logs **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this worktree's own pristine sweeps (1588 surelog row-modes + 1358 u2r × 2 modes) |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — **exactly the nine PREDICTED BY NAME** from the pristine and golden databases before the patched binary produced anything |
| the law's corpus population | 15 scoreable wrong cells in 9 databases (30 emitted objects) | **0** — `WRONG->RIGHT 15`, `RIGHT->WRONG 0`, `AWAY 0` on KIND / NAME / PFX, and every one-sided row-set count UNCHANGED |
| the grid, five arms × two views | 218 wrong call-shape cells | **0** — `RIGHT->WRONG 0`, `AWAY 0`, `ONLY-GOLDEN 0`, `ONLY-OURS 0` in every arm, every view, every column |
| wide boundary | — | 4227 files × 2 views: **MOVED 12** (this pass's own 5 arms × 2 views + `r10v99repro/v99_b7_order.sv` × 2 views, re-measured against golden and moving TOWARD it), **BREACH 0**, RC-MISMATCH 0 |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this worktree's own pristine sweep found the SAME object on
**SEVEN** row-modes, not the four the brief named — SimpleUVM ×2 and
Scoreboard/default had arrived at it since uvm148:

```systemverilog
// uvm-1.2 base/uvm_component.svh:3432-3437, inside uvm_component::m_set_cl_verb
if(this == top) begin
  fork begin
    time last_time = 0;
    if (m_time_settings.size() > 0)
      m_time_settings.sort() with ( item.offset );        // 3436  <- THE HEAD
```

36 cmp lines, ONE `^LHS:` (`head_pris_default_SeqDriver.cmp`, and identical on
SimpleUVM, Scoreboard and MiniAmiq):

```
LHS (golden)                                  RHS (ours)
func_call: (m_time_settings) @3436:9-3436:52  method_func_call: (sort) @3436:25-3436:29
|vpiParent: \_if_stmt @3435:7-3436:53         |vpiParent: \_if_stmt @3435:7-3436:53
|vpiName:m_time_settings                      |vpiName:sort
                                              |vpiPrefix: \_ref_obj (…::m_time_settings)
```

`if_stmt::Compare` reaches the object through `VpiStmt` and
`BaseClass::Compare`'s TYPE test fails first (different `UhdmType`), which is
why both sides print in full. Golden models the whole
`<queue>.sort() with (…)` **statement** as a `func_call` NAMED AFTER THE QUEUE,
spanning the entire written call INCLUDING the `with` clause, carrying no
prefix, no arguments and no `vpiWith`.

---

## 2. THE DECODED LAW

### The grammar has two roads and `compileTfCall` decodes only one

`subroutine_call` (`Surelog/grammar/SV3_1aParser.g4:3185`):

```
subroutine_call
  : ( implicit_class_handle DOT | class_scope | package_scope | dollar_keyword )?
    dollar_root_keyword? identifier ( constant_bit_select DOT identifier )*
    attribute_instance*
    ( ( OPEN_PARENS list_of_arguments CLOSE_PARENS ) | select )
    ( DOT method_call_body )?
  | randomize_call ;

method_call_body       : identifier attribute_instance*
                           ( OPEN_PARENS list_of_arguments CLOSE_PARENS )?
                       | built_in_method_call ;
built_in_method_call   : array_manipulation_call | randomize_call ;
array_manipulation_call: array_method_name attribute_instance*
                           ( OPEN_PARENS list_of_arguments CLOSE_PARENS )?
                           ( WITH OPEN_PARENS expression CLOSE_PARENS )? ;
array_method_name      : identifier | unique_call | and_call | or_call | xor_call ;
unique_call: UNIQUE;  and_call: AND;  or_call: OR;  xor_call: XOR;
```

`CompileHelper::compileTfCall` (`src/DesignCompile/CompileHelper.cpp:4218`)
decodes ONLY the first road. In its "User call" arm it takes
`fC->Sibling(tfNameNode)` and tests it for `paConstant_bit_select`; on a hit it
mints the `method_func_call(<method>) { vpiPrefix <receiver> }` we already
emit. When the sibling is a **`paSelect`** instead — the second road, the one
that ends in `DOT method_call_body` — nothing in that function matches:
`getTaskFunc(name)` misses (the name is a VARIABLE), `getLetStmt(name)` misses,
and the call falls out of the bottom at `CompileHelper.cpp:4310`:

```cpp
    if (call == nullptr) { call = s.MakeFunc_call(); call->VpiParent(pexpr); }
    if (call->VpiName().empty()) call->VpiName(name);            // the RECEIVER
    if (call->VpiLineNo() == 0)
      fC->populateCoreMembers(Tf_call_stmt, Tf_call_stmt, call); // the WHOLE node
    NodeId argListNode = fC->Sibling(tfNameNode);                // the paSelect
    if (VectorOfany* arguments = compileTfCallArguments(…))      // -> null
      call->Tf_call_args(arguments);
```

— a BARE `func_call` NAMED AFTER THE RECEIVER (`fC->SymName(dollar_or_string)`,
the base identifier: subscript and all method text discarded), spanned over the
WHOLE `Subroutine_call` node, with NO prefix, NO `vpiWith` and NO arguments.

> **§ stmtBuiltinBodyIsBareRecvCall151.**  A built-in method call written in
> STATEMENT position on a SINGLE-COMPONENT receiver becomes, in golden, a bare
> `func_call` named after that receiver's BASE identifier, spanned over the
> whole written call, with no prefix, no arguments and no `vpiWith` — exactly
> when the grammar cannot spell the call as `identifier`-dot-`identifier`,
> i.e. when a `with` clause follows (only `array_manipulation_call` and
> `randomize_call` may carry one) or when the method token is one of the four
> KEYWORD array-method names `unique` / `and` / `or` / `xor`.

### GOLDEN SAYS IT IN ONE TASK BODY, SEVENTEEN CELLS AGAINST TWELVE

Read off `g151_d_kind.sv` and `g151_a_body.sv` (arm scores in §5):

| written statement | golden |
|---|---|
| `iq.sort() with ( item );` | **`func_call(iq)`** |
| `iq.find_index() with (…);` `iq.min() with (…)` … | **`func_call(iq)`** |
| `qq.sort with ( item.offset );` (PARENS-LESS) | **`func_call(qq)`** |
| `qarr[2].sort() with ( item );` (INDEXED) | **`func_call(qarr)`** — the index dropped |
| `iq.sort( x ) with ( x < 3 );` (WRITTEN iterator arg) | **`func_call(iq)`, NO arguments** |
| `bq.and();` `bq.or();` `bq.xor();` `iq.unique();` | **`func_call(bq)` / `func_call(iq)`** — no `with` in sight |
| `obj.randomize() with { rv > 1; };` | **`func_call(obj)`** |
| — | — |
| `iq.sort();` `iq.sort;` `iq.rsort();` `iq.reverse();` `iq.shuffle();` | `method_func_call(<method>)` + `vpiPrefix` |
| `iq.sum();` `iq.min();` `iq.max();` `iq.product();` `iq.unique_index();` | `method_func_call(<method>)` + `vpiPrefix` |
| `obj.randomize();` `obj.randomize(rv);` `oarr[1].randomize();` | `method_func_call(randomize)` + `vpiPrefix` |
| `qarr[2].shuffle();` | `method_func_call(shuffle)` + `vpiPrefix` |

`unique`/`and`/`or`/`xor` are LEXER TOKENS, so `iq.unique()` can never match the
`identifier`-dot-`identifier` road even with no `with` written; `unique_index`,
`shuffle`, `sum`, `sort` are plain identifiers and do. `RANDOMIZE` is a token
too, but Surelog's `identifier` rule admits it, so only the CONSTRAINT BLOCK
forces `o.randomize()` onto the second road — measured, not assumed
(`g151_d_kind.sv` cells 42-49).

### The three fences, each measured

* **`!deep0` — a MULTI-COMPONENT receiver takes the FIRST road anyway.** The
  `(constant_bit_select DOT identifier)*` star eats `h . q2`, the
  `paConstant_bit_select` sibling test hits, and golden keeps
  `method_func_call(q2){prefix h}` for `h.q2.sort() with ( item );`. Arm B
  measures three spellings (`h.inner`, `harr[1].inner`, `nxt.h.inner`) and our
  pristine ALREADY agreed with golden on every one — they are RIGHT→RIGHT and
  did not move a byte.
* **A `this.`/`super.`-rooted receiver never reaches this arm.** Surelog takes a
  THIRD road for it (`paImplicit_class_handle` → `compileComplexFuncCall`,
  whose answer is a `hier_path` named `this.<step>`), and on our side
  `handleStmtCall85` returns before this law's block. README residue **R1**.
* **EXPRESSION position is a different Surelog function entirely.**
  `compileExpression`'s dotted-path builder (`CompileExpression.cpp:5610`) DOES
  decode `paMethod_call_body`: it mints the `hier_path` named after the ARRAY
  ALONE with a `method_func_call` carrying `vpiWith`, which is
  § `arrayWithIsRecvPath9`'s object and which we already emit. `stmtCtx` is the
  whole gate; arm A carries the rvalue, binary-operand, ternary-operand,
  argument, `if`-condition, `while`-condition and `case`-selector twins of the
  law's cells, and every one of them is RIGHT→RIGHT.

---

## 3. THE CHANGE

Two edits, `src/ExprEmit.cpp` + `include/UhdmExporter.h`:

1. `UhdmExporter::stmtBuiltinBodyDegenerate151` — the new predicate. Three
   disjuncts, all read off slang's BOUND AST, never off source text:
   * the call's `SystemCallInfo::getIteratorInfo().first` is non-null (an
     ARRAY-MANIPULATION call carrying a `with (…)` clause — the same pair
     § `arrayWithIsRecvPath9` reads in the expression arm);
   * the subroutine name is `unique` / `and` / `or` / `xor` (the four grammar
     keywords; they are SystemVerilog KEYWORDS, so no user subroutine can wear
     them and the string test cannot collide);
   * `memberRandomizeWith119(...)` answers TRUE (`randomize` with a bound
     inline constraint block) — § `memberRandomizeWithIsRecvPath119`'s own
     predicate, reused verbatim, which also hands back the constraint so the
     span can run through its `}`.
2. One block in the STATEMENT arm of the built-in method emitter
   (`ExprEmit.cpp`, immediately after `deep0` / `recvNm0` are computed and
   after `handleStmtCall85` has returned for the `this.`/`super.` forms):
   when `!deep0` and the predicate fires, mint a bare `func_call` named after
   the receiver's base name — dropped the same TREE-FENCED way
   § `dottedIdxRecvFromSyntax23` drops it for this arm's prefix, i.e. only
   where `builtinRecvStepSelectors74` has confirmed the text split against the
   bound receiver — spanned over the whole written call, and return it.

The span is read off the invocation SYNTAX (`expr.syntax->sourceRange()`,
the `ArrayOrRandomizeMethodExpressionSyntax` that wraps the `with` clause)
because slang's own `expr.sourceRange` stops at the METHOD's `)`; for the
randomize form it runs to the constraint block's own `}`
(§ `memberRandomizeWithIsRecvPath119`'s measurement, reused); for the keyword
forms there is no clause and `expr.sourceRange` already IS the whole call.
**All three spellings land on golden's span EXACTLY** — arm A, arm D and the
corpus head all reproduce `line:…:9, endln:…:52` character for character.

**THE ELABORATED VIEW IS THE SAME REGIME, AND THAT IS MEASURED.** Surelog's
`compileTfCall` runs during compilation, not elaboration, so golden's answer is
identical under `-elabuhdm`; all five arms score the same way in both views and
the corpus population is DEF-view only (SeqDriver's `cmds.txt` carries no
`--elabuhdm` in either mode).

---

## 4. THE GRIDS (`arms151.sh` + `ct151cen` + `score151.py` — `ARMS.txt`)

Five arms, each run under Surelog (golden), the pristine and the patched binary,
in the def and elab views — `LISTED=5 PROCESSED=5 PROCESSED-ASSERT-OK`, every
rc recorded.

| arm | grid |
|---|---|
| `g151_a_body.sv` | **methods × `with`-clause presence × parentheses**: sort / rsort / find / find_index / find_first / find_last / find_first_index / find_last_index / min / max / sum / product / unique, with and without a `with`, parens-ful and parens-less, plus a WRITTEN iterator argument; and every one of them again as an rvalue, a `$display` argument and an `if` condition |
| `g151_b_recv.sv` | **receivers**: queue / dynamic / associative / fixed-unpacked class property, a subroutine BODY LOCAL, an INDEXED single component, three MULTI-COMPONENT chains (`h.inner`, `harr[1].inner`, `nxt.h.inner`), a `this.`-rooted receiver, and each of them again with no `with` |
| `g151_c_home.sv` | **homes**: free package function, free package task, in-body class method, out-of-body class method AND task, class CONSTRUCTOR, module function, module task, module `initial`, module `always`, program, interface, a package that WILDCARD-IMPORTS another (the copy vs the original) and TWO INSTANCES of one module |
| `g151_d_kind.sv` | **the four KEYWORD array-method names** with and without a `with`, against their plain-identifier twins; the **three randomize forms** (`()`, `(args)`, `with { … }`, plus the parens-less `with` and an INDEXED receiver); and three INSTANCES of one law cell on one name |
| `g151_e_ctx.sv` | **contexts**: body top level, plain `begin`, named `begin`, `if` branch, `else` branch, `for` body, `while` body, `repeat` body, `forever` body, `case` arm, `case` default, a bare `fork` arm, and **the corpus head's own container** (`fork begin` + `if`); then the assignment-rvalue, binary-operand, ternary-operand, system-call-argument, `if`-condition, `while`-condition and `case`-selector twins |

Cells are joined as MULTISETS on the ID-FREE key `FILE + ANCH`, where `ANCH` is
the shape ANCHOR — the PREFIX's start for a prefixed `method_func_call`, the
object's own start otherwise. Golden's degenerate `func_call` starts exactly
where our `method_func_call`'s prefix starts, which is what lets the two shapes
pair ACROSS the type flip. Scored columns are `KIND NAME PFX NARG WITH FUNC`;
SPAN and the parent kind are diagnostic only (RESUME.md §9: no generated
`Compare` reads a span).

**RESULT — `RIGHT->WRONG` 0, `AWAY` 0, `ONLY-GOLDEN` 0, `ONLY-OURS` 0 in every
arm, every view, every column.**

| arm | def `KIND`/`NAME`/`PFX` | elab | design-section distance from golden (order-blind, tail cut off) |
|---|---|---|---|
| a | RIGHT→RIGHT 27, **WRONG→RIGHT 17** | same | def 677 → **507**, elab 721 → **517** |
| b | RIGHT→RIGHT 13, **WRONG→RIGHT 6**, WRONG→WRONG 1 (R1) | same | def 569 → **515**, elab 609 → **549** |
| c | RIGHT→RIGHT 0, **WRONG→RIGHT 51** | **WRONG→RIGHT 65** | def 1135 → **675**, elab 1405 → **705** |
| d | RIGHT→RIGHT 13, **WRONG→RIGHT 15** | same | def 651 → **495**, elab 701 → **515** |
| e | RIGHT→RIGHT 16, **WRONG→RIGHT 13** | same | def 653 → **531**, elab 705 → **557** |

`NARG`, `WITH` and `FUNC` are RIGHT→RIGHT throughout except arm D's one
`NARG` WRONG→RIGHT (`obj.randomize(rv) with { … }`, whose argument golden
drops with the rest of the call).

The fences that must NOT move, and did not: every no-`with` statement call,
every plain-identifier reduction method, every multi-component receiver, both
argument-carrying `randomize` forms, and all seven EXPRESSION positions.

### The measurement bug this arm set caught, and the instrument that caught it

`score151.py`'s ROWSETS line first read `ONLY-GOLDEN pris=0 pat=6` on arm C's
elab view. It was not a regression: `UhdmListener` follows BACK-REFERENCE edges
(`vpiParent`, `vpiActual`) that `uhdm-dump` only SHALLOW-visits, so a stale
package clone the design merely points at was being counted as live cells.
`ct151cen` now takes the tail set from **UHDM's own visitor**
(`VpiVisitor::getWeaklyReferenced()`, `UHDM/templates/vpi_visitor.cpp:543`) and
drops any object whose parent chain passes through it, and the arm reads
`0/0` in every view. The AUTHORITATIVE row-set instrument is
`dumpsect151.sh` — the sorted DESIGN SECTION of the whole dump — which the arms
driver runs for every arm and view (the right-hand column above).

---

## 5. THE A-PRIORI PREDICTION (`PREDICTION.txt`, `censweep151.sh`, `pred151.py`)

`ct151cen` was run over **all 956 surelog databases and all 1358 uhdm2rtlil
databases of the PRISTINE sweep AND over each one's GOLDEN** (read out of that
test's own `cmds.txt`, so the pairing cannot drift), and the mover set was
named BEFORE the patched binary existed. The predicate reads golden and
pristine ALONE:

```
at one ID-FREE key (FILE, ANCH)
   golden  KIND=FC   PFX=-   NARG=0  WITH=0  FUNC=0
   ours    KIND=MFC  PFX=<a name>
```

```
surelog     9 databases, 15 scoreable cells, 4 distinct source sites
            SeqDriver df+tf, SimpleUVM df+tf, MiniAmiq df+tf,
            BuildUVMPkg df+tf, Scoreboard df
uhdm2rtlil  0 databases, 0 cells
```

The four sites:

| file:line | written statement | databases |
|---|---|---|
| `uvm-1.2 base/uvm_component.svh:3436` | `m_time_settings.sort() with ( item.offset );` | 7 |
| `1800.2 uvm_pkg.sv:41234` | the same statement in the pp_output | 4 |
| `SVAUnit svaunit_immediate_assertion_info.svh:158` | `checks_details.rsort(item) with (…);` | 2 |
| `SVAUnit svaunit_test_suite.svh:495` | `lof_tests.rsort(item) with (…);` | 2 |

**MEASURED: MOVERS 9 / 956 and 0 / 1358 — exactly the nine, by name.**

---

## 6. THE MOVERS, ATTRIBUTED (`MOVERS.txt`)

`attr151.py` convicts or clears each mover on two independent halves — every
differing census row must be one leg of a FLIP
(`method_func_call(<method>){prefix <recv>}` → bare `func_call(<recv>)`) at a
shared anchor with the row count at every anchor unchanged, and every line of
the whole-dump diff (tail cut off) must belong to the object replaced or to the
object that replaced it.

```
default/BuildUVMPkg  FLIPS=2 CENBAD=0 DUMPBAD=0      testflags/BuildUVMPkg  FLIPS=2 CENBAD=0 DUMPBAD=0
default/MiniAmiq     FLIPS=6 CENBAD=0 DUMPBAD=0      testflags/MiniAmiq     FLIPS=6 CENBAD=0 DUMPBAD=0
default/Scoreboard   FLIPS=2 CENBAD=0 DUMPBAD=92 <-- THE COIN
default/SeqDriver    FLIPS=4 CENBAD=0 DUMPBAD=0      testflags/SeqDriver    FLIPS=4 CENBAD=0 DUMPBAD=0
default/SimpleUVM    FLIPS=2 CENBAD=0 DUMPBAD=0      testflags/SimpleUVM    FLIPS=2 CENBAD=0 DUMPBAD=0
```

**Scoreboard/default is the ~50/50 COIN (RESUME.md §9) and this pass PROVED it
rather than asserting it.** Three runs of the PRISTINE binary alone on the same
sources produced two distinct databases, and their dumps differ by **94
in-order lines and TWO order-blind lines — both of which are the dump's own
header line naming the `.uhdm` file, i.e. ZERO real lines.** Scoreboard is
therefore attributed ORDER-BLIND and no other way, and its order-blind
design-section diff is EXACTLY the law's 18 lines.

Order-blind design-section line counts, pristine vs patched:

```
default/BuildUVMPkg  18    default/MiniAmiq  58    default/Scoreboard  18
default/SeqDriver    38    default/SimpleUVM 18
testflags/BuildUVMPkg 18   testflags/MiniAmiq 58   testflags/SeqDriver 38
testflags/SimpleUVM  18
```

and every one of those lines is one of the law's own — the removed
`method_func_call: (sort)` / `(rsort)` with its `vpiPrefix` `ref_obj` sub-tree,
and the added `func_call: (<receiver>)`.

### The corpus census, golden vs pristine vs patched (`CENSUS.txt`)

Over the nine movers' 112 000+ scored call cells:

```
KIND  WRONG->RIGHT 15   RIGHT->WRONG 0   AWAY 0
NAME  WRONG->RIGHT 15   RIGHT->WRONG 0   AWAY 0
PFX   WRONG->RIGHT 15   RIGHT->WRONG 0   AWAY 0
NARG / WITH / FUNC      RIGHT->RIGHT, unchanged
ROWSETS  ONLY-GOLDEN and ONLY-OURS IDENTICAL pristine -> patched
```

and over all 1358 uhdm2rtlil databases, every column RIGHT→RIGHT with
WRONG→RIGHT 0 and AWAY 0 — the law does not reach that corpus at all.

(The census scores 15 PAIRED cells while the emitter flipped 30 OBJECTS: the
join takes `min` of the two multiplicities at each anchor, and golden holds
fewer copies of a wildcard-imported package body than we do. That row-set gap
is pre-existing, is identical pristine → patched, and belongs to a different
law.)

---

## 7. GATES (all green — `GATES.txt`)

| gate | result |
|---|---|
| (1) build both, `-j 2` | pristine and patched both `Built target slang_uhdm`, 0 errors |
| (2) `tests/check_goldens.sh` (`SLANG_UHDM` exported per binary) | **PASS=23 FAIL=0** for each; negative control `SLANG_UHDM=/bin/false` **FAIL=23 PASS=0** |
| (3) uhdm2rtlil both modes | **CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2**, identical to pristine in both modes; `ct8rows` vs `results/gate_uhdm2rtlil.csv` **PASS**, vs this worktree's own pristine testflags AND default csv **PASS** — 0 differing rows, status AND dump column |
| (4) surelog `--mode both` | histograms **byte-identical to pristine** (default 471/10/5/283/25; testflags 466/9/5/3/1/284/23/1/2); `ct8rows` vs `results/golden_surelog.csv` **PASS** and vs this worktree's own pristine csv **PASS** — **0 differing rows over 1588**, and **NO row was converted** (`results/*.csv` were never written) |
| (5) `byteverify.sh SELFCHECK=1` | uhdm2rtlil **MOVERS 0 / 1358**; surelog **MOVERS 9 / 956**; `PATH_SETS_IDENTICAL` on both (SELFCHECK 1357/1358 and 955/956 flagged) |
| canaries | `canaries.sh` surelog **ok=52 changed=0**, u2r **ok=8 changed=0**; `ctcan2.sh` **PASS** on both; `canaudit.sh canaries.sh ctcan2.sh` **PASS, audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr **byte-identical**; SVSwitch **4842211c4030**; YosysVerx **6ccda350c24a** |
| wide boundary (`BOUNDARY.txt`) | 4227 files × 2 views, two halves: `MOVED=12 BREACH=0 RC-MISMATCH=0` — 10 are this pass's OWN arms in both views, 2 are `r10v99repro/v99_b7_order.sv`, re-measured against golden and moving TOWARD it. `CTRL=1` positive control: **POSITIVE-CONTROL-OK** |

**THE BOUNDARY GATE PRINTED GREEN HAVING COMPILED NOTHING, ONCE.** Its first
run was handed a file list with a doubled `tools/probe/tools/probe/` prefix;
every `cd` failed, every database was absent, and it reported
`MOVED=0 BREACH=0 NORUN=4166` — RESUME.md §9's "a top-level glob ran nothing
and printed green", live. `bound151.sh` now carries a **NORUN ASSERT** that
fails when `NORUN` swallows the whole list, and both halves print
`NORUN-ASSERT-OK`.

---

## 8. HEADS BEFORE → AFTER, AND R0

`rowheads.sh` on this worktree's own pristine and patched sweep workdirs, same
instrument both times; counts are DEPTH, not distance.

| row | before | after |
|---|---|---|
| **SeqDriver default / testflags** | **36 / 36** | **60 / 60** (new object) |
| **SimpleUVM default / testflags** | **36 / 36** | **36 / 36** (new object, same size) |
| **Scoreboard default** | **36** | **163** (new object) |
| **MiniAmiq default / testflags** | **36 / 36** | **106 / 106** (new object) |
| BuildUVMPkg default / testflags | 68 / 68 | 68 / 68 (SAME object; only `id:` numbers shifted by one) |
| Earlgrey_0_1 default / testflags | 29 / 50 | 29 / 50 (byte-identical head log) |
| Rggen default | 0 | 0 |

(`Scoreboard/testflags` is `SLANG_REJECT` and `Rggen/testflags` has no golden —
both print SKIP-NOFILE and are COUNTED, never read as perfection.)

**A cmp line count going UP is fine when the head object CHANGED** (the count
is the new head object's decompile size — RESUME.md §7). All four
`head_pat_*.cmp` logs below carry a DIFFERENT object from their
`head_pris_*.cmp` twin.

**R0 — THE NEXT HEAD.** Four candidates, one per family; the SeqDriver ×2 head
is the deepest-shared:

```
SeqDriver ×2, 60 cmp lines, ONE ^LHS:  — uvm_pkg.sv:801:27
LHS (golden)  class_var: (uvm_pkg::clp) @801:27-801:66, parent \_package: uvm_pkg
```

a PACKAGE-scope `class_var` named `clp` that golden owns and we do not place
the same way — the same `CompilePackage::collectObjects_` out-of-body-walk
family § `tfItemLocalLosesToPkgVar148` decoded, one object further out. See
`head_pat_default_SeqDriver.cmp`.

The other three, for the queue:

* **SimpleUVM ×2, 36 lines** — `enum_const: (UVM_CVR_ALL)` @279:7-279:32 under
  `enum_typespec (uvm_pkg::uvm_coverage_model_e)`, `INT:-1`
  (`head_pat_default_SimpleUVM.cmp`);
* **MiniAmiq ×2, 106 lines** — `unsupported_typespec: (uvm_severity)`
  @168:15-168:27 with `vpiInstance` `uvm_pkg`
  (`head_pat_default_MiniAmiq.cmp`);
* **Scoreboard/default, 163 lines** — the `begin` of
  `uvm_pkg::uvm_reg_predictor::get_type_name` @118:26-122:8 under an `if_stmt`
  (`head_pat_default_Scoreboard.cmp`).

---

## 9. RESIDUES

* **R1 — a `this.`-rooted STATEMENT receiver is a THIRD Surelog road, and we
  take neither.** `this.q.sort() with ( item );` reaches
  `compileComplexFuncCall` through `paImplicit_class_handle`, and golden emits
  a `hier_path` named `this.q` with two `ref_obj` elements; our pristine emits
  a `method_func_call` literally named `this`, and still does. `WRONG->WRONG`
  on `KIND`/`NAME`, 1 cell per view, arm B only. **Corpus incidence is zero**
  (the census names no such cell in either corpus). A different law — the
  implicit-class-handle path builder — and § `handleStmtCall85`'s arm, not this
  one, owns that surface.
* **R2 — the EXPRESSION-position `with`-clause hier_path SPAN is one column
  short, and this pass did not touch it.** § `arrayWithIsRecvPath9` ends the
  path at `withExpr9->sourceRange.end() + 1` where golden ends it one past the
  clause's own `)`. Seven cells in arm A, seven in arm E, IDENTICAL pristine →
  patched. `VpiFile`/line/col are not read by any generated `Compare`
  (RESUME.md §9), so it is invisible to the judge; it is recorded so the next
  pass over that arm does not mistake it for a regression.
* **R3 — the chained spelling is refused by Surelog's own parser.** Both
  `q.find() with (…).size()` and the parenthesised
  `(q.find() with (…)).size()` raise `PA0207`, so the brief's "chained
  `.size()` after it" context is written in `g151_a_body.sv` as the two
  statements the grammar admits. Recorded so the gap is not left unmeasured.
* **R4 — arm C's class CONSTRUCTOR cell makes Surelog print one `CP0332`
  error** (`Function "%exobj" is not defined for variable "cq_c151"`) and
  Surelog exits 4. It still emits the object, the cell scores WRONG→RIGHT, and
  the driver records `rc_sl=4` rather than hiding it.
* **R5 — no helper extraction.** `stmtBuiltinBodyDegenerate151` calls
  `memberRandomizeWith119` rather than sharing a common core with it; per the
  campaign's no-premature-extraction rule the two stay as they are until
  0 DIFF / 0 CMP_ONLY.
