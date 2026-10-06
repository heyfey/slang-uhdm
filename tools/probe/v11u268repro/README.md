# v11u268: adversarial verification of r11u268

Pass 268 (tools/probe/r11u268repro) landed two laws on the expression/parameter ground, § macroStrBodyLen268
(ExprEmit records, the drain runs from ParamEmit) and § pkgQualOvrPatInitSpan268 (ParamEmit). Base `90c49b50`
(pass 266). This verification rebuilt both binaries, reproduced every headline number, and attacked the laws with
49 fresh case dirs (cases/VM 28, cases/VQ 21). It found **three breaks on legal SV**. Two of them move fields away
from golden where pristine was right; one of those also moves downstream rows IDENTICAL -> EQUIVALENT. The third
is a double correction. Each break is fixed behind its own switch in src/ExprEmit.cpp and src/ParamEmit.cpp
(src/R268.h, `R11V268_<FIX>_OFF`).

**VERDICT: the implementer's numbers reproduce bit for bit. The law ships with the three fixes below.** The fixes
move 0 corpus, 0 probe and 0 downstream databases against the law. The full fix sweep's probe, surelog,
uhdm2rtlil and downstream csvs are identical to the law sweep's, row for row.

Binaries, each frozen before it was measured (/tmp/v11u268_bin):

- pristine `48955723` (byte-identical to the main tree's build/slang-uhdm).
- law `40332276`: rebuilt from /tmp/r11u268.patch on a fresh 90c49b50. It equals the implementer's frozen law.
- fix `372aa285`: the law plus the three fixes.
- Two intermediate fix builds were never swept. `f7de33fc` had only the dedup fix. `8e51b20d` added the
  generate-local fix. Each was measured on the fresh grid only, and every number below is the final binary's.

`R11V268_OFF` gives the law's bytes and `R11U268_OFF` gives pristine's bytes on every case-view (gridsum_fresh,
the FV / FU columns).

## Targeted rows (as the implementer claims, reproduced)

**MiniAmiq d/t: `differ:endcol(2)` -> `differ:depth(1)`, a CHANGE.** The first record #217949 is cleared in both
modes. The law sweep's rows and the fix sweep's rows are identical:

    MiniAmiq,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
    MiniAmiq,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)

uhdm-strictcmp --max 3 on pristine's database against golden gives `#217949 endcol` (`$sformatf`
svaunit_test.svh 433:14, golden 434:75, ours 434:85) and then `#223178 depth`. On the law, the first and only
record is `#223178 depth`: golden `class_var ...create_component` uvm_registry.svh 63:20, ours `class_typespec
uvm_component` 51:39, objects 435559 vs 435553. uhdm-cmp reads 0 lines in both modes.

The record away census (drivers/away.py against golden) reads `dist 111 -> 108 lost=0 gained=3` in both modes.
The two modes' goldens are byte-identical.

Integration note: pass 271 (a37b87c18) has since cleared #223178 on main. On the integrated tree, MiniAmiq's
remaining records are the inside-set package-parameter fold (#227043 / #227046 / #227049, ExprEmit; see
r11u271repro).

The src diff of the verified patch 3-way-applies cleanly to a37b87c18.

## Gates (pristine, law and fix sweeps; tests/sweep.sh --jobs 3, workdirs /tmp/v11u268_sw{P,L,F})

| stage | pristine | law | fix |
|---|---|---|---|
| probe | 3611 + 476, reg=0 conv=0 chg=0 | **3623 + 464, reg=0, conv=12, chg=0** | identical csv to law |
| surelog | d 476+4, t 470+4, reg=0 | the same; reg=0 conv=0 **chg=2 (MiniAmiq d/t)** | identical csv to law |
| uhdm2rtlil | 803/1/67 both modes, reg=0 | reg=0 conv=0 chg=0 | identical |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, csv identical to pristine's | identical |

The 12 probe conversions match the implementer's list, each `STRICT_NOTEQUAL -> EQUAL` (evidence/rowdiff.txt):

