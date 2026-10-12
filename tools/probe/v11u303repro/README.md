# v11u303 — adversarial verification of r11u303

Base 368d0810 (pass 301). The implementer's patch (ten laws in ModuleEmit, TypeEmit and UhdmExporter behind
`src/R303.h`) reproduces bit for bit. Fresh cases found **three breaks on legal SystemVerilog** where pristine was right
and the law wrong. Each is fixed by its own refinement behind `src/R303.h`:

- Each refinement reads its own `R11V303_<X>_OFF` switch.
- `R11V303_OFF` gives the law's bytes, and `R11U303_OFF` still gives pristine's.
- `R11U303_TRACE` logs each refinement's abstention as `<X>303V_ABSTAIN`.

The fix binary's gate sweeps are row-identical to the law's. No gate database moves between law and fix, and no
refinement fires anywhere in the gate (the fix census predicts no mover, and byteverify confirms it).

## The refinements (the verifier's laws)

**§ genCaEnumSelBoundLhsQual303v** (`R11V303_ENUMSELQUAL_OFF`, TypeEmit, inside § genCaEnumQualWholeSpan303).

- *The break.* The law gave every package enum constant inside a definition-view generate continuous assignment the
  whole `pkg::NAME` span. Golden keeps the qualifier-only span (`pkg::`) in these positions:
  - anywhere in the cell's LEFT side: `assign o[i][p::OpB] = ...`, `o[i][p::OpB:0]`, `{o[i][p::OpB], q[i]} = ...`, `o[p::OpA + i]`;
  - as a part-select bound: `v[p::OpB:2]`, `v[7:p::OpB]`, `{v[p::OpB:2]}`, `$bits(v[p::OpB:0])`, `v[p::OpB:p::OpA]`;
  - as an indexed part select's width: `v[0 +: p::OpB]`.
- *Golden's whole span holds* for a right-side value, for a bit-select index (also nested, and also as an operand
  inside an index), for an indexed part select's base, for a replication count and for a ternary condition.
- *Law vs pristine on the witnesses.* Twelve witnesses read chain away 1 (ve35 reads 2), with no record toward golden
  except ve24's right side. Five witnesses go STRICT_EQUAL -> STRICT_NOTEQUAL endcol in both views:
  - VE/ve06_partbound
  - VE/ve18_partlow
  - VE/ve19_lhspart
  - VE/ve21_partinconcat
  - VE/ve35_multi
- *The fix.* It reads the enum's syntax parents up to the assignment. It keeps the qualifier span under a
  `SimpleRangeSelect`, under the right operand of a `+:` / `-:` select, and on the left operand of the
  `AssignmentExpression`.
- *Result.* All twelve return to pristine's bytes, and ve24 keeps its toward record.
- *Also in the byte controls.* The same break shows on the existing case r11v158repro/cases/gl/g06, which reads law
  chain away 2 and toward 2, and fix away 0. The fix also moves g06 and g08 from the law's bytes.

**§ genNdaSelConstReduces303v** (`R11V303_NDASELCONST_OFF`, ModuleEmit emitGenScopes, inside
§ genNdaSelRhsSharesNet303).

- *The break.* The law shared the scope net as the cell's Lhs for every select initializer.
- *The decode* (UhdmWriter::writeCont_assign, the trailing reduceExpr branch). A select whose value is a constant, such
  as `wire [3:0] w = P[7:4];` or `P[i*4 +: 4]` with P a parameter, is reduced to a constant. The cell is then cloned
  with a fresh Lhs, as any constant initializer is: golden's Rhs is `BIN:1010`.
- *Law vs pristine.* VG/vg08_paramsel and vg10_paramips read chain away 12 in the default view, at uhdm-cmp stage 1 on
  both binaries.
- *The fix.* The law now stands aside when slang evaluates the initializer to a constant.

**§ ifFillBitSelConstIdx303v** (`R11V303_IFFILLIDX_OFF`, ModuleEmit emitInterfaceInstance, inside
§ ifCaTernFillArmKept303).

- *The break.* The cloned interface cell's bit-select Lhs copies only a constant index. So
  `assign arr[K] = (P) ? {2{sig}} : '0;` with K a parameter left the elaborated bit_select with no index, where golden
  keeps the reference K.
- *Law vs pristine.* VI/vi13_paramidx went from uhdm-cmp equal (STRICT_NOTEQUAL type) to uhdm-cmp stage 1 (15 lines,
  `RHS: <null>` under the bit_select).
- *The fix.* The law now fires only on a constant index.

## Reproduction of the implementer's numbers (all bit for bit)

**Builds.**

