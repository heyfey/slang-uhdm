# v11u264: adversarial verification of r11u264 (pass 264, the expression/parameter ground)

Verdict: **ACCEPT WITH FIX.** Every headline number of r11u264 reproduces bit for bit. Fresh cases found two laws
moving legal SV away from golden where pristine was right:
- § elabParamRefSignedTsUnlocated264 on shortint, longint, byte and untyped sources: 12 case-views leave
  STRICT_EQUAL.
- § pkgQualRefShadowOwnTs264 when a generate block reads the parameter, or when the parameter is typed by a
  package typedef: 10 case-views leave judge-equal (uhdm-cmp stage 1), and 10 more move records away.

Three refinements fix them, each behind its own switch. They move 0 corpus, 0 probe and 0 downstream databases
against the law. The deliverable is `/tmp/r11u264.verified.patch`.

Base abc22480. The binaries were built in fresh worktrees and frozen before any measurement:
- pristine: md5 52573f406f01c43fb57d2d6c829e7f48, identical to the main tree;
- law: 27c1dab2740341ebe116d3cd5923b21d, the implementer's md5;
- fix: 73e79e8b86a63a123a192901c355dad9. Rebuilt from `/tmp/r11u264.verified.patch` applied to a fresh worktree of
  abc22480, it gives the same md5, and the law index reads current there.

All three link slang 12.0.0+545f88b2e. The switches:
- `R11V264_OFF` gives the law's bytes on 266 of 266 fresh case-views and on 164 of 164 implementer case-views.
- `R11U264_OFF` gives pristine's bytes on all 430.

## Reproduction of the implementer's numbers

| item | implementer | this verification |
|---|---|---|
| probe (law sweep) | 3577 EQUAL + 510, conversions g6_view111 and s12_one_pl_pos_recvA_noov | same, regressions=0 conversions=2 changes=0 |
| surelog | default 476 + 4, testflags 469 + 5, Earlgrey_0_1 default CONVERTED | same; fresh row `Earlgrey_0_1,default,CMP_EQUAL,,,equal` |
| uhdm2rtlil | 1606 + 0 | same |
| downstream | 803 / 66 / 2 / 0 | same; verdict diff 0 against my pristine sweep |
| row diff, law vs pristine sweep | Earlgrey d + LowMem path text | same 3 rows (LowMemLib / LowMemPkg testflags embed the workdir) |
| heads | MiniAmiq #136655, SeqDriver #136613 / #136625, Earlgrey t #580520 / #580527 / #580790 | same (evidence/earlgrey_testflags_law_records.txt: the 14 records, 13 fullname #580520 to #594077 and #604991 depth) |
| byte movers | 6 surelog, 0 uhdm2rtlil, 0 downstream, 2 probe | same, with the implementer's hashes (4d98b51f6f39, 21c97dfb4c42, 394522f956cf, ba56402e6606, 4e5fdda52ad3) |
| firing census | 8 databases | identical line for line (evidence/census_law.txt) |
| away census | Earlgrey d 136 -> 2, t 552 -> 447, MiniAmiq 110 / 27, SeqDriver 81 / 18, 0 lost; chain 0 away | identical (evidence/away_corpus.txt, away_chain_corpus.txt); uhdm-cmp 0 lines on all six |
| grid | 164 case-views, 110 moving, 66 entering, none leaving, OFF pristine 164 | identical on the law and on the fix (2460 lines on 15 configurations; 2430 rc 0, 30 rc 4 = C/c11 on every configuration) |
| byte controls | 35 dirs, 5074 case-views, 8 movers, 2 entering | identical: the same 8 movers on the law and the fix, every one 0 away (evidence/away_controls.txt), no rc or uhdm-cmp count change |
| canaries / ctcan2 / audit | ok=51 changed=1, ok=16, PASS / PASS, 3265 of 3315 | same on the law and the fix sweeps; the other 50 carry no slang line |
| determinism | one hash per row-mode | three concurrent draws on the fix binary: one hash per row-mode, equal to the sweep's (evidence/determinism.txt) |

**Two discrepancies in the implementer's report:**
1. The pristine sweep's rc 1 is not caused by the pass's src edits. tests/LAWS.md is already stale at abc22480:
   `scripts/law_index.py --check` fails in a clean worktree of the base and in the main tree.
2. **A fence slip.** The implementer's surelog byteverify (evidence/byteverify_surelog.txt) lists 960 databases.
   The surelog workdir holds 960 only when the 8 fenced row-mode databases are counted, and filtered by `$FENCED`
   it holds 952. So `byteverify.sh` was run on the unfiltered sweep tree, and it ran `cmp` and `md5sum` on the
   fenced rows' databases. Nothing was decoded or dispatched outside the gate sweep, and no fenced name appears in
   the evidence. It is still the "unfiltered cmp loop" class of pass 236's breach. Every byteverify here ran on a
   `$FENCED`-filtered hardlink mirror (drivers/bvmirror.sh): 952 surelog databases.

