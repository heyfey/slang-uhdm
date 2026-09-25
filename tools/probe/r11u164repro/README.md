# r11u164: the module/type ground on the strict axis (pair B, refill after pass 160)

Base `d48f8f8a` (branch matrix-1.87). This pass lands the r11u161 decode (rebased by hand) and ten laws of its own on
pair B's ground. Files of the ground touched: `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`, `src/UhdmExporter.cpp`. No line
of `ExprEmit.cpp`, `EmitHelpers.h`, `StmtEmit.cpp` or `ParamEmit.cpp` is edited. The switch helper is `r11u164Law`
(UhdmExporter.cpp, beside `r11u160Law`). `R11U164_OFF=1` drops every r11u164 law, and `R11U161_OFF=1` drops the r11u161
laws. With both set, every one of the 118 grid cases gives the pristine bytes (section 5).

The slang-fenced tests are written `FENCED=` here and are never spelled. `drivers/env.sh` builds the list from
RESUME.md and refuses to go on without four names. Every driver that reads corpus sources or corpus databases
(`drivers/predict_all.py`, `drivers/row.sh`, `drivers/attrib.sh`, `drivers/orderblind.sh`, `drivers/bvmirror.sh`) fails
closed on `$FENCED` and skips those names by word boundary. The byte comparisons ran on hard-link mirrors that leave
out the 8 fenced row-mode databases. No fenced test was run, read or decoded outside the gate sweeps, which dispatch
every row themselves.

The sister pass r11u163 (expression ground) landed in the main tree as `576b21fa` while this pass ran. Every gate
below is measured against the `d48f8f8a` baselines in this worktree, as the brief requires. Section 8 records how
this patch applies on `576b21fa`.

r11u166's macro decode (`tools/probe/r11u166mac`) was not in the main tree at the start, and it had not landed by the
end. So this pass wrote none of the macro-model faces of brief item (2).

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u164_bin/pris.bin` | `76f6b803e83ec4e631b29a1f4d18b1bd` | worktree build of d48f8f8a (system deps, `-j 2`), byte-identical to the main tree's `build/slang-uhdm` |
| `/tmp/r11u164_bin/law.bin` | `f43f2933b26d730acaabbf6083c43dee` | d48f8f8a + this patch (the final build) |
| `/tmp/r11u164_bin/l161.bin` | `2ae472b755b069ec4abdc05b9b61a434` | d48f8f8a + the rebased r11u161 patch alone |
| `/tmp/r11u164_bin/law1.bin`, `lawF.bin`, `lawG.bin`, `lawH.bin` | `2ed3b300`, `aebbbe72`, `270bc3c9`, `e4990c96` | intermediate law builds (rounds 1-4, section 6) |
| `/tmp/r11u164_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the committed comparator |

Sweeps (`tests/sweep.sh --jobs 3`, workdir names all the same length): `/tmp/r11u164_swP` (pristine) and
`/tmp/r11u164_swI` (final law). In the pristine sweep, all 3273 `slang:` lines of the corpus `cmds.txt` files read
`/tmp/r11u164_bin/pris.bin`. In the law sweep, all 3273 read `/tmp/r11u164_bin/law.bin`.

## 2. The laws

