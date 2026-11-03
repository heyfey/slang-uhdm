# r11u481 — expression/parameter ground: virtual-interface typedef locals and spans

Pass 481 of the sv-tests campaign on the expression/parameter ground (src/ExprEmit.cpp,
src/ParamEmit.cpp; StmtEmit.cpp, EmitHelpers.h and every sister file unchanged), on base
24db9b73b (pass 479). Measured under the measurement budget: the pristine reading is the
master's control /tmp/intr11u479; one full five-stage sweep; byteverify against the control.

## Verdict

- NO sv-tests row converts, no row changes: the sweep reads EQUAL 1935, STRICT_NOTEQUAL 0,
  DIFFERENT 5, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1
  of 2346, regressions 0, conversions 0, changes 0, the csv equal to the control row for row.
- The two target rows at this base (pass 474 has not landed on it):
  `generated/uvm-examples/uvm_param_vif_config_db.sv` DIFFERENT -> DIFFERENT, and
  `generated/easyUVM/top.sv` DIFFERENT -> DIFFERENT. No law of this pass fires on either
  row (the traced census writes no trace for them), and both databases are byte-identical
  to pristine. Their heads are the sister's: the this_t / SFR_agent_t vpiInstance face and
  ModuleEmit's ref_module face. No open row has its head on this ground, so this pass
  works the ground's residue backlog: pass 479's vif-typedef residues.
- Three laws and one extension, all firing on NO corpus row, probe case or sv-tests row.
  The grid has 82 case dirs. Pristine reads STRICT_EQUAL 16, STRICT_NOTEQUAL 6 and
  NOT_EQUAL 60; law6 reads STRICT_EQUAL 62, STRICT_NOTEQUAL 2 and NOT_EQUAL 18. 46 dirs
  move to STRICT_EQUAL and 6 more move closer. The away census finds 6 external movers,
  all toward golden: pass 479's residues v11u479 VA/va07, va15, VL/vl03 and r11u479
  LV/lv07, lv09 move to STRICT_EQUAL, and v11u447 VN/vn20 moves closer.

## Laws (each read through src/LawSwitch.h; R11U481_OFF drops them all)

### § pkgVifTdParamNameSpan481 (ParamEmit; R11U481_VIFPARAMSPAN_OFF; cases VS)

A package typedef written with BOTH parameters and a modport,
`typedef virtual ifc #(8).mp vt_t;`, spans the interface name alone in golden (4:19-4:22).
The typespec builder (TypeEmit's VirtualInterfaceTypeSyntax branch, reached through
`makeTypespec`) ends it at the modport (4:30). With parameters only (`ifc #(8)`, vs02,
vs05) golden and the builder agree on the name alone. With a modport only (`ifc.mp`, vs03)
they agree on name.mp. The law resets the span in emitPackage's § pkgVirtIfaceTd479
branch and in the importer-clone site. Every copy (net copies, local copies) reads its span
from these objects.
Grid: vs01, vs04 (`virtual interface ...`), vs06 (spaced) and vs07 (a local) move
STRICT_NOTEQUAL endcol -> STRICT_EQUAL. vs08 moves STRICT_NOTEQUAL endcol -> depth (dump
distance 31 -> 13, residue R3). Controls vs02, vs03, vs05, vs09 and vs10 are
byte-identical. External: v11u479 VA/va07 moves STRICT_NOTEQUAL endcol -> STRICT_EQUAL.

### § vifTdRefVarLocalImplicitNet481 (ExprEmit; R11U481_REFVARNET_OFF; cases RN)

A reference in a module or interface process to a statement-block local that is a
`ref_var` binds the implicit wire Surelog mints. The main case is the virtual-interface
typedef local of § vifTdLocalIsRefVar479. A statement-scope typedef local (rn50) and a
`process` / `mailbox` / `semaphore` local (rn39, rn49, rn56) are ref_vars too.

Decode (Surelog src/DesignCompile):
- Compile time: CompileHelper::bindVariable binds such a local only in the window that
  § refVarLocalWindowBinds5 models. The window is an if or assert condition, or an
  argument of a user call written as a STATEMENT, at the declaring unnamed block's own
  control depth (§ 57). Cases: rn03, rn26, rn29, rn34, rn46 and rn63 keep the ref_var
  binding.
