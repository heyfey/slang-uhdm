# r11u227 — the expression/parameter ground: forward package references in expression grammar, the pattern parameter read by an evaluated subroutine, part selects inside `new[...]`, the renaming drain visited in id order (the MiniAmiq / SimpleUVM symbol-table coins), and the ground-A halves of six cross-ground switches

Base: `ac0dda58` (pass 224). Ground: src/ExprEmit.cpp, src/ParamEmit.cpp and a new header src/R227.h (this pass's
switch, split-switch and trace helpers). Nothing under results/, third_party/ or tests/ changes except the regenerated
tests/LAWS.md. The patch is `/tmp/r11u227.patch` (git diff against `ac0dda58`, this directory included).

## 0. Verdicts

| target (brief item) | before -> after (fresh csv rows, [evidence/sweeps/](evidence/sweeps/)) | law |
|---|---|---|
| (1) FuncStructVal d/t #747 / #7462 (map 14's N1096: `NOCType: config_pkg::NOC_TYPE_AXI4_ATOP`, golden 106:16-28, ours 106:16-46) | **CHANGE** `endcol(7)` -> `file(5)` (default), `endcol(10)` -> `file(9)` (testflags): both #747 records and their elaborated twins cleared; the head is now #4782 (N2472, the INSTR_PER_FETCH read-site leftover, residue 2) | § fwdPkgRefClassScopeSpan227 |
| (1) FuncStructVal N0980 / N1946 / N2472 / N2473 | not written (section 8) | none |
| (1) struct_param_func_config N0675 / N2412, cfg_func_width_loop N0025 N0033 N0754 N0794, BlackBePipeInt #15268 / #15272, N0131, Earlgrey N0812, N0039 | not reached (section 10) | none |
| map 14's N0003 (ground A, the first cluster of 24 probe cases: golden's pattern-parameter operation carries an unparented, unnamed ref_typespec) | **20 probe cases CHANGE**, every one shrinking on its first field (`fullname(5)` -> `fullname(4)` on 16, `fullname(9)` -> `fullname(8)` on 3, `fullname(10)` -> `fullname(8)` on a5); none converts: what is left is the module listing's leftover copy (golden `<in>pk::c_t.u`, a copy per typespec copy) | § pkgPatFuncBodyLeftoverNoParent227 |
| (2) v11u224 NX/nx05 (a part select inside `new[...]`) | `fullname` -> **EQUAL** (parse view); the `--elabuhdm` view keeps `fullname` (residue 4) | § newArrayPartSelStripped227 |
| (2) the other pass-224 residues (sx11, G/g26 / T/t35, ld02, ib01_el, C/c21 c22, SP sp19, K/k09, HN hn10, TP tp12) | not reached (section 10) | none |
| (3) the address-order loop (§ refFullNameThroughNamedExpr175, § methodArgNestedRefChain201, § callArgInSelIdxChainName201 in ExprEmit) | written: **one hash in 16 concurrent draws** on every row-mode of MiniAmiq, SimpleUVM, SeqDriver, BuildUVMPkg and Earlgrey_0_1 (pristine: MiniAmiq d 2 hashes, t 2, SimpleUVM d 2); the raw strict walk (`--no-canon`) of every draw against the pristine one is STRICT_EQUAL and uhdm-cmp reads 0 lines: no record moves | § refChainDrainIdOrder227 |
| (3) the `[N]` bound of an array with an unsized inner dimension (golden `N-1` as an operation) | decoded as stage 1 on every pass-223 C case at the base; not written (section 8) | none |
| (4) the switch-reach table (R11U113, R11U115, R11U172, R11U48, R11V190, R11V199) | measured on each landing's own cases in both views; a ground-A split added for each (section 7) | § landingSwitchReach227 |
| (5) carried items | not reached (section 10) | none |

**No corpus row-mode converts.** No probe case converts. The gate sweep changes are exactly the laws' predicted
records: surelog 2 changes (FuncStructVal d/t), probe 20 changes (the N0003 cases), uhdm2rtlil 0, downstream 803 / 66 /
2 / 0 with the csv byte-identical to the pristine sweep's.

