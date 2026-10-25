# r11u427 — the expression/parameter ground, fourteenth pass of the sv-tests campaign

Base 42dfe016b (pass 425 on top of pass 426). Ground: src/ExprEmit.cpp,
src/EmitHelpers.h, src/StmtEmit.cpp, src/ParamEmit.cpp (this pass touches
ParamEmit.cpp and ExprEmit.cpp only). Pristine = the worktree's build at the
base, md5 5026bfe26bde534bfcd774304a08183e (equal to the main tree's
build/slang-uhdm), frozen as /tmp/r11u427_bin/pristine and used only for case
runs; the pristine sweep reading is the master's control at the base,
/tmp/intr11u425. FINAL law binary md5 d2522d91f296ff3830b8c5b80798faaa
(/tmp/r11u427_bin/law20, the worktree's build/slang-uhdm at the patch). It
differs from the earlier law19 (ba3d5f73...) only by the rename of one law and
its switch (the word rule: § sgnBinElabIntArmStands427 /
R11U427_SGNBINARM_OFF became § sgnBinElabIntBranchStands427 /
R11U427_SGNBINBRANCH_OFF); the 67-case grid reads byte-identical on both.

## Summary

NO sv-tests row converts and none changes: every both-accepted DIFFERENT /
STRICT_NOTEQUAL row's first difference at the base sits on the sister's ground
or is a Surelog artefact (pass 425's head census stands; passes 425 and 426
moved no head onto this ground). The pass writes nine laws on the x / z and
based-literal parameter family of this ground's probe backlog (pass 425's
residues ra04, OB/ob11, ob12, pass 407's VX/XZ cells, pass 266's S controls
and pass 116's F1 grid): the elaborated value of a parameter OVERRIDDEN by an
x / z literal (ours wrote slang's 4-state value through the decimal branch,
`X` / UINT:0, a downstream-visible value), the overridden untyped parameter's
implied range, the elaborated copies of x / z, uppercase-base, signed and
width-mismatched literal defaults, the module fold of an x-valued package
parameter, and the one-bit x digit.

The one five-stage sweep on law20 (tests/sweep.sh --jobs 3 for the four corpus
stages from the worktree, the sv-tests stage through the main tree's
scripts/check_svtests.py with --baseline the worktree's
results/golden_svtests.csv, R11U427_TRACE set throughout), launched after a
quiet reading with the sister pass 430's sweep ended:

| stage | reading | vs baseline |
|---|---|---|
| probe | EQUAL 4018, STRICT_NOTEQUAL 69 of 4087 | regressions 0, conversions 0, changes 0; csv identical to the control |
| surelog | default CMP_EQUAL 480, testflags 474 (Tnoc d/t CMP_NOTEQUAL standing) | 0 / 0 / 0; csv differs from the control only in the two LowMem log-path texts |
| uhdm2rtlil | 803 / 1 / 67 in both modes | 0 / 0 / 0; csv identical to the control |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 | csv identical to the control |
| sv-tests | EQUAL 1883, STRICT_NOTEQUAL 2, DIFFERENT 55, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346 | regressions 0, conversions 0, changes 0; csv identical to the control on all 2346 rows |

The strict column of every corpus csv is therefore unchanged row by row.
byteverify (law workdir against /tmp/intr11u425, SELFCHECK=1): 0 of 962
(surelog), 0 of 1608 (uhdm2rtlil), 0 of 805 (downstream), each self-check
flagging n-1 of n. Canaries: canaries.sh ok=52 (surelog csv) and ok=16
(uhdm2rtlil csv), changed 0; ctcan2 PASS on both (ok=58 unknown 1, ok=2
unknown 6). Binary audit, fence-filtered: 3313 of 3323 cmds records after the
fence, 3263 naming /tmp/r11u427_bin/law20, the other 50 holding only a Surelog
line. Law index: `law index current` at the corpus stage.

PREDICTED BY NAME before the sweep, and confirmed by the sweep's trace:
- probe and earlier-pass cases: the census (below) moved no tests/probe case
  (4087 of 4087 byte-identical, exit codes equal);
- corpora: no law fires (the cut draft sweep's trace on law19 logged no corpus
  firing; byteverify 0 / 0 / 0 confirms);
- sv-tests: a fence-filtered source scan for x / z, uppercase-base and signed
  binary literals in parameter lines or override lists found 26 rows
  (chapter-20/20.9--isunknown and 25 generic/number rows, all EQUAL), and the
  untyped-override law's draft trace named
  generated/basejump/bsg_misc_BaseJumpSTL_bsg_mul_pipelined.sv; a targeted
  traced runner call on those 27 rows with law20 read the 26 EQUAL with no
  firing and mul_pipelined DIFFERENT with eight § ovUntypedTsDeclWidth427
  firings (group_vec_p, S_above_vec_p, dot_bar_vec_p, B_vec_p, one_vec_p:
  "inv"-placeholder defaults overridden by vectors);
- the sweep's trace: ONE database fires, mul_pipelined, the same eight lines
  (evidence/sweep_trace.txt). Its row stays DIFFERENT: uhdm-cmp 10 lines on
  both binaries, the path-normalized sorted dump distance to golden 40893 ->
  40833 (the overridden parameters' typespecs lose the [39:0] / [99:0] ranges
  golden does not write), no line the law writes that golden lacks.

Goal 1: nothing on this ground. All 75 SURELOG_ONLY rows carry an upstream
slang front-end `error:` diagnostic (no exporter message); C::mk().arr[1],
u.mk(x).a[2] stay as pass 425 recorded (exit 4 here, upstream slang accepts,
Surelog rejects both with a syntax error: not forced, golden has no shape);
the black-parrot size guard (§ macroVecLitTokenText403) is untouched and was
not re-measured in this pass; rsd stays SURELOG_CRASH (Surelog first).

## Laws

Every law reads through src/LawSwitch.h: `lawOn(427, "R11U427_<LAW>_OFF")`,
R11U427_OFF drops all of them, R11U427_TRACE=<dir> logs each firing
(lawTrace(427, ...)). No src/R*.h, no LawState.h section, no getenv and no
reader function in the added lines; StmtEmit, EmitHelpers.h, include/ and
uhdm_main.cpp unchanged.

The decoded producer (Surelog v1.87): a based literal holding an x / z / ?
digit is stored by ExprBuilder as a string Value (StValue), and an elaborated
parameter's Rhs is `value->uhdmValue()` with the decompile
`StValue::decompiledValue()` (Expression/Value.cpp): `[<size>]'<lowercase
base><digits as written>`, the size prefix only for a sized literal, the `s`
dropped. CompileHelper::adjustSize then reads the value through
ExprEval::get_value, which parses the digits only up to the first unknown one
(NumUtils' prefix parse): a value whose FIRST digit is x / z / ? reads invalid
and keeps its own size and encoding; a leading digit takes the parameter
typespec's branches (binary at an int typespec min(size, width), at a logic
typespec a wider value cut to its low digits, at a bit typespec no branch; a hex
value the width; an unsized binary the `orig_size == -1` branch: a prefix reading
1 becomes the all-ones UINT of the width, any other value takes the width).
The lexer's one-bit tokens `1'bx` / `1'bX` / `1'Bx` / `1'BX` (paNumber_1Tickbx)
are BIN:X with the decompile `1'bX`; every other one-bit x literal is the
generic slIntConst branch that keeps the written digit.

1. § xzOvLitKeepsText427 (R11U427_XZOVLIT_OFF, ParamEmit, the override
   render) — an override actual that IS a based literal holding x / z / ?
   digits (`#(.P(4'b10x1))`, `#('bz1)`, `#(8'hxF)`, `#(6'o7x)`, `#(4'dx)`)
   is the StValue above: BIN / HEX with the written digits and the
   lowercase-base decompile, sized by the adjustSize branches at the formal's
   typespec (clsParam8's kind and width); an octal literal reads its digits
   up to the first x as UINT (fromVpiValue has no octal branch), a decimal one
   INT:0. Ours: `X` / `x` / `Z` decompiles with UINT:0 (or slang's 2-state
   value at a typed formal, `9` for 4'b10x1 at `int`). Only a literal
   written directly as the actual. Grid cases/XO.
2. § ovUntypedTsDeclWidth427 (R11U427_OVTSDECLW_OFF, ParamEmit makeParamTs)
   — an OVERRIDDEN untyped parameter's implied `[w-1:0]` range is the
   DECLARATION default's width (`parameter P = 1'b0` overridden with
   `4'b1001` keeps `[0:0]`; `parameter N = 8` keeps no range): Surelog builds
   the typespec once from the declaration. Ours read the width off the
   semantic initializer, which is the override actual. Grid cases/OT (and the
   XO cells, where it co-fires).
3. § sgnBinElabIntBranchStands427 (R11U427_SGNBINBRANCH_OFF, ParamEmit
   § paramInitAdjustSizeElab52) — at an untyped, unranged parameter a signed
   binary default with its MSB set (`parameter D = 4'sb1010`) keeps the
   signed-binary branch's INT value (golden INT:10 size 4 decompile `10`):
   adjustSize reads the CONSTANT's own signed int_typespec; the 52 model
   reads only the target's sign and rewrote the INT back to `4'b1010`.
   Grid cases/EB.
4. § sgnBinUntypedFreshTsUnsigned427 (R11U427_SGNBINTSU_OFF, ParamEmit, the
   signedBinFoldParams typespec) — the fresh int_typespec of that copy is
   unsigned: adjustSize's binary branch clears the literal typespec's sign at an
   unsigned target (`if (!signedLhs) itps->VpiSigned(false)`). Grid EB/eb10
   (both laws needed: each switch alone breaks it).
5. § elabBasedLitLowerBase427 (R11U427_ELABLOWBASE_OFF, ParamEmit, the
   elaborated param_assign) — the elaborated copy of a module parameter whose
   binary / hex default keeps written digits (uppercase base, x / z digits,
   unsized) decompiles `[<size>]'<lowercase base><digits>` (`4'B10x1` ->
   `4'b10x1`, `'B101` -> `'b101`, `8'HxF` -> `8'hxF`, `4'Sb10x1` ->
   `4'b10x1`); a typed parameter's signed hex literal is rendered at the
   declared width (`shortint P = 8'sh7` -> `16'h7`, `int P = 12'shFxF` ->
   `32'hFxF`), a signed binary and a leading-x value keep the written size
   (`int Q = 1'sbx` -> `1'bx`). Definition and package views keep the
   written text. Grid cases/EB (pass 425's ra04).
6. § elabUnszXzTypedAdjust427 (R11U427_ELABUNSZXZ_OFF, ParamEmit) — at a
   typed or ranged parameter an x / z / ? default goes through the
   adjustSize branches at the declared width: unsized `'bx1` keeps `'bx1` size
   -1, `logic [7:0] A = 'b1x` -> UINT:255, `'b0x1` -> `8'b0x1` size 8, `'h1x`
   -> `8'h1x`; sized `logic [7:0] A = 4'hx` keeps `4'hx` size 4, `int D =
   8'h1x` -> `32'h1x`, `logic [3:0] E = 8'b1x01_0011` -> `4'b0011`; the one-bit
   `1'bx` token is BIN:X (§ typedParamXzLitSize407's cells); a wider binary at
   an int or bit typespec abstains; the sizes are re-applied after the
   design-final drains (a later typed pass re-sized the copy at slang's 32-bit
   unsized width). Grid cases/EB.
7. § typedLitElabAdjustLogic427 (R11U427_TYPEDLITADJ_OFF, ParamEmit
   § paramInitAdjustSizeElab52) — the 52 pipeline extended to TYPED logic and
   bit parameters for an unsigned SIZED binary or hex default: hex takes the
   declared width and is rendered at it (`logic [31:0] A = 12'hFFF` ->
   `32'hFFF`, `logic [3:0] G = 8'hAB` -> `4'hAB`), a binary wider than a
   logic parameter is cut to its low digits (`logic [3:0] H = 8'b1010_1010` ->
   `4'b1010` size 4) and a narrower one keeps its own size (`logic [7:0] D =
   4'b1010`, `logic [15:0] SEED = 8'b0` size 8). F3's measured exclusions
   stand (signed, sized decimal, unbased fills, ranged untyped). Grid
   EB/eb13, eb14 (pass 116's F1 cells mv_n_ig, mv_n_ms, k3_sized and pass
   124's v08_trunc move to STRICT_EQUAL).
8. § xzPkgLeafFoldIsRhsCopy427 (R11U427_XPKGFOLD_OFF, ExprEmit, the
   module-side package parameter fold) — a module read of a package parameter
   whose initializer is a based literal LEAF holding x / z / ? digits folds
   like any based-literal package parameter (substituteAssignedValue hands the
   read the compiled Rhs: BIN:10x1 decompile `4'B10x1`, the one-bit token
   `1'Bx` as `1'bX` / BIN:X); ours left a ref_obj. An x under an operator
   stays § unknownOperandDeclinesFold102's ref_obj; this is that law's
   recorded LEAF road. Grid cases/XP (pass 425's OB/ob11).
9. § oneBitXQuirkTokenOnly427 (R11U427_ONEBITX_OFF, ExprEmit IntegerLiteral)
   — the uppercase one-bit x digit belongs to the four dedicated tokens only;
   `1'sbx`, `1'hx`, `1'ox`, `1'dx` keep the written digit (golden `1'sbx` /
   BIN:x where ours wrote `1'sbX` / BIN:X). Grid cases/OX.

## Grid (67 case dirs in EB, OT, OX, XO and XP; evidence/grid_final.txt)

Each case: golden from Surelog v1.87 (`-parse -nobuiltin -nocache -sv dut.sv`,
`--top-module` when a TOP file exists), ours `dut.sv --single-unit
--nobuiltin`, driver drivers/case.sh (exit code, uhdm-cmp line count, sorted
dump distance to golden, strict verdict). Every exit code 0 on pristine, law
and every switch. Every case's first line names its law.

| group | law(s) (first line of the cases) | pristine -> law |
|---|---|---|
| EB (14) | § elabBasedLitLowerBase427 (eb01, eb04-eb08), § sgnBinElabIntBranchStands427 + § sgnBinUntypedFreshTsUnsigned427 (eb02, eb03, eb10), § elabUnszXzTypedAdjust427 (eb09, eb11, eb12), § typedLitElabAdjustLogic427 (eb13, eb14) | 10 NOT_EQUAL -> STRICT_EQUAL, 4 NOT_EQUAL closer (eb01, eb03, eb06, eb07) |
| OT (13) | § ovUntypedTsDeclWidth427 | ot11 STRICT_NOTEQUAL value -> STRICT_EQUAL, 9 NOT_EQUAL closer, 3 controls byte-identical (ot03, ot06, ot07) |
| OX (4) | § oneBitXQuirkTokenOnly427 | 3 NOT_EQUAL -> STRICT_EQUAL, ox02 closer |
| XO (30) | § xzOvLitKeepsText427 (with § ovUntypedTsDeclWidth427 co-firing on xo01-xo26) | 27 NOT_EQUAL -> STRICT_EQUAL, 3 closer (xo26, xo27, xo28) |
| XP (6) | § xzPkgLeafFoldIsRhsCopy427 | 3 NOT_EQUAL -> STRICT_EQUAL (xp01, xp03, xp04), 3 closer |

Totals: 43 NOT_EQUAL -> STRICT_EQUAL, 1 STRICT_NOTEQUAL -> STRICT_EQUAL, 20
NOT_EQUAL on both and closer to golden (sorted dump distance down on every one;
uhdm-cmp count rising only on OT/ot13, 27 -> 36, its head moved later to the
unsized default `0` of a keyword-less entry while the distance fell 98 -> 8),
3 controls byte-identical; NONE AWAY. R11U427_OFF restores pristine's bytes
and exit code on 67 of 67. Of the 64 moved cases one law's own switch restores
pristine on 29; the other 35 need co-firing switches, as the per-case trace
shows (evidence/grid_trace.txt): XZOVLIT + OVTSDECLW on xo01-xo26, SGNBINBRANCH
+ SGNBINTSU on eb02, eb03, eb10, ELABLOWBASE + XPKGFOLD on eb06 and xp02,
ELABLOWBASE + ONEBITX on ox02, ELABLOWBASE + SGNBINBRANCH + SGNBINTSU on eb01,
ELABUNSZXZ + TYPEDLITADJ on eb08, TYPEDLITADJ + ELABLOWBASE on eb13 (the
`4'HC` entry: with TYPEDLITADJ on the decompile is already lowercase so
ELABLOWBASE changes nothing and logs nothing; with it off ELABLOWBASE fires).

Downstream on the 67 cases (drivers/ds.sh, the harness's one() with the
downstream flags; evidence/downstream_cases.txt): 18 STATUS_DIFF -> IDENTICAL,
15 EQUIVALENT -> IDENTICAL, 5 DIVERGENT -> IDENTICAL, 1 STATUS_DIFF ->
EQUIVALENT (XO/xo27), 18 IDENTICAL kept, 8 EQUIVALENT kept (OT/ot02-ot09), 1
DIVERGENT kept (OT/ot10), 1 STATUS_DIFF kept (XO/xo28); none worse.

## Earlier-pass census (drivers/census.sh; evidence/earlier_pass_movers.txt)

Every fence-filtered case dir (a dut.sv) under tests/probe and the main
tree's tools/probe (37563 dirs, pass 428's r11u428repro and v11u428repro
included), pristine against law20: exit codes equal on all 37563 (one dir,
v11u112repro grid brk2 k/m07_hdr_enum_default, rc 139 on both binaries,
unchanged), 4087 of 4087 probe cases byte-identical, 37 movers, every one
closer to golden by sorted dump distance and none writing a line golden lacks
except r11u301repro TP/a07_pkg_param_ctl (below):
- to STRICT_EQUAL (15) or STRICT_NOTEQUAL (2): r11u116repro f1 mv_n_ig, mv_n_ms; r11u215repro C/c01,
  c02; r11u217verify C/c02, c04; r11u266repro S/s18_vec_ctl; r11u425repro
  OB/ob11, ob12 and residue_cases/ra04_upperB_multibit_elab (pass 425's
  residues); r11v124repro pv/v08_trunc; v11u116repro arms/k3_sized;
  v11u210repro C/vc09; v11u407repro VX/vx01, vx02 (pass 407's residues);
  and to STRICT_NOTEQUAL on file: r11u266repro S/s35_xz_ctl, v11u407repro
  VX/vx06;
- NOT_EQUAL on both and closer (20): r11u116repro f1 mv_n_ac, mv_n_ch,
  mv_n_lg; r11u266repro S/s13-s16 (byte, shortint, longint, integer
  controls); r11u301repro TP/a05_child_two, a07_pkg_param_ctl; v11u116repro
  arms/r3_neg; v11u215repro CW/w01_forms; v11u232repro MF/m02; v11u243repro
  B/b02_signedoct, U/u03; v11u266repro VS/vs26_header_and_body_mixed;
  v11u301repro VA/va01_ovr_x; v11u423repro VO/vo03, VS/vs07, vs08; and
  v11u428repro VE/ve06 (pass 428's 1'sbx / 1'Bx residue, distance 52 -> 36).
  uhdm-cmp counts rise on a05 (64 -> 66), a07 (32 -> 74), w01_forms (46 -> 86)
  and va01 (64 -> 66), each with its head moved later: on a07 the definition
  view now folds pk::XV to the constant golden writes, and the next head is
  the ELABORATED cont_assign, where golden folds the whole ternary
  `EN ? pk::XV : 4'h0` to the shared constant and ours keeps the operation
  (now holding a constant operand where it held a ref_obj; residue below).

## Residues (ranked; all wrong on pristine too, none moved away)

1. Untyped x / z and uppercase-base parameter typespecs: the parameter's own
   int_typespec range for a based literal holding x / z digits (EB/eb01,
   eb03, eb06, XP/xp02), and a package parameter defined by another
   (`parameter C = B`, XP/xp06).
2. The elaborated param_assign constant's typespec link under an override
   chain (EB/eb07, OT/ot04, ot09, XO/xo27, xo28).
3. The overridden parameter's per-instance typespec in the overriding
   instance (OT/ot01, ot02, ot05, ot08, ot12; pass 407's TD/VT face).
4. A keyword-less unsized `0` default (OT/ot13); the signed int_typespec of
   `int Q = 1'sbx` (OX/ox02); a generate-scope net in a case with an x/z
   override (XO/xo26).
5. The elaborated fold of a ternary over a package x parameter (r11u301repro
   TP/a07_pkg_param_ctl).
6. Carried: pass 425's list (up05, vb05/vb10, VL, VQ, vn03/vn07, the
   ModuleEmit unsized-fold cells), pass 423's and earlier lists, tnoc's
   333:14 head, fx68k's design-level CF parameter, p733's defparam.

## Sister-ground faces (reported, not written)

- The 4 testbenches rows (uvm_agent_active, uvm_agent_passive,
  uvm_driver_sequencer_env, uvm_monitor_env): after pass 428 (f713a2062) they
  read STRICT_NOTEQUAL differ:type(1) with the next head a cast's
  uvm_radix_enum typespec reaching the definition listing of
  uvm_field_flag_t with its range unfolded where golden reaches a copy with
  the folded INT:27. The cast typespec is ExprEmit's (the explicit
  ConversionExpression branch of emitExpr choosing which enum typedef copy
  the cast references). NOT WRITTEN: at this pass's base (42dfe016b) those
  rows still differ first at TypeEmit's uvm_resource#(TYPE) face, so a law
  could not be measured on them here; it is the next pass's on top of
  f713a2062.
- Pass 428's § synOneBitXUpper428 (TypeEmit, syntax-built `1'bX`) and this
  pass's § oneBitXQuirkTokenOnly427 (ExprEmit IntegerLiteral) both shape the
  one-bit x digit through different builders; v11u428repro VE/ve06 moves
  closer on this pass's base. The integration sweep on top of f713a2062 is
  the measurement of the pair.

## Process

- Resumed from the 2026-10-21 run that the usage limit cut; every inherited
  number was re-measured: the grid on law19 and law20 (identical to the draft
  line for line), the census on law20, the downstream cases on both binaries,
  the targeted traced runner call, and the one full sweep on law20 (the cut
  sweep in /tmp/r11u427_sw not used).
- The rename for the word rule rebuilt the binary (law20, the one rebuild
  of this resumed run; no behavior change: grid bytes equal).
- Slips, none affecting a measurement: (1) a single-row runner call on
  bsg_mul_pipelined (pristine and law19) started while the sister r11u430's
  single-row runner call on the same row was live (its pgrep check printed
  the process and the call was not held); (2) the first prediction runner's
  wait loop matched its own command line and never started; stopped by its
  task id and relaunched from a script file; (3) the binary audit's first
  grep opened the cmds.txt records of the sweep workdir before filtering the
  list on the fence (10 records whose path matches a fence entry; harness
  records, no source opened or run, nothing printed from them); redone
  fence-filtered first.
- The fence list was read into a file by a program and never printed; no
  other agent's process touched; no fenced test named, opened or run.

## Files

- cases/<GROUP>/<case>/dut.sv (67), TOP where needed.
- drivers/: case.sh (one case: golden + ours), grid.sh (the grid with every
  switch), census.sh (earlier-pass census), ds.sh (downstream per case),
  show.sh, newwrong.sh, fullsweep.sh (the one five-stage sweep).
- evidence/: grid_final.txt, grid_trace.txt, downstream_cases.txt,
  earlier_pass_movers.txt, sweep_summary.txt, sweep_trace.txt,
  byteverify.txt, canaries.txt.
