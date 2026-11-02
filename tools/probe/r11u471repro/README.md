# r11u471 — enum clone instances, export items and imported-parameter folds (expression/parameter ground, pass 471)

Base 0f193bf8f (pass 469). Ground: src/ParamEmit.cpp, src/ExprEmit.cpp and src/EmitHelpers.h.
Laws read through src/LawSwitch.h: `lawOn(471, "R11U471_<LAW>_OFF")`. `R11U471_OFF=1` drops every law of the pass.
`R11U471_TRACE=<dir>` logs each firing through `lawTrace(471, ...)`. There is no src/R*.h, no getenv, no reader function and no header under include/ changed.

Binaries (frozen, chmod 555):
- pristine: `/tmp/r11u471_bin/pristine`, md5 914aca3fab82ab18ffce129b445c3537. The worktree's first build, equal to the main tree's build/slang-uhdm.
- law: `/tmp/r11u471_bin/law13`, md5 97f7694e0c9cbcba6a032d55e47e3d68, linking slang 12.0.0+545f88b2e.
- law1 to law12 were intermediate binaries, used only on case runs and on the traced census below.

## Item (a): no open row heads on this ground

The 9 DIFFERENT rows at the base all head on the sister's ground (pass 469's census, tools/probe/r11u469repro/evidence/census).
The traced runner census below reran 562 sv-tests rows on the law binary, the 9 among them. Every row keeps its golden status.
So the pass took the residue backlog of this ground, largest family first.
That backlog is pass 469's enum clone shared by several importers (VE/ve01, ve03, ve08, ve10), its re-export shapes (VE/ve04, VT/vt06),
and the module-level import copies behind them.

## Decode

1. **Enum clone shared by several importing packages** (v11u469 VE/ve01, ve03, ve08, ve10).
   - Our listing instances the shared enum import clone at the last importer (ve08: `b!DEF param PK enum_typespec@c!DEF`).
   - Golden instances every role of every importer at a view of the home `a`.
   - CompileHelper::importPackage clones the home's Parameters and each view's param_assigns per importer.
   - § importEnumCloneHomeInst469 fired only where the instance is the importer itself.
2. **Export items** (VE/ve03, ve04, VT/vt06).
   - The grammar writes `export a::*;` and `export a::N;` as a package_export_declaration holding package_import_item nodes.
   - CompilePackage::collectObjects_ walks the package body depth-first in source order. It calls importPackage on every paPackage_import_item.
   - So every export item copies the exported parameters again. In `import a::*; import a::PA; export a::PA;`, golden b lists PA three times in both of its vectors.
   - An importer of b lists PA once in its Parameters (b's getParameterMap(), one per name) and three times in its Param_assigns (b's getParamAssignVec()).
   - Ours saw only the two import members. `export *::*` holds no import item.
3. **A continuous assignment's fold of a typedef-typed imported parameter** (VM/vm02's family; scratch m1, m8).
   - Golden: the fold of `assign y = PA;` with `parameter t PA` imported from a package carries a per-reference clone of `logic_typespec (t)` with its alias, Instanced at the home.
   - This is the component branch of compileExpression: clone_tree of the materialized param_assign Rhs, which holds its own typespec reference.
   - Ours: no typespec. That copy's definition typespec is deferred past the typedef listing (ParamEmit's deferAggTs branch), so importedParamDefTs stays empty for it.
4. **The whole right side of a procedural assignment** (`always_comb y = PA;`, `s <= RST;`, `initial`, `final`, a module task).
   - The same component-branch clone, stamped with the parameter's declaration typespec.
   - Ours stamped only operands (procOpFold9), so a whole-side read was bare.
   - The reference names the owning instance's param_assign: `work@top` even under a named block, and the program definition `work@prg` in a program.
5. **A package's localparam initializer reading a wildcard- or explicitly-imported parameter unqualified** (`package b; import a::*; localparam int LB = PA + 1;`).
   - The importing package's param_assigns hold the materialized copy with vpiImported set, so the component branch (`paramFromPackage`) folds the read in b's definition listing.
   - An operand carries a reference named `b` to that copy's typespec, Instanced at a's definition view.
   - Ours kept the cross-package ref_obj `b::a::PA` bound to a's parameter.
   - The existing rule for a QUALIFIED `a::PA` read (no fold) stands.

