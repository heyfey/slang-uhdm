# r11u190: second adversarial verification of passes 180 and 181 (verifier; measurement plus two refinements in fix.patch)

Base `8e3153a2` (branch matrix-1.87). Pass 180 (the module/type ground: ten laws of r11u180 and v11u180's three
refinements) landed at `a3a62624`; pass 181 (the expression/parameter ground: fifteen laws of r11u181 and r11v181's
four refinements) landed at `1eeff71d`. On top of them sit the r11u183 decode (`459b7cdf`, tools only), the
verification r11u185 (`2b97649e`, § genericAfterTypedIfacePortTyped185v), pass 184 (`44393367`, nine expression
laws and two refinements in the same files as pass 181) and map 10 (`8e3153a2`, tools only). Worktree
`/tmp/wt_r11u190` (system-deps configuration, `-j 2`); scratch `/tmp/r11u190_*`.

This directory is the deliverable, with one tool change: `tools/uhdm-strictcmp/uhdm-strictcmp.cpp` gains a
display line (section 4, proved with a case; verdicts unchanged). Nothing under `src/`, `scripts/`, `results/`,
`tests/` or `third_party/` is edited. The two refinements are [fix.patch](fix.patch), a `git diff 8e3153a2 -- src`
(`src/ModuleEmit.cpp`, `src/ExprEmit.cpp`) that applies clean on a fresh `8e3153a2`; it is NOT applied here.

The brief speaks of "the canonicalisation patch you were given". No such patch was handed to this pass; the
comparator edit here is this pass's own, a reporting defect proved in section 4.

The cases name their laws in their first line (`// § law`), so `tests/LAWS.md` reads STALE in every sweep here.
A clean `8e3153a2` checkout reads STALE too (`python3 scripts/law_index.py --check` in a fresh worktree at the base:
`law index STALE`); it is the only red of every sweep below.

The slang-fenced tests are named nowhere in this directory (word-boundary scan of this directory and of
r11u180repro, v11u180repro, r11u181repro, r11v181repro: 0 files each; the positive control finds a planted name).
[drivers/env.sh](drivers/env.sh) reads `$FENCED` from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`
and refuses to run without four names; every driver here that reads corpus sources or databases sources it and
skips the four names by word boundary. No gdb was used. Only the gate sweeps dispatched fenced rows.

## Verdict

**Two breaks, both refined in [fix.patch](fix.patch); every other law of the two landings holds on 72 fresh cases
in both views; the landings compose additively; every CHANGE line of both integrations is an unmasking or a strict
improvement; the downstream lanes are byte-identical to golden's on every converted row.**

- **B1, § enumImportParentLastWriter180 (and its header branch `R11U180_ENUMIMPHDR_OFF`) counts an import of an
  enum LITERAL as a writer of the enum typedef.** `import p::C1;` in a module body (E/e05) or `module zlit import
  p::C2; (...)` in a header (E/e10), with the alphabetically last name, wins the drain. Golden's parent is the only
  typedef importer `work@amod` and the base ref reads `work@amod.p::e_t`; the law writes `work@zlit.p::e_t`.
  Pristine (the law off) is STRICT_EQUAL (148 / 147 objects); the law is `STRICT_NOTEQUAL fullname(7)` in both
  views. Decode: `CompileHelper::importPackage` (third_party/Surelog/src/DesignCompile/CompileHelper.cpp 127-170)
  copies a package DataTypeMap entry into the importer only when its key equals the imported item
  (`if (type.first != object_name) continue;`), and writeDataTypes walks that map; a literal names no typedef
  (the enum listing it gets is `writeImportedSymbols`'s clone, the pre-existing comment above the importer loop in
  ModuleEmit.cpp). **Fix § enumImpNamedItemWrites190v** (`R11V190_ENUMITEM_OFF`): an explicit import records a
  write only for the typedef it names (module body, module header, interface branch). E/e05 and E/e10 go to
  STRICT_EQUAL in both views (E/e10's bytes are the pristine bytes); E/e09, e11, e13 (stage 1 on every binary, a
  pre-existing interface listing face) get golden's enum parent (`work@aif`, `work@aif`, `work@ylit`).
- **B2, § lvIdxReadNestedKeepsLvalue181v gives a CALL ARGUMENT inside the read path the nested-path (lvalue)
  form.** In `m.w[n.w[f(o.w[k].v)].v].v = 2` (LC/c03 line 10) and in `f(o.w[k].v) + 1`, `$clog2(o.w[k].v)`,
  `f(o.w[p.w[k].v].v)` (LC/c04 lines 9, 10, 12), golden compiles the argument path as an ordinary read: `o` on its
  own token (10:15-16), bit_select `o.w[k]` on the member token (10:17-18), the index named through the outer read
  path (`work@top.m.w[].v.w.n.w[].v.k`). § lvIdxMixedPathIsRead181 alone gives exactly that; the refinement moves
  it to `o` 10:17-18, `...o.w[k].v.w` 10:17-21 (fieldscore FAWAY: 12 field cells on c03, 11-12 on c04 per view).
  On LC/c04 line 12 the landing as a whole also moves the inner `p.w[k].v` (nested in the argument path's own
  index) away from the pristine reading (golden and pristine `p` 12:21-22 on the member token, the landing 12:19-20;
  44-48 field cells against `R11U181_OFF`). Decode: `CompileHelper::compileTfCallArguments`
  (CompileHelper.cpp 4456, `compileExpression` per argument, 4491-4517) compiles each argument afresh, outside the
  enclosing select's context. **Fix § nestRdIdxOnly190v** (`R11V190_NESTIDX_OFF`): the refinement fires only for a
  path whose parent is a select, directly or through operations (§ lvIdxPathIsRead154's gate
  `lvIdxParent154`). LC/c03 and LC/c04 go to STRICT_EQUAL in both views; the operation index (c04 line 11) and a
  path in the argument path's own index (line 12's `p`) keep the nested shape, as golden does.

`R11V190_OFF` drops both. Fix measurements (section 3): 14 case-modes move (the seven cases above, both views), every
one toward golden (0 golden dump lines lost against law.bin); the fix sweep reads 0/0/0 in every stage with csvs
equal to HEAD's; byteverify 6 of 2560 corpus movers, all the coins of section 7; 0 of 4087 probe databases; 0 of 805
downstream slang-lane databases; the boundary byte control over 10370 landed `tools/probe` cases reads 0 movers.

**No other law of the two landings moves a field away from golden on fresh legal SV.** 72 cases, 144 case-modes:

- crashes: none (rc 0 everywhere, NW/n01 rc 4 "unsupported constructs" with a database, identical in every state);
- strict equality: ALLOFF (both landings off) -> ON goes 8 -> 27 (default) and 8 -> 27 (`--elabuhdm`); the only
  cells losing it are B1's four; with the fix, 31 and 31;
- uhdm-cmp: no cell's stage 1 appears or disappears except toward golden; the six `cmp:UP` cells of
  § rootPathFullNameByChain181 print the SAME head object longer (its computed full name), and R/r03's head moves
  from the fixed port typespec to a later generate-scope face (an unmasking);
- aligned walks: FAWAY only on B2's cells (fieldscore over every aligned cell);
- the flagged stage-1 and MIXED cells (RT/r01, r03, r04, T/t01, X/x02, G/g01) are wrong-to-wrong readings or
  multiset artifacts, read object by object in section 2.

**Composition: additive; no pair of laws cancels another's error** (section 5): status level CANCEL 0 in all three
stages, byte level CANCEL 0 over 6647 databases; the historical states reproduce the committed counts exactly; pass
181 moves the same 26 probe rows and 15 corpus rows with pass 184 off and on, except `r10buvm21repro/g21c`, pass
184's own claimed conversion, which needs both.

## 1. Binaries and states (frozen `chmod 555` in `/tmp/r11u190_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `law.bin` | `948f24885e7b03e37e1451b8c8152303` | worktree build of `8e3153a2` = the main tree's `build/slang-uhdm` (`948f24885e7b`) |
| `fix.bin` | `f3f16e56d7df2666e46b0f84b98bfda0` | `8e3153a2` + [fix.patch](fix.patch) (`be61646203dfa20a09def2d4f8ad8698`) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `uhdm-strictcmp-fix` | `fa6e4f42f252ae0ab69d9845003e71c5` | + the display line of section 4 |
| `predict190` | built by [drivers/cc190.sh](drivers/cc190.sh) | [drivers/predict190.cpp](drivers/predict190.cpp), this pass's fix predictor |
| `predict180`, `predict181`, `predict181v` | built by cc190.sh from the committed `r11u180repro`, `r11u181repro`, `r11v181repro` sources | the passes' own predictors (section 9) |

