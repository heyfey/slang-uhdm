# v11u413 — adversarial verification of r11u413

Verifier pass on base c64f995f for the implementer pass r11u413 (the sv-tests
campaign's seventh pass on the expression/parameter ground: src/ExprEmit.cpp,
src/ParamEmit.cpp).  VERDICT: **VERIFIED, no production refinement.**  Every
headline number reproduced; 73 fresh case dirs found no case where pristine
was right and the law is wrong, no case leaving an equal status, no exit code
worse and no downstream verdict worse.  The verified patch is the
implementer's production code unchanged plus this directory and the
regenerated tests/LAWS.md.

## Binaries (frozen before any measurement)

- pristine /tmp/v11u413_bin/pristine md5 91430e8d41d50b5bb4445fae97e61b69
  (the implementer's frozen copy, equal to the main tree's build at the base;
  no pristine build, no pristine sweep under the measurement budget: the
  pristine reading is the master's control /tmp/intr11u411).
- law, rebuilt ONCE from /tmp/r11u413.patch applied on a fresh c64f995f
  worktree (-j 2): /tmp/v11u413_bin/law md5 87836b5db413c10d58c1aabdc4bd9c78,
  equal to the implementer's law5.  uhdm-strictcmp fa6e4f42.
- No-header audit of the added lines: no src/R*.h, no getenv, no #include,
  no reader function; switches lawOn(413, "R11U413_CLSCALLMEMBER_OFF"),
  "R11U413_IFCALLMEMBER_OFF" (twice), "R11U413_IFARRELEM_OFF",
  "R11U413_COPYLHS_OFF", "R11U413_EMPTYCONCAT_OFF", "R11U413_SUPERMEMBER_OFF",
  "R11U413_UNQRAND_OFF", "R11U413_UNITBITCLONE_OFF"; nine lawTrace(413, ...).

## The one full sweep (law binary; drivers/sweep.sh, drivers/launch.sh)

Launched by drivers/launch.sh after waiting the 30-minute maximum for a quiet
machine: no sweep process was live, but the sister verifier v11u416's
uhdm-dump census held the load at about 3.2 (evidence/sweep_law/launch.log).
No TIMEOUT or load artefact followed; nothing reran.

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0
  conversions=0 changes=0; csv byte-identical to the control.
- surelog: default CMP_EQUAL 480 (CMP_NOTEQUAL 4), testflags 474 (4),
  0/0/0; csv identical to the control except the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0; csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  csv identical to the control.
- sv-tests: `regressions=0 conversions=5 changes=0`; EQUAL 1705,
  STRICT_NOTEQUAL 97, DIFFERENT 138, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; the csv is identical to
  the implementer's on all 2346 rows.  Fresh rows:

      chapter-7/queues/delete_assign.sv,EQUAL,,equal                      (§ emptyConcatArrayVar413)
      chapter-8/8.12--shallow_copy.sv,EQUAL,,equal                        (§ shallowCopyLhsUnbound413)
      generated/hdlconv_std2017/hdlconvertor_std2017_p181_2.sv,EQUAL,,equal  (§ superMemberHierPath413)
      generated/hdlconv_std2017/hdlconvertor_std2017_p537.sv,EQUAL,,equal    (§ stdRandomizeFuncCall413)
      generated/hdlconv_std2017/hdlconvertor_std2017_p770.sv,EQUAL,,equal    (§ ifaceArrElemArgBitSel413)

  each DIFFERENT (detail `decompile:`) in the control.
- The sweep exits 1 in this worktree only because this directory's cases
  make tests/LAWS.md stale (`law index current` with the directory moved
  aside); the index is regenerated in the verified patch.
- byteverify against /tmp/intr11u411 (same-length workdir names, SELFCHECK
  961/962, 1607/1608, 804/805 flagged): surelog 2 of 962 (SVSwitch default and
  testflags), uhdm2rtlil 0 of 1608, downstream 0 of 805.  SVSwitch:
  § shallowCopyLhsUnbound413 on Driver.sv:38 `pkt = new gpkt;` gives the Lhs
  ref golden's `hier_path (pkt)` parent (golden dump: the same parent and the
  same listed hier_path); status CMP_EQUAL / equal unchanged.
- canaries ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil); ctcan2
  PASS on both (ok=58 unknown-patterns=1; ok=2 unknown-patterns=6).
- binary audit, fence-filtered (the fence list read into a file by a
  program, never printed): surelog 1523 of 1573 cmds.txt name the law binary,
  0 another, 50 hold no slang line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of
  2346.
- trace census (evidence/sweep_law/trace_by_db.txt, 173 databases): probe,
  uhdm2rtlil, downstream none; surelog SVSwitch d/t (copy) and
  § stdRandomizeFuncCall413 on BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t,
  SimpleUVM d/t and Scoreboard d (uvm_sequence_library's out-of-body
  `randomize(select_rand)`, byte-neutral: no byte mover there); sv-tests 162
  rows: the five converted, p179 (copy), uvm_many_to_one (empty `{}` and
  randomize) and 155 UVM rows with the randomize firing alone.
