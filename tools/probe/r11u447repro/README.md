# r11u447 — reads of undeclared names in never-elaborated bodies (expression/parameter ground)

Pass 447 is the twenty-fourth pass of the sv-tests campaign on the
expression / parameter ground. It changes one file, ExprEmit.cpp; StmtEmit,
ParamEmit and EmitHelpers.h are unchanged. Base 34893117 (pass 445).

- **Pristine reading:** the master's control sweep at the base
  (/tmp/intr11u445). Its probe, surelog, uhdm2rtlil, downstream and svtests
  csvs equal the committed results/*.csv.
- **No pristine build and no pristine sweep.** The worktree's base build
  matched the main tree's build/slang-uhdm (md5
  58637f1e347839343e1068b18f4d5f92) and was frozen for case runs.
- **Final law binary:** law5, md5 d2ac6e0b6b23d72fcd84fd0e37bc048f, linking
  slang 12.0.0+545f88b2e.

## Heads at the base (question 1)

The 26 DIFFERENT sv-tests rows at the base are the rows pass 443 measured,
less control_slave, which pass 444 converted. This pass re-ran the runner
with `--keep-golden` on the four small ones:
- bsg_mem_BaseJumpSTL_bsg_nonsynth_mem_1rw_sync_assoc
- bsg_misc_BaseJumpSTL_bsg_scheduler_dataflow
- hdlconvertor_std2017_p733
- hdlconvertor_std2017_p737

All four still read DIFFERENT on pristine.

- **p737:** module M has an undefaulted TYPE parameter (`type T2`). Golden
  lists M as the design top (`design: (work@M)`), and ours lists no M at all
  (`design: (unnamed)`). This is UhdmExporter's admission, which abstains on
  an undefaulted type parameter (§ undefaultedDefInvalidInst404). It is the
  sister's face.
- **p733 and tnoc:** as reported before (the cross-top defparam; tnoc_pkg.sv
  333:14). They await the user's decision.
- **The 16 uvm-examples rows, the 3 scoreboard rows and easyUVM:** the
  sister's listings, as before.
- **The two basejump rows** are brief item (b): never-instantiated
  definitions that golden lists as module_inst. Ours does not list them,
  because the Bad404 visitor in UhdmExporter rejects their placeholder bodies
  (`abstain-unbound`).

To find out what each row needs once it is admitted, this pass built a
measurement-only scratch binary. It disables that one `return` under an
environment variable (evidence/r11u447_xadmit_hunk.txt). The hunk was never
in the patch, and every production binary was built without it.

| row | pristine + admission (xadmit) | law5 + admission (xlaw7) |
|---|---|---|
| bsg_nonsynth_mem_1rw_sync_assoc | rc 0, **STRICT_EQUAL 5195 objects** | rc 0, STRICT_EQUAL 5195 objects |
| bsg_scheduler_dataflow | rc 4 (`expression kind: Invalid`), NOT_EQUAL | rc 0, **STRICT_EQUAL 5589 objects** |

(evidence/r11u447_svrows_admit.txt; without the admission both rows stay as
they are on law5.)

- **The associative row needs no writer on this ground.** StmtEmit's
  § invalidChild14 already re-emits the nonblocking `mem[addr_i] <= data_i`
  from the InvalidStatement's child, exactly as golden writes it. Only the
  admission holds the row back.
- **The scheduler row needed this ground's writer for the undeclared
  `bypass_lo`.** Before this pass the `$display` argument was dropped and the
  run exited 4. Golden writes the argument as
  `ref_obj (work@bsg_scheduler_dataflow.bypass_lo) 191:112-191:121`, bound to
  an implicit `logic_net` minted at that span. In the module's net list that
  net sits after `alloc_id_v_lo` and before the port-connection wire
  `src_yumi_o` (219:25). This pass writes it (laws below).

So with this pass landed, **both rows convert DIFFERENT -> EQUAL as soon as
the sister's admission lets their bodies through** (see "Sister-ground
faces").

### Goal 1

- **No rejecting row carries an exporter message.** The control csv has 303
  BOTH_REJECT, 75 SURELOG_ONLY and 0 SLANG_CRASH rows. The five rows whose
  detail contains the text "slang-uhdm" match only on the UVM path; their
  message is upstream slang's timescale diagnostic.
- **black-parrot:** bp_unicore, run alone on law5 with the guard on, exits
  3 in 13.9 s at 828 MB maxrss (`basic_string::substr` behind
  § macroVecLitTokenText403's 1 MB guard). No memory-bounded export was
  found, so the guard stays.
- **rsd:** SURELOG_CRASH, not this ground.
- **Probe shapes C::mk().arr[1], u.mk(x).a[2] and this.mk().inner.s:** not
  re-measured, since no law of this pass reaches them (the trace census
  fires nowhere outside this pass's own cases).

**New on this ground: exit-4 shapes that upstream slang accepts.** The
fresh grid found seven, all accepted by upstream slang (exit 0) and by
Surelog:
- an undeclared name read in a continuous assignment of a definition no
  module instantiates (UN/un12, un26, un29);
- a net declared after a continuous-assignment read (un28);
- an undeclared name read in a process or continuous assignment of a
  never-instantiated interface (un30, un31, un32).

Pristine exited 4 with the read dropped. **law5 exits 0, and six of the
seven are STRICT_EQUAL.**

## Decode (question 2)

Slang leaves a read of a name it cannot resolve as an InvalidExpression with
no child and the bare IdentifierName syntax. That shape is reachable
without a slang error only in a body slang never elaborates (a definition
reached from basejump's `if (0)` abstract wrapper, or a module with a
default-less parameter that no one instantiates).

Surelog binds nothing at compile time. Its netlist elaboration (lateBinding,
the lookup-miss branch that § implicitNetMintNoFile131 and
§ implicitNetOnePerName405 already model) then works as follows:
- **Module, process read.** It mints the implicit wire at the first
  reference's span (vpiNetType 1, no file) and binds every reference to it
  by name.
- **Order in the module's net list.** All declared nets come first. Then
  every implicit wire follows in SOURCE ORDER of its first reference,
  whatever minted it: a port connection `.a(imp_a)`, a continuous-assignment
  target, or such a read. Golden un02: `clk, imp_a 3:12, undecl_x 4:40,
  imp_b 5:12`. Golden un03: `clk, late_w, undecl_y 2:40, imp_w 3:10,
  undecl_x 4:40`.
- **Module, continuous assignment.** It mints the same wire, and the
  cont_assign's rhs binds it (un12, un26, un29).
- **A module-level net or variable declared after the read** (slang: used
  before its declaration) binds to that declaration (un14, un27, un28).
- **A value of the same name that only a nested scope declares** (a named
  block's or a function's local) does not stop the mint (un35, un36).
- **A typedef of that name declared in a nested scope** never reaches the
  mint. In that case the Invalid node is a cast target that golden writes as
  unsupported_typespec (v11u304 VT/vt14_td_disp).
- **Interface.** The read is a bare ref_obj (`work@ifc.undecl_x`, no
  vpiActual), and no wire is minted (un30, un32).

Not written (golden measured, cases kept as residues):
- **un10, un25: generate blocks.** Golden writes a bare
  `ref_obj work@m.g.undecl_x` with no wire. Our emitter does not reach the
  law there, because implicitNetModule is null in the definition's
  generate-scope emission.
- **un07, un20: a bit-select over or with an undeclared name.** Golden spans
  the bit_select at the index alone.
- **un21: a dotted name.** Golden writes `hier_path undecl_x.y`.
- **un22: a call to an undeclared function.** Golden writes an unlinked
  func_call.
- **un13: a module-level typedef used as a value.** Golden writes a bare
  ref_obj.
- **un15: a read before a later port-connection implicit net.** Golden moves
  that wire to the read's span.
- **un18, un34: a concatenation.** § badConcatOperandsFromSyntax160 abstains.
- **un19: a named block in an InvalidStatement.** It is re-emitted as an
  unnamed begin; golden keeps `named_begin nb` spanning the label alone,
  3:19-3:21.
- **un31: an interface continuous assignment.** Golden's lhs `w` has no
  vpiActual. This is ModuleEmit's lhs binding.
- **un33: a program.** It is not admitted at all; this is UhdmExporter's
  face.
- **un37: the function-typedef cast.** It shows the same
  unsupported_typespec face as vt14 and is not touched by this pass.

## Laws (src/ExprEmit.cpp, the Invalid branch of emitExpr)

Every law is read through src/LawSwitch.h (`lawOn(447, ...)`). R11U447_OFF
drops the whole pass, and R11U447_TRACE=<dir> logs each firing and each
abstention through `lawTrace(447, ...)`. There is no src/R*.h, no LawState.h
section and no getenv. TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit,
StmtEmit, ParamEmit, EmitHelpers.h, include/ and uhdm_main.cpp are
unchanged.

### § undeclaredReadImplicitNet447 (R11U447_UNDECLNET_OFF)

**Scope.** In a module body, it applies to an InvalidExpression with no
child and IdentifierName syntax, outside a let or property body. The module
comes from implicitNetModule. In a continuous assignment, where that is
unset, it is the module that parents the cont_assign, reached up through
already-parented expressions.

**What it writes.** A ref_obj named by the identifier, spanning it and
bound to `mintImplicitNet403`'s wire. The wire is then moved in front of
the first implicit net (slang's NetSymbol::isImplicit, or a
§ implicitNetMintNoFile131 mint) that starts after it.

**When it abstains:**
- when currentScope is not in the body of the very definition being written
  (currentScope is stale in the elaborated walk);
- when a symbol of the name is found from currentScope up to the body;
- when any nested scope of the body declares the name as a type.

### § undeclaredReadLaterDecl447 (R11U447_LATEDECL_OFF)

Inside the law above: when the symbol found is a module-level variable or
a non-implicit net, the read binds to that declaration's object from
netMap.

### § undeclaredReadIfaceBare447 (R11U447_IFACEBARE_OFF)

The same shape in an interface body becomes a bare ref_obj with no
vpiActual and no wire. It abstains under the same guards.

## Grid (cases/UN, 37 case dirs; evidence/r11u447_grid_UN.tsv)

Each case dir's first line is `// § <law>`.

**Binaries:**
- pristine;
- law5;
- xadm, pristine with the measurement-only admission;
- xlaw, xlaw7 = law5 with the admission.

The law5 columns of un14 and un27 read xlaw7's bytes because those cases
are reachable only with the admission.

**Goldens:** `surelog -parse -nobuiltin -nocache -sv dut.sv`, all slrc 0.
Upstream slang (`slang dut.sv --single-unit`) accepts all 37.

| case (law) | pristine | law5 | xadm | xlaw7 |
|---|---|---|---|---|
| un12 (UNDECLNET, cont-assign) | rc 4, cmp 318 | **rc 0 STRICT_EQUAL** | rc 4 | STRICT_EQUAL |
| un26 (UNDECLNET, cont-assign operands) | rc 4, cmp 476 | **rc 0 STRICT_EQUAL** | rc 4 | STRICT_EQUAL |
| un28 (LATEDECL, cont-assign) | rc 4, cmp 19 | **rc 0 STRICT_EQUAL** | rc 4 | STRICT_EQUAL |
| un29 (UNDECLNET, cont-assign after a slang implicit net) | rc 4, cmp 426 | **rc 0 STRICT_EQUAL** | rc 4 | STRICT_EQUAL |
| un30 (IFACEBARE) | rc 4, cmp 68 | **rc 0 STRICT_EQUAL** | rc 4 | STRICT_EQUAL |
| un32 (IFACEBARE) | rc 4, cmp 37 | **rc 0 STRICT_EQUAL** | rc 4 | STRICT_EQUAL |
| un31 (IFACEBARE, interface cont-assign) | rc 4, cmp 15, dist 8 | rc 0, cmp 31, dist 2 (closer; next face ModuleEmit's lhs) | rc 4 | same as law5 |
| un01-06, 08, 09, 11, 16, 17, 23, 24, 35, 36 (UNDECLNET) | rc 0, not admitted (byte-identical on law5) | = pristine | rc 4 | **STRICT_EQUAL (15 cases)** |
| un14, un27 (LATEDECL) | = pristine | = pristine | rc 4 | **STRICT_EQUAL** |
| un07, 10, 13, 15, 20, 21, 22, 25 | = pristine | = pristine | rc 4 | rc 4, byte-identical to xadm (law abstains: residues) |
| un18, 34 | = pristine | = pristine | rc 0 | = xadm (concatenation residue) |
| un19 | = pristine | = pristine | rc 4, dist 22 | rc 0, dist 11 (closer; named_begin residue) |
| un33 | = pristine | = pristine | = pristine | = pristine (program not admitted) |
| un37 | = pristine | = pristine | rc 4, dist 20 | rc 0, dist 5 (closer; cast-typespec residue) |

**Totals:**
- **On law5:** 7 cases move, all exit 4 -> 0: 6 to STRICT_EQUAL and un31
  closer. The other 30 are byte-identical to pristine.
- **With the admission:** 23 STRICT_EQUAL, against 0 on xadm. 3 more are
  closer.
- **Away cases:** none.

**Switches** (each run on law5 over all 37 case dirs;
evidence/r11u447_switches.txt):
- **R11U447_OFF** gives pristine's bytes and exit code on 37 of 37.
- **R11U447_UNDECLNET_OFF** restores pristine on un12, un26 and un29.
- **R11U447_LATEDECL_OFF** restores pristine on un28.
- **R11U447_IFACEBARE_OFF** restores pristine on un30 to un32.

Each switch leaves the other laws' movers moved.

**Downstream** (ds.one, both lanes; evidence/r11u447_downstream.txt): the 7
moving cases read IDENTICAL on pristine and on law5. Both lanes read
NO_GATES, since a never-instantiated definition synthesizes nothing.

**The pass's own break, found and fixed before the sweep.** law2 minted a
wire for the cast target of a typedef declared in a function. The emitter
does not push the function scope into currentScope, so the typedef read as
undeclared:
- v11u304 VT/vt14_td_disp: dump distance 5 -> 20, uhdm-cmp 14 -> 30;
- vt27_const_fn_param: dist 96 -> 111.

law4 added a search of every nested scope of the body. That overreached
on un35 and un36, where golden does mint the wire for a name that only a
nested block or function declares as a value. law5 narrows the search to
type declarations. Both VT cases are byte-identical to pristine again, and
un35 and un36 are STRICT_EQUAL under the admission.

## Census and prediction (before the sweep; evidence/r11u447_prediction.txt)

**The probe trees.** law5 with R11U447_TRACE ran over every fence-filtered
.sv file in tools/probe and tests/probe (44714 files, drivers/census.py,
evidence/r11u447_census_probe_tree.tsv):
- 16 files fire, and none is under tests/probe;
- 9 are abstentions, byte- and exit-identical to pristine: r11u121
  t42_bodylp_mod_direct, r11u294 MT/mt09_body, r11u299 ME/e02_lp_three_inst
  and e05_two_inst_same, r11v167 ts/t05, v11u278 VT/vt06, v11u299
  VE/ve06_genfor_inst, and v11u304 VT/vt14_td_disp and vt27_const_fn_param;
- the 7 movers are exactly the grid's un12, un26 and un28 to un32.

The positive control is this pass's cases, which fire.

**The corpora** (drivers/corpus_census.py over the control's cmds.txt slang
lines, fence-filtered):
- surelog: 1573 records, 0 firings, 0 md5 movers against the control's
  databases;
- uhdm2rtlil: 1740 records, 0 firings, 0 md5 movers.

**sv-tests** (drivers/sv_trace.py, all 2346 control rows): 0 firings.

**Predicted sweep:** every stage 0/0/0 and the trace directory empty.

## Gates (question 3): the one five-stage sweep on law5

The sweep was launched after three quiet readings (drivers/fullsweep.sh,
evidence/r11u447_sweep.log). The four corpus stages ran from the worktree.
The sv-tests stage ran through the main tree's tests/sweep.sh with the same
binary and workdir, since the worktree has no UVM submodule. The trace was
on in every stage.

- **probe:** EQUAL 4023 + STRICT_NOTEQUAL 64, regressions=0 conversions=0
  changes=0. The csv is identical to the control. The 4087 databases are
  identical to the control by path-normalized uhdm-dump (the positive
  control differs by 887 lines).
- **surelog:** default 480 + 0 and testflags 474 + 0, 0/0/0. The csv
  differs from the control only in the two LowMem log-path texts.
- **uhdm2rtlil:** 803/1/67 in both modes, 0/0/0. The csv is identical to
  the control.
- **downstream:** IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  "not identical and not excused=0". The csv is identical to the control.
- **sv-tests:** EQUAL 1914, DIFFERENT 26, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, with regressions=0
  conversions=0 changes=0. The csv is identical to the control.
  - The stage's script exit was 1, on the main tree's stale tests/LAWS.md
    alone: `scripts/law_index.py --check` reads STALE on the clean main tree
    at the base too. The worktree's index is current.
- **trace directory:** empty in all five stages, as predicted.
- **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1)
  against /tmp/intr11u445:
  - surelog: 0 movers of 962, self-check 961;
  - uhdm2rtlil: 0 of 1608, self-check 1607;
  - downstream: 0 of 805, self-check 804.
- **canaries:**
  - surelog: ok=52 changed=0;
  - uhdm2rtlil: ok=16 changed=0;
  - both ctcan2 checks PASS (EXPECT_UNKNOWN=1 and 6).
- **binary audit** (fence-filtered cmds.txt):
  - surelog: 1523 of 1573 records name /tmp/r11u447_bin/law5; the other 50
    hold only a Surelog line;
  - uhdm2rtlil: 1740 of 1740;
  - sv-tests: 2346 of 2346;
  - none names another binary.

**sv-tests rows before -> after on this binary:** none moves. The two
basejump rows stay DIFFERENT until the sister admits them; with admission
both measure STRICT_EQUAL, as shown in the table above.

## Residues, ranked

1. **The admission of the two basejump definitions** (sister ground, below).
   It converts both rows on top of this pass.
2. **Generate-block reads (un10, un25):** golden writes a bare ref_obj
   `work@m.g.undecl_x`. The law is not reached, because implicitNetModule is
   null in the definition's generate-scope emission.
3. **Select, dotted and call shapes over undeclared names:**
   - un07 and un20: bit_select spanning the index;
   - un21: hier_path;
   - un22: unlinked func_call.
4. **un15:** a read before a later port-connection implicit wire. Golden
   relocates the wire to the read.
5. **un19:** the named block re-emitted from an InvalidStatement.
6. **un13:** a module typedef read as a value (golden: a bare ref).
7. **un18 and un34:** concatenations, § badConcatOperandsFromSyntax160's
   abstention.
8. **un31:** the interface cont_assign's lhs keeps a vpiActual that golden
   lacks (ModuleEmit).
9. **un37 and VT/vt14:** golden's unsupported_typespec for a cast to a
   function-local typedef.

The carried lists of passes 445 and earlier stand unchanged; no law of this
pass touches them.

## Sister-ground faces (reported, not written)

- **UhdmExporter's Bad404 admission** (the `abstain-unbound` return after
  § undefaultedPlaceholderRetry440 / § defaultedStrPlaceholderRetry444).
  - **What it does now.** Every InvalidStatement counts as bad, and the
    visitor never looks inside it.
  - **Associative row.** On bsg_nonsynth_mem_1rw_sync_assoc the only bad
    nodes are 3 InvalidStatements with a child, the timed `always_ff` bodies.
    With them admitted, the row reads STRICT_EQUAL 5195 objects on pristine
    and on law5.
  - **Scheduler row.** On bsg_scheduler_dataflow the bad nodes are 5
    InvalidStatements with a child, around the `$display` that reads the
    undeclared `bypass_lo`. With them admitted, the row reads STRICT_EQUAL
    5589 objects on law5 (exit 4 on pristine).
  - **Suggested rule:** admit when every InvalidStatement has a child and
    every child-less InvalidExpression inside is a bare IdentifierName that
    § undeclaredReadImplicitNet447 writes. Measure it with the cases/UN grid,
    whose xlaw column is that admission's ceiling.
- **The same admission abstains on an undefaulted type parameter**
  (hdlconvertor_std2017_p737: golden lists `work@M` as the design top), and
  it lists no never-instantiated program (UN/un33).
- **ModuleEmit:**
  - the interface cont_assign's lhs binding when its rhs is invalid
    (UN/un31);
  - the generate-scope emission of a never-elaborated definition, which
    leaves implicitNetModule null (un10, un25).

## Process

- **Implementer within the budget.** One full five-stage sweep was run, on
  the final binary law5. Intermediate binaries law1 to law4 and the
  measurement-only scratch builds xadmit, xlaw1 to xlaw7 got case runs and
  the two-row runs only. There was no pristine build beyond the frozen base
  build and no pristine sweep.
- **Slip, not affecting a measurement:** the law5 trace census over the
  44714 probe-tree files (3 jobs at nice 10, about 5 minutes) overlapped the
  sister r11u446's full sweep, which started at 08:53:51. Its outputs are
  per-binary bytes and do not depend on load. The corpus and sv-tests
  censuses and the sweep itself waited for three quiet readings.
- **The scratch admission hunk** was applied to UhdmExporter.cpp in the
  worktree only for those scratch builds. The file was restored from a copy
  each time, and a rebuild reproduced the law binary's md5. The patch does
  not touch UhdmExporter.cpp.
- **Fence:** the fence list was read into a file by a program without
  printing it, and every tree-wide list was filtered on it first. A scan of
  this directory for the fenced names finds none. No other agent's process
  was touched.

## Files

- cases/UN/unNN/dut.sv: 37 case dirs, first line `// § <law>`.
- drivers/:
  - grid.sh (golden + per-binary run, uhdm-cmp, strictcmp, dump distance);
  - census.py (probe-tree trace census);
  - corpus_census.py;
  - sv_trace.py;
  - probedump.sh;
  - fullsweep.sh;
  - rowrun.sh (one sv-tests row under the scratch admission);
  - quiet.sh.
- evidence/:
  - the grid, prediction, censuses, sweep log, byteverify, canaries and
    downstream;
  - the two-row admission readings (r11u447_svrows_admit.txt);
  - the scratch hunk (r11u447_xadmit_hunk.txt).
