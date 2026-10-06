# r11u257: pass 257, the module/type ground (refill after pass 255)

Base 5f1da483. Seven laws in TypeEmit, ModuleEmit and UhdmExporter behind `src/R257.h`. Each law reads its own
`R11U257_<LAW>_OFF` switch, and `R11U257_OFF` drops all seven. `R11U257_TRACE=<dir>` logs every firing, one file
per process: the first line is `OUT <-o path>`, then one `<law> <detail>` line per firing.

**Verdict:** no corpus row converts. Five probe cases convert. Three corpus row-modes move later in their walk:
* Rggen d: fullname(199) -> col(129). Every record on this ground is cleared, and the new head #27671 is on the
  sister ground.
* Earlgrey_0_1 d: fullname(155) -> (139). Earlgrey_0_1 t: fullname(50) -> (34). The same first records
  #136315 / #137760 stand, and 16 records per mode are cleared.

The first-writer determinism defect v11u255 found is fixed. The skipped kind-changing typedef, v11u255 F/vf02,
goes to STRICT_EQUAL in both views.

## 1. Binaries and gates

Both binaries were built in `/tmp/wt_r11u257` with `-j 2` and the system deps, then frozen before any measurement:
* pristine `771d2315d253e6fafc91b9df9e2cc1f8`, the same md5 as the main tree's build;
* law `cadde10535fddb43936f591a8c8bf08c`;
* both link slang 12.0.0+545f88b2e.

An earlier law binary, `b037f731…`, is superseded; section 6 says why. Every number below is for the final binary.

The gate sweeps ran `tests/sweep.sh --jobs 3`, with workdirs `/tmp/r11u257_wP` and `/tmp/r11u257_wL`. The
fence-filtered summaries and the row diff of the csvs are in `evidence/sweeps/`.

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3547 + STRICT_NOTEQUAL 540; regressions=0 | EQUAL 3552 + STRICT_NOTEQUAL 535; regressions=0, **conversions=5**, changes=0 |
| surelog | 937 + 17; regressions=0 conversions=0 changes=0 | regressions=0 conversions=0 **changes=3** |
| uhdm2rtlil | 1606 + 0; regressions=0 | the same; changes=0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; the csv is byte-identical to pristine's |

**The five probe conversions** (fresh rows from the law sweep; results/ untouched):

```
r10rggen6repro/t4,EQUAL,,equal                    (was differ:endcol(4);   § genLpFoldLeftOperandSpan257)
r10rggen6repro/t5,EQUAL,,equal                    (was differ:endcol(16);  § genLpFoldLeftOperandSpan257)
r11u112repro/grid/f/g09_for_lp_sub,EQUAL,,equal   (was differ:fullname(1); § defGenLhsSelIdxThroughBase257)
r11u112repro/grid/f/g18_hop_lhs,EQUAL,,equal      (was differ:fullname(1); § defGenLhsSelIdxThroughBase257)
r11u46repro/grid2,EQUAL,,equal                    (was differ:fullname(1); § defGenLhsSelIdxThroughBase257)
```

**The three corpus changes** (fresh rows from the law sweep):

```
Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(139),,differ:fullname(139)    (was fullname(155))
Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(34),,differ:fullname(34)    (was fullname(50))
Rggen,default,STRICT_NOTEQUAL,differ:col(129),,differ:col(129)                      (was fullname(199))
```

* **Earlgrey_0_1 d/t.** The first records are unchanged: #136315 / #137760, ground A (§ sysFuncArgFold). The count
  shrinks by 16 per mode. § implicitPortTsFirstDim257 clears padring #190726 / #190744 and the elaborated
  #351141 / #351150 / #351249 / #351259. § defGenLhsSelIdxThroughBase257 clears the ten prim_present gen-block `k`
  records #214166 to #214360.
* **Rggen d.** This is a first-field change. The old head #26477 is cleared, and so are all 44 interface port-view
  full-name records (§ ifacePortMemberHighConnParent257) and the 26 constant endcol records #26718… (§
  genLpFoldLeftOperandSpan257). The new head is **#27671**: the first path element of a macro-expanded left-side
  `bit_field_if.read_data[0+:4]`. Golden is at 7:24-33 and ours at 7:11-23. It is ExprEmit, ground A (section 5).
  All 128 remaining col records are that one face.
