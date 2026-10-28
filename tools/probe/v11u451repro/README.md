# v11u451repro — adversarial verification of r11u451 (pass 451, expression/parameter ground)

Base 57706919e. Implementer patch /tmp/r11u451.patch; verified patch /tmp/r11u451.verified.patch.

## Verdict

**CONFIRMED with three production refinements (four switches). No break was found:** no
legal-SV case where pristine was right and the law is wrong. The refinements fix overreaches
of two laws on shapes where pristine was also wrong. In each, the law's dump distance moved
away from golden: VT/vt07, vt09 and vt14 for the task-value law, and VL/vl01 for the leftover
net.

- The implementer's headline numbers reproduce exactly.
- No sv-tests row changes status on the law binary or on the verified binary. Both read
  regressions 0, conversions 0, changes 0 in all five stages.
- uvm_test_init and the three uvm_generation_seq rows stay DIFFERENT. Their uhdm-cmp head moves
  off the diamond-import package listing:
  - uvm_test_init: package test_top_pkg -> class_defn top_vseq_pkg::top_vseq_base;
  - poly: package test_lib_pkg -> class_defn bus_seq_lib_pkg::bus_seq_base.

  Both new heads are the sister's ground.

## Reproduction

- **Law binary:** rebuilt from the patch on a fresh 57706919. Its md5 01804187a7028f357251db94512545f7
  equals the implementer's law9; it links slang 12.0.0+545f88b2e. Frozen at /tmp/v11u451_bin/law.
- **Pristine:** the main tree's build/slang-uhdm (cf09f0be76a18f7e3e6ff99a43f2ab89), frozen at
  /tmp/v11u451_bin/pristine. It was used for case runs only; the pristine sweep is the master's
  control /tmp/intr11u449.
- **The implementer's 29 grid case dirs** reproduce on exit code, uhdm-cmp line count and strict
  verdict on all 29 (evidence/impl_grid_reproduced.txt). `R11U451_OFF` gives pristine's bytes
  and exit code on 29 of 29.
- **Non-production correction:** NM/nm01's first line named a law that does not exist
  (`nestedModUndeclReadNet451`). It now reads `nestedModUndeclReadBare451`.

## Law sweep (one five-stage sweep on the law binary, after three quiet readings; drivers/fullsweep.sh)

- **Results:**
  - probe 4023 + 64, 0/0/0;
  - surelog default 480 / testflags 474, 0/0/0;
  - uhdm2rtlil 1606 + 0, 0/0/0;
  - downstream IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0;
  - sv-tests EQUAL 1916, STRICT_NOTEQUAL 3, DIFFERENT 21, BOTH_REJECT 303, SURELOG_ONLY 75,
    SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, 0/0/0.
- **Comparison with the master's control:**
  - every csv equals the control's, except the two LowMem log-path texts in surelog.csv;
  - byteverify finds 0 of 962, 0 of 1608 and 0 of 805 movers; the self-checks flag 961, 1607
    and 804;
  - the probe databases are identical to the control by path-normalized dump: 0 of 4087
    (drivers/probedump.sh; positive control: a different case's pair is flagged).
- **Canaries:** ok=52 and ok=16; both ctcan2 checks PASS.
- **Binary audit (fence-filtered):**
  - surelog: 1523 of 1573 records name the law binary; the other 50 hold only a Surelog line;
  - uhdm2rtlil: 1740 of 1740;
  - sv-tests: 2346 of 2346.
- **The corpus stages exit 1 on the stale law index alone.** The index was regenerated last, in
  the patch.
- **Trace:** the sv-tests rows where the laws fire are exactly the implementer's 15 (the 14
  uvm-examples rows and generated/rsd/rsd; evidence/law_sweep_trace_rows.txt). There are no
  firings in probe, surelog, uhdm2rtlil or downstream.

## Attack grid (cases/, 50 case dirs; drivers/run1.sh)

Every case is accepted by upstream slang with the same sources and --single-unit. Exit code,
uhdm-cmp line count and strict verdict for pristine -> law -> verified are in
evidence/grid_*.txt; dump distance (path-normalized line count) is in
evidence/dumpdist_pristine_law.txt.

- **VD (8), the diamond listing:**
  - vd01, vd05 (a 5-level doubling diamond: 45784 -> 9160 dump lines, strict 7866 objects),
    vd06, vd07 and vd08 go NOT_EQUAL -> STRICT_EQUAL;
  - vd02 and vd03 are closer: vd02's head moves from package c to the module;
  - vd04 (two separate import items) is byte-identical STRICT_EQUAL.
