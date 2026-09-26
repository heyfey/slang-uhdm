# r11u177: second adversarial verification of passes 168 and 169 (verifier, measurement plus three refinements in fix.patch)

Base `50a01bc3` (branch matrix-1.87). Pass 168 (the r11u166 location model and six laws of its own, with its verifier
v11u168) landed at `f34d9d7c`, r11u173's refinement § pvElabGenDefParamLhs173v at `e3f14d0a`, pass 169 (four laws and
r11v169's refinement § gcaChainInsideSetKeepsInst169v) at `31739f79`, the r11u175 decode (tools only) at `50a01bc3`.
The commit before pass 168 is `edb34d8a`. Worktrees: `/tmp/wt_r11u177` (the base, the deliverable),
`/tmp/wt_r11u177pre` (`edb34d8a`), `/tmp/wt_r11u177fix` (the base + [fix.patch](fix.patch)). System-deps
configuration, `-j 2`.

This directory is the whole deliverable. Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is
edited. The three refinements are [fix.patch](fix.patch), a `git diff 50a01bc3 -- src` (`src/ExprEmit.cpp`,
`src/ParamEmit.cpp`) that applies clean on a fresh `50a01bc3` (`git apply --check`, measured); it is NOT applied here.
No canonicalisation patch for `tools/uhdm-strictcmp` was handed to this pass and no comparator defect was found, so
the comparator is not edited.

The slang-fenced tests are named nowhere here. [drivers/env.sh](drivers/env.sh) builds `$FENCED` from RESUME.md
without spelling it; every driver of this directory that reads corpus sources or databases refuses to run without it
and skips those names by word boundary (section 9).

## Verdict

**Three breaks found, all compositions of the r11u166 location model (landed with pass 168) with another emitter
site; each is fixed behind its own switch in fix.patch.** No law of either landing breaks on its own ground: across
149 fresh cases x 2 modes, every cell where a law is switched off against on reads toward golden or neutral, field by
field, except the three shapes below.

