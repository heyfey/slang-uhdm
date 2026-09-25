# r11u156map: the strict ground map, seventh edition (measurement only)

**Base.** Measured at `89d599ef` (branch matrix-1.87): after passes 145 (1fb349a9) and 146 (3e06cad2), r11u151's
decode (d10675dd) and r11u153's verification (89d599ef). The reference sweep is `/tmp/intr11u153`.

**Pass 147 landed while this map was measured** (`b6af876c`, r11u147 = pair A). Its integration sweep
`/tmp/intr11u147` is read-only here. Its csvs equal results/golden_*.csv at b6af876c on every row. This map
re-dumped and re-keyed that sweep with the same pipeline, so pair A reads **measured** everywhere below (section 3c),
and the next briefs (section 6) are computed on top of pass 147 as landed plus pair B (r11u152, still live).

Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited. This directory is the whole
patch, and it applies on `89d599ef` and on `b6af876c` alike.

Conventions:
- Law names are written `law <name>`, without the section sign, so `scripts/law_index.py` does not read this
  directory as a pass of laws. The landing still regenerates tests/LAWS.md; the passes table gains a row.
- The slang-fenced tests are written `FENCED_1` (drivers/redact.py). **No binary, gdb run or script touched a fenced
  test's sources or its databases in this pass.** `drivers/jobs.py` reads the fenced names from RESUME.md and
  skips the fenced rows, so no strict run read their sweep databases. `drivers/pinmulti.py` skips them too, and
  `final.py` lists them from the committed csv cell only. The fenced surelog row `FENCED_1` (d/t, `differ:file(2)`
  at 89d599ef) is in the fail list with no cluster; pass 147 converted it (its csv cell at b6af876c reads `equal`).
  The gate sweeps ran every row, as the gate mandates.

Binaries, frozen with `chmod 555` in `/tmp/r11u156_bin` before any measurement (evidence/verify.txt):

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `1b89f73ee8704d8bb4979a668115366c` | worktree `/tmp/wt_r11u156` at 89d599ef, system-deps config, `-j 2`. Byte-identical to the main tree's `build/slang-uhdm`, which the reference sweep ran (3273 of 3273 `slang:` lines). The brief's `c7b333fcf978` is an older binary, as maps 5 and 6 found |
| `slang-uhdm.law` | `9aadd8ecf6fc1bed78a6477aa95a96ae` | MEASUREMENT ONLY: 89d599ef + `tools/probe/r11u151struct/law_after_r11u145.patch` + `evidence/pairB_c3_scratch.patch` (clean `git apply`; worktree `/tmp/wt_r11u156law`) |
| `slang-uhdm.g1` | `bba0a5056cce42e6264e3c2c5d03b95d` | the same source with `-DCMAKE_CXX_FLAGS=-g1` (`/tmp/r11u156_g1build`); used by gdb only |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's; unchanged since 4f73d52f |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | drivers/strictcmp_x.cpp (maps 3-6's variant: `--dump-ids` and the mode-4 inputs), same md5 as map 6's |
| `objrank` | `3e213a154aab7f619443de5f11646f0a` | drivers/objrank.cpp |

## 0. Where we stand (89d599ef; the committed baselines are the fail list)

| corpus | mode | judge-equal | strict-equal | `STRICT_NOTEQUAL` |
|---|---|---|---|---|
| surelog | default | 480 | 406 | 74 |
| surelog | testflags | 474 | 405 | 69 |
| uhdm2rtlil | default | 803 | 714 | 89 |
| uhdm2rtlil | testflags | 803 | 714 | 89 |
| probe cases | | 4087 | 2390 | 1697 |

**The fail list is 321 row-modes (143 surelog + 178 uhdm2rtlil) in 164 tests, plus 1697 probe cases.** 319
row-modes were dispatched; the other 2 are FENCED_1 d/t.

First fields, tallied from the detail column of results/golden_*.csv (evidence/tallies.txt):
* surelog 143: fullname 39, endcol 30, line 26, file 15, endline 11, col 8, name 6, depth 4, value 4;
* uhdm2rtlil 178: fullname 84, file 30, line 22, endline 12, depth 10, col 10, name 6, endcol 4;
* probe 1697: fullname 740, endcol 282, line 224, file 118, depth 102, type 99, endline 48, col 43, name 33, value 5,
  decompile 3.

At b6af876c (pass 147) the same tallies read: surelog 139 (fullname 41, endcol 30, line 26, file 13, endline 11,
col 8, name 6, value 4), uhdm2rtlil 152 (fullname 76, line 24, file 20, endline 12, col 8, name 6, endcol 4,
depth 2), probe 1642.

Mode asymmetries: surelog rows NE in default only are BasicOh, InterfArrayBind, Rggen, Scoreboard, UnsizedParam and
YosysBigSimEllip; HierPathTypespec is NE in testflags only. Every uhdm2rtlil fail test is NE in both modes.

**Every uhdm2rtlil fail row-mode is downstream IDENTICAL**: 178 of 178 at 89d599ef, 152 of 152 at b6af876c.

**Since map 6.** Map 6 (98aa49db) counted 360 row-modes and 1779 probe cases. At 89d599ef the fail list is 321 and
1697: 39 row-modes left and none entered. Pass 145 took 6 (DefaultPatternInt, ibex_counter and
packed_struct_array_shift, each d/t). Pass 146 took 33, including BasicOh/testflags, the joint row r11u153
attributed to both landings.

**Clusters.** Map 6 had 1518 clusters, this map has 1460: 1016 carry a corpus row and 856 a probe case. 1457 keep
their map-6 id, because the key is map 6's key. 61 map-6 clusters are gone. **3 are new, N2390-N2392**:
* N2390 (YosysBigSimEllip, 3 row-modes): a `part_select` bound reference named through the path. Pinned at ExprEmit
  `emitExpr`, next to law psBoundBareRefByBase145, which unmasked it.
* N2391 (BuildUVMPkg d/t): a UVM method-call receiver name.
* N2392 (probe case r10earl54repro/v3_v54): a port reference endcol.

## 1. Method (map 6's pipeline, drivers/run.sh)

1. **Input.** The READ-ONLY 89d599ef reference sweep `/tmp/intr11u153`. Its status and strict columns equal
   results/golden_surelog.csv (1596 of 1596 rows), golden_uhdm2rtlil.csv (1742 of 1742) and golden_probe.csv
   (4087 of 4087). The jobs are every `STRICT_NOTEQUAL` row-mode of the committed baselines: 321, of which 319 are
   dispatched and 2 fenced. Each golden is the cache entry its cmds.txt names. Every probe case is a job too
   (4087); its golden is `scripts/check_probe.py`'s `cache_dir(rel)`, whose key hashes the case's files.
2. **Strict runs.** `strictcmp_x --max 50 --dump-a --dump-b golden ours` on every job.
   * All 319 corpus runs return rc=2.
   * Probe runs return rc=0 on 2390 cases and rc=2 on 1697. That NE set, and every `differ:<field>(<n>)` cell,
     equals results/golden_probe.csv (0 mismatches).
3. **Analysis.** `drivers/analyze.py` records EVERY differing object; it is unchanged since map 3. Its mode-4
   reimplementation agrees with the tool's stdout on 2016 of 2016 rows (0 CELL-MISMATCH), on 2002 of 2002 on the
   law binary's cross-section, and on 1933 of 1933 on pass 147's.
4. **Clusters.** The key is maps 4-6's (`facet|type|shape|under:<walk parent type>` + `@builtin` / `@in-typespec`).
   A key that persists keeps its map-6 id. A new key takes the next id from N2390; maps 3-6 used N0001-N2389.
5. **Sites.** `drivers/pinmulti.py` ran one gdb session per example row (the `-g1` exporter stops at the example
   object's `Serializer::Make<type>` rank; the main checkout's case directories are the cwd). It pinned 28
   clusters: the new ones, plus those whose example object changed since map 6, among those with >= 3 row-modes,
   first on a fail row, covered, or >= 40 probe cases (evidence/pinwant.txt).
   * 25 pinned: `db=SAME` on 22. `db=DIFF` on 3 (MiniAmiq/default, Scoreboard/default: the UVM order coin); those
     keep map 6's pin.
   * N0194, N0478 and N0488 have no partner record and keep map 6's site.

   Every other cluster keeps map 6's pin, marked `[r11u150map pin]` (or an older map's). `drivers/mksites7.py`
   merges the pins.
