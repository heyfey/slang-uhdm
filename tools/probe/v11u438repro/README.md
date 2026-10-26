# v11u438 — adversarial verification of r11u438 (module/type ground)

Verifier of pass 438 (the whole-name and net-declaration unsized-constant
clone legs), base 82e1e458. **Verdict: CONFIRMED, no production refinement.**
The patch's src/ModuleEmit.cpp hunks are carried byte-identical; this
directory adds 56 fresh attack case dirs, drivers and evidence, and
tests/LAWS.md is regenerated with them.

## Headline numbers reproduced

| claim | implementer | verifier |
|---|---|---|
| law binary md5 (rebuilt once, -j 2, worktree /tmp/wt_v11u438) | a59709b933e2dbc6e3098e2fb6786d3b (law5) | a59709b933e2dbc6e3098e2fb6786d3b |
| pristine binary md5 (frozen copy of the base build, no rebuild) | a1389d52cb05d259babaa70fa64f23a7 | a1389d52cb05d259babaa70fa64f23a7 |
| generated/fx68k/fx68k.sv | STRICT_NOTEQUAL differ:fullname(4) -> EQUAL | `generated/fx68k/fx68k.sv,EQUAL,,equal`; uhdm-strictcmp STRICT_EQUAL 82353 objects, uhdm-cmp 0 lines |
| sv-tests stage | 0 / 1 / 0 | regressions=0 conversions=1 changes=0; EQUAL 1907, STRICT_NOTEQUAL 1, DIFFERENT 32, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346 |
| probe | 4019 + 68, 0/0/0 | EQUAL 4019 + STRICT_NOTEQUAL 68, 0/0/0 |
| surelog | 480 + 0 / 474 + 0, 0/0/0 | same |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | same |
| downstream | 803/66/2/0 | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not identical and not excused 0 |

