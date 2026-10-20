# r11u417 — expression/parameter ground, the ninth sv-tests pass on this ground

Base 1e4b0333d (pass 415). Ground: src/StmtEmit.cpp and src/ExprEmit.cpp
(EmitHelpers.h and ParamEmit.cpp unchanged). Three laws, each read through
src/LawSwitch.h as `lawOn(417, "R11U417_<LAW>_OFF")`; `R11U417_OFF` drops all
of them, `R11U417_TRACE=<dir>` logs each firing through `lawTrace(417, ...)`.
No src/R*.h, no LawState.h section, no getenv, no reader function; include/,
TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit and uhdm_main.cpp unchanged.

Binaries: pristine = the main tree's build at the base (md5
42a17ef86d53481c31bcf8b76ee9a73f; the worktree's own base build came out
byte-identical, then became the law build); final law binary md5
59aec9b436104c4cb522cae128e235ef (`law7`). The intermediate binaries law1 to
law6 ran only on the case grids and, law3 once, on the three chapter-18
sv-tests rows.

## Verdict per targeted row

| row | before (base) | after (final) | law |
|---|---|---|---|
| chapter-18/18.5.9--global-constraints_1.sv | DIFFERENT | **EQUAL** (IDENTICAL, strict equal) | § foreachArrayNamesClass417 |
| chapter-18/18.5.13--constraint-guards_1.sv | DIFFERENT | **EQUAL** (IDENTICAL, strict equal) | § foreachArrayNamesClass417 |
| chapter-18/18.14--random-stability_1.sv | DIFFERENT | DIFFERENT, unchanged: its head is not the foreach face (the law does not fire there) but the class property initializer `int tab1[5] = {1,2,3,4,5}` (sister ground, below) | — |
| generated/basejump/bsg_cache_BaseJumpSTL_bsg_cache_non_blocking_data_mem.sv | DIFFERENT | DIFFERENT, unchanged: its `data_mem_pkt.data[0+:(8*(2**i))]` head is in a definition-view generate block, written by TypeEmit's emitSyntaxExpr (sister ground); the law fixes the same name in every expression-ground context (grid HP) | § hierSelParenBoundPretty417 (not reached there) |

THE CONVERSIONS (fresh rows of /tmp/r11u417_sw/svtests.csv; results/ untouched,
the master promotes):

    chapter-18/18.5.13--constraint-guards_1.sv,EQUAL,,equal
    chapter-18/18.5.9--global-constraints_1.sv,EQUAL,,equal

The sv-tests stage on the final binary (evidence/svtests_stage_final.log):
EQUAL 1809 -> 1811, DIFFERENT 125 -> 123, STRICT_NOTEQUAL 6, BOTH_REJECT 303,
SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
regressions 0, conversions 2, changes 0. The csv against the master's control
(/tmp/intr11u415/svtests.csv) differs in exactly those two rows
(evidence/svtests_csv_vs_control.diff).

## Laws

