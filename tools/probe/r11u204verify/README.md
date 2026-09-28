# r11u204: second adversarial verification of passes 196 and 198 (verifier; measurement plus four refinements in fix.patch)

Base `1454b68c` (branch matrix-1.87). Pass 198 (the expression/parameter ground: seven r11u198 laws and v11u198's
refinement) landed at `cffb131f`; pass 196 (the module/type ground: the seven r11u191 ground-B laws, eight r11u196 laws
and v11u196's two refinements) landed at `c029f423`. On top sit the decode r11u200 (`ddc67d87`) and the map r11u203
(`1454b68c`), both tools only. Worktree `/tmp/wt_r11u204` (system-deps configuration, `-j 2`), scratch `/tmp/r11u204_*`.

This directory is the deliverable. Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited
in the patch, and `tools/uhdm-strictcmp/` is not edited (no comparator defect was found). The refinements are
[fix.patch](fix.patch), a `git diff 1454b68c -- src` (`src/ModuleEmit.cpp`, `src/ExprEmit.cpp`,
`src/TaskFuncEmit.cpp` and a new `src/R204.h` holding the switch and trace helpers). It applies clean on a fresh
`1454b68c` and rebuilds `fix.bin` (section 1). It is NOT applied here.

The brief speaks of "the canonicalisation patch you were given". No such patch was handed to this pass.

The cases name their laws in their first line (`// § law`), so `tests/LAWS.md` reads STALE in every sweep run from this
worktree; the main tree at `1454b68c` reads `law index current` (`python3 scripts/law_index.py --check`, rc 0). That is
the only red of every sweep below.

The slang-fenced tests are named nowhere in this directory. [drivers/env.sh](drivers/env.sh) resolves the repository
from its own path, reads `$FENCED` from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and refuses to run
without four names. Every driver here that reads corpus sources or databases sources it and skips the four names by word
boundary (the firing censuses run the corpora with a `--filter` built from it; the byte mirrors read
`fenced_skipped=8`). No gdb was used. Only the gate sweeps dispatched fenced rows; their csv verdicts are the only fenced
facts cited (all unchanged in every state).

## Verdict

**Six breaks on fresh legal SV; four refined behind their own switches in [fix.patch](fix.patch), two reported with the
measured reason not to refine them here.** Every other law of the two landings holds on 83 fresh cases in both views
(default and `--elabuhdm`) and downstream. The landings compose additively: 0 CANCEL at status level in all three
stages and at byte level over 6647 databases; the switch states reproduce the committed history exactly; every CHANGE
line of both integrations is a strict subset (no NEW, no WORSE); map 12's away census finds **0 chain-keyed records
moved away from golden by either landing over the full corpora and probe set**.

| # | law (landing) | shape (fresh case) | the error, measured | status |
|---|---|---|---|---|
| B1 | § evalFuncCastMemberKeepsCall191 (196), its member branch | a member read of a STRUCT formal bound to a literal-valued actual: `h1(8'h21)`, `h2(8'd33)` (V191/cc3), `h({4'd1,4'd2})`, `h(8'h20+8'h1)`, `h(8'(33))`, `h('1)`, `h(pk::Q)` (cc4), `h(Q)`, `h(Q+8'h1)` (cc5), `h3(8'h96)` / `h4(8'h96)` over a nested struct (cc6), `h(PI)`, `h(PE)` int / enum package parameters (cc7), a header typedef formal `chk2(4'h3)` (hd2) | golden FOLDS these calls, the law keeps them: 14 elaborated calls on 6 cases, uhdm-cmp heads 50 -> 78 (cc3, cc6), and **downstream cc4 IDENTICAL -> DIVERGENT** | **fixed: § memberFormalLitActualFolds204v** (`R11V204_CCLIT_OFF`) |
| B2 | § dfltArgExecutedRead196v + § dfltArgExecutedPathEval196v (196) | the omitted formal read only in a CONDITION on the executed path: `if (b > 0)`, `case (b)`, `while (i < b)`, `repeat (b)` (DF/e07), `for (...; i < b; ...)` (e02); a case whose DEFAULT item is the taken one (e01 f(1)) | golden keeps (a condition that does not reduce sets `invalidValue`; UHDM's `evalStmt` never runs a default item), the refinements fold (slang's evaluator reads the X as false and takes the other branch): 6 calls; e07 STRICT_EQUAL with the refinement's switch off, `type` with it on | **fixed: § dfltArgTaintExec204v** (`R11V204_DFLTTAINT_OFF`) |
| B3 | § evalFuncOmittedDefaultKeepsCall196 (196) | a defaulted formal omitted through NAMED arguments or an EMPTY positional slot: `f(.a(1), .c(4))` (DF/e06), `f(.a(1))`, `f(.a(1), .c(3))`, `f(1, , 3)` (e08) | golden FOLDS (CompileHelper::compileTfCallArguments fills every missing formal of a named list, and an empty slot, with a constant `INT:0`: golden folds `f(.a(1))` to `1`, not `3`); the law keeps: 4 calls, strict type axis away | **not refined**: a keep/fold refinement alone (measured as fix2, `R11V204_DFLTNAMED_OFF`) folds with the declared default (3) and turns **downstream e06 and e08 IDENTICAL -> DIVERGENT**; the kept call reproduces golden's netlist. The complete refinement needs the fold value with the missing formal read as 0 (the constant-fold replay, `constCallFold`): residue N1 |
| B4 | § modGenericHandleBare196 (196) | an INTERFACE home (MG/g06, pass 196's R8) | golden keeps the definition listing's `pkt #(2, logic)` handle specialization list (12 chain-keyed records the law drops) | **not refined**: with the law off the plugin CRASHES (downstream STATUS_DIFF, `--elabuhdm` rc 139); with it on IDENTICAL, rc 0. The complete fix is R8 (list the interface's class at the design root, as Surelog does) |
| B5 | § genHopFoldSelName198 (198) | a one-hop fold DIRECTLY under a unary operator in a select index: `a[-L+7]`, `a[~L & 7]` (N/h2, N/h4) | golden names the fold's reference by the declaring scope (`work@top.g[0]`: compileExpression's unary branch does not re-parent its operand), the law by the select (`work@top.g[0].h.a`): 4 + 16 records | **fixed: § hopFoldUnaryKeepsScope204v** (`R11V204_HOPUNARY_OFF`) |
| B6 | § queueRetTwinDynShape191 (196) | a class method returning a queue typedef of an ENUM (V191/qr3 `typedef e_t eq_t[$]`) | the dynamic-shape twin carries no element typespec; the pristine clone-form twin carried golden's (8 records: `enum_typespec p::e_t` with its base and constants) | **fixed: § queueTwinKeepsElem204v** (`R11V204_QTWINELEM_OFF`), for non-aggregate, non-type-parameter elements |

`R11V204_OFF` drops all four refinements (law.bin's bytes on all 2720 case-modes of section 4 and on every corpus and
probe database).

**Fix measurements** (section 4): - **The boundary**: 2720 case-modes (1360 case dirs of this directory and fifteen evidence directories, both views):
  26 move (13 dirs: r11u196repro V191/qr01 and 12 of this directory's), each by exactly one switch (CCLIT 12, DFLTTAINT
  6, HOPUNARY 4, QTWINELEM 4); `R11V204_OFF=1` gives law.bin's bytes on all 2720.
- **Judged against golden**: TOWARD 14, BYTES-ONLY 10, AWAY 2 (V191/cc5, both views: a chain-key collision, proven per
  call below); per call the fix matches golden's keep / fold on every call the law disagreed on and moves none away;
  STRICT_EQUAL gained on DF/e07 (both views) and N/h4 (`--elabuhdm`); downstream DF/e01, e07 and V191/cc4 go to
  IDENTICAL, V191/cc6 goes IDENTICAL -> EQUIVALENT (N10).
- **The census** (`R11V204_TRACE`, every non-fenced corpus row-mode, probe case and downstream lane): no refinement
  fires anywhere; the positive control fires all four on this directory's cases
  ([prediction_fix.txt](evidence/prediction_fix.txt), frozen at 08:26:54.841, the fix sweep's workdir born 08:26:54.909).
- **The fix sweep**: 0/0/0 in all three compare stages, downstream 803 / 66 / 2 / 0; `probe.csv`, `uhdm2rtlil.csv` and
  `downstream.csv` byte-identical to the HEAD sweep's; 9 / 2560 corpus byte movers, the storage-order draws the
  prediction names (the UVM rows and BuildUVMPkg: ordered and order-blind uhdm-dumps identical to HEAD's; three
  concurrent fix.bin runs per row-mode draw from the binary's own hash pool,
  [det_runs_fix.txt](evidence/determinism/det_runs_fix.txt)); canaries ok=52 / ok=16, ctcan2 PASS / PASS
  ([byteverify_fix_vs_head.txt](evidence/sweeps/byteverify_fix_vs_head.txt),
  [orderblind_fix_vs_head.txt](evidence/sweeps/orderblind_fix_vs_head.txt), [canaries.txt](evidence/sweeps/canaries.txt)).
  A first start of this sweep (08:26:06, before the prediction file was rewritten for fix8) was stopped in its probe
  stage within a minute and discarded; the reported swF started at 08:26:54.
- **Rebuild**: fix.patch applied to this worktree reverted to `1454b68c` (`git apply --check` clean) rebuilds
  `5b2bc7811a09643b481f0ce8114b5357` = fix.bin, bit for bit.

## 1. Binaries and states (frozen `chmod 555` in `/tmp/r11u204_bin` before any measurement; [binaries.txt](evidence/binaries.txt))

| binary | md5 | what |
|---|---|---|
| `law.bin` | `18183f058868a85659208c85a099980e` | worktree build of `1454b68c` = the main tree's `build/slang-uhdm` (`18183f058868`) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |
| `fix1.bin` .. `fix7.bin` | [binaries.txt](evidence/binaries.txt) | development builds, each superseded for a measured reason (below) |
| **`fix.bin` = fix8** | **`5b2bc7811a09643b481f0ce8114b5357`** | `1454b68c` + [fix.patch](fix.patch) |

The superseded builds, in order: fix1 (CCLIT folded union formals too: golden KEEPS a member read of a union formal bound to a
literal, V191/hd1 `g(4'h6)`, cc6 h1, h2); fix2 (carried § dfltArgNamedOrSlotFolds204v, dropped for its downstream
cost: B3); fix3 (CCLIT folded package STRUCT parameters: r11u190verify G/g02 `pf(PP)` went STRICT_EQUAL -> `type`);
fix4 (`isAggregate()` is false for a PACKED struct: G/g02 and V191/cc7 still regressed); fix5 (QTWINELEM gave a class
type-parameter queue twin an element golden lacks: +2 records on every UVM row, V191/qr2); fix6 (its type-parameter
test missed the class specialization's alias); fix7 (the carried STRUCT element adds records golden lacks: V191/qr3 +27,
r11u196repro V191/qr01 +10). Each was found by this directory's boundary before any gate sweep read it as final.

State wrappers ([drivers/mkstate.sh](drivers/mkstate.sh)), all running law.bin under switches:

| wrapper | switches | the state |
|---|---|---|
| `alloff.sh` | `R11U196_OFF R11V196_OFF R11U198_OFF R11V198_OFF` | both landings off (= `a015c911`) |
| `off196.sh` / `off198.sh` | `R11U196_OFF R11V196_OFF` / `R11U198_OFF R11V198_OFF` | one landing off (`off196` = `cffb131f`) |
| `wide.sh` | alloff + `R11U193_OFF R11V193_OFF R11U195_OFF R11V195_OFF R11V199_OFF` | the brief's wide composition |
| `wideon.sh` | `R11U193_OFF R11V193_OFF R11U195_OFF R11V195_OFF R11V199_OFF` | the same with the two landings on |
| `briefoff.sh` | `R11U191_OFF` + alloff | the brief's literal switch set (section 5.2) |

Two facts about the switches, read from the sources: `R11V198_OFF` is read nowhere (a no-op; § vsStampReducedCtxOnly198v
lives inside § callArgVarSelStamp198, so `R11U198_OFF` drops it), and `R11U191_OFF` is **not** landing 196's switch: it
also drops pass 195's three r11u191 ground-A laws (§ idxCallPathAtDots191, § evalFuncExecCallArgTs191,
§ pkgFoldAtLeadingLeaf191: `r191EX` in ExprEmit.cpp and `r191PE` in ParamEmit.cpp read it). `R11U196_OFF` drops the seven
ground-B r11u191 laws (the `r191ME` / `r191TF` / `r191TE` gates read it) and every r11u196 law; the v11u196 refinements
live inside § evalFuncOmittedDefaultKeepsCall196. So landing 196 is `R11U196_OFF R11V196_OFF`.

## 2. Sweeps (`tests/sweep.sh --jobs 3`, [drivers/queue.sh](drivers/queue.sh); `/tmp/r11u204_sw?`, same-length names)

Every sweep's 3273 corpus `slang:` lines name its own binary or wrapper ([cmds_audit.txt](evidence/sweeps/cmds_audit.txt)).
Every golden came from the cache. Gate lines: [sweep_gates.txt](evidence/sweeps/sweep_gates.txt).

| sweep | state | probe EQUAL | surelog d+t CMP_EQUAL | u2r d+t | gate vs results/ |
|---|---|---|---|---|---|
| swH | law.bin, all four stages | 3345 | 461+457 | 796+796 | **0/0/0** in every stage; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0 |
| swA | alloff | 3306 | 461+457 | 793+793 | = `a015c911`'s committed csvs, 0/0/0 in all three stages |
| sw6 | off196 | 3343 | 461+457 | 794+794 | = `cffb131f`'s committed csvs, 0/0/0 |
| sw8 | off198 | 3308 | 461+457 | 795+795 | against swH: exactly pass 198's 37 + 2 probe and 2 + 2 uhdm2rtlil rows, surelog 0 |
| swW / swO | wide / wideon | 3155 / 3193 | 460+456 both | 792 / 794 per mode | section 5.3 |
| swB | briefoff | 3305 | 461+457 | 793+793 | section 5.2 |
| swF | fix.bin, all four stages | 3345 | 461+457 | 796+796 | **0/0/0** in every stage; downstream 803 / 66 / 2 / 0, not excused 0; `probe.csv`, `uhdm2rtlil.csv`, `downstream.csv` byte-identical to swH's, `surelog.csv` different only in the two LowMem log-path texts; 9 / 2560 corpus byte movers (MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d, BuildUVMPkg d/t), every one with an identical ordered and order-blind uhdm-dump (storage order), 0 / 4087 probe movers |

swH also equals `c029f423`'s committed csvs (0/0/0), [states_vs_history.txt](evidence/states_vs_history.txt).
Canaries on swH: `r11u107repro/canaries.sh` surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1
ctcan2.sh` (surelog) and `EXPECT_UNKNOWN=6 ctcan2.sh` (uhdm2rtlil) PASS. uhdm-cmp reads 0 lines on every row the
landings touch (every judge-equal status is kept in every state).

## 3. The fresh cases, per law ([cases/](cases), [evidence/](evidence))

83 cases in 14 groups (DF EN FR K L M MG N O SF TB V V191 X), none in the grids of r11u196repro, v11u196repro,
r11u198repro or v11u198repro. The first line names the laws each case attacks.
- [drivers/case.sh](drivers/case.sh) builds the golden with the pinned Surelog (check_probe's arguments; `EL=1` adds
  `-elabuhdm` / `--elabuhdm`), cached per text md5 under `/tmp/r11u204_g`.
- [drivers/grid.py](drivers/grid.py) runs each case in both views: ON; a trace run (`R11U196_TRACE`, `R11U191_TRACE`,
  `R11U198_TRACE`: the `FIRED` lines, byte-identical to ON on all 164 case-views); each named law's own switch (a
  refinement also under its parent's); each landing off; every pair of named laws (group X); ALLOFF; WIDE.
- Judges: the grid's record / dump reading, [recaway2.py](drivers/recaway2.py) (chain-keyed strict records,
  [recaway2.txt](evidence/recaway2.txt)), [dumpaway2.py](drivers/dumpaway2.py) (reachable uhdm-dump lines,
  [dumpaway2.txt](evidence/dumpaway2.txt)), [callfold.py](drivers/callfold.py) (keep / fold per continuous assignment,
  the judge of the kept-call laws), and downstream ([dscase.py](drivers/dscase.py): the harness's own `one()`, states
  ALLOFF / OWN / ON / FIX, [cases_all_states.txt](evidence/downstream/cases_all_states.txt)).
- Totals, both views (164 judgeable case-views; DF/e04b has no golden: the pinned Surelog stops in "Creating UHDM
  Model" on `r = b + 0; r = r - b + a;`): STRICT_EQUAL 8 (ALLOFF) -> 30 (ON) -> 33 (FIX); judge-equal 48 -> 51 -> 52;
  crashes 4 (ALLOFF: MG g02 g06 g07 g08 `--elabuhdm`, rc 139) -> 0 -> 0.

Per law, both views, ON against the law's own switch ([lawsum.txt](evidence/lawsum.txt); cmp = uhdm-cmp head lines,
records = chain-keyed strict records, ds = downstream OWN -> ON):

| law | cases | reading | verdict |
|---|---|---|---|
| § formalDefaultNamedThroughFormal191 | V191 fd1 fd2, X x4 | TOWARD 4, STAGE1-CLOSER 2; fd2 and x4 STRICT_EQUAL | holds |
| § queueRetTwinDynShape191 | V191 qr1 (package functions: unfired), qr2, qr3 | STAGE1-CLOSER 4; **qr3: 8 records away** (the enum element) | **B6** (fixed) |
| § evalFuncCastMemberKeepsCall191 | V191 cc1-cc7, X x1 (hd1 hd2 by the landing) | TOWARD 1, STAGE1-CLOSER 7, **STAGE1-AWAY 8 cells (cc3-cc7)**; ds cc4 IDENTICAL -> DIVERGENT | **B1** (fixed) |
| § elabCaConstLhsSized191 | V191 uz1 uz2, X x2 | STAGE1-CLOSER 2 (uz1: cmp 60 -> 11; ds EQUIVALENT -> IDENTICAL); unfired on uz2 (part-select, signed and concatenation targets) and x2 (generate scope) | holds; the unreached shapes are residue N6 |
| § enumDefOwnerNotInstance191 | V191 ep1 ep2 | BYTES-ONLY (vpiParent); ep1 STRICT_EQUAL on both | holds |
| § modAggClonePerDefKey191 | V191 hd1 hd2 | STAGE1-CLOSER (hd1 dump distance 80 -> 32) | holds |
| § splitPortRealRedeclLogicTs191 | V191 rp1 rp2 | STAGE1-CLOSER 4; ds rp1 EQUIVALENT -> IDENTICAL (rp2 DIVERGENT in every state: residue N7) | holds |
| § modGenericClassListed196 | MG g01-g09, X x6 | STAGE1-CLOSER 18 (cmp 279 -> 18 on g01, 466 -> 18 on g03, 363 -> 0 on g07); `--elabuhdm` rc 139 -> 0 on g02 g06 g07 g08; ds STATUS_DIFF (plugin CRASH) -> IDENTICAL on g02 g06 g07 g08 | holds |
| § modGenericHandleBare196 | MG g01-g07, X x6 | STAGE1-CLOSER 6; **g06 (interface home): 12 records away**; the crash rescues above | **B4** (not refined: section 4) |
| § modClassTsLinksDefListing196 | MG g08 g09 | STAGE1-CLOSER 4 | holds |
| § classPropElemClassTsAtName196 | EN n01-n04, X x6 | TOWARD 2 (n04 STRICT_EQUAL), STAGE1-CLOSER 8 | holds |
| § retPkgQualTdNoAlias196 | FR r01-r04 | STAGE1-CLOSER 6, unfired 2 | holds |
| § tpArrBoundAtLeftOperand196 | TB b01-b04, X x5 | TOWARD 6 (b01 STRICT_EQUAL), STAGE1-CLOSER 2; unfired on x5 (a type-parameter array in a generate scope: residue N8) | holds |
| § evalFuncOmittedDefaultKeepsCall196 | DF e01-e08, X x1 | TOWARD 1, STAGE1-CLOSER 9, **STAGE1-AWAY 2 (e06, e08: named / empty-slot omissions)** | **B3** (not refined) |
| § tfFormalTdCloneFile196 | SF f01-f04, X x3 | TOWARD 8 (f02 f03 x3 STRICT_EQUAL), STAGE1-SAME 2 | holds |
| § dfltArgExecutedRead196v | DF e01 e02 e04 e05 e07 e08 | **AWAY 1 + STAGE1-AWAY 4 (e01, e02, e07, both views)**, STAGE1-CLOSER 4 (e04, e05) | **B2** (fixed) |
| § dfltArgExecutedPathEval196v | DF e01 e02 e05 e07 | STAGE1-CLOSER 4, unfired 4 (it cannot restore what the X read hides) | B2's other half |
| § genCaUnclonedFoldOwner198 | O o1-o4, X x2 | STAGE1-CLOSER 6; o3 (the bind-model controls: module-body, ancestor and child targets) unfired | holds |
| § callArgVarSelStamp198 | V v1-v4, X x1 | TOWARD 3 (v4, x1 STRICT_EQUAL), STAGE1-CLOSER 4 | holds |
| § vsStampReducedCtxOnly198v | V v1-v4 | TOWARD 2, STAGE1-CLOSER 4 (dumpaway2's 2 / 4 lost lines on v2 are multiset coincidences: the stamps golden and the refinement leave off, checked per select) | holds |
| § genHopFoldSelName198 | N h1-h4, X x5 | STAGE1-CLOSER 4, STAGE1-SAME 2, MIXED 2 (h3: the cast operand, v11u198's residue 4); **h2 4 and h4 12 + 4 records away** | **B5** (fixed) |
| § ovrParamBoundOpSelName198 | N w1 w2 | TOWARD 2 (w2 STRICT_EQUAL), BYTES-ONLY 2 | holds |
| § methodArgOpRefChainName198 | M m1-m3, X x4 | TOWARD 5, STAGE1-CLOSER 3; m2 keeps v11u198's residue faces (`q.size() + i`, `i + j[0]`) | holds |
| § lvIdxCallArgIsRead198 | L l1-l3, X x3 | TOWARD 6 (l1 l2 x3 STRICT_EQUAL), STAGE1-CLOSER 2 | holds |
| § genCaCastRhsRefUnnamed198 | K k1-k3, N h3 | TOWARD 2, STAGE1-CLOSER 1, unfired 3 (`--elabuhdm`: the law is parse-form only) | holds |

The four `MG/g0?_el` rows [lawsum.txt](evidence/lawsum.txt) prints first are the grid's CRASH lines of the OFF states
(pristine rc 139), not ON cells.

## 4. The breaks, record by record, and the fix

**B1** ([callfold_fix_member.txt](evidence/callfold_fix_member.txt)). Golden (elaborated continuous assignments):

    cc3  h1(8'h21) FOLD 0010   h2(8'd33) FOLD 0001   h1(L) KEEP   h2(P) KEEP          (L, P module localparams)
    cc4  {4'd1,4'd2} FOLD  8'h20+8'h1 FOLD  8'(33) FOLD  '1 FOLD  I KEEP  pk::Q FOLD  id(8'h21) KEEP
    cc5  L+8'h0 KEEP   Q FOLD   PP KEEP   {L[7:4],4'd1} KEEP   Q+8'h1 FOLD              (Q imported package vector)
    cc6  union formal u.w KEEP, u.s.b KEEP; struct formal t.in.a FOLD, t.c FOLD      (all 8'h96 / 4'h6 literals)
    cc7  pk::PS KEEP  PS KEEP (package STRUCT parameters)   PI FOLD  PE FOLD (package int / enum parameters)

The decoded rule: the member branch keeps a call whose struct formal's actual reads a parameter of a design element
(module, interface, program), a package parameter of a struct / union (or other aggregate) type, or a user call; an
actual of literals, operations and casts of them, or package parameters of a non-aggregate type folds; a UNION formal
keeps. § memberFormalLitActualFolds204v (ModuleEmit.cpp, `r191ConstCallPoison`) withdraws the member-branch firing for a
struct formal whose actual is of the folding kind. With it every call of cc3-cc7 and hd2 matches golden's keep / fold;
r11u191dec's C grid, const_cast_signext and r11u190verify G/g02 (`pf(PP)`, STRICT_EQUAL) are untouched.

**B2** (DF e01, e02, e07). UHDM `ExprEval::evalStmt` (Surelog's UHDM, templates/ExprEval.cpp): an `if` / `case` /
loop / `repeat` condition goes through `get_value`, which sets `invalidValue` on anything but a constant; an unset
formal (evalFunc binds only the call's own arguments) or a local declared without an initializer is not a constant; a
`case` visits only items with expressions (the default item never runs); a statement kind without a row sets
`invalidValue`. § dfltArgTaintExec204v (ModuleEmit.cpp, `r204TaintExec`) runs the body that way, with slang's
EvalContext evaluating only the untainted expressions: a tainted condition or a tainted return keeps, a clean return
folds, a body that ends with the result unset keeps. It is consulted only where the delivered law fires (some read of
an omitted formal), so it only decides between the delivered law and the v11u196 refinements. e07's four calls and
e02's `for` bound: kept (golden); e02's `while` that breaks first: folded (golden); e01 f(1) (the taken default item):
kept (golden); v11u196's x01-x06 read unchanged.

**B5** (N h2, h4): fold under `-L` and `~L` keeps `work@top.g[0]` (golden); under `-(L+1)` (binary inside the unary) and
`L*2+1` the select name (golden). § hopFoldUnaryKeepsScope204v (ExprEmit.cpp, the § genLpIdxOpOperandFold112 site):
the hop rename declines when the fold's parent is a unary operation (`vpiMinusOp` .. `vpiUnaryXNorOp`).

**B6** (V191 qr3): the clone-form element is carried onto the dynamic-shape twin
(§ queueTwinKeepsElem204v, TaskFuncEmit.cpp), except a struct / union element (the clone form's struct element does
not match golden's) and a class type-parameter element (golden has none: qr2, uvm_misc.svh 642's `types_t`).

**B3 / B4, not refined.** B3: [cases_all_states.txt](evidence/downstream/cases_all_states.txt) with fix2 read e06 and e08
DIVERGENT (the fold value 3 against golden's 1); the kept call is IDENTICAL. B4: g06 with the law off is STATUS_DIFF
(the plugin's `propagateParamAssign` on a param_assign without Lhs), with it on IDENTICAL.

**The fix's boundary** ([fixbound.txt](evidence/fixbound.txt), [drivers/fixbound.sh](drivers/fixbound.sh); every case
dir of this directory and of r11u191dec, r11u196repro, v11u196repro, r11u198repro, v11u198repro, r11u199verify,
r11u195repro, v11u195repro, r11u193repro, v11u193repro, r11u192repro, v11u192repro, r11u194verify, r11u190verify,
r11u188repro, both views: 2720 case-modes; 26 move (r11u196repro V191/qr01 and, of this directory, DF e01 e02 e07, N h2 h4, V191 cc3-cc7
hd2 qr3), each restored to law.bin's bytes by exactly one switch (CCLIT 12, DFLTTAINT 6, HOPUNARY 4, QTWINELEM 4) and
all 2720 by `R11V204_OFF`; 0 case-modes that no single switch explains.

**The fix judged** ([fixjudge.txt](evidence/fixjudge.txt), [drivers/fixjudge2.py](drivers/fixjudge2.py), law.bin vs
fix.bin against golden): TOWARD 14 (qr01, e01, e02, e07, h2, h4, hd2, qr3), BYTES-ONLY 10 (cc3, cc4, cc6, cc7, hd2 `--elabuhdm`, h2
`--elabuhdm`: the kept call's subtree, 4 to 50 records golden lacks, is replaced by the fold, whose constant is 1 to 5
records off golden's value encoding: N10), AWAY 2 (cc5, both views). cc5's "away" records are a chain-key collision
([cc5_chainkey_collision.txt](evidence/fix/cc5_chainkey_collision.txt)): the chain key carries no positions, so law's
formal-typespec stamp on the call golden folds (11:17 `h(Q + 8'h1)`) matched golden's stamp on another call (10:17
`h({L[7:4], 4'd1})`, which no binary writes: N4); the fix folds 11:17 like golden. Per call
([callfold_fix_member.txt](evidence/callfold_fix_member.txt) and the DF cases' callfold lines in section 3's judge): the
fix agrees with golden on all 14 member-branch calls and the 6 omitted-default calls the law got wrong, and disagrees on
none the law got right.

## 5. Composition ([compose_H_A_6_8.txt](evidence/compose_H_A_6_8.txt), [bytecancel_H_A_6_8.txt](evidence/bytecancel_H_A_6_8.txt))

### 5.1 The two landings

| stage | conversions A -> H | owner | changes A -> H | CANCEL |
|---|---|---|---|---|
| probe | 39 | OWN196 2 (gv29_b_positions, g13), OWN198 37 | OWN196 1 (c12_const_fold `file(5) -> file(4)`), OWN198 2 (g5_hop95 `fullname(7) -> (2)`, g18_hop_lhs `(5) -> (1)`) | 0 |
| surelog | 0 | - | OWN196 9 (BuildUVMPkg d/t `fullname(20) -> line(11)`, MiniAmiq d/t `file(25) -> file(17)`, SeqDriver d/t `file(24) -> fullname(16)`, SimpleUVM d/t and Scoreboard d `fullname(52) -> (44)`) | 0 |
| uhdm2rtlil | 6 | OWN196 4 (const_cast_signext d/t, func_typename_ret d/t), OWN198 2 (ibex_pmp d/t) | JOINT 2 (arb_idx_cast d/t `endcol(17) -> endline(2)`: 198 `-> endcol(3)`, 196 `-> endline(2)`) | 0 |

- **Each landing converts exactly its claimed set**: the OWN196 probe set equals the conversions `cffb131f -> c029f423`
  commits, the OWN198 set the 37 `a015c911 -> cffb131f` commits (checked name by name).
- **Byte level** (6647 databases): SAME 6277, OWN196 314 (probe 204, corpus 110), OWN198 41 (probe 40, Rggen d), BOTH 15
  (the UVM rows, Earlgrey_0_1 d/t, ibex_pmp d/t, arb_idx_cast d/t), **CANCEL 0**. Pass 196's 125 corpus movers
  (110 + 15) and 204 probe movers, and pass 198's 16 corpus (1 + 15) and 40 probe movers, are the counts both passes
  reported.
- **The switch states reproduce the committed history exactly**: swA = `a015c911`, sw6 = `cffb131f`, swH = `c029f423`,
  0/0/0 in all three stages.
- **UVM distances are additive** ([uvmdist_A_H.txt](evidence/uvm/uvmdist_A_H.txt), order-blind, both modes equal):

| row | both off | 198 only | 196 only | both | fall = 196 + 198 |
|---|---|---|---|---|---|
| MiniAmiq | 7089 | 7026 | 6949 | 6886 | 203 = 140 + 63 |
| SeqDriver | 5739 | 5665 | 5546 | 5472 | 267 = 193 + 74 |
| SimpleUVM | 2537 | 2487 | 2362 | 2312 | 225 = 175 + 50 |
| Scoreboard d | 1918 | 1880 | 1774 | 1736 | 182 = 144 + 38 |
| BuildUVMPkg | 1018 | 992 | 980 | 954 | 64 = 38 + 26 |

### 5.2 The brief's literal switch set (`R11U191_OFF` + both landings, swB)

swB against swA: probe `regressions=1` (r10fiot_repro/a9 EQUAL -> `type(1)`), surelog 11 changes (Earlgrey_0_1 d/t
`fullname(82) -> col(83)`, the UVM rows `+2`, Scr1SvTests d/t `endcol(29) -> type(1)`). These are pass 195's three
r11u191 laws, which `R11U191_OFF` also drops: switching landing 196 off that way would charge pass 195's work to it.

### 5.3 The wide base ([wide_vs_head.txt](evidence/wide_vs_head.txt))

With passes 193, 195 and the r11u199 refinements off (swO against swW) the landings convert the same rows but three, and
change the same rows plus three:
- probe gv29_b_positions: `fullname(3) -> fullname(1)`, not a conversion. It needs pass 193 too (`R11U193_OFF` alone
  keeps it `fullname`; `R11V193_OFF`, `R11U195_OFF`, `R11V195_OFF`, `R11V199_OFF` alone keep it STRICT_EQUAL):
  r11u199's `gv29_b_positions 3 -> 2` under pass 193, then pass 196's last record.
- ibex_pmp d/t: `file(5) -> file(4)`, not a conversion: pass 193 moved ibex_pmp `file(5) -> type(1)` (r11u199's
  census), pass 198 converted it.
- The UVM surelog changes keep their rows and deltas (`file(27) -> file(19)`, `fullname(54) -> (46)`, SeqDriver
  `file(26) -> endcol(18)`): the same eight records per row.
A dependency on an earlier pass, not a cancellation: no row reads the same with both landings on and off while a
single landing moves it (CANCEL 0 above).

### 5.4 Cross-ground pairs (group X, each pair off together; [grid_default.txt](evidence/grid_default.txt), [grid_elab.txt](evidence/grid_elab.txt))

| case | pair | reading |
|---|---|---|
| X/x1 | § callArgVarSelStamp198 × § evalFuncOmittedDefaultKeepsCall196 × § evalFuncCastMemberKeepsCall191 (`f(p[1][2])` omitting a read default, `g(p[0][1])` casting to a typedef, and the same calls on literals) | all three fire; TOWARD alone and in every pair; STRICT_EQUAL on (317 objects), `type` in every off state; ds DIVERGENT -> IDENTICAL |
| X/x2 | § genCaUnclonedFoldOwner198 × § elabCaConstLhsSized191 (an unsized package parameter as a generate assignment's whole right side, in a concatenation and under `~`) | neither fires: the owner law declines on an unsized constant (the re-clone fence) and the sizing law is not reached in a generate scope; stage 1 on every state (residue N6) |
| X/x3 | § lvIdxCallArgIsRead198 × § tfFormalTdCloneFile196 (`arr[fx(s.f[k])] <= ...`, `fx`'s formal a header typedef) | TOWARD alone and together; STRICT_EQUAL on (207 objects) |
| X/x4 | § methodArgOpRefChainName198 × § formalDefaultNamedThroughFormal191 (`c.f(i + n)` in a method whose default `i = n * 2` names a formal) | TOWARD alone and together; STRICT_EQUAL on (63 objects) |
| X/x5 | § genHopFoldSelName198 × § tpArrBoundAtLeftOperand196 (type-parameter arrays bounded by the hop localparam in a nested generate scope) | the bound law does not fire (golden folds these ranges on a `logic_var`, ours writes no such range: residue N8); the hop law STAGE1-CLOSER |
| X/x6 | § modGenericClassListed196 × § classPropElemClassTsAtName196 (queue, fixed and associative arrays of a module-local generic as module-class properties and module variables) | both fire; STAGE1-CLOSER alone and together (cmp 850 -> 64) |

## 6. The CHANGE lines and the away-moved-record census

**CHANGE lines** ([unmask_198_swA_to_sw6.txt](evidence/changes/unmask_198_swA_to_sw6.txt),
[unmask_196_sw6_to_swH.txt](evidence/changes/unmask_196_sw6_to_swH.txt), [drivers/unmask.py](drivers/unmask.py)):
- pass 198's integration (swA -> sw6 = `a015c911 -> cffb131f`): probe CONVERSION 37, SUBSET 2 (g5_hop95 7 -> 2 records,
  g18_hop_lhs 5 -> 1); uhdm2rtlil CONVERSION 2, SUBSET 2 (arb_idx_cast d/t 17 -> 3).
- pass 196's integration (sw6 -> swH = `cffb131f -> c029f423`): probe CONVERSION 2, SUBSET 1 (c12_const_fold 5 -> 4);
  surelog SUBSET 9 (BuildUVMPkg d/t 20 -> 11, MiniAmiq d/t 25 -> 17, Scoreboard d 52 -> 44, SeqDriver d/t 24 -> 16,
  SimpleUVM d/t 52 -> 44: every record of the new cell was among the old, the walk diverged in both); uhdm2rtlil
  CONVERSION 4, SUBSET 2 (arb_idx_cast d/t 3 -> 2).
- **No NEW, no WORSE**: every CHANGE line of both integrations is a strict subset of the off records, i.e. a strict
  improvement (the first field moves because records ahead of it cleared, not because new ones appear).

**Map 12's away census** ([drivers/awayrows.py](drivers/awayrows.py): every probe and non-fenced corpus database whose
bytes move, walked by uhdm-strictcmp against itself for golden, the landing-off state and HEAD; a record golden and the
off state share that HEAD lost is a field moved away):
- landing 196 (sw6 -> swH, [away_196_sw6_vs_swH.txt](evidence/away_196_sw6_vs_swH.txt)): 329 databases move; **0
  chain-keyed and 0 flat records away**, 1346 / 1326 toward.
- landing 198 (sw8 -> swH, [away_198_sw8_vs_swH.txt](evidence/away_198_sw8_vs_swH.txt)): 56 databases; **0 chain-keyed
  records away**, 4853 toward; the flat (depth-dropped, map 12's own key) count reads 2 on probe g5_hop95: two
  `ref_typespec` names (`work@toph95.u8`, `.u6`) the off state wrote at a place where golden writes them elsewhere; keyed
  by their chains they are not golden's (0 away).
- So no landed law moves a corpus or probe record away from golden; there is nothing to attribute or refine there. The
  away moves of section 4 live on fresh shapes the corpora do not hold.

## 7. Downstream ([evidence/downstream/](evidence/downstream))

- **The converted rows are byte-identical to golden's lane** in swH ([dsnet_H.txt](evidence/downstream/dsnet_H.txt)):
  const_cast_signext, func_typename_ret, ibex_pmp, arb_idx_cast: `_nohier.il`, `.il` and `_synth.v` SAME
  (`ibex_pmp,IDENTICAL,OK,OK,52,52`, `arb_idx_cast,IDENTICAL,OK,OK,11,11`,
  `const_cast_signext,IDENTICAL,NO_GATES,NO_GATES,0,0`, `func_typename_ret,IDENTICAL,NO_GATES,NO_GATES,0,0`).
- **The full gate**: swH and swF read 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0.
- **The landmark cases** (ALLOFF -> ON, [cases_all_states.txt](evidence/downstream/cases_all_states.txt)): r11u194's N1
  z01 STATUS_DIFF -> **IDENTICAL**, x01 STATUS_DIFF -> **EQUIVALENT**; pass 196's MG/ma01 and m09 STATUS_DIFF ->
  **IDENTICAL**, DF/d01 and d03 DIVERGENT -> **IDENTICAL**; the real split-port cases r11u190verify R/r01, r11u191dec
  R r01 r02 DIVERGENT and r03 EQUIVALENT -> **IDENTICAL** (r04, the control, IDENTICAL in every state). `--elabuhdm`
  rc 0 on every MG case of this directory where the off states read rc 139.
- **This directory's 83 cases**, states ALLOFF / OWN / ON / FIX: 55 IDENTICAL in all four states; 9 DIVERGENT in all (DF/e03, FR r01 r02, K/k2, SF/f04, V191 cc1 cc2 rp2, X/x5:
pre-existing value and structure faces, N2 N3 N7 N8) and 4 EQUIVALENT in all (MG/g04, O/o4, TB/b02, V191/uz2); DF/e04b
SURELOG_FAIL. The landings: DIVERGENT -> IDENTICAL on DF e05 e06 e08 and X/x1, STATUS_DIFF -> IDENTICAL on MG g02 g06 g07
(g08 already IDENTICAL with its named laws off: MODGENHANDLE carries it), EQUIVALENT -> IDENTICAL on V191 rp1 uz1 cc6;
**one case moves away: V191/cc4 IDENTICAL -> DIVERGENT (B1)**. The fix: DF e01 e07 DIVERGENT -> IDENTICAL (B2), V191/cc4
DIVERGENT -> IDENTICAL (B1), V191/cc6 IDENTICAL -> EQUIVALENT (N10: the fold's value encoding; the netlists are
equivalent, the law's kept call gave golden's text by coincidence).

## 8. Determinism ([det_runs.txt](evidence/determinism/det_runs.txt), [ob.txt](evidence/determinism/ob.txt), [drivers/det.sh](drivers/det.sh), [drivers/ob.sh](drivers/ob.sh))

| row-mode | law.bin concurrent runs | reading |
|---|---|---|
| Earlgrey_0_1 default / testflags | **1 hash in 6 of 6** each (`2a3a623104a7`, `52b21f1158b5`) | = swH's |
| MiniAmiq d / t | 1 hash (= swH) / 2 hashes | the t pair: 0 order-blind lines, 0 ordered dump lines (storage order only) |
| SeqDriver d / t | 1 hash, swH another / 1 hash | 0 order-blind, 0 ordered lines |
| SimpleUVM d / t | 1 / 1 (= swH) | - |
| Scoreboard d | 2 hashes, swH a third | 0 order-blind lines, **92 ordered lines**: the svunit_pkg `vpiTaskFunc` listing order (`svunit_base::get_name`, `report`, `get_results`, `svunit_testcase::wait_for_error` ...), the pre-existing reader-visible coin of RESUME §9 |
| BuildUVMPkg d / t | 2 / 2 | 0 order-blind, 0 ordered lines |

**The UVM value coin is CLOSED**: no draw differs by the 4-line `UINT` / `vpiDecompile` bound of `types_t` (the value
§ queueRetTwinDynShape191 fixed); every multi-hash draw is storage order only, except Scoreboard default's listing order,
which neither landing touches (it is present with both off: r11u199's and map 12's reading).

## 9. Residues

### Re-measured at the base ([cases_at_base.txt](evidence/residues/cases_at_base.txt), [uvm_first_records.txt](evidence/residues/uvm_first_records.txt))

| source | residue | at 1454b68c |
|---|---|---|
| pass 196, R1 | MiniAmiq #899 `uvm_severity` enum file | **stands** (the row's first record: uvm_globals.svh 271 vs uvm_object_globals.svh 242) |
| pass 196, R2 | the value-parameter class body (MG ma03, ma07, m12) | **stands** (18 / 64 / 64 cmp lines, both views) |
| pass 196, R3 | a package-qualified formal of a scalar typedef (FR/f02, SF/s05) | **stands** (`line`, `file`; f02 `--elabuhdm` 64 cmp lines) |
| v11u196, V1 | constCallFold's value for an overwritten local (DF/x05) | **stands** (17 cmp lines) |
| v11u196, V2 | the refinements' under-reach (a non-integral formal: DF/x04's family) | **stands** (36 cmp lines); § dfltArgTaintExec204v closes the condition half of the under-reach it names |
| v11u196, V3 | the array-bound law on a package-qualified leaf (TB/b02) | **stands** (`endcol`, both views) |
| pass 198, R1 | N4, a call argument's index through the outer lvalue path (L/l12) | **stands** (`fullname`, both views) |
| pass 198, R2 | the method-call nested path (M/m13) | **stands** (`fullname`) |
| pass 198, R3 | the cast law's limits (K/k19 `fullname`, k10 `fullname`) | **stand** (k19's `--elabuhdm` form STRICT_EQUAL, as reported) |
| v11u198, 1-3 | u08 / u10 (`fullname`), v01 / v13 (`fullname`), the pristine bit_select stamp t18 (`type`), t35 (stage 1) | **stand** |
| pass 196, R8 | the interface home (MG/m10) | **stands** (207 / 247 cmp lines); fresh MG/g06 adds B4's 12 records |

### New, found here (none is a break but B1-B6)

- **N1 (B3's complete refinement).** Named-argument and empty-slot omissions fold in golden with the missing formal
  read as `INT:0`; ours folds with the declared default (pristine) or keeps (the law). The refinement needs
  `constCallFold` to bind those formals to 0.
- **N2.** A nested kept call: golden keeps `g(f(1))` (the inner call's omitted default) and `h(1)` whose body calls
  `f(a)` omitting a default (DF/e03); ours folds both in every state.
- **N3.** `unsigned'(x)` in a constant function body is kept by golden (cc1 g5), folded by every binary; a member read
  of another call's struct result, `mk(x).a`, is kept by golden (cc2 h3), folded by every binary; an interface's own
  continuous assignment `chk(4'h1)` is folded by golden and kept by every binary (hd2).
- **N4.** A definition-listing concatenation argument `h({L[7:4], 4'd1})` carries golden's formal-typespec stamp, ours
  none (cc5).
- **N5.** A case whose only return sits in the DEFAULT item is kept by golden even without an omitted default (UHDM's
  `evalStmt` never runs a default item); ours folds (pristine).
- **N6.** § elabCaConstLhsSized191 does not reach a part-select, signed or concatenation target (uz2) or a generate
  scope (x2: golden keeps size `-1` and no typespec on the unsized constant, `~U` folds to 8 bits).
- **N7.** Split real ports of a parameterized module instantiated twice (rp2) stay DIVERGENT downstream in every state.
- **N8.** A type-parameter-typed array declared in a generate scope (x5): golden writes a `logic_var` with folded
  ranges spanning the left operand, ours no range objects there.
- **N9.** The union-formal keep (cc6 h1, h2) and the struct-element queue twin (qr3 pq_t / uq_t: the clone form's
  struct element differs from golden's) are left to the pristine rules.
- **N10.** A fresh fold now IDENTICAL -> EQUIVALENT downstream: cc6 under the fix (the struct formal's folded value is
  written `UINT` where golden writes a sized `BIN`: the value family, `srlgRedIntSyn`), where the law's kept call gave
  golden's netlist text by coincidence; netlists equivalent.

## 10. The fence and the process ([evidence/process/](evidence/process))

**No law, case or number here rests on a fenced reading.** Every case is this directory's or a named evidence case;
every corpus reading goes through a fail-closed driver or a gate sweep.

**The laws nearest the fenced tests' shapes (parameter substitution and folding), re-derived from this directory's
cases and Surelog's source only:**
- § genCaUnclonedFoldOwner198: CompileExpression's getValue substitutes a parameter by a clone of the param_assign's Rhs
  with `VpiParent(param_ass)`; the binary, ternary and cast branches re-parent operands, the concatenation, replication,
  unary and system-call branches do not; writeCont_assign re-clones an assignment to a found whole name under an
  operation root. Cases O o1-o4 (fires on the nested mix, the explicit import and qualified name, the case-generate in
  a child instance; o3's three whole-target controls unfired), X x2 (the unsized fence).
- § genHopFoldSelName198: the same getValue parent, and the unary branch's missing re-parent (B5): cases N h1-h4.
- § elabCaConstLhsSized191: uz1 (4 widths) and the unreached uz2 / x2 shapes.

**Drivers of the four evidence directories** ([fencecheck.txt](evidence/process/fencecheck.txt), static reading plus a
runtime source of each env.sh):
- The four env.sh resolve the repository from their own path and read the `FENCED=` line of
  `tools/probe/r11u107repro/canaudit.sh`, never RESUME.md: sourced from the checkout rc 0 with 4 names; from a scratch
  copy beside a two-name canaudit.sh rc 1 (r11u196repro, r11u198repro, v11u198repro) or rc 3 (v11u196repro), i.e. fail
  closed. A word scan finds 0 files naming a fenced test in any of the four directories or this one; the positive
  control finds a planted name. r11u196repro's env.sh also requires `R196_BIN`.
- **Readers of corpus sources or databases, all fenced**: r11u196repro census.sh (`--filter "$NEGFENCE"`), predict.sh
  and bvmirror.sh (`fenced_skipped=8`), row.sh, rowrun.sh, rowdist.sh, attrib.sh, det.sh, ob.sh, offcheck.sh (probe
  paths), switches.sh, compose.sh (`r196_fenced`), moverdist.sh (through rowdist.sh), uvmdist.sh (refuses without
  `$FENCED`), dscase.py, probeheads.py and probesub.py (read canaudit.sh themselves); v11u196repro mirror.sh, rowdist.sh,
  det.sh, uvmdist.sh, case.sh, ds.py; r11u198repro census.sh and case.sh (read canaudit.sh themselves), bvmirror.sh,
  rowhead.sh, obrow.sh, det.sh, detob.sh, uvmdist.sh; v11u198repro census.sh, bvmirror.sh, bytes.sh, det.sh, detob.sh,
  obrow.sh, uvmdist.sh, ds.sh, case.sh, switchcheck.sh.
- **No fence check of their own, and none needed** (own cases, given traces or dumps, builds, gate sweeps):
  r11u196repro cc.sh, censum.py, composeana.py, grid.sh, predcheck.py, predict.cpp, sweep.sh; v11u196repro detana.sh,
  obd.sh, switches.sh, sweep.sh; r11u198repro censum.py, foldnames.py, grid.sh, judge.sh, mkgrid*.py, obdist.sh,
  switchcheck.sh; v11u198repro censum.py, judge.sh, obdist.sh, show.sh. None names a fenced test.

**Predictions written before their sweeps, as far as the tree can show** ([prediction_check.txt](evidence/process/prediction_check.txt),
[census_at_head_vs_committed.txt](evidence/process/census_at_head_vs_committed.txt)):
- **Pass 196**: the measured movers at HEAD (swH against sw6: 204 probe + 125 corpus databases) are **all inside** the
  committed frozen census `r11u196repro/evidence/predict_census_before_sweep.txt` (0 outside); 42 predicted databases do
  not move (the pass's own "14 corpus rows fire without moving" plus 28 probe). A re-run of the census at HEAD
  ([drivers/lawcensus.sh](drivers/lawcensus.sh), `R11U196_TRACE` + `R11U191_TRACE`) reproduces its 371 databases with
  identical law counts; it adds 41 downstream-lane databases pass 196's census did not cover.
- **Pass 198**: the measured movers (40 probe + 16 corpus) are all inside `r11u198repro/evidence/census/predicted_movers.txt`;
  the 5 predicted-not-moved are the ones it names (r11u46repro/grid2, v11u116 g2_fcall, g2_sys, mem2reg_test4 d/t). The
  census re-run reproduces all 64 rows with identical law counts.
- The censuses are functions of the law binary and the sources, so these checks prove content, not time. The timestamps
  v11u196 quoted (census `chmod 444` at 01:54:01, sweep workdir 01:54:08) cannot be re-read: both passes' `/tmp`
  censuses and workdirs are pruned (only `/tmp/r11u196.patch` 02:47:15, `/tmp/r11u198.patch` 03:44:26 and the
  `.verified.patch` files remain).
- **The cases' first lines** ([case_first_lines.txt](evidence/process/case_first_lines.txt)): every case of the four
  directories (53, 34, 170, 115) carries a `// § law` first line naming a law of its pass.

**The stray empty file (04:57, repo root, 255-byte binary name).** No driver of the four directories writes to its
current directory: every redirect, `-o` and `open(..., 'w')` target is an absolute path or an argument (a static scan of
all `>` / `>>` / `-o` / `--dump-*` / `tee` / `open` targets). By the surviving timestamps both verifiers had finished
before 04:57 (`/tmp/r11u198.verified.patch` 04:42:59, `/tmp/r11u196.verified.patch` 04:52:33, their reports 04:55:32);
at 04:57 the main tree was building pass 198's integration unit by unit (`/tmp/intr11u198_build_tf.log` 04:56:28,
`_build_param.log` 04:57:36, `_build_stmt.log` 04:58:37, `_link.log` 04:58:39). The file is gone (the root directory's
mtime is 05:08:54), so the writer cannot be read back; the evidence points at the integration step, not at a driver of
these directories.

**Operations of this pass, disclosed:**
- Eight fix builds ran in this worktree's `src/`, each frozen under `/tmp/r11u204_bin` before use; the sources are
  reverted (`git checkout src`, `src/R204.h` removed) after the last. The deliverable carries no `src/` edit.
- Three firing censuses of superseded fix binaries were stopped part-way (fix2, fix3, fix4) and one fix-boundary run
  (its parts file was deleted under it); each process was checked by its command line before it was stopped. While
  stopping the fix4 census a `pgrep -f` pattern matched this pass's own launcher shell, which was stopped with it; every
  process it touched was this pass's own (two orphaned Surelog golden runs of that census were stopped by pid after a
  command-line check).
- A complete fix sweep on fix5 (08:05, with its own frozen prediction naming the seven UVM row-modes fix5's
  QTWINELEM fired on) was superseded when the boundary found fix5's type-parameter element; its prediction file was
  replaced by fix8's.
- The live pairs' worktrees (`/tmp/wt_r11u201*`, `/tmp/wt_*r11u202*`, `/tmp/wt_v11u20*`) were not touched; nothing here
  reads the main tree's binary.
- Resources: at most three sweeps / censuses concurrently at `--jobs 3`; builds at `-j 2` with 6 GB or more available;
  no OOM.

## 11. Files

- [fix.patch](fix.patch): § memberFormalLitActualFolds204v, § dfltArgTaintExec204v, § hopFoldUnaryKeepsScope204v,
  § queueTwinKeepsElem204v (`git diff 1454b68c -- src`, with `src/R204.h`).
- `cases/{DF,EN,FR,K,L,M,MG,N,O,SF,TB,V,V191,X}/`: 83 cases (SF f01 has `args` = `defs.sv dut.sv`; SF f02-f04,
  V191 hd1 hd2, X x3 include headers).
- `drivers/`: environment and states: env.sh, laws.py, mkstate.sh; sweeps: sweep.sh, queue.sh; cases: case.sh,
  grid.py, gridall.sh, lawsum.py, lawtable.py, fieldscore.py, recaway2.py, dumpaway2.py, callfold.py, carhs.py;
  composition and changes: compose.py, bytecancel.py, unmask.py, unmaskpos.py, awayrows.py, predcheck.py;
  downstream: dscase.py, dsnet.sh; determinism and UVM: det.sh, ob.sh, obpair.sh, uvmdist.sh; byte mirrors:
  bvmirror.sh; fix: census.sh, censum.py, lawcensus.sh, fixbound.sh, fixjudge.py, fixjudge2.py; process: fencecheck.sh.
  Drivers copied from r11u199verify say so in their second line.
- `evidence/`: `binaries.txt`, `grid_default.txt`, `grid_elab.txt`, `recaway2.txt`, `dumpaway2.txt`, `lawsum.txt`,
  `callfold_fix_member.txt`, `compose_H_A_6_8.txt`, `bytecancel_H_A_6_8.txt`, `states_vs_history.txt`,
  `wide_vs_head.txt`, `away_*.txt`, `prediction_fix.txt`, `fixbound.txt`, `fixjudge.txt`, `changes/`, `determinism/`,
  `downstream/`, `fix/`, `process/`, `residues/`, `sweeps/`, `uvm/`.
