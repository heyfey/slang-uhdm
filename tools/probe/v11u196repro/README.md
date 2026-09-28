# v11u196: adversarial verification of r11u196 (the module/type ground, pair B)

Base `b8719ea9` (branch matrix-1.87, pass 193). Implementer's patch `/tmp/r11u196.patch` (md5 `184802c0...`),
applied unchanged. **Verdict: ACCEPT-WITH-FIX.** Every headline number of r11u196 reproduces bit for bit. One law,
§ evalFuncOmittedDefaultKeepsCall196, over-reaches on legal SV where pristine was right: a fresh probe case leaves
judge equality (DF/x03), and two others (DF/x01, DF/x05) grow their uhdm-cmp heads from 17 to 78 lines. Two
refinements behind their own switches fix it (section 3). The verified patch is `/tmp/r11u196.verified.patch`: the
implementer's patch, plus the refinements in `src/ModuleEmit.cpp`, this directory, and the regenerated
`tests/LAWS.md`. Nothing under `results/`, `tests/probe/` or `third_party/` is touched.

**The fence.** The four slang-fenced names come from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`.
Every driver here resolves its paths from the repo holding it and reads the names fail-closed (`drivers/env.sh`). The byte comparisons ran on hard-link mirrors that leave
the 8 fenced row-mode databases out (`drivers/mirror.sh`, `fenced_skipped=8`), and the determinism driver refuses
fenced rows. No fenced test was run, read or decoded outside the gate sweeps, which dispatch every row themselves.
The only fenced facts cited are their csv verdicts, which are unchanged.

## 1. Binaries (frozen `chmod 555` in `/tmp/v11u196_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris` | `4519cd58f7833bd1ac01afb706d3d45f` | `/tmp/wt_v11u196pris`, `b8719ea9`, system deps, `-j 2`; equals the main tree's `build/slang-uhdm` |
| `law` | `2ceb9c16dd0eb3d4bb4431d0bf56f289` | `/tmp/wt_v11u196`, `b8719ea9` + `/tmp/r11u196.patch`; equals the implementer's `law.bin` |
| `fix` | `1c10a904dd161e44764f3836631e1fc8` | `/tmp/wt_v11u196fix`, law + this verification's two refinements |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's `build/uhdm-strictcmp` |

Sweeps: `tests/sweep.sh --jobs 3`, all four stages, each run from its own worktree with the pins exported
(`drivers/sweep.sh`). The workdirs `/tmp/v11u196_swP`, `/tmp/v11u196_swL` and
`/tmp/v11u196_swF` have names of the same length. **Binary audit:** each sweep's corpus `cmds.txt` files name its own
binary on 3273 of 3273 `slang:` lines.

## 2. Reproduction of r11u196's headline numbers (all bit for bit)

| claim | measured here |
|---|---|
| pristine sweep = the committed baselines | probe `EQUAL=3299 STRICT_NOTEQUAL=788`, surelog 480/3 + 474/3, uhdm2rtlil 803/1 per mode, downstream `IDENTICAL=803 SLANG_REJECT=66 EQUIVALENT=2`, `regressions=0 conversions=0 changes=0` in all three compares. The sweep exits 1 only on `law index STALE`: at the base commit the index lacks pass 193's own commit, and regenerating it at `b8719ea9` fills in `caTernFillArmKept193`'s commit and nine others. |
| probe `regressions=0 conversions=2 changes=1` | the same: `r10vbuvm29repro/gv29_b_positions` and `v11u114repro/grid/set3/g13` read EQUAL, and `r11u108repro/grid/f4/c12_const_fold` goes `file(5)` to `file(4)` |
| surelog `regressions=0 conversions=0 changes=9` | the same nine lines (BuildUVMPkg d/t `fullname(20)` to `line(11)`; MiniAmiq d/t `file(27)` to `file(19)`; SeqDriver d/t `file(26)` to `endcol(18)`; SimpleUVM d/t and Scoreboard d `fullname(54)` to `fullname(46)`) |
| uhdm2rtlil `regressions=0 conversions=4 changes=2` | the same: const_cast_signext d/t and func_typename_ret d/t read CMP_EQUAL; arb_idx_cast d/t goes `endcol(17)` to `fullname(16)` |
| downstream 803 / 66 / 2 / 0 | the same; `downstream.csv` is byte-identical to the pristine sweep's |
| byteverify 125 movers | `MOVERS: 125 / 2560`, SELFCHECK 2559 / 2560; the **same path set** as the implementer's `evidence/byteverify.txt` |
| every mover in the frozen census | 0 corpus movers outside the census (`/tmp/r11u196_predicted_census.txt` was made read-only at 01:54:01 and the law sweep's workdir was created at 01:54:08: frozen before the sweep, and byte-identical to `evidence/predict_census_before_sweep.txt`); the 14 census rows that fire without moving are those named |
| probe 204 movers, all in the census | 204 of 4087, 0 outside the census. Both binaries were run from ONE source tree (`/tmp/v11u196_pr_*`): a probe database embeds its source path, so the two gate sweeps' probe databases, run from two worktrees, differ on all 4087 |
| UVM order-blind distances | MiniAmiq 7143 to 7003, SeqDriver 5801 to 5608, SimpleUVM 2579 to 2404, Scoreboard 1950 to 1806 (both modes equal, pass 168's `uvmdist.sh`); BuildUVMPkg 1036 to 998; Rggen d 4521 to 4521; Earlgrey_0_1 d/t 6746 / 6313 unchanged (`drivers/rowdist.sh`) |
| first records | every changed row's first differing record moves later: BuildUVMPkg #2834 to #3245, SeqDriver #1677 to #3473, arb_idx_cast #209 to #322; MiniAmiq stays at #899, SimpleUVM at #458 and Scoreboard at #466, each with a lower count |
| the grid: 53 cases, 4 strict-equal on pristine, 31 on law | the same 4 and 31 (`evidence/grid_impl.txt`); `fix` gives the same database as `law` on all 53 |
| canaries | surelog `ok=45 changed=7`, uhdm2rtlil `ok=16`; both ctcan2 checks PASS; the pristine sweep reads `ok=52` and `ok=16` |

## 3. The break: § evalFuncOmittedDefaultKeepsCall196 keeps calls golden folds

**The law as delivered** keeps a whole-Rhs call whose defaulted formal is omitted, whenever the body reads that
formal *anywhere*. **Golden's rule** is `ExprEval::evalFunc` (UHDM `templates/ExprEval.cpp`). It binds only the
call's own arguments and then EXECUTES the body: an if or case statement runs the branch its condition selects, a loop
runs its body only while its condition holds, a return ends the evaluation, and an assignment overwrites a value.
The unset formal therefore poisons the call only when its value reaches the returned result on the path that runs.
The fresh cases `cases/DF` show the difference (goldens from the v1.87 pin):

| case | golden | pristine | r11u196 (`law`) | `fix` |
|---|---|---|---|---|
| x01 `if (a > 0) return a; else return b;`: f(1) and f(-1) | f(1) **folded**, f(-1) kept | both folded; NOT_EQUAL, 17 cmp lines | both kept; **78 cmp lines** | f(1) folded, f(-1) kept; 17 cmp lines on the pre-existing value-type head; distance 31 to 19; downstream IDENTICAL |
| x03 `return (a>0) ? a : b;` f(1); a loop over `b` that never runs, g(5) | f(1) kept, g(5) **folded** | STRICT_NOTEQUAL `type` (judge-equal) | **NOT_EQUAL, 78 cmp lines (judge regression)** | **STRICT_EQUAL** |
| x05 early return f(1); `int t = b; if (a>0) t = a; return t;` g(1); `return t + b` after a branch, h(1) | f and g **folded**, h kept | all folded; 17 cmp lines | all kept; **78 cmp lines** | f and g folded, h kept; 17 cmp lines (the same head); distance 46 to 36 |
| x06: a case branch `1: return b;`; a while loop that runs; a begin-end return | all kept | STRICT_NOTEQUAL `type` | STRICT_EQUAL | STRICT_EQUAL |
| x02 `int t; t = b; return a + t;`, generate-loop calls | kept | NOT_EQUAL, 42 cmp lines | STRICT_EQUAL | STRICT_EQUAL |
| x04 supplied read formal, omitted unread formal | folded | NOT_EQUAL, 36 | NOT_EQUAL, 36 | NOT_EQUAL, 36 (the value family) |
| r11u196 DF/d01-d04, V191/fd03 | | | | the same database as law (d03 and fd03 STRICT_EQUAL) |

**The laws of this verification** (src/ModuleEmit.cpp, inside `r196OmittedDefaultKeeps`; `r11v196Law` reads the
switches, and `R11V196_OFF` drops both):

- **§ dfltArgExecutedRead196v** (`R11V196_DFLTEXEC_OFF`; turning it off also turns off the next law, which lives
  inside it). The law is claimed on the body's straight-line prefix. That prefix is the top-level statements up to the
  first return, or up to the first statement that is not straight-line (if, case, a loop, ...). Along it the unset
  value is tracked through locals:
  - an assignment whose right side reads an unset value makes its target unset;
  - a whole assignment of any other value sets the target;
  - a return in the prefix that reads an unset value keeps the call.

  A conditional operator counts all its operands, since golden's reduceExpr reads every operand: x03's
  `(a > 0) ? a : b` is kept.
- **§ dfltArgExecutedPathEval196v** (`R11V196_DFLTEVAL_OFF`). Past the prefix, the executed path is taken from
  slang's own constant evaluator (`EvalContext`, `pushFrame`, `createLocal`, `Statement::eval`). It runs the body with
  the supplied actuals and every omitted integral formal set to all-X. A returned value with unknown bits keeps the
  call; a clean value, or a failed evaluation, declines. This runs only where the delivered law would fire (some read
  of an omitted formal). So together the two refinements only **withdraw** firings of the delivered law.

Each switch moves only its own cases (`evidence/switches.txt`). With `R11V196_DFLTEXEC_OFF` or `R11V196_OFF`, the fix
binary writes the law binary's bytes. With `R11V196_DFLTEVAL_OFF`, x01 and x05 go back to the pristine bytes and x06
goes back to `type` (`evidence/df_switches.txt`).

**Mover prediction for the fix, frozen before its sweep** (`evidence/prediction_fix_vs_law.txt`, `chmod 444` at
03:17): **0 byte movers against the law sweep**, except the known order draws. The reason: the refinements only
withdraw firings, and the delivered law fires on no corpus row-mode and no probe case (r11u196's census: 0 firings).
**Measured**:
- corpus: `MOVERS: 1 / 2560` (SELFCHECK 2559 / 2560), `surelog/default/BuildUVMPkg`. Its uhdm-dump is identical line
  for line, in order, to the law sweep's: a serialization-order draw. The law binary alone gives two hashes for this
  row-mode in three concurrent runs (section 5), and a trace of the fix binary on this row fires neither refinement
  nor the delivered law.
- probe: 0 of 4087.
- downstream: `downstream.csv` is byte-identical to the pristine sweep's.

## 4. The other laws, broken against fresh cases (`cases/`, 34 dirs, both views, goldens from the v1.87 pin)

Every case names its law on its first line. Each case is judged by uhdm-cmp, by uhdm-strictcmp field by field, by
the order-blind uhdm-dump distance to golden (`drivers/obd.sh`, `evidence/obd.txt`), and by the downstream verdict
(`drivers/ds.py`, the gate's own `one()`, fresh golden cache, `evidence/downstream_cases.tsv`). Totals: pristine 0
STRICT_EQUAL, law 10, fix 11. No case moves away from golden on `fix`: no judge-equal case leaves judge equality, no
cmp head grows, and no downstream verdict falls. Downstream, 5 cases go from STATUS_DIFF to IDENTICAL on the law,
and 5 DF cases go from EQUIVALENT or DIVERGENT to IDENTICAL.

| grid | law | cases | pristine -> law / fix |
|---|---|---|---|
| TB | § tpArrBoundAtLeftOperand196 | b01 a sized literal `4'd3+N` (IntegerVector, not a LiteralExpression) and `8'h2*N-1`; b02 a package-qualified leaf `pk::N-1` and product `pk::N*2-1`; b03 shift, modulo, parenthesized quotient; b04 a macro-written left operand and a parenthesized conditional; b05 the vector-typedef emitter; b06 a binary right bound, `N+1-1`, `$bits(t_t)*N`, a two-line left operand | b05 **STRICT_EQUAL**. b01, b03: every folded-bound span now equals golden's (constant spans multiset-equal). b04's `` `WW-1`` record is cleared; the next record, #67, is the same on both binaries. b02: the `pk::N*2` bound matches, and the `pk::N` leaf keeps pristine's `pk` span where golden spans `pk::N` (under-reach: the law excludes ScopedName; residue V3). b06 stage 1 on both (the `$bits` face). Downstream IDENTICAL on all (b06 EQUIVALENT on both). |
| FR | § retPkgQualTdNoAlias196 | r01 qualified scalar-logic, `int` and typedef-of-typedef returns; r02 a package class method, an interface function, the typedef's own package function; r03 a qualified return beside a wildcard import, a packed array of a typedef | stage 1 on both, the same heads (golden drops r01's `P::S2` assign; r02, r03 other faces); distance 49 to 28, 126 to 113, 96 to 83; downstream unchanged (IDENTICAL, IDENTICAL, EQUIVALENT) |
| SF | § tfFormalTdCloneFile196 | f01 a module function in dut.sv over header typedefs (with a call); f02 a formal type written by a macro defined in one header and expanded in another, output and ref formals; f03 a class method in a header over dut.sv typedefs, an extern method body; f04 two headers, and a formal in a macro defined and expanded in dut.sv; f05 f01 without the call | f02 f03 f04 **STRICT_EQUAL**; f05's logic-typedef clones take golden's file, and its `bit` typedef formal is not cloned (residue V4, like r11u196's R4); f01 stage 1 on both (the fold's value) |
| EN | § classPropElemClassTsAtName196 | n01 `pool#()`, named parameter assignments, a two-dimension element; n02 a typedef of a specialization (control), local / protected static qualifiers | n01 n02 **STRICT_EQUAL**, both views |
| MG | § modGenericClassListed196, § modGenericHandleBare196, § modClassTsLinksDefListing196 | g01 a generic class in a generate FOR loop, two instances; g02 two generate blocks each declaring a plain class `c`, two instances; g03 a generic extending a generic, a static call through a specialization; g04 a program home, a formal and a process local, two instances; g05 a module generic beside a package generic of the same name; g06 an unspecialized generic; g07 a plain class extending a specialization, a typedef of one; g08 a class-typed parameter defaulted to a package class, a task local; g09 a type parameter with no default; g08p the package-home control for g08 | g03 g06 **STRICT_EQUAL**; g01 329 to 53, g04 303 to 18, g05 135 to 88 cmp lines; g08 255 lines to STRICT_NOTEQUAL `name` (the default typespec name `pk::item` inside the class body, which the package home g08p shows the same on both binaries: a class-body residue); g07 unchanged (slang-uhdm rejects a typedef of a class, rc 4 on both); g02 and g09 byte-identical or unchanged. `--elabuhdm`: pristine **rc 139 on g03 g04 g05 g08 g09**, law and fix **0 crashes**. Downstream: g03 g04 g05 g08 g09 **STATUS_DIFF to IDENTICAL**. |
| V | r11u191's § evalFuncCastMemberKeepsCall191 and § elabCaConstLhsSized191 | c01 a cast to a type parameter, a cast in a branch, a cast to a bit typedef; u01 unsized `'d300` / `'h1FF` package parameters into 4- and 16-bit left sides from two instances | stage 1 on both, distance 34 to 16 and 12 to 10; downstream unchanged (c01 DIVERGENT on all three binaries: the folded-call value family) |