- § macroStrBodyLen268: r10uvm104 g104_a1_sep and g104_a2_shapes; r10v104 v11_uvmreal, v12_seps, v1_pastecount,
  v3_ifdef, v4_nested and v7_esc.
- § pkgQualOvrPatInitSpan268: r10vearl108 m_gen108, r11u69 grid/g9_child, and r11v69 grid/v4_nestinst and
  grid/w5_ovr.

All three sweeps exit 1 on the law-index check alone. The worktree's src named this pass's laws while
tests/LAWS.md was still the base's; the regenerated LAWS.md is part of the patch. The only surelog csv
difference apart from MiniAmiq is the LowMemLib / LowMemPkg testflags detail text, which carries the workdir
path.

The other checks:

- **byteverify** (r11v75repro/byteverify.sh, `SELFCHECK=1`, hard-link mirrors filtered by `$FENCED`,
  drivers/bvmirror.sh; evidence/byteverify_*.txt).
  - Law vs pristine: surelog 2 of 952 (MiniAmiq d/t, hash `a976c52c5c53`); uhdm2rtlil 0 of 1608; downstream 0
    of 805; probe 12 of 4087 (the 12 conversions).
  - Fix vs law: 0 in every corpus and 0 of 4087 probe.
  - Scoreboard default is byte-identical to pristine. The implementer's withdrawn first law had a Scoreboard
    serialization-order mover; the final law does not.
  - SELFCHECK reads N-1 per corpus (951/952, 1607/1608, 804/805). It compares every file with one fixed file,
    and that file equals itself.
  - A first run with all three lanes in one mirror read 3363/3365. That is because
    downstream/1DUnpackedArray and uhdm2rtlil/testflags/1DUnpackedArray are byte-identical, so two files equal
    the fixed reference. It is not a missed mover. Per-corpus runs are the measurement.
- **Firing census** (drivers/tracecensus.sh with the fix binary before the fix sweep, filtered by `$FENCED`;
  evidence/census_predict.txt).
  - It is identical line for line to the implementer's census_predict.txt: 14 predicted byte movers, exactly the
    byteverify movers.
  - None of the three fixes fires on any probe, corpus or downstream database, so 0 fix-vs-law movers were
    predicted, and byteverify confirms 0.
  - Positive control: the same trace fires the three fixes on r11v11u8repro/v3, VM/vm02 and VQ/vq01
    (`macroStrBodyLenCommentAbstains268v abstain comment-in-string`, `macroStrBodyLenDupEvent268v dup 1:30`,
    `pkgQualOvrPatGenLocalKeepsRef268v abstain struct-gen-local C`).
- **Away census** (chain-free record multisets, drivers/away.py; evidence/away_probe.txt): all 12 probe movers
  read lost=0 (for example `g104_a1_sep dist 44 -> 0 gained=44`), and uhdm-cmp reads 0 lines on each.
- **Canaries** (evidence/canaries.txt, all three sweeps): surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0,
  ctcan2 surelog ok=58 PASS, uhdm2rtlil ok=2 PASS.
- **Binary audit** (evidence/binaudit.txt): in each sweep, 3265 of the 3315 fence-filtered cmds.txt name that
  sweep's own frozen binary. The other 50 carry no slang line, and no line names another binary.
- **Determinism** (drivers/det.sh, three concurrent draws with the fix binary; evidence/determinism.txt): one
  hash per row-mode for Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen. Every
  hash equals the fix sweep's and the implementer's law hashes. Scoreboard t and Rggen t write no database.

## The implementer's grid and controls, reproduced

- **Grid** (79 dirs, 158 case-views; evidence/grid_impl.txt, gridsum_impl.txt): 124 moving, 90 entering
  STRICT_EQUAL, 0 leaving, every rc 0.
  - The P / L / OFF verdict fields (cmp, cmplines, strict, rc) are identical line for line to the implementer's
    evidence/grid.txt.
  - The fix equals the law on all 158 case-views.
