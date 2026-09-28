# r11u206: the module/type ground, pair B (refill after pass 202): arb_idx_cast converts (a generate-scope cast and an unpacked element bind the definition's default type-parameter object), the $unit class-typedef end written by interface and program variables, returns typed by another class's typedef, generate-scope class variables

Base `3668bf30` (branch matrix-1.87, pass 201). Files of the ground touched: `src/UhdmExporter.cpp`,
`src/ModuleEmit.cpp`, `src/TaskFuncEmit.cpp` (`src/TypeEmit.cpp` and `uhdm_main.cpp` needed nothing). No line of the
sister's files (`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`), of `include/`,
`scripts/`, `results/`, `tests/probe/` or `third_party/` is edited; `tests/LAWS.md` is regenerated
(`python3 scripts/law_index.py`, run last). `tools/probe/r11u205dec` had not landed when this pass started, so
question (0) does not apply; the live r11u205 worktrees were not touched.

**Verdicts per targeted row** (fresh csv rows of the law sweep `/tmp/r11u206_sL`; `results/` untouched):

| row-mode | base (`results/` = the pristine sweep) | after | laws |
|---|---|---|---|
| **arb_idx_cast default (uhdm2rtlil)** | `STRICT_NOTEQUAL differ:endline(2)` | **`arb_idx_cast,default,CMP_EQUAL,,,equal`** | § tpCastUseBindsDefDefault206 |
| **arb_idx_cast testflags (uhdm2rtlil)** | `STRICT_NOTEQUAL differ:endline(2)` | **`arb_idx_cast,testflags,CMP_EQUAL,,,equal`** | § tpCastUseBindsDefDefault206 |
| UnitElabBlock d/t | `differ:file(2)` / `file(1)` | unchanged | the one face left is ExprEmit's (section 7, sister call site) |
| Scr1SvTests d/t | `differ:type(1)` | unchanged | the Surelog binding defect of map 12 section 8a (no law possible) |
| InterfaceStructMemberPort d/t | `differ:fullname(6)` | unchanged | decoded further, structural (section 7, R3) |
| HierPathTypespec t | `differ:fullname(1)` | unchanged | decoded (section 7, R4) |
| anon_struct_packed_dim d/t | `differ:fullname(43)` | unchanged | decoded: 39 records ground B (Surelog's struct-member re-parenting), 4 ExprEmit (section 7, R2) |
| SVSwitch d/t | CMP_EQUAL at the base | - | pass 201's integration converted it before this pass |

Gate totals: probe **`regressions=0 conversions=0 changes=0`** (EQUAL 3363 / STRICT_NOTEQUAL 724, `probe.csv`
byte-identical to `results/golden_probe.csv`); surelog **`regressions=0 conversions=0 changes=0`**; uhdm2rtlil
**`regressions=0 conversions=2 changes=0`**; downstream **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0
DIVERGENT**, `downstream.csv` byte-identical to the pristine sweep's (arb_idx_cast `IDENTICAL` in both). **5 of 2560**
corpus databases move: arb_idx_cast d/t (predicted by name by the frozen firing census) and three UVM coin draws
(section 4); uhdm-cmp reads 0 lines on all five. 3 of 4087 probe databases move, all three predicted, all EQUAL before
and after.

**The fence.** The four slang-fenced names come from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`;
every driver here resolves its paths from the repo that holds it and reads them fail-closed (`drivers/env.sh` exports
`FENCED` and `FENCERE`; `case.sh`, `grid.sh`, `rowrun.sh`, `rowhead.sh`, `det.sh`, `bytectl.sh`, `switches.sh`,
`awaycorp.sh`, `bvmirror.sh`, `uvmdist.sh`, `dscase.py` refuse a fenced name; `census.sh` runs the corpora with
`--filter` built from the fence). The byte comparisons ran on hard-link mirrors that leave the 8 fenced row-mode
databases out (`fenced_skipped=8`). No fenced test was run, read or decoded outside the gate sweeps, which dispatch
every row themselves; their csv verdicts are the only fenced facts cited (none moved). No gdb was used.

## 0. Switches

Every r11u206 law reads its own `R11U206_<LAW>_OFF` through `r11u206Law` (`UhdmExporter.cpp`, beside
`r11v202Law`); **`R11U206_OFF=1` drops all of them**. `R11U206_TRACE=<dir>` names every firing (one file per process,
`<pid>.206`, first line `OUT <-o path>`, then `<law> <detail>`), on every branch that writes (the on-demand build of
§ classScopeTdRetBuildsOwner206 is traced on every call, bound or not, since the build alone can move bytes).

| switch | law | file |
|---|---|---|
| `R11U206_TPCASTDEF_OFF` | § tpCastUseBindsDefDefault206 | UhdmExporter.cpp (a post-pass right after § tpUseBindsDefDefault160, reading its per-instance map) |
| `R11U206_TPARRELEM_OFF` | § tpArrayElemBindsDefDefault206 | UhdmExporter.cpp (inside § tpUseBindsDefDefault160's walk) |
| `R11U206_UTIFCPRG_OFF` | § unitClassTdEndAtInitIfcPrg206 | UhdmExporter.cpp (§ unitClassTdEndAtInit202's writer walk) |
| `R11U206_CLSCOPETDRET_OFF` | § classScopeTdRetBuildsOwner206 | TaskFuncEmit.cpp (just before § classTdRetSharesTypedefTs200) |
| `R11U206_GENCLSVAR_OFF` | § genScopeClassVarListed206 | ModuleEmit.cpp (the elaborated gen_scope variable loop) |
| `R11U206_GENCLSSPAN_OFF` | § genScopeClassVarSpecAtName206 | ModuleEmit.cpp (the same site) |
| `R11U206_OFF` | all of the above | |

**OFF check.** `R11U206_OFF=1` on the law binary writes the pristine bytes on **all 4087 `tests/probe` databases**
(`check_probe.py` rerun under the switch, every database compared with the pristine sweep's: 0 differ; its csv equals
`results/golden_probe.csv`, [evidence/sweeps/probe_off_check.txt](evidence/sweeps/probe_off_check.txt)) and on **57 of
57** cases of this directory (last column of [evidence/grids/grid_pris_law_off.tsv](evidence/grids/grid_pris_law_off.tsv)).
One known exception outside both sets, section 5: `r11u196repro/cases/V191/qr01`, whose bytes change with every
rebuild of any source (an orphan with an uninitialised value, pre-existing). **Each switch alone**
([evidence/switches/](evidence/switches/), `drivers/switches.sh` over this directory's cases): every switch moves
only cases whose plain run traced its own law (`UNTRACED 0`).

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u206_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `d27bb984d49f6d31eb76cd00e98e517f` | = the main tree's `build/slang-uhdm`; the worktree's own pristine build (`/tmp/wt_r11u206` at `3668bf30`, system deps, `-j 2`) reads the same md5 |
| `d7.bin` (**the law binary**) | `b81dbfaca6fdd916dbc1aa17af48e42e` | the delivered sources (`d1`-`d6` are development builds: d1 the cast law, d2 + the array element, d3 + the interface/program writers, d4 + the class-scope return, d5 + the gen-scope class variable, d6 + its span; d7 only widens the on-demand build's trace) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

The source patch applied to a FRESH worktree of `3668bf30` (`git apply`, clean) builds (system deps, `-j 2`) to the
law binary's md5 (section 3, row (1)).

## 2. The laws (decode, grid, law)

Grids ([evidence/grids/grid_pris_law_off.tsv](evidence/grids/grid_pris_law_off.tsv), `drivers/grid.sh`: each case
judged as `scripts/check_probe.py` judges it, goldens from the pinned Surelog cached per case text; columns pristine,
law, and the law binary under `R11U206_OFF=1` against the pristine bytes). 57 cases, EQUAL **13 -> 43**, 0 leave
EQUAL, `OFF=pristine` on 57 of 57:

| family | cases | EQUAL pristine | EQUAL law | converted by the law binary | left |
|---|---|---|---|---|---|
| TE (§ 2.1, § 2.2) | 17 | 0 | 12 | e01-e06 e08 e10-e13 e15 | e07 `type(1)` (a MODULE-scope cast, ExprEmit's face), e09 e14 e16 (stage 1 in both binaries), e17 (residue R6) |
| UT (§ 2.3) | 17 | 7 | 16 | u01 u02 u07 u11-u16 | u06 (stage 1 in both: two initialised declarators in one interface) |
| TR (§ 2.4) | 8 | 0 | 5 | r01 r02 r03 r05 r07 | r04 r06 r08: golden writes an `unsupported_typespec` (a Surelog miss on a package- or class-qualified owner, or a `$unit` owner); our bytes do not move there |
| VG (§ 2.5, § 2.6) | 7 | 0 | 3 | g01 g02 g07 | g03-g06 (the definition view, residue R5) |
| VN (v11u202's V3, decode only) | 7 | 6 | 6 | - | n05 (stage 1 in both) |

**Downstream of the grid** (the gate's own `one()`, `drivers/dscase.py`,
[evidence/downstream/cases_pris_law.tsv](evidence/downstream/cases_pris_law.tsv)): 49 cases, **7 EQUIVALENT ->
IDENTICAL** (VG g01-g07: the listed gen-scope class variable), 39 IDENTICAL in both, 3 EQUIVALENT in both (TE e07,
e09, e16), none leaves IDENTICAL.

### 2.1 § tpCastUseBindsDefDefault206 (arb_idx_cast, map 12's N0090; pass 202's residue 5)

Head at the base (`build/uhdm-strictcmp`, both modes, [evidence/sweeps/arb_idx_cast_heads.txt](evidence/sweeps/arb_idx_cast_heads.txt)):
`#360 endline logic_typespec` golden `8:40-15:27`, ours `8:40-8:60`, and `#384` the same (testflags `#270` / `#294`).
The two records are the ref_typespec actuals of the two casts `idx_t'({1'b1, ...})` / `idx_t'({1'b0, ...})` under the
ternary in `gen_levels[0].gen_level[0].gen_other_levels` (arb_idx_cast.sv 31-32). Golden's object is the type
parameter's DEFAULT (`logic [IdxWidth-1:0]` 8:40) with its end moved by writeNets to the first packed dimension of
`idx_t [2**NumLevels-2:0] index_nodes` (15:27), the object every other use reads.

Decode. § genScopeTypeParamCastTs121 binds such a cast (a loop-generate cast golden resolves) to "the same object the
instance's type_parameter points at", which it reads from `typeParamElabTs`, the instance's own copy
(`makeTypespec(tps)` in ParamEmit's elaborated type-parameter branch: 8:40-8:60, the default's span). Two later laws moved
every other reader of that copy onto the DEFINITION's object: § instTypeParamSharesDef120 (the instance lists the
definition's type_parameter, Surelog writeElabParameters "These point to the sole copy") and § tpUseBindsDefDefault160
(the instance's variables and nets, with the moved end). The cast kept the copy. Pass 202's TD grid measured the
end move but had no judge-equal shape (a01-a04 stage 1 at the definition-view cast); the judge-equal shape is a cast
under a ternary or an operation in a LOOP generate (pass 202's a05, a direct cast, keeps § 113's placeholder and
agrees already).

Law. After § tpUseBindsDefDefault160, from ITS per-instance map (instance copy -> definition object, only where UHDM's
own Compare reads the two equal and no named override applies), every ref_typespec whose parent is a cast operation
(`vpiCastOp`) and whose nearest enclosing module_inst is that instance, reading the copy, is re-pointed at the
definition's object. Nothing is minted. Grid [cases/TE](cases/TE) e01-e12 (loop-generate ternary, if-in-for,
`always_comb` in a loop generate, a named override beside a default instance (e04: the override instance keeps its
copy), a value-parameter override (e05), a struct default (e06), the arb shape reduced (e08), an operation (e11), a
`localparam type` in the header (e12)): **10 NOT_EQUAL/STRICT_NOTEQUAL -> EQUAL**; e07 (a module-scope cast: `type(1)`,
the placeholder face, ExprEmit) and e09 (no dimensioned use: stage 1 in both) unchanged. Downstream: the width is
unchanged (the copy and the definition object Compare equal), every TE case keeps its verdict.

### 2.2 § tpArrayElemBindsDefDefault206

The same producer for an UNPACKED declaration (`t x [4];`): the element variable / net sits under the array object
(`vpiReg` / `vpiNet`) and its typespec reference reads the definition object in golden (the end moved to the first
unpacked dimension, § defNetTypeParamDefault137's grid tn04), where § tpUseBindsDefDefault160's walk re-pointed only a
packed array's elements. Found by the TE grid (e10, where § 2.1 left `endline(1)`). Grid e10, e13 (a plain body
variable), e15 (two unpacked dimensions): **3 -> EQUAL**; e14 (`wire t w [2]`) and e16 (a generate-local unpacked
array beside a named override) stage 1 in both; e17 (a STRUCT default, unpacked) unchanged `endline(3)`: its element's
struct copy is not the instance copy § 160's map holds (residue R6).

### 2.3 § unitClassTdEndAtInitIfcPrg206 (v11u202's V1)

§ unitClassTdEndAtInit202 moves the end of a `$unit` class typedef's class_typespec to the initializer end of the last
MODULE variable declared with it. Golden moves it for INTERFACE and PROGRAM variables too (UT/u01 `interface ifc;
m_misc a = new;` 5:9-7:17, u02 a program), and the writers are ranked by KIND before name. Grid [cases/UT](cases/UT),
17 cases, each pair built so that the kind order, the name order and the source order disagree:

* a module beats an interface (u04: interface `zzz` vs module `aaa`; u08: module first in the file; u10: interface
  alphabetically first but later in the file) and a program (u05, u09);
* an interface beats a program both ways round (u11-u14);
* within one kind the alphabetically last `work@<name>` wins (u07 two programs, u15 two interfaces, pass 202's modules);
* an uninstantiated interface writes too (u16); a procedural block's variable never does (u17).

So the order is programs, then interfaces, then modules, by name within a kind (Surelog compiles the module and
program definition maps in `CompileDesign::compileMT_`; the measured order is the rule, the compile order behind it is
not transcribed further). The walk now ranks (kind, name) and keeps the maximum; with a module writer present the
outcome is pass 202's. **9 converted** (u01 u02 u07 u11-u16), u03-u05, u08-u10, u17 EQUAL in both, u06 stage 1 in both.
The v11u202 cases UT/x01 and x02 convert too (section 3, byte controls).

### 2.4 § classScopeTdRetBuildsOwner206 (v11u202's V4)

A return written as ANOTHER class's typedef (`function K::q_t f();`, an `extern function K::q_t f()` and its
out-of-body `function K::q_t D::f()`, a return split across lines, a typedef inherited from a base class) must bind
that typedef's listed class_typespec (golden `q_t` 7:13-7:14 parented at class_defn K). § classTdRetSharesTypedefTs200
tests `typedefTs.count(returnType)`, and classes are emitted in NAME order (`D` before `K`), so the owner's typedefs
were not built yet: the law missed and an anonymous class_typespec was minted at the return token (stage 1 on r01, r02;
`name(2)` on r03; v11u202's q02 `name(3)` was the same miss). The law makes the on-demand build every other
class-nested typedef reader already makes (§ classPropElemTsFollowsScalarTd9, `fwWinnerTs98`: a package- or
class-nested owner only, never the declaring class itself), then § 200 binds. Grid [cases/TR](cases/TR): r01 r02 r03
r05 (the inherited typedef) r07 (a plain class and the owner's own class as typedef targets) **-> EQUAL**; r04 (a
`p2::K::q_t` from another package), r06 (a `$unit` owner) and r08 (`A::K::q_t`, a nested owner) read an
`unsupported_typespec` in golden (Surelog does not resolve them) and our bytes do not move there. v11u202's TR q01 and
q02 convert (section 3).

### 2.5 § genScopeClassVarListed206 (v11u202's V5)

A CLASS-HANDLE generate-block local (`if (1) begin : g c q; end`) is a `class_var` in the elaborated gen_scope's
vpiVariables (golden VG/g02 `class_var work@g02.g.q` 6:7-6:8, its ref_typespec full name the variable's, the
class_typespec at the written type, unparented); `genLocalVarClass` knows no class form, so every such declaration was
dropped (stage 1, uhdm2rtlil's `nohier` differs: EQUIVALENT downstream). The branch builds the class_var the way the
module level does (makeTypespec on the written type, `nameSpan` location, visibility 1) and registers it in the net
map. The definition view keeps nothing, as for the other locals.

### 2.6 § genScopeClassVarSpecAtName206

Its class_typespec written as an unscoped SPECIALIZATION is located at the class NAME alone, value or type arguments
alike (golden VG/g01 `c #(3) q;` 6:5-6:6 where ours spanned `c #(3)`, g04 `c #(byte) q;` 6:5-6:6): the generate-scope
counterpart of § modSpecValueArgSpanAtName202 without its value-only test. Grid [cases/VG](cases/VG): g01 g02 g07 (an
if/else generate beside a module-level class variable) **-> EQUAL**; g03-g06 stay stage 1 (the DEFINITION view:
residue R5). Downstream: g01-g07 EQUIVALENT -> **IDENTICAL**.

### 2.7 Decoded, no law

* **V3** (`c #(.W(8)) j;`, the elaborated view's name-only span, [cases/VN](cases/VN)): golden writes two spans for the
  specialization (the whole text in one listing, the name in the other) and ours is one of them, so the strict
  comparator's copy rule excuses it: n01-n04, n06, n07 are EQUAL at the base. Strict-invisible; no law.
* **V7** (v11u202 GV/g01 `logic [7:0] d = f(q);` in a generate block): the call argument `q` keeps the formal-typespec
  stamp golden does not write (uhdm-cmp `rhsPath: ... logic_var(d) > func_call(f) > ref_obj(q) > ref_typespec`,
  LHS `<null>`). The stamp is ExprEmit's (the family pass 201 landed as the formal-typespec-stamp laws); the call site
  is ModuleEmit's pendingGenVarInit drain (`emitExpr(*in0, pv9.var, ...)` just above § genVarInitOuterRefUnbound202):
  sister ground, stopped at the decode.

## 3. The gates (the law sweep `/tmp/r11u206_sL` against the committed baselines, beside the pristine `/tmp/r11u206_sP`)

Both sweeps are `tests/sweep.sh --jobs 3 --workdir <dir>` with `SLANG_UHDM` exported (`drivers/sweep.sh`); workdir
names of equal length; every `cmds.txt` `slang:` line names the sweep's own binary (3273 of 3273 in each), and the
downstream lane's databases are the sweep binary's (arb_idx_cast's downstream `slang.uhdm` equals that binary's
testflags database). Both sweeps exit 0 (`SWEEP_RC=0`; the worktree's `tests/LAWS.md` was regenerated before the law
sweep). Summaries: [evidence/sweeps/](evidence/sweeps/).

| gate | pristine `pris.bin` | law `d7.bin` |
|---|---|---|
| (1) build | = the main tree's `build/slang-uhdm` | `3668bf30` + this patch, the fresh-worktree rebuild reading the same md5 |
| (2) probe vs golden_probe.csv | EQUAL 3363 / 724, `0 / 0 / 0`, `probe.csv` byte-identical to the baseline | **EQUAL 3363 / 724: `regressions=0 conversions=0 changes=0`**, `probe.csv` byte-identical to the baseline |
| (3) surelog vs golden_surelog.csv | `0 / 0 / 0` | **`regressions=0 conversions=0 changes=0`** (463 + 17 default, 459 + 15 testflags) |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | `0 / 0 / 0` | **`regressions=0 conversions=2 changes=0`** (798 + 5 per mode) |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **the same; `downstream.csv` byte-identical to the pristine sweep's** |
| (5) uhdm-cmp | | **0 lines on all 5 corpus movers** ([evidence/sweeps/uhdmcmp_movers.txt](evidence/sweeps/uhdmcmp_movers.txt)); every probe case stays uhdm-cmp EQUAL |
| (6) byteverify (SELFCHECK=1, fence-free mirrors) | | **`MOVERS: 5 / 2560`**, PATH_SETS_IDENTICAL, SELFCHECK 2559 / 2560 flagged ([evidence/sweeps/byteverify_law_vs_pristine.txt](evidence/sweeps/byteverify_law_vs_pristine.txt)) |
| canaries | | surelog `ok=52 changed=0`, uhdm2rtlil `ok=16 changed=0`; ctcan2 `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS |

The whole strict column of the law sweep against the pristine sweep, row by row
([evidence/sweeps/csv_rowdiff_pristine_law.txt](evidence/sweeps/csv_rowdiff_pristine_law.txt)): the two arb_idx_cast
rows, nothing else (the LowMemLib / LowMemPkg detail texts carry the workdir path: environment). **No row-mode's
strict column worsens.**

**The two row-mode conversions** (fresh rows, NOT written to `results/`):

    arb_idx_cast,default,CMP_EQUAL,,,equal       was differ:endline(2)   § tpCastUseBindsDefDefault206
    arb_idx_cast,testflags,CMP_EQUAL,,,equal     was differ:endline(2)

arb_idx_cast's downstream row stays `arb_idx_cast,IDENTICAL,OK,OK,11,11,,` in both sweeps.

**Byte controls on the earlier passes' evidence** ([evidence/bytectl/](evidence/bytectl/), `drivers/bytectl.sh`,
pristine vs law with traces, the probe command line): **2074 case dirs** of r11u31repro, r11u108repro, r11u113repro,
r11u115repro, r11u118repro, r11v11u118repro, r11u119repro, r11u120repro, r11v120repro, r11u121repro, r11u124repro,
r11v124repro, r11u131repro, r11v131repro, r11u137repro, r11u144repro, r11u149verify, r11u152repro, r11u160repro,
r11u170verify, r11u196repro, v11u196repro, r11u200dec, r11u201repro, v11u201repro, r11u202repro, v11u202repro,
r11u204verify: **42 move, 41 with a firing of a law of this pass**; the one without, `r11u196repro/cases/V191/qr01`,
moves with every rebuild of any source (section 5), not by a law; 11 dirs write no database in either binary
(multi-file cases). All 118 / 119 / 120 / 124 / 131 cases byte-identical. Judged pristine -> law
([movers_judged_pris_law.tsv](evidence/bytectl/movers_judged_pris_law.tsv)): **10 converted** (`STRICT_NOTEQUAL` or
`NOT_EQUAL -> EQUAL`: r11u113 grid/c/c01_arb and r11u121 grid/t/t45_arb by § 2.1, r11u204verify TB/b03 by § 2.2,
v11u202 UT/x01 and x02 by § 2.3, TR/q01 and q02 by § 2.4, v11u196 MG/g02, v11u201 M/m03_gen_initial and v11u202 VA/a04
by § 2.5), 22 EQUAL in both, 10 NOT_EQUAL in both; **none leaves
EQUAL**. Downstream of the 42 ([evidence/downstream/bytectl_movers_pris_law.tsv](evidence/downstream/bytectl_movers_pris_law.tsv)):
**9 EQUIVALENT -> IDENTICAL** (the gen-scope class variables of r11u196 MG/m12, r11u204 MG/g04, v11u196 MG/g01, g02,
v11u201 M/m03_gen_initial, v11u202 NP/n02, UT/x03, VA/a01, VA/a04), 32 IDENTICAL in both, r11u202 TD/a04 EQUIVALENT in
both; none leaves IDENTICAL.

## 4. Movers, predicted by name

The firing census (`drivers/census.sh`: the law binary with `R11U206_TRACE` over every corpus row-mode but the fenced
four, and every probe case, BEFORE the law sweep; `drivers/censum.py`) was frozen `chmod 444` in
[evidence/census/predicted_movers.txt](evidence/census/predicted_movers.txt) at the time in
[frozen_at.txt](evidence/census/frozen_at.txt), before `/tmp/r11u206_sL` started:

    probe/r11u113repro__grid__c__c13_genif_comb.uhdm          tpCastUseBindsDefDefault206:1
    probe/r11u113repro__grid__c__c25_genfor_ternary_gvcast.uhdm tpCastUseBindsDefDefault206:4
    probe/r11u113repro__grid__c__c27_genfor_ternary_plain.uhdm  tpCastUseBindsDefDefault206:4
    uhdm2rtlil/default/arb_idx_cast                           tpCastUseBindsDefDefault206:2
    uhdm2rtlil/testflags/arb_idx_cast                         tpCastUseBindsDefDefault206:2

No law of this pass fires anywhere in the surelog corpus (the positive control: the same census names arb_idx_cast's
two casts in both uhdm2rtlil modes, and the grids fire every law). **Corpus: 2 of 2 law movers predicted by name, 0
moved-not-predicted among law movers, 0 predicted-not-moved; probe: 3 of 3** (all EQUAL before and after,
[evidence/sweeps/probe_byte_movers.txt](evidence/sweeps/probe_byte_movers.txt)).

The three other corpus movers are the UVM storage-order family the brief names, none with a firing:

| mover | order-blind dump lines (pristine vs law draw) | reading |
|---|---|---|
| Scoreboard default | 0 (92 raw lines) | the svunit listing-order coin |
| MiniAmiq testflags | 0 (0 raw lines) | a serialization-order draw |
| BuildUVMPkg default | 4 | **v11u202's V2 draw, on the PRISTINE side**: the pristine sweep's database lacks the weakly-referenced `class_typespec this_type` 13776:11-13776:42 of `uvm_abstract_component_registry`; the law draw has it, as every determinism draw of both binaries does (section 5). The row's strict cell is unchanged (`differ:line(11)`) |

## 5. Determinism, the UVM distance, the away census

**Determinism** (`drivers/det.sh`: each binary three times CONCURRENTLY per row-mode with the pristine sweep's command
line and cwd; `drivers/detob.sh` compares the SORTED dumps of every multi-hash row-mode, ids and the path header dropped;
[evidence/determinism/](evidence/determinism/)): Earlgrey_0_1 default and testflags **one database per mode per binary,
and the SAME database in both binaries** (`15e6e48bc148`, `e449573deea9`); every UVM row-mode's draws of the law binary
are a subset of the pristine binary's hashes; the multi-hash draws (pristine SimpleUVM default 2, Scoreboard default 3;
law Scoreboard default 2) read **0 order-blind lines**. The UVM value coin stays closed; **no law of this pass adds a
coin**. BuildUVMPkg default drew one database in all six draws (`a22b6ee6955d`, the object V2 names present).

**The UVM order-blind distance** (`drivers/uvmdist.sh`, [evidence/sweeps/uvm_orderblind_distance.txt](evidence/sweeps/uvm_orderblind_distance.txt)):
identical in both sweeps on every UVM row-mode (MiniAmiq 6634, SeqDriver 5194, SimpleUVM 2074, Scoreboard 1526,
BuildUVMPkg testflags 776), except BuildUVMPkg default, 769 in the pristine sweep's rare V2 draw and 776 in the law
sweep's ordinary draw (the missing object's 8 records; pristine testflags reads 776).

**The away-moved-record census** (map 12's method, `drivers/away.py` + `awaycorp.sh`, order-blind records with the
depth dropped; LOST = in golden and pristine, not in law): the five corpus movers **lost=0** (arb_idx_cast d/t `dist 2 -> 0,
gained=2`; the three UVM draws gained 1 / 0 / 0), the 42 byte-control movers **lost=0**
([evidence/away/](evidence/away/)); this directory's 56 cases with a database in both binaries lost=0 except TE/e06
(`lost=8 gained=4`), which the law turns STRICT_EQUAL: its eight "lost" records are the struct members' ref_typespec
records read `<in>a` / `<in>b` (inside a copy) in golden and pristine and `a` / `b` in the law, the same raw content now
reached through the definition object (the comparator's copy rule reads them equal); no content record moves away.

**A pre-existing build-dependent orphan (found by the byte controls).** `r11u196repro/cases/V191/qr01` (a class method
returning `typedef int a_t[string]`) writes an unreachable constant whose value (`UINT:249...`, 10 bytes) changes with
EVERY rebuild of any source, deterministic per binary (four runs each of pristine and law), never in the dump. Site:
TaskFuncEmit's § queueTwinKeepsElem204v (r11u204), which calls `buildUnpackedArrayTypedefTs(..., cloneForm=true)` on a
dynamic / associative container to borrow the clone form's element and leaves the rest orphaned; that builder reads the
alias through `as<FixedSizeUnpackedArrayType>()`, the garbage read § queueRetTwinDynShape191 closed on the listed twin.
Reader-invisible (uhdm-cmp, the strict walk, the dump and the plugin never reach it), but it makes "OFF = pristine
bytes" false on such a case across rebuilds. Not changed here (it would move every database with such a return;
residue R1 with the fix named).

## 6. Pass 202 / 201 / r11u204 / map 12 items: what this pass did with each

| item | status |
|---|---|
| (0) r11u205dec | not landed at the start |
| (1) V1 | **landed**, § unitClassTdEndAtInitIfcPrg206 |
| (1) V2 | observed once (the pristine sweep's BuildUVMPkg default draw), 0 of 6 determinism draws; not decoded (residue R7) |
| (1) V3 | strict-invisible (section 2.7), no law |
| (1) V4 | **landed**, § classScopeTdRetBuildsOwner206 |
| (1) V5 | **landed** (the elaborated view), § genScopeClassVarListed206 + § genScopeClassVarSpecAtName206; the definition view is residue R5 |
| (1) V6, V7 | V6 not attempted; V7 decoded to ExprEmit (section 2.7) |
| (1) MiniAmiq #899, BuildUVMPkg #3245 | not attempted |
| (1) arb_idx_cast | **converted** |
| (1) UnitElabBlock d | ExprEmit only (section 7) |
| (2) SVSwitch | CMP_EQUAL at the base |
| (2) Scr1SvTests | `type(1)`, the Surelog binding defect; no law |
| (2) Earlgrey #90097, Rggen N0145 / N1249, the definition half of the generate `$bits` law, the UVM first records | not attempted |
| (3) r11u204 B3, B4, N5-N9 | not attempted |
| (4) InterfaceStructMemberPort, HierPathTypespec t, anon_struct_packed_dim | decoded (residues R2-R4) |
| (4) cfg_func_width_loop, OutputSize..., ibex_tracer, the UVM B families | not attempted |

## 7. Residues, ranked, and the sister-ground faces

1. **R1 — the build-dependent orphan** (section 5): the fix is to stop § queueTwinKeepsElem204v's borrow from calling
   `buildUnpackedArrayTypedefTs` on a non-fixed-size container (build the element alone); every database holding a
   dynamic / associative class-method return of a non-type-parameter element moves (orphan bytes only), so it needs its
   own census.
2. **R2 — anon_struct_packed_dim d/t `fullname(43)`**: 39 records are the members of the `$unit` struct `pte_t` used as
   the type of two members of an anonymous struct (`pte_t pte; pte_t gpte;`): golden's member ref_typespec full names
   read `gpte.pte_t.ppn` / `.g` / `.v` at every listing, because Surelog's struct-member branch re-parents the member's
   (shared) typespec at the member, `member_ts->VpiParent(m)` (Surelog `CompileType.cpp` compileTypespec, the
   `paStruct_union_member` loop), the LAST member winning, and the writer computes the names from that chain (golden's
   `pte_t` lists `vpiParent: typespec_member (gpte)`; ours has no parent and `pte_t.ppn`). The law belongs with
   § typedefParentLastWriter134's re-parenting model (a new writer kind, compile-time, before UhdmWriter's
   writeDataTypes), which needs the full writer order graded on nets and variables of the typedef type too. The other 4
   records are ExprEmit's (`gx` under `tq[gi].is_page[2 - gx][0:0]` named through the select chain): the row needs both.
3. **R3 — InterfaceStructMemberPort d/t `fullname(6)`**: the modport io_decl nets of the port's interface view carry NO
   full name in golden (`struct_net req`, `logic_var trn`; ours `work@top.w.sub.sub.req.req`, `work@top.w.sub.trn`), and
   the references of `sub.req.wen & sub.trn` in the child's connection are named through the child's port
   (`work@top.w.u.sys_wen.wen`, ours `work@top.w.wen`); on pass 202's IM grid golden's shared modport objects are
   renamed by the last connection that reads them (`work@top.w.u.x.a`) and the operation diverges structurally before
   the names (a ref_obj where ours has the hier_path). ModuleEmit `emitInterfaceInstance`, § modportExprPort's site.
4. **R4 — HierPathTypespec t `fullname(1)`**: under `-elabuhdm` golden binds `c[1].x`'s member to the typespec_member of
   an ELABORATION CLONE of `pkg::a` under a clone of `pkg::b` (its ref full name `pkg::pkg::b::pkg::a::x`); ours binds the
   package listing's member (`pkg::pkg::a::x`). Needs the elaborated variable's per-use clone of the packed-array
   typedef and the hier_path binding into it (TypeEmit buildStructTs / ModuleEmit's elaborated variable).
5. **R5 — the definition view of a generate-block class local** (VG g03-g06): golden's definition view stmt-ifies the
   declaration as an `assignment` whose Lhs is the class_var when the type carries a TYPE argument (`c #(byte) q;`), a
   package scope (`p::c r;`, `p::c #(4) q;`) or an initializer (`c q = new;`), and in a loop generate (g03); a plain
   `c q;` and a value specialization `c #(3) q;` are not listed there. ModuleEmit's definition-view generate-block
   emitter (the locals branch beside § defGenInitRhsKeepsParent200).
6. **R6 — a struct default read through an unpacked declaration** (TE/e17 `endline(3)`): the element's struct typespec is
   not the instance copy § tpUseBindsDefDefault160 maps.
7. **R7 — v11u202's V2**: the weakly-referenced `this_type` class_typespec minted by § classTdRetSharesTypedefTs200 is
   missing from rare draws (here the pristine sweep's BuildUVMPkg default). Reader-invisible; undecoded. A hypothesis for
   the next pass: the mint depends on whether the declaring class's typedefs were built when its static method was
   emitted, an emission order that may vary between runs.
8. **TE/e07** (`type(1)`): a MODULE-scope cast to a type parameter under a ternary (`assign x[0] = s ? t'(1) : t'(0);`);
   the placeholder / resolution choice is ExprEmit's (§ genScopeTypeParamCastTs121's module-scope neighbour).
9. The items section 6 marks "not attempted".

**Sister-ground faces met on the way** (stopped at the decode, with the call site): UnitElabBlock d/t `file(2)` /
`file(1)`: the implicit `logic_net work@mod.hold` minted in ExprEmit's `vlogHiddenBlockVars` branch carries `top.v`
where golden's has no file (pass 202's reading, re-measured at this base: `#105` / `#207 file logic_net hold`); that
branch must call `noteImplicitNetMint131` as the other three implicit-net mints do (§ implicitNetMintNoFile131).
V7's formal-typespec stamp (ExprEmit, called from ModuleEmit's pendingGenVarInit drain); anon_struct_packed_dim's four
`gx` names (ExprEmit's hier_path select naming); TE/e07's module-scope cast (ExprEmit).

## 8. Files

* `cases/`: TE (§ tpCastUseBindsDefDefault206 e01-e12, § tpArrayElemBindsDefDefault206 e13-e17), UT
  (§ unitClassTdEndAtInitIfcPrg206), TR (§ classScopeTdRetBuildsOwner206), VG (§ genScopeClassVarListed206, the span
  law's cases g01 g04), VN (§ modSpecValueArgSpanAtName202: V3's decode). Every case names its law on its first line.
* `drivers/`: `env.sh` (pins + fence, `FENCED` and `FENCERE`), `case.sh`, `grid.sh`, `rowhead.sh` (a sweep row's strict
  head without a rerun), `rowrun.sh`, `sweep.sh`, `census.sh` + `censum.py` (the prediction), `bytectl.sh`,
  `switches.sh`, `bvmirror.sh`, `det.sh` + `detob.sh`, `uvmdist.sh`, `away.py` + `awaycorp.sh`, `dscase.py` (the
  downstream gate's `one()` on cases).
* `evidence/`: `grids/`, `switches/`, `census/` (the frozen prediction), `sweeps/` (the two sweep summaries, the row diff,
  byteverify, uhdm-cmp on the movers, the probe byte movers and the OFF check, arb_idx_cast's heads, the UVM distance),
  `bytectl/`, `downstream/`, `determinism/`, `away/`.
