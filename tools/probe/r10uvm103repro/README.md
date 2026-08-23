# r10uvm103 — § `invalidShellKeepsStmtPos103` — **AN `Invalid` NODE IS A SHELL, NOT A POSITION: a statement-position call one of whose ARGUMENTS slang refused to bind is still a STATEMENT** — the SimpleUVM ×2 / Scoreboard/default head **CUT 108 → 22**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `ecdded75` |
| worktree | `/tmp/wt_r10uvm103` |
| pristine binary | md5 `9ae62f2d6a19f72cf5cb259847914b9a` — reproduced the main tree's binary byte for byte — frozen `chmod 555` |
| patched binary | md5 `345863eda3e6135f471565542c866c9f`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` ONLY — the `case ExpressionKind::Invalid` child unwrap |
| probe surface | `tools/probe/r10uvm103repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **108** | **22** | 1 |
| **Scoreboard default** | **108** | **22** | 1 |
| SeqDriver default / testflags | 17 | 17 | 1 |
| MiniAmiq default / testflags | 348 | 348 | 1 |
| BuildUVMPkg default / testflags | 72 | 72 | 1 |
| Earlgrey_0_1 default / testflags | 46 | 46 | 1 |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes) | |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the nine PREDICTED BY NAME | |
| the fossil family | 29 rows / 9 databases | **0 rows / 0 databases** | |

`head_pris_default_SimpleUVM.cmp` is the whole 108-line head uvm99 named R2;
`head_pat_default_SimpleUVM.cmp` and `head_pat_default_Scoreboard.cmp` are the
whole NEW 22-line one (**R0**, the same object in all three row-modes — the two
files differ only in object ids).

## 1. THE HEAD, DECODED FROM `BaseClass.h` + THE GENERATED `Compare` FIRST

The 108-line head, verbatim from the pristine cmp log:

```
LHS  method_func_call: (before_export)              @131:10-131:23
       |vpiParent: \_function: (uvm_pkg::uvm_algorithmic_comparator::write) @130:3-132:14
       |vpiName:before_export
       |vpiPrefix: \_ref_obj: (…::write::comp)      @131:5-131:9
RHS  hier_path: (comp.before_export.write)          @131:5-131:29
       |vpiParent: \_function: (…::write)
       |vpiActual: \_ref_obj: (comp)                @131:5-131:9
       |vpiActual: \_ref_obj: (before_export)       @131:10-131:23
       |vpiActual: \_method_func_call: (write)      @131:24-131:29
                     |vpiArgument: \_hier_path: (m_transformer.transform) @131:31-131:59
       |vpiName:comp.before_export.write
```

**THE FIELD IS `VpiType`, and the CARRIER is `function::Stmt`.** Both sides put
the object in the **singular** `Stmt` slot of the same `function` (read off both
`uhdm-dump`s, not assumed: `|vpiStmt:` immediately follows the `io_decl` on both
sides). `task_func::Compare` therefore reaches it through the SINGULAR
`SafeCompare` overload (`~/.local/include/uhdm/BaseClass.h:187`) →
`BaseClass::Compare`, whose **first** test is `VpiType`, and that arm sets
`m_failedLhs` **and** `m_failedRhs` — which is exactly the two-sided head we see.
Nothing below `VpiType` is ever read, so `Path_elems`, the names and the
arguments are all beyond the mismatch.

Source: `uvm-1.2 comps/uvm_algorithmic_comparator.svh:131`, the whole body of

```systemverilog
class uvm_algorithmic_comparator #(type BEFORE=int, type AFTER=int, type TRANSFORMER=int) …
  local uvm_in_order_class_comparator #(AFTER) comp;      // :100
  local TRANSFORMER m_transformer;                        // :101
  function void write( input BEFORE b );                  // :130
    comp.before_export.write( m_transformer.transform( b ) );   // :131
  endfunction
```

**ONE copy per database, on both sides** (counted: the golden dump holds the
object once plus one parent back-reference; ours holds it once plus three).
The class is never instantiated, so there is no per-specialisation copy — the
object lives in the DEF class listing only.

**Golden DROPS the trailing `.write(…)` entirely**, and the DUMP proves it
rather than the head implying it: golden's whole `function::Stmt` subtree is the
`method_func_call (before_export)`, its `vpiParent`, its `vpiName`, and its
`vpiPrefix` `ref_obj (comp)` — and nothing else. There is **no `vpiArgument`**,
no second call, and no `m_transformer.transform` anywhere beneath it. Our
patched database's subtree is now **BYTE-IDENTICAL** to golden's (diffed
directly, `uhdm-dump` to `uhdm-dump`).

