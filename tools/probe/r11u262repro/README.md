# r11u262 — expression/parameter ground (pair A, refill after pass 260)

Base d019d9dd9 (pass 260). Pristine binary md5 5f13d6064e32de7d46471274b28444c2 (byte-identical to the main tree's
build), law binary md5 faa368c2b352fc31e2ed137a9e4cc015, both linking slang 12.0.0+545f88b2e. Five laws behind
`src/R262.h`: each reads its own `R11U262_<LAW>_OFF`, `R11U262_OFF` drops all of them (pristine bytes on every grid
case-view), `R11U262_TRACE=<dir>` logs every firing. Production files touched: `src/ExprEmit.cpp`,
`src/ParamEmit.cpp`, `src/R262.h` (new). Nothing in TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit or uhdm_main.

## 1. Verdicts per targeted row (law sweep vs the committed baselines)

| row-mode | before (base) | after | records cleared, law |
|---|---|---|---|
| **BlackBePipeInt d** | `STRICT_NOTEQUAL differ:depth(1)` #331795 | **`CMP_EQUAL`** (CONVERSION) | #331795, § impConcatParamShared262 |
| **BlackBePipeInt t** | `STRICT_NOTEQUAL differ:depth(1)` #331692 | **`CMP_EQUAL`** (CONVERSION) | #331692, § impConcatParamShared262 |
| Earlgrey_0_1 d | `differ:file(19)`, head #395727 | `differ:fullname(5)`, head #600811 | #395727 (§ genEnumVarLocatedConst262); #464077 and #814099 to #814111 (§ genIpsOvrParamOwner262); #726217 / #726221 / #726225, #727777 / #727781 / #727785, #730573 / #730577 (§ shareDefParamTsOwnNotImport262) |
| Earlgrey_0_1 t | `differ:fullname(20)`, head #446024 | `differ:fullname(16)`, head #530951 | #446024 (§ genIpsOvrParamOwner262); #604623 / #604627 / #604631 (§ shareDefParamTsOwnNotImport262) |
| MiniAmiq d/t, SeqDriver d/t | `differ:file(4)` | unchanged (no law fires) | sister ground |

The fresh csv rows (law sweep):

    BlackBePipeInt,default,CMP_EQUAL,,,equal
    BlackBePipeInt,testflags,CMP_EQUAL,,,equal
    Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
    Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(16),,differ:fullname(16)

Every record left on Earlgrey is on the sister ground (section 5). Probe: five CONVERSIONS (r10earl105repro/
g5_int105 `fullname(2)`, r10earl85repro/g4_shadow85 `line(2)`, r10earl85repro/g5_noshadow85 `line(1)`,
r10earl_repro/uf `line(1)`, r11u114repro/grid/f3/c05 `depth(1)` -> EQUAL); r10v64repro/v7_inst64 moves in bytes
with `fullname(16)` unchanged (chain-keyed census: 0 away, 0 toward).

## 2. The laws

