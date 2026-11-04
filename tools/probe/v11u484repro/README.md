# v11u484 — adversarial verification of r11u484 (module/type ground)

Base 3ffaa399. Implementer's patch /tmp/r11u484.patch, applied clean on a fresh 3ffaa399 worktree.
Verdict: CONFIRMED WITH ONE BREAK FIXED AND ONE ABSTENTION ADDED (two refinements, both in
src/TypeEmit.cpp inside § modAliasTdAtBaseClone484, both read through fixOn(484, ...)).

## Binaries (frozen before any measurement)

* pristine: the main tree's build copied, md5 585a272f69cd126ce4380e151b5114f1 (no pristine build, per the budget)
* law: rebuilt from the patch, md5 698201aa341467c8ee0da6553f483da4, the same as the implementer's law16;
  links slang 12.0.0+545f88b2e
* verified: md5 a19ec751708ae4bdc74a941f68bb1abe

## Refinements

| refinement | switch | statement |
|---|---|---|
| § modAliasPkgBaseTopView484v | R11V484_MODALIASTOP_OFF | THE BREAK. A module, interface or program alias of a PACKAGE struct or union reads that package's TOP view as vpiInstance, and so do the member types the clone owns. Golden: `struct_typespec my_s inst=lp(top)` with its member types `lp(top)` on r11u161gen e14_mod_alias_struct_ctl. Golden reads `p(top)` on VL/vl08, vl10, VM/vm02, vm03, vm05, vm07, vm13, vm14 and r11u484 RV/rv18, and on v11u480 VA/va22. The law copied the definition-listing base's instance (`p(all)`), where pristine wrote none. The implementer's README reading of e14 as golden "lp" missed the view. The instance-census distance grew 4 -> 6 on e14, rv18, vl08, vl10 and va22, 10 -> 12 on vm02 and vm07, 14 -> 18 on vm05, and 16 -> 18 on vm03. On the verified binary every instance value equals golden's: e14, rv18, vl08, vl10, vm14 and va22 read ic 0. The remaining ic lines on vm02, vm03, vm05, vm07 and vm13 are an older parent face: a non-top module's typedef clone is unparented in ours and parented at the module_inst in golden, wrong on pristine too. Both package views are built before any module (exportDesign), so the top view is looked up at the law site. |
| § modAliasShadowAbstain484v | R11V484_MODALIASSHADOW_OFF | § modAliasTdAtBaseClone484 abstains when an import also offers the alias's name (§ ownNamedAliasNameIsNotShadowing177v). In that case golden resolves the variable to the imported `p::op2_t` and lists no clone of the module's alias. The law added a span, an alias reference and member references to an object golden does not have. VL/vl11 went uhdm-cmp 978 -> 992, dump distance 55 -> 62 and object census 11 -> 12 on the law. The verified binary restores pristine's bytes. |

Switches, measured on 151 dirs (the 38 grid dirs, the 57 attack dirs, e14 and the 56 away movers):

* `R11U484_OFF` on the verified binary gives pristine's bytes on 151 of 151.
* `R11V484_OFF` gives the law's bytes on 151 of 151.
* `R11V484_MODALIASTOP_OFF` alone restores the law's bytes on exactly the 12 top-view movers.
* `R11V484_MODALIASSHADOW_OFF` alone restores the law's bytes on vl11 only.
* Exit codes do not move on any binary.

Evidence: evidence/switch_*.txt.

## Reproduction of the implementer's numbers

* **Grid**, 38 dirs RV + AL (evidence/grid_{pris,law,ver1}.txt):
  * pristine STRICT_EQUAL 4, NOT_EQUAL 34;
  * law STRICT_EQUAL 22, STRICT_NOTEQUAL 1, NOT_EQUAL 15;
  * every row matches the implementer's README field for field (al01 56 -> 832, al14 56 -> 844, al09 56 -> 63, al08 dd 1834 -> 1918 with oc 236 -> 209, rv23 STRICT_NOTEQUAL name);
  * the verified binary is identical to the law on all 38 except rv18, which moves bytes by the top-view refinement (ic 6 -> 0).
* **Away census**, wider than the implementer's 2008: 12935 fence-filtered tools/probe case dirs whose dut.sv holds `typedef`, run on all three binaries (evidence/away_bytecensus.txt):
  * no exit code moves;
  * 56 dirs move from pristine to the law, exactly the implementer's 56;
  * judged against fresh Surelog goldens, the tags equal the implementer's on every dir: UP 9, closer 9, same 36, CMPGROW 2 (l23_alias 17 -> 59 and v11u405 VC/vc10 17 -> 102, dd and oc shrinking);
  * none moves down;
  * 3 dirs move from the law to the verified binary (e14, l23_alias, va22), each by the top-view refinement: ic 6 -> 0, 36 -> 32 and 6 -> 0 with every other field equal.
