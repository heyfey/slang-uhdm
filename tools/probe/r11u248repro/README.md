# r11u248: the expression/parameter ground, pass 248

Base 910f9474 (pass 246 on top of pass 247). Ground: src/ExprEmit.cpp, src/StmtEmit.cpp, src/ParamEmit.cpp and the new
switch header src/R248.h. Four laws, each behind its own switch; `R11U248_OFF` drops all four and gives pristine bytes
on every case-view and on every corpus mover. A dead early return in § macroParamMethNameEnd246 is removed with its
comment corrected; this changes no bytes.

## Verdicts on the targeted rows

| row-mode | base (results/golden_surelog.csv) | after (fresh law sweep) | laws |
|---|---|---|---|
| MiniAmiq default / testflags | `differ:type(1)` #78478 | `differ:fullname(5)` #79121 | § cloneDotLoopVarBaseNoDrill248 clears #78478; § cloneWithOperandChainName248 clears #79206 / #79207 / #79227 / #79228 and the unsync twins (8 records); § cloneLoopVarClassPropStringTs248 clears #83613 |
| SeqDriver default / testflags | `differ:type(1)` #78434 / #78446 | `differ:fullname(5)` #79078 / #79090 | the same three laws |

The fresh csv rows:

```
MiniAmiq,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
MiniAmiq,testflags,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
SeqDriver,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
SeqDriver,testflags,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
```

No row converts. These are first-field changes, and each old head is cleared:

* #78478 `next_pred`'s home object now binds golden's unlocated `int_typespec`.
* Three heads were measured with `uhdm-strictcmp --max 20` on interim binaries: `type(1)` -> `fullname(13)` (#79121 and the
  with-clause names) -> `fullname(5)` (#79121, #79122, #79458, #79459, then #83613) -> `fullname(5)` with #83613 cleared.
* The walk now reaches #87013 (MiniAmiq) and #86971 (SeqDriver), which are on the sister ground (below).

Chain-keyed away census against pristine ([census/away_law.txt](evidence/census/away_law.txt)):

* MiniAmiq: away 0, toward 60 per mode;
* SeqDriver: away 0, toward 40 per mode.

The swapped run is the positive control ([census/away_swapped.txt](evidence/census/away_swapped.txt)): it reads the
same numbers as away.

## The laws

### § cloneDotLoopVarBaseNoDrill248 (`R11U248_CLONEDOTBASE_OFF`; StmtEmit, the § cloneLoopVarHomeObject183 branch)

In an importer copy, the shared home object of a loop variable can belong to a DOTTED loop list (`foreach
(x.m_pred[nx])`) whose base is an enclosing foreach's loop variable. If that base's home object binds neither a
class_typespec nor a struct_typespec, the home object takes a fresh unlocated `int_typespec`. This is the home listing's
§ dottedForeachLoopVarBaseMustDrill137 answer:

* decodeHierPath answers nothing for that base;
* UhdmWriter swapForSpecifiedVar then mints the bare int_var + int_typespec.

The home object used to carry the member's index typespec instead. Two kinds of base are not changed:

* a base whose home object is still the unsupported placeholder;
* a class_var or struct_var base (controls c03, c07).

The UVM site is `uvm_phase::get_predecessors_for_successors` with `output bit pred_of_succ[uvm_phase]`. Its loop variable
`pred` is a bit_var in golden's home listing, so `foreach (pred.m_predecessors[next_pred])` falls to int.

### § cloneWithOperandChainName248 (`R11U248_WITHCHAIN_OFF`; ExprEmit array-method `with`, drained design-final from ParamEmit after `fwdPkgRefClassScopeSpanDrain227`)

This law applies in the DEFAULT view's importer copy. Every ref_obj, bit_select, part_select and indexed_part_select
under an array method's `with` expression whose stored full name is `<prefix>::<name>` takes the receiver chain
`<prefix>::<receiver text>::<name>`. This is the same chain the written iterator argument already reads
(§ arrayMethodIterArg). For example, golden writes `svaunit_pkg::uvm_phase::sync::from_node.m_sync::to_node`.

* Under a nested `with`, the outer receiver joins in front of the inner chain (`q::c::f::m_v::m_v::t`, case w07).
* Path elements written with no full name keep none.
* The --elabuhdm view and the home listing keep the subroutine-scoped name: every `_el` case-view is STRICT_EQUAL on
  pristine and is byte-unchanged.

### § cloneLoopVarClassPropStringTs248 (`R11U248_CLONEPROPSTR_OFF`; StmtEmit, beside § cloneLoopVarClassPropArrayTs238)

This is the STRING half of § cloneLoopVarClassPropArrayTs238. In an importer copy, `foreach (m_name[i])` over a class
property that is a plain `string` gives the shared home object the property's own string_typespec, located at the written
`string` keyword. This is what § foreachClassPropStringTsShared238 decodes for the home listing. Golden writes
`uvm_component::get_depth::i` at 1664:3.

* If the property's typespec is bound only by the class listing's drain, the object is mirrored through
  pendingLoopVarTs9. A miss falls back to pristine's unsupported placeholder, which ParamEmit drainShareDefParamTs
  creates with tag `_miss`.
* The gate is pass 238's.
* A typedef'd string property keeps the placeholder (control s03). Golden binds the typedef there, and ours names it
  `p::str_t`.

### § callArgCopyReduceOpModel248 (`R11U248_PAREDUCE_OFF`; ExprEmit `callArgCopyOpaqueStep248` inside `callArgCopyLpReduced246v`)

This is brief item (2), refining pass 246's conservative syntax scan with a model of UHDM `ExprEval::reduceExpr`. The
scan's structural one-select default ("Surelog reduces `L[k]` outside procedural blocks") now also asks whether the
reference sits under an operator reduceExpr has no case for, or inside a range selector. If it does, the reference is not
reduced, evalFunc never runs, and § callArgParamCopyOwnTs246's copy keeps the parameter's own typespec.

* Operators reduceExpr does not handle: binary `^`, `~^`, `===`, `!==`, `==?`, `!=?`, `->`, `<->`.
* Range selectors: `[a:b]`, `[a +: w]`, `[a -: w]`.

Unchanged by the model:

* a single bit index stays reduced (r04 `o[1][L[0]]`, pristine and law STRICT_EQUAL);
* every structural context the 246v scan names (dimension, replication, generate, task or function body) keeps
  abstaining, including `logic [L[1] ^ 8'd3:0]` (r10);
* a module that also reduces another reference keeps abstaining as a whole (r14).

### Cleanup in § macroParamMethNameEnd246 (no switch, no byte change)

The early return that compared the start's source text with the name is removed. `SourceManager::getSourceText` returns
an empty view for a macro buffer, so the return never fired (v11u246). The comment now states what the code does. All 16
MN case-views (r11u246repro and v11u246repro) are byte-identical before and after.

## Grid ([grid/grid_main.txt](evidence/grid/grid_main.txt), [grid/grid_summary.md](evidence/grid/grid_summary.md))

There are 40 cases in both views, so 80 case-views. Each runs on pristine, law, law + `R11U248_OFF` and law + each
switch: 560 lines, every line carrying its exit code. Every case names its law in its first line.

| group | law | cases |
|---|---|---|
| C c01-c09, d01_decode247 | § cloneDotLoopVarBaseNoDrill248 | output/ref/input/inout assoc formals with bit/int/string elements; class-, int-, string-indexed, queue and fixed member arrays; a two-level chain; a free package function; this. paths and a class specialisation; controls: class element (c03), local and property assoc (c04), struct element (c07), no importer copy (c08); r11u247's decode d01 |
| W w01-w11 | § cloneWithOperandChainName248 | find_index / find / find_first with and without a written iterator; nested with; a select receiver; this. receivers; a macro-born call; constant slots (part-select bounds, indexed width, replication); system, function (named argument) and method calls in the with; an implicit net; control w04 (module-scope class, no copy) |
| S s01-s06 | § cloneLoopVarClassPropStringTs248 | protected, local, static and this. string properties; inherited and dotted; constant slots in the body; controls: typedef string (s03), home package imported at $unit (s05) |
| R r01-r14 | § callArgCopyReduceOpModel248 | |, &, ~^, a bit index, <<, concatenation, ?:, ~, ===, ==?, xor in a dimension, xor under ?:, an indexed base, a reduced reference beside an xor |

Results:

* `R11U248_OFF` gives pristine bytes on **80 of 80** case-views.
* **26 case-views enter STRICT_EQUAL and none leave it.** No uhdm-cmp line count rises. Every exit code is 0.
* Each switch reverts exactly its own group's moved cases and nothing else.

Moved case-views that stay unequal:

* C c09: an endcol head on the class-specialisation typespec, sister ground. Chain-keyed census 0 lost.
* W w09: `differ:fullname` -> `differ:type` at #115, the indexed-part-select operand `lim` in a copy. Golden binds the
  home int_var and ours does not; the same record stands on pristine behind its fullname head. 8 toward, 0 lost.
* Stage-1 shapes (W w06, w11; S s04; R r03, r11): order-blind dump census
  ([drivers/awaydump.py](drivers/awaydump.py)) 0 lost on w06, w11, r03 and r11, each gaining the golden record.
  * S s04 and the control v11u238 E e01 / e02 lose a context-free `|vpiParent:` dump line. That line is the
    unsupported placeholder's own parent block, which a shared string_typespec does not print.
  * The gained line on each of these is golden's `string_typespec`.

Downstream on all 40 cases (the harness's own `one`): pristine and law give the same verdict per case, 37 IDENTICAL and 3
DIVERGENT. The 3 are R r03, r11 and r14, the xor shapes, which are DIVERGENT on pristine too, as v11u246's PE e20 is.

Reduce-model detail: of v11u246's PE cases, only e15, e16 and e20 move.

* e15 and e16: 3 -> 2 records from golden in both views, 0 lost.
* e20: stage 1 on both binaries, 0 lost.
* The 46 other PE case-views are byte-identical: e01-e14, e17-e19 and e21-e26, both views.
* R r09, r12 and r13 enter STRICT_EQUAL in both views.

## Byte controls ([grid/controls.txt](evidence/grid/controls.txt))

There are 693 cases from 12 earlier repros (r11u246, v11u246, r11u247, v11u247, r11u244, v11u244, r11u238, v11u238,
r11u183, r11u118, r11u119, r11u120), each in both views on pristine and law: 2772 lines with exit codes. Non-zero exits
are identical on both binaries:

* r11u244 F/f19, rc 3;
* rc 4: r11u244 X/x02, r11u246 DT/d12_v11, v11u238 D/d01_tdqueue, v11u246 LN/v04_ifcbody.

The moving case-views, all attributed:

* r11u247 decode/d01, both views: enters STRICT_EQUAL (§ cloneDotLoopVarBaseNoDrill248).
* v11u246 PE e15, e16 and e20, both views (§ callArgCopyReduceOpModel248).
* v11u238 C/c02_clone, both views: `type` -> `name`, a class_typespec name on the sister ground. Chain-keyed census 2
  toward, 0 lost (§ cloneLoopVarClassPropStringTs248).
* v11u238 E/e01_mixed and e02_this_paths, both views: stage 1 on both binaries, 1 golden `string_typespec` gained
  (§ cloneLoopVarClassPropStringTs248).

## Gates (law binary md5 51a675644dac5543ff49eee50200bf38; pristine d648893fb282dbd79047ec841d57b894, equal to the main tree's build)

* **Sweeps.** [sweeps/sweep_pristine.txt](evidence/sweeps/sweep_pristine.txt) and
  [sweeps/sweep_law.txt](evidence/sweeps/sweep_law.txt), with `tests/sweep.sh --jobs 3` and the workdirs /tmp/r11u248_wP
  and /tmp/r11u248_wL (same length).
  * probe: 3539 EQUAL + 548 STRICT_NOTEQUAL, regressions 0, conversions 0, changes 0.
  * surelog: 470 + 10 / 466 + 8, regressions 0, conversions 0, changes 4 (the four rows above).
  * uhdm2rtlil: 803 per mode, 0/0/0.
  * downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0.
  * The law sweep's exit 1 is the law-index staleness check alone. Cases were moved after the index was regenerated; it
    is regenerated again in the patch.
* **cmds.txt audit** (fence-filtered path list):
  * every database of the pristine sweep from /tmp/r11u248_bin/pristine (3265);
  * every database of the law sweep from /tmp/r11u248_bin/law (3265).
* **byteverify.** With `SELFCHECK=1` ([sweeps/byteverify.txt](evidence/sweeps/byteverify.txt)), the path sets are
  identical (3373) and the movers are 4 of 3373: MiniAmiq d/t and SeqDriver d/t.
  * SELFCHECK reads 3371 of 3373, not 3372. The reference file is `downstream/1DUnpackedArray/slang.uhdm`, and
    `uhdm2rtlil/testflags/1DUnpackedArray-*/slang.uhdm` is byte-identical to it: the same command line produces both. So
    two paths compare equal to the reference by construction (pass 201's artifact). The script exits 5 on that reading,
    which is not a mover.
  * The probe databases, which byteverify does not list, were compared separately: 0 of 4087 move, and the probe
    self-check flags 4086 of 4087.
* **Prediction.** It was frozen before the law sweep ([census/predicted.txt](evidence/census/predicted.txt), 10:20:34).
  It comes from the firing census with `R11U248_TRACE` over the probe and both corpora in both modes, with the filter
  built from `$FENCED`, and lists 4 databases: MiniAmiq d/t and SeqDriver d/t. The movers equal the prediction (4
  corpus, 0 probe, 0 downstream).
  * § callArgCopyReduceOpModel248 fires in no corpus, probe or downstream database.
  * The trace's positive control is W/w01, which wrote the tag.
* **uhdm-cmp** reads 0 lines on all 4 movers. `R11U248_OFF` gives pristine bytes on all 4.
* **Canaries:**
  * surelog: ok=50 changed=2. The two changed rows are SeqDriver d/t; MiniAmiq is not a canary row.
  * uhdm2rtlil: ok=16 changed=0.
  * `EXPECT_UNKNOWN=1` and `EXPECT_UNKNOWN=6` ctcan2 both PASS.
* **Determinism** ([det/det_law.txt](evidence/det/det_law.txt)): three concurrent draws of Earlgrey_0_1 and the five UVM
  rows give one hash per row-mode on 11 of 11. Scoreboard testflags is SLANG_REJECT. The MiniAmiq and SeqDriver hashes
  equal the sweep's.

## Brief items

1. **(1)(a)** is done (§ cloneDotLoopVarBaseNoDrill248). **(1)(c)** is the next records on this ground, which are the two
   with-clause and string laws above. The heads behind them are sister-ground (next section).
2. **(2)** is done (§ callArgCopyReduceOpModel248, plus the § macroParamMethNameEnd246 cleanup). A reference through a
   hierarchical path or in a nested module is still not scanned.
3. **(3) Earlgrey_0_1.** No writer is on this ground; the row is unchanged.
   * #136315 / #137760: TypeEmit emitSyntaxExpr names the system-call argument's ref_typespec (pass 246).
   * #142988: reproduced as [decode/e01_genkey](decode/e01_genkey). It is STRICT_NOTEQUAL `col` in both views on
     pristine with 1 object: golden spans `key[7 - i]` 9:19-27, ours 9:23-26. The writer is TypeEmit emitSyntaxExpr's
     definition-view generate path, the § defGenPathSel161 branch for a non-identifier index; it is a bit_select whose
     span starts at the index.
   * #154375 / #165002: ModuleEmit port high-conn prefix.
4. **(4)** to **(7)** were not attempted. BlackBePipeInt reads `depth(1)` #38807 / `fullname(3)` #38803 at the base,
   unchanged.

## Sister-ground faces (decode only; call sites)

1. **MiniAmiq #79121 / #79122 / #79458 / #79459, SeqDriver #79078 / #79079 / #79416 / #79417** (the new heads):
   * Site: UhdmExporter `mintArrayElemVar193` / `drainCloneArrayRecvArgMint193` (§ cloneArrayRecvArgMintsElemVar193).
   * The receiver-argument mint for `visited.exists(succ)` in the importer copy of `uvm_phase::sync` / `unsync` is
     parented at the copy's own call. Its synthesized full name is `svaunit_pkg::...::visited.exists::succ`; golden's
     mint is parented at the home call and reads `uvm_pkg::...`.
   * The law's own comment calls this "worth nothing to the judge"; it is now the strict head.
2. **MiniAmiq #87013 / SeqDriver #86971** (next behind):
   * Site: TypeEmit § cloneStmtHomeVarRef17.
   * In the copy of `uvm_component::m_set_cl_verb`, the left side `cs` of `cs = uvm_coreservice_t::get();` binds the
     home class_var. Golden leaves it unbound in every listing, the home included, and ours leaves the home unbound too.
   * A one-file reduction (a class-scoped static call on the right side) was STRICT_EQUAL on pristine, so the
     distinguisher is not isolated.
3. SimpleUVM d/t col(5) #194836, Scoreboard d #195016 (UhdmExporter locLineCol), then #201235 / #201602 (TypeEmit class
   typedef writers) and #202914 (TaskFuncEmit). BuildUVMPkg d/t depth(1) #185844 (TaskFuncEmit). Rggen d fullname(199)
   #26477 (ModuleEmit). These are unchanged and re-measured at the base with `--max 20`.

## Residues, ranked

1. The two sister heads of MiniAmiq and SeqDriver above: 4 row-modes, then the remaining records.
2. § callArgCopyReduceOpModel248 does not scan a reference through a hierarchical path (`u.L[1]`) or in a nested
   module. The xor shapes (PE e20, R r03, r11) stay stage 1 on golden's folded select and are downstream DIVERGENT on
   every binary.
3. Copy faces found by the grids, all wrong on pristine too:
   * a typedef'd string property (S s03, golden binds the typedef, ours names it `p::str_t`);
   * an indexed-part-select operand in a `with` (W w09 #115);
   * `this.`-receiver withs (W w06, stage 1);
   * an implicit net beside a copy (W w11, stage 1);
   * an inherited or dotted string property (S s04, stage 1);
   * $unit-imported homes (S s05);
   * a struct-element base (C c07).
4. Brief items (3) beyond the decode, and (4) to (7), not attempted.

## Process

* No fenced test was dispatched, read or opened outside the gate sweeps.
  * Every corpus scan built its path list and filtered it by `$FENCED` first.
  * The census filter is built from `$FENCED` (`^(?!(?:...)$)` on names; word boundary on probe paths).
  * heads.sh refuses a fenced name.
  * The fence check on this evidence directory reads clean.
* Every tool variable was checked with `[ -x ]`.
* One waiter (`until` on the grid's line count) expected 588 lines where the grid wrote 560; it was stopped by its own
  task id.
* pgrep was used once, on this pass's own workdir name, to confirm the law sweep started.
* The order-blind `away.py` of v11u202 reuses its work files and reads a stale dump when uhdm-strictcmp stops at stage 1;
  the stage-1 numbers here come from awaydump.py instead.
* Drivers are copied from r11u247repro and resolve paths from the repo: case.sh, env.sh, grid.sh, controls.sh, det.sh,
  dscases.py, awayrows.py, strictcmp_x.cpp, cc_x.sh, bvmirror.sh. heads.sh, tracecensus.sh, gridsum.py and awaydump.py
  are new.