## 2. THE LAW

> **§ `invalidShellKeepsStmtPos103`** — *slang wraps the WHOLE expression of a
> statement in a bad-expression (`Invalid`) shell when any part of it fails to
> bind. **The call inside that shell is still the STATEMENT.** The `Invalid`
> arm must clear the statement flag for its own sub-expressions, but it must
> RESTORE it for the child it unwraps when that child is the call itself (or
> another shell, which re-decides) — otherwise a statement-position call is
> emitted in EXPRESSION position and gets the `hier_path` receiver chain
> instead of Surelog's `method_func_call` + `vpiPrefix`.*

The gate is three conjuncts and nothing else:

1. the object being emitted is an `InvalidExpression` **with a child**;
2. `callStmtContext` was TRUE on entry (only `StmtEmit`'s `ExpressionStatement`
   arm ever raises it, and only for the statement's OUTERMOST expression —
   every consumer clears it immediately);
3. the child's kind is `Call` or `Invalid`.

Everything else keeps the plain unwrap, byte for byte, by construction — a
`$display` shell, a `&&` one of whose operands was dropped, a bare receiver
(which § `droppedCall14` already owns, and which already received the flag).

**DIRECTION: it changes a CARRIER, never a payload.** Measured directly on the
corpus at `uvm_misc.svh:720`: the moved call's ARGUMENT SUBTREE is byte-identical
before and after; only the enclosing object changed from `hier_path` to
`method_func_call` + `vpiPrefix`.

## 3. DECODED FROM SURELOG (`~/git-repos/Surelog`), NOT INFERRED

Surelog never binds anything here, so a statement-position dotted call compiles
the same way whether or not slang could resolve its arguments. The whole shape
comes out of ONE arm:

* `CompileStmt.cpp:250` — `case VObjectType::paSubroutine_call_statement:` hands
  `fC->Child(the_stmt)` straight to `compileTfCall`.
* `CompileHelper.cpp:4135` `compileTfCall`, the final `else` (**"User call"**),
  `:4218`–`:4237`:

```cpp
tfNameNode = dollar_or_string;                       // the FIRST identifier
name = fC->SymName(tfNameNode);                      // "comp"
NodeId Constant_bit_select = fC->Sibling(tfNameNode);
if (fC->Type(Constant_bit_select) == VObjectType::paConstant_bit_select) {
  tfNameNode = fC->Sibling(Constant_bit_select);     // the SECOND identifier
  method_func_call* fcall = s.MakeMethod_func_call();
  fC->populateCoreMembers(tfNameNode, tfNameNode, fcall);
  fcall->VpiName(fC->SymName(tfNameNode));           // "before_export"
  ref_obj* prefix = s.MakeRef_obj();
  prefix->VpiName(name);                             // "comp"
  fC->populateCoreMembers(dollar_or_string, dollar_or_string, prefix);
  fcall->Prefix(prefix);
  call = fcall;
}
…
NodeId argListNode = fC->Sibling(tfNameNode);        // :4326 — Sibling of the SECOND name
if (VectorOfany* arguments = compileTfCallArguments(…, argListNode, …))
  call->Tf_call_args(arguments);
```

**The walk takes exactly ONE `Constant_bit_select` step.** For a
2-component call `a.b(x)` the sibling of the second name IS the
`List_of_arguments`, so the arguments survive. For **3 or more** components
the sibling of the second name is the NEXT `Constant_bit_select`, and
`compileTfCallArguments` (`:4340`) returns `nullptr` for it — so the third
component, the fourth, the method and **the whole argument list** are dropped
on the floor. That is not a special case for unbindable arguments: it is what
Surelog does to `a.b.c(x)` always, and arm a1 measures it on eight spellings.

The one place the dropped node is not empty is `a.b[1].c(x)`: there the sibling
of the second name is a `Constant_bit_select` that HAS a child, and
`compileTfCallArguments` compiles that child — so golden's argument is the
INDEX `1`. Our emitter already modelled that (`sg1.idx`, `src/ExprEmit.cpp`
~14770); arm a1 cell `S3j` confirms it byte for byte.