- **Byte controls** (drivers/ctlbytes.sh, bytes first on three binaries; evidence/controls_bytes.txt).
  - Scope: the implementer's 61 dirs plus 12 more (r10uvm122, r10v122, r10v132, r11u104, r11u218dec,
    r11u220 / v11u220, r11u227 / v11u227, r11u8, r11v11u8, r11v125), 9462 case-views.
  - No exit code changes. The known `--elabuhdm` rc 139 on r11u254 F/f04 and v11u254 vf02 / vf04 is the same
    on all three binaries.
  - The law moves 12 case-views:
    - r11u124 c13/q01_override, r11u131 pat/t07_override and r11u133 pqs/q06_override, both views: the
      implementer's 6, entering STRICT_EQUAL.
    - **v11u160repro/cases/MM/q23 in both views: a mover the implementer's controls did not report.** Surelog
      fails to parse that case (`$display(`STR(a "q" b))`), so there is no golden and case.sh prints only
      SURELOG_FAIL, which hides the byte change. Our literal moves 4:20-24 -> 4:20-31. It cannot be judged.
    - r11v11u8repro/v14 in both views: stage 1 on all three binaries, dump census 0 lost / 0 gained (residue
      R3 below).
    - **r11v11u8repro/v3 in both views: BREAK 2 below.**
  - The fix equals the law on every control except r11v11u8 v3, which it restores to pristine's bytes.

## The breaks and the fixes

### BREAK 1: a header included twice doubles the correction. Fix § macroStrBodyLenDupEvent268v (`R11V268_DUPEV_OFF`)

A header without an include guard holds a call of a stringification macro, and it is included twice: into two
packages (vm01), two modules (vm02), a package and a module (vm10), twice in one block (vm19), or as a class
included into two packages (vm20).

Each inclusion is its own macro expansion buffer, so the record step's `callEndLoc` test keeps two events for
the same file line. The drain's `add()` then **sums** both corrections on every object of that line.

- Golden is `a` at body.svh 1:45. Pristine has 1:55, which is wrong by +10. The law has 1:35, which is wrong by
  -10.
- uhdm-strictcmp reads `STRICT_NOTEQUAL endcol` under both. Records: P 24, L 20 objects differing.
- On the law, vm02 stays EQUIVALENT downstream: the src attributes are wrong the other way.

The fix drops an event equal to an earlier one in file, line, literal start and end, call end, golden end,
threshold and correction.

- All 10 case-views enter STRICT_EQUAL (`vm02 75 objects`), and vm02 goes EQUIVALENT -> IDENTICAL downstream.
- The away census (fix vs pristine) reads lost=0 with gained 12-24.
- Events that differ are kept. vm17 includes the same header under two definitions of the macro; it stays
  STRICT_EQUAL on law and fix.
- The guarded header (vm18) never doubles.

### BREAK 2: a comment inside the stringification. Fix § macroStrBodyLenCommentAbstains268v (`R11V268_STRCMT_OFF`)

`` `define CM(__x) `"/*c*/__x`" `` (the existing control r11v11u8repro/v3, and vm24), `` `define CO `"/*c*/abc`" ``
(vm21) and `` `"a/*x*/b`" `` (vm26) all keep the comment in Surelog's spliced literal. Golden's literal is
11:21-34 for `"/*c*/plainc"`, and its value holds the comment. slang's literal drops the comment, so
`raw.size()` is not golden's length.

**Pristine's columns were golden's. The law moved them away.**

- Dump census law vs pristine: v3 lost=4 / 6, and vm21 / vm24 / vm26 lost=13 (definition view) and 21
  (elaborated view).
- Downstream: vm21, vm24 and vm26 go **IDENTICAL -> EQUIVALENT** under the law.

All of these cases are uhdm-cmp stage 1 on every binary, because the literal value differs, so neither gate
nor grid verdict shows the move.

The fix makes the law stand aside when a `/*` or `//` is written between the stringification markers.

- Pristine's bytes come back on all 8 case-views.
- Downstream returns to IDENTICAL.
- The away census reads lost=0.

### BREAK 3: the generate rule on a generate-local parameter. Fix § pkgQualOvrPatGenLocalKeepsRef268v (`R11V268_GENLOCAL_OFF`)

§ pkgQualOvrPatInitSpan268's generate rule moved the op75 to the initializer's span for ANY bare name in an
instance inside a generate block.

