# v11u215 — adversarial verification of r11u215 (the expression/parameter ground: § pkgTdAliasLastWriter215, § pkgImportEnumCloneLastWriter215, § impPatCopyFirstListingUnparented215 + § impPatMemberReadKeepsParent215v, § incDecOperandKeepsLvalueForm215, § opIdxRecvElemFollowsPath215 + § opIdxRecvPlainElab215, § caseItemWildConcatOnly215, § landingSwitchReach215): CONFIRMED with one refinement, § enumCloneValueItemKeepsBare215v

**Base.** `a727b8c7` (matrix-1.87, pass 210). Worktrees `/tmp/wt_v11u215pris` (pristine) and `/tmp/wt_v11u215`
(the implementer's `/tmp/r11u215.patch`, md5 `6cfb7f8771a8ffe95adbe824abc6176c`, applied clean), system-deps config,
`-j 2`. Scratch `/tmp/v11u215_*`. Nothing under `results/`, `tests/` (but the regenerated `tests/LAWS.md`) or
`third_party/` is edited. A probe case is called a case.

**The fence.** `drivers/env.sh` reads the four names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`
in the main repository (resolved through git's common dir) and fails closed; `case.sh`, `grid.sh`, `wide.sh`,
`judgemv.sh`, `dscase.py`, `draw.sh`, `det.sh`, `awayrows.py`, `uvmdist.sh`, `bvmirror.sh` refuse a fenced name;
`census.sh` runs the corpora with a `--filter` built from the fence; `bvmirror.sh` leaves the 8 fenced row-mode
databases out of every byte comparison (`fenced_skipped=8`); the wide byte-control list (13075 case dirs) holds 0
fenced paths. The gate sweeps dispatched every row; their csv verdicts are the only fenced facts used (all unchanged).
No fenced source, database or head was read, run or decoded.

## 0. Verdict

**CONFIRMED.** Every headline number of the implementer's report reproduces bit for bit with binaries I built myself;
50 fresh cases in both views (100 case-views) find **no case-view leaving EQUAL, no strict cell or downstream verdict
moving away from golden, no uhdm-cmp change, no crash-parity change**. One break on legal SV was found below the strict
walk (a raw full name moved away from golden where pristine was right, in shapes stage 1 on both binaries): fixed behind
its own switch (§ enumCloneValueItemKeepsBare215v, `R11V215_ENUMVALITEM_OFF`), full gates re-run. Two findings the
implementer's report states otherwise: the SeqDriver storage coin is **not** cured in `law26` (section 5), and two of
the pass's pieces had already landed on the branch before delivery (section 6). The verified patch is
`/tmp/r11u215.verified.patch`.

| row-mode | base `a727b8c7` | law (`law.bin` = implementer's `law26`) | fix (`fix.bin`) |
|---|---|---|---|
| **ibex_tracer d / t (uhdm2rtlil)** | `differ:fullname(13)` | **`CMP_EQUAL`**: `ibex_tracer,default,CMP_EQUAL,,,equal` / `ibex_tracer,testflags,CMP_EQUAL,,,equal` | the same |
| SeqDriver d / t | `fullname(63)`, first record #10090 / #10102 (`uvm_pkg::uvm_event_pool` alias ref) | `endline(61)`, #11289 / #11301 (`phase_state_change` endline, the macro-argument span) | the same |
| MiniAmiq d / t | `file(77)` #899 | `file(75)` #899 | the same |
| SimpleUVM d / t | `fullname(241)` #458 / #470 | `fullname(190)` #458 / #470 | the same |
| Scoreboard d | `fullname(193)` #466 | `fullname(136)` #466 | the same |
| BuildUVMPkg d / t | `endcol(57)` #22884 | `endcol(33)` #22884 | the same |
| BlackBePipeInt d / t | `type(1)` #15272 / `depth(1)` #66 | unchanged, 21 records toward golden | the same |
| **12 probe cases** | STRICT_NOTEQUAL | **EQUAL** (the implementer's twelve, by name) | the same |

## 1. Binaries (frozen `chmod 555` in `/tmp/v11u215_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `11b349f41c8453bbb85b792816e5e5a1` | `/tmp/wt_v11u215pris` at `a727b8c7`: = the brief's pristine md5 |
| `law.bin` | `6a021c3c045bbe47c20a827e9bbf41c9` | `a727b8c7` + `/tmp/r11u215.patch`: **= the implementer's `law26` md5** |
| `fix.bin` | `6dd6c0325a9ee3843d702c1a81ec9f2c` | + § enumCloneValueItemKeepsBare215v (this pass); `/tmp/r11u215.verified.patch` applied clean on a fresh `a727b8c7` tree rebuilds this md5 exactly, and `law_index.py --check` reads current there |
| `head.bin` | `00cd5d712fb76282ba92c898efb8812c` | the main tree's build at `c4f26079` (= the pass-216 integration's recorded md5) |
| `head215.bin` | `163d48993c33f324469ec0f2751529e5` | `c4f26079` + r11u215 (3-way; StmtEmit keeps `c4f26079`'s § caseItemWildConcatOnly217v) |
| `h214.bin` | `ebbfa9bfb8d4d5f1b74a3f5119b596cb` | `c4f26079` + `tools/probe/r11u214dec/law_typeemit.patch` (3-way, clean) |
| `h214_215.bin` | `9941155d8642f0221a3f70a742cb3162` | `c4f26079` + r11u214's law patch + r11u215 |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

`cmds.txt` audit ([evidence/sweeps/cmds_audit.txt](evidence/sweeps/cmds_audit.txt),
[evidence/composition/cmds_audit_and_md5.txt](evidence/composition/cmds_audit_and_md5.txt)): every sweep 3273 of 3273
`slang:` lines name its own frozen binary. Every case run records its exit code (`rc=` in the grid tsvs).

## 2. The gates, reproduced (`tests/sweep.sh --jobs 3`, all four stages, against the committed baselines at `a727b8c7`)

| gate | pristine `/tmp/v11u215_swP` | law `/tmp/v11u215_swL` | fix `/tmp/v11u215_swF` |
|---|---|---|---|
| probe | EQUAL 3406 / 681, `0/0/0` | **3418 / 669, `regressions=0 conversions=12 changes=1`** (`g202_a_kinds fullname(6) -> fullname(4)`) | the same, probe csv byte-identical to law's |
| surelog | `0/0/0` (466 + 14 / 463 + 11) | **`regressions=0 conversions=0 changes=9`** (the nine above) | the same, csv identical to law's but the LowMem detail text |
| uhdm2rtlil | `0/0/0` (798 + 5 each mode) | **`regressions=0 conversions=2 changes=0`** (799 + 4 each mode) | the same |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, `downstream.csv` **byte-identical** to pristine's | the same, byte-identical |
| byteverify (`SELFCHECK=1`, mirrors `fenced_skipped=8`) | | **13 / 2560 movers = the 13 predicted by name**; 13 / 4087 probe databases = the 13 predicted; SELFCHECK 2559 / 2560 | **fix vs law: 1 / 2560** (Scoreboard default, the known svunit storage coin: uhdm-dump identical unsorted), 0 / 4087 probe, 0 / 805 downstream lanes = the frozen prediction of 0 |

Every sweep exits 1 for one reason printed first, `law index STALE`: the sweeps run from the pristine worktree, whose
committed `tests/LAWS.md` is stale at its own commit by construction (the index lists a landing's own laws as "commits:
none" until the next regeneration: `a727b8c7`'s `caseItemImpWildParamScopeName210` etc.). The patched worktree's
`--check` reads `law index current`. **SELFCHECK 2559 / 2560** is byteverify's negative control: every patched database
is compared against the pristine copy of ONE fixed path; that path's own patched database is not a mover, so exactly one
comparison reads equal.

**Canaries** ([evidence/sweeps/canaries.txt](evidence/sweeps/canaries.txt)): surelog `ok=52 changed=0` pristine,
`ok=45 changed=7` law and fix (the seven named CHANGE rows among the canaries); uhdm2rtlil `ok=16` on all three;
`EXPECT_UNKNOWN=1 ctcan2.sh` surelog and `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS on all three.

**The prediction** ([evidence/census/](evidence/census/)): my own firing census (`drivers/census.sh` with
`R11U215_TRACE`, fence filter, law.bin) frozen before the law sweep reads 27 databases — the same 27 keys as the
implementer's frozen file (13 corpus row-modes, 13 probe cases, 1 downstream lane) and the same per-law counts; the law
sweep's movers are exactly those. The fix's prediction (0 movers against law) was frozen before the fix sweep.

**Away census** ([evidence/away/](evidence/away/)), map 12's chain-keyed `awayrows.py` over the two sweeps: 26 databases,
**0 records away** (chain and flat) on every one; toward BlackBePipeInt 21, BuildUVMPkg 40, MiniAmiq 73, Scoreboard 60,
SeqDriver 102, SimpleUVM 80, ibex_tracer 13 (per mode); the 13 probe movers 0 / 0 (their names sit inside canonicalised
typespec copies). **Positive control**: the reversed run reads exactly those counts as away. A raw `vpiFullName`
multiset census of the corpus movers' uhdm-dumps (golden / pristine / law) reads 0 away on every row
([corpus_raw_fullnames.txt](evidence/away/corpus_raw_fullnames.txt)).

**Order-blind distance** ([evidence/uvmdist.txt](evidence/uvmdist.txt)): MiniAmiq 14802 -> 14656, SeqDriver 10954 ->
10750, SimpleUVM 3834 -> 3674, Scoreboard 2847 -> 2727, BuildUVMPkg 1385 -> 1305 (per mode; ApbSlave, SVSwitch 0):
the implementer's figures exactly.

**Grids of the implementer** (53 case dirs, both views, [evidence/grid/r11u215_*.tsv](evidence/grid/)): 28 / 28
convert, 3 / 4 shrink, 0 worse, `R11U215_OFF` = pristine bytes on 106 of 106 case-views; fix.bin = law bytes on all 106,
`R11U215_OFF` on fix.bin = pristine on all 106. Downstream on the 53 ([evidence/downstream/r11u215_cases.txt](evidence/downstream/r11u215_cases.txt)):
52 IDENTICAL on both binaries, r07 DIVERGENT on both with the slang-lane RTLIL byte-identical.

**Wide byte control** ([evidence/wide/](evidence/wide/), `drivers/wide.sh`: every case dir under `tools/probe/` at the
base, 13075, 0 fenced, both binaries, both views; movers judged by `drivers/judgemv.sh`): parse 47 movers, 91 NODB;
elaborated 52 movers, 95 NODB; **exit codes identical on every dir** (3 / 7 segfaults, 88 rc 3, 112 rc 4 on both
binaries). Parse: 23 convert, 4 change (r11u170verify ev/a03 `fullname(7) -> file(1)`, r11u176repro PQ/q12_alias
`line(15) -> line(5)`, r11u210repro P/p04 `file(3) -> file(2)`, r11v147repro c7_member_typedef_of_enum_ctl
`fullname(2) -> depth(1)`: every one a shrink or an unmasking of a record pristine carried), 20 keep, 0 worse;
elaborated: 24 convert, 6 change (the same four plus r11u191dec M/m01 `fullname(3) -> fullname(2)` and r11u198repro
M/m10_cls_arrrecv `fullname(2) -> fullname(1)`), 22 keep, 0 worse; **chain-keyed away 0 on every mover**. The raw
full-name census reads 1 line away on five movers: r11v84repro/grid/v3_expedge in both views (**the break of section
3**), and r10uvm39repro/t55a, r11u191dec M/m01, r11u198repro M/m10 in the elaborated view — the latter three and my own
OR r01, r03, r04 are one pattern: golden holds a SECOND, unreachable copy of the class method under
`\_weaklyReferenced` whose plain index keeps the scope's name (`work@uc::f::i` at golden dump line 1149, the reached
copy `work@uc::f::fields[i].get::i` at 173), ours lists one shared object; the reached object is right with the law,
no gate or reader sees the tail.

## 3. The break and its refinement: § enumCloneValueItemKeepsBare215v (`R11V215_ENUMVALITEM_OFF`)

**Found by** the wide control's raw full-name census on r11v84repro/grid/v3_expedge (`package ep_ev; import eh1::XE1;`:
an explicit import of an enum VALUE), then decoded with fresh cases TC c04-c06. **Golden:** a package that imports only
an enum value lists a clone of the enum whose base ref keeps the bare name (`p::e_t`): `importPackage` copies the item,
not the typedef, and no DataTypeMap writer re-parents that object. **Law:** § pkgImportEnumCloneLastWriter215 stamped
every listed plain-enum clone with the last writer's name (`p::p::e_t` with no other importer; `r::p::e_t` when a later
package imports `p::*`), moving a golden-agreeing name away where pristine was right. The shapes are stage 1 on both
binaries (the pre-existing `import_typespec` listing face), so no gate and no chain-keyed walk saw it; the downstream
verdicts and RTLIL are unchanged. **Refinement** (ParamEmit.cpp, inside `pkgTdAliasLastWriter215`): the stamp of a
clone candidate needs at least one package LISTING that object which brings the typedef itself by the law's own `reach`
(a wildcard or the typedef's item, directly or through another package); every listing is recorded
(`listers215v`), not only the first. Traced as `enumCloneValueItemKeepsBare215v`.

| case (both views) | pristine | law | fix | fix with `R11V215_ENUMVALITEM_OFF=1` |
|---|---|---|---|---|
| TC/c04_enum_value_item (`import p::B;` only) | raw `p::e_t` (golden) | `p::p::e_t` (1 away) | **pristine bytes** | law bytes |
| TC/c05_enum_value_item_used (and `parameter p::e_t QP = B;`) | golden | 1 away | **pristine bytes** | law bytes |
| r11v84repro/grid/v3_expedge | golden | 1 away | **pristine bytes** | law bytes |
| TC/c06_enum_value_and_wild (value item in q, `p::*` in r) | bare on the shared object | `r::p::e_t` | law bytes (r reaches) | law bytes |
| probe r11u111repro/grid/f5/e08_explicit_import (`p1` imports `p0::*`) | STRICT_NOTEQUAL | **EQUAL** | **EQUAL** (the conversion kept) | EQUAL |

c06 stays a 1-for-1 swap on both binaries: golden holds TWO objects (q's bare, r's `r::p::e_t`), ours one clone listed by
both packages — a structural residue of the clone model (`pkgImportAggCloneLastWriter32`), not written here. The
refinement fires on no corpus row, probe case or downstream lane (fix vs law: 0 movers but the Scoreboard coin).

## 4. The fresh cases (50 dirs, both views; [evidence/grid/fresh_*.tsv](evidence/grid/))

Columns in the tsvs: pristine, law, law under `R11U215_OFF`, fix, fix under `R11U215_OFF` (verdict, md5, rc).
**Totals (fix against pristine): parse 11 convert, 3 change (all shrinks or unmaskings), 36 same verdict, 0 worse;
elaborated 8 convert, 4 change, 38 same, 0 worse.** fix = law bytes on 48 of 50 per view (not c04, c05); `R11U215_OFF`
= pristine bytes on all 100 case-views for both binaries; every rc 0. Chain-keyed away 0 on every mover; raw away only
c06 (the swap) and the weakly-referenced pattern ([fresh_away_*.tsv](evidence/grid/)). Downstream: every case the same
verdict on both binaries, slang-lane RTLIL byte-identical ([evidence/downstream/fresh_cases.txt](evidence/downstream/fresh_cases.txt)).

| group | case (law on its first line) | parse: pris -> fix | elab: pris -> fix | reading |
|---|---|---|---|---|
| TA | t01_unit_import_after_module (§ pkgTdAliasLastWriter215) | EQUAL -> EQUAL (same bytes) | EQUAL -> EQUAL | control: a module ABOVE the file's `$unit` import is a writer in golden (`work@zz.`) |
| TA | t02_two_pkgs_reverse_src | fullname(23) -> **EQUAL** | fullname(23) -> **EQUAL** | source order, not name order, among packages |
| TA | t03_nested_class_in_modclass | fullname(23) -> fullname(23) | 19 -> 19 | **under-reach**: golden `work@m::lc::inner::` (a nested class writes last) |
| TA | t04_iface_local_class | stage 1 | stage 1 | bytes unchanged |
| TA | t05_two_unit_classes | fullname(38) -> 38 | 26 -> 26 | golden `work@zeta::` (class-name order) = the stamp's; the enum half re-written by the sister's drain (residue 1 of r11u215) |
| TA | t06_class_in_importing_pkg | fullname(22) -> **EQUAL** | 22 -> **EQUAL** | a class inside an importing package is no writer |
| TA | t07_explicit_base_only, t09_program_and_module, t10_function_scope_import, t15_home_pkg_last_file, t16_alias_of_alias, t20_no_importer_class_in_pkg_q_explicit | stage 1 | stage 1 | bytes move, raw away 0 |
| TA | t08_alias_of_foreign_enum, t11_ca_lhs_enum, t12_class_alias_used_in_module, t17_pkg_same_file_after_import | EQUAL -> EQUAL | EQUAL -> EQUAL | controls (t11: the continuous-assignment unparent) |
| TA | t13_two_files, t14_unit_class_before_import, t18_two_module_classes, t19_unit_nested_class | same count | same count | golden `work@k2::`, `work@zcls::` (a `$unit` class ABOVE the import writes), `work@m::zc::`, `work@outer::inner::` (**under-reach**: nested class) |
| TC | c01 (§ pkgImportEnumCloneLastWriter215) | EQUAL | EQUAL | control |
| TC | c02, c03, c07 | stage 1 | stage 1 | c02/c03 bytes move toward, c07 no firing |
| TC | c04, c05, c06 (§ enumCloneValueItemKeepsBare215v) | stage 1 | stage 1 | section 3 |
| IP | p01_explicit_then_wild, p03_bits_and_override, p05_nested_inst_gen (§ impPatCopyFirstListingUnparented215) | fullname(2..4) -> **EQUAL** | -> **EQUAL** (p05 EQUAL on both) | explicit item then wildcard; `$bits` and an override; for- and if-generate two levels down |
| IP | p02_bitselect_read | fullname(3) -> type(1) | stage 1 | the two records toward golden, the structural #808 pre-existing (pristine's third record): an unmasking |
| IP | p07_member_read_in_other_module (§ impPatMemberReadKeepsParent215v) | fullname(3) -> fullname(2) | 3 -> 2 | |
| IP | p04, p06, p08 | stage 1 | stage 1 | bytes toward, raw away 0 |
| ID | d01_positions, d02_deep_and_selects, d03_module_struct (§ incDecOperandKeepsLvalueForm215) | col(2..12) -> **EQUAL** | -> **EQUAL** | for step, system-call and nested-call arguments, if condition, two-level paths, a module struct in an `always` block |
| ID | d05_unary_call_indices | EQUAL (no firing) | EQUAL | control: unary and call indices |
| ID | d04_this_and_super, d06_gen_iface | stage 1 (no firing) | stage 1 | `this.`/`super.` and generate/interface controls |
| OR | r02_class_member_index, r03_unit_and_module_class, r04_task_and_foreach (§ opIdxRecvElemFollowsPath215) | fullname(6..12) -> **EQUAL** | r02 -> EQUAL; r03 18 -> 4; r04 8 -> 2 | elab residues: a module-local class (not fired, golden renames), a package FREE function's plain index (golden `p::free_f::fs[i].get::i`, § opIdxRecvPlainElab215 declines by design), a `$unit` class operation index golden writes as `...get::fields::i` |
| OR | r07_call_index_args | fullname(9) -> endcol(3) | the same | the call-in-index span residue (r11u215's residue 6) |
| OR | r01_shapes, r05, r06, r08 | stage 1 | stage 1 | raw away 0 (parse); elaborated r01 the weakly-referenced pattern |
| CW | w01_forms (§ caseItemWildConcatOnly215) | stage 1 | stage 1 | no firing, bytes unchanged |

## 5. Determinism: the SeqDriver storage coin is NOT cured in `law26`

[evidence/determinism/](evidence/determinism/). My first three-concurrent batch on `law.bin` (Earlgrey_0_1, MiniAmiq,
SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg, BlackBePipeInt, both modes) read one hash per row-mode except Scoreboard
default (the known svunit coin) and **SeqDriver testflags `5d55bb5ae431 / 756a5480d8e9 / 756a5480d8e9`** — exactly the
pair the implementer reported for law22-law25 and said law26's syntax scan removed. Direct draws of the SeqDriver command
line (`drivers/draw.sh`): law 41 / 60, 55 / 90, 15 / 30 (sequential), 20 / 60 draws on the minority hash; pristine 60 /
60, 90 / 90, 30 / 30 one hash, then **58 + 2** (`b566ab77af8e`) in a later batch; `law.bin` under `R11U215_OFF` 8 / 60
on the same `b566ab77af8e`; `fix.bin` 18 / 60. **Storage only:** the two law draws' uhdm-dumps are identical with object
ids kept, their symbol tables identical (39031 symbols, `drivers/sym.cpp`), and `drivers/ord.cpp` (objects in storage
order) shows the whole difference: **15 `ref_var` objects, UhdmIds 298130-298144, minted last in another order**
(param_t, response, t, req_item, cbs, m_reg_process, parented at package-clone subroutines). They are the unbound twins of
**§ cloneTfOwnVarListingIsUnbound195 (src/UhdmExporter.cpp, the sister's ground)**, minted while iterating
`pkgCloneBodyLocals9`, a `std::map` keyed by `const UHDM::task_func*` (include/UhdmExporter.h): address order, which
follows the heap layout. The coin is the base's own (pristine draws it rarely); this pass's binary lays the heap out so
that it draws it often. No reader sees it (the judge, the strict walk and the dump are identical); byte controls will
read SeqDriver as a coin row. The fix is one line on the sister's ground (iterate by `UhdmId`), not written here.

## 6. Landed before delivery (integration notes)

* **§ caseItemWildConcatOnly215 duplicates § caseItemWildConcatOnly217v**, landed by r11u217 at `0a682d73`
  (2026-09-28 19:36, before this patch's 20:21): the same gate on `concatBearing114` at the same site. `git apply` of the
  patch on `c4f26079` conflicts in StmtEmit.cpp; the resolution is to drop § caseItemWildConcatOnly215 and keep 217v (the
  only difference: 217v also declines a parameter with no initializer). The C cases then belong to 217v.
* **r11u214dec landed at `83ee16d6` (18:08)**, before delivery; the r11u215 README says it had not. It carries no
  `law_exprstmt.patch`, so item (0) was moot, but its `law_typeemit.patch` implements the same writer rule on the
  module/type ground (§ enumTdLastWriter214, § classTdAliasLastWriter214).
* **The law index read r11u215repro as a verification pass**: its README title said "the r11u210 verifier's F1 gate",
  and `scripts/law_index.py` classifies any title holding "verif" as a verifier, so this directory was attributed to
  r10uvm215repro. The verified patch rewords that one phrase ("the F1 gate of r11u210's second check"); the index then
  reads r11u215repro as the implement pass and this directory as its verifier.
* **Composition, measured** ([evidence/composition/](evidence/composition/), each against the committed baselines at
  `c4f26079`, whose `results/` already carry passes 212, 216 and r11u217):

| state | probe | surelog | uhdm2rtlil | downstream |
|---|---|---|---|---|
| `c4f26079` + r11u215 | 3422 / 665, `0 / 12 / 1` (the same twelve and the same change) | `0 / 0 / 9`: BuildUVMPkg `col(51) -> line(31)`, MiniAmiq `fullname(61) -> endline(59)`, SeqDriver `fullname(61) -> endline(59)`, SimpleUVM `fullname(236) -> fullname(185)`, Scoreboard `fullname(188) -> fullname(137)` | `0 / 2 / 0` (ibex_tracer) | 803 / 66 / 2 / 0, sweep rc 0 |
| `c4f26079` + r11u214 law patch | 3430 / 657, `0 / 20 / 35` | `0 / 0 / 9` (Earlgrey `endcol(45) -> endcol(39)`, SimpleUVM `endline(135)`, Scoreboard `endline(111)`, MiniAmiq and SeqDriver `endline(59)`) | `0 / 0 / 0` | – |
| `c4f26079` + both | 3430 / 657, probe csv **byte-identical** to r11u214's alone | `0 / 0 / 11`: SimpleUVM `endline(115)`, Scoreboard `endline(91)`, BuildUVMPkg `line(31)`, the rest as r11u214's | `0 / 2 / 0` | 803 / 66 / 2 / 0 |

  The two implementations of the writer rule agree wherever both write (r11u215's twelve probe conversions are a subset
  of r11u214's twenty, and adding r11u215 on top moves no probe case); r11u215's other laws add on top of r11u214 on the
  UVM rows. Land the writer rule once (r11u214's replays the sister's drain and covers the class-last enum cells a06/a12
  that r11u215 leaves to the sister); keep r11u215's other laws.

## 7. Switch reach (this pass)

| switch | drops | measured |
|---|---|---|
| `R11V215_ENUMVALITEM_OFF` | § enumCloneValueItemKeepsBare215v only | law bytes on c04, c05 (both views) and v3_expedge; no other case-view moves |
| `R11U215_OFF` | every r11u215 law and refinement, and this one (its law is off) | pristine bytes on 206 case-views (53 + 50 dirs, both views) for law.bin and fix.bin |

The implementer's `R11V198_OFF` reach (§ landingSwitchReach215) holds by construction: the switch is read at exactly one
site, beside `R11V198_VSSYS_OFF` (the other `198v` refinement in the tree, § clsScopedTdLocalCloneIsClassMethodOnly198v,
is r10v198's, not v11u198's).

## 8. Ranked residues

1. The SeqDriver storage coin (section 5): **UhdmExporter § cloneTfOwnVarListingIsUnbound195**, sister ground; iterate
   `pkgCloneBodyLocals9` by the subroutine's `UhdmId`.
2. Integration: drop § caseItemWildConcatOnly215 for § caseItemWildConcatOnly217v; land the writer rule once (section 6).
3. **Nested classes as writers** (§ pkgTdAliasLastWriter215 under-reach: TA t03 `work@m::lc::inner::`, t19
   `work@outer::inner::`): the stamp reads only a definition's direct class members and top-level `$unit` classes;
   golden's last writer is the last nested class. Wrong to wrong on both binaries.
4. The shared import-clone swap (TC c06): golden lists one object per importing package, ours one clone.
5. § opIdxRecvPlainElab215's declines in the elaborated view (a package free function, a module-local class) and the
   `$unit` class operation-index name golden writes through the element (`...get::fields::i`), OR r03 / r04.
6. The weakly-referenced second copy golden keeps of a class method (scope-named plain index; unreachable, no gate).
7. r11u215's own residues stand as its README ranks them (the sister's `enumImportParentDrain180` class-last cells,
   `designImportParamCopy146`'s `UVM_MACRO_NUMFLAGS`, the macro-argument method-call span, the TypeEmit heads, the
   call-in-index span, BlackBePipeInt #66).

## 9. Files

* `drivers/`: `env.sh` (pins, fence, `REPO` from git's common dir, `WT` = the worktree to run), `case.sh` (one case,
  `ELAB=1` elaborated, `args`/`files` roots), `grid.sh` (pris / law / law under `R11U215_OFF` + `EXTRA` specs),
  `wide.sh` + `judgemv.sh` (the wide byte control and its judging), `awaychain.py` (chain-keyed, one triple),
  `fnaway.py` (raw full-name multiset), `dscase.py` (the downstream gate's `one()`), `draw.sh` (SeqDriver draws),
  `sym.cpp`, `ord.cpp` (symbol table and storage order of a database; build with `g++ -std=c++17 -I$HOME/.local/include
  X.cpp -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread`), and copies of r11u215's `census.sh`, `predict.py`,
  `awayrows.py`, `uvmdist.sh`, `det.sh`, `bvmirror.sh`; `sweep.sh` / `sweeph.sh` run `tests/sweep.sh` of `$WT` with a
  frozen binary.
* `cases/`: TA (§ pkgTdAliasLastWriter215), TC (§ pkgImportEnumCloneLastWriter215; c04-c06 § enumCloneValueItemKeepsBare215v),
  IP (§ impPatCopyFirstListingUnparented215; p07, p08 § impPatMemberReadKeepsParent215v), ID
  (§ incDecOperandKeepsLvalueForm215), OR (§ opIdxRecvElemFollowsPath215), CW (§ caseItemWildConcatOnly215).
* `evidence/`: `grid/`, `wide/`, `sweeps/` (summaries, cmds audit, byteverify law-vs-pristine and fix-vs-law, probe
  movers, canaries; the sweep csvs are not committed since they list the fenced rows), `census/`, `away/`,
  `uvmdist.txt`, `determinism/`, `composition/`, `downstream/`.