| break | laws | shape | axis | refinement (switch) |
|---|---|---|---|---|
| B1 | § ppOutputFile166 x § memLeftFormalArgLoc169 (the cross pair the brief names) | a constant function called with a multi-line macro (`XW` defined in an include) as an actual and a plain actual after it: `localparam cfg_t D = mk(`XW,\n 5);` | strict, file: the whole-formal leftover placed at the actual `5` keeps the CALL's file (`defs.svh`, where § ppOutputFile166 files the call's first line, as golden does); golden files the `5` at `dut.sv` 17:5, pristine and the FILE law off write `dut.sv` | § mlArgLocFileAtActual177v (`R11V177_MLARGFILE_OFF`) |
| B2 | § ppOutputFile166 x the aggregate-default re-anchor (the § aggParamFoldQualSpanByView163 site, ExprEmit) | a module header default `parameter p::cfg_t C = p::D` whose package value sits on a line § ppOutputFile166 files at an include (`'{A: 5, B: `XW}` with a multi-line `XW` from `defs.svh`) | strict, file: the re-anchored fold keeps the package value's file (`defs.svh`) at the reference's span; golden `dut.sv` 7:37 (z02). The same site keeps a CROSS-ROOT package file in pristine too (z05, `pkg.sv` for golden's `dut.sv`): a pre-existing face the location model exposed on one more shape | § aggFoldReanchorFile177v (`R11V177_AGGREANCHORFILE_OFF`) |
| B3 | § ppOutputLine166 x the tagged-operand order (ExprEmit, the `Surelog lists tagged operands in SOURCE order` sort) | a struct pattern whose first member's value starts in a multi-line macro: `'{x: `ADD2(W, 1) * 2, y: W - `ADD2(1, 1)}` | **uhdm-cmp (judge)**: the sort keys on the written line/column, which the model maps as Surelog does (x at 3:3, y at 2:10, golden holds exactly those), so the operands swap; golden keeps the written order x, y. NOT_EQUAL (132 cmp lines) with the law on, judge-equal (strict `endcol`) with it off (X/x11, T/t01) | § tagPatSortSrcOrder177v (`R11V177_TAGSORT_OFF`) |

`R11V177_OFF=1` drops all three. With the refinements (binary `fix4.bin`): the 13 cases they move (26 case-modes) all
move toward golden (t01, x11 stage 1 -> STRICT_EQUAL; z02, z05 file -> STRICT_EQUAL; x09 y01-y03 y05 lose 20/25 file
records; the rest stage 1 on both, the file field being invisible to uhdm-dump), no cell of any state moves a field
away on any of the 149 cases, and `R11V177_OFF=1` gives law.bin's bytes on all 298 case-modes. The census of the
refinements (trace `R11V177_TRACE`, written before their sweep) reads **0 firings** on both corpora and the probe set
(positive control: 6 firings on this directory's cases); their gate sweep reads 0/0/0 in all three stages, the
downstream csv byte-identical, and 0 byte movers but the UVM order coin. None of the three reaches a corpus row today.

**Composition: additive.** Every conversion the landings claimed is owned by exactly one landing (probe 21 + 58,
surelog 8 + 0, uhdm2rtlil 2 + 2), no pair of laws cancels (0 rows at the status level, 0 databases at the byte level),
the 168/169 delta is the same with passes 164, 167 and r11u173 switched off (175 byte movers on both bases, the same
rows), and `R11U166_OFF R11U168_OFF R11U169_OFF R11V173_OFF` gives the `edb34d8a` build's bytes on every case and every
database but the UVM coin.

**Changes: all strict improvements or unmaskings.** Every byte mover of the two landings (probe 125, surelog 38,
uhdm2rtlil 12) reads FTOWARD or FSAME field by field in the aligned walk; 0 FAWAY.

**Downstream:** the converted uhdm2rtlil rows (ibex_load_store_unit, pkg_nested_struct_param_width) and the four other
touched rows are byte-identical to golden's lane (`.il`, `_nohier.il`, `_synth.v`); the downstream csv is byte-identical
with both landings off; 15 fresh cases go EQUIVALENT -> IDENTICAL with the landings on, none leaves IDENTICAL.

**Fence: held.** No law, case or number here rests on a fenced reading (section 9).

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u177_bin/law.bin` | `5f356bace7feda3ba46382e2b63ac365` | worktree build of `50a01bc3` = the main tree's `build/slang-uhdm` (the brief's `5f356bace7fe`) |
| `/tmp/r11u177_bin/pre.bin` | `d64816326230eb41669e1062297ba547` | build of `edb34d8a`, the commit before pass 168 (= r11u173's and r11u169's pristine md5) |
| `/tmp/r11u177_bin/fix4.bin` | `f1b896fe2b74cc167ee38fc51d91422e` | `50a01bc3` + [fix.patch](fix.patch) (the final refinement build) |
| `fix.bin`, `fix2.bin`, `fix3.bin` | `b33daf82`, `8f13d13f`, `547dd39c` | development builds: B1 only; B1 + B2 (gate-swept as `swF`, superseded); B1-B3 with a brace defect that crashed T/t05 (rc 139), withdrawn (section 4) |
| `/tmp/r11u177_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `alloff.sh`, `off168.sh`, `off169.sh`, `preoff.sh`, `off164167.sh`, `wide.sh` | wrappers ([drivers/mkstate.sh](drivers/mkstate.sh)) | law.bin under `R11U166_OFF R11U168_OFF R11U169_OFF`; `R11U166_OFF R11U168_OFF`; `R11U169_OFF`; alloff + `R11V173_OFF`; `R11U161_OFF R11U164_OFF R11U167_OFF R11V173_OFF`; all of them |

## 2. Sweeps (`tests/sweep.sh --jobs 3`, [drivers/sweep.sh](drivers/sweep.sh); workdir names all the same length)

| sweep | binary | probe EQUAL | vs committed baselines: regressions / conversions / changes (probe; surelog; uhdm2rtlil) | downstream |
|---|---|---|---|---|
| swH | law.bin (the gate at HEAD) | 2755 / 1332 | 0/0/0; 0/0/0; 0/0/0 | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 |
| swA | alloff.sh | 2676 | 79/0/32; 8/0/23; 4/0/8 | csv byte-identical to swH's |
| sw8 | off168.sh | 2734 | 21/0/5; 8/0/21; 2/0/2 (exactly pass 168's claim) | - |
| sw9 | off169.sh | 2697 | 58/0/27; 0/0/2; 2/0/8 (exactly pass 169's claim) | - |
| swR | preoff.sh | 2676 | as swA | - |
| swP | pre.bin | 2676 | as swA | - |
| swQ | off164167.sh | 2676 | 79/0/86; 12/0/4; 12/0/0 | - |
| swW | wide.sh | 2597 | 158/0/118; 18/0/25; 16/0/8 | - |
| swG | fix4.bin (the refinements) | 2755 / 1332 | 0/0/0; 0/0/0; 0/0/0 | 803 / 66 / 2 / 0, csv byte-identical to swH's |

Every sweep's `cmds.txt` names its own binary on all 3273 `slang:` lines (1531 surelog + 1742 uhdm2rtlil). Every
sweep exits 1 for one reason, `law index STALE`: a clean checkout of `50a01bc3` reads STALE too (`python3
scripts/law_index.py --check` in the main tree, measured), and this directory's cases name laws, so the landing
regenerates `tests/LAWS.md`. swH's `probe.csv` is byte-identical to results/golden_probe.csv and its `downstream.csv`
to results/downstream_uhdm2rtlil.csv. Canaries ([evidence/sweeps/canaries_swH.txt](evidence/sweeps/canaries_swH.txt),
[evidence/fix/canaries_swG.txt](evidence/fix/canaries_swG.txt)): canaries.sh surelog ok=52 changed=0, uhdm2rtlil
ok=16 changed=0; ctcan2.sh surelog ok=58 changed=0 PASS (EXPECT_UNKNOWN=1), uhdm2rtlil ok=2 changed=0 PASS
(EXPECT_UNKNOWN=6), on both swH and swG. The surelog csvs of every pair of sweeps differ only in the LowMemLib /
LowMemPkg testflags detail text (the workdir path in Surelog's log line: environment).

swQ's 12 surelog regressions are pass 164's 6 and pass 167's 4 plus GenForStructParamBound d/t, which pass 168
converts only together with pass 164's law (section 5).

## 3. The fresh cases and the per-law scores

149 cases in [cases/](cases) (16 groups), none in any grid of r11u166mac, r11u168repro, v11u168repro, r11u169repro or
r11v169repro; the first line of each names its laws. [drivers/grid.py](drivers/grid.py) runs every case in both modes
(default = check_probe's arguments; `--elabuhdm` = Surelog `-elabuhdm`, ours `--elabuhdm`) under: ON, each named law's
own switch (a refinement also under its parent's), each landing off, both landings off (ALLOFF), ALLOFF +
`R11V173_OFF` (PREOFF), and pre.bin. [drivers/case.sh](drivers/case.sh) builds the golden with the pinned Surelog
(a `dut.v` case in Verilog mode, an `args` case with several root files of one compilation unit) and records every
run's rc. Two readings per law cell:

- grid.py: UNFIRED (same bytes), TOWARD (records only leave), AWAY / MIXED (a new record at an aligned walk position),
  UNMASK, BYTES-ONLY, and for stage-1 cells the order-blind dump distance (STAGE1-CLOSER / SAME / AWAY);
- [drivers/fieldscore.py](drivers/fieldscore.py), the decisive one: per walk index the set of fields that differ from
  golden, ON against the state: FTOWARD (fields only lost), FNEUTRAL (the same fields wrong on both, values moved),
  FAWAY (a field the state had right is wrong with the law on: a BREAK), FSAME.

| group | cases | law(s) attacked (the brief's shapes) |
|---|---|---|
| L | 12 | location model: a macro defined in one root file and used in another (l01, l08 in an include of the second root), nested includes with a multi-line body (l02), a paste at a line end (l03), a stringified formal with an escaped quote (l04), a macro call inside a macro argument inside an include (l05), a based literal with spaces after a paste (l06), macro port connections with ranges (l07, l09), macro literals from an include (l10), a re-included multi-line macro (l11), a stringify with a multi-line actual (l12) |
| B | 13 | § ppOutputFile166: a multi-line macro from an include followed by tokens on the next line, in calls, concatenations, system tasks, tasks, packages; b04 the same-file control |
| F | 3 | § ppFileCallArgBody168: the formal receiver `PH.get_full_name()` three levels deep across two and three files, a variable receiver |
| U | 6 | § undefKeepsOtherRootMacro168: `undef in an include of the second root, a redefinition with another body, `undef of a never-defined macro, `undef then `ifdef, undef+define inside an include, three roots |
| P | 6 | § paramBaseSelTsInstName168: a bound that is a parameter of a parameter, overridden, passed from a parent, imported from a package, in a generate-if, a localparam of a localparam |
| H | 8 | § hcSelIdxInstName168: three-level index, a struct member of an array element, a 2-D element, an index of an index in a generate array, three-deep hierarchy, a port struct member part-select, a call in the index, a packed 2-D element bit |
| S | 6 | § structParamBoundAtPatternLeaf168: nested patterns with `default:`, an outer `default:`, a two-level override, a parameter-to-parameter read in the interface, a left bound, a package-parameter nested override |
| R | 3 | § rangeHierPathNoFullName168: three struct levels, a module wire array, an interface wire array with an override |
| G | 32 | § genCaFoldTsChainNamed169 and § gcaChainInsideSetKeepsInst169v: `>>>`, `<<<`, index of an index, conditional condition, streaming, part-select and indexed part-select bounds with operations, `$bits`, a cast size, a replication count, `&&`/`||`/`==?` chains, localparam of the parameter, three-level loops, a child override with nested loops, and inside sets (ranges with operations, parameters of parameters, two-parameter ranges, mixed members, conditional members, concatenation members, nested inside) |
| M | 10 | § memLeftSliceUnlocated169 / § memLeftFormalArgLoc169: call, nested-call, binary (parameter left), unary, macro-born, sign-cast, override, pattern-literal and underscore-literal actuals, a whole member read through a pattern parameter |
| Q | 6 | § patFlatMemberLeftSpan169: a call as the left operand or the member value, unary reduction, concatenation and replication left operands, three nested patterns, an override with shifts |
| X | 13 | the cross-ground pairs: § ppBasedLitWsAfter166 with the chain law (x01 x02), § hcSelIdxInstName168 with the chain law (x03 x04, x13), § paramBaseSelTsInstName168 with the leftover laws (x05 x06), § ppOutputFile166 / § ppFileCallArgBody168 with the leftover laws on macro-born actuals (x07-x09), the struct-parameter bound from a constant function (x10), the pattern member from a multi-line macro (x11), a chain operand from a multi-line macro (x12) |
| Y | 9 | B1's grid (section 4) |
| Z | 10 | B2's grid |
| T | 9 | B3's grid |
| K | 3 | the instance source-order sort (`V11U93` last type-parameter binding) with macro-born instances: controls, strict-equal in every state |

Per law (law.bin, the 137 cases of groups B-Z but T and K, both modes; [evidence/grid/lawsum.md](evidence/grid/lawsum.md),
[evidence/grid/lawcases.md](evidence/grid/lawcases.md) lists every fired case with both readings; T and K in
[evidence/grid/grid_t_law.txt](evidence/grid/grid_t_law.txt) and [evidence/grid/gridF4_def.txt](evidence/grid/gridF4_def.txt)):

| law | cases naming it | fired on | field reading of the law's own switch (cells, both modes) | breaks |
|---|---|---|---|---|
| § ppOutputLine166 | 23 | 20 | FTOWARD 36, FSAME 6, stage-1 cells closer | B3 (x11, T/t01) |
| § ppOutputCol166 | 7 | 7 | FTOWARD 10, stage-1 closer 4 | - |
| § ppOutputFile166 | 38 | 23 | FTOWARD 26, FSAME 28, **FAWAY 12** | B1 (x09, y01 y02 y03 y05), B2 (z02) |
| § ppOutputInclLine166 | 5 | 1 | FTOWARD 2 | - |
| § ppReincludeSplice166 | 1 | 0 | - | - |
| § macroConnInRange166 | 3 | 3 | stage 1 -> STRICT_EQUAL (l07 l09), closer (x13) | - |
| § ppBasedLitWsAfter166 | 4 | 4 | stage-1 closer 8 (the spaced literal's cont_assign span moves to golden's) | - |
| § ppFileCallArgBody168 | 6 | 3 | FTOWARD 6 (grid.py reads MIXED: the same object keeps its S1 span face and loses its file face) | - |
| § undefKeepsOtherRootMacro168 | 6 | 4 | FTOWARD 8 (u01 u03 u04 u06 -> STRICT_EQUAL) | - |
| § paramBaseSelTsInstName168 | 8 | 1 | FTOWARD 2 (p03 -> STRICT_EQUAL) | - |
| § hcSelIdxInstName168 | 11 | 6 | FTOWARD 6 (h01 h05 x04 -> STRICT_EQUAL), stage-1 closer 6 | - |
| § structParamBoundAtPatternLeaf168 | 10 | 5 | stage-1 closer 10 (s05 stage 1 -> STRICT_EQUAL; s04's head moves past the folded bound) | - |
| § rangeHierPathNoFullName168 | 3 | 2 | stage-1 closer 4 | - |
| § genCaFoldTsChainNamed169 | 37 | 22 | FTOWARD 28, FNEUTRAL 4, stage-1 closer 9, BYTES-ONLY 2 | - |
| § gcaChainInsideSetKeepsInst169v | 10 | 9 | FTOWARD 8, FNEUTRAL 2, stage-1 closer 6 / same 1 / AWAY 1 (i01, traced: neutral) | - |
| § memLeftSliceUnlocated169 | 15 | 14 | FTOWARD 12, stage-1 closer 14 / same 2 | - |
| § memLeftFormalArgLoc169 | 25 | 19 | FTOWARD 22 (grid.py MIXED on the B1 cases: the leftover's line fixed, its file wrong), stage-1 closer 16 | B1 (with § ppOutputFile166) |
| § patFlatMemberLeftSpan169 | 7 | 6 | FTOWARD 6, stage-1 closer 6 | - |

Totals: no case crashes or times out in any state (every rc is 0; two first drafts that were illegal SystemVerilog,
L/l04 and S/s05, were rewritten before the final grids); no case
that is STRICT_EQUAL with the landings off reads otherwise with them on except x11 / T/t01 (B3); PREOFF = pre.bin byte
for byte on all 274 case-modes of the 137 cases ([evidence/grid/gridA_def.txt](evidence/grid/gridA_def.txt),
`ALLOFF==PRE YES`).

The FNEUTRAL and stage-1-AWAY cells, traced:

- g14 `32'(((a[c] & P) != 0) && a[c][0])`, i04 `inside {P, a[c][P]}`, i05 `inside {(c == 0) ? P : 1}`, i01 `inside
  {[P-1:P+1]}`: golden leaves the folded reference's full name EMPTY (the substituted constant unparented, r11v169's
  residue 1, now also for ranges with operations, conditional set members and the `&&` chain inside a cast) or `a`
  (i04, the index inside a set member); pristine writes `work@dut`, the chain law `work@dut.g[0]`, the refinement
  `work@dut` again: wrong on every state, the same field. i01's dump distance (141 -> 145) is a line-multiset
  coincidence: golden's `ref_typespec:` lines are unnamed in all four places, ours name them by the scope or by the
  instance.

## 4. The breaks and the refinements ([fix.patch](fix.patch); `R11V177_OFF=1` drops all three)

The decode behind all three: Surelog files every object at the file of its start OUTPUT line and its line at that
output line's record (third_party/Surelog/src/SourceCompile/SV3_1aTreeShapeHelper.cpp:188-190, `fileId =
getFileId(lineCol.first + m_lineOffset); line = getLineNb(lineCol.first + m_lineOffset)`), so file and line always
come from one position; and it lists a pattern's operands in parse order
(third_party/Surelog/src/DesignCompile/CompileExpression.cpp:2194-2205, the `while (Sibling)` loop pushing each
compiled item). Our `setLoc` keeps a file already stamped (§ vpiFileOnEveryLocated117), so a second `setLoc` that
relocates an object moves its line and column but not its file; and one emitter site orders tagged operands by
their written line and column. Before § ppOutputLine166 / § ppOutputFile166 a token's file and line were those of its
own buffer (monotonic, one file per root); the model reproduces Surelog's output-line mapping, which is neither.

### B1: § mlArgLocFileAtActual177v (ParamEmit.cpp, the makeMemLeftConst stamp site; `R11V177_MLARGFILE_OFF`)

Pass 169's leftover is first located at the call (`setLoc(c9, init->sourceRange)`) and then, under
§ memLeftFormalArgLoc169, at the actual (`setLoc(c9, *ar169)`). When the call's first output line is filed at another
file than the actual (text before a multi-line `XW` expansion reads the definition file under § ppOutputFile166 and in
golden: golden `parameter D` at `defs.svh 1:20`), the relocated leftover keeps the call's file. The refinement clears
the file before the relocation, so the leftover takes the actual's file with its line. The drain's parameter-actual
copy (`c169->VpiFile(prev169->VpiFile())`) reads the corrected file.

Grid Y (9 cases x 2 modes; [evidence/grid/grid_y_law.txt](evidence/grid/grid_y_law.txt)): y01 (object-like multi-line
macro, literal on the next line), y02 (function-like), y03 (same line), y05 (binary actual) read FAWAY against
`R11U166_FILE_OFF`, against landing 168 off, against both landings off and against pre.bin (`#294 file gold='dut.sv'
ours='defs.svh'`; 20 objects in the default view and 25 in the elaborated one, B1's leftovers and B2's re-anchored
`Cfg` fold of the same case together; x09 the same), and FTOWARD against `R11U169_MLARGLOC_OFF` alone (the
line was wrong there too): a composition break, invisible to each landing's own grid. Controls: y06 (the macro in the
same file) and y07 (no macro) unmoved; y09 (the literal first, the macro second) unmoved. With the refinements
those 20 / 25 file faces leave; what is left is pass 169's residue R4 (the macro-born `64`'s
span, 1:24-17:7 for golden's 2:3-2:5).

### B2: § aggFoldReanchorFile177v (ExprEmit.cpp, the struct/union parameter default fold; `R11V177_AGGREANCHORFILE_OFF`)

An interface/module parameter default reading a struct package localparam is re-emitted from the package's value and
re-anchored at the reference (§ aggParamFoldUnqualWholeSpan158 / § aggParamFoldQualSpanByView163 and the qualifier
fallback: four `setLoc(folded, ...)` sites). The re-emission stamped the package value's file; the re-anchor keeps it.
Golden files the elaborated operation at the reference's file (z02 `dut.sv 7:37`, z05 `dut.sv 2:37`). The refinement
clears the file before the four re-anchors.

Grid Z (10 cases; [evidence/grid/grid_z_law.txt](evidence/grid/grid_z_law.txt)): z02 is the break (FAWAY against
`R11U166_FILE_OFF`: `#67 file gold='dut.sv' ours='defs.svh'`; the landings off are stage 1 there); z05 (the package in
another ROOT file, no macro) and z06 (the package in an include) carry the same face in every state, pristine included:
the location model only added a shape. With the refinement z02 and z05 read STRICT_EQUAL, z06 loses the operation's
file record (its `typespec_member` root-file face stays, the identity family). Controls: z01 z04 z09 (scalar
parameters), z07 (an unqualified import: golden and ours agree already), z08 (an instance override `#(.C(p::D))`: golden
keeps the PACKAGE's location, file and span, `pkg.sv 4:24`; a different path, untouched) unmoved.

### B3: § tagPatSortSrcOrder177v (ExprEmit.cpp, the tagged-operand order; `R11V177_TAGSORT_OFF`)

The re-sort `Surelog lists tagged operands in SOURCE order` ordered by the tagged pattern's line and column. Under
§ ppOutputLine166 those are Surelog's output-line positions (golden itself holds x at 3:3 and y at 2:10 for
`'{x: `ADD2(W, 1) * 2, y: W - `ADD2(1, 1)}`), which are not monotonic in the text, so the operands swapped and
uhdm-cmp read NOT_EQUAL (132 lines, the head an operation opType 25 against 11). The refinement orders by the operand's
expansion point in the file (buffer, offset), recorded at each tagged pattern's `setLoc` (the named, indexed and default
setters). T/t08 (plain, reversed `'{y: .., x: ..}`) proves golden's order is the written order (golden y first).

