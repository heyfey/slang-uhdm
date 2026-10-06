# v11u269: adversarial verification of r11u269 (pass 269, the module/type ground)

Base abc22480. Verdict: **ACCEPT WITH ONE FIX.** Every headline number of r11u269 reproduces bit for bit. One of
its five laws, § selLhsOpFoldFresh269, breaks on legal SystemVerilog the gate does not contain: under the law,
41 fresh case-views lose uhdm-cmp equality and 20 leave STRICT_EQUAL, and on 12 fresh case dirs the downstream
verdict moves away from IDENTICAL (11 EQUIVALENT, 1 DIVERGENT). The fix is the refinement
§ selOpFoldReducibleKinds269v (switch `R11V269_OPKIND_OFF`, ModuleEmit). It changes 0 of 2560 corpus, 0 of 4087
probe and 0 of 805 downstream slang-lane databases relative to the law, and every result csv matches the law
sweep's. With the fix, all 378 grid case-views keep STRICT_EQUAL and uhdm-cmp equality, and all 146 case dirs
read IDENTICAL downstream.

| binary | md5 | what |
|---|---|---|
| pristine | 52573f406f01c43fb57d2d6c829e7f48 | abc22480, built in a fresh worktree (the main tree's md5) |
| law | 885a66ea315bff7d08675ba2e6e38e2f | abc22480 + /tmp/r11u269.patch (the implementer's md5) |
| fix | 85dd8dc978289a25b9cf8eb079b85147 | law + § selOpFoldReducibleKinds269v; rebuilt from the delivered src diff on a third fresh abc22480 worktree to the same md5 |

Every switch: `R11U269_OFF` drops the five laws and the refinement (pristine bytes). `R11V269_OFF` drops the
refinement alone (the law's bytes). `R11V269_OPKIND_OFF` is the refinement's own switch. `R11U269_TRACE=<dir>`
also logs the refinement's stand-asides as `selOpFoldReducibleKinds269v`.

## 1. Reproduction of the implementer's numbers (all from my own builds, frozen before any measurement)

- **Pristine sweep** (tests/sweep.sh, all four stages): probe 3575 EQUAL + 512 STRICT_NOTEQUAL; surelog 475 + 5 /
  469 + 5; uhdm2rtlil 803 / 803; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT. It reads
  regressions=0 in every stage and is the baseline exactly.
- **Law sweep:**
  - probe 3591 + 496, with the same 16 conversions (r10uvm112repro a6, a7, a9, a10; r10uvm212repro grid_c7;
    r10v112repro g1, g2, g3, g5, g10, g12, g15, g18; r10v212repro gridv v1, v8, v9, all `differ:depth(1) -> EQUAL`)
    and one change, g19_builtin `file(6) -> file(10)`;
  - surelog 944 + 10 with one change: `Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(105),,differ:fullname(105)`
    (was `fullname(14)`);
  - uhdm2rtlil 1606 + 0;
  - downstream 803/66/2/0, with a csv byte-identical to pristine's.
- **Earlgrey testflags walk** (uhdm-strictcmp, no `--max`, golden vs the two sweep databases):
  - pristine reads `objects 1342584 vs 1342968`, fullname=14, walk diverged;
  - the law reads `fields: fullname=73 file=3 line=3 col=3 endline=3 endcol=32 objects_differing=105` and the walk runs
    to the end.
  - Every record of the 105 is on the sister ground: 15 `ref_obj k` genvar-index full names inside
    alert_handler_reg_wrap (ExprEmit), 29 tlul_socket_m1 `indexed_part_select a_source` endcols plus their typespec
    references (ExprEmit § genIpsBoundOwner256 / stampFoldedPkgParamTs), and 3 int_typespec file records (ParamEmit).
- **byteverify** (on hard-link mirrors with the 8 fenced paths left out, SELFCHECK=1):
  - law vs pristine: 6 of 2560 corpus databases move (Earlgrey_0_1, MiniAmiq, SeqDriver, each d/t), with the
    implementer's hashes;
  - probe (both runs from one checkout): 19 of 4087 move;
  - downstream slang lane: 0 of 805.
- **Firing census** (drivers/tracecensus.sh, filter built from `$FENCED`): the law's 31 lines are identical, line
  for line, to the implementer's evidence/predict_frozen.txt.
- **Chain-keyed away census** (drivers/awaycorpchain.sh over awaychain.py with the raw-full-name comparator):
  Earlgrey d/t 0 away (10559 / 1981 toward), MiniAmiq d/t 0 away (469 toward), SeqDriver d/t 0 away (422 toward).
  - MiniAmiq's flat distance 110 -> 111 is not a new wrong object. Pristine already holds 4 class_typespec records
    (uvm_component at uvm_registry.svh 51:39, uvm_object at 189:36) under uvm_component_registry::create /
    create_component and uvm_object_registry::create / create_object that golden lacks there.
  - The law adds 67 golden-matching copies of those two records, so the multiset total passes golden's (73).
- **Grid** (the implementer's 58 dirs, 116 case-views, 12 configurations; evidence/grid.txt, gridsum3.txt):
  - 73 move and 44 enter STRICT_EQUAL; none leaves and no exit code changes.
  - Each mover is moved by exactly one switch: TOPARRELEM 22, TDCLONEDEEP 14, RETRANGEOWNPKG 5, SELOPFOLD 16,
    BINDUP 16.
  - `R11U269_OFF` gives pristine's bytes on 116 of 116, and the fix equals the law on 116 of 116.
- **Byte controls** (the implementer's 37 earlier dirs, 5286 case-views, three binaries; evidence/controls.txt,
  controls_summary.txt): law vs pristine moves 22 and 14 enter STRICT_EQUAL, with none leaving and no exit code
  changing. Fix vs law moves 0.
- **Canaries, ctcan2, binary audit** (law and fix sweeps alike):
  - canaries: surelog ok=51 changed=1 (Earlgrey testflags); uhdm2rtlil ok=16;
  - ctcan2: PASS on both corpora;
  - binary audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary; the other 50 carry no slang line.
- **uhdm-cmp:** 0 lines on all six corpus movers.
- **Determinism** (drivers/det.sh, the final fix binary): three concurrent draws per row-mode on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen read one hash each, equal to the sweep's
  (Scoreboard and Rggen testflags have no database).

## 2. The break: § selLhsOpFoldFresh269 on operator kinds golden does not reduce the way our fold writes

UhdmWriter::writeCont_assign's `simplified == false` branch installs `reduceExpr`'s RAW constant on a select Lhs.
`adjustSize(tps, ...)` runs with `tps == nullptr`, because a bit, part or concatenation Lhs carries no typespec.
Our general fold writes the constant at the Lhs width, which is the plain-Lhs model, where adjustSize resizes the
constant to the bound variable.

UHDM's `ExprEval::reduceExpr` (third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp) writes a per-operator
constant:

| Rhs operator | golden's constant |
|---|---|
| `>>`, `<<` | `UINT` size 64 |
| `-` | `INT` size 64 |
| `+` | the operands' larger size, with the UNWRAPPED 64-bit sum; `INT` when an operand is a decimal or a parameter |
| `&`, `|`, `&&`, `||`, `!`, the reductions | `UINT` size 64 |
| `/`, `%`, `**` | `INT` size 64 |
| `^`, `~^`, unary `+`, `===`, `!==`, `==?` | not reduced: golden keeps the operation, and pristine's shared definition object was right |

The implementer's width-equality test (`r269.type` width == Lhs width) is a proxy that holds only for some of these
kinds.

The grid in cases/VO (75 dirs, one select-Lhs assignment per operator form) and cases/VS (16 dirs) measures each
kind on both binaries:

| outcome under the law (law vs pristine) | case-views |
|---|---|
| uhdm-cmp equality LOST (STRICT_NOTEQUAL -> stage 1), e.g. VO/o02_sub_el, o07_and_el, o11_shl_el, o24_redand_el, o30_p_add_el, o48_add_dec_el, o53_neg_nested_sub_el, o66_neg_neg_el, o74_add_overflow_el; VS/vs02, vs06, vs11, vs12, vs15, vs16 elaborated views | 41 |
| STRICT_EQUAL LEFT (pristine right, the law wrong), VO/o09_xor, o10_xnor, o23_uplus, o29_caseeq, o32_p_xor, o41_repl_op, o51_bnot_nested_xor, o59_case_neq, o61_wild_eq, o65_repl_xor_item in both views | 20 |
| downstream IDENTICAL -> EQUIVALENT (VO o09, o10, o29, o32, o41, o51, o59, o61, o65; VS vs03, vs15) | 11 dirs |
| downstream IDENTICAL -> DIVERGENT: VO/o13_ashr `assign w[3:0] = 4'sh8 >>> 1`, the netlist constant differing ("Constant value mismatch") | 1 dir |

No corpus row, probe case or downstream row of the gate has the shape. The law fires on 0 gate databases (the
census), so the gate could not see it.

**§ selOpFoldReducibleKinds269v** (ModuleEmit, helper next to § caLhsBindsUpScopes269, gate inside
§ selLhsOpFoldFresh269 in emitContAssigns; switch `R11V269_OPKIND_OFF`). The law fires only on the kinds whose
reduced constant the general fold writes exactly, each measured on the grid:

- a replication of literal or parameter items, with any constant count (`{N{1'b1}}`, `{2*W{1'b1}}`, `{2{P}}`);
- unary `-` and `~` over a literal or a parameter;
- the six comparisons `==` `!=` `<` `<=` `>` `>=` over such operands, with nested comparisons and sums allowed;
- `+` over unsigned, based, non-decimal literals whose sum fits each `+` node's width, with nested such `+`.

A literal holding x or z bits stands aside everywhere.

Two drafts were refined on the grid before the final binary. Fix 1 (md5 54618eeb) checked the replication count
recursively, which reverted v11u267repro VA/va04 `{2*W{1'b1}}` (the law right, golden folds it) in the byte
controls. Fix 2 (645eda48) still let `-(-4'sd3)` (o66) and `4'hF + 4'h1` (o74, golden UINT:16 size 4) through.
Both drafts' sweeps, census and grid runs were stopped by me and their outputs deleted or set aside, and everything
below was rerun on the final binary.

## 3. Measurements on the final fix binary (85dd8dc9)

1. **Census frozen before the fix sweep** (evidence/predict_fix_frozen.txt): the law's 31 lines unchanged, plus one
   refinement stand-aside on r10vearl98repro/v3b_shapes98, where the law itself never fired.
   - The prediction is therefore 0 byte movers against the law in every corpus, and the implementer's 25 against
     pristine.
   - Positive control (evidence/trace_positive_control.txt): the stand-aside fires on VO/o02, o13 and o74, and the
     law fires on o01.
2. **Fix sweep** (all four stages): probe 3591 + 496, with the same 16 conversions and the g19_builtin change,
   regressions=0; surelog 944 + 10, regressions=0, conversions=0, with the one Earlgrey testflags change quoted
   above; uhdm2rtlil 1606 + 0, regressions=0; downstream 803/66/2/0.
   - The probe, uhdm2rtlil and downstream csvs are byte-identical to the law sweep's.
   - The surelog csv differs only in the two LowMem SURELOG_FAIL detail texts, which embed the workdir.
   - Both the law sweep and the fix sweep exit 1 on the law-index staleness check alone. The pristine worktree and
     the main tree at abc22480 read the same staleness.
3. **byteverify, fix vs law:** 0 of 952 surelog, 0 of 1608 uhdm2rtlil, 0 of 4087 probe and 0 of 805 downstream
   slang-lane databases move. Fix vs pristine: the same 6 corpus and 19 probe movers with the law's hashes, and 0
   downstream. The prediction holds exactly.
4. **Grid** (189 case dirs, 378 case-views; 12 configurations: P, L, OFF, five law switches, F, FV, FU,
   `R11V269_OPKIND_OFF`; every line carries rc):

   | | law vs pristine | fix vs pristine |
   |---|---|---|
   | moving | 287 | 193 |
   | entering STRICT_EQUAL | 131 | 129 |
   | LEAVING STRICT_EQUAL | 20 | 0 |
   | losing uhdm-cmp | 41 | 0 |
   | exit code changing | 0 | 0 |

   - FU (`R11U269_OFF`) gives pristine's bytes on 378 of 378. FV (`R11V269_OFF`) and `R11V269_OPKIND_OFF` give the
     law's bytes on 378 of 378.
   - The two STRICT_EQUAL entries the fix gives up are VO/o49_add_signed in both views (`4'sh1 + 4'sh2`). The fix
     conservatively refuses signed literals in `+`, and the case returns to pristine's verdicts (stage 1 /
     STRICT_NOTEQUAL file).
5. **Away census, fix vs pristine, on every grid mover** (evidence/grid_away_fix.txt, 193 case-views: 100 record
   census, 93 dump census): 0 lost everywhere except one generic `|vpiParent:` dump line on R/S/s04_ipart_local_el
   and VO/o28_repl_param_el, o37_p_bnot_el and o57_bnot_typed_el. All four are print-position artefacts, and every
   one of them ENTERS STRICT_EQUAL.
6. **Byte controls** (37 dirs, 5286 case-views): fix vs law moves 0, and fix vs pristine reads 22 / 14 / 0 like the
   law. v11u267repro VA/va04 keeps the law's STRICT_EQUAL.
7. **Downstream on every moving case dir** (146 single-file dirs, evidence/ds_cases_{P,L,F}.txt):
   - pristine: 146 IDENTICAL;
   - law: 134 IDENTICAL, 11 EQUIVALENT, 1 DIVERGENT;
   - fix: 146 IDENTICAL.
   - Some dirs read IDENTICAL because both lanes fail the same way (READ_FAIL / NO_GATES), as in the implementer's
     A cases.
8. **Canaries** surelog ok=51 changed=1, uhdm2rtlil ok=16; ctcan2 PASS on both corpora; binary audit 3265 of 3315;
   uhdm-cmp 0 lines on the six movers; determinism one hash in 3 of 3 per row-mode, equal to the sweep's.

## 4. The attack cases (every dir's first line names its law)

| cases | law | result (law; the fix unless noted is the law's bytes) |
|---|---|---|
| VA/va01 .. va07 | § topNestedArrElemTopTwin269 | a typedef-aliased packed array (`mregs_t`, stage 1 on both binaries, dump distance unchanged), two importer modules (va02_el enters STRICT_EQUAL), a package function reader (no move), a packed union (rewritten once: the first draft's member widths differed, rc 3), the element in another package, a direct element port, three levels (va07_el enters STRICT_EQUAL); none leaves |
| VB/vb01 .. vb13 | § caLhsBindsUpScopes269 | the name in a parent generate block (no bind, no move, golden agrees), a parent parameter named alike (no move), a `$unit` variable (no move), three levels, a parent generate declaration, a parent interface instance, nested generate blocks, a parent net declared after the instance, two instances, a parent implicit net, a grandparent through a generate loop, a parent port, an interface generate block below a module whose grandparent declares the name: vb04, vb08, vb09, vb10, vb11, vb12, vb13 elaborated views enter STRICT_EQUAL; none leaves |
| VR/vr01 .. vr10 | § retTopRangeOwnPkg269 | a range qualified with ANOTHER package's parameter of the same name (vr01, vr07, vr09: the law does not fire), an explicitly imported parameter (vr03), an imported range parameter (vr08: fires, binds the object the old code chose, dump unchanged), two functions in a package with two importers (vr10 default view enters STRICT_EQUAL); none leaves |
| VS/vs01 .. vs16 | § selLhsOpFoldFresh269 (vs02, vs03, vs06, vs11, vs12, vs15, vs16: § selOpFoldReducibleKinds269v) | the law: vs01, vs04, vs08, vs09, vs13_el enter STRICT_EQUAL (kept by the fix); vs02, vs06, vs11, vs12, vs15, vs16 elaborated views LOSE uhdm-cmp equality (restored by the fix); vs03 and vs15 downstream EQUIVALENT (restored); vs05 is illegal (rc 3 on every binary, no measurement) |
| VO/o01 .. o75 | § selOpFoldReducibleKinds269v | one operator form per dir, section 2; o54 is illegal (rc 3 on every binary) |
| VU/vu01 .. vu10 | § cloneTdSpecDeepCopy269 | a parameterized-class actual, a four-deep nesting, a struct actual (vu03 depth -> fullname, toward golden, 50 records gained, 0 lost), module-scope classes (vu04, below), vector actuals, a three-package utils macro (no move), CRTP and a self specialization (no move), a type-parameter default naming another type parameter (vu09: its first record is now a pristine defect the old divergence hid), a virtual-interface actual; no exit code changes, none leaves |

## 5. Residues, ranked

1. **§ selLhsOpFoldFresh269's unreduced kinds.** The general transcription is ExprEval::reduceExpr's per-operator
   constant (kind, size, unwrapped value) for a select Lhs with no typespec. Today the refinement keeps pristine's
   share for `-`, `*`, `/`, `%`, `**`, `&`, `|`, `^`, `~^`, shifts, logical ops, reductions, a decimal or parameter
   `+`, a signed `+` (o49), an overflowing `+` (o74) and nested unary minus.
   - Pristine is stage 1 or STRICT_NOTEQUAL file on most of these (VO grid); `^`, `~^`, `===`, `!==`, `==?` and unary
     `+` are already right.
   - Also not reached: a select Lhs in an interface body (VS/vs14) and a 2-D net element (vs10, stage 1 on pristine).
2. **§ cloneTdSpecDeepCopy269 on classes declared in a module** (VU/vu04). Golden lists no specialization at all on
   such a clone; ours already did, and the law's copies grow the wrong listing (dump distance 59 -> 99 default,
   203 -> 278 elaborated, 0 golden lines gained). Stage 1 on both binaries; no gate database has the shape.
3. **§ cloneTdSpecDeepCopy269's open shapes:**
   - vu03: the clone_tree copy of a struct actual keeps its members' raw ref_typespec full names (`bp::st_t::a`
     where golden's copy reads `up::c3::tid::T::bp::st_t::a`);
   - vu09: the generic's own formal `U = T` reads `class_typespec obj` in ours where golden's reference has no
     actual, a pristine defect now first;
   - vu01, vu02, vu05, vu10: stage 1 or file on both binaries, with golden lines gained and 0 lost.
4. **The implementer's residues 1 to 9, unchanged** (its README): the type-parameter use face (TypeEmit 180 / 183 /
   186), VB/vb04's missing gen-scope `vpiDelay`, the base type_parameter span on class-typedef groups, U/u04 and
   u05, S/s03 / s05 / s10, the B default views, R/r06 to r08, A/a18 and A/a20, and the brief's items (3) to (5)
   beyond #136655, including pass 260's cast-copy re-parent in UhdmExporter typedefParentModel134.
5. **Sister-ground faces, as measured here on the law sweep's Earlgrey testflags walk:**
   - ExprEmit: the genvar index naming in generate-scope member paths (15 `ref_obj k` records under
     alert_handler_reg_wrap) and the § genIpsBoundOwner256 / stampFoldedPkgParamTs tlul_socket_m1 family (29
     endcols plus full names);
   - ParamEmit: 3 int_typespec file records (the elaborated param_assign fold typespec);
   - StmtEmit emitCtorBody27's EK_BID branch: the MiniAmiq / SeqDriver heads #134648 / #134606 / #134618, unchanged.

## 6. Process

- **Worktrees:** /tmp/wt_v11u269 (law + fix), /tmp/wt_v11u269pris (pristine) and /tmp/wt_v11u269chk (the
  fresh-base rebuild check). Scratch is under /tmp/v11u269_*. Binaries were frozen read-only before every
  measurement.
- **Fence:** nothing fenced was read or run outside the gate sweeps.
  - byteverify ran on hard-link mirrors built from fence-filtered path lists (8 fenced paths left out).
  - The census, determinism, audit and away drivers all read `$FENCED` fail-closed, and the census filter is built
    from it.
  - No `grep -r` was run over a corpus tree.
- **MY SLIPS:**
  1. While stopping my own fix-2 census and grid runs, one `pgrep -f` pattern matched my own shell and ended it
     (exit 144). The remaining processes, all mine and checked by command line, were then stopped by pid; no other
     process was signalled.
  2. My first downstream-case batch passed a newline-separated directory list inside `bash -c`, so each line ran as
     a command. Every line was a directory ("Is a directory"); nothing ran and nothing was written. The batch was
     rerun with `xargs`.
  3. My first byte-control run named three dirs with a `repro` suffix they do not have. Those dirs (r11u148share,
     r11u175uvm, r11u183dec) were run separately and joined; the totals above include them.
  4. My first fix sweep was started before its census was frozen. I stopped it and deleted its outputs unread,
     then reran it after the census.
- **Case rewrites:** two first drafts were illegal SV (VA/va04 rewritten; VS/vs05 and VO/o54 kept with their rc 3
  on every binary). After the grid I renamed the first line of the VO and VS refinement cases to the refinement's
  law. The comment-only change re-keyed their golden cache, and the VO/VS rerun read the same verdicts.

Drivers (all copied from r11u269repro unless named): case.sh, grid.sh (+ the fix configurations), gridsum.py,
gridsum3.py (new: three-binary summary), pl.sh (new: pristine / law / extra configurations), controls.sh (+ `CFGS`),
ctlsum.py (+ tag arguments), tracecensus.sh, det.sh, dscases.py, awayall.sh, away.py, awaydump.py, awaychain.py,
awayrows.py, awaycorp.sh, awaycorpchain.sh (new: chain census of corpus movers between two sweeps), bvmirror.sh,
probemovers.py and dsmovers.py (new: probe and downstream slang-lane byte movers), cc_x.sh + strictcmp_x.cpp (the
raw-full-name comparator, rebuilt to the implementer's md5 886f0302), env.sh.
