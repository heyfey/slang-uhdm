# r11u162: second adversarial verification of passes 154 and 155 (verifier, measurement plus one refinement patch)

Base `16607134` (branch matrix-1.87; its `src/` equals the pass-155 landing `75226e07`, and pass 154 landed at
`fc99b2d5` on `5a602076`). Worktree `/tmp/wt_r11u162`, system-deps config, `-j 2`. This directory is the whole
deliverable. Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited. The proposed
refinement is [fix.patch](fix.patch), a `git diff 16607134 -- src` that applies clean on 16607134 and is NOT applied
here. No canonicalisation patch for `tools/uhdm-strictcmp` was handed to this pass and no comparator defect was
found, so the comparator is not edited. The slang-fenced tests are named nowhere here. Every driver that reads
corpus sources or databases refuses to run without `$FENCED` (`drivers/env.sh` builds it from RESUME.md without
spelling it) and skips those names by word boundary.

**Verdict: NO BREAK.** No law of either landing moves a field away from golden on the fresh cases:

- 173 fresh cases, both modes.
- 0 AWAY cells, 0 uhdm-cmp regressions.
- 0 downstream verdict or netlist moves.

**Composition: additive.** No pair of laws cancels. Every conversion each landing claimed is its own. The one case
both landings move is additive record by record.

**Changes: all unmaskings or strict improvements.** All 108 CHANGE lines are subsets of the landings-off record
sets or the same objects re-rendered.

**One law defect found and refined.** § ifaceSigConnNamedByChildPort155 picks the wrong "last writer" in two
shapes. Both are wrong-to-wrong: pristine names the member wrong as well, so neither is a break by the brief's
definition. Refinements § ifaceSigConnSelectWrites162v and § ifaceSigConnLastByExpansion162v are in fix.patch. They
convert 4 fresh cases and one committed probe case (`r10rggen9repro/t8`), move nothing else in the corpora, the
probe set or 7403 tools/probe cases, and change no downstream verdict.

**Fence: held.** The census the pass-154 implementer ran over the fenced rows is reproduced line for line by its
verifier's fence-clean census. Six drivers, and the byteverify runs of all four passes, do not meet the fence rule
(section 9).

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u162_bin/law.bin` | `2aa918616ddb54c5502f85f387b3e4f7` | worktree build of 16607134 = the main tree's `build/slang-uhdm` (the brief's `2aa918616ddb`) |
| `/tmp/r11u162_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `/tmp/r11u162_bin/pre154.bin` | `6dc4aab88e16f6e83302720c74dd53ea` | build of `5a602076`, the commit before pass 154 landed (= r11u159's fix.bin md5) |
| `/tmp/r11u162_bin/q154.bin` | `9217dad597362de51df7424ea011231a` | build of `fc99b2d5` (pass 154 landed, pass 155 not) |
| `/tmp/r11u162_bin/fix.bin` | `a52c8ec19093858f0da7a4daae5bfbad` | 16607134 + fix.patch (worktree `/tmp/wt_r11u162F`) |
| `alloff.sh` / `off154.sh` / `off155.sh` | wrappers | law.bin with `R11U154_OFF R11V154_VIDMOD_OFF R11U155_OFF` / `R11U154_OFF R11V154_VIDMOD_OFF` / `R11U155_OFF` |

Two intermediate fix builds were superseded and never swept:

- `fix1.bin` (`8eb351c0…`) held the macro refinement only.
- `0e37eff7…` stripped the select in the AST. It moved nothing, because `sub.dat[1:0]` parses as `sub` . `dat[1:0]`,
  an IdentifierSelectName, so the syntax check still failed. The final build reads the selector off the name.

Every `cmds.txt` names its sweep's binary or wrapper: 3273 of 3273 `slang:` lines in each full sweep.

## 2. Gate sweeps

All sweeps are `tests/sweep.sh --jobs 3` with `GOLDEN_DEFER` unset. The logs are `evidence/sweep_*.log`.

| sweep | binary | probe EQUAL / SN, reg/conv/chg | surelog reg/conv/chg | uhdm2rtlil reg/conv/chg | downstream |
|---|---|---|---|---|---|
| L | law.bin (HEAD) | 2514 / 1573, 0/0/0 | 0/0/0 | 0/0/0 | 803 / 66 / 2, not excused 0 |
| A | alloff.sh | 2491 / 1596, 23/0/84 | 15/0/18 | 30/0/6 | 803 / 66 / 2 |
| X | off154.sh (155 alone) | 2499 / 1588, 15/0/18 | 5/0/15 | 20/0/4 | 803 / 66 / 2 |
| Y | off155.sh (154 alone) | 2506 / 1581, 8/0/67 | 10/0/5 * | 10/0/2 | 803 / 66 / 2 |
| P | pre154.bin (probe + corpora) | = A | = A | = A | - |
| Q | q154.bin (probe + corpora) | = Y | 10/0/3 | = Y | - |
| F | fix.bin | 2515 / 1572, 0/**1**/0 | 0/0/0 | 0/0/0 | 803 / 66 / 2 |

\* Y's two extra surelog changes are CoresSweRV and CoresSweRVMP default. There the Surelog producer timed out
under load (`TIMEOUT surelog timeout`; the baseline reads SURELOG_FAIL). A rerun with off155.sh reads SURELOG_FAIL
(`evidence/rerun_Y_CoresSweRV.csv`), and Q reads SURELOG_FAIL. This is the environment, not the binary.

**L reads the committed baselines exactly:**

- surelog 425 + 423 CMP_EQUAL and 55 + 51 STRICT_NOTEQUAL (848 + 106 of 954 judge-equal).
- uhdm2rtlil 751 + 751 and 52 + 52 (1502 + 104).
- probe 2514 / 1573.
- downstream csv equal to `results/downstream_uhdm2rtlil.csv`.

The only red in every sweep is `law index STALE`. It is environmental: the main tree at 16607134, clean, reads STALE
too. The downstream csvs of A, X, Y and F equal L's on every column.

**Switch completeness.** A (HEAD with both landings switched off) against P (the pre-154 build):

- The csvs are identical, apart from the LowMem log-path detail.
- Probe databases: 0 / 4087 movers. uhdm2rtlil: 0 / 1608.
- surelog: 5 / 952 movers (SELFCHECK 951/952), all the UVM coin: MiniAmiq d/t, SeqDriver d/t, SimpleUVM d, each 4
  order-blind `UINT`/`vpiDecompile` lines (`evidence/coin_A_vs_P.txt`).

Y (HEAD with 155 off) against Q (the fc99b2d5 build):

- The csvs are identical apart from the CoresSweRV timeout above.
- Probe 0 / 4087, uhdm2rtlil 0 / 1608.
- surelog 5 / 952, the coin only: Scoreboard d 0 order-blind lines, the others 4.

So `R11U154_OFF R11V154_VIDMOD_OFF R11U155_OFF` restores the pre-landing bytes, and `R11U155_OFF` restores pass 154's
landed bytes. On the fresh cases, ALLOFF gives pre154.bin's bytes on 173 of 173 cases in both modes
(`evidence/offbytes_alloff_vs_pre154.txt`).

The byte comparisons run on hard-link mirrors of the sweeps with the 8 fenced row-mode databases left out
(`drivers/bvmirror.sh`: 952 surelog paths).

**Canaries on L and F** (`evidence/canaries_{L,F}.txt`):

- `canaries.sh`: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0.
- `EXPECT_UNKNOWN=1 ctcan2.sh`: surelog ok=58 changed=0, PASS.
- `EXPECT_UNKNOWN=6 ctcan2.sh`: uhdm2rtlil ok=2 changed=0, PASS.

**Byte movers of the two landings, predicted first.** `evidence/prediction_L_vs_A.txt` was written before either
byteverify ran. It lists the landings' own mover lists plus the UVM coin family: 77 row-modes.

Measured L vs A: surelog 37 / 952 and uhdm2rtlil 40 / 1608 (SELFCHECK 951/952 and 1607/1608). That is **77
movers: exactly the predicted 77**, none unpredicted and none predicted-but-still. Probe: 107 / 4087 byte movers,
the 107 verdict movers exactly (23 conversions + 84 changes), with no byte-only probe mover.

## 3. Fresh cases per law

The cases are `cases/`: 173 cases in 27 groups, and each case's first line names its law or laws.
`drivers/grid.py` runs law.bin in these states:

- ON;
- each named law's own switch (a verifier refinement `…v` is also run under its parent law's switch, which is
  pristine);