State wrappers ([drivers/mkstate.sh](drivers/mkstate.sh)), all law.bin under switches:

| wrapper | switches | the state |
|---|---|---|
| `alloff.sh` | `R11U180_OFF R11V180_OFF R11U181_OFF R11V181_OFF` | both landings off |
| `off180.sh` / `off181.sh` | `R11U180_OFF R11V180_OFF` / `R11U181_OFF R11V181_OFF` | one landing off |
| `off184.sh` / `off184x181.sh` | `R11U184_OFF R11V184_OFF` / + `R11U181_OFF R11V181_OFF` | pass 181 measured with pass 184 off |
| `wide.sh` | alloff + `R11U175_OFF R11U176_OFF R11V176_TDKEYUNRES_OFF R11U178_OFF R11V178_OFF R11U184_OFF R11V184_OFF R11V185_OFF` | the brief's composition list off (there is no `R11V176_OFF`; `R11V176_TDKEYUNRES_OFF` is its one refinement) |
| `wideon.sh` | the same list without the two landings | the two landings on that base |
| `s804.sh` | alloff + 184 + 185 off | `804e3b75`, pass 180's pristine base |
| `s1eef.sh` | 180 + 184 + 185 off | `1eeff71d`, pass 181 landed |
| `sa3a.sh` | 184 + 185 off | `a3a62624`, pass 180 landed |
| `s80a.sh` | s804 + `R11U175_FSPAN_OFF R11U176_OFF R11V176_TDKEYUNRES_OFF` | `80a1c2af`, pass 181's pristine base |

## 2. Sweeps (`tests/sweep.sh --jobs 3`, [drivers/sweep.sh](drivers/sweep.sh), [drivers/queue.sh](drivers/queue.sh); `/tmp/r11u190_sw?`, same-length names)

Every sweep's 3273 corpus `slang:` lines name its own binary or wrapper
([evidence/sweeps_cmds_audit.txt](evidence/sweeps_cmds_audit.txt)); summaries in [evidence/sweeps/](evidence/sweeps).
Every golden came from the cache.

| sweep | state | probe EQUAL | surelog d+t CMP_EQUAL | u2r d / t | gate vs results/ |
|---|---|---|---|---|---|
| swH | law.bin, all four stages | 2898 (`probe.csv` byte-identical to `results/golden_probe.csv`) | 456 + 452 | 787 / 787 | **0/0/0** in every stage; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0, csv byte-identical to `results/downstream_uhdm2rtlil.csv` |
| swA | alloff, all four stages | 2882 | 453 + 449 | 786 / 786 | downstream csv byte-identical to swH's |
| sw0 / sw1 | off180 / off181 | 2889 / 2891 | 455+451 / 454+450 | 786 / 787 | - |
| sw4 / sw5 | off184 / off184x181 | 2895 / 2889 | 456+452 / 454+450 | 784 / 784 | - |
| swW / swO | wide / wideon | 2796 / 2811 | 450+446 / 453+449 | 783 / 784 | - |
| sw8 / swP / swE / swT | s80a / s804 / s1eef / sa3a | 2814 / 2880 / 2886 / 2895 | 450+447 / 453+449 / 455+451 / 456+452 | 783 / 783 / 783 / 784 | - |
| swF | fix.bin, all four stages | 2898 | 456 + 452 | 787 / 787 | **0/0/0**; probe.csv, uhdm2rtlil.csv and downstream.csv byte-identical to swH's; surelog.csv differs only in the two LowMem log-path texts |
| swS | law.bin with `STRICT_CMP=uhdm-strictcmp-fix` | 2898 | 456 + 452 | 787 / 787 | csvs identical to swH's (the comparator edit is display-only) |

