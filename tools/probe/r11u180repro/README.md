# r11u180: the module/type ground, pair B (refill after pass 176): nine laws, one switch split, the dead statements removed

Base `804e3b75` (branch matrix-1.87). Files of the ground touched: `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`,
`src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp` (the return site and its forward declaration). `uhdm_main.cpp` needed nothing. No line of
the sister's files (`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`), of
`include/`, and nothing under `results/`, `tests/probe/` or `third_party/` is edited; `tests/LAWS.md` is regenerated
(`python3 scripts/law_index.py`). The r11u183 decode (`tools/probe/r11u183dec`) had not landed when this pass started
and was not waited for.

Switches. Every law reads its own `R11U180_<LAW>_OFF` through `r11u180Law` (`UhdmExporter.cpp`, beside `r11u176Law`),
and `R11U180_OFF=1` drops all of them: it gives the pristine bytes on every one of the 81 cases here (section 4).
`R11U180_TRACE=1` prints one `R11U180 <LAW> <detail>` line per firing branch (the attribution below).

The slang-fenced tests are written `FENCED=` here and never spelled. Every driver that reads corpus sources or
databases (`drivers/row.sh`, `drivers/case.sh`, `drivers/predict180.sh`, `drivers/bvmirror.sh`, `drivers/attrib.sh`,
`drivers/boundary.sh`, `drivers/dscase.sh`, `drivers/uvmdist.sh`) takes the four names from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` (`drivers/env.sh`, fail closed) and refuses or skips a fenced name by word
boundary; the byte comparisons ran on hard-link mirrors that leave the 8 fenced row-mode databases out
(`fenced_skipped=8`). No fenced test was run, read or decoded outside the gate sweeps, which dispatch every row
themselves. gdb ran once, on `Earlgrey_0_1` only (not fenced), to locate the byte coin of section 9
(`drivers/mktrace.py`). A grep of this directory for the four names reads 0.

This pass was RESUMED after the first attempt died at an API usage limit: section 9 re-measures every gate from the
resume session (the final sweep `/tmp/r11u180_swH`) and records what the resume found.

## 1. Binaries (frozen `chmod 555` before any measurement, `/tmp/r11u180_bin/`)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `daefc86815272ea28a026d6a4741115f` | worktree build of `804e3b75` (system deps, `-j 2`) = the main tree's `build/slang-uhdm` |
| `d1`..`d15`, `final.bin` | (development builds) | `d6` ran the development sweep `swA`, `d9` `swB`, `final.bin` (`1f5753fd…`, before § classTpChainRootShares180) `swF` |
| `final2.bin` | `53c9f6116e2519503a607f7323369eb3` | **the final build of the patch** (= `d15`; the later edits were comments and drivers); the sweeps `swG` and, in the resume session, `swH` (the worktree rebuilt from its sources gives the same md5) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `predict180` | `19de3daddd97f9a78d46676704955aa5` | `drivers/predict180.cpp` built by `drivers/cc180.sh`, the byte-mover predictor |

Sweeps (`tests/sweep.sh --jobs 3`, all four stages, same-length workdirs, `drivers/sweep.sh`): `/tmp/r11u180_swP`
(pristine) and `/tmp/r11u180_swG` (`final2.bin`); the development sweeps `swA` (`d6`), `swB` (`d9`) and `swF` (`final.bin`: the
same status and strict columns as `swG` in all three stages). In `swG` all 3273 `slang:` lines of the corpus `cmds.txt` files
read `/tmp/r11u180_bin/final2.bin` (in `swP` all read `pris.bin`). Both
exit 1 for one reason only, `law index STALE: tests/LAWS.md`, which the base reads too; the patch carries the
regenerated `tests/LAWS.md`, and the resume session's final sweep `/tmp/r11u180_swH` (`final2.bin`, all 3273 `slang:`
lines audited) exits 0 (`law index current`). The pristine sweep equals the committed baselines: `probe.csv` byte-identical to
`results/golden_probe.csv`, `regressions=0 conversions=0 changes=0` in both corpora, `downstream.csv` equal
(`evidence/sweep_swP_summary.txt`, `evidence/sweep_swG_summary.txt`).

## 2. Verdict per targeted row (fresh csv rows of `/tmp/r11u180_swG`; results/ untouched)

**4 corpus row-modes STRICT_NOTEQUAL -> CMP_EQUAL, 0 regressions, loudly:**

    PackedArrayHighConn,default,CMP_EQUAL,,,equal     § enumImportParentLastWriter180   (was differ:fullname(5), map N0163)
    PackedArrayHighConn,testflags,CMP_EQUAL,,,equal   (same)                             (was differ:fullname(5))
    mem_read_reg,default,CMP_EQUAL,,,equal            § ifaceWildcardTdNameOrder180      (was differ:name(5), map N0804 + N0805)
    mem_read_reg,testflags,CMP_EQUAL,,,equal          (same)                             (was differ:name(5))

**9 probe cases STRICT_NOTEQUAL -> EQUAL** (EQUAL 2880 -> 2889), 6 changes, 0 regressions:
`r10earl_repro/qb25` (ENUMIMP + IFACETDORDER), `r10rggen7repro/t6` (ENUMIMP), `r10uvm224repro/grid224/a15_associndex`
(IFACETDORDER), `r10uvm66repro/v3_unbound` (TPUSE), `r10v223repro/branches/v1_pkg_nodata` (IFACETDORDER),
`r11u10repro/grid/h9_1e1m_port` and `hD_1e1mvec` (ENUMIMP), `r11u14repro/c10` (PKGAGGCLONE),
`v11u111repro/brk/f5/z51_three_mods_import` (ENUMIMP).

**Changes (compare_results CHANGE lines), every one attributed, every one toward golden:**

| row / case | base | final | law | why it moves toward golden |
|---|---|---|---|---|
| ArrayMethodIterator d / t | name(6) / name(16) | endcol(1) / endcol(1) | § classTpDefaultTsAtUse180 | the five `CB` class_typespecs now read golden's `uvm_callback 10:50-10:62`; the one record left is the sister's N0097 (section 7, S2) |
| Earlgrey_0_1 d / t | fullname(436) | col(102) | § enumImportParentLastWriter180 (67 firings) | the 102 records are a strict SUBSET of the pristine 436 (`evidence/earlgrey_default_records_{P,G}.txt`: 0 records enter); the first record moves from #25840 to #26470 |
| Rggen d | fullname(7) | endcol(634) | § enumImportParentLastWriter180 (5) + § ifaceWildcardTdNameOrder180 (2) | **the count grows because the walk diverges later**: the pristine walk diverged at #469 (depth; #466 is the interface typedef order `rggen_polarity` vs `rggen_status`); all seven pristine records (#111-#469) are gone and the walk now runs to #23166 (a type face, operation vs constant: ExprEmit), exposing 634 records behind (`evidence/rggen_default_records_{P,G}.txt`) |
| const_cast_signext d / t (u2r) | line(5) | type(1) | § modAggTfArgCloneFollows180 | the five `op_t` spans read golden's 19:42-19:46; the walk now reaches #602, a `func_call sext` golden keeps where ours folds (sister S3) |
| struct_param_func_config d / t (u2r) | line(8) | fullname(5) | § pkgAggTfArgCloneFollows180 | the four `p::ucfg_t` copies read golden's 32:40-32:46; the five left are pass 174's leftRefFix174 names (N2412 / N0675, ParamEmit, sister) |
| r10uvm55repro/a1 | line(20) | file(15) | § classTpDefaultTsAtUse180 | #53 / #105 gone, the first record moves to #134, 20 -> 15 objects |
| r10uvm59repro/a3_scope | line(2) | line(1) | § classTpDefaultTsAtUse180 | #84 gone |
| r10uvm90repro/g90_a2_shapes | line(11) | line(9) | § classTpFormalMovesTs180 + § classTpDefaultTsAtUse180 | 2 fewer |
| r10v158repro/v158_i | name(4) | name(3) | § classTpDefaultTsAtUse180 | #57 gone |
| r11u88repro/grid/i1_ifkinds | type(1) | endcol(2) | § ifaceWildcardTdNameOrder180 | the walk no longer diverges at #236 (the interface typedef order); two end columns at #347 / #590 behind |
| r11v53repro/grid/x10_iface_import_shadow | type(1) | fullname(2) | § ifaceWildcardTdNameOrder180 | the walk no longer diverges at #67; two type-parameter names at #207 behind |

Status histograms at the end: surelog 454 + 26 default, 450 + 24 testflags judge-equal (480 / 474 as at the base);
uhdm2rtlil 784 + 19 both modes (803 / 803). No row leaves judge-equality.

**Downstream.** `downstream.csv` of `swG` is byte-identical to the pristine sweep's (803 IDENTICAL / 66 SLANG_REJECT /
2 EQUIVALENT / 0 DIVERGENT; pass 120's eight rows included): `mem_read_reg,IDENTICAL,...` and every other row as
recorded. On the cases (`evidence/downstream_cases_P_vs_L.txt`, the gate's own `one()`, fresh `GOLDEN_CACHE`): **4
DIVERGENT -> IDENTICAL** (R/r01 = r11u182's F/f01, r02, r04, r06: § splitPortIntRedeclLogicTs180), 75 IDENTICAL stay
IDENTICAL, none moves away (the two three-file cases H/h23, h24 are not run downstream).

## 3. The laws

Grids: `cases/<grid>/<case>/dut.sv` (first line `// § <law>`; H/h23, h24 carry a `files` list). `drivers/case.sh`
judges a case against the pinned Surelog with the probe harness's arguments (`-parse -nobuiltin -nocache -sv ... -mt 0
-mp 0`, ours `--single-unit --nobuiltin`); `evidence/grid_pristine_law_off.txt` lists every case with both binaries.

### 3.1 § enumImportParentLastWriter180 (`R11U180_ENUMIMP_OFF`, branch `R11U180_ENUMIMPHDR_OFF`) — ModuleEmit.cpp

**Law.** A package ENUM typedef's shared listing object is parented at the alphabetically LAST importing MODULE
definition (an interface only when no module imports it), and its base-type reference is named through that module
(`work@<module>.<pkg>::<name>`). **Decode.** `UhdmWriter::write` (third_party/Surelog/src/DesignCompile/UhdmWriter.cpp)
writes programs, then interfaces, then modules, each loop over `Design::getModuleDefinitions()`, a `std::map` keyed by
the definition name (`ModuleNameModuleDefinitionMap`, include/Surelog/Common/Containers.h), and `writeModule` /
`writeInterface` run `writeDataTypes(setParent)` over the definition's DataTypeMap, which `importPackage` filled with
the package's typedef objects themselves; the base ref's full name is `BaseClass::ComputeFullName` over that parent.
Our emitter wrote the parent and the scoped names importer by importer in source order (`emitImportArtifacts`); the
sites record each write and a design-final drain replays the winner's, before § typedefParentLastWriter134's model
(which still unparents an assigned typedef). Struct and union objects stay § typedefParentLastWriter134's. The branch
`ENUMIMPHDR`: an explicit HEADER import (`module z import p::e_t; (...)`) is a writer too (golden h15, h21: the parent is
`work@z_mod`), recorded only (the emitter keeps not writing in place). Golden PackedArrayHighConn: `pad_type_e` under
`work@prim_pad_wrapper`, ours `work@dut` (source order). **Grid H** (24 cases): h01 (the row's text), h02/h03 (two modules
in both source orders: h03 was wrong), h08/h09/h14 (explicit and body imports), h10 (three modules), h11/h13 (interface
beside module: the module wins), h12 (a struct nesting the enum), h15/h21/h22 (header imports), h16 (an assigned enum:
still unparented), h17 (two packages' enums), h18 (an alias typedef), h19 (a program: stage 1 on both binaries), h20
(instances), h23/h24 (three files, both module-file orders), h04-h07 controls. 10 conversions, 12 equal on both, 2
stage 1 on both (h17's head unchanged; its dump's parents now read golden's).

### 3.2 § classTpDefaultTsAtUse180 (`R11U180_TPUSE_OFF`) — TypeEmit.cpp, sites in TypeEmit / TaskFuncEmit / UhdmExporter

**Law.** A declaration written as one of its class's own TYPE PARAMETERS resolving to a class, in a group with no
winning typedef, is typed by the parameter's OWN class_typespec: named as the class header spells the default
(§ classTpTsResolvedNameEverySite87's `classTpTsName87`) and located at that default's tokens, at every site: a class
property, a method body local, a nested-block local, a queue / array element, a return value. **Decode.**
compileTypespec answers a type-parameter name with the parameter's typespec (CompileType.cpp's parameter branch), one
object per group; ours minted a per-declaration object at the use, anonymous for a same-package class
(§ localClassTsUnnamed15). The sites (makeTypespec's class-handle branch, the return branch in TaskFuncEmit, the array-element
branch in UhdmExporter) record their object when § 87 finds no winner; a design-final drain copies name, file and span
from the parameter's own object (recorded in `emitClassParameters`). Fences: an out-of-body definition's local (§ 87's
fence), an inherited parameter. Golden ArrayMethodIterator `CB cb;` = `class_typespec uvm_callback 10:50-10:62`, ours
anonymous at 14:3-14:5. **Grid A** a01-a05, a07-a13, a16, a19, a20.

### 3.3 § classTpFormalMovesTs180 (`R11U180_TPFORMAL_OFF`) — TypeEmit.cpp

**Law.** A class method FORMAL written as that type parameter MOVES the shared object: `compileTfPortList` runs
`populateCoreMembers(type, type, ts)` on the typespec compileTypespec answers (the § tfArgTypedefLastWriter146 decode),
so the parameter's object, every use, and every formal read the LAST formal's type token (source order in the class
body); an `extern` prototype's formal is a writer (the class-body listing compiles the prototype), an out-of-body
definition's is not. Golden a06 `class_typespec base_c 6:21-6:23` under the type_parameter for `function void f(CB
x)`; a17 two methods, golden 9:28-9:30 on both formals; a18 the prototype's 6:28. **Grid A** a06, a14, a17, a18.

### 3.3b § classTpChainRootShares180 (`R11U180_TPCHAIN_OFF`) — TypeEmit.cpp

**Law.** A type parameter whose class-header default is ANOTHER type parameter of the same class (`type RSP = REQ`)
resolves, in compileTypespec, to that parameter's own object: the chain's ROOT holds the one object that every chain
member's type_parameter, their uses and their formals read (the formal writer of § 3.3 moves it for the whole chain).
The chain is read off the class header (a specialization's parameter carries its override as target type and no
syntax: the generic class declaration's parameter port list is read). Golden r10uvm31repro/t41a: `take_rsp(input RSP
t)`, the last formal, moves the object `REQ`'s type_parameter lists too (59:42-59:45); ours moved `REQ`'s to `take_req`'s
58:42. **Grid A** a21 (uses and two formals), a22 (uses only) convert; a23 (a specialization overriding both) stays
stage 1 with the same head, its `base_c` objects now at golden's 8:21-8:24.

### 3.4 § classTpQualDefaultSpan180 (`R11U180_TPQUAL_OFF`) — UhdmExporter.cpp `emitClassParameters`

**Law.** A type parameter default written PACKAGE-QUALIFIED (`type CB = other::base_c`, `other :: par_c#(int)`) is
located at the qualifier, `other::` from the package name to the end of the `::` token (the paPackage_scope form, the
span § tfArgQualOutsideWriter176 reads for a qualified formal), and named from the tokens without blanks (golden
`other::base_c` 6:26-6:33, ours 6:26-6:39 and `other :: base_c` verbatim). **Grid A** a04, a11, a12, a15 (a11 and a15
were stage 1 on the pristine binary: the name is judged).

