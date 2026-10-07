# v11u283 — adversarial verification of r11u283 (program and interface process sharing, bound-instance display names, generate comma lists, scoped class returns)

Base fa9bf4a9 (pass 281). The implementer's patch (/tmp/r11u283.patch) applied clean on a fresh worktree; the
verifier rebuilt pristine (b14ecd9c27c854a7b81fcde33f30da1a, equal to the main tree's build at the base), the law
(c9c78b5b9208ea870395bb4f4399d383, equal to the implementer's) and the fix (7b6b01f23cc6145e38b6779ec888f6c2), froze
all three before measuring, and reproduced every gate number. **VERDICT: one break, fixed.** Laws 1 and 4
(§ progDefKeepsLastInstProcs283, § ifaceInstFirstProcsShared283) take "first" and "last" instance from OUR emission
order, which emits a body's direct instances before its generate blocks; golden takes them from the SOURCE order. On
legal SV where pristine was right the law moves records away from golden (chain-keyed away 6 to 12). The refinement
§ progLastInstSrcOrder283v (ModuleEmit; `R11V283_SRCORDER_OFF`, `R11V283_OFF` for the refinement, read through
`r11v283On` in src/R283.h) fixes it. The fix moves no gate database against the law.

## The break (evidence/law_breaks.txt, drivers/awaycv.sh P L)

| case (cases/) | shape | pristine | law | chain away under the law |
|---|---|---|---|---|
| VP/vp05_gen_and_top | `if (1) begin : g prg u_p (.a(x)); end prg u_q (.a(y));` | stage 1 | stage 1 | 6 (both views) |
| VP/vp14_gen_then_child | a generate-block program, then a module instance holding one | stage 1 | stage 1 | 6 / 12 |
| VP/vp16_forgen_then_direct | a for-generate program, then a direct one | stage 1 | stage 1 | 6 / 6 |
| VI/vi12_gen_then_direct | `if (1) begin : g ifc a (.clk(clk)); end ifc b (.clk(clk));` | `depth` | `fullname` | 8 (default view; order-blind lost 8) |
| VP/vp10_direct_gen_direct | direct u_p, generate g.u_q, direct u_r | `fullname` | `fullname` | 0 (order-blind lost 2) |

Golden vp05 (uhdm-dump): the definition's `initial` is parented at `work@dut.u_q` and its ref_objs are named
`work@dut.u_q.a` with `vpiActual` `logic_net work@dut.g.u_p.a`: bound to the FIRST instance in source order (g.u_p),
named after the LAST (u_q). Ours emits u_q before the generate block, so the law bound the set to u_q's signals and
named it after g.u_p, both wrong; pristine had the names right. Golden vi12 binds the definition's `always` to
`work@dut.g.a.d`; the law bound it to `work@dut.b.d`.

**§ progLastInstSrcOrder283v** (ModuleEmit, inside both laws; switch `R11V283_SRCORDER_OFF`): one walk of the
elaborated design in source order (tops in slang's `topInstances` order; a body's members in order, generate blocks
in place, generate-array entries and instance-array elements in order, uninstantiated blocks skipped) numbers every
program and interface instance. Law 1 records the shared set only at the instance FIRST in that order (otherwise
every instance compiles its own, pristine's bytes), and a later instance re-stamps (re-parents and renames) the set
only when it is later in source order than the current holder, so the holder ends at golden's LAST instance. Law 4
records the first instance's set only at the instance first in source order. Trace tags `SRCORDER283V_ABSTAIN`,
`SRCORDER283V_KEEP`, `SRCORDER283V_IFABSTAIN` (abstentions; the census counts them as writing nothing).

Fix grid (drivers/fixgrid.sh, evidence/fixgrid.txt, drivers/fixsum.py -> evidence/fixgrid_summary.txt): every case
in both views on P, L, F, F + `R11V283_OFF` (FV) and F + `R11U283_OFF` (FU), every line with its exit code.

- **FV equals the law's bytes on 302 of 302 case-views; FU equals pristine's on 302 of 302.**
- F differs from L only on the order cases: vp05, vp13, vp14, vp16 and vi12 both views return to pristine's bytes;
  vp10 both views go `fullname -> STRICT_EQUAL` (the law left it at `fullname` with order-blind lost 2).
- The implementer's 91 dirs (182 case-views): F == L on all 182; P -> F 160 moving, 132 entering STRICT_EQUAL,
  0 leaving, 0 exit-code changes, the 11 uhdm-cmp line-count changes the implementer lists (I/i08, i17, i21, i22, i23
  to 0; I/i19 default 31 -> 638), bit for bit the implementer's grid.
- Away census P -> F (drivers/awaycv.sh, order-blind away.py and chain-keyed awaychain.py with the variant comparator
  strictcmp_x; evidence/fix_away.txt): **chain away 0 and lost 0 on all 260 movers** (the flat away 1 on P/p04 and
  VP/vp02, a named begin-block local, chain away 0, toward 21, the implementer's noted face). Positive control (the
  binaries swapped, evidence/away_poscontrol.txt): away 2 to 8 on six movers.
- The fix gives up one toward-only gain of the law: VP/vp13_two_gens_direct_between (g1.u_p, u_q, g2.u_r; ours emits
  u_q first, the refinement abstains; under the law chain toward 6, away 0, stage 1 on every binary).

## Fresh attack grid (cases/, 64 case dirs in VP, VG, VC, VI, VB, VR; 128 case-views, rc on every line)

drivers/grid.sh (P, L, OFF, each switch; evidence/grid.txt, evidence/grid_summary.txt for the first 58 dirs) and
drivers/fixgrid.sh (all 64 dirs). Every case file's first line names its law.

- Law against pristine on the first 58 dirs: **OFF == P on 100 of 100 case-views** (16 case-views are SLANG_FAIL on
  both binaries, see below), 90 moving, 58 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes; each mover back to
  pristine under exactly one switch except vi08, vi09 and vi11 (both views) needing IFPROCFIRST + IFVIEWNOPROC
  together, as the implementer's i17-i23.
- Over all 64 dirs: law 110 moving and 64 entering; fix 100 moving, 66 entering, 0 leaving, chain away 0 on all.
- Converting under the fix, by law: § progDefKeepsLastInstProcs283 VP/vp01 (two parameter overrides), vp03 (u_p and
  u_p2, the prefix-alias rename), vp04 (fork with named blocks), vp07 (two tops), vp09 (no ports), vp10 (with the
  refinement), vp11 (a module instance holding one, then a direct one), vp12 (direct, then a for-generate);
  § progGenDupFirstSpan283 VG/vg01 (arguments), vg03 (void, two instances), vg04 (same line); § defGenCaCommaListSpan283
  VC/vc02 (part-select left sides), vc03 (a generate if without begin), vc04 (comments across lines), vc06 (case
  generate in two instances), vc07 (the list written by a macro), vc08 (block-local nets);
  § ifaceInstFirstProcsShared283 VI/vi01 (two parameter overrides; the elaborated view stage 1 -> STRICT_EQUAL), vi02
  (different clocks), vi04 (two modules), vi05 (a named-block local), vi10 (a continuous assign beside the process),
  vi13 (a module instance holding one, then a direct one); with § ifacePortViewNoProcs283 vi08, vi09 (modport task
  import) stage 1 -> STRICT_EQUAL; § bindChildDisplayScopedNames283 VB/vb03 (if inside for), vb05 (target two levels
  down); § scopedClassRetQualSpan283 VR/vr02 (named parameter specialization), vr05 (a comment inside the scope),
  vr07 (a static method and an extern method of another package's class), vr08 (the package name from a macro), vr09
  (`fp::` and the class name on two lines), vr10 (a called function).
- Moving toward golden and not converting (chain away 0): VI/vi07 (a for-generate with genvar-dependent parameters,
  default view fullname(8 -> 2 records), elaborated view stage 1 -> fullname), vi11 (an interface port view of a
  program, stage 1 -> fullname), vi14 (direct, generate, direct: fullname), vi06 (a nested interface, stage 1, 2920 ->
  2812 uhdm-cmp lines), VP/vp02, vp06, vp08 (stage 1; toward 12 to 24), vp15 (an instance array, stage 1, 619 -> 571),
  VB/vb01, vb02, vb07 (stage 1), VC/vc01 (a concatenation left side: stage 1; elaborated view endcol -> col), VG/vg02
  (two generate blocks, stage 1), VR/vr06 (an interface-class prototype, stage 1; the class_typespec now golden's
  5:46-5:50).
- Moving with no record change (stage 1 on both): VR/vr01 (`K::N`, a class-scoped nested class: ours 9:22-9:25,
  golden lists no class_typespec at that line), vr03 (`$unit::LL`: ours 4:22-4:29, golden lists none), VC/vc05 (a
  program generate comma list: STRICT_EQUAL on both, the program's definition-view generate statements not walked).
- Not moving: VG/vg05 (a module, control), VR/vr04 (a typedef alias of a class, the law does not fire).
- SLANG_FAIL on both binaries (not this pass's): VB/vb04 (bind into an interface, exit 3), VB/vb06 (`bind tgt:
  u_t2`, an instance-specific bind, **exit 139**), VI/vi03 (a top module with an interface port, exit 3).
- Downstream (drivers/dscases.py; evidence/downstream_cases_{P,L,F}.txt): P 49 IDENTICAL, 5 EQUIVALENT, 1 DIVERGENT,
  3 SLANG_REJECT; L and F 52 IDENTICAL, 3 EQUIVALENT, 3 SLANG_REJECT; VI/vi01 and vi08 EQUIVALENT -> IDENTICAL, vi09
  DIVERGENT -> IDENTICAL; none worse.

## Gates reproduced (three sweeps from this pass's own workdirs /tmp/v11u283_{P,L,F})

- Probe: pristine EQUAL 3815 + STRICT_NOTEQUAL 272, regressions 0; law and fix **EQUAL 3836 + STRICT_NOTEQUAL 251,
  regressions=0 conversions=21 changes=0**, the 21 conversions by name equal to the implementer's (r10uvm226repro/
  grid226 a9_multiinst and a10_genregion, r10uvm56repro/v3_hierpath, r10v150repro/v150_f1, r10v226repro/arms/
  b12_multiproc, r10vearl106repro va3_span106 and va7_mix106, r10vearl113repro/v1_decl113, r10vearl95repro/v95f_bind,
  r10vearl98repro/v4b_bind98, r10vrgg16repro/cells/v14, r11u105repro/grid k40 and k42, r11u22repro/grid/
  d21_comma_list, r11u23repro/grid/d10_comma_list, r11u95repro/grid a22 and c13, r11v105repro/grid v13 and v22,
  r11v95repro/grid x27_proggendupfirst and x5_progtwoinstgeninit). The elaborated view of the 21 (evidence/
  conversions_elview.txt): 20 STRICT_EQUAL on the fix, r10vrgg16repro/cells/v14 `fullname -> depth`, as reported.
- Surelog: default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2 on all three binaries, regressions 0,
  conversions 0, changes 0; the csv differs between sweeps only in the LowMemLib / LowMemPkg testflags detail text (the
  workdir path). uhdm2rtlil 803 / 1 / 67 both modes, 0 / 0 / 0, csvs identical row for row in the first six columns.
- Downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0 on all three; the three csvs byte-identical
  to each other and to results/downstream_uhdm2rtlil.csv.
- Byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors from
  drivers/bvmirror.sh, 8 fenced row-mode databases left out): law and fix each against pristine **0 / 952 surelog,
  0 / 1608 uhdm2rtlil, 0 / 805 downstream**, SELFCHECK n-1 / n flagged on each. Probe (pristine rerun from the law
  worktree as /tmp/v11u283_Q so the source paths match): **21 of 4087 databases move, exactly the 21 conversions**;
  fix against law 0 of 4087.
- Firing census of the fix (drivers/tracecensus.sh, R11U283_TRACE over the probe and both corpora in both modes with
  the fence filter): 349 lines, the same keys as the implementer's evidence/predict.txt; the 21 lines beyond the
  port-view tracer are exactly the 21 probe conversions; `SRCORDER283V_*` fires on 0 gate databases (positive
  control: it fires on vp05, vp10 and vi12, /tmp scratch trace), predicting fix == law on the gate, as measured.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0 on the law and the fix; ctcan2 PASS on both csvs
  (EXPECT_UNKNOWN=1 surelog, 6 uhdm2rtlil).
- Binary-path audit (cmds.txt lists fence-filtered first): 3265 of 3315 name each sweep's own frozen binary
  (pristine, law, fix); the other 50 run no slang (two of them mention the repo path in a Surelog command line).
- Determinism (drivers/det.sh, three concurrent draws per row-mode with the fix; evidence/determinism.txt): one hash
  per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg d/t and Rggen d, each equal
  to the fix sweep's and to the implementer's law hashes.
- uhdm-cmp at 0 lines on every converted probe case and every touched corpus row (none moved).

## Byte controls (drivers/controls.sh, pristine against the fix; evidence/controls*.txt)

The implementer's 1887 dirs (the 37 repro dirs of r11u283repro/evidence/controls_dirs.txt) plus 2654 more tools/probe
case dirs whose source holds a program, a bind, an interface, a comma-list continuous assign or a scoped function
return (evidence/controls_cases.txt; 4541 dirs, 9082 case-views; every path list fence-filtered before any case was
opened; every line with its exit code):

- **The implementer's 3774 case-views: 6 moving, 4 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes**, the same
  six by name (r10uvm226repro/grid226/a14_genregcount d/e stage 1 at 500 lines, r10v226repro/arms/b14_param d/e
  stage 1 -> STRICT_EQUAL with 36 -> 0 and 64 -> 0 lines, v11u281repro/cases/VI/vi38_two_inst_two_declarators d/e
  `fullname -> STRICT_EQUAL`); the pristine and the law/fix verdict, strict, cmplines and rc fields equal the
  implementer's evidence/controls.txt on all 3774 lines.
- **Widened, 5308 case-views: 26 moving, 8 entering STRICT_EQUAL, 0 leaving, 0 exit-code or uhdm-cmp line-count
  changes**: r11u176repro PG/g09_two_progs d/e and r11u185verify PG/p05_param_iface_twice d/e `type -> STRICT_EQUAL`,
  v11u176repro PG/p04_nested_twice d/e `fullname -> STRICT_EQUAL`, r11u234dec GF/gf02_qual_el and r11v69repro
  grid/w6_declorder_el `endcol -> STRICT_EQUAL` (their default views stage 1, toward 2); stage 1 on both binaries
  r11u173verify dl/d04 and d10, v11u164repro DL/d02 (definition-view comma lists, toward 2), v11u196repro MG/g04
  (toward 12), r11u185verify PG/p03_prog_in_generate and X/x02_progmp_idx_actual (the definition's process now
  parented at golden's last instance, L[1].tbk and t1, which the stage-1 census cannot key), r11u213verify TR/r05
  (`K#(.W(2))::q_t`) and v11u271repro VT/vt12_extern_ret (`reg_c::T`), the last two moving the return class_typespec
  end where golden lists none at that line.
- Away census on all 32 movers (evidence/controls_away.txt): **lost 0 and chain away 0 on all 32**.
- Five case-views exit 139 on both binaries (r10v226repro/arms/b13_modportproc and r11v105repro/grid/
  v09_A_nested_program_in_sub, both views, as the implementer reports, and v11u254repro/cases/F/vf02_iface elaborated view in the widened set), none changed.

## Residues (ranked; all wrong on pristine too)

1. The implementer's list stands (struct-member full names in class and importer copies, 8 probe cases; a bound
   instance's child instances, B/b06; a program generate-block function after the body's, x8; generate-scope select
   left sides; interface declaration order; escaped-identifier end columns; class_typespec spans; the elaborated
   cont_assign call fold).
2. Program and interface instances whose source-first instance is not emitted first (vp05, vp13, vp14, vp16, vi12):
   the refinement abstains, pristine's bytes. Writing golden needs the shared set compiled at the source-first
   instance, which ours emits after the direct instances; vp13 under the law moved toward golden only by chance
   (the law bound g1's set through u_q's emission order) and is given up.
3. VI/vi07 a generate array of interfaces with genvar-dependent parameters (fullname 2 records), vi11 an interface
   port view of a program (fullname), vi14 direct / generate / direct interface instances (fullname), vi06 a nested
   interface (stage 1).
4. VR/vr01 `K::N` (a class nested in a module-scope class) and vr03 `$unit::LL` returns: stage 1 on both binaries,
   golden lists no class_typespec at the return; the law relocates ours to the scope prefix with nothing to compare.
5. VB/vb06 `bind tgt: u_t2 ...` exits 139 on pristine and law (a crash, not decoded); VB/vb04 bind into an interface
   and VI/vi03 a top-level interface port exit 3.
6. VC/vc01 a concatenation left side in a definition-view comma list (stage 1; elaborated view endcol -> col).

## Process

- Fence: every corpus path list was filtered by $FENCED (read fail-closed from tools/probe/r11u107repro/canaudit.sh)
  before any file was opened (bvmirror, the census filter, the binary-path audit, the control lists); no fenced
  source or database was read or dispatched outside the gate sweeps. Every tool variable was checked with `[ -x ]`.
- SLIP: the first byte-controls launch ran without STRICT_CMP exported; case.sh refused every line ("tool not
  executable", nothing written to a database), and its queued follow-up was drained by its own completion condition
  rather than signalled; both were rerun with the comparator set and only the rerun is reported. The first away
  census launch used a relative-path mistake (MISSING on every line) and a driver missing awayrows.py; both rerun.
- The fix firing census ran AFTER the fix sweep (the refinement was written after the law sweeps had been measured);
  the prediction (0 refinement firings on the gate) and the measurement (fix == law on every gate database) agree.
- No process was listed or signalled; nothing was written to the main tree. The sweeps exited 1 on the law-index
  check alone (the committed index is stale at the base); the delivered patch regenerates tests/LAWS.md.
- Drivers copied from tools/probe/r11u283repro/drivers (case.sh, grid.sh, gridsum283.py, away*.py, awaycv.sh,
  strictcmp_x.cpp, cc_x.sh, dscases.py, bvmirror.sh, det.sh, tracecensus.sh); fixgrid.sh, fixsum.py and controls.sh
  are new.
