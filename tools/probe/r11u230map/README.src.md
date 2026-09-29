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
| writer pins (new) | **563 clusters** pinned to the WRITER of the differing field on their smallest example, **83** row clusters again on their smallest CORPUS row, the **13 head records** of the fail-list rows, BlackBePipeInt d's four ground-B-filed clusters on the default row and pass 225's two conversions at the landing-off state: **669 gdb runs, every one writing the reference database byte for byte**; <<WRITER_STATS>> |
| N0039 / N0120 (brief question 2) | **N0039: written in ground A** (ParamEmit `predefIntTypespec` on the BuildUVMPkg row, ExprEmit `emitExpr` on the probe shape), map 14's ground-B filing superseded; **N0120: written in ground B** (TaskFuncEmit `emitTaskFuncs`, the `catch` enum_var's span through `copyLoc`) |
| landings since map 14 (section 3) | pass 224: 0 row-modes, 5 probe cases; **pass 225: InterfArrayBind d, OutputSize...StructMember d/t**; r11u226, r11u229: bytes only |
| yield of the live pairs (optimistic, section 6) | <<YIELD_LINE>> |
| **fail list after both live pairs** | <<AFTER_LINE>> |
| **realised (addendum)** | passes 228 and 227 converted **0 row-modes and 0 probe cases**: fail list at `9c9c11d6` **28 / 15, 634** (FuncStructVal d/t `endcol` -> `file`, 20 probe cases shrink) |
| away census since map 14 | **0 records lost chain-keyed for every landing** (pass 224: 134 toward, pass 225: 15, r11u226 and r11u229: bytes only); pass 224's 13 flat-key losses all excess removals in place; the reversed controls read 134 and 15 lost |
| determinism | **one hash per row-mode** on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg: **MiniAmiq d/t 1 hash in 12 draws each (r11u226's cure holds), Scoreboard d 1 in 12 (r11u229's cure holds)**, every draw equal to the HEAD sweep's |
| rebuild identity | three independent builds of `97343175` byte-identical (`7e50408d`); the `-g1` binary writes the same bytes on the two rebuild cases and on all <<NPW>> writer-pin examples |
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

<<T_FAIL>>

Columns: the strict cell per mode; clusters per mode; the row's first cluster (the earliest differing record's
cluster) with its ground; the first site, `W:` = the writer of the differing field (section 5), `M:` = the mint (a
struct / order cluster has no field); the first cluster still OPEN after both live pairs (optimistic) and the count of
open clusters; whether the pairs clear it; the same against the NAMED heads only; the downstream verdict of the
uhdm2rtlil rows. `probe_fail_list.csv` has the same per case (first cluster, coverage, ground, site, writer, counts,
clears).

**First clusters of the probe cases** (top 40; [evidence/tables/t_pfirst.md](evidence/tables/t_pfirst.md)):

<<T_PFIRST>>

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
  byte for byte (`db=SAME` on all <<NPW>>), so the rank named the example object.
* **Coverage**: <<WRITER_COVERAGE>>
* **The writer and the mint differ in file on <<W_NE_M>> clusters**; ground by the writer's own frame: <<W_GROUNDS>>.
  Writer chains that cross the grounds (the writer's frame on one ground, a caller on the other): <<W_CROSS>>.

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

<<T_HEADS>>

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
its one row left, Rggen d, is written by ExprEmit `emitExpr` inside a ModuleEmit generate lambda). <<OVR_CONFLICTS>>

**Ranked OPEN clusters** (by the row-modes each still carries after both live pairs, optimistic, then the rows it
clears ALONE on top of both pairs, then the rows it heads, then probe cases; the last column is the writer where
pinned (`W:`), else the mint (`M:`); [evidence/tables/t_t1.md](evidence/tables/t_t1.md), all 134 in
cluster_index.csv):

<<T_T1>>

<<T_OPEN_NOTES>>

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

<<T_YIELD>>

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
<<DS_COUNTS>>**.

<<T_DS>>

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

<<T_FAMILY>>

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
importer clones' copies) and F5; <<UVM_TOP>>

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

<<T_GREEDY>>

**The joint rows in walk order** ([evidence/rowsets.txt](evidence/rowsets.txt), drivers/rowsets.py: every cluster of
the row with its earliest record, ground and writer; the next refill of each ground can read exactly which records
stand in front of its own):

<<T_JOINT>>

## 14. Addendum: passes 228 and 227 landed at `9c9c11d6` during this map ([evidence/addendum_9c9c11d6/](evidence/addendum_9c9c11d6/))

<<ADDENDUM>>

## 15. Files, fence and process

<<FILES>>