- **VA (6), param_assigns per path:**
  - va05 goes to STRICT_EQUAL;
  - va01 to va04 are closer;
  - va06 (an explicit import in the middle, `import a::PA`) is byte-identical: the implementer's
    DI/di04 residue.
- **VL (12), leftover nets:**
  - vl02, vl03 (an explicit and a wildcard import of one package in one package), vl04
    (reg/logic typedefs, reg, bit), vl06, vl07 (class and string arrays) go to STRICT_EQUAL;
  - vl10 goes to STRICT_EQUAL on the verified binary, where the law read STRICT_NOTEQUAL endcol;
  - vl05 is closer;
  - vl08 (`import a::*` written twice: the implementer's dn02 residue) is closer;
  - vl01, vl09, vl11 and vl12 move toward golden through the refinements and stay NOT_EQUAL on
    pre-existing var-listing faces.
- **VN (10), nested-module reads:**
  - vn01 to vn04 and vn06 to vn08 go from exit 4 to STRICT_EQUAL. These cover: an outer module's
    net declared after the nested module, a continuous assignment, a function body, an outer
    typedef read as a value, `default_nettype none, two nested modules, and a nested module that
    is never instantiated;
  - vn09 (an enum constant in a nested block) goes from exit 4 to exit 0 and is closer: § 447v's
    enum face;
  - **vn05 (a parameter declared after the read) stays exit 4.** This is a goal-1 face that is
    still open;
  - vn10 is a control and is byte-identical.
- **VT (14), task names read as a value:**
  - vt01, vt04, vt05, vt06 (a package task imported by wildcard), vt10 and vt12 go to
    STRICT_EQUAL;
  - **vt07, vt09, vt11 and vt14 MOVED AWAY on the law and are STRICT_EQUAL on the verified binary**
    (see the refinements);
  - vt02 (a task with a defaulted argument), vt03 (a read inside a function body), vt08 (a task
    in a nested module) and vt13 (a `generate` region; golden bare, the law does not fire) are
    byte-identical residues.
- **Downstream (evidence/downstream_*.txt):** on all 50, pristine 48 IDENTICAL + 2 EQUIVALENT;
  law and verified 49 + 1. va05 goes EQUIVALENT -> IDENTICAL. No verdict
  moves away.
- **Switches:**
  - `R11U451_OFF` gives pristine's bytes on 50 of 50;
  - `R11V451_OFF` gives the law's bytes on 50 of 50;
  - each refinement's own switch restores the law's bytes on the cases only it moves (vt07,
    vt09, vt11, vt14, vl10, vl11, vl12);
  - vl01 and vl09 move under two refinements and read mixed with one switch.

## Refinements (verified patch; read through src/LawSwitch.h `fixOn(451, ...)`, so `R11U451_OFF` drops them with their law and `R11V451_OFF` gives the law's bytes)

1. **§ taskValBareRefGenNone451v** (ExprEmit, inside § taskNameReadImplicitNet451)
   - **Rule.** Surelog mints no wire, and the read stays a bare ref_obj with no vpiActual, in two
     places:
     - (a) a read inside a generate block (if, for or case generate), switch
       `R11V451_TASKVALGEN_OFF`;
     - (b) a module under `default_nettype none` (§ noneNetTypeBareRef447v's rule), switch
       `R11V451_TASKVALNONE_OFF`.
   - **Effect.** The law minted `logic_net work@m.t`, which moved the dump distance away
     (vt09 3 -> 9, vt07 5 -> 9). On the verified binary vt07, vt09, vt11 and vt14 are
     STRICT_EQUAL.
   - **Detection.** The definition view writes a generate block's processes with the module body
     as the current scope, so the generate test also walks the expression's syntax parents. The
     first verified build checked the scope only and never fired; that build is
     /tmp/v11u451_bin/ver_unswept_v1, which was not swept.
2. **§ leftNetVarKwNoType451v** (ParamEmit, § pkgDupSignalLeftoverNet451's net type), switch
   `R11V451_LEFTVARKW_OFF`
   - **Rule.** A declaration written with the `var` keyword gives no vpiNetType in golden:
     `var logic [1:0] vv`, `var reg [1:0] vr`, `var logic signed [3:0] vs`. `static logic st`
     keeps 36.
   - **Effect.** The law wrote 36 or 48.
   - **Cases:** VL/vl01, vl09, vl12.
3. **§ leftNetInitEnd451v** (ParamEmit, the leftover net's anonymous typespec), switch
   `R11V451_LEFTINITEND_OFF`
   - **Rule.** For a variable written with an initializer and no unpacked dimension, golden's
     writeNets stretch ends at the END OF THE INITIALIZER:
     - `int vi = 5;` 2:12-2:22;
     - `logic [3:0] li = 4'h3;` 2:24-2:45;
     - `int x1, x2 = 3;` gives only x2 2:12-2:26;
     - `logic [1:0][3:0] pm = '0;` 3:52-3:76.
   - **Scope.** An unpacked dimension keeps § pkgNetTsDimEnd274's end (`int ua2 [2] = '{1, 2}`
     2:58 in both). A named typedef element is left alone (golden keeps `n_t`'s own span). An
     initializer written by a macro abstains (vl11's `INIT, residue).
   - **Effect.** vl10 goes STRICT_NOTEQUAL endcol -> STRICT_EQUAL. In the verified sweep the
     refinement fires on the 14 uvm-examples rows only (580 trace lines), and none of them
     changes status.

