# r11u252: the expression/parameter ground, pass 252 (implementer)

Base 99ea3716 (`matrix-1.87`). Pristine binary md5 de0c6d846229ddfb799e37cb0cbb28b8, byte-identical to the main
tree's `build/slang-uhdm`. Law binary md5 ec509aa1d646c51552387d68d1c3796a. Both report slang 12.0.0+545f88b2e.
Production files: src/ParamEmit.cpp, src/ExprEmit.cpp, src/StmtEmit.cpp and the new src/R252.h. Every law reads
its own `R11U252_<LAW>_OFF` switch. `R11U252_OFF` drops all twelve laws and restores pristine bytes (230 of 230
grid case-views). `R11U252_TRACE=<dir>` logs every firing.

**Verdict on the gate: SimpleUVM CONVERTS in both modes. MiniAmiq, SeqDriver and BlackBePipeInt change in both
modes, each with its old head cleared.**

The fresh law-sweep rows (`results/` is untouched):

    SimpleUVM,default,CMP_EQUAL,,,equal
    SimpleUVM,testflags,CMP_EQUAL,,,equal
    MiniAmiq,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
    MiniAmiq,testflags,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
    SeqDriver,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
    SeqDriver,testflags,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
    BlackBePipeInt,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
    BlackBePipeInt,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)

| row-mode | base (99ea3716) | law | what moved |
|---|---|---|---|
| SimpleUVM d / t | `value(50)`, #203342 / #203354 | **CMP_EQUAL, strict equal (334285 / 334297 objects)** | brief item (1): the 50 `work@top.UVM_*` parameter values. § dupImportSameValueKeeps252 |
| MiniAmiq d / t | `type(1)`, #87036 | `fullname(5)`, #95125 | item (2): #87036 (§ cloneLoopVarLocalElemTs252), #90429 / #90430 (§ cloneHpIdxSelectByChain252), #93788 (§ cloneLoopVarClassScopedInt252) and #94831 (§ cloneRandWithParentCall252) all cleared. The new head is on the sister ground (see "Sister-ground faces") |
| SeqDriver d / t | `type(1)`, #86994 / #87006 | `fullname(5)`, #95083 / #95095 | the same four faces cleared. The new head is the MiniAmiq one, bound through `work@top_tb` |
| BlackBePipeInt d / t | `file(721)`, #190646 / #190553 | `depth(1)`, #331795 / #331692 | item (3): every record up to #331795 now agrees with golden, about 743 per mode. The laws are § impSizeCastFoldLocated252, § impStructRefOpAtRef252, § ternLeafThroughParamRef252, § patFlatBinLeftSpan252, § lazyTernArithLeftSpan252, § impPatMemberReadParentsAll252 and § impPatConcatSelReadParents252. The depth head is decoded, not written (residue 2) |

Probe: five conversions and no regression (EQUAL 3547 -> 3552): r10uvm201repro/g201_a_forms, g201_c_uvmshape,
g201_e_explicit, r10uvm210repro/g210_e_unitimp, r10uvm67repro/c5_clone. Each was `differ:value(2)` or
`value(10)` before; § dupImportSameValueKeeps252 converts all five. No other probe case changes.

## The laws

