# r11u302 — pass 302, expression/parameter ground: the EvalFunc-leftover family on module builders, the flat import copy, the cast-pattern tag keys

Pair A, refill after pass 300. Base 0c29ccd0 (pass 300). Production surface: src/ParamEmit.cpp, src/ExprEmit.cpp
and the new src/R302.h only (StmtEmit and EmitHelpers.h untouched). Pristine build md5
f050c791ecad49e641fde77e05aa7faa (equal to the main tree's build/slang-uhdm at the base); law build md5
68d848f44dcb2c30d51741e98e5e1f61. Both binaries were frozen (chmod 555) before any measurement; every
cmds.txt of both sweeps names its own binary (evidence/gates.txt).

## Verdict

- **EIGHT PROBE CONVERSIONS**, each predicted by name in the firing census frozen before the law sweep
  (evidence/predict.txt), uhdm-cmp 0 lines before and after; the fresh law-sweep rows:
  - `r11u13repro/b3,EQUAL,,equal` (was `differ:line(29)`) — § modFnLitLeftoverAtLiteral302
  - `r11u24repro/n4,EQUAL,,equal` (was `differ:line(17)`) — § modFnLitLeftoverAtLiteral302
  - `r11u24repro/n11,EQUAL,,equal` (was `differ:fullname(7)`) — § modFnLitLeftoverAtLiteral302 with § rootTdLeftoverStamp302
  - `r11u26repro/m4,EQUAL,,equal` (was `differ:fullname(39)`) — § modFnLitLeftoverAtLiteral302 with § modPatLeftoverCloneNoParent302
  - `r11u28repro/a2,EQUAL,,equal` (was `differ:fullname(39)`) — § modFnLitLeftoverAtLiteral302 with § modPatLeftoverCloneNoParent302
  - `r11u26repro/m7,EQUAL,,equal` (was `differ:fullname(38)`) — § modFnLitLeftoverAtLiteral302 with § pkgPatLeftoverSrcPkgListing302
  - `r11u60repro/g7,EQUAL,,equal` (was `differ:fullname(1)`) — § elabImpSelFlatKeepsParent302
  - `r11v55repro/grid/vv1c_cast,EQUAL,,equal` (was `differ:file(8)`) — § castPatTagKeyLocThroughParens302
- **One probe change, toward golden:** `r11v21repro/v15,STRICT_NOTEQUAL,differ:depth(1),differ:depth(1)` (was
  `differ:fullname(7)`). Old first record #6 `fullname <in>loc_t.aa` (raw golden `loc_t.aa`, ours
  `work@dut.LC.loc_t.aa`); new first record #124 `depth` (golden `typespec_member bb` at depth 6, ours a leftover
  constant at depth 7 under the assembled param_assign constant's struct). Chain-keyed away census: away 0, 22
  records toward golden (evidence/probe_movers_away.txt). Residue 1 below.
- **No corpus row moves:** surelog default 480 + 0 and testflags 474 + 0, uhdm2rtlil 803/1/67 in both modes,
  regressions 0 / conversions 0 / changes 0 in both corpora; byteverify reads 0 of 2560 corpus and 0 of 805
  downstream-lane databases moving. Every Surelog row-mode stays CMP_EQUAL (954 of 954); stamped_gen_param d/t
  stays CMP_NOTEQUAL as at the base.
- **Downstream:** IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0, the law csv byte-identical to
  results/downstream_uhdm2rtlil.csv.
- **Probe gate:** 4005 EQUAL + 82 STRICT_NOTEQUAL, regressions 0, conversions 8, changes 1 (pristine at the base:
  3997 + 90, equal to results/golden_probe.csv).

## The laws (src/R302.h)

`R11U302_OFF` drops all six and gives pristine's bytes and exit code on 114 of 114 grid case-views.
`R11U302_TRACE=<dir>` logs every firing (`<law> <detail>`) and every abstention (`<law>_ABSTAIN <reason>`) into
`<dir>/<pid>.302`, its first line `OUT <-o path>`.

### § modFnLitLeftoverAtLiteral302 — switch `R11U302_LITLOC_OFF` (ParamEmit, stampEvalFuncLeftovers' drain, the literal branch; registry written in ExprEmit's assignment emission)

