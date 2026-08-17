# r10uvm85 — § `thisStmtHandleCall85` — **THE HEAD OF SEVEN UVM ROWS, CLOSED**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here. slang was NOT patched;
`results/*.csv` were READ ONLY; **nothing was promoted.**

## The headline

r10uvm84 tore the EXPRESSION-position `this`-chain family down to golden and left
ONE head standing on all seven UVM row-modes — the STATEMENT two lines below it:

```
this.sequences.delete(i);          uvm_sequencer_base.svh:1578:12
```

Golden emits ONE `method_func_call` **named `"this"`**, spanned at the FIRST NAME
after the handle, whose `vpiPrefix` is the `this` STRING CONSTANT and whose
`vpiArgument` is `i`. Our pristine emitter named it `"sequences"`, gave it a
`ref_obj` prefix **mis-bound to a module net called `this`**, and **dropped the
argument** — four defects on one object. That head is **gone, and so is the whole
family**: 40 objects per SeqDriver / MiniAmiq database, 20 per SimpleUVM /
Scoreboard, 16 per BuildUVMPkg, every one to golden — **object for object, span
for span, prefix for prefix, argument count for argument count** (CENSUS Part 3).

| row | head BEFORE | head AFTER |
|---|---|---|
| SeqDriver / SimpleUVM / Scoreboard / MiniAmiq (both modes) | `method_func_call(this)` vs `method_func_call(sequences)` @**1578:12** | `constant(INT:-1)` vs `operation(vpiOpType:1)` @**1685:10** |
| BuildUVMPkg (both modes) | `ref_typespec uvm_pkg::uvm_is_match::s` | unchanged (its own older head) |

Still `CMP_NOTEQUAL` on every row — **NO ROW PASSES cmp, nothing was promoted** —
but the head has moved 107 lines down the same file to `return -1;`, and the cmp
line count falls 68→38 / 64→38 on every row that shares it (GATES, OFFICIAL
HEADS). The new head is a NEGATIVE-LITERAL FOLD and is R0 below.

## The law

> In **STATEMENT position** (Surelog's `Subroutine_call_statement`, which the
> parser also builds for `void'(…)`), a call written
> `<handle>.<name>[<index>].<method>(args)` where `<handle>` is an IMPLICIT CLASS
> HANDLE — `this`, `super`, `this.super` — compiles to ONE `method_func_call`:
>
> * `vpiName` = the **ROOT**, never the method: `"this"` for a `this` handle,
>   `"super"` for **BOTH** `super` and `this.super`;
> * the **span** is the FIRST NAME AFTER THE HANDLE, its **name only** — the
>   index is not part of it;
> * `vpiPrefix` = the handle compiled as an expression, which for these three
>   keywords is a bare STRING constant: `STRING:this` size 4 / `STRING:super`
>   size 5 / `STRING:this.super` size 10, `vpiConstType` `vpiStringConst`,
>   `vpiDecompile` the same text, spanning the handle text, **UNPARENTED**;
> * **the method name appears nowhere**;
> * `vpiArgument` = the method's own written arguments — **but only when exactly
>   ONE name stands between the handle and the method.** Two names deep the
>   whole argument list is dropped as well.
>
> When the receiver **IS** the handle (`void'(this.randomize());`) it is the
> OTHER arm: named after the METHOD, arguments kept, and **only the prefix** is
> this law's.

### Where it comes from — Surelog, not a guess

`CompileHelper::compileTfCall` sends a `paImplicit_class_handle` statement leaf
straight to `compileComplexFuncCall` (`CompileHelper.cpp:4157`), which splits on
the node FOLLOWING the first name after the handle. In statement position the
parser puts a **`paConstant_bit_select`** there — EMPTY for a plain name, and
carrying the index expression when the step is indexed — never the
`slStringConst` that selects uvm84's mockup. `CompileExpression.cpp:5227`:

```cpp
} else if (fC->Type(List_of_arguments) == VObjectType::paConstant_bit_select) {
  // TODO: Fill this
  method_func_call *fcall = s.MakeMethod_func_call();
  if (expr *object = (expr*)compileExpression(component, fC, Handle, ...))
    fcall->Prefix(object);                       // the THIS/SUPER constant, :3523
  if (VectorOfany *arguments = compileTfCallArguments(
          component, fC, fC->Sibling(fC->Sibling(List_of_arguments)), ...))
    fcall->Tf_call_args(arguments);              // <- the ARITY RULE lives here
  fcall->VpiName(rootName);                      // "this" / "super", :5162
  fC->populateCoreMembers(Method, Method, fcall);// <- the FIRST name's span
  result = fcall;
}
```

