# r11u222 — the strict ground map, fourteenth edition (measured at `551c9751`; addendum at `75a564b0`)

Measurement only: no file under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` changes. The map covers
every `STRICT_NOTEQUAL` row-mode of the committed baselines and every probe case, clusters their differing strict
records by (first field, object type, shape), pins each cluster's example object to the emitter function that mints
it, routes the clusters to the two grounds and the live pairs, and measures every landing since map 13
(`tools/probe/r11u211map`, measured at `4acbe8a5`, addendum at `62ac216e`) for records moved away from golden.

## 0. Restart, bases, what landed since map 13

* **Restart.** A first run of this map started at 00:34 on 2026-09-29 on base `896ec643` and stalled at 02:23 after
  repeated tool safety-check outages (stopped at 03:45). Its worktree and scratch held a complete strict-run pass, the
  cluster map, ten site pins, the measured r11u218 decode patch (applied as is at `896ec643`), all nine landing-off
  state sweeps and their away census, the UVM census and distance, the downstream faces and the determinism draws,
  but no README. Pass 220 (pair A, `551c9751`) landed the r11u218 decode's law patch while it ran. **This edition
  re-measures everything at `551c9751`** in a fresh worktree, reusing from the first run only: its drivers (copied,
  with the `*b.py` successors where the base changed), its ten site pins whose example object is unchanged (tagged
  `[r11u222 pin at 896ec643]`), its content-keyed record cache for the away census (keyed by the md5 of a database, so
  a reuse can only hit an identical database), and its `896ec643` analysis as the "before" side of section 3 (proved
  byte-identical to the `R11U220_OFF` state at `551c9751`, below). Its numbers at `896ec643` are quoted as such in
  [evidence/first_run_896ec643/](evidence/first_run_896ec643/).
* **Base measured: `551c9751`** (pass 220). The HEAD sweep read is the pass-220 integration sweep (read-only): its
  csvs equal `results/golden_*.csv` at `551c9751` cell for cell (1596 / 1742 / 4087 rows, 0 differences), all 3273
  corpus `slang:` lines name the main tree's `build/slang-uhdm`, then `2510f4fe` (built 02:47, before the sweep).
* **Landed while this edition ran: pass 223** (pair B, `75a564b0`, 04:14). Everything above section 13 is at
  `551c9751` and is not edited for it; section 13 is the addendum at `75a564b0`.
* Landings since map 13, all read (README verdicts, laws, conversions, residues): pass 209 (`b69dc2da`), r11u213
  (`6dcc0818`), pass 210 (`a727b8c7`), pass 212 (`745f66ab`), r11u214 (`83ee16d6`, decode), r11u217 (`0a682d73`),
  pass 216 (`c4f26079`), r11u218 (`c624cafb`, decode), pass 215 (`57ce3ae8`), r11u221 (`162790c3`), pass 219
  (`896ec643`), **pass 220 (`551c9751`)**, and in the addendum pass 223 (`75a564b0`).
* The live pairs counted (section 6): **pair A r11u224** (ExprEmit / EmitHelpers / StmtEmit / ParamEmit, base
  `551c9751`) and **pair B r11u223** (TypeEmit / ModuleEmit / UhdmExporter / TaskFuncEmit / uhdm_main, base
  `896ec643`; it landed as pass 223, so section 13 audits this map's pair-B prediction against it at once).

## 1. Summary

| measure | at `551c9751` |
|---|---|
| fail list (committed baselines) | **31 row-modes / 17 tests** (surelog 25: default 14, testflags 11; uhdm2rtlil 6: 3 + 3), **644 probe cases** |
| first fields (csv detail column) | surelog: file 8, endcol 6, type 3, fullname 3, line 2, endline 2, depth 1; uhdm2rtlil: line 4, fullname 2; probe: fullname 203, line 105, endcol 79, type 74, name 59, depth 50, file 39, col 15, endline 10, value 9, decompile 1 |
| clusters | **709** (297 with a corpus row, 530 with a probe case); 698 keep a map-13 id, 11 are not in map 13 (6 reuse an earlier map's id, 5 new: N2471-N2475) |
| analyzer vs tool | the python mode-4 rule agrees with `uhdm-strictcmp`'s own verdict on **675 of 675** jobs (31 row-modes + 644 cases) |
| pass 220 (section 3) | anon_struct_packed_dim d/t converted, 11 probe cases; 68 cluster keys gone and 6 new; away census **0 lost chain-keyed**, 7730 toward |
| yield of the live pairs (optimistic) | pair A r11u224 0 row-modes / 58 cases; pair B r11u223 1 / 21; both **3 row-modes / 2 tests / 88 cases** (InterfArrayBind d, cfg_func_width_loop d/t) |
| **fail list after both live pairs** | **28 row-modes / 15 tests, 556 cases** optimistic; **30 / 16, 604** counting only the heads a brief item names |
| ranked OPEN clusters with a row after the pairs | 177 (ground A 35, ground B 142) |
| near rows (one open cluster after the pairs) | InterfaceModPort d/t (N0040), PreprocTest d/t (N0056), FuncStructVal d/t (N0891) |
| away census since map 13 | **0 records lost chain-keyed for every landing**, pass 220 and (addendum) pass 223 included (section 9); every flat-key "loss" (pass 219's 34, pass 220's 650 / 598, pass 223's 298) is an excess removal at its own chain; the reversed controls read 3091 / 7730 / 5942 lost |
| determinism | one hash per mode for Earlgrey_0_1, SeqDriver (the r11u221 cure holds), SimpleUVM, BuildUVMPkg; MiniAmiq d/t 2 hashes (0 dump lines: a symbol-table order coin, **writer pinned: § refFullNameThroughNamedExpr175's pointer-ordered walk**, confirmed by the switch); Scoreboard d 3 hashes (0 order-blind lines, 92 raw: the svunit listing order) |
| rebuild identity | three independent builds at `551c9751` byte-identical (`2510f4fe`) |
| addendum `75a564b0` (pass 223) | 0 row-modes converted (31 / 17 stay), 5 probe cases (**639**); N0318 and N0706 gone, N0123 9 -> 2 rows, N0263 6 -> 2 rows |

## 2. Inputs, binaries, the fence

| binary (frozen `chmod 555` in the scratch bin directory before any measurement) | md5 | what |
|---|---|---|
| `slang-uhdm` | `2510f4fe44619abb4eae492a1a0e737f` | `551c9751` built in this worktree (`-DSLANG_UHDM_USE_SYSTEM_DEPS=ON`, `-j 2`); equal to the main tree's build that made the HEAD sweep |
| `slang-uhdm.rebuild2` | `2510f4fe44619abb4eae492a1a0e737f` | a second build directory, configured and built from nothing (rebuild identity, section 8) |
| `slang-uhdm.g1` | `39d02abab113fbbe6659fc5e9f93e752` | `-DCMAKE_CXX_FLAGS=-g1`, target `slang_uhdm` (the site pins; writes the same bytes as `slang-uhdm` on the rebuild cases) |
| `slang-uhdm.h223` | `abaa83b8a0194539219d406e055c8b51` | the main tree's build at `75a564b0` (pass 223), copied after it landed (section 13) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the gate's comparator (the main tree's build; `tools/` unchanged since `896ec643`) |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's variant with the raw full name (drivers/cc.sh), for record dumps and the raw census |
| `objrank`, `sym`, `ord` | `3e213a15`, `2a0a870c`, `dec151d9` | creation rank of an object (pins); symbol table; storage order (r11u221's sources) |
| `st<k>.sh` | | `exec env <switches> slang-uhdm "$@"`: the landing-off states of section 9, `st175.sh` (section 8), `sth3.sh` (section 13) |

Every `slang:` line of every corpus `cmds.txt` of this map's own sweeps names its sweep's wrapper or binary (3273 of
3273 per sweep, [evidence/sweeps/cmds_binary_audit.txt](evidence/sweeps/cmds_binary_audit.txt)).

**The pristine gate sweep reproduces HEAD.** `tests/sweep.sh --jobs 3` with `slang-uhdm` in this worktree: probe
3443 + 644 **0/0/0**, surelog **0/0/0**, uhdm2rtlil **0/0/0**, downstream **803 / 66 / 2 / 0** (the sweep's exit 1 is
the law index's staleness from this untracked directory alone). byteverify (`SELFCHECK=1`, fenced databases left out
of both mirrors unread) against the HEAD sweep: **1 mover of 2560**, MiniAmiq default (`99fed9d5` vs `21ff47e0`, the
symbol-table order coin of section 8, uhdm-dumps identical); the probe databases, compared by path-normalised
uhdm-dump since the two sweeps ran from different checkouts: **0 of 4087**.

**The fence.** Every driver that reads databases, sources or case lists takes the four slang-fenced names from the
`FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed (`drivers/common.py fenced()`,
`drivers/env.sh`); no fenced name is spelled anywhere in this directory. The four fenced tests hold no
`STRICT_NOTEQUAL` row (jobs.py: `fenced_skipped 0`); their eight corpus databases per sweep are left out of every byte
mirror unread (`fenced_skipped=8`). The gate sweeps dispatched every row as the gate mandates; no binary, gdb or
script of this map ran on a fenced test's sources or databases outside them. A grep of this directory for the four
names reads 0.

## 3. Pass 220 landed the r11u218 decode patch: the cross-section with and without it

The brief's item (3) asked for the unlanded r11u218 patch measured with and without; pass 220 landed it (with nine
laws of its own) at `551c9751`, so it is measured three ways:

* **Without**: the state `R11U220_OFF` at `551c9751` (drops all thirteen laws of pass 220, the four r11u218 ones
  included). Its sweep **reproduces the `896ec643` pristine sweep byte for byte: 0 of 2560 corpus databases and 0 of
  4087 probe databases differ** (probe by normalised dump), and its gate reads exactly pass 220's claimed movements
  reversed (probe 11 regressions + 11 changes, surelog 7 changes, uhdm2rtlil anon_struct_packed_dim d/t). So the first
  run's `896ec643` analysis is the "without" map.
* **r11u218 alone**: the state `R11U218_OFF` against pristine (the r11u218 half); and the first run's measurement of
  the patch applied as is at `896ec643`.
* **With**: HEAD.

| | without (`896ec643` = `R11U220_OFF`) | r11u218 alone (first run, `896ec643` + patch) | **with (HEAD `551c9751`)** |
|---|---|---|---|
| corpus STRICT_NOTEQUAL | 33 row-modes / 18 tests | 33 / 18 (0 converted; Earlgrey_0_1 d/t `endcol(39)` -> `fullname(19)`) | **31 / 17** (anon_struct_packed_dim d/t -> `CMP_EQUAL`) |
| probe STRICT_NOTEQUAL | 655 | 647 (8 converted) | **644** (11 converted) |
| cluster keys | 771 | 726 (47 gone, 2 new) | **709** (68 gone, 6 new) |
| chain-keyed away census (vs without) | - | 0 lost / 4511 toward (`R11U218_OFF` at HEAD: the same 4511) | **0 lost / 7730 toward** (pass 220's own census: 7730) |
| flat key | - | 650 canonical / 598 raw "lost", **all excess removals** in place | the same 650 / 598, all excess removals (0 unexplained) |
| UVM order-blind distance MiniAmiq / SeqDriver (dist) | 5941 / 4598 | 3368 / 2724 | **2461 / 2122** |
| UVM family census (5 rows' default databases) | 21,112 objects in 209 clusters | 16,339 in 175 | **15,588 in 168** (14,792 without Scoreboard's coin draw, section 11) |

**Pass 220's movement of the map** ([evidence/landing220.txt](evidence/landing220.txt), drivers/landing220.py, keyed
by cluster key): converted anon_struct_packed_dim d/t (its only cluster N0820 gone) and the probe cases
r10earl_repro/i, r10uvm111repro/g111_a, r10uvm127repro/g127_c_import, r10uvm226repro/grid226/a11_nested,
r10v111repro/v111_b1, v111_b2, v111_b7, r10v147repro/v147_i, r10v184repro/gv184_h_retpin,
r10v194repro/v194_e_explclone, r11u109repro/grid/hp/h03_gen; changed BuildUVMPkg d/t `line(31)` -> `line(19)`,
Earlgrey_0_1 d/t `endcol(39)` -> `fullname(19)`, Scoreboard d `file(32)` -> `file(30)`, SimpleUVM d/t `file(56)` ->
`file(54)`. **68 keys gone**, 1 with 9 row-modes (N0185, a constant's end column under an assignment: the string-literal
span laws), 32 with the four MiniAmiq / SeqDriver row-modes (the clone-return family of § importCloneSharesHomeReturn218
and the clone select indices of § cloneHpIdxNamesByChain220: N0485 N0513 N0514 N0520 N0537 N0539 N0664 N0606 N0598
N0637 N0665-N0669 N0597 N0578 N0607 N0599 N0490 N0621 N0671 N0622 N0641 N0575 N0580 N0593 N0642-N0644 N0608 N0278),
N0017 (BuildUVMPkg and MiniAmiq d/t: a constant's end span under a system call), N0785-N0788 (BuildUVMPkg d/t: the
path-select names), N0807 N1012 N1013 N0956 N1033 N1104 N1023 (Earlgrey_0_1 d/t: the qualifier and path-select names of
the r11u218 laws), N0820 (anon_struct_packed_dim d/t), N2388 N1565 N1619 N1719 (Earlgrey, 1 mode each), and 18
probe-only keys;
fell: N0054 9 -> 2, N0512 N0175 N0511 N0553 N0480 N0510 4 -> 0, N0073 4 -> 2, N0001 5 -> 3, N0005 2 -> 0; grew: none.
**6 new keys**: N2474 / N2475 (r10v194repro/v194_a_explicit: the clone-return case the law names under the
importer's own class where golden holds the home object, r11u218's residue) and four Scoreboard keys N1211 N1212
N1438 N1439 that are the svunit listing-order coin's other draw (section 8), not a law.

