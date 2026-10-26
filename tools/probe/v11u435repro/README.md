# v11u435 — adversarial verification of r11u435 (expression/parameter ground)

Base 676585243 (pass 433). Implementer's patch: r11u435 (three laws in src/ParamEmit.cpp,
src/ExprEmit.cpp and src/EmitHelpers.h). Verifier: v11u435.

## Verdict

**VERIFIED, with one production refinement.** No break found: no attack case, probe case, corpus
row, downstream row or sv-tests row moved away from golden on the law binary. The refinement
corrects the value § patMemberSizeCastSignedInt435 writes when the cast operand is a parameter
initialized by one integer literal. On that shape the law made uhdm-cmp equal but wrote the wrong
value: pristine was wrong there too, so it is not a break.

* **§ patCastParamLitBits435v** (`R11V435_PARAMLIT_OFF`, read through `fixOn(435, ...)`; ParamEmit,
  inside the signed branch of § patMemberSizeCastSignedInt435). A parameter whose initializer is one
  integer literal keeps that literal's own value in Surelog's stored constant, not the value
  converted to the declared type. ExprEval's `get_value` reads that constant, then the `vpiCastOp`
  branch masks it and sign-extends from the cast width (third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp,
  the `uhdminteger_typespec` branch). The rule, measured on these cases:
  * An unsigned literal zero-extends. With `logic signed [7:0] K = 8'hF0`, `16'(K)` reads INT:240 in
    golden where the law wrote INT:-16 (VS/vs01). `int K = 32'hFFFF_FFF0` with `40'(K)` reads
    INT:4294967280 where the law wrote INT:-16 (vs02, vs03). The same holds for vs06, vs25 and
    vs27 (`int K = 32'd4294967293`, `40'(K)`).
  * An unsized decimal keeps its value: `K = 200` reads INT:200 where the law wrote INT:-56 (vs17).
  * A signed literal sign-extends from its own width: `int K = 4'sb1101` reads INT:-3 (vs20, which
    both binaries already write).

  With the fix, 7 cases go STRICT_NOTEQUAL value -> STRICT_EQUAL (vs01, vs02, vs03, vs06, vs17,
  vs25, vs27). Downstream, 4 go DIVERGENT -> IDENTICAL (vs01, vs06, vs17, vs25) and vs02, vs03 stay
  IDENTICAL (evidence/downstream_refinement_verified.txt). The fix fires on no corpus row, probe
  case or sv-tests row: the traces of both sweeps list the same 29 databases, all firings of law 1.
  * `R11V435_OFF` and `R11V435_PARAMLIT_OFF` each give the law's bytes on 81 of 81 attack cases
    and 73 of 73 implementer cases.
  * `R11U435_OFF` on the verified binary gives pristine's bytes on all 154.

## Reproduction of the implementer's numbers

* **Builds.** The law binary was rebuilt once in /tmp/wt_v11u435. Its md5 is
  d5d13cf711fb46d7025becf312be4a01, equal to the implementer's law7, and it links slang
  12.0.0+545f88b2e. There was no pristine build: the pristine reading is the master's control
  /tmp/intr11u433, and case runs used the frozen base binary 256107fb9c98995fc2a29f7dfe33d198.
  There was one verified build, a916531ba3b8daf7270fdfda4415cc22.
* **Sweeps.** One full five-stage sweep each on the law and the verified binary, with the trace
  on. Each started after three quiet readings, and nothing of the sister's ran at the same time.
  The first four stages ran through tests/sweep.sh. The sv-tests stage ran through `svstage.py`,
  which is scripts/check_svtests.py with UVM read from the main checkout, because the worktree's
  submodule dirs are empty. All 2346 sv-tests command records name the binary under test, in both
  sweeps. Results, identical on both binaries:
  * probe: EQUAL 4023 + STRICT_NOTEQUAL 64. regressions=0 conversions=4 changes=0. The four
    conversions are the implementer's: r11u109repro/grid/f1/c04_x64cast, c06_x64plain,
    p06_plainparam and p07_litcast, each `EQUAL,,equal` (was STRICT_NOTEQUAL differ:value(2)).
  * surelog: default 480, testflags 474. 0/0/0. The csv differs from the control only in the two
    LowMem log-path texts.
  * uhdm2rtlil: 803 / 1 / 67 in both modes. 0/0/0. The csv is identical to the control.
  * downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0. The csv is identical
    to the control.
  * sv-tests: EQUAL 1903, STRICT_NOTEQUAL 1, DIFFERENT 36, BOTH_REJECT 303, SURELOG_ONLY 75,
    SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346. regressions=0 conversions=0 changes=0. The
    csv is identical to the control on all 2346 rows. This is the first sv-tests reading of law7.
  * The corpus stages exit 1 only because of the stale law index (regenerated into the patch).
  * The verified sweep's five csvs equal the law sweep's, apart from the two LowMem path texts.
