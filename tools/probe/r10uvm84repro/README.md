# r10uvm84 — § `thisDeepStepMockupConst84` — **THE FIRST PASS PAST THE WALL**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here. slang was NOT patched;
`results/*.csv` were READ ONLY; **nothing was promoted**.

## The headline

r10uvm83 tore down the UVM container wall and left ONE head standing on all five
big UVM rows — 54 cmp lines at `uvm_sequencer_base.svh:1576:23`, golden a
`constant` whose only field is `vpiDecompile:this`, ours the `hier_path`
`this.sequences.size`. That head is **gone**, and with it the whole family it
belongs to: **106 objects per SeqDriver database, 54 per SimpleUVM/Scoreboard, 46
per BuildUVMPkg — every one of them to golden, object for object, span for span.**

| row | head BEFORE | head AFTER |
|---|---|---|
| SeqDriver / SimpleUVM / Scoreboard (both modes) | `constant(this)` vs `hier_path(this.sequences.size)` @1576:23 | `method_func_call(this)` vs `method_func_call(sequences)` @**1578:12** |
| BuildUVMPkg (both modes) | `ref_typespec uvm_pkg::uvm_is_match::s` | unchanged (its 46-object deficit still closed) |

Still `CMP_NOTEQUAL` on every row — **no row passes cmp, nothing was promoted** —
but the head has moved TWO LINES DOWN THE SAME FUNCTION, from the expression
`this.sequences.size()` to the statement `this.sequences.delete(i);` on line 1578.
The five rows still share one head; it is now a different law (R0 below).

## The law

> In **EXPRESSION (rvalue) position**, a written chain rooted at an IMPLICIT CLASS
> HANDLE — `this`, `super`, or `this.super` — whose **first step is followed by a
> `.`** compiles to ONE `constant` carrying **only** `vpiDecompile` = the literal
> text `"this"`. No value, no size, no `vpiConstType`, no typespec. Everything
> after the first step — further members, indices, the method call and its whole
> argument list — is **discarded**. The string is `"this"` even for a `super`
> root.

One step is never this shape (`this.n` is a `hier_path`, `this.m()` is a
`method_func_call` with a `this` string-constant prefix), and an INDEX or an
ARGUMENT LIST directly on the first step routes to the select/call arms instead.

### Where it comes from — Surelog, not a guess

`CompileHelper::compileComplexFuncCall`, the `paImplicit_class_handle` branch of
`Surelog/src/DesignCompile/CompileExpression.cpp`, takes
`Method = fC->Sibling(handle)` — the FIRST name after the handle — and splits on
the type of the node that FOLLOWS that name:

| node after the first name | written | result |
|---|---|---|
| `paList_of_arguments` | `this.m(a)` | `method_func_call` named after the METHOD, `vpiPrefix` the `this` string constant |
| `paSelect` / `paConstant_expression` | `this.n`, `this.q[i].len()`, **`this.q.sum() with (item)`** | `compileSelectExpression`, or its fallback `hier_path` |
| `paConstant_bit_select` | `this.q.m(a);` (STATEMENT) | `method_func_call` literally NAMED `"this"` |
| **`slStringConst`** | **`this.q.size()`, `this.h.fld`** | **`:5250  // TODO: this is a mockup`** |

```cpp
    } else if (fC->Type(List_of_arguments) == VObjectType::slStringConst) {
      // TODO: this is a mockup
      constant *cvar = s.MakeConstant();
      cvar->VpiDecompile("this");
      result = cvar;
    }
```

`compileExpression`'s tail (`:3658`, `if (result && result->VpiLineNo() == 0)`) is
what gives that field-less object the span of the whole written chain.

The AST is what makes the gate exact, and it was read with `surelog -parse -d ast`:

```
this.q.size()   Implicit_class_handle, StringConst q, StringConst size, List_of_arguments   -> MOCKUP
this.q[i].len() Implicit_class_handle, StringConst q, Select(Bit_select+expr), StringConst len -> hier_path
this.q.sum() with (item)
                Implicit_class_handle, StringConst q, Select(Bit_select), Built_in_method_call -> hier_path
this.q.delete(i);  (statement)
                Implicit_class_handle, StringConst q, Constant_bit_select, StringConst delete, List_of_arguments
                                                                                        -> method_func_call("this")
```

## The fix — where the regime was UNREACHABLE, and why

