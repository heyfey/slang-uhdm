# r11u145 — the expression/parameter ground of the strict axis, fifth refill (implementer)

Base `c24699f1` (branch matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`, `src/EmitHelpers.h`
(`src/StmtEmit.cpp` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`,
`TaskFuncEmit.cpp`, `uhdm_main.cpp` or `include/`; faces whose fix sits there are decoded below and stop there.
Net binding and § ipsQualBaseRangeSpan141v are not touched. Worktree `/tmp/wt_r11u145`, system-deps config, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree rebuild of the base, byte-identical to the main tree's `build/slang-uhdm`) | `a408021857111d030b0571aee87d105b` |
| law (this patch) | `5a327fb1484f60c446cc2d06c5cf3584` |
| `build/uhdm-strictcmp` (= the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |

Both frozen (`chmod 555` copies) before measuring; every `cmds.txt` of the pristine sweep names the pristine
copy (3273 / 3273) and every one of the law sweep the law copy (3273 / 3273). Pristine sweep
(`/tmp/r11u145_wdP`) vs the committed baselines: `regressions=0 conversions=0 changes=0` in all three stages
(evidence/sweep_pristine_vs_baselines.txt; the sweep's only red is `law index STALE`, fixed by this patch's
tests/LAWS.md).

## Result

| axis | base (committed = pristine sweep) | law | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL of 954 judge-equal row-modes) | 788 | **790** | +2 |
| uhdm2rtlil strict-equal (of 1606) | 1394 | **1398** | +4 |
| probe EQUAL (of 4087) | 2295 | **2339** | +44 |
| surelog / uhdm2rtlil judge-equal (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT | same | 0 of 871 rows changed on any column |

**CONVERSIONS (STRICT_NOTEQUAL -> CMP_EQUAL; results/ untouched, the landing re-baselines them)**, fresh csv rows
(evidence/sweep_law_vs_baselines.txt), with the law whose trigger the pristine database carries
(evidence/changes_attributed.txt, drivers/predict145.cpp):

    surelog:
      DefaultPatternInt,default,CMP_EQUAL,,,equal              § defaultFillImportCopies145
      DefaultPatternInt,testflags,CMP_EQUAL,,,equal            § defaultFillImportCopies145
    uhdm2rtlil:
      ibex_counter,default,CMP_EQUAL,,,equal                   § lpPaCopyBoundOwnerName145
      ibex_counter,testflags,CMP_EQUAL,,,equal                 § lpPaCopyBoundOwnerName145
      packed_struct_array_shift,default,CMP_EQUAL,,,equal      § hpBaseSelOpIdxNamesByPath145
      packed_struct_array_shift,testflags,CMP_EQUAL,,,equal    § hpBaseSelOpIdxNamesByPath145

Probe: 44 cases `STRICT_NOTEQUAL -> EQUAL` (each reads `EQUAL,,equal` in the fresh probe.csv):
§ unaryOperandParamOwnerName145 25 (`r11u116repro/grid/f1/*_ig`, the whole `_ig` family), § impElabArithWholeSpan145
15 (`r10earl85repro/g3_ov85`, `r10earl_repro/ll wa wc24 wf`, `r10uvm201repro/g201_d_bodyimp`,
`r10uvm210repro/g210_c_pkgimp g210_d_modimp`, `r10v201repro/v201_i_explicit`, `r10v210repro/v210_1_localparam`,
`r11u113repro/grid/b/b15_exprinit_ius`, `r11u113repro/grid/v/v11_icache_shape`, `r11v50repro/b4_width50`,
`v11u113repro/grid/f1/a08_div a10_pkg_ref_other`), § psBoundBareRefByBase145 4 (`r10earl_repro/wd24`,
`r10uvm78repro/c3_constsel`, `v11u113repro/grid/f1/a09_genfor_lp a13_child_overridden_mod_uses_pkg`).

Targeted downstream rows, all IDENTICAL (evidence/downstream_targets.csv): `ibex_counter,IDENTICAL,OK,OK,129,129,,`,
`packed_struct_array_shift,IDENTICAL,OK,OK,54,54,,`, `comb_dyn_2d_packed_sel,IDENTICAL,OK,OK,124,124,,`,
`ibex_alu,IDENTICAL,OK,OK,1028,1028,,`, `cs_registers,IDENTICAL,OK,OK,149,149,,`.

## Laws (all under `R11U145_OFF=1`, each droppable alone)

| law | switch | site (file + § token) | cluster / residue |
|---|---|---|---|
| § defaultFillImportCopies145 | `R11U145_DEFFILLIMP_OFF` | ParamEmit.cpp `emitParameters`, the `'{default: X}` expansion beside § defaultFillOneConstant140 | N0441's remaining rows (DefaultPatternInt) |
| § unsignedScalarParamTsAtKeyword145 | `R11U145_UNSPARAMTS_OFF` | ParamEmit.cpp `makeParamTs`, the typed branch after `trimTypeSigning` | N0056 (GenCase, GenCaseStmt, int_types), pass 137's S2 |
| § psBoundBareRefByBase145 | `R11U145_PSBAREREF_OFF` | ExprEmit.cpp `emitExpr` RangeSelect case, `bareRefByBase145` after the bound emission | N0076 (part_select ref names) |
| § unaryOperandParamOwnerName145 | `R11U145_UNARYOWN_OFF` | ExprEmit.cpp `emitExpr` NamedValue, the gen-scope CA plain-operand fold (SITE 1 the pa copy, SITE 2 the mint) + `caLhsIsSelect145`; EmitHelpers.h `unaryOperandOwnerName145` | N0129 (58 probe cases' `_ig` family) |
| § lpPaCopyBoundOwnerName145 | `R11U145_LPBOUNDOWN_OFF` | ExprEmit.cpp `emitExpr` NamedValue, the § genCaLpPaCopy case; EmitHelpers.h `paOwnerFullName145` | N0415 (ibex_counter), N0129's bound shape |
| § hpBaseSelOpIdxNamesByPath145 | `R11U145_BASESELOP_OFF` | ExprEmit.cpp `baseSelOpIdxNames145`, called beside `trailSelIdxNames133` at both hier_path builders | N1017 (packed_struct_array_shift), r11v140 residue 2 (v07), pass 133's R7 |
| § impElabArithWholeSpan145 | `R11U145_IMPARITH_OFF` | ParamEmit.cpp `emitParameters`, the "ELAB-pkg computed BinaryOp init" location rule (`wholeImp145`) | N0005's import shape (ibex `ibex_pkg.sv 384`, HierPathStructTypespec, 15 probe cases), pass 140's R13 |

Switch helper: `r11u145On` in EmitHelpers.h (its block lists every switch). `R11U145_OFF=1` restores pristine
bytes on all 52 case databases of this directory (evidence/switches.txt: `byte-identical to pristine on 52 of 52
cases; the law binary differs from pristine on 36`). Each single switch moves exactly its own grid's cases:
DEFFILLIMP `dfi/i01 i02 i03`, UNSPARAMTS `usp/u01 u02 u03 u04 u07 u08`, PSBAREREF `psb/p02 r01 r02 r03 r06 r07`,
UNARYOWN `uop/t02 t10 t11 t12 t16 w01 w11 w16 w17`, LPBOUNDOWN `lpb/l01 l03 l06 r08`, BASESELOP `bso/b01 b03 b04 b05`,
IMPARITH `iaw/ae1 ae4 q02 q06`.

### § defaultFillImportCopies145
Golden (DefaultPatternInt, grid `dfi`): the module views of a package `'{default: X}` parameter reached through an
IMPORT list one constant object PER element, each parented at the array_expr (`work@top.V`: two records); the
package's own listing and a module-local parameter (§ defaultFillOneConstant140, ParamArrayUnsizedPattern) share
one. Pristine shared one in the import copy too (the walk listed one record: `depth`). Law: `isImported` mints per
element. Cases: `dfi/i01_func_body`, `dfi/i02_unused_import`, `dfi/i03_static_func` (§ defaultFillImportCopies145),
`dfi/i04_local_ctl` (control: module-local keeps the shared constant, unchanged).

### § unsignedScalarParamTsAtKeyword145
Golden GenCase `parameter bit unsigned x_1b0`: bit_typespec 6:13-6:16 (the keyword), ours 6:13-6:25. Every view and
every reference sharing the typespec (the constant's ref, the cont-assign read). Scalar `bit`/`logic`/`reg`
`unsigned` only; a packed dimension keeps the whole span (control `usp/u05_dims_ctl`), `signed` unchanged
(`usp/u06_signed_ctl`). Cases `usp/u01 u02 u03 u04 u07 u08` (§ unsignedScalarParamTsAtKeyword145); u04/u08 then read
the pass-145 residue R5 (a package parameter's cont-assign read value).

### § psBoundBareRefByBase145
Census over every judge-equal golden (drivers/cen145.cpp mode `psb`, drivers/psb_an2.py): 3591 bare references that
are a simple part-select bound are named `<select>.<name>` (`work@dut.a.L`); none by the scope alone outside a class
method's `::` path (33, already equal) and a hier_path member select (37, another site). Pristine passed the scope
for a bare bound. The law renames the emitted ref_obj AFTER emission (a bound the emitter folds to a constant keeps
its own naming — the first attempt passed the base prefix down and regressed cs_registers' folded package-parameter
bounds, `work@dut` -> `work@dut.csr_rdata_int`; the landed form does not touch them). Cases `psb/r01 r02 r03 r06 r07
p02` (§ psBoundBareRefByBase145); controls `psb/r04_indexed_ctl`, `psb/r05_indexed_op_ctl` (indexed selects).

### § unaryOperandParamOwnerName145
Census (mode `rtw`): a use-site constant whose parent in golden is the parameter's own `param_assign` takes that
scope's name on its ref_typespec. In an elaborated generate-scope continuous assignment, a parameter read that is the
DIRECT operand of a unary operator (`a[c] & ~M`) is such a constant when the assignment's LEFT side is a select
(`o[c] = ...`, `x[3:0] = ...`, `x[0] = ...`): golden `work@dut`, ours `work@dut.g`. A plain-reference lhs keeps the
generate scope's name (BasicOh oh_dsync `assign dout = ... (~DELAY & ...)`: the first law build without the lhs gate
moved 12 of BasicOh's records AWAY from golden; the landed gate reads the lhs from the syntax, `caLhsIsSelect145`).
Cases `uop/t02 t10 t11 t12 t16 w01_untyped_port w11_lhs_bitsel w16_lhs_partsel w17_lhs_packed_bit`
(§ unaryOperandParamOwnerName145); controls `uop/t03_binary_ctl t05_binary_ctl t13_unary_of_op_ctl
w07_child_plain_lhs_ctl w10_plain_lhs_ctl w12_plain_lhs_ctl`.

### § lpPaCopyBoundOwnerName145
The § genCaLpPaCopy case copies the parameter's elaborated param_assign constant into a generate-scope RHS select
bound; golden's object IS that constant (parented at the param_assign), so its ref_typespec is named by the declaring
instance (ibex_counter `counter_load[63:CounterWidth]`: golden `work@ibex_counter`, ours
`work@ibex_counter.g_counter_narrow.counter_load`). Only when the read IS the bound: a bound nested in an operation
(`x[L-1:0]`) keeps the select base (control `lpb/l05_bound_op_ctl`, which the first law build broke). Cases `lpb/l01
l03 l06 r08` (§ lpPaCopyBoundOwnerName145); controls `lpb/l02_bitsel_ctl l05_bound_op_ctl l07_bitsel_op_ctl
l08_concat_ctl`.

### § hpBaseSelOpIdxNamesByPath145
Census (mode `hpx`): every reference under an operation that indexes a hier_path's FIRST element (`sd[D - 1].v`) is
named `<scope>.<path>.<name>` in golden (`work@dut.sd[D - 1].v.D`; 139 + 119 + 54 records in assignment / operation /
system-call contexts, 30 + 8 already equal in generate scopes), ours the scope's `work@dut.D`. A bare base index
(`sd[i].v`) is left alone (control `bso/b06_bare_idx_ctl`), as is the trailing select (§ hpTrailSelIdxNamesByPath133).
Cases `bso/b01 b03 b04 b05` (§ hpBaseSelOpIdxNamesByPath145).

### § impElabArithWholeSpan145
The elaborated MODULE import copy of a package parameter whose init is arithmetic spans the WHOLE init (golden
`ibex_pkg.sv 384:45-55` `BUS_SIZE/8` under every ibex module, HierPathStructTypespec 11:34-61, q02 3:31-34); the
package's own elaborated listing and the definition-view copy keep the left operand (both equal before and after).
Pristine applied the package rule to the module copy. Keyed on the PHYSICAL view (`defViewOrig9`), so a module with a
parameter port list (flipped topView) keeps its definition copy (case `iaw/ae1`). Cases `iaw/q02 q06 ae1 ae4`
(§ impElabArithWholeSpan145).

## Census (the whole status column, law sweep vs pristine sweep, row by row)

Law vs committed baselines (evidence/sweep_law_vs_baselines.txt):

| | regressions | conversions | changes |
|---|---|---|---|
| probe | 0 | 44 | 4 |
| surelog | 0 | 2 | 11 |
| uhdm2rtlil | 0 | 4 | 26 |

Every pair whose status or strict cell differs between the two sweeps (91 = 50 conversions + 41 changes) was
re-measured record by record (drivers/firstrec.py, evidence/strict_changes_first_record.txt): 50 EQUAL, 13 LATER,
28 SAME-FEWER, none EARLIER or grown; and for the 41 still-failing pairs the law's whole set of differing
(record, field) is a SUBSET of pristine's (drivers/subset.sh, evidence/changed_pairs_subset_check.txt: 41 / 41). The
changes, attributed by trigger (evidence/changes_attributed.txt): ibex_alu / branch_predict / compressed_decoder /
decoder / icache / multdiv_fast / multdiv_slow / pmp / tracer / wb_stage `-7` each and HierPathStructTypespec `col(4)
-> col(1)` (IMPARITH), BasicOh `-20` (PSBAREREF + UNARYOWN), Scr1SvTests `line -4`, YosysBigSimEllip `-97`,
mriscv_bind_sva `-4`, comb_dyn_2d_packed_sel `fullname -> depth` (PSBAREREF), GenCase / GenCaseStmt `endcol ->
fullname` and int_types `-12` (UNSPARAMTS), probe g2_orig76 `col -14` and qj27 `col -> depth` (IMPARITH), g143_c_index
`fullname -> endcol` and c2_idxkind `file -1` (BASESELOP). The two structural `depth` first fields (qj27 #830,
comb_dyn #743/#653) are records pristine already differed at (subset check), revealed when the earlier ones cleared.

Byte level (`SELFCHECK=1 tools/probe/r11v75repro/byteverify.sh`, law vs pristine workdir, evidence/byteverify_*.txt):
surelog `PATH_SETS_IDENTICAL (960 paths)`, `MOVERS: 27 / 960`, selfcheck 959/960; uhdm2rtlil `PATH_SETS_IDENTICAL (1608
paths)`, `MOVERS: 32 / 1608`, selfcheck 1607/1608; probe databases 53 / 4087 (evidence/probe_movers.txt). PREDICTED BY
NAME from the pristine databases (drivers/predict145.cpp, run on every pristine database, evidence/predictions_pristine.txt,
329 predicted): **112 / 112 movers predicted, 0 unpredicted** (evidence/movers_vs_predictions.txt). YosysOldOpen (both
modes) moves in bytes with an order-blind-identical dump: § psBoundBareRefByBase145 stores a name on four bound
references the walk never reaches (serialized, unreachable); the predictor reads every serialized object for that
trigger (`PSBAREREF_ALLOBJ`), and `R11U145_PSBAREREF_OFF=1` alone restores its pristine bytes. The UVM coin family
(MiniAmiq, SeqDriver, SimpleUVM, Scoreboard) did not move.

## Gates

1. Build: md5s above; the pristine rebuild is byte-identical to the main tree's `build/slang-uhdm`.
2. Probe: `regressions=0` vs `results/golden_probe.csv`; EQUAL 2295 -> 2339, STRICT_NOTEQUAL 1792 -> 1748; every case
   stays judge-equal.
3. Corpora: `regressions=0` in both (surelog conversions 2 changes 11; uhdm2rtlil conversions 4 changes 26); uhdm-cmp
   statuses unchanged on every row (480/3 + 474/3, 803/1/67 both modes).
4. Downstream (`tests/sweep.sh --corpus downstream`, law binary, evidence/downstream_summary.txt):
   `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`; joined to
   `results/downstream_uhdm2rtlil.csv` on every column: 0 of 871 rows changed (pass 120's eight rows and every
   earlier target row stay IDENTICAL). The sweep exits 1 only on `law index STALE`, fixed by this patch's tests/LAWS.md.
5. uhdm-cmp: every row keeps judge-equality (the status join), every probe case judge-equal; the grid's stage-1 cells
   keep their uhdm-cmp line counts.
6. Byteverify and predictions: above.
7. Canaries (evidence/canaries.txt): `canaries.sh` law surelog csv vs committed: ok=48 changed=4 — the strict cells of
   predicted, record-checked movers (Scr1SvTests, BasicOh, both modes); the pristine csv reads ok=52 changed=0;
   uhdm2rtlil ok=16 changed=0. `EXPECT_UNKNOWN=1 ctcan2.sh` surelog: PASS ok=58; `EXPECT_UNKNOWN=6 ctcan2.sh`
   uhdm2rtlil: PASS ok=2.
8. Earlier passes' cases as byte controls (pristine vs law, drivers/bytes.sh, evidence/controls_earlier_passes.txt,
   1663 cases): r11u118repro 0/56, r11v11u118repro 0/56, r11u119repro 0/78, r11u120repro 0/44, r11v120repro 0/47,
   r11u121repro 0/83, v11u121repro 0/41, r11u124repro 0/81, r11u125repro 0/61, r11v125repro 0/48, r11u130repro 0/98,
   r11v130repro 0/115, r11u131repro 0/121, r11u133repro 0/50; the rest (evidence/controls_movers_verdicts.txt):
   r11v124repro `pv/v14_string`, `qx/q08_string` write NO database on either binary (rc=3; the script counts two
   absent files as a difference — no mover); r11v131repro `par/b03_pkg_import_lit`, `par/b22_typed_pkg_import` and
   r11u140repro `dfl/d02_pkg_import` (stage 1 on both, uhdm-cmp 20/26/34 lines on both) move TOWARD golden (dump
   distance 18 -> 14, 18 -> 14, 94 -> 70); r11v133repro `hpm/b10_in_operation` 3 -> 2 differing objects;
   r11v140repro `pfp/b11_chain` and `plv/v07_basesel_opidx` (pass 140's verifier residue 2) -> STRICT_EQUAL.

## Decoded, not landed (ranked residues)

R1 — GenCase / GenCaseStmt after § unsignedScalarParamTsAtKeyword145: the generate-case item's ref_obj and the
named_begin carry full names golden leaves empty, and the gen_scope_array / gen_scope span the case item
(12:13-14:8) where ours spans the instance (13:7-13:17). ModuleEmit.cpp gen_case emission (the `MakeGen_case`
sites). Sister ground.

R2 — PreprocTest (N0056's last rows): `typedef enum bit [2:0]` — golden's enum base bit_typespec spans the keyword
(5:14-5:17), ours the keyword and the dimension (5:14-5:23). TypeEmit.cpp `buildEnumTs`. Sister ground.

R3 — IndexAssign (N1167, 2 row-modes alone): `assign sig[I-7] = 3` — golden keeps the literal's 64-bit encoding
(`3`, size 64) under a SELECT lhs and adjusts it only under a plain module-net lhs (`x = 3` -> `1`, size 1): the
`caLhsAdjustSize68` rule (bindVariable finds nothing for a select) applied to the literal RHS. ModuleEmit.cpp
`emitContAssigns`. Sister ground.

R4 — a module-side package-qualified ENUM constant default (`parameter pk::e_t P = pk::B`, `localparam pk::e_t P =
pk::C`; ibex_alu `RV32B = ibex_pkg::RV32BNone`): golden's definition-view fold spans the qualifier with its colons
(`pk::`, 4:36-4:40; `ibex_pkg::` 10:39-10:49), ours the whole reference — § pkgQualFoldSpanByView124's rule for enum
constants; the enum case of the parameter-default fold (ParamEmit `emitParameters` / ExprEmit enum fold). Probe: q01,
q05 of the scratch grid.

R5 — an imported package parameter READ in a continuous assignment (`assign o = BY`, `BY = S/8`): golden copies the
parameter's own elaborated constant (`INT:4`, const type 7: the `/` case of § foldSigned9), ours mints `UINT:4` from the
type (iaw/q02, q06, ae4, usp/u04, u08: `value` / `decompile`). ExprEmit NamedValue import fold / ModuleEmit
cont-assign fold; not decoded to the site.

R6 — N0005's interface port-view share (r10rgg3repro, 35 probe cases, 7:23-25 vs 7:23-29; GenForIfaceLocalparamBound
10:33-36 vs 10:33-38): ModuleEmit.cpp `emitInterfaceInstance` (pass 133's R4). Sister ground.

R7 — dfi/i01, i03 after § defaultFillImportCopies145: the next face is `type` (the function-body read of the imported
pattern parameter).

R8 — comb_dyn_2d_packed_sel after § psBoundBareRefByBase145: the next face is structural (`depth` #743, an
int_typespec range expanded with its `SEL_W` reference under the 32:36 operation).

R9 — the bare base index named by the path in golden's ELABORATED instance listings (Scr1SvTests
`req_status[req_aval_ptr].req_resp.req_aval_ptr`, 1702 records in 8 row-modes) and the second-package UVM clone's
doubled form (`m_rows[i + 1].level::m_rows::i`, SeqDriver's adpcm_pkg): both left alone by
§ hpBaseSelOpIdxNamesByPath145.

R10 — the remaining N0129 shapes: an indexed_part_select bound inside a hier_path (Earlgrey flash_ctrl
`reg2hw.addr.q[DataBitWidth+:17]`, 156 records), a port connection's bound, ibex_icache's `lookup_addr_ic0[...]`
bounds outside a generate scope (golden `work@ibex_icache`, ours the select), YosysOldOpen `BASE_ADDR[14:4]` (golden
the instance, ours `<instance>.BASE_ADDR`): the same "the copy IS the param_assign constant" rule at other fold cases.

## Cases (first line of every case names its law; pristine and law verdicts, evidence/grid_pristine_vs_law.txt)

| case | law | pristine | law |
|---|---|---|---|
| `dfi/i01_func_body` | § defaultFillImportCopies145 | STRICT_NOTEQUAL depth | STRICT_NOTEQUAL type |
| `dfi/i02_unused_import` | § defaultFillImportCopies145 | STRICT_NOTEQUAL depth | STRICT_EQUAL |
| `dfi/i03_static_func` | § defaultFillImportCopies145 | STRICT_NOTEQUAL depth | STRICT_NOTEQUAL type |
| `dfi/i04_local_ctl` | § defaultFillImportCopies145 (control) | STRICT_NOTEQUAL file | same |
| `usp/u01`, `usp/u02`, `usp/u03`, `usp/u07` | § unsignedScalarParamTsAtKeyword145 | STRICT_NOTEQUAL endcol | STRICT_EQUAL |
| `usp/u04`, `usp/u08` | § unsignedScalarParamTsAtKeyword145 | STRICT_NOTEQUAL endcol | STRICT_NOTEQUAL decompile (R5) |
| `usp/u05_dims_ctl`, `usp/u06_signed_ctl` | § unsignedScalarParamTsAtKeyword145 (controls) | STRICT_EQUAL | STRICT_EQUAL |
| `psb/r01`, `psb/r02`, `psb/r03`, `psb/r06`, `psb/r07`, `psb/p02` | § psBoundBareRefByBase145 | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| `psb/r04_indexed_ctl`, `psb/r05_indexed_op_ctl` | § psBoundBareRefByBase145 (controls) | STRICT_EQUAL | STRICT_EQUAL |
| `uop/t02`, `uop/t10`, `uop/t11`, `uop/t12`, `uop/t16`, `uop/w01_untyped_port`, `uop/w11_lhs_bitsel`, `uop/w16_lhs_partsel`, `uop/w17_lhs_packed_bit` | § unaryOperandParamOwnerName145 | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| `uop/t03_binary_ctl`, `uop/t05_binary_ctl`, `uop/t13_unary_of_op_ctl`, `uop/w07_child_plain_lhs_ctl`, `uop/w10_plain_lhs_ctl`, `uop/w12_plain_lhs_ctl` | § unaryOperandParamOwnerName145 (controls) | STRICT_EQUAL | STRICT_EQUAL |
| `lpb/l01`, `lpb/l03`, `lpb/l06`, `lpb/r08` | § lpPaCopyBoundOwnerName145 | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| `lpb/l02_bitsel_ctl`, `lpb/l05_bound_op_ctl`, `lpb/l07_bitsel_op_ctl`, `lpb/l08_concat_ctl` | § lpPaCopyBoundOwnerName145 (controls) | STRICT_EQUAL | STRICT_EQUAL |
| `bso/b01`, `bso/b03`, `bso/b04`, `bso/b05` | § hpBaseSelOpIdxNamesByPath145 | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| `bso/b06_bare_idx_ctl` | § hpBaseSelOpIdxNamesByPath145 (control) | STRICT_EQUAL | STRICT_EQUAL |
| `iaw/ae1` | § impElabArithWholeSpan145 | STRICT_NOTEQUAL endcol | STRICT_EQUAL |
| `iaw/q02`, `iaw/q06` | § impElabArithWholeSpan145 | STRICT_NOTEQUAL endcol | STRICT_NOTEQUAL value (R5) |
| `iaw/ae4` | § impElabArithWholeSpan145 | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL fullname (the child-view ref name, R10) |

52 cases, every one rc=0 and uhdm-cmp 0 lines on both binaries; 36 move, 29 of them to STRICT_EQUAL.

## Files

* `dfi/ usp/ psb/ uop/ lpb/ bso/ iaw/` — the law grids (52 cases).
* `drivers/`: `rc.sh` (one case: golden with the probe flags, cached per case dir; ours per binary; uhdm-cmp; strict),
  `cx.sh` + `ctx2.sh` + `anc.py` (a case's differing strict records with their ancestors), `row.sh` + `rowcx.sh`
  (corpus rows through verify_golden.py), `grid.sh` (every case on a list of binaries), `switches.sh` (master and
  single switches), `bytes.sh` (earlier passes' byte controls), `cen145.cpp` + `census.sh` + `pairs.py` +
  `psb_an2.py` + `rtc_an.py` (golden-vs-ours censuses: `psb` part-select bound references, `rtc`/`rtw` constant
  typespec references and their parentage, `hpx` hier_path select indices), `predict145.cpp` (mover prediction
  from pristine databases), `firstrec.py` + `subset.sh` (record-level check of every changed pair). Build a C++
  driver with `g++ -std=gnu++20 -include uhdm/config.h X.cpp -I ~/.local/include ~/.local/lib64/libuhdm.a
  ~/.local/lib64/libcapnp.a ~/.local/lib64/libkj.a -ldl -lpthread`.
* `evidence/`: sweep gates (pristine and law), downstream csv and summary, byteverify, predictions and movers,
  record checks, switches, grid, earlier-pass controls, canaries, change attribution.
