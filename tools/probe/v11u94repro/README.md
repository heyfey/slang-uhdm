# v11u94 — adversarial verifier of r11u106 (the range-bound folds). Verdict: ACCEPT-WITH-FIX

**The headline numbers reproduce exactly.** `mem_packed_2d_byte_write`
**CONVERTS in BOTH modes**, and `cva6` / `StructParamFieldRange` /
`StructParamFuncBodyFieldCompare` move to the R0 head the implementer named.

**The two laws as landed are too wide on legal SV.** On the verifier's grid
arms (real v1.87 goldens, every arm `slrc=0 ourrc=0 slerr=0`), scored per cell
by the name key, they produce:

- **MOVED-WRONG 21 cells**, where the law writes `INT` size 64 but the
  producer's evaluator mints another type or width:
  - `UINT` for add/plus (11 cells), shifts (3) and bitwise and/or (3);
  - size 32 for a sized add (`UW+32'd1`, `UW+IW`);
  - `INT:0` for `$bits(<anonymous vector type>)` (4 cells).
- **AWAY 2 cells, pristine-right to patched-wrong.** A `var`-keyword
  variable of a typedef'd unpacked array (`var a10_t v;`) keeps golden's
  operation, and the M law folded it.
- **4 folds inside typed patterns** (`h_t'{default: 1}`). Golden writes a cast
  (`op 67`) that keeps the operation. We write `op 75` (a difference that
  predates this pass), and the S law folded inside it.

Four verifier gates, each droppable alone, remove all 27 cells. Nothing the
corpus or the wide boundary reaches changes: the fixed binary's databases are
**byte-identical to LAW's** on every corpus row (apart from the documented UVM
nondeterminism) and on all 69 boundary DIFFERS arms.

## Binaries (all frozen `chmod 555` before any sweep; every cmds.txt audited by absolute path)

| binary | md5 | notes |
|---|---|---|
| pristine | `84adb8d34c76d136325c65a6aa2e4b22` | own worktree at 81f13b5f; equals the OPS pin |
| LAW | `77f1796144334e9e4355079e74980443` | `/tmp/r11u106.patch` on a fresh 81f13b5f; equals the implementer's |
| FIX | `d4f29202b54eec06a26f31b7d3097b98` | LAW + the four gates below (`r11u106.verified.patch`); rebuilt from that patch on a fresh 81f13b5f: same md5 |
| explore | `e348cdf037f83a508adf6938178ae55c` | FIX source with all seven gates read from `V94OFF` (drops only) |

## Q1 — the target rows at 81f13b5f, and after (uhdm-cmp; LHS golden; one head per run)

| row | base | LAW | FIX |
|---|---|---|---|
| cva6_struct_param_field (both modes) | 74 | 60 | 60 |
| mem_packed_2d_byte_write (both modes) | 48 | **0 — CONVERTS** | **0 — CONVERTS** |
| StructParamFieldRange (both modes) | 74 | 60 | 60 |
| StructParamFuncBodyFieldCompare (both modes) | 74 | 164 (depth, not distance) | 164 |
| StructParamPatternInitCast (untargeted, both modes) | 15 | 15 | 15 |

The head at the base is golden's location-less `constant INT:63` (mem_packed:
`INT:3`), `vpiSize:64`, `vpiConstType:7`. Ours is an `operation` with
`vpiOpType:11` (`range` parent, cva6 line 26:12; mem_packed 19:51).

The committed rows are unedited. The FIX sweep reads:

```
results/golden_uhdm2rtlil.csv: mem_packed_2d_byte_write,default,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv: mem_packed_2d_byte_write,testflags,CMP_NOTEQUAL,decompile:,,
results/gate_uhdm2rtlil.csv:   mem_packed_2d_byte_write,testflags,CMP_NOTEQUAL,decompile:,,
FIX sweep:                     mem_packed_2d_byte_write,{default,testflags},CMP_EQUAL,,,differ
```

### LAW B — R0, reproduced

- **cva6 / StructParamFieldRange.** Golden keeps the member initializer
  `Cfg.XLEN'(1)` as an `op 67` cast: `vpiSize:64`, typespec a
  `void_typespec` at 29:28, operand `UINT:1`. Ours is a folded
  `constant UINT:1`.