| law | switch | site | what |
|---|---|---|---|
| § dupImportSameValueKeeps252 | R11U252_DUPIMPVAL_OFF | ParamEmit `paramValueIsDefRhs124`, the `scope` lambda | § paramValueIsDefRhs124 gives a listing's Parameters() entries their param_assign's value. Before this law it left the entries alone whenever a key (name + vpiImported) appeared twice, as "ambiguous". A `$unit`-scope `import p::*;` lists every package parameter twice in the module's DEFINITION listing (measured on golden and ours: A, B, C, A, B, C). Both copies come from one declaration, and golden writes the value on both entries: SimpleUVM `work@top.UVM_ABSTRACT` UINT:16384, decode r11u251repro HP h01, h02. Now a key listed twice keeps its value when the two values agree and are not empty. Disagreeing values still leave the listing alone. An agreed EMPTY value (the clearing half) also leaves it alone: in U/u12 our definition Rhs of `real R = 1.5 * 2` stays an operation where golden's folds, and the first draft's clearing moved golden's REAL:3.000000 away |
| § cloneLoopVarLocalElemTs252 | R11U252_CLONELVLOCAL_OFF | StmtEmit, the foreach branch's § cloneLoopVarHomeObject183 block (`res183`) | A clone's foreach over a SUBROUTINE-LOCAL queue or dynamic array. Surelog compiles the tf local `static string values[$];` as a plain string_var (the dimension is dropped, both sides list it so). The home listing's lateTypedefBinding then resolves the loop variable through that variable's own typespec. So the shared home object binds the local's ref_typespec actual (string_typespec at the keyword, uvm_component.svh 3380:10), where ours kept the unsupported placeholder. This applies to a local of a subroutine or of a block nested in one. A variable whose ref_typespec has no actual keeps the placeholder |
| § cloneHpIdxSelectByChain252 | R11U252_CLONEIDXSEL_OFF | ExprEmit `cloneHpIdxDrain220` (the `drop` lambda), default view only (`cloneIdxSelElabView252`, set from ParamEmit) | The index of a path element's select is itself a select of a reference: `arb_sequence_q[avail_sequences[i]].sequence_ptr`. UHDM's DeepClone of the outer select parents the cloned inner select at the OUTER select and stores no name on it. The writer's chain therefore keeps the outer select's name: golden `...::arb_sequence_q[[i]].sequence_ptr::arb_sequence_q::avail_sequences`, and its index `...::arb_sequence_q::i` (MiniAmiq #90429 / #90430). Ours parented it at the hier_path with the home's stored name. The inner select's index is handled too: a reference directly under it takes the § cloneHpIdxNamesByChain220 treatment, and a reference under an operation or a call drops a name the chain rebuilds (X x03 `avail[i+1]`, x07 `avail[pick(i)]`; the first draft also moved the elaborated view, which pristine already had right, so the law is the default view's). The operation branch of the existing drain got braces (a dangling else, byte-neutral) |
| § cloneLoopVarClassScopedInt252 | R11U252_CLONELVSCOPED_OFF | StmtEmit, the same block | A loop list written CLASS-SCOPED, `foreach (this_type::m_typewide_sequences[i])`. Surelog compiles the scoped name through paClass_scope (§ foreachScopedArrayName33), the home listing's decodeHierPath answers nothing for it, and swapForSpecifiedVar mints the bare int_var. The shared home object therefore carries that unlocated int_typespec (MiniAmiq #93788), not the property's array_typespec, string_typespec or index typespec. Class properties only; a package-scoped name is not touched (K/k11, stage 1 on both) |
| § cloneRandWithParentCall252 | R11U252_CLONERANDWITH_OFF | ExprEmit, the member `randomize() with` site (`cons119`) | In the default view's importer copy, the bare `with {}` constraint is parented at the method_func_call: method_func_call::DeepClone parents the cloned With at the cloned call, so the chain runs call (skipped) -> hier_path. Golden `svaunit_pkg::uvm_sequence_library::execute::seq_or_item` (the `uvm_rand_send` macro, MiniAmiq #94831). The home keeps the hier_path's own parent. The scope form `randomize() with {...}` keeps its parent too (R r03: the first draft moved it away) |
| § impSizeCastFoldLocated252 | R11U252_IMPCASTLOC_OFF | ParamEmit, the generic fold's `importedFold` location | A materialized import copy whose init is a SIZE cast (`(W+V)'(x)`, `24'(x)`, `V'(x)`) is located at the whole init in both module views. Golden BlackBePipeInt `host_base_addr_gp` dut.sv 2537:40-89, #190646. Every other importedFold form keeps the bare constant, and so does a cast whose operand is a CONCATENATION or a replication (`3'({3'h1})`, `8'({2{4'h3}})`): ParamTypespec, uhdm2rtlil DivisionOfSize and probe v11u114 m02. The first draft moved those three away, caught by the firing-census sweep before any gate sweep |
| § impStructRefOpAtRef252 | R11U252_IMPREFLOC_OFF | ParamEmit, the flat op75 branch (`op2`) | A materialized import copy of a struct parameter written as a bare reference to another (`localparam bp_proc_param_s bp_unicore_cfg_p = bp_default_cfg_p`). Its op75 spans the REFERENCE (BlackBePipeInt 2565:47-63, #190751), not the borrowed pattern. A module's own reference keeps the pattern span |
| § ternLeafThroughParamRef252 | R11U252_TERNREFCHAIN_OFF | ParamEmit `ternPickedLeaf250` (the MemberAccess branch) | A member read off a struct parameter that is itself a bare reference (`bp_unicore_cfg_p.cc_x_dim`) reaches the referenced parameter's pattern literal. Golden puts it at bp_default_cfg_p's `1` (2047:16-17, #191992 and the members after it); ours took the ternary's span |
| § lazyTernArithLeftSpan252 | R11U252_LAZYARITHLOC_OFF | ParamEmit § elabLazyTernaryArithFold | The reduced arithmetic element of a lazily substituted unpacked-array pattern sits at its LEFT operand's node (§ patFlatMemberLeftSpan169): `coh_noc_cord_markers_pos_p` 15483:12-34, #293887 and its mem/io twins. Ours took the whole sum |
| § impPatMemberReadParentsAll252 | R11U252_MEMREADPARENT_OFF | ParamEmit `impPatCopyFirstListing215` (its memberRead branch); reach `pkgMemberReadNames252` | The second half of § impPatMemberReadKeepsParent215v's decode: golden parents the op ref of EVERY listing of a member-read pattern parameter. The elaborated module's flat op75 ref was left bare (BlackBePipeInt `bp_default_cfg_p` ... `ref_typespec work@bp_be_pipe_int`, #294152 and 81 more per mode). Its reach is an AST walk of each package's own parameter initializers: a member select of a parameter of the SAME package, with a constant `?:` reading only its taken branch. Not reached: a read only in a module (probe v11u114 g11, k12), a read by another package (r11u215 I/i18, S/s22), a read in an untaken branch (r11u250 T/t03, S/s21). The first two drafts moved those away |
| § patFlatBinLeftSpan252 | R11U252_PATBINLEFT_OFF | ParamEmit, the wide walk's folded member | A struct-pattern member written as ARITHMETIC directly in the walked pattern is reduced at its left operand's node: `(1 << e_cfg_enabled)` 2088:29-30, the `\|` chain 2077:28-2081:58 (#294395, #294400 and 33 more per mode). Ours took the whole operation |
| § impPatConcatSelReadParents252 | R11U252_CONCATSELREAD_OFF (rides on R11U252_MEMREADPARENT_OFF) | ParamEmit `concatSelReadNames252` | The parameters that an element select of a concatenation parameter reaches (`all_cfgs_gp[bp_params_p]` over `all_cfgs_gp = {...}`) join the parented set: substituteAssignedValue expands every element to answer the select. BlackBePipeInt `bp_custom_cfg_p`, `bp_unicore_megaparrot_cfg_p` ... (#294444 and 20 more per mode). An unselected concat keeps the base (S/s14) |

## Cases (every first line names its law)

Each cell reads pristine -> law in both views. `cN` is the uhdm-cmp line count. Every grid line carries its
exit code, and every exit code is 0.

| cases | law | result |
|---|---|---|
| U u01, u02, u04, u10, u11, u14, u15 | § dupImportSameValueKeeps252 | STRICT_NOTEQUAL value -> STRICT_EQUAL: a `$unit` import, used, with a module-scope import too, two modules with overrides, an explicit `$unit` import beside the wildcard, an interface, typed parameters |
| U u05-u09, u12 | § dupImportSameValueKeeps252 | stage 1 on both (a package chain, `$clog2` / ternary / cast inits, a type parameter, localparams, the constant slots u09: port ranges, an unpacked dimension, a replication count, an indexed part-select width, a localparam default; real and string u12). Bytes move. The chain-keyed away census reads 0 lost on all except u07 (below) |
| U u03, u13 | controls | STRICT_EQUAL on both: a module-scope import, a parameter port list |
| L l01-l05, l11, l14, l15 | § cloneLoopVarLocalElemTs252 | STRICT_NOTEQUAL type -> STRICT_EQUAL: static and automatic string, int, logic-vector queues, a dynamic array, no re-export (l11), a nested loop, a package function |
| L l06, l12, l13 | § cloneLoopVarLocalElemTs252 | moved toward golden, still unequal: a typedef element (stage 1), the constant slots `values[i][3:0]` / `values[i][7 -: 4]` (l12, a fullname face of the part-selects, 16 records toward), a class element (l13: type -> name, golden names the class_typespec) |
| L l07-l10 | controls | unchanged: an associative local, a fixed local, a block local and a task (stage 1 on both) |
| X x01-x03, x05-x08 | § cloneHpIdxSelectByChain252 | default view STRICT_NOTEQUAL fullname -> STRICT_EQUAL: a call argument, an rvalue, an operation index, an lvalue, a constant index, a call as index, a member select after; the elaborated views were equal and stay so |
| X x04 | § cloneHpIdxSelectByChain252 | STRICT_NOTEQUAL col on both (a two-level index; the home's span face, residue) |
| X x09-x12 | controls | unchanged: a part-select slot (stage 1), no re-export, a reference index, inc/dec |
| K k01-k03, k05-k08, k10 | § cloneLoopVarClassScopedInt252 | STRICT_NOTEQUAL type -> STRICT_EQUAL: a parameterized `this_type`, a plain `this_type`, the class name, string, associative, dynamic and fixed properties, the constant slot `[3:0]` in the body |
| K k04, k09, k11 | controls | unchanged: the bare and `this.` spellings, a package-scoped list (stage 1) |
| R r01, r02, r05, r06, r08-r10 | § cloneRandWithParentCall252 | default view STRICT_NOTEQUAL fullname -> STRICT_EQUAL: an empty `with`, a constraint, an assignment, a formal receiver, the `uvm_rand_send` shape, `inside {[1:4]}` and a part select in the constraint, a function return |
| R r03, r04, r07 | controls | unchanged: the scope form, a module import, no `with` |
| F f01-f03, f08, f10, f14 | § impSizeCastFoldLocated252 | STRICT_NOTEQUAL file -> STRICT_EQUAL: paren, literal and parameter widths, a parameter operand, the BlackBePipeInt shape |
| F f09, f12, f13, f17 | § impSizeCastFoldLocated252 | stage 1 on both (no parameter port list, the constant slots `X[3:0]` / `X >> 18` / `[Y-1:0]`, an assignment) or STRICT_EQUAL on both (a typed parameter f17); bytes move, 0 lost |
| F f04-f07, f11, f15, f16 | controls | unchanged: type cast, concat, replication, unary, struct cast, a concatenation operand (the ParamTypespec shape), a replication operand (probe m02) |
| S s13, s16, s17 | § impPatConcatSelReadParents252 | STRICT_NOTEQUAL fullname -> STRICT_EQUAL: a parameter-port select, the ternary configs, a 12-member struct |
| S s11, s20 | § patFlatBinLeftSpan252, § impPatMemberReadParentsAll252 | STRICT_NOTEQUAL fullname -> STRICT_EQUAL |
| S s01-s03, s05 | § impStructRefOpAtRef252, § ternLeafThroughParamRef252, § impPatMemberReadParentsAll252 | STRICT_NOTEQUAL fullname, 4 records -> 1 (the package-listing face of residue 3) |
| S s04, s06, s07, s10, s12, s15, s21 | the same laws | stage 1 on both; the chain-keyed census reads 0 lost |
| S s08, s09, s14, s18, s19, s22 | controls | unchanged: a module-only read, unread, unselected, the constant slots read in a module, the k12 shape, a re-exporter's read |
| T t01, t02, t07 | § lazyTernArithLeftSpan252 | STRICT_NOTEQUAL endcol -> STRICT_EQUAL: a port-list localparam, a body localparam with parentheses, a nested ternary |
| T t04-t06 | § lazyTernArithLeftSpan252 | stage 1 on both (a true branch with `*`, the constant slots `[A[2]:0]` / `{A[1]{1'b0}}`, an imported operand); bytes move, 0 lost |
| T t03 | control | stage 1 on both, unchanged (no ternary) |
| decode M/m01 | § cloneAggMemberOwn241 (sister) | the MiniAmiq / SeqDriver head #95125, reproduced: STRICT_NOTEQUAL fullname on both |
| decode S/d01-d04 | § impStructRefOpAtRef252 / § impPatConcatSelReadParents252 | d01 the home definition listing's substitution of an unread `U = D` (stage 1 on both); d02 residue 3; d03 a select reaching a reference element (stage 1); d04 the BlackBePipeInt depth head, not reproduced (STRICT_EQUAL under the law) |
| decode H/h01 | § cloneHpIdxSelectByChain252 | a parenthesised out-of-body definition with two declarations: stage 1 on both binaries (a sister-ground face) |

Grid (`evidence/grid.txt`, `evidence/gridsum.txt`; drivers/grid.sh): 115 case dirs, 230 case-views, 15
configurations, 3450 lines. R11U252_OFF reproduces pristine bytes on 230 of 230. 90 case-views enter
STRICT_EQUAL, none leave, every exit code is 0, and each switch reverts only its own law's cases. The away census
over every moving case-view that stays unequal (`evidence/away_grid.txt`, drivers/awayctl.sh):
chain-keyed records (drivers/awaychain.py; each database is walked against itself, so stage-1 pairs are keyed
too) read 0 lost on every case-view except U/u07 (below). The order-blind uhdm-dump line census, kept beside it
for stage-1 pairs, reads 1-3 "lost" lines on S s04, s06, s15 and the controls bp01 and w05. Each was traced
listing by listing (bp01, w05 and t03 in the dumps): the law's listings equal golden's, and the line multiset
matched a pristine line against a golden line of ANOTHER listing.

**U/u07** (`parameter A = $bits(T) * 2` with a type parameter T, stage 1 on both): 2 chain records move away.
Our definition Rhs folds `$bits(T)*2` to a constant where golden keeps the operation. That is a pre-existing
definition-view face of ParamEmit's fold, and § paramValueIsDefRhs124 already gave our param_assign Lhs that
value on pristine. The law extends the value to the two Parameters() copies. It is left standing and named as
residue 5; no gate database holds the shape.

## Gates (from the worktree, every binary path audited)

| gate | pristine sweep | law sweep |
|---|---|---|
| build | de0c6d84 (= main tree) | ec509aa1 |
| probe vs golden_probe.csv | EQUAL 3547 + STRICT_NOTEQUAL 540, regressions 0 | **EQUAL 3552 + 535, regressions 0, conversions 5, changes 0** |
| surelog vs golden_surelog.csv | 937 + 17, regressions 0 changes 0 | **939 + 15: regressions 0, conversions 2 (SimpleUVM d/t), changes 6 (MiniAmiq d/t, SeqDriver d/t, BlackBePipeInt d/t)** |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 1606 + 0 | 1606 + 0, regressions 0 conversions 0 changes 0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; the csv equals the pristine sweep's row for row |
| uhdm-cmp on every corpus mover | - | 0 lines on all 10 (`evidence/uhdmcmp_movers.txt`) |
| binary audit (cmds.txt, fence-filtered path list) | 3265 of 3265 slang lines name pristine.bin | 3265 of 3265 name law.bin (`evidence/binaudit.txt`) |

Both sweeps exit 1 only on the law-index check: the worktree carried this pass's new cases before
`tests/LAWS.md` was regenerated, which is the last step of the pass. `python3 scripts/law_index.py --check`
passes after regeneration.

**Movers, predicted.** The firing census (drivers/tracesweep.sh: R11U252_TRACE over both corpora in both modes and
the 4087 probe cases, the fenced rows excluded by the harness's own `--filter` built from `$FENCED`) was frozen
before the law sweep (`evidence/prediction.txt`, chmod 444). It names 30 databases: 10 corpus and 20 probe, and 0
uhdm2rtlil, so 0 downstream movers.

* Corpus byte movers (byteverify over fence-filtered hard-link mirrors, drivers/bvmirror.sh, `evidence/byteverify.txt`):
  **10 of 2560**, exactly the 10 predicted: BlackBePipeInt, Earlgrey_0_1, MiniAmiq, SeqDriver and SimpleUVM in
  both modes.
  * The SELFCHECK reads 2559 of 2560. That is the self-check's own artefact: it compares every file against one
    fixed file, and the fixed file equals itself. It is not a mover line.
  * Scoreboard default (the UVM storage coin) did not move.
  * Earlgrey_0_1 moves in bytes only: § impSizeCastFoldLocated252 fires on it, and the strict record multisets and
    the order-blind uhdm-dump (ids and workdir stripped) are identical on both binaries.
* Probe movers (drivers/dbmovers.sh, `evidence/dbmovers.txt`): **6 of 4087**, all predicted: the five conversions
  plus r10earl_repro/tf (EQUAL on both, bytes only). 14 predicted probe databases fire without moving: the
  agreement branch of § dupImportSameValueKeeps252 (13) or § impPatConcatSelReadParents252's name set (1,
  r10earl42repro/v42_overfire) fires, but no listing entry changes.
* Downstream slang lanes: 0 of 805 moved.

**Away census** (map 12's, drivers/awayrows.py on the two sweeps, chain-keyed and flat, `evidence/away_sweeps.txt`):
**0 records lost on all 16 moved databases**. Records moved toward golden per mode:

| database | toward golden |
|---|---|
| SimpleUVM | 50 |
| MiniAmiq | 15 |
| SeqDriver | 10 |
| BlackBePipeInt | 743 (744 flat) |
| Earlgrey_0_1 | 0 |
| each probe conversion | 2 or 10 |

The swapped run (law as OFF, pristine as ON; `evidence/away_sweeps_swapped.txt`) reads exactly those counts as
lost, so the census can see them.

**Canaries** (`evidence/canaries.txt`):

* `r11u107repro/canaries.sh` on surelog reads ok=48 changed=4. All four are targeted: SimpleUVM d/t and SeqDriver d/t.
* `r11u107repro/canaries.sh` on uhdm2rtlil reads ok=16 changed=0.
* `ctcan2.sh` surelog (EXPECT_UNKNOWN=1) reads FAIL on exactly the two BlackBePipeInt rows (targeted). Pristine reads PASS.
* `ctcan2.sh` uhdm2rtlil (EXPECT_UNKNOWN=6) reads PASS.

**Byte controls** (drivers/controls.sh over 31 earlier repro dirs, `evidence/controls.txt`,
`evidence/controls_summary.txt`): 4374 case-views (2187 case dirs in both views, every
line with its exit code): 86 move, 26 enter STRICT_EQUAL (r11u214dec D/g01-g03, r11u251repro decode/HP h01-h02 and
r11u253repro decode/LV lv01-lv02 in both views: the decodes of items (1) and (2); r11u250repro T/t01, t02 and
decode/B/b01, v11u238repro D/d05, r11u238repro F/f19, r11u236repro BP/bp02), none leave, and no exit code
differs. The chain-keyed away census over every mover that stays unequal (`evidence/away_controls.txt`) reads 0
lost on all of them (r11u124 cast/k14 moves in bytes only, STRICT_EQUAL on both).

**Determinism** (drivers/det.sh: three CONCURRENT harness runs of the law binary on Earlgrey_0_1, MiniAmiq,
SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and BlackBePipeInt, both modes; `evidence/determinism.txt`):
one hash per row-mode on 13 of 13 (Scoreboard testflags is SLANG_REJECT and writes no
database), each equal to the law sweep's database.

**Downstream on the cases** (drivers/dscases.py, the harness's `one()` on each case dir with each binary;
`evidence/ds_pristine.txt`, `evidence/ds_law.txt`): 109 synthesizable case dirs: pristine 106 IDENTICAL / 2 EQUIVALENT / 1 STATUS_DIFF, law the
same, no case changes its verdict (the STATUS_DIFF and EQUIVALENT ones are the same cases on both binaries).

## Rows: heads before and after (`evidence/heads_base.txt`, `evidence/heads_law.txt`)

* **SimpleUVM d/t.** Before: #203342 / #203354, 50 `work@top.UVM_*` parameters lacking golden's value
  (`UVM_ABSTRACT` UINT:16384, `UVM_CHECK_FIELDS` UINT:131075, `UVM_COMPARE` UINT:4, ...). After: STRICT_EQUAL.
* **MiniAmiq d/t, SeqDriver d/t.** The walk crosses these faces in order:
  * #87036: the foreach loop variable over a paren-less function's string-queue local. Golden binds string_typespec 3380:10.
  * #90429 / #90430: the index select chain in the copy of `m_choose_next_request`.
  * #93788: `this_type::m_typewide_sequences` loop variable, golden int_typespec.
  * #94831: the `uvm_rand_send` constraint's full name.

  Every one is cleared. The heads now (MiniAmiq #95125, SeqDriver d #95083 / t #95095) are a member reference in
  the svaunit / adpcm copy of `uvm_hdl_concat2string`. Golden binds `slice.path`'s typespec_member to a struct copy
  owned by the LAST importer, named `work@svaunit_vpi_interface.uvm_pkg::uvm_hdl_path_slice.path` (SeqDriver
  `work@top_tb...`); ours binds the package's own. Then:
  * #116544: `uvm_reg_addr_t` named `uvm_pkg::uvm_reg_addr_t` in golden.
  * #121302: the struct index of `m_mems_by_offset[uvm_reg_map_addr_range]` (the § cloneLoopVarHomeObject183
    residue its own comment names).
* **BlackBePipeInt d/t.** Before: #190646 / #190553, the imported paren-cast fold with no location. After: the
  first difference is #331795 / #331692, a DEPTH record: golden's elaborated bp_be_pipe_int listing of the imported
  `parameter bp_proc_param_s [max_cfgs-1:0] all_cfgs_gp = {...}` has a param_assign with NO Rhs, and ours writes
  the concatenation (residue 2). Every record before it agrees with golden. Faces cleared on the way:
  * #190646: the size-cast fold location.
  * #190751: the reference op span.
  * #191992 ...: 70 members' origin literal through `bp_unicore_cfg_p`.
  * #293887 ...: the lazy-ternary sums.
  * #294152 ... (103 records): the elaborated module's flat op ts references.
  * #294395 ...: the arithmetic members' left-operand spans.

## Sister-ground faces (decoded, call sites; not written)

1. **MiniAmiq #95125, SeqDriver #95083 / #95095, the new head of four row-modes** (UhdmExporter: the importer
   copy's member-reference rebinding, § cloneAggMemberOwn241's drain over `g_cloneTf241`, which re-points a
   hier_path's member at the copy's own struct members). Golden binds the member reference of the svaunit / adpcm
   copy of `uvm_hdl_concat2string` to the struct copy of the LAST importing scope (the interface
   svaunit_vpi_interface, the module top_tb). Its ref_typespec reads `work@<importer>.uvm_pkg::uvm_hdl_path_slice.path`.
   Ours binds the package's own typespec_member. Reproduced as decode/M/m01: a package function reading
   `slice.path`, re-exported by `q`, imported by an interface. #138 there already binds the interface's member;
   #74 (q's copy) does not.
2. Rggen #26477 (ModuleEmit), BuildUVMPkg #185844 (TaskFuncEmit; the live sister r11u255 bisects it), Earlgrey
   #136315 / #142988 (TypeEmit emitSyntaxExpr) and #154375 (ModuleEmit): unchanged, no law of this pass fires on
   them except § impSizeCastFoldLocated252 on Earlgrey (bytes only).
3. decode/H/h01: an out-of-body method with parentheses and two local declarations is stage 1 on both binaries
   (golden wraps the body in a begin at the first declaration); TaskFuncEmit's out-of-body body emission.

## Residues, ranked

1. The sister head above (4 row-modes). Behind it, on this ground:
   * #116544: the typedef alias name `uvm_pkg::uvm_reg_addr_t` on a bit_typespec copy.
   * #121302: a struct-index foreach in a copy, the StmtEmit § cloneLoopVarHomeObject183 residue. Golden binds a
     struct copy whose member references uhdm-cmp reads; a cheap law would move stage 1.
2. **BlackBePipeInt #331795 / #331692** (ParamEmit, the elaborated import copy of a concatenation parameter):
   golden writes the param_assign with no Rhs for `all_cfgs_gp`. The reductions S s13-s17 and decode S/d04
   (2-12 member structs, a selected and an unselected concat, ternary configs) all keep the Rhs in golden.
   Candidates not yet tested: the width (33 elements of a ~2.4 kbit struct) and an element that is itself a
   reference (`bp_unicore_cfg_p`; decode S/d03 shows the select through such an element is stage 1 on both).
3. **The home package's elaborated listing of a member-read `U = D`** (decode S/d02, S s01-s03, s05: golden's ts
   reference is bare, ours `p`). BlackBePipeInt's bp_common_pkg `bp_unicore_cfg_p` shows the parented form in
   golden, so no distinguisher is known yet. A law written for the grid moved BlackBePipeInt #90190 / #40604 away
   and was withdrawn before the law binary was frozen.
4. The definition-listing faces of the struct-pattern grid, all stage 1 on both binaries:
   * the home definition listing substitutes an unread `U = D` (decode S/d01);
   * a select through a reference element (decode S/d03);
   * module listings without a parameter port list (S s06, F f09);
   * the two-level ternary chain S s04.
5. U/u07: our definition-view fold of `$bits(T) * 2` (T a type parameter, where golden keeps the operation)
   carries into the module copies' values (ParamEmit's definition-view fold).
