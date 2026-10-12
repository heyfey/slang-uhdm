# r11u294 — expression/parameter ground: struct-parameter member selects in parameter initializers, the coverpoint method-call path span, casts to a module type parameter

Pass 294, implementer, ground A (src/ExprEmit.cpp, src/ParamEmit.cpp; switches in the
new src/R294.h). Base 1ebef106 (pass 292 on pass 297). Every number below is from the
frozen binaries:

| binary | md5 | what |
|---|---|---|
| pristine | bf9a4030d405b91c5a4e5001a5b0213a | the base, byte-identical to the main tree's build/slang-uhdm |
| law | 67c65e9397e64f79dbc463e26c64e928 | the delivered patch (slang 12.0.0+545f88b2e, UHDM 1.87) |

## Verdict

**FOUR PROBE CONVERSIONS, no probe change, no corpus row moves (0 of 2560 corpus and
0 of 805 downstream databases move in bytes).** Fresh rows of the law sweep
(`evidence/sweep_L.log`; results/golden_probe.csv untouched):

    r11u21repro/t9,EQUAL,,equal                       (base differ:col(3))    § paramInitMemberSelLvShape294 + § paramInitMemberSelFoldBaseSpan294
    r11u24repro/n1,EQUAL,,equal                       (base differ:col(3))    § paramInitMemberSelLvShape294 + § paramInitMemberSelFoldBaseSpan294
    r10svs8repro/a3_builtins,EQUAL,,equal             (base differ:endcol(1)) § dottedCallHpSpansInvocation294
    r11u113repro/grid/c/c16_mod_comb,EQUAL,,equal     (base differ:type(1))   § castModTypeParamDefaultTs294

Gate sweeps (`tests/sweep.sh --jobs 3`):

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3959 + STRICT_NOTEQUAL 128, regressions=0 conversions=0 changes=0 | EQUAL 3963 + STRICT_NOTEQUAL 124, regressions=0 **conversions=4** changes=0 |
| surelog | default 480 + 0, testflags 474 + 0 (954 + 0), 0/0/0 | identical, 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | identical, 0/0/0 (stamped_gen_param d/t CMP_NOTEQUAL as at the base) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | identical; downstream.csv byte-identical to the committed one |

Both sweeps exited 1 on the law-index check alone (`law index STALE` at the base
already); the patch carries the regenerated tests/LAWS.md. Row by row the law's
surelog.csv differs from pristine's only in the LowMemLib/LowMemPkg testflags detail
text (the workdir path), uhdm2rtlil.csv and downstream.csv in nothing, probe.csv in the
four conversions.

## The laws (each under its own switch; R11U294_OFF drops all four; R11U294_TRACE=<dir> logs every firing, switch-off and abstention)