The reconstructed states reproduce the committed histories exactly: s80a 2814 and 450 + 447 (pass 181's pristine
figures), s804 2880 and 453 + 449 (pass 180's pristine, v11u180's `EQUAL 2880`), s1eef 2886 and 455 + 451
(r11u185's HEAD at `459b7cdf`), sa3a 2895 and 456 + 452 (pass 180's integration: +9 probe, PackedArrayHighConn d/t,
mem_read_reg d/t), HEAD 2898 and u2r 787 (pass 184's +3 probe and +6 row-modes); wide gives 2796, pass 178's
pristine figure ([evidence/composition/state_counts.txt](evidence/composition/state_counts.txt)).

Canaries ([evidence/fix/canaries_H_F.txt](evidence/fix/canaries_H_F.txt)): `r11u107repro/canaries.sh` surelog
ok=52 changed=0, uhdm2rtlil ok=16 changed=0 on swH and swF; `EXPECT_UNKNOWN=1 ctcan2.sh` (surelog) and
`EXPECT_UNKNOWN=6 ctcan2.sh` (uhdm2rtlil) PASS on both.

## 3. The fresh cases, per law ([cases/](cases), [evidence/grid/](evidence/grid))

72 cases in 17 groups, none in the grids of r11u180repro, v11u180repro, r11u181repro or r11v181repro; the first
line names the laws each attacks. [drivers/case.sh](drivers/case.sh) builds the golden with the pinned Surelog
(check_probe's arguments; `EL=1` adds `-elabuhdm` / `--elabuhdm`; a `files` list names several root files).
[drivers/grid.py](drivers/grid.py) runs each case in both views under ON, each named law's own switches (a
refinement also under its parent's), each landing off, every pair of named laws (group X), ALLOFF and WIDE, and
reads UNFIRED / TOWARD / AWAY / MIXED / UNMASK / BYTES-ONLY / STAGE1-x; [drivers/fieldscore.py](drivers/fieldscore.py)
(per walk index field sets), [drivers/recaway2.py](drivers/recaway2.py) (chain-keyed records) and
[drivers/dumpaway2.py](drivers/dumpaway2.py) (reachable-dump line multisets, fields neither comparator reads) judge
every cell. Tables: [law_readings.txt](evidence/grid/law_readings.txt), [lawtable.txt](evidence/grid/lawtable.txt),
[summary_default.txt](evidence/grid/summary_default.txt), [summary_elabuhdm.txt](evidence/grid/summary_elabuhdm.txt).

| group | cases | shapes (the brief's list) |
|---|---|---|
| E | e01-e13 | a package enum imported by three modules in two files (e01); a program and an interface only (e02); one header with the import included into two module bodies (e03); wildcard and explicit import of the enum in one module (e04); **a literal-only import (e05, B1)**; the winning importer casting to the enum (e06); the winner parameterized, twice in a generate loop, both views (e07); two enums explicitly imported by different modules (e08); two interfaces, one importing another typedef (e09); **a header literal import (e10, B1)**; an interface literal import (e11); literal + wildcard in the winner (e12); literals by two late modules, one also importing the typedef (e13) |
| T | t01-t08 | a default that is a package typedef of a class (t01); a chain of three type parameters, the formal on the last (t02); a specialization overriding the default beside the default one (t03); a static method formal, static property and return (t04); a package-qualified parameterized default with a named override (t05); a positional override of two type parameters (t06); a class-local typedef of the parameter, associative and dynamic elements (t07); a nested class and an out-of-body method (t08) |
| G | g01-g06 | **the break shape of v11u180 with BOTH header modules writing, plus a third module's own typedef at the same line and column in its own file (g01)**; a package function and a module function taking the same imported struct (g02); the formal writer in an included file (g03); a union with a nested struct and an enum (g04); a non-ANSI port and a task formal (g05); a package union moved by a task output formal, two importers and an override (g06) |
| I | i01-i04 | two packages imported in reverse name order (i01, pass 180's residue 1); an explicit and a wildcard import of one package (i02); a local typedef shadowing the imported one (i03); typedefs used only in a function and a modport, the interface a port (i04) |
| R | r01-r04 | integer, time, real and byte redeclarations (r01); shortint, longint, int unsigned and a signed port redeclared int (r02); the module in a generate loop and a generate if (r03); part-select and bit-select writes, an input redeclared integer (r04) |
| W | w01, w02 | § tfArgAggSwitchSplit180: a package struct taken by a class method and a module's qualified formal; a package union by a class task output and a package function |
| RT | r01-r05 | `$root` reads with two dimensions, a part select, a call index, an indexed part select (r01); a `$root` child net as a continuous-assignment target (r02); selects in a class method and generate-scope reads (r03); function-like macros taking the selects (r04); port actuals of instances in generate-for and generate-if scopes through two instance levels (r05) |
| PX | p01, p02 | nested parentheses, a parenthesized call and system call, parenthesized part-select bounds (p01); a continuous assignment, a generate-loop assignment, a function return (p02) |
| ID | i01-i03 | pre and post forms with unary and call indices in a module function (i01); a member path through two selects, this and super paths in a class task (i02); a nested begin in always_ff and a for step in a package function (i03) |
| IV | i01, i02 | two and three unbound items, an unbound item in a nested block (i01); the second of two in a task, an unbound right side (i02) |
| US | u01-u04 | 1_000_000 and 1_0 in parameter defaults, a range bound, a 67-bit decimal (u01); a sized decimal, a negative, a comparison, a replication count (u02); case items and an enum value (u03, the sister face); real and time literals with separators (u04) |
| DW | d01-d03 | a macro condition with trailing comments and inside written parentheses (d01); the parameterized class with the local-declaring do-while from an include (d02); nested do-whiles with call conditions, one through a macro (d03) |
| LV | l01-l03 | a static method (l01); a method of a parameterized class specialized in a module (l02); a package class method called from a module (l03) |
| LC | c01-c04 | a member call as a procedural lvalue index (c01); calls with arguments as part-select bounds, an indexed base, a bit index (c02); **a call two levels down in a nested lvalue index path (c03, B2)**; **call and system-call arguments inside the read path, an operation control, a path in an argument path's index (c04, B2)** |
| NW | n01, n02 | `new[n * 2]` and `new[n](...)` on dynamic-array elements (n01; our rc 4, a class property type we do not support, identical in every state); a queue element in a module task, a two-dimensional element with a call index (n02) |
| X | x01-x07 | the brief's cross-ground pairs: package enums read through `$root` (x01); an aggregate formal typedef in doubly nested lvalue indices (x02); integer-redeclared ports under part selects with call bounds (x03); interface typedefs in a macro do-while condition of an interface task (x04); a class method assigning through a type-parameter-typed array (x05); pass 181's and pass 184's inc/dec laws on the same operands (x06, x07) |
| D | d01 | the determinism reproduction of section 7 |

Per law, both views, each against its own switch (fired cells: TOWARD / STAGE1-CLOSER unless noted):

| law | cases | cells (fired) | reading | downstream (ON vs OWN) | verdict |
|---|---|---|---|---|---|
| § enumImportParentLastWriter180 | 14 | 28 (12) | TOWARD 6, STAGE1-SAME 2, **AWAY 4 (E/e05, e10)** | same | **BREAK B1** (fixed) |
| header branch (`ENUMIMPHDR`) | 1 | 2 (2) | **AWAY 2 (E/e10)** | same | **BREAK B1** (fixed) |
| § enumImpDefOwner180v | 8 | 16 (2) | BYTES-ONLY 2 (parent only) | same | holds; its invariant is incomplete (residue N1) |
| § classTpDefaultTsAtUse180 | 9 | 18 (16) | TOWARD 8, CLOSER 5, SAME 1, STAGE1-AWAY 2 (T/t01: multiset, wrong to wrong, N4) | same | holds |
| § classTpFormalMovesTs180 | 7 | 14 (12) | TOWARD 6, CLOSER 6 | same | holds |
| § classTpChainRootShares180 | 1 | 2 (2) | TOWARD 2 (T/t02 converts) | same | holds |
| § classTpQualDefaultSpan180 | 1 | 2 (0) | unfired on `other::par_c#(.W(8))` (stage 1 on every binary) | same | holds (not exercised beyond the landed grids) |
| § modAggTfArgCloneFollows180 | 6 | 12 (8) | TOWARD 4, CLOSER 3, BYTES-ONLY 1 | same | holds |
| § modAggCloneOwnDefOnly180v | 1 | 2 (2) | AWAY / STAGE1-AWAY against the law alone; = pristine | same | holds against pristine; over-declines when both modules write (residue N2) |
| § modAggCloneTakesFile180v | 2 | 4 (2) | TOWARD 1, SAME 1 | same | holds |
| § pkgAggTfArgCloneFollows180 | 2 | 4 (4) | TOWARD 3, CLOSER 1 | same | holds |
| § ifaceWildcardTdNameOrder180 | 5 | 10 (10) | TOWARD 2, UNMASK 2, SAME 6 | same | holds |
| § splitPortIntRedeclLogicTs180 | 5 | 10 (10) | CLOSER 10 (R/r02, r04, X/x03 to STRICT_EQUAL) | **DIVERGENT -> IDENTICAL 2, EQUIVALENT -> IDENTICAL 1, STATUS_DIFF -> IDENTICAL 1** | holds; a `real` redeclaration is not covered (residue N5) |
| § tfArgAggSwitchSplit180 | 2 + 41 landed | 392 switch cells | byte-identical with every pass-176 switch on or `CLSMETHOD`/`DEFTOPSPLIT` off; under `R11U176_QUALFORMAL_OFF` alone the split keeps the struct face (CM/c08 STRICT_EQUAL vs coupled `line`, c18 `fullname` vs `line`, G/g02 `type` vs `line`) ([aggswitch_matrix.txt](evidence/grid/aggswitch_matrix.txt)) | - | holds |
| § rootPathFullNameByChain181 | 6 | 12 (12) | TOWARD 6, STAGE1-AWAY 6 (multiset: the computed full name prints one more dump line; section 2.1) | same | holds |
| § rootPathElemOwnName181 | 5 | 10 (2) | TOWARD 2 (RT/r05) | same | holds |
| § rootNetPathOwnNames181 | 5 | 10 (6) | TOWARD 4, CLOSER 2 | same | holds |
| § bitSelParenIdxSpan181 | 2 | 4 (4) | TOWARD 2, CLOSER 2 | **EQUIVALENT -> IDENTICAL 2** | holds |
| § incDecBitSelWholeSpan181 | 5 | 10 (8) | TOWARD 2, CLOSER 4, SAME 2 | same | holds |
| § invalidStmtAnchorSyntax181 | 2 | 4 (4) | TOWARD 4 (IV/i02 STRICT_EQUAL) | same | holds |
| § bareDecUnderscoreDropped181 | 4 | 8 (8) | CLOSER 8 (US/u02 STRICT_EQUAL) | **DIVERGENT -> IDENTICAL 1** | holds; US/u04 (real and time literals beside `#1_0`, `1_2`) STRICT_EQUAL with the law, stage 1 without |
| § bigDecUnderscoreDropped181v | 1 | 2 (2) | SAME 2 (the 67-bit value; stage 1 on the range-bound face) | same | holds |
| § doWhileSyntaxFromCond181 | 2 | 4 (2) | TOWARD 2 (the include form) | same | holds |
| § doWhileMacroCondEnd181 | 3 | 6 (6) | TOWARD 6 (DW/d01, X/x04 STRICT_EQUAL) | same | holds |
| § incDecMixedPathIsLvalue181 | 5 | 10 (4) | CLOSER 4 | same | holds |
| § classMethodLvIsProcess181 | 6 | 12 (6) | TOWARD 2, CLOSER 4 | same | holds |
| § lvSelIdxChainName181 | 5 | 10 (6) | TOWARD 2, CLOSER 4 | same | holds |
| § procLvIdxCallWholeSpan181 | 4 | 8 (4) | TOWARD 2, CLOSER 2 | **EQUIVALENT -> IDENTICAL 1** | holds |
| § procLvPartSelBoundCallName181v | 2 | 4 (4) | TOWARD 4 | **DIVERGENT -> IDENTICAL 1, EQUIVALENT -> IDENTICAL 1** | holds |
| § newLhsBitSelAtIndex181 | 3 | 6 (4) | TOWARD 2, CLOSER 2 | same | holds |
| § lvIdxMixedPathIsRead181 | 3 | 6 (6) | MIXED 6: wrong to wrong on X/x02; on LC/c04 line 12 part of B2 | EQUIVALENT -> IDENTICAL 1 | holds but for B2's composite (fixed) |
| § lvIdxReadNestedKeepsLvalue181v | 3 | 6 (6) | **MIXED with FAWAY on LC/c03, c04** | EQUIVALENT -> IDENTICAL 1 | **BREAK B2** (fixed) |
| § lvIdxReadCallNameSpan181v | 2 | 4 (2) | TOWARD 2 | EQUIVALENT -> IDENTICAL 1 | holds |

### 3.1 The flagged cells that are not breaks (object by object)

- **RT/r01, r03, r04 (§ rootPathFullNameByChain181, STAGE1-AWAY)**: stage 1 in every state on a pre-existing face:
  golden names a `$root` READ path without its selects (`hier_path $root.top.mem`, full name
  `work@top.$root.top.mem`), ours keeps them (`$root.top.mem[1][0]`). The law clears our stored full name, so the
  dump prints the computed `work@top.$root.top.mem[1][0]` (one more line); no golden line is lost
  (dumpaway2 lost=0), the uhdm-cmp head is the same object.
- **T/t01 (§ classTpDefaultTsAtUse180)**: a default written as a package TYPEDEF of a class. Golden binds every use
  to the typedef's own `class_typespec pkg::base_t` at 6:11-17; pristine writes `base_c` / anonymous objects at the
  uses, the law `base_t` at the default tokens 7:28-34. Wrong to wrong (residue N4).
- **X/x02 (§ lvIdxReadNestedKeepsLvalue181v / § lvIdxMixedPathIsRead181, MIXED)**: the member index `IX.k` of the
  level-2 path; the ref `k`'s full name is wrong in every state (pristine `work@top.m.w[].v.n.w[].v.o.w[].v.k`, law
  `work@top.m.w[].v.o.w[].v.k`, golden none); every other record of the case moves toward golden (16 -> 2).
- **G/g01 (§ modAggCloneOwnDefOnly180v)**: against the law without the refinement it is AWAY, against pristine it
  is equal (residue N2).
- **LC/c04 and r11v181's lx/x03 dump lines** (`vpiParent` of an operation constant): residue N8, pre-existing in
  every rvalue path.

## 4. The comparator display defect (tools/uhdm-strictcmp/uhdm-strictcmp.cpp)

In mode 4 a full name inside a typespec copy prints as its in-copy rewrite (`<in>p::e_t`), while the comparison
also reads the raw full names (use-site test). When the rewrites agree and the raw names differ, the record printed
the same text on both lines: E/e05 `#13 fullname  A: <in>p::e_t  B: <in>p::e_t`, MiniAmiq's first record `#770`
`<in>uvm_reg_byte_en_t` on both sides, Rggen's pristine head `#111`. The head could not be read from the
comparator. The edit prints the raw names on a line of its own after such a record:

    raw fullname A: work@amod.p::e_t | B: work@zlit.p::e_t                         (E/e05, B1's head)
    raw fullname A: uvm_pkg::uvm_pkg::uvm_reg_bus_op::byte_en::uvm_reg_byte_en_t | B: uvm_reg_byte_en_t   (MiniAmiq #770)
    raw fullname A: work@rggen_register_common.rggen_rtl_pkg::rggen_polarity | B: work@rggen.rggen_rtl_pkg::rggen_polarity   (Rggen #111 at s1eef)

Verdicts, the `fields:` line, the record lines and the `--dump-a/-b` files are unchanged; the harness calls the
comparator with `--max 0` and never prints records. Measured: the sweep swS with `STRICT_CMP=uhdm-strictcmp-fix`
writes `probe.csv` and `uhdm2rtlil.csv` byte-identical to swH's and `surelog.csv` equal but the LowMem log paths.

## 5. Composition ([evidence/composition/](evidence/composition))

**Status level** ([compose_H_A_0_1.txt](evidence/composition/compose_H_A_0_1.txt): H = swH, A = swA, 0 = off180,
1 = off181; the 1588 surelog rows are 1596 minus the 8 fenced, skipped unread):

| stage | conversions A -> H | owner | changes A -> H | CANCEL |
|---|---|---|---|---|
| probe | 16 | OWN180 9 (exactly pass 180's claimed nine), OWN181 7 (pass 181's six + `r10buvm21repro/g21c`, pass 184's claimed conversion, which needs pass 181) | OWN180 5, OWN181 18, JOINT 1 (`r10uvm55repro/a1` line(20) -> line(13)) | 0 |
| surelog | 6 | OWN180 PackedArrayHighConn d/t; OWN181 CovMacro d/t, YosysRiscv d/t | OWN180 5 (ArrayMethodIterator d/t, Earlgrey_0_1 d/t, Rggen d), OWN181 11 (the UVM rows and SVSwitch) | 0 |
| uhdm2rtlil | 2 | OWN180 mem_read_reg d/t | OWN180 4 (const_cast_signext d/t, struct_param_func_config d/t) | 0 |

**Byte level** ([bytecancel_H_A_0_1.txt](evidence/composition/bytecancel_H_A_0_1.txt), 6647 databases): SAME 6522,
OWN180 26, OWN181 86, BOTH 13 (the UVM rows, Earlgrey d/t, `r10uvm55repro/a1`, `r10v160repro/x11_class`), **CANCEL 0**.

**Record level** ([joint_share.txt](evidence/composition/joint_share.txt), [drivers/joint.py](drivers/joint.py)):
`a1`: pass 180 removes 5 records, pass 181 2, overlap 0, introduced 0 (22 -> 15); `x11_class` 1 + 1; SVSwitch 0 + 1;
Earlgrey_0_1 d 0 + 8 (pass 180's move there is a relocation: its record multiset is unchanged, the walk aligns
later); no record is cancelled.

**Pass 181 with pass 184 off and on** ([p181_with_without_184.txt](evidence/composition/p181_with_without_184.txt)):
the 181 delta on the 184-on base (swH vs off181) and on the 184-off base (off184 vs off184x181) names the same 26
probe rows (25 with the same (from, to) pair) and the same 15 corpus rows; the one probe difference is `g21c`
(col(9) -> EQUAL with 184, col(11) -> col(2) without), pass 184's conversion that needs pass 181. The 9 UVM rows
move by exactly one record on both bases (fullname(n) -> fullname(n-1); the absolute counts differ by pass 184's
own two). Bytes: 99 movers on both bases, the same 99.

**The wide base** (swW -> swO, everything of the brief's list off, the two landings on): probe 2796 -> 2811,
surelog 450+446 -> 453+449, u2r 783 -> 784.

**Cross-ground pairs** (group X, each pair off together; [grid_default.txt](evidence/grid/grid_default.txt)):

| case | pair | reading |
|---|---|---|
| X/x01 | § enumImportParentLastWriter180 × § rootPathElemOwnName181 / § rootPathFullNameByChain181 (package enums read through `$root`) | STRICT_EQUAL with everything on; each law TOWARD alone, the pair the sum (11 + 4 = 15 records); ROOTELEM unfired there (RT/r05 fires it) |
| X/x02 | § modAggTfArgCloneFollows180 × § lvIdxReadNestedKeepsLvalue181v | 180 TOWARD 2; 181v MIXED wrong to wrong (3.1); additive |
| X/x03 | § splitPortIntRedeclLogicTs180 × § procLvPartSelBoundCallName181v | STRICT_EQUAL; each alone closer (dump 20 / 8 records), the pair 36-44 lines off; downstream DIVERGENT -> IDENTICAL |
| X/x04 | § ifaceWildcardTdNameOrder180 × § doWhileMacroCondEnd181 | STRICT_EQUAL; each TOWARD, additive |
| X/x05 | § classTpDefaultTsAtUse180 × § classMethodLvIsProcess181 × § newLhsBitSelAtIndex181 | STRICT_EQUAL; LVCLASS unfired (the path is the element itself), TPUSE and NEWLHS TOWARD, additive |
| X/x06, x07 | § incDecMixedPathIsLvalue181 × § incDecMemberSelIsLvalue184 × § incDecSelTopRestore184v × § incDecBitSelWholeSpan181 | stage 1 in every state (the operand-list face); x06 fires only INCDECMIX, x07 fires INCDECSEL184 and INCDECBS; every pair CLOSER with 0 new golden-disagreeing lines, the pairs additive (x07: 64 / 32 lines off alone, 68 together, 28 on) |

## 6. The CHANGE lines ([evidence/changes/](evidence/changes), [drivers/unmask.py](drivers/unmask.py), [unmaskpos.py](drivers/unmaskpos.py), [unmaskposrow.py](drivers/unmaskposrow.py), [lostrec.py](drivers/lostrec.py))

**Pass 180 at `a3a62624` (swE -> swT)**, [unmask_180_swE_to_swT.txt](evidence/changes/unmask_180_swE_to_swT.txt):

- probe: CONVERSION 9, SUBSET 4 (`a1` line(18) -> line(13), `a3_scope` 2 -> 1, `g90_a2_shapes` 11 -> 9, `v158_i`
  name(4) -> name(3)), UNMASK 2: `i1_ifkinds` type(1) -> endcol(2), off diverged at #236 (`enum_typespec pk::e_t`
  against our `struct_typespec pk::st_t`, the interface typedef order), the new records at #347 and #590 (logic_typespec
  end columns); `x10_iface_import_shadow` type(1) -> fullname(2), off diverged at #67, new records at #207, #208
  (`type_parameter TP` full name `work@ifc.TP` against `work@dut.u.TP`). All new records at or after the off
  divergence ([unmaskpos_180.txt](evidence/changes/unmaskpos_180.txt)).
- surelog: CONVERSION 2 (PackedArrayHighConn d/t), SUBSET 4: ArrayMethodIterator d/t name(6)/name(16) -> endcol(1);
  **Earlgrey_0_1 d/t fullname(436) -> col(102): every one of the 102 records is among the 436** (SUBSET); **Rggen d
  fullname(7) -> endcol(634): UNMASK** ([unmaskposrow_180_rggen.txt](evidence/changes/unmaskposrow_180_rggen.txt)):
  the off walk's first record is `#111 fullname` (ref_typespec base-ref full name, raw golden
  `work@rggen_register_common.rggen_rtl_pkg::rggen_polarity`, ours `work@rggen.…`, the enum last-writer face the law
  fixes) and it diverges at #469; the on walk's first record is `#2063 endcol` (`array_typespec`,
  rggen_apb_adapter.sv 18:3-48 golden, 18:3-49 ours) and it diverges at #23166; every new record sits after #469
  ([rggen_first_records_E_T.txt](evidence/changes/rggen_first_records_E_T.txt)).
- uhdm2rtlil: CONVERSION 2 (mem_read_reg d/t), SUBSET 4: const_cast_signext d/t line(5) -> type(1) (the sister's
  constant-call fold), struct_param_func_config d/t line(8) -> fullname(5).

**Pass 181 at `1eeff71d` (swP -> swE)**, [unmask_181_swP_to_swE.txt](evidence/changes/unmask_181_swP_to_swE.txt):
probe CONVERSION 6 + SUBSET 20 (every one of the 20 changes loses records, none gains); surelog CONVERSION 4
(CovMacro d/t, YosysRiscv d/t) + SUBSET 11. **Each of the 11 corpus changes loses exactly one record and gains
none** ([lostrec_181_swP_to_swE.txt](evidence/changes/lostrec_181_swP_to_swE.txt)): SVSwitch d/t `#264 col
bit_select rcvr` Environemnt.sv 43:11-12 (ours 43:6-13); SimpleUVM d/t, Scoreboard d, SeqDriver d/t, MiniAmiq d/t the
`bit_select uvm_random_seed_table_lookup` uvm_misc.svh 409:34-41; BuildUVMPkg d/t the same statement in the flat
uvm_pkg.sv 8678:34-41: the new-array element bit_select of § newLhsBitSelAtIndex181.

## 7. Downstream ([evidence/downstream/](evidence/downstream))

- **Converted rows**, through the harness's own `one()` ([drivers/dsrow.py](drivers/dsrow.py),
  [surelog_rows_ON_ALLOFF_FIX.txt](evidence/downstream/surelog_rows_ON_ALLOFF_FIX.txt)): PackedArrayHighConn
  IDENTICAL (NO_GATES), YosysRiscv IDENTICAL (OK, 528 gates); the slang lane's three netlists have golden's lane md5
  in ON, ALLOFF and FIX. CovMacro reads SURELOG_FAIL in every state (uhdm2rtlil's Surelog with the downstream flags
  writes no reference for it; the row is a simulation construct). mem_read_reg (a gate row): `mem_read_reg,IDENTICAL,OK,OK,1789,1789,,`
  in swH and swA; `_nohier.il` / `.il` / `_synth.v` md5 2c3c7f556e / 74db87b322 / 3c024840a2 in golden's lane, swH's
  and swA's slang lanes although the slang database moves; const_cast_signext and struct_param_func_config likewise
  ([u2r_rows_netlists_H_A.txt](evidence/downstream/u2r_rows_netlists_H_A.txt)).
- **The four r11u182 integer-redeclared port cases** (r11u180repro R/r01, r02, r04, r06):
  IDENTICAL with the laws on, DIVERGENT with both landings off and with `R11U180_PORTINTREDECL_OFF` alone
  ([r11u182_intport_cases.txt](evidence/downstream/r11u182_intport_cases.txt)).
- **This pass's 73 cases** (ON, ALLOFF, OWN, FIX; [cases_ON_ALLOFF_OWN_FIX.txt](evidence/downstream/cases_ON_ALLOFF_OWN_FIX.txt)):
  ON 65 IDENTICAL, 6 EQUIVALENT, 1 DIVERGENT, 1 STATUS_DIFF. ALLOFF -> ON: 5 EQUIVALENT -> IDENTICAL (LC/c02,
  PX/p01, PX/p02, R/r03, NW/n02), 3 DIVERGENT -> IDENTICAL (R/r02, US/u02, X/x03), 1 STATUS_DIFF -> IDENTICAL (R/r04).
  No case leaves IDENTICAL; the fix moves no verdict. The non-identical verdicts are the same in every state:
  R/r01 DIVERGENT (the `real` port, N5), US/u01 STATUS_DIFF (N6), I/i03, ID/i03, RT/r01, US/u03, X/x06, X/x07
  EQUIVALENT.
- The full downstream gate: swH, swA and swF `downstream.csv` byte-identical to `results/downstream_uhdm2rtlil.csv`
  (803 / 66 / 2 / 0); the fix moves 0 of 805 slang-lane databases.
- **UVM file facets, order-blind** ([uvmdist_H_A.txt](evidence/uvm/uvmdist_H_A.txt), `all_file_away` = (type, name,
  file) triples ours holds more often than golden; both landings off -> HEAD): MiniAmiq 3539 -> 3464 (distance
  10078 -> 9848), SeqDriver 3335 -> 3259 (8217 -> 7974), SimpleUVM 1710 -> 1634 (3318 -> 3104), Scoreboard d 1412 ->
  1336 (2643 -> 2444), BuildUVMPkg 437 -> 368 (1789 -> 1607); `method_func_call` file facets 15 on both sides (0 on
  BuildUVMPkg). First records at HEAD ([first_records_H.txt](evidence/uvm/first_records_H.txt)): MiniAmiq #770
  (`uvm_reg_byte_en_t` reference full name, golden `uvm_pkg::uvm_pkg::uvm_reg_bus_op::byte_en::uvm_reg_byte_en_t`,
  ours bare; N0164), #899 `uvm_severity` file, #1694 `uvm_bitstream_t` file; SeqDriver #753 / #765 the same N0164
  face; SimpleUVM #458 / #470 and Scoreboard `UVM_MACRO_NUMFLAGS` references (N0682); BuildUVMPkg #1135.

## 8. Determinism ([evidence/determinism/](evidence/determinism), [drivers/det.sh](drivers/det.sh), [drivers/ob.sh](drivers/ob.sh))

Three concurrent runs per binary per row-mode with the sweep's recorded command line and cwd, for law.bin (L),
fix.bin (F), alloff.sh (A), and law.bin with slang's parse on ONE thread (`-j 1`, J); each against its sweep's
database. Order-blind = sorted uhdm-dump lines, database path normalised.

| row-mode | L + F + sweep: distinct hashes | order-blind lines per pair | strict cell (every variant) | `-j 1` (J, 3 runs) |
|---|---|---|---|---|
| Earlgrey_0_1 d | 2 (L 3x one, F 2+1, the same two) | 0 | `col`, objects 2173209 vs 2173853 | **1 hash 3/3** |
| Earlgrey_0_1 t | 2 (the same two in L and F) | 0 | `col`, 1342584 vs 1342870 | **1 hash 3/3** |
| MiniAmiq d / t | 6 / 7 | 4 (one pair d: 0) | `fullname(6)`, 435559 vs 428712 | 3 hashes (still varies) |
| SeqDriver d / t | 6 / 7 | 4 | `fullname(5)`, 475526 vs 471999 / 475538 vs 472011 | 3 hashes (still varies) |
| SimpleUVM d / t | 2 / 1 | 4 / - | `fullname(21)` | d: 3 hashes; t: 1 |
| Scoreboard d | 2 | 0 | `fullname(21)` | **1 hash 3/3** |
| BuildUVMPkg d / t | 1 / 1 | - | `fullname(21)` | not run |

With both landings off (A, [ob_A.txt](evidence/determinism/r11u190_ob_A.txt)) the same pattern: Earlgrey d and t
two-valued and order-only (`16c8…`/`5ba6…`, `155e…`/`8314…`, strict `fullname(436)` in both), MiniAmiq / SeqDriver /
SimpleUVM d the 4-line value coin, Scoreboard d order-only: no coin depends on the landings. Every variant reads uhdm-cmp 0 lines and the same strict cell and object counts; no strict
verdict or object count is ever affected.

**Attribution.**

- **Earlgrey_0_1** (both modes): the two outcomes differ only in the place of one `logic_typespec spi_byte_t`
  (spi_device_pkg.sv 22:11-22) in the weakly-referenced tail (its 6 dump lines move: 12 diff lines, 0
  order-blind). The copies are
  minted by `bareScalarTypedefVarTs` (TypeEmit.cpp) inside `for (auto& kv : s.AllObjects())` (TypeEmit.cpp 13988,
  14077), and `Serializer::AllObjects()` is a `std::map<const BaseClass*, uint32_t>` (uhdm/Serializer.h 87): the
  creation order follows heap addresses. With slang's parse on one thread the heap layout is stable and the row is
  byte-deterministic (3/3 in both modes); only the parallel parse varies the layout. So pass 180's resume evidence
  (`r11u180repro/evidence/earlgrey_coin.txt`) holds: our own address-keyed iteration, exposed by slang's parallel
  parse. **r11u186 has not landed** (the main tree's HEAD is still `8e3153a2` at the time of this report), so no
  determinism law can be measured.
- **The UVM 4-line coin** (MiniAmiq, SeqDriver, SimpleUVM d): one constant, the right bound of
  `array_typespec types_t` (uvm-1.2 uvm_misc.svh 642, `typedef TYPE types_t[$];` in `uvm_utils #(TYPE)`), in the
  weakly-referenced tail: `UINT:<n>` / `vpiDecompile:<n>` with n = 0, 644, 811, 918, 1099, 1238, 1494 in this pass's runs
  ([types_t_right_bound_values.txt](evidence/determinism/types_t_right_bound_values.txt); golden: `STRING:$`,
  vpiConstType 10). The object is the return-type twin of `find_all`, built by TaskFuncEmit.cpp's
  unpacked-array typedef return branch (`buildUnpackedArrayTypedefTs(*retAlias, ...)`, TaskFuncEmit.cpp 4409),
  which casts the alias's canonical type with `ct.as<FixedSizeUnpackedArrayType>()` (TypeEmit.cpp 16429) although it
  is a `QueueType`. `FixedSizeUnpackedArrayType` holds `elementType` then `ConstantRange range`; `QueueType` holds
  `elementType` then `uint32_t maxBound` (slang ast/types/AllTypes.h 188-200, 273-281): `range.left` reads
  `maxBound` (0 for `[$]`, always 0 in every variant) and `range.right` reads the 4 padding bytes after it, arena
  garbage. **Neither slang's parallel parse nor our iteration order**: it varies with `-j 1` too. D/d01 reproduces
  the wrong shape (`UINT:0` / `UINT:0` where golden writes `STRING:$`) on a 13-line case, deterministically 0 in a
  small heap. Not judged by either comparator (the tail is unreachable from the design).
- **Scoreboard d** (order only, 0 lines): stable under `-j 1`, i.e. the known svunit_pkg `vpiTaskFunc` list order
  under slang's parallel parse (RESUME section 9).

## 9. Residues

### Re-measured at the base (`8e3153a2`, passes 184 and 185 on top)

| source | residue | at 8e3153a2 |
|---|---|---|
| pass 180, 1 | StructParamPatternInitCast d/t fullname(3) (S1) | **stands**: fullname(3) both modes; S/s01 fullname |
| pass 180, 2 | ArrayMethodIterator d/t endcol(1) (S2) | **stands** |
| pass 180, 3 | const_cast_signext d/t type(1) (S3) | **stands**; T/t11 and U/u03 `type` |
| v11u180, V1 | interface wildcard imports of two packages (I/i01) | **stands**: stage 1 on every binary; fresh I/i01 likewise |
| v11u180, V2 | an enum its importers cast to (e03-e07) | **stands, unjudged**: e03 and e05 STRICT_EQUAL in every state |
| v11u180, V3 | a package typedef moved to a formal inside an include (P/p08) | **stands**: file |
| pass 181, R1 | FuncStructValSimple d/t | **stands**: file(39)/file(59) (was file(40)/file(60)) |
| pass 181, R2 | streaming lvalue member paths (adv/a01) | **gone**: STRICT_EQUAL both views at HEAD (pass 184's § streamLvMemberPathRead184; fullname with both landings off) |
| pass 181, R3 | a call index inside an rvalue hier_path (vA_meth) | **stands**: endcol(9) |
| (pass 181, R4) | the lvalue `$root` endcol (rt/g05) | gone: STRICT_EQUAL (pass 184's § rootLvalueSpanAtRoot184) |
| r11v181, V1 | separators in an enum value / generate condition (us/d04) | **stands**: stage 1 |
| r11v181, V2 | a member path's parenthesized index (px/p05) | **gone**: STRICT_EQUAL (pass 184's § memberSelParenIdxSpan184) |
| r11v181, V3 | reads inside a read path nested in an lvalue index (lx/x03) | **stands**: col; its `k+1` constant also leaves its operation parent (N8) |

### New, found here (none is a break of the two landings but B1 and B2, which are fixed)

- **N1. § enumImpDefOwner180v's invariant is incomplete.** When the winning module is also the last one emitted,
  its elaborated instance wrote last and the refinement's exception ("a parent already of the winning definition is
  left") keeps that INSTANCE: `work@zmod (work@top.uz)` where golden has `work@zmod (work@zmod)` (E/e03, e04, e06,
  e07, e08, e12; both views; vpiParent only, identical on pristine). Parenting at the definition object whenever the
  current parent is an instance of the winning definition would close it (ModuleEmit.cpp, the ENUMDEF drain).
- **N2. § modAggCloneOwnDefOnly180v over-declines** when both definitions sharing one header typedef have a formal
  writer (G/g01): golden gives amod's clones 4:42-46 (14) and bmod's 10:42-46 (14); the refinement leaves 16 at the
  declaration td.svh 2:11-58 (= pristine), the law alone moves bmod's 8 to amod's span. A per-definition key would
  convert both.
- **N3.** The interface branch lists every package typedef for an explicit import (E/e09, e11 stage 1 on every
  binary); the fix corrects their enum parents only.
- **N4.** A type-parameter default written as a package typedef of a class (T/t01): golden binds the uses to the
  typedef's own `pkg::base_t` object; the law names them `base_t` at the default tokens.
- **N5.** A split port redeclared `real` (R/r01): golden keeps the port's `logic_typespec` (6:10) as for the integer
  types; ours `real_typespec` in every state; downstream DIVERGENT in every state.
- **N6.** US/u01 downstream STATUS_DIFF in every state: the plugin reading our database of
  `localparam logic [69:0] BIG = 100_000_000_000_000_000_000` stops with `Failed to parse integer constant:
  value='INT:100000000000000000000'` (the Surelog lane reads NO_GATES); not decoded further.
- **N7.** `$root` read paths with selects (RT/r01, r03, r04): golden names the path without its selects; stage 1 in
  every state. The generate-scope `$root` column (RT/r05 `col`) is pass 181's S2 (TypeEmit `emitSyntaxExpr`).
- **N8.** The constant operand of an operation inside a read path's select index has no vpiParent
  (`y = n.w[k + 1].v`, pristine and every state: 0 of 1 parented, golden 1); § lvIdxMixedPathIsRead181 builds the
  lvalue-nested path as that rvalue path and inherits it (LC/c04, r11v181 lx/x03: 2 dump lines per operation). A
  pre-existing rvalue face of the mixed-path builder, invisible to both comparators.
- **N9.** The queue-typedef return twin type confusion of section 8 (TaskFuncEmit.cpp 4409 -> TypeEmit.cpp 16429):
  undefined behaviour and the UVM value coin; a guard on `ct.kind` plus the `[0 : $]` shape of
  `memberWrittenQueueTs149` would close it.
- **N10.** `IX.k` as the index of a doubly nested lvalue path (X/x02): the ref's full name is wrong in every state.
- **N11.** § classTpQualDefaultSpan180 does not fire on `other::par_c#(.W(8))` (T/t05, stage 1 on every binary).

## 10. The fence and the process

**No law, case or number here rests on a fenced reading.** Every case is this directory's; every corpus reading is
a non-fenced row through a fail-closed driver or a gate sweep ([bvmirror.sh](drivers/bvmirror.sh)
`fenced_skipped=8`, [predict190.sh](drivers/predict190.sh) `fenced_excluded 8`, the prediction reruns below
`fenced_excluded 8`; det.sh, ob.sh, uvmdist.sh, unmask*.py, lostrec.py, joint.py, compose.py, bytecancel.py,
additive.py, dsrow.py refuse or skip fenced names).

**Four laws re-derived from this directory's cases and Surelog's source only** (the parameter and path laws
nearest the fenced tests' shapes):

- § rootPathFullNameByChain181: CompileExpression.cpp 5088-5115 (the `paDollar_root_keyword` branch): the hier_path
  gets `VpiParent` and `Path_elems`, each ref_obj its own name, the path no `VpiFullName`. Cases X/x01 (STRICT_EQUAL
  with the law, fullname without), RT/r02, RT/r05.
- § bareDecUnderscoreDropped181: CompileExpression.cpp 476 (`slIntConst`: `value.erase(std::remove(..., '_'))`
  before `VpiDecompile`) and 451 / 504 for the large and based forms. Cases US/u02 (STRICT_EQUAL, downstream
  DIVERGENT -> IDENTICAL), US/u04 (the bare `#1_0` and `1_2` beside real and time literals: STRICT_EQUAL).
- § modAggTfArgCloneFollows180 and § pkgAggTfArgCloneFollows180: `CompileHelper::compileTfPortList`
  (CompileStmt.cpp 1720; 1805-1809 `compileTypespec` then `populateCoreMembers(type, type, ts)` on the typedef's
  own object): the last formal's type token moves the shared object before any clone. Cases G/g02 (both writers),
  G/g03, G/g06; and the counter-case G/g01 (N2) where each module's object moves to its own formal.

**Drivers of the four evidence directories** (static reading):

- **r11u180repro**: every driver sources `/tmp/wt_r11u180/tools/probe/r11u180repro/drivers/env.sh`, which reads
  canaudit.sh's `FENCED=` line from that worktree with a four-name check. The worktree is pruned, so every driver now
  refuses (fail closed) and none can run from the tree. Corpus readers (attrib.sh, bvmirror.sh, predict180.sh,
  row.sh, uvmdist.sh) skip the names (attrib.sh and uvmdist.sh by exact name, the others by word boundary).
  **mktrace.py** (the gdb trace, used once on Earlgrey_0_1) and **parents.sh** (a dump reader taking any path) do
  not check the fence themselves; probefirst.sh and probemovers.sh read probe databases only; grid.sh,
  switches.sh, case.sh, dscase.sh, boundary.sh are case-scoped (case.sh, dscase.sh and boundary.sh refuse fenced
  paths).
- **v11u180repro**: env.sh reads canaudit.sh from `/tmp/wt_v11u180pris` (pruned; refuses now). enumpar.sh sources
  `/tmp/v11u180_scr/env.sh` and sw1.sh uses `/tmp/v11u180_cases` (scratch, gone: not runnable from the tree;
  case-only). attrib.sh (exact name), bvmirror.sh, uvmdist.sh skip the names; case.sh and dscase.sh refuse them.
- **r11u181repro**: env.sh resolves the repository root from its own path (r11v181's fix) and reads canaudit.sh,
  four-name check. **r11v181's claim holds**: no driver of r11u181repro names `/tmp/wt_r11u181` (grep: 0), and env.sh
  and obmovers.py carry the `(v11u181: ... from this file)` root resolution. predict181.sh, obrows.sh, rowrec.sh
  (`: "${FENCED:?}"` plus a count check) and bvmirror.sh are fail-closed with word-boundary skips; obmovers.py
  asserts four names. **offwrap.sh and tracewrap.sh** are binary shims for `verify_golden.py --filter`; they cannot
  refuse, and the fence is the dispatcher's filter (the README says it was checked against `$FENCED_RE`). The record
  readers anc.py, consts.py, dconsts.py, enter.py, recs.py take any file and do not check the fence;
  grid.sh, gridall.sh, offbytes.sh, switchmatrix.sh are case-scoped.
- **r11v181repro**: env.sh resolves the root from its own path, `exit 9` without four names. bvmirror.sh,
  predict181v.sh (grep -Pv `$FENCED_RE`), grid.sh and ds.sh are fail-closed. both.sh, three.sh and rec.sh call
  scratch copies `/tmp/v11u181_grid.sh` and `/tmp/v11u181_recmv.py`; ds.sh, sw.sh and sweepV.sh `cd` into pruned
  worktrees (`/tmp/wt_v11u181pris`, `/tmp/wt_v11u181`): not runnable from the tree (case-only or gate).
- A word-boundary scan of the four directories and of this one for the four names finds 0 files.

**The predictions were written before their sweeps, as far as the tree can show** ([evidence/process/](evidence/process)):

- **Pass 180**: the committed `predict180.cpp`, run over swP (the `804e3b75` state, probe EQUAL 2880 = pass 180's
  pristine), reproduces `r11u180repro/evidence/predict180_pristine.txt` **exactly: 6647 listed, 67 predicted, 0
  differing names**; the 22 corpus movers of `byteverify_G_vs_P.txt` and the 17 probe movers of
  `probe_movers_G_vs_P.txt` are all inside the 67. v11u180's "the same 67 names" therefore stands too.
- **Pass 181**: the committed `predict181.cpp`, run over sw8 (the `80a1c2af` state, 2814 = pass 181's pristine),
  reproduces `r11u181repro/evidence/predict_pristine.txt` **exactly: 197 predicted, 0 differing**; the 17 corpus
  movers of `byteverify_corpus_final.txt` and the 82 probe movers of `probe_movers.txt` are all inside.
- **r11v181**: `predict181v.cpp` names 0 of 6647 on swE (the `1eeff71d` state) and on swH; its positive control is
  its own grid (lx/x01-x03, lc/c02-c03, us/d06); this pass's `predict190` NESTIDX trigger (a narrowing of its NESTRD
  trigger) fires on LC/c03 and c04.
- Both predictions are functions of the pristine databases alone, so they could not have seen the law sweeps.

**This pass's own prediction** ([prediction_fix.txt](evidence/fix/prediction_fix.txt), written 2026-09-27 16:57:33
from swH's databases; the fix sweep started 16:57:41, [swF_start_time.txt](evidence/fix/swF_start_time.txt)):
predict190 names 9 of 6647 (ENUMITEM: Kmac d/t and 7 probe cases with an enum-literal import); positive control
E/e05, e10 (ENUMITEM), LC/c03, c04 (NESTIDX), negative E/e01, LC/c02, X/x02. Measured
([byteverify_F_vs_H.txt](evidence/fix/byteverify_F_vs_H.txt), mirrors `fenced_skipped=8`, PATH_SETS_IDENTICAL,
SELFCHECK 2559/2560): 6 of 2560 corpus movers, none predicted, all coins
([movers_orderblind_F_vs_H.txt](evidence/fix/movers_orderblind_F_vs_H.txt)): Earlgrey_0_1 d/t 12 dump lines, 0
order-blind (fix.bin's hashes are law.bin's two det variants); MiniAmiq d/t and SeqDriver d/t 4 order-blind lines,
the section 8 constant. The 9 predicted databases do not move (their winners are unchanged): the trigger
over-approximates. Probe 0 of 4087, downstream 0 of 805. Boundary ([drivers/boundary.sh](drivers/boundary.sh),
fix.bin vs law.bin over every single-file `tools/probe/**/dut.sv` outside this directory, fenced paths refused):
listed 10370, processed 10370, **10221 SAME, 0 MOVER**, 149 NODB (slang rejections and three segfaults, the same
on both binaries).

**Operations of this pass, disclosed:**

- The first grid launch ran before `case.sh` was executable (every cell a Python error); it was relaunched.
- A first judge run crashed on a record whose name field holds a macro text with a newline (RT/r04); recaway2.py
  now skips such lines.
- A `cp` of evidence ran from the session's cwd after a backgrounded `cd`; it failed without writing (the main
  tree was checked: nothing of this pass is in it) and was repeated with absolute paths.
- During this pass the main tree showed uncommitted edits in `src/ModuleEmit.cpp`, `src/TaskFuncEmit.cpp`,
  `src/TypeEmit.cpp`, `src/UhdmExporter.cpp` and `tests/LAWS.md` (an integration in progress, not this pass's);
  nothing here reads or depends on the main tree's files, and no process this pass did not start was touched.
- Up to three sweeps ran concurrently at `--jobs 3`; no build ran above `-j 2`; no OOM.

## 11. Files

- [fix.patch](fix.patch): § enumImpNamedItemWrites190v and § nestRdIdxOnly190v (`git diff 8e3153a2 -- src`).
- `cases/{D,DW,E,G,I,ID,IV,LC,LV,NW,PX,R,RT,T,US,W,X}/`: 72 cases; E/e01 and G/g01 carry a `files` list, E/e03,
  G/g01, G/g03 and DW/d02 include headers.
- `drivers/`: env.sh, laws.py, mkstate.sh, sweep.sh, queue.sh; case.sh, grid.py, gridall.sh, gridsum.py,
  lawtable.py; fieldscore.py, recaway2.py, dumpaway2.py, dd.sh, enumpar.sh; compose.py, bytecancel.py, joint.py,
  additive.py, unmask.py, unmaskpos.py, unmaskposrow.py, lostrec.py; dsrow.py, dscase.py; det.sh, ob.sh, coin.sh,
  uvmdist.sh, bvmirror.sh; predict190.cpp, predict190.sh, cc190.sh, fixcases.sh, boundary.sh, aggswitch.sh. Drivers
  copied from r11u185verify say so in their second line.
- `evidence/`: `grid/`, `fix/`, `composition/`, `changes/`, `downstream/`, `uvm/`, `determinism/`, `process/`,
  `sweeps/`, `sweeps_cmds_audit.txt`.
