# v11u274 — adversarial verification of r11u274

The adversarial verification of pass 274 (the expression/parameter ground, `src/ParamEmit.cpp` behind
`src/R274.h`). Base b557d7d76. **Verdict: the law § pkgNetTsDimEnd274 BREAKS a pristine-right span on legal SV.**
With an explicit data type, as in `wire logic [1:0][3:0] f;` in a package, the case goes from STRICT_EQUAL to
`differ:endcol` in both views, and the away census reads 2 golden records lost. **This verification FIXES it** with
one refinement in the same branch, § pkgNetKwTypeSignEnd274v, behind two switches. The refinement also converts the
signing-keyword shape that the law left wrong. Every other number the implementer reported is reproduced bit for
bit. The three other laws hold on 88 fresh case dirs (176 case-views: VU, VR, VG) with nothing moving away from golden.

## The refinement: § pkgNetKwTypeSignEnd274v (ParamEmit, inside § pkgNetTsDimEnd274's branch)

Switches: `R11V274_PKDKW_OFF` and `R11V274_SIGNEND_OFF`. `R11V274_OFF` drops both and gives the implementer's law
bytes; `R11U274_OFF` still gives pristine's bytes. The trace tag `PKGNETKWSIGN274V` writes `kwtype <net>` or
`signend <net>` under `R11U274_TRACE`.

With no unpacked dimension, Surelog's net-writer stretch does not end at "the first packed dimension of a
multi-dimension declaration". It ends at the end of the FIRST NODE AFTER THE NET KEYWORD. Decoded on
cases/VP vp13 to vp17 (default view; the elaborated view reads the same):

| declaration | golden | pristine | law | fix |
|---|---|---|---|---|
| `wire logic [1:0][3:0] f;` (vp14) | 3:8-3:24 (the whole data type) | 3:8-3:24 | **3:8-3:19 (away)** | 3:8-3:24 |
| `wire logic signed [1:0][3:0] e;` (vp13) | 7:8-7:31 | 7:8-7:31 | **7:8-7:26 (away)** | 7:8-7:31 |
| `wire signed [1:0][3:0] d;` (vp15) | 3:3-3:14 (end of `signed`) | 3:3-3:25 | 3:3-3:20 | 3:3-3:14 |
| `wire unsigned [1:0][3:0] g;` (vp13) | 9:3-9:16 | 9:3-9:27 | 9:3-9:22 | 9:3-9:16 |
| `wire signed [7:0] s;` / `wire signed t;` / `wire unsigned [3:0] u;` (vp17) | 3:14 / 4:14 / 5:16 | 3:20 / 4:7 / 5:22 | unchanged | golden's |
| `wire logic [7:0] a [0:1];`, `wire signed [7:0] b [0:1];` (vp16), `wire signed [1:0][3:0] d [2];` (vp18) | end of the first unpacked dimension | type span | golden's | golden's |

The rule:

- An unpacked dimension keeps the law's end, at the end of the first unpacked dimension.
- An explicit data type (`IntegerTypeSyntax`) keeps the full type span. The law abstains, under switch
  `R11V274_PKDKW_OFF`.
- An implicit type with a `signed` / `unsigned` keyword ends after that keyword, for any number of packed dimensions,
  zero included. This is switch `R11V274_SIGNEND_OFF`.
- Otherwise the end is the first packed dimension, as in the law.

The refinement is in the same branch as the law. A keyword written by a macro still abstains through the law's
`isMacroLoc` check.

## Reproduction of the implementer's numbers (all bit for bit)

- **Builds:** pristine 3ddde3c0b5abae4824299578f13e9bcd, which equals the brief's pristine. The law build is
  8f954c199ecf3e3187352de73ade4c66, which equals the implementer's. Both were built with the system-deps config,
  `-j 2`, and frozen read-only. Both link slang 12.0.0+545f88b2e. uhdm-strictcmp fa6e4f42.
- **Grid:** the implementer's grid of 59 dirs, 118 case-views and 826 lines was rerun with drivers copied to
  drivers/. Every verdict field is identical line for line to their evidence/grid.txt; md5s differ only by the
  worktree path inside the databases. The summary is identical: 79 moving, 54 entering, 0 leaving, `R11U274_OFF` equal
  to pristine on 118/118, and vm02_el the one two-switch mover (evidence/grid_impl_*).
