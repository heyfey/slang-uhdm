# v11u292 — adversarial verification of r11u292 (expression/parameter ground: scoped lvalue and index names, invalid-operand and type-parameter casts, parameter-initializer call arguments, parenthesised delay spans)

Verifier of pass 292 (implementer r11u292, tools/probe/r11u292repro). Base 7f5277df (pass 288 on pass 293).
Two fresh worktrees at the base (pristine, and the base plus the implementer's patch), both built with the
system-deps cmake config at -j 2, binaries frozen (chmod 555) before any measurement:

| binary | md5 | what |
|---|---|---|
| pristine | 301aac6c43e62a91687cdc13bc938c30 | the base, equal to the main tree's build/slang-uhdm |
| law | 01fac149b090dec2bf75de1327e3d85b | base + the implementer's patch, equal to the implementer's frozen law binary |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | built in the pristine worktree |
| strictcmp_x (`drivers/cc_x.sh`) | 886f030233ecdbcce7d0e29ac0c4df2c | the away census's comparator, equal to the implementer's |

## Verdict

**VERIFIED WITH NO PRODUCTION FIX.** Every headline number of the implementer reproduces bit for bit, and no
fresh case, control or gate finds a break: no probe case or corpus row leaves EQUAL / CMP_EQUAL, no downstream
row leaves IDENTICAL, no strict cell moves away from golden (chain-keyed away census 0 on every mover of every
grid and control). The delivered patch is the implementer's production code unchanged, plus this directory and
the regenerated tests/LAWS.md.

FIVE PROBE CONVERSIONS reproduced (fresh rows of this verifier's law sweep, results/ untouched):

    r10uvm48repro/t67d,EQUAL,,equal            (base differ:fullname(1))  § pkgVarLvalueScopeSep292
    r10uvm48repro/t67e,EQUAL,,equal            (base differ:fullname(1))  § clsScopedChainIdxDirect292
    r10uvm59repro/c05_cast,EQUAL,,equal        (base differ:file(2))      § castInvalidOperandSyntax292 + § castTypeParamDefaultLoc292
    r10v100repro/v100_b3_trivia,EQUAL,,equal   (base differ:line(8))      § delayParenInnerExprSpan292
    v11u117repro/grid/b02,EQUAL,,equal         (base differ:fullname(1))  § paramInitCallArgLeafScoped292

## Gates (tests/sweep.sh --jobs 3; workdirs /tmp/v11u292_swP from the pristine worktree, /tmp/v11u292_swL from the law worktree)

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3947 + STRICT_NOTEQUAL 140, regressions=0 conversions=0 changes=0 | EQUAL 3952 + STRICT_NOTEQUAL 135, regressions=0 **conversions=5** changes=0 |
| surelog | default 480 + 0, testflags 474 + 0 (954 + 0), 0/0/0 | identical, 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | identical, 0/0/0 (stamped_gen_param d/t CMP_NOTEQUAL as at the base) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | identical; downstream.csv byte-identical to pristine's and to results/downstream_uhdm2rtlil.csv |

Row by row (`evidence/sweep_P.log`, `sweep_L.log`): probe.csv differs only in the five conversions; surelog.csv
only in the LowMemLib / LowMemPkg testflags detail text (the workdir path in the SURELOG_FAIL log line);
uhdm2rtlil.csv and downstream.csv not at all. Both sweeps exited 1 on the law-index check alone (`law index
STALE`): the pristine worktree's at the base itself, the law worktree's from the new § names; the delivered
patch carries tests/LAWS.md regenerated with this directory in the tree and `scripts/law_index.py --check`
reads it current.

- **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, fence-filtered hard-link mirrors
  /tmp/v11u292_mL vs /tmp/v11u292_mP of equal name length, `drivers/mirror.sh`: 2560 mirrored, 8 fenced paths
  skipped by name): PATH_SETS_IDENTICAL, **MOVERS 0 / 2560** (`evidence/byteverify_corpus.txt`). SELFCHECK reads
  2559 / 2560: the self-check compares every patched file with ONE fixed pristine file (the first path), and the
  patched copy of that same path is byte-identical to it because nothing moved, so it is the one file not
  flagged — pass 201's artefact, not a mover.
- **Probe databases**: the probe databases embed the source path of the worktree that ran them, so the pristine
  binary's probe stage was re-run from the law worktree (/tmp/v11u292_swQ, its probe.csv identical to the
  pristine sweep's); against the law sweep **5 of 4087 move**, exactly the five conversions
  (`evidence/byteverify_probe.txt`).
- **Downstream slang-lane databases**: 0 of 805 move (`evidence/byteverify_ds.txt`).
- **Firing census** (`drivers/tracecensus.sh`, the law binary under R11U292_TRACE over the probe and both corpora
  in both modes, the filter built from $FENCED): `evidence/predict.txt` is byte-identical to the implementer's
  frozen prediction — exactly the five probe databases (t67d PVLVSEP:1, t67e CHAINIDX:1, c05_cast CASTINV:1
  CASTTPDEF:1, v100_b3_trivia DLYPAREN:4, b02 PICALLLEAF:1), no corpus row-mode, no abstention line anywhere; the
  five firings are the census's own positive control, and the byte comparisons above confirm it in both
  directions.
- **Canaries** (`evidence/canaries.txt`): surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, both ctcan2 PASS.
- **Binary-path audit** (`drivers/audit.sh`, `evidence/binary_audit.txt`): pristine and law sweeps 3265 of 3315
  cmds.txt naming the sweep's own binary, 0 naming another, 50 running no slang, 8 fenced paths skipped by name.
- **Determinism** (`drivers/det.sh`, three concurrent draws of the law binary, `evidence/determinism.txt`): one
  hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg and Rggen d, each
  equal to the law sweep's and the pristine sweep's database.
- **uhdm-cmp** at 0 lines on the five converted probe cases (EQUAL) and every corpus row's status unchanged.

## The implementer's grid, reproduced

`drivers/gridall.sh` over tools/probe/r11u292repro/cases (62 case dirs, 124 case-views, labels pristine, law,
law+R11U292_OFF and law+each switch): **96 moving, 77 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes,
10 uhdm-cmp line-count changes, law+R11U292_OFF byte-identical to pristine on 124 of 124** — every field of every
line equal to the implementer's evidence/grid.txt but the md5 column; the per-mover attribution
(`drivers/attrib.py`) byte-identical to the implementer's grid_attrib.txt (CASTINV 24, CHAINIDX 16, DLYPAREN 16,
PVLVSEP 14, PICALLLEAF 14, CASTTPDEF 8, CHAINIDX+PVLVSEP 2 (CI/ci04), CASTTPDEF+CASTTPKIND 2 (CT/ct16)).

