# v11u441 — adversarial verification of r11u441 (expression/parameter ground, pass 441)

Base d1d6686a (pass 439). Implementer's patch /tmp/r11u441.patch (md5 e1552d3e...).
Verdict: **the three laws HOLD; no break found.** One production refinement
added inside the inc/dec walks (not a break: pristine was wrong there too):
§ unnamedLocalUnderNamedBinds441v. Production surface: src/ExprEmit.cpp only.

## Binaries (frozen before any measurement)

| name | path | md5 |
|---|---|---|
| pristine | /tmp/v11u441_bin/pristine (copy of the main tree's build at d1d6686a) | 695581e834d51f3ab012e5fb4ae62077 |
| law | /tmp/v11u441_bin/law (rebuilt from the patch in /tmp/wt_v11u441) | caf5b613ae9f5162678f8e3e81fe14aa = the implementer's law3 |
| verified | /tmp/v11u441_bin/verified (law + the refinement) | c4efdfa2c713ab09d9d8aada0ba7da74 |

All three link slang 12.0.0+545f88b2e. No pristine build and no pristine sweep:
the pristine reading is the master's control sweep /tmp/intr11u439.

## Targeted row

generated/basejump/bsg_comm_link_BaseJumpSTL_test_bsg_comm_link_checker.sv:
STRICT_NOTEQUAL differ:endline(1) -> **EQUAL** (CONVERSION) on both the law and
the verified binary. Fresh rows:
`generated/basejump/bsg_comm_link_BaseJumpSTL_test_bsg_comm_link_checker.sv,EQUAL,,equal`
(law sweep /tmp/v11u441_LW/svtests.csv and verified sweep /tmp/v11u441_VW/svtests.csv);
the csv differs from the control in that row only. Trace in both sweeps: exactly
one firing, `sysCallEmptyArgEndPrevTok441 $display 120:28 -> 119:86`.

## Laws under test (the implementer's; all in ExprEmit)

- § sysCallEmptyArgEndPrevTok441 (R11U441_EMPTYARGEND_OFF): a system call's empty
  argument INT:0 ends at the end of Surelog's hidden token before the slot.
- § emptySlotArgEndPrevTok441 (R11U441_EMPTYSLOTEND_OFF): the same for user calls.
- § uninstIfaceIncDecBinds441 (R11U441_IFACEINCDEC_OFF): statement-position ++/--
  in an uninstantiated interface binds formals, subroutine locals and
  unnamed-block locals.

## Refinement

§ unnamedLocalUnderNamedBinds441v (R11V441_NAMEDNEST_OFF; read through
`lawFixOn(441, ...)`, so R11U441_OFF and R11V441_OFF both drop it). In the walk of
§ uninstProgIncDecBinds439v (programs) and § uninstIfaceIncDecBinds441
(interfaces), a NAMED block stops the walk only when the symbol is declared
directly in it. Golden binds a local of an UNNAMED block nested anywhere under a
named block (VJ/vj11 `begin : nb begin int inner; inner++; garr[s]++; end end`,
bound to work@ifc.t.nb.inner; vj16 the same in an interface initial; vj22 two
named levels; vj17 the program twin), while a named-block local stays bare,
read from that block (vj14) or from an unnamed block inside it (vj15); an
unnamed-block local read from a named block inside its block binds (vj21, law
already right). Pristine and the law left these bare: not a break. Trace
`unnamedLocalUnderNamedBinds441v <name>` is written only when the walk binds.

## Attack grid (cases/, 65 fresh case dirs; evidence/grid_p_l_v.tsv)

Every case's first line names its law; upstream slang accepts all 65 (exit 0);
every exit code is equal on pristine, law and verified (64 at 0; none at 3 or 4
after va10 and vj12 were rewritten to shapes upstream slang accepts).

| group | law | cases | pristine -> verified |
|---|---|---|---|
| VA | § sysCallEmptyArgEndPrevTok441 | va01 trailing spaces, va02 tabs, va03 blank lines, va04 trailing slot before `)`, va07 line comment + blank line, va08 two slots on two lines, va09 a macro earlier on the line, va10 $strobe/$write, va11 package function, va12 class method, va13 two instances, va14 line comment then `,` at column 1, va17 two block comments, va18 generate loop, va20 three calls, va21 mixed tabs/spaces, va24 UTF-8 in a block comment, va25 multi-line block comment ending at the comma, va26 $error and $fatal, va27 CRLF + block comment + blank line, va28 trailing slots, va29 two calls on one line, va30 instantiated interface, va31 program | 24 STRICT_NOTEQUAL endline -> STRICT_EQUAL |
| VA | same | va05 leading slot across a line, va06 multi-line block comment then a space, va19 a comment-only line | 3 controls, STRICT_EQUAL on both, byte-identical |
| VA | same | va16 inactive `ifdef between the slots, va23 a `define between the slots | 2 residues, STRICT_NOTEQUAL endline on both, byte-identical (abstains) |
| VA | same | va15 the call itself from a macro (`D(...)), va22 the call in an `include file | NOT_EQUAL on both at the same dump distance (22, 77); golden has no INT:0 at all there, so the moved end is on an object golden lacks |
| VU | § emptySlotArgEndPrevTok441 | vu01 task, vu02 function, vu03 class method, vu06 trailing slot, vu08 interface task through an instance, vu10 multi-line block comment, vu12 two trailing slots | 7 STRICT_NOTEQUAL endline -> STRICT_EQUAL |
| VU | same | vu04 constructor, vu05 package function after a line comment, vu09 leading slot | 3 controls, byte-identical |
| VU | same | vu07 continuous assignment in two instances, vu11 generate-loop net initializer | NOT_EQUAL on both at the same distance (160, 74): golden folds the call and has no INT:0 there |
| VJ | § uninstIfaceIncDecBinds441 | vj01 initial unnamed local, vj02 always automatic local, vj03 static local, vj05 fork + delay, vj06 struct member, vj07 parameterized interface + foreach, vj08 event control + modport, vj09 expression position, vj10 beside a top, vj12 ref/inout/output formals + final, vj14 named-block local, vj18 nested unnamed blocks, vj19 automatic function + task, vj20 a task local read in an unnamed block inside a named block, vj21 an unnamed local read in a named block | 15 NOT_EQUAL -> STRICT_EQUAL |
| VJ | § unnamedLocalUnderNamedBinds441v | vj11, vj16, vj22 (interface) | NOT_EQUAL -> STRICT_EQUAL (law alone: vj11 closer 4 -> 2, vj16 and vj22 byte-identical to pristine) |
| VJ | § unnamedLocalUnderNamedBinds441v | vj17 (program) | NOT_EQUAL on both, dump distance 17 -> 15; the 15 lines left are only the sister's program-net listing face (golden lists the task local inner as a program net); its uhdm-cmp count grows 31 -> 414 only because the first difference moved from the variable to the program object, which uhdm-cmp prints whole |
| VJ | controls | vj04 for/case bodies, vj13 an instantiated interface, vj15 a named-block local read from an unnamed block | byte-identical, STRICT_EQUAL |

Totals pristine -> verified: 49 to STRICT_EQUAL, 1 closer (vj17), 4 moved on
objects golden lacks at the same distance, 2 residues and 9 controls
byte-identical, NONE further from golden. Law -> verified moves exactly vj11,
vj16, vj17 and vj22.

Switches on all 107 case dirs (the 65 above, the implementer's 40, v11u439 VI/vi07
and vi08): R11U441_OFF on the verified binary gives pristine's bytes and exit
code on 107 of 107 (evidence/grid_R11U441_OFF.tsv); R11V441_OFF and
R11V441_NAMEDNEST_OFF each give the law's bytes on 107 of 107.

The implementer's 42 grid lines (EA, EU, II, VI/vi07, vi08) reproduced exactly on
exit code, uhdm-cmp count, dump distance and strict verdict.

Downstream (drivers/dsgrid.py, evidence/downstream_*.tsv) on the 37 class-,
interface- and program-free VA and VU cases: 36 IDENTICAL and 1 EQUIVALENT on
both pristine and verified; no case changes verdict.

## Refinement census (drivers/census.sh, evidence/refinement_census.tsv)

The 402 fence-filtered tools/probe dut.sv dirs holding an interface or program,
a ++ or --, and a named begin, run on law and verified (traced): exit codes
equal on all 402 (398 at 0, 4 at 3 on both since they need more files), 0 byte
movers, 0 refinement firings. Positive control: VJ/vj16 traced on verified logs
`unnamedLocalUnderNamedBinds441v inner`.

## Sweeps (one per binary; evidence/prediction.txt written before the verified sweep's results)

Both sweeps through drivers/fullsweep.sh with workdirs of the control's length
(/tmp/v11u441_LW, /tmp/v11u441_VW), the machine quiet before each launch (no
sweep, runner or check process).

| stage | law (caf5b613) | verified (c4efdfa2) |
|---|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64, 0/0/0, csv identical to the control, 4087 of 4087 databases identical to the control by path-normalized dump (positive control 3344 lines) | the same, csv identical to the law sweep's |
| surelog | default 480 CMP_EQUAL + 4 CMP_NOTEQUAL, testflags 474 + 4, 0/0/0; csv differs from the control only in the two LowMem log-path texts | the same |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0, csv identical | the same |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, csv identical | the same |
| sv-tests | EQUAL 1913, STRICT_NOTEQUAL 0, DIFFERENT 27, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions 0, conversions 1 (the checker), changes 0 | the same, csv identical to the law sweep's |
| byteverify vs control (SELFCHECK=1) | 0/962, 0/1608, 0/805 (self-checks 961, 1607, 804) | the same |
| canaries | ok=52, ok=16, ctcan2 PASS both | the same |
| binary audit (fence-filtered cmds.txt) | surelog 1523 of 1573 name law (the 50 others hold only a Surelog line), uhdm2rtlil 1740/1740, sv-tests 2346/2346 | the same naming verified |
| trace | one line: sysCallEmptyArgEndPrevTok441 on the checker | the same one line, as predicted |

The law sweep's corpus stage exited 1 only on the stale law index (my case dirs
were written before it); tests/LAWS.md was regenerated before the verified sweep,
which exited 0.

## Goal 1 (reproduced)

All 75 SURELOG_ONLY rows carry an upstream slang front-end `error:` diagnostic.
The probe shapes read upstream slang 0 and Surelog 3, ours 0, 4 and 4 on the
verified binary: v11u415 VT/vt03, v11u413 VC/vc04, v11u413 VI/vi06.
bp_unicore alone on the verified binary: rc 3 in 14.4 s at 831 MB (the substr
message under pass 403's size guard); the guard stands.

## Residues (all wrong on pristine too, none moved away)

1. The empty-argument end where the law abstains: an inactive conditional (VA/va16,
   EA/ea21) or a `define (VA/va23) between the slots, and a slot in a macro body (EA/ea15).
2. Empty arguments golden does not write as INT:0: a call from a macro (VA/va15),
   in an include file (va22), user calls in elaborated continuous assignments and
   generate net initializers which golden folds (VU/vu07, vu11).
3. The program twin of the named-block nesting rule leaves vj17 at the sister's
   program-net listing face.
4. The sequence instance's empty argument (EU/eu09) and the implementer's list
   (the two basejump definitions behind the sister's admission gate; the carried
   lists of passes 439 and earlier).

## Sister-ground faces (reported, not written)

- ModuleEmit's program road with TaskFuncEmit's locals: golden lists an
  uninstantiated program's task local declared in an unnamed block under a named
  block as a program net (work@prg.inner, VJ/vj17), the same face as pass 439's
  program net listing.
- UhdmExporter's never-instantiated definition admission for
  bsg_scheduler_dataflow and bsg_nonsynth_mem_1rw_sync_assoc (the implementer's
  report, confirmed by the sv-tests rows staying DIFFERENT).

## Process

Within the budget: no pristine build, no pristine sweep, one law build (md5 equal
to the implementer's law3), one verified build, one full five-stage sweep on each.
The verified build ran during the law sweep's corpus stage at nice 10, with -j 2;
no stage read a TIMEOUT beyond the standing one. Small case grids, the downstream case
grid and the census ran beside the law sweep, one process at a time. The fence list
was read into a file by a program without printing it, and every tree-wide list was
filtered on it before opening a file. No other agent's process was touched; no
fenced test was named, opened or run.