6. X x04 (a two-level index's span in the home listing), L l06 (an element typedef), l12 (the part-select full
   names in the copy), l13 (golden names the element class_typespec).
7. Brief items (4) to (7) not attempted, beyond what the BlackBePipeInt work touched: pass 250's residues 2 (the
   origin location in a child instance and on a continuous-assignment member read), the array-typedef shapes, D/d01,
   Y/y04; passes 248 to 238 residues; the BuildUVMPkg ground-A clusters (N0033, N0025, ...); map 15's brief; N0008,
   the value encodings, `$size` with a genvar argument.

## Process

* **BREACH.** At 16:12 the first decode shell called `$UHDM_DUMP` before the environment had been sourced in that
  shell. Bash executed decode HP h01's golden and pristine databases as scripts, with the main checkout as the
  current directory, and wrote three empty files with binary names in the main checkout's root. They were found at
  once (`git status`) and removed (`find -maxdepth 1 -type f -empty -newer ...`: exactly those three). After that,
  `git status` was clean. Every later shell sourced `/tmp/r11u252_scratch/env.sh`, which tests every tool with
  `-x` and exits otherwise; every tool call was guarded with `[ -x "$VAR" ]`.
* **Withdrawn binaries.** Each draft's breaks were found before delivery:
  * Law v1 (43c25d65) went through the firing-census sweep only. It read regressions on ParamTypespec d/t,
    uhdm2rtlil DivisionOfSize d/t and three v11u114 probe cases.
  * Law v2 (523f6ba4) passed its gate sweep. The byte controls' away census then found r11u215 I/i18 and r11u250
    T/t03.
  * Law v3 (c47e3197) passed its gate sweep. The grid's chain-keyed census then found U/u12.

  Each was refined, as described in the laws table, and every measurement in this README is the final binary's
  (ec509aa1): the firing census, the gate sweep, the grid, the controls, the away censuses and the determinism
  draws. The pristine sweep is the base's and was run once.
