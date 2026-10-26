# v11u440 — adversarial verification of r11u440 (module/type ground)

Verifier of pass 440, base e516a74d. The implementer's patch is /tmp/r11u440.patch.
This pass adds two production refinements, both in the implementer's own laws and
both behind their own switches (fixOn(440, ...), dropped by R11V440_OFF):

- § errTypeTsLocAsVector440v (R11V440_ERRTSLOC_OFF), in TypeEmit, inside
  § errTypePortSyntaxRange440.
- § defOnlyNetLaterDeclNoType440v (R11V440_LATERDECL_OFF), in ModuleEmit, inside
  § defOnlyAliasVarNoNetType440.

Neither is a break. Pristine was wrong on every case the refinements move, and the
law moved each of those cases closer but left a location or net-type field wrong.
UhdmExporter's change is the implementer's hunk, byte for byte. No src/R*.h, no getenv,
no reader function, no flag written across files.

## Verdict

**CONFIRMED with two refinements.** The implementer's numbers reproduce bit for bit.

The law binary was rebuilt once in /tmp/wt_v11u440:
- md5 fe74127763ae0595f92c247852c07831, equal to the implementer's law6.
- It links slang 12.0.0+545f88b2e.

The pristine binary is the implementer's frozen copy:
- md5 23f0fa7a9de9d5325d1ebc88ea697778, equal to the main tree's build at the base.
- No pristine build and no pristine sweep: the pristine reading is the master's control /tmp/intr11u438.

The final verified binary has md5 f435d6cfd839f92f3591a0a24ba51239.

| sv-tests row | base golden | law (sweep /tmp/v11u440sw1) | verified (sweep /tmp/v11u440sw2) |
|---|---|---|---|
| generated/basejump/bsg_noc_BaseJumpSTL_bsg_mesh_stitch.sv | DIFFERENT | EQUAL,,equal | EQUAL,,equal |
| generated/basejump/bsg_dataflow_BaseJumpSTL_bsg_round_robin_fifo_to_fifo.sv | DIFFERENT | EQUAL,,equal | EQUAL,,equal |
| generated/basejump/bsg_misc_BaseJumpSTL_bsg_dff_en_segmented.sv | DIFFERENT | EQUAL,,equal | EQUAL,,equal |
| generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_ascii_writer.sv | DIFFERENT | EQUAL,,equal | EQUAL,,equal |
| generated/basejump/bsg_comm_link_BaseJumpSTL_test_bsg_comm_link_checker.sv | DIFFERENT | STRICT_NOTEQUAL,differ:endline(1) | STRICT_NOTEQUAL,differ:endline(1) |

Both sweeps read the same sv-tests counts:
- EQUAL 1911, STRICT_NOTEQUAL 2, DIFFERENT 27, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, SURELOG_ONLY 75, TIMEOUT 1 of 2346.
- regressions 0, conversions 5 (the five rows above), changes 0.

The verified sv-tests csv is identical to the law's on all 2346 rows. The law csv is
identical to the implementer's /tmp/r11u440sw6/svtests.csv.

The runner was rerun on the five rows alone with pristine and verified
(evidence/five_pristine.csv, five_verified.csv):
- Pristine: NOTEQUAL / DIFFERENT on all five.
- Verified: EQUAL / IDENTICAL on four, and JUDGE_EQUAL with differ:endline(1) on the checker.

## Gates (both sweeps: tests/sweep.sh --jobs 3, all five stages, trace on, launched after three quiet readings)

Sweep scope and timing:
- The four corpus stages ran through the worktree's tests/sweep.sh.
- The sv-tests stage ran through the main tree's scripts/check_svtests.py, with the baseline set to the worktree's results/golden_svtests.csv. The worktree's UVM submodule is empty, and scripts/ and tests/sweep.sh are unchanged between e516a74d and the main tree's HEAD.
- The law sweep's corpus run exited 1 only on the stale law index: verifier cases were added after the index was regenerated. The verified sweep exited 0.