1. **§ genEnumVarLocatedConst262** (ExprEmit, the enum-constant bind in a generate-scope continuous-assignment right
   side, beside § genCaEnumBindsSelectOnly22's mint; `R11U262_GENENUMVAR_OFF`). Surelog's
   `UhdmWriter::lateBinding`, run on the elaborated gen_scope, scans that gen scope's own `Variables()` for an
   `enum_var` whose enum typespec holds a constant of the name (after the name, parameter and typespec scans, before
   the `getValue` mint of a fresh unlocated `enum_const`) and binds that typespec's located constant. Where the
   pristine binary minted the fresh clone, the law binds the shared declaration constant when the generate block
   itself declares a variable of an enum holding the constant (first such variable; nets, ancestor generate
   scopes, module variables, arrays and struct members of the enum do not count; a same-named constant of another
   enum abstains). Earlgrey #395727 (`WB_INSTR_OTHER` beside `wb_instr_type_q`), r11u263repro decode/E/e01.
2. **§ genIpsOvrParamOwner262** (ExprEmit, the typed-parameter fold branch of a generate-scope select bound that copies
   the elaborated `param_assign` constant, after § ovrParamBoundOpSelName198; `R11U262_IPSOVROWN_OFF`). An
   indexed part select's base or width folded from a typed parameter in a top-level if/case-generate continuous
   assignment: the branch's two-level prefix strip assumed the select base as prefix and landed on the instantiating
   scope (`work@top`); golden names the owning instance when the select is the whole right side (`work@top.u`) and
   the select's own full name when it is an operand (`work@top.u.gn.a`), the rule § genIpsBoundOwner256 gives the
   imported fold. Earlgrey `rdata_sram[0+:Width]` (#464077 / #446024), r11u256repro G/g23.
3. **§ genLoopDirectBoundPaConst262** (ExprEmit, the loop-window fold `c9` of § genCaTopLoopParamPaCopy105;
   `R11U262_LOOPBOUNDPA_OFF`). A parameter that IS a select's bound (part-select bound, indexed base or width; not
   nested in a bound operation, not a bit-select index) in a top-level for-generate continuous assignment is
   golden's own elaborated constant: parented at the instance's `param_assign`, its reference named by the
   instance (`work@top.u`), where the branch parented it at the select and named it by the generate scope
   (`work@top.u.gf[0]`). Typed, untyped and localparam alike, overridden or not, top module or child. Fires on no
   corpus row (probe g5_int105 converts; r11u256 G/g12, r11u254 G/g03 / g05, r11u198 N/n24 move toward golden).
4. **§ impConcatParamShared262** (ParamEmit, where the param_assign Rhs is set, beside § elabReExportPaLhsShare;
   `R11U262_IMPCONCATSHARE_OFF`). The elaborated listing's second materialized import copy of a parameter whose
   value is an unreduced concatenation (`parameter s_t [1:0] ALL = {E, D}` re-listed by a package that imports the
   first) holds the first copy's Rhs object: the same name-keyed per-instance lookup that shares the Lhs answers
   the Rhs. Golden's walk lists that operation once. BlackBePipeInt `all_cfgs_gp` (#331795 / #331692) — pass 252's
   "golden writes no Rhs" was the comparator's object memo; the decode (records 22763 ... 331795 in both walks:
   eight listings, golden's eighth not re-expanded) is in section 4.
5. **§ shareDefParamTsOwnNotImport262** (ParamEmit `drainShareDefParamTs` and the park in its push lambda;
   `R11U262_SHAREDEFOWN_OFF`). The elaborated `param_assign` Rhs reference of a module's own parameter is bound by
   name to the definition's `Parameters()`; a wildcard-imported package declaring the same name lists its
   materialized copy first, so the reference took the PACKAGE parameter's typespec. Golden reads the module's own
   declaration when the parameter is a body parameter or a port parameter this instance overrides, and no
   instantiated if/case-generate block of the body reads the name; a port parameter left at its default (header
   `parameter` or `localparam`) and a name read inside an if/case generate block keep the package's typespec, the
   first-by-name answer. Earlgrey flash_erase_ctrl `AddrW`, flash_mp `MpRegions`, rv_timer `N_HARTS` (default
   #726217 ..., testflags #604623 ...), while flash_mp `localparam int BankW = $clog2(NumBanks)` stays the package's
   (a first draft without that test moved #727793 away: refined before the frozen binary, section 6).

## 3. Measurements

* **Grid** (cases/A 28, B 39, D 28, E 10, decode/C 6 dirs; 111 dirs x 2 views = 222 case-views, 8 configurations,
  1776 lines, every line carrying `rc=`, every exit 0; `evidence/grid.txt`, `gridsum.txt`): 152 case-views moving,
  94 entering STRICT_EQUAL, **none leaving**, no exit code or uhdm-cmp line count changing; `R11U262_OFF` pristine on
  222 of 222; every mover moved by exactly one switch: GENENUMVAR 38 (15 entering), IPSOVROWN 30 (30),
  LOOPBOUNDPA 28 (20), IMPCONCATSHARE 16 (6), SHAREDEFOWN 40 (23).
* **Away census on the grid** (`evidence/gridaway.txt`, record multisets where both sides pass stage 1, dump lines
  otherwise): 0 records lost on every stage-1-passing mover except E/e10 (d/el: 1); dump-line losses only on
  stage-1 case-views. Each explained: A/a16, a22 and B/b31_el lose the `|vpiParent:` / tail-listing lines of the
  unreferenced clone or chain the law no longer creates (b31_el distance 183 -> 9); E/e05 to e08 lose parent lines
  of the shared subtree uhdm-dump no longer re-prints (golden prints the operation the same number of times as the
  law: e01 23 = 23, e07 33 = 33, pristine 26 / 39); E/e10 (an interface importing both packages) loses one
  multiset pairing: the pristine second copy's `ref_typespec work@top.i` paired by accident with golden's record
  #931, which our first copy names `work@ifc` (pre-existing, same first record #891 on both); D/d08 (an
  overridden parameter read whole in a module continuous assignment, value 5 on ours against golden's package value
  17, stage 1 on both) loses the accidental typespec match of that wrong-valued copy.
* **Byte controls** over 24 earlier repro dirs (r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124,
  r11v124, r11u131, r11v131, r11u145, r11u163, r11u169, r11u198, r11u252, r11u254, r11u256, v11u256, r11u258,
  v11u258, r11u260, v11u260, r11u261, r11u263, v11u263; 1836 dirs, 3672 case-views, paths filtered by $FENCED
  before opening; `evidence/controls.txt`, `ctlsum.txt`): 106 moving, 72 entering STRICT_EQUAL, none leaving, no
  exit code or uhdm-cmp line count changing; chain of attribution (`ctlattr.txt`, each mover rerun with each switch
  off): SHAREDEFOWN 88 (r11u260 S, v11u260 VS), LOOPBOUNDPA 8, IPSOVROWN 4 (r11u198 N/n20, r11u256 G/g23),
  GENENUMVAR 2 (r11u263 decode/E/e01), LOOPBOUNDPA + SHAREDEFOWN 4 (s29_for_gen, vs04_for_gen); away census 0 lost
  on all 106 (`ctlaway.txt`).
* **Firing census** (drivers/tracecensus.sh, frozen before the law sweep, `evidence/predict.txt`): 10 databases —
  6 probe cases, BlackBePipeInt d/t, Earlgrey d/t; 0 uhdm2rtlil, 0 downstream. A positive control: the trace fires
  through both harnesses (probe and surelog lines).
* **Law sweep** (`tests/sweep.sh --jobs 3`, all four stages): probe regressions=0 conversions=5 changes=0 (EQUAL
  3571 + STRICT_NOTEQUAL 516); surelog regressions=0 conversions=2 changes=2 (944 CMP_EQUAL + 10 of 954 judge-equal
  row-modes); uhdm2rtlil regressions=0 conversions=0 changes=0 (1606 + 0); downstream EQUIVALENT=2 IDENTICAL=803
  SLANG_REJECT=66, not identical and not excused 0, the csv identical to the pristine sweep's. Both sweeps (pristine
  and law) exit 1 on the law-index check alone: the committed tests/LAWS.md is one landing stale at the base (the
  newest commit is not in it) and this pass's case files predate the regenerated index.
* **byteverify** on fence-filtered hard-link mirrors (drivers/bvmirror.sh; 8 fenced databases skipped unread):
  `MOVERS: 4 / 2560` (BlackBePipeInt d/t, Earlgrey d/t), all predicted; SELFCHECK `2559 / 2560 flagged`: the
  self-check compares every file against one fixed file, and that file against itself is the one unflagged path
  (a self-check artifact, not a mover). Probe 6 of 4087 movers, downstream 0 of 805, all predicted
  (`byteverify_*.txt`). No UVM coin moved.
* **Chain-keyed away census on the sweep movers** (drivers/awayrows.py, `evidence/awaycorpus.txt`): away=0 on all
  10 (Earlgrey d 18 toward, t 17 toward; the probe cases 0/2/2/1/1 toward). BlackBePipeInt reads flat_away=73 with
  chain away 0: it is STRICT_EQUAL, the flat multiset uses raw full names inside typespec copies.
* uhdm-cmp: 0 lines on Earlgrey d/t and BlackBePipeInt d/t.
* Canaries: surelog ok=50 changed=2 (the Earlgrey rows); uhdm2rtlil ok=16 changed=0; ctcan2 uhdm2rtlil PASS;
  ctcan2 surelog FAIL on exactly the two BlackBePipeInt conversions (`STRICT_NOTEQUAL/differ:depth(1) ->
  CMP_EQUAL/equal`), PASS on the pristine sweep.
* Binary-path audit: law sweep 3265 of 3315 cmds.txt name the law binary, pristine sweep 3265 name pristine, 0 other
  binaries, 50 with no slang line, 8 fenced skipped unread.
* Determinism (`evidence/determinism.txt`): three concurrent draws of the law binary, one hash per row-mode on
  Earlgrey_0_1 and the five UVM rows, Earlgrey's equal to the sweep's.
* Downstream on the cases (drivers/dscases.py, 111 dirs, both binaries): 103 IDENTICAL, 7 EQUIVALENT, 1
  STATUS_DIFF on both, no verdict changing.

## 4. Decodes

* **BlackBePipeInt #331795 / #331692.** The strict walk lists `all_cfgs_gp`'s param_assign eight times (two
  packages and the module, definition and elaborated listings, the module holding the copy from bp_common_pkg and
  the re-listing from bp_be_pkg). Golden expands the Rhs operation at seven and not at the eighth (the elaborated
  module's second copy): that object was already on the walk. Reproduced in cases/E/e01 (a struct concatenation
  parameter in `p`, re-listed by `q` which imports `p`, a module importing both): `STRICT_NOTEQUAL depth`; e02
  (one import) and the struct-pattern copies beside it are not shared.