* Every other STRICT_NOTEQUAL row keeps its head and its count, as the csv diff shows: SimpleUVM, MiniAmiq,
  SeqDriver, BuildUVMPkg, BlackBePipeInt, and the known failures.

**Other checks:**
* **byteverify**: `tools/probe/r11v75repro/byteverify.sh`, run through fence-filtered hard-link mirrors
  (`drivers/bvmirror.sh`; 8 fenced databases skipped per sweep; `evidence/byteverify_corpus.txt`).
  * **7 of 2560 move**: Earlgrey_0_1 d/t, Rggen d, OneNetModPort d/t (surelog) and OneNetModport d/t (uhdm2rtlil).
  * PATH_SETS_IDENTICAL. SELFCHECK flags 2559 of 2560.
* **Probe bytes** (`evidence/probe_movers.txt`; the path list was filtered by `$FENCED` first): **7 of 4087 move**.
  They are the five conversions plus r10rggen9repro/t8 and t9, which are EQUAL on both binaries
  (§ ifacePortMemberHighConnParent257).
* **Downstream slang-lane bytes**: 1 of 805 moves, OneNetModport. Its verdict is IDENTICAL on both binaries.
* **uhdm-cmp** on all 7 corpus movers: 0 lines (`evidence/off_corpus.txt`).
* **R11U257_OFF** gives pristine's md5 on all 7 corpus movers (`evidence/off_corpus.txt`).
* **Firing census** (`drivers/tracecensus.sh`, run with the law binary before the law sweep, the harness dispatching
  with the filter built from `$FENCED`; frozen as `evidence/predict.txt`): 24 corpus row-modes and 40 probe
  databases. Every mover is named in it. Those that fire without moving:
  * **The five UVM rows** (BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d) hit
    § fwWinnerSpecTieBreak257's tie. The rule picks the specialization pristine already picked on them.
  * **uhdm2rtlil StreamOpImplicitSliceSize, ibex_alu, ibex_register_file_ff and ibex_wb_stage d/t**, and 29 of the
    32 probe databases where § defGenLhsSelIdxThroughBase257 fires. These are targets with a literal index
    (`t[0]`): the prefix changes, but there is no reference under it to rename.
  * Four probe databases fire § fwWinnerSpecTieBreak257 without moving.
* **Away census** (`drivers/awaycorp.sh`, chain-keyed records against the cached golden; `evidence/away_corpus.txt`):
  * Earlgrey d: `dist 1032 -> 996 lost=0 gained=36`;
  * Earlgrey t: `764 -> 728 lost=0 gained=36`;
  * Rggen d: `811 -> 523 lost=0 gained=288`;
  * OneNetModPort / OneNetModport: `0 -> 0`.
* **Canaries**:
  * `tools/probe/r11u107repro/canaries.sh`: surelog `ok=50 changed=2`, the two Earlgrey rows; uhdm2rtlil
    `ok=16 changed=0`;
  * `ctcan2.sh` (EXPECT_UNKNOWN=1 / 6): PASS on both corpora.
* **Binary-path audit** (the path list filtered by `$FENCED` first): 3265 of 3265 `slang:` lines per sweep name that
  sweep's frozen binary.
* **Determinism**: `drivers/det.sh`, three concurrent harness draws per round, three rounds (`evidence/det_law.txt`).
  * Ten draws per row-mode, counting the sweep, give one hash per row-mode on 11 of 11.
  * The rows are Earlgrey_0_1 and the five UVM rows in both modes; Scoreboard testflags writes no database.
  * Every hash equals the law sweep's.
* **The law index**: `scripts/law_index.py` was regenerated last, and `--check` reads current.

## 2. The laws

