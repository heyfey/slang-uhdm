# r11u292 — expression/parameter ground: scoped lvalue and index names, invalid-operand and type-parameter casts, parameter-initializer call arguments, parenthesised delay spans

Pass 292, implementer, ground A (src/ExprEmit.cpp, src/StmtEmit.cpp; switches in the
new src/R292.h). Base 7f5277df (pass 288 on pass 293). Every number below is from
the frozen binaries:

| binary | md5 | what |
|---|---|---|
| pristine | 301aac6c43e62a91687cdc13bc938c30 | the base, byte-identical to the main tree's build/slang-uhdm |
| law | 01fac149b090dec2bf75de1327e3d85b | the delivered patch (slang 12.0.0+545f88b2e, UHDM 1.87) |
| law_draft | b8391d7dc3e73f93f10757a9556ea2cd | the first freeze, before the delay law's laid-out comparison (§ 7 below); used only for the draft census `evidence/predict_draft.txt` and the positive control of cases/DL/dl06 |

## Verdict

**FIVE PROBE CONVERSIONS, no probe change, no corpus row moves (0 of 2560 corpus,
0 of 805 downstream databases move in bytes).** Fresh rows of the law sweep
(`evidence/sweep_L.log`, results/golden_probe.csv untouched):

    r10uvm48repro/t67d,EQUAL,,equal            (base differ:fullname(1))  § pkgVarLvalueScopeSep292
    r10uvm48repro/t67e,EQUAL,,equal            (base differ:fullname(1))  § clsScopedChainIdxDirect292
    r10uvm59repro/c05_cast,EQUAL,,equal        (base differ:file(2))      § castInvalidOperandSyntax292 + § castTypeParamDefaultLoc292
    r10v100repro/v100_b3_trivia,EQUAL,,equal   (base differ:line(8))      § delayParenInnerExprSpan292
    v11u117repro/grid/b02,EQUAL,,equal         (base differ:fullname(1))  § paramInitCallArgLeafScoped292

Gate sweeps (`tests/sweep.sh --jobs 3`, workdirs /tmp/r11u292_swP and /tmp/r11u292_swL):

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3947 + STRICT_NOTEQUAL 140, regressions=0 conversions=0 changes=0 | EQUAL 3952 + STRICT_NOTEQUAL 135, regressions=0 **conversions=5** changes=0 |
| surelog | default 480 + 0, testflags 474 + 0 (954 + 0), 0/0/0 | identical, 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | identical, 0/0/0 (stamped_gen_param d/t CMP_NOTEQUAL as at the base) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | identical; downstream.csv byte-identical to pristine's |

Both sweeps exited 1 on the law-index check alone (`law index STALE`, the new §
names in src); the patch carries the regenerated tests/LAWS.md. Row by row the
law's surelog.csv differs from pristine's only in the LowMemLib/LowMemPkg testflags
detail text (the workdir path), uhdm2rtlil.csv in nothing, probe.csv in the five
conversions.

## The laws (each under its own switch; R11U292_OFF drops all; R11U292_TRACE=<dir> logs every firing and abstention)

1. **§ pkgVarLvalueScopeSep292** — ExprEmit, the `isPkgQualifiedVarRef` branch.
   `R11U292_PVLVSEP_OFF`. As an assignment TARGET the `<pkg>::@@BAD_SYMBOL@@`
   placeholder of a package variable joins its scope with `::` when the scope is a
   package or class subroutine (joinRef's rule, the same join § staticScopedRef12
   uses for the class branch): golden `p67::rdr67::h2::q67::@@BAD_SYMBOL@@` (t67d H2),
   `p::h::q::@@BAD_SYMBOL@@` in a package function, `work@top::c::h::q::@@BAD_SYMBOL@@`
   in a module's class, `p::c::h::...` in an extern method body; ours joined with `.`.
   A module or interface subroutine or process keeps `.` (both producers, PQ
   pq03/pq04/pq08 unchanged). Reads are not touched.