* **Earlgrey #600811 / #600816 and testflags #530951 / #530956** (sister ground, decode only, cases/decode/C): the
  whole-right-side replication fold `{TotalWidth{1'b1}}` in a generate scope is unparented in golden when the target
  is a MODULE-body signal (c02, c03, c06) and parented at the cont_assign when the target is generate-local (c01,
  c04, c05). Ours always parents it: ModuleEmit emitGenScopes, § genCaReplWholeFold78's `c78->VpiParent(ca)`.
* **Earlgrey default #729363** (sister ground): `assign region_cfgs[MpRegions].size.q = {AllPagesW{1'b1}}`, a
  module-body continuous assignment with a select-rooted member target; golden's folded constant is parented (its
  reference reads `work@top_earlgrey.u_flash_ctrl`), ours unparented. ModuleEmit's module-body `tryFoldConst` caller.

## 5. Sister-ground faces (call sites, not written)

* Earlgrey d #600811 / #600816, t #530951 / #530956: ModuleEmit § genCaReplWholeFold78 (above).
* Earlgrey d #729363: ModuleEmit module-body CA fold (above).
* Earlgrey d #816151 / #816152: `output sha_word_t [7:0] digest`, golden's named typedef typespec (ModuleEmit/TypeEmit).
* Earlgrey t #580520 to #594077: struct members under a port actual, `reg2hw.mp_region_cfg[0].en.q`
  (ModuleEmit's port connection or the elaborator).
* Earlgrey t #604991 `depth`: flash_mp `region_cfgs_i`'s struct_typespec listed without its members in golden
  (ModuleEmit variable listing).
* MiniAmiq / SeqDriver `file(4)`: UhdmExporter § cloneAggMemberOwn241 and the ref_obj-only binders.

## 6. Process

* Drafts d1 to d7 were measured on cases and on Earlgrey only. A first frozen law binary (84fb0797, census in
  `evidence/predict_withdrawn_v1.txt`) entered its law sweep; the byte controls then showed v11u260 VS/vs09 and
  vs15 losing one golden record each under SHAREDEFOWN (a body localparam read inside an if-generate). The pass
  stopped its own sweep (its pids' command lines checked for this pass's workdir), deleted the outputs unread,
  added the if/case-generate test (cases/D d24 to d28), refroze, and reran grid, controls, census and sweep from
  scratch. Earlier drafts of SHAREDEFOWN (all own parameters; then typed own declarations) were withdrawn on D/d03,
  d13, d19, d20 and Earlgrey #727793 before any binary was frozen.
* SLIPS: one `grep -r --include=*.sl` over the Surelog third_party/tests tree to locate Earlgrey's `.sl` (it read
  the `.sl` command-line files of every test, the fenced ones included; it printed only Earlgrey's path; no source
  read, nothing fenced run); one waiter used `pgrep -f` with a pattern its own shell matched and was stopped by its
  own task id (no process signalled). Every later path list was built and filtered by $FENCED before opening; the
  BlackBePipeInt directory came from verify_golden.py's discovery with an exact filter.
