# v11u401 — adversarial verification of r11u401 (the expression/parameter ground on sv-tests, pair A)

Base `eee9c5fd4` (matrix-1.87). Implementer patch `/tmp/r11u401.patch` applied clean on a fresh
worktree. Verified patch: `/tmp/r11u401.verified.patch` (the implementer's laws unchanged, plus
three refinements behind `fixOn(401, "R11V401_<X>_OFF")` from `src/LawSwitch.h`; `R11V401_OFF`
drops all three; no `src/R*.h`, no `getenv`, no reader function).

## Verdict

PASS WITH THREE REFINEMENTS. Every headline number of r11u401 reproduces exactly: the five
stages, the 65 sv-tests conversions (same list, row for row), the 160-view grid. One fresh case
broke a law on legal SV where pristine was right (§ strLitMacroRefSubst401 expanded a macro
defined AFTER the string literal; pristine STRICT_EQUAL, law NOT_EQUAL, chain away 6). That is
fixed by § strLitMacroDefBeforeUse401v. Two more refinements fix faces where pristine was also
wrong and the law wrote the wrong shape: § intraAsgEventSpanInner401v (spans) and
§ randSeqListRule401v (randsequence in a subroutine body). None of the three moves a corpus row,
a probe case, a downstream row or an sv-tests status.

## Binaries (built `-j 2`, frozen `chmod 555` under /tmp/v11u401_bin before any measurement)

| binary | md5 |
|---|---|
| pristine (eee9c5fd4) | `2982d1ee861fb421aceffc8c0cc4e18f` (= main tree `build/slang-uhdm`) |
| law (eee9c5fd4 + r11u401.patch) | `674e9baeed2ead711fa9f7a7c4a2cd4a` (= the implementer's) |
| verified (law + the three refinements, "v3") | `0af515598480f5b9de5b1d49d3937da6` |

slang 12.0.0+545f88b2e, UHDM 1.87. Intermediate refinement builds (`51d74a28...`,
`dc3dd901...`) were used only for the grids that designed the refinements.

## Gates (tests/sweep.sh --jobs 3 from the worktree, the sv-tests stage through the main tree's
scripts/check_svtests.py, as the implementer did, because a worktree has no UVM tree)

| stage | pristine `/tmp/v11u401_wP` | law `/tmp/v11u401_wL` | verified `/tmp/v11u401_wV` |
|---|---|---|---|
| probe | 4017 + 70, 0/0/0 | 4017 + 70, 0/0/0 | 4017 + 70, 0/0/0 |
| surelog | 480 + 0 / 474 + 0, 0/0/0 | same | same |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | same | same |
| downstream | 803 / 66 / 2 / 0 | same, verdict csv identical | same, verdict csv identical |
| sv-tests | 1153/23/705/309/133/13/1/8/1, 0/0/0 | 1206/21/686/303/101/18/1/8/2, 0 reg, 65 conv, 1 change | 1206/21/686/304/101/18/1/8/1, **0 reg, 65 conv, 0 changes** |

The sv-tests counts read EQUAL/STRICT_NOTEQUAL/DIFFERENT/BOTH_REJECT/SURELOG_ONLY/SLANG_ONLY/
SLANG_CRASH/SURELOG_CRASH/TIMEOUT. The law run's one change (`generated/uvm-examples/uart_example.sv`
BOTH_REJECT -> TIMEOUT) is load: my case grids ran during that stage; the verified run, made with
nothing else of mine running, reads BOTH_REJECT and no change, as the implementer's did. The 65
conversions of the law run and of the verified run are the implementer's list exactly
(`evidence/svtests_law.txt`, `svtests_verified.txt`). The pristine and verified sv-tests rows differ
only by those 65 (csv sorted diff, workdir normalised).

Law sweep rc=1 on the law-index check alone (my repro dir was added during the run); the verified
sweep, after `python3 scripts/law_index.py`, reads rc=0.

* byteverify (SELFCHECK=1, same-length workdirs): law vs pristine and verified vs pristine,
  surelog **0 / 960** (selfcheck 959/960), uhdm2rtlil **0 / 1608** (1607/1608), downstream
  **0 / 805** (804/805), probe (all 4087 databases, cmp) **0 / 4087**. The implementer reported
  the probe on its 15 firing cases only; all 4087 now read 0. Strict columns: identical row for row
  (the only csv text difference is the workdir path inside the LowMem SURELOG_FAIL detail).