**Gates (law7.bin against the committed baselines, `tests/sweep.sh --jobs 3`, [evidence/sweeps/sweep_swL.log](evidence/sweeps/sweep_swL.log)):**
probe **0 regressions**, 0 conversions, 20 changes (3453 + 634); surelog **0 regressions**, 0 conversions, 2 changes;
uhdm2rtlil **0 regressions**, 0 conversions, 0 changes (1600 + 6); downstream **803 / 66 / 2 / 0**, csv identical to the
pristine sweep's. EXIT=1 on both sweeps is only the tests/LAWS.md staleness notice (this directory's `§` names; the
patch carries the regenerated index). The pristine sweep ([sweep_swP.log](evidence/sweeps/sweep_swP.log)) reads 0 / 0 /
0 in every stage and 803 / 66 / 2 / 0.

## 1. Binaries (frozen `chmod 555` under the pass's scratch bin directory before any measurement)

| name | md5 | what |
|---|---|---|
| pristine.bin | `4af5fef78fce30c048738988bca79c9c` | `ac0dda58` built in this worktree (`-DSLANG_UHDM_USE_SYSTEM_DEPS=ON`), byte-identical to the main tree's build/slang-uhdm |
| **law7.bin** | **`3eca48dc648268bc7bab3052df2ddf0c`** | the delivered source |
| law1.bin ... law6.bin | `fc0722f1...`, `a4c555b6...`, `60d46a23...`, `1968dea3...`, `c4046820...`, `b3ac4cfd...` | the successive drafts (section 9 names the two superseded ones) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | this worktree's build, identical to the main tree's (the sweeps' comparator) |
| strictcmp_x | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's variant (tools/probe/r11u211map/drivers/cc.sh), for the chain-keyed away census |

The patch applied to a fresh worktree at `ac0dda58` (git apply, clean) rebuilds law7.bin byte for byte (md5
`3eca48dc648268bc7bab3052df2ddf0c`). Every `slang:` line of the law sweep's 3273 corpus `cmds.txt` names law7.bin, and
of the pristine sweep's pristine.bin.
Every source edit was followed by a fresh build frozen under a new name; the pristine binary was frozen before the first
edit.

## 2. The laws

Every law reads its own switch; **R11U227_OFF drops every law of this pass**, restoring the base's bytes: on all 108
grid case-views the law binary under R11U227_OFF writes the pristine bytes (`OFF=pristine` on every line of
[evidence/grid_law7.tsv](evidence/grid_law7.tsv)), on FuncStructVal d/t and the three probe movers of § refChainDrainIdOrder227
it writes the pristine hash, and on BuildUVMPkg, MiniAmiq, SeqDriver and SimpleUVM (both modes, 4 draws each) every draw
is a pristine hash ([evidence/det/det_law7off.txt](evidence/det/det_law7off.txt)). R11U227_TRACE=<dir> names every
firing, one file per process (`<dir>/<pid>.227`, first line `OUT <-o path>`): the census that predicted the movers
(section 4).

| law | switch | site (anchor) |
|---|---|---|
| § fwdPkgRefClassScopeSpan227 | R11U227_FWDPKGSPAN_OFF | ExprEmit, `fwdPkgRefClassScopeSpanDrain227`, run design-final from ParamEmit's drainPaNameCopySrc38 after § cloneHpIdxNamesByChain220's drain |
| § pkgPatFuncBodyLeftoverNoParent227 | R11U227_PATLEFTOVER_OFF | ParamEmit, drainShareDefParamTs's § pkgPatReadTsNoParent131 read set (beside § pkgPatUnqualReadTsNoParent178); the registry `patLeftoverClones227` filled in memLeftPatParamClone26 (§ patParamLeftoverShare26) |
| § newArrayPartSelStripped227 | R11U227_NEWARRPS_OFF | ExprEmit, `stripRefFullNames11`'s part_select / indexed_part_select cases and its hier_path case; the view flag `newArrPsParseView227` set at the `new[...]` branch's call |
| § refChainDrainIdOrder227 | R11U227_IDORDER_OFF | ExprEmit, `refFullNameThroughNamedExpr175` (its three renaming loops) with `idOrderObjs227` / `IdOrderTrace227` |
| § landingSwitchReach227 | R11U227_SPLIT113A_OFF, _SPLIT115A_OFF, _SPLIT172A_OFF, _SPLIT48A_OFF, _SPLITV190A_OFF, _SPLITV199A_OFF (R11U227_OFF does NOT read them) | R227.h `r11u227SplitAOff`, read at the twelve ground-A read sites of the six old switches in ExprEmit |

### 2.1 § fwdPkgRefClassScopeSpan227 (FuncStructVal #747; grid [cases/FW](cases/FW))

Surelog compiles the packages in file order (CompileDesign; FuncStructVal's cva6_config_pkg reads config_pkg, declared
after it, and golden's reference stays unresolved: full name `cva6_config_pkg::config_pkg::NOC_TYPE_AXI4_ATOP`). An
unresolved reference is a ref_obj located at CompileExpression's `parent` node (`fC->populateCoreMembers(parent, parent,
ref)`), and that node depends on the grammar. In a constant_expression `p2::K` parses as constant_primary
(package_scope identifier, the whole name: golden `localparam e_t Q = p2::E1;` 7:26-32). In expression grammar it parses
as complex_func_call (class_scope identifier), and the class_scope node spans only `p2::` (Surelog's `-d ast` of the
decode case: `Class_scope l<5:30> el<5:34>`, golden `$clog2(p2::K)` 5:30-34). Expression grammar is reached through an
assignment-pattern member (keyed and positional), a subroutine or system-call argument, the first branch of a constant
ternary (the grammar's `constant_expression ? expression : constant_expression`: golden `1 ? p2::K : 2` 9:27-31, the
condition `p2::K ? 1 : 2` 8:23-28 whole) and a subroutine body (`return p2::K;` 12:12-16). A backward reference folds in
golden (FW fw07: a constant spanning the name) and is never an unresolved ref_obj.

The law, design-final over every ref_obj (id order): a name `Q::n` with one `::`, ours located on one line exactly over
the written name, whose parent chain reaches a package P (no class, module, interface, program or generate scope on the
way) through an expression-grammar node (tagged_pattern, an assignment-pattern operation, a call, the conditional's
second operand, a subroutine), and Q a package other than P declared after P in the same file: the end column becomes
`col + |Q| + 2`. The full name is never read (ref_obj's getter stores the chain name it computes: section 9).

| FW case | parse | --elabuhdm | |
|---|---|---|---|
| fw01 keyed enum member, fw05 two parameters on a line, fw06 member value on its own line, fw22 a class in the package too | `endcol` -> **EQUAL** | `endcol` -> **EQUAL** | the law |
| fw14 member from a macro, fw15 member and whole pattern from a macro in an included file | `endcol` -> **EQUAL** | `endcol` -> **EQUAL** | golden spans the expanded `p2::` at the macro call's column (6:10-14, 9:46-50), as ours places it |
| fw02 fw03 fw04 fw08 fw09 fw10 fw11 fw16 fw17 fw20 fw21 (a forward parameter `p2::K`, positional, operation, sys call, ternary, nested pattern, imported use, three packages, default key, call argument) | stage 1, moved | stage 1, moved | stage 1 at the base (ours folds `p2::K` where golden keeps the reference, or keeps a nested pattern): 0 away, 1-4 records toward each |
| fw18 (a class parameter `c::K` beside the forward enum) | `endcol` -> `type` | stage 1, moved | the class reference declines; the next record (#181, a `type` record present at the same index in the pristine walk) is unmasked |
| fw07 backward, fw12 function body (ours folds the return), fw19 interface body, fw13 spaced `p2 :: E1` | unchanged bytes | unchanged bytes | declines (fw13: golden 5:10-15 ends at the `::` token, ours 5:10-18; residue 3) |

FW: 22 cases, 44 views, **12 converting**, 0 leaving EQUAL, 24 moved without converting (**0 away** in the dump census,
[evidence/grid_away_law7.txt](evidence/grid_away_law7.txt)), R11U227_OFF pristine on all 44.

### 2.2 § pkgPatFuncBodyLeftoverNoParent227 (map 14's N0003; the 20 gate probe cases; grid [cases/PL](cases/PL))

Golden `r11u24repro/n12` (`localparam in_t UU = '{a: 11, b: 22};` read whole by `c.u = UU;` in the package function
`mk()` that `localparam c_t C = mk();` calls): the package listing's pattern operation carries an unnamed ref_typespec
(the strict record #153 golden empty, ours `pk`). The producer road is § pkgPatReadTsNoParent131's: ExprEval's evalFunc
reduces the read through CompileHelper::getValue, which runs expandPatternAssignment on the param_assign's pattern and
writes the flattened copy back, its ref_typespec minted by flattenPatternAssignments without a parent. The read set of
§ pkgPatReadTsNoParent131 held the qualified reads, § pkgPatCallArgReadNoParent167 the call arguments and
§ pkgPatUnqualReadTsNoParent178 the member reads; the whole-value read inside an evaluated subroutine was missing. Ours
already marks that read: § patParamLeftoverShare26 clones exactly that (flattened, all-constant) operation into the typespec
member's leftover (memLeftPatParamClone26). The law adds to the read set a pattern-written package parameter whose
flattened listing operation § patParamLeftoverShare26 cloned; the existing branch then gives it a fresh, unparented reference.
The clones themselves keep their parented reference: golden's leftover under the package listing's `pk::C` typespec
reads `pk` (a first draft that unparented the clones too moved those records away, law3.bin, section 9).

Gate probe cases (all 20 predicted by name, all `CHANGE` shrinking, **0 away, 21 toward** in the chain-keyed census):
r11u24repro n3 n12; r11u26repro m6 m8 m9 m13 m15; r11u28repro a4 a5 (two parameters) a6 a7 a13 a16; r11v26repro v2 v9
v12 v13 v15 v16 v18. The four N0003 cases the law does not reach: r11u26repro m4 and r11u28repro a2 (the first record
is a MODULE listing's pattern reference, golden unnamed, ours `work@dut`: not a package parameter), r11v4repro v5 v6 (an
interface port view's, ours `work@top.a0.q`, § ifacePortViewPaFoldsDeclDefault's face).

PL (fresh cases): pl07 (two readers), pl08 (default key), pl11 (an interface reads the parameter), pl12 (a generate
scope reads it) move toward golden (1 record each, 0 away; stage 1 or `fullname` elsewhere at the base); pl01
(qualified read in its own package: § pkgPatReadTsNoParent131 already), pl02 (read from another package), pl03
(positional), pl04 (not evaluated), pl05 (whole-value localparam), pl06 (nested pattern: no clone), pl09 (module
parameter calls it), pl10 (member read in an expression) are untouched. PL: 12 cases, 24 views, 0 converting, 0 leaving
EQUAL, R11U227_OFF pristine on all.

### 2.3 § newArrayPartSelStripped227 (v11u224 NX/nx05; grid [cases/NP](cases/NP))

Under the unparented `new[...]` call (§ newArray11's model, § newArrayVarSelStripped224's strip) a part select or an
indexed part select stores no name in golden's parse view, nor do the references of its bounds, base and width: golden
`la = new[v[k+:2]];` in `p::c::f`, `indexed_part_select v` and `ref_obj k` unnamed, ours `p::c::f::v` / `p::c::f::k`;
as the last index of a var_select the writer's chain runs through it (`new[arr[k][k][1:0]]`: golden `part_select arr` =
`arr.arr`; `new[arr[k][k+:2]]`: `k` = `arr.k`); as a hier_path's trailing select the select keeps its name (EQUAL at the
base) and its base reference reads the chain (`new[s.f[k+:2]]`: `s.f[k+:2].k`). With `--elabuhdm` UHDM's
ElaboratorListener runs over both databases and golden names all of them by the parented chain (`p::c::f::v`,
`p::c::f::arr::arr`), where the pristine binary is already right for the indexed part select (np03 np04 np07 np10 np12
--elabuhdm: EQUAL at the base), so the law is the parse view's alone (`!elabUhdmView121`).

