# v11u425 — adversarial verification of r11u425 (expression/parameter ground)

Base 914cad62. The implementer's patch is /tmp/r11u425.patch: five laws in src/ExprEmit.cpp and src/EmitHelpers.h. This verification finds ONE BREAK and fixes it with one refinement, § lineDirectiveActive425v (switch R11V425_LINEACTIVE_OFF, ExprEmit, read through fixOn(425, ...)). The verified patch is /tmp/r11u425.verified.patch.

## Binaries (frozen, audited by path in every cmds.txt)

- pristine: /tmp/v11u425_bin/pristine, md5 72038e16a3df50b111015c03b239fc7a. This is the implementer's frozen copy of the main tree's build at the base. It equals the brief's pristine md5 and was not rebuilt, as the budget requires.
- law: /tmp/v11u425_bin/law, md5 0c313392ab6e82fc9b6a2d39044278f4. Rebuilt once in /tmp/wt_v11u425 from the patch applied to a fresh 914cad62. It equals the implementer's law binary. The binary reports slang 12.0.0+545f88b2e and UHDM 1.87.
- verified: /tmp/v11u425_bin/verified, md5 b1f06213604fec5d9041ab27db387d37. This is the law plus § lineDirectiveActive425v. It is the second and last build.
- uhdm-strictcmp: md5 fa6e4f42f252ae0ab69d9845003e71c5, the same as the implementer's and the main tree's.

## THE BREAK and the refinement

