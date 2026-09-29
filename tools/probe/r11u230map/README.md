# r11u230 — the strict ground map, fifteenth edition (measured at `97343175`; addendum at `9c9c11d6`)

Measurement only: no file under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` changes. The map covers
every `STRICT_NOTEQUAL` row-mode of the committed baselines and every `STRICT_NOTEQUAL` probe case, clusters their
differing strict records by (first field, object type, shape), pins each cluster twice: to the function that MINTS its
example object (map 14's pins, re-pinned where the example changed) and, new in this edition, to the function that
WRITES the differing field (a gdb run per cluster watching the field, section 5), routes the clusters to the two
grounds and the live pairs, and measures every landing since map 14 (`tools/probe/r11u222map`, measured at
`551c9751`, addendum at `75a564b0`) for records moved away from golden.

## 0. Bases, what landed since map 14

* **Base measured: `97343175`** (the verification r11u229). The HEAD sweep read is the r11u229 integration sweep
  (read-only): its csvs equal `results/golden_*.csv` at `97343175` cell for cell (1596 / 1742 / 4087 rows, 0
  differences), and all 3273 corpus `slang:` lines of its `cmds.txt` name the main tree's `build/slang-uhdm`, whose
  bytes this worktree's build reproduces (`7e50408d`, section 2).
* **Landings since map 14, all read** (README verdicts, laws, conversions, residues): pass 223 (`75a564b0`, map 14's
  own addendum), map 14 (`4a620bd0`, tools only), **pass 224** (`ac0dda58`, tools/probe/r11u224repro +
  v11u224repro), **pass 225** (`1a30095a`, r11u225repro + v11u225repro), **the verification r11u226** (`01dc93ab`,
  r11u226verify), the patch-file removal (`a332e45b`, `e0d6957c`: tools and tests only) and **the verification
  r11u229** (`97343175`, r11u229verify).
* **The live pairs this map was briefed on**: pair A **r11u227** (ExprEmit / EmitHelpers / StmtEmit / ParamEmit, base
  `ac0dda58`) and pair B **r11u228** (TypeEmit / ModuleEmit / UhdmExporter / TaskFuncEmit / uhdm_main, base
  `1a30095a`). **Both landed while this map ran**: pass 228 at `cd4fd02a` (09:05) and pass 227 at `9c9c11d6`
  (09:20). Everything above section 14 is at `97343175` and is not edited for them; **section 14 is the addendum at
  `9c9c11d6`**: what they moved, this map's prediction for them audited at once, and the yield of the NEW live pairs
  r11u231 (pair B, base `cd4fd02a`) and r11u232 (pair A, base `9c9c11d6`), whose briefs were dispatched during this
  map.

## 1. Summary

| measure | at `97343175` |
|---|---|
| fail list (committed baselines) | **28 row-modes / 15 tests** (surelog 24: default 13, testflags 11; uhdm2rtlil 4: 2 + 2), **634 probe cases** |
| first fields (csv detail column) | surelog: line 6, endcol 6, type 4, file 4, fullname 2, endline 2; uhdm2rtlil: line 2, fullname 2; probe: fullname 202, line 99, endcol 75, type 74, name 60, depth 50, file 39, col 15, endline 10, value 9, decompile 1 |
| clusters | **695** (284 with a corpus row, 525 with a probe case); 693 keep a map-14 id, 2 are not in map 14 (N1446 reuses map 1's id, N2476 new); 16 of map 14's 709 gone |
| analyzer vs tool | the python mode-4 rule agrees with `uhdm-strictcmp`'s own verdict on **662 of 662** jobs (28 row-modes + 634 cases) |
| writer pins (new) | **563 clusters** pinned to the WRITER of the differing field on their smallest example, **83** row clusters again on their smallest CORPUS row, the **13 head records** of the fail-list rows, BlackBePipeInt d's four ground-B-filed clusters on the default row and pass 225's two conversions at the landing-off state: **669 gdb runs, every one writing the reference database byte for byte**; last write by a watchpoint 150, by a setter 315, a full name through the parent chain 52, no write after the mint 46; writer frame on ground A 290, B 263, elsewhere 10 |
| N0039 / N0120 (brief question 2) | **N0039: written in ground A** (ParamEmit `predefIntTypespec` on the BuildUVMPkg row, ExprEmit `emitExpr` on the probe shape), map 14's ground-B filing superseded; **N0120: written in ground B** (TaskFuncEmit `emitTaskFuncs`, the `catch` enum_var's span through `copyLoc`) |
| landings since map 14 (section 3) | pass 224: 0 row-modes, 5 probe cases; **pass 225: InterfArrayBind d, OutputSize...StructMember d/t**; r11u226, r11u229: bytes only |
| yield of the live pairs (optimistic, section 6) | pair A r11u227 optimistic (139 clusters): 5 / 2 / 137; pair B r11u228 optimistic (16 clusters): 0 / 0 / 11; both pairs optimistic: 8 row-modes / 4 tests / 154 probe |
| **fail list after both live pairs** | **20 row-modes / 11 tests (today 28 / 15)** optimistic; named-only: 24 row-modes / 13 tests, probe 551 |
| **realised (addendum)** | passes 228 and 227 converted **0 row-modes and 0 probe cases**: fail list at `9c9c11d6` **28 / 15, 634** (FuncStructVal d/t `endcol` -> `file`, 20 probe cases shrink) |
| away census since map 14 | **0 records lost chain-keyed for every landing** (pass 224: 134 toward, pass 225: 15, r11u226 and r11u229: bytes only); pass 224's 13 flat-key losses all excess removals in place; the reversed controls read 134 and 15 lost |
| determinism | **one hash per row-mode** on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg: **MiniAmiq d/t 1 hash in 12 draws each (r11u226's cure holds), Scoreboard d 1 in 12 (r11u229's cure holds)**, every draw equal to the HEAD sweep's |
| rebuild identity | three independent builds of `97343175` byte-identical (`7e50408d`); the `-g1` binary writes the same bytes on the two rebuild cases and on all 669 writer-pin examples |
| UVM family census | **14,341 objects in 155 clusters** (map 14: 15,588 in 168; 14,792 without its Scoreboard coin draw) |

## 2. Inputs, binaries, the fence

| binary (frozen `chmod 555` in the scratch bin directory before any measurement) | md5 | what |
|---|---|---|
| `slang-uhdm` | `7e50408d1da06eaece796ba1903c589f` | `97343175` built in this worktree (`-DSLANG_UHDM_USE_SYSTEM_DEPS=ON`, `-j 2`); equal to the main tree's build that made the HEAD sweep |
| `slang-uhdm.rebuild2` | `7e50408d1da06eaece796ba1903c589f` | a second build directory, configured and built from nothing (rebuild identity, section 8) |
| `slang-uhdm.g1` | `4287f4e8bab7769223e35feab53d668e` | `-DCMAKE_CXX_FLAGS=-g1`, target `slang_uhdm` (the mint and writer pins); writes the same bytes as `slang-uhdm` on every example it ran (section 5) |
| `slang-uhdm.h227` | `8d6b76685739e0fcb064eb0fee37399f` | the main tree's build at `9c9c11d6` (passes 228 + 227), copied after its integration sweep (section 14) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the gate's comparator (this worktree's build; equal to the main tree's) |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's variant with the raw full name and `--dump-ids` (drivers/cc.sh), for record dumps, ids and the raw census |
| `objrank` | `82be8e819d67948b41f0cbf0a904f216` | creation rank of an object within its type (drivers/objrank.cpp) |
| `fieldoff` | `fccfdb80464879b9b43b194a2cd3e87a` | the byte offsets of UHDM `BaseClass`'s watched fields (drivers/fieldoff.cpp): `vpiParent_` 32, `vpiLineNo_` 44, `vpiEndLineNo_` 48, `vpiColumnNo_` 52, `vpiEndColumnNo_` 54 |
| `st<k>.sh` | | `exec env <switches> slang-uhdm "$@"`: the landing-off states of section 9 |

Every `slang:` line of every corpus `cmds.txt` of this map's own sweeps names its sweep's wrapper or binary (3273 of
3273 per sweep, [evidence/sweeps/cmds_binary_audit.txt](evidence/sweeps/cmds_binary_audit.txt)).

**The pristine gate sweep reproduces HEAD.** `tests/sweep.sh --jobs 3` with `slang-uhdm` in this worktree
([evidence/sweeps/sweep_pristine.log](evidence/sweeps/sweep_pristine.log)): probe 3453 + 634 **0/0/0**, surelog
**0/0/0**, uhdm2rtlil **0/0/0**, downstream **803 / 66 / 2 / 0** (the two EQUIVALENT rows func_upto and
matching_end_labels, as recorded); the csvs equal the HEAD sweep's except the LowMemLib / LowMemPkg testflags
detail text (the workdir path in a Surelog log line: environment). The sweep's exit 1 is the law index's staleness
from this untracked directory alone. byteverify (`SELFCHECK=1`, fenced databases left out of both mirrors unread)
against the HEAD sweep: **0 movers of 2560** (the self-check's 2559 of 2560 is its fixed file compared with itself);
the probe databases, compared by path-normalised uhdm-dump since the two sweeps ran from different checkouts: **0 of
4087** ([evidence/sweeps/](evidence/sweeps/)).

**The fence.** Every driver that reads databases, sources or case lists takes the four slang-fenced names from the
`FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed (`drivers/common.py fenced()`,
`drivers/env.sh`); no fenced name is spelled anywhere in this directory. The four fenced tests hold no
`STRICT_NOTEQUAL` row (jobs.py: `fenced_skipped 0`); their eight corpus databases per sweep are left out of every byte
mirror unread (`fenced_skipped=8`). The gate sweeps dispatched every row as the gate mandates; no binary, gdb or
script of this map ran on a fenced test's sources or databases outside them (pinwriter.py and pinmulti.py refuse a
fenced example). Every tool called through a variable is checked with `[ -x ]` first (section 15). A grep of this
directory for the four names reads 0.

## 3. What landed since map 14, and what it did to the map ([evidence/landings/](evidence/landings/))

Measured two ways: the committed baselines at each landing commit (drivers/audit15.py section A), and, per landing
whose laws still move records, **the landing-off state sweep** (the HEAD binary under the landing's switches, all
probe and corpus databases) re-analyzed where its databases differ from HEAD's (drivers/statejobs.py + analyze.py,
drivers/landing15.py: BEFORE = the landing off, AFTER = HEAD). Each state sweep reproduces its landing's own gate
movement reversed exactly ([evidence/sweeps/](evidence/sweeps/)).