- **Sweeps** (`tests/sweep.sh --jobs 3`, own workdirs; evidence/sweep_{P,L,X}_summary.txt):
  - pristine: probe 3742 + 345, surelog 477+3 / 471+3, uhdm2rtlil 803/1/67, downstream 803/66/2/0. rc 1 comes from
    the base's stale law index alone.
  - law: probe 3748 + 339 with **regressions=0 conversions=6 changes=2**, the same six conversions and two changes by
    name. surelog and uhdm2rtlil read regressions=0 conversions=0 changes=0. downstream 803/66/2/0. rc 0.
  - The row-by-row csv diff of law against pristine shows only the LowMemLib/LowMemPkg testflags workdir path. The
    downstream csv is byte-identical to the baseline.
- **Firing census:** `R11U274_TRACE` over the probe and both corpora, fence-filtered (/tmp/v11u274_census). Its 49
  lines are identical to the implementer's predict.txt (md5 eb4d5941...). Nine databases fire: 8 probe and
  NoReducTypespec testflags.
- **byteverify** on fence-filtered mirrors with `SELFCHECK=1`: 1 of 2560 corpus databases moves, NoReducTypespec
  testflags. It stays CMP_EQUAL / `equal` in both modes. Probe: 8 of 4087 databases move, exactly the predicted 8;
  the pristine probe stage was rerun from the law worktree so that the source paths match. Downstream: 0 of 805.
  - SELFCHECK reads 2559 of 2560. Every file is compared against one fixed file, and the fixed file itself is the one
    not flagged. This is the self-check's design, not a mover.
- **Binary audit:** 3265 of the 3315 fence-filtered cmds.txt name each sweep's own frozen binary, and the other 50
  carry no slang line. With the 8 fenced row-modes counted, that is the implementer's 3273 of 3323. The fenced
  cmds.txt were not opened.
- **Canaries** on the fix sweep: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. ctcan2 PASS with
  `EXPECT_UNKNOWN=1` and `EXPECT_UNKNOWN=6`.
- **Determinism** (tools/probe/r11u272repro/drivers/det.sh, three CONCURRENT draws, final binary): Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen, default and testflags. Each row-mode has one hash,
  equal to the fix sweep's and to the implementer's evidence (evidence/determinism_fix.txt). Scoreboard and Rggen
  testflags produce no database on any binary.
- **MiniAmiq d/t:** `differ:col(2)` and bytes identical to pristine's. The heads #241741 / #243118 are TaskFuncEmit's
  constructor return class_var, the sister's ground, landed on main by pass 277.

## The final (fix) binary 1b116e9d9d517e0e13d6a8a219bf8007

- **Prediction**, frozen before the sweep: the census on the fix binary (evidence/predict_fix.txt and its md5) is
  identical to the law's 49 lines. The refinement's tag `PKGNETKWSIGN274V` appears in no probe case and no corpus
  row, so the prediction is 0 movers against the law. Positive control: the same trace on cases/VP/vp13 writes 3
  `signend` and 2 `kwtype` lines.
- **Sweep:** probe 3748 + 339 with regressions=0 conversions=6 changes=2, identical to the law's csv. surelog and
  uhdm2rtlil read 0/0/0, and their csvs are identical to the law's except the LowMem path text. Downstream is
  803/66/2/0, byte-identical to the baseline. rc 1 comes only from the law index, stale until this patch regenerated
  it.
- **byteverify fix against law:** 0 of 2560 corpus, 0 of 4087 probe and 0 of 805 downstream databases. This matches
  the prediction.
- **uhdm-cmp** stays at 0 lines on every touched row and probe case. No probe case leaves EQUAL. Every downstream
  IDENTICAL row stays.

## The attack: 107 fresh case dirs in both views (214 case-views)

Families:

- cases/VU: 34 dirs on § pkgElabUnaryFoldOpSpan274. Shapes: untyped parameters, `-B`, unary plus, `-f()`,
  `-$clog2()`, `$unit`, multi-line, `-(B+1)`, casts, typedef-typed, an unused package, an import chain, a module
  default, constant slots, if/for generate conditions, an interface import, real / shortreal / longint, a class in the
  package, reduction operators, and macro operands. The `b` variants drop the `assign o = pk::A` read, whose
  package-qualified naming puts the original at uhdm-cmp stage 1 on both binaries.
- cases/VP: 19 dirs on § pkgNetTsDimEnd274 and the refinement. Shapes: multiple unpacked dimensions, signed, explicit
  `logic`, `tri`/`wand`/`wor`/`uwire`/`tri1`, two declarators, parameter dimensions, comments and line breaks between
  dimensions, three packed dimensions, reversed ranges, two packages read from an interface, unused packages, and
  net initialisers. vp08 has rc 3 on every binary; slang rejects it.
- cases/VR: 48 dirs on § elabMemberReadCopyChain274. Shapes:
  - an untaken if-generate branch, a generate condition and a for-generate bound;
  - part-select bounds, a replication count and dimension bounds;
  - a function formal, a block variable and a generate localparam shadowing P;
  - `k0.P.u.a` from the top, an instance array, a localparam alias, a type parameter, three nesting levels, an enum
    member, a nested union, a task argument typed by the member struct, and a depth-3 override;
  - a module-local struct, an unpacked struct and nested-generate reads;
  - an interface, a class in the module and a class with a struct parameter;
  - named call arguments, `++` on an indexed path, a macro-written path, a port actual, a program, an implicit net,
    a case item and `$bits` / `$display`;
  - pass 272's leftover struct.

  The `b` variants use `always_comb` where `assign o = P.u.a` hits ModuleEmit's elaborated cont_assign fold, which is
  stage 1 on both binaries.
- cases/VG: 6 dirs on § lotsCopyNestedGenWalk274: for/for/for, if/if, case/for with an override, a nested generate
  in a child, mixed levels and a named block.

Results (drivers/grid.sh and drivers/vgrid.sh; evidence/grid_fresh_law*, vgrid_fix*, away_*, downstream_cases_*):

- **Law against pristine:** 148 moving, 50 entering STRICT_EQUAL, **2 leaving (vp14 d/e)**, 0 exit-code changes,
  0 uhdm-cmp line changes. `R11U274_OFF` equals pristine on every view. Each mover is restored by exactly one switch,
  except the VG elaborated views, where MEMREADCOPY and LOTSNESTGEN act together as on the implementer's vm02. Chain
  away: **2 on vp14 d/e and 2 on vp02 d/e** (`wire logic` in both), 0 on every other mover.
- **Fix against pristine:** 148 moving, 56 entering, 0 leaving, chain away 0 on every mover. `R11V274_OFF` equals the
  law on 70 of 70 refinement-grid views. `R11U274_OFF` equals pristine on 70 of 70. The fix differs from the law only
  on cases/VP: vp13, vp14, vp15, vp17 and vp02 / vp19, which are stage 1. Each difference is restored by exactly one
  refinement switch, or by both where a case holds both faces. On the other 300 fresh and implementer case-views the
  fix bytes equal the law's (evidence/fix_vs_law_other_grids.txt; its only lines are VP and NODB artefacts).
- **Downstream on all 107 dirs** (dscases.py; pristine, law and fix): 95 IDENTICAL, 5 EQUIVALENT, 6 DIVERGENT and
  1 SLANG_REJECT. Every dir reads the same verdict on all three binaries. The slang lane's `.il`, `_nohier.il` and
  `_synth.v` are byte-identical across the three on the 294 files compared. Every DIVERGENT and EQUIVALENT dir is
  pre-existing: vr07 / vr07b / vr17 / vr18 / vu17 / vu19 and vg03 / vp02 / vp19 / vu16 / vr37.

## Byte controls (drivers/vcontrols.sh; evidence/controls*.txt, away_controls.txt)

Coverage: the implementer's 21 repro dirs, widened by r11u270, v11u270, r11u273, v11u273, r11u266 and v11u266. That is
1528 case dirs and **3056 case-views** on pristine, law and fix. Path lists were filtered by `$FENCED` first.

