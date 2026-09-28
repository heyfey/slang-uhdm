# r11u196: the module/type ground, pair B (refill after pass 193): the r11u191 ground-B laws landed, module-local parameterized classes listed (the `--elabuhdm` crash), a qualified return's typedef object, the formal typedef clone's file, a type-parameter array bound at its left operand, a parameterized element class ending at its name, a call omitting a defaulted argument kept

Base `b8719ea9` (branch matrix-1.87, pass 193). Files of the ground touched: `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`,
`src/TaskFuncEmit.cpp`, `src/UhdmExporter.cpp` (`uhdm_main.cpp` needed nothing). No line of the sister's files
(`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`), of `include/`, `scripts/`,
`results/`, `tests/probe/` or `third_party/` is edited; `tests/LAWS.md` is regenerated (`python3 scripts/law_index.py`).

**Verdicts per targeted row** (fresh csv rows of the law sweep `/tmp/r11u196_swL`; `results/` untouched):

| row-mode | base | after | law |
|---|---|---|---|
| **const_cast_signext d/t (u2r)** | `STRICT_NOTEQUAL differ:type(1)` | **`const_cast_signext,default,CMP_EQUAL,,,equal`**, **`const_cast_signext,testflags,CMP_EQUAL,,,equal`** | § evalFuncCastMemberKeepsCall191 |
| **func_typename_ret d/t (u2r)** | `STRICT_NOTEQUAL differ:name(2)` | **`func_typename_ret,default,CMP_EQUAL,,,equal`**, **`func_typename_ret,testflags,CMP_EQUAL,,,equal`** | § retPkgQualTdNoAlias196 |
| arb_idx_cast d/t (u2r) | `differ:endcol(17)` (#209) | `differ:fullname(16)` (#209 cleared; #322 is the sister's) | § tpArrBoundAtLeftOperand196 |
| BuildUVMPkg d/t | `differ:fullname(20)` | `differ:line(11)` | § formalDefaultNamedThroughFormal191 (+ § classPropElemClassTsAtName196) |
| MiniAmiq d/t | `differ:file(27)` | `differ:file(19)` (the four `uvm_bitstream_t` / `uvm_integral_t` file records gone; #899 is next) | § tfFormalTdCloneFile196, § formalDefaultNamedThroughFormal191, § queueRetTwinDynShape191, § classPropElemClassTsAtName196 |
| SeqDriver d/t | `differ:file(26)` | `differ:endcol(18)` (the file family gone from the row) | the same four |
| SimpleUVM d/t, Scoreboard d | `differ:fullname(54)` | `differ:fullname(46)` | the same four |
| probe r10vbuvm29repro/gv29_b_positions | `STRICT_NOTEQUAL differ:fullname(2)` | **`EQUAL`** | § formalDefaultNamedThroughFormal191 |
| probe v11u114repro/grid/set3/g13 | `STRICT_NOTEQUAL differ:type(1)` | **`EQUAL`** | § evalFuncCastMemberKeepsCall191 |
| probe r11u108repro/grid/f4/c12_const_fold | `differ:file(5)` | `differ:file(4)` | § evalFuncCastMemberKeepsCall191 |

Gate totals: probe `regressions=0 conversions=2 changes=1` (EQUAL 3299 -> **3301**); surelog `regressions=0
conversions=0 changes=9`; uhdm2rtlil `regressions=0` **`conversions=4`** `changes=2`; downstream 803 IDENTICAL / 66
SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, `downstream.csv` byte-identical to the pristine sweep's.

**The fence.** The four slang-fenced tests are never spelled here. Every driver that reads corpus sources or databases
(`drivers/env.sh` and everything that sources it: `case.sh`, `grid.sh`, `row.sh`, `rowrun.sh`, `rowdist.sh`,
`moverdist.sh`, `census.sh`, `predict.sh`, `bvmirror.sh`, `offcheck.sh`, `switches.sh`, `ob.sh`, `det.sh`,
`attrib.sh`, `compose.sh`; `uvmdist.sh` refuses to run without `$FENCED`; `dscase.py` reads the line itself) takes
the four names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed. The firing census ran
with `--filter "$NEGFENCE"` (built from `$FENCED`); the predictor skipped the 8 fenced row-mode databases
(`fenced_skipped=8`), the byte comparison ran on hard-link mirrors that leave them out (`fenced_skipped=8`). No fenced
test was run, read or decoded outside the two gate sweeps, which dispatch every row themselves; their csv verdicts are
the only fenced facts cited (none moved). gdb was used only on this pass's own cases (`MG/ma01` through the Yosys
plugin, `FR/f01`) and on r11u194's case `Z/z01` (copied to scratch).

## 0. Switches

Every r11u196 law reads its own `R11U196_<LAW>_OFF` through `r11u196Law` (`UhdmExporter.cpp`, beside `r11u193Law`);
`R11U196_OFF=1` drops all of them **and the seven r11u191 laws landed here** (their own gates `r191ME` / `r191TF` /
`r191TE` read it). The r11u191 laws keep their own `R11U191_<LAW>_OFF` switches and `R11U191_OFF`.
`R11U196_TRACE=<dir>` names every firing (one file per process, `<dir>/<pid>.196`, first line `OUT <-o path>`, then
`<law> <detail>`); `R11U191_TRACE=<dir>` does the same for the r11u191 laws (`<pid>.ME` / `.TF` / `.TE`).

| switch | law | file |
|---|---|---|
| `R11U191_REFFULL_OFF` | § formalDefaultNamedThroughFormal191 | TaskFuncEmit.cpp |
| `R11U191_QUEUERANGE_OFF` | § queueRetTwinDynShape191 | TaskFuncEmit.cpp |
| `R11U191_CONSTCALL_OFF` | § evalFuncCastMemberKeepsCall191 | ModuleEmit.cpp |
| `R11U191_UNSIZEDPKG_OFF` | § elabCaConstLhsSized191 | ModuleEmit.cpp |
| `R11U191_ENUMPARENT_OFF` | § enumDefOwnerNotInstance191 | ModuleEmit.cpp |
| `R11U191_HDRTD_OFF` | § modAggClonePerDefKey191 | TypeEmit.cpp |
| `R11U191_REALPORT_OFF` | § splitPortRealRedeclLogicTs191 | TypeEmit.cpp |
| `R11U196_MODGENERIC_OFF` | § modGenericClassListed196 | ModuleEmit.cpp (the module / program class listing, body and generate blocks) |
| `R11U196_MODGENHANDLE_OFF` | § modGenericHandleBare196 | TypeEmit.cpp (the class-handle typespec mint) |
| `R11U196_MODCLSLINK_OFF` | § modClassTsLinksDefListing196 | UhdmExporter.cpp (`classDefnFor`), ModuleEmit.cpp (the listing records it) |
| `R11U196_ELEMCLSNAME_OFF` | § classPropElemClassTsAtName196 | UhdmExporter.cpp (the array-element class_typespec, § classPropElemClassTsAtType183's site) |
| `R11U196_RETQUALTD_OFF` | § retPkgQualTdNoAlias196 | TaskFuncEmit.cpp (the return marker), TypeEmit.cpp (LAW S's skip), UhdmExporter.cpp (the marker set) |
| `R11U196_TPARRBOUND_OFF` | § tpArrBoundAtLeftOperand196 | TypeEmit.cpp (`emitTypeParamArrayVar` and `emitVectorTypedefArrayVar` bounds) |
| `R11U196_DFLTARG_OFF` | § evalFuncOmittedDefaultKeepsCall196 | ModuleEmit.cpp (beside § evalFuncSelectKeepsCall148, both cont_assign sites) |
| `R11U196_FORMALCLONEFILE_OFF` | § tfFormalTdCloneFile196 | TaskFuncEmit.cpp (the per-formal typedef clone and the unpacked element clone) |

**OFF check** ([evidence/offcheck.txt](evidence/offcheck.txt), `drivers/offcheck.sh`): `R11U196_OFF=1` on `law.bin`
gives the pristine bytes on all 4087 `tests/probe` databases and on 121 of the 122 case dirs of this pass and of
`tools/probe/r11u191dec/cases`. The one that differs, `V191/qr01`, differs by the r11u191 value coin itself: with the
queue law off the binary reads a queue alias through the fixed-size-array view again and prints the padding bytes as
the bound (`UINT:24747865` off vs `UINT:24698489` pristine; the rest of the dump identical), a value that depends on the
binary's memory layout. **Each switch alone** ([evidence/switches.txt](evidence/switches.txt)) moves only its own
law's cases (MODGENERIC also moves EN/e05, a module-local generic; CONSTCALL also moves the G / V191 hd cases whose
constant calls it keeps; DFLTARG also moves V191/fd03, which calls with a defaulted argument omitted).

## 1. Binaries (frozen `chmod 555` in `$R196_BIN=/tmp/r11u196_bin` before any measurement; [evidence/binaries.txt](evidence/binaries.txt))

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `4519cd58f7833bd1ac01afb706d3d45f` | the worktree's system-deps `-j 2` build of `b8719ea9` = the main tree's `build/slang-uhdm` |
| `l191.bin` | `0b5113334d08e4773fd9f61e685b1644` | `b8719ea9` + `tools/probe/r11u191dec/law_typeemit.patch` alone (applied clean, no rebase needed) |
| `law.bin` | `2ceb9c16dd0eb3d4bb4431d0bf56f289` | the delivered sources (`d1`..`d9` are development builds; `d9` = `law.bin`) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |
| `predict` | (built by `drivers/cc.sh`) | `drivers/predict.cpp`, the pristine-database predictor |

Sweeps: `drivers/sweep.sh <bin> <workdir>` = `tests/sweep.sh --jobs 3` with the pins exported, same-length workdirs
`/tmp/r11u196_swP` (pristine) and `/tmp/r11u196_swL` (law), all four stages. Every corpus `cmds.txt` of swP names
`/tmp/r11u196_bin/pris.bin` (3273 of 3273 `slang:` lines), every one of swL `/tmp/r11u196_bin/law.bin` (3273 of 3273).

## 2. (0) The r11u191 ground-B patch: landed, measured alone, re-verified, composed

**Rebase.** `law_typeemit.patch` applies clean on `b8719ea9` (`git apply --check`, rc 0) and was applied unchanged.

**Alone** (`l191.bin` against `pris.bin`, [evidence/grid_r11u191_pris_vs_l191.txt](evidence/grid_r11u191_pris_vs_l191.txt)):
r11u191's grid reproduces on this base. F f01 f02 f03 f05 f06 f07 -> STRICT_EQUAL (f04, f08 stage 1 on both); G g01 ->
STRICT_EQUAL; R r01, r03 -> STRICT_EQUAL (r02 stays stage 1, r04 control); U u01 u02 u05 u06 u07 u09 u10 u11 p01 p03 p06
p08 -> STRICT_EQUAL from NOT_EQUAL (u08, p02, p05, p07 stay); C c03 `type -> file`; N (bytes only: vpiParent) and Q
(bytes only: the twin) keep their verdicts. **New here**: pass 188's residue grid `r11u188repro/cases/E` (its R3,
const_cast_signext's decode) converts e01, e05, e06, e07, e09, e12 to STRICT_EQUAL by § evalFuncCastMemberKeepsCall191
alone (trace: one firing each; [evidence/grid_r11u188E_pris_vs_l191.txt](evidence/grid_r11u188E_pris_vs_l191.txt));
the rest of that grid (e04, e08, e10, e14-e24: a hex literal or a struct parameter as the actual) keeps `type` on both.

**Re-verified with 16 fresh cases** (`cases/V191`, [evidence/grid_V191_pris_vs_l191.txt](evidence/grid_V191_pris_vs_l191.txt);
each names its law on its first line):

| law | cases | pristine -> l191 |
|---|---|---|
| § formalDefaultNamedThroughFormal191 | fd01 (package parameter + concatenation default), fd02 (class property + static call, task ternary), fd03 (unary, `$bits`, an interface function) | fd02 **EQUAL**; fd03 `fullname` -> `type` (the names clear; the walk reaches a kept-call face, which § evalFuncOmittedDefaultKeepsCall196 then converts: EQUAL on law.bin); fd01 stage 1 on both (a `vpiActual` binding face of `K`, the sister's) |
| § evalFuncCastMemberKeepsCall191 | cc01 (reg typedef, packed union, shortint / longint), cc02 (local struct member, literal pattern, parameter member), cc03 (generate-scope call, size cast) | cc02 `type` both (h1 now kept; h2's pattern actual `'{a:4'h5, ...}` is kept in golden: r11u188's R3 hex family); cc03 60 -> 36 cmp lines; cc01 36 both (ExprEval value faces of the folded calls) |
| § elabCaConstLhsSized191 | uz01 (unsized hex / octal package parameters, two instances), uz02 (binary wider than the LHS, decimal) | uz01 60 -> 11 cmp lines (the next face: golden gives the octal parameter no typespec); uz02 EQUAL both |
| § queueRetTwinDynShape191 | qr01 (dynamic, associative, struct-queue returns), qr02 (bounded queue of a type parameter, two specializations) | stage 1 on both (other faces); bytes move at the twin only |
| § enumDefOwnerNotInstance191 | ep01 (two definitions, two instances each), ep02 (interface inside a module) | EQUAL both (vpiParent only) |
| § modAggClonePerDefKey191 | hd01 (header typedef, one writer), hd02 (task writer, a module instantiated twice) | hd01, hd02 **EQUAL** |
| § splitPortRealRedeclLogicTs191 | rp01 (real input, shortreal output, integer control), rp02 (real in / out, two instances) | rp01, rp02 **EQUAL** |

No fresh case moves away from golden: every judge-equal case stays judge-equal, every stage-1 case keeps or lowers its
cmp line count. One harness finding: r11u191's `drivers/dscase.py` (and this pass's first copy of it) reloaded the
downstream module but not `verify_golden`, whose `SLANG_UHDM` is read at import, so **every binary after the first ran
the first binary**: r11u191's per-case downstream verdicts compare a binary with itself. This pass's `dscase.py`
reloads both and asserts the binary taken.

**Composition with passes 188 and 193** (`drivers/compose.sh` + `composeana.py`, 264 case dirs: r11u191dec C F G N Q
R U, r11u188repro, r11u193repro, v11u193repro; [evidence/compose_l191_analysis.txt](evidence/compose_l191_analysis.txt)):
the byte mover set of `l191.bin` against `pris.bin` is the same 47 cases with neither, either or both of
`R11U188_OFF` / `R11U193_OFF` set: no law of the patch depends on a pass-188 or pass-193 law, and none of theirs
reads anything the patch moves. With this pass's own laws added ([evidence/compose_law_analysis.txt](evidence/compose_law_analysis.txt),
the same dirs plus `r11u196repro/cases`): 96 movers, the same set in all four switch states; `law.bin` with
`R11U196_OFF=1` = pristine on every dir but the qr01 coin. The only case of pass 193 that moves is `PM/p09_enum`
(§ enumDefOwnerNotInstance191, vpiParent; stage 1 with 32 cmp lines on both).

**The UVM value coin closes** ([evidence/determinism.txt](evidence/determinism.txt), `drivers/det.sh`: three
CONCURRENT runs per binary and row-mode, the pristine sweep's command line and cwd): pristine MiniAmiq d 3 distinct
hashes (twin bound `UINT:1097` / `0` / `1039`), MiniAmiq t 3 (`984` / `578` / `0`), SeqDriver d 2, SeqDriver t 2,
SimpleUVM d 2, SimpleUVM t 1; **law: the twin reads `STRING:$` in every run, one hash per row-mode** except MiniAmiq t
(2 hashes whose uhdm-dumps are identical line for line: a serialization-order draw no dump shows, 0 order-blind lines).
Earlgrey_0_1 d/t: one hash per binary in 3 of 3 runs, the law hashes equal to the law sweep's.

## 3. The laws of this pass

### 3.1 § modGenericClassListed196, § modGenericHandleBare196, § modClassTsLinksDefListing196 — r11u194's N1 (the `--elabuhdm` crash)

**The null dereference.** `class box #(type E = int)` inside `module sub`, `box #(byte) b;`: UHDM's
`ElaboratorListener::enterVariables` (templates/ElaboratorListener.cpp, the pinned UHDM and the plugin's alike) deep-clones
the class_var's typespec and, for each of its `Param_assigns`, calls `propagateParamAssign(pass, cctps->Class_defn())`,
which reads `target->UhdmType()`. Ours had minted the specialization's `vpiParameter` / `vpiParamAssign` with **no
`vpiClassDefn`** and a param_assign with **no `Lhs`**: the module listing held no class_defn for a parameterized class
at all (slang holds it as a `GenericClassDefSymbol`, and the listing collected `ClassType` members only), so
`classDefnFor` found nothing and `pendingClassTsPa` never bound the Lhs. rc 139 in `--elabuhdm` (slang-uhdm's own
elaboration) and a **CRASH in the Yosys plugin** in the downstream lane (the plugin runs the same listener).

**Decode.** Golden (cases/MG): `module_inst work@sub` lists `class_defn work@sub::box` with its `type_parameter E`
(ResolveSymbols' syntactic class collection files every paClass_declaration, parameterized or not), and every handle's
class_typespec is **bare**: Name + Class_defn, no vpiParameter / vpiParamAssign (compileTypespec's
`<component>::<typeName>` probe hits the home's own registration `work@sub::box` before `compileDatastructureTypespec`,
the only writer of specialization lists): a module variable with or without `= new`, a property of another module
class (at the class name token), a process local (unnamed), a function formal (at the name token).

**Laws.** (modGenericClassListed196) the module / program listing also takes each `GenericClassDef` member of the body
and of its generate blocks, by its default specialization, as `emitPackageClasses` does; (modGenericHandleBare196) a
handle of a class whose generic lives in a module, program or interface body gets no specialization list, spanned at
the name token on a class-property or formal site; (modClassTsLinksDefListing196) the listing is recorded by
(definition, class name), and `classDefnFor` resolves a class of any instance body of that definition through it
(slang elaborates a body per parameterization, and a second instance's class symbols are not the listed ones: this
also closes a pre-existing face of PLAIN module classes, m13).

**Grid** (`cases/MG`, 13 cases, both views; [evidence/grid_law.txt](evidence/grid_law.txt),
[evidence/grid_law_el_MG.txt](evidence/grid_law_el_MG.txt)): default view pristine NOT_EQUAL on 12 (47 to 540 cmp
lines), law **STRICT_EQUAL** on m09 (two instances, two specializations), m11 (a generic extending a plain class, a
formal of the specialization), m13 (plain class, two instances), ma01 (N1's shape), ma02 (`= new`), ma04 (the bare
generic name), ma05 (a property of another module class), ma06 (a program home), ma08 (control, equal both); ma03 /
ma07 / m12 drop to 18 / 64 / 64 cmp lines on the **value-parameter** faces of the class body (ma03: the `int W`
parameter's int_typespec is vpiSigned in golden and not in ours; ma07 / m12: an unpacked dimension `[N]`'s constant is
64-bit in golden, 32 in ours), which the package home shows identically (scratch controls: `pk::box #(8)` 18 and a
type-and-value package class 50 cmp lines, the same on both binaries) — class-body emission residues, not the
listing's; m10
(an interface home) unchanged (207: Surelog publishes an interface's classes at the design root; not modelled).
`--elabuhdm`: pristine **rc 139 on 9 cases**, law **0 crashes**; judge-equal on m09 m11 m13 ma01 ma02 ma04 ma05 ma06
(ma06 strict-equal), the rest `fullname` exactly as the plain-class control ma08 reads on the pristine binary (the
elaborated class_defn named `work@top::v::plain` where golden keeps `work@sub::plain`: pre-existing, outside the gate).
**Downstream** ([evidence/downstream_cases.tsv](evidence/downstream_cases.tsv), the gate's own `one()`): ma01 and m09
`STATUS_DIFF` (slang lane `CRASH`: `propagateParamAssign` in the plugin, gdb) on pristine -> **IDENTICAL** on law.

### 3.2 § classPropElemClassTsAtName196 — r11u194's N2

**Face.** `static pool#(string, int) m_rsc[comp];`: § classPropElemClassTsAtType183 spans the element's class_typespec
over the written type, `pool#(string, int)` (6:12-6:30), where golden ends at the class name (6:12-6:16); the UVM rows'
`uvm_pool` / `uvm_queue` elements at uvm_config_db.svh 69:10-69:44 vs 69:18. **Law**: a `ClassName` (with a parameter
list) ends the span at its identifier. **Grid** (`cases/EN`): e01 (associative + fixed, u04's shape), e02 (queue,
dynamic, spaced list), e06 (multi-line list, macro-written type) -> STRICT_EQUAL; e03 (nested specialization, value
parameter), e04 (package-qualified: § classPropElemQualTs186's route) stage 1 on both for other faces; e05 (module and
`$unit` generics) 502 -> 81 cmp lines (with § modGenericClassListed196). UVM rows: 2 records each (attribution below).

### 3.3 § retPkgQualTdNoAlias196 — func_typename_ret `name(2)`

**Face.** `function automatic P::S func2;`: golden's return var references the package's typedef object `P::S`
(4:13-4:24, no vpiTypedefAlias); ours a bare clone `S` with a Typedef_alias to `P::S`. **Decode**: LAW S
(`bareScalarTypedefVarTs`, TypeEmit: a package scalar typedef is bare at every variable-like binding, measured on
UNQUALIFIED spellings: its r6 cell) rebinds the return. A **written package-qualified** return is compileTypespec's
paPackage_scope branch, which hands back the package DataType's own typespec (golden FR/f02: the imported unqualified `B`
return keeps `B` -> `P::B`). **Law**: the return's ref_typespec written `<pkg>::<typedef>` is marked, and LAW S skips
it. **Grid** (`cases/FR`): f01 **STRICT_EQUAL**; f02 the return clears, the next record is the qualified FORMAL's
(residue R3); f03 122 -> 36 cmp lines (the next face is an enum constant's value type, the sister's).

### 3.4 § tfFormalTdCloneFile196 — MiniAmiq #1694 / #1858 / #2014 / #2546, SeqDriver #1677 / #1841 / #1997 / #2529

**Face.** `logic_typespec uvm_bitstream_t`: golden uvm_misc.svh 483:42-483:57, ours the same span in
uvm_object_globals.svh. **Decode**: this is not a moved listing object (§ tdMoveCarriesFile172's family, measured:
the package's own `p::it_t` stays at its declaration in both databases, cases SF) but the **per-formal clone** of a
vector / scalar typedef, which compileTfPortList populates at the formal's type token — vpiFile with the span.
TaskFuncEmit mints the clone with `makeTypespec` (filed at the typedef) and relocates it with `setLoc`, which fills
only an EMPTY file. **Law**: the clone (and the unpacked-array formal's element clone) takes the file of the formal's
type token. **Grid** (`cases/SF`): s01 (two headers, package functions), s02 (a class method and a package task), s04
(a formal type written in a macro body, an unpacked-array formal) -> STRICT_EQUAL; s03 (control, one file; an `int`
typedef formal: golden clones it at the formal too, ours keeps the declaration: residue R4) and s05 (a package-qualified
formal: residue R3) keep their verdicts. MiniAmiq / SeqDriver: the four file records gone (SeqDriver's first field
moves off `file`).

### 3.5 § tpArrBoundAtLeftOperand196 — arb_idx_cast #209

**Face.** `idx_t [2**NumLevels-2:0] index_nodes;` (a type-parameter-typed packed array): the folded bound constant
spans `2**NumLevels` (15:10-15:22) in golden, the leftmost token `2` (15:10-15:11) in ours. **Decode** (grid `cases/TB`,
goldens): Surelog locates the folded constant at the first child of the expression node, i.e. the whole LEFT OPERAND
of the top binary operation (its parse tree is left-deep): `N-1` -> `N`, `N+M-1` -> `N+M`, `N*2-1` -> `N*2`, `(N)-1`
-> `(N)`, `$clog2(N)+1` -> `$clog2(N)`, `-N+5` -> `-N`, `2**N-1` -> `2**N`. **Law**: a left operand that is not a name
or a literal keeps its own span; both copies of the reading (`emitTypeParamArrayVar`, `emitVectorTypedefArrayVar`).
**Grid**: t01 t02 t03 t04 t06 -> STRICT_EQUAL; t05 (`-N+5`) stays stage 1 for its VALUE (golden `INT:2`, ours
`UINT:2`: `srlgRedIntSyn`, EmitHelpers.h, the sister's), its span now golden's.

### 3.6 § evalFuncOmittedDefaultKeepsCall196 — found on the fresh case V191/fd03

**Decode.** `ExprEval::evalFunc` binds only the call's own argument list (`for (auto io : *func->Io_decls()) if (args
&& index < args->size()) ... setValueInInstance`), so a defaulted formal the call omits is never set, and a body that
reads it cannot reduce: writeCont_assign keeps the call (golden DF/d01: `f(1)` with `int b = 2` kept, `f(1, 3)`
folded). **Law** (beside § evalFuncSelectKeepsCall148 and § evalFuncCastMemberKeepsCall191, both cont_assign sites):
a whole-Rhs user call whose actual for a defaulted formal is the formal's own default (slang fills it from the port
list) and whose body reads that formal is kept. **Grid** (`cases/DF`): d03 (a package function from a module and a
generate block) -> STRICT_EQUAL, V191/fd03 -> STRICT_EQUAL; d01 keeps stage 1 for the folded call's VALUE (golden
`UINT:4`, ours `INT:4`: the sister's value family); d02 (named arguments) and d04 (an empty positional slot) stage 1
on both for a ref_typespec face. **Downstream**: d01, d03 `DIVERGENT` (constant value mismatch) on pristine ->
**IDENTICAL** on law.

## 4. Grids ([evidence/grid_law.txt](evidence/grid_law.txt); every case judged by `drivers/case.sh`, golden per text)

| grid | laws (first line of every case) | cases | pristine STRICT_EQUAL | law STRICT_EQUAL | moved away |
|---|---|---|---|---|---|
| `cases/MG` | § modGenericClassListed196, § modGenericHandleBare196 (m13: § modClassTsLinksDefListing196) | 13 | 1 (ma08) | 9 | 0 |
| `cases/EN` | § classPropElemClassTsAtName196 | 6 | 0 | 3 | 0 |
| `cases/FR` | § retPkgQualTdNoAlias196 | 3 | 0 | 1 | 0 |
| `cases/SF` | § tfFormalTdCloneFile196 | 5 | 0 | 3 | 0 |
| `cases/TB` | § tpArrBoundAtLeftOperand196 | 6 | 0 | 5 | 0 |
| `cases/DF` | § evalFuncOmittedDefaultKeepsCall196 | 4 | 0 | 1 | 0 |
| `cases/V191` | the seven r11u191 laws (fresh) | 16 | 3 | 9 | 0 |
| total | | **53** | **4** | **31** | **0** |

Shapes: module, program and interface homes, generate blocks, two instances of two parameterizations, class
properties, formals, process locals, initializers; associative / fixed / queue / dynamic elements, nested and
qualified specializations, multi-line and macro-written types; qualified vs imported returns, struct and enum returns,
package functions of other packages; two headers, class methods, tasks, macro-written formals, unpacked formals, a
qualified formal, an `int` typedef; leaf / sum / product / power / parenthesized / call / unary left operands, two
dimensions, parameter overrides, the vector-typedef emitter; omitted, named, empty-slot and unread defaulted
arguments, package and generate call sites.

## 5. Gates

1. **Build**: pristine = main tree (`4519cd58...`); law `2ceb9c16...` from the delivered sources (a no-op rebuild of
   the worktree reads the same md5).
2. **Probe** ([evidence/sweep_law.log](evidence/sweep_law.log)): `regressions=0 conversions=2 changes=1`, EQUAL 3299 ->
   **3301**, STRICT_NOTEQUAL 788 -> 786. The pristine sweep's `probe.csv` reads `regressions=0 conversions=0 changes=0`.
3. **Corpora**: surelog `regressions=0 conversions=0 changes=9` (judge-equal histograms unchanged: 480 / 3 and 474 / 3
   CMP_EQUAL + STRICT_NOTEQUAL with the same CMP_NOTEQUAL rows); uhdm2rtlil `regressions=0 conversions=4 changes=2`
   (CMP_EQUAL 793 -> 795 per mode). Every change and conversion is in the verdict table above; every surelog change
   is a first field moving off the head this pass works or a count falling on the same field.
4. **Downstream**: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`, every row its
   baseline verdict; const_cast_signext, func_typename_ret, arb_idx_cast IDENTICAL. `downstream.csv` is byte-identical
   to the pristine sweep's; 37 slang-lane databases move and **0 of the 2409 RTLIL / netlist files change**
   ([evidence/downstream_db_movers.txt](evidence/downstream_db_movers.txt)).
5. **uhdm-cmp**: every corpus row keeps its judge status (the csvs hold the baseline CMP_NOTEQUAL rows only; no
   STRICT_NOTEQUAL row left judge-equality) and every probe case is judge-equal (probe `regressions=0` includes the
   judge).
6. **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, fence-free mirrors,
   [evidence/byteverify.txt](evidence/byteverify.txt)): PATH_SETS_IDENTICAL 2560, SELFCHECK 2559 / 2560, **MOVERS 125**.
   **Prediction, frozen before the law sweep** (`chmod 444`): (a) the firing census (`drivers/census.sh`: `law.bin`
   with both traces over every non-fenced corpus row-mode and every probe case, summarised by `censum.py`,
   [evidence/predict_census_before_sweep.txt](evidence/predict_census_before_sweep.txt)) and (b) the pristine-database
   predictor (`drivers/predict.cpp` + `predict.sh`: one trigger per r11u196 law derived from its condition, an upper
   bound; positive controls MG/ma01 MODGEN, EN/e01 ELEMCLS, FR/f01 RETQUAL, TB/t01 TPARR, DF/d03 DFLTARG, SF/s02 FCFILE
   fire, MG/ma08 and SF/s03 do not; [evidence/predict_pristine_db_before_sweep.txt](evidence/predict_pristine_db_before_sweep.txt)).
   Check ([evidence/prediction_check_corpus.txt](evidence/prediction_check_corpus.txt)): **0 moved-not-in-census** of
   125; **0 r11u196-law movers the pristine predictor missed**; 14 census rows fire without moving (FuncStructVal,
   FuncStructValSimple, PackFunc d/t: § retPkgQualTdNoAlias196 marks a struct return LAW S never rebinds;
   EnumInPackage d/t: § enumDefOwnerNotInstance191, a later drain writes the same parent; func_struct_repro,
   nested_cast_repro, union_param_repro d/t: calls an earlier guard already kept). Movers by firing law:
   enumDefOwnerNotInstance191 115 (106 by it alone), classPropElemClassTsAtName196 9, formalDefaultNamedThroughFormal191
   9, queueRetTwinDynShape191 9, tfFormalTdCloneFile196 7, evalFuncCastMemberKeepsCall191 6, retPkgQualTdNoAlias196
   2, tpArrBoundAtLeftOperand196 2. **Attribution** ([evidence/moverdist.txt](evidence/moverdist.txt)): the
   order-blind strict-record distance to golden (`drivers/moverdist.sh`) falls on 15 movers (dist and miss both:
   BuildUVMPkg d/t 1036 -> 998, MiniAmiq d/t 7143 -> 7003, SeqDriver d/t 5801 -> 5608, SimpleUVM d/t 2579 -> 2404,
   Scoreboard d 1950 -> 1806, arb_idx_cast d/t 17 -> 16, const_cast_signext d/t 4 -> 0, func_typename_ret d/t 10 -> 0)
   and is unchanged on the other 110 (vpiParent / order bytes: § enumDefOwnerNotInstance191, the cast-keep firings on
   ibex_pmp and rsp_gen_minimal); **no mover's distance grows**. Probe ([evidence/prediction_check_probe.txt](evidence/prediction_check_probe.txt)):
   204 of 4087 databases move, 0 outside the census (232 named; 28 fire without moving).
7. **Canaries** ([evidence/canaries.txt](evidence/canaries.txt)): surelog `ok=45 changed=7` = exactly the seven canary
   rows among the nine surelog changes (MiniAmiq d/t are not canaries); uhdm2rtlil `ok=16 changed=0`; pristine sweep
   `ok=52` / `ok=16`; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS, `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS.
8. **Determinism** (section 2): the value coin closed; Earlgrey_0_1 one hash per binary.
9. `tests/sweep.sh` exits 1 in both sweeps for one reason: `law index STALE: tests/LAWS.md`, read on the worktree whose
   sources carried the new laws; the patch includes the regenerated `tests/LAWS.md`.

## 6. The UVM / Earlgrey rows ((5) of the brief)

**Order-blind distance** ([evidence/uvmdist.txt](evidence/uvmdist.txt), pass 193's `uvmdist.sh`; both modes equal):

| row | pass 193 | this base | law | per law (`drivers/attrib.sh`, default mode: distance with the law's switch off minus law) |
|---|---|---|---|---|
| MiniAmiq | 7143 | 7143 | **7003** | tfFormalTdCloneFile196 73, formalDefaultNamedThroughFormal191 63, classPropElemClassTsAtName196 2, queueRetTwinDynShape191 2 |
| SeqDriver | 5801 | 5801 | **5608** | 117, 72, 2, 2 |
| SimpleUVM | 2579 | 2579 | **2404** | 117, 54, 2, 2 |
| Scoreboard | 1950 | 1950 | **1806** | 95, 45, 2, 2 |
| BuildUVMPkg | 1036 | 1036 | **998** | formalDefault 36, elemClass 2 |
| Rggen d | 4521 | 4521 | 4521 | none fires on a record |
| Earlgrey_0_1 d / t | 6776 / 6341 | 6746 / 6313 | 6746 / 6313 | vpiParent only (§ enumDefOwnerNotInstance191) |

The per-law shares add up exactly to each row's fall, and `R11U196_OFF=1` restores every pristine distance
([evidence/attribution_uvm.txt](evidence/attribution_uvm.txt)).

**First ten records** ([evidence/heads_first10.txt](evidence/heads_first10.txt), base and law), by family and ground:
MiniAmiq — #899 `uvm_severity` enum file (ground B: the class-writer case of pass 176 / 188, residue R6), #1694 #1858
#2014 #2546 the formal-clone file (**cleared**, § tfFormalTdCloneFile196), #3490 / #3491 the method-call path at the
dots (N0228 / N0224: ExprEmit, r11u191's `idxCallPathAtDots191` in its ground-A patch), #5404 on: references named
through a method-call path (`space.substr::i`, r11u191's R1: ExprEmit). SeqDriver — the four file records **cleared**;
now #3473 N0228 then R1. SimpleUVM / Scoreboard — `UVM_MACRO_*` ref_typespec names (N0682, ground A). BuildUVMPkg —
the nine formal-default records **cleared**; now #3245 `uvm_action` int_typespec at a use (N0039, ground B, residue R5),
#5639 / #5909 constant lines, R1 names, #11991 a class_typespec name. SVSwitch — unchanged (`size` names through the
method, interface-array names: ground A). Earlgrey_0_1 — unchanged, #26470 N1082 (r11u191's `pkgFoldAtLeadingLeaf191`,
ground A), then `reg2hw.key[i]` bit_select names (ExprEmit).

## 7. What the brief's items read, and what was not attempted

* (1) pass 193's residues: **not attempted** — pm01 (two outside writers: the § tfArgOutsideCopyOrder193 mover declines),
  pm07 (package-internal references to a moved typedef), CL/s12 + bc09 (the § connLeftmostLeafElab139 walk is not run by
  `emitInterfaceInstance` or the bind path), tf07 / uc22 (interface continuous assignments), the unsized detector behind
  references, nested module arrays / program instances, the r10rgg9 cells. Their sites are unchanged; see R8-R11.
* (2) pass 192's sister faces on this ground: func_typename_ret **converted** (§ retPkgQualTdNoAlias196); arb_idx_cast's
  #209 **cleared** (§ tpArrBoundAtLeftOperand196); anon_struct_packed_dim (N0014 in `buildStructTs`: 39 of its 43
  records are the second use of a struct typedef inside an anonymous struct named through the member,
  `gpte.pte_t.ppn`; 4 are N0820, the sister's: not convertible on this ground alone), the unpacked-port-list span and
  InterfArrayBind's elaborated-view flag: not attempted.
* (3) r11u194's residues: N1 **fixed** (3.1); N2 **fixed** (3.2); the § typeParamDefersToTpUse186 hold-back (TP/t03)
  not attempted.
* (4) map 10's ground-B remainder: arb_idx_cast #209 done; OutputSize (its first records are `hier_path Info.x` spans,
  the sister's), N0039's probe cases, N0072, N0051, N0031 / N0042, ClassTypeParam, UnitElabBlock, pass 188's
  residues, LogicTypespec, InterfaceModPort: not attempted.

## 8. Residues, ranked

1. **R1 — MiniAmiq #899** (the first record of the row): the `uvm_severity` enum typedef moved by class-method writers
   plus outside writers (pass 176 / 188's residue), UhdmExporter's § tfArgClassMethodOrder176 mover.
2. **R2 — the value-parameter class body** (MG ma03 / ma07 / m12, the package home alike): a class value parameter's
   `int` typespec is vpiSigned in golden (ma03), and an unpacked dimension `[N]` over it folds to a 64-bit constant
   in golden, 32-bit in ours (ma07, m12); `emitClassDefn`'s parameter and variable emission (UhdmExporter / TypeEmit).
3. **R3 — a package-qualified FORMAL of a scalar typedef** (FR/f02, SF/s05; the same family as cfg_func_width_loop's
   `line(3)` first record, there an in-package writer): golden binds the package's own typedef object and MOVES it to
   the last writer (FR/f02 `P::` 9:31-9:34 without a direction keyword, SF/s05 the whole `p::it_t` 6:45-6:52 with one:
   the span rule § tfArgQualOutsideWriter176 already reads), where ours binds a bare LAW-S clone and leaves the
   listing at its declaration: the scalar face of the § tfArgQualOutsideWriter176 mover (UhdmExporter, which admits
   enum and aggregate typedefs only) together with LAW S's io_decl rebind (TypeEmit `bareScalarTypedefVarTs`).
4. **R4 — an `int` typedef formal** (SF/s03): golden clones it at the formal (5:42-5:47); ours binds the declaration
   (TaskFuncEmit's formal typedef-clone branches take vector / scalar logic and bit typedefs only).
5. **R5 — BuildUVMPkg #3245** (`uvm_action` int_typespec at a use, N0039) and the #5639 / #5909 constant lines.
6. **R6 — evalFunc's hex-literal and struct-pattern actuals** (r11u188 R3: E grid e04, e08, e10, e14-e24; V191/cc02's
   `h2('{a:4'h5, ...})`): golden keeps the call where ours folds; not decoded (a simple `g(4'h1)` folds in golden, DF/d01).
7. **R7 — `--elabuhdm` class_defn full name** (MG ma08 and every module class): the elaborated listing reads
   `work@top::v::plain` where golden keeps `work@sub::plain` (outside the gate).
8. **R8 — an interface home's parameterized class** (MG/m10): Surelog publishes it at the design root; ours lists
   nothing (the simple-interface path).
9. **R9 — pass 193's residues** (section 7, unchanged): pm01, pm07, CL/s12 + bc09, tf07 / uc22, the unsized detector,
   nested module arrays.
10. **R10 — named-argument and empty-slot calls** (DF/d02, d04): a ref_typespec golden lists and ours omits.

**Sister-ground faces met on the way** (not this ground; stopped at the decode): TB/t05 and DF/d01 value encodings
(`srlgRedIntSyn`, EmitHelpers.h; ExprEval's folded call values); V191/fd01 (`K`'s vpiActual inside a formal default,
ExprEmit's name binding, the call site being TaskFuncEmit's § formalDefaultNamedThroughFormal191 scope); FR/f03's enum
constant value type (ExprEmit); arb_idx_cast #322 (generate-scope bit_select ref_typespec names, ExprEmit); the UVM
rows' N0228 / N0224 / R1 / N0682 and Earlgrey's N1082 (r11u191's ground-A patch, `law_exprstmt.patch`).

## 9. Files

* `cases/{MG,EN,FR,SF,TB,DF,V191}/*/dut.sv` (SF cases also `types.svh` / `fns.svh`; V191/hd01, hd02 also `td.svh`):
  each names its law on its first line.
* `drivers/`: `env.sh` (pins, fence), `case.sh` (one case, `EL=1` the elaborated view), `grid.sh`, `compose.sh` +
  `composeana.py` (byte composition), `switches.sh`, `offcheck.sh`, `census.sh` + `censum.py` (the firing census),
  `predict.cpp` + `predict.sh` + `cc.sh` (the pristine predictor), `predcheck.py`, `sweep.sh`, `bvmirror.sh`,
  `moverdist.sh` + `rowdist.sh`, `row.sh`, `rowrun.sh`, `det.sh`, `attrib.sh`, `uvmdist.sh`, `ob.sh`, `dscase.py`
  (downstream per case), `probeheads.py`, `probesub.py`.
* `evidence/`: binaries, grids (law, elaborated MG, r11u191 alone, pass 188's E, V191), compositions, switches, offcheck,
  the two frozen predictions, both sweep logs, byteverify, prediction checks, mover distances, census compare,
  canaries, determinism, UVM distances and attribution, Rggen / Earlgrey distances, first records, downstream.
