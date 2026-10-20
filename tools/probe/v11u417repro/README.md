# v11u417 — adversarial verification of r11u417 (expression/parameter ground, ninth sv-tests pass on this ground)

Base 1e4b0333d (pass 415). Implementer's patch /tmp/r11u417.patch (md5
7d18bcdf098f774191e6601415fcf6e2), applied clean on a fresh worktree.

VERDICT: the two sv-tests conversions and every gate reproduce exactly, but
§ foreachArrayNamesClass417 BREAKS three fresh cases on legal SV where pristine
was right (pristine STRICT_EQUAL -> law NOT_EQUAL). Two refinements fix them
(below); the verified binary holds every conversion and every gate.

## Binaries (frozen under /tmp/v11u417_bin before any measurement)

| binary | md5 | origin |
|---|---|---|
| pristine | 42a17ef86d53481c31bcf8b76ee9a73f | the main tree's build/slang-uhdm at the base (the budget: no pristine build) |
| law | 59aec9b436104c4cb522cae128e235ef | rebuilt once from the implementer's patch, equal to the implementer's final binary |
| verified | 4379811b70e2c74ffe0c3ada41ef3961 | the law plus the two refinements (second and last build) |

All three link slang 12.0.0+545f88b2e. Every cmds.txt of both sweeps names
only the binary under test (fence-filtered paths): surelog 1523 of 1573 (the
rest hold no slang line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346.

## The breaks and the refinements

Surelog's CompileHelper::compileVariable (third_party/Surelog/src/DesignCompile/
CompileType.cpp) finds a foreach array's name as a class only through
design->getClassDefinition with the keys ResolveSymbols registers
(DesignCompile/ResolveSymbols.cpp), or through compileTypespec's class_typespec.
Two kinds of class slang sees are in neither, and the law's scope walk took
both:

1. § foreachIfaceClassAbstain417v (StmtEmit, foreachArrNamesClass417,
   fixOn(417, "R11V417_IFCLASS_OFF")). An INTERFACE class: ResolveSymbols
   files paInterface_class_declaration in its default branch as a module
   definition, never a class. Golden keeps the ref_var over the
   array_typespec.
   - cases/VC/vc02 (`interface class b` at $unit, module `int b[3]`): pristine STRICT_EQUAL 50 objects, law NOT_EQUAL (cmp 54), verified STRICT_EQUAL 50 objects, bytes back at pristine's.
   - cases/VC/vc27 (an interface class in a package, a package function's local `int b[2]`): pristine STRICT_EQUAL 85, law NOT_EQUAL (cmp 54), verified STRICT_EQUAL 85 at pristine's bytes.
2. § foreachNestedClassAbstain417v (StmtEmit, foreachArrNamesClass417,
   fixOn(417, "R11V417_NESTEDCLASS_OFF")). A class NESTED in a class:
   ResolveSymbols' sl_collect_all stops at a class_declaration, so the
   nested class is never registered, and compileTypespec does not resolve it
   from the enclosing class's method either. Golden keeps the ref_var over an
   unsupported_typespec.
   - cases/VC/vc07 (class p::A with nested class b and a method local `int b[3]`): pristine STRICT_EQUAL 43, law NOT_EQUAL (cmp 54), verified STRICT_EQUAL 43 at pristine's bytes.

Either refinement turns the lookup into "not found", which is pristine's
path. R11V417_OFF gives the law's bytes and exit code on 105 of 105 of my case
dirs and 41 of 41 of the implementer's. Each refinement's own switch gives the
law's bytes on its own cases (vc02, vc27; vc07). No src/R*.h, no getenv, no
reader function; the two switches go through src/LawSwitch.h. Only
src/StmtEmit.cpp changes beyond the implementer's patch.

Neither refinement fires anywhere in the sweeps. The verified sweep's trace
shows only the law's six lines on the two converted rows. The verified
binary's bytes equal the law's on every database of surelog, uhdm2rtlil and
downstream (byteverify 0 of 962, 0 of 1608, 0 of 805), and on all 2306
earlier-pass case dirs. Every sweep csv is identical to the law sweep's,
apart from the LowMem log-path text.

## Targeted rows (reproduced on both binaries)

| row | control (base) | law | verified |
|---|---|---|---|
| chapter-18/18.5.9--global-constraints_1.sv | DIFFERENT | EQUAL,,equal | EQUAL,,equal |
| chapter-18/18.5.13--constraint-guards_1.sv | DIFFERENT | EQUAL,,equal | EQUAL,,equal |
| chapter-18/18.14--random-stability_1.sv | DIFFERENT | DIFFERENT (no firing) | DIFFERENT |
| generated/basejump/bsg_cache_BaseJumpSTL_bsg_cache_non_blocking_data_mem.sv | DIFFERENT | DIFFERENT (no firing) | DIFFERENT |

Fresh rows (/tmp/v11u417swV/svtests.csv):

    chapter-18/18.5.13--constraint-guards_1.sv,EQUAL,,equal
    chapter-18/18.5.9--global-constraints_1.sv,EQUAL,,equal

## Gates (one five-stage sweep on the law binary, one on the verified binary)

Both sweeps ran on a quiet machine (drivers/quiet.sh: three empty reads in a
row). Workdirs were /tmp/v11u417swL and /tmp/v11u417swV, with names the same
length as the control's /tmp/intr11u415.

The four corpus stages ran from the worktree. The sv-tests stage ran right
after, through the main tree's scripts/check_svtests.py (read-only), because a
worktree has no UVM tree. Driver: drivers/sweep.sh.

- **probe:** EQUAL 4018, STRICT_NOTEQUAL 69 of 4087; 0/0/0. The csv is byte-identical to the control's and to the implementer's.
- **surelog:** default 480 + 0, testflags 474 + 0; 0/0/0. The csv differs from the control only in the two LowMem log-path texts.
- **uhdm2rtlil:** 803/1/67 in both modes; 0/0/0. The csv is identical to the control's.
- **downstream:** IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not identical and not excused 0. The csv is identical to the control's.
- **sv-tests:** regressions 0, conversions 2 (above), changes 0. Totals: EQUAL 1811, STRICT_NOTEQUAL 6, DIFFERENT 123, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1. The law csv is byte-identical to the implementer's /tmp/r11u417_sw/svtests.csv, and the verified csv to the law csv.
- **Stale law index:** the law sweep's corpus stages exited 1 only because tests/LAWS.md was stale once my cases were added. It was regenerated before the verified sweep, which exited 0.
- **byteverify (evidence/byteverify.txt):** law against control, and verified against control, read 0 of 962, 0 of 1608 and 0 of 805, with identical path sets. Verified against law reads 0 everywhere; SELFCHECK flags 961, 1607 and 804.
- **canaries:** ok=52 and ok=16 on both sweeps; ctcan2 (EXPECT_UNKNOWN=1 / 6) PASS on both.
- **trace census:** the laws fire only on 18.5.9_1 and 18.5.13_1, three lines each. Nothing fires in the probe, surelog, uhdm2rtlil or downstream stages.
- **away census on sv-tests (evidence/svtests_away_census_law_vs_control.txt):** the 150 kept databases, law against control, compared by path- and id-normalized dump:
  - 149 identical.
  - tnoc differs only because uhdm-dump hits its 300 s timeout at different points; uhdm-cmp law against control reads 0 lines, and the law never fires on it.
  - Positive control: 18.5.9_1 re-exported with and without R11U417_OFF gives different dumps.

## Reproduction of the implementer's claims

- Law binary md5 equal to the implementer's.
- Grid (evidence/implementer_grid_reproduced.txt): the 41 case dirs reproduce line for line in exit code, uhdm-cmp lines and strict verdict. One exception is the dump-distance column of FC/fc17: 44 -> 26 in my run, 24 -> 4 in the implementer's, with the same verdicts. R11U417_OFF gives pristine's bytes and exit code on 41 of 41.
- Earlier passes (evidence/earlier_pass_cases_pristine_law_verified.txt): 2306 fence-filtered case dirs of [rv]11u401-416repro. Pristine differs from the law only on r11u413's FB residue cases fb01, fb02 and fb05; verified equals the law on 2306 of 2306; no exit code changes.
- Goal 1 (evidence/goal1.txt):
  - All 75 SURELOG_ONLY details are upstream slang `error:` lines; none is the exporter's note.
  - v11u413 VC/vc04 `C::mk().arr[1]` and VI/vi06 `u.mk(x).a[2]`: ours exit 4 ('element select base'), upstream slang 0, Surelog 3 (SNT:PA0207 at 10:25 and 13:22). Not forced, since there is no golden.
  - v11u415 VT/vt03: exit 0.
  - bp_unicore alone (the runner's command, verified binary, guard on): exit 3 in 16.5 s at 780 MB with the same substr error. No memory-bounded export exists, so the guard stays.

## Attack grid: 105 fresh case dirs (evidence/grid_verified.txt, grid_law_pristine_vs_law.txt)

Upstream slang accepts every case. Every case exits 0 on all three binaries.
Each line gives pristine, law and verified, each with exit code, uhdm-cmp
lines, dump distance and strict verdict. Each line also checks that
R11V417_OFF on the verified binary gives the law's bytes and that R11U417_OFF
gives pristine's bytes: 105 of 105 for both. The law grid also checks that
each group's own switch gives pristine's bytes: 105 of 105.

| group | law | cases | pristine -> verified |
|---|---|---|---|
| VC | § foreachArrayNamesClass417 (vc02, vc27: § foreachIfaceClassAbstain417v; vc07: § foreachNestedClassAbstain417v) | 36 | 22 NOT_EQUAL -> STRICT_EQUAL; 6 STRICT_EQUAL kept at pristine's bytes (vc02, vc07, vc27, vc15, vc33, vc34; the first three were the law's breaks); 8 still NOT_EQUAL: 6 toward golden or at the same cmp (vc04, vc06, vc14, vc24, vc30, vc36) and vc17, vc29 at pristine's bytes |
| VT | § foreachArrayNamesTypedef417 | 27 | 22 NOT_EQUAL -> STRICT_EQUAL; vt08 STRICT_NOTEQUAL kept at pristine's bytes; vt18, vt19 NOT_EQUAL toward golden; vt04, vt28 abstain at pristine's bytes |
| VH | § hierSelParenBoundPretty417 | 42 | 11 NOT_EQUAL -> STRICT_EQUAL; 3 NOT_EQUAL -> STRICT_NOTEQUAL endcol (vh17, vh22, vh29; the endcol is the part_select span over a parenthesized right bound, wrong on pristine too); 23 STRICT_EQUAL kept (19 with moved bytes and an identical dump: the law renames an unreferenced copy, as the implementer reported for hp08/hp10/hp14); 5 NOT_EQUAL at the same distance |

The VC cases cover:

- Converted: forward typedef class (vc01), virtual class (vc03), module-local class (vc05), class property (vc08), nested foreach (vc09), two dimensions (vc10), `b b[3]` (vc11), explicit import (vc12), function formal (vc13), two instances (vc16), associative array (vc18), queue in a $unit class task (vc19), always_comb (vc20), $unit function (vc21), port array (vc22), a class nested in another class iterating a $unit class name (vc23), a module-local class read from a module-local class's method (vc25), $unit import (vc26), two foreach on one array (vc28), class after the module (vc31), parameter array (vc32), package importing a package (vc35).
- Controls: uppercase class name (vc15), constraint foreach (vc33), a class in another module (vc34).
- Still unequal, all wrong on pristine too: program (vc04, vc24), interface-local class (vc06), generate block (vc14), a non-exported transitive import (vc17), parameterized class (vc29), `b[i][j]` inner foreach (vc30), out-of-body $unit method (vc36).

Away census on the cases still unequal (law diff lines not in pristine's
diff): none is a pristine-right line.

- vc04, vc24, vt19 (program): golden leaves the loop variable a ref_var; ours is an int_var on pristine and on the law alike.
- vc06: golden's class_typespec is named (b); the law's has no name. Pristine wrote no class_var at all.
- vc14, vt18 (generate): golden leaves the loop variable unresolved; pristine writes int_var too.
- vc24's uhdm-cmp count grows 54 -> 56 because its first difference moved later in the walk, to the loop variable, which pristine also had wrong.

Downstream (evidence/downstream_cases_pristine_law.txt): on all 105 cases
pristine and law give the same verdict. vh12 is DIVERGENT on both (pristine
too); vc04, vc24 and vt19 are READ_FAIL on both lanes. Nearly every case is
NO_GATES on both lanes (the selects are pure wiring), so this is a weak
instrument.

## Residues (ranked; all wrong on pristine too, none moved away)

1. Program scope (vc04, vc24, vt19): Surelog leaves the foreach loop variable a ref_var over an unsupported_typespec where we write the int_var fallback. Golden also mints a logic_net for a task-local array named like a class (vc24). StmtEmit, this ground.
2. A class declared in an interface (vc06): golden's class_typespec is named. The interface class is not filed under "work@ifc::b", so compileTypespec's branch answers. The law's viaMember marks interface scopes; a narrowing to named would convert vc06.
3. A generate-block foreach (vc14, vt18): golden's loop variable is unresolved, and its array element typespec is int where we write logic (vc14).
4. `foreach (b[i][j])` (vc30): golden's inner array is a class_var too; the law handles a bare identifier only.
5. A parameterized class (vc29, fc21), a non-exported transitive import (vc17), an unpacked-array typedef (vt04), a class-scope typedef (vt28): the law abstains.
6. vh07 (interface member select) and vh08 (struct array element): at pristine's bytes; the head is elsewhere.
7. The part_select end column over a parenthesized right bound (vh17, vh22, vh29: golden 5:32, ours 5:31). ExprEmit, this ground.
8. Carried: everything in the implementer's README residue list, which I reproduced:
   - 18.14_1's class-property array initializer (UhdmExporter emitClassDefn, sister ground).
   - The definition-view hier_path name (TypeEmit emitSyntaxExpr, sister ground).
   - fc11/fb01's method listing (TaskFuncEmit/UhdmExporter, sister ground).
   - p88/p124 (ModuleEmit, sister ground).
   - The goal-1 probe faces vc04 and vi06 (Surelog rejects them).

## Sister-ground faces (reported, not written)

The implementer's four, confirmed:

- UhdmExporter emitClassDefn: 18.14_1.
- TypeEmit emitSyntaxExpr `hp->VpiName(dispRaw)`: bsg_cache_non_blocking_data_mem 110:62, hp01.
- TaskFuncEmit/UhdmExporter: the out-of-body method listing under `import p::*` (fc11, fb01, and vc36 here).
- ModuleEmit: p88/p124.

## Process

- Budget: one law build (md5 equal to the implementer's), one verified build. One five-stage sweep on each, both on a quiet machine. No pristine build or sweep (the control is /tmp/intr11u415). No third build or sweep.
- The attack grids ran only after the sister v11u418's sweep had ended and the machine read quiet three times in a row. My two sweeps never overlapped another sweep.
- A first away-census run compared dumps whose header line held two different paths and read DIFF everywhere. I stopped its two loop processes by their PIDs and reran it with the header stripped. Nothing else was touched.
- The fence list was read into a file by a program without printing it. Every tree-wide list was filtered on it before any file was opened. No fenced test was named, opened or run, and no other agent's process was touched.

Files:

- drivers/: case.sh, grid.sh, vgrid.sh, ds.sh, earlier.sh, away.sh, sweep.sh, quiet.sh.
- cases/: VC (36), VT (27), VH (42).
- evidence/.
