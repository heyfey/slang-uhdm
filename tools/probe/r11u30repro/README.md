# r11u30 — § `insideOpenRangeMemberIsOneListOp30` — an `inside` value range is ONE `vpiListOp` operand

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang,
Surelog, UHDM and uhdm2rtlil were **NOT** patched; `results/*.csv` were **READ
ONLY**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `4110f3de` (branch `matrix-1.87`) |
| worktree | `/tmp/wt_r11u30` |
| pristine binary | md5 `62547ac98ebcfdeb522171dc946d50ad` — byte-identical to the main tree at the base |
| patched binary | md5 `0fc7b2ec16a79f41b5bc73ef10275de1` |
| production surface | `src/ExprEmit.cpp` ONLY — two file-static helpers and the `ExpressionKind::Inside` / `ExpressionKind::ValueRange` arms |
| probe surface | `tools/probe/r11u30repro/` only |
| target | r11u29 TRIAGE.md cluster **K1** (5 tests / 9 rows), its top dispatch target |

## 0. READ THIS FIRST — the head, re-measured, and the site the triage suspected

The nine target rows carry ONE head each, 50 `uhdm-cmp` lines, and with object
ids and source locations blinded all nine are **the same text** (md5
`f54de5e82fdaf630e4a1628e437ee95d` over the id/line-blinded `.cmp`):

```
LHS (golden)                                   RHS (ours)
operation: 199:63-199:100                      ref_obj: (…::jump::UVM_PHASE_STARTED) 199:64-199:81
|vpiParent: \_operation: 199:38-199:101        |vpiParent: \_operation: 199:38-199:101   <- the SAME outer op
|vpiOpType:37                    (vpiListOp)   |vpiName:UVM_PHASE_STARTED
|vpiOperand: \_ref_obj (…UVM_PHASE_STARTED)
|vpiOperand: \_ref_obj (…UVM_PHASE_CLEANUP)
```

The owner is `uvm-1.2 base/uvm_domain.svh:199`:
`phases = phases.find(item) with (item.get_state() inside {[UVM_PHASE_STARTED:UVM_PHASE_CLEANUP]});`

**The triage's suspected site is REFUTED.** `src/TypeEmit.cpp:16987` (the
`InsideExpression` arm of `emitSyntaxExpr`) produces none of it: every head and
every grid cell this pass moves comes from the **AST** arm,
`src/ExprEmit.cpp`'s `ExpressionKind::Inside`, and patching that one arm alone
moves all nine heads and 8 of the 13 grid arms from `CMP_FAIL` to `PASS_CMP`.
The triage's "there is no `OpenRangeExpression` arm anywhere in `src/`" grep
also asked for a name slang does not use: the syntax kind is
`SyntaxKind::ValueRangeExpression` and the AST kind is
`ExpressionKind::ValueRange`, and there HAS been a `ValueRange` arm in
`src/ExprEmit.cpp` all along — it mints exactly the `vpiListOp` golden shows.
What suppressed it was a LANDED LAW, not a missing arm.

## 1. The decode — Surelog v1.87 FIXED the bug r10uvm99 modelled

`CompileHelper::compileExpression`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp`) still has ONE
arm for `paINSIDE` (`:2340`), reached from
`expression INSIDE OPEN_CURLY open_range_list CLOSE_CURLY`
(`grammar/SV3_1aParser.g4:3525`), and **two different parses still land there**
— but v1.87 now branches on which one it got:

```cpp
:2350   if (fC->Type(rval) == VObjectType::paOpen_range_list) {
          NodeId Member = fC->Child(rval);
          while (Member) { operands->push_back(compileExpression(... Member ...)); … }
          break;                                    // RHS is done
        }
        // else: the false-Concatenation walk, unchanged
