# r11u296 — expression/parameter ground: the return fold's typespec per parameter, path-index names through a port and through a package-function clone, a cast's typespec in a path index, the randomize-with receiver's last select

Pass 296, implementer, ground A (src/ExprEmit.cpp, src/StmtEmit.cpp, src/ParamEmit.cpp; switches in
the new src/R296.h). Base 3049e6ab (pass 294 on pass 299). Every number below is from the frozen
binaries:

| binary | md5 | what |
|---|---|---|
| pristine | 6b20693eef699614784a0ae089571dc0 | the base, byte-identical to the main tree's build/slang-uhdm |
| law | f084a2ac85ffae8db05ce180440a60ed | the delivered patch (slang 12.0.0+545f88b2e, UHDM 1.87) |

## Verdict

**FIVE PROBE CONVERSIONS, no probe change, no corpus row moves (0 of 2560 corpus and
0 of 805 downstream databases move in bytes).** Fresh rows of the law sweep
(`evidence/sweep_L.log`; results/golden_probe.csv untouched):

    r10v169repro/v169_g_control,EQUAL,,equal         (base differ:line(10))     § retFoldTsKeyedByParam296
    r10uvm193repro/g193_c_argface,EQUAL,,equal       (base differ:fullname(4))  § pkgFnCloneIdxNamesByChain296
    r10earl29repro/v8_sites2,EQUAL,,equal            (base differ:fullname(1))  § hcTrailIdxNamesByPortChain296
    r10earl29repro/b3_edges,EQUAL,,equal             (base differ:fullname(2))  § castTsInPathIdxByChain296
    r10uvm175repro/g175_c_tail,EQUAL,,equal          (base differ:fullname(2))  § randWithLastSelChainShape296