* **Fence.** Nothing fenced was dispatched, read or opened outside the gate sweeps:
  * The firing census used the harness's `--filter`.
  * byteverify ran on hard-link mirrors without the eight fenced databases.
  * dbmovers, the binary audit and awayrows build their path lists and filter them by `$FENCED` before opening anything.
  * Every case driver refuses a fenced path.
* No process outside this pass was signalled or listed. `pgrep -f` was used once, with a self-excluding pattern
  (`[c]ontrols.sh`), on this pass's own driver.
* Patch surface: src/ParamEmit.cpp, src/ExprEmit.cpp, src/StmtEmit.cpp, src/R252.h, tools/probe/r11u252repro/ and
  the regenerated tests/LAWS.md.

## Drivers

* `drivers/env.sh`: the pins and the fence. `drivers/case.sh`: one case, both producers. `drivers/grid.sh`: the grid.
* `drivers/controls.sh`: the byte controls. `drivers/tracesweep.sh`: the firing census.
* `drivers/bvmirror.sh`: fence-filtered mirrors. `drivers/dbmovers.sh`: probe and downstream movers.
* `drivers/awayrows.py`: the sweep away census. `drivers/awaychain.py`: chain-keyed, one case.
* `drivers/awaydump.py`: order-blind dump lines. `drivers/awayctl.sh`: all moving case-views.
* `drivers/det.sh`: determinism. `drivers/dscases.py`: downstream on cases. `drivers/gridsum.py`: the grid summary.
* `drivers/cc_x.sh` + `strictcmp_x.cpp`: the variant comparator awayrows reads.