* sv-tests databases (the 807 the runner keeps), compared by normalised `uhdm-dump`
  (`drivers/svdump.sh`, `evidence/svtests_dumps.txt`; the capnp packing splits path text, so a
  byte compare with the workdir replaced is useless): verified == law on **807 / 807**; law vs
  pristine 420 movers = 53 rows pristine left without a database (the goal-1 acceptances) + 367
  rows with both, 355 of them basejump (§ pkgEnumParamFold401 and its untyped / unbased
  siblings: the package-parameter heads cleared, the rows stay DIFFERENT on the sister's
  allModules face). Chain-keyed away census on the 361 of the 367 with a Surelog golden
  (`drivers/svaway.sh`, `evidence/svtests_away.txt`): **chain away 0 and flat away 0 on 361 / 361**,
  33075 records toward golden; the other 6 have no golden (Surelog rejects or crashes: 18.17.3,
  6.23, rggen, rsd, uvm_slave_agent and its twin).
* canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, on all three sweeps; ctcan2
  (EXPECT_UNKNOWN=1 / 6) PASS on all six csvs.
* binary audit (cmds.txt by binary PATH): law sweep 5619 law / 0 pristine, pristine sweep 0 law /
  all pristine, verified corpus stages 3273 v3 / 0 other of 3323 (the 50 others are Surelog-only
  rows that run no slang-uhdm).
* uhdm-cmp at 0 lines on every touched row: no corpus row or probe case moves in bytes.

## Implementer grid reproduced (tools/probe/r11u401repro, own golden cache /tmp/v11u401_gold)

160 case-views, 140 moving, 122 entering STRICT_EQUAL, 0 leaving, R11U401_OFF == pristine on
160/160 (`evidence/implgrid_law.txt`). With the verified binary: identical bytes on 158/160; the
two others are IA/ia04_list d/e, STRICT_NOTEQUAL col -> STRICT_EQUAL (§ intraAsgEventSpanInner401v),
and law+R11V401_OFF equals the law binary on 160/160 (`evidence/implgrid_v3.txt`).

## Fresh attack grid (cases/, 66 case dirs in 19 groups, both views = 132 case-views)

`drivers/grid.sh` (pristine, verified, verified+R11U401_OFF, +R11V401_OFF and each refinement
switch), `evidence/grid.txt`, summary `evidence/gridsum.txt`. Verified binary: 110 moving, 77
entering STRICT_EQUAL, **0 leaving**, R11U401_OFF == pristine on 132/132; R11V401_OFF equals the
r11u401 law binary on every case-view measured with both (130/130). Chain-keyed away census
(`drivers/away.sh`, the v11u314 awaychain/awayrows records of strictcmp_x) over all 110 movers:
**chain away 0** on 110/110, 1097 records toward golden; the positive control is SM/vs01 on the
r11u401 law binary (chain away 6). Flat away 1 on CE/vs01 d/e only: golden holds enum_const CC
twice (class typespec, depth 3, and a reference), pristine three times (two through its BOUND
ref_obj of `o.CC`, which golden leaves unbound), the law once; the chain census is 0 and the
law's hier_path is golden's. Downstream verdict on the 61 class-free cases
(`drivers/dscases.sh`, `evidence/downstream_cases.txt`): 22 improve (7 DIVERGENT, 11 EQUIVALENT,
4 STATUS_DIFF -> IDENTICAL), none worse.

Groups and laws (each case names its law in its first line):

