# v11u469 — adversarial verification of r11u469

Verdict: **CONFIRMED, no break, no production change.** The verified patch's src diff is byte-identical
to the implementer's (/tmp/r11u469.patch, md5 e81233ba85bdf217fcf4a3400f399a37). This repro dir and the
regenerated tests/LAWS.md are the only additions.

Base fe1067e0c (pass 467). Laws under test, both in src/ParamEmit.cpp at the end of drainPaNameCopySrc38:
§ importCopyTsInstByRole469 (`R11U469_IMPTSINST_OFF`) and § importEnumCloneHomeInst469
(`R11U469_IMPENUMINST_OFF`); `R11U469_OFF` drops both. No src/R*.h, no getenv, no reader definition in the
added lines; the switches go through lawOn and the trace through lawTrace.

## Binaries (frozen)
- pristine: /tmp/v11u469_bin/pristine, a copy of the main tree's build/slang-uhdm, md5 c9b2f893019899967f666555de7bc9e8 (no pristine build, per the budget).
- law: /tmp/v11u469_bin/law, rebuilt once from the patch on a fresh fe1067e0c (-j 2), md5 914aca3fab82ab18ffce129b445c3537,
  equal to the implementer's law4, linking slang 12.0.0+545f88b2e.
- No verified build: nothing was changed.

## One five-stage sweep on the law binary (workdir /tmp/v11u469_sw, trace on; evidence/sweep/)
Four corpus stages ran from the verifier worktree. The sv-tests stage ran through the main tree's tests/sweep.sh,
because the worktree's UVM folder is empty. Both commands exited 1 on the law index alone: the worktree's own index
went stale once this repro dir's cases were added, and the main tree's index is stale against the pass.

| stage | result | csv vs the control /tmp/intr11u467 |
|---|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0 | identical |
| surelog | 480 + 0 / 474 + 0, 0/0/0 | equal except the two LowMem log-path texts |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | identical |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 | identical |
| svtests | EQUAL 1931, STRICT_NOTEQUAL 0, DIFFERENT 9, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; 0/0/0 | identical |

- **byteverify** (SELFCHECK=1, law sweep against the control; evidence/byteverify/):
  - surelog 8 of 962: BlackBePipeInt, HierPathOverride, MiniAmiq and SeqDriver, each in both modes.
  - uhdm2rtlil 4 of 1608: BitSelectOfParameterPassedToSubmodule and ibex_tracer, both modes.
  - downstream 2 of 805: the same two rows.
  - Every self-check flagged n-1 of n.
  - Exactly the implementer's predicted movers. Every mover keeps STRICT_EQUAL under the canonical walk (STRICT_NOTEQUAL depth under --no-canon on both binaries, identical object counts).
  - The import-copy role census (rolecmp) against the cached golden reads 66 -> 0 (BlackBePipeInt), 2 -> 0 (HierPathOverride, BitSelectOfParameterPassedToSubmodule), 14 -> 0 (MiniAmiq, SeqDriver) and 134 -> 0 (ibex_tracer).
  - The chain census (evidence/tools/chains.cpp) finds no change outside the importing packages' import copies.
- **probe**: 72 of 4087 databases differ from the control by path-normalized dump. That is exactly the implementer's predicted list (66 r10v160repro, the rest r11u114, r10uvm114/23/82 and r10v169). None has a chain change outside the import copies, and every one stays EQUAL.
- **trace**: fired on exactly 107 databases (72 probe, 8 surelog, 4 uhdm2rtlil, 2 downstream, 21 sv-tests). The 21 sv-tests rows and their per-row firing counts are identical to the implementer's evidence/prediction/sv_trace_firing_rows.txt, and every one keeps its golden status.
- **Canaries**: ok=52 and ok=16. ctcan2 PASS for surelog (ok=58, 1 unknown) and uhdm2rtlil (ok=2, 6 unknown).
- **Binary audit** (fence-filtered; evidence/sweep/binary_audit.txt):
  - surelog: 1523 of 1573 records name the law binary; the other 50 hold only a Surelog line.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346.
  - No record names any other slang-uhdm binary.

## The implementer's grid, reproduced (31 dirs; evidence/grid.txt)
On both binaries every exit code, uhdm-cmp line count and strict verdict equals the implementer's grid_law4.txt
row for row.

- 11 dirs reach STRICT_EQUAL.
- ir07 goes NOT_EQUAL 312 -> STRICT_NOTEQUAL fullname.
- ir12, ir13, ir14 and ia01 are byte-identical.
- ir08 (64 -> 112) and ia12 (50 -> 64) grow in uhdm-cmp lines because the head moved later. ir08's head is now the module copy work@top.PB's typespec. ia12's head is now a constant at 13:19 in module top. In both, the package listing is now golden's.

## Switch checks (evidence/switch_check.txt; all 59 dirs, both grids)
- `R11U469_OFF` restores pristine's bytes on 59 of 59.
- 37 dirs are moved by § importCopyTsInstByRole469 alone and 16 by § importEnumCloneHomeInst469 alone. Each is restored by its own law's switch alone.
- 6 dirs do not move. No dir needs both laws.

## Attack grid: 28 fresh case dirs (cases/VE, VM, VT)
Every case is accepted by upstream slang (~/.local/bin/slang --single-unit, real exit code read; evidence/upstream_slang_accept.txt).

During construction, four first drafts failed the upstream check:
- ve04 and vt06 used `export *::*` on an unreferenced import. They were rewritten to `import a::PE; export a::PE;` (and `a::PA` for vt06).
- vt14's draft used `export b::*`, which was removed.
- Two drafts that typed a package parameter with a $unit typedef are illegal SV. Upstream slang rejects them and so do both binaries (exit 3), so they were deleted.

