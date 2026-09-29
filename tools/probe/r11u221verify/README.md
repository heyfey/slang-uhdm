# r11u221: second adversarial verification of passes 216 and 215

Base `57ce3ae8` (branch matrix-1.87). Pass 216 and its verifier v11u216 landed at `c4f26079` (the module/type
ground). Pass 215 and its verifier v11u215 landed at `57ce3ae8` (the expression/parameter ground). The r11u218 decode
at `c624cafb` is measurement only. No pair landed after `57ce3ae8` while this pass ran: main HEAD stayed at
`57ce3ae8`, and r11u219 (the module/type pair that carries r11u214's law patch) had not landed. The two
implementations of the writer rule (§ enumTdLastWriter214 and § pkgTdAliasLastWriter215) are therefore not both in
the source, and their composition is v11u215's measurement (section 5.4).

This pass measures only. No file under `src/`, `scripts/`, `tests/`, `results/` or `third_party/` is edited by this
directory. The two refinements this pass proves are in [fix.patch](fix.patch). It is not applied. Each refinement
has its own switch, `R11V221_OFF` drops both, and the new header is `src/R221.h`. No canonicalisation patch of
`tools/uhdm-strictcmp` was handed to this pass, and none was written, because no comparator defect was proven. A
probe case is called a case throughout. The four slang-fenced tests are never named here.

## 0. Verdict

* **One break, found through the composition of pass 216 with an earlier landing, and refined** (section 4.1).
  * § ndaQueryFoldsNoStamp217v (r11u217, landed at `0a682d73`) drops § ndaSysCallNetTs212's stamp on every
    `$high`, `$low`, `$left` or `$right` in a net-declaration initializer.
  * r11u217 decoded that golden always folds these queries. Golden does not fold a query of an **unpacked-array
    port** (input, output, non-ANSI, a child's port). It keeps the `sys_func_call` and stamps it with
    `ref_typespec (work@dut)`.
  * Pass 216's own grid case r11u216repro NQ/n12 (`$left` of `input logic [3:0] i [5]`) was STRICT_EQUAL in the
    elaborated view and judge-equal in the parse view at pass 216's base `745f66ab`. At `57ce3ae8` it is **stage 1 in
    both views**. Nobody measured it after the two landings met: pass 216 and v11u216 ran their grids at `745f66ab`,
    before `0a682d73`.
  * Fresh cases NP/p01-p07 break the same way (14 case-views). With 217v switched off they read judge-equal or
    STRICT_EQUAL; with 217v on they read stage 1.
  * v11u212repro E/e16, a mover of pass 216's wide control, breaks the same way.
  * The refinement is **§ ndaPortQueryKeepsStamp221v** (`R11V221_NDAPORTQRY_OFF`). All 18 break case-views (NP
    p01-p07, n12 and e16) go back to golden's verdict: 9 elaborated case-views STRICT_EQUAL, and 9 parse case-views
    judge-equal with the pre-existing `depth` record.
  * fix2 writes law.bin's bytes on the other 116 fresh case-views, NP/p08's controls included.
  * Over all 27504 tools/probe case-views, the refinement fires only on these 18.
  * It fires on no gate database.
* **No break in the laws of passes 216 and 215 themselves.** 65 fresh cases in both views (130 case-views) were
  judged three ways: uhdm-cmp, uhdm-strictcmp field by field, and the downstream verdict.
  * From both landings off to law, 16 case-views enter EQUAL and 0 leave EQUAL.
  * No strict record is new on an aligned walk. Every stage-1 mover was read object by object: 0 fields moved away
    in the reachable dump.
  * Every rc is 0 in every state.
  * Downstream: q06, q10, q16 and q17 go DIVERGENT -> IDENTICAL, and 0 cases leave IDENTICAL.
  * The candidates the order-blind dump metric flagged were each read object by object and are not breaks
    (section 3.2). They are: generic-line count artifacts where golden lists a third import copy; the unreachable
    `\_weaklyReferenced` tail; and a wrong-to-wrong refinement decision.
* **The SeqDriver storage-order coin reproduces, and is cured** (section 7).
  * On the law binary, SeqDriver testflags drew the minority hash in 26 of 90 concurrent draws, and in 37 of 90
    with the command line without `--timescale`.
  * The difference is 15 `ref_var` twins minted in the address order of the `std::map` `pkgCloneBodyLocals9`
    (UhdmExporter.cpp, § cloneTfOwnVarListingIsUnbound195), exactly as v11u215 found.
  * **§ cloneTwinMintIdOrder221v** (`R11V221_TWINORDER_OFF`) walks the subroutines in `UhdmId` order.
  * SeqDriver testflags then writes one hash in 90 of 90 draws with fix1 and in 60 of 60 with fix2.
  * The uhdm-dump is identical to the law's draws, 0 lines ordered and 0 order-blind. No record moves.
* **Composition** (section 5):
  * Every claimed conversion belongs to its own landing. Pass 216 has none at status level; its MiniAmiq change is
    JOINT with 215. Pass 215 owns the 12 probe conversions and ibex_tracer d/t.
  * No conversion hides two laws cancelling each other: CANCEL is 0 at status level and 0 at byte level over 7452
    databases.
  * With both landings off (`R11U216_OFF R11V216_OFF R11U215_OFF`), the sweep reproduces `0a682d73`'s committed
    baselines 0/0/0 in all three stages. It also reproduces r11u216's pristine hashes byte for byte on all 11 UVM and
    Earlgrey row-modes.
  * With 215 off, the sweep reproduces `c4f26079`'s baselines 0/0/0.
* **Away census, both keys, both landings** (section 6): 0 records moved away on all 26 movers.
  * Chain-keyed strict records: 0 lost, 1048 toward (1096 flat).
  * Raw uhdm-dump lines (these see the unnamed objects inside typespec copies): 0 full names lost.
  * The only raw lines lost are 3 generic `|vpiParent:` lines on ibex_tracer, a count artifact of a row that is
    now STRICT_EQUAL.
  * The reversed positive controls read every toward count as lost.
  * Per landing: pass 216 has 165 chain-keyed and 189 flat toward (MiniAmiq, per mode), exactly its claim. Pass 215
    has its claimed 21, 40, 73, 60, 102, 80 and 13 per row.
* **Fence and process** (section 10): no fenced read.
  * Each of the four directories reads the fence and fails closed.
  * The frozen predictions match their claimed md5s, and their union equals this pass's census line for line (27
    rows) with identical per-law firing counts.
  * r11u215repro C/c01, c02 and v11u215repro CW/w01 name a law that is not in the source
    (§ caseItemWildConcatOnly215, dropped at integration).
  * All four directories' frozen binaries are gone. 41 of their drivers hard-code a `/tmp` scratch or binary path
    outside comments, and 44 if comments are counted (the integrator's nine and 35):
    9 in the pass-216 pair and 32 in the pass-215 pair (section 10 lists what each needs to re-run).

## 1. Binaries and states

Frozen `chmod 555` in `/tmp/r11u221_bin` before any measurement ([evidence/sweeps/binaries_md5.txt](evidence/sweeps/binaries_md5.txt)):

| binary | md5 | what |
|---|---|---|
| `law.bin` | `de9af7b93a576744d480028edeee07ed` | `57ce3ae8`, this worktree's build (system deps, `-j 2`): **byte-identical to the main tree's `build/slang-uhdm`** |
| `fix.bin` | `82d355011956de826e74140cb954815d` | `57ce3ae8` + § cloneTwinMintIdOrder221v alone (development step: its sweep G is kept as evidence) |
| `fix2.bin` | `d7566e763c11f41fa374d1113b68444d` | `57ce3ae8` + [fix.patch](fix.patch) (both refinements) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the base's comparator (= the main tree's build; not edited) |

Gate sweeps (`tests/sweep.sh --jobs 3`, all four stages, same-length workdirs `/tmp/r11u221_sw<tag>`). Every
`cmds.txt` names the sweep's own frozen wrapper: 3273 of 3273 `slang:` lines per sweep
([evidence/sweeps/cmds_audit.txt](evidence/sweeps/cmds_audit.txt)).

| tag | state | switches |
|---|---|---|
| H | law (+ the firing census) | `R11U216_TRACE R11U215_TRACE` |
| A | both landings off | `R11U216_OFF R11V216_OFF R11U215_OFF` |
| 6 | landing 216 off | `R11U216_OFF R11V216_OFF` |
| 5 | landing 215 off | `R11U215_OFF` |
| G | fix.bin (twin order only) | `R11V221_TRACE` |
| 2 | **fix2.bin (the fix)** | `R11V221_TRACE` |

Every sweep reads `law index STALE`, so `SWEEP_RC=1`. The cause is that this directory's cases name laws and
`tests/LAWS.md` is not regenerated here; the integrator runs `scripts/law_index.py`. Every stage reads 0 unexcused.

**The switch map, read from src** ([drivers/laws.py](drivers/laws.py) header):

* **Pass 216** (UhdmExporter.cpp).
  * `r11u216Law`: `R11U216_OFF` or the law's own switch. The five laws are § genScopeRangeQueryFold216
    `R11U216_GENRQFOLD_OFF`, § ndaRangeQueryFold216 `R11U216_NDARQFOLD_OFF`, § ndaSizeQueryFold216
    `R11U216_NDASIZEFOLD_OFF`, § tfArgOutsideClassOrder216 `R11U216_TFOUTCLS_OFF` (which also drops the clone law)
    and § tfArgImportCloneFollows216 `R11U216_TFIMPCLONE_OFF`.
  * `r11v216Law`: `R11V216_OFF` or its own switch. The two refinements are § tfArgOutsideClassKeyOrder216v
    `R11V216_CLSKEY_OFF` and § rqParamOpBoundAtCall216v `R11V216_PARAMOPLOC_OFF`.
  * `r11v216Law` does **not** read `R11U216_OFF`. Both refinements run only inside a pass-216 law's application,
    so `R11U216_OFF` alone restores the pristine bytes. Sweep 5 = `c4f26079`'s baselines and sweep A = r11u216's
    pristine hashes show this.
* **Pass 215** (EmitHelpers.h).
  * `r11u215On`: `R11U215_OFF` (cached) or the law's own switch. The laws are § pkgTdAliasLastWriter215
    `R11U215_TDALIAS_OFF`, § pkgImportEnumCloneLastWriter215 `R11U215_ENUMCLONE_OFF`,
    § impPatCopyFirstListingUnparented215 `R11U215_IMPPATFIRST_OFF`, § incDecOperandKeepsLvalueForm215
    `R11U215_INCDECROUTE_OFF`, § opIdxRecvElemFollowsPath215 `R11U215_OPIDXRECV_OFF` (which drops the elab sub-law
    too) and § opIdxRecvPlainElab215 `R11U215_OPIDXRECVELAB_OFF`.
  * The two refinements read plain `getenv`: § impPatMemberReadKeepsParent215v `R11V215_MEMBERREAD_OFF` and
    § enumCloneValueItemKeepsBare215v `R11V215_ENUMVALITEM_OFF`. They run only inside their law, so `R11U215_OFF`
    drops them.
  * **`R11V215_OFF` is read nowhere, and `R11U215_CASEWILDCAT_OFF` is read nowhere.** § caseItemWildConcatOnly215
    was dropped at integration. The shipped gate is § caseItemWildConcatOnly217v, `R11V217_CASEWILDCAT_OFF`.
  * § landingSwitchReach215 is the switch `R11V198_OFF` (ExprEmit.cpp `vsStampReducedCtxOnly198v`). It belongs to
    v11u198's refinement and is not dropped by `R11U215_OFF`.
* **This pass** (fix.patch, `src/R221.h`): `r11v221Law` reads `R11V221_OFF` or the refinement's own switch.
  `R11V221_TRACE=<dir>` names every firing in `<pid>.221`.

## 2. The gates

All sweeps are compared against the committed baselines at `57ce3ae8`. Logs, with progress lines dropped and 0 fenced
lines, are in [evidence/sweeps/](evidence/sweeps/).

| gate | law (sweep H) | fix2 (sweep 2) |
|---|---|---|
| (1) build | `de9af7b93a57`, byte-identical to the main tree | `d7566e763c11`; rebuilt from a fresh `57ce3ae8` worktree + `git apply fix.patch` (section 4.3) |
| (2) probe | EQUAL 3422 / STRICT_NOTEQUAL 665, `regressions=0 conversions=0 changes=0` | the same; probe.csv byte-identical to H's |
| (3) surelog | 929 + 25, `0 / 0 / 0` | `0 / 0 / 0`; surelog.csv differs from H only in the LowMemLib / LowMemPkg testflags detail text (the workdir path) |
| (3) uhdm2rtlil | 1598 + 8, `0 / 0 / 0` | `0 / 0 / 0`; uhdm2rtlil.csv byte-identical |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 | the same; downstream.csv byte-identical to H's |
| (5) uhdm-cmp on every touched row | 0 lines on all 13 corpus movers | 0 lines on the same 13 ([evidence/gates/uhdmcmp_touched.txt](evidence/gates/uhdmcmp_touched.txt)) |
| (6) byteverify `SELFCHECK=1`, fence-free mirrors (`fenced_skipped=8`) | H vs A: **13 / 2560**, exactly the prediction frozen before the comparison; probe 13 / 4087; lanes 1 / 805 (section 5) | 2 vs H: **5 / 2560**. These are MiniAmiq d/t and SeqDriver d/t, predicted by the fix's census, with uhdm-dumps identical (0 lines ordered and order-blind), plus the Scoreboard default svunit coin (92 ordered, 0 order-blind). Probe 0 / 4087, lanes 0 / 805 |
| canaries | surelog `ok=52 changed=0`, uhdm2rtlil `ok=16 changed=0`; `ctcan2.sh` `EXPECT_UNKNOWN=1` / `=6` PASS | the same ([evidence/gates/](evidence/gates/)) |

**The prediction (law).** [evidence/census/predicted_movers_H_vs_A.txt](evidence/census/predicted_movers_H_vs_A.txt)
has md5 `2dba817b87f9` and was frozen at 2026-09-29T02:57:42Z, before any byte comparison
([predicted_frozen_at.txt](evidence/census/predicted_frozen_at.txt)). It is sweep H's own firing census
(`R11U216_TRACE`, `R11U215_TRACE`), with `diag*` lines excluded and 0 fenced lines. It names 27 rows: 13 corpus
row-modes, 13 probe cases and 1 downstream lane.

* It equals the union of the two passes' frozen predictions **line for line**: r11u215repro `predicted_movers.txt`
  (md5 `99fb9419`) and r11u216repro `predicted.txt` (md5 `556a7184`).
* **Every per-law firing count is identical.**
* The movers of H against A are exactly those 27 databases.

**The prediction (fix2).** [evidence/fix/predicted_movers_fix2.txt](evidence/fix/predicted_movers_fix2.txt) has md5
`004f1f3cf6af` and was frozen at 03:45:57Z, before sweep 2 was compared. It is sweep 2's `R11V221_TRACE` census.

* § ndaPortQueryKeepsStamp221v fires on **no gate database**.
* § cloneTwinMintIdOrder221v fires on 12 databases: 8 probe cases whose twins come from 2-4 subroutines, and
  MiniAmiq d/t and SeqDriver d/t (34 twins from 34 subroutines). Of these, 5 walked the address map out of
  `UhdmId` order in that run (`reordered=1`).
* The movers are the 4 corpus `reordered=1` rows, as predicted. v195_d_tfitem (`reordered=1`) did not move against
  H, whose own draw happened to walk the same order.
* The unpredicted Scoreboard default is the known svunit coin; the fix does not fire there.

## 3. The laws, fresh cases, three axes

There are 65 fresh cases in [cases/](cases/), none of them in the pass grids or their verifiers' grids. Each case
names its laws on its first line; `W/w06` is two files via `args`, and its second file is CRLF. Goldens come from the
pinned Surelog with check_probe's arguments, in both views (`EL=1`: `-elabuhdm` / `--elabuhdm`).

[drivers/grid.py](drivers/grid.py) runs every case under these states: every law on; each named law's own switch;
the landing's switches; every pair of named laws (under X/); and both landings off (`ALLOFF`). It scores each state
against the law. When both walks are aligned, the scoring uses strict records (TOWARD / AWAY / MIXED / UNMASK /
BYTES-ONLY). When either state is stage 1, it uses the order-blind uhdm-dump distance (STAGE1-CLOSER / SAME /
AWAY).

The order-blind line metric is not position-aware, so **every non-TOWARD cell was re-read object by object**
(section 3.2):
* [drivers/dumpaway2.py](drivers/dumpaway2.py) gives the reachable-dump multiset;
* [drivers/oppos.py](drivers/oppos.py) compares the i-th listed pattern copy of ours with golden's i-th;
* [drivers/ddr.sh](drivers/ddr.sh) gives ordered, id-stripped dump diffs cut at the `\_weaklyReferenced` tail.

Raw outputs: [evidence/grid/raw/](evidence/grid/raw/) (law.bin) and [raw_fix/](evidence/grid/raw_fix/) (fix2.bin).
Summaries: [grid_summary_law.tsv](evidence/grid/grid_summary_law.tsv), [grid_summary_fix2.tsv](evidence/grid/grid_summary_fix2.tsv).

**Judge level over the 130 case-views** (both landings off -> law):

| off | law | case-views |
|---|---|---|
| stage 1 | stage 1 | 105 |
| `col` | **EQUAL** | 6 (D/d01-d03 both views) |
| `line` | **EQUAL** | 6 (W/w03, w05, w06 both views) |
| stage 1 | **EQUAL** | 3 (Q/q14 both views, Q/q17 parse) |
| `fullname` | **EQUAL** | 1 (R/r04 parse) |
| `line` | `fullname` | 4 (W/w01, w02: the pre-existing module-class and import-clone name face) |
| `fullname` | `fullname` | 3 (R/r03 both views, R/r04_el) |
| `fullname` | `endcol` | 2 (R/r01 both views: the call-in-index span, pass 215's residue 6) |

**No case-view leaves EQUAL.** The rc is 0 on every case-view in every state.

### 3.1 Per law

| law (switch) | fresh cases (shapes) | fired case-views | law vs its switch off | verdict |
|---|---|---|---|---|
| § genScopeRangeQueryFold216 (`R11U216_GENRQFOLD_OFF`) | Q/q01 (typedef and typedef-of-typedef variables), q02 (packed-struct variable, packed array of structs), q03 (a 2-D packed variable, `$increment` control, gen-case), q05 (hex / binary / octal / sized bounds), q06 (depth 3: gen-for > gen-if > gen-case; a net, a port, a parameter), q07 (an interface twice, different widths), q09 (the generate block written by a macro, the net in an included header), q12 (member and bit-select operands: declined), q13 (onto an output variable, a `reg` output, a signed net with a negative bound), q16 (depth-2 parameters `[W*2-1:W]`, `[W+3:W-1]`, a qualified bound), q18 (a child twice, a gen-case), X/x03 | 20 (q03 q05 q06 q07 q09 q12 q13 q16 q18 x03, both views) | STAGE1-CLOSER 20; reachable dump distance down in every one (q06: the only reachable difference left is the nested-scope parameter's typespec location) | holds; **under-reach**: q01, q02 (golden folds a typedef-typed or packed-struct operand, the law declines); downstream q06 and q16 DIVERGENT -> IDENTICAL |
| § ndaRangeQueryFold216 (`R11U216_NDARQFOLD_OFF`) | Q/q05, q07, q08 (a child twice, a W-1 port, a localparam bound), q09, q10 (a ranged localparam, a typedef-typed variable, a net in a gen-case block), q11 (unpacked-array operands: declined), q12, q15 (CRLF, two declarators), q17 (module and interface parameters), q18, X/x02 | 16 (q05 q07 q08 q09 q10 q17 q18 x02) | q17 parse stage 1 -> **STRICT_EQUAL**, STAGE1-CLOSER 14; q05_el reads STAGE1-AWAY on the whole dump only | holds; q05_el read object by object (3.2): the reachable dump moves 16 -> 12 toward golden. The growth is 3 orphan `cont_assign` copies in the unreachable `\_weaklyReferenced` tail. Downstream q10 and q17 DIVERGENT -> IDENTICAL |
| § ndaSizeQueryFold216 (`R11U216_NDASIZEFOLD_OFF`) | Q/q04 (multi-dimensional unpacked arrays, `$size(m, 2)`), q14 (ascending and descending vectors onto narrower, signed and explicit-logic nets), q15 | 6 | q14 stage 1 -> **STRICT_EQUAL** both views; q04, q15 STAGE1-CLOSER | holds; **pass 216's f14 confirmed**: golden folds `$size(m)` of `logic [1:0] m [2][3]` to `UINT:2`, and the law declines (residue) |
| § rqParamOpBoundAtCall216v (`R11V216_PARAMOPLOC_OFF`) | Q/q16, q17, q18 | 4 (q17, q18) | TOWARD (q17 parse -> STRICT_EQUAL), STAGE1-CLOSER 3; q16 unfired (a depth-2 parameter reads the bare value, no location) | holds |
| § tfArgOutsideClassOrder216 (`R11U216_TFOUTCLS_OFF`) | W/w01 (an outside package named `work`: key `work::N` < `work@top::M`), w02 (`Zq` < `work@` by byte), w03 (nested classes `q::Z::Y::A` two levels deep), w04 (classes in a program and an interface), w05 (`p1`, `p`, `p_a`: digit, colon and underscore in the key), w06 (two files, the second CRLF, nested outside class, an importer calling the function), w07 (MiniAmiq's shape with an interface importer), X/x01 | 14 | TOWARD 10 (w03, w05, w06 line -> **STRICT_EQUAL** both views; w01, w02 line -> fullname: every location golden's), STAGE1-CLOSER 4 (w07, x01) | holds; w04 unfired (program and interface classes, stage 1) |
| § tfArgOutsideClassKeyOrder216v (`R11V216_CLSKEY_OFF`) | W/w01, w02, w03, w05, w06 | 2 (w03) | TOWARD (w03: the nested class compiles inside its outermost class `Z`, whose key sorts between `B` and `M0`) | holds; on w01, w02, w05, w06 the key order and the name order agree (no byte moved) |
| § tfArgImportCloneFollows216 (`R11U216_TFIMPCLONE_OFF`) | W/w06, w07 | 4 | TOWARD (w06 -> STRICT_EQUAL), STAGE1-CLOSER (w07) | holds |
| § pkgTdAliasLastWriter215 (`R11U215_TDALIAS_OFF`) | A/a01 (every writer kind, names in reverse kind order), a02 (nested classes two levels deep, `$unit` and module-local), a03 (a two-package re-export chain, an interface port), a05 (`$unit` aliases, a `$unit` class), a06 (class-specialization aliases in a module, an interface and a program), a07 (two modules and two interfaces out of name order, a program), X/x01 | 14 | STAGE1-CLOSER 4 (a03, a06), STAGE1-SAME 8; a07 fires with no byte moved (2) | holds; a06: golden `work@m.p::c8_t` = law (pristine `p::p::c8_t`); a01, a07: the drain already wrote golden's name; **a02 confirms v11u215's residue 3** (golden `work@outer::m:inner::p::alias_t`, law and pristine `work@m.p::`); a05: golden `work@uc::p::alias_t` for the enum alias, wrong on both (r11u215's residue 1, the sister's drain); x01: the renamed refs sit in the unreachable tail only |
| § pkgImportEnumCloneLastWriter215 (`R11U215_ENUMCLONE_OFF`) and § enumCloneValueItemKeepsBare215v (`R11V215_ENUMVALITEM_OFF`) | A/a04 (value-item imports into a module, an interface and a package, a wildcard in a later package), a08 (a value-item package wildcard-imported by another), a09 (three packages, a program, an interface, a module) | 0 | unfired on all six case-views (no clone candidate: the listing shapes are stage 1 at the base) | holds (no reach) |
| § impPatCopyFirstListingUnparented215 (`R11U215_IMPPATFIRST_OFF`) | I/i01 (one parameter imported into two modules and a package), i02 (unpacked-struct, array-of-struct and packed-array patterns: controls), i04 (a same-named module parameter and a localparam copy), i05 (nested, default and replication patterns through two packages, in a gen loop), i06, IR/mr1-mr6, X/x02 | 20 (i01 i05 i06 IR x02) | **position judge: 22 copies toward, 0 away**, and 4 copies of i05_el renamed toward ([evidence/grid/pattern_positions_law_vs_alloff.txt](evidence/grid/pattern_positions_law_vs_alloff.txt)); every line-metric STAGE1-AWAY cell is golden listing a third import copy | holds; i02, i04 unfired (controls) |
| § impPatMemberReadKeepsParent215v (`R11V215_MEMBERREAD_OFF`) | I/i03 (a member read in another module and in a generate condition), i06 (a module function, a qualified `hp::PA.a`, an `always_ff` read), IR/mr1-mr6 (one context each: `always_ff`, a module function, a qualified continuous read, a continuous read, a localparam, an `initial`) | 14 | the refinement keeps the parameter parented; golden's first instance copy is **unparented** in all seven module-read shapes, a localparam read included; pristine parented too | **wrong to wrong, not a break**: the predicate "read by member select anywhere" is broader than golden's. Golden's rule for these module-side reads is undecoded: dropping the refinement is right on mr1, mr2, mr4, mr5, mr6 but wrong on mr3's second copy ([memberread_refinement_positions.txt](evidence/grid/memberread_refinement_positions.txt)). Residue |
| § incDecOperandKeepsLvalueForm215 (`R11U215_INCDECROUTE_OFF`) | D/d01 (system-task arguments, indices on both sides, if / while conditions, a for step, a return), d02 (nested struct and class-handle members in a module's `initial`, `always` and function), d03 (a member handle's method call, nested calls, a ternary, a case expression), d04 (a `$unit` function, a package-qualified variable: control) | 6 | **col -> STRICT_EQUAL** 6 | holds; d04 unfired (stage 1: the `$unit` function face) |
| § opIdxRecvElemFollowsPath215 (`R11U215_OPIDXRECV_OFF`) | R/r01 (parameter, localparam, call, nested and modulo indices), r02 (module-local class, a function in a generate block, genvar indices), r03 (two-level receivers `a[i-1].b[j+1].m()`, a `this.` index, a `$unit` class), r04 (plain and operation indices, a static method, an interface-scope class), X/x03 | 10 | TOWARD 4 (r01 both views -> `endcol`; r03 parse; r04 parse -> **STRICT_EQUAL**), STAGE1-CLOSER 4 (r02, x03), MIXED 2 | holds; the MIXED cells (r03_el, r04_el) are wrong to wrong: golden names a two-level or interface-class receiver's index through the element (`...m::a::i`, `...get::fs::j`), pristine `work@uc::f::i`, law `...m::i` (v11u215's residue 5 family) |
| § opIdxRecvPlainElab215 (`R11U215_OPIDXRECVELAB_OFF`) | R/r02, r04 | 1 (r04_el) | TOWARD | holds; r02 unfired (module-local class: r11u215's declined shape) |

### 3.2 The line-metric flags, read object by object

* **I/i01, i05, i06, IR/mr1-mr6 (STAGE1-AWAY, +1 to +3 lines).** In these shapes golden lists **three** import
  copies of the pattern parameter where ours lists two: first unparented, then two parented. The law unparents
  our first copy as golden does, which removes generic `|vpiParent:` / `\_operation` lines golden still holds for
  its third copy. [oppos.py](drivers/oppos.py) aligns the copies by position: **toward 1-4 per case, away 0**.
  I/i05_el is the same law in the elaborated view, where golden's first copy is parented at `work@dut.g[0].u`. There
  the law renames `work@dut.u` to golden's name.
* **Q/q05_el (STAGE1-AWAY, 40 -> 130 whole-dump lines).** In the reachable dump the law moves 28 -> 12 lines from
  golden (all off), and 16 -> 12 against the nda switch alone. The folded bound becomes golden's `HEX:A` / `2'd1`
  constant, sized to the net. The growth is 3 orphan `cont_assign` copies left in the `\_weaklyReferenced` tail,
  which no reader reaches (neither the judge, the strict walk nor the plugin). Also, where golden shares one bound
  object between the generate-scope assignment and the net initializer, ours writes two objects with golden's
  fields.
* **Q/q03, q07, X/x02 (dumpaway2 lost 1-3 generic lines).** q07: the shared bound's parent is golden's
  (`cont_assign 7:12`). x02: `$low(PR)` folds to golden's `constant 5:22 UINT:2`, where pristine kept the call with
  the value as argument. The lost lines are generic counts.
* **X/x01 (pkgTdAlias STAGE1-SAME, newbad 5):** the renamed refs sit in the unreachable tail only.

### 3.3 The cross-ground pairs (X/, every pair switched off, both views)

| case | pair | reading |
|---|---|---|
| x01 | § tfArgOutsideClassOrder216 + § pkgTdAliasLastWriter215: an alias enum typedef read by class-method formals in its own package and another package, imported by a module and an interface | the writer law CLOSER alone (dump 259 -> 219); the alias stamp only renames refs in the unreachable tail; together = the writer law's bytes plus the tail. The alias names are golden's `work@top.p::e_t` in every state |
| x02 | § ndaRangeQueryFold216 + § impPatCopyFirstListingUnparented215: nets initialized by `$high`, `$low`, `$size` of an imported packed-struct pattern parameter and of a ranged imported parameter | each alone CLOSER, both CLOSER still (1594 -> 1584 parse, 1700 -> 1649 elaborated); `$high(PA)` and `$size(PA)` of the struct pattern are declined (golden keeps `$size(PA)` with a stamp); the position judge reads the pattern copy toward |
| x03 | § genScopeRangeQueryFold216 + § opIdxRecvElemFollowsPath215 in one generate scope (a range-query assignment and a function whose class receiver is indexed by operations) | each alone CLOSER, both CLOSER still (47 -> 18, 75 -> 22) |

No pair's joint effect differs in sign from its members'.

## 4. The break and the refinements

[fix.patch](fix.patch) holds `src/R221.h` and two refinements (UhdmExporter.cpp, ModuleEmit.cpp). `R11V221_OFF`
drops both, each has its own switch, and `R11V221_TRACE=<dir>` names every firing. It is not applied.

### 4.1 The break: § ndaQueryFoldsNoStamp217v drops a stamp golden writes (refined by § ndaPortQueryKeepsStamp221v, `R11V221_NDAPORTQRY_OFF`)

* **The composition.**
  * Pass 216's § ndaRangeQueryFold216 folds a net-declaration range query where golden folds it. A query it
    declines keeps our `sys_func_call`.
  * § ndaSysCallNetTs212 (pass 212) stamps a kept call with the net's typespec, as golden's writeCont_assign does.
  * § ndaQueryFoldsNoStamp217v (r11u217, landed at `0a682d73`, 16 minutes before pass 216 landed on top of it)
    drops that stamp on **every** `$high`, `$low`, `$left`, `$right` and `$size`. Its decode was "golden folds
    all five, 0 range-query calls in golden".
* **What golden does, measured** ([evidence/breaks/port_query_shape_grid.txt](evidence/breaks/port_query_shape_grid.txt),
  80 scratch shapes x 2 views, law against `R11V217_NDAQUERY_OFF`):
  * For a **port** whose type has an unpacked dimension, golden keeps the call and stamps it with
    `ref_typespec (work@dut)`, the actual being the net's logic_typespec. The query is `$high`, `$low`, `$left` or
    `$right`. The port is an input `[5]`, `[0:4]`, `[2][3]` or of scalar elements, an output, non-ANSI, or a
    child's port instantiated from a parent.
  * `uhdm-cmp` reads `LHS: ref_typespec (work@dut) ... RHS: <null>` on the law's database.
  * The same query of a local unpacked variable is folded by golden, to Surelog's bit count `UINT:20` for
    `logic [3:0] a [5]`. `$size` of these ports is folded, and § ndaSizeQueryFold216 matches it. So is every query
    § ndaRangeQueryFold216 folds (packed ports and variables, ranged parameters).
* **Break cells (legal SV, the law-off state right, the law wrong):**

  | case | 217v on (law.bin) | 217v off / fix2 |
  |---|---|---|
  | r11u216repro NQ/n12 (pass 216's own grid: `$left` of `input logic [3:0] i [5]`) | stage 1 / stage 1 | `depth` (judge-equal) / **STRICT_EQUAL** (84 objects) |
  | v11u212repro E/e16 (pass 216's wide-control mover, second net) | stage 1 / stage 1 | `depth` / **STRICT_EQUAL** (125) |
  | NP/p01-p07 (fresh: four queries of `[5]`, `[0:4]` with two declarators, `[2][3]`, scalar elements, an output port, non-ANSI, a child twice) | stage 1 / stage 1 (14 case-views) | `depth` / **STRICT_EQUAL** (14 case-views) |

  Pass 216 measured n12_el STRICT_EQUAL at `745f66ab`, and its wide control measured e16_el EQUAL. Both went to
  stage 1 when `0a682d73` and `c4f26079` composed, and no later sweep saw it, since neither case is in tests/probe.
  The parse view's remaining `depth` record is pre-existing: it is n12's pristine record at `745f66ab`.
* **Refinement.** In `emitContAssigns`' net-declaration branch, 217v does not drop the stamp when the query is
  `$high`, `$low`, `$left` or `$right` and its argument names a port of the instance body (`getPortList`,
  `internalSymbol`) whose type is an unpacked array. Traced as `ndaPortQueryKeepsStamp221v <net> <query> <port>`.
* **Measured** (fix2.bin):
  * The 18 break case-views get golden's verdict: the NP p01-p07, n12 and e16 rows of the table above.
  * NP/p08's controls keep the law's bytes: a local unpacked variable, a packed port, `$size` of the unpacked port
    and a generate-scope net.
  * `R11V221_NDAPORTQRY_OFF` and `R11V221_OFF` each write law.bin's bytes on all 16 NP case-views.
  * Over the 130 fresh case-views, fix2 differs from law.bin on exactly the 14 NP break case-views.
  * **The wide firing census** covers every case directory under tools/probe (13752 x 2 = 27504 case-views, fence
    fail-closed; [evidence/fix/firecensus_fix2_traces.txt](evidence/fix/firecensus_fix2_traces.txt)). The
    refinement fires only on n12, e16 and NP p01-p07, all break cells. The rc is the same on law and fix2 for every
    one of the 512 non-zero rc case-views: 10 x 139, 278 x 3, 224 x 4 on both.
  * The refinement fires on no gate database (section 2).
  * Downstream, NP p01-p07 are IDENTICAL in every state: the plugin does not read the stamp there.

### 4.2 The SeqDriver coin: § cloneTwinMintIdOrder221v (`R11V221_TWINORDER_OFF`)

* **The mechanism.** § cloneTfOwnVarListingIsUnbound195 (UhdmExporter.cpp) walks `pkgCloneBodyLocals9`, a
  `std::map` keyed by the clone subroutine's address. For every listing slot the body block also lists, it mints an
  unbound twin with `s.MakeRef_var()`. The twins' UhdmIds, and so the serialized storage order, follow the heap
  layout (section 7).
* **Refinement.** Walk the subroutines in `UhdmId` order: one `std::stable_sort` of the keys.
  * The same objects are minted with the same fields.
  * Traced as `cloneTwinMintIdOrder221v subroutines=<n> with_twins=<m> twins=<k> reordered=<0|1>`. Only a database
    with `with_twins >= 2` can change; `reordered=1` says this run's address walk differed from the id order.
* **Measured** (section 7):
  * SeqDriver testflags writes one hash in 90 / 90 (fix.bin) and 60 / 60 (fix2.bin) concurrent draws. The law drew
    the minority in 26 / 90.
  * The fix's bytes are uhdm-dump-identical to both law draws, 0 lines ordered.
  * Storage order: fix2 = the law's majority draw except 2 twins that the law's majority itself minted out of id
    order (ids 298159/298160).
  * No record, field or listing moves anywhere: every gate csv is identical, and the 4 corpus movers read 0 ordered
    dump lines.

### 4.3 Rebuild identity and switch reach

* A fresh `57ce3ae8` worktree with `git apply fix.patch` (clean) and a fresh cmake builds **`d7566e763c11`,
  byte-identical to fix2.bin** ([evidence/fix/rebuild_identity.txt](evidence/fix/rebuild_identity.txt)).
* `scripts/law_index.py --check` reads STALE there, as it does on any tree carrying new `§` names: the integrator
  regenerates `tests/LAWS.md`.

* `R11V221_OFF` writes law.bin's bytes on all 16 NP case-views, as does each refinement's own switch.
* `R11V221_TWINORDER_OFF` restores the address walk. fix2 under it draws law.bin's two SeqDriver hashes again, 17 of
  60 on the minority ([seqdriver_draws_fix2_TWINORDER_OFF_testflags.txt](evidence/determinism/seqdriver_draws_fix2_TWINORDER_OFF_testflags.txt)).
* The gate sweeps show that neither refinement moves a judged field: sweep 2 against H has csvs identical but the
  LowMem detail text, and 0 ordered dump lines on every mover.

## 5. Composition

### 5.1 Status level ([drivers/compose.py](drivers/compose.py), [evidence/compose/compose_status.txt](evidence/compose/compose_status.txt))

| corpus | conversions A -> H | attributed | changes A -> H |
|---|---|---|---|
| probe | 12 | **OWN215 12** (g202_e_head, g206_b_dedup, a3, a4, a5, a6, a1, a7, v136_g_param, v202_6_twotd, v206_d_selfname, e08_explicit_import: pass 215's twelve by name) | OWN215 1: g202_a_kinds `fullname(6) -> fullname(4)` |
| surelog | 0 | - | OWN215 7: BuildUVMPkg d/t `col(51) -> line(31)`, Scoreboard d `fullname(188) -> fullname(137)`, SeqDriver d/t `fullname(61) -> endline(59)`, SimpleUVM d/t `fullname(236) -> fullname(185)`; **JOINT216+215** 2: MiniAmiq d/t `file(75) -> endline(59)` (216 off: `file(73)`; 215 off: `fullname(61)`) |
| uhdm2rtlil | 2 | **OWN215 2**: ibex_tracer d/t `CMP_EQUAL` | - |

**CANCEL 0** in all three stages: no row reads the same (status, strict) in H and A but differently with one landing
off.

### 5.2 Byte level ([drivers/bytecancel.py](drivers/bytecancel.py), [evidence/compose/compose_bytes.txt](evidence/compose/compose_bytes.txt))

The census covers 7452 databases: probe, both corpora (fence-free) and the downstream slang lanes. **CANCEL 0.**

| attribution | probe | corpus | lanes |
|---|---|---|---|
| OWN215 | 13 | 10 (BlackBePipeInt, BuildUVMPkg, SeqDriver, SimpleUVM, ibex_tracer, each d/t) | ibex_tracer |
| JOINT216+215 | | MiniAmiq d/t (both landings fire there, as predicted) | |
| JOINT216+215 | | Scoreboard d, a 215 mover that reads JOINT only because sweep 6 drew the svunit coin (`ad13c87faad6` vs H's `b6fe2cd0adf5`: 92 ordered, **0 order-blind** lines); pass 216 fires nowhere on it | |

Against A, the byte movers of H are exactly the 27 predicted databases: 13 of 2560 corpus, 13 of 4087 probe and 1 of
805 lanes ([evidence/movers/](evidence/movers/)). Each landing alone moves as follows:
* 216 alone (H vs 6): MiniAmiq d/t, plus the Scoreboard coin.
* 215 alone (H vs 5): the 24 OWN215 databases, plus MiniAmiq d/t.

### 5.3 The switches are exact

* **Sweep A (both off) against `0a682d73`'s committed baselines**: probe, surelog and uhdm2rtlil all read
  `regressions=0 conversions=0 changes=0`, and the downstream verdict diff is 0
  ([evidence/compose/states_vs_committed_baselines.txt](evidence/compose/states_vs_committed_baselines.txt)).
* A's corpus hashes are **r11u216's pristine hashes at `745f66ab`**, byte for byte, on all 11 UVM and Earlgrey
  row-modes:

  | row | hashes |
  |---|---|
  | Earlgrey_0_1 | `5bb5b3b989b4` / `1961f9984a06` |
  | MiniAmiq | `4db8f413be66` (both modes) |
  | SeqDriver | `602689e9f8a3` / `69640b807a50` |
  | SimpleUVM | `3c1292b40f57` / `61f25c6da659` |
  | Scoreboard d | `50f1e9cd5845` |
  | BuildUVMPkg | `c020394bcdbc` (both modes) |

  `0a682d73` is `745f66ab` plus r11u217's refinements, which fire on no corpus database.
* **Sweep 5 (215 off) against `c4f26079`'s baselines**: 0/0/0 in all three stages, downstream diff 0.
* Sweep 6 (216 off) reads exactly pass 216's change reversed: MiniAmiq d/t `endline(59) -> file(73)`.
* `R11U216_OFF` drops both v11u216 refinements by construction, since they run inside its laws.
  `R11U216_OFF` alone writes the same bytes as `R11U216_OFF R11V216_OFF` on all 200 case-views of r11u216repro
  and v11u216repro ([evidence/compose/switch_reach_216.txt](evidence/compose/switch_reach_216.txt)).
  `R11V215_OFF` does not exist; `R11U215_OFF` alone is sweep 5's state.

### 5.4 The writer rule composed with r11u214's § enumTdLastWriter214

r11u214's law patch had **not landed** at this base: main HEAD `57ce3ae8` throughout, and no r11u219 landing. So the
two implementations are not both in the source. v11u215 measured the composition at `c4f26079`: the probe csv was
byte-identical to r11u214's alone, and the rules agree wherever both write. That stands. The residue this pass
re-measured is r11u215's residue 1: the class-last enum cells (fresh A/a05, `work@uc::` in golden; ours `work@m.`
under both). That cell is r11u214's `enumImportParentDrain180` replay, to be composed when r11u219 lands.

## 6. The CHANGES: unmasking proofs and the away-moved-record census

### 6.1 Every claimed CHANGE is a strict improvement ([drivers/unmask2.py](drivers/unmask2.py), [evidence/unmask/](evidence/unmask/))

golden against each database, records with walk indices:

| comparison | probe | surelog | uhdm2rtlil |
|---|---|---|---|
| 216 (6 -> H) | - | **SUBSET 2**: MiniAmiq d/t `file(73) -> endline(59)`, 73 -> 59 records, 0 new, first record #899 (`uvm_severity`, golden uvm_globals.svh 271:61) gone | - |
| 215 (5 -> H) | CONVERSION 12, **SUBSET 1** (g202_a_kinds 6 -> 4) | **SUBSET 9**: BuildUVMPkg d/t 51 -> 31, MiniAmiq d/t 61 -> 59, Scoreboard d 188 -> 137, SeqDriver d/t 61 -> 59, SimpleUVM d/t 236 -> 185 (0 new records on every one; walks diverge at the same index before and after) | CONVERSION 2 (ibex_tracer d/t, 13 -> 0) |
| both (A -> H) | CONVERSION 12, SUBSET 1 | SUBSET 9 (MiniAmiq d/t 75 -> 59) | CONVERSION 2 |

No CHANGE needed an unmasking argument: every one is a strict subset. The first records after the landings are
MiniAmiq #11306, SeqDriver #11289 (the `phase_state_change` macro-argument endline), SimpleUVM #458, Scoreboard #466
(`UVM_MACRO_NUMFLAGS`) and BuildUVMPkg #26855 (`this_type` class_typespec line)
([evidence/residues/heads_H.txt](evidence/residues/heads_H.txt)).

### 6.2 Away-moved-record census, both keys, both landings ([evidence/away/](evidence/away/))

The chain-keyed census is [drivers/awayrows.py](drivers/awayrows.py), map 12's method: strict records keyed by their
ancestor chain, and flat. The raw census is [drivers/rawaway.py](drivers/rawaway.py): uhdm-dump lines of the
reachable dump with ids and paths dropped, and their `vpiFullName` values. It sees the unnamed objects inside typespec
copies that the strict walk canonicalises; r11u214's 12 flat-key losses were of this kind.

| landing | databases | chain lost / toward | flat lost / toward | raw lines lost | raw full names lost / gained |
|---|---|---|---|---|---|
| 216 (6 -> H) | 3 (MiniAmiq d/t, Scoreboard coin) | **0** / 165 per mode | **0** / 189 per mode | **0** (142 gained per mode) | **0** / 0 |
| 215 (5 -> H) | 26 | **0** / 21, 40, 73, 60, 102, 80, 13 per row-mode | **0** / the same | 3 (ibex_tracer d/t: generic `\|vpiParent:` count, below) | **0** / 1-98 per database |
| both (A -> H) | 26 | **0** / 1048 | **0** / 1096 | 3 (the same) | **0** |
| positive control (H -> A) | 26 | **1048 lost** | **1096 lost** | reads every gained line lost | reads every gained name lost |

The 13 probe movers read 0 / 0 on strict records, because their renamed refs sit inside canonicalised typespec
copies. They read 1-3 full names gained and 0 lost in the raw census, where the reversed control names them (for
example `work@a3_top.p49c::mmm_3_t`).

**The 3 raw lines on ibex_tracer** are generic `|vpiParent:` lines. The law unparents 13 op refs golden leaves
unparented, and ibex_tracer d/t is STRICT_EQUAL on the law: every strict record is golden's. The line count of
`|vpiParent:` across the whole reachable dump falls below golden's because of objects elsewhere, so the
count-min reads 3. 0 full names are lost.

**Nothing moved away. No refinement is owed to either landing's corpus movers.**

The fix (sweep 2 vs H, [rawaway_fix2_H_to_2.txt](evidence/away/rawaway_fix2_H_to_2.txt)) reads 0 lost, 0 gained on
every mover (storage only).

## 7. Determinism

All runs use the harness's own command lines and cwd ([drivers/det.sh](drivers/det.sh): three concurrent runs per
row-mode against sweep H's recorded lines; [drivers/draw.sh](drivers/draw.sh): SeqDriver batches of three concurrent
draws; [drivers/drawrow.sh](drivers/drawrow.sh): any row). Evidence is in [evidence/determinism/](evidence/determinism/).

| row-mode | law.bin | fix2.bin | reading |
|---|---|---|---|
| Earlgrey_0_1 d / t | 1 / 1 (`5bb5b3b989b4` / `1961f9984a06`, = H) | 1 / 1 (the same bytes) | deterministic; neither landing nor the fix fires there |
| BuildUVMPkg d / t | 1 (`56f8e74321b6`) | 1 (the same) | deterministic |
| SimpleUVM d / t | 1 / 1 (`3db894279104` / `0349d31312a3`) | 1 / 1 (the same) | deterministic |
| **SeqDriver t** | **2 hashes**: 26 of 90 draws on `97dadf469be5` (batches of 3), 37 of 90 without `--timescale`, 1 of 3 in det.sh | **1 hash in 60 / 60** (`403a3f56a22f`); fix.bin 90 / 90 twice | **the coin, reproduced and cured**: the law's two draws are uhdm-dump-identical, 0 lines ordered. ord.cpp shows 15 `ref_var` twins (UhdmIds 298130-298144, parents the clone subroutines 206377-226381) minted in another order ([storage_order_diffs.txt](evidence/determinism/storage_order_diffs.txt)). With `R11V221_TWINORDER_OFF=1`, fix2 draws the law's two hashes again (17 of 60 minority) |
| SeqDriver d (`--single-unit`) | 1 in 90 (`0625065ac83c`) | 1 in 90 (`94ab12e80988`) | the default line walks the address map in one order on every draw; the fix's id order is another single order, uhdm-dump-identical to the law's |
| MiniAmiq d / t | 1 hash in 30 sequential draws each (`53b61821ce52`); 2 hashes under the concurrent det load (`646fdab8f9ea`) | 1 in 30 sequential (`bd6497e2de0f`); 2 under load (`14665f826073`) | **a second, pre-existing coin, not cured and not the twins**. The pair's uhdm-dumps are identical (0 ordered, 0 order-blind), and their ord.cpp storage lists are identical too. The symbol tables differ in 842 lines, symbols 41005-41394: the interning order of computed full names (`uvm_pkg::uvm_report_object::uvm_report_info::verbosity::UVM_MEDIUM` ...). r11u216 saw it on its pristine binary at `745f66ab` (`322b782ebb31` / `4db8f413be66`) and v11u216 on its fix. Reader-invisible |
| Scoreboard d | 3 hashes over det and sweeps (`ec430b13a2e0`, `ad13c87faad6`, H's `b6fe2cd0adf5`) | 2 under det (`ad13c87faad6`, `ec430b13a2e0`) | the known svunit listing coin: 92 ordered and **0 order-blind** lines; neither landing fires on Scoreboard |

**No new reader-visible coin.** The SeqDriver testflags coin v11u215 found is reproduced at the base and cured by
§ cloneTwinMintIdOrder221v. The cure moves no record, as section 4.2 shows.

## 8. Downstream

The harness's own `one()` runs through [drivers/dscase.py](drivers/dscase.py) with a fresh `GOLDEN_CACHE`, in
states ON, ALLOFF and FIX.

| set | result |
|---|---|
| **ibex_tracer** (pass 215's conversion, the moved lane) | IDENTICAL in H and A; the slang lane's `_nohier.il`, `.il` and `_synth.v` are **byte-identical to the Surelog lane's** in both sweeps, and byte-identical between H and A ([evidence/downstream/ibex_tracer_lane.txt](evidence/downstream/ibex_tracer_lane.txt)). The corpus row reads `ibex_tracer,default,CMP_EQUAL,,,equal` / `ibex_tracer,testflags,CMP_EQUAL,,,equal` |
| **q08** (r11u173verify rq/q08_high_param_genfor) | ALLOFF DIVERGENT -> ON **IDENTICAL**; RTLIL and netlist byte-identical to the Surelog lane ([converted_lanes_bytes.txt](evidence/downstream/converted_lanes_bytes.txt)) |
| **v11u216's f09, f22** (DIVERGENT -> IDENTICAL) and **f16, f17, f20** (EQUIVALENT -> IDENTICAL) | all five reproduce; every converted lane byte-identical to the Surelog lane |
| the four directories' 203 cases + q08 ([passcases_ON_ALLOFF.txt](evidence/downstream/passcases_ON_ALLOFF.txt)) | IDENTICAL both 181; DIVERGENT -> IDENTICAL 12 (q08, r11u216's g01 g02 g04 g05 g11 g12 g14 g20 n04, v11u216's f09 f22); EQUIVALENT -> IDENTICAL 3 (f16 f17 f20); DIVERGENT both 3 (r11u215 R/r07, r11u216 NQ/n11, v11u216 F/f14); EQUIVALENT both 3 (v11u215 IP/p04, OR/r08, TA/t16); STATUS_DIFF both 1 (v11u215 TC/c02); SLANG_REJECT both 1 (v11u216 F/f02). **0 leave IDENTICAL.** On every non-IDENTICAL case, the slang lane's RTLIL is byte-identical between ON and ALLOFF. **Pass 215's grid: 52 of 53 IDENTICAL, R/r07 DIVERGENT on both with byte-identical RTLIL: confirmed** |
| the 65 fresh cases ([fresh_cases_ALLOFF_ON_FIX.tsv](evidence/downstream/fresh_cases_ALLOFF_ON_FIX.tsv)) | IDENTICAL in all three states 49; **DIVERGENT -> IDENTICAL 4** (Q/q06, q10, q16, q17); DIVERGENT in all three 7 (I/i02, i06, Q/q02, q04, q11, X/x02, NP/p08); EQUIVALENT in all three 4; STATUS_DIFF 1 (A/a03: the Surelog lane READ_FAIL). **0 leave IDENTICAL; FIX = ON on every case.** Where the slang lane's RTLIL moves between states (q04, q05, x02), it moves toward the Surelog lane: nohier diff lines 16 -> 12, 31 -> 2 and 8 -> 4 |
| the corpus lanes | H: 803 / 66 / 2 / 0, `downstream.csv` byte-identical in H, A, 6, 5 and 2 |

**UVM order-blind distance** ([drivers/uvmdist.sh](drivers/uvmdist.sh), dist / sym, both modes equal;
[evidence/residues/uvmdist_H_A.txt](evidence/residues/uvmdist_H_A.txt), [uvmdist_S6_S5.txt](evidence/residues/uvmdist_S6_S5.txt)):

| row | both off (A) | 216 only (5) | 215 only (6) | law (H) | 216's delta | 215's delta |
|---|---|---|---|---|---|---|
| MiniAmiq | 6528 / 14780 | 6339 / 14402 | 6455 / 14634 | **6266 / 14256** | -189 / -378 (claimed 6528 -> 6339, 14780 -> 14402) | -73 / -146 (claimed 14802 -> 14656 at its base) |
| SeqDriver | 5071 / 10928 | 5071 / 10928 | 4969 / 10724 | **4969 / 10724** | 0 | -102 / -204 (claimed 10954 -> 10750) |
| SimpleUVM | 1983 / 3812 | 1983 / 3812 | 1903 / 3652 | **1903 / 3652** | 0 | -80 / -160 (claimed 3834 -> 3674) |
| Scoreboard | 1453 / 2829 | 1453 / 2829 | 1393 / 2709 | **1393 / 2709** | 0 | -60 / -120 (claimed 2847 -> 2727) |
| BuildUVMPkg | 713 / 1371 | 713 / 1371 | 673 / 1291 | **673 / 1291** | 0 | -40 / -80 (claimed 1385 -> 1305) |

Every landing's delta equals its claim, and the two add up exactly (MiniAmiq -262 / -524).

## 9. The residues, re-measured at the base

The rows at the base are in [evidence/residues/heads_H.txt](evidence/residues/heads_H.txt). The residue cases were
re-judged at the base in both views ([residue_cases_base.txt](evidence/residues/residue_cases_base.txt)).

| residue | status at `57ce3ae8` |
|---|---|
| 216 #1: pass 212's residues (q08; instance-range stamps; exposed names) | q08 **closed** (IDENTICAL, both views EQUAL). **n12 and v11u212's e16 regressed to stage 1 by the 217v composition (section 4.1), refined in fix.patch.** The rest were not re-measured case by case |
| 216 #2: the formal writer-order family | MiniAmiq #899 **closed** (the 216 SUBSET above). cfg_func_width_loop d/t `line(3)` **stands**: #464 `logic_typespec mask_t`, golden 27:40 (the function formal), ours 16:11 |
| 216 #3: the remaining UVM enum listings | not in MiniAmiq's 59 strict records at the base (52 macro method-call spans, 5 `UVM_FILE` span-pairing records, 2 `UVM_SEQ_ARB_TYPE`); undecided below the walk |
| v11u216 #1-2: r11u214's law patch, MiniAmiq #10107 | the patch **still unlanded** at this base. #10107 (N0540) was cleared by pass 215's § pkgTdAliasLastWriter215: MiniAmiq's head is now #11306 |
| v11u216 #3: `$size` of a multi-dimensional unpacked array | **stands and confirmed** (fresh Q/q04: golden `UINT:2` for `m [2][3]`, the law declines; the downstream RTLIL still differs by `$size(m)`) |
| v11u216 #4: the range-bound encoding face | **stands and confirmed** (fresh Q/q05: golden keeps `4'hA` `HEX:A` and `2'd1` `DEC:1` on the typespec bound, sized to the net; ours `UINT:10` / `UINT:1`: the stage-1 head of both views, on all states) |
| v11u216 #5-6: the module-scope class name face; t10, t14 | stand (fresh W/w01, w02: `work@top::M::p::e_t` and the import-clone name `work::g::y::p::e_t`; t10, t14 stage 1) |
| 215 #1: the enum-alias twin when a class writes last | **stands**: r11u215 A/a06, a12 `fullname` both views; fresh A/a05 (golden `work@uc::p::alias_t`, ours `work@m.p::` under both) |
| 215 #2: SimpleUVM #458 / Scoreboard #466 `UVM_MACRO_NUMFLAGS` | **stands**: the heads of both rows (`ref_typespec UVM_MACRO_NUMFLAGS`, ours `uvm_pkg::UVM_MACRO_NUMFLAGS`) |
| 215 #3: the macro method-call spans | **stands**: MiniAmiq #11306, SeqDriver #11289 `phase_state_change` endline 168:29 in golden, 169:9 ours |
| v11u215 #1: the SeqDriver coin | **reproduced and cured** (§ cloneTwinMintIdOrder221v, section 7) |
| v11u215 #3: nested classes as the last writer | **stands, wrong on both binaries, not a break** (fresh A/a02: golden `work@outer::m:inner::p::alias_t`, the nested `$unit` class; law and pristine `work@m.p::`; v11u215 TA/t03, t19 `fullname` both views) |
| v11u215 #4: the shared import-clone swap | stands (TC/c06 stage 1 both views) |
| v11u215 #5: § opIdxRecvPlainElab215's declines | stand, with two more shapes: fresh R/r03_el (two-level receivers, golden `...m::a::i` / `...m::b::j` through each element; law `...m::i`) and R/r04_el (an interface-scope class, golden `...get::fs::j`). Both wrong to wrong |

**New residues decoded here (none is a break):**
* **§ impPatMemberReadKeepsParent215v's predicate is broader than golden's** (I/i06, IR/mr1-mr6). Golden's first
  instance copy of a pattern parameter stays unparented when the importing module itself reads a member of it, in
  `always_ff`, a module function, a continuous assignment, `initial` and even a localparam. The refinement keeps
  every copy parented there, as pristine did. The pass-215 grid shapes where golden parents every copy (i13-i16)
  read the parameter in a package, or in a module importing only the home package. The distinguisher is
  undecoded: dropping the refinement would unparent mr3's second copy, which golden parents. Wrong to wrong, the
  next ground-A item.
* **Range queries golden folds and the laws decline:**
  * a typedef-typed or packed-struct operand in a generate scope (Q/q01, q02);
  * `$high`, `$low`, `$right` of a local unpacked variable (Q/q11). Golden writes Surelog's bit count (`UINT:32`
    for `logic [3:0] u [0:7]`), a value the LRM does not give.
* **`$increment` in a generate scope** (Q/q03, a control): golden keeps the call and stamps it with
  `ref_typespec (work@dut.c1)`. Ours lacks the stamp: stage 1 in both states, the head of Q/q03_el.
* **§ ndaRangeQueryFold216 mints a second bound object** where golden shares one between a generate-scope query and
  a net initializer on the same net (Q/q05). It also leaves 3 orphan `cont_assign` copies in the unreachable tail.
  The fields are golden's and no reader sees either.

**Rows:**
* Earlgrey_0_1 d/t `endcol(45)` (#93964 `8'h04` endcol) stands.
* BlackBePipeInt d `type(1)` #15272 / t `depth(1)` stands.
* Rggen d `file(3)` #23164 (the Surelog TypespecCache defect) stands.
* BuildUVMPkg d/t `line(31)`: head #26855 `this_type` class_typespec.

## 10. Fence and process

### 10.1 This pass

* Every driver that runs a binary or reads a database sources [drivers/env.sh](drivers/env.sh) (`oppos.py` reads
  dump texts only). env.sh reads the four names from the `FENCED=` line of
  tools/probe/r11u107repro/canaudit.sh in this checkout and refuses without four: rc 1 beside a two-name copy
  ([evidence/fence/fencecheck.txt](evidence/fence/fencecheck.txt)).
* Every driver that reads corpus sources or databases drops fenced paths by word boundary before opening them:
  `bvmirror.sh` (`fenced_skipped=8` on every mirror), `probelanes.sh`, `awayrows.py`, `rawaway.py`, `unmask2.py`,
  `compose.py`, `bytecancel.py`, `det.sh`, `draw.sh`, `drawrow.sh`, `heads.sh`, `cmprows.sh`, `uvmdist.sh`,
  `dscase.py`, `lanebytes2.sh` and `firecensus.sh`.
* The firing censuses and sweep logs were filtered by the same expression, and 0 fenced lines existed.
* The gate sweeps dispatched every row by design. Their csv verdicts are the only fenced facts used, and all are
  unchanged.
* No binary, gdb or script ran on a fenced test's sources or databases outside the gate sweeps' own dispatch. No
  fenced head was read, and no gdb was used.
* A word scan of this directory finds no fenced name; the positive control finds the planted file.

### 10.2 The four directories ([fenceaudit.txt](evidence/fence/fenceaudit.txt) static, [fencecheck.txt](evidence/fence/fencecheck.txt) runtime, [casefirst.txt](evidence/fence/casefirst.txt))

* **env.sh.** r11u216repro's and v11u216repro's read 4 names from the checkout (rc 0) and refuse a two-name copy
  (rc 1, 2 names). r11u215repro's and v11u215repro's resolve the main repository through git's common dir: rc 0 and
  4 names in the checkout, rc 1 and 0 names in a scratch copy, which has no git dir.
* **The drivers without their own fence check touch no corpus source or database but through a fenced caller.**
  * r11u216repro `dumpdiff.sh` reads a case workdir.
  * r11u215repro `awaychain.py`, `awaydump.py`, `fnlines.py` and v11u215repro `awaychain.py` read database triples
    their fenced callers hand in.
  * `censum.py` and `predict.py` (both) read trace files.
  * `ctlsum.py`, `obdist.sh` and `opts.py` read outputs.
  * `grid.sh`, `switches.sh`, `switchcheck.sh`, `judge.sh`, `ctlbytes.sh` and `rungrid.sh` run the directories' own
    cases through their fenced `case.sh`.
  * The `dscase.py` of both 215 directories read the fence themselves.
  * v11u215repro `sweep.sh` / `sweeph.sh` run the gate, which dispatches every row by design.
* **No fenced name** in any file of the four directories.
* **Predictions.** Each was frozen before its sweep, with an md5 in its stamp as claimed.

  | pass | file | md5 | frozen at |
  |---|---|---|---|
  | 216 | `evidence/census/predicted.txt` | `556a7184` as claimed | `frozen_at.txt` 2026-09-28 18:05:51 local; the md5 is in the README only, not in the stamp |
  | 215 | `predicted_movers.txt` | `99fb9419` | stamp `predicted_frozen_at.txt` 2026-09-28T23:38:13Z, with the md5 and binary (`law26.bin` `6a021c3c`) |
  | v11u215 law | the same file | `99fb9419` | 2026-09-29T00:48:59Z |
  | v11u215 fix | fix prediction | `15b44a40` | 02:00:32Z |
  | v11u216 | none separate | - | its README says so: the prediction came from r11u216's census |

  **The union of the 216 and 215 predictions equals this pass's census of the base line for line, 27 rows, with
  every per-law firing count equal.**
* **Packaged cases.** Every case of the four directories names a law on its first line: 62, 38, 53 and 50 cases,
  the READMEs' counts. **Finding:** r11u215repro C/c01, c02 and v11u215repro CW/w01 name
  § caseItemWildConcatOnly215, which is **not in the source**. It was dropped at integration for
  § caseItemWildConcatOnly217v, so the law index credits those three cases to a law with no site. Their first
  lines should name § caseItemWildConcatOnly217v, and their README switch `R11U215_CASEWILDCAT_OFF` is read
  nowhere.
* **Scratch paths and re-running.** Every frozen binary directory the four directories name is gone:
  `/tmp/r11u216_bin`, `/tmp/v11u216_bin`, `/tmp/r11u215_bin` and `/tmp/v11u215_bin`. So none of them re-runs as
  packaged, and each fails at its first binary. The hard-coded `/tmp` paths
  ([evidence/fence/hardcoded_paths.txt](evidence/fence/hardcoded_paths.txt)) count as follows.

  | directory | outside comments | with comments | what they name | to re-run, supply |
  |---|---|---|---|---|
  | r11u216repro | 5 | 5 | `env.sh` `B=${B:-/tmp/r11u216_bin}` (`pristine.bin`, `law.bin`, `strictcmp`), `case.sh` `/tmp/r11u216_g`, `awayrows.py` `/tmp/r11u216_awaycache`, `uvmdist.sh`, `widebytes.sh` scratch | rebuilt `745f66ab` and `745f66ab`+r11u216 binaries in `$B` (overridable) |
  | v11u216repro | 4 | 4 | `env.sh` `B=${B:-/tmp/v11u216_bin}`, `case.sh` `/tmp/v11u216_g`, `dsrun.sh` `/tmp/v11u216_dsg`, `widebytes.sh` | the same, plus `fix2.bin` |
  | r11u215repro | 19 | 19 | `env.sh` `B=/tmp/r11u215_bin` (not overridable), `case.sh` `/tmp/r11u215_gold/`, `/tmp/r11u215_run/`, the strictcmp at `/tmp/r11u215_bin/uhdm-strictcmp` in `away.py`, `awaychain.py`, `heads.sh`, `uvmdist.sh`, and 14 scratch roots | `pris.bin` (`a727b8c7`) and `law26.bin` in `/tmp/r11u215_bin`, fixed path |
  | v11u215repro | 13 | 16 | `env.sh` `B=${B:-/tmp/v11u215_bin}` with `SCMP` there, `case.sh` `/tmp/v11u215_gold/`, `census.sh`, `sweep.sh`, `sweeph.sh` and `uvmdist.sh` reading `/tmp/v11u215_bin/uhdm-strictcmp`, 7 scratch roots | `pris.bin`, `law.bin` and `fix.bin` in `$B`, and the strictcmp at the fixed path |

  r11u215repro `awaydump.py` and `fnlines.py` name only the pinned tool path. No driver of the four writes relative
  to its current directory: the static scan's hits are docstring words, `dsfaces.py`'s usage line, `censum.py`'s
  "for", `predict.py`'s "one", `switchcheck.sh`'s "continue" and `ord.cpp`'s "v".
* **Process.** Builds used `-j 2` with free memory checked first. Binaries were frozen before measurement. There was
  no stash and `GOLDEN_DEFER` was unset. Nothing under `results/`, `tests/` or `third_party/` was written. Scratch is
  `/tmp/r11u221_*` only, with worktrees `/tmp/wt_r11u221`, `/tmp/wt_r11u221fix` and `/tmp/wt_r11u221fx2`. The live
  pairs' worktrees (`/tmp/wt_r11u219*`) were not touched. Every process stopped was this pass's own. r11u219 and
  r11u220 had not landed when this pass finished (main HEAD `57ce3ae8`).

## 11. Files

* [fix.patch](fix.patch): `src/R221.h`, UhdmExporter.cpp § cloneTwinMintIdOrder221v, and ModuleEmit.cpp
  § ndaPortQueryKeepsStamp221v. It is not applied, and it applies clean on a fresh `57ce3ae8`.
* [cases/](cases/), 65 cases, each naming its laws on its first line. NP names § ndaPortQueryKeepsStamp221v, which
  exists only in fix.patch, so `casefirst.py` reads it as not in src at the base:
  * A: 9 (§ pkgTdAliasLastWriter215; a04 and a08 name the clone law and its refinement);
  * D: 4; I: 6; IR: 6 (the member-read contexts); NP: 8 (the break, § ndaPortQueryKeepsStamp221v);
  * Q: 18 (q09 with its header `q09.svh`, q15 CRLF); R: 4;
  * W: 7 (w06 two files via `args`, the second CRLF); X: 3 (the cross-ground pairs).
* [drivers/](drivers/):
  * Copied from r11u217verify and adapted: `env.sh`, `case.sh`, `grid.py`, `gridall.sh`, `laws.py`, `mkstate.sh`,
    `sweep.sh`, `awayrows.py`, `unmask2.py`, `bvmirror.sh`, `det.sh`, `detob.sh`, `uvmdist.sh`, `heads.sh`,
    `dscase.py`, `censum.py`, `firecensus.sh`, `compose.py`, `bytecancel.py`, `dumpaway2.py`, `fenceaudit.py`,
    `fencecheck.sh` and `casefirst.py`.
  * New: `rawaway.py` (the flat raw-dump census), `oppos.py` (the position judge), `ddr.sh` (reachable dump diffs),
    `probelanes.sh`, `lanebytes2.sh`, `cmprows.sh`, `draw.sh`, `drawrow.sh`.
  * From v11u215repro: `ord.cpp` and `sym.cpp`. Build with
    `g++ -std=c++17 -I$HOME/.local/include X.cpp -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread`.
  * The r11u217 drivers not used here are kept for reuse.
* [evidence/](evidence/):
  * `sweeps/`: logs, the cmds audit, binaries;
  * `census/`: the frozen prediction and its stamp;
  * `movers/`, `compose/`, `unmask/`, `away/`;
  * `grid/`: raw per case for law and fix2, summaries, the position judges;
  * `breaks/`: the 80-shape query grid behind the break;
  * `fix/`: fix predictions, byte movers, the firing census, rebuild identity;
  * `determinism/`, `downstream/`, `residues/`, `fence/`, `gates/`.
