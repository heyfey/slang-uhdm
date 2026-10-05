# r11u242 — pass 242, the expression/parameter ground (implementer)

Base `6cd6f5ac` (matrix-1.87). Ground: `src/ParamEmit.cpp` and the new switch header `src/R242.h` (six laws; each
reads its own `R11U242_<LAW>_OFF`, `R11U242_OFF` drops all six and restores the pristine bytes; `R11U242_TRACE=<dir>`
writes `<dir>/<pid>.242`, first line `OUT <-o path>`, then one `<law> <detail>` line per firing, every branch traced,
the non-writing branches tagged `_noclone`, `_failed`, `_shape`, `_signed`, `_unresolved`). No file of the sister
ground (TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit, uhdm_main) is touched. The four slang-fenced tests are never
named here: every driver reads them from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`, fail-closed;
nothing fenced was dispatched outside the gate sweeps, decoded or opened (the census ran with a `--filter` built from
`$FENCED`; byteverify and the away census ran on mirrors / path lists filtered by `$FENCED` before any file was
opened).

## Verdict per targeted row (base -> this pass; fresh rows of the law sweep `/tmp/r11u242_wL`)

**FuncStructVal CONVERTS in both modes** (STRICT_NOTEQUAL `differ:depth(1)` -> CMP_EQUAL). Earlgrey_0_1 moves its first
record later in both modes with **0 golden-agreeing records lost** (chain-keyed away census 0).

```
FuncStructVal,default,CMP_EQUAL,,,equal
FuncStructVal,testflags,CMP_EQUAL,,,equal
Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(160),,differ:fullname(160)
Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(55),,differ:fullname(55)
```

| row-mode | base | after | what moved |
|---|---|---|---|
| FuncStructVal d | `differ:depth(1)` #7975 | **CMP_EQUAL / equal** (STRICT_EQUAL 18222 objects) | #7975 (map 15's N0891: golden lists the cast operation `1024'({64'b0, 64'b0})` 108:30-51 under typespec_member `NonIdempotentAddrBase` of the elaborated config_pkg's `cva6_cfg_t`, ours listed no value) cleared by § patLeftoverOpCopy242; the eight fullname records behind it (#17114 ..., the module copy `work@top.CVA6Cfg`'s operation reference: golden `<in>config_pkg::cva6_cfg_t.NonIdempotentAddrBase`, ours `cva6_config_pkg`) by § elabParamLeftoverOpRefUnnamed242 |
| FuncStructVal t | `differ:depth(1)` #14765 | **CMP_EQUAL / equal** (STRICT_EQUAL 45362 objects) | the same two laws, then #40014 (the `-elabuhdm` view: ours listed a constant `2` 539:33 under `cfg.NrRgprPorts`'s member where golden's leftover IS the body's own `$unsigned(2)` operand, already walked in the function body) cleared by § signCastLitLeftoverIsBodyOperand242 |
| Earlgrey_0_1 d | `differ:col(2)` #122230 / #130430 | `differ:fullname(160)` #136315 | #122230 (flash_phy_pkg.sv:43 `WordSelW` in flash_phy_core's definition listing: golden 43:53, ours 43:28) cleared by § impCondFlipTakenLeaf242; #130430 (hmac's `InitHash` import copy: golden `range` 26:35 under the array_typespec, ours a `ref_typespec`) cleared by § impArrParamTsOwnRanges242. The new head #136315 (`work@sha2.round`'s `$clog2(NumRound)` argument constant: golden ref_typespec `work@sha2`, ours unnamed) is **present in the pristine database** (its walk diverged before reaching it); chain away 0, toward 41 |
| Earlgrey_0_1 t | `differ:col(2)` #123704 / #131904 | `differ:fullname(55)` #137760 | the same two laws, the same pre-existing next face; chain away 0, toward 41 |

The grown counts on Earlgrey (2 -> 160 / 55 objects, first field col -> fullname) are a walk that diverges later: the
old first records are cleared ([evidence/heads.txt](evidence/heads.txt)) and the chain-keyed away census reads 0
golden-agreeing records lost on both modes (toward 41 per mode), the reversed census (law -> pristine) reading away 41
as its positive control.

### The base's records, reproduced (question 1)

```
FuncStructVal default (uhdm-strictcmp, pristine):
#7975 depth
  A: 6	operation				dut.sv	108	30	108	51		0
  B: 5	typespec_member	NonIdempotentLength			dut.sv	363	34	363	53
Earlgrey_0_1 default:
#122230 col
  A: 3	constant				flash_phy_pkg.sv	43	53	43	63	1	32	UINT:1	9
  B: 3	constant				flash_phy_pkg.sv	43	28	43	63	1	32	UINT:1	9
#130430 type
  A: 6	range				hmac_pkg.sv	26	35	26	36
  B: 6	ref_typespec			<in>		0	0	0	0		0
```

## The laws (all in ParamEmit; read each at its § token)

### § patLeftoverOpCopy242 (switch `R11U242_LEFTOPCOPY_OFF`; `stampEvalFuncLeftovers`, the § r10fsv2 L1 resolve loop)

FuncStructVal #7975 (map 15's N0891, brief item 2). Decoded with two object-identity helpers (`drivers/memids.cpp`,
`drivers/paramids.cpp`, both fence-checked): golden's elaborated `config_pkg::cva6_cfg_t` (#4148) carries
`NonIdempotentAddrBase`'s leftover as operation #9956 and the module copy (#10375) its own #10671, neither of them
the caller's listed pattern element; ours stamped the caller's ELABORATED pattern element object itself (#3040,
shared). The member value was there all along (uhdm-dump does not print it, the identity helper does), but the
strict walk had already met that object in `cva6_config_pkg::cva6_cfg`'s elaborated pattern, so under the stamped
struct it listed nothing. § patLeftoverOrphanCopy151 decoded the producer for a CONSTANT element (the element
ExprEval reads belongs to the operation CompileHelper::getValue expanded or clone_tree'd at the reference, which no
listing walks) and stamps a copy; an OPERATION element (§ r10fsv2 L4: a size cast over a concatenation wider than 64
bits stays a cast operation whose operand is one BIN constant) kept the share.