## Byte controls

- The implementer's 27 earlier repro dirs (`drivers/controls.sh`: r11u118, r11v11u118, r11u119, r11u120,
  r11v120, r11u121, r11u124, r11v124, r11u131, r11v131, r11u181, r11u201, r10uvm48, r11u280, v11u280, r11u282,
  v11u282, r11u284, v11u284, r11u286, v11u286, r11u288, v11u288, r11u290, v11u290, r11u293, v11u293): 2748 case
  dirs, **5496 case-views, 0 moving**, 0 exit-code or uhdm-cmp changes (`evidence/controls_impl_summary.txt`).
- WIDENED (`drivers/ctlsel.sh`): every dut.sv case dir under the other 436 tools/probe dirs (21162 case dirs,
  the path list filtered by $FENCED first) whose source spells one of the laws' triggers — a statement or
  intra-assignment `#(`, a cast `X'(`/`'(p::f(`, an assignment to `p::v`, a `::` chain inside `[ ]`, a
  `pkg::P.member` inside a call — 812 case dirs (`evidence/controls_selected_cases.txt`), **1624 case-views:
  6 moving, 4 entering STRICT_EQUAL, 0 leaving, 0 exit-code or uhdm-cmp changes**
  (`evidence/controls_selected_summary.txt`):

  | case-view | pristine -> law | switch | away census |
  |---|---|---|---|
  | r11u173verify/cases/pc/c03_member_arg_user_fn d, e | fullname -> STRICT_EQUAL 153 / 152 objects | PICALLLEAF | away 0, toward 1 |
  | v11u246repro/cases/MC/v04_paramcls d, e | line -> STRICT_EQUAL 89 / 127 objects | CASTTPDEF | away 0, toward 2 |
  | r11u167repro/cases/pc/c03 d, e | stage 1 -> stage 1 | PICALLLEAF | away 0, toward 1 |

  Each mover back to pristine's bytes under exactly its one switch; positive control (binaries swapped) away 1
  to 2 on 6 of 6 (`evidence/controls_away.txt`).

## Fresh cases (cases/; every case names its law on its first line)