**Expected self-check readings.** byteverify's SELFCHECK reads N-1 of N on every lane (951 of 952, 1607 of 1608).
This is expected: the self-check compares every file against one fixed file, and that file matches itself. It is
not a missed mover.

## The breaks and the fixes

### § refSignSrcSurelogSigned264v (`R11V264_SRCKIND_OFF`, ParamEmit `signedRefSrc264`)

§ elabParamRefSignedTsUnlocated264 fires whenever slang calls the source parameter's type signed. Surelog's rule is
narrower: the value is signed only when `CompileHelper::valueRange` sees an `int_typespec`, `logic_typespec` or
`bit_typespec` with VpiSigned. DesignElaboration calls it with the constant's own typespec, else the declared one,
and only when a typespec exists.

Where the law broke:
- **Shortint, longint, byte source.** These typespecs (`short_int_typespec` and the others) are none of the three.
  Golden keeps the target's located typespec. The law moved these away, STRICT_EQUAL -> file: VR/vr18 shortint,
  vr19 longint, vr20 byte; vr45 (typedef shortint) is stage 1 on all three binaries, 1 record away.
- **Untyped source** (`localparam A = 5`). There is no typespec, so valueRange never runs. The law moved these away,
  STRICT_EQUAL -> file: vr28, vr50 (negative), vr51 (header parameters); vr07 and vr53 are stage 1, away 2 / 1.

The fix:
- It abstains on an untyped source.
- On a shortint, longint or byte source it recurses into the source's own initializer. That source's constant is
  the minted signed int when it reads an int source. Golden is unlocated there, and the law and the fix agree:
  vr46 `shortint A = I` and vr54 enter STRICT_EQUAL.
- `localparam signed A = 5` (vr42) and `localparam signed [3:0]` (vr43) keep the law, because golden mints for
  logic signed. The same holds for `bit signed`, scalar `bit signed` (vr49) and `logic signed` (vr41).

### § qualShadowPkgTdKeepsClone264v (`R11V264_QSPKGTD_OFF`) and § qualShadowGenReadKeepsClone264v (`R11V264_QSGENREAD_OFF`), ParamEmit `qualShadowAbstain264v`

§ pkgQualRefShadowOwnTs264 leaves the param_assign's Rhs unshared. Reads of the parameter fold from that object, so
the law changes the reads' typespec too:
- **Generate-block reads.** A read inside a generate block folds to the PACKAGE's int_typespec in golden (the value
  Surelog substituted), while the param_assign holds the module's. Under the law our fold took the module's, and
  uhdm-cmp reads the typespec's instance, so the package is missing. STRICT_NOTEQUAL -> NOT_EQUAL_stage1, both
  views:
  - VQ/vq22 `if (1) begin : g assign o = NE; end` with `localparam int NE = pk::NE`: the law's own shape;
  - vq21 logic [7:0];
  - vq20 local typedef;
  - vq26 a select index `i[NE]` in a for-generate;
  - vq18 a package typedef.
- **Package typedef targets** (`localparam pk_t NE = pk::NE`, pk_t = logic [7:0]). Any read binds our declared
  typespec, an unnamed unlocated logic_typespec, where golden keeps the package's `byte_t`. Chain away 5 on vq06
  (whole read) and vq19 (operand and process read). vq13 (no read) and vq09 swap one weakly listed record.
  - Not affected: an int typedef from the package (vq10, vq17, vq23) and a module-local typedef (vq08, vq16).

The fixes:
- The law stands aside when any generate block of the module reads the parameter. This is a slang AST visit over
  the instantiated generate blocks; a for-generate bound is not inside the block and keeps the law (vq24 enters
  STRICT_EQUAL).
- The law also stands aside when the declared type is a package typedef of a type that is not an integer atom.
- Module-body reads keep the law, and enter STRICT_EQUAL:
  - vq27, a process read;
  - vq28, select, part-select and replication-count reads;
  - vq29, a replication count and a child parameter override;
  - vq30, a process loop bound and replication.
- Earlgrey's usbdev reads `NEndpoints` only in processes, dimensions, replications and an override (read from the
  unfenced Earlgrey source after a fence-filtered path list), so the conversion stands. The fix census predicted no
  change, and the fix sweep confirms it.

Each refinement mover is moved by exactly one new switch (24 SRCKIND, 14 QSGENREAD, 8 QSPKGTD). The exception is
vq18 / vq18_el, which carries both QS shapes and returns only with both switches off; its LAW file names both laws.