- Late binding: every other reference reaches UhdmWriter::lateBinding. Every scope branch
  there skips a ref_var declaration (`if (decl->UhdmType() == uhdmref_var) continue;`), so
  the walk ends at the module-level mint. That mint is a logic_net named like the local,
  with vpiNetType from the default net type, at the FIRST such reference's span; every
  later reference binds it by name.

The positions that mint:
- assignment left side, right side and operands (rn01, rn02, rn04, rn32, rn33)
- $display and $cast arguments (rn05, rn28)
- an argument of a call inside an expression (rn27)
- fork (rn06), a nested begin (rn15) and a named block (rn02, rn23, rn48)
- while conditions (rn24) and nested control depth (rn30, rn66)
- for bodies (rn44), delay and event controls (rn45), wait (rn55), nonblocking (rn51)
- two locals (rn14) and two processes sharing one wire (rn16)
- two instances (rn19, rn47), $unit and module typedefs (rn20, rn21)
- a block local inside a MODULE task (rn41: § refVarLocalNoBind5's bare references walk to
  the module)
- a never-elaborated definition (rn61, rn62, v11u447 VN/vn20)

The wire is placed in source order of first reference among the implicit nets, the rule of
§ undeclaredReadImplicitNet447 (rn59, rn60, vn20 `d` before `DA` and `DB`).