35 case dirs, **70 case-views** in both views, every line with its exit code (`evidence/grid.txt`, labels as
above): **66 moving, 22 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, law+R11U292_OFF byte-identical to
pristine on 70 of 70.** Attribution (`evidence/grid_attrib.txt`): PVLVSEP 14, DLYPAREN 14, CHAINIDX 12,
PICALLLEAF 10, CASTINV 6, CASTTPDEF 2, and CASTTPDEF+CASTTPKIND 8 (vc03 e, vc04, vc06, vc07: the kind and the
location of one typespec, the pair ct16 already showed). **Away census (chain-keyed, `drivers/awaygrid.sh`,
`evidence/grid_away.txt`): away 0 on all 66 movers, 385 records toward golden**; positive control (binaries
swapped) away 1 to 26 on 15 of 15 sampled movers (`evidence/away_poscontrol.txt`). One flat (depth-dropped)
away record on VP/vp06 d and e is a coincidental pairing: golden's only bare `a` sits in the range golden builds
for `logic [W-1:0] z` by substituting W's initializer (a copy we do not mint, stage 1 on both binaries), which the
flat count paired with pristine's bare leaf at the localparam; chain-keyed it is 0. Three uhdm-cmp line counts
grow (VP/vp03 d 96 -> 98, vp05 d and e 64 -> 66) with the SAME first difference: the renamed leaf ref_obj is
printed in the head's context with its new full name. Downstream (`drivers/dscases.py`,
`evidence/downstream_cases.txt`): 35 cases, 26 IDENTICAL and 9 EQUIVALENT on both binaries, no verdict change.

