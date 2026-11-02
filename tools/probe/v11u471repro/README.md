# v11u471 — adversarial verification of r11u471 (expression/parameter ground, pass 471)

Base 0f193bf8f. Implementer's patch /tmp/r11u471.patch (laws § enumSharedCloneHomeInst471, § pkgExportItemReImports471,
§ impTdParamCaFoldTs471, § procAsgRhsPkgFoldTs471, § pkgInitImpReadFolds471). Verdict: CONFIRMED WITH ONE BREAK FIXED.
The verified patch is /tmp/r11u471.verified.patch.

## Binaries (frozen, chmod 555)
- pristine `/tmp/v11u471_bin/pristine` md5 914aca3fab82ab18ffce129b445c3537. This is a copy of the implementer's frozen pristine, equal to the base build. The main tree's build/slang-uhdm already held pass 466's integration, so it was not used.
- law `/tmp/v11u471_bin/law` md5 97f7694e0c9cbcba6a032d55e47e3d68, rebuilt once from the patch. It equals the implementer's law13 and links slang 12.0.0+545f88b2e.
- verified `/tmp/v11u471_bin/verified` md5 7ebfbe924daef65018eb48de237d4139: the law plus one refinement in ParamEmit.

## The break and its fix: § exportDupKeepsDiamondPaths471v (ParamEmit, `fixOn(471, "R11V471_EXPDIAMOND_OFF")`)
The break was found on legal SV that upstream slang accepts. Pristine was closer to golden there, and the law moved away.
- **Shape.** `package c; import a::*; import b::*; export a::PZ;`, where b imports a (a diamond), and a module imports c.
- **Golden.** The module's param_assigns list c's per-path vector: PA PZ PA PZ PZ.
- **Pristine.** PA PZ PA PZ.
- **Law.** PA PZ PZ.
- **Why.** The explicit export pushed a second PZ into collectImportedParams' de-duplicated `acc`. Then `first451 != acc`, so § diamondImportParamAssignsPerPath451 abstained and the per-path repeats were lost.
- **Measured by the line-multiset overlap census** (drivers/v11u471_overlap.py: the sum over golden dump lines of min(golden count, ours count)):
  - v11u467 VU/vu16: 3537 on pristine, 3503 on the law.
  - vu07: 3581 -> 3330.
  - vu10: 2522 -> 2520.
- **uhdm-cmp did not show it.** Its head moved later because the package listings became golden's, so its count grew while the module listing moved away.
- **The fix.** The comparison skips the acc slots that an export item of an already-listed parameter filled. The full per-path walk, export items included, then stands, which is Surelog's getParamAssignVec().
- **Its cases** (VX/vx08, VX/vx10; first line `// § exportDupKeepsDiamondPaths471v`):
  - vx08 966 -> 940 (law) -> STRICT_EQUAL (verified).
  - vx10 478 -> 850 -> STRICT_EQUAL.
  - VX/vx05 842 (law) -> STRICT_EQUAL.
  - In the away census, v11u467 VU/vu16 966 -> 3000 -> STRICT_EQUAL, vu02, vu09 and vu15 reach STRICT_EQUAL, and vu07, vu10, vu14 and vu18 move closer. Every verified overlap is above pristine's.
- **Switches.**
  - `R11V471_EXPDIAMOND_OFF` or `R11V471_OFF` gives the law's bytes on 110 of 110 dirs: 45 of mine and the implementer's 65.
  - `R11U471_OFF` on the verified binary gives pristine's bytes on 110 of 110. The fix is reachable only through an export item, which only the law resolves.
  - lawTrace(471, "exportDupKeepsDiamondPaths471v", ...) logs each firing.
- **Prediction, written before the verified sweep** (evidence/prediction_verified.txt): it fires on no corpus row, probe case or sv-tests row. In the law sweep's trace the only export item resolved is the wildcard `export pkg_uniform::*` in probe r10v179 v179_f_nomod. The sweep held this (below).

