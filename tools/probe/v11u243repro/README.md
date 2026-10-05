# v11u243 — adversarial verification of r11u243

Verdict: **VERIFIED WITH TWO FIXES.** Every headline number of r11u243 was reproduced exactly. Fresh cases found two
places where the patch moved a record away from golden on legal SV where pristine was right. Both are fixed behind
their own switches (`R11V243_OFF` drops both). A third finding is a misnamed law token in one implementer case. The
delivery is `/tmp/r11u243.verified.patch` (a diff against `f984159f`; it applies clean on a fresh `f984159f`).

Worktrees `/tmp/wt_v11u243` (patch + fixes) and `/tmp/wt_v11u243pris` (pristine), scratch `/tmp/v11u243_*`.

## Binaries (built here, frozen under `/tmp/v11u243_bin` before any measurement)

| binary | md5 | |
|---|---|---|
| pristine | `38df1270940e81dbce1addeef4d0e2ab` | byte-identical to the main tree's build at the base |
| law (r11u243 as delivered) | `0fa327fd1592d945bab39b2926928080` | the implementer's md5 |
| fix1 (+ § thisNetHomeListedOnly243v) | `d3279dd1d0c87f2e4d5928c6fc493e70` | intermediate |
| fix (+ § unitImpPaRhsActualFinal243v) | `70391de839f83d142a5965403072c075` | the verified patch |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's |

All binaries link slang 12.0.0+545f88b2e. The cmds.txt audit (path list filtered by `$FENCED` first;
`evidence/cmds_audit.txt`) shows that each sweep names only its own binary on 3265 rows. The other 50 cmds.txt run no
slang-uhdm.

## Reproduction of r11u243's numbers

* **Gate sweeps** (`tests/sweep.sh --jobs 3`; `/tmp/v11u243_wL` law, `/tmp/v11u243_wP` pristine). After stripping the
  workdir paths (the LowMem SURELOG_FAIL detail text), every csv matches the implementer's row for row in all four
  stages, for both sweeps.
  * Law sweep: probe EQUAL 3498 + STRICT_NOTEQUAL 589, regressions=0, conversions=17, changes=5.
  * Surelog corpus: regressions=0, conversions=0, changes=5 (SimpleUVM d/t file(2) -> type(1), BuildUVMPkg d/t
    file(8) -> file(7), Scoreboard d fullname(3) -> fullname(2)).
  * uhdm2rtlil corpus: 0 / 0 / 0.
  * Downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT.
  * Pristine reproduces every baseline. Both sweeps exit 1 only on the law-index staleness check.
* **Byte movers** (`evidence/byteverify_law_vs_pristine.txt`; `tools/probe/r11v75repro/byteverify.sh` with
  SELFCHECK=1 on fence-filtered mirrors, `drivers/bvmirror.sh`):
  * Corpus: 9 / 2560 (selfcheck 2559 / 2560): BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t,
    Scoreboard d.
  * Probe: 31 / 4087, the same 31 names as the implementer's frozen prediction.
  * Downstream slang lanes: 0 / 805.
* **Away census** (`drivers/awayrows.py` with the variant comparator `strictcmp_x`; `evidence/away_law_vs_pristine.txt`):
  40 databases, chain away 0, flat away 0, toward 687 (SimpleUVM 79 per mode).
* **Canaries:**
  * `canaries.sh` on the surelog csv: law ok=47 changed=5 (the five attributed rows), pristine ok=52 changed=0.
  * `canaries.sh` on the uhdm2rtlil csv: ok=16 changed=0.
  * `ctcan2.sh` surelog (EXPECT_UNKNOWN=1) ok=58 changed=0 PASS; uhdm2rtlil (EXPECT_UNKNOWN=6) PASS.
* **The implementer's grid** (its own `drivers/grid.sh`, 500 lines, every rc 0): the verdicts are identical line for
  line, and the per-case-view byte classes across the 10 configurations are identical (0 mismatches). The md5s differ
  only because the output database records the worktree path. `R11U243_OFF` == pristine on 50 / 50; 43 enter
  STRICT_EQUAL and none leaves; the per-switch revert counts are the implementer's (THISNOFILE 20, THISANCHOR 10,
  LAWSSTRING 12, CLSPROPALIAS 14, CLSIMPUNSIZED 6, PROPSPECPANOFILE 6, UNITIMPRHS 4).
