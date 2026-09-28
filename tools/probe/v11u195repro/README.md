# v11u195 — adversarial verification of r11u195: every headline number reproduced; § evalFuncExecCallArgTs191 with § evalFuncOpReduceGate195 broke 14 fresh EQUAL cases (four new refinements: the operand kinds reduceExpr admits, a ternary branch, an all-constant return, the all-constant visit) and § funcCfgPatOpRefBare195 broke 3 (the struct's declaring scope, a positional pattern); all 17 are EQUAL again and no corpus or probe database moves against the implementer's law binary

**Base.** `b6344400` (branch matrix-1.87, pass 192). Worktrees `/tmp/wt_v11u195pris` (pristine) and `/tmp/wt_v11u195`
(`/tmp/r11u195.patch` applied, then this verification's refinements), system-deps config, `-j 2`. Ground A only: the
refinements edit `src/ExprEmit.cpp` and `src/ParamEmit.cpp`. Nothing under `results/`, `tests/` (but the regenerated
`tests/LAWS.md`) or `third_party/` is edited. The sister pass 193 has landed on the branch since (`b8719ea92`); this
verification is measured at `b6344400`, as the brief sets.

**The fence.** `drivers/env.sh` reads the four names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`
and every driver refuses a fenced path fail-closed; the firing census runs the corpora with a `--filter` built from the
fence; the byte comparison mirrors the corpus databases without the 8 fenced row-mode databases (`fenced_skipped=8`).
The gate sweeps dispatched every row; their csv verdicts are the only fenced facts cited. A grep of this directory for
the four names reads 0.

## 0. Verdict

**r11u195 holds on every headline number, and breaks on legal SV in two of its laws.** The implementer's binary
(`6e9366b66a6c`) reproduces bit for bit: the 106-case grid table (pristine and law columns, counts included), the
sweep deltas (probe `0/7/3`, surelog `0/2/11`, uhdm2rtlil `0/0/0`), downstream 803 / 66 / 2 / 0 with `downstream.csv`
byte-identical to the pristine sweep's and 0 of 805 downstream-lane databases moving, the 17 corpus + 10 probe byte
movers (exactly the frozen prediction's 27 names), the canaries and the UVM order-blind deltas (−108 / −124 / −84 /
−64 / −36).

Fresh cases broke two laws, pristine right and the law wrong, on legal SV (all judge-equal, all downstream IDENTICAL):

* § evalFuncExecCallArgTs191 as refined by § evalFuncOpReduceGate195 stamped the formal's typespec on 14 actuals
  golden leaves bare (EQUAL -> `type(1)`): a part select or a module net beside the call (e01 e06 e12 e16 e18), a call
  in a ternary branch (e04 e05 e08 e15 e31 e36), and the return expression of an all-constant run (e13 e14 e26).
* § funcCfgPatOpRefBare195 unparented the pattern reference of 3 parameters golden keeps parented (EQUAL ->
  `fullname(1..3)`): a package struct whose dimension name the module shadows (f05), a positional pattern (f09 f10).

All 17 read EQUAL again with six refinements, each behind its own switch (section 3). The refinements fire on no corpus
row-mode and no probe case (the census, section 4), so the delivered binary is byte-identical to the implementer's
on every non-fenced database; the final sweep reproduces the implementer's verdicts exactly (section 5).

## 1. Binaries (frozen `chmod 555` in `/tmp/v11u195_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `6d53eebe71a2327f4e3c89a48c6886a4` | `/tmp/wt_v11u195pris` at `b6344400`: byte-identical to the base build the brief names |
| `law.bin` | `6e9366b66a6caf3d348dbb935ef02652` | `b6344400` + `/tmp/r11u195.patch`, built here: byte-identical to the implementer's `lawG.bin` |
| **`fix1.bin`** | **`24077a17c2469ba3d47eb3e49dd666cf`** | **the delivered sources** (`/tmp/r11u195.verified.patch`) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | both worktrees build it identically |

Sweeps (`tests/sweep.sh --jobs 3`, same-length workdirs): `/tmp/v11u195_swP` (pristine), `/tmp/v11u195_swL` (law; the
corpora stages and then the downstream stage, run after the pristine downstream stage finished), `/tmp/v11u195_swF`
(fix1). `cmds.txt` audit ([evidence/sweeps/cmds_audit.txt](evidence/sweeps/cmds_audit.txt)): swP 3273 of 3273
`slang:` lines name `pris.bin`, swL 3273 of 3273 `law.bin`, swF see section 5. The pristine and law sweeps ran the
harness of the pristine worktree (identical to the patched tree's): its `law_index.py --check` reads STALE at
`b6344400` because `git log` now shows the base commit's own message (the self-reference every landing has); it is the
sweeps' only nonzero exit.

## 2. Reproduction of the implementer's numbers

| claim | implementer | measured here |
|---|---|---|
| pristine sweep | probe byte-identical to the baseline, 0/0/0 both corpora, downstream 803/66/2/0 | the same: `probe.csv` byte-identical to `b6344400:results/golden_probe.csv` (EQUAL 3155 / STRICT_NOTEQUAL 932); surelog and uhdm2rtlil `regressions=0 conversions=0 changes=0`; downstream EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 |
| law sweep, probe | `0/7/3`: g1_earl62, g2_earl62, a9, f1 c01 c02 c03 c05 convert; c04 c06 `fullname(5) -> value(2)`; m12 `line(5) -> fullname(4)` | identical, line for line ([evidence/sweeps/swL.summary.txt](evidence/sweeps/swL.summary.txt)) |
| law sweep, surelog | `0/2/11`: StructParamPatternInitCast d/t convert; Earlgrey d/t `col(91) -> fullname(82)`; MiniAmiq d/t 27 -> 25; SeqDriver d/t 26 -> 24; SimpleUVM d/t, Scoreboard d 54 -> 52; Scr1SvTests d/t `type(1) -> endcol(29)` | identical |
| law sweep, uhdm2rtlil | `0/0/0` | identical |
| downstream | 803/66/2/0, csv byte-identical to pristine, 0 of 805 lane databases move | identical (`cmp` of the two csvs reads equal; 0 of 805 `slang` lane databases differ) |
| byte movers | 17 of 2560 corpus (8 fenced left out), 10 of 4087 probe, all predicted | 17 / 2560 (`SELFCHECK` 2559 / 2560 flagged), 10 / 4087; the set equals the frozen `r11u195repro/evidence/census/predicted_movers.txt` name for name |
| canaries | surelog ok=43 changed=9, u2r ok=16 changed=0, both ctcan2 PASS | identical |
| UVM order-blind | −108 / −124 / −84 / −64 / −36 | identical ([evidence/uvmdist_pris_law.txt](evidence/uvmdist_pris_law.txt)) |
| grid | 106 cases, the README table | all 106 rows reproduce exactly, pristine and law verdicts and counts |
| r11u191dec cases | as the decode measured | law and fix1 byte-identical on all 67 that build (g_g01, n_e01 rc=3 in every binary) |

## 3. The breaks and the refinements

The fresh cases are under [cases/](cases/) (89; every case names its law in its first line; `args` lists several root
files). [evidence/grid.tsv](evidence/grid.tsv) has the three verdicts per case (`=` marks bytes equal to the previous
column); [evidence/grid_orderblind.txt](evidence/grid_orderblind.txt) the order-blind distance of every case that does
not end EQUAL; [evidence/switchcheck.txt](evidence/switchcheck.txt) each refinement switch alone (`L` = the law
binary's bytes, `F` = fix1's, `=` law and fix1 already equal); [evidence/offcheck.txt](evidence/offcheck.txt):
`R11V195_OFF=1` gives the law binary's bytes and `R11U195_OFF=1` the pristine bytes on all 89 cases.

### 3.1 The evaluator laws (§ evalFuncExecCallArgTs191 + § evalFuncOpReduceGate195)

**Decode** (UHDM `templates/ExprEval.cpp`, `reduceExpr`'s operation branch, and `evalStmt`). Before the operator
switch, a `constantOperands` pre-check walks the operation's operands: a `ref_obj` needs `getValue` to find a value,
an operation, call, system call, bit or var select, hier_path or enum passes, and ANY other kind (a `part_select`, an
`indexed_part_select`) makes the whole operation come back unreduced, its calls never evaluated. The `vpiConditionOp`
case reduces the condition and then only the taken branch; a condition it cannot bring to a value breaks before either
branch. And in an all-constant run the return expression's calls keep bare actuals in golden while the same calls in an
assignment are stamped (measured, e13 e14 e26 e28 against e25 e27 e28; the decode of why stops at `evalStmt`'s
`uhdmreturn_stmt`, which reduces the expression like an assignment: the all-constant call is folded by another route).

| case | shape (function called by a continuous assignment) | pristine | law | fix1 | law that fixes it |
|---|---|---|---|---|---|
| E/e01 | `return lv[7:6] + g(lv[1:0]);` non-constant | EQUAL | `type(1)` | EQUAL | § evalFuncOperandKinds195v |
| E/e12 | `r = lv[7:6] + g(lv[1:0]); return r;` | EQUAL | `type(1)` | EQUAL | § evalFuncOperandKinds195v |
| E/e18 | `return g(lv[1:0]) + lv[7:6];` | EQUAL | `type(1)` | EQUAL | § evalFuncOperandKinds195v |
| E/e06, e16 | a module net beside the call (`w + g(...)`, `g(...) + w`) | EQUAL | `type(1)` | EQUAL | § evalFuncOperandKinds195v |
| E/e07 | a formal beside one call (stamped), an indexed part select beside another | `type(1)` | `type(1)` | **EQUAL** | § evalFuncOperandKinds195v |
| E/e04, e15, e31 | a call in an branch of `(W > 2) ? 4'd0 : g(...)` (taken or not; a module-parameter condition) | EQUAL | `type(1)` | EQUAL | § evalFuncTernaryArm195v |
| E/e05, e36 | a call in an branch of a local-bit condition, non-constant | EQUAL | `type(1)` | EQUAL | § evalFuncTernaryArm195v |
| E/e08 | all-constant, the call in the untaken branch | EQUAL | `type(1)` | EQUAL | § evalFuncTernaryArm195v and § evalFuncConstReturnBare195v |
| E/e13, e14, e26 | all-constant, `return 4'd1 + g(lv[1:0]);` / `return g(...) + 4'd3;` / on the formal | EQUAL | `type(1)` | EQUAL | § evalFuncConstReturnBare195v |
| E/e28 | all-constant, a call in an assignment (stamped) then one in the return (bare) | `type(1)` | `type(1)` | **EQUAL** | § evalFuncConstReturnBare195v |
| E/e39, e40 | all-constant, `r = g(x[1:0]) + (4'd3 ^ g(x[5:4]))` / `+ (x[7:4] + g(x[5:4]))` | `type(1)` #43 | `type(1)` #54 | `type(1)` #148 (the next face) | § evalFuncConstVisitGate195v |
| E/e11 e17 e19 e33 e34 e37 e38 | a literal, a local, a bit select, a module parameter or localparam, a unary over the call, a unary over a part select beside the call | `type(1)` | EQUAL | EQUAL | controls: stamped |
| E/e32, e35 | the call in the taken branch of a literal condition | `type(1)` | EQUAL | EQUAL | controls |
| E/e23 e25 e27 | all-constant assignments (`r = 4'd1 + g(...)`) | `type(1)` | EQUAL | EQUAL | controls: § evalFuncExecCallArgTs191's all-constant mode holds for assignments |

The refinements (ExprEmit, in `evalOpPathOk195` and the evaluator walk; each reads its own switch, `R11V195_OFF` drops
all six and `R11U195_OFF` the whole pass):

* **§ evalFuncOperandKinds195v** (`R11V195_EVALOPND_OFF`): every binary operation and conditional on the path to the
  call must hold no operand that is a range select (part select or indexed part select) and no name of a net or a
  variable declared outside the subroutine; otherwise the walk abstains.
* **§ evalFuncTernaryArm195v** (`R11V195_EVALTERN_OFF`): a call written in an branch of a conditional is met only when
  the condition is an integer literal selecting that branch; a call in the condition is unaffected (the r11u195 grid's
  G/g22 keeps its conversion).
* **§ evalFuncConstReturnBare195v** (`R11V195_EVALRET_OFF`): in the all-constant run the return statement's calls are
  not stamped.
* **§ evalFuncConstVisitGate195v** (`R11V195_EVALVISIT_OFF`): the all-constant run's claim of every other call of the
  statement passes each through the same operator gate (a call argument passes through).

Each switch alone restores the law binary's bytes on its own cases (switchcheck: EVALOPND e01 e06 e07 e12 e16 e18 e29
e40; EVALTERN e04 e05 e15 e20 e31 e36; EVALRET e13 e14 e22 e26 e28; EVALVISIT e39 e40); e02 e03 e08 need two of them
off.

### 3.2 § funcCfgPatOpRefBare195

| case | shape | pristine | law | fix1 | law that fixes it |
|---|---|---|---|---|---|
| F/f05 | a package struct `it_t` sized by the package's `X = 8`, the module declaring its own `X = Cfg.XLEN` | EQUAL | `fullname(3)` | EQUAL | § funcCfgPatDeclScope195v |
| F/f01 | the same shadowing in a judge-unequal shape | NOT_EQUAL 192 | 197 | 192 | § funcCfgPatDeclScope195v |
| F/f10 | a positional pattern `'{1, 3}` | EQUAL | `fullname(1)` | EQUAL | § funcCfgPatNamedOnly195v |
| F/f09 | the positional pattern with macro-born dimensions | EQUAL | `fullname(1)` | EQUAL | § funcCfgPatNamedOnly195v |
| F/f11, f14, f15 | the named twin with macro-born dimensions; `'{default: 1}`; `'{S: 2, default: 1}` | `fullname(3)` | EQUAL | EQUAL | controls: the law holds |
| F/f12 | two patterns of the struct in one module | `fullname(6)` | EQUAL | EQUAL | control |
| F/f07 | two patterns in a leaf at depth 2 and at depth 1 | `fullname(16)` | `fullname(4)` | `fullname(4)` | residue R5 |

* **§ funcCfgPatDeclScope195v** (`R11V195_FCPSCOPE_OFF`, ParamEmit `funcCfgPatSized195`): the law resolves the
  struct's dimension names from the parameter's module; a struct declared anywhere else (a package typedef) declines.
* **§ funcCfgPatNamedOnly195v** (`R11V195_FCPPOS_OFF`): a positional (simple) assignment pattern declines.

### 3.3 The other laws: fresh cases hold

* § procNetMidSelDotted195: K/k06 (an event control and a nonblocking read), k07 (a call argument), k08 (a case
  expression and item), k10 (the path two levels down in plain array indices; unary and call indices on the mid
  select), k13 (an inc/dec of an array indexed by the path, the path in a call argument inside an index) and k01
  convert; k09 (processes in one- and two-level for-generates) EQUAL on every binary; k02 k04 k05 k11 k12 (a procedural
  `force` on the port, struct-typed wires) are judge-unequal on other faces and their order-blind distance falls
  (76 -> 66, 59 -> 51, 53 -> 31, 30 -> 26, 49 -> 39); k03 unchanged.
* § pkgPatMemberReadAtValue195: P/p01-p09 (a parameter-reference value, a unary, a concatenation, a system call, a
  parenthesized product, a pattern in another package and another root file with a macro-born value from an included
  header, a narrower reader) are all judge-unequal on other faces; every distance falls, and the folded readers'
  constants sit where golden's do (p07: `W` 4:33-34 and the macro-born `V` 4:28-29 in `q.sv`).
* § tagPatParenSpan195: T/t01 (continuous assignment, a ternary value, nested parentheses), t03 (a function's return
  pattern), t04 (a parenthesized ternary and concatenation, a macro-born parenthesis), t06 (a macro from an included
  header in another root file) convert; t05 (an index setter beside a parenthesized `default:`) `col(6) -> col(2)`;
  t02 judge-unequal, 74 -> 46.
* § idxCallPathAtDots191: A/a01 `fullname(11) -> fullname(3)`, A/a02 `col(6) -> col(4)` (the remaining records are the
  bit_select span over a call index, residue R6).
* § pkgFoldAtLeadingLeaf191: B/b04 (a package parameter read by a generate condition and a for-generate bound) and
  B/b05 (macro-born leaves from an included header in another root file) convert; B/b01-b03 (a unary minus, a cast,
  a system call, a nested product, a shift as taken branches) judge-unequal, distances falling.

Downstream (`drivers/ds.sh`, the harness's `one()`): E/e01 e04 e11, K/k06 k08 k10, T/t01 t04, F/f05 f12 read
IDENTICAL with all three binaries ([evidence/downstream_fresh.txt](evidence/downstream_fresh.txt)).

## 4. The prediction (frozen before the fix sweep)

`drivers/census.sh` ran `fix1.bin` over every probe case and every corpus row-mode but the fenced four, with
`R11U191_TRACE` / `R11U195_TRACE` set; every refinement traces where it declines what the law would have claimed.
[evidence/census/predicted_fix_vs_law.txt](evidence/census/predicted_fix_vs_law.txt) (`chmod 444`): the 27 rows where
the r11u191 / r11u195 laws fire, exactly the law movers, and **0 firings of any refinement**. Positive control
([evidence/census/positive_control.txt](evidence/census/positive_control.txt)): the same trace on e01 e04 e13 e39 f05
f10 names each refinement once. Predicted: fix1's databases byte-identical to law.bin's on every non-fenced corpus
row-mode and probe case.

## 5. Gates of the delivered binary (`/tmp/v11u195_swF`)

| gate | pristine `6d53eebe71a2` (`/tmp/v11u195_swP`) | law `6e9366b66a6c` (`/tmp/v11u195_swL`) | **fix1 `24077a17c246`** (`/tmp/v11u195_swF`) |
|---|---|---|---|
| (1) build | the base build | `b6344400` + `/tmp/r11u195.patch` | `b6344400` + `/tmp/r11u195.verified.patch` |
| (2) probe vs golden_probe.csv | EQUAL 3155 / 932, `0/0/0` | EQUAL 3162 / 925, `regressions=0 conversions=7 changes=3` | the same; `probe.csv` byte-identical to the law sweep's |
| (3) surelog | `0/0/0` | `regressions=0 conversions=2 changes=11` | the same; `surelog.csv` equal to the law sweep's but the LowMemLib / LowMemPkg testflags detail text (the workdir path in Surelog's log line: environment) |
| (3) uhdm2rtlil | `0/0/0` | `0/0/0` | `0/0/0`, csv byte-identical |
| (4) downstream | 803 / 66 / 2 / 0 | the same, csv byte-identical to pristine | the same, csv byte-identical to pristine; 0 of 805 downstream-lane databases move |
| (5) uhdm-cmp | | every mover keeps its judge status | every mover keeps its judge status (the fresh rows below) |
| (6) byteverify (`SELFCHECK=1`, mirrors with `fenced_skipped=8`) | | 17 / 2560 vs pristine, SELFCHECK 2559 / 2560 | 17 / 2560 vs pristine (the same 17 names); **vs law 6 / 2560**: MiniAmiq d/t, SeqDriver d/t, SimpleUVM d, Scoreboard d, each 0 or 4 order-blind dump lines (`|UINT:1118` / `|UINT:1271` and their `vpiDecompile`), the known UVM value coin ([evidence/sweeps/fix_vs_law_coin.txt](evidence/sweeps/fix_vs_law_coin.txt)); probe 0 / 4087 vs law (re-run from the same tree paths, `/tmp/v11u195_prF`) |
| canaries | ok=52 changed=0 / u2r ok=16 | surelog ok=43 changed=9, u2r ok=16 changed=0, both ctcan2 PASS | the same |
| cmds.txt | 3273 / 3273 `pris.bin` | 3273 / 3273 `law.bin` | 3273 / 3273 `fix1.bin` |

The prediction held: no refinement fires in the gate and no non-fenced database but the UVM coin moves against the law
binary. The status census of the fix sweep is the implementer's, line for line:
[evidence/sweeps/swF.summary.txt](evidence/sweeps/swF.summary.txt). The fresh rows (not written to `results/`):

    StructParamPatternInitCast,default,CMP_EQUAL,,,equal       (baseline STRICT_NOTEQUAL differ:fullname(3))
    StructParamPatternInitCast,testflags,CMP_EQUAL,,,equal     (baseline STRICT_NOTEQUAL differ:fullname(3))

UVM order-blind distances with fix1 ([evidence/uvmdist_fix.txt](evidence/uvmdist_fix.txt)): 15963 / 12337 / 4986 /
3813 / 2035, the law binary's. Earlgrey_0_1 default with each law off alone on the law binary
([evidence/attrib_earlgrey.txt](evidence/attrib_earlgrey.txt)): `R11U195_PROCNETSEL_OFF` `fullname(90)`,
`R11U191_EARLCOL_OFF` `col(83)`, `R11U191_EVALTS_OFF` `fullname(82)`: the implementer's attribution (91 = 82 + 8 + 1).
The sweeps exit 1 for the law index only (section 1); `python3 scripts/law_index.py --check` reads current on the
delivered tree.

## 6. Ranked residues

1. **The evaluator's fold decision** (E/e39 e40 after the refinements, e02 e03 e20 e29 on every binary): when the
   function body holds an operation reduceExpr cannot reduce, golden keeps the continuous assignment's call as a
   `func_call` while ours folds it to a constant (`#148 type func_call` vs `constant`). The fold is decided at the
   continuous-assignment emission (ModuleEmit), the sister ground: its contract is reduceExpr's `constantOperands`
   rule of section 3.1.
2. **§ evalFuncExecCallArgTs191's non-constant stop** (E/e30): the law stops the non-constant run at the first call,
   but golden runs on when the callee's body returns an unreduced value without flagging it (a concatenation,
   `{2'b00, d}`), stamping a later statement's call too; with a reduction (`|d`, r11u191's V/v01) it stops. Not
   modelled; the law abstains (no regression).