- **Shape:** a member-by-member const function declared in a MODULE, interface, program or `$unit` (not a package)
  writes a member from a literal, `function automatic pk::c_t mk(); pk::c_t c; c.d = 64; ...` with
  `localparam pk::c_t L = mk();` beside it.
- **Golden:** the typespec member's leftover (Actual_value) is the function body's own literal object, located at
  the literal (r11u26repro/m4 `c.d = 64`: constant 12:32-34, UINT:64 size 64), and because it is the body's object
  the strict walk lists it once under the body and not again in a typespec copy walked later (the kid's definition
  listing of r11u24repro/n4, r11u13repro/b3, m4 and a2).
- **Ours (pristine):** a minted value slice parked at the call `mk()` (14:26-30), listed again in every typespec copy.
- **Decode:** UHDM's ExprEval::setValueInInstance stamps `reduceExpr(<body RHS>)` and a literal reduces to itself
  (the landed § pkgStructFuncAssembleBin / § modEvalFuncLeftoverEnc reading: holder-blind). Pristine already shares
  the body object for a PACKAGE subroutine (ExprEmit records bodyAsgRhsObj only under pkgScopeInst); this law records
  the emitted literal right side of an assignment in any other subroutine (modFnBodyLit302, every copy in emission
  order) and shares the FIRST copy (the definition listing's subroutine). With no recorded copy the minted constant
  is relocated to the literal (trace `reloc`); the law moves only a still-minted constant.
- **Converts:** b3, n4 (alone), m4, a2, m7, n11 (with the laws below).

### § modPatLeftoverCloneNoParent302 — switch `R11U302_PATMODNOPAR_OFF` (ParamEmit, the drain's pattern-parameter branch)

- **Shape:** the builder writes a member from a pattern parameter declared in the MODULE (`localparam pk::in_t UU =
  '{a: 11, b: 22}; ... c.u = UU;`).
- **Golden** (m4, a2): the leftover clone of UU's flattened pattern has no parent, and its ref_typespec neither a
  parent nor a full name; the reference binds the package listing's `pk::in_t` (its members name
  `pk::pk::in_t::a`), not the module's copy.
- **Decode:** CompileHelper::getValue (third_party/Surelog/src/DesignCompile/CompileExpression.cpp, the
  `instance->getComplexValue(name)` branch after the `::` branch) hands back the instance's complex value object for an
  unqualified module parameter, an object no param_assign holds; ExprEval's flatten mints its reference unparented
  onto the pattern's declared typedef. Ours cloned the elaborated param_assign's Rhs and kept that parent
  (§ patParamLeftoverShare26's package model). The law unparents the clone, clears its reference's name and parent,
  and binds the reference to pkgTopTypedefTs's object for the parameter's typedef (trace `toptd`).
- **Converts:** m4, a2 (with § modFnLitLeftoverAtLiteral302).

### § pkgPatLeftoverSrcPkgListing302 — switch `R11U302_PATSRCPKG_OFF` (ParamEmit, the same branch; the record pkgOwnElabRhs302 written in emitParameters)

- **Shape:** the module builder reads a PACKAGE pattern parameter QUALIFIED (`c.u = pk::UU;`) in a module that also
  imports the package (r11u26repro/m7).
- **Golden:** the leftover is a clone of the PACKAGE listing's param_assign Rhs, parented there (its reference
  reads `pk`); ours cloned the importing module's copy (`work@dut`), which writes elabParamRhsObj6 after the
  package listing.
- **Decode:** getValue's `::` branch (CompileExpression.cpp, `pack->getParam_assigns()` ... `clone_tree(param->Rhs())`,
  `result->VpiParent(param)`) resolves the qualified name to the package's own param_assign. The law takes the
  package's own elaborated listing's Rhs (recorded when `inPackage && !isImported`) for a qualified read only; an
  UNQUALIFIED read through an import resolves in the instance first and golden clones the module's copy (grid
  PM/p03), so the law abstains there (trace `_ABSTAIN unqualified`: 26 probe cases and portsel_struct_param d/t,
  all byte-identical).
- **Converts:** m7 (with § modFnLitLeftoverAtLiteral302).

### § rootTdLeftoverStamp302 — switch `R11U302_ROOTTDSTAMP_OFF` (ParamEmit, stampEvalFuncLeftovers' stamp walk)

- **Shape:** a compilation-unit (`$root`) struct typedef, `typedef struct packed {...} rc_t;` at file scope, with
  a builder and `localparam rc_t L = mk();` (r11u24repro/n11).
