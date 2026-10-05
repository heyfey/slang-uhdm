# r11u237 — pass 237, the module/type ground (pair B, refill after pass 235)

Base `a219b848`. Production files: `src/UhdmExporter.cpp`, `src/TypeEmit.cpp`, `src/TaskFuncEmit.cpp`,
`src/ModuleEmit.cpp`, the new header `src/R237.h`. Six laws, each behind its own switch; `R11U237_OFF` drops all six
(pristine bytes on every grid case-view, below); `R11U237_TRACE=<dir>` writes one `<pid>.237` file per process naming
every firing (first line `OUT <-o path>`).

## Verdict per targeted row

| row-mode | base (results/) | fresh law sweep | law |
|---|---|---|---|
| uhdm2rtlil cfg_func_width_loop default | STRICT_NOTEQUAL differ:type(1) | **CMP_EQUAL, strict equal** (CONVERSION) | § evalFuncPkgParamVarSelKeepsCall237 |
| uhdm2rtlil cfg_func_width_loop testflags | STRICT_NOTEQUAL differ:type(1) | **CMP_EQUAL, strict equal** (CONVERSION) | § evalFuncPkgParamVarSelKeepsCall237 |
| downstream cfg_func_width_loop | IDENTICAL | IDENTICAL (bytes move, verdict holds) | same |

The fresh csv rows (`evidence/sweep/fresh_rows_u2r.csv`, `fresh_rows_downstream.csv`):

```
cfg_func_width_loop,default,CMP_EQUAL,,,equal
cfg_func_width_loop,testflags,CMP_EQUAL,,,equal
cfg_func_width_loop,IDENTICAL,OK,OK,10,10,,
```

`results/` is untouched. No other corpus row-mode moves a byte.

## The laws

1. **§ evalFuncPkgParamVarSelKeepsCall237** (`R11U237_PKGSEL_OFF`; ModuleEmit `r237PkgSelKeeps`, called beside
   § evalFuncSelectKeepsCall148, § evalFuncCastMemberKeepsCall191 and § dfltArgTaintExec204v in `emitContAssigns`
   and `emitGenScopes`). The producer is the one § evalFuncSelectKeepsCall148 decodes: `UhdmWriter::writeCont_assign`'s
   trailing `reduceExpr` -> `ExprEval::evalFunc`; only a constant result replaces the Rhs. A select (bit, part or
   indexed part) whose base is a PACKAGE parameter and whose index reads a formal or a variable cannot be reduced:
   the bit_select branch of `ExprEval::reduceExpr` hands the base to `getObject`, which resolves a package parameter to
   its `parameter` object, and no select branch reads a `parameter`. An index made only of literals, parameters and enum
   values is folded when Surelog compiles the package function (FW g03, g13). Unlike § evalFuncSelectKeepsCall148's P
   branch the select may sit in a nested callee or behind loops and branches: evalFunc EXECUTES the body, so the law runs
   the call with slang's evaluator (the executor of § dfltArgTaintExec204v) and keeps the call only when the execution
   REACHES such a select; a branch, loop or `?:` branch not taken does not keep (g08, g15, g16, g17); a statement or
   expression the executor does not model abstains (pristine). cfg_func_width_loop is FW f01 (`maxw` -> `fwidth` ->
   `ENC[i].e`): golden keeps `q::maxw(M)` in the elaborated cont_assign, the base folded it to UINT:10.