Grid T (9 cases; [evidence/grid/grid_t_law.txt](evidence/grid/grid_t_law.txt)): t01 (= X/x11) is the break in both
modes (the law's switch off: judge-equal, strict `endline`); t02 t07 t09 (multi-line macro values elsewhere, reversed
orders) keep their order on every state; t03 (one-line macro), t05 (a `default:` first), t06 (a cont_assign pattern),
t08 (plain) are controls; t04 (index setters of an array parameter) is stage 1 on every state (another face). With the
refinement t01 and x11 read STRICT_EQUAL in both modes; no other case moves.

A development defect, disclosed: the first build of B3 (`fix3.bin`) put the key call for the nested `default:` value
after an unbraced `if`, dereferencing a null syntax pointer on T/t05 (rc 139 where law.bin writes a database). The
grid's crash check caught it; `fix3.bin` was withdrawn before any sweep, the call braced, and `fix4.bin` built.

### Measurements of the refinements (fix4.bin)

| gate | result |
|---|---|
| (1) build | `fix4.bin` `f1b896fe2b74cc167ee38fc51d91422e`, `/tmp/wt_r11u177fix` = `50a01bc3` + fix.patch |
| cases | 13 cases move (26 case-modes: t01 x09 x11 y01-y05 y08 z02 z05 z06 z10), every one toward golden: vs law.bin 16 FTOWARD cells + t01, x11 stage 1 -> STRICT_EQUAL; the others FSAME; vs every other state (each law off, each landing off, ALLOFF, PREOFF) **0 FAWAY**, 18 FNEUTRAL (the empty-name residue above) ([evidence/fix/fieldscore_fix_grid.txt](evidence/fix/fieldscore_fix_grid.txt)) |
| switches | `R11V177_OFF=1` = law.bin bytes on 298 / 298 case-modes ([evidence/fix/switch_off_bytes.txt](evidence/fix/switch_off_bytes.txt)); each switch alone restores its own grid |
| census (before the sweep) | 0 firings over 1588 surelog + 1742 uhdm2rtlil row-modes (fence filter, 0 fenced mentions) and 4087 probe cases; positive control 6 firings on Y, Z, T, x11 ([evidence/fix/prediction_fix_final.txt](evidence/fix/prediction_fix_final.txt), written 03:27Z, before swG) |
| (2)-(4) gate sweep swG | probe 0/0/0 (EQUAL 2755), surelog 0/0/0, uhdm2rtlil 0/0/0; downstream 803 / 66 / 2 / 0, csv byte-identical to swH's |
| (6) byteverify vs swH (SELFCHECK=1, fence-clean mirrors) | surelog 5 / 952 = MiniAmiq d/t, SeqDriver t, SimpleUVM d, Scoreboard d, the UVM coin (order-blind 4, 4, 4, 4, 0 lines); uhdm2rtlil 0 / 1608; probe 0 / 4087 ([evidence/fix/](evidence/fix)) |
| byte controls | 883 cases of the landed-law grids (r11u118repro, r11v11u118repro, r11u119repro, r11u166mac, r11u168repro, v11u168repro, r11u169repro, r11v169repro, r11u170verify, r11u173verify): 0 byte movers ([evidence/fix/fixbytes_landed_grids.txt](evidence/fix/fixbytes_landed_grids.txt)) |
| downstream | 30 cases (Y, Z, T, x09, x11): the same verdict on law.bin, fix4 and both landings off (29 IDENTICAL, Y/y08 EQUIVALENT on all three) |
| canaries | ok=52 / ok=16 changed 0; ctcan2 PASS both |