| stage | law sweep | verified sweep |
|---|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, 0/0/0; csv identical to the control; all 4087 databases identical to the control by path-normalized dump (positive control flagged) | 0/0/0; csv identical to law; 0 of 4087 byte movers against law |
| surelog | default 480, testflags 474, 0/0/0; csv equal to the control except the two LowMem log-path texts | same; csv equal to law except the LowMem paths |
| uhdm2rtlil | 803 / 1 / 67 both modes, 0/0/0; csv identical to the control | identical to law |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; csv identical to the control | identical to law |
| svtests | 0 regressions / 5 conversions / 0 changes | identical csv |

Byteverify (SELFCHECK=1, per corpus):
- Law against the control: 0 of 962, 0 of 1608 and 0 of 805; the self-checks flag 961, 1607 and 804.
- Verified against law: 0 of 962, 0 of 1608 and 0 of 805, with the same self-checks.

Canaries and audit:
- ok=52 and ok=16 with changed=0 on both sweeps; ctcan2 EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6 PASS on both.
- Binary audit (verified sweep): surelog 1531 of 1581 cmds.txt name the verified binary, and the other 50 hold only a Surelog line. uhdm2rtlil 1742 of 1742; sv-tests 2346 of 2346.
- Goal 1, reproduced: all 75 SURELOG_ONLY details carry an upstream slang `: error`, and no row carries an exporter `unsupported` message.

The sweep trace matches the implementer's exactly: 52 databases.
- Surelog Earlgrey_0_1 default and testflags: § defOnlyAliasVarNoNetType440 on 3 variables, 0 byte movers.
- 50 sv-tests rows.

The refinements fire only on bsg_mesh_stitch:
- § errTypeTsLocAsVector440v fires on its 6 ports, an implicit ANSI port typespec at its first dimension, which is the law's own location. The row stays EQUAL.
- § defOnlyNetLaterDeclNoType440v fires nowhere in the sweep.
- The kept non-EQUAL sv-tests databases on which the laws fire (control_slave, checker, mem_1rw_sync_assoc, scheduler_dataflow, rsd) are dump-identical between law and verified.

Determinism: three concurrent verified draws of each of the five converted rows read one dump each.

## Reproduction of the implementer's grid and census

- Grid: the 50 case dirs reproduced on law exactly (evidence/grid_impl_reproduced_law.txt, the md5 column included), with R11U440_OFF and each case's own switch as claimed.
- Earlier-pass census: the 5332 fence-filtered case dirs of tools/probe/r11u4*repro and v11u4*repro (evidence/earlier_pass_census_5332.txt).
  - Exit codes are equal everywhere: 5306 rc 0, 18 rc 4 and 8 rc 3 on both binaries.
  - Exactly the implementer's 7 byte movers, judged in evidence/earlier_pass_movers_judged.txt:

| case | pristine | law | dump distance (unsorted / sorted) |
|---|---|---|---|
| r11u405 PH/ph01 | NOT_EQUAL | STRICT_EQUAL | 27/27 -> 0/0 |
| r11u434 TC/tc09 | NOT_EQUAL | STRICT_EQUAL | 84/26 -> 72/0 |
| v11u434 VT/vt17 | NOT_EQUAL | STRICT_EQUAL | 32/26 -> 6/0 |
| v11u434 VT/vt20 | NOT_EQUAL | NOT_EQUAL | 27/27 -> 1/1 |
| v11u434 VT/vt09 | NOT_EQUAL (68 lines) | NOT_EQUAL (493 lines) | 122/42 -> 142/20 |
| r11u424 BV/bv02 | STRICT_EQUAL | STRICT_EQUAL | bytes only |
| v11u424 VK/vk05 | STRICT_EQUAL | STRICT_EQUAL | bytes only |

  vt09: pristine's uhdm-cmp head is the definition copy's `$clog2(W)-1` operation, the face the law writes. The law's head is the module listing, where golden has one elaborated typedef copy per instance. Pristine and law differ in that one bound only.

- Widened census, not run by the implementer (evidence/widened_census_12328.txt, widened_movers_judged.txt): the 12328 fence-filtered case dirs outside r11u4*/v11u4* whose sources hold `typedef` or an undefaulted parameter.
  - Exit codes are equal everywhere: 12169 rc 0, 137 rc 3 and 22 rc 4.
  - 7 movers, all toward golden:

| case | pristine | law | sorted dump distance |
|---|---|---|---|
| r10rgg4repro/d6_typedef_range | NOT_EQUAL | STRICT_EQUAL | 21 -> 0 |
| r11u141verify p134_elabnetalias/l03_sub_twice | NOT_EQUAL | STRICT_NOTEQUAL type | 83 -> 62 |
| r11u261repro A/a07_typedef | NOT_EQUAL | STRICT_NOTEQUAL fullname | 49 -> 18 |
| v11u134repro grid/nb01 | NOT_EQUAL | STRICT_NOTEQUAL type | 41 -> 20 |
| r10vrgg4repro/w1_var_kinds | NOT_EQUAL | NOT_EQUAL | 43 -> 22 |
| r11u103repro b09_F_pkgstruct | NOT_EQUAL | NOT_EQUAL | 4 -> 3 |
| r11v35repro v1_elab35 | NOT_EQUAL | NOT_EQUAL | 124 -> 107 |

- All 14 movers of both censuses are byte-identical between law and the final verified binary. A traced verified run fires only § defNetModTdCloneBoundSyntax440 and § defOnlyAliasVarNoNetType440 there.

## Attack grid (89 fresh case dirs; drivers/grid3.sh; evidence/grid3_final.txt)

Every case is accepted by upstream slang (~/.local/bin/slang with the case's --top and --single-unit). VE/ve04 and ve13 were rewritten once until slang accepted them, VP/vp09 has no top in slang, and every exit code is equal on all three binaries. Groups:

- VA: 22 dirs on § defNetModTdCloneBoundSyntax440.
- VN: 17 dirs on § defOnlyAliasVarNoNetType440, and on § defOnlyNetLaterDeclNoType440v for vn11 and vn16.
- VX: 10 dirs on § defGenConnVarSelIdxPart440.
- VP: 19 dirs on § undefaultedPlaceholderRetry440.
- VE: 21 dirs on § errTypePortSyntaxRange440, and on § errTypeTsLocAsVector440v for ve04, ve09 to ve13, ve20 and ve21.

**Pristine -> verified**

- **44 NOT_EQUAL -> STRICT_EQUAL:**
  - VA: va01, va02, va04, va05, va06, va15, va16, va18, va20 (a `$clog2` bound, a parenthesized bound, a localparam, `bit signed`, two packed dimensions, a program, an override, `[w-1:w/2]`, a used variable).
  - VN: vn01 (a type parameter), vn02 ($unit typedef), vn04 (unpacked typedef), vn07 (reached only from `if (0)` with no explicit top), vn08 (`if (0)` in top), vn11, vn12 (imported and scoped package types), vn14, vn15, vn16.
  - VX: vx01 to vx07, vx09 and vx10: `-:`, base k*w, width w/2, three dimensions, a nested generate-if, no explicit top, an output connection, a genvar base, a parenthesized base.
  - VP: vp06, vp07, vp11, vp13 to vp19. These include a type parameter, a generate loop bound and an unpacked memory bound that the retry sets to "inv" or 8; none hangs, each case runs in about a second.
  - VE: ve04, ve09, ve10, ve11, ve13 and ve21. These are closed only by § errTypeTsLocAsVector440v; the law reads STRICT_NOTEQUAL col on each.
- **20 STRICT_EQUAL on both binaries, byte-identical controls:** va12, ve01 to ve03, ve05 to ve08, ve14 to ve16, ve18, ve19, vn03, vn05, vn13, vp01, vp08, vp10, vp12.
- **10 NOT_EQUAL on both binaries, closer by dump distance and none further:**

| case | unsorted | sorted |
|---|---|---|
| VA/va03 | 52 -> 38 | — |
| va10 | 61 -> 8 | — |
| va11 | 32 -> 10 | — |
| va13 | 23 -> 4 | — |
| va14 | 65 -> 23 | — |
| VE/ve12 | 159 -> 17 | — |
| ve20 | 207 -> 138 | 205 -> 2 |
| VN/vn09 | 7 -> 6 | — |
| VP/vp02 | 190 -> 6 | — |
| VX/vx08 | 23 -> 13 | — |

  ve20's uhdm-cmp count grows 107 -> 214. The typespec set now equals golden's, and only the listing order of the error-typed port and net typespecs differs.
- **14 NOT_EQUAL and byte-identical:** va07, va08, va09, va17, va19, va21, va22, ve17, vn06, vn17, vp03, vp04, vp05, vp09.
- **1 exit 4 on both:** VN/vn10, `typedef C ct;` of a module-local class, 'typedef target: ClassType', the carried VC/vc13 face.

Switches:
- R11U440_OFF gives pristine's bytes on all 139 case dirs (the implementer's 50 and these 89).
- R11V440_OFF gives the law's bytes on all 139.
- Each refinement's switch gives the law's bytes on its own cases. Across the 139 dirs, verified differs from law on exactly those 10.