- **Golden:** the leftovers sit on the DESIGN's own rc_t object and every reference to rc_t reads it (L's members
  name `rc_t.a`, the function variable's typespec lists the stamps). Our stamp walk reached only TopPackages'
  typespecs and TopModules' parameters (the n11 case's own comment names the gap).
- **The law:** before that walk, a design-level struct typespec is stamped from the stamp whose owner parameter's
  declared type is a compilation-unit typedef of that name with the same member names, and becomes the stamp's
  `stamped` object (so the owner parameter binds it). A package typedef of the same name and members is not matched
  (grid RT/r04).
- **Converts:** n11 (with § modFnLitLeftoverAtLiteral302); moves r11v21repro/v15 toward golden (residue 1).

### § elabImpSelFlatKeepsParent302 — switch `R11U302_IMPSELFLATPAR_OFF` (ParamEmit, § pkgPatReadTsNoParent131's elaborated walk; record at § modDefImportPkgSelFlat60)

- **Shape:** a packed package pattern parameter the DECLARING package member-selects (`typedef logic [WSEL.a-1:0]
  w1_t;` in p7), imported into a module (r11u60repro/g7).
- **Golden:** the elaborated instance's import copy keeps a parented reference named by its chain
  (`work@g7top.u_q`); the never-selected sibling WNON carries the unparented reference § pkgPatReadTsNoParent131
  models.
- **Decode:** § modDefImportPkgSelFlat60's reading: a member select written in the declaring package reduces the
  package's param_assign in place while the package compiles, and every module's copy is a clone_tree of that flat
  Rhs, which re-parents the reference at the copy's operation; only a copy the elaborator flattens itself mints the
  reference ExprEval leaves unparented. The law skips § pkgPatReadTsNoParent131's unparenting for an import copy whose
  `pkg::NAME` § modDefImportPkgSelFlat60 flattened, giving an emitted copy that already shares an unparented
  reference a fresh one named by the owning instance or generate scope (trace `fresh`).
- **Converts:** g7. Fires 82 times on BlackBePipeInt d/t with 0 bytes moved (the copies there already hold their
  parented reference; byteverify and the census agree).

### § castPatTagKeyLocThroughParens302 — switch `R11U302_CASTPATKEY_OFF` (ExprEmit, the structured-pattern branch's tag-key lookup)

