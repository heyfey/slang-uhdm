# v11u144 — adversarial verification of r11u144

Verifier of pass r11u144 (the module/type ground on the strict axis, fourth round: ten laws in
src/ModuleEmit.cpp, src/TypeEmit.cpp, src/UhdmExporter.cpp, src/TaskFuncEmit.cpp and uhdm_main.cpp).
Base `6ef15be0`, branch matrix-1.87. Worktrees `/tmp/wt_v11u144` (patch) and `/tmp/wt_v11u144pris`
(pristine), both built by this verifier with the system-deps config at `-j 2`.

**Verdict: ACCEPT-WITH-FIX (tooling and documentation only; no production line changed).**
- Every headline number reproduces bit for bit.
- No break case, probe case, corpus row-mode or downstream row moves away from golden.
- Each law drops alone.
- The fix does two things:
  - It makes the implementer's `drivers/predict.py` refuse to run without the fence list. The committed script scanned every corpus test's sources when `$FENCED` was unset, and the implementer's first run did exactly that (see Fence note below).
  - It corrects one wrong mover count in the implementer's README.

## Fence note (for the integrator; the decision is the user's)

The implementer's report says its first mover-prediction run regex-scanned the sources of every corpus test, the
four slang-fenced tests included. It says it ran no binary on them and decoded nothing from them, and that it
re-ran the scan with the fence applied.

The standing rules forbid running any script on those sources, and state that a breach invalidates the pass.
This verifier cannot undo that run. What it can confirm:
- No committed file spells a fenced name. The only mention is the allowed superstring.
- The committed `predict_pristine.tsv` holds 3315 rows, which matches a fenced run.
- `drivers/predict.py` now exits when `$FENCED` does not hold four names.

This verifier ran the prediction once, with `$FENCED` exported, before it read any mover list.

## 1. Binaries (frozen `chmod 555` copies under /tmp/v11u144_bin before any measurement)

