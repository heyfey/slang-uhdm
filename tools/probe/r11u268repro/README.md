# r11u268: pass 268, the expression/parameter ground (MiniAmiq's #217949 and the macro-stringification end columns; the package-qualified override's pattern span)

Base `90c49b50` (pass 266). Production files: src/ExprEmit.cpp, src/ParamEmit.cpp and the new src/R268.h.
Binaries, frozen before any measurement they carry: pristine `48955723` (byte-identical to the main tree's
build/slang-uhdm), law `40332276`. Two laws, five switches; `R11U268_OFF` drops both and gives pristine's bytes on
every case-view (158 of 158). `R11U268_TRACE=<dir>` writes one file per process (`<pid>.268`, first line
`OUT <-o path>`) with every firing and every abstention (`<law> abstain ...`).

## Verdict per targeted row

**MiniAmiq d/t: endcol(2) -> depth(1), the head #217949 CLEARED in both modes.** The fresh rows of the law sweep:

    MiniAmiq,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
    MiniAmiq,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)

Pristine's first records (evidence/miniamiq_heads.txt): `#217949 endcol` the `$sformatf` of svaunit_test.svh
433:14, golden end 434:75, ours 434:85; then `#223178 depth`. On the law binary the first and only record is
`#223178 depth` (golden `class_var uvm_pkg::uvm_component_registry::create_component` at uvm_registry.svh 63:20,
ours `class_typespec uvm_component` 51:39): **MiniAmiq now stands entirely on the sister ground's type-parameter
use face** (TypeEmit's 180 / 183 / 186 family, the live sister pass's work). The count is the same object walk
(435559 vs 435553 objects), so this is a first-field change by clearing, not a regrowth. SeqDriver d/t keep
depth(1) with #218195 / #218207 (the same sister face; no law of this pass fires a byte there).

No other corpus row moves: surelog 946 + 8 (default 476 + 4, testflags 470 + 4), uhdm2rtlil 1606 + 0, downstream
803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, as the base. Earlgrey_0_1 d/t, BlackBePipeInt d/t,
Rggen d, SimpleUVM d/t, Scoreboard d and BuildUVMPkg d/t stay CMP_EQUAL.

**PROBE: 12 CONVERSIONS (STRICT_NOTEQUAL -> EQUAL), 0 changes, 0 regressions**, 3611 + 476 -> **3623 EQUAL + 464
STRICT_NOTEQUAL** (evidence/fresh_rows.txt, fresh_changes.txt):

| case | before | after (fresh csv row) | law |
|---|---|---|---|
| r10uvm104repro/g104_a1_sep | differ:endcol(44) | `r10uvm104repro/g104_a1_sep,EQUAL,,equal` | § macroStrBodyLen268 |
| r10uvm104repro/g104_a2_shapes | differ:endcol(24) | `...,EQUAL,,equal` | § macroStrBodyLen268 |
| r10v104repro/v11_uvmreal | differ:endcol(8) | `...,EQUAL,,equal` | § macroStrBodyLen268 |
| r10v104repro/v12_seps | differ:endcol(44) | `...,EQUAL,,equal` | § macroStrBodyLen268 |
| r10v104repro/v1_pastecount | differ:endcol(4) | `...,EQUAL,,equal` | § macroStrBodyLen268 |
| r10v104repro/v3_ifdef | differ:endcol(8) | `...,EQUAL,,equal` | § macroStrBodyLen268 |
| r10v104repro/v4_nested | differ:endcol(24) | `...,EQUAL,,equal` | § macroStrBodyLen268 |
| r10v104repro/v7_esc | differ:endcol(4) | `...,EQUAL,,equal` | § macroStrBodyLen268 |
| r10vearl108repro/m_gen108 | differ:line(3) | `...,EQUAL,,equal` | § pkgQualOvrPatInitSpan268 (generate rule) |
| r11u69repro/grid/g9_child | differ:line(2) | `...,EQUAL,,equal` | § pkgQualOvrPatInitSpan268 |
| r11v69repro/grid/v4_nestinst | differ:line(2) | `...,EQUAL,,equal` | § pkgQualOvrPatInitSpan268 |
| r11v69repro/grid/w5_ovr | differ:line(3) | `...,EQUAL,,equal` | § pkgQualOvrPatInitSpan268 |

