# v11u299 — adversarial verification of r11u299 (module/type ground: class-method formal writers of a `$unit` typedef, the module enum's elaborated parameter copies, inline-aggregate formal and return spans, the non-ANSI type-parameter port variable)

Base 11701850 (pass 297). The implementer's patch is verified with **no production fix**. No case was found where
pristine was right and the law wrong. The delivered patch differs from the implementer's in four places only:
- the 17 PF case files under tools/probe/r11u299repro/cases/PF now name their law correctly in their first line. They
  named a draft law name (inlineAggPackedArr...FormalSpan299, spelled here without its section mark) that exists nowhere in src, so tests/LAWS.md attributed
  only 7 of the law's 24 cases to `§ inlineAggFormalTypeSpan299`;
- src/R299.h's refinement list says "none" (a comment-only change);
- this directory;
- the regenerated tests/LAWS.md.

## Builds

- Pristine: built at 11701850 in /tmp/wt_v11u299pris, md5 5169a64e. This equals the main tree's build at the base.
- Law: the implementer's patch applied to a fresh 11701850, md5 0bd15001. This equals the implementer's binary.
- Both are frozen read-only before any measurement and report slang 12.0.0+545f88b2e.

## Gate reproduction (bit for bit)

- Sweeps: `tests/sweep.sh --jobs 3`, pristine from the pristine worktree and law from the law worktree (evidence/sweep_P.txt,
  sweep_L.txt).
  - Probe: pristine reads 3954 + 133. The law reads 3957 + 130, with regressions 0, conversions 3 and changes 1:
    - r10uvm56repro/a6_type line(9) -> EQUAL;
    - r11u110repro/grid/e1/e22_nonansi line(1) -> EQUAL;
    - v11u93b107repro/brk/p18_func_arg endcol(4) -> EQUAL;
    - r10v62repro/v62e_bind line(7) -> fullname(5).
  - Surelog: default 480 + 0 and testflags 474 + 0, 0/0/0.
  - uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
  - Downstream: 803/66/2/0 on both binaries. The law csv is byte-identical to results/downstream_uhdm2rtlil.csv.
  - Every sweep exits 1 on the law-index check alone.
- Strict column, the whole csvs row by row (pristine against law): surelog differs only in the LowMemLib / LowMemPkg
  testflags detail text; uhdm2rtlil has 0 rows; probe has exactly the four rows above.
- Firing census (drivers/tracecensus.sh, frozen before the law sweep; evidence/predict.txt): byte-identical to the
  implementer's. It names exactly the 4 probe databases and 0 corpus row-modes.
- Byteverify on fence-filtered hard-link mirrors (drivers/bvmirror.sh, 8 fenced paths skipped by name): 0 of 3365 corpus
  and downstream databases move (SELFCHECK 3363 of 3365, the known twin).
  - Probe: compared with a pristine probe run from the LAW worktree, because the probe databases carry the case's source
    path and the two worktree paths differ in length. Exactly the 4 predicted of 4087 move (evidence/byteverify_probe.txt).
  - Away census on the 4 probe movers (evidence/probe_movers_away.txt): lost 0 and chain away 0, toward 9, 6, 1 and 4;
    v62e_bind's elaborated view is STRICT_EQUAL at 1373 objects.
  - v62e_bind's new first record #767 (`ref_obj op` named `work@be62.op` where golden has `work@top62e.u_a.op`) is
    present in pristine's records too.
- Canaries: surelog ok=52 and uhdm2rtlil ok=16, changed 0. ctcan2 PASS on both (EXPECT_UNKNOWN=1 / 6).
- Binary audit (evidence/binary_audit.txt): 3265 of 3315 fence-filtered cmds.txt in each sweep name that sweep's own
  binary, none name the other binary or the main tree's, and the other 50 run no slang.
- Determinism (drivers/det.sh, three concurrent draws on the law binary): Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg and Rggen read one hash per row-mode. Each hash equals the law sweep's and the implementer's
  evidence.
- The implementer's grid (77 case dirs, 154 case-views, evidence/grid_impl_reproduced.txt) matches its evidence/grid.txt
  in every field but md5, exit codes included:
  - 122 moving, 108 entering STRICT_EQUAL, 0 leaving;
  - OFF equals P on 154 of 154;
  - attribution UNITCLSFORMAL 58, INLAGGFORMAL 36, INLAGGRET 12, MODENUMCLONE 10, NATPVARHDR 6;
  - away census lost 0 and chain away 0 on all 122, 640 records toward golden.
- The implementer's byte controls (28 repro dirs, 4116 case-views, evidence/controls_impl.txt):
  - 6 moving, 0 exit-code changes;
  - r11u152repro TP/t08_nonansi enters STRICT_EQUAL in both views;
  - r11u231repro AL/a10 and TI/t05 stay at stage 1 with uhdm-cmp 156 and 152 lines unchanged;
  - lost 0 and chain away 0 on all 6.

