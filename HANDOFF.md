# HANDOFF — continuing the convergence campaign

For a fresh session picking up this project. Read this, then NOTES.md
(quirk catalog — the accumulated ground truth), then PLAN.md Part II
(campaign strategy). Everything below is verified as of 2026-07-17.

## Mission (unchanged)

1. Converge the 710-test uhdm2rtlil corpus: slang-uhdm output byte-identical
   to Surelog's (`uhdm-dump` diff empty + `uhdm-cmp` exit 0) for all 661
   achievable tests (710 − 44 SLANG_REJECT − 5 SURELOG_FAIL).
   Remaining phases: B2, C2, C3, D, E, F (details in PLAN.md Part II §2).
2. Then the Surelog repo suite (~703 dirs, PLAN.md Part II §3).
3. Then sv-tests (~2346 files, PLAN.md Part II §4).

## Current scoreboard (r14 baseline, committed as results/baseline.csv)

PASS 36 · CMP_ONLY 33 · DIFF 243 · UNSUPPORTED 349 · CRASH 0
· SLANG_REJECT 44 · SURELOG_FAIL 5
(PASS = dump+cmp identical; CMP_ONLY = cmp passes, only the unordered
weaklyReferenced dump tail differs — one ordering fix from PASS.)

## Environment (this machine)

- This repo: ~/git-repos/slang-uhdm  (history: extracted from the
  slang fork's uhdm-export branch, which remains frozen as an archive)
- Build: `~/.local/bin/cmake -B build -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_PREFIX_PATH=$HOME/.local && ~/.local/bin/cmake --build build -j 4`
  (system cmake is too old; slang + UHDM installed in ~/.local prefix)
- Binary: build/slang-uhdm
- Reference producer: ~/git-repos/Surelog/build/bin/surelog  (v1.86-114)
  invoke: surelog -parse -nobuiltin -nocache <files> → slpp_all/surelog.uhdm
- Oracles: ~/git-repos/UHDM/build/bin/{uhdm-dump,uhdm-cmp,uhdm-hier,uhdm-lint}
  (UHDM 5523dfc — NEVER update these checkouts mid-campaign)
- Corpus: ~/git-repos/uhdm2rtlil/test/*/dut.sv (710 tests)
- Slang sources for API reference: ~/git-repos/slang (branch uhdm-export)
- DO NOT USE: any binary under ~/git-repos/sv-tests/third_party or
  ~/git-repos/UHDM-1.84 (v1.84, schema-incompatible)

## The dev loop (verified, fast)

1. `./scripts/triage.sh results/latest.csv` → pick the top blocker.
2. Write a minimal probe dut.sv exercising it; run
   `./scripts/converge.sh probe.sv` and read the golden via
   `uhdm-dump <workdir>/slpp_all/surelog.uhdm` to learn Surelog's shape.
3. Implement in src/; rebuild (`cmake --build build -j 4`, ~30s);
   re-run converge.sh until DUMP_MATCH + PASS_CMP.
4. `./tests/check_goldens.sh` (must stay 5/5), then
   `./scripts/run_corpus.sh ~/git-repos/uhdm2rtlil/test results/rN.csv
   results/baseline.csv` (~50s, parallel; FAILS on regressions).
5. Commit per converged feature; append every new quirk to NOTES.md;
   promote 1-2 representative tests to tests/golden/ per feature;
   update results/baseline.csv when a round improves.

Methodology hard rules (learned the expensive way):
- DUMP_MATCH alone is NOT success — uhdm-cmp checks fields the dump never
  prints (Module_inst, typespec Instance). Require both.
- When cmp fails but dump matches, bisect with a C++ probe against the
  installed UHDM lib (pattern in NOTES.md "Session 1"; probe compiles with
  g++ -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj).
- Weakly-tail dump order = object CREATION order per type. Fix content
  first, ordering second.
- Match Surelog bug-for-bug; document every replicated quirk in NOTES.md.

## Task 0 for the new session: split UhdmExporter.cpp

src/UhdmExporter.cpp is ~3000 lines; split BEFORE phases D/E add more.
Pure code motion (keep the single UhdmExporter class; spread member
functions across TUs); verify with check_goldens + gated corpus round:

  src/EmitHelpers.h    file-local helpers as inline: netTypeFor, mapUnaryOp,
                       mapBinaryOp, firstDeclaratorLoc, ansiNetHeader,
                       collectDefs, findConnSyntax, connectionExpr,
                       containsOperation, joinPath
  src/UhdmExporter.cpp ctor, exportDesign, setLoc/setLocNamed, rawText,
                       fullFilePath, noteUnsupported
  src/ModuleEmit.cpp   emitModuleDef, emitInstance, emitPorts, emitContAssigns
  src/ParamEmit.cpp    emitParameters, patchParamTypespecs, makeParamTs,
                       analyzeParamEnc, emitPackage
  src/StmtEmit.cpp     emitProcess, emitStmt, emitEventExpr
  src/ExprEmit.cpp     emitExpr, tryFoldConst, isIntEncoded
  src/TypeEmit.cpp     makeTypespec, sharedTypespec, makeBoundConst, makeVar
Update CMakeLists.txt target sources accordingly. Commit as its own change.

## Then: feature phases (priority = live triage data, roughly)

1. Weakly-tail ordering polish → flips most of the 33 CMP_ONLY to PASS.
   Approach: pick each CMP_ONLY test, diff tails, adjust CREATION order
   (typespec/constant arena order rules are in NOTES.md).
2. C2 user functions/tasks (~100 tests blocked on "Call"): module
   Task_funcs vector + func_call/task_call; probe golden shapes first.
3. D1 enums + typedefs (incl. package typedefs — shapes partially decoded
   in NOTES.md: vpiTypedef list, named typespecs, UNFOLDED range exprs
   whose refs bind Actual→param-rhs constants).
4. E2 generate (gen_scope_array/gen_scope; genvars are most of the
   "ArbitrarySymbol" 46); B2 parameterized instances (STUDY golden shape
   of AdditionAsParameterInInstance first — known design unknown).
5. D2 member access / structs (70), C3 assertions (58), E1 hier_path (49),
   E4 interfaces (46, deepest — last).
6. F: --elabuhdm mode (run UHDM ElaboratorListener + UhdmAdjuster in-process
   like Surelog's -elabuhdm; needed for Stage 2 and sv-pathfinder).

## Stages 2-3 (after corpus is mostly green)

- Surelog suite: tests/<Name>/<Name>.sl holds raw surelog args; write
  scripts/run_surelog_suite.sh mapping them to slang-uhdm args. Many use
  -elabuhdm → needs F first. Tiering + goals in PLAN.md Part II §3.
- sv-tests: metadata-driven runner (:tags:/:should_fail:), agreement matrix.
  PLAN.md Part II §4.

## Flow closure (deferred by user, do LAST)

Build uhdm2rtlil, run its test_uhdm_workflow.sh with slang-produced .uhdm;
rebuild sv-pathfinder's native addon against UHDM v1.86 (binding.gyp
UHDM_HOME change + node-gyp rebuild).