The eight r10v104 / r10uvm104 cases are pass 266's "8 macro-paste end columns" bucket, the same family as
MiniAmiq's #217949 (brief item (1)); the four operation-line cases are pass 266's "4 elaborated-param_assign
operation lines" bucket.

## 1. MiniAmiq #217949, decoded

svaunit_test.svh 433-434: `return $sformatf("Automatically generated on %s by %s with %s",` /
`get_date_with_format("%Y-%m-%d"), get_user_name(), `SVAUNIT_VERSION_STRING);` with
`` `define SVAUNIT_VERSION_STRING `"`SVAUNIT_NAME``-```SVAUNIT_MAJOR_REV``.```SVAUNIT_MINOR_REV`" ``
(svaunit_version_defines.svh). Surelog's preprocessor (PreprocessFile::evaluateMacro, the listener's enterString)
turns the one-line body into the plain literal `"SVAUNIT.3.2"` (13 columns: the `` X `` windows collapse to `.`,
§ macroPasteDotText104, the nested macros expand inside) and splices THAT text in place of the 23-column call. The
literal spans 434:61-74, the `)` sits at 74, the call ends at 75. Our column model (UhdmExporter
buildMacroExpansions' `expLen`, which sizes a one-line body from its written text plus its nested replacements, and
special-cases only the `"<formal>`" body, § ppMacroBodyLines160's stringify rule) sizes this body at 23 and shifts
the rest of the line by +0 instead of -10; the literal's own end (ExprEmit's StringLiteral case, start + the
expanded length mapped through the macro buffer) came out 2 columns long in the reduction. Reduced to
cases/M/m01_sformatf_tail (golden 10:12-10:50 / literal 10:36-49, ours 10:60 / 10:51).

The fix that would size the body right sits in UhdmExporter (the sister ground). This pass transcribes Surelog's
rule on its own ground as a design-final re-layout of the call's line (the pattern § strLitPpEscIdShift224 set),
which is exact because the spliced text is known: the literal itself plus the body's kept tail.

## 2. The laws

### § macroStrBodyLen268 (ExprEmit: the StringLiteral case records; the drain runs from ParamEmit's drainPaNameCopySrc38 after strLitPpLineShiftDrain224)

