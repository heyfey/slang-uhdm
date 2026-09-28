# v11u198 — adversarial verification of r11u198 (the expression/parameter ground): every headline number reproduced bit for bit, one break found and refined (§ vsStampReducedCtxOnly198v), ACCEPT-WITH-FIX

**Base.** `7eb6f4b5` (branch matrix-1.87, pass 195). Worktrees `/tmp/wt_v11u198pris` (pristine) and `/tmp/wt_v11u198`
(`/tmp/r11u198.patch` applied, then the refinement below), system-deps config, `-j 2`. The refinement edits
`src/ExprEmit.cpp` only (ground A). Nothing under `results/`, `third_party/` or `tests/` (but the regenerated
`tests/LAWS.md`) is edited; no sister-ground file (TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit, uhdm_main) is
touched.

**The fence.** `drivers/env.sh` reads the four names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`
and every driver here fails closed on it; `census.sh` runs the corpora and the downstream lanes with a `--filter`
built from the fence; `bvmirror.sh` leaves the 8 fenced row-mode databases out of every byte comparison
(`fenced_skipped=8`); the downstream lane comparison skips them too. The gate sweeps dispatched every row; their csv
verdicts are the only fenced facts cited (unchanged). A grep of this directory for the four names reads 0.

## 0. Verdict

**ACCEPT-WITH-FIX.** Every number r11u198 reports reproduces exactly on binaries built here. Six of its seven laws
hold on 115 fresh cases in both forms (parse and `-elabuhdm`) and downstream. One law,
§ callArgVarSelStamp198, breaks legal SV where pristine was right: a user call whose `var_select` actual it stamps
sits under a system call Surelog's evaluator never reduces through (`$countones`, `$bits`, `$size`, ...), or under
an operation further up than the immediate parent in the definition listing / the `-elabuhdm` body. Four fresh cases
go EQUAL -> STRICT_NOTEQUAL. The refinement § vsStampReducedCtxOnly198v (`R11V198_VSSYS_OFF`) fixes all four and
converts four more. It fires on no corpus row, probe case or downstream lane (census), so every gate number of the
verified binary equals the law binary's. The verified patch is `/tmp/r11u198.verified.patch`.

| row / face | pristine `7eb6f4b5` | r11u198 (`180bbe38`) | verified (`489a0c07`) |
|---|---|---|---|
| **ibex_pmp default** (uhdm2rtlil) | `STRICT_NOTEQUAL differ:type(1)` | **`CMP_EQUAL`** | **`CMP_EQUAL`** |
| **ibex_pmp testflags** (uhdm2rtlil) | `STRICT_NOTEQUAL differ:type(1)` | **`CMP_EQUAL`** | **`CMP_EQUAL`** |
| arb_idx_cast d/t (uhdm2rtlil) | `differ:endcol(17)` | `differ:endcol(3)` | `differ:endcol(3)` |
| probe | EQUAL 3306 / 781 | EQUAL **3343** / 744 (37 conversions, 2 changes) | the same 3343 / 744, `probe.csv` identical to the law sweep's |
| surelog | regressions=0 conversions=0 changes=0 | 0 / 0 / 0 | 0 / 0 / 0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same, `downstream.csv` byte-identical | the same, byte-identical |
| fresh grid (115 cases, parse / `-elabuhdm`) | – | **2 / 4 worse than pristine**; 51 / 35 converted | **0 / 0 worse**; 54 / 35 converted |

Fresh rows (verified sweep `/tmp/v11u198_swF`, not written to `results/`):

    ibex_pmp,default,CMP_EQUAL,,,equal
    ibex_pmp,testflags,CMP_EQUAL,,,equal
    arb_idx_cast,default,STRICT_NOTEQUAL,differ:endcol(3),,differ:endcol(3)
    arb_idx_cast,testflags,STRICT_NOTEQUAL,differ:endcol(3),,differ:endcol(3)
    ibex_pmp,IDENTICAL,OK,OK,52,52,,           (downstream.csv)
    arb_idx_cast,IDENTICAL,OK,OK,11,11,,       (downstream.csv)

## 1. Binaries (frozen `chmod 555` in `/tmp/v11u198_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `86812cac4e113f93d477723d6437b44c` | `7eb6f4b5`, built here; equal to the md5 the brief pins for the main tree's build at the base |
| `law.bin` | `180bbe38c02c88d601e02c6671f01e7a` | `7eb6f4b5` + `/tmp/r11u198.patch`, built here: **the implementer's md5, reproduced** |
| **`fix1.bin`** | **`489a0c07fab0b985e8f5c5123eff5d9f`** | **the verified sources** (`/tmp/r11u198.verified.patch` on a fresh `7eb6f4b5`, section 7) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | built here; equal to the main tree's |

