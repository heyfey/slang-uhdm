# r11u255: module/type ground, pass 255 (BuildUVMPkg's identity face, Earlgrey's generate-path faces)

Base 99ea3716. Four laws in TypeEmit and UhdmExporter behind `src/R255.h` (each `R11U255_<LAW>_OFF`,
`R11U255_OFF` drops all and restores the base's bytes, `R11U255_TRACE=<dir>` names every firing).
No row converts. Four corpus row-modes change, all toward golden:

| row-mode | base | law | first record base -> law |
|---|---|---|---|
| BuildUVMPkg d/t | `differ:depth(1)` | `differ:endcol(1)` | #185844 (§ fwWinnerListedObject255) -> #194627, one object, ground A |
| Earlgrey_0_1 d | `differ:fullname(160)` | `differ:fullname(155)` | #136315 unchanged (ground A); #142988, #206088, #206089, #206093, #206094 cleared |
| Earlgrey_0_1 t | `differ:fullname(55)` | `differ:fullname(50)` | #137760 unchanged (ground A); the testflags twins of those five records cleared |

Fresh rows from the law sweep (`evidence/sweeps/wL_surelog.csv`; results/ untouched):

```
BuildUVMPkg,default,STRICT_NOTEQUAL,differ:endcol(1),,differ:endcol(1)
BuildUVMPkg,testflags,STRICT_NOTEQUAL,differ:endcol(1),,differ:endcol(1)
Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(155),,differ:fullname(155)
Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(50),,differ:fullname(50)
```

**BuildUVMPkg is now one record from conversion, and that record is on the sister ground.** A measurement-only
prototype in ExprEmit (described in the ground-A section; never delivered) together with this pass's laws makes a
hand run of BuildUVMPkg default read `STRICT_EQUAL 201533 objects` with uhdm-cmp at 0 lines.

## 1. BuildUVMPkg #185844: § fwWinnerListedObject255 (switch `R11U255_FWLISTED_OFF`)

**The face is object identity, not binding.** Pass 253 read #185844 as "golden leaves the formal unbound". It does
not. Golden binds `connect(this_type provider)` in all eight TLM socket classes to
uvm_abstract_component_registry's `this_type` (uvm_pkg.sv 13776:11), the same typespec ours binds. Measured with
a small UHDM reader (`drivers/tfid.cpp`: for every class it prints the listed typespecs and each formal's actual,
with its UhdmId and parent):

```
golden  TS this_type id=186239 @13776:11 (uvm_abstract_component_registry's class_defn listing)
golden  IO connect.provider actual=this_type id=186239 @13776:11 parent=class_defn:uvm_abstract_component_registry   (x8)
ours    TS this_type id=5618   @13776:11
ours    IO connect.provider actual=this_type id=109114 @13776:11 (no parent)                                      (x8)
```

Golden points the formal at the listed object. That object has already been visited under a class typespec
(`type_id`'s alias, walk record 65331), so the strict walk does not expand it again. Ours points at an unparented twin
with the same span, and the walk lists that twin's subtree. This is the depth record:
`A: begin` vs `B: 8 class_typespec this_type 13776:11`.

**Writer.** § bareTdNameFirstWriterWins98 (TypeEmit fwWinner98 / fwWinnerTs98) picks the winner from
`collectFwWinners98`, which walks the specializations of a generic class. When the first specialization is not the
default one (the class_defn listing is built from the default specialization, `emitPackageClasses`), fwWinnerTs98
builds that specialization's typedef on demand as a separate object. Surelog keeps one TypeDef per declaration:
`ElaborationStep::bindTypedefs_` stores the typedef's own compiled typespec in `specs[name]`, and that is the object
the class_defn lists.

**Law.** Run design-final, after § oobClassTdFirstClassKey231's re-point. Take each object fwWinnerTs98 handed out
(recorded in `r255Fw98()`). If the object has no parent, and the winner's class_defn (`classDefnFor`) lists a
typespec of the same name, kind and position, the drain replaces the object with the listed one at every reference.
It walks every ref_typespec of the serializer once, and the writes are idempotent, so the result does not depend on
order. Traced as `fwWinnerListedObject255 <class>::<name> refs=<n>`. On BuildUVMPkg the trace reads
`uvm_abstract_component_registry::this_type refs=8` in each mode.

Grid `cases/F` (12 cases):
* the face: f04 (the listed object visited under a class typespec first), f06 (property, return and local), f09
  (two packages), f10 (three sockets), f12 (a module using the socket);
* identity moves but both sides list the same records: f03, f08 (a scalar `my_t`);
* f05: an out-of-body definition beside an in-body one. **Pristine stage 1 (uhdm-cmp 61 lines) -> STRICT_EQUAL**
  in both views;
* controls: f01, f02 (the winner is the default specialization), f07 (a non-generic winner), f11 (`$unit` classes:
  fwWinner98 abstains).

## 2. Earlgrey #142988: § genPathExprSelSpan255 (switch `R11U255_GENEXPRSEL_OFF`)

This is pass 248's `decode/e01_genkey`. The target is `assign hw2reg.key[7-i].d = '0;` in a gen-for block. Golden's
bit_select `key` spans 9:19-9:27; ours spans the bracket contents, 9:23-9:26. Surelog's SEL writer
(compileSelectExpression, the § defGenPathSel161 route 1: a definition-view generate continuous-assignment target,
a generate condition or case item, the gen-for header) spans a selected field from its name through the closing
bracket, whatever the index is. The literal-index branch already wrote this. **Law**: the expression-index branch of
TypeEmit emitSyntaxExpr's dotted-path loop (the BitSelect branch under § hpSymbolicSelect) does the same for a field
(`i > 0`) on the SEL route. The span ends at the last `]`. Traced as `genPathExprSelSpan255 <path>`.

Grid `cases/E` (12 cases):
* the face: e01 (the decode), e02 (spaced), e03 (parenthesised), e05 (two operators), e06 (the select is the leaf),
  e08 (two selects on the path), e11 (a generate-if body);
* stage 1 on both binaries, unrelated to this law: e09 (`$clog2` index), e12 (CRLF and a macro index);
* controls: e04 (identifier index), e07 (the right side, the CFC writer), e10 (outside a generate block).

## 3. Earlgrey #206088 / #206089 / #206093 / #206094: § defGenCfcThroughCondSel255 (switch `R11U255_CFCTHRU_OFF`)

The source is pinmux.sv 228-230: `assign pin_value = (reg2hw.wkup_detector[k].miodio.q) ?
dio_data_mux[reg2hw.wkup_detector_padsel[k]] : mio_data_mux[...]` in a gen-for block. Golden's
`wkup_detector_padsel` bit_select sits at the index `k` (229:65-66). It stores no full name, so the full name is read
through the parent chain, with the enclosing select's name included:
`work@pinmux.gen_wkup_detect.dio_data_mux.reg2hw.wkup_detector_padsel[k].wkup_detector_padsel`. The index `k`
likewise stores no full name. Ours wrote the legacy form: the dotted text stored, over the member. Two things send a
path to the legacy form: defGenRoute161 abstained at a `?:`, and it returned 0 at any select. Golden's right side is
an `expression` whatever lies between the path and the assignment, and compileComplexFuncCall (CFC) compiles it
exactly as it compiles the bare right side (`cases/C/c03`, equal on pristine). **Law**: the route walk continues
through a `?:` and through a bit or variable select. It answers CFC when it reaches a continuous assignment's RIGHT
side. In every other position it still abstains: an assignment target (c05), a generate condition (c14), a case
item, the gen-for header. Traced as `defGenCfcThroughCondSel255`.

## 4. § defGenCfcLitLeafSel255 (switch `R11U255_CFCLIT_OFF`)

This law came out of the C grid; no corpus row reaches it (the firing census reads 0). The case is
`assign o[k] = reg2hw.en[0];` in a gen-for block. Golden writes `work@pinmux.g.reg2hw.en[0].en` at the digit
(8:29-30); ours wrote the dotted text over the member (8:26-28). This is the literal-index twin of
§ defGenPathSel161's CFC rule in the identifier branch: compileComplexFuncCall's trailing select sits at its index and
stores no full name, and a middle literal select keeps the dotted form. c15 shows the middle form already equal on
pristine. Traced as `defGenCfcLitLeafSel255`.

Grid `cases/C` (17 cases):
* through a `?:` or a select: c01 (the Earlgrey shape), c02 (a select index), c04 (an operation), c06 (a var_select),
  c07 (a nested `?:`);
* both laws together: c08, c10;
* the literal leaf: c15, c16;
* controls: c03 (the bare right side), c05 (a target index, abstains), c11 (outside a generate block), c12 (a
  concatenation, abstains), c13 (an indexed part select, abstains), c14 (a gen-if condition with `?:`, stage 1 on
  both), c17 (a literal leaf as a target, SEL);
* c09 moves toward golden with a residue: residue 4.

## 5. Measurements

**Grid** (`drivers/grid.sh`, `evidence/grid.txt`, 574 lines, every line carrying its exit code; summary
`evidence/gridsum.txt` from `drivers/gridsum.py`): 41 cases in both views on 7 configurations (pristine, law,
`R11U255_OFF`, and each of the four switches).
* `R11U255_OFF` gives pristine's bytes on 82 of 82 case-views.
* 54 case-views move; 36 enter STRICT_EQUAL and none leave; every exit code is 0 on both binaries.
* uhdm-cmp line counts change only on F/f05 (61 -> 0, both views).
* Each switch moves only its own law's cases. c08 and c10 need both CFCTHRU and CFCLIT: each switch alone restores
  pristine.

**Away census** (`drivers/away.py` with a fail-closed fence check added, `drivers/awaycases.sh`,
`evidence/away_grid.txt`): every grid mover reads lost=0. F/f05 shows `dist 0 -> 86` only because pristine is
stage 1 there, so the census has no golden record set.

**Downstream on the cases** (`drivers/dscases.py`): 41 of 41 IDENTICAL on both binaries.

**Byte controls** (`drivers/controls.sh`, `evidence/controls.txt`): 963 cases from 17 earlier repro dirs, 1926
case-views:
* dirs: r11u161gen, r11u205dec, r11u219repro, r11u231repro, r11u253repro, v11u253repro, r11u248repro,
  r11u118repro, r11v11u118repro, r11u119repro, r11u120repro, r11u124repro, r11u131repro, r11u236repro,
  r11u192repro, r11u113repro, r11u112repro;
* exit codes identical on both binaries;
* 4 case-views move:
  * r11u248repro/decode/e01_genkey, both views: col -> STRICT_EQUAL (§ genPathExprSelSpan255);
  * r11u236repro/cases/E/e14, both views: endcol, 5 -> 4 objects, the same first record, away lost=0, gained=1
    (the literal leaf `q[0]` of a def-gen right-side path).

**Firing census** (`drivers/tracecensus.sh`, frozen as `evidence/predict.txt` before the law sweep, run through the
harness with the filter built from `$FENCED`): 14 databases.
* BuildUVMPkg d/t: FWLISTED.
* Earlgrey_0_1 d/t: CFCTHRU x22, GENEXPRSEL x1.
* uhdm2rtlil genvar_iface_struct, hier_path, ibex_pmp d/t: CFCTHRU.
* four probe cases, r11u22repro b14 and e09, r11v22repro v03 and v04: CFCTHRU.

**Byte movers** (`evidence/byteverify_corpus.txt`, through fence-filtered hard-link mirrors from `drivers/bvmirror.sh`,
SELFCHECK 2559/2560): 4 of 2560 corpus databases move, BuildUVMPkg d/t and Earlgrey_0_1 d/t, all four predicted. 0
of 4087 probe databases move (positive control 199/200) and 0 of 805 downstream databases move. The other 10
predicted databases fire CFCTHRU without moving: route 2 and the legacy form write the same bytes for a path with no
select component.

**Corpus movers**:
* uhdm-cmp reads 0 lines on all four (`evidence/cmp_movers.txt`).
* Away census (`drivers/awaycorp.sh`, `evidence/away_corpus.txt`): BuildUVMPkg d/t `dist 27 -> 19 lost=0`,
  Earlgrey d `1037 -> 1032 lost=0 gained=5`, t `769 -> 764 lost=0 gained=5`.
* With `R11U255_OFF` the law binary gives pristine's md5 on all four (`evidence/off_corpus.txt`).

**Gates** (`tests/sweep.sh --jobs 3`; pristine `/tmp/r11u255_wP`, law `/tmp/r11u255_wL`; logs and fence-filtered csvs
in `evidence/sweeps/`):

| stage | result |
|---|---|
| probe | regressions=0 conversions=0 changes=0 (EQUAL 3547 / STRICT_NOTEQUAL 540) |
| surelog | regressions=0 conversions=0 changes=4 (the four rows above; 937 CMP_EQUAL + 17 STRICT_NOTEQUAL unchanged) |
| uhdm2rtlil | regressions=0 conversions=0 changes=0 (1606 + 0) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; the csv is byte-identical to pristine's |

* Each sweep exits 1 only because the law index is stale while this directory is untracked; the patch carries the
  regenerated `tests/LAWS.md`.
* The pristine sweep reproduces every baseline: changes=0 in all stages.
* The two csvs are equal row for row apart from the four rows above and the two LowMem path-detail rows.

**Canaries**:
* surelog `ok=48 changed=4`, the four targeted rows (pristine `ok=52 changed=0`); uhdm2rtlil `ok=16 changed=0`.
* ctcan2 PASS on both corpora (EXPECT_UNKNOWN=1 / 6).

**Binary-path audit** (`evidence/binaudit.txt`, path list filtered by `$FENCED` first): 3265 of 3265 cmds.txt per
sweep name the frozen binary of that sweep, and none names another binary.

**Determinism** (`drivers/det.sh`, three concurrent draws per row-mode with the law binary,
`evidence/det_law.txt`): one hash per row-mode on 11 of 11. Scoreboard testflags writes no database. Each hash
equals the law sweep's.

Binaries: pristine md5 de0c6d846229ddfb799e37cb0cbb28b8 (the main tree's), law 771d2315d253e6fafc91b9df9e2cc1f8;
both link slang 12.0.0+545f88b2e.

## 6. Ground-A faces (decode only; call sites), cases `decode/A`

1. **BuildUVMPkg d/t #194627, the last record** (`decode/A/a01_shell_call_span`, STRICT_NOTEQUAL endcol on both
   binaries).
   * Source: `if (factory.is_type_registered(rgtry))` in uvm_registry_common::set_type_alias, where the argument
     (`Tregistry rgtry`, a type parameter defaulting to int) does not convert to the class formal. slang wraps the
     call in an InvalidExpression.
   * ExprEmit's `case ExpressionKind::Invalid` unwrap (§ shellCallKeepsItsSyntax167) emits the child call. Its
     hier_path takes the call's range, the callee `factory.is_type_registered` (14097:13-39). Golden spans the whole
     invocation (13-46).
   * Prototype (measurement only, never delivered): after the unwrap, when the result is a hier_path and the
     wrapper's syntax is an InvocationExpression, set the location from the wrapper's syntax. It brings a01 to
     STRICT_EQUAL in both views. With this pass's laws it brings BuildUVMPkg default to STRICT_EQUAL (hand run).
     **That one change should convert BuildUVMPkg d/t.**
2. **Earlgrey #154375 / #165002 (t #155820 / #166447)** (`decode/A/a02_hc_selidx_tsname`): `.instr_pmp_err_i(pmp_req_err[PMP_I])`.
   * The folded index constant's ref_typespec stores the full name `work@ibex_core.if_stage_i.instr_pmp_err_i.pmp_req_err`.
   * Golden stores `work@ibex_core.if_stage_i.pmp_req_err`, the bit_select's own full name: UHDM
     BaseClass::ComputeFullName skips a port above a bit_select.
   * The writer is ExprEmit's imported-parameter fold stamp (§ selFold9: "named after the select"). In a port
     connection it names the stamp from the port prefix.
3. **Earlgrey #136315 / #137760** (`decode/A/a03_sysarg_fold_parent`): `logic [$clog2(NumRound)-1:0] round;` with
   `NumRound` an imported package parameter.
   * Golden parents the folded argument constant at the module's param_assign, so its ref_typespec reads
     `work@sha2`.
   * Ours parents it at the sys_func_call, which ComputeFullName skips, so the name reads empty.
   * The site is ExprEmit's § sysFuncArgFold re-parent (`pkgParamConst`), which is gated to the parameter-init
     context; a typespec range is not reached.
4. Unchanged and not attempted: SimpleUVM #203342 / #203354 (ParamEmit's imported-parameter mint), MiniAmiq /
   SeqDriver #87036 / #86994 / #87006 (StmtEmit's foreach branch, § cloneLoopVarHomeObject183), BlackBePipeInt
   #190646 / #190553 (ParamEmit importedFold).

## 7. Residues, ranked

1. BuildUVMPkg d/t #194627 (ground A, item 1 of section 6): one record.
2. Earlgrey_0_1 d/t: 155 / 50 records.
   * The heads are ground A (section 6, items 2 and 3).
   * Behind them, on this ground:
     * #190726 / #190744: padring.sv 40-41 logic_typespec endcol, golden 30, ours 42, on
       `input [NMioPads-1:0][AttrDw-1:0]`;
     * #193018: the ref_typespec `work@pinmux.p_sleep` vs `work@pinmux`;
     * #214166..#214360: `prim_present` gen-block index `k` full names reading through `data_state` / `round_key`;
     * the rstmgr port-typespec full names (#233633...).
   * None attempted.
3. Rggen d fullname(199) #26477: the interface port-view full name (`g_decoder[0].u_decoder.i_access.access`, ours
   `register_if.access`; ModuleEmit). Not attempted.
4. `cases/C/c09` (and Earlgrey's sister shapes): a MIDDLE select with an EXPRESSION index under the CFC writer
   (`reg2hw.wkup_detector_padsel[1-k].q`).
   * Golden keeps the dotted form at the member: `reg2hw.wkup_detector_padsel[1 - k]`, 41-61.
   * Ours writes the bracket-contents span and a scoped name. That is the expression branch's
     `An EXPRESSION-indexed bit_select spans the BRACKET CONTENTS` rule, measured outside a generate block.
   * Wrong on pristine too.
5. The elaborated-instance face behind E/e06 and E/e08: the genvar reference inside a select index of an elaborated
   gen-scope path (`work@top.u.gen_key_digest[0].i`, golden `...hw2reg.key[7 - i].key.i`). Wrong on pristine too.
6. The brief's items (3) to (7) were not attempted.

## 8. Process

* Nothing fenced was dispatched, read or opened outside the gate sweeps.
  * The firing census ran through the harness with the filter built from `$FENCED`.
  * The byte comparison of corpus databases ran on hard-link mirrors without the fenced rows (8 skipped).
  * The probe and downstream byte lists and the binary audit filtered their path lists by `$FENCED` before
    opening anything.
  * The copied sweep csvs in `evidence/sweeps/` have the fenced rows removed.
  * The evidence directory reads clean on a fence grep.
* **Process error, recorded**: one waiter (waiting for the firing census) used
  `pgrep -u <me> -f '<tracecensus driver path>'`, a pattern that matched its own shell. It could not end and was
  stopped by its own task id. No process was signalled or listed otherwise. Every later waiter tested a file.
* Every tool variable was checked with `[ -x ]` (case.sh, env.sh).
* Measurement-only builds were made from temporary source edits, reverted before the law binary was built:
  * a debug print in fwWinnerTs98;
  * the ExprEmit prototype in section 6, item 1.

  The worktree's ExprEmit, StmtEmit, ParamEmit and EmitHelpers.h are the base's.
* Drivers: env.sh, case.sh, grid.sh, gridsum.py, away.py (fence check added), awaycases.sh, awaycorp.sh, controls.sh,
  bvmirror.sh, tracecensus.sh, det.sh, heads.sh, dscases.py, tfid.cpp (the identity reader; it needs `FENCED` and
  refuses a fenced path).
