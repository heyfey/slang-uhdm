# v11u315 — adversarial verification of r11u315

Base 494dcae5 (pass 313). Implementer's patch /tmp/r11u315.patch (six laws in src/ModuleEmit.cpp,
tools/probe/r11u315repro). This dir: 89 fresh case dirs in VO, VL, VK, VU and VD (both views), the drivers
(copied from r11u315repro/drivers, plus gridfix.sh, gsum.py and gsum2.py) and evidence/.

## Verdict

**One break, fixed behind its own switch.** § genIfaceHcCallArgUnbound315 unbinds every reference that is a system
call's argument in a generate block. A name declared INSIDE the generate block keeps its binding in golden. On
VU/vu08_sys_local_and_outer (`logic l;` in the block, `.clk($signed(l) & a)`), the default view went from judge-equal
(pristine STRICT_NOTEQUAL fullname, uhdm-cmp 0 lines) to uhdm-cmp stage 1 under the law (31 lines). The head is
`ref_obj work@top.g.u.clk.l`: golden's vpiActual is `logic_var work@top.g.l`, the law's is `<null>`. Pristine had the
right binding and the wrong name.

The chain-keyed and order-blind away censuses both read 0 on vu08. The bound object is listed elsewhere in the walk,
so a dropped vpiActual is invisible to the records. Only uhdm-cmp's line count saw it.

