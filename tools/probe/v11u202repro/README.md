# v11u202: adversarial verification of r11u202 (the module/type ground, pair B): every headline number reproduced; the r11u200 laws' two AWAY faces map 12 named (the packed-port span on a bare implicit port, the class-typedef return variable's span and file) and three new breaks (a line comment before an implicit type's break, a CRLF break, the definition view of a multi-argument value specialization) refined under R11V202_* switches

Base `ddc67d87` (branch matrix-1.87). Implementer's patch: `/tmp/r11u202.patch` (its README:
[../r11u202repro/README.md](../r11u202repro/README.md)). **Verdict: ACCEPT-WITH-FIX** — `/tmp/r11u202.verified.patch` =
r11u202's patch + five refinements (`src/ModuleEmit.cpp`, `src/TaskFuncEmit.cpp`, `src/TypeEmit.cpp`,
`src/UhdmExporter.cpp`) + this directory + the regenerated `tests/LAWS.md`. Nothing under `results/`, `tests/probe/`,
`third_party/`, `scripts/` or the sister ground's files (`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`,
`src/ParamEmit.cpp`) is edited.

**The fence.** The four fenced names are read fail-closed from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` (`drivers/env.sh`, every driver sources it); the byte comparisons ran on
hard-link mirrors that leave the 8 fenced row-mode databases out (`fenced_skipped=8`, `drivers/mirror.sh`); the
firing census ran the corpora with `--filter` built from the fence (`drivers/census.sh`). No fenced source or database
was run, read, dumped or decoded outside the gate sweeps; the only fenced facts cited are the sweeps' csv verdicts
(none moved). No gdb was used.

## 1. Binaries (frozen `chmod 555` in `/tmp/v11u202_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `18183f058868a85659208c85a099980e` | worktree `/tmp/wt_v11u202pris` at `ddc67d87`, system deps, `-j 2`: = the main tree's `build/slang-uhdm` |
| `law.bin` | `8214d7927295a3b3eefe3ee87df53cbd` | `ddc67d87` + `/tmp/r11u202.patch` (applies clean), `-j 1`: = the implementer's law binary `d6.bin` |
| `v1.bin` | `1d83fbd8622b633335f53ea81c904e35` | law + the first four refinements (development build) |
| **`v2.bin`** | `0fedefadeeb3ad6fb3ca55778b5755da` | **law + the five refinements (the delivered sources)** |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

Every `cmds.txt` of the three gate sweeps names its own binary: `sP` 3273 of 3273 `pris.bin`, `sL` 3273 `law.bin`, `sV`
3273 `v2.bin` ([evidence/sweeps/canaries_and_audit.txt](evidence/sweeps/canaries_and_audit.txt)).

## 2. The implementer's numbers, reproduced bit for bit

All from my own builds and sweeps (`tests/sweep.sh --jobs 3`, run from the pristine worktree so `law_index.py --check`
passes; workdirs `/tmp/v11u202_sP`, `/tmp/v11u202_sL`, `/tmp/v11u202_sV`, same length):

