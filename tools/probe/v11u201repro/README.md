# v11u201 — adversarial verification of r11u201 (the expression/parameter ground): ACCEPT-WITH-FIX, three breaks refined (§ opCtxBindableTarget201v, § clsScopedBoundPlainClass201v, § newArrayKeepFrozenBare201v); every headline number of r11u201 reproduced bit for bit

**Base.** `ddc67d87` (matrix-1.87). Worktrees `/tmp/wt_v11u201pris` (pristine) and `/tmp/wt_v11u201` (r11u201's patch,
then the refinements), system-deps config, `-j 1` builds. Implementer's patch `/tmp/r11u201.patch` (md5
`82d642cf9d9d56777a7b81804c875294`). The verified patch `/tmp/r11u201.verified.patch` is r11u201's patch plus the three
refinements below (ground A only: `src/ExprEmit.cpp`, `src/EmitHelpers.h`), this directory and the regenerated
`tests/LAWS.md`.

**The fence.** `drivers/env.sh` reads the four names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` in
the main repository (through git's common dir) and every driver fails closed on it (`case.sh`, `obrow.sh`, `det.sh`,
`dscase.py` refuse a fenced name; `census.sh` runs the corpora and the downstream lanes with a `--filter` built from it;
`bvmirror.sh` leaves the 8 fenced row-mode databases out of every byte comparison, `fenced_skipped=8`). The control
list was filtered by the fence (0 hits). The gate sweeps dispatched every row; their csv verdicts are the only fenced
facts cited (all unchanged). A grep of this directory for the four names reads 0.

## 0. Verdict

**ACCEPT-WITH-FIX.** Every number r11u201 reports reproduces bit for bit (section 2). Fresh cases broke three of its
laws on legal SV where the pristine binary was right (section 1): two fresh cases leave `EQUAL` in the parse
form and seven in the `-elabuhdm` form, and three more move away from golden without a status change (o09 and o16 in
the parse form, c01 in both). Each break is fixed
behind its own switch; with the fixes every one of those cases writes the pristine bytes again, and nothing else
moves: the refined binary's firing census is identical to r11u201's (the refinements fire on no corpus row-mode, probe
case or downstream lane), its gate sweep reads exactly r11u201's verdicts, and its databases differ from r11u201's
on 0 of 1698 control cases in the parse form outside the break cases.

| row-mode | base (`ddc67d87`) | r11u201 | refined (verified) |
|---|---|---|---|
| MiniAmiq d / t | `differ:file(17)` | `differ:file(4)` | `differ:file(4)` |
| SeqDriver d / t | `differ:fullname(16)` | `differ:endcol(3)` | `differ:endcol(3)` |
| SimpleUVM d / t, Scoreboard d | `differ:fullname(44)` | `differ:fullname(31)` | `differ:fullname(31)` |
| BuildUVMPkg d / t | `differ:line(11)` | `differ:line(5)` | `differ:line(5)` |
| SVSwitch d / t | `differ:fullname(13)` | `differ:endline(11)` | `differ:endline(11)` |
| Scr1SvTests d / t | `differ:endcol(29)` | `differ:endcol(19)` | `differ:endcol(19)` |
| probe r10svs2repro/s4_context, r10svs3repro/a1_newlhs, r10uvm60repro/v2_class, v11u112repro/grid/brk/t/b2c_iface_fn | `STRICT_NOTEQUAL` | **`EQUAL`** | **`EQUAL`** |
| probe r10uvm193repro/g193_c_argface | `differ:fullname(102)` | `differ:fullname(94)` | `differ:fullname(94)` |

No corpus row-mode converts (every one of them still needs ground B, as map 11 and r11u201 found). The fresh rows of
the refined sweep `/tmp/v11u201_swF` (NOT written to `results/`):

    MiniAmiq,default,STRICT_NOTEQUAL,differ:file(4),,differ:file(4)
    SeqDriver,default,STRICT_NOTEQUAL,differ:endcol(3),,differ:endcol(3)
    SimpleUVM,default,STRICT_NOTEQUAL,differ:fullname(31),,differ:fullname(31)
    Scoreboard,default,STRICT_NOTEQUAL,differ:fullname(31),,differ:fullname(31)
    BuildUVMPkg,default,STRICT_NOTEQUAL,differ:line(5),,differ:line(5)
    SVSwitch,default,STRICT_NOTEQUAL,differ:endline(11),,differ:endline(11)
    Scr1SvTests,default,STRICT_NOTEQUAL,differ:endcol(19),,differ:endcol(19)
    r10svs2repro/s4_context,EQUAL,,equal   (probe.csv; likewise a1_newlhs, v2_class, b2c_iface_fn)

## 1. The breaks and the refinements (switches `R11V201_<NAME>_OFF`, `R11V201_OFF` for all three)

Every case here names its law in its first line; the grid is `evidence/grid/v11u201_grid_parse_elab.tsv` (73 cases,
columns: case, then pristine / r11u201 / refined in the parse form, then the same in the `-elabuhdm` form; `=` marks
bytes equal to the previous column). Judged by uhdm-cmp and uhdm-strictcmp against the pinned Surelog v1.87 golden,
parse form (`-parse -nobuiltin -nocache -sv dut.sv`) and `-elabuhdm` form.

### 1.1 § opCtxBindableTarget201v (`R11V201_OPTGT_OFF`; refines § opCtxRefArgBare201)

**Break.** § opCtxRefArgBare201 drops the formal-typespec stamp on a user call's actual in the definition listing of a
continuous assignment whose target is a plain identifier and whose root is an operation, modelling
`UhdmWriter::writeCont_assign` cloning the assignment before `reduceExpr` stamps it. The clone happens only when
`CompileHelper::bindVariable(mod, m, lhs->VpiName())` finds the target, and that overload (CompileStmt.cpp) searches
`Variables()` / `Nets()` of a `module_inst` scope (and function, task, begin scopes) only; otherwise the later
`reduceExpr` (the `simplified == false` branch) runs on the listing's own objects and stamps them. Two legal shapes are
never cloned:

* an **implicit net** target (`assign yi = f(a) + 4'd1;` with `yi` undeclared): cases/O `o01_implicit`,
  `o11_implicit2`: pristine `EQUAL` in both forms, r11u201 `NOT_EQUAL` in both (golden `ref_typespec (work@top.a)` under
  `f(a)`, r11u201 none);