1. **§ paramInitMemberSelLvShape294** — ExprEmit, the single-select member-path branch
   (`obj.member[idx]` over a plain base). `R11U294_PISEL_OFF`. A struct parameter's
   (packed or unpacked) member read ending in a select, in a parameter initializer,
   takes the lvalue path shape: Surelog compiles a parameter's value through
   CompileHelper::compileSelectExpression's member branch (CompileExpression.cpp, the
   `paPs_or_hierarchical_identifier` / `slStringConst` branch), which locates the base
   ref_obj on the FIRST MEMBER's token (`populateCoreMembers(Bit_select, Bit_select, r1)`)
   and builds `field[idx]` as a bit_select named `field` from the field token to the end
   of its bracket (`populateCoreMembers(Bit_select, last_indexed, bsel)`) with no stored
   full name, so the reader names it over the final parent chain (golden t9
   `CFG` 17:34-35, `d` 17:34-38 `work@kid.CFG.d[0].d`; ours `CFG` 17:30-33, the select at
   its index 17:36-37 named `CFG.d[0].d`, frozen before the param_assign hung under its
   module). The member-only path (`CFG.u`) already had that shape (the member branch's
   `paramInitStructMember`). Abstains (trace `_ABSTAIN`) when the path does not stand
   under the param_assign through operations only (a system-call argument `$bits(CFG.d[1])`,
   a user-call argument `f(CFG.d[1])`: golden keeps the rvalue spans, grid PS ps22/ps25/ps26
   — the first draft moved ps22's `CFG` one record away, refined before the freeze) and on
   a written package qualifier (`pk::C.d[0]`, the qualified road; PF pf10).
2. **§ paramInitMemberSelFoldBaseSpan294** — ParamEmit, the elaborated fold's location
   (`emitParameters`, after the generic `setLoc(rhs, rhsLoc)`). `R11U294_PISELFOLD_OFF`.
   The elaborated fold of such a select whose base is § asmEncFollowsRef's family
   (`asmRefFamilyBase`: a packed struct parameter a member-by-member const function
   assembles, through bare references) is located at the BASE NAME and left unparented,
   the shape drainPaAsmMemberSlice already writes for the select-free member read (golden
   t9 `BIT0` 17:30-33 with no vpiParent; ours the whole initializer 17:30-38 parented at
   the param_assign). DECODED DISTINGUISHER (grids PT, PU, PM, PF): a struct written as a
   pattern keeps the whole initializer's span for every member type (int unsigned, int,
   logic, bit, integer, byte, shortint, longint, signed vectors), every target type (int,
   logic, ranged, untyped, bit, integer, byte, shortint) and every reader (unused, direct,
   concatenation, operation, process); only the function-assembled base takes the base
   span. Abstains in a generate-local holder, on a qualified base and on an overridden
   reading parameter (the record's own exclusions, § paAsmMemberSliceFold21).
3. **§ dottedCallHpSpansInvocation294** — ExprEmit, the dotted user/built-in call in
   expression position (the hier_path over name-only ref_objs plus a method_func_call).
   `R11U294_DOTCALLSPAN_OFF`. The path spans the whole written invocation, its argument
   list included: Surelog locates it at the Complex_func_call node (golden a3_builtins
   `r8 = cgc8.cpc8.get_coverage();` 60:12-36); slang gives a built-in method called
   through a COVERPOINT (or a cross) a CallExpression ending at the method name (60:12-34),
   so the range is read from the enclosing InvocationExpression when it reaches further.
   A user call (`i.f()`, `blk.f(3)`) and the covergroup's own `cg.get_coverage()` already
   end at the closing parenthesis and do not move (grid DC dc08-dc10, md5-identical).
4. **§ castModTypeParamDefaultTs294** — ExprEmit, the cast branch where the cast's left is a
   name (the size-cast fallback). `R11U294_CASTMODTP_OFF`. A cast to a MODULE's or
   INTERFACE's header type parameter (`idx_t'(a)`, `parameter type idx_t = logic [W-1:0]`)
   binds the type parameter's DEFAULT typespec, the object the definition compile built
   for the parameter (`typeParamDefaultTs`, keyed by the definition, the object every
   type-parameter-typed port shares): golden c16_mod_comb logic_typespec 1:67-80 with its
   range in both views and under an instance override (MT mt06); ours bound the name as a
   value, failed, and minted an integer_typespec at the name (2:19-24) and exited 4 (an
   unsupported construct). § castTypeParamDefaultLoc292 is the class twin. Every converted
   MT case-view also goes from exit 4 to 0. A definition-view generate process keeps its
   unsupported_typespec (MT mt12, unchanged); a type parameter declared in the module BODY
   has no `typeParamDefaultTs` entry and the law abstains (trace `_ABSTAIN nodefault`;
   MT mt09 stays at type, residue 4).

## Grid (tools/probe/r11u294repro/cases; drivers/gridall.sh, both views, every line with its exit code)

115 case dirs, 230 case-views (PS 30, PT 10, PU 10, PM 20, PF 18, DC 12, MT 15), labels
pristine / law / law+R11U294_OFF / law+each switch (`evidence/grid.txt`,
`grid_summary.txt`, `grid_attrib.txt`):

- 190 moving, 88 entering STRICT_EQUAL, 0 leaving; R11U294_OFF gives pristine's bytes on
  230 of 230.
- exit codes: 26 change, all MT 4 -> 0 (mt01-mt08, mt10, mt11, mt13-mt15 in both views).
- uhdm-cmp line counts: MT mt02 and mt15 82/86 -> 0 in both views (converted); PF pf16
  elaborated 19 -> 15 with the same first difference (golden's interface listing has no
  Rhs where ours has the constant; the law only drops our constant's parent line).
- attribution (single-switch runs): PISEL 120, PISEL+PISELFOLD 28 (the PF function-
  assembled family and t9's shape), CASTMODTP 26, DOTCALLSPAN 16; every mover back to
  pristine under the switch(es) named.
- the chain-keyed away census (drivers/awaygrid.sh, `evidence/grid_away.txt`): away 0
  on all 190 movers, 626 records toward golden; the positive control (binaries swapped,
  every tenth mover, `evidence/away_poscontrol.txt`) reads away 1 to 16 on 19 of 19.
- downstream (drivers/dscases.py, `evidence/downstream_cases.txt`): MT mt01-mt06, mt08,
  mt10, mt11, mt13-mt15 EQUIVALENT -> IDENTICAL; every other case keeps its verdict
  (MT mt07 and PF pf10 DIVERGENT on both binaries).
- movers that do not convert (all wrong on pristine too, heads listed): PS ps01-ps03,
  ps08, ps17, ps18, PT pt02, PU pu07/pu09, PM even cases col -> file: the elaborated
  `localparam logic B` typespec (golden the `logic` keyword located, ours an unlocated
  logic_typespec with a range); PT pt05, PU pu04, PM odd cases col -> type: the same
  typespec under `bit`/`int` targets; stage-1 cases moving inside stage 1 (PS ps04, ps09,
  ps12-ps14, ps19, ps20, ps22-ps24, ps29; PT pt01, pt06-pt08, pt10; PU pu02, pu03, pu08;
  PF pf08, pf16): the PT/PM int-target stage 1 is golden's `INT:-1` for a set bit read
  into an int (a Surelog sign-extension defect, not copied); MT mt07 line -> line (the
  function return type, see residue 5).

Byte controls (drivers/controls.sh over every dut.sv dir of r11u118repro, r11v11u118repro,
r11u119repro, r11u292repro, v11u292repro, r11u21repro, r11u24repro, r11u113repro,
r11u154repro, r11u163repro, r11u120repro, r11u218dec, r11u184repro, r11u288repro,
v11u288repro, r11u124repro, r11u131repro, r11u181repro, r10uvm59repro, r11u297repro and
v11u297repro, path list filtered by $FENCED first; `evidence/controls.txt`,
`controls_summary.txt`): 2326 case-views, 6 moving, 2 entering STRICT_EQUAL
(r11u113repro/grid/c/c03_mod_ref d/e, NOT_EQUAL stage1 rc 4 -> STRICT_EQUAL rc 0 under
CASTMODTP), 0 leaving; r11u24repro/n8 d/e inside stage 1 (PISEL, away 0, 3 records
toward), r11u292repro/cases/CT/ct06_tp_module d/e rc 4 -> 0 with the same 277-line stage 1
(CASTMODTP, away 0); the away census on all 6 reads 0.

## Prediction and gates (evidence/predict.txt, gates.txt)

The firing census (drivers/tracecensus.sh) ran on the frozen law binary BEFORE the law
sweep, over the probe cases and both corpora in both modes with the fence filter: it
predicted exactly the four probe databases above (t9, n1: PISEL + PISELFOLD; a3_builtins:
DOTCALLSPAN; c16_mod_comb: CASTMODTP) plus one abstention (r11u47repro/arms/g2,
CASTMODTP `_ABSTAIN`, no bytes) and NO corpus firing at all (no trace file was opened by
any corpus run). A first census on a draft binary was stopped when the PISEL draft was
refined (residue-free refinement of the ps22 / pf10 away record); the predict file is the
final binary's.

- byteverify on fence-filtered mirrors: 0 of 2560 corpus databases move; SELFCHECK reads
  2559 of 2560 flagged: the self-check compares every database against one fixed database,
  which never differs from itself (the known artefact, not a mover). Probe databases:
  exactly the four predicted of 4087. Downstream slang-lane databases: 0 of 805.
- canaries surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both.
- binary-path audit: 3265 cmds.txt naming each sweep's own binary, 50 running no slang,
  8 fenced paths skipped by name, 0 other.
- determinism: three concurrent draws of the law binary on Earlgrey_0_1 and the UVM rows
  and Rggen, one hash per row-mode, each equal to the law sweep's database.
- uhdm-cmp: 0 lines on every touched probe case and corpus row (nothing in the corpus moved).

## Residues, ranked (all wrong on pristine too)

1. The struct-parameter select in a GENERATE-LOCAL parameter initializer (PS ps10, ps11,
   PF pf09): the definition view's generate statements are emitted by TypeEmit
   emitSyntaxExpr called from ModuleEmit emitDefGenStmts (gdb backtrace on pf09) — the
   SISTER'S ground; the same law (base at the member token, the select from the member to
   its bracket, the index named by the path) applies there.
2. The elaborated `localparam logic B` / `bit B` / `int B` typespec beside the fold (head of
   PS ps01-ps03 and the PT/PU/PM movers after law 1): golden locates the keyword typespec,
   ours mints an unlocated logic_typespec with a range; not decoded (ParamEmit makeParamTs
   or TypeEmit).
3. Part selects, indexed part selects and multi-index selects of a member in a parameter
   initializer (PS ps05, ps06, ps15; PF pf17), a nested member path (ps04) and the
   qualified `pk::C.d[0]` (ps23, pf10): stage 1 on both binaries, other builders.
4. Casts to a module type parameter declared in the module BODY (MT mt09; no
   `typeParamDefaultTs` entry — the body list builds the default elsewhere) and the module
   function's return typespec `function T f` (MT mt07, line: golden at the default, ours at
   the T in the header; TaskFuncEmit, the sister's).
5. The coverpoint call through a macro (DC dc11, stage 1 on both binaries).
6. The remaining 124 probe residues: first records with their writers in
   `evidence/residue_first_records_base.txt` and `evidence/residue_writers_base.txt`
   (each first record's ours-side location hooked in a debug build of the base and the
   setLoc callers tallied: ExprEmit/ParamEmit/StmtEmit heads are the select-naming text
   defects c2_idxkind, v92_b2_varsel, b1_sites, v8_sites2, the v4_ops qualifier quirk,
   g175_c_tail, g193_c_argface, the r11u109 64-bit cast values (Surelog defects), vy5 and
   the c_paraminit / v_takn_real folds (ExprEmit called from ModuleEmit emitContAssigns),
   the package-function call folds v3_argts8, v3_clone13, v9fold8, a1, va8, t12,
   a9_class_holder, g213_i_scopedtd, v194_a_explicit (StmtEmit called from TaskFuncEmit),
   the importer-copy typespec swaps v169_g_control, v62e_bind, g1k_hop_userfn and
   f1_noovr_arr_recvp (ParamEmit makeParamTs / patchParamTypespecs), v111_b6 (ParamEmit
   emitPackageVar)), and the brief's items (2) to (7) beyond the above not attempted.

Sister-ground faces read on this pass (reported, not written), with the writer from the
backtrace census:

- r11v66repro/a3_inst66 endcol(6): the elaborated cont_assign fold of `assign y = Q.a`
  where `Q = '{a: P * 2, ...}`; golden copies the param_assign operand constant located
  at `P` (10:34-35), ours spans `P * 2`; ModuleEmit setLocCompact over the
  § caStructParamModSharesPaOperand289 site.
- r10rgg4repro/c9_litarith_noovr endcol(1): ModuleEmit fillSizeDimRange (port array `[3*2]`).
- r10earl115repro/p1_pos115, r10earl121repro/a1_axis121, r11v46repro/grid7,
  r10vrgg17repro/v8, r11u52vrepro/grid/b2_exprforms, r10earl41repro/v41v_comment,
  r11u117repro/grid/g1/g13, r10earl104repro/vb4_instarr: TypeEmit emitSyntaxExpr from
  ModuleEmit emitDefGenStmts / generate statements.
- v11u110repro/brk/v5/k11_logic_param_range, r10v200repro/v200_5_modmat: TypeEmit makeTypespec.
- r10rgg9repro/cells/c_iface_body, r10v92repro/v4_arm, r11u88repro a6_commadrive: ModuleEmit
  emitContAssigns / emitInterfaceDef; r11u13repro/b3, r11u24repro/n4, r11u1repro/grid2,
  r11v1repro/vA, r11u93repro pb19_modportview: ModuleEmit emitInstance;
  r11v11u8repro/v9: the macro column model (UhdmExporter).

## Process

- Worktree /tmp/wt_r11u294 at 1ebef106, scratch /tmp/r11u294_*; built with -j 2 (the
  pristine frozen before any edit, md5 equal to the main tree's). A debug-info copy of the
  base sources was built in scratch (one hook function in its setLoc, never in the
  worktree) to read backtraces; gdb ran only on probe cases and this pass's fresh cases.
- THE FENCE: every driver reads $FENCED fail-closed from tools/probe/r11u107repro/canaudit.sh
  (drivers/env.sh); the census filtered its corpus runs by $FENCED; byteverify ran on
  fence-filtered mirrors; the probe and downstream byte comparisons and the binary audit
  filtered their path lists by $FENCERE before any file was opened. No fenced source, copy
  or database was read, run or debugged. No other agent's process was listed or signalled.
- Slips, no effect on results: the case files of PS were first written with an
  uncommented description line (Surelog syntax error, NOGOLDEN), fixed and re-run; the
  first census ran on a draft binary and was stopped by its own task id when the PISEL
  gate was refined (its partial output discarded, the census re-run in full on the frozen
  final binary before the law sweep).
- Drivers copied from r11u292repro/drivers with their pass names updated.
