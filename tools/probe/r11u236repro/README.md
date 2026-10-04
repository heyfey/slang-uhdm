# r11u236 — pass 236, the expression/parameter ground (implementer)

Base `6152687b` (matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`, `src/StmtEmit.cpp` and the new switch
header `src/R236.h` (nine laws, each behind its own `R11U236_<LAW>_OFF`; `R11U236_OFF` drops all and restores the
pristine bytes; `R11U236_TRACE=<dir>` writes `<dir>/<pid>.236`, first line `OUT <-o path>`, then one `<law> <detail>`
line per firing). The four slang-fenced tests are never named here: every driver reads them from the `FENCED=` line
of `tools/probe/r11u107repro/canaudit.sh`, fail-closed; nothing fenced was dispatched, read, decoded or opened.

## Verdict per targeted row (base -> this pass; fresh csv rows of the law sweep)

No row converts. Every change is a first record moved later in the walk with no golden-agreeing record lost
(chain-keyed away census 0 on every mover).

| row-mode | base | after | first record after, and whose ground |
|---|---|---|---|
| Earlgrey_0_1 d/t | `differ:fullname(18)` | `differ:fullname(5)` | #121994 (t #123468): genvar index `bank` of `host_rsp_avail[bank]` in an operation in a for-generate port connection, golden `...host_req_i.bank`, ours `...host_req_i.host_rsp_avail.bank`: written by ModuleEmit `emitDefGenStmts` (its syntax-walk naming lambda, found with gdb on `evidence/decode/G/g01`) — **ground B** |
| BlackBePipeInt d / t | `differ:type(1)` | `differ:fullname(73)` / `fullname(75)` | #24671 (t #24667): the member ref_typespec names of `bp_be_pkg::all_cfgs_gp`'s element struct (packed array of `bp_proc_param_s` re-listed in the importing package): golden `bp_be_pkg::all_cfgs_gp::bp_common_pkg::bp_proc_param_s::cc_x_dim`, ours the module copy's `work@bp_be_pipe_int.bp_common_pkg::bp_proc_param_s.cc_x_dim` — map 15's N2471 (ParamEmit `makeParamTs` < `drainDefParamTs`, § pkgImpParamMemberColons210 does not reach a packed-array element) — ground A, not written |
| MiniAmiq d/t, SeqDriver d/t | `differ:fullname(2)` | `differ:depth(1)` | MiniAmiq #64612, SeqDriver #64568 / #64580: in the importer clone `svaunit_pkg::uvm_oneway_hash` (uvm_misc.svh 378) golden binds the `_byte` reference of the for-loop's `_byte < string_in.len()` / `_byte++` to the HOME function's loop variable `uvm_pkg::uvm_oneway_hash::_byte` (listed there first), ours to the clone's own: a reference binding in a clone body (net/variable binding, which the brief keeps out of scope) — not written |
| FuncStructVal t | `differ:depth(1)` #13254 | `differ:depth(1)` #14765 | the default row's head #7975 (golden's `1024'({64'b0, 64'b0})` cast operations under `cva6_cfg_empty`'s members: map 14's N0891, TypeEmit `buildStructTs`) — **ground B** |
| FuncStructVal d | `differ:depth(1)` #7975 | unchanged | same, ground B |
| cfg_func_width_loop d/t | `differ:type(1)` | unchanged (no byte moved) | the kept call `q::maxw(M)`: the fold is decided in ModuleEmit `emitContAssigns` (`CallFold cfr = (topView && ... && !evalKeep148)`), the predicate `evalFuncSelectKeepsCall148` (ModuleEmit, § evalFuncSelectKeepsCall148) does not recognise `maxw`'s for-loop-with-`if (cfg[i])` body as one ExprEval cannot reduce — **ground B** (the folded constant is not first written in ExprEmit or ParamEmit) |
| BuildUVMPkg d/t | `differ:fullname(4)` | unchanged | #71346 `uvm_callbacks::this_type` alias ref full name (golden prefixes `uvm_pkg::`, map 15's N0161) — ground B |

Fresh rows (`/tmp/r11u236_wlaw/surelog.csv`, the law binary):

```
BlackBePipeInt,default,STRICT_NOTEQUAL,differ:fullname(73),,differ:fullname(73)
BlackBePipeInt,testflags,STRICT_NOTEQUAL,differ:fullname(75),,differ:fullname(75)
Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
FuncStructVal,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
FuncStructVal,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
MiniAmiq,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
MiniAmiq,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
SeqDriver,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
SeqDriver,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
```

**Probe: three conversions** (STRICT_NOTEQUAL -> EQUAL, `results/golden_probe.csv` untouched):
`r10earl34repro/v1_view` `differ:fullname(8) -> EQUAL` (§ hpSelIdxPkgFoldTsOwner236), `r10v65repro/a6_def` and
`r10v65repro/a8_orphan` `differ:fullname(2) -> EQUAL` (§ defConnIpsFoldTsOwner236); one change
`r10v169repro/v169_g_control` `differ:fullname(14) -> differ:line(10)` (§ cloneRetParamFoldTsName236: its four
fullname records cleared, the ten pre-existing `line` records — a second `return` of the wildcard clone located at
the home's line — stand; objects_differing 14 -> 10, the walk does not diverge on either binary).

## The laws

### § pkgDefPatSubstShared236 (switch `R11U236_PKGDEFSHARE_OFF`; ExprEmit pkgPatSubstValue branch, ParamEmit emitParameters)

BlackBePipeInt #15272 (brief item 1). Decoded with object ids (`drivers/objid236.cpp`, `drivers/strictid236.cpp`):
the head is NOT the elaborated listing pass 232 looked at (its constant 302135 under `bp_unicore_cfg_p`'s
elaborated operation is listed at #90776 on both sides). The head is the declaring package's DEFINITION listing
(AllPackages, `vpiTop` 0): there golden's `bp_custom_cfg_p.cc_x_dim: bp_default_cfg_p.cc_x_dim` and
`bp_unicore_megaparrot_cfg_p`'s taken branch `bp_unicore_cfg_p.cc_x_dim` hold ONE unparented constant (7783519),
distinct from `bp_default_cfg_p`'s own pattern constant; across the listing 159 such objects are shared by 2144
tagged patterns, every one in that listing and none in the elaborated or any import listing (where golden keeps
one object per use). Ours minted a copy per use (pkgPatSubstValue's branch, "RESIDUE (byte-identity only)").
**Law**: in the declaring package's definition listing (`inPackage && !topView && !isImported`, flag
`pkgDefPatShare236()` set by ParamEmit around the initializer), the copy is memoised per source object, and the copy
maps to itself so a read chained through an already-substituted parameter lands on it. Traced `reuse` (moves bytes)
and `first` (the memo insert, writes nothing by itself; the predictor lists it apart).
Cases (all § pkgDefPatSubstShared236): `cases/BP/bp01` (stage 1 at the base, unchanged), `bp02`, `bp03`
(`differ:type -> differ:line`: the def listing now walks identically, object counts equal, the next records are
pre-existing spans of the elaborated listing), `bp04` (stage 1, unchanged).

### § pkgPatArithLeftParenSpan236 (switch `R11U236_ARITHPAREN_OFF`; ExprEmit, the package pattern arithmetic-member fold)

Exposed by the previous law (BlackBePipeInt #15558 ...): `dcache_features : (1 << e_cfg_enabled) | (1 << e_cfg_lr_sc)`
folds to UINT:17 at 2992:26-46 in golden, the left operand's parentheses included; ours 27-45. slang's operand range
stops inside the parentheses; the syntax is the ParenthesizedExpression for an operation and the inner name for a
bare reference `(N) + 1` (whose implicit conversion carries no syntax). **Law**: the span climbs every enclosing
parenthesis of the left operand. Case `cases/BP/bp05` (§ pkgPatArithLeftParenSpan236): `differ:col(9) -> EQUAL`,
both views.

### § hpSelIdxPkgFoldTsOwner236 (switch `R11U236_HPIDXOWNER_OFF`; ExprEmit emitMixedHierPath + the selFold9 naming site)

Earlgrey_0_1 #106660-#106722 (brief item 2c): `assign region_cfgs[MpRegions].base.q = '0;` — the index constant's
ref_typespec: golden `work@flash_ctrl`, ours `region_cfgs[8]` (selFold9 names it after the bit_select). Golden's
names are UHDM ComputeFullName of golden's parent chain (the getter caches a computed name; golden stores none
there): the getValue clone hangs at the DEFINITION module's param_assign (`work@sub` even inside `work@top.u_s`,
case e06), or, in an elaborated continuous-assignment lvalue, at the select (`work@top.u_s.rc[2].base.q.rc`).
Measured on cases E (pristine golden vs ours, both views):

| component | def listing | elaborated listing |
|---|---|---|
| mid-path (followed by members), cont-assign lvalue | `work@<module>` | the chain (select-parented) |
| mid-path, read; any procedural or subroutine position | `work@<module>` | `work@<module>` |
| trailing, lvalue (cont-assign or procedural) | the chain | the chain |
| trailing, read | the select's name (ours already) | same |

**Law**: emitMixedHierPath records the path, the component's mid/trailing position and lvalue-ness; at the
selFold9 / procSelFold9 naming site a component index fold takes `work@<definition>` (the chain's module_inst
`VpiDefName`) or no stored name (ComputeFullName then reads golden's chain); abstains through a generate scope, a
port, an interface, a package or a class (unmeasured). Traced `def` / `chain`.
Cases (all § hpSelIdxPkgFoldTsOwner236): e01 e04 e05 e06 e09 e11 e15 e17 (`differ:fullname -> EQUAL`, e11's
elaborated view `fullname -> name`: its four fullname records cleared, the pre-existing #462 struct-member order stands),
e02 (a module localparam: a different face, unchanged), e03 e07 e08 (controls, unchanged), e10 e13 e14 (generate,
interface: the law abstains, bytes unchanged), e12 e16 e18 (stage 1 at the base on a trailing part-select lvalue
`rc[N].base.q[N-1:0] = ...`, unchanged count).

### § hpMidSelBaseSelDotted236 (switch `R11U236_MIDSELBASESEL_OFF`; ExprEmit emitMixedHierPath)

Found by the grid (e17): a continuous-assignment lvalue select on a member array FOLLOWED by a member, when the path's
BASE is itself selected (`rc[1].fs[0].q = ...`, a packed array of structs): golden keeps the simple dotted name
`rc[1].fs[0]` at the member-name span 11:16-18, ours the lazily frozen doubled form at 11:16-21; with an unselected
base (`t.fs[1].q`) golden keeps the doubled form (the existing branch, unchanged). **Law**: the selected-base case
takes the read's shape. Cases e17, e19 (§ hpMidSelBaseSelDotted236 named in e19's first line; e17 carries both laws):
`differ:fullname -> EQUAL`. Corpus firings: none (no corpus mover).

### § defConnIpsFoldTsOwner236 (switch `R11U236_CONNIPSOWNER_OFF`; ExprEmit, the ipsWidFold9 naming and both hier-path indexed-part-select width stamps)

Earlgrey_0_1 #119021-#121124 (brief item 2c's second family): `.req_addr_i(flash_addr[WordW +: AllPagesW])` and
`.op_addr_i(reg2hw.addr.q[DataBitWidth +: AddrW])` in flash_ctrl's DEFINITION listing: golden's base/width fold
reads `work@flash_ctrl`, ours the port path the prefix holds. **Law**: in a definition listing's port connection
(`defRefModConn`) the indexed-part-select base/width fold names the instantiating definition (ownerInstName192 through
the port, no generate scope); the elaborated connection is unchanged (already golden's). Cases (§
defConnIpsFoldTsOwner236): p01 p02 p03 (`differ:fullname -> EQUAL`), p04 p05 (stage 1 at the base on other shapes,
unchanged), p06 (a generate block and an instance array: abstains, unchanged).

### § cloneRetParamFoldTsName236 (switch `R11U236_CLONERETTS_OFF`; StmtEmit, the § pkgRetParamSubstIsRhsClone120 return fold)

MiniAmiq / SeqDriver #64390 (brief item 2b): `return uvm_revision;` in the importer's clone
`svaunit_pkg::uvm_revision_string`: golden's folded constant reference reads `svaunit_pkg::uvm_revision_string` (the
chain through the clone's return statement), ours `uvm_pkg`. **Law**: in an importer clone (`pkgImportCloneEmit`,
both views) the reference names the clone (the emission prefix); the home's elaborated listing keeps the package
name. Case `cases/U/u01` (§ cloneRetParamFoldTsName236): four fullname records cleared, the next head is a
func_call listing face (#142 depth, the same class as the corpus' new heads).

### § namedCallArgFormalTs236 (switch `R11U236_NAMEDARGTS_OFF`; ExprEmit stampCond48)

Brief item 2a (pass 231's residue): a NAMED-argument call `h(.y(b), .x(a))` in a module's continuous assignment:
golden stamps every actual with ITS OWN formal's typespec (a -> x's `int` 3:28, b -> y's 3:35; typedef formals the
per-formal `UVM_FILE` copy), exactly as the positional form; the exclusion `!namedArgs9` was measured on
EvalFuncNamed, whose named call sits inside a package FUNCTION body. **Law**: the exclusion holds only inside a
subroutine body (`currentTf` / `currentSubSym`). Cases (§ namedCallArgFormalTs236): n01 n03 n04 n05 n08 n15
(`NOT_EQUAL -> EQUAL`, both views), n10 n11 (named calls in a function body, a localparam initializer, a class:
EQUAL on both binaries, controls), n07 (stage 1 at the base and after: golden lists the omitted defaulted formal's
value, 17 -> 15 lines), n09 n13 (a named call in a generate block: stage 1 at the base, n13 shows the face alone; in
n09 the head moves from the child instance's call, fixed, to that pre-existing face, 17 -> 37 lines). Corpus
firings: none.

### § caOpArgIntFormalTs236 (switch `R11U236_OPARGTS_OFF`; ExprEmit argCtxOk)

Brief item 2d (pass 231's CA c05): `h(a, a + 1)` — golden stamps the `int` formal's typespec on the OPERATION actual;
ours excluded `intFormal && operation`. Measured: golden stamps an operation of nets/variables (c05, n06, n14
`v[3:0] + a`, `-a`, `a * P`) and also `P + L` (n14), but uhdm2rtlil int_types' `f(-1)` (an operation of a literal in a
generate net declaration) is bare: stamping every operation regressed int_types d/t (stage 1; an experiment binary,
not delivered). **Law**: an operation actual that reads a net or a variable takes the stamp. Cases (§
caOpArgIntFormalTs236): n02 n06 (`NOT_EQUAL -> EQUAL`), n12 n14 (stage 1 at the base and after: n14's head is `P + L`
— golden stamps an all-parameter operation too, the residue that int_types forbids taking blindly). Corpus firings
traced on Scr1SvTests d/t (4 each) with no byte moved (the trace sits in the predicate; the stamp's later conditions
fail).

### § patLeftoverCopyShared236 (switch `R11U236_LEFTCOPYSHARE_OFF`; ParamEmit stampEvalFuncLeftovers, § patLeftoverOrphanCopy151's copy)

FuncStructVal t #13254 (brief item 1): `cfg.AxiUserWidth = CVA6Cfg.AxiUserWidth;` and `cfg.DCACHE_USER_WIDTH =
CVA6Cfg.AxiUserWidth;` in `build_config`: golden's two typespec_members hold ONE Actual_value (constant 9722, 76:31-54,
the caller pattern's element), ours a § 151 copy each (5451, 5508), the second listed again where golden's is
already visited. **Law**: the § 151 copy is made once per caller element per stamped struct. FuncStructVal t's head
moves from #13254 to #14765, the default row's ground-B head. Cases (§ patLeftoverCopyShared236): l01 l02 (stage 1 at
the base in these small shapes — a module-parameter call to a package function — byte movers with an unchanged
uhdm-cmp line count; the corpus row is the witness).

## Binaries (frozen before any measurement; every cmds.txt audited by binary path)

| binary | md5 | note |
|---|---|---|
| pristine (`/tmp/r11u236_bin/pristine`) | `ed8c598e76da99bd014a5ba69e751d23` | rebuilt at `6152687b` with the system-deps config, identical to the main tree's; reports slang 12.0.0+545f88b2e |
| law (`/tmp/r11u236_bin/law`) | `ca838e5b2888680e04a3ec8c9fcd4f1c` | this patch |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the worktree's build of `tools/uhdm-strictcmp` |
| strictcmp_x | `886f030233ecdbcce7d0e29ac0c4df2c` | `drivers/strictcmp_x.cpp` (map 15's variant + a fence check), built by `drivers/cc_x.sh`, for the away census |

Every `cmds.txt` of the four gate sweeps names `/tmp/r11u236_bin/pristine` or `/tmp/r11u236_bin/law` only.
Development binaries (`dev*`, one experiment binary `exp10` for the all-operation variant of § caOpArgIntFormalTs236,
section on that law) ran only on cases and scratch filtered sweeps, never on the gate.

## Gates (from the worktree, SLANG_UHDM exported, `tests/sweep.sh --jobs 3`)

| stage | pristine sweep | law sweep |
|---|---|---|
| probe | EQUAL 3454 + STRICT_NOTEQUAL 633, regressions 0 (the csv byte-identical to `results/golden_probe.csv`) | EQUAL 3457 + 630: **regressions 0, conversions 3, changes 1** (above) |
| surelog | 932 CMP_EQUAL + 22 STRICT_NOTEQUAL, 0 / 0 / 0 | 932 + 22: **regressions 0, conversions 0, changes 8** (BlackBePipeInt d/t, Earlgrey_0_1 d/t, MiniAmiq d/t, SeqDriver d/t, quoted above) |
| uhdm2rtlil | 1604 + 2, 0 / 0 / 0 | 1604 + 2, **0 / 0 / 0** |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 | **803 / 66 / 2 / 0, not excused 0, verdict diff 0** against the pristine sweep |

Both sweeps print `law index STALE` first: the base's committed `tests/LAWS.md` predates its own commit (the commits
column cannot hold the commit that carries it); the patch carries the regenerated file and `law_index.py --check`
reads current on it. Canary battery on the law csvs: `canaries.sh` surelog ok=48 changed=4 (Earlgrey_0_1 d/t,
SeqDriver d/t, the changes above), uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog ok=56 changed=2
(BlackBePipeInt d/t, the change above; pristine ok=58 changed=0), `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS
(ok=2). uhdm-cmp on every corpus mover reads 0 lines ([evidence/movers/cmp_movers.txt](evidence/movers/cmp_movers.txt)).

## The mover prediction, frozen before the law sweep ([evidence/census/](evidence/census/))

`drivers/census.sh` ran the law binary with `R11U236_TRACE` over both corpora in both modes (`--filter` built from
`$FENCED`, the fenced tests never dispatched) and every probe case, and `drivers/dscensus.py` every downstream lane
(the harness's translated command line). `drivers/predict.py` names every database whose process fired a
byte-writing branch (the memo-insert `first` branch of § pkgDefPatSubstShared236 is listed apart): **19 predicted
movers** (12 surelog row-modes, 7 probe cases, 0 uhdm2rtlil, 0 downstream lanes), frozen at the time in
`frozen_at.txt`, md5 `d1b7cdf7a47278cdb318227f4af2191a`, before the law sweep started. Per law, databases firing:
pkgDefPatSubstShared236 2 (BlackBePipeInt d/t, 1985 reuses each), pkgPatArithLeftParenSpan236 2 (BlackBePipeInt d/t,
5 each), hpSelIdxPkgFoldTsOwner236 3, defConnIpsFoldTsOwner236 4, cloneRetParamFoldTsName236 5,
patLeftoverCopyShared236 2, caOpArgIntFormalTs236 5, namedCallArgFormalTs236 0, hpMidSelBaseSelDotted236 0.
(The census was restarted twice when a refinement replaced the law binary; the frozen prediction is the run of the
final binary.)

**byteverify** (`tools/probe/r11v75repro/byteverify.sh` on hard-link mirrors of both sweeps without the fenced paths,
`drivers/bvmirror.sh`; [evidence/movers/byteverify.txt](evidence/movers/byteverify.txt)): `PATH_SETS_IDENTICAL (2560
paths)`, **MOVERS: 10 / 2560**: BlackBePipeInt, Earlgrey_0_1, FuncStructVal, MiniAmiq, SeqDriver, each d/t — all
predicted by name; the two predicted row-modes that did not move are Scr1SvTests d/t (§ caOpArgIntFormalTs236's trace
sits in its predicate; the stamp's later conditions fail there). None of the known coins moved (Scoreboard d and
SimpleUVM d/t wrote the pristine bytes). `SELFCHECK (every file vs one fixed file): 2559 / 2560 flagged` is the
self-check reading correctly, not a mover line: the comparator is run with one side replaced by ONE fixed file, and
that file compared with itself is the one path it cannot flag. **Probe**: 4 of 4087 databases move
([evidence/movers/probe_movers.txt](evidence/movers/probe_movers.txt)), all predicted; the three predicted cases that
do not move (r10v122repro/q4inst, q6clone, r10vbuvm29repro/gv29_b_positions) are § caOpArgIntFormalTs236 predicate
traces with no stamp. **Downstream lanes**: 0 of 805 lane databases differ between the pristine and the law
downstream sweeps (positive control: two different lanes compared read as a mover).

## Away-moved-record census (map 12's, `drivers/awayrows.py` with strictcmp_x; [evidence/movers/away.txt](evidence/movers/away.txt))

Over the 14 databases that differ between the pristine and the law gate sweeps: **chain-keyed away 0 on every one**,
toward 78 (Earlgrey_0_1 16 per mode, BlackBePipeInt 10, MiniAmiq 3, SeqDriver 2, v1_view 8, v169_g_control 4,
a6_def 2, a8_orphan 2, FuncStructVal 0). Flat key: 2 away on SeqDriver d and t and on FuncStructVal t, all three
explained record by record: SeqDriver's two `ref_typespec uvm_pkg` records become `adpcm_pkg::uvm_revision_string`
(golden holds exactly 2 of the latter; its 105 `uvm_pkg` records include 2 elsewhere ours lacks at the base, so the
flat count coincided); FuncStructVal t's two `ref_typespec cva6_config_pkg` records are the now-shared leftover's
second listing, at the position where golden's shared object is not listed either (golden 1354, pristine 1296, law
1294: the shortfall is elsewhere).

## Determinism, UVM distance

`drivers/det.sh` (three concurrent harness runs of the law binary on Earlgrey_0_1 and the five UVM rows, both modes;
[evidence/det_law.txt](evidence/det_law.txt)): one hash per row-mode on all 11 row-modes with a database (Scoreboard t
is SLANG_REJECT), each equal to the law sweep's. UVM order-blind distance (`drivers/uvmdist.sh`, its cache lookup now
`find -L` because the golden cache keys are links since a40fe1a6; [evidence/uvmdist.txt](evidence/uvmdist.txt)):
MiniAmiq d/t dist 1298 -> 1295 (total 5625 -> 5619); SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg, ApbSlave, SVSwitch
unchanged.

## Grid (cases/, 48 cases, both views; `drivers/grid.sh`; [evidence/grid.txt](evidence/grid.txt))

1152 runs (pristine, law, law with `R11U236_OFF`, the law with each of the nine switches; default and `-elabuhdm`
views), **every exit code 0**, no SLANG_FAIL or SURELOG_FAIL. `R11U236_OFF` writes the pristine bytes on 96 of 96
case-views; each switch alone reverts exactly its own law's cases (PKGDEFSHARE 8, ARITHPAREN 8, HPIDXOWNER 22,
MIDSELBASESEL 6, CONNIPSOWNER 10, CLONERETTS 2, NAMEDARGTS 20, OPARGTS 8, LEFTCOPYSHARE 4 case-views). 76 case-views
move bytes; **41 enter STRICT_EQUAL, none leaves EQUAL**; no uhdm-cmp line count grows except n09 (the head moves to
a pre-existing face, n13). Per case:

| case | law | default view: pristine -> law | -elabuhdm view: pristine -> law |
|---|---|---|---|
| BP/bp01 | pkgDefPatSubstShared236 | NOT_EQUAL(cmp 11) -> NOT_EQUAL(cmp 11) | NOT_EQUAL(cmp 11) -> NOT_EQUAL(cmp 11) |
| BP/bp02 | pkgDefPatSubstShared236 | SNE:type -> SNE:line | SNE:type -> SNE:line |
| BP/bp03 | pkgDefPatSubstShared236 | SNE:type -> SNE:line | SNE:type -> SNE:line |
| BP/bp04 | pkgDefPatSubstShared236 | NOT_EQUAL(cmp 88) -> NOT_EQUAL(cmp 88) | NOT_EQUAL(cmp 88) -> NOT_EQUAL(cmp 88) |
| BP/bp05 | pkgPatArithLeftParenSpan236 | SNE:col -> EQUAL | SNE:col -> EQUAL |
| E/e01 | hpSelIdxPkgFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| E/e02 | hpSelIdxPkgFoldTsOwner236 | SNE:fullname -> SNE:fullname | EQUAL -> EQUAL |
| E/e03 | hpSelIdxPkgFoldTsOwner236 | EQUAL -> EQUAL | EQUAL -> EQUAL |
| E/e04 | hpSelIdxPkgFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| E/e05 | hpSelIdxPkgFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| E/e06 | hpSelIdxPkgFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| E/e07 | hpSelIdxPkgFoldTsOwner236 | NOT_EQUAL(cmp 17) -> NOT_EQUAL(cmp 17) | NOT_EQUAL(cmp 17) -> NOT_EQUAL(cmp 17) |
| E/e08 | hpSelIdxPkgFoldTsOwner236 | EQUAL -> EQUAL | EQUAL -> EQUAL |
| E/e09 | hpSelIdxPkgFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| E/e10 | hpSelIdxPkgFoldTsOwner236 | NOT_EQUAL(cmp 172) -> NOT_EQUAL(cmp 172) | NOT_EQUAL(cmp 172) -> NOT_EQUAL(cmp 172) |
| E/e11 | hpSelIdxPkgFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> SNE:name |
| E/e12 | hpSelIdxPkgFoldTsOwner236 | NOT_EQUAL(cmp 286) -> NOT_EQUAL(cmp 286) | NOT_EQUAL(cmp 286) -> NOT_EQUAL(cmp 286) |
| E/e13 | hpSelIdxPkgFoldTsOwner236 | NOT_EQUAL(cmp 172) -> NOT_EQUAL(cmp 172) | NOT_EQUAL(cmp 172) -> NOT_EQUAL(cmp 172) |
| E/e14 | hpSelIdxPkgFoldTsOwner236 | SNE:endcol -> SNE:endcol | SNE:endcol -> SNE:endcol |
| E/e15 | hpSelIdxPkgFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| E/e16 | hpSelIdxPkgFoldTsOwner236 | NOT_EQUAL(cmp 266) -> NOT_EQUAL(cmp 266) | NOT_EQUAL(cmp 266) -> NOT_EQUAL(cmp 266) |
| E/e17 | hpSelIdxPkgFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| E/e18 | hpSelIdxPkgFoldTsOwner236 | NOT_EQUAL(cmp 274) -> NOT_EQUAL(cmp 274) | NOT_EQUAL(cmp 274) -> NOT_EQUAL(cmp 274) |
| E/e19 | hpMidSelBaseSelDotted236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| L/l01 | patLeftoverCopyShared236 | NOT_EQUAL(cmp 11) -> NOT_EQUAL(cmp 11) | NOT_EQUAL(cmp 11) -> NOT_EQUAL(cmp 11) |
| L/l02 | patLeftoverCopyShared236 | NOT_EQUAL(cmp 89) -> NOT_EQUAL(cmp 89) | NOT_EQUAL(cmp 30) -> NOT_EQUAL(cmp 30) |
| N/n01 | namedCallArgFormalTs236 | NOT_EQUAL(cmp 17) -> EQUAL | NOT_EQUAL(cmp 17) -> EQUAL |
| N/n02 | caOpArgIntFormalTs236 | NOT_EQUAL(cmp 17) -> EQUAL | NOT_EQUAL(cmp 17) -> EQUAL |
| N/n03 | namedCallArgFormalTs236 | NOT_EQUAL(cmp 17) -> EQUAL | NOT_EQUAL(cmp 17) -> EQUAL |
| N/n04 | namedCallArgFormalTs236 | NOT_EQUAL(cmp 17) -> EQUAL | NOT_EQUAL(cmp 17) -> EQUAL |
| N/n05 | namedCallArgFormalTs236 | NOT_EQUAL(cmp 17) -> EQUAL | NOT_EQUAL(cmp 17) -> EQUAL |
| N/n06 | caOpArgIntFormalTs236 | NOT_EQUAL(cmp 17) -> EQUAL | NOT_EQUAL(cmp 17) -> EQUAL |
| N/n07 | namedCallArgFormalTs236 | NOT_EQUAL(cmp 17) -> NOT_EQUAL(cmp 15) | NOT_EQUAL(cmp 17) -> NOT_EQUAL(cmp 15) |
| N/n08 | namedCallArgFormalTs236 | NOT_EQUAL(cmp 17) -> EQUAL | NOT_EQUAL(cmp 17) -> EQUAL |
| N/n09 | namedCallArgFormalTs236 | NOT_EQUAL(cmp 17) -> NOT_EQUAL(cmp 37) | NOT_EQUAL(cmp 17) -> NOT_EQUAL(cmp 37) |
| N/n10 | namedCallArgFormalTs236 | EQUAL -> EQUAL | EQUAL -> EQUAL |
| N/n11 | namedCallArgFormalTs236 | EQUAL -> EQUAL | EQUAL -> EQUAL |
| N/n12 | caOpArgIntFormalTs236 | NOT_EQUAL(cmp 212) -> NOT_EQUAL(cmp 212) | NOT_EQUAL(cmp 212) -> NOT_EQUAL(cmp 212) |
| N/n13 | namedCallArgFormalTs236 | NOT_EQUAL(cmp 37) -> NOT_EQUAL(cmp 37) | NOT_EQUAL(cmp 37) -> NOT_EQUAL(cmp 37) |
| N/n14 | caOpArgIntFormalTs236 | NOT_EQUAL(cmp 17) -> NOT_EQUAL(cmp 17) | NOT_EQUAL(cmp 17) -> NOT_EQUAL(cmp 17) |
| N/n15 | namedCallArgFormalTs236 | NOT_EQUAL(cmp 17) -> EQUAL | NOT_EQUAL(cmp 17) -> EQUAL |
| P/p01 | defConnIpsFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| P/p02 | defConnIpsFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| P/p03 | defConnIpsFoldTsOwner236 | SNE:fullname -> EQUAL | SNE:fullname -> EQUAL |
| P/p04 | defConnIpsFoldTsOwner236 | NOT_EQUAL(cmp 64) -> NOT_EQUAL(cmp 64) | NOT_EQUAL(cmp 64) -> NOT_EQUAL(cmp 64) |
| P/p05 | defConnIpsFoldTsOwner236 | NOT_EQUAL(cmp 40) -> NOT_EQUAL(cmp 40) | NOT_EQUAL(cmp 44) -> NOT_EQUAL(cmp 44) |
| P/p06 | defConnIpsFoldTsOwner236 | NOT_EQUAL(cmp 46) -> NOT_EQUAL(cmp 46) | NOT_EQUAL(cmp 46) -> NOT_EQUAL(cmp 46) |
| U/u01 | cloneRetParamFoldTsName236 | SNE:fullname -> SNE:depth | SNE:fullname -> SNE:line |

Decode-only sources (sister-ground faces, kept as `dut.sv.txt` with an `args` file so the law index does not attach
them): [evidence/decode/G](evidence/decode/G) g01 g02 (Earlgrey #121994 / #123996: ModuleEmit `emitDefGenStmts`), g03
(Earlgrey #123586: a `$clog2(N)` in an if-generate localparam; our `sys_func_call` is unparented, written by TypeEmit
`emitSyntaxExpr` called from ModuleEmit `emitDefGenStmts`), g04 g05 (Earlgrey #122230 does not reproduce: STRICT_EQUAL).

## Sister-ground faces (decode only, call sites)

1. Earlgrey_0_1 d/t #121994 / #123996 (2 of the row's 5): ModuleEmit `emitDefGenStmts`, the syntax-walk naming lambda
   stores `<port>.<select name>.<genvar>` on a genvar index reference of a select inside an operation in a
   for-generate port connection; golden's name is the chain's (the select skipped): `...host_req_i.bank`.
2. Earlgrey_0_1 #123586: the def-listing gen-scope localparam `NumLevels = $clog2(N)`: TypeEmit `emitSyntaxExpr`
   (called from ModuleEmit `emitDefGenStmts`'s param_assign) leaves the `sys_func_call` unparented, so `N`'s name
   computes empty; golden parents it at the param_assign (`work@prim_arbiter_tree.gen_normal_case.N`).
3. FuncStructVal d/t #7975 / #14765: N0891, TypeEmit `buildStructTs`.
4. cfg_func_width_loop d/t: ModuleEmit `emitContAssigns`, § evalFuncSelectKeepsCall148's predicate.
5. BuildUVMPkg d/t #71346: N0161 (`uvm_callbacks::this_type`, UhdmExporter `buildClassTypedefTs` family).

## Residues, ranked (ground A)

1. **BlackBePipeInt d/t #24671**: N2471 — the importing package's re-listed `all_cfgs_gp` (packed array of a package
   struct): its element struct's member ref names (`bp_be_pkg::all_cfgs_gp::...::cc_x_dim`, and in the module
   `work@bp_be_pipe_int.all_cfgs_gp...`); ours shares the module's struct copy. ParamEmit `makeParamTs` /
   `drainDefParamTs`; § pkgImpParamMemberColons210 covers a struct parameter, not a packed array's element. The row
   then holds map 15's N0028 / N0118 / N0873 (tens of thousands of objects): not convertible in one pass.
2. **MiniAmiq / SeqDriver #64612 / #64568**: the importer clone's loop-variable reference binds the home function's
   variable in golden (a binding face; the brief keeps binding out of scope).
3. Earlgrey_0_1 #122230: `WordSelW = WidthMultiple == 1 ? 1 : LsbAddrBit` re-listed in `flash_phy_core`: golden locates
   the folded value at the taken branch (43:53-63), ours at the whole ternary; two small shapes (g04, g05) do not
   reproduce it. Then #130430, the structural range / ref_typespec record.
4. § caOpArgIntFormalTs236's other half: golden stamps an all-parameter operation actual too (`h(x, P + L)`, n14),
   but not uhdm2rtlil int_types' `f(-1)` in a generate net declaration; the distinguisher is not decoded.
5. Named calls: an omitted defaulted formal's value (n07), a named call in a generate block (n09, n13), a mixed
   positional/named call in a process (n12): stage 1 at the base, unchanged.
6. Member paths: a trailing part select or indexed part select in an lvalue member path (`rc[N].base.q[N-1:0] = ...`,
   e12 e16 e18, stage 1 at the base); a module localparam index in a member path (e02: golden names the index
   reference through the path, `work@top.rc[L].base.q.L`); the generate and interface cells of
   § hpSelIdxPkgFoldTsOwner236 (e10 e13 e14) where the law abstains.
7. Small shapes for § pkgDefPatSubstShared236 and § patLeftoverCopyShared236 stop at pre-existing stage-1 faces
   (bp01 bp04, l01 l02: golden's struct ref_typespec on a module's read of a package parameter member, the
   pattern-operation listing of a package localparam built by a function).
8. Brief items not attempted: (3) pass 232's residues (struct-pattern overrides under the definition law, nested-copy
   record losses, formal typespecs written where golden does not, the elaborated typedef-typed value's typespec, the
   408 minted locals per MiniAmiq / SeqDriver row-mode, the param_assign `int` stamps behind pass 228's member law);
   (4) BuildUVMPkg's 18 ground-A clusters (its first record #71346 is ground B); (5) N0131, N0039, the `[N]` bound
   with an unsized inner dimension, forward references, the string-law and part-select-width items; (6) N0008, the
   value encodings, the UVM A families, `$size` with a genvar dimension.

## Drivers (`drivers/`; every one reads `$FENCED` fail-closed, compiled helpers included)

`env.sh`, `case.sh` (from r11u232repro), `grid.sh` (the grid), `census.sh`, `dscensus.py`, `predict.py` (the
prediction; `first` traces listed apart), `bvmirror.sh`, `det.sh`, `uvmdist.sh` (`find -L` fix), `awayrows.py` (from
r11u232repro), `strictcmp_x.cpp` + `cc_x.sh` (map 15's variant comparator with a fence check), `objid236.cpp`,
`strictid236.cpp` + `cc_tools.sh` (decode helpers: every object by UhdmId with its parent, pattern, actual; the strict
walk with each record's UhdmId), all refusing to run without `$FENCED` or on a path naming a fenced test.

## Process notes

- Every command ran from the worktree `/tmp/wt_r11u236` (base `6152687b`); scratch under `/tmp/r11u236_*`; the main
  checkout's `git status` read clean at every check. No submodule was initialised in the worktree.
- One write landed nowhere: a heredoc to a relative-looking path `$RP/drivers/grid.sh` with `RP` unset tried
  `/drivers/grid.sh`, which does not exist; the shell refused, nothing was written (checked `/drivers` and the
  main checkout).
- Killed only processes this pass started (by pid, children first): the two stale census runs and nothing else.
- gdb ran only on this pass's own cases (`evidence/decode/G`, cases E, P, U), never on a corpus source.
- Every tool call through a variable was guarded (`[ -x ]` in env.sh / case.sh); no database was executed.
