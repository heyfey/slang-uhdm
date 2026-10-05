# v11u255: adversarial verification of r11u255 (pass 255, module/type ground)

Base 99ea3716. Implementer's patch `/tmp/r11u255.patch` (four laws behind `src/R255.h`, TypeEmit and UhdmExporter).
**Verdict: VERIFIED, no production fix.** Every headline number of `tools/probe/r11u255repro/README.md` reproduces
bit for bit on binaries built here. 46 fresh cases found no pristine-right -> patched-wrong move: no case-view leaves
STRICT_EQUAL, no uhdm-cmp line count rises, the away census loses 0 records, and no downstream verdict changes. One
pre-existing determinism defect in § bareTdNameFirstWriterWins98 is reported (section 4). Pristine has it too. The
law does not cause it, and on the measured cases the law makes the dumps agree across draws.

## 1. Binaries and gates

The binaries were built in fresh worktrees at 99ea3716 (`-j 2`, system deps) and frozen before any measurement:
* pristine `de0c6d846229ddfb799e37cb0cbb28b8`, the main tree's md5;
* law `771d2315d253e6fafc91b9df9e2cc1f8`, the implementer's md5;
* both link slang 12.0.0+545f88b2e.

The gate sweeps (`drivers/sweeps.sh`; `tests/sweep.sh --jobs 3`, workdirs `wP` / `wL`; fence-filtered csvs and logs in
`evidence/sweeps/`):

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3547 + STRICT_NOTEQUAL 540; regressions=0 conversions=0 changes=0 | the same; changes=0 |
| surelog | 937 + 17; regressions=0 conversions=0 changes=0 | regressions=0 conversions=0 **changes=4** |
| uhdm2rtlil | 1606 + 0; regressions=0 conversions=0 changes=0 | the same |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; the csv byte-identical to pristine's |

The four changes, the fresh rows from the law sweep (results/ untouched):

```
BuildUVMPkg,default,STRICT_NOTEQUAL,differ:endcol(1),,differ:endcol(1)
BuildUVMPkg,testflags,STRICT_NOTEQUAL,differ:endcol(1),,differ:endcol(1)
Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(155),,differ:fullname(155)
Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(50),,differ:fullname(50)
```

The surelog csvs are equal row for row apart from these four rows and the two LowMem path-detail rows. The probe
and uhdm2rtlil csvs are identical.

Both sweeps exit 1 only on `law index STALE`. The base itself reads stale: the pristine worktree fails
`scripts/law_index.py --check`. On a fresh 99ea3716 with the implementer's patch applied, `--check` reads
`law index current`.

**BuildUVMPkg, first records** (uhdm-strictcmp, default):
* pristine: `#185844 depth`, golden `6 begin uvm_pkg::uvm_tlm_b_initiator_socket::connect 60210:5-68`, ours
  `8 class_typespec this_type 13776:11-42`;
* law: `#194627 endcol`, `hier_path factory.is_type_registered 14097:13`, golden end 46 and ours 39.

That record is ExprEmit's (ground A), as the implementer reported. The claim that an ExprEmit prototype converts
the row was not re-measured here: it is the sister ground.

**Other checks:**
* byteverify (`tools/probe/r11v75repro/byteverify.sh`, through fence-filtered hard-link mirrors; 8 fenced databases
  skipped per sweep; `evidence/byteverify_corpus.txt`): 4 of 2560 movers, BuildUVMPkg d/t and Earlgrey_0_1 d/t.
  SELFCHECK 2559 / 2560 flagged.
* Probe bytes: the pristine probe stage was rerun from the law worktree, so both sides carry the same case paths.
  0 of 4087 databases move. The path list was filtered by `$FENCED` first.
* Downstream slang-lane bytes: 0 of 805 move.
* uhdm-cmp on the four movers: 0 lines each.
* With `R11U255_OFF` (verify_golden.py, filter BuildUVMPkg and Earlgrey_0_1) the law binary gives pristine's md5
  on all four row-modes.
* Away census (`r11u255repro/drivers/awaycorp.sh`; `evidence/away_corpus.txt`):
  * BuildUVMPkg d and t: `dist 27 -> 19 lost=0`;
  * Earlgrey d: `1037 -> 1032 lost=0 gained=5`;
  * Earlgrey t: `769 -> 764 lost=0 gained=5`.
