# r11u126 — the LAW file of every unresolved gate case

Base `7bd06f52`. Maintenance pass: no production file, no case source and no
script is touched. The only writes are the `LAW` files under `tests/probe/` and
this README. A `LAW` file holds one law name per line, and every name written
here is a law of `tests/LAWS.md` section 1 (checked by name against the index).

At the base the index listed 1858 gate cases with a `?` (a pass owning several
laws, nothing saying which one the case exercises) and 604 tied to no law
(section 3). Every one of the 2462 was looked at, pass by pass. 2081 now carry
a `LAW` file. 381 stay without one, each for a stated reason below: no case was
given a law by guess.

## Counts, before and after (`scripts/law_index.py` run in the worktree)

| | at 7bd06f52 | after |
|---|---|---|
| cases in the gate | 4087 | 4087 |
| tied to one law (a LAW file, the text, a README row or heading, or a single-law pass) | 1625 | 3706 |
| listed with `?` under several laws | 1858 | 99 |
| tied to no law (section 3) | 604 | 282 |
| laws with cases in the gate | 545 | 532 |

The last row falls because a `?` case used to be listed under EVERY law of its
pass; a determined case is now listed only under the law it exercises, so a law
that only ever carried `?` cases (for example a law cited by a pass README but
landed elsewhere) no longer shows gate cases it never had.

## How a case was resolved