NP: 20 cases, 40 views, **14 converting** (every parse view that differed: np01 np03 np04 np05 np07 np08 np10 np12 np14
np16 np17 np18 np19 np20), 0 leaving EQUAL, np15 (an interface function, stage 1) moved 3 records toward, every
`--elabuhdm` view unchanged in bytes, R11U227_OFF pristine on all 40. Fresh shapes: `this.` paths (np13), extern methods
below (np14) and above their caller (np20, the copy form), class specializations with a parameter width (np16), a pure
virtual prototype (np17), a module initial block (np18), linked named and positional call arguments (np19), macro-born
arguments (np12), an interface body (np15), a module function (np06). nx05 itself converts in the parse view.

### 2.4 § refChainDrainIdOrder227 (brief item 3; map 14 section 8, pass 223's § formalRegNoHeap223v)

`refFullNameThroughNamedExpr175` iterated `Serializer::AllObjects()`, a `std::map` keyed by the object's address, in its
three renaming loops (§ refFullNameThroughNamedExpr175 with § methodArgOpRefChainName198, § methodArgNestedRefChain201,
§ callArgInSelIdxChainName201), and each `VpiFullName(want)` registers `want` in the symbol table the first time it is
seen: the order of the new symbols, so the bytes (never the content), followed the heap layout, which slang's parallel
parse varies per run. Every decision in the loops reads only the object and its parent chain's names (chainFullName175
reads VpiName / VpiDefName, never a full name another iteration writes), so the same writes happen in any order. The
loops now visit the objects sorted by UhdmId (the idiom of § rootPathFullNameByChain181); the io_decl default map keeps
its walk (it writes nothing). The trace line per process (`refChainDrainIdOrder227 id writes=N reorder=R`) says whether
the id order puts a loop's new symbols in another order than that run's address order: the byte-mover predictor.

