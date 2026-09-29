# v11u227 — adversarial verification of r11u227 (pass 227, the expression/parameter ground): one break refined (§ fwdPkgRefConstSlotWhole227v), everything else reproduced

Base `ac0dda58` (pass 224). Implementer's patch `/tmp/r11u227.patch` (md5 `2e2f97e80dedc722e8c4874c85ed0b66`).
Verified patch: `/tmp/r11u227.verified.patch` (git diff against `ac0dda58`: the implementer's patch plus the refinement
below, this directory, and the regenerated tests/LAWS.md). An integration-ready rebase on `97343175` is
`/tmp/r11u227.verified.head.patch` (section 8).

## 0. Verdict

**ACCEPTED WITH FIX.** One law broke on legal SV where pristine was right: § fwdPkgRefClassScopeSpan227 cut a forward
`Q::name` to `Q::` when the reference sits in a **constant-grammar slot inside expression grammar**: the bounds of a part
select, the width of an indexed part select, or the count of a replicated assignment pattern. There golden keeps the
whole name. Pristine wrote the whole name, and the law moved those records away from golden. The pass's own grid did not
include these shapes. The refinement § fwdPkgRefConstSlotWhole227v (switch `R11V227_CONSTSLOT_OFF`; `R11V227_OFF` drops
every refinement of this verification) lets the innermost grammar decide. It fires on no corpus row-mode, no probe case,
no downstream lane and none of 2860 case-views of 19 landed grids. It changes no gate csv row. Every other headline number
of the pass reproduces exactly.