| binary | md5 |
|---|---|
| pristine (built from 6ef15be0) | `614337e4c8d4b8833fe5c71262db8aae` (the required pristine md5) |
| law (6ef15be0 + /tmp/r11u144.patch) | `10c1d04958343953d85c6a94a9f16172` (= the implementer's) |
| uhdm-strictcmp | `5d4617d0458f34aa79e0b91009d5d1fc` (= main tree) |

Every corpus `cmds.txt` was audited by binary path:
- pristine sweep: 3273 of 3273 slang lines name `pris.bin`;
- law sweep: 3273 of 3273 name `law.bin`.

The downstream slang lane of PkgParamAsFunctionArg was re-made by hand with both binaries. Its bytes equal the law binary's.

## 2. Headline numbers reproduced (evidence/sweep_*.txt, downstream_law.txt)

| gate | pristine | law | implementer |
|---|---|---|---|
| probe EQUAL (of 4087) | 2272 | 2285 (regressions=0 conversions=13 changes=21) | same |
| surelog CMP_EQUAL (of 954 judge-equal) | 389 + 383 = 772 | 391 + 389 = 780 (0 / 8 / 11) | same |
| uhdm2rtlil CMP_EQUAL (of 1606) | 692 + 692 = 1384 | 697 + 697 = 1394 (0 / 10 / 4) | same |
| judge scoreboards | 480/3 + 474/3, 803/1/67 | unchanged | same |
| downstream | — | IDENTICAL 803, EQUIVALENT 2, SLANG_REJECT 66; verdict and `differs` equal the baseline on 871 of 871 | same |
| byteverify | — | PATH_SETS_IDENTICAL; SELFCHECK 959/960 and 1607/1608; MOVERS 32/960 + 14/1608 = 46 | evidence 32 + 14; README said 33 + 15 = 48 (corrected) |
| grid (84 cells) | judge-equal 67, strict-equal 20 | 67, 64; `R11U144_OFF=1` gives the pristine bytes on 84 of 84 | same |
| per-switch grid drop (evidence/grid_switches.txt) | — | each switch moves only its own grid's cells back to pristine bytes; at/fc is shared by the two method-span laws | same |
| canaries.sh | — | surelog ok=44 changed=8 (Earlgrey_0_1, YosysOldOr, ClassTypeParam, SVSwitch, both modes); u2r ok=16 changed=0; ctcan2 PASS 58 / 2 | same |
| `law_index.py --check` | STALE at the base | current | same |

The pristine sweep reads `rc=1` only because of `law index STALE`, which the base reads too. The law sweep reads `rc=0`.

**Converted rows (fresh law csv rows, `status,...,strict`):**
- surelog: `CarryAdd,testflags,CMP_EQUAL,,,equal`, and the same `CMP_EQUAL ... equal` cell for GenScopeHierPath3 t, SequenceInst t, UnsizedParam t, IndexAssign d/t and PackStructVar d/t.
- uhdm2rtlil, both modes: ParameterInitializedByPartSelectOfParametersAssignedToVar, ParameterOfParametrizedType, ParameterOfParametrizedTypeInSubmodule, PkgParamAsFunctionArg and iface_array_modport_drive.
- 13 probe cases (the implementer's list, reproduced).

**Downstream rows of the targets (fresh):**
- `PkgParamAsFunctionArg,IDENTICAL,NO_GATES,NO_GATES,`
- `ParameterInitializedByPartSelectOfParametersAssignedToVar,IDENTICAL,NO_GATES,NO_GATES,`
- `ParameterOfParametrizedType,IDENTICAL,NO_GATES,NO_GATES,`
- `ParameterOfParametrizedTypeInSubmodule,IDENTICAL,NO_GATES,NO_GATES,`
- `iface_array_modport_drive,IDENTICAL,READ_FAIL,READ_FAIL,`
- `genvar_iface_struct,IDENTICAL,OK,OK,`
- `packed_struct_array_fifo,IDENTICAL,OK,OK,`

## 3. No strict cell worsens (evidence/changed_rows.txt, drivers/worse.py)

For each of the 36 rows or cases whose strict column changed without converting, the verifier listed the full differing-record walk of golden against pristine and of golden against law (`uhdm-strictcmp --max 1000000`). It then looked for any record that the pristine walk matched, before its own structural divergence, and that differs in the law walk.

The result: **33 IMPROVE** (the law's differing records are a subset of the pristine's) and **3 UNMASK**: packed_struct_array_fifo d/t, where the pristine walk diverged at record 190 / 100, and the probe case r11u112repro/grid/k/k20_hdr_param_type_ctl. **0 NEW.** No record that stays different changed its value.

## 4. Movers: prediction and attribution (evidence/byteverify_*.txt, attribution*.txt)

**Prediction.** The implementer's `drivers/predict.py` (regexes over the sources, with `$FENCED` exported) ran on the pristine workdir before the byte verifier.
- It predicts 44 of the 46 movers. The two it misses are EvalFunc t and StringRange t.
- The prediction is broad: 994 of 3315 row-modes carry some face. It is a coverage check, not a sharp predictor.
- EvalFunc t and StringRange t, together with FuncInModule t and UnsizedFunc t, are strict-equal rows that read equal before and after. Their order-blind dumps are identical (0 lines), and each gets its pristine bytes back under `R11U144_ELABINST_OFF` alone: the elaboration law unstores names that equal their chains.

**Attribution.** Every mover was re-run from its own `cmds.txt` with the law binary, under `R11U144_OFF` and under each single switch.
- `R11U144_OFF` gives the pristine bytes back on 40 of 46. The six others are the known UVM order coin: MiniAmiq d/t, Scoreboard d, SeqDriver d/t and SimpleUVM t this time. Their `R11U144_OFF` outputs sit 0 to 4 order-blind dump lines from pristine.
- Every non-coin mover has one owning switch:
  - SELBAREDEC: IndexAssign, YosysOldOr, YosysBigSimEllip.
  - METHQUALSPAN: ClassTypeParam, SVSwitch, BuildUVMPkg.
  - PKGQUALREF: PackStructVar.
  - PARAMALIASREF: UnsizedParam d, ParameterOfParametrizedType*.
  - ELABINST: CarryAdd, GenScopeHierPath3, InterfArrayBind, and the four equal rows above.
  - ELABPROP: SequenceInst.
  - FOLDTSNAME: ParameterInitializedByPartSelect...
  - CALLBITSEL: PkgParamAsFunctionArg.
  - TPPACKEDNET: packed_struct_array_fifo.
  - DEFGENHP: iface_array_modport_drive, genvar_iface_struct.
- Two rows are compositions:
  - UnsizedParam t gets its pristine bytes back under `PARAMALIASREF_OFF` alone, and under `ELABINST_OFF` alone it reads a third state: the elaboration law acts on the alias law's references.
  - Earlgrey_0_1 moves under FOLDTSNAME, PKGQUALREF and DEFGENHP, plus ELABINST in testflags. The implementer found the same.
- The UVM rows move toward golden. On BuildUVMPkg d, the order-blind distance to golden goes from 67502 to 62106 lines, a drop of 5396, which is exactly the number of lines the law moves. On SeqDriver d it goes from 468763 to 463815.

## 5. Break grid: 58 fresh cases (brk/, drivers/case.sh; evidence/brk_{P,L,O}.txt, brk_changed.txt, downstream_brk.txt)

Every case names its law on its first line.
- Surelog v1.87 golden (`-parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`, plus `-elabuhdm` for el/) wrote each database with 0 errors.
- Ours ran as `dut.sv --single-unit --nobuiltin` (plus `--elabuhdm`). rc=0 for all three binaries (pristine, law, law with `R11U144_OFF`) on all 58.
- `R11U144_OFF=1` gives the pristine bytes on 58 of 58.
- uhdm-cmp line counts are equal on 56 of 58. On qb/x6 and qb/x10 the count goes from 60 to 62 with the SAME head (golden folds the member bound `p::W-1` to a constant, where ours keeps the operation, in a package struct reached through a packed-array typedef). The two extra lines are our operand's dump printing its now-computed full name `q::q::s_t::d::p::W`.
- Judge-equal cells: 32. Strict-equal: pristine 4, law 20.
- Every judge-equal cell that moved without converting was checked mechanically:
  - IMPROVE on el/x3, fb/x4, hg/x1, hg/x2, hg/x4, hg/x5, pf/x3 and pf/x4.
  - UNMASK on tq/x1 and tq/x5. Their pristine walks diverge at record 17; the law's net now binds the default struct with golden's end, and what remains is the pass's R3/R4 member names and the elaborated copy's span.
- Judge-NE cells were compared order-blind against golden. Every moved one is closer or level: ia/x3 42→34, pf/x5 12→8, pt/x4 237→229, pt/x6 252→244, qb/x2 11→2, qb/x4 27→21, qb/x5 5→2, qb/x6 102→93, qb/x7 56→44, qb/x10 147→135, tq/x2 56→45, tq/x3 180→126, tq/x4 158→147, vf/x2 15→5. pf/x2 moves bytes only, with a dump equal to pristine.
- Downstream (`ds.one`, both binaries, 21 synthesizable cases): IDENTICAL for both binaries on all 21.

| case | law | uhdm-cmp lines P / L | strict P -> L | bytes |
|---|---|---|---|---|
| brk/at/x1 | § methodSpanSkipsAttrs144 | 0 / 0 | differ:endcol -> equal | moved |
| brk/at/x2 | § methodSpanSkipsAttrs144 | 0 / 0 | differ:col -> equal | moved |
| brk/at/x3 | § methodSpanSkipsAttrs144 | 0 / 0 | differ:col -> equal | moved |
| brk/el/x1 (--elabuhdm) | § elabCloneInstTreeUnstored144 | 0 / 0 | differ:endcol -> differ:endcol | same |
| brk/el/x2 (--elabuhdm) | § elabCloneInstTreeUnstored144 | 52 / 52 | judge-NE -> judge-NE | moved |
| brk/el/x3 (--elabuhdm) | § elabCloneInstTreeUnstored144 | 0 / 0 | differ:fullname -> differ:fullname | moved |
| brk/el/x4 (--elabuhdm) | § elabCloneInstTreeUnstored144 | 0 / 0 | differ:fullname -> equal | moved |
| brk/fb/x1 | § foldedBoundTsRefUnstored144 | 15 / 15 | judge-NE -> judge-NE | same |
| brk/fb/x2 | § foldedBoundTsRefUnstored144 | 50 / 50 | judge-NE -> judge-NE | same |
| brk/fb/x3 | § foldedBoundTsRefUnstored144 | 0 / 0 | equal -> equal | same |
| brk/fb/x4 | § foldedBoundTsRefUnstored144 | 0 / 0 | differ:fullname -> differ:fullname | moved |
| brk/fb/x5 | § foldedBoundTsRefUnstored144 | 0 / 0 | equal -> equal | same |
| brk/hg/x1 | § defGenLhsHpBaseAnchor144 | 0 / 0 | differ:endcol -> differ:fullname | moved |
| brk/hg/x2 | § defGenLhsHpBaseAnchor144 | 0 / 0 | differ:endcol -> differ:fullname | moved |
| brk/hg/x3 | § defGenLhsHpBaseAnchor144 | 0 / 0 | differ:endcol -> equal | moved |
| brk/hg/x4 | § defGenLhsHpBaseAnchor144 | 0 / 0 | differ:endcol -> differ:endcol | moved |
| brk/hg/x5 | § defGenLhsHpBaseAnchor144 | 0 / 0 | differ:endcol -> differ:fullname | moved |
| brk/ia/x1 | § caSelLhsBareDecNoAdjust144 | 0 / 0 | differ:decompile -> equal | moved |
| brk/ia/x2 | § caSelLhsBareDecNoAdjust144 | 0 / 0 | differ:decompile -> equal | moved |
| brk/ia/x3 | § caSelLhsBareDecNoAdjust144 | 17 / 17 | judge-NE -> judge-NE | moved |
| brk/ia/x4 | § caSelLhsBareDecNoAdjust144 | 0 / 0 | equal -> equal | same |
| brk/ia/x5 | § caSelLhsBareDecNoAdjust144 | 0 / 0 | differ:decompile -> equal | moved |
| brk/ia/x6 | § caSelLhsBareDecNoAdjust144 | 0 / 0 | differ:decompile -> equal | moved |
| brk/ia/x7 | § caSelLhsBareDecNoAdjust144 | 0 / 0 | differ:size -> equal | moved |
| brk/pf/x1 | § callFoldFormalBitSelLoc144 | 0 / 0 | differ:file -> equal | moved |
| brk/pf/x2 | § callFoldFormalBitSelLoc144 | 26 / 26 | judge-NE -> judge-NE | moved |
| brk/pf/x3 | § callFoldFormalBitSelLoc144 | 0 / 0 | differ:endcol -> differ:endcol | moved |
| brk/pf/x4 | § callFoldFormalBitSelLoc144 | 0 / 0 | differ:file -> differ:file | moved |
| brk/pf/x5 | § callFoldFormalBitSelLoc144 | 64 / 64 | judge-NE -> judge-NE | moved |
| brk/pf/x6 | § callFoldFormalBitSelLoc144 | 36 / 36 | judge-NE -> judge-NE | same |
| brk/pf/x7 | § callFoldFormalBitSelLoc144 | 0 / 0 | differ:file -> differ:file | same |
| brk/pt/x1 | § paramAliasBoundRefUnstored144 | 42 / 42 | judge-NE -> judge-NE | same |
| brk/pt/x2 | § paramAliasBoundRefUnstored144 | 0 / 0 | differ:fullname -> equal | moved |
| brk/pt/x3 | § paramAliasBoundRefUnstored144 | 72 / 72 | judge-NE -> judge-NE | same |
| brk/pt/x4 | § paramAliasBoundRefUnstored144 | 17 / 17 | judge-NE -> judge-NE | moved |
| brk/pt/x5 | § paramAliasBoundRefUnstored144 | 17 / 17 | judge-NE -> judge-NE | same |
| brk/pt/x6 | § paramAliasBoundRefUnstored144 | 92 / 92 | judge-NE -> judge-NE | moved |
| brk/pt/x7 | § paramAliasBoundRefUnstored144 | 56 / 56 | judge-NE -> judge-NE | same |
| brk/qb/x1 | § pkgTsForeignQualRefUnstored144 | 64 / 64 | judge-NE -> judge-NE | same |
| brk/qb/x10 | § pkgTsForeignQualRefUnstored144 | 60 / 62 | judge-NE -> judge-NE | moved |
| brk/qb/x2 | § pkgTsForeignQualRefUnstored144 | 64 / 64 | judge-NE -> judge-NE | moved |
| brk/qb/x3 | § pkgTsForeignQualRefUnstored144 | 0 / 0 | equal -> equal | same |
| brk/qb/x4 | § pkgTsForeignQualRefUnstored144 | 50 / 50 | judge-NE -> judge-NE | moved |
| brk/qb/x5 | § pkgTsForeignQualRefUnstored144 | 64 / 64 | judge-NE -> judge-NE | moved |
| brk/qb/x6 | § pkgTsForeignQualRefUnstored144 | 60 / 62 | judge-NE -> judge-NE | moved |
| brk/qb/x7 | § pkgTsForeignQualRefUnstored144 | 50 / 50 | judge-NE -> judge-NE | moved |
| brk/qb/x8 | § pkgTsForeignQualRefUnstored144 | 64 / 64 | judge-NE -> judge-NE | same |
| brk/qb/x9 | § pkgTsForeignQualRefUnstored144 | 0 / 0 | differ:fullname -> equal | moved |
| brk/tq/x1 | § defNetTypeParamPackedDim144 | 0 / 0 | differ:endline -> differ:fullname | moved |
| brk/tq/x2 | § defNetTypeParamPackedDim144 | 36 / 36 | judge-NE -> judge-NE | moved |
| brk/tq/x3 | § defNetTypeParamPackedDim144 | 110 / 110 | judge-NE -> judge-NE | moved |
| brk/tq/x4 | § defNetTypeParamPackedDim144 | 607 / 607 | judge-NE -> judge-NE | moved |
| brk/tq/x5 | § defNetTypeParamPackedDim144 | 0 / 0 | differ:endline -> differ:fullname | moved |
| brk/vf/x1 | § classMethodQualSpan144 | 0 / 0 | differ:endline -> equal | moved |
| brk/vf/x2 | § classMethodQualSpan144 | 18 / 18 | judge-NE -> judge-NE | moved |
| brk/vf/x3 | § classMethodQualSpan144 | 168 / 168 | judge-NE -> judge-NE | same |
| brk/vf/x4 | § classMethodQualSpan144 | 0 / 0 | differ:col -> equal | moved |
| brk/vf/x5 | § classMethodQualSpan144 | 0 / 0 | differ:endcol -> equal | moved |

## 6. Residues found by the break grid (all pristine-wrong; none introduced by the patch), ranked by reach

1. **Elaborated generate-scope index references.** Golden reaches the loop variable of a member path through the path: `work@top.g[0].s[i].a.y.i`. Ours names it by the scope: `work@top.g[0].i`.
   - Cases: brk/hg/x1, hg/x2, hg/x4 and hg/x5 (the interface array too). It is the first remaining field on each.
   - Site: the elaborated generate cont_assign's hier_path index. The implementer's S4 lists the `IFN` twin as an ExprEmit.cpp face.
2. **Definition-view generate Lhs with a trailing select** (`s[i].f[0]`, brk/hg/x4). This is the next face of § defGenLhsHpBaseAnchor144.
   - Golden anchors the hier_path at the base token (6:12-6:13) and the trailing `bit_select` at 6:19-6:20. Ours has 6:12-6:21 and 6:17-6:18.
   - As an Rhs operand, golden names the `bit_select` `work@top.g.s[i].f[0].f`.
   - Site: ModuleEmit.cpp emitDefGenStmts, beside § defGenLhsHpBaseAnchor144.
3. **The pass-139 net-binding shapes pc31 and pc33** (tools/probe/r11u139netbind/cases/pc/pc31_bitsel_first_pos and pc33_sel_index_whole) were in the brief's item (1) and are not in the implementer's report. Measured unchanged at the base and under the law:
   - pc31 `differ:col(1)`: golden spans the positional bit-select actual `v[0]` 4:9-4:13, ours 4:11-4:12.
   - pc33 `differ:fullname(2)`: golden names the select index `work@top.u.idx`, ours `work@top.u.a.idx` and `work@top.idx`.
   - Site: ModuleEmit.cpp, the connection emission under § connLeftmostLeafElab139.
4. **Folded call faces beyond § callFoldFormalBitSelLoc144**:
   - brk/pf/x3: a package parameter initialised by a REPLICATION (`{2{2'b10}}`) folds to 0:0-0:1 in golden too, but the law handles only a Concatenation initialiser.
   - brk/pf/x4: a bit select indexed by another formal (`x[k]`) takes the literal actual's location in golden (9:20-9:21); ours is unlocated.
5. **The folded bound of a header-declared port** (`input logic [P-1:0] a`, brk/fb/x4). Golden names the reference `work@top`, ours `work@top.a`. It is the next face of § foldedBoundTsRefUnstored144.
6. **Definition-view generate index name** in brk/el/x3: golden `work@sub.S.R.S[k - 1].t.k`, ours `work@sub.S.R.k`.
7. **Elaborated fold span of a part-select base expression** under `--elabuhdm` (brk/el/x1): golden spans `i*4` (8:28-8:31), ours 8:28-8:29.
8. **Judge-visible (uhdm-cmp) faces:**
   - brk/qb/x6 and qb/x10: golden folds a foreign-package bound `p::W-1` inside a package struct reached through a packed-array typedef.
   - brk/qb/x5 and qb/x7: a union member `[p::W:0]`, and a vector typedef with `p::W/4`.
   - brk/pt/x1, x3, x4 and x6: `$clog2` and struct or array aliases in a parameter's type.
   - brk/vf/x2 and x3: a parameterised class and extern methods in a module class.
   - brk/tq/x2, x3 and x4: union default, overridden type parameter, unpacked dimension.

The implementer's residue table maps item (5)'s replication-in-concatenation actual, package `bit_typespec` name, type-parameter port copies and PreprocTest to "R6-R8". Those residue entries describe other faces, so these four remain UNDECODED. Only the port-view fold span (S5) is decoded.

## 7. Files

- `brk/{at,el,fb,hg,ia,pf,pt,qb,tq,vf}/x*/dut.sv`: the 58 break cases. Each one's first line names its law: at = § methodSpanSkipsAttrs144, el = § elabCloneInstTreeUnstored144, fb = § foldedBoundTsRefUnstored144, hg = § defGenLhsHpBaseAnchor144, ia = § caSelLhsBareDecNoAdjust144, pf = § callFoldFormalBitSelLoc144, pt = § paramAliasBoundRefUnstored144, qb = § pkgTsForeignQualRefUnstored144, tq = § defNetTypeParamPackedDim144, vf = § classMethodQualSpan144.
- `drivers/`:
  - env.sh
  - case.sh (one case: golden, ours, uhdm-cmp, strict)
  - rdiff.sh (strict records)
  - ob.sh (order-blind dump distance)
  - brkworse.py and worse.py (the no-new-difference checks on the break grid and the sweeps)
  - attr.py (per-switch mover attribution)
  - ds.py (downstream per case)
  - sweep.sh
- `evidence/`:
  - brk_{P,L,O}.txt, brk_changed.txt, downstream_brk.txt
  - grid_{P,L,O}.txt, grid_switches.txt
  - sweep_pristine.txt, sweep_law.txt, downstream_law.txt
  - changed_rows.txt
  - byteverify_surelog.txt, byteverify_uhdm2rtlil.txt
  - attribution.txt, attribution_big.txt