| group | law | cases |
|---|---|---|
| AM | § kwArrayMethodIsCallElem401 | vs01_with, vs02_queue_unique, vs03_member (all STRICT_EQUAL) |
| AP | § asgOpInnermostParenSpan401 | vs01_quad, vs03_stmt (STRICT_EQUAL); vs02_cond (still NE, toward 4) |
| BT | § bitsBlockLocalKeepsCall401 | vs01-vs05, vs07 (STRICT_EQUAL; vs04 task block control); vs06_decl_range (NE, toward 4) |
| CE | § classEnumViaHandleIsPath401 | vs01_this, vs02_this_only (NE at the class typespec listing, sister) |
| CS | § concatRangeSelIsConcat401 | vs01_idx_part, vs03_nested (STRICT_EQUAL), vs02_assign (STRICT_NOTEQUAL count, was rejected) |
| EA | § sysCallEmptyArgIsIntZero401 | vs01_fwrite, vs03_func, vs04_two_lead (STRICT_EQUAL); vs02_nested (slang rejects, rc 3 on both) |
| EV | § bothEdgeIsAnyEdgeOp401 | vs01_edge_list, vs02_edge_iff (STRICT_EQUAL) |
| IA | § intraAsgEventCtrlEmptyDelay401 + § intraAsgEventSpanInner401v | vs01_noparen, vs02_named_event, vs04_func_blocking (law col -> STRICT_EQUAL by the refinement), vs03_iff |
| LE | § logEquivIsEqOp401 | vs01_nested, vs02_param (STRICT_EQUAL) |
| MA | § ifacePortArrMemberChainPath401 | vs01_hier_struct, vs02_iface_arr (controls, no firing, bytes equal) |
| PC | § procCheckerIsCheckerInst401 | vs01_two_instances (STRICT_EQUAL) |
| PD | § forceIsForceObj401 / § deassignReleaseObj401 | vs01-vs04 (STRICT_EQUAL) |
| PE | § pkgEnumParamFold401 / § pkgEnumUntypedParamFold401 | vs02_import (STRICT_EQUAL); vs01, vs03, vs04 (NE, heads later in the walk, toward 30/24/12) |
| PU | § unbasedUntypedElabKeepsLiteral401 | vs01, vs02 (NE, toward 2/8), vs03_overridden (NE, toward 0-1) |
| RC | § randCaseIsRandCaseStmt401 | vs01-vs03 (STRICT_EQUAL) |
| RS | § randSequenceDropped401 + § randSeqListRule401v | vs04_only, vs05_modfunc (STRICT_EQUAL); vs06_task_after, vs07_class (STRICT_EQUAL by the refinement); vs01, vs02, vs03, vs08 (NE: residue 2) |
| SC | § castSizeSubrLocalBind401 | vs01_task_class (NE at the class function listing, sister) |
| SM | § strLitMacroRefSubst401 + § strLitMacroDefBeforeUse401v | vs01_defined_after (THE BREAK, back to pristine STRICT_EQUAL), vs02_redefined (abstains, pristine bytes), vs03_undef (control), vs05, vs06 (STRICT_EQUAL), vs04 (Surelog fails, no golden) |
| VD | § loneVarDeclStmtDropped401 | vs01-vs03 (bytes equal pristine, exit 4 -> 0, NE: residue 1), vs04 (control) |

## Refinements (src only on this ground; each droppable alone)

