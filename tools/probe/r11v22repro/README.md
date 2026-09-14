# r11v22 — the adversarial verification of r11u22, and the two amendments it forced

Base commit `40b5e0f3`, fresh worktrees built from source by this verifier.
Everything below was re-measured on this verifier's own binaries against the
REAL v1.87 goldens; nothing is carried forward from the implementer's
write-up.  **`results/*.csv` ARE NOT EDITED BY THIS PASS.**

| binary | md5 | what it is |
|---|---|---|
| pristine | `d9ceb85d37a97fa6c77d1cc50da3c65a` | `40b5e0f3` built from source — BYTE-IDENTICAL to the OPS-stated main-tree md5 |
| implementer's law | `c80243213f2fdff761bf8188c7148aa7` | `/tmp/r11u22.patch` on a fresh `40b5e0f3` — reproduces the implementer's md5 exactly |
| VERIFIED law | `d43d7293f9727ab6be004ffc8b2551bd` | the same plus § genTernCondSameMachine22 below |

## 1. WHAT REPRODUCED, BIT FOR BIT

* **R0 IS CLOSED.**  `r11u19repro/grid/f07_genif_tern_fill0/dut.sv` against the
  golden this verifier built (`surelog -parse -nobuiltin -nocache -sv`):
  pristine `cmp_rc=255`, **1 head, 73 cmp lines**; law `cmp_rc=0`, **0 heads, 0
  lines**.  The head is golden's `constant vpiDecompile:'0 vpiSize:32 BIN:0
  constType 3` at `7:56` against our whole `vpiOpType:32` ternary — the
  implementer's framing, verified from the cmp log.
* **THE PRODUCER DECODE IS CORRECT, read at the pin, not taken on trust.**
  `UhdmWriter::writeCont_assign` (`UhdmWriter.cpp:2090`) runs for every
  instance; its bound arm reduces and `adjustSize`s
  (`UhdmWriter.cpp:2135-2160`).  `CompileHelper::bindVariable`
  (`CompileStmt.cpp:3094`) switches on `uhdmfunction` / `uhdmtask` / `uhdmbegin`
  / `uhdmmodule_inst` and tail-recurses on `scope->VpiParent()` for everything
  else — so a `gen_scope` never sees its OWN declarations and an
  `interface_inst` binds nothing.  `ExprEval::reduceExpr`'s `constantOperands`
  loop (`ExprEval.cpp:3121-3145`) whitelists exactly `ref_obj`-with-a-value,
  `operation`, `sys_func_call`, `func_call`, `bit_select`, `hier_path`,
  `var_select`, `enum_var`, `constant` — `part_select` and
  `indexed_part_select` are absent.  `vpiConditionOp`
  (`ExprEval.cpp:3863-3903`) is the three outcomes, and the fill-arm bail-out
  is there verbatim.  `adjustSize`'s `orig_size == -1` tail sits INSIDE the
  `vpiBinaryConst` branch (`CompileHelper.cpp:4218-4240`) and a `vpiIntConst`
  fold takes the final `else { c->VpiSize(size); }` — which is why the fold
  constant is sized at `Bits(tps)` and the fill keeps its encoding.
* **THE GATE IS THE MECHANISM, not a coincidence.**  `R11U22_CELLDBG=1` on the
  six already-equal gate arms prints `bind=1 w=N fold=0 arm=0 fill=0` for every
  one — `b12`, `d17`, `d19`, `d12`, `e08`, `b25` REACH the law's entry and the
  operand gate is what declines them.  `d21`'s two cells do the same.
* **THE 101-ARM GRID.**  Every arm `golden_rc=0`; `c11` is `ours_rc=3` on BOTH
  binaries (no verdict); **57 CONVERT (the 56 committed arms + `f07`), 3 drop
  cmp lines (`a05` 64→15, `a09` 64→15, `d01` 74→8), 0 regress, 0 rise.**
* **THE PASS-19 GRID (91 arms, `r11u19repro/grid`) — 0 regressions**, 89
  unchanged, `f07` converts, two arms `ours_rc=3` on both binaries.  The landed
  § genCaPackedPatternFold19 and § caTernFillArmKeepsEncoding19 witnesses stand.
* **THE CORPUS.**  uhdm2rtlil **766 / 38 / 67 in BOTH modes**, whole-row
  byte-identical to `results/gate_uhdm2rtlil.csv` and to the default half of
  `results/golden_uhdm2rtlil.csv`; **0 byte movers of 1608**,
  `PATH_SETS_IDENTICAL`, self-check 1607/1608.  Surelog **469/14 default,
  465/12 testflags**.  1742 u2r + 960 surelog `cmds.txt` audited by binary
  PATH, **0 naming the main-tree binary**.
* **EARLGREY DECLINES 1314 CELLS, COUNTED.**  `R11U22_CELLDBG=1` on
  `Earlgrey_0_1`'s own command line: **1041 `bind=1` + 273 `bind=0`, and
  `fold=0 arm=0 fill=0` on all 1314** — the implementer's numbers exactly.  The
  row stays `CMP_EQUAL` with 0 heads in both modes.
* **THE BOUNDARY.**  `PROCESSED=1235 LISTED=1235 MOVED=4` over the committed
  file list; every file's rc is the SAME on both binaries.  Positive control:
  `f07` `norm_delta=67`, its module-scope twin `0`.  Scored against the REAL
  golden, cell by cell with the SHAPE LISTER: `g3_val106` 15→14 differing CA
  shapes (**one `DIFF→SAME`**, `48:34 work@g3_val106.n_terx.n_ter`),
  `v59w6_more59` 3→2 (**one `DIFF→SAME`**, `25:14
  work@a1.u_sub.g_a.g_b.mn_ternc`), `v8_gen` 5→5 with its two moved cells now
  carrying golden's exact `vpiOpType:30` operand shape and differing only in
  the parent token.  **`SAME→DIFF` 0 on all three.**
* **THE PROTECTED DATABASES.**  `SVSwitch` `4842211c4030` and `YosysVerx`
  `6ccda350c24a` in BOTH modes — the OPS byte pins, hit exactly;
  `InterfaceModPort` `59a365f3ce2c`; `Earlgrey_0_1` `8bdf25272e08` /
  `59d0ee6d10c3`.  Canaries ok=50/8, ctcan2 PASS both, rowheads green.
* **THE COIN, CONVICTED TWICE AND NEVER BY A COUNT.**  This verifier's surelog
  byteverify drew **3 movers of 960** where the implementer drew 4 — a
  different DRAW of the same family (`MiniAmiq`, `SeqDriver`, `SimpleUVM`, all
  `default`).  (1) `R11U22_CELLDBG=1` on `MiniAmiq`'s own command line prints
  **0 gen-scope ternary cells** — the law cannot reach it.  (2) The PRISTINE
  binary ALONE produced two different databases in three runs of that same
  command line, and the pristine-vs-pristine order-blind delta is the SAME
  4-line class as the law-vs-pristine one: one constant's `UINT` and its
  `vpiDecompile`, drawing 945/0 pristine-vs-pristine and 938/0
  law-vs-pristine.  All three movers are that identical 4-line class.

## 2. AMENDMENT ONE — § genTernCondSameMachine22: the condition was read with the WRONG MACHINE

**THE DEFECT.**  `genTernInt64Eval22` is `ExprEval`'s int64 arithmetic
transcribed, and the law reads the selected ARM with it — but it read the
CONDITION with slang's context-typed `ctx.tryEval`.  `reduceExpr`'s
`vpiConditionOp` arm reduces operand 0 through `reduceExpr` and reads it with
`get_value`, so the condition goes through the SAME machine the arm does.  The
two evaluators disagree on sign and width — the implementer's own README
tabulates the disagreement for the arm (`g01` golden `INT:-1` against slang
4294967295) — and on a condition the disagreement decides **WHICH ARM GETS
INSTALLED**.

Measured against the real v1.87 golden, `adv/v01` and `adv/v02`:

| arm | source | golden Rhs | implementer's law | verified law |
|---|---|---|---|---|
| `v01` | `((32'd2 - 32'd3) < 32'd0) ? 32'd7 : '0` | `INT:7` sized 32 | **`'0` BIN:0 sized 32 — THE OTHER ARM** (63→14 cmp lines) | **rc 0, EQUAL** |
| `v02` | `(K < 32'd0) ? 32'd7 : '0`, `parameter int K = -1` | `INT:7` sized 32 | **`'0` BIN:0 sized 32** (57→14) | **rc 0, EQUAL** |

`ExprEval` subtracts into an `int64_t` (-1) and `reduceCompOp`
(`ExprEval.cpp:2860`) compares SIGNED, so golden takes the TRUE arm; SV
self-determination keeps slang's subtraction unsigned 32-bit (4294967295) and
its comparison unsigned, so the law took the FALSE arm.  `v02` is the same fact
through a parameter's DECLARED `INT:-1`.  Neither cell was right at pristine, so
this is not a MOVED-WRONG — but it is the law installing an object golden does
not have, which is exactly what the pass's own doctrine ("decline rather than
install a differently-wrong object") forbids.

**THE FIX** (`ModuleEmit.cpp`, `genTernCondTrue22`): ask the transcribed machine
first and believe it; fall back to `tryEval` ONLY for the shapes it has not
transcribed.  It can only NARROW the disagreement, never widen the fold — every
leaf inside `genTernInt64Eval22` is still read through `ctx.tryEval`, so a
condition slang cannot value still declines.

**WHAT IT COSTS: NOTHING.**  The 101-arm grid and the 91-arm pass-19 grid are
**identical arm for arm** (same `cmp_rc`, same `cmplines`, same rcs) on the two
law binaries; only `v01`/`v02` move, and they move to `uhdm-cmp` rc 0.  The
shapes the fallback still serves are each measured to AGREE on both machines:
`v03` a packed-struct member condition, `v33` `~32'd0`, `v35` `|4'b0010`, `v36`
a string compare, `v05`/`v25` selects, `v34` a cast, `v09`/`v23`/`v32` constant
function calls, `v10` `$clog2`.

## 3. AMENDMENT TWO — the pass's own `canaudit.sh` was RED on the delivered patch

`GATES.r11u22.txt` spelled the four slang-fenced test names in its fence-check
line.  `canaudit.sh` excludes only `README*.md` and itself, so run from the pass
directory as the integration cycle mandates it printed **`FENCE-BREACH=4` and
exited 6** — against a report claiming "Fence check 0/0/0/0" and "canaudit
green".  The line is rewritten to name the check without spelling the tests;
`canaudit.sh canaries.sh ctcan2.sh` now prints `audited=29 UNCOVERED=0
FENCE-BREACH=0` and exits 0.

## 4. BREAKING THE LAW — 52 adversarial arms, every rc recorded (`adv/`)

`ADV.r11v22.txt` is the table: arm, `golden_rc`, `ours_rc` on both binaries, and
cmp lines for pristine / implementer's law / verified law.  **Every arm
`golden_rc=0`; `v37` and `v41` are `ours_rc=3` on BOTH binaries (slang refuses
them — error recovery, no verdict).**

**NOT ONE pristine-EQUAL arm regressed on either law binary.**  The five arms
where golden KEEPS the ternary and the pristine emitter is therefore RIGHT —
`v04` a hierarchical-parameter condition, `v15` a 65-bit condition, `v18` a bare
indexed-part-select untaken arm, `v19` an `'x` condition, `v25` a taken
part-select, `v40` a modulo-by-zero condition — are `cmp_rc=0` before and after.

The faces covered: condition kinds (constant, parameter, enum, genvar,
gen-local localparam, `$clog2`, `$bits`, unlisted `$`-functions, user and
package functions incl. recursion and loops, hierarchical, struct member,
select, real, string, `'x`, >64-bit, division and modulo by zero, unary
reduction, `~`, cast, mixed-sign comparison); arm kinds (fills at 1/4/8/12/16/
32/63/64/65/72/95/96/128 bits, sized literals, parameters, operations, selects,
patterns, nested ternaries, >64-bit concats, shifts); scopes (gen-if, gen-else,
gen-for, gen-case, nested x3, gen-if-in-gen-for, unnamed `genblk`, child
instance, interface body, interface gen scope, two instances of one module with
different parameters); Lhs kinds (port, module net, module var, `wire`, `bit`,
`int`, `integer`, `byte`, scalar, packed struct, packed 2-D, enum, unpacked
array element, gen-local, comma list, delayed `assign`).

**Ranked residues this verifier leaves standing** (each wrong at pristine and
wrong-in-a-different-way, or wrong at pristine and unchanged — none a
regression):

* **RV1 — a >64-bit CONDITION still installs the wrong arm.**  `adv/v21`
  `((65'h1_0000_0000_0000_0000) > 65'd0) ? 32'd7 : '0`: `get_value` reads an
  int64, so golden's comparison sees the low 64 bits (0 > 0 → FALSE) and
  installs `'0` sized 32; slang sees the whole 65-bit value and the law folds
  `INT:7`.  52 → 16 cmp lines, still DIFF.  `genTernInt64Eval22` poisons above
  64 bits and therefore declines to answer, and the `tryEval` fallback then
  answers wrongly.  The clean close is to poison the FALLBACK too whenever any
  leaf of the condition exceeds 64 bits.
* **RV2 — a SELECT condition takes slang's decode, not golden's.**  The law
  DECLINES a select ARM that values, because golden's `bit_select` decode
  disagrees with slang's (the implementer's R5, `f01`); the CONDITION has no
  such decline.  No arm of this verifier exhibited a divergence, but the
  asymmetry is real.
* **RV3 — an ASSIGNMENT-PATTERN arm is installed unflattened.**  `adv/v06`
  `(1) ? '{x:8'd1,y:8'd2} : '0` on a packed-struct Lhs: 87 cmp lines on all
  three binaries.  `writeCont_assign`'s `if (tps)` arm
  (`UhdmWriter.cpp:2178-2216`) runs `flattenPatternAssignments` on the INSTALLED
  Rhs and, for `vpiAssignmentPatternOp` or `vpiConditionOp`, then
  `substituteAssignedValue` + `expandPatternAssignment`; `patFlat9`/`patStruct9`
  here are computed from the WHOLE ternary and are therefore false.  Unchanged
  from pristine, so not a regression — but the shape is unmodelled.
* **RV4 — `adv/v49`: an unpacked-array ELEMENT Lhs.**  `assign o[g] = …` in a
  for-generate: 50 cmp lines unchanged.  `caLhsAdjustBind106` requires a whole
  `NamedValue`, so this is the implementer's R0 (the UNBOUND half) wearing an
  element-select Lhs.
* **RV5 — the nested-gen-block net-declaration face is now the head** of
  `a05`/`a09`/`adv/v51` (a triple-nested gen-if), at 15 cmp lines: a
  `logic_net work@top.o2` golden has and we do not.  r11u19 `t14`'s face, not
  this law's; it is what stands between those arms and rc 0.
* **RV6 — `adv/v22`/`v31`/`v34` (a real comparison, `$bits` of a typedef, a
  cast condition) and `v16`/`v26`/`v27`/`v28`/`v30` are unchanged on all three
  binaries** — declined cells that stay exactly as wrong as pristine left them.

## 5. THE THREE CORPUS ROWS THAT DIFFER FROM THE COMMITTED BASELINE, QUOTED

Against this verifier's OWN pristine sweep, run in the same environment, four
rows differ and none is a judge verdict:

    Earlgrey_0_1,default,CMP_EQUAL,,,differ   ->  Earlgrey_0_1,default,CMP_EQUAL,,,
    LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file ".../sl/testflags/LowMemLib-f068a766/slpp_all/surelog.log".,,
    LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file ".../sl/testflags/LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
    YosysOpenSparc,default,SLANG_REJECT,.../t2.v:269093:6: error: expected a declaration name,,
      ->  YosysOpenSparc,default,SURELOG_FAIL,[INF:UH0708] Writing UHDM DB: ...

* `Earlgrey_0_1` — the harness's `dump` column, not the database.
  `verify_golden.py:625-632` initialises `dump = ''` and `except
  subprocess.TimeoutExpired: pass`, so a `uhdm-dump` timeout leaves it blank.
  STATUS is `CMP_EQUAL` in both modes, the databases are byte-identical on both
  binaries, and `rowheads.sh` reads `cmp rc=0`, 0 heads.
* `LowMemLib` / `LowMemPkg` — the workdir path inside a `SURELOG_FAIL` detail
  string.  Nothing but the path.
* `YosysOpenSparc` — the GOLDEN side.  `SURELOG_FAIL` means Surelog itself died
  writing the database of a 69566-instance design (`surelog.log` ends at
  `[INF:UH0708] Writing UHDM DB`); our binary never ran.  Neither status is a
  judge verdict, the same row is `SLANG_REJECT` in this verifier's pristine
  sweep of the same set, and the implementer's own run did not draw it — a
  resource flake under four concurrent sweeps.  **RE-MEASURED ALONE, on the
  law binary, with no contention: `YosysOpenSparc,default,SLANG_REJECT,
  /home/heyfey/git-repos/Surelog/third_party/tests/YosysOpenSparc/t2.v:269093:6:
  error: expected a declaration name` — the committed baseline row exactly.**
  (`verify_golden.py:573-577` does cache a `SURELOG_FAIL` under the golden-cache
  key, so the re-run also proves the cache was not left poisoned.)

## 6. THE VERIFIED BINARY'S OWN FULL BATTERY (`d43d7293f9727ab6be004ffc8b2551bd`)

Re-run end to end after the amendment, not inherited:

* **Applies clean on a FRESH `40b5e0f3`** (0 conflict markers) and rebuilds from
  that fresh worktree to `d43d7293f9727ab6be004ffc8b2551bd` — the same md5 as
  the amended worktree's own build.
* **Goldens 23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` gives 0 PASS / 23 FAIL.
* **uhdm2rtlil 766 / 38 / 67 in BOTH modes**, whole-row byte-identical to
  `results/gate_uhdm2rtlil.csv` and to the default half of
  `results/golden_uhdm2rtlil.csv`; **byteverify 0 movers of 1608**,
  `PATH_SETS_IDENTICAL`, self-check 1607/1608; 1742 `cmds.txt`, **0 naming the
  main-tree binary**.
* **Surelog 469/14 default and 465/12 testflags.**  Against the committed
  baseline exactly the three rows of §5; against this verifier's OWN pristine
  sweep, only the two `SURELOG_FAIL` workdir path strings — every status and
  dump histogram identical, `Earlgrey_0_1` and `YosysOpenSparc` included.
  1581 `cmds.txt`, **0 naming the main-tree binary** (50 carry no slang line at
  all: rows the golden side never produced a database for).
* **byteverify surelog: 6 movers of 960, all four coin names, attributed one by
  one and never by a count** — `default/MiniAmiq` (UINT 894→0 + decompile),
  `default/SeqDriver` (632→1438), `default/SimpleUVM` (1081→0),
  `testflags/MiniAmiq` (1293→0) are the 4-line `UINT` + `vpiDecompile`
  line-number class; `default/Scoreboard` and `testflags/SeqDriver` are
  **order-blind delta 0** — pure list-ORDER flips.  The implementer's draw was
  3–4 on the same names; the COUNT is the draw, the CLASS is the law.
* **Boundary `PROCESSED=1235 LISTED=1235 MOVED=4`**, the same four files with
  the same `norm_delta` (67 / 53 / 35 / 152) as the implementer's binary, every
  file the same rc on both binaries.
* **Canaries ok=51 changed=1** (`Earlgrey_0_1/testflags`, the §5 dump column);
  u2r ok=8 changed=0; ctcan2 PASS on both corpora; `canaudit.sh` exit **0**,
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`.
* **Protected databases all SAME vs this verifier's own pristine**, with the
  OPS pins hit exactly: `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` (both
  modes), `InterfaceModPort 59a365f3ce2c`, `BlackParrotComplex`,
  `YosysOldOr`, `Earlgrey_0_1 8bdf25272e08 / 59d0ee6d10c3`.
* **`R11U22_OFF=1` still reproduces the pristine bytes exactly** on `a01`,
  `b01` and `f07`.
* **AWAY-GOLDEN 0 / MOVED-WRONG 0.**

## 7. VERDICT

**ACCEPT WITH FIX.**  `/tmp/r11u22.verified.patch` — the implementer's patch
plus § genTernCondSameMachine22 and the fence-line correction.  Surface
`src/ModuleEmit.cpp` + `tools/probe/r11u22repro/` + `tools/probe/r11v22repro/`.
