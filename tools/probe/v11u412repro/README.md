# v11u412 — adversarial verification of r11u412 (module/type ground, sv-tests pass 412)

Base f90a5af1e (pass 410). Implementer patch /tmp/r11u412.patch applied clean on
a fresh worktree. Pristine reading = the master's control sweep /tmp/intr11u410
(no pristine sweep run here); pristine binary = the main tree's build at the base.

## Verdict

The implementer's 23 laws hold on every gate and on the attack grid: no corpus
row, probe case, downstream row or sv-tests row regresses, and no fresh case on
legal SV goes from right on pristine to wrong under the law.  Two laws were
partial transcriptions that moved fresh cases the wrong way or left them wrong
in a new way; both are refined here behind their own switches:

| refinement | file | switch | statement |
|---|---|---|---|
| § fnDeclOnlyFirstTwice412v | TaskFuncEmit (inside § tfDeclOnlyBodyBegin412) | R11V412_FNFIRSTTWICE_OFF | a FUNCTION (void or not) whose one declaration item is its whole body lists every declarator once, then the FIRST declarator again; each declarator after the first is parented at an unlisted blocking assignment (opType 82) at the declarator's span, the assignment parented at the function. Only a TASK lists the whole item twice. |
| § unitSignedBinPadOnes412v | UhdmExporter (inside § unitParamBasedLitFold412) | R11V412_SBINPAD_OFF | a $unit parameter's signed binary literal with its top bit set follows Surelog's CompileHelper::adjustSize. Under a SIGNED int, logic or bit typespec the value is the literal's own negative (-(2^n - v)). Under any other type, ones are appended to the RIGHT of the written digits up to the parameter's width (INT). Past 63 bits that digit string stays a BIN constant. An untyped parameter keeps the literal's value at its own width, up to 63 bits. |

THE BREAKS (fresh cases, legal SV):
- VD/vd10 `function void f(); int a, b, c; endfunction`: pristine 212 uhdm-cmp
  lines / 22 dump lines; under the law 224 / 24 (AWAY). The law listed the
  item twice (a b c a b c); golden lists a b c a with b and c under unlisted
  assignments. vd06 and vd07 (two declarators, module and class) also grew in
  uhdm-cmp lines (156 -> 164, 152 -> 160) at the same dump distance. A
  non-void function's single declaration (vd09 `function int f(); int a;`,
  vd12, r11u412 TB/tb02 f2) was left wrong: golden lists a a.
  Verified: vd06, vd07, vd09, vd10, vd12 and tb02 STRICT_EQUAL.
- § unitParamBasedLitFold412's signed-literal branch sign-extended on the left.
  That matches golden only for an all-ones literal, which is the only shape the
  implementer's UP cases used. Golden: shortint = 4'sb1000 is INT:36863 (1000
  then twelve ones), logic [7:0] = 4'sb1010 is 175, bit signed [7:0] =
  4'sb1000 is -8, int unsigned = 3'SB101 is 3221225471, integer = 4'sb1000 is
  2415919103, byte = 4'sb1000 is 143. The law wrote 65528, 250, 248,
  4294967293, ... (VL/vl01, vl02, vl05, vl06).
  The longint BIN quirk (r11u412 UP/up07) and the 40-bit untyped literal stayed
  wrong.
  Verified: vl01, vl02, vl05, vl06 and up07 STRICT_EQUAL.
  Pristine wrote BIN literals here: wrong too, but the law's values were wrong
  in a new way.

## Binaries (frozen under /tmp/v11u412_bin)