**Law**: an operation element is stamped as a field-for-field copy (cloneStampTree167, after its allocation-free
precheck stampTreeClonable167v), one copy per caller element per stamp (`_shared` re-uses it); a tree the precheck
rejects keeps the share (`_noclone`, fired nowhere), a failed clone too (`_failed`, fired nowhere).

### § elabParamLeftoverOpRefUnnamed242 (switch `R11U242_LEFTOPREF_OFF`; `leftRefFix174`)

FuncStructVal d #17114 and seven more (exposed by the first law). § elabParamLeftoverRefUnnamed174's rule on an
OPERATION leftover: a module-side parameter's struct copy holds its own copy of the operation whose reference stores
no name (golden `work@top.CVA6Cfg`: `<in>config_pkg::cva6_cfg_t.NonIdempotentAddrBase`, computed through the member;
the package listings keep `cva6_config_pkg`). **Law**: in the parameter's own struct copy, a § patLeftoverOpCopy242
copy whose reference stores a name (or whose parent is not the member) is cloned at the member with its reference
unnamed; it also makes § 174 give the parameter its copy when only such an operation needs it.

### § signCastLitLeftoverIsBodyOperand242 (switch `R11U242_SIGNCASTLIT_OFF`; the § pkgStructFuncAssembleBin resolution loop)