- **FuncBody.** Golden writes `op29(op22(op67 …))`. Ours is
  `constant UINT:9223372036854775809`.

This is the pattern **value** face. The producer's road is `reduceExprTree`
plus flatten, `NetlistElaboration.cpp:369-394`.

## Q2 — the producer's evaluator decides the constant's TYPE and WIDTH, not only its value

`reduceBound` → `ExprEval::reduceExpr`
(`~/git-repos/UHDM/templates/ExprEval.cpp`, v1.87) mints a different constant
for each operator:

| operator | constant golden writes |
|---|---|
| `vpiSubOp` :3443, `vpiMultOp` :3479, `vpiModOp` :3709, `vpiPowerOp` :3765, `vpiDivOp` :3803, `vpiConditionOp` :3863 | always `INT` size 64 |
| `vpiAddOp` / `vpiPlusOp` :3260 | `UINT` unless an operand constant is INT/STRING/REAL/DEC; the size is the wider operand's |
| shifts :3149 / :3236, bit/logical ops :3331-3406 | `UINT` size 64 |
| unary `vpiMinusOp` :3407 | the operand's size |

The landed law wrote `INT` size 64 for every operation, which is wrong for
every row of that table except the first.

## The fix — four gates, all in `src/EmitHelpers.h` (+ one call-site condition in ModuleEmit, two in-line argument additions in ParamEmit; ParamEmit line count unchanged, 33717)

1. **§ `evalIntOpOnly106v`.** Only the always-INT-64 operators fold (both
   laws); every other operator keeps the base operation.
2. **§ `bitsAnonVecDecline106v`.** A bound whose syntax takes `$bits` of a
   `logic`/`bit`/`reg` type expression declines, in both laws. Golden's
   evaluator sizes that argument as 1 bit (`INT:0`). `$bits(int)` and
   `$bits(named_t)` are right and still fold.
3. **§ `spOpTsTypedPatDecline106v`.** A typed pattern initializer declines.
   That covers `T'{...}` and an instance override, which slang sets as the
   initializer syntax.
4. **§ `utdVarKwDecline106v`.** A `var`-keyword declaration declines, using
   the existing `hasVarKeywordDecl`.

## Measurements

**Grid.** Thirteen arms: r11u106's five plus this directory's eight. Evidence
in `evidence/GRID94.txt`.

| comparison | TO | AWAY | MOVED-WRONG | NOGOLD |
|---|---|---|---|---|
| pristine → LAW | 101 | 2 | 21 | 4 |
| pristine → FIX | 95 | 0 | 0 | 0 |
| swap control (FIX → pristine) | 0 | 95 | 0 | 0 |

The six cells FIX gives up relative to LAW are add cells whose golden
happens to be `INT`: `c09_lplus`, `c01_xplus`, `c03_bplus`, `c06_divplus`,
`s1 c03_plus` and `b5 c03_uminus` (see `evidence/LAW_TO_FIX94.txt`). They go
back to the base operation; that is conservative and not AWAY.

**Drops** (`evidence/DROPS94.txt`, explore binary):

- All gates on: 13/13 dumps equal FIX. All seven off: 13/13 equal pristine.
- Each gate dropped alone moves only its own cells:
  - `evalInt`: MOVED-WRONG 17, plus the 6 add TOs;
  - `bitsAnon`: MOVED-WRONG 4;
  - `typedPat`: the 4 typed-pattern cells;
  - `varKw`: AWAY 2;
  - r11u106's `spOpTsFoldOp106`, `spOpTsFoldClog2106` and `utdVarFoldOp106`:
    only their own TO cells.

**Census** (r11u106repro/census106.py, reproduced):

- Golden against golden: u2r has 2 M GOLD-OTHER cells
  (`unpacked_struct_array_typedef`, declined by the element gate); Surelog
  has 0.
- Pristine: u2r S 4 + M 2 GOLD-FOLD; Surelog S 12 GOLD-FOLD. Every reach cell
  is `op 11` with no typed pattern, no `var` and no `$bits`.
- The prediction was that FIX equals LAW byte for byte on the corpus, and the
  sweeps confirmed it.

