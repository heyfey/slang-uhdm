# v11u288: adversarial verification of r11u288

Base fc30ffe8 (pass 290 on top of pass 291).  The implementer's patch (/tmp/r11u288.patch, five laws behind
src/R288.h) was applied to a fresh worktree, rebuilt and measured from scratch, then attacked with 41 fresh case dirs.

**VERDICT: ONE BREAK FOUND AND FIXED.**  § randWithCallParentByConsumer288 re-parented a with-form `randomize`
call at ANY operation of two or more operands.  Surelog re-parents an operand only in compileExpression's binary
and ternary branch.  In the definition view, a call that is a concatenation member, an assignment-pattern member or
an inside-set member stayed parentless on pristine, and the law parented it.  Pristine was right on legal SV there,
and the law moved a record away from golden (fullname, chain away 1 on each).  The refinement
§ rzMemberNoReparentDefView288v (R11V288_RZMEMBER_OFF) fixes it.  It moves 0 of 2558 corpus, 0 of 4087 probe and
0 of 805 downstream databases relative to the law.  Every headline number of the implementer reproduces bit for
bit.

## Binaries (built here at -j 2, frozen with chmod 555 before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine | 834660b326d9b8dd22fc4d8e3ec6bc8a | equal to the main tree's build at the base |
| law | 42fb9061ac0c2d943b52fb020aae65f6 | equal to the implementer's |
| fix | b8f0c4d33094b99b5773444e8c81965f | law + § rzMemberNoReparentDefView288v |

All three report slang 12.0.0+545f88b2e.

## The refinement: § rzMemberNoReparentDefView288v (R11V288_RZMEMBER_OFF; R11V288_OFF drops it)

- **Where:** ExprEmit rzWithParentDrain288, inside § randWithCallParentByConsumer288.  ParamEmit's drain call site
  records the view (`rzElabView288v() = elabUhdmView121`), and src/R288.h holds `r11v288On`.
- **The decode** (third_party/Surelog/src/DesignCompile/CompileExpression.cpp):
  - The binary and ternary branch re-parents its operands: `opL->VpiParent(operation)` and
    `opR->VpiParent(operation)`.
  - The `paConcatenation` and `paMultiple_concatenation` branches push their members without re-parenting.  So do
    `compileAssignmentPattern` and the inside operator's `paOpen_range_list` loop.
- **The rule:** in the definition view, the drain abstains when the operation is a concatenation, a replication,
  an assignment pattern or a multi-assignment pattern, or when the call is a set member of an inside (index > 0).
  Its trace reads `RZPARENT_ABSTAIN v288-member-not-reparented`.
- **The elaborated view keeps the law.**  UHDM's elaborator deep-clones the body there and parents each clone at its
  cloned operation, so golden names the arguments (vr01 e, vr02 e and vr14 e reach STRICT_EQUAL under the law and
  the fix).

