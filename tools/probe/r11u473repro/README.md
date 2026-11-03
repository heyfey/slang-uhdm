# r11u473 — a module's import copy of a package parameter typed by an imported typedef (expression/parameter ground, pass 473)

Base 01d7233b (pass 471). Ground: src/ParamEmit.cpp, src/ExprEmit.cpp and src/EmitHelpers.h.
The one law is read through src/LawSwitch.h: `lawOn(473, "R11U473_MODCOPYTD_OFF")`. `R11U473_OFF=1` drops the pass.
`R11U473_TRACE=<dir>` logs each firing through `lawTrace(473, ...)`. There is no src/R*.h, no getenv, no reader function and no header under include/ changed.

Binaries (frozen, chmod 555):
- pristine: `/tmp/r11u473_bin/pristine`, md5 1c8052676adb70d4a65475f27607fafe. The worktree's first build, equal to the main tree's build/slang-uhdm. Case runs only.
- law: `/tmp/r11u473_bin/law6`, md5 afa30e9d601c11d257df9155230c42ca, linking slang 12.0.0+545f88b2e.
- law1 to law5 were intermediate binaries, used only on case runs.

## Item (a): no open row heads on this ground

The 8 DIFFERENT sv-tests rows at the base all head on the sister's ground (pass 469's census; pass 471 re-measured them).
So this pass took this ground's residue backlog, largest family first: **the module-level import copies** (passes 469 and 471's residue 1).

## Characterize

The family splits into three faces. Each was read with evidence/tools/modroles.cpp, which prints every typespec hop of every role (vpiParameter entry, param_assign Lhs and Rhs, continuous-assignment fold, variable initializer) in both views, with each hop's name and Instance:

1. **(written) A package's own parameter typed by a typedef it imports, copied into a module** (`package b; import a::*; parameter t PB = 5;` read by `module top; import b::*;`). This covers r11u469 IR/ir08 and IA/ia04, r11u471 EX/ex07, v11u469 VM/vm01 and VT/vt14, and this grid's MC cases. The head on ir08 is golden's module copy of PB:
   - golden: the alias target of the copy's typespec is `logic_typespec (t)` Instanced at the elaborated a;
   - ours: the importing package's typedef listing object `logic_typespec (a::t)` Instanced at b. VpiName differs (`t` against `a::t`), so uhdm-cmp reads 112 lines.

   The same chain stands in the module's continuous-assignment folds (`assign y = PB;`, `i + PB`), in its variable initializer (`logic [3:0] w = PB;`) and in both views.
2. **(not written) The elaborated module copy's Rhs of a parameter defined by another parameter** (`parameter t PC = PA;` or `localparam t LB = PA;`). Golden respells it `INT:33` with decompile `33`. Ours keeps the source literal `DEC:33` / `6'd33`, because the elaborated respell § impCopyBasedDecKeep runs before the name copy sets the value. `PD = PA + 6'd1` is golden `INT:34` and ours `UINT:34`. This is the next head on ex07, vt14 and vm01 (scratch cases c1 and c2 in evidence/scratch_faces.txt).
3. **(not written) The elaborated module variable initializer fold of an imported, typed int parameter** (`logic [31:0] q = LB;`; r11u471 PI/pi04 and pi06, r11u469 IA/ia10). Golden's fold typespec is Instanced at the elaborated package. Ours has no Instance, because ModuleEmit's variable-initializer branch calls makeParamTs with no instance. The same branch also gives a qualified `b::LB` initializer a typespec that golden leaves out. This face is the sister's: see "Sister-ground faces".

## Decode

CompileHelper::importPackage (third_party/Surelog/src/DesignCompile/CompileHelper.cpp) runs while the module is compiled. Two things follow from that order:
- It runs **before** UhdmWriter writes the typedef listings. UhdmWriter renames the shared typedef object to `a::t` and re-homes it at its last lister.
- Its "Regular parameter" loop clone_tree's every param_assign of the imported package. So the module's copy of b's `PB` holds a clone of every hop of PB's chain **as it was at compile time**: bare-named (`t`), Instanced at the elaborated home package of the typedef (a).