* Canaries:
  * surelog: law `ok=48 changed=4`, the four targeted rows; pristine `ok=52 changed=0`;
  * uhdm2rtlil: `ok=16 changed=0`;
  * ctcan2: PASS on both corpora (EXPECT_UNKNOWN=1 / 6).
* Binary-path audit: 3265 of 3265 cmds.txt per sweep name that sweep's frozen binary (1523 surelog + 1742
  uhdm2rtlil). The path list was filtered by `$FENCED` first.
* Firing census (`r11u255repro/drivers/tracecensus.sh` with the law binary, the harness dispatching, the filter built
  from `$FENCED`; 794 surelog tests): 14 databases.
  * The census output is identical line for line to the implementer's frozen `evidence/predict.txt`.
  * It fires, so the census is its own positive control.
  * The 10 that fire without moving are uhdm2rtlil genvar_iface_struct, hier_path and ibex_pmp d/t, and four probe
    cases. byteverify and the probe byte list confirm that none of them moves.
* Determinism (`r11u255repro/drivers/det.sh`, three concurrent draws with the law binary; `evidence/det_law.txt`):
  * one hash per row-mode on 11 of 11 (Scoreboard testflags writes no database);
  * the BuildUVMPkg and Earlgrey hashes equal the law sweep's.

## 2. The implementer's grid and controls, rerun

**Grid:** `r11u255repro/drivers/grid.sh` over its 41 cases, 574 lines (`evidence/grid_impl_rerun.txt`).
* The summary is identical to the implementer's `gridsum.txt` in every field.
* 82 case-views; 54 moving; 36 entering STRICT_EQUAL; none leaving.
* `R11U255_OFF` gives pristine bytes on 82 of 82.
* uhdm-cmp counts change only on F/f05 (61 -> 0, both views).

**Byte controls** over the implementer's 17 dirs (`r11u255repro/drivers/controls.sh`; `evidence/controls_impl_*`):
* 1926 case-views; exit codes identical;
* 4 moving: r11u248repro decode/e01_genkey in both views enters STRICT_EQUAL, and r11u236repro E/e14 in both views
  keeps endcol;
* none leaving.

**Widened controls** over 11 more dirs (`evidence/controls_wide_*`):
* dirs: r11u217verify, v11u219repro (the § defGenTarget… grids), r11u98repro, r11v98repro
  (§ bareTdNameFirstWriterWins98), v11u248repro, r11u249repro, v11u249repro, r11u250repro, v11u250repro,
  r11u251repro, v11u251repro;
* 638 cases, 1276 case-views;
* 0 moving; exit codes identical.

## 3. Fresh cases (`cases/`, 46 cases, both views, 7 configurations: `drivers/grid.sh`, `evidence/grid.txt`)

644 lines, every exit 0. The totals (`evidence/gridsum.txt`):
* 92 case-views; 63 moving.
* 32 enter STRICT_EQUAL (C 24, E 8); none leave.
* uhdm-cmp line counts change on none.
* `R11U255_OFF` gives pristine bytes on 87 of 92. The other 5 (F/vf03 both views, vf05 both views, vf08 default) are
  the pre-existing nondeterminism of section 4: pristine draws the same two hashes there.
* Each switch moves only its own law's cases, apart from vf05's switch column, which is the same nondeterminism.

**Away census.** The record census (`evidence/away_grid.txt`) and the uhdm-dump line census for stage-1 case-views
(`evidence/awaydump_grid.txt`, `r11u248repro/drivers/awaydump.py`) both read **lost=0 on every mover**.
* The stage-1 E movers ve01, ve02, ve04, ve05, ve09 and ve14 read `gained=0`: the law's span equals golden's, but
  the dump line also carries a full-name text that pristine already got wrong. Examples: `key [7 - i]` against
  golden's `key[7 - i]`, `key[ 7 - i ]`, `` key[`REVi] ``, `key[idx[i]]` against golden's `key[[i]]`.

**Downstream** (`drivers/dscases.sh`, `evidence/downstream_cases.txt`): the 37 C and E cases read the same verdict on
both binaries. 35 are IDENTICAL; vc05 is DIVERGENT on both and ve08 EQUIVALENT on both.

### § defGenCfcThroughCondSel255 and § defGenCfcLitLeafSel255 (C)