6. **Coverage by the live pairs**, from the brief's map-6 ids (drivers/final.py):
   * **Pair A, r11u147** (ExprEmit/EmitHelpers/StmtEmit/ParamEmit, base 1fb349a9). Named:
     * r11u151's law_after_r11u145.patch: D2 N2383 + N2384, ARR N0046, G N0724 + N1129, D N0045 + N0758;
       MEASURED;
     * N0077, N0455 / N0456 (gone: pass 146 took them), N0286, N1053, N1063, N1118, N0820, N0471 / N0702,
       N0006 / N0765, N0833 / N1067, N0394 / N1140, N0739.

     Routed residues (evidence/residue_routes.json, from the residue cases run through casekeys.sh,
     evidence/residue_cases.txt):
     * pass-145 R5 (N0475, N1983), R7 (N1276, and N0133 / N0284 with pair B), R9 (N0427), R10 (N0129, N0536);
     * r11v145 V2 (N0446), V4 (N2268, N0453), V6 + pass-144 S4 (N0010);
     * pass-144 S3 (N0740, N0130).

     S3's two ParamEmit sites are in the law patch.
   * **Pair B, r11u152** (TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main, base d10675dd). Named:
     * r11u151's C3 module half: N0417 + N0534, via evidence/pairB_c3_scratch.patch; MEASURED;
     * N0008, N0470 / N0472, N0433 / N0436 / N0494, N0163 / N0655, N0274 / N1014 (N0274 gone: pass 146),
       N0004 / N0265, N0103, N0011, N0078, N0454, N0528, N0531, N0646, N0688, N0830, N0962, N0019;
     * the ibex macro-line set N0017 N0026 N0027 N0029;
     * the rp32 set N0092 N0140 N0143 N0149;
     * UVM/Earlgrey, read as the set map 6 gave r11u146 (N0064 N0015 N0067 N0068 N0069 N0071 N0072 N0051 N0093;
       N0070 is gone).

     Routed:
     * pass-146 R1 (N0139), R3 (N0762, N0135), R4 (N0084, N0108), R5 (N0075, N0266, N0409);
     * pass-145 sister R1 (GenCase N0482 N0483 N0486), R2 (PreprocTest N0056);
     * the verifiers' faces: v11u146 R2 (N2320), R6 (N0751); r11u153 N2 (N0133 / N0284 with pair A).
   * **A residue that names one shape of a multi-test cluster does not cover the cluster.** It reads `OPEN (one
     shape named by ...)` and counts as open in every yield (evidence/shape_routes.json):
     * N0001 (48 row-modes; r11v145 V4 x23 + pass-146 R2);
     * N0007 (V4 x23);
     * N0005 (pass-144 S4/S5 + pass-145 R4 -> A; pass-145 R6 -> B);
     * N0009 (pass-144 S3 -> A; v11u146 R1 + pass-146 R3 -> B);
     * N0083 (pass-144 S3 -> A; v11u146 R6 / r11u153 B1 -> B);
     * N0263 (v11u146 R6 / r11u153 B1);
     * N0275 (v11u146 R4, escaped-line based literal);
     * N0224 (r11u153 N6, escaped struct member).

     Map 6 counted such clusters whole. Section 7 shows what that cost.
   * **Not routed to either pair** (named in no live brief), OPEN:
     * pass-146's sister faces S1 (select-bound names: N0030's remainder, N0446's corpus rows are V2's, N0453,
       N0273, N0357) and S4;
     * pass 147's sister faces S1-S7 (section 6's ground-B list names them);
     * the map-6-covered clusters passes 145 / 146 left, e.g. N0018, N0036, N0063, N0097-N0102 (pass 145's) and
       N0014, N0025, N0028, N0031, N0033, N0039, N0042-N0044 (pass 146's).
7. **Yields.**
   * The law binary's full sweep is re-dumped and re-keyed, so it is MEASURED.
   * Pair A's and pair B's other covered clusters are then applied optimistically to that cross-section (a covered
     cluster fixed whole).
   * Pass 147's integration sweep is re-dumped and re-keyed the same way (section 3c). On top of it only pair B is
     applied.

## 2. Positive controls and gates

| control | result |
|---|---|
| surelog/default/1364_2005 | `STRICT_EQUAL 159 objects`, record dumps identical (159 / 159) |
| surelog/default/HierPathInterfBlock | `STRICT_EQUAL 226 objects`, dumps identical (226 / 226) |
| uhdm2rtlil/default/1DUnpackedArray | `STRICT_EQUAL 194 objects`, dumps identical (194 / 194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, lhsPath `design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`; baseline `CMP_NOTEQUAL,decompile:` both modes |
| analyzer rule vs tool stdout | 2016 / 2016 (89d599ef), 2002 / 2002 (law binary), 1933 / 1933 (pass 147) |
| probe NE set and cells vs golden_probe.csv | identical, 0 mismatches |
| pin validity | 22 / 25 gdb runs wrote the reference database byte for byte; the 3 others (UVM coin) keep map 6's pin |

Gates. This map lands no binary. The frozen pristine binary ran the full `tests/sweep.sh --jobs 3 --workdir
/tmp/r11u156swP` from the worktree with every pin exported (evidence/sweeps/sweep_pristine.txt). All 3273 `slang:`
lines name `/tmp/r11u156_bin/slang-uhdm`.

| gate | result |
|---|---|
| (1) build | pristine 1b89f73e = the main tree's 89d599ef build; law 9aadd8ec; g1 bba0a505 |
| (2) probe vs golden_probe.csv | EQUAL 2390 / STRICT_NOTEQUAL 1697; `regressions=0 conversions=0 changes=0` |
| (3) surelog + uhdm2rtlil vs golden_*.csv | `regressions=0 conversions=0 changes=0` in both. The scoreboards are 480/3 + 474/3 and 803/1/67 |
| (4) downstream | EQUIVALENT 2, IDENTICAL 803, SLANG_REJECT 66; not identical and not excused 0. Joined to results/downstream_uhdm2rtlil.csv, 0 of 871 rows differ on any column. No row is targeted: this map lands no law |
| (5) uhdm-cmp | no row touched |
| (6) byteverify | Pristine vs the reference sweep (same-length workdirs; SELFCHECK 959/960 and 1607/1608 flagged): surelog 3 movers, MiniAmiq d/t and SeqDriver d, the UVM order coin. The order-blind uhdm-dump diff is 4 lines each, `UINT`/`vpiDecompile` only (evidence/sweeps/uvm_coin_orderblind.txt). uhdm2rtlil 0 movers |
| canaries | canaries.sh: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. ctcan2 `EXPECT_UNKNOWN=1` surelog PASS (ok=58); `EXPECT_UNKNOWN=6` uhdm2rtlil PASS (ok=2) |

The sweep's rc is 1 only because the law index reads `STALE`. The main tree at 89d599ef reads STALE too
(`scripts/law_index.py --check`, rc 1), so the cause is not this directory.

## 3. The live pairs: yield, and the fail list after them

### 3a. The r11u151 law binary, MEASURED (evidence/sweeps/sweep_law.txt, evidence/report.txt section 1)

89d599ef + law_after_r11u145.patch + pairB_c3_scratch.patch, full sweep `/tmp/r11u156swM` (probe + both corpora;
all 3273 `slang:` lines name the law binary). Every stage reads `regressions=0`.

* **Conversions: 14 row-modes.**
  * surelog: BlackParrotComplex d/t.
  * uhdm2rtlil: array_assign, def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot,
    StructArrayParameterInitializedByPatternPassedAsPort and NestedStructArrayParameterInitializedByPatternPassedAsPort,
    all d/t.
* **Probe: no conversions, 32 changes.** The 30 `r11u109repro/grid/f1` cases (D + DCAST unmaskings), and
  `r11u10repro/grid/h9_1e1m_port` and `hD_1e1mvec` (fullname 7 -> 5).
* **Corpus changes:** FuncStructVal d/t, FuncStructValSimple d/t, StructParamFieldRange d/t,
  StructParamFuncBodyFieldCompare d/t (depth -> fullname(15)), StructParamPatternInitCast d/t, and
  cva6_struct_param_field d/t.

This is exactly r11u151's claim (its 12 + the C3 scratch's 4, minus DefaultPatternInt, which pass 145 took).

The byte movers against the pristine sweep (evidence/sweeps/byteverify_law_vs_pristine.txt) are:
* surelog 17 / 960: the 12 changed or converted row-modes above, plus the UVM coin (MiniAmiq d/t, SeqDriver d/t,
  Scoreboard d);
* uhdm2rtlil 14 / 1608: the 12 conversions and cva6_struct_param_field d/t.

Every mover is on r11u151's census firing list.

Calibration: the law clusters predicted 12 of the 14 conversions. The 2 NestedStructArray... rows carry N0003 as
well, which the law's `nestedPatOpTsNoParent151` removes.

### 3b. Both pairs as briefed (law measured, the rest optimistic; evidence/report.txt section 2)

| | row-modes cleared | tests cleared (every NE mode) | probe cases cleared |
|---|---|---|---|
| the law binary, MEASURED | 14 | 7 | 0 |
| pair A r11u147, named + routed, optimistic (31 clusters) | 15 | 7 | 114 |
| pair B r11u152, named + routed, optimistic (56 clusters) | 34 | 17 | 153 |
| **both** | **64** | **32** | **229** |

Predicted fail list after both pairs: **255 row-modes / 131 tests** (257 with FENCED_1 d/t), and **1468 probe
cases**. The per corpus/mode split is table T5.

### 3c. Pass 147 LANDED (b6af876c), MEASURED from its integration sweep (evidence/report147.txt, evidence/audit147.txt)

**Pass 147 converted 30 row-modes (28 dispatched here + FENCED_1 d/t) and 55 probe cases.**
* The law's 10 non-C3 conversions: BlackParrotComplex, array_assign, def_ctx_struct_param, latch_decoder_partial,
  latch_tlb_napot.
* 18 more: ParameterPassedTo3TimesNestedSubmodule, ParameterPassedToSubmoduleInGenscopeOfSubmodule,
  ParameterPassedToSubmoduleOfSubmodule, SubmoduleInGenScopeWithGenScopeParametrizedByParameterFromTopModule,
  SelectFromUnpackedInFunction, latch_packed_dyn_write, mem_packed_2d_byte_write, multiplier and
  unpacked_elem_partsel_comb, all d/t.
* The C3 rows remain: StructArray... d/t `line(2)`, and NestedStructArray... d/t moved from `fullname(4)` to
  `line(2)`. The pair-B C3 scratch clears both (3a).
* Structural first fields at b6af876c: only comb_dyn_2d_packed_sel d/t (`depth(1)`, N0286).

**The fail list after pass 147 (measured) is 291 row-modes / 149 tests and 1642 probe cases. After pair B on top
(the C3 scratch + named/routed, optimistic) it is 251 row-modes / 129 tests and 1485 probe cases.** Pair B's share
is 40 row-modes: 4 C3 + 36 others.

### T5. Fail-list size

| corpus | mode | 89d599ef (incl. fenced) | after the r11u151 law binary (measured, excl. fenced) | after both pairs as briefed (law measured + named optimistic) | after pass 147 (measured) | after pass 147 + pair B (optimistic) |
|---|---|---|---|---|---|---|
| surelog | default | 74 | 72 | 61 | 72 | 65 |
| surelog | testflags | 69 | 67 | 56 | 67 | 60 |
| uhdm2rtlil | default | 89 | 83 | 69 | 76 | 63 |
| uhdm2rtlil | testflags | 89 | 83 | 69 | 76 | 63 |
| **all** | | **321** | 305 | 255 | 291 | **251** |

## 4. Ranked OPEN clusters with sites (on top of pass 147 measured + pair B optimistic)

Columns:
* `rows left` counts the row-modes the cluster still carries after pass 147 + pair B; the number in parentheses is
  its rows at 89d599ef.
* `heads` counts the rows it is FIRST on.
* `alone` counts the rows it clears alone on top of pass 147 + pair B.
* `probe` counts the probe cases it carries after pass 147.
* `ground`: A = ExprEmit/EmitHelpers/StmtEmit/ParamEmit, B = the rest (by the pinned mint's file, overridden where
  a pass decoded the fix site elsewhere: evidence/ground_override.json).

The whole list is cluster_index_p147.csv (`rows_after_pairs`, `alone_on_top_of_pairs`, `first_in_after_pairs`);
the 89d599ef version is cluster_index.csv.

### T1. Ranked OPEN clusters on top of pass 147 (measured) + pair B r11u152 (optimistic): top 60 of 940

| # | cluster | rows left (89d599ef) | sl/u2r at 89d599ef | tests | heads | alone | probe (after 147) | ground | status | key | site (mint < caller < caller) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0001 | 48 (48) | 32/16 | 25 | 10 | 2 | 39 | A | OPEN (one shape named by r11u147+r11u152: r11v145 V4 psb/x23 (struct-p | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSub... |
| 2 | N0007 | 32 (32) | 24/8 | 17 | 0 | 2 | 28 | A | OPEN (one shape named by r11u147: r11v145 V4 psb/x23) | `fullname\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubro... |
| 3 | N0018 | 25 (25) | 21/4 | 13 | 0 | 0 | 18 | A | OPEN (residue of pass 145 (r11u145): map 6 named it, still present) | `fullname\|ref_obj\|ours-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law recvNa... |
| 4 | N0009 | 18 (18) | 10/8 | 9 | 8 | 8 | 16 | B | OPEN (one shape named by r11u147+r11u152: pass-144 S3 (packed_array_st | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit... |
| 5 | N0025 | 17 (17) | 5/12 | 9 | 0 | 0 | 11 | B | OPEN (residue of pass 146 (r11u146): map 6 named it, still present) | `depth\|constant\|range->operation` | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarR... |
| 6 | N0033 | 17 (17) | 5/12 | 9 | 0 | 0 | 11 | B | OPEN (residue of pass 146 (r11u146): map 6 named it, still present) | `struct\|ours-only:fewer-copies\|operation\|under:range` | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) < makeTypespec (TypeEmit.cpp, law typ... |
| 7 | N0005 | 16 (24) | 10/14 | 12 | 8 | 8 | 138 | A | OPEN (one shape named by r11u147+r11u152: pass-144 S4/S5 + pass-145 R4 | `span\|constant\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsP... |
| 8 | N0043 | 16 (16) | 10/6 | 9 | 4 | 2 | 5 | B | OPEN (residue of pass 146 (r11u146): map 6 named it, still present) | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit... |
| 9 | N0031 | 15 (15) | 9/6 | 8 | 0 | 0 | 13 | B | OPEN (residue of pass 146 (r11u146): map 6 named it, still present) | `file\|constant\|ours-empty\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) <... |
| 10 | N0054 | 15 (15) | 15/0 | 8 | 4 | 0 | 0 | A | OPEN | `span\|assignment\|endcol\|under:begin` | emitStmt (StmtEmit.cpp, law declInitWrittenNewNoStmt66) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitClas... |
| 11 | N0063 | 14 (14) | 2/12 | 7 | 4 | 8 | 2 | A | OPEN (residue of pass 145 (r11u145): map 6 named it, still present) | `fullname\|ref_typespec\|ours-empty\|under:operation` | emitExpr (ExprEmit.cpp, law caTernaryArmPatternFlatten99) < emitExpr (ExprEmit.cpp, law patCaGenIdxValueRender112) < emitExpr (ExprEmit.cpp, law conca... |
| 12 | N0014 | 14 (14) | 8/6 | 7 | 2 | 0 | 18 | B | OPEN (residue of pass 146 (r11u146): map 6 named it, still present) | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs107) < makeTypespec (TypeEmit.c... |
| 13 | N0036 | 14 (18) | 14/4 | 10 | 0 | 0 | 6 | A | OPEN (residue of pass 145 (r11u145): map 6 named it, still present) | `span\|bit_select\|col+endcol\|under:operation` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitMixedHierPath (ExprEmit.cpp, law hpM... |
| 14 | N0042 | 13 (13) | 9/4 | 7 | 0 | 0 | 10 | B | OPEN (residue of pass 146 (r11u146): map 6 named it, still present) | `span\|constant\|ours-zero\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) <... |
| 15 | N0012 | 13 (21) | 9/12 | 11 | 4 | 0 | 5 | A | OPEN | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInstance (ModuleEmit.cpp, law... |
| 16 | N0034 | 13 (13) | 9/4 | 7 | 0 | 0 | 5 | A | OPEN | `span\|enum_typespec\|ours-zero\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInstance (ModuleEmit.cpp, law... |
| 17 | N0055 | 13 (13) | 11/2 | 7 | 0 | 0 | 1 | A | OPEN (map 6 routed it to pass 146 (r11u146) as a residue; still presen | `span\|ref_obj\|line+endline\|under:operation` | emitBadConcatOperand160 (ExprEmit.cpp, law badConcatCompoundOperands162) < emitBadConcatFromSyntax160 (ExprEmit.cpp, law classArgBind12) < emitExpr (E... |
| 18 | N0080 | 13 (13) | 13/0 | 7 | 2 | 0 | 1 | B | OPEN | `span\|struct_typespec\|line+col+endline+endcol\|under:package` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.c... |
| 19 | N0050 | 13 (13) | 13/0 | 7 | 0 | 0 | 0 | A | OPEN | `span\|operation\|col+endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law connIpsPkgParamBoundNoTs65) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubr... |
| 20 | N0003 | 12 (14) | 8/6 | 7 | 8 | 2 | 36 | A | OPEN (map 6 routed it to pass 145 (r11u145) as a residue; still presen | `fullname\|ref_typespec\|golden-empty\|under:operation` | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmEx... |
| 21 | N0039 | 12 (12) | 12/0 | 7 | 0 | 0 | 219 | B | OPEN (residue of pass 146 (r11u146): map 6 named it, still present) | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) < emitClassDefn (UhdmExpor... |
| 22 | N0083 | 12 (12) | 2/10 | 6 | 0 | 0 | 41 | B | OPEN (one shape named by r11u147+r11u152: pass-144 S3 (packed_array_st | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi... |
| 23 | N0086 | 12 (12) | 4/8 | 6 | 2 | 0 | 20 | A | OPEN | `file\|constant\|golden-empty\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitPackage ... |
| 24 | N0087 | 12 (12) | 4/8 | 6 | 0 | 0 | 20 | A | OPEN | `span\|constant\|golden-zero\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitPackage ... |
| 25 | N0061 | 12 (12) | 12/0 | 7 | 0 | 0 | 8 | A | OPEN (map 6 routed it to pass 145 (r11u145) as a residue; still presen | `span\|bit_select\|col+endcol\|under:hier_path` | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectErased4) < emitExpr (ExprEmit.cpp, law dynAr... |
| 26 | N0060 | 12 (12) | 8/4 | 7 | 0 | 0 | 1 | A | OPEN | `span\|operation\|col+endcol\|under:operation` | emitExpr (ExprEmit.cpp, law insideOpenRangeMemberIsOneListOp30) < operator() (ExprEmit.cpp, law pkgTdCloneRefNoBind18) < emitExpr (ExprEmit.cpp, law p... |
| 27 | N0091 | 12 (12) | 10/2 | 6 | 0 | 0 | 0 | A | OPEN (residue of pass 145 (r11u145): map 6 named it, still present) | `span\|ref_obj\|col+endcol\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBa... |
| 28 | N0142 | 12 (12) | 12/0 | 7 | 0 | 0 | 0 | A | OPEN | `struct\|golden-only:fewer-copies\|range\|under:array_typespec` | makeUnpackedArrayParamTs (ParamEmit.cpp, law pkgParamTsRef) < emitParameters (ParamEmit.cpp, law importElemBareTdAlias) < exportDesign (UhdmExporter.c... |
| 29 | N0097 | 11 (11) | 11/0 | 6 | 0 | 2 | 17 | A | OPEN (residue of pass 145 (r11u145): map 6 named it, still present) | `span\|hier_path\|endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSub... |
| 30 | N0094 | 11 (11) | 11/0 | 6 | 0 | 0 | 58 | B | OPEN | `span\|constant\|line+col+endline+endcol\|under:range` | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBoundElabSize113) < emitInterfaceInstance (ModuleE... |
| 31 | N0040 | 11 (11) | 9/2 | 6 | 2 | 0 | 34 | B | OPEN | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef... |
| 32 | N0095 | 11 (11) | 11/0 | 6 | 0 | 0 | 25 | A | OPEN | `fullname\|ref_obj\|tok:id.id::->\|under:method_func_call` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) < emitExpr (ExprEmit.cpp, law hpNameBareIdxF... |
| 33 | N0098 | 11 (11) | 11/0 | 6 | 0 | 0 | 13 | A | OPEN (residue of pass 145 (r11u145): map 6 named it, still present) | `file\|ref_obj\|ours-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubro... |
| 34 | N0099 | 11 (11) | 11/0 | 6 | 0 | 0 | 12 | A | OPEN (residue of pass 145 (r11u145): map 6 named it, still present) | `span\|ref_obj\|ours-zero\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubro... |
| 35 | N0100 | 11 (11) | 11/0 | 6 | 0 | 0 | 11 | B | OPEN | `span\|bit_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) < main (uhdm_main.cpp, law genCaPa... |
| 36 | N0101 | 11 (11) | 11/0 | 6 | 0 | 0 | 7 | A | OPEN (residue of pass 145 (r11u145): map 6 named it, still present) | `file\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law recvNa... |
| 37 | N0102 | 11 (11) | 11/0 | 6 | 0 | 0 | 7 | A | OPEN (residue of pass 145 (r11u145): map 6 named it, still present) | `span\|ref_obj\|golden-zero\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law recvNa... |
| 38 | N0104 | 11 (11) | 11/0 | 6 | 0 | 0 | 7 | B | OPEN | `span\|bit_var\|line+col+endline+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageCl... |
| 39 | N0105 | 11 (11) | 11/0 | 6 | 0 | 0 | 7 | B | OPEN | `span\|string_var\|line+col+endline+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageCl... |
| 40 | N0106 | 11 (11) | 11/0 | 6 | 0 | 0 | 7 | B | OPEN | `file\|class_var\|golden-empty\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law methodSpanSkipsAttrs144) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageClasse... |

Probe-only OPEN clusters with the most cases: N1897 (119, B), N1898 (92, B), N1899 (52, B), N1900 (50, B),
N1901 (45, B), N1902 (37, A), N1903 (21, A), N1904 (20, A). Laws with the most NE cases:
* badConcatOperandsFromSyntax160 71/71;
* loopCaParamReadKeepsLiteral116 59/123;
* tpElemRebindElabPort110 57/61;
* nestedGenProcLhsKeepsRef116 46/74;
* portViewRangeRecvParams 45/55;
* tpPackedArrayTsVar108 43/73;
* pvExprDefaultFold115 43/50.

### T4. First clusters of the rows left after pass 147 + pair B (row-modes each heads)

| first cluster | row-modes it heads | ground | status | key | site |
|---|---|---|---|---|---|
| N0064 | 14 | B | COVERED r11u152 (N0064) | `span\|include_file_info\|line+endline\|under:design` | emitIncludeFileInfos (UhdmExporter.cpp, law includeInactiveTabNotText141v) < exportDesign (UhdmExporter.cpp, law dottedT... |
| N0008 | 12 | B | COVERED r11u152 (N0008) | `fullname\|ref_typespec\|golden-empty\|under:constant` | operator() (ModuleEmit.cpp, law genLpFoldDigitsMathValue18) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48... |
| N0001 | 10 | A | OPEN (one shape named by r11u147+r11u152: r11v145  | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (... |
| N0005 | 8 | A | OPEN (one shape named by r11u147+r11u152: pass-144 | `span\|constant\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.c... |
| N0003 | 8 | A | OPEN (map 6 routed it to pass 145 (r11u145) as a r | `fullname\|ref_typespec\|golden-empty\|under:operation` | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPer... |
| N0009 | 8 | B | OPEN (one shape named by r11u147+r11u152: pass-144 | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword13... |
| N0139 | 8 | B | COVERED r11u152 (residue: pass-146 R1: member name | `fullname\|ref_typespec\|tok:id::id::id::->id@id.id.id::id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsN... |
| N0149 | 8 | B | COVERED r11u152 (N0149) | `file\|struct_typespec\|other-file\|under:package` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law a7) < exportDesign (UhdmEx... |
| N0084 | 6 | B | COVERED r11u152 (residue: pass-146 R4: the type-pa | `fullname\|ref_typespec\|tok:id@id.id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs1... |
| N0090 | 6 | B | OPEN | `span\|logic_typespec\|endline+endcol\|under:ref_typespec` | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEmit.cpp, law typePara... |
| N0627 | 4 | B | OPEN | `fullname\|property_decl\|tok:id.id.id->id\|under:module_inst` | emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < exportDesign (UhdmExporter.cpp, law importedClassTsRideThe... |
| N0051 | 4 | B | COVERED r11u152 (N0051) | `span\|class_typespec\|endcol\|under:ref_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter.cpp, law ... |
| N0054 | 4 | A | OPEN | `span\|assignment\|endcol\|under:begin` | emitStmt (StmtEmit.cpp, law declInitWrittenNewNoStmt66) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLo... |
| N0655 | 4 | B | COVERED r11u152 (N0655) | `name\|enum_typespec\|tok:id->id\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, la... |
| N0536 | 4 | A | OPEN (residue of pass 147: COVERED r11u147 (residu | `fullname\|ref_typespec\|tok:id.id->id\|under:constant` | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) < em... |
| N0012 | 4 | A | OPEN | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emi... |
| N0043 | 4 | B | OPEN (residue of pass 146 (r11u146): map 6 named i | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword13... |
| N0044 | 4 | B | OPEN (residue of pass 146 (r11u146): map 6 named i | `span\|struct_typespec\|endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword13... |
| N0063 | 4 | A | OPEN (residue of pass 145 (r11u145): map 6 named i | `fullname\|ref_typespec\|ours-empty\|under:operation` | emitExpr (ExprEmit.cpp, law caTernaryArmPatternFlatten99) < emitExpr (ExprEmit.cpp, law patCaGenIdxValueRender112) < emi... |
| N0047 | 4 | B | OPEN | `fullname\|parameter\|tok:id->id.id.id\|under:param_assign` | emitParameters (ParamEmit.cpp, law unsizedBasedParamRhsSize106) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfaceT... |
| N0407 | 4 | A | OPEN | `span\|constant\|line+col+endline+endcol\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAs... |
| N0163 | 3 | B | COVERED r11u152 (N0163) | `fullname\|ref_typespec\|tok:id->id\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law c... |
| N0103 | 2 | B | COVERED r11u152 (N0103) | `name\|class_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) <... |
| N0923 | 2 | A | OPEN | `fullname\|ref_obj\|golden-empty@in-typespec\|under:int_typespec` | stampParenCastWidthTs (ParamEmit.cpp, law parenCastWidthRefModuleCopy) < emitParameters (ParamEmit.cpp, law pkgParamTsRe... |
| N0722 | 2 | A | OPEN | `span\|parameter\|line+endline\|under:module_inst` | emitParameters (ParamEmit.cpp, law unsizedBasedParamRhsSize106) < exportDesign (UhdmExporter.cpp, law importedClassTsRid... |
| N0080 | 2 | B | OPEN | `span\|struct_typespec\|line+col+endline+endcol\|under:package` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) ... |
| N0739 | 2 | A | OPEN (residue of pass 147: COVERED r11u147 (N0739) | `struct\|ours-only:fewer-copies\|ref_obj\|under:cont_assign` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) <... |
| N0117 | 2 | B | OPEN | `span\|unsupported_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymboli... |
| N0851 | 2 | B | OPEN | `span\|enum_typespec\|endline+endcol\|under:package` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, la... |
| N0011 | 2 | B | COVERED r11u152 (N0011) | `file\|logic_net\|golden-empty\|under:ref_obj` | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cpp, law hoi... |

### The covered clusters

### T2. Pair B r11u152: its covered clusters (named, routed, C3 measured), rows at 89d599ef -> after pass 147

| cluster | rows 89d599ef (sl/u2r) | after pass 147 | probe 89d599ef -> after 147 | coverage | key |
|---|---|---|---|---|---|
| N0008 | 27 (5/22) | 27 | 23 -> 23 | COVERED r11u152 (N0008) | `fullname\|ref_typespec\|golden-empty\|under:constant` |
| N0015 | 27 (7/20) | 27 | 1 -> 1 | COVERED r11u152 (N0015) | `span\|constant\|line+col+endline+endcol\|under:sys_func_call` |
| N0017 | 26 (6/20) | 26 | 5 -> 5 | COVERED r11u152 (N0017) | `span\|constant\|endline+endcol\|under:sys_func_call` |
| N0026 | 20 (0/20) | 20 | 10 -> 10 | COVERED r11u152 (N0026) | `span\|constant\|line+endline\|under:sys_func_call` |
| N0027 | 20 (0/20) | 20 | 8 -> 8 | COVERED r11u152 (N0027) | `span\|sys_func_call\|line+endcol\|under:begin` |
| N0029 | 20 (0/20) | 20 | 0 -> 0 | COVERED r11u152 (N0029) | `span\|sys_func_call\|line+endline\|under:sys_func_call` |
| N0051 | 15 (15/0) | 15 | 9 -> 9 | COVERED r11u152 (N0051) | `span\|class_typespec\|endcol\|under:ref_typespec` |
| N0064 | 14 (14/0) | 14 | 0 -> 0 | COVERED r11u152 (N0064) | `span\|include_file_info\|line+endline\|under:design` |
| N0067 | 13 (13/0) | 13 | 47 -> 47 | COVERED r11u152 (N0067) | `file\|class_typespec\|ours-empty\|under:ref_typespec` |
| N0068 | 13 (13/0) | 13 | 47 -> 47 | COVERED r11u152 (N0068) | `span\|class_typespec\|ours-zero\|under:ref_typespec` |
| N0069 | 13 (13/0) | 13 | 25 -> 25 | COVERED r11u152 (N0069) | `span\|string_typespec\|line+col+endline+endcol\|under:ref_typespec` |
| N0071 | 13 (13/0) | 13 | 16 -> 16 | COVERED r11u152 (N0071) | `span\|hier_path\|endcol\|under:operation` |
| N0072 | 13 (13/0) | 13 | 16 -> 16 | COVERED r11u152 (N0072) | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` |
| N0092 | 12 (2/10) | 12 | 0 -> 0 | COVERED r11u152 (N0092) | `value\|constant\|value:UINT->UINT\|under:range` |
| N0056 | 11 (9/2) | 11 | 1 -> 1 | COVERED r11u152 (residue: pass-145 R2 (sister): PreprocTest enum base bit_typesp | `span\|bit_typespec\|endcol\|under:ref_typespec` |
| N0093 | 11 (11/0) | 11 | 65 -> 65 | COVERED r11u152 (N0093) | `span\|io_decl\|line+col+endline+endcol\|under:function` |
| N0103 | 11 (11/0) | 11 | 7 -> 7 | COVERED r11u152 (N0103) | `name\|class_typespec\|ours-empty\|under:ref_typespec` |
| N0139 | 10 (2/8) | 10 | 1 -> 1 | COVERED r11u152 (residue: pass-146 R1: member names in parameter typespec copies | `fullname\|ref_typespec\|tok:id::id::id::->id@id.id.id::id.\|under:typespec_member` |
| N0140 | 10 (2/8) | 10 | 0 -> 0 | COVERED r11u152 (N0140) | `file\|struct_typespec\|other-file\|under:ref_typespec` |
| N0143 | 10 (2/8) | 10 | 0 -> 0 | COVERED r11u152 (N0143) | `file\|struct_typespec\|other-file\|under:module_inst` |
| N0149 | 10 (2/8) | 10 | 0 -> 0 | COVERED r11u152 (N0149) | `file\|struct_typespec\|other-file\|under:package` |
| N0075 | 9 (9/0) | 9 | 6 -> 6 | COVERED r11u152 (residue: pass-146 R5: tfArgTypedefLastWriter146 declined shapes | `span\|enum_typespec\|line+col+endline+endcol\|under:package` |
| N0078 | 9 (7/2) | 9 | 0 -> 0 | COVERED r11u152 (N0078) | `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation` |
| N0163 | 9 (7/2) | 9 | 5 -> 5 | COVERED r11u152 (N0163) | `fullname\|ref_typespec\|tok:id->id\|under:enum_typespec` |
| N0084 | 8 (6/2) | 8 | 50 -> 50 | COVERED r11u152 (residue: pass-146 R4: the type-parameter default's member refer | `fullname\|ref_typespec\|tok:id@id.id.->\|under:typespec_member` |
| N0011 | 7 (7/0) | 7 | 4 -> 4 | COVERED r11u152 (N0011) | `file\|logic_net\|golden-empty\|under:ref_obj` |
| N0417 | 6 (2/4) | 6 | 3 -> 3 | COVERED r11u152 (N0417, r11u151 pairB_c3_scratch.patch) | `span\|operation\|line+col+endline+endcol\|under:port` |
| N0433 | 6 (4/2) | 6 | 0 -> 0 | COVERED r11u152 (N0433) | `file\|packed_array_typespec\|golden-empty\|under:ref_typespec` |
| N0436 | 6 (4/2) | 6 | 0 -> 0 | COVERED r11u152 (N0436) | `span\|packed_array_typespec\|golden-zero\|under:ref_typespec` |
| N0454 | 5 (3/2) | 5 | 1 -> 1 | COVERED r11u152 (N0454) | `fullname\|ref_typespec\|tok:id@id.id.id.id.->\|under:typespec_member` |
| N0004 | 4 (4/0) | 4 | 20 -> 20 | COVERED r11u152 (N0004) | `fullname\|ref_typespec\|tok:id@id.->\|under:typespec_member` |
| N0133 | 4 (0/4) | 4 | 10 -> 10 | COVERED r11u147+r11u152 (residue: pass-145 R7 (case dfi/i01) + r11u153 N2 (e148/ | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` |
| N0265 | 4 (4/0) | 4 | 20 -> 20 | COVERED r11u152 (N0265) | `fullname\|ref_typespec\|tok:id@id.->\|under:logic_typespec` |
| N0409 | 4 (4/0) | 4 | 4 -> 4 | COVERED r11u152 (residue: pass-146 R5 (probe g114_f_twopkg, g27_a0_head)) | `span\|enum_typespec\|line+col+endline+endcol\|under:module_inst` |
| N0470 | 4 (0/4) | 4 | 77 -> 77 | COVERED r11u152 (N0470) | `fullname\|ref_typespec\|tok:id->id\|under:packed_array_typespec` |
| N0472 | 4 (0/4) | 4 | 42 -> 42 | COVERED r11u152 (N0472) | `fullname\|ref_obj\|tok:id->id.id@in-typespec\|under:operation` |
| N0482 | 4 (4/0) | 4 | 15 -> 15 | COVERED r11u152 (residue: pass-145 R1 (sister): GenCase generate-case item names | `fullname\|named_begin\|golden-empty\|under:case_item` |
| N0483 | 4 (4/0) | 4 | 15 -> 15 | COVERED r11u152 (residue: pass-145 R1 (sister): GenCase) | `span\|gen_scope\|line+col+endline+endcol\|under:gen_scope_array` |
| N0486 | 4 (4/0) | 4 | 14 -> 14 | COVERED r11u152 (residue: pass-145 R1 (sister): GenCase) | `span\|gen_scope_array\|line+col+endline+endcol\|under:module_inst` |
| N0494 | 4 (2/2) | 4 | 8 -> 8 | COVERED r11u152 (N0494) | `fullname\|ref_typespec\|golden-empty\|under:packed_array_typespec` |
| N0528 | 4 (4/0) | 4 | 2 -> 2 | COVERED r11u152 (N0528) | `value\|constant\|value:UINT->UINT\|under:cont_assign` |
| N0531 | 4 (2/2) | 4 | 2 -> 2 | COVERED r11u152 (N0531) | `fullname\|ref_typespec\|tok:id@id.id.id.id.id.->\|under:typespec_member` |
| N0534 | 4 (0/4) | 4 | 2 -> 2 | COVERED r11u152 (N0534, r11u151 pairB_c3_scratch.patch) | `fullname\|ref_typespec\|tok:->id.\|under:operation` |
| N0646 | 4 (4/0) | 4 | 0 -> 0 | COVERED r11u152 (N0646) | `fullname\|ref_obj\|golden-empty\|under:case_item` |
| N0655 | 4 (2/2) | 4 | 0 -> 0 | COVERED r11u152 (N0655) | `name\|enum_typespec\|tok:id->id\|under:ref_typespec` |
| N0284 | 3 (3/0) | 3 | 49 -> 49 | COVERED r11u147+r11u152 (residue: pass-145 R7 (case dfi/i01) + r11u153 N2 (e148/ | `struct\|ours-only:fewer-copies\|constant\|under:cont_assign` |
| N0019 | 2 (0/2) | 2 | 0 -> 0 | COVERED r11u152 (N0019) | `fullname\|ref_obj\|golden-empty@in-typespec\|under:hier_path` |
| N0130 | 2 (0/2) | 2 | 24 -> 24 | COVERED r11u147+r11u152 (residue: pass-144 S3 (packed_array_struct) + pass-146 R | `depth\|logic_typespec\|ref_typespec->ref_typespec` |
| N0135 | 2 (2/0) | 2 | 3 -> 3 | COVERED r11u152 (residue: pass-146 R3: IfGenTypeBinding (grid ig/i11)) | `span\|struct_typespec\|endline+endcol\|under:module_inst` |
| N0266 | 2 (2/0) | 2 | 6 -> 6 | COVERED r11u152 (residue: pass-146 R5 (grid fa/f11)) | `span\|enum_typespec\|line+col+endline+endcol\|under:ref_typespec` |
| N0688 | 2 (0/2) | 2 | 2 -> 2 | COVERED r11u152 (N0688) | `fullname\|ref_typespec\|tok:id@id->id::id\|under:typespec_member` |
| N0751 | 2 (2/0) | 2 | 2 -> 2 | COVERED r11u152 (residue: v11u146 R6: the interface type-parameter default types | `span\|logic_typespec\|col+endcol\|under:ref_typespec` |
| N0762 | 2 (2/0) | 2 | 4 -> 4 | COVERED r11u152 (residue: pass-146 R3: IfGenTypeBinding (defNetTypedefEndWrite13 | `span\|struct_typespec\|endline+endcol\|under:package` |
| N0830 | 2 (2/0) | 2 | 1 -> 1 | COVERED r11u152 (N0830) | `struct\|ours-only:fewer-copies\|logic_net\|under:cont_assign` |
| N0962 | 2 (0/2) | 2 | 0 -> 0 | COVERED r11u152 (N0962) | `fullname\|hier_path\|golden-empty\|under:port` |
| N1014 | 2 (0/2) | 2 | 0 -> 0 | COVERED r11u152 (N1014) | `fullname\|ref_obj\|tok:id->id.id.id[n].id@in-typespec\|under:operation` |
| N0108 | 0 (0/0) | 0 | 7 -> 7 | COVERED r11u152 (residue: pass-146 R4 (grid tp/t5_iface)) | `fullname\|ref_typespec\|tok:id@id.id.id.->\|under:typespec_member` |
| N2320 | 0 (0/0) | 0 | 2 -> 2 | COVERED r11u152 (residue: v11u146 R2: escaped instance ref_module end (esc/x2)) | `span\|ref_module\|endcol\|under:module_inst` |

### T3. Pair A r11u147 (landed as pass 147): its covered clusters, rows at 89d599ef -> after pass 147 (measured)

| cluster | rows 89d599ef | after pass 147 | probe 89d599ef -> after 147 | coverage at 89d599ef | key |
|---|---|---|---|---|---|
| N0045 | 10 | 2 | 12 -> 2 | COVERED r11u147 (N0045, r11u151 law_after_r11u145.patch) | `struct\|golden-only:fewer-copies\|constant\|under:typespec_member` |
| N0129 | 10 | 10 | 33 -> 33 | COVERED r11u147 (residue: pass-145 R10: N0129's remaining shapes (Earlgrey flash | `fullname\|ref_typespec\|tok:->.id\|under:constant` |
| N0077 | 9 | 2 | 0 -> 0 | COVERED r11u147 (N0077) | `fullname\|ref_obj\|tok:id.id[id].->\|under:bit_select` |
| N0286 | 7 | 7 | 7 -> 7 | COVERED r11u147 (N0286) | `struct\|ours-only:fewer-copies\|ref_obj\|under:int_typespec` |
| N2383 | 6 | 0 | 0 -> 0 | COVERED r11u147 (N2383, r11u151 law_after_r11u145.patch) | `struct\|golden-only:elsewhere\|constant\|under:typespec_member` |
| N2384 | 6 | 0 | 0 -> 0 | COVERED r11u147 (N2384, r11u151 law_after_r11u145.patch) | `struct\|ours-only:elsewhere\|constant\|under:typespec_member` |
| N0446 | 5 | 5 | 7 -> 7 | COVERED r11u147 (residue: r11v145 V2: an operand part-select bound named by the  | `fullname\|ref_typespec\|tok:.id->\|under:constant` |
| N0453 | 5 | 5 | 1 -> 1 | COVERED r11u147 (residue: r11v145 V4: a generate-if process part_select name (ca | `fullname\|part_select\|tok:id.->\|under:assignment` |
| N0010 | 4 | 4 | 1 -> 1 | COVERED r11u147 (residue: r11v145 V6 (iaw/x06 x08) + pass-144 S4 (HierPathStruct | `span\|constant\|col+endcol\|under:param_assign` |
| N0133 | 4 | 4 | 10 -> 10 | COVERED r11u147+r11u152 (residue: pass-145 R7 (case dfi/i01) + r11u153 N2 (e148/ | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` |
| N0471 | 4 | 2 | 54 -> 54 | COVERED r11u147 (N0471) | `fullname\|ref_typespec\|tok:.id[n]->\|under:constant` |
| N0475 | 4 | 4 | 21 -> 21 | COVERED r11u147 (residue: pass-145 R5: the imported package parameter read in a  | `struct\|ours-only:fewer-copies\|ref_typespec\|under:constant` |
| N0536 | 4 | 4 | 2 -> 2 | COVERED r11u147 (residue: pass-145 R10: the child-view reference name of the imp | `fullname\|ref_typespec\|tok:id.id->id\|under:constant` |
| N0006 | 3 | 3 | 3 -> 3 | COVERED r11u147 (N0006) | `struct\|golden-only:fewer-copies\|logic_net\|under:ref_obj` |
| N0284 | 3 | 3 | 49 -> 49 | COVERED r11u147+r11u152 (residue: pass-145 R7 (case dfi/i01) + r11u153 N2 (e148/ | `struct\|ours-only:fewer-copies\|constant\|under:cont_assign` |
| N0427 | 3 | 3 | 0 -> 0 | COVERED r11u147 (residue: pass-145 R9: the bare base index named by the path (Sc | `fullname\|ref_obj\|tok:id[id].id.->\|under:bit_select` |
| N0702 | 3 | 0 | 0 -> 0 | COVERED r11u147 (N0702) | `fullname\|ref_typespec\|tok:.id[n].id.id->\|under:constant` |
| N0046 | 2 | 0 | 5 -> 5 | COVERED r11u147 (N0046, r11u151 law_after_r11u145.patch) | `struct\|ours-only:fewer-copies\|logic_net\|under:ref_obj` |
| N0130 | 2 | 2 | 24 -> 24 | COVERED r11u147+r11u152 (residue: pass-144 S3 (packed_array_struct) + pass-146 R | `depth\|logic_typespec\|ref_typespec->ref_typespec` |
| N0394 | 2 | 2 | 0 -> 0 | COVERED r11u147 (N0394) | `file\|constant\|ours-empty\|under:operation` |
| N0724 | 2 | 0 | 0 -> 0 | COVERED r11u147 (N0724, r11u151 law_after_r11u145.patch) | `struct\|ours-only:absent\|constant\|under:param_assign` |
| N0739 | 2 | 2 | 27 -> 27 | COVERED r11u147 (N0739) | `struct\|ours-only:fewer-copies\|ref_obj\|under:cont_assign` |
| N0740 | 2 | 2 | 10 -> 10 | COVERED r11u147 (residue: pass-144 S3: packed_array_struct body localparam type  | `struct\|golden-only:absent\|struct_typespec\|under:ref_typespec` |
| N0758 | 2 | 0 | 4 -> 0 | COVERED r11u147 (N0758, r11u151 law_after_r11u145.patch) | `depth\|hier_path\|operation->integer_typespec` |
| N0765 | 2 | 2 | 3 -> 3 | COVERED r11u147 (N0765) | `fullname\|ref_obj\|tok:id.id.->\|under:method_func_call` |
| N0820 | 2 | 2 | 1 -> 1 | COVERED r11u147 (N0820) | `fullname\|ref_obj\|tok:id[id].id[n - id][n:n].id.->\|under:operation` |
| N0833 | 2 | 2 | 1 -> 1 | COVERED r11u147 (N0833) | `fullname\|bit_select\|tok:id.->\|under:hier_path` |
| N1053 | 2 | 0 | 0 -> 0 | COVERED r11u147 (N1053) | `fullname\|bit_select\|tok:id.->\|under:operation` |
| N1063 | 2 | 2 | 0 -> 0 | COVERED r11u147 (N1063) | `fullname\|ref_obj\|tok:id.id.id[id - n:].id.->\|under:operation` |
| N1067 | 2 | 2 | 0 -> 0 | COVERED r11u147 (N1067) | `fullname\|ref_obj\|tok:id.id[n].id[id(id) - n:n].id.->\|under:sys_func_call` |
| N1118 | 2 | 2 | 0 -> 0 | COVERED r11u147 (N1118) | `fullname\|part_select\|tok:id.->\|under:port` |
| N1129 | 2 | 0 | 0 -> 0 | COVERED r11u147 (N1129, r11u151 law_after_r11u145.patch) | `fullname\|ref_typespec\|tok:.id->\|under:array_typespec` |
| N1140 | 2 | 2 | 0 -> 0 | COVERED r11u147 (N1140) | `span\|constant\|ours-zero\|under:operation` |
| N1276 | 1 | 1 | 0 -> 0 | COVERED r11u147 (residue: pass-145 R7: the function-body read of the imported pa | `struct\|golden-only:fewer-copies\|bit_select\|under:cont_assign` |
| N0455 | 0 | 0 | 1 -> 1 | COVERED r11u147 (N0455) | `span\|assignment\|line+col+endline+endcol\|under:initial` |
| N0456 | 0 | 0 | 1 -> 1 | COVERED r11u147 (N0456) | `span\|ref_obj\|line+col+endline+endcol\|under:assignment` |
| N1983 | 0 | 0 | 3 -> 3 | COVERED r11u147 (residue: pass-145 R5 (cases usp/u04, u08: decompile)) | `value\|constant\|value:BIN->UINT+decompile+consttype:3->9\|under:cont_assign` |
| N2268 | 0 | 0 | 1 -> 1 | COVERED r11u147 (residue: r11v145 V4: a qualified bound constant endcol (case ps | `span\|constant\|endcol\|under:part_select` |

## 5. The structural rows (first field depth / type / count) after passes 145/146 and the r11u151 decode

**At 89d599ef: 14 row-modes in 7 tests** (evidence/structural.txt), classed by first cluster with r11u151's letters:

| class | row-modes | rows | first cluster | law binary (measured) | pass 147 (measured) | what it needs |
|---|---|---|---|---|---|---|
| D2 the swapped cast targets | 6 (3 tests) | def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot d/t | N2384 (+ N2383) | CMP_EQUAL | CMP_EQUAL | D2 alone (law pkgTdCastTargetOwnView151) |
| ARR procedural whole-reference binding | 2 | array_assign d/t | N0046 | CMP_EQUAL | CMP_EQUAL | ARR alone |
| G the kept concatenation | 2 | BlackParrotComplex d/t | N0724 (+ N1129) | CMP_EQUAL | CMP_EQUAL | G + G2 |
| D member-default leftovers | 2 | StructParamFuncBodyFieldCompare d/t | N0045 | `differ:fullname(15)` | `differ:fullname(15)` | D, then no structural record: its open faces are N0001, N0009, N0018 and N0759 (R-D1..R-D3) |
| C3 | 0 structural | the two ...PassedAsPort tests (`line(2)` / `fullname(4)`) | N0417 + N0534 | CMP_EQUAL (with the pair-B scratch) | `line(2)` both | the pair-B C3 module half (ModuleEmit emitInstance) |
| N0286 comb_dyn_2d_packed_sel | 2 | comb_dyn_2d_packed_sel d/t | N0286 | `depth(1)` | `depth(1)` | none of r11u151's laws. It is pair A's named N0286 (pass-145 R8: the SEL_W reference under the 32:36 operation's int_typespec range); pass 147 did not take it (its R4) |

**After the law binary, and after pass 147, the only structural rows left are comb_dyn_2d_packed_sel d/t.** Every
other structural row needed exactly the r11u151 law named in its class:
* D2: def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot;
* ARR: array_assign;
* G: BlackParrotComplex;
* D: StructParamFuncBodyFieldCompare, which is non-structural after it.

C3 is not structural and needs its module half. The probe set still has 99 `type` and 98 `depth` first fields at
b6af876c.

## 6. The per-ground briefs (on top of pass 147 as landed + pair B r11u152 optimistic)

**The single-cluster greedy stalls after a few steps** (evidence/report147.txt section 6), because most remaining rows
need two or more clusters at once. The briefs below come from `drivers/greedy_sets.py` (evidence/greedy_sets147.txt).
A candidate there is the whole open-cluster set of one remaining row whose open clusters all belong to one ground,
and the greedy picks by row-modes cleared per cluster added. The base is 68 row-modes / 34 tests cleared by pass 147
(28, measured) and pair B (40, optimistic).

The remaining 251 row-modes carry:
* by open-cluster count: 1 open cluster 65, 2: 53, 3: 23, 4: 27, 5: 15, 6 or more: 68;
* by ground: A only 74, B only 71, both 93, with an unpinned cluster 13.

Every OPEN cluster of ground A clears 142 row-modes (71 tests) cumulative with the pairs; every OPEN cluster of
ground B clears 139 (70 tests).

**Ground A: expression/parameter (ExprEmit/EmitHelpers/StmtEmit/ParamEmit). The refill after pass 147.**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0005 | 8 | 76 | 38 | GenForIfaceLocalparamBound/d GenForIfaceLocalparamNestedGen/d LargeValue2Struct/d StructUnsizedVal/d GenForIfaceLocalparamBound/t GenForIfaceLocalparamNestedGen/t LargeValue2Struct/t StructUnsizedVal/t | `span\|constant\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) [r11u142ma |
| 2 | N0063 | 8 | 84 | 42 | iface_cfg_mem/d/u2r iface_nested_param_field/d/u2r iface_param_2level/d/u2r iface_struct_field_param_width/d/u2r iface_cfg_mem/t/u2r iface_nested_param_field/t/u2r iface_param_2level/t/u2r iface_struct_field_param_width/t/u2r | `fullname\|ref_typespec\|ours-empty\|under:operation` | emitExpr (ExprEmit.cpp, law caTernaryArmPatternFlatten99) < emitExpr (ExprEmit.cpp, law patCaGenIdxValueRender112) < emitExpr (ExprEmit.cpp, law concatRefNoSubst) [r11u14 |
| 3 | N0001 + N0007 | 8 | 92 | 46 | GenIfIfaceParamStructField/d GenIfIfaceParamStructField/t expr_width_cast/d/u2r mriscv_bind_sva/d/u2r portsel_struct_param/d/u2r expr_width_cast/t/u2r mriscv_bind_sva/t/u2r portsel_struct_param/t/u2r | `span\|ref_obj\|col+endcol\|under:hier_path`; `fullname\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmt |
| 4 | N0003 + N1132 | 4 | 96 | 48 | ParamNoImport/d ParamNoImport/t iface_zero_width_field/d/u2r iface_zero_width_field/t/u2r | `fullname\|ref_typespec\|golden-empty\|under:operation`; `fullname\|ref_typespec\|tok:id@id.id->id\|under:operation` | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.cpp, law caUn |
| 5 | N0018 | 2 | 98 | 49 | mem_ff_partial_rsp/d/u2r mem_ff_partial_rsp/t/u2r | `fullname\|ref_obj\|ours-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollaps |
| 6 | N0097 | 2 | 100 | 50 | ArrayMethodIterator/d ArrayMethodIterator/t | `span\|hier_path\|endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmt |
| 7 | N0129 | 2 | 102 | 51 | YosysOldOpen/d YosysOldOpen/t | `fullname\|ref_typespec\|tok:->.id\|under:constant` | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < emitExpr (ExprEmit.cpp, law psBoundPkgParamTs31) [r11u142ma |
| 8 | N0286 | 2 | 104 | 52 | comb_dyn_2d_packed_sel/d/u2r comb_dyn_2d_packed_sel/t/u2r | `struct\|ours-only:fewer-copies\|ref_obj\|under:int_typespec` | emitExpr (ExprEmit.cpp, law castTgtDefaultIsLiteral) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < operator() (ExprEmit.cpp, law pkgTdCloneRefNoBind18) [r1 |
| 9 | N0357 | 2 | 106 | 53 | jeras_tcb_gpio/d/u2r jeras_tcb_gpio/t/u2r | `fullname\|ref_obj\|tok:id.id[id - n:n].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law everyPartSelIsConstSel78) [r |
| 10 | N0016 | 2 | 108 | 54 | FuncIoTypespec/d FuncIoTypespec/t | `file\|logic_net\|golden-empty\|under:module_inst` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapse |
| 11 | N0010 | 2 | 110 | 55 | HierPathStructTypespec/d HierPathStructTypespec/t | `span\|constant\|col+endcol\|under:param_assign` | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTargetKinds) < emitParameters (ParamEmit.cpp, law castElabFoldTarg |
| 12 | N1118 | 2 | 112 | 56 | genscope_module_ctx_reset/d/u2r genscope_module_ctx_reset/t/u2r | `fullname\|part_select\|tok:id.->\|under:port` | emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < emitInstance (ModuleEmit.cpp, law elabPortConnUnitEnumNet) < operator() (ModuleEmit.cpp, law genScopeIface) [r11u |
| 13 | N0822 | 2 | 114 | 57 | HighLow/d HighLow/t | `span\|constant\|line+col+endline+endcol\|under:param_assign` | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTargetKinds) < emitParameters (ParamEmit.cpp, law castElabFoldTarg |
| 14 | N0276 | 2 | 116 | 58 | ComplexHierPath/d ComplexHierPath/t | `span\|hier_path\|endcol\|under:cont_assign` | emitExpr (ExprEmit.cpp, law r10fsv2) < operator() (ModuleEmit.cpp, law genCaParamFoldOneHopPool95) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) [r11u138m |
| 15 | N1064 | 2 | 118 | 59 | iface_scalar_localparam/d/u2r iface_scalar_localparam/t/u2r | `fullname\|ref_obj\|tok:id.id[id - n:].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law everyPartSelIsConstSel78) [r |
| 16 | N1063 | 2 | 120 | 60 | iface_struct_field_partsel/d/u2r iface_struct_field_partsel/t/u2r | `fullname\|ref_obj\|tok:id.id.id[id - n:].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law everyPartSelIsConstSel78) [r |
| 17 | N1115 | 2 | 122 | 61 | PackedArrayHighConn/d PackedArrayHighConn/t | `fullname\|bit_select\|tok:->id.\|under:bit_select` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law genLpIdxOpOperandFold112) < emitModuleDefPorts (ModuleEmit.cpp, law structParamBareImportRe |
| 18 | N0006 + N0765 | 2 | 124 | 62 | StringMethod/d StringMethod/t | `struct\|golden-only:fewer-copies\|logic_net\|under:ref_obj`; `fullname\|ref_obj\|tok:id.id.->\|under:method_func_call` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < emitContAssigns (ModuleEmit.cpp, law caLhsDefNetUnlessOpRhs |
| 19 | N0833 + N1067 | 2 | 126 | 63 | iface_arr_struct_field_partsel/d/u2r iface_arr_struct_field_partsel/t/u2r | `fullname\|bit_select\|tok:id.->\|under:hier_path`; `fullname\|ref_obj\|tok:id.id[n].id[id(id) - n:n].id.->\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law hpConnElemIdxFold17) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) < emitModuleDef (ModuleEmit.cpp, law shadowedImportPara |
| 20 | N0394 + N1140 | 2 | 128 | 64 | PatternStruct/d/u2r PatternStruct/t/u2r | `file\|constant\|ours-empty\|under:operation`; `span\|constant\|ours-zero\|under:operation` | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < emitContAssigns (ModuleEmit.cpp, law caIfaceElabNetDeclAssignListing88) < emitInstance (ModuleEmit.cpp, law e |
| 21 | N0427 | 1 | 129 | 65 | InterfArrayBind/d | `fullname\|ref_obj\|tok:id[id].id.->\|under:bit_select` | emitExpr (ExprEmit.cpp) < operator() (ModuleEmit.cpp, law genCaParamFoldOneHopPool95) < emitGenScopes (ModuleEmit.cpp, law genLoopUnitMiseval) [r11u150map pin] |
| 22 | N0739 | 1 | 130 | 65 | ComplexParamOverload/t | `struct\|ours-only:fewer-copies\|ref_obj\|under:cont_assign` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) < emitModuleDef (ModuleEmit.cpp, law shadowedImport |
| 23 | N0050 + N0091 + N1075 + N1076 | 2 | 132 | 66 | MacroArgMismatch/d MacroArgMismatch/t | `span\|operation\|col+endcol\|under:assignment`; `span\|ref_obj\|col+endcol\|under:operation`; `span\|always\|endcol\|under:module_inst`; `span\|assignment\|endcol\|under:event_control` | emitExpr (ExprEmit.cpp, law connIpsPkgParamBoundNoTs65) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtC |

ground A: the 31 clusters above clear 64 row-modes on top of the pairs (132 with them)

**Ground B: module/type (TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main). On top of r11u152, or its refill.**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0009 | 8 | 76 | 38 | IfGenTypeBinding/d StructParamFieldRange/d IfGenTypeBinding/t StructParamFieldRange/t cva6_struct_param_field/d/u2r struct_member_cfg_width/d/u2r cva6_struct_param_field/t/u2r struct_member_cfg_width/t/u2r | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit.cpp, law typeParamC |
| 2 | N0057 | 4 | 80 | 40 | PackedEnumPort/d PackedEnumPort/t VarPassedTo2Submodules/d/u2r VarPassedTo2Submodules/t/u2r | `struct\|golden-only:fewer-copies\|ref_typespec\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp, law importCopyAggFormalOwnCopy32) < exportDesign (UhdmExporter.cpp, law caUnelabBodyCh |
| 3 | N0025 + N0033 | 6 | 86 | 43 | rp32_r5p_bru/d/u2r rp32_r5p_mdu/d/u2r rp32_r5p_wbu/d/u2r rp32_r5p_bru/t/u2r rp32_r5p_mdu/t/u2r rp32_r5p_wbu/t/u2r | `depth\|constant\|range->operation`; `struct\|ours-only:fewer-copies\|operation\|under:range` | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) |
| 4 | N0014 + N0044 | 6 | 92 | 46 | gen_scope_typaram/d/u2r packed_array_struct_port_sel/d/u2r packed_struct_array_fifo/d/u2r gen_scope_typaram/t/u2r packed_array_struct_port_sel/t/u2r packed_struct_array_fifo/t/u2r | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member`; `span\|struct_typespec\|endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs107) < makeTypespec (TypeEmit.cpp, law anonPackedAg |
| 5 | N0043 | 2 | 94 | 47 | struct_param_pattern_packing/d/u2r struct_param_pattern_packing/t/u2r | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit.cpp, law typeParamC |
| 6 | N0049 | 2 | 96 | 48 | rp32_r5p_alu/d/u2r rp32_r5p_alu/t/u2r | `span\|sys_func_call\|endcol\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law syntaxMultiConcat) < emitSyntaxExpr (TypeEmit.cpp, law structParamPathBaseAtMember137) < operator() (ModuleEmit.cpp, law defGenElemIpsVa |
| 7 | N0430 | 2 | 98 | 49 | UnionCast/d UnionCast/t | `file\|union_typespec\|ours-empty\|under:ref_typespec` | buildUnionTs (TypeEmit.cpp, law modStructMemberBoundMeta) < emitExpr (ExprEmit.cpp, law modFnLocalTdCastClone112) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmI |
| 8 | N0767 | 2 | 100 | 50 | ImplicitArg/d ImplicitArg/t | `span\|range\|col+endcol\|under:logic_typespec` | makeTypespec (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < sharedTypespec (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitTaskFuncs (TaskFuncEmit.cpp, l |
| 9 | N1146 | 2 | 102 | 51 | SimpleConstraint/d SimpleConstraint/t | `span\|integer_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < operator() (ModuleEmit.cpp, law implicitNetNoFile119) < emitModuleDef (ModuleEmit.cpp, law implicitNetNoFile119 |
| 10 | N0083 + N0740 | 2 | 104 | 52 | packed_array_struct/d/u2r packed_array_struct/t/u2r | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `struct\|golden-only:absent\|struct_typespec\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfac |
| 11 | N0090 + N0533 | 2 | 106 | 53 | packed_array_reset_loop/d/u2r packed_array_reset_loop/t/u2r | `span\|logic_typespec\|endline+endcol\|under:ref_typespec`; `span\|logic_typespec\|line+col\|under:ref_typespec` | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < exportDesign (UhdmExporter.cpp,  |
| 12 | N0117 + N0768 | 2 | 108 | 54 | CrossFunc/d CrossFunc/t | `span\|unsupported_typespec\|endcol\|under:ref_typespec`; `span\|logic_var\|endcol\|under:module_inst` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymbolic) < emitTopPorts (ModuleEmit.cpp, law tpDimVecPor |
| 13 | N0269 + N0450 | 2 | 110 | 55 | OneNetModport/d/u2r OneNetModport/t/u2r | `fullname\|ref_typespec\|tok:id.id->id\|under:logic_var`; `fullname\|logic_var\|tok:id.id->id\|under:io_decl` | emitInterfaceInstance (ModuleEmit.cpp, law caIfaceElabNetDeclAssignListing88) < emitInstance (ModuleEmit.cpp, law modportNeedsSimplePortNoGenericFallback215v) < emitInsta |
| 14 | N0438 + N0487 | 2 | 112 | 56 | const_cast_signext/d/u2r const_cast_signext/t/u2r | `span\|struct_typespec\|line+col+endline+endcol\|under:module_inst`; `struct\|ours-only:absent\|constant\|under:cont_assign` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitTypedefs (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52) < exportDesign (UhdmExporter.cpp, law import |
| 15 | N0447 + N0498 | 2 | 114 | 57 | ClassParamAsParam/d ClassParamAsParam/t | `file\|param_assign\|golden-empty\|under:class_typespec`; `span\|class_var\|endcol\|under:module_inst` | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < materializeDef |
| 16 | N1135 + N1156 | 2 | 116 | 58 | UnpackPort/d UnpackPort/t | `span\|array_net\|line+col+endline+endcol\|under:module_inst`; `span\|struct_net\|line+col\|under:array_net` | emitArrayNet (TypeEmit.cpp, law sharedAliasNoStamp41) < emitInstance (ModuleEmit.cpp, law elabNetTdCloneNoAlias134) < exportDesign (UhdmExporter.cpp, law dottedTopNameBar |
| 17 | N1041 + N1161 | 2 | 118 | 59 | union_param_repro/d/u2r union_param_repro/t/u2r | `span\|union_typespec\|line+col+endline+endcol\|under:ref_typespec`; `span\|union_typespec\|line+col+endline+endcol\|under:design` | buildUnionTs (TypeEmit.cpp, law modStructMemberBoundMeta) < exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) < main (uhdm_main.cpp, law genCaPatKeepTagD |
| 18 | N0796 + N0969 | 2 | 120 | 60 | GenerateUnnamed/d GenerateUnnamed/t | `span\|gen_scope_array\|line+col+endline+endcol\|under:gen_scope`; `fullname\|ref_obj\|tok:id.id.->\|under:prim_term` | operator() (ModuleEmit.cpp, law genCaParamFoldOneHopPool95) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) < operator() (ModuleEmit.cpp, law genNestedScope |
| 19 | N1015 + N1062 | 2 | 122 | 61 | TypeParamElab/d TypeParamElab/t | `fullname\|ref_obj\|tok:id.id.id.id->id@in-typespec\|under:operation`; `fullname\|ref_obj\|tok:id.id.->@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl1 |
| 20 | N0831 + N0843 | 2 | 124 | 62 | MultirangesStartNotFromZero/d/u2r MultirangesStartNotFromZero/t/u2r | `file\|enum_const\|golden-empty\|under:ref_obj`; `span\|enum_const\|golden-zero\|under:ref_obj` | buildEnumTs (TypeEmit.cpp, law unitArith) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11u142map pin] |
| 21 | N0844 + N0851 | 2 | 126 | 63 | EnumVar/d EnumVar/t | `span\|enum_typespec\|endline+endcol\|under:ref_typespec`; `span\|enum_typespec\|endline+endcol\|under:package` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11u138map pin] [r11 |
| 22 | N1059 + N1072 | 2 | 128 | 64 | iface_sig_in_child_port/d/u2r iface_sig_in_child_port/t/u2r | `fullname\|logic_net\|tok:id->id.id\|under:io_decl`; `fullname\|ref_typespec\|tok:id->id.id\|under:logic_net` | emitInterfaceInstance (ModuleEmit.cpp, law modportExprPort) < emitInstance (ModuleEmit.cpp, law modportNeedsSimplePortNoGenericFallback215v) < emitInstance (ModuleEmit.cp |
| 23 | N1174 | 1 | 129 | 65 | HierPathTypespec/t | `fullname\|ref_typespec\|tok:id::id::->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildClassTypedefTs (UhdmExporter.cpp, law typedefAliasSharesTypespec25) < emitClassTypedefs (UhdmE |
| 24 | N0422 + N0484 + N1149 | 2 | 131 | 66 | LogicTypespec/d LogicTypespec/t | `span\|logic_typespec\|endline+endcol\|under:package`; `name\|logic_typespec\|ours-empty\|under:ref_typespec`; `span\|logic_typespec\|line+col+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChild |

ground B: the 41 clusters above clear 63 row-modes on top of the pairs (131 with them)

In short:

* **Expression/parameter ground, after pass 147.**
  1. **N0005, the folded parameter constant's endcol (8 row-modes alone):**
     * GenForIfaceLocalparamBound and ...NestedGen d/t (pass 147 left them at `endcol(1)`);
     * LargeValue2Struct and StructUnsizedVal d/t.

     Pass 147 decoded the interface port-view face to ModuleEmit `emitInterfaceInstance` (its S1): a pair-B site
     for a ground-A cluster. Read the first caller before claiming it.
  2. **N0063, the use-site constant's typespec reference name (8):** iface_cfg_mem, iface_nested_param_field,
     iface_param_2level and iface_struct_field_param_width, all d/t.
  3. **The hier_path base spans and names N0001 + N0007 (8)**, and N0018, N0097, N0036. These are pass-146 R2's
     ExprEmit counterpart of law constPathBaseAnyKind146; they carry 48 / 32 / 25 row-modes but clear few alone.
  4. **N0003 + N1132 (ParamNoImport, iface_zero_width_field).**
  5. **Singles:** N0129 (YosysOldOpen), N0286 (the last structural row), N0357 (jeras_tcb_gpio), N0016
     (FuncIoTypespec), N0010 (HierPathStructTypespec), N1115, N1064, N0822, N1063, N1118, N0276.
  6. **Pass 147's own residues still carrying rows:**
     * StringMethod N0006 + N0765 (R2);
     * PatternStruct N0394 + N1140 (S4, ModuleEmit caller);
     * iface_arr_struct_field_partsel N0833 + N1067 (R3);
     * ComplexParamOverload N0739 (R4, ModuleEmit caller);
     * genscope_module_ctx_reset N1118 (S3, ModuleEmit).
* **Module/type ground (r11u152 and its refill).**
  1. **N0009, the struct typespec's end (8):** IfGenTypeBinding (pass-146 R3), StructParamFieldRange,
     cva6_struct_param_field and struct_member_cfg_width, all d/t. It carries 18 row-modes, and pass 147's R-D1
     (the `localparam type` struct span) is one of its faces.
  2. **N0057**, pass 147's S7 (the enum-alias per-use name, TypeEmit `buildEnumTs`): PackedEnumPort and
     VarPassedTo2Submodules d/t.
  3. **N0025 + N0033**, the rp32 bound operation (6), on top of the rp32 set pair B already holds.
  4. **N0014 + N0044 (6):** gen_scope_typaram, packed_array_struct_port_sel, packed_struct_array_fifo.
  5. **Singles:** N0043, N0049, N0430, N0767, N1146, the packed_array_struct pair N0083 + N0740, N0090 + N0533,
     CrossFunc, OneNetModport, const_cast_signext, ClassParamAsParam, UnpackPort, union_param_repro,
     GenerateUnnamed, TypeParamElab, MultirangesStartNotFromZero, EnumVar, iface_sig_in_child_port,
     HierPathTypespec t, LogicTypespec.
  6. **Pass 147's sister faces on this ground:**
     * S1 the interface port-view left-operand span (N0005's GenForIface rows);
     * S2 the non-ANSI output-port initial;
     * S3 genscope_module_ctx_reset;
     * S4 PatternStruct;
     * S5 C3, the scratch;
     * S6 the def-view gen_for interface member;
     * S7 = N0057 / N0655 / N0163.

## 7. Prediction audits

### 7a. Map 6 against passes 145 and 146 (evidence/report.txt section 8)

Map 6 predicted 71 row-modes for its two live pairs, and 26 of them moved:

| map 6 said | row-modes | moved |
|---|---|---|
| pair A r11u145, optimistic | 23 | **4** (DefaultPatternInt d/t, ibex_counter d/t) |
| pair B r11u146, share law MEASURED | 10 | **10** |
| pair B r11u146, optimistic | 25 | **12**: 10 by pass 146, and packed_struct_array_shift d/t, which pass 145 took under a pair-B route (N1017). Two more of the 25, mem_packed_2d_byte_write and unpacked_elem_partsel_comb d/t, moved later with pass 147, which is pair A's ground |
| both pairs, optimistic | 13 | 0 |

**Unpredicted, 13 row-modes of pass 146:**

| rows | map-6 cluster | where map 6 put it | landed by |
|---|---|---|---|
| PortInitVal d, PortInitVal2 d/t, sat_asserts_seq d/t | N0455 + N0456 | ground-A step 3 (ExprEmit/StmtEmit pin) | ModuleEmit portInitAssignAtHeader146: **the caller** |
| FuncCase d/t | N0075 N0266 N0409 | OPEN | UhdmExporter tfArgTypedefLastWriter146 (pins: TypeEmit buildEnumTs < ParamEmit emitPackage < UhdmExporter) |
| param_name_collision_typeparam d/t | N0274 | ground-B step 5 (TypeEmit) | TypeEmit tpDefaultCaLhsUnparented146: pin right |
| typed_named_pattern d/t | N0011 | ground-B step 8 (TypeEmit thisImplicitNetBoth38) | UhdmExporter castKeyElabNetNoFile146: **another file** |
| ExplictiPorts d | N0081 + PortExpr set | pair B routed (d was not all-covered) | ModuleEmit: pin right |
| BasicOh t | N0076 + N1061 | pair A covered N0076 | joint 145 + 146 (r11u153) |

At the cluster level:
* **Map 6's pair A (29 clusters):** 2 cleared (N0076, N2385), 7 fell (N0001 62 -> 48, N0005 44 -> 24, N0007 34 -> 32,
  N0010 30 -> 4, N0056 15 -> 11, N0057 14 -> 12, N0415 6 -> 4), and 20 unchanged. N0018, N0036, N0063, N0097-N0102,
  N0129 and N0091 did not move at all.
* **Map 6's pair B (47 clusters):**
  * cleared 11: N0096, N0554, N0764, N0824, N0825, N1017, N1085, N1093, N1098, N1111, N1148;
  * fell 10: N0030 16 -> 10, N0044 14 -> 4, N0133 10 -> 4, ...;
  * 26 unchanged, among them the whole UVM/Earlgrey set and the struct/int typespec spans N0009, N0014, N0025,
    N0031, N0033, N0039, N0042, N0043.
* **Map 6's section-7 greedy lists:** ground A cleared N0455 and N0456, both taken by pass 146 at a ModuleEmit
  caller. Ground B cleared N0274, and N0011 fell 9 -> 7. None of the other 76 listed clusters moved before pass 147.

### 7b. This map's own pair-A list against pass 147 (evidence/audit147.txt)

**Pass 147 moved 28 of the 319 dispatched row-modes. This map, built from the brief's pair-A ids, predicted 25 of
them for pair A alone; 10 moved, all of them the MEASURED law's.**

* **Predicted but not moved, 15:** HierPathStructTypespec d/t, InterfArrayBind d, StringMethod d/t,
  ComplexParamOverload t, YosysOldOpen t, PatternStruct d/t, comb_dyn_2d_packed_sel d/t, genscope_module_ctx_reset
  d/t, iface_arr_struct_field_partsel d/t. Pass 147's README puts them in its residues:
  * StringMethod R2, iface_arr R3, comb_dyn and ComplexParamOverload R4;
  * PatternStruct S4, genscope_module_ctx_reset S3: ModuleEmit callers.
  * The routed residues (N0010, N0427, N0129) were not in pass 147's brief.
* **Not predicted, 18:**

  | rows | clusters (map-7 status at 89d599ef) | landed by |
  |---|---|---|
  | the four ParameterPassed... / SubmoduleInGenScope... tests d/t | N0012 N0028 N0057 N0150 (OPEN) | ParamEmit memberEnumCloneKeepsBase147 (map pin TypeEmit `buildEnumTs` < ParamEmit `emitParameters`: the first caller) |
  | SelectFromUnpackedInFunction d/t | N0109 N0110 N1114 N1159 (OPEN; map 6 ground-A step 20) | ExprEmit nestedDefaultPatLoc147 (pin right) |
  | mem_packed_2d_byte_write, unpacked_elem_partsel_comb d/t | N0030 (OPEN, pass-146 residue) | ExprEmit vsIpsBaseNamesByIps147 (pin right) |
  | latch_packed_dyn_write d/t | N1053 (A) + N0036 (OPEN) | the same law + lvIdxBitSelAtIndex147 |
  | multiplier d/t | N0471 N0702 (A) + N0568 (OPEN) | gcaUseSiteParamConst147 + firstOrderedConnBitSelWhole147 (pin ExprEmit < ModuleEmit emitInstance) |

* **Clusters:** of pair A's 34 covered clusters with a row, 8 are gone (N0046 N0702 N0724 N0758 N1053 N1129 N2383
  N2384), 3 fell (N0045 10 -> 2, N0077 9 -> 2, N0471 4 -> 2), and 23 are unchanged. Among clusters pair A did not
  cover, 23 cleared or fell:
  * N0113 11 -> 0, N0059 8 -> 0, N0150 8 -> 0, N0568 4 -> 0;
  * N0012 21 -> 13, N0005 24 -> 16, N0024 12 -> 4, N0057 12 -> 4, N0028 12 -> 4, N0030 10 -> 4, N0036 18 -> 14, ...

**What it says about the site pins.** Of the clusters that passes 145, 146 and 147 cleared or reduced and whose
landing law is named:
* **the pinned mint's file is the law's file (or the pin names the law's function among its callers)** for N0076,
  N2385, N0415, N0056, N0010, N0005, N0044, N0274, N0096, the PortExpr set, N0133 / N0554 / N0764, N0030, N0113,
  N0109 / N1114, and N0012 / N0057 / N0150 (the first caller, ParamEmit);
* **it misses** for N0455 / N0456 (a StmtEmit/ExprEmit mint, fixed in the ModuleEmit caller), N0011 (a TypeEmit
  mint, fixed in UhdmExporter's late-binding twin), and the FuncCase set (fixed in UhdmExporter's exportDesign tail).

Two lessons for the briefs:
* A pin is a fair ground guess when the first NON-ExprEmit caller is read too (map 6's caution holds).
* **An optimistic "covered cluster fixed whole" count over-predicts** a brief whose passes take one shape of a
  multi-shape cluster: 4 of 23 (map 6 pair A), 12 of 25 (map 6 pair B), and 0 of 15 (this map's pair A). Measured
  laws are exact: map 6's share law moved 10 of 10; r11u151's law binary reproduced its 14 claimed conversions here, and
  pass 147 landed its 10 non-C3 ones.
  Read the optimistic column as an upper bound, and prefer a measured cross-section.

## 8. The family view (evidence/report147.txt section 8b)

The **near rows**, one open cluster after pass 147 + pair B, are 65 row-modes in 34 tests (report147.txt lists them):
* ArrayMethodIterator N0097, FuncIoTypespec N0016, the GenForIface pair and LargeValue2Struct / StructUnsizedVal N0005,
  HierPathStructTypespec N0010, HighLow N0822, IfGenTypeBinding / StructParamFieldRange / cva6_struct_param_field N0009,
  ImplicitArg N0767, InterfArrayBind N0427, PackedArrayHighConn N1115, PackedEnumPort / VarPassedTo2Submodules N0057,
  SimpleConstraint N1146, UnionCast N0430, YosysOldOpen N0129, ComplexParamOverload t N0739, HierPathTypespec t N1174,
  comb_dyn_2d_packed_sel N0286, expr_width_cast N0001, genscope_module_ctx_reset N1118, ...

The big families still carry dozens to hundreds of clusters each. Rows cleared by the pairs are 0 unless noted.

| family | row-modes / tests | clusters per row at 89d599ef | open per row after pass 147 + pair B |
|---|---|---|---|
| UVM (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg) | 9 / 5 | 178-470 (543 distinct) | 166-455 (528 distinct) |
| Earlgrey_0_1 | 2 / 1 | 130 / 137 | 118 / 123 |
| Rggen (default only) | 1 / 1 | 71 | 68 |
| BlackBePipeInt | 2 / 1 | 33 / 31 | 33 / 31 |
| Scr1SvTests | 2 / 1 | 32 | 27 |
| ibex (14 tests) | 28 / 14 | 1-22 | 0-21 |
| rp32 (4 tests) | 8 / 4 | 6-7 | 2-3 |

Notes on the table:
* ibex: 10 row-modes clear with pair B (ibex_alu, ibex_branch_predict, ibex_csr, ibex_fetch_fifo,
  ibex_register_file_ff, d/t). ibex_pmp keeps 21, ibex_icache 15 and ibex_load_store_unit 13.
* rp32: the N0025 + N0033 / N0049 sets finish them.
* The UVM rows head with N0064 (the include-file line model, pair B) and keep N0001/N0007/N0018 (the hier_path spans
  and names) and the N0104-N0107 method-variable spans.

## 9. Files

* **cluster_index.csv** (89d599ef; the columns `rows_after_law`, `rows_after_pairs`, `alone_on_top_of_pairs` are on
  the law binary's cross-section + both pairs as briefed), **cluster_index_p147.csv** (the same on pass 147's
  cross-section + pair B; pair A's covered clusters read `OPEN (residue of pass 147: ...)`), **clusters.csv**
  (row-mode x cluster), **probe_clusters.csv**, **family_index.csv**.
* **fail_list.csv** / **fail_list_p147.csv**: every `STRICT_NOTEQUAL` row-mode with its first cluster, that
  cluster's coverage and site, its open clusters, and whether the pairs clear it. **probe_fail_list.csv** /
  **probe_fail_list_p147.csv**: the same for probe cases.
* **evidence/**:
  * `clusters/`: record dumps, one example per cluster with a row or >= 3 probe cases.
  * `objects.csv`, `row_objects.csv`.
  * `report.txt`, `report147.txt`, `final.txt`, `structural*.txt`, `greedy_sets*.txt`, `audit147.txt`, `tables.md`.
  * `pins_new.txt`, `sites.json`, `pinwant.txt`.
  * `residue_cases.txt`, `residue_routes.json`, `shape_routes.json`, `ground_override.json`.
  * `tallies.txt`, `verify.txt`, `controls/`.
  * `sweeps/`: the sweep summaries, byteverify, the UVM coin, canaries and the downstream join.
* **drivers/**: `run.sh` (the pipeline) and map 6's drivers, adapted:
  * `final.py` (ids from N2390, the r11u147 / r11u152 coverage, shape routes, the fence);
  * `report7.py` (`R11U156_P147=1` for pass 147's cross-section), `audit147.py`, `tables7.py`, `mksites7.py`;
  * `residue_cases.sh`, `casekeys.sh` (scratch `/tmp/r11u156_cases`), `structural.py` (r11u151's letters);
  * `jobs.py` (fail-closed fence).
