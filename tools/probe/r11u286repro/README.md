# r11u286 — pass 286, the expression/parameter ground (ExprEmit, StmtEmit)

Base 0d2443e1 (pass 284 on top of pass 287).  Five laws behind src/R286.h (`R11U286_<LAW>_OFF` each,
`R11U286_OFF` drops all of them, `R11U286_TRACE=<dir>` logs every firing, abstention and switched-off firing to
`<dir>/<pid>.286`, first line `OUT <-o path>`).  **SEVEN PROBE CONVERSIONS, no probe change, no corpus row moves in
status, 0 of 2560 corpus databases and 0 of 805 downstream databases move in bytes.**

Binaries (built in the worktree with the system-deps config, -j 2, frozen `chmod 555` before any measurement):
pristine `7a24e7c63d75dcabb2cf607f9f7e443c` (byte-identical to the main tree's build/slang-uhdm), law
`9bac5d074ea2624a0a6f99c03e95cb99`; both report slang 12.0.0+545f88b2e.

## The probe conversions (fresh law-sweep rows, results/ untouched)

| case | base | law | law |
|---|---|---|---|
| r10uvm151repro/g151_e_ctx | differ:endcol(2) | `r10uvm151repro/g151_e_ctx,EQUAL,,equal` | § withCallParenSyntax286 |
| r10v151repro/v151_5_ctx | differ:endcol(1) | `r10v151repro/v151_5_ctx,EQUAL,,equal` | § withCallParenSyntax286 |
| v11u116repro/arms/g2_fcall | differ:endcol(4) | `v11u116repro/arms/g2_fcall,EQUAL,,equal` | § genProcLvIdxCallSpan286 |
| v11u116repro/arms/f1t_intsig | differ:endcol(4) | `v11u116repro/arms/f1t_intsig,EQUAL,,equal` | § foldIntTsSignedKwTrim286 |
| r11v70repro/v5 | differ:fullname(3) | `r11v70repro/v5,EQUAL,,equal` | § elabCastKeyBindsDefNet286 |
| r11v70repro/v11 | differ:fullname(2) | `r11v70repro/v11,EQUAL,,equal` | § elabCastKeyBindsDefNet286 |
| r10earl31repro/e4_ctrl | differ:endcol(2) | `r10earl31repro/e4_ctrl,EQUAL,,equal` | § escBlockNameSpanTrailSpace286 |

Probe: base EQUAL 3898 + STRICT_NOTEQUAL 189 -> law EQUAL 3905 + STRICT_NOTEQUAL 182, regressions 0, changes 0.

## The laws

### § withCallParenSyntax286 — `R11U286_WITHPAREN_OFF` (ExprEmit, the array-method path builder)

slang's Expression::bind gives a PARENTHESIZED expression the ParenthesizedExpression node as its `syntax`
(`result->syntax = &syntax` after binding the inner expression), so for `r = 1 + (q.sum() with ( item ));` the call's
`expr.syntax` is the parentheses, not the ArrayOrRandomizeMethodExpression.  Two readers of that syntax missed:
§ withClauseCloseParenEnd183's span (the hier_path ends one past the with-clause's own `)`: golden g151_e_ctx
45:16-38, ours 45:16-37, the end falling back to one past the with expression) and the written iterator argument
(`(q.sum(x) with ( x + 1 ))`: the argument ref_obj was never emitted, uhdm-cmp reading 63 / 71 lines in the two
views of cases/WP/w02 and w05, now 0).  The law reads the call through any number of parentheses at both sites
(helper `withCallSyntax286`); an inner node that is not a with-call abstains (`WITHPAREN_ABSTAIN`, never fired).

### § genProcLvIdxCallSpan286 — `R11U286_GENLVCALL_OFF` (ExprEmit, the func_call span beside § procLvIdxCallWholeSpan181)

