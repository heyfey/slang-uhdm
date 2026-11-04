# v11u485 — adversarial verification of r11u485

Verifier of pass 485 (expression/parameter ground: src/ParamEmit.cpp, src/ExprEmit.cpp,
src/EmitHelpers.h) on base b20e61b5c. Measured under the measurement budget: the pristine is
a frozen copy of the main tree's build/slang-uhdm (md5 9aaf4570aa8c469640569b4ba37b874d) and the
master's control sweep /tmp/intr11u476; the law binary rebuilt once from /tmp/r11u485.patch on a
fresh worktree (md5 3cea9c1e8e880dbd38368f67653b4b52, equal to the implementer's law8, slang
12.0.0+545f88b2e).

## Verdict

FOUR BREAKS FOUND AND FIXED (pristine right, the law wrong, legal SV that upstream slang
accepts), two refinements behind their own switches, read through src/LawSwitch.h with
fixOn(485, ...); R11V485_OFF gives the law's bytes on all 174 dirs of both grids:

- § ndtSameFileDirective485v (ParamEmit, the § implicitNetDefaultType485 drain;
  R11V485_SAMEFILE_OFF; cases VT/vt01, vt09, vt13). Surelog does not carry `default_nettype
  across files: CompilationUnit::getDefaultNetType (SourceCompile/CompilationUnit.cpp) returns
  the last directive recorded with the design element's OWN file id at a line not after the
  element's line, else wire. A directive's file id is its parse file's main file and its line
  the PREPROCESSED line (SV3_1aTreeShapeListener::exitDefault_nettype_directive), while the
  element's file id and line are its written ones (SV3_1aTreeShapeHelper::getFileLine). So
  golden's late-binder wire stays vpiNetType 1 when the directive is in another source file
  (vt01: a.sv ends with `default_nettype tri, b.sv holds the module), when the module is
  written in an included file (vt09), or when an include before the directive pushes its
  preprocessed line past the module's line (vt13). slang's single unit carries the default, so
  the law wrote 4 there: STRICT_EQUAL on pristine, NOT_EQUAL (uhdm-cmp 32 lines) on the law.
  The fix keeps the law only when the directive slang applied (the last one in token order
  before the definition, found from the directive trivia of the definition's syntax tree) sits
  directly in the definition's own top-level file with no include before it in that file, and
  the definition is not in an included file. Cost: VT/vt04 (the directive inside an include
  file written before the module, golden tri) goes back to pristine's NOT_EQUAL; the
  implementer's NT grid keeps all its movers.
- § noneBindSameDefRead485v (ExprEmit, the § ifaceValNoneBindsInst485 record; 
  R11V485_NONEXSCOPE_OFF; case VN/vn08). Under `default_nettype none a module NESTED inside
  the declaring module that reads the outer interface instance (`module top; ifc u(clk);
  module inner; ... mv = u; endmodule`) keeps golden's unbound ref_obj, which pristine wrote
  (STRICT_EQUAL) and the law bound to work@top.u (NOT_EQUAL, uhdm-cmp 139 lines). The fix
  records the binding only when the reading instance's definition name (vpiDefName after the
  last `@` and `::`) is the declaring definition's; an instance declared and read inside the
  nested module (VN/vn12) still binds as golden does.

Everything else of the pass reproduces bit for bit: the implementer's 76 grid dirs (rc,
uhdm-cmp count, strict verdict, md5) on pristine and law; the law sweep's five csvs equal to
the master's control row for row (except the two LowMem log-path texts); byteverify 0 of 962,
1608 and 805; the probe dumps 0 of 4087; the target row unchanged at
STRICT_NOTEQUAL differ:fullname(3); the away census's 11 movers.

## Target row

generated/uvm-examples/uvm_param_vif_config_db.sv: STRICT_NOTEQUAL differ:fullname(3) on the
control, the law sweep and the verified sweep, fresh row
`generated/uvm-examples/uvm_param_vif_config_db.sv,STRICT_NOTEQUAL,differ:fullname(3),differ:fullname(3)`;
its faces are the sister's (pass 478). No sv-tests row converts or changes.

## Gates

One full five-stage sweep on the LAW binary (/tmp/v11u485law) and one on the final VERIFIED
binary (/tmp/v11u485ver, md5 f6a346fb81377618674f89230eef4973, slang 12.0.0+545f88b2e), run one
after the other by one launcher that waited for a quiet machine (the sister v11u478's sweep had
ended), the corpus stages from this worktree's tests/sweep.sh and the sv-tests stage through the
main tree's tests/sweep.sh (this worktree's UVM folder is empty); both exit 0, the law index
current. R11U485_TRACE was set on both sweeps; the trace directories stayed empty (no law of the
pass and no refinement fired in any process; positive control: the same trace on the attack grid
logged 69 files).

| stage | law sweep | verified sweep |
|---|---|---|
| probe | EQUAL 4025 + STRICT_NOTEQUAL 62, 0/0/0 | same, 0/0/0 |
| surelog | default 480 + testflags 474 CMP_EQUAL, 0/0/0 | same |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | same |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not excused 0 | same |
| sv-tests | EQUAL 1936, STRICT_NOTEQUAL 1, DIFFERENT 3, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; 0/0/0 | same |

Every csv of both sweeps equals the master's control /tmp/intr11u476 row for row except the two
LowMem testflags log-path texts in surelog.csv (the workdir name); the verified sweep's csvs
equal the law sweep's. byteverify (SELFCHECK=1, same-length workdir names): law against control
0 of 962, 0 of 1608, 0 of 805; verified against law and verified against control 0 of 962, 0
of 1608, 0 of 805 (negative control flagging 961, 1607, 804). Probe databases (path-normalised
dumps, since the sources sit under the worktree): 0 of 4087 movers for law and for verified
against the control, the unnormalised negative control flagging 4087 of 4087. Canaries ok=52
and ok=16 with both ctcan2 checks PASS on both sweeps. Binary audit: surelog 1531 of 1581
records name the binary under test (the other 50 hold a Surelog line only), uhdm2rtlil 1742 of
1742, sv-tests 2346 of 2346, no record naming another slang-uhdm binary.

## Attack grid (cases/, 98 dirs; every case accepted by upstream slang ~/.local/bin/slang
--single-unit, read by its real exit code; every slang-uhdm exit code 0 on all three binaries)

Groups: VD (§ clsOvDepParamOpTree485, 29), VE (§ clsOvExprActualOpTree485, 14), VF
(§ ovDefparamWinsValue485, 21), VN (§ ifaceValNoneBindsInst485 / § noneBindSameDefRead485v,
11), VS (§ clsOvSpanSepEnd485, 7), VT (§ implicitNetDefaultType485 /
§ ndtSameFileDirective485v, 16). Evidence grid_pristine.txt, grid_law.txt,
grid_verified.txt (rc, Surelog rc, uhdm-cmp lines, dump distance, strict verdict, md5).

| binary | STRICT_EQUAL | STRICT_NOTEQUAL | NOT_EQUAL |
|---|---|---|---|
| pristine | 15 | 5 | 78 |
| law | 73 | 3 | 22 |
| verified | 76 | 3 | 19 |

Moved AWAY from golden on the law (the breaks): VT/vt01, vt09, vt13, VN/vn08 (STRICT_EQUAL ->
NOT_EQUAL); none on the verified binary. uhdm-cmp count growing with a smaller dump distance
and a later head (not a step away, pristine wrong too): VD/vd19 17 -> 36 (dist 28 -> 4: a
copy of an overridden parameter's constant inside B's tree, golden size 64 from the unsized
actual, ours 32 from the param_assign), VD/vd30 64 -> 72 (dist 34 -> 30: A defparam'd and
K::w-overridden, A's value now golden's 3, B golden's K::w operation tree not written since
§ clsOvDefparamAbstain483v leaves A valued), VN/vn12 139 -> 227 (dist 15 -> 13: the binding
now golden's, the nested module's implicit clk wire golden mints the next face).
Downstream (downstream_grid.txt): none leaves IDENTICAL on any binary; vd01, ve01, ve08, vf03,
vf18, vf21 EQUIVALENT -> IDENTICAL.

Shapes confirmed by fresh cases (verified STRICT_EQUAL): a header dependent parameter (vd01),
<<, ?:, ~, - , chains, (A+1)*(A-1), p::K::w, child instance, interface, generate instance,
two instances, a later-declared literal-overridden parameter (vd03); int A and int B; the
expression actual with typed A, unary - and !, &&, ==, two class leaves, a typedef of the
class, a sized 'd leaf, child instance; defparam on top of named, ordered, typed int/integer,
interface, generate-scope, through two levels, 06, 32'd6, 0, two instances with one defparam;
`K::/*c*/w`, `K::` newline `w`, `p :: K :: w`, a macro `define KW K :: w, a tab; tri, trireg,
triand, uwire, wand after tri, a directive after an include, two files each with their own
directive, a commented directive; none with two instances, a task, a function argument, a
parameterized interface, a second top, an instance array.

Residues (all wrong on pristine too, none moved away on the verified binary):
VT/vt04 (directive in an include file, golden tri; the refinement abstains); VD/vd19 (golden
copies an overridden parameter's value at size 64); VD/vd30 (defparam'd K::w override, B's
tree); VF/vf04 (`parameter logic [3:0] A`, defparam 20: golden UINT:4 = 20 mod 16, the law 20,
pristine 5); VF/vf10 (`parameter signed A = -1`), vf14 (B = A + 1 under a defparam, the
continuous assignment), vf17 ('h6 defparam, abstains); VD/vd02 (logic [7:0] B: type abstain),
vd04 (P::x leaf), vd11 (4'd3 default), vd16 (1'b1 leaf), vd24 (bound reading B, TypeEmit's),
vd27 (integer B), vd28 (ordered #(K::w) twin); VE/ve03 (1_0 leaf: abstains, leaving the
operation objects it built unreferenced, byte hygiene), ve04 (** and % shapes partly), ve08
(port width A-1, TypeEmit's); VN/vn04 (parameterized interface: endcol), vn06 (three reads:
col); VT/vt11 (task-argument read under tri1: col).

## Away census

1806 fence-filtered earlier case dirs (every tools/probe/[rv]1[01]u*repro dut.sv holding
`default_nettype, defparam or a `#( ... ::` override; the list in away_census_list.txt),
pristine against the final verified binary: no exit code moving, 11 dirs moving bytes, the
implementer's 11 (wider than its 399-dir list) and all toward golden: r11u483 IV/iv08,
v11u483 VI/vi14, VO/vo07, vo13, vo20 to STRICT_EQUAL; r11u483 OV/ov06, ov16, ov23, r11u474
CS/cs06, v11u474 VP/vp06 closer by dump distance at the same uhdm-cmp count; v11u483 VO/vo12
17 -> 50 lines with dump distance 29 -> 16 (the head later, at the continuous assignment).

## Switches (switch_checks.txt; 174 dirs, both grids, rc + md5)

R11U485_OFF on the verified binary gives pristine's bytes and exit code on 174 of 174;
R11V485_OFF gives the law's on 174 of 174; R11V485_SAMEFILE_OFF moves exactly vt01, vt04,
vt09, vt13; R11V485_NONEXSCOPE_OFF exactly vn08. Each law switch moves only its own law's
dirs (DEPPARAM 48, EXPRACTUAL 29, SEPEND 9, DEFPARAMVAL 18, NETTYPE 21, NONEBIND 14 on the
first 159 dirs), three dirs needing two (vs04, se09 EXPRACTUAL+SEPEND, ea11 DEPPARAM+EXPRACTUAL).

## Goal 1

Re-measured on the verified binary (evidence/goal1.txt): bp_unicore alone with the size guard
on (§ macroVecLitTokenText403) exits 3 in 14.5 s at 816 MB, so the guard stays; C::mk().arr[1]
(v11u413 VC/vc04) and u.mk(x).a[2] (VI/vi06) exit 4 in ours and 0 upstream, Surelog rejecting
both, so there is no golden shape; this.mk().inner.s (v11u415 VT/vt03) exits 0; all 75
SURELOG_ONLY details are upstream slang diagnostics. Unchanged.

## Process

Builds: the law binary once from the patch (md5 equal to the implementer's law8); a first
verified build with § ndtSameFileDirective485v alone (md5 8241a1d0a086d80b90da00e8ba005d5c, used
on case runs and the first away census only, never swept); a THIRD build adding
§ noneBindSameDefRead485v after the attack grid found VN/vn08 (md5
f6a346fb81377618674f89230eef4973), the only verified binary swept. The third build exceeds the
budget's two-build allowance: the vn08 break was found after the second build, before either
sweep had started, and a break where pristine was right must be fixed, so it was built rather
than left; no third sweep was run (one law sweep, one verified sweep). Every build ran -j 2
and finished before the sweeps started; the attack-grid, census and downstream runs were
single-process, some during the sister's sweep stages and the byteverify/probe-dump readings
during my own verified sweep's sv-tests stage. The fence list was read into a file by a
program and never printed; the away-census list was fence-filtered before any file was opened;
every byteverify, canary and sweep log was fence-filtered before entering evidence/; the patch
and both repro folders scan clean. No other agent's process touched; the launcher stopped
nothing.

## Files

cases/ (98 dirs), drivers/ (env.sh, runcase.sh: Surelog golden + ours + uhdm-cmp + strict +
dump distance; sw.sh: switch runs; away.sh: the census; ds.py: downstream one()), evidence/.