* **First records quoted at the law binary:**
  * SimpleUVM d #98800 `type`: golden `enum_typespec uvm_pkg::uvm_severity` (uvm_sequence_item.svh 352:37-49)
    against ours `unsupported_typespec uvm_severity` (uvm_globals.svh 168:15-27). This is ground A (ExprEmit
    § dpiExportedPkgSubBareOwnTdUnsupported170).
  * Scoreboard d: #81633 unchanged, while #84633 (the param_assign's file) and #84965 (the class copy of
    UVM_RADIX) clear. The next record is #130737, a constant against our operation (ground A).

## Findings

### F1: § thisNetSurelogAnchor243 moved the top's wire onto a child module's `this`

Case: `cases/A/a15_childimport_x` (§ thisNetHomeListedOnly243v).

* **Shape.** The top imports p2, which is written first. A child module imports p1. Both packages have an
  out-of-body method using `this`.
* **Golden.** `work@top.this` sits at 7:41 (p2's `this`). Golden also writes a separate `work@child.this` at 13:41.
* **Pristine.** 7:41, which is right.
* **Law.** 13:41. The law ranks every package missing from the top's import listing at 0, as if it were a file-scope
  import. The child's package is not a file-scope import, and Surelog's module late-binding list holds only what that
  module imports (`CompileHelper::importPackage` splices the imported package's list into the importing scope).
* **Fix.** § thisNetHomeListedOnly243v (`R11V243_THISHOME_OFF`, TypeEmit thisImplicitNetBoth38): a hit whose routine
  is not listed by the home module (its def entry or its elaborated twin) is not an anchor candidate. With none left,
  the law abstains.
* **Effect.** On `a15_childimport_x` d/t the fix restores pristine's 7:41 with no file. It moves nothing else: 0 gate
  databases, as predicted (below).
* **Limit.** The case is stage 1 at the base (the missing `work@child.this`, the pre-existing face of minting the wire
  in the top only). The wire's location was read from both producers' `uhdm-dump`.

### F2: § unitImpPaRhsOwnCopy243 left a typedef-typed parameter's copy without its type

Case: `cases/B/b03_typed` (§ unitImpPaRhsActualFinal243v).

* **Shape.** `parameter n_t C = 'h3;` where `n_t` is a package `typedef logic [3:0]`, imported through `$unit`.
* **Defect.** The design's copy of the constant read its reference's actual at copy time, before the package
  constant's own reference was bound. The copy's `ref_typespec` therefore had no actual. Golden binds
  `logic_typespec n_t` with its range, and pristine, which shared the package constant, showed the same.
* **Census.** The chain-keyed census lost 4 golden records per view.
* **Fix.** § unitImpPaRhsActualFinal243v (`R11V243_UNITRHSACT_OFF`, UhdmExporter, at the start of exportDesign's
  `finish241` so that every exit takes it): each copy takes the source reference's actual as it stands at the end of
  export.
* **Effect.** b03 d/t: away 4 -> 0, toward 48 -> 52. It fires in no gate database: the census over the 18 databases
  where § unitImpPaRhsOwnCopy243 fires logged 0 firings.

### F3: TS/s01 named a law that does not exist

`tools/probe/r11u243repro/cases/TS/s01_tdstr` named `§ clsPropTdStringTs243`, a law that exists nowhere, so
tests/CASES.csv attributed the case to a phantom law. It now names `§ lawSStringTd243`. Only the comment line
changed; the outputs are byte-identical.

## The attack grid (`cases/`, 71 cases, 142 case-views)

The first line of every case names its law. Fourteen configurations: pristine, law, law + `R11U243_OFF`, law + each
of the 7 switches, fix, fix + `R11V243_OFF`, and fix + each of the 2 new switches. That gives 1988 lines, each with
its exit code (`evidence/grid_full.txt`, `evidence/gridsum_full.txt`, `drivers/vgrid.sh`, `drivers/case.sh`).

* **Exit codes.** Every one is 0 except C/c04_alias, which exits 4 on every binary including pristine: the `$unit`
  writer reports `typedef target: StringType` for `typedef string ustr_t` at file scope. That is a pre-existing
  module/type-ground face.
* **Switch controls.**
  * `R11U243_OFF` == pristine on 142 / 142.
  * `R11V243_OFF` == law on 142 / 142.
  * Each `R11V243_*` switch differs from the fix only on its own case (a15 d/t, b03 d/t) and equals the law there.
* **Strict equality.** Law and fix each move 43 case-views into STRICT_EQUAL. Neither takes any case-view out of
  STRICT_EQUAL or out of uhdm-cmp equality.
* **Away census on the grid** (`drivers/awaycase.py`, variant comparator, records of each database dumped against
  itself so stage-1 views count too):
  * Law against pristine: chain away 8 (the b03 face). The fix against pristine reads chain **away 0**, toward 657.
  * Flat away 6 on b06/u01/u02 is the flat key's blind spot. Pristine reached one shared `ref_typespec p` constant
    from both the package and the design. The copy's unnamed reference is what golden writes at the design (chain
    away 0).

| group | law | cases | what they found |
|---|---|---|---|
| A | § thisNetSurelogAnchor243 | a01-a15 (in-body methods: no wire, 0 bytes, the negative control) and a01_x-a15_x (out-of-body) | a01_x, a09_x, a11_x (CRLF), a12_x (headers in two packages) and a14_x enter STRICT_EQUAL. a04/a05 (in-body against out-of-body text order) enter too. a07_x (an export chain) moves toward golden. **a15_x: F1**. a03_x (an item import), a13_x (two file-scope imports against text order: golden takes the first IMPORTED, the law ties at rank 0) and a06_x (golden mints `work@m1.this` in the child) are wrong on pristine and law alike (residues) |
| B, U | § clsImpUnsizedBasedRhsCopy243 / § unitImpPaRhsOwnCopy243 | b01-b08, u01-u18 (`'1`, `'0`, `'sh5`, `'o17`, `'b1x0`, `'D12`, typed vector / bit / range / signed / integer / real / string / time, sized, localparam, `'h 1F`, two packages, an item import, a synthesizable reader) | every judge-equal value kind (u05, u07, u10, u12-u18) enters STRICT_EQUAL in both views. The stage-1 kinds (`'1`, `'0`, `'sh5`, `'o17`, `'b1x0`, ranged, signed, real) are stage 1 at the base: the elaborated package listing folds `'1` to 4294967295, which is ground A. **b03: F2** |
| C, X | § lawSStringTd243 | struct member, arrays, parameters, alias + `$unit`, task formals, interface/module-class, qualified uses; x01 the int control | c01 enters STRICT_EQUAL, and c05 and c02 move from stage 1 to fewer cmp lines or to stage 2. c07_qual (`p::str_t` used in ANOTHER package's class) diverges earlier, on the same first field `line` with the same count of 3 and 0 records lost. That is LAW S's pre-existing qualified-binder face (x01, the same shape with `int`, reads identically on pristine), now reaching strings |
| D | § clsPropLawSAliasName243 | parameterized class, module and `$unit` classes, qualifiers, inheritance and a nested class, a cross-package typedef, interface/program classes, a synth control | d01, d02 and d03 enter STRICT_EQUAL. d04 and d05 shrink (fullname 3 -> 1, fullname(2) -> name(1)). d06 is stage 1 on both |
| E | § clsPropSpecPaNoFile243 | mixed type/value and named arguments, a nested specialization, a module class, an included generic | e02 enters STRICT_EQUAL in both views. e01 is stage 1 on both |

**Downstream on the cases** (`evidence/dscase_{pristine,law,fix}.txt`, the harness's own `one`). All 71 cases give
the same verdict on all three binaries: 58 IDENTICAL and 13 EQUIVALENT. The 13 EQUIVALENT are EQUIVALENT on pristine
too. Every r11u243 law fires under the downstream flags (the trace under `$S/dstr_law`), which is the positive control.

## Gates with the fix binary

* **Prediction, frozen before the fix sweep** (`evidence/predict_fix.txt`, `predict_fix2.txt`): 0 movers against the
  law.
  * F1 can move only databases holding a `this` wire: probe g219_a..d, SimpleUVM d/t and SeqDriver d/t.
  * F2 can move only databases where § unitImpPaRhsOwnCopy243 fires: 15 probe cases, SimpleUVM d/t and Scoreboard d.
  * The fix binary with the trace on exactly those sets logged 0 firings, and its databases are byte-identical to
    the law sweep's.
* **Gate sweep `/tmp/v11u243_wX`** (`tests/sweep.sh --jobs 3`): every csv in all four stages is identical to the law
  sweep's.
  * Probe: 3498 + 589, regressions=0, conversions=17, changes=5.
  * Surelog corpus: regressions=0, conversions=0, changes=5.
  * uhdm2rtlil corpus: 0 / 0 / 0.
  * Downstream: 803 / 66 / 2 / 0.
* **Movers.** Byteverify fix vs law: 0 / 2560 corpus (selfcheck 2559). Probe 0 / 4087. Downstream lanes 0 / 805. Fix
  vs pristine: the same 9 corpus movers. **Prediction met.**
* **Determinism** (`evidence/determinism_fix.txt`, `drivers/det.sh`): three concurrent harness runs of the fix binary
  on Earlgrey_0_1 and the five UVM rows give one hash per row-mode on all 11 runnable row-modes, each equal to the
  fix sweep's.

## Residues, ranked

1. **Ground-A heads of the targeted rows, for the sister pass:**
   * SimpleUVM d/t #98800 / #98812: ExprEmit § dpiExportedPkgSubBareOwnTdUnsupported170.
   * BuildUVMPkg d/t #81827: StmtEmit, the foreach body `begin`.
   * Scoreboard d #81633: ExprEmit, the hier_path member naming. Next is #130737, a constant against our operation.
   * MiniAmiq #71388 / SeqDriver #71344: StmtEmit.
2. **§ thisNetSurelogAnchor243's open faces:**
   * File-scope imports tie at rank 0, while golden takes the first IMPORTED (a13_x).
   * An item import `import p2::c2;` does not rank p2 (a03_x).
   * Golden mints a per-module `work@<child>.this`; we mint only the top's (a06_x, a15_x).
   * All three are wrong on pristine as well.
3. **LAW S on a package-qualified binder in a foreign package** (`p::t` in another package's class: golden keeps the
   qualified listing copy located at the use; LAW S writes the bare aliased copy). This is pre-existing for the
   integral kinds (x01), and § lawSStringTd243 extends it to strings (c07: walk divergence #30 -> #10, 0 records
   lost).
4. **`$unit` string typedef** `typedef string t;` at file scope exits 4 (`typedef target: StringType`) on every
   binary (c04).
5. **Stage-1 faces at the base on the parameter-copy shapes:** the elaborated package listing folds unbased unsized
   fills (`'1` -> 4294967295) and the signed, octal and x-digit kinds. This is ground A, the sister pass's.
6. The implementer's residues stand as stated: faces (1)(c) and (1)(d), the wire's place in the net list, and the
   module / derived-class import copies.

## Process

* Every helper reads `$FENCED` fail-closed from the FENCED= line of `tools/probe/r11u107repro/canaudit.sh`
  (`drivers/env.sh`).
* Corpus database lists for byteverify, cmds audit and lane comparison were built and filtered by `$FENCED` before
  any file was opened.
* The only corpus rows run outside the gate sweeps are named, unfenced rows, checked against `$FENCED` first:
  SimpleUVM, SeqDriver and Scoreboard for the predictions, and Earlgrey_0_1 plus the five UVM rows for determinism.
* No fenced test was dispatched, read or opened outside the gate sweeps.
* Every tool variable was checked with `[ -x ]` before use.
* No process outside this pass was listed or signalled.
* The sweeps ran one at a time, in the order law, pristine, fix1, fix.