§ procLvIdxCallWholeSpan181 spans a call used as an lvalue select index over the whole call (`v[f][fn(P)] <= ...`)
only when `inProcessEmit || currentSubSym`; a GENERATE-SCOPE process sets neither (the elaborated gen_scope loop sets
`inGenScopeProc`, the definition view's gen process `defGenProcessEmit`), so the call kept the name span: golden
v11u116 g2_fcall 13:14-19 in both views, ours 13:14-16.  The law adds the two generate-process flags to the
condition, keeping § 181's own exclusions (a call indexing a read path, § lvIdxReadCallNameSpan181v; a part-select
bound, § procLvPartSelBoundCallName181v).  **Refinement inside the law** (found by grid case GL/g07, where the first
draft moved a STRICT_EQUAL case away): a call inside a member-path lvalue whose ROOT is selected (`m[fn(1)].v = ...`,
`ts[1].arr[fn(3)].v = ...`, `ts[fn(0)].w = ...`) keeps the name span, as golden has it (measured at module level
too, where pristine spans the whole call and is wrong: see residues); a plain root (`s.arr[fn(1)] = ...`) spans the
call.  Read from the lvalue's syntax (helper `rootSelLvPath286`: the left side's ScopedName / MemberAccess chain down
to an IdentifierSelectName), trace `GENLVCALL_ABSTAIN <name> rootsel-path`.

### § foldIntTsSignedKwTrim286 — `R11U286_INTSIGNTRIM_OFF` (ExprEmit, the loop-scope fold typespec)

The int_typespec minted for a for-generate fold of a typed parameter (`itsL9`, beside § sgnLitElabFreshIntTs266's
read site) took the whole type syntax, `int signed` 2:13-23, where Surelog's typespec of an integer atom never spans
the `signed` keyword: golden f1t_intsig 2:13-16 on every fold, the same span makeParamTs already gives the
parameter's own typespec through trimTypeSigning.  The law applies trimTypeSigning at that site; `int unsigned`,
`int` and untyped parameters are untouched (trimTypeSigning trims only a `signed` keyword on an integer atom; grid
IS/i05 control).  Located with a line-table build of the law source (gdb on the int_typespec allocations of the
witness; the sweep binaries carry no debug info).

### § elabCastKeyBindsDefNet286 — `R11U286_CASTKEYDEF_OFF` (ExprEmit, § castNamedPatternConcat70's key wires)