FuncStructVal t #40014. `cfg.NrRgprPorts = unsigned'(2)`: Surelog compiles the cast as `$unsigned(2)`, ExprEval's
reduce of that system call over a constant hands the argument constant back, and setValueInInstance stamps the BODY's
own `2` (golden #7093 at 539:33, parented at the sys_func_call #7094, in both views; in the `-elabuhdm` view the walk
meets the function body first and lists the constant only there). Ours stamped a minted constant with the same
fields. **Law**: for a non-pattern member whose body right side is `unsigned'(<integer literal>)`, the leftover is the
first argument of the emitted body right side (bodyAsgRhsObj, the elaborated view's object) when that is a constant;
another shape keeps the minted value (`_shape`, fired nowhere). `signed'(<literal>)` abstains (`_signed`): golden's
leftover there is a fresh constant typed by an unlocated logic_typespec (grid F/f07, stage 1 on both binaries).

### § impArrParamTsOwnRanges242 (switch `R11U242_IMPARRRANGE_OFF`; `emitParameters`, the unpacked-array parameter typespec)

Earlgrey #130430 / #131904. A module's materialized import copy of an unpacked-array package parameter is a
clone_tree of the package's listing entry, and clone_tree copies the parameter's vpiRange and the array_typespec's
vpiRange apart: golden `work@hmac.InitHash` holds range #95235 on the parameter and #95220 (parented at the
array_typespec) on its typespec, where each package listing shares one range between the two (#32686). Ours passed the
parameter's ranges into the copy's typespec, so a walk that had met the parameter's range listed none under the
typespec at its next reference (the param_assign's Lhs). **Law**: for `isImported && !inPackage` (a module or
interface definition listing's import copy), the array typespec's ranges are built fresh, with the parameter's own
dim naming (`dimPrefix9`) and the materialized-import dim shape (`elabParamDim`); the elaborated copies already built
their own.

### § impCondFlipTakenLeaf242 (switch `R11U242_IMPCONDFLIP_OFF`; the generic parameter fold, after `setLoc(rhs, rhsLoc)`)

Earlgrey #122230 / #123704. § modDefImportShape flips topView for an importer WITH a parameter port list (the
elaborated shape in the definition listing), so a ternary import copy (`WordSelW = WidthMultiple == 1 ? 1 :
LsbAddrBit`) reached the generic fold and kept the whole init's span; § impCondBranchFold anchors the unflipped
definition listing at the selected branch's leaf, and golden does the same under the flip (flash_phy_core, which has
`#(SkipInit)`: 43:53-63; flash_phy_rd / flash_phy_rd_buffers, which have none, already matched; the elaborated
copies keep 43:28-63). Reduced from the row's own package to grid T/t01 (judge-equal at the base, `col`).
**Law**: in the PHYSICAL definition view (`defViewOrig9`) under the flip, an imported ternary whose conditions fold is
relocated to its selected leaf (an arithmetic leaf at its left operand, as § impCondBranchFold); an unresolved chain
abstains (`_unresolved`, fired nowhere); an unlocated constant is left alone.

### § s2CloneGenScopeInst242 (switch `R11U242_S2CLONEGEN_OFF`; § evalFuncBodyRhsStampClone167's walk)