2. **§ evalFuncPkgStructMemberFolds237** (`R11U237_PKGMEMBER_OFF`; ModuleEmit `r191ConstCallPoison`, refining the M
   branch of § evalFuncCastMemberKeepsCall191). A member read of a package parameter of a packed struct, read by a
   function of the same package, FOLDS in golden when the member's value in the parameter's assignment pattern is an
   UNSIZED DECIMAL literal (m01 `S.e + i`, m02, m04 through a nested pattern, m07 wildcard import, m08 gen scope, m11
   named pattern, m12 default pattern, m15, m18). It KEEPS, as the M branch says, when the value is sized (`4'h1`:
   r11v131's pat/k03_read_in_func, m13, m14, m16, m17, m19-m21), when the parameter's value is a concatenation (m09,
   m10), for a module-local function reading `q::S.e` (m03) and for a packed union (m05). The FM cases are stage 1 at
   the base on an unrelated face (`_weaklyReferenced` string_typespec members of the pattern), so no FM case-view
   changes verdict; the law moves 20 case-views' bytes, every one toward golden (away census below) and turns nine
   downstream lanes from DIVERGENT to EQUIVALENT or IDENTICAL (the base wrote an elaborated cont_assign with no Rhs
   where golden folds).
3. **§ clsTdUnionBuilt237** (`R11U237_CLSUNION_OFF`; UhdmExporter `buildClassTypedefTs`). A union typedef declared
   in a class is a typedef like the struct one (Surelog's class DataTypeMap compiles every `typedef` of the class body
   through `compileTypespec`, union included); the base had no union branch, so the class listed no typedef and a member
   declared with it bound nothing (pass 235's rs/r05, stage 1). Built as the struct branch builds, with the same member
   path (the § classTdStructMemberPkgPath146 package prefix included).
4. **§ clsTdUnionClsEnumMemberShares237** (`R11U237_CLSUNIONENUM_OFF`; TypeEmit `buildUnionTs`). The union builder's
   twin of § clsTdClsEnumMemberShares235: a union member written with an enum typedef declared in a class reads that
   typedef's own listing object (reached once law 3 builds class-scope unions; CU u01, u10).
5. **§ unionRetVarAtTypeToken237** (`R11U237_UNIONRET_OFF`; TaskFuncEmit `emitTaskFuncs`). A union typedef's return
   variable is located at the written return type exactly as the struct_var is (CU u13 against its struct twin u08).
   The trace sits in the predicate: on the rp32_r5p_{alu,bru,mdu,wbu} rows it fires on `riscv_isa_i_pkg::enc32`
   (a package function returning the package union `op32_t`) whose union_var the base already located at
   `op32_t` (417:20-26), so those databases keep their bytes.
6. **§ vlogAggMemberKwSpan237** (`R11U237_VLOGMEMKW_OFF`; TypeEmit `buildStructTs` and `buildUnionTs`).
   § vlogEnumBaseKwSpan235's lexer rule on a struct or union MEMBER: in Verilog lexer mode `bit` and `logic` are type
   identifiers, so a member written `logic [1:0] g;` compiles through `compileTypespec`'s slStringConst branch and its
   logic_typespec / bit_typespec spans the identifier token alone (v11u235's vk/k11). A member without a packed
   dimension already spans the keyword; a signed one, `reg` and every SystemVerilog-mode file (and every file under
   `--sverilog`, `grid_vm_svm_v2.txt`: 26 of 26 case-views pristine bytes) keep the whole type.

## Cases (tools/probe/r11u237repro/cases, 77; every first line names its law)

`evidence/grid/grid_table.md` lists every case with its law and its status in both views, pristine -> law, and the
downstream verdict pristine -> law. Families: **FW** (29, § evalFuncPkgParamVarSelKeepsCall237: f01 the
cfg_func_width_loop shape, f02-f06 and g01-g23 the shapes and contexts named in law 1), **FM** (21,
§ evalFuncPkgStructMemberFolds237: m01-m21 as in law 2, m06 a module parameter control), **CU** (14: u01-u11
§ clsTdUnionBuilt237 except u10 § clsTdUnionClsEnumMemberShares237 — $unit class, parameterized class, unused
typedef, method formal and return, local variable, two classes with the same union name, the no-builtin view u07, the
struct twin u08 as control; u12-u14 § unionRetVarAtTypeToken237 — package, module and class-method returns), **VM**
(13, § vlogAggMemberKwSpan237, Verilog-mode `.v` roots: k01 v11u235's k11, k02 package struct, k03 union, k04 scalar
and k05 `reg` controls, k06 the same text in a `.sv` root (control), k07 CRLF, k08 the struct in a macro body, k09
keyword and dimension on two lines, k10 nested struct and two dimensions, k11 a `.v` root including a header that
declares the struct, k12 a struct-typed port and formal, k13 two `.v` files with the same declarator positions).

## Measurements (binaries: `evidence/binaries_md5.txt`)

* Pristine `/tmp/r11u237_bin/pristine` md5 `3a7564e0ea1536071cd97aec47b0b40b` (= the main tree's build/slang-uhdm);
  law `/tmp/r11u237_bin/final` md5 `6fedad04cd416cdbabe5f2e84dc5cd90`; both against slang 12.0.0+545f88b2e.
* **Grid** (`evidence/grid/grid_v2.txt`, `drivers/grid.sh`, every line carries `rc=`): the 77 cases plus the 9
  existing tools/probe cases the firing census named (the boundary), both views, nine binaries (pristine, law,
  law + `R11U237_OFF`, law with each switch off alone): 1548 runs, every exit code 0. Pristine -> law over 172
  case-views: 26 stage 1 -> STRICT_EQUAL, 26 STRICT_NOTEQUAL -> STRICT_EQUAL, 2 stage 1 -> STRICT_NOTEQUAL (CU u04),
  50 bytes moved with the same verdict, 68 identical; **none leaving STRICT_EQUAL or judge-equality**. Own cases
  (154): 20 + 22 + 2 entering; boundary (18): r11u235repro rs/r05, v11u146repro ct/c2_union, v11u209repro CS/v04
  stage 1 -> EQUAL, r11u155repro UF/f08 and v11u235repro vk/k11 STRICT_NOTEQUAL -> EQUAL (both views each);
  r11u217verify CS/c02 stage 1 with 92 -> 68 uhdm-cmp lines; r11v131repro pat/k03_read_in_func, v11u209repro CS/v12
  and v11u235repro vk/k06 unchanged. `R11U237_OFF`: pristine bytes on 172 of 172. Each switch alone
  (`evidence/grid/gridcmp.txt`): PKGSEL returns FW f01 and g09 (both views) to their base verdicts plus 24 byte
  moves; PKGMEMBER 20 byte moves; CLSUNIONENUM CU u01, u10 and r05 (6 case-views); CLSUNION 26 verdicts plus 2 byte
  moves; UNIONRET CU u13 and r11u155 f08 (4 verdicts) plus 2 byte moves; VLOGMEMKW 20 verdicts (VM and vk/k11)
  plus 4 byte moves: every switch returns exactly its
  own cases, none is a duplicate.
* **Away-moved-record census** on the grid (`evidence/grid/away_v2.txt`, `drivers/awaycase.py`, chain key and flat):
  0 lost, 1172 toward. On the sweeps (`evidence/sweep/away_sweeps.txt`, `drivers/awayall.py`): 2 databases differ,
  0 lost, 6 toward.
* **Downstream on the cases** (`evidence/downstream/`, `drivers/dscase.py`, the harness's `one()`): 64 `.sv` cases,
  pristine 38 IDENTICAL + 26 DIVERGENT, law 48 IDENTICAL + 7 EQUIVALENT + 9 DIVERGENT; 17 lanes move toward
  (FM m01 m02 m04 m07 m11 m12 -> EQUIVALENT, m08 m15 m18 -> IDENTICAL, FW g01 g11 g14 g18-g21 -> IDENTICAL, g02 ->
  EQUIVALENT), none away. The 9 still DIVERGENT were DIVERGENT on pristine (FM m13 m14 m16 m19-m21: the KEEP side,
  where golden writes the same empty elaborated cont_assign; FW g10 g13 g23).
* **Firing census before the sweep** (`evidence/census/`): corpus both modes with `--filter` built from `$FENCED`
  (`drivers/corpus.sh`): § evalFuncPkgParamVarSelKeepsCall237 on cfg_func_width_loop d/t, § unionRetVarAtTypeToken237
  on rp32_r5p_{alu,bru,mdu,wbu} d/t, nothing else; the census sweep itself read 0 regressions and the two
  conversions. tests/probe (4087 cases, `drivers/fire.py`): no firing. tools/probe both views (15591 cases): the 8
  boundary cases above (the r11u237repro cases excluded).
* **Prediction** frozen before the law sweep (`evidence/census/predicted.txt`, `drivers/predict.py`, 10 databases,
  body md5 `8106e295638ad755b88b1a20dbfbc967`): cfg_func_width_loop d/t and the 8 rp32 row-modes.
* **Gate sweeps** (`tests/sweep.sh --jobs 3`, pristine `/tmp/r11u237_wP`, law `/tmp/r11u237_wL`;
  `evidence/sweep/*_summary.txt`): probe EQUAL 3460 + STRICT_NOTEQUAL 627, regressions 0, conversions 0, changes 0;
  surelog default CMP_EQUAL 469 + STRICT_NOTEQUAL 11, testflags 465 + 9, regressions 0, conversions 0, changes 0;
  uhdm2rtlil 803 + 0 per mode (1604 + 2 -> 1606 + 0), regressions 0, **conversions 2** (cfg_func_width_loop d/t),
  changes 0; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, verdict diff 0 against the
  pristine sweep and against results/downstream_uhdm2rtlil.csv. Both sweeps exit 1 only on the stale law index
  (regenerated in this patch).
* **Byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`, `evidence/sweep/byteverify.txt`): surelog
  0 movers of 960, uhdm2rtlil 2 of 1608 (cfg_func_width_loop d/t), downstream 1 of 805 (cfg_func_width_loop),
  probe 0 of 4087 (same path sets; the negative control flags differing files). Every mover predicted; the 8 rp32
  predictions are predicate-only firings (law 5). No UVM-family coin moved.
* uhdm-cmp on every touched row: cfg_func_width_loop d/t 0 lines (CMP_EQUAL); the rp32 rows keep their bytes.
* **Determinism** (`drivers/det.sh`, three concurrent harness runs per binary, `evidence/det/`): one hash per
  row-mode on Earlgrey_0_1 and the five UVM rows, both modes, both binaries, and the law's hashes equal pristine's.
* **Canaries**: canaries.sh on both sweep csvs ok=52 (surelog) and ok=16 (uhdm2rtlil), changed 0; ctcan2.sh
  EXPECT_UNKNOWN=1 on surelog PASS (58 ok), EXPECT_UNKNOWN=6 on uhdm2rtlil PASS.

## Brief items

* **(1a)** rs/r05: cleared (law 3 + law 4), both views STRICT_EQUAL. **(1b)** ui/u07 and **(1c)** ui/u10 (pass 235's
  cases): no law fires, unchanged. **(1d)** ca/a02 and **(1f)** ui/w01: unchanged. w01 decoded: a class variable
  typed by an imported package vector typedef binds the memoized bare copy (TypeEmit `bareScalarTdCopyOf`), whose
  alias ref is named after the copy alone; golden names it from the variable (`work@env::v::byte_t`, and
  `q::env::v::byte_t` for a package class; a `p::byte_t` qualified spelling is a different face: the copy's name).
  The fix needs a per-variable copy or a rename at the class-variable writer; not written.
* **(1e)** v11u235 vk/k11: cleared (law 6). Decoded beside it, not written: a Verilog-mode PORT written
  `input logic [3:0] i` (ANSI or non-ANSI) or `input bit [3:0]` spans the keyword in golden on every occurrence
  (port, def-view net, elab net); a module variable `logic [3:0] r;` spans the keyword on the elaborated logic_var
  only (the def-view net keeps the whole type, and the row is stage 1 at the base on the netType model); a function
  formal keeps the whole type (VM k12's residue).
* **(1g)** The `--elabuhdm` segfault (`evidence/crash/elab_recursion_cases.txt`): UHDM's
  `ElaboratorListener::enterVariables` -> `propagateParamAssign` recurses without bound over class_defn -> static
  class_var -> class_typespec `this_type` -> `Class_defn` -> the same class_defn (gdb on the pristine binary: 64971
  frames of `propagateParamAssign` under `realMain`'s `listenDesigns`). **Surelog `-elabuhdm` segfaults identically**
  on the same sources (cases b and d, exit 139; a and c run on both). The crash is the shared elaborator's, not this
  ground's; golden writes no database there, so no guard is written.
* **(1h)** The BuildUVMPkg odd database did not recur: 6 more runs per binary per mode, one hash.
* **(2)** BuildUVMPkg d/t and Scoreboard d: no law of this pass moves them (bytes identical). Their heads after this
  pass: BuildUVMPkg #77588 file (string_typespec of the foreach loop variable, StmtEmit MakeForeach_stmt) then
  #79836 type (string_typespec vs our array_typespec at uvm_pkg.sv 41169, the same site); Scoreboard #79148 type
  (the same face at uvm_component.svh 3380); SimpleUVM #75572 line then #75684 file (`this` net minted at
  § implicitNetMintNoFile131) then #78752 the foreach face; MiniAmiq #64390 fullname (the svaunit uvm_revision fold
  name) then #64612 depth (the `foreach(arg[i])` loop variable `_byte` at uvm_misc.svh 378, StmtEmit). All ground A.
  The module/type clusters N0051 ... N0254 behind them were not attempted.
* **(3), (4), (7)** not attempted.
* **(5)** Earlgrey_0_1: no law moves it (bytes identical, deterministic).
* **(6)** cfg_func_width_loop: the fold is made in ModuleEmit `emitContAssigns` (the `constCallFold` the keep test
  gates), so the law is on this ground: converted. FuncStructVal #7975: golden's two `operation` records under
  typespec_member NonIdempotentAddrBase (the evaluator's member annotations of `1024'({64'b0, 64'b0})`); map 15
  re-routes N0891 to ground A (ParamEmit `stampEvalFuncLeftovers`, pass 228's decode): not written. BlackBePipeInt:
  ground A, not touched.

## Residues, ranked

1. CU u04: a class-scope union typedef used as a method formal and return type: golden locates the use-site copy at
   the written type token (6:18-21), ours at the typedef (5:11-57); its struct twin u08 is equal.
2. Verilog-mode ports and module variables written `logic`/`bit` with a packed dimension (above; VM k12).
3. FW g19 (the call in a generate block): stage 1 on another face, downstream IDENTICAL after the law; FW g10, g13,
   g23 and FM m13-m21 downstream DIVERGENT on both binaries.
4. ui/w01 (the class variable's alias name); ca/a02; ui/u07; ui/u10 (pass 235's).
5. The ground-A faces: BuildUVMPkg #77588/#79836 and Scoreboard #79148 (StmtEmit MakeForeach_stmt), SimpleUVM
   #75572/#75684 (§ implicitNetMintNoFile131), MiniAmiq/SeqDriver #64390 (svaunit_pkg import clone fold name) and
   #64612 (StmtEmit foreach), FuncStructVal #7975 (ParamEmit `stampEvalFuncLeftovers`) and #13254, BlackBePipeInt,
   the named-argument call stamps, the CA c05 operation call-argument stamp, Earlgrey's emitMixedHierPath names.

## Process

* This pass resumed a leftover worktree whose earlier session had ended after building the final binary; every
  number above was re-measured with the frozen binaries in this session (the grid rerun, the prediction frozen from
  the census of the final binary before the law sweep).
* Drivers (`drivers/`, all resolve paths from the repository and read `$FENCED` fail-closed, directly or through env.sh; there is no compiled helper): env.sh, case.sh, grid.sh, gridcmp.py,
  awaycase.py, awayall.py, fire.py, predict.py, corpus.sh, det.sh, rowhead.sh, dscase.py.
* Nothing fenced was opened, read or run; the corpus census ran with a `--filter` built from `$FENCED`; the fence
  scan of this directory reads 0 (positive control 1).
