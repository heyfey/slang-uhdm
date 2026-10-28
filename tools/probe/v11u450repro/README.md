# v11u450 — adversarial verification of r11u450

Base 57706919e, the implementer's patch /tmp/r11u450.patch (module/type ground:
src/UhdmExporter.cpp, src/ModuleEmit.cpp, src/TypeEmit.cpp). Verifier worktree
/tmp/wt_v11u450.

## Verdict

CONFIRMED. No break was found and there is no production change. The verified
patch's source diff is byte-identical to the implementer's. It adds only this
directory and the regenerated tests/LAWS.md.

Four sv-tests rows convert. Fresh rows from this verifier's own sweep on the law
binary:

| row | base (master control) | law (fresh svtests.csv row) |
|---|---|---|
| generated/uvm-examples/uvm_messaging_example.sv | STRICT_NOTEQUAL differ:file(5) | `EQUAL,,equal` |
| generated/uvm-examples/uvm_priority_arbitration.sv | STRICT_NOTEQUAL differ:file(5) | `EQUAL,,equal` |
| generated/uvm-examples/uvm_priority_grab_lock.sv | STRICT_NOTEQUAL differ:file(5) | `EQUAL,,equal` |
| generated/uvm-examples/uvm_use_models_unidirectional.sv | DIFFERENT (decompile) | `EQUAL,,equal` |

The runner on those four rows alone (evidence/rows4_runner.txt):
- pristine: JUDGE_EQUAL differ:file(5) on the three rows, and NOTEQUAL on
  unidirectional;
- law: EQUAL, equal and IDENTICAL on all four.

## Binaries

- pristine: /tmp/v11u450_bin/pristine, a copy of the main tree's build/slang-uhdm
  (md5 cf09f0be76a18f7e3e6ff99a43f2ab89). No pristine build, per the budget.
- law: /tmp/v11u450_bin/law, built once from the implementer's patch on
  57706919e (md5 ae1709859a3c1ce1cf9b271909aee0f0). This equals the implementer's
  law12, and the binary reports slang 12.0.0+545f88b2e.
- There was no verified build.

## Gates: one five-stage sweep on the law binary (/tmp/v11u450swl, after three quiet readings)

| stage | result | byte movers vs the master's control /tmp/intr11u449 |
|---|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087; regressions=0 conversions=0 changes=0 | 0 of 4087 by path-normalized dump (comparator control: two different databases differ, the same database under the two path roots agrees) |
| surelog | default 480, testflags 474 CMP_EQUAL; 0/0/0; Tnoc d/t CMP_NOTEQUAL standing | 4 of 962 (self-check 961) |
| uhdm2rtlil | 803 / 1 / 67 in both modes; 0/0/0 | 0 of 1608 (self-check 1607) |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 | 0 of 805 (self-check 804) |
| sv-tests | EQUAL 1920, STRICT_NOTEQUAL 0, DIFFERENT 20, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=4 changes=0 | — |

- **Surelog movers:** MiniAmiq default and testflags, and SeqDriver default and
  testflags. These were the four predicted by name (law 3,
  § cloneVarSelBind450). The hashes equal the implementer's:
  - MiniAmiq d/t 89ef2145c577
  - SeqDriver default cb044a2c33df
  - SeqDriver testflags 0c627ab6bffd
- **These rows stay STRICT_EQUAL.** uhdm-strictcmp on the swept databases reads
  435559, 435559, 475526 and 475538 objects.
- **The added bindings match golden.** On MiniAmiq default, the dump diff
  against the control is exactly 12 added `vpiActual -> io_decl (value)` lines,
  at uvm_packer 730:47, 762:45, 948:49 and 978:47. On those four io_decls,
  golden holds 24 bindings, the law 24 and pristine 12.
- **CSV comparison:**
  - Every csv equals the implementer's sweep.
  - Against the control, every csv is equal apart from:
    - the four converted sv-tests rows;
    - the two LowMem log-path texts in surelog.csv.
- **Canaries:** ok=52 and ok=16, changed 0. ctcan2 PASS with EXPECT_UNKNOWN=1
  and with EXPECT_UNKNOWN=6.
- **Binary audit,** fence-filtered:
  - surelog: 1523 of 1573 records name /tmp/v11u450_bin/law; the other 50 hold
    only a Surelog line;
  - uhdm2rtlil: 1740 of 1740;
  - sv-tests: 2346 of 2346;
  - no record names another binary.
