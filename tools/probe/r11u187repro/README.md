# r11u187 — the expression/parameter ground: the r11u183 decode's ground-A laws landed and re-verified (seven of eight; one measured redundant), and the trailing select's index named through calls and selects; 2 row-modes and 10 probe cases converted

Implementer pass (pair A, refill after pass 184). Base `44393367` (branch matrix-1.87). Ground: `src/ExprEmit.cpp`,
`src/ParamEmit.cpp`, `src/StmtEmit.cpp` (`src/EmitHelpers.h` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`,
`UhdmExporter.cpp`, `TaskFuncEmit.cpp`, `uhdm_main.cpp`, `include/`, `results/`, `third_party/`, or `tests/` other than
the regenerated law index (`tests/LAWS.md`). Net binding is not touched. Every law of passes 140-184 and every
refinement stays as landed; the new code is new sites under their own switches. The sister pass r11u186 (module/type
ground) had not landed at the end of this pass; the tenth map r11u189 had not landed either, so the brief's item (3)
stood. Worktree `/tmp/wt_r11u187`, system-deps config, `-j 2` (`-j 1` whenever less than 6 GB was free).

## Result

| axis | base (committed = pristine sweep `swP`) | final law (`swG`, law4.bin) | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL, default + testflags) | 456 + 452 | **457 + 453** | **+2** (ArrayMethodIterator d/t) |
| uhdm2rtlil strict-equal (of 1606) | 787 + 787 | 787 + 787 | 0 (jeras_union d/t CHANGE, fullname 75 -> 15) |
| probe EQUAL (of 4087) | 2898 | **2908** | **+10** |
| judge-equal scoreboards (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same | `downstream.csv` byte-identical to swP's |

**CONVERSIONS (surelog corpus; results/ untouched).** Fresh rows of the final law sweep (`/tmp/r11u187_swG/surelog.csv`):

    ArrayMethodIterator,default,CMP_EQUAL,,,equal      was differ:endcol(1)   § withClauseCloseParenEnd183
    ArrayMethodIterator,testflags,CMP_EQUAL,,,equal    was differ:endcol(1)   § withClauseCloseParenEnd183

(pass 180 landed the type-parameter half on the sister ground, so this row converts with ground A alone at this base;
with `R11U183_PATHSPAN_OFF=1` it reads `differ:endcol(1)` again.)

**Probe CONVERSIONS (10):** `r10uvm57repro/b2_shape`, `r10uvm57repro/v1_prodcell`, `r10uvm80repro/c2_autokinds`,
`r10uvm80repro/v5_edges80` (§ blockSizeDimEndsAtExpr183 / § withClauseCloseParenEnd183), `r10uvm153repro/g153_a_mech`,
`r10uvm88repro/g88_a2_bound`, `r10v152repro/v152_e_pos` (§ defCloneRefsBindDefListing183), `r10earl29repro/v5_gen`,
`r10earl29repro/v6_genvar`, `r10earl29repro/v7_lval` (§ trailIdxCallArgNamesByPath187 / § trailIdxSelNamesByPath187).

## Binaries (frozen `chmod 555` in `/tmp/r11u187_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `948f24885e7b03e37e1451b8c8152303` | the worktree build of `44393367`, byte-identical to the main tree's `build/slang-uhdm` |
| `lawA0.bin` | `8865c0e64fa7e682f02fc068d7bc8e64` | base + `tools/probe/r11u183dec/law_exprstmt.patch` (3-way, clean), i.e. item (0) alone (sweep `swA`) |
| `law2.bin` | `4f70a51b7c46a6866c02918d2ad4c967` | lawA0 + § trailIdxCallArgNamesByPath187 / § trailIdxSelNamesByPath187 (the final firing census) |
| `law3.bin` | `9b0d428fe8393a471efc7c762173675f` | law2 + `R11U187_OFF` also dropping the r11u183 laws (sweep `swF`) |
| `law4.bin` | `515bf9a120cb976747a20f88cde3d662` | law3 without law paramAggTdLastWriter183 (section 2): THE DELIVERED SOURCES, final gate sweep `swG` |
| `compAB.bin` | `b0c1f77725aa248c28af375eb77b0eeb` | measurement only: lawA0 + the sister's `law_typeemit.patch` (section 3) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

`/tmp/r11u187.patch` applied to a FRESH `44393367` worktree (`git apply --check` clean; whitespace warnings only, in
evidence text) builds to `515bf9a120cb976747a20f88cde3d662`, byte-identical to `law4.bin`, and reads `law index current`.

Every sweep's `cmds.txt` names its own binary on all 3273 `slang:` lines (`/tmp/r11u187_swP`, `_swA`, `_swF`, `_swG`;
same-length workdir names).

