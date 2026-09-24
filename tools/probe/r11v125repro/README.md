# r11v125 — adversarial verification of r11u125

Verifier of pass r11u125 (pair B, the module/type ground on the strict axis). Base `7bd06f52`
(branch matrix-1.87). Worktrees `/tmp/wt_v11u125` (patched) and `/tmp/wt_v11u125pris` (pristine),
both built with the system-deps config at `-j 2`. Verdict: **ACCEPT-WITH-FIX** — two of the eight
laws moved strict cells AWAY from golden on legal SV that no corpus row or probe case contains; both
are fixed here under their own switches (§ includeInfoRawCol125v, § emptyRedefineBareLine125v).

| binary | md5 | what |
|---|---|---|
| pristine | `cb7b39bd1fa880fa84d54d11d9ff8ce2` | = the main tree's `build/slang-uhdm` |
| law | `9b9884b9c78b4bbb7c19bae450418a11` | the implementer's patch, rebuilt here: byte-identical to the implementer's |
| fix | `7c5a7e01c46167100bd7787ae1798f2c` | law + the two verifier laws (the shipped `.verified.patch`) |
| `uhdm-strictcmp` | `88bf7040c706f80686ea981e6a8650c8` | = the main tree's |

All frozen (`chmod 555`, `/tmp/v11u125_bin/`) before any measurement; every sweep exported
`SLANG_UHDM` and `STRICT_CMP` to the frozen copies; cmds.txt audit: 3273 of 3323 per sweep name the
frozen binary, the other 50 are rows with no slang run (SURELOG_FAIL/NO_DATABASE/...), the same 50 in
every sweep.

## 1. The implementer's headline numbers, reproduced