## Verified sweep (one five-stage sweep on the final verified binary, md5 5d37a07f4c3c9bcd40c486fc8df12955, after three quiet readings)

- **Prediction, written before the sweep** (evidence/prediction_before_verified_sweep.txt): the
  movers against the law sweep are a subset of the 15 leftover-firing rows, 0 in the four
  corpus stages, and no sv-tests status change.
- **Results:**
  - the same counts as the law sweep in all five stages, 0/0/0 each;
  - the csvs equal the law sweep's, except the two LowMem texts;
  - byteverify against the law sweep and against the control: 0 of 962, 0 of 1608, 0 of 805;
  - probe: 0 of 4087 byte movers against the law sweep.
- **sv-tests byte movers, verified vs law** (the database embeds the workdir path, so the
  comparison rewrites `/tmp/v11u451swv/svt` to `swl`, allowing for packing tags; a different row
  is flagged as the positive control; evidence/svtests_byte_movers_ver_vs_law.txt):
  - **exactly the 14 predicted uvm-examples rows:** uvm_ac_config_db, uvm_ef_vif_config_db,
    uvm_generation_seq_persistence, poly and randomization, uvm_id_register, uvm_many_to_one,
    uvm_overriding, uvm_param_vif_config_db, uvm_slave_agent, uvm_slave_agent_multi_seq_item,
    uvm_test_init, uvm_use_models_pipelined_get_put and uvm_vif_config_db;
  - the other 31 kept databases, rsd among them, are unchanged;
  - no status moved.
- **Trace:** `leftNetInitEnd451v` fired on those 14 rows (580 lines). `taskValBareRefGenNone451v`
  and `leftNetVarKwNoType451v` fired nowhere in the sweep.

## Residues (ranked; all wrong on pristine too)

1. The diamond rows' class-listing heads are on the sister's ground (the implementer's
   sister-ground list stands).
2. **VN/vn05, a goal-1 face.** A parameter declared after its read in a nested module exits 4.
   The law abstains on any declared name and the parameter path has no writer.
3. **VA/va06 and DI/di04.** An explicit import in a middle package is missing from the
   importer's parameter vectors.
4. **VL/vl08 and DN/dn02.** A wildcard import written twice is listed once.
5. **Task values the law does not reach:**
   - vt02: a task with a defaulted argument;
   - vt03: a read in a function body;
   - vt08: a task in a nested module;
   - vt14: golden names the ref `c1.t` where ours writes a scoped name (strict equal, dump only).
6. **The leftover net of a macro-written initializer** (VL/vl11 mv: golden's columns are in
   expanded-text coordinates, 3:88).
7. **A dimension end on a line shifted by an earlier macro** (vl11 `un`: the § 274 stretch writes
   the raw column 128 where golden has 124). This is pre-existing in § 274.
8. **Pre-existing package var-listing faces** that the leftover copies now repeat once per path:
   - `var x` with an implicit type, where golden writes no typespec (vl01, vl11);
   - `var int` signing (vl12);
   - the unpacked-array initializer's vpiExpr (vl09).

## Process

- Builds: the law build (md5 equal to law9), the first verified build (not swept), and the
  final verified build.
- **Budget slip.** That is THREE builds where the budget allows two: the second build's
  generate test never fired, and shipping a refinement with dead code was not acceptable.
  Sweeps: one on the law binary and one on the final verified binary, never overlapping
  another sweep.
- The sv-tests stage ran through the main tree's scripts/check_svtests.py with
  `--baseline <worktree>/results/golden_svtests.csv`, because the worktree's UVM submodule is
  empty. The script is identical in both trees.
- The fence list was read into a file by a program and never printed. Every tree-wide list was
  filtered on it first. No fenced test was named, opened or run.
- No other agent's process was touched.