2. **§ clsScopedChainIdxDirect292** — ExprEmit, the ElementSelect index prefix
   and the indexed part-select base/width prefix (`boundPfx`). `R11U292_CHAINIDX_OFF`.
   A `::`-rooted chain written as the WHOLE index (`arr[b::stat.hval]`) collapses to
   its base reference (§ staticScopedChainDrops48), and Surelog names that reference
   like a DIRECT index reference: the scope prefix, never the select base (golden
   `p67::rdr67::i4::base67::stat` t67e I4, `p::r::f5::b::stat` on a read,
   `work@top.f3.p::stat` in a module function, `p::r::f3::m::b::stat` one level down
   in `m[m[b::stat.hval]]`, `p::r::f5::b::stat` for `v[b::stat.hval +: 2]`); ours
   added the base. Under an operation (`arr[b::stat.hval + 1]`) the base stays
   (golden `p::r::f4::arr::b::stat`, unchanged); a multi-index var_select is not
   this site (unchanged, equal on both).
3. **§ castInvalidOperandSyntax292** — ExprEmit, the Conversion branch.
   `R11U292_CASTINV_OFF`. slang wraps an UNRESOLVABLE operand (`int'(T::get())` in a
   generic class, the InvalidExpression § invalidScopedCallRef59 decodes) in an
   explicit Conversion with NO syntax, so the target typespec was minted unlocated;
   Surelog compiles the cast from its written syntax (golden c05_cast int_typespec
   6:15-18). The cast syntax is recovered by climbing from the Invalid operand's own
   syntax through scoped-name, invocation, argument-list and parenthesis nodes to the
   CastExpression (abstention traced `CASTINV_ABSTAIN no-cast-ancestor`). It also
   clears four stage-1 shapes: `32'(...)`, `shortint'(...)`, `n_t'(...)` (a package
   typedef) and `n_t'` in an assignment (CT ct03, ct08, ct11, ct14: uhdm-cmp 14-72
   lines -> 0).
4. **§ castTypeParamDefaultLoc292** — ExprEmit, the cast typespec fallback.
   `R11U292_CASTTPDEF_OFF`. A cast to a CLASS's type parameter (`T'(3)` with `class
   gen #(type T = int)`) locates its integer typespec at the parameter's DEFAULT type
   (golden c05_cast int_typespec 3:26-29, ours the written `T`); only a predefined
   integer keyword default (int, byte, shortint, longint, integer) reaches it, a
   module's type parameter (CT ct06, exit 4 on every binary) is not touched; a
   non-keyword default traces `CASTTPDEF_ABSTAIN`.