## Fresh cases (cases/VC, VG, VN, VQ, VR: 133 dirs, 266 case-views; drivers/grid.sh, evidence/grid_fresh.txt, gridsum_fresh.txt)

Each dir runs in both views on 15 configurations: P, L, F, OFF, VOFF and F with each of the ten switches off. That
gives 3990 lines, every one rc 0.

**Totals:**
- P -> L: 244 moving, 90 entering STRICT_EQUAL, 12 LEAVING STRICT_EQUAL, 10 leaving judge-equal (the breaks above).
- P -> F: 202 moving, 92 entering, none leaving, no rc change.
- uhdm-cmp line counts:
  - Five stage-1 VC elaborated views grow: vc02, vc05, vc09, vc13, vc14. The head object prints more of the
    importer's new copies, chain away 0, as the implementer's c09 / c12.
  - Fourteen VR case-views fall to 0.
- Chain-keyed away census (evidence/away_cases.txt): **0 away on all 312 fix movers** (110 implementer, 202
  fresh). Under the law, 42 case-views were away, all VR / VQ above.
- Downstream on all 124 earlier fresh dirs (drivers/dscases.py; evidence/downstream_fresh_cases.txt): the same
  verdict on pristine, law and fix. That is 91 IDENTICAL and 32 EQUIVALENT; vg05 is DIVERGENT on all three
  binaries, `This indicates a serious bug in UHDM import`, pre-existing.