## 4. WHY THE HEAD SURVIVED THE EXISTING MODEL — THE DISCRIMINATOR, ISOLATED

The collapse above has been in this emitter since before this pass
(`src/ExprEmit.cpp` ~14759, `callStmtCtx0 && deepRecv11 && segs11.size() > 1`).
**43 of arm a1's 44 cells** — 2/3/4 components, statement and expression, void
function and task, class in-body / out-of-body / package / module function /
module `initial`, `this.`, an index in the base, an index in the middle,
parens-less, `void'(…)` — already agree with golden, before and after; the 44th
is `super.` (residue R-S).

What the head had that a1 did not is a **type parameter defaulting to a
non-class**: `TRANSFORMER=int`, so `m_transformer.transform(b)` cannot bind.
Arm a3 isolates exactly that axis and nothing else:

| cell | written statement | argument binds? | pristine | golden |
|---|---|---|---|---|
| `G2ok` | `el.put(31)` | yes | `mfc put` / prefix `el` / arg | same |
| `G3ok` | `bo.slot.put(32)` | yes | `mfc slot` / prefix `bo` / no arg | same |
| `G4ok` | `cr.bx.slot.put(33)` | yes | `mfc bx` / prefix `cr` / no arg | same |
| `G2bad` | `el.put(tp.conv(kk))` | **no** | `hier_path el.put` | `mfc put` / prefix `el` / **arg KEPT** |
| `G3bad` | `bo.slot.put(tp.conv(kk))` | **no** | `hier_path bo.slot.put` | `mfc slot` / prefix `bo` / no arg |
| `G4bad` | `cr.bx.slot.put(tp.conv(kk))` | **no** | `hier_path cr.bx.slot.put` | `mfc bx` / prefix `cr` / no arg |
| `G3mem` | `bo.slot.put(tp.fld)` | **no** | `hier_path bo.slot.put` | `mfc slot` / prefix `bo` / no arg |

Golden's answer does not depend on the argument **at all** — which is what makes
the shell, and only the shell, the defect. slang's own diagnostics are
suppressed inside a generic class's default specialization, so the whole loss
was **silent**: the pristine binary compiles `g103_a2.sv` and `g103_a3.sv` with
no error at all.

After the patch: a3 DEF view 11 differing cells → **1**, a2 DEF view 3 → **0**,
a1 unchanged (`pristine-vs-patched` is 0 lines in both views).

## 5. THE FENCE, ENUMERATED FROM THE DATABASES BEFORE THE CODE

`PREDICTION.txt` + `fence103.sh` + `goldcen103.sh`. The fossil is exact and
enumerable — a `hier_path` whose last `Path_elem` is a call, occupying a
STATEMENT slot — and the calibration is golden-vs-golden FIRST:

| | scanned | `HPCALL` rows | of them `POS=STMT` |
|---|---|---|---|
| GOLDEN, surelog corpus | 1 516 distinct goldens | 322 533 | **0** |
| GOLDEN, uhdm2rtlil corpus | 1 460 distinct goldens | 20 | **0** |
| OURS pristine, uhdm2rtlil | 1 358 databases | — | **0 rows / 0 DBs** |
| OURS pristine, surelog | 956 databases | — | **29 rows / 9 DBs** |