`Sibling(Sibling(Constant_bit_select))` is the argument list only at depth one;
one name deeper it is the NEXT `Constant_bit_select` and `compileTfCallArguments`
finds nothing. That single line is the whole arity rule, and it was read off the
AST (`surelog -parse -d ast -nobuiltin ast85.sv`) before it was measured:

```
this.q.delete(0);       Implicit_class_handle, q, Constant_bit_select(EMPTY),
                        delete, List_of_arguments            -> args KEPT
this.hv[1].m85();       Implicit_class_handle, hv, Constant_bit_select(Constant_
                        expression), m85, List_of_arguments  -> args KEPT
this.h.arr.delete(0);   Implicit_class_handle, h, Constant_bit_select, arr,
                        Constant_bit_select, delete, List_of_arguments
                                                             -> args DROPPED
void'(this.q.size());   Subroutine_call_statement, same shape -> SAME ARM
this.um85(3);           Implicit_class_handle, um85, List_of_arguments
                                                             -> the OTHER arm
```

## The fix — two sites, and why the regime was unreachable at the first

§ `thisRecvCall11` has shipped this exact object since r10uvm11 — **for a call
slang gives a `thisClass()`**, i.e. a USER method. The corpus head is `delete` on
a QUEUE: a **BUILT-IN method is a SystemSubroutine whose `thisClass()` is NULL and
whose receiver hides in `arguments()[0]`** (§ `scopedBuiltinRecvIsChain1`'s
decode — the same gap uvm84 closed for the rvalue collapse). So the whole
handle-rooted regime was unreachable at the built-in statement arm, which minted a
call named after the MEMBER with a `ref_obj` prefix and no arguments at all.

| site | file | what changes |
|---|---|---|
| 1 | `src/ExprEmit.cpp`, the BUILT-IN statement arm | the whole object: name, span, prefix KIND, arguments |
| 2 | `src/ExprEmit.cpp`, § `thisRecvCall11`'s statement branch | the ARITY RULE only (`segs11.size() <= 2`) |

