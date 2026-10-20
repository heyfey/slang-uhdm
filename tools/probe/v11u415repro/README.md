# v11u415 — adversarial verification of r11u415

Base 4f83b198. Verifies the implementer's patch /tmp/r11u415.patch (md5
e38e838e625218b299253df5d8a08972, seven laws in src/ExprEmit.cpp and
src/StmtEmit.cpp). Verdict: the claims reproduce exactly. The fresh cases found
three places where the law was wrong on legal SV and pristine was right:
§ pkgLetCallFuncCall415 inside the let's own package (VL), and
§ labeledCallStmtLabelDropped415 on a labeled hierarchical call to a module
instance's subroutine (VA). The extern-call law also dropped an argument's
parent and kept slang's formal order (VX). Four production refinements fix
these. Each sits behind its own switch, read through `fixOn(415, ...)`, and
`R11V415_OFF` gives the law's bytes back.

## Binaries (frozen under /tmp/v11u415_bin)

| binary | md5 | what |
|---|---|---|
| pristine | 72d4f6bae580986adaa074230873072e | the main tree's build/slang-uhdm at the base (the budget: no pristine build) |
| law | 3bfb5860fd8461254d6babfe48feb443 | the implementer's patch rebuilt in /tmp/wt_v11u415, equal to the implementer's law7 |
| ver1 | 3df568b937acbe491f2dcf68cda94f2c | law + § pkgLetOwnPkgAbstain415v, § externCallNamedWritten415v, § externCallArgParent415v |
| ver2 | 42a17ef86d53481c31bcf8b76ee9a73f | ver1 + § labelHierModCallKeep415v (the final verified binary) |

All four report slang 12.0.0+545f88b2e.

## Reproduction of the implementer's numbers

- **Grid:** the implementer's 36 case dirs, rerun with drivers/grid.sh
  (evidence/implementer_grid_reproduced_law.txt). Every line matches
  evidence/grid_law7.txt in exit code, uhdm-cmp count, dump distance and
  strict verdict. Only the output-path-dependent md5 column differs.
  R11U415_OFF and each group's own switch give pristine's bytes on 36 of 36.
- **Earlier-pass case dirs:** 2194 fence-filtered case dirs from
  tools/probe/r11u401repro to v11u416repro
  (evidence/earlier_pass_cases_pristine_law_ver2.txt). The exit codes match
  the implementer's file on 2194 of 2194. Three dirs move on the law:
  r11u416 DC/dc13 (exit 4 -> 0, same bytes), v11u405 VD/vd03 and v11u413
  VC/vc13. ver1 and ver2 are byte-identical to the law on all 2194.
- **Law sweep** (/tmp/v11u415_swL, run once on the law binary). The corpus
  stages ran from the worktree. The sv-tests stage ran through the main
  tree's scripts/check_svtests.py, read-only, because a worktree has no UVM
  tree.
  - probe: EQUAL 4018 + STRICT_NOTEQUAL 69, 0/0/0; csv byte-identical to /tmp/intr11u413.
  - surelog: default 480 + 0, testflags 474 + 0, 0/0/0; csv differs from the control only in the two LowMem log-path texts.
  - uhdm2rtlil: 803/1/67 in both modes, 0/0/0; csv identical.
  - downstream: IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0; csv identical.
  - sv-tests: EQUAL 1809, STRICT_NOTEQUAL 6, DIFFERENT 125, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions 0, conversions 1, changes 0. The one conversion is generated/hdlconv_std2017/hdlconvertor_std2017_p292.sv DIFFERENT -> EQUAL, fresh row `generated/hdlconv_std2017/hdlconvertor_std2017_p292.sv,EQUAL,,equal`. The csv is identical to the control's on the other 2345 rows.
  - byteverify (SELFCHECK=1) against /tmp/intr11u413: surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805. The selfcheck flags 961, 1607 and 804.
  - canaries: ok=52 changed=0 and ok=16 changed=0. ctcan2 PASS on both (EXPECT_UNKNOWN=1 and 6).
  - binary audit (fence-filtered cmds.txt): surelog 1523 of 1573 name the law binary. The 50 others hold no slang-uhdm line, except 2 that name slang-uhdm only in the UVM checkout path. uhdm2rtlil 1740 of 1740.
  - p765 against golden by normalized dump: 204 lines away on the control, 110 on the law. Its uhdm-cmp head is now memMod's out-of-body task listing.