## Reproduction of the implementer's numbers (law binary)
- **Grid:** 65 of 65 case dirs reproduced row for row on exit code, uhdm-cmp count and strict verdict (evidence/impl_grid_reproduced.txt). `R11U471_OFF` gives pristine bytes on 65 of 65.
- **One five-stage sweep on the law binary** (/tmp/v11u471_sw, trace on; drivers/v11u471_launch.sh):
  - probe EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0; the csv is identical to results/golden_probe.csv.
  - surelog default 480 + 0, testflags 474 + 0, 0/0/0.
  - uhdm2rtlil 803/1/67 in both modes, 0/0/0.
  - downstream IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2; the csv is identical to results/downstream_uhdm2rtlil.csv.
  - sv-tests EQUAL 1931, STRICT_NOTEQUAL 0, DIFFERENT 9, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=0 changes=0; the csv is identical to the base's results/golden_svtests.csv.
  - The sv-tests stage ran as the main tree's scripts/check_svtests.py with `--baseline` set to a copy of the base's golden_svtests.csv. The worktree's UVM folder is empty, and the main tree's scripts are identical to the base's.
  - All five csvs equal the implementer's law13 sweep, except surelog's two LowMem log-path texts.
  - The corpus command exited 1 only because the law index was stale: my new cases had not been indexed yet.
- **byteverify, law against the implementer's law13 sweep** (same binary): 0 of 962, 0 of 1608, 0 of 805, with the self-checks flagging 961, 1607 and 804.
  - The master's control /tmp/intr11u469 had been pruned before this verification, so the law-against-pristine byte check was replaced by the next item.
- **Pristine byte check of the rows the laws can reach** (drivers/v11u471_pbc.py; evidence/pristine_bytecheck_import_rows.txt): every fence-filtered corpus row whose sources contain `import` or `export` was rerun with pristine on its recorded command.
  - surelog default: 71 of 71 rows byte-identical to the law sweep's databases. One row, LowMemPkg, needed a rerun because its quoted -D argument had been split; it was then SAME.
  - uhdm2rtlil default: 77 of 77 byte-identical.
- **Trace:**
  - In the corpus stages it fires on exactly one database: probe r10v179 v179_f_nomod, with § pkgExportItemReImports471 resolving a wildcard export.
  - In sv-tests it fires on exactly the implementer's 15 rows: rsd with § procAsgRhsPkgFoldTs471 and § pkgInitImpReadFolds471, and 14 uvm-examples rows with § enumSharedCloneHomeInst471.
- **UVM role census** (evidence/uvm_role_census.txt): the import-copy role mismatches against golden fall to 0 on uvm_overriding (3 -> 0), uvm_test_init (56 -> 0), uvm_many_to_one (21 -> 0) and uvm_ac_config_db (3 -> 0). Every row stays STRICT_EQUAL to golden.
- **Canaries:** ok=52 / ok=16. ctcan2 PASS for surelog (EXPECT_UNKNOWN=1) and uhdm2rtlil (EXPECT_UNKNOWN=6).
- **Binary audit** (fence-filtered):
  - surelog 1523 of 1573 records name the law binary; the other 50 hold only a Surelog line.
  - uhdm2rtlil 1740 of 1740.
  - sv-tests 2346 of 2346.
- **Goal 1:**
  - All 75 SURELOG_ONLY rows carry an upstream slang `error:`, and none carries the exporter's unsupported message.
  - C::mk().arr[1] (v11u413 VC/vc04) and u.mk(x).a[2] (VI/vi06) exit 4 on pristine and on the law; this.mk().inner.s (v11u415 VT/vt03) exits 0. Upstream slang exits 0 on all three.

## Verified sweep (one five-stage sweep on the verified binary; /tmp/v11u471_vw; drivers/v11u471_launchv.sh)
- probe EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0.
- surelog 480 + 0 / 474 + 0, 0/0/0.
- uhdm2rtlil 803/1/67 in both modes, 0/0/0.
- downstream 803/66/2/0.
- sv-tests EQUAL 1931, STRICT_NOTEQUAL 0, DIFFERENT 9, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, regressions=0 conversions=0 changes=0.
- Every command exited 0, and the law index is current.
- All five csvs equal the law sweep's, except surelog's two LowMem log-path texts.
- byteverify, verified against law (evidence/byteverify_verified_vs_law.txt): surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805 (self-checks 961, 1607, 804); probe 0 of 4087 databases.
- The 30 kept sv-tests databases differ in raw bytes, and all 30 read STRICT_EQUAL under `uhdm-strictcmp --no-canon`. This is the serialization-order variance.
- The fix's trace fired 0 times, as predicted. The other firings are the same 16 databases as the law sweep.
- Canaries ok=52 / ok=16; both ctcan2 checks PASS.