| law | switch | site | statement (decode) |
|---|---|---|---|
| § defGenPathSel161 (r11u161) | `R11U161_ROUTE_OFF` (+ `R11U161_SPAN_OFF`, `R11U161_NAME_OFF`) | TypeEmit.cpp `defGenRoute161` + the `emitSyntaxExpr` hier_path loop; ModuleEmit.cpp `emitDefGenStmts` (`setDefGenCaLhs161`) | Delivered unchanged; see tools/probe/r11u161gen/README.md. In a definition-view generate statement, the target, the conditions, case items and the gen-for header are Surelog's SEL form. The base sits at the next component's token, each field stores its own name, and a selected field spans name..`]`. The right side is CFC. |
| § firstOrderedPathSel161 (r11u161) | `R11U161_PORT_OFF` | ModuleEmit.cpp `emitInstance`, the struct-member connection re-scope (`firstOrderedConn161`) | Delivered unchanged. The first actual of an ordered list of two or more takes the SEL form. |
| § enumAliasClone161 (r11u161) | `R11U161_ALIAS_OFF` (+ `R11U161_FILE_OFF`) | TypeEmit.cpp `emitTypedefs`, `enumAliasSyn161`, `enumAliasCloneFinish161`; UhdmExporter.cpp `exportDesign` ($unit) | Delivered unchanged. A module, interface or `$unit` alias of a named enum is a clone of the enum (ElaborationStep::bindTypedefs_). |
| § rangeQueryFoldUnconverted164 | `R11U164_RANGEQ_OFF` | ModuleEmit.cpp `emitContAssigns`, the `$signed/$high/...` sysFold block | Pass-158 sister face S1 (HighLow). A range query's fold (`$high/$low/$left/$right`) is ExprEval's value of the query and is never narrowed to the target. Ours evaluated the assignment's implicit conversion to the one-bit implicit net, which gave `$high(a)` UINT:0 where golden has UINT:2. |
| § rangeQueryDeclNetSize164 | `R11U164_RANGEQSIZE_OFF` | the same block, the UINT branch | Onto a DECLARED net, that constant carries the net's width as vpiSize: golden `wire ccc` gives size 1 and `wire [7:0]` gives size 8 (writeCont's adjustSize). An implicit net keeps the bare value. |
| § caDelayFirstOnly164 | `R11U164_CADELAY_OFF` | ModuleEmit.cpp `emitContAssigns`, the statement delay | Pass-158 sister face S4 / r11u159 residue 2. CompileHelper::compileContinuousAssignment compiles a statement's Delay3 once, before its net-assignment loop, and hands the SAME `delay_expr` to every cont_assign of `assign #d b = a, c = ~a` (reparented each time, so the last one owns it). The definition view therefore lists it under the first cont_assign only. The elaborated view clones one delay per cont_assign, which ours already did. |
| § caDelayParamElabFresh164 | `R11U164_DLYPARAMELAB_OFF` | ModuleEmit.cpp `emitContAssigns`, the elab share decision | Found by the DL grid. A statement whose delay is a PARAMETER reference (`#D`, header, body or local parameter) is re-elaborated in the elaborated view. Golden lists a fresh cont_assign whose delay ref_obj binds the instance's parameter (§ caDelayParamRefSpelling90's elaborated half). Ours shared the definition object with its unbound reference, which uhdm-cmp reads as stage 1 (`ref_obj::Actual_group` RHS `<null>`) on every such module. |
| § modportPortViewParamDef164 | `R11U164_PVMPDEF_OFF` | ModuleEmit.cpp `emitInterfaceInstance`, end of the port-view build | Pass-158 sister face S6. A modport-qualified or generic-restricted port view that is elab_interface_'s fresh copy names its scalar parameters (and their ref_typespec) by the DEFINITION (`work@my_iface.W`), as § portViewParamDefName130 found for the reference-style view. The copy is every view except a NAMED connection whose actual is an unselected name resolving in the instantiating scope. The copies are: ordered connections, selected actuals (`.p(arr[1])`, an interface-array element), generic ports, and names out of scope (§ namedModportOutOfScopeFresh115). elab_parameters_ gives such a copy the definition's parameter object (`inst_assign->Lhs(mod_assign->Lhs())`). |
| § portViewParamShared164 | `R11U164_PVSHARE_OFF` | the same block | That definition parameter is ONE object for every such view of the definition, reference-style views included. Golden lists it under the first view only (interface_array's `p1.b`). Ours minted one per view. A later view's param_assign Lhs now reads the first view's object when the two carry the same value. |
| § defGenSelBaseLeafAtIndex164 | `R11U164_SELBASELEAF_OFF` | ModuleEmit.cpp `emitDefGenStmts`, after § defGenLhsHpBaseAnchor144 | The definition-view generate target `s[i].f[0]`: a genvar-selected base with a SELECTED leaf. Golden anchors the hier_path at the base token, locates the leaf bit_select at its INDEX and names it by the raw path. Found as a byte mover of the r11u161 route law (probe r11v120repro M/m05 moved AWAY: § defGenPathSel161's selected-field rule, which holds for a plain base, named the leaf `<scope>.<path>.<field>`). |
| § bindUnresolvedPathNoName164 | `R11U164_BINDPATHNAME_OFF` | ModuleEmit.cpp `emitInstance`, the synthesised literal path of an unresolvable bind connection | r11u161 residue R4 (mriscv_bind_sva). The distinguisher is an UNRESOLVABLE hierarchical path: the corpus writes `DECODE_INSTR_inst`, while the instance is `DECO_INSTR_inst`. Golden stores no full name on the hier_path or on any element but the leaf. Ours left them unset, so UHDM's ComputeFullName read them through the port (`work@top.C.y.m0`). They get the no-fullname idiom. |
| § genNetDeclAssignLhsShared164 | `R11U164_GENNDAHP_OFF` | ModuleEmit.cpp `emitGenScopes`, the generate-scope net-declaration cont_assign | ComplexHierPath's walk divergence (#190, unmasked by the r11u161 route law). A net declaration whose initializer is a plain HIERARCHICAL PATH (`wire z = A.B.C.x;`) takes the scope net itself as the Lhs in every generate scope, vector nets included. Golden lists no Lhs net under that cont_assign. A constant or an operation initializer, even one over a path, keeps the fresh Lhs. |

### The r11u161 rebase

`tools/probe/r11u161gen/law.patch` (base 5a602076) failed on the current base at three context blocks only:

* the two helper-declaration hunks (TypeEmit.cpp and ModuleEmit.cpp: passes 155 and 160 added the `r11u155Law` and
  `r11u160Law` declarations under the `r11u152Law` line);
* the `copyArrayTypedefTs` hunk, whose trailing context now continues with pass 155's § modAggTfArgLastWriter155
  comment.

The hunks were rebased by extending their context ([evidence/r11u161_law_rebased.patch](evidence/r11u161_law_rebased.patch)).
No line of the laws changed. Their switches and § names are as delivered.

Re-measured on the current base, the r11u161 grid (54 cases, both binaries) reads pristine STRICT_EQUAL 11 → law 34:

* 25 cases change verdict ([evidence/grid/grid_verdicts_r11u161.txt](evidence/grid/grid_verdicts_r11u161.txt));
* the generate-path cases a01-a07, b05, c01-c03 and e01-e03 now read STRICT_EQUAL in both views, because pass 158
  landed the elaborated view's writer since r11u161 was measured;
* downstream, the 11 alias cases e02 e04 e05 e07 e09 e10 e11 e12 e16 e17 e18 go DIVERGENT → IDENTICAL
  ([evidence/downstream/](evidence/downstream/));
* e15 stays DIVERGENT on both binaries.

## 3. Targeted rows (fresh csv rows, `/tmp/r11u164_swI/{surelog,uhdm2rtlil}.csv`; results/ untouched)

**14 corpus row-modes STRICT_NOTEQUAL → CMP_EQUAL, 0 regressions:**

| test (both modes) | corpus | before | fresh row | law(s) (per-switch attribution, `evidence/sweeps/corpus_attribution.txt`) |
|---|---|---|---|---|
| HighLow | surelog | differ:value(1) | `HighLow,default,CMP_EQUAL,,,equal` `HighLow,testflags,CMP_EQUAL,,,equal` | rangeQueryFoldUnconverted164 |
| GenIfIfaceParamStructField | surelog | differ:col(2) | `GenIfIfaceParamStructField,default,CMP_EQUAL,,,equal` (and testflags) | defGenPathSel161 |
| ComplexHierPath | surelog | differ:col(7) | `ComplexHierPath,default,CMP_EQUAL,,,equal` (and testflags) | defGenPathSel161 + genNetDeclAssignLhsShared164 |
| iface_param_port_width | uhdm2rtlil | differ:fullname(2) | `iface_param_port_width,default,CMP_EQUAL,,,equal` (and testflags) | modportPortViewParamDef164 |
| interface_array | uhdm2rtlil | differ:fullname(3) | `interface_array,default,CMP_EQUAL,,,equal` (and testflags) | modportPortViewParamDef164 + portViewParamShared164 |
| interface_array_fanout | uhdm2rtlil | differ:fullname(3) | `interface_array_fanout,default,CMP_EQUAL,,,equal` (and testflags) | modportPortViewParamDef164 + portViewParamShared164 |
| mriscv_bind_sva | uhdm2rtlil | differ:fullname(30) | `mriscv_bind_sva,default,CMP_EQUAL,,,equal` (and testflags) | bindUnresolvedPathNoName164 |

**Downstream rows of the converted uhdm2rtlil tests (fresh, IDENTICAL, `differs` empty):**
`iface_param_port_width,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `interface_array,IDENTICAL,OK,OK,8,8,,`,
`interface_array_fanout,IDENTICAL,OK,OK,22,22,,`, `mriscv_bind_sva,IDENTICAL,NO_GATES,NO_GATES,0,0,,`.

**Improved, still STRICT_NOTEQUAL** (compare_results CHANGE lines):

* Earlgrey_0_1 d/t `line(1730) -> line(1686)` (defGenPathSel161, the 51 predicted definition-view generate paths);
* GenForStructParamBound d/t `fullname(7) -> fullname(3)` (defGenPathSel161). What is left there is the interface
  range `[0:CFG.HSK.DLY]`'s hier_path full name plus the folded bound's location, a residue.

## 4. Gates

| gate | pristine (`/tmp/r11u164_swP`) | law (`/tmp/r11u164_swI`) |
|---|---|---|
| (1) build | `pris.bin` = main tree md5 `76f6b803` | `law.bin` `f43f2933` |
| (2) probe vs golden_probe.csv | 0 / 0 / 0 (EQUAL 2547, STRICT_NOTEQUAL 1540) | regressions 0, conversions 50, changes 73 (EQUAL 2597, STRICT_NOTEQUAL 1490) |
| (3) surelog vs golden_surelog.csv | 0 / 0 / 0 | regressions 0, conversions 6, changes 4 |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | 0 / 0 / 0 | regressions 0, conversions 8, changes 0 |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; not excused 0 | 803 / 66 / 2 / 0, not excused 0; `downstream.csv` identical to the pristine sweep's, row by row (pass 120's eight rows included) |

Both sweeps exit 1 for one reason only: `law index STALE`. The worktree's `src/` carried the r11u161 hunks (and later
this pass's) before `scripts/law_index.py` ran. The patch carries the regenerated `tests/LAWS.md`, `tests/LAWS.csv` and
`tests/CASES.csv`.

(5) uhdm-cmp reads 0 lines on every touched row and case. Every converted row is CMP_EQUAL, every changed row stays
STRICT_NOTEQUAL (judge-equal), and the probe stage has no NOT_EQUAL case.

**(6) Byte movers, corpora** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, on the fenced mirrors; path sets
identical; `evidence/sweeps/byteverify_*.txt`): surelog 18 / 952, uhdm2rtlil 12 / 1608 (SELFCHECK 951 / 952 and 1607 / 1608 flagged).

Attribution (`drivers/attrib.sh`, `evidence/sweeps/corpus_attribution.txt`): every deterministic mover is
deterministic on rerun and returns to the pristine bytes under `R11U164_OFF=1 R11U161_OFF=1`. The switches that change
its bytes are the laws named in section 3, plus:

* OneNetModPort d/t (firstOrderedPathSel161; csv unchanged, differ:file(3) before and after);
* genvar_iface_struct d/t and iface_array_modport_drive d/t (defGenPathSel161: the stored full names now equal the
  computed ones, the dump is identical);
* Rggen/default (portViewParamShared164 + modportPortViewParamDef164 + defGenPathSel161; csv unchanged).

The UVM order-coin family (MiniAmiq d/t, SeqDriver d/t, SimpleUVM t) is attributed order-blind
(`evidence/sweeps/uvm_coin_orderblind.txt`): each differs from its pristine database by exactly the known 4-line
`UINT`/`vpiDecompile` coin.

**Prediction** (`drivers/predict164.cpp` + `drivers/predict_all.py`, over every PRISTINE database of `/tmp/r11u164_swP`,
fail-closed on `$FENCED`; `evidence/prediction/`). It was run before each law sweep. The first file was written before
round 1. The final file adds the tags of the laws added later (`selbase`, `bindpath`, `genndahp`, `dlyparam`) and was
written before the final sweeps.

* Every corpus byte mover is on the predicted list by name: ComplexHierPath (route, genndahp), Earlgrey_0_1 (route),
  GenForStructParamBound, GenIfIfaceParamStructField, genvar_iface_struct, iface_array_modport_drive (route), HighLow
  (rangeq), iface_param_port_width, interface_array, interface_array_fanout (pview), mriscv_bind_sva (bindpath),
  OneNetModPort (port) and Rggen/default (pview + route).
* The predictor is a superset. Among the predicted rows that do not move are DelayAssign t, jeras_tcb_gpio,
  simple_interface and the other `pview` rows whose views are named-modport or already default-named.
* Probe: every probe byte mover is predicted (126 of 4087 probe databases move, all 126 among the 173 predicted).

**Probe byte movers** (`drivers/attrib_probe.sh`, `evidence/sweeps/probe_attribution.txt`): all 126 return to the
pristine bytes under `R11U164_OFF=1 R11U161_OFF=1`. The contributing switches are:

* PVMPDEF 64, PVMPDEF+PVSHARE 55;
* ROUTE+SPAN+NAME 5, ROUTE+NAME 1 (w4_selmem, byte only, STRICT_EQUAL both);
* CADELAY 1 (r11u88 a6_commadrive, byte only, `col(2)` both, order-blind 18 → 12 lines: the interface's comma-list
  delay).

The 123 verdict movers are among them. The third byte-only mover is r10vrgg16 cells/v7 (pview, `file` both,
177 → 173).

**Canaries** (`evidence/sweeps/canaries.txt`, against the d48f8f8a baselines):

* canaries.sh surelog ok=50 changed=2 (Earlgrey_0_1 d/t, the attributed CHANGE; the pristine control reads ok=52
  changed=0);
* canaries.sh uhdm2rtlil ok=16 changed=0;
* ctcan2 surelog ok=58 changed=0 PASS (EXPECT_UNKNOWN=1);
* ctcan2 uhdm2rtlil ok=2 changed=0 PASS (EXPECT_UNKNOWN=6).

**Probe CHANGE lines** (`evidence/sweeps/probe_compare.txt`): every one lowers the count on its first field, except
one.

* r11v1repro/vA `depth(1) -> col(2)`: the pristine walk DIVERGED at #292 (the port view's param_assign, which the
  shared definition parameter now lists once). The walk now reaches a pre-existing hier_path column face (`u.mp` in
  `mp_pos a3 (u.mp, ...)`, ExprEmit).
* The rgg3 / rgg4 / vrgg3 / vrgg4 / r11u115 families are the port-view parameter names (pview laws).

**Landed-law controls** (`drivers/bytes.sh` over every committed case of r11u118repro, r11u119repro, r11u120repro,
r11u124repro, r11u130repro, r11u131repro, r11u152repro, r11u155repro, r11u157hp, r11u158repro, r11u159verify,
r11u160repro, r11u162verify, r11v11u118repro, r11v120repro, r11v124repro, r11v131repro, r11v158repro, v11u152repro,
v11u155repro and v11u160repro; `evidence/controls/`):

* 2009 cases processed = listed; 33 move and 1965 keep their bytes;
* verdicts (`prior_pass_movers_verdicts.txt`): 21 of the 33 go STRICT_NOTEQUAL/stage 1 → STRICT_EQUAL, and every other
  mover moves toward golden order-blind (for example e03_local_alias 95 → 48 lines, e08_iface_alias 117 → 92);
* one STRICT_EQUAL case reads two more order-blind lines, r11u130 g6/p07_two_level (30 → 32). Those lines are the
  `weaklyReferenced` tail: § portViewParamShared164 leaves the later view's own parameter object unreachable. The tail
  is outside the judge's walk and the plugin's reach (golden 123 tail lines, pristine 129, law 143; downstream
  unchanged);
* the r11u120 and v11u160 cases that move are port-view and generate-path cases; pass 120's eight downstream rows read
  IDENTICAL in the law sweep.

## 5. Grids (`cases/`, 63 law cases, first line `// § <law>`; goldens from the pinned Surelog with check_probe's
arguments, `drivers/case.sh`)

Pristine STRICT_EQUAL 14 → law 43 of 63 ([evidence/grid/grid_verdicts_own.txt](evidence/grid/grid_verdicts_own.txt)).
No case that pristine read STRICT_EQUAL reads otherwise with the law. Switch attribution over these 63 cases, r11u161's
54 and r11v120's m05 ([evidence/grid/switch_attribution.tsv](evidence/grid/switch_attribution.tsv)): every case returns
to the pristine bytes under `R11U164_OFF=1 R11U161_OFF=1`, and each mover names its switches.

Downstream through the harness's `one()` (`drivers/dscase.py`, 81 cases: r11u161's `al/` and every case here but
`SB/`'s controls; `evidence/downstream/`):

* pristine: DIVERGENT 12, EQUIVALENT 3 (PV a11, SB b02, b04);
* law: DIVERGENT 1 (al/e15), EQUIVALENT 2 (b02, b04 on both binaries);
* no case leaves IDENTICAL;
* d06 is SURELOG_FAIL (no reference).

| dir | law | cases | converted | controls / residue |
|---|---|---|---|---|
| RQ | rangeQueryFoldUnconverted164, rangeQueryDeclNetSize164 | 9 | q01 q03 q06 (implicit net: `$high`, `$left`, ascending `$right`) | q02 ($low 1) and q08 ($signed) are controls. q04 q05 q09 (declared nets) stay stage 1 on a pre-existing face (a weakly-referenced range constant of the sys_func_call's typespec carries a value golden's lacks) and move from 2 to 1 order-blind dump line. q07 (`$high` of a variable): value right now, but golden hands back the declared range-bound object itself, which is located and decompiled (residue). |
| DL | caDelayFirstOnly164, caDelayParamElabFresh164 | 15 | d01 d02 d03 d08 (lists), d05 d09 d10 d11 d12 d15 (parameter delays) | d04 (single literal) and d07 (net declaration) are controls. d13 (`#(D)`) and d14 (`#(D+1)`) are unchanged: pass 90 abstains there. d06 (strength + delay) is SURELOG_FAIL. |
| PV | modportPortViewParamDef164, portViewParamShared164 | 20 | a02 a03 a04 a06 a08 a10 a11 a12 a15 a17 a18 a19 | a01 a05 a07 a09 a14 (named, in scope: path names) are controls. a13 (generic port) takes the definition names; its first record is a program-like ref line face. a16 and a20 (generate-block connection) are stage 1 on both binaries. |
| SB | defGenSelBaseLeafAtIndex164 | 5 | - | b01 (m05's shape) now differs only by the ELABORATED refs (`work@top.g[0].s[i].f.i`, ExprEmit: sister). b02 b04 are stage 1 on both and move toward golden (70 → 62, 155 → 148). b03 and b05 are controls. |
| BU | bindUnresolvedPathNoName164 | 1 | u01 | - |
| ND | genNetDeclAssignLhsShared164 | 13 | n06 n11 n12 | n03 n04 n07 n09 n10 n13 are controls. n01 n02 n05 n08 are stage 1 on both, on the RHS reference binding of a generate-scope net declaration (another face). |

## 6. Development breaks found and fixed before the final sweep

* Round 1 (`law1.bin`, sweep `/tmp/r11u164_swL`): the r11u161 rebase moved probe `r11v120repro/grid/M/m05` AWAY from
  golden (68 → 72 order-blind lines; `m05` is in tools/probe, not in the gate). This was fixed by
  § defGenSelBaseLeafAtIndex164 (m05 now 52, its remaining face is the elaborated view).
* Round 3 (`lawG.bin`): the port-view laws turned probe `r10rgg3repro/m1_port_passthrough` from fullname(8) into a walk
  divergence. The inner module's pass-through `.p(p)` view is a named, in-scope connection, so golden keeps path names
  there, but its connected instance is an array element, which `namedModportPortView9` excludes. The fix was the
  connection-syntax rule.
* Round 4 (`lawH.bin`): that syntax rule first ignored out-of-scope actuals, and probe g1, v5, o08, vL and q03 lost their
  conversions. The fix: an out-of-scope named actual (`actualOutOfScope16`) is a copy. A first attempt that keyed the
  rule on the param_assign's value was refuted by m1's `u.p`, which reads the receiving module's AW = 7 and is still
  definition-named.
* The DL grid showed that every module with a parameter-named delay was stage 1 (the elaborated delay reference was
  unbound), and that the list law's sharing moved the list form 22 → 26 order-blind lines through that face. The fix
  is § caDelayParamElabFresh164, and all ten parameter-delay cases are now STRICT_EQUAL.

## 7. Decodes, sister-ground faces and residues (ranked by row-modes within reach)

**Sister-ground faces (the fix sits in a file this pass does not own):**

* S2, pass-158 grid `sc/c10`: the gen-if scope's `assign q = 3'(-1)` keeps the cast operation. Golden folds a
  loc-less, parentless UINT:7 at the target width, the same shape its gen-for twin `2'(7)` already reads. The fold is
  reached only through ExprEmit's emitExpr under `genCaLoopParamFold` / `genCaChildLoopFold21`, and
  § sizeCastCaLitMask158's mask lives there. This is the sister's to extend to the if-generate scope; ModuleEmit only
  sets the flag.
* S3, `sc/c12`: STRICT_EQUAL already on the base (pass 158's § sizeCastNamedWidthNoCast158v). Nothing is left.
* SB b01 / r11v120 M/m05: the elaborated view's references under a genvar-selected path (`work@top.g[0].s[i].f.i`)
  belong to ExprEmit's elaborated hier_path mint.
* r11v1repro/vA col(2): the hier_path over a modport expression (`u.mp`), ExprEmit.

**S5 confirmed:** the escaped name holding `#` (r11u160repro/cases/S7/s01) exits 3 with slang's message
(`error: expected '('`) and writes no database. That is a clean SLANG_REJECT. Surelog on the same source also exits 3
and writes no database, so the case has no golden. It is a SURELOG_FAIL row in any harness (no comparison), not a
fence.

**Residues on this ground, ranked:**

1. **OneNetModPort d/t file(3) + OneNetModPortGeneric d/t line(2)** (4 row-modes): a PROGRAM's interface port. The
   decode-only repros are `evidence/residue/PP` (p01, p03; p02 is the module control). Three faces:
   * the program port's Low_conn ref_obj is unlocated in golden (both views);
   * the modport view under that Low_conn lists io_decls whose Expr is the connected instance's variable (shared),
     where ours mints `work@TOP.tb.intf.drive`;
   * the plain-port view is unnamed in golden and names its variables `intf.drive`.
   Site: ModuleEmit's program port binding.
2. **GenerateUnnamed d/t fullname(9)**: the gate terminal refs are named through Surelog's unflattened generate path.
   `genBlkIndex` is local to each DesignElaboration::elaborateInstance_ call, is incremented for every conditional and
   loop generate construct, and restarts inside every nested scope. An else-if adds a level. The heuristic parse-tree
   walk of the else-if branch (DesignElaboration.cpp, the `If-Else stmt` branch, `refresh instName`) decides the reused
   name. Not landed: the index of a later unnamed block needs that walk transcribed and gridded.
3. **GenForStructParamBound d/t fullname(3)**: an interface array variable's range `[0:CFG.HSK.DLY]`. The hier_path
   stores no full name in golden, and golden locates the folded bound at the struct parameter's value (`1` at 10:39),
   ours at the path. Decode-only repros: `evidence/residue/HR` (stage 1 on the bound's size and location).
4. alias residues of r11u161:
   * e15 (an alias with an added packed dimension: Surelog compiles a fresh typespec; DIVERGENT on both);
   * e08 and e13 (the interface alias variable is `packed_array_var` in golden);
   * e04, e05, e09 and e18 are unmasked to the bare enum constant folded in golden's elaborated cont_assign
     (ExprEmit).
5. The range-query face on a declared net (RQ q04 q05 q09, stage 1) and on a variable (q07), see section 5.
6. Not reached in this pass: ClassTypeParam, HierPathTypespec t (N1174), UnionCast's union file (N0430), the
   UVM/Earlgrey-only clusters (N0067/N0068, N0069/N0072, N0051, N0093, N0070), the class handle initialised to null
   under § unsupportedTsInitEnd152, the $unit aggregate last writer through a DPI formal or class method formal, the
   macro-expanded interface-member connection, the positional connection of a parameter struct array, and the
   `localparam type` struct written bare and procedurally.

## 8. Files

* `cases/<dir>/<case>/dut.sv`: 63 law cases, first line `// § <law>`. `evidence/residue/{HR,PP}/*.sv.txt` hold the
  decode-only repros.
* Drivers, grids and bytes: `drivers/env.sh`, `drivers/case.sh` (one case: golden + ours + uhdm-cmp + uhdm-strictcmp),
  `drivers/casedist.sh` (order-blind dump distance), `drivers/offcheck.sh` (landing-off bytes + per-switch
  attribution), `drivers/bytes.sh` (landed-law case controls).
* Drivers, rows and prediction: `drivers/row.sh` (one corpus row's strict records), `drivers/predict164.cpp` +
  `drivers/cc.sh` + `drivers/predict_all.py`.
* Drivers, attribution: `drivers/attrib.sh` and `drivers/attrib_probe.sh`, `drivers/orderblind.sh`,
  `drivers/bvmirror.sh`, `drivers/dscase.py`.
* `evidence/`:
  * `prediction/`, `grid/`, `downstream/`, `controls/`, `sweeps/` (compare outputs, byteverify, attribution, canaries,
    the UVM coin);
  * `r11u161_law_rebased.patch`.

On `576b21fa` (r11u163 landed): the three `src/` files of this patch apply clean (`git apply --cached --check` against a scratch index of `576b21fa`; r11u163 touched `EmitHelpers.h`, `ExprEmit.cpp` and `ParamEmit.cpp` only). `tests/LAWS.md` is generated and must be regenerated there (`python3 scripts/law_index.py`).