The gate is the receiver's SOURCE TEXT (`handleStmtCall85`), for the same reason
uvm84's predicate is: slang resolves `super.bq` straight to the inherited member,
so the written handle survives nowhere else, and for a PARENS-LESS built-in
slang's own call range collapses onto the receiver. The decoder tolerates
whitespace (`this . q.delete(0);` — arm b1 L22, where the pristine emitter
produced a call literally NAMED `" q"`) because every span it computes is an
OFFSET INTO THAT TEXT, and it DECLINES — keeping the pristine shape rather than
guessing — for an escaped identifier (`\this ` is an ordinary variable whose
symbol name is also `this`: uvm84's verifier finding F1), a receiver that is a
CALL, a comment in the way, or a `this . super` spelling whose step would read
`super` (a KEYWORD can never name a step, so that case is caught and declined).

## Fences, each with a cell that fails without it

1. **STATEMENT POSITION.** `stmtCtx` is the existing gate and it is uvm84's law
   on the other side of it: arm a5 L23/L24 write the same chain in EXPRESSION
   position and golden emits § `thisDeepStepMockupConst84`'s mockup, which is
   already ours and must stay.  a5 measures both in one body.
2. **NO `classArgBind12` WINDOW.** Arm a8 is the corpus shape — a package class
   with an out-of-body method AND its in-body twin — and golden leaves the
   IN-BODY twin's loop variable and formal BARE (L14/L16) while binding the
   OUT-OF-BODY twin's to the `int_var` and the `io_decl` (L23/L25). That is
   exactly what the standing bind machinery does with no window open; opening one
   would have bound all four.
3. **THE ARITY RULE.** a6 L20/L21/L22 is the depth ladder on ONE golden
   (`this.q.delete(k)` keeps `k`, `this.h.arr.delete(k)` and
   `this.h.l.arr.delete(k)` keep nothing), and a4 L24/L26 proves an INDEX is not
   a name.
4. **uvm84's `lvIncDecTarget84` fence is untouched.** This law lives in the
   statement CALL arm; it reads neither `inLhs` nor that flag and cannot reach an
   assignment target. `allbound82.sh` proves it by bytes: c1/e1, uvm84's lvalue
   and position arms, are among the 984 cells that did NOT move.

## The grid — 11 arms, 100+ cells, every one compiled by BOTH tools

| arm | what it measures | after |
|---|---|---|
| `g85_a1_builtin.sv` | delete/insert/push_back/push_front/sort/reverse/shuffle, assoc `delete`, 0/1/2 args, literal / formal / operation / deep-`this` actuals | **PASS_CMP** |
| `g85_a2_user.sv` | USER method on `this.<member>`, bare `this.<user>()` (controls) | cells agree |
| `g85_a3_super.sv` | `super.` and `this.super.` roots, deep, 1 arg and 0 args | **PASS_CMP** |
| `g85_a4_deep.sv` | INDEXED members (`this.qq[1].delete(0)`, variable index), 3-deep chains | cells agree |
| `g85_a5_neg.sv` | flat and deep NON-handle receivers, EXPRESSION position (uvm84's mockup), `void'(…)` | cells agree |
| `g85_a6_depth.sv` | the ARITY LADDER, both call families | cells agree |
| `g85_a7_pos.sv` | task body, fork arm, if/else, for (loop-var actual), while, case item, named block, two `void'` forms | **PASS_CMP** |
| `g85_a8_corpus.sv` | the CORPUS shape: package class, out-of-body + in-body twins, argument BINDING both ways | **PASS_CMP** |
| `g85_a9_onestep.sv` | the receiver that IS the handle (`void'(this.randomize())`) | **PASS_CMP** |
| `g85_b1_edges.sv` | deep `super.`/`this.super.` USER methods, parens-less `this.q.delete;`, the SPACED handle | 2 cells left (R1) |
| `g85_z0_pkgoob.sv` | uvm84's own 20-line corpus repro, unmodified | **PASS_CMP** |

Six arms go CMP_FAIL → **PASS_CMP**. The five that do not each keep the SAME
pre-existing head — a class-handle property's `class_var`/`ref_typespec`/
`class_typespec` shape, present on both binaries and unrelated to this law — and
their handle-call cells are all green (`cell85.sh` reports lines_DIFFER=0 for
a2/a5/a6 and only pre-existing declaration cells for a4).

## The census — the deficit was a BIJECTION before any code was written

`GHEAD` deficit == `OHEAD` == `PRED` == `THISKW` deficit, EXACTLY, in every
database: 40 / 40 / 40 / 40 SeqDriver and MiniAmiq, 20 SimpleUVM and Scoreboard,
16 BuildUVMPkg. After the patch every population equals golden's and the
`(span, name, prefix, args)` sets JOIN with **zero golden-only and zero ours-only
objects in all six measured databases**. uvm84's `MOCKUP` population — the
control — moved by **zero objects** everywhere, and the `THISKW` column is the
same 16/20/40 uvm84 recorded as its own unexplained deficit.

## The instruments (all MEASUREMENT-ONLY)

| tool | what it answers |
|---|---|
| `ct85cen.cpp` | the six populations of ONE database (`Serializer::AllObjects`, each object once), `--list` for the span/name/prefix/arg join; `PRED` is the mover predictor |
| `pred85.sh` | `ct85cen` over a whole sweep workdir: the predicted movers, by name |
| `arm85.sh` | golden + BOTH binaries in ONE scratch dir; cmp verdict, head count, dump distance, and a pristine/patched byte compare |
| `cell85.sh` | the PER-CELL comparator: reduces both dumps to object-header SETS bucketed by SOURCE LINE, so a 300-line dump diff can be read cell by cell (it buckets by line NUMBER only, so keep arms shorter than the builtin file's line span or pass a range) |
| `sweep85.sh` | the sweep driver: echoes `GOLDEN_DEFER`, exports `SLANG_UHDM`, greps the workdir's own `cmds.txt` to prove which binary ran |
| `ast85.sv` | the AST probe — the five parse shapes quoted above |
| `g85_*.sv` | the grid |
| `rowheads.sh` `ct8rows.sh` `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` | the committed gate drivers, carried forward BYTE-IDENTICAL (md5-checked against r10uvm84repro) |

## RESIDUES (ranked)

**R0 — THE NEW HEAD, and the five rows share it.** `return -1;` at
`uvm_sequencer_base.svh:1685:10` in `uvm_sequencer_base::get_seq_kind`:

```
LHS golden  constant  vpiDecompile:-1  vpiSize:64  INT:-1  vpiConstType:7
RHS ours    operation vpiOpType:1 (unary minus) @1685:10-1685:12
              vpiOperand -> constant  vpiDecompile:1  vpiSize:64  UINT:1  ct:9
```
Surelog FOLDS a negated integer literal into ONE `constant`; we keep the written
`operation`. 38 cmp lines on SeqDriver / SimpleUVM / Scoreboard / MiniAmiq (both
modes). It is a FOLD law, not a naming law, and it is the first head this
campaign has met that is neither a class-body shape nor a chain.

**R1 — the DEEP `super.` / `this.super.` USER-method statement call.** Arm b1
L19/L25, MEASURED on golden and still wrong:
```
super.bl.lm1(k);        golden constant STRING:super       + method_func_call(super) @ `bl`
this.super.bl.lm1(k);   golden constant STRING:this.super  + method_func_call(super) @ `bl`
ours (both)             method_func_call(lm1) with a ref_obj prefix spanning the whole receiver
```
It is the SAME Surelog arm, reached through § `thisRecvCall11`, whose
`superRoot11` clause deliberately "keeps the pre-existing flat form rather than
guessing". It is NOT landed here because the corpus contains **ZERO** such
statements (CENSUS Part 6: the grep finds none in any of the three UVM trees), so
a third emitter site would carry regression risk against no corpus witness. The
two cells above are the arm a future pass can land it on.

**R2 — `this.randomize() with { … }` is a THIRD Surelog arm.** Arm `g84_d2_ctx`
L13 / `v84x7_misc` L22: golden emits a `func_call` NAMED `"this"` spanning the
WHOLE call, ours a `method_func_call(randomize)`. Wrong on both binaries; this
pass changed only the prefix object inside it (ref_obj → the handle constant), so
the cell is NEUTRAL and is named in GATES as such.

**R3 — the `this` net's SPAN.** Golden's implicit `work@top_tb.this` wire is
minted at its own first unresolved reference (@902:36); ours at @152:45. Same
object count on both sides in all nine databases (CENSUS Part 4) and neither
`vpiFile` nor the span is a compared field — recorded because a `--list` join
looks asymmetric until you know it.

**R4 — the NON-HANDLE statement call with an INDEXED receiver is named from the
wrong text.** The ladder names it one rung below this family
(`default/SimpleUVM` RUNG 130, `uvm_component.svh:2674:33`):
```
m_streams[stream.get_name()].delete(stream.get_type_name());
golden  method_func_call NAMED "delete" @2674:33-2674:39   (Surelog's plain
        statement branch, CompileHelper.cpp:4220: tfNameNode = Sibling(
        Constant_bit_select) — the METHOD)
ours    method_func_call NAMED "get_name()]" @2674:21-2674:32
```
Our non-handle path splits the receiver TEXT on `.` and takes segment 1, which an
INDEX CONTAINING A DOT turns into garbage. It is cmp-visible (`VpiName`), it lives
in the arm this pass edits, and this law does not touch it: `handleStmtCall85`
declines a receiver that is not handle-rooted, so the cell is byte-identical on
both binaries (ladder FAM count 1 -> 1). It needs its own arm and its own gate.

**R5 — the deep-`this` ARGUMENT's own shape is now visible.** Emitting the
argument at all exposes a PRE-EXISTING law's residue in the arm cells: for
`this.q.push_front(this.n);` golden's actual is `hier_path(this.n)` spanning
16:25-16:31 with both elements at the LAST name, ours spans 16:25-16:29 with a
scoped element fullname (a1 L16/L24). NOT cmp-visible — `hier_path::Compare`
reads `VpiName` and both read `this.n` — and in the CORPUS the actual is uvm84's
MOCKUP, which we now emit and golden agrees with (v84x8_break L28/L29). Dump-only.

**R6 — the arm-level class-handle-property head** (`inner h;` →
`class_var`/`ref_typespec`/`class_typespec`) is what keeps five of this pass's
eleven arms at CMP_FAIL. It is pre-existing, identical on both binaries, and
unrelated to any handle call.