The one full five-stage sweep ran on the LAW binary itself (law5; the
implementer's sweep was on law4), workdir /tmp/v11u438_L, trace on
(drivers/fullsweep.sh: the four corpus stages through the worktree's
tests/sweep.sh, the sv-tests stage through the main tree's
scripts/check_svtests.py, byte-identical to the worktree's, with the
worktree's results/golden_svtests.csv as baseline, since a worktree has no
UVM tree). The sweep exits 1 on the law index alone (stale because of this
directory's cases; regenerated into the patch). Against the master's control
/tmp/intr11u436: probe, uhdm2rtlil and downstream csvs identical, surelog
differing only in the two LowMem log-path texts, svtests only in the fx68k
row. The five csvs equal the implementer's law4 sweep (/tmp/r11u438_L) apart
from the LowMem paths. This is the first full five-stage reading of law5.

- Trace census (R11U438_TRACE, evidence/sweep_trace.txt): exactly two
  firings in the whole sweep, `caPlainLhsUnsizedClone438 work@fx68k.uaddrDecode
  1815` and `... 1816`; no ABSTAIN line, no firing on any probe case, corpus
  row or other sv-tests row.
- byteverify law against the control (evidence/byteverify_law_vs_control.txt,
  SELFCHECK=1, per stage): surelog 0 of 962, uhdm2rtlil 0 of 1608,
  downstream 0 of 805, the self-checks flagging 961, 1607 and 804.
- Path-normalized dumps (drivers/dcmp.sh): probe 4087 of 4087 identical to
  the control (evidence/probe_dump_compare.txt); kept sv-tests databases 53
  of 53 identical (tnoc left out, no law fires on it;
  evidence/svtests_dump_compare.txt). The positive control is the grid: the
  same normalization moves on every VA/VG/VI/VN mover below.
- Canaries ok=52 changed=0 and ok=16 changed=0; ctcan2 surelog ok=58 PASS,
  uhdm2rtlil ok=2 PASS.
- Binary audit (fence-filtered workdir): surelog 1531 of 1581 cmds.txt name
  /tmp/v11u438_bin/law, the other 50 hold one Surelog line only; uhdm2rtlil
  1742 of 1742; sv-tests 2346 of 2346.
- Determinism: three concurrent fx68k runs on the law binary differ only in
  the one byte of their own output path (cmp -l: 0, 1, 1 bytes); STRICT_EQUAL
  82353 objects.
- The implementer's 43 grid lines (PU, ND) reproduced exactly on the rebuilt
  binary once the md5 column is stripped (evidence/impl_grid_reproduced.txt).
- Earlier-pass census (drivers/bytecensus.sh, 5228 fence-filtered case dirs
  of passes 401 to 436, evidence/earlier_pass_census.txt): exit codes equal
  everywhere (8 dirs exit 3 on both with no output); movers exactly the
  implementer's 5, r11u433 HX/hx01 to hx04 and v11u425 VQ/vq10, all toward
  golden; v11u417 VH/vh12 (law4's break) byte-identical to pristine.

## The decode, checked

third_party/Surelog/src/DesignCompile/UhdmWriter.cpp writeCont_assign: when
neither the named-delay, the plain-name operation, the typespec-flattening
nor the reduce-to-constant leg clones or simplifies, `DetectUnsizedConstant`
(a VpiListener over the whole Rhs, `VpiSize() == -1` on any constant)
clones the cell with `clone_tree(assign, ElaboratorContext(&s, false, true))`
and parents it under the instance; it never looks at the Lhs. A
net-declaration assignment's Lhs is the net itself, so the clone copies the
net. The four laws transcribe that leg for a whole-name Lhs and for module,
generate-scope and interface net declarations, abstaining where the reduce
leg runs first (a Rhs reading no net or variable, a user call).

## Attack grid (cases/VA, VG, VI, VN: 56 case dirs; evidence/grid_law.txt)

Every case's first line names its law; every one accepted by upstream slang
(~/.local/bin/slang --single-unit, with --top where a TOP file exists), every
exit code 0 on both binaries; R11U438_OFF and each case's own switch give
pristine's bytes on 56 of 56. Shapes: parameter overrides on two instances
in the index (va01, vn01), literal delay (va02, vn05), multiple assignments
and declarators (va03, vn08), instances in a generate loop (va04) and two
levels deep (va05), $signed (va06), memory and 2-D memory elements (va07,
va08, vn03, vg05), a struct member select (va09, vn04), a net or variable
with an initializer read by the select (va10, va11), '1 as an index (va12),
an implicit net Lhs (va13), output logic (va14), nested modules (va15,
vn12), strength (va16), indexed part-selects (va17, vn02, vg02), part
selects with an unconnected second instance (va18, vn09), -: (va19), a
package parameter in the index (va20), a user call (va21), sized controls
(va22, va28, va29), a generate-if assignment (va24), $clog2('h8) as index
(va25, vn10), a struct array element (va26, vn06), a net driven by an
assign (va27), a select feeding a ternary (va30), an explicit --top with an
uninstantiated spare module and two tops (va31, vn13, vn14), tri and wand
(vn07), a module top (vn11), generate-for, nested generate-if and
parameter-selected branches (vg01 to vg07), interface instances twice, with
a parameter, a memory and a modport (vi01 to vi04).

| pristine -> law | count | cases |
|---|---|---|
| STRICT_NOTEQUAL fullname -> STRICT_EQUAL | 21 | va01-va05, va07, va08, va10-va12, va14, va16-va19, va23, va25-va27, va30, va31 |
| STRICT_NOTEQUAL depth -> STRICT_EQUAL | 21 | vg01-vg07, vi01, vi03, vi04, vn01, vn03, vn05, vn07-vn14 |
| STRICT_NOTEQUAL on both, closer | 2 | va06 (dump distance 73 -> 8), va15 (26 -> 12) |
| NOT_EQUAL on both, closer | 4 | va20 (41 -> 6), vi02 (55 -> 20), vn02 (39 -> 4), vn06 (125 -> 118) |
| byte-identical (residues) | 4 | va09, va13, va21, vn04 |
| byte-identical (controls) | 4 | va22, va24, va28, va29 |

None moved away from golden by dump distance (evidence/dist_law.txt; a
distance of 2 is the output path line). vn06's uhdm-cmp count grows 756 ->
778 while its dump distance drops 125 -> 118: pristine already writes the
struct-typed net `wire st_t w = arr['h1]` as a struct_var, and the law's fresh
Lhs is a logic_net where golden has a struct_net (see residues).
Downstream (drivers/dsgrid.sh, evidence/downstream_cases.txt): all 56
IDENTICAL on both binaries.

NO FRESH CASE ON LEGAL SV WHERE PRISTINE WAS RIGHT AND THE LAW WRONG, so no
refinement and no verified build.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The carried sv-tests clusters of the implementer's list: the 16
   uvm-examples rows, the 3 uvm_scoreboard rows and easyUVM, the 8 basejump
   inv-placeholder rows, p737 and tnoc (report only).
2. This face, not reached: a struct-member select Rhs `s.f['h1]` (hier_path;
   rhsHasUnsized438 does not descend into a hier_path; golden clones; VA/va09
   and the net twin VN/vn04); an implicit-net Lhs (VA/va13); user calls with
   an unsized argument (VA/va21 and the implementer's pu06, pu21, pu22, nd14).
3. The clone's leftovers: the $signed call's ref_typespec named work@sub
   where golden names it work@top.u (VA/va06); nested-module names
   work@top::nest::q where golden has work@top.n.q (VA/va15, pass 436's
   nested-module ground); a struct-typed net declaration written as a
   struct_var with the law's fresh Lhs a logic_net where golden lists a
   struct_net (VN/vn06; the isStructNet test reads the shared object's kind).
4. Unrelated first differences on cases the law moves closer: a package
   parameter in an index (va20), an interface parameter override (vi02), a
   signed net-declaration typespec (vn02).

## Sister-ground faces

None new.

## Process

Within the budget: no pristine build and no pristine sweep (pristine reading
the master's control /tmp/intr11u436 and the frozen base build for case
runs), the law binary built once, one full five-stage sweep. The build, grid
and sweep waited for three quiet readings after the master's pass 435
integration sweep ended at 10:44; nothing of this pass overlapped another
sweep. The fence list was read into a file by a program from canaudit.sh's
FENCED= line and never printed; the census list was filtered on it by path
and file name before any file was opened. No other agent's process touched.

## Files

cases/VA (31), VG (7), VI (4), VN (14); drivers/ (run1.sh, grid.sh, sc.sh,
dist.sh, dsgrid.sh, quiet.sh, fullsweep.sh, dcmp.sh, bytecensus.sh,
switches.txt); evidence/.
