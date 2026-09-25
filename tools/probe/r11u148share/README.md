# r11u148share: the sharing classes, decoded and checked in scratch (analyst pass, measurement only)

Base `0024d365` (branch matrix-1.87). This directory is the whole deliverable. Nothing under `src/`,
`scripts/`, `results/`, `tests/` or `third_party/` is edited. The law is in [law.patch](law.patch), a
`git diff 0024d365 -- src` of `src/ModuleEmit.cpp` and `src/TypeEmit.cpp` that applies cleanly at
`0024d365`. Pair B lands it on its next refill.

Law names below are written `law <name>` with no section sign, so `scripts/law_index.py` does not read
this directory as a pass of laws. The patch itself names its laws with the section sign at their sites.
The landing must run `python3 scripts/law_index.py` and commit `tests/LAWS.md`. In both sweeps below,
the law-index check reads `STALE` for one reason: the new names in the worktree's edited `src/`. Every
measured binary was frozen before its sweep, so no stage result depends on that check. This README
writes the slang-fenced tests as `FENCED=`. `drivers/census.py` holds them in a `FENCED` set and never
dispatches them.

## Binaries (frozen with `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `slang-uhdm.pris` | `a408021857111d030b0571aee87d105b` | worktree `/tmp/wt_r11u148` at 0024d365, system-deps config, `-j 2`; byte-identical to the main tree's `build/slang-uhdm` (a40802185711) |
| `slang-uhdm.law5` | `b0d4cbe33da2d53219a7f83d42aefae5` | 0024d365 + law.patch; the worktree's final build, byte-identical after the last comment-only edits |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the main tree's, unchanged; no defect found in it, so it is not edited |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | `tools/probe/r11u142map/drivers/strictcmp_x.cpp` built with its `cc.sh`: the committed tool plus `--dump-ids` |
| `carhs_db`, `pkgsig_db` | built from `drivers/*.cpp` with the same flags | read a database: each elaborated cont_assign's Rhs and whether the definition's object is shared (`carhs_db`); each package subroutine's signature-range binding by listing (`pkgsig_db`) |

Every `cmds.txt` of both sweeps names its binary by path (`/tmp/r11u148_bin/slang-uhdm.{pris,law5}`).

## The one fact every class turns on

`VpiListener::listenDesign_` clears its visited set between `uhdmallPackages` and `uhdmtopPackages`,
and between `uhdmallModules` and `uhdmtopModules`. In the UHDM `VpiListener.cpp` that
`build-intree/third_party/Surelog/third_party/UHDM` generates, these are the `visited.clear()` calls
at 3648 and 3666. An object shared between a definition listing and its elaborated listing is therefore
listed in full in both. An object shared inside one listing is listed once, and the second site lists
nothing. The strict walk records exactly that. So a sharing class is a question of which object golden
hangs at a site, and whether that object was already walked inside the same listing.

## 1. Reproduction at 0024d365

`evidence/rows/heads_0024d365.txt` holds every example row, both modes (`uhdm-strictcmp --max 50`, A =
golden, B = ours), with the walk-path chain of the first differing record. `evidence/rows/*.recdiff.txt`
holds the whole-record diffs. `evidence/rows/ids.txt` holds the object identities (UhdmId).

The brief's `/tmp/strict_sweep` databases predate 0024d365 (written 03:31 by a since-rebuilt main
binary). They read `SumOfParameters...` as `file(3)`, `simple_package` as `fullname(5)` and the C3 rows
as `fullname(2)/(5)`, none of which match the committed baselines. Every head here was therefore
regenerated with the frozen pristine binary: `verify_golden.py --filter` on the 14 tests, and all 28
row-modes match `results/golden_*.csv` exactly.

## 2. Per class: the decode, the law, the conversions, what is left

### E: the elaborated function call (FunctionParam, SelectGivenBySelectOnParameterInFunction, func_local_array)