- **Determinism:** three concurrent law runs of MiniAmiq default and of SeqDriver
  testflags from the sweep's cwd read the sweep's hash, 4 of 4 each.
- **Sweep layout:** the corpus stages ran from the worktree. The sv-tests stage
  ran alone afterwards, on the same binary and workdir, through the main tree's
  scripts/check_svtests.py against the worktree's results/golden_svtests.csv,
  because the worktree's UVM submodule is empty. The driver is
  drivers/fullsweep.sh.

## The implementer's grid, reproduced

All 51 implementer case dirs were run on pristine and law (evidence/impl_grid.txt).
Exit code, uhdm-cmp count, strict verdict and moved/same agree with
evidence/grid_law12.txt on 51 of 51. The md5s differ only because the source
path differs. Every exit code is 0.

## Attack grid: 65 fresh case dirs

Every case is accepted by upstream slang (~/.local/bin/slang --single-unit). One
vx02 draft used a nonblocking write to an automatic variable, which slang
rejects; it was rewritten as a static task before any run.

The groups:
- VA (9): § clsAssocVecIdxTs450 — ascending and leading-zero bounds, spaced
  brackets, a parameterized class, static/rand, inner and outer associative
  dimensions, unsigned/signed/scalar keywords, inheritance, an initializer, a
  class in a package imported by another, classes in an interface and a program.
- VF (2): § fwListedQualNameMatch450 — two importers specializing the registry,
  and a non-socket class.
- VG (5): § importGroupOrderIfaces450 — interface-own subroutines with the group,
  instances in a generate loop, nested interfaces, a direct and an indirect
  import, an uninstantiated interface.
- VO (5): § cloneOwnCopyAtHomeListing450 / § cloneArrElemAggAtHomeListing450 — a
  union, two importers, in-class (non-extern) bodies, an enum-free struct with
  fixed/queue/packed arrays, the typedef in an included file.
- VP (15): § ifcAnsiLogicPortNet450 — output int/bit, time, packed structs with
  int or logic fields, an unpacked output array, `output var logic`, two instances
  plus a generate instance, continuous-assign drivers, reg and signed, enum and
  typedef ports, a modport consumer, an always_ff/function driver, module ports
  passed through, a non-ANSI header, an interface array, a synthesizable counter.
- VT (9): § ifcBodyImpTransitiveTds450 — two instances, uninstantiated with and
  without a top, a three-level chain, two transitive packages plus a plain
  package, an own typedef in the interface, a port typed u::nib_t in a generate
  block, `export u::*` with a class, a modport consumer.
- VW (10): § ifcTaskFixupWalksStmts450 — a formal named clk, a task-local
  shadowing an interface variable in while, a for over a parameter, repeat over
  a variable, delays and iff/or events, a function while plus forever, a
  task-local clk, generate instances, a for-loop variable shadowing an interface
  int, a formal shadowing an interface variable inside while.
- VX (10): § cloneLhsIdxPartSelBind450 / § cloneVarSelBind450 — package
  variables, a static task with <=, += and |=, parameter and localparam bases,
  block-local shadowing, a static local, a concatenation left side, if and for
  bodies, class out-of-body methods, diamond importers, struct members and
  unpacked arrays, ref and inout formals, a module-side control.

Results, pristine -> law (evidence/attack_grid.txt; exit code, uhdm-cmp lines,
dump distance, strict verdict, md5):

- **Exit codes:** every code is equal on both binaries. Every case is 0 except
  VA/va04 (an inner associative dimension), which is 4 on both: a pre-existing
  goal-1 face, see the residues.
- **To STRICT_EQUAL: 38.** These are va01–va03, va05–va09, vg01, vg02, vg05,
  vo05, vp02, vp05–vp08, vp11, vp12, vp15, vt01, vt02, vt04, vt07–vt09,
  vw01–vw05, vw08–vw10, vx02–vx04 and vx07.
