# v11u294 — adversarial verification of r11u294 (expression/parameter ground: struct-parameter member selects in parameter initializers, the coverpoint method-call path span, casts to a module type parameter)

Verifier of pass 294 (implementer r11u294, ground A). Base 1ebef106 (pass 292 on pass 297).
Both binaries rebuilt from scratch in fresh worktrees (system-deps cmake config, -j 1 each)
and frozen before any measurement:

| binary | md5 | what |
|---|---|---|
| pristine | bf9a4030d405b91c5a4e5001a5b0213a | 1ebef106, byte-identical to the main tree's build/slang-uhdm |
| law | 67c65e9397e64f79dbc463e26c64e928 | 1ebef106 + /tmp/r11u294.patch (md5 404c6056…), byte-identical to the implementer's law binary |

Both report slang 12.0.0+545f88b2e and UHDM 1.87.

## Verdict

**VERIFIED, NO PRODUCTION FIX.** Every headline number of the implementer reproduces bit for bit.
No case was found where pristine was right and the law wrong. That covers the implementer's
230-case-view grid, 136 fresh case-views here, and 2310 trigger-selected control case-views from 127
earlier repro dirs. The chain-keyed away census reads 0 on all 400 movers: 190 implementer-grid, 112
fresh and 98 control. No downstream verdict gets worse.