### 3.5 § modAggTfArgCloneFollows180 (`R11U180_MODAGGCLONE_OFF`) — TypeEmit.cpp

**Law.** § modAggTfArgLastWriter155 moves a MODULE typedef's shared struct / union object to the last formal at
compile time, before elaboration, so every copy Surelog clones afterwards reads the moved span; ours built the copies
(the elaborated parameter's typespec) from the typedef's syntax. The listing site records the move and a design-final
drain gives every other struct / union typespec of that name located exactly at the typedef's declaration span the
moved span (the write-time end stretch `structTypedefUseEnd` is the shared object's alone). Golden const_cast_signext
`op_t` 19:42-19:46 under `work@const_cast_signext.OP_F`, ours 15:11-15:61. **Grid T** (t11 moves; t01-t10 controls,
t06 an interface residue) and U/u03, u04.

### 3.6 § pkgAggTfArgCloneFollows180 (`R11U180_PKGAGGCLONE_OFF`) — UhdmExporter.cpp

**Law.** The PACKAGE twin: a package struct / union typedef moved to a package subroutine formal's type token (at
package compile time; ours is emitPackage's last-writer loop, ParamEmit.cpp) is copied by importers AFTER the move, so
golden's import copies read the moved span (struct_param_func_config's `parameter U` copy in `work@child`:
`p::ucfg_t` 32:40-32:46, ours 16:11-20:4). Applied when every listing object of the typedef starts at the same moved
one-line span (a definition listing left at the declaration, the qualified outside writer's shape, or a write-time
end stretch is not this move), to every other struct / union object of that name at the declaration's exact type span.
**Grid P** p03-p05 convert, p01/p02 stage 1 on both (a sister value face: the head is the constant `BIN` vs `INT`, and
our struct now reads golden's moved span in the dump), p06 control.

### 3.7 § ifaceWildcardTdNameOrder180 (`R11U180_IFACETDORDER_OFF`) — ModuleEmit.cpp `emitImportArtifacts`

**Law.** A WILDCARD import lists the package's typedefs in an interface in NAME order, as the module branch does:
importPackage copies them into the interface's DataTypeMap (a `std::map` keyed by name) and writeInterface's
writeDataTypes walks it in that order. Golden mem_read_reg `mem_if` lists `p::req_t` before `p::rsp_t` (declared rsp_t
first). **Grid I** i01, i04, i05 convert; i02 (explicit imports), i03, i06 (vector typedefs) are stage 1 on both
binaries with the same head.

### 3.8 § splitPortIntRedeclLogicTs180 (`R11U180_PORTINTREDECL_OFF`) — TypeEmit.cpp `makeTypespec`

**Law.** A split (Verilog-95) port whose port declaration carries no data type (`output b;`) and whose body re-declares
it as a predefined integer type (`integer`, `int`, `time`, `byte`) keeps the PORT declaration's own typespec: a
`logic_typespec` at the port declarator (signed when the port declaration says `signed`); only the variable is integer.
Golden r11u182verify F/f01: `logic_typespec 4:10-4:10` under the port; ours typed the port `integer` (r11u182's
residue 3, downstream DIVERGENT 1 vs 7 gates). **Grid R** r01-r04, r06 (stage 1 -> STRICT_EQUAL, downstream DIVERGENT ->
IDENTICAL), r05 control.

### 3.9 § tfArgAggSwitchSplit180 (`R11U180_AGGSWITCH_OFF`) — UhdmExporter.cpp (v11u176's coupling)

`R11U176_QUALFORMAL_OFF` dropped the struct face of § tfArgClassMethodOrder176 too (the aggregate admission `aggTd176`
was gated by it alone). The admission now follows any of `R11U176_QUALFORMAL_OFF`, `R11U176_CLSMETHOD_OFF`,
`R11U176_DEFTOPSPLIT_OFF`, and the outside-writer aggregate face alone reads `R11U176_QUALFORMAL_OFF`. Byte-identical
with every switch on (all 21 v11u176 CM cases and all 20 r11u176 PQ cases identical on `pris.bin` and the law binary);
with `R11U176_QUALFORMAL_OFF=1` the CM/c08 and c18 struct faces now stay (c08 STRICT_EQUAL, c18 `fullname` as with every
switch on) and the PQ cases read as on the pristine binary with the same switch.

### 3.10 Housekeeping (no switch)

§ genElseBeginIfDepth176's two dead statements (`for (auto& sg : segs171) (void)sg;` and the unused `outer`, v11u176
residue 6) are removed: byte-identical by construction (every case of this pass and the boundary run read no mover
there).

## 4. The gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `daefc868…` = main tree; law `53c9f611…` |
| (2) tests/sweep.sh --corpus probe | regressions=0, conversions=9, changes=6; EQUAL 2889 STRICT_NOTEQUAL 1198, every case judge-equal |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 2 + 2; changes 5 + 4 (all in section 2) |
| (4) downstream | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66, not identical and not excused=0; `downstream.csv` byte-identical to the pristine sweep's; `mem_read_reg` IDENTICAL; pass 120's eight rows IDENTICAL |
| (5) uhdm-cmp on touched rows | every mover keeps its judge-equal status (the strict stage 1 is uhdm-cmp's Compare; 0 regressions in all three stages) |
| (6) byteverify | 22 corpus movers of 2560 (`evidence/byteverify_G_vs_P.txt`, SELFCHECK 2559/2560 flagged; `fenced_skipped=8`), 17 probe movers of 4087 (`evidence/probe_movers_G_vs_P.txt`): **all 39 predicted by name** from the pristine databases (`evidence/predict180_pristine.txt`: 67 predicted, each trigger a superset of its law's condition) and all attributed by trace (section 5) |
| canaries | `r11u107repro/canaries.sh`: surelog ok=50 changed=2 (Earlgrey_0_1 d/t, the attributed change), uhdm2rtlil ok=16 changed=0 (pristine 52/0 and 16/0); `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS, `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS |
| cases | 83 cases (`evidence/grid_pristine_law_off.txt`): 37 go to STRICT_EQUAL (7 of them from stage 1), 1 from stage 1 to judge-equal (a12), 4 change toward golden (a01, t11, u03, u04), 26 equal on both, 4 keep their first field (a20 with 4 -> 2 objects; a19, s01, t06 unchanged), 11 stage 1 on both with the same head (H/h25 and H/h26 were added in the resume session, section 9) |
| switches | each switch alone returns exactly its own cases (`evidence/switches.txt`); `R11U180_AGGSWITCH_OFF` moves none (by construction) |
| `R11U180_OFF=1` | 83 of 83 cases byte-identical to pristine. On `Earlgrey_0_1` it is NOT reliably so: see the byte coin in section 9 |
| boundary | every `tools/probe/**/dut.sv` case outside this pass (9701 dirs, fence excluded, `drivers/boundary.sh`) plus 20 `args`/`dut.v` cases: 51 movers, all attributed by trace (`evidence/boundary_movers_attrib.txt`: ENUMIMP 18, PKGAGGCLONE 21, IFACETDORDER 7, MODAGGCLONE 3, TPFORMAL 3, TPCHAIN 2, TPUSE 1), none leaves judge-equality (`evidence/boundary_movers_judged.txt`): 5 convert (r11u10repro h1_1e1m, r11u151struct D/e02, r11u155repro MF/m05, r11u167repro pc/c10, r11v163repro rc/f05), 5 change toward golden (r11u112 t01_ccs and r11u163 rl/q03 line -> type: the walk reaches the sister fold S3; r11u83/r11u85 i1_ifkinds type -> endcol; v11u155 FN/d05 type -> fullname), the 41 stage-1 movers keep the same golden head object (32 byte-identical cmp output; 9 print our side's objects at golden's spans or order); the byte controls of passes 118, 119, 120, 124, 131, 176 (and their verifiers) and r11u182 are all SAME |

## 5. Movers and attribution

Corpus (`evidence/attrib_corpus_movers.txt`, `R11U180_TRACE=1` on each mover's recorded command line, final binary):

| mover (d/t) | laws firing |
|---|---|
| ArrayMethodIterator d/t | TPUSE 3 |
| BuildUVMPkg d/t | TPCHAIN 7, TPFORMAL 44, TPUSE 61 |
| Earlgrey_0_1 d/t | ENUMIMP 67 |
| MiniAmiq d/t | IFACETDORDER 2, TPCHAIN 7, TPFORMAL 44, TPUSE 57 |
| PackedArrayHighConn d/t | ENUMIMP 1 |
| Rggen d | ENUMIMP 5, IFACETDORDER 2 |
| Scoreboard d, SeqDriver d/t, SimpleUVM d/t | TPCHAIN 7, TPFORMAL 44, TPUSE 56 |
| const_cast_signext d/t | MODAGGCLONE 4 |
| mem_read_reg d/t | IFACETDORDER 1 |
| struct_param_func_config d/t | PKGAGGCLONE 4 |

The UVM rows keep their strict cell (MiniAmiq fullname(9), SeqDriver fullname(8), SimpleUVM / Scoreboard / BuildUVMPkg
fullname(24): the first differing records are other families, section 6) and move toward golden order-blind
(`drivers/uvmdist.sh`, `evidence/uvmdist_{P,G}.txt`, ours-not-golden + golden-not-ours records): MiniAmiq 27043 ->
26777 (testflags 26779: the one-record UINT/vpiDecompile coin), SeqDriver 20009 -> 19747, SimpleUVM 7392 -> 7128,
Scoreboard 6014 -> 5750, BuildUVMPkg 3657 -> 3353; ApbSlave 12 and SVSwitch 108 unchanged. The 22 movers are exactly
the 22 the development sweeps `swB` and `swF` moved, and every one is predicted and traced.

Probe (`evidence/attrib_probe_movers.txt`): the 9 conversions and 6 changes above, plus r10uvm180repro/g180_a_kinds
(PKGAGGCLONE) and r10v160repro/x11_class (TPUSE), whose strict verdicts (`depth(1)`) and first records are unchanged:
the moved objects sit behind the same walk divergence.

## 6. The UVM / Earlgrey rows (brief item 4)

First ten records after the laws (`evidence/uvm_first10_after.txt`, the final sweep), by family:
* **MiniAmiq, SeqDriver, BuildUVMPkg**: #770 / #753 / #1135 the typespec-identity reference name `uvm_reg_byte_en_t`
  under a `bit_typespec` (map N0164; TypeEmit `bareScalarTdCopyOf`, not landed here); MiniAmiq #899 `uvm_severity` file
  (the class-writer relocation with outside writers, pass 176's residue q11); `seed_map.count[type_id]` /
  `uvm_random_seed_table_lookup` select columns (ExprEmit, sister); `uvm_bitstream_t` / `uvm_integral_t` logic_typespec
  files at formal type tokens (§ tdMoveCarriesFile172's family); a `depth` record (`printer` bound to
  `uvm_default_printer`: a reference binding, sister). BuildUVMPkg's records 5-10 are reference full names through the
  call argument chain (F5, sister).
* **SimpleUVM, Scoreboard**: ten `ref_typespec UVM_MACRO_*` package parameter reference names (N0682, sister).
* **SVSwitch**: #184 a class property's class_typespec without a file (`Receiver`, UhdmExporter `classElemVar`, map
  N0067's family), #264 a bit_select column, #651 / #980 reference full names (F5), then interface-array names under a
  program instance.
* **Earlgrey_0_1**: 436 -> 102 records, first #26470 a `flash_phy_pkg.sv` constant column (43:53 golden, 43:28 ours),
  then `reg2hw.key[i]` bit_select names (ExprEmit).

## 7. Residues, ranked, and the sister-ground faces (decoded; the fix sits elsewhere)

1. **S1 — StructParamPatternInitCast d/t fullname(3)** (N0003 + N0014): the elaborated `localparam it_t INT = '{...}`
   pattern whose member values read a function-computed struct parameter keeps its pattern operation with a BARE
   ref_typespec (no parent, no full name) whose actual is the parameter INT's own struct copy (members
   `work@...INT.S_SW`); ours parents the ref at the operation and binds the type parameter's struct (`...S_SW`).
   Site: ParamEmit.cpp, the op75 `MakeRef_typespec` beside § elabPatQualRefQualSpan133 (`rt->VpiParent(op2)`) and the
   actual bound through `rhsRt` / `patchParamTypespecs`. Cases S/s01 (the face), s02-s04 (a reducible value: equal).
2. **S2 — ArrayMethodIterator d/t endcol(1)** (N0097): `callbacks_to_append.unique( cb_ ) with ( cb_.get_inst_id )`
   hier_path ends after the `)` in golden (19:90), ours at 19:89. ExprEmit (the method-call-with-clause span; the map
   gave it to r11u178, which did not land it). The row converts with it.
3. **S3 — const_cast_signext d/t type(1)**: golden keeps `func_call sext(OP_F)` in the elaborated cont_assign where
   ours folds the constant function call (also `assign o = g(12'hFFF)` in a four-line module). ExprEmit's call branch
   in the elaborated cont_assign context (cases T/t11, U/u03, u04).
4. **S4 — iface_zero_width_field d/t fullname(3)** (N0688): the unparented reference § pkgPatReadTsNoParent131 /
   § pkgPatUnqualReadTsNoParent178 mint for package `B`'s flattened pattern binds the parameter's own struct copy (member
   names `p::B.p::bus_t.CTL`); golden binds the package typedef's shared object (`work@top.p::bus_t.CTL`, parented by
   § typedefParentLastWriter134's last writer). Site: ParamEmit.cpp `drainShareDefParamTs`, the reference's actual.
5. **S5 — ibex_icache d/t fullname(49)** (N0129): the part-select bound constant substituted for the package parameter
   `IC_LINE_W` in an explicit `assign` (`lookup_addr_ic0[ADDR_W-1:IC_LINE_W]`) is named `work@ibex_icache` in golden,
   ours through the selected object; the explicit-assign substitution is ExprEmit's (`elabCaPortParamPaCopy64` per the
   map), not ModuleEmit's `substNdaParamRefs` (net-declaration assignments only, § paramBaseSelTsInstName168 already
   gives the direct bound the instance name there).
6. **ApbSlave d/t depth(1)** (N0289): ours binds `svunit_version` inside a class method to a second copy of the package
   string variable (4 extra objects listed under the reference); the binding is ExprEmit's, the listing ParamEmit's
   `emitPackageVar`. N0067 / N0068 / N0162 (ours) are behind it.
7. **ibex_pmp d/t file(5)**: the elaborated package parameter `PmpCfgRst`'s element binds the definition
   `pmp_cfg_t` where golden binds the moved elaborated one, and the module's import copy the reverse (a swap of the two
   listing objects between two parameter emissions: ParamEmit's package parameter and the import-parameter copy).
8. **PreprocTest d/t endcol(2)** (N0056), re-measured: the face is the `bit_typespec` span alone (5:14-5:17 golden,
   5:14-5:23 ours); pass 168's decode stands (ParseFile.cpp: no `-sv` and a `.vh` file lex `bit` as an identifier), and
   the harness never tells slang-uhdm Surelog's parse mode. Not implementable on this ground.
9. **HierPathTypespec t fullname(1)** (N1174): under `-elabuhdm` golden binds `c[1].x` to the member of a copy of `a`
   parented under `b`'s element (`pkg::pkg::b::pkg::a::x`); the default row is CMP_EQUAL. Naming is context-dependent
   here (the memory's warning); not attempted.
10. Class type-parameter groups: a § 87 group with a winning typedef keeps golden's default-token span at every site
    (a19: ours at the uses); a derived class's `extends base #(CB)` specialization typespecs (a20); a specialized
    parameter's `int` typespec at the generic's default (a12); our class_defn lists a specialization's parameters
    where golden lists the generic's (a23, t41a: stage 1). TypeEmit / UhdmExporter, next on this ground.
11. **InterfaceModPort d/t endcol(12)** (report only): the definition interface `mem_if`'s `logic reset;` etc. (logic_net
    typespecs) end at the keyword in golden (27:3-27:8), ours at the declarator (27:21); the plain shape is equal
    (interface with and without a modport), so the stretch comes from a use in this design not isolated here.
12. **YosysRiscv d/t col(40)**: `butterfly[`smartbextdep_bfly_idx_b(4, i)]` bit_selects inside a macro argument: every
    span one column right at the start and one left at the end; the location model's macro-argument mapping
    (UhdmExporter) or ExprEmit's select span; not decoded further.
13. **LogicTypespec d/t endline(3)** (a user decision, measured only): the package `logic_typespec` golden spans
    2:9-7:44 (to a use site), ours 2:9-2:20; unchanged.
14. Pass 176's carried residues not attempted: the UVM class-writer relocations with outside writers (MiniAmiq #899),
    § tdMoveCarriesFile172's writer order across unit kinds (TT/t9), a package variable declarator at a module
    declarator's position (TT/t2), typespec-identity full names (N0164), type-parameter last writers, program instances
    sharing processes, a pasted-token io_decl column, the include-file undef residue, the modport shorthand and wildcard
    grids, interface-instance delays, `g[S.a].x`, CovMacro's macro-argument columns.
15. **Determinism (found in the resume session, section 9)**: LAW S's design-final pass `bareScalarTypedefVarTs`
    (TypeEmit.cpp, beside § portVecTdElemClone18) mints its per-declaration copies (`bareScalarTdCopyOfFresh16`) while
    iterating `s.AllObjects()`, a pointer-keyed hash map, so the copies' creation order (their UhdmIds) follows heap
    addresses. Order-only (sorted dumps identical, strict verdicts unchanged); a fix (collect, sort by UhdmId, then
    mint) would move the bytes of every row whose copies are minted out of id order and wants its own pass with an
    order-blind census and the downstream lane as gate.

## 8. Files

* `cases/{A,H,I,P,R,S,T,U}/`: 83 cases (first line `// § <law>`; `H/h23`, `H/h24` carry a `files` list; `H/h25` a program
  and a module importing one enum, `H/h26` an interface plus a wildcard and an explicit module importer, both added in
  the resume session):
  A § classTpDefaultTsAtUse180 (a01-a05, a07-a10, a13, a16, a19, a20), § classTpFormalMovesTs180 (a06, a14, a17, a18),
  § classTpChainRootShares180 (a21-a23), § classTpQualDefaultSpan180 (a11, a12, a15); H § enumImportParentLastWriter180; I § ifaceWildcardTdNameOrder180;
  P § pkgAggTfArgCloneFollows180; R § splitPortIntRedeclLogicTs180; T, U § modAggTfArgCloneFollows180; S the sister
  face S1 (named after its site, § elabPatQualRefQualSpan133).
