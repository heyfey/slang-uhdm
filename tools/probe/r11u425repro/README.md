# r11u425 — the expression/parameter ground, thirteenth pass of the sv-tests campaign

Base 914cad62 (pass 423 on top of passes 422 and 424). Ground: src/ExprEmit.cpp,
src/EmitHelpers.h, src/StmtEmit.cpp, src/ParamEmit.cpp (this pass touches
ExprEmit.cpp and EmitHelpers.h only). Pristine = the main tree's build at the
base (md5 72038e16a3df50b111015c03b239fc7a, frozen as /tmp/r11u425_bin/pristine,
not rebuilt); law binary md5 0c313392ab6e82fc9b6a2d39044278f4
(/tmp/r11u425_bin/law). The pristine sweep reading is the master's control at
the base, /tmp/intr11u423.

## Summary

No sv-tests row on this ground converts: every both-accepted DIFFERENT /
STRICT_NOTEQUAL row's first difference at the base sits on the sister's ground
or is a Surelog artefact (head census below). The pass writes five laws on
the probe backlog of this ground: the one-bit uppercase-base literal tokens
(pass 412's reported face), `__LINE__` after a `line directive (pass 416's
vl07), and three laws on the unsized based package parameter fold family
(pass 423's VS residues vs03 and vs16 and the base x context grid around
them).

## The sweep (one, on the final law binary; tests/sweep.sh --jobs 3 --workdir /tmp/r11u425_sw for the four corpus stages from this worktree, the sv-tests stage through the main tree's scripts/check_svtests.py with the base's results/golden_svtests.csv, since a worktree has no UVM tree; evidence/sweep.log)

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0
  conversions=0 changes=0; probe.csv identical to the control's.
- surelog: default CMP_EQUAL 480, testflags 474 (954 of 954 judge-equal
  row-modes, STRICT_NOTEQUAL 0; Tnoc d/t CMP_NOTEQUAL standing),
  regressions=0 conversions=0 changes=0; the csv differs from the control's
  only in the two LowMem log-path texts.
- uhdm2rtlil: 803 / 1 / 67 in both modes (stamped_gen_param d/t CMP_NOTEQUAL
  standing), 0/0/0; csv identical to the control's.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of
  871, csv identical to the control's.
- sv-tests: EQUAL 1881, STRICT_NOTEQUAL 2, DIFFERENT 57, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  regressions=0 conversions=0 changes=0; svtests.csv identical to the
  control's on all 2346 rows. No sv-tests row moves: NO CONVERSION this pass.
- The corpus stage's exit 1 is the law index alone (tests/LAWS.md went stale
  when this README was written after the index; regenerated afterwards and
  `scripts/law_index.py --check` passes).
- byteverify (SELFCHECK=1) law against the control /tmp/intr11u423: 0 of 962
  (surelog), 0 of 1608 (uhdm2rtlil), 0 of 805 (downstream), each selfcheck
  flagging all but the fixed file; the 80 kept sv-tests databases differ in
  bytes only by the embedded work-dir path: 79 of 80 identical by
  path-normalized dump, tnoc's dump cut by its 900 s timeout with the two
  databases the same size (230131612 bytes) and uhdm-cmp between them reading
  0 lines (evidence/byteverify.txt). As predicted: no mover.
- canaries: canaries.sh ok=52 (surelog) and ok=16 (uhdm2rtlil), changed=0;
  ctcan2 PASS on both (ok=58 unknown-patterns=1; ok=2 unknown-patterns=6)
  (evidence/canaries.txt).
- trace census: the sweep ran with R11U425_TRACE=/tmp/r11u425_trace and the
  directory is empty: no law fired on any corpus row, probe case or sv-tests
  row (positive control: LD/ld01 under the same variable logs four firings;
  the stage runners pass the environment through).

## Laws (all in src/ExprEmit.cpp; helper unszBasedLitBase425 in src/EmitHelpers.h)

Every law reads through src/LawSwitch.h: `lawOn(425, "R11U425_<LAW>_OFF")`,
R11U425_OFF drops all of them, R11U425_TRACE=<dir> logs each firing
(lawTrace(425, ...)). No src/R*.h, no LawState.h section, no getenv, no reader
function; StmtEmit, ParamEmit, include/ and uhdm_main.cpp unchanged.

