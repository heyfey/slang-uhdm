# r11vu15 — adversarial verification of r11u15 (VERDICT: ACCEPT)

Base `401ed722`. Verifier worktrees `/tmp/wt_v11u15` (law) and
`/tmp/wt_v11u15pris` (pristine), both fresh at the base. Everything here is
measurement-only; the judge is the official `uhdm-cmp` through
`scripts/verify_golden.py`. `results/*.csv` NOT edited.

## What was reproduced bit-for-bit, from my own builds

| claim | verifier measurement |
|---|---|
| pristine md5 | `aa22f942076295f56fd20551df1ee939` = the main tree at `401ed722` |
| law md5 | `71f3672cb6c14f8eefa74b9958b77210` — identical to the implementer's |
| u2r pristine | 757 / 47 / 67 both modes |
| u2r law | **759 / 45 / 67 both modes** |
| surelog pristine | 468/15 default, 464/13 testflags |
| surelog law | 468/15 + 464/13, status diff pristine-vs-law **0 rows**, dump-column diff **0 rows** |
| u2r byte movers | **8 / 1608**, SELFCHECK 1607/1608 |
| surelog byte movers | **8 / 960**, SELFCHECK 959/960 (coin membership differs per run) |

`uhdm-cmp` run directly on the golden the sweep itself used:
`ibex_wb_stage` and `latch_tlb_napot` are **rc 0 in both modes** under the law
and rc 255 / 1 head under pristine.

## The 24-arm INDEPENDENT grid (this directory)