| target | before -> after (fresh csv rows of the fix sweep, [evidence/sweeps/](evidence/sweeps/)) | law |
|---|---|---|
| FuncStructVal default | `STRICT_NOTEQUAL,differ:endcol(7)` -> `FuncStructVal,default,STRICT_NOTEQUAL,differ:file(5),,differ:file(5)` (CHANGE; #747 family cleared, head now the INSTR_PER_FETCH read-site leftover) | § fwdPkgRefClassScopeSpan227 |
| FuncStructVal testflags | `differ:endcol(10)` -> `FuncStructVal,testflags,STRICT_NOTEQUAL,differ:file(9),,differ:file(9)` (CHANGE) | § fwdPkgRefClassScopeSpan227 |
| map 14's N0003 (20 gate probe cases) | 20 CHANGES, each shrinking its first field (`fullname(5)` -> `fullname(4)` ...; a5 `fullname(10)` -> `fullname(8)`); none converts | § pkgPatFuncBodyLeftoverNoParent227 |
| v11u224 NX/nx05 | parse view `STRICT_NOTEQUAL fullname` -> `STRICT_EQUAL 63 objects`; `--elabuhdm` view unchanged (`fullname`) | § newArrayPartSelStripped227 |
| the address-order loop | one hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, BuildUVMPkg (both modes); every mover STRICT_EQUAL to pristine on the raw walk, uhdm-cmp 0 lines | § refChainDrainIdOrder227 (**duplicate of HEAD's § fullNameDrainIdOrder226v; drop it at integration, section 8**) |
| switch reach | R11U48 112 / 30 / 2 / 0, R11V190 146 / 14 / 4 / 0 reproduced; split bytes equal the old switch's bytes wherever the split moves | § landingSwitchReach227 |

No corpus row-mode converts and no probe case converts, as the implementer reported.

## 1. Binaries (frozen `chmod 555` under /tmp/v11u227_bin before any measurement)

| name | md5 | what |
|---|---|---|
| pris.bin | `4af5fef78fce30c048738988bca79c9c` | `ac0dda58` built in /tmp/wt_v11u227pris, byte-identical to the base's build |
| law.bin | `3eca48dc648268bc7bab3052df2ddf0c` | `/tmp/r11u227.patch` applied to a fresh `ac0dda58` worktree: **the implementer's law7.bin byte for byte** |
| fix.bin | `d30de296669e4c9e3c94218ea47b9873` | law.bin's source plus § fwdPkgRefConstSlotWhole227v (the verified patch; rebuilt from the patch in a fresh worktree, section 9) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | this worktree's build, identical to the main tree's (every sweep's comparator) |
| headfix.bin | `ff1c0cc9cc3f779983ca287c50d87198` | `97343175` plus the rebased verified patch (section 8) |
| headpris.bin | `7e50408d1da06eaece796ba1903c589f` | a copy of the main tree's build/slang-uhdm at `97343175` (section 8) |

Every `slang:` line of the three sweeps' 3273 corpus cmds.txt names that sweep's binary (`pris.bin` 3273, `law.bin`
3273, `fix.bin` 3273).

## 2. The implementer's numbers, reproduced

| claim | reproduced |
|---|---|
| law7.bin md5 `3eca48dc...` from the patch on a fresh `ac0dda58` | yes (law.bin) |
| law sweep: probe 0 / 0 / 20, surelog 0 / 0 / 2, uhdm2rtlil 0 / 0 / 0, downstream 803 / 66 / 2 / 0 | yes ([sweep_swL.log](evidence/sweeps/sweep_swL.log)); pristine 0 / 0 / 0 everywhere, 803 / 66 / 2 / 0 ([sweep_swP.log](evidence/sweeps/sweep_swP.log)) |
| downstream csv identical to pristine's | yes, byte-identical; 0 of 805 lane databases move and every lane's `.il` / `_nohier.il` is identical |
| 11 corpus movers of 2560 (byteverify) | yes, the same 11 ([byteverify_law_vs_pristine.txt](evidence/movers/byteverify_law_vs_pristine.txt)) |
| 23 probe movers of 4087 | yes, the same 23, measured with both binaries run from the same tree ([probe_movers_law_vs_pristine.txt](evidence/movers/probe_movers_law_vs_pristine.txt)) |
| frozen prediction, 34 names, md5 `8532dbcb54eb54036e2bd57ce3dbc0b0` | my own census of fix.bin writes a byte-identical prediction (same md5, [evidence/census/](evidence/census/)) |
| away census over the 34 movers: 0 away, 25 toward; reversed control 25 away | yes, with v11u202's order-blind away.py: lost 0, gained 25 (FuncStructVal d/t 2 each, 21 probe); reversed lost 25 ([evidence/away/](evidence/away/)) |
| UVM order-blind distance unchanged | yes: MiniAmiq 1761, SeqDriver 1304, SimpleUVM 914, Scoreboard 585, BuildUVMPkg 230 on both binaries |
| grid: 54 cases, 108 views, 59 moved, 26 converting, 0 leaving EQUAL, R11U227_OFF pristine on all 108 | yes ([implementer_grid_P_L_F_LO.txt](evidence/grid/implementer_grid_P_L_F_LO.txt)); fix.bin moves none of the 108 |
| canaries surelog ok=50 changed=2, ctcan2 PASS both | yes, on the fix sweep ([evidence/sweeps/](evidence/sweeps/)) |
| R11U227_OFF restores pristine bytes; R11U227_FWDPKGSPAN_OFF alone restores FuncStructVal | yes: FuncStructVal d/t, BuildUVMPkg d/t, SeqDriver d/t under law.bin + R11U227_OFF write the pristine hashes, and FuncStructVal d/t under R11U227_FWDPKGSPAN_OFF alone ([switch_restore.txt](evidence/det/switch_restore.txt)) |

**byteverify's SELFCHECK reading 2559 of 2560.** The self-check compares every patched database against the
*pristine* database of one fixed path (the list's first path, a non-mover). The patched copy of that same path equals
its pristine copy, so it is the one path the check cannot flag. The implementer's wording ("that file against itself")
is close but not exact. Every other file differs from that one database.

## 3. The break and the refinement

### 3.1 § fwdPkgRefClassScopeSpan227 in a constant-grammar slot (grid [cases/BF](cases/BF))

Surelog's grammar (third_party/Surelog/grammar/SV3_1aParser.g4) reads a `select`'s `[ part_select_range ]` as
`constant_range : constant_expression COLON constant_expression` or `indexed_range : expression part_select_op
constant_expression`. It reads a replicated assignment pattern as `'{ constant_expression { expression, ... } }`. A
forward `Q::name` in one of those slots therefore parses as `constant_primary` (package_scope, the whole name), even when
the select or pattern sits in a pattern member or a call argument. The law walked up to the first expression-grammar
node, found the pattern member or call above the slot, and cut the span to `Q::`.

| case (both views) | written | golden | pristine | law | fix |
|---|---|---|---|---|---|
| bf02 | `y: W[p2::E2:0]` (pattern member) | 7:12-18 | 7:12-18 | **7:12-16** | 7:12-18 |
| bf03 | `y: W[0 +: p2::E2]` | 7:17-23 | 7:17-23 | **7:17-21** | 7:17-23 |
| bf26 | `y: W[5 -: p2::E2]` | 7:17-23 | 7:17-23 | **7:17-21** | 7:17-23 |
| bf25 | `y: W[p2::E3:p2::E1]` | 7:12-18, 7:19-25 | same | **7:12-16, 7:19-23** | same as golden |
| bf04 | `a: '{p2::E4{64'h0}}` | 4:12-18 | 4:12-18 | **4:12-16** | 4:12-18 |
| bf28 | `a: '{p2::E2{64'h0, 64'h1}}` | 4:12-18 | 4:12-18 | **4:12-16** | 4:12-18 |
| bf15 | `localparam int Y = $countones(W[p2::E3:0]);` | 4:35-41 | 4:35-41 | **4:35-39** | 4:35-41 |
| bf31 | `$bits(W[p2::E3:0])` | 5:30-36 | 5:30-36 | **5:30-34** | 5:30-36 |
| bf36 | `'{b: W[p2::E3:p2::E0], default: 0}` | 4:33-39, 4:40-46 | same | **4:33-37, 4:40-44** | same as golden |
| bf37 | `C ? W[p2::E3:0] : 0` (constant ternary's first branch) | 5:28-34 | 5:28-34 | **5:28-32** | 5:28-34 |

An expression-grammar node *below* the slot still decides first. The law is right on these, and the fix keeps them:
`W[$clog2(p2::E4):0]` (bf23, golden 7:19-23 `Q::`), `W[(C ? p2::E3 : 1):0]` (bf24, 8:17-21). The base of an indexed
part select and a bit-select index are expression grammar, so `Q::` is right there too: bf21 `W[p2::E1 +: 2]` and
bf20 `W[p2::E1]` (7:12-16). Likewise a concatenation replication count, `{p2::E4{64'h0}}`, parses through
`multiple_concatenation : { expression concatenation }` (bf22, golden 4:11-15). A bit-select chain `S[p2::E1][p2::E2]`
(bf29, `Q::`) is expression grammar as well.

**The refinement** (§ fwdPkgRefConstSlotWhole227v, ExprEmit `fwdConstSlot227v` read in `fwdPkgRefClassScopeSpanDrain227`;
switch `R11V227_CONSTSLOT_OFF`, and `R11V227_OFF` drops it; `R11U227_OFF` drops the pass and with it the
refinement). While walking up from the reference, a constant-grammar slot met *before* any expression-grammar node locks
the grammar to constant, and the law declines. The slots are a part_select's Left_range and Right_range, an
indexed_part_select's Width_expr, and operand 0 of a `vpiMultiAssignmentPatternOp`. Every decline is traced
(`fwdPkgRefConstSlotWhole227v` under R11U227_TRACE).

BF grid: 37 cases, 74 case-views, both producers' databases per case text
([fresh_grid_summary.txt](evidence/grid/fresh_grid_summary.txt)).

| | law.bin vs pristine | fix.bin vs pristine |
|---|---|---|
| case-views moved | 48 | 42 |
| judge-equal views: records away / toward | **10 / 20** | **0 / 20** |
| every forward-reference span over all 74 views (dump census, [BF_dump_span_census.txt](evidence/grid/BF_dump_span_census.txt)) | **38 golden-matching spans lost**, 101 gained | **0 lost**, 101 gained |
| leaving EQUAL / judge-equal -> stage 1 | 0 / 0 | 0 / 0 |

`R11V227_OFF` on fix.bin writes law.bin's bytes on all 74 views, and `R11U227_OFF` writes pristine's bytes on all 74.
The refinement moves exactly the 20 views of the 10 cases whose first line names it. It moves none of the
implementer's 108 grid views, no corpus database, no probe database and no downstream lane.

Downstream: bf02, bf03, bf20, bf25 and bf26 read `IDENTICAL` (both lanes crash in the plugin on a package with a
forward reference) on all three binaries ([dscase_verdicts.txt](evidence/ds/dscase_verdicts.txt)).

### 3.2 The other laws, attacked (no break)

* **§ pkgPatFuncBodyLeftoverNoParent227** (grid [cases/BP](cases/BP), 12 cases, 24 views). The judge-equal movers are
  bp03 (the parameter written `parameter`) and bp12 (`'{default: 7}`) in both views. Each first differing record moves
  later (for example #153 -> #471): the package listing's pattern operation takes golden's unparented, unnamed
  reference. The stage-1 movers are bp07 (two parameters read), bp08 (also read in a module) and bp09 (read inside a
  loop). On each, the moved record is that operation's ref_typespec, unparented as in golden. The shapes it leaves
  untouched are correct declines: a direct pattern member (bp01, bp02), a module-default pattern (bp04), a function
  argument (bp05), a ternary read (bp06), another package's parameter (bp10) and a read under `if` (bp11). 0 leave
  EQUAL. `R11U227_OFF` restores pristine bytes on all 24 views.
* **§ newArrayPartSelStripped227** (grid [cases/BN](cases/BN), 15 cases, 30 views). 4 convert in the parse view: bn01
  `new[v[k+1 +: 2]]`, bn06 `v[k -: 2]`, bn08 the copy form with an operation, bn09 a module task. 2 stage-1 views move
  toward golden: bn13 (an interface function) and bn14 (a generate block), golden `indexed_part_select v (v)`. The
  plain constant part selects bn02-bn05, bn07 and bn12 are already EQUAL and unchanged, and the control bn15 (outside
  `new`) is unchanged. 0 leave EQUAL, and no `--elabuhdm` view moves.
* **§ refChainDrainIdOrder227**. On all 8 corpus movers of the UVM family, pristine and fix databases read
  `uhdm-strictcmp --no-canon` STRICT_EQUAL (181,148 to 427,341 objects) with uhdm-cmp at 0 lines. In the landed grids
  its 8 movers (r11u201repro M/N) have identical records.
* **§ landingSwitchReach227**. The old switches' meanings are unchanged: each site ANDs a new env read, which is inert
  unless it is set. Reproduced R11U48_OFF against R11U227_SPLIT48A_OFF (112 case-views, old 30, split 2, split-only 0)
  and R11V190_OFF against R11U227_SPLITV190A_OFF (146, 14, 4, 0); on every split mover the split writes the old
  switch's bytes ([evidence/reach/](evidence/reach/)).

### 3.3 Byte control over the landed grids

[bytectl.sh](drivers/bytectl.sh) ran binaries only over tools/probe r11u224repro, v11u224repro, r11u220repro,
v11u220repro, r11u131repro, r11v131repro, r11u124repro, r11v124repro, r11u118repro, r11v11u118repro, r11u119repro,
r11u120repro, r11v120repro, r11u201repro, r11u200dec, r11u210repro, r11u26repro, r11u28repro and r11u24repro, both
views: **2860 case-views**, with exit codes identical on all.

* pristine vs fix: **29 movers**, judged against goldens ([bytectl_movers_judged.txt](evidence/bytectl/bytectl_movers_judged.txt)).
  * r11u201repro M/N, 8 views (the id-order drain): records identical.
  * r11u26repro m1 m2 m3 m5 and r11u28repro a1 a3 a11 a14 a17 a18, 20 views (§ pkgPatFuncBodyLeftoverNoParent227): each
    judge-equal view's first differing record moves later. On m2 `--elabuhdm` the head field becomes `name`, because
    the next differing record (#585, member order) already differed at the base. On each stage-1 view the listing's
    pattern operation takes golden's unparented ref_typespec.
  * v11u224 nx05, 1 view: converts.
* law vs fix: **0 movers**.

## 4. The gates (fix.bin, `tests/sweep.sh --jobs 3`, against the committed baselines)

| stage | pristine.bin | law.bin | **fix.bin** |
|---|---|---|---|
| probe vs golden_probe.csv | 3453 + 634, 0 / 0 / 0 | 0 reg / 0 conv / 20 changes | **0 regressions, 0 conversions, 20 changes** (3453 + 634) |
| surelog vs golden_surelog.csv | 0 / 0 / 0 | 0 / 0 / 2 | **0 regressions, 0 conversions, 2 changes** (FuncStructVal d/t) |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 1600 + 6, 0 / 0 / 0 | 0 / 0 / 0 | **0 / 0 / 0** (1600 + 6) |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0 | **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT** |

The fix sweep's four csvs are row-for-row identical to the law sweep's. No strict cell moves between them, and no row
moves away from IDENTICAL. EXIT=1 on all three sweeps is only the tests/LAWS.md staleness notice. `ac0dda58` itself
reads stale, and the verified patch carries the regenerated index. uhdm-cmp reads 0 lines on every touched row-mode and
probe case: each stays judge-equal in the sweep. Canaries on the fix sweep: surelog ok=50 changed=2 (exactly
FuncStructVal d/t), uhdm2rtlil ok=16 changed=0, ctcan2 surelog PASS (EXPECT_UNKNOWN=1), ctcan2 uhdm2rtlil PASS
(EXPECT_UNKNOWN=6).

## 5. Movers, predicted before the fix sweep

* **Census**: fix.bin under R11U227_TRACE over every corpus row-mode except the fenced ones (census.sh's negative
  `--filter` from the FENCED= line), every probe case, and every downstream lane's translated command line (dscensus.py,
  871 lanes). `fwdPkgRefConstSlotWhole227v` fires in **0** of the 58 trace files and in 0 lanes. predict.py writes the
  same 34 names as the implementer's frozen prediction (md5 `8532dbcb...`). Frozen at 2026-09-29T12:30:36Z with
  fix.bin's md5 ([predict_fix.stamp](evidence/census/predict_fix.stamp)), before the fix sweep: **fix vs law, 0
  movers predicted**.
* **Measured**:
  * fix vs law: 1 of 2560 corpus databases, Scoreboard default. It is the svunit listing coin (92 unsorted dump
    lines, 0 sorted, uhdm-cmp 0, RESUME section 9's known coin).
  * probe: 0 of 4087. Downstream lanes: 0 of 805.
  * fix vs pristine: the same 11 corpus databases and 23 probe databases as law vs pristine.
* **Away census** (fix vs pristine = law vs pristine plus the coin): 0 lost, 25 gained. The reversed control reads 25
  lost.

## 6. Determinism (fix.bin, drivers of r11u227repro det16.sh, 8 draws per row-mode, 4 concurrent)

One database hash per row-mode on Earlgrey_0_1 default and testflags (`ede36385c330` / `260e88febe42`, the pristine
sweep's own hashes), MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t and BuildUVMPkg d/t. Scoreboard default draws 2 hashes
(3 + 5), the svunit coin. Every exit code is 0 ([det8_fix.txt](evidence/det/det8_fix.txt)).

## 7. Downstream

The fix sweep's downstream csv is identical to pristine's (803 / 66 / 2 / 0), and no lane database moves. On the fresh
cases bf02, bf03, bf20, bf25, bf26, bn01, bn09, bp03 and bp12 the verdict is the same on all three binaries: IDENTICAL,
with bn14 EQUIVALENT on all three.

## 8. Integration: § refChainDrainIdOrder227 duplicates a landed law

r11u226 landed § fullNameDrainIdOrder226v (`01dc93ab`, 06:50, switch `R11V226_IDORDER_OFF`), which applies the same fix
as § refChainDrainIdOrder227: the same three loops of refFullNameThroughNamedExpr175, stable-sorted by UhdmId. The
brief said to skip the item if r11u226 had landed by the start, and it landed while the pass was running. The patch
therefore **does not apply on HEAD**. Two conflicts are in src/ExprEmit.cpp (the include line, and the three loops) and
one in tests/LAWS.md. The resolution is to keep HEAD's § fullNameDrainIdOrder226v and drop § refChainDrainIdOrder227:
its loops, `idOrderObjs227`, `IdOrderTrace227` and the `refChainDrainIdOrder227` trace line. After that,
`R11U227_IDORDER_OFF` is no longer read.

`/tmp/r11u227.verified.head.patch` is that resolution on `97343175`. The function refFullNameThroughNamedExpr175 is
byte-identical to HEAD's, and the other src hunks are exactly the verified patch's. Check at `97343175`
([head_grid_HP_HF_HO.txt](evidence/integration/head_grid_HP_HF_HO.txt), all 118 cases of both grids, 236 case-views):

* headfix.bin under R11U227_OFF writes the main tree's binary's bytes on all 236.
* The same 117 case-views move as at the base.
* Every strict verdict equals the base's.

The full gates were not re-run at HEAD: that is the integration sweep's job.

## 9. Fence, process and findings on the pass

* The fence held. case.sh, bytectl.sh, awaymov.py and dscase.py require `$FENCED` to hold the four names of the
  FENCED= line of tools/probe/r11u107repro/canaudit.sh, refuse any path naming one of them, and fail closed.
  recaway.py reads only the record files case.sh wrote. The gate sweeps dispatched every row, and the census ran
  with the negative filter. Evidence csvs and logs drop every line holding a fenced name, even as a substring. No
  fenced name appears in this directory.
* One process listing, taken to confirm the census had started, printed the census's `--filter` argument. Nothing ran
  on fenced sources, and no file holds the names.
* Every tool call here goes through a variable checked with `[ -x ]`. The implementer's case.sh calls `$UHDM_CMP` and
  `$STRICT_CMP` unquoted, guarded only by env.sh's `${VAR:?}`, which checks that the variable is set but not that it
  is executable. Its dumpdelta.sh and rowdelta.sh quote `"$UHDM_DUMP"`. An unset variable cannot execute a database in
  either case, but the brief's `[ -x ]` guard is absent.
* The implementer's grid missed constant-grammar slots. The law's own comment says "once reached, every
  sub-expression is expression grammar", which is false for part-select bounds, indexed widths and pattern replication
  counts.
* tests/LAWS.md is stale at `ac0dda58` itself (the pristine sweep prints the notice). The patch's regeneration fixes it.
* The verified patch applies clean on a fresh `ac0dda58` worktree and rebuilds fix.bin byte for byte (md5
  `d30de296669e4c9e3c94218ea47b9873`).
* bf19's first draft (a packed array of structs with a pre-dot index `S[p2::E1].y`) made the pinned Surelog segfault.
  It was removed and replaced by the stream-slice shape.

## 10. Residues, ranked

1. The implementer's ranked residues stand, measured unchanged by this verification: FuncStructVal #4782 (N2472 /
   N2473), then N0980 / N1946 and ground B's N0891; N0003's module-listing leftovers (typespec-copy family, TypeEmit)
   and its unreached m4 a2 v5 v6; the spaced `p2 :: E1`; the `--elabuhdm` names of part selects in `new[...]`; the
   brief items not reached (struct_param_func_config, cfg_func_width_loop, BlackBePipeInt #15268 / #15272, N0131,
   Earlgrey N0812, N0039, pass 224's residues, N0008, the value encodings, map 13's clusters, the `[N]` bound).
2. Forward-reference shapes this verification left undecided: a hierarchical pre-dot index `S[p2::E1].y`
   (`complex_func_call`'s `[ constant_expression ] . identifier`; the packed shape crashes Surelog); a size cast
   `p2::E4'(x)` and a streaming slice size (golden holds no reference, folded); `C && p2::E1 ? a : b` in a constant
   ternary (the grammar's `(LOGICAL_AND expression)*` makes the operand expression grammar, and the law misses it:
   pristine's bytes are kept, so this is a miss rather than a break); bf32, where golden drops a named argument's
   reference and ours keeps it (stage 1).
3. Scoreboard default's svunit listing-order coin.

## 11. Files

* `cases/`: BF (37 cases; the 10 on which the refinement fires name § fwdPkgRefConstSlotWhole227v in their first line,
  the controls § fwdPkgRefClassScopeSpan227), BP (12, § pkgPatFuncBodyLeftoverNoParent227), BN (15,
  § newArrayPartSelStripped227).
* `drivers/`:
  * case.sh: one case, golden cached by content, uhdm-cmp and strict records.
  * recaway.py: index-aligned record away/toward.
  * awaymov.py: v11u202's away.py over a mover list.
  * dscase.py: the downstream verdict of a case.
  * bytectl.sh: a binary-pair byte control over case roots.
* `evidence/`:
  * sweeps/: pristine, law and fix sweep logs and csvs, the same-tree pristine probe run, canaries.
  * movers/: byteverify outputs and probe mover lists.
  * away/, census/, grid/, det/, bytectl/, reach/, ds/, integration/.