| law | file, site | switch | what it does |
|---|---|---|---|
| § fwWinnerSpecTieBreak257 | TypeEmit `collectFwWinners98` | R11U257_FWSPEC_OFF | Specializations of one generic class tie under the generic's claim key. Among them, the smallest parameter rendering wins, an order that does not depend on the run. |
| § fwWinnerSpecKind257 | TypeEmit `fwWinnerTs98` | R11U257_FWKIND_OFF | The winner's own typedef object may not be the one its generic's class_defn lists, while a specialization of the same declaration has a listed object of another kind. In that case the listed object is handed out. |
| § ifacePortMemberHighConnParent257 | UhdmExporter design-final, after § fwWinnerListedObject255 | R11U257_IFPORTHC_OFF | A member of an interface port, written as a child instance's port actual, is re-parented at that child port. The variable belongs to the port-view interface_inst; the last writer in source order wins. The stored full names on the variable and its ref_typespec are dropped. |
| § genLpFoldLeftOperandSpan257 | ModuleEmit, § genLpTsFoldBounds's fold | R11U257_GENLPLEFT_OFF | The folded binary bound of a generate-block localparam's packed range sits at its left operand as written, parentheses included. |
| § genLpFoldAddUint257 | the same site | R11U257_GENLPADD_OFF | That fold is encoded UINT for an add whose operands do not reduce to INT, reduceExpr's table. |
| § implicitPortTsFirstDim257 | TypeEmit `makeTypespec`, the implicit-dims location | R11U257_IMPLDIM1_OFF | A data type written as packed dimensions alone, with no net keyword, is located at its first dimension. |
| § defGenLhsSelIdxThroughBase257 | TypeEmit `emitSyntaxExpr`, the bit_select and indexed_part_select branches | R11U257_DGLHSIDX_OFF | On a definition-view generate continuous assignment's target, a non-identifier index scopes its references through the select's name. An indexed part select spans its name through the closing bracket. |

### § fwWinnerSpecTieBreak257 (item 1)

**Decode.** v11u255 section 4 found that `collectFwWinners98` gives every specialization the generic's `TdClaim11`.
The strict `<` then keeps whichever comes first in slang's `specializations()` order, which is an unordered map, so
the order changes from run to run. A non-default winner makes `fwWinnerTs98` build an unparented twin. With
§ fwWinnerListedObject255 the dumps agree across draws, but the twin's bytes do not.

Surelog has one TypeDef per declaration (`ElaborationStep::bindTypedefs_`), so any specialization of the same
declaration is the same answer. The tie is now decided by a key that does not depend on the run: each
specialization's parameter values and type-parameter targets, rendered as text. The tie is traced at every decision,
whichever way it goes.

**The first draft was withdrawn.** It made `fwWinnerTs98` return the class_defn's listed object directly. That broke
r11u255repro F/f05 (STRICT_EQUAL -> stage 1, 61 lines, both views). A package-level out-of-body definition stamps
the package `vpiInstance` on the typespec it binds. Golden's listed object carries none, and under
§ fwWinnerListedObject255 the stamp landed on the twin. The draft was found by the byte controls. The listed-object
hand-out now applies only when the kind differs (§ fwWinnerSpecKind257).

**Proof** (`evidence/nondet.txt`, 10 concurrent draws per case-view):

| case-view | pristine hashes | law + R11U257_OFF hashes | law hashes |
|---|---|---|---|
| v11u255 F/vf03 def / el | 2 / 2 | 2 / 2 | 1 / 1 |
| v11u255 F/vf05 def / el | 2 / 2 | 2 / 2 | 1 / 1 |
| v11u255 F/vf08 def / el | 2 / 2 | 2 / 2 | 1 / 1 |
| F/f10_header def / el | 2 / 2 | 2 / 2 | 1 / 1 |
| F/f11_crlf def / el | 1 / 2 | 2 / 1 | 1 / 1 |
| F/f12_unit_scope def / el | 2 / 2 | 2 / 2 | 1 / 1 |

In every row the law's one hash is one of the pristine draws. For f11, both draw sets come from the same two hashes.
The UVM rows read one hash in 10 draws (section 1).

### § fwWinnerSpecKind257 (item 1, second half)

v11u255 F/vf02 has `typedef T this_type` in `aa_reg #(type T=int)`, and only `aa_reg #(byte)` is made. Golden binds
the declaration's listed `int_typespec` 4:23, and ours bound the `byte_typespec` 12:12.

The law makes vf02 STRICT_EQUAL in both views. On the F cases f01 to f04 and f09, the first record (the formal) is
cleared. The next record stays, and section 5 lists it.

### § ifacePortMemberHighConnParent257 (item 2, Rggen #26477)

