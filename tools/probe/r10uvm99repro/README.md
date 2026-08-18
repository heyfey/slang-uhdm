# r10uvm99 — § `insideSetFirstRangeTruncates99` — the SeqDriver/MiniAmiq head CUT 50 → 13

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `40a0097` |
| worktree | `/tmp/wt_r10uvm99` |
| pristine binary | md5 `213ee8e1cada6a1013f277e4f7f7c8d2`, frozen `chmod 555` |
| patched binary | md5 `73e9b33d1cd399d1ef0cc60d2292cc00`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` ONLY — one file-static gate (`insideTrunc99`) and the `ExpressionKind::Inside` arm |
| probe surface | `tools/probe/r10uvm99repro/` only |

## READ THIS FIRST — the head, and a CORRECTION to uvm98's R0

| row-mode | pristine cmp lines | patched | heads | note |
|---|---|---|---|---|
| SeqDriver default / testflags | **50** | **13** | 1 | R0 CLEARED |
| MiniAmiq default / testflags | **50** | **13** | 1 | R0 CLEARED |
| SimpleUVM default / testflags | 108 | **108** | 1 | head was **NEVER** this family |
| Scoreboard default | 108 | **108** | 1 | head was **NEVER** this family |
| BuildUVMPkg default / testflags | 166 | 166 | 1 | unchanged (bytes moved, head masked) |
| Earlgrey_0_1 default / testflags | 216 | 216 | 1 | unchanged |
| Rggen default | 194 | 194 | 1 | unchanged |
| corpus rows changed | — | **0** (both corpora, both modes) | | |

**CORRECTION, measured, not remembered.** uvm98's README named this family as
the head of *all seven* UVM row-modes. It is the head of **four** of them
(SeqDriver ×2, MiniAmiq ×2, the 50-line ones). **SimpleUVM ×2 and
Scoreboard/default never had this head**: their 108-line head is a different
family entirely and is byte-identical before and after this pass —

```
LHS  method_func_call: (before_export), id:121142, line:131:10, endln:131:23
     |vpiParent: \_function: (uvm_pkg::uvm_algorithmic_comparator::write)
     |vpiPrefix: \_ref_obj: (…::write::comp) @131:5-131:9
RHS  (empty)
```

(`head_pat_default_SimpleUVM.cmp`, the whole 108 lines). The `inside` family
was present in those two databases too and is **MASKED** behind that head; the
census below proves it moved TO GOLDEN there anyway, and byteverify names both
as movers.

`head_pris_default_SeqDriver.cmp` is the old 50-line head (identical to the
`head_pat_default_SeqDriver.cmp` uvm98 committed);
`head_pat_default_SeqDriver.cmp` here is the whole NEW 13-line one (**R0**).

## The head, decoded from `BaseClass.h` + the generated `operation::Compare` FIRST

`operation::Compare`
(`~/git-repos/UHDM/build/generated/src/operation.cpp:98`) reads, in order,
`VpiOpType`, `VpiReordered`, `VpiFlattened`, `VpiOpStrong`, then
`SafeCompare(Operands())`. The VECTOR overload
(`~/.local/include/uhdm/BaseClass.h:202`) returns on a size mismatch naming the
two OWNERS; here both sides have **2** operands, so it descends to element 1
and calls the SINGULAR overload (`:187`) → `BaseClass::Compare`, whose VpiType
arm sets `m_failedLhs` AND `m_failedRhs` — which is exactly the head we see, an
element PAIR under a shared parent:

```
LHS  ref_obj: (uvm_pkg::uvm_domain::jump::UVM_PHASE_STARTED), line:199:64-199:81
     |vpiParent: \_operation: 199:38-199:101
RHS  operation: 199:63-199:100  |vpiOpType:37   (vpiListOp)
     |vpiParent: \_operation: 199:38-199:101
     |vpiOperand: ref_obj (UVM_PHASE_STARTED) @199:64-199:81
     |vpiOperand: ref_obj (UVM_PHASE_CLEANUP) @199:82-199:99
