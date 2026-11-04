# r11u484 — the alias typedef faces (module/type ground)

Base 3ffaa399 (pass 482). The brief's first item, pass 482's finding 2 (the alias typedef copies
in import clones: v11u482 VM/vm11, VF/vf02, vf03), was decoded and written, and it led back to
three older alias faces that every alias case heads on first. All five laws come from Surelog's
handling of a typedef whose written base is another typedef (`typedef op_t op2_t;`):

* compileTypedef's DummyType branch (Surelog `src/DesignCompile/CompileHelper.cpp`): the alias object
  is `clone_tree` of the base's typespec, named with the BARE alias name and re-instanced at the
  package (the package listing qualifies its name later);
* compileVariable's `slStringConst` branch (`CompileType.cpp`): `getDataType(name)->getActual()->
  getTypespec()` is still null while the alias's own component compiles (bindTypedefs_ runs after
  every component), so a local written as that alias falls to the final `ref_var` branch.

Every law reads `lawOn(484, "R11U484_<LAW>_OFF")` from src/LawSwitch.h. `R11U484_OFF` drops them
all. `R11U484_TRACE=<dir>` logs each firing through `lawTrace(484, ...)`. There is no src/R*.h,
no getenv, no new include and no header change. Files touched: src/TaskFuncEmit.cpp,
src/UhdmExporter.cpp, src/TypeEmit.cpp (plus the regenerated tests/LAWS.md).

## Laws

| law | file | switch | statement |
|---|---|---|---|
| § ownNamedAliasLocalIsRefVar484 | TaskFuncEmit | R11U484_ALIASLOCAL_OFF | The local-variable twin of § ownNamedAliasRetIsRefVar177. A subroutine local, or a fixed array's element variable, written as the bare name of a typedef whose base is another typedef, declared in the subroutine's own package (definition listing only) or module, interface or program, is a `ref_var` that keeps its typespec. Cases: RV/rv01, rv05, rv06, rv07, rv14, rv16, rv21 (package), rv02, rv09, rv18 (module), rv19 (interface), rv22 (the package definition listing's own out-of-body copy of a class method, § 177's pkgClone). It does not fire in the package's top listing or in import clones, which compile after the bind (v11u482 VF/vf02's clones keep struct_var). It also does not fire on an alias imported from another package (rv03), on a package alias named from a class method (rv04), on a class alias (rv17, class_var), or on a name shadowed by an import (§ 177v's gate). |
| § aliasTdMembTsInstAtAlias484 | UhdmExporter | R11U484_ALIASMEMBINST_OFF | The member types that a package alias object owns read their package's TOP view, not its definition view (rv01, rv15, AL/al13). |
| § aliasTdTargetTopView484 | UhdmExporter | R11U484_ALIASTGTTOP_OFF | A package alias object's vpiTypedefAlias binds the base typedef's top listing object (rv01, rv14, rv10 for another package's base), not the definition listing object. Without it, the ref_var law exposes the definition/top view mismatch to uhdm-cmp: rv01 went from 56 to 710 lines with identical dumps. The unparented vector and int base copies (`w_t`, `i_t`) are left alone, because golden reads u(top) on rv06 and rv07 but p(all) on v11u250 D/d05_alias_param_func. |
| § cloneAliasCopyBareName484 | UhdmExporter | R11U484_ALIASCOPYNAME_OFF, also gated by R11U482_COPYINST_OFF (it runs inside that block) | Pass 482's finding 2. Inside import clones, a struct or union copy of a package alias is named with the bare alias name (`op2_t`, where ours wrote `u::op2_t`). It gets its own vpiTypedefAlias reference, full name `<chain>::op2_t`, bound to the base's top listing object; for an alias of an alias it is bound to a bare-named middle copy (al06). Its member types read the top view of the CANONICAL struct's package (vf03: s(top), where the copy itself reads u(top)). Copies are made in UhdmId order. Enum alias copies are left alone: renaming them let uhdm-cmp reach an older instance face (r11u231 AL/a06 went from 156 to 612 lines, r11u478 AF/af07 from 124 to 514). |
| § modAliasTdAtBaseClone484 | TypeEmit | R11U484_MODALIASTD_OFF | A module, interface or program typedef whose base is a struct or union typedef declared in that same body or in a package is the base's clone. It spans the base (3:11-3:38, where ours spanned the written name), carries a vpiTypedefAlias reference to the END of the alias chain (rv24: `c_t -> a_t`), keeps the base's vpiInstance (r11u161gen e14: lp), and parents its own member types at their member references. Cases: rv02, rv09, rv13, rv18, rv19, rv23, rv24; v11u405 VC/vc10's interface alias. |

The pass-480 interaction named by pass 482's verifier (finding 4) still holds:
`R11U480_FIXARRAGG_OFF` also turns off § cloneFixArrAggElemShared482. Pass 480's
`lawTrace(480, "fixArrLocalNamedAggElemTs480")` line now also fires in import clones.

## Grid (cases/RV, cases/AL; 38 case dirs)

Every case is accepted by upstream slang (`~/.local/bin/slang --single-unit`) and exits 0 on both
binaries. The drivers are drivers/runcase.sh and drivers/grid.sh (Surelog golden with
check_probe.py's flags; ours `dut.sv --single-unit --nobuiltin`). The tables are
evidence/grid_pristine.txt and evidence/grid_law.txt. Columns: uhdm-cmp lines, strict verdict,
path-normalised dump distance (dd), object-census distance (oc, pass 482's objcensus + msdist) and
instance-census distance (ic, pass 482's tsinst).

* pristine (the frozen base build, md5 585a272f69cd126ce4380e151b5114f1): STRICT_EQUAL 4, NOT_EQUAL 34.
* law (md5 698201aa341467c8ee0da6553f483da4): STRICT_EQUAL 22, STRICT_NOTEQUAL 1, NOT_EQUAL 15.

| case | law | pristine -> law |
|---|---|---|
| RV/rv01 | ownNamedAliasLocalIsRefVar484 + the two package alias laws | NOT_EQUAL 56 -> STRICT_EQUAL |
| RV/rv02 | ownNamedAliasLocalIsRefVar484 + modAliasTdAtBaseClone484 | NOT_EQUAL 17 -> STRICT_EQUAL |
| RV/rv03, rv04, rv11, rv12 | controls (an imported alias, a class method, a class property, a plain typedef) | STRICT_EQUAL on both |
| RV/rv05, rv06, rv07, rv16, rv21 | ownNamedAliasLocalIsRefVar484 (enum, vector, int aliases; a return; a task with two declarators) | NOT_EQUAL 56 -> STRICT_EQUAL |
| RV/rv08 | an initial-block local (StmtEmit, sister ground) | NOT_EQUAL 17 -> NOT_EQUAL 56 (dd 27 -> 6). The listing face is fixed; the head is now the sister's begin-local ref_var. |
| RV/rv09, rv13, rv18, rv19, rv24 | modAliasTdAtBaseClone484 (+ the local law) | NOT_EQUAL 17 -> STRICT_EQUAL |
| RV/rv10 | aliasTdTargetTopView484 (another package's base) | NOT_EQUAL 56 -> STRICT_EQUAL |
| RV/rv14 | the fixed-array element (local law) | NOT_EQUAL 836 -> STRICT_EQUAL |
| RV/rv15 | aliasTdMembTsInstAtAlias484 | NOT_EQUAL 56 -> STRICT_EQUAL |
| RV/rv17 | negative: a class alias | unchanged (NOT_EQUAL 30, an older face) |
| RV/rv20 | negative: import shadow | NOT_EQUAL 56 -> STRICT_EQUAL (the other alias op3_t fires) |
| RV/rv22 | out-of-body method local (pkgClone branch) | NOT_EQUAL 56 -> STRICT_EQUAL |
| RV/rv23 | module packed union and struct aliases | NOT_EQUAL 17 -> STRICT_NOTEQUAL fullname. The packed-struct bare-reference rule flips between base and alias; this is a residue. |
| AL/al13 | aliasTdMembTsInstAtAlias484 (alias in the importer of another package's struct) | NOT_EQUAL 56 -> STRICT_EQUAL |
| AL/al01 to al03, al05 to al08, al10 to al12, al14 | cloneAliasCopyBareName484 | NOT_EQUAL on both. dd and oc shrink on every one except al08 (dd 1834 -> 1918 with oc 236 -> 209: golden's per-reference private base copies print elsewhere). uhdm-cmp grows on al01 (56 -> 832) and al14 (56 -> 844) because the head moves later, from the home ref_var to the importer's re-written alias listing (golden's shared u::op2_t parented at the module with instance a(all)), with dd shrinking (407 -> 383, 553 -> 513). |
| AL/al04 | an alias formal in a clone | unchanged, not reached (residue: golden copies the formal's alias per clone) |
| AL/al09 | an enum alias in a clone (left alone) | NOT_EQUAL 56 -> 63 (dd 441 -> 431). The head moves from the home ref_var to the enum copy name `e2_t`. |

The brief's finding cases (pristine -> law; rows from evidence/away_movers_judged.txt):
v11u482 VF/vf02 dd 977 -> 899, oc 124 -> 97, ic 89 -> 41; vf03 dd 1001 -> 899, ic 89 -> 41;
v11u478 VM/vm11 dd 2623 -> 2251, oc 362 -> 298, ic 185 -> 97. The instance-census growth that
pass 482's verifier measured (79 -> 89, 157 -> 185) is now well below pristine. The copies carry
golden's bare names and the canonical package for member types. All three stay NOT_EQUAL at their
older heads (the importer's re-written alias listing, golden's shared `u::op2_t` parented at the
last importer with that importer's instance, and the per-reference private base copies).

## Away census (drivers/bytecensus.sh, drivers/judge.py; evidence/away_*)

The candidates are the 2008 fence-filtered earlier case dirs under tools/probe/*/cases whose
dut.sv declares a typedef with a named base (every law needs one). Each dir was run on pristine
and on the law binary.

* No exit code moves.
* 27 exit-3 dirs (slang front-end errors, whose partial bytes vary) are excluded.
* 56 dirs move bytes. Judged against fresh Surelog goldens:
  * 9 move up: r11u212 EA/e07, r11u231 TI/t07, r11u480 FA/fa10, fa26 and v11u480 VA/va22 go
    NOT_EQUAL -> STRICT_EQUAL (fa10, fa26 and va22 are pass 480's alias-of-typedef residues);
    r11u161gen e14_mod_alias_struct_ctl, r11u250 Q/q03_alias_contexts, v11u260
    VC/vc07_alias_chain and v11u442 VM/vm02 go NOT_EQUAL -> STRICT_NOTEQUAL.
  * 9 keep their verdict with smaller dd and oc: v11u241 AG/g10, v11u305 VT/vt26_td_alias,
    v11u405 VC/vc07, vc09, v11u478 VM/vm11, vm14, v11u482 VF/vf02, vf03, VM/vm04.
  * 2 grow in uhdm-cmp lines with dd and oc shrinking, the head moving later:
    * r11u272 L/l23_alias (17 -> 59): golden's alias copies carry member default values from
      `localparam in_t UU`, a Surelog artefact.
    * v11u405 VC/vc10 (17 -> 102): the interface's own alias is now golden's; the head is the
      module's interface-port typedef, which is § ifacePortTdCastLogicTs405's logic_typespec
      face.
  * 36 keep verdict, dd and oc, with the instance census equal or smaller.
* None moves down.

Two breaks were caught by this census and fixed before the sweep:

* The unparented base copy branch of § aliasTdTargetTopView484 moved v11u250 D/d05_alias_param_func
  away on the instance census. The branch was dropped.
* Renaming enum alias copies moved r11u231 AL/a06 (156 -> 612 lines) and r11u478 AF/af07
  (124 -> 514). Enum copies are now left alone.

Switches (evidence/switch_off_check.txt, switch_table.txt):

* `R11U484_OFF` gives pristine's bytes and exit code on 97 of 97 dirs (the 38 grid dirs and the
  away movers).
* Each switch alone moves the dirs listed in switch_table.txt. 91 of the 94 dirs checked move
  under at least one switch; the 3 that do not are the plain-typedef control rv12, the class-alias negative rv17 and AL/al04 (an alias formal in a clone, which no law reaches and which stays at pristine's bytes).

## Prediction and corpus movers

The prediction was written before the sweep, from a scan of the master's 7529 fence-filtered
control databases in /tmp/intr11u482 (evidence/tools/aliasscan.cpp; result in
evidence/prediction_scan.txt). It named:

* surelog TypedefAlias d/t and StructTypedef d/t (the two package alias laws);
* in an earlier, broader cut of the scan, the probe case r10vearl100repro/v6_more100.

Targeted traced runs before the sweep, on 83 surelog rows in both modes (every UVM row and every
row whose sources hold a named-base typedef) and on 37 uhdm2rtlil rows, read every status equal
to the committed csv. The law fired only in TypedefAlias d/t (and StructTypedef d/t on the final
binary).

THE PREDICTION MISSED Tnoc d/t. The scan cannot see a module-scope alias, because ours had no
vpiTypedefAlias on it before the law. In the sweep, Tnoc fires § modAliasTdAtBaseClone484 once
and § ownNamedAliasLocalIsRefVar484 twice. It stays CMP_NOTEQUAL with an unchanged detail and 28
uhdm-cmp lines in both modes, and its object-census distance shrinks 2009030 -> 2008993
(default) and 2008967 -> 2008930 (testflags).

## The one sweep (law16, md5 698201aa341467c8ee0da6553f483da4; evidence/sweep_summary.txt, sweep_trace.txt, byteverify.txt)

`tests/sweep.sh --jobs 3 --workdir /tmp/r11u484swp` was run with R11U484_TRACE on.

* probe: EQUAL 4026 + STRICT_NOTEQUAL 61, regressions 0, conversions 0, changes 0.
* surelog: 480 + 474 CMP_EQUAL, 0/0/0.
* uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
* downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0.
* sv-tests: EQUAL 1937, DIFFERENT 3, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions 0, conversions 0, changes 0.
  * The worktree has no sv-tests checkout or UVM folder, so the sweep skipped this stage. It was
    run alone right after, through the main tree's scripts/check_svtests.py, with `--baseline`
    the worktree's results/golden_svtests.csv.
* The sweep exited 1 on the stale law index alone. The README was edited after the index was
  generated; tests/LAWS.md is regenerated last.

byteverify against the control (SELFCHECK=1):

* surelog: 6 of 962 move, by law: TypedefAlias d/t, StructTypedef d/t and Tnoc d/t. Every verdict
  is kept.
* uhdm2rtlil: 0 of 1608. downstream: 0 of 805.
* The selfchecks flagged 961, 1607 and 804.

Trace:

* probe: r10vearl100repro/v6_more100 (aliasTdMembTsInstAtAlias484, status EQUAL kept).
* surelog: the 6 movers above.
* sv-tests:
  * tnoc, a known exception that stays DIFFERENT;
  * the 6 black-parrot SURELOG_CRASH rows bp_default, bp_multicore_1, bp_multicore_1_cce_ucode,
    bp_multicore_4, bp_multicore_4_cce_ucode_cfg and bp_unicore (modAliasTdAtBaseClone484 11
    times each), with their status unchanged.

Canaries: ok=52 and ok=16; ctcan2 PASS on both csvs.

Downstream on grid cases (ds.one): rv09 EQUIVALENT -> IDENTICAL; rv13 and rv24 IDENTICAL on both
binaries; rv23 EQUIVALENT on both.

Determinism: three draws each of AL/al07 and al06, the two cases that mint the most copies, read
one hash. The copies are minted in UhdmId order.

No sv-tests row and no corpus row converts. The gate stays ALL CLEAN.

## Goal 1

Not re-measured beyond the sweep: all 75 SURELOG_ONLY rows are unchanged, and no law of this pass
touches an exit code (no exit code moved in the grid, the away census or the sweep).

## Residues (ranked; all wrong on pristine too, none moved away)

1. **The importer's alias listing.** When the home package is imported, golden's shared
   `u::op2_t` alias is re-written by the last importer: it is parented at the module, takes that
   importer's definition-view instance, and its target is the importer's `u::op_t` copy (AL/al01
   head, vm11, vf03). Ours keeps it at the package. Ours also lists a separate module-level alias
   copy at the alias name's span (4:11-4:15) without a vpiTypedefAlias. This is now the uhdm-cmp
   head of every AL case.
2. **Enum alias copies in clones**: golden names them by the bare alias `e2_t` (AL/al09), and an
   enum alias of an alias holds a bare-named middle enum copy whose instance is not modelled
   (r11u231 AL/a06, r11u478 AF/af07).
3. **Private base copies per alias copy**: golden gives every clone copy its own private copy of
   the base struct (10 against our 3 on vf03). Ours binds the base's top listing object. The
   strict comparator does not see this; the dump does (al08 dd 1834 -> 1918, oc shrinking).
4. **Packed-struct module aliases**: the bare-reference rule for a struct assigned whole applies
   to the base in golden and to the alias clone in ours (RV/rv23, STRICT_NOTEQUAL fullname).
5. **Unparented vector and int base copies of package aliases**: golden reads u(top) on rv06 and
   rv07 but p(all) on v11u250 D/d05. Not decoded.
6. **Member defaults on module alias copies of package structs** (r11u272 L/l23_alias): a Surelog
   artefact.
7. **Carried, from pass 482's verifier list and the brief's backlog**, not worked this pass:
   * CI/ci03, ci16, VM/vm12, vm08, vm18, ci10, VF/vf10, vf05, vf09;
   * VC/vc02, vc03, vi03, vi05, vi07, vi08, va04, va06;
   * pass 480's va32, fa20, fa21, va24, fa07, fa22, fa23, fa25, fa27 (fa10, fa26 and va22 are now
     STRICT_EQUAL);
   * pass 478's vf06, vf02;
   * pass 476's vp06, iu14/vi15, vi16, vi01;
   * the AP cases;
   * the rest of the brief's list.

## Sister-ground faces (reported, not written)

* **StmtEmit's begin-block locals**: a local typed by an own-component alias, declared in a
  procedural begin block (an initial's begin, or a named block inside a function), is a
  `ref_var` in golden and a struct_var in ours. The cases are RV/rv08 (module initial) and AL/al12
  (`begin : blk` in a package function). The site is § blockLocalTdDeclIsRefVarUnsupported155's
  SITE 2 in StmtEmit, where the § ownNamedAliasLocalIsRefVar484 predicate
  (src/TaskFuncEmit.cpp) would apply.
* The sister faces of pass 482: ExprEmit's call-argument constant typespec in f(1) (CI/ci11,
  ci23) and its fold (ci22, VC/vc08); StmtEmit's § importCloneBodyLocalCopies175 begin copies.

## Process

* Measurement stayed within the budget: law1 to law16 were checked on case runs and targeted
  runner calls only, and the one full sweep ran on the final binary law16.
* SLIPS:
  * One targeted surelog verify_golden run (83 rows) overlapped the end of the sister r11u491's
    sv-tests stage. The pgrep that printed the live sweep did not gate the launch. This affected
    timing only.
  * The full sweep was launched while the master's probe-census job (a git mv over tools/probe,
    whose command line matched the quiet-wait pattern) was live. It was not a sweep; light load.
* The fence list was read into a file by a program, never printed. Every tree-wide list was
  filtered on it first, and the repro folder scans clean.

## Drivers and tools

* drivers/: runcase.sh, grid.sh, bytecensus.sh, swtable.sh, judge.py, quietwait.py.
* evidence/tools/:
  * aliasscan.cpp: the prediction scan;
  * aliasview.cpp: the alias-target instance views;
  * install.cpp: the package-pointer views;
  * callview.cpp: the call binding views.
* Pass 482's objcensus, tsinst and msdist (tools/probe/r11u482repro/evidence/tools) are used as
  they are. Build each against ~/.local's UHDM:
  `g++ -std=c++17 -I$HOME/.local/include X.cpp -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread`.