## Laws

- **§ enumSharedCloneHomeInst471** (ParamEmit, in importCopyTsInstByRole469, design-final at the end of drainPaNameCopySrc38; `R11U471_ENUMSHAREDINST_OFF`).
  - An enum import clone (no alias) in an importing package's listing whose instance names a package that is neither the importer nor the home its qualified name names.
  - Each role is re-instanced by § importCopyTsInstByRole469's roles: the vpiParameter entry at the home's elaborated view, the param_assign's sides at the home's view matching the importer's view.
  - An unqualified name abstains.
- **§ pkgExportItemReImports471** (ParamEmit, pkgItems471 and the two package walks of collectImportedParams; `R11U471_EXPORTITEM_OFF`).
  - Each `export p::*` / `export p::N` item is one more import item at its source position.
  - It applies in the package's own listing and in every transitive walk of an importer: a wildcard export walks p again, and an explicit export of a parameter adds that parameter.
  - An export item after a parameter declaration is materialized ahead of the package's own parameters, as § pkgImpParamsAheadOfOwn453 orders an import member.
- **§ impTdParamCaFoldTs471** (ExprEmit at the imported-parameter fold stamp, EmitHelpers.h impTdParamHome471, ParamEmit's deferAggTs branch; `R11U471_TDIMPFOLDTS_OFF`).
  - A module's import copy of a package parameter typed by a typedef (deferAggTs) records its home package.
  - A per-reference fold (caFold9's set, plus the procedural whole side below) then mints the clone through makeParamTs, Instanced at the home: the elaborated view, or the definition view with the top fixup.
  - A fold that shares the definition object abstains.
- **§ procAsgRhsPkgFoldTs471** (ExprEmit; `R11U471_PROCASGTS_OFF`).
  - A fold parented directly at an assignment inside a module or program process, or a module task or function (an owning instance on the chain), takes the same per-reference stamp.
  - The reference is named after the owning instance, or after the program definition inside a program.
  - Interfaces, generate-scope processes, package and class subroutines are not reached.
  - A typedef-typed parameter needs both this law and § impTdParamCaFoldTs471 (the home record).
- **§ pkgInitImpReadFolds471** (ExprEmit's package-init reference branch and operand stamp, EmitHelpers.h pkgInitTs471, ParamEmit design-final binding; `R11U471_PKGINITFOLD_OFF`).
  - In a package's definition listing, an unqualified read of another package's parameter that the reading package imports directly (a wildcard import of the home, or an explicit import of the parameter) falls through to the fold.
  - An operand or system-call-argument fold takes a reference named after the reading package. It is bound design-final to that package's definition-listing copy's typespec, and dropped when no copy is found.

## Grid (evidence/grid_law13.txt; drivers/grid.sh; every exit code 0 on both binaries; every case accepted by upstream slang)

65 case dirs; 41 reach STRICT_EQUAL from NOT_EQUAL, 2 reach STRICT_NOTEQUAL from NOT_EQUAL.

| group | law | result |
|---|---|---|
| ES (7) | § enumSharedCloneHomeInst471 | es01 two importers, es02 three importers, es03 chain + direct importer, es04 diamond + module read, es07 importers with own enum parameters: NOT_EQUAL -> STRICT_EQUAL. es05 (explicit imports) 322 -> 292 lines, its head in b's listing an older face. es06 (one importer, pass 469's shape) byte-identical control. |
| EX (7) | § pkgExportItemReImports471 (+ § pkgInitImpReadFolds471 on ex02, ex03, ex07) | ex01, ex02, ex04, ex05, ex06 -> STRICT_EQUAL. ex03 (`export *::*`, control for the export law) -> STRICT_EQUAL through the package-init law alone. ex07 570 -> 112 lines, its head now module top's copy of the typedef parameter (the module-level import-copy face). |
| TF (12) | § impTdParamCaFoldTs471 | tf01 wildcard, tf02 explicit, tf03 enum, tf04 operand, tf10 `$unit` import -> STRICT_EQUAL. tf11 (two instances) -> STRICT_NOTEQUAL fullname: the alias reference is work@sub.t where golden names the last instance's work@top.u2.t. tf12 (signed, concatenation operand) moves its operand to golden's typespec, head unchanged at the package's -4'sd3 constant (older face). Byte-identical: tf05 struct (older face), tf06 int typedef (older fullname face), tf07 / tf09 qualified reads, tf08 plain vector. |
| PF (28) | § procAsgRhsPkgFoldTs471 | 17 -> STRICT_EQUAL: initial, always_ff with a named block, if/else, case, a module task, explicit import, `$unit` import, two instances, +=, final, enum, array elements, parentheses, an intra-assignment delay, three always_comb. pf18 (module function) -> STRICT_NOTEQUAL fullname (alias reference `t` where golden writes `work@top.t`). pf03 and pf15 (untyped parameter) 17 -> 22 lines: the fold is now golden's, and the head is the untyped import's older int_typespec face that pf17 (continuous assignment) shows on both binaries. pf22 (program): the fold constant is now golden's (`work@prg`); the head is the same program-listing face (1144 -> 1162 lines, because the printed listing holds the stamped constant). Byte-identical: pf04 generate process, pf05 interface, pf06 qualified, pf17, pf19 to pf21 (package function, class in module, class in package). |
| PI (11) | § pkgInitImpReadFolds471 | pi01 whole side, pi02 operand, pi03 typedef, pi05 parameter, pi08 explicit imports, pi09 `$clog2` argument and range, pi10 chain, pi11 untyped -> STRICT_EQUAL. pi04 50 -> 199 lines, head later at module top's copy of b's LB, the face the control pi06 shows on both binaries. Byte-identical: pi06 and pi07 (a qualified `a::PA` read). |

None moved away: every non-converting mover reaches golden's object at the law's site, and its first difference is later or older (the comparisons above).
Downstream (evidence/downstream_cases.txt): TF/tf01, tf04 (2 gates), tf10, PF/pf02, pf12, pf27, EX/ex04 and ES/es04 read IDENTICAL on both binaries.

The pass-469 residues are re-measured on law13 (evidence/residues469.txt):
- -> STRICT_EQUAL: VE/ve01, ve03, ve04, ve08, ve10, VT/vt06, VM/vm02.
- VM/vm01 50 -> 64 lines with its head later: b's definition-view `PB = PA + 6'd1` operand is now golden's (§ pkgInitImpReadFolds471), and the next head is the elaborated b's PB constant, INT:18 in golden and UINT:18 in ours on both binaries (an older signing face).
- VT/vt14 50 -> 112 lines with its head later, at module top's copy of the typedef parameter (the module-copy face).
- IR/ir08 and IA/ia12 are byte-identical, at their module-copy heads.

Switches (evidence/switch_check.txt, drivers/switch_check.sh):
- `R11U471_OFF=1` gives pristine's bytes and exit code on 65 of 65.
- Each law's own switch alone restores pristine on 5 (ENUMSHAREDINST), 3 (EXPORTITEM), 20 (TDIMPFOLDTS), 21 (PROCASGTS) and 10 (PKGINITFOLD) dirs.
- Every other mover needs two of the laws, by design:
  - the typedef-typed procedural folds need PROCASGTS with TDIMPFOLDTS's home record;
  - es04, ex02, ex05 and ex07 combine two laws.

## Prediction (written before the sweep; evidence/prediction)

The prediction was written from four sources:
- The predicates (evidence/tools/pred471.cpp, predpk.cpp) ran on pristine databases over the 7481 fence-filtered control databases of /tmp/intr11u469.
- A text census of export items ran over 19736 fence-filtered corpus and probe sources.
- A traced law13 runner pass ran over 562 sv-tests candidate rows: those using import, export or the uvm tag.

The predicted result:
- **No byte mover in probe, surelog, uhdm2rtlil or downstream.**
  - The predicates find no candidate there.
  - The two probe cases with export items (r10v194 v194_e_explclone, r10v179 v179_f_nomod) are byte-identical on law13.
  - The other export sources (kmac_pkg, Zachjs, Verilator) are compiled only by SLANG_REJECT or DEFERRED rows.
- **sv-tests: no status change.** Every one of the 562 rows keeps its golden status on law13.
- The trace fires on 15 rows (evidence/prediction/sv_trace_firing_rows.txt):
  - rsd (SURELOG_CRASH): § procAsgRhsPkgFoldTs471 and § pkgInitImpReadFolds471;
  - 14 uvm-examples rows: § enumSharedCloneHomeInst471.
- Kept databases moving bytes: rsd plus uvm_overriding, param_vif_config_db, slave_agent, slave_agent_multi_seq_item and pipelined_get_put.

## Gates (one five-stage sweep on law13)

Workdir /tmp/r11u471_sw, `R11U471_TRACE` on, `SLANG_UHDM=/tmp/r11u471_bin/law13`. The four corpus stages ran from the worktree (exit 0).
The sv-tests stage ran through the main tree's tests/sweep.sh, because the worktree's UVM folder is empty (exit 0). Logs are in evidence/sweep/.

| stage | result | csv vs the master's control /tmp/intr11u469 |
|---|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63 of 4087, regressions=0 conversions=0 changes=0 | identical |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 | equal except the two LowMem log-path texts |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 | identical |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 of 871 | identical |
| svtests | EQUAL 1931, STRICT_NOTEQUAL 0, DIFFERENT 9, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SLANG_CRASH 0, SURELOG_CRASH 8, TIMEOUT 1 of 2346; 0/0/0 | identical |

**No sv-tests row converts** and no row changes.

- **byteverify** (SELFCHECK=1, law workdir against the control; evidence/byteverify/corpora.txt): surelog 0 of 962, uhdm2rtlil 0 of 1608 and downstream 0 of 805. The self-checks flag 961, 1607 and 804. **Exactly the predicted zero.**
- **probe**: all 4087 databases are SAME as the control by path-normalized dump (drivers/r11u471_pdump.sh; evidence/byteverify/probe_pdump.txt). The negative control (two different databases) reads DIFF.
- **sv-tests kept databases** (evidence/byteverify/svtests_kept.txt): all 30 differ from the control in raw bytes.
  - 24 read STRICT_EQUAL under `uhdm-strictcmp --no-canon` (the serialization-order variance).
  - The other 6 are exactly the 6 predicted:
    - rsd (SURELOG_CRASH, no golden; NOT_EQUAL against the control by law);
    - overriding, param_vif_config_db, slave_agent, slave_agent_multi_seq_item and pipelined_get_put: STRICT_NOTEQUAL on depth under --no-canon because the clone identity changes, STRICT_EQUAL to the control under the canonical walk.
- **trace** (evidence/sweep/trace_firing_per_db.txt): fires on exactly the 15 sv-tests rows of the census, with the same per-row counts, and on one probe database.
  - The probe database is r10v179 v179_f_nomod, where § pkgExportItemReImports471 resolves `export pkg_uniform::*` and its bytes do not move. That package exports no parameter, and the case is SAME above.
  - No corpus database fires.
- **Determinism**: no corpus database moves, so the recorded hashes stand.
- **Canaries**: ok=52 and ok=16. ctcan2 PASS for surelog (EXPECT_UNKNOWN=1) and for uhdm2rtlil (EXPECT_UNKNOWN=6) (evidence/sweep/canaries.txt).
- **Binary audit** (fence-filtered; evidence/sweep/binary_audit.txt):
  - surelog: 1523 of 1573 records name law13; the other 50 hold only a Surelog line;
  - uhdm2rtlil: 1740 of 1740;
  - sv-tests: 2346 of 2346;
  - no record names any other slang-uhdm binary.

## Goal 1 (re-measured on the base)
- All 75 SURELOG_ONLY rows of results/golden_svtests.csv carry an upstream slang diagnostic (`error:`), none the exporter's unsupported message; no BOTH_REJECT or SLANG_CRASH row carries it either.
- The probe faces, on both binaries:

  | face | case | upstream slang | Surelog | ours |
  |---|---|---|---|---|
  | C::mk().arr[1] | v11u413 VC/vc04 | 0 | 3 | 4 |
  | u.mk(x).a[2] | v11u413 VI/vi06 | 0 | 3 | 4 |
  | this.mk().inner.s | v11u415 VT/vt03 | 0 | 3 | 0 |

  Surelog rejects all three with a syntax error, so golden has no shape to follow. They are not forced.
- Black-parrot: bp_unicore was run alone through the runner on law13, on a quiet machine, with the guard of § macroVecLitTokenText403 on (evidence/census/bp_unicore.txt).
  - Surelog crashes (rc -11). Ours exits 3 in 14.0 s at 833 MB maximum child RSS.
  - This is the same reading as passes 405 to 419. The guard stays, and the six rows stay SURELOG_CRASH.
- generated/rsd/rsd.sv stays SURELOG_CRASH; Surelog dies first.

## Residues (ranked; all wrong on pristine too, none moved away)
1. The module-level import copies:
   - a module's copy of an imported typedef or localparam parameter: ex07, pi04 / pi06, v11u469 VM/vm01, VT/vt14, r11u469 IR/ir08, IA/ia12;
   - its typespec Instance, and the 199-line face of a module variable initializer reading a package localparam. This is the next family on this ground.
2. The untyped import's int_typespec pairing (pf03, pf15, pf17: golden pairs the module param_assign's own int_typespec).
3. Alias-reference full names under the per-reference clone:
   - a module function (pf18: `t` against `work@top.t`);
   - two instances of the reading module (tf11: golden names the last instance).
4. Procedural folds not reached: a generate-scope process (pf04, 46 lines at an INT:9 elaborated constant), an interface process (pf05), a qualified read (pf06).
5. An explicit import shared by two packages (es05, 292 lines in b's listing); a struct-typed or int-typedef parameter fold (tf05, tf06); the signed package constant (tf12).
6. Easy UVM, the 3 uvm_scoreboard rows, use_models_pipelined_get_put and param_vif_config_db (the sister's heads); p733, p737 and tnoc (await the user's decision).
7. The carried lists of passes 469 and earlier.

## Sister-ground faces (reported, not written)
- ModuleEmit: a program instance's listing in the elaborated view (pf22's head; the constant this pass stamps is now golden's).
- ModuleEmit / UhdmExporter: the generate-scope and interface processes' fold sites (pf04, pf05). These are ExprEmit's stamps reached through the sister's emission contexts. Writing them needs the emitter's process flags (inGenScopeProc, the interface process loop) to reach this law.
- The heads of the 9 DIFFERENT rows, as pass 469 reported them.

## Process
- Budget:
  - One pristine build, equal to the main tree's binary. It served only case runs.
  - law1 to law13 were used on case runs only.
  - One traced runner census of 562 sv-tests candidate rows ran on law13 for the prediction: no comparison gate, no status read beyond the census check.
  - One full five-stage sweep on law13 and one byteverify against the master's control.
  - One bp_unicore run.
  - No pristine sweep of its own.
- Launches: every launch waited for drivers/r11u471_quiet.py to read no sweep or runner live. It excludes its own ancestors and the session shells.
  - The sweep's launcher waited out the sister v11u466's sv-tests and probe run before starting.
  - The launcher is named r11u471_launch.sh and does not match the sweep pattern.
- The fence list was read into a file by a program and never printed. Every tree-wide list (control databases, corpus sources, cmds.txt records, sweep logs) was filtered on it before any file was opened. No fenced test was named, opened or run.
- No other agent's process was touched.
- Slips, none affecting a measurement:
  - The first byte-audit command used a wrong regular expression, which counted law13 records as "other". It was rerun with the binary read from each record's slang line.
  - The first bp_unicore attempt called /usr/bin/time, which is absent, so nothing ran. It was rerun through a Python rusage wrapper.