* an **interface body**'s continuous assignment (m an `interface_inst`): cases/O `o09_iface_body`, `o16_iface_noport`:
  pristine `EQUAL` in the `-elabuhdm` form, r11u201 `NOT_EQUAL`; in the parse form both are `NOT_EQUAL` on an earlier
  pristine face, and r11u201 moves them away (order-blind dump distance 6 -> 20 and 4 -> 11).

**Refinement.** The law fires only when the cont_assign's parent is a `module_inst` and no net of the target's name in
the listing's net map is an implicit net (slang `NetSymbol::isImplicit`). All four cases write the pristine bytes again
in both forms; the controls that r11u201 converts keep converting (o02 ports and variables, o03 non-ANSI ports, o05
operators, o07 child modules, o08 comma lists, o12 uninstantiated modules, o14 an implicit-typed port, o17 a struct
target; o13 a `#D` delay and o15 unpacked array targets convert in the `-elabuhdm` form).

### 1.2 § clsScopedBoundPlainClass201v (`R11V201_CLSPARAM_OFF`; refines § clsScopedBoundWholeSpan201)

**Break.** A class SPECIALIZATION qualifier in a part-select bound keeps the qualifier span in golden: cases/C
`c01_paramcls` `x[G#(4)::LV:0]`, `x[G#()::LV:1]`: golden `ref_obj (work@top.x.G::LV)` 7:16-7:23 (over `G#(4)::`),
r11u201 7:16-7:25 (the whole name), pristine 7:16-7:23. The case is `NOT_EQUAL` on an earlier face in both binaries;
the move is away (distance 28 -> 32 parse, 44 -> 52 `-elabuhdm`).

**Refinement.** The whole-name span applies only when the qualifier is a plain class name (`ScopedName` whose left is
an `IdentifierName`). c01 writes the pristine bytes again; r11u201's own C grid (c01, c02, c04, c05 converted) and the
fresh c02 (an enum member `K::E2`), c03 (parentheses, a unary minus, an indexed part select declined), c04 (generate
and procedural), c05 (class bodies) keep their r11u201 bytes.