> `default/BuildUVMPkg` `testflags/BuildUVMPkg` `default/MiniAmiq`
> `testflags/MiniAmiq` `default/SeqDriver` `testflags/SeqDriver`
> `default/SimpleUVM` `testflags/SimpleUVM` `default/Scoreboard`
> (Scoreboard's testflags row is `SLANG_REJECT`)

`byteverify` moved **exactly those nine and no others**, and the order-blind
per-database attribution names only the fence's own source lines (GATES.txt §5).

## 6. GATES

All green — see `GATES.txt` for the full battery with its numbers, including the
negative control (`SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL), the `cmds.txt`
binary audit, the four boundary runs and the coin attribution.

## 7. RESIDUES, named for the queue

**R0 — THE NEW HEAD of SimpleUVM ×2 and Scoreboard/default (22 lines, 1 head,
the SAME object in all three row-modes).** A variable declared with the
enclosing class's own **unspecialised type parameter**:

```
LHS  unsupported_typespec: (REQ)  @270:3-270:6
       |vpiName:REQ
       |vpiInstance: \_package: uvm_pkg
RHS  class_typespec:              @270:3-270:6
       |vpiClassDefn: \_class_defn: (uvm_pkg::uvm_sequence_item)
```

`uvm-1.2 seq/uvm_sequencer_param_base.svh` — `class uvm_sequencer_param_base
#(type REQ = uvm_sequence_item, …)` at `:31`, and its **OUT-OF-BODY** body
`function void uvm_sequencer_param_base::send_request(…)` at `:267` whose first
line, `:270`, is `REQ param_t;`. Golden leaves the `ref_typespec`'s `vpiActual`
an `unsupported_typespec` NAMED `REQ` and INSTANCED at the package; we resolve it
to REQ's DEFAULT, `uvm_sequence_item`, and emit a `class_typespec`. `VpiType`
again, `BaseClass::Compare`'s first test. Population: golden's SimpleUVM dump
holds 2 119 `unsupported_typespec` lines to our 2 075, and `REQ` alone accounts
for 40 of golden's.

**R-R — a dropped call whose RECEIVER is MORE THAN ONE component**
(§ `droppedCall14`'s shape predicate takes an `IdentifierName` left only). Arm
a3 cell `G3rcv`, `tp.bx.slot.put(34)` where `tp` is the type parameter: golden
is the ordinary collapse — `method_func_call (bx)` @c31 with `vpiPrefix`
`ref_obj (tp)` @c28 and no argument — and we emit a **bare `ref_obj (tp)` as the
statement**. Not corpus-visible today (the fence found no such site), and
untouched by this pass; the golden answer is now measured, so it is ready to
model.

**R-S — `super.<member>.<method>()` in statement position.** Arm a1 cell `S3s`,
the one cell of that arm that differs in both binaries: golden is
`method_func_call` **named `"super"`**, located at the FIRST name after the
keyword (`@c33`), with an UNPARENTED STRING constant `"super"` as `vpiPrefix` —
the exact mirror of § `thisRecvCall11`'s `this.` arm — and we emit
`method_func_call (one)` with `vpiPrefix ref_obj (bm)`. `superRoot11`
(`src/ExprEmit.cpp` ~14378) deliberately abstained because the shape had never
been measured. **It is measured now**, on golden, in both views.

**R-A — the argument residues that survive under the moved calls.** At
`uvm_misc.svh:720`/`:725` the concatenation argument still loses two operands on
our side (`FIELD` and `TYPE::type_name` inside `{…}`), and two macro-expanded
`` `uvm_file ``/`` `uvm_line `` constants carry different spans. Both are
PRE-EXISTING (byte-identical between the pristine and patched databases) and
belong to § `typeParamScopedCallRef59`'s family, not this one.

**R-M — the ELAB copy count.** Arms a2/a3 in the `-elabuhdm` view still differ
from golden only by MULTIPLICITY (our extra ELAB copy of a class body); every
SHAPE matches. A pre-existing family: a1's 46 ELAB lines are identical in the
pristine and patched binaries.

## 8. FILES

```
README.md                       this file (the decoded law)
GATES.txt                       the whole gate battery with its numbers
GRID.txt                        the golden grid, both views, cell by cell
PREDICTION.txt                  the fence, written from PRISTINE databases only
PREDICTION.fence_pristine_surelog.tsv       the 29 fossil rows, by database
PREDICTION.fence_pristine_uhdm2rtlil.tsv    empty — the predicted NONE
head_pris_default_SimpleUVM.cmp the whole 108-line head this pass cut
head_pat_default_SimpleUVM.cmp  the whole 22-line head it left  (R0)
head_pat_default_Scoreboard.cmp the same head in the Scoreboard row
g103_a1.sv                      44-cell grid: components x position x carrier x home
g103_a2.sv                      the head's own shape (generic class, unbindable arg)
g103_a3.sv                      the discriminator, isolated on ONE axis
r10uvm103cen.cpp                the dotted-call census (MFC / HPCALL / BARESTMT)
grid103.sh                      builds a grid arm's 3 databases in BOTH views
fence103.sh                     enumerates the fossil over a sweep workdir
goldcen103.sh                   golden-vs-golden calibration over every golden
bound103.sh                     the boundary gate (a verbatim copy of bound23.sh)
byteverify.sh canaries.sh ctcan2.sh canaudit.sh rowheads.sh ct8rows.sh
                                the standing gate instruments, copied so this
                                directory can re-run its own battery
```