**Face.** For each row, the elaborated `cont_assign` Rhs record reads golden `func_call theta 8:15-8:22`
against ours `constant 2:30-2:31 UINT:1 size 32`. FunctionParam shows it at #160. SelectGivenBy shows
ours `1'b1`, with no location. func_local_array shows golden `func_call func1` plus its argument
subtree, against ours `UINT:2`. The map's framing ("ours shares the definition's func_call") is not
what 0024d365 writes: ours FOLDS. Golden lists the definition's own `cont_assign` object (UhdmId 21 in
both listings, `evidence/rows/ids.txt`).

**Decode.** See `third_party/Surelog/src/DesignCompile/UhdmWriter.cpp`, `writeCont_assign` (2090). A
func_call Rhs is not an operation, so it reaches the trailing `if (simplified == false)` case (2245).
`reduceExpr` there runs `ExprEval::reduceExpr`'s func_call case, which calls `ExprEval::evalFunc` in
`third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp` (6106). That executes the body. Only a
`constant` result (2266) makes the writer clone the assign and replace the Rhs. Anything else leaves
the assign un-cloned, so the elaborated module lists the definition's object. Two body shapes never
come back as a constant:

- **P**: a select of a module parameter. The bit_select case of `ExprEval::reduceExpr` (5010) resolves
  the base with `getObject`, which returns the `parameter`. No case reads a `parameter`, so the select
  survives.
- **V**: a select of a select (a var_select) on a function-local variable, read, or written with a
  variable index.

**Grid** (`cases/E`, 24 cases; golden per case in `evidence/grid/E_ca_rhs.txt`):

| outcome | cases |
|---|---|
| golden KEEPS the call | e01 e02 e03 e05 e07 e08 e09 e10 e13 e14 f03 f05 f09 f11, plus e12 and f08 |
| golden FOLDS | e04 (`return P`), e06 (one select of a local), e11, f01 (select of a formal), f02, f04 (`t[1][0] = 1'b1`, literal indices), f07, f10 (the parameter select sits behind an executed `return`) |