| Binary | md5 | Notes |
|---|---|---|
| pristine | `0b3ca4f932398a7372df33091d925f1a` | equal to the required base md5 |
| law | `390233ebdff4ffcb1ae21289b5c5f3b3` | equal to the implementer's |
| fix | `80bd60ce00cc4339065bd636ea9c45cf` | |
| uhdm-strictcmp | `fa6e4f42` | |
| strictcmp_x | `886f0302` | equal to the implementer's build |

- Every binary is frozen read-only in `/tmp/v11u303_bin`, and every one links slang 12.0.0+545f88b2e.

**Sweeps** (`tests/sweep.sh --jobs 3`; evidence/sweep_{P,L,F}.txt).

- *Probe.*
  - Pristine reads 3983 + 104 with 0/0/0.
  - Law and fix each read **3991 EQUAL + 96 STRICT_NOTEQUAL**, with regressions 0, conversions 8 and changes 1.
  - The conversions are r10earl104repro/vb4_instarr, r10earl121repro/a1_axis121, r10rgg14repro/cells/pc5,
    r10rgg9repro/cells/c_iface_body, r10vrgg14repro/cells/v5, r11u52vrepro/grid/b2_exprforms, r11v46repro/grid7 and
    v11u111repro/brk/f1/x01_class_param. Each one's fresh row reads `<case>,EQUAL,,equal`.
  - The change is r10earl115repro/p1_pos115 `differ:endcol(18) -> differ:endcol(13)`.
- *Corpora.* All three binaries read surelog 480 + 0 / 474 + 0 and uhdm2rtlil 803/1/67 in both modes, with 0/0/0.
- *Downstream.* All three read 803/66/2/0, and each csv is byte-identical to `results/downstream_uhdm2rtlil.csv`.
- *Exit status.* Every sweep exits 1 on the law-index check alone.

**Row-by-row csv comparisons.**
- Law vs pristine: only the nine probe rows above, plus the LowMemLib / LowMemPkg detail text (the workdir path).
- Fix vs law: only the LowMem text.

**Firing census.** evidence/predict_law.txt was frozen before the law sweep and is byte-identical to the implementer's
predict.txt.

- It names 27 probe databases and 14 corpus row-modes.
- Probe byte movers: exactly 20, all predicted (evidence/probe_byte_movers_law_vs_pristine.txt, measured with a
  pristine probe pass from the same worktree).
  - These are the 8 conversions, p1_pos115, and 11 cases that stay EQUAL.
  - The 7 other predicted databases fire § sysCallArgRefScopedName303 with no byte change.
- The fix census (evidence/predict_fix.txt) was frozen before the fix sweep. It carries the same 41 law lines and no
  `V` line, so it predicts no fix-vs-law mover.
- Positive control (evidence/census_poscontrol.txt): each refinement traces its abstention on its witness (ve06,
  vg08, vi13).

**Byteverify** (fence-filtered hard-link mirrors, SELFCHECK 3363 of 3365, the known twin).

- Law vs pristine: 10 of 3365 move, exactly the implementer's: Earlgrey_0_1 and ElabCParam in both modes,
  ibex_multdiv_fast and rp32_r5p_alu in both uhdm2rtlil modes and in the downstream lane.
- Fix vs law: 0 of 3365, and 0 of 4087 probe databases.
- Fix vs pristine: the same 10.
- Corpus movers, away census: order-blind lost 0 and chain-keyed away 0 / toward 0 on all 8 row-modes (identity-only
  movers; evidence/corpus_movers_*).

**Other gate checks.**
- Canaries: surelog ok=52 and uhdm2rtlil ok=16, changed 0, on all three sweeps. Both ctcan2 checks PASS
  (EXPECT_UNKNOWN 1 / 6).
- Binary-path audit: on each sweep, 3315 fence-filtered cmds.txt. 3265 name the sweep's own binary, 0 name another,
  and 50 run no slang.
- Determinism (drivers/det.sh, three concurrent draws): one hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard, BuildUVMPkg and Rggen, for law and fix. The hashes are equal to the sweeps' and to the
  implementer's evidence; the testflags Scoreboard and Rggen rows write no database.

**The implementer's grid** (116 case dirs, 232 case-views, rerun with drivers/gridf.sh; evidence/gridf_impl*.txt).
- 150 moving and 95 entering STRICT_EQUAL, with 0 leaving.
- Attribution matches the implementer's exactly: SELBASETRIM 18, BOUNDSYSCLONE 18, SYSARGNAME 10, MODARRSELNAME 14,
  MODARRIPSSPAN 2, GENCAENUMSPAN 18, GENNDASEL 22, GENNDAOP 10, CLSPARAMTD 22, IFTERNFILL 12, and the pair 4.