```

and its own comment (`:2340-2348`) names the bug it repairs — *"The old
navigation (`Child(Child(rval))`) then landed INSIDE the first `Value_range` and
compiled ONLY its low bound — `rm inside {[3'b000:3'b010]}` lost the range
entirely (CVA6 decoder FP rounding-mode checks flagged legal instructions
illegal)."* That lost-bound shape is precisely
§ `insideSetFirstRangeTruncates99`, the law `r10uvm99` landed against Surelog
v1.86 — correctly then, wrongly now. **This pass replaces it.**

The member compile lands in the `paValue_range` arm (`:1631`), which mints ONE
`operation(vpiListOp)` per member, populated from the `Value_range` node
(`populateCoreMembers(parent, parent, list_op)` — so its span is the member AS
WRITTEN, brackets included for a range), with the low bound and — only when the
member has a second `Expression` sibling — the high bound as operands.

## 2. The law

> **§ `insideOpenRangeMemberIsOneListOp30` — THE MOMENT ANY MEMBER OF AN
> `inside` SET IS A `[a:b]` RANGE, EVERY MEMBER OF THAT SET IS ONE
> `operation(vpiListOp)` OPERAND — TWO operands for a range, ONE for a plain
> value — and the set is otherwise unchanged.**
>
> **THE FENCE IS STILL THE PARSE.** A set with NO range member is a
> Concatenation: golden flattens every member BARE, which is what our pristine
> emitter already did, so the model is the IDENTITY there. Measured, not
> assumed: grid arm `a9` (ten range-free sets in nine contexts) is
> `PASS_CMP → PASS_CMP` with `FIXED 0 BROKE 0` and a whole-dump diff that is
> **87 lines before and the same 87 lines after**.
>
> **THE PARENT HALF.** A bound (or plain member) that IS a literal is compiled
> through Surelog's constant path, which never back-links: golden's list-op
> literal operands carry NO `vpiParent`. Anything deeper keeps the ordinary
> policy — `{[pv+1:pv+4]}` and `{n30+1, [2:3]}` DO parent the `1` to the `+`
> operation. `vpiParent` is read by no generated `Compare`, so this half is
> dump fidelity, not judge-visible; it is written because the whole-dump diff
> can see it and a landing is judged on bytes too.
>
> **NOT THIS ARM, and untouched:** a `case … inside` item
> (`src/StmtEmit.cpp:4864`, which already wraps every member in its own
> `vpiListOp` — arm `a4` is `ALREADY-OK 7 / FIXED 0` and its whole-dump diff
> against golden is **0 lines**, before and after), covergroup `bins`
> (arm `a10`, `ALREADY-OK`), and a CONSTRAINT body, for which golden emits no
> operation at all (arm `a3`: golden `op95=0 op37=0`).

**What the v1.87 fix also retires:** r10uvm99's residue R1 (a non-primary first
bound — `{[pv+1:pv+4]}` — which v1.86 spliced into the operand list with an
`unsupported_expr`). v1.87 compiles the compound bound whole (arm `a1` cell k8,
arm `a7` cell h3, arm `b2` cell m5), so **no member shape is left unmodelled**.

## 3. The golden grid — 13 arms × both views, every arm's rc recorded

Ten arms are `r10uvm99`'s (re-run against the v1.87 golden producer, which is
the point); three are new. `grid30.sh` drives the committed three-way scorer
`../r10uvm99repro/three99.sh` + `opcen99.py` (census key = the INSIDE/LISTOP
operation's nearest named ancestor + span; scored MULTISET and SET).
Full output: `evidence/GRID.r11u30.txt`.

| arm | what it pins | golden v1.87's answer | pristine → patched |
|---|---|---|---|
| `a1` if-conditions: `[1:3]`, `{4,[6:8],11}`, param bounds, `[1:$]`, `{7}`, a queue, `{pv+1,5}`, `[pv+1:pv+4]` | every member a list-op wherever a range appears; bare wherever none does | `CMP_FAIL → PASS_CMP`, FIXED 10 BROKE 0 STILL 0 (both views) |
| `a2` cont-assign, net init, `always_comb`, `always @(*)`, task `if`, `while`, ternary, `initial` | same rule everywhere | `CMP_FAIL → PASS_CMP`, FIXED 17 (SET) BROKE 0 |
| `a3` `constraint {…}`, `dist { [1:3] := 1 }` | **no operation at all** | `PASS_CMP → PASS_CMP`, 0 cells |
| `a4` `case (…) inside` with ranges | every member in its OWN list-op — already ours | `PASS_CMP`, ALREADY-OK 7, whole-dump diff **0** |
| `a5` `with` clause of find/find_index/find_first/find_last/unique/min/max/sum | the with clause is NOT a discriminator | FIXED 24 BROKE 0; head 54 → 17 lines (new head is a missing `logic_net`, another family) |
| `a6` immediate `assert`, named `property`, inline `assert property` | same rule | `CMP_FAIL → PASS_CMP`, FIXED 4 BROKE 0 |
| `a7` exotic members: package params, `nn+mm` first, `[nn*2:mm+1]`, `?`-wildcard, `q[0]` first, strings, bare queue, two `inside`s in one expression | compound bounds now compile WHOLE (R1 retired) | `CMP_FAIL → PASS_CMP`, FIXED 9 BROKE 0 |
| `a8` class method, out-of-block method body, three live instances | same rule, DEF and ELAB copies alike | `CMP_FAIL → PASS_CMP`, FIXED 4 BROKE 0 |
| `a9` **THE FENCE** — ten range-free sets in nine contexts | golden flattens all of them | `PASS_CMP → PASS_CMP`, FIXED 0 BROKE 0, whole-dump diff 87 → **87** |
| `a10` covergroup `bins {[0:3]}` / `{4,[5:7]}`, case-inside beside an ordinary case, compound LHS, negated `inside` | bins and case-inside untouched; the compound LHS stays whole at operand 0 | `CMP_FAIL → PASS_CMP`, FIXED 4 BROKE 0 |
| `b1` **NEW** — declaration contexts: net-decl assign, variable initialiser, subroutine DEFAULT ARGUMENT, class property initialiser, cont-assign | same rule in the reachable ones | FIXED 12 (SET) BROKE 0; residue is a FOLD family (below) |
| `b2` **NEW** — member shapes: `[1:$]`, `[$:9]`, five-member mixed sets, compound bounds both sides, function-call bounds, a select and a hierarchical bound, `?`-wildcard beside a range, strings, `inside` nested in `inside` | every one reproduced exactly | `CMP_FAIL → PASS_CMP`, FIXED 32 BROKE 0 STILL 0 |
| `b3` **NEW** — scopes: package function, interface, generate block, a module instantiated TWICE, a package class method, a task from `initial` | same rule in every scope | FIXED 18 (SET) BROKE 0; residue is a COPY-COUNT family (below) |

**`BROKE` is 0 in all 52 scorings** (13 arms × 2 views × 2 scorings), and no
arm that passed pristine fails patched. **Eight arm-views convert
`CMP_FAIL → PASS_CMP`** (a1, a2, a6, a7, a8, a10, b2 — both views each).

**Two elaboration-time contexts are UNREACHABLE on the golden side, measured
not assumed:** `inside` in a module parameter-port default, in a
`localparam`/`parameter` value, and in a GENERATE-IF condition are all SYNTAX
errors for Surelog (`constant_expression` has no INSIDE alternative; 10 syntax
errors, no database), so no such face can exist. `{[$:$]}` is refused by slang
itself ("value range cannot be unbounded on both sides"). Both removals are
recorded in the arm sources.

## 4. Fidelity beyond the judge — the whole-dump diff

`dumpdiff30.sh` (ids and the workdir path normalised away, `vpiParent` and
spans INCLUDED — the fields the official `Compare` cannot see).
`evidence/DUMPDIFF.r11u30.txt`:

```
g99_a1_ifcond_def    golden-vs-pris 100   golden-vs-pat   4
g99_a1_ifcond_elab   golden-vs-pris 164   golden-vs-pat   4
g30_b2_shapes_def    golden-vs-pris 367   golden-vs-pat   4
g99_a7_shapes_def    golden-vs-pris 164   golden-vs-pat  58
g99_a10_other_def    golden-vs-pris  44   golden-vs-pat   6
g99_a9_fence_def     golden-vs-pris  87   golden-vs-pat  87   <- THE FENCE: unchanged
g99_a4_caseins_def   golden-vs-pris   0   golden-vs-pat   0   <- case-inside: exact, before and after
```

Every line that survives on a1/b2 is the SAME pre-existing family the fence arm
carries with no range in sight: a RANGE-FREE set's bare constant operand gets a
`vpiParent` from our literal policy and golden's does not (`{7}`, `{pv+1,5}`,
`{"aa","bb"}`). a7's remaining 58 and a10's 6 are an imported-package
`ref_typespec` naming family and an `unsupported_typespec` span — both present
in the pristine diff, neither this law.

## 5. The mover set, PREDICTED BY NAME first

`pred30.cpp` + `predict30.sh` read **only OUR PRISTINE databases** — never
golden, never the patched binary. Our pristine emitter TRUNCATES a range-
carrying set, so the operation's own span still covers the whole written
`x inside { … }` while its last operand stops early: the gap between them is
the dropped text, and it names the movable databases without a golden byte.
(`evidence/PREDICT.r11u30.txt`)

```
uhdm2rtlil : PREDICTED 0 / 1608 databases  (6 carry an expression-inside at all)
surelog    : PREDICTED 9 /  960 databases  (13 carry an expression-inside at all)
             default/{BuildUVMPkg,MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}
             testflags/{BuildUVMPkg,MiniAmiq,SeqDriver,SimpleUVM}
