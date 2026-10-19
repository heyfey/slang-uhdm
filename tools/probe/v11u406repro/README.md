# v11u406 — adversarial verification of r11u406 (pass 406, module/type ground): ACCEPT WITH THREE REFINEMENTS

Verifier of /tmp/r11u406.patch (md5 4208379ada68a9d85547d137b485bcf0) at base 22bc000f7. The patch applies clean
on a fresh worktree (/tmp/wt_v11u406). Per the measurement budget, no pristine binary was rebuilt and no pristine
sweep was run: the pristine reading is the master's control sweep /tmp/intr11u404 and the implementer's frozen
pristine copy (md5 6ee88056d0a8447122ae3a598417db1f, the base build). Binaries, each frozen (chmod 555 under
/tmp/v11u406_bin) before it was measured, all reporting slang 12.0.0+545f88b2e:

- law (the implementer's patch, built here with -j 2) 283350dabc3ac201906b83489f837973, equal to the implementer's
  law.bin;
- verified (the patch plus the three refinements below) fc90591ed136ae870d57d0cc8f25efff (`ver4.bin`; the
  intermediate builds ver.bin, ver2.bin and ver3.bin were grid-only, never swept to completion, see Process).

The three refinements read their switches through src/LawSwitch.h with `fixOn(406, ...)`; `R11V406_OFF` drops all
three; `R11U406_OFF` still drops the whole pass (the refinements sit inside the law branches). No src/R*.h, no
getenv, no reader function, no LawState.h section, include/ unchanged.

## Verdict

Every headline number of the implementer reproduces bit for bit on the law binary. The fresh cases found two
faces where the law is wrong and pristine was right or more complete, both on legal SV, and one gap of the same
chain law; all three are fixed below behind their own switches. With the fixes no fresh case, corpus row, probe
case, downstream row or sv-tests row moves away from golden.

| stage | pristine (control /tmp/intr11u404) | law | verified |
|---|---|---|---|
| probe | 4018 + 69 | 4018 + 69, 0/0/0 | 4018 + 69, 0/0/0 |
| surelog | 480 + 0 / 474 + 0 | 480 + 0 / 474 + 0, 0/0/0 | 480 + 0 / 474 + 0, 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes | 803/1/67 both modes, 0/0/0 | 803/1/67 both modes, 0/0/0 |
| downstream | 803 / 66 / 2 / 0 | IDENTICAL 803, EQUIVALENT 2, SLANG_REJECT 66, not excused 0 | IDENTICAL 803, EQUIVALENT 2, SLANG_REJECT 66, not excused 0 |
| sv-tests | EQUAL 1534, DIFFERENT 390, SURELOG_ONLY 83 | **0 regressions, 21 conversions, 0 changes** | **0 / 21 / 0**, the same 21 rows |

The counts are regressions / conversions / changes against the base's results/*.csv (the sv-tests stage ran the
main tree's scripts/check_svtests.py read-only with `--baseline` the worktree's results/golden_svtests.csv, i.e.
the base 22bc000f, because a worktree has no UVM tree and the main tree's baseline already holds pass 403).

- **sv-tests, law.** The 21 conversions are the implementer's list path for path (evidence/svtests_law.log):
  generic/typedef/typedef_test_13.sv SURELOG_ONLY -> EQUAL; chapter-16/16.2--assert-final.sv, 16.2--assert0.sv,
  16.2--assume-final.sv, 16.2--assume0.sv, 16.2--cover-final.sv, 16.2--cover0.sv, 16.7--sequence.sv,
  16.9--sequence-cons-repetition.sv, 16.9--sequence-goto-repetition.sv, 16.9--sequence-noncons-repetition.sv,
  chapter-5/5.8-time-literals.sv, generated/integers/6.11--integer_time.sv, 6.11--integer_signed_time.sv,
  6.11--integer_unsigned_time.sv, chapter-12/12.7.3--foreach.sv, 12.7.4--while.sv, 12.7.5--dowhile.sv,
  chapter-7/queues/bounded.sv, max-size.sv and slice.sv DIFFERENT -> EQUAL. Counts EQUAL 1555, STRICT_NOTEQUAL 8,
  DIFFERENT 370, SURELOG_ONLY 82, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346.
- **sv-tests, verified.** the same 21 conversions; the csv is identical to the law sweep's on all 2346 rows (evidence/svtests_verified.log); the 406 sv-tests databases both sweeps keep are identical by normalised dump on 405, the 406th (generated/tnoc/tnoc, a 230 MB partial database of the SURELOG_ONLY row) not dumped (evidence/svtests_dumps_ver_vs_law.txt). As predicted, no sv-tests row holds a typedef'd time variable or a three-element chain with a leading or inner ranged delay.
- **Byte movers, law vs the control** (byteverify, SELFCHECK=1, same-length workdir names /tmp/v11u406law and
  /tmp/intr11u404): surelog 0 of 962 (selfcheck 961 of 962 flagged), uhdm2rtlil 0 of 1608 (1607 of 1608),
  downstream 0 of 805 (804 of 805). Probe: every raw database embeds its worktree path, so the 4087 databases were
  compared by uhdm-dump with the header line dropped and /tmp/wt_v11u406/ mapped to the main tree: 4087 of 4087
  identical, positive control (two different cases) differs (evidence/byteverify_law.txt).
- **Byte movers, verified vs law:** surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805 (byteverify, SELFCHECK passing), probe 0 of 4087 raw bytes (both sweeps from the same worktree path); the probe, uhdm2rtlil, downstream and sv-tests csvs are identical to the law sweep's row for row, the surelog csv differs only in the LowMemLib / LowMemPkg testflags detail text that carries the workdir path (evidence/byteverify_ver_vs_law.txt). As predicted: the refinements act only inside law branches that move no corpus or probe byte.
- **Canaries** (law): ok=52 changed=0 and ok=16 changed=0; ctcan2 EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6 PASS
  (evidence/canaries_law.txt). Verified: ok=52 changed=0, ok=16 changed=0, both ctcan2 PASS (evidence/canaries_verified.txt).
- **Binary audit** (drivers/audit.sh; the cmds.txt path list is filtered on the fence line of
  tools/probe/r11u107repro/canaudit.sh BEFORE any file is opened): law 5659 cmds.txt, 5609 name the law binary,
  0 another, 50 with no slang line (Surelog-only corpus rows). Verified: 5659 cmds.txt, 5609 name the verified binary, 0 another, 50 none (evidence/binary_audit_verified.txt).
- **Implementer's grid** (63 case dirs, rerun with my pristine copy and law binary, evidence/grid_impl_cases_law.txt):
  the verdict columns equal the implementer's evidence/grid406.txt on 63 of 63 lines; `R11U406_OFF` gives
  pristine's bytes on 63 of 63. With the verified binary all 63 keep the law's bytes (evidence/vgrid_impl.txt).
- **sv-tests away census** (drivers/away.sh; the rows DIFFERENT or STRICT_NOTEQUAL kept by both sweeps, golden
  from the golden cache the row's cmds.txt names): the 427 databases the control keeps: 21 GONE (the converted rows, whose database the runner deletes), 377 with an identical normalised dump, **19 toward golden, 0 away, 0 at the same distance**, 9 with no Surelog database (SLANG_ONLY rows: 8 identical dumps, generated/rsd/rsd 105 MB not dumped), generated/tnoc/tnoc (230 MB partial database of the SURELOG_ONLY row) not dumped. The distance is the multiset of dump lines (order-insensitive, drivers/msdist.py); the diff line count is printed beside it and agrees on the 5 non-UVM movers (chapter-16/16.10--sequence-local-var and -fail 90 -> 9, chapter-9/9.4.2.4--event_sequence 77 -> 8, chapter-5/5.9-string-word-assignment 16 -> 10, generic/typedef/typedef_test_9 81 -> 40, the implementer's five) and on 4 of the 14 UVM sequence rows, but rises on the other 10 (chapter-16/16.7, 16.9, 16.10, 16.11, 16.13 -uvm rows: multiset 85009 -> 84906 and alike), where the law adds the module's sequence_decl that golden also lists and GNU diff realigns the 1.1M-line dumps (evidence/away_census_svtests_verified.txt).

- **A correction to the implementer's census:** its away census left the UVM rows out and judged them by the
  absence of a trace on uvm/uvm_files.sv alone. The laws DO fire on 14 UVM rows (the chapter-16 sequence tests,
  whose test modules declare sequences: § sequenceDeclListed406 and § seqConcatNestsRight406): every one of them
  moves toward golden by the multiset metric and stays DIFFERENT; uvm/uvm_files.sv itself keeps its dump.
- **Determinism:** three concurrent draws of the verified binary on chapter-16/16.11--sequence-subroutine-uvm.sv
  (with the UVM package) and on 16.9--sequence-noncons-repetition.sv: one hash each (evidence/determinism_verified.txt).

## The breaks found and the refinements

### 1. § timeNetKeywordOnly406v (TypeEmit makeVar, `R11V406_TIMEKW_OFF`; cases VT/vt07, vt13, vt14, vt15)

§ timeModVarIsNet406 turns every static module-body `time` variable without `var` and without an initializer into
a net. Golden does that only when the declaration WRITES the `time` keyword: a variable declared through a name
stays a time_var.

| case | source | pristine | law | verified |
|---|---|---|---|---|
| VT/vt07_signed_typedef_func | `typedef time signed ts_t; ts_t v;` + a `time unsigned` function | STRICT_NOTEQUAL endcol (judge-equal), downstream IDENTICAL | **NOT_EQUAL** (v a logic_net), downstream **EQUIVALENT** | STRICT_EQUAL 135, IDENTICAL |
| VT/vt13_typeparam_time | `parameter type T = time; T v;` | NOT_EQUAL, 17 dump lines | NOT_EQUAL, 18 (away) | STRICT_EQUAL 111 |
| VT/vt14_typedef_unsigned | module-body `typedef time tt_t; tt_t a;` | NOT_EQUAL, 19 | NOT_EQUAL, 19 (moved, same distance) | STRICT_EQUAL 125 |
| VT/vt15_pkg_typedef_time | `pk::pt_t a;` | NOT_EQUAL, 32 | NOT_EQUAL, 32 (moved, same distance) | STRICT_NOTEQUAL name |

vt07 is the break: pristine judge-equal and downstream IDENTICAL, the law leaving both. The refinement keys on the
declared type syntax (`SyntaxKind::TimeType`); every `time`-keyword case of the law (TM, VT/vt01-vt06, vt08-vt12,
VK/vk08, vk09) keeps the law's bytes. Prediction: no sv-tests source writes `typedef time` or a type parameter
defaulting to time (grep over the fence-filtered list of 2346 sources, positive control on these four cases), and
the law moved no corpus byte, so the refinement moves no corpus row, probe case or sv-tests row.

### 2. § seqNestLeadingDelay406v (ModuleEmit emitAssertionExpr SequenceConcat, `R11V406_SEQLEAD_OFF`; cases VQ/vq20, vq21, vq24, vq26)

§ seqConcatNestsRight406 nests a concatenation of three or more elements to the right but started the chain at
element 0 and never wrote element 0's own delay: `##1 a ##1 b ##1 c` (a sequence body) and the consequent of
`a |-> ##1 b ##1 c ##1 d` (a property body) lost the leading `##1` altogether, where pristine kept it as the first
operand of its flat operation. Golden writes the unary cycle-delay operation (53) spanning from the leading `##`
to the last element, its operands the leading delay (a constant, or for `##[1:2]` the range operand of
§ sequenceDeclListed406) and the right-nested chain. Measured: vq20 NOT_EQUAL 63 -> law 61 -> verified
STRICT_EQUAL; vq21 82 -> 61 -> STRICT_EQUAL; vq24 (`##[1:2] a ##1 b ##1 c`) 71 -> 77 (law away) -> STRICT_EQUAL
(the operation starts at the `##` before the range's `[`); vq26 STRICT_EQUAL with refinement 3. Two-element
chains (VQ/vq22) and inline assertions (VQ/vq23, pristine STRICT_EQUAL) are not reached by the law and stay.

### 3. § seqNestRangedDelay406v (same site, `R11V406_SEQRANGE_OFF`; cases VQ/vq01, vq25, vq26)

Inside the nested chain a RANGED delay (`a ##[1:2] b ##1 c`, `a |-> b ##[2:3] c ##1 d`) was written as the
minimum alone (a constant spanning `##[1:2]`, the maximum lost), where the law's own flat form
(§ sequenceDeclListed406) and golden write a range operand at `1:2`. Measured: vq01 60 -> law 18 -> STRICT_EQUAL;
vq25 STRICT_EQUAL. Pristine also wrote the minimum alone (flat), so this one is a gap of the law, not a break;
it is fixed because the range builder is the one refinement 2 needs.

Every refinement mover is restored to the law's bytes by its own switch (vq26 by SEQLEAD and SEQRANGE together;
evidence/own_switch_refinements.txt); `R11V406_OFF` and the three switches together give the law's bytes on
101 of 101 of my cases and 63 of 63 of the implementer's; `R11U406_OFF` on the verified binary gives pristine's
bytes and exit code on 164 of 164 (evidence/off_check_verified.txt).

## The attack grid (101 case dirs in 7 groups, evidence/grid_law.txt and grid_verified.txt)

Each case: Surelog v1.87 golden (`-parse -sverilog`, `--top-module top` when the case declares `top`), pristine,
law (with `R11U406_TRACE`), `R11U406_OFF`, the case's own switch; verdict = uhdm-cmp then build/uhdm-strictcmp,
plus the dump-diff line count to golden ("dd"). Downstream: scripts/downstream_uhdm2rtlil.py `one()` on the 98
class-free cases (drivers/ds.py).

| group | law | cases | what |
|---|---|---|---|
| VA | § unitAssocTdMultiDim406, § assocIdxParamBoundTs406, § aliasElemDynTd406 | 23 | $unit/module 2-D and 3-D typedefs used by ports, struct members, subroutine args/returns, two instances, parameter dims; struct/enum elements; parameter-bound index keywords; alias-element queues/dynamic arrays (chains, struct/enum elements, two instances) |
| VB | § boundedQueueVarStatic406 | 8 | logic-vector / string / expression-bound / initialised / generate / interface / class / function-local bounded queues, a child with two parameterisations |
| VD | § deferredAssertItemDropped406 | 7 | action blocks, generate for / if / case, an interface plus a child, an uninstantiated module whose only item is a deferred assertion, mixed with concurrent and procedural assertions |
| VK | mixed | 12 | the contexts where pristine may be right: package, port, class and function-static arrays; `.triggered` on a listed sequence; property antecedent / `not` chains; time through a port connection; sequence formals with defaults |
| VQ | § sequenceDeclListed406, § seqConcatNestsRight406 (+ refinements 2, 3) | 26 | ranged / spaced / parameter / zero delays, args, sequences of sequences, two instances, interface and generate sequences, cover sequence, typed formals, or / throughout, default clocking, disable iff, uninstantiated module, leading delays |
| VS | § arrElemVarKind406 | 10 | 2-D string, unsigned and real kinds, initialisers, generate / interface, other kinds (control), function local, chandle / event, two parameterisations, typedef elements |
| VT | § timeModVarIsNet406, § timeTsKeywordSpan406 (+ refinement 1) | 15 | always / initial / continuous drivers, program (control), static keyword, signed ports, typedef and function returns, struct member, hierarchical write, class property, function static, localparam, type parameter, package typedef |

Results on the verified binary vs pristine: 86 cases move toward golden, 15 keep pristine's bytes, **0 away, 0 at
the same distance**; 63 STRICT_EQUAL (57 entering: 55 from NOT_EQUAL including 6 that pristine rejected with exit
4, vt07 and vt08 from STRICT_NOTEQUAL; the 6 pristine-STRICT_EQUAL controls vk04, vk12, vq23, vs06, vs07, vt11 keep
pristine's bytes), 4 STRICT_NOTEQUAL (va11 and va17 fullname, vs10 depth, vt15 name; all NOT_EQUAL on pristine).
On the law binary: 81 toward, 15 same bytes, 3 away (vt07, vt13, vq24), 2 at the same distance (vt14, vt15).
Downstream on the 98 class-free cases, pristine vs verified: 28 improve to IDENTICAL, va20 DIVERGENT ->
EQUIVALENT, none worse (law: vt07 IDENTICAL -> EQUIVALENT, restored by refinement 1).

## Residues (all NOT_EQUAL on pristine too, none moved away), ranked

1. Multi-dimension typedef uses (VA/va01 port, va05 module body as at18, va09 parameter dims, va19 struct member,
   va20 subroutine argument and return, va22 per-instance dims): golden binds the use to the named array_typespec
   `t2` at the typedef where we list an unnamed copy at the use; the element kinds struct / enum (va07, va08) list
   the element typespec where golden lists the array.
2. Alias-element dynamic typedefs used in a subroutine argument (va13), with struct / enum elements (va14), alias
   chains (va15: golden keeps the `b_t` alias chain) and module-body two-instance listings (va16).
3. Module-body associative index bound naming a localparam (va12: golden lists the module-body a_t listing).
4. Bounded queues with an expression bound or a per-instance parameter (VB/vb03, vb08), in generate scopes,
   interfaces, classes and function locals (vb05, vb06: not reached).
5. Element kinds: shortreal elements carry a ref_typespec golden omits (VS/vs03); generate / interface arrays
   (vs05) and chandle / event arrays (vs08) not reached; a typedef element's typespec span (vs10).
6. Sequences: a spaced delay `## 2` (golden spans `## 2` with decompile " 2"; vq02), the property_spec order of
   a cover with a listed sequence (vq07), `cover sequence` (vq08), `(…) or (…)` operands (vq10), a delay naming a
   parameter (vq11), formals with defaults (VK/vk10); interface and generate-block sequences not listed (vq06,
   vq12, the law reaches module bodies only).
7. Time: signed time port spans (VT/vt06, one line), plus the implementer's TM/tm03, tm05-tm07 and `realtime`.
8. The implementer's ranked residues (README of r11u406repro) stand unchanged.

## Sister-ground faces (reported, not written)

The implementer's four faces stand (basejump size casts by a default-less parameter in ParamEmit; the `@seq` event
control in StmtEmit emitEventExpr; a sequence's local variable golden binds to an implicit module net, the
formal-reference binder in ExprEmit; hierarchical references minting implicit nets). The UVM sequence rows
(chapter-16/16.10--sequence-local-var-uvm, 16.11--sequence-subroutine-uvm) show the third one inside the listed
sequence_decl: the only difference left in that block is golden's `x` bound to logic_net work@top.x.

## Process

- My first binary audit ran grep over the law sweep's cmds.txt list before the fence filter took effect (the fence
  line holds space-separated names and my first regex treated it as one alternative): it opened the harness's
  command records of 10 fenced row-modes (not sources, not databases; nothing dispatched). The reported audit is
  the corrected one, filtered on the four names before any file is opened. This is the same slip the implementer
  reported.
