# v11u468: adversarial verification of r11u468 (module/type ground, pass 468)

Base 770304e1. Implementer's patch /tmp/r11u468.patch (md5 49b86903990c2171d344a16a5ac3f70e), applied clean on a fresh worktree of the base. Verdict: CONFIRMED WITH TWO BREAKS FIXED. The three scoreboard conversions reproduce exactly. Two refinements land behind fixOn(468, ...): § oobTdCandClassOnly468v and § specNamedArgsAbstain468v.

## Binaries

| binary | md5 | what |
|---|---|---|
| /tmp/v11u468_bin/pristine | 1c992b8a6ef274d7f4fba9c55be2cf69 | a copy of the base build (the brief's md5) |
| /tmp/v11u468_bin/law | 0581ecaad93bf3cf6f1039f47e53b733 | rebuilt once from the patch; equal to the implementer's law13 |
| /tmp/v11u468_bin/ver1 | ebe8cf6f6dc2fa9f977f7bb14fdf00e7 | the verified binary: the patch plus the two fixes |

All three link slang 12.0.0+545f88b2e. There was no pristine build and no pristine sweep; the pristine reading is the master's control /tmp/intr11u466. Two builds in total (law, ver1), and one full five-stage sweep on each.

## The two breaks (legal SV, upstream slang accepts every case, pristine right or closer)

1. § oobClassTdImporterClass468 took a typedef that does not name a class as a candidate.
   - VO/vo06 (`typedef int this_type;` in a $unit class under `import p::*;`, the package in another file): pristine STRICT_EQUAL 86 -> law STRICT_NOTEQUAL type, because the m_check formal was bound to the int_typespec. Golden keeps § 231's winner.
   - VO/vo10 (`typedef struct {...} this_type;`): STRICT_EQUAL 89 -> STRICT_NOTEQUAL type, the same way.
   - VO/vo09 and vo13 (an int `this_type` in class cmp beside a class `this_type` in cmp2, in either order): golden binds work@cmp2's class typedef. The law's smaller-name rule picked cmp's int: 689 -> 30 uhdm-cmp lines and not equal.
   - FIX § oobTdCandClassOnly468v (fixOn(468, "R11V468_CANDCLASS_OFF"), UhdmExporter, in the candidate loop): a candidate typedef must name a class, meaning its canonical target is a ClassType. A typedef of another class still counts (VO/vo14 STRICT_EQUAL on both binaries).
   - Result: vo06 and vo10 are back on pristine's bytes (STRICT_EQUAL); vo09 and vo13 reach STRICT_EQUAL 96.
2. § specArgPairsImportedFormal468 re-paired specializations written with NAMED arguments.
   - In Surelog, the ClassDefinition branch of compileDatastructureTypespec (CompileType.cpp) walks only an Ordered_parameter_assignment list, so `C #(.U(item))` gets no parameter at all.
   - The implementer's README says named arguments are left alone, but the code had no such test.
   - VS/vs01: pristine and golden differ at the same head (we write a formal-order T where golden has nothing). The law renamed the entry to PA, so uhdm-cmp went 145 -> 157 lines at an unchanged dump distance (386).
   - FIX § specNamedArgsAbstain468v (fixOn(468, "R11V468_NAMEDSPEC_OFF")).
     - markNamedSpec468v records each class_typespec whose written spelling carries a NamedParamAssignment. It is called at the three emitClassTsParams sites with a syntax: TypeEmit's variable site, TypeEmit's module class typedef (§ 442) and UhdmExporter's $unit/package class typedef.
     - The record is a membership-only set, never iterated, and the re-pairing skips those typespecs.
     - vs01 is back at 145 lines. Its remaining bytes differ from pristine by law 3's fullname only.

Every fix line carries lawTrace(468, ...): oobTdCandClassOnly468v and specNamedArgsAbstain468v. Switch checks over all 89 grid dirs (38 implementer, 51 attack):
- R11V468_OFF on ver1 gives the law binary's bytes on 89 of 89.
- R11U468_OFF on ver1 gives pristine's bytes on 89 of 89.

## Implementer's numbers reproduced

- Grid: the implementer's 38 non-UVM case dirs (IU, OU, SP, TA) reproduce on rc, uhdm-cmp count and strict verdict on both binaries, line for line (evidence/impl_grid_*.txt). md5s differ only by the worktree path in VpiFile. ver1 gives the same verdicts as law on all 38.
- Law sweep /tmp/v11u468_sw (evidence/sweep/sw_*):
  - probe EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0.
  - surelog 480 + 474, 0/0/0. The csv differs from the control only in the two LowMem log-path texts.
  - uhdm2rtlil 803/1/67 in both modes, 0/0/0.
  - downstream IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0.
  - sv-tests EQUAL 1935, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, with regressions=0 conversions=3 changes=0.
  - Every csv equals the implementer's /tmp/r11u468_sw csv after workdir normalisation.
- Both sweep commands exit 1 on the stale law index alone (the worktree's source carried the fix tokens; the main tree's svtests run read its own index).
- byteverify (SELFCHECK=1, per corpus, law against the control):
  - surelog 1 of 962: default/Scoreboard, the known coin. Dump diff 0 lines; uhdm-strictcmp --no-canon reads STRICT_EQUAL 241570.
  - uhdm2rtlil 0 of 1608; downstream 0 of 805.
- Canaries ok=52 and ok=16; ctcan2 EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6 both PASS.
- Binary audit, fence-filtered (drivers/audit.py): surelog 1523 of 1573 records name the binary, and the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346.

## Verified sweep /tmp/v11u468_vw (ver1, R11U468_TRACE on)

- All five csvs equal the law sweep's row for row (evidence/sweep/vw_*): sv-tests regressions=0 conversions=3 changes=0, and every corpus stage 0/0/0.
- byteverify ver1 against law: 0 of 962, 0 of 1608, 0 of 805. Against the control: only the Scoreboard coin.
- Canaries ok=52 and ok=16; both ctcan2 PASS. The audit reads as above with ver1.
- Trace (evidence/sweep/vw_trace_counts.txt): the five laws fire on exactly the four predicted sv-tests rows (easyUVM 21 lines, each scoreboard row 6) and nowhere else.
  - § oobTdCandClassOnly468v logs 39692 skip lines on 169 databases (4 probe cases, 9 surelog row-modes, 156 sv-tests rows). Each line is a non-class typedef of a formal's name being REJECTED before the other candidate tests, a check rather than an effect, which is why byteverify reads 0 movers against law.
  - § specNamedArgsAbstain468v fires nowhere in the sweep.
- Determinism: three concurrent draws of uvm_scoreboard_env with ver1 read one md5 (26a2fd53…), STRICT_EQUAL 432906 objects and uhdm-cmp 0 lines.

Target rows on ver1 (runner with --keep-golden, evidence/sweep/target_rows_ver1.csv; goldens from the cache):

| row | control | ver1 |
|---|---|---|
| testbenches/uvm_scoreboard_env.sv | DIFFERENT (uhdm-cmp 2200983) | EQUAL, equal (STRICT_EQUAL 432906) |
| testbenches/uvm_scoreboard_monitor_env.sv | DIFFERENT | EQUAL, equal |
| testbenches/uvm_scoreboard_monitor_agent_env.sv | DIFFERENT | EQUAL, equal |
| generated/easyUVM/top.sv | DIFFERENT (uhdm-cmp 659635) | DIFFERENT (uhdm-cmp 60) |
| generated/uvm-examples/uvm_param_vif_config_db.sv | DIFFERENT (230) | DIFFERENT (230) |

## Attack grid (51 fresh dirs: VF, VI, VO, VS, VT)

Every case is accepted by upstream slang (drivers/slangcheck.sh, real exit code read, negative control rc=1), and every exit code is 0 on all three binaries. Full table: evidence/attack_table.txt.

- STRICT_EQUAL: 8 on pristine, 30 on law, 34 on ver1. 11 dirs are byte-identical pristine against ver1.
- No dir reads further from golden on ver1 than on pristine, by strict verdict or by dump distance (evidence/attack_dist_ver1.txt). vs01 is at an equal distance, with law 3's fullname only.

Per law (ver1):
- § unitInclClassImports468, VI:
  - vi01 to vi04 and vi07 to vi09 reach STRICT_EQUAL. These cover macro-written classes, a macro defined in another file or in an include, two-level includes, an import inside an include, an explicit import beside a wildcard, and a class include inside a module body.
  - vi06 (import in another file) is a byte-identical control.
  - vi05 (the import written in an included file) moves closer (624 -> 565 lines, distance 884 -> 646). Its head is the module listing in the sister's EmitHelpers.h, the same face as the implementer's IU/iu07.
- § specArgPairsImportedFormal468, VS:
  - Reach STRICT_EQUAL: vs02 (type plus value args), vs04 (two imported packages), vs06 (more args than imported params), vs08 (explicit import p::PA), vs11 (method local), vs12 (class typedef of a spec), vs13 (value formal first) and vs15 (wildcard plus explicit import).
  - Unchanged: vs03 (package class spec under the package's own import, 32 lines), vs10 (extends, STRICT_EQUAL both) and vs14 (module-local, STRICT_EQUAL both).
  - vs07 (a defaulted formal not written) moves 230 -> 242 lines but closer by distance (379 -> 361). The first entry is now golden's PA, while our builder still lists the unwritten formal (renamed PB), an older face.
  - vs09 (module typedef of a spec) moves 56 -> 1318 lines but closer (269 -> 259). Its head is now the module_inst: golden's implicit net work@top.item and its unlocated type_parameter, both older faces.
- § clsPropSpecTpFullName468, VF: vf02 (nested class) and vf05 (two declarators) reach STRICT_EQUAL. vf03 (rand/static) and vf06 (nested spec C #(C #(byte)): the inner `C.T.C.T` stays where golden writes `work@env::nest::C::T::C::T`) move closer.
- § oobClassTdImporterClass468, VO:
  - Reach STRICT_EQUAL: vo01 (class in an include of a second file), vo04 (two packages' classes), vo05 (generic class), vo09 and vo13 (after the fix).
  - vo14 (a typedef of another class) is STRICT_EQUAL on law and ver1.
  - Standing, unchanged or closer at the same count: vo02 (package and class in one root through an include, 572 lines), vo03 (two module-local classes of one name, 233), vo07 (explicit import p::lib, 573), vo08 (nested class), vo11 (typedef p::aa, 17) and vo12 (enum typedef, 366).
- § specArgTypedefNameShares468, VT: vt03 (typedef of a typedef) and vt07 ($unit typedef, two uses) reach STRICT_EQUAL. vt04 (a typedef of a spec as argument) goes 224 -> STRICT_NOTEQUAL file. vt01 (module typedef, 39 -> 23) and vt06 (method local, 10 -> 8) move closer. vt02 (an imported package typedef) moves its head later: fullname #24 -> name #29, where golden's argument is the package's `p::e_t` object and ours a fresh class_typespec. Law 5 does not take package typedefs. vt05 is a control.
- Downstream on 6 module-reading cases (vf04, vs14, vi09, vo03, vt01, vi01): IDENTICAL on pristine and ver1.

## Away census (wider than the implementer's 440-469 scope)

Every tools/probe/*repro case dir of every pass that holds a class together with `#(`, an import, an include or extern: 4022 dirs, fence-filtered by name before any file was opened. pristine against ver1, absolute paths (evidence/away/).

- 3966 exit-0 and 7 exit-4 dirs are byte-identical.
- 18 exit-3 dirs differ, as they do between two pristine runs (all 18 checked).
- 31 exit-0 movers, judged against golden on both binaries (evidence/away_movers_*.txt), all attributed by trace or switch. None moves away.
  - 7 reach STRICT_EQUAL: r11u291 CS/c07 and c17, v11u152 KV/v13, v11u291 VC/vc07, v11u428 VK/vk21 (law 3), and v11u434 VS/vs15 and vs16 (law 2).
  - v11u434 VR/vr03: NOT_EQUAL 56 -> STRICT_NOTEQUAL fullname.
  - v11u434 VS/vs13: 241 -> 48 lines.
  - r11u255 F/f11: head later (fullname #5 -> name #77).
  - Closer by dump distance: c24, y07 and v11u403 VH/vh02 (287 -> 161).
  - r11u436 CS/cs12: its extra entry is renamed in golden's style, at the same distance.
- 15 movers have an identical dump and STRICT_EQUAL --no-canon: r11u254 I/i10_copy, r11u434 SF/sf04 to sf07 and v11u434 VS/vs01 to vs12 except vs11.

**FINDING: an untraced byte mover in § clsPropSpecTpFullName468.**
- The law computes `cdFull` from `class_defn::VpiFullName()` before testing whether any type parameter matches. UHDM's generated getter (scripts/classes.py) computes ComputeFullName() and STORES it when the stored name is empty.
- So every class_defn holding a property typed by a specialization gets its full name written into the database even when the law does not fire. That is a byte change with no trace line.
- Every reader calls the same getter, so the dump, uhdm-strictcmp and the plugin see the same value.
- Bisect: R11U468_PROPSPECFULL_OFF alone restores i10_copy and sf05 to pristine's md5, and three draws per binary are stable.
- Not fixed here (the budget allows no third build). The next pass should read `cdFull` only after a type parameter matches. No corpus row moves from it: byteverify reads 0 against the control.

## Residues (ranked; all wrong on pristine too, none moved away on ver1)

1. easyUVM: 60 uhdm-cmp lines. The implementer's faces stand: the ExprEmit default argument on `exp.compare(rec)`, the uvm_report string constants, and modules or interfaces in included files at EmitHelpers.h collectMaterializedPkgs, the sister's.
2. param_vif_config_db: law 2's pairing for package-scoped VALUE arguments (unchanged, 230 lines).
3. Law 2's builder faces:
   - named-argument specializations, where golden lists nothing and we list every formal (VS/vs01);
   - a defaulted formal not written but listed by emitClassTsParams (vs07);
   - a module typedef of a spec, where golden's type_parameter is unlocated and the ref_obj argument mints an implicit net (vs09);
   - a package class spec under the package's own import (vs03).
4. Law 4: two module-local classes of one name share one candidate key (VO/vo03; the key holds no module name). Other faces: an explicit import p::lib (vo07), a nested class's typedef (vo08), `typedef p::aa this_type` (vo11), an enum this_type (vo12), the one-root include case (vo02), and mixed kinds.
5. Law 5: package typedef arguments through a wildcard import (VT/vt02), a typedef of a spec as argument located at the formal (vt04, file), module and method-local typedef arguments (vt01, vt06).
6. Law 3: the nested specialization's inner full name (VF/vf06) and the untraced getter write above.
7. Law 1: an import written in an included file (VI/vi05) at the sister's module listing.
8. The implementer's ranked residues and the carried lists of pass 466 and earlier.

## Sister-ground faces (reported, not written)

The implementer's two stand:
- EmitHelpers.h collectMaterializedPkgs raw-buffer test (VI/vi05, IU/iu06, iu07);
- ExprEmit's default argument on a type-parameter handle call (easyUVM comparator.sv 63:14).

No new face found.

## Process

- Every build, grid batch, census and sweep waited on drivers/quietwait.py (pass 466's, with its own name excluded). The away-mover reruns waited behind the sister v11u473's sv-tests stage.
- The fence list was read into /tmp/v11u468_fenced.txt by a program and never printed. The away census filtered paths on it before opening any file. No fenced test was named, opened or run.
- No other agent's process was touched. No relative redirect. Two builds and two full sweeps, within the budget.
- One slip, affecting no measurement: the first fix build failed to link because the TypeEmit declaration of markNamedSpec468v sat outside namespace slang_uhdm. It was moved inside and rebuilt, and that build is ver1.