Downstream (drivers/dsgrid.sh):
- The 67 first-wave attack cases on law (every first-wave case but VN/vn10's class): va16 EQUIVALENT -> IDENTICAL, va22 EQUIVALENT on both, the other 65 IDENTICAL on both (evidence/downstream_attack_law.txt).
- The 10 verified movers and the control vn17 are IDENTICAL on pristine and verified (evidence/downstream_verified_movers.txt).
- None of these cases leaves IDENTICAL.

## The two refinements

### § errTypeTsLocAsVector440v (R11V440_ERRTSLOC_OFF)

The law located every error-typed vector typespec at its first packed dimension (from the keyword for `bit`). That is right only for an implicit ANSI port type, the bsg_mesh_stitch shape.

The usable-value twins VE/ve14 to ve19 read STRICT_EQUAL on pristine, so golden locates such a typespec the same way it locates the same declaration's usable vector:
- **Keyword type:** from the keyword. Golden: `reg [x-1:0][0:2] r` 3:3, `logic signed [..]` 4:3, `input logic [..][..] a` from `logic`, non-ANSI `output reg [..][..] q` from `reg`.
- **Implicit type with a net keyword:** from the net keyword (`input wire [..][..]`, `wire [..][..] n`).
- **Implicit signed type:** at the signing.
- **Implicit port type:** at its first dimension.
- **Ends:** a port ends at its last dimension. A body declaration with two or more packed dimensions, no unpacked dimension, no initializer and no `var` ends at its first, which is writeNets' packed-slot end. That end rule is § defNetEndOnlyLoc130's, and it does not reach an error type because slang's error type is not a packed array.

The law read STRICT_NOTEQUAL col on ve04, ve09, ve10, ve11, ve13 and ve21. The verified binary reads STRICT_EQUAL on all six, and MS/ms01 to ms06 and bsg_mesh_stitch are byte-identical to law.

### § defOnlyNetLaterDeclNoType440v (R11V440_LATERDECL_OFF)

In a never-elaborated definition, golden gives the keyword's net type only to the FIRST declarator of a net declaration:
- VN/vn16 `wire t a, b, c; tri t d, e;`: golden a 1, d 4, and b, c and e none.
- VN/vn11 `wire t w1 = 4'h3, w2;`: w2 none.

Pristine wrote 36 on all of them and the law wrote the keyword's type on all of them. vn11 and vn16 go NOT_EQUAL -> STRICT_EQUAL. The refinement does not apply once the module is instantiated (VN/vn17, 36 everywhere in the definition, byte-identical).

Builds: the verified binary took three builds, recorded as a deviation:
- The first two had the location rule without, and then with an over-broad, body end rule. Both were used on case runs only.
- The first verified sweep, launched on the second, was stopped by its own task id while still in its quiet wait, before any stage ran, to add the later-declarator rule.
- A comment-only edit afterwards rebuilt to the same md5.

## Residues (all wrong on pristine too; none moved away)

1. **§ defNetModTdCloneBoundSyntax440's syntax bound uses emitSyntaxExpr's naming and binding, not the typedef listing's:**
   - A package-scoped p::W (VA/va03) and a wildcard-imported W (va14) stay a ref_obj where golden folds them to UINT constants.
   - A $unit parameter (va13) is bound to the parameter where golden leaves the ref_obj unbound.
   - A user call `f(w)-1` (va11) spans 4:18-4:22 where golden spans the name only, and binds no vpiFunction where golden binds one.
   - The law does not reach a typedef of a typedef (va09), an interface typedef (va07), a non-ANSI port typed by the typedef (va08), `$bits(clk)*w` (va17), an unpacked use (va19), a struct member (va21) or a generate-block typedef (va22). Also carried: the per-instance elaborated typedef copy (TD/td19, td20, v11u434 VT/vt09).
2. **Error-typed declarations:**
   - The typespec listing order of error-typed ports and nets (VE/ve20).
   - `wire logic [..][..]` and `var [..][..]` typespec ends (ve12, the general path's face on ve17 too).
   - MS/ms01's `'0` sized -1.
3. **defOnly net types:** an interface definition (VN/vn06) and non-ANSI ports typed by a typedef (vn09, 36 kept on the ports where golden has none).
4. **Placeholder retry:** two scalar parameters both needing a string (VP/vp05) still abstain. `parameter int ws[n-1:0]` with `logic [ws[i]-1:0]` in a generate loop (vp03) and a string array (vp04) stay where pristine was. A top-level module with an undefaulted parameter (vp09) has no slang top.
5. **Indexed part-select:** a package-scoped base p::B+:w (VX/vx08) stays a ref_obj where golden folds it to UINT:2.
6. **Carried:** the implementer's ranked residues (the 16 uvm-examples rows in two families, control_slave's defaulted "inv", the elaborated indexed-select copies VI/vi01 to vi03, vi05 and vi06, TD/td10, td17, td22, NT/nt03, MS/ms01 and ms02, easyUVM, the 3 scoreboard rows, p733, p737, tnoc) and the lists of passes 438 and earlier.
7. **Exit 4:** the module-local class typedef (VN/vn10, 'typedef target: ClassType').

## Sister-ground faces (reported, not written)

- **ExprEmit:** the checker row's last strict field, the empty system-call argument (`$display(..., core_1_period_p, , ...)`, test_bsg_comm_link_checker.sv 119/120). Golden writes INT:0 ending at the previous line's end.
- **ExprEmit and StmtEmit:** the invalid placeholder statements of bsg_scheduler_dataflow (187:12, an undeclared name) and bsg_nonsynth_mem_1rw_sync_assoc (41:13, a nonblocking write to an associative element). They keep pass 404's abstention.

Both are the implementer's findings, confirmed on the kept databases.

## Process

Measurements:
- One law build, three verified builds (above), one full sweep on law and one on the final verified binary. Each sweep was launched after three quiet readings.
- No pristine build and no pristine sweep.
- Case grids and the censuses ran with at most 3 jobs, while no sweep or runner of the sister pass was live (checked with pgrep before each batch). The widened census and the verified builds overlapped each other.

Slips, none affecting a measurement:
- One byteverify call was first run on the whole sweep root, which mixes the sv-tests kept databases, and refused with PATH_SETS_DIFFER. It was rerun per corpus.
- The first probe dump comparison kept uhdm-dump's header line, which names the database path, and flagged every case. It was rerun without that line: 4087 identical, with a positive control flagged.

Fence and isolation:
- The fence list was read into a file by a program from tools/probe/r11u107repro/canaudit.sh without printing it, and every tree-wide list (both censuses) was filtered on it before any file was opened.
- No other agent's process was touched, and no fenced test was named, opened or run.
- Nothing was written outside /tmp/wt_v11u440, /tmp/v11u440_* and /tmp/v11u440sw{1,2}.

## Files

- drivers/: the implementer's drivers with this pass's paths (run1.sh, grid.sh, dist.sh, cmp.sh, ddiff.sh, dsgrid.sh, bytecensus.sh, quiet.sh, fullsweep.sh, switches.txt), plus grid3.sh, which reports pristine, law and verified with the switch columns.
- evidence/:
  - Both sweeps' logs, csv diffs, traces and byteverify readings.
  - The probe dump comparison.
  - The reproduced implementer grid, the attack grids (law waves 1 and 2, and grid3_final for all 139 dirs on three binaries), the downstream grids, both censuses with their judged movers, and the five-row runner csvs.
