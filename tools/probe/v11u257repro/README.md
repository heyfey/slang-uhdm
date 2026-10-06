# v11u257: adversarial verification of r11u257

Base 5f1da483. Implementer's patch `/tmp/r11u257.patch` (md5 a40c4e0b82a5503eca6469984e96137e): seven laws behind
`src/R257.h` in TypeEmit, ModuleEmit and UhdmExporter.

**Verdict: ACCEPT WITH FIX.** Every headline number of r11u257 reproduces. Fresh cases found two laws that move
legal SV away from golden where pristine was right, and the determinism check found a database that reads a second
hash with the law. All three are fixed by refinements behind their own switches:
* § genLpFoldAddUint257 wrote UINT for an add whose operand reduces to a signed constant: a 3-way uhdm-cmp
  regression (pristine judge-equal -> law stage 1) on fresh C/vc06, vc18, vc19 in the elaborated view.
* § ifacePortMemberHighConnParent257 picked the last port DECLARED where Surelog takes the last connection
  WRITTEN: STRICT_EQUAL -> STRICT_NOTEQUAL fullname on fresh R/vr03 and vr17 in both views.

* SeqDriver testflags read a second database hash in 5 of 90 concurrent draws of the law binary and in 0 of 132
  pristine draws. It is order-only: two unparented `uvm_reg_byte_en_t` bit_typespecs swap places. The cause is a
  pre-existing address-ordered mint loop, traced and fixed as § cloneTfIdOrder257v (§ 3.3).

The first two fixes move no gate database. The determinism fix moves 4 corpus databases (MiniAmiq d/t, SeqDriver
d/t) and 2 probe databases, all predicted by name, all order-only, every csv row unchanged.
The delivered patch is `/tmp/r11u257.verified.patch`.

## 1. Binaries

Built with `-j 2` and the system deps in fresh worktrees at 5f1da483, then frozen before any measurement:

| binary | md5 | built from |
|---|---|---|
| pristine | 771d2315d253e6fafc91b9df9e2cc1f8 | `/tmp/wt_v11u257pris`, the same md5 as the main tree |
| law | cadde10535fddb43936f591a8c8bf08c | the implementer's patch applied cleanly, the same md5 as the implementer reported |
| fix | cba73b5bd1e959727c8d1a28173f8fb0 | law + the three refinements below; a fresh apply of the delivered patch on 5f1da483 builds to the same md5 |

All three link slang 12.0.0+545f88b2e. Intermediate fix binaries were superseded during the refinement (§ 3):
* c38167e0… is the first two refinements. Its sweep summary is `evidence/sweeps/summary_wF.txt`, and its census and prediction are
  `evidence/census_fix3.txt` and `evidence/prediction_fix3.txt`.
* 50aa75bd…, c4a7b5b9… and 096253c4… are drafts.
* The `exp` builds (V257_EXP) and the `dbg` builds are measurement-only and were never delivered.

Unless marked, every number below is for the final fix binary.

## 2. Reproduction of r11u257's numbers

Gate sweeps: `tests/sweep.sh --jobs 3`, workdirs `/tmp/v11u257_wP` (pristine), `/tmp/v11u257_wL` (law),
`/tmp/v11u257_wF` (the c38167e0 fix) and `/tmp/v11u257_wZ` (the final fix). Summaries and fence-filtered row diffs are in `evidence/sweeps/`.

| stage | pristine | law | fix |
|---|---|---|---|
| probe | 3547 + 540, regressions=0 | 3552 + 535, regressions=0, conversions=5, changes=0 | the same as law, row for row |
| surelog | 937 + 17, regressions=0 changes=0 | regressions=0 conversions=0 changes=3 | the same as law, row for row |
| uhdm2rtlil | 1606 + 0 | the same | the same |
| downstream | 803 / 66 / 2 / 0 | the csv byte-identical to pristine's | byte-identical to pristine's |

