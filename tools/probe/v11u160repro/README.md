# v11u160: adversarial verification of r11u160 (the module/type ground, pair B)

Base `75226e07` (branch matrix-1.87). Verifier worktrees `/tmp/wt_v11u160` (base + `/tmp/r11u160.patch`, then
the refinements below) and `/tmp/wt_v11u160pris` (base), scratch `/tmp/v11u160_*`. The implementer's report and
README are `tools/probe/r11u160repro/README.md`. The slang-fenced tests are `FENCED=` here (four names read from
RESUME.md by `drivers/env.sh`, never spelled); every driver that reads corpus databases refuses to run without
them and drops them by word match (`drivers/mirror.sh`, `drivers/classify_corpus.sh`). No fenced test was run,
read or decoded outside the gate sweeps, which dispatch every row themselves. The committed evidence carries no
sweep csv: a non-fenced corpus test (SizeOf...Parameter) contains a fenced name as a substring and would trip
the integration fence check.

**VERDICT: ACCEPT WITH FIX.** Every headline number of the implementer reproduces bit for bit. Fresh cases
found **two breaks on legal SV** (pristine-right strict cells moved away from golden; one case left
STRICT_EQUAL). Both are fixed behind their own switches (below). The refinements move no corpus row and no
probe case: the gate results of the verified build equal the implementer's. Deliverable
`/tmp/r11u160.verified.patch` (applies clean on a fresh 75226e07).