Landing note: the cases of groups Y, Z and T name the three `...177v` laws in their first lines; those laws have
sites in `src` only once fix.patch lands (`scripts/law_index.py --law tagPatSortSrcOrder177v` lists them with no
source until then). The landing regenerates `tests/LAWS.md` either way.

An intermediate build (`fix2.bin`, B1 + B2) was gate-swept first (`swF`: 0/0/0, downstream identical, 6 UVM coin
movers; [evidence/sweeps/sweep_swF_fix2_intermediate.log](evidence/sweeps/sweep_swF_fix2_intermediate.log)).

## 5. Composition ([drivers/compose.py](drivers/compose.py), [drivers/bytecancel.py](drivers/bytecancel.py), [drivers/additive.py](drivers/additive.py), [evidence/composition/](evidence/composition))

Status level, HEAD (swH) against both landings off (swA) with one landing off at a time (sw8, sw9)
([compose_H_A_8_9.txt](evidence/composition/compose_H_A_8_9.txt)):

| stage | conversions HEAD vs both off | owner | changes | cancel |
|---|---|---|---|---|
| probe | 79 | OWN168 21 (pass 168's 21 names), OWN169 58 (pass 169's 58) | OWN168 5, OWN169 27 | 0 |
| surelog (1588 rows, fenced skipped) | 8 | OWN168 8 (GenForStructParamBound, StructArrayNet, YosysMarlann, YosysOldOpen d/t) | OWN168 21, OWN169 2 (FuncStructVal d/t) | 0 |
| uhdm2rtlil | 4 | OWN168 2 (ibex_load_store_unit d/t), OWN169 2 (pkg_nested_struct_param_width d/t) | JOINT 2 (ibex_pmp d/t: file(52) -> 15, pass 168's 16 and pass 169's 51 combined), OWN169 6 | 0 |

