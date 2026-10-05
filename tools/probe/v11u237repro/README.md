# v11u237 — adversarial verification of r11u237 (pass 237, the module/type ground)

Base `a219b848`, the implementer's patch `/tmp/r11u237.patch` applied clean on a fresh worktree (`/tmp/wt_v11u237`),
pristine in `/tmp/wt_v11u237pris`. **Verdict: three breaks on legal SV/Verilog where pristine was right; all
three fixed behind their own switches (four refinements, below). With the refinements the pass is good to land.**
The delivered patch is `/tmp/r11u237.verified.patch` = the implementer's patch + the refinements + this directory +
the regenerated tests/LAWS.md.

## Binaries (`evidence/binaries_md5.txt`, all against slang 12.0.0+545f88b2e, system-deps config, `-j 2`)

| binary | md5 | note |
|---|---|---|
| pristine | `3a7564e0ea1536071cd97aec47b0b40b` | equals the brief's base md5 |
| law (r11u237 patch alone) | `6fedad04cd416cdbabe5f2e84dc5cd90` | equals the implementer's `final` |
| fix (law + refinements, delivered) | `0975e00aed219d31a6055d1dbfed8ba7` | swept; `fix1`/`fix2` are intermediate builds (fix2 differs from fix only under `R11U237_OFF`) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | equals the implementer's |

## Reproduction of the implementer's numbers

* **Bytes**: the 152 plain-view databases of the implementer's 77 cases, re-run in their own worktree with my
  pristine and law binaries, match the md5s of `r11u237repro/evidence/grid/grid_v2.txt` on 152 of 152.
* **Grid** (`evidence/grid/grid_final.txt`, `gridcmp.txt`): over the implementer's 172 case-views pristine -> law
  reads 26 stage 1 -> STRICT_EQUAL, 26 STRICT_NOTEQUAL -> STRICT_EQUAL, 2 stage 1 -> STRICT_NOTEQUAL (CU u04),
  50 bytes moved, 68 identical, every exit code 0: identical to their summary. Away census on those case-views:
  0 lost, 1172 toward (identical).
* **Gate sweeps** (`evidence/sweep/sweep_{P,L,F}_summary.txt`; P pristine, L law, F fix; workdirs
  `/tmp/v11u237_w{P,L,F}`, every `cmds.txt` names only its own frozen binary, 3273 lines each):
  probe EQUAL 3460 + STRICT_NOTEQUAL 627 on all three, regressions 0, conversions 0, changes 0; surelog default
  469 + 11, testflags 465 + 9, 0/0/0 on all three; uhdm2rtlil pristine 802 + 1 per mode, law and fix 803 + 0 per
  mode, **regressions 0, conversions 2, changes 0**. Every sweep exits 1 only on the law index (`tests/LAWS.md` at
  the base is already stale against its own commit; the patch regenerates it).
* **CONVERSION, fresh rows** (`evidence/sweep/fresh_rows.txt`, results/ untouched):
  ```
  uhdm2rtlil.csv: cfg_func_width_loop,default,CMP_EQUAL,,,equal
  uhdm2rtlil.csv: cfg_func_width_loop,testflags,CMP_EQUAL,,,equal
  downstream.csv: cfg_func_width_loop,IDENTICAL,OK,OK,10,10,,
  ```
* **Downstream** (pristine and fix, one at a time): 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT on
  both, verdict diff 0 against the pristine sweep and against results/downstream_uhdm2rtlil.csv.
* **Byteverify** (`evidence/sweep/byteverify.txt`, `SELFCHECK=1`, 2568 surelog+uhdm2rtlil databases, same path
  sets, the negative control flags 2567 of 2568): fix against pristine 2 movers (cfg_func_width_loop d/t), law
  against pristine the same 2, **fix against law 0**. Downstream databases: 1 of 805 moves (cfg_func_width_loop).
  Probe databases: fix against law 0 of 4087 (the pristine probe sweep ran from another worktree path, so its bytes
  embed another source path; the implementer measured law against pristine 0 of 4087 and no law fires on the
  probe).