## Attack grid (45 case dirs in VI, VP, VS, VT, VX)
Every case is accepted by upstream slang (`slang dut.sv --single-unit`, real exit code read), and every exit code is 0 on all three binaries.
Columns are uhdm-cmp lines and verdict for pristine, law and verified (evidence/attack_grid_pris_law.txt, grid_verified_switches.txt).

| case | law (first line) | pristine | law | verified |
|---|---|---|---|---|
| VI/vi01 | pkgInitImpReadFolds471 | 50 NOT_EQUAL | 17 NOT_EQUAL | 17 NOT_EQUAL |
| VI/vi02 | pkgInitImpReadFolds471 | 478 NOT_EQUAL | 50 NOT_EQUAL | 50 NOT_EQUAL |
| VI/vi03 | pkgInitImpReadFolds471 | 46 NOT_EQUAL | 46 NOT_EQUAL | 46 NOT_EQUAL |
| VI/vi04 | pkgInitImpReadFolds471 | 50 NOT_EQUAL | 17 NOT_EQUAL | 17 NOT_EQUAL |
| VI/vi05 | pkgInitImpReadFolds471 | 50 NOT_EQUAL | 64 NOT_EQUAL | 64 NOT_EQUAL |
| VI/vi06 | pkgInitImpReadFolds471 | 50 NOT_EQUAL | 64 NOT_EQUAL | 64 NOT_EQUAL |
| VI/vi07 | pkgInitImpReadFolds471 | 17 NOT_EQUAL | 17 NOT_EQUAL | 17 NOT_EQUAL |
| VI/vi08 | pkgInitImpReadFolds471 | 50 NOT_EQUAL | 64 NOT_EQUAL | 64 NOT_EQUAL |
| VP/vp01 | procAsgRhsPkgFoldTs471 | 17 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 192 |
| VP/vp02 | procAsgRhsPkgFoldTs471 | 68 NOT_EQUAL | 68 NOT_EQUAL | 68 NOT_EQUAL |
| VP/vp03 | procAsgRhsPkgFoldTs471 | 17 NOT_EQUAL | 17 NOT_EQUAL | 17 NOT_EQUAL |
| VP/vp04 | procAsgRhsPkgFoldTs471 | 17 NOT_EQUAL | 17 NOT_EQUAL | 17 NOT_EQUAL |
| VP/vp05 | procAsgRhsPkgFoldTs471 | 17 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 165 |
| VP/vp06 | procAsgRhsPkgFoldTs471 | 17 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 129 |
| VP/vp07 | procAsgRhsPkgFoldTs471 | 17 NOT_EQUAL | 17 NOT_EQUAL | 17 NOT_EQUAL |
| VP/vp08 | procAsgRhsPkgFoldTs471 | 17 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 215 |
| VP/vp09 | procAsgRhsPkgFoldTs471 | 17 NOT_EQUAL | 17 NOT_EQUAL | 17 NOT_EQUAL |
| VP/vp10 | procAsgRhsPkgFoldTs471 | 17 NOT_EQUAL | 17 NOT_EQUAL | 17 NOT_EQUAL |
| VP/vp11 | procAsgRhsPkgFoldTs471 | 17 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 202 |
| VS/vs01 | enumSharedCloneHomeInst471 | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL | 0 STRICT_EQUAL 375 |
| VS/vs02 | enumSharedCloneHomeInst471 | 570 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 467 |
| VS/vs03 | enumSharedCloneHomeInst471 | 390 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 414 |
| VS/vs04 | enumSharedCloneHomeInst471 | 358 NOT_EQUAL | 404 NOT_EQUAL | 404 NOT_EQUAL |
| VS/vs05 | enumSharedCloneHomeInst471 | 954 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 570 |
| VS/vs06 | enumSharedCloneHomeInst471 | 88 NOT_EQUAL | 88 NOT_EQUAL | 88 NOT_EQUAL |
| VT/vt01 | impTdParamCaFoldTs471 | 144 NOT_EQUAL | 144 NOT_EQUAL | 144 NOT_EQUAL |
| VT/vt02 | impTdParamCaFoldTs471 | 17 NOT_EQUAL | 17 NOT_EQUAL | 17 NOT_EQUAL |
| VT/vt03 | impTdParamCaFoldTs471 | 46 NOT_EQUAL | 64 NOT_EQUAL | 64 NOT_EQUAL |
| VT/vt04 | impTdParamCaFoldTs471 | 192 NOT_EQUAL | 192 NOT_EQUAL | 192 NOT_EQUAL |
| VT/vt05 | impTdParamCaFoldTs471 | 17 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 382 |
| VT/vt06 | impTdParamCaFoldTs471 | 112 NOT_EQUAL | 112 NOT_EQUAL | 112 NOT_EQUAL |
| VT/vt07 | impTdParamCaFoldTs471 | 17 NOT_EQUAL | 0 STRICT_NOTEQUAL | 0 STRICT_NOTEQUAL fullname |
| VT/vt08 | impTdParamCaFoldTs471 | 46 NOT_EQUAL | 64 NOT_EQUAL | 64 NOT_EQUAL |
| VT/vt09 | impTdParamCaFoldTs471 | 112 NOT_EQUAL | 112 NOT_EQUAL | 112 NOT_EQUAL |
| VT/vt10 | impTdParamCaFoldTs471 | 64 NOT_EQUAL | 64 NOT_EQUAL | 64 NOT_EQUAL |
| VX/vx01 | pkgExportItemReImports471 | 830 NOT_EQUAL | 0 STRICT_NOTEQUAL | 0 STRICT_NOTEQUAL line |
| VX/vx02 | pkgExportItemReImports471 | 490 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 165 |
| VX/vx03 | pkgExportItemReImports471 | 344 NOT_EQUAL | 344 NOT_EQUAL | 344 NOT_EQUAL |
| VX/vx04 | pkgExportItemReImports471 | 346 NOT_EQUAL | 936 NOT_EQUAL | 936 NOT_EQUAL |
| VX/vx05 | pkgExportItemReImports471 | 660 NOT_EQUAL | 842 NOT_EQUAL | 0 STRICT_EQUAL (204 objects) |
| VX/vx06 | pkgExportItemReImports471 | 1032 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 691 |
| VX/vx07 | pkgExportItemReImports471 | 506 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 165 |
| VX/vx08 | exportDupKeepsDiamondPaths471v | 966 NOT_EQUAL | 940 NOT_EQUAL | 0 STRICT_EQUAL (283 objects) |
| VX/vx09 | pkgExportItemReImports471 | 1200 NOT_EQUAL | 0 STRICT_EQUAL ( objects)| 0 STRICT_EQUAL 345 |
| VX/vx10 | exportDupKeepsDiamondPaths471v | 478 NOT_EQUAL | 850 NOT_EQUAL | 0 STRICT_EQUAL (242 objects) |

