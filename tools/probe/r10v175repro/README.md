# r10v175 — ADVERSARIAL VERIFICATION of r10uvm175 (§ `withRecvIndexedStepIsBitSelect175`) — **ACCEPT**

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge: the
official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** slang was NOT patched;
`results/*.csv` were READ-ONLY; nothing was promoted; **no corpus row
converted**; `GOLDEN_DEFER` stayed unset; the four slang-fenced tests were
never dispatched and are named in no artifact here.

**VERDICT: ACCEPT.** `/tmp/r10uvm175.patch` stands as submitted — production is
unchanged by this verification. Every headline number reproduced bit for bit
from binaries and sweeps the verifier built itself; **no legal SystemVerilog
was found on which pristine is right and patched is wrong**, in 39 arm-views
across 20 arm files (8 of them written by the verifier, and none of them shown
to the implementer).

---

## 1. What was reproduced (GATES.r10v175.txt has the full table)

Two fresh worktrees at `a0a33bb3`, both binaries built by the verifier at
`-j 2`, frozen `chmod 555` before any sweep, `SLANG_UHDM` exported explicitly
per binary, every `cmds.txt` audited by binary PATH.

| | implementer | verifier |
|---|---|---|
| pristine md5 | `9853d69d43a9cf87884b368be6f16c7f` | **same**, and byte-identical to the main tree's binary |
| patched md5 | `b49636170347560e90432e4e18a11f3b` | **same** |
| goldens | 23/0 both binaries, `/bin/false` 0/23 | **same** |
| u2r | 679/50/2, 0 rows changed | **same**, four sweeps (both binaries × both modes) |
| surelog | 0 rows changed over 1588, no conversion | **same**, own sweeps for both binaries; status histograms identical |
| movers | sl 3/956 (2 predicted + the coin), u2r 0/1358 | **same**; the prediction re-run on the verifier's OWN pristine DBs named MiniAmiq ×2 and nothing else |
| MiniAmiq attribution | 12 order-blind lines, ONE cell | **same 12 lines** |
| heads | MiniAmiq 40→29 both modes, every other row's log byte-identical | **same**; cmp-log md5 `dcb32643befb` → `d10e1669eb7a`, and the committed head artifacts are byte-identical to the verifier's own |
| face census | golden 324/0/2/322; ours patched == golden; FACEDIFF 2 → 0 | **same** |
| the pass's grid | 76 TOGOLD / 0 AWAY / 2 MOVEDWRONG / 4 STILLWRONG; judge 78/0/0/0 | **same, all 24 score lines line for line** |
| wide boundary | LISTED=4848 PROCESSED=4848 MOVED=14 ASYMMETRIC=0 | **same, and the same 14 by name** |
| canaries / pins | ok=52, ok=8, ctcan2 PASS×2, canaudit PASS, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **same** |

The decode was checked against Surelog's source, not taken on trust:
`CompileHelper::compileComplexFuncCall`'s single `while (dotedName)` loop
(`CompileExpression.cpp:5498-5692`) mints the `bit_select` at `:5578-5595` and
only reaches `fcall->With(...)` at `:5665-5672`, after `elems` is complete; the
`this`/`super` road really is a different function branch
(`:5154-5245`, `paImplicit_class_handle`), whose fallback pushes plain
`ref_obj`s and stops at the method node — which is why golden has three
elements there and we have four.

**The gate expression is safe by construction.** `!withExpr9 && stepOk23`
became `stepOk23 && (!withExpr9 || !implicitRoot175)`; for `withExpr9 == null`
both read `stepOk23`, so **no no-`with` cell can move** — which the 953
byte-identical surelog databases and 17 unchanged control arms confirm.

---

## 2. Breaking the law — the verifier's own arms

`vgrid175.sh` (independent of the pass's driver: fd-3 list, children
`</dev/null`, scratch keyed on the RELATIVE path, every rc recorded,
PROCESSED asserted, plus a raw workdir-normalised whole-dump `pristine` vs
`patched` diff per arm-view and the official judge on each). Names inside the
arms are unlike the arm letters and unlike each other.