| row-mode ([evidence/det/](evidence/det/), drivers/det16.sh: 16 draws, 4 concurrent, the harness's own command line and cwd) | pristine.bin | law7.bin |
|---|---|---|
| MiniAmiq d / t | **2 hashes** (6 + 10) / **2 hashes** (3 + 13) | **1** / **1** |
| SimpleUVM d / t | **2 hashes** (14 + 2) / 1 | **1** / **1** |
| SeqDriver d / t, BuildUVMPkg d / t, Earlgrey_0_1 d / t | 1 each | 1 each (Earlgrey_0_1: the pristine hash itself) |
| Scoreboard d | 3 hashes | 2 hashes (the svunit listing-order coin, not this loop: 0 sorted dump lines) |

Every law7 draw against the pristine draw of the same row-mode: `uhdm-strictcmp --no-canon` STRICT_EQUAL (390,916 to
908,551 objects), uhdm-cmp 0 lines; Scoreboard d the listing coin, its sorted dumps identical
([idorder_norecord.txt](evidence/det/idorder_norecord.txt)). The three probe movers of the law (r10buvm13repro/v3_clone13,
r10uvm17repro/t29_t, r10v179repro/v179_f_nomod) read STRICT_EQUAL against their pristine databases and
R11U227_IDORDER_OFF restores their bytes ([idorder_probe.txt](evidence/det/idorder_probe.txt)). The UVM order-blind
distance is unchanged by the pass ([evidence/uvmdist.txt](evidence/uvmdist.txt): MiniAmiq 1761 / 6565, SeqDriver 1304 /
4713, SimpleUVM 914 / 1554, Scoreboard 585 / 973, BuildUVMPkg 230 / 405, dist / total, both sweeps).

## 3. The gates (law7.bin against pristine.bin, both at `ac0dda58`; workdirs of equal name length)

| stage | pristine.bin | law7.bin |
|---|---|---|
| probe vs golden_probe.csv | 3453 + 634, 0 / 0 / 0 | **3453 + 634: 0 regressions, 0 conversions, 20 changes** |
| surelog vs golden_surelog.csv | 929 + 25, 0 / 0 / 0 | **0 regressions, 0 conversions, 2 changes** |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 1600 + 6, 0 / 0 / 0 | **1600 + 6: 0 / 0 / 0** |
| downstream | 803 / 66 / 2 / 0 | **803 / 66 / 2 / 0** (csv identical) |

**Surelog changes** (2): FuncStructVal default `endcol(7)` -> `file(5)`, testflags `endcol(10)` -> `file(9)`
(§ fwdPkgRefClassScopeSpan227: the two #747-family records per listing leave; the first record is now #4782, the
`INSTR_PER_FETCH` leftover located at the read site 618:22-45 by golden, pristine's walk holding it at the same index).
**Probe changes** (20): the N0003 cases of section 2.2, each on the same first field with a smaller count.

Canaries: canaries.sh surelog ok=50 changed=2 (exactly FuncStructVal d/t; the pristine sweep ok=52), uhdm2rtlil identical
to the pristine sweep's reading; ctcan2 EXPECT_UNKNOWN=1 surelog PASS, EXPECT_UNKNOWN=6 uhdm2rtlil PASS, on both sweeps.
uhdm-cmp reads 0 lines on every touched row-mode and probe case: each is judge-equal (CMP_EQUAL / STRICT_NOTEQUAL /
EQUAL) in the law sweep.

## 4. Movers, predicted by name before the law sweep

The firing census (drivers/census.sh: every corpus row-mode but the four fenced ones through a negative `--filter` built
from the FENCED= line of tools/probe/r11u107repro/canaudit.sh, and every probe case; drivers/dscensus.py: every
downstream lane's translated command line, no Yosys) ran law7.bin with R11U227_TRACE set; drivers/predict.py (a
`refChainDrainIdOrder227 ... reorder=0` line predicts nothing) froze [evidence/census/predict_final.txt](evidence/census/predict_final.txt)
(md5 `8532dbcb54eb54036e2bd57ce3dbc0b0`, stamped 2026-09-29T11:35:38Z with law7.bin's md5,
[predict_final.stamp](evidence/census/predict_final.stamp)), the law sweep starting after it: 11 surelog row-modes, 23
probe cases, 0 uhdm2rtlil row-modes, 0 downstream lanes.

* **corpus**: byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on hard-link mirrors without the 8 fenced
  row-mode databases, drivers/bvmirror.sh; path sets identical): **11 of 2560 movers, exactly the 11 predicted**
  ([evidence/movers/byteverify_corpus.txt](evidence/movers/byteverify_corpus.txt)): FuncStructVal d/t
  (§ fwdPkgRefClassScopeSpan227 x2 each), BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d
  (§ refChainDrainIdOrder227, reorder=1 each; their records unchanged, section 2.4). SELFCHECK reads 2559 of 2560: the
  self-check compares every file against ONE fixed file of the set, and that file against itself is the one path it
  cannot flag.
* **probe**: **23 of 4087 movers, exactly the 23 predicted** ([evidence/movers/probe_movers.txt](evidence/movers/probe_movers.txt)).
* **downstream lanes**: **0 of 805** databases move; every lane's RTLIL (`.il`, `_nohier.il`) identical.

The chain-keyed away census (drivers/awayrows.py, map 13's census on strictcmp_x records, raw full names) over the 34
moving databases: **away 0, toward 25** (21 probe, 4 FuncStructVal; the 12 § refChainDrainIdOrder227 movers 0 / 0), flat
away 0 ([evidence/away/awayrows_law.txt](evidence/away/awayrows_law.txt)); the reversed positive control reads **away 25**
([awayrows_reversed_control.txt](evidence/away/awayrows_reversed_control.txt)).

## 5. Grid and controls

This pass's grid ([evidence/grid_law7.tsv](evidence/grid_law7.tsv), drivers/grid.sh): 54 case directories x 2 views =
108 case-views, goldens built by the pinned Surelog per case text:

| group | cases | law | converting | leaving EQUAL | moved without converting |
|---|---|---|---|---|---|
| FW | 22 | § fwdPkgRefClassScopeSpan227 | 12 | 0 | 24 (0 away) |
| PL | 12 | § pkgPatFuncBodyLeftoverNoParent227 | 0 | 0 | 8 (0 away) |
| NP | 20 | § newArrayPartSelStripped227 | 14 | 0 | 1 (0 away) |
| **total** | **54** | | **26** | **0** | **33, 69 records toward, 0 away** |

R11U227_OFF writes the pristine bytes on all 108. Switch reach ([evidence/switch_reach.txt](evidence/switch_reach.txt),
drivers/switches.sh): every one of the 59 moved case-views is restored by exactly its own law's switch (36
R11U227_FWDPKGSPAN_OFF, 15 R11U227_NEWARRPS_OFF, 8 R11U227_PATLEFTOVER_OFF); R11U227_IDORDER_OFF moves no grid case.

## 6. The decode cases kept out of the grid

The forward-reference decode (the grammar table of section 2.1) ran on scratch cases of the same shapes (a pattern with
a local struct type, `$clog2`, ternary branches, a function body, both package orders) whose views are stage 1 at the
base; the kept FW cases carry every judge-equal and every control shape.

## 7. The switch reach (§ landingSwitchReach227, brief item 4)

The six whole-pass switches pass 224 left unsplit are read at 12 ground-A sites (ExprEmit) and 10 ground-B sites
(TypeEmit, ModuleEmit). Each ground-A site now also reads `R11U227_SPLIT<N>A_OFF`; the old switches keep their meaning and
R11U227_OFF does not read the splits. Measured with law7.bin on each landing's own cases, both views (drivers/reach227.sh,
[evidence/reach/](evidence/reach/)):