No conversion is SHARED or JOINT. Byte level over 6647 databases
([bytecancel_H_A_8_9.txt](evidence/composition/bytecancel_H_A_8_9.txt)): SAME 6472, OWN168 53 (probe 27 = pass 168's
27 probe movers, corpus 26), OWN169 114 (probe 98 = pass 169's 98, corpus 16), BOTH 8 (Earlgrey_0_1 d/t and ibex_pmp
d/t, which both passes reported moving; MiniAmiq d/t, SeqDriver d, Scoreboard d: the UVM coin, order-blind 4 / 4 / 4 / 0
lines against sw9, [orderblind_H_vs_off169_uvm.txt](evidence/composition/orderblind_H_vs_off169_uvm.txt)), CANCEL 0.

Pre-168 bytes ([bytesame.txt](evidence/composition/bytesame.txt)): PREOFF (swR) against pre.bin (swP) over 6647
databases: 7 differ, all UVM (SeqDriver d/t, MiniAmiq d/t, SimpleUVM d/t, Scoreboard d; order-blind 4 or 0 lines,
[orderblind_preoff_vs_pre_uvm.txt](evidence/composition/orderblind_preoff_vs_pre_uvm.txt)); probe and uhdm2rtlil csvs
identical, surelog csv identical but the LowMem detail text. The same holds for swA against swP.

