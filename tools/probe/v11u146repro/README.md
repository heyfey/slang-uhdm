# v11u146: adversarial verification of r11u146 (the module/type ground on the strict axis)

Base `b2199096` (branch matrix-1.87). Implementer's patch `r11u146` (16 laws, r11u148's three sharing-class
laws included). Verdict: **ACCEPT-WITH-FIX**. Every headline number of the implementer reproduces bit for
bit. Three faces where the patch moved a pristine-right cell away from golden on legal SV were found by
fresh cases (none occurs in the gate: no probe case, corpus row or downstream row moves). They are
refined under three new switches (`R11V146_*_OFF`) in the implementer's files. The refined binary equals
the implementer's on every gate byte (except the known UVM order coins).

The slang-fenced tests are written `FENCED=` here. Every driver that reads corpus databases refuses to run
without `$FENCED` and skips those names.

## 1. Binaries (frozen `chmod 555` before any measurement; every `cmds.txt` audited by path)

| binary | md5 | what |
|---|---|---|
| `/tmp/v11u146_bin/pris.bin` | `6820ba5daec69a13d1ff66dca5fcb356` | own worktree at b2199096, system-deps config, `-j 2` (equals the brief's pristine) |
| `/tmp/v11u146_bin/law.bin` | `55fd4489e609ab6115060171e2235fe0` | b2199096 + `r11u146.patch` (byte-identical to the implementer's `law.final.bin`) |
| `/tmp/v11u146_bin/fix1.bin` | `42ab38fd83b3ca3adbf3f84e3d8aaff8` | b2199096 + the verified patch (this README's three refinements) |
| `/tmp/v11u146_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the committed comparator |

Sweeps `tests/sweep.sh --jobs 3`: `/tmp/v11u146_swP` (pristine), `/tmp/v11u146_swL` (law), `/tmp/v11u146_swF`
(fix). Workdir names have the same length. Every `cmds.txt` names its own binary: 3273 of 3273 in each sweep.

## 2. The implementer's headline numbers, reproduced (`evidence/sweep_{pristine,law}.txt`)

| gate | pristine | law (implementer's binary) | claimed |
|---|---|---|---|
| probe | EQUAL 2308, STRICT_NOTEQUAL 1779; 0/0/0 | EQUAL 2346 / 1741; regressions 0, conversions 38, changes 66 | same |
| surelog | 399 + 397 CMP_EQUAL; 0/0/0 | 405 + 403; regressions 0, conversions 12, changes 18 | same |
| uhdm2rtlil | 702 + 702; 0/0/0 | 712 + 712; regressions 0, conversions 20, changes 28 | same |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2 | the same, verdict and `differs` equal to pristine on all 871 rows | same |
| canaries | surelog ok=52, u2r ok=16; ctcan2 PASS, PASS | surelog ok=42 changed=10 (BasicOh, BuildUVMPkg, Earlgrey_0_1, Scr1SvTests, SimpleConstraint d/t), u2r ok=16; ctcan2 PASS, PASS | same |
| byte movers | | surelog 42 / 960, uhdm2rtlil 50 / 1608 (SELFCHECK 959/960, 1607/1608; path sets identical) | the implementer's evidence files read 42 and 50 and list exactly my set; its README section 6 and report say 43 and 51 (a transcription slip) |

The pristine sweep's law-index line reads STALE. A tree checked out AT a commit always reads its own
commit as missing from the committed `tests/LAWS.md`. This comes from the environment and does not
affect the verdict.

**The 30 + 48 changed corpus row-modes** (`evidence/corpus_changes_firstdiff.txt`, driver `firstdiff.sh`:
the first record uhdm-strictcmp reports, golden against each sweep's database):
- 32 are conversions.
- 22 have their first difference LATER. Examples: SimpleConstraint #95 -> #184, Rggen #101 -> #111,
  iface_param_2level #141 -> #433, pkg_nested_struct_param_width #49 -> #194.
- 24 keep the same first record, with a smaller count on every one.
- None moves EARLIER and none grows.

**The 66 probe changes** (`evidence/probe_changes_firstdiff.txt`, `probefd.py`): 54 LATER, 10 SAME, 2 at the
same index with another record (both escaped-identifier cases, each closer to golden):
- `r10svs8repro/a5_escaped` `sample` col 16 -> 20, golden 21.
- `v11u110repro/brk/v3/a36_escaped_inst_name` ref_module endcol 34 -> 38, golden 41.

The one count that grows, `r10v200repro/v200_5_modmat` `fullname(2) -> fullname(3)`, keeps its first record
(#59). Its walk diverges later, at #77 instead of #66: the class-I unmasking r11u148 documented.

**Attribution** (`evidence/attribution_law_vs_pristine.tsv`, the implementer's `attrib.py` re-run against
my binaries and workdirs). 92 movers:
- 82 are owned by one switch, and `R11U146_OFF` returns the pristine bytes on each:
  - PATHBASE 20, TPSTRUCTKW 12, TFARGTD 9, TPCALHS 8, MODARRBOUND 8
  - E148 6, PORTINIT 6, CLSTDPKG 5, E2148 4, I148 2, CASTKEYFILE 2
- 4 are the multi-law rows ExplictiPorts and PortExpr: `R11U146_OFF` restores them, and no single switch does.
- 6 are UVM order coins (MiniAmiq d/t, SeqDriver d/t, SimpleUVM t, Scoreboard d). They do not
  reproduce from run to run. An order-blind reading (`evidence/uvm_orderblind.txt`) finds exactly the
  24 `uvm_pkg::`-prefixed struct member names of § classTdStructMemberPkgPath146 (golden spells
  `uvm_pkg::uvm_resource_types::access_t::read_count`), the 24 names they replace, and at most the 4
  known UINT/vpiDecompile coin lines.

The byte movers whose csv cell did not change are StructParamPatternInitCast, StructParamFuncBodyFieldCompare,
packed_array_struct and PortInitVal testflags. Their strict records are identical in pristine and law
(`rowrec.sh`). The moves sit past the walk's divergence:
- The first two move the type parameter's struct from 30:26-30:39 to the golden 30:26-30:32.
- packed_array_struct's golden reads 10:28-17:15, and neither pristine (10:41) nor law (10:34) matches.
  This is residue R1 below.

## 3. The breaks (pristine-right -> law-wrong on legal SV) and the refinements

Each was found by a fresh case, confirmed against the pinned Surelog's golden, and is refined behind its own
switch (`R11U146_OFF` still restores the pristine bytes; each `R11V146_*_OFF` alone restores the implementer's
bytes on its cases).

| law (refinement) | switch | site | the break | cases |
|---|---|---|---|---|
| § tfArgDpiNoWrite146v | `R11V146_TFARGDPI_OFF` | UhdmExporter.cpp exportDesign (the § tfArgTypedefLastWriter146 walk) | a DPI import prototype's enum argument (`import "DPI-C" function int cf(input e_t x);`) moved the typedef to the argument token. Golden keeps the typedef's own span and types the DPI argument with its own `unsupported_typespec`. `cases/fa/a18_dpi_module_only`: pristine STRICT_EQUAL, law `STRICT_NOTEQUAL line` (a regression of an equal cell). a15_dpi_pkg_only and a2_dpi (stage-1 cases): the law's dump moved 12 enum_typespec spans away from golden (golden-vs-ours dump lines 12 -> 28) | fa/a18, a15, a2 (and a14, where a later ordinary function is the last writer: still converts) |
| § tpDefaultCaIfaceKeeps146v | `R11V146_TPCALHSIF_OFF` | TypeEmit.cpp tpDefaultCaLhsUnparented146 | in an INTERFACE (`interface ifc #(int W = 4, type T = logic [W-1:0]); T a, b; assign b = a;`), golden keeps the default's bound reference named `<in>T.W`. The law cleared it, so the first difference moved from #37 (line) to #10 (fullname). The unparenting was measured on modules only | tn/k6_iface, k10_iface_ansi (both return to pristine bytes; k1-k5, k7, k8 modules still convert or improve) |
| § tfArgAliasEndFollows146v | `R11V146_TFARGALIAS_OFF` | UhdmExporter.cpp exportDesign (the endMoved test) | an alias of an enum typedef (`typedef e_t f_t;` used as an argument type) holds the aliased enum's span, so its end differed from its own declaration's and read as a write-time move. The law wrote the incoherent span 5:30-3:33 (start after end). Golden has 5:30-5:33. Only an object that starts at its own declaration can carry a moved end | fa/a3_alias (golden-vs-ours dump lines 47 -> 33) |

## 4. Gates of the refined binary (`evidence/sweep_fix.txt`)

| gate | fix |
|---|---|
| law index | current (tests/LAWS.md regenerated) |
| probe | EQUAL 2346 / 1741; regressions 0, conversions 38, changes 66; 0 of 4087 databases differ from the law sweep's |
| surelog | regressions 0, conversions 12, changes 18; csv equal to the law sweep's on all 1596 rows; byte movers vs law 6 / 960, all UVM order coins: MiniAmiq d/t, SeqDriver d/t and SimpleUVM d read exactly the 4 UINT/vpiDecompile coin lines order-blind, Scoreboard d reads 0 (predicted: `evidence/predict_refinements_pristine.tsv`, 153 rows carry a face, written before this sweep existed) |
| uhdm2rtlil | regressions 0, conversions 20, changes 28; byte movers vs law 0 / 1608 |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2; verdict and `differs` equal on all 871 rows across pristine, law and fix |
| canaries | surelog ok=42 changed=10 (the same 10 improvements), u2r ok=16; ctcan2 PASS, PASS |
| uhdm-cmp | every probe case and corpus row keeps its judge status |
| the implementer's grid (99) + r11u148's cases (47) | fix bytes equal law bytes on every one |

## 5. Break attempts (`cases/`, 90 cases, every `dut.sv` names its law in its first line; `evidence/cases_table.tsv`)

Goldens from the pinned Surelog with check_probe's arguments (`drivers/case.sh`). Pristine vs fix, judged by
uhdm-cmp, by uhdm-strictcmp record by record (`recdiff.py`: no case has a record the fix gets wrong that
pristine got right, `newbad=0` on all), and by the downstream verdict (`evidence/cases_downstream.tsv`, the
66 cases whose bytes move):
- 37 cases go from STRICT_NOTEQUAL to STRICT_EQUAL, and 1 from stage-1 to STRICT_EQUAL (e148/q6_gen).
- The other movers read a later first difference or fewer differing records.
- Downstream: 15 cases move to IDENTICAL (4 DIVERGENT -> IDENTICAL, all § evalFuncSelectKeepsCall148:
  q2_override, q4_formalidx, q5_sel_lhs and q6_gen; 11 EQUIVALENT -> IDENTICAL: escaped-identifier and
  unnamed-concat cases, q1_bits and x12). 46 stay IDENTICAL, 4 stay EQUIVALENT, 1 stays DIVERGENT, and
  none leaves IDENTICAL.
- Under `R11U146_OFF=1` all 90 cases return to the pristine bytes.

| family | law | cases | notes |
|---|---|---|---|
| esc | § escIdPpColumnShift146 | 12 (x1-x12) | 8 converted (assign, comments, macro on the line, string with `\\`, two per line, select after, space-then-tab). Improved but not equal: x2 (ref_module end, R2), x4 (a based literal's internal space on the same line, R4), x9 (parameter end, R3). x6/x11 stage-1 but closer (dump lines 147 -> 89, 110 -> 30) |
| pe / ucp | § portExprOperandAtExpr146, § portExprElabDefNets146, § unnamedConcatIfaceAnchor146, § ucpIfaceInstElabShape146 | 6 + 3 | y1, y3, y5, y6 converted; y2 and y4 (positional, generate) stage-1 but closer; z1 32 -> 2 dump lines; z2 (three operands) declined, unchanged |
| pi | § portInitAssignAtHeader146 | 5 | w4 converted; w1-w3 stage-1 but closer (w3 `.x(b)`: golden lists a second initial for `b`, missing in pristine and law); w5 ANSI control unchanged |
| tp | § typeParamStructAtKeyword146 | 6 | v1 (signed), v6 (multi-line) converted; v2 union control equal both; v3/v5 closer |
| tn | § tpDefaultCaLhsUnparented146 (+ § tpDefaultCaIfaceKeeps146v) | 10 | k1 mixed override, k2 generate, k3 `$clog2`, k4 width override, k5 body variable, k8 instance array: converted; k7 two type parameters: #10 -> #197; k6, k9, k10 (interfaces): pristine bytes after the fix |
| ma | § modArrayBoundRefArrayPath146 | 6 | m2 ascending, m5 child, m6 interface array converted; m1, m3 and m4 stage-1 with unchanged bytes |
| fa | § tfArgTypedefLastWriter146 (+ § tfArgDpiNoWrite146v, § tfArgAliasEndFollows146v) | 18 | a1 task, a4 module, a5 `$unit`, a14, a16 pure virtual converted; a6 unpacked/ref/default, a7 interface, a13 modport: later first difference; a11 two modules, a8 extern and a12 declined (unchanged); a2, a15, a18 (DPI) and a3 (alias) are the breaks of section 3 |
| hp | § constPathBaseAnyKind146 | 6 | h3 interface port of a child converted; h4 closer; h1 and h6 variable bases (stale-scope probe) unchanged; h5 control equal; h2 generate-block base rejected by slang |
| ct / ck | § classTdStructMemberPkgPath146, § castKeyElabNetNoFile146 | 3 + 2 | k2 converted; c1 nested class declined (unchanged); c3 fullname #14 -> type #15 (the next face); k1 (two instances) unchanged count |
| e148 / e2148 / i148 | r11u148's three laws | 6 + 3 + 4 | q1 (`$bits` of a parameter select), q2 (override), q4, q5, q6 converted; q3 package parameter declined; r1-r3 stage-1 but closer; s1 (`int` localparam) and s4 (task) converted; s2 (an operation value) and s3 (another package) declined |

## 6. Ops and fence notes

- **The implementer's fence incident** (its README section 8): `heads.sh` ran uhdm-strictcmp on the pristine
  sweep's databases of one fenced test and read its head. No fenced source was read or run, the patch
  holds no fenced name (checked by word match), the head line was discarded, and no law derives from it.
  Reading a fenced test's head is still a decode of that test, against the rule's intent. It is reported
  to the integrator, and the patch is unaffected.
- This verification ran no binary, script or scan on a fenced source. The sweeps and the byteverify
  gate treat every row alike, as the gate mandates. `firstdiff.sh`, `rowrec.sh`, `attrib.py` and
  `predict.py` refuse to run without `$FENCED` and skip those names.
- **Integration note:** the patch applies clean on b2199096. On the current branch head (pass 145 and
  r11u149) `git apply -3` leaves three conflicts: `src/ModuleEmit.cpp` and `src/TypeEmit.cpp` (adjacent
  declarations added by pass 145 and r11u149; keep both sides) and `tests/LAWS.md` (regenerate).

## 7. Residues, ranked (new faces decoded here; none is a regression)

1. **R1 packed_array_struct:** golden ends the `localparam type my_t = struct packed {..}` object at the
   packed-array net's `[2:0]` (17:15). This is a writeNets end move that § typeParamStructAtKeyword146's "no
   move" clause does not model: pristine read 10:41, law reads 10:34. It is invisible to the strict walk
   today, because the walk diverges earlier.
2. **R2 escaped instance names:** a `ref_module` end still misses (`sub \u1  (..)`: golden 5:7-5:16, fix
   5:13; probe a36 38 against golden 41).
3. **R3 an escaped parameter name:** its end misses (`localparam \W$ = 4`: golden 3:14-3:22, fix 3:20).
4. **R4 a based literal with an internal space** on an escaped-identifier line: later columns miss the
   -1 fold (x4: golden 59, fix 60).
5. **R5 an escaped hierarchical method call** (`\cg.esc8 .sample()`): its column is off by one (a5_escaped
   20 against golden 21).
6. **R6 interfaces:** the type-parameter default typespec's span and names (k6, k9, k10: the pristine line
   difference at the interface's `logic_typespec`) are left untouched by the refinement.
7. The implementer's residues R1-R6 and sister-ground faces S1-S4 stand as written in
   tools/probe/r11u146repro/README.md section 7.

## 8. Files

- `cases/<family>/<case>/dut.sv`: the 90 break-attempt cases.
- `drivers/`:
  - case.sh: golden, ours, uhdm-cmp and uhdm-strictcmp per case.
  - recdiff.py: record-level pristine/fix against golden.
  - colcmp.py: csv status/strict join.
  - firstdiff.sh and rowrec.sh: corpus first differences, fail-closed on `$FENCED`.
  - probefd.py: probe first differences.
  - ds.sh: the downstream verdict per case.
  - attrib.py: the implementer's, pointed at these binaries.
  - predict.py: faces of the three refinements, fail-closed.
  - sweep.sh: the sweep wrapper.
- `evidence/`: the sweep summaries, the csv changes, the first-difference classifications, byteverify
  law-vs-pristine and fix-vs-law, the attribution, the canaries, the UVM order-blind reading, the
  prediction, the case table and the case downstream verdicts.
