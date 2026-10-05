# v11u250: adversarial verification of r11u250

Base de569463 (`matrix-1.87`, pass 248 on top of pass 249). This directory verifies the r11u250 patch (eight laws
in src/ParamEmit.cpp behind src/R250.h) and carries the verifier's three fixes, each behind its own switch.

**Verdict: the headline numbers reproduce bit for bit, and the laws hold on the gate. Fresh cases found three
defects on legal SV, all fixed behind their own switches. In one of them, § pcwRefLastWriter250, pristine was right
and the law was wrong. The fixes move no gate database.**

| binary | md5 | how |
|---|---|---|
| pristine | 409b8458c62d0339200319d742d4079d | /tmp/wt_v11u250pris at de569463, the main tree's md5 |
| law (r11u250) | 44ecd8c1b6711bb63e084f0ffe05f599 | /tmp/r11u250.patch (md5 cf37cae4...) applied on a fresh de569463, the implementer's md5 |
| fix (v11u250) | f2ccca7572c14135b90ab8673f97a4ca | the law tree plus this pass's three fixes |

All three binaries link slang 12.0.0+545f88b2e. They were frozen under /tmp/v11u250_bin before any measurement.
Every cmds.txt of the pristine and law sweeps names its own frozen binary: 3265 of 3265 per sweep. The other 50
are SURELOG_FAIL rows that never run slang. The audit list was filtered by $FENCED before any file was read.

## The fixes (switch R11V250_OFF drops all three; R11U250_OFF still restores pristine bytes)

| fix | switch | site | what |
|---|---|---|---|
| § pcwOtherSymKeeps250v | R11V250_PCWOTHER_OFF | ParamEmit `pcwRefLastWriter250`, the listings it reads recorded in `stampParenCastWidthTs` and `claimParenCastWidthOwner` (`pcwUps250v`) | § pcwRefLastWriter250 picked the typespecs to re-point by the reference's NAME. A module's own parameter of the same name, also used as a paren-cast width (`module sub #(parameter int W = 4) ... (W)'(x)` beside a package `W` used the same way), lost its own reference. That reference is minted by `stampCastSizeParamTs`, so § parenCastWidthRefPkgBare207's list never held it. It was re-pointed to the package's shared one. Golden keeps `ref_obj work@sub.W.W` -> `parameter work@top.u.W`, and pristine wrote it. A reference already bound to a parameter that is none of the declaring symbol's listings, copies or claimed owner now keeps its binding. |
| § kwAliasDeclResolves250v | R11V250_KWDECL_OFF | ParamEmit `pkgAliasOfKwBind250`, the declarator scan | The scan keyed a declaration by file BASENAME, line and column, and read a bare name as the package alias wherever it was written. Case D/d01: a module's own `typedef real al_t; al_t x;` got `p::al_t` (golden: the module's `al_t` 10:11). Case D/d04: `q::al_t v;` in b/x.sv sits at the position of `p::al_t v;` in a/x.sv, and work@top.a.v got `q::al_t` (golden: `p::al_t`). The fix keys by the full path and drops any key two declarations share. It reads a bare name only when exactly one typedef, type parameter or class of that name is declared in the design. |
| § arrQualDeclFullPath250v | R11V250_QUALKEY_OFF | ParamEmit `pkgArrTdBindCopies250`, the qualified-declarator scan | The same basename key. Case C/c08: an imported `a_t v;` in b/x.sv sits at the position of a `p::a_t v;` in a/x.sv, so it was read as qualified and kept the listing. Golden binds the aliased copy. Keyed by the full path, the law's own rule applies: law stage 1 (17 lines) -> fix STRICT_EQUAL in both views. |

Each fix lives inside its law's branch, and the trace (R11U250_TRACE) names it: `pcwOtherSymKeeps250v`,
`kwAliasDeclResolves250v` and `pkgArrTdBindCopies250_qual arrQualDeclFullPath250v`.

## Reproduction of the implementer's numbers

* **Patch**: md5 cf37cae430b946773e1635f0eb61e735. It applies clean on a fresh de569463, apart from whitespace
  warnings in the evidence text. The law binary rebuilt to 44ecd8c1..., the implementer's md5.