- A first verified sweep (binary ver.bin, refinement 1 only) was stopped by its task id during its surelog stage
  when refinement 2 was found, and its workdir deleted; the only full verified sweep is the one on ver4.bin. ver2
  (refinement 2 abstaining on a ranged leading delay) and ver3 (ranged form, column one off) were measured on the
  grid only; the ranged leading case vq24 showed ver2 away from golden and ver3 one column off, both fixed in ver4.
- The source edits for refinements 2 and 3 were made in the worktree while the law sweep's sv-tests stage ran (it
  reads only the frozen binary and the worktree's results/ baseline; the law index check runs at the sweep's start).
- My first sv-tests away census measured distance by diff line count and read the UVM rows as away: on 1.1M-line
  dumps GNU diff's alignment is not monotone (16.11--sequence-subroutine-uvm: the law adds the 105-line
  sequence_decl golden also has, block-diff 2 differences, yet the diff count rose 207437 -> 210970). The census
  reported above classifies by the multiset of dump lines (order-insensitive) and prints both counts.
- Nothing written outside /tmp/wt_v11u406 and /tmp/v11u406_*; no other agent's process touched (every stop by my
  own task id); results/, third_party/ and the sv-tests checkout untouched; no fenced test dispatched or spelled.

## Drivers

drivers/env.sh, grid.sh (pristine vs a binary per case), vgrid.sh (law vs verified, refinement switches),
ds.py (downstream per case), sweep.sh (four corpus stages then sv-tests against the base baseline), audit.sh
(fence-filtered binary audit), away.sh + msdist.py (sv-tests away census), pnorm.sh (probe normalised compare).