**The fence.** No fenced test is named in this directory. `drivers/env.sh` reads the four names from
`tools/probe/r11u107repro/canaudit.sh`'s `FENCED=` line and refuses to run without four; `drivers/census.sh` (the firing
census = the mover prediction) runs `verify_golden.py` / `check_probe.py` with `--filter` built from `$FENCED` (word
boundary, fail closed; 3265 `slang:` lines, none fenced); `drivers/rows.sh` refuses a regex that matches any fenced name;
`drivers/bvmirror.sh` hard-links the corpus databases leaving the 8 fenced row-mode databases out; `grid.sh`, `head.sh`,
`chgcheck.py`, `offcheck.sh`, `switchmatrix.sh`, `probemovers.sh` refuse a fenced path. No gdb run. The predicted-mover
files and every evidence file grep 0 for each fenced name.

## 1. Item (0): the r11u183 ground-A laws, rebased and re-verified

`law_exprstmt.patch` (written at `80a1c2af`) applies to `44393367` with `git apply --3way` cleanly in all three files
(passes 178, 181, 184 moved its context only). Its trace (`R11U183_TRACE=<dir>`) and switches are kept as written.

| law | site (file, § token) | switch | at 44393367 |
|---|---|---|---|
| § aliasFoldBoundFile183 | ParamEmit.cpp `emitPackage` | `R11U183_RANGEFILE_OFF` | landed; the fold's file (jeras_union fullname 75 -> 15) |
| § foreachAssocLoopVarIdxTs183 (its A half) | StmtEmit.cpp foreach branch | `R11U183_FEIDX_OFF` (+ `R11U183_TSSPAN_OFF`) | landed; INERT alone (needs the B registration), measured composed (section 3) |
| paramAggTdLastWriter183 | (ParamEmit.cpp `makeParamTs`) | (`R11U183_PARAMAGG_OFF`) | **NOT landed: redundant** (section 2) |
| § blockSizeDimEndsAtExpr183 | StmtEmit.cpp block-item array | `R11U183_IFARR_OFF` | landed |
| § macroIfacePathTokSpans183 | ExprEmit.cpp interface-path branches | `R11U183_PATHSPAN_OFF` | landed (Rggen moves toward) |
| § withClauseCloseParenEnd183 | ExprEmit.cpp array-method span | `R11U183_PATHSPAN_OFF` | landed; **ArrayMethodIterator d/t convert** |
| § cloneLoopVarHomeObject183 | StmtEmit.cpp `cloneLoopVarShared37` mint | `R11U183_CLONELV_OFF` / `R11U183_UVMCOPY_OFF` | landed |
| § defCloneRefsBindDefListing183 | ParamEmit.cpp `emitPackageClassMethodClones` | `R11U183_DEPTH_OFF` | landed; ApbSlave `depth(1) -> file(4)` |

`R11U183_OFF=1` drops the seven, and `R11U187_OFF=1` drops the seven and this pass's two (one switch restores the
pristine bytes: section 6).

**Re-verification on the r11u183 grid** (`tools/probe/r11u183dec/cases`, 147 cases, both views,
`evidence/grid_r11u183cases_lawA0_{default,elab}.txt`, and with the final binary `evidence/grid_r11u183cases_final.txt`):
every case keeps its r11u183 "A alone" verdict class except 11 whose PRISTINE verdict already moved at this base (a/c16,
b/t01-t03, b/t05-t07, e/p01, e/p02, e/p06 read EQUAL at pristine now: passes 180 and 184; b/s01 reads `type` at pristine
now: pass 180); 0 case-modes move away from golden (order-blind record distance: 30 TOWARD, 260 SAME, 0 AWAY, 4 without
a database).

**Fresh cases, 2-6 per law** (`cases/A`, `C`, `E`, `G`, `H`, each naming its law in its first line; both views;
`evidence/grid_fresh_lawA0.txt`, final `evidence/grid_final.txt`):