- **Moved with the same verdict, closer or with the head later: 16.**
  - va04 (dist 236 -> 212), vf01 (94 -> 88), vg03 (301 -> 285), vo01
    (1008 -> 994).
  - vo04: the copies take golden's spans. Span counts at 11:45 are 12 -> 10 with
    golden at 10, and at 14:39 35 -> 41 with golden at 41.
  - vp04 (176 -> 170), vp09 (cmp 60 -> 17).
  - vp10, vp14 and vt06: uhdm-cmp grows only because the first difference
    moved later.
    - vp10 goes from the f net to the modport port's interface_inst;
    - vp14 goes to the module_array;
    - vt06 goes from the definition to the generate-block instance.
  - vt05 (cmp 446 -> 251), vw06 (dist 146 -> 86), vw07 (95 -> 65).
  - vx05 and vx08: STRICT_NOTEQUAL on the same field, with the distance down.
  - vx09: STRICT_EQUAL on both, with formal bindings added (dist 106 -> 94).
- **Byte-identical: 11.** These are vf02, vg04, vo02, vo03, vp01, vp03, vp13,
  vt03, vx01, vx06 and vx10.
- **None moved further on the strict axis.**

Switches (evidence/attack_switches.txt):
- `R11U450_OFF` gives pristine's bytes on 65 of 65 attack dirs, as well as the
  implementer's 51.
- Each mover's own switch alone restores pristine, except the measured pairs:
  - VW vw02–vw05, vw09 and vw10 need IFCFIXWALK and IFCPORTNET together;
  - vw01, vw06 and vw07 move on IFCPORTNET alone;
  - vo04 moves on ARRELEMHOME, with OWNCOPYSPAN placing the copy;
  - vx02 and vx07 need IDXPSBIND and VARSELBIND.

Downstream, on the 34 class-free VP, VW and VT dirs
(evidence/attack_downstream.txt):
- 18 go EQUIVALENT -> IDENTICAL: vp02, vp05–vp12, vp15, vw01–vw06, vw09 and
  vw10.
- The rest keep their verdict. vp04 is STATUS_DIFF on both (Surelog READ_FAIL on
  the unpacked output-port array). vp14 is STATUS_DIFF on both (the slang lane's
  READ_FAIL on the interface array).
- No verdict moves away from IDENTICAL.

## Residues (all wrong on pristine too; none moved away)

1. **The implementer's ranked residues stand:**
   - bidir_get_put, bidir_item_done and pipelined_get_put;
   - the three sfr_scoreboard rows at the class typedef listing;
   - param_vif_config_db, id_register, many_to_one, generation_seq_* and
     test_init;
   - easyUVM, the 3 scoreboard rows, p733, p737 and tnoc.
2. **VT/vt03:** an interface importing a package that reaches typedefs through a
   two-level chain (b imports a imports u). The law abstains because it looks
   one level down. It is byte-identical and NOT_EQUAL on both.
3. **VA/va04:** an associative dimension inside or after another dimension
   (`int a[bit[7:0]][bit[3:0]]`, `int c[2][bit[7:0]]`). This exits 4 on both
   binaries. It is a goal-1 face on this ground, decoded neither here nor by the
   implementer.
4. **VP/vp03:** a packed-struct output port with an int member. It is
   byte-identical and NOT_EQUAL on both: the struct branch returns before the port
   rule.
5. **VP/vp04 and vp14:** unpacked output-port arrays and interface arrays. Both
   are NOT_EQUAL and STATUS_DIFF downstream on both binaries.
6. **The sister ground (reported, not written):** ExprEmit's full name of an
   indexed part-select inside a var_select (the implementer's ix13 and
   ix17–ix19; VX/vx08 is STRICT_NOTEQUAL on fullname on both binaries).

## Process

- **Budget:** one law build, no verified build, and one five-stage sweep on the
  law binary. The four rows were rerun alone on both binaries. There were three
  determinism draws per row.
- **Slip (timing only, no measurement affected):** the first attack batch ran
  through the pristine and law binaries while the sister v11u451's full sweep was
  live. It ran one process at a time, during their surelog stage. Every later
  batch, and this verifier's sweep, ran after three quiet readings.
- **Fence:** the fence list was read by a program into /tmp/v11u450_fence.txt
  and never printed. The cmds.txt audit list was filtered on it before any file
  was opened. No fenced test was named, opened or run.
- **No other agent's process was touched.**
- **Drivers:** run1.sh (one case: golden cached per case text, the full repro
  path as the key), grid.sh, sw.sh (R11U450_OFF and per-law switches), ds1.sh
  (downstream for one case), join.py, probedump.sh (path-normalized probe dump
  compare), fullsweep.sh, waitquiet.sh and det3.sh.