1. § oneTickUpperBNormalized425 (R11U425_ONETICKB_OFF) — a one-bit literal
   written with an uppercase base, `1'B0`, `1'B1`, `1'Bx`, `1'BX`, decompiles
   `1'b0`, `1'b1`, `1'bX`. Surelog's lexer has dedicated tokens for the eight
   spellings (SV3_1aTreeShapeListener::exitNumber ONE_TICK_B0 ... ONE_TICK_BX)
   and CompileExpression's paNumber_1TickB0 / B1 / Bx branches hard-code the
   lowercase decompile; ours kept the written text. Two sites: the
   IntegerLiteral emission, and the fold of a package parameter written
   `1'B0` / `1'B1` (the clone of its compiled Rhs). Only those exact
   four-character spellings: `1'Bz`, `4'B1010`, `1'sB1`, `'B0` are ordinary
   tokens Surelog keeps (controls OB/ob08). Grid cases/OB.
2. § lineMacroAfterDirectivePlus1_425 (R11U425_LINEPLUS1_OFF) — `` `__LINE__ ``
   written below a `` `line N `` directive of the same file reads one more
   than slang's value: PreprocessFile::getLineNb maps line L after a directive
   on line D to N + (L - D) (the LineTranslationInfo enterLine_directive
   records keeps the directive's own line), slang maps it to N + (L - D - 1)
   (IEEE 1800 22.12). Only a `__LINE__` whose expansion location is file text
   (not a macro body, where Surelog substitutes the calling line: control
   LD/ld05) with a `line directive at the start of an earlier line of the
   same buffer. Grid cases/LD.
3. § unszPkgFoldElabForm425 (R11U425_ELABFORM_OFF) — a read of an untyped
   package parameter initialized by an unsized `'d` or `'o` literal that is
   written package-qualified (`p::H`, any context) or is the whole
   initializer of a net declaration (`wire [7:0] w = H;`, qualified or not)
   is the package's elaborated value, not the clone of the definition's Rhs
   the unqualified reads take: `'d200` is `INT:200` decompile `200`
   (vpiIntConst), `'o17` is `UINT:15` decompile `15` (vpiUIntConst); ours
   copied the written `'d200` / `'o17` (DEC / OCT). Size untouched (the
   cont_assign's own resize is ModuleEmit's). Abstains on an octal read that
   is the whole right side of a plain continuous assignment (golden's
   definition view keeps -1 while its elaborated copy is resized: UP/up20),
   values over 31 bits (UP/up85..up96) and x/z values. Grid cases/UP.
4. § unszPkgFoldNdaNoTs425 (R11U425_NDANOTS_OFF) — the unqualified whole
   initializer of a net declaration over such a parameter carries no
   typespec in golden (`'h1F`, `'b101`, `'o17`); ours kept § 423's
   actual-less ref_typespec (the v11u423 case VS/vs03). Grid cases/UP.
5. § unszBinNdaKeepsTickText425 (R11U425_BINNDATICK_OFF) — at a net
   declaration's whole initializer an unsized binary parameter keeps its
   written `'b101` decompile: § readerWidthIsTheSecondAdjust104 truncated it
   as a 32-bit literal wider than the net and wrote the bare digits `101`,
   where adjustSize's binary branch truncates only when the constant's own size
   (-1 here) exceeds the reader's. Grid cases/UP.

A first form of law 3's family also held a fourth law, withdrawn
(unqualified `'d` whole cont_assign right side at size -1, UP/up01): it made
the elaborated copy a separate object where golden shares the definition's
(uhdm-cmp 42 -> 13 but dump distance 11 -> 37), so it was withdrawn before the
sweep; UP/up01 stays at pristine's bytes.

## Grid (evidence/grid_final.txt; drivers/grid.sh, drivers/case.sh)

109 case dirs, every one accepted by upstream slang, every exit code 0 on both
binaries (OB 12, LD 7, UP 90; the UP grid is base {'d200, 'o17, 'h1F, 'b101,
'd0, 'd3000000000} x context {qualified/unqualified whole cont_assign, net
declaration, operand; procedural, procedural operand, port actual, function
return, 16/4/integer nets, generate scope, generate-for qualified, a child
instance, case item}; six class-method cases were dropped because upstream
slang rejects them, -Wdynamic-non-procedural):

- pristine -> law: 49 NOT_EQUAL -> STRICT_EQUAL; 3 NOT_EQUAL ->
  STRICT_NOTEQUAL toward golden (OB/ob02 type: the elaborated untyped
  parameter's int vs logic typespec, pristine too; LD/ld06 endcol: the
  `$display` argument span over the expanded text; UP/up44 line: the
  generate-scope copy sits at the parameter's location in golden); 12
  NOT_EQUAL toward golden (smaller dump distance; UP/up27, up28, up39, up40,
  up75, up76 with a larger uhdm-cmp count because the head moved later in the
  walk); 2 NOT_EQUAL with moved bytes at the same distance (UP/up32, up80: the
  generate-scope elaborated copy's value now INT:200 as golden's, its location
  still the read's); 43 unchanged (18 STRICT_EQUAL controls, 1 STRICT_NOTEQUAL,
  24 NOT_EQUAL); none away.
- R11U425_OFF restores pristine's bytes and exit code on 109 of 109; each
  moved case's own switch restores pristine on 55 of 66, the other 11 (UP/up15,
  up21, up41..44, up46, up65, up66, up68, up70) needing the two co-firing
  switches (ELABFORM + NDANOTS or BINNDATICK + NDANOTS), as the trace reads.
- downstream (drivers/ds.sh, evidence/downstream_cases.txt): 11 DIVERGENT ->
  IDENTICAL (LD/ld01, ld03, ld07, UP/up21, up22, up37, up41..44, up46), 3
  STATUS_DIFF -> IDENTICAL (UP/up24, up38, up48: octal reads), 1 DIVERGENT ->
  EQUIVALENT (LD/ld06), 80 IDENTICAL, 9 EQUIVALENT and 5 DIVERGENT unchanged,
  none worse.

## Earlier-pass census (drivers/census.sh, evidence/earlier_census.txt)

6011 fence-filtered case dirs of passes 110-139 and 401-424 (r and v), pristine
against law by exit code and bytes: 6006 unchanged, 5 moved, all toward golden
(evidence/earlier_movers.txt): r11u412 UP/up03, up06 NOT_EQUAL -> STRICT_EQUAL
(§ oneTickUpperBNormalized425: pass 412's `parameter int bar = 1'B0`),
v11u423 VS/vs03 NOT_EQUAL -> STRICT_EQUAL (§ unszPkgFoldNdaNoTs425), VS/vs16
NOT_EQUAL -> STRICT_EQUAL (§ unszPkgFoldElabForm425), v11u416
VL/vl07_line_value_after NOT_EQUAL toward (dump distance 18 -> 10,
§ lineMacroAfterDirectivePlus1_425; the localparam's elaborated value and its
reads are slang's folded constant, still N).
The probe corpus (tests/probe, 4087 case dirs): 4087 of 4087 byte-identical.

## Prediction by name before the sweep

A fence-filtered source scan (21333 corpus files, 21950 sv-tests files):
- `1'B[01xX]`: Google number_test_7 and oh fifo_async_104x32 in the Surelog
  tree (no corpus row compiles either), sv-tests generic/number/number_test_7
  (a `$unit` `parameter int foo = 1'B0`, measured byte-identical on both
  binaries, STRICT_EQUAL).
- `` `__LINE__ `` below a `` `line ``: Surelog tests/PreprocLine (SURELOG_FAIL,
  slang-uhdm exits 3 on both binaries: no database) and a Verilator include no
  row compiles; none in sv-tests rows.
- untyped unsized based package parameters: the UVM `UVM_RADIX = 'hf000000`
  (hex: only law 4 could fire, on a net-declaration read; none), NyuziProcessor
  (SLANG_REJECT), black-parrot pkgdef `'h` localparams (no net-declaration
  read in BlackBePipeInt; trace below); sv-tests: module localparams only
  (scr1, fx68k), not package ones.
- a traced run of MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg,
  Earlgrey_0_1, Rggen, BlackBePipeInt, TypeParam, LogicTypespec, Scr1SvTests
  and PreprocLine in both modes logged no firing and read the baseline
  statuses (positive control: LD/ld01 under the same trace logs four firings).
Predicted: no byte or exit-code mover in any corpus row, probe case or
sv-tests row.

## Goal 1

- No sv-tests row on this ground: all 75 SURELOG_ONLY rows carry a slang
  front-end `error:` diagnostic in their detail and none an exporter message.
- The probe faces: C::mk().arr[1] (r11u423 residue g1a) and u.mk(x).a[2]
  (g1b) exit 4 on pristine and law where upstream slang exits 0 and Surelog
  rejects both (syntax error): not forced, golden has no shape; this.mk().inner.s
  (g1c) and the v11u415 case VT/vt03 exit 0.
- black-parrot: the six rows stay SURELOG_CRASH behind pass 403's size guard;
  bp_unicore alone on the law binary on a quiet machine exits 3 in 17.1 s at
  808 MB maximum resident memory with the same `basic_string::substr` error;
  no memory-bounded export found, the guard stands.
- rsd stays SURELOG_CRASH (Surelog dies first): not this ground.

## Goal 2: the head census at the base (/tmp/intr11u423 pairs, build/uhdm-strictcmp)

The 57 DIFFERENT and 2 STRICT_NOTEQUAL rows, first differing object:
- sister ground (TypeEmit / ModuleEmit / UhdmExporter / TaskFuncEmit), reported:
  - generic/class/class_test_49.sv: the brief placed the f(glb::arr[N])
    naming in ExprEmit; it is TypeEmit emitSyntaxExpr's InvocationExpression
    branch, reached from UhdmExporter emitClassParameters for a class parameter's
    initializer. Golden: func_call f spans the name only (27:18-27:19) and
    links vpiFunction to the `$unit` function f; its argument is a bit_select
    named glb::arr (parented to the package parameter, spanning the index
    27:29-27:30) with the index ref_obj N named glb::arr::N; ours a raw-text
    ref_obj `glb::arr[N]` spanning 27:20-27:31.
  - generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_axi_mem.sv: TypeEmit
    mapSyntaxBinOp has no CaseEqualityExpression / CaseInequalityExpression
    branch, so the definition-view generate-block cont_assign
    `(ram[i][j] === 1'bx) ? ... : ...` loses its condition operand (reduced
    evidence/residue_cases/ra01_caseeq_defgen; `==` reads STRICT_EQUAL, `===`
    in a gen-for 194-214 uhdm-cmp lines).
  - chapter-18/18.14--random-stability_1.sv: UhdmExporter emitClassDefn's
    class-property `int tab1[5] = {1,2,3,4,5}`: golden an int_var with the
    concatenation's constants at size 32, ours an array_var at 64
    (ra02); the module twin drops the variable's vpiExpr in ModuleEmit (ra03).
  - p599: ModuleEmit's cont-assign system-call typespec stamp list
    ($realtobits). 
  - The unsized package parameter family's remaining cells are ModuleEmit's
    cont_assign resize (modCaAdjustKeeps289): `'b101` read whole into an
    8-bit net golden size 8, ours 32 (UP/up13, up14); `'d200` unqualified
    whole golden size -1 with an actual-less ref_typespec (UP/up01); `'o17`
    qualified whole, golden two objects (definition UINT:15 at -1, elaborated
    at 8) where ours shares one (UP/up20).
  - the 4 testbenches rows (uvm_resource class typespec), 16 uvm-examples rows
    (package listing / UVM_DEEP enum constants), easyUVM, the 3 scoreboard
    testbench rows, default-value, the basejump typedef-range / include-info /
    generate rows (comm_link, round_robin, dpi_rom, mesh_stitch,
    channel_control_master, non_blocking_data_mem, imod_range, mul_pipelined,
    six include_file_info rows), p130, p179, p193_2, p203, p334, p489, p600,
    p719, p737, p765, typedef_test_9.
- this ground, not written: tnoc (tnoc_pkg 333:14, golden 241 from Surelog
  evaluating the function, an artefact), fx68k (a design-level CF parameter
  golden lists and we do not), p733 (defparam: golden the range constant 0,
  ours 4).

## Residues standing on this ground (all wrong on pristine too)

1. The unsized package fold cells behind ModuleEmit's resize (UP/up01, up13,
   up14, up20) and the unqualified `'d` operand that golden leaves without a
   typespec (UP/up05; ours keeps § 423's actual-less ref_typespec — a 'd-only
   distinguisher measured on one cell, not written).
2. Uppercase-B multi-bit binaries in an elaborated param_assign (golden
   `4'b10x1` / `'b101`, ours `4'B10x1` / `'B101`; a signed `4'SB1010` is
   INT:10 in golden) and in the folded read of `pk::PP = 4'B1100`
   (evidence/residue_cases/ra04).
3. 1'Bx package parameter folds and `#(1'BX)` overrides (OB/ob11, ob12):
   pass 407's x/z parameter backlog.
4. `__LINE__` folded into a localparam's elaborated value and its reads (vl07),
   `__LINE__` inside a macro body after a directive (LD/ld05), and the
   expanded-text span of a `__LINE__` argument (LD/ld06).
5. golden's `$bits` of a select reads the whole signal's width (v11u421 VB/vb14,
   vb23, vb17; ra05): the next head of pass 421's VB residue.
6. The carried lists of passes 401 to 423 (their READMEs).

## Process

- One law build line (law1 .. law4 intermediates measured only on case dirs;
  law4 = the final `law`), no pristine build, no pristine sweep.
- The sweep launched after three quiet readings (the sister verifier v11u426's
  sweep was live; the launcher waited).
- Slip: one dump command ran with $UHDM_DUMP unset in that shell, so the shell
  executed a cached golden database (mode 0700) as a script; it wrote nothing
  (scratch dir checked, main tree clean) and every later tool call used
  guarded absolute paths.
- The fence list was read into a file by a program, never printed; every
  tree-wide list was filtered on it before any file was opened. No other
  agent's process touched.