§ lineMacroAfterDirectivePlus1_425 finds a `` `line `` directive by scanning the buffer's text for `` `line `` at the start of a line. That scan also matches a `` `line `` that sits inside a BLOCK COMMENT. Neither preprocessor applies such a directive: golden reads the physical line there, and so does slang. On pristine those reads were right; the law added 1.

| case (shape) | pristine | law | verified |
|---|---|---|---|
| VL/vl06 (`` `line `` alone in a `/* */` block) | STRICT_EQUAL | NOT_EQUAL (36 uhdm-cmp lines); downstream IDENTICAL -> DIVERGENT | STRICT_EQUAL, pristine's bytes, downstream IDENTICAL |
| VL/vl15 (the same, with the comment closing on the use line) | STRICT_EQUAL | NOT_EQUAL (36); IDENTICAL -> DIVERGENT | STRICT_EQUAL, pristine's bytes, IDENTICAL |
| VL/vl18 (indented `` `line `` in a comment) | STRICT_EQUAL | NOT_EQUAL (36); IDENTICAL -> DIVERGENT | STRICT_EQUAL, pristine's bytes, IDENTICAL |
| VL/vl05 (`` `line `` inside an inactive `` `ifdef `` branch) | NOT_EQUAL (value 6) | NOT_EQUAL (7) | pristine's bytes (6) |

On vl05 golden reads 102: Surelog applies a `` `line `` even in an inactive branch, slang does not. Neither binary reaches golden there.

§ lineDirectiveActive425v counts a directive only when slang itself applied it. The test is that the line after the directive reads the directive's own number N in slang's line map (`sm->getLineNumber`). Otherwise the scan moves on to the next candidate. Every other `__LINE__` case keeps the law's bytes: the verified binary equals the law on the 80 attack cases outside these four, and on all 109 of the implementer's grid case dirs.

Switches:
- R11V425_OFF or R11V425_LINEACTIVE_OFF gives the law's bytes on all 84 attack case dirs.
- R11U425_OFF gives pristine's bytes and exit code on all 84.

Evidence: evidence/refinement_cases.txt, evidence/grid_verified.txt and evidence/downstream_cases.txt.

## Reproduction of the implementer's numbers

- Grid: all 109 case dirs in OB, LD and UP reproduced on exit code, uhdm-cmp line count and strict verdict, on both pristine and law. There are 0 mismatches against tools/probe/r11u425repro/evidence/grid_final.txt; the goldens were rebuilt in /tmp/v11u425_gold2. Law equals verified on all 109 (evidence/r11u425_grid_pristine.txt, evidence/r11u425_grid_law_vs_verified.txt).
- Earlier-pass census: the implementer's 6011 fence-filtered case dirs, run pristine against VERIFIED. 6006 are byte-identical at the same exit code. The same 5 dirs move: r11u412 UP/up03 and up06, v11u416 VL/vl07_line_value_after, and v11u423 VS/vs03 and vs16. On v11u416 vl07, verified equals law (evidence/earlier_census_pristine_vs_verified.txt). Only one earlier case dir holds both `` `line `` and `` `__LINE__ `` (the fence-filtered text scan of 41610 .sv files under tools/probe and tests/probe). The fence filter's positive control matched 4 Surelog test dirs.
- Goal 1: all 75 SURELOG_ONLY rows of both sweeps carry a slang `error:` diagnostic, and none carries an exporter message. bp_unicore run alone with the verified binary exits 3 in 14.3 s at 804 MB maximum RSS (python rusage), with the same `basic_string::substr` error. Pass 403's size guard stands.
- sv-tests text census: the only sv-tests file holding `1'B[01xX]` is generic/number/number_test_7.sv (`parameter int foo = 1'B0;`). A traced run of the law binary on it logs no firing; the positive control is VB/vb01 under the same trace, which logs four firings. No sv-tests file holds both `` `line `` and `` `__LINE__ ``.

## Sweeps (tests/sweep.sh --jobs 3 from /tmp/wt_v11u425 for the four corpus stages; the sv-tests stage through the main tree's scripts/check_svtests.py with --baseline set to the base's results/golden_svtests.csv; each launched after three quiet readings; evidence/sweepL.log, evidence/sweepV.log)

Both sweeps read the same in every stage:

| stage | law (/tmp/v11u425_sL) | verified (/tmp/v11u425_sV) |
|---|---|---|
| probe | EQUAL 4018 + STRICT_NOTEQUAL 69, 0/0/0; csv identical to the control | same; csv identical to law |
| surelog | 480 + 0 / 474 + 0, 0/0/0; csv differs from the control only in the two LowMem log-path texts | same |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0; csv identical to the control | same |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; csv identical to the control | same |
| sv-tests | EQUAL 1881, STRICT_NOTEQUAL 2, DIFFERENT 57, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; 0/0/0; csv identical to the control and to the implementer's on all 2346 rows | same; csv identical |

- byteverify, SELFCHECK=1: law against the control reads 0 of 962, 0 of 1608 and 0 of 805. Verified against the control and verified against law read the same 0 / 0 / 0. Every self-check flags n-1 of n (evidence/byteverify.txt).
- Kept sv-tests databases: 79 of 80 are identical by normalized dump across control, law and verified. tnoc's dump hits the 900 s timeout on all three, but the three files have the same size (230131612) and uhdm-cmp reads 0 lines between control and law and between law and verified (evidence/svtests_kept_dump_census.txt).
- Canaries: canaries.sh reads ok=52 and ok=16 on both sweeps, and both ctcan2 checks PASS (evidence/canaries.txt).
- cmds.txt audit: surelog 1531 of 1581 name the binary under test, and the other 50 hold only a Surelog line. uhdm2rtlil 1742 of 1742 and svtests 2346 of 2346 name it.
- No sweep overlapped another. The sister's sweep went live after the verified sweep's corpus stage had ended, and the sv-tests stage waited until it ended.

## Attack grid (84 case dirs in VB, VL, VN, VQ; every case accepted by upstream slang with the same arguments; every golden at 0 Surelog errors and fatals; every exit code 0 on all three binaries; drivers/case.sh, drivers/grid.sh, drivers/newwrong.sh)

Pristine -> verified:
- 43 NOT_EQUAL -> STRICT_EQUAL.
- 4 NOT_EQUAL -> STRICT_NOTEQUAL:
  - VB/vb05 value: `{1'BX, 1'Bx}` folded BIN:xx where golden has BIN:XX.
  - VB/vb07 file.
  - VL/vl09 endcol.
  - VL/vl16 endcol.
- 31 NOT_EQUAL on both: 19 closer by dump distance, 12 at the same distance. Of those 12, vl05 is pristine's bytes and vn07 moves toward golden's shared constant (decoded below); the rest are byte-identical.
- 6 STRICT_EQUAL controls stay STRICT_EQUAL (vb04, vb06, vl12, and vl06, vl15 and vl18 through the refinement).
- With the verified binary, nothing ends further from golden than pristine.

The grid driver (drivers/newwrong.sh) lists every dump line the law adds that golden does not have. On VN/vn03 and vn07 (a net-declaration initializer inside a generate block) it flags INT:200 and 'b101. Decoded: golden's generate-scope Rhs IS the module's elaborated import-copy constant (INT:200 with decompile 200 at size 8, 'b101 at size 8, no typespec), shared and located at the package line. Ours is a fresh constant at the use with the same values now. So the values move toward golden, and the sharing and location residue was already there on pristine.

Downstream on the 81 class-free case dirs (pristine -> law -> verified):
- 18 DIVERGENT -> IDENTICAL.
- 4 STATUS_DIFF -> IDENTICAL.
- 2 EQUIVALENT -> IDENTICAL.
- 41 IDENTICAL kept, 5 EQUIVALENT kept, 8 DIVERGENT kept.
- Under the law, vl06, vl15 and vl18 went IDENTICAL -> DIVERGENT; under verified they are IDENTICAL again.
- Under verified, none is worse than pristine.