In the order the brief gives: (1) the pass README's grid table or prose naming
the case; (2) the pass's own evidence and generator scripts: a per-switch drop
ledger (`evidence/DROPS*.txt`, `SWITCH*.txt`: the kill switch that returns the
case to pristine names its law, switch -> law from the README's drop table), a
grid generator's face comments, a grid table; (3) the case's own header comment
against the law's statement; (4) the landing commit message. A control case
(one no switch moves) takes the law of the face its grid dir or README row
assigns it; a control of several laws lists each. A verification pass's cases
take the laws of the pass its README title names, plus the verifier's own fence
where the case is that fence's case (its source comment names the verifier).

## Why 381 cases have no LAW file

* **The law has no pass number.** Passes before the index grammar named their
  laws without the trailing pass number (`genCaDrivenOpenerIsGenLocalOnly`,
  `ifacePortViewParamAssignsOnly`, the Earlgrey pass 2-17 and Rggen pass 6-9
  laws). The law is determined for most of these cases and is recorded in the
  pass row below, but the index recognises only `<name><number>`, so a LAW file
  naming it would tie the case to a name that has no entry in section 1. The
  fix is to give each such law its number at its source sites and README, then
  write the LAW files.
* **The face never landed in that pass.** The README says the face was stopped
  at the decode, fenced or left as a residue, and the pass's evidence shows the
  case byte-identical between pristine and law. Only the pass's own laws may be
  written, and none of them is exercised.
* **Carried controls of earlier passes.** The README lists them as boundary
  controls of other passes (byte-identical, no switch moves them).
* **No law landed.** Measurement-only passes, and a witness the landing commit
  records as not reproducing.

## Per pass

`?` and `none` are the counts at the base; `LAW` is the number of LAW files
written; `left` the cases still without one.

| pass | ? | none | LAW | left |
|---|---|---|---|---|
| r11u27repro | 0 | 199 | 199 | 0 |
| r11u115repro | 117 | 0 | 117 | 0 |
| v11u116repro | 106 | 0 | 106 | 0 |
| r11u116repro | 102 | 0 | 102 | 0 |
| r11u113repro | 96 | 0 | 96 | 0 |
| r11u112repro | 80 | 0 | 71 | 9 |
| r10earl_repro | 0 | 78 | 20 | 58 |
| r11u22repro | 73 | 0 | 73 | 0 |
| r11u23repro | 73 | 0 | 73 | 0 |
| r10vrgg9repro | 69 | 0 | 69 | 0 |
| r11u109repro | 62 | 0 | 62 | 0 |
| r11u108repro | 56 | 0 | 17 | 39 |
| r11v23repro | 52 | 0 | 52 | 0 |
| r11u93repro | 50 | 0 | 50 | 0 |
| r11u111repro | 47 | 0 | 46 | 1 |
| r11u19repro | 46 | 0 | 46 | 0 |
| v11u112repro | 43 | 0 | 43 | 0 |
| r11u110repro | 40 | 0 | 40 | 0 |
| r11u15repro | 0 | 40 | 0 | 40 |
| v11u110repro | 40 | 0 | 40 | 0 |
| v11u115repro | 38 | 0 | 38 | 0 |
| r11u17repro | 37 | 0 | 33 | 4 |
| r10rgg3repro | 0 | 35 | 0 | 35 |
| r10sd10repro | 34 | 0 | 7 | 27 |
| r11u107repro | 34 | 0 | 31 | 3 |
| r11u48repro | 34 | 0 | 34 | 0 |
| v11u114repro | 32 | 0 | 32 | 0 |
| r11u105repro | 31 | 0 | 31 | 0 |
| v11u113repro | 0 | 31 | 31 | 0 |
| v11u111repro | 0 | 30 | 30 | 0 |
| v11u93b107repro | 30 | 0 | 30 | 0 |
| r11u103repro | 29 | 0 | 29 | 0 |
| v11u93repro | 28 | 0 | 28 | 0 |
| r11u90repro | 26 | 0 | 26 | 0 |
| r10vrgg3repro | 0 | 24 | 0 | 24 |
| r11u101repro | 22 | 0 | 22 | 0 |
| r11v48repro | 22 | 0 | 22 | 0 |
| r11vu15repro | 0 | 22 | 0 | 22 |
| v11u108repro | 21 | 0 | 21 | 0 |
| r11v17repro | 20 | 0 | 20 | 0 |
| r11u98repro | 19 | 0 | 19 | 0 |
| r11v95repro | 19 | 0 | 19 | 0 |
| r11v22repro | 17 | 0 | 17 | 0 |
| r11v88repro | 17 | 0 | 17 | 0 |
| r10buvm8repro | 16 | 0 | 16 | 0 |
| r11u88repro | 15 | 0 | 2 | 13 |
| r11v105repro | 15 | 0 | 15 | 0 |
| r11v93repro | 15 | 0 | 15 | 0 |
| r10vrgg11repro | 14 | 0 | 14 | 0 |
| r11u99repro | 14 | 0 | 12 | 2 |
| r10vrgg4repro | 0 | 13 | 13 | 0 |
| r10rgg10repro | 9 | 0 | 9 | 0 |
| r10rggen7repro | 0 | 9 | 0 | 9 |
| r10svs2repro | 0 | 9 | 0 | 9 |
| r10uvm12repro | 0 | 9 | 9 | 0 |
| r11v16repro | 0 | 9 | 0 | 9 |
| r10imex_repro | 0 | 7 | 0 | 7 |
| r10v119repro | 7 | 0 | 7 | 0 |
| r11v26repro | 7 | 0 | 7 | 0 |
| r11v70repro | 0 | 7 | 7 | 0 |
| r10v97repro | 6 | 0 | 6 | 0 |
| r11u117repro | 6 | 0 | 5 | 1 |
| r11u14repro | 0 | 6 | 0 | 6 |
| r11vu3repro | 0 | 6 | 0 | 6 |
| r10uvm49repro | 0 | 5 | 0 | 5 |
| r10yos1repro | 0 | 5 | 0 | 5 |
| r11v45repro | 5 | 0 | 5 | 0 |
| r11v53repro | 5 | 0 | 5 | 0 |
| r11v74repro | 5 | 0 | 5 | 0 |
| r10buvm7repro | 4 | 0 | 4 | 0 |
| r10fiot_repro | 0 | 4 | 0 | 4 |
| r10v199repro | 4 | 0 | 4 | 0 |
| r11u51repro | 0 | 4 | 0 | 4 |
| r11v83repro | 4 | 0 | 4 | 0 |
| r10itype_repro | 0 | 3 | 0 | 3 |
| r10rggen6repro | 0 | 3 | 0 | 3 |
| r10scr13repro | 0 | 3 | 0 | 3 |
| r10uvm21repro | 3 | 0 | 3 | 0 |
| r10uvm60repro | 3 | 0 | 3 | 0 |
| r10v146repro | 3 | 0 | 3 | 0 |
| r10v151repro | 0 | 3 | 3 | 0 |
| r11u11repro | 0 | 3 | 0 | 3 |
| r11u52vrepro | 0 | 3 | 3 | 0 |
| r11v11u9repro | 0 | 3 | 0 | 3 |
| r11v1repro | 0 | 3 | 0 | 3 |
| r11v32repro | 3 | 0 | 3 | 0 |
| r11v75repro | 3 | 0 | 3 | 0 |
| r11v77repro | 3 | 0 | 3 | 0 |
| r11vu13repro | 0 | 3 | 0 | 3 |
| r10rggen9repro | 0 | 2 | 0 | 2 |
| r10uvm101repro | 0 | 2 | 2 | 0 |
| r10uvm14repro | 2 | 0 | 2 | 0 |
| r10uvm77repro | 2 | 0 | 2 | 0 |
| r10uvm80repro | 2 | 0 | 2 | 0 |
| r10uvm8repro | 0 | 2 | 0 | 2 |
| r10v79repro | 2 | 0 | 2 | 0 |
| r11u10repro | 0 | 2 | 0 | 2 |
| r11u13repro | 0 | 2 | 0 | 2 |
| r11u32repro | 2 | 0 | 2 | 0 |
| r11u3repro | 0 | 2 | 0 | 2 |
| r11u70repro | 0 | 2 | 2 | 0 |
| r11u75repro | 2 | 0 | 2 | 0 |
| r11v4repro | 0 | 2 | 0 | 2 |
| r10buvm2repro | 1 | 0 | 1 | 0 |
| r10earl79repro | 1 | 0 | 1 | 0 |
| r10rggen8repro | 0 | 1 | 0 | 1 |
| r10scr14repro | 0 | 1 | 0 | 1 |
| r10uvm11repro | 1 | 0 | 1 | 0 |
| r10uvm13repro | 1 | 0 | 1 | 0 |
| r10uvm15repro | 1 | 0 | 1 | 0 |
| r10uvm17repro | 1 | 0 | 1 | 0 |
| r10uvm20repro | 1 | 0 | 1 | 0 |
| r10uvm22repro | 1 | 0 | 1 | 0 |
| r10uvm27repro | 1 | 0 | 1 | 0 |
| r10v134repro | 1 | 0 | 1 | 0 |
| r10v182repro | 0 | 1 | 1 | 0 |
| r10v64repro | 1 | 0 | 1 | 0 |
| r10v96repro | 0 | 1 | 1 | 0 |
| r10vearl99repro | 1 | 0 | 1 | 0 |
| r10vrgg17repro | 0 | 1 | 1 | 0 |
| r11u1repro | 0 | 1 | 0 | 1 |
| r11u39repro | 0 | 1 | 0 | 1 |
| r11u5repro | 0 | 1 | 0 | 1 |
| r11u79repro | 1 | 0 | 1 | 0 |
| r11v11u5repro | 0 | 1 | 0 | 1 |
| r11v96repro | 1 | 0 | 1 | 0 |
| v11u94repro | 1 | 0 | 1 | 0 |

## Sources, and the cases left, pass by pass

### r10buvm2repro

source: the verifier case v3 header: "the SYSTEM-CALL over-fire probe" =
classPropSysCallInit2

### r10buvm7repro

source: README section 3 (the pass lands lvIncDecSelMemberCollapse7 +
lvIncDecCollapseNetSpans7; lvIncDecOperandSpan7 / lvIncDecTrailingSelect7 are
its R1/R2 residues) + VERIFY.md case table: C_index (index exotica, collapse) and
O_macro (macro-built lvalue, collapse) = the collapse law; L_mint = "the SECOND
law: out-of-body method, mint + SPAN"; M_order = mint order/span of two
collapses (both)

### r10buvm8repro

source: README title + section 3 (the pair: the stamp pkgRetTopCallArgFormalTs8
and the source of its typespec pkgRetTopArgTsElabTwin8, one mechanism, every case
of the window) + VERIFY.md (the verifier's two fences in the same pass, their
comments say "(VERIFIER, r10buvm8)"): v11coll8/v12coll8 and vshadowcells8 v21_s*
= pkgRetArgTsFormalNameShadow8v; vfwd8/vfwdts8 (forward callee) and vxpkg8 (its
cross-package control) = pkgRetCalleeDeclaredFirst8v

### r10earl79repro

source: README title law dimExprBoundFold79 (an EXPRESSION-form unpacked
dimension folds); g1_first79 declares N+1 / N-1 / N*2 / N/2 / N<<1 / $clog2(N)
dims under two overrides = that law's first grid

### r10earl_repro

NO README; a multi-pass witness directory (Earlgrey passes 2-28). Source per
case: the Earlgrey pass commit that names the witness file (f20aee3e pass 18,
ff46f388 pass 20, 369eb416 pass 21, 45e1fe2b pass 22, c67ce75b pass 23, f9d98a53
pass 24, d1f9947d pass 25, 745eb77c pass 27) and the source comment that cites
it beside the law's (fc18 defGenQualPkgCallBinds18, pq20/pr20/ps20/px20
genCaOpDeepBindGenLocal20, qa20 elabConnSelFoldNoTs21, qc21, qe21, qf21, qh21,
qc22, qf22 x2, qb25, qj27); pp18 = the commit's deliberate negative witness of
law 3 genScopePkgParamRefTop18 (its header quotes that law's gen_for >
named_begin > gen_if_else > named_begin reach); pn20 = the pass-20 gen-scope CA
RHS bind witness (its own header), pt23 = dimFoldOverriddenParam23 ("pt23
measures six spellings"), qa23 = law 1 pair, wb24/wc24/wf24 = the commit's law 1
/ law 3 witnesses LEFT: py20 (the pass-20 commit ff46f388: "py20.sv is CMP_EQUAL
... does NOT reproduce", no law), qd25 (the pass-25 commit d1f9947d: the
frontier "REFUTED THREE WAYS by qc25/qd25", no law), qa28 (the pass-28 commit
6a3075a4: the refuted framing's grid, "qa28 3->3 untouched" by both pass-28
laws); every other left case is an Earlgrey pass 2-17 witness (letter-named
a..y, ua-ug, vb-vp, wa-wh; headers say r10earl3..r10earl15) whose pass named its
laws WITHOUT a pass number (e.g. pkgTypespecInstanceIsTop, impCopyBasedDecKeep,
genRefModuleImplicitPort, sysCallArgPkgParamSubst, castSizeParamRefBindFinal,
structParamBareImportRef, caOpFoldTs, refModConnOpFoldTs), or a header-less
pass-2 witness (a b c cc dd e f g h i l o p r) naming no pass at all.

Left without a LAW file (58): `a` `aa` `b` `c` `cc` `dd` `e` `ee` `f` `g` `gg`
`h` `hh` `i` `ii` `jj` `l` `ll` `mm` `nn` `o` `oo` `p` `py20` `qa28` `qd25` `qq`
`r` `rr` `s` `ss` `t` `ta` `tc` `td` `tf` `tj` `tl` `u` `ua` `ud` `ue` `uf` `ug`
`vb` `ve` `vf` `vj` `vk` `vl` `vo` `vp` `wa` `wd` `wf` `wh` `x` `y`

### r10fiot_repro

FuncIoTypespec laws fnLocalParamRangeNet / evalReachedCallees /
bareFormalTsReached. laws named WITHOUT a pass number, outside the index grammar
(a law is ` <name><pass number>`); the law is determined but a LAW file would
name no index law. Fix = give the law its number at its sites/README, then stamp

Left without a LAW file (4): `a5` `a6` `a7` `a9`

### r10imex_repro

NO README.md/.txt (plain README: modportExprPort and the InterfaceModExp
families). laws named WITHOUT a pass number, outside the index grammar (a law is
` <name><pass number>`); the law is determined but a LAW file would name no
index law. Fix = give the law its number at its sites/README, then stamp

Left without a LAW file (7): `t1` `t2` `t3` `t4` `t5` `t6` `t7`

### r10itype_repro

NO README.md/.txt (plain README: ifaceIfaceTypedPort /
ifaceIfaceTypedPortOrder). laws named WITHOUT a pass number, outside the index
grammar (a law is ` <name><pass number>`); the law is determined but a LAW file
would name no index law. Fix = give the law its number at its sites/README, then
stamp

Left without a LAW file (3): `t2` `t5` `t6`

### r10rgg10repro

source: README title law genLpPortConnRead10 + section 3 read-axis table
(portplain / ca / pov / proc_always / nestedca are its read kinds, pov /
proc_always / nestedca the declaration-typespec controls) + vrgg10/gen_gridv.py
("break genLpPortConnRead10": F1 read cases) and gen_gridv8.py (deepnest,
defonly); none of these cells is a call-argument cell of the verifier clause
genLpCallArgSelBlocks10v (vrgg10/CALLARG_LAW.txt grid7/grid6)

### r10rgg3repro

README title law (port-view member ranges follow the receiving module) is named
in r10vrgg3 as portViewRangeRecvParams / ifaceArrayElemViewFoldsDefault. laws
named WITHOUT a pass number, outside the index grammar (a law is ` <name><pass
number>`); the law is determined but a LAW file would name no index law. Fix =
give the law its number at its sites/README, then stamp

Left without a LAW file (35): `a1_mp_named_norecvp` `a2_mp_named_recvp`
`a3_mp_pos_norecvp` `a4_mp_pos_recvp` `b1_pl_named_norecvp` `b2_pl_named_recvp`
`c1_arr_whole_norecvp` `c2_arr_whole_recvp` `d1_elem_named_norecvp`
`d2_elem_named_recvp` `e1_namedovr_norecvp` `e2_namedovr_recvp`
`e3_namedovr_arr_recvp` `e4_namedovr_arr_norecvp` `f1_noovr_arr_recvp`
`g1_arr_recv_awbw` `g2_single_recv_awbw` `h1_two_level_arr`
`i1_module_array_pos` `j1_rggen_shape` `k1_rggen_apb_shape`
`l1_single_recvaw_differs` `m1_port_passthrough` `n1_transitive_vw`
`n2_recv_localparam` `n3_recv_var_notparam` `n5_gen_scope_recv`
`n6_recv_param_overridden` `n7_module_same_named` `n8_recv_ovr_disambig`
`n9_recv_type_param` `p1_multiparam_arr_recvp` `p2_multiparam_arr_norecvp`
`p4_textmulti_arr_recvp` `p5_gen_iface_arr_recvp`

### r10rggen6repro

NO README.md/.txt (plain README maps t4 genLpTsFoldBounds, t5 cast-seal +
genLpCaSharedBareTs, t7 genLpCaSharedBareTs). laws named WITHOUT a pass number,
outside the index grammar (a law is ` <name><pass number>`); the law is
determined but a LAW file would name no index law. Fix = give the law its number
at its sites/README, then stamp

Left without a LAW file (3): `t4` `t5` `t7`

### r10rggen7repro

NO README.md/.txt (a plain README file maps t1-t9 to defGenCallNoBind,
ifaceArrayPassThruActual, genRegionCondNoEnumBind, enumConstOvEnc,
genCaUnbasedSizing, genProcParamFold). laws named WITHOUT a pass number, outside
the index grammar (a law is ` <name><pass number>`); the law is determined but a
LAW file would name no index law. Fix = give the law its number at its
sites/README, then stamp

Left without a LAW file (9): `t1` `t2` `t3` `t4` `t5` `t6` `t7` `t8` `t9`

### r10rggen8repro

NO README.md/.txt (plain README: t1 elabInstCallDefSub). laws named WITHOUT a
pass number, outside the index grammar (a law is ` <name><pass number>`); the
law is determined but a LAW file would name no index law. Fix = give the law its
number at its sites/README, then stamp

Left without a LAW file (1): `t1`

### r10rggen9repro

NO README.md/.txt (plain README: t8 ifacePortVarHighConn; t9 not listed). laws
named WITHOUT a pass number, outside the index grammar (a law is ` <name><pass
number>`); the law is determined but a LAW file would name no index law. Fix =
give the law its number at its sites/README, then stamp

Left without a LAW file (2): `t8` `t9`

### r10scr13repro

connExprBindsNet / connActualParamFold. laws named WITHOUT a pass number,
outside the index grammar (a law is ` <name><pass number>`); the law is
determined but a LAW file would name no index law. Fix = give the law its number
at its sites/README, then stamp

Left without a LAW file (3): `t1` `t2` `t4a`

### r10scr14repro

genProcParamFold / elabOvRefCopiesParam. laws named WITHOUT a pass number,
outside the index grammar (a law is ` <name><pass number>`); the law is
determined but a LAW file would name no index law. Fix = give the law its number
at its sites/README, then stamp

Left without a LAW file (1): `t6`

### r10sd10repro

source: README title law classTdLocalVarKindFollowsCompileOrder10 (1.3 grid10
cells, 5 refutations) + each case's own header: "r10sd10 grid cell"
(g4_owner_reach, g6_extern_body, g8_sortorder_refutation) and "vsd10 adversarial
cell" (v5, v9, v13, v14) are this law's. aliasClassRefVar10 is r10uvm10's law
(commits dc4f5eb5/e74f7b4c), only cited here. The other cases are the sd4..sd9
kits "carried forward unchanged and RE-RUN as 4.2's boundary checks" (README 7):
their headers name no r10sd10 face (core/elem/discriminator cells of the import-
copy passes, q* queue-local cells, sd7 verifier cells v1-v3) -> UNRESOLVED,
their laws belong to those earlier passes

Left without a LAW file (27): `g1_assoc_class_elem_import`
`g1_assoc_index_import` `g1_direct_ref` `g2_dynarray_elem_import` `g2_spellings`
`g3_class_own_assoc_control` `g3_class_own_var_control`
`g3_dynarray_class_elem_import` `g4_class_own_assoc_control`
`g4_no_import_control` `g5_explicit_import` `g5_no_import_control`
`g6_class_handle_new` `g6_enum_td_control` `g6_typedef_elem_import`
`grid7_g4_no_import_control` `q10_pkgtype_oob_local`
`q1_cls_member_queue_struct` `q4_inbody_method_queue` `q5_pkg_var_queue`
`q6_mod_cls_member_queue` `q7_cls_member_dynarray` `q8_cls_member_queue_pkgtype`
`q9_clstype_oob_local` `v1_fixedarray_elem_import` `v2_dynarray_struct_typedef`
`v3_elem_class_of_importing`

### r10svs2repro

parensLessCallIsPathRefObj, parensLessFuncRefIsRefObj (commit 09ee8f91). laws
named WITHOUT a pass number, outside the index grammar (a law is ` <name><pass
number>`); the law is determined but a LAW file would name no index law. Fix =
give the law its number at its sites/README, then stamp

Left without a LAW file (9): `s1_dynsize` `s3_arraykind` `s4_context`
`s5_negctl` `s6_otherbuiltin` `s7_recvless` `w1_stmtfunc` `w2_spacedot`
`w3_macrodeep`

### r10uvm101repro

source: README "Decoded producer" names the implementation
eventTriggerSyntaxBaseName101 (the comment in src/StmtEmit.cpp cites
tools/probe/r10uvm101repro/g101_a2_nonblocking.sv); both cases are its token
grids

### r10uvm11repro

source: README.txt t3 entry: waitStmt11, waitFork11, newArray11 (the structural
drops t3 pins)

### r10uvm12repro

NO README. Source: the UVM pass 12 landing commit 82de36b8 (four laws:
staticScopedCall12 a static class method through ::, staticScopedRef12 the read
half, classCallNoLink12 an implicit-this call to a not-yet-emitted method with
the t8 three-way split, classArgBind12 user call arguments bind incl. oob
methods) + the comments that cite the witnesses (staticScopedCall12: t1-t3;
classCallNoLink12: t6 bm/xm, t8; classArgBind12: t10 t11); case text: t =
sub::getv/settv static calls, t3 = base::sv read + base::sf call, t7/t9 = the
late-declared method twins of t8, t12 = the oob-method argument binds

### r10uvm13repro

source: README table row t15: a WRITTEN p1::PE* read from a class-in-package
method, "byte-identical on the fold" = the class-qualified fold half
pkgClassEnumFold13

### r10uvm14repro

source: README table: t (= the t18 UVM_MS_IMP_COMMON condition shape, per its
header) " invalidChild14 lands ALL of them"; t19 (uvm_pair dotted calls) is
measured with droppedCall14's emitted shapes ("t17 + t19")

### r10uvm15repro

source: README table row t22: " localClassTsUnnamed15 lands all six" (the over-
fire check)

### r10uvm17repro

source: README table row t29: " outArgLvalue17 — FIXED"

### r10uvm20repro

source: README t31 controls + law text: the function-local / task-local cells
are foreachLocalArrayVar20 ("the fone cell falls out"), the formal-array cells
are foreachAssocIdxLocalOnly20 ("t31 shows a FORMAL drills to the element")

### r10uvm21repro

source: README purpose-built matrix t32a..t32g + each case header: t (= t32a, no
import, the import-position control) and t32b_t (module-scope import) are cases
of the $unit-import gate classPropUnitImport21 and its array_var mint
foreachClassPropArrayVar21; t32g_t (= t32f's this./other. spellings with no
import, "resolves all eight") is the control for foreachHierPathAlwaysRes21 and
classPropIterThisRefVar21 ("t32f and t32g loop-variable censuses byte-identical
to golden") and for the gate

### r10uvm22repro

source: README: t33d/t33e are "the shadowing-formal and string-property pair"
(foreachShadowFormalWins22 + foreachClassPropStringVar22); t33e pins the string
property directly

### r10uvm27repro

source: t37a header (out-of-body constructor with no port list whose super.new()
golden DROPS) = README law 1 constructorBodyElementShift27 ("a constructor that
declares no port list loses its FIRST BODY ELEMENT")

### r10uvm49repro

MEASUREMENT-ONLY pass (README title): no production law; its cases decode a
residue ( ifaceDupSharesHomePorts is a reference). No law to write

Left without a LAW file (5): `a2` `a3` `a4` `a5` `a6`

### r10uvm60repro

source: README "ONE law landed — tfBodyConstArgNoFormalTs60 with its predicate
tfBodyConstArgNeedsEvaldBody60" + the verifier cases' headers: v2_class /
v5_class2 hunt the predicate's scope x reachability product (class static method
in the evaluated set), v7_macroesc the macro / escaped-name axes of the stamp;
each is one stamp decided by the one predicate

### r10uvm77repro

source: the verifier cases' headers: x1 the parens-less `with` clause cell, x2
"THE PROBE'S DECLARED BLIND SPOT" - both attack the parens probe
(parensProbeIsTheGate77) that decides the ref_obj step
(classMethodParensLessStepIsRefObj77)

### r10uvm80repro

source: README title law blockDeclAutomaticIsWrittenKw80 + the verifier cases'
headers (edge shapes where "ONE keyword must reach TWO different factories"; the
fork/no-initialiser SITE 4 stamp)

### r10uvm8repro

NO README; UVM pass 8 commit 64f49223 lands LAW Q / LAW E / LAW LV, unnamed (q1
= the assoc-formal decode, q3 = LAW LV foreach four-way). laws named WITHOUT a
pass number, outside the index grammar (a law is ` <name><pass number>`); the
law is determined but a LAW file would name no index law. Fix = give the law its
number at its sites/README, then stamp

Left without a LAW file (2): `q1` `q3`

### r10v119repro

source: README title (verifies r10uvm119) + each case's header: D/G/H/I/J/K/L are
member randomize-with shapes (constraint content, macro form, references,
composition, receivers, package reach, names) =
memberRandomizeWithIsRecvPath119; none writes the randomize(null) surface of
memberRandNullDropsArgsAndWith119

### r10v134repro

source: README title (verifies r10uvm134 foreachLoopListStopsAtFirstSelect134) +
v134 grid 4 header: body shapes under one fixed loop-list shape; the 134v write-
too clause is a loop-list truncation fence this grid holds fixed

### r10v146repro

source: README section 2 (verifies r10uvm146 unitImportHoistsPkgParams146, the
$unit-import hoist of package parameters) + each case's header: v05 a second
package (README row "listing == golden IN ORDER"), v11 imported but never
referenced / a package with no parameters, v15 two files with their own $unit
imports - all hoist-listing cases of the law; the verifier's 146v fixes are
exercised by v08/v33/v35

### r10v151repro

NO README. VERIFIED.md: adversarial verification of r10uvm151
stmtBuiltinBodyIsBareRecvCall151 (single law); every v151_* case attacks it

### r10v182repro

NO README. VERIFIED.r10v182.txt: adversarial verification of r10uvm182
builtinArrayReadBindsMintedFuncCall182 (single law)

### r10v199repro

source: README (verifies r10uvm199 impUnsizedBasedLhsNoTs199) + its Files row
"13 cases: c one-copy body import, d interface + program, f three copies, g uvm
shape": each is an unsized-based import-copy LHS case of that law; the verifier
fix parenCastWidthLhsKeepsTs199v is exercised only by v199_l_castw/v199_m_ctl,
and implicitUnsizedBasedNoTs102 is pass 102's law, cited

### r10v64repro

source: README (verifies r10earl64) + v7_inst64 header: "THREE instances with
DIFFERENT overrides (the per-instance copy the law claims)" =
elabCaPortParamPaCopy64

### r10v79repro

source: README: the fix dimExprLeafBoundInit79v closes the shadowed/unresolvable
override-name leaf of dimExprBoundFold79, cases "a shadow (va6, va8, va9) or an
unresolvable one (va5)"

### r10v96repro

NO README. VERIFY.r10uvm96.txt: adversarial verification of r10uvm96
castTargetKeywordTypespecKind96 (that pass's single law); v96_a4_operands is one
of its case files

### r10v97repro

source: README (verifies r10uvm97 classNestedTdOneObjectPerSurelogTypedef97; its
re-cut classNestedTdDupCopiesFollowTheirDeclaration97v rewrites the same dedup
block: distinct-pair count + skip only the BASE's copies) + the Files list:
c1/c4 the regression cases of the re-cut, c2 the base-duplicate mirror, c3 two
typedefs, c8 specialization counts, c9 the package-anchored group - each
exercises the one dedup decision both laws make

### r10vearl99repro

source: v99_enum header: an ENUM-CONSTANT member value in a pattern reached by
the landed direct carrier and the NEW ternary carrier
caTernaryArmPatternFlatten99; the enum decompile fence is
patFlatEnumDecompileRenderV99

### r10vrgg11repro

source: README section 4 (the V4 hand-written cells of the verification of
r10rgg11 genLpPortConnValue11: instance counts, genvars, hierarchical/outer
reads, interface gen scope, defparam, sharing; the byte-still ones are the law's
own controls) + PORTTABLE_V4_special.txt; nonlit_init is the non-literal-
initializer (fold-arm) cell of the verifier's fix genLpPortConnCopyableOnly11v

### r10vrgg17repro

NO README. Pass verified: r10rgg17repro (single law hpConnElemIdxFold17); v8 =
OUTPUT/INOUT hier_path port actuals, the law's own face (case header)

### r10vrgg3repro

verifier of r10rgg3: portViewRangeRecvParams, ifaceArrayElemViewFoldsDefault,
defPortsNullDefInstGuard (commit 0129e437). laws named WITHOUT a pass number,
outside the index grammar (a law is ` <name><pass number>`); the law is
determined but a LAW file would name no index law. Fix = give the law its number
at its sites/README, then stamp

Left without a LAW file (24): `v13_recv_clog2` `v1_recv_aw_zero`
`v3_recv_aw_huge` `v5_iface_gen_depends_on_aw` `v7_iface_assert_range`
`v9_recv_aw_intmax` `x1_mixed_override_arr` `x2_named_only_override_single`
`x3_plain_positional_single` `x7_two_recvs_diff_aw`
`x8_same_recv_two_insts_diff_ovr` `x9_nested_iface_port`
`xb_module_array_contrast` `xc_recv_localparam_only` `xg_iface_untyped_param`
`xk_iface_no_default_param` `xl_deep_transitive` `y1_elem_index_recvp`
`y2_modport_used` `y3_recv_bw_only` `z1_single_genfor_named`
`z5_textmulti_arr_norecvp` `z6_gen_arr_norecvp` `z9_multiparam_arr_valdiff`

### r10vrgg4repro

NO README. Pass verified: r10rgg4repro (RGG4_SCORE.reproduced.txt,
BOUNDARY_vrgg3.txt; r10rgg4 owns the single law sizeDimOvrChain4).
gen_vgrid.py/gen_vgrid2.py: v5* = "the NON-overridden typespec gate (the pass
NARROWED it: only plain int)"; gen_vgrid3.py: w3/w6/w7 = non-interface sites
sized by the overridden parameter (the law's reach controls)

### r10vrgg9repro

source: README (verifies r10rgg9 srlgCondOpInstValueTernFold9; the fix
srlgCondOpSysFuncEvalable9 guards every value taken through a system call, the
closed whitelist $clog2 $bits $size $high $low $left $right). Every cell
exercises the ternary fold; a cell whose conditional cont_assign holds a system
call is also a case of the sys-func fence (cells3/cells4 grids and
v_takn/v_untk_syscall)

### r10yos1repro

dottedTopNameBareElab. laws named WITHOUT a pass number, outside the index
grammar (a law is ` <name><pass number>`); the law is determined but a LAW file
would name no index law. Fix = give the law its number at its sites/README, then
stamp

Left without a LAW file (5): `v3_bind_outside` `v4_dotted_top_plus_iface`
`w11_rich` `w12_bind` `w17_hierref`

### r11u101repro

source: README section 3 grid table: an case is LAW A
caNestedModPortedDefShell101 when R11U101_NESTPORT_OFF (A-off) changes its cmp
count, LAW B caNestedModDefKeyScoped101 when R11U101_NESTKEY_OFF (B-off) does;
the four CONTROL rows (x06 x07 x23 x24, no switch moves them) are LAW A's
controls (ported nested / depth-2 / implicit and file-scope roads)

### r11u103repro

source: README grid table + switch table: a* = LAW A
caNestedModFileScopeKeyAtEntry103 (FILEKEY / FILEKEY_DEFONLY switches; a01/a07
unmoved controls), b*_F / c*_NI / d*_NP = LAW B caUnelabBodyChildPorts103 roads
F / NI / NP (b07, c04 the also-elaborated controls); a16 "LAW A x road F" and
e01 "LAW A x road NI" carry both

### r11u105repro

source: evidence/SWITCHES105.txt (the cases each switch returns: tkof
R11U105_TOPKEY_OFF = LAW A caTopNamesakeKeyAtEntry105, pkof/piof = LAW B
caProgramNamesakeKeyAtEntry105, ikof = LAW C caIfaceNamesakeKeyAtEntry105; k39
moves under both A and B); the unmoved controls take the face letter in their
name (README grid table controls row), k42 being LAW B INST k40's control

### r11u107repro

source: README "The three laws" (Law 1 anonPackedAggDimTs107 = grid a* anonymous
packed aggregate cases, Law 2 typeParamAnonAggDefault107 = t* type-parameter
default cases, Law 3 tpElemRebindDefView107 = o* override-element cases incl. the
o06 no-default control) + evidence/GRID107.txt; grid u* = "Face 2 is FENCED"
(probe never shipped, GRID107 law = pristine on every u case) -> UNRESOLVED

Left without a LAW file (3): `grid/u01_top_tp_pkg_unp`
`grid/u02_top_tp_chain_unp` `grid/u05_top_tp_lit_unp`

### r11u108repro

source: README Q2/Q3 + evidence/GRIDS.txt: grid/f5 = FACE 5
tpPackedArrayTsVar108 (all cases incl. controls). grid/f4 (FACE 4) and grid/pk
(FACES 1 and 3) are STOPPED AT THE DECODE (sites fenced): no law of this pass,
every case SAME law-vs-pristine in GRIDS.txt -> UNRESOLVED (face 4 landed later
as modFnLocalTdCastClone112/modFnLocalTdRetClone112 in r11u112)

Left without a LAW file (39): `grid/f4/c01_modfunc_cast`
`grid/f4/c02_modfunc_ret` `grid/f4/c03_modfunc_ret_cast`
`grid/f4/c04_modscope_cast` `grid/f4/c05_always_cast` `grid/f4/c06_modtask_cast`
`grid/f4/c07_unsigned_td` `grid/f4/c08_bit_td` `grid/f4/c09_int_td`
`grid/f4/c10_struct_td` `grid/f4/c11_twocasts` `grid/f4/c12_const_fold`
`grid/pk/k01_param_v` `grid/pk/k02_param_vn` `grid/pk/k03_param_vn_default`
`grid/pk/k05_param_a` `grid/pk/k07_port_vn` `grid/pk/k08_var_vn`
`grid/pk/k09_member_v_toppar` `grid/pk/k10_member_v_pkgparam`
`grid/pk/k10b_member_child_sel` `grid/pk/k10c_member_widthparam`
`grid/pk/k10d_member_child_nosel` `grid/pk/k10e_member_child_sel_q`
`grid/pk/k10f_member_bodyimport` `grid/pk/k10g_member_bodyimport_child`
`grid/pk/k10h_noassign` `grid/pk/k10i_noassign_nochild` `grid/pk/k10j_wide`
`grid/pk/k10k_w32` `grid/pk/k10l_w33` `grid/pk/k11_member_v_qualified`
`grid/pk/k17_func_in_pkg` `grid/pk/k20_cfg_func_width`
`grid/pk/k21_param_vn_nofunc` `grid/pk/k22_param_v_literal`
`grid/pk/k23_lv2s_copy` `grid/pk/k23c_samekey` `grid/pk/k23d_nowidth`

### r11u109repro

source: evidence/DROPS109.txt per-switch movers (switch->law from the README
drops table: face-1 case B / case C sub-laws, face-2 c01-c06
STAMPTYPE+PKGCALLFLAT, f5 ANONNET, hp HPVS); unmoved cases are the face controls
of their dir (README grid section: f1 = face 1, f5 = face 5, hp = the hier_path
face)

### r11u10repro

unpackedStructArrPatOneElemFold / unpackedStructArrPatElabTs. laws named WITHOUT
a pass number, outside the index grammar (a law is ` <name><pass number>`); the
law is determined but a LAW file would name no index law. Fix = give the law its
number at its sites/README, then stamp

Left without a LAW file (2): `grid/h9_1e1m_port` `grid/hD_1e1mvec`

### r11u110repro

source: evidence/SWITCH.txt (every moved case is owned by exactly one switch:
sport PORT, sinit INIT, sreg ELEMREG, sattr ATTR, smulti PKGTDMULTI -> the
README Q4 law table); unmoved cases: grid/e1 = the law-1 override x default grid
(tpElemRebindElabPort110 controls), grid/f2 unmoved cases by their face-2 kind in
the name (init / unpacked / attr)

### r11u111repro

source: evidence/SWITCH.txt (sw111.sh per-arm kill-switch table: an case restored
to pristine by R11U111_F<n>_OFF is that face's law; the 10 cases only R11U111_OFF
restores carry both F1 and F3, README Q4); SAME cases are their dir face's
controls (README Q3: f1 F1, f2 F2, f3 F3, f5 F5); grid/f4 = FACE 4 STOPPED AT
THE DECODE (site fenced, no law) -> UNRESOLVED

Left without a LAW file (1): `grid/f4/d02_plain_pos_dep`

### r11u112repro

source: evidence/DROPS112.txt per-switch movers (switch->law from the README
drops table); f/r* range-bound cases = the fenced R1b face (decode only, no law
of this pass; landed later as typedPkgBoundElabSize113 in r11u113) ->
UNRESOLVED; unmoved cases take their dir face from the README grid table (p=FACE
5, t=FACE 2 both laws, k=FACE 3, v=FACE 4, f/f*=caSelIdxOpFoldTs112,
f/g*=genLpIdxOpOperandFold112)

Left without a LAW file (9): `grid/f/r01_rng_unp` `grid/f/r02_rng_plain`
`grid/f/r03_rng_sub_unp` `grid/f/r04_rng_int_unp` `grid/f/r05_rng_modparam_unp`
`grid/f/r06_rng_untyped_unp` `grid/f/r07_rng_port_unp`
`grid/f/r08_rng_unp_param_n` `grid/f/r09_rng_lo_param_unp`

### r11u113repro

source: README grid table + drops table (grid/b RBND, c TPCAST, e ENUM, q
REPRNG; grid/v: evidence/DROPS113.txt VSIDX_OFF moves v01-v11 var_select cases,
GSBS_OFF v13-v18 bit_select cases; v07 var_select always_comb control, v12 module
bit_select control per mkgrid113.py)

### r11u115repro

source: evidence/DROPS115.txt (per-switch movers, switch->law from the README
drops table); unmoved controls take the law of their grid dir face (README grid
table)

### r11u116repro

source: README grid table (grid/f1 = FACE 1, grid/f2 = FACE 2, grid/f3 r1_* =
FACE 3 R1, r3_* = FACE 3 R3) + the switch table; evidence/SWITCH_grid.txt
confirms each face switch reverts only its own dir

### r11u117repro

source: README Q3 measured rules + Q4 laws/fences + evidence/DROPS117.txt: g13
(dead generate), g18 (never read, CONTROL) and t05 (a member > 64 bits, L1's
Bits fence) are pkgQualSelParamFlat117's tagged controls; t03 is moved by
R11U117_BITS_OFF (pkgFlatSurelogBits117); t12 is L1's function-body CONTROL and
moved by BITS_OFF (both). grid/g3 = "face-3 R5, not landed" (README) -> g3/r04
UNRESOLVED

Left without a LAW file (1): `grid/g3/r04`

### r11u11repro

memSelAsmBaseOv (with structParamMemberOvBinary / elabOvRefIntConst context).
laws named WITHOUT a pass number, outside the index grammar (a law is `
<name><pass number>`); the law is determined but a LAW file would name no index
law. Fix = give the law its number at its sites/README, then stamp

Left without a LAW file (3): `a3` `a5` `a8`

### r11u13repro

asmEncFollowsRef (with pkgStructFuncAssembleBin family). laws named WITHOUT a
pass number, outside the index grammar (a law is ` <name><pass number>`); the
law is determined but a LAW file would name no index law. Fix = give the law its
number at its sites/README, then stamp

Left without a LAW file (2): `b3` `b6`

### r11u14repro

modEvalFuncLeftoverEnc (9 source sites). laws named WITHOUT a pass number,
outside the index grammar (a law is ` <name><pass number>`); the law is
determined but a LAW file would name no index law. Fix = give the law its number
at its sites/README, then stamp

Left without a LAW file (6): `c10` `c3` `c4` `c5` `c6` `c8`

### r11u15repro

README LAW A/LAW B unnamed; source/commit 76c8a58b:
genCaDrivenOpenerIsGenLocalOnly (r11u15) = grid b* (LAW A axes),
wholeWriteIsNotTheDiscriminatorForANET (r11u15) = grid a* (LAW B axes). laws
named WITHOUT a pass number, outside the index grammar (a law is ` <name><pass
number>`); the law is determined but a LAW file would name no index law. Fix =
give the law its number at its sites/README, then stamp

Left without a LAW file (40): `grid/a01_blk_partsel_shadow`
`grid/a02_blk_no_partsel` `grid/a03_unnamed_blk_partsel`
`grid/a04_blk_bitsel_shadow` `grid/a05_blk_partsel_var_only_before`
`grid/a06_blk_partsel_after_only` `grid/a07_blk_partsel_rhs_only`
`grid/a08_blk_partsel_two_names` `grid/a09_blk_partsel_var_notnet`
`grid/a11_partsel_on_output_port` `grid/a12_two_selects`
`grid/a13_select_in_case_item` `grid/a14_wholewrite_reads_self`
`grid/a15_nonansi_reg_one_select` `grid/a16_nonansi_reg_port_select`
`grid/a17_wholewrite_after_select` `grid/a18_two_whole_writes`
`grid/a19_also_read_at_module_level` `grid/a20_wholewrite_nested_select_outer`
`grid/a21_select_nested_wholewrite_outer` `grid/a22_indexed_partsel_wholewrite`
`grid/b01_genif_rhs_modvar` `grid/b02_genif_rhs_modwire`
`grid/b03_genif_rhs_modport` `grid/b04_genif_rhs_genlocal`
`grid/b05_genif_rhs_operation` `grid/b06_genif_rhs_partsel`
`grid/b07_genif_rhs_modlocalparam` `grid/b08_genif_rhs_modarray`
`grid/b09_modlevel_rhs_modvar` `grid/b10_genfor_rhs_modvar`
`grid/b11_gennest_rhs_modvar` `grid/b12_genif_lhs_modvar_rhs_const`
`grid/b13_genif_rhs_modvar_procdriven` `grid/b14_genif_rhs_two_bare`
`grid/b17_gennest_ancestor_local` `grid/b18_genif_modwire_driven_in_blk`
`grid/b19_genif_modvar_procdriven_in_blk` `grid/b20_genif_modvar_driven_rhs_op`
`grid/b22_genif_modport_driven_in_blk`

### r11u17repro

source: README section 3: LAW 2 axes table (c* cases) =
genCaBoundLhsOperationRhsUnbindsRhs17, LAW 1 axes table (d* cases + c20) =
genCaLhsArrayNetNeverBinds17; c20 is the case that "proves the two laws mutually
exclusive in one file" (both). The 5 e-arms are "R1's residue and byte-unchanged
by design" (an unbased-unsized ternary branch encoding, no law of this pass) ->
UNRESOLVED

Left without a LAW file (4): `grid/e01_tern_1bit_sized0`
`grid/e03_tern_32bit_sized0` `grid/e04_tern_1bit_unsized0`
`grid/e05_tern_32bit_unsized0_truesimple`

### r11u19repro

source: README section 3: LAW 1 axes table (p/q/r/s/t cases, assignment pattern
on a logic target) = genCaPackedPatternFold19; LAW 2 axes table (e/f cases, the
ternary fill case) = caTernFillArmKeepsEncoding19

### r11u1repro

ifacePortViewParamAssignsOnly. laws named WITHOUT a pass number, outside the
index grammar (a law is ` <name><pass number>`); the law is determined but a LAW
file would name no index law. Fix = give the law its number at its sites/README,
then stamp

Left without a LAW file (1): `grid2`

### r11u22repro

source: README section 2-3 + landing commit 5346c1e9: the pass lands ONE law,
genCaTernaryFoldGenScope22; every grid case (scope / case kind / Lhs kind tables)
is its case or gate control. elabCaTernaryFoldIntConst22 is Earlgrey pass 92's
module-scope law (commit 5c6cea7c) that the README only references; only a02
(the MODULE-SCOPE twin) exercises it too

### r11u23repro

source: mkgrid23.py section banners (A re-measure of r11u22 R0 + witness, B FACE
A the Lhs vpiActual, C FACE B the fold outcomes, D scopes, E condition/operand
gate, F the clone, G fill mints, H the concat fence) mapped to the README laws
(B,F=genCaUnboundTernLhsNoActual23; A,C,D,E,G=genCaUnboundTernFold23;
H=genCaUnboundTernConcatFence23); README lists a11/e01/e02/e04 under the clone
and c06/c11/c26 under the concat fence FOLD set

### r11u27repro

README names no law with , but its section 3 names the machine `caFoldEnc27` and
the landing commit d24291a2 ("v1.87 pass 27", evidence tools/probe/r11u27repro/)
lands caFoldEnc27; the source sites name the same law caNonTernFoldEnc27
(r11u27). One law under the commit's and the source's two spellings, so each
case lists both; every grid case (mkgrid27.py / mkgrid27b.py: operand ladder x
Lhs home x scope x width x parameter ladder x over-64 x operators) is an case or
a control of it

### r11u32repro

source: README section 5: k9.sv / k9b.sv are the two purpose-built goldens of
typeParamArgNetNeedsNonAnsi32 (the NON-ANSI header gate)

### r11u39repro

README title law hpCompMultiSelElemShape. laws named WITHOUT a pass number,
outside the index grammar (a law is ` <name><pass number>`); the law is
determined but a LAW file would name no index law. Fix = give the law its number
at its sites/README, then stamp

Left without a LAW file (1): `a1`

### r11u3repro

structParamMemberOvBinary. laws named WITHOUT a pass number, outside the index
grammar (a law is ` <name><pass number>`); the law is determined but a LAW file
would name no index law. Fix = give the law its number at its sites/README, then
stamp

Left without a LAW file (2): `g1` `g2`

### r11u48repro

source: README section 4: h1-h18 "the folded range bound" =
foldedBoundTsIsTheSignednessCapture48 (the TypeEmit bound site), g1-g22 "the
call argument" = callArgSubroutineLocalOffRetExprNoTs48 (the ExprEmit call-
argument stamp)

### r11u51repro

MEASUREMENT-ONLY census pass (README title): no law landed. No law to write

Left without a LAW file (4): `grid/b3_leafsubst_ca` `grid/e1_ca_rhskind`
`grid/va1_bits_signal` `grid/vb2_concat_bound`

### r11u52vrepro

source: README title (verifies ROAD C bodyTypedefElemBoundSymbolic52) + section
4 break table (b2 bound forms, b4 program-body typedef, b6 macro expansions all
exercise that law)

### r11u5repro

README title "NO LAW LANDED" (the IBEX family re-measured and decoded). No law
to write

Left without a LAW file (1): `g2`

### r11u70repro

source: README section 2 grid table + section 3 (THE LAW =
castNamedPatternConcat70, source comments name r11u70): c1 the corpus shape, c13
the uncast twin fence control

### r11u75repro

source: README section 3a "g1_netkinds — NET KINDS x SCOPES (LAW A)" =
caGenScopeNetNamesakeStore75; w8_unitname's head is the width half and its
binding half of caNamesakePkgImportHome75 (LAW B; the IMPBIND/IMPW switch rows)

### r11u79repro

source: README 3f + z6 header: "uhdm-cmp returns 0 exactly when LAWS A/B/C are
all three right"

### r11u88repro

source: README 3b LAW B table: z3_stronly / z4_dlyonly are "the control" of
caStrengthAndDelayDeclined88. The other unresolved cases (a1 a5 a6 c2 i1 i4 i5 i6
vf x6 y1 y2 y6) are listed in 3d "THE PASS-82/83/85-FAMILY CONTROLS", byte-
identical between the two binaries and NONE=0 in the switch ledger: carried
controls of earlier passes' laws, not of this pass's -> UNRESOLVED

Left without a LAW file (13): `grid/a1_cadrive` `grid/a5_ifliteral`
`grid/a6_commadrive` `grid/c2_kinds` `grid/i1_ifkinds` `grid/i4_portview`
`grid/i5_twoinst` `grid/i6_ifarray` `grid/vf_collide` `grid/x6_ifdefcast`
`grid/y1_pkgnetkind` `grid/y2_pkgvarkind` `grid/y6_hoistconv`

### r11u90repro

source: README section 3 tables: 3a LAW A caNetDeclStrengthDropped90 = strength-
decorated net declaration cases (the verifier's vx*_str* cases), 3b LAW B
caDelayParamRefSpelling90 = delay-as-parameter-name cases (vy*_dly* and the
#3/#1.5 control w11_dlyctl)

### r11u93repro

source: README section 4 grid tables: 4a LAW A caProgramGenFlattens93 = p1-p9
(r11u92 program controls), pa* (pa15/pa16 its module/interface-home controls);
4b LAW B caIfacePortDeclNetMint93 = pb* and the pass-90/92 module-home controls
n*, m1, i1

### r11u98repro

source: README section 4 grid tables: 4a LAW A caClassListNameKeyed98 (g1 g2
g4-g8; g3 is the interface home whose order is the design root's = LAW B2; h5 is
LAW A across the module body and its generate block = LAW A + B1), 4b LAW B1
caModGenBlockClassIsModuleOwn98 (h1 h6 h7 h8) and LAW B2
caIfaceClassIsDesignRoot98 (h2 h3 h9), 4c LAW B3 caDefGenBlockKeepsFinal98 (h4 +
its controls h10 h11)

### r11u99repro

source: README law statements (A1/A2 the interface class root, B1-B6 the nested-
module rules) + section 3 grid tables and the census seed lines (#SEED:w11 LAWB-
NESTDEF, LAWB2-NESTINST, LAWB2-NESTREF, LAWB3-NESTCLASS): w05 = LAW A's simple-
interface CONTROL; every converted one-level nested def view carries the scoped
name B1 and the outer parent B6, plus B2 (no implicit ref/inst) and B3 where it
declares classes; w13 = "B2 must NOT fire; B5 must"; w14 = B4; w21 = B4 + B5;
w19 = the file-scope namesake face of B1; w20 = B2's real-ref_module CONTROL.
w23/w24 (nested module WITH a port / parameter) are 8 residues no law of this
pass reaches (landed later as caNestedModPortedDefShell101) -> UNRESOLVED

Left without a LAW file (2): `grid/w23_modinnerport` `grid/w24_modinnerparam`

### r11v105repro

source: README case table (verifies r11u105) + the LAW letter in each case name
(_A_ top namesake LAW A, _B_ program namesake LAW B, _C_ interface namesake LAW
C, _ABC_ = v16 "A+B+C together"); controls v03/v20/v23 are LAW A's no-collision
/ declared-first controls

### r11v11u5repro

verifier of r11u5, which landed no law. No law to write

Left without a LAW file (1): `d1`

### r11v11u9repro

verifier of r11u9 pkgStructFuncAssembleBin (+ modStructFuncAssembleBin,
pkgStructFuncAssembleBinBail). laws named WITHOUT a pass number, outside the
index grammar (a law is ` <name><pass number>`); the law is determined but a LAW
file would name no index law. Fix = give the law its number at its sites/README,
then stamp

Left without a LAW file (3): `g13` `g3` `g7`

### r11v16repro

verifier of r11u16 caAsmMemberSliceFold. laws named WITHOUT a pass number,
outside the index grammar (a law is ` <name><pass number>`); the law is
determined but a LAW file would name no index law. Fix = give the law its number
at its sites/README, then stamp

Left without a LAW file (9): `v1` `v10` `v13` `v1b` `v1c` `v1d` `v2` `v4` `v8`

### r11v17repro

source: README section 2 (the fix sysCallCastArgKeepsBind17v re-enables a cast-
operand bind that LAW 2 narrowed; its table rows are the w* $system-argument
cases, each also a LAW 2 cell) + section 3 axes: the array-net / array-var /
struct-net Lhs cases (va11 va12 va13 va19 va20 va22) are LAW 1
genCaLhsArrayNetNeverBinds17, the bound-Lhs operation-Rhs cases (va03-va10, va21)
LAW 2 genCaBoundLhsOperationRhsUnbindsRhs17

### r11v1repro

verifier of r11u1 ifacePortViewParamAssignsOnly. laws named WITHOUT a pass
number, outside the index grammar (a law is ` <name><pass number>`); the law is
determined but a LAW file would name no index law. Fix = give the law its number
at its sites/README, then stamp

Left without a LAW file (3): `vA` `vE` `vL`

### r11v22repro

source: README sections 2 and 4 + ADV.r11v22.txt: the verifier amendment
genTernCondSameMachine22 moves ONLY v01/v02; every other unresolved adv case
converts pris->law under the implementer's law genCaTernaryFoldGenScope22 and is
identical on the two law binaries

### r11v23repro

source: README section 2 (the concat fence amendment and the
caLhsUnboundOwnLocal23 namesake decline) + section 3 face list + ADV.r11v23.txt;
concat/replication operand cases (v10-v14, w*, x01-x11 whose Rhs holds a concat)
= genCaUnboundTernConcatFence23, their non-concat width controls =
genCaUnboundTernFold23; Lhs namesake cases v20-v24 and the unsized-untaken clone
cases v51/v52 = genCaUnboundTernLhsNoActual23; value machine, fills, scopes,
targets = genCaUnboundTernFold23

### r11v26repro

source: README sections 2-3 (verifies r11u26) against the r11u26 README laws (A
the leftover patParamLeftoverShare26, B the flatten trigger
patParamEvalFuncRead26): v12 v13 v15 v16 v18 are the FLAT rows of the element
table that settle the verifier gate patParamPatElem26v (+ B); v2 = two members
from the same pattern parameter (A + B); v9 = selectivity of the trigger (B)

### r11v32repro

source: README (verifies r11u32; the fix typeParamArrayVarIsFourState32v gates
law B namedTypePackedDimElabVar32 on a 4-state leaf) + the cases' text:
w1_regression_witness = the named 2-state regression witness (both), h02 = a
4-state logic type parameter with a packed dim in always_ff (law B, the fence's
passing side), h03 = an enum-leaf named type with a packed dim
(namedTypeLeafNoNetType32's enum leaf)

### r11v45repro

source: README (verifies r11u45 typeParamChainBorrow45; the fix
typeParamChainBorrowShadow45v refuses a borrow shadowed by a same-NAME typedef)
+ each case's header: v2 non-ANSI chain, v9 struct-typedef source in a generate,
v12 chain in a gen-for instance, v16 per-list record isolation = the borrow law;
v18 "no shadow, but a typedef ELSEWHERE with the same canonical type" = the
borrow law and the shadow fence's name-not-structure control

### r11v48repro

source: README sections 2-4 + each case's header comment: va*/vc* are call-
argument cases (a body local / formal / module variable passed as an argument) =
callArgSubroutineLocalOffRetExprNoTs48; vb*/vd* are range-bound signedness cases
(localparam/parameter bound, 2x2 override, imported, expression bound) =
foldedBoundTsIsTheSignednessCapture48

### r11v4repro

verifier of r11u4 ifacePortViewPaFoldsDeclDefault. laws named WITHOUT a pass
number, outside the index grammar (a law is ` <name><pass number>`); the law is
determined but a LAW file would name no index law. Fix = give the law its number
at its sites/README, then stamp

Left without a LAW file (2): `v5` `v6`

### r11v53repro

source: README section 2 break table (verifies r11u53
bitsTypeParamArgNeverFolds53, the $bits-of-a-type-parameter road):
x1/x9/x10/x11/x15 are the imported-type-shadows-the-type-parameter cases the
verifier gate importedTypeShadowsTypeParam53 fixes, each a $bits read of the
type parameter (both laws)

### r11v70repro

source: README title (verifies r11u70 castNamedPatternConcat70) + section 2
"Everything else the law claims held" (v3 v5 v6 v9 v11 v16) and
evidence/GRID.v11v70.txt (v2 the corpus shape + member select); none of these
cases is on a 70v fence (those are v1 v15 v17-v21)

### r11v74repro

source: README section 2-3 (verifies r11u74): v1_nearest, v2_kindns, v3_order,
v5_inst, v9_hops are all LAW B cases (the gen-scope Lhs namesake bind,
caGenScopeLhsNamesakeBind74: climb / kinds / order / instances / hop count); LAW
A caAsmMemberSliceFoldGenScope74's cases are v7/v8

### r11v75repro

source: README (verifies r11u75) case list: xj_twoinst "LAW A across two
instances" = caGenScopeNetNamesakeStore75; xl_impclimb "LAW B's width half ...
ON THE CLIMB" and xe_impkind "the import home BY KIND" =
caNamesakePkgImportHome75

### r11v77repro

source: each case's own header ("LAW B face" for va_netstructkinds and
vd_structmem, the interface road where "LAW A splices package NETS into that
listing" for ve_ifacenet) with the r11u77 README letters: LAW A
caImportedPkgNetHoist77 (PKGNET), LAW B caImportedPkgHoistKindTable77
(HOISTKIND)

### r11v83repro

source: README section 2 (verifies r11u83: LAW A caIfaceImportedPkgHoist83 the
imported-package holder hoist, LAW B caIfaceBodyCaFolds83 the interface
cont_assign fold): b2_mpexpr (a modport expression port fed by the hoist's
netMap), b12_ifarr (an interface array) and b17_topiface (a top-level interface,
0 hoist entries: the hoist's control) are LAW A cases; b18_xmember is "LAW B's
DECLINE path on an X-valued member"

### r11v88repro

source: README section 2 (verifies r11u88) + case names: the *shadow cases are LAW
C caIfaceNdaNameFoldsToParamValue88 (the fixed name-resolution break v2/v26, its
module-home control v25, v1 pkgshadow); the *_both* cases are LAW B
caStrengthAndDelayDeclined88 (v11a, v21); the *_nda* cases are LAW A
caIfaceElabNetDeclAssignListing88 net-decl-assign homes/shapes (v5_ndastrdly =
the strength-decorated declaration LAW A declines)

### r11v93repro

source: README section 3 verifier grid: v*_if* cases break LAW B
caIfacePortDeclNetMint93, v*_prog* cases and the module-home control
v14_modgeninit break LAW A caProgramGenFlattens93

### r11v95repro

source: README (verifies r11u95; the three 95V fences sit inside LAW A's gates)
+ r11u95 README law statements, matched on each case's own text: every program-
generate case (and the module-home controls x15/x18) is LAW A
caProgramGenFlattensEveryKind95; a zero-iteration loop case (forzero / zeroloop)
is also LAW B caGenLoopZeroIterStillWritten95; a program case declaring a task or
function is also caProgTaskFuncInstIsElab95 (the program task_func instance
stamp)

### r11v96repro

source: README + v6 header: does the package-parameter mint of * / %
(pkgParamMulDivModIsIntReduce96) reach a module localparam / port / override /
$unit home

### r11vu13repro

verifier of r11u13 asmEncFollowsRef. laws named WITHOUT a pass number, outside
the index grammar (a law is ` <name><pass number>`); the law is determined but a
LAW file would name no index law. Fix = give the law its number at its
sites/README, then stamp

Left without a LAW file (3): `v2` `v4` `v9`

### r11vu15repro

verifier of r11u15 (commit 76c8a58b); its cases attack
genCaDrivenOpenerIsGenLocalOnly / wholeWriteIsNotTheDiscriminatorForANET. laws
named WITHOUT a pass number, outside the index grammar (a law is ` <name><pass
number>`); the law is determined but a LAW file would name no index law. Fix =
give the law its number at its sites/README, then stamp

Left without a LAW file (22): `grid/v01_sel_in_forbody`
`grid/v02_sel_other_process` `grid/v03_wholeref_deeper_nested`
`grid/v04_func_local_fence` `grid/v05_struct_member_sel`
`grid/v06_param_bound_sel` `grid/v07_output_reg_modread`
`grid/v08_two_procs_both_whole` `grid/v09_sel_in_bare_for`
`grid/v11_genif_rhs_bitsel_modvar` `grid/v14_gencase_modvar`
`grid/v15_genif_implicit_local` `grid/v17_genif_genlocal_driven`
`grid/v18_genfor_genlocal_driven` `grid/v19_genif_modvar_driven_procblk`
`grid/v20_two_nets_both_sel` `grid/v21_inout_port_sel` `grid/v22_array_elem_sel`
`grid/v23_initial_block_sel` `grid/v26_genfor_nested_genif_local`
`grid/v30_func_local_namedblk` `grid/v31_task_local_namedblk`

### r11vu3repro

verifier of r11u3 structParamMemberOvBinary. laws named WITHOUT a pass number,
outside the index grammar (a law is ` <name><pass number>`); the law is
determined but a LAW file would name no index law. Fix = give the law its number
at its sites/README, then stamp

Left without a LAW file (6): `vA` `vB` `vD` `vE` `vK` `vL`

### v11u108repro

source: README title + defects table: brk/f5 = face 5 (tpPackedArrayTsVar108),
brk/f2 = face 2 (defPkgMemberTdOfNamedShares108)

### v11u110repro

source: evidence/SWITCH.txt switch owners (sport/sinit/sreg/sattr/smulti ->
r11u110 README Q4 laws) + README "Break cases": brk/v1 families a=port law,
b=initialisers, c=unpacked elements, d=attribute cell, e=multi-dim members;
v3/v4/v5/v6 (escaped name, middle modules, interface-parent control, the dims-
form family, the override-kind sweep, the chain control) are port-law
(tpElemRebindElabPort110) cases

### v11u111repro

NO README. Pass verified: r11u111repro (evidence/GATES.txt "verifier of
r11u111"; sw111v.sh drives the R11U111_F<n>_OFF switches). Source: the break-arm
dir brk/f<n> = r11u111 FACE n (evidence/BRK.txt "brk/<face>/<case>"), face->law
from the r11u111 README (f1 pkgTdQualParamCopiesListing111, f2
pkgRhsStructBareCopy111, f3 pkgTdOfNamedDimsListing111, f5
impCopyConcatUnbound111, f6 tpOvrNamedDimsDrop111)

### v11u112repro

source: evidence/DROPSV112.txt per-switch movers (the seven R11U112_* switches +
the verifier fences V11U112_ENUMFENCE_OFF = tpStructKindNet112's enum fence,
V11U112_PROPFENCE_OFF = propDeclDisableIffSkip112's operator fence); unmoved
cases take the face of their dir (p=5, t=2, k=3, v=4, f: b1*/f*
caSelIdxOpFoldTs112, g* genLpIdxOpOperandFold112); ctlg/t/t10_body_tp_struct =
r11u107's case the r11u112 README names as face 3

### v11u113repro

NO README. Pass verified: r11u113repro (dir name, drops113v.sh drives the
R11U113_* switches, mkbrk113v.py "face 1..5" comments = r11u113 README faces).
Source: evidence/DROPS.txt per-switch movers (switch->law from r11u113 README
drops table); unmoved cases take their face per the mkbrk113v.py face comments
(f1/a*=face 1, f2/t*=face 2, f3/e*=face 3, f4/r*=face 4, f5/v*=face 5
var_select)

### v11u114repro

source: README (verifies r11u114: FACE 1 pkgPatCatMemberFold114, FACE 2
imppCopyOpReadIsRef114 unqualified + pkgQualOpReadIsRef114 qualified, FACE 3
leakCopyOpNoTs114) + each case's header comment ("face-1 ...", "face-2 qualified
...", "face-2 [unqualified] ...", "verifier: enum leaf" = face 1); the e* cases
are the README's face-2 contexts (task e01, generate e03, casez e04, case inside
e05, explicit import e09, enum concat e12), unqualified or qualified by their
own read

### v11u115repro

source: mkbrk115v.py face comments (face 1 sys-arg / typed positions / 1c
var_select / 2 / 2b / 3) + README "Laws that held"; evidence/DROPS.txt per-
switch movers

### v11u116repro

source: evidence/SWITCH_arms.txt (the face switch that reverts each case; an case
reverting under only R11U116_OFF is unmoved) + the case family prefix (f1*=F1,
f2*/g2=F2, h1/r1=F3R1, k3/r3=F3R3), consistent on every moved case; unmoved cases
are controls of their family law

### v11u93b107repro

source: README title (verifies r11u107; the fix srcOrder107 is inside
tpElemRebindDefView107) + evidence/BRK.txt + the cases' text: brk/p* = anonymous
packed struct/union with dims in declaration homes (Law 1
anonPackedAggDimTs107), brk/q* = anonymous packed aggregate as a type-parameter
default (Law 2 typeParamAnonAggDefault107), brk/r* = the override-element
instance-order cases of Law 3 tpElemRebindDefView107

### v11u93repro

source: README title (verifies r11u101) + section 3 face list: the LAW B
variants are the rv2* cases (two outers declaring the same nested name, written /
generate / array / depth-2 / one-explicit / top-two) and the portless shadow b12
(a portless nested def losing the bare-name collision to a file-scope module);
every other case is a ported/parameterized nested shell face of LAW A (sibling
nesting, upward refs, face families, instance counts, tops, the ported shadow
b11)

### v11u94repro

source: README title (verifies r11u106) + b2 header: the struct-parameter member
read under each operator inside a struct localparam's member range =
structPatternOpTsBoundFold106 and its verifier fence evalIntOpOnly106v ("only
the always-INT-64 operators fold", comment names v11u94)