- The fix equals the law on 232 of 232. `R11U303_OFF` equals pristine on 232 and `R11V303_OFF` equals the law on 232.
- Every line is rc=0 except SA/a01_forinit (rc 3, no golden, on every binary).

**The implementer's byte controls** (36 dirs, 2574 case-views; drivers/ctl3.sh; evidence/controls36*).
- The same 12 movers, all at stage 1, with no exit-code or line-count change.
- The fix equals the law on all 2574.

## Attack grid (drivers/gridf.sh; cases/; evidence/gridf.txt, gridf_summary.txt, gridf_away*.txt)

132 fresh case dirs in both views make 264 case-views; every line carries its exit code and every one is rc=0. The
families, each case naming its law in its first line:

| Family | Dirs | What it varies |
|---|---|---|
| VT | 13 | blank, tab, newline and comment before the select; positional; net bit, part and indexed part selects; escaped names; no generate; if-generate; nested; 2-D |
| VB | 10 | `$clog2(N+1)`, `$bits(port)`, a package argument, an unpacked dimension, a generate block, a localparam, overridden instances, a low bound, `$signed`, a single use |
| VS | 13 | a generate-local net, a typedef argument, a genvar argument, an imported parameter, a nested localparam, an if condition, an interface, `$size(m,1)`, case-generate, always, a cell, a declaration range, an instance parameter |
| VE | 35 | right-side values, every select position on both sides, a call argument, a system call, net-declaration, cast, nested, case-generate, interface, always, inside, replication, ternary, an instance actual |
| VG | 21 | reference, concatenation, call, indexed part select, ternary, nested, parameter selects, case-generate, unary, compare, interface, two instances, constant, a parameter operation, a memory word, a struct member |
| VC | 13 | a type parameter, string, real, a body localparam, struct, no specialization, several specializations, enum, bit signed, unpacked, virtual, a package class, int unsigned |
| VI | 14 | two instances, a part-select Lhs, nested, arrays, a generate block, split fills, a true-branch fill, a vector bit, two modules, parameter from the parent, `'x`, default parameters, a parameter index, ports |
| VM | 13 | var, part and indexed selects, a system call, an operation, right bounds, two arrays, a generate block, an interface array, a struct member, two instances, a package select |

**Law vs pristine.**
- 174 moving, 81 entering STRICT_EQUAL and **10 leaving**: ve06, ve18, ve19, ve21 and ve35, each in both views.
- **vi13 leaves uhdm-cmp equality** (0 -> 15 lines).
- Chain away on 24 movers: the twelve VE witnesses in both views, and vg08 / vg10 at 12.

**Fix vs pristine.**
- 148 moving, 81 entering STRICT_EQUAL, **0 leaving**, and no exit-code change.
- `R11U303_OFF` equals pristine on 264 of 264.
- Away census on all 148 movers: order-blind lost 0, chain away 0, and 455 records toward golden.
- Every mover is restored by exactly one law switch, except 8 that need a pair (MODARRSELNAME with MODARRIPSSPAN on
  vm05 and vm12; GENNDASEL with GENNDAOP on vg15 and vg16).

**Fix vs law.**
- 28 case-views differ: ENUMSELQUAL 22, NDASELCONST 4 and IFFILLIDX 2.
- Each returns to pristine's bytes and is restored to the law's by exactly one refinement switch.
- `R11V303_OFF` equals the law on 264 of 264.

**uhdm-cmp line-count changes, fix vs pristine.**
- VI vi01, vi03, vi04, vi05, vi07, vi09, vi11, vi12 and vi14 in the elaborated view go from 33 (vi05: 104) to 0. All
  of them become STRICT_EQUAL.
- VC/vc12_pkgclass grows 96 -> 126 in both views, like the implementer's CP c02 / c06.
  - The first differing object is the same on both binaries: the class parameter's typespec.
  - Golden gives the class in the package its own copy named `m_t`, parented at the parameter. Pristine writes an
    int_typespec, and the law writes the package listing `q::m_t`, whose kind is golden's.
  - The chain census reads away 0 and toward 1. The count grows only because the bound object prints its range. This
    is a residue, not a break.

**Downstream** (drivers/dscases.py, all 132 dirs on three binaries; evidence/downstream_cases.txt).
- Nothing gets worse on law or fix.
- 14 improve: VI vi01, vi03, vi04, vi07, vi09, vi11, vi12 and vi14 go EQUIVALENT -> IDENTICAL. VT vt01, vt02, vt03,
  vt10 and vt12 go STATUS_DIFF -> IDENTICAL, and vt11 goes STATUS_DIFF -> EQUIVALENT.