Per law (each moved case restored by its own switch, except where two laws fire together; R11U425_OFF restores pristine on 84 of 84):
- § oneTickUpperBNormalized425 (VB, R11U425_ONETICKB_OFF): module parameters, overrides, case items, the ternary, a function, a macro body, a net initializer, always_ff and a class method all go to STRICT_EQUAL. The spellings Surelog keeps verbatim (`1'BZ`, `1'Bz`, `'B1`, `1'sB1`) stay byte-identical (vb06). A UDP `initial q = 1'B1` stays byte-identical (vb04, golden lists no init). The package fold (vb09) and a generate-if condition `if (1'B1)` (vb10, whose elaborated copies still read 1'B1) move toward golden.
- § lineMacroAfterDirectivePlus1_425 (VL, R11U425_LINEPLUS1_OFF):
  - Reach golden: a `` `line `` naming another file (vl02), levels 1 and 2 (vl03), two directives (vl04), an indented directive (vl11), always_comb (vl14).
  - Toward golden: a localparam (vl08, residue), $display (vl09, endcol), an assertion (vl16, endcol), a parameter default above the directive (vl17).
  - Unchanged: `__LINE__` through a macro (vl13, golden reads the physical line 5) and a line comment (vl12).
  - Surelog rejects `` `ID(`__LINE__) `` (PP0110): dropped.
- § unszPkgFoldElabForm425 (VQ, R11U425_ELABFORM_OFF): every qualified `p::H` / `p::O` context reaches STRICT_EQUAL or moves toward golden:
  - procedural operand and whole right side, a case item, a concatenation, a class method, an interface, an index;
  - a $unit function, an assertion, `inside`, a select and a negation, and a generate-block net initializer;
  - `p::Z` = 'd0 (the law does fire at value 0; golden reads INT:0).
  No cell moves away. Residues:
  - the elaborated port-actual copy (vq05, golden INT:200 at size -1, ours 'd200 at 32; pass 423's vs15);
  - a localparam initializer (vq11) and a parameter override (vq15; golden INT, ours UINT);
  - values above 2^31 (vq22, golden INT:3000000000, the law abstains);
  - a genvar loop bound (vq27, unchanged), a variable initializer (vq29), the package's own function (vq31, golden folds to a constant, ours keeps the ref_obj), an enum initializer (vq33) and a package class (vq34).
- § unszPkgFoldNdaNoTs425 and § unszBinNdaKeepsTickText425 (VN): net initializers in modules, interfaces, instances, uwire, tri, wand, multiple declarators, delays and binary truncation into 2 bits all reach STRICT_EQUAL. Generate blocks move toward golden (vn03, vn07, sharing residue). A signed 'sd (vn06) and values above 2^31 (vn10) move toward golden. An operand inside the initializer (vn12) moves toward golden.

Note: evidence/grid_law_first.txt holds the first run's VQ and VN lines from before the 'sd100 package parameter was dropped from those cases. That parameter's own size is a pre-existing package-listing head that masked every case: golden -1, ours 32; it stays in vq13 and vn06.

## Cases (each first line names its law)

- VB/vb01-vb14: § oneTickUpperBNormalized425.
- VL/vl01-vl04, vl08-vl14, vl16, vl17: § lineMacroAfterDirectivePlus1_425.
- VL/vl05, vl06, vl15, vl18: § lineDirectiveActive425v.
- VQ/vq01-vq35: § unszPkgFoldElabForm425.
- VN/vn01-vn03, vn06-vn18: § unszPkgFoldNdaNoTs425.
- VN/vn04: § unszBinNdaKeepsTickText425.
- VN/vn05: § unszPkgFoldElabForm425.

## Residues on this ground (all wrong on pristine too, none moved away), ranked

1. Elaborated copies of qualified unsized reads: the port actual (vq05), localparam and override initializers (vq11, vq15), a variable initializer (vq29) and the genvar bound (vq27).
2. Values above 2^31 (vq22, vn10): golden INT:<v>.
3. The package's own function and class reads, which golden folds to a constant (vq31, vq34), and enum initializers (vq33).
4. Golden shares the module's import-copy constant with a generate-scope net initializer (vn03, vn07).
5. `1'B1` in a generate-if condition's elaborated copies (vb10), and the x-concatenation fold value BIN:xx (vb05).
6. `__LINE__` through a macro body (vl13) and through an inactive-branch `` `line `` (vl05, Surelog applies it).
7. The implementer's ranked list stands (up05, ra04, ob11/ob12, ra05, tnoc, fx68k, p733).

## Sister-ground faces

None new. The implementer's list stands (class_test_49 at TypeEmit emitSyntaxExpr, bsg_nonsynth_axi_mem at TypeEmit mapSyntaxBinOp, 18.14_1 at UhdmExporter emitClassDefn, p599 and the remaining unsized-fold cells at ModuleEmit modCaAdjustKeeps289).

## Process

- One law build and one verified build; one five-stage sweep on each, never overlapping another sweep.
- The fence list was read into a file by a program and never printed. Every tree-wide list was filtered on it before any file was opened. No fenced test was named, opened or run.
- No other agent's process was touched.
- Slips: the first golden loop listed directories with `ls */*`, which wrote golden dirs keyed on garbage names into /tmp/v11u425_gold. That cache was abandoned for /tmp/v11u425_gold2, and nothing was measured from it. The first error counter matched Surelog's `[  ERROR] : 0` summary line; it was replaced by a count of `[ERR:`/`[FAT:` lines before any case was judged.