### 1.3 § newArrayKeepFrozenBare201v (`R11V201_NEWARRBARE_OFF`; refines § newArrayPathStripTrailOnly201v)

**Break.** A `this.` path's members are minted with their bare name frozen (§ thisPathFormByPosition157: `(void)
r->VpiFullName()` before parenting). The r11u201 strip of the trailing element erases that stored bare name, and in
the `-elabuhdm` form the elaborator's clone of the class body then computes `work@C::t::n` where golden's clone (and
pristine's) reads `ref_obj (n)`: cases/A `a07_this_only` (`data = new[this.n + 1];`), `a01_this`, `a10_func_pkg`
(a package class): pristine `EQUAL` in the `-elabuhdm` form, r11u201 `STRICT_NOTEQUAL fullname(1)`. (`R11U201_NEWARRLAST_OFF`
brings back r11u200's own, larger break on the leading `this`.)

**Refinement.** A trailing element whose stored name IS its bare name keeps it; a scoped name (the law's face,
`work@Receiver::start::size`) is stripped. Reading an unstored trailing element computes its chain, which is scoped
there (the argument chain reaches the subroutine), and the strip leaves it unstored again: the parse-form bytes of
every case and of all 1698 controls are unchanged by this refinement. a01, a07, a10 read `EQUAL` in both forms;
r11u201's z01, z02, the fresh a02 (a wildcard-imported package function), a04 (a module initial), a08 (a handle path)
keep their conversions; a03 (a three-level path), a05 (a select in the path), a11 (`super.` and `this.h.n`) keep their
closer bytes.

### 1.4 What the fresh cases did not break

| grid | law | fresh shapes (both forms) | result |
|---|---|---|---|
| A | § newArrayArgPathElemsStripped200 | `this.`, handle, `super.`, three-level, select-in-path, package-import clone, module initial, generate | only 1.3 |
| B | § unitBoundFoldAtLeftOperand200 | `$unit` and package, `localparam` / `parameter` untyped ranges, `[(W*2)-1:0]`, `[W*2*2-1:0]`, `[-1+8:0]`, `[W-1-1:0]`, `[0:W*2-1]`, `[2**3-1:0]`, `[W<<1:1]`, `[$clog2(16)-1:0]`, macros in the file, macros from an include (b07), macros defined in another root file (b09, two-file command line, run by hand) | converts b02 b05 b07 (and b09's bound records), every other case closer or unchanged; none away |
| G | § genBlockBitsKeepsSelect200 | a gen-block localparam and net range (not reached), instance parameter overrides, a function in a gen block, gen-if / gen-for / case-generate conditions and headers, struct member and multi-dim selects, two-level generates | g03 converts; g05 and g03 go **DIVERGENT -> IDENTICAL** downstream; nothing away |
| C | § clsScopedBoundWholeSpan201 | specializations, enum members, parentheses, unary minus, indexed part selects, generate, procedural, class bodies, a parameter-conditional bound, a static call bound | only 1.2 |
| S | § sysCtxRefArgBare201 | `$bits`, `$size`, reducing `$signed` / `$unsigned` / `$clog2` beside it, nesting through user calls and concatenations, a conditional under `$onehot`, generate bodies in a child module, a parameter context, procedural and net-declaration contexts | every changed case closer (order-blind distance 170 -> 135, 162 -> 134, 74 -> 56, 49 -> 35, 47 -> 40); nothing away |
| O | § opCtxRefArgBare201 | 17 target / context shapes | only 1.1 |
| X | § nonReduceOpArgBare201 | `===`, `!=?`, `^` over a sum, `~^` under `==`, the conditional's condition and branch, `$signed` below, select targets, generate in a child | x01 x02 x03 convert (parse), x03 (elab); nothing away |
| M | § methodArgNestedRefChain201 | interface calls in continuous and procedural contexts, generate initial blocks, a task statement, a call index, package functions, a module task, `new[...]` arguments, inc/dec and `this.` paths, `super.` paths, part-select bounds, a method call in a case-generate block two instances down | m01 m07 m08 m09 m11 m12 convert; m10 (`super.c.f`) renames objects golden collapses into its `this` mockup (wrong both ways, same count); nothing away |
| N | § callArgInSelIdxChainName201 | a middle-position select, operations and `$clog2` between, generate continuous assignments, class methods, two nesting levels, streaming lvalues, generate blocks two instances down | every changed case closer; n06's streaming lvalue renames the index from one wrong name to another (golden reads the rvalue form `t.f.f...` there, a pass-184 carried face) |

Downstream (the gate's own `one()`, `drivers/dscase.py`, all 73 fresh cases on the three binaries,
`evidence/downstream/`): **g03 and g05 DIVERGENT -> IDENTICAL** on r11u201 and on the refined binary; no other verdict
moves (pristine 60 IDENTICAL / 7 EQUIVALENT / 5 DIVERGENT / 1 STATUS_DIFF, r11u201 and refined 62 / 7 / 3 / 1).

**Switch checks** (`drivers/switchcheck.sh` on the refined binary, both forms, the 73 fresh cases and r11u201's 48,
`evidence/grid/switchcheck.txt`): `R11U201_OFF=1 R11U200_OFF=1` writes the pristine bytes on all 204 case-forms where a
law fires; where one law's switch covers every firing, that switch alone restores the pristine bytes (170 of 172), the
exception being r11u201's N/n05 in both forms, where § methodArgNestedRefChain201 and § callArgInSelIdxChainName201 own
the same index (`kk.a[kk.idx(s.f[k])]`, a method call inside a select index): with `R11U201_MARGNEST_OFF` alone the
other law names it the same way, so dropping one law there needs both switches (r11u201's "each switch alone restores
its own context" does not hold on this overlap; the result is the same name either way). The refinement-only cases
(a07, c01, o01, o09, o11, o16) write the pristine bytes with every switch unset.

## 2. r11u201's numbers, reproduced

| claim | reproduced |
|---|---|
| pristine binary md5 `18183f058868a85659208c85a099980e` | yes (`/tmp/v11u201_bin/pris.bin`, built from `/tmp/wt_v11u201pris`) |
| law7 binary md5 `a86ce8281a1d3fdd65a6a7fc0e2589bb` from `ddc67d87` + the patch | yes (`/tmp/v11u201_bin/law.bin`, built from a fresh `ddc67d87` worktree + the patch) |
| patch applies clean on fresh `ddc67d87`; `law_index.py --check` current | yes |
| pristine sweep = the baselines | yes: `probe.csv` byte-identical to `results/golden_probe.csv`; surelog, uhdm2rtlil 0/0/0; downstream 803 / 66 / 2 / 0 |
| probe `regressions=0 conversions=4 changes=1` | yes (`/tmp/v11u201_swL`) |
| surelog `regressions=0 conversions=0 changes=13`; uhdm2rtlil 0/0/0 | yes |
| downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, `downstream.csv` byte-identical to pristine's | yes |
| byteverify 13 / 2560 movers, SELFCHECK 2559 / 2560 | yes (fence-free mirrors, `fenced_skipped=8`) |
| canaries surelog ok=41 changed=11, uhdm2rtlil ok=16; ctcan2 both PASS | yes |
| cmds audit 3273 / 3273 | yes (`/tmp/v11u201_bin/law.bin`) |
| UVM order-blind distances 15559 -> 15265, 11805 -> 11449, 4538 -> 4246, 3451 -> 3213, 1907 -> 1765; SVSwitch 102 -> 98; Scr1SvTests 251 -> 231 | yes (`drivers/uvmdist.sh`, `drivers/obrow.sh`) |
| grid 48 cases: parse 33 converted, `-elabuhdm` 26, 0 worse | yes (`evidence/grid/r11u201_grid_parse_elab.tsv`); "0 worse" holds on its own 48 but not on fresh cases (section 1) |
| byte controls 1370 cases: 18 movers, 15 to EQUAL, 3 closer (v23 16 -> 9, w8 79 -> 36, t35 55 -> 41) | yes, exactly (same directory set); plus r11u200dec's grids (10 movers: n01 n02 u01 u05 to EQUAL, b01 b03 b04 b05 u02 u06 closer) and v11u192repro (0 movers) |
| firing census: 26 databases | yes, identical line for line (refined binary; `evidence/census/firing_census_fix.txt`) |
| r11u200 laws with and without pass 198 (`R11U198_OFF=1`): identical verdicts | yes (`evidence/grid/r11u200_A_*.tsv`) |
| determinism: Earlgrey_0_1 one hash per mode; UVM draws storage order only | yes on the pristine and the refined binary (`evidence/determinism/`): Earlgrey `2a3a623104a7` / `52b21f1158b5` on both; every UVM multi-hash row 0 sorted-dump lines apart |

## 3. Gates of the verified patch (refined binary `/tmp/v11u201_bin/fix1.bin`, md5 `28df5418163a1463cf7ae93cc5b2762d`)

`tests/sweep.sh --jobs 3 --workdir /tmp/v11u201_swF`, all four stages, `SLANG_UHDM` exported, rc 0, `law index
current`; cmds audit 3273 of 3273 `slang:` lines name `/tmp/v11u201_bin/fix1.bin`.

| gate | result |
|---|---|
| (1) build | pristine = the main tree's md5; refined `28df5418163a1463cf7ae93cc5b2762d`, rebuilt to the same md5 from `/tmp/r11u201.verified.patch` applied to a fresh `ddc67d87` worktree (`/tmp/wt_v11u201chk`, `law_index.py --check` current) |
| (2) probe | EQUAL 3349 / STRICT_NOTEQUAL 738: `regressions=0 conversions=4 changes=1`; `probe.csv` byte-identical to r11u201's |
| (3) surelog | `regressions=0 conversions=0 changes=13` (the 13 above); CMP_EQUAL 461 / 457, CMP_NOTEQUAL 3 / 3 unchanged |
| (3) uhdm2rtlil | `regressions=0 conversions=0 changes=0`; csv byte-identical to r11u201's |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; `downstream.csv` byte-identical to the pristine sweep's |
| (5) uhdm-cmp | every changed row stays judge-equal (`STRICT_NOTEQUAL` -> `STRICT_NOTEQUAL`); every probe mover EQUAL or judge-equal |
| (6) byteverify vs pristine | **13 / 2560**, exactly the predicted 13; SELFCHECK 2559 / 2560 |
| byteverify vs r11u201's sweep | 3 / 2560 (MiniAmiq, SeqDriver, SimpleUVM default): uhdm-dumps identical ordered and sorted, storage order only |
| probe movers vs a same-path pristine run | **5 / 4087**, exactly the predicted 5 |
| downstream-lane movers | **0 / 805** |
| canaries | surelog ok=41 changed=11 (the canary rows among the 13 changes); uhdm2rtlil ok=16; ctcan2 `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS |

**The prediction** (`evidence/census/predicted_movers.txt`, frozen `chmod 444` before the refined sweep): the refined
binary's firing census (`drivers/census.sh`, fence filter) is identical to r11u201's; the refinements' own traces
(`opCtxBindableTarget201v`, `clsScopedBoundPlainClass201v`, `newArrayKeepFrozenBare201v`) fire on none of the 2560
corpus databases, 4087 probe cases and 805 downstream lanes, so the refined sweep must move exactly r11u201's 13 + 5
databases against pristine and none against r11u201. It did (the 3 byte draws against r11u201 are storage order).
Fired but unmoved (both binaries): Earlgrey_0_1 d/t (§ nonReduceOpArgBare201 ×6), SimpleConstraint d/t and ibex_tracer
d/t (§ sysCtxRefArgBare201), probe r10uvm57repro/v1_prodcell, downstream ibex_tracer: the trace fires where the law's
context holds, before the stamp rule's other conditions decide.

## 4. Ranked residues (the verifier's view; r11u201's section 7 list stands)

1. **Ground B halves** (r11u202's ground): SVSwitch `endline(11)` (TypeEmit implicitTsEndCrossesLineBreak200, ModuleEmit
   ifaceArrPortElemViewNamedByArray200), Scr1SvTests `endcol(19)` (ModuleEmit `materializeDefNetTs`, the UhdmExporter
   `$unit` initializer half), the UVM first records, the definition-listing half of § genBlockBitsKeepsSelect200 (z05,
   z08, fresh g04 g05 g06: TypeEmit `emitSyntaxExpr`), the generate-listing spans (r11u201's c06, n07; fresh c04's
   generate full names).