**Decode.** `NetlistElaboration::high_conn_` (third_party/Surelog/src/DesignCompile/NetlistElaboration.cpp) compiles
the actual with `Reduce::Yes`. `register_if.access` through a modport port reduces to the member variable of the
parent's port-view interface_inst, and `p->High_conn(hexpr); hexpr->VpiParent(p);` re-parents that shared object at
the child port. The modport io_decl lists the same object, so golden's walk reads
`...u_register_common.g_decoder[0].u_decoder.i_access.access`.

The grid (cases R) pins down which shapes re-parent:
* last writer: r06, r11;
* positional connection: r07;
* two module instances: r10;
* passed down two levels: r12;
* interface array element: r13;
* instance inside a generate block: r14;
* an interface INSTANCE member does not reduce: r03, equal on pristine;
* a concatenation or select keeps its own expression: r05.

The port-view variable is found by name and kind among the enclosing instance's port views. Several candidates are
told apart by the bound instance's name path; the getter is never called, because it caches a computed full name.

### § genLpFoldLeftOperandSpan257 and § genLpFoldAddUint257 (Rggen #26718)

§ genLpTsFoldBounds' own comment said "at the operation's own span". Golden puts it at the left operand: Rggen 33:24-37
`ADDRESS_WIDTH` of `ADDRESS_WIDTH-1`. That is the same anchor TypeEmit's range builder uses everywhere else.

Cases RC:
* c01, c02, c04, c06, c08, c09, c10 go to STRICT_EQUAL in the elaborated view.
* c05 `[AW+1:0]` needs the UINT encoding as well (golden `UINT:9` ct 9).
* c03, the module-level control, does not move.

The default views of c04 to c10 are stage 1 on both binaries, on a separate initializer face. On c05 default the
stage-1 head moves later and the uhdm-cmp log grows 36 -> 52 lines: the old head, the bound constant, is gone, and
the next block printed is the cast operation. This is the only uhdm-cmp line count that rises anywhere, and the
away census reads lost=0 on it.

### § implicitPortTsFirstDim257 (Earlgrey #190726 / #190744)

Golden's logic_typespec for `input [NMioPads-1:0][AttrDw-1:0] mio_attr_i` spans 40:16-30. Cases P2 cover:
* ANSI, non-ANSI and multi-line ports;
* three dimensions;
* output and signed ports;
* function and task formals with a direction;
* interface and program ports.

All of them go to STRICT_EQUAL in both views. The controls do not move: `logic`, `wire`, one dimension, and a
module-body `wire`.

### § defGenLhsSelIdxThroughBase257 (Earlgrey #214166 to #214360)

A definition-view generate target is a net_lvalue compiled by compileSelectExpression. That writer stores no full
name on an index's references, so `BaseClass::ComputeFullName` reads them through the select. A bit_select parent is
skipped only for a direct ref_obj child, so a bare (or parenthesized) identifier index stays scope-level.

Cases G:
* g01 (prim_present's shape), g02, g04, g07, g08, g10, g11 and g12 go to STRICT_EQUAL in both views; g14 does in
  the elaborated view.
* The controls do not move: g03 (identifier index), g05 (right side), g06 (part select, which already scoped
  through the base), g09 (two selects).

## 3. The grid (`drivers/grid.sh`, `evidence/grid.txt`, `evidence/gridsum.txt`)

The grid has 85 cases in both views on 10 configurations: pristine, law, law + R11U257_OFF, and the law with each
switch off. The cases are this pass's 64 (F, G, P2, R, RC), v11u255repro F (9) and r11u255repro F (12).
* 1700 lines, every line with its exit code, every exit 0.
* 170 case-views; 111 moving; **65 entering STRICT_EQUAL; none leaving**.
* `R11U257_OFF` gives pristine's bytes on 163 of 170. The other 7 are the first-writer nondeterminism in pristine,
  section 2's table.
* Every moving case-view moves back under its own law's switch, with two kinds of exception (gridsum's `-`):
  * the pristine-nondeterministic F cases, whose single pristine draw is one of two hashes;
  * f09, which either fwWinner law alone brings to the same bytes.