- **Law against pristine:** 111 moving, 11 entering, 0 leaving, 0 rc and 0 uhdm-cmp changes.
- **Fix against pristine:** 113 moving, 11 entering, 0 leaving, 0 rc and 0 uhdm-cmp changes.
- **Fix against law:** 2 moving, r11v77repro/grid/vc_netkw d/e, which has `wire signed [7:0] k_signed`. It is stage 1
  on every binary, with chain toward 2 and away 0.
- **Chain away:** 0 on all 113 fix movers.
- **Positive control:** the census on vp14 reads law against pristine away 2 and fix against pristine away 0.

## Residues on this ground, ranked (all wrong on pristine too)

1. **§ pkgElabUnaryFoldOpSpan274 does not reach:**
   - a typedef-typed parameter (`parameter sb_t A = -3`, VU/vu09b, endcol);
   - a negated cast with a width (`~8'(3)`, vu08b);
   - `-$clog2(8)` (vu04b);
   - macro-born operators (vu20b, the implementer's un21);
   - untyped parameters, unary plus, `-(B+1)`, imported chains, real kinds and classes in the package, which are
     stage 1 on both binaries (vu01b, vu03b, vu07b, vu12b, vu17b, vu18b).
2. **§ elabMemberReadCopyChain274 leaves:**
   - the member typespec of an indexed path under `++` (vr35, fullname 2 -> 1);
   - an import-typed parameter `parameter c_t P` with `import pk::*` (vr26: golden `work@dut.k0.P.pk::c_t.u.pk::in_t.a`,
     ours `work@kid.pk::in_t.a`; the law does not fire);
   - the indexed-select member in vr29 (fullname 3 -> 2);
   - vr12's task-argument member list (name, the head unchanged; the `tfarg` abstention);
   - the generate-localparam shadow vr17b;
   - the stage-1 shapes: a localparam alias vr07b, a type parameter vr08, a module-local struct vr14, an unpacked struct
     vr15, an interface vr18, a class struct parameter vr33, a port actual vr37 and an implicit net vr22b.
3. **§ lotsCopyNestedGenWalk274:** the VG cases still read `col`, with the P read in a localparam initializer as in
   the implementer's residue 6. vg03 and vg06 are stage 1 on both binaries.
4. **The implementer's own residues stand as reported:** c12_const_fold, the doubled `rd.rd.o` for-generate base,
   `&4'hF`, `P.arr[0].a`, mr05 and vm02's `P.u.a[0]`.

**Sister ground, reported and not written:** § importNetTsDimEnd275 (ModuleEmit), the importer copy's stretch, uses the
same "first packed dimension" model. If it meets `wire logic [1:0][3:0]` or `wire signed [..][..]` through an import,
it likely carries the same face. vp19 reads it at stage 1 on every binary, so it is not decoded here.

## Process

- **Isolation:** both worktrees were fresh at b557d7d7: /tmp/wt_v11u274 for the law and fix, /tmp/wt_v11u274pris for
  pristine. Binaries were frozen at /tmp/v11u274_scr/bin before any measurement. Scratch stayed under /tmp/v11u274_*.
  Every tool variable was guarded with `[ -x ]`.
- **Fence:** every path list was filtered by `$FENCED`, read fail-closed from canaudit.sh, before any file was opened.
  byteverify ran on fence-filtered mirrors. No fenced source or database was read outside the gate sweeps, and no
  process I did not start was signalled.
- **Rebuilds:** the fix was built twice. fix1 measured the grid with a relative binary path, so its first VP grid ran
  nothing (rc 127) and was rerun. fix2 only added the distinct trace tag, and its bytes equal fix1's.
- **Cases in scratch:** the fresh cases lived in scratch until the end, so that the sweeps' law-index check was not
  disturbed.
- **Implementer's driver:** case.sh's golden cache keys on file content, so the VG and VP edits made in place were
  regridded.
- **Clean-up:** none. Scratch was left under /tmp/v11u274_* for the operator.

Files: drivers/case.sh, grid.sh and gridsum.py, copied from r11u274repro. awaygrid.sh is adapted from r11u274repro,
and accepts MOVER lists and a scratch case root. vgrid.sh, vgridsum.py, vcontrols.sh and vctlsum.py are new.
