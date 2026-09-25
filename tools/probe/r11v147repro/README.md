# r11v147 — adversarial verification of r11u147 (the expression/parameter ground, sixth refill, with r11u151's structural law)

Base `1fb349a9` (branch matrix-1.87). Worktrees `/tmp/wt_v11u147` (implementer patch + this verifier's fix) and
`/tmp/wt_v11u147pris` (pristine), system-deps config, `-j 2`, built one after the other. Scratch `/tmp/v11u147_*`.

**Verdict: ACCEPT WITH FIX.** Every headline number of r11u147 reproduces bit for bit. One law, § gcaUseSiteParamConst147,
turns a pristine-right database wrong on legal SV: a BARE parameter bound of a part-select that trails a var_select
in a loop-generate continuous assignment (`assign gB = PP[i-1][M:0];`). The verifier's refinement
§ gcaBareBoundKeepsInst147v (switch `R11V147_GCABARE_OFF`) fixes it. It moves no corpus row, probe case or downstream
row: against the implementer's binary its only differences are the four known UVM order-coin rows. The shipped patch is
`/tmp/r11u147.verified.patch`: the implementer's patch, this refinement, this directory and a regenerated tests/LAWS.md.

| binary | md5 |
|---|---|
| pristine (worktree build of the base; byte-identical to the main tree's `build/slang-uhdm`) | `0d37333d17a0a6bc3c0f0e8fbfe21f8a` |
| implementer law (`/tmp/r11u147.patch` as shipped) | `d1b102e17317fc448653ec355f758fe0` (= the implementer's) |
| final (implementer law + § gcaBareBoundKeepsInst147v) | `6d5161ecf03a503ad01dfc29ed7c6236` |
| `build/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` (= the main tree's) |

Every binary was frozen (`chmod 555` copies) before any measurement. Every `cmds.txt` names its binary: pristine sweep
3273/3273 `pris`, law sweep 3273/3273 `law`, final sweep 3273/3273 `fix1`. The downstream lanes were audited through
multiplier's database. The law and final lanes' `slang.uhdm` equal the fix1 binary's own run with the downstream
flags (`d71d12af…`), and pristine's differs (`eb291558…`).

## 1. Reproduction (implementer law binary, against the committed baselines; evidence/sweep_*.txt)

| stage | pristine sweep | implementer law | final (fix1) |
|---|---|---|---|
| probe EQUAL / STRICT_NOTEQUAL (of 4087) | 2352 / 1735, 0/0/0 | 2407 / 1680, regressions=0 conversions=55 changes=33 | same as law |
| surelog CMP_EQUAL (d + t) | 400 + 398, 0/0/0 | 402 + 400, regressions=0 conversions=4 changes=18 | same |
| uhdm2rtlil CMP_EQUAL (d + t) | 704 + 704, 0/0/0 | 717 + 717, regressions=0 conversions=26 changes=14 | same |
| downstream (871) | — | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2, not excused 0 | same; `downstream.csv` equals `results/downstream_uhdm2rtlil.csv` on every column |

- **uhdm-cmp.** The judge-equal statuses hold on every row (the status join has no regression). Every probe case
  stays judge-equal.
- **The conversion and change lists** in the law and final sweeps are line-for-line identical to the implementer's
  README. The conversions: surelog BlackParrotComplex d/t and the fenced row `FENCED_1` d/t; uhdm2rtlil
  latch_packed_dyn_write, mem_packed_2d_byte_write, unpacked_elem_partsel_comb, multiplier,
  SelectFromUnpackedInFunction, the four ParameterPassed… / SubmoduleInGenScope… rows, array_assign,
  def_ctx_struct_param, latch_decoder_partial and latch_tlb_napot, each d/t. Each converted row reads
  `CMP_EQUAL,,,equal` in the fresh csv, for example `multiplier,default,CMP_EQUAL,,,equal` and
  `BlackParrotComplex,testflags,CMP_EQUAL,,,equal`.
- **The only red** in any sweep is `law index STALE`, fixed by the regenerated tests/LAWS.md.
- **Byteverify** (`SELFCHECK=1 tools/probe/r11v75repro/byteverify.sh`, evidence/byteverify_*.txt):
  - law vs pristine: surelog `MOVERS: 34 / 960` (selfcheck 959/960) and uhdm2rtlil `MOVERS: 40 / 1608` (1607/1608),
    both `PATH_SETS_IDENTICAL`.
  - final vs law: surelog 6/960, all UVM order coins (see below); uhdm2rtlil 0/1608; probe 0/4087 byte movers.
  - final vs pristine: 34/960 and 40/1608, the same sets.
- **Every corpus mover appears by name in the implementer's census** (evidence of r11u147, `census_fires.txt`): 74/74.
- **Probe movers.** Path- and id-normalised uhdm-dump comparison gives 90/4087 law vs pristine (the implementer
  reports 91), all in the census. The census predicts 10 cases that do not move.
- **The UVM coin.** The final-vs-law movers MiniAmiq d/t, SeqDriver d/t and SimpleUVM d are the 4-line coin
  (`UINT:0`/`UINT:713` and `vpiDecompile:0`/`vpiDecompile:713`, order-blind 4 lines). Scoreboard d is the
  92-line list-order coin (0 lines order-blind).
- **Order-blind dump distance to golden** of the non-verdict corpus movers (lines, pristine -> law):

  | row (default mode) | pristine | law | by |
  |---|---|---|---|
  | BuildUVMPkg | 61108 | 61096 | LVIDXBS |
  | MiniAmiq | 471985 | 471959 | LVIDXBS |
  | Rggen | 68972 | 64092 | IFTRAILIDX |
  | Scoreboard | 113289 | 113273 | LVIDXBS |
  | Scr1SvTests | 1912 | 1892 | IFTRAILIDX + VSIPSBASE |
  | SeqDriver | 462415 | 462383 | LVIDXBS |
  | SimpleUVM | 114135 | 114123 | LVIDXBS |
  | YosysOldOr | 2489 | 417 | FIRSTPOS |

  Every one moves toward golden.
- **Counts that grow on a still-failing row** (caution c), first record and structural divergence (`#N depth/type`)
  read with `uhdm-strictcmp`:
  - FuncStructVal default `endcol(165) -> (207)`: first record #747 on both; the walk diverges later (#7595 -> #7975),
    and our object count moves closer to golden's (16134 -> 17934 of 18222).
  - FuncStructVal testflags `(377) -> (363)`: the count shrinks, but the divergence moves EARLIER (#14385 -> #13254).
    This is r11u151's recorded R-D4, not a column worsening.
  - StructParamFieldRange d/t `endcol(5) -> (9)` and StructParamPatternInitCast d/t `fullname(2) -> (17)`: pristine
    "walk diverged" at the same first record (#157, #67); the law aligns the walk (unmasking).
  - FuncStructValSimple d/t: pristine "walk diverged, objects 669 vs 657", law aligned, same first record #117.
  - The 30 `r11u109repro/grid/f1` probe changes: pristine "walk diverged" on every one, law aligned on 29.
    `p03_ready` diverges later (#126 -> #284).
- **Canaries** (evidence/canaries.txt, final csvs):
  - `canaries.sh` surelog: ok=44 changed=8 (BlackParrotComplex d/t = the conversion; FuncStructVal, Earlgrey_0_1 and
    YosysOldOr d/t = the attributed changes). uhdm2rtlil: ok=16 changed=0.
  - `EXPECT_UNKNOWN=1 ctcan2.sh` surelog: the FAIL is BlackParrotComplex d/t alone (the claimed conversion).
  - `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil: PASS.
- **Grids.** The r11u147 grid (68 cases, evidence/grid_r11u147_pristine_vs_law.txt) reproduces every verdict of the
  implementer's table: 44 -> STRICT_EQUAL, `mec/f02 f03` stage 1 -> judge-equal, 15 controls unmoved, 7 still failing
  with fewer or equal objects, all rc=0 and uhdm-cmp 0 lines on the law binary. The r11u151 grid (67 cases, copied to
  scratch from the main tree's tools/probe/r11u151struct/cases): 14 -> STRICT_EQUAL, none leaves STRICT_EQUAL
  (evidence/grid_r11u151_pristine_vs_law.txt).
- **The r11u151 part of the patch** was compared file by file against `law_after_r11u145.patch` applied to the base.
  The only differences are the r11u147 hunks and `r11u151On` also reading `R11U147_OFF`. StmtEmit.cpp's hunks are
  r11u151's ARRNB law, byte-identical to its patch; the implementer README's "src/StmtEmit.cpp untouched" means
  untouched by r11u147's own laws.
- **Earlier passes' cases as byte controls** (drivers/bytes.sh, fence-filtered, fail closed;
  evidence/controls_earlier_passes.txt): 21 movers / 2088 cases in 25 directories, the implementer's count. Every
  mover's verdict:
  - r11v124 q07 endcol -> STRICT_EQUAL.
  - r11v140 t01 file -> STRICT_EQUAL.
  - r11u143 fence_s3 f05 stage 1 -> STRICT_EQUAL; f03 stage 1 -> judge-equal.
  - f01, f02 and f04: 16 -> 64 uhdm-cmp lines, stage 1 on both. This is an unmasking. The new head
    (`cont_assign > hier_path(Cfg.mode)`, golden a folded constant) reads the same 64 lines on PRISTINE for the
    same shape without the import (`brk/mec/c8_same_pkg_member_read_ctl`).
  - Every other mover keeps its verdict and its uhdm-cmp line count.

## 2. The break: § gcaUseSiteParamConst147 on a bare part-select bound

Clause (b) of `gcaUseSiteParamRead147` compiles a module-parameter read at the use site whenever the read sits in the
bound of a part-select trailing an unqualified var_select, at any depth, including a bare bound. Golden names a BARE
bound through the instance, exactly as clause (a) already rules for a bare replication count:

    module top #(parameter M = 4, parameter N = 3)(input [M-1:0] A, output [M+N-1:0] P);
    ...
    for (i=1; i < N; i=i+1) begin: g
      wire [M:0] gB;
      assign gB = PP[i-1][M:0];        // brk/mul/g1_bare_bound_vs

    pristine  STRICT_EQUAL 246 objects
    law       #169 fullname  A: ref_typespec work@top   B: ref_typespec work@top.g[1].PP.PP
              #208 fullname  A: ref_typespec work@top   B: ref_typespec work@top.g[2].PP.PP   (2 GCAUSESITE firings)

`brk/mul/g7_bare_right_bound` (`P[i] = PP[i][M:1]`) breaks the same way: STRICT_EQUAL -> fullname(2). An operation
bound is golden's use-site form. `g8` (`PP[i][M-1:0]`, pristine fullname(2) -> STRICT_EQUAL) and `g12`
(`PP[i][M+i:i]`) confirm the implementer's clause there.

**§ gcaBareBoundKeepsInst147v** (ExprEmit.cpp `gcaUseSiteParamRead147`, clause (b); switch `R11V147_GCABARE_OFF`,
dropped by `R11U147_OFF` or `R11U147_GCAUSESITE_OFF` with the law it refines). Clause (b) fires only when at least
one operation stands between the read and the part-select; a bare bound keeps the instance's constant. Results:

- g1 and g7 are STRICT_EQUAL again (0 firings).
- k1-k9 and g8/g12 keep their conversions.
- The corpora and probe bytes are unchanged against the implementer's binary: 0/1608 uhdm2rtlil, 0/4087 probe, and
  surelog 6/960, the UVM coin only. No corpus row carries the bare shape, which is why the implementer's gates could
  not see it.

## 3. Breaking the other laws: fresh instances (brk/, 89 cases, pristine / law / final)

| law | fresh cases -> STRICT_EQUAL | unmoved or shrunk | pristine-right -> law-wrong |
|---|---|---|---|
| § ifaceMemberTrailIdxNamesByPath147 | x1 x2 x3 x6 x9 (op of two vars, struct member array, modport process op, function body, parameter in the op) | x4 (4 -> 2), x5 ctl, x7 x8 stage 1 unmoved | none |
| § vsIpsBaseNamesByIps147 | y1 y2 y4 y5 y6 y7 y8 y10 y11 y12 y13 y14 (member, call, `-:`, 3-D, cast, parameter product, continuous assign, unpacked, generate, variable first index, nonblocking lvalue, function body) | y3 cond (8 -> 2), y9 y15 ctl | none |
| § lvIdxBitSelAtIndex147 | z1 (stage 1 -> equal with ARR) z2 z4 z6 z7 z10 z11 z12 (nonblocking, concat lvalue, loop, arithmetic index, nested, unpacked target, queue/assoc) | z5 member lvalue (col gone, fullname 2 stays), z8 z9 ctl | none |
| § nestedDefaultPatLoc147 | n5 n8 | n7 (6 -> 2), n3 stage 1 unmoved | none (slang rejects deeper nestings; two shapes crash Surelog, not kept) |
| § gcaUseSiteParamConst147 | g8 g12 | g2 g9 g3 (10 -> 4), g4 g5 g10 ctl, g6 g11 stage 1 | **g1 g7 (fixed by § gcaBareBoundKeepsInst147v)** |
| § firstOrderedConnBitSelWhole147 | w2 w3 w8 (override, two instances per statement, output first) | w7 (col(3) -> fullname(2); downstream EQUIVALENT -> IDENTICAL), w10 (5 -> 3), w1 w9 w12 w13 ctl, w4 w5 w6 w11 w14 stage 1 | none |
| § memberEnumCloneKeepsBase147 | c2 (stage 1 -> equal) | c4 stage 1 -> judge-equal, c1 stage 1 16 -> 30 lines (unmasking: the next head is a decompile `3'd4` vs golden `4` that pristine's dump already carries), c5 c6 stage 1 same head, c3 c7 c8 ctl | none |
| § enumQualDefaultDefSpan147 | r3 (`pk :: B`) | r4 r6 stage 1 (the fired constants move to golden's `pk::` span, dump-checked), r1 r2 r5 r7 unfired | none |
| r11u151 ARR / ARRNB | h5 h9 (nonblocking whole ref in an if; non-ANSI reg) | h2 formal written by var_select stage 1 (binding moves TO golden's `var_select`, dump-checked), h1 h3 h4 h6 h7 h8 ctl | none |

**Downstream** (`downstream_uhdm2rtlil.one` on all 68 + 89 cases, fresh GOLDEN_CACHE, evidence/downstream_cases.txt):

- Nothing leaves IDENTICAL.
- `ipb/f7`, `pos/n5` and `brk/pos/w7` move EQUIVALENT -> IDENTICAL.
- The non-identical rows are the same on both binaries: `brk/arr/h2` DIVERGENT, `brk/tsi/x7` DIVERGENT,
  `brk/qen/r1` STATUS_DIFF, `y3 r2 r4 x8` EQUIVALENT.

**Switches** (drivers/sw.sh on 223 cases = both grids + brk; evidence/switch_matrix_md5.txt, switch_ownership.txt):

- `R11U147_OFF=1` restores pristine bytes on all 223.
- Each single switch moves only its own subdirectory: VSIPSBASE ipb, LVIDXBS ipb + brk/lvi, IFTRAILIDX tsi, NESTDEFLOC
  dfp, GCAUSESITE mul, FIRSTPOS pos, ENUMCLONE mec, ENUMQSPAN qen, `R11V147_GCABARE_OFF` brk/mul g1 g7 only.
- `R11U151_ARR_OFF` also owns `ipb/d1 d4` and `brk/lvi/z1` (the ARR composition).
- Each `R11U151_*` switch owns its own class of the r11u151 grid.

## 4. Residues (ranked; decoded by the implementer, re-checked where noted)

1. r11u151's own: C3, R-D1..R-D4, R-ARR2, G2 h01/h03/h05. FuncStructVal testflags' earlier divergence is R-D4.
2. StringMethod (method-call argument names plus the structural binding), R2 of the implementer.
3. Interface and member path names: the implementer's R3 a-f, plus `brk/tsi/x4` (a top-level interface in a generate
   block, 2 names left) and `brk/tsi/x7 x8` (a part-select index, an interface array: stage 1 on both binaries, and
   x7 is downstream DIVERGENT on both).
4. Sister ground, not this ground's to fix, decoded by the implementer with call sites: S1 (the port-view
   param_assign span, ModuleEmit `emitInterfaceInstance`), S2 (PortInitVal*, sat_asserts_seq; possibly pass 146's
   subject), S3 (genscope_module_ctx_reset, ModuleEmit `emitInstance`), S4 (PatternStruct), S5 (C3 `cfn9`),
   S6 (the def-view gen_for, TypeEmit `emitSyntaxExpr`), S7 (enum alias, TypeEmit `buildEnumTs`).
5. The unmasked fold face on package-struct member reads (`assign o = Cfg.mode`: golden folds the elaborated read,
   ours keeps the hier_path; 64 lines on pristine: `brk/mec/c8`, r11u143 fence_s3 f01 f02 f04). It is now the head
   of those cases, and the next target for the S3 family.
6. The member-select decompile (`3'd4` vs golden `4`, `brk/mec/c1`).
7. A function formal written by a var_select: downstream DIVERGENT on both binaries (`brk/arr/h2`), a pre-existing
   consumer face worth its own pass.
8. The pass-145 R5/V5 items the implementer did not reach.

## 5. Ops

- **Fence.** No fenced source was read, scanned or dispatched outside the gate sweeps, which dispatch every baseline
  row, so the fenced surelog row ran under `tests/sweep.sh` like any other. Its only reads are its sweep verdicts; its
  name is redacted to `FENCED_1` in every evidence file. drivers/bytes.sh and drivers/rc.sh fail closed on `$FENCED`
  (drivers/env.sh builds it from RESUME.md without spelling it). The fence check on the shipped patch reads 0/0/0/0.
- **The implementer's incidents** (the killed r11u153 `uhdm-dump`, the seven `.gpath` files) are not re-checkable
  here beyond this: the main tree's `git status` is clean.
- **This pass wrote only** under its worktrees and `/tmp/v11u147_*`. It ran our binaries in one corpus test directory
  of the main tree (multiplier, `-o` to /tmp) and in the r11u151 cases copied to scratch.

## 6. Cases (first line of every case names its law; pristine / implementer law / final)

| case | law (first line) | pristine | implementer law | final (fix1) |
|---|---|---|---|---|
| `brk/arr/h1_formal_vs_read` | § blockLhsVarSelBindsWholeRef151 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/arr/h2_formal_vs_write` | § blockLhsVarSelBindsWholeRef151 | rc=0 cmp=62 stage1 | rc=0 cmp=62 stage1 | rc=0 cmp=62 stage1 |
| `brk/arr/h3_vs_in_if_arm` | § blockLhsVarSelBindsWholeRef151 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/arr/h4_vs_nested_begin_ref_outer` | § blockLhsVarSelBindsWholeRef151 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/arr/h5_nb_vs_ref_in_if` | § nonblockingSelLhsBindsWholeRef151 | rc=0 cmp=0 SN depth(1) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/arr/h6_nb_case_ctl` | § nonblockingSelLhsBindsWholeRef151 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/arr/h7_nb_two_blocks` | § nonblockingSelLhsBindsWholeRef151 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/arr/h8_nb_fork` | § nonblockingSelLhsBindsWholeRef151 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/arr/h9_nb_reg_nonansi` | § nonblockingSelLhsBindsWholeRef151 | rc=0 cmp=0 SN depth(1) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/dfp/n3_inner_keyed` | § nestedDefaultPatLoc147 | rc=0 cmp=124 stage1 | rc=0 cmp=124 stage1 | rc=0 cmp=124 stage1 |
| `brk/dfp/n5_inner_positional` | § nestedDefaultPatLoc147 | rc=0 cmp=0 SN file(1) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/dfp/n7_func_local` | § nestedDefaultPatLoc147 | rc=0 cmp=0 SN endcol(6) | rc=0 cmp=0 SN endcol(2) | rc=0 cmp=0 SN endcol(2) |
| `brk/dfp/n8_proc_nested` | § nestedDefaultPatLoc147 | rc=0 cmp=0 SN file(4) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y10_unpacked_vs` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y11_gen_vs` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(4) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y12_var_first_idx` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y13_lhs_nb` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y14_func_body` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y15_member_vs` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y1_member_base` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y2_call_base` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y3_cond_base` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN col(8) | rc=0 cmp=0 SN col(2) | rc=0 cmp=0 SN col(2) |
| `brk/ipb/y4_minus_idx` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y5_three_dim` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y6_cast_base` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(4) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y7_param_mul_base` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(4) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y8_ca_vs_op` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/ipb/y9_const_base_ctl` | § vsIpsBaseNamesByIps147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/lvi/z10_ff_nested_bs` | § lvIdxBitSelAtIndex147 | rc=0 cmp=0 SN col(4) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/lvi/z11_unpacked_target` | § lvIdxBitSelAtIndex147 | rc=0 cmp=0 SN col(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/lvi/z12_class_like_queue` | § lvIdxBitSelAtIndex147 | rc=0 cmp=0 SN col(4) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/lvi/z1_first_dim` | § lvIdxBitSelAtIndex147 | rc=0 cmp=72 stage1 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/lvi/z2_nonblocking` | § lvIdxBitSelAtIndex147 | rc=0 cmp=0 SN col(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/lvi/z4_concat_lhs` | § lvIdxBitSelAtIndex147 | rc=0 cmp=0 SN col(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/lvi/z5_member_lhs` | § lvIdxBitSelAtIndex147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 SN fullname(2) |
| `brk/lvi/z6_for_loop` | § lvIdxBitSelAtIndex147 | rc=0 cmp=0 SN col(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/lvi/z7_arith_in_idx` | § lvIdxBitSelAtIndex147 | rc=0 cmp=0 SN col(4) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/lvi/z8_plain_target_ctl` | § lvIdxBitSelAtIndex147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/lvi/z9_task_output` | § lvIdxBitSelAtIndex147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/mec/c1_explicit_vals` | § memberEnumCloneKeepsBase147 | rc=0 cmp=16 stage1 | rc=0 cmp=30 stage1 | rc=0 cmp=30 stage1 |
| `brk/mec/c2_two_members` | § memberEnumCloneKeepsBase147 | rc=0 cmp=16 stage1 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/mec/c3_union` | § memberEnumCloneKeepsBase147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/mec/c4_var_only` | § memberEnumCloneKeepsBase147 | rc=0 cmp=16 stage1 | rc=0 cmp=0 SN fullname(7) | rc=0 cmp=0 SN fullname(7) |
| `brk/mec/c5_three_pkgs` | § memberEnumCloneKeepsBase147 | rc=0 cmp=410 stage1 | rc=0 cmp=410 stage1 | rc=0 cmp=410 stage1 |
| `brk/mec/c6_no_base_int` | § memberEnumCloneKeepsBase147 | rc=0 cmp=26 stage1 | rc=0 cmp=26 stage1 | rc=0 cmp=26 stage1 |
| `brk/mec/c7_member_typedef_of_enum_ctl` | § memberEnumCloneKeepsBase147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 SN fullname(2) |
| `brk/mec/c8_same_pkg_member_read_ctl` | § memberEnumCloneKeepsBase147 | rc=0 cmp=64 stage1 | rc=0 cmp=64 stage1 | rc=0 cmp=64 stage1 |
| `brk/mul/g10_nested_gen` | § gcaUseSiteParamConst147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/mul/g11_pkg_count` | § gcaUseSiteParamConst147 | rc=0 cmp=60 stage1 | rc=0 cmp=60 stage1 | rc=0 cmp=60 stage1 |
| `brk/mul/g12_bare_bound_left_op_right` | § gcaUseSiteParamConst147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/mul/g1_bare_bound_vs` | § gcaBareBoundKeepsInst147v | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL |
| `brk/mul/g2_ips_vs` | § gcaUseSiteParamConst147 | rc=0 cmp=0 SN fullname(1) | rc=0 cmp=0 SN fullname(1) | rc=0 cmp=0 SN fullname(1) |
| `brk/mul/g3_repl_mul` | § gcaUseSiteParamConst147 | rc=0 cmp=0 SN col(10) | rc=0 cmp=0 SN col(4) | rc=0 cmp=0 SN col(4) |
| `brk/mul/g4_repl_in_proc_ctl` | § gcaUseSiteParamConst147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/mul/g5_repl_in_ca_nogen` | § gcaUseSiteParamConst147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/mul/g6_param_in_count_call` | § gcaUseSiteParamConst147 | rc=0 cmp=44 stage1 | rc=0 cmp=44 stage1 | rc=0 cmp=44 stage1 |
| `brk/mul/g7_bare_right_bound` | § gcaBareBoundKeepsInst147v | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL |
| `brk/mul/g8_op_bound_noidx` | § gcaUseSiteParamConst147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/mul/g9_proc_in_gen_ctl` | § gcaUseSiteParamConst147 | rc=0 cmp=0 SN fullname(3) | rc=0 cmp=0 SN fullname(3) | rc=0 cmp=0 SN fullname(3) |
| `brk/pos/w10_modarr` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=0 SN endcol(5) | rc=0 cmp=0 SN endcol(3) | rc=0 cmp=0 SN endcol(3) |
| `brk/pos/w11_gen_if_block` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=26 stage1 | rc=0 cmp=26 stage1 | rc=0 cmp=26 stage1 |
| `brk/pos/w12_first_varsel` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=0 SN endcol(3) | rc=0 cmp=0 SN endcol(3) | rc=0 cmp=0 SN endcol(3) |
| `brk/pos/w13_first_partsel` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/pos/w14_nested_parent` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=26 stage1 | rc=0 cmp=26 stage1 | rc=0 cmp=26 stage1 |
| `brk/pos/w1_empty_first` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/pos/w2_param_override` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=0 SN col(1) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/pos/w3_two_insts_one_stmt` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=0 SN col(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/pos/w4_gen_op_idx` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=26 stage1 | rc=0 cmp=26 stage1 | rc=0 cmp=26 stage1 |
| `brk/pos/w5_iface_ordered` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=322 stage1 | rc=0 cmp=322 stage1 | rc=0 cmp=322 stage1 |
| `brk/pos/w6_first_in_op` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=338 stage1 | rc=0 cmp=338 stage1 | rc=0 cmp=338 stage1 |
| `brk/pos/w7_first_var_idx_mod` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=0 SN col(3) | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 SN fullname(2) |
| `brk/pos/w8_output_first` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=0 SN col(1) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/pos/w9_gate_prim_ctl` | § firstOrderedConnBitSelWhole147 | rc=0 cmp=0 SN col(4) | rc=0 cmp=0 SN col(4) | rc=0 cmp=0 SN col(4) |
| `brk/qen/r1_pkg_localparam` | § enumQualDefaultDefSpan147 | rc=0 cmp=44 stage1 | rc=0 cmp=44 stage1 | rc=0 cmp=44 stage1 |
| `brk/qen/r2_iface_param` | § enumQualDefaultDefSpan147 | rc=0 cmp=48 stage1 | rc=0 cmp=48 stage1 | rc=0 cmp=48 stage1 |
| `brk/qen/r3_spaces` | § enumQualDefaultDefSpan147 | rc=0 cmp=0 SN endcol(1) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/qen/r4_int_typed` | § enumQualDefaultDefSpan147 | rc=0 cmp=16 stage1 | rc=0 cmp=16 stage1 | rc=0 cmp=16 stage1 |
| `brk/qen/r5_gen_localparam` | § enumQualDefaultDefSpan147 | rc=0 cmp=62 stage1 | rc=0 cmp=62 stage1 | rc=0 cmp=62 stage1 |
| `brk/qen/r6_untyped` | § enumQualDefaultDefSpan147 | rc=0 cmp=16 stage1 | rc=0 cmp=16 stage1 | rc=0 cmp=16 stage1 |
| `brk/qen/r7_param_ref_ctl` | § enumQualDefaultDefSpan147 | rc=0 cmp=58 stage1 | rc=0 cmp=58 stage1 | rc=0 cmp=58 stage1 |
| `brk/tsi/x1_op_two_vars` | § ifaceMemberTrailIdxNamesByPath147 | rc=0 cmp=0 SN fullname(4) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/tsi/x2_struct_member_arr` | § ifaceMemberTrailIdxNamesByPath147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/tsi/x3_modport_proc_op` | § ifaceMemberTrailIdxNamesByPath147 | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/tsi/x4_top_inst_gen` | § ifaceMemberTrailIdxNamesByPath147 | rc=0 cmp=0 SN fullname(4) | rc=0 cmp=0 SN fullname(2) | rc=0 cmp=0 SN fullname(2) |
| `brk/tsi/x5_const_idx_ctl` | § ifaceMemberTrailIdxNamesByPath147 | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/tsi/x6_task_body` | § ifaceMemberTrailIdxNamesByPath147 | rc=0 cmp=0 SN fullname(4) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |
| `brk/tsi/x7_partsel_idx` | § ifaceMemberTrailIdxNamesByPath147 | rc=0 cmp=146 stage1 | rc=0 cmp=146 stage1 | rc=0 cmp=146 stage1 |
| `brk/tsi/x8_iface_array` | § ifaceMemberTrailIdxNamesByPath147 | rc=0 cmp=36 stage1 | rc=0 cmp=36 stage1 | rc=0 cmp=36 stage1 |
| `brk/tsi/x9_param_idx_op` | § ifaceMemberTrailIdxNamesByPath147 | rc=0 cmp=0 SN fullname(4) | rc=0 cmp=0 STRICT_EQUAL | rc=0 cmp=0 STRICT_EQUAL |

Files: `brk/` (the 89 cases), `drivers/` (`env.sh`, `rc.sh` one case on N binaries with a Surelog golden,
`sw.sh` switch matrix, `bytes.sh` earlier-pass byte controls, `pdump.sh` normalised probe comparison, `dist.sh`
order-blind distance, `first.sh` first strict records of a sweep row, `ds.py` downstream verdict of cases),
`evidence/` (named above).
