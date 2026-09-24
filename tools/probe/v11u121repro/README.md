# v11u121 — adversarial verification of r11u121

**VERDICT: ACCEPT-WITH-FIX.** The submitted patch holds on every gate. One
face of one law is wrong on legal SV: a parameter initializer. The verified
patch adds one gate, § pkgQualParamMemberSelParamInitKeeps121v, so the select
erasure no longer fires inside a parameter initializer.

**THE TARGET ROW CONVERTS DOWNSTREAM: `arb_idx_cast` EQUIVALENT -> IDENTICAL**
(the verified binary's own sweep):

```
results/downstream_uhdm2rtlil.csv: arb_idx_cast,EQUIVALENT,OK,OK,11,11,nohier il synth,...
FIX sweep downstream.csv:          arb_idx_cast,IDENTICAL,OK,OK,11,11,,
```

Downstream moves from 794 / 7 / 4 / 66 to **795 IDENTICAL / 6 EQUIVALENT /
4 DIVERGENT / 66 SLANG_REJECT** of 871. No other row changes, and no row
leaves IDENTICAL.

## Binaries

Built at `-j 2` in the verifier's own worktrees at `d31ae79a`, then frozen
with `chmod 555`.

| binary | md5 | notes |
|---|---|---|
| pristine | `3e6d2800759fb6ea476700223ab73bb0` | equal to the main tree's `build/slang-uhdm` |
| LAW (as submitted) | `6e0b0cef42b4bbb23d812ada31135a65` | equal to the implementer's md5 |
| **FIX (verified)** | `b319f1547ecd2cc511f0685201224d94` | the LAW source plus one gate in `src/ExprEmit.cpp` |

## 1. Reproduction of the headline

**Q1, the head at base.** On the pristine sweep, `arb_idx_cast`'s nohier
diff is 96 `<`/`>` lines. Autoidx goes from 27 to 31. Our lane has two
`wire width 32 $auto$expression.cpp:6227:import_operation` wires, at
`dut.sv:31.13-31.80` and `32.13-32.78`, two `$pos` cells from `A_WIDTH 2` to
`Y_WIDTH 32`, and a 32-bit `$mux`. Golden's lane has a 2-bit `$mux`.

The cast cells in the downstream-lane databases, at
`gen_levels[0].gen_level[0].gen_other_levels`:

| lane | typespec |
|---|---|
| golden (u2r Surelog, `-DSYNTHESIS`) | `logic_typespec 8:40-15:27` |
| ours at base | `integer_typespec 31:13-31:18` and `32:13-32:18` |

uhdm-cmp reads 0 lines against that golden.

**Q2, the decode checks out.**
* The plugin: `expression.cpp:6070` reads an `integer_typespec` with an
  empty value, then `get_width_from_typespec` falls to `module.cpp` 3248
  (`uhdminteger_typespec` -> 32), then `addPos` at `:6230` (the wire is made at `:6227`).
* Surelog: `CompileExpression.cpp` `paCast` is at :2660, and
  `needLateTypedefBinding` is at :2710. `UhdmWriter::lateTypedefBinding` is
  at :2576, and its `module_inst` branch at :2836.
* The `R4` and `R3c` decode sites are `ModuleEmit.cpp` 36751-36770 and
  34143-34150, both on the sister pass's ground.

**Gates re-run for all three binaries** (`tests/sweep.sh --jobs 3`, workdirs
`/tmp/v11u121_w{pris,laws,fixs}`, `evidence/SWEEPS_v121.txt`):

* probe: EQUAL=2833 of 2833 on each binary.
* surelog: 480/3 + 474/3, regressions=0 conversions=0 changes=0.
* uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
* downstream: pristine 794/7/4/66 (the baseline); LAW and FIX 795/6/4/66.
* `cmds.txt`: 3273 of 3323 name the frozen binary on each sweep. The other 50
  are Surelog-failed rows that never run slang-uhdm.

## 2. The break: a parameter initializer keeps the select

§ pkgQualParamMemberSelErased121 gates only on `!inLhs`. Golden erases the
select in a cont_assign or process. In a **parameter initializer**, golden
KEEPS it.

For `localparam logic [3:0] L = cp::CFG.f[3:0];` (arm `B/b1`), golden's
`param_assign` Rhs is:

```
hier_path (cp::CFG.f[3:0]) 8:30-8:34
  ref_obj (cp::CFG) 8:38-8:39
  part_select f (work@top.cp::CFG.f[3:0].f) 8:38-8:43, left 3 / right 0
```

What each binary emits:
* **Pristine:** the same shape, with the names `CFG.f[3:0]` / `CFG`.
* **LAW:** the select is erased. The Rhs becomes `hier_path (work@top)` over
  `ref_obj cp::CFG` and `ref_obj f`, so the part_select is gone
  (`evidence/PARAMINIT_b1_cells.txt`).

The same holds for element and variable selects. Golden keeps a `bit_select U`
for `q2::IMPL.U[1]` (the r11u108 k13 arm) and a `var_select m` for
`q2::IMPL.m[1][2]` (v11u117 b20).

**Measured, pristine -> LAW** (order-blind whole-dump distance to the v1.87 golden):

| arm | distance |
|---|---|
| b1 | 58 -> **70** |
| b10 (`parameter P = cp::CFG.f[3:0]`) | 58 -> **70** |
| b16 (`cp::CFG.f[3:0] + 5'd1`, `cp::CFG.g[2]`) | 93 -> **106** |

These are cells moving AWAY from golden on legal SV. Downstream stays
IDENTICAL, because the parameter folds. The implementer's boundary scored 14
such arms "TO" (dist -1, cmp 100 -> 86): r11u108/r11u111/r11u114/r11u117
k13/a01/a30/g02/g03/g17, v11u108 c22, v11u117 b20/b52. There the renamed
`ref_obj cp::CFG` hid the lost select kind.

**The fix** (`src/ExprEmit.cpp`, both QMSEL sites): add
`(offQmPi121 || !inParamInit)` to the law's gate. `inParamInit` is the
existing flag set while a parameter initializer is emitted.

* Switch: `R11U121_QMSELPI_OFF=1`. With it set, the FIX binary gives the LAW
  binary's bytes on all 178 arm dirs in both forms (356/356).
* `R11U121_OFF=1` still gives pristine bytes (356/356).
* b1, b10, b16 and all 14 boundary arms return to **pristine bytes** (28/28
  forms).
* b17 (a localparam plus a cont_assign in one module) moves closer to golden
  still: 293 -> 262, where LAW gave 274.

## 3. Fresh instances (`arms/`, 41 arms, both goldens, both lanes)

`evidence/ARMS_v121.txt` has the full table. For each arm: rc, cmp and the
downstream verdict on pristine, LAW and FIX, plus the distance to golden.

| face | arms | pristine -> FIX |
|---|---|---|
| TPGS (cast to a type param in an elaborated gen scope) | A/a1-a8, F/a9-a13, G/a14-a16 | a2 child instantiated twice with and without an override, a3 if-if always_comb case, a4 always_ff, a5 struct type param, a10 t13 under a top, a12 `$clog2` default, a15: EQUIVALENT -> **IDENTICAL**, cmp stays 0/31. a1 case-generate, a6 shadowing typedef control, a8 function in a gen scope: bytes unchanged. |
| QMSEL | B/b2-b9, E/b11-b17 | b2 ff condition, b3 port connection, b7 as an index: EQUIVALENT -> IDENTICAL; b4 case item + concat, b9 compare/add: DIVERGENT -> IDENTICAL; b5 nested member, b6 `parameter` keyword: STATUS_DIFF -> IDENTICAL. b11 override, b12 range bound, b13 gen condition, b14 gen-block localparam: unchanged. |
| PVSPAN | C/c1-c5 | all 5 TO golden, IDENTICAL kept (c5 includes an LHS write). |
| PVSP | D/d1-d3 | `vp ::x`, `vp:: x`, a newline before `::`, spaced member/element/ff: DIVERGENT -> **IDENTICAL**, cmp 32/123/32 -> 0/29/0. |

On FIX: **0 arms AWAY** (LAW had 3). No arm leaves IDENTICAL, and no EQUAL
arm leaves 0 lines. E/b15 is excluded from scoring because its golden errors
(`EL0514 Undefined variable: cp::CFG`, rc 4).

## 4. Movers

Predicted by name before the FIX sweep (`evidence/PREDICTION_v121.txt`): FIX
vs LAW, 0 corpus movers apart from the UVM coin. The source census of a
qualified member select in a parameter initializer finds one hit,
`stamped_gen_param/dut.sv:44`, a gen-loop localparam that neither the law nor
the fix reaches. Its positive control is b1/b10 matching the same regex.

byteverify (`SELFCHECK=1`, identical path sets, `evidence/GATES_v121.txt`):

**FIX vs pristine**
* surelog, 6/960:
  * `ApbSlave` in both modes: 30 order-blind lines, all
    `svunit_pkg::current_tc` spans; distance to golden 777 -> 747.
  * `Scoreboard/default`: 18 lines, 120139 -> 120121.
  * `MiniAmiq` in both modes and `SeqDriver/default`: exactly 4
    `UINT`/`vpiDecompile` lines each, the coin.
* u2r, 2/1608: `arb_idx_cast` in both modes.
* downstream, 1/805: `arb_idx_cast`.

**FIX vs LAW**
* surelog, 4/960: the coin only (4 lines each; `Scoreboard` has 0
  order-blind lines).
* u2r 0/1608, downstream 0/805.

**Other checks**
* **Boundary** (every `dut.sv` under `tools/probe` + `tests/probe` of the
  pristine tree, 5896 arms, both forms, pristine vs FIX): DIFF 74 = 37 arms.
  These are the implementer's 51 minus the 14 parameter-initializer arms, with
  no new mover. 18 forms go rc 4 -> 0. The rc=139 arms are unchanged: 3 arms,
  6 forms, both binaries.
* **Probe movers:** t36a, t36d, c13, c25, c27, all EQUAL.
* **Protected databases:** byte-identical to pristine (Earlgrey_0_1,
  SVSwitch, YosysVerx, InterfaceModPort, BlackParrotComplex and YosysOldOr, in
  both modes).
* **Canaries:** the FIX output matches the pristine output, except
  `Earlgrey_0_1/testflags` dump `differ -> blank`, the dump-timeout draw.
* **uhdm-cmp on `arb_idx_cast`:** 0 lines in default, testflags and the
  downstream lane.

## 5. Residues (ranked)

1. **Single-iteration generate loop keeps the placeholder** (TPGS scope, this
   ground).
   * Golden keeps `unsupported_typespec (idx_t)` on the elaborated `g[0]`
     cast when the loop runs ONCE (a13, a14, a16, and a7/a9/a11 with
     `lv[0].l0`). With 2 or more iterations every copy resolves (t07; a15
     `g[1].gi`).
   * Pristine emits `integer_typespec`, and LAW/FIX emit the shared
     `logic_typespec`. Both are wrong, but FIX is closer (59 -> 57).
   * The cmp head stays on the same object, printing 18 -> 80/88 lines
     because the RHS object is bigger.
   * Downstream EQUIVALENT/DIVERGENT on all three binaries.
   * The fix belongs to § genCaTypeParamCastUnsupported113 (a placeholder in
     an unreplicated elaborated scope).
2. **R3c/R3d:** ModuleEmit / TypeEmit, the sister pass's ground, as the
   implementer reported.
3. **Parameter-initializer member select** (b1/b10/b16, k13, b20): golden's
   naming is `cp::CFG.f[3:0]`, the ref_obj spans `8:38-8:39` and the select is
   named `f` with fullname `work@top.cp::CFG.f[3:0].f`. Ours keeps the
   pristine `CFG.f[3:0]` names. Downstream IDENTICAL.
4. **b17 / R3b:** a qualified member select inside an operation whose golden
   keeps the unfolded whole member (`8'hA5`). Ours folds. DIVERGENT on all
   three binaries.
5. **a8:** a cast to a type parameter inside a function in a gen scope.
   Golden has `logic_typespec`; ours has `integer_typespec`, rc 4. Not
   reached.
6. **R4, R6, R-mod, R3e:** as the implementer reported.

## 6. "Won't it double the sweep time if compare twice?" (uhdm-strictcmp, fc313b50)

The Compare does run twice on every CMP_EQUAL row: uhdm-cmp, then
strictcmp's stage 1. It costs very little. Measured over all 954 CMP_EQUAL
Surelog-corpus row-modes of this pristine sweep (`evidence/STRICT_TIMING_v121.txt`,
sequential, shared machine):

| step | total over 954 rows |
|---|---|
| uhdm-cmp | 19.7 s |
| uhdm-strictcmp (stage 1, which repeats the Compare, + stage 2) | 65.5 s |
| uhdm-dump of our database (what the harness at d31ae79a runs per equal row) | 1111.7 s (Earlgrey 574 + 432 s alone) |

* The repeated Compare costs about 20 s of CPU, about 7 s of wall time at
  `--jobs 3`. That is roughly 2% of a Surelog stage of about 6 minutes
  (pristine sweep here: probe 16 s, surelog 358 s, u2r 23 s, downstream
  200 s).
* strictcmp replaces the per-row uhdm-dump, which cost about 17 times more.
* So the new flow is cheaper than the old one, not twice as slow.

## Files

* `arms/{A,B,C,D,E,F,G}/<arm>/dut.sv`: the fresh instances.
* `bytecmp.sh <binA> <binB> <list> <scratch> [ENV=1]`: byte + rc compare in
  both forms.
* `castts.py <uhdm-dump> <db>`: cast target typespec per scope.
* `strict_timing.py`: the timing measurement.
* Arms run through `../r11u121repro/arm.sh`, and distances through
  `../r11u121repro/dist121.sh`.
* `evidence/`: the arm table, cast cells, the b1 cells, drops, the boundary,
  sweeps, gates, the prediction and the timing.
