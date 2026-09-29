# r11u229: second adversarial verification of passes 224 and 225 and of r11u226's two fixes

Base `01dc93ab` (branch matrix-1.87): pass 224 and v11u224 landed at `ac0dda58` (expression/parameter ground), pass 225
and v11u225 at `1a30095a` (module/type ground), r11u226's two refinements at `01dc93ab`. While this pass ran the main
tree moved to `e0d6957c` (`a332e45b` removed the landed patch files under tools/probe, r11u226verify/fix.patch among
them, and `e0d6957c` regenerated the law index); neither is r11u227 or r11u228, whose worktrees were not touched. This
pass kept its base. Its patch adds files only, so it applies on `e0d6957c` too.

This pass measures only. No file under `src/`, `scripts/`, `tests/`, `results/` or `third_party/` is edited by this
directory. The one refinement it proves is in [fix.patch](fix.patch) (a diff against `01dc93ab`, not applied), behind
its own switch, `R11V229_OFF` dropping it, in a new header `src/R229.h`. Under the rule of `a332e45b` (a patch whose
content lands is not committed), fix.patch is delivered for integration and need not be committed with this
directory. No canonicalisation patch of `tools/uhdm-strictcmp` was handed to this pass and none was written: no
comparator defect was proven. A probe case is called a case. The four slang-fenced tests are never named here.

## 0. Verdict

* **No break in any law of the three landings.** 123 fresh cases in both views (246 case-views) were judged three
  ways: uhdm-cmp, uhdm-strictcmp record by record, and the downstream verdict.
  * From all three landings off (`R11U224_OFF R11U225_OFF R11V225_OFF R11V226_OFF`) to on: **88 case-views enter
    STRICT_EQUAL, 0 leave, 0 go from judge-equal to stage 1** (3 go from stage 1 to judge-equal: O/o03, o04, o06
    elaborated, by § initHierFillKept225), **every exit code 0 in every state** (1716 runs).
  * Every law scored against its own switch reads TOWARD, BYTES-ONLY, UNFIRED or a stage-1 distance: **0 AWAY, 0
    STAGE1-AWAY**; the eight MIXED readings (four cases, both views) are wrong-to-closer on the same object, checked
    field by field (section 4).
  * The away census over every state of every case-view: **chain-keyed 0 lost, 2557 toward**; the flat key's 92
    lost are all removed extras at chains golden does not hold them at; the reversed control reads 2557 lost.
  * Downstream on the fresh cases: **4 EQUIVALENT -> IDENTICAL, 0 leaving IDENTICAL**, every other netlist the same
    or closer.