The pristine sweep's only non-zero exit is `law index STALE` at the base itself (the base commit's own message is
not in its tests/LAWS.md; the main tree reads the same).

The three corpus changes (fresh rows, results/ untouched):

```
Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(139),,differ:fullname(139)    (was fullname(155))
Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(34),,differ:fullname(34)    (was fullname(50))
Rggen,default,STRICT_NOTEQUAL,differ:col(129),,differ:col(129)                      (was fullname(199))
```

The Rggen head was read on both sweeps with `uhdm-strictcmp --max 3`:
* pristine: #26477 fullname. Golden has the `enum_var access` at `...u_register_common.g_decoder[0].u_decoder.i_access.access`, ours at `...u_register_common.register_if.access`.
* law: #27671 col. The `ref_obj bit_field_if` is at block_0.sv 7:24-33 in golden and 7:11-23 in ours, the implementer's sister-ground head.

The five probe conversions are r10rggen6repro/t4 and t5, r11u112repro/grid/f/g09_for_lp_sub and g18_hop_lhs, and
r11u46repro/grid2.

Other checks:
* **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`) runs through fence-filtered hard-link
  mirrors, built by r11u257's `drivers/bvmirror.sh`, which skips 8 fenced databases per sweep
  (`evidence/byteverify_corpus.txt`):
  * law vs pristine: **7 of 2560** move. They are Earlgrey_0_1 d/t, Rggen d, OneNetModPort d/t and OneNetModport
    d/t, the implementer's list.
  * c38167e0 fix vs law: **0 of 2560**.
  * final fix vs law: **4 of 2560**, MiniAmiq d/t and SeqDriver d/t, § cloneTfIdOrder257v.
    * All four were named in `evidence/prediction_final.txt`, frozen before the final sweep.
    * Sorted uhdm-dumps are identical on all four (`evidence/orderblind_final_vs_law.txt`).
    * Their csv rows are unchanged.
  * final fix vs pristine: 11, the law's 7 plus those 4.
  * Every run reads PATH_SETS_IDENTICAL and SELFCHECK 2559 of 2560.
* **Probe bytes** (`evidence/probe_ds_movers.txt`): the pristine probe stage was rerun from the law worktree,
  because a database embeds its case path.
  * law vs pristine: **7 of 4087** move, the five conversions plus r10rggen9repro/t8 and t9.
  * c38167e0 fix vs law: **0**.
  * final fix vs law: **2**, r10uvm180repro/g180_a_kinds and r10v180repro/v180_a_share. Both are predicted
    candidates and both are order-only.
* **Downstream slang-lane bytes**: 1 of 805 moves against pristine (OneNetModport, IDENTICAL on all three
  binaries) and 0 against law. The downstream csv of every sweep is byte-identical to pristine's.
* **The OFF switches on the final fix** (`evidence/off_corpus.txt`), over all 11 corpus movers, run through the
  harness with a fixed name filter; every cmds.txt names the fix binary:
  * `R11U257_OFF` gives pristine's md5 on 11 of 11;
  * `R11V257_OFF` gives the law's md5 on 11 of 11.
* **Away census** on the corpus movers, fix vs pristine (`evidence/away_corpus.txt`, r11u257's awaycorp.sh,
  chain-keyed):
  * Earlgrey d: 1032 -> 996, lost=0.
  * Earlgrey t: 764 -> 728, lost=0.
  * Rggen d: 811 -> 523, lost=0.
  * OneNetModPort and OneNetModport: 0 -> 0.
* **Canaries**:
  * law sweep: surelog `ok=50 changed=2` (the Earlgrey rows) and uhdm2rtlil `ok=16 changed=0`.
  * `ctcan2.sh` with EXPECT_UNKNOWN=1 and 6: PASS on both.
* **Binary-path audit**, with the cmds.txt list filtered by $FENCED first: 3265 of 3265 `slang:` lines per sweep
  name that sweep's frozen binary.
* **Firing census** (`evidence/census_final.txt`, r11u257's tracecensus.sh with the final fix): its law entries
  equal the implementer's frozen `predict.txt` line for line (64 databases). The refinements add:
  * `ifacePortHcConnOrder257v` on Rggen d, probe r10rggen9repro/t8 and t9, and uhdm2rtlil iface_sig_in_child_port
    d/t. Its order changes the last writer nowhere in the gate.
  * `genLpFoldAddOperandKinds257v` nowhere.
  * `cloneTfIdOrder257v` (two or more clone bodies minting) on MiniAmiq d/t, SeqDriver d/t and nine probe
    databases. Six of these moved.
* **The r11u257 grid** (85 cases, both views, 10 configurations, 1700 lines): every line rc=0, and the law-side
  verdicts are identical to the implementer's `evidence/grid.txt` on all 1360 non-pristine lines.
  * 65 case-views enter STRICT_EQUAL and none leave.
  * Its summary differs from the implementer's only on the pristine-nondeterministic F cases (single draws):
    moving 113 against 111, and f12_unit_scope_el drew a stage-1 pristine hash here.
* **Byte controls**: the implementer's 21 repro dirs plus the clone-body dirs r10uvm180repro, r10v180repro,
  r10uvm123repro, r10uvm32repro, r10uvm36repro, r10buvm8repro and r10v208repro. That is 3040 case-views on
  pristine, law and the final fix (`evidence/controls.txt`).
  * The exit codes are identical on all three binaries; 21 case-views exit non-zero on all three.
  * Law vs pristine: 30 move. Two enter STRICT_EQUAL (v11u255 vf02 in both views) and none leave.
  * The implementer counted 29 and the c38167e0 run counted 32. The difference is the pristine coin on the v11u255
    F cases, single draws.
  * Fix vs law: 0 move.
  * Away census over the 30: lost=0 (`evidence/away_controls.txt`).
* **The determinism defect** (`evidence/nondet.txt`, 10 concurrent draws per case-view), on v11u255 vf03, vf05 and
  vf08, r11u257 f10, f11 and f12, and v11u257 vf20 and vf21:
  * pristine: two hashes on 13 of 16 case-views;
  * law and fix: one hash on 16 of 16;
  * fix + R11U257_OFF: two hashes on 13 of 16;
  * fix + R11U257_FWSPEC_OFF: two hashes on 14 of 16.

## 3. The two breaks and the refinements

### 3.1 § genLpFoldAddOperandKinds257v (refines § genLpFoldAddUint257; switch R11V257_ADDKIND_OFF)

**Break.** Fresh case C/vc06 is `[UW+1:0]` on a generate localparam, with `parameter bit [7:0] UW = 8'd5`.
* Golden: INT:6, const type 7.
* Law: UINT:6, const type 9.
* Pristine was judge-equal (STRICT_NOTEQUAL endcol). The law fails uhdm-cmp: stage 1, 36 lines.