* After the measurements the first line of B/b13 and b21 to b27 was corrected to name § genLoopDirectBoundPaConst262
  (they had been written under § genIpsOvrParamOwner262's heading); a comment-only edit, no line moved.
* A RelWithDebInfo copy of the d3 source, built in scratch, located the writers with gdb (ParamEmit
  `drainShareDefParamTs`; the c2 and c9 branches in ExprEmit). No fenced test was run under any tool.

## 7. Residues, ranked

1. Earlgrey's remaining records, all sister ground (section 5): d `fullname(5)`, t `fullname(16)`.
2. This ground: B/b11 (an UNTYPED overridden parameter as an if-generate indexed width: ours `work@top.u.gn`, golden
   `work@top.u`, another branch); B/b39_el (a direct for-generate bound inside a generate-scope always_comb: golden the
   instance, ours the scope); B/b24 (`work@m.gf.b.i` index naming in the definition view); A/a12 (the
   package-qualified constant's endcol); A/a18 (macro-born enum constant span from an include, pre-existing on the
   package listing); E/e10 (#931 an interface listing's reference named `work@ifc`); the D stage-1 shapes (a
   shadowed parameter read whole in a module or generate continuous assignment folds the package VALUE in golden,
   d04 to d08, d10, d12, d16, d17, d24, d26, d27), E/e05 to e08 (stage 1 on both).
3. Not attempted: items (2) and (4) to (7) of the brief (pass 260's cast law residues, pass 258's address-ordered
   loops and its open shapes, pass 256 / 254 / 252 / 250 / 248 / 246 / 244 / 242 / 240 / 238 / 236 / 232 residues,
   BuildUVMPkg decode clusters, map 15's ground-A brief, N0008, the value encodings, `$size` with a genvar).

## Cases (each names its law in its first line)

* cases/A a01 to a28 — § genEnumVarLocatedConst262.
* cases/B b01 to b20, b36, b37 — § genIpsOvrParamOwner262; b13, b21 to b35, b38, b39 — § genLoopDirectBoundPaConst262.
* cases/D d01 to d28 — § shareDefParamTsOwnNotImport262.
* cases/E e01 to e10 — § impConcatParamShared262.
* cases/decode/C c01 to c06 — § genCaReplWholeFold78 (decode only, sister ground).

Drivers (drivers/, copied from r11u260repro; paths from this checkout, $FENCED fail-closed): env.sh, case.sh,
grid.sh, gridsum.py, controls.sh, ctlsum.py, tracecensus.sh, awayall.sh, away.py, awaydump.py, awayrows.py,
awaychain.py, bvmirror.sh, binaudit.sh, det.sh, dscases.py, rowhead.sh, cc_x.sh, strictcmp_x.cpp.