With passes 164, 167 and r11u173 ([additive_H_A_Q_W.txt](evidence/composition/additive_H_A_Q_W.txt),
[fieldrows_W_to_Q.txt](evidence/composition/fieldrows_W_to_Q.txt)): the 168/169 delta on HEAD's base (swA -> swH) and
on the base with 164/167/173 off (swW -> swQ) moves the same 111 probe cases with the same (from, to) pairs, the same
12 uhdm2rtlil rows, the same 175 databases, and 31 surelog rows of which 27 move identically. The four others:
Earlgrey_0_1 d/t (line(1686) -> fullname(511) on HEAD's base, line(1730) -> fullname(555) on the other; 1294 fields
lost on both bases, FTOWARD) and GenForStructParamBound d/t (converted on HEAD's base; on the other base it loses the
same 6 fields and stops at col(4), pass 164's face: the conversion needs both passes' laws, each fixing its own
field, not a pair cancelling). Field level on the other base: probe 111 FTOWARD + 14 FSAME, surelog 31 FTOWARD + 7
FSAME, uhdm2rtlil 12 FTOWARD, 0 FAWAY.

The cross-ground pairs the brief names (group X, `--pairs`: each pair of laws off together;
[evidence/grid/grid_x.txt](evidence/grid/grid_x.txt), [fieldscore_X_law.txt](evidence/grid/fieldscore_X_law.txt)):
§ ppBasedLitWsAfter166 with the chain law on spaced literals in a loop (x01, x02): stage 1 on every state (golden keeps
a macro-born or spaced literal's spaces in its decompile and value, `8'h   F`, section 8), closer order-blind;
§ hcSelIdxInstName168 with the chain law (x03 stage 1 closer, x04 -> STRICT_EQUAL, x13 closer); § paramBaseSelTsInstName168
with § memLeftFormalArgLoc169 (x05 strict-equal on every state, x06 FTOWARD); § ppOutputFile166 /
§ ppFileCallArgBody168 with § memLeftSliceUnlocated169 on macro-born actuals (x07, x08 FTOWARD; x09 = B1). Every
other pair cell is FTOWARD or FSAME.

## 6. The CHANGE lines re-derived ([drivers/unmask.py](drivers/unmask.py), [drivers/fieldrows.py](drivers/fieldrows.py), [evidence/changes/](evidence/changes))

Both landings off against HEAD, record by record ([unmask_A_to_H.txt](evidence/changes/unmask_A_to_H.txt)):

| stage | CONVERSION | SUBSET (every record of HEAD was one of the off state's) | UNMASK | NEW / BOTH-DIVERGED |
|---|---|---|---|---|
| probe (111 rows) | 79 | 26 | 5 (r11u20 t5, r11u21 t1, r11v21 v1, r11vu13 v4 v9: pass 169's walk-goes-further cases) | NEW 1: r11v11u8 v9 `line(6) -> col(6)` |
| surelog (31) | 8 | 21 | 0 | NEW 2: CovMacro d/t `endcol(118) -> fullname(8)` |
| uhdm2rtlil (10) | 4 | 4 | 2 (param_nested_struct_field_width d/t) | BOTH-DIVERGED 2: struct_param_func_config d/t |

The three readings that are not a subset, field by field ([fieldrows_A_to_H.txt](evidence/changes/fieldrows_A_to_H.txt)):
v9 and CovMacro keep the same objects with fewer fields wrong (v9 loses 8 fields, its `initial` keeps a column face
that was there before; CovMacro loses 224 fields, its 8 hier_path full names were there before behind the
endcol face): FTOWARD. struct_param_func_config's walk diverges later (#301 -> #1364 default, #294 -> #1274
elaborated, r11v169's `#239/#301 depth` proof reproduced); the aligned prefix loses 18 fields and the 14 new records
all sit past the old divergence. Over every byte mover of the two landings: probe 125 (FTOWARD 111, FSAME 14),
surelog 38 (FTOWARD 31, FSAME 7), uhdm2rtlil 12 (FTOWARD 12); **FAWAY 0**.

The combined change lines at this base are pass 168's (21 surelog + 2 uhdm2rtlil + 5 probe) and pass 169's (2 + 8 +
27) with ibex_pmp d/t counted once (both passes moved it): 23 + 8 + 32.

UVM file facets ([drivers/uvmdist.sh](drivers/uvmdist.sh), [evidence/sweeps/uvm_file_facets.txt](evidence/sweeps/uvm_file_facets.txt)):
order-blind distance to golden HEAD / both off: MiniAmiq d/t 16872 / 28599, SeqDriver d/t 15771 / 29455, SimpleUVM
d/t 10672 / 20221, Scoreboard d 9306 / 16921; method_func_call file facets away 15 on both (§ ppFileCallArgBody168
holds); every (type, name, file) triple: 4867 / 4934, 5190 / 5270, 3714 / 3784, 3001 / 3056. No file facet moves away
on ten rows checked triple by triple ([drivers/fileaway.py](drivers/fileaway.py),
[file_facets_away_A_to_H.txt](evidence/sweeps/file_facets_away_A_to_H.txt): the four UVM rows, Scr1SvTests, ApbSlave,
Earlgrey_0_1, ibex_pmp, CovMacro, YosysOldOr: 0 triples).

## 7. Downstream ([drivers/dscase.py](drivers/dscase.py), [evidence/downstream/](evidence/downstream))

- The converted uhdm2rtlil rows: ibex_load_store_unit (pass 168) and pkg_nested_struct_param_width (pass 169) read
  `IDENTICAL,OK,OK,736,736` and `IDENTICAL,OK,OK,66,66` in swH; `ibex_load_store_unit.il`, `_nohier.il`, `_synth.v`
  and the same three of pkg_nested_struct_param_width, ibex_pmp, param_nested_struct_field_width,
  struct_param_field_shift and struct_param_func_config are byte-identical between the Surelog lane and ours.
  ibex_load_store_unit's downstream database is byte-identical with both landings off (the downstream command line
  never reaches the location-model face); pkg_nested_struct_param_width's changes, its netlists do not.