| arm | faces | def / elab |
|---|---|---|
| `v175_pos.sv` | POSITION: rvalue, call argument, `if` condition, ternary, `foreach` body, concatenation, the same call written three times, statement-position void `sort() with`, `randomize() with {}` on an indexed receiver, a no-clause control | **TOGOLD 9, AWAY 0** (both views); elab reaches **CMP_EQUAL** |
| `v175_deep.sv` | DEPTH: index on step 0 / step 1 / both / none / the method's own step / three components / fixed-array root | **TOGOLD 6, AWAY 0**; **both views reach CMP_EQUAL** |
| `v175_kind.sv` | SPELLINGS: `4'd2`, `'h2`, `[ 2 ]`, a localparam, a NESTED bracket index, a parenthesised compound, `i+1`, two dimensions, a string key, a cast | **TOGOLD 6, AWAY 0**, 4 one-sided keys — all four are §23's PATH-NAME residue and all four are element-identical to golden after the patch (checked position-keyed, by hand); the nested-bracket index is correctly REFUSED and stays pristine |
| `v175_home.sv` | HOMES: in-body, out-of-body `::`, virtual, static, package free function, module `initial`, module `always`, module function | **TOGOLD 8, AWAY 0** |
| `v175_scope.sv` | SCOPES: a class declared inside a MODULE, a module body handle, a GENVAR index in a generate block, a `program` block | **TOGOLD 5, AWAY 0** |
| `v175_face.sv` | TAILS/SLOTS: `min` `max` `unique` `unique_index` `find_last_index`, two `with`-form calls in one expression, a `with` expression naming the receiver's index variable, `return` position, `case` selector, `while` condition, a dotted-MEMBER index | **TOGOLD 12, AWAY 0**; elab reaches **CMP_EQUAL** |
| `v175_solo.sv` | the ONE-COMPONENT subscripted receiver (queue-of-queues, fixed 2-D, associative, dynamic-of-dynamic) | **AWAY 0**; judge column **TOGOLD 4**; see §3 |
| `v175_solo2.sv` | the same array with and WITHOUT the clause — golden only | the discriminator for §3 |

**Controls re-run in the same driver, all unchanged (`SAME_AGREE`/`STILLWRONG`
only, and byte-identical dumps): r10uvm74's `b1`/`b2`/`b3`/`b4`/`v74_edge2`,
every r10uvm124 arm, every r10uvm172 arm, r10buvm14's `a1_dims14`.** The only
control that moves is r10uvm74's `v74_edge.sv`, whose ONE moved cell is that
pass's own residue R2 and moves TOGOLD — reproducing the implementer's
`G-ONLY=2 O-ONLY=2 SAME_AGREE=8 STILLWRONG=2 TOGOLD=1` (def) and
`... SAME_AGREE=7 STILLWRONG=3 TOGOLD=1` (elab) exactly.

**Keys gained or lost by the patch, over all 31 arm-views of the first grid:
two gained, zero lost** — both are the nested `hier_path` of a DOTTED index
(`helper.nail`, `helper.tick`), which **golden also has** and pristine did not
build at all.

**POSITIVE CONTROL.** Fed `(golden, golden, pristine)` the scorer reports
`AWAY=9` on `v175_pos.def`; fed the real triple it reports `TOGOLD=9`. The gate
can see an AWAY. **CALIBRATION:** three arms' Surelog goldens built twice in two
different directories score 33 cells, **0 DIFF**.

---

## 3. The one finding — verifier residue **R7**, judge-invisible

r10uvm175's law states the clause "cannot change an element's shape … every
position, every index kind, every locator method and every home give the SAME
`bit_select` with and without the clause." That holds for every MULTI-component
receiver measured here and in the pass's own arms. **It does not hold for a
receiver written as ONE subscripted component.** Measured on golden with the
same array and the same method (`SOLO.r10v175.txt`):