- away census on the 157 firing sv-tests rows kept by both sweeps
  (drivers/svnorm.sh, path- and id-normalized dumps):
  155 identical to the control; p179 moved toward golden (dump distance 99 ->
  91, 8 lines changed) and uvm_many_to_one toward golden (5084638 -> 5082527,
  13 lines changed); 0 away.
- black-parrot: bp_unicore alone on the law binary exits 3 (the guarded
  `basic_string::substr`) at 813 MB max RSS; the size guard stays.

## The implementer's grid, reproduced

drivers/grid.sh over tools/probe/r11u413repro/cases (48 case dirs):
every line equal to evidence/grid_law5.txt in exit code, uhdm-cmp line count,
strict verdict, R11U413_OFF -> pristine (48 of 48) and the own switch ->
pristine (48 of 48) (evidence/grid_impl_reproduced.txt; md5s and two dump
distances differ only by the case path length embedded in the databases).
Earlier passes' case dirs (every dut.sv under r11u4*repro and v11u4*repro,
fence-filtered, 1712): the same exit code and bytes on 1709; movers v11u409
VI/vi20, v11u411 VM/vm04 (exit 4 -> 0) and VM/vm06, all targeted
(evidence/earlier_pass_cases_pristine_vs_law.txt).

## The attack grid (cases/, 73 case dirs; evidence/grid_attack_law.txt)

Every case accepted by upstream slang (~/.local/bin/slang --single-unit),
first line `// § <law>`; drivers/vgrid.sh: pristine, law, R11U413_OFF and the
group's own switch.  R11U413_OFF gives pristine's bytes on 73 of 73, the
group's own switch on 73 of 73.