* **Sweep on the law binary**, /tmp/v11u484swl: the four worktree stages, then the sv-tests stage through the main tree's scripts/check_svtests.py, because the worktree has no sv-tests checkout or UVM folder (the implementer's route).
  * probe: EQUAL 4026 + STRICT_NOTEQUAL 61, 0/0/0.
  * surelog: 480 + 474, 0/0/0.
  * uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
  * downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, none unexcused.
  * sv-tests: EQUAL 1937, DIFFERENT 3, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, regressions 0, conversions 0, changes 0.
  * Every csv is equal to the master's control /tmp/intr11u482 row for row after workdir normalisation.
  * byteverify against the control: surelog 6 of 962 (StructTypedef d/t, TypedefAlias d/t, Tnoc d/t, the implementer's md5s exactly), uhdm2rtlil 0 of 1608, downstream 0 of 805. The selfchecks flag 961, 1607 and 804.
  * Probe: 0 of 4087 path-normalised dumps move against the control.
  * Canaries: ok=52 and ok=16; ctcan2 PASS on both.
  * Binary audit, fence-filtered: surelog 1523 of 1573 records name the law binary and the other 50 hold only a Surelog line; uhdm2rtlil 1742 of 1742; sv-tests 2346 of 2346.
* **Sweep on the verified binary**, /tmp/v11u484swv: every stage reads the same numbers, every csv is equal to the control row for row, regressions 0 in all five stages.
  * byteverify verified against the law: 0 of 962, 0 of 1608 and 0 of 805.
  * probe: 0 of 4087 databases move.
  * Canaries: ok=52 and ok=16; ctcan2 PASS.
  * PREDICTED before the sweep: the top-view refinement fires only where § modAliasTdAtBaseClone484 fires on a package base. Tnoc's alias base is in the interface tnoc_types itself, and tnoc_pkg offers no same-named type, so no corpus mover was predicted, and none occurred.
* The five corpus UVM rows stay STRICT_EQUAL (the surelog csv is equal to the control).

## Attack grid (57 fresh dirs in VL, VM, VP, VC; evidence/grid_*.txt, downstream_*.txt)

Every case is accepted by upstream slang; four first drafts that slang rejected were rewritten. Every exit code is 0 on all three binaries. VL/vl15 is excluded from the tallies because Surelog itself errors (UH0701 on `var op2_t a;`, exit 4).

On the remaining 56:

| binary | STRICT_EQUAL | STRICT_NOTEQUAL | NOT_EQUAL |
|---|---|---|---|
| pristine | 1 | 1 | 54 |
| law | 16 | 7 | 33 |
| verified | 16 | 7 | 33 |

Downstream on 23 module and package alias dirs: no dir leaves IDENTICAL. rv18 and vl08 go EQUIVALENT -> IDENTICAL on the law and verified binaries.

Not breaks (heads moving later, with dd and oc shrinking):

* vm01 and vm09 (17 -> 539): golden's constant `10'h15` sized 12 against ours 10; pristine has it too.
* vm12 (17 -> 78): golden's unsupported_typespec member of an alias type.
* vm03 (17 -> 30): the package-alias output port.
* vp09 (56 -> 140): a struct member typed by an alias.
* VC vc01, vc03, vc04, vc06, vc08, vc15 (56 -> 816 to 1260): the importer's re-written alias listing, the implementer's residue 1.
* vc06's dd grows 1703 -> 1759 with oc 235 -> 213 and ic 88 -> 56: golden's private base copies, the implementer's residue 3, as on al08.

## Findings that are not breaks

1. The implementer did not record the module-alias instance view. That is the break above, fixed.
2. Shapes the local law does not reach, all wrong on pristine too:
   * a queue element of the alias (VL/vl13: golden ref_var, ours struct_var);
   * an alias of an unpacked-array typedef (VC/vc12);
   * a module alias of a vector, an int or a $unit struct, where golden's typedef carries an alias reference ours lacks (vl02, vl14, vl03);
   * golden listing a module net `a` for a module function's vector-alias local (vl02, the next head).
3. The census growth on non-top modules (vm02, vm03, vm05, vm07, vm13) is the older unparented typedef clone face.

## Residues (ranked; all wrong on pristine too)

1. The implementer's residues 1 to 7 stand as written.
2. The items in findings 2 and 3 above.
3. The constant size of a struct with an enum member (vm01, vm09).

## Sister-ground faces

None new. The implementer's StmtEmit begin-block local face stands (RV/rv08, AL/al12).

## Process

* The verifier waited for the sister v11u491's sv-tests stage before building.
* One law build and one verified build, at -j 2.
* One five-stage sweep on each binary, each launched after a quiet wait.
* The fence list was read into a file by a program and never printed. Every tree-wide list was filtered on it first.
* No other agent's process was touched.