The verified binary reaches STRICT_EQUAL on 17 dirs: vp01, vp05, vp06, vp08, vp11, vs01 to vs03, vs05, vt05, vx02, vx05 to vx10. vs01 was already STRICT_EQUAL on pristine; on vs01 the import-copy role mismatches fall 5 -> 0.
- Two reach STRICT_NOTEQUAL:
  - vt07 on fullname: an interface reading a typedef-typed import. NOT_EQUAL on pristine.
  - vx01 on line: an export written before its import.
- Six are byte-identical controls: vi07, vp07, vs06, vt09, vt10 and vx03.
- **Every other mover keeps or later-moves its head.** The overlap census (drivers/v11u471_overlap.py) finds no dir where the verified binary's overlap is below pristine's, across both grids (110 dirs).
- **Heads that moved later:**
  - vi05, vi08: the elaborated package constant, INT in golden and UINT in ours, as on pristine.
  - vi06: a class parameter in the package.
  - vs04: the program listing.
  - vx04: package c after a chained export.
  - vt03, vt08: the net-declaration or generate-scope constant's value form and parent, the same 64-line face as the plain-vector control vt10.
  - vp03: `return PA`, not an assignment.
  - vp09: an interface `initial v = PA`.
  - vp10: a program instance listing.
- **Heads unchanged:**
  - vi03: a typedef range bound.
  - vp02, vt01: the package's signed -4'sd3 constant.
  - vp04: a package class method.
  - vt02: a select index.
  - vt04: a typedef from a third package.
  - vt06, vt09: module top's copy of the typedef parameter, at a port actual.
- **Switches** (evidence/switch_off_attack.txt, switch_each_attack.txt):
  - `R11U471_OFF` gives pristine bytes on all of them.
  - Each mover is restored by its own law's switch. The exceptions are vi02, vi03, vi06 and vx01, which combine two laws.
