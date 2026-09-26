# r11u182: second adversarial verification of passes 171 and 174 (verifier, measurement plus one refinement in fix.patch)

Base `7fadac8a` (branch matrix-1.87). Pass 171 (the module/type ground: r11u172's three TypeEmit laws, seven laws of
its own, v11u171's two refinements) landed at `72fd3061`; pass 174 (the expression/parameter ground: r11u172's DEPTH
law, three laws of its own, r11v174's refinement) at `38d03148`; r11u177's three location-model refinements at
`5e8d08d9`; the ninth map (tools only) at `7fadac8a`. The commit before pass 171 is `50a01bc3`. Worktrees:
`/tmp/wt_r11u182` (the base, the deliverable), `/tmp/wt_r11u182pre` (`50a01bc3`), `/tmp/wt_r11u182fix` (the base +
[fix.patch](fix.patch)). System-deps configuration, `-j 2`.

This directory is the whole deliverable. Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is
edited. The refinement is [fix.patch](fix.patch), a `git diff 7fadac8a -- src` (`src/UhdmExporter.cpp` only) that
applies clean on a fresh `7fadac8a`; it is NOT applied here. No canonicalisation patch for `tools/uhdm-strictcmp`
was handed to this pass and no comparator defect was found, so the comparator is not edited.

The slang-fenced tests are named nowhere here. [drivers/env.sh](drivers/env.sh) reads `$FENCED` from the `FENCED=`
line of `tools/probe/r11u107repro/canaudit.sh` (not from RESUME.md) and refuses to run without four names; every
driver of this directory that reads corpus sources or databases refuses to run without it and skips those names by
word boundary (section 9).

The cases name their laws in their first line (`// § law`), so `tests/LAWS.md` reads STALE in every sweep run after
they were written (the landing regenerates it with `python3 scripts/law_index.py`); that is the only red of every
sweep below. The HEAD sweep `swH` ran before the cases existed and exits 0.

## Verdict

**One break, judge-invisible, on the landed corpus rows: § castUnionCloneFile171 composed with
§ contAssignLhsTsUnparented134 (pass 134's typedef parent model).** § castUnionCloneFile171 stamps the typedef's
file on the fresh union clone a cast to a package union typedef binds. § contAssignLhsTsUnparented134 unparents every
named typespec whose key (kind, name, FILE, line:col) equals the key of a cont_assign LHS typedef. Before pass 171 the
clone had no file and never matched; with the file it matches the listing object's key, so the clone is unparented
and its member references' explicit full names are rewritten. Golden keeps every cast clone parented at the cast's
`ref_typespec` (Surelog's writeCont_assign unparents `TypeDef::getTypespec`, the listing object, never a cast copy).
Field by field, against the law's own switch:

| where | golden | pristine (`R11U171_CASTUNIONFILE_OFF`) | law (HEAD) | fix |
|---|---|---|---|---|
| UnionCast d/t (surelog), jeras_union d/t (uhdm2rtlil): the cast clone `riscv_isa_pkg::op32_t` | file set, parent `ref_typespec` | no file, parent `ref_typespec` | file set, **no parent** | file set, parent `ref_typespec` |
| the same rows: member reference full names `work@...riscv_isa_pkg::op32_t.<m>` / `riscv_isa_pkg::op32_t.<m>` | 74 / 7 | 74 / 7 | **67 / 14** | 74 / 7 |
| strict verdict / uhdm-cmp lines | | UnionCast `file`, jeras `fullname(75)`; 0 | UnionCast STRICT_EQUAL, jeras `fullname(75)`; 0 | the same as HEAD; 0 |

Neither judge sees it: uhdm-cmp reads no parent, and uhdm-strictcmp canonicalises typespec copies with the full
names inside them ([evidence/fix/break_rows.txt](evidence/fix/break_rows.txt)); the downstream netlists of
jeras_union and UnionCast are byte-identical to golden's lane in every state, so the plugin does not read it. The
same shape is in pass 171's own grid (`r11u171repro` U/u01-u03), in v11u171's U/k02 and in this directory's D/d01-d03
([evidence/fix/break_cases_objlist.txt](evidence/fix/break_cases_objlist.txt)). The fix is
**§ castUnionCloneKeepsCastParent182v** (`R11V182_UNIONPARENT_OFF`; `R11V182_OFF` drops it), which keeps the cast
clones out of the unparent key in `typedefParentModel134`. With it, every moved case gains golden dump lines and loses
none. Every conversion is kept. The fix gate sweep reads 0/0/0 in all three stages. Its only byte movers are the four
predicted row-modes plus the UVM order coin (section 4).

**No other law of the two landings moves a field away from golden.** The grid has 82 fresh cases × 2 modes (default
and `--elabuhdm`), 17 laws plus 3 cross-ground partners. No cell loses strict equality, and no uhdm-cmp count grows.
No run crashes (every rc 0). The field judge reads 0 FAWAY, and the chain-keyed record judge and the order-blind dump
judge read no away cell outside the union-clone break, apart from three artifacts that were traced (section 3). The
strict-equal count goes from 0 to 24 of 82 (default) and from 0 to 25 of 82 (`--elabuhdm`).

**Composition: additive.** Every conversion the landings claimed is owned as claimed. The probe has 41 (OWN171 13,
OWN174 28), surelog 7 (OWN171), and uhdm2rtlil 12 (OWN174 4, JOINT 8: the rp32 rows, which need both landings, as
claimed). CANCEL is 0 at the status level and 0 over 6647 databases. The rp32 share proof shows each law fixing its
own disjoint records (section 5). With passes 168/169 and the refinements off, the same 129 databases move, and every
field reading is FTOWARD or FSAME.

**Changes: strict improvements or unmaskings.** Every row the landings move reads CONVERSION or SUBSET record by
record. The one exception is jeras_union, an UNMASK: the walk completes, and the order-blind judge loses 0 golden
records. There are 0 FAWAY over 129 moved databases.

**Downstream:** the six converted uhdm2rtlil rows (and jeras_union, ibex_multdiv_fast, struct_param_func_config) are
byte-identical to golden's lane. The four converted surelog rows, run through the harness's `one()`, give the same
netlists with the landings on and off (GenerateUnnamed, UnionCast, YosysBigSimEllip IDENTICAL; YosysOldOr
EQUIVALENT both, pre-existing). The 32 own cases run through `one()` read the same verdict in ON, ALLOFF and OWN.

**Fence: held; process findings, none a breach** (section 9): no driver of the four evidence directories reads
`$FENCED` from canaudit.sh; r11u174repro and r11v174repro read RESUME.md by line number; r11v174's `toward.sh`
reads corpus databases without refusing an empty `$FENCED`. Both predictions reproduce exactly from the pre-sweep
inputs.

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u182_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `law.bin` | `9958104447d83791aab5afe31f796885` | worktree build of `7fadac8a` = the main tree's `build/slang-uhdm` (the brief's `9958104447d8`) |
| `pre.bin` | `5f356bace7feda3ba46382e2b63ac365` | build of `50a01bc3`, the commit before pass 171 (= r11u174's / r11u177's pristine md5) |
| `fix.bin` | `1c321cd5ce346cefdde18703cd2f56f6` | `7fadac8a` + [fix.patch](fix.patch) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

State wrappers ([drivers/mkstate.sh](drivers/mkstate.sh), [evidence/sweeps/state_wrappers.txt](evidence/sweeps/state_wrappers.txt)):
`alloff.sh` = law.bin under `R11U172_OFF R11U171_OFF R11V171_OFF R11U174_OFF` (both landings off); `off171.sh` =
`R11U172_FILE_OFF R11U172_VALUE_OFF R11U172_SPAN_OFF R11U171_OFF R11V171_OFF`; `off174.sh` = `R11U174_OFF` (drops
§ pkgFnCastTopListing172 and § mopPkgBaseReduces174v too); `off1669.sh` = `R11U166_OFF R11U168_OFF R11U169_OFF
R11V173_OFF R11V177_OFF`; `wide.sh` = both; `stf34.sh` = alloff + `R11V177_OFF R11U169_OFF R11V173_OFF` (pass 171's
base state, `f34d9d7c`); `st174law.sh` = off171 + `R11V177_OFF R11V174_MOPPKG_OFF` (pass 174's law binary on
`31739f79`).

**Switch completeness:** ALLOFF + `R11V177_OFF` gives `pre.bin`'s bytes on all 164 case-modes of the grid (`ALLOFF==PRE
YES` 82 + 82).

## 2. Sweeps (`tests/sweep.sh --jobs 3`, [drivers/sweep.sh](drivers/sweep.sh); workdir names `/tmp/r11u182_sw?`, all the same length)

Every sweep's `cmds.txt` names its own binary or wrapper on all 3273 `slang:` lines (audit line at the end of each
[evidence/sweeps/](evidence/sweeps) summary). All goldens came from the cache.

| sweep | binary | probe (regr / conv / chg vs results/) | surelog | uhdm2rtlil | downstream |
|---|---|---|---|---|---|
| swH | law.bin | 0/0/0, EQUAL 2796 / 1291, `probe.csv` byte-identical to results/golden_probe.csv | 0/0/0, 450+30 / 446+28 | 0/0/0, 783+20 both modes | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0; csv byte-identical to results/downstream_uhdm2rtlil.csv |
| swA | alloff.sh | 41/0/28 | 7/0/13 | 12/0/6 | csv byte-identical to swH's |
| sw1 | off171.sh | 13/0/5 (exactly pass 171's probe claim) | 7/0/11 (exactly pass 171's claim) | 8/0/4 (the rp32 rows need 171's FILE + VALUE) | - |
| sw4 | off174.sh | 28/0/23 (exactly pass 174's claim) | 0/0/2 | 12/0/4 | - |
| swX | fix.bin | 0/0/0, csv identical to swH's | 0/0/0 (csv = swH's except the LowMem detail text: the workdir path) | 0/0/0, csv identical | csv byte-identical to swH's |
| swQ | off1669.sh | 96/0/15 | 10/0/21 | 8/0/4 | - |
| swW | wide.sh | 120/0/42 | 15/0/23 | 16/0/8 | - |
| swF | stf34.sh | 99/0/37, EQUAL 2697 / 1390 (= pass 171's own pristine sweep) | 7/0/15 | 14/0/8 | - |

Canaries on swH and swX ([evidence/fix/canaries_H_X.txt](evidence/fix/canaries_H_X.txt)): `canaries.sh` surelog ok=52
changed=0, uhdm2rtlil ok=16 changed=0; `ctcan2.sh` `EXPECT_UNKNOWN=1` surelog ok=58 PASS, `EXPECT_UNKNOWN=6`
uhdm2rtlil ok=2 PASS.

## 3. The fresh cases and the per-law reading

82 cases in [cases/](cases), 15 groups; none is in a grid of r11u171repro, v11u171repro, r11u172rp, r11u174repro or
r11v174repro. The first line of each case names its laws. [drivers/case.sh](drivers/case.sh) builds the golden with the
pinned Surelog. It uses check_probe's arguments, or `-elabuhdm` with `EL=1`, a `dut.v` case runs in Verilog mode, and
an `args` file lists several root files. Every run's rc is recorded. [drivers/grid.py](drivers/grid.py) runs each
case in both modes under: ON; each named law's own switch (a refinement also under its parent's); each landing off;
every pair of named laws (group X); ALLOFF; PREOFF; and pre.bin. Readings:

- grid.py: UNFIRED, TOWARD, AWAY, MIXED, UNMASK, and the order-blind dump distance for stage-1 cells.
- [drivers/fieldscore.py](drivers/fieldscore.py): the per-walk-index field sets (FTOWARD / FNEUTRAL / FAWAY) on
  aligned cells.
- [drivers/recaway2.py](drivers/recaway2.py) (new): strict records of each database walked against itself, keyed by
  their ancestor chain. It works on stage-1 cells too and includes the file field. `away` counts records the state
  shared with golden that ON lost.
- [drivers/dumpaway.py](drivers/dumpaway.py) (new): uhdm-dump line multisets on every cell. It sees fields neither
  comparator reads (vpiParent, the computed full names, the unreachable tail). This is the instrument that found the
  break.

| group | cases | law(s) attacked (the brief's shapes) |
|---|---|---|
| A | 8 | § tdMoveCarriesFile172: formals across three files (a01), unpacked-dimension ends across three files (a02), three files with the same declarator position, file order reversed against module names (a03), a package-qualified formal next to a plain one (a04), a typedef from an include of an include (a05), a module-function formal in another file (a06), an enum formal and net (a07), a task formal of a nested struct (a08) |
| B | 7 | § boundLitWrittenDigits172: `007`/`000`/`00` module and port bounds (b01), generate bounds (b02), package parameter / typedef / struct / function bounds (b03), `'d7`, `8'd7`, unpacked `[00:01]`, `[1_0:03]` (b04), class member and generate typedef (b05), elaborated port ranges (b06), `1_000`, `0_07`, `1_5` (b07) |
| C | 4 | § sysSignNameSpanSyntax172: nested `$signed($unsigned(x))` (c01), in a range bound and a generate range (c02), in a case item and a generate case (c03), in a parameter and a gen-if condition (c04) |
| D | 3 | § castUnionCloneFile171: a union inside a struct inside a package in another root file (d01), a typedef chain to the union (d02), the union in a header, casts in two modules and a package function (d03) |
| E | 4 | § tsMemberRootFile171: a union of a struct through a typedef chain in an include of a root file (e01), members from an include of an include (e02), members from a macro defined in another root file (e03), a class struct whose body is a header (e04) |
| F | 4 | § splitPortTsKeyOnPortDecl171: Verilog-95 ports re-declared as `integer` (f01), `wire` with ranges (f02), signed `reg` used in a generate (f03), mixed port declarations (f04) |
| G | 4 | § selLhsBareDecRhsShared171: bit and part selects of unpacked arrays (g01), sized and negative decimals (g02), in generates (g03), `1_0` and a signed net (g04) |
| H | 8 | § udpFormConcatSwallowSpans171 / § udpSwallowLvalueOnly171v: member access first (h01), a single element (h02), part selects with an operation tail (h03), a replication (h04), nested bit selects (h05), a literal (h06), in a generate loop (h07), an operation element (h08) |
| I | 4 | § defNetEndOutputCol171: a pasted packed dimension (i01), multi-line macros in both dimensions (i02), a stringified formal on the same line (i03), macro unpacked and 2-D packed (i04) |
| J | 10 | § genElseIfGateTermPath171 / § genElseIfFlatOnly171v: a gate array (j01), `else begin if end` (j02), a no-begin else-if with a begin-end body (j03), a three-level chain (j04), named blocks in the chain (j05), a UDP instance (j06), three parameterised instances (j07), a flat chain in a named block (j08), a flat else-if with a nested if (j09), a flat chain with gate arrays (j10) |
| K | 4 | § pkgFnCastTopListing172: reached from another package (k01), from a class (k02), from a module parameter (k03), a typedef chain and an enum cast (k04) |
| L | 4 | § elabParamLeftoverRefUnnamed174: a generate loop per iteration (l01), a parent function-built override (l02), two wildcard importers (l03), an instance array with a sibling read (l04) |
| M | 5 | § asmRefQualWholeSpanElab174: member reads of the qualified parameter (m01), a comment inside the reference (m02), an interface parameter (m03), two modules × two instances (m04), a reference through an `export p::*` package (m05) |
| N | 8 | § elabStructMemberOpFoldUnlocated174 / § mopPkgBaseReduces174v: package function- and pattern-built bases (n01, n07 imported, n08 cast and unary), a `$unit` base (n02), a class static base (n03), a generate-localparam base (n04), casts over members of function- and pattern-built parameters (n05), an interface base (n06) |
| X | 5 | cross-ground pairs (section 5): x01 § tdMoveCarriesFile172 × § memLeftFormalArgLoc169 × § mlArgLocFileAtActual177v (a macro-born actual of a constant function whose formal type lives in another file); x02 § tsMemberRootFile171 × § elabParamLeftoverRefUnnamed174; x03 § udpFormConcatSwallowSpans171 × § genCaFoldTsChainNamed169; x04 § boundLitWrittenDigits172 × § pkgFnCastTopListing172; x05 § selLhsBareDecRhsShared171 × § elabStructMemberOpFoldUnlocated174 |

Per law, both modes, against the law's own switch ([evidence/grid/lawtable.txt](evidence/grid/lawtable.txt); every
cell in [evidence/grid/summary_default.txt](evidence/grid/summary_default.txt),
[summary_elabuhdm.txt](evidence/grid/summary_elabuhdm.txt), [grid_default.txt](evidence/grid/grid_default.txt),
[grid_elabuhdm.txt](evidence/grid/grid_elabuhdm.txt), [fieldscore.txt](evidence/grid/fieldscore.txt),
[recaway2_chainkeyed.txt](evidence/grid/recaway2_chainkeyed.txt), [dumpaway_orderblind.txt](evidence/grid/dumpaway_orderblind.txt)):

| law | cells | unfired | strict: gained / both not-equal / lost | uhdm-cmp up | away (records / dump) | downstream (ON vs OWN) | verdict |
|---|---|---|---|---|---|---|---|
| § tdMoveCarriesFile172 | 18 | 4 | 6 / 8 / 0 | 0 | 0 / 0 | - | holds; a02 MIXED = wrong→wrong file (the known end-only tie-break, R1) |
| § boundLitWrittenDigits172 | 16 | 0 | 4 / 12 / 0 | 0 | 0 / 0 | - | holds |
| § sysSignNameSpanSyntax172 | 8 | 0 | 1 / 7 / 0 | 0 | 0 / 0 | - | holds (every stage-1 cell closer) |
| § castUnionCloneFile171 | 6 | 0 | 0 / 6 / 0 | 0 | 0 / **6** | same | **BREAK** (the parent / full-name composition above; fixed) |
| § tsMemberRootFile171 | 10 | 0 | 10 / 0 / 0 | 0 | 0 / 0 | - | holds |
| § splitPortTsKeyOnPortDecl171 | 8 | 0 | 4 / 4 / 0 | 0 | 0 / 0 | same | holds (f01's stage-1 cell: the span moves to golden's, the pre-existing `integer`/`logic` kind stays) |
| § selLhsBareDecRhsShared171 | 10 | 0 | 2 / 8 / 0 | 0 | 0 / 6* | same | holds (*dump first-visit artifact of sharing; object census: golden shares exactly as the law does) |
| § udpFormConcatSwallowSpans171 | 18 | 6 | 2 / 10 / 0 | 0 | 1* / 0 | same | holds (*h03, a walk first-visit artifact: every binding identical in the dumps) |
| § udpSwallowLvalueOnly171v | 6 | 0 | 0 / 6 / 0 | 0 | 4* / 4* | same | holds (*a coincidental same-depth span match inside the pre-existing wrong swallow, R4; the refinement returns pristine's exact bytes) |
| § defNetEndOutputCol171 | 8 | 2 | 6 / 0 / 0 | 0 | 0 / 0 | - | holds (i01, the paste guard: unfired as designed) |
| § genElseIfGateTermPath171 | 18 | 6 | 8 / 4 / 0 | 0 | 0 / 0 | same | holds (j01, j02, j09 unfired: the known gaps R5) |
| § genElseIfFlatOnly171v | 6 | 4 | 0 / 2 / 0 | 0 | 0 / 0 | - | holds (j10: the decline fires and moves closer) |
| § pkgFnCastTopListing172 | 10 | 0 | 4 / 6 / 0 | 0 | 0 / 0 | - | holds |
| § elabParamLeftoverRefUnnamed174 | 10 | 0 | 4 / 6 / 0 | 0 | 0 / 0 | - | holds |
| § asmRefQualWholeSpanElab174 | 10 | 0 | 0 / 10 / 0 | 0 | 0 / 0 | - | holds (every param_assign line it moves goes to golden's, [pacmp](drivers/pacmp.sh)) |
| § elabStructMemberOpFoldUnlocated174 | 18 | 8 | 2 / 8 / 0 | 0 | 0 / 0 | same | holds (n02/n03/n06 wrong→wrong: golden keeps an unfolded operation there) |
| § mopPkgBaseReduces174v | 6 | 0 | 0 / 6 / 0 | 0 | 0 / 0 | same | holds on every package base (n01, n07, n08 closer) |

The three artifacts that were traced:

- h03 (`f3 u ({w[3:2], w[1:0]}, x & y, z)`): uhdm-dump shows the actuals of port B identical in golden, pristine and law
  (both bound). The chain-keyed away record is the net listed at its first walk visit, which moved into port A.
- The G cells: [drivers/carhs.cpp](drivers/carhs.cpp) prints every cont_assign's Rhs object. Golden, like the law,
  gives one definition constant to the definition cell and every elaborated cell for a bare decimal onto a select, and
  fresh per-cell constants in generate scopes. The dump prints a shared object once, so line multisets drop.
- h04/h08 (refinement): golden never swallows a non-lvalue first concatenation, and every state does. The refinement
  gives pristine's bytes (landing off = UNFIRED). The "away" record is the law-state inner concatenation that took
  its first element's span at golden's replication depth.

Stage-1 cells of the member-fold law, read at the param_assign level ([drivers/pacmp.sh](drivers/pacmp.sh)):

- n02 (`$unit` base), n03 (class static base) and n06 (interface): golden keeps the operation unfolded, and every
  state folds it. The law moves the fold's location from located to unlocated, wrong to wrong.
- n04 (a generate-localparam base): golden unlocates X, and the law does not fire there (residue).
- n05: X toward golden.

## 4. The break and § castUnionCloneKeepsCastParent182v ([fix.patch](fix.patch))

**Decode.** Surelog's `UhdmWriter::writeCont_assign` ends each assignment with `tps->VpiParent(nullptr)` on the LHS
typespec. That typespec is `TypeDef::getTypespec`, the listing object (the r11u134 model; our
§ contAssignLhsTsUnparented134). The union copy a cast re-elaborates is built by `compileTypespec` for the cast and is
parented at the cast's `ref_typespec` (golden UnionCast id1360, jeras_union id3267: parent `ref_typespec`). Ours keys
the unparent on (kind, name, file, line:col) because our definition and elaborated listings are separate objects. The
cast clone copies the listing's span, and once § castUnionCloneFile171 gives it the listing's file too, its key equals
the listing's.

**Rule.** The clones in `castUnionClone` are excluded from the unparent key (UhdmExporter.cpp, at the call of
`typedefParentModel134`). Pristine never had them in the key (empty file), so the refinement restores pristine's parent
and names for them while keeping § castUnionCloneFile171's file.

**Measurements** ([evidence/fix/](evidence/fix)):

- Cases: D/d01-d03 in both modes. fix vs law gains 12-77 golden dump lines and loses 0. fix vs pristine gives the same
  dump and moves the strict file record toward golden. The union clone objects equal golden's shape (file set, parent
  `ref_typespec`). `R11V182_UNIONPARENT_OFF=1` gives law.bin's bytes.
- Corpus rows ([break_rows.txt](evidence/fix/break_rows.txt)): UnionCast d/t stays STRICT_EQUAL; jeras_union d/t
  stays `fullname(75)`; uhdm-cmp reads 0 lines on all four; full names 74/7 = golden's.
- Prediction, written from the HEAD databases before the fix sweep ([prediction_fix.txt](evidence/fix/prediction_fix.txt),
  [drivers/predfix.cpp](drivers/predfix.cpp): a union typespec a cast binds with no parent). It names 6647 databases,
  fenced excluded 8, and predicts exactly UnionCast d/t and jeras_union d/t, 0 probe cases. The positive control is
  the D cases ([prediction_fix_positive_control.txt](evidence/fix/prediction_fix_positive_control.txt)).
- Gate sweep swX: 0/0/0 in all three stages. The downstream csv is byte-identical to swH's. Canaries are as for swH.
- byteverify swX vs swH on fence-clean mirrors (`mirrored=2560 fenced_skipped=8`, PATH_SETS_IDENTICAL, SELFCHECK
  2559/2560): 8 movers. Four are the predicted rows. The other four are MiniAmiq d/t, SeqDriver t and Scoreboard d,
  the UVM order coin: the order-blind dump difference is 4, 4, 4 and 0 lines
  ([uvm_coin_X_vs_H.txt](evidence/fix/uvm_coin_X_vs_H.txt)). Probe byte movers: 0 of 4087.
- Byte controls ([drivers/fixbytes.sh](drivers/fixbytes.sh)): fix vs law over 1213 cases of the landed-law grids
  (this directory, r11u171repro, v11u171repro, r11u172rp, r11u174repro, r11v174repro, r11u177verify, r11u173verify,
  r11u169repro, r11v169repro, r11u168repro, v11u168repro, r11u166mac, r11u118repro, r11v11u118repro, r11u119repro)
  move 7 cases, all union-cast cases: r11u171 U/u01, u02, u03, v11u171 U/k02, and D/d01-d03. Every one gains golden
  dump lines and loses none. Every strict verdict is kept: u01, u03, k02 stay STRICT_EQUAL, and u02 stays stage 1
  with the same text. `R11V182_OFF=1` gives law.bin's bytes on 366 of 366 cases, and `R11V182_UNIONPARENT_OFF=1` on
  87 of 87.
- Downstream: jeras_union's three netlists are byte-identical to golden's lane in swX.

## 5. Composition ([evidence/composition/](evidence/composition))

**Status level** ([compose_H_A_1_4.txt](evidence/composition/compose_H_A_1_4.txt); H = swH, A = swA, off171 = sw1,
off174 = sw4; 1588 surelog rows = 1596 - the 8 fenced, skipped unread):

| stage | conversions A→H | owner | changes | cancel |
|---|---|---|---|---|
| probe | 41 | OWN171 13 (pass 171's 13 names), OWN174 28 (pass 174's 28) | OWN171 5, OWN174 23 | 0 |
| surelog | 7 | OWN171 7 (GenerateUnnamed d/t, UnionCast d/t, YosysBigSimEllip d, YosysOldOr d/t) | OWN171 11, OWN174 2 (FuncStructValSimple d/t) | 0 |
| uhdm2rtlil | 12 | OWN174 4 (struct_param_field_shift d/t, param_nested_struct_field_width d/t), JOINT 8 (rp32_r5p_{alu,bru,mdu,wbu} d/t) | JOINT 2 (jeras_union d/t), OWN171 2 (ibex_multdiv_fast d/t), OWN174 2 (struct_param_func_config d/t) | 0 |

**Byte level** ([bytecancel_H_A_1_4.txt](evidence/composition/bytecancel_H_A_1_4.txt)), over 6647 databases:

- SAME 6518, OWN171 45 (probe 18, corpus 27), OWN174 69 (probe 59, corpus 10), CANCEL 0.
- BOTH 15: the rp32 rows and jeras_union, which both passes move, and MiniAmiq d/t, SeqDriver d/t and Scoreboard d,
  the UVM coin. The order-blind dump difference against sw4 is 4, 4, 4, 4 and 0 lines
  ([uvm_both_orderblind.txt](evidence/composition/uvm_both_orderblind.txt)).
- byteverify H vs A on mirrors: 52 of 2560 corpus movers (= 27 + 10 + 15), SELFCHECK 2559/2560.

**The rp32 shares** ([rp32_shares.txt](evidence/composition/rp32_shares.txt), each row re-exported under one or two
switches; every state rc 0). All laws on gives STRICT_EQUAL on all four rows. Each single switch leaves only its own
face:

- `R11U172_VALUE_OFF` → value=152 (alu, wbu) or 140 (bru, mdu).
- `R11U172_FILE_OFF` → file=17 or 13.
- `R11U172_SPAN_OFF` → endcol=1 (alu only; bru, mdu and wbu are byte-identical to ON).
- `R11U172_DEPTH_OFF` → type=1 (walk diverged); this is byte-identical to `R11U174_OFF`.

FILE+VALUE off = 169 / 153 records, exactly the sum. Pass 171 off = FILE+VALUE off (+SPAN's 1 on alu), byte-identical
on bru, mdu and wbu. No law hides another's error: the conversion needs each law's disjoint records.

**Cross-ground pairs** (group X; each pair off together, [recaway2_chainkeyed.txt](evidence/grid/recaway2_chainkeyed.txt)):
every pair and every single cell reads away 0. The pair's toward count is the sum of the singles:

| case | first law alone | second law alone | the pair together |
|---|---|---|---|
| x01 | § tdMoveCarriesFile172: 5 | § memLeftFormalArgLoc169 (with § mlArgLocFileAtActual177v): 18 | 23 |
| x02 | § tsMemberRootFile171: 45 | § elabParamLeftoverRefUnnamed174: 16 | 61 |
| x03 | § udpFormConcatSwallowSpans171: 15 | § genCaFoldTsChainNamed169: 0 (unfired) | 15 |
| x04 | § boundLitWrittenDigits172: 93 | § pkgFnCastTopListing172: 3 | 96 |
| x05 | § selLhsBareDecRhsShared171: identity only (golden's sharing, carhs) | MOPUNLOC: 2 | 2 |

x02 and x05 are STRICT_EQUAL with everything on.

**With passes 168/169 and the refinements off** ([additive_H_A_Q_W.txt](evidence/composition/additive_H_A_Q_W.txt),
[fieldrows_W_to_Q.txt](evidence/composition/fieldrows_W_to_Q.txt)). The 171/174 delta is read on HEAD's base (A→H)
and on the base without 168/169/173v/177v (W→Q). The same 129 databases move on both bases.

- Where the (from, to) pairs differ, the head on the off base is an earlier 168/169 face, and the laws remove the same
  record count: Earlgrey 75, the UVM rows 17, Scr1SvTests 142, YosysOldOr 1, struct_param_field_shift 5.
- Nine rows convert only on HEAD's base: probe r11u20 t5, r11u21 t1, r11v21 v1, r11vu13 v4 and v9;
  param_nested_struct_field_width d/t; struct_param_func_config d/t. Their bytes move on both bases. They need pass
  169's leftovers, which § elabParamLeftoverRefUnnamed174 renames, so this is a dependency, not a cancellation.
- Field level on the off base: probe 64 FTOWARD + 13 FSAME, surelog 19 + 11, uhdm2rtlil 14 + 8, **0 FAWAY**.

## 6. The CHANGE lines ([evidence/changes/](evidence/changes))

Record by record ([drivers/unmask.py](drivers/unmask.py), [drivers/fieldrows.py](drivers/fieldrows.py)):

| delta | probe | surelog | uhdm2rtlil | field level |
|---|---|---|---|---|
| A→H (both landings) | CONVERSION 41, SUBSET 28 | CONVERSION 7, SUBSET 13 | CONVERSION 12, SUBSET 4, UNMASK 2 (jeras_union d/t) | 0 FAWAY (probe 69 FTOWARD + 8 FSAME, surelog 19 + 11, uhdm2rtlil 18 + 4) |
| off171→H | CONVERSION 13, SUBSET 5 | CONVERSION 7, SUBSET 11 | CONVERSION 8, SUBSET 4 | 0 FAWAY |
| off174→H | CONVERSION 28, SUBSET 23 | SUBSET 2 | CONVERSION 12, SUBSET 2, UNMASK 2 | 0 FAWAY |

The lines the brief lists, each an unmasking or a strict improvement:

- **Scr1SvTests d/t** `file(143) → type(1)`: the same divergence record #16033 on both sides (`offdiv=ondiv=16033`);
  142 facets before it are lost and none is added.
- **rp32** `file(46) → type(1)` (at pass 171's base): section 5. The 45 FILE/VALUE records before the DEPTH divergence
  #15963 are removed, and DEPTH alone leaves `type=1 (walk diverged)`.
- **Earlgrey_0_1** `511 → 436`: FTOWARD, lost 75, the same divergence.
- **MiniAmiq/SeqDriver** `file 46 → 29` and **SimpleUVM/Scoreboard** `fullname 62 → 45`: FTOWARD, lost 17 each.
  [evidence/uvm/uvmdist_H_A.txt](evidence/uvm/uvmdist_H_A.txt), order-blind, on HEAD and both off:

  | row | distance | file facets away | method_func_call file facets |
  |---|---|---|---|
  | MiniAmiq d/t | 16872 → 15848 / 15847 | 4867 → 3832 | 15 on both |
  | SeqDriver d/t | 15772 → 14629 / 14630 | 5190 → 4035 | 15 on both |
  | SimpleUVM d/t | 10672 → 9810 | 3714 → 2841 | 15 on both |
  | Scoreboard d | 9306 → 8649 | 3001 → 2335 | 15 on both |

  These are pass 171's figures.
- **jeras_union** `54 → 36 → 75`: an UNMASK. The HEAD walk completes (19912 records = golden's), and the off walk
  diverged at #8592. The prefix is FTOWARD with 18 fields lost; 40 records sit past the old divergence. Order-blind,
  chain-keyed:
  - 174 on vs off: records ours holds that golden lacks go 108 → 60, with 0 golden records lost.
  - 171 on vs off: 106 → 60, with 0 lost.
  - The 75 faces (60 range-constant files, 15 full names) are present with every single 171 law off (15/60, +44 value
    with VALUE off, +2 file with CASTUNIONFILE off). They are older faces, not introduced by either landing.
- **ibex_multdiv_fast** `endcol(26) → file(11)`: FTOWARD, lost 15.
- **FuncStructValSimple** `42/62 → 40/60`: FTOWARD, lost 2.
- **struct_param_func_config** `fullname(14) → line(8)`: FTOWARD, lost 6, the same divergence #1364 / #1274.

## 7. Downstream ([evidence/downstream/](evidence/downstream), [drivers/dscase.py](drivers/dscase.py), [drivers/dsrow.py](drivers/dsrow.py))

- **uhdm2rtlil rows the landings converted or changed** (swH): struct_param_field_shift, param_nested_struct_field_width,
  rp32_r5p_{alu,bru,mdu,wbu}, jeras_union, ibex_multdiv_fast and struct_param_func_config each have `_nohier.il`,
  `.il` and `_synth.v` byte-identical between the Surelog lane and ours. Rows:
  `struct_param_field_shift,IDENTICAL,OK,OK,1,1,,` `param_nested_struct_field_width,IDENTICAL,OK,OK,70,70,,`
  `rp32_r5p_alu,IDENTICAL,OK,OK,1332,1332,,` `rp32_r5p_bru,IDENTICAL,OK,OK,174,174,,`
  `rp32_r5p_mdu,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `rp32_r5p_wbu,IDENTICAL,OK,OK,320,320,,`
  `jeras_union,IDENTICAL,NO_GATES,NO_GATES,0,0,,`. The swA downstream csv is byte-identical to swH's.
- **Surelog-corpus rows pass 171 converted** (not downstream-gate rows; run through the harness's `one()` with their
  source lists): GenerateUnnamed and UnionCast are IDENTICAL NO_GATES, and YosysBigSimEllip is IDENTICAL OK 9775 /
  9775. YosysOldOr is EQUIVALENT OK 25921 / 25921, pre-existing. Each row's slang-lane netlists have the same md5
  with the landings on and off ([surelog_rows.txt](evidence/downstream/surelog_rows.txt)).
- **Own cases** (F, G, H, J, N, D and x03: 32 cases; ON, ALLOFF, OWN; [cases_ON_ALLOFF_OWN.txt](evidence/downstream/cases_ON_ALLOFF_OWN.txt)):
  23 IDENTICAL in all three states, 6 EQUIVALENT in all three, 2 DIVERGENT in all three (F/f01, G/g04), and 1
  STATUS_DIFF in all three (J/j05). No case leaves IDENTICAL.

## 8. Residues

### Re-measured at the base ([evidence/residues_cases_at_base.txt](evidence/residues_cases_at_base.txt), the swH csvs)

| source | residue | at 7fadac8a |
|---|---|---|
| pass 171, 1 | rp32 DEPTH face | **gone**: rp32 d/t CMP_EQUAL (pass 174 landed § pkgFnCastTopListing172) |
| pass 171, 2 | ibex_multdiv_fast d/t (the generate-block enum constants) | `differ:file(11)` d/t, stands |
| pass 171, 3 | Scr1SvTests d/t (the call argument's formal typespec) | `differ:type(1)` d/t at #16033, stands |
| v11u171, R1 | the end-only tie-break (alphabetical module order) | stands: h05 file(9) on law and all-off; this directory's a02 (m2.sv golden, dut.sv law, a_pkg.sv pristine) |
| v11u171, R2 | the formal key ignores the package | h10 file(10) (pristine 20), stands |
| v11u171, R3 | a package-qualified formal is not relocated | h01 file(2)+span, stands; a04 here: the law still fixes the unqualified writer |
| pass 174, 1 / r11v174, R1 | FuncStructValSimple package-listing leftovers | `file(40)` / `file(60)`, stands |
| pass 174, 2 / r11v174, R2 | FuncStructVal INSTR_PER_FETCH | `endcol(95)` / `endcol(177)`, stands |
| pass 174, 3 | UVM class-scope casts (DEPTH never fires) | stands: the census reproduces 0 DEPTH firings on UVM rows |
| r11v174, R3 | an overridden struct parameter's member fold (mo/b06) | `file(1)` (all off: fullname(12)+), stands |

### New, found here (none is a break of the two landings)

1. **The cast union clone's parent** (the break, fixed).
2. **A bare decimal with `_` onto a select keeps the underscore in its value** (G/g04 `assign c[15:8] = 1_0;`). Golden
   has `UINT:10`, ours `UINT:1_0` in every state (§ selBareDec144's literal shape). It is **downstream-visible**:
   g04 is DIVERGENT in every state.
3. **An output re-declared `integer` keeps the port declaration's `logic` typespec in golden** (F/f01), and ours types
   it `integer` in every state. It is **downstream-visible**: DIVERGENT, 1 vs 7 gates. § splitPortTsKeyOnPortDecl171
   moves only the span.
4. **A non-lvalue input terminal in a UDP-form swallow** (h03): golden keeps only the operation's leftmost leaf in the
   swallowed concatenation (`x` of `x & y`), where ours keeps the operation. Pre-existing, stage 1.
5. **Member folds golden leaves unfolded**: a header localparam over a `$unit` base (n02), a class static base (n03)
   and an interface parameter (n06) all stay operations in golden. **A generate-localparam base** (n04) is unlocated in
   golden, and § elabStructMemberOpFoldUnlocated174 does not reach generate scopes.
6. **Gaps of § tdMoveCarriesFile172**: a module-function formal in another file (a06) is not relocated in ours, file
   face; an enum formal (a07) is § tfArgTypedefLastWriter146's.
7. **Gaps of § genElseIfGateTermPath171** (j01 gate array, j02 `else begin if end`, j09 flat else-if with a nested if):
   fullname(3) in every state (v11u171's R5, extended by j09).

## 9. The fence and the process

**No law, case or number here rests on a fenced reading.** Every case is this directory's. Every corpus reading is a
non-fenced row through a fail-closed driver ([drivers/rowrun.sh](drivers/rowrun.sh), [drivers/bvmirror.sh](drivers/bvmirror.sh):
`fenced_skipped=8` on every mirror, [drivers/census.sh](drivers/census.sh): `fenced mentions: 0`, [drivers/uvmdist.sh](drivers/uvmdist.sh),
unmask.py, fieldrows.py, compose.py, bytecancel.py and additive.py skip fenced rows unread) or a gate sweep. A grep
for the four names over r11u171repro, v11u171repro, r11u172rp, r11u174repro, r11v174repro, r11u177verify and this
directory finds 0 mentions.

**Two laws of each pass re-derived from this directory's cases and Surelog's source only** (the parameter- and
constant-shaped laws nearest the fenced tests):

- § boundLitWrittenDigits172: `third_party/Surelog/src/DesignCompile/CompileExpression.cpp:471-477`. The `slIntConst`
  branch erases `_` and keeps the text ("Do not evaluate the constant"). B/b01 and b06 convert (value face), and b07
  shows golden's decompile without `_`, the older R4 face.
- § selLhsBareDecRhsShared171: `UhdmWriter.cpp:2257-2276` (reduceExpr on the Rhs, clone_tree of the assign,
  `adjustSize(tps, ...)`, `res->VpiParent(assign)`) with `CompileHelper.cpp:4073-4075` (`if (ts == nullptr) return
  result;`). A select Lhs has no typespec, so one constant is re-parented at the last cell. carhs census on G/g02,
  g03, g04 and x05: golden = law.
- § elabStructMemberOpFoldUnlocated174 with § mopPkgBaseReduces174v: `NetlistElaboration.cpp:514-562`. When
  `instance->getValue` is valid, a constant is located at the assignment (`populateCoreMembers`, :560). When it is
  not (a member of a function-built module parameter), `getComplexValue` goes through `reduceExpr` (:580-596), and the
  minted constant has no location. A package parameter is elaborated before the module, so its member read is valid:
  located. N/n05 toward; n01, n07 and n08 (package bases) keep golden's location only with the refinement.
- § asmRefQualWholeSpanElab174: `CompileExpression.cpp:2717-2750`. In elaboration mode a package-scoped reference is
  replaced by a clone of the package parameter's value. The whole-reference span in the elaborated listing is read
  from goldens: M/m02 and m03 param_assign lines go to golden's, and every other M line is unchanged.

**Drivers of the four evidence directories.** None reads `$FENCED` from canaudit.sh's `FENCED=` line.

- r11u171repro/drivers/env.sh reads RESUME.md by pattern (`for n in ...;`) and refuses fewer than four names.
- v11u171repro/drivers/env.sh reads the pattern from `/tmp/wt_v11u171pris/RESUME.md`, a pruned worktree. It cannot
  run from the tree, and it fails closed (FENCED empty → refused); its drivers source `/tmp/v11u171_scr/env.sh`.
- **r11u174repro/drivers/env.sh and r11v174repro/drivers/env.sh read RESUME.md by LINE NUMBER** (78-80) and have no
  count check. At 7fadac8a they still yield the canaudit set (measured, names not printed), but an edit above line 78
  of RESUME.md would silently change them.

Refusal without `$FENCED`, by driver:

| directory | refuses (count check or `${FENCED:?}`) | reads its own cases, probe cases or evidence only | not fail-closed on corpus reads |
|---|---|---|---|
| r11u171repro | attrib.sh, boundary.sh, bvmirror.sh, case.sh, dscase.py, predict171.py, rowrec.sh (`${FENCED:?}`, no count check), switches.sh, uvmdist.sh | carhs.cpp, cen171.cpp, grid.sh, judge.sh, obdist.sh, obrec.sh | - |
| v11u171repro | through the scratch env.sh: attrib.sh, case.sh, judge.sh, boundary.sh, mirror.sh | away.sh, away2.sh, recs.sh, dd.sh, obd.sh, dscase.py | - |
| r11u174repro | bvmirror.sh, census.sh, offbytes.sh, predict.py, rowrec.sh, rowtoward.sh, switches.sh | grid.sh, anc.py, recanc.py, toward.py, tracewrap.sh | - |
| r11v174repro | census.sh, grid.sh | pdump.sh (probe databases), cmp2.sh, dmcmp.sh, ds.sh, pa.py, pacmp.sh, swmat.sh | **toward.sh**: reads corpus row databases and refuses a fenced row, but with an empty `$FENCED` its refusal loop does nothing |

v11u171's and r11v174's `sweep*.sh` drivers are gate sweeps that dispatch every row.

**The predictions were written before the sweeps, as far as the tree can show.** The scratch of both passes is
pruned, so no timestamp survives. What is reproducible:

- Pass 171 ([evidence/process/pred171_rerun.tsv](evidence/process/pred171_rerun.tsv)): the committed
  `predict171.py` + `cen171.cpp`, run over this directory's sweep of pass 171's base state. That is `stf34.sh`, whose
  probe reads EQUAL 2697 / STRICT_NOTEQUAL 1390, pass 171's own pristine figures. The rerun reproduces `pred_F.tsv`
  exactly (2036 rows, 0 differing lines) and differs from `pred_P.tsv` only by its 2 GENELSEIF rows. The prediction is
  a function of the pristine databases alone. Its reach is as reported: 41 of 42 movers named, ImplicitPorts2
  testflags missed, 1757 keys.
- Pass 174 ([evidence/process/census174_rerun_all.tsv](evidence/process/census174_rerun_all.tsv)): its census.sh +
  tracewrap, run on law.bin in pass 174's law state (`st174law.sh`, probe EQUAL 2783 = pass 174's law sweep). It
  reproduces `census_all_firings.tsv` (101 rows) and `predicted_movers.tsv` (**82 names**) exactly, with `fenced
  mentions: 0`. The census is a function of the binary alone.

**r11v174's package-base refinement holds on every base shape written here:**

| base | cases | reading |
|---|---|---|
| package | n01, n07, n08 | the refinement keeps golden's location |
| `$unit` | n02 | the law acts, wrong to wrong (golden: unfolded operation) |
| class static | n03 | the law acts, wrong to wrong (golden: unfolded operation) |
| interface | n06 | the law acts, wrong to wrong (golden: unfolded operation) |
| generate localparam | n04 | nothing fires; golden unlocated |

The package test does not reach any shape where golden locates.

**Operations of this pass, disclosed.**

- A first attempt to build `pre.bin` named the wrong CMake target and exited at once; it was rebuilt.
- A first cmds.txt audit script had a grep bug. It reported every line as not matching, and the lines it had written
  were deleted and re-audited (3273 of 3273 per sweep).
- Up to three sweeps ran concurrently at `--jobs 3`.
- No process this pass did not start was touched. The live pairs' worktrees were not touched.

## 10. Files

- [fix.patch](fix.patch): § castUnionCloneKeepsCastParent182v (`git diff 7fadac8a -- src`).
- `cases/{A..N,X}/`: 82 cases, the first line naming their laws; A, D/d01-d02, E/e01, E/e03 and X/x01 carry an `args`
  file.
- `drivers/`:
  - `env.sh`: `$FENCED` from canaudit.sh.
  - `laws.py`: law → switch map.
  - `case.sh`, `grid.py`, `gridall.sh`, `gridsum.py`, `lawtable.py`.
  - `fieldscore.py`, `recaway.py`, `recaway2.py`, `recchain.py`, `dumpaway.py`, `pa.py`, `pacmp.sh`.
  - `objlist.cpp`, `objchain.cpp`, `carhs.cpp`, `predfix.cpp`, `cc.sh`.
  - `rowrun.sh`, `mkstate.sh`, `sweep.sh`, `census.sh`, `tracewrap.sh`.
  - `compose.py`, `bytecancel.py`, `additive.py`, `unmask.py`, `fieldrows.py`, `bvmirror.sh`, `uvmdist.sh`,
    `fixbytes.sh`, `dscase.py`, `dsrow.py`.
- `evidence/`: `grid/`, `fix/`, `composition/`, `changes/`, `downstream/`, `uvm/`, `process/`, `sweeps/`,
  `residues_cases_at_base.txt`.