- **Verified sweep** (/tmp/v11u415_swV, run once on ver1 with R11U415_TRACE set).
  - Every stage reads the same as the law sweep. The sv-tests csv is byte-identical to the law's.
  - byteverify: 0 movers against the law and 0 against the control in all three corpora.
  - canaries and ctcan2: the same readings as the law sweep.
  - audit: surelog 1523 of 1573, uhdm2rtlil 1740 of 1740.
  - Trace census (the positive control is that the laws do fire): the probe case r11u47repro branches/g2 (§ badCastSizeNoExpr415), sv-tests p292 (§ pkgLetCallFuncCall415) and p765 (§ labeledCallStmtLabelDropped415, both disable laws, § externTaskCallUnlinked415). No refinement fired anywhere in the five stages. This is the implementer's trace census exactly.
- **ver2:** it adds only § labelHierModCallKeep415v, whose condition is a strict subset of § labeledCallStmtLabelDropped415's. In both sweeps that law fired only on p765, on interface-port calls, so ver2 cannot move a sweep database. The budget allows no third sweep, so ver2 was measured by targeted reruns instead:
  - p765 and p292 rerun through scripts/svtests/svtests_matrix.py: statuses DIFFERENT and EQUAL. The normalized dumps are identical to ver1's sweep databases, and the trace shows no refinement firing.
  - The 2194 earlier case dirs: identical to the law.
  - All 97 case dirs (the implementer's 36 plus these 61): R11V415_OFF gives the law's bytes and exit code on 97 of 97 (evidence/ver2_vs_law.txt).

## The breaks (fresh cases on legal SV, accepted by upstream slang)

1. **§ pkgLetCallFuncCall415 inside the let's own package**
   (cases/VL vl01, vl17).
   - Shape: a package function's `return sum2(a, b);` where `sum2` is a let of the same package.
   - Golden: Surelog finds the let in the calling scope and substitutes it. It writes the let_decl's own body: an operation parented at let_decl (sum2) with operands ref_obj sum2.x and sum2.y. Pristine already inlined that body.
   - The law wrote a func_call there. vl01 moved from 32 to 80 uhdm-cmp lines and from 150 to 174 dump lines away. vl17 moved from 32 to 80 and from 297 to 305.
   - A package that imports the let from another package does not find it, so the law is right there (vl16 STRICT_EQUAL).
2. **§ labeledCallStmtLabelDropped415 on a labeled hierarchical call to a module instance's task or function** (cases/VA va08 `lh: u.t(5);`, va15 `lf: void'(u.f(5));`).
   - Downstream moved IDENTICAL -> EQUIVALENT on both. The law unwraps pristine's named_begin, and uhdm2rtlil then inlines the task_call bound to work@sub.t.
   - Golden writes an unlinked method_func_call with the prefix `u`. The unlabeled `u.t(5);` already shows the same face on pristine (UL ul01 in evidence/downstream_cases.txt is EQUIVALENT on pristine).
3. **§ externTaskCallUnlinked415's argument list** (cases/VX).
   - A literal argument came back with no vpiParent where pristine's linked call parented it (vx01 `f(1)`, vx02, vx04, implementer FJ fj02).
   - A named-association call kept slang's formal order where golden, which leaves the call unresolved, lists the written order (vx05 `Write(.e(2), .d(1))`).

## Refinements (production, ExprEmit and StmtEmit; through src/LawSwitch.h)

| refinement | switch | file | what |
|---|---|---|---|
| § pkgLetOwnPkgAbstain415v | R11V415_LETOWNPKG_OFF | ExprEmit | the let law abstains when its one matching call site lies inside the let's own package syntax |
| § labelHierModCallKeep415v | R11V415_LABELHIER_OFF | StmtEmit | the label law abstains on a labeled call written `x.f(...)` (not this/super) whose subroutine belongs to a MODULE instance body; interface and class method calls unaffected (va16, lb04, va04 keep the law) |
| § externCallArgParent415v | R11V415_EXTARGPARENT_OFF | ExprEmit | an argument of the extern-call func_call returned with no parent is parented at the func_call |
| § externCallNamedWritten415v | R11V415_EXTNAMEDORDER_OFF | ExprEmit | a named-association extern call lists its actuals in written order (§ namedUnlinkedWrittenOrder207's order) |

`R11V415_OFF` gives the law's bytes and exit code back on 97 of 97 case dirs.
No src/R*.h, no getenv and no reader function. EmitHelpers.h, ParamEmit and
the sister's four files are unchanged.

## Attack grid (evidence/grid_ver2.txt, drivers/vgrid.sh; 61 case dirs, each first line `// § <law>`)

Every case is accepted by upstream slang (~/.local/bin/slang, `--single-unit`).
Each grid line gives pristine and ver2 (exit code, uhdm-cmp lines, dump lines
away from golden, dump md5, strict verdict), then whether R11U415_OFF and the
group's own law switch give pristine's dump and exit code (61 of 61 yes), then
the trace.

| group | law | cases | pristine -> ver2 |
|---|---|---|---|
| VT | § thisCallResultMemberDropped415 | vt01 `$display(this.mk().s)`, vt02 `this.mk().s + 1`, vt03 `this.mk().inner.s`, vt04 `super.mk().s` from a derived class, vt05 a package class `this.mk(k).s`, vt06 control `this.nxt.mk().s`, vt07 if condition and assignment in a task, vt08 a struct return `this.mk().b` | 6 exit 4 NOT_EQUAL -> exit 0 STRICT_EQUAL (vt01, vt02, vt04, vt05, vt07, vt08); vt03 exit 4 -> exit 0 where Surelog itself rejects (syntax error at the second `.`); vt06 byte-identical STRICT_EQUAL |
| VB | § badCastSizeNoExpr415 | vb01 in nested generate if/else, vb02 `p::W'(x[i])`, vb03 an interface instance, vb04 always_comb in a generate loop, vb05 a generate-scope localparam width, vb06 an overriding instance | vb01, vb05 exit 4 -> exit 0 with identical bytes (STRICT_EQUAL); vb02, vb04 STRICT_EQUAL and vb03, vb06 NOT_EQUAL at pristine's bytes (the law does not fire) |
| VL | § pkgLetCallFuncCall415 (+ § pkgLetOwnPkgAbstain415v) | vl01 call in the let's own package, vl02 continuous assign, vl03 two modules with different actuals, vl04 two modules with the same actual names, vl05 inside an assert property, vl06 one module instantiated twice, vl07 a let calling a let, vl08 named arguments out of formal order, vl09 $display argument, vl10 module function locals, vl11 generate loop, vl12 two `pex::sum2` calls, vl13 two calls with different actuals, vl14 a parenthesized argument, vl15 a class in the let's package, vl16 another package importing the let, vl17 own-package call plus a module call | 7 NOT_EQUAL -> STRICT_EQUAL (vl02, vl08, vl09, vl11, vl12, vl13, vl16); vl03, vl06 -> STRICT_NOTEQUAL fullname (golden keeps work@m1.a in the elaborated instance's cont_assign around an unresolved call), vl10 -> STRICT_NOTEQUAL type (`assign o = f()` folded to 3 on pristine too); vl17 NOT_EQUAL toward golden (297 -> 281); vl01, vl04, vl07, vl14, vl15 at pristine's bytes (refinement or abstain); vl05 STRICT_EQUAL control (slang does not expand a let in a property) |
| VA | § labeledCallStmtLabelDropped415 (+ § labelHierModCallKeep415v) | va01 fork/join, va02 a function's labeled $display, va03 `initial lab: t(a);`, va04 class `this.run(3)` and `run(4)`, va05 generate-scope task in always_ff, va06 queue `push_back`, va07 `t(f(a))`, va08 `u.t(5)` module instance, va09 inside a named begin, va10 if/else branches, va11 beside a labeled assignment, va12 labeled `void'($urandom)` and `std::randomize`, va13 the label targeted by `disable`, va15 `void'(u.f(5))` module instance, va16 `i1.Put(3)` interface instance | 10 NOT_EQUAL -> STRICT_EQUAL (va01 to va04, va06, va07, va09, va10, va13, va16); va05, va11, va12 NOT_EQUAL toward golden (99 -> 45, 70 -> 42, 58 -> 36; remaining heads: the generate-scope task call golden writes as an unlinked func_call, the labeled assignment, the labeled `r = $urandom`); va08, va15 at pristine's bytes (refinement) |
| VD | § disableHierNetFirstName415, § disableHierNoTaskExpr415 | vd01 `blk.inner` local, vd02 `u1.blk`, vd03 three disables through two instances, vd04 inside a generate loop, vd05 `top.m.l.Read`, vd06 two modules each `u1.Read`, vd07 interface task from a module task, vd08 local `Read` plus `u1.Read`, vd09 two instances' blocks, vd10 `top.blk` twice from initial and task | 9 NOT_EQUAL -> STRICT_EQUAL; vd04 NOT_EQUAL toward golden (19 -> 8: pristine minted two `Read` nets in work@sub, the law one `u1`, golden none: the implicit net of a disable inside a generate scope lands in the wrong module on pristine too) |
| VX | § externTaskCallUnlinked415 (+ § externCallArgParent415v, § externCallNamedWritten415v) | vx01 extern function `f(1)`, vx02 extern task called from an interface task, vx03 `b.Write(7)` through an import modport, vx04 forkjoin task with an argument and two exporters, vx05 named arguments out of formal order | vx01, vx02, vx04, vx05 NOT_EQUAL toward golden (56 -> 52, 45 -> 37, 25 -> 17, 59 -> 37); the call now matches golden line for line and the uhdm-cmp head is the exporting module's out-of-body task listing (sister ground); vx03 at pristine's bytes (the law does not reach a modport method call) |

Summary: 32 NOT_EQUAL -> STRICT_EQUAL (6 of them from exit 4), 3 NOT_EQUAL
-> STRICT_NOTEQUAL, 9 NOT_EQUAL toward golden, 2 exit 4 -> exit 0 on
identical STRICT_EQUAL bytes, 1 exit 4 -> exit 0 where Surelog rejects, 10
NOT_EQUAL and 4 STRICT_EQUAL at pristine's bytes. On ver2 no case leaves an
equal status, no exit code is worse and nothing moves away.

Downstream (evidence/downstream_cases.txt, `downstream_uhdm2rtlil.one` on 49
class-free fresh cases plus the implementer's LT, DN, LB lb01/lb03/lb06, BC
and FJ, pristine against ver2/ver1):
- Moved to IDENTICAL: VA va03, va07 DIVERGENT -> IDENTICAL. VD vd06, VL vl02, vl03, vl06, vl11, vl12, vl13, vl17 STATUS_DIFF -> IDENTICAL. VL vl08, VX vx04, vx05 EQUIVALENT -> IDENTICAL.
- The implementer's own: LT lt02 to lt04, lt06, lt08 STATUS_DIFF -> IDENTICAL. LT lt01, FJ fj01, fj02 EQUIVALENT -> IDENTICAL.
- The law moved va08 and va15 IDENTICAL -> EQUIVALENT. Both are back at IDENTICAL on ver2.
- None worse on ver2.

## Goal 1 (checked)

- this.mk().s exports (VC/vc13 and VT). `this.mk().inner.s` exports too (vt03), where Surelog rejects it and upstream slang accepts.
- W'(x[i]) in a generate-loop port connection now exits 0 on identical bytes (dc13, BC, vb01, vb05).
- C::mk().arr[1] and u.mk(x).a[2]: Surelog rejects both and upstream slang accepts. Not forced.
- Black-parrot: not remeasured. The guard is untouched, and the implementer reports bp_unicore at exit 3, 795 MB.
- SURELOG_ONLY rows: all 75 unchanged in both sweeps.

## Residues (all wrong on pristine too; none moved away on ver2)

1. **Module-instance hierarchical calls.**
   - Golden writes `u.t(5)` as an unlinked method_func_call spanning the name, with the prefix ref_obj `u`.
   - We write a task_call bound to work@sub.t, labeled (va08, va15) or not (UL ul01). Downstream is EQUIVALENT on pristine for the unlabeled form.
   - Writer: ExprEmit's call emission (this ground).
2. **A package let's call inside an instantiated module.** Golden keeps the definition's full names (work@m1.a, work@m1.o) on the elaborated instance's cont_assign, because Surelog does not elaborate it (vl03, vl06).
3. **Package let calls the law cannot place:**
   - two identical call sites (vl04, lt09);
   - a parenthesized or expression argument (vl14, lt07);
   - a let calling a let (vl07);
   - class properties as actuals (vl15).
4. **Generate-scope task calls** (va05): golden writes an unlinked func_call, we write a task_call.
5. **Labeled non-call statements** (va11, va12, lb07, lb08; pass 403's VM/vm12).
6. **The implicit net of a hierarchical disable inside a generate scope** is minted in the instantiated module on pristine and on the law (vd04). Golden mints none.
7. **The exporting module's out-of-body interface task listing** (vx01, vx02, vx04, vx05, fj01, fj02, p765's next head). TaskFuncEmit and ModuleEmit: sister ground.
8. **`b.Write(7)` through an import modport** (vx03): not reached.
9. **Interface-instance and overriding-instance size casts** (vb03, vb06): NOT_EQUAL on pristine, the law not firing.
10. **The implementer's residue list stands as written:** the UVM rows, the basejump rows, decoder_dor and mesh_router's emitSyntaxExpr select (TypeEmit), class_test_49, p599, p600, tnoc 333:14, scr1, p733, fx68k and the carried backlog.

## Sister-ground faces (reported, not written)

- TaskFuncEmit and ModuleEmit: the exporting module's out-of-body interface task (`task a.Write(...)`). Golden lists it as an unnamed task under the module's vpiTaskFunc (VX, FJ, p765).
- ModuleEmit: the interface port typespec `interface_typespec (slave)` where golden writes `(bus)` with a vpiActual to the interface instance (VX, lb04).

## Process

- **Builds:**
  - The law binary was rebuilt once; its md5 equals the implementer's law7.
  - There were two verified builds. ver1 fixed the let and extern breaks. ver2 was needed because ver1's downstream check on the fresh VA cases found the label break.
  - That is one build over the budget. There was no third sweep: ver2's one refinement narrows a law that fired only on p765, and was measured by the targeted rows and the case grids.
- **Sweeps:** two full five-stage sweeps, on the law and on ver1, each launched after checking that no other sweep or runner was live. The sister's corpus sweep finished before the first one started.
- **Attack grid timing:** the attack grids ran as single processes while the sister's probe stage was running, for about a minute.
- **The fence:** the fence list was read by a program into a file and never printed. Every tree-wide list (cmds.txt audits, case dirs) was filtered on it before any file was opened. No fenced test was named, opened or run.
- **Other agents:** no other agent's process was touched.

Drivers: drivers/case.sh (golden cached by md5 of dut.sv; exit code, uhdm-cmp
lines, dump lines away, dump md5, size, strict verdict), drivers/vgrid.sh,
drivers/vcheck.sh, drivers/grid.sh, drivers/earlier.sh, drivers/sweep.sh,
drivers/mk.py.