```

The owner is `uvm-1.2 base/uvm_domain.svh:199` in
`function void uvm_domain::jump(uvm_phase phase)`:

```systemverilog
phases = phases.find(item) with (item.get_state() inside {[UVM_PHASE_STARTED:UVM_PHASE_CLEANUP]});
```

columns 38–101 are `item.get_state() inside {[…]}`, 63–100 are `[A:B]`, 64–81
`UVM_PHASE_STARTED`, 82–99 `UVM_PHASE_CLEANUP` — all read off the source, not
assumed.

## The law

> **§ `insideSetFirstRangeTruncates99` — AN `inside` SET IS TRUNCATED TO ITS
> FIRST MEMBER'S FIRST PRIMARY THE MOMENT ANY MEMBER IS A `[a:b]` RANGE.**
>
> `CompileHelper::compileExpression`
> (`src/DesignCompile/CompileExpression.cpp`) has exactly ONE arm for `inside`,
> at **`:2339` (`if (opType == VObjectType::paINSIDE)`)**. Its own comment says
> what parse it was written for — *"Because open_range_list is stored in `{ }`,
> it is being interpreted as a concatenation operation"* — and it reaches the
> set members as
>
> ```cpp
> NodeId false_concat = fC->Child(fC->Child(rval));   // :2362
> NodeId Expression   = fC->Child(false_concat);      // :2363
> while (Expression) { … operands->push_back(exp); Expression = fC->Sibling(Expression); }
> ```
>
> `rval` is the node after the `INSIDE` token in
> `expression INSIDE OPEN_CURLY open_range_list CLOSE_CURLY`
> (`grammar/SV3_1aParser.g4:3525`). **Two different parses land there**, and
> `-d ast` names them:
>
> | source | `rval` | `Child(Child(rval))` | operands the loop pushes |
> |---|---|---|---|
> | `y inside {1, 2, 3}` (**no range**) | `Expression`→`Primary`→**`Concatenation`** | the Concatenation | **every member**, each compiled whole |
> | `y inside {[1:3]}` / `{4, [6:8], 11}` (**some range**) | **`Open_range_list`** | the FIRST `Value_range`'s FIRST `Expression` | **that Expression's CHILDREN** |
>
> A `Value_range` for `[A:B]` has the two bound `Expression`s as its children,
> so `Child(Child(Open_range_list))` is the `Expression` for **A**; a PRIMARY
> `Expression` has exactly ONE child and no siblings, so the loop pushes
> **one** operand. The inside operation therefore ends up with exactly TWO
> operands — the LHS and the first member's first bound — and **the upper bound
> and every later member are DROPPED**.
>
> It is a Surelog bug. **Golden is the spec, bugs included** — we MODEL it, we
> do not fix it.
>
> **THE FENCE IS THE PARSE.** A set with no `[a:b]` member is a Concatenation
> and golden flattens all of it — which is what our pristine emitter already
> did, so the model is the **IDENTITY** there. Both `uhdm2rtlil` tests that use
> `inside` (`OneInside`, `GenIfInside`, both CMP_EQUAL rows) are range-free,
> which is why the whole corpus cannot move a byte.
>
> **NOT MODELLED (residue R1).** When the first bound is NOT a primary
> (`{[pv+1:pv+4]}`), Surelog's `Child()` walk descends INTO it and splices that
> expression's own sub-nodes — plus an `unsupported_expr` carrying the operator
> token — into the operand list. Such a set keeps the PRISTINE emission: a
> no-op, never a wrong operand list. `insideTrunc99` returns `nullptr` for
> `UnaryOp/BinaryOp/ConditionalOp/Inside/Assignment/Dist/MinTypMax/TaggedUnion`.
>
> **NOT THIS ARM.** `case … inside` items are built by `StmtEmit.cpp:3255`
> (every member wrapped in its own `vpiListOp`, golden's shape, arm a4) and
> constraint bodies produce no operation in golden at all (arm a3). Neither
> path is touched; `ExpressionKind::ValueRange`'s own `vpiListOp` mint is left
> exactly as it was, because case-inside depends on it.

**Provenance of the shape we replace:** the `vpiListOp` mint came in with
commit `04660102` *"Inside operator + case-inside statements"*, whose own arms
are `OneInside` (range-free → the fence) and `CaseInside` (the StmtEmit path).
Both stay byte-identical here (`byteverify` MOVERS **0 / 1358**).

## The grid, golden-side, ten arms × both views (`three99.sh`, `GRID.r10uvm99.txt`)

Every cell is scored TWICE — **MULTISET** (the dump's copy multiplicity kept)
and **SET** (dropped) — because a golden object reachable through two parents
prints twice and that is not this family.

| arm | what it pins | golden's answer | def | elab |
|---|---|---|---|---|
| `g99_a1_ifcond.sv` | **the law, minimised**: eight `if (…)` conditions — `[1:3]`, `{4,[6:8],11}`, param bounds, `[1:$]`, `{7}`, a queue, `{pv+1,5}`, `[pv+1:pv+4]` | 2 operands wherever a range appears; the WHOLE set wherever none does | FIXED 8 BROKE 0 | FIXED 8 BROKE 0 |
| `g99_a2_proc.sv` | cont-assign, net init, `always_comb`, `always @(*)`, task `if`, `while`, ternary, `initial` | same rule in every one | **PASS_CMP**, FIXED 15/16 BROKE 0 | **PASS_CMP**, FIXED 15/16 BROKE 0 |
| `g99_a3_constr.sv` | `constraint { x inside {…}; }`, `dist { [1:3] := 1 }` | golden emits **no operation at all** — and neither do we | PASS_CMP → PASS_CMP, 0 cells | PASS_CMP → PASS_CMP, 0 cells |
| `g99_a4_caseins.sv` | `case (…) inside` with `[1:3]`, `4,[6:8]`, `9` | every member in its OWN `vpiListOp` — a DIFFERENT shape, already ours | PASS_CMP, **ALREADY-OK 7, FIXED 0** | same |
| `g99_a5_with.sv` | the WITH clause of `find` / `find_index` / `find_first` / `find_last` / `unique` / `min` / `max` / `sum`, on a QUEUE and a DYNAMIC ARRAY, class and module scope | **the with clause is NOT a discriminator** — identical rule | FIXED 22 BROKE 0 | FIXED 16 BROKE 0 |
| `g99_a6_assert.sv` | immediate `assert`, a named `property`, an inline `assert property` | same rule | **PASS_CMP**, FIXED 4 BROKE 0 | **PASS_CMP**, FIXED 4 BROKE 0 |
| `g99_a7_shapes.sv` | exotic members: package params, `nn+mm` first, `[nn*2:mm+1]`, a `?`-wildcard literal, `q[0]` first, strings, a bare queue, two `inside`s in one expression | primaries truncate, compound first bounds SPLICE (R1) | FIXED 8 BROKE 0 | FIXED 8 BROKE 0 |
| `g99_a8_class.sv` | class-scope method, an OUT-OF-BLOCK method body, three live instances | same rule, DEF and ELAB copies alike | **PASS_CMP**, FIXED 4 BROKE 0 | FIXED 3 BROKE 0 |
| `g99_a9_fence.sv` | **THE FENCE** — ten `inside` sets, NONE with a range, in nine contexts | golden flattens all of them, exactly as we already did | PASS_CMP → PASS_CMP, **FIXED 0 BROKE 0** | same |
| `g99_a10_other.sv` | covergroup `bins {[0:3]}` / `{4,[5:7]}`, `case inside` beside an ordinary `case`, a COMPOUND LHS `(av+bv) inside {[1:4]}`, a negated `inside` | bins and case-inside untouched; the compound LHS stays WHOLE at operand 0 | **PASS_CMP**, FIXED 4 BROKE 0 | **PASS_CMP**, FIXED 4 BROKE 0 |

**`BROKE` is 0 in all 40 runs** (10 arms × 2 views × 2 scorings). `a9`, the
fence, and `a3`/`a4` move NOTHING — the model is the identity wherever the set
has no range, which is the whole safety argument. **Five arms convert
`CMP_FAIL` → `PASS_CMP`** (a2, a6, a8/def, a10, both views) and **no arm that
passed pristine fails patched**.

The two `STILL` cells in a1/a7 are R1 (`[pv+1:pv+4]`, `[nn99*2:mm99+1]`); the
`STILL` cells in a5/elab and a8/elab are a pre-existing ELAB copy-and-naming
family (golden carries an extra copy whose ref is named
`…::mfind::dyn99::jtx` / `work@mu99.oob.qv`), untouched by this pass.

## The corpus census, three-way, keyed on what the judge reads

`opcen99.py` + `cen99.sh`. One row per `operation` with `vpiOpType` **95**
(`vpiInsideOp`) or **37** (`vpiListOp`) **in the `uhdm-dump` tree** — the dump
is exactly the REACHABLE tree, so no row can name an object the judge cannot
see (uvm97's `AllObjects` trap). Key = (SITE, nearest named ancestor + the
operation's span); value = operand count + each operand's kind / op type /
span. Never the file, never the source text.

**Calibrated golden-vs-golden FIRST**: SeqDriver's `default` and `testflags`
goldens produce **51 rows each and 0 differing lines** — the key is
view-general and the instrument manufactures no cells.

```
default/SeqDriver-32af76aa         [MULTISET] cells    49  ALREADY-OK    46  TO-GOLDEN   2  AWAY-GOLDEN   0  STILL    1
testflags/SeqDriver-32af76aa       [MULTISET] cells    49  ALREADY-OK    46  TO-GOLDEN   2  AWAY-GOLDEN   0  STILL    1
default/SimpleUVM-1dc93a62         [MULTISET] cells    47  ALREADY-OK    45  TO-GOLDEN   2  AWAY-GOLDEN   0  STILL    0
testflags/SimpleUVM-1dc93a62       [MULTISET] cells    47  ALREADY-OK    45  TO-GOLDEN   2  AWAY-GOLDEN   0  STILL    0
default/MiniAmiq-544c7f61          [MULTISET] cells    56  ALREADY-OK    53  TO-GOLDEN   2  AWAY-GOLDEN   0  STILL    1
testflags/MiniAmiq-544c7f61        [MULTISET] cells    56  ALREADY-OK    53  TO-GOLDEN   2  AWAY-GOLDEN   0  STILL    1
default/Scoreboard-59431470        [MULTISET] cells    47  ALREADY-OK    45  TO-GOLDEN   2  AWAY-GOLDEN   0  STILL    0
default/BuildUVMPkg-bf853d43       [MULTISET] cells    13  ALREADY-OK    11  TO-GOLDEN   2  AWAY-GOLDEN   0  STILL    0
testflags/BuildUVMPkg-bf853d43     [MULTISET] cells    13  ALREADY-OK    11  TO-GOLDEN   2  AWAY-GOLDEN   0  STILL    0