```

The two zeroes have POSITIVE CONTROLS (`evidence/POSCONTROL.r11u30.txt`): the
six u2r databases that DO carry `inside` write range-free sets only
(`OneInside`, `GenIfInside`, `ibex_load_store_unit`, sources quoted); the same
predictor says `movable=3..5` on the nine surelog databases and `4/8` on grid
arm a1; and **Earlgrey_0_1** — a CMP_EQUAL-must-stay-equal row with a byte pin
— carries 14 (default) / 25 (testflags) expression-`inside` operations, all
range-free, and is predicted immovable. `SVSwitch`, the hard byte pin, writes
`inside` twice and one of them IS a range
(`third_party/tests/SVSwitch/Packet.sv:28`, `data.size inside {[1:250]}`) —
inside a CONSTRAINT, for which arm a3 measures golden emitting no operation at
all. The pin is safe by the measured shape, not by luck.

## 6. The corpus census, three ways, keyed on what the judge reads

`cen30.sh` + the committed `r10uvm99repro/opcen99.py`: one row per `operation`
with `vpiOpType` **95** or **37** in the `uhdm-dump` tree (the dump is exactly
the REACHABLE tree, so no row can name an object the judge cannot see).
**Calibrated golden-vs-golden FIRST** — the two MODE goldens of one test are
different cache entries: `SeqDriver` 52 rows each, `MiniAmiq` 59 rows each,
**0 differing lines** on both, so the key is view-general and manufactures no
cell. (`evidence/CENSUS.r11u30.txt`)

```
default/BuildUVMPkg    cells 13  ALREADY-OK 11  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 0
default/MiniAmiq       cells 56  ALREADY-OK 53  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 1
default/Scoreboard     cells 47  ALREADY-OK 45  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 0
default/SeqDriver      cells 49  ALREADY-OK 46  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 1
default/SimpleUVM      cells 47  ALREADY-OK 45  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 0
testflags/BuildUVMPkg  cells 13  ALREADY-OK 11  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 0
testflags/MiniAmiq     cells 56  ALREADY-OK 53  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 1
testflags/SeqDriver    cells 49  ALREADY-OK 46  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 1
testflags/SimpleUVM    cells 47  ALREADY-OK 45  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 0
testflags/Scoreboard   NOFILE (no database in this mode -- COUNTED, not skipped silently)
(MULTISET and SET scoring agree on all nine.)
```

**`AWAY-GOLDEN` is 0 on every database and both scorings.** Exactly **2**
TO-GOLDEN cells per database — the `INSIDE` cell at `uvm_domain.svh:199` and the
`LISTOP` cell that appears with it — out of 13..56 inside/list-op cells, which is
why the other 11..53 sites in those same designs provably did not move. The
`STILL` cell on MiniAmiq/SeqDriver is r10uvm99's R3
(`uvm_sequencer_base.svh:664`, a range-free set both sides flatten identically,
differing only in how golden SCOPES the two enum refs — a `vpiFullName`
difference, which is why the row is CMP_EQUAL anyway).

## 7. THE CONVERSIONS — 5 tests / 9 rows, judged by `uhdm-cmp` rc alone

**LOUDLY: nine corpus rows CONVERT. `results/*.csv` were NOT edited — the master
promotes them.** The committed baseline rows and their fresh replacements,
quoted verbatim from `ct8rows.sh results/golden_surelog.csv <fresh>`:

```
< BuildUVMPkg,default,CMP_NOTEQUAL,decompile:,,      > BuildUVMPkg,default,CMP_EQUAL,,,differ
< BuildUVMPkg,testflags,CMP_NOTEQUAL,decompile:,,    > BuildUVMPkg,testflags,CMP_EQUAL,,,differ
< MiniAmiq,default,CMP_NOTEQUAL,decompile:,,         > MiniAmiq,default,CMP_EQUAL,,,differ
< MiniAmiq,testflags,CMP_NOTEQUAL,decompile:,,       > MiniAmiq,testflags,CMP_EQUAL,,,differ
< Scoreboard,default,CMP_NOTEQUAL,decompile:,,       > Scoreboard,default,CMP_EQUAL,,,differ
< SeqDriver,default,CMP_NOTEQUAL,decompile:,,        > SeqDriver,default,CMP_EQUAL,,,differ
< SeqDriver,testflags,CMP_NOTEQUAL,decompile:,,      > SeqDriver,testflags,CMP_EQUAL,,,differ
< SimpleUVM,default,CMP_NOTEQUAL,decompile:,,        > SimpleUVM,default,CMP_EQUAL,,,differ
< SimpleUVM,testflags,CMP_NOTEQUAL,decompile:,,      > SimpleUVM,testflags,CMP_EQUAL,,,differ
```

| scoreboard | baseline | this pass |
|---|---|---|
| surelog `default` | 469 CMP_EQUAL / 14 CMP_NOTEQUAL | **474 / 9** |
| surelog `testflags` | 465 / 12 | **469 / 8** |
| uhdm2rtlil `default` | 768 / 36 / 67 SLANG_REJECT | 768 / 36 / 67 — unchanged |
| uhdm2rtlil `testflags` | 768 / 36 / 67 | 768 / 36 / 67 — unchanged |

Four of the five tests are the **proven UVM coin family**, so the conversion is
judged by `uhdm-cmp` rc alone and the head was run **TWICE, on two independent
sets of databases**: the full patched sweep and a second filtered sweep with its
own workdir. Both times all nine rows read `cmp rc=0`, **0 cmp lines, 0 heads**
(`evidence/HEADS.r11u30.txt`). The whole cluster **K1 closes**.

The other three differing CSV rows are read, not summarised:
`LowMemLib`/`LowMemPkg` testflags embed the WORKDIR PATH in their
`SURELOG_FAIL` note field (same status), and `Earlgrey_0_1/testflags` goes
`CMP_EQUAL/differ → CMP_EQUAL/<blank>` — the documented `uhdm-dump` timeout draw
in the DUMP column; its DATABASE is byte-identical (`59d0ee6d10c3` both
binaries), which is the pin.

## 8. Every byte, predicted then attributed

`byteverify.sh SELFCHECK=1`, patched vs MY OWN pristine workdirs:

```
uhdm2rtlil  MOVERS 0 / 1608   (SELFCHECK 1607/1608 flagged)
surelog     MOVERS 9 /  960   (SELFCHECK  959/ 960 flagged)
```

**The mover set is exactly the set predicted by name before the patched sweep —
9 of 9, no unpredicted mover.** Attribution is ORDER-BLIND (`attrib30.sh`:
workdir-normalised, SORTED dumps) because four of the five tests are the coin
family and a line COUNT there is a per-run draw:

```
default/BuildUVMPkg  17 lines = 17 law + 0 coin      testflags/BuildUVMPkg 17 = 17 + 0
default/MiniAmiq     17        = 17 + 0              testflags/MiniAmiq    17 = 17 + 0
default/Scoreboard   17        = 17 + 0              testflags/SeqDriver   21 = 17 + 4
default/SeqDriver    21        = 17 law + 4 coin     testflags/SimpleUVM   17 = 17 + 0
default/SimpleUVM    17        = 17 + 0
```

The 17 law lines are the SAME cells every time: the new `operation(vpiListOp)`,
its two `ref_obj` operands (`UVM_PHASE_STARTED` and the `UVM_PHASE_CLEANUP` the
pristine truncation DROPPED), their `vpiParent` / `vpiName` / `vpiFullName` rows
and the `vpiOpType:37` row — all at `uvm_domain.svh:199`. The 4 coin lines on
SeqDriver are a LINE-NUMBER-class constant (`UINT:643 ↔ 841` default,
`UINT:639 ↔ 633` testflags, with their `vpiDecompile`s), the documented
order-blind coin class, and nothing else. **MOVED-WRONG 0 / AWAY-GOLDEN 0.**

## 9. Gates — all green (`evidence/GATES.r11u30.txt`)

| gate | result |
|---|---|
| build both, md5 | pristine `62547ac98ebcfdeb522171dc946d50ad` = the main tree at `4110f3de`; patched `0fc7b2ec16a79f41b5bc73ef10275de1`; both frozen `chmod 555` before any sweep |
| `cmds.txt` binary audit, by PATH | u2r patched 1742/1742, surelog patched 1531/1531, surelog pristine 1531/1531 — no other binary anywhere |
| goldens | **PASS 23 / FAIL 0**; negative control `SLANG_UHDM=/bin/false` → **PASS 0 / FAIL 23** |
| u2r both modes vs committed baseline | **PASS**, every row byte-identical |
| surelog both modes | 12 differing rows: the 9 conversions + 2 path-in-note + 1 Earlgrey dump-column draw, all quoted |
| byteverify SELFCHECK | u2r 0/1608, surelog 9/960 — exactly the predicted names |
| protected databases | 12/12 byte-identical: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, BlackParrotComplex, YosysOldOr, Earlgrey `8bdf25272e08`/`59d0ee6d10c3` |
| canaries / ctcan2 / canaudit | surelog ok=44 changed=8 (7 conversions + the Earlgrey draw); u2r ok=8 changed=0; ctcan2 ok=58+1 changed=0 PASS; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS |

`results/*.csv` were READ ONLY. `GOLDEN_DEFER` unset. Builds `-j 2`, sweeps
`--jobs 2`, every arm's rc recorded. No fenced test was dispatched.

## 10. Residues and R0

* **R1 — the SYNTAX emitter's own `inside` arm** (`src/TypeEmit.cpp:16987`,
  inside `emitSyntaxExpr`) still pushes `emitSyntaxExpr(*vr)` flat and has no
  `ValueRangeExpression` arm at all. It is NOT touched, and no measured face
  reaches it: its callers are a CLASS PARAMETER's RHS
  (`src/UhdmExporter.cpp:2741`) and select/range bounds
  (`src/TaskFuncEmit.cpp:5939`) — and Surelog REFUSES `inside` in every one of
  those contexts (a class-parameter default with `inside` is 3 SYNTAX errors and
  no database, measured). Whoever wants to close it must first find a source
  Surelog will compile through that arm.
* **R2 — a range-free set's bare constant operand carries a `vpiParent` we
  emit and golden does not** (`{7}`, `{pv+1,5}`, `{"aa","bb"}`). PRE-EXISTING,
  judge-invisible, and untouched by this pass: the fence arm `a9`'s whole-dump
  diff is the same 87 lines before and after. It is the only fidelity gap left
  on the inside family, and it belongs to the LITERAL-PARENT policy, not here.
* **R3 — the enum-ref SCOPING at `uvm_sequencer_base.svh:664`**
  (`…::arb_sequence_q::process::KILLED` vs our `…::process::KILLED`): the one
  `STILL` census cell on MiniAmiq/SeqDriver, a `vpiFullName` family, still
  open, still judge-invisible (r10uvm99's R3, unchanged).
* **R0 (the next head) — the surelog suite now stands at 474/9 + 469/8.** The
  nine remaining `default` not-equal rows and eight `testflags` ones are the
  r11u29 triage's OTHER clusters (K2 `vpiNetType`, K4 the type parameter's lost
  dimension, K5/K6/K3 the reducer), none of which this law touches. K1 is
  CLOSED: its five tests are CMP_EQUAL in every mode they have a database in.

## 11. Files

* `README.md` — this write-up.
* `g30_b1_param.sv`, `g30_b2_shapes.sv`, `g30_b3_scope.sv` — the three new arms.
* `grid30.sh` — the whole grid (13 arms × both views) through the committed
  `r10uvm99repro/three99.sh` + `opcen99.py`.
* `dumpdiff30.sh` — the whole-dump fidelity diff for one arm directory.
* `pred30.cpp`, `predict30.sh` — the a-priori mover predictor.
* `cen30.sh` — the corpus INSIDE/LIST-OP census for one named row, three ways.
* `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `byteverify.sh`, `ct8rows.sh`,
  `rowheads.sh` — the committed gate battery (copied from
  `r10uvm221repro`, the current generation), so the gates RUN here.
* `evidence/` — GRID, PREDICT, POSCONTROL, DUMPDIFF, CENSUS, GATES, heads.