The same happens on C/vc18, where `#(.AW(4'd6))` overrides an int parameter, and on C/vc19, `[AW%5+1:0]`. All three
are in the elaborated view.

**Decode.** UHDM's ExprEval `reduceExpr`, vpiAddOp
(third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp), takes the signed path when either *reduced* operand
is a constant of const type INT, DEC, STRING or REAL. The implementer's rule read the operator tree alone, where
sub, mult and div yield INT. Two cases show the gap:
* A parameter reduces to the value its scope's param_assign carries: `8'd5` is DEC, `4'd6` is DEC, `8'hA` is HEX.
  The parameter object keeps its default value in golden too: vc17's `UW` reads DEC:5 although the override is
  HEX.
* vpiModOp also yields INT.

**Law.** The fold is UINT only when every leaf of the add tree is known unsigned:
* an unsized decimal literal;
* a based literal with an h, b or o base;
* a parameter whose param_assign right-hand side, or failing that whose own value, is UINT, HEX, BIN or OCT. The
  lookup walks the generate scopes and then the instance.

A sub, mult, div or mod operand is INT. An operand of unknown kind leaves the base's INT. This sits at ModuleEmit
§ genLpFoldAddUint257's site.

**Measured** (C cases):
* vc05, vc06, vc17, vc18, vc19, vc20 and vc22 are STRICT_EQUAL in the elaborated view.
* vc21 (`AW+4'h1` and `AW+4'd1`) moves two records toward golden and stays stage 1 on a separate size face (see
  residues).
* The implementer's RC c01 to c10 are byte-identical on law and fix.

### 3.2 § ifacePortHcConnOrder257v (refines § ifacePortMemberHighConnParent257; switch R11V257_HCORDER_OFF)

**Break.** Fresh case R/vr03 has the child `dec d(.y(register_if.address), .x(register_if.address))`, with dec's
ports declared x, y:
* golden parents the shared port-view variable at **x**;
* pristine's stored full name already read `work@top.u.d.x.address`;
* the law re-parents it at **y**.

STRICT_EQUAL -> STRICT_NOTEQUAL fullname in both views. R/vr17 (the same, over three lines with a macro actual)
breaks the same way.

**Decode.** `NetlistElaboration::high_conn_` (third_party/Surelog/src/DesignCompile/NetlistElaboration.cpp) walks
the instance's connection list in source order. A named connection finds its port by name, and
`p->High_conn(hexpr); hexpr->VpiParent(p);` runs once per connection, so the last connection written wins. The law
walked `Ports()` in declaration order.

**Law.**
* ModuleEmit records the connection position at § ifacePortVarHighConn's resolution site (where the actual became
  the interface variable). The key is the fully expanded location, then the fully original one: a macro body's
  tokens read their definition's place as original.
* The design-final walk then visits one instance's resolved ports in that order.
* Ports without a record keep their declared order ahead of them.

**Measured:**
* vr03, vr17 and vr18 are STRICT_EQUAL in both views. vr18 has the last actual written through a macro defined
  above the instance; pristine and law are both wrong there.
* vr14 (positional), vr15 (named, in declared order) and vr16 (two children) are unchanged and equal.

### 3.3 § cloneTfIdOrder257v (determinism; switch R11V257_CLONETFORDER_OFF)

**Break.** In the law's determinism check, SeqDriver testflags read 43673ce642c6 in 1 of 3 draws, against
2a2f2c0bc6a8. `evidence/det_seqdriver.txt` holds 3-concurrent harness draws per configuration:

| configuration | flipped draws |
|---|---|
| law | 5 of 90 (and 2 of 36 earlier) |
| c38167e0 fix | 3 of 90 |
| pristine | 0 of 132 |
| law + `R11U257_OFF` | 0 of 90 |
| law + `R11U257_FWSPEC_OFF` | 0 of 90 |
| law + `R11U257_FWKIND_OFF` | 0 of 90 |
| exp build with only the FWKIND block's `ownListed257` call left | 7 of 90 |

The rate followed heap layout, not the law's decisions:
* a `dbg` build that differs from the fix only by a stderr print when `V257_DBG` is set flipped 32 of 45;
* § fwWinnerSpecKind257 never fires on SeqDriver.

**Decode.** The `dbg` build logged every LAW-S copy mint with a backtrace. The no-alias copy of
`uvm_pkg::uvm_reg_byte_en_t` is minted at a different point of the sequence in the two hash classes, both from
TypeEmit `importCloneBareTdAlias16`. There, `for (auto* tf : pkgImportCloneTfs16)` walks a `std::set` of task_func
POINTERS, so the clone bodies are visited in heap-address order, and `cloneCopyOf` and `bareScalarTdCopyOf` mint on
first use. The order is pre-existing; the law only perturbs the allocator.

**Law.** The bodies are visited in creation order (UhdmId), the order § lawSCopyIdOrder186 and
§ recvArgMintIdOrder238v already use. The trace `cloneTfIdOrder257v minting <n>` names every database where two
or more bodies mint, which is the mover predictor.

**Measured:**
* SeqDriver testflags: 90 of 90 draws read one hash, 499fc01a9c89.
* `R11V257_CLONETFORDER_OFF`: 90 of 90 read the law's 2a2f2c0bc6a8.
* The four corpus movers and two probe movers are order-only.
* Fresh K/vk02 (two wildcard importers) moves order-only, with lost=0, and keeps its verdict in both views.
* Fresh K/vk01 fires the trigger without moving: its addresses already follow creation order.

A first attempt, withdrawn, replaced § fwWinnerSpecKind257's walk over `specializations()` (it reads `members()`,
which elaborates a specialization's body). It did not remove the flip (10 of 90) and is not delivered.

## 4. The fresh cases (`cases/`, 75 cases, both views)

Every case names its law in its first line.

| dir | law | cases |
|---|---|---|
| F | § fwWinnerSpecTieBreak257, § fwWinnerSpecKind257 | vf20 same-named classes of two packages as type arguments; vf21 same-named struct typedefs of two packages; vf22 width-parameter vector; vf23 int and byte; vf24 struct default; vf25 negative and multi-digit values |
| R | § ifacePortMemberHighConnParent257, § ifacePortHcConnOrder257v | vr01 interface child; vr02 program child; vr03 reversed named connections; vr04 two modport ports; vr05 two ports bound to one instance; vr06 output member; vr07 member kinds; vr08 enclosing module in a top generate over an interface array; vr09 member also assigned; vr10 two enclosing instances; vr11 `.*`; vr12 bit select beside the whole member; vr14 to vr19 connection order (positional, named in order, two children, multi-line with macro, macro actual written last, reversed inside a macro body) |
| P | § implicitPortTsFirstDim257 | vp01 parameter; vp02 localparam; vp03 function return; vp04 macro dimensions; vp05 `var`; vp06 dimensions across a newline and a comment; vp07 parameterised dimensions with two ports per declaration; vp08 class method formal; vp09 non-ANSI; vp10 with an unpacked dimension; vp11 `signed`; vp12 package task output |
| C | § genLpFoldLeftOperandSpan257, § genLpFoldAddOperandKinds257v | vc01 to vc16 bound shapes (product, shift, two-parameter add, add over product, unsigned parameter, both bounds, quotient, conditional, `$clog2`, mod, add-sub, sub-add, literal-first add, a logic localparam over two lines in a nested generate, an interface); vc17 to vc22 operand kinds (hex override, decimal override, mod under add, generate-local operand, hex and based-decimal literals, genvar operand) |
| K | § cloneTfIdOrder257v | vk01 six package subroutines each with its own scalar typedef, cloned into one wildcard importer; vk02 two wildcard importers of one package |
| G | § defGenLhsSelIdxThroughBase257 | vg02 function-call index; vg03 parenthesised identifier; vg04 member after the select; vg05 and vg06 indexed part selects of elements; vg07 concatenation target; vg08 conditional index; vg09 parameter identifier; vg10 unary; vg11 product plus one; vg12 part select with operation bounds; vg13 macro index; vg14 interface; vg15 CRLF; vg16 up and down part selects with operation bases |

Two first drafts were illegal SV and are not delivered: an unpacked target with a non-constant index, and a macro
naming a port the child lacks. Both read SLANG_FAIL on every binary.

**The final grid** (`drivers/vgrid.sh`, `evidence/vgrid.txt`, `evidence/vsum.txt`) covers these 75 cases, r11u257's
64, v11u255 F (9) and r11u255 F (12): 160 cases, 320 case-views, 8 configurations, 2560 lines, **every line rc=0**.

* fix vs pristine: **223 move, 111 enter STRICT_EQUAL, none leave**, and no case-view leaves judge-equal.
* fix vs law: 16 move, 9 enter STRICT_EQUAL, none leave. These are exactly vc06, vc18, vc19, vc21, vr03, vr17,
  vr18 and vk02, in both views.
* law vs pristine: **4 leave STRICT_EQUAL** (vr03 and vr17, both views) and **3 leave judge-equal** (vc06, vc18 and
  vc19, elaborated). These are the breaks.
* `R11V257_OFF`: the law's bytes on 320 of 320. `R11U257_OFF`: pristine's bytes on 309 of 320; the 11 others are
  all F cases with the first-writer coin in pristine (single draws).
* Each switch moves only its own refinement's cases and gives the law's bytes there:
  * `R11V257_ADDKIND_OFF`: the 8 C case-views;
  * `R11V257_HCORDER_OFF`: the 6 R case-views;
  * `R11V257_CLONETFORDER_OFF`: the 2 K case-views.
* **Away census** (`evidence/away_grid_fix_vs_pristine.txt`, `away_grid_fix_vs_law.txt`): lost=0 on all 223 and all
  16 movers.
  * Stage-1 views gain 1 to 3 dump lines; uhdm-cmp's printed block grows on vc06, vc18 and vc19 default (36 -> 52,
    the r11u257 c05 effect: the bound constant is fixed and the next block printed is longer).
* **Downstream on the 69 fresh R, P, C, G and K cases** (`evidence/ds_{pristine,law,fix}.txt`): 65 IDENTICAL and 4
  EQUIVALENT (vp05, vr01, vr07, vr19), the same verdict on all three binaries.

What the fresh cases show per law:
* **§ fwWinnerSpecTieBreak257**: deterministic in 30 draws on vf20 (same-named class arguments, where pristine
  reads two hashes). vf21 moves and stays equal.
* **§ fwWinnerSpecKind257**: vf24 (struct default) moves toward golden, stage 1 on both (dist 80 -> 58, lost 0).
* **§ implicitPortTsFirstDim257**: ten of twelve shapes go to STRICT_EQUAL in both views. vp01 and vp02
  (parameters) are a stage-1 face on both binaries, unmoved. vp05 (`var`) moves with lost 0.
* **§ defGenLhsSelIdxThroughBase257**: vg08, vg11, vg13 and vg15 go to STRICT_EQUAL in both views, vg10 in the
  elaborated view. vg02 and vg16 move toward golden.
* **§ genLpFoldLeftOperandSpan257**: every elaborated binary-bound shape goes to STRICT_EQUAL.

## 5. Determinism

* **Final fix** (`evidence/det_fix.txt`, r11u257's det.sh: three rounds of three concurrent harness draws on
  Earlgrey_0_1 and the five UVM rows in both modes): one hash per row-mode on 11 of 11 in 9 draws, each equal to
  the final sweep's. Scoreboard testflags writes no database.
* **Law** (`evidence/det_law.txt`, one round): 10 of 11 read one hash. **SeqDriver testflags read a second hash in
  1 of 3**. § 3.3 decodes and fixes it.
  * The sorted uhdm-dumps of the two draws are identical. The ordered diff is 38 lines: two unparented
    `uvm_reg_byte_en_t` copies swap places.
  * The draw counts per configuration are in `evidence/det_seqdriver.txt`.
* **SeqDriver testflags, final fix**: 90 of 90 draws read one hash.

## 6. Residues, ranked

1. **The address-ordered loops not yet sorted.** § cloneTfIdOrder257v sorts the one loop the trace found.
   pristine reads one hash in 132 SeqDriver draws only by heap luck. Any other loop over a pointer-keyed container
   that mints objects can flip the same way when a change perturbs the allocator. A grep for range-for over
   `std::set<const UHDM::` and `std::map<const UHDM::` containers that mint is the next determinism audit.
2. **The fold size** (§ genLpFoldAddUint257's site). `vpiSize` is the larger operand size in reduceExpr: 32 for two
   int parameters, the literal's own size for a sized literal. The site writes 64. This leaves C/vc03 (`AW+BW`)
   and vc21 (`AW+4'h1`) stage 1 on every binary.