* `drivers/`: `env.sh` (pins, binaries, `$FENCED` from canaudit.sh, fail closed), `sweep.sh`, `row.sh` (a corpus row's
  strict records), `case.sh` (a case against the pinned Surelog), `grid.sh` (pristine / law / all-off bytes),
  `switches.sh`, `predict180.cpp` + `cc180.sh` + `predict180.sh` (the predictor over pristine databases),
  `bvmirror.sh` + `probemovers.sh` (fence-clean byte comparisons), `attrib.sh` (trace per corpus mover),
  `boundary.sh` (both binaries over every tools/probe case), `dscase.sh` (the downstream gate's `one()` on cases),
  `uvmdist.sh`, `probefirst.sh`, `parents.sh`, `mktrace.py` (the gdb creation-site trace of section 9).
* `evidence/`: sweep summaries, byteverify and probe movers, the predictor output, the mover attributions, the grid
  and switch tables, the boundary run and its judged movers, the downstream table of the cases, the UVM distances and
  first records, the Earlgrey and Rggen record lists before and after; from the resume session
  `sweep_swH_summary.txt`, `byteverify_H_vs_P.txt`, `probe_movers_H_vs_P.txt`, `earlgrey_coin.txt`.

## 9. Resume verification (the second session)

The first attempt died at an API usage limit after writing sections 1-8. The resume session rebuilt the worktree binary
from its current sources (md5 `53c9f611…` = `final2.bin`), confirmed that the main tree is still at `804e3b75` and that no
r11u183 decode has landed (`tools/probe/r11u183dec` absent), and re-measured everything below with its own runs:

* **Final sweep `/tmp/r11u180_swH`** (`drivers/sweep.sh final2.bin`, all four stages, `evidence/sweep_swH_summary.txt`),
  rc=0: probe regressions=0 conversions=9 changes=6 (EQUAL 2889 / STRICT_NOTEQUAL 1198), surelog regressions=0
  conversions=2 changes=5, uhdm2rtlil regressions=0 conversions=2 changes=4, downstream IDENTICAL=803 / SLANG_REJECT=66
  / EQUIVALENT=2 / not excused 0. The same CONVERSION and CHANGE lines as in section 2. `probe.csv` and `uhdm2rtlil.csv`
  are byte-identical to `swG`'s; `surelog.csv` differs from `swG`'s only in the two LowMem detail texts (they carry
  the work directory); `downstream.csv` is byte-identical to the pristine sweep's.
* **byteverify** `swH` vs `swP` (`evidence/byteverify_H_vs_P.txt`): the same 22 movers by name (SELFCHECK 2559/2560,
  `fenced_skipped=8`); probe movers the same 17 (`evidence/probe_movers_H_vs_P.txt`). Three movers' HASHES differ
  between `swG` and `swH` (same binary): MiniAmiq d/t and SeqDriver d/t, the known 4-line `UINT` / `vpiDecompile`
  coin (`|vpiDecompile:0` vs `1229`), and Earlgrey_0_1 d/t, the coin below.
* **canaries**: surelog ok=50 changed=2 (Earlgrey_0_1 d/t, `fullname(436) -> col(102)`), uhdm2rtlil ok=16 changed=0;
  `ctcan2.sh` PASS on both (EXPECT_UNKNOWN 1 and 6).
* **grid** and **switches** re-run: identical to the first session's tables. Two cases were added: H/h25 (a program
  `zprog` and a module `amod` import one enum package: stage 1 on both binaries with a program head, byte-identical)
  and H/h26 (an interface wildcard, a module wildcard `amod` and a module explicit body import `bmod`: STRICT_EQUAL on
  both; the law parents the enum at `work@bmod`, trace `ENUMIMP p::e_t -> work@bmod`, and its bytes move with no strict
  field: a control that the explicit body importer wins as a module). Downstream spot check R/r01, R/r06: DIVERGENT on
  `pris.bin`, IDENTICAL on `final2.bin`.
