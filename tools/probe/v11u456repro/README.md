# v11u456: adversarial verification of r11u456 (module/type ground, pass 456)

Verifier of r11u456 on base 7b76f0685. Verdict: CONFIRMED WITH ONE REFINEMENT.
The implementer's numbers reproduce bit for bit. 48 fresh attack cases found no
break (no case moved away from golden on uhdm-cmp, on uhdm-strictcmp or on the
downstream verdict). They did find one wrong binding that the law writes and
neither judge reads. The verifier fixes it behind its own switch:
§ loopVarShadowedByTfDecl456v.

## Reproduction (law binary)

- Patch /tmp/r11u456.patch (md5 81f6cee85c81d9d7f1390e74df5bd66b) applies clean on a fresh 7b76f0685.
  Surface: src/ModuleEmit.cpp, src/TypeEmit.cpp, tests/LAWS.md, tools/probe/r11u456repro/.
  The no-header audit reads no src/R*.h, no getenv, no reader definition and no header change. The three
  law switches go through lawOn(456, ...), and every law has a lawTrace call.
- Law binary built once in /tmp/wt_v11u456: md5 c24fb0c78f778827e09489cd96815ff7, equal to the
  implementer's law8. It links slang 12.0.0+545f88b2e. Frozen at /tmp/v11u456_bin/law.
- Pristine: the implementer's frozen worktree build, md5 61990b658b183290f4b48a414a72a435 (equal to the
  base build), copied to /tmp/v11u456_bin/pristine and used only for case runs. There was no pristine
  sweep; the master's control /tmp/intr11u454 is the pristine reading.
- The implementer's 20 grid dirs reproduce on exit code, uhdm-cmp count and strict verdict (pristine ->
  law; IR/ir01 STRICT_NOTEQUAL fullname -> STRICT_EQUAL 262, TF/tf01, tf02, tf04 to tf07 17 -> 0, WT/wt01,
  wt02, wt06, wt07, wt09 31 -> 0, wt04 31 -> 811, wt05 56 -> 56, the five controls byte-identical).
- One full five-stage sweep on the law binary (/tmp/v11u456swL, trace on), started after three quiet readings:
  - probe EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, 0/0/0;
  - surelog default 480 + 0, testflags 474 + 0, 0/0/0;
  - uhdm2rtlil 803/1/67 in both modes, 0/0/0;
  - downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0, not excused 0;
  - sv-tests EQUAL 1926, DIFFERENT 14, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
    SURELOG_CRASH 8, TIMEOUT 1 of 2346, 0/0/0.
  Every csv is identical to the control's after path normalization (svtests.csv byte-identical). The
  corpus stage exited 1 only on the stale law index, which these new case dirs make stale.
- byteverify (SELFCHECK=1) law sweep vs /tmp/intr11u454: surelog 0 of 962 (961), uhdm2rtlil 0 of 1608
  (1607), downstream 0 of 805 (804).
- Canaries: canaries.sh ok=52 (surelog csv) and ok=16 (uhdm2rtlil csv). ctcan2 surelog ok=58 PASS
  (EXPECT_UNKNOWN=1), uhdm2rtlil ok=2 PASS (EXPECT_UNKNOWN=6).
- Binary audit (cmds.txt list fence-filtered before any file was opened): surelog 1523 of 1573 name the
  law binary, and the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346.
- Trace: exactly the implementer's firings. Probe 5 cases (r10uvm69repro/v1_gaps, r10v221repro/arms/v1_inst,
  r10vrgg16repro/cells/v5, r10vrgg6repro/cells/v_iface_chain, v11u112repro/grid/brk/t/b2c_iface_fn): each
  database is identical to the control by path-normalized dump. Surelog Tnoc d/t: 17 firings each, bytes
  unmoved. sv-tests 12 rows: tnoc, uvm_ac_config_db, uvm_ef_vif_config_db, uvm_id_register,
  uvm_param_vif_config_db, uvm_slave_agent, uvm_slave_agent_multi_seq_item, uvm_use_models_bidir_get_put,
  _bidir_item_done, _pipelined_get_put, _unidirectional and uvm_wait_for_signal. No status moves.
  The raw bytes of the kept sv-tests databases differ from the control for firing and non-firing rows alike
  (uvm_vif_config_db and uvm_test_init fire nothing and still differ). That is the known serialization-order
  variance, not a mover.
- Not reproduced: the experiment readings with pass 455 (exp2: ef_vif judge-equal at differ:fullname(427),
  ac_config_db at 64 lines). They need a third build, which is outside the budget. They are not a gate
  claim on this base.

## Attack grid (cases/, 48 dirs, every first line names its law)

Every case is accepted by upstream slang (~/.local/bin/slang). Every exit code is 0 on all three binaries.
Readings are pristine -> law -> verified (evidence/grid_pri.txt, grid_law.txt, grid_ver.txt). The bindings
were compared to golden with r11u456repro/drivers/refbind.py.

