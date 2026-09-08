# r10uvm222 — § ifaceOwnCallCalleeFormRoutes222

**A call's KIND is decided by the CALLEE's own form, never by what its
arguments spell.**

Base commit `db069bdf`. One production conjunct in `src/ExprEmit.cpp`.

---

## 1. THE LAW

The emitter's "INTERFACE method calls through a port" arm is reached for every
call whose callee is declared inside an interface — a call *through* a port
(`vif.poke(x)`, the shape it was decoded on) and equally a call an interface's
own subroutine makes to a **sibling subroutine of the same interface, written
bare** (`ctrl(x)`).  Having been reached, the arm decided the object's KIND by
`rawText(expr.sourceRange).find_last_of('.')` — **the last dot of the whole
statement, arguments included**.  So a bare callee whose argument list happened
to contain a dot was split at that dot: the callee's own name, its opening
paren, any earlier actuals, their commas and string literals all became the
"receiver", and golden's plain `func_call` became a `method_func_call` with a
`vpiPrefix` named `ctrl(x, o`.

Surelog reads the CALLEE ALONE.  `CompileHelper::compileTfCall`'s user-call arm
(`src/DesignCompile/CompileHelper.cpp:4211-4241`) takes `name =
SymName(tfNameNode)` off the NAME node and tests that node's
`paConstant_bit_select` SIBLING to choose between `func_call` and
`method_func_call{vpiPrefix}`; the argument list is not fetched until `:4318`
(`argListNode = fC->Sibling(tfNameNode)`), after the shape is already chosen.
The argument text cannot reach the decision in the reference tool.

The production change is the same read the EXPRESSION-position sibling arm ~100
lines above already performs on the very same string:

```
-   auto dot1 = raw1.find_last_of('.');
+   std::string callee222 = raw1.substr(0, raw1.find('('));
+   auto dot1 = callee222.find_last_of('.');
```

No new flag, no new counter, no new window — the two arms now ask one question
of one string.

---

## 2. THE HEAD

| | |
|---|---|
| the head, re-measured on this pass's own pristine build FIRST | **MiniAmiq ×2, 152 cmp lines / ONE head each**, the two logs byte-identical **and byte-identical to `r10uvm221repro/head_pat_MiniAmiq.default.cmp`** — uvm221's R0 reproduced exactly. Every other row at BASE: SeqDriver ×2 **0**, SimpleUVM ×2 **0**, Scoreboard/default **0**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**. The pass's pristine binary is byte-identical to the main-tree build at `db069bdf` (md5 `769b69341dc3…`). |
| the head after | **THE OBJECT IS GONE.** MiniAmiq ×2 read **1 388 494 lines / 1 head** — a NEW object of a different family, and the line count is that object's decompile size. `interface_inst: work@svaunit_vpi_interface`, on the **net list**: golden 71 nets + 5 array nets + 1 process, ours 5 nets and no process. **R0.** |

`instance::Compare` (`~/git-repos/UHDM/build/generated/src/instance.cpp:335-337`)
reads `Task_funcs()` and then, on the very next line, `Nets()`.  The pristine
head sat inside `Task_funcs`; the patched walk returns **0 for the whole
`Task_funcs` vector** — every one of the seven statements, their argument
bindings included, now agrees with golden exactly — and advances ONE LINE to
the net list, where a size mismatch names the OWNER (`BaseClass.h`'s VECTOR
overload).  That is the strongest available proof that this law moved nothing
wrong: the official judge itself walked the whole population and returned zero.

---

## 3. THE SEVEN SITES AND § 218's R1

`svaunit_vpi_interface.sv` is an interface holding two DPI-C imports
(`control_assertion_dpi` :40, `get_cover_statistics_dpi` :48).

