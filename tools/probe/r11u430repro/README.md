# r11u430 — module/type ground, sv-tests campaign (pass 430)

Base f713a2062. Pristine reading: the master's control sweep `/tmp/intr11u428`
(its csvs equal the committed `results/*.csv`); no pristine build, no pristine
sweep (measurement budget, user 2026-10-18). Pristine binary for case runs:
the main tree's `build/slang-uhdm` frozen at `/tmp/r11u430_bin/pristine`
(md5 65e4ae8b4a83a4366e3a2c1c7eb371f6). Final law binary frozen at
`/tmp/r11u430_bin/final` (md5 ce2b1c0700aa7b98649896ffca6cb8a1, the
worktree build `law11`), links slang 12.0.0+545f88b2e.

## sv-tests rows (before -> after, by path)

| row | before | after | laws |
|---|---|---|---|
| chapter-7/structures/unpacked/default-value.sv | DIFFERENT | **EQUAL** | § structMemberDefaultParamRef430 |
| chapter-18/18.14--random-stability_1.sv | DIFFERENT | **EQUAL** | § clsArrPropConcatInitElemSize430 |
| generated/basejump/bsg_misc_BaseJumpSTL_bsg_mul_pipelined.sv | DIFFERENT (head: the unbuilt `rof` block's param_assigns) | DIFFERENT (uhdm-cmp 354 -> 13 lines; head moved later to ParamEmit's override-width range, sister ground) | § defGenLpNoBlockListed430, § defGenLpRangedTs430 |

## The one five-stage sweep (final binary, `drivers/fullsweep.sh`, workdir /tmp/r11u430sw2, trace on)

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0 conversions=0 changes=0; csv identical to the control.
- surelog: default CMP_EQUAL 480, testflags 474 (954 of 954 judge-equal row-modes, STRICT_NOTEQUAL 0; Tnoc d/t CMP_NOTEQUAL standing), regressions=0 conversions=0 changes=0; the csv differs from the control only in the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, regressions=0 conversions=0 changes=0; csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871; csv identical to the control.
- sv-tests (main tree's scripts/check_svtests.py, the base's golden): EQUAL 1891, STRICT_NOTEQUAL 6, DIFFERENT 43, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; **regressions=0 conversions=2 changes=0**:
  - `CONVERSION chapter-18/18.14--random-stability_1.sv: DIFFERENT -> EQUAL` (fresh row `chapter-18/18.14--random-stability_1.sv,EQUAL,,equal`)
  - `CONVERSION chapter-7/structures/unpacked/default-value.sv: DIFFERENT -> EQUAL` (fresh row `chapter-7/structures/unpacked/default-value.sv,EQUAL,,equal`)