- The downstream csv of swA (both landings off) is byte-identical to swH's and to the committed baseline.
- Per case, 118 cases (all groups but Y, Z, T, K): with both landings off 96 IDENTICAL, 18 EQUIVALENT, 2 DIVERGENT, 2
  STATUS_DIFF; with them on 111 / 3 / 2 / 2. 15 go EQUIVALENT -> IDENTICAL (b03 b06-b09 b12 b13, l03 l04 l05 l07 l09
  l12, x12 x13: the macro-connection and multi-line-macro cases), none leaves IDENTICAL. The 32 cases of T, K, Y, Z
  read the same verdict with the landings off and on, and the 30 of them the refinements move or touch (Y, Z, T, x09,
  x11) the same verdict with the refinements (K's databases are byte-identical under them).

## 8. Residues

### Re-measured at the base: every top-three residue still stands ([evidence/residues/residue_cases_at_base.txt](evidence/residues/residue_cases_at_base.txt), the swH csvs)

| source | residue | at 50a01bc3 |
|---|---|---|
| pass 168, 1 | PreprocTest d/t (the Verilog-mode `bit` face) | `differ:endcol(2)` d/t, stands |
| pass 168, 2 | UnsizedParam d (the elaborated cont_assign clone) | `differ:fullname(2)`, t CMP_EQUAL, stands |
| pass 168, 3 | GenerateUnnamed d/t (genblk numbering) | `differ:fullname(9)` d/t, stands |
| v11u168, 1 | U/y10 (object lines after a cross-root redefinition in an include) | `line`, `module_inst x.vh 3:1` for golden's 2:1, stands |
| v11u168, 2 | the S1 span of the formal-receiver call (F/z07-z09) | `line`, 5:72-13:9 for golden's 6:13-6:26, stands (this pass's F group: the same span, now in the right file) |
| v11u168, 3 | R/x13 (the override's param_assign operation location) | `line`, 12:17 for golden's 5:30, stands |
| pass 169, R1 | the leftover's typespec reference on the elaborated struct copy | struct_param_field_shift `fullname(5)`, param_nested_struct_field_width `fullname(6)`, struct_param_func_config `fullname(14)`, FuncStructValSimple `file(42)` / `file(62)`: stand (M/m03 reads the same face: `<in>p::cfg_t.A` for our `p`) |
| pass 169, R2 | gc/c04 (`work@dut.g[0].a.a`), gc/a07 (`work@dut.g.a.P`) | `fullname`, stand |
| pass 169, R3 | FuncStructVal INSTR_PER_FETCH | `endcol(95)` / `endcol(177)`, stands |
| r11v169, 1 | empty reference names under `==?`, `&&` (gv05, gv06) | `fullname(6)`, stands, and extends (section 3) |
| r11v169, 2 | `s.f[P % 8]` (gb12) | stage 1 (180 cmp lines), stands |
| r11v169, 3 | the substituted constant's vpiParent | strict-invisible, not re-measured |

ibex_pmp d/t reads `file(15)` at this base (pass 168's 16 and pass 169's 51 composed); CovMacro d/t `fullname(8)`,
YosysRiscv `col(40)`, YosysOldOr `line(1)`.

### New, found here (none is a break of the two landings; ranked by reach)

1. **The re-anchor keeps a cross-root file** (Z/z05, z06): an aggregate parameter default reading a package localparam
   from another root file or an include keeps the package's file at the reference's span. B2's refinement fixes z05;
   z06's `typespec_member` root-file face is the identity family (Scr1SvTests' face). An instance override
   `#(.C(p::D))` (z08) is the opposite: golden keeps the package value's location, file and span, where ours re-anchors.
2. **§ paramBaseSelTsInstName168 does not reach a wildcard-imported package bound** (P/p04 `v[I+3:I]` with `import
   pk::*`): golden `work@top.s`, ours `work@top.s.v` on every state (the law is unfired; v11u168's x02 was the
   package-qualified shape).
3. **§ hcSelIdxInstName168 does not reach a two-index high connection** (H/h03 `.a(mm[i][j])`, H/h08 packed
   `.a(v[i][j])`): golden names the index `work@dut.m.a.mm.i`, ours `work@dut.mm.i` (unfired).
4. **A pattern-literal actual's member read** (M/m08 `build('{s: 3, d: 32})` with `c.a = uu.s`): golden locates the
   leftover at the member's value (12:33-34), ours at the whole pattern (12:22-43); § memLeftFormalArgLoc169 abstains
   on a pattern actual. M/m09 (`c.b = uu.d * 4` with a package pattern localparam, elaborated view): golden leaves the
   leftover unlocated, ours keeps the call span: the R3 rule (a pattern-parameter caller) is not uniform.
5. **A macro-born or spaced based literal keeps its spaces in golden's decompile and value** (L/l06 `8'h   F`, l10
   `8'h 0F`, X/x01 x02): stage 1 on every state; the laws move only the spans.
6. **A call as a pattern member value** (Q/q01, q02): golden spans `f(A)` 8:28-32, ours the name 8:28-29, every state.
7. The empty-name family (section 3) and T/t04 (index setters of an array parameter, stage 1 on every state).

## 9. The fence and the process

**No law, case or number rests on a fenced reading.** Every case is this directory's; every corpus reading is a
non-fenced row through a fail-closed driver or a gate sweep; the composition csvs skip the fenced rows unread
(compose.py: 1588 surelog rows = 1596 - 8). The laws nearest to parameter and path shapes (two per pass, plus the undef law) were re-derived here from the
pinned sources and this directory's cases only:

- § genCaFoldTsChainNamed169 and § hcSelIdxInstName168: third_party/Surelog/third_party/UHDM/templates/BaseClass.cpp:100
  `ComputeFullName` walks the parent chain, taking each named parent (:120) and skipping a `bit_select` under a `port`
  (:130) and a `ref_obj` under a `bit_select` (:133). A substituted constant parented at a binary operation, a
  conditional or the cont_assign names through the generate scope; one under a select through the select; one left at
  its param_assign keeps the instance; an unparented one has no name (the empty-name family). A high connection's
  index `ref_obj` under the `bit_select` under the port names through the child instance. Cases G/g01-g20, i02 i06,
  H/h01 h05, X/x04 reproduce each branch against golden. § paramBaseSelTsInstName168 follows from the same walk: a
  part-select bound's substituted constant is not parented under the select (golden names its reference by the instance,
  P/p03 `work@top.s`), where a bit-select index is (named through the select, pass 169's index branch).
- § undefKeepsOtherRootMacro168: third_party/Surelog/src/SourceCompile/PreprocessFile.cpp:1079 `deleteMacro` searches
  the file's own macros, then its includes, then its includer, and deletes from the compilation unit only when found
  there (:1104): an earlier root's macro survives. Cases U/u01 u03 u04 u06 convert, u02 u05 are controls.
- § memLeftFormalArgLoc169: third_party/Surelog/src/DesignCompile/CompileExpression.cpp:2748 `populateCoreMembers(child,
  child, result)` stamps the reduced constant at the expression node's first child (the left operand of a binary
  actual), and SV3_1aTreeShapeHelper.cpp:188-190 ties the file to the same output line: cases M/m03 (PW + 16 at `PW`),
  Y/y01-y05 (the file at the actual, B1).