| group | law | cases | pristine -> law |
|---|---|---|---|
| VC | § classCallResultMemberRef413 | vc01-vc14 | 10 exit 4 -> STRICT_EQUAL (vc01 singleton `C::get().val + 1`, vc02 struct return in always_comb, vc05 inside another class, vc06 unscoped non-static, vc07 handle with an operation argument, vc08 handle inside a class method, vc09 `pk::C::mk(z).s`, vc10 module function, vc11 in a condition, vc14 two arguments); vc12 `C4::mk().s` through a typedef of a specialization exit 4 -> exit 0 NOT_EQUAL (the class-parameter typespec head, the sister's face cm06); vc03 `C::mk().d.k` exit 4 -> exit 0 (Surelog rejects it: syntax error, no golden); vc04 `C::mk().arr[1]` exit 4 on both (Surelog rejects; ours 'element select base'); vc13 `this.mk().s` exit 4 on both ('member access base') |
| VI | § ifaceCallResultMemberElem413 | vi01-vi06 | vi01, vi03 (a localparam argument), vi04 (an interface port), vi05 (two calls, an operation argument) NOT_EQUAL -> STRICT_EQUAL; vi02 (a part-select argument) abstains, dump identical; vi06 `u.mk(x).a[2]` exit 4 on both (Surelog rejects) |
| VA | § ifaceArrElemArgBitSel413 | va01-va12 | va01 (task argument), va02 (`s[P]`), va03 (virtual-interface assignment), va05 (`s[ 3 ]` on a [1:4] array), va07 (nonblocking), va10 (`s[i]` in a generate-for) NOT_EQUAL -> STRICT_EQUAL; va06 (function argument) NOT_EQUAL -> STRICT_NOTEQUAL col; va11 (`v[0] = s[0]` into a virtual-interface array) NOT_EQUAL on both, dump distance 87 -> 59 (its head the array_net of virtual interfaces, pass 410's residue); va04 (2-D array), va08 (`s['h2]`), va12 (an interface port array) abstain, pristine's bytes; va09 (a parameterized class static call) STRICT_EQUAL control unchanged |
| VS | § shallowCopyLhsUnbound413 | vs01-vs07 | vs01 (a block-local handle), vs02 (task), vs06 (fork) NOT_EQUAL -> STRICT_EQUAL; vs03 (`new this` in a class method), vs05 (a class property) STRICT_EQUAL on both, bytes moved to golden's hier_path parent (dump distance 10 -> 2); vs04 (`arr[0] = new x`) and vs07 (a declaration initializer) abstain |
| VE | § emptyConcatArrayVar413 | ve01-ve09 | ve02 (return), ve05 (dynamic array), ve06 (class property), ve07 (nonblocking), ve09 (string queue) NOT_EQUAL -> STRICT_EQUAL; ve01 (a variable initializer), ve03 (task argument), ve04 (ternary operand) NOT_EQUAL -> STRICT_NOTEQUAL fullname; ve08 (`p.push_back({})`) NOT_EQUAL on both, dump distance 48 -> 32 |
| VU | § superMemberHierPath413 | vu01-vu10 | vu04 (two levels up), vu06 (call argument), vu08 (lhs and rhs), vu10 (package class) NOT_EQUAL -> STRICT_EQUAL; vu05 (`super.value++`), vu07 (out-of-body method) NOT_EQUAL -> STRICT_NOTEQUAL fullname; vu01 (`super.arr[1]`), vu09 (`super.value[1:0]`) abstain, NOT_EQUAL on both; vu02 (`super.s.f`), vu03 (a constraint) STRICT_EQUAL controls unchanged |
| VR | § stdRandomizeFuncCall413 | vr01-vr08 | vr02 (package function), vr03 (interface), vr05 (module condition), vr08 (module task) NOT_EQUAL -> STRICT_EQUAL; vr04 (program) NOT_EQUAL on both, dump distance 10 -> 4; vr01 (out-of-body class method: the law fires) STRICT_NOTEQUAL fullname on both, dump identical; vr06 (in-body method), vr07 (`with`) abstain |
| VN | § unitTdCloneNoPrefixBit413 | vn01-vn07 | vn01 (bit signed [7:0]), vn02 (packed 2-D), vn07 (instance two levels down) NOT_EQUAL -> STRICT_NOTEQUAL fullname (the alias ref `i_t`, golden the instance path); vn03 ([0:7] default only), vn04 (two parameters), vn05 (localparam), vn06 (bit [15:0]) STRICT_EQUAL controls unchanged |

Tally (73): 36 NOT_EQUAL -> STRICT_EQUAL (10 of them from exit 4), 9
NOT_EQUAL -> STRICT_NOTEQUAL (8 fullname, 1 col), vc12 exit 4 -> exit 0
still NOT_EQUAL (closer, 64 -> 58), 3 NOT_EQUAL on both and closer (va11 87
-> 59, ve08 48 -> 32, vr04 10 -> 4), 7 NOT_EQUAL on both at pristine's bytes
(va04, va08, va12, vr07, vs04, vu01, vu09) plus vi02 dump-identical (bytes
only, residue 6), vc13 exit 4 on both, 11 STRICT_EQUAL on both (9 at
pristine's bytes, vs03 and vs05 bytes toward golden 10 -> 2), vr01
STRICT_NOTEQUAL fullname on both and dump-identical, 3 shapes Surelog rejects
(vc03 exit 4 -> 0, vc04 and vi06 exit 4 on both).  No case leaving an equal
status, no exit code worse, none away by dump distance.  uhdm-cmp line counts
grow on ve08 (40 -> 103) and va11 (44 -> 371) while the dump distance
shrinks: the comparator's alignment, not a move away.

Downstream (drivers/ds.py, the class-free cases;
evidence/downstream_attack.txt): vi01, vi05 STATUS_DIFF -> IDENTICAL, vi03
EQUIVALENT -> IDENTICAL, va03, va07 STATUS_DIFF -> IDENTICAL, vr05
EQUIVALENT -> IDENTICAL; vi04, VN (7), ve01, ve03, ve04, ve05, ve07, ve09,
va11, va12 IDENTICAL on both; ve08, va04 EQUIVALENT on both, vi02 STATUS_DIFF
on both; none worse.

## Residues (ranked; all wrong on pristine too, none moved away)

1. GOAL 1 on this ground: `this.mk().s` (VC/vc13, Surelog accepts) still
   exits 4 'member access base' (§ classCallResultMemberRef413's handle
   branch requires an identifier left of the dot); `C::mk().arr[1]` and
   `u.mk(x).a[2]` exit 4 'element select base' (VC/vc04, VI/vi06; Surelog
   rejects both with a syntax error, so no golden; upstream slang accepts).
2. The empty `{}` outside an assignment's right side or a return
   (ve01, ve03, ve04, ve08): decoded, Surelog's paEmpty_queue
   (CompileExpression.cpp) builds the array_var with no parent and the caller
   supplies one: an argument, an operand or a variable initializer parents
   it there and the full-name pass names it after the enclosing scope
   (`work@top`, the ref_typespec too) or the variable (`work@top.q`), where
   the law writes it unparented and unnamed everywhere.  Not written.
3. The alias-ref full name of the no-prefix `$unit` bit typedef clone
   (vn01, vn02, vn07, NU/nu01; golden `work@top.u.i_t`).
4. `super.value++` and an out-of-body method's `super.value` (vu05, vu07,
   one full name each); `super.arr[1]`, `super.value[1:0]` (vu01, vu09).
5. randomize in a program (vr04) and out-of-body class methods (vr01, a full
   name standing on pristine too).
6. Byte hygiene: when § ifaceCallResultMemberElem413 abstains on an
   argument it cannot copy (vi02, a part-select), the method_func_call and
   the partial copies it built are left unreferenced in the serializer, so
   the bytes move with an identical dump; a later pass may build the copy
   before minting the element.
7. The implementer's residues stand as listed in tools/probe/r11u413repro.

## Process

- No sweep ran while another sweep ran; the sweep started while the sister
  verifier's dump census ran (launch.log).  The attack grids, the earlier-pass
  byte controls, the away census and the downstream case runs ran before or
  after the sweep, one at a time; the downstream case runs were the only
  downstream harness of this pass besides the sweep's stage.
- No other agent's process touched; no fenced test named, opened or run;
  every tree-wide list (earlier-pass dut.sv, cmds.txt) filtered on the fence
  file first.
