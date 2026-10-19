# v11u410 — adversarial verification of r11u410 (module/type ground, sv-tests campaign pass 410)

Base 2aa103d1 (pass 408). The implementer's patch applies clean on a fresh
2aa103d1. The verifier rebuilt the law binary once from it: md5
7bdbdc7f885c6bd11cc2f74c8c1deb53, equal to the implementer's law27. The
pristine binary (md5 18a8b0bb50273c372eb97da9b304aa0c, equal to the main
tree's build at the base) was used only for the case grid. The pristine sweep
reading is the master's control at the base (/tmp/intr11u408).

VERDICT: the pass holds, with ONE production refinement. Fresh cases found one
field that pristine had right and the law gets wrong: the size of a binary
literal wider than its class property.

## The refinement

| refinement | switch | file | what |
|---|---|---|---|
| § clsPropBinLitTrunc410v | R11V410_BINTRUNC_OFF (also R11V410_OFF) | UhdmExporter.cpp, inside § classPropBasedLitKept410 | THE BREAK. Case VB/vb02: in `logic [3:0] d = 8'b10101010`, golden writes BIN:1010, decompile 1010, size 4. Pristine had size 4 (with UINT:170). The law wrote BIN:10101010, decompile 8'b10101010, size 8, so the size moved away from golden. Golden's rule is Surelog's adjustSize (CompileHelper.cpp, the vpiBinaryConst branch), for a binary literal wider than the property: (a) under a logic_typespec (a logic or reg scalar or vector, also through a typedef or signed), the constant is cut to the property width; the leading digits are dropped only when there are more digits than the excess (`8'b101` gives BIN:101 at size 4). (b) Under an int_typespec only the size drops to 32, and the digits are kept. A bit vector or another atom keeps the literal's size (vb07). |

Grid for the refinement (law -> verified):
- VB/vb02: NOT_EQUAL -> STRICT_EQUAL.
- VB/vb05: NOT_EQUAL -> STRICT_EQUAL.
- VB/vb09: NOT_EQUAL -> STRICT_EQUAL. This covers a $unit logic typedef, int, int unsigned and integer.
- VB/vb08: NOT_EQUAL, 29 -> 7 dump lines. The one remaining line is the pre-existing missing vpiSigned on a `logic signed` class property, which is the same on pristine.
- VB/vb01, vb03, vb04, vb06, vb07 and the implementer's CB/cb01–cb03: byte-identical to the law.

The refinement fires on no corpus row, probe case or sv-tests row. The sweep
trace has no `clsPropBinLitTrunc410v` line. So the verified binary's bytes equal
the law's on every row of the sweep. R11V410_OFF and R11V410_BINTRUNC_OFF each
give the law's bytes on the VB and CB cases.

## Reproduction of the implementer's numbers (one five-stage sweep on the verified binary)

The verified binary is md5 8c75792fa662ab6667e792c268d1adab. Its
R11U410_TRACE was set for the whole sweep. The four corpus stages ran through
tests/sweep.sh from this worktree. The sv-tests stage ran through the main
tree's scripts/check_svtests.py, read-only, with `--baseline` set to the base's
results/golden_svtests.csv (a worktree has no UVM tree). See drivers/sweep.sh.
Before launch, pgrep showed no other sweep. The sweep exited 1 only because the
law index was stale with the refinement's new section; the index is regenerated
in this patch.

- **probe:** EQUAL 4018 + STRICT_NOTEQUAL 69, regressions=0 conversions=0 changes=0. probe.csv is byte-identical to results/golden_probe.csv.
- **surelog:** default CMP_EQUAL 480, testflags 474, 0/0/0. The csv differs from the control only in the two LowMem log-path detail texts.
- **uhdm2rtlil:** 803/1/67 in both modes, 0/0/0. The csv is identical to the control.
- **downstream:** IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0. Not identical and not excused: 0. The csv is identical to the control.
- **byteverify** against the master's control (SELFCHECK=1, path sets identical): surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805. The prediction (zero firings of any pass-410 law outside sv-tests) holds: the trace dir got no file during the four corpus stages. The harness passes the environment through (no `env=` in verify_golden.py, check_probe.py or downstream_uhdm2rtlil.py), and the same mechanism wrote 33 trace files in the sv-tests stage, which is the positive control.
- **canaries:** ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil). ctcan2 EXPECT_UNKNOWN=1 PASS and EXPECT_UNKNOWN=6 PASS.
- **binary audit** (fence-filtered cmds.txt):
  - surelog: 1573, of which 1523 name the verified binary, 0 name another and 50 hold no slang line.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346.
  - downstream keeps no command record; its 805 databases are byte-identical to the control's.
- **sv-tests:** BOTH_REJECT 303, DIFFERENT 279 -> 256, EQUAL 1641 -> 1663, SLANG_ONLY 19, STRICT_NOTEQUAL 20 -> 21, SURELOG_CRASH 8, SURELOG_ONLY 75, TIMEOUT 1 of 2346. **regressions=0 conversions=25 changes=0.** The csv is identical to the implementer's law27 csv on all 2346 rows, and differs from the control's on exactly the 25 converted rows. These are the implementer's 25, with the same laws by trace (evidence/trace_census_svtests.txt):
  - **22 EQUAL:**
    - 22.4--include_via_define and 22.5.1--include-define-expansion: § macroIncludeCol410.
    - bsg_cache_dma_to_wormhole, bsg_wormhole_to_cache_dma_fanout and _inorder: § modStructMemberBitsTypeFold410.
    - bsg_parallel_in_serial_out, bsg_cam_1r1w_replacement, bsg_encode_one_hot, bsg_hash_bank, bsg_hash_bank_reverse and bsg_nonsynth_dramsim3_unmap: § genLpUntypedDefNoTs410.
    - bsg_round_robin_n_to_1, bsg_decode, bsg_mesh_router_decoder_dor and bsg_nonsynth_ramulator_hbm: § parenCastNameUnsupTs410.
    - class_test_56, 57 and 58: § classPropBasedLitKept410 + § unitTdClassPropAliasName410.
    - class_member_test_18: § oobUnitClsTdUnsupported410.
    - class_member_test_19: § oobUnitClsTdUnsupported410 + § clsMethodDimRefColons410.
    - typedef_test_8 and typedef_test_14: § unitScalarTdAliasChain410.
  - **3 DIFFERENT -> STRICT_NOTEQUAL:**
    - bsg_mesh_router, col(2): genLp.
    - bsg_wormhole_router, fullname(1): genLp.
    - bsg_link_ddr_upstream, col(2): paren cast.
  - **Other firings, no status change:**
    - bsg_wormhole_router_decoder_dor (genLp): normalised dump distance to golden 7674 -> 7666.
    - The six black-parrot rows and rsd: SURELOG_CRASH.
  - **Away census on the firing rows that are not EQUAL:** 0 away. Distances (control -> verified): wormhole_router_decoder_dor 7674 -> 7666, mesh_router 8706 -> 8698, wormhole_router 8044 -> 8028, link_ddr_upstream 7731 -> 7720.
- **goal-1 census** of results/golden_svtests.csv at the base: all 75 SURELOG_ONLY rows carry a slang front-end diagnostic (`<file>:<line>:<col>: error:`). None is an exporter message. This agrees with the implementer.

The heads of the three new STRICT_NOTEQUAL rows (decoded here, not decoded by
the implementer):

- **bsg_mesh_router, bsg_link_ddr_upstream (sister ground):** a bit_select in an elaborated port actual. Golden spans the index alone (bsg_defines.sv 143:57-58; bsg_mesh_router.sv 174:45-46; bsg_link_ddr_upstream.sv 213:30-31 and 213:46-47). Ours spans the whole select (143:40-59). This is the elaborated port actual's select span, emitted by ExprEmit.
- **bsg_wormhole_router (this ground):** in a module-body struct typedef from bsg_wormhole_router.svh 10:10-36, a bit_select `cord_markers_pos_p`. Golden's full name is `work@bsg_wormhole_router.bsg_wormhole_router_header_s.cord.cord_markers_pos_p`; ours lacks the `work@<module>.` prefix. This is TypeEmit's module-body struct member dimension.

## Attack grid (64 case dirs in 13 groups; evidence/grid.txt)

Golden is the pinned Surelog `-parse -nobuiltin -nocache -sv dut.sv`. Ours is
`dut.sv --single-unit --nobuiltin` (drivers/run1.sh, drivers/grid.sh). Each
line carries pristine, law and verified readings with exit codes, plus three
checks: R11U410_OFF (on the law binary) against pristine, the group's own law
switch against pristine, and R11V410_OFF (on the verified binary) against the
law.

| group | law | cases |
|---|---|---|
| VA | § unitScalarTdAliasChain410 | va01 signed vector, va02 three-link bit chain, va03 2-D packed, va04 packed dims on the alias (control), va05 port/function uses, va06 reg + unpacked use, va07 logic scalar used by a function, a class and ports |
| VB | § classPropBasedLitKept410 / § clsPropBinLitTrunc410v | vb01–vb04 widths, bases, package, static/const, module-scope class; vb05–vb09 wider/narrower literals per property type |
| VC | § unitTdClassPropAliasName410 | vc01 int/vector/static, vc02 class in a module, vc03 string/real/rand/array/local + extends |
| VD | § clsMethodDimRefColons410 | vd01 `[N-1:0]`, `[0:N]`, task; vd02 module subroutine control + class in a module; vd03 package class out-of-body |
| VG | § genLpUntypedDefNoTs410 | vg01 string, vg02 sized literal + fold, vg03 real + $clog2 in a loop, vg04 interface, vg05 case generate with typed/ranged siblings, vg06 typed module parameters + nested generate, vg07 `parameter` in a loop, 'h3, 1'b1 |
| VM | § macroIncludeCol410 | vm01 two blanks, vm02 tabs, vm03 directive inside a macro body via a nested stringify macro, vm04 macro with an argument |
| VO | § oobUnitClsTdUnsupported410 | vo01 vector return + formal, vo02 unpacked-array + string, vo03 task (control), vo04 alias of a $unit typedef |
| VP | § parenCastNameUnsupTs410 | vp01 module item (typed parameter), vp02 `((W))` in always_comb in a generate block, vp03 function, vp04 a generate localparam, vp05 genvar, vp06 overridden instances, vp07 parenthesized typedef and type parameter, vp08 function inside a generate block |
| VQ | § classBoundedQueueMultiDim410 | vq01 `[$:3][$:2]`, `[$][$:2]`, `[3][$]`; vq02 logic vector, string, `[2][3][$]`; vq03 parameter bound, `[2][]`, `[2][$:N]`, rand |
| VS | § modStructMemberBitsTypeFold410 | vs01 enum, vs02 struct typedef, vs03 `$bits(<localparam>)` (control), vs04 interface, vs05 packed union |
| VU | § unitBoundedQTd410 | vu01 byte + logic vector, vu02 enum + real-typedef element, vu03 module-body bounded queue used procedurally |
| VV | § modVirtIfaceTd410 | vv01 modport, vv02 array + function formal + class property, vv03 parameterized interface, vv04 the $unit twin of an array (control), vv05 the module array alone |
| VY | § dynTdAliasClone410 | vy01 dynamic, vy02 a three-link associative chain, vy03 module-body queue + associative |

Results, pristine -> verified:
- NOT_EQUAL -> STRICT_EQUAL: 16.
- exit 4 -> exit 0 STRICT_EQUAL: 7 (vq01–vq03, vu01, vv03, vy01, vy03).
- STRICT_NOTEQUAL -> STRICT_EQUAL: 5 (vc01, vc02, vd02, vm01, vm02).
- exit 4 -> exit 0 NOT_EQUAL: 4 (vu03, vv01, vv02, vv05).
- exit 4 on both: 3, with the verified closer to golden on all three:
  - vu02: a real-typedef element; the law abstains.
  - vy02: a three-link alias of an associative typedef, `typedef b_t c_t;` where b_t is itself a clone.
  - vp05: `(i)'(x)` with a genvar `i` in a generate loop. The message is `expression kind: Invalid`, a goal-1 face, and upstream slang accepts the case. It is the elaborated cast (ExprEmit), the sister's ground; see below.
- STRICT_EQUAL on both: 3 controls (va04, vo03, vs03), byte-identical.
- STRICT_NOTEQUAL on both: 2. vm03 moves from col to endcol (law partial). vp03 is byte-identical.
- NOT_EQUAL on both: 24.

Checks:
- No exit code worsens. No case leaves an equal status.
- R11U410_OFF gives pristine's bytes and exit code on 64 of 64.
- The group's own switch does so on 62. The other two need a two-switch set (evidence/switchsets.txt):
  - VB/vb09: + R11U410_UNITCLSPROPALIAS_OFF.
  - VP/vp04: + R11U410_GENLPNOTS_OFF.
- R11V410_OFF gives the law's bytes on 64 of 64.
- **Away census** (normalised dump lines to golden, pristine -> verified; evidence/away_census.txt): 55 toward, 9 at the same count, 0 away.
- Two cases grow in uhdm-cmp line count while moving toward golden. In both the head moved later in the walk:
  - va05: 74 -> 128, distance 140 -> 130.
  - va06: 17 -> 58, distance 117 -> 81.

Downstream on the 40 class-free cases (drivers/ds.py, the HEAD harness;
evidence/downstream_cases.txt), pristine -> verified:
- 9 improve to IDENTICAL: va01, va03, va05, vs04, vs05, vu01, vu03, vy01, vy03 (from EQUIVALENT).
- All other cases keep their verdict, except two that move EQUIVALENT -> STATUS_DIFF: VV/vv02 and VV/vv05. See the first residue.

## Residues standing (ranked)

1. **The elaborated array of virtual-interface handles (pass 402's VV/vv01 face, now reached by § modVirtIfaceTd410).**
   - Golden lists `vi_t h [2]` as a plain logic_net in the definition and no net at all in the elaborated instance.
   - Ours lists an array_net whose element logic_net is typed by the interface_typespec. The uhdm2rtlil plugin then fails `width >= 0 && width < RTLIL::WIDTH_LIMIT` (rtlil.cc:3175).
   - The $unit twin VV/vv04 is STATUS_DIFF on pristine too.
   - The module twins vv02 and vv05 read EQUIVALENT on pristine only because pristine exited 4 and its partial database had no typespec. Pristine was not right (it rejected the case), so no fix was made here.
   - The fix belongs to the net emission for virtual-interface-typed unpacked arrays, in ModuleEmit / UhdmExporter, and serves both branches.
2. **Pre-existing faces on cases the laws newly accept:**
   - vm03: an `include written inside a macro body through a nested macro. Golden's end column is after the written macro call (`STR(inc.svh), 5:10-5:23); the law ends after the substituted name (5:19).
   - va06: an unpacked-array use of a vector alias typedef. Golden's listing span runs to the use's declaration (4:9-6:29).
   - vy02: a typedef of a cloned associative typedef, still exit 4.
   - vu02: a real-typedef element, still exit 4.
   - The implementer's AQ/aq05, aq09, aq11 and YA/ya04.
3. **vb08:** a `logic signed` class property lacks vpiSigned. Pristine has the same face.
4. **The implementer's residues** (UVM ParamEmit copy, `$bits(<struct>)` localparams, PC/pc25, pc26, p88, p124, OT/ot04, ot06, GP/gp06, gp07), confirmed unchanged.

## Sister-ground faces (reported, not written)

- **ExprEmit:** the elaborated port actual's bit_select span. Golden spans the index alone. Rows: bsg_mesh_router and bsg_link_ddr_upstream, now STRICT_NOTEQUAL on col.
- **ExprEmit:** the elaborated `(W)'(x)` cast typespec (VP/vp04, vp06, vp07; the implementer's PC/pc25, pc26).
- **ExprEmit, goal 1:** a size cast by a genvar in a generate loop, `(i)'(x)` (VP/vp05). It exits 4 with `expression kind: Invalid` on pristine and on the law, while upstream slang accepts it.

The module-body struct member select's full name in bsg_wormhole_router
(TypeEmit) is this ground's face, not the sister's.

## Process

- Fresh worktree /tmp/wt_v11u410 at 2aa103d1, scratch /tmp/v11u410_*. Nothing was written elsewhere. The pristine worktree was not built: the implementer's frozen pristine copy was used, with its md5 checked against the main tree's build at the base.
- Builds were at nice -j 2. Two builds: the law binary, equal to the implementer's, and the verified binary.
- One five-stage sweep, on the verified binary. No sweep ran while the builds or the grid ran. Light case runs were made before the sweep and after it.
- The binaries were frozen before measurement, and the cmds.txt files were audited by binary path.
- The fence list was read into a scratch file without printing. Every tree-wide cmds.txt list was filtered on it before any file was opened. No fenced test was named, run or read.
- No pkill and no pgrep -f was run against another agent's process. The sweep was waited on by its recorded PID.