| case | law | pristine -> law (default / elaborated) |
|---|---|---|
| vc01_cond_noselpath | § defGenCfcThroughCondSel255 | fullname -> STRICT_EQUAL / same |
| vc02_arm_exprsel | § defGenCfcThroughCondSel255 | fullname 5 -> 2 objects / same (the middle expression select, residue 3) |
| vc03_idx_in_idx | § defGenCfcThroughCondSel255 | fullname -> STRICT_EQUAL / same |
| vc04_unary_idx | § defGenCfcThroughCondSel255 | fullname -> STRICT_EQUAL / same |
| vc05_multidim_idx | § defGenCfcThroughCondSel255 | stage 1 on both, no move |
| vc06_proc_ctl | § defGenCfcThroughCondSel255 | control (procedural, abstains): STRICT_EQUAL on both |
| vc07_lit_under_cond | § defGenCfcLitLeafSel255 | fullname -> STRICT_EQUAL / same (both laws) |
| vc08_lit_leaf_nested | § defGenCfcLitLeafSel255 | fullname -> STRICT_EQUAL / same |
| vc09_lit_mid_and_leaf | § defGenCfcLitLeafSel255 | fullname -> STRICT_EQUAL / same |
| vc10_lit_2d_leaf | § defGenCfcLitLeafSel255 | stage 1 on both; moves, dump census 9 -> 8, lost 0 |
| vc11_lit_sized | § defGenCfcLitLeafSel255 | STRICT_EQUAL on both, no move |
| vc12_lit_spaced | § defGenCfcLitLeafSel255 | stage 1 on both, no move |
| vc13_lit_in_idx | § defGenCfcLitLeafSel255 | fullname -> STRICT_EQUAL / same (both laws) |
| vc14_func_arg | § defGenCfcThroughCondSel255 | control: fullname on both (residue 4) |
| vc15_binop_cond | § defGenCfcThroughCondSel255 | fullname -> STRICT_EQUAL / same |
| vc16_genif_body | § defGenCfcThroughCondSel255 | fullname -> STRICT_EQUAL / same |
| vc17_gencase_body | § defGenCfcThroughCondSel255 | fullname -> STRICT_EQUAL / same |
| vc18_nested_for | § defGenCfcThroughCondSel255 | STRICT_EQUAL on both, no move |
| vc19_iface | § defGenCfcThroughCondSel255 | fullname -> STRICT_EQUAL / same |
| vc20_netdecl | § defGenCfcThroughCondSel255 | default depth on both (an unrelated net-declaration-assignment face), elaborated STRICT_EQUAL on both |
| vc21_localstruct | § defGenCfcThroughCondSel255 | fullname -> STRICT_EQUAL / same |

### § genPathExprSelSpan255 (E)