**Law `evalFuncSelectKeepsCall148`**, switch `R11U148_E_OFF`, cases `R11U148_EP_OFF` and
`R11U148_EV_OFF`. In `emitContAssigns` and in the gen-scope emitter, the law declines every call fold
(the `constCallFold` replay, the unvalued-actual replay, slang's `tryEval`, and the signed-formal fold)
in two cases:

- P: the callee's body is straight-line and reads a select whose base is a module-body parameter.
- V: the body reads a select-of-select on a local, or writes one with a non-literal index.

The existing definition share (`shareWithDef`) then takes the row. In a generate scope, the call is
emitted as written. The law mints nothing.

**Converts** FunctionParam, SelectGivenBySelectOnParameterInFunction and func_local_array, in both
modes (6 row-modes). It also converts 14 grid cases: e01 e02 e03 e05 e07 e08 e09 e10 e13 e14 f03 f05
f09 f11. Every fold control is unchanged. **Census** (trace `R11U148_TRACE=1`): the law fires on those
3 rows and on Earlgrey_0_1 (11 sites, case V, prim_keccak / aes_mix_columns / aes_key_mix_columns). At
Earlgrey, ours already kept those calls, so the database is byte-unmoved there (checked with
`carhs_db`). In the probe set it fires on `r10earl_repro/u`, which is also byte-unmoved.

**Left:**
- **e12**: `s = '0; s[0] = 2'd1; return s[0] ^ a` keeps in golden. Not claimed.
- **f08**: `return P + a` keeps in golden. Not claimed; the value read path is not decoded.
- **The fold cases' own encoding** (f01/f02 `file`, f04/f10 values). These folds are golden's too, so
  they sit outside this law.

### E2: the gen-scope constant (SumOfParametersInNestedForLoops)

**Face.** Golden lists `constant 6:34-6:39 UINT:3` plus its `ref_typespec` and `int_typespec` under
the gen-scope `cont_assign` (#163). Ours lists nothing there: the Rhs is the param_assign's own
constant, already walked in that listing.

**Decode.** `writeCont_assign`'s trailing case reduces the block-localparam read to the param_assign's
value constant. It then calls `adjustSize(tps, ..., res, true)` (UhdmWriter.cpp 2274), in
`third_party/Surelog/src/DesignCompile/CompileHelper.cpp` (4065). adjustSize behaves as follows:

- `ts == nullptr` returns the object itself (4073).
- The vpiUIntConst case `clone_tree`s under `uniquify` (4106/4110).
- Other encodings are mutated in place.

`tps` is non-null only on the `lhs->UhdmType() == uhdmref_obj` road (2121), where
`bindVariable(mod, m, ...)` finds a MODULE-level net or variable.

**Grid** (`cases/E2`, 15 cases; golden copy or share read off uhdm-dump in
`evidence/grid/E2_copy_or_share.txt`):

| golden | cases |
|---|---|
| own copy | g01 g02 g03 g07 g09 g10 g11 g13 g15 (UINT, plain Lhs of a module-level net or variable) |
| shared | g04 BIN, g05 HEX, g06 `o[i]` select Lhs, g08 INT (`2 * 3`), g12 part-select Lhs, g14 generate-local net Lhs |

**Law `genLpUintCaRhsOwnCopy148`**, switch `R11U148_E2_OFF`. When a UINT value is read by a plain Lhs
naming a non-implicit net or a variable declared in the module body, the gen-scope cont_assign gets its
own constant: same value, size, encoding and span, and a fresh ref_typespec with the same full name.
That ref_typespec's actual mirrors the source's after the `pendingGenLpTs` drain. The param_assign keeps
the original. Every other read keeps the share.

**Converts** SumOfParametersInNestedForLoops in both modes (2 row-modes), and grid cases g01, g09 and
g15. The equal controls g04, g05, g06 and g12 are unchanged. **Census**: the law fires on
SumOfParameters and on LocalParamInNestedForLoops. LocalParamInNestedForLoops, both modes:
`differ:fullname(2) -> differ:fullname(1)`. Its type divergence at #184 is gone, and the remaining
field is the N0008 `ref_typespec` full name (`work@top` vs empty, pair A's typespec-linkage ground).

**Left:** g02, g03, g07, g10, g11 and g13 are copies in golden and are copied now too, but pre-existing
stage-1 differences keep them unjudged.

### I: the package parameter read in a signature range (simple_package)

**Face.** Golden lists nothing under `ref_obj DATA_WIDTH`, in the range of the elaborated package's
function return and argument (#108/#116). Ours lists `constant 6:32-6:34 UINT:32 size 64` plus its
typespec. The object identities are:

| listing | ref_obj Actual (golden) | ref_obj Actual (ours) |
|---|---|---|
| elaborated package function | uhdmtopPackages param_assign Rhs, id 15, size 32 | uhdmallPackages one, id 6, size 64 |
| module copies | the same object | the same object |

**Decode.** Surelog compiles every package twice (`CompilePackage.cpp:66`, the `getUnElabPackage()`
twin). It writes the elaborated compile with `writePackage(pack, p, s, true)` (UhdmWriter.cpp 4993)
and the definition with `writePackage(pack->getUnElabPackage(), p, s, false)` (5028). Each listing's
subroutine ranges therefore bind that listing's own parameter value. The r10fsv3 S3 note in TypeEmit
says "a return/arg range keeps the def-view constant in both views". Golden refutes it on every grid
shape (`evidence/grid/I_sig_binding.txt`, `pkgsig_db`: golden TOP/TOP, pristine ALL/ALL, law TOP/TOP).

**Law `pkgTfSigRangeTopViewConst148`**, switch `R11U148_I_OFF`, in TypeEmit `emitSyntaxExpr`'s
tfTypeScope case. In the elaborated package listing, a return or argument range reads that listing's
`pkgParamDefRhs` value, but only when that value is a constant.

**Converts** simple_package in both modes (2 row-modes). In the probe set it converts `r11v48repro/vc1`
and `vc2` (`STRICT_NOTEQUAL differ:depth(1) -> EQUAL`, cfg_func_width_loop's shape). Grid cases i01,
i02, i03, i04, i06, i07, i08 and i10 convert. **Census**: the law fires in the UVM family (22 sites,
`UVM_LARGE_STRING`), but there it binds the object pristine already bound, and the UVM movers are the
coin (section 4).

**Left:** `r10v200repro/v200_5_modmat` reads `differ:fullname(2) -> differ:fullname(3)`. This is an
unmasking. Pristine diverged at #66 (depth), where the pv5 signature bound the definition constant, and
the law aligns it. The walk then reaches two old faces:

- The importing package pv5p's clone of `m5` lacks golden's `logic_var l5` (`pv5p::m5::l5`, 7:18).
- Clone ranges still bind the definition constant (ours `constant 5:18 size 64` at depth 11).

The law does not reach that second road: the imported clone's ranges, bound elsewhere. It is residue
I-2. **i05** (`'1` return) and **i09** (the UVM shape: non-automatic, `$swrite` body) are unchanged.

### D2: the cast target (def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot), decoded and not written (pair A)

After pass 140, the face is no longer struct against integer. `evidence/rows/def_ctx_struct_param.default.recdiff.txt`
shows the member-value constants of `cfg_t` (`c.XLEN = 32` etc., two per member) on the WRONG copy:

| golden | ours |
|---|---|
| the definition package's `CfgEmpty = cfg_t'(0)` cast target (#37) is clean | stamped (#37: 2 per member) |
| the elaborated package's (#167) carries the stamps | clean (#173) |

The two package listings' cast targets are swapped. The binding is pass 140's law
`pkgTypedefCastTargetTs140` (`drainShareDefParamTs` in ParamEmit.cpp; pending list registered in
ExprEmit). It binds every deferred cast in both listings to `pkgTopTypedefTs`, and the evalFunc member
stamp sits on the other copy (`stampEvalFuncLeftovers`, ParamEmit). The fix is to bind the definition
listing's cast to the definition package's typedef, and it is on pair A's files. Count: 6 row-modes.

### D: the member default (StructParamFuncBodyFieldCompare), decoded and not written (pair A)

Golden stamps `cfg_pkg::cfg_t` members in every listing that resolves the typedef after elaboration.
The stamps appear at ten listings, from #189 on: XLEN gets `constant 30:23-30:25 UINT:64 size 32` (the
`unsigned'(64)` of `Base`), twice. Flag gets the UNREDUCED `operation 26:14-26:47`
(`(c.NrRules > 0) && (c.Length > 0)`, with its hier_paths), twice, because evalFunc could not reduce it.
Ours stamps three listings only (#426, #614, #694). The member stamp is evalFunc's `setValueInInstance`
case, `typespec_member::Actual_value`, modelled by `stampEvalFuncLeftovers` (ParamEmit.cpp). The caller
here is a module parameter's DEFAULT `cfg_pkg::build_config(cfg_pkg::Base)`, and an operation-valued
member is a shape L3 does not model. This is pair A's ground. Count: 2 row-modes (golden 923 records, ours 809).

### G: the extra folded constant (BlackParrotComplex), decoded and not written (pair A)

`routing_matrix_p = (dims_p == 2) ? StrictXY : StrictX`. Golden's elaborated param_assign (id 1929)
lists no Rhs child: its Rhs is StrictXY's OWN value object, the concatenation `operation 9:31-25:33`,
already walked in that listing (uhdm-dump in `evidence/rows/ids.txt`). ExprEval's vpiConditionOp case
returns the reduction of the taken case, and `getValue(StrictXY)` hands back the param_assign's Rhs
object, which is an operation, not a constant. Ours folds to `constant 40:68-40:102
UINT:553163846905791 size 50` with a location-less logic_typespec (id 806). The law would be: a
conditional whose taken case is a bare parameter reference with an aggregate value shares that
parameter's Rhs object. The site is the elaborated param_assign emission (ParamEmit, pair A). Count: 2
row-modes.

### ARR: the net binding (array_assign), decoded and not written (pair A)

`pb = pa;` in `always_comb` sits in the shared process (ref_obj id 170 golden / 116 ours, in both
module listings). Golden's `ref_obj pa` Actual is the `var_select pa[0][0]` at 56:9-56:17, the first
Lhs in the same block that names `pa`, already listed. Ours binds the definition `logic_net pa`, not
yet walked in the elaborated listing, so it lists 3 extra records. This looks like a producer
name-keyed binding that takes the first object written under the name. The candidate site,
`UhdmWriter::lateBinding` (UhdmWriter.cpp 3297), is not pinned. The site on our side is the procedural
reference binding (StmtEmit/ExprEmit), which is pair A's ground. Count: 2 row-modes.

### C3 leftovers (StructArray... / NestedStructArray...PassedAsPort), decoded and not written

After pass 140's law `impLhsCloneArrayTsOwnCopy140`, no structural head remains. StructArray...
(`line(2)`) differs on the elaborated port `region_attrs_i`'s high_conn:

| field | golden | ours |
|---|---|---|
| operation span | the ACTUAL's span `23:23-23:33` (the `HwDataAttr` reference), full name `work@top.u_hw_sel.region_attrs_i` | the package parameter's pattern span `6:49-10:5`, full name `work@top.u_hw_sel.u_hw_sel.region_attrs_i` (the instance doubled) |

Golden substitutes the value and relocates the copy to the reference. The Nested twin (`fullname(4)`)
adds two ref_typespecs where ours stores `work@top` / `work@top.u_hw_sel` and golden stores none. The
site is the port-connection value substitution; not pinned in this pass (probably ParamEmit, pair A).

### C2 (DefaultPatternInt, N0441)

This is pair A's (r11u145). It is reproduced (`depth(1)`, `evidence/rows/heads_0024d365.txt`) and not
decoded here.

## 3. Gates (law5 against pris, same-length workdirs `/tmp/r11u148_swP` and `/tmp/r11u148_swL`, `--jobs 3`)

| gate | pristine sweep | law sweep |
|---|---|---|
| probe vs golden_probe.csv | 0 / 0 / 0 (EQUAL 2295, STRICT_NOTEQUAL 1792) | regressions 0, conversions 2 (vc1, vc2), changes 1 (v200_5_modmat, the unmasking in class I) |
| surelog vs golden_surelog.csv | 0 / 0 / 0 | 0 / 0 / 0 |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 0 / 0 / 0 | regressions 0, conversions 10, changes 2 (LocalParamInNestedForLoops, fullname 2 -> 1, both modes) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 | 803 / 66 / 2 / 0; the verdict column is identical to pristine on all 871 rows |

The 10 conversions (fresh rows in `evidence/sweeps/fresh_rows_u2r.csv`) are FunctionParam,
SelectGivenBySelectOnParameterInFunction, func_local_array, SumOfParametersInNestedForLoops and
simple_package, each `default` and `testflags`, each `STRICT_NOTEQUAL -> CMP_EQUAL,,,equal`.

- **Downstream rows of the converted tests**, all IDENTICAL, `differs` empty:
  `FunctionParam,IDENTICAL,NO_GATES,NO_GATES,0,0,,`; the same for SelectGivenBy..., func_local_array,
  SumOfParameters... and LocalParamInNestedForLoops; `simple_package,IDENTICAL,OK,OK,180,180,,`.
- **uhdm-cmp** reads 0 lines on all 20 byte movers.
- **Canaries.** canaries.sh surelog ok=52 changed=0 (7 unknown, the u2r-only names). uhdm2rtlil
  ok=16 changed=0 (25 unknown, the rest). ctcan2 `EXPECT_UNKNOWN=1` surelog PASS (ok=58). ctcan2
  `EXPECT_UNKNOWN=6` uhdm2rtlil PASS. See `evidence/sweeps/canaries.txt`.
- **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`): surelog 5 / 960 movers, the
  selfcheck flagged 959 / 960. uhdm2rtlil 12 / 1608 movers, the selfcheck flagged 1607 / 1608.
- **Probe databases** were compared by `cmp`: 3 / 4087 movers.

**Movers, predicted by name before the byte comparison** (census `evidence/census/`, the law binary
under `R11U148_TRACE=1` on every command of the pristine sweep):

- **The 12 uhdm2rtlil movers** are exactly the census's firing rows. FunctionParam, SelectGivenBy and
  func_local_array are E. SumOfParameters and LocalParamInNestedForLoops are E2. simple_package is I.
  All are in both modes.
- **The 3 probe movers** (v200_5_modmat, vc1, vc2) are I-firing cases. The census also names
  `r10earl_repro/u` (E) and `r10uvm67repro/c5_clone` (I), which fire without moving a byte.
- **The 5 surelog movers are the UVM coin**: MiniAmiq default and testflags, Scoreboard default,
  SeqDriver testflags, SimpleUVM testflags. The order-blind uhdm-dump diff shows 0 or 4 UINT /
  vpiDecompile lines (`evidence/sweeps/uvm_coin_orderblind.txt`). The census run of the same law5
  binary reproduced the pristine bytes for Scoreboard default and SeqDriver testflags. Across all 2560
  unfenced rows, the census databases equal the law sweep's except these same five.
- **Switch attribution** (`evidence/sweeps/switch_check.txt`, `drivers/swcheck.sh`). Every mover is
  owned by exactly one switch:
  - Each class switch alone returns its movers to the pristine bytes.
  - `R11U148_OFF=1` returns all 15 non-coin movers to the pristine bytes.
  - On the 49 grid cases, `R11U148_OFF=1` equals pristine byte for byte (`evidence/grid/grid_table.txt`).
  - As a positive control, the same 49 cases give 34 movers with the law on.

## 4. Totals and ranked residue

**Converted by this law.patch:** 10 corpus row-modes (5 tests, both modes), 2 probe cases, and 25 grid
cases (E 14, E2 3, I 8). Nothing regressed. No downstream verdict moved.

Ranked residue, by row-modes:

1. **D2**: 6 row-modes. Swap the two listings' cast targets (pair A, `pkgTypedefCastTargetTs140`'s
   drain).
2. **G** and **D**: 2 row-modes each (pair A, ParamEmit): the taken-arm parameter Rhs share, and the
   module-default evalFunc stamp with an operation-valued member.
3. **ARR**: 2 row-modes (pair A, procedural binding to the first var_select naming the array).
4. **C3 leftovers**: 4 row-modes. These are span and name faces now, not structural (the port
   high_conn copy relocated to the reference).
5. **I-2**: the imported clones' signature ranges (v200_5_modmat).
6. **E residues**: e12 and f08 (evalFunc keep shapes not decoded).
7. **E2**: the six stage-1 cases.

No class needed an object golden holds once to be copied. E declines a fold. E2 copies only where
golden's adjustSize copies. I rebinds to an object golden already lists.

## 5. Files

- **law.patch**: the law (src/ModuleEmit.cpp, src/TypeEmit.cpp).
- **cases/E, cases/E2, cases/I**: 49 cases, a `dut.sv` each. Goldens are rebuilt with the pinned
  Surelog, using check_probe's `SL_ARGS`.
- **drivers/**:
  - `grid1.sh` builds a case's golden, runs ours, and runs uhdm-cmp and strictcmp.
  - `carhs.py` and `ctx.py` are record readers.
  - `census.py` and `census_probe.py` run the trace census.
  - `swcheck.sh` runs the switch attribution.
  - `ndump.sh` produces a path-normalised uhdm-dump.
  - `carhs_db.cpp` and `pkgsig_db.cpp` build with the `cc.sh` flags of `r11u142map`.
- **evidence/rows**: the heads at 0024d365, the record diffs and the identities.
- **evidence/grid**: the grid table and the per-class golden readings.
- **evidence/sweeps**: both sweep summaries, byteverify, canaries, the switch check, the UVM coin and
  the fresh rows.
- **evidence/census**: the firing sites by row and case.