The home package's own parameter (`parameter t PA` in a) already reads that way in ours. Our copy of b's PB instead kept the pointer to the object b's listing later renamed.

The module's folds are getValue clones of the module's materialized param_assign Rhs (CompileExpression's component branch). So they hold the same chain, and golden names their alias reference by its chain (`work@top.t`, `work@top.PB.t`).

## Law

- **§ modImpCopyTdChainHomeTop473** (ParamEmit `modImpCopyTdChainHomeTop473`, design-final at the end of drainPaNameCopySrc38 after § importCopyTsInstByRole469; ExprEmit at the imported-parameter fold stamp; EmitHelpers.h `modCopyFold473`; `R11U473_MODCOPYTD_OFF`).
  - **Where it applies:** in every module, interface and program listing (both views, the elaborated tree recursively). The roles are:
    - an import copy's vpiParameter entry;
    - its param_assign Lhs and Rhs constant;
    - every per-reference fold ExprEmit minted for the module's reads (recorded with the parameter's package);
    - a continuous assignment's fold (the whole right side or an operation operand, any depth);
    - a module variable's folded initializer.
  - **The shape:** the role's typespec has exactly two hops. The alias target is named `<H>::<x>` and is Instanced at a package other than H (an importer's listing object). The first hop is named `<x>`. H is a package other than the copy's own vpiImported package.
  - **The write:** the role is re-pointed at a fresh clone of the first hop and of the alias target. Both are Instanced at H's elaborated package, the alias target is named `<x>`, and the new alias reference reads the role reference's chain (`<role>.<x>`).
  - **What it leaves alone:** shared objects are never edited. A reference another owner holds is split.
  - **Where it abstains:** an alias target that is the home's own typedef. A **qualified** `parameter a::t PB` has no alias in golden at all (MC/mc09, byte-identical).

## Grid (evidence/grid_law6.txt; drivers/runcase.sh; every exit code 0 on both binaries)