| claim | reproduced |
|---|---|
| probe EQUAL 4087/4087, strict tally 1712 -> 1836 | yes: 124 turned equal, 165 fewer, 155 moved-fewer, 2 moved-same (pt23, h08_unpacked_base: only the `file` diffs removed, the endline/endcol ones pre-existing — drivers/fielddiff3.py), 0 worse |
| surelog 521 -> 576, uhdm2rtlil 1072 -> 1190 strict-equal | yes: 173 turned equal, 133 fewer, 36 first field moved (30 fewer, 6 same count), 0 worse, 0 status changes |
| the 6 same-count rows (unpacked_struct_2d / _dyn_read / _mixed, both modes) | only the 4 `file` diffs removed; the 13 endline/endcol objects pre-existing (fielddiff3) |
| corpora `regressions=0 conversions=0 changes=0`, 480/3 + 474/3, 803/1/67 both modes | yes (all three sweeps) |
| downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT | yes, verdict + `differs` identical to pristine on 871/871 rows (law and fix) |
| byte movers 141 + 245 = 386 | **140 + 244 = 384** (the implementer's own evidence/byteverify_*.txt also read 140 and 244; the report text mis-added; stamped_gen_param both modes is inside the 384). Mover SET identical to the implementer's byte_movers_attributed.tsv |
| per-object: improved 247542, worsened 0 | own pairing (GNU diff over the record keys): surelog 140 rows improved 227434, uhdm2rtlil 242 rows improved 20122, **worsened 0**; neutral 418; only flagged row Scoreboard/default (walk-order coin) |
| grid g1 0->16/18, g2 0->6/10, g3 1->11/16, g4 2->10/11, g5 2->6/6; R11U125_OFF = pristine bytes on 61/61; 51 move without it | yes, every number |
| canaries ok=35 changed=17 / ok=6 changed=10 (all improvements) | yes |
| ctcan2 vs committed csvs | the committed csvs are CRLF here: LF-normalised, the pristine sweep reads ok=58 changed=0 (calibration PASS), law/fix changed=9 (PartSelect4 col 9->1, the BlackBox family file(1)->equal, BlackConst line 31->29: all improvements); uhdm2rtlil PASS ok=2 |
| single-law attribution | spot-check: each law's switch alone on law.bin gives PRISTINE BYTES on 17/17 byte movers it alone owns (DecValue testflags, the 18th row-mode run, is not a mover) (GVFILE BitSelect, CaseDefault; CASTFILE DecValue, ReplicationPassedToInstance; SPANFILE BiasValue, iface_pkg_enum_item; MACROFILE CovMacro, ibex_wb_stage; INCCOL YosysBigSimSoft; both modes) |
| func_upto EQUIVALENT is not a field | confirmed: our `_nohier.il` byte-identical pristine vs law; its diff against the Surelog lane is 814 lines, 0 sorted (the `update` order of a `sync init` rule); the plugin's `std::map<RTLIL::Wire*, ...> wire_to_value` (process.cpp `import_initial_interpreted`) iterates by heap address. matching_end_labels the same (2 lines, 0 sorted). func_upto strict `equal` with `--no-canon` |

Target rows (fresh csv rows, law = fix):

    BlackBox,default,CMP_EQUAL,,,differ:file(1)        -> BlackBox,default,CMP_EQUAL,,,equal       (both modes)
    func_upto,default,CMP_EQUAL,,,differ:file(2477)    -> func_upto,default,CMP_EQUAL,,,equal      (both modes)
    DoubleLoop,default,CMP_EQUAL,,,differ:file(30)     -> DoubleLoop,default,CMP_EQUAL,,,equal     (both modes)
    YosysOldSpi,default,CMP_EQUAL,,,differ:line(525)   -> ...,differ:fullname(1); testflags differ:col(523) -> differ:fullname(1)
    downstream func_upto: EQUIVALENT nohier -> EQUIVALENT nohier (R1, not a field)

## 2. Breaking the laws (grid/, 48 cases, every case names its law in its first line)

drivers/case.sh: golden = the pinned Surelog with the probe arguments, ours `dut.sv --single-unit
--nobuiltin`, uhdm-cmp line count and strictcmp verdict per binary. Full table evidence/grid_mine.txt.

| face | cases | pristine strict-equal | law | fix | notes |
|---|---|---|---|---|---|
| gv (§ genvarParamFile125, § genvarParamLoopVarLine125): split header over 3 lines, nested loops with a split inner header, two parameterisations, loop under if-generate with if/else body, loop in an include, loop from a multi-line macro, `genvar` alone on the `for` line, three nested no-begin loops | 8 | 0 | 6 | 6 | v05/v06: only the def-view gen_for int_typespec file left (golden = the including/invoking file: residue R5, pristine wrong too) |
| mf (§ macroTokenFileFollowsLine125): one-line macro from an include, multi-line body with argument, one-line macro nested in a multi-line body, one-line body with a multi-line INVOCATION, macro used in a second include, multi-line body without args, nested macro in a macro argument, `$display` argument, a whole module from a one-line and a multi-line macro, a function from a multi-line macro | 11 | 2 | 8 | 8 | w04 (one-line body, invocation spanning 2 lines: golden reads the DEFINITION file and lines 1-2 for every token — a new face of R4, pristine the same bytes); w05/w11 R4 |
| ic (§ includeFirstLineColShift125): tab indent, text before the directive, indented first line, nested include on the first line of an include, comment-only first line, two includes, `/* */` before the directive, a macro invocation before the directive | 8 | 1 | 5 | **6** | **x04 LAW WRONG** (below); x02/x08: text before the `include on its line reads the INCLUDED file in golden (an object of the including file on the directive's line: new residue R8, pristine wrong too) |
| mc (§ macroBodyTrailingComment125): args + comment, `//` inside a string, `//` inside a block comment, trailing tabs, nested one-line macros with comments, comment glued to the body | 6 | 0 | 6 | 6 | robust |
| rd (§ includeInfoEmptyRedefineLine125): `define X // c` redefined, trailing blanks, bodied then empty, redefinition inside `ifdef, first definition in an include, `/* c */` redefinition, include ending in a define | 11 | 3 | 1 | **3** | **z01, z07 LAW WRONG** (below); z02/z03/z05: include_file_info now right, but golden ALSO lowers every later OBJECT line of the root file (module_inst 3:1 vs ours 4:1): new residue R9; z06/z08/z09/z12: an included file whose LAST line is a `define (bodied or not, first definition or not) splices one line fewer: new residue R10 (pristine wrong too) |
| ct (§ castTsDrainFile125): cast in a one-line macro from an include, package cast, casts on the first line of an include at column 3, parameter-width and struct casts | 4 | 1 | 1 | 1 | t03: the drained typespec columns come from the raw `pendingCastTs` record (ExprEmit.cpp, sister ground) and miss the include-column shift (pristine the same: residue R11); t02 NOT_EQUAL at base (pkg typedef cast in an include) |

Every other cell: law = fix, no field worse than pristine; uhdm-cmp 0 lines on every cell that is
EQUAL at base.

### The two defects (pristine right -> law wrong on legal SV)

1. **§ includeFirstLineColShift125 shifts the include_file_info record** of a directive written on the
   first line of an included file. Case grid/ic/x04: `mid.svh` line 1 is `  \`include "inner.svh"`,
   `mid.svh` is included at `dut.sv` 4:4. golden `include_file_info dut.sv 4:12-4:23`, pristine
   4:12-4:23, law **4:15-4:26**. The include_file_info record carries the directive's raw column
   (Surelog reads it from the source token, not from the flattened output line).
   FIX § includeInfoRawCol125v (UhdmExporter.cpp emitIncludeFileInfos + fileLineCol; switch
   `R11V125_INCINFOCOL_OFF`): the shift is skipped while emitIncludeFileInfos reads a directive span.
2. **§ includeInfoEmptyRedefineLine125 fires on `define X // c` and `define X /* c */`.** Surelog drops
   the line only in `exitDefine_directive` (SV3_1aPpTreeShapeListener.cpp: `addLineFiller` is skipped
   when `getMacro(name)` is non-null), and `define_directive` is `TICK_DEFINE Spaces name Spaces* CR`
   (SV3_1aPpParser.g4); `One_line_comment` eats the newline and a block comment is not `Spaces`, so
   those lines parse as `simple_no_args_macro_definition` and keep their filler. Cases grid/rd/z01,
   z07: golden = pristine include_file_info 5:10, law 4:10. FIX § emptyRedefineBareLine125v
   (UhdmExporter.cpp emitIncludeFileInfos; switch `R11V125_BAREDEF_OFF`): only a define line with
   nothing but blanks after the name counts. (Command-line `-D` macros are NOT in Surelog's
   compilation-unit macro table — `getMacro` reads `m_compilationUnit` only — so ignoring them is right.)

Neither shape occurs in either corpus or in tests/probe: the fix sweep is byte-identical to the law
sweep except the UVM coins (below), and every strict cell, probe case and downstream verdict is
identical to the law's.

## 3. Gates of the verified patch (fix binary)

1. build: pristine `cb7b39bd1fa8` (= main tree), fix `7c5a7e01c461`.
2. probe: EQUAL=4087 (of 4087); strict tally 1836 (= law); per case identical to law on 4087/4087.
3. corpora: `regressions=0 conversions=0 changes=0` both; surelog 480/3 + 474/3, uhdm2rtlil
   803/1/67 both modes (the sweep's rc=1 was `law index STALE` only, before tests/LAWS.md was
   regenerated with this README).
4. downstream: EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66, `not identical and not excused=0`;
   verdict + differs identical to pristine on 871/871 (func_upto EQUIVALENT nohier = R1; the pass-120
   rows and arb_idx_cast IDENTICAL).
5. uhdm-cmp: every row keeps its status; 0 lines on every grid cell equal at base.
6. strict: fix vs law identical row by row (1596 surelog + 1742 uhdm2rtlil rows); fix vs pristine = the
   law's census (173 / 133 / 36, 0 worse).
7. byteverify (`SELFCHECK=1`, same-length workdirs): fix vs law PATH_SETS_IDENTICAL, uhdm2rtlil
   MOVERS 0/1608 (selfcheck 1607/1608), surelog MOVERS 5/960 (selfcheck 959/960) = MiniAmiq both
   modes, SimpleUVM default, SeqDriver testflags (4 dump lines each, `vpiDecompile`/`UINT` 513 vs 0:
   the known coin) and Scoreboard default (92 dump lines, 0 sorted: the order coin). PREDICTED: the
   two fixed shapes (a directive on line 1 of an included file that is itself included at a column
   > 1; an empty-body redefinition with a trailing comment) move nothing unless a database already
   contains that shape; the law objcheck (0 worsened) says none does — so 0 real movers, confirmed.
8. switches: `R11U125_OFF=1` on the fix binary = pristine bytes on all 109 grid cases (61 implementer +
   48 verifier); `R11V125_INCINFOCOL_OFF=1 R11V125_BAREDEF_OFF=1` = law bytes on all of
   them; fix differs from law only on x04, z01, z07.

## 4. Residues, ranked (after the fix)

* **R1** func_upto / matching_end_labels downstream EQUIVALENT: plugin heap-address order, confirmed (section 1).
* **R3** (sister, ParamEmit) the double package prefix `pa::pa::` — not re-measured here.
* **R4** multi-line macro line model (implementer's), plus the new face grid/mf/w04: a one-line body
  whose INVOCATION spans lines reads the definition file and definition lines 1-2 in golden.
* **R5** def-view gen_for int_typespec file (golden: the including / invoking file; gv v05, v06).
* **R8 (new)** text before an `include directive on the same line reads the INCLUDED file's first
  line in golden (ic x02, x08: `logic z;` before the directive reads body.svh 1:9).
* **R9 (new)** an empty redefinition in the ROOT file lowers every later object line of that file in
  golden, not only the include_file_info (rd z02, z03, z05: module_inst 3:1 vs ours 4:1).
* **R10 (new)** an included file whose last line is a `define splices one line fewer (rd z06, z08,
  z09, z12; z11 with a comment after the define splices all lines).
* **R11 (sister, ExprEmit)** the drained cast typespec columns miss the include first-line shift (ct t03).
* R2, R6, R7 and the late-bound nets: as the implementer reports (not re-measured).

## 5. Files

grid/ (the cases), drivers/ (case.sh, rdiff.py, bytes.sh, strictcols.py, probecols.py, objcheck.py,
fielddiff3.py, env.sh), evidence/ (grid_mine.txt, bytes_*.txt, cols_*.tsv, objcheck_*.txt,
byteverify lists, downstream comparisons, canaries).