Found by grid F/f04 (exposed by § patLeftoverOpCopy242): an instance inside a generate scope holds its own struct copy
whose S2 clone names its path elements through the member (golden `<in>cp::cfg_t.z.n` at `work@top.m.g.u.C`), where
§ 167's walk never entered generate scopes and left the body operation (`cp::build::n`). **Law**: the walk recurses
through generate scopes (the recursion § 174's walk already makes). Fires nowhere in the corpora or the probe set.

## Binaries (frozen before any measurement; every cmds.txt audited by binary path)

| binary | md5 | note |
|---|---|---|
| pristine (`/tmp/r11u242_bin/pristine`) | `e8e74e7af71d0b248694123631d26dbe` | built at `6cd6f5ac` with the system-deps config (`-j 2`), identical to the main tree's `build/slang-uhdm`; reports slang 12.0.0+545f88b2e |
| law (`/tmp/r11u242_bin/law`) | `caf12314455901eaaa60b95ecb8ad333` | this patch (the worktree's build of the delivered sources) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the worktree's build of `tools/uhdm-strictcmp` |
| strictcmp_x | `886f030233ecdbcce7d0e29ac0c4df2c` | `drivers/strictcmp_x.cpp` (fence-checked), built by `drivers/cc_x.sh`, for the away census |

Development binaries `dev1`-`dev6` ran only on cases and on the four target rows (`dev1` carried a debug print,
removed); `dev7` is `law`. Every `cmds.txt` of the pristine sweep names `/tmp/r11u242_bin/pristine` only (3273 of
3273), of the law sweep `/tmp/r11u242_bin/law` only (3273 of 3273).

## Gates (from the worktree, SLANG_UHDM exported, `tests/sweep.sh --jobs 3`; [evidence/sweep_pristine.txt](evidence/sweep_pristine.txt), [evidence/sweep_law.txt](evidence/sweep_law.txt))

| stage | pristine sweep (`/tmp/r11u242_wP`) | law sweep (`/tmp/r11u242_wL`) |
|---|---|---|
| probe | EQUAL 3480 + STRICT_NOTEQUAL 607, 0 / 0 / 0 | EQUAL 3480 + 607: **regressions 0, conversions 0, changes 0** |
| surelog | 469 + 11 / 465 + 9, 0 / 0 / 0 | 470 + 10 / 466 + 8: **regressions 0, conversions 2 (FuncStructVal d/t), changes 2 (Earlgrey_0_1 d/t)** |
| uhdm2rtlil | 803 + 0 per mode, 0 / 0 / 0 | **0 / 0 / 0** |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 | **803 / 66 / 2 / 0, not excused 0, verdict diff 0** (the two csvs sorted and diffed: 0 lines) |

Both sweeps print `law index STALE` first (the base's committed `tests/LAWS.md` predates its own commit); the patch
carries the regenerated file. uhdm-cmp on every corpus mover reads 0 lines (36 of 36, rc 0,
[evidence/movers/uhdmcmp.txt](evidence/movers/uhdmcmp.txt)). Canary battery on the law csvs
([evidence/canaries.txt](evidence/canaries.txt)): `canaries.sh` surelog ok=48 changed=4 (FuncStructVal d/t, the
conversions; Earlgrey_0_1 d/t, the targeted change), unknown-names 7 (the u2r-only canaries); uhdm2rtlil ok=16
changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS (ok=58 changed=0), `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS
(ok=2 changed=0). `R11U242_OFF=1` with the law binary writes the pristine bytes on all 8 surelog mover row-modes
([evidence/movers/off_corpus.txt](evidence/movers/off_corpus.txt)).

## The mover prediction, frozen before the law sweep ([evidence/census/](evidence/census/))

`drivers/census.sh` ran `law` with `R11U242_TRACE` over both corpora in both modes (`--filter` built from `$FENCED`)
and every probe case, `drivers/dscensus.py` every downstream lane (the harness's translated command line);
`drivers/predict.py` names every database whose process fired a byte-writing branch: **55 predicted movers** (8
surelog row-modes, 28 uhdm2rtlil row-modes, 4 probe cases, 15 downstream lanes), frozen at 2026-10-05T02:27:56-04:00
(`frozen_at.txt`, md5 `e86bf38761500064b8560c7ed402f37a`) before the law sweep started. Firings
([census/firings.txt](evidence/census/firings.txt)): impArrParamTsOwnRanges242 201, patLeftoverOpCopy242 8,
elabParamLeftoverOpRefUnnamed242 8, impCondFlipTakenLeaf242 2, signCastLitLeftoverIsBodyOperand242 2,
s2CloneGenScopeInst242 0; no non-writing tag fired. The census's own csvs already read regressions 0 in all three
stages with the two conversions and two changes above.

**byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`, on hard-link mirrors of both sweeps without
the fenced paths, `drivers/bvmirror.sh`, same-length workdir names; [evidence/movers/byteverify.txt](evidence/movers/byteverify.txt)):
`PATH_SETS_IDENTICAL (2560 paths)`, **MOVERS: 36 / 2560**, every one predicted, none predicted and unmoved:
FuncStructVal d/t (the three leftover laws), Earlgrey_0_1 d/t (impCondFlip + impArrParamTsOwnRanges), DefaultPatternInt
d/t and Kmac d/t (impArrParamTsOwnRanges: an unpacked-array package parameter imported by a module; CMP_EQUAL before
and after), and 28 uhdm2rtlil row-modes (ibex_alu, ibex_branch_predict, ibex_compressed_decoder, ibex_decoder,
ibex_icache, ibex_multdiv_fast, ibex_multdiv_slow, ibex_pmp, ibex_tracer, ibex_wb_stage,
NestedStructArrayParameterInitializedByPatternPassedAsPort, StructArrayParameterInitializedByPatternPassedAsPort,
param_struct_field_bitsel, param_unpacked_struct_array, both modes; impArrParamTsOwnRanges; CMP_EQUAL before and
after). `SELFCHECK (every file vs one fixed file): 2559 / 2560 flagged` is the self-check reading correctly, not a
movers line: one side is replaced by one fixed file, and that file compared with itself is the one path the check
cannot flag. **Probe**: 4 of 4087 databases move, all predicted (r10uvm48repro/t67b and r11u114repro/grid/f3/c05,
STRICT_NOTEQUAL with the same detail in both sweeps; r11u10repro/grid/h9_1e1m_port and hD_1e1mvec, EQUAL in both;
all impArrParamTsOwnRanges). **Downstream lanes**: 15 of 805 slang-lane databases differ, exactly the 15 predicted
(the ibex lanes including ibex_controller, the two struct-array pattern lanes, param_struct_field_bitsel,
param_unpacked_struct_array), every verdict IDENTICAL in both sweeps (positive control: two different lanes compared
read as differing). [evidence/movers/probe_downstream_movers.txt](evidence/movers/probe_downstream_movers.txt).

## Away-moved-record census (map 13's chain-keyed census, `drivers/awayrows.py` with strictcmp_x; [evidence/movers/away.txt](evidence/movers/away.txt))

Over the 40 databases that differ between the pristine and the law sweeps: **chain-keyed away 0 and flat away 0 on
every one**; toward 296 / 280 (FuncStructVal d/t), 41 per mode (Earlgrey_0_1), 0 elsewhere (the range ownership moves
object identity only: the walk's record multiset is unchanged on the 34 impArrParamTsOwnRanges-only movers). Positive
control ([evidence/movers/away_reversed_control.txt](evidence/movers/away_reversed_control.txt)): the same census with
the sweeps swapped reads away 296 / 280 / 41 / 41 on those rows.

## Determinism ([evidence/det_law.txt](evidence/det_law.txt))

`drivers/det.sh` (three concurrent harness runs on Earlgrey_0_1 and the five UVM rows, both modes, `--jobs 2` each)
with the law binary: **one hash per row-mode on all 11** (Scoreboard testflags writes no database at the base), each
equal to the law sweep's database (Earlgrey_0_1 d `99040b3db63c`, t `233bf5448585`; the UVM rows' hashes are pass
240's, no law of this pass fires there).

## Grid (cases/, 21 cases, both views; `drivers/grid.sh`, `drivers/gridsum.py`; [evidence/grid.txt](evidence/grid.txt), [evidence/grid_summary.md](evidence/grid_summary.md))

378 runs (pristine, law, law with `R11U242_OFF`, the law with each of the six switches; default and `-elabuhdm`
views), **every exit code 0**. `R11U242_OFF` writes the pristine bytes on 42 of 42 case-views; each switch alone
reverts exactly its own law's cases (LEFTOPCOPY 16, LEFTOPREF 16, SIGNCASTLIT 6, IMPARRRANGE 12, IMPCONDFLIP 14,
S2CLONEGEN 2 case-views). Every case-view moves bytes; **20 enter STRICT_EQUAL, none leaves**; no uhdm-cmp line count
changes on any stage-1 case-view.

| case | law | shape | pristine -> law (default / `-elabuhdm`) |
|---|---|---|---|
| F/f01 | § patLeftoverOpCopy242 (+ § elabParamLeftoverOpRefUnnamed242) | FuncStructVal's shape: wide cast members `1024'({..})`, an unassembled struct (an unreduced member read, § r10fsv3 S2), a module header parameter | depth -> STRICT_EQUAL / depth -> STRICT_EQUAL |
| F/f02 | § signCastLitLeftoverIsBodyOperand242 | f01 + `r.k = unsigned'(2)` | depth -> STRICT_EQUAL / depth -> STRICT_EQUAL (the elaborated view needs the law: with `R11U242_SIGNCASTLIT_OFF` it reads depth) |
| F/f03 | § patLeftoverOpCopy242 | controls beside the law: a cast concatenation that fits 64 bits (folds), a replication member, an unsized literal | depth -> STRICT_EQUAL / depth -> STRICT_EQUAL |
| F/f04 | § s2CloneGenScopeInst242 (+ § patLeftoverOpCopy242) | the holder at depth 2 inside a generate block | depth -> STRICT_EQUAL / depth -> STRICT_EQUAL (before § s2CloneGenScopeInst242 the law alone read fullname: the gen-scope S2 clone) |
| F/f05 | § elabParamLeftoverOpRefUnnamed242 | two instances of the holder | depth -> STRICT_EQUAL / depth -> STRICT_EQUAL |
| F/f06 | § patLeftoverOpCopy242 | a PACKAGE holder (`localparam B = build(U)`) imported by a module | stage 1 both (82 lines, unchanged: the module's import copy of the folded struct value) |
| F/f07 | § signCastLitLeftoverIsBodyOperand242 | residue: `signed'(3)` on an `int signed` member (the law abstains) | stage 1 both (15 lines, unchanged) |
| F/f08 | § patLeftoverOpCopy242 | residue: an INTERFACE instance holding the struct parameter | stage 1 both (43 lines, unchanged: golden stamps the interface parameter's copy, ours stamps no interface) |
| R/r01 | § impArrParamTsOwnRanges242 | Earlgrey's InitHash shape: an array of a vector typedef imported by two modules, one instantiating the other | type -> fullname (a pre-existing face: the elaborated child's cont_assign names) / type -> STRICT_EQUAL |
| R/r02 | § impArrParamTsOwnRanges242 | 2-D array, an ascending range bound by a package localparam | stage 1 both (304 lines, unchanged) |
| R/r03 | § impArrParamTsOwnRanges242 | an importer with a parameter port list, an interface importer | stage 1 (17) unchanged / type -> STRICT_EQUAL |
| R/r04 | § impArrParamTsOwnRanges242 | control: a package importing the array (no law) beside a module importing both | stage 1 both (184 lines, unchanged) |
| R/r05 | § impArrParamTsOwnRanges242 | a struct-element array, a module-local array (no law), the imported array in a part-select width and a replication count | col both (pre-existing `bit_select` span faces), bytes move |
| R/r06 | § impArrParamTsOwnRanges242 | the importer at depth 2 in a generate for, two parameterisations | STRICT_EQUAL both, bytes move |
| T/t01 | § impCondFlipTakenLeaf242 | Earlgrey's WordSelW shape, read in an indexed part-select width | col -> STRICT_EQUAL / col -> STRICT_EQUAL |
| T/t02 | § impCondFlipTakenLeaf242 | condition true (left branch), a literal leaf and a parameter leaf | col -> STRICT_EQUAL / col -> STRICT_EQUAL |
| T/t03 | § impCondFlipTakenLeaf242 | arithmetic leaves `LB - 1`, `LB + 1`, `(LB) * 2` | stage 1 both (64 lines, unchanged: the `-` leaf's INT encoding in the package's elaborated listing, a value face) |
| T/t04 | § impCondFlipTakenLeaf242 | a nested ternary, a system-call leaf | stage 1 both (36 lines, unchanged) |
| T/t05 | § impCondFlipTakenLeaf242 | control: importers with and without a parameter port list side by side | col -> STRICT_EQUAL / col -> STRICT_EQUAL |
| T/t06 | § impCondFlipTakenLeaf242 | the importer at depth 2 in a generate block, the parameter in a replication count, a dimension bound and a generate-for bound | col -> STRICT_EQUAL / col -> STRICT_EQUAL |
| T/t07 | § impCondFlipTakenLeaf242 | a module-local ternary localparam (no law) and an interface importer | stage 1 both (60 / 64 lines, unchanged) |

## Process notes

- Every command ran from the worktree `/tmp/wt_r11u242` (base `6cd6f5ac`); scratch under `/tmp/r11u242_*`; the main
  checkout was never written. No submodule was initialised in the worktree. No process of another agent was listed or
  signalled; this pass killed nothing.
- **Fence**: the fence names were read into a variable only (never printed); every corpus row this pass opened
  (FuncStructVal, Earlgrey_0_1, BlackBePipeInt, Rggen) was checked against `$FENCED` first; the census, mirrors and
  away census filter by `$FENCED` before any file is opened. The producer (`$SURELOG`) ran only on this pass's own
  case files (case.sh).
- Every tool reached through a variable was guarded (`[ -x ]` in env.sh / case.sh and before every uhdm-dump and
  uhdm-cmp call); no database was executed.
- The grid's F cases were rewritten after their first runs: the first versions read members of the built struct in
  continuous assignments or let the struct assemble, which is stage 1 at the base on other faces (the folded member
  read, the assembled BIN value); the final files hold FuncStructVal's shape (no member read, an S2 member keeps the
  struct unassembled). The interface holder moved to F/f08 and the `signed'` cast to F/f07 as residues. Every grid
  number is the final files'. The law § signCastLitLeftoverIsBodyOperand242 was narrowed to `unsigned'` after F/f07
  (dev6), and § s2CloneGenScopeInst242 added after F/f04 (dev7 = law); the census and both sweeps ran on `law` only.
  F/f04's first comment line was re-pointed at § s2CloneGenScopeInst242 after the grid (the law index attributes a
  case by its first line); its 18 grid runs were repeated on the edited file with identical verdicts and md5s.

## Drivers (`drivers/`; every one reads `$FENCED` fail-closed, compiled helpers included)

`env.sh`, `case.sh`, `grid.sh` (the grid; `LAWBIN` overrides the law binary), `gridsum.py`, `census.sh`,
`dscensus.py`, `predict.py` (non-writing trace tags listed apart), `bvmirror.sh`, `det.sh`, `awayrows.py`,
`strictcmp_x.cpp` + `cc_x.sh` (copied from r11u240repro, switches and trace names updated); new: `memids.cpp`
(`memids <db> <struct name> <member>`: every struct_typespec of that name with its parent and the member's
Actual_value / Default_value kind, id, location and parent) and `paramids.cpp` (`paramids <db> <param name>`: every
parameter with its ranges' ids and its typespec's ranges' ids), the identity readers that decoded #7975 and #130430
(uhdm-dump prints neither ids nor a member's value). Build either with the `cc_x.sh` command line on its file.

## Sister-ground faces and decodes not written (call sites)

1. **Rggen d #23546** (brief item 2): decoded, not written. The elaborated `SUB_N_LIST = get_sub_n_list(N)` argument
   constant (N folded to 25): golden types it with N's own int_typespec (rggen_or_reducer.sv 3:13) in the DEFAULT view
   and with the formal's (8:55) in the `-elabuhdm` view; ours uses the formal's in both. Reproduced in a 19-line
   shape (a module with `parameter int N`, a module function `f(int n)`, `localparam bit [N-1:0][15:0] L = f(N);`,
   an instance with `.N(25)`): default view STRICT_NOTEQUAL `line` (golden 3:13, ours 8:49), `-elabuhdm` view
   STRICT_EQUAL. No pass switch of any landed law changes it (a sweep of all 165 master `R11U*_OFF` switches on the
   shape: only R11U200_OFF / R11U202_OFF move the head, to an earlier endcol face), so the stamp is a base rule of
   ExprEmit's call-argument emission (the formal-typespec binding of a folded parameter actual; § nestedParamActualTs6
   names the Rggen shape and its "golden leaves the elaborated get_sub_n_list(N) bare" note predates the view split).
   The law: in the default view, a parameter actual of an elaboration-time call keeps the parameter's typespec.
2. **BlackBePipeInt d #38807 / t #38803** (brief item 1): not attempted beyond reproduction; the records are pass 240's
   (bp_be_pkg's re-listed copy of `dev_addr_width_gp`, ParamEmit `stampParenCastWidthTs`, § parenCastWidthRefPkgBare207:
   golden binds the paren-cast width reference to an unlisted `bp_common_pkg::dev_addr_width_gp` copy whose int_typespec
   has no cast reference in the default view, the module copy in the elaborated view). Unchanged by this pass (bytes
   unchanged: no law fires on the row).
3. **Earlgrey_0_1's next faces** (after this pass, in walk order): #136315 the `$clog2(NumRound)` argument constant's
   ref_typespec in sha2's definition listing (golden `work@sha2`, ours unnamed: N0131's family, ExprEmit emitExpr);
   #142988 a generate-scope `hw2reg.key[7 - i].d.key` bit_select span (golden 133:19-27, ours 133:23-26); #154375 /
   #165002 ref_typespec full names through a port (`if_stage_i.pmp_req_err`, ours `if_stage_i.instr_pmp_err_i.
   pmp_req_err`); 160 objects in all (129 fullname, 10 line, 10 name, 6 endcol, 3 file, 1 col, 1 depth).
4. The UVM first records (SimpleUVM #75684 TypeEmit thisImplicitNetBoth38; BuildUVMPkg #81218 / Scoreboard #80496 the
   class body writers; MiniAmiq / SeqDriver the TaskFuncEmit associative-array names) are the live sister's: no law of
   this pass fires there (census), bytes unchanged.

## Residues, ranked (ground A first)

1. Rggen d #23546 (decoded above, ExprEmit call-argument typespec, view-dependent) and its 202 objects behind.
2. Earlgrey_0_1 d/t: 160 / 55 objects (item 3 above), N0131's family first.
3. BlackBePipeInt d/t #38807 / #38803 then map 15's N0028, N0118, N0873 (not attempted).
4. Grid residues: F/f07 (`signed'(<literal>)` leftover: golden a fresh constant with an unlocated logic_typespec),
   F/f08 (an interface holding the built struct parameter: golden stamps the interface parameter's struct copy),
   F/f06 (a package holder's struct value re-listed in an importing module), T/t03 (the `-` leaf's INT encoding in the
   package's elaborated listing), T/t04, R/r02, R/r04 (stage 1 on other faces).
5. The brief's items (3), (4), (5), (6), (7): not attempted.