## Widened byte controls (evidence/controls_trigger*.txt)

The case dirs under tools/probe were selected by the laws' triggers: an inline struct or union formal or return, a
class beside a `$unit` aggregate typedef, a non-ANSI port with a type parameter, or a module enum with a parameter and a
subroutine. The path list was fence-filtered before any file was read. This gives 262 case dirs and 524 case-views:
- 20 moving, 8 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 0 uhdm-cmp line-count changes.
- Entering STRICT_EQUAL:
  - r11u107repro/grid/a22_anon_task_arg (law 3);
  - r11u162verify/cases/uag/u04_class_method_and_func (law 1);
  - v11u152repro/cases/KT/t06_nonansi_out (law 5);
  - r11u152 t08_nonansi (law 5).
- r11u190verify G/g04 and r11u276repro CA/ca10_enum_formal move line -> type. The enum line record is cleared. The next
  head is a module function-call fold that pristine also has.
- Lost 0 and chain away 0 on all 20, 53 records toward golden.

## Attack: 67 fresh case dirs in both views (cases/VU, VE, VP, VR, VN; 134 case-views, every grid line with rc=)

Each case names its law in its first line. Totals:
- 102 moving, 74 entering STRICT_EQUAL, **0 leaving**, 0 exit-code changes.
- OFF equals P on 134 of 134.
- Each mover is restored by exactly one switch: UNITCLSFORMAL 36, INLAGGFORMAL 28, INLAGGRET 14, NATPVARHDR 16,
  MODENUMCLONE 8.
- Away census on all 102 movers: lost 0 and chain away 0, 433 records toward golden. The positive control (binaries
  swapped) reads away 1 to 10 on 10 of 10.
- uhdm-cmp line counts are unchanged on every stage-1 mover.
- Downstream (drivers/dscases.py, both binaries): no verdict changes on any of the 67 (60 IDENTICAL; ve03 and vn03
  STATUS_DIFF, vn01, vn06 and vp04 EQUIVALENT, vp05 and vr01 DIVERGENT on both binaries).