1. § foreachArrayNamesClass417 (StmtEmit, R11U417_FOREACHCLASS_OFF). Surelog
   compiles a foreach's array identifier with CompileHelper::compileVariable
   (CompileStmt.cpp paFOREACH branch -> CompileType.cpp compileVariable), whose
   slStringConst branch reads the identifier as a TYPE NAME first: a class of that
   name makes the array an unnamed class_var whatever the array really is. Golden
   (grid FC, decoded on the r11u413 FB residue cases): the foreach's vpiVariables
   is a class_var with no name and no full name of its own (the dump prints the
   enclosing scope's), at the identifier, over a ref_typespec (no name, no full
   name) to a class_typespec at the identifier linked to the class_defn; the loop
   variables, wherever Surelog resolves them at all (UhdmWriter::
   swapForSpecifiedVar: a class_var listed variable is neither a hier_path nor a
   ref_var, so indexTypespec stays null), take the int_var fallback over a fresh
   unlocated int_typespec, exactly as for the `::`-written spelling
   (§ foreachScopedArrayLoopVarIntFallback34); in the views where Surelog never
   resolves them (in-body class methods, the class-method listing of an
   out-of-body method) they keep the ref_var placeholder. Which branch found the
   class decides the class_typespec: a class declared in an enclosing package or
   module (compileVariable's "<component>::name" / "<parent>::name" keys) is found
   FIRST, wins over a $unit class of the same name (FC/fc20) and gets a fresh
   class_typespec with neither name nor instance (fc06, fc15, fc20); otherwise a
   $unit class or one reached through an import is compileTypespec's resolution,
   named after the class and, in a package view, stamped with the package
   instance (fc01, fc02, fc05, fc09, fc19). Not found: a package class nobody
   imports (fc13), a class nested in another class (fc14). Abstains: a
   parameterized class (fc21, golden writes a class_var over a class_typespec of
   the generic class: residue), `this.b[i]` (fc22: pristine already equal), a
   typedef of the name anywhere on the walk (the typedef law decides). Site: the
   foreach array branch of StmtEmit (the class_var/typespec mint and the loop
   variable's fallback beside § foreachScopedArrayLoopVarIntFallback34); the
   lookup is the file-local foreachArrNamesClass417.
2. § foreachArrayNamesTypedef417 (StmtEmit, R11U417_FOREACHTD_OFF). compileVariable's
   first branch, component->getDataType(name): a typedef of the array's name makes
   the array getSimpleVarFromTypespec of the typedef's own typespec, NAMED as
   written (FT/ft01 `typedef int b;` -> int_var `b` over int_typespec (b); ft03 a
   packed struct typedef -> struct_var; ft04 a package typedef read in a package
   function), loop variables the same int fallback. Measured homes only: a typedef
   declared at $unit or in a package, of a non-class type, whose shared typespec
   (sharedAliasTs) already exists. Abstains, pristine bytes: a typedef of a class
   (ft05: golden keeps the ref_var, getTypespec() of the class datatype answers
   nothing), a module typedef (ft06: golden binds Surelog's elaborated clone with
   a typedef alias we do not build), a $unit typedef written after the package
   whose class method iterates (ft02 and r11u413 FB/fb04: the typedef's typespec
   is not emitted yet when the method is; golden's clone carries a typedef alias).
3. § hierSelParenBoundPretty417 (ExprEmit, R11U417_HSPARENBND_OFF). A select
   bound written in parentheses or with `**` on a dotted reference
   (`s.data[0+:(8*(2**i))]`, `s.data[i+:(8*2)]`, `s.data[(i)+:4]`,
   `s.vpn[(A/B)-1:0]`) is named by Surelog's decompileHelper from the bound
   OBJECTS: an operation through ExprEval::prettyPrint, which never writes a
   parenthesis and spaces every binary operator (golden `s.data[0+:8 * 2 ** i]`,
   `s.data[i+:8 * 2]`, `s.data[i+:4]`). The raw-text rendering kept the
   parenthesis the bound's range starts after, lost the closing one (or the
   reverse) and split `**` into `* *`. The law renders both bounds through the
   existing ppIdxText92 (§ hpIdxOpPrettyPrint92's transcription) when the raw text
   of the bounds holds `(`, `)` or `**`, and only when the result differs from the
   raw rendering. Site: the range-select branch of the dotted hier_path builder in
   ExprEmit (beside § hierSelMacroBoundPretty405).

## Grid (evidence/grid_final.txt; drivers/grid.sh, drivers/case.sh)

41 case dirs, each with exit code, uhdm-cmp lines, dump distance, strict verdict
on pristine and final, R11U417_OFF -> pristine's bytes and exit code (41 of 41)
and the group's own switch -> pristine's bytes and exit code (41 of 41). Every
case exits 0 on both binaries.

| group | law | cases | result pristine -> final |
|---|---|---|---|
| FC | § foreachArrayNamesClass417 | fc01-fc15, fc17-fc22 (21) | 15 NOT_EQUAL -> STRICT_EQUAL (fc01 module initial, fc02 package function, fc03 $unit class in-body, fc04 package class in-body, fc05 out-of-body, fc06 same-package class, fc08 class property, fc09 imported class, fc10 two loop variables, fc12 module task local, fc15 module-local class, fc17 associative array, fc18 interface, fc19 package importing a package, fc20 package class over a $unit class); fc11 (uvm find_blocks shape with `import p::*`) NOT_EQUAL toward golden (61 -> 20 dump lines, cmp 1462 -> 1460; its remaining head the import+extern method listing, sister ground); controls fc07, fc13, fc14, fc22 byte-identical STRICT_EQUAL; fc21 (parameterized class) abstains, byte-identical NOT_EQUAL |
| FT | § foreachArrayNamesTypedef417 | ft01-ft06 | ft01, ft03, ft04 NOT_EQUAL -> STRICT_EQUAL; ft02, ft05, ft06 abstain, byte-identical NOT_EQUAL |
| HP | § hierSelParenBoundPretty417 | hp01-hp14 | hp02, hp03, hp04, hp05, hp07, hp09, hp11, hp13 NOT_EQUAL -> STRICT_EQUAL; hp01 (a generate block) NOT_EQUAL toward golden (92 -> 38 dump lines: the elaborated view fixed, the definition view is emitSyntaxExpr's, sister ground); controls hp06, hp12 byte-identical STRICT_EQUAL; hp08, hp10, hp14 STRICT_EQUAL with identical dumps but moved bytes (below) |

Byte movers with identical dumps (hp08, hp10, hp14): the law also renames an
unreferenced copy of the path (the trace shows it firing, e.g. hp08's
`s.data[i * 8)+:8] -> [i * 8+:8]` three times, once per generate iteration); the
renamed string is one the database already holds, so the file shrinks (hp08
9370 -> 9204 bytes) while every reachable object, the uhdm-cmp result and the
strict verdict stay. No corpus or sv-tests database fires it (trace below).

Downstream (evidence/downstream_cases.txt): the 18 class-free or class-light
cases HP/hp01-hp14, FT/ft01, ft03, FC/fc01, fc12 read IDENTICAL on both
binaries (both lanes NO_GATES: a weak instrument here, these duts synthesize
to constants).

r11u413's FB residue cases (evidence/residue_cases/FB of r11u413repro): fb02 and
fb05 NOT_EQUAL -> STRICT_EQUAL, fb01 toward golden (59 -> 18 dump lines; the
`import p::*` + extern method listing left, sister ground), fb04 (the $unit
typedef after the package) abstains, byte-identical.

## Gates (the final binary, one full sweep: evidence/sweep_final.log)

`tests/sweep.sh --jobs 3 --workdir /tmp/r11u417_sw` from the worktree with
SLANG_UHDM=/tmp/r11u417_bin/slang-uhdm.final and R11U417_TRACE set; the sv-tests
stage skipped itself in the worktree (no sv-tests sibling, no UVM tree) and ran
alone right after through the main tree's scripts/check_svtests.py read-only
with the same binary and workdir (evidence/svtests_stage_final.log), as pass 415
did.

- probe: EQUAL 4018, STRICT_NOTEQUAL 69 of 4087; regressions 0, conversions 0,
  changes 0; the csv byte-identical to the control's.
- surelog: default CMP_EQUAL 480 + 0, testflags 474 + 0; regressions 0,
  conversions 0, changes 0; the csv differs from the control only in the two
  LowMem log-path texts.
- uhdm2rtlil: 803 / 1 / 67 in both modes; regressions 0, conversions 0, changes 0;
  the csv identical to the control's.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not
  identical and not excused 0; the csv identical to the control's.
- sv-tests: regressions 0, conversions 2 (above), changes 0.
- byteverify (evidence/byteverify.txt) law workdir against the master's control
  /tmp/intr11u415: surelog MOVERS 0 / 962, uhdm2rtlil 0 / 1608 (SELFCHECK 961 and
  1607 flagged); the probe stage keeps no databases.
- canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2
  (EXPECT_UNKNOWN=1 surelog, EXPECT_UNKNOWN=6 uhdm2rtlil) PASS both.
- binary audit, fence-filtered paths: surelog 1523 of 1573 cmds.txt name the
  final binary (the rest hold no slang line), uhdm2rtlil 1740 of 1740, sv-tests
  2346 of 2346; none names another slang-uhdm.
- uhdm-cmp 0 lines on every touched corpus row: no corpus row is touched.

## Prediction by name and the trace census

Before the sweep: source scans over the four corpus trees, fence-filtered by
path before any file was opened (drivers/scan_foreach.py,
drivers/scan_hp.py; evidence/prediction_scan_FOREACH.txt,
prediction_scan_HSPARENBND.txt). The foreach scan listed directories where a
bare foreach array name is also a class or typedef name in the same sources:
surelog ClassCons, IndexPartSelectBind, SimpleClass1, UnitClass, UnitAmiqEth,
Google, Verilator (all SLANG_REJECT or TIMEOUT rows, no database to move), ariane/tb,
uhdm2rtlil cva6_equiv and ibex/prim, and ten probe case dirs; a traced law
binary run on those ten probe cases and on uvm_pkg alone fired nothing (the
scan is name-level: a type parameter or an out-of-scope class does not resolve;
the FC/fc01 positive control fired). The paren scan listed 172 source lines in
Ariane, Ariane2024, black-parrot, Earlgrey, Opentitan, Rp32, NyuziProcessor,
IncompTitan, SplitFile, cva6_equiv, rp32, ibex and one probe case; each is a
range select with `$clog2(...)` or a parenthesized bound on a dotted path,
where the law fires only if the prettyPrint rendering differs from the raw one
(hp10/hp12/hp14 model them: no reachable change). Predicted exit-code movers:
none (no law touches an exit path). Predicted byte movers: none reachable.

The sweep's trace (evidence/trace_final.txt): the laws fire on exactly two
databases of all five stages, the converted sv-tests rows 18.5.9_1 and
18.5.13_1 (§ foreachArrayNamesClass417, three firings each: the array and its
loop variable); nothing fires in the probe, surelog, uhdm2rtlil or downstream
stages, matching byteverify's 0 movers. The away census on sv-tests is
therefore the two converted rows alone (both now strict equal); no other kept
database can move.

Earlier passes' case dirs (evidence/earlier_pass_cases_pristine_vs_final.txt,
drivers/earlier.sh): 2306 fence-filtered dut.sv dirs of tools/probe/[rv]11u401
to 416repro, exit code and md5 on both binaries: 2303 identical, the 3 movers
are r11u413's FB residue cases fb01, fb02, fb05 (targeted, above).

## Goal 1

- All 75 SURELOG_ONLY rows of results/golden_svtests.csv carry an upstream
  slang front-end diagnostic (75 of 75 details are `error:` lines from slang's
  front end; the one naming the checkout path, biquad_example, is uvm_pkg's
  "design element does not have a time scale" from slang). None is the
  exporter's own.
- The probe faces (exporter exit 4 'element select base' where upstream slang
  exits 0 and Surelog itself rejects with a syntax error, so no golden exists;
  not forced): v11u413 VC/vc04 `C::mk().arr[1]` (ours rc 4, upstream slang rc
  0, Surelog rc 3 SNT:PA0207 at 10:25), v11u413 VI/vi06 `u.mk(x).a[2]` (ours rc
  4, upstream 0, Surelog rc 3 at 13:22); v11u415 VT/vt03 `this.mk().inner.s`
  exits 0 on the final binary (pass 415), upstream 0, Surelog rc 3 at 12:26.
- black-parrot: bp_unicore alone with pass 403's guard on, final binary: exit 3
  in 12.1 s at 812 MB max RSS with the same substr error
  (evidence/black_parrot_bp_unicore.txt); no memory-bounded export found, the
  guard stays. rsd: SURELOG_CRASH, not ours.
- No new exit-4 shape found by this pass's 41 cases.

## Residues (ranked; all wrong on pristine too, none moved away)

1. chapter-18/18.14--random-stability_1.sv: `int tab1[5] = { 1, 2, 3, 4, 5 };`
   as a class property initializer: golden lists the operation under the
   element int_var with operands at size 32 where ours lists it under the
   array_var at size 64 (a 4-line case reproduces it in a $unit class and a
   package class; a module variable differs again: golden keeps the vpiExpr).
   The class property listing is UhdmExporter's (emitClassDefn): sister ground.
2. A parameterized class named like the foreach array (FC/fc21): golden's
   class_var over the generic class's class_typespec; the law abstains (no
   class_defn reachable without minting a specialization).
3. The typedef branch's abstentions: a module typedef (ft06, golden's elaborated
   clone with a typedef alias), a $unit typedef emitted after the iterating
   package (ft02, FB/fb04).
4. FC/fc11 and FB/fb01: the class's method listing with `import p::*` and an
   out-of-body method (golden lists vpiMethod p::blk::find under the class and
   the formals' typespecs in another order): TaskFuncEmit/UhdmExporter, sister.
5. The definition-view generate hier_path name (HP/hp01 def view,
   bsg_cache_non_blocking_data_mem 110:62): TypeEmit emitSyntaxExpr writes
   `dispRaw` (the raw source text) as the hier_path name; golden's is the
   prettyPrint text (`s.data[0+:8 * 2 ** i]`): sister ground.
6. Carried from passes 401-415 (not reached this pass): the remaining basejump
   DIFFERENT rows (macro-built raw-text bounds `(i` / `1)*mask_width_p` in
   definition-view port connections of mask_write_var 1rw/1r1w, the gen_for
   `i+=1` increment in pipeline_stall_collapse, typedef range folds in
   round_robin and comm_link, the generate-if `$bits(out_calib_code)` fold in
   source_sync_channel_control_master: all emitSyntaxExpr / ModuleEmit / TypeEmit,
   sister ground), hdlconvertor p88/p124 (the type-parameter variable initializer
   sized by the parameter's default type, golden size 16 where ours 32, plus the
   override int_typespec parented by the type_parameter: the "Bare-decimal inits
   size at the var type width" site in ModuleEmit), p130, p179, p193_2, p203,
   p334, p488, p489, p599, p600, p719, p733, p737, p791, p827, p884, the
   utd-sv primitives (gate-array terminal concatenation), class_test_49/51/53,
   typedef_test_9, default-value, 5.10, 8.24, scr1, fx68k, tnoc 333:14; the
   STRICT_NOTEQUAL rows decoder_dor and mesh_router (TypeEmit emitSyntaxExpr per
   pass 415) and the four full-name basejump rows; the goal-1 probe faces above.

## Sister-ground faces (reported, not written)

- UhdmExporter emitClassDefn: a class property's unpacked array initializer
  placed under the element var at the element width (18.14_1, residue 1).
- TypeEmit emitSyntaxExpr (`hp->VpiName(dispRaw)` in its hier_path branch): the
  definition-view generate hier_path name should be decompileHelper's text
  (prettyPrint for operation bounds), residue 5.
- TaskFuncEmit/UhdmExporter: the class's method listing of an out-of-body
  method under a $unit `import p::*` (fc11, fb01, fb03).
- ModuleEmit's elaborated variable initializer chain ("Bare-decimal inits size
  at the var type width"): p88/p124's type-parameter variable sized by the
  parameter's DEFAULT type in golden.

## Process

- The IMPLEMENTER within the budget: one full sweep on the final binary
  (four stages in the worktree, the sv-tests stage alone right after through
  the main tree's script read-only); intermediate binaries on the grids only,
  and law3 once on the three chapter-18 rows through the runner.
- SLIP: that one law3 runner call on the three chapter-18 rows (jobs 3, about
  five minutes) overlapped the sister verifier v11u418's live sweep (its
  surelog stage): my pre-launch pgrep printed the live sweep but did not gate
  the launch. No measurement of mine depends on it (the rows were remeasured
  in the final sweep's sv-tests stage on a quiet machine); whether it loaded
  the sister's surelog stage I cannot tell from here. Every later launch was
  gated on a quiet machine (drivers/quiet.sh, three consecutive zero reads).
- SLIP: once a shell lost the tool variables and `$UHDM_CMP <golden> <ours>`
  executed the golden .uhdm as a script inside a /tmp runner row directory
  (bash syntax error, nothing written; the main tree's git status stayed clean).
  Every later call guards with `[ -x "$UHDM_CMP" ]`.
- The fence list was read into a file by a program without printing it; every
  tree-wide list was filtered on it before any file was opened. No other
  agent's process was touched; no fenced test named, opened or run.

Files: drivers/ (case.sh, gold.sh, ddiff.sh, show.sh, grid.sh, earlier.sh,
scan_foreach.py, scan_hp.py, quiet.sh), cases/FC (21), cases/FT (6),
cases/HP (14), evidence/.