**Sweeps** (`verify_golden.py --jobs 3`, `SLANG_UHDM` exported, own
workdirs):

- The pristine rows equal the committed baselines.
- LAW and FIX:
  - u2r 789/15/67 in both modes; the only differing row is the law-named one
    above.
  - Surelog 474/9 + 469/8, unchanged. The row diffs are the environment-only
    Earlgrey_0_1 dump column (the pristine sweep has it too) and the
    LowMemLib/LowMemPkg log-path text.
- `cmds.txt`: pristine 3273/3273, LAW 3273/3273, FIX 3273/3273, each naming
  its own binary.

**Byteverify** (SELFCHECK 1607/1608 and 959/960):

- FIX against pristine:
  - u2r 4/1608: `cva6_struct_param_field` ×2, `mem_packed_2d_byte_write` ×2.
  - Surelog 9/960: `StructParamFieldRange` ×2,
    `StructParamFuncBodyFieldCompare` ×2, `StructParamPatternInitCast` ×2
    (all predicted), plus the UVM class `MiniAmiq` ×2 and
    `SeqDriver/testflags`. The order-blind dump diff of each UVM database is
    4 lines (2 `|UINT` + 2 `|vpiDecompile`), and every UVM row stays
    CMP_EQUAL.
- FIX against LAW: u2r 0/1608; Surelog 4/960, all in that UVM class.

**Wide boundary.** 8730 arms under tools/probe, path-neutral `bnd106.sh`,
`-P 3`, children fed `</dev/null`:

- LAW and FIX each have 69 DIFFERS arms, the same set as r11u106's.
  prc and lrc agree on every arm.
- Scored against a fresh golden: TO 141, AWAY 0, MOVED-WRONG 0, NOGOLD 2.
  The two NOGOLD cells are r11v47 v15/v31, where golden writes no Top
  param_assign for a package-typed pattern param.
- The pristine re-run (null) is SAME 69/69.
- FIX's database equals LAW's on all 69 arms.

**Gates:**

- goldens: LAW 23/0 and FIX 23/0; `/bin/false` 0/23.
- `canaries.sh`: Surelog ok=50 changed=2 (Earlgrey's dump column only, the
  same as pristine); u2r ok=8.
- `ctcan2` PASS ×2; `canaudit` PASS.
- Database pins are identical in both modes for pristine, LAW and FIX:

  | row | md5 |
  |---|---|
  | SVSwitch | 4842211c4030 |
  | YosysVerx | 6ccda350c24a |
  | InterfaceModPort | 59a365f3ce2c |
  | BlackParrotComplex | e3e354129d5a / 73a10e8217e5 |
  | YosysOldOr | d68e0796d62c |
  | Earlgrey_0_1 | 8bdf25272e08 / 59d0ee6d10c3 |

- rowheads: every UVM row reads 0 lines.

## Residues (ranked)

1. **R0 (implementer's): the pattern VALUE face.** Golden keeps the `op 67`
   cast / `op 29` tree as the member initializer; we write a folded constant.
   This is the next head of all three S rows.
2. **R-add.** The add/plus bound. Golden's type follows the operand constants
   (`UINT` unless an operand is INT-typed) and its size is the wider operand's.
   Measured on unsized, `int` and `int unsigned` parameters (`UINT`), a sized
   literal (`INT`, size 32) and a `logic [7:0]` parameter (`INT`). Declined
   here; a model of the operand constants would recover 6 cells.
3. **R-shift/bitwise.** `UINT` size 64 constants. They are modelable, and
   declined here.
4. Implementer R1–R4 stand as written: bare member reads, shared nested
   typespecs, the unpacked struct pattern, and `[0:D-1]` / package-typedef
   variables.

## Reproducing

```bash
R=tools/probe
g++ -O2 -std=c++17 $R/r11u106repro/tw106.cpp -I ~/.local/include -L ~/.local/lib64 -luhdm -lcapnp -lkj -o /tmp/v11u94_tw
TW106=/tmp/v11u94_tw bash $R/v11u94repro/grid94.sh /tmp/v11u94_grid pris=<pristine> lawx=<LAW> fixx=<FIX>
```
