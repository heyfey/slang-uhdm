# v11u474: adversarial verification of r11u474

Verdict: one break found and fixed. § thisTdRegDefView474 moved the this_t clone to the
definition view on legal SV where pristine's TOP view was golden's (5 attack cases). The fix is
§ thisTdRegOrder474v (UhdmExporter, `fixOn(474, "R11V474_REGORDER_OFF")`). The other three laws
held on every attack case. The verified patch is /tmp/r11u474.verified.patch.

## Binaries

| binary | md5 | note |
|---|---|---|
| pristine | 21cd25b130d5a097624f8d4fc3dbb292 | copy of the implementer's frozen pristine, equal to the base build |
| law | b8ed2976069b17485592cfe7eb656f1d | rebuilt once from /tmp/r11u474.patch on fresh a1ffba66, equal to the implementer's law15 |
| verified | 3337b7ee04dfd0cef061268afac6ad6a | the law plus § thisTdRegOrder474v |

All three link slang 12.0.0+545f88b2e. The uhdm-strictcmp built in the worktree is
fa6e4f42f252ae0ab69d9845003e71c5, the same as the implementer's.

## The break and the fix

§ thisTdRegDefView474 gives the class-nested this_t clone the declaring package's DEFINITION view
when the generic class declares `typedef R #(this_t) ...` with R imported from another package.
Golden keeps the TOP view (pristine's output) in these attack cases:

| case | shape | golden | pristine | law | verified |
|---|---|---|---|---|---|
| VT/vt03 | `typedef R #(int) other_t;` besides the registry typedef | TOP | TOP, STRICT_NOTEQUAL file | DEF, NOT_EQUAL 670 | TOP, STRICT_NOTEQUAL file |
| VT/vt04 | R visible only through a file-level `import u::*;` | TOP | TOP, STRICT_NOTEQUAL fullname | DEF, NOT_EQUAL 584 | TOP, STRICT_NOTEQUAL fullname |
| VT/vt15 | `R #(int) other_t` written after the registry typedef | TOP | TOP, STRICT_NOTEQUAL file | DEF, NOT_EQUAL 670 | TOP, STRICT_NOTEQUAL file |
| VT/vt18 | `u::R #(int) other_t` (qualified) | TOP | TOP, STRICT_NOTEQUAL fullname | DEF, NOT_EQUAL 542 | TOP, STRICT_EQUAL |
| VT/vt19 | the registry typedef named `aa_t` | TOP | TOP, NOT_EQUAL 222 | DEF, NOT_EQUAL 670 | TOP, NOT_EQUAL 222 |

(views read by evidence/tools/thist.cpp, the implementer's tool, on golden, pristine, law and verified)

What decides it: Surelog's bindTypedefs_ walks a class's typedefs through
DesignComponent::getTypeDefMap(), a `std::map` keyed by NAME, not in source order. The pairs that
isolate this:

- vt14 (`R #(int) zz_t`, written first, sorting after type_id) reads DEF in golden.
- vt15 (`R #(int) other_t`, written last, sorting before this_t) reads TOP.

So § thisTdRegOrder474v adds two conditions to the law. The law holds only when:

- **(a)** R is visible through an import written in the declaring package's own body, either a
  wildcard import of a package that supplies R (exports count, vt08) or an explicit import of R.
  vt04 (a file-level import only) reads TOP. vt17 (both kinds of import) reads DEF.
- **(b)** No typedef of the class whose type is a specialization of a class from another package
  has a name that sorts before the nested typedef's name. This covers imported and qualified
  classes, any arguments, and the registry typedef itself (vt03, vt15, vt18, vt19).

These shapes keep the definition view: vt14, vt16 (`typedef int aa_t`), vt20 (a same-package
specialization `A #(1,1) other_t` sorting first), vt05, vt06, vt07 (`self_t`), vt08 (R through
`export u::R`), vt11, vt12, vt17 and VC/vc05.

The target row still fires: sfr_agent and sfr_config_object have only `this_t` and `type_id`,
and sfr_agent_pkg imports uvm_pkg in its body. The trace of the verified sweep reads the same 15
lines as the law sweep's.

Switches (evidence/switches.txt; 105 dirs: 58 attack, 47 of the implementer's):

- `R11U474_OFF` on the verified binary gives pristine's exit code and bytes on 105 of 105.
- `R11V474_OFF` and `R11V474_REGORDER_OFF` each give the law's bytes on 105 of 105.
- The law and the verified binary differ on exactly the 5 dirs in the table above.

## Reproduction of the implementer's numbers

- **Grid:** the 47 dirs (CS, RG, TI) reproduce on the law binary: exit code 0 and the same
  uhdm-cmp count, strict verdict and object count on 47 of 47. The verified binary is
  byte-identical to the law binary on all 47.
- **Target row:** uvm_param_vif_config_db reads uhdm-cmp 172 lines on the control and 1376868 on
  the law and verified binaries (law sweep, verified sweep and a runner call).
  - Simulating the sister's two faces with the implementer's addvif.cpp and addpa.cpp: pristine
    stays at 172 lines, the verified binary reads 0 lines and STRICT_NOTEQUAL fullname, first
    divergence at uvm_misc.svh 103 (the implementer's residue 1(c)).
  - So the line jump comes from uhdm-cmp's vector-size report on tb_params_pkg's typedef list
    (134 against 132). The head did not move away. The jump does NOT meet the brief's
    "count grows only when the head moves later" test.
- **easyUVM:** 60 lines on every binary.
- **Bytes:** this row's raw bytes are not deterministic on pristine either. Three runner draws
  gave three md5s for pristine and three for R11U474_OFF (verified and law). The pristine and OFF
  dumps are identical after path normalisation.
- **Away census:** 2221 fence-filtered earlier case dirs whose source holds class/typedef/import
  or a `::` with a class (evidence/away_census.txt).
  - No exit code moves, and 2218 dirs are byte-identical across pristine, law and verified.
  - The 3 movers are the implementer's: r11u472 TI/ti04, TI/ti05 and v11u470 VK/vk09. Each goes
    STRICT_NOTEQUAL fullname -> STRICT_EQUAL, with dump distance 22 -> 10, 30 -> 18 and
    16 -> 10.
  - The law and verified binaries are byte-identical on all 2221.

## Sweeps (one on the law binary, one on the verified binary)

Four stages ran from the worktree. The sv-tests stage ran through the main tree's
tests/sweep.sh, because the worktree's UVM folder is empty. Both commands exit 1 on a stale law
index alone.

- **Law** (/tmp/v11u474_sL):
  - probe EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0.
  - surelog 480 + 0 / 474 + 0, 0/0/0, the csv differing from the control only in the two LowMem
    log-path texts.
  - uhdm2rtlil 803/1/67 in both modes, 0/0/0.
  - downstream 803/66/2/0, csv identical.
  - sv-tests EQUAL 1935, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
    SURELOG_CRASH 8, TIMEOUT 1, 0/0/0. The csv is identical to the control's.
- **Verified** (/tmp/v11u474_sV): probe, uhdm2rtlil and downstream csvs identical to the law's.
  Two load artefacts, each rerun as its stage alone:
  - surelog read 1 regression, Earlgrey_0_1 testflags CMP_EQUAL -> TIMEOUT ("slang timeout").
    Rerun as the surelog stage alone: CMP_EQUAL in both modes, 0/0/0 (evidence/rerun_earlgrey.log).
  - sv-tests read 1 change, rsd SURELOG_CRASH -> TIMEOUT (the known 111 to 114 s row). Rerun as
    the sv-tests stage alone: SURELOG_CRASH, 0/0/0 (evidence/rerun_rsd.log).
  - No law fired on either row (both traces hold only uvm_param_vif_config_db).
  - With the reruns merged, every verified csv equals the law's.
- **byteverify** (SELFCHECK on):
  - law against the control /tmp/intr11u472: surelog 0 of 962, uhdm2rtlil 0 of 1608,
    downstream 0 of 805.
  - verified against the control and against the law: 0 of 962 (Earlgrey testflags merged from
    the rerun), 0 of 1608 and 0 of 805.
- **Canaries** on the verified csvs: ok=52 and ok=16, and both ctcan2 checks PASS.
- **Binary audit** (fence-filtered): surelog 1523 of 1573 cmds.txt name the verified binary (the
  other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346. No record
  names another slang-uhdm binary.

## Attack grid (58 dirs + 1 negative control)

Upstream slang accepts every attack case (rc 0), and every exit code is 0 on all three binaries.
The negative control NC/nc01 (`S::w` on a generic class) reads rc 1 upstream and 3 on pristine
and on the verified binary.

| binary | STRICT_EQUAL | STRICT_NOTEQUAL | NOT_EQUAL |
|---|---|---|---|
| pristine | 2 | 7 | 49 |
| law | 21 | 5 | 32 |
| verified | 22 | 8 | 28 |

Nine dirs are byte-identical on every binary: vp06, vp12, vr01, vr02, vr17, vt01, vt02, vt09
and vt13.

On the verified binary nothing moves away from golden by strict verdict, uhdm-cmp count or dump
distance (evidence/grid_pris_law_ver.txt).

Downstream on 11 movers (drivers/ds.py):

- DIVERGENT -> IDENTICAL: VR/vr19.
- EQUIVALENT -> IDENTICAL: vr06, vr07, vr13 and vr16.
- No change: vr09 and vr14 stay IDENTICAL; vp02, vp07, vp09 and vp11 stay EQUIVALENT.
- None moves away.

Cases and laws:

- **§ clsScopedRangeKept474**, VR/vr01 to vr19:
  - Newly STRICT_EQUAL: vr05 (typedef alias of the class), vr06 (interface), vr07 (generate
    block), vr09 (two instances), vr10 (parenthesized, multiplied and two-sided bounds), vr13 (two
    packed dimensions), vr14 (ANSI ports), vr15 (module-local class), vr16 ($unit class) and vr19
    (driven nets).
  - Closer: vr03 (package variable) and vr08 (typedef of the range) to STRICT_NOTEQUAL fullname.
    vr12 (initializers) 58 -> 36 uhdm-cmp lines. vr18 (with a package parameter) 98 -> 50.
    vr11 (static class function in the bound) dump distance 25 -> 8.
  - Unchanged: vr01 (module function local), vr02 (class method local) and vr17 (`S#(4)::w`).
  - vr04 (class enum constant `S::C`) moves bytes with the same uhdm-cmp count and dump distance.
- **§ elabParamClsScopedSubst474**, VP/vp01 to vp14: every mover is closer, 72 -> 46 or better.
  vp06 (bound through a body localparam) and vp12 (parenthesized override) are unchanged.
- **§ thisTdRegDefView474 / § thisTdRegOrder474v**, VT/vt01 to vt20: the table above.
  - Newly STRICT_EQUAL on the verified binary: vt05, vt06, vt07, vt10, vt12, vt16, vt17, vt18
    and vt20.
  - vt14 goes 670 -> STRICT_NOTEQUAL fullname.
- **§ cloneValFormalUnnamed474**, VC/vc01 to vc05:
  - vc01 goes STRICT_NOTEQUAL fullname -> STRICT_EQUAL.
  - vc05 goes 984 -> STRICT_NOTEQUAL depth, the imported-parameter listing face of rg11.
  - vc02 to vc04 keep their uhdm-cmp count and are closer by dump distance.

## Finding, not a break

§ cloneValFormalUnnamed474 tests `!parameter::VpiFullName().empty()` before `lawOn(...)`. UHDM's
parameter getter computes and STORES the full name when none is stored (caution z2). With the
switch off, a fresh copy that has no stored name would gain one.

- No measured effect: `R11U474_OFF` gives pristine's bytes on 105 of 105 dirs and pristine's dump
  on the target row.
- Not rebuilt for this (the build budget).
- Recommended: move `lawOn` ahead of the getter test at integration. That changes no bytes with
  the law on.

## Residues (all wrong on pristine too, none moved away on the verified binary)

1. **uvm_param_vif_config_db:** the sister's faces (ParamEmit emitPackage has no
   VirtualInterfaceType branch; the param_assign Rhs of `.A(K::w)`). Then the implementer's 1(c)
   at uvm_misc.svh 103 and 1(d).
2. **§ clsScopedRangeKept474:**
   - Golden names the class-scoped reference in a package variable and in a module typedef's
     range, where ours writes no full name (VR/vr03 `<in>S::w`, vr08 `t.S::w`).
   - Golden folds a package-scoped `p::P` inside the kept tree where ours keeps the reference
     (vr18).
   - The class enum constant `S::C` is written as a constant where golden keeps the ref_obj, since
     emitSyntaxExpr folds it (vr04; ExprEmit, the sister's).
   - A static class call in a bound (vr11).
   - The module function local (vr01, STRICT_NOTEQUAL type, at an older face).
3. **§ elabParamClsScopedSubst474:** the body localparam route (vp06), the parenthesized override
   (vp12), and the sister's param_assign face on every VP case.
4. **§ thisTdRegDefView474:**
   - The rule is still read from cases, not stepped through in Surelog.
   - A foreign specialization written as a class property (vt02, golden lists no copy) and in a
     module (vt09).
   - Literal arguments (vt01) and an extends of the specialization (vt13), unchanged.
   - vt03, vt15 and vt19 at older heads.
5. The implementer's residues and the carried lists of passes 472 and earlier.

## Sister-ground faces (reported, not written)

The implementer's three, plus ExprEmit's emitSyntaxExpr folding a class enum constant `S::C` in a
kept bound to a constant where golden writes a ref_obj (VR/vr04).

## Process

- **Builds:** one law build. Two verified builds: the first draft found packages with a scope
  lookup, which misses them; it was fixed on the case grid before any sweep.
- **Sweeps:** one full sweep on each of the law and verified binaries. Two single-stage reruns
  for load artefacts. No pristine build or sweep; the pristine reading is the master's control.
- **Waiting:** I waited for the sister's sweeps (r11u479, v11u479) and the master's landing sweep
  of pass 479 before the verified sweep.
- **Slip:** one shell ran uhdm-strictcmp with `STRICTCMP` unset, and bash tried to run a golden
  database as a script. git status of the main tree and of the worktree showed no file written.
  Every later call sourced drivers/env.sh and guarded the variables.
- **Self-match:** a `pgrep -f` guard matched its own command line and printed BUSY once. pgrep -af
  showed no live sweep then.
- **Fence:** the fence list was read into a file by a program and never printed. Every tree-wide
  list was filtered on it before any file was opened, and the repro folder was scanned with it
  before delivery.