* **The Earlgrey_0_1 byte coin** (`evidence/earlgrey_coin.txt`). `swG` and `swH` wrote two different Earlgrey
  databases from one binary. Re-running the sweep's command line: `pris.bin` wrote ONE hash in 21 of 21 runs (3 serial,
  18 at six concurrent); `final2.bin` wrote two hashes (serial 3/3 `c491d4bd`; concurrent 5 `c491d4bd` + 4 `bffa323b`),
  and so did `final2.bin` with `R11U180_OFF=1` (6 pristine bytes + 12 `864c6bb2`) and with `R11U180_ENUMIMP_OFF=1`. So the
  coin does not come from any law's logic. The two outcomes differ ONLY in the place of one weakly-referenced
  `logic_typespec spi_byte_t` in uhdm-dump's id-ordered tail (12 raw lines, sorted dumps identical, strict verdict
  `col(102)` in both sweeps). A gdb trace of every `MakeLogic_typespec` call (66677 per run) shows one call site
  swapping places between the two outcomes: `bareScalarTdCopyOfFresh16 < bareScalarTdCopyOf < bareScalarTypedefVarTs <
  exportDesign`. That pass iterates `s.AllObjects()`, a hash map keyed by object ADDRESS, so the order of its copies
  follows the heap layout. The heap layout varies with slang's parallel parse. The pristine binary happens to land on
  one layout, and any added allocation (this patch records its writes even when a switch is off) can expose the
  latent order. This is a pre-existing determinism defect on this ground, ranked as residue 15. The pass leaves it
  unfixed because a fix moves bytes beyond this pass's movers. Byte claims about Earlgrey_0_1 need order-blind
  attribution, as for Scoreboard and SeqDriver.