Gate sweeps (`tests/sweep.sh --jobs 3`, workdirs /tmp/r11u296_wdP and /tmp/r11u296_wdL of equal
length):

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3966 + STRICT_NOTEQUAL 121, regressions=0 conversions=0 changes=0 | EQUAL 3971 + STRICT_NOTEQUAL 116, regressions=0 **conversions=5** changes=0 |
| surelog | default 480 + 0, testflags 474 + 0 (954 + 0), 0/0/0 | default 480 + 0, testflags 474 + 0 (954 + 0), 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | 803/1/67 both modes, 0/0/0 (stamped_gen_param d/t CMP_NOTEQUAL as at the base) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | 803 / 66 / 2 / 0, downstream.csv byte-identical to the committed one (and to pristine's) |

Both sweeps exited 1 on the law-index check alone (`law index STALE` at the base already);
the patch carries the regenerated tests/LAWS.md. Row by row the law's surelog.csv differs from pristine's only in the
LowMemLib/LowMemPkg testflags detail text (the workdir path), uhdm2rtlil.csv and downstream.csv in
nothing, probe.csv in the five conversions. The strict comparator of both sweeps is
uhdm-strictcmp fa6e4f42f252ae0ab69d9845003e71c5, the worktree's own build.

## The laws (each under its own switch; R11U296_OFF drops all five; R11U296_TRACE=<dir> logs every firing and switch-off)

1. **§ retFoldTsKeyedByParam296** — StmtEmit, the package-return fold window of
   § pkgRetParamSubstIsRhsClone120 (`case StatementKind::Return`). `R11U296_RETFOLDTS_OFF`.
   The definition-view package compile pre-creates the int_typespec clone the folded return
   binds (`foldCloneTs`), keyed by the SUBROUTINE and made for the parameter of the FIRST return
   statement it meets; a later folded return of ANOTHER parameter bound that clone, so its
   constant's ref_typespec read the other parameter's type and location. Surelog's
   `CompileHelper::compileExpression` primary-literal branch clones the MATCHED param_assign's Rhs
   (`UHDM::clone_tree(param_ass->Rhs())`, CompileExpression.cpp), whose ref_typespec is that
   parameter's own: golden r10v169repro/v169_g_control `if (s) return kg169; return lg169;`
   folds the last return to lg169's `int` at 6:13, ours read kg169's at 5:13 (f_after169 the
   mirror; ten records, every copy of both functions). The law binds a clone made for the
   fold's own parameter, one per (subroutine, parameter) and shared by the home and every
   importer copy exactly as the pre-created one is; a fold of the parameter the clone was made
   for is untouched. For a vector, byte or shortint parameter the wrong clone also carried the
   wrong kind or range, which uhdm-cmp reads (grid RF rf04 and rf05: 36 and 32 uhdm-cmp lines
   on pristine, 0 and STRICT_EQUAL on the law).
2. **§ pkgFnCloneIdxNamesByChain296** — ParamEmit, the wildcard-import clone loop of
   `emitPackage` (an importer package's clone of a FREE package subroutine), and ExprEmit
   `notePkgFnCloneHpIdx296`. `R11U296_PKGFNCLONEIDX_OFF`. Pass 220's § cloneHpIdxNamesByChain220
   drain (an importer clone of a CLASS METHOD stores no full name on a reference in a path
   element's select index, so the reader's ComputeFullName walks the clone's chain through the
   select and the path) is UHDM's clone_tree too for a free subroutine, but only the
   class-method clones were registered with it: golden r10uvm193repro/g193_c_argface, Jetty193's
   clone of Pier193::c7_two193 `fleet193[kink193].rub193(kink193)`, reads
   `Jetty193::c7_two193::fleet193[kink193].rub193::kink193`, ours the home-shaped
   `Jetty193::c7_two193::kink193`. The law registers the free-subroutine clone with the same
   drain, whose every gate (the clone's own body, the stored name being the scope's or the
   path's join, the select-index branch of § cloneHpIdxSelectByChain252) is unchanged; the drain
   traces each rename under such a root.
3. **§ hcTrailIdxNamesByPortChain296** — ExprEmit `portChainBase296`, the base every path-index
   naming rule joins to (§ hpTrailSelIdxNamesByPath133 with § trailIdxCallArgNamesByPath187,
   § hpTrailIpsNamesByPath218, § hpBaseSelOpIdxNamesByPath145, § ifaceMemberTrailIdxNamesByPath147,
   § hpMemVarSelIdxNamesByChain280). `R11U296_HCTRAILIDX_OFF`. A path that is a PORT's high
   connection hangs under the port, which hangs under the instance, and Surelog stores no name
   on the references inside it, so ComputeFullName runs through both: golden
   r10earl29repro/v8_sites2 `.a(q.autoexecprogbuf[{1'b1, k[0]}])` on the elaborated instance u
   reads `work@v8_sites2.u.a.q.autoexecprogbuf[{1'b1,}].autoexecprogbuf.k`. The elaborated
   instance's emission (ModuleEmit emitInstance -> emitExpr) hands these rules the PARENT's
   prefix, so ours read `work@v8_sites2.q...` (the select itself, named by the getter over the
   chain, already read `...u.a...`; the definition's ref_module port was right, its emission
   passing the port prefix). The base is the path's own chain (chainFullName175) whenever the
   path is parented at a port that is itself parented; elsewhere it is the old join.
4. **§ castTsInPathIdxByChain296** — ExprEmit `castTsInPathIdxDrain296`, design-final from
   ParamEmit's drain list right after § cloneHpIdxNamesByChain220, in UhdmId order.
   `R11U296_CASTIDXTS_OFF`. Surelog stores no full name on a ref_typespec (pass 284's census:
   every probe golden's ref_typespec name equals ComputeFullName over the final parent chain),
   so a cast written inside the index of a path element's select reads through the select and
   the path: golden r10earl29repro/b3_edges `q.autoexecprogbuf[{1'b1, 2'(k)}]` names the cast's
   ref_typespec `work@b3_edges.q.autoexecprogbuf[{1'b1,}].autoexecprogbuf`, ours stored the
   scope's `work@b3_edges`. Only a cast reached from the select's index through operations,
   under a bit_select whose parent is a hier_path, and only where the stored name is a prefix
   of the chain name.
5. **§ randWithLastSelChainShape296** — ExprEmit, the dotted-receiver builder of
   § memberRandomizeWithIsRecvPath119 (`dots`/`stepSel74` loop). `R11U296_RANDLASTSEL_OFF`.
   The member randomize-with receiver's LAST element written with one select
   (`holds[berth].randomize() with {...}`) is pushed by Surelog's trailing `paSelect` branch,
   the branch that sets NO full name (the rule § memberRandomizeWithIsRecvPath119 already quotes
   for a plain last name): the bit_select stores none and is located at its INDEX, and the
   index hangs under the select with no stored name, so the reader names both through the path
   (golden r10uvm175repro/g175_c_tail `holds` 45:19-24 `...::survey::holds[berth]::holds` and
   `berth` `...::holds[berth]::berth`; ours `holds[berth]` 45:13-18 and `...::survey::berth`).
   A reference, operation or bare-decimal index; an operation's references drop their stored
   names too (golden `holds[j + 1]`: `...::holds[j + 1]::holds::j`); a constant stays
   unparented. The no-with form, a user method and the array-locator with form keep their
   shape (grid RW rw08, rw09, rw10).

## The grid (cases/, 83 case dirs in both views, 166 case-views; evidence/grid.txt, grid_summary.txt, grid_attrib.txt, grid_away.txt)

Every case dir's first line names its law. `drivers/gridall.sh` runs each case-view through
`drivers/case.sh` (golden = the pinned Surelog's database with check_probe's arguments, view e
adding `-elabuhdm` / `--elabuhdm`; every line with its exit code) on pristine, law,
law+R11U296_OFF and law with each single switch:

- **166 case-views, 127 moving, 73 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes;**
  R11U296_OFF gives pristine's bytes on 166 of 166; every mover is restored by exactly one
  switch (RETFOLDTS 26, PKGFNCLONEIDX 23, HCTRAILIDX 36, CASTIDXTS 24, RANDLASTSEL 18); four
  uhdm-cmp line counts change, all to 0 (RF rf04 d/e 36 -> 0 and rf05 d/e 32 -> 0: the
  wrongly bound clone carried the other parameter's range or kind, which uhdm-cmp reads).
- **The chain-keyed away census** (drivers/awaygrid.sh, awaychain.py over strictcmp_x
  records): away 0 on all 127 movers, 306 records toward golden; the positive control
  (binaries swapped) reads away 1 to 5 on 11 of 11 sampled movers
  (evidence/away_poscontrol.txt). Fifteen movers read 0 away and 0 toward:
  HC hc10, hc19 and hc20 (d/e) differ from pristine only in the symbol table (the chain name
  the law computes is interned and a later rule writes the final name: their dumps are
  identical, checked on hc19), and the stage-1 movers CI ci05 d, HC hc14 and hc22 (d/e), RW
  rw14 and rw15 (d/e) move only records the stage-1 walk does not align with golden.
- Per group (the shapes and contexts; STRICT_EQUAL counts are law case-views):
  - **RF** (§ retFoldTsKeyedByParam296, 16 dirs): two parameters in an if and its mirror
    (rf01, rf02), the same parameter twice (rf03, unmoved control), `logic [7:0]`/`logic [3:0]`
    (rf04) and `byte`/`shortint` (rf05) parameters (uhdm-cmp 36 and 32 -> 0), an untyped
    parameter (rf06), the first return in a case (rf07) and in a for (rf14), a package
    importer (rf08) and two importers of two functions (rf09), localparams with an operation
    initializer (rf10), a void function beside (rf11), the $unit function (rf12, control,
    unmoved), an explicit import (rf13), the call in a part-select bound and a port dimension
    (rf15, constant slots), a class static function (rf16, control, unmoved): 26 movers, 20
    entering STRICT_EQUAL.
  - **CI** (§ pkgFnCloneIdxNamesByChain296, 14 dirs): a local, a formal, a package variable,
    an operation, a nested select and a call as the receiver path's index (ci01 to ci05,
    ci11), struct member paths (ci06, ci07), a class property read (ci08), a task (ci09), a
    two-dimension path (ci10), a module importer beside the package importer (ci12), a chain
    of importers (ci13), two importers (ci14): 23 movers, 6 entering STRICT_EQUAL (every
    default view the grid can judge), the elaborated views moving toward golden (residue 3).
  - **HC** (§ hcTrailIdxNamesByPortChain296, 22 dirs): a reference, an operation, a nested
    select, a concatenation and a call as the index of a port connection's trailing select
    (hc01 to hc04, hc14), positional (hc05), the base select (hc06, hc19), an indexed part
    select (hc07) and a constant part select (hc08, constant slots), a for-generate (hc09)
    and an if-generate (hc10), an instance array (hc11), instance depths 2 and 3 (hc12,
    hc13), a plain vector (hc15) and a package parameter index (hc16) as controls, two
    instances (hc17), an interface member path (hc18), a two-select member path (hc20), a
    class specialization index (hc22), a named call argument (hc23): 36 movers, 16 entering
    STRICT_EQUAL, every elaborated view the grid can judge equal.
  - **CT** (§ castTsInPathIdxByChain296, 16 dirs): a cast in a concatenation member, as the
    whole index, under an operation, of a typedef and `signed'` (ct01 to ct05), in a
    continuous assignment (ct06), an lvalue index (ct07), a function (ct08), a for-generate
    (ct09), a plain vector control (ct10), a class method (ct11, `::` join), two casts
    (ct12), part-select and indexed-part-select bounds (ct13, ct14, constant slots), a class
    specialization (ct15), an interface body (ct16): 24 movers, 22 entering STRICT_EQUAL.
  - **RW** (§ randWithLastSelChainShape296, 15 dirs): a local, a property, an operation, a
    literal and a formal index (rw01 to rw04, rw07), two dimensions (rw05), a middle path
    (rw06), the no-with randomize (rw08), a user method (rw09) and a `void'(...)` statement
    form (rw10) as controls, a nested select index (rw11), an if condition (rw12), a call
    index (rw13), a parenthesised operation (rw14), a `this.` path (rw15): 18 movers, 13
    entering STRICT_EQUAL.
- **Downstream** (drivers/dscases.py through scripts/downstream_uhdm2rtlil.py one(), both
  lanes, on the RF, HC and CT cases; evidence/downstream_cases.txt): 54 cases, no verdict
  change between pristine and law (51 IDENTICAL, 3 EQUIVALENT on both: hc08, hc14, ct13).
- One case was dropped before the final grid: an interface instantiating a module (illegal
  SystemVerilog; slang rejects it with exit 3 on both binaries).

Byte controls (drivers/controls.sh over every dut.sv dir of r11u118repro, r11v11u118repro,
r11u119repro, r11u120repro, r11u133repro, r11u145repro, r11u147repro, r11u220repro,
v11u220repro, r11u236repro, r11u284repro, r11u288repro, v11u288repro, r11u292repro,
v11u292repro, r11u294repro and v11u294repro, the path list filtered by $FENCED first;
`evidence/controls.txt`, `controls_summary.txt`, `controls_away.txt`): 1298 case dirs, 2596
case-views, 4 moving, 0 entering or leaving STRICT_EQUAL, 0 exit-code and 0 uhdm-cmp
line-count changes: r11u220repro/cases/CI/c07 d/e (a class handle array's method path in an
importer package's clone of a free function, stage 1 on both binaries, PKGFNCLONEIDX alone,
4 and 1 records toward golden) and v11u220repro/cases/C/c22 d/e (STRICT_NOTEQUAL fullname on
both, CASTIDXTS alone, 4 and 4 records toward); the away census on all 4 reads 0. Four
case-views (r11u220repro/cases/SL/s37 d/e on both binaries) have no golden (Surelog writes no
database for them).

## Prediction and gates (evidence/predict.txt, gates.txt, sweep_P.log, sweep_L.log)

The firing census (drivers/tracecensus.sh) ran on the frozen law binary BEFORE the law sweep,
over the probe cases and both corpora in both modes with the filter built from $FENCED
(evidence/predict.txt). It named exactly the five probe databases above (v169_g_control:
RETFOLDTS 6; g193_c_argface: PKGFNCLONEIDX 4; v8_sites2: HCTRAILIDX 1; b3_edges: CASTIDXTS 1;
g175_c_tail: RANDLASTSEL 1) and six corpus row-modes where a trace fires and, as checked
against the pristine sweep's databases before the law sweep, the bytes stay:
Earlgrey_0_1 d/t (HCTRAILIDX 97 each: elaborated port connections whose base the law
recomputes, but whose index references are constants or are renamed by a later rule) and
MiniAmiq d/t, SeqDriver d/t (PKGFNCLONEIDX 16 each: svaunit_pkg's clone of uvm_pkg's free
`uvm_create_random_seed`, `seed_map.seed_table[type_id]`, where the reference already
stored the chain name and was already parented at the select; dropping the stored name
gives the same name on save). The census csvs read regressions=0 conversions=0 changes=0
against both corpus baselines under the fence filter.

- byteverify on fence-filtered mirrors (drivers/mirror.sh, 8 fenced paths skipped by name):
  0 of 2560 corpus databases move; SELFCHECK reads 2559 of 2560 flagged: the self-check
  compares every database against one fixed database, which never differs from itself (the
  known artefact, not a mover). Probe databases: exactly the five predicted of 4087.
  Downstream slang-lane databases: 0 of 805.
- Row by row, the law sweep's surelog.csv differs from pristine's only in the LowMemLib and
  LowMemPkg testflags detail text (the workdir path), uhdm2rtlil.csv in nothing, probe.csv
  in the five conversions, downstream.csv in nothing (byte-identical to results/downstream_uhdm2rtlil.csv on both binaries).
- canaries surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both
  (EXPECT_UNKNOWN=1 and 6).
- binary-path audit (drivers/audit.sh, path list fence-filtered first): pristine and law sweeps each 3265 cmds.txt naming that sweep's own
  binary, 50 running no slang, 0 naming another binary, 8 fenced paths skipped by name.
- determinism (drivers/det.sh, evidence/det.txt): three concurrent draws of the law binary on
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen read one hash
  per row-mode (12 row-modes; Scoreboard and Rggen testflags write no database), each equal to
  the law sweep's database.
- uhdm-cmp: 0 lines on the five converted probe cases; no corpus database moved.

## Residues, ranked (every one wrong on pristine too)

1. **The elaborated port connection's index binding (default view).** With
   § hcTrailIdxNamesByPortChain296 the names agree; the default view's next record is the
   binding: golden binds a plain reference in the high connection's index (`.a(q.f[i])` on the
   elaborated instance) to the definition's `logic_net i`, ours to the elaborated `int_var`
   (HC hc01, hc02, hc07, hc12, hc13, hc17, hc18 d: `depth`, the walk expanding golden's net).
   The binding is made in emitExpr under ModuleEmit emitInstance's netMap (the stale
   `currentScope` of RESUME §9); not decoded.
2. **The other path-index sites under a port.** A bare reference indexing the path's FIRST
   select (`.a(qa[i].f[0])`, HC hc06: golden `work@dut.u.a.qa[i].f[0].i`, ours `work@dut.i`):
   no naming rule visits it (§ hpBaseSelOpIdxNamesByPath145 takes operations only, and outside
   a port golden keeps the bare scope name). Stage 1 on both binaries: a positional connection
   (hc05), a for-generate (hc09), an instance array (hc11), a call index (hc14), a class
   specialization index (hc22), a named call argument in the default view (hc23 d).
3. **The elaborated view of the package-function clones** (CI ci01 to ci04, ci12, ci14 e and
   probe g193_c_argface e 10 -> 6 records): golden's elaborated listing names the index
   references by the chain in the HOME listing too (`Pier193::c7_two193::fleet193[kink193].
   rub193::kink193`), where the definition view keeps the home's stored name; the drain runs
   for the clones only. The CI shapes at stage 1 on both binaries: a nested select index
   (ci05), a struct member path (ci06, ci07), a class property read (ci08), a task (ci09), a
   two-dimension path (ci10), a call index (ci11), a chain of importers (ci13).
4. **The return fold's other faces** (RF): an importer package's function returning a call
   of the imported function (rf08 `function int g(); return f(1'b0); endfunction`: in the
   elaborated view golden locates the folded constant at the callee's return value 7:12 where
   ours spans the call 12:28, and the default view's listing keeps a func_call where golden's
   has none; the family of the probe residues v9fold8, v3_clone13, a1 and va8, where golden's
   second package listing leaves `return foldable(a)` with no value at all; not decoded), two
   importer packages in the default view (rf09 d, stage 1 on both), a call in a part-select
   bound ending at the name in golden (rf15 `w[f(1'b0)-1:0]` 13:17-18 where ours spans the
   call), the $unit function (rf12 d, stage 1).
5. **The cast typespec's unreached shapes** (CT): `signed'(...)` (ct05), a for-generate
   continuous assignment (ct09), a part-select bound (ct13) and an indexed part-select base
   (ct14), all stage 1 on both binaries.
6. **The randomize-with receiver's unreached shapes** (RW): two written dimensions (rw05), a
   nested select index (rw11), a call index (rw13), a parenthesised operation (rw14), a
   `this.` path (rw15), an if condition in the default view (rw12 d), all stage 1 on both.
7. **The probe residue** (116 STRICT_NOTEQUAL cases after this pass): the writer tags of
   tools/probe/r11u294repro/evidence/residue_writers_base.txt stand for every case this pass
   did not move; on this ground the leaders are the select-naming leftovers (b1_sites four
   records at two sites, c2_idxkind four faces, v92_b2_varsel), the package-qualified ternary
   fold end (r10earl31repro/v4_ops: golden ends the folded `pk::DC` in a ternary condition and
   its false branch after `pk::`, 4 records), the struct-fold leftovers (r11u26 m4 and m7,
   r11u28 a2), the 64-bit cast values of r11u109 (a Surelog defect, not copied) and t12.

## Sister-ground faces read on this pass (reported, not written)

- r10v62repro/v62e_bind fullname(5): `assign p6 = (bv.op inside {BA, BC});` in the first
  instance u_a of a module with three specializations; golden gives the instance its own
  continuous assignment (references named `work@top62e.u_a.op`, `...u_a.BA`, the left side
  unbound), ours shares the definition's cell (`work@be62.op`, p6 bound to the definition
  net). ModuleEmit emitContAssigns, the share-or-clone decision for an inside-set right side.
- The elaborated port connection's index binding (residue 1): the reference is emitted by
  emitExpr under ModuleEmit emitInstance, whose netMap binds the elaborated `int_var` where
  golden's default view binds the definition's `logic_net`.
- The writers pass 294 tagged for the other sister-ground residues stand
  (tools/probe/r11u294repro/evidence/residue_writers_base.txt): a3_inst66 and
  c9_litarith_noovr (ModuleEmit), p1_pos115, a1_axis121, grid7, v8, b2_exprforms,
  v41v_comment, g13 and vb4_instarr (TypeEmit emitSyntaxExpr), c_iface_body, v4_arm and
  a6_commadrive (ModuleEmit emitContAssigns and emitInterfaceDef), b3, n4, grid2, vA and
  pb19_modportview (ModuleEmit emitInstance), v9 (UhdmExporter's macro column model).

## Process

- Worktree /tmp/wt_r11u296 at 3049e6ab, scratch /tmp/r11u296_*; the pristine binary was built
  and frozen (md5 equal to the main tree's build) before any source edit; the law binary was
  frozen before the grid, the controls, the census and the law sweep; every cmds.txt audited.
- The fence was read fail-closed from the FENCED= line of tools/probe/r11u107repro/canaudit.sh
  (drivers/env.sh); every path list over a corpus tree was filtered before any file was opened;
  gdb ran only on probe cases (v8_sites2, g193_c_argface) to find the setters.
- THE IMPLEMENTER'S SLIPS, no effect on any number: (1) one shell line ran `$UHDM_DUMP` on a
  cached probe golden (r10uvm175repro/g175_c_tail's) in a shell where the variable was unset,
  so the shell tried to execute the database: it printed two parse errors and wrote nothing
  (the scratch directory held only this pass's files afterwards; the golden's md5 unchanged);
  every later dump went through drivers/dump.sh, which guards the variable. (2) one `ps` line
  listing this pass's own census processes printed the census's own `--filter` argument, which
  holds the fenced names; no fenced source or database was read and no fenced test was run by
  hand. (3) a draft law, § cloneIdxHomeLocalIsOwn296 (a reference bound to the home
  subroutine's local counted as the clone's own), proved unnecessary on its own grid (the CI
  movers byte-identical with and without it) and was removed before the law binary was frozen.
- The law-index check fails at the base already (`law index STALE`); both sweeps exited 1 on
  it alone; the patch carries the regenerated tests/LAWS.md.

## Drivers (drivers/, copied from tools/probe/r11u294repro/drivers; every one reads $FENCED fail-closed through env.sh)

- `env.sh` pins and the fence; `case.sh <dir> <bin> d|e` one case-view (its own golden cache,
  `R296_GOLD`); `views.sh`, `gridall.sh` (GRIDGLOB selects a group), `gridsum.py`, `attrib.py`;
  `controls.sh`, `ctlsum.py`; `awaygrid.sh` + `awaychain.py` + `awayrows.py` (chain-keyed away
  census, needs `SCX` = strictcmp_x built by `cc_x.sh`); `tracecensus.sh` (firing census ->
  predict.txt); `mirror.sh` (fence-filtered hard-link mirrors for byteverify); `audit.sh`;
  `det.sh` (three concurrent draws); `dscases.py` (downstream harness on cases); `dump.sh`
  (guarded uhdm-dump); `residue.py` (first strict records of every STRICT_NOTEQUAL probe case).
- The grid: `GRIDGLOB='*/*/' bash drivers/gridall.sh <pristine> <law> grid.txt R11U296_RETFOLDTS_OFF
  R11U296_PKGFNCLONEIDX_OFF R11U296_HCTRAILIDX_OFF R11U296_CASTIDXTS_OFF R11U296_RANDLASTSEL_OFF`.