| landing | row-modes converted | probe cases converted | strict-cell changes | state sweep (switches) | byte movers (corpus / probe) | cluster movement (BEFORE -> HEAD) |
|---|---|---|---|---|---|---|
| pass 223 (`75a564b0`, map 14's addendum) | - | 5 | 7 | (map 14 section 13) | | N0318, N0706, N0100 gone; N0123 9 -> 2 rows, N0263 6 -> 2, N0039 44 -> 40 cases |
| **pass 224** (`ac0dda58`) | - | **5** (r10svs2repro/s5_negctl, w3_macrodeep, r10v121repro/v121_c, r10v172repro/v172_3_pos, r10v174repro/v174_b_sysfns) | 6: BuildUVMPkg d/t `line(19)` -> `line(14)`, Scoreboard d `file(16)` -> `file(12)`, SimpleUVM d/t `file(40)` -> `file(36)`, **BlackBePipeInt t `depth(1)` -> `type(1)`** | `R11U224_OFF` | 10 / 7 | 700 -> 695 keys: **gone N0207** (9 rows: the dot after a `::` scope), N0832, N1060, N1066 (BuildUVMPkg d/t path names), **N0897** (BlackBePipeInt t #66), N2159, N2163 (probe); **N0097 9 -> 0 rows** (9 -> 4 cases: the lvalue of a class `new`); **new N2476, N1446** (BlackBePipeInt t: unmasked behind #66, written by uhdm_main's `--elabuhdm` clone naming) |
| **pass 225** (`1a30095a`) | **InterfArrayBind d, OutputSize...StructMember d/t** | - | - | `R11U225_OFF R11V225_OFF` | 4 / 0 | 697 -> 695: **gone N0191, N1127** (OutputSize); N0427 3 -> 2 rows, N0001 3 -> 1, N0853 2 -> 0 |
| r11u226 (`01dc93ab`) | - | - | - | `R11V226_OFF` | 9 / 3 | bytes only (symbol-table order; the UVM rows): 0 records move |
| r11u229 (`97343175`) | - | - | - | `R11V229_OFF` | 0 / 0 | bytes only: this draw of the switched state is golden's svunit order (the coin, section 8); map 14's four Scoreboard keys N1211 N1212 N1438 N1439 were the other draw of that coin and are gone with the cure |
| **since map 14** | **3 row-modes / 2 tests** | **10** | | | | **709 -> 695**: 16 gone (above), 2 new (N1446, N2476) |

Differing objects per moved row-mode (analyzer facet rows), BEFORE -> HEAD: pass 224: MiniAmiq d/t 3784 -> 3771,
SeqDriver d/t 2721 -> 2706, SimpleUVM d/t 1521 -> 1510, Scoreboard d 484 -> 475, BuildUVMPkg d/t 224 -> 212,
BlackBePipeInt t 38834 -> 38809 (a count through the walk divergence: #66 cleared, the next structural record #15268
reached); pass 225: InterfArrayBind d 1 -> 0, OutputSize d/t 8 -> 0.

## 4. The fail list at `97343175` with sites ([fail_list.csv](fail_list.csv), [probe_fail_list.csv](probe_fail_list.csv))

| corpus | test | cell d / t | clusters d/t | first cluster (ground) | first site | first open after the pairs (optimistic) | open after pairs | clears | first open after the named heads | open after named | downstream |
|---|---|---|---|---|---|---|---|---|---|---|---|
| sur | InterfaceModPort | differ:endcol(12) / differ:endcol(12) | 1/1 | N0040 (B) | W: materializeDefNetTs (ModuleEmit.cpp, law deferredPortUnpackedArrayTs)  | N0040 | 1/1 | no | N0040 | 1/1 | - |
| sur | PreprocTest | differ:endcol(2) / differ:endcol(2) | 1/1 | N0056 (B) | W: [setLoc] buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPack | N0056 | 1/1 | no | N0056 | 1/1 | - |
| sur | LogicTypespec | differ:endline(3) / differ:endline(3) | 4/4 | N0422 (B) | W: [setLoc] makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emit | N0422 | 4/4 | no | N0422 | 4/4 | - |
| sur | FuncStructVal | differ:endcol(7) / differ:endcol(10) | 5/6 | N1096 (A) | W: [setLoc] emitExpr (ExprEmit.cpp, law r10fsv3) < emitExpr (ExprEmit.cpp | - | 0/0 | yes (pair A, optimistic) | N2472 | 2/2 | - |
| sur | Scr1SvTests | differ:type(1) / differ:type(1) | 17/17 | N0791 (B) | M: emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInsta | N0284 | 17/17 | no | N0284 | 17/17 | - |
| sur | BlackBePipeInt | differ:type(1) / differ:type(1) | 20/24 | N0868 (A) | M: emitExpr (ExprEmit.cpp, law r10fsv2) < emitParameters (ParamEmit.cpp,  | - | 0/0 | yes (pair A, optimistic); yes (pairs A+B, optimistic) | N0964 | 16/17 | - |
| sur | Rggen | differ:file(3) / - | 20/- | N0141 (B) | W: [setLoc] makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < shar | N0141 | 19/- | no | N0141 | 19/- | - |
| sur | Earlgrey_0_1 | differ:fullname(19) / differ:fullname(19) | 53/45 | N0812 (A) | W: emitExpr (ExprEmit.cpp, law genScopeProcOpFoldTs75) < emitMixedHierPat | N0525 | 26/27 | no | N0415 | 50/42 | - |
| sur | BuildUVMPkg | differ:line(14) / differ:line(14) | 46/46 | N0072 (B) | W: [setLoc] buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonC | N0177 | 19/19 | no | N0075 | 40/40 | - |
| sur | Scoreboard | differ:file(12) / - | 54/- | N0337 (B) | W: [setLoc] buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonC | N0467 | 16/- | no | N0144 | 47/- | - |
| sur | SimpleUVM | differ:file(36) / differ:file(36) | 64/64 | N0337 (B) | W: [setLoc] buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonC | N2464 | 19/19 | no | N0144 | 57/57 | - |
| sur | SeqDriver | differ:line(2) / differ:line(2) | 124/124 | N0266 (B) | W: [setLoc] operator() (UhdmExporter.cpp, law tfArgAliasEndFollows146v) < | N0492 | 64/64 | no | N0423 | 118/118 | - |
| sur | MiniAmiq | differ:line(2) / differ:line(2) | 130/130 | N0266 (B) | W: [setLoc] operator() (UhdmExporter.cpp, law tfArgAliasEndFollows146v) < | N0492 | 64/64 | no | N0423 | 124/124 | - |
| uhd | cfg_func_width_loop | differ:line(3) / differ:line(3) | 7/7 | N0263 (A) | W: [setLoc] makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < make | - | 0/0 | yes (pairs A+B, optimistic) | - | 0/0 | IDENTICAL |
| uhd | struct_param_func_config | differ:fullname(5) / differ:fullname(5) | 7/7 | N0817 (A) | W: buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | - | 0/0 | yes (pair A, optimistic) | - | 0/0 | IDENTICAL |

Columns: the strict cell per mode; clusters per mode; the row's first cluster (the earliest differing record's
cluster) with its ground; the first site, `W:` = the writer of the differing field (section 5), `M:` = the mint (a
struct / order cluster has no field); the first cluster still OPEN after both live pairs (optimistic) and the count of
open clusters; whether the pairs clear it; the same against the NAMED heads only; the downstream verdict of the
uhdm2rtlil rows. `probe_fail_list.csv` has the same per case (first cluster, coverage, ground, site, writer, counts,
clears).

**First clusters of the probe cases** (top 40; [evidence/tables/t_pfirst.md](evidence/tables/t_pfirst.md)):

| first cluster | probe cases it heads | clears (pairs, optimistic) | ground | status | key | top laws |
|---|---|---|---|---|---|---|
| N0284 | 44 | no 44 | B | OPEN (map 14 ground-A+B step 9) | `struct\|ours-only:fewer-copies\|constant\|under:cont_assign` | srlgUnvaluedActualLitRetFold8:19 loopCaParamReadKeepsLiteral116:10 caS |
| N0039 | 39 | yes pair A 34, yes pairs A+B 3, no 2 | A | COVERED r11u227 (item 1: N0039 (its field writer i | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | nestedParamActualTs6:22 genIfUnvaluedFuncParam7:4 satArrArgFirstElem5: |
| N0263 | 34 | no 30, yes pairs A+B 2, yes pair A 2 | A | COVERED r11u227 (row named: r11u227 brief item 1:  | `span\|logic_typespec\|line+col+endline+endcol\|under:ref_typespec` | caIfacePortDeclNetMint93:7 tpPackedArrayTsVar108:5 tpElemRebindElabPor |
| N0738 | 27 | no 27 | A | OPEN | `name\|logic_typespec\|tok:id::->\|under:ref_typespec` | pkgTdQualParamCopiesListing111:11 defPkgMemberTdOfNamedShares108:8 tpP |
| N0739 | 26 | yes pair A 22, no 4 | A | COVERED r11u227 (item 5: map 13's N0739) | `struct\|ours-only:fewer-copies\|ref_obj\|under:cont_assign` | pkgRhsStructBareCopy111:14 defPkgMemberTdOfNamedShares108:11 tpPackedA |
| N0003 | 24 | no 24 | A | OPEN | `fullname\|ref_typespec\|golden-empty\|under:operation` | patParamEvalFuncRead26:12 patParamLeftoverShare26:6 catParamLeftoverRe |
| N0008 | 18 | yes pair A 18 | B | COVERED r11u227 (item 5: N0008 (a design param_ass | `fullname\|ref_typespec\|golden-empty\|under:constant` | impFoldRhsMirrorsLhsTs201:7 sizeDimOvrChain4:4 impUnsizedBasedLhsNoTs1 |
| N0479 | 16 | no 16 | B | OPEN (map 14 ground-A+B step 13) | `struct\|golden-only:fewer-copies\|class_typespec\|under:ref_typespec` | classTdCloneSpecOverridesOwnArgs112:12 classTdCloneTakesTheBasesEmptyL |
| N1916 | 12 | no 12 | B | OPEN | `struct\|golden-only:fewer-copies\|logic_net\|under:cont_assign` | caIfaceNdaNameFoldsToParamValue88:9 caIfaceElabNetDeclAssignListing88: |
| N0040 | 9 | no 9 | B | OPEN (map 14 ground-B step 1) | `span\|logic_typespec\|endcol\|under:ref_typespec` | caIfaceNdaNameFoldsToParamValue88:5 caIfaceElabNetDeclAssignListing88: |
| N0084 | 9 | no 9 | A | OPEN | `fullname\|ref_typespec\|tok:id@id.id.->\|under:typespec_member` | tpAnonAggParamTsNoStamp47:7 genCaTypeParamCastUnsupported113:1 typePar |
| N0744 | 8 | no 8 | A | OPEN | `span\|param_assign\|endcol\|under:package` | macroPasteDotText104:8 |
| N0494 | 8 | no 8 | B | OPEN | `fullname\|ref_typespec\|golden-empty\|under:packed_array_typespec` | typeParamAnonAggDefault107:5 tpPackedArrayTsVar108:1 typeParamNamedEle |
| N0746 | 7 | yes pair A 7 | A | COVERED r11u227 (the Earlgrey_0_1 ground-A scope-n | `file\|int_typespec\|golden-empty\|under:ref_typespec` | sizeDimOvrChain4:4 loopCaParamReadKeepsLiteral116:3 portViewRangeRecvP |
| N0129 | 7 | yes pair A 6, no 1 | A | COVERED r11u227 (the Earlgrey_0_1 ground-A scope-n | `fullname\|ref_typespec\|tok:->.id\|under:constant` | genCaUnboundTernConcatFence23:2 insideSetFirstRangeTruncates99:2 genEl |
| N0108 | 7 | no 7 | B | OPEN | `fullname\|ref_typespec\|tok:id@id.id.id.->\|under:typespec_member` | tpStructKindNet112:5 typeParamAnonAggMemberNoReduce35:1 typeParamAnonA |
| N0051 | 6 | yes pair B 6 | B | COVERED r11u228 (a UVM/Earlgrey first record, grou | `span\|class_typespec\|endcol\|under:ref_typespec` | dpiExportListedAtExportItem216:1 uninstIfaceForeachHdrUnresolved220:1  |
| N0127 | 6 | no 6 | B | OPEN | `span\|array_typespec\|endcol\|under:ref_typespec` | localBlockStmtSelBinds122:5 castTargetKeywordTypespecKind96:1 |
| N0264 | 6 | no 6 | B | OPEN (map 14 ground-A+B step 9) | `span\|int_typespec\|endcol\|under:ref_typespec` | tfItemLocalLosesToPkgVar148:2 wildcardImportCopiesPkgVarsToDefNets223: |
| N0496 | 6 | yes pair A 6 | A | COVERED r11u227 (the UVM ground-A families, optimi | `struct\|golden-only:fewer-copies\|class_var\|under:ref_obj` | cloneForInitVarBind204:7 |
| N0131 | 5 | no 5 | B | COVERED r11u227 (item 1: N0131 (a constant's empty | `fullname\|ref_typespec\|ours-empty\|under:constant` | srlgUnvaluedActualLitRetFold8:2 cloneArrayRecvArgMintsElemVar193:2 imp |
| N0753 | 5 | yes pair A 5 | A | COVERED r11u227 (the UVM ground-A families, optimi | `fullname\|ref_obj\|tok:->id.\|under:port` | bindIfaceTwinInParent46:5 qualifiedLifetimeMethodLosesNamePortsBody46: |
| N1931 | 5 | no 5 | B | OPEN | `span\|packed_array_var\|endcol\|under:module_inst` | tpPackedArrayTsVarInit110:7 tpPackedArrayTsVar108:1 |
| N1930 | 5 | no 5 | A | OPEN | `fullname\|type_parameter\|tok:id->id.id\|under:interface_inst` | tpAnonAggParamTsNoStamp47:2 typeParamChainBorrow45:1 bitsTypeParamArgN |
| N0474 | 4 | yes pair A 4 | A | COVERED r11u227 (the Earlgrey_0_1 ground-A scope-n | `fullname\|ref_typespec\|tok:->.id[n]\|under:constant` | genCaTopLoopParamPaCopy105:2 defGenElemIpsVarSel112:1 modLocalIntTsFol |
| N0030 | 4 | no 4 | B | OPEN (map 14 ground-A+B step 9) | `fullname\|ref_obj\|tok:id.->\|under:operation` | genScopeOwnParamNoSelFold56:2 genLpIdxOpOperandFold112:2 genLpUseFoldP |
| N1942 | 4 | no 4 | A | OPEN | `span\|var_select\|col\|under:hier_path` | hpCompMultiSelElemShape:1 concatIdxDecompile29:1 selChainElemShapeIsSy |
| N0762 | 4 | no 4 | A | OPEN | `span\|struct_typespec\|endline+endcol\|under:package` | caIfaceElabNetDeclAssignListing88:2 caIfaceNdaNameFoldsToParamValue88: |
| N0415 | 4 | yes pair A 4 | A | COVERED r11u227 (the Earlgrey_0_1 ground-A scope-n | `fullname\|ref_typespec\|tok:->.id.id\|under:constant` | elabConnEmit21:2 rangeBoundStoredWidth82:1 shadowedImportParamFold:1 |
| N0476 | 4 | no 4 | A | COVERED r11u227 (item 5: map 13's N0476) | `file\|logic_typespec\|ours-empty\|under:ref_typespec` | defPkgMemberTdOfNamedShares108:5 pkgTdOfNamedDimsListing111:5 impCopyB |
| N1174 | 4 | no 4 | B | OPEN | `fullname\|ref_typespec\|tok:id::id::->\|under:typespec_member` | classTdLocalVarKindFollowsCompileOrder10:4 |
| N0097 | 4 | no 4 | A | OPEN (map 14 gave it to pair A r11u224; pass 224 l | `span\|hier_path\|endcol\|under:assignment` | shellCallKeepsItsSyntax167:2 droppedCall14:1 covergroupBuiltinCall8:1 |
| N1945 | 4 | no 4 | A | OPEN | `struct\|ours-only:elsewhere\|bit_select\|under:ref_obj` | retNameSelBindsHomeReturnInCloneOnly171:3 classRetNameDefViewNoBind37: |
| N0685 | 4 | yes pair A 4 | A | COVERED r11u227 (the UVM ground-A families, optimi | `value\|parameter\|value:UINT->empty\|under:module_inst` | impFoldRhsMirrorsLhsTs201:3 pkgParamRefRhs210:1 |
| N0011 | 4 | no 4 | B | OPEN (map 14 ground-A+B step 10) | `file\|logic_net\|golden-empty\|under:ref_obj` | hoistedThisRidesTheForwardedBlock219:3 thisImplicitNetBoth38:1 |
| N0413 | 4 | no 2, yes pair A 2 | A | COVERED r11u227 (row named: r11u227 brief item 1:  | `span\|operation\|line+col+endline+endcol\|under:param_assign` | caStructParamGenScopeSubst69:3 ovStructPatNonStructFormal108:1 |
| N1906 | 4 | no 4 | B | OPEN | `file\|logic_typespec\|golden-empty\|under:ref_typespec` | defPkgMemberTdOfNamedShares108:4 pkgTdOfNamedDimsListing111:4 pkgFlatS |
| N1957 | 4 | no 4 | A | OPEN | `value\|constant\|value:UINT->UINT\|under:operation` | memLeftStampOwnType109:2 pkgPatCallArgFlat109:2 spVoidCastValue109:2 |
| N0001 | 4 | no 4 | A | OPEN (map 14 ground-B step 5) | `span\|ref_obj\|col+endcol\|under:hier_path` | ifacePortViewParamAssignsOnly:2 pkgStructFuncAssembleNested24:1 pkgQua |
| N1173 | 4 | yes pair A 2, no 2 | A | COVERED r11u227 (the Earlgrey_0_1 ground-A scope-n | `struct\|ours-only:fewer-copies\|hier_path\|under:cont_assign` | caStructParamGenScopeSubst69:3 caStructParamPatternSubst55:1 |

## 5. The writer pins, and the ranked OPEN clusters ([cluster_index.csv](cluster_index.csv), [clusters.csv](clusters.csv), [probe_clusters.csv](probe_clusters.csv))

**Why.** Map 14's audit found two rows pinned at the function that creates the object instead of the one that writes
the differing field (InterfArrayBind, struct_param_func_config), and pass 228 found a third (FuncStructVal's N0891).
This edition pins the WRITER of every OPEN cluster's differing field (and of every cluster with a corpus row):

* **Method** (drivers/pinwriter.py, summarised by drivers/pwsum.py): per cluster, the example record's UhdmId
  (`strictcmp_x --dump-ids`) gives its creation rank within its type (`objrank`); a gdb run of the `-g1` binary stops
  at that call of `Serializer::Make<Type>` (the MINT backtrace), `finish` returns the object's address, and the field
  is then watched to the end of the run: a span with two hardware watchpoints (`vpiLineNo_`, and
  `vpiEndLineNo_`+`vpiColumnNo_`+`vpiEndColumnNo_`), a file, name, value or decompile by a breakpoint on UHDM's
  out-of-line setter conditioned on `this` = the object, a full name by the class's `VpiFullName` setter plus a
  watchpoint on `vpiParent_` (UHDM synthesizes a full name from the parent chain when none is stored). **The writer is
  the last recorded write**; a write inside a generic helper (`setLoc`, `copyLoc`, the UHDM setters, UHDM's
  `DeepClone`) is attributed to its first caller outside the helpers, the helper kept in brackets; no write after the
  mint = the mint's function wrote it. Every gdb run's output database was compared with the reference database
  byte for byte (`db=SAME` on all 669), so the rank named the example object.
* **Coverage**: 563 of the 695 clusters, every one with a field whose key is OPEN or carries a corpus row (by facet: fullname 303, span 171, file 51, name 19, value 12, depth 7); the 128 struct / order clusters have no field and keep their mint pin (map 14's, re-pinned by drivers/pinmulti.py on the 28 whose example object changed: all BlackBePipeInt t's shifted records, N0001, N0014, N0073, N0097, N0123, N0427, N0853, N1179, N0905, N1446, N2476). 95 row clusters whose smallest example is a probe case were pinned again on their smallest corpus row (PW_PREFER=corpus); the two pins name different writer files on 31: N0014 (probe TypeEmit.cpp, row uhdm_main.cpp), N0030 (probe TypeEmit.cpp, row UhdmExporter.cpp), N0039 (probe ExprEmit.cpp, row ParamEmit.cpp), N0043 (probe TypeEmit.cpp, row UhdmExporter.cpp), N0051 (probe UhdmExporter.cpp, row TypeEmit.cpp), N0061 (probe ExprEmit.cpp, row TypeEmit.cpp), N0067 (probe TypeEmit.cpp, row UhdmExporter.cpp), N0068 (probe TypeEmit.cpp, row UhdmExporter.cpp), N0073 (probe ModuleEmit.cpp, row ParamEmit.cpp), N0118 (probe ExprEmit.cpp, row ParamEmit.cpp), N0129 (probe ExprEmit.cpp, row uhdm_main.cpp), N0131 (probe ExprEmit.cpp, row TaskFuncEmit.cpp), N0158 (probe TypeEmit.cpp, row UhdmExporter.cpp), N0164 (probe TypeEmit.cpp, row UhdmExporter.cpp), N0264 (probe ModuleEmit.cpp, row TypeEmit.cpp), N0273 (probe TypeEmit.cpp, row ExprEmit.cpp), N0417 (probe ModuleEmit.cpp, row ?), N0448 (probe TypeEmit.cpp, row ModuleEmit.cpp), N0481 (probe ModuleEmit.cpp, row UhdmExporter.cpp), N0492 (probe TypeEmit.cpp, row TaskFuncEmit.cpp), N0516 (probe ModuleEmit.cpp, row UhdmExporter.cpp), N0683 (probe ParamEmit.cpp, row TypeEmit.cpp), N0761 (probe TypeEmit.cpp, row ParamEmit.cpp), N0779 (probe TypeEmit.cpp, row UhdmExporter.cpp), N0784 (probe TypeEmit.cpp, row ?), N0834 (probe TypeEmit.cpp, row uhdm_main.cpp), N0846 (probe TypeEmit.cpp, row uhdm_main.cpp), N0923 (probe uhdm_main.cpp, row ParamEmit.cpp), N1125 (probe uhdm_main.cpp, row ParamEmit.cpp), N1179 (probe TypeEmit.cpp, row uhdm_main.cpp), N2471 (probe uhdm_main.cpp, row TypeEmit.cpp).
* **The writer and the mint differ in file on 66 clusters**; ground by the writer's own frame: A 290, B 263, neither 10 (a writer in UHDM's library or uhdm_main's elaboration).
  Writer chains that cross the grounds (the writer's frame on one ground, a caller on the other): 160 clusters (18 of them OPEN with a row after the pairs: N0001 N0056 N0123 N0273 N0340 N0341 N0422 N0449 N0451 N0452 N0492 N0544 N0588 N0589 N0779 N1113 N1119 N1131).

**N0039 and N0120 (the brief's question).**

* **N0039** (`span|int_typespec|line+col+endline+endcol|under:ref_typespec`, 10 rows in 6 tests, 40 probe cases): on
  its corpus example (BuildUVMPkg d #129711, golden 14837:35-36, ours 14699:13-14) the span is written by
  **ParamEmit `predefIntTypespec`** (through `setLoc`), called from UhdmExporter `emitClassDefn` < `emitPackageClasses`:
  the predefined `int` typespec a class listing takes, located at its first use where golden locates each use; on its
  smallest probe example (r10uvm59repro/c05_cast #31) by **ExprEmit `emitExpr`** (the cast target's keyword typespec,
  § castTargetKeywordTypespecKind96's branch) called from StmtEmit `emitStmt` < TaskFuncEmit `emitTaskFuncs`. Both
  writers are ground-A files, so **by both briefs' own rule N0039 is pair A's**; map 14's filing (ground B, from map
  13's decode of the TypeParam head) is superseded, the callers on ground B noted.
* **N0120** (`span|enum_var|line+col+endline+endcol|under:function`, 9 rows in 5 tests, heading 5 in map 14): on
  BuildUVMPkg d #70038 (golden 29246:25-33, ours 28907:3-58) the span is written by **TaskFuncEmit `emitTaskFuncs`**
  (through `copyLoc`, law atomVarSignedWritten68's block) < UhdmExporter `emitClassDefn` < `emitPackageClasses`: ground
  B, where its mint is too.

**The head record of every fail-list row, its writer** ([evidence/writers/heads_table.md](evidence/writers/heads_table.md);
pinwriter.py with PW_ROWS = the row, so the pinned object is the row's first differing record itself; BlackBePipeInt
and Scr1SvTests head on a struct record, no field):

| row (default mode) | first cluster | head record (golden / ours) | writer of the differing field (how) | mint | ground of the writer frame |
|---|---|---|---|---|---|
| BuildUVMPkg | N0072 | #26855 class_typespec 'this_type' line+col+endline+endcol: 13776:11:13776:42 / 56391:12:56391:32 | [setLoc] buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter.cpp, law typedefAliasSharesTyp (watch) | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootSha | B |
| Earlgrey_0_1 | N0812 | #106660 ref_typespec '' fullname: work@flash_ctrl / region_cfgs[8] | emitExpr (ExprEmit.cpp, law genScopeProcOpFoldTs75) < emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxAtPath79) < emitExpr (ExprEmit.cpp, law thisPath (setter) | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitMixedHierPath  | A |
| FuncStructVal | N1096 | #747 ref_obj 'config_pkg::NOC_TYPE_AXI4_ATOP' endcol: 106:16:106:28 / 106:16:106:46 | [setLoc] emitExpr (ExprEmit.cpp, law r10fsv3) < emitExpr (ExprEmit.cpp, law r10fsv2) < emitParameters (ParamEmit.cpp, law foldSigned9) (watch) | emitExpr (ExprEmit.cpp, law clsScopedBoundWholeSpan201) < emitExpr (Ex | A |
| InterfaceModPort | N0040 | #95 logic_typespec '' endcol: 27:3:27:8 / 27:3:27:21 | materializeDefNetTs (ModuleEmit.cpp, law deferredPortUnpackedArrayTs) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) < realMain (uhdm_ma (watch) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDe | B |
| LogicTypespec | N0422 | #14 logic_typespec 'my_package::typedef_logic_typespec' endline+endcol: 2:9:7:44 / 2:9:2:20 | [setLoc] makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitPackage (ParamEmit.cpp, law aliasFoldBoundFile183) < exportDesign (UhdmExporter. (watch) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitPackage ( | B |
| MiniAmiq | N0266 | #24915 enum_typespec 'uvm_pkg::UVM_SEQ_ARB_TYPE' line+col+endline+endcol: 332:40:332:56 / 1381:51:1381:67 | [setLoc] operator() (UhdmExporter.cpp, law tfArgAliasEndFollows146v) < exportDesign (UhdmExporter.cpp, law tfArgOutsideClassOrder216) < realMain (uhdm (watch) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (P | B |
| PreprocTest | N0056 | #9 bit_typespec '' endcol: 5:14:5:17 / 5:14:5:23 | [setLoc] buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp, law enumAliasEndAtDimOrInitDecl158) < exportDesign (UhdmExpo (watch) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (Para | B |
| Rggen | N0141 | #23164 logic_typespec '' file+span: rggen_adapter_common.sv 43:5:43:10 / rggen_bus_if.sv 9:3:9:28 | [setLoc] makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespec (TypeEmit.cpp, law splitPortTsKeyOnPortDecl171) < emitInterfaceInstan (setter) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespe | B |
| Scoreboard | N0337 | #26895 class_typespec 'this_type' file+span: uvm_algorithmic_comparator.svh 74:11:74: / uvm_sequence_library.svh 330:12:330:32 | [setLoc] buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter.cpp, law typedefAliasSharesTyp (setter) | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootSha | B |
| SeqDriver | N0266 | #24898 enum_typespec 'uvm_pkg::UVM_SEQ_ARB_TYPE' line+col+endline+endcol: 332:40:332:56 / 1381:51:1381:67 | [setLoc] operator() (UhdmExporter.cpp, law tfArgAliasEndFollows146v) < exportDesign (UhdmExporter.cpp, law tfArgOutsideClassOrder216) < realMain (uhdm (watch) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (P | B |
| SimpleUVM | N0337 | #26887 class_typespec 'this_type' file+span: uvm_algorithmic_comparator.svh 74:11:74: / uvm_sequence_library.svh 330:12:330:32 | [setLoc] buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter.cpp, law typedefAliasSharesTyp (setter) | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootSha | B |
| cfg_func_width_loop | N0263 | #464 logic_typespec 'mask_t' line+col+endline+endcol: 27:40:27:46 / 16:11:16:25 | [setLoc] makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeParamTs (ParamEmit.cpp, law pkgParamOwnDefRange) < drainDefParamTs (ParamEmit.cp (watch) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeParamTs ( | B |
| struct_param_func_config | N0817 | #759 ref_typespec '' fullname: work@struct_param_func_config.p::cfg_t.u / work@struct_param_func_config.u_c.Cfg.p: | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgParamTsRefColons131) < patchParamTypespecs ( (setter) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | B |

Read with the chain: the UVM heads are ground B throughout (UVM_SEQ_ARB_TYPE's span last written by UhdmExporter's
formal-writer lambda of § tfArgOutsideClassOrder216 / § tfArgAliasEndFollows146v, this_type's by UhdmExporter
`buildClassTypedefTs`); cfg_func_width_loop's #464 span is set in TypeEmit `makeTypespec` on the typespec ParamEmit
`makeParamTs` < `drainDefParamTs` chose (pass 228: a re-pointing in ParamEmit), struct_param_func_config's #759 name in
TypeEmit `buildStructTs` from ParamEmit's `memberScope`: both are ground A by pass 228's decode and ground B by the
writer frame, and the routing below takes the decode.

**The writer pin audited on the conversions it would have had to predict** ([evidence/writers/validate_pass225.txt](evidence/writers/validate_pass225.txt)):
the `R11U225_OFF R11V225_OFF` state's databases of the two rows pass 225 converted, pinned the same way:

| cluster (row) | writer at the landing-off state | mint | pass 225's law and file | reading |
|---|---|---|---|---|
| N0191 (OutputSize d/t: the substituted `Info.x` path's span) | `[setLoc] emitExpr` (ExprEmit) < **`operator()` (TypeEmit, the emitInitHier lambda)** | the same `emitExpr` < TypeEmit | § initHierAtRefToken225, TypeEmit `emitInitHier` | the fix is a later write in the writer's CALLER on ground B |
| N0427 (InterfArrayBind d: the element ref_obj's full name) | `emitExpr` (ExprEmit, law elabIfArrIdxChainName205) < **`emitContAssigns` (ModuleEmit)** | the same | § ifArrElemLitCaFresh225, ModuleEmit `emitContAssigns` | the fix is in the caller: a fresh cont_assign, so the landed ExprEmit law names it |
| N1127 (OutputSize: the path's ref_typespec full name) | `operator()` (TypeEmit, emitInitHier) | the same | § initHierCaLhsBareName225, TypeEmit | writer = law file |
| N0853 (OutputSize: the `'1` fill constant's value) | `emitContAssigns` (ModuleEmit) | the same | § initHierFillKept225 | writer = law file |

So a writer frame alone would have routed N0191 and N0427 to ground A (as map 13's mint pin did for N0427): **the
routing rule of this map is decoded override first, then the writer's frame, then the mint**, and every table carries
the writer's whole three-frame chain and the grounds it crosses (`writer_chain_grounds` in cluster_index.csv), so a
brief can name the caller. The same holds for pass 228's decode of struct_param_func_config: the full names of N0817
N0028 N0761 N0552 are SET in TypeEmit `buildStructTs` (the writer pin) from the `memberScope` string ParamEmit
`makeParamTs` passes (the value's source, pass 228's reading); the override takes pass 228's (ground A).

**Overrides this edition applies** (evidence/ground_override.json; drivers/mkroutes15.py): map 14's 64, then pass
228's decodes (N0817 N0028 N0761 N0552 N0045 N0891 N0263 N0073 -> A; the writer pin of N0073 on BlackBePipeInt t is
ParamEmit `emitParameters`, agreeing), N2471 -> A (on BlackBePipeInt d its writer chain is N0028's: TypeEmit
`buildStructTs` < ParamEmit `makeParamTs`, [evidence/writers/bb_default_row.txt](evidence/writers/bb_default_row.txt)), then N0039 -> A (above) and N0001 -> A (its map-14 basis, OutputSize, converted;
its one row left, Rggen d, is written by ExprEmit `emitExpr` inside a ModuleEmit generate lambda). **Overrides the writer frame contradicts** (18; the override stands, the writer chain is printed beside it): N0008 (override B, writer frame A: emitParameters (ParamEmit.cpp, law timeLitParamIntTs) < emitPackage (ParamEmit.cpp, law ca); N0009 (override A, writer frame B: [setLoc] makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmi); N0012 (override A, writer frame B: buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law mo); N0025 (override A, writer frame B: emitSyntaxExpr (TypeEmit.cpp, law bigDecUnderscoreDropped181v) < emitSyntaxExpr (TypeEmit.); N0028 (override A, writer frame B: buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamE); N0034 (override A, writer frame B: buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law mo); N0084 (override A, writer frame B: buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmi); N0123 (override B, writer frame A: [setLoc] makeParamTs (ParamEmit.cpp, law timeLitParamIntTs) < emitParameters (ParamEmit.cp); N0129 (override A, writer frame B: elabCloneFullNameUnstored137 (uhdm_main.cpp, law elabCloneInstTreeUnstored144) < realMain ); N0136 (override B, writer frame A: emitExpr (ExprEmit.cpp, law genProcFoldDeclTsScopeNamed167) < emitContAssigns (ModuleEmit.); N0215 (override B, writer frame A: emitExpr (ExprEmit.cpp, law genProcFoldDeclTsScopeNamed167) < emitExpr (ExprEmit.cpp, law ); N0263 (override A, writer frame B: [setLoc] makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeParamTs (ParamEmit.c); N0427 (override B, writer frame A: emitExpr (ExprEmit.cpp, law genProcFoldDeclTsScopeNamed167) < emitMixedHierPath (ExprEmit.); N0552 (override A, writer frame B: buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamE); N0817 (override A, writer frame B: buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamE); N2471 (override A, writer frame B: buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamE); N2474 (override A, writer frame B: emitTaskFuncs (TaskFuncEmit.cpp, law pkgTdRangeViewFold18) < emitClassDefn (UhdmExporter.c); N2475 (override A, writer frame B: emitTaskFuncs (TaskFuncEmit.cpp, law atomVarSignedWritten68) < emitClassDefn (UhdmExporter)

**Ranked OPEN clusters** (by the row-modes each still carries after both live pairs, optimistic, then the rows it
clears ALONE on top of both pairs, then the rows it heads, then probe cases; the last column is the writer where
pinned (`W:`), else the mint (`M:`); [evidence/tables/t_t1.md](evidence/tables/t_t1.md), all 134 in
cluster_index.csv):

| # | cluster | rows left (97343175) | sl/u2r | tests | families | first-open heads | alone | probe | ground | status | key | writer of the field (else the mint) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0171 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 5 | B | OPEN (map 14 ground-A+B step 9) | `struct\|golden-only:fewer-copies\|bit_typespec\|under:ref_typespec` | M: namedElemPackedDimTs31 (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypeParamDefaultTs (TypeEmit.cpp, law  |
| 2 | N0067 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 14 ground-A+B step 9) | `file\|class_typespec\|ours-empty\|under:ref_typespec` | W: classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPro |
| 3 | N0068 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 14 ground-A+B step 9) | `span\|class_typespec\|ours-zero\|under:ref_typespec` | W: classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPro |
| 4 | N0180 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 14 ground-A+B step 9) | `fullname\|ref_typespec\|ours-empty\|under:enum_typespec` | W: buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < makeTypespec (TypeEmit.cpp, law modPkgGenericSpecNamedBar |
| 5 | N0158 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN (map 14 ground-A+B step 9) | `depth\|bit_typespec\|ref_typespec->ref_typespec` | W: exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) < realMain (uhdm_main.cpp, law genCaPatKeepTagDefVi |
| 6 | N0188 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN (map 14 ground-A+B step 9) | `name\|enum_typespec\|ours-empty\|under:ref_typespec` | W: buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law modPkgGenericSpecNamed |
| 7 | N0117 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `span\|unsupported_typespec\|endcol\|under:ref_typespec` | W: [setLoc] emitTaskFuncs (TaskFuncEmit.cpp, law classScopedTdFormalUnsupported34) < emitClassDefn (UhdmExporter. |
| 8 | N0213 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `struct\|golden-only:absent\|enum_typespec\|under:ref_typespec` | M: buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildClassTypedefTs (UhdmExporter.cpp,  |
| 9 | N0230 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `span\|class_typespec\|line+endline\|under:ref_typespec` | W: classTpDefaultTsDrain180 (TypeEmit.cpp, law classTpFormalMovesTs180) < exportDesign (UhdmExporter.cpp, law cla |
| 10 | N0232 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `struct\|ours-only:elsewhere\|ref_typespec\|under:array_typespec` | M: emitTaskFuncs (TaskFuncEmit.cpp, law modTdRetCloneSymbolic20) < emitClassDefn (UhdmExporter.cpp, law externPro |
| 11 | N0254 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `fullname\|ref_typespec\|tok:id::id::->\|under:enum_typespec` | W: buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroup |
| 12 | N0255 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `span\|class_typespec\|line+col+endline+endcol\|under:class_defn` | W: [setLoc] buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < classElemVar (UhdmExpo |
| 13 | N0256 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `span\|class_var\|endcol\|under:function` | W: [copyLoc] emitTaskFuncs (TaskFuncEmit.cpp, law atomVarSignedWritten68) < emitClassDefn (UhdmExporter.cpp, law  |
| 14 | N0262 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | B | OPEN (map 14 gave it to pair B r11u223; passes 223 and 225 l | `struct\|golden-only:fewer-copies\|constant\|under:param_assign` | M: importPaCopy82 (ModuleEmit.cpp, law classImportParamStamped82) < classInheritsContainerImports23 (ModuleEmit.c |
| 15 | N0043 | 6 (6) | 6/0 | 3 | UVM | 0 | 0 | 3 | B | OPEN (map 14 ground-A+B step 9) | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | W: [setLoc] operator() (UhdmExporter.cpp, law tfArgQualOutsideWriter176) < exportDesign (UhdmExporter.cpp, law tf |
| 16 | N0078 | 6 (6) | 6/0 | 3 | Scr1 UVM | 0 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation` | W: emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law elabMisevalRefSu |
| 17 | N0426 | 6 (6) | 6/0 | 3 | Scr1 UVM | 0 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `fullname\|ref_obj\|ours-empty\|under:operation` | W: emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law elabMisevalRefSu |
| 18 | N0974 | 6 (6) | 6/0 | 3 | UVM | 0 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `struct\|ours-only:fewer-copies\|class_typespec\|under:ref_typespec` | M: buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter |
| 19 | N0467 | 5 (5) | 5/0 | 3 | UVM | 1 | 0 | 0 | B | OPEN (map 14 ground-A+B step 9) | `struct\|ours-only:fewer-copies\|array_typespec\|under:ref_typespec` | M: exportDesign (UhdmExporter.cpp, law enumNoBind13) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) |
| 20 | N0449 | 5 (5) | 5/0 | 3 | Earlgrey UVM | 0 | 0 | 3 | B | OPEN (map 14 ground-A+B step 13) | `fullname\|ref_typespec\|tok:id@id.id::id.->id::id::id::\|under:typespec_member` | W: buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < emitPackage (ParamEmit.cpp, law aliasFo |
| 21 | N0182 | 5 (5) | 5/0 | 3 | Earlgrey UVM | 0 | 0 | 2 | B | OPEN (map 14 ground-A+B step 13) | `struct\|golden-only:fewer-copies\|typespec_member\|under:struct_typespec` | M: operator() (TypeEmit.cpp, law cloneStructMemberBareTdAlias207) < importCloneBareTdAlias16 (TypeEmit.cpp, law c |
| 22 | N0040 | 4 (4) | 4/0 | 2 | Earlgrey the harness rows (InterfaceModPort, PreprocTest) | 2 | 2 | 14 | B | OPEN (map 14 ground-B step 1) | `span\|logic_typespec\|endcol\|under:ref_typespec` | W: materializeDefNetTs (ModuleEmit.cpp, law deferredPortUnpackedArrayTs) < exportDesign (UhdmExporter.cpp, law do |
| 23 | N0492 | 4 (4) | 4/0 | 2 | UVM | 4 | 0 | 8 | B | OPEN (map 14 ground-A+B step 13) | `fullname\|ref_typespec\|ours-empty\|under:array_typespec` | W: makeAssocArrayVar (TaskFuncEmit.cpp, law assocPromotedBoundAtBracket183) < emitTaskFuncs (TaskFuncEmit.cpp, la |
| 24 | N0478 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 17 | B | OPEN (map 14 ground-A+B step 13) | `struct\|golden-only:fewer-copies\|type_parameter\|under:param_assign` | M: - |
| 25 | N0479 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 16 | B | OPEN (map 14 ground-A+B step 13) | `struct\|golden-only:fewer-copies\|class_typespec\|under:ref_typespec` | M: copyClassTdSpecParams1 (UhdmExporter.cpp, law classTdCloneSpecOverridesOwnArgs112) < copyClassTdSpecParams1 (U |
| 26 | N0484 | 4 (4) | 4/0 | 2 | Earlgrey LogicTypespec | 0 | 0 | 13 | B | OPEN (map 14 ground-B step 4) | `name\|logic_typespec\|ours-empty\|under:ref_typespec` | W: makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeTypespec (TypeEmit.cpp, law tpFormalIncludeOrder1 |
| 27 | N0507 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 7 | B | OPEN (map 14 ground-A+B step 13) | `name\|bit_typespec\|tok:id::->\|under:ref_typespec` | W: bareScalarTdCopyOfFresh16 (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < bareScalarTdCopyOf (TypeEmit.cpp, law bo |
| 28 | N0030 | 4 (4) | 4/0 | 2 | Earlgrey Scr1 | 0 | 0 | 5 | B | OPEN (map 14 ground-A+B step 9) | `fullname\|ref_obj\|tok:id.->\|under:operation` | W: cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) < cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst |
| 29 | N0011 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 4 | B | OPEN (map 14 ground-A+B step 10) | `file\|logic_net\|golden-empty\|under:ref_obj` | W: thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cp |
| 30 | N0481 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 4 | B | OPEN (map 14 gave it to pair B r11u223; passes 223 and 225 l | `fullname\|ref_typespec\|tok:id->id\|under:int_var` | W: mintArrayElemVar193 (UhdmExporter.cpp, law cloneArrayRecvArgMintsElemVar193) < drainCloneArrayRecvArgMint193 ( |
| 31 | N0516 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 4 | B | OPEN (map 14 gave it to pair B r11u223; passes 223 and 225 l | `fullname\|int_var\|tok:id->id\|under:ref_obj` | W: mintArrayElemVar193 (UhdmExporter.cpp, law cloneArrayRecvArgMintsElemVar193) < drainCloneArrayRecvArgMint193 ( |
| 32 | N0414 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 3 | B | OPEN (map 14 ground-A+B step 13) | `struct\|golden-only:fewer-copies\|int_typespec\|under:ref_typespec` | M: namedElemPackedDimTs31 (TypeEmit.cpp, law boundLitWrittenDigits172) < makeTypeParamDefaultTs (TypeEmit.cpp, la |
| 33 | N0420 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 2 | B | OPEN (map 14 ground-A+B step 13) | `struct\|ours-only:elsewhere\|typespec_member\|under:struct_typespec` | M: buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law a7) < expo |
| 34 | N0784 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 2 | B | OPEN (map 14 ground-A+B step 13) | `fullname\|ref_typespec\|tok:id::id::id::id::id::id::->\|under:bit_typespec` | W: DeepCopy (?) < DeepCopy (?) < DeepCopy (?) |
| 35 | N0164 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 1 | B | OPEN (map 14 ground-A+B step 13) | `fullname\|ref_typespec\|tok:id::id::id::id::->\|under:bit_typespec` | W: operator() (UhdmExporter.cpp, law tfArgScalarTdWriter223) < operator() (UhdmExporter.cpp, law formalRegNoHeap2 |
| 36 | N0289 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 1 | B | OPEN (map 14 ground-A+B step 13) | `struct\|ours-only:fewer-copies\|string_var\|under:ref_obj` | M: emitTaskFuncs (TaskFuncEmit.cpp, law assocLocalArrayVar40) < emitPackage (ParamEmit.cpp, law LAW) < exportDesi |
| 37 | N0452 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 1 | B | OPEN (map 14 ground-A+B step 13) | `fullname\|ref_typespec\|tok:->::id\|under:bit_var` | W: makeQueueDynArrayVar (TaskFuncEmit.cpp, law declArrayElemKindIsDeclKind12) < emitStmt (StmtEmit.cpp, law block |
| 38 | N0505 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 1 | B | OPEN (map 14 ground-A+B step 13) | `struct\|ours-only:fewer-copies\|int_var\|under:ref_obj` | M: makeVar (TypeEmit.cpp, law pkgScopedPortAnyDirVar77) < emitPackageVar (ParamEmit.cpp, law caPkgCloneReadsTheEl |
| 39 | N0521 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 1 | B | OPEN (map 14 gave it to pair B r11u223; passes 223 and 225 l | `fullname\|ref_typespec\|tok:id->id\|under:class_var` | W: mintArrayElemVar193 (UhdmExporter.cpp, law cloneArrayRecvArgMintsElemVar193) < drainCloneArrayRecvArgMint193 ( |
| 40 | N0538 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 1 | B | OPEN (map 14 ground-A+B step 13) | `struct\|golden-only:fewer-copies\|bit_var\|under:array_var` | M: makeQueueDynArrayVar (TaskFuncEmit.cpp, law blockLocalTdDeclIsRefVarUnsupported155) < emitStmt (StmtEmit.cpp,  |

**Clusters that clear a row-mode ALONE on top of both pairs**: N0040 (2 row-modes; tests carrying it: Earlgrey_0_1 InterfaceModPort); N0056 (2 row-modes; tests carrying it: PreprocTest). **Clusters that head the most rows after the pairs**: N0492 (4) N0177 (2) N0525 (2) N0284 (2) N2464 (2) N0056 (2) N0422 (2) N0040 (2) N0141 (1) N0467 (1). **Ground-A OPEN clusters with a row after the pairs** (7): N0001 N0142 N0273 N0451 N0836 N1069 N1119 (the rest of ground A is credited to pair A: the UVM and Earlgrey A families, optimistic). **Probe-only OPEN clusters with the most cases**: N0738 (36, A) N1899 (30, B) N0094 (30, B) N0003 (24, A) N1905 (17, B) N1907 (15, B) N1909 (14, A) N1915 (14, ?) N1908 (14, B) N1906 (14, B) N0005 (13, A) N1916 (13, B) N1918 (13, A) N1914 (13, A). **Laws with the most STRICT_NOTEQUAL cases** (of their cases): tpPackedArrayTsVar108 28/73; nestedParamActualTs6 23/41; srlgUnvaluedActualLitRetFold8 23/98; defPkgMemberTdOfNamedShares108 22/42; caIfaceNdaNameFoldsToParamValue88 15/37; classTdCloneSpecOverridesOwnArgs112 14/22; pkgRhsStructBareCopy111 14/15; loopCaParamReadKeepsLiteral116 14/123; patParamEvalFuncRead26 14/17; pkgTdQualParamCopiesListing111 13/22; caStructParamGenScopeSubst69 11/15; tpElemRebindElabPort110 10/61. By ground the ranked table's grounds are [evidence/tables/t_groundA.md](evidence/tables/t_groundA.md) and [t_groundB.md](evidence/tables/t_groundB.md).

## 6. The yield of the live pairs, and the fail list after them

Routes: [evidence/routes.json](evidence/routes.json) (drivers/mkroutes15.py), ground overrides
[evidence/ground_override.json](evidence/ground_override.json).

* **Pair A r11u227** (brief: map 14's ground-A greedy list — the FuncStructVal, struct_param_func_config,
  cfg_func_width_loop and BlackBePipeInt A halves, N0131, the Earlgrey scope names, the N0039 decode —, pass 224's
  residues, the unsplit cross-ground switches, N0008 and map 13's case clusters, the UVM A families). Named heads
  (19): N0980 N1946 N1096 (FuncStructVal), N0675 N2412 (struct_param_func_config), N0025 N0033 N0754 N0794
  (cfg_func_width_loop), N0868 (BlackBePipeInt #15268/#15272), N0131, N0812, N0008, N0739 N1903 N1904 N0476 N0477,
  and N0039 (its writer is ground A, section 5). Row credits: the A halves of the four joint rows. Optimistic: every
  ground-A cluster whose rows are all UVM rows (or a credited row), every ground-A cluster whose rows are all
  Earlgrey_0_1 rows.
* **Pair B r11u228** (brief: map 14's ground-B greedy list — N0891; N0817 N0028 N0761 N0552 N0045; the kept call N0133
  N0487 and #464 (N0263); BlackBePipeInt N0073 N2471 N0014 N0905 N1179 —, N0120, the minted clone return variables,
  pass 225's residues, the UVM heads UVM_SEQ_ARB_TYPE (N0266) and this_type (N0337, N0072)). Named heads (18). Row
  credits: the B halves of the four joint rows. Optimistic: map 11's first-ten rule (the ground-B clusters of the
  UVM / Earlgrey rows' first ten differing records). The minted clone return variables hold no strict record (neither
  the walk nor uhdm-dump reaches them): no cluster.

```
 yields (row-modes / tests cleared in every NE mode / probe cases)
   pair A r11u227 optimistic (139 clusters): 5 / 2 / 137
   pair B r11u228 optimistic (16 clusters): 0 / 0 / 11
   both pairs optimistic: 8 row-modes / 4 tests / 154 probe
   surelog default: today 13; + pair A 11; + pair B 13; + both 11
   surelog testflags: today 11; + pair A 10; + pair B 11; + both 9
   uhdm2rtlil default: today 2; + pair A 1; + pair B 2; + both 0
   uhdm2rtlil testflags: today 2; + pair A 1; + pair B 2; + both 0
   FAIL LIST AFTER BOTH PAIRS: 20 row-modes / 11 tests (today 28 / 15); probe 480 (today 634; + A 497, + B 623)
   rows cleared: sur/d/BlackBePipeInt[A] sur/d/FuncStructVal[A] sur/t/BlackBePipeInt[A+B] sur/t/FuncStructVal[A] uhd/d/cfg_func_width_loop[A+B] uhd/d/struct_param_func_config[A] uhd/t/cfg_func_width_loop[A+B] uhd/t/struct_param_func_config[A]
   NAMED ONLY (the decoded heads the brief items name, no row / family / first-ten credit: A 19 + B 18 clusters): 4 row-modes / 2 tests / 83 probe; FAIL LIST AFTER NAMED: 24 row-modes / 13 tests, probe 551
   rows cleared (named): uhd/d/cfg_func_width_loop uhd/d/struct_param_func_config uhd/t/cfg_func_width_loop uhd/t/struct_param_func_config
   surelog default: named-only after 13
   surelog testflags: named-only after 11
   uhdm2rtlil default: named-only after 0
   uhdm2rtlil testflags: named-only after 0
```

## 7. Structural rows and the downstream-visible faces

**Structural rows** (first field depth / type): **4 row-modes**: BlackBePipeInt d `type(1)` #15272 and **t `type(1)`
#15268** (N0868, the same record in both modes since pass 224 cleared t's #66: golden leaves a tagged-pattern member
empty exactly when the override member is defaulted, 48 of 48; pass 224 R1, four hypotheses refuted; ground A
ParamEmit / ExprEmit; the mint pin is ExprEmit `emitExpr` < ParamEmit `emitParameters`, no field to watch), and
Scr1SvTests d/t `type(1)` (N0791: a golden-only ref_obj under a cont_assign, **a Surelog binding defect**, r11u200
3d: Surelog binds the include-guarded `$unit` enum constant `SCR1_MEM_CMD_RD` to an implicit net; no law without
inventing an object; 16 more clusters behind it). The probe set holds **50 `depth` and 74 `type` first fields**.
The laws they need: N0868 an ExprEval-shaped rule for the defaulted pattern member (r11u232's item 1); N0791 none.

**Downstream-visible faces** ([evidence/downstream/](evidence/downstream/), drivers/dsfaces.py: the gate's own
`one()`, a fresh golden cache, the HEAD binary): map 14's 90 non-IDENTICAL cases, r11u229's four EQUIVALENT ->
IDENTICAL cases and its other listed faces, r11u225's o05, o19, o21 (and o12), v11u224's ds01-ds03: **116 cases:
51 EQUIVALENT, 38 DIVERGENT, 11 IDENTICAL, 10 STATUS_DIFF, 3 SLANG_REJECT, 3 SURELOG_FAIL**.

| face | cases | verdict at `97343175` | map 14 |
|---|---|---|---|
| r11u173verify/hw | w12_index_member_blanks w13_index_member_noblank_ctl | **DIVERGENT** | DIVERGENT |
| r11u185verify/PU | u06_whole_copy_and_bits | **DIVERGENT** | DIVERGENT |
| r11u185verify/UD | u04_inst_array | **DIVERGENT** | DIVERGENT |
| r11u199verify/C | c06_nda_array_net | **DIVERGENT** | DIVERGENT |
| r11u199verify/X | x06_enum_port_cast | **DIVERGENT** | DIVERGENT |
| r11u204verify/V191 | rp2 | **DIVERGENT** | DIVERGENT |
| r11u204verify/X | x5 | **DIVERGENT** | DIVERGENT |
| r11u205dec/B3 | b05 b07 | **DIVERGENT** | DIVERGENT |
| r11u205dec/D5 | d01 d03 | **DIVERGENT** | DIVERGENT |
| r11u205dec/TP | t12 | **DIVERGENT** | DIVERGENT |
| r11u215repro/R | r07 | **DIVERGENT** | DIVERGENT |
| r11u216repro/NQ | n11 | **DIVERGENT** | DIVERGENT |
| r11u220repro/SL | s47 | **DIVERGENT** | DIVERGENT |
| r11u221verify/I | i02 i06 | **DIVERGENT** | DIVERGENT |
| r11u221verify/NP | p08 | **DIVERGENT** | DIVERGENT |
| r11u221verify/Q | q02 q11 | **DIVERGENT** | DIVERGENT |
| r11u221verify/X | x02 | **DIVERGENT** | DIVERGENT |
| v11u202repro/PP | p05 | **DIVERGENT** | DIVERGENT |
| v11u206repro/A | a12 | **DIVERGENT** | DIVERGENT |
| v11u219repro/E | e07_fnlocal_import | **DIVERGENT** | DIVERGENT |
| v11u219repro/S | s01c_assoc_inner s06_contassign_untouched s08_bit_packed2d | **DIVERGENT** | DIVERGENT |
| v11u220repro/K | k01 k06 k08 | **DIVERGENT** | DIVERGENT |
| v11u220repro/T | t19 | **DIVERGENT** | DIVERGENT |
| r11u158repro/sc | c10 c12 | EQUIVALENT | EQUIVALENT |
| r11u181repro/us | u02 u08 | EQUIVALENT | EQUIVALENT |
| r11u185verify/GV | v02_named_array_elem_mp v11_typed_then_generic_mpconn | EQUIVALENT | EQUIVALENT |
| r11u191dec/U | u08 u_p02 u_p07 | EQUIVALENT | EQUIVALENT |
| r11u194verify/X | x01_tp_enum_keyword | EQUIVALENT | EQUIVALENT |
| r11u199verify/T | t03_gen_loop | EQUIVALENT | EQUIVALENT |
| r11u199verify/X | x05_repl_fill_genloop | EQUIVALENT | EQUIVALENT |
| r11u200dec/K | k02 | EQUIVALENT | EQUIVALENT |
| r11u204verify/V191 | cc6 | EQUIVALENT | EQUIVALENT |
| r11u205dec/TP | t04 t06 t08 t09 t17 | EQUIVALENT | EQUIVALENT |
| r11u219repro/S | s03_struct_dimarg s04_shapes | EQUIVALENT | EQUIVALENT |
| r11u220repro/CI | c07 | EQUIVALENT | EQUIVALENT |
| r11u220repro/GX | g25 | EQUIVALENT | EQUIVALENT |
| r11u220repro/SL | s50 | **IDENTICAL** | EQUIVALENT |
| r11u221verify/I | i01 i05 | EQUIVALENT | EQUIVALENT |
| r11u221verify/Q | q05 q13 | EQUIVALENT | EQUIVALENT |
| v11u171repro/Q | c02_tail_op c08_inst_array c14_const_select | EQUIVALENT | EQUIVALENT |
| v11u212repro/G | g12 | EQUIVALENT | EQUIVALENT |
| v11u215repro/IP | p04_default_key | EQUIVALENT | EQUIVALENT |
| v11u215repro/OR | r08_iface_body | EQUIVALENT | EQUIVALENT |
| v11u215repro/TA | t16_alias_of_alias | EQUIVALENT | EQUIVALENT |
| v11u219repro/E | e15_param_copy_and_unitcls | EQUIVALENT | EQUIVALENT |
| v11u219repro/I | i03_iface_arr_elem | EQUIVALENT | EQUIVALENT |
| v11u219repro/M | m11_hier_actual_macro | EQUIVALENT | EQUIVALENT |
| v11u219repro/U | u02_two_pkgs_same_name | EQUIVALENT | EQUIVALENT |
| v11u220repro/K | k09 k17 | EQUIVALENT | EQUIVALENT |
| v11u220repro/K | k15 | **IDENTICAL** | EQUIVALENT |
| v11u220repro/T | t14 | **IDENTICAL** | EQUIVALENT |
| r11u205dec/FT | f03 | SLANG_REJECT | SLANG_REJECT |
| v11u216repro/F | f02 | SLANG_REJECT | SLANG_REJECT |
| v11u216repro/T | t11 | SLANG_REJECT | SLANG_REJECT |
| r11u185verify/GV | v07_typed_then_generic v08_modport_then_generic v09_chain_through_generic v15_typed_then_generic_multiline | **STATUS_DIFF** | STATUS_DIFF |
| r11u185verify/PG | p04_mod_control_same_ports | **STATUS_DIFF** | STATUS_DIFF |
| r11u190verify/US | u01 | **STATUS_DIFF** | STATUS_DIFF |
| v11u215repro/TC | c02_plain_enum_explicit_item | **STATUS_DIFF** | STATUS_DIFF |
| v11u220repro/G | g27 | **STATUS_DIFF** | STATUS_DIFF |
| v11u220repro/K | k13 | **STATUS_DIFF** | STATUS_DIFF |
| r11u220repro/SL | s37 | SURELOG_FAIL | SURELOG_FAIL |
| v11u219repro/S | s01_dyn_inner s01b_queue_inner | SURELOG_FAIL | SURELOG_FAIL |
| r11u229verify/K | k07 | IDENTICAL | - |
| r11u229verify/S | s07 s11 s17 | IDENTICAL | - |
| r11u229verify/S | s09 | EQUIVALENT | - |
| r11u229verify/A | a09 | EQUIVALENT | - |
| r11u229verify/B | b02 b04 | EQUIVALENT | - |
| r11u229verify/I | i07 | EQUIVALENT | - |
| r11u229verify/L | l10 | EQUIVALENT | - |
| r11u229verify/O | o01 o07 | EQUIVALENT | - |
| r11u229verify/A | a12 | **DIVERGENT** | - |
| r11u229verify/B | b01 b05 | **DIVERGENT** | - |
| r11u229verify/O | o02 | **DIVERGENT** | - |
| r11u229verify/X | x02 x04 | **DIVERGENT** | - |
| r11u229verify/A | a08 | **STATUS_DIFF** | - |
| r11u225repro/OS | o05 o19 o21 | EQUIVALENT | - |
| r11u225repro/OS | o12 | IDENTICAL | - |
| v11u224repro/DS | ds01 ds02 ds03 | IDENTICAL | - |

Changed against map 14 (same case, `551c9751` -> `97343175`): tools/probe/r11u220repro/cases/SL/s50 EQUIVALENT -> IDENTICAL, tools/probe/v11u220repro/cases/K/k15 EQUIVALENT -> IDENTICAL, tools/probe/v11u220repro/cases/T/t14 EQUIVALENT -> IDENTICAL (pass 224's string-literal laws; their spans reach the RTLIL src attributes).

The downstream gate itself reads 803 / 66 / 2 / 0 (section 2); the four uhdm2rtlil STRICT_NOTEQUAL rows' lanes
(cfg_func_width_loop d/t, struct_param_func_config d/t) are IDENTICAL, as is OutputSize's since pass 225.

## 8. Positive controls, determinism, rebuild identity ([evidence/controls/](evidence/controls/), [evidence/determinism/](evidence/determinism/), [evidence/rebuild/](evidence/rebuild/))

**Positive controls** (the HEAD sweep's databases, drivers/controls.sh): 1364_2005 d, HierPathInterfBlock d (surelog)
and 1DUnpackedArray d (uhdm2rtlil) read `STRICT_EQUAL` (159 / 226 / 194 objects) with **identical record dumps** (0
differing lines) and uhdm-cmp rc 0, 0 lines; **stamped_gen_param d/t stays stage-1 NOT_EQUAL** (strictcmp rc 1 at
stage 1: `rhsPath: design > module_inst > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`;
uhdm-cmp rc 255, 62 lines), the user-decided Surelog-defect row. A zero census elsewhere in this map is read beside its
reversed control (section 9).

**Determinism control** (drivers/det.sh: the HEAD binary run concurrently per row-mode with the HEAD sweep's command
line and cwd, three at a time; MiniAmiq and Scoreboard in four rounds):

| row-mode | draws | distinct hashes | equal to the HEAD sweep's | reading |
|---|---|---|---|---|
| **MiniAmiq d / t** | **12 / 12** | **1 / 1** (`7d6c076f`) | yes | **r11u226's cure (§ fullNameDrainIdOrder226v) holds** (map 14: 2 hashes per mode) |
| **Scoreboard d** | **12** | **1** (`dbb7fce6`, golden's svunit order) | yes | **r11u229's cure (§ unitImportFileOrder229v) holds** (map 14: 3 hashes) |
| Scoreboard t | - | - | - | SLANG_REJECT (skipped) |
| Earlgrey_0_1 d / t | 3 / 3 | 1 / 1 | yes | deterministic |
| SeqDriver d / t, SimpleUVM d / t, BuildUVMPkg d / t | 3 each | 1 each | yes | deterministic (r11u221's twin-order cure holds) |

With the pristine gate sweep (one more draw of every row, section 2) and the r11u229 state sweep (one draw of
Scoreboard d with the cure's switch set: golden's order this time), no row-mode shows a second hash. **No coin remains
to pin.**

**Rebuild identity.** Three builds of `97343175` from nothing (this worktree's `build`, a second build directory
`build-rb2`, and the main tree's integrator build that made the HEAD sweep) are byte-identical (`7e50408d`); the `-g1`
binary writes the same bytes as both on tools/probe/r11u196repro/cases/V191/qr01 and r11u209repro/cases/TW/qr01 (3 runs
each, one hash per binary, dumps identical) and on every writer-pin example (section 5).

## 9. The away-moved-record census of every landing since map 14 ([evidence/away/](evidence/away/))

Method (map 14's): the `97343175` binary under one landing's switches is swept (probe + both corpora, both modes: the
state sweeps) beside this map's pristine sweep; every database whose bytes differ is walked by `uhdm-strictcmp`
(canonical records) and by `strictcmp_x` (raw full names), each record keyed by its **ancestor chain** and **flat**
(depth dropped). **lost** = records golden and the landing-off state share that HEAD lacks; **toward** = the reverse.
The flat key is read position-aware: a flat-lost record is an *excess removal* when, at its own chain, HEAD removed
only copies above golden's count there. Measured at `97343175`, the census answers both "did the landing move a
record away from golden" and "does any such record survive at HEAD".

| landing (state) | switches | databases moved (probe + corpus) | **lost, chain-keyed** (canonical / raw) | lost, flat (unexplained) | toward, chain / flat (canonical; raw) | the landing's own census | survives at HEAD |
|---|---|---|---|---|---|---|---|
| pass 224 (s4) | `R11U224_OFF` | 17 (7 + 10) | **0 / 0** | 13 (**0**: all 13 excess removals in place) | 134 / 131; raw 134 / 131 | v11u224's corrected census (134 chain toward, 131 flat): **reproduced exactly** | 0 |
| pass 225 (s5) | `R11U225_OFF R11V225_OFF` | 4 (0 + 4) | **0 / 0** | 0 | 15 / 15; raw 17 / 17 | pass 225: 0 lost, 15 toward in both keys: **reproduced** | 0 |
| r11u226 (s6) | `R11V226_OFF` | 12 (3 + 9) | **0 / 0** | 0 | 0 / 0 | bytes only: **reproduced** (the dumps identical, a symbol-table order) | 0 |
| r11u229 (s9) | `R11V229_OFF` | 0 | **0 / 0** | 0 | 0 / 0 | bytes only (this draw of the coin fell on golden's order) | 0 |
| **positive control**: pass 224 reversed (HEAD as the off side) | | 17 | **134 / 134** | 131 (131) | 0 / 13 | | - |
| **positive control**: pass 225 reversed | | 4 | **15 / 17** | 15 (15) | 0 / 0 | | - |

**No landing since map 14 moved a strict record away from golden on any corpus row-mode or probe case, and none of
the records they moved toward golden has been lost since**: every state's chain-keyed lost count at `97343175` is 0 in
both record forms, and the reversed controls read every toward count as lost, so the census sees. Pass 224's 13
flat-key "losses" are excess removals at their own chains (ours held more copies there than golden). r11u226's and
r11u229's movers carry no record: the symbol-table order and the import order.

## 10. Prediction audit of map 14 ([evidence/audit.txt](evidence/audit.txt), drivers/audit15.py)

**Conversions since map 14** (read from the committed baselines at each landing commit; no landing left `CMP_EQUAL` or
added a `STRICT_NOTEQUAL` row): pass 223 0 row-modes / 5 cases, pass 224 0 / 5, **pass 225 InterfArrayBind d and
OutputSize...StructMember d/t (3 row-modes / 2 tests)**, r11u226 and r11u229 none: **3 row-modes / 2 tests, 10 probe
cases**.

**Map 14's predictions against them.** Its fail list was 31 row-modes / 17 tests at `551c9751` (and at `75a564b0`);
after both of its live pairs (r11u224 pair A, r11u223 pair B) it predicted **28 / 15 optimistic** (InterfArrayBind d,
cfg_func_width_loop d/t) and **30 / 16 named-only** (InterfArrayBind d). The fail list at `97343175` is **28 / 15**:
the same number, a different composition.

| row-mode | map 14's credit | what happened | by | map 14's first cluster, pin and ground | the landing law's files | verdict on the pin |
|---|---|---|---|---|---|---|
| InterfArrayBind d | pair B r11u223, NAMED (N0427, pass 219 residue 7) | **converted** | pass 225 (the pair-B refill AFTER r11u223; r11u223 itself took UVM_FILE and `$size`, section 13 of map 14) | N0427: `emitExpr (ExprEmit, law elabIfArrIdxChainName205) < emitContAssigns (ModuleEmit)`; override B (pass 220's decode) | ModuleEmit (§ ifArrElemLitCaFresh225) | **pin right (a caller)**, override right |
| OutputSize...StructMember d/t | not credited to the live pairs; **map 14's list B step 5** and its addendum's list for pair B's next refill | **converted** | pass 225 | N0191: `emitDroppedCall14 (StmtEmit) < emitBadConcatFromSyntax160 (ExprEmit) < emitExpr (ExprEmit)` (an r11u142map pin of another example); override B (pass 220's decode: TypeEmit `emitInitHier`) | ModuleEmit + TypeEmit + R225.h | **mint pin misses** (another example's chain); the override right; this map's writer pin at the pass-225-off state names ExprEmit `emitExpr` < TypeEmit `emitInitHier`: right as a caller (section 5) |
| cfg_func_width_loop d/t | pairs A+B, optimistic (N0025 N0033 N0794 N0754 A; the kept call B) | open (`line(3)`) | - | N0263 (B, pass 216's decode) | - | pass 228 re-decoded #464 as a ParamEmit re-pointing (A): the credit's ground was wrong again for its first record |

**Which predictions held**: 1 of the 3 credited row-modes (InterfArrayBind d, the NAMED one), not by the pair map 14
credited but by that ground's next refill; **the conversion it did not credit to the live pairs (OutputSize d/t) was
on its section-12 list B at step 5 and named in its addendum for pair B's next refill**, whose brief (r11u225) took
it. Map 14's lists together named all 31 row-modes; the 3 that converted were its NAMED pair credit (InterfArrayBind d)
and its list B step 5 (OutputSize d/t). **Map 14's live pairs converted no row-mode** (pass 224: 5 probe cases; pass 223: 5), and neither did this map's
(section 14): a live pair takes its first brief items (pass 224: string spans, UVM path names, BlackBePipeInt #66; pass 223:
UVM_FILE), and a row credited to it converts, when at all, in the next refill whose brief leads with it.

**What that says about the pins.** Of the two converted tests, the pin of N0427 names the landing's file as a caller
and the pin of N0191 misses; the decoded overrides were right on both. Pinning the WRITER does not fix that by
itself (section 5: the writer frame of both is ExprEmit `emitExpr`, the laws landed in its ground-B callers): the
field is last written by the generic expression emitter, and the landing chose the caller that decides WHICH object
or path is emitted. The map therefore routes by the decode first, and prints the writer's full chain so a brief can
see both grounds.

**Map 14's clusters**: of its 126 covered clusters, 6 gone, 1 row-cleared (N0097), 3 fell (N0123 9 -> 2, N0263 6 ->
2, N0427 3 -> 2), 116 unchanged; of the 177 on its section-12 lists, 7 gone (N0191, N1127, N0706 and the four
Scoreboard coin keys), 1 row-cleared (N0853), 1 fell (N0001), 168 unchanged.

## 11. The rows no exporter change can fix (for the user to rule on)

| row-mode(s) | strict cell | cluster(s) | why no exporter law converts it | evidence |
|---|---|---|---|---|
| InterfaceModPort d/t | `endcol(12)` | N0040 (writer: ModuleEmit `emitImportedPkgVarNets`, § importNetTsToInitEnd183) | the `.sl` carries Surelog's `-sverilog`, which forces every file to SystemVerilog; the harness drops the flag (`verify_golden.py` treats it as Surelog-only), so the exporter models Surelog's Verilog-mode lexer for the `.v` root (`logic` not a keyword, the net typespec stretched to the declarator). § svModeAllFiles188 (`--sverilog`) reads the row `STRICT_EQUAL 790 objects` in both modes by hand; the gate never passes it. **Needs a harness change** (translate `-sverilog` / a trailing `-sv` to `--sverilog`) | tools/probe/r11u188repro section 2.6 |
| PreprocTest d/t | `endcol(2)` | N0056 (writer: TypeEmit `buildEnumTs`, § bareScalarTdCopyOf) | Surelog lexes `bit` in a `.vh` file without `-sv` as an identifier, so golden's enum base typespec ends at the keyword; the harness never tells slang-uhdm Surelog's language mode for an included `.vh`. **Needs a harness / language-mode decision**, not an exporter law | tools/probe/r11u186repro residue R5 (pass 168's decode) |
| LogicTypespec d/t | `endline(3)` | N0083 N0422 N0484 N1149 | a Surelog-defect candidate: golden binds `my_package::t2 [1:0][7:0] x` straight to the package typedef and DROPS the written packed dimensions (downstream `$bits(x)` 2 on the Surelog lane, 32 on ours: l02 DIVERGENT); following golden would write a wrong width. **A user decision (map 13) keeps it** | tools/probe/r11u160repro (LT l01, l02) |
| Scr1SvTests d/t | `type(1)` + 16 clusters behind | N0791 | Surelog's per-file compilation units leave the include-guarded `$unit` enum constant `SCR1_MEM_CMD_RD` unresolved in scr1_pipe_ifu.sv and bind it to an IMPLICIT net (no file); slang resolves it. **Following golden means inventing an unresolved-name net** (golden writes nothing on a miss, and the map never invents one); the 16 clusters behind the structural record are measurable only past it | tools/probe/r11u200dec section 3d |
| stamped_gen_param d/t (uhdm2rtlil) | `CMP_NOTEQUAL` (stage 1) | - | **the proven Surelog-defect row** (user decision 2026-09-23): Surelog's ExprEval bit-selects the pre-folded pattern constant instead of element-selecting it, so golden elaborates `gen_grps[0].u.g[0..2]` as `inv` where the source requires `keep`; slang elaborates the real value; the test's own header names the defect (fixed upstream after the pin) | RESUME.md, the workable-corpus section |

Together: 8 STRICT_NOTEQUAL row-modes / 4 tests of the 28 / 15, plus the one CMP_NOTEQUAL row.

## 12. The family view, the UVM census, the order-blind distance

| family | row-modes / tests | clusters per row at 97343175 | open per row after both pairs | distinct clusters: 97343175 -> + pairs | cleared |
|---|---|---|---|---|---|
| UVM | 9 / 5 | 46-130 | 16-64 | 156 -> 73 | 0 |
| Earlgrey | 2 / 1 | 45-53 | 26-27 | 58 -> 31 | 0 |
| Rggen | 1 / 1 | 20-20 | 19-19 | 20 -> 19 | 0 |
| BlackBePipeInt | 2 / 1 | 20-24 | 0-0 | 25 -> 0 | 2 |
| Scr1 | 2 / 1 | 17-17 | 17-17 | 17 -> 17 | 0 |
| FuncStructVal | 2 / 1 | 5-6 | 0-0 | 6 -> 0 | 2 |
| struct_param_func_config | 2 / 1 | 7-7 | 0-0 | 7 -> 0 | 2 |
| cfg_func_width_loop | 2 / 1 | 7-7 | 0-0 | 7 -> 0 | 2 |
| the harness rows (InterfaceModPort, PreprocTest) | 4 / 2 | 1-1 | 1-1 | 2 -> 2 | 0 |
| LogicTypespec | 2 / 1 | 4-4 | 4-4 | 4 -> 4 | 0 |

**Single-cluster rows at `97343175`**: 4 row-modes / 2 tests: sur/d/InterfaceModPort N0040; sur/d/PreprocTest N0056; sur/t/InterfaceModPort N0040; sur/t/PreprocTest N0056

**Near rows** (one open cluster after both pairs): 4 row-modes / 2 tests: sur/d/InterfaceModPort N0040; sur/d/PreprocTest N0056; sur/t/InterfaceModPort N0040; sur/t/PreprocTest N0056

**Two open clusters**: 0 row-modes:

**The UVM family: r11u175's census by family key** (drivers/uvmcensus9.sh = r11u175's `uvmcensus.py` +
`uvmfamilies.py` over map 8's cluster keys, the five UVM rows' default databases, from this map's analyzer output;
[evidence/uvm/](evidence/uvm/)):

| family | map 13 `4acbe8a5` | map 14 `551c9751` | map 14 without its Scoreboard coin draw | **`97343175`** |
|---|---|---|---|---|
| F2 object multiplicity | 11,840 | 9,334 | 8,538 | **8,538** |
| F5 reference full names | 8,038 | 3,257 | 3,257 | **3,238** |
| F6 file facets | 2,165 | 1,754 | 1,754 | **1,368** |
| F4 formal / typespec / bound spans | 483 | 433 | 433 | **428** |
| F9 value / order / depth | 283 | 275 | 275 | **275** |
| F7 expression spans outside the pp model | 1,182 | 301 | 301 | **260** |
| F3 typedef relocation spans | 139 | 139 | 139 | **139** |
| F8 names | 95 | 95 | 95 | **95** |
| F1 preprocessor location model | 720 | 0 | 0 | **0** |
| **all** | **24,945 (251 clusters)** | **15,588 (168)** | **14,792** | **14,341 (155)** |

Pass 223 took F6 -386 (typedef int UVM_FILE's file facets) and F4 -5; pass 224 took F5 -19 and F7 -41 (the lvalue of
a class `new`, the `$bits(typedef)` argument, the dot after a `::` scope). The largest UVM families are still F2 (the
importer clones' copies) and F5; by today's ids: F2 N0182 1,924, N0024 780, N0478 762, N0420 717, N0495 576, N0408 481, N0496 468, N0538 440; F5 N0565 590, N0492 585, N0571 552 (evidence/uvm/families.txt, whose status column is map 8's).

**Order-blind uhdm-dump distance to golden** (drivers/uvmdist.sh: strict records with the depth dropped, as multisets;
`dist` = ours-not-in-golden records, `sym` = dist + golden-not-in-ours; [evidence/uvm/uvmdist_97343175.txt](evidence/uvm/uvmdist_97343175.txt)):

| row-mode | map 14 `551c9751` (dist / sym) | **`97343175` (dist / sym)** |
|---|---|---|
| MiniAmiq d / t | 2,461 / 7,965 | **1,761 / 6,565** |
| SeqDriver d / t | 2,122 / 6,349 | **1,304 / 4,713** |
| SimpleUVM d / t | 1,535 / 2,796 | **914 / 1,554** |
| Scoreboard d | 1,098 / 1,999 | **585 / 973** |
| BuildUVMPkg d / t | 648 / 1,241 | **230 / 405** |
| Earlgrey_0_1 d / t | 1,066 / 1,488; 798 / 1,310 | the same |
| Rggen d | 4,321 / 10,371 | the same |
| Scr1SvTests d / t | 117 / 195 | the same |
| BlackBePipeInt d / t | 16,886 / 31,517; 17,111 / 31,742 | 16,886 / 31,517; **16,900 / 31,544** (pass 224's #66) |
| FuncStructVal d / t | 30 / 348; 53 / 371 | the same |

(The UVM drop composes pass 223's typedef formals, measured by map 14 only at its own base, and pass 224's laws.)

## 13. The per-ground briefs (greedy, in the shape of map 14's section 12)

The lists ([evidence/greedy15.json](evidence/greedy15.json), [evidence/greedy15_named.json](evidence/greedy15_named.json),
[evidence/report.txt](evidence/report.txt)) take whole open sets of the rows left, greedily by rows gained per
cluster; the 'deep' lists take a row's whole open set whatever its size.

**Recommended next briefs, per ground** (read from the lists below, the joint-row walk order after them and the
addendum's re-routing at `9c9c11d6`; every cluster with its writer chain in cluster_index.csv):

* **Ground A** (ExprEmit / EmitHelpers / StmtEmit / ParamEmit; now r11u232, then its successor):
  1. **struct_param_func_config d/t** — every cluster is ground A by pass 228's decode: N0817 + N0028 + N0761 + N0552
     (the member ref_typespec names: TypeEmit `buildStructTs` sets them from the `memberScope` ParamEmit `makeParamTs`
     passes; the prefix `u_c.Cfg.` is ParamEmit's), N0045 (ParamEmit `stampEvalFuncLeftovers`), N0675 + N2412
     (`leftRefFix174`): 7 clusters, 2 row-modes.
  2. **FuncStructVal d/t** — N2472 + N2473 (the INSTR_PER_FETCH leftover #4782 golden locates at its read site 618:22,
     ParamEmit `makeMemLeftConst`), N0980, N1946, N0891 (the evaluator's member annotations, ParamEmit
     `stampEvalFuncLeftovers`): 5 clusters, 2 row-modes (named-only list A step 1 is N2472 + N2473 once the others
     are in).
  3. **BlackBePipeInt d** — on the default row every open cluster is ground A (the head N0868, ExprEval's defaulted
     pattern member; N0923 ParamEmit `stampParenCastWidthTs`; N1125 ParamEmit `makeParamTs`; N2471 / N0028 the
     memberScope names; the parameter spans in ParamEmit `emitParameters`): 20 clusters, 1 row-mode.
  4. **cfg_func_width_loop d/t, the A half** — N0263 (#464: re-point the elaborated param_assign Rhs's ref_typespec to
     the formal's clone, ParamEmit) and N0025 N0033 N0754 N0794; the row then waits for ground B's kept call.
  5. N0039 (10 rows' records, 40 cases; ParamEmit `predefIntTypespec` / ExprEmit `emitExpr`), N0131 (6 rows), the
     Earlgrey_0_1 scope names (N0812 family, 27 clusters on the two rows), the UVM A families.
* **Ground B** (TypeEmit / ModuleEmit / UhdmExporter / TaskFuncEmit / uhdm_main; now r11u231, then its successor):
  1. **cfg_func_width_loop d/t, the B half** — the kept call N0133 + N0487 (ModuleEmit `emitContAssigns`): with the A
     half, 2 row-modes (the addendum's list B step 3).
  2. **BlackBePipeInt t** — the `--elabuhdm` clone names written by uhdm_main `elabCloneFullNameUnstored137` (N0014
     N0905 N1179 N1446 N2476, and N0923 N1125 N2471 on the testflags row): with ground A's default-row laws, 1 more
     row-mode.
  3. **The UVM heads** — N0266 (UVM_SEQ_ARB_TYPE: UhdmExporter's formal-writer lambda, § tfArgOutsideClassOrder216),
     N0337 / N0072 (this_type: UhdmExporter `buildClassTypedefTs`), N0120 (TaskFuncEmit `emitTaskFuncs`); then deep
     list B: SimpleUVM d/t's 19 ground-B clusters, Scoreboard d's N0447 (the only cluster left on it once the UVM A
     families and first-ten credits are in, optimistic), BuildUVMPkg d/t's 5 (N0043 N0177 N0203 N0264 N0974).
  4. Not an exporter law: N0040 and N0056 (the harness), LogicTypespec's four (a user decision), Scr1SvTests' N0791
     (section 11).

### 13a. On top of both live pairs (optimistic)

greedy sets per ground on top of both pairs (optimistic); base cleared 8 row-modes / 4 tests
   rows left by open-cluster count (6 = 6+): {1: 4, 4: 2, 6: 14} ; by ground: {'B': 15, 'both': 5}
   every OPEN cluster of ground A (7) clears 0 row-modes (8 with the pairs)
   every OPEN cluster of ground B (127) clears 15 row-modes (23 with the pairs)
**list A: 0 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|

ground A: the 0 clusters above clear 0 row-modes on top of the pairs (8 with them)

**list B: 3 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 10 | 5 | InterfaceModPort/d InterfaceModPort/t | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef |
| 2 | N0056 | 2 | 12 | 6 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 3 | N0083 + N0422 + N0484 + N1149 | 2 | 14 | 7 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`;  ... | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |

ground B: the 6 clusters above clear 6 row-modes on top of the pairs (14 with them)

**list A+B: 3 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 10 | 5 | InterfaceModPort/d InterfaceModPort/t | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef |
| 2 | N0056 | 2 | 12 | 6 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 3 | N0083 + N0422 + N0484 + N1149 | 2 | 14 | 7 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`;  ... | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |

ground A+B: the 6 clusters above clear 6 row-modes on top of the pairs (14 with them)

**list deep A: 0 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|

ground deep A: the 0 clusters above clear 0 row-modes on top of the pairs (8 with them)

**list deep B: 8 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 10 | 5 | InterfaceModPort/d InterfaceModPort/t | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef |
| 2 | N0056 | 2 | 12 | 6 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 3 | N0083 + N0422 + N0484 + N1149 | 2 | 14 | 7 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`;  ... | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |
| 4 | N0011 + N0067 + N0068 + N0117 + N0158 + N0171 + N0180 + N0188 + N0213 + N0230 + N0232 + N0254 + N0255 + N0256 ... (+5) | 2 | 16 | 8 | SimpleUVM/d SimpleUVM/t | `file\|logic_net\|golden-empty\|under:ref_obj`; `file\|class_typespec\|ours-empty\|under:ref_typespec`; `span\|class_typ ... | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cpp, law hoistedThisRidesTheForwardedBlock |
| 5 | N0447 | 1 | 17 | 9 | Scoreboard/d | `file\|param_assign\|golden-empty\|under:class_typespec` | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing |
| 6 | N0043 + N0177 + N0203 + N0264 + N0974 | 2 | 19 | 10 | BuildUVMPkg/d BuildUVMPkg/t | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec`; `struct\|ours-only:absent\|bit_typespec\|under:ref ... | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWholeLhsBare160) < emitParameters (ParamEmit.cpp, |
| 7 | N0078 + N0164 + N0170 + N0182 + N0215 + N0289 + N0340 + N0341 + N0343 + N0414 + N0420 + N0426 + N0428 + N0449 ... (+34) | 4 | 23 | 12 | MiniAmiq/d SeqDriver/d MiniAmiq/t SeqDriver/t | `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation`; `fullname\|ref_typespec\|tok:id::id::id::id::->\|under:bit ... | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law elabMisevalRefSubst) < emitSyntaxExpr (TypeEmit.cpp, law |

ground deep B: the 79 clusters above clear 15 row-modes on top of the pairs (23 with them)

**list deep A+B: 12 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 10 | 5 | InterfaceModPort/d InterfaceModPort/t | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef |
| 2 | N0056 | 2 | 12 | 6 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 3 | N0083 + N0422 + N0484 + N1149 | 2 | 14 | 7 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`;  ... | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |
| 4 | N0021 + N0030 + N0078 + N0284 + N0416 + N0426 + N0427 + N0779 + N0791 + N0836 + N0921 + N1009 + N1069 + N1112 ... (+3) | 2 | 16 | 8 | Scr1SvTests/d Scr1SvTests/t | `fullname\|ref_obj\|tok:id.id.->\|under:operation`; `fullname\|ref_obj\|tok:id.->\|under:operation`; `fullname\|ref_obj\ ... | cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) < cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) < cloneUnitParamRhs (UhdmExporter.cpp, |
| 5 | N0011 + N0067 + N0068 + N0117 + N0158 + N0171 + N0180 + N0188 + N0213 + N0230 + N0232 + N0254 + N0255 + N0256 ... (+5) | 2 | 18 | 9 | SimpleUVM/d SimpleUVM/t | `file\|logic_net\|golden-empty\|under:ref_obj`; `file\|class_typespec\|ours-empty\|under:ref_typespec`; `span\|class_typ ... | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cpp, law hoistedThisRidesTheForwardedBlock |
| 6 | N0447 | 1 | 19 | 10 | Scoreboard/d | `file\|param_assign\|golden-empty\|under:class_typespec` | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing |
| 7 | N0043 + N0177 + N0203 + N0264 + N0974 | 2 | 21 | 11 | BuildUVMPkg/d BuildUVMPkg/t | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec`; `struct\|ours-only:absent\|bit_typespec\|under:ref ... | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWholeLhsBare160) < emitParameters (ParamEmit.cpp, |
| 8 | N0164 + N0170 + N0182 + N0215 + N0289 + N0340 + N0341 + N0343 + N0414 + N0420 + N0428 + N0449 + N0452 + N0478 ... (+32) | 4 | 25 | 13 | MiniAmiq/d SeqDriver/d MiniAmiq/t SeqDriver/t | `fullname\|ref_typespec\|tok:id::id::id::id::->\|under:bit_typespec`; `span\|class_var\|col+endcol\|under:function`; `st ... | operator() (TypeEmit.cpp, law pkgTdRangeViewFold18) < operator() (TypeEmit.cpp, law cloneStructMemberBareTdAlias207) < importCloneBareTdAlias16 (TypeE |
| 9 | N0001 + N0141 + N0142 + N0273 + N0448 + N0451 + N0683 + N0690 + N0696 + N0697 + N1172 + N1338 + N1339 + N1342 ... (+5) | 1 | 26 | 14 | Rggen/d | `span\|ref_obj\|col+endcol\|under:hier_path`; `file\|logic_typespec\|other-file+span\|under:ref_typespec`; `struct\|gold ... | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law hpTrailSelIdxNamesByPath133) < emitExpr (ExprEmit.cpp, law hpNam |
| 10 | N0061 + N0077 + N0090 + N0123 + N0525 + N0742 + N0834 + N0835 + N0846 + N0976 + N0981 + N1002 + N1054 + N1074 ... (+3) | 1 | 27 | 14 | Earlgrey_0_1/t | `span\|bit_select\|col+endcol\|under:hier_path`; `fullname\|ref_obj\|tok:id.id[id].->\|under:bit_select`; `span\|logic_t ... | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectErased4) < emitExpr (ExprEmit.cpp, law dynAr |
| 11 | N0454 + N0772 + N1181 + N1184 | 1 | 28 | 15 | Earlgrey_0_1/d | `fullname\|ref_typespec\|tok:id@id.id.id.id.->\|under:typespec_member`; `span\|cont_assign\|line+endline+endcol\|under:m ... | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters ( |

ground deep A+B: the 134 clusters above clear 20 row-modes on top of the pairs (28 with them)

### 13b. On top of the NAMED heads only

greedy sets per ground on top of the NAMED heads only; base cleared 4 row-modes / 2 tests
   rows left by open-cluster count (6 = 6+): {1: 4, 2: 2, 4: 2, 6: 16} ; by ground: {'both': 15, 'B': 6, 'A': 3}
   every OPEN cluster of ground A (118) clears 3 row-modes (7 with the pairs)
   every OPEN cluster of ground B (134) clears 6 row-modes (10 with the pairs)
**list A: 1 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N2472 + N2473 | 2 | 6 | 3 | FuncStructVal/d FuncStructVal/t | `file\|constant\|ours-empty\|under:typespec_member`; `span\|constant\|ours-zero\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitInstance |

ground A: the 2 clusters above clear 2 row-modes on top of the pairs (6 with them)

**list B: 3 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 6 | 3 | InterfaceModPort/d InterfaceModPort/t | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef |
| 2 | N0056 | 2 | 8 | 4 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 3 | N0083 + N0422 + N0484 + N1149 | 2 | 10 | 5 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`;  ... | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |

ground B: the 6 clusters above clear 6 row-modes on top of the pairs (10 with them)

**list A+B: 4 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 6 | 3 | InterfaceModPort/d InterfaceModPort/t | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef |
| 2 | N0056 | 2 | 8 | 4 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 3 | N2472 + N2473 | 2 | 10 | 5 | FuncStructVal/d FuncStructVal/t | `file\|constant\|ours-empty\|under:typespec_member`; `span\|constant\|ours-zero\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitInstance |
| 4 | N0083 + N0422 + N0484 + N1149 | 2 | 12 | 6 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`;  ... | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |

ground A+B: the 8 clusters above clear 8 row-modes on top of the pairs (12 with them)

**list deep A: 2 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N2472 + N2473 | 2 | 6 | 3 | FuncStructVal/d FuncStructVal/t | `file\|constant\|ours-empty\|under:typespec_member`; `span\|constant\|ours-zero\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitInstance |
| 2 | N0063 + N0118 + N0286 + N0413 + N0800 + N0873 + N0893 + N0907 + N0908 + N0917 + N0923 + N0936 + N0951 + N0964 ... (+2) | 1 | 7 | 3 | BlackBePipeInt/d | `fullname\|ref_typespec\|ours-empty\|under:operation`; `span\|constant\|line+col+endline+endcol\|under:operation`; `stru ... | operator() (ParamEmit.cpp, law pkgPatReadTsBindsTopTypedef192) < operator() (ParamEmit.cpp, law pkgPatReadTsBindsTopTypedef192) < drainShareDefParamTs |

ground deep A: the 18 clusters above clear 3 row-modes on top of the pairs (7 with them)

**list deep B: 3 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 6 | 3 | InterfaceModPort/d InterfaceModPort/t | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef |
| 2 | N0056 | 2 | 8 | 4 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 3 | N0083 + N0422 + N0484 + N1149 | 2 | 10 | 5 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`;  ... | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |

ground deep B: the 6 clusters above clear 6 row-modes on top of the pairs (10 with them)

**list deep A+B: 15 candidate sets**
| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 6 | 3 | InterfaceModPort/d InterfaceModPort/t | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef |
| 2 | N0056 | 2 | 8 | 4 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 3 | N2472 + N2473 | 2 | 10 | 5 | FuncStructVal/d FuncStructVal/t | `file\|constant\|ours-empty\|under:typespec_member`; `span\|constant\|ours-zero\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitInstance |
| 4 | N0083 + N0422 + N0484 + N1149 | 2 | 12 | 6 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`;  ... | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |
| 5 | N0021 + N0030 + N0078 + N0284 + N0416 + N0426 + N0427 + N0779 + N0791 + N0836 + N0921 + N1009 + N1069 + N1112 ... (+3) | 2 | 14 | 7 | Scr1SvTests/d Scr1SvTests/t | `fullname\|ref_obj\|tok:id.id.->\|under:operation`; `fullname\|ref_obj\|tok:id.->\|under:operation`; `fullname\|ref_obj\ ... | cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) < cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) < cloneUnitParamRhs (UhdmExporter.cpp, |
| 6 | N0063 + N0118 + N0286 + N0413 + N0800 + N0873 + N0893 + N0907 + N0908 + N0917 + N0923 + N0936 + N0951 + N0964 ... (+2) | 1 | 15 | 7 | BlackBePipeInt/d | `fullname\|ref_typespec\|ours-empty\|under:operation`; `span\|constant\|line+col+endline+endcol\|under:operation`; `stru ... | operator() (ParamEmit.cpp, law pkgPatReadTsBindsTopTypedef192) < operator() (ParamEmit.cpp, law pkgPatReadTsBindsTopTypedef192) < drainShareDefParamTs |
| 7 | N1446 + N2476 | 1 | 16 | 8 | BlackBePipeInt/t | `fullname\|ref_typespec\|tok:id@id.->id::\|under:parameter`; `fullname\|parameter\|tok:id@id.->id::@in-typespec\|under:r ... | emitParameters (ParamEmit.cpp, law modDefImportShape) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.c |
| 8 | N0001 + N0141 + N0142 + N0273 + N0448 + N0451 + N0683 + N0690 + N0696 + N0697 + N1172 + N1338 + N1339 + N1342 ... (+5) | 1 | 17 | 9 | Rggen/d | `span\|ref_obj\|col+endcol\|under:hier_path`; `file\|logic_typespec\|other-file+span\|under:ref_typespec`; `struct\|gold ... | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law hpTrailSelIdxNamesByPath133) < emitExpr (ExprEmit.cpp, law hpNam |
| 9 | N0012 + N0034 + N0043 + N0051 + N0067 + N0068 + N0075 + N0109 + N0110 + N0117 + N0158 + N0161 + N0171 + N0177 ... (+26) | 2 | 19 | 10 | BuildUVMPkg/d BuildUVMPkg/t | `file\|enum_typespec\|ours-empty\|under:ref_typespec`; `span\|enum_typespec\|ours-zero\|under:ref_typespec`; `span\|stru ... | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classVarInitSpan152) < makeTypespec (TypeEmit.cpp, law tpForma |
| 10 | N0011 + N0050 + N0098 + N0121 + N0144 + N0219 + N0262 + N0303 + N0304 + N0305 + N0306 + N0321 + N0325 + N0374 ... (+15) | 2 | 21 | 11 | SimpleUVM/d SimpleUVM/t | `file\|logic_net\|golden-empty\|under:ref_obj`; `span\|operation\|col+endcol\|under:assignment`; `file\|ref_obj\|ours-em ... | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cpp, law hoistedThisRidesTheForwardedBlock |
| 11 | N0447 | 1 | 22 | 12 | Scoreboard/d | `file\|param_assign\|golden-empty\|under:class_typespec` | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing |
| 12 | N0024 + N0134 + N0164 + N0182 + N0192 + N0215 + N0289 + N0340 + N0341 + N0343 + N0414 + N0420 + N0428 + N0449 ... (+50) | 2 | 24 | 13 | SeqDriver/d SeqDriver/t | `struct\|golden-only:fewer-copies\|struct_typespec\|under:ref_typespec`; `struct\|golden-only:fewer-copies\|array_typesp ... | emitInterfaceInstance (ModuleEmit.cpp, law defNetEndOnlyLoc130) < emitInstance (ModuleEmit.cpp, law caNestedModDeclNoRefNoInst99) < exportDesign (Uhdm |
| 13 | N0054 + N0170 + N0370 + N0384 + N0424 + N0703 + N0989 + N1131 + N1154 + N1158 + N2469 | 2 | 26 | 14 | MiniAmiq/d MiniAmiq/t | `span\|assignment\|endcol\|under:begin`; `span\|class_var\|col+endcol\|under:function`; `span\|sys_func_call\|endcol\|un ... | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) < emitStmt (StmtEmit.cpp, law  |
| 14 | N0061 + N0077 + N0085 + N0090 + N0123 + N0129 + N0415 + N0417 + N0446 + N0474 + N0525 + N0687 + N0727 + N0742 ... (+18) | 1 | 27 | 14 | Earlgrey_0_1/t | `span\|bit_select\|col+endcol\|under:hier_path`; `fullname\|ref_obj\|tok:id.id[id].->\|under:bit_select`; `struct\|ours- ... | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectErased4) < emitExpr (ExprEmit.cpp, law dynAr |
| 15 | N0454 + N0545 + N0546 + N0772 + N1173 + N1181 + N1184 + N1194 + N1302 + N1381 + N1529 + N1539 + N1753 | 1 | 28 | 15 | Earlgrey_0_1/d | `fullname\|ref_typespec\|tok:id@id.id.id.id.->\|under:typespec_member`; `file\|enum_const\|ours-empty\|under:ref_obj`; ` ... | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters ( |

ground deep A+B: the 252 clusters above clear 24 row-modes on top of the pairs (28 with them)

**The joint rows in walk order** ([evidence/rowsets.txt](evidence/rowsets.txt), drivers/rowsets.py: every cluster of
the row with its earliest record, ground and writer; the next refill of each ground can read exactly which records
stand in front of its own):

```
== surelog/default/BlackBePipeInt differ:type(1): 20 clusters, ground A 20, B 0
   #15272   N0868 A (writer chain -) constant '' struct:ours-only g= o=1 objs | -
   #15558   N0964 A (writer chain A) constant '' span:col+endcol g=2992:26:2992:46 o=2992:27:2992:45 | [setLoc] emitExpr (ExprEmit.cpp, law r10fsv2) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage
   #16864   N0917 A (writer chain -) constant '' struct:ours-only g= o=1 objs | -
   #38807   N0951 A (writer chain -) parameter 'dev_addr_width_gp' struct:golden-only g=3 objs o= | -
   #39482   N2471 A (writer chain A+B) ref_typespec '' fullname:fullname g=bp_be_pkg::bp_common_pkg::bp_proc_param_s::cc_x_di o=bp_be_pkg::bp_default_cfg_p::bp_common_pkg::bp_pro | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgPara
   #44904   N0118 A (writer chain A+B) constant '' span:line+col+endline+endcol g=2047:16:2047:17 o=3807:14:3809:54 | [setLoc] emitParameters (ParamEmit.cpp, law redBasedLeafWrittenDigits76) < emitPackage (ParamEmit.cpp, law caP
   #47753   N0873 A (writer chain A) constant '' span:line+col+endline+endcol g=2047:16:2047:17 o=3807:14:3809:54 | emitExpr (ExprEmit.cpp, law r10fsv2) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmi
   #125760  N2470 A (writer chain -) parameter 'dev_addr_width_gp' struct:ours-only g= o=4 objs | -
   #174101  N0923 A (writer chain A+B) ref_obj 'dev_addr_width_gp' fullname:fullname g= o=work@bp_be_pipe_int.dev_addr_width_gp.dev_addr_wid | stampParenCastWidthTs (ParamEmit.cpp, law parenCastWidthRefPkgBare207) < emitParameters (ParamEmit.cpp, law tf
   #176093  N0286 A (writer chain -) ref_obj 'dev_addr_width_gp' struct:ours-only g= o=1 objs | -
   #188925  N0028 A (writer chain A+B) ref_typespec '' fullname:fullname g=work@bp_be_pipe_int.bp_common_pkg::bp_proc_param_s o=work@bp_be_pipe_int.proc_param_lp.bp_common_pkg::b | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgPara
   #190646  N0907 A (writer chain A) constant '' file:file g=dut.sv 2537:40:2537:89 o= 0:0:0:0 | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTarget
   #190646  N0908 A (writer chain A) constant '' span:line+col+endline+endcol g=2537:40:2537:89 o=0:0:0:0 | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTarget
   #190751  N0413 A (writer chain A+B) operation '' span:line+col+endline+endcol g=2565:47:2565:63 o=2047:2:2142:5 | [setLoc] emitParameters (ParamEmit.cpp, law elabUnpStructOperandWidth61) < exportDesign (UhdmExporter.cpp, law
   #208349  N0893 A (writer chain A+B) constant '' span:line+endline+endcol g=8858:15:8858:16 o=8890:15:8892:70 | [setLoc] emitParameters (ParamEmit.cpp, law elabImportedStructOperandFold) < exportDesign (UhdmExporter.cpp, l
   #293887  N0073 A (writer chain A+B) constant '' span:endcol g=15483:12:15483:34 o=15483:12:15483:57 | emitParameters (ParamEmit.cpp, law elabLazyTernaryArithFold) < emitInstance (ModuleEmit.cpp, law elabParamTsRe
   #294152  N0063 A (writer chain A) ref_typespec '' fullname:fullname g=work@bp_be_pipe_int o= | operator() (ParamEmit.cpp, law pkgPatReadTsBindsTopTypedef192) < __invoke_impl (invoke.h) < __invoke_r (invoke
   #294400  N0936 A (writer chain A+B) constant '' span:endline+endcol g=2077:28:2081:58 o=2077:28:2082:63 | [setLoc] emitParameters (ParamEmit.cpp, law elabImportedStructOperandFold) < emitInstance (ModuleEmit.cpp, law
   #312613  N1125 A (writer chain A+B) ref_typespec '' fullname:fullname g=work@bp_be_pipe_int o=work@bp_be_pipe_int.all_cfgs_gp | makeParamTs (ParamEmit.cpp, law pkgParamOwnDefRange) < patchParamTypespecs (ParamEmit.cpp, law paramCloneImpor
   #333793  N0800 A (writer chain -) operation '' struct:ours-only g= o=257 objs | -
== surelog/testflags/BlackBePipeInt differ:type(1): 24 clusters, ground A 19, B 5
   #15268   N0868 A (writer chain -) constant '' struct:ours-only g= o=1 objs | -
   #15554   N0964 A (writer chain A) constant '' span:col+endcol g=2992:26:2992:46 o=2992:27:2992:45 | [setLoc] emitExpr (ExprEmit.cpp, law r10fsv2) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage
   #16860   N0917 A (writer chain -) constant '' struct:ours-only g= o=1 objs | -
   #24667   N0905 B (writer chain B) ref_typespec '' fullname:fullname g=bp_be_pkg::all_cfgs_gp::bp_common_pkg::bp_proc_par o=work@bp_be_pipe_int.bp_common_pkg::bp_proc_param_s | elabCloneFullNameUnstored137 (uhdm_main.cpp, law elabCloneInstTreeUnstored144) < realMain (uhdm_main.cpp, law
   #38803   N2476 B (writer chain B) parameter 'dev_addr_width_gp' fullname:fullname g=work@bp_be_pipe_int.dev_addr_width_gp o=bp_common_pkg::dev_addr_width_gp | elabCloneFullNameUnstored137 (uhdm_main.cpp, law elabCloneInstTreeUnstored144) < realMain (uhdm_main.cpp, law
   #38804   N1446 B (writer chain B) ref_typespec '' fullname:fullname g=work@bp_be_pipe_int.dev_addr_width_gp o=bp_common_pkg::dev_addr_width_gp | elabCloneFullNameUnstored137 (uhdm_main.cpp, law elabCloneInstTreeUnstored144) < realMain (uhdm_main.cpp, law
   #39463   N2471 A (writer chain A+B) ref_typespec '' fullname:fullname g=bp_be_pkg::bp_common_pkg::bp_proc_param_s::cc_x_di o=bp_be_pkg::bp_default_cfg_p::bp_common_pkg::bp_pro | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgPara
   #40791   N0286 A (writer chain -) ref_obj 'dev_addr_width_gp' struct:ours-only g= o=5 objs | -
   #44885   N0118 A (writer chain A+B) constant '' span:line+col+endline+endcol g=2047:16:2047:17 o=3807:14:3809:54 | [setLoc] emitParameters (ParamEmit.cpp, law redBasedLeafWrittenDigits76) < emitPackage (ParamEmit.cpp, law caP
   #47734   N0873 A (writer chain A) constant '' span:line+col+endline+endcol g=2047:16:2047:17 o=3807:14:3809:54 | emitExpr (ExprEmit.cpp, law r10fsv2) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmi
   #90174   N1179 B (writer chain B) ref_typespec '' fullname:fullname g=bp_common_pkg::bp_common_pkg::bp_proc_param_s::cc_ o=work@bp_be_pipe_int.bp_common_pkg::bp_proc_param_s | elabCloneFullNameUnstored137 (uhdm_main.cpp, law elabCloneInstTreeUnstored144) < realMain (uhdm_main.cpp, law
   #123765  N0951 A (writer chain -) parameter 'dev_addr_width_gp' struct:golden-only g=3 objs o= | -
   #159873  N0014 B (writer chain B) ref_typespec '' fullname:fullname g=work@bp_be_pipe_int.all_cfgs_gp.bp_common_pkg::bp_ o=work@bp_be_pipe_int.bp_common_pkg::bp_proc_param_s | elabCloneFullNameUnstored137 (uhdm_main.cpp, law elabCloneInstTreeUnstored144) < realMain (uhdm_main.cpp, law
   #174008  N0923 A (writer chain A+B) ref_obj 'dev_addr_width_gp' fullname:fullname g= o=work@bp_be_pipe_int.dev_addr_width_gp.dev_addr_wid | stampParenCastWidthTs (ParamEmit.cpp, law parenCastWidthRefPkgBare207) < emitParameters (ParamEmit.cpp, law tf
   #188832  N0028 A (writer chain A+B) ref_typespec '' fullname:fullname g=work@bp_be_pipe_int.bp_common_pkg::bp_proc_param_s o=work@bp_be_pipe_int.proc_param_lp.bp_common_pkg::b | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgPara
   #190553  N0907 A (writer chain A) constant '' file:file g=dut.sv 2537:40:2537:89 o= 0:0:0:0 | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTarget
   #190553  N0908 A (writer chain A) constant '' span:line+col+endline+endcol g=2537:40:2537:89 o=0:0:0:0 | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTarget
   #190658  N0413 A (writer chain A+B) operation '' span:line+col+endline+endcol g=2565:47:2565:63 o=2047:2:2142:5 | [setLoc] emitParameters (ParamEmit.cpp, law elabUnpStructOperandWidth61) < exportDesign (UhdmExporter.cpp, law
   #208256  N0893 A (writer chain A+B) constant '' span:line+endline+endcol g=8858:15:8858:16 o=8890:15:8892:70 | [setLoc] emitParameters (ParamEmit.cpp, law elabImportedStructOperandFold) < exportDesign (UhdmExporter.cpp, l
   #293790  N0073 A (writer chain A+B) constant '' span:endcol g=15483:12:15483:34 o=15483:12:15483:57 | emitParameters (ParamEmit.cpp, law elabLazyTernaryArithFold) < emitInstance (ModuleEmit.cpp, law elabParamTsRe
   #294052  N0063 A (writer chain A) ref_typespec '' fullname:fullname g=work@bp_be_pipe_int o= | operator() (ParamEmit.cpp, law pkgPatReadTsBindsTopTypedef192) < __invoke_impl (invoke.h) < __invoke_r (invoke
   #294300  N0936 A (writer chain A+B) constant '' span:endline+endcol g=2077:28:2081:58 o=2077:28:2082:63 | [setLoc] emitParameters (ParamEmit.cpp, law elabImportedStructOperandFold) < emitInstance (ModuleEmit.cpp, law
   #312513  N1125 A (writer chain A+B) ref_typespec '' fullname:fullname g=work@bp_be_pipe_int o=work@bp_be_pipe_int.all_cfgs_gp | makeParamTs (ParamEmit.cpp, law pkgParamOwnDefRange) < patchParamTypespecs (ParamEmit.cpp, law paramCloneImpor
   #333691  N0800 A (writer chain -) operation '' struct:ours-only g= o=257 objs | -
== surelog/default/FuncStructVal differ:endcol(7): 5 clusters, ground A 5, B 0
   #747     N1096 A (writer chain A) ref_obj 'config_pkg::NOC_TYPE_AXI4_ATOP' span:endcol g=106:16:106:28 o=106:16:106:46 | [setLoc] emitExpr (ExprEmit.cpp, law r10fsv3) < emitExpr (ExprEmit.cpp, law r10fsv2) < emitParameters (ParamEm
   #4782    N2472 A (writer chain A+B) constant '' file:file g=dut.sv 618:22:618:45 o= 0:0:0:0 | stampEvalFuncLeftovers (ParamEmit.cpp, law memLeftReadsPatUnlocated210) < exportDesign (UhdmExporter.cpp, law
   #4782    N2473 A (writer chain A+B) constant '' span:line+col+endline+endcol g=618:22:618:45 o=0:0:0:0 | stampEvalFuncLeftovers (ParamEmit.cpp, law memLeftReadsPatUnlocated210) < exportDesign (UhdmExporter.cpp, law
   #7975    N0891 A (writer chain -) operation '' struct:golden-only g=4 objs o= | -
   #17114   N0980 A (writer chain A) ref_typespec '' fullname:fullname g=work@top.CVA6Cfg.config_pkg::cva6_cfg_t.NonIdempot o=cva6_config_pkg | emitExpr (ExprEmit.cpp, law packageVarAutomaticIsDataDeclShape26) < emitExpr (ExprEmit.cpp, law ndaCallFoldIsE
== surelog/testflags/FuncStructVal differ:endcol(10): 6 clusters, ground A 6, B 0
   #746     N1096 A (writer chain A) ref_obj 'config_pkg::NOC_TYPE_AXI4_ATOP' span:endcol g=106:16:106:28 o=106:16:106:46 | [setLoc] emitExpr (ExprEmit.cpp, law r10fsv3) < emitExpr (ExprEmit.cpp, law r10fsv2) < emitParameters (ParamEm
   #7129    N2472 A (writer chain A+B) constant '' file:file g=dut.sv 618:22:618:45 o= 0:0:0:0 | stampEvalFuncLeftovers (ParamEmit.cpp, law memLeftReadsPatUnlocated210) < exportDesign (UhdmExporter.cpp, law
   #7129    N2473 A (writer chain A+B) constant '' span:line+col+endline+endcol g=618:22:618:45 o=0:0:0:0 | stampEvalFuncLeftovers (ParamEmit.cpp, law memLeftReadsPatUnlocated210) < exportDesign (UhdmExporter.cpp, law
   #13254   N1946 A (writer chain -) constant '' struct:ours-only g= o=3 objs | -
   #14765   N0891 A (writer chain -) operation '' struct:golden-only g=4 objs o= | -
   #43313   N0980 A (writer chain A) ref_typespec '' fullname:fullname g=work@top.CVA6Cfg.config_pkg::cva6_cfg_t.NonIdempot o=cva6_config_pkg | emitExpr (ExprEmit.cpp, law packageVarAutomaticIsDataDeclShape26) < emitExpr (ExprEmit.cpp, law ndaCallFoldIsE
== uhdm2rtlil/default/cfg_func_width_loop differ:line(3): 7 clusters, ground A 5, B 2
   #464     N0263 A (writer chain A+B) logic_typespec 'mask_t' span:line+col+endline+endcol g=27:40:27:46 o=16:11:16:25 | [setLoc] makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeParamTs (ParamEmit.cpp, law pkgParamOwnD
   #465     N0794 A (writer chain A+B) ref_typespec '' fullname:fullname g=mask_t o=work@sub.M.mask_t | makeParamTs (ParamEmit.cpp, law pkgImpParamAliasColons210) < drainDefParamTs (ParamEmit.cpp, law pkgImpParamMe
   #472     N0025 A (writer chain B) constant '' depth:depth g=8 range < logic_typespec(mask_t) o=9 operation < range | emitSyntaxExpr (TypeEmit.cpp, law bigDecUnderscoreDropped181v) < emitSyntaxExpr (TypeEmit.cpp, law rootNetPath
   #472     N0033 A (writer chain -) operation '' struct:ours-only g= o=2 objs | -
   #516     N0133 B (writer chain -) func_call 'q::maxw' struct:golden-only g=2 objs o= | -
   #518     N0487 B (writer chain -) constant '' struct:ours-only g= o=1 objs | -
   #518     N0754 A (writer chain A+B) ref_obj 'o' fullname:fullname g=work@sub.o o=work@cfg_func_width_loop.u.o | emitExpr (ExprEmit.cpp, law genProcFoldDeclTsScopeNamed167) < emitContAssigns (ModuleEmit.cpp, law caLhsDefNet
== uhdm2rtlil/default/struct_param_func_config differ:fullname(5): 7 clusters, ground A 7, B 0
   #759     N0817 A (writer chain A+B) ref_typespec '' fullname:fullname g=work@struct_param_func_config.p::cfg_t.u o=work@struct_param_func_config.u_c.Cfg.p::cfg_t.u | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgPara
   #1364    N0045 A (writer chain -) constant '' struct:golden-only g=1 objs o= | -
   #1439    N0028 A (writer chain A+B) ref_typespec '' fullname:fullname g=work@struct_param_func_config.p::cfg_t.u o=work@struct_param_func_config.Cfg.p::cfg_t.u | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgPara
   #1920    N0761 A (writer chain A) ref_typespec '' fullname:fullname g=p::cfg_t.u o=work@struct_param_func_config.Cfg.p::cfg_t.u | leftRefFix174 (ParamEmit.cpp, law evalFuncBodyRhsStampClone167) < leftRefWalk174 (ParamEmit.cpp, law evalFuncB
   #1938    N2412 A (writer chain A) ref_typespec '' fullname:fullname g=p::cfg_t.u o=work@struct_param_func_config.Cfg.p::cfg_t.u | leftRefFix174 (ParamEmit.cpp, law evalFuncBodyRhsStampClone167) < leftRefWalk174 (ParamEmit.cpp, law evalFuncB
   #2538    N0552 A (writer chain A+B) ref_typespec '' fullname:fullname g=work@child.U.p::ucfg_t.a o=work@struct_param_func_config.u_c.U.p::ucfg_t.a | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgPara
   #2575    N0675 A (writer chain A) ref_typespec '' fullname:fullname g=work@child.C.p::cfg_t.u o=work@struct_param_func_config.u_c.C.p::cfg_t.u | leftRefFix174 (ParamEmit.cpp, law evalFuncBodyRhsStampClone167) < leftRefWalk174 (ParamEmit.cpp, law evalFuncB
== uhdm2rtlil/testflags/cfg_func_width_loop differ:line(3): 7 clusters, ground A 5, B 2
   #374     N0263 A (writer chain A+B) logic_typespec 'mask_t' span:line+col+endline+endcol g=27:40:27:46 o=16:11:16:25 | [setLoc] makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeParamTs (ParamEmit.cpp, law pkgParamOwnD
   #375     N0794 A (writer chain A+B) ref_typespec '' fullname:fullname g=mask_t o=work@sub.M.mask_t | makeParamTs (ParamEmit.cpp, law pkgImpParamAliasColons210) < drainDefParamTs (ParamEmit.cpp, law pkgImpParamMe
   #382     N0025 A (writer chain B) constant '' depth:depth g=8 range < logic_typespec(mask_t) o=9 operation < range | emitSyntaxExpr (TypeEmit.cpp, law bigDecUnderscoreDropped181v) < emitSyntaxExpr (TypeEmit.cpp, law rootNetPath
   #382     N0033 A (writer chain -) operation '' struct:ours-only g= o=2 objs | -
   #426     N0133 B (writer chain -) func_call 'q::maxw' struct:golden-only g=2 objs o= | -
   #428     N0487 B (writer chain -) constant '' struct:ours-only g= o=1 objs | -
   #428     N0754 A (writer chain A+B) ref_obj 'o' fullname:fullname g=work@sub.o o=work@cfg_func_width_loop.u.o | emitExpr (ExprEmit.cpp, law genProcFoldDeclTsScopeNamed167) < emitContAssigns (ModuleEmit.cpp, law caLhsDefNet
== uhdm2rtlil/testflags/struct_param_func_config differ:fullname(5): 7 clusters, ground A 7, B 0
   #669     N0817 A (writer chain A+B) ref_typespec '' fullname:fullname g=work@struct_param_func_config.p::cfg_t.u o=work@struct_param_func_config.u_c.Cfg.p::cfg_t.u | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgPara
   #1274    N0045 A (writer chain -) constant '' struct:golden-only g=1 objs o= | -
   #1349    N0028 A (writer chain A+B) ref_typespec '' fullname:fullname g=work@struct_param_func_config.p::cfg_t.u o=work@struct_param_func_config.Cfg.p::cfg_t.u | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgPara
   #1830    N0761 A (writer chain A) ref_typespec '' fullname:fullname g=p::cfg_t.u o=work@struct_param_func_config.Cfg.p::cfg_t.u | leftRefFix174 (ParamEmit.cpp, law evalFuncBodyRhsStampClone167) < leftRefWalk174 (ParamEmit.cpp, law evalFuncB
   #1848    N2412 A (writer chain A) ref_typespec '' fullname:fullname g=p::cfg_t.u o=work@struct_param_func_config.Cfg.p::cfg_t.u | leftRefFix174 (ParamEmit.cpp, law evalFuncBodyRhsStampClone167) < leftRefWalk174 (ParamEmit.cpp, law evalFuncB
   #2448    N0552 A (writer chain A+B) ref_typespec '' fullname:fullname g=work@child.U.p::ucfg_t.a o=work@struct_param_func_config.u_c.U.p::ucfg_t.a | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law pkgPara
   #2485    N0675 A (writer chain A) ref_typespec '' fullname:fullname g=work@child.C.p::cfg_t.u o=work@struct_param_func_config.u_c.C.p::cfg_t.u | leftRefFix174 (ParamEmit.cpp, law evalFuncBodyRhsStampClone167) < leftRefWalk174 (ParamEmit.cpp, law evalFuncB
```

## 14. Addendum: passes 228 and 227 landed at `9c9c11d6` during this map ([evidence/addendum_9c9c11d6/](evidence/addendum_9c9c11d6/))

Both live pairs this map was briefed on landed while it ran: **pass 228** (pair B r11u228, `cd4fd02a`, 09:05: §
memberInitReducedRootFolds228, § parseViewSizeExprEval228, § sizeBitNetIsVar228 and the verifier's three
refinements) and **pass 227** (pair A r11u227, `9c9c11d6`, 09:20: § fwdPkgRefClassScopeSpan227, §
pkgPatFuncBodyLeftoverNoParent227, § newArrayPartSelStripped227, § landingSwitchReach227's six splits, the verifier's
§ fwdPkgRefConstSlotWhole227v). Re-measured without editing the sections above:

* **The reference.** The pass-227 integration sweep (at `cd4fd02a` + pass 227, read-only) equals the committed
  baselines at `9c9c11d6` cell for cell (1596 / 1742 / 4087 rows, 0 differences); all 3273 corpus `slang:` lines name
  the main tree's `build/slang-uhdm`, then `8d6b7668` (built at 09:10, before the sweep), frozen here as
  `slang-uhdm.h227`. Its gate lines: probe 0 regressions / 0 conversions / 20 changes, surelog 0 / 0 / 2, uhdm2rtlil 0
  / 0 / 0, downstream 803 / 66 / 2 / 0. (The pass-228 integration sweep was already removed from the scratch when
  this map reached it; pass 228's own census reads 0 firings on every gate database, and the pass-227 sweep moves
  only databases pass 227's laws name, below, so pass 228 moved no gate database.)
* **Byte movers against this map's base sweep** ([byteverify.txt](evidence/addendum_9c9c11d6/byteverify.txt), [probe_movers.txt](evidence/addendum_9c9c11d6/probe_movers.txt); fence-filtered mirrors, 2560 databases each, 8 fenced left out unread):
  **2 of 2560 corpus databases** (FuncStructVal d/t) and **20 of 4087 probe databases** (r11u24repro n3, n12;
  r11u26repro m6, m8, m9, m13, m15; r11u28repro a4-a7, a13, a16; r11v26repro v2, v9, v12, v13, v15, v16, v18), each
  re-analyzed (drivers/statejobs.py, analyze.py, addmerge.py; [landing.txt](evidence/addendum_9c9c11d6/landing.txt)).
* **The fail list at `9c9c11d6`: 28 row-modes / 15 tests, 634 probe cases: no row-mode and no case converted.**
  Changed: FuncStructVal d `endcol(7)` -> `file(5)`, t `endcol(10)` -> `file(9)` (the head #747 gone, the next first
  record #4782, the INSTR_PER_FETCH leftover golden locates at its read site); twenty probe cases shrink by one or two
  objects on their `fullname` first field.
* **Clusters at `9c9c11d6`: 694** (695 - 1): **gone N1096** (FuncStructVal d/t #747, pair A's named head: §
  fwdPkgRefClassScopeSpan227); **N0003 24 -> 4 probe cases** (§ pkgPatFuncBodyLeftoverNoParent227; OPEN and ground A
  in this map, not a named head of either pair); none new, none grew.
* **This map's prediction for the two pairs, audited at once.** Section 6 credited them, optimistically, with **8
  row-modes / 4 tests / 154 cases** (FuncStructVal d/t, struct_param_func_config d/t, cfg_func_width_loop d/t,
  BlackBePipeInt d/t), and **4 / 2 / 83** on the NAMED heads alone (the two uhdm2rtlil rows). **Realised: 0 row-modes,
  0 cases** (both counts). Of pair A's 19 named clusters 1 is gone (N1096) and 18 are unchanged; of pair B's 18, none
  moved. The reasons are the passes' own: pass 228 re-measured the four joint rows at its base and found every first
  record on ground A or behind a ground-A record, so it wrote its laws elsewhere (they fire on no gate database); pass
  227 reached FuncStructVal's #747 and N0003 and lists "not reached: struct_param_func_config, cfg_func_width_loop,
  BlackBePipeInt #15268 and #15272, N0131, the Earlgrey scope names, N0039". Map 14's live pairs (r11u224, r11u223) converted no
  row-mode either; the rows they were credited with converted, when at all, in the next refill whose brief led with
  them (InterfArrayBind d, pass 225). The optimistic credit is an upper bound, and so is the named one when a row
  needs both grounds' halves in the same cycle.
* **The new live pairs** (dispatched during this map; routes [routes_add.json](evidence/addendum_9c9c11d6/routes_add.json), drivers/mkroutes_add.py,
  from their briefs): **pair A r11u232** (base `9c9c11d6`; item 1: the four joint rows' A halves, now every cluster of
  FuncStructVal and struct_param_func_config after pass 228's decode; item 2: the param_assign stamps and the minted
  clone return variables; items 3-6: pass 227's and r11u229's residues, N0131, the Earlgrey scope names, N0039, N0008,
  the UVM A families) and **pair B r11u231** (base `cd4fd02a`; item 1: the UVM heads N0266, N0337, N0072; item 2:
  N0120; items 3-6: pass 228's residues, Earlgrey's ground-B families, the joint rows only where their first record is
  ground B, which none is at `9c9c11d6`). Their yield ([report_add.txt](evidence/addendum_9c9c11d6/report_add.txt), drivers/report15.py over the
  merged analysis):

| | row-modes | tests | probe cases | fail list after |
|---|---|---|---|---|
| pair A r11u232 (optimistic, 133 clusters) | 5 (FuncStructVal d/t, struct_param_func_config d/t, BlackBePipeInt d) | 2 | 114 | 23 / 13, 520 |
| pair B r11u231 (optimistic, 9 clusters) | 0 | 0 | 8 | 28 / 15, 626 |
| **both (optimistic)** | **5** | **2** | **123** | **23 / 13, 511** |
| both, NAMED heads only (A 22 + B 4) | 4 (FuncStructVal d/t, struct_param_func_config d/t: every one of their clusters is a named A head) | 2 | 50 | **24 / 13, 584** |

  cfg_func_width_loop d/t stays behind the kept call N0133 + N0487 (ModuleEmit `emitContAssigns`, ground B), which
  r11u231's brief does not name. BlackBePipeInt d clears on pair A's optimistic row credit: pinned on the DEFAULT row
  (PW_ROWS, [evidence/writers/bb_default_row.txt](evidence/writers/bb_default_row.txt)) its remaining clusters are written in
  ParamEmit (N0923 `stampParenCastWidthTs`, N1125 `makeParamTs`) or in TypeEmit `buildStructTs` from the `memberScope`
  ParamEmit `makeParamTs` passes (N2471, N0028: pass 228's reading); BlackBePipeInt t keeps the `--elabuhdm` clone
  names written by uhdm_main `elabCloneFullNameUnstored137` (N0014 N0905 N1179 N1446 N2476, ground B), which no brief
  names. **The ground-B list for the refill after r11u231, on top of both new pairs** (report_add.txt section 8):
  N0040 (InterfaceModPort, the harness), N0056 (PreprocTest, the harness), **N0133 + N0487 (cfg_func_width_loop d/t:
  2 row-modes with pair A's half)**, the LogicTypespec four (a user decision); then the deep lists (the UVM rows,
  Earlgrey, Rggen, Scr1SvTests, BlackBePipeInt t's clone names, unchanged from section 13). No row is open on ground A
  alone after r11u232 (every OPEN ground-A cluster together clears 0 row-modes on top of the pairs).
* The UVM order-blind distance and census are unchanged at `9c9c11d6` (no UVM database moved).

## 15. Files, fence and process

* **cluster_index.csv**: one row per cluster (695): rows (row-modes carrying it) with the surelog / uhdm2rtlil split,
  tests, objects, probe cases, first_in_rows, **ground** (decoded override, else the writer's file, else the mint's),
  coverage (COVERED by which live pair and why, or OPEN with its map-14 history), `rows_after_pairs`,
  `probe_after_pairs`, `first_in_after_pairs`, **`alone_on_top_of_pairs`** (row-modes it clears alone on top of both
  pairs), `alone_on_pristine`, the same against the NAMED heads only, map 14's rows, coverage and site (`map14_*`),
  families, example tests, **site** (the MINT: `mint < caller < caller` with the nearest law), **writer** (the
  WRITER of the differing field, section 5) and **writer_chain_grounds**, probe laws, key, example object.
* **clusters.csv**: row-mode x cluster with its object count and a `first` flag; **probe_clusters.csv** the same per
  case; **fail_list.csv** / **probe_fail_list.csv**: every STRICT_NOTEQUAL row-mode / case with its first cluster,
  coverage, ground, mint site, **writer**, counts, and whether the live pairs clear it (optimistic and named-only).
* **evidence/**: `report.txt` (drivers/report15.py, every table), `audit.txt` (drivers/audit15.py), `final15.txt`
  (the clustering run), `routes.json`, `ground_override.json`, `greedy15.json`, `greedy15_named.json`,
  `pristine_index.csv` (the id assignment against maps 1-14), `rowsets.txt` (drivers/rowsets.py), `objects.csv` (one
  example object per cluster), `sites.json` (this edition's 28 mint re-pins), `tables/` (drivers/tables15.py),
  `clusters/` (the record dumps of one example per cluster that has a row or at least 3 cases, drivers/evid.py),
  `writers/` (`sites_writer.json` and `writer_ground.json` from drivers/pwsum.py, the pass-225-off validation, the
  count of gdb runs `npw.txt`), `landings/` (drivers/landing15.py per landing, drivers/delta15.py against map 14),
  `sweeps/` (the pristine and landing-off gate sweep logs, byteverify, the probe comparison, the binary audit),
  `away/` (drivers/awayall.py per state, canonical and raw, and the reversed controls), `controls/`,
  `determinism/`, `rebuild/`, `uvm/` (census and distance), `downstream/` (the face list and verdicts),
  `addendum_9c9c11d6/`.
* **drivers/** (every path resolved from the checkout or from `MAP_W` / `MAP_BIN` / `MAP_H` / `SWPFX` / `SP` set by
  the caller; no scratch path is hard-coded; every driver that reads databases, sources or case lists reads the fence
  list itself and fails closed; every tool called through a variable is checked with `[ -x ]`): `env.sh`,
  `common.py` (the key rewrite and the fence), `jobs.py`, `probejobs.py`, `probelaw.py`, `strict_runs.sh`, `run1.sh`,
  `analyze.py` (map 13's analyzer, unchanged), `final15.py` (ids), `delta15.py`, `statejobs.py`, `landing15.py`,
  `statesweeps.sh`, `movers.sh`, `bvmirror.sh`, `probecmp.sh`, `awaylandings.sh`, `awayall.py`, `mkroutes15.py`,
  `mkroutes_add.py`, `report15.py`, `tables15.py`, `rowsets.py`, `audit15.py`, `evid.py`, `pinmulti.py` + `sites.py`
  (mint pins) with `objrank.cpp`, **`pinwriter.py` + `pwsum.py` (writer pins) with `fieldoff.cpp` / `ccw.sh`**,
  `addmerge.py` (the addendum), `controls.sh`, `det.sh`, `ob.sh`, `rebuildid.sh`, `dsfaces.py`, `uvmcensus9.sh` +
  `uvmcensus.py` + `uvmfamilies.py`, `uvmdist.sh`, `cc.sh` and `strictcmp_x.cpp` (map 13's variant comparator),
  `headtable.py` (the head-record writer table), `readme15.py` (fills README.src.md's generated tables into README.md),
  `run15.sh` (the order the pipeline ran in).
  No patch file is in this directory.
* **Fence**: a grep of this directory for the four fenced names reads 0; the gate sweeps dispatched every row as the
  gate mandates, and nothing else of this map ran on, dumped or read a fenced test's sources or databases.
* **Process**: the pinwriter's first part stalled on the slowest examples (BlackBePipeInt, Earlgrey_0_1) and was
  stopped by this map (its own process, after checking the command line) and its remaining 89 clusters re-run in three
  parts; its partial output is kept, a cluster's later pin replacing an earlier one. No tool was ever called through
  an unset variable. The scratch used for this map was about 15 GB (sweeps, mirrors, record dumps, gdb runs),
  under 20 GB.
