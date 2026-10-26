# r11u435 — expression/parameter ground: Surelog's size-cast fold in a struct-pattern member, and the `+` encoding of a reduced generate-scope right side

Pass 435, the eighteenth pass of the sv-tests campaign on the expression/parameter
ground (src/ExprEmit.cpp, src/EmitHelpers.h, src/ParamEmit.cpp; StmtEmit unchanged).
Base 676585243 (pass 433). Implementer: r11u435.

## Verdict

* **4 probe conversions** (the gate's `results/golden_probe.csv` rows, not edited here):

      r11u109repro/grid/f1/c04_x64cast,EQUAL,,equal      (baseline STRICT_NOTEQUAL differ:value(2))
      r11u109repro/grid/f1/c06_x64plain,EQUAL,,equal     (baseline STRICT_NOTEQUAL differ:value(2))
      r11u109repro/grid/f1/p06_plainparam,EQUAL,,equal   (baseline STRICT_NOTEQUAL differ:value(2))
      r11u109repro/grid/f1/p07_litcast,EQUAL,,equal      (baseline STRICT_NOTEQUAL differ:value(2))

  probe 4019 EQUAL + 68 STRICT_NOTEQUAL -> **4023 + 64**, regressions 0, changes 0.
  These are pass 109's f1 residue and pass 195's residue R6 ("the folded `Cfg.XLEN'(1)` cast
  value, an ExprEval value face behind the conversions").
* **No sv-tests row is on this ground at the base** (every one of the 37 non-EQUAL rows was
  re-run on the pristine binary with `--keep-golden` and its head read; the attribution
  table is below), so no sv-tests row converts; the sv-tests stage reads the numbers in
  "Gates".
* **Goal 1: nothing on this ground.** All 75 SURELOG_ONLY rows carry an upstream slang
  front-end diagnostic (`error:` in all 75 detail cells, 0 exporter "unsupported" messages in
  any rejecting row). The probe-case goal-1 shapes are all rejected by Surelog (exit 3), so
  golden has no shape to copy (measured, pristine and law binaries alike):

      v11u415repro/cases/VT/vt03 (this.mk().inner.s)         slang 0  Surelog 3  ours 0
      r11u423repro/evidence/residue_cases/g1a, g1b            slang 0  Surelog 3  ours 4
      r11u423repro/evidence/residue_cases/g1c                 slang 0  Surelog 3  ours 0
      v11u413repro/cases/VC/vc04 (C::mk().arr[1])             slang 0  Surelog 3  ours 4
      v11u413repro/cases/VI/vi06 (u.mk(x).a[2])               slang 0  Surelog 3  ours 4

  black-parrot: bp_unicore measured alone on the law binary exits 3 in 11.3 s at 840 MB
  (`basic_string::substr` with pass 403's size guard abstaining); the guard stays, the six
  rows stay SURELOG_CRASH. rsd is SURELOG_CRASH (Surelog dies first).

## Laws (all read through src/LawSwitch.h; `R11U435_OFF` drops the whole pass)

1. **§ patMemberSizeCastUbMask435** (`R11U435_PATCASTMASK_OFF`, ParamEmit, the elaborated
   struct-pattern walk's cast branch after § patMemberCastNoDecomp; `R11U435_PATCASTMASKDEF_OFF`,
   ExprEmit, the definition view's § patMemberSizeCastDef branch). A struct-pattern member written
   as a SIZE cast `W'(x)` folds through UHDM `ExprEval::reduceExpr`'s `vpiCastOp`
   integer-typespec branch (third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp, the
   `uhdminteger_typespec` branch): `mask = ((uint64_t)(1ULL << cast_to)) - 1ULL` is a shift
   x86-64 takes modulo 64, so a cast of width 64 folds to `x & 0` (UINT:0), 65 to `x & 1`,
   128 to 0 — the rule § srlgSizeCastUbShiftMask93 already models for a `param_assign`'s whole
   right side. The member branch wrote slang's value (UINT:1, UINT:2). The law applies the mask
   where the operand is one ExprEval reads UNSIGNED (see law 2), its value fits 64 bits, and
   the cast is not a chain (`depth == 1`); the size the branch writes is untouched. The mask walk
   `srlgSizeCastUbMask93` moved from ExprEmit.cpp to EmitHelpers.h unchanged (byte-neutral) so
   ParamEmit reads it.
2. **§ patMemberSizeCastSignedInt435** (`R11U435_PATCASTSIGNED_OFF`, ParamEmit, the same branch;
   classifier `patCastOperandSignedLeaf435` in EmitHelpers.h). ExprEval's `oper_signed` branch:
   when the operand's reduced constant carries a signed typespec the fold is `INT:` of the
   masked value (sign-extended below 64 bits, not at 64 and above; a literal operand's own bits
   are read unsigned, `16'(8'sb1111_0000)` INT:240, a parameter's stored INT signed), `vpiIntConst`, with a
   `ref_typespec` (full name the instance, parent the constant) to a fresh unlocated signed
   `logic_typespec`; this branch wrote UINT with no typespec — a uhdm-cmp difference at every
   width (`32'(K)` with `int K = 9`: golden INT:9). Measured which operands are signed leaves:
   a signed based literal (`16'sd5`, through the cast's parenthesized operand node) and a read
   of a parameter declared `int` or as a signed `logic` / `bit` / `reg` vector. `integer`,
   `byte`, `shortint`, `longint` parameters read UNSIGNED (PS/ps06, ps07, ps08, ps13 golden
   UINT); every operation (`-1`, `-K`, `K + 1`, `-16'sd5`) reads unsigned (PM/pm05, pm28, pm29,
   PS/ps12). It abstains on an untyped or typedef-typed parameter (ps05, ps21), a chain of
   casts, and an instance override (the stored value is the override's own constant: PS/ps16
   u1 golden UINT:4294967292 for `.K(-4)`). The pattern walk's bail scan
   (§ patBailStopsMemberStamp68) must not read the law's negative INT as a refusal: golden
   stamps the member width on the operands after it (ps04, ps10); the scan skips the law's own
   constants (a membership set in ParamEmit, never iterated).
3. **§ genCaAddParamIntCt435** (`R11U435_GENCAADDINT_OFF`, ExprEmit, § genCaConstRhsWhole433's
   leg 1). The reduced generate-scope right side's `+` is INT when an operand's stored constant
   is `vpiIntConst` or `vpiDecConst`; a parameter leaf's stored constant is the encoding of its
   initializer as written (the instance's actual when overridden), where the emitted tree's
   leaf carried the emitter's UINT. `gcCtSlang435` reads that encoding off the slang tree under
   ExprEval's table (`+` INT on an INT/DEC operand, `- * / %` INT, shifts and bitwise UINT, an
   unbased decimal UINT, a based decimal DEC, `$bits` UINT); it is consulted only to move a UINT
   the table answers INT for a top-level `+`, and abstains on typed parameters. Pass 433's
   residue 1 (v11u433 VW/vw10, vw11, vw26).

Trace: `R11U435_TRACE=<dir>` logs every firing (`lawTrace(435, ...)`). No src/R*.h, no getenv,
no LawState.h section, no reader function; TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit,
StmtEmit, include/ and uhdm_main.cpp unchanged.

## Grid (73 case dirs, `cases/`; drivers `grid.sh`, `runcase.sh`, `switch.sh`, `downstream_cases.py`)

Every case's first line names its law. Every case is accepted by upstream slang
(`~/.local/bin/slang dut.sv --single-unit`, exit 0) and every exit code is 0 on both binaries.
Golden from the pinned Surelog (`-parse -nobuiltin -nocache -sv dut.sv`), ours
`dut.sv --single-unit --nobuiltin`. Raw lines: evidence/grid_law7.txt (exit code, uhdm-cmp
lines, path-stripped dump distance, md5, strict verdict, R11U435_OFF check); classified:
evidence/grid_law7_classified.txt. Pristine -> law, 73 cases: **39 to STRICT_EQUAL**, 24
byte-identical (controls and two residues), 10 unequal on both with the dump distance down on
every one; none further from golden.

| group | law | cases | pristine -> law |
|---|---|---|---|
| PM | § patMemberSizeCastUbMask435 (pm06, pm26, pm27, pm30: § patMemberSizeCastSignedInt435) | 25 | 15 to STRICT_EQUAL (12 from STRICT_NOTEQUAL value: pm01 `64'(1)`, pm02 `W'(5)` W=64, pm04 64-bit cast into a 32-bit member, pm05 `64'(-1)`, pm09 `65'(3)`, pm10 based operands, pm13 `default:`, pm17, pm18 `128'(1)`, pm19 an unsigned `bit [7:0]` parameter, pm24 a package parameter read from a module, pm29 `64'(-K)`; pm06 `64'(int K)`, pm26 `32'(int K)` and pm27 `16'(16'sd5)` from NOT_EQUAL), 5 controls byte-identical (pm03 63'/32', pm20 W=32, pm21 W=96, pm28 `32'(-1)`, pm12 an operation over the cast), 5 NOT_EQUAL on both and closer (pm14 the narrowing chain `32'(64'(7))`, pm22 child instances, pm23 a package cfg, pm25 an imported package, pm30 a `logic signed` parameter: each head another face) |
| PS | § patMemberSizeCastSignedInt435 | 22 | 13 to STRICT_EQUAL (ps01 `int`, ps02 `16'sd5`, ps03 `64'(int K)`, ps04 `8'(K)` K=-3, ps10 `bit signed`, ps11 `16'(8'sb1111_0000)` INT:240, ps12 `64'(-16'sd5)`, ps15 `66'(K)` K=-2, ps16 a child with and without an override, ps17 `reg signed`, ps18 `int signed`, ps19 both members, ps20 member order), 8 byte-identical (controls ps05 untyped, ps06 integer, ps07 byte, ps08 longint, ps13 shortint, ps14 int unsigned, ps22 byte unsigned; residue ps21 a typedef'd int), ps09 NOT_EQUAL on both and closer |
| PD | § patMemberSizeCastUbMask435 (pd06, pd07 signed) | 10 | 3 to STRICT_EQUAL (pd01, pd02, pd05; the definition-view branch with the elaborated copy), pd03 STRICT_NOTEQUAL value -> type (the package typedef range `W-1`, TypeEmit: sister), 3 byte-identical (pd04, pd08, pd09), pd06, pd07, pd10 NOT_EQUAL on both and closer |
| GA | § genCaAddParamIntCt435 | 16 | 8 to STRICT_EQUAL (ga01 `W = 4'd2`, ga02 `2*3` and `10 - 3`, ga07 nested, ga08 a select Lhs, ga09 `$bits(x) + L`, ga12 `W + W`, ga13 `1 + L`, ga14 `.W(4'd4)` and `.W(2*2)` beside `.W(3)`), 6 controls byte-identical (unbased `3000000000`, `2 + 3`, `'h2`, `int W`, `W << 1`, `W - 1 + 2`), ga11 and ga15 byte-identical residues |

Switches (evidence/switch_family.txt, switch_own.txt): `R11U435_OFF` gives pristine's bytes
and exit code on 73 of 73; the three cast-law switches together on PM/PD/PS and
`R11U435_GENCAADDINT_OFF` on GA give pristine's bytes on 73 of 73; each case's own switch
alone restores pristine except where the other cast law co-fires in the same parameter
(PS/ps03, ps12, PM/pm06, pm14, pm26, pm27, pm30, PD/pd06), which the cast-law switches
together restore.

Downstream (evidence/downstream_cases.txt, `downstream_cases.py` through
scripts/downstream_uhdm2rtlil.one, all 73 class-free): 44 IDENTICAL on both, **8 DIVERGENT ->
IDENTICAL** (pm04, pm06, pm09, pm13, pm18, pm22, ps11, ps15), **14 STATUS_DIFF -> IDENTICAL**
(Surelog's lane had no gates because golden's folded value is 0), 5 STATUS_DIFF on both, and
PD/pd07 and PM/pm23 STATUS_DIFF -> DIVERGENT with their IL now nearer the Surelog lane (pd07:
one of the two differing constants now equal; pm23: the `Cfg` parameter and the mux now equal,
the port width left, another face); none moves away from IDENTICAL.

Pass 433's residue 1 on the law binary: v11u433 VW/vw10, vw11, vw26 NOT_EQUAL (28 uhdm-cmp
lines) -> STRICT_EQUAL.

Evidence: `evidence/sweep/` holds the law5 sweep csvs and log, the law6 sv-tests csv and the
law7 probe csv, with the fenced rows filtered out by program; `evidence/trace_census.txt` every
firing of the sweep's trace; `evidence/svtests_nonequal_heads_pristine.txt` the uhdm-cmp head of
every non-EQUAL sv-tests row on pristine.

## Census by name, before the sweep, and movers

* Probe: a traced export of all 4087 probe cases (fence-filtered list, 0 fenced) with the law
  binary, and the same 4087 on pristine compared byte for byte: 24 movers, all in
  r11u109repro/grid/f1 — the 4 conversions and 20 EQUAL cases (b01, b02, f03, f04, f07, f08, f09,
  f11, f12, f17, f19, f20, f21, f22, f24, p01-p05) where the law's constant is later replaced by
  ModuleEmit's § spVoidCastValue109 (the written value lives on in an unreferenced object:
  path-normalized dump identical, uhdm-cmp and strictcmp unchanged).
* Corpora and sv-tests: a fence-filtered source scan of 37594 files (Surelog tests and
  third_party tests, uhdm2rtlil tests, sv-tests) named 255 files with a size cast inside a
  pattern parameter (laws 1, 2) and 1570 with an `assign ... +` beside an INT-shaped parameter
  initializer (law 3); every firing in the sweep's trace is in those lists. A scan for a signed
  based literal as a cast operand inside a pattern parameter reads 0 corpus or sv-tests files
  (positive control: it finds PM/pm14, pm27, PS/ps02, ps11).
* The sweep's trace: law 1 fires on StructParamFieldRange d/t, cva6_struct_param_field d/t (and
  its downstream database) and the 24 probe cases above; laws 2 and 3 fire on no corpus row,
  probe case or sv-tests row.
* byteverify (`SELFCHECK=1 tools/probe/r11v75repro/byteverify.sh`, law workdir against the
  master's control /tmp/intr11u433): surelog 2 of 962 (StructParamFieldRange default and
  testflags), uhdm2rtlil 2 of 1608 (cva6_struct_param_field default and testflags), downstream
  1 of 805 (cva6_struct_param_field), self-checks 961/962, 1607/1608, 804/805 flagged; every
  mover predicted by name and path-normalized dump identical to the control (the
  spVoidCastValue109 overwrite again). The UVM coin rows did not move.

## Gates (law binary)

* probe: EQUAL 4023 + STRICT_NOTEQUAL 64, regressions 0, conversions 4 (above), changes 0.
* surelog: default CMP_EQUAL 480, testflags 474, regressions 0 conversions 0 changes 0; the csv
  differs from the control only in the two LowMem log-path texts.
* uhdm2rtlil: 803 / 1 / 67 in both modes, regressions 0 conversions 0 changes 0; csv identical
  to the control.
* downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not identical and not
  excused 0; csv identical to the control.
* canaries ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil); ctcan2 PASS on both.
* binary audit: 3263 of 3313 fence-filtered corpus command records name the law binary, the
  other 50 hold only a Surelog line; no other slang-uhdm binary appears.
* sv-tests (law6, the stage run through `svstage.py`, see Process): EQUAL 1903,
  STRICT_NOTEQUAL 1, DIFFERENT 36, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions 0 conversions 0 changes 0; the csv identical
  to the control's; the laws fire on no sv-tests row.

## sv-tests rows not EQUAL at the base, by head (pristine binary, kept goldens)

| rows | head (uhdm-cmp first object) | ground |
|---|---|---|
| 6 basejump (channel_control_slave, comm_link_checker, mem_1rw_sync_assoc, dff_en_segmented, scheduler_dataflow, ascii_writer) | the design's module list (uninstantiated modules with the inv-placeholder default) | UhdmExporter (sister) |
| round_robin_fifo_to_fifo, mesh_stitch | a module typedef's range (339:19 `width_p*num_out_p`, 18:14) | TypeEmit (sister) |
| p203, p334, p719 | type_parameter C.p, logic_typespec 2:17, logic_net i1.nq1 | sister pass 436's claims |
| p737, easyUVM, 16 uvm-examples, 3 uvm_scoreboard testbenches | design / class / package listings | sister |
| p733 | constant 16:10 (the cross-top defparam) | report only (user's decision) |
| tnoc | constant tnoc_pkg.sv 333:14 (Surelog's evaluated function artefact) | report only |
| fx68k (STRICT_NOTEQUAL fullname(4)) | ModuleEmit § caUnsizedRhsClonePerInst193's `!plainLhs` gate | sister (pass 438) |

## Residues (ranked; all wrong on pristine too, none moved away)

1. A generate-block localparam read by a generate-scope right side (`localparam G = 2*2;
   assign y = G + 1;`, GA/ga15): our emitter folds it at another site (not § genCaConstRhsWhole433)
   and writes UINT:5 where golden has INT:5.
2. A signed parameter typed through a typedef (`typedef int my_t; localparam my_t K`,
   PS/ps21): golden signed, the classifier abstains.
3. A chain of size casts whose outer cast narrows (`32'(64'(7))`, PM/pm14's y member): slang
   binds one conversion, so the inner 64-bit mask is not in the AST (pass 93's R2).
4. Pattern-member size casts behind other faces: child instances under an override (PM/pm22),
   a package cfg struct (pm23), an imported package parameter (pm25, PD/pd10), a `logic signed`
   parameter (pm30, PS/ps09), a package `int` parameter (PD/pd06, pd07), 65-bit package members
   (pd04), `default:` in a package pattern (pd09), a package pattern with a wider cast (pd08):
   each judge-unequal on a different first object.
5. `L = -3; assign y = L + 5;` in a generate body (GA/ga11): judge-unequal on another face.
6. The carried lists of passes 433 and earlier (tools/probe/r11u433repro and v11u433repro
   READMEs), except VW/vw10, vw11, vw26, written here.

## Sister-ground faces (reported, not written)

* fa20 / FA/fa16 (`f({3'd1,3'd2})` golden BIN:1010, ours UINT:10) and the FC cases: the fold is
  ModuleEmit emitContAssigns' (pass 433's attribution, confirmed: § genCaConstRhsWhole433 does
  not fire there).
* v11u432 VF/vf03, vf14 (`f({P, Q})`): golden lists the definition's cont_assign object itself
  in the instance (no elaborated clone, no fold) where ours writes a folded clone — ModuleEmit's
  elaborated cont_assign emission.
* PD/pd03: a package typedef's range `W-1` with `int W = 64` reads INT:63 in golden, an
  operation in ours (TypeEmit).

## Process

* Builds: the base build in the worktree equals the main tree's
  (256107fb9c98995fc2a29f7dfe33d198); intermediate law1 to law4 used on case runs only; law5
  (d3038082ee936b8a19e11e685bf74069) swept on all five stages with the trace on (the probe,
  surelog, uhdm2rtlil, downstream, byteverify and canary readings above are law5's). Two
  narrowings followed, both confined to a signed based literal as a cast operand in a pattern
  member: law6 (36d0c890654910b0fc96525fc4583447) reads the literal through the cast's
  parenthesized operand node (law5 classified `16'sd5` unsigned, so the mask law took PM/pm14's
  x member), law7 (d5d13cf711fb46d7025becf312be4a01, THE FINAL BINARY) reads that literal's bits
  unsigned as ExprEval's `get_value` does (PS/ps11 INT:240 where law6 wrote INT:-16). A
  fence-filtered scan of all 37594 corpus and sv-tests sources finds no such operand in any
  pattern parameter (positive control: PM/pm14, pm27, PS/ps02, ps11), and law5's trace shows the
  cast branch firing only on StructParamFieldRange and cva6_struct_param_field. Reruns, each a
  stage or rows alone: the probe stage on law6 and on law7 (csv identical to law5's, 4087 of
  4087 databases byte-identical to law5's), the four firing corpus databases on law6 and law7
  (targeted verify_golden rows: CMP_EQUAL equal, byte-identical to law5's), the sv-tests stage
  on law6 (the laws fire on no sv-tests row), and the grid, switches and downstream cases on
  law7. A budget deviation: the corpus stages were not rerun on law6 or law7, nor the sv-tests
  stage on law7.
* The worktree's empty `third_party/Surelog` made the sweep's sv-tests stage resolve UVM inside
  the worktree (156 UVM rows BOTH_REJECT, "No such file or directory": an environment
  artefact, discarded); the stage was rerun through scripts/check_svtests.py with `UVM_DIR`
  pointed at the main checkout (`svstage.py`; `quiet.sh` is the quiet-machine waiter), first launched by the sweep script with
  `SVTESTS_ROOT` unset (stage skipped).
* Slips, none affecting a measurement: one launch of the sv-tests stage from the main tree's
  sweep script started while the master's pass 436 integration sweep was live (its check
  printed that sweep and did not wait); it was stopped by its recorded PID within seconds
  before writing anything. The 73-case grid on law5 ran beside the
  master's sweep as a single sequential process. One background quiet-waiter matched its own
  command line and was stopped by task id; the replacement matches only harness programs.
  The fence list was read into a file by a program without printing it and every tree-wide
  path list was filtered on it first; no fenced test was named, opened or run; no other
  agent's process was touched.