(SET scoring is identical on all nine — see CENSUS.r10uvm99.txt)
```

**`AWAY-GOLDEN 0` on every database and both scorings.** Exactly **2**
TO-GOLDEN cells per database: the `INSIDE` cell at `uvm_domain.svh:199` and the
`LISTOP` cell that disappears with it — `listop=1` per database, which is why
`inside=22..58` other sites per database cannot move.

The SeqDriver/MiniAmiq `STILL` cell is `uvm_sequencer_base.svh:664`
(`item.process_id.status inside {process::KILLED, process::FINISHED}` — a
range-free set both sides flatten identically); it differs only in how golden
SCOPES the two enum refs (`…::arb_sequence_q::process::KILLED` vs our
`…::process::KILLED`). A naming family, **R3**, not this one.

## The mover set, PREDICTED BY NAME first (`PREDICT.r10uvm99.txt`)

`pred99.cpp` reads **only OUR PRISTINE databases** — never golden, never the
patched binary. Our pristine emitter renders every `[a:b]` set member as an
`operation(vpiListOp)` operand, so a database with no `vpiInsideOp` carrying a
`vpiListOp` at operand index ≥ 1 (index 0 is the bare LHS in the expression
arm; a CASE-INSIDE op has a list-op at index 0 and is excluded by that test)
**cannot move**.

```
uhdm2rtlil: PREDICTED 0 / 1358 databases   <- THE FENCE, and it is NOT vacuous:
                                              OneInside and GenIfInside DO carry
                                              `inside` expressions — both range-free