§ ifcTaskFixupWalksWait456 (VW, 16 dirs):
- To STRICT_EQUAL with every ref binding equal to golden's:
  - vw03: user call arguments, nested calls;
  - vw04: fork/join_any with a block local and disable fork;
  - vw06: three instances; the shared body binds the first;
  - vw08: nested foreach i/i2;
  - vw10: an interface parameter named like the loop variable; golden binds the loop variable;
  - vw12: bit, part and indexed selects in a function called from the module;
  - vw13: parameterized interface in a generate loop;
  - vw14: $sformatf, $cast, $isunknown, $countones;
  - vw15: a block local shadowing the loop variable inside the body;
  - vw16: wait fork and a wait with a block body, two instances.
- vw01 and vw05: 31 and 29 -> 0, STRICT_EQUAL, but with the wrong binding the refinement fixes (below).
- Closer, with the residues listed below:
  - vw02: $bits and $size; 61 lines on all three binaries;
  - vw07: assume, cover, assert #0 and assert final; 31 lines;
  - vw11: event trigger and queue methods; 31 lines, byte-identical;
  - vw09: an interface wire named like the loop variable; 56 lines; bindings equal golden; the loop
    variable kind is the sister's StmtEmit face 1.

§ thisFirstGroupOrigToo456 (VT, 16 dirs):
- 17 -> 0, STRICT_EQUAL:
  - vt01: in-body method beside the out-of-body one, this.m_a;
  - vt02: an out-of-body task, one module instantiated twice;
  - vt03: two importing packages a and b, one module each;
  - vt04: the first module imports both a and u;
  - vt06: a parameterized class, single module;
  - vt07: two methods, three modules;
  - vt08: a file-level import a::*;
  - vt09: export u::*;
  - vt10: a derived class in the importer;
  - vt13: the declaration and instantiation order reversed;
  - vt14: two classes, this twice in one method;
  - vt15: an interface as the second importer;
  - vt16: two modules importing a.
- vt05 (an interface as the first lister): STRICT_EQUAL on pristine, byte-identical on the law.
- Unchanged at uhdm-cmp 101 and 102 lines on all binaries; both heads are the import_typespec listing on
  pristine too:
  - vt11: a program as the first lister;
  - vt12: an explicit import u::C in the package.
- Downstream: vt01 and vt07 go EQUIVALENT -> IDENTICAL.

§ ifcTransTdWriterRank456 (VR, 10 dirs):
- STRICT_EQUAL on all binaries, with the bytes moving toward golden (the shared enum u::e_t re-parented
  from the interface to the module, as golden writes it; a field strict does not read):
  - vr01: two interfaces sorting after the module;
  - vr03: the module importing u directly;
  - vr05: two interface instances plus a generate-block instance;
  - vr07: a module named aa;
  - vr09: an uninstantiated interface.
- Byte-identical controls:
  - vr02: the explicit import mid::k, the law abstaining;
  - vr06: interfaces only.
- Byte-identical and NOT_EQUAL on all binaries, at the importer's typedef listing (the
  § ifcBodyImpTransitiveTds450 residues):
  - vr04: a program importer;
  - vr08: the file-level import, § 418's route that keeps rank 1;
  - vr10: the importing package with its own enum.

Downstream on 8 sampled cases (vw06, vw12, vw13, VS/vs05, vt01, vt07, vr01, vr05): IDENTICAL on law and
verified. vt01 and vt07 were EQUIVALENT on pristine; the others were IDENTICAL on all three.

Earlier grids as byte controls (drivers/bytectl.sh, pristine vs law, evidence/bytectl_earlier_grids.txt):
- 310 dirs of r11u450repro, v11u450repro, r11u452repro, v11u452repro, r11u454repro, v11u454repro and r11u456repro.
- 294 are byte-identical. The other 16 are the implementer's 15 movers plus v11u452repro VT/vt06, which goes
  uhdm-cmp 17 -> STRICT_EQUAL 184: an interface imports u and a module imports a, pass 452's residue now
  closed by § thisFirstGroupOrigToo456.
- Exit codes are equal on every dir.

## THE REFINEMENT: § loopVarShadowedByTfDecl456v (ModuleEmit, switch R11V456_LVSHADOW_OFF)

The law binds a name the interface does not declare to the innermost enclosing foreach loop variable.
Golden resolves the name in the subroutine's own scopes first: a block or subroutine local, or a formal,
of that name wins over the loop variable, as an interface variable does (WT/wt05). Only a name that
nothing encloses binds the loop variable (vw08, vw10, VS/vs06).

Example: in `task run(); int i; foreach (arr[i]) acc = acc + i;` golden binds `i` to the task's int_var
(VW/vw01). With `task run(input int i)` it binds the io_decl (vw05). Pristine left both unbound. The law
bound the loop variable's ref_var.

Neither judge reads the link: both binaries read STRICT_EQUAL. It is the law's own error rather than a
break, since pristine's value (unbound) was wrong too. The fix walks the reference's parents up to its
task or function and takes the first named_begin, begin or subroutine variable, or subroutine formal, of
that name.

