# v11u232: adversarial verification of r11u232 (pass 232, the expression/parameter ground): two breaks in § caCallArgParamFormalTs232 fixed (§ caCallArgCastAbstains232v, § caCallArgTruncByBase232v)

**Base:** `9c9c11d6` (branch matrix-1.87).

**Verdict: ACCEPTED WITH FIX.**
- Every headline number in the implementer's README ([../r11u232repro/README.md](../r11u232repro/README.md)) reproduces exactly.
- Fresh cases broke one law, § caCallArgParamFormalTs232, in two ways on legal SV. Both are fixed in `src/ParamEmit.cpp` (the law's own file, ground A). Each fix has its own switch; `R11V232_OFF` drops both, and `R11U232_OFF` drops them along with the laws.
- `src/R232.h` gains `r11v232On`.
- The fix binary writes the law binary's bytes on every gate database.

This is the second run of this verification. The first run (2026-09-29) died on the weekly usage limit and its worktrees and scratch were removed. Its fix and its cases (FX, DX, NX, CX, LX) survived in its transport patch. This run did the following:
- rebuilt every binary;
- re-ran every sweep, census and grid;
- reproduced both breaks on fresh instances of its own (MF m11, m12, m13);
- added 25 fresh cases (MF, MD, MN, ML, MC).

The four slang-fenced tests are never named here. Every driver reads them from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed.

## 0. Verdict per law

| law (switch) | verdict | evidence |
|---|---|---|
| § defAggParamBindsImportClone232 (`R11U232_DEFAGGIMP_OFF`) | holds on judge-equal shapes | DX 17 + MD 8 cases. d05 (header imports, literal overrides) moves its head #28 -> #276. d04 and d07 move toward and lose no record. The losses are on stage-1 shapes only (residue 3). |
| § caCallArgParamFormalTs232 (`R11U232_CAFORMALTS_OFF`) | **2 breaks, fixed** | Section 2 |
| § structCopyNestedAnnotDeep232 (`R11U232_NESTANNOT_OFF`) | holds | NX 10 + MN 2. nx08 enters STRICT_EQUAL in both views. The record losses are on stage-1 shapes only (residue 3). |
| § ovrMemberReadLocatesLeftover232 (`R11U232_OVRLEFTLOC_OFF`) | holds | LX 6: FuncStructVal copies, head `file -> depth`, as on the row. ML 3 (fresh small shapes): the law does not fire and the bytes do not move. |
| § cloneRetNoMintBindsHome232 (`R11U232_CLONERETMINT_OFF`) | holds | CX 6 + MC 1. Every judge-equal view stays STRICT_EQUAL and the bytes do not move. |

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| pristine | `3765eba7b293ec7c2de692dc55b5866e` | fresh worktree at `9c9c11d6` |
| law | `87a92c4132038bf3359a77d4e034f633` | fresh `9c9c11d6` + `/tmp/r11u232.patch` (md5 `0a2fabb7...`, applies clean) |
| **fix** | **`5a84e76e2b950834280df43382edcb59`** | law + the two fixes |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | built in the pristine worktree; identical to the main tree's |
| strictcmp_x | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's variant, used for the chain-keyed away census |

All three builds used `-DSLANG_UHDM_USE_SYSTEM_DEPS=ON` and `-j 1`/`-j 2`. One build was killed by the OOM killer and retried.

**The slang move.** Every build here links the installed slang 12.0.0+545f88b2e (the master's v12.0 anchor of 2026-10-04). So the md5s differ from the implementer's (pristine `8d6b7668`, law `821750b1`, built against the 11.0 line).

**The bridge.** The implementer's frozen pristine and law binaries were run beside this run's pristine and law binaries on all 166 grid cases in both views (332 case-views):
- every database is byte-identical between the two pristines and between the two laws;
- this run's pristine sweep matches the base exactly (below).

So every number below compares with the implementer's.

**Sweeps.** Each sweep is `tests/sweep.sh --jobs 3` from the pristine worktree's harness, with workdir names of equal length: `v11u232_wP`, `v11u232_wL`, `v11u232_wF`. The `cmds.txt` audit:
- every one of the 3265 slang invocations in each sweep's surelog and uhdm2rtlil stages (fenced rows excluded) names that sweep's own frozen binary;
- no other slang-uhdm binary appears.

## 2. The breaks and the fixes

Both breaks are in § caCallArgParamFormalTs232, in ParamEmit `stampEvalFuncLeftovers`.

### 2.1 § caCallArgCastAbstains232v (switch `R11V232_CASTARG_OFF`)

**Break.**
- The law strips every slang `ConversionExpression` around a call argument, so an explicit cast counts as the bare parameter.
- In Surelog, `reduceExpr` answers a cast with a fresh constant, or keeps the cast operation. So evalFunc's `exparg->Typespec()->Actual_typespec(tps)` never reaches the elaborated `param_assign` Rhs.
- Golden keeps the parameter's own typespec; the law writes the formal's.

Measured (elaborated `param_assign` Rhs typespec, golden / pristine / law / fix):

| case | argument | golden | pristine | law | fix |
|---|---|---|---|---|---|
| fx20 (judge-equal, parse view) | `q::cnt(q::mask_t'(M))` | own 17:24-35 | own | formal 4:39-45 | own |
| m12 (fresh) | `q::cnt(3'(M)) + 1` in `u`, a bare `q::cnt(M)` in `v` | `u`: own 11:24-35; `v`: formal | same | `u`: formal (lost) | same as golden |
| fx02 / fx03 / fx21 / fx28 | `32'(N)`, `int'(N)`, `3'(M)`, casts inside a nested call and under `+` | own | own | formal | own |

- On fx20, the strict head moves `type` #219 -> `name` #209 under the law. 4 golden records are lost (the parameter's own typespec, its range and both bounds) and 0 are gained.
- The fix writes the pristine bytes on fx01-fx03, fx20, fx21, fx28 (both views).
- Signing casts (`signed'`, `unsigned'`) stay transparent: golden fx18, fx23, fx27 stamp the formal.

**Fix.** The argument walk looks through implicit conversions and signing casts only (syntax kind `SignedCastExpression`). Any other explicit cast makes the argument not a parameter. Traced as `caCallArgCastAbstains232v <function>#<index>`.

### 2.2 § caCallArgTruncByBase232v (switch `R11V232_TRUNCBASE_OFF`)

**Break.**
- The truncation to a narrower logic formal read the value with `std::stoll(v.substr(col + 1))`. That reads `HEX:1F3` as 1 and throws on `HEX:AB`.
- evalFunc reads the value with `ExprEval::get_value`, which parses each base.

| case | override, formal | golden | pristine | law | fix | downstream P / L / F |
|---|---|---|---|---|---|---|
| fx05 | `12'h1F3`, `logic [7:0]` | UINT:243 size 8 | HEX:1F3 size 12 | **UINT:1** size 8 | UINT:243 | EQUIVALENT / EQUIVALENT / **IDENTICAL** |
| m11 (fresh) | `8'hAB`, `logic [3:0]` (last call) | UINT:11 size 4 | HEX:AB | HEX:AB (stoll threw) | UINT:11 | EQUIVALENT / EQUIVALENT / **IDENTICAL** |
| m13 (fresh) | `16'hABCD` and `16'd700`, `logic [7:0]` | UINT:205, UINT:188 | HEX:ABCD, INT:700 | HEX:ABCD, UINT:188 | UINT:205, UINT:188 | EQUIVALENT / EQUIVALENT / **IDENTICAL** |

- Sized octal (m01), negative and unsized decimals (m10) and a real (m03) were already right: slang hands those over in decimal.
- The downstream verdicts are in [evidence/downstream/cases.txt](evidence/downstream/cases.txt).

**Fix.** The value is parsed in its own base (`HEX:` 16, `OCT:` 8, `BIN:` 2, `UINT:`/`INT:`/`DEC:` 10) and must parse whole; otherwise it is not truncated. Traced as `caCallArgTruncByBase232v <value>` for a value that is not decimal.

**Positive control.** The fix binary with `R11U232_TRACE` writes:
- `caCallArgCastAbstains232v cnt#0` on fx20 and on m12;
- `caCallArgTruncByBase232v HEX:1F3` on fx05;
- `caCallArgTruncByBase232v HEX:ABCD` on m13.

## 3. Reproduction of the implementer's numbers (law binary, this run)

| claim | reproduced |
|---|---|
| probe 0 regressions / 0 conversions / 2 changes (k17_func_in_pkg, k20_cfg_func_width `line(3) -> type(1)`), EQUAL 3453 / STRICT_NOTEQUAL 634 | yes ([evidence/sweeps/wL.log](evidence/sweeps/wL.log)) |
| surelog 0 / 0 / 2 changes (FuncStructVal d `file(5) -> depth(1)`, t `file(9) -> depth(1)`) | yes |
| uhdm2rtlil 0 regressions / **2 conversions** (struct_param_func_config d/t) / 2 changes (cfg_func_width_loop d/t `line(3) -> type(1)`), now 1604 + 2 | yes |
| downstream 803 / 66 / 2 / 0, csv identical to pristine's | yes |
| byteverify 66 / 2560 = the 66 predicted corpus row-modes; SELFCHECK 2559 / 2560 | yes: the same 66, none unpredicted ([evidence/movers/](evidence/movers/)) |
| probe 69 movers, all predicted; 4 predicted ones unmoved (g171_b_homes, g194_c_clone, v194_a_explicit, v194_e_explclone) | yes, the same 69 and the same 4 |
| 19 downstream lanes moved, all predicted | yes, the same 19 |
| chain-keyed away census over 135 databases: 0 away / 1340 toward; flat key 6 away (struct_param_func_config d/t, 3 + 3) / 1337 toward | yes, exactly ([evidence/away/away_rows_law_vs_pristine.txt](evidence/away/away_rows_law_vs_pristine.txt)) |
| canaries surelog ok=50 changed=2 (FuncStructVal d/t), u2r ok=16 changed=0; ctcan2 surelog ok=58 PASS, u2r ok=2 PASS | yes, for both the law and the fix |
| R11U232_OFF writes the pristine bytes on all 158 implementer case-views | yes, and on all 346 case-views of this grid |
| 20 implementer case-views enter STRICT_EQUAL | yes, the same 20 |

**SELFCHECK.** It reads 2559 / 2560, which is the self-check's correct answer and not a movers line. The check compares every patched file with ONE fixed file of the other side, and the path whose file IS that fixed file cannot be flagged.

The sweep exits 1 on `law index STALE: tests/LAWS.md` only. The pristine sweep does the same: the base is stale. The patch carries the regenerated index.

## 4. Gates of the fix binary (against the committed baselines)

- **probe:** regressions=0 conversions=0 changes=2 (k17_func_in_pkg, k20_cfg_func_width), EQUAL 3453 / STRICT_NOTEQUAL 634.
- **surelog:** regressions=0 conversions=0 changes=2 (FuncStructVal d/t), 930 CMP_EQUAL + 24 STRICT_NOTEQUAL.
- **uhdm2rtlil:** regressions=0 **conversions=2** changes=2, 1604 CMP_EQUAL + 2 STRICT_NOTEQUAL. The fresh rows:

```
struct_param_func_config,default,CMP_EQUAL,,,equal
struct_param_func_config,testflags,CMP_EQUAL,,,equal
cfg_func_width_loop,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)
cfg_func_width_loop,testflags,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)
FuncStructVal,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
FuncStructVal,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
BlackBePipeInt,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)
BlackBePipeInt,testflags,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)
cfg_func_width_loop,IDENTICAL,OK,OK,10,10,,                    (downstream)
struct_param_func_config,IDENTICAL,NO_GATES,NO_GATES,0,0,,     (downstream)
```

- **downstream:** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; not identical and not excused = 0.
- **Fix against law:**
  - the probe, uhdm2rtlil and downstream csvs are identical;
  - the surelog csv differs only in LowMemLib and LowMemPkg testflags, whose detail text spells the workdir (environment);
  - byteverify fix vs law reads **0 / 2560**;
  - probe databases 0 / 4087 differ;
  - downstream lanes: 0 differ.

## 5. Determinism

Three concurrent `verify_golden.py` runs of the fix binary covered Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard and BuildUVMPkg in both modes ([evidence/det/](evidence/det/)):
- one hash per row-mode, each equal to the fix sweep's database;
- Scoreboard testflags writes no database, as at the base.

## 6. The grid ([evidence/grid/](evidence/grid/))

**Scope:** 173 cases in both views, 346 case-views: the implementer's 79, the first run's 67 and this run's 27. Each case-view ran 8 binary/switch tags (drivers/grid.sh): 2768 runs, **every exit code 0**.

**Switch checks:**
- `R11U232_OFF` on the law writes the pristine bytes on all 346.
- On the fix, `R11U232_OFF` also writes the pristine bytes on all 346.
- `R11V232_OFF` on the fix writes the law's bytes on all 346.
- Fix against law, 20 case-views move. Each is restored by its own fix's switch alone:
  - cast: fx01, fx02, fx03, fx20, fx21, fx28, m12, both views;
  - base: fx05, m11, m13, both views.

**Pristine -> fix:**
- 24 case-views enter STRICT_EQUAL: the implementer's 20, plus fx11 and nx08 in both views.
- 12 move their strict head later: LX ×8 `file -> depth`, fx24 `line -> type`, fa39_el `line -> file`, and MD d05 (both views) `fullname #28 -> name #276`.
- None leaves EQUAL. None leaves judge-equality: uhdm-cmp's line count is unchanged on every case-view.

**Value census** (drivers/pa.py, every elaborated `param_assign` Rhs: value, size, typespec location, golden / P / L): pristine -> law loses a golden fact only on the cast cases. The fix restores every one.

**Constant slots covered:**
- parameter defaults: fx15, m10, dx04;
- dimension bounds: m11, d02, d07, nx07;
- part-select bounds and widths: m04, fx13, n01;
- replication counts: m07, d02, n01, fx14;
- localparam initializers: m07, n01;
- overrides: every DX, FX, MD, ML and LX case.

**This run's cases** (each case's first line names its law):
- **MF** (§ caCallArgParamFormalTs232; m12 § caCallArgCastAbstains232v; m11 and m13 § caCallArgTruncByBase232v):
  - m01 a sized octal value; m02 a hex value with an x digit; m03 a real parameter;
  - m04 a call under `$clog2` and in an indexed part-select base;
  - m05 enum and string formals; m06 a struct formal;
  - m07 depth 3, if-generate and for-generate instances, a replication count and a localparam;
  - m08 two formals of different width on one parameter, plus a defaulted instance;
  - m09 an interface body and an implicit net; m10 unsized and negative values;
  - m11 a wildcard import with a port range from the call; m12 a cast beside a bare call; m13 sized hex and decimal values.
- **MD** (§ defAggParamBindsImportClone232):
  - d01 a packed union, a qualified-typed parameter and a for-generate instance;
  - d02 and d07 a file-level import, an uninstantiated definition, a dimension bound and a replication count (d02 pattern overrides, d07 literal overrides);
  - d03 and d08 header imports, an interface and two levels;
  - d04 and d05 literal overrides;
  - d06 body imports with a member read in an override.
- **MN** (§ structCopyNestedAnnotDeep232): n01 three nesting levels in the constant slots; n02 a nested member passed on as its own parameter, in two instances.
- **ML** (§ ovrMemberReadLocatesLeftover232): l01 positional and named reads of written and unwritten members; l02 one level down, the same member twice, a macro-born override; l03 a for-generate instance and a parenthesized override.
- **MC** (§ cloneRetNoMintBindsHome232): c01 class methods writing the return name through a bit select, inc/dec and a call index, with an extern body below and a virtual override.

## 7. Process and fence

**Fence handling:**
- The drivers read `$FENCED` from canaudit.sh and fail closed: env.sh, case.sh (refuses a fenced path), pa.py, caseaway.py and chain.py.
- byteverify ran on hard-link mirrors without the fenced paths (r11u232repro drivers/bvmirror.sh: 2560 mirrored, 8 skipped).
- The evidence csvs and logs drop every line that holds a fenced name.
- No binary or script ran on a fenced test's sources.

**Slips, with nothing run on fenced sources:**
- (a) This verification printed the `FENCED=` line once while reading it.
- (b) One `uhdm-dump` call was made in a shell that had not sourced the environment. The shell tried to execute `L.uhdm` by bare name and failed with "command not found". Nothing ran and no file was written. Every later call guards with `[ -x "$UHDM_DUMP" ]`.
- (c) One scan for fenced names ran with an empty pattern. It matched every case file. Rerun with the pattern set, it reads 0.

**Implementer's directory:** seven of its decode helpers (objid.cpp, ostats.cpp, minted.cpp, cc_objid.sh, pats.py, nest.py, tsusers.py) hold no fence check. They read databases named on their command line.

**Patch files:** no patch file is kept here. `/tmp/r11u232.verified.patch` is transport only.

## 8. Residues, ranked

1. **BlackBePipeInt d/t** #15272 / #15268 (the implementer's decode: golden's defaulted pattern member is the shared operand of `bp_unicore_cfg_p`'s elaborated pattern; the emitting branch is not pinned).
2. **cfg_func_width_loop d/t** #516 / #426: the kept `q::maxw(M)` call. ModuleEmit `emitContAssigns`, § evalFuncSelectKeepsCall148 (sister ground). Golden also keeps a call whose argument is an explicit cast (fx20, m12); same site.
3. **Record losses on stage-1 shapes** (uhdm-cmp already unequal at the base; net toward):
   - **The definition law, a struct-pattern override** (d02, d03, d08, dx03, da11): ours writes the elaborated Rhs as a constant at the default's span, where golden keeps the operation with its own clone (the stage-1 face). The law then binds the constant's typespec to the import clone: 2 records per view, against 4-14 toward.
     - The right fix is the operation itself. A narrower one is to skip `rhsRt` when the instance overrides that parameter.
   - **The nested-copy law** (nx07_el, nx09, na06): 1-3 records against 164-427 toward.
4. **FuncStructVal** d #7975 (N0891, TypeEmit `buildStructTs`, sister ground) and t #13254 (the body member reference's leftover).
5. Formal stamps that ours writes and golden does not (fa23, fa26, fx13), the elaborated typedef-typed Rhs typespec (the `q::mask_t` object), and the 408 home-listing minted locals per MiniAmiq / SeqDriver row-mode (ModuleEmit `drainFuncRet`).
6. Brief items (2) int stamp, (3), (4), (5) and (6), untouched as the implementer reports.

## 9. Files

- `cases/`: FX, DX, NX, CX, LX (first run); MF, MD, MN, ML, MC (this run).
- `drivers/`: env.sh, case.sh, grid.sh, grid_an.py, pa.py, caseaway.py, chain.py.
- `evidence/`: sweeps, movers, away, grid, det, downstream.