The four probe conversions (fresh rows of this verifier's law sweep; results/ untouched):

    r10svs8repro/a3_builtins,EQUAL,,equal             (pristine: STRICT_NOTEQUAL,differ:endcol(1))  § dottedCallHpSpansInvocation294
    r11u113repro/grid/c/c16_mod_comb,EQUAL,,equal     (pristine: STRICT_NOTEQUAL,differ:type(1))    § castModTypeParamDefaultTs294
    r11u21repro/t9,EQUAL,,equal                       (pristine: STRICT_NOTEQUAL,differ:col(3))     § paramInitMemberSelLvShape294 + § paramInitMemberSelFoldBaseSpan294
    r11u24repro/n1,EQUAL,,equal                       (pristine: STRICT_NOTEQUAL,differ:col(3))     § paramInitMemberSelLvShape294 + § paramInitMemberSelFoldBaseSpan294

## Gates (tests/sweep.sh --jobs 3, both sweeps run from the law worktree so that probe paths have equal length; evidence/sweep_P.log, sweep_L.log)

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3959 + STRICT_NOTEQUAL 128, regressions=0 conversions=0 changes=0 | EQUAL 3963 + STRICT_NOTEQUAL 124, regressions=0 **conversions=4** changes=0 |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 | identical, 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | identical, 0/0/0 (stamped_gen_param d/t CMP_NOTEQUAL as at the base) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | identical; downstream.csv byte-identical to results/downstream_uhdm2rtlil.csv |

Row by row:
- probe.csv differs from pristine's in the four conversions only.
- surelog.csv differs in the LowMemLib/LowMemPkg testflags detail text only (the workdir path in Surelog's log line).
- uhdm2rtlil.csv and downstream.csv do not differ at all.

Both sweeps exited 1 on the law-index check alone. In the sweep worktree, this verifier's own new
cases were not yet indexed. On a clean third worktree with only /tmp/r11u294.patch applied,
`scripts/law_index.py --check` reads `law index current`.

Other gate measurements:

- **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) over hard-linked corpus mirrors
  (drivers/mirror.sh; the path list is filtered by $FENCED before any file is linked; mirrored=2560,
  fenced_skipped=8 on each side): PATH_SETS_IDENTICAL, **MOVERS 0 / 2560**.
  - SELFCHECK reads 2559 / 2560. The self-check compares every database against one fixed database, and that database never differs from itself. This is the known artefact, not a mover (evidence/byteverify.txt).
- **Probe databases:** exactly 4 of 4087 move. They are the four conversions above.
- **Downstream slang-lane databases:** 0 of 805 move.
- **Canaries:** surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. `EXPECT_UNKNOWN=1 ctcan2.sh` reads PASS on surelog and `EXPECT_UNKNOWN=6 ctcan2.sh` reads PASS on uhdm2rtlil.
- **Binary-path audit** (drivers/audit.sh; the cmds.txt list is filtered by $FENCED first): the law sweep reads own=3265 other=0 noslang=50 fenced_skipped=8, and the pristine sweep reads the same.
- **Firing census** (drivers/tracecensus.sh, law binary, R11U294_TRACE, probe and both corpora in both modes with the $FENCED filter): evidence/predict.txt is **byte-identical to the implementer's**. It names the four converted probe databases, plus one abstention (r11u47repro/arms/g2, castModTypeParamDefaultTs294_ABSTAIN, no bytes). No corpus run opened a trace file. byteverify and the probe comparison confirm the prediction exactly.
- **Determinism** (drivers/det.sh: three concurrent harness draws of the law binary): one hash per row-mode, each equal to the law sweep's database.
  - Earlgrey_0_1 d 3f77d6f16c61, t 891990462621
  - MiniAmiq d/t 6274d155ae91
  - SeqDriver d 0140024e994f, t dcc2c63e2e29
  - SimpleUVM d 57a5aaad5589, t f0c85a0be92c
  - Scoreboard d e60363ba3f2d (no testflags database, as at the base)
  - BuildUVMPkg d/t 00b6402714d5
  - Rggen d 1a450c2e7808 (no testflags database, as at the base)
- **uhdm-cmp:** 0 lines on the four converted probe cases. No corpus row moved.

## The implementer's grid, reproduced (tools/probe/r11u294repro/cases with this verifier's binaries and its own golden cache)

All 1610 grid lines (230 case-views x pristine, law, law+R11U294_OFF and the four single
switches) match the implementer's evidence/grid.txt in every field except md5.

- 190 case-views move and 88 enter STRICT_EQUAL. None leaves.
- R11U294_OFF gives pristine's bytes on 230 of 230.
- 26 exit codes go 4 -> 0.
- Attribution:
  - PISEL 120, CASTMODTP 26 and DOTCALLSPAN 16, each back to pristine under its one switch.
  - The 28 PISEL+PISELFOLD movers each go back to pristine with both switches set (checked here, 28 of 28).

## Fresh attack cases (cases/, 68 dirs, 136 case-views; drivers/gridall.sh, every line with its exit code: evidence/grid.txt, grid_summary.txt)

Shapes attacked, by law:

- **PISEL (VS, 30 dirs).** Contexts:
  - header parameter defaults
  - ternary conditions, concatenations, size casts, unary and binary operators, replication counts and inside sets
  - an index of another select, a user-call argument, a function-local localparam and a generate-local localparam
  - package, class and interface localparams
  - unpacked struct parameters with unpacked array members
  - localparam indices, module-body and module-typedef struct localparams
  - pattern overrides at depth 1 and 3, an override expression
  - macros, an implicit net, a wildcard-imported package parameter and two-dimensional members

  Golden's `INT:-1` for a set bit read into an int is a Surelog defect. Most indices are therefore cleared bits, so that a stage-1 failure does not mask the law.
- **PISELFOLD (VF, 8 dirs).** A function-assembled default overridden by a pattern, and a pattern default overridden by the function-assembled value. Also covered: int and untyped targets, an interface, a module function, a nested member, two instances and a depth-2 pass-down.
- **DOTCALLSPAN (VD, 14 dirs).**
  - Coverpoint calls in if conditions, with arguments, in $display, in operations and user-call arguments, through this. and through a class handle from outside, and through a macro.
  - Cross get_inst_coverage in a module function.
  - Interface queue, enum and array-with built-in methods.
  - Hierarchical user calls nested in each other, a chained class-handle return and a task called without parentheses.
- **CASTMODTP (VM, 16 dirs).**
  - Defaults tried: struct, keyword, signed vector, byte, enum, string and a chained type parameter.
  - Contexts tried: an interface, a program, a module function, for-generate and if-generate processes, constant slots (header parameter, localparam, $bits, a part-select base), a nested module, nested casts and a ternary.
  - Overrides tried: logic -> struct, struct -> logic, and a depth-2 pass-down.

Results:

- 112 case-views move and 52 enter STRICT_EQUAL. **None leaves.**
- **R11U294_OFF gives pristine's bytes on 136 of 136.**
- 28 exit codes go 4 -> 0 (every CASTMODTP mover except VM/vm04, which stays 4). There is no other exit-code change.
- Attribution:
  - PISEL 46, CASTMODTP 30 and DOTCALLSPAN 18, each back to pristine under its one switch.
  - The 18 PISEL+PISELFOLD movers (VF and VS/vs18) each go back to pristine with both switches set.
- **Away census** (drivers/awaygrid.sh, chain-keyed; drivers/awaychain.py over drivers/strictcmp_x.cpp): away 0 (and flat away 0) on all 112 movers, 697 records toward golden (evidence/grid_away.txt).
  - Positive control, binaries swapped on every fourth mover: away 1 to 39 on 28 of 28 (evidence/away_poscontrol.txt).
- **uhdm-cmp line counts:**
  - Converted to 0: VM vm02, vm03 e, vm06, vm11, vm12, vm15, vm16 (56 to 96 -> 0).
  - Shrinking: VF/vf04 e 19 -> 15, VM/vm03 d 56 -> 31.
  - Growing on one case only, VM/vm13_nested d/e 22 -> 62, with the same first difference (residue 1).
- **Downstream** (drivers/dscases.py, evidence/downstream_cases.txt): 12 cases go EQUIVALENT -> IDENTICAL (VM vm01, vm02, vm03, vm05, vm06, vm08, vm10, vm11, vm12, vm14, vm15, vm16). The other 56 keep their verdict on both binaries, and none gets worse.

| case | law | shape | definition view (pristine -> law) | elaborated view | switch restoring pristine |
|---|---|---|---|---|---|
| VS/vs01_hdr_param | § paramInitMemberSelLvShape294 | a header parameter default reading the select | rc0 col -> rc0 file | rc0 col -> rc0 file | PISEL |
| VS/vs02_ternary | § paramInitMemberSelLvShape294 | the select as a ternary condition | rc0 col -> rc0 EQ 379 | rc0 col -> rc0 EQ 378 | PISEL |
| VS/vs03_concat | § paramInitMemberSelLvShape294 | two selects in a concatenation | rc0 stage1 cmp64 -> rc0 stage1 cmp64 | rc0 stage1 cmp64 -> rc0 stage1 cmp64 | PISEL |
| VS/vs04_cast | § paramInitMemberSelLvShape294 | the select inside a size cast | rc0 stage1 cmp106 -> rc0 stage1 cmp106 | rc0 stage1 cmp110 -> rc0 stage1 cmp110 | PISEL |
| VS/vs05_pkg | § paramInitMemberSelLvShape294 | a package localparam reading a select of a package struct parameter | rc0 stage1 cmp32 -> rc0 stage1 cmp32 | rc0 stage1 cmp32 -> rc0 stage1 cmp32 | PISEL |
| VS/vs06_class | § paramInitMemberSelLvShape294 | a class localparam reading a select of a class struct parameter | rc0 stage1 cmp17 -> unmoved | rc0 stage1 cmp17 -> unmoved | - |
| VS/vs07_iface | § paramInitMemberSelLvShape294 | an interface localparam reading the select | rc0 stage1 cmp31 -> rc0 stage1 cmp31 | rc0 stage1 cmp33 -> rc0 stage1 cmp33 | PISEL |
| VS/vs08_unpacked | § paramInitMemberSelLvShape294 | an unpacked struct parameter with an unpacked array member | rc0 stage1 cmp32 -> rc0 stage1 cmp32 | rc0 stage1 cmp32 -> rc0 stage1 cmp32 | PISEL |
| VS/vs09_paramidx | § paramInitMemberSelLvShape294 | the select index is a localparam | rc0 stage1 cmp50 -> rc0 stage1 cmp50 | rc0 stage1 cmp58 -> rc0 stage1 cmp58 | PISEL |
| VS/vs10_bodylocal | § paramInitMemberSelLvShape294 | a module-body struct localparam (not a header parameter) | rc0 col -> rc0 file | rc0 col -> rc0 file | PISEL |
| VS/vs11_patovr | § paramInitMemberSelLvShape294 | an instance overriding the struct with a pattern | rc0 stage1 cmp100 -> rc0 stage1 cmp100 | rc0 stage1 cmp100 -> rc0 stage1 cmp100 | PISEL |
| VS/vs12_macro | § paramInitMemberSelLvShape294 | the select from a macro | rc0 col -> rc0 file | rc0 col -> rc0 file | PISEL |
| VS/vs13_unary | § paramInitMemberSelLvShape294 | the select under unary and binary operators | rc0 stage1 cmp66 -> rc0 stage1 cmp66 | rc0 stage1 cmp74 -> rc0 stage1 cmp74 | PISEL |
| VS/vs14_replcount | § paramInitMemberSelLvShape294 | the select inside a replication count | rc0 col -> rc0 EQ 387 | rc0 col -> rc0 EQ 386 | PISEL |
| VS/vs15_inindex | § paramInitMemberSelLvShape294 | the select as another select index | rc0 col -> unmoved | rc0 col -> unmoved | - |
| VS/vs16_userfn | § paramInitMemberSelLvShape294 | the select as a module function argument | rc0 fullname -> unmoved | rc0 fullname -> unmoved | - |
| VS/vs17_body_param | § paramInitMemberSelLvShape294 | a body parameter (not localparam) reading the select | rc0 col -> rc0 file | rc0 col -> rc0 file | PISEL |
| VS/vs18_twoinst | § paramInitMemberSelLvShape294 | two instances, one overriding by the function-assembled value | rc0 stage1 cmp19 -> rc0 stage1 cmp19 | rc0 stage1 cmp19 -> rc0 stage1 cmp19 | PISEL+PISELFOLD |
| VS/vs19_inside | § paramInitMemberSelLvShape294 | the select in an inside set | rc0 stage1 cmp86 -> rc0 stage1 cmp86 | rc0 stage1 cmp86 -> rc0 stage1 cmp86 | PISEL |
| VS/vs20_typed_hdr_dim | § paramInitMemberSelLvShape294 | the select as a header parameter dimension and initializer | rc0 col -> rc0 EQ 378 | rc0 col -> rc0 EQ 377 | PISEL |
| VS/vs21_implicit | § paramInitMemberSelLvShape294 | beside an implicit net and an always_comb read | rc0 col -> rc0 file | rc0 col -> rc0 file | PISEL |
| VS/vs22_this_cls | § paramInitMemberSelLvShape294 | a class parameter select read through a specialization | rc0 stage1 cmp17 -> unmoved | rc0 stage1 cmp17 -> unmoved | - |
| VS/vs23_genlocal | § paramInitMemberSelLvShape294 | a generate-local localparam and an if-generate localparam reading the select | rc0 col -> unmoved | rc0 col -> unmoved | - |
| VS/vs24_funclocal | § paramInitMemberSelLvShape294 | a function-local localparam reading the select | rc0 stage1 cmp159 -> rc0 stage1 cmp159 | rc0 stage1 cmp159 -> rc0 stage1 cmp159 | PISEL |
| VS/vs25_ovr_expr | § paramInitMemberSelLvShape294 | the select as an instance override value | rc0 EQ 372 -> unmoved | rc0 EQ 371 -> unmoved | - |
| VS/vs26_wildimport | § paramInitMemberSelLvShape294 | a wildcard-imported package struct parameter read with a select | rc0 stage1 cmp11 -> rc0 stage1 cmp11 | rc0 stage1 cmp11 -> rc0 stage1 cmp11 | PISEL |
| VS/vs27_lp_struct_arr | § paramInitMemberSelLvShape294 | a localparam struct and a select on a two-dimensional member | rc0 stage1 cmp64 -> rc0 stage1 cmp64 | rc0 stage1 cmp64 -> rc0 stage1 cmp64 | PISEL |
| VS/vs28_two_selects | § paramInitMemberSelLvShape294 | two selects of one member in one initializer and a select beside a plain member read | rc0 col -> rc0 EQ 397 | rc0 col -> rc0 EQ 396 | PISEL |
| VS/vs29_param_typed_local | § paramInitMemberSelLvShape294 | a struct parameter typed by a module-local typedef | rc0 col -> rc0 file | rc0 col -> rc0 file | PISEL |
| VS/vs30_ovr_depth3 | § paramInitMemberSelLvShape294 | an override passed down three instance levels | rc0 stage1 cmp100 -> rc0 stage1 cmp100 | rc0 stage1 cmp100 -> rc0 stage1 cmp100 | PISEL |
| VF/vf01_fn_default_patovr | § paramInitMemberSelFoldBaseSpan294 | function-assembled default, one instance overriding with a pattern | rc0 stage1 cmp126 -> rc0 stage1 cmp126 | rc0 stage1 cmp126 -> rc0 stage1 cmp126 | PISEL+PISELFOLD |
| VF/vf02_pat_default_fnovr | § paramInitMemberSelFoldBaseSpan294 | pattern default, an instance overriding with the function-assembled value | rc0 col -> rc0 EQ 552 | rc0 col -> rc0 EQ 695 | PISEL+PISELFOLD |
| VF/vf03_fn_int_target | § paramInitMemberSelFoldBaseSpan294 | function-assembled default, int and untyped targets | rc0 col -> rc0 EQ 569 | rc0 col -> rc0 EQ 713 | PISEL+PISELFOLD |
| VF/vf04_fn_iface | § paramInitMemberSelFoldBaseSpan294 | function-assembled default in an interface | rc0 stage1 cmp19 -> rc0 stage1 cmp19 | rc0 stage1 cmp19 -> rc0 stage1 cmp15 | PISEL+PISELFOLD |
| VF/vf05_fn_localfn | § paramInitMemberSelFoldBaseSpan294 | a module-local struct parameter assembled by a module function | rc0 stage1 cmp28 -> rc0 stage1 cmp28 | rc0 stage1 cmp28 -> rc0 stage1 cmp28 | PISEL+PISELFOLD |
| VF/vf06_fn_nested | § paramInitMemberSelFoldBaseSpan294 | function-assembled base, nested member select | rc0 col -> rc0 EQ 559 | rc0 col -> rc0 EQ 702 | PISEL+PISELFOLD |
| VF/vf07_fn_twoinst_ovr_same | § paramInitMemberSelFoldBaseSpan294 | function-assembled default, an instance overriding with the same value | rc0 col -> rc0 EQ 659 | rc0 col -> rc0 EQ 802 | PISEL+PISELFOLD |
| VF/vf08_fn_depth2 | § paramInitMemberSelFoldBaseSpan294 | function-assembled default, instance depth 2 with pass-down | rc0 stage1 cmp48 -> rc0 stage1 cmp48 | rc0 stage1 cmp48 -> rc0 stage1 cmp48 | PISEL+PISELFOLD |
| VD/vd01_cp_if | § dottedCallHpSpansInvocation294 | a coverpoint call in an if condition | rc4 endcol -> rc4 EQ 34 | rc4 endcol -> rc4 EQ 65 | DOTCALLSPAN |
| VD/vd02_cp_args | § dottedCallHpSpansInvocation294 | a coverpoint call with arguments | rc4 endcol -> rc4 EQ 39 | rc4 endcol -> rc4 EQ 99 | DOTCALLSPAN |
| VD/vd03_cross_inst | § dottedCallHpSpansInvocation294 | a cross get_inst_coverage | rc4 endcol -> rc4 EQ 30 | rc4 endcol -> rc4 EQ 57 | DOTCALLSPAN |
| VD/vd04_cp_display | § dottedCallHpSpansInvocation294 | a coverpoint call as a system-call argument | rc4 endcol -> rc4 EQ 30 | rc4 endcol -> rc4 EQ 57 | DOTCALLSPAN |
| VD/vd05_cp_binop | § dottedCallHpSpansInvocation294 | a coverpoint call in an operation and a user-call argument | rc4 endcol -> rc4 EQ 45 | rc4 endcol -> rc4 EQ 87 | DOTCALLSPAN |
| VD/vd06_cp_noparen | § dottedCallHpSpansInvocation294 | a coverpoint call through this. and from outside the class through a handle | rc4 stage1 cmp60 -> rc4 stage1 cmp60 | rc4 stage1 cmp79 -> rc4 stage1 cmp79 | DOTCALLSPAN |
| VD/vd07_iface_queue | § dottedCallHpSpansInvocation294 | a built-in queue method through an interface instance | rc0 stage1 cmp164 -> unmoved | rc0 stage1 cmp164 -> unmoved | - |
| VD/vd08_inst_noparen_func | § dottedCallHpSpansInvocation294 | hierarchical user calls nested in each other and an argument call | rc0 stage1 cmp116 -> unmoved | rc0 stage1 cmp58 -> unmoved | - |
| VD/vd09_enum_method | § dottedCallHpSpansInvocation294 | a built-in enum method through an interface instance | rc0 EQ 64 -> unmoved | rc0 EQ 63 -> unmoved | - |
| VD/vd10_cp_option | § dottedCallHpSpansInvocation294 | a coverpoint call on a covergroup in a module and a sample call | rc0 endcol -> rc0 EQ 72 | rc0 endcol -> rc0 EQ 70 | DOTCALLSPAN |
| VD/vd11_arr_with | § dottedCallHpSpansInvocation294 | an array method with a with clause through an interface | rc0 EQ 77 -> unmoved | rc0 EQ 76 -> unmoved | - |
| VD/vd12_cp_macro | § dottedCallHpSpansInvocation294 | a coverpoint call spelled across a macro and with spaces before the parenthesis | rc4 stage1 cmp43 -> rc4 stage1 cmp43 | rc4 stage1 cmp43 -> rc4 stage1 cmp43 | DOTCALLSPAN |
| VD/vd13_hier_chain | § dottedCallHpSpansInvocation294 | a hierarchical call whose result is a class handle, chained, and a task call without parentheses | rc0 stage1 cmp52 -> unmoved | rc0 stage1 cmp68 -> unmoved | - |
| VD/vd14_cg_module_methods | § dottedCallHpSpansInvocation294 | covergroup instance methods in a module through a coverpoint and a cross, inside a function and as a comparison | rc0 endcol -> rc0 EQ 121 | rc0 endcol -> rc0 EQ 118 | DOTCALLSPAN |
| VM/vm01_struct_default | § castModTypeParamDefaultTs294 | default is a package struct typedef | rc4 type -> rc0 EQ 299 | rc4 type -> rc0 EQ 297 | CASTMODTP |
| VM/vm02_kw_defaults | § castModTypeParamDefaultTs294 | keyword and signed defaults | rc4 stage1 cmp62 -> rc0 EQ 133 | rc4 stage1 cmp62 -> rc0 EQ 130 | CASTMODTP |
| VM/vm03_iface | § castModTypeParamDefaultTs294 | a cast to an interface type parameter | rc4 stage1 cmp56 -> rc0 stage1 cmp31 | rc4 stage1 cmp56 -> rc0 fullname | CASTMODTP |
| VM/vm04_paraminit | § castModTypeParamDefaultTs294 | a cast in a localparam initializer and a header parameter (constant slots) | rc4 stage1 cmp84 -> rc4 stage1 cmp84 | rc4 stage1 cmp84 -> rc4 stage1 cmp84 | CASTMODTP |
| VM/vm05_chain | § castModTypeParamDefaultTs294 | a type parameter defaulting to another | rc4 type -> rc0 EQ 82 | rc4 type -> rc0 EQ 80 | CASTMODTP |
| VM/vm06_ovr_struct | § castModTypeParamDefaultTs294 | an instance overriding with a struct type, both instances | rc4 stage1 cmp60 -> rc0 EQ 390 | rc4 stage1 cmp60 -> rc0 EQ 389 | CASTMODTP |
| VM/vm07_genfor | § castModTypeParamDefaultTs294 | a cast in a for-generate process and an if-generate assign | rc0 EQ 163 -> unmoved | rc0 EQ 163 -> unmoved | - |
| VM/vm08_function | § castModTypeParamDefaultTs294 | a cast inside a module function and task | rc4 type -> rc0 EQ 119 | rc4 type -> rc0 EQ 117 | CASTMODTP |
| VM/vm09_program | § castModTypeParamDefaultTs294 | a cast in a program with a type parameter | rc4 type -> rc0 line | rc4 type -> rc0 line | CASTMODTP |
| VM/vm10_ovr_depth2 | § castModTypeParamDefaultTs294 | pass-down of a type parameter two levels | rc4 type -> rc0 EQ 193 | rc4 type -> rc0 EQ 191 | CASTMODTP |
| VM/vm11_shadow_value | § castModTypeParamDefaultTs294 | a value parameter and a type parameter cast side by side, and a cast in a select bound | rc4 stage1 cmp56 -> rc0 EQ 144 | rc4 stage1 cmp60 -> rc0 EQ 151 | CASTMODTP |
| VM/vm12_twocasts_ports | § castModTypeParamDefaultTs294 | a cast and a port sharing the type parameter | rc4 stage1 cmp60 -> rc0 EQ 80 | rc4 stage1 cmp60 -> rc0 EQ 79 | CASTMODTP |
| VM/vm13_nested | § castModTypeParamDefaultTs294 | a cast in a nested module to the outer module type parameter | rc4 stage1 cmp22 -> rc0 stage1 cmp62 | rc4 stage1 cmp22 -> rc0 stage1 cmp62 | CASTMODTP |
| VM/vm14_enum | § castModTypeParamDefaultTs294 | a type parameter defaulting to a package enum | rc4 type -> rc0 EQ 119 | rc4 type -> rc0 EQ 117 | CASTMODTP |
| VM/vm15_struct_default_ovr_logic | § castModTypeParamDefaultTs294 | a struct default overridden by a vector, and a string default | rc4 stage1 cmp96 -> rc0 EQ 343 | rc4 stage1 cmp96 -> rc0 EQ 347 | CASTMODTP |
| VM/vm16_two_params_one_cast | § castModTypeParamDefaultTs294 | two type parameters, casts nested and in a port default and a ternary | rc4 stage1 cmp60 -> rc0 EQ 193 | rc4 stage1 cmp60 -> rc0 EQ 190 | CASTMODTP |

(`EQ n` = STRICT_EQUAL with n objects; `stage1 cmpN` = uhdm-cmp fails with N lines; `col`, `file`, ... = the strict
column's first differing field; the `file` heads after PISEL are the elaborated `localparam logic B` typespec,
the implementer's residue 2.)

## Byte controls (drivers/controls.sh; evidence/controls_list.txt, controls.txt, controls_attrib.txt, controls_away.txt, controls_downstream.txt)

**Selection.**
- The dut.sv paths under tools/probe (not this pass's or the implementer's dirs) are listed first (24295 dirs) and filtered by $FENCED.
- Only then are the files opened, selecting every dir that contains any of:
  - a `parameter type`
  - a get_coverage / get_inst_coverage call
  - a parameter initializer reading a dotted path with a select
- That gives 1155 case dirs from 127 repro dirs: 2310 case-views on both binaries. Four case-views have no golden because Surelog fails on them (r11u108repro/grid/f5/f5a13_wire d/e, v11u275repro/cases/VP/vp10_nda d/e).

**Results.**
- 98 case-views move, in 18 repro dirs. 58 enter STRICT_EQUAL and **none leaves**.
- Exit codes: 62 go 4 -> 0 and 2 stay 4.
- No uhdm-cmp line count grows.
- Attribution: CASTMODTP 64, PISEL+PISELFOLD 32 and PISEL 2, each restoring pristine's bytes.
  - The 32 PISEL+PISELFOLD movers are the v11u272repro VM/VO and v11u274repro VG struct-function folds, r11u24repro/n8, r11u26repro/m5, r11u117repro/grid/g1/g19 and r11v21repro/v3.
  - The 64 CASTMODTP movers are the type-parameter cast grids of r11u113, r11u115, r11u121, r11u170verify, r11u202, r11u206, r11u213verify, r11u273, r11v184, v11u121, v11u196 and v11u206.
- **Away census:** chain away 0 on all 98, with 1087 records toward golden.
- **Downstream** on the 49 mover dirs:
  - 26 go EQUIVALENT -> IDENTICAL and 1 goes DIVERGENT -> IDENTICAL.
  - 22 keep their verdict: 16 IDENTICAL, 3 EQUIVALENT, 2 DIVERGENT and 1 STATUS_DIFF.
  - None gets worse.

## Findings (none is a pristine-right -> law-wrong break)

1. **The shared default typespec is re-parented at the elaborated cast (§ castModTypeParamDefaultTs294).**
   - What the law does: it sets `cts` to the `typeParamDefaultTs` object without setting `tpShared121`. The cast branch's later `cts->VpiParent(rt)` (when reemitting) therefore re-parents that SHARED default (ports and the type_parameter's ref read it) at the elaborated cast's ref_typespec.
   - What golden does (VM/vm12 both views): it keeps the default unparented (`#5 logic_typespec 3:33-3:44 parent=null`) and gives the elaborated cast its OWN copy parented at its ref (`#39 ... parent=ref_typespec #38`).
   - Pristine was wrong too: parent=type_parameter.
   - Typespec identity and a re-expanded subtree's parent are canonicalised by uhdm-strictcmp, so no strict record moves. The downstream verdicts improve.
   - Possible refinement: the elaborated cast copies the default, which is § castStructInstCopy260's model for struct casts.
   - Found with drivers/parents.cpp (it prints every object's vpiParent).
2. **ParamEmit carries one edit outside the four laws.** `std::string_view::npos` became `std::string::npos` in the X/Z constant branch (same value, byte-neutral; the sweeps show no mover). It is not behind a switch and is not named in the implementer's README.

## Residues, ranked (all wrong on pristine too; none written)

1. **VM/vm13_nested** (a cast in a NESTED module to the OUTER module's type parameter).
   - Golden writes Surelog's unresolved placeholder: an `unsupported_typespec` named `T` at the cast token, the § tpCast113 shape.
   - Pristine minted an integer_typespec there. The law binds the outer default logic_typespec instead.
   - Both are stage 1 at the same first record. uhdm-cmp goes 22 -> 62 lines only because the bound object prints its range; away 0, 4 records toward golden.
   - Exit code 4 -> 0.
   - Fix (ExprEmit, this ground): § castModTypeParamDefaultTs294 should abstain, or write the placeholder, when the type parameter's instance body is not the cast site's (`castSiteScope57`).
2. **The struct-parameter select shapes the PISEL laws leave at stage 1** (both binaries; the PISEL movers among them moved toward golden):
   - The whole-initializer folds Surelog makes on a concatenation, a cast, a package localparam and a two-dimensional member (vs03, vs04, vs05, vs27).
   - The elaborated cont_assign folds over pattern overrides (vs11, vs30, vf01, ModuleEmit).
   - An interface variable (vs07, vf04).
   - A function-local localparam (vs24, TaskFuncEmit).
   - A wildcard-imported base (vs26, a ref_typespec actual).
   - Class parameters (vs06 and vs22, where the law does not fire).
   - The generate-local localparam (vs23, unmoved: the implementer's residue 1, TypeEmit emitSyntaxExpr from ModuleEmit emitDefGenStmts).
3. **The elaborated `localparam logic B` typespec** (golden locates the keyword). This is the `file` head of VS vs01, vs10, vs12, vs17, vs21 and vs29 after PISEL, and the implementer's residue 2.
4. **The coverpoint call through a macro** (VD/vd12, the hier_path end through the macro, stage 1; implementer's dc11) and **`this.cg.cp.get_coverage()`** (VD/vd06, golden's `this` constant face).
5. **The CASTMODTP leftovers:**
   - $bits(T'(1)) in a localparam (VM/vm04, still exit 4, stage 1 at the sys_func_call).
   - An interface's elaborated variable (vm03 d, a logic_var head, stage 1).
   - A program's variable typespec location (vm09, line).
6. **The implementer's residues 1 to 6 and sister-ground faces** stand as stated in tools/probe/r11u294repro/README.md, re-read and not contradicted here.

## Process

- **Fence.** The fence was read fail-closed by every driver (drivers/env.sh reads the FENCED= line of tools/probe/r11u107repro/canaudit.sh).
  - Every path list was filtered by $FENCED before any file was opened.
  - No fenced name was spelled.
  - No binary, gdb or script ran on a fenced source.
- **Isolation.**
  - No other agent's process was listed or signalled.
  - The main tree was not written.
  - Every file was written under /tmp/wt_v11u294 or /tmp/v11u294_*.
- **Slips, no effect.**
  - The first fresh-grid draft put a function-assembled package and concatenation readers into every VS case. That made all of them stage 1 on both binaries through pre-existing faces (the UINT size of `c.u.a = 3` and the cont_assign concatenation fold).
  - The cases were rewritten (indices moved to cleared bits) and re-run in full. Every number above is from the final sources.
  - One dump command in a fresh shell ran with $UHDM_DUMP unset. It was guarded by `[ -x ]` and printed nothing.

Drivers:
- Copied from r11u294repro/drivers with paths repointed: case.sh, env.sh, views.sh, gridall.sh, gridsum.py, attrib.py, awaygrid.sh, awaychain.py, awayrows.py, away.py, chains.py, strictcmp_x.cpp, cc_x.sh, dscases.py, mirror.sh, audit.sh, det.sh and tracecensus.sh.
- New here: controls.sh and parents.cpp.