* **Gate sweeps** (`evidence/sweep_P.txt`, `sweep_L.txt`, `sweep_F.txt`, tests/sweep.sh --jobs 3):
  * pristine and law both read probe 3539 EQUAL + 548 STRICT_NOTEQUAL with 0/0/0;
  * surelog: default 470 + 10, testflags 466 + 8;
  * uhdm2rtlil: 803 / 1 / 67 in both modes;
  * downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT.

  The law's surelog stage reads 0 regressions, 0 conversions and 2 changes:
  `CHANGE BlackBePipeInt default STRICT_NOTEQUAL differ:depth(1) -> differ:file(721)` and
  `CHANGE BlackBePipeInt testflags STRICT_NOTEQUAL differ:fullname(3) -> differ:file(721)`.

  Every law csv equals the pristine csv row for row, apart from those two rows and the LowMemLib log-path text.
  The fix sweep reads the same and rc 0, with the law index current. Its csvs equal the law's row for row, apart
  from the LowMemLib path. The pristine sweep's rc 1 is the law index alone: tests/LAWS.md at de569463 lacks the
  commit hash of its own landing (1606 vs 1611 laws with a commit), which every base shows.
* **Rows**: the fix sweep's rows are
  `BlackBePipeInt,default,STRICT_NOTEQUAL,differ:file(721),,differ:file(721)` and
  `BlackBePipeInt,testflags,STRICT_NOTEQUAL,differ:file(721),,differ:file(721)`. uhdm-cmp reads 0 lines on both
  modes on the law and fix databases. The heads (build/uhdm-strictcmp):
  * pristine default `#38807 depth`: golden `6 parameter dev_addr_width_gp bp_common_pkg::dev_addr_width_gp
    1793:12-29 UINT:20`, ours `2 parameter dev_id_width_gp`.
  * pristine testflags `#38803 fullname`: golden `work@bp_be_pipe_int.dev_addr_width_gp`, ours
    `bp_common_pkg::dev_addr_width_gp`.
  * fix (= law) default `#190646 file`, testflags `#190553 file`: golden `constant dut.sv 2537:40-89 UINT:1048576`,
    ours the same constant with no location. This is the implementer's residue 1, ParamEmit `importedFold`.
    721 objects differ.