Cases VS/vs01 to vs06 (a named-block local, a function formal, an output formal, a nested foreach under an
outer task local, two instances, and the vs06 control without shadowing), plus VW/vw01 and vw05:

| case | refbind diff lines vs golden: pristine | law | verified |
|---|---|---|---|
| vs01 | 6 | 2 | 0 |
| vs02 | 2 | 2 | 0 |
| vs03 | 4 | 4 | 0 |
| vs04 | 10 | 2 | 0 |
| vs05 | 4 | 4 | 0 |
| vw01 | 6 | 2 | 0 |
| vw05 | 4 | 4 | 0 |

- Every one is STRICT_EQUAL on the law and the verified binary.
- vs06 is byte-identical between law and verified.
- Switches (evidence/switches.txt, 68 dirs: these 48 and r11u456repro's 20): R11U456_OFF on the verified
  binary gives pristine's bytes on 68 of 68. R11V456_OFF and R11V456_LVSHADOW_OFF each give the law
  binary's bytes on 68 of 68.
- Each law's own switch alone on the law binary gives pristine's bytes on its own group:
  - R11U456_IFCWAIT_OFF on VW and VS, 22 of 22;
  - R11U456_THISFIRSTORIG_OFF on VT, 16 of 16;
  - R11U456_IFCTDRANK_OFF on VR, 10 of 10.
- Verified binary md5 b5015636cfeccbd024daf7338d5ac38a.

Prediction (evidence/prediction.txt, written before the verified sweep): no mover, since the fix sits inside
the loop-variable branch and both sweeps' traces hold no `loopvar` line. It held:
- One five-stage sweep on the verified binary (/tmp/v11u456swV, after three quiet readings).
- All five csvs are identical to the law sweep's: probe 4023 + 64, surelog 480 + 0 / 474 + 0, uhdm2rtlil
  803/1/67 both modes, downstream 803/66/2/0, sv-tests 1926/14/303/75/19/8/1, each with 0/0/0.
- byteverify against the law sweep reads 0 of 962, 0 of 1608 and 0 of 805, and the same against the
  control.
- The trace is identical to the law sweep's, with no firing of the refinement.
- Canaries ok=52 and ok=16; ctcan2 PASS on both.
- Audit: surelog 1523 of 1573 records name the verified binary (the other 50 hold only a Surelog line),
  uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346.
- The sister verifier's sv-tests stage (/tmp/v11u457_swL) started while this sweep's sv-tests stage ran.
  It overlapped, timing only: the stage reads TIMEOUT 1, the standing uvm_tb_build_ss_tb row.

## Residues, ranked (none moved away from golden)

1. The sfr rows behind pass 455 (implementer's residues 1 and 2; not re-measured, a third build being
   outside the budget).
2. The walk's statements not entered:
   - immediate assume and cover, and deferred assert #0 and assert final (VW/vw07, data and ok left
     unbound where golden binds the elaborated variables);
   - method calls on a queue (q.push_back(data), q.size()) and the event trigger -> ev (vw11).
   ModuleEmit, this ground; the next law of the family.
3. The elaborated interface listing:
   - $size(q) over an interface queue stays unbound (vw02);
   - the elaborated interface lacks the queue variable and named event (the implementer's WT/wt04
     residue 3).
4. The import-listing heads that the § ifcTransTdWriterRank456 cases stop at: a program importer (VR/vr04,
   VT/vt11), a file-level import into an interface (vr08; § 418's route keeps rank 1, and its head is the
   typedef listing, so the rank there is not reached), an importing package with its own enum (vr10, the
   r11u450 IT/it02 family), and an explicit import u::C in an intermediate package (VT/vt12).
5. The implementer's decodes and the carried lists (many_to_one, id_register, param_vif_config_db; passes
   454 and earlier).

## Sister-ground faces (reported, not written)

- StmtEmit: the foreach loop variable named like an interface variable or net, which golden writes as a
  ref_var over the interface object's typespec (WT/wt05, VW/vw09). This is the implementer's face 1,
  confirmed for a net (wire i) too.

## Process

- Within the budget: one law build (md5 equal to the implementer's), one verified build, one sweep each.
  No pristine build or sweep.
- Slips, none affecting a measurement:
  - The byte-control batch over the earlier grids and the verified build ran while the sister r11u457's
    corpus sweep was live (timing only).
  - The sister verifier's sv-tests stage overlapped this pass's verified sv-tests stage (its launch, not
    this pass's).
- The fence list was read into a file by a program and never printed. Every cmds.txt list was filtered on
  it before opening a file. No fenced test was named, opened or run. No other agent's process was touched.

Drivers: drivers/runcase.sh (Surelog golden + ours, exit code, uhdm-cmp lines, strict verdict),
drivers/bytectl.sh (two binaries, SAME/MOVED), drivers/switchcheck.sh.