* **Prediction** (`evidence/census/predicted.txt`, frozen before the fix sweep, md5 `6daad565…`): fix against law
  0 databases anywhere; fix against pristine the three cfg_func_width_loop databases. Measured exactly. The firing
  census of the fix sweep (`evidence/census/fix_sweep_firings.txt`, `R11U237_TRACE`) names
  § evalFuncPkgParamVarSelKeepsCall237 on cfg_func_width_loop d/t and § unionRetVarAtTypeToken237 (predicate only, no
  byte) on rp32_r5p_{alu,bru,mdu,wbu} d/t, nothing else: no refinement fires on any corpus database or probe case
  (the trace's positive control: PS s04 logs `bitsArgNotReduced237v fw`).
* **Canaries** on the fix csvs: canaries.sh surelog ok=52 changed 0, uhdm2rtlil ok=16 changed 0; ctcan2.sh
  EXPECT_UNKNOWN=1 surelog PASS (58 ok), EXPECT_UNKNOWN=6 uhdm2rtlil PASS.
* **Determinism** (`drivers/det.sh`, three concurrent harness runs of the fix binary, `evidence/sweep/det_fix.txt`):
  one hash per row-mode on Earlgrey_0_1 and the five UVM rows, both modes; the hashes equal the fix and pristine
  sweeps' (Earlgrey_0_1, BuildUVMPkg and MiniAmiq default checked).
* **(1g)** confirmed: the `--elabuhdm` this_type recursion (the implementer's case b) segfaults (rc 139) in Surelog
  `-elabuhdm`, pristine and fix alike.

## The breaks (pristine right, r11u237 wrong, legal source) and the refinements

All four refinements sit in `src/R237.h` (`r11v237Law`): each reads its own `R11V237_<X>_OFF`; `R11V237_OFF` drops
all four (the law binary's bytes on 280 of 280 grid case-views); `R11U237_OFF` drops the six laws AND the four
refinements (pristine bytes on 280 of 280). Firings log through `tr237` (`R11U237_TRACE`).

1. **§ bitsArgNotReduced237v** (`R11V237_BITSARG_OFF`; ModuleEmit `r237PkgSelExec`'s `callFlow`, refining
   § evalFuncPkgParamVarSelKeepsCall237). The executor scanned the arguments of every system call, so
   `return $bits(ENC[i]) + i;` KEPT the call; golden FOLDS it (`$bits` takes the operand's type, evalFunc never
   reduces the select written inside it). Cases (first line `// § bitsArgNotReduced237v`): PS s04 (struct array),
   s14 (packed vector element), s17 (bare `$bits(ENC[i])`). Under the law each lost golden's elaborated
   cont_assign records (away census: s04 1 record lost); with the refinement the base's fold returns (bytes =
   pristine). Controls that still keep in golden and in ours: `$size(ENC[i])` s15, `$clog2(ENC[i])` s13,
   `$signed(ENC[i])` s16.
2. **§ bareStructParamReadKeeps237v** (`R11V237_BAREREAD_OFF`; ModuleEmit `r191ConstCallPoison`, refining
   § evalFuncPkgStructMemberFolds237). The law folds a member read of a same-package struct parameter whose
   pattern value is an unsized decimal, but golden KEEPS the call when the body ALSO reads the parameter whole:
   PM p10 `{S, 16'(S.e)} + i` and p12 `S + S.e + i` (first line `// § bareStructParamReadKeeps237v`); the law
   folded them (away census: p10 3 + 2 records lost, the elaborated func_call and its ref_objs). The refinement
   collects the parameters the body names outside a member access and abstains on them (bytes = pristine).
3. **§ kwDirectiveSvMode237v** (`R11V237_KWDIR_OFF`; TypeEmit `buildStructTs` / `buildUnionTs`, refining
   § vlogAggMemberKwSpan237). Surelog's ParseFile takes the lexer mode from the root file's PreprocessFile
   VerilogVersion when a `` `begin_keywords `` set one (SV3_1aPpTreeShapeListener `enterBegin_keywords_directive`;
   "1800-2005/2009/2012/2017" lex SystemVerilog; the last directive wins, `` `end_keywords `` does not reset it, and
   the extension is read only when no directive set a version). A `.v` root holding `` `begin_keywords "1800-2017" ``
   spans `logic [1:0]` whole in golden; the law spanned the keyword (VM v04: STRICT_EQUAL -> STRICT_NOTEQUAL
   endcol in both views, 10 + 8 records lost). The refinement scans the root file of the include chain (comments
   skipped) for the last directive and abstains on a 1800 version. Cases (`// § kwDirectiveSvMode237v`): v04,
   v09 (closed by end_keywords before the struct), v12 (directive after the module); v10 (the directive only in
   comments) still converts under the law.
4. **§ kwDirectiveSvModeEnum237v** (`R11V237_KWDIRENUM_OFF`; TypeEmit `buildEnumTs`, the same rule on pass 235's
   § vlogEnumBaseKwSpan235 and § vlogEnumByteBaseUnsigned235). Not a break of this pass (pristine already wrong),
   found by the same grid and fixed beside it: VM v11 (enum logic base, STRICT_NOTEQUAL endcol -> STRICT_EQUAL) and
   v13 (byte base: stage 1 -> STRICT_EQUAL). It moves no corpus or probe database: the only corpus roots holding
   `begin_keywords` are BeginKeywords and 1364_2005 (1364 versions, no enum, struct or union), and no tests/probe
   case holds one.

## Grid (fresh cases `cases/`, 54 case directories, both views; plus the implementer's 77 and 9 boundary cases)

`drivers/grid.sh` on the full list under 15 binary specs (pristine, law, fix, fix with `R11U237_OFF`,
`R11V237_OFF`, each refinement off, each of the six law switches off): 4200 + 2240 runs, every line carries `rc=`,
**every exit code 0** (four illegal drafts were rewritten before the counted grid: CU c08/c10 used a member select
on a call result our exporter does not support, VM v03 put `signed` after `logic` in Verilog mode (Surelog syntax
error), VM v08 used `typedef` under 1364-2005 keywords (slang rejects); v08 was dropped).

* pristine -> fix over 280 case-views: 37 stage 1 -> STRICT_EQUAL, 43 STRICT_NOTEQUAL -> STRICT_EQUAL, 4 stage 1 ->
  STRICT_NOTEQUAL, 88 bytes moved with the same verdict, 108 identical, **none leaving STRICT_EQUAL or
  judge-equality**. pristine -> law over the same: 6 EQUAL -> STRICT_NOTEQUAL (VM v04 the break; v09, v12 its
  siblings) and 67 records lost; law -> fix: 8 STRICT_NOTEQUAL -> EQUAL, 2 stage 1 -> EQUAL, 10 bytes moved, 0 lost.
* **Away census** (`evidence/grid/away_pri_fix.txt`, chain key and flat): pristine -> fix **0 lost, 1859 toward**;
  pristine -> law 67 lost (PM p10/p12, PS s04/s14/s17, VM v04/v09/v12).
* Each switch off alone returns only its own family (`gridcmp.txt`): PKGSEL 6 verdicts + 44 bytes, PKGMEMBER 32
  bytes, CLSUNION 36 verdicts + 8 bytes, CLSUNIONENUM 6 verdicts, UNIONRET 8 verdicts + 2 bytes, VLOGMEMKW 32
  verdicts + 4 bytes; BITSARG 6 bytes, BAREREAD 4 bytes, KWDIR 6 verdicts, KWDIRENUM 4 verdicts.
* **Keep or fold** (`evidence/grid/keepfold.txt`, `drivers/keepfold.py`: the elaborated cont_assign Rhs in golden,
  pristine, law and fix; `-` = no Rhs, the call kept) is how the stage-1 PS/PM cases are judged: their uhdm-cmp
  heads are the pre-existing `_weaklyReferenced` face.
* **Downstream** (`evidence/downstream/ds_*.txt`, `drivers/dscase.py`, the harness's `one()`) on the 42 `.sv` fresh
  cases: pristine -> fix 15 lanes improve (PS s01 s03 s07 s08 s09 s13 s15 s16 and PM p09 -> IDENTICAL, s02
  EQUIVALENT -> IDENTICAL, PM p02 p03 p04 p11 p13 -> EQUIVALENT), none worse.

| case | law (first line) | what | plain pri -> fix | -elabuhdm pri -> fix | downstream pri -> fix |
|---|---|---|---|---|---|
| CU/c01 | § clsTdUnionBuilt237 | an unpacked union typedef in a class with a struct member and a class variable | stage1 -> EQ | stage1 -> EQ | IDENTICAL -> IDENTICAL |
| CU/c02 | § clsTdUnionBuilt237 | a packed class union read by a module variable through the class scope | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| CU/c03 | § clsTdUnionBuilt237 | a parameterized class union with a type-parameter member and two specializations | stage1 -> stage1 | stage1 -> stage1 | IDENTICAL -> IDENTICAL |
| CU/c04 | § clsTdUnionBuilt237 | class b's union nests class a's union | stage1 -> EQ | stage1 -> EQ | IDENTICAL -> IDENTICAL |
| CU/c05 | § clsTdUnionBuilt237 | a union typedef inside a class inside a module | stage1 -> SNE:fullname | stage1 -> SNE:fullname | IDENTICAL -> IDENTICAL |
| CU/c06 | § clsTdUnionClsEnumMemberShares237 | a class union whose member is another class's enum typedef, and a third class reads it | stage1 -> stage1 | stage1 -> stage1 | IDENTICAL -> IDENTICAL |
| CU/c07 | § unionRetVarAtTypeToken237 | a package function returning a package union typedef by its qualified name, called in a cont_assign | stage1 -> stage1 | stage1 -> stage1 | IDENTICAL -> IDENTICAL |
| CU/c08 | § unionRetVarAtTypeToken237 | an interface function returning a union typedef of the interface | SNE:line -> EQ | SNE:line -> EQ | IDENTICAL -> IDENTICAL |
| CU/c09 | § unionRetVarAtTypeToken237 | an out-of-body class method returning the class's union typedef | stage1 -> EQ | stage1 -> EQ | IDENTICAL -> IDENTICAL |
| CU/c10 | § unionRetVarAtTypeToken237 | a module function returning a union typedef declared in a package, imported | EQ -> EQ | EQ -> EQ | IDENTICAL -> IDENTICAL |
| CU/c11 | § clsTdUnionBuilt237 | a tagged union typedef in a class | stage1 -> EQ | stage1 -> EQ | IDENTICAL -> IDENTICAL |
| PM/p01 | § evalFuncPkgStructMemberFolds237 | unsized based hex member value | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PM/p02 | § evalFuncPkgStructMemberFolds237 | 64-bit member with an unsized decimal value | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> EQUIVALENT |
| PM/p03 | § evalFuncPkgStructMemberFolds237 | member part-select of an unsized decimal member | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> EQUIVALENT |
| PM/p04 | § evalFuncPkgStructMemberFolds237 | a signed packed struct | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> EQUIVALENT |
| PM/p05 | § evalFuncPkgStructMemberFolds237 | parenthesized decimal member value | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PM/p06 | § evalFuncPkgStructMemberFolds237 | decimal member read twice beside a sized one | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PM/p07 | § evalFuncPkgStructMemberFolds237 | unsized decimal value read in a loop bound | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PM/p08 | § evalFuncPkgStructMemberFolds237 | a negative decimal member value | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PM/p09 | § evalFuncPkgStructMemberFolds237 | int members with unsized decimal values | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> IDENTICAL |
| PM/p10 | § bareStructParamReadKeeps237v | the whole struct parameter in a concatenation beside a cast of a member | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PM/p11 | § evalFuncPkgStructMemberFolds237 | a cast of an unsized decimal member | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> EQUIVALENT |
| PM/p12 | § bareStructParamReadKeeps237v | the whole struct parameter read beside a member | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PM/p13 | § evalFuncPkgStructMemberFolds237 | a concatenation of two unsized decimal members | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> EQUIVALENT |
| PM/p14 | § evalFuncPkgStructMemberFolds237 | control: the whole struct parameter in a concatenation, no member read (no law fires; golden keeps, the base folds) | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PS/s01 | § evalFuncPkgParamVarSelKeepsCall237 | bit-select of a packed vector package parameter by a formal | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> IDENTICAL |
| PS/s02 | § evalFuncPkgParamVarSelKeepsCall237 | element select of an unpacked int array package parameter by a formal | stage1 -> stage1 | stage1 -> stage1 | EQUIVALENT -> IDENTICAL |
| PS/s03 | § evalFuncPkgParamVarSelKeepsCall237 | indexed part-select of a packed vector package parameter by a formal | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> IDENTICAL |
| PS/s04 | § bitsArgNotReduced237v | the select only inside $bits() | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PS/s05 | § evalFuncPkgParamVarSelKeepsCall237 | the select behind a short-circuit && whose left side is false | stage1 -> stage1 | stage1 -> stage1 | IDENTICAL -> IDENTICAL |
| PS/s06 | § evalFuncPkgParamVarSelKeepsCall237 | a function of package r selects package q's parameter by its formal | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PS/s07 | § evalFuncPkgParamVarSelKeepsCall237 | a literal argument (no parameter) to the selecting function | SNE:type -> EQ | stage1 -> EQ | DIVERGENT -> IDENTICAL |
| PS/s08 | § evalFuncPkgParamVarSelKeepsCall237 | package q's function calls package r's function that selects r's parameter by its formal | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> IDENTICAL |
| PS/s09 | § evalFuncPkgParamVarSelKeepsCall237 | two-dimensional select of a packed 2-D package parameter by two formals | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> IDENTICAL |
| PS/s10 | § evalFuncPkgParamVarSelKeepsCall237 | the cont_assign inside an interface | stage1 -> stage1 | stage1 -> stage1 | IDENTICAL -> IDENTICAL |
| PS/s11 | § evalFuncPkgParamVarSelKeepsCall237 | unpacked array of structs, member of the selected element | stage1 -> stage1 | stage1 -> stage1 | IDENTICAL -> IDENTICAL |
| PS/s12 | § evalFuncPkgParamVarSelKeepsCall237 | a local variable copies the parameter, then the local is selected (no select of the parameter) | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PS/s13 | § evalFuncPkgParamVarSelKeepsCall237 | the select only inside $clog2() | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> IDENTICAL |
| PS/s14 | § bitsArgNotReduced237v | the select only inside $bits() of a packed vector element | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| PS/s15 | § evalFuncPkgParamVarSelKeepsCall237 | the select only inside $size() of a packed vector element | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> IDENTICAL |
| PS/s16 | § evalFuncPkgParamVarSelKeepsCall237 | the select inside $signed() | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> IDENTICAL |
| PS/s17 | § bitsArgNotReduced237v | the select only inside $bits() of a packed vector element, bare | stage1 -> stage1 | stage1 -> stage1 | DIVERGENT -> DIVERGENT |
| VM/v01 | § vlogAggMemberKwSpan237 | two packed dimensions on a logic member | SNE:endcol -> EQ | SNE:endcol -> EQ | - -> - |
| VM/v02 | § vlogAggMemberKwSpan237 | a bit member sized by a parameter expression | SNE:endcol -> EQ | SNE:endcol -> EQ | - -> - |
| VM/v03 | § vlogAggMemberKwSpan237 | a nested anonymous struct member and a union member in Verilog mode | SNE:endcol -> EQ | SNE:endcol -> EQ | - -> - |
| VM/v04 | § kwDirectiveSvMode237v | begin_keywords 1800-2017 in a .v root | EQ -> EQ | EQ -> EQ | - -> - |
| VM/v05 | § vlogAggMemberKwSpan237 | a .sv root including a .vh header that declares the struct (SystemVerilog mode inherited: control) | EQ -> EQ | EQ -> EQ | - -> - |
| VM/v06 | § vlogAggMemberKwSpan237 | a struct member written through a macro whose body carries the type, the use on a second line | SNE:endcol -> EQ | SNE:endcol -> EQ | - -> - |
| VM/v07 | § vlogAggMemberKwSpan237 | an unpacked struct in a function formal and a union of struct members in a package | SNE:endcol -> EQ | SNE:endcol -> EQ | - -> - |
| VM/v09 | § kwDirectiveSvMode237v | begin_keywords 1800-2017 closed by end_keywords before the struct | EQ -> EQ | EQ -> EQ | - -> - |
| VM/v10 | § kwDirectiveSvMode237v | begin_keywords 1800-2017 only inside comments | SNE:endcol -> EQ | SNE:endcol -> EQ | - -> - |
| VM/v11 | § kwDirectiveSvModeEnum237v | pass 235's enum base under begin_keywords 1800-2017 in a .v root | SNE:endcol -> EQ | SNE:endcol -> EQ | - -> - |
| VM/v12 | § kwDirectiveSvMode237v | begin_keywords 1800-2017 after the module | EQ -> EQ | EQ -> EQ | - -> - |
| VM/v13 | § kwDirectiveSvModeEnum237v | pass 235's byte enum base under begin_keywords 1800-2017 in a .v root | stage1 -> EQ | stage1 -> EQ | - -> - |

## Residues, ranked (measured on the fresh grid; none is a break: law = pristine on each)

1. **§ evalFuncPkgStructMemberFolds237's distinguisher is narrower than golden's.** Golden also FOLDS when the
   member's pattern value is an unsized based literal (`'h5`, PM p01), parenthesized (`(5)`, p05), negative (`-5`,
   p08) or a sized DECIMAL read beside it (`'{5, 8'd6}` read as `S.e + S.m`, p06); it keeps for sized HEX values
   (the implementer's m13-m21) and for whole-parameter reads (p10, p12, p14). The keep/fold boundary looks like the
   literal's radix (Surelog's HEX constant), not its sizing: not decoded in Surelog's source, so not written. p14
   (whole read, no member access) is folded by the base where golden keeps (ModuleEmit `r191ConstCallPoison` has no
   branch for it). p07 (the member read in a nested callee's loop bound): golden keeps, the base folds.
2. **$bits value**: with § bitsArgNotReduced237v the fold returns, but golden's folded value is `1` for
   `$bits(ENC[i])` (s17; s04/s14 `1 + i`) where ours is the true width (8, 9): Surelog's evalFunc cannot size the
   select. Downstream DIVERGENT on both binaries (s04, s14, s17).
3. **§ evalFuncPkgParamVarSelKeepsCall237 leaves**: a function of ANOTHER package selecting `q::ENC[i]` (PS s06:
   golden folds to a wrong `BIN:1`, ours UINT:3, DIVERGENT on both) and a local copy selected by the formal (s12:
   golden keeps, ours folds, DIVERGENT on both). The interface cont_assign (s10) keeps on both sides.
4. **Class unions** beside the implementer's CU u04: a class union read by a module variable through the class
   scope (CU c02, stage 1 on both, 95 -> 90 cmp lines, downstream DIVERGENT on both), a parameterized class union
   with a type-parameter member (c03, 92 -> 51 lines), a class union whose member is another class's enum read by a
   third class (c06, 92 -> 84), a union in a class declared inside a module (c05: stage 1 -> STRICT_NOTEQUAL
   fullname), a package function returning `p::u_t` (c07, stage 1 on both on another face).
5. **The root-file keyword-version model** is a text scan: a `` `begin_keywords `` inside an inactive `` `ifdef ``
   branch, inside a macro body or inside an included header is not modelled (Surelog's per-file PreprocessFile
   version for an include was not decoded); a `.sv` root holding a 1364 version (Surelog lexes it in Verilog mode)
   is not modelled either (no law fires there; slang rejects SV-only constructs under 1364 keywords anyway).
6. The implementer's residues stand unchanged: CU u04; the Verilog-mode port and module-variable keyword spans;
   FW g19 stage 1; FW g10/g13/g23 and FM m13-m21 downstream DIVERGENT on both binaries; pass 235's ca/a02, ui/u07,
   ui/u10, ui/w01; brief items (2), (3), (4), (7) not attempted by the implementer; the ground-A faces with their
   call sites as the implementer lists them (BuildUVMPkg #77588/#79836 and Scoreboard #79148 StmtEmit
   `MakeForeach_stmt`; SimpleUVM #75572/#75684 at § implicitNetMintNoFile131; MiniAmiq/SeqDriver #64390 the
   svaunit_pkg import-clone fold name and #64612 StmtEmit foreach; FuncStructVal #7975 ParamEmit
   `stampEvalFuncLeftovers` and #13254; BlackBePipeInt; the named-argument call stamps; CA c05; Earlgrey's
   emitMixedHierPath names).

## Drivers (`drivers/`; each resolves paths from the repository and reads `$FENCED` fail-closed through env.sh)

env.sh, case.sh, grid.sh, gridcmp.py, awaycase.py, dscase.py, det.sh (copied from r11u237repro with this pass's
scratch `/tmp/v11u237_s` and binaries `/tmp/v11u237_bin`), keepfold.py (new: the elaborated cont_assign Rhs per
producer; refuses a fenced path; refuses an unexecutable `UHDM_DUMP`).

## Process

* **Fence breach (reported)**: to learn whether the keyword-directive refinements could move a corpus row I ran one
  `grep -rl begin_keywords` over the corpus source trees and filtered its OUTPUT by `$FENCE_RE`; grep itself read
  every file under the trees, the four fenced tests' sources included. Nothing fenced was printed, kept or used
  (the listing named only unfenced files), no binary ran on a fenced source, and the refinements' trigger was not
  derived from it, but the scan read fenced sources and is recorded here as a breach. A fail-closed scan must prune
  the fenced directories before reading (`find ... -prune`).
* The fix binary was rebuilt twice after the first refinement build (adding the enum refinement, then making
  `R11U237_OFF` drop the refinements); the first fix sweep was stopped before it wrote a database and rerun with the
  final binary; every number above is the final binary's (fix2 and fix write identical bytes on all 280 case-views).
* Every case file's first line names the law it tests; the four fresh-case first lines were relabelled after the
  grid and the 54 fresh cases re-run under nine specs (972 case-views, verdicts unchanged:
  `evidence/grid/grid_ver_relabelled.txt`).
* No patch file in this directory; results/, tests/probe/ and third_party/ untouched.