| claim | reproduced |
|---|---|
| law binary md5 `8214d792…` | yes |
| pristine sweep `0 / 0 / 0` everywhere, probe 3345 / 742 | yes ([evidence/sweeps/sweep_sP.txt](evidence/sweeps/sweep_sP.txt)) |
| probe `regressions=0 conversions=14 changes=13` (EQUAL 3359 / 728) | yes, the same 14 + 13 case names ([sweep_sL.txt](evidence/sweeps/sweep_sL.txt)) |
| surelog `regressions=0 conversions=2 changes=18` | yes |
| uhdm2rtlil `regressions=0 conversions=2 changes=0` | yes |
| downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | yes; `downstream.csv` **byte-identical to `results/downstream_uhdm2rtlil.csv`** |
| byteverify `MOVERS: 22 / 2560`, SELFCHECK 2559 / 2560 | yes ([byteverify_law_vs_pristine.txt](evidence/sweeps/byteverify_law_vs_pristine.txt)) |
| 22 of 22 movers predicted by name (123 predicted row-modes) | yes, against its frozen `evidence/census/predicted_movers.txt` |
| grids: own 84 cases 7 -> 63 EQUAL; r11u200dec 88 cases 20 -> 60 | yes: 27 -> 123 on the 172 together ([evidence/grids/grid_r11u202_r11u200dec_pris_law_v2.txt](evidence/grids/grid_r11u202_r11u200dec_pris_law_v2.txt)) |
| class-listing composition: neither 2, pass 196 alone 15, r11u200 alone 11, both 15 (both = 196 byte for byte) of 24 | yes (r11u200 alone read as the law binary with every `R11U202_<LAW>_OFF` set; [compose_classlisting_remeasured.tsv](evidence/grids/compose_classlisting_remeasured.tsv)); the law binary reads 19 |
| `R11U202_OFF=1` = pristine bytes on all 4087 probe databases | yes, on `v2.bin` too (0 of 4087 differ; its `probe.csv` = `results/golden_probe.csv`) |
| UVM strict-record distance 6886->6789, 5472->5380, 2312->2228, 1736->1653, 954->852 | yes ([evidence/away/away_law_vs_pristine.txt](evidence/away/away_law_vs_pristine.txt)) |
| UVM first records unchanged (MiniAmiq #899, SeqDriver #5387, SimpleUVM #458, Scoreboard #466, BuildUVMPkg #3245) | yes, on `v2.bin` too |
| canaries surelog `ok=37 changed=15`, uhdm2rtlil `ok=16`, ctcan2 PASS both | yes |

## 3. The breaks (legal SV, pristine right, patched wrong)

The strict gate cannot see any of them: the rows stay STRICT_NOTEQUAL (or the comparator canonicalises the field),
so the order-blind census is the instrument: strict records or `uhdm-dump` lines as multisets, ids and paths
stripped; a LOST record is one golden and PRISTINE share that the patched database no longer has
(`drivers/away.py`, `drivers/ob.py`, `drivers/awaycorp.sh`, `drivers/obcorp.sh`).

**The law binary loses 74 corpus records that pristine had right** (exactly map 12's count, `tools/probe/r11u203map`
section 4, which asked pair B to refine both laws when landing them; the implementer's patch carries them unrefined):
[evidence/away/away_law_lost_records.txt](evidence/away/away_law_lost_records.txt).

| # | face | law | where | golden (= pristine) | law |
|---|---|---|---|---|---|
| B1 | a port written with NO keyword before its packed dimensions (`input [NAlerts-1:0] [CLASS_DW-1:0] alert_class_i`) | § defPortPackedTsKeepsWholeSpan200 | Earlgrey_0_1 d/t 4 records each (alert_handler_class.sv 15, 16; alert_handler_esc_timer.sv 30, 32); **the row's new first record `#89859 endcol` (`endcol(80)`) IS one of them**; cases PP/p01 p04 p08 p09 | first-dimension end 15:9-15:22 | 15:9-15:40 |
| B2 | the return VARIABLE of a function returning a class typedef written qualified (`function uvm_resource_types::rsrc_q_t lookup_name(...)`) | § classTdRetSharesTypedefTs200 | BuildUVMPkg d/t 5, MiniAmiq, SeqDriver, SimpleUVM d/t, Scoreboard d 6 each; case TR/q02 | the written type 16092:12-16092:40 | the typedef's 15203:11-15203:20 |
| B3 | the late-bound `ref_var` return of `static function this_type get();` when the specialization's typedef sits in another file | the same (the law's `setLoc` keeps the `VpiFile` `copyLoc` wrote) | uvm_callback.svh 507, uvm_pool.svh 61: 2 per UVM row-mode; case TR/q05 (two headers) | file uvm_callback.svh | file uvm_heartbeat.svh (the typedef's) |

**Three more breaks found by fresh cases** ([evidence/grids/grid_own_pris_law_v2.txt](evidence/grids/grid_own_pris_law_v2.txt)):

| # | face | law | case | golden | law |
|---|---|---|---|---|---|
| B4 | an implicit port type whose trivia holds a `//` comment before the line break (`input // c` / `    c;`) | § implicitTsEndCrossesLineBreak200 | IE/l02: 3 objects LOST (pristine had them right) | 8:5-8:5 (Surelog's One_line_comment token owns the newline, so the whitespace token starts on the name's line) | 8:5-7:29 |
| B5 | the definition view of a module / program variable written as an unscoped specialization with TWO or more ordered value arguments (`c #(8, 9) k;`, `c #(1, 2, 3) h;`) | § modSpecValueArgSpanAtName202 | VA/a01, a04-a07: 2-4 LOST dump lines each (strict-invisible: typespec copy spans are canonicalised, the MG/m09 blind spot r11u202 itself met) | definition view the whole `c #(8, 9)` 6:3-6:12, elaborated view and weakly-referenced copy the name 6:3-6:4; ONE value argument (`c #(8) h`) the name in every view | the name in every view |
| B6 | (not a regression, both wrong) a CRLF file: the implicit-type end counted the `\r` | § implicitTsEndCrossesLineBreak200 | IE/l03 | 2:23 | 2:24 (pristine 3:5, `endline`) |

No other fresh case moved a record away from golden (51 cases, 11 families: [section 5](#5-the-fresh-grid)); the one
multiset LOST pair left (UT/x08) is an artefact: golden lists the `$unit` typedef `m_b` as `m_a`'s specialization and its
param_assign LHS formal is located where ours has no distinct LHS object; pristine's located RHS matched it by
coincidence (both binaries NOT_EQUAL at stage 1).

## 4. The refinements (each behind its own switch; `R11V202_OFF` drops all five, `R11U202_OFF` drops them with the rest of the pass)

| switch | law | site | rule |
|---|---|---|---|
| `R11V202_PORTIMPL_OFF` | § portPackedBareImplicitTruncates202v | ModuleEmit.cpp `materializeDefNetTs` (the port fence of § defPortPackedTsKeepsWholeSpan200) and `portPackedBareImplicit202v` | a port whose type syntax is an ImplicitType with no signing token under a port header with no net type and no `var` keyword keeps the first-dimension end (the net rule). `input wire [..][..]` (PP/p02), `input logic [..][..]` and `input signed / unsigned [..][..]` (p03, p08, p09: golden spans the signing keyword alone, the law's shape) keep the law. |
| `R11V202_TDRETVAR_OFF` | § classTdRetVarKeepsWrittenLoc202v | TaskFuncEmit.cpp, the return variable after `copyLoc(rv, ts)` | every return variable of a return bound by § classTdRetSharesTypedefTs200 (class_var and ref_var) takes the WRITTEN return type's span and file (the file cleared before `setLoc`, which keeps an existing one): golden's compileVariable populates the variable at its own Data_type node, only the typespec is the typedef's. |
| `R11V202_IMPLCMT_OFF` | § implicitTsEndAfterLineComment202v | TypeEmit.cpp, the § implicitTsEndCrossesLineBreak200 scan | when the line holding the start of the whitespace run carries a `//` comment, the comment owns the first newline: the whitespace token starts after it, and moves the end only if a further newline follows (a blank line). A `/* */` comment keeps the law (IE/l02 `output /* comment */` golden 6:5-5:28, the law's). |
| `R11V202_IMPLCR_OFF` | § implicitTsEndSkipsCarriageReturn202v | the same scan | a `\r` in the trivia is not counted (Surelog's preprocessed text carries no `\r`). |
| `R11V202_VALSPECDEF_OFF` | § modSpecValueArgDefViewMultiArg202v | TypeEmit.cpp `makeTypespec`, the § modSpecValueArgSpanAtName202 site | in the definition view (`moduleDefEmit`) a written list of two or more ordered arguments keeps the whole text; one argument, and every elaborated view, keep the law. |

Every refinement traces its firings under `R11U202_TRACE`. **Switch checks** ([evidence/switches/switches_alone.txt](evidence/switches/switches_alone.txt),
`drivers/switches.sh`, 223 cases = my 51 + r11u202's 84 + r11u200dec's 88): `R11V202_OFF=1` on `v2.bin` writes the
law binary's bytes on 223 of 223 and on all 4087 probe databases (`check_probe.py` rerun, 0 differ, `probe.csv` = the law
sweep's); `R11U202_OFF=1` writes the pristine bytes on 223 of 223 and on all 4087 probe databases; each switch alone
moves only cases whose plain run traced that switch's own law (13 moves, `bad=0`).

## 5. The fresh grid

`cases/` (51 cases, each naming its law on its first line; goldens from the pinned Surelog; `drivers/case.sh` judges a
case as `check_probe.py` does, `BINS="pris law v2"`): EQUAL **pristine 2, law 16, v2 18**; no case leaves EQUAL; the
order-blind dump census reads LOST 0 under `v2.bin` on every case but the UT/x08 artefact.

| family | cases | law(s) attacked | result |
|---|---|---|---|
| PP | p01-p11 | § defPortPackedTsKeepsWholeSpan200 on bare / `wire` / `tri` / `signed` / `unsigned` / `var` / `bit` / `reg` / non-ANSI / redeclared / interface / program ports | B1 (p01 p04 p08 p09); p02 p03 convert with the law; p05 NOT_EQUAL in all binaries (`var` / `bit` ports, stage 1); p06 p07 p10 p11 unmoved |
| TR | q01-q05 | § classTdRetSharesTypedefTs200: `K::T` returns (in-class, extern + out-of-block, inherited), `this_type` across two headers | B2 (q02), B3 (q05); q02 NOT_EQUAL -> `line` (law) -> `name` (v2: the extern prototype and `other()` returns are not bound to the typedef, an under-reach) |
| IE | l01-l04 | § implicitTsEndCrossesLineBreak200: parameters, tabs, `//` and `/* */` comments, CRLF, signed / dimensioned implicit ports, a body parameter | B4 (l02), B6 (l03); l01 converts with the law; l02 l03 convert with v2 |
| VA | a01-a07 | § modSpecValueArgSpanAtName202: 1 / 2 / 3 ordered and named arguments, parameter-valued arguments, interface / program / generate homes, a function local | B5 (a01 a04-a07); a05 a06 a07 read STRICT_EQUAL in both law and v2 (the comparator canonicalises the spans: the dump census is the judge) |
| UT | x01-x04, x06-x08 | § unitClassTdSpecAtName202, § unitClassTdEndAtInit202, § classSpecExprArgUnlocated202: interface / program / generate-block / function-local / multi-declarator / cross-module writers, `#()` and named arguments, identifier arguments naming an imported class and a scalar typedef | x04 converts; x01 x02 improve to `endline` (UNDER-reach, residue V1); the rest NOT_EQUAL in all binaries |
| CV | v01-v04 | § classValueParamIntSigned202: `int signed` / `int unsigned` / keyword-less / `localparam` / body `parameter`, other integer atoms, a module-local class, negative defaults | v03 converts; v01 v02 v04 NOT_EQUAL in all (parameter order, other atoms: pre-existing) |
| NP | n01-n03 | § modPkgGenericSpecNamedBare202 in interface / program / generate / function homes, spaced `p :: b`, two declarators | n01 n03 convert; n02 NOT_EQUAL (a function-local class variable, rc 4 pre-existing) |
| GV | g01-g04 | § genVarInitOuterRefUnbound202, § defGenInitBitSelAtIndex202: part / parameter / nested selects, concatenations, calls, `$signed`, nested generate scopes, gen-for and gen-case | g02 g04 convert; g01 g03 NOT_EQUAL in all (a call argument's ref_typespec, a sized constant: pre-existing) |
| SG | s01 s02 | § tfSigningSpanFollowsCompilePath200: packed signed returns and formals, `ref` / `output` formals, extern methods, a DPI import | s01 converts; s02 EQUAL in all |
| PQ | q01 q02 | § posOpConnKeepsRefModule200: concatenation / parenthesised / conditional / literal / system-call first terminals, empty terminals | q02 converts (1100 cmp lines -> EQUAL); q01 NOT_EQUAL 594 -> 60 cmp lines |
| IA | i01 i02 | § ifaceArrPortElemViewNamedByArray200: a net member in the modport, a program and a module on one array | NOT_EQUAL in all (pre-existing stage 1) |

**Downstream** (the gate's own `one()`, `drivers/ds.py`, [evidence/downstream/cases.txt](evidence/downstream/cases.txt)): all
51 cases read the same verdict under `pris.bin` and `v2.bin`: 41 IDENTICAL, 9 EQUIVALENT, 1 DIVERGENT (PP/p05, `input var`
/ `input bit` packed ports driving an `always_comb`: 12 gates against golden's 1, pre-existing, residue V6); no case
leaves IDENTICAL.

## 6. The gates of the delivered binary (`v2.bin`, sweep `/tmp/v11u202_sV`)

| gate | result |
|---|---|
| (1) build | `v2.bin` `0fedefad…`; the verified patch applied to a FRESH `ddc67d87` worktree builds to the same md5 (section 8) |
| (2) probe vs `results/golden_probe.csv` | **`regressions=0 conversions=14 changes=13`**, EQUAL 3359 / 728; every probe database byte-identical to the law sweep's (0 of 4087) |
| (3) surelog vs `results/golden_surelog.csv` | **`regressions=0 conversions=2 changes=18`** |
| (3) uhdm2rtlil vs `results/golden_uhdm2rtlil.csv` | **`regressions=0 conversions=2 changes=0`** |
| (4) downstream | **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; `downstream.csv` byte-identical to `results/downstream_uhdm2rtlil.csv`** |
| (5) uhdm-cmp | **0 lines on all 22 movers** ([evidence/sweeps/uhdmcmp_v2_movers.txt](evidence/sweeps/uhdmcmp_v2_movers.txt)) |
| (6) byteverify vs pristine | `MOVERS: 22 / 2560`, PATH_SETS_IDENTICAL, SELFCHECK 2559 / 2560; the same 22 row-modes as the law binary; **22 of 22 predicted** (r11u202's frozen census plus mine) |
| (6) byteverify vs the law binary | `MOVERS: 11 / 2560` (BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM d/t, Scoreboard d, Earlgrey_0_1 d/t); **11 of 11 predicted by name** in [evidence/census/predicted_movers_v202.txt](evidence/census/predicted_movers_v202.txt) (frozen `chmod 444` at [frozen_at.txt](evidence/census/frozen_at.txt), before the `v2.bin` sweep started; 40 row-modes and 6 probe cases predicted, 29 + 6 did not move: the port trace fires on every bare implicit packed port, one-dimensional ones included) |
| canaries | surelog `ok=37 changed=15` (the conversion and change rows), uhdm2rtlil `ok=16 changed=0`; ctcan2 `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS |

**The four row-mode conversions** (fresh rows of `/tmp/v11u202_sV`, NOT written to `results/`):

    ClassTypeParam,default,CMP_EQUAL,,,equal     was differ:endline(17)
    ClassTypeParam,testflags,CMP_EQUAL,,,equal   was differ:file(30)
    int_types,default,CMP_EQUAL,,,equal          was differ:fullname(82)   (uhdm2rtlil)
    int_types,testflags,CMP_EQUAL,,,equal        was differ:fullname(82)   (uhdm2rtlil)

**The strict column, law vs v2, row by row** (the only csv lines that differ between `sL` and `sV`, besides the two
LowMem path strings): `Earlgrey_0_1,default|testflags` `differ:endcol(80)` (law) -> **`differ:fullname(76)`** (v2; pristine
`differ:fullname(82)`): the first record is pristine's `#90097` again (the pass-195 residue Q, the sister ground's
emitSyntaxExpr), the AWAY record B1 is gone, 6 objects fewer than pristine (the port law's gains on ports written with
`logic`). Every other row's strict cell equals the law binary's; the probe csvs are identical.

**AWAY census of the 22 movers under `v2.bin`** ([evidence/away/away_v2_vs_pristine.txt](evidence/away/away_v2_vs_pristine.txt),
strict records; the raw dump census in [evidence/away/obcorp.txt](evidence/away/obcorp.txt)): **LOST 0 on every row-mode**;
distances (strict records ours-not-in-golden) pristine -> law -> v2:

| row-mode | pristine | law | v2 |
|---|---|---|---|
| MiniAmiq d/t | 6886 | 6789 (lost 8) | **6781** (lost 0) |
| SeqDriver d/t | 5472 | 5380 (lost 8) | **5372** |
| SimpleUVM d/t | 2312 | 2228 (lost 8) | **2220** |
| Scoreboard d | 1736 | 1653 (lost 8) | **1645** |
| BuildUVMPkg d/t | 954 | 852 (lost 5) | **847** |
| Earlgrey_0_1 d / t | 4607 / 4301 | 4603 / 4297 (lost 4) | **4599 / 4293** |
| ClassTypeParam d / t, Rggen d, Scr1SvTests d/t, SVSwitch d/t, UnitElabBlock d/t, int_types d/t | | | as the law binary (lost 0) |

The raw `uhdm-dump` census reads LOST 0 under `v2.bin` on 20 of the 22 movers (the law binary: 10-16 on the UVM rows and
Earlgrey); SVSwitch d/t read `lost=2` under BOTH binaries, one bare `|vpiParent:` and one bare `|vpiActual:` line (the
census strips indentation): the io_decl of § ifaceArrPortElemViewNamedByArray200 now binds the element's own variable
where pristine minted a logic_net under it, a line-count artefact of the generic lines (the strict records read LOST 0
and the row's count falls 13 -> 2).

## 7. Determinism (`drivers/det.sh` + `drivers/detob.sh`: three concurrent runs per binary per row-mode)

[evidence/determinism/](evidence/determinism/): Earlgrey_0_1 d/t one database per mode per binary (`pris.bin`,
`v2.bin`). Every multi-hash UVM draw of `pris.bin` and of `v2.bin` reads 0 order-blind dump lines, with ONE exception:
one `v2.bin` draw of BuildUVMPkg default (of 3) lacks one object of the **weaklyReferenced** tail, a
`class_typespec this_type` 13776:11-13776:42 of `uvm_abstract_component_registry` (4 dump lines; the design tree
identical). The object is minted by § classTdRetSharesTypedefTs200's `makeTypespec` call on the return
(`law.bin` and `v2.bin` list 19 such objects, `pris.bin` 18); my refinements create no object. It is unreachable to
uhdm-cmp, to the strict walk and to the plugin (not a downstream row). 15 further draws per binary
([evidence/determinism/buvm_draws.txt](evidence/determinism/buvm_draws.txt)): `pris.bin` 18 in 15 of 15, `law.bin` 19 in
15 of 15, `v2.bin` 19 in 15 of 15: the missing draw is rare (1 of 18 `v2.bin` draws, 0 of 15 `law.bin` draws observed;
the code path is the law binary's). Residue V2.

## 8. Files

* `cases/` (51): PP (§ portPackedBareImplicitTruncates202v, § defPortPackedTsKeepsWholeSpan200), TR
  (§ classTdRetVarKeepsWrittenLoc202v, § classTdRetSharesTypedefTs200), IE (§ implicitTsEndAfterLineComment202v,
  § implicitTsEndSkipsCarriageReturn202v, § implicitTsEndCrossesLineBreak200), VA (§ modSpecValueArgDefViewMultiArg202v,
  § modSpecValueArgSpanAtName202), UT (§ unitClassTdEndAtInit202, § unitClassTdSpecAtName202,
  § classSpecExprArgUnlocated202), CV (§ classValueParamIntSigned202), NP (§ modPkgGenericSpecNamedBare202), GV
  (§ genVarInitOuterRefUnbound202, § defGenInitBitSelAtIndex202), SG (§ tfSigningSpanFollowsCompilePath200), PQ
  (§ posOpConnKeepsRefModule200), IA (§ ifaceArrPortElemViewNamedByArray200). Every case names its law on line 1.
* `drivers/`: `env.sh` (pins + fence; the corpora resolve from the checkout that owns the git dir, since a worktree's
  submodule dirs are empty), `case.sh`, `away.py`, `ob.py`, `awaycorp.sh`, `obcorp.sh`, `mirror.sh`, `census.sh` +
  `censum.py` (the prediction), `switches.sh`, `rowrun.sh` + `det.sh` + `detob.sh` (determinism), `ds.py` (downstream
  `one()` on cases).
* `evidence/`: `sweeps/` (the three sweep summaries, byteverify law/v2 vs pristine and v2 vs law, uhdm-cmp on the
  movers, canaries and the binary audit), `away/` (the law binary's 74 LOST records, the v2 census, the raw dump
  census), `census/`, `grids/` (my grid, r11u202's and r11u200dec's grids under the three binaries, the composition),
  `switches/`, `determinism/`, `downstream/`.

## 9. Residues, ranked

Ground B (this pass's ground) unless named otherwise; r11u202's own residue list (its README section 7) stands, with
these additions:

1. **V1 — § unitClassTdEndAtInit202 under-reach**: an INTERFACE or PROGRAM variable of the `$unit` class typedef with an
   initializer moves the typedef's end in golden too (UT/x01 `interface ifc; m_misc a = new;` golden 5:9-7:17, ours
   5:9-5:12); the law walks module definitions only. The writer order across kinds is not gridded. UhdmExporter, the
   law's site.
2. **V2 — the weakly-referenced `this_type` draw** (section 7): § classTdRetSharesTypedefTs200's minted return typespec
   sometimes missing from the weaklyReferenced tail on BuildUVMPkg default; reader-invisible; TaskFuncEmit, the
   law's `makeTypespec` call.
3. **V3 — the value specialization's ELABORATED view with named arguments** (VA/a05 `c #(.W(8)) j;`: golden 7:3-7:4 in
   the elaborated view, ours the whole text in every view; pristine the same): § modSpecValueArgSpanAtName202 reads
   ordered arguments only.
4. **V4 — § classTdRetSharesTypedefTs200 under-reach on an extern prototype and a line-split return** (TR/q02: golden
   binds `q_t` on the prototype `extern function K::q_t lookup` and on `function K::q_t\n other()`; ours an anonymous
   class_typespec: `name(3)`).
5. **V5 — a generate-block class variable of a value specialization** (VA/a04 `if (1) begin : g c #(3) q; end`) is not
   listed in ours (stage 1, pristine the same).
6. **V6 — PP/p05** (`input var [N-1:0][3:0] a, input bit [N-1:0][3:0] b` into an `always_comb`): NOT_EQUAL at stage 1 and
   DIVERGENT downstream (12 gates against 1) in every binary; not decoded (ModuleEmit, the port / process emission).
7. **V7 — GV/g01**: a call argument inside an elaborated generate-variable initializer keeps a ref_typespec golden does
   not write (the § genVarInitOuterRefUnbound202 walk descends operations only).
8. The sister-ground faces r11u202 recorded (UnitElabBlock's implicit-net file in ExprEmit's `vlogHiddenBlockVars` branch,
   § implicitNetMintNoFile131; SVSwitch's `new[]` names; Scr1SvTests' bound half in ParamEmit; the UVM first records of
   SeqDriver / BuildUVMPkg in ExprEmit and SimpleUVM / Scoreboard in ParamEmit) are unchanged by the refinements.