**Statement.** A string literal the preprocessor produced from a ONE-LINE `define body that is exactly one
stringification `` `"...`" `` (an escaped `` `\`" `` stays inside), called from a file (directly, or through a chain of
object-like macros each of whose body is exactly the next call), is spliced by Surelog as the literal's own text:
the literal spans [its start, its start + its length), and the call's line from the end of our call onward moves
by (literal length + the body's kept tail - our expansion width), the kept tail being § macroBodyTrailingComment125's
(everything before a `//` comment, else the rest minus `\r`). Design-final, on every located object of that file
and line: an object starting at or before the literal and ending where our literal or our call ended ends at
golden's literal end; any other start or end at or past our call end moves by the correction. Our call end is read
at drain time through fileLineCol.

- `R11U268_STRMACLEN_OFF` drops the law (and both sub-rules).
- `R11U268_STRMACTAIL_OFF`: the tail rule. Text after the stringification with no backtick and no continuation
  (`` `define VY `"...`", 5 ``) is spliced as written; the objects written in that tail move with it (their
  threshold is where our tail begins). Without it the law abstains (`body-text-after`).
- `R11U268_STRMACFORMALS_OFF`: a function-like macro whose body is the stringification and blanks
  (`` `define F(x) `"x``-``tail`" ``); the call spans through its `)`. Without it the law abstains (`formals`).

**Abstentions** (each traced): a literal from an argument buffer (`not-body`), a literal that is not the body's
first token (`not-whole-body`), a body that is not a stringification, a tail holding a macro, a paste or a
continuation, a function-like body with a tail, a call inside another macro's argument (`call-in-argument`), a chain
hop whose body is not exactly one object-like call, a call end on another output line or a threshold not past the
literal (`layout`).

**The store.** The events live in a fixed array (no heap allocation while the design is emitted) and the drain
walks the design only when an event moves something. A first frozen law (`20b6c8ab`, withdrawn) used a map and
called fileLineCol at the literal: its byteverify showed Scoreboard default as a byte mover that the firing census
had not predicted (the census line held two `event`s with no `move`). Its dump was identical to pristine's
line for line, uhdm-strictcmp `--no-canon` read the two equal on all 242071 objects, and 359 bytes differed in one
region of the same-size file: serialization order only. Bisection on scratch binaries: skipping the event record
restored pristine's bytes, skipping only the drain did not, and skipping only fileLineCol or only the column
reads did; the record's heap traffic shifts a later address-ordered writer of pristine's export (pass 258's list
of address-ordered loops is the candidate set; three glibc malloc tunables left both binaries' hashes unchanged,
so the dependence is on the allocation sequence, not on absolute addresses). A second draft (`60ba6625`,
withdrawn after its grid) read our call end from lineShifts directly to avoid fileLineCol; its grid moved
cases/M m14 and m32 (both views) away from golden, 4 case-views leaving STRICT_EQUAL, because the one-line
output-column model (§ ppOutputCol166) adjusts those calls outside lineShifts. The frozen law reads fileLineCol
at drain time from a fixed store; its grid is byte-identical to the first law's on all 1264 lines, and Scoreboard
default is byte-identical to pristine's in the law sweep and in three concurrent draws.

### § pkgQualOvrPatInitSpan268 (ParamEmit, the elaborated param_assign's op75 under an override)

**Statement.** An instance parameter OVERRIDE whose actual is a PACKAGE-QUALIFIED reference to a parameter with an
assignment-pattern initializer (`leaf #(.C(p::B))`, positional `#(p::B)` too) substitutes that pattern with the
op75 at the referenced parameter's INITIALIZER span (`'{n: 8}` at the package line), where pristine anchored it at
the reference. The constants inside already carried the package spans; only the op75's own span moves. An
override in an instance declared inside a GENERATE block (if, for, case; any depth) does the same for a BARE name,
whether it reaches a package parameter through an import or the module's own localparam. A bare name in the module
body keeps the reference span (golden's answer, pristine's). Both the struct-formal branch and pass 108's
range-less integral formal branch (`bit` / integer atoms, `ovNonStructPat108`) carry it.

**Decode.** Measured per instance on one golden (cases/Q and the /tmp grid it came from): qualified named,
qualified positional, qualified `parameter` (not localparam), qualified into a `bit` formal, qualified inside
generate: the package initializer's span; bare via header import, body `import p::*`, explicit `import p::B`,
module localparam, bare into a `bit` formal: the reference span in the module body; bare in if-generate, for-
generate, two-level generate, for a package or a module localparam: the initializer's span. Surelog's qualified
branch of getValue (the paPackage_scope branch of CompileExpression) returns the package parameter's own Rhs, whose
location the elaborated copy keeps; a bare name compiled at the reference keeps the reference's location except
in a generate scope, which resolves it by value.

- `R11U268_QUALOVRSPAN_OFF`: the qualified rule. `R11U268_GENOVRSPAN_OFF`: the generate rule.
- Abstentions (traced): a bare name in the module body (`struct-bare-body`, `bit-bare-body`), an unpacked struct
  formal with a qualified actual (`unpacked-qualified`, refused by pristine's branch already).

## 3. Grid (cases/M, cases/Q; drivers/grid.sh; evidence/grid.txt, gridsum.txt, away_cases.txt, downstream_cases.txt)

79 case dirs (M 55 for § macroStrBodyLen268, Q 24 for § pkgQualOvrPatInitSpan268; each case's first line names its
law) in both views (default and `--elabuhdm`): 158 case-views on eight configurations (pristine, law, law +
`R11U268_OFF`, the law with each of the five switches off), 1264 lines, **every line rc 0**.

| | M | Q | total |
|---|---|---|---|
| case-views | 110 | 48 | 158 |
| moving | 92 | 32 | 124 |
| entering STRICT_EQUAL | 78 | 12 | 90 |
| leaving STRICT_EQUAL | 0 | 0 | 0 |

- `R11U268_OFF` gives pristine's bytes on 158 of 158; no exit code and no uhdm-cmp line count changes.
- Attribution: STRMACLEN alone 68; STRMACLEN with its TAIL sub-rule 12 (m22, m40, m43, m46, m47) and with its
  FORMALS sub-rule 12 (m09, m10, m36, m37, m44, m45), each moving back under the sub-switch alone; QUALOVRSPAN 18;
  GENOVRSPAN 8; both Q switches 6 (q17, q21, q24, each holding one qualified and one generate instance, every
  instance moved by one switch).
- **Away census** (drivers/awayall.sh): 0 lost on all 124 movers (records where both sides pass stage 1, dump
  lines otherwise).
- The movers that do not end strict-equal: M m23 (generate), m29 (class property), m35 ($bits), m49 (extern
  method), m53 (program), m10 and Q q09 / q16 / q18 / q21 (default view) are uhdm-cmp stage 1 on both binaries,
  their dump distance falling with 0 lost; m34 (an elaborated `assign o = `VS` to a net) moves to its older face,
  the shared cont_assign Rhs (ModuleEmit, the sister's bucket, #28 file); Q q07 / q10 / q12 / q17 / q22 / q24
  keep an unrelated import-copy face of the test package (the ref_typespec full name `work@top` on the unpacked
  struct parameter `U`'s copy, residue R5).
- **Constant slots** (q18: the overridden pattern member in a part-select bound, an indexed-part-select base, a
  replication count): stage 1 on both binaries before and after, 0 lost. Macro-born tokens from includes in
  another file: M m12 (definitions in an included header) and m13 (the use in an included body), both entering.
- **Downstream on the 79 case dirs** (drivers/dscases.py, one binary at a time): **34 EQUIVALENT -> IDENTICAL**
  (the src attributes of every object after the call now match), 36 IDENTICAL on both, 8 EQUIVALENT on both, 1
  DIVERGENT on both; none leaves IDENTICAL.

## 4. Byte controls (drivers/controls.sh; evidence/controls_dirs.txt, controls.txt, controls_sum.txt, controls_attrib.txt)

61 earlier repro dirs: pass 266's 45, r11u266 / v11u266, r11u269 / v11u269, and the dirs of the shapes these laws
touch: r10v104, r10uvm104, r11u160 / v11u160 (the macro-body line model), r11u125, r11u224 / v11u224, r11u69 /
r11v69, r11u133, r10vearl108, r10earl108. 4191 case dirs, 8382 case-views in both views, every path list
filtered by `$FENCED` before any file was opened.

- **6 move, 6 enter STRICT_EQUAL, none leave; no exit code and no uhdm-cmp line count changes**:
  r11u124repro/c13/q01_override, r11u131repro/pat/t07_override, r11u133repro/pqs/q06_override, each in both views,
  each moved by `R11U268_QUALOVRSPAN_OFF` alone (the other switches leave the law's bytes).
- The rc 139 lines are the known `--elabuhdm` crashes (r11u254 F/f04, v11u254 vf02 / vf04), identical on both
  binaries.

## 5. Gates (evidence/sweep_pristine.log, sweep_law.log, rowdiff.txt)

Both sweeps are tests/sweep.sh `--jobs 3`, workdirs /tmp/r11u268_swP and /tmp/r11u268_swL (equal length).

| stage | pristine | law |
|---|---|---|
| probe | 3611 + 476, regressions=0 conversions=0 changes=0 | **3623 + 464, regressions=0, conversions=12, changes=0** |
| surelog | default 476 + 4, testflags 470 + 4; regressions=0 | the same; regressions=0 conversions=0 **changes=2** (MiniAmiq d/t endcol(2) -> depth(1)) |
| uhdm2rtlil | 1606 + 0; regressions=0 | the same; regressions=0 conversions=0 changes=0 |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, verdict diff 0 |

Both sweeps exit 1 on the law-index staleness check alone (the pristine sweep ran the frozen pristine binary while
the worktree's src already named this pass's laws; the regenerated tests/LAWS.md is part of this patch). Row by
row, law against pristine: surelog differs only in the MiniAmiq rows and the LowMemLib / LowMemPkg testflags
detail text (the workdir path, environment); uhdm2rtlil 0 rows; downstream 0 rows; probe the 12 rows above. No
strict column worsens anywhere.

**The firing census** (drivers/tracecensus.sh on the frozen law, before the law sweep; drivers/predict.py;
evidence/census_firings.txt, census_predict.txt) predicted 14 byte movers by name: the 12 probe conversions and
MiniAmiq d/t. Firings that move no byte are listed apart: § macroStrBodyLen268 records (literal end already
golden's, correction 0 or nothing after the call on the line) or abstentions on Scoreboard d, SeqDriver d/t,
SimpleUVM d/t, ApbSlave d/t, ten ibex uhdm2rtlil tests in both modes and 18 probe cases (r10uvm104 a4 / a5 / a6,
r10v104 v2, r10v132 v4_home, r11u8 and r11v11u8), and § pkgQualOvrPatInitSpan268's abstentions (bare names in a
module body) on 15 corpus tests in both modes, Earlgrey_0_1 among them, and their downstream rows.

**byteverify** (`SELFCHECK=1` on hard-link mirrors filtered by `$FENCED`, drivers/bvmirror.sh with BV_CORPORA; the
8 fenced row-mode databases left out and never opened; evidence/byteverify_corpora.txt, byteverify_probe.txt):

| corpus | movers | names | SELFCHECK |
|---|---|---|---|
| surelog | 2 of 952 | MiniAmiq d/t | 951 of 952 |
| uhdm2rtlil | 0 of 1608 | | 1607 of 1608 |
| downstream | 0 of 805 | | 804 of 805 |
| probe (a byte compare) | 12 of 4087 | the 12 conversions | |

Exactly the 14 predicted, nothing else. SELFCHECK compares every file with ONE fixed file, so it flags N-1: the
fixed file is identical to itself; that is the self-check's artifact (pass 201's 2559-of-2560 shape), not a missed
mover.

**MiniAmiq's dump** (law against pristine, both modes): 24 lines differ, all end columns: the `$sformatf` at
433:14 ends 434:75 (was 85) in its five listings, and a `$sformatf` / `assignment` pair at 97:24 / 97:7 ends
97:80 (was 90) in its listings, another call of the same macro. **Away census** (drivers/awaycorp.sh flat, and
drivers/awayrows.py chain-keyed over every byte mover of the two sweeps; evidence/away_corpus.txt,
away_rows.txt): MiniAmiq d/t dist 111 -> 108, **0 lost**, 3 gained; chain-keyed **away=0** toward=3 on both, and
away=0 on all 12 probe movers.

**Other checks:**
- uhdm-cmp reads 0 lines on MiniAmiq d/t (STRICT_NOTEQUAL is judge-equal) and on every probe mover (EQUAL).
- **Canaries** (tools/probe/r11u107repro/canaries.sh): surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0.
- **ctcan2**: surelog PASS (`EXPECT_UNKNOWN=1`, ok=58), uhdm2rtlil PASS (`EXPECT_UNKNOWN=6`, ok=2).
- **Binary-path audit** (evidence/binaudit.txt): 3265 of the 3315 fence-filtered cmds.txt name
  `/tmp/r11u268_bin/law`; the other 50 carry no slang line; none names another binary.
- **Determinism** (drivers/det.sh; evidence/determinism.txt): three concurrent draws per row-mode of Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen with the law binary: one hash per row-mode
  (3 of 3 each), every one equal to the law sweep's (Scoreboard and Rggen testflags write no database).

## 6. The probe residue at the base, refreshed (evidence/residue_buckets.txt, residue_chains.txt)

drivers/classify.py and chains.py (pass 266's) on the 476 STRICT_NOTEQUAL cases of the pristine sweep: the
buckets are pass 266's minus its 21 movers. This pass worked the two ground-A buckets it could transcribe whole (8
macro-paste end columns, 4 operation lines). Decoded on the way, for the sister ground:

- **Subroutine-local unpacked array typespec end column** (6 cases: r10uvm122repro g122_b_shape, g122_d_pos,
  g122_f_clone, r10v122repro q1shapes, q7extra, r10v96repro v96_a4_operands): `int v [0:3];` in a function or task
  (module, package or class) lists its array_typespec at 9-17 in golden and 9-16 in ours; a `[N]` dimension and
  the same declaration in an initial block match. TaskFuncEmit, the fixed-size declarator array of the tf-item form
  (the `aEnd = dim0->sourceRange().end() - 1` span beside § classScopedTdDeclTsUnsupported11's site 4c, and its
  twin in the other tf-item road). Ground B, REPORT.
- The larger buckets stand as pass 266 decoded them (the shared elaborated cont_assign Rhs, ModuleEmit
  emitContAssigns, about 75 cases; struct member typespec full names, TypeEmit buildStructTs, 60; type-parameter
  faces, UhdmExporter / TypeEmit, 31; importer-copy argument typedef names, 10).

## 7. Sister-ground faces (decoded, nothing written there)

- **MiniAmiq / SeqDriver's type-parameter use heads** #223178 (MiniAmiq d/t, now its only record) and #218195 /
  #218207 (SeqDriver d/t): TypeEmit's 180 / 183 / 186 family, the live sister pass's work.
- **The macro body width** behind § macroStrBodyLen268: UhdmExporter buildMacroExpansions' `expLen` sizes a
  one-line stringification body from its written text and nested replacements; the exact fix there would size it
  as the literal plus the kept tail (and would make this pass's drain a no-op).
- The subroutine-local array typespec end column (section 6), TaskFuncEmit.
- m34's elaborated `assign o = `VS` Rhs (the shared cont_assign Rhs, ModuleEmit emitContAssigns).
- The items the brief lists for ground B stand as reported by pass 266: the package listing order,
  typedefParentModel134's unparenting of the cast copy, the select-Lhs replication fold (r11u267 R/r11 to r14), the
  pendingParamCloneTs drain (r11u264 P/p09), interface-array port views (r10rgg3 f1), vf01.

## 8. Residues on this ground, ranked

1. **R1, § macroStrBodyLen268's untouched shapes**: a call inside another macro's argument (`` `W(`VS) ``, m11), a
   chain hop through a function-like macro (m41), a function-like body with a tail (m42), a body with a line
   continuation (m26, stage 1 on both). All keep pristine's (wrong) columns.
2. **R2, the override pattern's other shapes**: the reference chain `localparam cfg_t L2 = p::B; leaf #(.C(L2))`
   (q20, stage 1 on both), an unpacked struct formal with a qualified actual (q19, stage 1 on both), a depth-3
   pass-down `mid #(.C(p::B))` -> `leaf #(.C(C))` (q16, stage 1 on both, toward).
3. **R3, pass 266's residues** (brief item (2)), not attempted: package array typedefs (k05_param_a,
   a27_q_row_named_dims, x38_param_in_module_typed at file(4)), the interface home, the runtime-call
   over-abstention of § pkgTdParamValListingTs266 (v11u266 VA/va15), signed literals into non-int targets, the signed
   ternary (a2_earl52), S/s37, the constant-call fold face, vs03 / vs27, the missing abstention trace on the
   ParamEmit branch of § sgnLitElabFreshIntTs266. A note on pass 266's README: it says § sgnLitElabFreshIntTs266
   admits a module or interface home where its code tests not-a-package (program, generate and class homes are
   admitted too).
4. **R4, the subroutine-local array end column** is the sister's (section 6); r10earl_repro ss / tl / ud / ue (the
   ranged bound folded from a qualified package parameter, file) and r11u109's 64-bit cast values (4) not attempted.