- **Downstream** (evidence/downstream_cases.txt; ds.one, both binaries): vp01, vp02 (a signed narrow parameter into a wider variable), vp05, vp06, vp08, vp11, vt01 (signed typedef), vt02, vt05, vt06, vt07, vt08, vs02, vi01, vx01 and vx06 read IDENTICAL on pristine and law. vi05 reads EQUIVALENT on both.

## Away census (drivers/v11u471_away.sh; evidence/away_census_*.txt)
The census covers 701 earlier case dirs of r11u/v11u 469, 467, 465, 463, 461, 458, 457, 453 and 451, plus r11u461's decode dirs. No exit code moves.
- **Pristine against law:** 30 movers, 671 dirs byte-identical.
- **Pristine against verified, every mover closer by the overlap census:**
  - **To STRICT_EQUAL:** v11u469 VE/ve01, ve03, ve04, ve08, ve10, VM/vm02, VT/vt06; v11u467 VU/vu02, vu03, vu05, vu09, vu15, vu16, vu21; r11u461 evidence RX/rx04; v11u451 VA/va04.
  - **To STRICT_NOTEQUAL:** VE/ve12.
  - **Head later:** ia04, ia10, vm01, vt08, vt14, vu07, vu10, vu14, vu18, vo06, vx06 and vx11.
    - On ia10, vo06 and vx06 the head moved from the package constant to the package object. The body of the dump is now golden's, and what remains is the tail typespec instances that pristine also lacks.
  - **va01:** same count at 199 lines, overlap 1669 -> 1682.
- **Law against verified:** 8 movers, v11u467 VU/vu02, vu07, vu09, vu10, vu14, vu15, vu16 and vu18. All are the fix's shape, and all are closer on the verified binary.

## Residues (ranked; all wrong on pristine too, none moved away on the verified binary)
1. **Module-level import copies** (the implementer's first residue): vt06 and vt09 (a port actual), ia04, ia10, vt14, vm01.
2. **Chained exports** `export b::*; export a::*;` through a middle package (VX/vx04, 936 lines, head at package c). An export line before its import (vx01, STRICT_NOTEQUAL line).
3. **Procedural folds not reached:**
   - a ternary operand (vp07);
   - `return PA` (vp03);
   - a package class method (vp04);
   - an interface process (vp09);
   - a program-instance listing (vp10, ModuleEmit).
4. **Signed constants:**
   - the package's -4'sd3 face (vp02, vt01);
   - the elaborated INT/UINT signing of a package localparam folded from an import (vi05, vi08, the implementer's vm01).
5. **Typedef-range bound** reading an imported parameter in a package (vi03).
6. **An anonymous enum parameter shared by importers** (vs06, ie05's face).
7. **The implementer's residues** (README of tools/probe/r11u471repro), unchanged.

## Sister-ground faces (reported, not written)
- ModuleEmit: the program-instance listing (vp10, the implementer's pf22) and the interface process fold context (vp09, pf05).

## Process
- **Budget.**
  - One law build and one verified build.
  - No pristine build: the pristine is a copy of the implementer's frozen pristine.
  - One five-stage sweep on each of the law and verified binaries.
  - Case runs and one targeted pristine byte check of the import-using corpus rows. That check stood in for the pruned control.
  - Every sweep launched with no sweep or runner live. The master's pass-466 integration sweep was waited out first.
- **Slips, none affecting a measurement:**
  - My first wait loop for the master's sweep used `pgrep -f` with a pattern its own command line matched, so it never returned. It and its two waiters were stopped by task id; nothing else was touched.
  - My first upstream-slang check passed `--nobuiltin`, which upstream rejects. The guard read the real exit code (1 on every case), and the check was rerun without the flag.
  - VI/vi02 was rewritten before any run, since `export a::*` exports only names b references.
  - The first downstream driver named the binary `pris` and stopped on its `[ -x ]` guard.
  - The pristine byte-check script split LowMemPkg's quoted -D argument, so that row was rerun by hand.
  - VX/vx08 and vx10 had their first line renamed to the fix law after their runs. It is a comment on the same line, so no location moves.
- **Fence.** The fence list was read into a file by a program and never printed. Every tree-wide list was filtered on it first. No fenced test was named, opened or run.
- No other agent's process was touched.