§ `thisRecvCall11` already ships this exact mockup. It fires for a call slang
gives a `thisClass()` — a USER class method. The corpus head is `size()` on a
QUEUE: a **BUILT-IN method is a SystemSubroutine whose `thisClass()` is NULL and
whose receiver hides in `arguments()[0]`** (§ `scopedBuiltinRecvIsChain1`'s
decode — the same gap that pass named as "what left BuildUVMPkg's head
standing"). And a chain with NO CALL AT ALL (`this.cfg.n_bytes`) never reaches
the call code in the first place. Four call sites, one predicate, one builder:

| site | `src/ExprEmit.cpp` | shape |
|---|---|---|
| 1 | the BUILT-IN / system-method arm | `this.q.size()`, `this.am.exists(k)`, `this.h.arr.size()` |
| 2 | `case ExpressionKind::ElementSelect` | `this.h.arr[i]` |
| 3 | `case ExpressionKind::RangeSelect` | `this.h.pk[1:0]` |
| 4 | `case ExpressionKind::MemberAccess` | `this.cfg.n_bytes`, `this.value.value` |

The predicate is TEXT (`thisDeepStepMockup84`), because text is the only form that
separates `this.q.size` from `this.q[i].len` in every position, and because at
SITE 1 slang's own range for a PARENS-LESS built-in collapses onto the receiver
(§ `parensLessCallIsPathRefObj`) and would hide the second step. The first step
must be a PLAIN identifier, so `this.get_q().size()` and a spaced `this.q [i]`
DECLINE rather than guess.

## Three fences, each MEASURED, each with a cell that fails without it

1. **LVALUE — AND `inLhs` IS ONLY HALF OF IT.** Surelog compiles an assignment
   target through its lvalue path, never through `compileComplexFuncCall`. Arm
   `c1` L12–L15 (`this.h.fld = 5`, `this.h.arr[i] = 6`, `this.h.fld++`,
   `this.h.fld += 2`) are `hier_path` in golden, while the SAME text one line
   later in rvalue position (bare condition, ternary condition, `$display`
   argument, user-call argument, concatenation operand) is the mockup.
   **The first cut of this law shipped `!inLhs` alone and OVER-COLLAPSED the
   INC/DEC cells** — this emitter builds `this.h.fld++` as an ordinary unary
   operation and never sets `inLhs`, so golden's `hier_path (this.h.fld)` under
   `operation vpiOpType:62` came out as the mockup, while the `+=` twin one line
   down was fenced correctly because that path DOES set `inLhs`. Caught by this
   pass's own arm (c1 L14, e1 L22/L23) on the binary
   `01fa98c95fa6f595623122d360708fd7`, before any of it landed; the fix is
   `lvIncDecTarget84`, set only around the inc/dec operand emit and read only by
   this law. Gate: `!inLhs && !lvIncDecTarget84`.
2. **The `with` clause.** `this.q.sum() with (item)` puts a `paSelect` between the
   first name and the method, so golden emits the `hier_path` named `this.q` that
   this arm already built — never the mockup. Gate: `!withExpr9`, and the block
   therefore sits AFTER the with-clause is read. **This fence caught a real
   regression**: the first measurement of this pass was taken from a binary that
   lost the clause to a build race (GATES, gate 1) and it collapsed that cell.
3. **The FIRST-STEP INDEX.** `this.ha[i].fld` and `this.q[i].len()` keep golden's
   select-erased `hier_path`; only an index on a LATER step (`this.h.arr[i]`) is
   inside the discarded tail. The predicate's "next char must be `.`" is that
   fence, and cells b1 L22 vs L23/L24 are the pair that distinguishes them.

Arm `e1` closes the position grid the other way round, and every one of its
cells agrees with golden: a `wait` condition, an **OUTPUT** argument actual, an
**INOUT** argument actual and a `for` condition all COLLAPSE (they are ordinary
`compileExpression` positions), `--`/`--x` do not, and a deep chain written as an
INDEX (`this.q[this.h.fld]`) is dropped with the rest of the select on both sides.

Constraint blocks and `randomize() with {…}` need no fence: golden emits NO object
for a constraint body at all, and arm `d2`'s mockup count is golden's (1 = 1) with
the law shipped, so the sites are not reached rather than merely gated.

## The census (CENSUS.r10uvm84.txt) — the deficit was a BIJECTION before any code

Golden mockups we lacked, and our `this…`/`super…` multi-dot hier_paths golden
lacked, were EQUAL IN EVERY DATABASE: 106/106 SeqDriver, 54/54 SimpleUVM,
54/54 Scoreboard, 46/46 BuildUVMPkg. After the patch both populations equal
golden's exactly, the span sets join with ZERO golden-only spans on BuildUVMPkg,
and the CONTROL population (`THISKW`, the ordinary `this`-keyword constant) moved
by **zero objects** in all seven databases.

The 30 golden-only spans of default/SimpleUVM split 12 / 15 / 3 into exactly the
two emitter sites this pass adds plus 3 macro-attribution artefacts — the split
that predicted, before the code was written, that a call-only fix would leave half
the family standing.

## The instruments (all MEASUREMENT-ONLY)

| tool | what it answers |
|---|---|
| `ct84cen.cpp` | the three populations of ONE database (`Serializer::AllObjects`, each object once), `--list` for spans; and `PRED`, the mover predictor |
| `pred84.sh` | `ct84cen` over a whole sweep workdir: the predicted movers, by name |
| `arm84.sh` | golden + BOTH binaries in ONE scratch dir; cmp verdict, head count, dump distance, and a pristine/patched byte compare |
| `g84_*.sv` | the grid: 14 arms, 70+ cells, every one compiled by BOTH tools |
| `ast84.sv` | the AST probe input — `surelog -parse -d ast -nobuiltin ast84.sv` prints the four parse shapes quoted above, which is where the gate came from |
| `ladtab84.sh` | builds `LADDERS.r10uvm84.txt` from two `rowladders.sh` output dirs (rung totals, R1 per row, and the two families' rung counts) |
| `rowheads.sh` `ct8rows.sh` `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` | the committed gate drivers, carried forward unmodified |

`g84_b3_pkgoob.sv` is the corpus head in 20 lines: a package class with an
out-of-body method AND its in-body twin, both writing
`for (int i = 0; i < this.sequences.size(); i++)`. Its pristine cmp head is
byte-for-byte the corpus head (`constant` @16:25 vs `hier_path this.sequences.size`),
and after the patch its head is the corpus's NEW head — the statement on the next
line but one. A 20-line file now reproduces both.

## Read next

* `CENSUS.r10uvm84.txt` — the bijection, the classified 30 spans, the grid table.
* `PREDICT.r10uvm84.txt` — the prediction (7 of 953, 0 of 1358) and the measurement.
* `GATES.r10uvm84.txt` — the five gates, the canaries, and the build race that
  produced a wrong number before it was caught.
* `LADDERS.r10uvm84.txt` — the calibration (3 ZERO-HEADS), the FULL before ladder on
  all seven UVM row-modes, and R1 (the rung the official judge stops at) on BOTH
  sides of all seven: `constant|VpiType|KIND:constant>hier_path` @1576:23 becomes
  `method_func_call|VpiName|TEXT:this|sequences` @1578:12, byte-for-byte the
  official heads. It also records what was NOT measured (the AFTER rung TOTALS,
  starved by a concurrent agent's own ladder) rather than quoting a BUDGET-stopped
  total against a FIXPOINT one.

## RESIDUES (ranked)

**R0 — THE NEW HEAD, and the five rows still share it.** The STATEMENT-position
spelling, `this.sequences.delete(i);` @`uvm_sequencer_base.svh:1578:12`:

```
LHS golden  method_func_call vpiName "this"   located at the FIRST name (`sequences`)
            vpiPrefix -> constant  decompile "this", size 4, STRING:this, vpiConstType 6
            vpiArgument -> ref_obj i
RHS ours    method_func_call vpiName "sequences"
            vpiPrefix -> ref_obj `…::remove_sequence::this` BOUND TO logic_net work@top.this
            no argument
```

Three separate defects in one object (the NAME, the PREFIX kind, the dropped
ARGUMENT) and a fourth worth naming: our prefix ref binds a **module net called
`this`** — `logic_net (work@top.this)`. Arm `g84_a7_stmt.sv` measures all four
spellings (`delete`, `push_back`, a user method, and `void'(…)`), and the THISKW
deficit this pass did not close (16 BuildUVMPkg / 20 SimpleUVM / 40 SeqDriver
objects per database) is EXACTLY this family's prefix constants. It is Surelog's
`paConstant_bit_select` arm, three lines below the one this pass read.

**R1 — the mockup's `vpiParent` at a sys_func_call ARGUMENT and a case_stmt
CONDITION.** Golden's parent for this object is whatever the CONSUMER stamps;
measured in arm `a1`: operation operand PARENTED, `$display` argument PARENTED,
`case` condition PARENTED, assignment RHS and `return` condition PARENTLESS. The
builder uses the emitter's existing literal-constant policy, which reproduces
operation / assignment / return exactly and leaves the sys_func_call and case_stmt
cases parentless — two dump lines per site, and the corpus has such sites
(`uvm_mem_mam.svh:675:41`, inside a \`uvm_info macro). `vpiParent` is read by NO
`Compare` method, so this is dump-only; the table above is the whole fix, and it
is deliberately not applied without re-running the five gates on it.

**R2 — 4 macro-body span attributions** (CENSUS Part 6): golden puts them in
`uvm_message_defines.svh`, we put them at the use site. Object count equal, 2 of
the 4 pre-existed this pass, and no compared field differs.

**R3 — `this.q[i].len()`: the NAME still carries the index.** Golden's
select-erased `hier_path` is named `this.q.len`, ours `this.q[i].len`
(arm b1 L23). `hier_path::Compare` READS `VpiName`, so this one IS cmp-visible —
it is § `thisPathSelectErased4`'s erasure not running for a BUILT-IN CALL
receiver, the same "receiver hides in `arguments()[0]`" gap this pass closed for
the collapse but not for the erasure. First-ranked cmp-visible residue.

**R4 — one-step `super.bfld` / `this.super.bfld`.** Golden emits
`hier_path (super.bfld)`; slang resolves `super.x` straight to the inherited
member and we emit a plain `ref_obj` (arm b2 L16, arm d1 L25). Unchanged by this
pass and still § `thisPathSelectErased4`'s own recorded residue.

**R5 — our mockup constants carry no `vpiFile`** while golden's do (visible in
`ct84cen --list`). Not a compared field; recorded because it makes a `--list`
join look asymmetric until you know it.