Under `default_nettype none the reference stays bare (rn12). The law abstains:
- in a program, where pass 444's hoist lists the local and golden binds it (rn10)
- in a class method or package subroutine (§ 107 owns those)
- when the instance body declares a member of the same name (rn35 module variable, rn36
  parameter: residue R4)
- on the left side of a written `= new` (rn38, rn40: § 107's fence; law1 broke both, and
  law2 restored them)

Call-argument window refinement (law6): the user-call site raises a side counter only
for a call in statement position (callStmtCtx0). law5 used a syntax walk, which misread
`tk(g);` and broke rn26; law6 replaced it before any sweep.

### § pkgVifLocalInitCopy481 (ParamEmit; R11U481_VIFLOCALINIT_OFF; cases LI, RN/rn18)

A local written with an initializer (`vt_t g = null;`) is parented at its initializing
assignment, in golden too. § pkgVifLocalBareCopy479 looked only at a begin, fork, task or
function parent, so the local bound the package listing `t::vt_t`. It now takes the
bare-named copy (golden `vt_t`). Cases li01, li04 and rn18 move to STRICT_EQUAL; li05 and
li06 need this law together with the implicit-net law. External: v11u479 VL/vl03 moves
NOT_EQUAL 42 -> STRICT_EQUAL.

## Grid (evidence/grid.txt, swcheck.txt, downstream_grid.txt)

82 case dirs in LI (7), RN (65) and VS (10). Every exit code is 0 on both binaries, and
every case's first line names its law.

| | pristine 7347b341 | law6 d5d1fa79 |
|---|---|---|
| STRICT_EQUAL | 16 | 62 |
| STRICT_NOTEQUAL | 6 | 2 |
| NOT_EQUAL | 60 | 18 |

- 46 dirs move to STRICT_EQUAL.
- 6 dirs move closer at the same head, by dump distance:
  - rn27 34 -> 25 and rn66 34 -> 25: the formal face remains (R1)
  - rn57 19 -> 8: the function face remains
  - rn62 61 -> 52: vn20's twin, uhdm-cmp 594 -> 608 lines, both at the same module_inst
    net-vector head with one more net now matching golden
  - rn52 91 -> 82: golden's own database for a ternary over the local is broken (no package
    listed, unsupported_typespec), so uhdm-cmp lines 409 -> 423 at the same first object
  - vs08: STRICT_NOTEQUAL endcol -> depth, dump distance 31 -> 13
- No dump distance grows.
- Switches (law6):
  - R11U481_OFF gives pristine's bytes on 82 of 82 dirs.
  - R11U481_VIFPARAMSPAN_OFF alone restores the 5 VS movers.
  - R11U481_REFVARNET_OFF alone restores the 42 RN movers that only it moves.
  - R11U481_VIFLOCALINIT_OFF alone restores li01, li04 and rn18.
  - li05 and li06 need both REFVARNET and VIFLOCALINIT off.
- Downstream on all 52 movers (50 measured on law4, rn27 and rn66 on law6): 50 IDENTICAL
  on both binaries; rn19 and rn47 move EQUIVALENT (nohier) -> IDENTICAL. None moves away.

## Census, prediction, sweep (evidence/)

- census.tsv: pristine against law3 over 10616 fence-filtered row-modes (probe 4087,
  surelog 789 + 784, uhdm2rtlil 870 + 870, downstream 870, sv-tests 2346), each run from
  the row's own directory with the law binary traced.
  - No exit code moves and no trace is written anywhere. The positive control RN/rn01
    writes `vifTdRefVarLocalImplicitNet481 work@top.g`.
  - One byte mover, uvm_test_init (sv-tests), is a pristine coin: pristine alone reads 3
    hashes in 3 runs (drivers/coin.py).
- prediction.txt: written before the sweep from the census. No mover in any corpus, all
  csvs equal to the control.
- census_law3_law4.tsv: law3 against law4, 10616 of 10616 byte-identical with no firing.
  The law3 -> law6 census is described under the binaries below.
- The sweep is one full five-stage tests/sweep.sh --jobs 3 on law3 with the trace on. The
  four corpus stages ran from the worktree. The sv-tests stage ran through the main tree's
  tests/sweep.sh, because the worktree's UVM folder is empty. The machine was quiet.
  - probe: EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0
  - surelog: 480 + 474, 0/0/0
  - uhdm2rtlil: 803/1/67 in both modes, 0/0/0
  - downstream: 803/66/2/0, not identical and not excused 0
  - sv-tests: as above, 0/0/0
  - Every csv equals the control's row for row after workdir normalization.
  - The sweep's trace directory is empty, as predicted.
- byteverify (SELFCHECK=1) against /tmp/intr11u479: surelog 0 of 962, uhdm2rtlil 0 of
  1608, downstream 0 of 805. The selfcheck flags 961, 1607 and 804. All 4087 probe dumps
  equal the control's after path normalization, with a negative control reading DIFF.
- canaries: ok=52 and ok=16; ctcan2 PASS on both.
- binary audit, fence-filtered: surelog 1523 of 1573 records name law3, and the other 50
  hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346.
- Binaries (binaries.txt):
  - pristine 7347b341, the worktree's first build, byte-identical to the main tree's
  - law3 7cc4f372, the sweep binary
  - law4 05570b23, which adds the order rule; byte-identical to law3 on all 10616
    row-modes
  - law6 d5d1fa79, FINAL, which adds the statement-call counter. The law3 -> law6 census
    (census_law3_law6.tsv) reads no exit-code mover and no firing on 10616 row-modes, and
    10614 byte-identical. The two byte movers are pristine coins: uvm_test_init and
    uvm_id_register (pristine alone reads 1f14321053, 1f14321053, ee7d6b7ac9). So the law3 sweep is law6's sweep: the extra law code never
    runs on a corpus row.
- away.tsv: pristine against the final binary over 422 fence-filtered earlier case dirs
  whose source has a process and a virtual / mailbox / semaphore / process / block typedef
  word. No exit code moves. 6 byte movers, all toward golden:
  - v11u479 VA/va07: STRICT_NOTEQUAL endcol -> STRICT_EQUAL
  - v11u479 VA/va15: NOT_EQUAL 330 -> STRICT_EQUAL
  - v11u479 VL/vl03: 42 -> STRICT_EQUAL
  - r11u479 LV/lv07: 133 -> STRICT_EQUAL
  - r11u479 LV/lv09: 123 -> STRICT_EQUAL
  - v11u447 VN/vn20: dump distance 61 -> 52 at the same head, golden's `d` wire now
    written and ordered; the next face is § nestedProcEnumValAbstain447v's enum-constant
    binding

## Goal 1 (evidence/goal1.txt)

- C::mk().arr[1] (v11u413 VC/vc04) and u.mk(x).a[2] (VI/vi06) exit 4 on both binaries.
  Upstream slang reads 0 and Surelog rejects them, so golden has no shape and nothing is
  forced.
- this.mk().inner.s (v11u415 VT/vt03) exits 0.
- bp_unicore alone, guard on: exit 3 in 14.1 s at 838 MB max RSS. The guard stays.
- None of the 75 SURELOG_ONLY details is the exporter's own message; all are upstream slang
  diagnostics, unchanged.

## Residues (ranked)

1. Formals typed by a package vif typedef bind the listing, where golden binds a bare copy
   spanned at the use. Cases: rn26, rn27, rn64, rn65, rn66. This is TypeEmit LAW S and the
   sister's ground; the net half of rn27 and rn66 is now right.
2. Subroutine-local kinds: locals of a module task or function, of a class method in a
   module and of package functions are logic_var where golden writes ref_var. Cases rn07,
   rn08, rn43, li03, li08 (TaskFuncEmit § blockLocalTdDeclIsRefVarUnsupported155 site 1,
   the sister's). Once the sister writes ref_var there, the implicit-net law reaches those
   references only for the module task and function shapes (rn07 golden net work@top.g).
3. A qualified `t::vt_t q;` in a module that also imports t binds the listing itself in
   golden (vs08). § pkgVirtIfaceTd479's net half copies it because the module lists the
   typedef. The distinguisher is the written scoped name, which the design-final UHDM pass
   cannot see. Not written.
4. A local sharing its name with a module member: rn35 golden binds the module's own net;
   rn36 with a parameter is bare in golden. Both abstain.
5. A generate-block process (rn42): golden types the local by an unsupported_typespec
   named vt_t. Not decoded.
6. Interface processes and tasks (rn09, rn58): golden mints the wire under the interface
   INSTANCE (work@top.u.g). emitInterfaceInstance's process loop and the interface
   subroutine bodies do not set implicitNetModule (ModuleEmit / TaskFuncEmit, the
   sister's).
7. A program local (rn10): golden's listing face is in ModuleEmit's program hoist.
8. Carried: pass 479's pv11/lv05 (a typedef of a vif typedef, listed by golden in the
   TOP view only, parented at the importing module and aliased to a bare copy; not
   written), pv12, pv13, pass 477's and earlier lists, and p733, p737 and tnoc (KNOWN
   EXCEPTIONS).

## Sister-ground faces (reported, not written)

- ModuleEmit emitInterfaceInstance's process loop: no implicitNetModule (rn09; golden
  `logic_net work@top.u.g`).
- TaskFuncEmit: interface subroutine bodies have no implicitNetModule (rn58).
- TaskFuncEmit § blockLocalTdDeclIsRefVarUnsupported155 site 1: subroutine locals through
  a vif typedef (rn07, rn08, li03, li08; class method rn43).
- TypeEmit LAW S: formals typed by a package vif typedef (rn26, rn27, rn64 to rn66).
- TypeEmit's $unit and module typedef branches (§ virtIfaceTd402, § modVirtIfaceTd410) build
  the same span as the package branch did. A `$unit` or module `typedef virtual ifc #(8).mp`
  presumably needs the same name-only span; not measured here.
- uvm_param_vif_config_db's head (this_t vpiInstance) and easyUVM's ref_module face, as
  at the base.

## Process

- The pristine build matched the main tree's binary.
- law1 to law6 were measured on case runs only. law5 broke rn26 and was never swept.
- Three censuses ran (pristine/law3, law3/law4, law3/law6). One full sweep ran on law3,
  and one byteverify.
- Every run waited for a quiet machine: the sister verifier v11u474's sweep finished
  before the census started.
- The fence list was read into a file by a program and never printed. Every tree-wide list
  and every csv copy was filtered on it before use. No fenced test was named, opened or
  run.
- Slip: one ad hoc strict-compare call ran with $STRICTCMP unset in a fresh shell. Bash
  tried to run a golden database as a script, the commands failed, and no file was
  written; the main repo was checked clean. Every later call sourced the env file and
  guarded the variable.