| case | law | pristine -> law |
|---|---|---|
| ve01_nested_idx, ve02_space_before_bracket, ve04_multiline_idx, ve05_two_expr, ve09_inner_space, ve14_macro_idx | § genPathExprSelSpan255 | stage 1 on both; the span moves to golden's, the full-name text was wrong on pristine (residue 5) |
| ve03_expr_then_lit | § genPathExprSelSpan255 | col -> fullname (first-field change; record census 9 -> 8, lost 0; the walk now reaches the literal leaf's full name) |
| ve06_concat_lhs | § genPathExprSelSpan255 | col on both, no move (a target inside a concatenation abstains) |
| ve07_paramidx, ve08_partsel_tail, ve11_iface_lhs | § genPathExprSelSpan255 | stage 1 on both; dump census gains 2 each, lost 0 |
| ve10_genif_cond, ve12_twofiles_samepos, ve13_crlf, ve15_genfor_header | § genPathExprSelSpan255 | col -> STRICT_EQUAL in both views |
| ve16_2d_middle | § genPathExprSelSpan255 | stage 1 on both, no move (a two-index middle select takes another branch) |

### § fwWinnerListedObject255 (F)

| case | law | result |
|---|---|---|
| vf01_widthparam | § fwWinnerListedObject255 | no firing; fullname on both (a range reference's raw full name inside the typedef) |
| vf02_typeparam_kind | § fwWinnerListedObject255 | no firing; type on both: golden binds the declaration's listed `int_typespec` 4:23, ours the specialization's `byte_typespec` 12:12; the law's kind gate abstains (residue 2) |
| vf03_twospecs | § fwWinnerListedObject255 | fires; STRICT_EQUAL on both; nondeterministic on both binaries (section 4) |
| vf04_header | § fwWinnerListedObject255 | no firing; endcol on both (a qualified class-specialization name span, unrelated) |
| vf05_module_user | § fwWinnerListedObject255 | stage 1 on both; nondeterministic on both binaries |
| vf06_struct_td | § fwWinnerListedObject255 | fires; col on both with the same first record; record census 2 -> 2, lost 0 |
| vf07_enum_td | § fwWinnerListedObject255 | stage 1 on both, no firing |
| vf08_winner_own_uses | § fwWinnerListedObject255 | STRICT_EQUAL on both; nondeterministic on both binaries |
| vf09_elab_spec_var | § fwWinnerListedObject255 | STRICT_EQUAL on both, no move |

## 4. Pre-existing determinism defect (§ bareTdNameFirstWriterWins98; reported, not fixed)

`drivers/nondet.sh 10` over F/vf03, vf05 and vf08 (`evidence/nondet.txt`): **pristine writes two hashes on all six
case-views.** The law binary with `R11U255_OFF` draws the same two hashes, and the law binary also draws two.

**Decode.** In TypeEmit `collectFwWinners98`, every specialization of a generic class that declares the raced name
gets the same `TdClaim11` key, and the strict `k < it->second.key` keeps whichever comes first. They come in the
iteration order of slang's `GenericClassDefSymbol::specializations()`, which changes from run to run. When the
first one is a non-default specialization, `fwWinnerTs98` builds its typedef as an unparented twin. In pristine the
references bind that twin, so the dumps differ: vf03's pristine variant lists an extra
`class_typespec this_type 4:59` and the other variant does not.

**Effect of § fwWinnerListedObject255.** It re-points every reference to the listed object. The law's two draws
then **dump identically** on all six case-views (checked with uhdm-dump). The bytes still differ, because the
unreferenced twin stays in the serializer and holds its ids.

**Scope.** No gate row is affected: three concurrent draws read one hash on BuildUVMPkg, Earlgrey and the UVM rows,
and both sweeps equal those hashes.

**A fix** belongs in `collectFwWinners98`: a deterministic tie-break between specializations of one generic class.
Or `fwWinnerTs98` could return the listed object when the class_defn lists one, without building the twin. Either
would go behind its own switch.

## 5. Residues, ranked

1. BuildUVMPkg d/t #194627: the hier_path span of a call wrapped in an InvalidExpression (ExprEmit, § shellCallKeepsItsSyntax167; ground A). Unchanged.
2. § fwWinnerListedObject255's kind and position gate misses a typedef whose specialization changes the kind
   (vf02: golden binds the declaration's listed `int_typespec`, ours the `byte_typespec` built for `aa_reg #(byte)`).
   Wrong on pristine too.
3. A middle select with an expression index under the CFC writer (vc02, the implementer's C/c09). Wrong on pristine
   too.
4. § defGenCfcThroughCondSel255 stops at a call argument (vc14: `f(c ? reg2hw.en[0] : 1'b0)`, golden's CFC form
   `work@dut.g.reg2hw.en[0].en` at the digit, ours the legacy dotted text). Wrong on pristine too.
5. Definition-view generate path full-name text: the raw spelling (spaces, macro text, a nested index) stored where
   golden writes normalized text (`key [7 - i]`, `` key[`REVi] ``; golden's `key[[i]]` for `key[idx[i]]`); ve01,
   ve02, ve04, ve05, ve09, ve14 are stage 1 on both binaries.
6. Section 4's determinism defect.
7. The implementer's residues stand: Earlgrey #154375 / #165002 and #136315 / #137760 (ExprEmit); #190726 and
   behind it on this ground; Rggen #26477 (ModuleEmit); E/e06, e08.

## 6. Process

* Nothing fenced was dispatched, read or opened outside the gate sweeps.
  * The fence names were read from `tools/probe/r11u107repro/canaudit.sh`.
  * Every path list (byteverify mirrors, probe and downstream byte lists, cmds.txt audit, controls) was filtered by
    `$FENCED` before any file was opened.
  * The firing census ran through the harness with the filter built from `$FENCED`.
  * The evidence csvs have the fenced rows removed.
* No process was listed or signalled; waits tested files.
* Every tool variable was checked with `[ -x ]`.
* One driver call ran with `B` overwritten by a case path: case.sh refused to `cd` before running anything. It wrote
  only empty directories under this pass's own scratch root, and those were removed.
* Two first-draft fresh cases were illegal SV (slang exit 3 on both binaries). They were rewritten as vc05 and vc06
  and gridded again; the totals above are over the final 46 cases.