Cases by law, with what each attacks (entering STRICT_EQUAL marked *):
- § pkgVarLvalueScopeSep292 — VQ/vq01_compound (+=, ++, --, select and part-select targets, a concatenation
  target), vq02_nested_cls* (a nested class's task, a constructor, a static function of a derived class),
  vq03_extern_mod (a module class with an extern body, a module function, always_comb, a named block),
  vq04_gen_iface (an interface function and class, a for-generate function and initial), vq05_program_fork* (a
  program class's fork, foreach over a package array, a nonblocking target), vq06_stream_out (a streaming target,
  an output argument), vq07_pkgtask_cls_mod* (a package task, a parameterized class, a virtual class with a pure
  prototype, a class inside a generate block).
- § clsScopedChainIdxDirect292 — VI/vi01_mod_proc (module always_comb on a class chain and a package struct
  variable, as read, target and under +), vi02_cls_kinds* (an element select inside the chain, a method call, a
  2-D select on either index, a target, -: base, unary minus, parentheses), vi03_gen_task (a for-generate
  process, a task output, a module function, a module-body always_comb target), vi04_iface* (an interface
  function and always_comb), vi05_lv_ips* (+: and -: targets, nested a[a[...]], ++ on the select), vi06_spec_this*
  (a class specialization b#(4)::stat in the index, b#()::, this. and handle paths, a cast around the chain).
- § castInvalidOperandSyntax292 — VC/vc01_inv_kinds (unsigned', a typedef, an enum, string', a sized cast of an
  operation, double parentheses, a member of the call, a call around it, two casts in one operation, $signed),
  vc02_inv_ctx (an if condition, a push_back argument, a parameter-width cast, a return), vc08_inv_more
  (T::K, T::get without parentheses, two arguments, byte', signed', const' (golden UH0705), a derived class).
- § castTypeParamDefaultLoc292 / § castTypeParamDefaultKind292 — VC/vc03_tp_more (int unsigned, byte unsigned,
  bit, a typedef, integer unsigned defaults, casts as operands), vc04_tp_spec_mod* (the class specialized in a
  module with longint and byte, the default specialization), vc05_tp_modclass (a module class, exit 4 on every
  binary), vc06_tp_nested_cls (a base and a derived class each with its own T, logic [7:0], bit [3:0] and real
  defaults), vc07_tp_alias_body (a typedef of T, a body `parameter type`, a cast in an array element, a static
  function return), vc09_tp_constslots (the CONSTANT SLOTS: a class parameter default N = T'(3), a dimension
  bound logic [T'(5):0], an unpacked size, a replication count, +: base and part-select bounds, a localparam).
- § paramInitCallArgLeafScoped292 — VP/vp01_genlp (generate-block localparams; no firing, pristine's bytes),
  vp02_header (a header parameter default calling a package function, an override f(q2::IMPL.s.a) on the
  instance), vp03_iface (an interface localparam, $bits(f(...)) in a parameter), vp04_shapes (a named argument
  with a default, a ternary, a concatenation, two calls under +, $clog2(f(..)+1), a path outside the call, an
  always_comb call), vp05_sysinuser (f($bits(..)), f(4'($unsigned(..))), a struct-valued member, a sized cast, a
  parameter), vp06_constslots (a replication count, +: base, part-select bound, a dimension bound).
- § delayParenInnerExprSpan292 — VD/vd01_shapes* (double parentheses, min:typ:max with and without spaces, a
  time literal, an empty statement, repeat, after an event control, fork, blocking and nonblocking intra
  delays, line breaks, a trailing comment), vd02_macro* (the value in a macro argument with spaces, a macro
  with spaces inside its parentheses, a whole-delay macro, a macro value inside the parentheses),
  vd03_class_prog (a package class task with a comment after `#`, a program with ##( 2 ), exit 4 on every
  binary), vd04_include* (an included macro, comments inside the macro argument, `# /* gap */ ( P )`, always,
  a task), vd05_always_clk (always #(HALF), begin-end, an event and a wait after the delay, forever, an
  interface initial, and the continuous-assignment and gate delays the law does not touch), vd06_tasks_mixed
  (automatic task arguments, a time parameter, a function call, a ternary, a concatenation as the value),
  vd07_clocking (clocking skews and a clocking-block drive).

## Residues (all wrong on pristine too; the laws leave them or move them toward golden)

1. **§ castTypeParamDefaultLoc292's unreached default kinds** — a cast to a class type parameter whose default
   is a vector or non-integer keyword (VC/vc06 `type T = logic [7:0]`: golden places the cast's logic_typespec
   at the default 10:22-33 with the default's range, ours at the written T 12:28-29 with none; STRICT_NOTEQUAL
   line on both binaries; ct05 shows the same for typedef and vector defaults). The law's model (golden reuses
   the default's typespec) extends to them; the copy must carry the range.
2. **Module and interface class type parameters** (VC/vc05 and the implementer's ct06/ct17: exit 4 on every
   binary) and the casts left at stage 1 (vc01 `$unsigned(T::get())` sys_func_call head, vc07 and vc09 with T
   inside class parameter defaults and dimensions, vc08).
3. **Package-variable targets the separator law does not reach** — a concatenation target `{p::q} = 5`
   (VQ/vq01 head ref_obj r::f::p), module-scope chains (vq03, vq04, stage 1 on both binaries).
4. **`::` chain indices in module scope** (VI/vi01 head `work@top.b::sv` under a bit_select, vi03; stage 1 on
   both binaries, moved toward golden).
5. **Parameter-initializer paths** (VP/vp02 to vp06 stage 1 on both binaries, each moved toward golden; vp01's
   generate-local localparams where the law does not fire).
6. **Delays outside emitDelayControl** — the continuous-assignment delay `assign #( 2 )` and gate delays
   (VD/vd05 head at the cont_assign delay constant; the implementer's xa09), clocking skews (vd07) and ##( 2 )
   (vd03, exit 4 on every binary).
7. The implementer's residues stand as written (t12's unparented return path withdrawn, the cast leftovers, the
   remaining 135 probe residues).

## Process

- The fence: every driver sources `drivers/env.sh`, which reads $FENCED fail-closed from the FENCED= line of
  tools/probe/r11u107repro/canaudit.sh; every path list (controls, mirrors, audit, probe byte comparison) was
  built and filtered by it before any file was opened; the census and determinism runs dispatch through the
  harness with a filter built from $FENCED; no fenced source or database was read, run or debugged; no name is
  spelled in this directory.
- THE VERIFIER'S SLIP, no effect: one wait loop for the firing census used `pgrep -f` with a pattern that matched
  its own shell's command line; it ended on its other condition (predict.txt written) and listed or signalled
  nothing. No other agent's process was touched and the main tree was not written.
- Four of the first fresh cases were illegal SystemVerilog (slang rc 3: an automatic variable in a nonblocking
  intra delay, a class-member part-select bound, a non-constant package variable in a module-body assign
  target, a task called from a function) and one Surelog could not parse (`T::get()[3]`): each was corrected and
  re-measured from fresh goldens (the golden cache keys on the case's content, /tmp/v11u292_gold).
- The probe databases embed the source path of the worktree that ran them, so a byte comparison of two sweeps
  run from different worktrees reads every probe database as moving; the pristine probe stage was re-run from
  the law worktree for that comparison (the corpus and downstream databases do not embed it).
