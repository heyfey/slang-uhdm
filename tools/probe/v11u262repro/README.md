# v11u262 — adversarial verification of r11u262

Base d019d9dd9 (pass 260). Implementer's patch /tmp/r11u262.patch (md5 b5183bd3c9840fbb8a9a58965acbdf95), applied clean
to a fresh d019d9dd. Binaries built here and frozen before any measurement (system-deps config, slang
12.0.0+545f88b2e):

| binary | md5 | what |
|---|---|---|
| pristine | 5f13d6064e32de7d46471274b28444c2 | the base, identical to the implementer's pristine |
| law | faa368c2b352fc31e2ed137a9e4cc015 | the implementer's patch, identical to the implementer's law binary |
| fix | 32b4b9a7b749788ebbf22ac3287447f7 | the law plus this pass's three refinements (below) |

**Verdict: the five laws reproduce bit for bit on every gate, but three of them break legal SV where pristine was
right. All three breaks are fixed here behind their own switches. The fix changes no corpus, probe or downstream
database against the law, so every gate number of the implementer stands as it was.**

## 1. Reproduction of the implementer's numbers (law binary)

* Sweep (`tests/sweep.sh --jobs 3`, all four stages; `evidence/sweep_L.txt`):
  * probe: EQUAL 3571 + STRICT_NOTEQUAL 516, regressions=0, conversions=5, changes=0.
  * surelog: 944 + 10, regressions=0, conversions=2, changes=2.
  * uhdm2rtlil: 1606 + 0, no change.
  * downstream: IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2, 0 not excused; the csv is identical to the pristine
    sweep's.
  * The pristine sweep reads exactly the baselines (probe 3566 + 521, surelog 942 + 12; `evidence/sweep_P.txt`).
  * Every sweep exits 1 on the law-index staleness check alone. The committed index is stale at the base, and this
    pass's case files were not yet indexed.
* Targeted rows, the same as the implementer's:

      BlackBePipeInt,default,CMP_EQUAL,,,equal
      BlackBePipeInt,testflags,CMP_EQUAL,,,equal
      Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
      Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(16),,differ:fullname(16)

  The heads after the patch (uhdm-strictcmp --max 3):
  * default: #600811 / #600816, then #729363;
  * testflags: #530951 / #530956, then #580520.

  uhdm-cmp reads 0 lines on all four row-modes. The surelog csv differs from pristine's only in these four rows (and
  in the LowMem log path).
* Firing census (the implementer's tracecensus.sh, run here with the law binary before the law sweep;
  `evidence/predict_law.txt`): line for line the implementer's 10 MOVER lines.
  * byteverify (fence-filtered mirrors, 8 fenced databases skipped unread): 4 / 2560 corpus movers (BlackBePipeInt
    d/t, Earlgrey d/t).
  * SELFCHECK reads 2559 / 2560. The self-check compares every file against one fixed file, and that file is not
    flagged against itself; it is a self-check artifact, not a movers line.
  * Probe: 6 / 4087 movers (run here from one worktree for all three binaries, since the databases embed the
    checkout path): g5_int105, g4_shadow85, g5_noshadow85, uf, v7_inst64, r11u114 grid/f3/c05.
  * Downstream: 0 / 805 movers. Every mover was predicted.
* Chain-keyed away census (awayrows.py): 0 away on all 10 movers. Earlgrey d has 18 records toward golden, t 17;
  BlackBePipeInt reads flat_away 73 with chain away 0, the canonicalised STRICT_EQUAL case.
* Canaries:
  * surelog ok=50 changed=2 (the Earlgrey rows); uhdm2rtlil ok=16.
  * ctcan2 uhdm2rtlil PASS. ctcan2 surelog FAIL only on the two BlackBePipeInt conversions; it PASSES on pristine.
* Binary audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary; the other 50 carry no slang line.
* Grid: the implementer's 111 dirs rerun here, 1776 lines. Every field except md5 is identical line for line to
  their `grid.txt`; the md5 differs only because the databases embed the checkout path. The summary is
  `evidence/gridsum_impl_rerun.txt`: 152 moving, 94 entering STRICT_EQUAL, none leaving.

## 2. The breaks (pristine right, law wrong, legal SV) and the fixes

All three fixes are refinements inside the implementer's laws. Each has its own switch; `R11V262_OFF` drops all three
and gives the law's bytes, and `R11U262_OFF` still gives pristine's bytes.