| case (default view) | pristine | law | fix |
|---|---|---|---|
| VR/vr01_concat_left `{randomize(x) with {..}, 1'b0}` | STRICT_EQUAL 44 | fullname, chain away 1 | STRICT_EQUAL 44 |
| VR/vr02_concat_right | STRICT_EQUAL 44 | fullname, chain away 1 | STRICT_EQUAL 44 |
| VR/vr14_concat_module (two members) | STRICT_EQUAL 52 | fullname | STRICT_EQUAL 52 |
| VR/vr04_inside (an inside left side and a set member) | fullname | fullname, chain away 1 toward 1 | STRICT_EQUAL 51 |
| VR/vr13_pattern_stream `'{randomize(..) with {..}, 0}` | endcol | fullname | endcol (pristine's residue) |

R11V288_OFF gives the law's bytes on 82 of 82 fresh case-views.  R11U288_OFF on the fix binary gives pristine's
bytes on 82 of 82 fresh case-views and on 58 of 58 of the implementer's.

## Reproduction of the implementer's numbers (sweeps /tmp/v11u288_w{P,L,F}, one tests/sweep.sh per binary)

**Probe:**
- pristine: EQUAL 3929 + STRICT_NOTEQUAL 158
- law: 3935 + 152, regressions=0 conversions=6 changes=0
- fix: identical csv to the law's

The six conversions, fresh fix rows:

| fresh fix row | law |
|---|---|
| `r10uvm158repro/g158_a_shape,EQUAL,,equal` | § badItemLocThroughInvalid288 |
| `r10v158repro/v158_d,EQUAL,,equal` | § badItemLocThroughInvalid288 |
| `r10vrgg9repro/cells/v_pred_cast,EQUAL,,equal` | § parenCastReadsCastSyntax288 |
| `r10uvm116repro/g116_f,EQUAL,,equal` | § randWithCallParentByConsumer288 (the operand is a binary operation's, not a member: the refinement does not reach it) |
| `r10buvm29repro/g29_d_fence,EQUAL,,equal` | § streamPartSelLazyName288 |
| `r10buvm21repro/g21b,EQUAL,,equal` | § incDecIpsWholeSpan288 |

**Surelog:** default CMP_EQUAL 480 + 0, testflags 474 + 0, regressions=0 conversions=0 changes=0 on all three
binaries.  The law and fix csvs differ only in the LowMemLib testflags detail text, which carries the workdir path.

**uhdm2rtlil:** 803/1/67 in both modes, regressions=0 conversions=0 changes=0.  The law and fix csvs are identical.

**Downstream:** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT on all three binaries.  The csvs
are byte-identical across the three, and their verdict columns equal results/downstream_uhdm2rtlil.csv.  0 of 805
fence-filtered slang-lane databases move from pristine to fix.

**Firing census** (drivers/tracecensus.sh, the implementer's driver run with this pass's binaries before each
sweep):
- law census: 22 lines, md5 f17c9310, identical to the implementer's predict.txt
- fix census: identical again
- The fix's trace tally (evidence/census_tally_fix.txt) shows that the refinement tag never fires on a gate
  database.  The one `operand-left` firing is g116_f.
- The census therefore predicts 0 law -> fix movers.

**Byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered hard-link mirrors, drivers/mirror.sh;
evidence/byteverify_*.txt):

| step | corpus movers | probe movers |
|---|---|---|
| pristine -> law | 0 of 2558 | exactly the 6 predicted |
| law -> fix | 0 of 2558 | 0 of 4087 |
| pristine -> fix | 0 of 2558 | the same 6 |

- PATH_SETS_IDENTICAL holds on every step.
- SELFCHECK reads 2557 of 2558, pass 201's self-check artefact: every file is compared against one fixed file,
  which is not flagged against itself.  This is the implementer's 2559 of 2560.
- The mirror holds 2558 because this machine's sweeps wrote 2568 corpus databases and 10 paths were dropped by
  the fence filter.
- The pristine probe stage was re-run from the law worktree (`/tmp/v11u288_wP/probe`, csv identical to the first
  run) so that the absolute source paths match.  A first byte comparison across two worktree roots read every
  database as moved because of the path; that comparison was discarded.

**Canaries** (on the law csvs against the pristine csvs; identical results on the fix csvs, since they equal the
law's):
- surelog ok=52 changed=0
- uhdm2rtlil ok=16 changed=0
- ctcan2 EXPECT_UNKNOWN=1 (surelog) and EXPECT_UNKNOWN=6 (uhdm2rtlil): PASS on both

**Binary audit:** after fence-filtering the path list, 3265 of 3315 cmds.txt name each sweep's own binary, for
both P and L.  The other 50 run no slang-uhdm: two CoresSweRV rows mention the repo path only inside Surelog's
command line.

**Determinism** (drivers/det.sh, three concurrent draws of the fix binary, evidence/determinism.txt): one hash per
row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes.  Each
hash equals both the law sweep's and the fix sweep's.  Scoreboard/testflags and Rggen/testflags write no database
on any binary.

**The law index:** every sweep exited 1 on the law-index check alone, and tests/LAWS.md is regenerated in this
patch.

## The attack: 41 fresh case dirs, both views, 82 case-views (cases/, evidence/grid.txt, every line with rc)

| family | cases | law attacked |
|---|---|---|
| VR | 14 | § randWithCallParentByConsumer288 (5 retagged to the refinement) |
| VP | 13 | § parenCastReadsCastSyntax288 |
| VS | 6 | § streamPartSelLazyName288 |
| VI | 5 | § incDecIpsWholeSpan288 |
| VC | 3 | § badItemLocThroughInvalid288 |

**What each family covers:**
- **VR:** a concatenation's left and right member, a replication, an inside left side and set member, a call
  argument, a case condition, a cast, a unary minus, two operands of one operation, nested operations, a ternary
  false branch, else-if, do-while and for conditions, std::randomize and obj.randomize in a module, immediate
  assert/assume/cover and a deferred assert, a package class task, an assignment pattern and a stream.
- **VP:** an implicit width conversion around the cast, parameter defaults, localparams and overrides, a select
  index, part-select bounds, an indexed width, a replication count, a dimension bound, generate if/for/case
  conditions and bodies, function, task, class-method and package-function homes, real conversions, a package enum
  target, parameter size casts, signedness, macro-born casts with parentheses inside and outside the macro, nested
  parentheses, port actuals named and positional, an interface body one level down, case conditions and items, a
  typedef of a type parameter and a class type parameter, concatenation members, streaming operands and a ternary.
- **VS:** streaming targets, a call argument, an index, an inner concatenation, a select's part-select, interface,
  task, for- and if-generate and package-task homes, a struct member, module and package parameters, a byte slice
  type, two instance depths, a two-level generate, a class static function and task, and a ternary.
- **VI:** class, package-function and interface homes, a plain part-select control, prefix forms, an unpacked
  element, a 2-D packed array, an overridden width, a for-generate, expression positions (operand, if condition,
  call argument), a macro, and a part-select index.
- **VC:** unique case and priority casez in a class task, a multi-expression item, an expression-statement body,
  case inside, and a case nested in a default item.

**Pristine -> fix:**
- 65 case-views move, 47 enter STRICT_EQUAL and **none leave**.  No exit code changes.
- Each mover goes back to pristine's bytes under exactly ONE law switch: PARENCAST 26, RZPARENT 15, STREAMPS 12,
  INCDECIPS 8, BADITEMLOC 4.
- Chain away 0 on all 65, with 410 records toward golden (evidence/grid_away.txt).
- The positive control (binaries swapped) reads away 1 to 37 on 63 of 65.  The two zeros are VP/vp12, both views:
  bytes move but its stage-1 walk records do not.

**Pristine -> law (before the fix):** the same, plus the breaks.  vr01 d and vr02 d left STRICT_EQUAL, and vr14 d
too once added.  vr04 d read chain away 1, and vr13 d moved endcol -> fullname
(evidence/grid_away_law.txt).

**Downstream on the fresh cases** (drivers/dscases.py, all three binaries; evidence/downstream_cases.txt):
- No verdict is worse on any binary.
- Ten improve.  EQUIVALENT -> IDENTICAL: vi01, vi03, vi04, vp01, vp04, vp05 and vp13.  DIVERGENT -> IDENTICAL:
  vp06.  STATUS_DIFF -> EQUIVALENT: vp07.
- The refinement changes no verdict.

**uhdm-cmp line counts that grow:** vp02 (14 -> 74), vp06 (12 -> 1324) and vp07 (19 -> 70) grow because the
pristine head is fixed and the walk reaches a later difference that pristine has too.
- vp06: pristine's head was the real_typespec of `(real'(i))`.  Under the fix, every cast record matches golden,
  and the remaining dump difference is golden listing the `output shortreal s` port as a logic_net.  That
  difference is also present on pristine.
- Chain away is 0 on all three.

## Byte controls: EVERY dut.sv case dir under tools/probe (drivers/ctlbytes.sh; evidence/controls_*)

- **Scope:** 23769 case dirs, 47538 case-views, pristine vs fix.  The path list was filtered by $FENCED before any
  file was opened.
- **Exit codes:** 0 differ.
- **Movers:** 153.  52 are the implementer's grid, 65 are this grid's, and 36 are in 18 earlier dirs:
  - r11u170verify pp/f02 and sc/f13
  - r11u181repro bx/b15
  - r11u199verify C/c01_cast_of_cast and C/c06_nda_array_net
  - r11u204verify K/k2
  - r11u212repro NS/n04
  - r11u228repro MR/m07
  - r11u254repro V/v05_forinit_more and V/v06_forinit_split
  - r11v140repro stm/b06_select
  - r11v181repro px/p01
  - v11u192repro K/k10_streaming_incdec
  - v11u244repro D/d02_case
  - v11u246repro SB/v02_inclother
  - v11u254repro F/vf03_selects
  - v11u258repro VS/vs17_plain_var_sel and VS/vs18_class_prop_noprefix
- **The 36 earlier-dir movers:**
  - None leaves STRICT_EQUAL.  16 enter it: b15, b06_select, p01, k10, d02_case, vf03, vs17 and vs18, each in both
    views.
  - Four move from stage 1 to a later strict head: c06 to depth, and n04 to endcol, each in both views.
  - Each goes back to pristine under exactly one switch: PARENCAST 20, STREAMPS 10, INCDECIPS 6.
  - Chain away is 0 on all 36.  The positive control reads nonzero on 36 of 36.
  - sc/f13 reads flat away 1 with chain away 0.  This is a diff-alignment artefact: the fix lists the located
    integer_typespec of `signed'(2'(3))`'s inner cast as golden does, which adds one INT:2 listing that the flat
    count pairs differently.
- **Implementer's grid:** law -> fix moves 0 of the 58 case-views.  R11U288_OFF on the fix binary gives pristine's
  bytes on 58 of 58.

## Residues (all wrong on pristine too unless stated), ranked

**This ground:**
1. The with-form randomize in positions the law abstains on.  These are already wrong on pristine in the
   elaborated view, where golden names the arguments because the clone is parented:
   - a call argument (vr05)
   - a case condition (vr05)
   - a cast and a unary minus (vr06)
   - a for condition (vr08 fc #45)
   - a streaming operand (vr13 e #47)
   - a replication (vr03 e)

   The default view of these reads golden's parentless form.  A law would parent the call in the elaborated view
   only.
2. vr13: the stream operation's end column `{<< {randomize(x) with {..}}}` (endcol 45 against golden's 61).
3. VP/vp12: a cast to a typedef of a type parameter, `typedef T tt; (tt'(x))`.
   - pristine: an unnamed, unlocated logic_typespec
   - law and fix: named tt but located at the typedef's `T` (6:11)
   - golden: tt at the type parameter's default `logic [3:0]` (5:31-42), the same model as pc05
4. The cast residues: vp02 and vp07's later stage-1 heads, vp10 and vp13 col.
5. The implementer's residue list stands as written in tools/probe/r11u288repro/README.md.

**Sister ground:** the faces the implementer reported with their call sites stand.

## Process

- Every reader took $FENCED fail-closed from tools/probe/r11u107repro/canaudit.sh (drivers/env.sh) and filtered
  its path list before opening anything.  Nothing fenced was read or run, and the main tree was not written.
- **THE VERIFIER'S SLIPS (no effect on any result):**
  - The first binary-path audit grep read the cmds.txt files of all sweep row dirs, fenced rows included, before
    filtering.  These are harness command-line records, not sources or databases.  The audit was redone from a
    fence-filtered path list, and those are the numbers above.
  - One background waiter used `pgrep -f` with a pattern containing its own command-line text.  It was stopped by
    its own task id before it signalled anything and was replaced by a wait on the control's own completion file.
    No other agent's process was listed or signalled.
- The goldens for the fresh cases come from the pinned Surelog with check_probe's arguments, cached under
  /tmp/v11u288_gold by source md5 and view.