`run.sh <binary> <tag> [arms]`, `GRID=` selects the arm root. Golden is
`surelog -parse -nobuiltin -nocache -sv dut.sv` from the pinned v1.87 tree;
ours is `<binary> dut.sv --single-unit --nobuiltin`. **Every arm records BOTH
return codes and every arm is `golden_rc=0 ours_rc=0`** — no arm is testing
error recovery. Verdicts are read off `refcen.py` (the implementer's census),
never off the cmp rc, because a masked cell reads rc 0 while still being wrong.

**0 regressions. 10 further conversions the implementer's grid did not reach.**

LAW B (part-select owns the name):

| arm | shape | pristine | law |
|---|---|---|---|
| `v03` | whole ref in a DEEPER nested block than the select | 2 wrong cells | **0** |
| `v07` | non-ANSI `output reg`, select in `always @(posedge)`, also read at module level | 1 | **0** |
| `v08` | select + whole write in one process, second process reads the name | 2 | **0** |
| `v20` | TWO nets, each whole-written and selected in one block | 4 | **0** |
| `v21` | module with an `inout wire` present; net whole-written + selected | 2 | **0** |
| `v23` | the block is an `initial`, not `always_comb` | 2 | **0** |
| `v01` | select inside a for-loop body block, whole refs outside | 0 | 0 (net, correct) |
| `v09` | select in a bare `for` with no `begin`/`end` | 0 | 0 (net, correct) |
| `v02` | select and whole write in DIFFERENT processes | 0 | 0 |
| `v05` | the select is on a STRUCT MEMBER (`p.lo[3:0]`) | 0 | 0 |
| `v06` | the select's left bound is a PARAMETER expression | 0 | 0 |
| `v22` | the select is on an unpacked ARRAY ELEMENT (`p[0][3:0]`) | 0 | 0 |
| `v04` | subroutine local, no named block — golden keeps `logic_var` | 0 | 0 (fence holds) |
| `v30` | subroutine local in a NAMED block — golden REPOINTS | 0 | 0 |
| `v31` | task local in a named block — golden REPOINTS | 0 | 0 |

LAW A (a generate scope's cont-assign reads the module symbolically):

| arm | shape | pristine | law |
|---|---|---|---|
| `v14` | GEN-CASE block drives a module var and reads it bare | bound | **UNBOUND, arm converts** |
| `v15` | the gen-local is an IMPLICIT net (undeclared) | 1 wrong cell | **0** |
| `v19` | the module var is driven by a PROCESS in the gen block | 1 | **0** |
| `v11` | the Rhs reads the module var through a BIT-SELECT | 0 | 0 (binds, correct) |
| `v17` | the r5p_gpr witness shape: gen-local array driven + read in-block | 0 | 0 (stays BOUND) |
| `v18` | gen-FOR with a gen-local driven and read in-block | 0 | 0 (stays BOUND) |
| `v26` | gen-FOR > gen-IF, gen-local driven and read, module var also driven | 0 | 0 |
| `v12` | module var driven in-block AND a module PARAMETER in one Rhs | 1 | 1 (R-V1) |
| `v13` | the same shape inside an INTERFACE generate scope | 1 | 1 (R-V2) |

## Boundary over a LANDED pass's own arm

`tools/probe/r10buvm5repro/v2_seltrack.sv` (the `V-FIX vbuvm5` seltrack arm,
cells s01–s05) compiles `golden_rc=0 ours_rc=0` on both binaries and its
database is **byte-identical** between them — the only dump line that differs
is the output filename. That pass's cells are untouched.

## A-priori prediction, run by the verifier on the verifier's own workdirs

`predict.py` over MY pristine u2r workdir names **20 of 1608 databases**
(10 rows × 2 modes) — the same ten rows the implementer names — and contains
all three LAW-A movers. `predict2.py` names **124 of 1608** (62 rows) and
contains `latch_tlb_napot`. On the surelog side, run on the PRISTINE databases
alone, `predict2.py` flags `Earlgrey_0_1` (356 candidate cells, including
`work@aes_key_expand.drive_regular.regular`) and `YosysOldSystem` (24).

**Positive control on arms the predictors had never seen:** `predict2.py`
fires on all six LAW-B movers (`v03 v07 v08 v20 v21 v23`) and is silent on the
four non-movers (`v01 v02 v04 v22`); `predict.py` fires on all three LAW-A
movers (`v14 v15 v19`) plus the two declared residues, and is silent on
`v11 v17 v18 v26`.

## Every mover attributed, AWAY-GOLDEN 0 / MOVED-WRONG 0

Whole-dump, path-normalised, id-stripped, order-blind diffs — nothing outside
the named cells moved in any database:

    ibex_alu            4 lines   1294:41 butterfly_result, 1296:41 invbutterfly_result -> <none>
    ibex_wb_stage       4 lines    213:50 perf_instr_ret_wb_o, 213:72 instr_is_compressed_id_i -> <none>
    ibex_multdiv_fast   2 lines    279:39 mac_res_signed -> <none>
    latch_tlb_napot     4 lines      57:9 / 59:28 patched_pte: logic_net -> part_select
    YosysOldSystem     20 lines   10 cells keysched col_t/W_var + mixcolum data_reg_var:
                                  logic_net -> part_select; refcen 10 differing keys -> 0
    Earlgrey_0_1        6 lines   3 cells aes_key_expand.regular: logic_net -> part_select

`refcen.py` set diffs REMOVE 7 u2r keys and ADD NONE. Earlgrey converges on
golden's own counts exactly: golden holds 7 `logic_net work@aes_key_expand.regular`
and 2 + 3 `part_select regular` at `202:9` / `227:9`; pristine held 10 and 1 + 1;
the law holds 7 and 2 + 3.

## The coin, proved from the verifier's own pristine binary

Thirteen runs of the PRISTINE binary alone on MiniAmiq's own command line
produced **thirteen different database hashes**; every pristine-vs-pristine
order-blind delta is the same 4-line shape (one constant drawing 0 / 1258 /
1276 / 903 / 846). MiniAmiq/default additionally shows 120 lines that are one
builtin buffer's rendered FILE PATH — and **the verifier's own PRISTINE sweep
drew both values**, `/home/heyfey/git-repos/Surelog/builtin.sv` in `default`
and `.../MiniAmiq/builtin.sv` in `testflags`, from the same binary and the same
command line. Nothing in the coin family is attributable to this pass.

## Gates re-run by the verifier

`check_goldens` 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL.
u2r canaries `ok=8 changed=0`, `EXPECT_UNKNOWN=6 ctcan2` PASS. Surelog
canaries `ok=52 changed=0`, `EXPECT_UNKNOWN=1 ctcan2` PASS (`ok=58`).
`rowheads.sh` over SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg /
Earlgrey_0_1 / Rggen is byte-identical on the two binaries (measured=12,
SKIP-NOFILE=2, UNKNOWN-NAME=0). `canaudit.sh` audited=29 UNCOVERED=0
FENCE-BREACH=0; an independent scan of the whole patch and both probe
directories finds each of the four fenced names 0 times. Protected databases,
md5 pristine vs law: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`,
InterfaceModPort `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a` /
`73a10e8217e5`, YosysOldOr `d68e0796d62c` — all SAME. All 1742 u2r and all
1531 surelog `cmds.txt` audited by binary PATH.

## Verifier residues

* **R-V1 — `v12`: a module PARAMETER in the Rhs re-opens the gate.**
  `assign loc = mv + P;` in a gen-if where `mv` is a module var driven in the
  block: golden leaves `mv` bare, we bind it on BOTH binaries, because the
  `SymbolKind::Parameter` opener fires for `P` and `hasBindableRef` is
  per-ASSIGNMENT. This is the same root as the implementer's R3 (`b15`/`b16`),
  one face wider: the co-referent need not be a gen-local.
* **R-V2 — `v13`: the INTERFACE analogue of LAW A is untouched.** The same
  shape inside an interface generate scope binds on both binaries where golden
  leaves it bare: the `uhdminterface_inst` branch downstream of the gate
  recomputes `allVarRefs` and clears `suppress`, so LAW A's narrowing never
  reaches it.
* **R-V3 — `ibex_multdiv_fast`'s head did NOT move.** Same object
  (`logic_var work@ibex_multdiv_fast.sign_a` @ `54:16`), same 15 cmp lines, same
  ids on both binaries. The row gained one byte-correction below the head
  (`279:39 mac_res_signed`). `ibex_alu`'s head DID move —
  `logic_var butterfly_result` (15 lines) to `array_net imd_val_d_o` (51 lines),
  a genuine advance with a changed head object, and it is the implementer's R0.
* **R-V4 — the surviving half of LAW B is conservative, not "vbuvm5's cell".**
  The patch keeps the whole-write carve-out for every non-`nets` actual, so for
  those references the emitted path is bit-identical to pristine — which is the
  correct engineering choice and is what makes the narrowing provably safe. But
  `v30`/`v31` show golden REPOINTING a subroutine local in a named block, and
  `v04` shows the no-named-block case being decided by `noteSelectObj`'s
  `isBlock` guard rather than by the carve-out. The carve-out may be dead for
  variables too; that is a cleanup question for a later pass, not a defect here.

## Verifier decode checks against the pinned sources

* Surelog v1.87 `0445655ee7`, `UhdmWriter::writeCont_assign` at
  `src/DesignCompile/UhdmWriter.cpp:2121-2123`: `bindVariable(mod, m,
  lhs->VpiName(), ...)` — the Lhs name only. The only `ref->Actual_group(var)`
  calls in that function are for the delay ref and the Lhs ref. No Rhs
  reference is ever rebound. LAW A's decode holds.
* `CompileHelper::bindVariable` searches `Variables()` and `Nets()` and never
  `Array_nets()`, which is exactly why golden leaves `ibex_alu`'s
  `imd_val_d_o` unbound. The implementer's R0 decode holds.
* `noteSelectObj` (`StmtEmit.cpp:454-466`) returns early unless the innermost
  sel-scope `isBlock`, so a case-item select registers nowhere and
  `multiple_blocking_gate` is decided by the scope rule, carve-out or not.
  Arms `v01`, `v09`, `a13`, `a21` reproduce it.
* `scope::Compare` (`UHDM/build/generated/src/scope.cpp:345-346`) walks
  `Parameters()` before `Param_assigns()`, consistent with
  `latch_tlb_napot`'s cast typespec being judge-invisible — and the row
  converts with that cell still in place, which is the proof.