A cast pattern `p2_t'{a: 4'd1, b: 4'd2}` in a parameter initializer binds each key to an implicit wire
(UhdmWriter's lookup-miss mint, pass 70).  Golden's ELABORATED instance binds the DEFINITION's wire: r11v70 v5
(`sub5 u1, u2`) reads `logic_net work@sub5.a` under both instances, one object, where ours minted `work@v5.u1.a` and
`work@v5.u2.a` (two extra objects, the walk diverging at the second instance).  The law keys the definition
listing's minted wire by (definition prefix, key) and binds an elaborated instance's key to it when the instance's
own name differs from the definition's (the top instance, whose copy already reads the definition's name, keeps
its own object: no top-level case moves).  The definition listing is always written first; the order-independent
half (an elaborated instance minting under the definition's name, adopted later by the listing) never fired on any
grid case, probe case or corpus row (trace census: only `CASTKEYDEF ... shares`).

### § escBlockNameSpanTrailSpace286 — `R11U286_ESCBLKNAME_OFF` (StmtEmit, the named_begin anchor)

A named block anchors at its name token; for an ESCAPED name (`begin : \blk@1 `) Surelog's token is the whole
lexeme through its terminating space, two characters more than the name (golden e4_ctrl 35:23-34, ours 35:23-32;
the line's +4 column shift is fileLineCol's § escIdPpColumnShift146).  The law ends the span after the space when
the name is escaped, written in the file (not a macro) and space-terminated; otherwise it abstains
(`ESCBLKNAME_ABSTAIN`).  A tab- or newline-terminated escaped block name and a macro-written one fail Surelog's
parse (no golden), so the abstention is unmeasured; a named fork keeps § parBlockJoinTailAfterFirstItem131's span.

## The grid (evidence/gridall.txt, gridsum.txt, attrib.txt; every line carries rc)

46 case dirs in WP, GL, IS, CK, EB (each dut.sv names its law on its first line), both views = 92 case-views, labels
pristine, law, law+R11U286_OFF and law+each switch.  **70 moving, 57 entering STRICT_EQUAL, 0 leaving, 0 exit-code
changes**; uhdm-cmp line-count changes 4, all to 0 (WP/w02_iter_arg and w05_queue_methods, both views, 63 / 71 -> 0:
the parenthesized with-call's written iterator argument); **law+R11U286_OFF equal to pristine on 92 of 92**.
Every mover is back to pristine under exactly one switch: WITHPAREN 16, GENLVCALL 22, INTSIGNTRIM 12, CASTKEYDEF
12, ESCBLKNAME 8.  The 13 movers that do not enter STRICT_EQUAL: CK/k05 and k06, GL/g09, IS/i09, WP/w09 and w10 read
stage 1 on both binaries (an unrelated face: generate instance arrays, a module typedef cast, an interface body,
longint, a parameterized class, an interface function), and GL/g13_member_root e moves endcol -> fullname (the
three calls now right; the walk reaches the pre-existing `ts[1].arr` select-name face, wrong on pristine too).

| group | law | cases |
|---|---|---|
| WP | § withCallParenSyntax286 | w01_class_task, w02_iter_arg, w03_ternary, w04_module_proc, w05_queue_methods, w06_macro, w07_multiline, w08_randomize_ctl (control), w09_this_extern, w10_iface |
| GL | § genProcLvIdxCallSpan286 | g01_for_ff, g02_if_comb, g03_case_gen, g04_nested, g05_partsel_ctl (constant slots: part-select bounds, indexed part-select base and width), g06_ops_idx (operation index, compound, inc), g07_member_path (the break witness), g08_func_in_gen_ctl, g09_iface_gen, g10_pkg_fn, g11_inst_depth, g12_assoc, g13_member_root, g14_named_args |
| IS | § foldIntTsSignedKwTrim286 | i01_hex, i02_dec, i03_localparam, i04_select_idx (constant slots: select index, indexed part-select base), i05_unsigned_ctl, i06_override, i07_header_param (macro default), i08_if_gen, i09_shortint_ctl |
| CK | § elabCastKeyBindsDefNet286 | k01_two_inst, k02_depth3, k03_two_patterns, k04_top_and_child, k05_gen_inst, k06_module_typedef, k07_key_is_net, k08_interface, k09_param_dep |
| EB | § escBlockNameSpanTrailSpace286 | e01_kinds, e02_nested_end, e03_gen_fork, e04_class_method |

**Away census** (drivers/awaychain.py with strictcmp_x, chain-keyed, copied from r11u287repro): **chain away 0 on
all 70 movers**, 226 records toward golden (evidence/away_grid.txt); positive control (binaries swapped) chain away
1 to 4 on 6 of 6 (evidence/away_poscontrol.txt).

**Downstream on the cases** (drivers/dscases.py): the 35 case dirs whose default view moves read the same verdict
on both binaries (34 IDENTICAL, 1 EQUIVALENT: WP/w10_iface, no gates on either lane), and the 105 slang-lane RTLIL and netlist files are
byte-identical (evidence/ds_cases_P.txt, ds_cases_L.txt).

## Byte controls (drivers/controls.sh; path lists filtered by $FENCED first; evidence/controls*.txt)

27 earlier repro dirs with case dirs (r11u181, r11v181, r11u116, v11u116, r11u146, r11u118, r11v11u118, r11u119, r11u120, r11v120,
r11u124, r11v124, r11u131, r11v131, r11u284, v11u284, r11u282, v11u282, r11u280, v11u280, r11u262, v11u262,
r11u266, v11u266, r11u158, r11u75, r11u183dec; r10uvm183repro and r10v183repro, also listed, hold no dut.sv
dir), 3129 case
dirs, 6258 case-views: **4 moving, 2 entering STRICT_EQUAL** (r11u146repro/grid/ck/c2_sub d/e fullname ->
STRICT_EQUAL, CASTKEYDEF), **0 leaving, 0 exit-code and 0 uhdm-cmp line changes**; r11v181repro/cases/lc/c01 d/e
moves inside endcol (GENLVCALL: its generate-scope `b[f(g)] <= 1'b0`).  Chain away 0 on all 4, toward 2 / 2 / 3 / 3
(evidence/away_controls.txt).

## Gates (worktree sweeps, SLANG_UHDM exported, workdirs /tmp/r11u286_wP and /tmp/r11u286_wL)

- Build: pristine md5 7a24e7c6... equal to the main tree; law md5 9bac5d07...; both frozen before measurement.
  The delivered patch applied with `git apply` on a fresh 0d2443e1 worktree and built there from scratch gives the
  law md5 9bac5d07... again.
- Probe: regressions 0, conversions 7, changes 0 (above).  Surelog: default CMP_EQUAL 478 + STRICT_NOTEQUAL 2,
  testflags 472 + 2, regressions/conversions/changes 0; every row identical to the pristine sweep except the
  LowMemLib/LowMemPkg testflags SURELOG_FAIL detail text (the workdir path, environment).  uhdm2rtlil 803/1/67 both
  modes, 0/0/0, rows identical.  Downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, the csv
  identical to the pristine sweep's.  Both sweeps exit 1 on the law-index check alone (tests/LAWS.md is stale at
  the base too; the patch carries the regenerated file).
- uhdm-cmp: 0 lines on every touched probe case (all seven EQUAL).
- **Firing census frozen before the law sweep** (drivers/tracecensus.sh, harness filter built from $FENCED;
  evidence/predict.txt, md5 in predict.md5): 7 probe databases fire (the seven conversions), **no corpus database
  fires any law, abstention or switched-off branch**.
- **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered hard-link mirrors, SELFCHECK=1):
  PATH_SETS_IDENTICAL 2560, **MOVERS 0 / 2560**, SELFCHECK 2559 / 2560 — pass 201's self-check artefact: every
  file is compared against one fixed file (the first path's pristine database), and that path's own pair is
  byte-equal, so the comparator flags every path but one.  Probe: **7 of 4087 databases move, exactly the
  predicted 7**.  Downstream lane: 0 of 805 databases move (evidence/byteverify_*.txt).
- Corpus away census: no corpus database moves, nothing to census.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS (EXPECT_UNKNOWN=1 and 6).
- Binary audit: 3265 of 3315 cmds.txt name each sweep's own binary, the other 50 run no slang, 8 fenced paths
  skipped by the list filter, in both sweeps (evidence/binary_audit.txt).
- Determinism (drivers/det.sh, three concurrent draws per row-mode): Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard d, BuildUVMPkg, Rggen d one hash each, equal to the law sweep's (evidence/determinism.txt).

## The probe residue at the base (evidence/residue_first_records_base.txt, residue_chains_base.tsv, residue_buckets_base.txt)

189 STRICT_NOTEQUAL cases classified by `uhdm-strictcmp --max 3` on the pristine sweep's databases (drivers/classify.py,
chains.py).  The residue is a long tail: the largest bucket is 11 (struct-member full names under a typespec member,
TypeEmit, the sister's), then 5 / 5 / 5 / 4.  On this ground, worked and ranked:

1. **Converted here** (7): the five laws above.
2. **Module-level calls in a root-selected member-path lvalue** (`m[fn(1)].v = ...` in a module always,
   `ts[fn(0)].arr[fn(3)].v`): golden spans the name, pristine the whole call (§ procLvIdxCallWholeSpan181's gap);
   the trailing select of such a path (`m[fn(1)].v[fn(0)]`) is whole in golden, so the rule is not written.  No
   probe case carries it.
3. **Member-path select element spans in an elaborated parameter initializer** (r11u21 t9, r11u24 n1): every
   variant off the witness shape (`CFG.u.a[1]`, `CFG.d[3:1]`, `CFG.d[2+:2]`, a cont_assign read) reads stage 1 on
   pristine, so no grid can isolate the three faces; not attempted.
4. **The struct-fold leftovers** (r11u26 m4, m7, r11u28 a2): the walk diverges (660 vs 664 objects), golden keeps a
   leftover pattern operation on the package typedef member; not attempted.
5. **A parenthesized with-call written in a macro body** (cases/WP/w06): § withClauseCloseParenEnd183 requires the
   closing parenthesis in the call's own buffer; unchanged.
6. **r10earl31 v4_ops**: golden spans a package constant in a ternary CONDITION as `pk::` plus one character
   (24:17-21), a Surelog quirk not copied; **r11u117 g1/g13**: a hier_path in a dead if-generate localparam; the
   r11u109 64-bit cast value family (a Surelog defect, not copied).

## Sister-ground faces met (reported, not written)

- **r11v66repro/a3_inst66** (endcol(6)): the elaborated continuous assignment `assign y = Q.a;` with `Q = '{a: P * 2,
  ...}` folds to a constant located at the member's WHOLE setter (`P * 2`, 10:34-39) where golden locates it at the
  leading leaf (`P`, 10:34-35; `2 * P` -> `2`, `(P + 1)` -> `P`, `P * P + 1` -> `P * P`: § pkgFoldAtLeadingLeaf191's
  rule).  Writer: ModuleEmit emitCaStructParamSubst55, § caStructParamPatternSubst55 (`setLoc(c55,
  stripImplicitConv(setter)...)`), called from emitContAssigns (gdb on the line-table build).
- **r11u113 c/c09_genif_modtd_ctl, c11_genif_pkimp**: a cast to a typedef in an if-generate continuous assignment:
  golden lists a copy of the typedef whose reference reads `work@top.g.idx_t`, ours shares the module's typedef
  (`idx_t`); a typespec copy in the generate scope (ModuleEmit emitGenScopes).
- **r11v46repro/grid7**: a for-generate initialization `genvar ce = $unsigned(MM)` stores the bare `MM` on the
  argument ref_obj where golden reads `work@cell7.MM` (the signing-cast form `unsigned'(MM)` already gets the
  prefix); the gen_for init is written on the module ground (emitDefGenStmts), writer not located.
- The other first records of the residue sit on ModuleEmit / TypeEmit / UhdmExporter writers as the earlier passes
  classified them (struct-member full names, the `type|ref_obj|cont_assign` comma-list and call-fold bucket, the
  type-parameter typespec lines and names).

## Process

**Fence.** Every corpus path list was built first and filtered by `$FENCED` (word boundary, read fail-closed from
tools/probe/r11u107repro/canaudit.sh) before any file was opened: mirror.sh, audit.sh, the probe and downstream byte
comparisons, and the firing census through the harness filter.  No fenced source, database or cmds.txt was read,
run or decoded; gdb ran only on fresh cases.

**Slip.** Two inspection commands ran `$UHDM_DUMP <db>` in a shell where the variable was unset, so the shell tried
to execute a fresh-case database (/tmp/r11u286_t/pm/d.uhdm, a non-fenced grid case); no file was written in its
directory or anywhere else (checked), and every later dump went through drivers/dump.sh, which checks `[ -x ]` and
the fence first.  A first debug build at -O0 was killed by the OOM killer when run and was replaced by a -O2 -g1
line-table build in a separate scratch worktree.

**Processes.** No other agent's process was listed or signalled; waiters polled their own log files.  The main
tree was not written (at the end its status showed another pass's edits, src/ModuleEmit.cpp, src/R289.h and
tests/LAWS.md, untouched here).

**Files.** README; cases/ WP, GL, IS, CK, EB; drivers/ (env.sh, case.sh, classify.py, chains.py, gridall.sh,
gridsum.py, attrib.py, controls.sh, ctlsum.py, awaygrid.sh, tracecensus.sh, det.sh, mirror.sh, audit.sh,
dscases.py from r11u284repro; strictcmp_x.cpp, cc_x.sh, awaychain.py, awayrows.py, away.py, awaycorp.sh from
r11u287repro; dump.sh new); evidence/.
