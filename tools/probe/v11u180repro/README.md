# v11u180: adversarial verification of r11u180 (the module/type ground, pair B): ACCEPT-WITH-FIX, one break of § modAggTfArgCloneFollows180 refined by § modAggCloneOwnDefOnly180v and § modAggCloneTakesFile180v, the enum parent of § enumImportParentLastWriter180 refined by § enumImpDefOwner180v

Base `804e3b75` (branch matrix-1.87). Verified: the implementer's patch `/tmp/r11u180.patch` (md5
`bacdcbcb021ccdf42cf7bc120315343a`: nine laws and one switch split in `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`,
`src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp`, `tools/probe/r11u180repro/`, `tests/LAWS.md`). The verified patch adds
three refinements in `src/TypeEmit.cpp` and `src/ModuleEmit.cpp` (one declaration and one call in
`src/UhdmExporter.cpp`), all on the implementer's own ground, and this directory. Nothing under `results/`,
`tests/probe/`, `third_party/` or the sister's files (`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`,
`src/ParamEmit.cpp`) is edited; `tests/LAWS.md` is regenerated.

The slang-fenced tests are written `FENCED=` here and never spelled. `drivers/env.sh` reads `$FENCED` from the
`FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed; `drivers/case.sh`, `drivers/dscase.sh`,
`drivers/attrib.sh` refuse a fenced path or name by word boundary, `drivers/bvmirror.sh` hard-links the corpus
databases into fence-clean mirrors (8 fenced row-mode databases left out). No fenced test was run, read or decoded
outside the gate sweeps, which dispatch every row themselves. gdb was not used. A grep of this directory for the four
names reads 0.

## 1. Binaries (fresh worktrees at `804e3b75`, `-j 2`, system deps; frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `daefc86815272ea28a026d6a4741115f` | pristine worktree build = the base md5 of the brief (= the implementer's `pris.bin`) |
| `law.bin` | `53c9f6116e2519503a607f7323369eb3` | the implementer's patch as delivered (= its `final2.bin`) |
| `fix2.bin` | `9abdabb46f5d4f3d44d323a6f277ad69` | + § modAggCloneOwnDefOnly180v + § modAggCloneTakesFile180v |
| `fix4.bin` | `b2f04b167855285280a34bd0367e5661` | + § enumImpDefOwner180v, the declaration record gated on its law's switch: **the verified patch** |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `predict180x` | (built by the patch's `drivers/cc180.sh` from its `drivers/predict180.cpp`) | the implementer's predictor |

(`fix1.bin`, the first build of the declaration key, keyed on the typedef NAME, which is still empty when the
listing is located, so it never declined; it was never swept. `fix3.bin` = `fix4.bin` without the switch gate on the
record, byte-identical output on every case.) The main tree's `build/slang-uhdm` was rebuilt by the master during
this pass (it read `d0519110…`, the sister's integration); every measurement here uses the frozen copies above.

Four full gate sweeps (`drivers/sweep.sh`, `tests/sweep.sh --jobs 3`, all four stages, same-length workdirs):
`/tmp/v11u180_swP` (pris), `swL` (law), `swF` (fix2), `swX` (fix4). Every sweep's corpus `cmds.txt` names its own
binary on all 3273 `slang:` lines (`evidence/cmds_audit.txt`).

## 2. The implementer's headline numbers, reproduced bit for bit (`swL` vs `swP`)

| claim | reproduced |
|---|---|
| pristine = baselines | `swP/probe.csv` byte-identical to `results/golden_probe.csv`; regressions=0 conversions=0 changes=0 in both corpora; `downstream.csv` byte-identical to `results/downstream_uhdm2rtlil.csv`; rc=0 |
| probe | regressions=0 conversions=9 changes=6, EQUAL 2880 -> 2889, STRICT_NOTEQUAL 1198: the same nine CONVERSION and six CHANGE lines (`evidence/sweep_swL_summary.txt`) |
| surelog | regressions=0 conversions=2 (PackedArrayHighConn d/t) changes=5 (ArrayMethodIterator d/t name(6)/name(16) -> endcol(1), Earlgrey_0_1 d/t fullname(436) -> col(102), Rggen d fullname(7) -> endcol(634)) |
| uhdm2rtlil | regressions=0 conversions=2 (mem_read_reg d/t) changes=4 (const_cast_signext d/t line(5) -> type(1), struct_param_func_config d/t line(8) -> fullname(5)) |
| downstream | IDENTICAL=803 SLANG_REJECT=66 EQUIVALENT=2, not excused 0; `downstream.csv` byte-identical to the pristine sweep's |
| byteverify | 22 corpus movers of 2560 (SELFCHECK 2559/2560, `fenced_skipped=8`), exactly the implementer's 22; 17 probe movers, exactly its 17 (`evidence/byteverify_L_vs_P.txt`, `evidence/probe_movers_L_vs_P.txt`) |
| prediction | `predict180x` over my pristine databases: 6647 listed, 67 predicted, the same 67 names as the implementer's `evidence/predict180_pristine.txt`; all 39 movers predicted |
| canaries | surelog ok=50 changed=2 (Earlgrey_0_1 d/t), uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` PASS (ok=58), `EXPECT_UNKNOWN=6 ctcan2.sh` PASS (ok=2) |
| grid | the 83 cases of `r11u180repro/cases`: `R11U180_OFF=1` byte-identical to pristine on 83 of 83; each law switch moves only its own grid (`evidence/switches.txt`); `R11U180_AGGSWITCH_OFF` moves none |
| Earlgrey subset | default: 102 records, first `#26470 col`, every one present with identical content among the pristine 436 (first `#25840 fullname`); testflags the same (#27073 in #26443's 436) (`evidence/earlgrey/`) |
| Rggen walk | pristine's seven records (#111-#469, #469 `depth`) are all gone; the law's first record is `#2063 endcol` (an array_typespec end column the pristine walk never reached) and the walk diverges at `#23166 type`; the order-blind pristine-vs-law dump diff is 18 lines, all the enum parent and its three base-ref names (`evidence/rggen/`) |
| UVM distances | order-blind totals pris -> law: MiniAmiq 27041/27043 -> 26779/26779, SeqDriver 20011/20009 -> 19747, SimpleUVM 7392 -> 7128, Scoreboard 6014 -> 5750, BuildUVMPkg 3657 -> 3353, ApbSlave 12, SVSwitch 108 unchanged (within the known two-record coin of the implementer's figures, `evidence/uvmdist_P_X.txt`) |
| Earlgrey byte coin | re-run 3x concurrently each: `pris.bin` one hash 3/3 (= swP's), `fix4.bin` two hashes (2 + 1), `fix4.bin` with `R11U180_OFF=1` one hash 3/3 that is NOT pristine's (`864c6bb2…`, the implementer's third hash), and the two `fix4.bin` hashes, each pair order-only (12 raw dump lines, 0 once sorted): the claim stands; `Serializer::AllObjects()` is a `std::map<const BaseClass*, uint32_t>` (address order), iterated by `bareScalarTypedefVarTs` |

## 3. The breaks, and the refinements (each under its own switch; `R11V180_OFF` drops all three)

### 3.1 § modAggCloneOwnDefOnly180v (`R11V180_MODAGGDEF_OFF`) — a header typedef in two definitions (TypeEmit.cpp)

**Break (pristine right -> patched wrong on legal SV).** § modAggTfArgCloneFollows180's drain keys a module typedef's
clones on (kind, name, file, declaration span), and a module typedef is named without its module (`op_t`). A header
`include`d into two modules puts two declarations at one key, so the formal writer of ONE module moved the other
module's objects. `cases/M/m01` (`td.svh` in `amod` and `bmod`, only `amod` has `function f(input op_t x)`):
pristine `STRICT_NOTEQUAL type(1)` (the sister's constant-call fold only), law `line(5)`: `#87 struct_typespec op_t`
golden `td.svh 1:9-4:2`, law `td.svh 5:42-5:46` (bmod's), `#110` the same. `m03` (the writer module second in the file)
identically.

**Refinement.** Every module / interface struct and union typedef declaration is recorded at its listing site with
its typedef declaration syntax; a move whose declaration key (file and span) holds TWO different declarations
declines (Surelog moves one DesignComponent's TypeDef object; each definition compiles the header text into its own).
m01, m03 return to the pristine bytes (`9f1404a0`, `98f785d7`).

### 3.2 § modAggCloneTakesFile180v (`R11V180_MODAGGFILE_OFF`) — the clones take the moved file (TypeEmit.cpp)

The drain copied the moved span's line and columns but not its FILE. With the typedef in an included header and the
formal in the main file (`cases/M/m04`), golden's clones read `dut.sv 5:42-5:46`; the law wrote `td.svh 5:42-5:46`.
The clones now take the listing object's file (the formal's, which § tdMoveCarriesFile172 set before the drain):
m04 `file(3)` (pristine and law) -> `type(1)` (the sister's constant-call fold only); m05 (two parameterizations)
stage 1 on all binaries with the same head.

### 3.3 § enumImpDefOwner180v (`R11V180_ENUMDEF_OFF`) — the enum's parent is the definition (ModuleEmit.cpp)

**Not judged, but wrong against golden.** `emitInstance` runs `emitImportArtifacts` on every ELABORATED module
instance too, so the winner's last recorded write is often an instance, and the drain parented the shared package
enum at it: `cases/H/h01` (PackedArrayHighConn's text) `work@prim_pad_wrapper (work@dut.u_dio_pad)`, h10, h20,
`cases/E/e01`, e11, e12; the corpus rows PackedArrayHighConn d/t (1 object), Rggen d (3), Earlgrey_0_1 d/t (51).
Golden's writer is `writeModule` / `writeInterface` on the definition: `work@prim_pad_wrapper (work@prim_pad_wrapper)`.
uhdm-cmp and uhdm-strictcmp never read a typespec's vpiParent, so no status or strict cell moves; the full names the
law writes were already right. Pristine was wrong too (another module), so this is not a regression; it is fixed
because the law's own statement says "the alphabetically last importing module DEFINITION".

**Refinement.** When the drain moves the object to ANOTHER definition, it takes that definition's own object (design
`AllModules` / `AllInterfaces`, by definition name); a parent that already belongs to the winning definition is left.
Enum parents (`drivers/enumpar.sh`, every enum_typespec parented by a module, interface, program or package) now equal
golden's in all 16 law-firing cases (e01, e11, e12, h01, h03, h08-h10, h12, h14, h15, h17, h18, h20, h21, h23), in
none of them worse; the other cases are unchanged (e03-e07, e09, e10, h25, h26 read golden's package parent where
ours lists none, identically on pristine: residue V2).

## 4. Gates of the verified patch (`swX`, `fix4.bin`)

| gate | result |
|---|---|
| (1) build | pris `daefc868…`, law `53c9f611…`, verified `b2f04b16…`; the verified patch applied on a fresh `804e3b75` worktree builds the same md5 |
| (2) probe | regressions=0 conversions=9 changes=6, EQUAL 2889 STRICT_NOTEQUAL 1198; `probe.csv` byte-identical to `swL`'s |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 2 + 2, changes 5 + 4: the same CONVERSION and CHANGE lines as `swL`; `uhdm2rtlil.csv` byte-identical to `swL`'s, `surelog.csv` differs only in the two LowMem detail texts (work directory) |
| (4) downstream | IDENTICAL=803 SLANG_REJECT=66 EQUIVALENT=2, not excused 0; `downstream.csv` byte-identical to the pristine sweep's; `mem_read_reg,IDENTICAL,OK,OK,1789,1789,,` |
| (5) uhdm-cmp | every mover judge-equal as at the base (0 regressions in all three stages) |
| (6) byteverify vs pristine | the same 22 corpus movers and 17 probe movers as the law (`evidence/byteverify_X_vs_P.txt`) |
| byteverify vs `fix2` | 9 corpus movers: PackedArrayHighConn d/t, Rggen d, Earlgrey_0_1 d/t (predicted: the ENUMIMP rows, trace `ENUMDEF:1/1/5/67/67`, `evidence/attrib_enumdef_corpus.txt`; order-blind exactly 2/2/6/102/102 lines, all enum-parent lines moving from an instance to the definition) + MiniAmiq d/t, SeqDriver d/t (the 4-line `UINT` / `vpiDecompile` coin); 5 probe movers, the five ENUMIMP cases (`evidence/orderblind_final_vs_fix2.txt`) |
| byteverify `fix2` vs law | 5 corpus movers, all coins: MiniAmiq d/t, SeqDriver d/t (4 lines each), Scoreboard d (92 raw lines, 0 sorted); 0 probe movers (`evidence/byteverify_F_vs_L.txt`) |
| canaries | surelog ok=50 changed=2 (Earlgrey d/t, the attributed change), uhdm2rtlil ok=16 changed=0; both ctcan2 PASS |
| law index | `python3 scripts/law_index.py --check`: current |

Cases: 131 (the implementer's 83 + 48 here), `evidence/grid_pris_vs_final.txt`: pristine -> verified 55 better
(to STRICT_EQUAL or a later first field), 69 same verdict, 0 worse, 7 a different first field toward golden (the
walk now reaches the sister's constant-call fold `type` or the sister's `endcol`: IMPL a01, t11, u03, u04, M/m04,
P/p05, P/p07). `R11U180_OFF=1`: pristine bytes on 131 of 131. Every switch alone moves only its own law's cases
(`evidence/switches.txt`): ENUMIMP 18, ENUMIMPHDR 2, TPUSE 32, TPFORMAL 13, TPCHAIN 4, TPQUAL 5, MODAGGCLONE 6,
PKGAGGCLONE 10, IFACETDORDER 9, PORTINTREDECL 9, AGGSWITCH 0, ENUMDEF 16, MODAGGDEF 2, MODAGGFILE 2.
Downstream on 77 cases (`evidence/downstream_cases_pris_vs_final.txt`): 8 go to IDENTICAL (the implementer's R/r01,
r02, r04, r06 and this pass's R/r01-r04: DIVERGENT x6, EQUIVALENT, STATUS_DIFF), 65 IDENTICAL stay, 4 EQUIVALENT stay,
none moves away.

## 5. The attack grid (`cases/`, first line `// § <law>`)

* A § classTpDefaultTsAtUse180 / § classTpFormalMovesTs180 / § classTpChainRootShares180 / § classTpQualDefaultSpan180:
  a01 queue formal (TPFORMAL), a02 pure virtual prototype formal (TPFORMAL), a03 parameterized-class default
  (TPUSE; stage 1 both, same head), a04 default from an imported package (TPUSE), a05 task `ref` formal then a
  constructor formal with a default (TPFORMAL), a06 extern prototype last with an out-of-body definition (TPFORMAL),
  a07 qualified parameterized default with blanks (TPQUAL; stage 1 both, same head), a08 specialization in a module
  (TPUSE; stage 1 both, same head), a09 three-member chain with a middle formal (TPCHAIN), a10 forward-typedef default
  with block and foreach locals (TPUSE), a11 two interleaved parameters (TPUSE), a12 class inside a module (TPUSE;
  stage 1 both, same head), a13 a derived class re-declaring the parameter (TPUSE). 10 convert, 4 unchanged.
* E § enumImportParentLastWriter180 / § enumImpDefOwner180v: e01 file-scope import (fullname: first record
  #13 -> #221, a cast ref name in a port high connection), e02 program + interface, e03 case-differing module names,
  e04 re-export through a package, e05 parameterized importer twice, e06 interface named last, e07 explicit body import
  + a struct nesting the enum, e08 two interfaces only, e09 an uninstantiated importer, e10 a function-scoped import,
  e11 (§ enumImpDefOwner180v) the winner instantiated twice, e12 header imports nested two levels, e13 an interface
  and an uninstantiated last module. e11, e12 convert; none moves away.
* I § ifaceWildcardTdNameOrder180: i01 two packages whose names interleave, i02 case-differing names, i03 own typedef
  beside the import, i04 enum and structs. All stage 1 on both binaries with the same head (i03 prints our side's
  interface in the new order); the definition listings of i02, i03, i04 now equal golden's.
* M § modAggTfArgCloneFollows180 / § modAggCloneOwnDefOnly180v / § modAggCloneTakesFile180v: m01, m03 the break
  (3.1), m04, m05 the file (3.2), m06 an interface typedef moved by an interface function (converts).
* P § pkgAggTfArgCloneFollows180: p01, p02 one header in two packages (the package name keeps them apart: no
  firing, byte-identical), p03 a package class-method writer, p04 a module's qualified formal (both byte-identical),
  p05 a package writer plus a module's qualified writer (line(6) -> type(1)), p06 a task then a function formal
  (stage 1 both, same head), p07 a one-line typedef with the writer on its line (col(4) -> type(1)), p08 the writer
  from an included file (file(3) -> file(1)), p09 a second package's parameter of the moved typedef (converts).
* R § splitPortIntRedeclLogicTs180: r01 the integer declared before the port, r02 an instantiated child, r03 a
  parameterized module with a function, r04 `input a; wire a;` beside `output b; int b;`. All four convert from stage
  1, downstream DIVERGENT/EQUIVALENT/STATUS_DIFF -> IDENTICAL.

## 6. Residues (ranked; the implementer's section 7 list stands as written, with these additions)

1. **V1 — interface wildcard imports of two packages** (ModuleEmit.cpp `emitImportArtifacts`, the interface branch of
   § ifaceWildcardTdNameOrder180): Surelog's DataTypeMap is ONE `std::map` keyed by the bare name across every import
   and the interface's own typedefs (CompileHelper::importPackage inserts `type.first`), so golden `I/i01` lists
   `p1::a_t, p2::b_t, p1::c_t`; the law sorts per package (`a_t, c_t, b_t`; pristine `c_t, a_t, b_t`). Closer, not
   equal; stage 1 on all binaries.
2. **V2 — an enum typedef its importers cast to** (e03-e07, e09, e10, h25, h26): golden keeps one of its objects
   under the package where ours lists none; identical on pristine, not judged.
3. **V3 — a package typedef moved to a formal inside an `include`d file** (P/p08 `#199`): the listing reads
   golden's `1:43-1:46` but the main file where golden has `fn.svh` (§ tdMoveCarriesFile172's formal file,
   TypeEmit.cpp); pristine the same.
4. **V4 — E/e01 `#221`**: a cast's ref_typespec in a port high connection is named `work@top` where golden has
   `work@top.uz.i` (the cast branch, ExprEmit.cpp: the sister's ground).
5. The Earlgrey byte coin (implementer's residue 15) reproduced; `R11U180_OFF=1` restores pristine bytes on every
   case but not on Earlgrey_0_1 (address-ordered `AllObjects()` iteration in `bareScalarTypedefVarTs`).

## 7. Files

* `cases/{A,E,I,M,P,R}/`: 48 cases (M/m01, m03, m04, m05 and P/p08 carry a header).
* `drivers/`: `env.sh` (pins, the fence), `case.sh` (a case against the pinned Surelog, probe-harness arguments),
  `sweep.sh`, `dscase.sh` (the downstream gate's `one()`), `bvmirror.sh`, `attrib.sh` (trace a corpus row's recorded
  command), `enumpar.sh` (enum listing parents), `sw1.sh` (the per-switch byte table), `uvmdist.sh`.
* `evidence/`: the four sweep summaries, the cmds audit, byteverify outputs (L vs P, X vs P, X vs F, F vs L), the
  probe movers, the predictor output, the grid and switch tables, the downstream case table, the ENUMDEF corpus
  trace, the order-blind attribution of the final movers, the Rggen and Earlgrey strict records, the UVM distances.
