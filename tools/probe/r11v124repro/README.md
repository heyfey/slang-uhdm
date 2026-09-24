# r11v124 — adversarial verification of r11u124

Verdict: **ACCEPT-WITH-FIX.** The implementer's numbers reproduce exactly. The adversarial pass found
one real regression, in § pkgQualFoldSpanByView124: in the definition listing of a module with a
parameter port list, strict cells moved away from golden. The fix is § qspanPhysDefView124v. The pass
also found one wrong-token placement in § aggArrayOuterRangeLoc124 (the inline struct/union body); the
fix is § aggRngSkipInlineBody124v. Both fixes are gated and each can be dropped alone. The verified
patch is the implementer's patch plus these two sub-laws, this directory and the regenerated
tests/LAWS.md.

Base `7bd06f52`. Worktrees `/tmp/wt_v11u124` (patch + fixes) and `/tmp/wt_v11u124pris` (pristine),
built with the system-deps config at `-j 2`. Every binary was frozen (`chmod 555` copies) before it
measured anything, and every `cmds.txt` names the frozen binary: pristine, law and fix sweeps each
have 3273 of 3273 slang lines.

| binary | md5 |
|---|---|
| pristine (byte-identical to the main tree's `build/slang-uhdm`) | `cb7b39bd1fa880fa84d54d11d9ff8ce2` |
| law (`/tmp/r11u124.patch` as shipped, identical to the implementer's `law5.bin`) | `4bfab8b9a6fc92d4c9b8d2fc29be022b` |
| fix (law + the two v-laws below) | `3be939c276a03a1317cf459b8ce86b53` |
| `build/uhdm-strictcmp` | `88bf7040c706f80686ea981e6a8650c8` |

## 1. The headline numbers, reproduced

| axis | pristine | law (reproduced) | fix |
|---|---|---|---|
| surelog strict-equal (of 954 judge-equal row-modes) | 521 | 565 | 565 |
| uhdm2rtlil strict-equal (of 1606) | 1072 | 1134 | 1134 |
| probe strict-equal (of 4087) | 1712 | 1846 | 1846 |
| probe gate | EQUAL=4087 | EQUAL=4087 | EQUAL=4087 |
| surelog scoreboard | 480/3 + 474/3 | same, regressions=0 conversions=0 changes=0 | same |
| uhdm2rtlil scoreboard | 803/1/67 both modes | same, 0/0/0 | same |
| downstream (871) | baseline 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT | same, 0 rows changed (verdict and `differs`) | same, 0 rows changed |

Checks on these numbers:
- The pristine strict columns equal `results/golden_*.csv` on every row.
- Law vs pristine strict classes, from the implementer's `drivers/strictdiff.py` on my csvs:
  - surelog: TO-EQUAL 44, BETTER 39, FIELD-CHANGE 22.
  - uhdm2rtlil: TO-EQUAL 62, BETTER 58, FIELD-CHANGE 10.
  - probe (`drivers/probe_strict.py`): TO-EQUAL 134, BETTER 161, FIELD-CHANGE 72, plus 18 byte movers with the same verdict.
- Byteverify (SELFCHECK=1) law vs pristine: surelog 121/960 and uhdm2rtlil 138/1608 movers. Selfcheck flagged 959/960 and 1607/1608, and the path sets are identical. All 259 movers appear by name in the implementer's `evidence/predictions_pristine.txt`. 26 predicted databases did not move: 12 are the implementer's "predicate wider than the law" rows (6 CASTFILE, 6 QSPAN-elab), and 14 are LHSCLONE-only, which is the reverted R1.
- All eight example rows in the implementer's table read exactly as quoted, for example:
  - `uhdm2rtlil ImportedParameter,testflags,CMP_EQUAL,,,differ:file(1)` → `equal`
  - `surelog ParamConstPush,testflags,…,differ:endcol(3)` → `equal`
  - `surelog TypedefRange,testflags,…,differ:file(4)` → `differ:fullname(1)`
- Canaries: `canaries.sh` / `ctcan2.sh` read FAIL on the PRISTINE csv too, because the committed baselines are CRLF. With CR stripped (`tr -d '\r'`):
  - pristine: surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 uhdm2rtlil PASS.
  - law: canaries CHANGED only on strict counts. Earlgrey_0_1 goes `line(5180)` → `(5172)` and BuildUVMPkg `fullname(346)` → `(342)`. ctcan2: EvalFuncNamed `file(2)` → `equal` and `file(14)` → `fullname(12)`. Every status is unchanged.

## 2. What the implementer's census missed

A column census cannot see a cell moving away from golden inside a row that stays `differ`, or whose
first field changes. The implementer's `worse.py` only records divergence before the first walk
divergence, so it passed rows that contain such cells. `drivers/pathchk.py` keys every strictcmp walk
record by its ancestor chain (type and name at each level, plus an occurrence index). It then compares
pristine and patched against golden key by key:
- AWAY: pristine equals golden and the patched binary does not.
- FWORSE: both differ from golden and the patched record matches fewer of golden's fields.

Run over all 385 moved probe cases and all 259 corpus movers, it found:

- **probe `r10earl76repro/g2_orig76`: AWAY 2.** `package g76p; parameter int NX = g76q::QC;` is imported by two modules with a parameter port list (`#(parameter int MP = 3)`). In golden's definition listing, the import copy's folded constant spans the qualifier, 23:26-32 (as in the package views). The elaborated instances span the whole reference, 23:26-34. Pristine was right in the definition listing and wrong in the instances. The law fixed the instances and broke the definition listing, because `§ pkgQualFoldSpanByView124` keyed the definition listing on `!topView`, and `§ modDefImportShape` flips `topView` to true for exactly these rows. The strict column only moved `value(14)` → `col(2)`, which hides the two cells.
- **surelog Earlgrey_0_1, both modes: AWAY 35.** The same face on alert_pkg import copies (golden `alert_pkg.sv 9:44-67`, law `9:44-74`) in modules with parameter port lists. The column reads `line(5180)` → `line(5172)`, which also hides it.
- Everything else is TOWARD only. The exceptions are the known UVM order coins:
  - MiniAmiq and SeqDriver: only the `uvm_misc.svh:642` `UINT:<n>` constant differs.
  - Scoreboard: a pristine null rerun has the same PRESENCE/FSAME signature. The law against the null rerun is TOWARD 75, AWAY 0.

Fresh grid `qf/` confirms the face. `qf/f1` body import, `f2` header import, `f4` a type-parameter port
list and `f6` an explicit import are all judge-equal. Their strict column goes `differ:depth` (the
C0012 walk divergence at object 45) → `differ:endcol`: a new differing object 42, the definition-view
constant `3:32-37` where golden has `3:32-35`. `f3` (no parameter port list) is the control: `endcol` → `equal`.

## 3. The fixes (gated; `R11U124_OFF=1` still restores pristine bytes on all 191 cases checked)

### § qspanPhysDefView124v (`R11V124_QSPANPHYS_OFF`), in ParamEmit.cpp inside the § pkgQualFoldSpanByView124 view lambda
The definition listing is the physical definition view (`defViewOrig9`), not the flipped `topView`.
This changes behaviour only on import copies that § modDefImportShape flips. Measured with the fix
binary against the law binary:
- surelog byte movers: 6 of 960. These are Earlgrey_0_1 in both modes (35 cells TOWARD, 0 AWAY) and the MiniAmiq/SeqDriver coin constant.
- uhdm2rtlil: 0 of 1608.
- probe: 1 of 4087, g2_orig76 (the two cells TOWARD).
- The strict column did not change on any row-mode, so the scoreboard figures are identical to the law's.
- Grid `qf/`: f1 f2 f4 f6 return to `differ:depth` (pathchk TOWARD 1 each against pristine). f3 stays `equal`. The implementer's `c14/` cells p01 p02 p03 p06 p07 p08 stay `equal`.

### § aggRngSkipInlineBody124v (`R11V124_AGGRNGBRACE_OFF`), in ParamEmit.cpp at the § aggArrayOuterRangeLoc124 site
Take `typedef struct packed { logic [1:0] x; } [3:0] b;` in a package. The law's `scanDimSpans` took
the member's `[1:0]` (2:44-49) as the outer dimension, where golden has 2:55-60. The fix scans only
after the closing brace, and only when the type syntax is an inline StructType or UnionType.
Case `gx/g01_inline` (stage 1, 85 uhdm-cmp lines on all three binaries): the dump-diff against golden
drops from 171 to 151 lines, and the range and bounds now read golden's tokens. No corpus or probe
database moves. The switch restores the law's bytes.

## 4. Breaking the laws: 109 fresh cases (pristine vs fix; `evidence/cases_fix_vs_pristine.txt`)

Each case's first line names its law. Golden is the pinned Surelog with the probe flags, cached by
content. Every case records rc. The only nonzero rc are `pv/v14_string` and `qx/q08_string` (rc=3, no
database on either binary: a string parameter indexed as `S[0]`).

| grid | law | cells | → equal | equal both | differ both | stage-1 |
|---|---|---|---|---|---|---|
| lx | § impLhsCloneFile124 (package in an include, explicit imports, two packages, macro-declared parameter, interface body import) | 5 | 5 | 0 | 0 | 0 |
| cx | § castTsFile124 (cast in an include, a macro from a header, a multi-line macro, nested macros, two casts on one line, package function, class, localparam, two lines, macro width, always_ff, package typedef cast, gen-for, macro used twice, cast as a macro argument, shortint macro) | 16 | 6 | 4 | 2 | 4 |
| rx | § realLitValueIsText124 (macro literal, compare, negative, delay, class, qualified parameter, gen localparam, macro argument, function, underscores/exponent, override, localparam expression, continuous-assign underscores, `12.5E+2`/`3e-2`, procedural `1.50`/`2.000`, class `1.0e3`/`007.50`, macro in a continuous assign, gen-block assign, function argument) | 19 | 7 | 1 | 2 | 9 |
| hx | § incDecMemberPathIsLvalue124 (array element base, for step, rhs `x = s.a++`, class chain `d.e.n++`, compound `+=`, `s.arr[i]++`, `q[i].a++`, pre-dec, while condition, static `C::cnt++`, union, package struct in always_ff, `this.s.b++`, three levels, argument next to an rvalue) | 15 | 8 | 2 | 1 | 4 |
| qx | § pkgQualFoldSpanByView124 (module port parameter, non-bare, package chain, flipped view, interface, parens, enum constant, string, override, gen localparam, class parameter, expression source, vector instance, `pk :: X`) | 14 | 3 | 0 | 3 | 6 (+1 rc=3) |
| qf | § qspanPhysDefView124v (the face above) | 6 | 1 (f3) | 0 | 4 | 1 |
| gx | § aggArrayOuterRangeLoc124 / § aggRngSkipInlineBody124v (inline struct, parameter bound, ascending, spaced, macro bound, cross-package element, union 2-D, multi-line) | 8 | 0 | 0 | 4 | 4 |
| pv | § paramValueIsDefRhs124 (override, derived localparam, two instances, `$clog2`, pass-through, interface, class, truncation, gen instances, defparam, package derived, shadowing import, enum, string, positional, struct, `$bits`, type-parameter width, negatives, `'1`/`'x`, gen localparam, localparam port, ternary, import override, real override, interface port) | 26 | 0 | 12 | 2 | 11 (+1 rc=3) |

Results:
- pathchk over every judge-equal mover: no AWAY and no FWORSE cell (`evidence/cases_pathchk_fix.txt`).
- Every stage-1 cell keeps its exact uhdm-cmp line count on all three binaries.
- Stage-1 dump-diffs against golden (`evidence/cases_stage1_dumpdiff_fix.txt`) fall or hold, with two exceptions (both residue V2):
  - `pv/v17_bits`: golden folds `$bits(logic [11:0])` to `UINT:1`. The law writes our Rhs value `UINT:12` where pristine had none.
  - `rx/r06_pkgqual`: our Rhs for `parameter real R = p::S` stays a `ref_obj` where golden folds `REAL:0.125`. The clearing half removes the value that pristine shared with golden.
- Downstream on every case, pristine vs law (`evidence/downstream_cases.txt`): no case changed verdict except `rx/r13_ca_under`, EQUIVALENT → **IDENTICAL**. The fix binary on qf/, gx/g01 and g2_orig76 gives the same verdicts.
- Switches (`evidence/switches.txt`): `R11U124_OFF=1` on the fix binary equals pristine bytes on 189 of 191 cases (mine + the implementer's 81); the 2 are the rc=3 cases. `R11V124_QSPANPHYS_OFF=1 R11V124_AGGRNGBRACE_OFF=1` equals the law's bytes on the same 189.

Earlier passes' cases as controls (`evidence/controls_earlier_passes.txt`, pristine vs fix, my own golden cache):
- Verdicts are unchanged everywhere except r11u119 g3 n_dir_real/n_nodir_real (value → equal), r11v120 d08/t02 (file → equal) and r11u121 s08_imp_ps (file → fullname, TOWARD 1). These match the implementer's report.
- Byte movers:
  - r11u118: 8 of 56.
  - r11v11u118: 2 of 56.
  - r11u120: 6 of 44.
  - r11v120: 17 of 47.
  - r11u121: 14 of 83.
  - v11u121: 2 of 41.
  - r11u123canon: 0 of 22.
- Every judge-equal mover is TOWARD-only. Every stage-1 mover keeps its cmp line count, and its dump-diff holds, falls, or (`v11u121 b15_pkg_localparam`) gains one wrong value line where golden's is itself wrong (golden `HEX:A5`, the pass-121 member-fold residue; law `BIN:0101`; pristine none).

## 5. Gates (fix binary)

1. Builds: md5s above.
2. Probe: `EQUAL=4087 (of 4087)`; strict tally equal=1846, the same as the law's.
3. Corpora: `regressions=0 conversions=0 changes=0 only-fresh=0 only-committed=0` in both corpora and both modes.
4. Downstream: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`. The row join against `results/downstream_uhdm2rtlil.csv` changes 0 of 871 rows (verdict and `differs`), for both the law and the fix binaries. The binary was audited by the bytes of a moved row: ImportedParameter's `slang.uhdm` equals a fresh law.bin run.
5. uhdm-cmp: every row-mode keeps its status and every probe case is EQUAL.
6. Byteverify, fix vs pristine: surelog 121/960 and uhdm2rtlil 138/1608. These are the law's movers. Fix vs law: 6/960 and 0/1608, named above and predicted by pathchk before the fix sweep. pathchk over all fix movers finds 0 AWAY outside the UVM coin family (`evidence/corpus_pathchk_fix.txt`).

## 6. Residues (ranked)

- V1 (R1 of the implementer, unchanged): C0012. Its imported-parameter clone gate reads the same flipped view flag as the one behind § qspanPhysDefView124v. This pass's qf/ grid is the C0012 walk divergence (`differ:depth` at the definition-view import copy) in four more shapes.
- V2: § paramValueIsDefRhs124 follows OUR definition Rhs. On stage-1 shapes where our Rhs differs from golden's (an unfolded real `p::S`, a `$bits` that golden misfolds), the value follows ours. That is right on every judge-equal row (the implementer's census, and none of mine regress), but it moves one value away on `rx/r06_pkgqual`. Downstream is unchanged (EQUIVALENT on both binaries). The value is not a strict cell.
- V3: § castTsFile124 stamps the file the push site computes. For a macro defined in a header and invoked in dut.sv (`cx/c02_inclmacro`), both the cast operation (pre-existing setLoc) and the stamped typespec read the header, where golden has the invoking file. This is a `setLoc` macro-file rule outside this ground.
- V4: in a multi-line macro (`cx/c03_multiline_macro`), golden's line numbers follow Surelog's own macro layout. This is pre-existing.
- The implementer's R2–R7 were not re-litigated beyond the numbers above.

## Files
* `pv/ hx/ cx/ rx/ qx/ qf/ gx/ lx/` — the cases (first line names the law).
* `drivers/run2.sh` runs one case: the golden (cached by content md5), pristine and patched, uhdm-cmp, strictcmp, and a byte compare.
* `drivers/pathchk.py` is the path-keyed record census (TOWARD / AWAY / FWORSE / PRESENCE).
* `drivers/mover_chk.sh` and `drivers/rw_probe.sh` apply pathchk to corpus and probe movers. `drivers/probe_strict.py` is the per-case probe strict join.
* `drivers/ds_case.sh` runs the downstream verdict of one case. `drivers/sw.sh` is the switch check. `drivers/env.sh` holds the tool paths.
* `evidence/` holds sweep summaries, strict diffs, byteverify, pathchk outputs, case grids, downstream, switches and controls.