**Drivers of the four evidence directories.** Every driver that reads corpus sources or corpus databases refuses to
run without `$FENCED` and skips those names by word boundary: r11u168repro `predict168.py`, `bvmirror.sh`,
`uvmdist.sh`, `orderblind.sh`, `attrib.py` (an `assert` on the four names and on every mover); v11u168repro
`rowcmp.sh`, `uvmdist.sh`; r11u169repro `census.sh` (dispatches with a whole-name exclusion filter), `moverdiff.sh`,
`rowrec.sh`, `predict.py`; r11v169repro `grid.sh`. The others have no refusal of their own, and none of them reads a
corpus source or database: they read their own cases, probe cases or evidence files (r11u168repro `case.sh`,
`controls.sh`, `dscase.py`, `grid.sh`, `switches.sh`, `predcmp.sh`; v11u168repro `case.sh`, `controls1.sh`, `dscase.py`,
`orderblind.sh`; r11u169repro `grid.sh`, `gridall.sh`, `offbytes.sh`, `pmovers.py`, `recdiff.sh`, `switches.sh`;
r11v169repro `ds.sh`, `gridrow.sh`, `offbytes.sh`, `switches.sh`, `toward.py`), or they are the gate sweep
(r11u169repro `sweep.sh`, `msweep.sh`, which runs `tests/sweep.sh` over every row as the gate does) or the census's
`SLANG_UHDM` stand-in (`tracewrap.sh`, dispatched under census.sh's filter). Process findings, none a fence breach:
r11u169repro/drivers/env.sh and r11v169repro/drivers/env.sh read the four names from RESUME.md by LINE NUMBER (78-80);
at this base they still yield the same four names as this directory's pattern read (measured), but an edit above
line 78 of RESUME.md would silently change them. v11u168repro `controls1.sh` and r11v169repro `gridrow.sh`,
`offbytes.sh`, `switches.sh`, `ds.sh` hard-code their verifiers' `/tmp` scratch paths and cannot run from the tree.

**The predictions were written before the sweeps, as far as the tree can show.** The scratch of both passes is
pruned, so no timestamp survives; what is reproducible:

- pass 168 ([evidence/process/predict168_rerun.txt](evidence/process/predict168_rerun.txt)): the committed
  `predict168.py` run over this pass's sources reproduces `pred3_posthoc_*.tsv` exactly (surelog 92, uhdm2rtlil 89
  rows) and differs from `pred2_*.tsv` by exactly PackedArrayHighConn d/t (and one probe case,
  r10earl29repro/v8_sites2, no mover): the committed script is the widened one, `pred2` the narrower regex it replaced,
  as the README says. The prediction is a function of the sources alone.
- pass 169 ([evidence/process/census169_rerun.txt](evidence/process/census169_rerun.txt)): `census.sh` + `predict.py`
  re-run on law.bin under `R11U166_OFF R11U168_OFF R11V173_OFF R11V169_INSIDESET_OFF` (its law8 on its base) reproduce
  `census_all_firings.tsv` exactly (134 rows) from the binary alone, before any sweep result; every one of the 118
  predicted names moves at this base, and the only unpredicted movers are MiniAmiq d/t, SeqDriver d and Scoreboard d,
  the UVM coin.
- pass 169's inside-set refinement holds on every set shape written here (ranges with operations, parameters of
  parameters, two-parameter ranges, mixed members, conditional members, concatenation members, a nested inside, a
  child override): direct members FTOWARD, operation and conditional members FNEUTRAL (golden leaves them unnamed).

**Operations of this pass, disclosed.** (a) The first refinement sweep was launched before its census finished and
stopped within a minute, in its probe stage (no corpus row dispatched, nothing read); its workdir was deleted, the
census completed, the prediction file written, and the sweep re-run. (b) A `pgrep -f` pattern meant for a stray
checker matched this pass's own shell and killed it (only this pass's processes were affected); an order-blind check
whose temporary files that run shared was re-run cleanly. (c) `drivers/gridall.sh` re-sourced `env.sh`, which reset
`LAW`, so a first "fix" grid measured law.bin; `env.sh` now keeps an exported `LAW`/`PRE`/`FIX` and the grid was
re-run. (d) The fix3 crash (section 4). No process that this pass did not start was touched; the live pairs'
worktrees were not touched.

## 10. Files

- [fix.patch](fix.patch): the three refinements (`git diff 50a01bc3 -- src`).
- `cases/{B,F,G,H,K,L,M,P,Q,R,S,T,U,X,Y,Z}/`: 149 cases; the first line of each names its laws; the `U/` cases, L/l01,
  L/l08 and Z/z05, z07-z10 carry an `args` file (several root files of one compilation unit).
- `drivers/`: `env.sh` (the environment, `$FENCED` from RESUME.md), `laws.py` (law -> switch map), `case.sh`,
  `grid.py`, `gridall.sh`, `fieldscore.py`, `lawsum.py`, `lawcases.py`, `obdiff.py` (a case's order-blind
  on/off/golden lines), `dscase.py`, `mkstate.sh`, `sweep.sh`, `compose.py`, `bytecancel.py`, `additive.py`,
  `bytesame.py`, `unmask.py`, `unmaskpos.py`, `fieldrows.py`, `fileaway.py`, `uvmdist.sh`, `obrow.sh`,
  `bvmirror.sh`, `census.sh` + `tracewrap.sh` (the refinements' firing census), `fixbytes.sh` (the byte controls).
- `evidence/`: `sweeps/` (sweep logs, byteverify, canaries, UVM facets, file facets), `grid/` (grid outputs, field
  scores, per-law tables), `composition/`, `changes/`, `downstream/`, `residues/`, `process/`, `fix/`.