**The OFF check.** `R11U196_OFF=1` on the law binary writes the pristine bytes on all 34 fresh cases in both
views. The only exceptions are the elaborated cases where pristine crashes, where both runs crash the same way.
**Each switch alone** (`evidence/switches.txt`, fix binary) moves only its own law's cases. MODGENHANDLE off alone
crashes one `--elabuhdm` run: that is the pristine crash shape, since the handle keeps its specialization list.

## 5. Determinism (`drivers/det.sh`: three CONCURRENT runs per binary and row-mode, the pristine sweep's command lines)

See `evidence/determinism.txt` and `evidence/determinism_dumps.txt`.

**The value coin closes.** Pristine's `types_t` return twin reads a garbage bound in several row-modes:
`UINT:694` / `1278` (MiniAmiq d), `932` / `983` / `0` (MiniAmiq t), `920` / `571` / `0` (SeqDriver d), and
`1227` / `0` / `1222` (SimpleUVM d). The law and fix binaries read `STRING:$` in every run of every UVM row-mode.

**Hash draws remain, and they are serialization order only.** Several law and fix row-modes still show 2-3 hashes in
3 runs: MiniAmiq d and t, SeqDriver d and t, SimpleUVM d, and BuildUVMPkg d and t. This does not reproduce
r11u196's "one hash per row-mode except MiniAmiq t". But every such draw has identical uhdm-dumps, line for line and
in order (header dropped): 1 distinct dump per row-mode over the 6 law and fix runs. The law and fix hashes are drawn
from the same pool (for example MiniAmiq d law {acb7, 9426} and fix {9426, f7e6, acb7}). Earlgrey_0_1: one hash per
binary in 3 of 3 runs, and fix equals law.