* **Grid** (`evidence/grid_repro.txt`, the implementer's drivers/grid.sh with these binaries): 1430 lines, every
  rc 0. Every field equals the implementer's evidence/grid.txt except the md5, whose database holds the worktree
  path. All 130 case-views show the same switch pattern. R11U250_OFF gives pristine bytes on 130 of 130. 50 enter
  STRICT_EQUAL and none leaves (`evidence/gridsum_repro.txt`). The fix binary on the same 130 case-views
  (`evidence/grid_impl_fix.txt`): fix = law on 130, fix + R11V250_OFF = law on 130, fix + R11U250_OFF = pristine on
  130.
* **Byte movers** (`evidence/byteverify.txt`):
  * law vs pristine: corpus 2 of 2560 (both BlackBePipeInt), PATH_SETS_IDENTICAL; probe 0 of 4087 (the pristine
    probe stage rerun from the law worktree, /tmp/v11u250_wdQ, because probe databases hold the worktree path; the
    cross-worktree comparison reads 4087 of 4087, all path); downstream slang lanes 0 of 805.
  * fix vs law: 0 of 2560, 0 of 4087, 0 of 805.
  * SELFCHECK reads 2559 of 2560 on every comparison. The self-check compares every database with one fixed
    database, which equals itself, so 2559 is the reading that shows the comparator sees a difference everywhere
    else. It is not a mover line.
* **Prediction**. The implementer's prediction is the two BlackBePipeInt databases, and it holds. This pass's
  prediction for the fix binary (`evidence/prediction.txt`) was frozen before the fix sweep. It came from the
  drivers/tracesweep.sh firing census over both corpora in both modes (794 tests per mode, fenced names excluded by
  the harness filter) and the probe. It names exactly the implementer's six (database, law) firings, and no
  R11V250 fix fires on any gate database. So it predicted 0 movers against the law, and 0 were measured. Positive
  control on the same binary:
  * A/a01 fired pcwOtherSymKeeps250v twice;
  * D/d01 fired kwAliasDeclResolves250v four times;
  * C/c08 fired arrQualDeclFullPath250v once.
* **Away census** (`evidence/away_sweeps.txt`, drivers/awayrows.py, chain-keyed, variant comparator md5
  886f0302..., equal to the implementer's):
  * pristine -> law: BlackBePipeInt default away=0 toward=13888, testflags away=0 toward=13903;
  * law -> fix: 0 databases differ;
  * swapped run: 13888 / 13903 away, the positive control.
* **Canaries** (`evidence/canaries.txt`):
  * canaries.sh: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0 on all three sweeps;
  * ctcan2 EXPECT_UNKNOWN=1: pristine PASS ok=58; law and fix FAIL ok=56 changed=2, the two BlackBePipeInt rows and
    nothing else;
  * ctcan2 EXPECT_UNKNOWN=6 (uhdm2rtlil): PASS on all three.
* **Determinism** (`evidence/determinism.txt`, drivers/det.sh on the fix binary, three concurrent harness runs):
  one hash per row-mode on 13 of 13 row-modes of Earlgrey_0_1, the five UVM rows and BlackBePipeInt. Scoreboard
  testflags has no database, as at the base. Each hash equals the fix sweep's and the implementer's law hashes.
  Twelve concurrent draws of P/p02, p11 and p20, the cases that take § pkgArrTdBindCopies250's
  pointer-ordered `bareOf` branch, read one hash per case-view.
* **Byte controls** (`evidence/controls.txt`, `controls_summary.txt`, drivers/controls3.sh): the implementer's 32
  repro dirs plus nine more (r11u240, v11u240, r11u238, v11u238, r11u236, v11u236, v11u242, r11u232, v11u232): 41
  dirs, 5018 case-views on three binaries.
  * Law: 82 move, 32 enter STRICT_EQUAL, none leaves. This includes all 60 of the implementer's movers.
  * Exit codes are identical on all three binaries: 22 exit 4, 6 exit 3 and 1 exit 139 per binary.
  * Fix: 0 move against the law.
  * The 22 new movers sit in the added dirs: r11u236 BP bp01-bp04, v11u236 E e01, e02, e06 (entering
    STRICT_EQUAL), v11u238 B b03, D d01, d03 and v11u242 Y y04.
  * Away census (`evidence/away_controls.txt`, order-blind): bp02 and bp03 go from 8 / 9 objects differing to 3 / 4
    on the same `line` field. Every stage-1 mover that loses lines loses only generic attribute lines (vpiParent,
    vpiSigned, an unparented UINT bound printed in a different context). The order-blind distance rises on three
    stage-1 case-views, each with lost=0: v11u238 D/d01_tdqueue_el 478 -> 492, d03_tdq_el 280 -> 296, and v11u242
    Y/y04 165 -> 166. The surplus is the new listing's `p::p::<td>` references; golden prints such a reference
    once there, beside its per-parameter copies. Residue 3.
* **Downstream on the implementer's 65 cases** (`evidence/ds_impl_*.txt`):
  * Law: 49 IDENTICAL / 12 EQUIVALENT / 0 STATUS_DIFF / 4 DIVERGENT, as reported.
  * Pristine: 38 / 20 / 2 / 5, where the implementer reported 38 / 19 / 3 / 5. P/p11 reads EQUIVALENT on four
    pristine draws here; its STATUS_DIFF there was a draw.
  * Fix, first draw: 47 / 12 / 2 / 4. P/p11's slang lane and P/p18's Surelog lane read Yosys CRASH at a moment
    the machine showed 1 GB available. The fix bytes equal the law's on both. Reruns read IDENTICAL on both, three
    draws each, so these are environment. On the third draw of P/p18, both lanes read CRASH, Surelog's
    reference lane included (`evidence/ds_reruns.txt`).

## Fresh cases (cases/, each first line names its law; `evidence/vgrid.txt`, `vgridsum.txt`, 480 lines, every rc 0)

The cases cover 30 cases in both views on pristine, law, fix, fix + R11V250_OFF, fix + R11U250_OFF and fix + each
fix switch:

* fix + R11U250_OFF = pristine on 60 of 60;
* fix + R11V250_OFF = law on 60 of 60;
* each fix switch moves only its own cases;
* law: 8 case-views enter STRICT_EQUAL and none leaves;
* fix: 10 enter STRICT_EQUAL and none leaves.

The away census for each case-view is in `evidence/away_cases.txt`. The downstream verdicts
(`evidence/ds_cases_*.txt`, the 25 single-file cases) go from pristine 13 IDENTICAL / 3 EQUIVALENT / 6 STATUS_DIFF /
3 DIVERGENT to law 20 / 2 / 0 / 3 and fix 20 / 2 / 0 / 3. No case leaves IDENTICAL.

| case | law | result (pristine -> law -> fix, both views) |
|---|---|---|
| A a01_modlocal_same_name, a03_two_importers_override | § pcwOtherSymKeeps250v | **the break**. Stage 1 on all binaries, on another face. The law loses golden's `ref_obj work@sub.W.W` -> `work@top.u.W` (9 golden lines lost; elaborated cmp 28 -> 163 and 64 -> 163). The fix restores it (law -> fix lost 0, dist 5 -> 3 and 12 -> 9; vs pristine lost 1 generic `vpiParent`). |
| A a02_modlocal_shadow, a04_iface_gen | § pcwRefLastWriter250 | fix = law. a02 (an importing module's own `localparam int W` used as a width): golden writes NO vpiExpr on the module's own typespec. Pristine writes one bound to the import copy, law and fix the shared package reference: both wrong, residue 1. a04 (an interface body and a generate scope): elaborated cmp 66 -> 26. |
| B b01-b07 | § patFlatTernPickedLeafSpan250 | Stage 1 on all binaries with the same cmp count; every case-view lost=0 and gained 1-17. Shapes: an overridden struct parameter read by member, a ?: condition overridden per instance, member-of-member chains with `default:` and a string compare, the constant slots (dimension bound, part-select bound, indexed width, replication count), a generate block and a child at depth 2, unary / enum / cast origins, conditions that are a constant function call, `$bits`, an x literal, a localparam, a nested ?: and `===`. The stage-1 head is pre-existing: golden keeps the origin literal's text (`4'd4`) where ours writes `4`, and the child-instance listing (residue 2 of the implementer). |
| C c01_rom_localparam | § pkgArrTdBindCopies250 | stage 1 105 -> 62; downstream IDENTICAL on all three. A synthesizable ROM: a localparam of the array typedef with a pattern, an always_ff write, an indexed read. |
| C c02_ranged_kinds | § pkgArrTdBindCopies250 | stage 1 417 -> STRICT_EQUAL. `[1]`, reversed `[2:0]`, `integer`, `int unsigned`, `time` elements, multiple declarators, an initializer. |
| C c03_contexts | § pkgArrTdBindCopies250 | stage 1 173 -> 122. An interface body, a generate-for block, a named begin, a function local, a qualified declaration, a `wire` array. |
| C c04_two_pkgs_same_name | § pkgArrTdListing250 | stage 1 105 -> STRICT_EQUAL. Two packages with a same-named array typedef, imported and qualified. |
| C c05_dyn_assoc_class | § pkgArrTdListing250 | stage 1 527 -> 150. Queue, dynamic and associative typedefs in a class specialization bound (`$size`), this. paths, an extern method and a pure virtual prototype. |
| C c06_port_and_implicit | § pkgArrTdBindCopies250 | stage 1 105 -> 52. An unpacked-array port of the typedef, an implicit net, depth 2. |
| C c07_wildcard_idx | § pkgArrTdListing250 | stage 1 on all; cmp 399 -> 650, but order-blind dist 75 -> 50 with lost=0. `[byte]`, `[bit [3:0]]`, `[*]`, `[16]`, `[7:4]`. |
| C c08_qual_key_same_basename | § arrQualDeclFullPath250v | **law defect**: 105 -> 17 -> STRICT_EQUAL. |
| C c09_calls_protos | § pkgArrTdBindCopies250 | stage 1 592 -> 30. Named, positional and empty-slot calls, an extern task, a pure virtual prototype above the caller, this. paths. |
| C c10_export_relist, c11_pkg_lp_and_struct | § pkgArrTdImportClone250, § pkgArrTdListing250 | stage 1 173 -> 124 (dist 72 -> 28); 64 -> 64 (dist 79 -> 71). A re-exporting package, a package localparam of the typedef, a struct-element array typedef beside it. Lost lines only generic. |
| D d01_modlocal_same_alias | § kwAliasDeclResolves250v | **law defect**: stage 1 122 -> STRICT_NOTEQUAL name, in both law and fix. The law bound work@top.u.x to `p::al_t`, the fix leaves it unnamed (pristine's), and the head stays that record. The fix also leaves top.y unnamed, where the law had golden's `p::al_t`, because `al_t` is declared twice in the design (residue 2). |
| D d02_alias_ports_struct | § pkgAliasOfKwBind250 | stage 1 526 -> STRICT_NOTEQUAL fullname. Ports, a struct member, a package function return and formal, qualified. |
| D d03_gen_two_level, d04_same_basename | § pkgAliasOfKwBind250, § kwAliasDeclResolves250v | d03 stage 1 (dist 64 -> 28, lost 0); d04 **law defect** fixed: dist 51 -> 16 -> 15, a.v back on `p::al_t`. |
| D d05_alias_param_func | § pkgAliasOfKwTd250 | stage 1 44 -> 44, dist 121 -> 75. unsigned, integer, shortreal and realtime targets, a module parameter and a package localparam of an alias. |
| E e01_deep_two_inst, e02_unit_typedef_slots | § modParamKwTdCopy250 | stage 1 40 -> STRICT_EQUAL. Depth 3 and 2 with an override; $unit typedefs in every constant slot and a for-generate bound. |
| E e03_iface_prog_class | § modParamKwTdCopy250 | stage 1 44 -> 16. An interface and a program overridden at their instances, a generate-local typed localparam (the implementer's residue 3b). |

## Residues, ranked (all wrong on pristine too)

1. **A module's own localparam that shadows an imported paren-cast width parameter** (A/a02): golden writes no
   vpiExpr on the module's own declaration typespec. Pristine binds one to the module's import copy, law and fix
   to the shared package reference. ParamEmit `stampCastSizeParamTs` / `stampParenCastWidthTs`.
2. **The conservative uniqueness rule of § kwAliasDeclResolves250v**: when a bare alias name is declared twice
   anywhere in the design, the elaborated real_var takes pristine's unnamed typespec, as in D/d01's top.y. A
   scope-aware lookup (the module's own typedefs, then its imports) would restore the law's right binding there.
3. **Package parameters typed by a package array typedef** (v11u242 Y/y04, stage 1 on every binary): golden binds a
   per-parameter copy named bare (`array_typespec (arr_t)`, references `hp::A::arr_t`). The new listing adds a second
   `hp::hp::<td>` reference golden prints once. The same surplus shows on v11u238 D/d01_tdqueue_el and d03_tdq_el.
4. **The struct-pattern fold's origin text**: golden's member-read origin constant keeps its literal text (`4'd4`,
   `8'd10`) where ours writes the decimal (`4`). Stage 1 on B/b01-b07 on every binary; the law moves only the
   location.
5. The implementer's residues 1-7 stand as written: the BlackBePipeInt `importedFold` location, the flat op's
   reference full name, binders outside nets and variables, alias function locals and realtime, the xor fold
   (ModuleEmit § caNonTernFoldEnc27), Earlgrey decode/E/e01, and items (5)-(7).

## Misstatements in the implementer's README

* The header says R11U250_OFF restores pristine bytes on "118 of 118 grid case-views". The grid has 130
  case-views, and both its measurements section and this rerun read 130 of 130.
* The pristine downstream reading of P/p11, STATUS_DIFF, is a draw. It reads EQUIVALENT on four draws here.
* The implementer's gridsum labels the decode cases `decode/...`. Its case.sh, as delivered, labels them
  `tp/r11u250repro/decode/...`. This is cosmetic.

## Process notes

* No fenced test was dispatched, read or opened outside the gate sweeps:
  * every driver reads $FENCED fail-closed;
  * the control, audit, byteverify and dbmovers path lists were built and filtered by $FENCED before any file
    was opened;
  * the firing census excluded the fenced names through the harness filter;
  * the eight target row names were checked against $FENCED before any head was read.
* Every tool variable was tested with `[ -x ]` before use. No database was executed, and no file was written
  outside /tmp/wt_v11u250, /tmp/wt_v11u250pris and /tmp/v11u250_*.
* Three items about this pass's own conduct:
  * The pristine worktree's tests/LAWS.md was regenerated once to see why the index read stale. That happened
    after its sweep, and it was restored with git checkout.
  * One `ps -eo pid,rss,comm` listing read process names and memory across users, with no command lines, during
    a memory squeeze.
  * A brace slip in the first fix build failed to compile and was corrected before any binary was frozen.
* The fix binary was rebuilt twice before freezing, to replace the first form of § pcwOtherSymKeeps250v and to
  add the uniqueness trace. Only the final binary (f2ccca75...) is measured here.

## Drivers

All drivers read $FENCED fail-closed and resolve their paths from the repo.

* `env.sh`, `case.sh`, `awaydump.py`, `gridsum.py` and `dscases.py`: copied from r11u250repro, labels changed.
* `vgrid.sh` and `controls3.sh`: three binaries and the fix switches.
* `ctlsum.py`: the control summary.
* `tracesweep.sh`, `bvmirror.sh`, `dbmovers.sh`, `det.sh`, `awayrows.py`, `cc_x.sh` and `strictcmp_x.cpp`: copied
  from r11u250repro.