surelog   : PREDICTED 9 / 956  databases   (each with listop=1, inside=22..58)
```

`byteverify SELFCHECK=1` then measured **`MOVERS 0 / 1358`** on uhdm2rtlil and
**`MOVERS 9 / 956`** on surelog — **exactly the nine predicted, zero
unpredicted**, and all nine were already `CMP_NOTEQUAL` rows:

```
default/{BuildUVMPkg,MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}
testflags/{BuildUVMPkg,MiniAmiq,SeqDriver,SimpleUVM}
```

Each mover's path-normalised, id-stripped whole-dump diff is **17 lines
ORDER-BLIND on all nine** (`attrib99.sh`); `SeqDriver` (57 ordered) and
`Scoreboard/default` (187 ordered) are the known ~50/50 COIN, and their
order-blind share is the same 17. The lines are the `vpiOpType:37` wrapper and
its second operand `UVM_PHASE_CLEANUP` leaving the tree, and the bare
`UVM_PHASE_STARTED` `ref_obj` taking its place at operand 2 — nothing else.

**Determinism**: the patched binary was run three times on SeqDriver —
`214814ec27a344553bc42989020b5e64` ×3, byte-identical, and equal to the sweep's
database.

## Gates

`GATES.r10uvm99.txt` has the full transcript. Summary: goldens **23/0** on both
binaries and **0/23** for `/bin/false`; u2r **679/50/2** on both modes and both
binaries; surelog `--mode both` **470/283/25/11/5** default and
**466/284/23/9/5/3/2/1/1** testflags, identical on both binaries — in fact all
three CSVs are **byte-identical pristine vs patched**; `ct8rows` **PASS, 0
differing rows** against the committed baselines AND against my own pristine
sweeps (u2r both modes, surelog 1588 rows) — **NO ROW CONVERTED, nothing
promoted**; `cmds.txt` audited by binary PATH (1523 surelog / 1458 u2r per
sweep, nothing else); `byteverify SELFCHECK=1` u2r **0/1358** (selfcheck
1357/1358), surelog **9/956** (selfcheck 955/956), all nine predicted by name
first and each attributed line by line; canaries `ok=52` / `ok=8`
`changed=0`, `ctcan2` PASS on both, `canaudit audited=33 UNCOVERED=0
FENCE-BREACH=0`; pins `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr`
**SAME**, `SVSwitch` **4842211c4030**, `YosysVerx` **6ccda350c24a**,
`SAME=10 MOVED=0`.

## The boundary (`BOUNDARY.r10uvm99.txt`)

From a **COPY** of the whole `tools/probe` tree, **no path filter**, `.sv`
**and** `.v`, fd-3 list, children `</dev/null`, PROCESSED asserted, rc recorded
and compared per cell, **both views**:

```
LISTED=3182 FENCED_SKIPPED=0 PROCESSED=3182 PROCESSED-ASSERT-OK
RC_PAIRS_COMPARED=6364  RC_DIFF=0  ASYMMETRIC_OUTPUT=0  MOVED=16
```

**14 of the 16 are my own arms** (a1, a2, a5, a6, a7, a8, a10 × 2 views) —
which is the gate's positive control: it can see. `a3`, `a4` and `a9` do NOT
move, in either view.

**The one non-own mover, attributed three-way against golden, BOTH views:**

| arm | verdict |
|---|---|
| `r10uvm92repro/v92_b1_break.sv` | **cmp head BYTE-IDENTICAL pristine vs patched** (18 lines, 1 head, both views); census FIXED 2 BROKE 0; the whole 50-line dump delta is two `vpiListOp` wrappers leaving two `inside` operand lists. **No `vpiName` / `vpiFullName` / `hier_path` line moves** — uvm92's `§ hpIdxOpPrettyPrint92` index-decompile text is untouched. |

uvm92's boundary law ("only cells your law names may move") holds: the moved
cells are `inside` operand lists and nothing else.

## Residues, named for the queue

**R0 — THE NEW HEAD of SeqDriver ×2 / MiniAmiq ×2 (13 lines, 1 head).** A
`ref_obj` golden has and we do **not emit at all** (`RHS: <null>`), in
`uvm-1.2 base/uvm_objection.svh` at `1260:15-1260:27`:

```
LHS  ref_obj: (uvm_pkg::uvm_test_done_objection::all_dropped), id:306155, line:1260:15, endln:1260:27
     |vpiParent: \_begin: (uvm_pkg::uvm_test_done_objection::all_dropped), line:1257:11-1264:14
     |vpiFullName:uvm_pkg::uvm_test_done_objection::all_dropped