```
nest[slot].sum() with (item)      golden bit_select span = 11:21-11:25  (the INDEX)
nest[slot].sum()                  golden bit_select span = 13:16-13:20  (the BASE NAME)
nest[slot].find_index() with (…)  golden bit_select span = 17:21-17:25  (the INDEX)
nest[slot].find_index()           golden bit_select span = 19:16-19:20  (the BASE NAME)
nest[slot].size()                 golden bit_select span = 15:16-15:20  (the BASE NAME)
```

(The split is identical in DEF and ELAB. The index's `vpiParent` is not a
stable discriminator: golden itself carries `bit_select` in one copy and
`hier_path` in another for the same cell.)

**This is a residue, not a regression.** Under the patch these cells move from
a flat `ref_obj` carrying the whole written text to golden's kind, golden's
`VpiName`, an index child of golden's kind — 4 of 5 reach golden on **every
field a generated `Compare` reads**; only the SPAN and the index's `vpiParent`
differ, and no generated `Compare` reads either (RESUME.md §9). **Judge impact
zero, corpus impact zero** (golden holds exactly two subscripted `with`-form
paths in 956 databases, both the MiniAmiq MULTI-component cell; uhdm2rtlil
holds no `with`-form path at all).

**The face is untested by the pass** because arm A's cell labelled
`// p_solo: ONE component, subscripted (the array-of-queues cell)` is written
`solo.tagset.find_index() with (…)` — two components, no subscript. The comment
names a cell the arm does not contain. `v175_solo.sv` / `v175_solo2.sv` are
that arm.

**Two smaller notes, both judge-safe.**
* `score175.py`'s `judgeform` strips `@<span>^<parent-kind>` with `[a-z_]*`,
  which does not match the `-` written for an UNPARENTED index; a cell whose
  index is unparented on one side reads as different in the judge column even
  when every judged field agrees. It **over**-reports difference, so it can
  never hide an AWAY — it slightly under-counts judge-column TOGOLD (one cell
  here).
* r10uvm175's residue **R2** (the nested index path's span) is one facet wider
  than written: with a dotted-MEMBER index the nested path's own leading
  `ref_obj` also takes golden's LAST-name span (golden `18:30-18:34`, ours
  `18:23-18:29` in `v175_face.sv`), not only the path's end column. Same
  judge-invisible field.

---

## 4. The DECLINE, checked

`this.`/`super.`-rooted receivers are declined under the clause and left as
r10uvm74 left them. Re-measured on arm E: golden's path there is NAMED
`this.decks.knots` (three `ref_obj`s, subscript and method element both
dropped) while ours is named `this.decks[cursor].knots` with four elements —
`hier_path::Compare` reads `VpiName`, so the cell fails at the OWNER on both
binaries and the element kinds are never reached. The decline is therefore
**judge-invisible**, and correctly conservative: it keeps r10uvm74's floor
(`s_nowiththis` is byte-identical before and after) rather than adding a fourth
wrong element shape. It is also **corpus-unreachable** — the face census finds
zero `this`/`super`-rooted `with`-form paths on either side in either corpus —
so its justification rests on the arm, which this verification reproduced.

---

## 5. Files

| file | role |
|---|---|
| `vgrid175.sh` | the verifier's own arm driver (golden + both binaries, both views, every rc, raw dump diff, the official judge) |
| `v175_pos.sv` `v175_deep.sv` `v175_kind.sv` `v175_home.sv` `v175_scope.sv` `v175_face.sv` | the six adversarial arms |
| `v175_solo.sv` `v175_solo2.sv` | the ONE-COMPONENT face and its with/without-clause discriminator (residue R7) |
| `GATES.r10v175.txt` | every reproduced number, gate by gate |
| `GRID.r10v175.txt` `GRID2.r10v175.txt` | the two grid runs, scores and details, both columns |
| `SOLO.r10v175.txt` | the R7 measurement |
| `BOUNDARY.r10v175.txt` | the verifier's own 4848-source boundary run |