* **The Scoreboard svunit listing-order coin is pinned and cured** (section 7). The coin flips the DESIGN's own
  vpiTaskFunc listing: [uvm_pkg's 894, svunit_pkg's 23] (golden's order) or the reverse. Its writer is
  `UhdmExporter::unitScopeWildcardImports` (ModuleEmit.cpp). It sorts the compilation-unit wildcard imports by
  `SourceLocation`, that is by BufferID. slang's driver assigns BufferIDs in the order its thread pool reads the
  source files, and the two imports sit in two files. **§ unitImportFileOrder229v** (`R11V229_UNITIMPORTORDER_OFF`)
  keeps the parse order instead: the order the collection loop already yields, the command line's.
  * Scoreboard default draws **one hash in 12 of 12 draws** with the refinement: the base binary's majority hash,
    L's own, golden's listing order. It draws 2 in 12 on the base binary (7 + 5) and 2 in 12 with the switch set (8 + 4).
  * The fix's gates read 0 / 0 / 0 in every stage, with every csv equal to the base's row for row.
  * The fix moves **0 of 7452 databases** against the base sweep, and 0 with `R11V229_OFF`.
  * The patch rebuilds the same md5 on a fresh `01dc93ab` worktree.
* **SimpleUVM's coin does not reproduce at the base.** It draws one hash per mode in 12 draws with the base binary and
  in 12 with `R11V226_IDORDER_OFF`. v11u225 saw it at `75a564b0` with identical dumps (a symbol-table order). At this base no
  second hash appears even with the id-order walk switched off, so there is no writer to pin and no fix to deliver.
* **§ fullNameDrainIdOrder226v holds.** Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM and BuildUVMPkg draw one hash
  per mode on the base binary. MiniAmiq draws 3 and 2 hashes with the switch set. Every row's uhdm-dump with the switch
  set is identical to the law's dump, unsorted.
* **Composition** (section 5): every conversion each landing claimed is its own. Pass 224 owns five probe cases (its
  sixth claim, BlackBePipeInt t `depth(1) -> type(1)`, is a CHANGE and its own too); pass 225 owns InterfArrayBind d and
  OutputSize d/t; r11u226 owns bytes only. **CANCEL is 0 at status level and 0 at byte level over 7452 databases.**
  Each landing's movers at HEAD lie inside its own frozen prediction. The cross-ground pairs compose (X/x01, x03, x06, x08).
* **The changes** (section 6): all eight CHANGE rows of the two integration sweeps are strict improvements (SUBSET) or,
  for BlackBePipeInt t, an unmasking past the base walk's divergence.
* **Away census over the full corpora, both keys**: pass 224 0 lost / 134 toward (the flat key's 13 are removed
  extras), pass 225 0 / 15 (raw 0 / 17), r11u226 0 / 0 (bytes only), all three 0 / 149. The reversed controls read
  the toward counts as lost.
* **Fence and process** (section 10): every driver of the six directories reads the fence itself or through its env.sh
  or a fenced caller, and every env.sh fails closed. No file names a fenced test. Among the four case drivers r11u226
  listed, and newly r11u224repro's and v11u224repro's case.sh, a driver runs `$SURELOG`, `$UHDM_CMP` and
  `$STRICT_CMP` with no executable check of its own. Neither of pass 225's two predictions has a time stamp. The only
  packaged case that repeats a corpus or tests/probe source is r11u225's OS/o01.

## 1. Binaries and states

| binary | md5 | what |
|---|---|---|
| `law.bin` | `22bb3dc75f6ad8cc89885b644dd07798` | `/tmp/wt_r11u229` at `01dc93ab`, system-deps config, `-j 2`: equal to the main tree's `build/slang-uhdm` |
| `fix.bin` | `7e50408d1da06eaece796ba1903c589f` | `01dc93ab` + [fix.patch](fix.patch) (md5 `8ff82576`), `/tmp/wt_r11u229fix`, `-j 2`; rebuilt from the patch on a fresh worktree (`/tmp/wt_r11u229rb`, `-j 1`, memory under 6 GB) to the same md5 |
| `fix_d1.bin` | `fb441e18e920e18acc6cc8f3a8be5a46` | a discarded draft (section 7.3) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the worktree's build, equal to the main tree's |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's raw-name variant (tools/probe/r11u222map/drivers/cc.sh), the md5 the earlier passes cite |

All frozen `chmod 555` in `/tmp/r11u229_bin` before any measurement. The switch map ([drivers/laws.py](drivers/laws.py),
read from the sources at `01dc93ab`):

| state | switches | drops |
|---|---|---|
| L (HEAD) | none | - |
| 224 off | `R11U224_OFF` | pass 224's eleven laws (`r11u224On`); the four § landingSwitchReach224 split switches are not read by it and change nothing by default |
| 225 off | `R11U225_OFF R11V225_OFF` | pass 225's four laws (`r11u225Law`) and v11u225's § fillSymbolicRootOnly225v (`r11v225Law`, which only restricts the fill law) |
| 226 off | `R11V226_OFF` | § tfArgScalarTdExportOwnTd226v and § fullNameDrainIdOrder226v (`r11v226Law`); the first is also dropped by `R11U223_OFF` |
| A (all off) | the four | the bytes of `4a620bd0` |

Gate sweeps (`tests/sweep.sh --jobs 3`, 15-character workdirs; every `slang:` line of all 3273 corpus `cmds.txt` of each
sweep names its own binary, [evidence/gates/cmds_binary_audit.txt](evidence/gates/cmds_binary_audit.txt)): L
`/tmp/r11u229_wL`, A `_wA`, 224 off `_w4`, 225 off `_w5`, 226 off `_w6`, the fix's census `_wC` (with the trace), the
fix `_wF`, the fix under `R11V229_OFF` `_wO`. Summaries: [evidence/gates/sweeps.txt](evidence/gates/sweeps.txt).

**L reproduces the integration of r11u226.** Its probe, uhdm2rtlil and downstream csvs are byte-identical to
`/tmp/intr11u226`'s. Its surelog csv differs only in the LowMemLib detail text, which names the workdir.

## 2. The gates of the base and of the fix

| gate | L (law.bin) | fix.bin |
|---|---|---|
| probe vs golden_probe.csv | EQUAL 3453 + STRICT_NOTEQUAL 634, **0 / 0 / 0** | 3453 + 634, **0 / 0 / 0** |
| surelog vs golden_surelog.csv | 930 CMP_EQUAL + 24 STRICT_NOTEQUAL, **0 / 0 / 0** | **0 / 0 / 0** |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 1602 + 4, **0 / 0 / 0** | **0 / 0 / 0** |
| downstream | **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT** | **803 / 66 / 2 / 0**; the four csvs equal L's row for row (status and strict) |

* Every sweep exits 1 on `law index STALE` alone. A clean `01dc93ab` worktree reads the same (checked in
  `/tmp/wt_r11u229chk`, removed after): the index records each law's landing commit.
* **Canaries** on L and on the fix ([evidence/gates/](evidence/gates/)): canaries.sh surelog ok=52 changed=0,
  uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS, `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS.
* **The fix's movers, predicted before its sweep.** The census sweep `_wC` ran fix.bin with `R11V229_TRACE`
  ([drivers/census.sh](drivers/census.sh)). [drivers/predict.py](drivers/predict.py) reduced its traces to
  [evidence/census/prediction_fix.txt](evidence/census/prediction_fix.txt): md5 `3c613f7b`, written 07:52:49 (-0400),
  and stamped 07:52:59 with fix.bin's md5 in [prediction_fix.stamp](evidence/census/prediction_fix.stamp). The gate
  sweep `_wF` was launched after the stamp, in the same shell sequence.
  * The prediction names **4 possible movers**: Scoreboard default (`MOVED` in the census draw) and three probe cases
    whose two imports share one file (`same`: r10uvm206repro/g206_e_two, r10v146repro/v11_unref,
    r10v206repro/x206_a_dropwithmove).
  * No fenced row and no downstream lane fired.
  * The sweep's movers against L: **byteverify 0 / 2560** (PATH_SETS_IDENTICAL, SELFCHECK 2559 / 2560, on hard-link
    mirrors without the 8 fenced row-mode databases, [drivers/bvmirror.sh](drivers/bvmirror.sh)), **probe 0 / 4087**,
    **downstream lanes 0 / 805** ([evidence/fix/](evidence/fix/)).
  * L's own Scoreboard draw already held golden's order, so the fix writes L's bytes there.
* **The switch**: the fix under `R11V229_OFF=1` (`_wO`) reads 0 / 0 / 0 in every stage and writes L's bytes on
  2560 / 2560 corpus and 4087 / 4087 probe databases (its Scoreboard draw fell on the majority side too).
* **The fix's reach on cases** ([evidence/fix/firecases.txt](evidence/fix/firecases.txt), [drivers/firecases.sh](drivers/firecases.sh)).
  Every case directory of r11u224repro, v11u224repro, r11u225repro, v11u225repro, r11u226verify and this directory
  ran in both views with the trace: 574 directories, 1148 case-views.
  * The refinement sees two or more compilation-unit imports only in r11u226's U/u02 (both views, one file, `same`).
    There law and fix write identical bytes.
  * With fewer than two imports the refinement changes nothing.

## 3. The fresh cases (cases/, 123 cases, 246 case-views)

Every case names its laws on its first line. Goldens are the pinned Surelog's with the probe arguments (both views:
the parse view and `-elabuhdm` / `--elabuhdm`), built into `/tmp/r11u229_g` ([drivers/case.sh](drivers/case.sh)).
[drivers/grid.py](drivers/grid.py) (r11u226's, with this pass's switch map) runs each case-view in a set of states and
scores each state against ON: the law binary with no switch; with each named law's switches; with each landing's
switch; with every pair of named laws for the X cases; all three landings off (ALLOFF); and ALLOFF plus
`R11U220_OFF R11U223_OFF` (WIDE). The verdicts:

* TOWARD: records lost, none new.
* AWAY: a new record on an aligned walk.
* UNMASK, BYTES-ONLY.
* When either side is stage 1: the order-blind uhdm-dump distance to golden, with the weaklyReferenced tail cut.

| family | law(s) | cases and the shapes (none in the grids of r11u224repro, v11u224repro, r11u225repro, v11u225repro or r11u226verify) |
|---|---|---|
| S | § strLitPpEscIdShift224 | s01 three backslashes in one escaped identifier (`\n\t\v `: +4 where +2 per backslash reads +6); s02 an escape at the body's end with no blank; s03 a tab then a blank after the escape; s04 `W` inside the run after other letters; s05 `$` in the run; s06 the first element of a localparam string-array pattern; s07 named arguments; s08 an instance port connection; s09 a net declaration list; s10 a declined literal (a `//` in the body) then an accepted one on one line; s11 `$display` with arguments after; s12 a package class method with a call after on the line; s13 a `while` condition and body on one line; s14 an included header with two declarations on the line; s15 CRLF; s16 a double backtick and blank after the identifier; s17 nonblocking assignments; s18 two identifiers split by a backtick, then a third after a blank run |
| K | § strLitContOwnerEnd224 | k01 a formal's default; k02 continued over three lines; k03 a header parameter's conditional default; k04 a single-statement `initial`; k05 a literal holding both a backtick and a continuation; k06 the conditional as a macro argument; k07 `a == "x" \|\| a == "ab \<nl>cd"`; k08 a nested conditional in a package class method (importer clone); k09 a package parameter's conditional default; k10 a task argument |
| I | § ipsBasePfxScopeJoin224, § ipsWidthPfxByPathInScope224 | i01 `-:`; i02 a call as the base; i03 a cast as the base (package function); i04 a struct member as the base; i05 a class localparam width; i06 a package-parameter width; i07 a class nested in a class; i08 two element selects, an rvalue in a class task; i09 a static class function |
| L | § hpLvSelIdxNamesByPath224, § hpLvSelColumnJoin224 | l01 `+=` in a class method; l02 NBA in an `always_ff` of a for-generate, genvar index; l03 a cast index; l04 `$clog2(N)` index; l05 a `foreach` variable; l06 the select in the path's middle (`s.arr[i].m[1:0]`); l07 through an interface port; l08 a package function's local struct; l09 a class-parameter index; l10 an index that is an element of another path; l11 `++` in a class method; l12 a module task |
| H | § hpLvNewClassFirstElemSpan224 | h01 the lvalue over two lines; h02 a class specialization handle; h03 the constructor argument reads the lvalue; h04 fork/join in a module task; h05 a macro constructor argument |
| N | § newArrayBitSelIdxOpStripped224, § newArrayVarSelStripped224 | n01 conditional; n02 modulo; n03 var_select of two references; n04 concatenation; n05 a cast in the operation; n06 a direct and an operation index side by side; n07 `$size` beside an operation index; n08 a module function (both laws) |
| B | § sysCallTypeArgScopeJoin224 | b01 a class nested in a class; b02 a typedef inherited from the base class; b03 `$low`, `$right`, `$increment`, `$dimensions`; b04 a method-local typedef; b05 a class localparam initialised by `$bits` |
| P | § pcwAllPkgListingBindsOwn224 | p01 two modules importing the package; p02 import by name; p03 the cast in a package function; p04 no import, qualified reads |
| A | § ifArrElemLitCaFresh225 | a01 `[1:4]`; a02 `[3:0]`; a03 x/z digits; a04 a string literal; a05 a drive strength; a06 a parenthesised literal; a07 a parameter-sized array, two sizes; a08 a plain interface-array port; a09 a member of an interface held by the element; a10 a literal and a signal-reading assignment to one element; a11 a system call in the selector; a12 a part select of the member; a13-a18 the named-selector twins (a localparam into `[1:4]`, an enum into `[3:0]`, x/z digits, a strength, a string by `K-1`, a module parameter with two values) |
| O | § initHierAtRefToken225, § initHierCaLhsBareName225, § initHierFillKept225, § fillSymbolicRootOnly225v | o01 the struct parameter overridden at the instance; o02 `[2*N-1:0]`; o03 two signals in one declaration; o04 the second member; o05 a localparam chain; o06 a package struct type, a wire; o07 `'x` onto a typed pattern with `default:`; o08 the member under a cast; o09 the width inside a typedef; o10 `always_comb` and `assign` side by side; o11 a child's port width from the parent's substituted localparam, two instances; o12 a bare reference to a typed-pattern localparam; o13 a cast of an untyped-pattern localparam; o14 an untyped positional pattern, `'x` onto a wire; o15 a concatenation; o16 a typed pattern with an expression member; o17 a typed pattern with a parameter member; o18 a bare reference to an untyped-pattern localparam |
| E | § tfArgScalarTdExportOwnTd226v (with its parent § tfArgScalarTdExportFirst223 and § tfArgScalarTdWriter223) | e01 a package-qualified formal, module, export first; e02 a module's own typedef; e03 an interface's own typedef; e04 a program's own typedef; e05 a DPI import using the own typedef, then the export; e06 the export before a DPI import, an imported typedef; e07 a typedef of the own typedef; e08 an imported typedef exported after the definition (control) |
| X | cross-ground pairs | x01 a continued literal onto an interface-array element; x02 an interface-array element whose index is a path (`b[S.k]`); x03 a backtick literal and an interface-array literal target on one line; x04 a continued literal beside the struct-member substitution and a fill; x05 four expression laws in one class method with an importer clone; x06 an interface-array literal target and an lvalue path select in one module; x07 an lvalue path select through an interface-array element; x08 a conditional ending at a continued literal onto an interface-array element |

### 3.1 Per family ([evidence/grid/states.txt](evidence/grid/states.txt))

| family | case-views | ON STRICT_EQUAL | ON STRICT_NOTEQUAL | ON stage 1 | enter STRICT_EQUAL (all three off -> on) | leave |
|---|---|---|---|---|---|---|
| A | 36 | 27 | 1 | 8 | 5 | 0 |
| B | 10 | 2 | 0 | 8 | 2 | 0 |
| E | 16 | 4 | 5 | 7 | 0 | 0 |
| H | 10 | 10 | 0 | 0 | 10 | 0 |
| I | 18 | 2 | 2 | 14 | 2 | 0 |
| K | 20 | 16 | 2 | 2 | 14 | 0 |
| L | 24 | 10 | 2 | 12 | 10 | 0 |
| N | 16 | 12 | 2 | 2 | 5 | 0 |
| O | 36 | 6 | 1 | 29 | 6 | 0 |
| P | 8 | 0 | 0 | 8 | 0 | 0 |
| S | 36 | 28 | 2 | 6 | 28 | 0 |
| X | 16 | 8 | 0 | 8 | 6 | 0 |
| **total** | **246** | 125 | 17 | 104 | **88** | **0** |

The stage-1 case-views are stage 1 in every state, on faces that predate the three landings
([evidence/grid/stage1_heads.txt](evidence/grid/stage1_heads.txt), section 9).

### 3.2 Per law ([evidence/grid/lawtable.md](evidence/grid/lawtable.md), drivers/lawtable.py)

| law or state | case-views | UNFIRED | TOWARD | BYTES-ONLY | AWAY | MIXED | STAGE1-CLOSER | STAGE1-SAME | STAGE1-AWAY | enter / leave STRICT_EQUAL |
|---|---|---|---|---|---|---|---|---|---|---|
| strLitPpEscIdShift224 | 40 | 2 | 30 | 0 | 0 | 2 | 4 | 2 | 0 | 30 / 0 |
| strLitContOwnerEnd224 | 26 | 4 | 16 | 0 | 0 | 2 | 4 | 0 | 0 | 16 / 0 |
| ipsBasePfxScopeJoin224 | 20 | 0 | 2 | 0 | 0 | 2 | 12 | 4 | 0 | 2 / 0 |
| ipsWidthPfxByPathInScope224 | 4 | 4 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 / 0 |
| hpLvSelIdxNamesByPath224 | 32 | 10 | 12 | 0 | 0 | 0 | 4 | 6 | 0 | 12 / 0 |
| hpLvSelColumnJoin224 | 10 | 2 | 6 | 0 | 0 | 0 | 2 | 0 | 0 | 6 / 0 |
| hpLvNewClassFirstElemSpan224 | 12 | 0 | 10 | 0 | 0 | 0 | 2 | 0 | 0 | 10 / 0 |
| newArrayBitSelIdxOpStripped224 | 14 | 2 | 5 | 5 | 0 | 0 | 2 | 0 | 0 | 4 / 0 |
| newArrayVarSelStripped224 | 4 | 0 | 1 | 1 | 0 | 0 | 2 | 0 | 0 | 1 / 0 |
| sysCallTypeArgScopeJoin224 | 12 | 10 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 / 0 |
| pcwAllPkgListingBindsOwn224 | 8 | 5 | 0 | 0 | 0 | 0 | 0 | 3 | 0 | 0 / 0 |
| ifArrElemLitCaFresh225 | 48 | 4 | 6 | 30 | 0 | 0 | 4 | 4 | 0 | 6 / 0 |
| initHierAtRefToken225 | 38 | 2 | 7 | 0 | 0 | 0 | 0 | 29 | 0 | 6 / 0 |
| initHierCaLhsBareName225 | 36 | 6 | 6 | 0 | 0 | 0 | 0 | 24 | 0 | 6 / 0 |
| initHierFillKept225 | 38 | 14 | 3 | 0 | 0 | 0 | 18 | 3 | 0 | 6 / 0 |
| fillSymbolicRootOnly225v | 36 | 32 | 0 | 0 | 0 | 0 | 4 | 0 | 0 | 0 / 0 |
| tfArgScalarTdExportOwnTd226v | 16 | 14 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 / 0 |
| ALLOFF (the three landings) | 246 | 43 | 88 | 31 | 0 | 6 | 45 | 33 | 0 | **88 / 0** |

(The per-law rows above are the lawtable's rows at the end of the grid, x06-x08 included; the full table with the
landing rows, the pairs and WIDE is [evidence/grid/lawtable.md](evidence/grid/lawtable.md).)

* **Each switch moves only where its own law fires**: every case-view whose bytes a law's switch moves is one where
  the trace names that law. There are two exceptions, both toward golden. § strLitPpEscIdShift224's zero-shift answer
  (S/s02, s03, both views: the law returns 0 where pass 220's +2-per-backslash rule would shift) writes no trace line.
  So a firing census built from its trace cannot see such a literal; the law's own census missed none in the corpora,
  its movers equalling its prediction. The other is the export-first decline of pass 223 on E/e05, e07, which traces
  nothing when it declines.
* **The uhdm-cmp axis**: no case-view goes from judge-equal to stage 1 in any state; three go the other way under
  § initHierFillKept225 (O/o03, o04, o06 elaborated).
* **Away census over every state** ([drivers/caseaway.py](drivers/caseaway.py), [evidence/away/cases_forward.txt](evidence/away/cases_forward.txt)):
  chain-keyed 0 lost, 2557 toward. The flat key reads 92 lost: P/p01 and p02 elaborated (7 and 6 per pcw state) and
  one record on each of O/o01, o07, o12, o16, o17 per span-law state. Every one is a record that the off state held at
  a chain where golden holds fewer (off=1 on=0 golden=0, or off=2 on=1 golden=1; [drivers/flatinspect.py](drivers/flatinspect.py),
  [cases_flat_lost_inspected.txt](evidence/away/cases_flat_lost_inspected.txt): 92 of 92 records, VERDICT
  removed-extra on all 64 record kinds). These are removed extras, the key-collision artifact v11u224 described. The reversed control
  ([cases_reversed_control.txt](evidence/away/cases_reversed_control.txt)) reads chain 2557 lost.

### 3.3 Downstream on the fresh cases ([evidence/downstream/fresh_law.txt](evidence/downstream/fresh_law.txt), [fresh_alloff.txt](evidence/downstream/fresh_alloff.txt), drivers/dscases.py: the gate's own `one()`, a fresh golden cache)

| verdict, all three landings off -> law | cases |
|---|---|
| IDENTICAL -> IDENTICAL | 104 |
| **EQUIVALENT -> IDENTICAL** | **4**: K/k07, S/s07, S/s11, S/s17 (the string laws' spans reach the RTLIL src attributes; the slang netlist byte-identical to the Surelog lane's) |
| EQUIVALENT -> EQUIVALENT, the slang netlist closer (`_nohier.il` diff lines law / off) | S/s09 17 / 21 |
| the same netlist on both | EQUIVALENT: A/a09, B/b02, B/b04, I/i07, L/l10, O/o01, O/o07; DIVERGENT: A/a12, B/b01, B/b05, O/o02, X/x02, X/x04; STATUS_DIFF: A/a08 |
| leaving IDENTICAL | **0** |

## 4. The eight MIXED readings, object by object

| case-view(s) | law | the record | golden | off | on | reading |
|---|---|---|---|---|---|---|
| S/s10 both | § strLitPpEscIdShift224 | the second assignment `p = "a\nb` c"` and everything after it on the line | 4:26-43 | 4:22-37 | 4:22-39 | the end moves 37 -> 39 toward 43, the start unchanged (22 vs 26): golden also shifts the FIRST literal `"a\nb` //c"` by +4, which the law declines for its `//` (pass 220's +2 stays there: 22 vs golden 24). Toward; a residue of the decline |
| K/k05 both | § strLitContOwnerEnd224 | the assignment and the conditional of `c ? "x" : "a\nb` \<nl>cd"` | 3:15-3:45 | ends 4:… (endline) | 3:15-3:41 | endline cleared; golden's end also carries the escaped identifier's +4, which § strLitPpEscIdShift224 declines for a body holding a line continuation. Toward; a residue |
| I/i04 both | § ipsBasePfxScopeJoin224 | `ref_obj k` under `arr[i].v[s.k+:2]` in `p1::c::f` | `p1::c::f::arr[i].v[+:2]::v::k` | `p1::c::f.arr[i].v[s.k+:2].v::k` | `p1::c::f::arr[i].v[s.k+:2]::v::k` | both separators now golden's; the one difference left is the path text (golden renders a member base as empty, `[+:2]`). Toward |
| E/e05 both | § tfArgScalarTdExportFirst223 (the parent of § tfArgScalarTdExportOwnTd226v) | the exported function's formal typespec, a package's own typedef with a DPI import before the export | `p::FILE_T` 3:11-14 (the declaration) | the per-formal copy | `FILE_T` 3:11-14 | the decline keeps golden's location; the `p::` name face predates the landings (UNFIRED under `R11U223_OFF` and ALLOFF) |

## 5. Composition

### 5.1 Status level ([evidence/compose/compose_status.txt](evidence/compose/compose_status.txt), drivers/compose.py over L, A and the three single-off sweeps)

| stage | conversions A -> L | owner | CHANGE rows A -> L | owner |
|---|---|---|---|---|
| probe | 5 | **OWN224** (r10svs2repro/s5_negctl, w3_macrodeep, r10v121repro/v121_c, r10v172repro/v172_3_pos, r10v174repro/v174_b_sysfns) | 2 | OWN224 (g147_a `col(14) -> col(6)`, v3_hierpath `endcol(6) -> endcol(4)`) |
| surelog | 1 | **OWN225** (InterfArrayBind d) | 6 | OWN224 (BlackBePipeInt t `depth(1) -> type(1)`, BuildUVMPkg d/t `line(19) -> line(14)`, Scoreboard d `file(16) -> file(12)`, SimpleUVM d/t `file(40) -> file(36)`) |
| uhdm2rtlil | 2 | **OWN225** (OutputSize...StructMember d/t) | 0 | - |

**CANCEL (a row the same in L and A but different with one landing off): 0 in all three stages.** No conversion
needs two landings. The downstream csvs of A and of every single-off sweep equal L's.

### 5.2 Byte level ([evidence/compose/compose_bytes.txt](evidence/compose/compose_bytes.txt), drivers/bytecancel.py)

7452 databases (4087 probe, 2560 non-fenced corpus, 805 downstream lanes): SAME 7427, OWN224 8 (7 probe, BlackBePipeInt
t), OWN225 5 (InterfArrayBind d/t, OutputSize d/t and its lane), OWN226 3 (the probe cases r11u226 named),
JOINT224+226 9 (BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d: pass 224's records and
r11u226's symbol order), **CANCEL 0**.

### 5.3 Each landing's movers against its frozen prediction ([evidence/compose/movers_vs_frozen_predictions.txt](evidence/compose/movers_vs_frozen_predictions.txt), drivers/predcheck.py)

| landing | prediction (md5) | movers at HEAD (L vs its single-off) | unpredicted | predicted, not moved |
|---|---|---|---|---|
| 224 | r11u224repro evidence/census/predict_final.txt (`c7573329`, as claimed; stamp 08:21:59Z with law11's md5) | 17 | 0 | StringWithBackslash d/t and its lane (its README's own over-prediction: +8 either way) |
| 225 | r11u225repro evidence/census/prediction_frozen.txt (`8d9896b8`, as claimed; no time stamp) | 4 corpus + the OutputSize lane (byte census) | 0 | 0 |
| 226 | r11u226verify evidence/census/prediction_fix.txt (`eede7036`, as claimed; stamp 06:13:14) | 12 (9 corpus + 3 probe) | 0 | 16 (the id order equalled the address order there, as r11u226 reported) |

### 5.4 The cross-ground pairs (both views, [evidence/grid/](evidence/grid/))

| pair | case | result |
|---|---|---|
| § strLitContOwnerEnd224 + § ifArrElemLitCaFresh225 | X/x01 (a continued literal onto an element member) | STRICT_EQUAL both views, law on or off: pass 220's § strLitContLineSpan220 moves the fresh cont_assign too (3 firings); WIDE (220 off) reads `endline` |
| same pair, a conditional right side | X/x08 | STRICT_EQUAL both views; the owner law TOWARD (4 records), the element law BYTES-ONLY (it fires on the literal target beside it and declines the conditional) |
| § hpLvSelIdxNamesByPath224 + § ifArrElemLitCaFresh225 | X/x06 (one module) | **STRICT_EQUAL both views only with both**: each law alone TOWARD (2 and 1 records), the pair off 3 |
| same pair, index a path | X/x02 (`b[S.k]`), X/x07 (`b[K].s.arr[i][1:0] = d`) | stage 1 on a pre-existing face in every state; the lvalue law does not reach a path through an interface-array element (x07, residue); the element law STAGE1-CLOSER |
| § strLitPpEscIdShift224 + § ifArrElemLitCaFresh225 | X/x03 | STRICT_EQUAL both views; each alone TOWARD |
| the string laws + pass 225's substitution | X/x04 | stage 1 on a pre-existing face; every law STAGE1-CLOSER |
| four expression laws + importer clone | X/x05 | stage 1 (the clone listing); every law and pair STAGE1-CLOSER |
| § fullNameDrainIdOrder226v + the name laws of passes 220 and 224 | the UVM rows (section 7), where every name law of both passes fires | the id-order walk changes only the symbol table: every UVM row's dump is identical with and without it, and the 224-off and 226-off sweeps move the UVM rows jointly with no cancellation (section 5.2); in the E family `R11V226_OFF` moves only E/e06, through § tfArgScalarTdExportOwnTd226v |

## 6. The CHANGES: strict improvements or unmaskings ([evidence/unmask/](evidence/unmask/), drivers/unmask2.py)

Pass 224's before and after are the switch states 224-off -> L. Every row whose strict verdict differs is re-read
record by record (golden against each database):

| row | before -> after | reading |
|---|---|---|
| BlackBePipeInt t | `depth(1)` #66 -> `type(1)` #15268 | **UNMASK**: #66 (golden `parameter host_dev_gp` at depth 2, ours `dev_addr_width_gp` at depth 6) is gone and the walk agrees through #15267; the new first record sits past the old divergence. It is default mode's #15272 face (`ref_typespec bp_common_pkg` against a folded constant), the residue pass 224 ranks first |
| BuildUVMPkg d/t | `line(19)` -> `line(14)` | SUBSET, the same first record (#26855 `this_type`), 5 records gone |
| Scoreboard d | `file(16)` -> `file(12)` | SUBSET, the same first record (#26895 `this_type`), 4 gone |
| SimpleUVM d/t | `file(40)` -> `file(36)` | SUBSET, the same first record, 4 gone |
| g147_a | `col(14)` -> `col(6)` | SUBSET, 8 gone |
| v3_hierpath | `endcol(6)` -> `endcol(4)` | SUBSET, 2 gone |

Pass 225 and r11u226 move no strict verdict except their own conversions.

**The away census in both keys over the full corpora** ([evidence/away/](evidence/away/), drivers/awayall.py: map
14's, canonical records and `RAW=1` raw full names, chain-keyed and flat with the in-place pairing;
drivers/awaylandings.sh):

| landing (off -> L) | canonical: chain lost / toward, flat lost (unexplained) | raw | reversed control (L -> off) |
|---|---|---|---|
| 224 | **0 / 134**, flat 13 (0: all 13 on BlackBePipeInt t, removed excess) | 0 / 134 | chain 134 lost |
| 225 | **0 / 15**, flat 0 | 0 / 17 | chain 15 (raw 17) lost |
| 226 | **0 / 0** (bytes only: 12 movers, 0 records) | 0 / 0 | 0 (nothing to reverse; the census sees the other landings' moves) |
| all three | **0 / 149**, flat 13 (0 unexplained) | 0 / 151 | 149 (raw 151) lost |

## 7. Determinism ([evidence/det/](evidence/det/), drivers/det.sh: three concurrent harness runs per row-mode with the L sweep's command lines; drivers/detdump.sh for the dumps)

| row-mode | law.bin | law.bin + `R11V226_IDORDER_OFF` | fix.bin | fix.bin + `R11V229_OFF` |
|---|---|---|---|---|
| Earlgrey_0_1 d / t | 1 hash each in 3 (= L's) | 1 each in 3 (the same) | - | - |
| MiniAmiq d | **1 in 3** (`7d6c076f`) | **3 in 3** | - | - |
| MiniAmiq t | **1 in 3** (`7d6c076f`) | **2 in 3** | - | - |
| SeqDriver, BuildUVMPkg d/t | 1 each in 3 | 1 each in 3 | - | - |
| SimpleUVM d / t | **1 each in 12** | 1 each in 12 | - | - |
| Scoreboard d | **2 in 12**: `dbb7fce6` x7, `a7eaa666` x5 | 2 in 3 | **1 in 12**: `dbb7fce6` (L's) | **2 in 12**: `dbb7fce6` x8, `a7eaa666` x4 |

* **Dumps**: every row's draws with `R11V226_IDORDER_OFF` read the same unsorted uhdm-dump as the law's
  ([detdump_law_idoff.txt](evidence/det/detdump_law_idoff.txt)). Scoreboard's two variants differ in 92 unsorted dump
  lines and 0 sorted, with or without the switch.

### 7.1 The Scoreboard coin, pinned ([evidence/det/scoreboard_coin.txt](evidence/det/scoreboard_coin.txt))

* **What moves.** The 92 lines are one block of 23 `svunit_pkg::` class methods in the DESIGN's own vpiTaskFunc
  listing, the fields printed between `uhdmallModules` and `uhdmtopModules`.
  * dbb7fce6 and golden list uvm_pkg's 894 entries, then svunit_pkg's 23: entry 894 `uvm_reg_block::new`, entry 895
    `svunit_base::get_name`.
  * a7eaa666 lists the 23 first.
* **Where the listing is built.** ModuleEmit.cpp builds it: `design->vpiTaskFunc` concatenates
  `materializedPkgTfGroup` over `unitScopeWildcardImports()`.
* **Why the order varies.** That function sorts the compilation-unit wildcard imports with `a.first < b.first` on
  their `SourceLocation`s.
  * Scoreboard's `import uvm_pkg::*` is in design.sv and `import svunit_pkg::*` in testbench.sv, so the sort
    compares BufferIDs.
  * slang's driver reads the source files on a thread pool, so the root files draw their BufferIDs in completion
    order. fix.bin's trace printed `uvm_pkg@2 svunit_pkg@3` in some draws and `uvm_pkg@4 svunit_pkg@2` in others:
    buffer ids 2, 3 and 4 in either order.
* **Which order is right.** Golden follows the command line (design.sv before testbench.sv), as Surelog processes it.

### 7.2 § unitImportFileOrder229v (`R11V229_UNITIMPORTORDER_OFF`, `R11V229_OFF`; [fix.patch](fix.patch): src/R229.h, src/ModuleEmit.cpp)

* **The rule.** The members of a compilation unit are in parse order: the command line, with an included file's text
  at its directive. `getCompilationUnits()` lists the units in syntax-tree order. So the collection loop already yields
  Surelog's order, and the refinement keeps it instead of sorting.
* **The trace.** `R11V229_TRACE` records every decision with two or more imports: `MOVED` where the parse order differs
  from the buffer-id order of that draw, `same` otherwise.
* **Scoreboard.** 12 of 12 draws give `dbb7fce6`, byte-identical to L's and the base's majority; the refinement
  reordered 7 of those 12 draws (`MOVED`). With the switch set the coin returns: 8 + 4 in 12.
* **Nothing else moves** (section 2): 0 of 7452 gate databases against L; on the cases of the six directories it sees
  two imports only in U/u02, one file, bytes equal.

### 7.3 A discarded draft

The first draft ranked each import by its root buffer's position in `SyntaxTree::getSourceBufferIds()`. slang's
`SyntaxTree::create` pushes the sources onto the preprocessor in REVERSE order, so that list runs last file first.
The draft drew one hash in 12 of 12 draws, but the wrong one: svunit first, `a7eaa666`, away from golden's listing
order (fix_d1.bin, trace `svunit_pkg@3/r0.0 uvm_pkg@2/r0.1`). It never reached a gate. The delivered refinement keeps
the collection order, which needs no rank.

### 7.4 SimpleUVM

* **The draws.** 12 draws per mode on law.bin and 12 per mode with `R11V226_IDORDER_OFF` give one hash per mode each
  ([det_simpleuvm_more.txt](evidence/det/det_simpleuvm_more.txt)).
* **The earlier sighting.** v11u225 drew two SimpleUVM default hashes at `75a564b0`, with identical dumps, so a
  symbol-table order.
* **Why nothing is pinned.** The address-order loop that wrote such orders is § fullNameDrainIdOrder226v's site, and
  at this base the coin does not reproduce even with that switch set. There is no writer to pin and no fix to deliver.

## 8. Downstream byte checks ([evidence/downstream/](evidence/downstream/))

| row or case | check | result |
|---|---|---|
| OutputSizeWithParameterOfInstanceInitializedByStructMember (the converted uhdm2rtlil row; its lane) | the slang lane's `.il`, `_nohier.il` and `_synth.v` against the Surelog lane's in L's downstream workdir | **byte-identical** (4cdb66da28, 33ee12ff6c, 43d898d3c1); the same three files with 225 off (its database moves, its RTLIL does not) |
| InterfArrayBind d (the converted surelog row) | no downstream lane (a Surelog-corpus test) | - |
| v11u224 DS/ds01, ds02 | law vs `R11U224_OFF` vs all off | **EQUIVALENT -> IDENTICAL by pass 224**: the law's slang `_nohier.il` equals the Surelog lane's byte for byte (75af69abfe, 673dc83857); with 224 off 48b31859fc / 42c390bc09 |
| r11u225 OS/o05, o19, o21 | law vs `R11U225_OFF R11V225_OFF` vs all off | EQUIVALENT in every state, the slang `.il`, `_nohier.il` and `_synth.v` byte-identical across the states: **pre-existing**, not a law's (the `'0` / `'z` fill and the second child width, section 9) |

## 9. Residues, re-measured at the base ([evidence/residues/](evidence/residues/))

| pass | residue (its README's rank) | at `01dc93ab` |
|---|---|---|
| 224 | 1 BlackBePipeInt #15272 / #15268 | **stands**: d `type(1)` #15272, t `type(1)` #15268, `ref_typespec bp_common_pkg` against a folded constant `UINT:1` at 2047:16 |
| 224 | 2 the sister's UVM heads and Earlgrey #106660 | **stand**: MiniAmiq d/t #24915 and SeqDriver d/t #24898 / #24910 `UVM_SEQ_ARB_TYPE` `line` (golden 332:40-56, ours 1381:51-67, then a depth record at +2); SimpleUVM d/t, Scoreboard d, BuildUVMPkg d/t `this_type`; Earlgrey d #106660 / t #108111 `ref_typespec` full name `work@flash_ctrl` against `region_cfgs[8]` |
| 224 | 3 the minted clone return variables | **stand, counted**: MiniAmiq d and t and SeqDriver d each hold **788** variables parented at a function that are neither a Return() nor listed (golden 0); with `R11U218_CLONERET_OFF` MiniAmiq holds 3283 Return objects (golden 2573) and 78 such variables, so **710** are the minted returns § importCloneSharesHomeReturn218 leaves unreferenced (drivers/tool/retvars.cpp, [minted_return_vars.txt](evidence/residues/minted_return_vars.txt)) |
| v11u224 | 1 a macro-born backtick literal (SX/sx11) | **stands** (`col`, both views) |
| v11u224 | 2 an lvalue select inside an lvalue select's index (v11u220 G/g26, v11u187 T/t35) | **stand** (stage 1, both views) |
| v11u224 | 3 a package-qualified lvalue index (LX/ld02) | **stands** (stage 1); ib01 elaborated (`fullname`) and nx05 (`fullname`) stand too |
| 225 | 1 `UVM_SEQ_ARB_TYPE` | **stands** (above) |
| 225 | 2 `this_type` | **stands** (above) |
| 225 | 3 imported scalar typedef formals at module scope (v11u223 A/a07, a12, a31) | **stand** (`name`; a31 elaborated STRICT_EQUAL) |
| 225 | 4 `'0` / `'z` / net-declaration `'1` onto a substituted width (OS/o05, o19, o12) | **stand** (stage 1; o05, o19 EQUIVALENT downstream, law-invariant) |
| 225 | 6 shapes not reached (IA a11, a16, a22 stage 1; a12, a14 `fullname` parse view) | **stand** |
| v11u225 | 1 the member substitution for a reduced struct value (FO g15, g19, h04) | **stands** (stage 1) |
| v11u225 | 2 one child with two member widths (FO g16, OS o21) | **stands** (stage 1) |
| r11u226 | 1 non-integral scalar typedef formals (F/f05) | **stands** (stage 1) |
| r11u226 | 2 § enumPkgWriterImportsType219's by-name alias (W/w04, w04b) | **stands** (stage 1) |
| r11u226 | 3 nested `$unit` class listings three deep (W/w02) | **stands** (stage 1) |
| r11u226 | 4 `$size` with a genvar dimension argument (S/s11) | **stands** (stage 1) |
| carried | FuncStructVal, cfg_func_width_loop, struct_param_func_config | stand: FuncStructVal d/t `endcol` #747 / #746 (a qualified reference's end), cfg_func_width_loop d/t `line` #464 / #374 (`mask_t`), struct_param_func_config d/t `fullname` #759 / #669 ([rowheads_L.txt](evidence/residues/rowheads_L.txt)) |

New residues this pass found (none is a break; each is a face where a law declines or does not reach):

1. **§ strLitPpEscIdShift224 declines a body holding `//`, but golden shifts it** (S/s10). Golden gives
   `"a\nb` //c"` its +4, where pristine's +2 stays and the next statements lag by 4. The comment-opener decline of
   `strLitPpShift224` (ExprEmit) is too wide.
2. **A literal with both a backtick and a line continuation** (K/k05). Golden's end is the continuation's computed
   end plus the escaped identifier's +4; ours stops at the continuation end (3:41 vs 3:45). `strLitPpShift224`
   declines any `\n` in the body.
3. **The hier_path decompile of a non-simple base or index** (I/i02, i03, L/l03, l04: stage 1; I/i04 `fullname`).
   Golden renders a call, a cast or a member as an empty operand (`arr[i].v[+:2]`, `s.arr[][1:0]`); ours writes the
   expression text, and the full names built through the path carry it.
4. **A package-parameter or class-localparam width of a trailing `+:`** (I/i05, i06). Golden keeps the reference
   (`k+:W`); ours folds it to the constant, so § ipsWidthPfxByPathInScope224 never sees a reference (stage 1).
5. **An lvalue path select through an interface-array element** (X/x07, `b[K].s.arr[i][1:0] = d`): stage 1, with
   § hpLvSelIdxNamesByPath224 unfired.
6. **A localparam chain onto the member** (O/o05, `N = A; A = Info.x`): golden substitutes `Info.x` at N's
   reference, ours folds it (stage 1); and `[2*N-1:0]` (O/o02) keeps golden's operation where ours substitutes the
   path (stage 1).
7. **The DPI-import typedef formal's name** (E/e05, `p::FILE_T` against `FILE_T`) and **a package-qualified formal
   with the export first** (E/e01, `line`), both predating the landings.
8. **The minted return variables counted**: 710 per MiniAmiq mode (above).

## 10. Fence and process

### 10.1 This pass

* **The fence.** Every driver here sources [drivers/env.sh](drivers/env.sh). It reads the four names from the
  `FENCED=` line of tools/probe/r11u107repro/canaudit.sh and fails closed on anything but four. It refuses to run
  unless `SURELOG`, `UHDM_CMP`, `UHDM_DUMP`, `STRICT_CMP` and `LAW` are executable files.
  * case.sh repeats the tool check, checks its binary argument, and refuses a fenced path.
  * These drivers skip fenced paths unread by word boundary: compose.py, bytecancel.py, predcheck.py, unmask2.py,
    awayall.py, predict.py, bvmirror.sh, rowheads.sh, det.sh, detdump.sh, firecases.sh, caseaway.py, dscases.py.
  * dupcheck.py never opens a corpus file whose path holds a fenced name even as a substring.
* **What ran on fenced tests.** The gate sweeps dispatched every row, as the gate mandates; only their csv verdicts
  and non-fenced databases were read. No binary, gdb or script ran on a fenced test's sources or databases outside
  them, and there was no gdb at all.
* **No fenced names.** A grep of this directory for the four names, as words and as substrings, reads 0
  ([fencecheck.txt](evidence/fence/fencecheck.txt), with a planted positive control found).
* **Builds and binaries.** `-j 2` for the base and the fix; `-j 1` for the fix's rebuild check, when `free -g` showed
  5 GB available. Binaries were frozen before measurement, and no source was edited while its build ran.
* **Repository hygiene.** No stash; `GOLDEN_DEFER` unset; nothing under `results/`, `tests/` or `third_party/` was
  written.
  * Scratch: `/tmp/r11u229_*`.
  * Worktrees: `/tmp/wt_r11u229`, `/tmp/wt_r11u229fix`, `/tmp/wt_r11u229rb`, and `/tmp/wt_r11u229chk` (removed).
  * No process was stopped.
* **Cases edited after the first triage, before their grid:**
  * S/s01, s04, s16: `\x` is a hexadecimal escape slang rejects, so the escape letters were changed.
  * S/s10: an escaped quote beside a backtick is a Surelog syntax error, so the declined literal became one holding
    `//`.
  * I/i07: the output port shadowed the class name.
  * E/e04: slang rejects a `$unit` typedef read from a package, so the case became a program's own typedef.
  * O/o01: its override was rewritten to match its first line.
* **The fix's prediction** was frozen before its gate sweep, with an md5 and a time stamp (section 2).

### 10.2 The six directories ([fenceaudit.txt](evidence/fence/fenceaudit.txt) static, [fencecheck.txt](evidence/fence/fencecheck.txt) runtime, [casefirst.txt](evidence/fence/casefirst.txt), [dupcheck.txt](evidence/fence/dupcheck.txt))

* **env.sh, at runtime.** Each env.sh was sourced from the checkout, then from a scratch copy beside a canaudit.sh
  holding two names. The runs used a bare environment and one with the pinned tools exported.
  * With the tools: all six read 4 names from the checkout and refuse the two-name copy (rc 1, 2 names).
  * Bare: r11u224repro's and v11u224repro's abort the shell (`${SURELOG:?}`). r11u225repro's and v11u225repro's
    read 4 names, then refuse the unset tools (rc 1). r11u226verify's refuses the tools before reading the fence
    (rc 1). All fail closed.
* **The fence, per driver (static).**
  * Every driver that touches corpus sources or databases reads the fence itself or sources its env.sh:
    dscensus.py reads the `FENCED=` line itself; gsweep.sh runs only the gate.
  * The others without an own check read case workdirs or database triples their callers hand in:
    r11u224repro caseaway.py, v11u224repro walkprefix.py, v11u225repro awaycase.py, r11u226verify sizevals.py.
  * **No file of the six names a fenced test.**
* **Predictions.**

  | pass | file | md5 | time stamp |
  |---|---|---|---|
  | 224 | `predict_final.txt` | `c7573329`, as claimed | 2026-09-29T08:21:59Z with law11's md5; v11u224 saw the law sweep's probe directory born 08:22:14Z |
  | 225 | `prediction_frozen.txt` | `8d9896b8`, as claimed | **none**: the freeze before the sweep is asserted in its README only |
  | v11u225 | `prediction_fix_frozen.txt` | `a060b88e`, as claimed | **none**: its header says "BEFORE its gate sweep" |
  | r11u226 | `prediction_fix.txt` | `eede7036`, as claimed | 06:13:14 with fix.bin's md5 |
* **Packaged cases and their § first lines.**

  | directory | cases | each first line names a law |
  |---|---|---|
  | v11u224repro | 140 | yes |
  | r11u225repro | 43 | yes |
  | v11u225repro | 40 | yes |
  | r11u226verify | 104 | yes |
  | this directory | 123 | yes |
  | r11u224repro | 124 | 103: the 21 without are PW p01-p03, TP tp01-tp15 and HN hn03, hn04, hn08, each marked `r11u224 decode` |

  r11u224's README (section 12) lists HN among its law directories without naming the three decode cases in it.
  Every named law exists in the sources (src/, include/, uhdm_main.cpp).
* **Tool-variable guards** (the mechanism that executed a `.uhdm` as a script in passes 223, 224 and 225 and in
  map 14). These drivers run a tool through a variable as a shell command word with no executable check of
  their own:

  | driver | runs | safe only if |
  |---|---|---|
  | r11u224repro/drivers/case.sh | `$SURELOG`, `$UHDM_CMP $g $o`, `$STRICT_CMP`, `$b` | the caller sourced env.sh (it checks only FENCED and S, and names env.sh in an error message) |
  | v11u224repro/drivers/case.sh | the same | the same |
  | r11u219repro/drivers/case.sh | the same (r11u226's finding) | the caller exported FENCED and S after sourcing env.sh |
  | r11u220repro/drivers/case.sh | the same (r11u226's finding) | the same |
  | v11u220repro/drivers/vcase.sh | the same (r11u226's finding) | the same |
  | r11u223repro/drivers/case.sh | the same (r11u226's finding) | it sources env.sh only when FENCED is unset |
  | r11u226verify/drivers/case.sh | `$b` only (the binary argument; the tools are checked) | a caller passing an empty binary makes `timeout` run the case source, not a database |

  r11u225repro and v11u225repro case.sh check all four tools and the binary; their dump.sh and r11u226's lawfix.sh
  source a checking env.sh. The Python drivers pass a tool as argv[0]: an unset variable raises, and no database runs
  as a script. This directory's case.sh checks every tool and its binary argument.
* **Hard-coded scratch, and what each needs to re-run.**
  * r11u224repro, v11u224repro: none; `$B` (the frozen binaries) and `$S` (the scratch root) come from the caller,
    both required.
  * r11u225repro: `B=/tmp/r11u225_bin` default (pristine, law, uhdm-strictcmp); `S=/tmp/r11u225_s`,
    `/tmp/r11u225_awaycache`; uvmdist.sh `/tmp/r11u225_bin/uhdm-strictcmp`.
  * v11u225repro: `/tmp/v11u225_bin`, `/tmp/v11u225_s`, `/tmp/v11u225_awaycache`.
  * r11u226verify: `/tmp/r11u226_bin` (`R226_BIN`), `/tmp/r11u226_g` (`GW`), `/tmp/r11u226_det`,
    `/tmp/r11u226_fence(_s)`, `/tmp/r11u226_lftr.*`. Its fix.patch was removed at `a332e45b` (landed); its fix binary
    re-runs from `4a620bd0` + the landed source.
  * None of those binary directories exists now: each re-runs given its pristine and law (and fix) binaries in `$B`
    and a scratch root.
  * This directory: `/tmp/r11u229_bin`, `/tmp/r11u229_g`, `/tmp/r11u229_det`, `/tmp/r11u229_away`,
    `/tmp/r11u229_awaycache` (every one overridable: `R229_BIN`, `GW`, `W`, `AWAYCACHE`).
* **Duplicated sources** ([dupcheck.txt](evidence/fence/dupcheck.txt), drivers/dupcheck.py). Every case file of the
  six directories (595) was hashed against 19718 corpus and tests/probe files, on the exact bytes and on the text with
  `//` lines dropped. **The only duplicate is r11u225repro's OS/o01**: the uhdm2rtlil row's `dut.sv` with a comment
  line added, as v11u225 reported. No other packaged case repeats a corpus or tests/probe source.

## 11. Files

* **fix.patch**: src/R229.h, src/ModuleEmit.cpp (§ unitImportFileOrder229v). Not applied.
* **cases/**: A 18, B 5, E 8, H 5, I 9, K 10, L 12, N 8, O 18, P 4, S 18 (s14 with an included `inc.svh`), X 8 (123).
* **drivers/**:
  * The environment and the grid: env.sh (pins, fence, tool guards), case.sh, grid.py and laws.py (r11u226's grid
    with this pass's switch map), gridall.sh, quick.sh, lawtable.py, caseaway.py.
  * Downstream: dscases.py.
  * Sweeps and composition: sweep.sh, compose.py, bytecancel.py, predcheck.py, unmask2.py, awayall.py (map 14's),
    awaylandings.sh.
  * Determinism and the fix: det.sh, detdump.sh, census.sh, predict.py, lawfix.sh, firecases.sh, bvmirror.sh.
  * Residues: rowheads.sh, tool/retvars.cpp.
  * Fence and process: fenceaudit.py (the env.sh-sourcing and loop-guard refinements), fencecheck.sh, casefirst.py,
    dupcheck.py.
* **evidence/**: grid/ (per case-view results in grid1-grid4, states, law table, stage-1 heads), away/, downstream/,
  compose/, unmask/, det/, census/, fix/, residues/, gates/, fence/.
