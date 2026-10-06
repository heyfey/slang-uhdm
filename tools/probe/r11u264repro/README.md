# r11u264: pass 264, the expression/parameter ground (Earlgrey default, the ctor-copy head of MiniAmiq / SeqDriver)

Base abc22480 (pass 262). The pristine binary has md5 52573f406f01c43fb57d2d6c829e7f48, identical to the main tree's
build. The law binary has md5 27c1dab2740341ebe116d3cd5923b21d. Both link slang 12.0.0+545f88b2e and both were
frozen before any measurement. Rebuilt from the delivered patch in a fresh worktree of abc22480, the law binary has
the same md5.

Seven laws, in StmtEmit, ExprEmit and ParamEmit, behind `src/R264.h`:
- Each law reads its own `R11U264_<LAW>_OFF` switch.
- `R11U264_OFF` drops all seven. It gives pristine bytes on every grid case-view (164 of 164).
- `R11U264_TRACE=<dir>` logs every firing and every abstention: one file per process, its first line `OUT <-o path>`.

## Verdict per targeted row

| row-mode | base (pristine sweep) | law sweep (fresh csv row) | after |
|---|---|---|---|
| **Earlgrey_0_1 default** | `differ:fullname(192)` | **`Earlgrey_0_1,default,CMP_EQUAL,,,equal`** | **CONVERTED**. uhdm-strictcmp reads STRICT_EQUAL over 2173209 objects |
| Earlgrey_0_1 testflags | `differ:fullname(14)` | `Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(14),,differ:fullname(14)` | Same first records #580520 / #580527 / #580790. All 14 are on the sister ground (see below) |
| MiniAmiq default / testflags | `differ:depth(1)` #134648 | `MiniAmiq,<mode>,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)` | #134648 is cleared. The new head #136655 is the sister's |
| SeqDriver default | `differ:depth(1)` #134606 | `SeqDriver,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)` | #134606 is cleared. The new head #136613 is the sister's |
| SeqDriver testflags | `differ:depth(1)` #134618 | `SeqDriver,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)` | #134618 is cleared. The new head #136625 is the sister's |

Two probe cases convert:
- `r10earl111repro/g6_view111`: `differ:fullname(2)` -> EQUAL, by § plainMemberIpsOwner264.
- `r11u115repro/grid/i/s12_one_pl_pos_recvA_noov`: `differ:file(1)` -> EQUAL, by § elabParamRefSignedTsUnlocated264.

The rows are quoted in evidence/fresh_rows.txt.

**Earlgrey default, before.** Its 192 records (evidence/earlgrey_default_base_records.txt, the full list without `--max`)
fall into six faces, all written by this ground:

| records | face | law |
|---|---|---|
| 15 (#1402682 ...) | `assign reg2hw_wrap.alert_en[k] = ...` in a for-generate of alert_handler_reg_wrap. Golden names the index `...gen_alert_en_class[0].reg2hw_wrap.alert_en[k].k`; ours named it `...gen_alert_en_class[0].k` | § caLvTrailIdxNamesByPath264 |
| 2 (#1465373, #1488054) | `localparam int AVFifoWidth = NBufWidth;` (usbdev) and `LocalDataBitsPerMask = (EnableParity) ? 1 : DataBitsPerMask` (prim_ram_2p_async_adv). Golden's int_typespec has no location; ours was at the declaration | § elabParamRefSignedTsUnlocated264 |
| 1 (#1465389) | `localparam int NEndpoints = usbdev_reg_pkg::NEndpoints;` beside `import usbdev_reg_pkg::*`. Golden reads usbdev.sv 91:14; ours read usbdev_reg_pkg.sv 10:13 | § pkgQualRefShadowOwnTs264 |
| 29 (#1794121 ...) | The endcol of `tl_h_i[i].a_source[0+:(IDW-STIDW)]` (tlul_socket_m1). Golden's span ends after `)` (97:40); ours ended at 97:39 | § memberIpsParenEnd264 |
| 87 | The folded operands of `(IDW-STIDW)` / `IDW-1`. Golden names their typespec references through the select (`...u_sm1_17.gen_host_fifo[0].tl_h_i[i].a_source[0+:8 - 2].a_source`); ours used the instance's name | § selRootIpsOpFoldChainName264 |
| 58 | The folded width of `drsp_fifo_o.d_source[0+:STIDW] == i` in gen_idrouting. Golden names it after the instance `...u_sm1_17`; ours used the generate scope `...u_sm1_17.gen_idrouting[0]` | § plainMemberIpsOwner264 |

Record census on Earlgrey default (evidence/away_corpus.txt):
- The distance falls from 136 to 2. The remaining 2 are canonicalised typespec identity, invisible to the strict
  walk.
- 0 records lost, 134 gained.
- The chain-keyed census reads 0 away and 192 toward.

## The laws

### § ctorBidLhsCloneCopy264 (`R11U264_CTORCOPY_OFF`)

Site: StmtEmit `emitCtorBody27`, both the EK_BID branch and the wrapper.

- **What golden does.** An OUT-OF-BODY constructor (`function uvm_component::new(...)`) is listed on its package's
  task_funcs. A wildcard importer therefore holds Surelog's `clone_tree` of it (CompileHelper.cpp `importPackage`,
  `inPackage`). DeepClone copies each list separately:
  - the wrapper begin's Variables, each copy parented at the begin;
  - every declaration assignment's Lhs, each copy parented at the assignment. Under § ctorDeclIsRhslessAssignment27
    the Rhs-less ones count too.
- **What ours did.** We shared one variable between the two lists, parented at the assignment. Golden's walk met
  `string_var error_str` where ours met the assignment (MiniAmiq #134648).
- **The rule.** This is § importCloneBodyLocalCopies175's model, which the subroutine-body wrapper already follows.
  The constructor body now registers into the same design-final copy drain: `cloneLocalLhs175` for the Lhs and
  `CloneLocalWrap175` for the wrapper list.
- **Scope.** Only under the wrapper and only in an importer clone (`pkgImportCloneEmit`), behind R11U175_MULT_OFF
  as well.
- **Controls.** An in-body constructor is not in the package's task_funcs, so it gets no copy (the first case
  draft, all STRICT_EQUAL on pristine). A plain extern function stays equal (c08). With no importer (c05), golden
  and ours are equal.

### § caLvTrailIdxNamesByPath264 (`R11U264_CALVTRAILIDX_OFF`)

Sites: ExprEmit `emitMixedHierPath` (site 1) and the `emitExpr` member-select branch (site 2) of
§ hpTrailSelIdxNamesByPath133.

- **The rule.** § hpTrailSelIdxNamesByPath133 now holds for the WHOLE LEFT SIDE of a continuous assignment too.
  Surelog stores no full name on the trailing select's index references, so ComputeFullName names them through the
  path:
  - `work@top.g[0].w.en[k].k` for a direct index;
  - `...w.en[k + 2].en.k` for an index under an operation.
- **Where it holds.** In a generate scope or in the module body (`assign w.en[P] = ..` gives `work@top.w.en[P].P`),
  in both views. Ours used the scope's `work@top.g[0].k`.
- **It applies only** when the path's emission parent is the cont_assign itself.
- **Literal indices.** A literal index is traced as an abstention (no reference to rename).

### § elabParamRefSignedTsUnlocated264 (`R11U264_REFSIGNTS_OFF`)

ParamEmit `emitParameters`, recorded there and applied design-final in `drainPaNameCopySrc38`.

- **What golden does.** An elaborated parameter whose value is read BY NAME from a SIGNED parameter holds a fresh
  unlocated signed int_typespec. Surelog's compileExpression mints a constant from the referenced value, and
  `if (sval->isSigned())` it gives that constant its own `s.MakeInt_typespec()` with VpiSigned and nothing else. A
  ternary hands back its taken branch's object, and a unary plus compiles to its operand.
- **When golden keeps the declared, located typespec:**
  - an operation, a call, a literal or an explicit cast (p07 T9, T10, p01 RXW);
  - an unsigned source (p07 T4);
  - an `integer` source (p07 T5);
  - an overridden source, whatever the override (p09, p21 same / different / parent / negative);
  - a package source read unqualified (p11).
- **For an untyped parameter** we had no reference at all. Golden's constant carries the minted one, so the law mints
  the reference too (p05, p07 T6).
- **Abstains:**
  - an interface port view's listing (Surelog's copy of the definition, located in golden: tests/probe
    r11u115repro grid/i s12; cases/P p18);
  - an element of an interface array (our element listing is the object the port view reaches too; tests/probe
    r10rgg3repro f1, p19);
  - a parameter that shadows a wildcard-imported package parameter of the same name (r11u262repro D/d16, p20);
  - a vector target (golden mints an unlocated logic_typespec [7:0] there, p07 T1: not modelled).
- **Scope.** The elaborated view of a module's own default only.

### § pkgQualRefShadowOwnTs264 (`R11U264_QUALSHADOW_OFF`)

ParamEmit, the `pkgRefFold` clone branch (§ pkgRefFoldClonesMultiDimOnly140).

- **The rule.** Take a module body parameter that SHADOWS the wildcard-imported package parameter it reads by `pkg::`
  name, in a module with no parameter port list. In golden it is not a clone of the package value: the
  param_assign keeps its own Rhs constant, parented at its own assignment, over the module's own declared typespec.
- **With a header list** golden clones as before (p16), the § bodyParamNoHdrList262v distinction.
- **Not this law's:** a different name (p13) or no import (p03).

### § memberIpsParenEnd264 (`R11U264_IPSPARENEND_OFF`)

Sites: ExprEmit, the indexed part select of a member path, both the select-rooted and the variable-rooted builder.

- **The rule.** The select ends where Surelog's right bound ends, and that bound is the WRITTEN expression with its
  parentheses (`a_source[0+:(IDW-STIDW)]`: golden ends at 97:40, ours ended at 97:39).
- **Where it holds.** In any context: generate, module body, process, both views (g18 in the module body, where
  every span now reads golden's).

### § selRootIpsOpFoldChainName264 (`R11U264_IPSOPCHAIN_OFF`)

ExprEmit, the select-rooted member path builder.

- **The rule.** In a generate scope's continuous assignment, a member path rooted at a select
  (`tl_h_i[i].a_source[...]`) whose indexed part-select base or width is an operation over parameters keeps that
  operation with each folded operand IN the operation. Golden parents the operand constants there, and their typespec
  reference reads `<scope>.<select's full name>.<member>`.
- **What ours did.** We parented them at the owning instance's param_assign (§ genIpsBoundOwner256's clone) and named
  them after the instance.
- **Where it does not apply.** A bound that is a bare parameter keeps the instance (g04, g07). The `--elabuhdm` view
  folds the whole operation and has no reference.

### § plainMemberIpsOwner264 (`R11U264_PLAINIPSOWN_OFF`)

ExprEmit, the dotted variable-rooted member path builder.

- **The rule.** § genIpsBoundOwner256 now applies at this site too. In a for-generate's continuous assignment the
  folded width of `d.a_source[0+:STIDW]` is named after the owning instance (`work@top.u`), in every position: whole
  right side (g03), operand (g02), concatenation (g09).
- **What ours did.** We named it after the generate scope.

## Grid (cases/C, G, N, P; drivers/grid.sh; evidence/grid.txt, gridsum.txt)

The grid has 82 case dirs: C 12, G 19, N 27, P 24. Each dir runs in both views on 10 configurations: P, L, OFF and
the law with each of the seven switches off. That gives 1640 lines, each carrying its exit code:
- 1620 lines rc 0.
- 20 lines rc 4: C/c11 on both binaries, a pre-existing unsupported-construct exit, ranked in the residues.

Results over the 164 case-views:
- `R11U264_OFF` gives pristine's bytes on 164 of 164.
- 110 case-views move, 66 enter STRICT_EQUAL and none leave.
- The chain-keyed away census (drivers/awaychain.py, evidence/away_cases.txt) reads away=0 on all 110 movers.

Six case-views change their uhdm-cmp line count:
- C/c09 and C/c12, both views: the head stays the same `module_inst` object. Its print grows by the importer's new
  copies, and the dump distance to golden falls.
- P/p07, both views: the head moves later, from T2 to T1, the vector target the law leaves alone.

Each moving case-view is moved by the switch of the law it names; the combinations in gridsum.txt are cases
carrying several shapes (g01 is the whole tlul_socket_m1 shape). Every case names its law in its first line.

Cases by law (P -> L, default view; the elaborated view reads the same unless noted):
- **§ ctorBidLhsCloneCopy264**:
  - c01, c06 (two importers), c07 (multi-declarator), c10 (nested begin): depth -> STRICT_EQUAL.
  - c02, c03, c04, c09, c12: stage 1 on both binaries. They move toward golden: Surelog's out-of-body array and
    queue locals leak as nets of the importing module, `q` binds to `work@top.q`, and the port-less constructor eats
    its first element.
  - c05, c08: controls.
  - c11: rc 4 on both binaries.
- **§ caLvTrailIdxNamesByPath264**:
  - fullname -> STRICT_EQUAL: n01-n03, n06, n08, n10, n12, n14, n20, n21, n26, n27.
  - Moving, stage 1 on both: n11, n19, n23, n24 (dump distance falls).
  - n05 stays endcol: the port struct typespec span, a different face.
  - Controls: n04, n07, n09, n13, n16.
  - Residues: n15, n17, n18, n22, n25.
- **§ elabParamRefSignedTsUnlocated264**:
  - file -> STRICT_EQUAL: p01-p04, p12, p18.
  - Moving with 0 away: p07, p08, p10, p20 (stage 1 on both) and p09 (the cont-assign fold is the sister's).
  - Controls: p11, p19, p21 x4.
  - p05 is stage 1 on both, unchanged.
- **§ pkgQualRefShadowOwnTs264**:
  - p15: line -> STRICT_EQUAL.
  - p06: one record left, the definition-view `Z = NE` (a residue).
  - p14: stage 1 (the `assign o = NE` package-listing head, as on p13).
  - Controls: p16, p17.
- **§ memberIpsParenEnd264, § selRootIpsOpFoldChainName264, § plainMemberIpsOwner264**:
  - endcol/fullname -> STRICT_EQUAL: g01, g02, g03, g09, g11-g14, g16, g17.
  - g18 and g19: stage 1 on both, every span now golden's.
  - Controls: g04, g05, g07.
  - Stage 1 on both: g06, g08, g10, g15.

Downstream on the cases (drivers/dscases.py, the first 78 dirs; evidence/downstream_cases.txt): 70 IDENTICAL and
8 EQUIVALENT, the same verdict on both binaries.

## Byte controls (drivers/controls.sh; evidence/controls_dirs.txt, controls.txt, controls_sum.txt)

The controls cover 35 earlier repro dirs:
- r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131;
- r/v pairs for 244, 246, 248, 250, 252, 254, 256, 258, 260, 262, 263, 265 and 267.

Totals: 5074 case-views in both views, every path list filtered by `$FENCED` before any file was opened. Results:
- 8 case-views move, 2 enter STRICT_EQUAL, none leave.
- No exit code changes. No uhdm-cmp line count changes.

The movers, each attributed by trace:
- r11u120repro grid/gA/a09_genfor, both views: § caLvTrailIdxNamesByPath264. It enters STRICT_EQUAL, toward 4.
- v11u262repro VB/vb11, both views: § elabParamRefSignedTsUnlocated264, toward 1. The one record left is the
  `a[0 +: W2]` width fold of the same parameter (a residue).
- r11u254repro G/g07_hp_ips, both views: § selRootIpsOpFoldChainName264. Stage 1 on both, chain census 0 / 0.
- v11u244repro B/b04_cls_forms, both views: § memberIpsParenEnd264. Stage 1 on both, chain census 0 / 0.

The rc 139 lines are r11u254 F/f04_class_el and v11u254 F/vf02_iface_el and vf04_hier_el. They crash on both
binaries: the known `--elabuhdm` for-init crash.

## Gates (evidence/sweep_pristine.log, sweep_law.log, rowdiff.txt)

Both sweeps are tests/sweep.sh `--jobs 3`, the pristine and law workdirs of equal length. The law sweep exited 0
and reads:

| stage | result |
|---|---|
| probe | 3577 EQUAL + 510 STRICT_NOTEQUAL. regressions=0, conversions=2 (above), changes=0 |
| surelog | default 476 + 4, testflags 469 + 5, so 945 + 9 of 954. regressions=0, conversions=1 (Earlgrey default), changes=0 |
| uhdm2rtlil | 1606 + 0. regressions=0, conversions=0, changes=0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT. The verdict diff against the pristine sweep is 0 |

Row by row, law sweep against pristine sweep:
- surelog: 3 rows differ. Earlgrey default is the conversion. The LowMemLib and LowMemPkg testflags detail text
  differs because it embeds the workdir path (environment).
- uhdm2rtlil: 0 rows differ.
- probe: the 2 conversions.
- No row's strict column worsens.

The pristine sweep reproduces the baselines exactly. Its rc is 1, on the law-index check only: it ran while this
pass's src edits were in the worktree.

**byteverify** (`SELFCHECK=1`; evidence/byteverify_*.txt):

| corpus | movers | names | SELFCHECK |
|---|---|---|---|
| surelog | 6 of 960 | Earlgrey_0_1 d/t, MiniAmiq d/t, SeqDriver d/t | 959 of 960 |
| uhdm2rtlil | 0 of 1608 | | 1607 of 1608 |
| downstream | 0 of 805 | | 804 of 805 |
| probe (a byte compare) | 2 of 4087 | g6_view111, s12_one_pl_pos_recvA_noov | 4086 of 4087 |

The SELFCHECK compares every file with ONE fixed file, so it flags N-1: the fixed file is identical to itself. That
is a self-check artifact, not a missed mover.

**The firing census** (drivers/tracecensus.sh; evidence/census_predict.txt) was run with the final binary over the
probe cases, both corpora in both modes and the downstream lane, filtered by `$FENCED`, and frozen before the law
sweep. It predicted exactly the 8 databases above, the abstentions listed apart:
- Earlgrey d/t: CALVTRAILIDX 15, IPSOPCHAIN 87, IPSPARENEND 29, PLAINIPSOWN 58, QUALSHADOW 1, REFSIGNTS 2 each;
- MiniAmiq d/t and SeqDriver d/t: CTORCOPY 2 each;
- probe g6_view111 (PLAINIPSOWN 2) and s12 (REFSIGNTS 1).

**Away censuses on the 6 corpus movers** (evidence/away_corpus.txt, away_chain.txt):

| row-mode | record census (awaycorp.sh) | chain-keyed census (awaychain.py) |
|---|---|---|
| Earlgrey default | dist 136 -> 2, lost 0 | away 0, toward 192 |
| Earlgrey testflags | dist 552 -> 447, lost 0 | away 0, toward 105 |
| MiniAmiq d/t | dist 110 -> 110, lost 0, gained 27 | away 0, toward 27 |
| SeqDriver d/t | dist 81 -> 81, lost 0, gained 18 | away 0, toward 18 |

uhdm-cmp reads 0 lines on all six movers.

**Other checks:**
- **Canaries.** surelog ok=51 changed=1 (the Earlgrey default conversion). uhdm2rtlil ok=16 changed=0.
- **ctcan2.** surelog PASS (`EXPECT_UNKNOWN=1`, ok=58). uhdm2rtlil PASS (`EXPECT_UNKNOWN=6`).
- **Binary-path audit.** 3265 of the 3315 fence-filtered cmds.txt name `/tmp/r11u264_bin/law`. The other 50 carry no
  slang line.
- **Determinism** (drivers/det.sh; evidence/determinism.txt). Three concurrent draws on Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen give one hash per row-mode, equal to the sweep's.

## Sister-ground faces (reported, not written)

**MiniAmiq #136655 and SeqDriver #136613 / #136625, now the head of all four row-modes.**
- Where: `uvm_algorithmic_comparator`'s `type_id` in the svaunit_pkg listing.
- What differs: golden's class_typespec `type_id` lists a type_parameter `T` whose reference resolves to the last
  `uvm_component_utils` expansion (`class_typespec svaunit_base` / `adpcm_driver`, uvm_object_defines.svh 468:35),
  plus a param_assign. Ours has the type_parameter with an unbound reference.
- The writer: UhdmExporter, `emitClassTdSpecParams1` / `copyClassTdSpecParams1` (§ classTdSpecParamsForeignHome1,
  § classTdCloneSpecOverridesOwnArgs112). In `copyClassTdSpecParams1` the copied reference takes the base's
  `Actual_typespec()`, which is null here. Both are UhdmExporter's.
- Neither row can convert on this ground.

**Earlgrey testflags.** All 14 records are the sister's:
- **13 records #580520 ... #594077.** These are the typespec_member references under the port actual
  `reg2hw.mp_region_cfg[0].en.q` (flash_ctrl_reg_top.sv:1003). Golden names them
  `work@flash_ctrl_reg_top.flash_ctrl_reg_pkg::flash_ctrl_reg2hw_mp_region_cfg_mreg_t.en`; ours names them
  `flash_ctrl_reg_pkg::flash_ctrl_reg_pkg::...::en`. This is the port-actual struct member binding, ModuleEmit /
  TypeEmit.
- **#604991 depth.** Golden lists `array_var work@top_earlgrey.u_flash_ctrl.u_flash_mp.region_end`, where ours has
  no such object (the variable listing, ModuleEmit).

**Other faces on the sister ground:**
- **Cont-assign fold of a law parameter.** A whole-right-side read of a § elabParamRefSignedTsUnlocated264
  parameter (`assign o = C;`, P/p09) folds into a clone whose typespec ModuleEmit's `pendingParamCloneTs` drain
  rebuilds from the declaration (located). Golden's is unlocated.
- **Interface-array element listing.** Ours is one object for `arr[k]` and the receiving port's `p[k]`, where
  golden keeps two (r10rgg3repro f1, P/p19). This is ModuleEmit's interface port view. § elabParamRefSignedTsUnlocated264
  abstains there.
- **Package listing.** The package listing / cont-assign whole read of a package-clone constant
  (`assign o = W;` with `W = pk::NE`, P/p13 and p14) is stage 1 on both binaries.

## Residues on this ground, ranked

1. **The width fold of a § elabParamRefSignedTsUnlocated264 parameter in an indexed part select** (v11u262 VB/vb11
   `a[0 +: W2]`, one record). ExprEmit `stampFoldedPkgParamTs` gives the declared typespec; golden's is unlocated.
2. **A vector-typed parameter read by name** (`localparam logic [7:0] T1 = A`, P/p07). Golden mints an unlocated
   logic_typespec with the target's range.
3. **The definition-view Rhs reference of a parameter reading a shadowing local** (P/p06 `Z = NE`, one record).
   Ours binds the package's typespec, golden the module's. Pass 262's first-match family.
4. **§ caLvTrailIdxNamesByPath264's open shapes:**
   - two element selects `w.en[k][j]` (n15: golden `...w.en[k][j].en.k`, ours `w.en[k][j].k`, a var_select);
   - an indexed part select on the left side (n17: golden `...w.en[k * 4+:4].en.k`);
   - a case-generate select index folded in the name (n18);
   - a concatenation left side (n22);
   - a package-qualified index (n25, stage 1);
   - a module-port struct (n05, endcol of the struct typespec).
5. **The variable-rooted member path with an operation bound** (G/g10, g08, g15: stage 1 on both binaries). The
   selection text renders `d.a_source[0+:(W]` (the parenthesized bound truncated in the name, g18 as well).
6. **The constructor body with one declaration only** (C/c11). Both binaries exit 4 with "unsupported constructs:
   VariableDeclaration".
7. **The --elabuhdm crashes (rc 139)** on r11u254 f04_class and v11u254 vf02 / vf04 (pass 254's residue, unchanged).
8. **The brief's items (2) to (7) were not attempted.** The listed residues of passes 232-262 are untouched.

## Process

**Draft binaries.** Nine draft law binaries were built and measured on cases only. Two earlier frozen law
binaries were swept before the final one, and both of those sweeps read regressions=0:
- 946711ef applied § elabParamRefSignedTsUnlocated264 at emission. Its probe byteverify and byte controls showed:
  - three away records on r10rgg3repro f1, the interface-array port views;
  - one away record on r11u262 D/d16, an import-shadowing target;
  - r11u115 grid/i s12 moving one record each way.
- 33c45ac9 was the same law with the CALVTRAILIDX literal-index trace split off as an abstention.

The law was then deferred to a design-final drain with the port-view, interface-array and shadow abstentions. The
census, the law sweep, the grid and the controls were rerun from scratch on the final binary 27c1dab2. Every number
above is the final binary's.

**The fence.** Every driver reads `$FENCED` from tools/probe/r11u107repro/canaudit.sh fail-closed. Every corpus path
list was filtered by word boundary before any file was opened. No fenced test was dispatched, read or decoded
outside the gate sweeps, and the whole-word scan of this directory reads 0.

**Processes and files.** No process was signalled. One `rm` with a variable target was refused by the shell guard
and rewritten with a literal path. The copied drivers' added header line was moved below the shebang.

**The law index.** tests/LAWS.md was regenerated last.

## Drivers

drivers/ (copied from r11u265repro):
- env.sh, case.sh, grid.sh, gridsum.py: the case grid.
- controls.sh, ctlsum.py: the byte controls.
- tracecensus.sh: the firing census, now including the downstream lane and listing abstentions apart.
- awaycorp.sh, away.py, awaychain.py, awayrows.py, cc_x.sh, strictcmp_x.cpp: the away censuses.
- rowhead.sh: a sweep row's strict records.
- det.sh: the determinism draws.
- dscases.py: downstream on cases.