## Widened byte controls (drivers/trigscan.sh, ctl3.sh; evidence/controls*.txt)

- *Selection.* The fix binary ran under `R11U303_TRACE` over every case dir of the base's tools/probe: 25177 dirs,
  with the path list fence-filtered before any file was opened. 132 dirs fired (evidence/controls_trigger_fired.txt,
  from 41 earlier repro dirs).
- *The 264 case-views on three binaries.*
  - Law: 212 moving, 15 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes. The two line-count changes are both
    to 0: v11u193repro TF/tf07_iface_el 33 -> 0 and v11u274repro VR/vr33_class_struct_param_el 37 -> 0.
  - Law, away census: chain away 0 on every mover except r11v158repro/cases/gl/g06 in both views (away 2, toward 2),
    the § genCaEnumSelBoundLhsQual303v face.
  - Fix: 210 moving and 15 entering. Order-blind lost 0 and chain away 0 on all 210.
  - The fix differs from the law on 4 views: g06 and g08 in both views.
- *Crash scan* (drivers/crashscan.sh, fix binary, all 25177 dirs). Exactly one exit 139:
  v11u112repro/grid/brk2/k/m07_hdr_enum_default, which exits 139 on pristine, law and fix alike. This is not this
  pass's.

## Residues (ranked; all wrong on pristine too)

1. The brief's first item, VA va06 / va08 / va09 / va10.
   - I confirm the implementer's decode: the prefix fold needs the elaborated param_assign reduce in ParamEmit
     emitParameters, on the sister's ground. Not written.
2. A select of a parameter in a generate net-declaration cell (VG vg08 to vg11).
   - Golden reduces it to a constant (`BIN:1010`) at uhdm-cmp stage 1, which the fold does not write.
   - A scalar loop net whose initializer is constant-valued (vg09 `P[i]`) gets a fresh Lhs in golden. Ours shares the
     scope net on every binary; it would need a constant-valued-select twin of § genNdaOpRhsFreshNet303.
3. Escaped identifiers as generate port actuals (VT vt07, vt08).
   - Golden names the select `bus$x`, with the backslash and the terminator dropped. The law trims only the trailing
     blank (`\bus$x`).
   - A comment between the name and the select (vt09) keeps the comment text. All are STRICT_NOTEQUAL name on every
     binary.
4. The class-in-a-package typed parameter (VC vc12, like CP c02 / c06).
   - Golden gives the parameter its own copy of the package typedef, named bare `m_t`. Stage 1.
5. The interface fill law's open shapes:
   - a part select of a select Lhs (vi02);
   - fills that differ by instance (vi06, vi10: the abstention);
   - a vector bit Lhs (vi08, stage 1);
   - a parameter-index Lhs (vi13, now abstaining). The decode: golden keeps the reference index in the cloned cell;
     copying a reference index would let the law fire.
6. Stage-1 shapes on every binary:
   - VE ve02, ve03, ve11, ve15, ve25, ve28 and ve33;
   - VS vs01 to vs03, vs07, vs08, vs10 and vs11;
   - VM vm01 to vm09, vm11 to vm13;
   - VB vb04, vb05 and vb07;
   - VC vc01 to vc05, vc09, vc10 and vc13.

Sister-ground faces (reported, not written): the ParamEmit param_assign reduce of residue 1, and the select fold of
residue 2, written by the reducer in ExprEmit / ParamEmit.

## Process

- *The fence.* Every driver reads `$FENCED` fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line
  (drivers/env.sh). Every path list was filtered by word boundary before any file was opened, in the trigger scan,
  the crash scan, the controls, the mirrors and the cmds.txt audit.
- *What I touched.* No fenced name was spelled, no other agent's process was listed or signalled, and nothing was
  written outside /tmp/wt_v11u303, /tmp/wt_v11u303pris and /tmp/v11u303_*.
- *Order of work.*
  - The pristine binary was frozen before any edit.
  - The law census ran on the frozen law binary before the law sweep.
  - The fix census ran on the frozen fix binary before the fix sweep.
- *The witness headers.* After the grid, the first lines of the 14 refinement witnesses were renamed to their
  refinement's law. A rerun on three binaries gives the same verdicts (evidence/witness_recheck.txt).
- *First draft.* The six VT net cases and VG's parameter header were rewritten once because their first draft had a
  slang error (an unconnected top-level interface port) or a stage-1 head unrelated to the law. They were rerun from a
  fresh golden.