**The first run's own prediction for pair A r11u220, audited.** At `896ec643` it credited pair A (optimistic, on top of
r11u218) with anon_struct_packed_dim d/t and struct_param_func_config d/t (4 row-modes / 2 tests) and 90 probe cases;
named-only anon_struct_packed_dim d/t. Pass 220 converted **anon_struct_packed_dim d/t** (predicted, named) and **11
cases** (8 are r11u218's, measured exactly by the first run; 3 more from its own laws). It did not
take struct_param_func_config: its section 6.3 decoded the row's first records as TypeEmit's (`buildStructTs`, the
sister's), which this edition applies as a ground override (section 6). The credit that failed is again a row the
brief named but whose first record was on the other ground.

## 4. The fail list at `551c9751` with sites ([fail_list.csv](fail_list.csv), [probe_fail_list.csv](probe_fail_list.csv))

| corpus | test | cell d / t | clusters d/t | first cluster (ground) | first site | first open after the pairs (optimistic) | open after pairs | clears | first open after the named heads | open after named | downstream |
|---|---|---|---|---|---|---|---|---|---|---|---|
| sur | InterfArrayBind | differ:fullname(1) / - | 1/- | N0427 (B) | emitExpr (ExprEmit.cpp, law elabIfArrIdxChainName205) < emitContAssign | - | 0/- | yes (pair B, optimistic) | - | 0/- | - |
| sur | InterfaceModPort | differ:endcol(12) / differ:endcol(12) | 1/1 | N0040 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedP | N0040 | 1/1 | no | N0040 | 1/1 | - |
| sur | PreprocTest | differ:endcol(2) / differ:endcol(2) | 1/1 | N0056 (B) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (Para | N0056 | 1/1 | no | N0056 | 1/1 | - |
| sur | LogicTypespec | differ:endline(3) / differ:endline(3) | 4/4 | N0422 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitPackage ( | N0422 | 4/4 | no | N0422 | 4/4 | - |
| sur | FuncStructVal | differ:endcol(7) / differ:endcol(10) | 5/6 | N1096 (A) | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprE | N0891 | 1/1 | no | N0891 | 2/3 | - |
| sur | Scr1SvTests | differ:type(1) / differ:type(1) | 17/17 | N0791 (B) | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInsta | N0284 | 16/16 | no | N0284 | 16/16 | - |
| sur | BlackBePipeInt | differ:type(1) / differ:depth(1) | 20/23 | N0868 (A) | emitExpr (ExprEmit.cpp, law r10fsv2) < emitParameters (ParamEmit.cpp,  | N2471 | 3/6 | no | N0964 | 19/21 | - |
| sur | Rggen | differ:file(3) / - | 20/- | N0141 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespe | N0141 | 20/- | no | N0141 | 20/- | - |
| sur | Earlgrey_0_1 | differ:fullname(19) / differ:fullname(19) | 53/45 | N0812 (A) | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitMixedHierPath  | N0812 | 51/43 | no | N0812 | 51/43 | - |
| sur | BuildUVMPkg | differ:line(19) / differ:line(19) | 51/51 | N0072 (B) | emitTaskFuncs (TaskFuncEmit.cpp, law classHandleRetTsNameUnlessSameHom | N0120 | 22/22 | no | N0072 | 48/48 | - |
| sur | Scoreboard | differ:file(30) / - | 61/- | N0123 (B) | makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < operator( | N0120 | 24/- | no | N0337 | 53/- | - |
| sur | SimpleUVM | differ:file(54) / differ:file(54) | 67/67 | N0123 (B) | makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < operator( | N0120 | 23/23 | no | N0337 | 57/57 | - |
| sur | SeqDriver | differ:file(7) / differ:file(7) | 130/130 | N0123 (B) | makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < operator( | N0131 | 65/65 | no | N0266 | 112/112 | - |
| sur | MiniAmiq | differ:file(7) / differ:file(7) | 136/136 | N0123 (B) | makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < operator( | N0131 | 65/65 | no | N0266 | 117/117 | - |
| uhd | OutputSizeWithParameterOfInstanceInitializedByStructMember | differ:line(8) / differ:line(8) | 4/4 | N0191 (B) | emitDroppedCall14 (StmtEmit.cpp, law classArgBind12) < emitBadConcatFr | N0191 | 4/4 | no | N0191 | 4/4 | IDENTICAL |
| uhd | cfg_func_width_loop | differ:line(3) / differ:line(3) | 7/7 | N0263 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespe | - | 0/0 | yes (pairs A+B, optimistic) | N0794 | 6/6 | IDENTICAL |
| uhd | struct_param_func_config | differ:fullname(5) / differ:fullname(5) | 7/7 | N0817 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | N0817 | 5/5 | no | N0817 | 7/7 | IDENTICAL |

Columns: the strict cell per mode; clusters per mode; the row's first cluster (the earliest differing record's
cluster) with its ground and pinned site; the first cluster still OPEN after both pairs (optimistic) and the count of
open clusters; whether the pairs clear it; the same against the NAMED heads only; the downstream verdict of the
uhdm2rtlil rows. `probe_fail_list.csv` has the same per case (first cluster, coverage, ground, site, counts, clears).

**First clusters of the probe cases** (top 20; [evidence/tables/t_pfirst.md](evidence/tables/t_pfirst.md)):

| first cluster | probe cases it heads | clears (pairs, optimistic) | ground | status | key | top laws |
|---|---|---|---|---|---|---|
| N0284 | 44 | no 44 | B | OPEN (map 13 ground-A+B step 4) | `struct\|ours-only:fewer-copies\|constant\|under:cont_assign` | srlgUnvaluedActualLitRetFold8:19 loopCaParamReadKeepsLiteral116:10 caS |
| N0039 | 43 | no 43 | B | OPEN (map 13 gave it to pair B r11u209; passes 209 | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | nestedParamActualTs6:22 genIfUnvaluedFuncParam7:4 satArrArgFirstElem5: |
| N0263 | 34 | no 30, yes pairs A+B 2, yes pair B 2 | B | COVERED r11u223 (brief item: pass 216 residue 2 /  | `span\|logic_typespec\|line+col+endline+endcol\|under:ref_typespec` | caIfacePortDeclNetMint93:7 tpPackedArrayTsVar108:5 tpPackedArrayTsVarA |
| N0738 | 27 | no 27 | B | OPEN (map 13 gave it to pair B r11u209; passes 209 | `name\|logic_typespec\|tok:id::->\|under:ref_typespec` | pkgTdQualParamCopiesListing111:11 defPkgMemberTdOfNamedShares108:8 pkg |
| N0739 | 26 | yes pair A 22, no 4 | A | COVERED r11u224 (brief item: pass 220 residue 6 (m | `struct\|ours-only:fewer-copies\|ref_obj\|under:cont_assign` | pkgRhsStructBareCopy111:14 defPkgMemberTdOfNamedShares108:11 tpPackedA |
| N0003 | 24 | no 24 | A | OPEN (map 13 gave it to pair A r11u207; passes 207 | `fullname\|ref_typespec\|golden-empty\|under:operation` | patParamEvalFuncRead26:12 catParamLeftoverReduce28:6 patParamLeftoverS |
| N0008 | 18 | yes pair B 13, no 5 | B | COVERED r11u223 (brief item: pass 219 residue 5 (N | `fullname\|ref_typespec\|golden-empty\|under:constant` | impFoldRhsMirrorsLhsTs201:7 sizeDimOvrChain4:4 genCaReplWholeFold78:3 |
| N0479 | 16 | no 16 | B | OPEN (map 13 ground-A+B step 12) | `struct\|golden-only:fewer-copies\|class_typespec\|under:ref_typespec` | classTdCloneSpecOverridesOwnArgs112:12 classTdCloneTakesTheBasesEmptyL |
| N1916 | 12 | no 12 | B | OPEN | `struct\|golden-only:fewer-copies\|logic_net\|under:cont_assign` | caIfaceNdaNameFoldsToParamValue88:9 caIfaceElabNetDeclAssignListing88: |
| N0040 | 9 | no 9 | B | OPEN (map 13 ground-B step 1) | `span\|logic_typespec\|endcol\|under:ref_typespec` | caIfaceNdaNameFoldsToParamValue88:5 caIfaceElabNetDeclAssignListing88: |
| N0084 | 9 | no 9 | A | OPEN | `fullname\|ref_typespec\|tok:id@id.id.->\|under:typespec_member` | tpAnonAggParamTsNoStamp47:7 genCaTypeParamCastUnsupported113:1 typePar |
| N0097 | 8 | yes pair A 8 | A | COVERED r11u224 (the UVM ground-A families, optimi | `span\|hier_path\|endcol\|under:assignment` | shellCallKeepsItsSyntax167:2 parensLessFuncRefIsRefObj:2 droppedCall14 |
| N0744 | 8 | no 8 | A | OPEN | `span\|param_assign\|endcol\|under:package` | macroPasteDotText104:8 |
| N0494 | 8 | no 8 | B | OPEN | `fullname\|ref_typespec\|golden-empty\|under:packed_array_typespec` | typeParamAnonAggDefault107:5 tpElemRebindElabPort110:1 typeParamNamedE |
| N0746 | 7 | no 7 | A | OPEN (map 13 ground-A+B step 10) | `file\|int_typespec\|golden-empty\|under:ref_typespec` | sizeDimOvrChain4:4 loopCaParamReadKeepsLiteral116:3 portViewRangeRecvP |
| N0129 | 7 | no 7 | A | OPEN (map 13 ground-A+B step 10) | `fullname\|ref_typespec\|tok:->.id\|under:constant` | genCaUnboundTernConcatFence23:2 insideSetFirstRangeTruncates99:2 genEl |
| N0108 | 7 | no 7 | B | OPEN | `fullname\|ref_typespec\|tok:id@id.id.id.->\|under:typespec_member` | tpStructKindNet112:5 typeParamAnonAggMemberNoReduce35:1 typeParamAnonA |
| N0051 | 6 | yes pair B 5, yes pairs A+B 1 | B | COVERED r11u223 (a UVM/Earlgrey first record, grou | `span\|class_typespec\|endcol\|under:ref_typespec` | ifaceDefArrayNetIsAnyUnpackedDim225:1 classTdCloneTakesTheBasesEmptyLi |
| N0127 | 6 | no 6 | B | OPEN | `span\|array_typespec\|endcol\|under:ref_typespec` | localBlockStmtSelBinds122:5 castTargetKeywordTypespecKind96:1 |
| N0264 | 6 | no 6 | B | OPEN (map 13 ground-A+B step 7) | `span\|int_typespec\|endcol\|under:ref_typespec` | tfItemLocalLosesToPkgVar148:2 loopCaParamReadKeepsLiteral116:1 wildcar |

## 5. Ranked OPEN clusters ([cluster_index.csv](cluster_index.csv), [clusters.csv](clusters.csv), [probe_clusters.csv](probe_clusters.csv))

Ranked by the row-modes each still carries after both live pairs (optimistic), then the rows it clears ALONE on top
of both pairs (`alone`), then the rows it heads (`first-open heads`), then probe cases. The site is `mint < caller <
caller` from a gdb run of the `-g1` binary on the cluster's example object (the smallest database carrying it), each
frame with the nearest `§` law above it; `[r11u222 pin]` = pinned in this edition, `[r11u222 pin at 896ec643]` = the
first run's pin of the same example object, otherwise map 13's (or an earlier map's) pin of the same example object.
**Status**: COVERED = a live pair's brief names it (by its decoded head, its row, the UVM ground-A families or map 11's
first-ten rule, section 6); OPEN otherwise, with the history of map 13's credit.

| # | cluster | rows left (551c9751) | sl/u2r | tests | families | first-open heads | alone | probe | ground | status | key | site (mint < caller < caller) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0039 | 10 (10) | 10/0 | 6 | Rggen UVM | 0 | 0 | 44 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | emitExpr (ExprEmit.cpp, law castTargetKeywordTypespecKind96) < emitStmt (StmtEmit.cpp, law importCloneBodyLoca |
| 2 | N0120 | 9 (9) | 9/0 | 5 | UVM | 5 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `span\|enum_var\|line+col+endline+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitClassDefn (UhdmExporter.cpp, law exter |
| 3 | N0171 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 5 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `struct\|golden-only:fewer-copies\|bit_typespec\|under:ref_typespec` | namedElemPackedDimTs31 (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypeParamDefaultTs (TypeEmit.cpp, law  |
| 4 | N0067 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `file\|class_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law unsupportedTsInitEnd152) < makeTypespec (TypeEmit.cpp, law tpFormalIncludeOrde |
| 5 | N0068 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `span\|class_typespec\|ours-zero\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law unsupportedTsInitEnd152) < makeTypespec (TypeEmit.cpp, law tpFormalIncludeOrde |
| 6 | N0161 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `fullname\|ref_typespec\|tok:id::->\|under:class_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law sharedAliasNoStamp41) < makeTypespec (TypeEmit.cpp, law classTdLoca |
| 7 | N0180 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `fullname\|ref_typespec\|ours-empty\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListin |
| 8 | N0158 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `depth\|bit_typespec\|ref_typespec->ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDe |
| 9 | N0188 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `name\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecLis |
| 10 | N0117 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `span\|unsupported_typespec\|endcol\|under:ref_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law classScopedTdFormalUnsupported34) < emitClassDefn (UhdmExporter.cpp, law  |
| 11 | N0213 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `struct\|golden-only:absent\|enum_typespec\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildClassTypedefTs (UhdmExporter.cpp,  |
| 12 | N0230 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `span\|class_typespec\|line+endline\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < sharedTypespec (TypeEmit.cpp, law typeParamDefaultBoundN |
| 13 | N0232 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `struct\|ours-only:elsewhere\|ref_typespec\|under:array_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law modTdRetCloneSymbolic20) < emitClassDefn (UhdmExporter.cpp, law externPro |
| 14 | N0254 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `fullname\|ref_typespec\|tok:id::id::->\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroup |
| 15 | N0255 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `span\|class_typespec\|line+col+endline+endcol\|under:class_defn` | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < classElemVar (UhdmExporter.cpp, |
| 16 | N0256 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `span\|class_var\|endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law implicitRetSigningIsIntVar70) < emitClassDefn (UhdmExporter.cpp, law exte |
| 17 | N0219 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `file\|struct_typespec\|other-file+span\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInline |
| 18 | N0131 | 6 (6) | 6/0 | 3 | Earlgrey UVM | 4 | 0 | 5 | A | OPEN (map 13 gave it to pair A r11u207; passes 207, 210, 215 | `fullname\|ref_typespec\|ours-empty\|under:constant` | emitExpr (ExprEmit.cpp, law bareDecUnderscoreDropped181) < emitExpr (ExprEmit.cpp, law ndaCallFoldIsEvalFunc10 |
| 19 | N0043 | 6 (6) | 6/0 | 3 | UVM | 0 | 0 | 3 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWholeLhsB |
| 20 | N0078 | 6 (6) | 6/0 | 3 | Scr1 UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law elabMisevalRefSu |
| 21 | N0426 | 6 (6) | 6/0 | 3 | Scr1 UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `fullname\|ref_obj\|ours-empty\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law syntaxMultiConca |
| 22 | N0974 | 6 (6) | 6/0 | 3 | UVM | 0 | 0 | 0 | B | OPEN (map 13 gave it to pair B r11u209; passes 209, 212, 216 | `struct\|ours-only:fewer-copies\|class_typespec\|under:ref_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter |
| 23 | N0449 | 5 (5) | 5/0 | 3 | Earlgrey UVM | 0 | 0 | 3 | B | OPEN (map 13 ground-A+B step 10) | `fullname\|ref_typespec\|tok:id@id.id::id.->id::id::id::\|under:typespec_member` | operator() (TypeEmit.cpp, law cloneStructMemberBareTdAlias207) < importCloneBareTdAlias16 (TypeEmit.cpp, law c |
| 24 | N0182 | 5 (5) | 5/0 | 3 | Earlgrey UVM | 0 | 0 | 2 | B | OPEN (map 13 ground-A+B step 10) | `struct\|golden-only:fewer-copies\|typespec_member\|under:struct_typespec` | operator() (TypeEmit.cpp, law cloneStructMemberBareTdAlias207) < importCloneBareTdAlias16 (TypeEmit.cpp, law c |
| 25 | N0467 | 5 (5) | 5/0 | 3 | UVM | 0 | 0 | 0 | B | OPEN (map 13 ground-A+B step 5) | `struct\|ours-only:fewer-copies\|array_typespec\|under:ref_typespec` | exportDesign (UhdmExporter.cpp, law enumNoBind13) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) |
| 26 | N0040 | 4 (4) | 4/0 | 2 | Earlgrey | 2 | 2 | 14 | B | OPEN (map 13 ground-B step 1) | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 27 | N0478 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 17 | B | OPEN (map 13 ground-A+B step 12) | `struct\|golden-only:fewer-copies\|type_parameter\|under:param_assign` | - |
| 28 | N0479 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 16 | B | OPEN (map 13 ground-A+B step 12) | `struct\|golden-only:fewer-copies\|class_typespec\|under:ref_typespec` | copyClassTdSpecParams1 (UhdmExporter.cpp, law classTdCloneSpecOverridesOwnArgs112) < copyClassTdSpecParams1 (U |
| 29 | N0484 | 4 (4) | 4/0 | 2 | Earlgrey | 0 | 0 | 13 | B | OPEN (map 13 ground-B step 3) | `name\|logic_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDe |
| 30 | N0492 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 8 | B | OPEN (map 13 ground-A+B step 12) | `fullname\|ref_typespec\|ours-empty\|under:array_typespec` | memberWrittenQueueTs149 (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildStructTs (TypeEmit.cpp,  |

**Clusters that clear a row-mode ALONE on top of both pairs**: N0040 (InterfaceModPort d/t: needs the harness's
`--sverilog`, pass 188 R1, not implementable in the exporter), N0056 (PreprocTest d/t: the `.vh` face, not
implementable), N0891 (FuncStructVal d/t: golden's 4 extra operations under a typespec_member, TypeEmit
`buildStructTs`). **Clusters that head the most rows after the pairs**: N0120 (5: the UVM rows' `catch` enum_var span,
TaskFuncEmit), N0131 (4: MiniAmiq / SeqDriver, a constant's empty ref_typespec full name, ExprEmit), then N0040 N0056
N0891 N0284 N0812 N0817 N0191 N0422 (2 each), N0141 N2471 N0905 (1).

**Ground A, the OPEN clusters with a row** ([evidence/tables/t_groundA.md](evidence/tables/t_groundA.md); the table
lists 23; all 35 are in cluster_index.csv): N0131 (6 rows: Earlgrey + MiniAmiq/SeqDriver), N0142 (Rggen, Earlgrey),
N0812 N0085 N0746 N0747 N0129 N0061 N0415 N0474 N0446 N0417 N0779 N0815 N0829 N0077 N0416 N0687 N0836 N0928 N0978
N1069 N1082 (2 each: Earlgrey_0_1 and Scr1SvTests elaborated-scope names, ParamEmit's parameter typespec copies).
**Ground B** ([evidence/tables/t_groundB.md](evidence/tables/t_groundB.md)): 142, the top 16 with 9 row-modes each
all UVM (N0039 N0120 N0171 N0067 N0068 N0161 N0180 N0158 N0188 N0117 N0213 N0230 N0232 N0254 N0255 N0256).

**Probe-only OPEN clusters with the most cases**: N0738 (36, B), N1899 (30, B), N0094 (30, B), N0003 (24, A), N1905
(17, B), N1907 (15, B), N1909 (14, A), N1915 (14, B), N1908 (14, B), N1906 (14, B), N1916 (13, B), N1914 (13, A),
N1918 (13, A), N0005 (13, A). The laws with the most NE cases: tpPackedArrayTsVar108 28 of 73, nestedParamActualTs6
23 of 41, srlgUnvaluedActualLitRetFold8 23 of 98, defPkgMemberTdOfNamedShares108 22 of 42,
caIfaceNdaNameFoldsToParamValue88 15 of 37, classTdCloneSpecOverridesOwnArgs112 14 of 22, pkgRhsStructBareCopy111 14
of 15, loopCaParamReadKeepsLiteral116 14 of 123.

**New clusters since map 13** ([evidence/tables/t_newc.md](evidence/tables/t_newc.md)): N0989 (MiniAmiq d/t: golden
lists uvm_severity's enum_typespec elsewhere, TypeEmit `buildEnumTs`), N1211 N1212 N1438 N1439 (Scoreboard d: the
svunit listing-order coin, pinned at `exportDesign` / TaskFuncEmit `emitTaskFuncs`), N2470 (BlackBePipeInt d: pass
207's elaborated-view parameter copies), N2471 (BlackBePipeInt t: a `cc_x_dim` member typespec reference, TypeEmit),
N2472 / N2473 (FuncStructVal d/t: the INSTR_PER_FETCH read-site constant's file and span, ParamEmit
`makeMemLeftConst`), N2474 / N2475 (section 3).

## 6. The yield of the live pairs, and the fail list after them

Routes: [evidence/routes.json](evidence/routes.json) (drivers/mkroutes14b.py), ground overrides
[evidence/ground_override.json](evidence/ground_override.json) (map 13's 58, plus pass 219's N0123 / N0263 -> B, and
three decodes of pass 220 applied here: N0427 InterfArrayBind #183 -> B (section 6.1: ModuleEmit `emitContAssigns`
shares the definition cont_assign); N0191 N0001 N0853 OutputSize -> B (6.2: TypeEmit `emitInitHier`, ModuleEmit's
instance cont_assign); N0028 N0045 N0552 N0761 N0817 struct_param_func_config -> B (6.3: TypeEmit `buildStructTs`);
and N2474 / N2475 -> A (ParamEmit's clone law)).

* **Pair A r11u224** (brief: pass 220's residues first, pass 215's writer stamp against r11u214's writer law, the UVM
  A families after pass 220 and the 598 orphaned return subtrees, the carried BlackBePipeInt, FuncStructVal,
  struct_param_func_config and cfg_func_width_loop faces, a switch-reach table). Named heads (21): the dot after a
  `::` scope N0207 N0397 N0832 N1060 N2117; clone indices the chain law misses N2469 N0555 N0557 N0461 N0215 N0192;
  BlackBePipeInt N0868 (#15272) N0897 (#66); FuncStructVal N1096 (#747) N2472 N2473; map 13's case clusters N0739
  N1903 N1904 N0476 N0477. Row credits: the ground-A halves of cfg_func_width_loop, struct_param_func_config,
  FuncStructVal, BlackBePipeInt. Optimistic: every ground-A cluster whose rows are all UVM rows (or a named row).
  The backtick string spans, continued literals, var_select lvalues and new[] indices have no cluster in the gate
  set: their shapes are pass 220's tools/probe cases (SL, NW, CI), none a gate case.
* **Pair B r11u223** (brief: typedef int UVM_FILE first, pass 219's residues, the writer rule's remaining faces, the
  svaunit clone names, MiniAmiq's storage coin, pass 212's and 216's residues): named heads (15) as the first run
  routed them (N0123 N0318 N0516 N0521 N0481 N0550 N0565 N2464 N0121 N0144 N0321 N0263 N0262 N0008 N0427); row
  credits cfg_func_width_loop (the kept call N0133 / N0487) and InterfArrayBind; map 11's first-ten rule.

| | row-modes cleared | tests | probe cases | fail list after |
|---|---|---|---|---|
| pair A r11u224 (103 clusters, optimistic) | 0 | 0 | 58 | 31 / 17, 586 |
| pair B r11u223 (23 clusters, optimistic) | 1 (InterfArrayBind d) | 1 | 21 | 30 / 16, 623 |
| **both (optimistic)** | **3** (InterfArrayBind d, cfg_func_width_loop d/t) | **2** | **88** | **28 / 15, 556** |
| both, NAMED heads only (A 21 + B 15 clusters) | 1 (InterfArrayBind d) | 1 | 40 | **30 / 16, 604** |

Per corpus and mode, today -> after both: surelog default 14 -> 13, testflags 11 -> 11, uhdm2rtlil default 3 -> 2,
testflags 3 -> 2. Section 13 measures pair B's half against pass 223.

## 7. Structural rows and the downstream-visible faces

**Structural rows** (first field depth / type): **4 row-modes**, unchanged since map 13's addendum: BlackBePipeInt d
`type(1)` (N0868: an ours-only constant under a tagged_pattern, #15272's family: golden writes no value for a pattern
member whose conditional compares an int member with a string; ParamEmit, pair A's carried item), BlackBePipeInt t
`depth(1)` (N0897: 8 ours-only `dev_addr_width_gp` parameter copies under a ref_obj, #66: the `--elabuhdm` claim of §
pcwElabKeepsClaim207v too broad for the AllPackages listing; ParamEmit, pair A), Scr1SvTests d/t `type(1)` (N0791: a
golden-only ref_obj under a cont_assign, **a Surelog binding defect** (r11u200 3d: Surelog binds the include-guarded
`$unit` enum constant to an implicit net), no law without inventing an object; 15 more clusters behind it, 10 of ground B and 5 of ground A). No
landed or unlanded law touches them. The probe set holds **50 `depth` and 74 `type` first fields**. Reminder: the
tool stops at a structural record; the analyzer's aligned records past it are what the clusters count.

**Downstream-visible faces** ([evidence/downstream/](evidence/downstream/), drivers/dsfaces.py: the gate's own
`one()`, a fresh golden cache, the HEAD binary): the first run's 457 cases (map 13's list, pass 216's, v11u216's,
pass 219's and v11u219's, r11u221's) plus **all 259 cases of pass 220 and its verifier**. **716 cases: 626 IDENTICAL,
43 EQUIVALENT, 32 DIVERGENT, 9 STATUS_DIFF, 3 SLANG_REJECT, 3 SURELOG_FAIL.** On the 457 cases the first run measured
at `896ec643`: **0 verdict changes** (pass 220 moves none of them).

| face | cases | verdict at `551c9751` | what it needs |
|---|---|---|---|
| r11u204's encoding faces | DF/e06, e08 | **IDENTICAL** | (closed) |
| r11u204 N7 (split real ports, twice instantiated) | V191/rp2 | **DIVERGENT** | not decoded |
| r11u204 N8 (type-parameter array in a generate scope) | X/x5 | **DIVERGENT** | golden folds the ranges at the left operand (ModuleEmit / TypeEmit) |
| pass 216's range queries | NQ/n11; n12; GQ/g12 | **n11 DIVERGENT**; n12 IDENTICAL; g12 IDENTICAL | n11: the unfolded query shapes (r11u221's new residue) |
| v11u216 | F/f14; F/f02, T/t11 | **f14 IDENTICAL** (pass 219); f02, t11 SLANG_REJECT | - |
| v11u212 G/g12 | G/g12 | **EQUIVALENT** | not decoded |
| r11u221's cases | Q/q08; q02, q11, I/i02, i06, NP/p08, X/x02; i01, i05, q05, q13 | q08 IDENTICAL; **DIVERGENT**; EQUIVALENT | the member-read refinement's predicate, unfolded query shapes |
| pass 219 / v11u219 `$size` | S/s01_2d, s02, s05 IDENTICAL; s03 s04 EQUIVALENT; v11u219 S/s01c, s06, s08 **DIVERGENT**; s01, s01b SURELOG_FAIL | as listed | golden's generic-handler `$size` values (pass 219 R2), ModuleEmit `rqSizePlan216` (parse view) |
| pass 215 R/r07 | R/r07 | **DIVERGENT** (identical RTLIL in both states, r11u221) | - |
| **pass 220's cases (new here)** | 259: 244 IDENTICAL; CI/c07 GX/g25 SL/s50 K/k09 k15 k17 T/t14 EQUIVALENT; **SL/s47, K/k01, k06, k08, T/t19 DIVERGENT**; G/g27 K/k13 STATUS_DIFF; SL/s37 SURELOG_FAIL | | t19 a string value encoding; k01 k06 k08 continued literals (v11u220's residues); s47 a continued literal reaching a variable initializer (pass 220 residue 3) |
| map 13's standing list | rq/q08, hw/w12 w13, sc/c10 c12, us/u02 u08, GV, PU/u06, UD/u04, Q c02 c08 c14, U, C/c06, X/x06, T/t03, X/x05, B3, D5, TP, A/a12, PP/p05 | unchanged since map 13 (q08 IDENTICAL since pass 216) | as map 13 section 7b |

The full per-case csv is [evidence/downstream/dsfaces_P.csv](evidence/downstream/dsfaces_P.csv); the non-IDENTICAL
list by verdict is [evidence/downstream/nonidentical.txt](evidence/downstream/nonidentical.txt). The downstream gate
itself reads 803 / 66 / 2 / 0 (section 2); the uhdm2rtlil STRICT_NOTEQUAL rows' lanes are all IDENTICAL.

## 8. Positive controls, determinism, rebuild identity ([evidence/controls/](evidence/controls/), [evidence/determinism/](evidence/determinism/), [evidence/rebuild/](evidence/rebuild/))

**Positive controls** (the HEAD sweep's databases, `strictcmp_x --max 50` with record dumps): 1364_2005 d, HierPathInterfBlock
d (surelog) and 1DUnpackedArray d (uhdm2rtlil) read `STRICT_EQUAL` (159 / 226 / 194 objects) with **identical record
dumps** (0 differing lines) and uhdm-cmp rc 0, 0 lines; **stamped_gen_param d/t stays stage-1 NOT_EQUAL** (tool rc 1,
uhdm-cmp rc 255 with 32 lines), the user-decided Surelog-defect row. A zero census elsewhere in this map is read beside
its reversed control (section 9).

**Determinism control** (drivers/det.sh: the HEAD binary three times CONCURRENTLY per row-mode with the HEAD sweep's
command line; drivers/ob.sh: order-blind line counts of each pair of distinct databases):

| row-mode | distinct hashes (3 draws + the HEAD sweep's) | order-blind dump lines | raw dump lines | reading |
|---|---|---|---|---|
| Earlgrey_0_1 d / t | 1 / 1 | - | - | deterministic |
| SeqDriver d / t | 1 / 1 | - | - | **r11u221's cure of the twin-mint coin holds** (§ cloneTwinMintIdOrder221v) |
| SimpleUVM d / t, BuildUVMPkg d / t | 1 / 1 each | - | - | deterministic |
| **MiniAmiq d / t** | **2 / 2** (`21ff47e0`, `99fed9d5`) | **0** | **0** | a symbol-table storage coin, invisible to every reader |
| **Scoreboard d** | **3** (`3a12bb35`, `10e7e362`, the sweep's `1c15e0b8`) | **0** | 0 between the first two; **92** against the sweep's | a symbol-table coin plus the known svunit listing-order coin (92 lines, the same object set) |
| Scoreboard t | - | - | - | SLANG_REJECT (skipped) |

**MiniAmiq's coin, its writer pinned.** The two draws' symbol tables (drivers/sym.cpp) hold the same 42,292 strings;
95 of them, all `svaunit_pkg::...` clone names (formal-default and path references such as
`svaunit_pkg::uvm_component::record_error_tr::stream.open_recorder::label`), are interned in a different order
(`ids 41571-41665`). A gdb break on the interning of the first of them (drivers/pinsym.sh, the `-g1` binary) stops in
**§ refFullNameThroughNamedExpr175** (`src/ExprEmit.cpp`, `refFullNameThroughNamedExpr175`, called from ParamEmit
`drainPaNameCopySrc38`), whose loop walks `s.AllObjects()`, a `std::map<const BaseClass*, uint32_t>`: pointer order,
so the names it re-stamps are interned in heap-address order. **Control: with its switch `R11U175_FULLNAME_OFF`,
MiniAmiq gives one hash in 8 of 8 concurrent draws (4 per mode).** The cure is the one r11u221 applied to the twin
mint: walk in `UhdmId` order. Ground A (ExprEmit). Pass 223 (section 13) reached the same writer independently ("the
address-order loop in ExprEmit itself, the root of both symbol-table coins"). It predates passes 215 and 216 (r11u221
counted 842 differing symbol-table lines between its draws; the two draws here differ in 95 positions, 190 lines).

**Rebuild identity.** Three builds of `551c9751` from nothing (this worktree's `build`, a second build directory
`build-rb2`, and the main tree's integrator build that made the HEAD sweep) are byte-identical (`2510f4fe`); the
`-g1` binary writes the same bytes as both on tools/probe/r11u196repro/cases/V191/qr01 and r11u209repro/cases/TW/qr01
(3 runs each, one hash per binary, dumps identical).

## 9. The away-moved-record census of every landing since map 13, and of pass 220 ([evidence/away/](evidence/away/))

Method (map 13's, extended as pass 219 required): the `551c9751` binary under one landing's switches is swept (probe +
both corpora, both modes: the state sweeps) beside this map's pristine sweep; every database whose bytes differ is
walked by `uhdm-strictcmp` (canonical records) and by `strictcmp_x` (raw full names), each record keyed by its
**ancestor chain** and **flat** (depth dropped). **lost** = records golden and the landing-off state share that HEAD
lacks; **toward** = the reverse. The flat key is read **position-aware**: a flat-lost record is an *excess removal*
when, at its own chain, HEAD removed only copies above golden's count there (toward golden in place); `unexplained` =
flat-lost records no in-place reading explains. Measured at `551c9751`, it answers "did the landing move a record away
from golden" and "does any such record survive at HEAD" at once.

| landing (state) | switches | databases moved (probe + corpus) | **lost, chain-keyed** | lost, flat (unexplained) | toward, chain / flat | the landing's own census | survives at HEAD |
|---|---|---|---|---|---|---|---|
| pass 209 (a9) | `R11U209_OFF R11V209_OFF` | 59 (37 + 22) | **0** | 0 | 8362 / 8362 (raw 8376) | 0 lost: **reproduced** (the first run at `896ec643`: the same 8362) | 0 |
| r11u213 (b3) | `R11V213_OFF` | 2 (MiniAmiq t, Scoreboard d: the coins, records identical) | **0** | 0 | 0 / 0 | 0 lost: **reproduced** (no gate record moves) | 0 |
| pass 210 (c0) | `R11U210_OFF R11U205_IFARRIDX_OFF` | 14 (3 + 11) | **0** | 0 | 2212 / 2212 (raw 38,844) | 0 lost: **reproduced** (the first run at `896ec643`: identical totals) | 0 |
| pass 212 (d2) | `R11U219_LANDING212_OFF` (pass 219's whole-landing switch) | 18 (6 + 12) | **0** | 0 | 161 / 161 (raw 266) | 0 lost: **reproduced** (the first run at `896ec643`: identical totals) | 0 |
| r11u217 (e7) | `R11V217_OFF` | 1 (MiniAmiq t, the coin) | **0** | 0 | 0 / 0 | 0 lost: **reproduced** (no gate record moves) | 0 |
| pass 216 (f6) | `R11U219_LANDING216_OFF` | 3 (MiniAmiq d/t, Scoreboard d) | **0** | 0 | 330 / 378 | 0 lost: **reproduced** (r11u221: 0) | 0 |
| pass 215 (g5) | `R11U215_OFF R11V215_OFF` (`R11V215_OFF` is read nowhere, as r11u221 found) | 14 (1 + 13) | **0** | 0 | 718 / 719 | 0 lost: **reproduced**; at HEAD its 12 probe conversions are also made by r11u214's writer law (pass 219), so only 1 case moves | 0 |
| r11u221 (h1) | `R11V221_OFF` | 5 (the coins; SeqDriver d/t: the twin order, records identical) | **0** | 0 | 0 / 0 | bytes only: **reproduced** | 0 |
| pass 219 (i9) | `R11U219_OFF R11V219_OFF` | 94 (62 + 32) | **0** | 34 (**0**: all 34 excess removals in place) | 3091 / 3057 (raw 3728 / 3650) | chain 0, the flat 34 paired in place: **reproduced exactly** | 0 |
| **pass 220 (j0)** | `R11U220_OFF` (all thirteen laws) | 39 (26 + 13) | **0** | 650 canonical / 598 raw (**0**: all excess removals) | 7730 / 7730 | chain 0, 7730 toward, the flat 598 (the unreferenced subtrees of the minted return variables § importCloneSharesHomeReturn218 no longer walks): **reproduced exactly**; the position-aware key reads them as removals of records golden does not hold at those chains | 0 |
| r11u218's half of pass 220 (k8) | `R11U218_OFF` | 34 (23 + 11) | **0** | 650 / 598 (**0**) | 4511 / 4511 | the first run measured the unlanded patch at `896ec643`: 4511 toward, the same 650 / 598: **reproduced** | 0 |
| **positive control**: pass 220 reversed (HEAD as the off side) | | 39 | **7730** | 7730 (7730) | 0 / 650 | | - |
| **positive control**: pass 219 reversed | | 94 | **3091** | 3057 (3057) | 0 / 34 | pass 219's reversed control: 3091 | - |
| **pass 223 (h3, addendum; `75a564b0` binary, section 13)** | `R11U223_OFF R11V223_OFF` | 25 (16 + 9) | **0** | 298 (**0**: all excess removals) | 5942 / 5942 | chain 0, 5942 toward, the flat 234 paired in place at its base: **reproduced** (298 here, composed with pass 220) | 0 |
| positive control: pass 223 reversed | | 25 | **5942** | 5942 (5942) | 0 / 298 | pass 223's reversed control: 5942 | - |

**No landing since map 13, pass 220 and pass 223 included, moved a strict record away from golden on any corpus
row-mode or probe case, and none of the records they moved toward golden has been lost since**: every state's
chain-keyed lost count at `551c9751` is 0, and the reversed controls read every toward count as lost, so the census
sees. Every flat-key "loss" (pass 219's 34, pass 220's 650 / 598, pass 223's 298) is an excess removal at its own chain
(ours held more copies there than golden). Byte movers that carry no record change are the MiniAmiq symbol-table coin
and Scoreboard's svunit listing coin (section 8) and r11u221's twin order. Each state's databases-moved count matches
the landing's own mover count where the landing is not shadowed (pass 220: 26 + 13; pass 223: 16 + 9; pass 219: 32
corpus); pass 215 moves only one probe case at HEAD because pass 219's writer law makes the same records.

## 10. Prediction audit of map 13 ([evidence/audit.txt](evidence/audit.txt), drivers/audit14b.py)

**Conversions per landing since map 13** (read from the committed baselines at each landing commit, never from a
sweep; no landing left `CMP_EQUAL` or added a `STRICT_NOTEQUAL` row):

| landing | row-modes converted | probe cases | strict-cell changes |
|---|---|---|---|
| pass 207 (`62ac216e`, map 13's addendum) | UnitElabBlock d/t | 7 | 11 |
| pass 209 (`b69dc2da`) | InterfaceStructMemberPort d/t, HierPathTypespec t | 33 | 12 |
| r11u213 (`6dcc0818`) | - | 0 | 0 |
| pass 210 (`a727b8c7`) | FuncStructValSimple d/t | 3 | 5 |
| pass 212 (`745f66ab`) | - | 4 | 12 (anon_struct_packed_dim d/t `fullname(43)` -> `fullname(4)`) |
| r11u214, r11u217, r11u218, r11u221 | - | 0 | 0 |
| pass 216 (`c4f26079`) | - | 0 | 2 |
| pass 215 (`57ce3ae8`) | ibex_tracer d/t | 12 | 9 |
| pass 219 (`896ec643`) | - | 10 | 9 |
| **pass 220 (`551c9751`)** | **anon_struct_packed_dim d/t** | 11 | 7 |
| **total since map 13's base** | **11 row-modes / 6 tests** | **80** | |

**Map 13's predictions against them.** Map 13's fail list was 42 row-modes / 23 tests at `4acbe8a5`; its credited
set (r11u205 measured + pairs r11u207 / r11u209 optimistic) was 20 row-modes, of which 8 were named optimisms;
its section-9 greedy lists covered all 42. **Converted: 11 of the 42, every one of them credited in the 20** (11 of
20 = 55%); without the eight named optimisms 10 of 12 converted (83%); the only named optimism that converted is
HierPathTypespec t (pass 209). The section-9 lists converted nothing beyond the credited rows (list B / A+B: the
not-implementable InterfaceModPort, PreprocTest and LogicTypespec; the deep lists: the big families). **No row
converted that map 13 did not predict.**

| converted row-modes | landing | map 13 credit | map 13's first cluster and pin | landing law's files | pin |
|---|---|---|---|---|---|
| UnitElabBlock d/t | pass 207 | r11u205 (measured) | N0016, ExprEmit | ExprEmit | right (mint) |
| InterfaceStructMemberPort d/t | pass 209 | pair B | N1134, ModuleEmit | ModuleEmit + UhdmExporter | right (mint) |
| HierPathTypespec t | pass 209 | pair B (named optimism) | N1174, TypeEmit | UhdmExporter | right (a caller) |
| FuncStructValSimple d/t | pass 210 | pair A | N0086, ParamEmit | ExprEmit + ParamEmit | right (mint) |
| ibex_tracer d/t | pass 215 | pairs A+B | N0563, TypeEmit | ParamEmit | right (a caller) |
| anon_struct_packed_dim d/t | pass 220 | pairs A+B | N0014, TypeEmit | ExprEmit | **the right ground for the first half**: pass 212 (the module/type ground, its law in UhdmExporter) removed N0014's records (`fullname(43)` -> `fullname(4)`, N0014 4 -> 1 rows), pass 220 (ExprEmit) the last cluster N0820: exactly map 13's A+B credit |

**Site pins: 9 of 11 name a file of the landing law** (6 at the mint, 3 at a caller); the other 2 (anon_struct_packed_dim
d/t) name the right ground for the half that landed first (pass 212) while the conversion came from the other
half. Map 13 for map 12: 8 of 8; map 12 for map 11: 10 of 10.

**The credits that did not convert, and why** (9 row-modes of the 20):

* FuncStructVal d/t (named optimism, pair A): pair A's refills (r11u210, r11u215, r11u220) carried #747 and the R2
  read-site leftovers as residues and never attempted them; the row's last open cluster after them is N0891, TypeEmit's
  (ground B), which map 13 had credited to pair A.
* InterfArrayBind d (named optimism, pair A): pass 210's § elabIfArrIdxChainName205 moved it `fullname(3)` ->
  `fullname(1)`; the last record (#183) is ModuleEmit `emitContAssigns` sharing the definition cont_assign (pass 220
  section 6.1): **the ground was wrong** (the pin names ExprEmit, the naming site; the object's sharing is ModuleEmit's).
* struct_param_func_config d/t (named optimism, pair A): its first records are TypeEmit `buildStructTs`' (pass 220
  section 6.3); again the credit's ground was wrong (map 13's override had moved them to A on r11u200's decode).
* cfg_func_width_loop d/t (named optimism, A+B): both halves decoded (r11u200, pass 216), neither written.
* OutputSize... d/t (pairs A+B): never attempted; pass 220 decoded its heads as TypeEmit `emitInitHier` spans and
  ModuleEmit's `'1` fill (ground B), where map 13's pin (StmtEmit's `emitDroppedCall14`) named the mint of the hier_path,
  not the writer of its span.

**What that says about the pins.** A pin names the function that MINTS the example object; every conversion so far
was made in a file on the pinned call chain. The misses are credits, not pins: a brief item named a row whose next
record lies on the other ground (FuncStructVal, InterfArrayBind, struct_param_func_config), or the pass took other
items first. Two of the three ground errors are cases where the mint and the field's writer differ (a shared object's
parent, a span stamped after the mint): **for a span or full-name cluster, pin the writer of the field, not only the
mint** (a watchpoint on the field, as pass 220's decodes did by tracing).

**Map 13's clusters** ([evidence/audit.txt](evidence/audit.txt) section D): of its 149 covered clusters, 40 gone, 7
rows cleared, 8 fell, 93 unchanged, 1 grew (N0123 7 -> 9: pass 219 made UVM_FILE the head of all nine UVM row-modes;
pass 223 then took it, section 13); of the 274 clusters on its section-9 lists, 71 gone, 9 rows cleared, 6 fell, 186
unchanged, 2 grew (N0594, N0616 2 -> 4). 38 clusters it did not route cleared cases (probe only). Its item-by-item
recount at `551c9751` is audit.txt section F.

**This map's own predictions audited so far**: the first run's pair-A credit for pass 220 (section 3: anon_struct_packed_dim
d/t converted as credited, struct_param_func_config not, the ground error above) and this edition's pair-B credit for
pass 223 (section 13).

## 11. The family view, the UVM census, the order-blind distance

**Families at `551c9751`** (report14b.py section 9; [evidence/report.txt](evidence/report.txt)):

| family | row-modes / tests | clusters per row | open per row after both pairs | distinct clusters: now -> after the pairs | cleared by the pairs |
|---|---|---|---|---|---|
| UVM (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg) | 9 / 5 | 51-136 | 22-65 | 169 -> 79 | 0 |
| Earlgrey_0_1 | 2 / 1 | 45-53 | 43-51 | 58 -> 56 | 0 |
| Rggen (default only) | 1 / 1 | 20 | 20 | 20 -> 20 | 0 |
| BlackBePipeInt | 2 / 1 | 20-23 | 3-6 (all B) | 24 -> 6 | 0 |
| Scr1SvTests | 2 / 1 | 17 | 16 (behind the Surelog defect N0791) | 17 -> 16 | 0 |
| FuncStructVal | 2 / 1 | 5-6 | 1 (N0891, B) | 6 -> 1 | 0 |
| struct_param_func_config (uhdm2rtlil) | 2 / 1 | 7 | 5 (B: TypeEmit `buildStructTs`) | 7 -> 5 | 0 |
| cfg_func_width_loop (uhdm2rtlil) | 2 / 1 | 7 | 0 | 7 -> 0 | 2 (pairs A+B, optimistic) |
| OutputSize...StructMember (uhdm2rtlil) | 2 / 1 | 4 | 4 (B, not in either brief) | 4 -> 4 | 0 |
| anon_struct_packed_dim | - | - | - | - | **converted by pass 220** |

**Single-cluster rows at `551c9751`: 5 row-modes / 3 tests**: InterfArrayBind d (N0427), InterfaceModPort d/t (N0040),
PreprocTest d/t (N0056). **Near rows after both pairs** (one open cluster): InterfaceModPort d/t (N0040, not
implementable: the harness's `--sverilog`), PreprocTest d/t (N0056, not implementable: the `.vh` face), FuncStructVal
d/t (N0891, TypeEmit's 4 missing operations under a typespec_member). LogicTypespec d/t keeps its four (a user
decision, map 13). No row has two.

**The UVM family: r11u175's census by family key** (drivers/uvmcensus9.sh = r11u175's `uvmcensus.py` +
`uvmfamilies.py` over map 8's cluster keys, the five UVM rows' default databases, from this map's analyzer output;
[evidence/uvm/](evidence/uvm/)):

| family | map 13 `4acbe8a5` | `896ec643` (first run) | `896ec643` + r11u218 (first run) | **`551c9751`** |
|---|---|---|---|---|
| F2 object multiplicity | 11,840 | 11,176 | 8,538 | **9,334** (8,538 without the Scoreboard coin draw, below) |
| F5 reference full names | 8,038 | 6,879 | 4,744 | **3,257** |
| F6 file facets | 2,165 | 1,754 | 1,754 | **1,754** |
| F4 formal / typespec / bound spans | 483 | 433 | 433 | **433** |
| F7 expression spans outside the pp model | 1,182 | 361 | 361 | **301** |
| F9 value / order / depth | 283 | 275 | 275 | **275** |
| F3 typedef relocation spans | 139 | 139 | 139 | **139** |
| F1 preprocessor location model | 720 | 0 | 0 | **0** |
| F8 names | 95 | 95 | 95 | **95** |
| **all** | **24,945 (251 clusters)** | **21,112 (209)** | **16,339 (175)** | **15,588 (168)**; **14,792** without the coin draw |

The HEAD sweep's Scoreboard default database drew the other svunit listing order (section 8): 796 F2 objects in four
keys (N1211 N1212 N1438 N1439, 379 + 379 + 19 + 19 records listed elsewhere) are that draw, not a law; without them F2
is 8,538, exactly r11u218's. Pass 220 took F5 another -1,487 (the clone select indices and the dot-join laws) and F7 -60
(the string-literal spans). **The largest UVM families are still F2 (the importer clones' copies: N0182 1,924, N0024
780, N0478 762, N0420 717, N0495 576, N0408 481, N0496 468) and F5 (N0565 590, N0492 585, N0571 552).** The F1 family
went to 0 with pass 219's preprocessor-model laws.

**Order-blind uhdm-dump distance to golden** (drivers/uvmdist.sh: strict records with the depth dropped, as multisets;
**dist** = records ours holds that golden lacks, **sym** = dist + records golden holds that ours lacks; the same
measure as tools/probe/r11u168repro/drivers/uvmdist.sh, run through the gate's comparator;
[evidence/uvm/uvmdist_H.txt](evidence/uvm/uvmdist_H.txt)):

| row-mode | map 13 `4acbe8a5` dist / sym | `896ec643` (first run) | `896ec643` + r11u218 | **`551c9751`** |
|---|---|---|---|---|
| MiniAmiq d / t | 6,634 / 15,058 | 5,941 / 13,606 | 3,368 / 9,779 | **2,461 / 7,965** |
| SeqDriver d / t | 5,194 / 11,252 | 4,598 / 9,982 | 2,724 / 7,553 | **2,122 / 6,349** |
| SimpleUVM d / t | 2,074 / 4,060 | 1,544 / 2,814 | 1,543 / 2,812 | **1,535 / 2,796** |
| Scoreboard d | 1,526 / 3,029 | 1,105 / 2,013 | 1,104 / 2,011 | **1,098 / 1,999** |
| BuildUVMPkg d / t | 776 / 1,551 | 673 / 1,291 | 672 / 1,289 | **648 / 1,241** |
| Earlgrey_0_1 d | 4,599 / 8,554 | 1,128 / 1,612 | 1,066 / 1,488 | **1,066 / 1,488** |
| Earlgrey_0_1 t | 4,293 / 8,300 | 868 / 1,450 | 798 / 1,310 | **798 / 1,310** |
| Rggen d | 4,463 / 10,655 | 4,321 / 10,371 | - | **4,321 / 10,371** |
| Scr1SvTests d / t | 117 / 195 | 117 / 195 | - | **117 / 195** |
| BlackBePipeInt d / t | 17,110 / 31,837; 17,181 / 31,882 | 16,886 / 31,517; 17,111 / 31,742 | - | **the same** |
| InterfArrayBind d | 3 / 6 | 1 / 2 | - | **1 / 2** |
| FuncStructVal d / t | - | 30 / 348; 53 / 371 | - | **the same** |

The per-pass figures published by pass 220 (MiniAmiq 6,266 -> 2,786 at `57ce3ae8`) and r11u221 (6,266) are at bases
without pass 219; the `551c9751` figure composes both. Pass 223's figures are in section 13.

## 12. The per-ground briefs (greedy, in the shape of map 13's section 9)

The lists ([evidence/greedy14.json](evidence/greedy14.json), [evidence/greedy14_named.json](evidence/greedy14_named.json),
[evidence/tables/](evidence/tables/)) take whole open sets of the rows left, greedily by rows gained per cluster; the
'deep' lists take a row's whole open set whatever its size. **No row-mode is open on ground A alone**: every row that
still carries a ground-A cluster also carries ground-B ones (by the ground overrides of section 6), so the ground-A
lists are empty and every A cluster reaches the row count only through an A+B list. Every ground-A cluster together
clears 0 row-modes on top of the NAMED heads; every ground-B cluster 8.

### 12a. On top of both live pairs (optimistic; 3 row-modes cleared by them)

**list B**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 5 | InterfaceModPort/d InterfaceModPort/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 2 | N0891 | 2 | 7 | FuncStructVal/d FuncStructVal/t | B | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRngSkip |
| 3 | N0056 | 2 | 9 | PreprocTest/d PreprocTest/t | B | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 4 | N0083 + N0422 + N0484 + N1149 | 2 | 11 | LogicTypespec/d LogicTypespec/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorr |
| 5 | N0001 + N0191 + N0853 + N1127 | 2 | 13 | OutputSizeWithParameterOfInstanceInitializedByStructMember/d/u2r OutputSizeWithParameterOfInstanceInitializedByStructMember/t/u2r | B | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue |
| 6 | N0028 + N0073 + N2471 | 1 | 14 | BlackBePipeInt/d | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law defPkgS |
**list deep B**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 5 | InterfaceModPort/d InterfaceModPort/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 2 | N0891 | 2 | 7 | FuncStructVal/d FuncStructVal/t | B | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRngSkip |
| 3 | N0056 | 2 | 9 | PreprocTest/d PreprocTest/t | B | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 4 | N0083 + N0422 + N0484 + N1149 | 2 | 11 | LogicTypespec/d LogicTypespec/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorr |
| 5 | N0001 + N0191 + N0853 + N1127 | 2 | 13 | OutputSizeWithParameterOfInstanceInitializedByStructMember/d/u2r OutputSizeWithParameterOfInstanceInitializedByStructMember/t/u2r | B | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue |
| 6 | N0028 + N0045 + N0552 + N0761 + N0817 | 2 | 15 | struct_param_func_config/d/u2r struct_param_func_config/t/u2r | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law defPkgS |
| 7 | N0073 + N2471 | 1 | 16 | BlackBePipeInt/d | B | fillSizeDimRange (ModuleEmit.cpp, law sizeDimOvrChain4) < emitInstance (ModuleEmit.cpp, law progPortIfaceArray |
| 8 | N0014 + N0905 + N1179 | 1 | 17 | BlackBePipeInt/t | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPacke |
| 9 | N0039 + N0043 + N0067 + N0068 + N0117 + N0120 + N0158 + N0161 + N0171 + N0177 + N0180 + N0188 + N0203 + N0213 + N0230 + N0232 + N0254 + N0255 + N0256 + N0264 + N0467 + N0974 | 2 | 19 | BuildUVMPkg/d BuildUVMPkg/t | B | emitExpr (ExprEmit.cpp, law castTargetKeywordTypespecKind96) < emitStmt (StmtEmit.cpp, law importCloneBodyLoca |
| 10 | N0011 + N0219 + N0325 + N0458 + N0541 + N0596 | 2 | 21 | SimpleUVM/d SimpleUVM/t | B | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cp |
| 11 | N0447 + N1211 + N1212 + N1438 + N1439 | 1 | 22 | Scoreboard/d | B | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeTypespec (Type |
**list deep A+B**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 5 | InterfaceModPort/d InterfaceModPort/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 2 | N0891 | 2 | 7 | FuncStructVal/d FuncStructVal/t | B | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRngSkip |
| 3 | N0056 | 2 | 9 | PreprocTest/d PreprocTest/t | B | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 4 | N0083 + N0422 + N0484 + N1149 | 2 | 11 | LogicTypespec/d LogicTypespec/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorr |
| 5 | N0001 + N0191 + N0853 + N1127 | 2 | 13 | OutputSizeWithParameterOfInstanceInitializedByStructMember/d/u2r OutputSizeWithParameterOfInstanceInitializedByStructMember/t/u2r | B | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue |
| 6 | N0028 + N0045 + N0552 + N0761 + N0817 | 2 | 15 | struct_param_func_config/d/u2r struct_param_func_config/t/u2r | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law defPkgS |
| 7 | N0073 + N2471 | 1 | 16 | BlackBePipeInt/d | B | fillSizeDimRange (ModuleEmit.cpp, law sizeDimOvrChain4) < emitInstance (ModuleEmit.cpp, law progPortIfaceArray |
| 8 | N0014 + N0905 + N1179 | 1 | 17 | BlackBePipeInt/t | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPacke |
| 9 | N0021 + N0030 + N0078 + N0284 + N0416 + N0426 + N0779 + N0791 + N0836 + N0921 + N1009 + N1069 + N1112 + N1113 + N1119 + N2405 | 2 | 19 | Scr1SvTests/d Scr1SvTests/t | A+B | cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) < cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst |
| 10 | N0039 + N0043 + N0067 + N0068 + N0117 + N0120 + N0158 + N0161 + N0171 + N0177 + N0180 + N0188 + N0203 + N0213 + N0230 + N0232 + N0254 + N0255 + N0256 + N0264 + N0467 + N0974 | 2 | 21 | BuildUVMPkg/d BuildUVMPkg/t | B | emitExpr (ExprEmit.cpp, law castTargetKeywordTypespecKind96) < emitStmt (StmtEmit.cpp, law importCloneBodyLoca |
| 11 | N0011 + N0219 + N0325 + N0458 + N0541 + N0596 | 2 | 23 | SimpleUVM/d SimpleUVM/t | B | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cp |
| 12 | N0447 + N1211 + N1212 + N1438 + N1439 | 1 | 24 | Scoreboard/d | B | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeTypespec (Type |
| 13 | N0131 + N0164 + N0170 + N0182 + N0289 + N0340 + N0341 + N0343 + N0414 + N0420 + N0428 + N0449 + N0452 + N0478 + N0479 + N0492 + N0505 + N0507 + N0538 + N0543 + N0544 + N0556 + N0570 + N0571 + N0574 + N0585 + N0588 + N0589 + N0594 + N0601 + N0616 + N0620 + N0630 + N0634 + N0647 + N0648 + N0658 + N0703 + N0706 + N0784 + N0989 + N1131 + N1163 + N2416 | 4 | 28 | MiniAmiq/d SeqDriver/d MiniAmiq/t SeqDriver/t | A+B 
| 14 | N0141 + N0142 + N0273 + N0448 + N0451 + N0683 + N0690 + N0696 + N0697 + N1172 + N1338 + N1339 + N1342 + N1343 + N1382 + N1845 + N1862 + N1875 | 1 | 29 | Rggen/d | A+B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespec (TypeEmit.cpp, law splitPortTsKeyOnPor |
| 15 | N0061 + N0077 + N0085 + N0090 + N0129 + N0415 + N0417 + N0446 + N0474 + N0525 + N0687 + N0727 + N0742 + N0746 + N0747 + N0812 + N0815 + N0829 + N0834 + N0835 + N0846 + N0928 + N0976 + N0978 + N0981 + N1002 + N1054 + N1074 + N1082 + N1218 + N1292 + N2382 | 1 | 30 | Earlgrey_0_1/t | A+B | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectEras |
| 16 | N0454 + N0545 + N0546 + N0772 + N1173 + N1181 + N1184 + N1194 + N1302 + N1381 + N1529 + N1539 + N1753 | 1 | 31 | Earlgrey_0_1/d | A+B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeTypespec (TypeEmit.cpp, law memberA |

### 12b. On top of the NAMED heads only (1 row-mode cleared by them) — the realistic base for the next refills

**list B**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 3 | InterfaceModPort/d InterfaceModPort/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 2 | N0056 | 2 | 5 | PreprocTest/d PreprocTest/t | B | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 3 | N0083 + N0422 + N0484 + N1149 | 2 | 7 | LogicTypespec/d LogicTypespec/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorr |
| 4 | N0001 + N0191 + N0853 + N1127 | 2 | 9 | OutputSizeWithParameterOfInstanceInitializedByStructMember/d/u2r OutputSizeWithParameterOfInstanceInitializedByStructMember/t/u2r | B | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue |
**list A+B**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 3 | InterfaceModPort/d InterfaceModPort/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 2 | N0056 | 2 | 5 | PreprocTest/d PreprocTest/t | B | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 3 | N0891 + N0980 + N1946 | 2 | 7 | FuncStructVal/d FuncStructVal/t | A+B | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRngSkip |
| 4 | N0083 + N0422 + N0484 + N1149 | 2 | 9 | LogicTypespec/d LogicTypespec/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorr |
| 5 | N0001 + N0191 + N0853 + N1127 | 2 | 11 | OutputSizeWithParameterOfInstanceInitializedByStructMember/d/u2r OutputSizeWithParameterOfInstanceInitializedByStructMember/t/u2r | B | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue |
| 6 | N0025 + N0033 + N0133 + N0487 + N0754 + N0794 | 2 | 13 | cfg_func_width_loop/d/u2r cfg_func_width_loop/t/u2r | A+B | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect)  |
**list deep A+B**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 3 | InterfaceModPort/d InterfaceModPort/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 2 | N0056 | 2 | 5 | PreprocTest/d PreprocTest/t | B | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 3 | N0891 + N0980 + N1946 | 2 | 7 | FuncStructVal/d FuncStructVal/t | A+B | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRngSkip |
| 4 | N0083 + N0422 + N0484 + N1149 | 2 | 9 | LogicTypespec/d LogicTypespec/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorr |
| 5 | N0001 + N0191 + N0853 + N1127 | 2 | 11 | OutputSizeWithParameterOfInstanceInitializedByStructMember/d/u2r OutputSizeWithParameterOfInstanceInitializedByStructMember/t/u2r | B | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue |
| 6 | N0025 + N0033 + N0133 + N0487 + N0754 + N0794 | 2 | 13 | cfg_func_width_loop/d/u2r cfg_func_width_loop/t/u2r | A+B | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect)  |
| 7 | N0028 + N0045 + N0552 + N0675 + N0761 + N0817 + N2412 | 2 | 15 | struct_param_func_config/d/u2r struct_param_func_config/t/u2r | A+B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law defPkgS |
| 8 | N0021 + N0030 + N0078 + N0284 + N0416 + N0426 + N0779 + N0791 + N0836 + N0921 + N1009 + N1069 + N1112 + N1113 + N1119 + N2405 | 2 | 17 | Scr1SvTests/d Scr1SvTests/t | A+B | cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) < cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst |
| 9 | N0063 + N0073 + N0118 + N0286 + N0413 + N0800 + N0873 + N0893 + N0907 + N0908 + N0917 + N0923 + N0936 + N0951 + N0964 + N1125 + N2470 + N2471 | 1 | 18 | BlackBePipeInt/d | A+B | emitExpr (ExprEmit.cpp, law caTernaryArmPatternFlatten99) < emitExpr (ExprEmit.cpp, law patCaGenIdxValueRender |
| 10 | N0014 + N0905 + N1179 | 1 | 19 | BlackBePipeInt/t | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPacke |
| 11 | N0039 + N0141 + N0142 + N0273 + N0448 + N0451 + N0683 + N0690 + N0696 + N0697 + N1172 + N1338 + N1339 + N1342 + N1343 + N1382 + N1845 + N1862 + N1875 | 1 | 20 | Rggen/d | A+B | emitExpr (ExprEmit.cpp, law castTargetKeywordTypespecKind96) < emitStmt (StmtEmit.cpp, law importCloneBodyLoca |
| 12 | N0012 + N0034 + N0043 + N0051 + N0067 + N0068 + N0072 + N0075 + N0097 + N0109 + N0110 + N0117 + N0120 + N0158 + N0161 + N0171 + N0177 + N0178 + N0179 + N0180 + N0188 + N0197 + N0198 + N0203 + N0213 + N0230 + N0232 + N0247 + N0253 + N0254 + N0255 + N0256 + N0264 + N0266 + N0423 + N0467 + N0974 + N1050 + N1051 + N1066 + N1079 + N1080 + N1151 + N2400 + N2401 | 2 | 22 | BuildUVMPkg/d BuildUVMPkg/t | A+B | buildEnu
| 13 | N0011 + N0050 + N0098 + N0219 + N0303 + N0304 + N0305 + N0306 + N0325 + N0337 + N0374 + N0387 + N0390 + N0392 + N0399 + N0408 + N0458 + N0541 + N0596 + N0685 + N0753 + N0827 + N2411 | 2 | 24 | SimpleUVM/d SimpleUVM/t | A+B | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cp |
| 14 | N0447 + N1211 + N1212 + N1438 + N1439 | 1 | 25 | Scoreboard/d | B | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeTypespec (Type |
| 15 | N0024 + N0131 + N0134 + N0164 + N0182 + N0289 + N0340 + N0341 + N0343 + N0414 + N0420 + N0428 + N0449 + N0452 + N0478 + N0479 + N0492 + N0495 + N0496 + N0505 + N0507 + N0538 + N0543 + N0544 + N0547 + N0556 + N0558 + N0564 + N0569 + N0570 + N0571 + N0573 + N0574 + N0579 + N0584 + N0585 + N0586 + N0587 + N0588 + N0589 + N0594 + N0601 + N0603 + N0616 + N0620 + N0630 + N0634 + N0645 + N0647 + N0648 + N0650 + N0658
| 16 | N0054 + N0170 + N0370 + N0384 + N0424 + N0703 + N0989 + N1131 + N1154 + N1158 | 2 | 29 | MiniAmiq/d MiniAmiq/t | A+B | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStm |
| 17 | N0061 + N0077 + N0085 + N0090 + N0129 + N0415 + N0417 + N0446 + N0474 + N0525 + N0687 + N0727 + N0742 + N0746 + N0747 + N0812 + N0815 + N0829 + N0834 + N0835 + N0846 + N0928 + N0976 + N0978 + N0981 + N1002 + N1054 + N1074 + N1082 + N1218 + N1292 + N2382 | 1 | 30 | Earlgrey_0_1/t | A+B | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectEras |
| 18 | N0454 + N0545 + N0546 + N0772 + N1173 + N1181 + N1184 + N1194 + N1302 + N1381 + N1529 + N1539 + N1753 | 1 | 31 | Earlgrey_0_1/d | A+B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeTypespec (TypeEmit.cpp, law memberA |

### 12c. The recommended next briefs, per ground

**Not implementable, drop from both briefs**: InterfaceModPort d/t (N0040: the harness would have to pass `--sverilog`,
pass 188 R1), PreprocTest d/t (N0056: the `.vh` face), LogicTypespec d/t (a user decision, pass 160), Scr1SvTests d/t
(N0791: a Surelog binding defect behind which 15 more clusters wait; r11u200 3d). Of the 17 row-modes the deep lists
clear first, these 8 are the first 3-4 steps: **the rows that can still convert are FuncStructVal, OutputSize,
cfg_func_width_loop, struct_param_func_config, InterfArrayBind, BlackBePipeInt, then the big families.**

**Ground B (the module/type pair, after pass 223)**, in the order of rows per cluster:

1. **FuncStructVal d/t**: N0891 (golden's 4 operations under a typespec_member, TypeEmit `buildStructTs`, law
   typeParamDefaultBoundNoReduce20 nearest); with ground A's N0980 / N1946 and the named #747 / R2 (N1096 N2472 N2473)
   the row converts (A+B step 3).
2. **OutputSize...StructMember d/t** (uhdm2rtlil, downstream IDENTICAL): N0191 N0001 (the substituted hier_path's and
   its elements' spans, TypeEmit `emitInitHier`, decoded by pass 220 section 6.2), N0853 (the `'1` fill kept BIN in the
   instance cont_assign, ModuleEmit), N1127 (a ref_typespec full name under the hier_path). Four clusters, 2 row-modes,
   no A half.
3. **InterfArrayBind d**: N0427 (#183: ModuleEmit `emitContAssigns` shares the definition cont_assign with the
   elaborated listing where golden holds two objects; re-emit it for an interface-array element member with a literal
   right side, and the landed ExprEmit branch names it; pass 220 section 6.1, grid tools/probe/r11u220repro/cases/IA).
   One cluster, 1 row-mode.
4. **struct_param_func_config d/t**: N0817 N0028 N0761 N0552 N0045 (TypeEmit `buildStructTs`, the member typespec's
   reference names and the structural #1364), with ground A's N0675 / N2412 (ParamEmit `leftRefFix174`).
5. **cfg_func_width_loop d/t**: the kept call N0133 / N0487 (ModuleEmit `emitContAssigns`) and #464's rest (N0263's
   cfg rows, pass 216 residue 2), with ground A's N0025 N0033 N0754 N0794 (the elaborated formal clone, the folded
   range, r11u200).
6. **BlackBePipeInt**: d N0073 N2471 (+ N0028), t adds N0014 N0905 N1179 (the `cc_x_dim` member typespec names,
   TypeEmit `buildStructTs`); ground A holds 15-16 clusters here (the tagged-pattern constants and the elaborated
   parameter copies: N0868 #15272, N0897 #66, N0063 N0118 N0286 N0413 N0800 N0873 N0893 N0907 N0908 N0917 N0923 N0936
   N0951 N0964 N1125 N2470).
7. The UVM B families: N0120 heads 5 row-modes after the pairs (the `catch` enum_var span, TaskFuncEmit); the
   9-row-mode block N0039 N0171 N0067 N0068 N0161 N0180 N0158 N0188 N0117 N0213 N0230 N0232 N0254 N0255 N0256; after
   pass 223, UVM_SEQ_ARB_TYPE (an out-of-body extern method's alias-of-alias typedef) and `this_type` (a design-wide
   typedef lookup) head the rows (pass 223's residues 1-2, section 13).

**Ground A (the expression/parameter pair, after r11u224)**: the row-finishing A halves above (FuncStructVal N0980
N1946; struct_param_func_config N0675 N2412; cfg_func_width_loop N0025 N0033 N0754 N0794; BlackBePipeInt's 15-16);
then N0131 (6 row-modes: a constant's empty ref_typespec full name in Earlgrey and the MiniAmiq / SeqDriver clones,
ExprEmit, heads 4 rows after the pairs); the Earlgrey elaborated-scope names N0812 N0129 N0415 N0474 N0446 N0815 N0829
N0978 (ExprEmit `caPartSelBoundFoldTs` / `emitMixedHierPath`, 2 rows each, 1-7 cases each); Rggen's N0142 N0451 N0683;
Scr1SvTests' A names (N0416 N0779 N0836 N1069 N1119: useful only if the row's Surelog defect is ever excused); **and
the MiniAmiq symbol-table coin's writer** (section 8: § refFullNameThroughNamedExpr175's pointer-ordered walk, a
one-function fix). The probe-only A clusters with the most cases: N0003 (24), N1909 (14), N1914 (13), N1918 (13),
N0005 (13), N0744 (8, macroPasteDotText104's param_assign end column), N0084 (9).

## 13. Addendum: pass 223 landed at `75a564b0` during this map ([evidence/addendum_75a564b0/](evidence/addendum_75a564b0/))

Pass 223 (pair B r11u223: § tfArgScalarTdWriter223, § tfArgScalarTdExportFirst223, § fixedOuterAssocInnerReg223, §
unsizedInnerSizeDeclines223, § ndaAdjSizeFoldSized223, the verifier's § sizeDeclineTsInvalid223v and §
formalRegNoHeap223v; `R11U223_OFF`, `R11V223_OFF`) landed at 04:14 while this map ran. Re-measured without editing the
sections above:

* **The reference.** The pass-223 integration sweep equals the committed baselines at `75a564b0` cell for cell
  (1596 / 1742 / 4087 rows); all 3273 `slang:` lines name the main tree's `build/slang-uhdm` (`abaa83b8`, built before
  the sweep), frozen here as `slang-uhdm.h223`. This map's own sweep of it (from this `551c9751` checkout against the
  `551c9751` baselines) reads exactly pass 223's movement: probe 5 conversions + 1 change, surelog 7 changes, uhdm2rtlil
  0; byteverify against the integration sweep: 2 of 2560 movers, MiniAmiq d (0 raw / 0 order-blind dump lines: the
  symbol-table coin, which pass 223's § formalRegNoHeap223v keeps at the base's frequency but does not cure) and
  Scoreboard d (92 raw / 0 order-blind: the svunit listing coin). With `R11U223_OFF R11V223_OFF` the same binary reads
  0/0/0 against the `551c9751` baselines.
* **The fail list at `75a564b0`: 31 row-modes / 17 tests (surelog 25, uhdm2rtlil 6), 639 probe cases.** No row-mode
  converted; changed: MiniAmiq d/t and SeqDriver d/t `file(7)` -> `line(2)`, SimpleUVM d/t `file(54)` -> `file(40)`,
  Scoreboard d `file(30)` -> `file(16)`; converted cases r10uvm125repro/g125_b_shapes, g125_d_homes, r10uvm35repro/t47a,
  t47b, r10uvm36repro/t48c; t48a `line(10)` -> `name(2)`.
* **Clusters at `75a564b0`** ([landing223.txt](evidence/addendum_75a564b0/landing223.txt); the 9 moved corpus databases
  and 7 moved NE cases re-dumped and re-analyzed, every other database byte-identical to `551c9751`'s and its analysis
  reused; 670 of 670 analyzer-vs-tool): **706** (709 - 3): gone N0318 (the uvm_reg_cvr_t bit typedef, 4 rows), N0706
  (4 rows) and N0100 (2 cases); fell N0123 (UVM_FILE) 9 -> 2 rows, N0263 6 -> 2 rows (cfg_func_width_loop's stay),
  N0039 44 -> 40 cases; none new. The UVM rows' first records are now N0266 (MiniAmiq, SeqDriver: an enum_typespec
  span, pass 223's residue 1 `UVM_SEQ_ARB_TYPE`), N0337 (SimpleUVM, Scoreboard: `this_type`, residue 2) and N0072
  (BuildUVMPkg, `this_type`).
* **This map's pair-B prediction, audited at once.** Credited to pair B r11u223 (optimistic): 23 clusters, 1 row-mode
  (InterfArrayBind d), 21 cases; named-only the same row. **Pass 223 converted 0 row-modes and 5 cases.** Of the 23
  credited clusters: 1 gone (N0318, named), 2 fell (N0123 9 -> 2 and N0263 6 -> 2, named), 20 unchanged (N0427
  InterfArrayBind, the svaunit clone names N0481 N0516 N0521 N0550, the writer rule's faces N0121 N0144 N0321 N0565
  N2464, N0008, N0262, the kept call N0133 / N0487, the first-ten credits N0051 N0072 N0075 N0266 N0337 N0423). It
  cleared one uncredited cluster (N0706, the same family as N0318) and 4 of N0039's cases. Its laws are in TaskFuncEmit,
  UhdmExporter, TypeEmit and uhdm_main: N0318's pin (TypeEmit `bareScalarTdCopyOfFresh16`) names a file of the
  landing; N0123's (ParamEmit `makeParamTs`, the mint of the shared copy the law now splits per formal) does not, its
  ground override (B) does. The credit failed as map 13's did: the pass took its first brief item (the whole UVM_FILE
  family) and the `$size` items, not InterfArrayBind.
* **The away census of pass 223** (`R11U223_OFF R11V223_OFF` on `slang-uhdm.h223` against its pristine sweep, section 9's
  method): 25 databases (16 cases, 9 corpus), **0 lost chain-keyed**, 5942 toward; the flat key's 298 all excess
  removals in place; the reversed control reads 5942 lost. Pass 223's own census (0 lost, 5942 toward) reproduced.
* **The count after, at `75a564b0`**: with pair A r11u224 still live (its credit unchanged) and pair B's next refill
  not yet briefed, pair A alone clears **0 row-modes** (every remaining row needs ground B) and 58 cases: **31 / 17 and
  581 cases** optimistic (614 named-only). With pair B's section-12 list for its next refill (FuncStructVal's N0891,
  OutputSize's four, InterfArrayBind's N0427, struct_param_func_config's five, cfg_func_width_loop's kept call) and pair
  A's matching halves, the rows with small decoded open sets are 9 row-modes (FuncStructVal d/t, OutputSize d/t, InterfArrayBind d,
  struct_param_func_config d/t, cfg_func_width_loop d/t), and with BlackBePipeInt d/t (19-21 open clusters, mostly
  ground A) 11: **20 row-modes / 11 tests** would then remain,
  every one a big-family row (UVM 9, Earlgrey 2, Rggen 1, Scr1SvTests 2 behind the Surelog defect) or a
  not-implementable one (InterfaceModPort 2, PreprocTest 2, LogicTypespec 2).
* The UVM order-blind distance at `75a564b0` is pass 223's to publish at its own base (MiniAmiq 5941 -> 5238 there); it
  composes with pass 220's here, not re-measured.

## 14. Files, fence and process

* **cluster_index.csv**: one row per cluster (709): rows (row-modes carrying it) with surelog / uhdm2rtlil split,
  tests, objects, probe cases, first_in_rows, ground, coverage (COVERED by which pair and why, or OPEN with its map-13
  history), `rows_after_pairs`, `probe_after_pairs`, `first_in_after_pairs`, **`alone_on_top_of_pairs`** (row-modes it
  clears alone on top of both pairs), `alone_on_pristine`, the same against the NAMED heads, map 13's rows, coverage
  and site (`map13_*`), families, example tests, **site** (`mint < caller < caller` with the nearest law), probe laws,
  key, example object.
* **clusters.csv**: row-mode x cluster with its object count and a `first` flag (1084 lines); **probe_clusters.csv**
  the same per case (1654).
* **fail_list.csv** (31) and **probe_fail_list.csv** (644): the strict cell, first cluster, its coverage, ground and
  site, cluster counts, family, downstream verdict, the first OPEN cluster and the open set after the pairs and after
  the NAMED heads, `clears`.
* Every differing object of every row-mode and case is in the analyzer's output (one facet row per differing (object,
  facet), 43 MB for the corpus, regenerated by drivers/run14b.sh step 1); the csvs above carry the per-cluster counts
  and [evidence/clusters/](evidence/clusters/) one example record dump per cluster with a row or at least 3 cases
  (374), [evidence/objects.csv](evidence/objects.csv) one example object for every cluster (709).
* **evidence/**: `report.txt` (drivers/report14b.py), `audit.txt` (audit14b.py), `final14.txt`, `landing220.txt`,
  `pristine_index.csv` (final14.py's table with map 13's columns), `greedy14.json`, `greedy14_named.json`,
  `routes.json`, `ground_override.json`, `sites.json` (the 25 pins used: 15 new, 10 of the first run), `sites_new.json`,
  `pins_new.txt` (the gdb backtraces), `pinwant.txt`, `evwant.txt`, `tables/`, `controls/`, `determinism/`
  (det_head.txt, det_ob.txt, det_off175.txt, pinsym_N.gdb and .log, the two draws' symbol-table diff), `rebuild/`,
  `uvm/` (families.txt, census_rank.csv, uvmdist_H.txt), `away/` (every state's census in both record forms, the
  reversed controls), `downstream/` (dsfaces_P.csv, ds_cases.txt, nonidentical.txt), `sweeps/` (each sweep's gate
  lines, the cmds.txt binary audit, the byteverify outputs), `first_run_896ec643/` (the stalled first run's report,
  audit, away totals, UVM census and distance with and without the r11u218 patch, its downstream csv, and
  `law218_on_896ec643.patch`, the measured binary's source, NOT applied), `addendum_75a564b0/` (section 13).
* **drivers/**: `run14b.sh` (this edition's pipeline as run), `env.sh` (the pins, the scratch locations from the
  caller, the fence), `common.py` (the key rewrite + the fence), `jobs.py`, `probejobs.py`, `probelaw.py`,
  `strict_runs.sh`, `run1.sh`, `cc.sh` + `strictcmp_x.cpp`, `objrank.cpp`, `sym.cpp`, `ord.cpp`, `analyze.py`,
  `final14.py`, `landing220.py` (section 3 and the addendum), `pinmulti.py`, `sites.py`, `mkroutes14b.py`,
  `report14b.py`, `audit14b.py`, `tables14b.py`, `evid.py`, `bvmirror.sh`, `probecmp.sh` (probe databases of two
  checkouts compared by normalised dump), `awayall.py`, `awaylandings.sh`, `statesweeps.sh`, `dsfaces.py`,
  `uvmcensus9.sh` (+ r11u175's `uvmcensus.py`, `uvmfamilies.py`), `uvmdist.sh`, `det.sh`, `ob.sh`, `pinsym.sh`,
  `rebuildid.sh`. The first run's drivers for the unlanded patch (`run14.sh`, `lawsweep.sh`, `crosssection.sh`,
  `census.sh`, `censum.py`, `mkroutes14.py`, `report14.py`, `audit14.py`, `tables14.py`) are kept as run at
  `896ec643`. Every driver resolves the repository from its own location and takes the scratch and binary
  directories from the caller (`MAP_W`, `MAP_BIN`, `MAP_H`, `SWPFX`, `SP`); none names a `/tmp/wt_` or pass-prefixed
  scratch path.
* **tests/LAWS.md** must be regenerated at landing (`python3 scripts/law_index.py`): this new `tools/probe/` directory
  adds one row; this patch cannot touch `tests/` (every sweep here exits 1 on that staleness alone).

**Fence and process.** No fenced read (section 2). Memory: three agents shared the machine; the corpus analyzer's
three-worker pool lost its two Earlgrey jobs to killed workers (the pool hung, its remaining workers idle); they were
re-run with one worker and appended (the rule "a killed process is a retry, not a measurement"). Twice a command
of this map ran a tool variable that was unset in its shell (env.sh not sourced), so bash executed a `.uhdm` database
as a script (the mechanism pass 223 reported): (1) `$UHDM_CMP` on a golden database during the positive controls, with
the main tree as the working directory: it printed "command not found" lines and wrote nothing (the main tree's
`git status` stayed clean and its top directory's mtime predates the command); (2) `$UHDM_DUMP` during the addendum's
coin check, in this map's own scratch directory: it wrote two empty files with control-character names there, removed
at once (nothing else touched). Both measurements were re-run with the tools' absolute paths; every shipped driver
takes the tools from env.sh.
Two worktree operations were declined by the permission check and not pursued: re-pointing the first run's second
worktree at the new base (it would have discarded that worktree's applied r11u218 patch and its build) and adding a
third worktree; the rebuild identity was measured with a second build directory in this worktree instead. The first run's worktrees and scratch
are left in place for the operator.