**By law** (F; law names in each case's first line):
- **§ ctorBidLhsCloneCopy264** (VC, 14 dirs):
  - vc01 (this. assignments, two declarators, class-typed local) depth -> STRICT_EQUAL.
  - The importer-copy shapes are stage 1 on all binaries, moving toward golden with 0 away:
    - vc02-vc05: init order, three-level import, parameterized class, nested blocks;
    - vc06: an explicit import;
    - vc08: static and const locals;
    - vc09-vc14: two classes, two base packages, the importer's own out-of-body ctor, a class-typed local, named
      calls with defaults and a pure virtual base, two importers.
  - vc07 (a MODULE importer) does not move.
  - Residue: vc01_el keeps depth #546, a class-typed ctor local (`item it`) listed in the elaborated view where
    golden has the assignment, 0 away.
- **§ caLvTrailIdxNamesByPath264** (VN, 17 dirs):
  - fullname -> STRICT_EQUAL on vn01-04, vn08, vn10-13: a struct output port, a select root, parameter expressions,
    two-level generate, both sides, a generate localparam, nested members, header-parameter indices at two
    instances, a package struct at depth 3.
  - vn16 (if / case generate scopes) fullname -> line, 4 toward.
  - Stage 1 on all binaries with 0 away: vn06 (call index), vn07 (wire struct net), vn09 (delay and strength),
    vn14 (interface body), vn15 (class-specialization index), vn17 (unary index).
  - vn05 (interface instance member) does not move.
- **§ memberIpsParenEnd264 / § selRootIpsOpFoldChainName264 / § plainMemberIpsOwner264** (VG, 15 dirs):
  - vg08 (depth 3 and two instances) endcol -> STRICT_EQUAL in both views.
  - Stage 1 on all binaries, chain 0 away: vg01 (macro-born parenthesized bounds), vg02 (shift, power, ternary
    width), vg03 (nested op and $clog2), vg05-vg07, vg09-vg15 (including an interface body, a class-specialization
    bound, a two-level concatenation, an LHS select root, an always_comb).
  - vg04 (if / case generate) keeps fullname.
- **§ pkgQualRefShadowOwnTs264** (VQ, 31 dirs):
  - STRICT_EQUAL: vq02 (interface), vq08, vq11, vq12, vq24, vq27-vq30.
  - vq01 (`#()` empty header list) stands aside as the law intends.
  - The breaks above are now restored.
- **§ elabParamRefSignedTsUnlocated264** (VR, 56 dirs):
  - Entering STRICT_EQUAL on the fix: vr08, vr10_el, vr12, vr13, vr15, vr16, vr21-vr23, vr27, vr30-vr33, vr36,
    vr38-vr44, vr46, vr49, vr54; vr02 and vr56 (a longint in a ternary) enter only on the fix.
  - Every constant slot was gridded (vr10: part-select bounds, indexed width, replication count, dimension,
    `$bits`, child parameter default); its elaborated view enters.

## Byte controls (drivers/controls.sh, ctlsum.py; evidence/controls*.txt)

- **The implementer's 35 dirs, three binaries:** 5074 case-views.
  - 8 movers on the law, the same 8 on the fix, fix vs law 0.
  - 2 entering (r11u120 a09_genfor), none leaving.
  - rc 139 / 3 / 4 unchanged on all three binaries.
- **Widened by 9 dirs whose laws neighbour this pass's:**
  - the dirs: r11u140, r11u133, r11u184, r11u236, v11u236, r11u187, r11u144, r11u27, r11u115;
  - 1204 case-views, 0 movers on the law and the fix.
- Every path list was filtered by `$FENCED` before any file was opened.

## Gates on the fix binary (evidence/sweep_F.txt, byteverify_fix.txt, census_fix.txt)

- **Firing census** on the fix binary, frozen before the fix sweep: identical to the law's, with 0 refinement
  abstentions in the probe, corpora or downstream. A positive control (vr18, vq22, vq06 under `R11U264_TRACE`)
  logs `SRCKIND abstain atom`, `QUALSHADOW abstain genread` and `QUALSHADOW abstain pkgtd`. The prediction:
  0 movers against the law.
- **Sweep:**
  - probe 3577 EQUAL + 510, regressions=0, conversions=2;
  - surelog 476 + 4 / 469 + 5, regressions=0, conversions=1 (Earlgrey_0_1 default);
  - uhdm2rtlil 1606 + 0;
  - downstream 803 / 66 / 2 / 0, no row leaving IDENTICAL.
  - rc 1 on the stale law index only.
- **byteverify fix vs law:** 0 of 952 surelog, 0 of 1608 uhdm2rtlil, 0 of 805 downstream, 0 of 4087 probe. The
  csvs are identical apart from the LowMem path text.
- **byteverify fix vs pristine:** the 6 corpus movers named above.
- **Canaries:** ok=51 changed=1 (Earlgrey d) and ok=16; ctcan2 PASS / PASS.
- **Binary audit:** 3265 of 3315 command files name `/tmp/v11u264_bin/fix`, and the other 50 carry no slang line.
- **Determinism:** three concurrent draws give one hash per row-mode.

## Residues, ranked

1. **MiniAmiq d/t and SeqDriver d/t** (heads #136655 / #136613 / #136625): the type_id type parameter T unbound.
   - Writer: UhdmExporter `emitClassTdSpecParams1` / `copyClassTdSpecParams1`, confirmed in UhdmExporter.cpp, the
     sister ground.
   - None of the four row-modes converts on this ground.
2. **Earlgrey_0_1 testflags fullname(14):**
   - #580520 to #594077: port-actual struct members under `reg2hw.mp_region_cfg[0].en.q`, ModuleEmit / TypeEmit;
   - #604991: the `u_flash_mp.region_end` listing, ModuleEmit.
   - Both are sister ground, as the implementer reports.
3. **§ pkgQualRefShadowOwnTs264 where the fixes now stand aside:**
   - Generate-block reads: golden's fold keeps the package typespec, so a precise law would rewrite only the
     generate fold. That fold is ModuleEmit's clone, the sister ground.
   - Package-typedef targets.
4. **§ elabParamRefSignedTsUnlocated264 shapes not reached:**
   - a target inside a generate block (vr04 stays file);
   - an untyped target from an int (vr53: golden mints unlocated on A);
   - the vector target (the implementer's p07 T1);
   - integer sources reading an int, which the recursion would reach but the implementer's integer carve-out still
     excludes, unmeasured.
5. **vc01_el:** the class-typed constructor local in the elaborated view.
6. **The implementer's own ranked residues** (vb11 width fold, P/p06, n15 / n17 / n18 / n22 / n25, g08 / g10 /
   g15, c11 rc 4, the --elabuhdm crashes), each reproduced in the grid.
7. **The brief's items (2) to (7)** were not attempted by either agent.

## Process

**Builds and binaries.**
- The pristine and law worktrees were built sequentially at -j 2. Both binaries and uhdm-strictcmp (fa6e4f42, the
  main tree's) were frozen under /tmp/v11u264_bin before the first measurement.
- The fix was built only after the pristine binary was frozen, with -j 1.
- Draft fix_d1 abstained only on whole generate-block right sides. vq26 (a generate select index) still broke on
  it, so it was widened to any generate-block read before any gate run, and only fix (= fix_d2) was swept.

**Re-measured cases.**
- vq26 was first written illegal (rc 3 on both binaries, an out-of-range part select), then rewritten.
- 24 fresh cases were relabelled to name the refinement laws in their first lines, and were re-gridded after the
  edit (fresh golden keys).

**Fence and processes.**
- No fenced test was dispatched, read or opened outside the gate sweeps.
- Every corpus and database path list was `$FENCED`-filtered first, and the whole-word scan of this directory and
  of the src diff reads 0.
- One control run of this pass was stopped by its own task id and rerun from scratch with more parallelism. No
  other process was signalled, and no other agent's command line was listed.
