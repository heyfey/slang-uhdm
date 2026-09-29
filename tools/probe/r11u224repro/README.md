# r11u224 — the expression/parameter ground: string literals re-lexed by the preprocessor, continued literals' owners, `::` joins in package and class scope, lvalue path indices, `new[...]` selects, the lvalue of a class `new`, BlackBePipeInt's AllPackages cast-width mark; pass 215's writer stamp measured against r11u214's; the split switches of four cross-ground landings

Base: `551c9751` (pass 220). Ground: src/ExprEmit.cpp, src/ParamEmit.cpp, src/StmtEmit.cpp, src/EmitHelpers.h and a
new header src/R224.h (this pass's switch and trace helpers). Nothing under results/, third_party/ or tests/ changes
except the regenerated tests/LAWS.md. The patch is `/tmp/r11u224.patch` (git diff against `551c9751`, this directory
included).

## 0. Verdicts

| target (brief item) | before -> after (fresh csv rows, [evidence/sweeps/](evidence/sweeps/)) | law(s) |
|---|---|---|
| (1) T/t12 backtick-tab, T/t14 double backtick, SL s30-s32 s35 s36 s38 s39 | all STRICT_NOTEQUAL `endcol` -> **EQUAL** in both views (decoded in Surelog's `SV3_1aPpTreeShapeListener::enterString` and the preprocessor lexer's ESCAPED_IDENTIFIER rule) | § strLitPpEscIdShift224 |
| (1) K/k04 (conditional ending at a continued literal), SL s48 (class property), SL s50 (variable declaration) | `endline` -> **EQUAL** in both views | § strLitContOwnerEnd224 |
| (1) K/k09 (continued literal from a macro) | unchanged, wrong to wrong (a macro-born literal; residue) | none |
| (1) C/c23 (`p1::c::f.arr[i].v[k+:2]::k`) | `fullname` -> **EQUAL** in both views | § ipsBasePfxScopeJoin224 (+ § ipsWidthPfxByPathInScope224 for a class-parameter width) |
| (1) G/g07 (a var_select as an lvalue) | `fullname` -> **EQUAL** in both views | § hpLvSelIdxNamesByPath224 (+ § hpLvSelColumnJoin224 in class scope) |
| (1) NW/w17 (`new[arr[k+1] + 2]`) | `fullname` -> **EQUAL** | § newArrayBitSelIdxOpStripped224 (+ § newArrayVarSelStripped224 for `new[arr[k+1][k-1]]`) |
| (1) C/c21, C/c22 (a call or a part select as a clone's select index) | unchanged (residue) | none |
| (2) pass 215's stamp against r11u214's writer law | measured (section 6): at the base R11U215_TDALIAS_OFF and R11U215_ENUMCLONE_OFF move no dump-visible record on any of the 4087 probe cases and on the eleven corpus row-modes the stamp fires on; byte-only movers, so no inert switch is added | none |
| (3) the UVM A families | two new families of every UVM row-mode's first records closed: the lvalue of a class `new` (`rw.parent = new(...)`, SimpleUVM / Scoreboard #55917 #56028) and the `$bits(typedef)` argument in a class method (`#58286` / `#58486`), plus BuildUVMPkg's `do_bus_access` path names (#57901, #58017, #58018); order-blind distance MiniAmiq 2461 -> **2448**, SeqDriver 2122 -> **2107**, SimpleUVM 1535 -> **1524**, Scoreboard 1098 -> **1089**, BuildUVMPkg 648 -> **636** | § hpLvNewClassFirstElemSpan224, § sysCallTypeArgScopeJoin224, § ipsBasePfxScopeJoin224, § hpLvSelIdxNamesByPath224, § hpLvSelColumnJoin224 |
| (3) the flat census's 598 minted return variables | decided: golden holds no such object (UHDM DeepClone copies vpiReturn by pointer); the mint is the sister's (section 7) | none |
| (4) **BlackBePipeInt t #66** (N0897) | `depth(1)` -> `type(1)`: #66 cleared, the head is now #15268, the same record as the default mode's #15272 | § pcwAllPkgListingBindsOwn224 |
| (4) BlackBePipeInt d/t #15272 | decoded in part, four hypotheses refuted on a grid (section 5.4), not written | none |
| (4) Earlgrey_0_1 d/t `fullname(19)` | attributed: #106660 `ref_typespec` full names inside flash_ctrl's `region_cfgs[8]` typespec copy, TypeEmit (the sister's) | none |
| (5) the switch reach | R11U224_SPLIT112A_OFF, R11U224_SPLIT175A_OFF, R11U224_SPLIT183A_OFF, R11U224_SPLIT191A_OFF: the ground-A halves of four whole-pass switches whose laws sit on both grounds (section 8) | § landingSwitchReach224 |

No corpus row-mode converts. The probe stage converts five cases, all of them earlier passes' gate cases that this
pass's laws reach:

    r10svs2repro/s5_negctl,EQUAL,,equal         (baseline STRICT_NOTEQUAL differ:endcol(2))   § hpLvNewClassFirstElemSpan224
    r10svs2repro/w3_macrodeep,EQUAL,,equal      (baseline STRICT_NOTEQUAL differ:endcol(2))   § hpLvNewClassFirstElemSpan224
    r10v121repro/v121_c,EQUAL,,equal            (baseline STRICT_NOTEQUAL differ:endcol(1))   § hpLvNewClassFirstElemSpan224
    r10v172repro/v172_3_pos,EQUAL,,equal        (baseline STRICT_NOTEQUAL differ:endcol(4))   § hpLvNewClassFirstElemSpan224
    r10v174repro/v174_b_sysfns,EQUAL,,equal     (baseline STRICT_NOTEQUAL differ:fullname(1)) § sysCallTypeArgScopeJoin224

**Gates (law.bin against the committed baselines, `tests/sweep.sh --jobs 3`, [evidence/sweeps/sweep_law.log](evidence/sweeps/sweep_law.log)):**
probe **0 regressions**, 5 conversions, 2 changes (3448 + 639); surelog **0 regressions**, 0 conversions, 6 changes;
uhdm2rtlil **0 regressions**, 0 conversions, 0 changes (1600 + 6); downstream **803 / 66 / 2 / 0**, the csv
byte-identical to the pristine sweep's. EXIT=1 on both sweeps is only the tests/LAWS.md staleness notice (this
directory's `§` names; the patch carries the regenerated index). The pristine sweep reads 0 / 0 / 0 in every stage.

## 1. Binaries (frozen `chmod 555` under the pass's scratch bin directory before any measurement)

| name | md5 | what |
|---|---|---|
| pristine.bin | `2510f4fe44619abb4eae492a1a0e737f` | `551c9751` built in this worktree (`-DSLANG_UHDM_USE_SYSTEM_DEPS=ON`), equal to the main tree's build/slang-uhdm |
| **law.bin (law11)** | **`c17d2a80d47f9ba2975511b32c70bbc1`** | the delivered source |
| law8.bin | `fde13bfd5064559bf5d66aad4234e131` | the first full round (all laws but § hpLvNewClassFirstElemSpan224 and § sysCallTypeArgScopeJoin224); its census and probe stage are superseded ([evidence/census/predict_law8_superseded.txt](evidence/census/predict_law8_superseded.txt)) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's build (unchanged tool) |
| strictcmp_x | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's variant (tools/probe/r11u211map/drivers/cc.sh), for the chain-keyed away census |

The patch applied to a fresh worktree at `551c9751` (git apply, clean) rebuilds law.bin byte for byte (md5
`c17d2a80d47f9ba2975511b32c70bbc1`). Every source edit was followed by a fresh build frozen under a new name; the pristine binary was frozen before the
first edit. Every `slang:` line of the law sweep's corpus `cmds.txt` names law.bin, and of the pristine sweep's
pristine.bin.

## 2. The laws

Every law reads its own switch; **R11U224_OFF drops every law of this pass**, restoring the base's bytes: on all 248
grid case-views the law binary under R11U224_OFF writes the pristine binary's bytes (`OFF=pristine` on every line of
[evidence/grid_law11.tsv](evidence/grid_law11.tsv)). R11U224_TRACE=<dir> names every firing, one file per process
(`<dir>/<pid>.224`, first line `OUT <-o path>`): the census that predicted the movers (section 4).

| law | switch | site (anchor) |
|---|---|---|
| § strLitPpEscIdShift224 | R11U224_STRPPESC_OFF | ExprEmit, `strLitPpShift224` / `ppEscIdEnd224` (the StringLiteral branch) and the design-final `strLitPpLineShiftDrain224` (run from ParamEmit's drainPaNameCopySrc38) |
| § strLitContOwnerEnd224 | R11U224_STRCONTOWN_OFF | ExprEmit, `strLitContOwnerDrain224` (run from drainPaNameCopySrc38 after § strLitContLineSpan220's drain) |
| § ipsBasePfxScopeJoin224 | R11U224_IPSPFXJOIN_OFF | ExprEmit, `ipsBasePfxJoin224` (the dotted-path branch's `bPfx9`) |
| § ipsWidthPfxByPathInScope224 | R11U224_IPSWIDTH_OFF | ExprEmit, `ipsWidthPfx224` (the same branch's width) |
| § hpLvSelIdxNamesByPath224 | R11U224_LVSELIDX_OFF | ExprEmit, `hpLvSelIdxPrefix224` (the hier_path builder's LVALUE shape) |
| § hpLvSelColumnJoin224 | R11U224_LVSELCOL_OFF | ExprEmit, `hpLvSelFull224` (same shape, the select's own full name) |
| § hpLvNewClassFirstElemSpan224 | R11U224_LVNEWSPAN_OFF | ExprEmit, `hpLvNewFirstSpan224` (the AssignmentExpression branch, after the Lhs) |
| § newArrayBitSelIdxOpStripped224 | R11U224_NEWARRIDXOP_OFF | ExprEmit, `stripRefFullNames11`'s bit_select case |
| § newArrayVarSelStripped224 | R11U224_NEWARRVS_OFF | ExprEmit, `stripRefFullNames11`'s var_select case |
| § sysCallTypeArgScopeJoin224 | R11U224_SYSTYPEJOIN_OFF | ExprEmit, the system-call DataType argument (TypeAlias) |
| § pcwAllPkgListingBindsOwn224 | R11U224_PCWALLPKG_OFF | ParamEmit, the design-final block after § parenCastWidthRefPkgBare207's |
| § landingSwitchReach224 | R11U224_SPLIT112A_OFF, _SPLIT175A_OFF, _SPLIT183A_OFF, _SPLIT191A_OFF (R11U224_OFF does NOT read them) | EmitHelpers.h `r11u224SplitAOff`, read by the r11u112 / r11u175 / r11u183 / r11u191 law gates of ExprEmit, ParamEmit and StmtEmit |

### 2.1 § strLitPpEscIdShift224 (T/t12, T/t14, SL s30-s39; grid [cases/SP](cases/SP))

`SV3_1aPpTreeShapeListener::enterString` (Surelog SourceCompile) hands the body of every string literal holding a
backtick to `evaluateMacroInstance` (after replacing ``` ``.`` ``` and ``` ``-`` ```). The preprocessor lexer
(grammar/SV3_1aPpLexer.g4) reads `'\\' ~[WS\r\t\n]*? WS` (the set excludes the LETTERS W and S, the grammar's own
spelling) or `'\\' ( '['? [A-Za-z0-9_$+-.]+ ']'? )* WS` as ESCAPED_IDENTIFIER, and `enterEscaped_identifier` writes
it back as `#~@` + the text without its first and last character + `#~@`: four columns more than the source, whatever
the blank run. The parser's columns are the preprocessed text's, so the literal ends four columns later per escaped
identifier, **and so does every token after it on the line**. The pass-220 rule (+2 per backslash) was this count on
the shapes it was measured on (two backslashes per escaped identifier) and stays for every literal this law declines
(a body with a macro reference `` `NAME ``, a paste, a quote, a comment opener or a line continuation).

| case | literal | source end | golden end | model |
|---|---|---|---|---|
| sp01 / s30 | `"a\nb` c"` | +0 | +4 | one escaped identifier `\nb` ` |
| sp09 | `"a\nb`   c"` | +0 | +4 | a blank run still adds four |
| sp10 | `"a\\Sb` c"` | +0 | **+0** | `S` stops the first alternative, the backtick the second |
| sp15 / t12 | `"a\\b`<TAB>c"` | +0 | **+0** | a tab is no WS |
| sp18 | `"\na` \nb` c"` | +0 | +8 | two |
| s31 / s32 | `"a\\b` c\\d"`, `"a` c\\d"` | +0 | +4 / **+0** | a trailing `\\d` has no blank after it |
| sp02 / t14 | `initial o = "a\\b`` c";` | initial -25 | initial -29 | the rest of the line moves |
| sp07 | two literals on one line | | second assignment starts +4, ends +8 | cumulative |
| sp20 | a module header's parameter default | | the port, net and typespec after it +4 | every located object |

The literal's own shift is recorded at emission (a macro-born literal takes it on its own end only, sp14 sp24 sp25);
the design-final drain moves every located object of that file whose start or end is on the line at or past a
shifted literal's source end, and registers a one-line string constant another emitter wrote (a class property's
initializer, sp31). Grid SP: 38 cases, 76 views, 56 converting, none leaving EQUAL; sp04 and sp06 unmask a record
present at the same index in the pristine walk (`size` of a cont_assign copy's literal, a `func_call` order record),
sp19 (a `` `FOO `` inside the literal: declined, pristine bytes) and sp11 (a paste: stage 1 on both) stay.

### 2.2 § strLitContOwnerEnd224 (K/k04, SL s48, s50; grid [cases/CK](cases/CK))

§ strLitContLineSpan220 moved a continued literal (and an assignment whose right side IS the literal) to its start
line at the start column plus the raw text's length. Surelog spans every object to its last token's end, so an
operation whose last operand is the literal ends there too (`always_comb o = c ? "x" : "ab \<nl>cd";`: golden the
conditional and the assignment 3:19-3:38 / 3:15-3:38, ours 4:4). Design-final: every object ending at a continued
literal's source end takes its computed end, and a string constant another emitter wrote (a class property s48, a
variable declaration s50 with its string_var) is recognised by its raw text's source geometry and moved too. CK: 10
cases, 20 views, 8 converting (ck03 localparam conditional, ck05 function return conditional, ck06 variable, ck09
package variable), the rest untouched (ck01 a system call, ck02 a concatenation, ck07 parenthesised, ck08 the literal
not last, ck10 an if body: each ends at a later token); ck04 stage 1 on both.

### 2.3 § ipsBasePfxScopeJoin224 and § ipsWidthPfxByPathInScope224 (C/c23; grid [cases/IJ](cases/IJ))

The dotted-path branch named a dynamic base reference of the trailing indexed part select `prefix + "." + path`;
Surelog stores no full name there and UHDM's `ComputeFullName` joins the whole chain with ONE separator, `::` once a
package or class is on it: golden `return arr[i].v[k+:2];` in `p1::c::f` names `k` `p1::c::f::arr[i].v[k+:2]::k`,
ours `p1::c::f.arr[i].v[k+:2]::k` (home listing and every importer clone). The joint is now joinRef's. A class
parameter width (`k+:W` in `class c #(int W)`) stays a reference and golden names it through the path as well
(`...::arr[i].v[k+:W]::W`, ij12); that half applies only where the scope joins with `::`. IJ: 16 cases, 32 views, 14
converting; ij02 (a package function, `endline` first on both) and ij06 ij08 ij15 (stage 1 on both) move toward
golden only; ij04 ij11 (module scope) untouched.

### 2.4 § hpLvSelIdxNamesByPath224 and § hpLvSelColumnJoin224 (G/g07; grid [cases/LV](cases/LV))

`s.arr[i][1:0] = d;`: Surelog builds bit_select(arr, i) (var_select for more element selects) and a separate
trailing part select and stores no index names, so the writer walks ref -> bit_select (skipped directly above a
ref_obj) -> hier_path: golden `work@top.s.arr[i][1:0].i`, ours the scope's `work@top.i`. An index under an operation,
a call or a var_select keeps the select's name on the chain (`...s.arr[i+1][1:0].arr.i`, lv02, lv03). In a class or
package subroutine the select's own name joins with `::` (lv14 lv16 lv17). LV: 17 cases, 34 views, 21 converting;
lv07 lv08 lv09 lv11 (stage 1 on both) move toward golden only (lv08 wrong to closer: golden renders the call index
`arr[]`); lv05 lv10 (literal indices) untouched.

### 2.5 § hpLvNewClassFirstElemSpan224 (SimpleUVM / Scoreboard #55917 #56028; grid [cases/HN](cases/HN))

`rw.parent = new("default_parent_seq");` (uvm_reg_map.svh:1773): golden hier_path `rw.parent` 1773:6-8, the span of
`rw` alone, ours the whole path. A dotted lvalue assigned a class `new` (with or without arguments, over a member
chain of a named root) ends at its first name; a dynamic-array `new[...]` keeps the whole span (hn04, EQUAL on both).
HN: 12 cases, 24 views, 12 converting; hn09 (an element-select root, stage 1 on both) and hn10 (a macro-born
statement: declined, a residue) untouched; hn08 fails in Surelog (a `new` in a conditional), hn12 (a nonblocking `<= new`) leaves Surelog no database.

### 2.6 § newArrayBitSelIdxOpStripped224, § newArrayVarSelStripped224 (NW/w17; grid [cases/NA](cases/NA))

Under the unparented `new[...]` call a reference inside an operation that is a bit_select's index stores no name:
the writer's chain runs ref -> operation -> bit_select (kept: its child is no ref_obj) -> the unparented `new`, golden
`arr.k`. A var_select there is unnamed too, its index references as well (na08: golden `var_select arr` unnamed,
`ref_obj k` = `arr.k`). NA: 10 cases, 20 views, 10 converting (every parse view), the `--elabuhdm` views moving bytes
in the weaklyReferenced tail only (dumps identical with the tail cut, as pass 220 read its `new[...]` cases).

### 2.7 § sysCallTypeArgScopeJoin224 (the UVM rows' #58286 / #58486; grid [cases/BT](cases/BT))

`$bits(uvm_reg_data_t)` in `uvm_reg_block::check_data_width`: golden `uvm_pkg::uvm_reg_block::check_data_width::uvm_reg_data_t`,
ours joined the typedef reference with joinPath's `.`. BT: bt01 (class method) converts in both views, bt02 (package
function) unmasks a `file` record present at the same index in the pristine walk, bt03 (module) untouched.

### 2.8 § pcwAllPkgListingBindsOwn224 (BlackBePipeInt t #66, N0897; decode [cases/PW](cases/PW))

In golden's `-elabuhdm` database the cast-width mark `ref_obj dev_addr_width_gp` under the `int_typespec` of
`bp_common_pkg::dev_addr_width_gp` in the UNELABORATED listing (design AllPackages), and the one under every
`(dev_addr_width_gp)'(...)` cast of that listing, is never expanded by the walk (38 records): its actual is the
listing's own parameter. The elaborated package listing (TopPackages), the importing package and the module expand
the module's copy `work@bp_be_pipe_int.dev_addr_width_gp`, § pcwElabKeepsClaim207v's measurement, still holding
(walk tabulation per listing: golden sections 2 / 24652 / 74925 / 109614 / 159858). A debug build showed ours: every
listing stamps its own int_typespec, and the module copy's claim (`claimParenCastWidthOwner`) re-points the
AllPackages mark too, so the walk expanded 8 ours-only records at #66. Design-final, `--elabuhdm` only: the mark of an
AllPackages package's own (not imported) parameter binding another same-named parameter is rebound to the listing's
parameter. BlackBePipeInt t `depth(1)` -> `type(1)` (#66 -> #15268). Every importer shape reads stage 1 on both
binaries at the base (the sister's module import copies keep the cast where golden folds it, pass 207's p02 p03 and
this pass's PW p01-p03), so no judge-equal grid exists; the row is the measurement.

## 3. The gates (law.bin against pristine.bin, both at `551c9751`; workdirs of equal name length)

| stage | pristine.bin | law.bin |
|---|---|---|
| probe vs golden_probe.csv | 3443 + 644, 0 / 0 / 0 | **3448 + 639: 0 regressions, 5 conversions, 2 changes** |
| surelog vs golden_surelog.csv | 929 + 25, 0 / 0 / 0 | **0 regressions, 0 conversions, 6 changes** |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 1600 + 6, 0 / 0 / 0 | **1600 + 6: 0 / 0 / 0** |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0 (csv byte-identical to pristine's) |

**Probe changes** (2): r10uvm147repro/g147_a `col(14)` -> `col(6)` [col -8] (§ hpLvSelIdxNamesByPath224 and
§ hpLvSelColumnJoin224: 8 records toward, the same first field); r10uvm56repro/v3_hierpath `endcol(6)` -> `endcol(4)`
[endcol -2] (§ hpLvNewClassFirstElemSpan224, 2 toward).

**Surelog changes** (6): BlackBePipeInt t `depth(1)` -> `type(1)` (§ pcwAllPkgListingBindsOwn224); BuildUVMPkg d/t
`line(19)` -> `line(14)` [line -5] (the head #26855 `this_type` class_typespec location is TypeEmit's, unchanged; the
path-name, `$bits` and lvalue-new records leave); Scoreboard d `file(30)` -> `file(26)` [file -4]; SimpleUVM d/t
`file(54)` -> `file(50)` [file -4] (two lvalue-new spans and two `$bits` names each). MiniAmiq d/t and SeqDriver d/t
keep `file(7)` (their first records are UVM_FILE's relocation, TypeEmit), 13 and 15 records toward golden past them.

Canaries: canaries.sh surelog ok=47 changed=5 (exactly the five claimed SimpleUVM / BuildUVMPkg / Scoreboard
changes), uhdm2rtlil ok on every row; ctcan2 EXPECT_UNKNOWN=1 surelog ok=57 changed=1 (BlackBePipeInt t, the claimed
change; the pristine sweep ok=58 PASS), EXPECT_UNKNOWN=6 uhdm2rtlil PASS. uhdm-cmp reads 0 lines on every touched
row-mode and probe case: every one of them is judge-equal (CMP_EQUAL / STRICT_NOTEQUAL / EQUAL) in the law sweep.

## 4. Movers, predicted by name before the law sweep

The firing census (drivers/census.sh: every corpus row-mode but the four fenced ones through a negative `--filter`
built from the FENCED= line of tools/probe/r11u107repro/canaudit.sh, and every probe case; drivers/dscensus.py: every
downstream lane's translated command line, no Yosys) ran law.bin with R11U224_TRACE set; drivers/predict.py froze
[evidence/census/predict_final.txt](evidence/census/predict_final.txt) (md5 `c7573329a18734563450c89111626fe9`,
stamped 2026-09-29T08:21:59Z with law.bin's md5, [predict_final.stamp](evidence/census/predict_final.stamp)), the
law sweep starting after it: 10 surelog row-modes, 2 uhdm2rtlil row-modes, 7 probe cases, 1 downstream lane.

* **corpus**: byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on hard-link mirrors without the 8
  fenced row-mode databases, drivers/bvmirror.sh; path sets identical): **10 of 2560 movers, all predicted**
  ([evidence/movers/byteverify_corpus.txt](evidence/movers/byteverify_corpus.txt)). The two predicted uhdm2rtlil
  row-modes (StringWithBackslash d/t, § strLitPpEscIdShift224 x3) do not move: its literal `"\\/ _| __| | '_ \\ / _` / "`
  holds two escaped identifiers of two backslashes each, so the new count (+8) is the old one (+8), and nothing
  follows the literal on its line. SELFCHECK reads 2559 of 2560: the self-check compares every file against ONE
  fixed file of the set, and that file against itself is the one path it cannot flag.
* **probe**: **7 of 4087 movers, exactly the 7 predicted** ([evidence/movers/probe_movers.txt](evidence/movers/probe_movers.txt)).
* **downstream lanes**: **0 of 805** databases move (the predicted StringWithBackslash lane, as above); every lane's
  RTLIL identical, the only differing files two `equiv.log` lines naming the work directory.

The chain-keyed away census (drivers/awayrows.py, map 13's census on strictcmp_x records, raw full names) over the
17 moving databases: **away 0, toward 134** ([evidence/away/awayrows_law.txt](evidence/away/awayrows_law.txt)); the
reversed positive control reads away 134 ([awayrows_reversed_control.txt](evidence/away/awayrows_reversed_control.txt)).
(Corrected at verification, tools/probe/v11u224repro/README.md: this line read 159 in the delivered README; the two
evidence files sum to 134 chain-keyed and 131 flat toward, and the verifier's own census reads the same 17 lines.)
The flat column reads 13 away on BlackBePipeInt t alone: the 8 ours-only records the old binding expanded at #66 (the
parameter, its typespec and the next expansion) match golden records of the same shape elsewhere in the flat multiset;
the strict walk itself moves its first difference from #66 to #15268, so every record between is now equal in walk
order (the pass-219 reading of a flat-key artifact).

## 5. Grid and controls

### 5.1 This pass's grid ([evidence/grid_law11.tsv](evidence/grid_law11.tsv), drivers/grid.sh)

124 case directories x 2 views (the parse form, and `--elabuhdm` / `-elabuhdm`) = 248 case-views, goldens built by the
pinned Surelog per case text:

| group | cases | law | converting | leaving EQUAL | moved without converting |
|---|---|---|---|---|---|
| SP | 38 | § strLitPpEscIdShift224 | 56 | 0 | 10 (0 away) |
| CK | 10 | § strLitContOwnerEnd224 | 8 | 0 | 0 |
| IJ | 16 | § ipsBasePfxScopeJoin224, § ipsWidthPfxByPathInScope224 | 14 | 0 | 8 (0 away) |
| LV | 17 | § hpLvSelIdxNamesByPath224, § hpLvSelColumnJoin224 | 21 | 0 | 7 (0 away) |
| HN | 12 | § hpLvNewClassFirstElemSpan224 | 12 | 0 | 0 |
| NA | 10 | § newArrayBitSelIdxOpStripped224, § newArrayVarSelStripped224 | 10 | 0 | 8 (tail only) |
| BT | 3 | § sysCallTypeArgScopeJoin224 | 2 | 0 | 2 (0 away) |
| PW | 3 | decode of § pcwAllPkgListingBindsOwn224 | 0 | 0 | 3 (stage 1 on both, 0 away) |
| TP | 15 | decode of BlackBePipeInt #15272 | 0 | 0 | 0 |
| **total** | **124** | | **123** | **0** | |

**0 case-views leave EQUAL; R11U224_OFF writes the pristine bytes on all 248.** Switch reach
([evidence/switch_reach.txt](evidence/switch_reach.txt), [switch_pairs.txt](evidence/switch_pairs.txt)): every one
of the 161 moved case-views is restored by exactly its own law's switch (147), or by exactly its law's pair (14:
IPSPFXJOIN + IPSWIDTH on ij12 ij15 ij16, LVSELIDX + LVSELCOL on lv07 lv14 lv16 lv17).

The brief's fresh-case list: interface bodies (SP sp29, IJ ij14, LV lv11), class specializations (IJ ij12 ij15 ij16),
`this.` paths (IJ ij09 ij13, LV lv14, NA na07), extern methods below the class (IJ ij01, BT bt01), virtual methods
(ij13), macro-born tokens and include files in another root file (SP sp14 sp23 sp24 sp25, HN hn10), generate scopes
(SP sp28, LV lv09, IJ ij11), module-local classes (IJ ij05), multi-line statements (HN hn11, SP sp26), increments and
streaming-like concatenation lvalues (LV lv12 lv15), literal widths and escapes (SP sp01-sp22).

### 5.2 The pass-220 residue cases (tools/probe/v11u220repro, r11u220repro)

The whole of both directories (259 cases, 518 views) ran on pristine.bin at the start; the residue views named in
the brief all move as the laws say (section 0), and the wide control below covers every one of them.

### 5.3 Wide byte control ([evidence/wide/](evidence/wide/))

611 case directories (every tools/probe and tests/probe dut.sv, fenced names excluded, holding a string with a
backtick or a continued line, a `new[`, a dotted path with a select, or a paren-cast localparam, plus this pass's own
cases), both views, pristine.bin vs law.bin: **211 byte movers of 1222 case-views, 156 converting, 0 leaving EQUAL, 0
from judge-equal to stage 1**; the 55 non-converting movers read **0 away** in the multiset dump census with the
weaklyReferenced tail cut (drivers/dumpdelta.sh; [wide_away.txt](evidence/wide/wide_away.txt)): 38 stage-1 views, 9
EQUAL -> EQUAL views moving in the tail only, and 8 unmaskings. One break was looked for and not found: r11u213verify
CW/w02 `-elabuhdm` (a re-exporting package, stage 1 on both) moves one line in the weaklyReferenced tail only.

### 5.4 BlackBePipeInt #15272 (decode, [cases/TP](cases/TP))

Golden writes no Pattern (`tagged_pattern` with only its ref_typespec) for the members of `bp_unicore_megaparrot_cfg_p`
whose value is `(override.x == "inv") ? bp_unicore_cfg_p.x : override.x` and whose override member is DEFAULTED
(`default : "inv"`): in that parameter's 72 members, all 48 defaulted members are null and all 24 explicit ones fold
to a constant (the parameters after it in the package mix both, not tabulated). Four hypotheses refuted on judge-equal or stage-1
shapes whose golden folds the member: the string comparison itself (tp02 tp05), `C = D` a parameter alias (tp01),
a wide packed struct (tp08 tp09 tp10: 192 bits), an operation or enum member in the source pattern (tp12 tp13 tp15).
The branch that returns nothing is in UHDM ExprEval's pattern evaluation (`flattenPatternAssignments` returns an empty
result when an operand of the pattern is an operation or constant, or a tagged key has no member), not pinned. The
next grid: the real struct's member count and order, the enum-typed members (`e_cacc_none`) of the source pattern,
the pattern nested in a package parameter used by a module.

## 6. Pass 215's writer stamp against r11u214's writer law (brief item 2)

At the base (both landed), pristine.bin with R11U215_TDALIAS_OFF and with R11U215_ENUMCLONE_OFF:

| scope | R11U215_TDALIAS_OFF | R11U215_ENUMCLONE_OFF |
|---|---|---|
| probe, 4087 cases | csv identical; 1 byte mover (r10uvm49repro/a3), its dump identical | csv identical; 0 byte movers |
| corpus, the eleven row-modes pass 215's census named (BlackBePipeInt, BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM d/t, Scoreboard d) | csv identical; 9 byte movers, every dump identical order-blind (0 lines) | csv identical; MiniAmiq d/t move (its known storage-order coin), dumps identical |

([evidence/pass215/](evidence/pass215/)). Pass 215's stamp writes no dump-visible record the r11u214 law does not
already write; its switches move bytes only (storage order), so the bytes do not prove it inert and no new switch is
added; the landed laws stay.

## 7. Decoded, not landed (the sister's sites)

* **The 598 minted return variables of § importCloneSharesHomeReturn218** (MiniAmiq, SeqDriver, g208): golden holds
  no such object (UHDM templates/clone_tree.cpp: function::DeepClone copies vpiReturn by pointer); ours mints one per
  class-method clone and the law leaves it unreferenced: neither the strict walk nor uhdm-dump reaches it (0 in both
  dumps, the weaklyReferenced tail included). The mint is the write-phase return-variable drain,
  ModuleEmit.cpp's `for (auto& pf : pendingFuncRet)` loop: ParamEmit's class-method clone passes no shared return
  (`pkgImportCloneRetVar = nullptr` before emitTaskFuncs, unlike the free-subroutine half), so the drain mints. Passing
  the home method's return there needs the drain to accept it for a class method (the sister's half).
* **Earlgrey_0_1 d/t `fullname(19)`**: #106660 onward, `ref_typespec` full names inside flash_ctrl's `region_cfgs[8]`
  typespec copy (golden `work@flash_ctrl`, ours `region_cfgs[8]` / `work@flash_ctrl.u_flash_*.op_addr_i`): TypeEmit.
* **The UVM rows' first records**: `typedef int UVM_FILE` relocation (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard
  #15320 onward, `file`), TypeEmit (pass 219's residue 1); the `UVM_SEQ_ARB_TYPE` enum typespec location (#24915),
  `this_type` class_typespec location (SimpleUVM #26887, BuildUVMPkg #26855), the `uvm_active_passive_enum` relocation
  (#63683): TypeEmit. First ten records per row-mode at the base: [evidence/heads/](evidence/heads/).
* **SL s50's twin in a module variable** now converts through § strLitContOwnerEnd224's design-final drain (it moves
  the string_var's end, written by ModuleEmit); a ModuleEmit fix at emission would leave the drain nothing to do.

## 8. The switch reach (§ landingSwitchReach224, brief item 5)

Whole-pass switches read on both grounds at the base (a static scan of every `R11U<N>_OFF` / `R11V<N>_OFF` read):
R11U112, R11U113, R11U115, R11U166, R11U172, R11U175, R11U183, R11U191, R11U200, R11U205, R11U48, R11U92, R11V141,
R11V190, R11V199. Already split: R11U200 (§ landingSwitchReach210) and R11U205 (§ landingSwitchReach220). Split here,
where one local law gate per file carries every ground-A law of the pass:

| switch (new) | drops | measured on its passes' cases, law.bin, both views ([evidence/reach/](evidence/reach/)) |
|---|---|---|
| R11U224_SPLIT112A_OFF | ExprEmit's r11u112 laws | 204 views: R11U112_OFF moves 106, the split 54, the split never where the old does not |
| R11U224_SPLIT175A_OFF | ExprEmit's and StmtEmit's r11u175 laws | 160 views (r11u175uvm, r11u178repro): old 56, split 34, 0 split-only |
| R11U224_SPLIT183A_OFF | ExprEmit's, ParamEmit's and StmtEmit's r11u183 laws | 406 views (r11u183dec, r11u187repro): old 191, split 107, 0 split-only |
| R11U224_SPLIT191A_OFF | ExprEmit's and ParamEmit's r11u191 laws | 358 views (r11u191dec, r11u195repro): old 146, split 70, 0 split-only |

Not split: R11U113, R11U115, R11U172, R11U48, R11V190, R11V199 (their ground-A laws read the switch inline at 1-10
sites each, no single gate; a split needs one edit per site), R11U166, R11U92, R11V141 (EmitHelpers.h helpers read
by both grounds' call sites, not a ground-A law set). The old switches keep their meaning.

## 9. Determinism ([evidence/det_law.txt](evidence/det_law.txt)) and UVM distance ([evidence/uvmdist.txt](evidence/uvmdist.txt))

drivers/det.sh (three concurrent harness runs of law.bin on Earlgrey_0_1 and the five UVM rows, both modes): one hash
per row-mode for Earlgrey_0_1, SeqDriver, SimpleUVM and BuildUVMPkg; MiniAmiq d/t two hashes whose uhdm-dumps are
identical unsorted (the known storage-order coin); Scoreboard d two hashes, dumps identical (the known svunit
listing-order coin). No new coin.

| row-mode | pristine dist / total | law dist / total |
|---|---|---|
| MiniAmiq d/t | 2461 / 7965 | **2448 / 7939** |
| SeqDriver d/t | 2122 / 6349 | **2107 / 6319** |
| SimpleUVM d/t | 1535 / 2796 | **1524 / 2774** |
| Scoreboard d | 1098 / 1999 | **1089 / 1981** |
| BuildUVMPkg d/t | 648 / 1241 | **636 / 1217** |

## 10. Fence and process

* Every driver that reads corpus sources or databases reads the four names from the FENCED= line of
  tools/probe/r11u107repro/canaudit.sh and fails closed (env.sh, case.sh, run1.sh, grid.sh, switches.sh, reach224.sh,
  dumpdelta.sh, rowdelta.sh, census.sh with its negative `--filter`, dscensus.py, predict.py, bvmirror.sh,
  awayrows.py, uvmdist.sh, det.sh). The gate sweeps dispatched every row as the gate mandates; no binary, gdb or
  script ran on a fenced test's sources or databases outside them; the evidence csvs are kept without the eight
  fenced row-modes, and every evidence line holding a fenced name even as a substring of another test's name is dropped (one uhdm2rtlil test's name contains one: its rows are CMP_EQUAL / IDENTICAL in both sweeps, the sweep logs keep the counts). No fenced name appears in this directory.
* gdb ran on the pristine binary for three decodes (a full-name setter breakpoint on C/c23 and BT/bt01, the
  cast-width stamps on BlackBePipeInt), all non-fenced; two temporary debug builds printed one decision each and were
  discarded (no `R224DBG` in the delivered source).
* Process: twice early in the pass a shell without the environment file executed a database path as a command
  (`$UHDM_DUMP` empty); it created empty files in this pass's own scratch case directories only, removed at once; the
  dump calls go through a wrapper since. The law8 sweep was stopped by this pass (its own process group) when two more
  laws were added; its probe stage is kept in [evidence/census/](evidence/census/) as superseded.
* Drivers resolve paths from the checkout; the binaries' directory ($B) and scratch root ($S) come from the caller.

## 11. Residues, ranked

1. BlackBePipeInt d/t #15272 / #15268 (section 5.4): the ExprEval branch that nulls a defaulted-member conditional;
   the next grid is listed there. Both row-modes now head on it.
2. The sister's heads of every UVM row (UVM_FILE, the enum and class typespec locations; section 7) and Earlgrey's
   #106660 (TypeEmit).
3. The minted clone return variables (the ModuleEmit drain, section 7).
4. A macro-born string: a `` `FOO `` inside a backtick literal (SP sp19: Surelog expands a defined macro there), a
   continued literal from a macro (K/k09), a macro-born lvalue-new statement (HN hn10).
5. Clone select indices the chain law does not reach (C/c21 a call index, C/c22 a part-select index and the cast's
   ref_typespec names).
6. The pattern-member fold spans (TP tp12 tp14 tp15: golden spans a folded `(1 << 2) | (1 << 3)` member from its first
   operand's parenthesis, 4:39-47, ours 4:40-46; the module copy's end).
7. The six unsplit cross-ground switches (section 8).
8. Carried: FuncStructVal #747 and the walk divergence at #7975 (a typespec_member where golden has an operation),
   N0008, the value encodings, map 13's N0739 N1903 N1904 N0476 N0477, struct_param_func_config and
   cfg_func_width_loop (their heads are TypeEmit's).

## 12. Files

* `drivers/`: env.sh case.sh run1.sh grid.sh switches.sh reach224.sh dumpdelta.sh rowdelta.sh census.sh dscensus.py
  predict.py bvmirror.sh awayrows.py uvmdist.sh det.sh (copied from r11u220repro where their headers say; caseaway.py,
  dumpaway.py and gridaway.sh are carried unused).
* `cases/`: SP CK IJ LV HN NA BT (this pass's laws: the first line of each dut.sv names its law), PW and TP (decode
  only: `r11u224 decode`).
* `evidence/`: sweeps/ census/ movers/ away/ wide/ reach/ pass215/ heads/, grid_law11.tsv, switch_reach.txt,
  switch_pairs.txt, det_law.txt, uvmdist.txt.