## 1. Binaries (built here, `-j 2`, system-deps config; frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/v11u160_bin/pris.bin` | `2aa918616ddb54c5502f85f387b3e4f7` | 75226e07, equal to the brief's pristine md5 |
| `/tmp/v11u160_bin/law.bin` | `7caa76089b0d55ebfe3401b263799570` | 75226e07 + `/tmp/r11u160.patch`, equal to the implementer's `law.bin` |
| `/tmp/v11u160_bin/fix2.bin` | `f55a3087a991864d7f86dcf12b69197b` | + the two refinements (the verified build) |
| `/tmp/v11u160_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the committed comparator |

Sweeps (`tests/sweep.sh --jobs 3`, `drivers/sweep.sh`): `/tmp/v11u160_swP` (pristine), `/tmp/v11u160_swL` (the
implementer's law), `/tmp/v11u160_swF` (verified). cmds.txt audit: 1531 surelog + 1742 uhdm2rtlil `slang:`
lines per sweep, every one naming that sweep's binary (3273 of 3273, three times). Logs without progress lines:
`evidence/sweeps/sweep_{P,L,F}.log`.

## 2. Reproduction of the implementer's numbers

| claim | reproduced |
|---|---|
| probe regressions 0, conversions 18, changes 25 (EQUAL 2514 -> 2532) | yes (`sweep_L.log`) |
| surelog regressions 0, conversions 6 (BlackConst, ComplexParamOverload, MacroArgMismatch d/t), changes 2 (ApbSlave line(29) -> line(26)) | yes |
| uhdm2rtlil regressions 0, conversions 24 (the 12 tests of the report, d/t), changes 8 (arb_idx_cast, ibex_icache, ibex_load_store_unit, ibex_multdiv_fast d/t) | yes |
| downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, csv equal to pristine row by row | yes (`downstream_P_vs_F.diff` empty; L equals P too) |
| byte movers surelog 15, uhdm2rtlil 48 (fenced mirrors, SELFCHECK 951/952 and 1607/1608), probe 89 | yes, same names (`evidence/attribution/v11u160_bv_L_*.txt`, `probe_movers_P_vs_L.txt`) |
| every deterministic corpus mover back to pristine bytes under `R11U160_OFF=1` | yes: replayed with the verified build under `R11U160_OFF=1`, 48/48 uhdm2rtlil and 10/15 surelog byte-equal; the other 5 (SeqDriver d/t, SimpleUVM d/t, Scoreboard d) differ order-blind only by the known 4-line `UINT`/`vpiDecompile` coin or not at all |
| grid 80 cases, STRICT_EQUAL 19 -> 68, all back to pristine bytes under `R11U160_OFF=1` | yes |
| canaries: surelog ok=50 changed=2 (ApbSlave), uhdm2rtlil ok=16; ctcan2 surelog FAIL only on BlackConst's conversion (ok=56 changed=2), uhdm2rtlil PASS | yes (identical on the verified sweep) |
| LogicTypespec: `$bits` of `pkg::t2 [1:0][7:0] x` reads 2 on the Surelog lane, 32 on ours (DIVERGENT) | yes (`connect \w 8'00000010` vs `8'00100000`): a Surelog-defect candidate, correctly not followed |
| r11u161's `law.patch` does not apply on a fresh 75226e07 | yes (ModuleEmit.cpp and TypeEmit.cpp helper-declaration hunks) |

Two README details do not hold, neither affects the landing: the patch carries only `tests/LAWS.md` (the
`tests/LAWS.csv` and `tests/CASES.csv` it names do not exist at this base), and "law index STALE" is read by
the PRISTINE sweep too: `scripts/law_index.py` at a fresh 75226e07 worktree rewrites every abbreviated commit
hash (8 -> 9 characters as the object count grew) and the committed-law count (1064 -> 1077), so the stale
reading is environment, not the pass.

## 3. Breaks found, and the refinements that fix them

Classifier `drivers/unmask.py` (per object, per field): a strict field that pristine had equal to golden and
the build under test does not is a BROKEN cell, unless it sits past the pristine walk's divergence (UNMASK). Its
positive controls read BROKEN (PA/a1 on the unrefined law: 6 cells; GT/z08: 6 hidden full names).

**B1 — the paste run (§ ppMacroBodyLines160, PASTE axis).** slang lays EVERY token written right after a
pasted token with no blank between (`[`, `1`, `]`, `;` of `arr_``n[1];`) at the pasted text's running
offset, which already is Surelog's output column; the unrefined law added the paste's shift (pasted length -
written span) to all of them (only the first one was read from the paste's start). Pristine-right cells moved:
one-line bodies `arr_``n[1]` (PA a1 a2 a9, MM q09, c3) and multi-line bodies (PA b1 b3 c7); **PA/c7
STRICT_EQUAL -> STRICT_NOTEQUAL endcol(12)**. 8 cases, 58 cells. Not caught by any probe case or corpus row.
**§ pasteChainRunning160v** (UhdmExporter.cpp; switch `R11V160_PASTECHAIN_OFF`, and off under `R11U160_OFF` /
`R11U160_PPPASTE_OFF`): the tokens of the blank-free run after a paste read the pasted token's column plus
their distance (on the paste's own definition line only, as the pasted token's end already did); the paste's
shift is for the tokens after the first blank. With a positive shift the run's end can be the very offset the
next blank-led token is written at (`arr_``n[1] = ...` with one more pasted character than written, PA/c3): the
end of a `]` or `)` bounds an object and wins, the end of a `;` or `,` does not and the next token's start
wins. After: all 8 cases STRICT_EQUAL.

**B2 — the whole-assign scan reads uninstantiated generate branches (§ tpCloneWholeLhsBare160).** The scan for
a whole continuous-assignment write of a T-typed signal recursed into every generate block, including a branch
the instance does not take (`if (W) assign d_o = d_i; else assign d_o.x = ...;` at W = 0): golden keeps the
type-parameter names there. GT/z08: pristine 4 differing records, unrefined law 10 (6 member-name cells).
**§ tpWholeLhsInstantiatedOnly160v** (TypeEmit.cpp; switch `R11V160_TPWHOLEUNINST_OFF`): uninstantiated
generate blocks are skipped. After: pristine bytes on z08; z09 (the taken branch) stays converted.

Each refinement is droppable alone: the verified build with both `R11V160_*_OFF` reproduces the unrefined
law's bytes on all 182 cases that write a database; with `R11U160_OFF=1` it reproduces pristine's.

## 4. Gates of the verified build (`/tmp/v11u160_swF`)

| gate | result |
|---|---|
| (1) build | pristine `2aa91861...` (brief's md5); verified `f55a3087...` |
| (2) probe vs golden_probe.csv | regressions 0, conversions 18, changes 25; EQUAL 2532 / STRICT_NOTEQUAL 1555 (csv identical to the unrefined law's) |
| (3) surelog | regressions 0, conversions 6, changes 2 (identical csv to the unrefined law's except the LowMem detail text) |
| (3) uhdm2rtlil | regressions 0, conversions 24, changes 8 (identical csv) |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, csv equal to pristine row by row; pass 120's rows unchanged |
| (5) uhdm-cmp | 0 lines on every touched row (converted rows CMP_EQUAL, changed rows STRICT_NOTEQUAL) and every probe case |
| (6) byte movers | verified vs unrefined law: probe 0, uhdm2rtlil 0, surelog 7 = the UVM family (MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d), each differing order-blind only by the 4-line `UINT`/`vpiDecompile` coin; verified vs pristine: the implementer's 15 + 48 + 89 by name |
| canaries | surelog ok=50 changed=2 (ApbSlave); uhdm2rtlil ok=16 changed=0; ctcan2 surelog ok=56 changed=2 (BlackConst conversion), uhdm2rtlil PASS |

The sweep exits 1 only on "law index STALE" (environment, section 2); the patch carries the regenerated
`tests/LAWS.md`.

**No strict cell worse on any row-mode.** Every probe byte mover (89) classifies CLEAN (77) or UNMASK (12:
the k-series, g8, v30, i11, w1, d01, d02, b3a — the pristine walk diverged before the new records), none BROKEN
(`probe_movers_class_{law,ver}.txt`); the two count growths on the same field (r11u47repro/branches/g8 fullname
3 -> 10, r11v47repro/branches/v30 8 -> 18) are UNMASK (pristine diverged at #21 / #55, the new records start at #23
/ #98). Corpus movers: uhdm2rtlil 46 CLEAN + 2 UNMASK (arb_idx_cast d/t: pristine diverged at #128 / #38);
surelog 15 CLEAN (`*_movers_class_law.txt`). The UVM rows diverge early (#2433-#2496), so they were read
order-blind against golden (`drivers/orderblind.sh`): golden lines shared, pristine -> law, MiniAmiq 1812952 ->
1838478, SeqDriver 1740524 -> 1765423, SimpleUVM 1072176 -> 1086720, Scoreboard 1060093 -> 1074623, ApbSlave
12366 -> 12396 (0 lost). The UVM rows lose 77-110 golden lines that pristine matched by coincidence: every
one is a `uvm_report_*` func_call or its if_stmt at uvm_macros lines 115/132/149/166 whose end column
pristine had shifted by about +20 onto another object's golden column; the law's end-column distribution
for these calls is golden's own (MiniAmiq `uvm_report_error` 149:8: pristine's histogram starts at
149:201, the law's and golden's at 149:181).

## 5. Grid (`cases/`, `drivers/grid4.sh`, `evidence/grid/grid5.txt`)

107 verifier cases (each first line names its law) plus the implementer's 80, five states each: pristine, the
unrefined law, the verified build, `R11U160_OFF=1` (PRISBYTES on all 182 that write a database), both
`R11V160_*_OFF` (LAWBYTES on all 182). STRICT_EQUAL of 187: pristine 34, unrefined law 133, verified 141; a
pristine STRICT_EQUAL case leaves it under the unrefined law once (PA/c7) and under the verified build never.
Classifier pristine -> unrefined law: 168 CLEAN, 4 UNMASK, **9 BROKEN** (PA a1 a2 a9 b1 b3 c3 c7, MM q09, GT
z08); pristine -> verified: 177 CLEAN, 4 UNMASK, 0 BROKEN. Downstream (`drivers/dsrun.sh`, both lanes,
`evidence/downstream/cases_pris_vs_ver.txt`): 187 cases, 121 IDENTICAL -> IDENTICAL, 39 EQUIVALENT ->
IDENTICAL, 2 DIVERGENT -> IDENTICAL (BT/x05, BT/b04), 12 EQUIVALENT and 6 DIVERGENT unchanged in verdict,
none leaves IDENTICAL; the unrefined law's break cases were IDENTICAL on both builds (the breaks are
strict-axis only). With `-DSYNTHESIS` (the downstream lane) a multi-line body's `ifdef SYNTHESIS` /
`ifndef SYNTHESIS` / undefined-name branch (DS d02 d03 d04) goes EQUIVALENT -> IDENTICAL: the model's defined
set includes command-line defines.

Per case: `case | law | pristine / unrefined law / verified strict verdict/records | classifier law / verified
| downstream pristine -> verified`.

| case | law | strict | classifier | downstream |
|---|---|---|---|---|
| BT/x01 | bodyTypeParamDefaultBound160 | pris=NOTEQUAL/3 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| BT/x02 | bodyTypeParamDefaultBound160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | DIVERGENT->DIVERGENT |
| BT/x03 | bodyTypeParamDefaultBound160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | DIVERGENT->DIVERGENT |
| BT/x04 | bodyTypeParamDefaultBound160 | pris=NOTEQUAL/3 law=NOTEQUAL/3 ver=NOTEQUAL/3 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| BT/x05 | bodyTypeParamDefaultBound160 | pris=NOTEQUAL/4 law=NOTEQUAL/14 ver=NOTEQUAL/14 | UNMASK / UNMASK | DIVERGENT->IDENTICAL |
| BT/x06 | bodyTypeParamDefaultBound160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | DIVERGENT->DIVERGENT |
| CP/y01 | implNetBareParamElab160 | pris=NOTEQUAL/2 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| CP/y02 | implNetBareParamElab160 | pris=NOTEQUAL/2 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| CP/y03 | implNetBareParamElab160 | pris=NOTEQUAL/2 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| CP/y04 | implNetBareParamElab160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| CP/y05 | implNetBareParamElab160 | pris=NOTEQUAL/2 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| CP/y06 | implNetBareParamElab160 | pris=NOTEQUAL/1 law=NOTEQUAL/1 ver=NOTEQUAL/1 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| CP/y07 | implNetBareParamElab160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | EQUIVALENT->EQUIVALENT |
| CP/y08 | implNetBareParamElab160 | pris=NOTEQUAL/2 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| CP/y09 | implNetBareParamElab160 | pris=NOTEQUAL/2 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| DS/d02 | ppMacroBodyLines160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| DS/d03 | ppMacroBodyLines160 | pris=NOTEQUAL/20 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| DS/d04 | ppMacroBodyLines160 | pris=NOTEQUAL/34 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| GT/z01 | tpCloneWholeLhsBare160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| GT/z02 | tpCloneWholeLhsBare160 | pris=NOTEQUAL/6 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| GT/z03 | tpCloneWholeLhsBare160 | pris=NOTEQUAL/12 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| GT/z04 | tpCloneWholeLhsBare160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| GT/z05 | tpCloneWholeLhsBare160 | pris=NOTEQUAL/9 law=NOTEQUAL/9 ver=NOTEQUAL/9 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| GT/z06 | tpCloneWholeLhsBare160 | pris=NOTEQUAL/6 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| GT/z07 | tpCloneWholeLhsBare160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| GT/z08 | tpWholeLhsInstantiatedOnly160v | pris=NOTEQUAL/4 law=NOTEQUAL/10 ver=NOTEQUAL/4 | BROKEN / CLEAN | IDENTICAL->IDENTICAL |
| GT/z09 | tpCloneWholeLhsBare160 | pris=NOTEQUAL/10 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MA/o01 | objMacroParenArgsTrimmed160 | pris=SL_FAIL(rc=3) law=SL_FAIL(rc=3) ver=SL_FAIL(rc=3) | - / - | SURELOG_FAIL->SURELOG_FAIL |
| MA/o02 | objMacroParenArgsTrimmed160 | pris=NOTEQUAL/7 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MA/o03 | objMacroParenArgsTrimmed160 | pris=NOTEQUAL/16 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MA/o04 | objMacroParenArgsTrimmed160 | pris=NOTEQUAL/4 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MA/o05 | objMacroParenArgsTrimmed160 | pris=NOTEQUAL/8 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MA/o06 | objMacroParenArgsTrimmed160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | DIVERGENT->DIVERGENT |
| MA/o07 | objMacroParenArgsTrimmed160 | pris=SL_FAIL(rc=3) law=SL_FAIL(rc=3) ver=SL_FAIL(rc=3) | - / - | SURELOG_FAIL->SURELOG_FAIL |
| MA/o08 | objMacroParenArgsTrimmed160 | pris=NOTEQUAL/10 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MA/o09 | objMacroParenArgsTrimmed160 | pris=NOTEQUAL/10 law=NOTEQUAL/10 ver=NOTEQUAL/10 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/p01 | ppMacroBodyLines160 | pris=NOTEQUAL/10 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/p02 | ppMacroBodyLines160 | pris=NOTEQUAL/10 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/p03 | ppMacroBodyLines160 | pris=NOTEQUAL/10 law=NOTEQUAL/10 ver=NOTEQUAL/10 | CLEAN / CLEAN | EQUIVALENT->EQUIVALENT |
| MM/p04 | ppMacroBodyLines160 | pris=NOTEQUAL/10 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/p05 | ppMacroBodyLines160 | pris=NOTEQUAL/16 law=NOTEQUAL/12 ver=NOTEQUAL/12 | CLEAN / CLEAN | EQUIVALENT->EQUIVALENT |
| MM/p06 | ppMacroBodyLines160 | pris=NOTEQUAL/12 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/p07 | ppMacroBodyLines160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/p08 | ppMacroBodyLines160 | pris=NOTEQUAL/6 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/p09 | ppMacroBodyLines160 | pris=NOTEQUAL/10 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/p10 | ppMacroBodyLines160 | pris=NOTEQUAL/16 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/p11 | ppMacroBodyLines160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/p12 | ppMacroBodyLines160 | pris=NOTEQUAL/6 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/p13 | ppMacroBodyLines160 | pris=NOTEQUAL/7 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q01 | ppMacroBodyLines160 | pris=NOTEQUAL/16 law=NOTEQUAL/6 ver=NOTEQUAL/6 | CLEAN / CLEAN | SLANG_REJECT->SLANG_REJECT |
| MM/q02 | ppMacroBodyLines160 | pris=NOTEQUAL/10 law=NOTEQUAL/10 ver=NOTEQUAL/10 | CLEAN / CLEAN | EQUIVALENT->EQUIVALENT |
| MM/q04 | ppMacroBodyLines160 | pris=NOTEQUAL/16 law=NOTEQUAL/16 ver=NOTEQUAL/16 | CLEAN / CLEAN | EQUIVALENT->EQUIVALENT |
| MM/q05 | ppMacroBodyLines160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q06 | ppMacroBodyLines160 | pris=NOTEQUAL/10 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q07 | ppMacroBodyLines160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q08 | ppMacroBodyLines160 | pris=NOTEQUAL/1 law=NOTEQUAL/1 ver=NOTEQUAL/1 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q09 | pasteChainRunning160v | pris=NOTEQUAL/8 law=NOTEQUAL/6 ver=EQUAL/0 | BROKEN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q11 | ppMacroBodyLines160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | DIVERGENT->DIVERGENT |
| MM/q13 | ppMacroBodyLines160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q15 | ppMacroBodyLines160 | pris=NOTEQUAL/6 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q16 | ppMacroBodyLines160 | pris=NOTEQUAL/12 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q17 | ppMacroBodyLines160 | pris=NOTEQUAL/6 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q18 | ppMacroBodyLines160 | pris=NOTEQUAL/6 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q20 | ppMacroBodyLines160 | pris=NOTEQUAL/8 law=NOTEQUAL/8 ver=NOTEQUAL/8 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q21 | ppMacroBodyLines160 | pris=NOTEQUAL/4 law=NOTEQUAL/4 ver=NOTEQUAL/4 | CLEAN / CLEAN | EQUIVALENT->EQUIVALENT |
| MM/q22 | ppMacroBodyLines160 | pris=NOTEQUAL/4 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/q23 | ppMacroBodyLines160 | pris=SL_FAIL(rc=0) law=SL_FAIL(rc=0) ver=SL_FAIL(rc=0) | - / - | SURELOG_FAIL->SURELOG_FAIL |
| MM/q24 | ppMacroBodyLines160 | pris=NOTEQUAL/10 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| MM/q25 | ppMacroBodyLines160 | pris=NOTEQUAL/8 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/r01 | ppMacroBodyLines160 | pris=NOTEQUAL/6 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/r02 | ppMacroBodyLines160 | pris=NOTEQUAL/10 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/r03 | ppMacroBodyLines160 | pris=NOTEQUAL/20 law=NOTEQUAL/12 ver=NOTEQUAL/12 | CLEAN / CLEAN | EQUIVALENT->EQUIVALENT |
| MM/r05 | ppMacroBodyLines160 | pris=NOTEQUAL/8 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| MM/r06 | ppMacroBodyLines160 | pris=NOTEQUAL/6 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| PA/a1 | pasteChainRunning160v | pris=NOTEQUAL/8 law=NOTEQUAL/6 ver=EQUAL/0 | BROKEN / CLEAN | IDENTICAL->IDENTICAL |
| PA/a2 | pasteChainRunning160v | pris=NOTEQUAL/8 law=NOTEQUAL/6 ver=EQUAL/0 | BROKEN / CLEAN | IDENTICAL->IDENTICAL |
| PA/a3 | ppMacroBodyLines160 | pris=NOTEQUAL/14 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| PA/a4 | ppMacroBodyLines160 | pris=NOTEQUAL/8 law=NOTEQUAL/8 ver=NOTEQUAL/8 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| PA/a5 | ppMacroBodyLines160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| PA/a6 | ppMacroBodyLines160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| PA/a7 | ppMacroBodyLines160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| PA/a8 | ppMacroBodyLines160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| PA/a9 | pasteChainRunning160v | pris=NOTEQUAL/14 law=NOTEQUAL/4 ver=EQUAL/0 | BROKEN / CLEAN | EQUIVALENT->IDENTICAL |
| PA/b1 | pasteChainRunning160v | pris=NOTEQUAL/6 law=NOTEQUAL/10 ver=EQUAL/0 | BROKEN / CLEAN | EQUIVALENT->IDENTICAL |
| PA/b2 | ppMacroBodyLines160 | pris=NOTEQUAL/16 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| PA/b3 | pasteChainRunning160v | pris=NOTEQUAL/6 law=NOTEQUAL/10 ver=EQUAL/0 | BROKEN / CLEAN | EQUIVALENT->IDENTICAL |
| PA/c1 | ppMacroBodyLines160 | pris=NOTEQUAL/7 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| PA/c2 | ppMacroBodyLines160 | pris=NOTEQUAL/12 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| PA/c3 | pasteChainRunning160v | pris=NOTEQUAL/18 law=NOTEQUAL/4 ver=EQUAL/0 | BROKEN / CLEAN | IDENTICAL->IDENTICAL |
| PA/c4 | ppMacroBodyLines160 | pris=NOTEQUAL/1 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| PA/c5 | ppMacroBodyLines160 | pris=NOTEQUAL/11 law=NOTEQUAL/7 ver=NOTEQUAL/7 | CLEAN / CLEAN | EQUIVALENT->EQUIVALENT |
| PA/c6 | ppMacroBodyLines160 | pris=NOTEQUAL/12 law=NOTEQUAL/4 ver=NOTEQUAL/4 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| PA/c7 | pasteChainRunning160v | pris=EQUAL/0 law=NOTEQUAL/12 ver=EQUAL/0 | BROKEN / CLEAN | IDENTICAL->IDENTICAL |
| TV/w01 | defNetTypeParamPackedVec160 | pris=NOTEQUAL/3 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| TV/w02 | defNetTypeParamPackedVec160 | pris=NOTEQUAL/3 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| TV/w03 | defNetTypeParamPackedVec160 | pris=NOTEQUAL/5 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| TV/w04 | tpUseBindsDefDefault160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| TV/w05 | tpUseBindsDefDefault160 | pris=NOTEQUAL/3 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| TV/w06 | tpUseBindsDefDefault160 | pris=NOTEQUAL/12 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| TV/w07 | tpUseBindsDefDefault160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| TV/w08 | tpUseBindsDefDefault160 | pris=NOTEQUAL/4 law=NOTEQUAL/4 ver=NOTEQUAL/4 | CLEAN / CLEAN | EQUIVALENT->EQUIVALENT |
| TV/w09 | tpUseBindsDefDefault160 | pris=NOTEQUAL/3 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| TV/w10 | tpUseBindsDefDefault160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| TV/w11 | tpUseBindsDefDefault160 | pris=NOTEQUAL/18 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |
| TV/w12 | tpUseBindsDefDefault160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | EQUIVALENT->IDENTICAL |
| TV/w13 | tpUseBindsDefDefault160 | pris=CMP_NOTEQUAL law=CMP_NOTEQUAL ver=CMP_NOTEQUAL | CLEAN / CLEAN | EQUIVALENT->EQUIVALENT |
| TV/w14 | tpUseBindsDefDefault160 | pris=EQUAL/0 law=EQUAL/0 ver=EQUAL/0 | CLEAN / CLEAN | IDENTICAL->IDENTICAL |

Probed and holding (no break): `ifdef`/`elsif`/`else` nesting, `undef` before the call, CRLF bodies, a blank
continuation line, a nested call in an inactive branch, an object-like multi-line body, two calls on one line,
text before a call with the definition in an include (not modelled: file differs), `__LINE__` in a one-line
and a multi-line body, stringification in a nested call, `` `F  (  (16)  ) `` and a defined-but-whitespace
object macro, a bare parameter read twice onto two implicit nets and read by two instances, a vector default
bound through an overridden width (`logic [W-1:0]` at W = 4: golden binds the definition's default too),
positional type overrides, a `$unit` typedef shadowed by a module typedef of the same name, a generate-scope
`localparam type` shadowing a header type parameter.

## 6. Residues (ranked)

1. The implementer's residues stand as reported (tools/probe/r11u160repro/README.md section 6): Earlgrey_0_1,
   GenerateUnnamed (partly decoded, site ModuleEmit emitGates), ClassTypeParam, the rest of the ibex family,
   the bare `localparam type` struct written procedurally (BT b03 b04, BT/x05: member names through the last
   net), the 2-state / enum vector default, stringify bodies with their own text, and the sister-ground faces
   (the spaced based literal in ExprEmit/StmtEmit/ParamEmit, UnionCast's value text, SimpleConstraint's
   randomize span, const_cast_signext's makeParamTs copies, `$signed`'s span).
2. The paste run with a shift of two or more: a blank-led token's written offset can fall inside the run
   (not only at its end); such offsets stay with the written layout. No case in the corpora or the probe set
   moves on it.
3. A macro defined after its use (MM/p03): the model's defined set is the end-of-file set, so an `ifdef` on it
   reads active; golden drops the branch. Unmoved (pristine bytes), not a break.
4. A pasted token followed by a multi-token run in a one-line body with a stringified formal (MM q08, q20,
   q21): unmoved, pre-existing columns.
5. The prediction gap the implementer stated stands: the census was written after the development sweeps.

## 7. Files

`cases/<dir>/<case>/dut.sv` (107; `// § <law>` first line; DS = the downstream `-DSYNTHESIS` cases), `drivers/`
(`grid4.sh` five states per case, `unmask.py` the broken-cell classifier, `dsrun.sh`/`ds1.sh` the downstream
lanes on one case, `mirror.sh` the fenced hard-link mirror for byteverify, `classify_corpus.sh` /
`classify_probe.sh`, `orderblind.sh`, `sweep.sh`, `env.sh`), `evidence/` (`grid/`, `sweeps/` the three
sweep logs and the downstream diff, `attribution/` byteverify outputs and mover classifications,
`downstream/`).