- The corpus stage's exit 1 is the stale law index alone (`law index STALE: tests/LAWS.md`), regenerated afterwards; `python3 scripts/law_index.py --check` current.
- byteverify (law workdir against the master's control /tmp/intr11u428, SELFCHECK=1, per corpus subtree): surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805, every self-check flagging n-1 of n.
- canaries ok=52 (surelog) and ok=16 (uhdm2rtlil), changed 0; ctcan2 ok=58 / unknown 1 and ok=2 / unknown 6, both PASS.


## Goal 1

`results/golden_svtests.csv` at the base: 75 SURELOG_ONLY + 303 BOTH_REJECT,
no SLANG_CRASH. None of the rejecting rows carries an exporter message
(nothing names "unsupported"); all 75 SURELOG_ONLY details are slang front-end
`error:` diagnostics (undeclared identifier 7, unknown module 6, expected a
declaration name 5, duplicate definition 4, time-scale 7, ...). Nothing on
this ground. The exit-4 backlog shapes (chandle arrays and aliases, vc13, vy02,
vu02, aq09, va09, ac04/ac05, the multi-dimension typedef uses, the event
arrays, the union shapes) were not written by this pass.

## Laws (each behind its own switch in src/LawSwitch.h; `R11U430_OFF` drops all; `R11U430_TRACE=<dir>` logs firings)

1. **§ clsArrPropConcatInitElemSize430** (`R11U430_CLSARRCONCAT_OFF`;
   src/UhdmExporter.cpp emitClassDefn). A FIXED-size array class property
   initialized by an unpacked-array concatenation (`int tab1[5] = {1, 2, 3, 4, 5}`)
   takes the carrier § assocPropPatternInitRidesElem31 gives a dynamic array:
   one operation parented at the vpiReg element, hung off both the element's
   and the array_var's vpiExpr, its unsized decimal operands at the element
   width (int 32, byte 8; a sized literal keeps its own width). Pristine head on
   18.14_1: `constant 22:19 UINT:1` size 64 where golden has 32. Cases CA/ca01,
   ca02, ca03, ca05, ca07, ca08 (ca04, an assignment pattern, is the control).
2. **§ modArrConcatInitElemSize430** (`R11U430_MODARRCONCAT_OFF`;
   src/TypeEmit.cpp emitArrayVar). The module-scope twin: `int tab[3] = {1, 2, 3};`
   gets the same carrier pair, leaf constants unparented, unsized decimal
   operands at the element width. Cases CA/ca06, ca09, ca13, ca14 (to
   STRICT_EQUAL); ca10 (parameter operands) and ca11 (generate scope) closer;
   ca12 (a package variable, the law does not reach it) byte-identical control.
3. **§ structMemberDefaultParamRef430** (`R11U430_MEMBERDEFPARAM_OFF`;
   src/TypeEmit.cpp buildStructTs). A struct member default written as a bare
   module PARAMETER name (`bit [3:0] lo = c;`): Surelog's definition-view struct
   keeps it as an unbound ref_obj (vpiName and vpiFullName the bare name, no
   actual, no parent); the elaborated view holds the parameter's value at the
   reference when the parameter is untyped, not overridden, and initialized by
   an integer literal (a sized literal as compiled, `4'h5` HEX:5 size 4; an
   unsized decimal at size 32). Any other elaborated shape is not written.
   Pristine head on default-value.sv: golden's `ref_obj (c) 21:17` missing in
   ours. Cases DM/dm01, dm04, dm06 (to STRICT_EQUAL); dm03, dm07, dm08 closer
   (member span now matches golden, head moved later); dm02 (`c + 1`), dm05
   (`p::K`) byte-identical controls.
4. **§ defGenLpNoBlockListed430** (`R11U430_GENLPNOBLOCK_OFF`;
   src/ModuleEmit.cpp emitDefGenStmts). A generate block the elaboration never
   builds (a loop of zero iterations under an uninstantiated definition's
   default parameters) still lists its UNTYPED (and `int`) parameters in the
   definition view, as Surelog compiles the block from its text: the
   param_assign, its parameter (no typespec for a bare declaration; the
   declaration span's int_typespec with the packed range for a ranged one; an
   `int` one an int_typespec at the keyword, signed) and its syntax-built
   right side. Typed (logic, signed, unpacked) parameters have no symbol and
   are not written. Measured with and without an explicit top (gl01/gl10,
   gl05/gl09) and nested (gl11). Cases GL/gl01, gl03, gl05, gl06, gl09, gl10,
   gl11 (to STRICT_EQUAL); gl12 closer (typed residues); gl02 control.
5. **§ defGenLpRangedTs430** (`R11U430_GENLPRANGEDTS_OFF`;
   src/ModuleEmit.cpp emitDefGenStmts, definition half, and emitTopPorts'
   generate-localparam drain, elaborated half). A generate-block parameter
   whose implicit type carries a packed range with literal bounds
   (`localparam [31:0] x7 = y + i - 6;`) is described by an int_typespec
   spanning the range and carrying it (bounds as written, UINT size 64), shared
   by the elaborated parameter, keeping that reference when its initializer
   reads the genvar; the elaborated param_assign constant takes the bare value
   clone when a continuous assignment or port connection reads it. Cases
   GL/gl04, gl08 (to STRICT_EQUAL), gl07 closer.

No src/R*.h, no getenv, no reader function, no LawState.h section; the five
switches read through `lawOn(430, ...)`, every law logs through
`lawTrace(430, ...)`. No flag is written across emitters by this pass.
EmitHelpers.h, ExprEmit, StmtEmit, ParamEmit, TaskFuncEmit, include/ and
uhdm_main.cpp unchanged.

## Grid (final binary vs pristine; `drivers/grid.sh`, every exit code recorded)

34 case dirs in CA, DM and GL (evidence/grid.txt; every exit code 0 on both binaries):
22 NOT_EQUAL -> STRICT_EQUAL (CA/ca01, ca02, ca03, ca05, ca06, ca07, ca08, ca09,
ca13, ca14; DM/dm01, dm04, dm06; GL/gl01, gl03, gl04, gl05, gl06, gl08, gl09,
gl10, gl11); 5 controls byte-identical to pristine (CA/ca04 STRICT_EQUAL, CA/ca12,
DM/dm02, dm05, GL/gl02 NOT_EQUAL); 7 NOT_EQUAL on both and closer to golden by
normalized dump distance (CA/ca10 69 -> 54, ca11 75 -> 33, DM/dm03 83 -> 71,
dm07 106 -> 84, dm08 28 -> 16, GL/gl07 333 -> 156, gl12 210 -> 165; the uhdm-cmp
counts of dm03, dm07, gl07 and gl12 grow only because their first head moved
later in the walk); none away. R11U430_OFF gives pristine's bytes and exit code
on 34 of 34; each case's own switch alone on 34 of 34.

Cases and their laws: § clsArrPropConcatInitElemSize430 CA/ca01-ca05, ca07, ca08;
§ modArrConcatInitElemSize430 CA/ca06, ca09-ca14; § structMemberDefaultParamRef430
DM/dm01-dm08; § defGenLpNoBlockListed430 GL/gl01-gl03, gl05, gl06, gl09-gl12;
§ defGenLpRangedTs430 GL/gl04, gl07, gl08.

Downstream (`drivers/dsgrid.sh`, 27 class-free cases; the first 23 on law11, md5-equal to the final binary, gl09 to gl12 on the final): CA/ca11 EQUIVALENT ->
IDENTICAL, the other 26 IDENTICAL on both; none worse (evidence/dsgrid.txt).
CA/ca15 (`int tab1[2][2] = {{1,2},{3,4}}`) was dropped: upstream slang rejects it.

## Census before the sweep (predicted firing, by name)

Fence-filtered source scan of the corpora (21315 files after the filter;
evidence/scan_*.txt): fixed-size array concatenation initializers only in
Surelog's `Google` sources (row SLANG_REJECT / TIMEOUT) and black-parrot's
testing tree (not compiled by a live row); struct member defaults naming a
parameter only in the Google tree; dynamic/queue concatenations in five probe
cases (r10buvm31 g31a3, r10svs6 b4_qual, r10uvm145 g145_b_kind, r10v145
v145_e_oob, r10vbuvm31 gv31a6) run on both binaries: byte-identical, no
firing. Ranged generate localparams: 68 candidate files; the small rows
(DecimalSize, DefParamIndex, PartSelectRange, func_upto, hierdefparam,
v59v2_earl59) run on both binaries byte-identical with no firing; the rest
measured by the sweep's trace and byteverify.

Trace census of the sweep (R11U430_TRACE over all five stages): exactly three
databases fire, all sv-tests rows, the positive controls of the census:
18.14--random-stability_1 (clsArrPropConcatInitElemSize430 x2),
default-value (structMemberDefaultParamRef430 x2) and bsg_mul_pipelined
(defGenLpNoBlockListed430 x3, defGenLpRangedTs430 x11). No corpus row and no
probe case fires, as predicted.

Away census on the 70 kept sv-tests databases (rows not EQUAL; path-normalized
uhdm-dump against the control's, evidence/sv_away.txt): 68 identical; 2 differ:
bsg_mul_pipelined (the firing row: uhdm-cmp 354 -> 13 lines, normalized dump
distance to golden 9676 -> 8581, toward golden) and tnoc (its dump cut by the
900 s timeout on both sides; the two databases are the same size, 230131612
bytes, and uhdm-cmp between them reads 0 lines; no firing logged on it).

## Residues (ranked; all wrong on pristine too, none moved away)

1. bsg_mul_pipelined's next head, **sister ground (ParamEmit makeParamTs)**:
   an untyped parameter whose default is an unsized literal (`group_vec_p = 0`)
   but whose instance override is sized (`40'h...`) gets an int_typespec with
   `[39:0]` from the override; golden derives the range from the DECLARATION's
   initializer only (no range for `0`, `[0:0]` for `1'b0`). makeParamTs reads
   `ps.getInitializer()` (the override actual) before its declaration-syntax
   fallback. Minimal repro evidence/paramemit_override_width_face.sv.txt
   (uhdm-cmp 13 lines with and without an explicit top).
2. Typed, signed and unpacked localparams in an unbuilt generate block (GL/gl12).
3. Concatenation initializers with parameter operands (CA/ca10), in generate
   scopes (ca11) and in packages (ca12).
4. Struct member defaults over expressions (`c + 1`, DM/dm02), package
   parameters (dm05); the struct member reference full names in elaborated
   copies (dm03, dm07).
5. The carried backlog of passes 402 to 428 (exit-4 shapes, p719's nested
   module implicit nets, p193_2, p600, the UVM listing faces, p737, p733,
   dpi_rom, the inv-placeholder rows), not touched.

## Sister-ground faces (reported, not written)

- ParamEmit makeParamTs: the override-width range above (bsg_mul_pipelined).
- Carried: ExprEmit's radix-enum cast typespec behind the 4 testbenches rows'
  type(1) and the 16 uvm-examples rows.

## Process

- One full five-stage sweep, on the final binary only (09:18 to 09:43 on
  2026-10-25), launched after quiet.sh read zero sweep processes; intermediate
  binaries law1 to law11 got case runs and targeted runner calls only (the
  51-row target list on law8, the bsg_mul_pipelined row on law11).
- No pristine build, no pristine sweep: the pristine reading is /tmp/intr11u428.
- Slips (none affecting a measurement): on 2026-10-21 the 51-row runner call on
  law8 and the builds law9 to law11 with GL/CA case batches overlapped the sister
  r11u427's sweep (the launch did not wait on the pgrep it printed); on
  2026-10-25 quiet.sh matched its own launching shell wrapper (the heredoc text
  held the runner's name) and was stopped by its task id, the pattern now anchored
  on the interpreter (drivers/quiet.sh); case labels were corrected after the
  resume (three law names renamed to the code's, CA/ca06 and GL/gl04 relabelled to
  the law that fires on them), CA/ca15 removed (upstream slang rejects it).
- The fence list was read into a file by a program without printing it; every
  tree-wide scan was filtered on it before opening a file; no fenced test was
  named, opened or run. No other agent's process was touched.