3. **§ ifacePortMemberHighConnParent257 on interface and program children.** high_conn_ handles
   paInterface_instantiation and paProgram_instantiation as well, but the walk visits module instances only. R/vr01
   and vr02 are STRICT_NOTEQUAL type on every binary.
4. Two interface ports bound to the same instance (R/vr05) are told apart by the bound instance only, so the law
   abstains. vr05 is equal on every binary.
5. The default-view stage-1 face of the generate localparam fold (C, all default views; unchanged by the fix).
6. The implementer's residues stand as reported. These include Rggen #27671 and Earlgrey's ground-A records
   (ExprEmit), the TaskFuncEmit return branch (§ classTdRetSharesTypedefTs200) and the sister-ground faces:
   * BuildUVMPkg #194627: ExprEmit § shellCallKeepsItsSyntax167.
   * Earlgrey #154375 / #165002: § selFold9.
   * Earlgrey #136315 / #137760: § sysFuncArgFold.
   * SimpleUVM #203342: ParamEmit, the imported-parameter mint.
   * MiniAmiq / SeqDriver #87036: StmtEmit.
   * BlackBePipeInt #190646: ParamEmit importedFold.

## 7. Process

* **The fence.**
  * Every case path, corpus path list (mirrors, probe and downstream byte lists, cmds.txt audit) and census was
    filtered by $FENCED (from tools/probe/r11u107repro/canaudit.sh's FENCED= line) before any file was opened.
  * The corpus census and the harness runs dispatched through fixed name filters or the fence-built filter.
  * No fenced source or database was read.
* **The premature sweep.** One sweep of the c38167e0 fix was started before the mover prediction was frozen. It was stopped within
  a minute, before any result was read.
  * The processes were found by their working directory (my own worktree) and checked by their command line for
    this pass's paths before they were signalled. No other process was listed or signalled.
  * The partial workdir was removed. The census ran, `evidence/prediction.txt` was frozen, and the sweep was rerun.
  * The prediction held:
    * no corpus, probe or downstream database moves fix vs law. The candidates Rggen d, t8 and t9 did not move
      either; their reorder leaves the last writer unchanged.
    * the fix vs pristine movers are the law's.
  * The final fix's prediction (`evidence/prediction_final.txt`) was frozen before its sweep. All 4 corpus and 2
    probe movers are among its named candidates.
* **An unset tool variable.** One dump command ran in a shell without the pins sourced. bash reported
  `pristine.uhdm: command not found` (a bare name, so nothing was executed) and wrote only the intended redirect file
  inside my scratch. Every later dump went through `drivers/dump.sh`, which checks the tool with [ -x ].
* **No helper fence.** r11u257's `drivers/awaydump.py` has no $FENCED check of its own. Its callers pass only case
  databases.
* **Measurement-only builds.** The `exp` and `dbg` builds were compiled in the scratch worktree
  `/tmp/wt_v11u257chk`. The edits made for the `exp` build in the law worktree were reverted from a saved copy
  before the next build, and the delivered TypeEmit was checked against the law's TypeEmit: the only difference is
  § cloneTfIdOrder257v.
* **Corpus database reads.** Reads of MiniAmiq, SeqDriver and Rggen databases (all unfenced) went through fixed
  names.
* **Paths.** Every file was written under `/tmp/wt_v11u257`, `/tmp/wt_v11u257pris`, `/tmp/wt_v11u257chk` or
  `/tmp/v11u257_*`.

## Files

* `cases/` (F, R, P, C, G, K).
* `drivers/`:
  * `env.sh` sources r11u257's env.sh, so the fence is fail-closed.
  * `vgrid.sh`, `vsum.py`, `controls.sh`, `ds.sh`, `census.sh` and `dump.sh`.
  * Each driver resolves its paths from the repository. B holds pristine, law, fix and uhdm-strictcmp; S is the
    scratch root.
* `evidence/`: as cited above.