The fix is § genCallArgLocalKeepsBind315v (switch `R11V315_GENLOCALBIND_OFF`, read with
`fixOn(315, ...)`; `R11V315_OFF` gives the law's bytes). The law now stands aside on a reference whose slang symbol
is declared in a GenerateBlock scope. These references are collected from the actual's slang expression and matched
by start position, as castLeaves193 does. Under the fix:
- the four case-views that differ from the law (vu04, vu08, vu09 and vu11, default view) all enter STRICT_EQUAL;
- `R11V315_GENLOCALBIND_OFF` restores the law's bytes on each of them;
- no other case-view in either repro dir moves between the law and the fix (354 of 354).

The rest of the implementer's report reproduces bit for bit; every number is below.

## Binaries (built here with -j 1 and frozen with chmod 555 before any measurement)

| binary | md5 |
|---|---|
| pristine (494dcae5) | 38e604258c7254491e9b6cb732d66e36 (equal to the main tree's build and the implementer's) |
| law (/tmp/r11u315.patch) | 233af0ffdaf0de9473fe59f45504cd3e (equal to the implementer's) |
| fix (law + § genCallArgLocalKeepsBind315v) | 4f4e3b7d3caecfcdeaa821c108ed0cc0 |
| uhdm-strictcmp / strictcmp_x | fa6e4f42f252ae0ab69d9845003e71c5 / 886f030233ecdbcce7d0e29ac0c4df2c |

All three link slang 12.0.0+545f88b2e.

## Reproduction of the implementer's numbers (law binary)

- **Grid:** r11u315repro's 88 dirs, 176 case-views, 1584 lines, every line rc=0 (evidence/grid_impl_repro.txt).
  - Equal to the implementer's grid.txt on 1584 of 1584 lines except the md5 field (the case path differs).
  - 122 moving, 117 entering STRICT_EQUAL, 0 leaving; `R11U315_OFF` equals pristine on 176 of 176.
  - Single-switch attribution: DEFGENTERNSYS 34, OPSEL 31, IFLEAFDEF 20, CASTTSNAME 9, CALLARG 7; 21 need two or
    more.
  - Away census (evidence/away_impl_grid_law.txt): lost 0, chain away 0, flat away 0 on all 122, with 369 records
    toward golden.
- **Firing scan** (drivers/firescan.sh): 27577 fence-filtered tools/probe dirs (the implementer's 27498 plus 79 of
  this dir).
  - 175 fire: 71 in r11u315repro, 72 here, and 32 earlier dirs. The earlier dirs are identical to the implementer's
    list (evidence/firing_earlier_law.txt).
  - 404 nonzero exits (249 exit 3, 154 exit 4, one exit 139 v11u112repro m07_hdr_enum_default), each equal on
    pristine (evidence/rc_law_nonzero.txt, rc_pristine_nonzero.txt).
- **The 32 earlier firing dirs, both views** (evidence/controls_firing_law.txt, away_controls_law.txt):
  - 64 case-views, 52 moving, 44 entering STRICT_EQUAL, 0 leaving.
  - Lost 0, chain away 0, flat away 0, with 119 records toward golden.
  - vg06 and vg20 in the elaborated view move in bytes while STRICT_EQUAL on both binaries.
  - Downstream on all 32 dirs: no verdict moves (31 IDENTICAL, r11u217verify PD/p07 EQUIVALENT on both).
- **Neighbour repro dirs** (r11u139netbind, r11u193repro, v11u193repro, r11u307/309/311/313repro,
  v11u307/309/311/313repro): 1670 case-views, 44 moving, 42 entering, 0 leaving. All 44 are in the firing list.
- **Standard byte controls** (r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131):
  1440 case-views, 0 moving.
- **Firing census, frozen before reading the law sweep** (drivers/tracecensus.sh; evidence/predict_law.txt):
  - The law under R11U315_TRACE over the probe and both corpora in both modes, filtered by $FENCED, writes no trace
    line. It predicts no gate mover.
  - Positive control: check_probe on r10rgg16repro/cells/g1 and r10vrgg16repro/cells/v8 with R11U313_TRACE beside
    R11U315_TRACE writes pass 313's GENIFBIRTH and GENIFCONN lines and no pass 315 line. The 175 firing tools/probe
    dirs show that the trace itself writes.
- **Gate sweeps** (tests/sweep.sh --jobs 3, from this worktree, workdirs /tmp/v11u315_swP and /tmp/v11u315_swL):

  | stage | pristine and law |
  |---|---|
  | probe | 4017 EQUAL + 70 STRICT_NOTEQUAL; 0 regressions, 0 conversions, 0 changes |
  | surelog | 480 + 0 (default), 474 + 0 (testflags); 0/0/0 |
  | uhdm2rtlil | 803/1/67 in both modes; 0/0/0 |
  | downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, byte-identical to the committed csv |

  - The csv row diff between law and pristine is 0 lines in all four csvs.
  - Both sweeps exit 1 on the law-index check alone. The index was stale only because this dir was added; with the
    implementer's patch alone on a fresh 494dcae5, `scripts/law_index.py --check` reads current.
- **byteverify** (SELFCHECK=1, on fence-filtered hard-link mirrors with 8 fenced paths skipped):
  - 0 of 3365 corpus and downstream databases move. SELFCHECK flags 3363 of 3365, the known 1DUnpackedArray twin.
  - Probe: 0 of 4087 databases move.
- **Canaries:** surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (surelog ok=58,
  uhdm2rtlil ok=2).
- **Binary audit:** each sweep has 3315 fence-filtered cmds.txt; 3265 name its own binary, 0 the other binary or the
  main tree's. The implementer's 3273 of 3323 counts the 8 fenced rows too.
- **Determinism** (drivers/det.sh, three concurrent draws of the law): one hash per row-mode on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard and BuildUVMPkg in both modes and Rggen default, each equal to the law
  sweep's.
  - Earlgrey_0_1 testflags timed out in that concurrent run (as it did in the implementer's det.txt, which lists no
    hash for it). Three concurrent draws of that row-mode alone read 025c86db2d2d three times, equal to the sweep.

## The attack (89 fresh dirs, both views; evidence/gridfix.txt, gridsum_fresh_*.txt)

Every case's first line names the law it attacks.

| group | law | cases |
|---|---|---|
| VO | § ifaceHcOpSelByInst315 | vo01 to vo13, vo20: two selects, a nested select index, a select as a ternary condition, a depth-2 parent, an interface array, a positional connection, a descending ips operand, an ips actual with an operation base, a 2-D select, two-level for and case generates, an interface in an interface, a bind, a macro select |
| VO / VL | § ifaceHcCallArgByInst315 | vo14 to vo19, vl21: $countones in a comparison, an operation argument, nested calls, $clog2 of a parameter, a select argument in a generate block, a call under an operation, two calls |
| VL | § ifaceConnLeftmostLeafElab315 | vl01 to vl20, vl23, vl24: a unary or parenthesised left operand, inside, parent ports at depth 2, always_comb variables, a replication, a parent instantiated twice with parameters, shifts and **, a struct member, two interfaces on the same nets, wire declaration assignments, a unary minus over a concatenation, && and \|\|, a nested ternary condition, a package parameter operand, a module-child sibling, a hierarchical left operand, a user call operand, signed', a non-ANSI top, an interface port, module-level and generate siblings |
| VK | § ifaceConnCastTsNamedByPort315 | vk01 to vk07: a cast in a ternary branch, in a system call, in a select index, two casts in a generate block, a package type cast, a depth-2 parent, a parameter-width cast |
| VU | § genIfaceHcCallArgUnbound315 (vu01 to vu03, vu05, vu06, vu10), § genCallArgLocalKeepsBind315v (vu04, vu08, vu09, vu11) | vu01 to vu06, vu08 to vu11; vu07 (§ genIfaceHcInnerRefUnbound313 control): a call beside a reference, nested calls, a genvar select argument, a block-local net, an else block, $isunknown, block-local and module-level names together, a block-local name shadowing the module's, a for-generate local wire, two calls over a local and an outer name |
| VD | § genConnTernSysActual315 | vd01 to vd28: a ternary inside a binary operation or a concatenation (unmoved, pristine already right), a ternary or concatenation argument, a parameter argument, a parameter condition, a comparison condition, an ips branch, a call in a binary operation (unmoved), an interface body's for generate, a cast argument, unary branches, a call branch, $countones, a hierarchical condition or argument, a unary over a ternary (unmoved), two ports, a CRLF file, a ternary condition, $random(), a user-call condition, a two-level generate in a module instantiated twice, an ips argument, an inactive if branch, an interface array, a macro call, an untaken case default |

**Results on the fresh dirs:**

| | case-views | moving | entering STRICT_EQUAL | leaving | uhdm-cmp equal -> unequal |
|---|---|---|---|---|---|
| law | 178 | 144 | 94 | 0 | **1 (vu08 default)** |
| fix | 178 | 144 | 98 | 0 | 0 |

- `R11U315_OFF` equals pristine on 178 of 178; `R11V315_OFF` equals the law on 178 of 178.
- Single-switch attribution under the fix: DEFGENTERNSYS 46, OPSEL 25, IFLEAFDEF 18, CALLARG 13, CASTTSNAME 7; 35
  need two or more.
- Away census on all 144 fix movers (evidence/away_gridfix.txt): lost 0, chain away 0, flat away 0, with 418
  records toward golden.
- Positive control, binaries swapped on 12 entering movers: chain away on 12 of 12 (evidence/away_poscontrol.txt).
- Every stage-1 mover whose uhdm-cmp count grows moves its head later in the walk:
  - vd05 38 -> 42: the definition-view call now matches; the head is the elaborated $clog2(W), folded to 3 in golden.
  - vd06 elaborated 62 -> 78: the head is the elaborated `P ? a : b`, which golden folds to `a`.
- Downstream on all 89 dirs: no verdict moves on pristine, law or fix (84 IDENTICAL; VD/vd05, vd06, VL/vl07, VO/vo05
  and vo11 EQUIVALENT on every binary).

**The decode of the break.** Surelog compiles an interface instance's actual in the generate scope's component.
- A name the block declares resolves there and is bound:
  - VU/vu04 `$signed(l)`;
  - vu08 `$signed(l) & a` (l bound, a unbound);
  - vu09, where the block-local `a` shadows the module's `a` (golden binds `logic_var work@top.g.a`);
  - vu11 `$countones(l) == $countones(a)` (l bound, a unbound).
- A module-level name goes unbound, as § genIfaceHcInnerRefUnbound313 has it.

In the elaborated view UHDM's elaborator rebinds the law's null actual by scope lookup, which is why vu04, vu08, vu09
and vu11 already read equal there under the law. Only the default view loses the binding.

## Gates on the fix binary (workdir /tmp/v11u315_swF, same length as swP)

The fix moves nothing in the gate:

| stage | fix |
|---|---|
| probe | 4017 EQUAL + 70 STRICT_NOTEQUAL; 0 regressions, 0 conversions, 0 changes |
| surelog | 480 + 0 / 474 + 0; 0/0/0 |
| uhdm2rtlil | 803/1/67 in both modes; 0/0/0 (stamped_gen_param d/t stays CMP_NOTEQUAL) |
| downstream | 803/66/2/0, byte-identical to the committed csv |

- **Csv rows:** the row diff between fix and pristine is 0 lines in all four csvs.
- **byteverify** against the pristine sweep (evidence/byteverify_fix.txt):
  - 0 of 3365 corpus and downstream databases move (SELFCHECK 3363 of 3365, the 1DUnpackedArray twin).
  - 0 of 4087 probe databases move.
- **Firing census, frozen before reading the fix sweep** (evidence/predict_fix.txt): the fix under R11U315_TRACE
  over the probe and both corpora in both modes writes no trace line, so it predicts no mover, and none moved.
- **Firing scan with the fix** (27587 dirs): 184 firing dirs, the law's 175 plus nine dirs added here after the law's
  scan.
  - § genCallArgLocalKeepsBind315v traces in exactly four dirs: VU/vu04, vu08, vu09 and vu11.
  - The 404 nonzero exits are unchanged.
  - The 32 earlier firing dirs read byte-identical between law and fix on 64 of 64 case-views
    (evidence/controls_firing_fix.txt).
- **Canaries:** surelog ok=52 and uhdm2rtlil ok=16, both changed=0; ctcan2 PASS on both.
- **Binary audit:** 3265 of the 3315 fence-filtered cmds.txt name the fix binary; 0 name another binary.
- **Determinism:** three concurrent draws of the fix give one hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard and BuildUVMPkg in both modes and Rggen default, each equal to the fix sweep's
  (evidence/det_fix.txt). Earlgrey_0_1 testflags reads 025c86db2d2d three times.
- **Sweep exit:** the fix sweep exits 1 on the law-index check alone (this dir was not yet indexed);
  `scripts/law_index.py` was regenerated last.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **Pass 313's twin of the break.**
   - § genIfaceHcInnerRefUnbound313 unbinds a block-local operation operand: VU/vu07 `.clk(l & a)`, where golden
     binds l and ours leaves it unbound. Both binaries are at stage 1.
   - Same decode: extend the generate-local set of § genCallArgLocalKeepsBind315v to genIfaceHcInnerRefUnbound313's
     walker behind a new switch.
2. **A select index under a system-call argument in a generate block stays bound.** VO/vo18 default view
   `$signed(ck[s])`: golden leaves s unbound. The GENCALLUNBIND walker does not enter an argument select's index.
3. **The cast typespec name inside a select index.** VK/vk03 `ck[2'(s)] & ck[0]`: golden names the cast's
   ref_typespec through its parent chain, `work@top.u.clk.ck`; the law writes `work@top.u.clk` at every depth.
4. **Select shapes the OPSEL walker does not reach:**
   - a select inside an index, VO/vo02 `ck[k[0]] | a` (golden `work@top.u.clk.ck.k`, ours `work@top.ck.k`);
   - a 2-D var_select operand, vo09 `m[1][0] & a` (golden `work@top.u.clk.m`).
5. **Definition-view generate leftovers of § genConnTernSysActual315.** Each reads the generate scope's name where
   golden scopes the reference through the formal:
   - an ips base inside a branch or argument: VD/vd08 `t ? v[s +: 1] : v[0]` and vd23 `$signed(v[s +: 1])` (golden
     `work@top.g.c0.clk.s`, ours `work@top.g.s`);
   - a user call's argument in the condition: vd21;
   - a hierarchical branch or argument: vd15, vd25 (the implementer's c08 face).
6. **Elaborated-view folds Surelog makes and ours does not** (stage 1 on both binaries; ModuleEmit's
   elaborated-generate port actual):
   - a parameter-only call: vd05 `$clog2(W)`, which golden folds to 3;
   - a constant-condition ternary: vd06 `P ? a : b`, which golden folds to `a`.
7. **Faces this pass does not reach, heads on both binaries:**
   - the package type cast name `pk::bit1_t` (vk05);
   - the bind naming (vo12, golden `work@top.c.u`, ours `work@top.t.c.u`);
   - the interface-array, interface-in-interface and for-generate hierarchical-path heads (vo05, vo10, vo11, vu03,
     vu10, vd10, vd26);
   - the struct-member operand at stage 1 (vl09) and the interface-port operand (vl23).
8. **Sister-ground faces (reported, not written):**
   - the cast typespec of a parameter-width cast `W'(a)`, where golden writes an unnamed integer_typespec 1 and ours
     an int_typespec named W (VK/vk07, stage 1; the cast emission in ExprEmit);
   - the end column of a folded `$clog2(W) == 2` operand inside an interface actual (VO/vo17 elaborated, endcol;
     ExprEmit's constant span).

## Process

- **Fence:**
  - The four fenced tests were never dispatched. Every scan built its path list and filtered it by $FENCED before
    opening a file: the firing scan, the controls, bvmirror and the cmds.txt audit.
  - The census and determinism runs used filters built from $FENCED, and the patch's fence scan reads 0 for the four
    names.
- **Writes and processes:**
  - Nothing was written outside /tmp/wt_v11u315, /tmp/wt_v11u315pris and /tmp/v11u315_*.
  - One temporary worktree (/tmp/v11u315_chk) was created for the law-index check and removed.
  - No other agent's process was listed or touched.
- **Slips, no effect:**
  - Two draft cases were not legal SV under slang (exit 3 on every binary): a module instantiated in an interface,
    and a net used before its declaration. They were rewritten (vd10) or dropped (vl22) before counting.
  - The first concurrent determinism draw of Earlgrey_0_1 testflags timed out and was re-run alone.