* **Away census** (`drivers/awayall.sh`, record multisets, or uhdm-dump line multisets on stage-1 views;
  `evidence/away_grid.txt`): **lost=0 on all 111 movers**.

**Downstream on the cases** (`drivers/dscases.py`; `evidence/ds_P.txt`, `ds_L.txt`), 52 cases (G, P2, R, RC):
* 48 IDENTICAL on both binaries;
* 4 EQUIVALENT on both: c07, r05, r08, r09, "no common assign statements";
* no verdict changes.

**Decode cases** (`decode/`, `evidence/decode.txt`): the ground-A faces of section 5. They do not move.

## 4. Byte controls (`drivers/controls.sh`, `evidence/controls.txt`)

The controls cover 21 earlier repro dirs, 1519 cases and 3038 case-views on pristine and law:
* pass 118: r11u118repro, r11v11u118repro;
* pass 119: r11u119repro;
* pass 120: r11u120repro, r11v120repro;
* pass 124: r11u124repro, r11v124repro;
* pass 125: r11u125repro;
* pass 130: r11u130repro;
* pass 131: r11u131repro, r11v131repro;
* pass 255: r11u255repro, v11u255repro;
* the first-writer law: r11u98repro, r11v98repro;
* the definition-view generate path: r11u161gen;
* the modport member: r11u239repro;
* the bind port references: r11u251repro;
* the definition-view generate target anchor: r11u144repro;
* the definition-view generate initializer: r11u202repro;
* the implicit argument dimensions: r11u155repro.

The exit codes are identical on both binaries. 21 case-views exit non-zero on both, including
r11v124repro hx/x02_forstep_el, which segfaults with rc 139 on both.

**29 case-views move. Two enter STRICT_EQUAL (v11u255 vf02 in both views) and none leave.** The movers by law:
* **§ defGenLhsSelIdxThroughBase257** (an indexed part select target): r11u118 g1/p30_genfor, r11v11u118
  v1/v14_genfor_plain, v1/v30_vs_genfor and v3/x06_ps_pkgbound_genfor, both views. They are stage 1 or fullname on
  both binaries. The away census gains 2 to 4 per view and loses 0.
* **§ ifacePortMemberHighConnParent257**: r11u155 IC/i07 and r11u202 IM/f02, both views. They are STRICT_EQUAL on
  both binaries.
* **§ fwWinnerSpecTieBreak257 / § fwWinnerSpecKind257**: r11u255 F/f01, f02, f03, f08 and v11u255 vf01, vf06,
  vf08 (el) and vf09. The verdict is the same on both binaries: the twin's bytes now come from one fixed
  specialization. vf02 enters STRICT_EQUAL.

Away census over all 29 (`evidence/away_controls.txt`): **lost=0**.

## 5. Residues, ranked