| law | cases | result (both views) |
|---|---|---|
| § aliasFoldBoundFile183 | A/a01 (literal bound, stage 1 at pristine), a02 (the package in an INCLUDED file), a03 (a `W-1` bound), a04 (a module variable) | a02 44 file records leave (the include's file kept), a03 / a04 the same; every one keeps the sister's fullname head (N0938); a01 unchanged |
| § blockSizeDimEndsAtExpr183 | C/c01 (`int q[N]` in a task block), c02 (`[2*2]` in a named always block), c03 (two size dimensions), c04 (control: `[0:3]`), c05 (spaces in the brackets), c06 (with a `$root` target: § rootLvalueSpanAtRoot184) | c03 c05 c06 convert; c01 c02 stage 1, TOWARD; c04 unchanged |
| § macroIfacePathTokSpans183 | E/e01 (with a call index: § hpIdxCallNameSpan184), e02 (a parenthesized index: § memberSelParenIdxSpan184), e03 (rvalue in the macro), e04 (a generate loop in the macro), e05 (the macro from an INCLUDED file), e06 (the whole path in the body), e07 (a procedural lvalue) | e05 e06 e07 convert; e04 8 records leave; e01 e02 stage 1 TOWARD (the compositions); e03 fires with identical bytes (an rvalue: the lvalue-only gates below the law decline) |
| § withClauseCloseParenEnd183 | E/w01 (`find with` without an argument list: no fire), w02 (`sum() with ( ... )`), w03 (the clause over three lines), w04 (a class iterator) | w02 w03 lose the endcol record (next head the folded call, `type`); w01 w04 unchanged |
| § cloneLoopVarHomeObject183 | G/g01 (`n[i]++` in the clone), g02 (`int m[string]`), g03 (a part select of the loop element), g04 (`foreach (s.f[i])`), g05 (a second-level importer), g06 (`st.cnt[i]++`: § incDecMemberSelIsLvalue184), g07 (a generate-scope caller) | g02 g05 convert; every other TOWARD (g03's next head: the part select named `q.q` where golden reads `q::q`, a residue) |
| § defCloneRefsBindDefListing183 | H/h01 (an int read), h02 (an enum variable and an enum PARAMETER: § tpEnumCopyAtTypedef184), h03 (in-body method, two variables), h04 (a module also writing the variable), h05 (an in-body method and a module read) | h01 converts; h04 `depth -> endcol` (the sister's § importNetTsToInitEnd183 face); h02 h03 h05 unchanged |

**Rows at this base, ground A alone (sweep `swA`).** CONVERTED ArrayMethodIterator d/t. CHANGED ApbSlave d/t
`depth(1) -> file(4)` (walk no longer diverges; order-blind 12 -> 8; the 4 are the sister's § classPropElemClassTsAtType183
class_typespec records and § importNetTsToInitEnd183's `string_typespec` 29:9-29:92), jeras_union d/t `fullname(75) ->
fullname(15)` (order-blind 120 -> 0; the 15 are the sister's § aliasOfTdSharedKeepsModName183 names), MiniAmiq d/t
`fullname(6) -> fullname(28)`, SeqDriver d/t `fullname(5) -> fullname(27)`, SimpleUVM d/t and Scoreboard d
`fullname(21) -> fullname(55)`: the first record is the SAME object at the same walk index in both sweeps (MiniAmiq
`#770 ref_typespec <in>uvm_reg_byte_en_t`, SimpleUVM `#458 ref_typespec UVM_MACRO_NUMFLAGS` / ours
`uvm_pkg::UVM_MACRO_NUMFLAGS`); the count grows because the index-aligned walk diverges later (MiniAmiq record 2450 ->
10107, SeqDriver 2433 -> 10090, SimpleUVM 2484 -> 10177, Scoreboard 2492 -> 10185) while the order-blind distance falls
(MiniAmiq 26545 -> 21618, SeqDriver 19475 -> 16188, SimpleUVM 6932 -> 6901, Scoreboard 5592 -> 5559):
`evidence/sweeps/changes_swA_vs_swP.txt` (`drivers/chgcheck.py`).

## 2. law paramAggTdLastWriter183 is redundant at this base (not landed)

It fires (its trace fires only when it changes a location) on const_cast_signext, struct_param_func_config,
struct_param_pattern_packing (u2r, both modes), `tests/probe/r11u14repro/c10`, r11u183 grid b/s01 b/s04, fresh B/b01-b03
and r11v178 `pu/u01_formal_shadow`, and moves 0 bytes on every one (sweep `swA` byteverify, grids). Cause, measured:
pass 180's § modAggTfArgCloneFollows180 (TypeEmit.cpp, `R11U180_MODAGGCLONE_OFF`) already gives the copy the relocated
typedef's span. With `R11U180_MODAGGCLONE_OFF=1` the r11u183 law does the same job (s01 and b03: `line` with the law
dropped, `type` with it), with pass 180's law on it adds nothing. Two laws on one field would leave
`R11U180_MODAGGCLONE_OFF` unable to restore its own bytes, so the law is not landed (the ParamEmit site carries a note).
Removing it is byte-neutral: law3 (with it) and law4 (without) write identical databases on all seven databases where it
fired, and it modifies nothing where it does not fire. Fresh cases `B/b01-b04` name the landed law instead.

## 3. Composition with the sister's ground-B patch (`r11u183dec/law_typeemit.patch`; measurement only)

Pass 186 had not landed. To say which rows wait for it, `law_typeemit.patch` was applied 3-way to a scratch worktree of
`44393367` (one UhdmExporter.cpp hunk merged by hand beside § classTpDefaultTsAtUse180) with the ground-A patch, and
built (`compAB.bin`). `evidence/composition_with_sister_patch.txt`:

| row-mode | ground A alone (this pass) | A + sister's B | drop one A law in the composition |
|---|---|---|---|
| ArrayMethodIterator d/t | **CMP_EQUAL** | CMP_EQUAL | `R11U183_PATHSPAN_OFF`: `endcol(1)` |
| ApbSlave d/t | `file(4)` | **CMP_EQUAL** | `R11U183_DEPTH_OFF`: `depth(1)` |
| jeras_union d/t | `fullname(15)` | **CMP_EQUAL** | `R11U183_RANGEFILE_OFF`: `file(60)` |
| ParameterFromPkgInNestedModule d/t, ParameterFromPkgOnParameterPortList d/t | `fullname(7)` | **CMP_EQUAL** | (ground B's laws alone) |
| SVSwitch d/t | `file(15)` | `fullname(13)` | |
| const_cast_signext d/t, struct_param_func_config d/t | `type(1)`, `fullname(5)` | same | |

So ApbSlave, jeras_union and the two ParameterFromPkg rows (8 row-modes) wait for pass 186, and ApbSlave and
jeras_union need this pass's A laws with it. § foreachAssocLoopVarIdxTs183's A half is inert alone; composed, it is
needed on 7 of the 8 r11u183 `d/` cases (f01 f02 f06 f09 f10 f13 f14 convert composed and read `file` / `col` with
`R11U183_FEIDX_OFF`; f11 converts on B alone).

## 4. New laws: the trailing select's index named through calls and selects

**Heads.** r11u184's residue R4 (`s.g[i[1:0]]` in a generate scope, `m.q[f(k)]`): the objects inside the index of a
path's TRAILING bit select, below a call or a select. Golden `work@top.m.q.q.k` for the argument of `m.q[f(k)]`, ours
`work@top.k`; golden `work@top.ga.gb.s.g.g.i` for the part select of `s.g[i[1:0]]`, ours `work@top.ga.gb.i`.

**Decode.** Surelog stores no full name on the objects of that index, so UHDM's `BaseClass::ComputeFullName`
(`third_party/Surelog/third_party/UHDM/templates/BaseClass.cpp`, the name loop) derives each from its parent chain: a
`func_call` / `sys_func_call` / `method_func_call` contributes no name, a `bit_select` or `indexed_part_select` is
skipped above a `ref_obj` and kept above anything else, a `part_select` is kept, an operation has no name, the
`hier_path` contributes its own name. So `m.q[f(k) - 1]` gives `work@top.m.w[ - 1].w.k` (the path's own name, the call
decompiled empty), the lvalue `m.q[f(k)] <= 1` gives `work@top.m.q[].q.k`, `s.f[i[j]]` gives `work@top.s.f.f.i` for the
inner bit select and `work@top.s.f.f.j` for its index, and in a class method the package separator (`p::c::get::m.q::q::k`).
The `ref_typespec` golden hangs on a call argument (the formal's typespec: pass 184's R2) derives the same name. §
hpTrailSelIdxNamesByPath133 is exactly this rule for references directly under the select or under operations; it stopped
at calls and selects.

**Laws** (ExprEmit.cpp `trailIdxNestedNames187`, called from `trailSelIdxNames133`, i.e. at both of § 133's sites and
under the same context gates):

- § trailIdxCallArgNamesByPath187 (`R11U187_TRAILCALL_OFF`): below a call, every reference is named
  `<path>.<select>.<name>` (the call is skipped), its own `ref_typespec` too.
- § trailIdxSelNamesByPath187 (`R11U187_TRAILSEL_OFF`): a bit / part / indexed part select inside the index is named
  `<path>.<select>.<name>`; below it a reference skips a bit / indexed part select and not a part select.
- A path NESTED in another path's (or select's) index derives its names through the OUTER chain in golden
  (`r = n.w[m.q[f(k)]]`: `work@top.n.w.w.m.q.q.k`, T/t16), which neither § 133 nor this law carries (pass 178's residue
  h09): the law declines when the path's parent chain reaches a select or path through operations and calls. The first
  draft (law1) renamed there (wrong to wrong, order-blind SAME on t16); the decline was added before any sweep.
- A select's name is set without being read: the UHDM getter freezes a lazily computed name at the read, and the chain
  above the path is not final at this point of the emission.

**Grid** (`cases/T`, 19 cases x both views = 38 case-modes, `evidence/grid_final.txt`): t01 (calls, an operation over a
call, a nested call, `$clog2`), t02 (continuous assignments, the argument's ref_typespec), t03 (a process lvalue), t04
(generate scopes one and two levels down), t05 (a part / bit / indexed part select as the index), t06 (a part select in a
two-level generate scope), t07 (a class method), t18 (a macro-born path), t19 (a package-qualified call) convert in both
views (18 case-modes); t09 (inc/dec with a call index, nested paths), t12 (inc/dec, unary and call indices), t14
(streaming operands), t15 (continuous assignments one and two generate levels down) are stage 1 at pristine and move
TOWARD; t08 (an interface path: § ifaceMemberTrailIdxNamesByPath147's builder, not reached), t16 (nested paths: declined),
t17 (calls as part-select bounds: control) do not move; t10 (a non-trailing select), t11 (direct index references and
their typespecs), t13 (`this.` and `super.` paths) are EQUAL controls and stay EQUAL. Also converted: r11u184 `C/c01` and
`G/g01` (the residue's own cases), r11v184 `C/vc06_trailing_after_member` (both views).

**Boundary** (`evidence/boundary_law2.txt`): every case of r11u184repro, r11v184repro, r11u181repro, r11v181repro,
r11u178repro, r11v178repro, r11u133repro, r11u140repro, r11u147repro (598 cases x both views = 1196 case-modes), pristine
vs law2: 8 case-modes move, all this law's, all TOWARD (6 convert: r11u184 C/c01, G/g01, r11v184 C/vc06, both views; r11v184
C/vc01 stage 1 TOWARD); the r11u183 laws move none of them.

## 5. Gates (final binary `law4.bin`, sweep `swG`; `evidence/sweeps/`)

| stage | pristine `swP` | (0) alone `swA` | final `swG` |
|---|---|---|---|
| probe vs golden_probe.csv | reg 0 conv 0 chg 0 (EQUAL 2898) | reg 0 conv 7 chg 13 (EQUAL 2905) | **reg 0 conv 10 chg 19 (EQUAL 2908)** |
| surelog vs golden_surelog.csv | reg 0 conv 0 chg 0 | reg 0 conv 2 chg 9 | **reg 0 conv 2 chg 9** |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | reg 0 conv 0 chg 0 | reg 0 conv 0 chg 2 | **reg 0 conv 0 chg 2** |
| downstream (871) | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, csv byte-identical | **803 / 66 / 2 / 0, csv byte-identical** |

`only-fresh=0 only-committed=0` everywhere. swP, swA and swF exit 1 only for `law index STALE` (the worktree's sources
carried unlanded laws); swG runs with this patch's regenerated `tests/LAWS.md` (SWEEPRC in `evidence/sweeps/sweep_swG.log`).

**Every CHANGE and CONVERSION judged** (`drivers/chgcheck.py`: the first record, where the index-aligned walk diverges,
and the order-blind record distance to golden; `evidence/sweeps/changes_swG_vs_swP.txt`): all TOWARD, none SAME, none
AWAY. The probe changes: § trailIdx...187 `r10earl29repro/a1_hp2`, `a2_hp1`, `b2_kinds`, `b3_edges`, `v8_sites2`,
`r10uvm92repro/v92_b2_varsel` (fullname / file counts fall); the r11u183 laws `r10uvm151repro/g151_a_body`,
`g151_e_ctx`, `r10v151repro/v151_5_ctx` (file), `r10uvm37repro/t51a`, `r10v181repro/v181_e_idxbase`, `v181_f_mixed`,
`r11u111repro/grid/f1/a10_q_chain`, `v11u110repro/brk/v6/s01_single_chain2_ctl`, `v11u111repro/brk/f6/x65_chain_td_dims`
(fullname counts fall), `r10uvm21repro/t32d_t` (`fullname -> type`, 66 -> 26), `r10v181repro/v181_h_nofe` (`depth ->
fullname`, walk divergence 110 -> 438), `r10v208repro/v208_f_io` (`fullname -> name`, 132 -> 36, divergence 158 ->
never), `r10uvm193repro/g193_c_argface` (`fullname(3) -> fullname(102)`: same first field, walk divergence 443 -> 2781,
order-blind 260 -> 235). uhdm-cmp reads 0 lines on every corpus mover (`evidence/sweeps/uhdmcmp_movers.txt`) and every
probe case reads EQUAL or STRICT_NOTEQUAL (no NOT_EQUAL).

**Byte movers, predicted by name first.** The firing census (`drivers/census.sh` with the law binary and both traces;
`drivers/censum.py`) was frozen (`chmod 444`) before each law sweep: `evidence/predicted_movers_A0.txt` (lawA0: 22 corpus
row-modes, 85 probe databases) before `swA`, `evidence/predicted_movers_final.txt` (law2: 22 corpus row-modes, 94 probe
databases) before `swF` / `swG`. Corpus (`byteverify.sh` SELFCHECK on fence-free mirrors, 2560 databases, 8 fenced
skipped, self-check 2559 / 2560; `evidence/sweeps/byteverify_corpus_swG.txt`): **17 movers, 16 predicted**: ApbSlave d/t,
ArrayMethodIterator d/t, BuildUVMPkg d/t, MiniAmiq d/t, Rggen d, Scoreboard d, SeqDriver d/t, SimpleUVM d/t (surelog),
jeras_union d/t (uhdm2rtlil); the status-silent ones move TOWARD (Rggen 17193 -> 12313, § macroIfacePathTokSpans183;
BuildUVMPkg d/t 3261 -> 3236). The one NOT predicted is **Earlgrey_0_1 testflags**, the known Earlgrey draw: no law of
this pass fires on it (census), the pristine and final databases read `STRICT_EQUAL 1342870 objects` against EACH OTHER
(uhdm-strictcmp with the pristine one as the reference: every compared field of every object in walk order identical,
the two record dumps byte-identical), its row keeps `differ:col(102)`, uhdm-cmp 0 lines; its hash follows the binary
build (pristine and lawA0 `99fc8d82`, law2 / law3 / law4 `76f319c5`), and its default twin drew a different hash in
the law3 sweep (`swF`) than in the law4 sweep (`swG`, equal to pristine) from identical sources for that row. Predicted
and not moved: const_cast_signext, struct_param_func_config, struct_param_pattern_packing d/t (paramAggTdLastWriter183,
section 2). Probe (`drivers/probemovers.sh`, `evidence/sweeps/probemovers_swG.txt`): **swA 23 / swG 32 movers, all predicted**, 0 moved-not-predicted; the
predicted-not-moved are § defCloneRefsBindDefListing183 firings whose clones read no remapped variable (61) and the
redundant law (1); the byte movers without a status change (r10uvm208repro/g208_e_head, r10v148repro/v148_d_kind,
r10v204repro/v204_s_shadow) are TOWARD (127 -> 59, 7 -> 4, 126 -> 94). Downstream slang lane (805 databases, SELFCHECK
804 / 805): **1 mover, jeras_union** (predicted from its corpus twin), verdict IDENTICAL.

**Canaries** (`evidence/sweeps/canaries.txt`): `canaries.sh` surelog ok=45 changed=7 (exactly ApbSlave d/t, SimpleUVM
d/t, SeqDriver d/t, Scoreboard d), uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS,
`EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS.

## 6. Switches

| switch | law |
|---|---|
| `R11U183_RANGEFILE_OFF` | § aliasFoldBoundFile183 |
| `R11U183_TSSPAN_OFF`, `R11U183_FEIDX_OFF` | § foreachAssocLoopVarIdxTs183 |
| `R11U183_IFARR_OFF` | § blockSizeDimEndsAtExpr183 |
| `R11U183_PATHSPAN_OFF` | § macroIfacePathTokSpans183, § withClauseCloseParenEnd183 |
| `R11U183_UVMCOPY_OFF`, `R11U183_CLONELV_OFF` | § cloneLoopVarHomeObject183 |
| `R11U183_DEPTH_OFF` | § defCloneRefsBindDefListing183 |
| `R11U183_OFF` | every r11u183 law |
| `R11U187_TRAILCALL_OFF` | § trailIdxCallArgNamesByPath187 |
| `R11U187_TRAILSEL_OFF` | § trailIdxSelNamesByPath187 |
| `R11U187_OFF` | every law of this pass, the landed r11u183 laws included |

`R11U183_TRACE=<dir>` / `R11U187_TRACE=<dir>`: one file per process (`<dir>/<pid>.<unit>`), first line `OUT <-o path>`,
then one law name per firing, on every branch that changes a field. `evidence/switch_all_off.txt`
(`drivers/offcheck.sh`): `R11U187_OFF=1` alone on the final binary writes the pristine bytes on every tests/probe case,
every case here and every r11u183 case (the two both-fail cases are slang failures on both binaries; positive control: the
same case with the laws on differs). `evidence/switch_matrix.txt` (`drivers/switchmatrix.sh`): per switch and case, the
law binary with the switch writes the pristine bytes where only its laws fire and the law bytes where none of them
fires; the only BAD rows are the two slang-failure cases (no database on either binary).

## 7. The brief's items, before -> after

| item | before | after | note |
|---|---|---|---|
| (0) ArrayMethodIterator d/t | endcol(1) | **CMP_EQUAL** | § withClauseCloseParenEnd183 |
| (0) ApbSlave d/t | depth(1) | file(4) | CMP_EQUAL composed with pass 186 (section 3) |
| (0) jeras_union d/t | fullname(75) | fullname(15) | CMP_EQUAL composed with pass 186 |
| (0) ParameterFromPkgInNestedModule / OnParameterPortList d/t | fullname(7) | same | ground B's laws alone convert them (composition) |
| (0) probe | | +7 | § blockSizeDimEndsAtExpr183, § withClauseCloseParenEnd183, § defCloneRefsBindDefListing183 |
| (1) index names under trailing selects (r11u184 R4) | | **fixed** | § trailIdxCallArgNamesByPath187, § trailIdxSelNamesByPath187 (+3 probe, 184 C/c01 G/g01) |
| (2) const_cast_signext d/t type(1) | | decoded, sister ground | R2 below |
| (3) arb_idx_cast endcol(17) | | first record decoded, sister ground | R3 below |
| (3) FuncStructVal endcol(95)/(165) | | first record decoded, no gate | R5 below |
| (1)-(4) the other rows | as baseline | same | not reached this pass (heads in section 8) |

## 8. Residues, ranked (this ground), and sister-ground faces

R1. **The rows that wait for pass 186** (8 row-modes, section 3): ApbSlave d/t (§ classPropElemClassTsAtType183 in
UhdmExporter.cpp `classElemVar`, § importNetTsToInitEnd183 in ModuleEmit.cpp `emitImportedPkgVarNets`), jeras_union d/t
(§ aliasOfTdSharedKeepsModName183, ModuleEmit.cpp `emitImportArtifacts`), ParameterFromPkg x2 d/t (§ pkgParamFoldOwnTs183,
§ pkgParamElabCaSharesDefFold183, ModuleEmit.cpp). Contract for the sister: land them with this pass's A laws on; the
composition converts all 8 and ArrayMethodIterator stays converted.

R2. **const_cast_signext d/t type(1)** (sister ground: ModuleEmit.cpp `emitContAssigns`, the fold decision beside §
evalFuncSelectKeepsCall148 and `constCallFold`). Decoded on `evidence/residue/constfold` (m1-m8, golden and ours): golden
keeps the DEFINITION's cont_assign object (and its func_call) in the elaborated module whenever `ExprEval::evalFunc`
cannot reduce the body to a constant: a member read of a struct-typed FORMAL (`g = op.f`, `$signed(op.f)`,
`imm_t'(op.f)`, `{op.f}`: m1-m4), a typedef cast of `$signed` (m5), a typedef RETURN type with arguments (m7); it folds
`32'(x)` (m8, EQUAL on both). Ours folds all of m1-m5, m7 to a constant. Contract: extend § evalFuncSelectKeepsCall148's
poison set with these three shapes.

R3. **arb_idx_cast d/t endcol(17)**, first record (sister ground: TypeEmit.cpp `emitTypeParamArrayVar`, its `mkB`):
the folded packed bound of a TYPE-PARAMETER-typed variable (`idx_t [2**N-2:0] nodes`) is anchored at the leftmost leaf
(`2`, 2:10-2:11) where golden spans the top operation's LEFT OPERAND whole (`2**N`, 2:10-2:14); a `logic [2**N-2:0]`
variable is already right (`evidence/residue/tpbound/x1`). The next records (14 `ref_typespec` full names in the
generate scope, `req_nodes`) are not decoded.

R4. **A path nested in another path's index** (pass 178's h09, T/t16 here): golden derives the inner path's index names
through the OUTER chain (`work@top.n.w.w.m.q.q.k`, `work@top.n.w.w.m.q[k].k`); § hpTrailSelIdxNamesByPath133 and this
pass's law use the scope (133 writes `work@top.m.q[k].k`; this law declines). Site: ExprEmit.cpp `trailSelIdxNames133`
(the base would have to carry the outer path's name and its select, known only after the outer path is complete).

R5. **FuncStructVal d/t endcol(95)/(165)**, first record: `config_pkg::NOC_TYPE_AXI4_ATOP` as a member value of a
package parameter's pattern, where `config_pkg` is declared LATER in the file: golden spans the package qualifier alone
(106:16-106:28), ours the whole name (106:16-106:46). Every small case of the shape is judge-unequal (golden keeps an
unresolved `ref_obj`, ours folds the constant: `evidence/residue/pkgfwd` q2, q6), so no grid can gate a law.

R6. **§ cloneLoopVarHomeObject183's next face** (G/g03): the part select of the loop element in the clone
(`q[i][1:0]`) is named `s::lsb::q.q` where golden reads `s::lsb::q::q` (the package separator on the select's own
name); StmtEmit / ExprEmit part-select naming in package clones.

R7. **The trailing select of an interface path with a call index** (T/t08, stage 1 at pristine) and **calls as
part-select bounds** (T/t17, stage 1): not reached.

R8. Carried unchanged (heads at this base, ground A alone): StructParamPatternInitCast d/t fullname(3) (`#414
ref_typespec` golden unnamed, ours `work@StructParamPatternInitCast`), iface_zero_width_field d/t fullname(3)
(`<in>p::bus_t.CTL` names), rsp_gen_minimal d/t fullname(2) (`ref_typespec` golden `work@dut.u_rsp_gen.data_i`, ours
`work@dut`, then a depth divergence), OutputSizeWithParameterOfInstanceInitializedByStructMember d/t line(8) (the
`Info.x` hier_path golden 17:11-17:26 / 4:18-4:23, ours 15:37-15:43), ibex_pmp d/t file(5) (the package parameter and
the import-parameter copy swap their listing objects: pass 176's residue 2), ibex_icache d/t fullname(49),
InterfArrayBind d fullname(3) (`io_idx` named through `peripheral_io_bus[io_idx].write_en`: the elaborated-view flag
only ModuleEmit has), FuncStructValSimple d/t file(39)/(59) (the INT:2 constant-function leftovers, pass 184's R1),
Scr1SvTests d/t type(1), the UVM first records (MiniAmiq `<in>uvm_reg_byte_en_t`, SimpleUVM `UVM_MACRO_NUMFLAGS`), the
Assert rows (property_decl full names by the elaborated instance: ModuleEmit).

## 9. Files

- `cases/`: `A` § aliasFoldBoundFile183 (a01-a04), `B` the redundant law's cases naming § modAggTfArgCloneFollows180
  (b01-b03; b04 control), `C` § blockSizeDimEndsAtExpr183 (c01-c06; c04 control; c06 with § rootLvalueSpanAtRoot184),
  `E` § macroIfacePathTokSpans183 (e01-e07; e01 with § hpIdxCallNameSpan184, e02 with § memberSelParenIdxSpan184) and §
  withClauseCloseParenEnd183 (w01-w04), `G` § cloneLoopVarHomeObject183 (g01-g07; g01 g06 with §
  incDecMemberSelIsLvalue184), `H` § defCloneRefsBindDefListing183 (h01-h05; h02 with § tpEnumCopyAtTypedef184), `T` §
  trailIdxCallArgNamesByPath187 (t01-t04, t07-t19; t10 t11 t13 t17 controls) and § trailIdxSelNamesByPath187 (t05, t06).
- `drivers/`: `env.sh` (pins, `$FENCED`), `grid.sh` / `gridcmp.sh` (golden + ours + uhdm-cmp + strictcmp per case, both
  views; record movement `recmv.py`, order-blind `obdist.py`, the laws that fired), `rows.sh` / `head.sh` (named corpus
  rows and their strict records), `census.sh` + `censum.py` (the firing census = the prediction), `bvmirror.sh`,
  `probemovers.sh`, `chgcheck.py` (every change judged), `offcheck.sh`, `switchmatrix.sh`, `obrows.sh`, `rowrec.sh`.
- `evidence/`: the predictions, the grids (`grid_final.txt`, `grid_fresh_lawA0.txt`, `grid_r11u183cases_*.txt`),
  `boundary_law2.txt`, `composition_with_sister_patch.txt`, `switch_all_off*.txt`, `switch_matrix.txt`, `residue/`
  (constfold, pkgfwd, tpbound), `sweeps/` (sweep logs, byteverify, probe movers, changes, canaries, uhdm-cmp on movers).