22 case dirs in cases/MC (16) and cases/PO (6), every case naming § modImpCopyTdChainHomeTop473 in its first line.
Columns: uhdm-cmp lines and strict verdict, pristine -> law6, and the golden line overlap (drivers/overlap.py: the sum over golden's dump lines of min(golden count, ours count)).

| case | shape | pristine | law6 | overlap |
|---|---|---|---|---|
| MC/mc01 | wildcard import of b, `assign y = PB` | 112 NOT_EQUAL | STRICT_EQUAL | 669 -> 870 of 872 |
| MC/mc02 | explicit `import b::PB` | 112 | STRICT_EQUAL | 665 -> 866 |
| MC/mc03 | b imports `a::t` explicitly | 112 | 506, head later (module typedef listing, see residues) | 621 -> 792 |
| MC/mc04 | localparam read in always_comb | 112 | STRICT_EQUAL | 629 -> 800 |
| MC/mc05 | two importing modules, one instantiates the other | 112 | STRICT_EQUAL | 1029 -> 1370 |
| MC/mc06 | the module imports a and b, `PA ^ PB` | 112 | 86, head later (golden keeps the operation) | 1719 -> 1946 |
| MC/mc07 | CONTROL an enum typedef | STRICT_EQUAL | byte-identical | 619 = 619 |
| MC/mc08 | a typedef of a typedef | 17 | 17, closer | 524 -> 538 |
| MC/mc09 | CONTROL `parameter a::t PB` written qualified | 17 | byte-identical | 567 = 567 |
| MC/mc10 | an interface imports b | 112 | STRICT_NOTEQUAL fullname (the elaborated interface fold's reference `work@ifc` where golden names `work@top.u`; ModuleEmit) | 593 -> 763 |
| MC/mc11 | bit typedef, P2 = P1 + 1 | 84 | 84, closer (head at b's own P1, the package-own face) | 870 -> 1308 |
| MC/mc12 | b imported through `$unit` | 112 | STRICT_EQUAL | 954 -> 1374 |
| MC/mc13 | a variable initializer | 112 | STRICT_EQUAL | 544 -> 717 |
| MC/mc14 | an operation operand | 112 | STRICT_EQUAL | 825 -> 1024 |
| MC/mc15 | CONTROL the home's own parameter | STRICT_NOTEQUAL fullname | byte-identical | 785 = 785 |
| MC/mc16 | a port actual and an override | 112 | 64, head later (the fold of the port actual, size 4 in golden and 64 in ours) | 1063 -> 1262 |
| PO/po01 to po06 | CONTROLS: no module imports b (the package-own face) | | byte-identical, all six | |

The pass-469 and pass-471 residues of this family (each in the away census below):
- r11u469 IR/ir08 112 -> STRICT_EQUAL and IA/ia04 112 -> STRICT_EQUAL;
- v11u471 VT/vt04 192 -> STRICT_EQUAL;
- r11u471 EX/ex07 112 -> 64, v11u469 VT/vt14 112 -> 64 and VM/vm01 64 -> 64. All three now head at face 2.
- v11u469 VT/vt08 and v11u471 VI/vi06 are closer at the same counts.

Switches (evidence/switch_check.txt): `R11U473_OFF=1` and `R11U473_MODCOPYTD_OFF=1` each give pristine's bytes and exit code on 22 of 22 dirs.

Away census (evidence/away_census_law6.txt; drivers/away.sh), over the 394 fence-filtered case dirs of r11u453, r11u465, r11u467, r11u469, r11u471 and their verifier twins:
- no exit code moves;
- 8 dirs move bytes, every one closer by golden line overlap and none away;
- 3 reach STRICT_EQUAL (IA/ia04, IR/ir08, v11u471 VT/vt04).

## Prediction (written before the sweep; evidence/prediction/PREDICTION.txt)

- **The law's exact predicate** (evidence/tools/pred473.cpp) was run on pristine databases over the 7481 fence-filtered databases of the master's control /tmp/intr11u471 (probe 4087, surelog 954, uhdm2rtlil 1606, downstream 804, sv-tests kept 29).
  - It fires on none of them. The mc01 positive control fires 8 roles.
  - One abstention is recorded: probe r11u111repro/grid/f1/a09_imp_explicit. Its alias target is the home's own typedef, and it is byte-identical on law6 by a direct run.
- **A traced law6 runner census** (`R11U473_TRACE`; drivers/svc_run.sh) over the 562 sv-tests candidate rows: every row using import, export or the uvm tag (pass 471's list).
  - It wrote no trace file.
  - Every row keeps its golden status: 511 EQUAL, 6 DIFFERENT, 21 BOTH_REJECT, 10 SURELOG_ONLY, 6 SLANG_ONLY, 7 SURELOG_CRASH, 1 TIMEOUT.
- **Predicted:** no byte mover and no exit-code mover in any stage, no sv-tests status change, and no trace firing.

## Gates (one five-stage sweep on law6)

Workdir /tmp/r11u473_sw, with `R11U473_TRACE` on and `SLANG_UHDM=/tmp/r11u473_bin/law6`.
- The four corpus stages ran from the worktree and exited 0.
- The sv-tests stage ran through the main tree's tests/sweep.sh, because the worktree's UVM folder is empty. It exited 1 only because the main tree's law index reads stale; its comparison reads 0/0/0.
- The sweep was launched after drivers/r11u473_quiet.py read no sweep or runner live (the sister r11u468's sv-tests sweep had finished).
- Logs are in evidence/sweep/.

| stage | result | csv vs the master's control /tmp/intr11u471 |
|---|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63 of 4087, regressions=0 conversions=0 changes=0 | identical |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 | equal except the two LowMem log-path texts |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 | identical |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 of 871 | identical |
| svtests | EQUAL 1932, STRICT_NOTEQUAL 0, DIFFERENT 8, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SLANG_CRASH 0, SURELOG_CRASH 8, TIMEOUT 1 of 2346; 0/0/0 | identical |

**No sv-tests row converts**, and no row changes.

- **byteverify** (SELFCHECK=1, law workdir against the control; evidence/byteverify/corpora.txt):
  - surelog 0 of 962, uhdm2rtlil 0 of 1608 and downstream 0 of 805;
  - the self-checks flag 961, 1607 and 804.
  - **This is exactly the predicted zero.**
- **probe:** all 4087 databases are SAME as the control by path-normalized dump (drivers/r11u473_pdump.sh; evidence/byteverify/probe_pdump.txt). The negative control (two different databases) reads DIFF.
- **sv-tests kept databases** (evidence/byteverify/svtests_kept.txt): all 29 differ from the control in raw bytes, and all 29 read STRICT_EQUAL to the control under `uhdm-strictcmp --no-canon`. This is the serialization-order variance.
- **trace:** no firing on any sweep database (0 trace files), as predicted.
- **Determinism:** no corpus database moves, so the recorded hashes stand.
- **Canaries:** ok=52 and ok=16. ctcan2 PASS for surelog (EXPECT_UNKNOWN=1) and for uhdm2rtlil (EXPECT_UNKNOWN=6) (evidence/sweep/canaries.txt).
- **Binary audit** (fence-filtered; evidence/sweep/binary_audit.txt):
  - surelog: 1523 of 1573 records name law6, and the other 50 hold only a Surelog line;
  - uhdm2rtlil: 1740 of 1740;
  - sv-tests: 2346 of 2346.
- **Downstream cases** (evidence/downstream_cases.txt): MC/mc01, mc04, mc05, mc12, mc13, mc14 (6 gates), mc16 (2 gates), IR/ir08 and IA/ia04 read IDENTICAL on both binaries. MC/mc06 reads EQUIVALENT on both (its operation face, which the law does not touch).

## Goal 1 (re-measured on the base)
- **SURELOG_ONLY rows:** all 75 SURELOG_ONLY rows of results/golden_svtests.csv carry an upstream slang `error:`, none the exporter's unsupported message. No BOTH_REJECT (303) or SLANG_CRASH (0) row carries that message either.
- **The probe faces on law6:**

  | face | case | ours | upstream slang |
  |---|---|---|---|
  | C::mk().arr[1] | v11u413 VC/vc04 | 4 | 0 |
  | u.mk(x).a[2] | v11u413 VI/vi06 | 4 | 0 |
  | this.mk().inner.s | v11u415 VT/vt03 | 0 | 0 |

  Surelog rejects all three with a syntax error (passes 417 to 471), so golden has no shape for them. They are not forced.
- **Black-parrot:** bp_unicore was run alone through the runner on law6, on a quiet machine, with the guard of § macroVecLitTokenText403 on.
  - Surelog crashes (rc -11).
  - Ours exits 3 in 14.9 s at 835 MB maximum child RSS.
  - The guard stays, and the six rows stay SURELOG_CRASH.
- **rsd:** generated/rsd/rsd.sv stays SURELOG_CRASH, because Surelog dies first.

## Residues (ranked; all wrong on pristine too, none moved away)
1. **Face 2.** The elaborated module copy's Rhs of a package parameter defined by another parameter or by an expression is not respelled to the INT form.
   - Golden reads `INT:33` / `33` for `PC = PA` and `INT:34` for `PD = PA + 6'd1`. Ours reads `DEC:33` / `6'd33` and `UINT:34`.
   - This is the next head on r11u471 EX/ex07 and v11u469 VT/vt14 and VM/vm01 (64 lines each; scratch cases in evidence/scratch_faces.txt).
   - The elaborated respell of § impCopyBasedDecKeep (ParamEmit) runs before the name copy sets the value.
   - The `UINT:34` half is the evaluator's encoding of a typed operation, the same as golden's package top view (`PTOP a:: PD INT:34`).
2. **Face 3.** The elaborated variable-initializer fold of an imported, typed parameter.
   - Golden's fold typespec is Instanced at the elaborated package, and a qualified `b::LB` initializer carries no typespec in golden.
   - The writer is ModuleEmit's variable-initializer branch (r11u471 PI/pi04, pi06, r11u469 IA/ia10). See "Sister-ground faces".
3. **A module's typedef listing.** When the imported package imports the typedef explicitly (`import a::t;`, MC/mc03), golden lists `a::t` in the module's typedef listing and ours lists nothing (now mc03's head, 506 lines; ModuleEmit).
4. **The package-own face.** A package's own parameter of a typedef it imports has its first hop Instanced at the typedef's home in golden and at the package in ours.
   - The DEF-view alias target is golden's importer listing object, and ours is the home's own typedef.
   - This is invisible to both judges on PO/po01 and po02.
   - It is the head on MC/mc11 (a bit typedef, b's own P1) and PO/po06 (two importers).
5. **Golden keeps the operation** `PA ^ PB` in the module's continuous assignment when the module imports both packages, where ours folds it (MC/mc06, 86 lines).
6. **A typedef of a typedef** as the imported type (MC/mc08, 17 lines, closer).
7. **The port-actual fold's size:** golden 4, ours 64 (MC/mc16, now its head).
8. The carried lists of passes 471 and earlier (tools/probe/r11u471repro README), and the 8 DIFFERENT sv-tests rows at the sister's heads; p733, p737 and tnoc await the user's decision.

## Sister-ground faces (reported, not written)
- **ModuleEmit's variable-initializer branch** (the `ExpressionKind::NamedValue` parameter branch that calls makeParamTs for `logic [N:0] v = P;`):
  - golden Instances the fold's typespec at the parameter's elaborated package (`Instance` null in ours);
  - golden writes no typespec for a qualified `b::LB` read;
  - golden keeps the parameter's own literal form (`8'hff` / HEX where `PA = LA` and `LA = 8'hff`, r11u469 IA/ia12; ours `UINT:255`).
- **ModuleEmit's elaborated interface fold:** the reference of an elaborated interface's continuous-assignment fold is named `work@ifc` where golden names the instance `work@top.u` (MC/mc10, STRICT_NOTEQUAL fullname).
- **ModuleEmit's typedef listing** of a module importing a package that imports a typedef explicitly (MC/mc03).
- **Repaired from this ground.** The elaborated continuous-assignment folds (ModuleEmit's pendingParamCloneTs drain) and the variable initializers are minted on the sister's ground. This pass repairs their typespec chain design-final from ParamEmit, as pass 467 repaired UhdmExporter's copies. If the sister writes the chain at its own sites, the law abstains there, because the alias target is then no longer the importer's listing object.

## Process
- **Budget:**
  - One pristine build, equal to the main tree's binary, for case runs only.
  - law1 to law6 for case runs.
  - One traced runner census of the 562 sv-tests candidates on law6, for the prediction.
  - One full five-stage sweep on law6, and one byteverify against the master's control.
  - One bp_unicore run.
  - No pristine sweep.
- **Launches:** the census and the sweep were launched after the quiet check read no sweep or runner live. The sister r11u468's sv-tests sweep was live during the case runs and the away census, and both waited it out.
- **Fence:** the fence list was read into a file by a program and never printed. Every tree-wide list (control databases, case dirs, cmds.txt records) was filtered on it before any file was opened. No fenced test was named, opened or run.
- No other agent's process was touched.
- **Slips, none affecting a measurement:**
  - The first predicate run printed nothing, so its file-count line was added and the run repeated with the positive control in the list.
  - The first away-census summary keyed dirs by their short group name, so twins in two repros collided. It was recounted per path: 394 dirs.
