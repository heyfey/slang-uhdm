# v11u219: adversarial verification of r11u219 (pass 219, the module/type ground)

**Verdict: CONFIRMED WITH ONE FIX.** Every headline number of r11u219 reproduces bit for bit on binaries this
verification built itself. One law broke on legal SV: § ndaSizeFoldReach219 wrote its own dimension count where
golden's fold comes from a different branch of UHDM's ExprEval, so one fresh case went from downstream IDENTICAL
to DIVERGENT and two elaborated-view values moved away from golden's. The fix, § sizeReachFollowsWalker219v, sits
behind `R11V219_SIZEWALK_OFF`, and `R11V219_OFF` drops it. It is shipped as `/tmp/r11u219.verified.patch` (the
implementer's patch plus the fix, this directory and the regenerated tests/LAWS.md). With the fix, every gate
reads as the implementer claimed. The fix moves no corpus database, probe case or downstream lane: its predicted
mover set is empty and was frozen before its sweep.

Base `c4f26079` (branch matrix-1.87). This directory is the verifier's; the implementer's is
tools/probe/r11u219repro. A probe case is called a case. The four slang-fenced tests are never named. Every driver
reads them from the `FENCED=` line of tools/probe/r11u107repro/canaudit.sh and fails closed (drivers/env.sh).

## 1. Binaries (built here, frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pristine` | `00cd5d712fb76282ba92c898efb8812c` | fresh worktree at `c4f26079` (system-deps config): the pinned pristine md5 |
| `law` | `49c50c74269ccbba7f6980c024056c9f` | a fresh `c4f26079` worktree + `/tmp/r11u219.patch` (md5 `7ea5f79b`), applied clean: **the implementer's final md5, reproduced** |
| `fix1` | `c8b9557ac164140faacde21184a93693` | `law` + § sizeReachFollowsWalker219v (this pass's fix): the verified binary |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's comparator (the worktrees build the same md5) |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's raw-name variant, rebuilt here with tools/probe/r11u211map/drivers/cc.sh: the md5 r11u214 and r11u219 cite |

Sweeps (15-character workdirs; every `slang:` line of all 3273 corpus `cmds.txt` names that sweep's binary):
pristine `/tmp/v11u219_wP` (pristine worktree), law `/tmp/v11u219_wL`, fix `/tmp/v11u219_wF`, fix under
`R11U219_OFF=1` `/tmp/v11u219_wO`, and a pristine probe-only rerun `/tmp/v11u219_wQ` from the law worktree. Probe
databases embed their source path, so probe bytes are compared only between runs from one worktree.

## 2. The implementer's numbers, reproduced

| claim (r11u219 README) | reproduced here |
|---|---|
| pristine sweep = the committed baselines | probe EQUAL 3410 / STRICT_NOTEQUAL 677, surelog, uhdm2rtlil **0/0/0**; downstream 803 / 66 / 2 / 0 |
| probe regressions=0 conversions=22 changes=35 (3432 / 655) | **same**. The 22 CONVERSION rows are the implementer's list exactly, and the 44 CHANGE lines are 35 probe plus 9 surelog |
| surelog 0 / 0 / 9, uhdm2rtlil 0 / 0 / 0 | **same**: Earlgrey_0_1 d/t `endcol(45)`→`endcol(39)`, MiniAmiq d/t and SeqDriver d/t `fullname(61)`→`file(7)`, SimpleUVM d/t `fullname(236)`→`file(76)`, Scoreboard d `fullname(188)`→`file(52)` |
| downstream 803 / 66 / 2 / 0, verdict diff 0 | **same**: verdicts equal the baseline and the pristine sweep row for row. The six moved uhdm2rtlil lanes (PackageCast, TypedefAliasInPackage, TypedefEnum, VarPassedTo2Submodules, ibex_branch_predict, ibex_decoder) write byte-identical `.il`, `_nohier.il` and `_synth.v` |
| 96 byte movers = the frozen prediction | **32 corpus + 64 probe = the prediction (md5 `3651a45b`) exactly**: [movers_corpus_P_vs_law.txt](evidence/movers_corpus_P_vs_law.txt), [probe_movers_Q_vs_law.txt](evidence/probe_movers_Q_vs_law.txt) |
| byteverify MOVERS 32 / 2560 | `PATH_SETS_IDENTICAL (2560 paths)`, **MOVERS 32 / 2560**, SELFCHECK 2559 / 2560 (fence-free hard-link mirrors: [byteverify.txt](evidence/byteverify.txt)). Earlgrey d/t law hashes `6a8fcde9f0f9` / `dc6bc45475ff` |
| canaries | surelog ok=45 changed=7 (all seven among the nine CHANGE rows); uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1` and `EXPECT_UNKNOWN=6 ctcan2.sh` both PASS |
| away census (96 movers) canonical chain 0 / 3091, flat 34 / 3057 (0 unpaired); raw chain 0 / 4485, flat 0 / 4403; reversed 3091 / 4485 | **all eight numbers the same** ([away_corpus_can.txt](evidence/away_corpus_can.txt), [away_probe_can.txt](evidence/away_probe_can.txt), the `_raw` twins, [away_reversed_control.txt](evidence/away_reversed_control.txt)) |
| UVM order-blind distance: MiniAmiq 6339→6014, SeqDriver 5071→4700, SimpleUVM 1983→1624, Scoreboard 1453→1165; `mfc_file_away` 12 | **same** on every row-mode ([uvmdist.txt](evidence/uvmdist.txt)) |
| own grid 70 case-views: 26 convert, none leave EQUAL, `R11U219_OFF` pristine on 70, 48 move | **same** ([grid_r11u219own.tsv](evidence/grid_r11u219own.tsv)) |
| r11u214dec grid 118: 31 convert, none leave, `R11U214_OFF`/`R11U219_OFF` pristine on all | **same** under `R11U219_OFF`, with 42 staying EQUAL and 58 moving ([grid_r11u214dec.tsv](evidence/grid_r11u214dec.tsv)) |
| reach table: `R11U219_LANDING202_OFF` moves 336 of 518 and equals `R11U202_OFF` on 426; with the two nested 206 switches, 518 / 518. `_LANDING212_OFF` equals `R11U212_OFF R11V212_OFF` on 298 / 298 (moves 210). `_LANDING216_OFF` equals `R11U216_OFF R11V216_OFF` on 200 / 200 (moves 182) | **all six numbers the same** ([reach_check.tsv](evidence/reach_check.tsv)). In code, the landing switches OR into exactly the functions the old switches gate. ExprEmit.cpp and ParamEmit.cpp keep their own local `r11u200Law`, so `R11U219_LANDING202_OFF` reaches no ground-A law there |
| the two refinements return the break cases to pristine bytes | **same**: on r11u214dec A/c07, r11u216repro TW/w11, r10v221repro v7_window, r11v84repro v3_expedge and r11u84repro t5_expfences (both views), the law gives pristine bytes. With `R11U219_UNITCLSONLY_OFF R11U219_PKGWIMPORT_OFF` it does not |
| first record of every UVM row is now `typedef int UVM_FILE` | **same**: MiniAmiq/SeqDriver/SimpleUVM/Scoreboard default `#15320`.. `int_typespec UVM_FILE` golden `uvm_root.svh 348:39-47`, ours `uvm_object_globals.svh 313:9-12` |
| determinism: known coins only | the fix binary, three concurrent runs ([det_fix.txt](evidence/det_fix.txt)) writes one hash per row-mode on Earlgrey d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t and BuildUVMPkg d/t. Scoreboard default writes three hashes, all identical order-blind (sorted uhdm-dump diff 0 lines): the svunit coin |

**Not re-run here**:

* the implementer's wide byte control over 26990 case-views of tools/probe. In its place, every case holding
  `$size` was run (section 3.2), along with the 374 case-views of the grids that the fix could touch;
* its 342-case downstream face set. 73 of those cases were re-run with the fix binary (r11u219repro and
  v11u216repro: 0 leave IDENTICAL, the six claimed `$size` faces reproduce), together with the 49 fresh cases
  here that hold a dut.sv;
* the pristine binary's determinism runs.

### 2.1 Item (0)'s 12 flat-key "lost" records (the brief's mandatory refinement): an artifact of the flat key, confirmed independently

The brief asked for law importVarElemOwnName214 to be refined until the flat-key census reads 0 lost. The
implementer declined and argued that the loss is an artifact. This verification checked the argument on its own
sweeps, chain by chain, over the cached record multisets:

* On MiniAmiq d/t (12 each) and SeqDriver d/t (5 each), 34 chain positions carry an index-type `ref_typespec`
  under the class-inherited copy of `uvm_random_seed_table_lookup`. At each one, pristine held the `<in>`
  (named-inside-a-copy) record and the law holds the unnamed one. **At all 34 the law's counts of both records
  equal golden's** (golden: 0 `<in>` and 1 unnamed at each chain).
* The flat totals explain the "loss". Golden holds 591 `<in>` records of that shape design-wide against
  pristine's 234 (MiniAmiq default), so every pristine `<in>` record matches golden flatly wherever it sits.
  Golden's unnamed count is 1145 against ours 1503 → 1515, already above golden's, so the 12 records the law
  wrote correctly never read as toward.
* A refinement "until the flat census reads 0" would restore pristine's wrong record at 34 positions where golden
  holds the law's. **The law stays as landed.** Both keys and the reversed control are in section 2.

## 3. The break, and the fix

### 3.1 The break: § ndaSizeFoldReach219 computes its own count where golden's comes from ExprEval's generic handler

Golden's `$size` fold is UHDM `ExprEval::reduceExpr`'s `$size` branch
(third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp). Its walker collects the first argument's dimensions
only through an `array_var` / `array_net` (their unpacked ranges, then the element's typespec), a `logic_var` or a
`logic_net`. Its `walk_ts` reads ranges only off a logic, bit, int, packed-array or array typespec. So:

* an enum's, a predefined integer's or a struct's element range adds no dimension;
* a bit, int, byte, enum or struct VARIABLE is not walked at all.

When the walker misses (the requested dimension lies past its list, or there is no list), reduceExpr falls to the
generic `$bits`-style handler. Its value is `ExprEval::size(object, full=false)`: the element size times the last
range. That is not the dimension's count. Our elaborated view already writes that same value, because it runs the
same ExprEval. Our parse view keeps the call, which the downstream plugin reduces the same way. Law
ndaSizeFoldReach219 replaced both with its own count.

Fresh cases, net-declaration initializers, golden against the law (tools: [drivers/sizevals.py](drivers/sizevals.py)):

| case | query | golden | pristine | law | effect of the law |
|---|---|---|---|---|---|
| S/s04 | `$size(ea, 2)`, `e_t ea [3]`, enum base `logic [2:0]` | `UINT:9` | elaborated `9`, parse view the call | `3` | **downstream IDENTICAL → DIVERGENT**; the elaborated view's value (a judge-read decompile) moves from golden's to not |
| S/s08 | `$size(bp)`, `bit [3:0][1:0] bp` | `UINT:2` | elaborated `2`, parse the call | `4` | the elaborated view's value moves away from golden's (downstream DIVERGENT in both) |
| S/s01c | `$size(ma)`, `int ma [4][int]` | `UINT:32` | the call; elaborated view crashes at the base (rc 139) | `4` | wrong-to-wrong. The law's own comment says a dynamic dimension is declined, but its first branch folded a fixed first dimension over a dynamic inner one |

The record-level away census cannot see the s04 and s08 elaborated-view moves. Pristine's constant already carried
golden's value but not golden's location or size, so it never matched golden's record as a whole. The field-level
table and the downstream verdict are the evidence.

### 3.2 § sizeReachFollowsWalker219v (ModuleEmit rqSizePlan216; switch `R11V219_SIZEWALK_OFF`, `R11V219_OFF` for all)

The reach of § ndaSizeFoldReach219 now folds only where ExprEval's walker resolves the requested dimension. The
walker's list is the law's list without the element range the walker does not read, so the counts agree wherever
it resolves. Everywhere else the reach declines and leaves the base's output, with one exception. A
one-dimensional bit vector, predefined integer (not `time`) or enum VARIABLE asked for dimension 1 keeps the fold.
There the generic handler's value is that same count: golden `$size(bv, 1)` 8, `$size(iv, 1)` 32, `$size(yv, 1)`
8 (s07, which converts to EQUAL under the law and keeps its conversion). A fixed first dimension over a dynamic,
queue or associative inner dimension is declined, as the law's comment already stated.

The one-dimensional cell of § ndaSizeQueryFold216 is untouched. `r11v219Law` also reads `R11U219_OFF`, so the
pass switch still restores the base's bytes. Each decline is traced as `sizeReachFollowsWalker219v` under
`R11U219_TRACE`.

**Result on the fresh cases.** Every value the fix writes equals golden's (s02, s03, s04 w2/w3, s05, s07, s08
w2/w3). The declined ones keep the base's output: the call in the parse view, and ExprEval's value (golden's) in
the elaborated view. Downstream is S/s04 IDENTICAL on the fix, and S/s02, s03, s05, s07 DIVERGENT → IDENTICAL.
The implementer's faces stay: v11u216repro F/f14 and r11u219repro S/s01, s02, s05 go DIVERGENT → IDENTICAL, and
s03, s04 go DIVERGENT → EQUIVALENT ([ds_r11u219_v11u216_fix.txt](evidence/ds_r11u219_v11u216_fix.txt)).

**Byte reach, law against fix** ([lawfix_fix1.tsv](evidence/lawfix_fix1.tsv)): r11u219repro, v11u216repro,
r11u216repro and this directory, 374 case-views. The fix moves exactly this directory's S/s01, s01b, s01c, s04 and
s08 (both views). Under `R11V219_OFF` it gives the law's bytes on all 374.

Every other case holding `$size` under tools/probe or tests/probe was also run (38 case dirs × 2 views, fence
filtered: [lawfix_sizescan_fix1.tsv](evidence/lawfix_sizescan_fix1.tsv)). The fix gives the law's bytes on all
76.

## 4. The fix's gates (`fix1`, `/tmp/v11u219_wF`, against the committed baselines)

The prediction was frozen before this sweep ([fix/prediction_fix_vs_law.txt](evidence/fix/prediction_fix_vs_law.txt),
md5 `118c883e`, with its time stamp and the sweep's start in
[fix/prediction_frozen_at.txt](evidence/fix/prediction_frozen_at.txt)). It predicts no byte mover against the law
binary. The derivation: the fix only declines folds of § ndaSizeFoldReach219, and r11u219's frozen firing census
holds no firing of that law on any corpus row-mode or case.

1. **Probe**: regressions=0 conversions=22 changes=35 (EQUAL 3432 / STRICT_NOTEQUAL 655). The csv is identical to
   the law's, and **0 of 4087** databases move against the law's.
2. **Corpora**: surelog **0 / 0 / 9**, the same nine CHANGE rows as the law. uhdm2rtlil **0 / 0 / 0**, with a
   byte-identical csv (the surelog csv differs from the law's only in the two LowMem detail texts naming the
   workdir). Byte movers against the law sweep: **Scoreboard default alone**, with 92 uhdm-dump lines unsorted and
   0 sorted (the svunit coin). This is the prediction.
3. **Downstream**: **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT**; verdicts equal the baseline
   row for row; 0 of the lanes' slang databases move against the law sweep.
4. **uhdm-cmp**: every touched row-mode and case stays judge-equal (the corpus and probe statuses above).
5. **The pass switch**: see section 4.1 (`R11U219_OFF=1` on the fix binary).
6. **Determinism**: section 2 (the fix binary, three concurrent runs).

### 4.1 `R11U219_OFF` on the fix binary

Sweep `/tmp/v11u219_wO` covered the probe cases and both corpora ([fix/alloff.txt](evidence/fix/alloff.txt)). It
reads **0 / 0 / 0 in all three stages** (probe EQUAL 3410 / 677). Against the pristine sweeps it moves **0 of
4087** probe databases and one corpus database, Scoreboard default. That database's uhdm-dump is identical to
pristine's even unsorted (0 lines), so the difference is storage order only. `R11U219_OFF` therefore restores the
base's bytes on the verified binary, the refinement included.

## 5. The fresh grid (cases/, 52 cases, 104 case-views, both views)

Each case names its law on its first line. The records are judged by uhdm-cmp and uhdm-strictcmp against the v1.87
pin, and the downstream verdict comes from the gate's own `one()` with a fresh golden cache.

| family | cases | what they attack |
|---|---|---|
| E (enumTdLastWriter214 and its refinements enumClsWriterUnitScopeOnly219, enumPkgWriterImportsType219) | e01 export chain, e02 named-type import beside a value import, e03 two files with the same declarator position (the second CRLF), e04 `$unit` classes in two files and an included header, e05 a nested `$unit` class, e06 a program importer, e07 a function-local import, e08 an unused wildcard import, e09 one header in two packages, e10 the typedefs from a macro body, e11 packages declared against name order, e12 the same over two files, e13 the class writer over package order, e14 composition with pass 212's anonymous-member writer, e15 composition with r11u217's parameter-copy keep and an anonymous union | every writer rule and both refinements |
| C (classTdAliasLastWriter214, classScopeTdPkgListingParent214) | c01 two interfaces and a module, c02 a `$unit` class and a program, c03 a class-scope specialization imported by a module and an interface | the class face |
| Q (modStructMemberQualSpan214) | q01 `cfg :: W` spaced and parenthesized, q02 the qualified name from a macro body and from an actual, q03 CRLF, interface and generate-block typedefs, q04 a port type and a function formal | the qualifier span on pasted, spaced and CRLF tokens |
| U (unitImportCopyOwnTsRef214, unitImportCopyValueFollowsPkg214) | u01 string, logic-vector, arithmetic, unsigned; u02 two packages with one name; u03 a parameter typed by another package | `$unit` import copies |
| V (importVarElemOwnName214) | v01 fixed and dynamic arrays of an enum and a struct, v02 two importing packages and a module class, v03 a class-keyed associative array and a nested class | the class-inherited array copies |
| I (defGenTargetIpsSelArm219) | i01 genvar-expression and parameter bases, i02 procedural and right-side uses (a control), i03 an interface-array element and a struct-array element | the spaced indexed-part-select branch |
| M (ppIdentEndInRebuiltText219, ppDotNameAfterArgToken219) | m01 three forwarding levels, m02 an actual ending in `]`, m03 a multi-token actual, m04 a property rather than a call, m05 a CRLF header used in a module, m06 a macro call as the actual, m07 an actual over two lines, m08 names with digits, `$` and one character, m09 to m11 RTL member selects through macro actuals (struct field, interface member, hierarchical actual) | the macro span model on RTL and class code |
| S (ndaSizeFoldReach219, sizeReachFollowsWalker219v) | s01, s01b, s01c dynamic, queue and associative inner dimensions; s02 every two-argument form; s03 typedef'd arrays; s04 enum and packed-struct arrays (**the break**); s05 interface, generate and narrow nets; s06 continuous-assignment and variable-initializer controls; s07 bit, int and byte variables; s08 packed 2-D bit and logic | the `$size` reach |

**Law binary** ([grid_fresh_law.tsv](evidence/grid_fresh_law.tsv)): 26 case-views convert to STRICT_EQUAL (C c01;
E e13; M m01, m02, m04, m05, m06, m07; Q q04; S s02, s05, s07; V v02, each in both views). **None leaves
EQUAL**, `R11U219_OFF` gives pristine bytes on all 104, and 78 move.

Away census over the moved case-views ([grid_fresh_away_can_fix.txt](evidence/grid_fresh_away_can_fix.txt),
[grid_fresh_away_raw_fix.txt](evidence/grid_fresh_away_raw_fix.txt), drivers/gridaway.py):

* **Canonical records: 0 lost chain-keyed.**
* The flat key's 7 lost records are s03's net and typespec records. The walk reached them through the `$size`
  argument that golden (and the law) folds away, so they sit at no chain golden holds.
* **Raw full names: 2 lost, on V/v01's elaborated view.** These are the base references of the enum `p::z_t`
  under class `holder`'s and class `qc`'s listings. Golden gives that object one name per listing class; ours is
  one shared object. This is the identity family the implementer names (r11u219 README section 2.3), and the
  comparator excuses it by design (GOLDEN_EQUIVALENCE.md, "Full names and spans on a typespec copy"): canonical
  0 lost, strict verdict unchanged.

**Downstream on the law** ([ds_fresh_law.txt](evidence/ds_fresh_law.txt)):

* 34 IDENTICAL → IDENTICAL and **1 IDENTICAL → DIVERGENT (S/s04, the break)**;
* 4 DIVERGENT → IDENTICAL (S/s02, s03, s05, s07);
* 4 DIVERGENT and 4 EQUIVALENT unchanged; 2 SURELOG_FAIL.

**Fix binary** ([grid_fresh_fix.tsv](evidence/grid_fresh_fix.tsv), [ds_fresh_fix.txt](evidence/ds_fresh_fix.txt)):
the same 26 conversions and none leaving EQUAL; `R11U219_OFF` gives pristine bytes on all 104. Downstream reads
**0 leaving IDENTICAL**, 35 IDENTICAL → IDENTICAL and the same four DIVERGENT → IDENTICAL.

## 6. Findings (non-breaking)

1. **A pre-existing crash at the base** (this ground, ModuleEmit, outside the laws). The elaborated view segfaults
   (rc 139) on `$size` of an unpacked array whose inner dimension is dynamic, a queue or associative, in a
   net-declaration initializer (S/s01, s01b, s01c `_el`; the pristine binary crashes the same way, and so does the
   fix binary under `R11U216_OFF` or `R11U219_OFF`). The law's fold happened to avoid the crash on the same
   shapes. The fix declines them and restores the base's behaviour. Surelog itself fails on s01 and s01b, and on
   s01c it folds to 32, which the law did not write.
2. **The law's comment says dynamic dimensions are declined.** Before the fix, the code folded the fixed first
   dimension over a dynamic inner one; it now matches the comment.
3. **The implementer's disclosed process slip** (r11u219 README section 10). One `cmp -s` loop compared two of its
   own sweep workdirs byte for byte over every corpus directory, fenced databases included. It is equality only:
   nothing was decoded and no result is used. The patch holds 0 lines naming a fenced test.
4. **This verification's own process slip.** A `pkill`/`pgrep -f` pattern matched this verifier's own shell while
   stopping its own `-j 2` pristine build, which was running under memory pressure. The build was restarted at
   `-j 1`. No process of another agent was touched, and the frozen pristine md5 is the pinned one.

## 7. Residues, ranked (after this verification)

1. **`typedef int UVM_FILE`**, the first record of all nine UVM row-modes (confirmed above): the scalar-typedef
   formal writer in UhdmExporter (§ tfArgClassMethodOrder176 and its relatives admit only enum and aggregate
   typedefs). This is ground B.
2. **The `$size` generic-handler values**: golden folds walker misses to ExprEval's `size()` value (S/s04 w1 `9`,
   s04 w5 `6`, s08 w1 `2`, s01c `32`). Under the fix our parse view keeps the call there, which is
   downstream-right, and the elaborated view writes the value with the base's location and size. A law
   transcribing `ExprEval::size(object, full=false)` could convert those shapes; it is not written here.
3. **The crash of section 6.1** (ModuleEmit's elaborated `$size` on a dynamic inner dimension).
4. The implementer's residues 2 to 9 stand as listed: Earlgrey's ground-A qualifier span, the identity family,
   the `$unit`-class formal writer (Z/x03), r11u214's leftovers, pass 216's and pass 212's residues, and the
   sister's hand-offs.

## 8. Files

* **cases/**: C 3, E 15, I 3, M 11, Q 4, S 10, U 3, V 3 (52 cases). Each names its law on its first line; the
  S break cases name § sizeReachFollowsWalker219v.
* **drivers/**:
  * `env.sh`: pins, frozen binaries, fence.
  * `case.sh`, `grid.sh`: case-views in both views.
  * `gridaway.py`: the grid away census, both keys, canonical or raw.
  * `sizevals.py`: `$size` fold values per net.
  * `lawfix.sh`: law against fix bytes.
  * `dscases.py`, `dsfaces.sh`: downstream verdicts through the gate's own `one()`.
  * `movers.sh`, `bvmirror.sh`, `awayall.py`, `uvmdist.sh`, `det.sh`, `reach.sh`: copied from r11u219repro,
    with paths from this directory. `awayall.py` adds `CORPUS_ONLY` / `PROBE_ONLY`.
* **evidence/**: every file cited above; fix/ holds the fix's frozen prediction and the pass-switch sweep result.