| case | law | P -> L |
|---|---|---|
| VU/vu02 pure virtual + class + module (enum), vu03 interface class + module, vu05 program class, vu10 extends, vu11 three containers (enum), vu12 default argument, vu13 static task, vu17 class in a header + module, vu18 pure virtual + module (enum), vu19 nested class in a module class, vu20 two module classes in key order (union) | § unitTdClassFormalWriter299 | line or file -> STRICT_EQUAL (vu20_el, vu07_el, vu08_el -> fullname: the elaborated module-class full name, pristine's too) |
| VU/vu07, vu08 `$unit` class `Zc` against module class `a` (byte-order keys) | same | -> STRICT_EQUAL default |
| VU/vu04 interface class + interface function, vu16 extern + module, vu21 `$unit` task + module class (enum) | same | stage 1 on both binaries, moved toward golden |
| VU/vu01 pure virtual + module (struct), vu14 same (union) | same | moves wrong -> wrong, distance unchanged (residue 1) |
| VU/vu06 parameterized class, vu15 interface class (enum) | same | unmoved (residue 1) |
| VE/ve06 instances in a generate loop, ve08 two localparams on two lines + a task | § modEnumTfArgCloneFollows299 | line -> STRICT_EQUAL |
| VE/ve01 generate-block localparam, ve05 alias typedef | same | stage 1, moved toward golden |
| VE/ve02 two modules with the same enum name, ve07 `parameter` + signal, ve04 unpacked parameter array, ve03 interface | same | unmoved (residue 2) |
| VE/ve09 program (control) | same | STRICT_EQUAL on both binaries, unmoved |
| VP/vp01 DPI import, vp03 `const ref`, vp06 generate block, vp09 program, vp10 nested inline struct, vp11 task called twice, vp13 interface task through a modport, vp14 inherited `output` with no keyword, vp15 static class method without a direction, vp16 CRLF multi-line, vp17 `v, w` sharing a declaration, vp18 task union without dims or direction | § inlineAggFormalTypeSpan299 | endcol or endline -> STRICT_EQUAL |
| VP/vp04 `input var`, vp07 package function | same | stage 1, moved toward golden |
| VP/vp05 unpacked dimension, vp08 pure virtual prototype | same | unmoved (residue 3) |
| VR/vr02 union with two dims, vr06 program, vr07 generate block, vr08 pure virtual control, vr09 macro-built type, vr10 CRLF; vr03 interface (elaborated) | § inlineAggReturnVarSpan299 | endcol or endline -> STRICT_EQUAL (vr08 unmoved) |
| VR/vr03 default, vr04 package | same | stage 1, moved toward golden |
| VR/vr01 `struct packed signed` | same | unmoved, stage 1 (pass 299's p12 face) |
| VN/vn05 `inout tri`, vn08 two instances, vn09 generate loop, vn10 escaped name, vn11 multi-line port list, vn14 CRLF | § nonAnsiTpVarAtHeader299 | line -> STRICT_EQUAL |
| VN/vn02 `input rt_t a, b;`, vn12 extra packed dimension | same | line -> fullname, toward 2 / 1 |
| VN/vn01 explicit port expression, vn03 interface, vn06 body redeclaration, vn07 plain type parameter, vn13 ANSI control | same | unmoved |

Dropped as illegal SV or without a golden: an extern method with an inline struct formal or return (slang rejects the
prototype mismatch, as the LRM says), a pure virtual overridden with an inline struct, an inline enum formal with no
cast, a package class reading `$unit` (slang: a compilation-unit reference from a package), and a non-ANSI program port
(Surelog's parser rejects it).

## Residues (all wrong on pristine too; ranked)

1. **Law 1's two halves disagree on pure virtual prototypes and interface classes.**
   - Pure virtual prototypes. Surelog's CompileClass compiles a pure virtual prototype through compileFunction like any
     method (paMethod_prototype branch), so its formal writes the typedef. Golden vu01 reads s_t at the prototype's 4:31
     and vu14 reads u_t at 4:32. The enum half (§ tfArgTypedefLastWriter146's writers) already counts it (vu18 converts).
     The aggregate half (`scanCls299`) poisons on `MethodFlags::Pure` and declines to the declaration. The decoded fix:
     in UhdmExporter `scanCls299`, a MethodPrototype counts as a writer unless it is a DPI import. That would convert
     vu01 and vu14 and touches no gate database the census sees.
   - Interface classes. Golden vu15 binds the interface class formal (5:20). The enum half returns early for any
     container that is not a ModuleDeclaration, while the aggregate half keys interface classes and gets vu03 right.
   - Generic classes. A parameterized class (vu06, golden 4:18) is a GenericClassDef, not a ClassType, so neither half
     sees it.
2. **The module enum's same-name and `parameter` shapes.** Two modules with the same enum name (ve02) and a `parameter`
   (not `localparam`) beside a signal (ve07) are § tfArgTypedefLastWriter146 declining the move itself. In both, golden
   moves the definition listing (ve02 5:36, ve07 6:36) and ours keeps the declaration. Law 2 also leaves interface and
   program instances alone (it requires a module_inst ancestor): the interface case ve03 stays at stage 1 on both
   binaries (the program case ve09 is already STRICT_EQUAL).
3. **Inline-aggregate formal shapes the law does not reach.** A pure virtual prototype's formal (vp08 endcol) and return
   (vr08 endcol). An unpacked dimension on the formal (vp05 array_typespec; DIVERGENT downstream on both binaries).
4. **Non-ANSI shapes.** `input rt_t a, b;` and an extra packed dimension (vn02, vn12) now head at a fullname record
   on the elaborated element typespec, the rebindTypeParamElem107 face the implementer lists. Also an explicit port
   expression (vn01, stage 1, EQUIVALENT downstream), an interface (vn03, STATUS_DIFF) and a body redeclaration (vn06).
5. The implementer's residues stand as written: t42a, vxpkg8, u27_hdr_samepos, the extern-prototype stage-1 cases, p12,
   r02 and n05.

Sister-ground faces seen: v62e_bind #767 (the inside-set reference name, ExprEmit). The module function-call fold that
heads g04 and ca10 after the enum record clears is pristine's too.

## Process

- Every driver is copied from r11u299repro/drivers. Each reads `$FENCED` fail-closed from
  tools/probe/r11u107repro/canaudit.sh's FENCED= line, and every corpus path list was filtered before any file was
  opened. The trigger scan read only a fence-filtered list of tools/probe case files. No fenced name is spelled anywhere.
- No other agent's process was listed or signalled, and the main tree was not written.
- **The verifier's slip, no effect on any reported number.** The first pristine sweep was launched with a trailing `&`
  inside a background task. That orphan kept running beside the relaunch on the same workdir, and the shared log showed
  two summaries, one of them with a HARNESS_ERROR. Both runs had ended before anything was read. The workdir was
  deleted and the pristine sweep rerun alone, and every pristine number above comes from that clean run (the
  contaminated log is kept only in scratch).
- **The implementer's process findings.**
  - The PF first-line law name is fixed in the delivered patch.
  - The law-1 trace fires on every class-writer return whether or not bytes move, and the new poison branch (pure
    virtual / DPI / non-bare spelling) has no trace. The census therefore cannot predict a poison-only mover.
    Byteverify confirms none exists in the gate.