* **byteverify** (`SELFCHECK=1`):
  * Law workdir against the control: the corpus and probe databases move only in the 5 predicted
    ones. These are StructParamFieldRange default and testflags, cva6_struct_param_field default
    and testflags, and the downstream copy of cva6_struct_param_field. They are all the
    § spVoidCastValue109 overwrite.
  * The 58 kept sv-tests databases differ by bytes because the workdir name, which is embedded in
    the builtin.sv path, differs in length from the control's. By path-normalized dump, 57 of 58
    are identical. tnoc's dump hits the 900 s timeout, and its trace shows no firing.
  * Verified against law: 0 corpus or probe movers out of 3375. The 58 sv-tests movers come from
    the one-character difference in the workdir name.
* **Canaries:** ok=52 and ok=16. Both ctcan2 checks pass, on both sweeps.
* **Binary audit**, fence-filtered: 3263 of 3313 corpus command records name the binary under
  test. The other 50 hold only a Surelog line. This is the same in both sweeps.
* **Trace census:** law 1 fires on the 24 r11u109repro/grid/f1 probe cases and the 5 corpus
  databases. Laws 2 and 3 and the fix fire on no corpus row, probe case or sv-tests row
  (evidence/trace_firing_dbs.txt). This matches the implementer's census.
* **Implementer's grid**, 73 case dirs through grid3.sh: 39 reach STRICT_EQUAL, 24 are
  byte-identical, and 10 stay unequal but closer. None moved further, and every exit code is 0.
  `R11U435_OFF` gives pristine's bytes on 73 of 73, and the verified binary writes the law's bytes
  on all 73. This reproduces the implementer exactly (evidence/grid_r11u435_cases.txt).
* **Earlier-pass census:** 5030 fence-filtered case dirs of passes 401 to 434, run on pristine,
  law and verified. Exit codes are equal on all three, and 11 dirs exit 3 on all three with no
  output. Pristine -> law moves exactly 3 dirs: v11u433 VW/vw10, vw11 and vw26, each NOT_EQUAL
  (28 uhdm-cmp lines) -> STRICT_EQUAL. These are pass 433's residue 1. Law -> verified moves 0.