**The one exception: BuildUVMPkg testflags.** One fix run (hash `f842...`) drops 4 lines of the
**weaklyReferenced tail**, which neither judge reaches: a `class_typespec this_type` of
`uvm_abstract_component_registry`. It appeared in 1 of 27 fix runs and 0 of 27 law runs (18 more concurrent runs of
each from the row's own directory, all on the common dump). The refinement code is never reached on this row:
`R11U196_TRACE` on the fix binary names no `dfltArg*` or `evalFuncOmittedDefault*` firing, and the row has no module
continuous assignment. So this is a rare tail-only draw of the r11u196 build, not of this verification's laws. Nine
pristine runs never showed it, but they come from a different dump pool, so they do not decide whether pristine
shares the draw. It is recorded as residue V7.

## 6. Residues, ranked (new here; r11u196's own R1-R10 re-read and unchanged)

1. **V1 — constCallFold's value for an overwritten local** (DF/x05 g(1): `int t = b; if (a > 0) t = a; return t;`).
   Ours folds `UINT:2` where golden folds `UINT:1`, on every binary, and downstream reads DIVERGENT. The fold is
   slang-uhdm's (`constCallFold`, ModuleEmit), not slang's evaluator. Pre-existing; not attempted.
2. **V2 — the refinements' remaining under-reach**: a non-integral omitted formal (string, real, struct) past the
   prefix declines. So does an X that slang's 2-state conversion flattens before the return (a 4-state expression
   returned as `int`).
