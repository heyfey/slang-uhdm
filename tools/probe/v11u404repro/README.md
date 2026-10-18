# v11u404 — adversarial verification of r11u404 (pass 404, module/type ground): ACCEPT WITH THREE REFINEMENTS

Verifier of /tmp/r11u404.patch (md5 bd26b47b54bb08dab7c71f15d1a9f664) at base c51d5b5f4. Fresh worktrees
(pristine and patched), binaries built here with -j 2 and frozen (chmod 555) before any measurement:

- pristine d90254f4ad18ac702ba763d6a8f7854b, equal to the main tree's build/slang-uhdm;
- law (the implementer's patch) ac78571fe2f25d30ae6026852f1467ca, equal to the implementer's law7;
- verified (the patch plus the three refinements below) 6ee88056d0a8447122ae3a598417db1f.

All three report slang 12.0.0+545f88b2e. The verified patch adds three refinements, each behind its own switch read
through src/LawSwitch.h with `fixOn(404, ...)`. `R11V404_OFF` drops all three. No src/R*.h, no getenv, no reader
function in the added lines, no LawState.h section.

## Verdict

Every headline number of the implementer reproduces bit for bit. The fresh cases found three faces where pristine
was right and the law is wrong, each on legal SV. All three are fixed below. With the fixes, no fresh case, corpus
row, probe case, downstream row or sv-tests row moves away from golden.

| stage | pristine | law | verified |
|---|---|---|---|
| probe | 4018 + 69, 0/0/0 | 4018 + 69, 0/0/0 | 4018 + 69, 0/0/0 |
| surelog | 480 + 0 / 474 + 0, 0/0/0 | same, 0/0/0 | same, 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | same, 0/0/0 | same, 0/0/0 |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, verdicts 871 of 871 equal to results/ | same |
| sv-tests | baseline exactly, 0/0/0 | **0 regressions, 302 conversions, 0 changes** | 0 / 302 / 0, the same 302 rows |

The counts are regressions / conversions / changes. The sv-tests counts on law and verified are EQUAL 1534,
STRICT_NOTEQUAL 8, DIFFERENT 390, SURELOG_ONLY 83, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346.
The baseline was EQUAL 1240, STRICT_NOTEQUAL 20, DIFFERENT 668, SURELOG_ONLY 87.

- **sv-tests movers.** The law sweep's 302 conversions are the implementer's list, path for path
  (evidence/svtests_law_movers.txt). The verified sweep's mover list is identical to the law sweep's. Its csv is
  identical to the law csv on all 2346 rows.
- **Byte movers, law vs pristine:** surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805, probe 0 of 4087.
  The byteverify path-set assertion and SELFCHECK passed. The probe compare was done file by file, with a negative
  control.
- **Byte movers, verified vs law:** 0 in every corpus and 0 in the probe. The surelog, uhdm2rtlil, probe, downstream
  and sv-tests csvs are identical to the law sweep's, row for row. The surelog csv differs from pristine only in the
  LowMem detail text, which carries the workdir path.
- **Strict column:** identical row for row between law and pristine on surelog, uhdm2rtlil and probe. The five corpus
  UVM rows keep their STRICT_EQUAL object counts.
- **Canaries:** ok=52 changed=0 and ok=16 changed=0. ctcan2 (EXPECT_UNKNOWN=1 / 6) PASS on both csvs.
- **Binary audit** (drivers/vaudit404.sh, cmds.txt list fence-filtered before any file is opened): each of the three
  workdirs has 5659 cmds.txt. In each, 5609 name only that workdir's own binary and 0 name another binary. The 50 that
  name none are Surelog-only corpus rows.
- **Determinism:** three concurrent draws per binary of Earlgrey_0_1 default, MiniAmiq default and SeqDriver
  testflags. Each binary gives one hash per row, equal to its sweep's database. The hashes are the same for all three
  binaries.
- **sv-tests away census, law vs pristine** (drivers/vsvaway404.sh; the rows DIFFERENT or STRICT_NOTEQUAL in both
  sweeps, normalised dump diff against golden): 390 rows. 304 have an identical normalised dump. 84 moved toward
  golden, by 365634 lines in all. 2 moved but stayed at the same distance (p230, p884). **0 moved away.**
- **sv-tests, verified vs law:** the normalised dumps of the 427 sv-tests databases the stage keeps are identical
  (drivers/vsvbytes404.sh, evidence/svtests_dumps_ver_vs_law.txt). The refinements move no sv-tests database.
- **Implementer's grid** (45 case dirs, rerun with my binaries, evidence/impl_grid_repro.txt): 38 move, 27 enter
  STRICT_EQUAL, none leaves. `R11U404_OFF` gives pristine's bytes and exit code on 45 of 45. Every moving case is
  restored by its own switch (evidence/impl_switch_repro.txt), except the six listed in the implementer's
  switch404_sets.txt, which their switch sets restore. With the verified binary the 45 cases keep the law's bytes.

## The breaks found (pristine right, law wrong) and the refinements

1. **§ ifacePrgOrderedConnMaterializes404v** (R11V404_IFPRGCONN_OFF; UhdmExporter.cpp, inside
   § implicitNetDefLastRef404's materialization test). The law treats every ORDERED connection of an instance as a
   mention that does not place the implicit net. Golden places the net at an ordered connection of an INTERFACE or
   PROGRAM instance: `ifc u(w); assign w = i;` keeps w at u (4:9), and `prg p1(w); assign w = i;` keeps it at p1.
   Only a MODULE instance's ordered connection is a mere mention.
   - Breaks, all pristine STRICT_EQUAL and law STRICT_NOTEQUAL `line`: VN/vn06, vn09, vn11.
   - VN/vn10: pristine STRICT_NOTEQUAL and law STRICT_NOTEQUAL. golden puts w at the interface instance after an
     earlier module ordered connection; the law moved it to the assign instead.
   - With the refinement all four read STRICT_EQUAL.
2. **§ builtinClassElemNotInClass404v** (R11V404_BICLASSMETH_OFF; TypeEmit.cpp, subrBuiltinClassElem404 of
   § subrBuiltinClassArrElemUnsup404). In a CLASS method, golden resolves the built-in class element like any other
   class: `class worker; task run(int n); process jobs[] = new[n];` gives class_var + class_typespec (class_defn
   process). The law wrote ref_var + unsupported_typespec there.
   - VB/vb05 (a static class task and a class task): pristine STRICT_EQUAL, law NOT_EQUAL.
   - VB/vb02: pristine 8 diff lines, law 23.
   - VB/vb04 `pk::C::f`: the law degraded the class function's `process p[2]` and `semaphore s[]`.
   - Only module, interface, program and package subroutines degrade. The refinement checks the subroutine's
     enclosing scopes for a class before the first instance body, package or unit. The package task in vb04 still
     degrades, as golden wants.
   - With the refinement vb05 reads STRICT_EQUAL and vb02 is back to pristine's distance.
3. **§ unitWideFillOnesBin404v** (R11V404_WIDEFILL_OFF; UhdmExporter.cpp, § unitParamXzLiteral404's typed `'1` branch).
   The law reduces a typed `'1` to an all-ones UINT and has no branch for widths above 64.
   - The law therefore wrote NO value and NO rhs constant for `parameter logic [99:0] P = '1;` in $unit. Pristine
     wrote a wrong INT:0 rhs object; golden writes BIN of 100 ones, with the decompile the same digits.
   - Golden keeps the BIN encoding above 64 bits (VX/vx01, vx05: 65-, 100- and 128-bit `logic`, `bit`,
     `logic signed`). The refinement writes exactly that.
   - VX/vx01: law 193 lines from golden, verified 178. VX/vx05: law 225, verified 180. Pristine was 202 and 227.
   - The rest is the module-scope variable read of the folded parameter and the unreferenced typespec tail, both
     pristine too.

## Fresh grid (64 case dirs in 11 groups, cases/, every case naming its law on line 1)

Drivers:

- drivers/vgrid404.sh: golden from the pinned Surelog with `-parse -sverilog`, plus `--top-module top` when the case
  declares one. Then uhdm-cmp, and uhdm-strictcmp's verdict, for pristine, law, `R11U404_OFF` and verified.
- drivers/vaway404.sh: the golden-distance census.
- drivers/vswitch404.sh: the switches.
- drivers/vds404.sh: the downstream verdict.

Results:

- **Verified vs pristine:** 53 cases move, 25 enter STRICT_EQUAL, and the 4 pristine-STRICT_EQUAL cases stay.
  44 move toward golden, 20 keep their distance, **0 move away**. VS/vs01 and vs02 change exit code 4 -> 0; vs04
  (repetition on the match) still exits 4 on both binaries.
- **Law vs pristine:** 58 move, 24 enter STRICT_EQUAL and 4 leave it (vn06, vn09, vn11, vb05). Away: vn06, vn09,
  vn11, vb02, vb05.
- **Switches:** `R11U404_OFF` gives pristine's bytes and exit code on 64 of 64 fresh cases and on 45 of 45 of the
  implementer's. Run on the verified binary, `R11V404_OFF` gives the law's bytes on 109 of 109. Each refinement's own
  switch gives the law's bytes on each of its cases: vn06, vn09, vn10, vn11; vb02, vb04, vb05; vx01, vx05. These 9
  are the only cases where the verified binary differs from the law.
- **Downstream** (evidence/fresh_downstream.txt; 59 class-free cases, pristine -> verified): no case gets worse.
  VI/vi01, vi02, vi04, vi05 and VM/vm03 go EQUIVALENT -> IDENTICAL. All other verdicts are unchanged:
  - IDENTICAL on the VN rows, vu12, vu15, vx02-vx04 and va01;
  - EQUIVALENT on the VU rows (the uninstantiated definition taken as top in that lane), vc01, vi03, vm01, vm02;
  - DIVERGENT on vx01 and vx05 (pristine too);
  - SLANG_REJECT on ve01-03 (an unknown module);
  - STATUS_DIFF on va02 (pristine too).

| case | law under test | pristine | law | verified | lines from golden p -> v |
|---|---|---|---|---|---|
| VA/va01-03 | § assocIdxSpanAtTokens404 | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | 21->9, 60->52, 21->17 |
| VB/vb01, vb03 | § subrBuiltinClassArrElemUnsup404 | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | 43->14, 18->10 |
| VB/vb02, vb04 | § builtinClassElemNotInClass404v | NOT_EQUAL | NOT_EQUAL (vb02 AWAY 8->23) | NOT_EQUAL | 8->8, 62->38 |
| VB/vb05 | § builtinClassElemNotInClass404v | STRICT_EQUAL 128 | **NOT_EQUAL** | STRICT_EQUAL 128 | 0->0 |
| VC/vc01 | § invalidCaAssignChild404 | NOT_EQUAL | STRICT_EQUAL 153 | STRICT_EQUAL 153 | 351->0 |
| VE/ve01 | § unknownModBitSelConnScope404 | STRICT_NOTEQUAL fullname | STRICT_EQUAL 139 | STRICT_EQUAL 139 | 20->0 |
| VE/ve02 | § unknownModEmptyNamedConnPort404 | NOT_EQUAL | STRICT_EQUAL 122 | STRICT_EQUAL 122 | 29->0 |
| VE/ve03 | § unknownModWildcardConnPort404 | NOT_EQUAL | STRICT_EQUAL 124 | STRICT_EQUAL 124 | 24->0 |
| VI/vi01, vi05 | § varInitOpCastKept404 | NOT_EQUAL | STRICT_EQUAL 132, 147 | same | 63->0, 84->0 |
| VI/vi02-04 | § varInitOpCastKept404 | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | 94->30, 100->27, 26->5 |
| VI/vi06 | § varInitOpCastKept404 | NOT_EQUAL | unmoved | unmoved | 49 |
| VM/vm01 | § macroArgParamOrder404 | NOT_EQUAL | unmoved | unmoved | 128 |
| VM/vm02, vm03 | § macroArgParamOrder404 | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | 194->62, 172->44 |
| VN/vn01-04, vn08, vn12-14 | § implicitNetDefLastRef404 | NOT_EQUAL | moved, NOT_EQUAL | NOT_EQUAL | 7, 7, 7, 7, 7, 7, 7, 14 (same) |
| VN/vn05, vn07 | § implicitNetDefLastRef404 | STRICT_NOTEQUAL line / NOT_EQUAL | STRICT_EQUAL 191, 226 | same | 16->0, 22->0 |
| VN/vn06, vn09, vn11 | § ifacePrgOrderedConnMaterializes404v | STRICT_EQUAL 167, 192, 169 | **STRICT_NOTEQUAL line** | STRICT_EQUAL | 0, 0, 2 (tail order) |
| VN/vn10 | § ifacePrgOrderedConnMaterializes404v | STRICT_NOTEQUAL line | STRICT_NOTEQUAL line | STRICT_EQUAL 192 | 6->0 |
| VN/vn15 | § implicitNetDefLastRef404 | STRICT_NOTEQUAL line | STRICT_NOTEQUAL line | same | 6->6 |
| VP/vp01 | § pkgStructMemberSysArgBind404 | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | 10->2 |
| VP/vp02 | § pkgStructMemberSysArgBind404 | NOT_EQUAL | unmoved | unmoved | 61 |
| VS/vs01, vs02 | § seqMatchItemsDropped404 | rc=4 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL | 37->29, 66->58 |
| VS/vs03 | § seqMatchItemsDropped404 | NOT_EQUAL | unmoved | unmoved | 66 |
| VS/vs04 | § seqMatchItemsDropped404 (abstains) | rc=4 | rc=4 unmoved | rc=4 | 28 |
| VU/vu01-09, vu12, vu13, vu16, vu17 | § undefaultedDefInvalidInst404 | NOT_EQUAL | STRICT_EQUAL (13) | STRICT_EQUAL | 181->2 ... all to 0-2 except vu05 277->62 (strict-equal, tail typespec order) |
| VU/vu10, vu11, vu14 | § undefaultedDefInvalidInst404 | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | 108->32, 109->5, 207->2 |
| VU/vu15 | § undefaultedDefInvalidInst404 (abstains: recursive instance) | NOT_EQUAL | unmoved | unmoved | 153 |
| VX/vx02-04 | § unitParamXzLiteral404 | NOT_EQUAL | STRICT_EQUAL 127, 133, 149 | same | 146/107/97 -> 54 (tail typespec order) |
| VX/vx01, vx05 | § unitWideFillOnesBin404v | NOT_EQUAL | NOT_EQUAL (P's value and rhs dropped) | NOT_EQUAL | 202->178, 227->180 |

The placeholder of § undefaultedDefInvalidInst404 survived its attacks:

- an elaboration-time `$error` taken under the placeholder value (vu13);
- a generate loop of 2**(p*3) iterations (vu14, rc 0, no blow-up);
- a recursive self-instantiation (vu15, abstains);
- a zero-size unpacked dimension and a division by p-8 (vu11, vu16);
- string, real, struct and enum typed parameters (vu02, vu03, vu04, vu07);
- a nested defaulted parameter (vu12).

Every one exits 0. None is worse than pristine, which did not list the definition at all.

## Residues (all wrong on pristine too; none moved away by the verified binary), ranked

1. **§ implicitNetDefLastRef404 is not scope-aware.** It matches an identifier by its text, so the following are
   taken as materializing references to the module-level implicit net:
   - a function argument or local (vn01, vn14);
   - a hierarchical `s1.b` (vn02);
   - a generate-block local net (vn03);
   - a named-block local (vn04);
   - a task-local reg (vn08).

   In vn01 to vn04 and vn08, golden lists NO such net, because Surelog never materializes it from a module ordered
   connection alone. Pristine lists it at its birth; law and verified list it at the shadowing reference. The
   distance is the same, the object is extra on every binary, and the line is the only field that moves.
2. **A declaration initializer inside procedural code materializes the net** (vn15:
   `always_comb begin automatic logic w2 = w; end` -> golden w at that initializer, 6:26). The law's
   NetDeclaration/DataDeclaration branch returns "mention" before it reaches the procedural ancestor. A reference inside
   a generate block (vn12, vn13) leaves golden without the module-level net.
3. **§ varInitOpCastKept404 is partial.**
   - A 1-bit scalar target is not adjusted (vi02 `bit e = (3 == 4)`: golden operands 1 and 0 at size 1).
   - A parameter operand is not folded to its constant (vi02 `int a = P + 1`).
   - A cast's operand is not adjusted (vi03 `shortint'(70000)` -> 4464/16, `4'(20)` -> 4/4).
   - `signed'(x)` is not covered (golden a `$signed` sys_func_call).
   - A real target's integer operand keeps size 64 where golden has 32.
   - Interface, generate, package, class and task initializers (vi04 5 lines, vi06 unmoved).
4. **§ undefaultedDefInvalidInst404 placeholder leak and coverage.** A `'0` assigned in a default-less definition gets
   the placeholder width (vu14, the implementer's UD/ud04). `int arr [p-8]` gets a logic_typespec element (vu11). An
   uninstantiated INTERFACE with a default-less parameter is still not listed (vu10).
5. **§ macroArgParamOrder404 does not reach port nets**: a port named through a macro argument (vm03,
   `` `PORT(z) ``) keeps its net listed after the physical ports. The plain macro declarations of vm01, a
   `` `DECL(b) `` among physical declarations, are not moved by the law and differ on other faces.
6. **§ pkgStructMemberSysArgBind404 does not reach an imported package's parameter** (vp02, `$clog2(m)` with m from
   an imported package). vp01 keeps a 2-line end-column residue on a folded `$clog2(n)-1` bound (the implementer's
   PS/ps02 face).
7. **§ subrBuiltinClassArrElemUnsup404 does not reach a scoped `std::process q[]`**, where golden writes
   unsupported_typespec `std::process` (vb03). Module-scope builtin-class arrays are the implementer's BC/bc02 residue.
8. **Associative index typespec**, other faces: `int b [ nib_t ]` makes golden list a net named nib_t (va01, a
   Surelog quirk). A two-dimensional associative index loses its ranges (va02).
9. **Sequence match items**: a sequence declaration with a local variable and a match item (vs03) is still not
   emitted (the sequence_decl residue). The property-local variable is sister ground (vs01, vs02).
10. The implementer's residue list stands as written (the 81 basejump DIFFERENT rows, typedef_test_13, the five new
    basejump STRICT_NOTEQUAL rows, the 5.6.4 debug-line row, and the rest).

## Sister-ground faces (reported, not written)

The implementer's seven stand. To them add the module-scope fold of a wide `$unit` parameter read by a variable
initializer. In vx01 and vx05, `logic [127:0] a = B;` is written as a folded constant UINT:0 where golden keeps the
ref_obj to the parameter. That is ModuleEmit's initializer chain reading ParamEmit's fold, pristine too.

## Process and slips

- The law sweep's corpus stage printed `law index STALE` and exited rc 1. I had added the refinement § tokens and my
  case headers to the worktree while that sweep ran. The probe, surelog, uhdm2rtlil and downstream numbers are
  unaffected: they come from the csvs. The index was regenerated, and the pristine and verified sweeps read `law
  index current`.
- Four first-draft fresh cases were illegal and were rewritten before they were counted. VB/vb01 to vb03 called
  `.size()` on fixed-size arrays (slang rc 3); they now use `$size`. VS/vs01's `(a ##1 b, v = x)` is rejected by
  Surelog (UH0700); it was rewritten as `a ##1 (b, v = x)`.
- One determinism draw of Earlgrey_0_1 ran from the test's top directory instead of sim-icarus and exited 1, with
  nothing written. It was rerun from the right directory. The determinism draws run slang-uhdm with its working
  directory in the corpus test directory, as verify_golden.py does, and write to /tmp only. `git status` of the main
  tree and of the Surelog submodule read clean afterwards.
- A background waiter's `pgrep -f` pattern matched its own command line. It was stopped by its task id.
- A `pkill -f` aimed at my own stalled uhdm-dump of the tnoc sv-tests database matched the shell running it, and
  only that shell died. The dump was then stopped by its PID; a sister verifier's processes were not touched. The
  tnoc database pair was compared raw instead: it differs in one byte, the workdir letter in an embedded path.
- Two scratch files were written as /tmp/a and /tmp/b, outside the pass prefix, during the mover comparison. They
  were removed at once.
- The sv-tests stage was run through the main tree's scripts/check_svtests.py, read-only, because a worktree has no
  UVM tree under third_party. It was never run while another sweep was live (the pgrep before each launch read 0).
- No fenced test was dispatched by name, read, or spelled. Every cmds.txt list was fence-filtered before any file was
  opened. byteverify compares every database the gate wrote, as the gate dispatches it, without opening any source.