| old switch | cases (both views) | old moves | split moves | split moves where old does not | split bytes == old bytes where split moves |
|---|---|---|---|---|---|
| R11U113_OFF (tools/probe/r11u113repro, tests/probe/r11u113repro, v11u113repro) | 284 | 216 | 78 | 0 | 78 |
| R11U115_OFF (tools/probe/r11u115repro, tests/probe/r11u115repro, v11u115repro) | 386 | 260 | 140 | 0 | 140 |
| R11U172_OFF (tools/probe/r11u172rp) | 104 | 60 | 14 | 0 | 14 |
| R11U48_OFF (tests/probe/r11u48repro, r11v48repro) | 112 | 30 | 2 | 0 | 2 |
| R11V190_OFF (tools/probe/r11u190verify) | 146 | 14 | 4 | 0 | 4 |
| R11V199_OFF (tools/probe/r11u199verify) | 170 | 30 | 18 | 0 | 18 |

Each split moves a strict subset of the old switch's movers, and wherever it moves it writes exactly the old switch's
bytes: those case-views carry only the landing's ground-A laws; the rest of the old movers are the ground-B half.
After this pass every whole-pass switch read on both grounds has a ground-A split except R11U166, R11U92, R11V141
(EmitHelpers.h helpers read by both grounds' call sites, pass 224 section 8).

## 8. Decoded, not landed

* **FuncStructVal #4782 (N2472 / N2473, residue 2)**: golden locates the INSTR_PER_FETCH leftover (INT:2) at the read
  site `CVA6Cfg.INSTR_PER_FETCH` 618:22-45; pass 210's and r11u218's shapes (RS r01-r08) all leave it unlocated; not
  decoded further here. The next records are N0980 / N1946 (the member leftovers' reference names and golden's extra
  operations, ParamEmit makeMemLeftConst) and N0891 (ground B, TypeEmit buildStructTs).
* **N0003's rest**: the module listing's leftover (golden `<in>pk::c_t.u`: a leftover copy per typespec copy, parented
  inside the module's copy) against ours' one leftover shared by both listings (the package listing's golden reference
  is parented, `pk`): a copy of the leftover per module typespec copy; the typespec copy family (TypeEmit, the sister's).
* **The `--elabuhdm` half of § newArrayPartSelStripped227's face**: golden names the part select by the parented chain
  (`p::c::f::v`, np02 np06 np08 np11 --elabuhdm; ours unnamed) and a var_select's element select with `::`
  (`p::c::f::arr::arr`, np01 np05; ours `p::c::f::arr.arr`).
* **The `[N]` bound of `int ma [4][int]`** (pass 223 residue 8): golden `4-1` as an operation, ours `UINT:3`; every pass-223
  C case reads stage 1 at the base on this record (`array_var(ma) > range > operation` against `constant`), no
  judge-equal shape; the array_var range builder was not pinned to a file.

## 9. Fence and process

* Every driver that reads corpus sources or databases reads the four names from the FENCED= line of
  tools/probe/r11u107repro/canaudit.sh and fails closed (env.sh, case.sh, run1.sh, grid.sh, switches.sh, reach227.sh,
  dumpdelta.sh, census.sh with its negative `--filter`, dscensus.py, predict.py, bvmirror.sh, awayrows.py, uvmdist.sh,
  det16.sh). The gate sweeps dispatched every row as the gate mandates; no binary, gdb or script ran on a fenced test's
  sources or databases outside them. The evidence csvs are the sweeps' csvs without every line holding a fenced name,
  even as a substring of another test's name (8 surelog rows, 2 uhdm2rtlil rows, 1 downstream row per sweep; their
  verdicts are unchanged in the sweep logs' counts). No fenced name appears in this directory.
* Every tool call through a variable was guarded (`[ -x "$UHDM_DUMP" ]` and the environment file's checks); no database
  was executed and no stray file was written.
* **Two drafts superseded before the census.** law3.bin also gave the leftover clones a fresh unparented reference: the
  package listing's leftovers moved away from golden (`pk` -> empty) on r11u24repro/n12; the clone half was dropped
  (law4.bin). law1.bin to law6.bin read `VpiFullName()` of every qualified ref_obj in § fwdPkgRefClassScopeSpan227's
  drain: ref_obj's getter stores the chain name it computes, so Earlgrey_0_1 d/t moved bytes with identical dumps and no
  firing (det16 law1 against pristine); the read was removed (law7.bin: Earlgrey_0_1 writes the pristine hashes). The
  census and every measurement above are law7.bin's.
* Drivers resolve paths from the checkout; the binaries' directory ($B) and scratch root ($S) come from the caller.

## 10. Residues, ranked

1. FuncStructVal d/t: #4782 the read-site leftover (N2472 / N2473), then N0980 / N1946 and ground B's N0891 (section 8).
2. N0003's remaining records (the module listing's leftover copies, typespec-copy family, TypeEmit) and its four unreached
   cases (m4 a2: a module listing's pattern reference; v5 v6: the interface port view).
3. The spaced forward reference `p2 :: E1` (golden ends at the `::` token; ours has no token geometry in the drain) and
   the stage-1 forward shapes: ours folds a forward `p2::K` (and keeps a nested pattern) where golden keeps the
   unresolved reference (FW fw02-fw04, fw08-fw11, fw16, fw17, fw20, fw21; the exporter's fold, ExprEmit / ParamEmit).
4. The `--elabuhdm` half of the `new[...]` part-select names (section 8).
5. Brief items not reached: struct_param_func_config N0675 / N2412, cfg_func_width_loop N0025 N0033 N0754 N0794,
   BlackBePipeInt #15268 / #15272 (the ExprEval pattern branch), N0131, Earlgrey N0812 family, N0039's writer; pass 224's
   residues sx11 (macro-born backtick literal), the lvalue select with a trailing part-select index (G/g26, T/t35),
   ld02, ib01_el, C/c21 c22, SP sp19, K/k09, HN hn10, TP tp12; N0008; the value encodings; map 13's N0739 N1903 N1904
   N0476 N0477; the `[N]` bound (section 8).
6. Scoreboard d's svunit listing-order coin (2 hashes in 16 draws; not this loop).

## 11. Files

* `drivers/`: env.sh case.sh run1.sh grid.sh switches.sh dumpdelta.sh rowdelta.sh census.sh dscensus.py predict.py
  bvmirror.sh awayrows.py uvmdist.sh det.sh (copied from r11u224repro, headers say so; predict.py reads the id-order
  trace), det16.sh and reach227.sh (new).
* `cases/`: FW (§ fwdPkgRefClassScopeSpan227), PL (§ pkgPatFuncBodyLeftoverNoParent227), NP (§ newArrayPartSelStripped227);
  the first line of each dut.sv names its law (fw15 also carries defs.svh).
* `evidence/`: sweeps/ (both sweeps' logs, csvs, canaries), census/ (the frozen prediction and its stamp), movers/,
  away/, det/, reach/, grid_law7.tsv, grid_away_law7.txt, switch_reach.txt, uvmdist.txt.