```
310:7  reset_assertion         ctrl(a_sva.get_sva_path(), `MACRO, $time());
334:7  disable_assertion       "
358:7  enable_assertion        "
383:7  kill_assertion          ctrl(a_sva.get_sva_path(), `MACRO, a_sim_time);
408:7  disable_step_assertion  "
434:7  enable_step_assertion   "
512:13 update_coverage         stat(cover_info[index].get_sva_name(), f, s);
```

The four sibling calls at **453 / 462 / 477 / 493** write
`control_assertion_dpi("", `MACRO, $time())` — no dot anywhere — and were
already `func_call` on both sides.  The population split was literally "is
there a dot in the text".

**§ 218's R1 is CLOSED, and it was never a separate family.**  `a_sim_time`
@383:56 — golden binds it to `kill_assertion`'s io_decl, we left it bare — sits
INSIDE the 383:7 statement.  It was a consequence of the mis-routing: routed by
the callee's own form, the statement takes the ordinary user-call road and the
binding falls out.  The whole-dump census records `\_io_decl: (a_sim_time),
line:378:99` as an ADDED line and as a CURED golden-only cell.

---

## 4. THE POPULATION AND THE A-PRIORI PREDICTION

`POPULATION.r10uvm222.txt`, `PREDICT.stage.*.txt`, `predict222.sh`.

The arm is the ONLY producer in this emitter of a `method_func_call` whose
`vpiPrefix` is named from a raw text slice, and the two readings disagree
EXACTLY when a `(` precedes the last dot — in which case the slice contains
that `(`.  So

> a `ref_obj` whose name contains `(`  ⟺  this arm mis-routed a call

is an **exact, complete, database-side** signature.  Golden holds zero of them
anywhere.  Read from the PRISTINE databases, before the patched binary was
built into any sweep:

| corpus | databases | row-modes HIT | cells |
|---|---|---|---|
| uhdm2rtlil | 1358 | **0** | **0** |
| surelog | 956 | **2** (MiniAmiq default + testflags) | **7 each** |

**The u2r zero was PROVEN A PRIORI**, which is what this pass's hardest gate
asked for: the routing fix is wide, and no u2r database could change because
none carries a cell of the signature.  The patched sweep then measured
`byteverify MOVERS 0 / 1358` — the predicted value.

---

## 5. THE GOLDEN GRID

`grid222/`, `grid222.sh`, `score222.sh`, `cells222.sh`,
`GRID.rc.r10uvm222.txt`, `GRID.cells.r10uvm222.txt`.

Six arms compiled with the **canonical golden-side Surelog** — the one
`scripts/verify_golden.py` names, `$HOME/git-repos/Surelog/build/bin/surelog` —
and with both binaries; **every arm's rc on both sides is recorded**, and an
arm with a non-zero rc is printed loudly and read as an ERROR-RECOVERY arm, not
a golden one.

| arm | what it crosses | pristine MISS/EXTRA | patched | verdict |
|---|---|---|---|---|
| `a1_home` | bare callee in an interface × ten argument forms (literal, receiver-call 1st/2nd/last, two of them, plain dotted name, indexed receiver, expression position, one control body down, `$time()`) | 28 / 44 | **0 / 0** | TOWARD |
| `a4_dpi` | the exact corpus callee kind — DPI-C imports declared in the interface | 8 / 12 | **0 / 0** | TOWARD |
| `a2_qual` | callee receiver-qualified (the arm's decoded home) × plain / receiver-call / dotted-name / spaced-dot / expression | 20 / 20 | 10 / 10 | TOWARD |
| `a3_holder` | holders: class in-body, class out-of-body, virtual-interface array, module `initial`, module function | 31 / 31 | 3 / 3 | TOWARD |
| `a5_edge` | an ESCAPED receiver identifier that CONTAINS a dot | 11 / 11 | 11 / 11 | unchanged count; e04 now takes e02's shape exactly |
| `a6_reject` | a receiver that is ITSELF A CALL | slang rc **3**, no database | same | unreachable |

`a1` and `a4` reach **exact agreement with golden on every call record**.
`a2`/`a3`'s remainders are pre-existing residues of other laws (R1–R3 below),
unchanged in kind and never enlarged.

**a6 is the arm that makes the gate exact.**  A receiver that is itself a call
(`get_vif().poke(x)`) is the only other spelling where the last dot follows a
`(`, so it is the only place the two readings could differ besides the target.
Surelog compiles it (rc 0); **slang refuses it** — "invalid member access for
type 'virtual interface if22f'", rc 3, no database.  The construct cannot reach
this emitter on any input.  The rc IS the measurement.

---

## 6. THE CENSUS AND THE MOVERS

`CENSUS.moved-cells.r10uvm222.txt`, `CENSUS.MiniAmiq.wholedump.diff.txt`.

Whole-dump order-blind diff, pristine vs patched MiniAmiq (1.89 million lines):
**44 added, 70 removed, ALL classified** — seven `method_func_call` + seven
prefix `ref_obj` out, seven `func_call` + their `vpiFunction` links in, plus the
one `a_sim_time` io_decl actual.  Nothing else in the database moved.

Against GOLDEN, order-blind multiset:

| | MISSING (golden-only) | EXTRA (ours-only) |
|---|---|---|
| pristine | 260 558 | 96 711 |
| patched | 260 521 | 96 648 |
| | **−37** | **−63** |

Both columns down, neither up.  **TO-GOLDEN, AWAY 0, STILL-WRONG 0.**  The only
lines that "newly appear" as MISSING are seven copies of the structural filler
string `|vpiParent:` at one indentation, where we were ALREADY 591 lines short
of golden (golden 27 148 / pristine 26 557 / patched 26 556): it carries no
object and no field value and is the counting shadow of the seven prefix
`ref_obj`s this law stops minting.  Newly-appearing EXTRA lines: **zero**.

---

## 7. GATES

`GATES.r10uvm222.txt` carries every number.  In one line: build both, md5s
recorded, the pristine binary byte-identical to the main tree at `db069bdf`;
goldens **23/0** with the negative control **0/23**; u2r **679/50/2 both
modes**, `ct8rows` PASS against the committed baseline and both controls,
`byteverify` **0/1358**; surelog **476/5 + 470/5**, `ct8rows` PASS against
both baselines and this pass's own pristine, `byteverify` **2/956 = exactly the
two row-modes predicted BY NAME**; the nine protected CMP_EQUAL row-modes
CMP_EQUAL on both binaries at judge **rc 0**; canaries **ok=52 / ok=8,
changed=0**, `ctcan2` PASS ×2, `canaudit` **audited=29 UNCOVERED=0
FENCE-BREACH=0**; all pins SAME with `InterfaceModPort` byte-identical,
`SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on their pinned values.

**NO CONVERSION.**  MiniAmiq stays `CMP_NOTEQUAL` in both modes — the ladder
has not bottomed out; the head object changed and a new family surfaced under
it.  `results/*.csv` untouched.

### The one CSV row that moved, and why it is not a mover

The patched sweep's CSV read `Earlgrey_0_1,testflags,CMP_EQUAL,,,` where the
baseline reads `…,differ`.  **The status column did not move**; the DUMP column
went blank, and blank is what `verify_golden.py` writes when `uhdm-dump` TIMES
OUT (`:633-635`, `except subprocess.TimeoutExpired: pass`).  Earlgrey_0_1's
testflags database is 95 MB and `uhdm-dump` alone takes ~95 s on it; this sweep
shared the machine with two other sweeps and the wide boundary gate.  Proven
twice, not argued: `byteverify` says that database is byte-identical between
the two binaries, and re-measured ALONE on an idle machine with the PATCHED
binary the row reads `…,CMP_EQUAL,,,differ`.  `ct8rows` on the re-measured CSV
is PASS against all three baselines and `canaries.sh` reads `ok=52 changed=0`.

---

## 8. THE WIDE BOUNDARY

`bound222.sh`, `BOUNDARY.r10uvm222.txt`, `bscore222.sh`, `bcells222.sh`,
`ARMSCORE.r10uvm222.txt`.

`LISTED = PROCESSED = 5541`, `RC_DIFFS = 0`, `MOVED_ARMS = 24` (12 arms × 2
views).  23 arms segfault identically on BOTH binaries (rc paired) —
pre-existing.

Six of the moved arms are this pass's own.  The six foreign ones were
re-compiled against the canonical golden-side Surelog and re-scored both ways:

| arm | def | elab |
|---|---|---|
| `r10uvm218repro/grid218/a5_sibling/dut.sv` | 15/529 → **1/511** | 15/740 → **1/722** |
| `r10v103repro/arms/v103_b4.sv` | 79/739 → **64/724** | 78/1288 → **63/1277** |
| `r10v103repro/arms/v103_c4_vifprefix.sv` | 21/535 → **5/519** | 21/813 → **5/801** |
| `r10v167repro/vG_nocls.sv` | 38/548 → **38/536** | 38/1780 → **38/1768** |
| `r10v176repro/v176_q_argtext.sv` | 100/580 → **70/556** | 91/1183 → **64/1164** |
| `r10v176repro/v176_s_exprpos.sv` | 142/586 → **130/574** | 128/1464 → **117/1457** |
| `r10v218repro/arms/b1_kinds/dut.sv` | 6/520 → **2/512** | 6/770 → **2/762** |

**TOWARD-GOLDEN 12 / 12 arm-views, AWAY 0, BROKEN 0.**

**THE MUST-STAY FLOOR HELD.**  `r10uvm216repro` 0 moved arms (its `+ index`
fence intact), `r10uvm220repro` 0, `r10uvm221repro` 0.  Of `r10uvm218repro`'s
five arms only `grid218/a5_sibling` moved — which is § 218's own **R1** arm,
the residue this pass was told to re-measure — and § 218's `a2_window` did not
move.  A call golden renders as a METHOD call stays one everywhere: `a2_qual`,
`a3_holder` and `a5_edge` keep `method_func_call` in all seventeen of their
qualified-callee cells.

The four slang-fenced tests are never dispatched (`canaudit`: each of the four
names "not dispatched by any driver (OK)", FENCE-BREACH 0).

---

## 9. FILES

| file | what |
|---|---|
| `DECODE.r10uvm222.txt` | the head both sides, the Surelog decode, the predicate, the fix. |
| `POPULATION.r10uvm222.txt` | callee form × argument form × holder × view over both corpora. |
| `PREDICT.stage.surelog.txt`, `PREDICT.stage.uhdm2rtlil.txt`, `predict222.sh` | the a-priori census from pristine databases. |
| `grid222/`, `grid222.sh`, `score222.sh`, `cells222.sh`, `GRID.rc.r10uvm222.txt`, `GRID.cells.r10uvm222.txt` | the golden grid, every arm's rc, every cell. |
| `CENSUS.moved-cells.r10uvm222.txt`, `CENSUS.MiniAmiq.wholedump.diff.txt` | the mover, attributed line by line. |
| `HEAD.new.fields.r10uvm222.txt` | the NEW head's field counts, both sides. |
| `head_pris_MiniAmiq.*.cmp`, `head_pat_MiniAmiq.*.head220.cmp` | the head on both binaries, both modes (the patched head's first 220 lines — the whole log is 1.39 M lines of one object's decompile). |
| `BOUNDARY.r10uvm222.txt`, `bound222.sh`, `ARMSCORE.r10uvm222.txt`, `bscore222.sh`, `bcells222.sh` | the wide boundary and the re-scoring of every moved arm. |
| `GATES.r10uvm222.txt` | every gate number, both binaries. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, copied unchanged from their canonical homes. |

---

## 10. RESIDUES

* **R0 — THE NEW MiniAmiq HEAD IS THE INTERFACE'S NET LIST.**  1 388 494 lines,
  one head, both row-modes.  `interface_inst: work@svaunit_vpi_interface`
  (`svaunit_vpi_interface.sv:25:1-647:13`) — a VECTOR SIZE mismatch, which
  names the OWNER: **golden 71 `vpiNet` + 5 `vpiArrayNet` + 1 `vpiProcess`,
  ours 5 `vpiNet` and nothing else.**  Our five are the interface's five
  declared variables (`test_name` :81, `eots_flag` :84, `sva_info` :87,
  `cover_info` :90, `property_info` :93).  Golden's extra sixty-six are
  IMPLICIT nets carrying **`uvm_pkg.sv` line numbers** —
  `uvm_start_uvm_declarations` @26:5, `uvm_default_printer` @637:13,
  `uvm_resources` @1694:25, `clp` @801:27 … — i.e. Surelog's `lateBinding`
  implicit-net fallback minting a net for every name the interface body
  references through its wildcard `import uvm_pkg::*` that it cannot otherwise
  resolve.  This is the same producer § 221's R3 named from the other side (a
  subroutine-local enum's constant binding an implicit `logic_net` in an
  INSTANTIATED interface).  A different family (instance population, not call
  shape).  `HEAD.new.fields.r10uvm222.txt` and
  `head_pat_MiniAmiq.default.head220.cmp` carry it.  Note the head is reached
  because `instance::Compare` reads `Nets()` on the line after `Task_funcs()`
  — a pass that fixes R0 will surface whatever `Array_nets()` and `Process()`
  hold next, in that order.
* **R1 — § 218's R1 IS CLOSED BY THIS LAW.**  `a_sim_time` @383:56 binds its
  io_decl now.  Recorded here so no later pass hunts a residue that is gone.
* **R2 — A SPACED DOT COSTS ONE COLUMN AND LEAVES A TRAILING SPACE IN THE
  PREFIX NAME.**  Arm a2 `q04_spaced` / `q05_spacedarg`: golden's
  `method_func_call` is at 48:16 with prefix `vif22b`, ours at 48:15 with
  prefix `vif22b ` — the text slice keeps the space the writer wrote.
  PRE-EXISTING (q04 reads exactly the same on both binaries) and untouched;
  q05 merely joins q04 instead of being further away.  Lifting it means
  trimming the slice, which is its own arm and its own grid.
* **R3 — A SUBSCRIPTED RECEIVER KEEPS ITS SUBSCRIPT IN OUR PREFIX NAME.**  Arm
  a3 `h03_idx` / `h04_idxarg`: golden's prefix is `bank22c`, ours is
  `bank22c[a_i]`.  This is § ifaceRecvCallArgTakesTheOrdinaryWindow176's own
  R2, PRE-EXISTING at h03 on both binaries; h04 now shares it instead of being
  further away.  Surelog drops the subscript at
  `CompileHelper.cpp:4216-4241` (`tfNameNode = fC->Sibling(Constant_bit_select)`
  — the subscript is neither in the name nor an argument).
* **R4 — AN ESCAPED RECEIVER NAME KEEPS ITS BACKSLASH AND TRAILING SPACE.**
  Arm a5: golden's prefix is `u.esc22e`, ours is `\u.esc22e `, and our call is
  four columns early.  PRE-EXISTING at e02 on both binaries; e04 now shares it.
  A text-slice residue of the same shape as R2/R3 — the three are one arm's
  worth of work.
* **R5 — AN OUT-OF-BODY METHOD'S PREFIX FULLNAME IS SPELLED DIFFERENTLY.**
  Arm a3 `h06_oob`: golden `holder22c::h06_oob.vif22c`, ours
  `work@holder22c::h06_oob::vif22c`.  A `VpiFullName`, which **no generated
  `Compare` reads** — dump fidelity only, and deliberately left.
* **R6 — A RECEIVER THAT IS ITSELF A CALL IS UNREACHABLE, NOT MODELLED.**  Arm
  a6: Surelog compiles `get_vif().poke(x)` (rc 0), slang refuses it (rc 3, no
  database).  The day slang accepts it, this arm's callee-form read declines it
  and the shape will have to be decided on measured golden, not on this pass's
  reasoning.