Every exit code is 0 on both binaries. `roles` is the implementer's rolecmp mismatch count (per-hop instance view of the import-copy roles against golden).

| result | cases |
|---|---|
| -> STRICT_EQUAL (10) | ve02 (enum type from a third package), ve05 (importer's own parameter of the enum type), ve06 (explicit imports), ve07 ($unit import of the importer), ve09 (re-typedef in the importer), vt04 (one-bit and int unsigned typedefs), vt05 (explicit imports, two parameters), vt09 (diamond), vt13 (pure chain c->b->a), vt15 (importer's own typedef named t) |
| closer, uhdm-cmp lower, head later (7) | ve12 414 -> 50, vm01 64 -> 50, vm02 358 -> 17, vt08 282 -> 50, vt12 414 -> 46, vt14 282 -> 50 (roles -> 0 in each); vt02 stays STRICT_NOTEQUAL fullname (roles 1 -> 0) |
| closer, same uhdm-cmp head (8) | ve01 diamond roles 20 -> 10, ve03 re-export 10 -> 5, ve08 two importers 20 -> 10, ve10 enum chain 10 -> 5, ve04 / vt06 re-export 10 -> 0 / 12 -> 0, vt11 function default 6 -> 2, vt03 union (STRICT_EQUAL both) 2 -> 0 |
| moved, instance views now golden's, kind still differs (1) | vt10 packed array of a typedef (golden packed_array_typespec, ours bit_typespec on both binaries) |
| byte-identical (2) | vt01 (typedef of an enum typedef), vt07 (re-typedef of another package's typedef; the law abstains by design) |

**None moved away.** The chain census over every attack dir finds collateral outside the importing packages in
only two dirs: IA/ia07 and VE/ve07, the design-level $unit copy's right-side constant. In both it moves to golden's chain
(a!TOP at every hop), and both reach STRICT_EQUAL.

**Downstream** (evidence/downstream/cases.txt): IDENTICAL on both binaries for VE/ve04, ve12, VM/vm01 (2 gates),
vm02 (4 gates), VT/vt06, vt08, vt14 and the implementer's IR/ir07, IA/ia04 and ia12.

## Away census (evidence/away_census.txt, away_movers_grid.txt, away_movers_class.txt)
946 earlier case dirs were run on both binaries: r11u453, r11u467, r11u465, r11u461, r11u458, r11u457, r11u454, r11u451, r11u402, r11u214dec and r11u146, with their verifier twins where present.

| outcome | dirs |
|---|---|
| exit 0, byte-identical | 859 |
| exit 4, byte-identical | 5 |
| exit 3, bytes differ (as they do between two pristine runs) | 3 |
| exit 0, bytes move | 79 |

No exit code moved. The 79 exit-0 movers, measured against golden:
- 5 -> STRICT_EQUAL, the pass's targets: r11u453 evidence/residue/TS/ts02, r11u461 evidence/decode/RX/rx01, r11u467 UC/uc02, v11u453 VO/vo07, v11u467 VU/vu11.
- 73 keep their verdict with the role mismatch count lower.
- 1, r11u453 XP/xp05 (explicit re-import of a typedef'd parameter), grows 64 -> 286 uhdm-cmp lines. Its head moved later: from the package param_assign constant at 4:20 to module_inst work@top's import copy work@top.PA. The package listings are now golden's (roles 6 -> 0) and the dump distance falls 319 -> 218. This is caution (y) of pass 461, a re-paired walk, not a break.

## Goal 1 and item (a)
Goal 1 was not re-measured beyond the sweep: the sv-tests csv is identical to the control on all 2346 rows, and no exit
code moved on any corpus row, probe case or case dir.

The implementer's head census of the four unreached rows and the sister's two was not repeated by a fresh head
walk. The rows' statuses read DIFFERENT on the law binary, identical to the control.

## Residues (all wrong on pristine too, none moved away)
1. **The enum clone shared by several importers** (ve01 diamond, ve03 re-export, ve08 two importers, ve10 chain).
   - Our listing instances the shared enum clone at the last importer.
   - § importEnumCloneHomeInst469 fires only where the instance is the importer itself, so the earlier importers' listings keep the last importer's instance where golden has the home.
   - Half of the roles are left in each case.
2. **A typedef of an enum typedef** (vt01) and **a re-typedef of another package's typedef** (vt07, the implementer's ir12 and ir13). The law abstains by design.
3. **vt10, a packed array of a typedef**: golden writes packed_array_typespec where ours writes bit_typespec. The kind face is older; the instance views now match.
4. **The next heads in modules**: module copies of imported typedef parameters (ir08, xp05's work@top.PA, vm01, vt08, vt14) and a module initializer reading a home parameter (ia12). These are on the import-copy listing of modules, not touched by this pass.
5. **The re-export shapes ve04 and vt06** at older uhdm-cmp faces (682 and 638 lines, unchanged).
6. **The implementer's residues stand as listed**: ia11, ie05, ia03, ia06, ia08 to ia10, ir09, ie03, ie04.

## Process
- Fresh worktrees /tmp/wt_v11u469 (patch applied clean) and /tmp/wt_v11u469pris (unused, no build). Scratch is /tmp/v11u469_*.
- One law build, one five-stage sweep, launched after pgrep showed no sweep or runner live. No other agent's process was touched.
- The fence list was read into a file by a program without printing it. Every tree-wide list was filtered on it, and this repro dir scans clean. No fenced test was named, opened or run.
- My one slip affected no measurement: a cleanup glob over /tmp/tmp.* in a byteverify command was refused by the permission layer and dropped; byteverify's own mktemp lists stay in /tmp.