`cmds.txt` audit ([evidence/sweeps/cmds_audit.txt](evidence/sweeps/cmds_audit.txt)): swP 3273 of 3273 `slang:` lines
name `pris.bin`, swL 3273 `law.bin`, swF 3273 `fix1.bin`. Every case run here records its rc (`[rc=N]` in the
grid; the one rc 3 is z03, a slang elaboration error on both binaries).

## 2. The headline numbers, reproduced

Three full sweeps (`tests/sweep.sh --jobs 3`, all four stages, same-length workdirs `/tmp/v11u198_sw{P,L,F}`,
logs in [evidence/sweeps/](evidence/sweeps/)). The pristine sweep reproduces the baselines exactly: `probe.csv`
byte-identical to `results/golden_probe.csv`, surelog and uhdm2rtlil `regressions=0 conversions=0 changes=0`,
downstream 803 / 66 / 2 / 0. All three exit 1 for `law index STALE` alone (the main tree reads the same at
`7eb6f4b5`; the patch carries the regenerated file).

| claim (r11u198 README) | reproduced here |
|---|---|
| probe `regressions=0 conversions=37 changes=2`, EQUAL 3343 / 744 | the same, the same 37 names and 2 changes (g5_hop95 `fullname(7)->(2)`, g18_hop_lhs `(5)->(1)`), [compare_L.txt](evidence/sweeps/compare_L.txt) |
| uhdm2rtlil `conversions=2 changes=2`; surelog 0 / 0 / 0 | the same; the surelog csv differs from the pristine sweep's only in the two LowMem `SURELOG_FAIL` detail texts (the workdir path) |
| downstream 803 / 66 / 2 / 0, csv byte-identical to pristine | the same; 805 non-fenced lanes: 2 database movers (arb_idx_cast, ibex_pmp), **0 netlist movers** (every slang-lane `.il` and `_synth.v` byte-identical) |
| 16 / 2560 corpus movers, SELFCHECK 2559 / 2560 | the same 16 names, SELFCHECK 2559 / 2560 ([byteverify_law_vs_pristine.txt](evidence/sweeps/byteverify_law_vs_pristine.txt)) |
| 40 / 4087 probe movers, all predicted; 3 predicted not moved | the same 40 (pristine probe stage re-run from the law worktree so the embedded source paths match), the same 43 predictions, the same 3 predicted-not-moved (r11u46repro/grid2, v11u116 g2_fcall, g2_sys) |
| firing census: 21 corpus / downstream row-mode databases + 43 probe cases | reproduced with this pass's own census ([census_firings.txt](evidence/census_firings.txt)): the same rows and firing counts |
| canaries surelog ok=52, uhdm2rtlil ok=16, ctcan2 PASS both | the same on swL and swF |
| Earlgrey order-blind 12814 -> 8570 (d), 12306 -> 8316 (t); Rggen 10771 -> 10659 | the same ([orderblind_earlgrey_rggen.txt](evidence/orderblind_earlgrey_rggen.txt)) |
| UVM distances MiniAmiq 15963 -> 15837, SeqDriver 12337 -> 12189, SimpleUVM 4986 -> 4886, Scoreboard 3813 -> 3737, BuildUVMPkg 2035 -> 1983 | the same ([uvmdist.txt](evidence/uvmdist.txt)) |
| the UVM movers are § methodArgOpRefChainName198's | sorted-dump diffs pristine -> law: BuildUVMPkg 104, MiniAmiq 208, Scoreboard 104, SeqDriver 204, SimpleUVM 108 lines (above the 4-line coin), and the census shows that law firing alone on those rows ([orderblind_law_vs_pristine.txt](evidence/sweeps/orderblind_law_vs_pristine.txt)) |
| determinism: Earlgrey one hash per mode, the UVM rows the 0-or-4-line coin | three concurrent runs of `fix1.bin`: Earlgrey `899a9b821e15` / `8ad9eae9d68f` in all three (equal to the law sweep's), the UVM draws 0 or 4 sorted-dump lines ([determinism.txt](evidence/determinism.txt)) |
| the patch applies clean on `7eb6f4b5` and rebuilds `180bbe38` | yes (the law worktree is that application) |
| integration note: applies on `a015c911` except `tests/LAWS.md` | `git apply --check --exclude=tests/LAWS.md` clean on `a015c911`, and the full patch fails only on `tests/LAWS.md` |

## 3. Breaking the laws: 115 fresh cases in both forms, judged by uhdm-cmp and uhdm-strictcmp against the pinned Surelog, and downstream

`drivers/judge.sh` (parse form: `-parse -nobuiltin -nocache -sv dut.sv` vs `dut.sv --single-unit --nobuiltin`;
`ELAB=1` for the `-elabuhdm` form), goldens cached per text md5 under `/tmp/v11u198_gold`. The whole table, all three
binaries in both forms, is [evidence/grid.tsv](evidence/grid.tsv). Downstream (`drivers/ds.sh`, the harness's own
`one()`): every case gives the same verdict on pristine, law and verified (112 IDENTICAL, 2 EQUIVALENT that are
EQUIVALENT on pristine too (t30, t36), 1 SLANG_REJECT on all binaries (z03)), and every slang-lane netlist is
byte-identical between the binaries ([downstream_cases.tsv](evidence/downstream_cases.tsv)).

| law | cases (first line names the law) | result |
|---|---|---|
| § genCaCastRhsRefUnnamed198 | K x01-x19: delay `#D` / `#1` (x01, x02: golden short names too, the parameter delay is folded before the writer's delay branch), `signed'`, a child instance at depth 2 and 3 (x04, x11), two-level for (x06), a net declaration (x07), an implicit net (x08), part select of a bit select (x09), a genvar-indexed packed element (x12), a typedef cast of a concatenation (x13), a sibling-scope namesake (x15), a part-select target (x16), a hop fold inside the cast (x17), a call inside the cast (x18, declined), a var_select with a reference index (x19) | **holds**: 8 converted, 3 narrowed, NOT_EQUAL ones move toward golden (order-blind), none worse |
| § genCaUnclonedFoldOwner198 | O y01-y15: `#D` / `#1` delays (golden keeps the owner name: the parameter delay folds before the writer's delay-clone branch), a unary inside a concatenation, `+W`, child instances in a for generate, a cast of a concatenation, a system call in a ternary, a member target, nested generate, a unary under a binary (y13), two folds in nested concatenations, a sibling-scope namesake | **holds**: 6 converted, none worse |
| § genHopFoldSelName198 | N z01-z11: a system-call argument, a nested select index, a for inside a for, a child instance with two overrides, a generate-local base, a ternary index, a member base, if-then-for, an lvalue index | **holds**: 6 converted (z04 z05 z06 z07 z09 and z11 narrowed 9 -> 1), none worse |
| § ovrParamBoundOpSelName198 | N w01-w10: a for generate, a nested bound operation, indexed part-select bases, depth 3 through a parent's parameter expression, in a concatenation and a system call, nested generate, a generate-local base, an lvalue bound, a process, a net declaration | **holds**: 4 converted, w03 narrowed, none worse |
| § methodArgOpRefChainName198 | M v01-v14: a bit select in the operation, a named-block local, a foreach variable, a task call statement, a cast inside, a mid-path call, a member receiver, a module function / initial block, a class property, `inside`, a static function, a fork, a user call in the operation, a package class with `this.` | **holds**: 9 converted, 2 narrowed, none worse |
| § lvIdxCallArgIsRead198 | L u01-u12: task and function OUTPUT formals, an lvalue concatenation, two-dimensional index, a queue method, a for loop in a function, an indexed part select width, a member lvalue, `$unsigned` and a cast argument, a class-member lvalue, intra-assignment delays, a generate continuous assignment | **holds**: 8 converted in both forms, u08 / u10 move from `col(6)` to r11u198's residue R1 (`fullname(2)`, the N4 name), none worse |
| **§ callArgVarSelStamp198** | V t01-t36 | **BREAKS** (below), fixed by § vsStampReducedCtxOnly198v |

### 3.1 The break: § callArgVarSelStamp198 stamps where Surelog's evaluator never reaches the call

| case | pristine | r11u198 | verified |
|---|---|---|---|
| V/t13 `assign y = 4'($countones(f(p[1][2])));` | EQUAL / EQUAL | **STRICT_NOTEQUAL:type(1) / type(1)** | EQUAL / EQUAL |
| V/t25 `assign y = g($countones(f(p[1][2])));` | EQUAL / EQUAL | **type(1) / type(1)** | EQUAL / EQUAL |
| V/t28 `assign y = f(p[1][2]) + $countones(f(p[0][1]));` | type(1) / EQUAL | type(1) / **type(1)** | **EQUAL / EQUAL** |
| V/t31 `assign y = 4'($clog2(f(p[1][2])));` | type(1) (golden-only stamp at `#252`) / EQUAL | type(1), head moved EARLIER to `#113` (a stamp golden lacks in the definition listing) / **type(1)** | **EQUAL / EQUAL** |
| V/t14, t24, t26, t27, t30, t36 (judge-unequal on all binaries) | – | a stamp golden lacks, order-blind distance up (t14 45 -> 57, t24 52 -> 64, t26 34 -> 41, t27 35 -> 41) | the stamp withdrawn (byte list below) |

(cells: parse form / `-elabuhdm` form)

**Decode.** The formal's typespec lands on an actual only in UHDM `ExprEval::evalFunc`, reached from `reduceExpr`.
`ExprEval.cpp`'s `sys_func_call` branch reduces the ARGUMENTS of `$clog2`, `$signed` and `$unsigned` only (the `$bits`
family reads the argument's type, every other system call is left as it is), so a call below any other system call is
never evaluated and its actuals stay bare, however deep the system call sits (t25: a user call around it does not
help). The views where the law already leaves a call whose PARENT is an operation bare (the definition listing, the
`-elabuhdm` body) leave it bare below ANY operation above it (t31: the cast above the reducing `$clog2`). Controls
that golden stamps: `$signed` (t23, t33, t34), `$unsigned` (t29), `$clog2` (t32), a user call inside another (t34),
a concatenation, a unary and a binary operation in the parse form (t11, t12, t19, t20).

**Law § vsStampReducedCtxOnly198v** (`R11V198_VSSYS_OFF`; refines § callArgVarSelStamp198, `src/ExprEmit.cpp`
beside `varSelRangeIdx198`): the `var_select` stamp declines when, walking the parent chain up from the call through
operations, system calls and user or method calls, it meets a system call other than `$signed` / `$unsigned` /
`$clog2` (every view), or an operation in the definition listing or the `-elabuhdm` body.

**Measured.** The grid V after the refinement: 0 cases worse than pristine in either form; t13 t25 t28 t31 fixed (t28
and t31 now convert), 11 cases move between law and verified, all of them this refinement's shapes (t09 t13 t14 t24
t25 t26 t27 t28 t30 t31 t36), in both forms; `R11V198_VSSYS_OFF=1` writes the law binary's bytes on all 285 grid
cases (this pass's 115 and r11u198's 170) in both forms; r11u198's own V grid (31 cases) reads the same verdicts on
law and verified in both forms. The census ran `fix1.bin` with the trace: the refinement fires on NO corpus row-mode,
probe case or downstream lane, and the verified sweep equals the law sweep: `probe.csv`, `uhdm2rtlil.csv` and
`downstream.csv` identical, `surelog.csv` different only in the two LowMem detail texts, 0 probe database movers,
4 / 2560 corpus movers all the UVM coin (MiniAmiq d/t, SeqDriver t: 4 sorted-dump lines, `UINT` values;
SimpleUVM d: 0 lines) ([byteverify_verified_vs_law.txt](evidence/sweeps/byteverify_verified_vs_law.txt),
[orderblind_verified_vs_law.txt](evidence/sweeps/orderblind_verified_vs_law.txt)).

The pristine `bit_select` rule has the same fault under a non-reducing system call (t18
`4'($countones(f(p1[2])))`, t35: type(1) / judge-unequal on every binary). It is a pristine residue, left alone
(R3 below).

## 4. Switches

[evidence/switchcheck.txt](evidence/switchcheck.txt), `drivers/switchcheck.sh` (`fix1.bin` with `R11U198_TRACE` on
every grid case of both passes, both forms):

- Every case where no law fires writes the pristine bytes: 221 of 221 case-forms.
- Every case where exactly one r11u198 law fires writes the pristine bytes with that law's switch alone:
  - parse form: VSARG 39, CASTRHS 27, GSOWNER 33, HOPSEL 13, LVCALLARG 29, MARGOP 26, OVRBOUND 11
  - `-elabuhdm` form: 31, 0, 35, 14, 29, 26, 11
- 6 cases mix two laws (x17, y07, o41, t09, t28, t31).
- `R11U198_OFF=1` writes the pristine bytes on all 285 cases in both forms.
- `R11V198_VSSYS_OFF=1` writes the law binary's bytes on all 285 cases.

## 5. Gates of the verified binary (`fix1.bin`, `/tmp/v11u198_swF`)

| gate | result |
|---|---|
| (1) build | `489a0c07fab0b985e8f5c5123eff5d9f`, rebuilt from the verified patch on a fresh `7eb6f4b5` (section 7) |
| (2) probe | EQUAL 3343 / 744, `regressions=0 conversions=37 changes=2` (the law sweep's list) |
| (3) surelog / uhdm2rtlil | 0 / 0 / 0 and `regressions=0 conversions=2 changes=2` (ibex_pmp d/t convert, arb_idx_cast d/t change) |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; ibex_pmp and arb_idx_cast IDENTICAL; csv byte-identical to pristine's |
| (5) uhdm-cmp | every touched row and case keeps its judge status (the 16 corpus and 40 probe movers are CMP_EQUAL / STRICT_NOTEQUAL on both sides) |
| (6) byteverify | law vs pristine 16 / 2560, all predicted; verified vs law 4 / 2560, the UVM coin; SELFCHECK 2559 / 2560 both |
| canaries | surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, ctcan2 `EXPECT_UNKNOWN=1` and `=6` PASS |
| strict column | row by row against the pristine sweep, no row-mode moves but ibex_pmp d/t (converted) and arb_idx_cast d/t (`endcol(17) -> endcol(3)`, fewer objects on the same field) |

## 6. Ranked residues (this ground)

r11u198's own residues R1-R10 are re-measured unchanged. The ones this pass met again:

1. **R1 (N4)**: u08 and u10, lvalue-index call arguments on a member or class-member lvalue, now read
   `fullname(2)`, down from `col(6)`.
2. **§ methodArgOpRefChainName198's limits**: v01 (a bit select inside the operation, `c.f(a[i] + 1)`) and v13 (a
   user call inside the operation, `c.f(g2(i) + 1)`) keep `fullname` on every binary. v05 and v08 narrow to one or
   two records.

New, found here:

3. **The pristine bit_select stamp under a non-reducing system call** (t18, t35): the same decode as
   § vsStampReducedCtxOnly198v applies to the `bit_select` / `part_select` / `ref_obj` actuals of
   `refArg`. This is a pristine rule, not a break of this pass. Extending the refinement to it needs its own switch
   and a corpus census.
4. **A hop fold under a cast right-hand side** (x17: `3'(a[L])`): golden names the fold's `ref_typespec` `a`, the chain
   below the cast, in BOTH forms. § genCaCastRhsRefUnnamed198 leaves constants alone, so it reads
   `work@top.g[0].h.a` (§ genHopFoldSelName198) where pristine read `work@top.g[0]`. The count halves in the parse
   form (16 -> 8) and stays 4 in the `-elabuhdm` form. The fix is to give that `ref_typespec` the chain name below the
   cast, inside the cast law's collection.
5. **The `-elabuhdm` form of a call under a concatenation or unary operation** (t12, t20; t09 also stays there): golden
   stamps where no binary does. Unchanged on every binary.
6. x10 `-elabuhdm` (`3'(b + N)`) and x13 `fullname(2)` (a typedef cast of a concatenation) are unchanged by the law.
   x16 (a part-select target) reads `col(2)` on every binary once the law has run.

## 7. Files, and how to reproduce

- **`/tmp/r11u198.verified.patch`** = `git diff 7eb6f4b5` of this worktree. It contains:
  - r11u198's `src/ExprEmit.cpp` and `src/EmitHelpers.h`, plus the refinement in `src/ExprEmit.cpp`
  - `tools/probe/r11u198repro/`, unchanged
  - this directory
  - the regenerated `tests/LAWS.md`

  It applies clean on a fresh `7eb6f4b5` and rebuilds `489a0c07fab0b985e8f5c5123eff5d9f`.
- `cases/<grid>/<case>/dut.sv` (115 cases; the first line of each names its law): K (cast law), O (owner law), N
  (hop-fold z*, overridden-bound w*), M (method arguments), L (lvalue call arguments), V (var_select stamp; t13 t14
  t18 t22-t36 name § vsStampReducedCtxOnly198v).
- `drivers/`:
  - `env.sh`: the pins and `$FENCED`, fail closed.
  - `case.sh`, `judge.sh` (`LB=<binary>` picks the second binary, `ELAB=1`), `show.sh`, `obdist.sh`
  - `bytes.sh`, `switchcheck.sh`, `ds.sh`
  - copied from r11u198repro: `census.sh` + `censum.py`, `bvmirror.sh`, `det.sh` + `detob.sh`, `uvmdist.sh`,
    `obrow.sh`
- Reproduce:
  1. Build and freeze the three binaries in `/tmp/v11u198_bin`.
  2. Run `bash drivers/judge.sh cases/*/*` (and `ELAB=1`, and `LB=fix1`) and `bash drivers/switchcheck.sh`.
  3. Run the census: `SLANG_UHDM=<fix1> bash drivers/census.sh <wd> <trace dir> <prefix>`.
  4. Run `tests/sweep.sh --jobs 3 --workdir <wd>` once per binary.
  5. Compare the sweeps with `bvmirror.sh` + `tools/probe/r11v75repro/byteverify.sh`.