2. **§ opCtxRefArgBare201 in the `-elabuhdm` form** (r11u201's q01 `type(1)`, q09 q10, fresh x01 x02 `NOT_EQUAL`): not
   decoded; the elaborated body's stamp rule under a binary operator.
3. **§ callArgInSelIdxChainName201's rvalue in a middle position** (fresh n01 line 11: golden `work@top.t.f[].g.s.f[k].k`,
   ours `work@top.s.f[k].k`) and inside a streaming lvalue (n06: golden reads the rvalue form `t.f.f.s.f[k].k`).
4. **`super.c.f(...)`** (fresh m10): golden collapses the path into its `this` mockup constant; ours emits the path.
5. **The overlap of § methodArgNestedRefChain201 and § callArgInSelIdxChainName201** (n05): both switches are needed to
   drop that index's name; harmless (same name either way).
6. r11u201's section 7 items 2-10 (UVM_MACRO_* ref_typespec names, Earlgrey #90097, Rggen N0145, arb_idx_cast,
   cfg_func_width_loop, struct_param_func_config, the value encodings, the carried faces) — unchanged by the
   refinements.

## 5. Files

* `drivers/`: `env.sh` (pins + fence), `case.sh` (one case, `ELAB=1` for the `-elabuhdm` form), `judge.sh` (binaries x
  cases, `=` for equal bytes), `obd.sh` (order-blind dump distance), `away.sh` / `awayall.sh` (lines a binary adds or
  loses against golden that the pristine binary did not), `switchcheck.sh`, `bvmirror.sh` (fence-free byte mirrors),
  `census.sh` + `censum.py` (the firing census), `obrow.sh`, `uvmdist.sh`, `dscase.py` (the downstream gate's `one()`),
  `det.sh` + `detob.sh`. Binaries are read from `$VB` (default `/tmp/v11u201_bin`: `pris.bin`, `law.bin` = r11u201,
  `fix1.bin` = refined, `uhdm-strictcmp`).
* `cases/`: A (§ newArrayArgPathElemsStripped200; a01 a07 a10 § newArrayKeepFrozenBare201v), B
  (§ unitBoundFoldAtLeftOperand200; b09 is a two-file case: `defs.sv dut.sv`), C (§ clsScopedBoundWholeSpan201; c01
  § clsScopedBoundPlainClass201v), G (§ genBlockBitsKeepsSelect200), M (§ methodArgNestedRefChain201), N
  (§ callArgInSelIdxChainName201), O (§ opCtxRefArgBare201; o01 o09 o11 o16 § opCtxBindableTarget201v), S
  (§ sysCtxRefArgBare201), X (§ nonReduceOpArgBare201).
* `evidence/`: `grid/` (the fresh grid, r11u201's grid on three binaries, the r11u200 composition, the switch check),
  `controls/` (1710 control cases pristine vs r11u201; refined vs r11u201), `census/`, `sweeps/` (the three sweep
  summaries, byteverify, canaries, probe movers, UVM distances), `downstream/`, `determinism/`.

Reproduce: build `ddc67d87` + `/tmp/r11u201.verified.patch` (`cmake -B build -DCMAKE_BUILD_TYPE=Release
-DSLANG_UHDM_USE_SYSTEM_DEPS=ON -DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build build -j 2`), freeze it as
`$VB/fix1.bin` beside the pristine build, then `bash drivers/judge.sh "pris.bin fix1.bin" <case dirs>` (and `ELAB=1`),
`bash drivers/switchcheck.sh fix1.bin <case dirs>`, `SLANG_UHDM=$VB/fix1.bin bash drivers/census.sh <wd> <trace dir>
<prefix>`, `tests/sweep.sh --jobs 3 --workdir <wd>` with `SLANG_UHDM` exported.