* **Goal 1** reproduced:
  * v11u415 VT/vt03: slang 0, Surelog 3, ours 0.
  * v11u413 VC/vc04 and VI/vi06: slang 0, Surelog 3, ours 4.
  * bp_unicore alone on the law binary exits 3 in 13.7 s at 813 MB (`basic_string::substr`, with
    pass 403's guard abstaining). The guard stays.

## Attack grid (81 case dirs, cases/VS, VM, VD, VG; every first line names the law)

Upstream slang accepts every case, and every exit code is 0 on all three binaries. The drivers are
runcase.sh, grid3.sh, classify.py and downstream_cases.py.

* **Pristine -> law:** 35 reach STRICT_EQUAL. 7 go NOT_EQUAL -> STRICT_NOTEQUAL value (the
  refinement's cases). 26 are byte-identical (12 controls, 14 residues). 13 stay unequal but
  closer. None moved further.
* **Pristine -> verified:** 42 reach STRICT_EQUAL, 26 are byte-identical and 13 stay unequal but
  closer. None moved further.
* **Downstream**, 74 class-free cases, pristine -> law: 15 go STATUS_DIFF/DIVERGENT -> IDENTICAL.
  VM/vm03 goes STATUS_DIFF -> DIVERGENT, because its other member now matches while the enum
  operand abstains. None leaves IDENTICAL. The refinement then moves 4 more cases to IDENTICAL.

The shapes tried, by law:

| law | cases | what was tried |
|---|---|---|
| § patMemberSizeCastSignedInt435 | VS/vs01 to vs29 | a signed `logic`/`bit` parameter with a hex, binary or unsized-decimal initializer; an `int` with a hex, based-decimal or signed-binary initializer, or from a negation; a parameter chain `K = J`; a nested struct pattern; `default:`; a parameter cast width `N'(K)`; a generate block; an interface; classes in $unit, a package and a module |
| § patMemberSizeCastUbMask435 | VM/vm01 to vm19 | a 64-bit hex parameter; `65'(-1)`; an enum operand; an unsigned parameter under a signed override; an untyped based parameter; `'1`; `integer` and `int unsigned` parameters; a struct member select; a function call; `K + 1`; an OR of casts; an unpacked struct; a class; a generate block; an interface; a parameter-port pattern; `W'(1)` with W overridden to 64 |
| § patMemberSizeCastUbMask435 (definition view) | VD/vd01 to vd06 | a package pattern over an unsigned parameter, `-1`, a wildcard import, a re-assigned import, `default:`, `W'(1)` with an `int unsigned` W |
| § genCaAddParamIntCt435 | VG/vg01 to vg29 | `/`, `%` and `*` under `+`; `'d2`; a defparam; an override from a parent parameter and from an operation; a package parameter; a genvar loop; a shift; `~W`; binary and octal operands; overflow; `1'b1`; `V = W`; `-W + 9`; `W + W - 1`; an uppercase `'D`; a 32-bit unsigned operand; generate case; an interface; a body localparam; nested generate blocks; a net operand |

## Residues (ranked; all wrong on pristine too, none moved away)

1. Size casts the cast laws do not reach:
   * an enum operand, `64'(B)`: golden UINT:0, the classifier abstains (VM/vm03);
   * an interface localparam (VM/vm14);
   * a 65-bit member, `65'(-1)`: golden UINT:1 (vm02);
   * classes in $unit, a package and a module (VS/vs08 to vs10, VM/vm12: another face first);
   * generate blocks (vs15, vm13), an unpacked struct (vm11), a nested pattern (vs12) and
     `W'(1)` under an override (vm19): each judge-unequal on another face;
   * a parameter chain `K = J` with a hex J (vs19) and `8'shF0` (vs22): another face first.
2. A 40-bit cast into a 16-bit member, `40'(3)`: golden keeps vpiSize 40, ours 16 (VS/vs28). The
   law cleared its first face, so uhdm-cmp's head moved later (17 -> 32 lines, dump distance
   153 -> 140).
3. Generate-scope `+` shapes the encoding law does not reach:
   * a package parameter `p::W + 1` (VG/vg07);
   * `W + i` in a genvar loop (vg08);
   * `~W + 1` (vg10);
   * nested generate blocks (vg28);
   * `W + n` with a net operand (vg29).
4. The implementer's residues stand: GA/ga11, ga15; PS/ps21; PM/pm14, pm22, pm23, pm25, pm30;
   PD/pd04, pd06 to pd10; ps09.
5. The carried lists of pass 433 and earlier (tools/probe/r11u433repro and v11u433repro READMEs),
   except VW/vw10, vw11 and vw26, which this pass writes.

## Sister-ground faces (reported, not written)

* VD/vd06 and the implementer's PD/pd03: a package typedef range `W-1` reads INT:63 in golden and
  is an operation in ours (TypeEmit).
* The implementer's fa20 / FA/fa16 / FC attribution (ModuleEmit emitContAssigns) and VF/vf03 and
  vf14 (ModuleEmit's elaborated cont_assign) were not re-decoded here.

## Process

* Slip, which affected no measurement: one uhdm-cmp call at the shell, used to read VS/vs28, ran
  with `$UHDM_CMP` unset. The shell executed a golden database as a script and printed
  "command not found" lines. No file was written: the case dir and the main tree were checked,
  and git status is clean. The call was rerun with the tool guarded by `[ -x ]`.
* bp_unicore was measured alone while this verifier's own sv-tests dump comparison was running.
* The fence list was read into a file by a program without printing it. Every tree-wide list (the
  census list, the cmds.txt audit, the evidence files) was filtered on it, and the evidence holds
  no fenced name. No fenced test was named, opened or run, and no other agent's process was
  touched.
* Budget: one law build and one verified build, and one full sweep on each. No pristine build or
  sweep.