- **Shape:** a pattern written as a cast's operand, `cfg_t'('{n: 9, h: 16'h00AB})` (r11v55repro vv1c_cast).
- **Golden:** each tagged_pattern's string_typespec is located at its key (`n` 4:37, `h` 4:44), as for a bare pattern.
- **Ours (pristine):** unlocated: slang binds the cast's operand from the ParenthesizedExpression syntax, so the
  pattern's syntax is the parentheses and the key lookup (which wanted an AssignmentPatternExpression) found none.
- **The law:** read through any number of parentheses to the AssignmentPatternExpression.
- **Converts:** vv1c_cast.

## Grid (cases/, 57 case dirs, 114 case-views; evidence/grid.txt, every line with its exit code)

Each case names its law in its first line. Lines: `<case> <view> <label> rc=.. cmp=.. <strict> md5=..` for
pristine, law, law+R11U302_OFF and law with each switch alone. Summary (evidence/grid_summary.txt):
114 case-views, 96 moving, 47 entering STRICT_EQUAL, 0 leaving, no exit-code change (1008 lines rc=0, 18 lines
rc=3 = GF/f05_iface on every binary, slang rejecting `interface ifc import p7::*;;`), law+R11U302_OFF equal to
pristine on 114 of 114. Attribution by the switches that move the law's bytes: CASTPATKEY 22, LITLOC 30,
IMPSELFLATPAR 12, LITLOC with PATMODNOPAR 12, LITLOC with ROOTTDSTAMP 18, LITLOC with PATSRCPKG 2.

| grid | law | cases |
|---|---|---|
| LL | § modFnLitLeftoverAtLiteral302 | l01_mod_lit, l02_mod_hex, l03_mod_nested, l04_mod_childovr, l05_iface, l06_pkgfn_ctl (control), l07_macro, l08_slot (part-select bound, replication count, indexed width), l09_twocalls, l10_gen, l11_modtd, l12_header, l13_include (body from an included file), l14_unbased |
| PM | § modPatLeftoverCloneNoParent302 / § pkgPatLeftoverSrcPkgListing302 | p01_mod_uu, p02_pkg_qual, p03_pkg_import, p04_pkg_noimport, p05_iface_uu, p06_mod_param_ovr, p07_mod_uu_nested, p08_pkgfn_ctl, p09_pkgfn_import_ctl, p10_mod_typed_uu, p11_two_builders, p12_slots |
| RT | § rootTdLeftoverStamp302 | r01_root_modfn, r02_unit_fn_header, r03_unit_fn_localparam, r04_samename_pkg, r05_child_ovr, r06_iface, r07_nested, r08_two_mods, r09_slots, r10_var_ctl (control) |
| GF | § elabImpSelFlatKeepsParent302 | f01_g7, f02_fnsel, f03_modread_ctl (control), f04_narrow, f05_iface (rc 3 on every binary), f06_gen_two (depth 2 and a generate block), f07_explicit, f08_qualsel_ctl, f09_used_in_mod (slots) |
| CP | § castPatTagKeyLocThroughParens302 | c01_pkg_cast, c02_mod_localparam, c03_header_default, c04_double_paren, c05_contassign, c06_default_key, c07_typed_ctl (control), c08_function, c09_nested, c10_macro, c11_slot, c12_import |

Entering STRICT_EQUAL in both views: LL l01, l03, l04, l07, l08, l13; PM p01, p02, p04, p07, p12 and p11 d;
RT r01, r09; GF f01, f04, f06, f07, f09; CP c02, c04, c08, c10, c12; LL l11 leaves stage 1 (uhdm-cmp 32 -> 0,
STRICT_NOTEQUAL fullname). The stage-1 movers on both binaries (LL l02, l05, l09, l12, l14; PM p03, p05, p06, p10;
RT r02 to r08; GF f02 d; CP c01, c03, c05, c06, c09, c11) keep stage 1. The uhdm-cmp line counts that change,
each the stage-1 head moving to a later object (chain away 0 on every one): LL l11 32 -> 0 (leaving stage 1 for
`differ:fullname`), PM p06 17 -> 11, RT r04 15 -> 68 (pristine's head, golden's leftover constant 7 missing from
ours, is cleared and the next head is the hier_path pk::P.b), r06 15 -> 19 (the missing leftover is now a later
object, id 29 -> 84), r07 951 -> 967 (e 1265 -> 1281), r08 32 -> 28.

**Away census** (map 12's chain-keyed census, drivers/awaygrid.sh with strictcmp_x): 0 records away on all 96
grid movers, 2380 records toward golden (evidence/grid_away.txt). Positive control (the binaries swapped, every
eighth mover): away on 11 of 12, l14 neutral (evidence/away_poscontrol.txt).

**Downstream on the grid** (drivers/dscases.py, every case dir on both binaries): no verdict change on 57 of 57
(51 IDENTICAL, 3 DIVERGENT, 2 EQUIVALENT, 1 SLANG_REJECT on both; evidence/downstream_cases.txt).

## Byte controls (evidence/controls*.txt)

1691 earlier case dirs (3382 case-views), the path list built from `find tools/probe -name dut.sv` and filtered by
$FENCED before any file was opened (evidence/control_dirs.txt): every dir whose dut.sv holds a cast-wrapped pattern,
a struct-builder function beside a parameter initialised by a call, or a package typedef sized by a parameter's
member select, plus every case dir of passes 118, 119, 120, 124 and 131 (and their verifications). Law against
pristine: 18 case-views moving, 8 entering STRICT_EQUAL, 0 leaving, no exit-code and no uhdm-cmp line change;
chain away 0 on all 18 (evidence/controls_away.txt). Movers: r11u260repro E/e15_unpacked d/e (CASTPATKEY, entering),
r11v140repro tdc/t08_decl_after d/e (CASTPATKEY, stage 1), v11u225repro FO/h07 d/e (CASTPATKEY, entering),
r11u272repro L/l08_import and l15_import_noaa d/e (IMPSELFLATPAR, stage 1, 0 records either way),
r11v178repro pu/u07_packed_struct d/e (IMPSELFLATPAR, entering), r11u28repro a20 d/e (LITLOC, stage 1, 18/22
toward), a19 d/e (LITLOC with PATMODNOPAR, stage 1, 46/50 toward), r11u26repro n11 d/e (LITLOC with ROOTTDSTAMP,
entering; the tools/probe twin of the converted gate case).

## Firing census (evidence/predict.txt, frozen before the law sweep)

drivers/tracecensus.sh on the law binary over the probe cases and both corpora in both modes (the filter built
from $FENCED). Firings: the 9 probe databases b3, n11, n4, m4, m7, a2, g7, v15, vv1c_cast, and BlackBePipeInt
d/t (elabImpSelFlatKeepsParent302 82 each, 0 bytes moved). Abstentions only (no bytes moved):
pkgPatLeftoverSrcPkgListing302_ABSTAIN on 26 probe cases (r11u14 c8; r11u24 n3, n12; r11u26 m6, m8, m9, m12, m13,
m15, m16; r11u28 a4 to a9, a12, a13, a16; r11v26 v2, v9, v12, v13, v15, v16, v18) and portsel_struct_param d/t.
Byte movers in the law sweep: exactly those 9 probe databases (the predicted list and the moved list are equal),
0 of 2560 corpus, 0 of 805 downstream.

## Gates (evidence/gates.txt, sweep_P.log, sweep_L.log)

- probe: law 4005 + 82, regressions 0, conversions 8, changes 1; pristine 3997 + 90 (0 / 0 / 0).
- surelog 480 + 0 / 474 + 0 and uhdm2rtlil 803/1/67 in both modes: regressions 0, conversions 0, changes 0 on both
  binaries; the row-by-row csv diff law vs pristine: the 9 probe rows and the LowMemLib / LowMemPkg testflags detail
  text (the workdir path), nothing else.
- downstream 803/66/2/0, the csv byte-identical to the committed one.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, same-length workdir names) on fence-filtered
  hard-link mirrors (drivers/mirror.sh, 2560 databases each, 8 fenced skipped): MOVERS 0 / 2560; SELFCHECK reads
  2559 of 2560 flagged: the self-check compares every file with one fixed file, and that file compared with
  itself is the one not flagged (the artefact pass 201 first explained), not a mover.
- canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6 PASS.
- binary-path audit (drivers/audit.sh): law sweep own 3265 other 0 noslang 50; pristine sweep the same.
- determinism (drivers/det.sh, three concurrent draws): one hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard, BuildUVMPkg and Rggen (Scoreboard and Rggen testflags write no database), each equal to
  the law sweep's (evidence/determinism.txt).
- the delivered patch applies clean on a fresh 0c29ccd0 worktree and rebuilds to the law binary's md5
  68d848f44dcb2c30d51741e98e5e1f61.
- every sweep exited 1 on the law-index check alone (tests/LAWS.md was stale at the base); tests/LAWS.md is
  regenerated in this patch.

## Residues (ranked; first records at the base in evidence/residue_first_records_base.txt, chains in evidence/residue_chains_base.txt)

The 82 probe cases still STRICT_NOTEQUAL, classified by the first record's object chain (no debug backtraces this
pass: the writer is read from the chain and the landed laws' sites).

1. **This ground, the leftover family:** r11v21repro/v15 (`$unit` builder initialising a header parameter):
   golden's assembled param_assign constant (`64'b...`) references a loc_t object whose leftovers the walk does not
   list again (the shared body literals, visited in the `$unit` function first), where ours references the stamped
   design object reached first in a typespec copy; the binding is § elabParamLeftoverRefUnnamed174's site in the
   drain (memLeftModAsm). Grid PM/p11 e (two builders, the elaborated view: `differ:fullname` at #47 -> `depth` at
   #874), RT r02/r03 stage 1 (`$unit` builders), LL l02/l09/l12/l14 and PM p05/p06/p10 stage 1 on both binaries
   (hex encodings of the literal leftover, call arguments, header parameters, typed patterns, interface holders),
   GF/f02 d stage 1, CP c01/c03/c05/c06/c09/c11 stage 1 (other faces of the same rows).
2. **This ground, naming:** the select-naming leftovers r10earl29repro/b1_sites fullname(4),
   r10uvm79repro/c2_idxkind col(5), r10uvm92repro/v92_b2_varsel fullname(1) (ExprEmit, the index-name drains);
   r11u117repro/grid/g1/t12 fullname(4) and g13 endcol(3) (the q2::IMPL member path); r11v4repro/v6 fullname(1)
   (an interface port view's struct-parameter copy named `...q.CFG.bus_t.DAT` in golden, the § leftoverTsCopyPerElabUse272
   family on an interface port view).
3. **Surelog defect, not transcribed:** r11u109repro/grid/f1 c04, c06, p06, p07 value(2) (`W'(1)` with W = 64 read
   as 0 in golden).
4. **The sister's ground (reported, not written; writer by chain):** package typedef stretches and last-writer
   spans (r10uvm32repro/t42a line(29), r11v77repro/grid/vh_arrelem endline(6), r10earl53repro/v2_v53,
   r10v136repro/v136_d_homes, r10vearl100repro/v6_more100, r10uvm207repro/g207_h_foreign, r10uvm26repro/t36c,
   r10sd5repro/v6_no_import_control, r10uvm226repro/a12_pkgimport, r10uvm149repro/g149/homes,
   r10uvm129repro/g129_d_bases, r10buvm8repro/vxpkg8: TypeEmit / UhdmExporter / TaskFuncEmit), the type-parameter
   typespec copies (r11u47repro arms g2, g10, g12, r11v47repro arms v12, v28, r11u107repro t13, r11u112repro k14,
   r11u110repro e18, i16, v11u108repro b07, b18, b21, v11u110repro k11, k13, v11u93b107repro q04, r05: TypeEmit /
   UhdmExporter), the q2::row_t alias family (v11u111repro x36, x40, y31; y62, y64, y65, x64: TypeEmit), the generate
   and module-instance cells (r10earl115repro/p1_pos115, r10vrgg17repro/v8, r10earl41repro/v41v_comment,
   r10earl59repro/v59v2_earl59, r10earl98repro/g3_rhs98, r10rgg9repro/cells/l_concat, r11u113repro c09, c11,
   r11u23repro e05, r11v66repro/a3_inst66, r10earl54repro/v13_v54, r10rgg4repro/c9_litarith_noovr,
   r10rgg3repro/f1_noovr_arr_recvp, v11u112repro g1k_hop_userfn: ModuleEmit / TypeEmit emitSyntaxExpr), the
   interface port hier_path spans (r11u1repro/grid2, r11v1repro/vA, r11u93repro pb19_modportview: ModuleEmit),
   the import-clone homes (r10uvm122repro/g122_f_clone, r10v122repro/q6clone, r10uvm227repro a9_class_holder,
   r10v200repro/v200_5_modmat, r10v208repro/v208_f_io, r10uvm36repro/t48a: UhdmExporter / TaskFuncEmit), class and
   package-class faces (r10uvm213repro g213_i_scopedtd, r10uvm220repro a1_uninst_if, r10v112repro g19_builtin,
   r10v206repro x206_a_dropwithmove, r10v97repro c3/c9, r10v181repro v181_h_nofe, r10v194repro v194_a_explicit,
   r10uvm97repro g97_a5_samename, r10v149repro/arms/paramtype, r10v92repro/v5_home: UhdmExporter / TaskFuncEmit /
   ModuleEmit), r11v11u8repro/v9 (a macro column, UhdmExporter's macro model).
5. The brief's items (2) to (7) beyond the above: not attempted this pass.

## Sister-ground faces (reported, not written)

- The kid definition listing's typespec copy (n4, b3, m4, a2 before this pass): golden lists the module builder's
  leftovers there only because they are the shared body objects; this pass's sharing is enough on this ground, no
  ModuleEmit change needed.
- Every chain in residue 4 above, with the emitter named there.

## Process

- The IMPLEMENTER'S SLIPS, no effect: a draft binary (d3) was copied from a build that had failed to compile (the
  previous binary), noticed at once, deleted, rebuilt; a draft knob (`R11U302_DRAFT_LITPICK`, choosing the first or
  last recorded body copy) was measured on the five targets (both choices gave the same bytes) and removed before
  the law binary was frozen; no src edit while a TU compiled.
- Every driver read $FENCED fail-closed; every path list over tools/probe was built and filtered by $FENCED before
  any file was opened; no fenced name was spelled; the only process listing named this pass's own controls driver;
  nothing was written outside the worktree /tmp/wt_r11u302 and /tmp/r11u302_* scratch.
- Drivers: copied from tools/probe/r11u300repro/drivers (renamed to R11U302 / r11u302), plus gridsum302.py and
  controls_list.sh (new). No patch file is kept in this directory.