- pristine 90a4636688930e71fba0fbcc9777e82a (the main tree's build at the base)
- law a29f6b4c554369ce3a75752906467e7a, rebuilt here at -j 2. It is equal to
  the implementer's final binary.
- verified e0e8ff5c0e77b01d6e7178bfe262f9b2. It links slang 12.0.0+545f88b2e.

After the verified build, four added comments were reworded in place (the word
rule: the forbidden word -> 'branch'). These are the implementer's comments in TypeEmit and
UhdmExporter. Line numbering is unchanged.

## Sweeps (tests/sweep.sh --jobs 3 corpus stages from the worktree; sv-tests through the main tree's scripts/check_svtests.py read-only with --baseline the worktree's golden, a worktree having no UVM tree)

Law binary, /tmp/v11u412_lwd (R11U412_TRACE on):
- probe: EQUAL 4018, STRICT_NOTEQUAL 69. Regressions, conversions and changes
  0/0/0; the csv is identical to the control's and to the implementer's.
- surelog: default 480 + 0 and testflags 474 + 0, 0/0/0. The csv differs from
  the control and the implementer's only in the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0; the csv is identical.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  not identical and not excused: 0. The csv is identical.
- sv-tests: EQUAL 1696, STRICT_NOTEQUAL 21, DIFFERENT 223, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346.
  Regressions 0, conversions 30, changes 0. The csv is identical to the
  implementer's on all 2346 rows. The 30 conversions are exactly the
  implementer's list, all DIFFERENT -> EQUAL.
- byteverify (SELFCHECK=1) against /tmp/intr11u410: surelog 0 of 962,
  uhdm2rtlil 0 of 1608, downstream 0 of 805 movers. The self-check flagged
  961, 1607 and 804.
- canaries: ok=52 and ok=16, changed 0. ctcan2: surelog ok=58 unknown=1 PASS;
  uhdm2rtlil ok=2 unknown=6 PASS.
- binary audit, fence-filtered before reading any cmds.txt:
  - surelog: 1523 of 1573 name the law binary, 0 another, 50 hold no slang
    line.
  - uhdm2rtlil: 1740 of 1740. The tree holds 1742; the implementer's '1742 of
    1742' includes the 2 fenced records.
  - sv-tests: 2346 of 2346.
- trace census: probe 2 (genericIfacePosConnNoDouble412 on r10imex t2 and
  t4); surelog 18 (builtinMailboxSpecBare412 on 9 UVM row-modes); uhdm2rtlil
  and downstream 0; sv-tests 193 rows. This equals the implementer's census.
- sv-tests away census on the 161 firing rows that are not EQUAL:
  uhdm-strictcmp law vs control reads STRICT_EQUAL on 157. The raw databases
  never compare byte-equal across workdirs. The 4 that move, by dump lines to
  golden (control -> law):
  - p203 130 -> 104
  - p600 154 -> 150
  - p737 159 -> 145
  - chapter-16/16.10--property-local-var-uvm: line-multiset distance
    80947 -> 80927. Its diff-line count grows 198575 -> 199845 by alignment
    only.

  p884 is strict-equal law vs control and moves in the UDP table text strict
  does not record (133 -> 125). 0 rows move away.

Verified binary, /tmp/v11u412_vwd (R11U412_TRACE on), one sweep. A second sweep
is allowed because the refinements changed production code.
- Every stage reads the same as the law sweep. The probe, uhdm2rtlil,
  downstream and sv-tests csvs are identical to the law sweep's; the surelog
  csv differs only in the two LowMem log-path texts. Regressions 0 in all five
  stages, sv-tests conversions 30, changes 0.
- byteverify against the control: 0 of 962, 0 of 1608, 0 of 805.
- canaries: ok=52 / ok=16, ctcan2 PASS / PASS.
- audit: surelog 1523/1573 (0 other, 50 none), uhdm2rtlil 1740/1740, sv-tests
  2346/2346.
- refinement firings, PREDICTED BY NAME before the sweep:
  - § unitSignedBinPadOnes412v: generic/number/number_test_15 only (`int foo =
    4'sb1111`, INT:-1 under both the law and the fix). The fence-filtered
    source scan, evidence/prediction_scan.txt, found no other $unit
    signed-binary parameter with its top bit set. The scan's other
    signed-binary files are module parameters or number_test_16's 4'Sb0000.
  - § fnDeclOnlyFirstTwice412v: generic/member/class_member_test_27, from the
    law trace's 'twice' line on a function with one declarator: the same bytes
    as the law. The scan's non-void single-declaration functions are
    ClassFuncProto and UnitThisNew (SLANG_REJECT rows, rc 3 on both binaries),
    r10v157 (a typedef item, abstains) and r10uvm27 t37c (a constructor,
    abstains).

  Both rows stay EQUAL; no corpus row or probe case fires either refinement.

## Grids

The implementer's 68 case dirs were reproduced line for line
(evidence/r11u412_grid_reproduced.txt). Pristine -> law:
- 34 NOT_EQUAL -> STRICT_EQUAL
- 24 NOT_EQUAL moving toward golden
- 5 abstaining NOT_EQUAL with pristine's bytes
- 5 STRICT_EQUAL controls with pristine's bytes
- every exit code 0

R11U412_OFF gives pristine's bytes on 68 of 68. R11V412_OFF gives the law's
bytes on 68 of 68. Verified vs law: tb02 and up07 NOT_EQUAL -> STRICT_EQUAL,
every other case byte-identical.

Attack grid: 102 fresh case dirs in 19 groups (evidence/grid.txt; driver
drivers/grid.sh; golden = Surelog v1.87 -parse -nobuiltin, VA and VM with the
builtins on both sides; every exit code 0 on all three binaries).
- Pristine -> verified:
  - 47 NOT_EQUAL -> STRICT_EQUAL
  - 47 NOT_EQUAL on both
  - 7 STRICT_EQUAL controls kept
  - 1 STRICT_NOTEQUAL kept
  - none leaving an equal status
- Law -> verified: 10 NOT_EQUAL -> STRICT_EQUAL (vd04, vd06, vd07, vd09, vd10,
  vd12, vl01, vl02, vl05, vl06), the rest byte-identical.
- Dump distance pristine -> verified: 77 toward golden, 22 the same, and 3
  further by dump lines (VT/vt02 70 -> 86, vt03 80 -> 108, vt05 85 -> 88).
  In those 3 the uhdm-cmp head moves later (vt02 782 -> 58 lines, vt03
  510 -> 78, vt05 215 -> 58). The growth is the dropped type_parameter and
  its default typespec, still built as the uses' parent and printed in the
  dump's free-object tail (see the § modKwlessTypeParamDropped412 residue).
- R11U412_OFF == pristine on 102 of 102; R11V412_OFF == law on 102 of 102.
- The case's own switch restores pristine (or, for a refinement case, the
  law's bytes) on 96. The 6 others need a second switch of this pass, all
  restoring pristine:
  - va04 and vm02: + R11U412_DECLONLYBODY_OFF
  - vr01 and vr05: R11U412_CLSTDRETLOC_OFF + R11U412_RETALIASTWIN_OFF
  - vr03: the return trio
  - vu01: R11U412_UDPSTAR_OFF + R11U412_UDPINITTICK_OFF
- downstream (drivers/ds.sh, ds.one with the downstream flags) on the
  class-free cases:
  - VE/ve01 and ve02: DIVERGENT -> IDENTICAL. Golden's inline-enum counter
    and the ranged member now agree with Surelog's lane.
  - VT/vt04: DIVERGENT -> IDENTICAL.
  - vb01, vb04-vb06, vg01, vg02, vg04, vr02, vr06, vd02, vd06, vd09, vd10,
    vd12, vi05, vf01, vf04, ve04, ve09, ve10 and vl01, vl02, vl05, vl06:
    IDENTICAL on every binary.
  - vt01, vt03, vt05, vs03, vs04, vb02, vi01 and vi04: EQUIVALENT on both.
  - vs02 and vf06: DIVERGENT on both.
  - No case's verdict worsens.

Cases by law (first line of each dut.sv):
- § modKwlessTypeParamDropped412: VT vt01-vt06
- § enumRangedMemberSurelogVal412: VE ve01-ve09
- § enumXzReplInitZero412: VE ve10, ve11
- § bitSignedElabVar412: VB vb01-vb06
- § unpStructArrElemVar412: VS vs01-vs05
- § elabVarSysCallInit412: VI vi01-vi05
- § tfDeclOnlyBodyBegin412: VD vd01-vd05, vd08, vd11
- § fnDeclOnlyFirstTwice412v: VD vd06, vd07, vd09, vd10, vd12
- § classKwParamsLast412: VC vc01-vc05
- § importFnNameFirstWins412: VF vf01-vf06
- § assocClassIdxNet412: VA va01-va05
- § builtinMailboxSpecBare412: VM vm01-vm04
- § interconnectNetNone412: VN vn01-vn04
- § propLocalVarListed412: VP vp01-vp05
- § unitParamBasedLitFold412: VL vl03, vl04
- § unitSignedBinPadOnes412v: VL vl01, vl02, vl05, vl06
- § extScopedParamBaseName412: VX vx01, vx02
- § udpSeqStarTwoSpaces412: VU vu01, vu02, vu04
- § udpInitTickValEmpty412: VU vu03
- § genericIfacePosConnNoDouble412: VG vg01-vg04
- § assocWildcardIdxRefTs412: VW vw01-vw03
- § classTdRetVarAtTypeToken412: VR vr01
- § tdAtomRetAliasTwin412: VR vr02, vr04-vr06
- § oobScopedClsTdRetUnsup412: VR vr03
- § modNettypeTypedef412: VY vy01-vy03

## Goal 1

The detail column was re-read on the law sweep's csv: all 75 SURELOG_ONLY and
303 BOTH_REJECT rows carry an upstream slang front-end diagnostic. No row
carries an exporter 'unsupported', 'typedef target' or 'expression kind'
message, and there is no SLANG_CRASH row.

## Residues found here (all wrong on pristine too, none moved away by uhdm-cmp)

1. § modKwlessTypeParamDropped412 is a listing filter only. The type_parameter
   object and its default typespec are still built, and every use binds that
   typespec. Golden builds no type_parameter, binds an unsupported_typespec
   named T at the use token, and gives the elaborated port variable no
   typespec (VT vt02, vt03, vt05: uhdm-cmp toward, dump lines further by the
   free-object tail). The use-site typespec is TypeEmit's makeTypespec: this
   ground.
2. § tfDeclOnlyBodyBegin412 / § fnDeclOnlyFirstTwice412v: a function body
   whose one item has an initialiser (`int a = 1, b;`, VD vd08 g) keeps
   pristine's begin/assignment shape. Golden lists a b a with both under
   assignments.
3. § unitSignedBinPadOnes412v: untyped literals wider than 63 bits not
   reached.
4. § elabVarSysCallInit412: an initialised time variable (`time t = $time;`)
   is a net plus a net-declaration cont_assign in golden. Ours is a time_var,
   now carrying the call (VI vi01; pass 406's residue TM).
5. § propLocalVarListed412: logic, bit and vector locals abstain (VP vp01, the
   bit q of vp03); property locals in an interface are not reached (vp04).
6. § unpStructArrElemVar412: an array of unpacked structs driven by a
   continuous assign or an initializer is an array_net of struct_net in
   golden (VS vs03, vs04: ours array_var of struct_var, pristine logic_var;
   same distance).
7. § bitSignedElabVar412 does not reach a function local or a class property
   (VB vb02, vb03 unchanged).
8. § enumRangedMemberSurelogVal412 does not reach an inline-enum parameter
   (VE ve03) or a typedef value naming a parameter (ve05: golden's counter
   ignores a non-constant initializer).
9. § assocClassIdxNet412 does not reach interfaces or generate blocks (VA
   va03), nor wildcard associatives in classes, packages or generate blocks
   (VW vw02).
10. § importFnNameFirstWins412: the design-level $unit import listing still
    lists the later package's namesake (VF vf05).
11. § classTdRetVarAtTypeToken412: a MODULE function returning a module
    typedef keeps the typedef's span where golden places the return variable
    at the written type (VR vr06).
12. § interconnectNetNone412: interconnect ports and nets in generate scopes
    (VN vn02, vn04).

## Sister-ground faces (reported, not written)

- ParamEmit / ExprEmit: a module use of a $unit parameter written 1'B1
  (VL vl03); elaborated folding of $unit parameter operands (VL vl04: golden
  INT:127 for LI + PBY).

## Process

- Two builds: the law binary, and the verified binary as an incremental build
  of the same worktree.
- Two five-stage sweeps, one per binary. No pristine build and no pristine
  sweep.
- Case runs wrote only under /tmp/v11u412_*. The repro dir holds the dut.sv
  files only.
- The fence list was read into a scratch file without printing it, and every
  tree-wide list was filtered on it before any file was opened. No fenced
  name is spelled here.
- No other agent's process was touched. The sister verifier's uhdm-dump runs
  were left alone.