1. **§ impConcatShareSameDecl262v** (ParamEmit, inside § impConcatParamShared262; `R11V262_SAMEDECL_OFF`).
   * **The break.** The Rhs share is keyed by parameter NAME. Take two unrelated packages, `a::X = {A1, A2}` and
     `b::X = {B1, B2}`, both wildcard-imported. The law hands b's elaborated import copy a's concatenation, which
     has the wrong span and the wrong VALUE. Golden keeps b's own operation (line 10:29).
   * **Downstream impact.** cases/VE/ve02 reads IDENTICAL on pristine and **EQUIVALENT on the law**. RTLIL
     `parameter \X 8'00110100` (golden) becomes `8'00010010` (ours; `evidence/ve02_law_nohier.diff`).
   * **The fix.** Share only when both copies come from the same declaration (the same source location). This is the
     re-export case: BlackBePipeInt, and the implementer's E/e01, e03 to e10.
   * **Where it moves.** VE ve01 to ve07 return to pristine's bytes, 14 case-views. The fix moves 0 of the
     implementer's E cases, and BlackBePipeInt still converts.
2. **§ bodyParamNoHdrList262v** (ParamEmit, the park of § shareDefParamTsOwnNotImport262; `R11V262_HDRLIST_OFF`).
   * **The break.** In golden, a BODY parameter (a localparam or parameter declared in the body) keeps the
     package's typespec whenever the module has a parameter port list, with or without a generate block. That
     covers `#(parameter bit E = 1)`, `#(localparam ...)`, `#(parameter type T)` and even an empty `#()`, and holds
     whether or not the instance overrides. A module with no header list reads its own declaration.
   * **The implementer's distinguisher was wrong.** Its rule was "an instantiated if/case-generate block of the body
     reads the name". That only fits its four cases (d24, d26, vs09, vs15) because all four also have a header
     parameter.
   * **Where the law broke.** Pristine is STRICT_EQUAL and the law STRICT_NOTEQUAL `line` on 17 case-views:
     * VH vh01: a header parameter and no generate at all;
     * vh03, vh06, vh14 and vh15;
     * VD vd01_el: if-generate inside a for-generate;
     * vd07: the read only in the not-taken branch;
     * vd13: an if condition and a for bound;
     * vd14: the if-generate reads `K_2`, not `K`.
   * **Away by record** (pristine already wrong in other fields): vh08, vh09 (`dist 0 -> 1 lost=1`) and vh10.
   * **Where the law is right.** No header list: vh02, vh05, vh11, vh12, vh13, and every implementer D mover. Port
     parameters keep the law: vh07 and d02.
   * **The fix.** The law abstains for a body parameter of a module whose declaration has a parameter port list. The
     if/case test stays as it was.
   * **Where it moves.** 26 case-views, each back to pristine's bytes. None of the implementer's D cases moves.
     Earlgrey keeps all 10 SHAREDEFOWN firings (the census reads the same FIRE counts), so its records still clear.
3. **§ loopBoundBinOperandPlainLhs262v** (ExprEmit, inside § genLoopDirectBoundPaConst262; `R11V262_LOOPOPND_OFF`).
   * **The break.** Take a select that is a DIRECT operand of a BINARY operation (`a[K +: 2] & 2'b11`,
     `a[h +: K] | x`, `a[K +: 2] == 2'b01`) in an assignment whose left side is a plain outside signal. Golden keeps
     the substituted constant parented at the select and names its reference through the select
     (`work@top.u.gf[0].a`). The law re-parents it at the param_assign and names it `work@top.u`.
   * **Measured.** The parent line golden and pristine share is lost (`dist 4 -> 5 lost=1`). The strict count is
     unchanged, because the field is vpiParent, but on stage-1 cases the dump distance grows. Shapes: VL vl15,
     vl18, vl19, vl24 to vl33, vl36 to vl39, and VH vh04.
   * **Where the law is right.**
     * a select left side: vl34, vl35, B/b30;
     * a generate-local left side: vl40, and the implicit net vl41;
     * a member left side: vl42;
     * the whole right side: vl20 to vl22;
     * a unary, concatenation, replication or conditional operand: vl08, vl10, vl13.
   * **The fix.** Abstain only in the window that breaks.
   * **Where it moves.** 36 case-views, each back to pristine's bytes.
   * **A first attempt was withdrawn on the grid.** An abstention on "body parameter of a module with a header list"
     (the same distinguisher as fix 2) reverted the law-right vl20 to vl23 and B/b30. It was withdrawn before any
     gate measurement (binary fix2 never swept).

## 3. Gates on the fix binary