3. **V3 — § tpArrBoundAtLeftOperand196 on a package-qualified leaf** (TB/b02 `pk::N-1`): golden spans `pk::N`, ours
   the `pk` token (pristine alike; the law excludes ScopedName).
4. **V4 — a scalar `bit` typedef formal is not cloned at the formal** (SF/f05), beside r11u196's R4 (`int`).
5. **V5 — a generic class's type-parameter default named through its package inside the class body** (MG/g08
   `pk::item` vs `item`; the package home g08p stage 1 on both binaries).
6. **V6 — the value-family faces** DF/x04, SF/f01, V/c01 (a folded call's constant type and value: the sister's
   `srlgRedIntSyn`, EmitHelpers.h, as r11u196 reported for TB/t05 and DF/d01).
7. **V7 — a weaklyReferenced-tail draw on BuildUVMPkg testflags** (section 5): 1 run in 54 of the law and fix
   binaries drops one `class_typespec this_type` from the tail. Neither judge reaches it, and BuildUVMPkg is not a
   downstream row. Not decoded.

## 7. Files

- `cases/{DF,TB,FR,SF,EN,MG,V}/*/dut.sv` (SF cases also have headers). Each names its law on its first line.
- `drivers/`:
  - `env.sh` (pins, fence)
  - `case.sh` (one case; `EL=1` for the elaborated view)
  - `obd.sh` (order-blind distance)
  - `ds.py` (downstream per case)
  - `mirror.sh` (fence-free hard-link mirrors for byteverify)
  - `sweep.sh` (the three gate sweeps)
  - `det.sh` and `detana.sh` (determinism)
  - `switches.sh` (each switch alone)
  - `rowdist.sh` and `uvmdist.sh` (distances)
- `evidence/`:
  - `sweep_{pristine,law,fix}.log`
  - `byteverify_law_vs_pris.txt`, `byteverify_fix_vs_law.txt`
  - `probe_movers_law_vs_pris.txt`
  - `prediction_fix_vs_law.txt`
  - `grid.txt`, `grid_el.txt`, `grid_impl.txt`, `obd.txt`
  - `downstream_cases.tsv`
  - `switches.txt`, `df_switches.txt`
  - `determinism.txt`, `determinism_dumps.txt`
  - `uvmdist.txt`, `rowdist.txt`