- every pair of own switches, for the `cx/*` cases;
- ALLOFF.

Each state runs in the default probe mode and with `-elabuhdm` / `--elabuhdm`, against goldens from the pinned
Surelog with check_probe's arguments.

Scores per law, comparing ON with the own-switch-off state:

- **TOWARD:** the strict records OFF had, and none new.
- **AWAY / MIXED:** a strict record ON has that OFF had not.
- **STAGE1-x:** either state is stage 1, and the order-blind dump distance to golden decides.
- **BYTES-ONLY:** the bytes move but the record multiset does not.
- **UNFIRED:** the same bytes.

Downstream per case: `drivers/dscase.py` (the harness's `one()`) in the states ON, OWN and ALLOFF.

The full per-case tables per law are in `evidence/law_tables.md`. Grids are in `evidence/grid_default.txt` and
`grid_elabuhdm.txt`, downstream in `evidence/downstream_cases_{ON,OWN,ALLOFF}.txt`.

| law | cases (fired) | to STRICT_EQUAL | toward / stage-1 closer | away or mixed (adjudicated) | uhdm-cmp 0 -> >0 | downstream moved |
|---|---|---|---|---|---|---|
| § hpPartSelBoundNamesBySelect154 | 5 (5) | 2 | 2 / 2 | 0 (`hpb/b03` STAGE1-SAME: the bound `g` is named `…bus.wdt[H + g:g].wdt.g` where golden's path text has folded `H` to `2`; a pre-existing stage-1 fold face) | 0 | none |
| § hpElemSelNameIsPathSoFar154 | 10 (3) | 3 | 3 / 0 | 0 (the law fires only under a trailing select, `bus.req_dly[1].adr[3:0]`; bare element reads e01-e03 are equal or pre-existing stage 1) | 0 | none |
| § genScopeProcPsNamedByScope154 | 7 (3) | 3 | 3 / 0 | 0 | 0 | none |
| § genProcFoldTsKeepsScope154 | 7 (3) | 2 | 2 / 0 | 0 (`gft/f05` STAGE1-SAME: golden keeps `P` unfolded in an `initial` in a generate block; pre-existing) | 0 | none |
| § builtinMethodArgNamedByPath154 | 6 (3) | 3 | 3 / 0 | 0 | 0 | none |
| § varInitStrMethodArgDefNet154 | 8 (5) | 5 | 4 / 0 (+1 bytes-only: `vid/v05`, the net rebind, dump 2 -> 0) | 0 | 0 | none |
| § varInitDefNetModuleOnly154v | 3 (3) | 3 | 2 / 0 (+1 bytes-only: `vid/v03` program, dump 2 -> 0) | 0 | 0 | none |
| § elabCastSharesDeclRef154 | 8 (3) | 3 | 3 / 0 | 0 | 0 | none |
| § lvIdxPathIsRead154 | 5 (5) | 5 | 5 / 0 | 0 (macro-expanded index `m[\`ADR]` included) | 0 | none |
| § lvPathBaseAtFirstMember154 | 10 (10) | 7 | 7 / 2 | 0 (`lbm/l06` STAGE1-SAME: whitespace in the path, residue N1) | 0 | none |
| § lvPathSelNamedByChain154 | 7 (6) | 5 | 5 / 1 | 0 | 0 | none |
| § lvIfacePathBitSelWhole154 | 4 (4) | 4 | 4 / 0 | 0 (variable index, unpacked member, spaced `[ 2 ]`) | 0 | none |
| § defPkgStructParamMemberNames154 | 11 (5) | 2 | 2 / 0 | 0 (3 STAGE1-SAME: a MODULE parameter of an unpacked package struct with a package default is pre-existing stage 1; the law's names are golden's spelling, `p::p::cfg_t::A`) | 0 | none |
| § paramInitUnpackedMemberPath154 | 4 (4) | 3 | 3 / 1 | 0 | 0 | none |
| § psBoundPathFirstMember154 | 4 (3) | 2 | 2 / 1 | 0 | 0 | none |
| § portViewNestedPatTsNamed154 | 7 (6) | 1 | 3 / 0 (+3 bytes-only: an unreached object renamed, dump and strict records identical) | 0 | 0 | none |
| § initTsEndProgramLocal155 | 6 (6) | 1 | 1 / 5 | 0 | 0 | none |
| § implicitArgDimsInner155 | 4 (4) | 3 | 3 / 1 | 0 | 0 | none |
| § nonAnsiArrayNetAtHeader155 | 8 (4) | 2 | 2 / 2 | 0 | 0 | none |
| § naArrNetOwnPortDecl155v | 3 (2) | 0 | 1 / 1 | 0 | 0 | none |
| § unitAggTfArgLastWriter155 | 5 (3) | 0 | 1 / 2 | 0 (declines: residue N3) | 0 | none |
| § modAggTfArgLastWriter155 | 5 (4) | 2 | 3 / 1 | 0 | 0 | none |
| § pselConnNameNotFrozen155 | 8 (6) | 4 | 4 / 2 | 0 | 0 | none |
| § packedStructNdaFoldConstLoc155 | 7 (5) | 3 | 3 / 2 | 0 | 0 | none |
| § ifacePortViewFoldAtLeftOperand155 | 10 (7) | 4 | 7 / 0 | 0 | 0 | none |
| § pkgTdStretchNonAnsiHeaderSkips155 | 5 (3) | 3 | 3 / 0 | 0 | 0 | none |
| § tdStretchProgramKeeps155v | 2 (2) | 0 | 0 / 2 | 0 | 0 | none |
| § dirlessFormalTypeAtName155 | 6 (5) | 4 | 5 / 0 | 0 | 0 | none |
| § ifaceSigConnNamedByChildPort155 | 16 (16) | 8 | 12 / 3 | **1 MIXED (`isc/c11`) + 1 stage-1 (`isc/c08`): the law's last writer is wrong in two shapes, wrong-to-wrong (section 4)** | 0 | none |
| § genLpOperandTsNoParent152 (cross pairs) | 2 (2) | 2 | 2 / 0 | 0 | 0 | none |
| § tpOvrTypedefStructSpan152 (cross pairs) | 3 (3) | 1 | 1 / 2 | 0 | 0 | none |

Totals, default mode (the `--elabuhdm` grid reads the same cells, `evidence/grid_elabuhdm.txt`):

- 97 TOWARD cells, 29 STAGE1-CLOSER, 5 STAGE1-SAME, 5 BYTES-ONLY, 52 UNFIRED.
- 1 MIXED, adjudicated as wrong-to-wrong.
- 0 AWAY.

No case moves from STRICT_EQUAL to anything else under a law. No case moves from uhdm-cmp 0 lines to non-zero.

rc is 0 on every run, except `hpe/e01` and `vid/v04`. Those return rc=4 identically in every state.

Downstream: the three states give the same verdict on all 173 cases (152 IDENTICAL, 11 EQUIVALENT, 5 STATUS_DIFF,
2 DIVERGENT, 3 SURELOG_FAIL). The 158 slang-lane `_nohier.il` netlists are byte-identical ON vs OWN vs ALLOFF
(0 moved). The non-IDENTICAL verdicts are all pre-existing; they are the residues of section 8.

**Shapes covered**, fresh against both pairs' grids:

- **Interfaces:** arrays of interfaces; nested interfaces; generic `interface` ports.
- **Modports:** modport-typed ports with bare, named, positional and `.s(s.sub)` connections; two port views of one
  instance through two modports; two children.
- **Connections:** sliced, bit-selected, indexed-part-selected, width-converted, concatenated and macro-expanded
  member actuals; escaped port and generate names.
- **Generate scopes:** case-generate, loop in if, `always_latch`, `initial`, gen blocks in interfaces.
- **String methods:** in task, named-block, package-function and class scopes; queue methods; nested method
  arguments; string input ports; interface, program and child-module variable initializers.
- **Casts:** in a port actual, a concatenation, an interface, a net declaration assignment.
- **Lvalue paths:** macro-expanded paths and indexes; paths spaced or with comments; escaped bases; function
  bodies; `-:` selects.
- **Parameters:** unpacked package structs in module and interface definitions (imported, three levels, two
  parameters).
- **Programs:** fork, final, class `new(3)`, multi-line initializers, `program automatic`.
- **Non-ANSI headers:** two declarators, `output reg`, separate `reg`/`logic`/`wire` redeclarations, explicit ports,
  escaped names, generated child instances.
- **$unit and module aggregates:** task-then-function, default argument, DPI import, class method, macro-defined
  function, interface functions, output formals.
- **Folds:** package, `$unit`, macro-valued and two-declarator one-element patterns.
- **Port-view folds:** `%`, `!`, `(a - b) / c`, parameter pairs, two children, nested pass-through.

**Re-derivation of the two pass-154 laws nearest the fenced tests' shapes (the hier-path family), from fresh cases
and Surelog's source only.** Surelog's hier_path loop (third_party/Surelog/src/DesignCompile/CompileExpression.cpp,
5521-5612) does two things:

1. It builds an indexed element with `select->VpiFullName(the_name)`, `the_name` being the running path text plus
   `"[" + decompileHelper(index) + "]"`. That is § hpElemSelNameIsPathSoFar154.
2. It compiles a trailing range with `compilePartSelectRange(…, "CREATE_UNNAMED_PARENT", …)`, storing no full name
   on the bound references. `BaseClass::ComputeFullName` (third_party/Surelog/third_party/UHDM/templates/BaseClass.cpp,
   100-150) then keeps the `part_select` and the `hier_path` names on the chain (only a bit_select, indexed
   part-select or hier_path parent of a ref_obj is skipped). That is § hpPartSelBoundNamesBySelect154's
   `…bus.wdt[GW - 1:0].wdt.GW`.

The fresh cases `hpe/e05 e06`, `cx/x12` and `hpb/b04 b05` read STRICT_EQUAL under the laws and STRICT_NOTEQUAL
fullname without them.

## 4. The defect and the refinements (fix.patch; measured, not applied)

§ ifaceSigConnNamedByChildPort155 names a modport member through the child port of the LAST connection in source
order. Its writer set and its order are both narrower than golden's:

1. **Select connections are writers in golden.** `chd c (.d(sub.dat[1:0]))`: golden names `dat`
   `work@dut.m.c.d.dat`. The law requires a bare `sub.member`, so ours keeps `work@dut.m.sub.dat`. Cases `isc/c01`
   (range), `c10` (bit select) and `c13` (`+:`) are STRICT_NOTEQUAL fullname under the law.
   - When a bare connection precedes a sliced one, the law picks the bare one: `isc/c11`
     `.w(sub.dat), .h(sub.dat[1:0])`. The law gives `work@dut.m.c.w.dat`, golden `work@dut.m.c.h.dat`, pristine
     `work@dut.m.sub.dat` (walk-index pairs: `evidence/pairs_isc_c11_*.txt`, RE-RENDERED, same object).
   - The committed probe case `r10rggen9repro/t8` is this shape (`.i_addr(mif.address)` then
     `.i_half(mif.address[3:0])`, golden `…u_leaf2.i_half.address`). It is pass 155's own change
     `fullname(4) -> fullname(2)`, whose remaining 2 records are this mis-pick.
   - A concatenation `{sub.rst, sub.clk}` stays a non-writer in golden (`isc/c07` keeps `work@dut.m.sub.s.rst.rst`),
     as the law says for operators.
2. **Macro-expanded connections break the ordering.** The law compares locations only within one buffer. A
   connection written through a macro (`child c1 (.clk(\`CK))` before `child c2 (.clk(sub.clk))`) sits in its own
   buffer, so the first connection kept the slot. The law gives `work@dut.m.c1.clk.clk`, golden
   `work@dut.m.c2.clk.clk`, pristine `work@dut.m.sub.s.clk.clk` (`isc/c08`, stage 1 on the pre-existing
   macro-actual face, residue N2).

Neither shape is a break by the brief's definition: pristine is wrong on the same field. Both are the law misapplying
its own rule.

| law | switch | site | statement |
|---|---|---|---|
| § ifaceSigConnSelectWrites162v | `R11V162_IFSIGSEL_OFF` | ModuleEmit.cpp emitInterfaceInstance, the § ifaceSigConnNamedByChildPort155 connection scan | a member connected through ONE select (`sub.dat[1:0]`, `sub.dat[2]`, `sub.dat[k +: 2]`: slang's `sub` . `dat[…]`, an IdentifierSelectName with one selector) is a writer; operators and concatenations stay non-writers |
| § ifaceSigConnLastByExpansion162v | `R11V162_IFSIGMACRO_OFF` | same scan | the source order compares each connection's location at its expansion point in the original file (`getFullyOriginalLoc`) |

Both are inside the law's `r11u155Law` gate, so `R11U155_OFF` drops them with the law.

Measurements (fix.bin against law.bin):

- **Cases:** `evidence/fixgrid_{default,elabuhdm}.txt`, `evidence/fix_switches.txt`.
  - 5 of 173 cases move, in both modes, all toward golden. `isc/c01 c10 c11 c13` go STRICT_NOTEQUAL fullname ->
    STRICT_EQUAL. `isc/c08` stays stage 1 and gets closer (order-blind dump 28 -> 16).
  - The other 168 cases keep law.bin's bytes.
  - Both switches together restore law.bin's bytes on 173 of 173 cases. `R11V162_IFSIGSEL_OFF` alone restores them
    on the four select cases, and `R11V162_IFSIGMACRO_OFF` alone on `c08`. The three landing switches restore the
    pre-landing bytes on 173 of 173.
- **Prediction first.** `evidence/prediction_fix.txt` is a fenced source-shape census written before the fix sweep.
  It lists the rows whose sources hold a modport and a select or macro actual (Rggen, Ariane, Ariane2024, rp32,
  Tnoc, NyuziProcessor, Opentitan/Earlgrey, Verilator, YosysTests, cva6_equiv) plus the UVM coin.
- **Fix sweep F:** every gate green.
  - probe: `CONVERSION r10rggen9repro/t8 STRICT_NOTEQUAL differ:fullname(2) -> EQUAL`, reading
    `r10rggen9repro/t8,EQUAL,,equal`. It is the only probe byte mover (1 / 4087).
  - surelog and uhdm2rtlil csvs are identical to L's, apart from the LowMem path.
  - Byte movers are surelog 3 / 952, the UVM coin only (MiniAmiq d/t and SeqDriver d, 4 order-blind lines each,
    `evidence/coin_F_vs_L.txt`), and uhdm2rtlil 0 / 1608. Every mover is inside the prediction.
  - Downstream csv equal to L's.
- **All committed tools/probe cases:** 7403 `dut.sv` files, fenced paths excluded, `drivers/bytes.sh`
  (`evidence/bytes_toolsprobe_law_vs_fix.txt`). 5 movers, the five fresh cases above. rc is the same on every
  case; the four pre-existing crashes (rc 139/134) are the same on both binaries.
- **Downstream** (`evidence/downstream_cases_fix_isc.txt`): all 13 `isc` cases keep their verdicts under the fix.
  `c01 c10 c11 c13` are IDENTICAL on both binaries; the names do not reach the RTLIL there.

## 5. Composition of the two landings

`drivers/compose.py` builds `evidence/composition_census.txt`. Per row, v = (status, strict) under:

- A: both landings off;
- X: 155 alone;
- Y: 154 alone;
- L: both on.

| stage | ONLY154 | ONLY155 | BOTH (both move it) | JOINT (only together) | CANCEL | NONADD |
|---|---|---|---|---|---|---|
| probe | 32 (15 conv) | 74 (8 conv) | 1 (`r11u1repro/grid2`) | 0 | 0 | 0 |
| surelog | 20 (5 conv) | 13 (10 conv) | 0 | 0 | 0 | 2 (environment: the CoresSweRV Surelog timeout in Y, section 2) |
| uhdm2rtlil | 24 (20 conv) | 12 (10 conv) | 0 | 0 | 0 | 0 |

Every conversion each landing claimed is that landing's, alone:

- 154: BasicOh d, InterfaceParamOverrideProp d/t, StringMethod d/t, the ten uhdm2rtlil rows, and 15 probe cases.
- 155: ImplicitArg, UnpackPort, GenForIfaceLocalparamBound, GenForIfaceLocalparamNestedGen, IfGenTypeBinding,
  union_param_repro, genscope_module_ctx_reset, PatternStruct, OneNetModport, iface_sig_in_child_port (each d/t),
  and 8 probe cases.

No conversion needs both landings, and no pair cancels. The single BOTH case is additive record by record
(`drivers/additive.py`, `evidence/composition_both_r11u1repro_grid2.txt`). A holds 15 records; 155 fixes 1 and 154
fixes 7, with no overlap and nothing added; L holds 7 = 15 - 1 - 7.

**The cross-ground pairs on fresh cases** (`cx/*`, every pair of own switches run; records differing from golden
per state):

- **§ pselConnNameNotFrozen155 with § lvPathSelNamedByChain154 / § lvPathBaseAtFirstMember154:**
  - `cx/x11` (an interface instance and a child in a generate block, a part-select actual, a written interface
    path): off-alone 1 / 2 / 2 records, pairs 3 / 3 / 4, all off 5, on 0. Additive; STRICT_EQUAL with all three.
  - `cx/x04`: 3 + 2 = 5 -> 0.
  - `cx/x03`: pre-existing stage 1, closer under each law.
- **§ hpElemSelNameIsPathSoFar154 with § ifaceSigConnNamedByChildPort155:** `cx/x12` (a child port connection and
  an element path read `sub.rq[1].adr[1:0]` through one modport view): 2 + 2 = 4 -> 0, STRICT_EQUAL.
  `cx/x05 x06` fire only the 155 law (the element reads without a trailing select), 2 -> 0.
- **§ genScopeProcPsNamedByScope154 / § genProcFoldTsKeepsScope154 with pass 152's § genLpOperandTsNoParent152:**
  `cx/x07 x08` (processes in a generate loop nested in a loop or an if, with a loop localparam `L = Q[k]`).
  GENLPOPTS 2 -> 0. The 154 pair does not fire there (the process is in a nested generate LOOP, whose names were
  already golden's), and the verdict is STRICT_EQUAL.
- **§ ifacePortViewFoldAtLeftOperand155 with § portViewNestedPatTsNamed154:** the two laws act on disjoint port
  views, so they never fire on the same object.
  - PVLEFTOP fires only on a plain interface port view (`!namedModportPortView9`); PVNESTTS fires on a modport view.
  - `cx/x02` (plain port): PVLEFTOP 1 -> 0, PVNESTTS bytes-only.
  - `cx/x01` (`.s(s.sub)`) and `cx/x13` (modport-typed port, bare connection): PVNESTTS 1 -> 0, PVLEFTOP unfired.
  - No interaction.
- **§ defPkgStructParamMemberNames154 with pass 152's § tpOvrTypedefStructSpan152:**
  - `cx/x09` (packed): TPOVRSTRUCT 4 -> 0, DEFPKGTS unfired.
  - `cx/x14` (unpacked package struct parameter plus a module-local type override): both fire. TPOVRSTRUCT is
    closer (dump 38 -> 26), DEFPKGTS STAGE1-SAME (the pre-existing module-parameter stage-1 face).
  - `cx/x10`: stage 1 unmoved.

## 6. The unmaskings and changes

`drivers/unmask.py` builds `evidence/unmask_A_vs_L.txt`. It re-reads every row and probe case whose verdict
differs between A and L with uhdm-strictcmp `--max 100000` on both databases.

| stage | rows | CONVERSION | SUBSET (every L record is an A record) | NEW | fenced |
|---|---|---|---|---|---|
| probe | 107 | 23 | 82 | 2 | - |
| surelog | 33 | 15 | 18 | 0 | 0 |
| uhdm2rtlil | 36 | 30 | 6 | 0 | 0 |

All 18 + 15 + 4 CHANGE lines of pass 154 and 67 + 3 + 2 of pass 155 are among these. The combined sweep lists
84 + 18 + 6, since one probe case is moved by both.

- **106 are SUBSET.** They lower the count on the same field, or they clear the records ahead of one A already held.
  - `r11v1repro/vA` `endcol(2) -> depth(1)`: paired by walk index (`evidence/unmask_pairs_r11v1repro_vA.txt`), #253
    endcol is FIXED and #292 depth is SAME-REC, the identical record in both walks.
  - `YosysBigSimEllip` d `fullname(2941) -> type(1)` (`evidence/unmask_pairs_YosysBigSimEllip_default.txt`): 2940
    FIXED; #70374 `part_select C` against our `constant` is SAME-REC; objects 681189 vs 681181 in both.
  - Earlgrey_0_1 d/t `line(1738) -> line(1730)`, SimpleConstraint, const_cast_signext and the rest are SUBSET.
- **The two NEW are re-renderings of the same objects, not new differences** (`evidence/unmask_new_pairs.txt`).
  - `r10earl29repro/a4_ctx` (pass 154's recorded one): #125 and #280 FIXED, #126 and #281 RE-RENDERED.
  - `r10rggen9repro/t8` (pass 155's): #353 and #354 FIXED, #357 and #358 RE-RENDERED. That is the mis-pick
    section 4 refines; under fix.bin the case converts.

## 7. Downstream bytes of the converted uhdm2rtlil rows (L's downstream workdir)

`<test>/surelog/*` against `<test>/slanguh/*`: every file (`.il`, `_nohier.il`, `_synth.v`, `run.ys`,
`yosys.log`) is byte-identical for all 16 rows the two landings converted or changed
(`evidence/downstream_bytes_converted_rows.txt`).

- Pass 154: `comb_dyn_2d_packed_sel,IDENTICAL,OK,OK,124,124,,`, `iface_arr_struct_field_partsel`,
  `iface_cfg_mem,IDENTICAL,OK,OK,27495,27495,,`, `iface_nested_param_field`, `iface_param_2level`,
  `iface_scalar_localparam`, `iface_struct_field_param_width`, `iface_struct_field_partsel`,
  `jeras_tcb_gpio,IDENTICAL,OK,OK,271,271,,`, `mem_ff_partial_rsp,IDENTICAL,OK,OK,1790,1790,,`.
- Pass 155: `union_param_repro,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `genscope_module_ctx_reset,IDENTICAL,OK,OK,11,11,,`,
  `PatternStruct,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `OneNetModport,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
  `iface_sig_in_child_port,IDENTICAL,OK,OK,2,2,,`, `const_cast_signext,IDENTICAL,NO_GATES,NO_GATES,0,0,,`.

Positive control: the two EQUIVALENT rows (func_upto, matching_end_labels) read `_nohier.il=DIFF` with the same
comparison. The connection and initializer cases are in section 3; every one keeps its verdict and its netlist
bytes in all three states.

## 8. Residues re-measured at 16607134

Row statuses are in `evidence/residue_rows_head.txt`, case verdicts in `evidence/residue_cases_head.txt`, and
downstream in `evidence/residue_cases_downstream.txt`.

**Pass 154, decoded residues 1-3.**

1. Still stands:
   - (a) InterfArrayBind d is still `fullname(3)`.
   - (b) portsel_struct_param d/t is `col(4)`; expr_width_cast d/t is `col(12)`.
   - (c) `r10earl29repro/a4_ctx` is `fullname(10)`.
2. Still stands: `lv/m1` and `lv/m2` are STRICT_NOTEQUAL col, downstream IDENTICAL.
3. Still stands: anon_struct_packed_dim d/t is `fullname(43)`.

Pass 154's residue 6 (`hp/f14`) is **cleared**: it now reads STRICT_EQUAL.

**Pass 154, sister faces S1-S3.** All still stand:

- S1: ComplexParamOverload d/t `name(2)`.
- S2: YosysMarlann d/t `endcol(24)`.
- S3: MacroArgMismatch d/t `endcol(8)`.

**r11v154, residues 1-3.** All still stand:

1. `cq/r1` is stage 1 (28 lines) and still **DIVERGENT** downstream.
2. `lb/i10` is stage 1 and STATUS_DIFF (Surelog READ_FAIL).
3. `he/b2` is STRICT_NOTEQUAL endcol.

r11v154's residue 5 (`gf/d3`) is **cleared**: it now reads STRICT_EQUAL.

**Pass 155, sister faces (top 3).** All still stand:

- R-EV: EnumVar d/t `endline(3)`.
- R-SP:
  - struct_param_pattern_packing d/t: `line(1)`.
  - const_cast_signext d/t: `line(5)`.
  - StructParamFieldRange and cva6_struct_param_field d/t: `fullname(7)`.
- MultirangesStartNotFromZero d/t: `file(2)`.

**Pass 155, ranked residues 1-3.** R-SP and R-EV are as above. R-LT, LogicTypespec d/t, still stands at `endline(3)`.

**v11u155, residues L1-L3.** All still stand:

- L1: `MF/g07` line.
- L2: `IT/k05` endcol.
- L3: `PS4/q03` endcol; `q05` and `q08` stage 1.
- L4: `IC/c02` fullname.

**New residues from this pass, ranked (all law-independent: the same in the ON, OWN and ALLOFF states):**

1. **N1: whitespace inside a dotted path** (`bs . wdtxx [3:0] <= x`, `v[sub . W : 0]`).
   - Ours splits the path TEXT, so the names carry the spaces (`bs `, ` W`: uhdm-cmp stage 1).
   - The downstream plugin fails to read our database: the slang lane is READ_FAIL, so the verdict is STATUS_DIFF
     (`lbm/l06`, `pbp/p04`).
   - The text-derived member token of § lvPathBaseAtFirstMember154 and § psBoundPathFirstMember154 lands one column
     early there (32 against golden's 33).
2. **N2: a macro-expanded interface-member actual** (`.clk(\`CK)` with `CK` = `sub.clk`).
   - Ours writes no high_conn for the child port (uhdm-cmp RHS `<null>`).
   - The netlist leaves the child's `\clk` unconnected (`connect \clk \sub.clk` missing; downstream EQUIVALENT,
     `isc/c05 c08`).
3. **N3: the `$unit` aggregate last writer across containers.**
   - Golden's last writer is a module DPI import's formal (`uag/u03`: 5:41).
   - It is also a class method's formal even when a later `$unit` function exists (`uag/u04`: 3:34).
   - § unitAggTfArgLastWriter155 declines both, so the bytes are pristine's (STRICT_NOTEQUAL line).
4. **N4: Surelog-defect faces** (golden wrong, ours right).
   - The second declarator of `input logic [1:0] a [2], b [2];` loses its unpacked dimension in golden (`naa/a01`,
     downstream STATUS_DIFF: Surelog NO_GATES).
   - A concatenation actual `{sub.rst, sub.clk}` is connected empty in golden (`connect \d { }`, `isc/c07`
     EQUIVALENT).
5. **N5: pre-existing downstream divergences.**
   - `naa/a04`: an explicit non-ANSI port `module dut(.a(x), o)` over an unpacked array is DIVERGENT.
   - `uag/u02`: a union default argument `f(u_t op = 4'h3)` is DIVERGENT, a constant value mismatch.
   - `isc/c03`: an escaped modport port name `\sb$0 ` makes the slang lane READ_FAIL.
   - `cst/c05`: a cast in a net declaration assignment is EQUIVALENT.
6. **N6: stage-1 folds.**
   - `hpb/b03`: golden folds a parameter inside a generate-loop path text (`bus.wdt[2 + g:g]`).
   - `gft/f05`: golden keeps `P` unfolded in a generate `initial`.
   - `dps/d05 d07 x14`: a MODULE parameter of an unpacked package struct with a package default is pre-existing
     stage 1.

## 9. The fence and the process

**No law, case or number of this pass rests on a fenced reading.**

- No fenced source, copy or sweep database was opened. The byte comparisons ran on mirrors without them.
- Every case is fresh, and `drivers/bytes.sh` excluded fenced paths.
- A word-boundary scan of every file here finds 0 fenced names. The same scan reads 8 lines in
  `results/golden_surelog.csv` (positive control), in `evidence/fence_check.txt`.

**Pass 154's fenced census is not load-bearing.**

- The implementer's census (`r11u154repro/evidence/census_firings.txt`, 133 lines) dispatched every corpus row,
  the fenced rows included.
- The verifier's fence-clean census (`r11v154repro/evidence/census_firings_fenceclean.txt`, `--filter` negative
  lookahead from `$FENCED`) is identical after normalising paths: 0 differing lines, and the same per-law counts
  (CASTREF 6, DEFPKGTS 14, GSFOLDTS 6, GSPROCPS 10, HPELEMNAME 2, HPPSBOUND 13, LVBASEMEM 17, LVIDXREAD 13,
  LVSELNAME 9, MARGNAME 13, PIUNPACKED 4, PSBOUNDPATH 4, PVNESTTS 20, VARINITDEF 2).
- No file of the four pass directories names a fenced test.
- This pass's L-vs-A byte movers (952 fence-free paths) are exactly the landings' own lists.
- The two pass-154 laws nearest the fenced tests' shapes (the hier-path family) are re-derived from fresh cases
  and Surelog's source in section 3.

**Drivers that do not meet the fence rule** (all classified in `evidence/driver_fence_audit.txt`):

- r11u154repro:
  - `row.sh` dispatches corpus rows by an unguarded `--filter`.
  - `tracewrap.sh` as used: its census dispatched the fenced rows. The breach is disclosed in its README.
  - `moverdiff.sh` refuses only an EMPTY `$FENCED`, not a wrong one.
- v11u155repro:
  - `attrib.sh` re-runs corpus rows from a positive whitelist without refusing when `$FENCED` is missing.
  - `dist.sh` is a generic database reader with no guard; the README used it on corpus databases.
- All four passes: `tools/probe/r11v75repro/byteverify.sh` ran over the full sweep trees ("960 paths" surelog in
  each), so the 8 fenced row-mode databases were read by `cmp`. No mover list names one.

Compliant drivers:

- r11u154 `rowdump.sh`; r11v154 `vc.sh` and `ds.sh`.
- r11u155 `attrib.sh`, `heads.sh` and `predict.py`.
- The rest read cases or probe databases only.

Drivers that do not run from the repository as committed:

- r11u154 `pdiff.sh`, `pin.sh`, `rc.sh`, `row.sh` and `switches.sh` source `/tmp/r11u154_env.sh`.
- r11v154 `sw.sh` calls `/tmp/v11u154_vc.sh`.
- r11v154 `probemov.py` and r11u155 `gridrun.sh` hard-code a `/tmp` worktree.

**Pass 155's prediction is labelled, but not in the driver.** The README (section 4) states that
`drivers/predict.py` was written after the development sweeps and is not a blind prediction. The driver's own
docstring still says it was "run on the pristine corpora BEFORE the law sweep".

**This pass's own process.**

- It wrote only under `/tmp/wt_r11u162*` (the worktree plus three build worktrees P/Q/F at 5a602076, fc99b2d5 and
  16607134+fix) and `/tmp/r11u162_*`.
- It ran binaries only on its own cases, on tools/probe and tests/probe cases, and inside the sweeps. No gdb was used.
- The only processes stopped were its own.
- The main tree's `git status` is clean.

## 10. Files

- `cases/<group>/<case>/dut.sv`: 173 cases. The first line is `// § <law>`; `cx/*` name two or three laws.
  - Groups: hpb hpe gsp gft mar vid cst lxr lbm lsn lbs dps piu pbp pvn (154); itp iad naa uag mag psc nda pvl tds dfn
    isc (155); cx (cross pairs).
- `fix.patch`: the two refinements. The directory names them with the section sign, so the commit that lands it
  (or this directory) regenerates `tests/LAWS.md` with `scripts/law_index.py`.
- `drivers/`:
  - Environment and cases:
    - `env.sh`: tools, `$FENCED`.
    - `case.sh`: one case (golden, ours, uhdm-cmp, uhdm-strictcmp).
    - `grid.py`: states and scores.
    - `fixgrid.py`: the fix against ON.
    - `fixswitch.sh`, `offbytes.sh`: switch restoration.
    - `tri.py`: OFF/ON dump lines marked against golden.
    - `dscase.py`: downstream per case and state.
    - `summarize.py`: produces `law_tables.md`.
  - Sweeps: `sweep.sh`, `bvmirror.sh` (fence-free hard-link mirror), `coin.sh` (order-blind UVM coin).
  - Composition and unmaskings: `compose.py`, `additive.py`, `unmask.py`, `samepair.py`.
  - The fix: `predict_fix.py` (fenced source-shape census), `bytes.sh` (all tools/probe cases on two binaries).
  - Residues: `rescase.sh`, `dsres.py`.
- `evidence/`:
  - Grids: `grid_default.txt`, `grid_elabuhdm.txt`, `law_tables.md`, `fixgrid_*.txt`.
  - Downstream: `downstream_cases_{ON,OWN,ALLOFF}.txt`, `downstream_cases_fix_isc.txt`,
    `downstream_bytes_converted_rows.txt`.
  - Sweeps: `sweep_{L,A,X,Y,P,Q,F}.log`, `canaries_{L,F}.txt`, `rerun_Y_CoresSweRV.csv`.
  - Bytes: `byteverify_{L_vs_A,A_vs_P,Y_vs_Q,F_vs_L}_*.txt`, `coin_*.txt`, `prediction_L_vs_A.txt`,
    `movers_L_vs_A.txt`, `probe_movers_L_vs_A.txt`, `offbytes_alloff_vs_pre154.txt`.
  - Composition and unmaskings: `composition_census.txt`, `composition_both_r11u1repro_grid2.txt`,
    `unmask_A_vs_L.txt`, `unmask_pairs_*.txt`, `unmask_new_pairs.txt`.
  - The fix: `prediction_fix.txt`, `fix_switches.txt`, `bytes_toolsprobe_law_vs_fix*.txt`, `pairs_isc_c11_*.txt`.
  - Residues: `residue_rows_head.txt`, `residue_cases_head.txt`, `residue_cases_downstream.txt`.
  - Fence: `fence_check.txt`, `driver_fence_audit.txt`.