* Sweep (`evidence/sweep_F.txt`): probe 3571 + 516, surelog 944 + 10, uhdm2rtlil 1606 + 0, downstream
  803 / 66 / 2 / 0.
  * Every csv is identical to the law sweep's: the surelog csv modulo the LowMem path, probe and uhdm2rtlil byte
    for byte, downstream identical to pristine's.
  * regressions=0 in every stage, with the same 5 probe and 2 surelog conversions and the same 2 changes.
* Prediction, frozen before the fix sweep (`evidence/predict_fix.txt`, the census run with the fix binary): the FIRE
  sets are identical to the law's. Not one SAMEDECL or LOOPOPND line appears in the corpora or the probe, and the
  HDRLIST lines are abstain-only on parameters the law never claimed. The prediction is 0 movers against the law.
* byteverify, fix vs law: 0 / 2560 corpus, 0 / 4087 probe, 0 / 805 downstream. Fix vs pristine: the same 4 corpus
  and 6 probe movers as the law (`evidence/byteverify.txt`).
* Away census, chain-keyed, fix vs pristine: identical to the law's (0 away on all 10).
* uhdm-cmp: 0 lines on Earlgrey d/t and BlackBePipeInt d/t.
* Canaries and ctcan2: as for the law.
* Binary audit: 3265 / 3315 name the fix binary.
* Determinism (`evidence/determinism_fix.txt`): three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard (default) and BuildUVMPkg give one hash each, equal to the sweep's. Scoreboard
  testflags has no database in either sweep.

## 4. Grids and controls

* **Fresh cases** (cases/VA 16, VB 13, VD 14, VE 7, VH 15, VL 42 = 107 dirs, 214 case-views; `evidence/tri_P_L_F_FV.txt`,
  `trisum.txt`; every line carries rc, every rc 0).
  * The law moves 152 case-views: 50 enter STRICT_EQUAL and **17 leave it** (the breaks above).
  * The fix moves 82 against pristine: 50 enter STRICT_EQUAL, none leave.
  * `R11V262_OFF` gives the law's bytes on 214 of 214.
* **Implementer's cases** (222 case-views): the fix gives the law's bytes on all 222.
* **Switch attribution** (`evidence/switches_fix.txt`, 436 case-views):
  * `R11U262_OFF` on the fix binary gives pristine's bytes on 436 of 436.
  * Each fix mover is moved by exactly one of HDRLIST 26, SAMEDECL 14 and LOOPOPND 36. The exception is VH/vh04 in
    both views, which carries both shapes and moves under both switches.
* **Away census, fix vs pristine** (`evidence/away_fix_vs_pristine.txt`): 0 lost on every mover except:
  * the implementer's explained losses: A/a16, a22, B/b31_el, D/d08, E/e05 to e08 and E/e10. D/d08 was checked
    here: golden's param_assign reads the module's own int_typespec at 5:37 exactly as the law writes it, and the 2
    lost lines are the package typespec printed elsewhere for golden's mis-folded value. E/e10 was checked too:
    golden holds 5 `work@top.i` references, pristine 3 and the law 2, and the lost one sat in pristine's unshared
    copy;
  * VA/va08 (stage 1, dist 34 -> 5, 1 lost 2 gained);
  * VE/ve04 and ve06 (stage 1, dist 149 -> 128 and 81 -> 59, generic `|vpiParent:` / `|vpiActual:` lines of the
    landed same-declaration share).
* **Downstream on the fresh cases** (`evidence/ds_cases_*.txt`):
  * pristine 95 IDENTICAL / 6 EQUIVALENT / 5 DIVERGENT / 1 STATUS_DIFF;
  * law 94 / 7 / 5 / 1, with **ve02 IDENTICAL -> EQUIVALENT**;
  * fix the same as pristine on every case.
  * The DIVERGENT and STATUS_DIFF verdicts are pre-existing on all three binaries (va02, va10, ve03, ve04, ve05,
    ve07).
* **Byte controls** (34 repro dirs: the implementer's 24 plus r11u184, r11u105, r11u116, r11u192, r11u250, v11u250,
  v11u252, v11u254, v11u261 and r11u259. That is 2483 dirs and 4966 case-views on three binaries; paths filtered by
  $FENCED before opening; `evidence/controls.txt`):
  * The law moves 118 and the fix the same 118 with **identical bytes**. 74 enter STRICT_EQUAL, none leave, and no
    exit code or uhdm-cmp line count changes.
  * The 21 nonzero rcs and 9 missing databases are the same on all three binaries.
  * The new movers beyond the implementer's 106 are v11u250 (2), v11u252 VU/vu03 (4), v11u254 (4) and v11u261 (2).
  * Away census (`controls_away_fix_vs_pristine.txt`): 0 lost except v11u252 VU/vu03_shadow_child(_typed) d/el,
    `lost=1 gained=1, distance unchanged`. This was checked: the overridden instance c2's param_assign moves to
    golden's own typespec (7:16), and the lost 3:1 line is the package int_typespec golden prints 57 times, pristine
    51 and the fix 50.