* § strLitMacroDefBeforeUse401v (ExprEmit, `R11V401_STRMACDEF_OFF`) — § strLitMacroRefSubst401
  read every object-like macro defined anywhere in the trees. Surelog's preprocessor expands a
  `` `NAME `` inside a string only when the macro is defined BEFORE the literal in the flattened
  text (cases/SM vs01: golden keeps `"`FOO is here"` where FOO is defined two lines later;
  pristine STRICT_EQUAL, law NOT_EQUAL with 6 records away). The refinement keeps each macro's
  final definition location and substitutes only when it precedes the literal's expansion site
  (§ includeExpandedKey order). A macro redefined after the use abstains (vs02 reads pristine's
  bytes; golden expands the earlier definition there: a residue that pristine shares).
* § intraAsgEventSpanInner401v (ExprEmit, `R11V401_ASGEVSPAN_OFF`) — the empty delay_control of
  § intraAsgEventCtrlEmptyDelay401 spans golden's location in three more forms: an `or` list
  inside the parens (`@(posedge clk or negedge clk)`, slang's EventList range kept the parens),
  a bare name without the `@` (`a = @clk b;`), and a parenthesised repeat count
  (`repeat ((2))` at the `2`). IA vs01, vs02, vs04 and the implementer's ia04 move col ->
  STRICT_EQUAL.
* § randSeqListRule401v (StmtEmit, `R11V401_RANDSEQLIST_OFF`) — the randsequence cut is a
  SUBROUTINE-BODY rule and there it takes the whole list. Surelog files the sequence in the
  body's statement group (UHDM: "adding wrong object type (sequence_decl) in a stmt group"), so
  the body keeps the begin wrapper its item count decides and lists no statement at all, the
  ones BEFORE the randsequence too (RS vs06: golden loses `x = 0;`; vs07: an empty begin anchored
  at `y = 2;`, which the law dropped while pristine's rejected database had it). A procedural
  block list never reached the cut (vs02/vs03 keep their statements on every binary).

## sv-tests (verified binary): base -> after, by path

The same 65 conversions the implementer lists (tools/probe/r11u401repro/README.md, attribution
unchanged; `evidence/svtests_verified.txt`), 0 regressions, 0 changes. The three refinements move
no sv-tests status (predicted: no 9.4.5 row has an `or` list, a bare `@name` or a parenthesised
count; no string-macro row defines the macro after the use; the 18.17 rows already listed
nothing). Database movers between the law and the verified sv-tests runs: 0 of 807 by
normalised dump, as predicted.

## Residues (ranked; all wrong on pristine too, none moved away)

1. § loneVarDeclStmtDropped401 is too broad. A lone declaration whose initializer is NOT a `new`
   keeps golden's hoisted assignment as the subroutine's vpiStmt (VD/vs01 `int v = 5;` in a
   function, vs02's task `int k = 3;`, vs03's `automatic int w = 7;`). The law writes nothing and
   now exits 0 where pristine exited 4 with the same bytes. Fix: route the lone declaration
   through the list branch's hoist (`hoists145v`, § declInitWrittenNewNoStmt66). vs02 also lists
   the class_var twice (TaskFuncEmit, sister).
2. randsequence in a PROCEDURAL block: golden lists a `sequence_decl` (named by the production,
   spanning the statement) under the enclosing begin's vpiSequenceDecl and keeps the other
   statements (RS vs01, vs02, vs03, vs08). We write nothing for it.
3. PE vs01/vs03: a module reading an untyped package parameter folded from an enum member gets
   UINT where golden reads INT (cont_assign constant); vs04 the package param_assign fold of
   `m + 1`.
4. PU vs01-vs03: the module-scope `'1`/`'z` constant ref_typespec (vs01), the module's read of a
   package `'1` (vs02), the overridden instance parameter (vs03).
5. AP/vs02_cond (`if (((a += 1)))`, the operation inside a binary op), BT/vs06 (`$bits(v)` in
   another block variable's range), CS/vs02 (continuous `assign a = {b,c}[6:3]`, object count in
   the definition view), SM/vs02 (a macro redefined after the use).
6. The implementer's residues stand as listed in its README (basejump 313 + 31 rows, variable
   initializers, associative index spans, `$unit` parameters, SequenceWithMatch, include columns,
   the module-scope x/z typed parameter size).

## Sister-ground faces (reported, not written)

* CE vs01/vs02: the class's enum typespec / class_defn listing (the head before the law's
  hier_path is reached).
* SC vs01 and VD vs02: the class function listing (TaskFuncEmit: a function-local localparam
  listing, the class_var listed twice).
* The implementer's sister list stands.

## Process

* Nothing written outside /tmp/wt_v11u401, /tmp/wt_v11u401pris, /tmp/wt_v11u401v (the
  refinement build tree, so the frozen sweeps' worktree build was never rebuilt mid-sweep) and
  /tmp/v11u401_*. No fenced test dispatched (case.sh fails closed on $FENCED; sv-tests holds none).
* SLIPS, no effect on a measurement: (1) my case grids ran during the law sweep's sv-tests stage
  (the uart_example TIMEOUT above; the verified stage was rerun with nothing of mine running);
  (2) one dump comparison ran with `$UHDM_DUMP` unset in that shell, so bash executed one
  `slang.uhdm` (written executable) from /tmp as a script: it printed "command not found" lines
  and created no file (find -mmin over /tmp, the main repo and the workdir read only the sister's
  and the stage's own files); every later dump loop names the tool by absolute path behind
  `[ -x ]`; (3) a first sv-tests mover count replaced the workdir in packed capnp bytes and read
  754 of 754 as movers on every pair, pristine-vs-law included; discarded for the dump compare;
  (4) the first refinement build named the cmake target `slang-uhdm` (no such rule) and built
  nothing; rebuilt as `slang_uhdm`.