RHS: <null>
```

`head_pat_default_SeqDriver.cmp` is the whole 13-line head. Per `BaseClass.h`'s
SINGULAR `SafeCompare` (`:191`), `RHS: <null>` means golden has an object in
that slot and we have none — a MISSING object, not a wrong one.

**Decoded from both dumps** (so the next pass starts with the model, not the
symptom). The site is `` `uvm_delay(stop_timeout) `` at
`uvm-1.2 base/uvm_objection.svh:1260`, inside the `fork` at `:1250-1265`;
`` `define uvm_delay(TIME) #(TIME); `` (`uvm_macros.svh:66`):

```
golden   \_delay_control: , line:1260:13, endln:1260:28      <- spans `#(stop_timeout)`
           |vpiDelay:
           \_ref_obj: (…::all_dropped), line:1260:15, endln:1260:27   <- NO vpiName at all
ours     \_delay_control: , line:1260:15, endln:1260:27      <- our span is the ARGUMENT's
           (no vpiDelay field emitted)
```

So R0 is two things at once: our `delay_control` takes the delay
EXPRESSION's span where golden takes the whole `#(…)`, and we emit **no
`Delay`** — and golden's `Delay` is a **NAMELESS `ref_obj`** (the dump's
`vpiFullName` there is the enclosing scope's, synthesized from the parent
chain, not the object's own name).