3. **The ternary condition over a module parameter** (E/e31): golden does not evaluate `(W > 2) ? g(...) : ...` in the
   function although `W + g(...)` is (e33); § evalFuncTernaryArm195v abstains on every non-literal condition, which
   also gives up the conversions a module-parameter condition that golden does evaluate would bring (none measured).
4. r11u195's own residues, unchanged: R1 (UVM N0175, the method-call operation arguments on a path), R2 (UVM_MACRO_*
   full names), R3 (the XOR/case-equality continuation), R4 (K/k12's nested path), R5 of r11u195 (a member read inside
   another pattern), R6 (ExprEval values), R7 (T/t10 nested pattern tags), R8 (§ funcCfgPatOpRefBare195's limits,
   now also a package-declared struct), R9 (§ idxCallPathAtDots191's receiver select, property path, spaced dot), R10
   (the carried faces).
5. **§ funcCfgPatOpRefBare195 across instances** (F/f07): two patterns of a leaf that is instantiated at depth 1 and 2
   name the second pattern's members through the first (`work@leaf.INT.S` where golden has `work@leaf.INU.S`); the
   single-instance twin F/f12 converts. The law shares the struct copy between the instances' parameters.
6. **The bit_select span over a method-call index** (A/a01 a02): golden ends the select after the call's `(`; the
   plain-select face r11u191 left.

## 7. Files, and how to reproduce

- `/tmp/r11u195.verified.patch` = `git diff b6344400` of `src/ExprEmit.cpp`, `src/ParamEmit.cpp`,
  `tools/probe/r11u195repro/` (the implementer's, unchanged), this directory and the regenerated `tests/LAWS.md`.
- Applied to a fresh `b6344400` worktree (`/tmp/wt_v11u195chk`), the patch applies clean (whitespace warnings from
  evidence text only); `src/ExprEmit.cpp`, `src/ParamEmit.cpp`, `tests/LAWS.md` and this directory come out
  byte-identical to the tree that built `fix1.bin`, and `law_index.py --check` reads current there.
- `drivers/`: `env.sh` (pins, the fence fail-closed, `REPO` from the script's location), `case.sh` (one case the way
  check_probe does; goldens cached per content md5 in `/tmp/v11u195_gold`), `judge.sh` (several binaries or switch
  settings side by side), `obd.sh` (order-blind distance), `sw.sh` (each refinement switch alone), `ds.sh`
  (downstream verdict of a case), `census.sh` + `censum.py` (the firing census), `bvmirror.sh` (the fence-free mirror
  for `tools/probe/r11v75repro/byteverify.sh`), `uvmdist.sh`.
- Reproduce: build `b6344400` and `b6344400` + the patch, freeze them as `/tmp/v11u195_bin/{pris,fix1}.bin`,
  `bash drivers/judge.sh "pris:pris.bin fix:fix1.bin" cases/*/*`, then `tests/sweep.sh --jobs 3 --workdir <wd>` once
  per binary.