1. **Rggen d #27671, the new head (ground A, ExprEmit).** The 128 col records come from macro-expanded left sides
   `RIF.read_data[LSB+:WIDTH]`. Golden puts the path's first ref_obj at the member name's span in expanded
   coordinates (7:24-33); ours puts it at the actual's (7:11-23). It applies only to an indexed part select target
   inside a macro body: the right side, a bit select and a plain member are equal (decode/HL h01 to h09).
   * Call site: ExprEmit's hier_path select-chain branch, the indexed_part_select element of the left-side chain
     (§ selChainElemShapeIsSyntactic147's routing).
   * Then #92960 (walk diverged): a generate-block unpacked-array localparam's param_assign array_typespec lists its
     range before the element ref_typespec in golden. That is § genLpUnpackedArray, ModuleEmit, this ground, not
     attempted.
2. **Earlgrey_0_1 records on ground A** (behind #136315 / #137760, § sysFuncArgFold, and #154375 / #165002,
   § selFold9):
   * #193018: a package parameter folded as a replication count inside a named always_ff block. Golden names the
     ref_typespec `work@pinmux`; ours names it `work@pinmux.p_sleep` (decode/EG e01; ExprEmit's
     § stampFoldedPkgParamTs family).
   * The rstmgr records #233633 onward: the same naming on an indexed-part-select width fold, `work@rstmgr_ctrl`
     against `work@rstmgr_ctrl.rst_req_i`.
   * #214553 / #346618 / #214684 / #214818: package-qualified `prim_cipher_pkg::PRINCE_ROUND_CONST` selects
     (ExprEmit).
   * #375033 / #392938: elaborated part_select full names missing their generate scope.
   * #395727: an enum_const without a file.
3. **§ fwWinnerSpecKind257's next record** (F/f01 to f04, f09; wrong on pristine too). A function RETURN written as
   the inherited bare typedef name builds an anonymous class_typespec at the return token. Golden binds the winner.
   The return branch (TaskFuncEmit § classTdRetSharesTypedefTs200) does not ask § bareTdNameFirstWriterWins98.
   * f12_unit_scope: the same record.
   * f08 (struct default, int specialization) is stage 1 on both binaries.
4. **§ ifacePortMemberHighConnParent257's open shapes**:
   * a member inside an operation (R r09): golden re-parents the operand too, and our operand is a hier_path where
     golden's is the reduced variable, so a different object;
   * a wire member (r08, stage 1 on both);
   * a generic interface port (r04, a separate depth face at the io_decl);
   * our port high_conn object is the top-level instance's variable where golden's is the port view's. The strict
     walk does not list it, and it was not changed, so the downstream reading stays as it is.
5. **§ genLpFoldLeftOperandSpan257's open shapes**: the default views of RC c04 to c10, an initializer cast fold face,
   and c07, two dimensions with a param_assign constant face. Both are stage 1 on both binaries.
6. Pass 255's residues (3) were not attempted, apart from what § defGenLhsSelIdxThroughBase257 now covers on the
   target side (E/e06 and e08 are elaborated, not this law). Items (4) to (7) of the brief were not attempted.
7. **Sister-ground faces to report**, as the brief lists them and unchanged: BuildUVMPkg #194627 (ExprEmit
   § shellCallKeepsItsSyntax167), Earlgrey #154375 / #165002 (§ selFold9) and #136315 / #137760
   (§ sysFuncArgFold), SimpleUVM #203342 (ParamEmit's imported-parameter mint), MiniAmiq / SeqDriver #87036
   (StmtEmit), BlackBePipeInt #190646 (ParamEmit importedFold).

## 6. Process

* **The fence.** Nothing fenced was dispatched, read or opened outside the gate sweeps.
  * The fence names come from `tools/probe/r11u107repro/canaudit.sh`'s FENCED= line (`drivers/env.sh`, fail-closed).
  * Every corpus path list (the byteverify mirrors, the probe and downstream byte lists, the cmds.txt audit, the
    Rggen and Earlgrey source reads, the controls) was filtered by `$FENCED` before any file was opened.
  * The firing census ran through the harness with the filter built from `$FENCED`.
  * The evidence csvs have the fenced rows removed.
* **Processes.** No process was listed or signalled. Waits tested files.
* **Tools.** Every tool variable was checked with `[ -x ]` before use.
* **The superseded law binary** (`b037f731…`) returned the listed object for every same-kind winner. Its byte
  controls showed r11u255 F/f05 leaving STRICT_EQUAL. The law was rewritten as the tie-break plus the kind-only
  hand-out, rebuilt, and everything above was re-measured on the final binary: the census, the gate sweep,
  byteverify, the OFF check, the grid, the controls, the away censuses, determinism and downstream.
* **A case renamed.** The G case headers carried a draft law name; they were renamed before
  delivery. The first-line edits change no database.

## Files

* `cases/`, one law per case's first line:
  * F: § fwWinnerSpecTieBreak257, § fwWinnerSpecKind257;
  * G: § defGenLhsSelIdxThroughBase257;
  * P2: § implicitPortTsFirstDim257;
  * R: § ifacePortMemberHighConnParent257;
  * RC: § genLpFoldLeftOperandSpan257, § genLpFoldAddUint257.
* `decode/HL`, `decode/EG`: ground-A decodes.
* `drivers/`:
  * `env.sh`, `case.sh`, `grid.sh`, `gridsum.py`, `nondet.sh`, `tracecensus.sh`, `det.sh`, `controls.sh`,
    `bvmirror.sh`, `awaycorp.sh`, `away.py`, `awaydump.py`, `awayall.sh`, `dscases.py`;
  * every reader is fail-closed on `$FENCED`.
* `evidence/`: as cited above.