**R1 — the SPLICE half of this very law, deliberately NOT modelled.** A first
bound that is not a primary (`{[pv+1:pv+4]}`, `{[nn*2:mm+1]}`) makes Surelog
walk INTO it: golden's operand list becomes `LHS, pv, unsupported_expr(“+”), 1`
(arm a1 `k8`) or `LHS, nn99, 2` (arm a7 `h3`, where `*` yields nothing at all
while `+` yields an `unsupported_expr`). Modelling it needs the operator-token
object and the per-operator asymmetry, which this pass measured but did not
guess at. **No corpus reach** (all nine movers are single-primary bounds).

**R2 — SimpleUVM ×2 / Scoreboard/default head, 108 lines, unchanged.** The
`method_func_call (before_export)` in `uvm_algorithmic_comparator::write`
(`131:10-131:23`), whose golden `vpiPrefix` is a `ref_obj (…::write::comp)`;
our side is empty. `head_pat_default_SimpleUVM.cmp` is the whole head.

**R3 — the `inside`-operand enum scoping family.** At
`uvm_sequencer_base.svh:664` golden names the two `process::` enum refs
`…::grant_queued_locks::arb_sequence_q::process::KILLED/FINISHED` and we name
them `…::grant_queued_locks::process::KILLED/FINISHED`. The set is range-free,
so both sides flatten identically — it is a NAMING family, the one `STILL`
cell of the SeqDriver/MiniAmiq census.

**R4 — the ELAB copy count of an `inside` in a with-clause / out-of-block
method.** Golden carries an extra ELAB copy whose operand-0 ref is scoped
through the array (`…::mfind::dyn99::jtx`, `work@zeta99b.mq99.ktx`) or through
the instantiating module (`work@mu99.oob.qv`); we emit one copy. Arms a5/elab
and a8/elab. Not this family; recorded because the arms show it.

**R5 — the `hier_path` index decompile of an `inside`** (uvm92's family):
golden's `nest.slot[k inside {1}]` vs our `nest.slot[k inside {}]`. Our operand
list now MATCHES golden's, but the name text does not follow it — the text is
minted elsewhere. Arm `r10uvm92repro/v92_b1_break.sv`; unchanged by this pass.

## Files

```
opcen99.py     the INSIDE/LIST-OP census, read off a uhdm-dump text tree
               (reachable objects only).  OPS99=95,37 selects the op types.
cen99.sh       run the census three-way (golden / pristine / patched) over one
               (mode, test) of a verify_golden workdir; golden is read from
               that test's OWN cmds.txt
three99.sh     three-way arm scorer, golden / pristine / patched, rc recorded,
               scored MULTISET and SET
pred99.cpp     the a-priori mover predictor, from OUR PRISTINE databases only
predict99.sh   run it over a workdir and name every (mode, test) that CAN move
attrib99.sh    attribute one mover: path-normalised id-stripped whole-dump
               diff, ORDERED and ORDER-BLIND
bound99.sh     the wide boundary gate (fd-3 list, children </dev/null,
               PROCESSED asserted, per-cell rc compared, both views, no path
               filter, .sv AND .v)
g99_a1..a10    the ten golden arms (a3/a4/a9 are the fences)
CENSUS / GRID / GATES / BOUNDARY / PREDICT .r10uvm99.txt   the measurements
head_pris_default_SeqDriver.cmp   the OLD head, whole (50 lines)
head_pat_default_SeqDriver.cmp    the NEW head, whole (13 lines) = R0
head_pat_default_SimpleUVM.cmp    the SimpleUVM/Scoreboard head, whole
                                  (108 lines, unchanged) = R2
byteverify.sh canaries.sh ctcan2.sh canaudit.sh ct8rows.sh rowheads.sh pins99.sh
               carried forward unchanged from r10uvm98repro / r10oth{4,8}repro /
               r10uvm{52,67}repro
```