When the parameter is declared in the **same** generate block as the instance, golden keeps the reference span.
For `if (1) begin : g localparam cfg_t G = '{n: 6}; leaf #(.C(G)) u (...); end`, golden has 13:15-16 (`G` in
`.C(G)`); the law has 12:26-33 (the initializer).

Affected cases: vq01 (if-generate), vq16 (for-generate with genvar-dependent `L`), vq18 (case-generate), vq19 (a
`bit` formal) and vq20 (a generate-local and a module localparam side by side). Dump census law vs pristine:
lost=3 to 9 lines.

A parameter of an **enclosing** generate block takes the initializer span as the law says (vq17, gained=2 under
the law). So does a module parameter (vq02, vq11), which enters STRICT_EQUAL.

The fix stands aside when the referenced parameter's parent scope is the instance's own generate block.

- Pristine's bytes come back on vq01 / vq16 / vq18 / vq19.
- vq20 keeps the law's move for its module localparam: lost=0, gained=3.
- The away census reads lost=0 on all.

All of these are stage 1 on every binary, because a generate-local struct parameter makes uhdm-cmp fail
elsewhere, so the gate cannot see them.

Each of the 13 fix-moved case dirs (26 case-views, plus r11v11u8 v3 in both views) returns to the law's bytes
under exactly one fix switch (evidence/attrib_fix.txt, and the per-switch columns of grid_fresh.txt).

## The fresh grid (cases/VM, cases/VQ; drivers/grid3.sh, gridsum3.py; evidence/grid_fresh.txt, gridsum_fresh.txt)

49 case dirs in both views, 98 case-views. Configurations: P, L, F, FV (fix + `R11V268_OFF`), FU (fix +
`R11U268_OFF`), and the fix with each `R11V268_*` switch off: 784 lines, **every rc 0**.

- F against P: 68 moving, 50 entering STRICT_EQUAL, **0 leaving**, no uhdm-cmp line count changing. FV equals L
  and FU equals P on 98 of 98.
- F against L: 26 case-views, each attributed to exactly one fix switch.
- Away census F against P (evidence/away_fresh_fix.txt): **0 lost on all 68 movers**. Law against pristine on
  the 26 fix case-views (evidence/away_fresh_law.txt) shows the losses described above.