## 5. Residues, ranked

1. Earlgrey: every remaining record is on the sister ground, as the implementer listed it.
   * d #600811 / #600816 and t #530951 / #530956: ModuleEmit § genCaReplWholeFold78 parents the whole-right-side
     replication fold at the cont_assign, where golden leaves it unparented for a module-body target (the
     implementer's cases/decode/C).
   * d #729363: ModuleEmit's module-body fold leaves it unparented.
   * d #816151 / #816152: `sha_word_t`.
   * t #580520 to #594077: the port-actual struct members, ModuleEmit or the elaborator.
   * t #604991: the flash_mp variable listing.
2. This ground, standing on both binaries:
   * the D shapes where golden folds the package VALUE (D/d04 to d08 and others; VD vd03, vd05, vd06, vd09, vd10,
     vd11 stage 1);
   * the package-listing order face that puts every multi-package case in stage 1 (vd05 `RHS: <null>` on the
     design's package vector);
   * the implementer's B/b11, b24, b39_el, A/a12, a18 and E/e10 #931.
3. The two refinements' own residues:
   * an if/case-generate read in a module WITHOUT a header list (vh12, vh13) still abstains by the implementer's
     textual test. Both are stage 1 on both binaries and the direction is unmeasured;
   * LOOPOPND abstains for every binary operation, including shapes not gridded (shifts, inside, `**`).
4. Not attempted: brief items (2) to (7).

## 6. Process

* All three breaks were found by fresh cases on legal SV and fixed in a third worktree. Pristine was frozen before
  any edit. The fix binaries fix1 (0bdf16b0: SAMEDECL plus HDRLIST), fix2 (3b5f845c: the withdrawn header-list
  LOOPBOUNDPA abstention) and fix3 (2c889ba8: LOOPOPND without the generate-local exemption, which reverted vl40)
  were measured on cases only. fix1 was also measured on Earlgrey and BlackBePipeInt only, with bytes identical to
  the law's. Only the final fix (32b4b9a7) was swept.
* Two cases were illegal and were rewritten before any law measurement: va03 (use before declaration, rc 3 on
  pristine) and ve05 (interface header import syntax).
* SLIPS:
  * One waiter ran `pgrep -f` with a pattern its own shell matched. It was stopped by its own task id, and no
    process was signalled.
  * The first binary audit counted the 8 fenced rows' `cmds.txt` (harness command lines only: no source, no
    database). The reported audit was redone with the fence-filtered list.
  * No fenced test was dispatched, run, read or decoded outside the gate sweeps. Every corpus path list was
    fence-filtered before opening.
* After the measurements, the first line of 37 fresh cases was renamed to the refinement it motivates. VE now names
  § impConcatShareSameDecl262v; VH / VD name § bodyParamNoHdrList262v; VL and vh04 name
  § loopBoundBinOperandPlainLhs262v. vh15's title was corrected. All are comment-only edits, and no line moved.

## Cases (each names its law in its first line)

* VA va01 to va16: § genEnumVarLocatedConst262.
* VB vb01 to vb13: § genIpsOvrParamOwner262.
* VD:
  * vd01, vd07, vd13, vd14: § bodyParamNoHdrList262v;
  * the others: § shareDefParamTsOwnNotImport262.
* VE ve01 to ve07: § impConcatShareSameDecl262v.
* VH:
  * vh01, 03, 06, 08, 09, 10, 14, 15: § bodyParamNoHdrList262v;
  * vh04: § loopBoundBinOperandPlainLhs262v;
  * the others: § shareDefParamTsOwnNotImport262.
* VL:
  * vl15, 18, 19, 24 to 33, 36 to 39: § loopBoundBinOperandPlainLhs262v;
  * the others: § genLoopDirectBoundPaConst262.

Drivers (drivers/; paths from this checkout, $FENCED fail-closed via env.sh; B, S and the tool pins exported by the
caller):
* copied from r11u262repro: env.sh, case.sh, grid.sh, gridsum.py, awayall.sh, away.py, awaydump.py, awayrows.py,
  dscases.py;
* adapted: controls.sh (three binaries);
* new: tri.sh, trisum.py, switches.sh.