5. **§ castTypeParamDefaultKind292** — ExprEmit, same site. `R11U292_CASTTPKIND_OFF`.
   The cast to a class type parameter takes the KIND of the default keyword through
   § castTargetKeywordTypespec96's table (golden `short_int_typespec` for `type T =
   shortint`, ours `int_typespec` of the canonical type); CT ct16 needs 4 and 5
   together.
6. **§ paramInitCallArgLeafScoped292** — ExprEmit, the member-path leaf name.
   `R11U292_PICALLLEAF_OFF`. A parameter initializer's `pkg::P.member` path standing
   inside a USER call's argument list (directly, by name, or under an operator) is
   compiled as that call's argument, not through the parameter-initializer's
   member-read route, so its leaf takes the scoped full name (golden b02 `localparam X
   = f(q2::IMPL.cfg);` ref_obj cfg `work@top.cfg`, ours bare). A system call's
   argument (PI pi05) and a path written alone (pi02) keep the bare leaf; a package's
   own initializer (pi12, stage 1 on every binary) is not touched.
7. **§ delayParenInnerExprSpan292** — StmtEmit `emitDelayControl`.
   `R11U292_DLYPAREN_OFF`. A parenthesised delay value spans the
   `mintypmax_expression` node, the written expression alone (populateCoreMembers
   spans a node from its first to its last token): golden `#(\n P + 2\n )` 9:7-12,
   `#/*between*/(P + 3)` 11:18-23, `#( /*inner*/ P + 4 /*tail*/ )` 12:18-23, the
   intra-assignment `<= #/*between*/(P + 1)` delay_control 14:23-28; ours spanned the
   raw text between the parentheses (spaces, comments and line breaks included), and a
   comment after `#` sent the value to the bare-name branch. The value is read off slang's
   DelaySyntax. The law fires only when the laid-out line/column of the new span
   differs from the old one: the first freeze compared SourceRange values, and a
   macro-born `#(v)` (UVM's `uvm_delay`) carries its range in the expansion buffer on
   one side and the arithmetic offset on the other with the same layout, so the draft
   census predicted MiniAmiq, SeqDriver, SimpleUVM and Scoreboard (22 firings,
   `evidence/predict_draft.txt`) where no byte moves (cases/DL/dl06: law_draft fires
   twice, its database byte-identical to law's and pristine's).

## Grid (tools/probe/r11u292repro/cases, both views, every line with its exit code)

62 case dirs, 124 case-views (`evidence/grid.txt`, `grid_summary.txt`,
`grid_attrib.txt`): **96 moving, 77 entering STRICT_EQUAL, 0 leaving, 0 exit-code
changes**, law+R11U292_OFF byte-identical to pristine on 124 of 124. Each mover goes
back to pristine under exactly one switch (CASTINV 24, CHAINIDX 16, DLYPAREN 16,
PVLVSEP 14, PICALLLEAF 14, CASTTPDEF 8) except CI/ci04 (CHAINIDX + PVLVSEP, a
package-variable chain in a class index and a class lvalue, stage 1 on both
binaries) and CT/ct16 (CASTTPDEF + CASTTPKIND, both fields of one typespec).

| family | law | case-views | movers | entering STRICT_EQUAL |
|---|---|---|---|---|
| PQ | § pkgVarLvalueScopeSep292 | 18 | 12 | 8 |
| CI | § clsScopedChainIdxDirect292 | 14 | 14 | 12 |
| CT | § castInvalidOperandSyntax292, § castTypeParamDefaultLoc292, § castTypeParamDefaultKind292 | 38 | 32 | 28 |
| PI | § paramInitCallArgLeafScoped292 | 24 | 12 | 8 |
| DL | § delayParenInnerExprSpan292 | 12 | 10 | 10 |
| XA | the fresh adversarial shapes (extern method, `this.` path, interface body, class specialization in an index, interface and implicit-net delays, extern cast, named call argument) | 18 | 16 | 11 |

Every case names its law on its first line. Cases by law:
§ pkgVarLvalueScopeSep292 — PQ/pq01..pq09, XA/xa01_extern_pv;
§ clsScopedChainIdxDirect292 — CI/ci01..ci07, XA/xa02_this_chain (no firing, equal on both), xa03_iface_chain, xa04_spec_chain;
§ castInvalidOperandSyntax292 — CT/ct01..ct03, ct07..ct15, XA/xa06_extern_cast;
§ castTypeParamDefaultLoc292 — CT/ct04..ct06, ct17..ct19;
§ castTypeParamDefaultKind292 — CT/ct16_tp_kinds2;
§ paramInitCallArgLeafScoped292 — PI/pi01..pi12, XA/xa08_named_call_pi;
§ delayParenInnerExprSpan292 — DL/dl01..dl06, XA/xa05_iface_delay, xa07_implicit_dly, xa09_ca_delay.

uhdm-cmp line counts change on 10 case-views: 8 go to 0 (CT ct03, ct08, ct11, ct14
both views) and CT/ct02 grows 14 -> 62 in both views because its pristine head
(`32'(T::get())` at line 9, fixed) gave way to the next pre-existing face, the
`signed'(T::get())` sys_func_call at line 12 that CT/ct09 shows byte-identically on
both binaries (heads quoted in the grid run: pristine `integer_typespec ...
line:9:11`, law `sys_func_call: ($signed) ... line:12:11`).

**Away census** (chain-keyed, `drivers/awaygrid.sh`, `evidence/grid_away.txt`): 96
movers, chain away 0 on all 96, 269 records toward golden. Positive control
(binaries swapped, `evidence/away_poscontrol.txt`): away 1 to 12 on 96 of 96.

**Downstream** on every grid case (`evidence/downstream_cases.txt`): no verdict
changes (59 IDENTICAL, 1 EQUIVALENT pi07, 2 DIVERGENT ct06 and pi06 on both binaries).

## Byte controls

`drivers/controls.sh` over 27 earlier repro dirs (r11u118, r11v11u118, r11u119,
r11u120, r11v120, r11u121, r11u124, r11v124, r11u131, r11v131, r11u181, r11u201,
r10uvm48, r11u280, v11u280, r11u282, v11u282, r11u284, v11u284, r11u286, v11u286,
r11u288, v11u288, r11u290, v11u290, r11u293, v11u293): 2748 case dirs, **5496
case-views, 0 moving**, 0 exit-code or uhdm-cmp changes (`evidence/controls_summary.txt`).
Positive control: the same driver on this pass's own dir reads 96 moving, 77
entering (`evidence/controls_poscontrol.txt`).

## Census by name before the sweep, byteverify, canaries, audit, determinism

- Firing census (`drivers/tracecensus.sh`, fence-filtered, frozen before the law
  sweep, `evidence/predict.txt`): exactly five probe databases (t67d PVLVSEP, t67e
  CHAINIDX, c05_cast CASTINV + CASTTPDEF, v100_b3_trivia DLYPAREN x4, b02 PICALLLEAF),
  0 corpus row-modes, 0 uhdm2rtlil rows.
- byteverify (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, fence-filtered
  hard-link mirrors /tmp/r11u292_mL vs /tmp/r11u292_mP of equal name length): **0 of
  2560 corpus databases move** (PATH_SETS_IDENTICAL). SELFCHECK reads 2559 of 2560:
  the self-check compares every file against ONE fixed file, and that file compared
  with itself is the one not flagged (pass 201's artefact, not a mover).
- Probe databases: 5 of 4087 move, exactly the predicted five
  (`evidence/byteverify_probe.txt`). Downstream slang-lane databases: 0 of 805 move
  (`evidence/byteverify_ds.txt`).
- Canaries (`evidence/canaries.txt`): surelog ok=52 changed=0, uhdm2rtlil ok=16
  changed=0, both ctcan2 checks PASS.
- Binary-path audit (`drivers/audit.sh`, `evidence/binary_audit.txt`): pristine and
  law sweeps 3265 of 3315 cmds.txt naming the sweep's own binary, the other 50 running
  no slang, 0 naming another binary; the census 3265 likewise.
- Determinism (`drivers/det.sh`, three concurrent draws, `evidence/determinism.txt`):
  one hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
  BuildUVMPkg and Rggen, each equal to the law sweep's database.
- uhdm-cmp at 0 lines on every converted probe case (EQUAL), and every corpus row's
  status unchanged.

## Residues, ranked (all wrong on pristine too)

1. **The returned / assigned package-qualified member path in a module
   subroutine** (r11u117repro/grid/g1/t12 `return q2::IMPL.m;`, fullname(4)) — DECODED,
   NOT LANDED: golden leaves that hier_path UNPARENTED (no vpiParent, so no stored or
   computed full name on it or its leaf member; the elaborated view's clone is parented
   and named), in a whole assignment right side and a return value only (a case item, a
   call argument and a binary operand keep their names). A law unparenting the path
   (ExprEmit's pkg-qualified member-path branch, `pkgQualBase9`) converted eight RT grid
   case-views (return, assignment, select, two instances), but on t12 itself the strict
   walk then reaches a different `parameter q2::IMPL` struct copy (the package typedef
   listing's, member m bound straight to q2::row_t, where pristine and golden walk the
   parameter's own copy with the `row_t [0:1]` wrapper), t12 moving fullname(4) ->
   name(8); moving the unparenting design-final after ParamEmit's drain list did not
   change that, so some later pass re-binds the path's base by its parent chain. The
   law was withdrawn; the next attempt must find that re-binding first.
2. The cast leftovers on this ground: `signed'(T::get())` (CT ct09, the `$signed`
   sys_func_call face, stage 1), a cast to a module's type parameter (ct06, exit 4),
   a class type parameter defaulting to a typedef or a vector (ct05, stage 1), a
   module class overridden `gen #(byte)` (ct17, integer_typespec at T, exit 4).
3. A package-variable chain inside a class method (`arr[q::qh.hval]`, `y = q::qi`
   reads, `return q::qi`: CI ci04, PQ pq01, pq02 stage 1 on both binaries, the read
   form's binding).
4. The continuous-assignment delay `assign #( P ) w` (XA xa09, stage 1 on both
   binaries: the ref_obj P face) and the interface default view's xa05 stage-1 head.
5. Parameter-initializer member paths outside a user call: a path written alone
   (PI pi02), a module-local struct (pi03), $bits (pi05), two arguments (pi06), a
   header parameter (pi07), a generate-local localparam (pi10), an import (pi11), a
   package's own initializer (pi12): all stage 1 on both binaries.
6. The 135 probe residues listed with their first records in
   `evidence/residue_first_records_law.txt` (base: `residue_first_records_base.txt`);
   the ones read on this ground and left: c2_idxkind, v92_b2_varsel, b1_sites,
   b3_edges, v8_sites2 (golden's index text losing parts: `iarr[ + 1]`, a Surelog text
   defect), v4_ops (a qualified parameter folded in a ternary inside a part-select
   bound spanning its qualifier, declined by pass 286 as a quirk), g175_c_tail,
   g193_c_argface, the r11u109 64-bit cast values (a Surelog defect).
7. The brief's items (2) to (7) beyond the above not attempted.

Sister-ground faces read on this pass (reported, not written):

- r10vrgg14repro/cells/v5 name(14): a bit_select named `dn ` with the trailing space
  of `dn [3+2*i]` in a generate-block port connection, written by
  `emitDefGenStmts`'s statement lambda (ModuleEmit; gdb backtrace
  ModuleEmit emitDefGenStmts -> ref_obj::VpiName("dn ")).
- r10rgg4repro/c9_litarith_noovr endcol(1): the folded port-array dimension `3*2`
  (ModuleEmit's port arrays).
- r11u1repro/grid2, r11v1repro/vA col(2): the interface-port actual `u_df.mp`
  (ModuleEmit port connections).
- The cont_assign call fold `assign o = f()` where golden keeps the func_call
  (heading RT rt05, rt18, rt27 after the withdrawn law; ModuleEmit emitContAssigns).

## Process

- Worktree /tmp/wt_r11u292 at 7f5277df, scratch /tmp/r11u292_*; built with -j 2.
  The pristine binary was frozen before any edit; the main tree was not written.
- THE FENCE: every driver reads $FENCED fail-closed from
  tools/probe/r11u107repro/canaudit.sh (drivers/env.sh); the census filters its
  corpus runs by $FENCED; the byteverify ran on fence-filtered mirrors; the probe and
  downstream byte comparisons filtered their path lists by $FENCERE before any file
  was opened; the UVM library scan for the draft census's delay sites built its path
  list with find and filtered it by $FENCED before grep opened anything. No fenced
  source, copy or database was read, run or debugged; gdb ran only on probe and fresh
  case copies. No other agent's process was listed or signalled.
- Slips, no effect on results: the first freeze of the law (law_draft) over-predicted
  the UVM rows in the census (§ 7 above); it was refined, re-frozen and the census
  re-run before the law sweep. A withdrawn law (residue 1) was measured on the RT grid
  and the probe sweep and removed before the freeze; its RT cases are not part of this
  directory. The pristine and law sweeps exited 1 on the law-index check alone.
- Drivers copied from r11u288repro/drivers with their pass names updated, plus
  views.sh (both views of a case dir) and residue.py (the first records of every
  STRICT_NOTEQUAL probe case of a sweep).