- Downstream on the 49 dirs (evidence/downstream_fresh.txt, pristine / law / fix):
  - 30 IDENTICAL on all three.
  - 10 EQUIVALENT -> IDENTICAL under both law and fix.
  - vm02 EQUIVALENT / EQUIVALENT / IDENTICAL (break 1).
  - vm21 / vm24 / vm26 IDENTICAL / **EQUIVALENT** / IDENTICAL (break 2).
  - 2 EQUIVALENT and 2 DIVERGENT on all three, all stage 1: vq03, vq04, vq05, vq06.
  - vm28 SURELOG_FAIL (Surelog rejects `` `"a\tb\\c`" ``).
- Shapes that hold under the law and the fix:
  - Macro side: a stringification and a plain macro on one line (vm03); a function-like macro inside the
    string (vm04); an empty string (vm05); two different stringification macros on one line (vm06); a module
    header default followed by another parameter (vm07); a comparison in a ternary (vm08); tabs (vm09); class
    specializations (vm11); a short body (vm13); `__LINE__` before the call (vm15); two statements on the line
    (vm16).
  - Pattern side: a two-line pattern (vq07); a `default:` pattern (vq08); positional with two parameters
    (vq09); a two-level generate qualified (vq10); a generate module header parameter (vq11); a `bit` formal
    qualified in a generate (vq13); a generate interface (vq14, line -> type toward golden, the walk then
    diverging at a pre-existing #284); a qualified actual used in port and replication slots (vq15).
- Shapes unchanged by both: a long macro name with a short body (vm14); whitespace runs inside the
  stringification (vm22 / vm23 / vm27, STRICT_EQUAL on all three binaries); a formal argument with spaces
  (vm25); stage 1 shapes moving toward golden (vm12, vq03, vq05, vq12).

## Residues, ranked (all wrong on pristine too unless stated)

1. **R1: macro-body width in UhdmExporter** (sister ground, REPORT). UhdmExporter's buildMacroExpansions `expLen`
   is the exact site of the spliced-text width. The law and the fixes transcribe it on this ground.
2. **R2: an `include repeated under two different macro definitions on the same line layout.** vm17 is right
   because the two layouts differ. If they coincided with different corrections, events keyed by file and line
   could not tell the inclusions apart. Not reproduced; noted from the code.
3. **R3: a nested macro with an empty body inside the stringification** (r11v11u8repro/v14, `` `"`EMPTY  tail`" ``).
   Golden's literal 9:23-46 holds text slang does not produce. Stage 1 on every binary. The law moves the call
   end 32 -> 30 where golden reads 47: further from golden numerically, with no line lost or gained by the
   census.
4. **R4: v11u160repro/cases/MM/q23 moves bytes but cannot be judged** (Surelog has no golden). The
   implementer's controls missed it because case.sh prints no md5 on SURELOG_FAIL lines.
5. **R5: § pkgQualOvrPatInitSpan268's unreached shapes.** A generate instance array (vq04: the generate test
   reads the instance's direct parent scope, which is the array); `$unit::` and `$unit` bare (vq05, vq06);
   the stage 1 face of generate-local and port-parameter overrides (vq01, vq03, vq16 to vq19: uhdm-cmp fails on
   every binary, the fix only restoring pristine's columns).
6. The implementer's residues R1-R5 stand as written: m11, m41, m42, m26; q16, q19, q20; pass 266's items; the
   TaskFuncEmit subroutine-local array end column; the ParamEmit import-copy `work@top` full name.
7. A note on the implementer's README: the abstention trace of the bit branch prints `bit-bare-body` also when
   the generate switch is off (only the trace text, not the bytes).

## Sister-ground faces (reported, nothing written there)

These are as the implementer reported them:

- The type-parameter use face #223178 / #218195 / #218207: TypeEmit's 180 / 183 / 186 family, cleared on main
  by pass 271.
- UhdmExporter buildMacroExpansions `expLen`.
- TaskFuncEmit's subroutine-local `int v [0:3]` end column.
- m34's elaborated cont_assign Rhs: ModuleEmit emitContAssigns.

## Process

- **Worktrees:** /tmp/wt_v11u268 (law + fixes) and /tmp/wt_v11u268pris (pristine), both at 90c49b50. A
  temporary /tmp/v11u268_apchk at a37b87c18 was used for the integration apply check and removed.
- **Scratch:** /tmp/v11u268_*.
- **Sweeps:** all ran from /tmp/wt_v11u268 so probe databases embed the same paths.
- **Aborted sweep:** a first fix-sweep invocation found no binary at /tmp/v11u268_bin/fix and ran nothing:
  "missing tool", no csv, workdir deleted. The binary had been renamed to bring in the third fix.
- **Order of runs:** the census with the final fix binary was frozen before the fix sweep.
- **The fence:**
  - Every driver reads `$FENCED` from tools/probe/r11u107repro/canaudit.sh fail-closed.
  - Every path list (controls, mirrors, cmds audit, probe compare) was filtered by word boundary before any
    file was opened.
  - The census dispatched with the harness filter built from `$FENCED`.
  - No fenced test was dispatched, read or decoded outside the gate sweeps.
- **Processes:** none was signalled.
- **Cases:** the first line of each case was set to its law name after the grid. The grid was then rerun from
  a fresh store, with every verdict field identical.

## Drivers (copied from r11u268repro unless new)

- env.sh, case.sh: one case-view against a cached golden.
- grid3.sh, gridsum3.py (new): P / L / F / FV / FU plus per-switch configurations, with summary.
- ctlbytes.sh (new): byte controls on three binaries, bytes first.
- tracecensus.sh, predict.py: the firing census.
- bvmirror.sh: fence-filtered byteverify mirrors.
- awayall.sh, away.py, awaydump.py: away censuses.
- dscases.py: downstream on cases.
- det.sh: determinism draws.