5. **R5**, the import-copy face of a module that imports a package holding an unpacked struct parameter (the copy's
   ref_typespec full name `work@top` where golden writes none; cases/Q q03 to q07, q10, q12, q13, q17, q22, q24),
   ParamEmit's import copy, decoded only this far.
6. The brief's items (3) to (7) (passes 264, 262, 260, 258 to 238 residues, the decode's BuildUVMPkg clusters,
   the carried items) were not attempted in this pass.

## 9. Process

- **Drafts and withdrawn binaries.** draft1 (`d01d3f0d`, the object-like stringification only) and draft2
  (`7e4ee807`, + the tail and formals rules and the override law) were measured on cases, the probe stage and the
  UVM rows only. The first frozen law (`20b6c8ab`) went through the census, the grid, the controls and a full law
  sweep; its byteverify showed the unpredicted Scoreboard default byte mover (section 2, the store), so it was
  withdrawn with its census and sweep set aside unused. The second (`60ba6625`) was withdrawn after its grid
  (m14 / m32 leaving STRICT_EQUAL) and its census was stopped (my own processes, command lines checked for this
  pass's name) before it finished. Every number above is the third frozen law's (`40332276`): grid, away census,
  controls, census, sweep, byteverify, canaries, determinism and downstream cases all rerun on it.
- **Experiment binaries** (scratch, never swept): three single-switch bisection builds of the first law
  (`R11U268_X_*` environment hooks) in /tmp; the hooks are not in the patch.
- **The fence.** Every driver reads `$FENCED` from tools/probe/r11u107repro/canaudit.sh fail-closed; the census
  dispatches with a filter built from it, the byteverify mirrors and the binary audit filter path lists by word
  boundary before opening anything, the controls filter their path lists first. No fenced test was dispatched,
  read or decoded outside the gate sweeps.
- **src edits during the pristine sweep.** The pristine sweep ran the frozen /tmp/r11u268_bin/pristine; the
  worktree's src was edited while it ran, which only the law-index check reads.
- **The law index.** tests/LAWS.md was regenerated last (`python3 scripts/law_index.py`).

## Drivers

drivers/ (copied from r11u266repro; the pass-specific names changed):
- env.sh, case.sh, grid.sh, gridsum.py: the case grid.
- classify.py, chains.py: the probe residue classification (section 6).
- controls.sh, ctlsum.py: the byte controls.
- tracecensus.sh, predict.py (new: a byte-mover prediction that separates moving firings from records that move
  nothing): the firing census.
- bvmirror.sh (BV_CORPORA added, the downstream lane mirrored too): the fence-filtered byteverify mirror.
- awayall.sh, away.py, awaydump.py, awaycorp.sh, awaychain.py, awayrows.py, cc_x.sh, strictcmp_x.cpp: the away
  censuses.
- rowhead.sh, det.sh, dscases.py: a row's strict records, the determinism draws, downstream on cases.
