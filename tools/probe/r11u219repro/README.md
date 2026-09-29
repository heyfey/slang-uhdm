# r11u219: pass 219, the module/type ground: the r11u214 decode landed with two refinements, the `$size` fold reach, the spaced indexed-part-select target, the macro-argument method-call spans, and the landing-switch repair

**Base** `c4f26079` (branch matrix-1.87). Production files touched: `src/UhdmExporter.cpp`, `src/ModuleEmit.cpp`,
`src/TypeEmit.cpp`, `src/TaskFuncEmit.cpp` (this ground only; nothing in ExprEmit.cpp, EmitHelpers.h, StmtEmit.cpp or
ParamEmit.cpp). Law names are written `§ name` in the source and `law name` here; a probe case is called a case. The
four slang-fenced tests are never named here: every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed (section 10).

## 0. Verdicts

| target | before (base) | after | law(s) |
|---|---|---|---|
| item (0): r11u214's law patch | not landed | **landed**, rebased over passes 216 and r11u217 (a clean three-way merge; a plain apply fails only at ModuleEmit's switch declarations), measured alone at the base first (section 2) | the eight r11u214 laws, their `R11U214_*` switches kept |
| item (0): the 12 flat-key "lost" records | open (r11u216's verifier) | **attributed and explained**: `R11U214_IMPVARELEM_OFF` (law importVarElemOwnName214); at each of the 12 (MiniAmiq) and 5 (SeqDriver) chain positions the law writes golden's exact record where pristine held a different one; the flat key counts them lost because golden holds the pristine record elsewhere. No refinement: the law is right there (section 2.2) | - |
| item (0): a raw-name away census over 13495 earlier case directories | not run by r11u214 | **found three breaks of law enumTdLastWriter214 on legal SV and refined them** (w11, v7_window: an interface class counted as a `$unit` writer; v3_expedge, t5_expfences, c07: a package listing an enum it never imports counted as a writer) | enumClsWriterUnitScopeOnly219, enumPkgWriterImportsType219 |
| Earlgrey_0_1 d/t | `endcol(45)` | `endcol(39)` | modStructMemberQualSpan214 |
| MiniAmiq d/t | `fullname(61)` | **`file(7)`** | classTdAliasLastWriter214 and the enum writer (item 0), ppIdentEndInRebuiltText219, ppDotNameAfterArgToken219 |
| SeqDriver d/t | `fullname(61)` | **`file(7)`** | item 0, the two pp laws |
| SimpleUVM d/t | `fullname(236)` | **`file(76)`** | item 0, the two pp laws |
| Scoreboard d | `fullname(188)` | **`file(52)`** | item 0, the two pp laws |
| pass 216's residue f14 (`$size` of a 2-D unpacked array) | stage 1, downstream DIVERGENT | **downstream IDENTICAL**; grid S s01 s02 STRICT_EQUAL in both views from stage 1 | ndaSizeFoldReach219 |
| r11u217's under-reach of law defGenTargetIpsDefName205 (the spaced `[2 +: 2]`) | `defname` | **STRICT_EQUAL** (grid I i01, i04, both views) | defGenTargetIpsSelArm219 |
| the macro-argument method-call spans (the UVM rows' head after item 0, map 13's F1, pp166 half) | `endline` head of four UVM rows | cleared on all nine UVM row-modes to the next family (`UVM_FILE`, section 11) | ppIdentEndInRebuiltText219, ppDotNameAfterArgToken219 |
| item (8): the switch-reach repair | R11U202_OFF, R11U212_OFF/R11V212_OFF, R11U216_OFF/R11V216_OFF | **landing switches `R11U219_LANDING202_OFF`, `_212_OFF`, `_216_OFF`** and a reach table measured by bytes (section 8) | landingSwitchReach219 |

**No corpus row-mode converts** (each UVM row still carries ground-A families and the `UVM_FILE` relocation, Earlgrey
its ground-A records). **Probe: 22 cases convert** (20 of r11u214, 2 of ppIdentEndInRebuiltText219), quoted in
section 4.1.

**Gates** (`tests/sweep.sh --jobs 3` with the final binary, against the committed baselines): **probe regressions=0
conversions=22 changes=35 (EQUAL 3432 / STRICT_NOTEQUAL 655); surelog regressions=0 conversions=0 changes=9;
uhdm2rtlil 0 / 0 / 0; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, verdict diff 0
against the baseline and against the pristine sweep.** Byte movers 96 (32 corpus row-modes, 64 probe cases) = the
frozen prediction exactly. Away census 0 records lost chain-keyed in both record forms; the flat key's 34 "lost" are
the item-0 records above, every one paired in place with golden's record (section 6).

## 1. Binaries (frozen `chmod 555` before measurement)

| binary | md5 | what |
|---|---|---|
| `pristine` | `00cd5d712fb76282ba92c898efb8812c` | the worktree at `c4f26079`, system-deps config, `-j 2`: byte-identical to the main tree's `build/slang-uhdm` |
| `law214` | `ebbfa9bfb8d4d5f1b74a3f5119b596cb` | `c4f26079` + tools/probe/r11u214dec/law_typeemit.patch alone (item 0 measured alone) |
| `law_fin` | `0013a4fcfa3a01ee4143f03b2ce0e20c` | all laws before the raw-name refinements (the sweep that exposed them, section 3.6) |
| **`law_r6`** | **`49c50c74269ccbba7f6980c024056c9f`** | **the final binary = `c4f26079` + this pass's src diff** |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's build (not edited) |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's variant comparator (tools/probe/r11u211map/drivers/cc.sh; raw full names), same md5 as r11u214's |

Intermediate drafts (`law_d1` .. `law_d6`, `law_r1` .. `law_r5`) were grid-only; `law_r5` and `law_r6` differ in two
trace calls only and write the same bytes on 190 of 190 case-views checked. Sweeps (15-character workdirs, every
`slang:` line of every `cmds.txt` naming its sweep's binary): pristine `/tmp/r11u219_wP`, item 0 alone
`/tmp/r11u219_wA`, final `/tmp/r11u219_wG`. Every sweep's EXIT=1 is the tests/LAWS.md staleness alone (this directory
and the new law names); every compare stage reads regressions=0.

## 2. Item (0): the r11u214 decode's law patch

### 2.1 Landed alone at the base, then composed

`git apply -3` of tools/probe/r11u214dec/law_typeemit.patch on a fresh `c4f26079`: clean (a plain apply fails only at
ModuleEmit.cpp's switch declarations, where passes 212 and 216 added lines). The composition with r11u217's
§ anonMemberTdUseCopyKeeps217v (UhdmExporter typedefParentModel134) needs no code: enumTdLastWriter214 runs before
typedefParentModel134 and re-parents enum objects at packages, `$unit` classes, interfaces and modules; the 217v
refinement keeps a per-use copy parented at a ref_typespec or parameter, which the enum writer never touches.

**Alone at the base** (`law214`, sweep `/tmp/r11u219_wA`, [evidence/item0/sweep_214_alone_summary.txt](evidence/item0/sweep_214_alone_summary.txt)):
probe 0 regressions / 20 conversions / 35 changes (EQUAL 3430), surelog 0 / 0 / 9 (Earlgrey d/t `endcol(39)`,
MiniAmiq d/t `endline(59)`, SeqDriver d/t `endline(59)`, SimpleUVM d/t `endline(135)`, Scoreboard d `endline(111)`),
uhdm2rtlil 0 / 0 / 0: r11u214's own numbers, MiniAmiq's `endline(59)` being the composition r11u216's verifier
measured. r11u214's grid (118 case-views) at the base: 31 convert, 42 stay EQUAL, 45 stay unequal, none leaves EQUAL,
`R11U214_OFF` gives pristine bytes on all 118 ([evidence/item0/grid_r11u214dec_at_base.tsv](evidence/item0/grid_r11u214dec_at_base.tsv)).

**Fresh cases, 2-4 per law** (cases/Z, both views; `R11U219_OFF` gives pristine bytes on all):

| law | cases | result |
|---|---|---|
| enumTdLastWriter214 | x01 (an interface sorting after the module), x02 (a second package and a module), x03 (a `$unit` class and a module), x04 (the package in an included CRLF header, two modules) | x01, x04 bytes unchanged (already golden); x02 stage 1 in both states, bytes only, 0 records either way; x03 `line` in both (fullname 10 -> 0 records: the names converted, the relocation to the class formal is the formal writer family, section 11) |
| classTdAliasLastWriter214 | y01 (a module importer), y02 (a `$unit` class importer) | **both STRICT_EQUAL in both views** |
| classScopeTdPkgListingParent214 | y03 (two class-scope specializations) | parse view `fullname -> depth` (the unmasking r11u214 reported: pass 112's structural record), 4 raw records toward, 0 lost |
| modStructMemberQualSpan214 | z01 (`cfg::W` bare and `cfg::K*2-1`), z02 (a packed union) | **z01 STRICT_EQUAL in both views**; z02 stage 1 at the base in both, bytes unchanged |
| unitImportCopyOwnTsRef214, unitImportCopyValueFollowsPkg214 | u01 (typed and untyped `$unit`-imported parameters), u02 (untyped arithmetic) | stage 1 at the base in both states (the module's own imported copies, map 13's N0685/N0827, ground A); 14-18 records toward, 0 lost |
| importVarElemOwnName214 | v01 (a dynamic array of a class), v02 (an associative array, two importing classes) | **both STRICT_EQUAL in both views** |
| cloneAliasFormalOwnChain214 | - | no small case reaches it judge-equal (an out-of-block class method in a small package is stage 1 at the base, r11u214 A a02/a03); measured on MiniAmiq and SeqDriver only, as r11u214 did |

### 2.2 The 12 flat-key "lost" records: attributed, and not a loss

r11u216's verifier read, on MiniAmiq default with the r11u214 patch, 12 records lost under the flat key (the record
without its depth): `ref_typespec` with an empty name, the canonical `<in>` full name and no location. Reproduced at
this base ([evidence/item0/away_miniamiq_default_214_alone.txt](evidence/item0/away_miniamiq_default_214_alone.txt):
flat 12 lost / 30 toward, chain-keyed 0 lost / 42 toward) and on SeqDriver d/t (5 each).

* **Attribution by switch**: MiniAmiq default under `law214` with `R11U214_IMPVARELEM_OFF` against `law214`: the same
  12 return ([evidence/item0/flat12_attribution_impvarelem.txt](evidence/item0/flat12_attribution_impvarelem.txt)).
  The law is importVarElemOwnName214's second half: the copy's array typespec is left free (unparented), as golden's.
* **The object**: the index-type reference under the array typespec of each class-inherited copy of uvm_pkg's
  `uvm_random_seed_table uvm_random_seed_table_lookup [string]` (12 svaunit classes on MiniAmiq, 5 adpcm classes on
  SeqDriver). Pristine parented the cloned array typespec at the copy's ref, so the index ref's full name was the
  copy's (the comparator prints a named object inside a typespec copy as `<in>`); golden's index ref has no name.
* **Golden's rule and the law**: at every one of the 12 chain positions golden holds 1 record `ref_typespec` with an
  EMPTY full name and 0 of the `<in>` form; pristine held the `<in>` form (golden 0), the law holds golden's
  ([evidence/item0/flat12_minia_default_contexts.txt](evidence/item0/flat12_minia_default_contexts.txt): 12 chains
  `G=0 OFF=1 ON=0` for `<in>` and 12 `G=1 OFF=0 ON=1` for the empty form). The flat key sees "lost" only because
  golden carries 591 `<in>` records of that shape elsewhere and pristine's 12 were counted against them.
* **Census in both keys** (section 6): chain-keyed 0 lost on every row; flat-keyed 34 lost (MiniAmiq d/t 12 each,
  SeqDriver d/t 5 each), all 34 of the index-ref record, each paired at its own chain with a record gained toward
  golden (the `flat_unpaired` count of drivers/awayall.py reads 0); the reversed positive control reads 3091 chain /
  3057 flat lost. Refining the law "until the flat census reads 0" would put pristine's wrong record back, so the
  law is left as landed and the census reports the paired count.

### 2.3 The refinements found by the raw-name census (the law's breaks on legal SV)

The raw-name away census (map 13's variant comparator, raw full names; the gate's canonical records hide a name
inside a typespec copy) over the byte movers of a wide control of 13495 earlier case directories x 2 views with the
unrefined binary (`law_fin`, [evidence/refine/](evidence/refine/)) found records golden holds, pristine held, and
enumTdLastWriter214 moved away:

* **law enumClsWriterUnitScopeOnly219** (UhdmExporter enumTdLastWriter214, `R11U219_UNITCLSONLY_OFF`): only a class
  declared at compilation-unit scope is a `$unit` class writer. A class declared inside an interface or a module is
  parented at the design in both databases (golden `work@M`) but is no writer: golden r11u216repro TW/w11 reads
  `work@top.p::e_t` on all 13 listings where the law wrote the interface class's `work@M::p::e_t` (13 / 14 raw
  records away in the two views), r10v221repro v7_window likewise (2). The compilation-unit classes are read off
  `classDefnMap` (a class symbol whose parent scope is the compilation unit). Both cases now keep pristine bytes;
  own grid Z/x05 (two interfaces' classes, a module importer: the unrefined law fires, the refined one does not,
  bytes pristine).
* **law enumPkgWriterImportsType219** (`R11U219_PKGWIMPORT_OFF`): a package other than the typedef's home counts as a
  writer only when it imports the home package with a wildcard or imports the typedef by name (read off the
  package's own import declarations and header imports); when a package lists the enum without either, the whole
  object is declined (golden keeps per-importer copies there that our one shared object cannot follow).
  r11v84repro v3_expedge (`import eh1::XE1;`, an enum VALUE: golden keeps `eh1::xe_t` where the unrefined law wrote
  its package writer's name, 2 raw records away), r11u84repro t5_expfences and r11u214dec A/c07 (bytes only) now
  keep pristine bytes; own grid Z/x06 (a function, a value and a type imported by name).

Left as the identity family, not refined: r11u214dec A a04 (elaborated, stage 1), a12, b04, c03, c05 (elaborated,
each converting to STRICT_EQUAL) and own Z/x07: golden lists a per-class copy of the enum parented at the listing
class (`p::c::p::ALIAS_T`, `work@aa_c::p::ALIAS_T`) beside the design-wide object, where ours holds one object in
every listing; the comparator's full-name rule excuses exactly that shape (golden gives the object more than one name
and ours is one of them), and following it would mean minting per-listing copies (GOLDEN_EQUIVALENCE.md, "Typespec
identity is canonicalised").

## 3. The laws of this pass

Every law sits behind its own switch; `R11U219_OFF` drops every one of them AND the r11u214 laws this pass lands
(`r11u214Law` reads it), restoring the base's bytes on all 70 own case-views and every corpus and probe database.
`R11U219_TRACE=1|<dir>` names every firing (`<pid>.219` files, first line `OUT <db path>`).

### 3.1 law ndaSizeFoldReach219 (ModuleEmit rqSizePlan216; `R11U219_SIZE2D_OFF`, `R11U219_SIZEDIM_OFF`)

Pass 216's law ndaSizeQueryFold216 folds a net declaration's whole-initializer `$size` of a net or variable to a
location-less `UINT:<count>` sized to the net, but only for a one-dimensional integral shape. Golden folds every shape
ExprEval reduces (grid S, golden databases): a multi-dimensional operand gives the count of its FIRST dimension,
unpacked dimensions first then packed (`logic [1:0] m [2][3]` -> 2, `logic [3:0][1:0] pv` -> 4), whatever the element
(`us_t su [4]` of an unpacked struct -> 4, `string st [3]` -> 3) (`R11U219_SIZE2D_OFF`); the two-argument form with a
literal dimension counts dimension d in the same order (`$size(m, 3)` -> 2, `$size(pv, 2)` -> 2)
(`R11U219_SIZEDIM_OFF`). A dynamic dimension and a parameter operand stay declined. Grid S (5 cases, 10 case-views):
**s01 (2-D, 3-D and `[0:5][1:0]`) and s02 (a generate-scope net and an interface net) STRICT_EQUAL in both views from
stage 1**; s03, s04, s05 stay stage 1 on pre-existing faces (the `array_var` of an unpacked-struct array; a `string`
array; `$size` of a parameter, golden keeps the call) with the folded records now golden's. Downstream: **f14
(v11u216repro), s01, s02, s05 DIVERGENT -> IDENTICAL; s03, s04 DIVERGENT -> EQUIVALENT.** Fires on no corpus row and
no probe case.

### 3.2 law defGenTargetIpsSelArm219 (TypeEmit emitSyntaxExpr, the symbolic-bound branch; `R11U219_IPSSELARM_OFF`)

r11u217 found law defGenTargetIpsDefName205 never firing on the spaced `[2 +: 2]`: that form (and a parameter or
expression base) reaches the symbolic-bound branch, not the digits-only text branch. compilePartSelectRange names a
definition-view generate assignment TARGET's indexed part select the same way whatever the bound's spelling:
VpiDefName = the member, no stored full name (golden `work@top.gl.gi.o.s.f[2+:2].f`), as the same branch's `[l:r]`
already writes (law defGenPathSel161). Reads law defGenTargetIpsDefName205's switch too. Grid I (4 cases): **i01 (spaced
`+:` and `-:` in an if-in-for) and i04 (an interface member in a case generate) STRICT_EQUAL in both views**; i02
(a parameter base) stage 1 in both (golden folds `1 * 2`, pre-existing), 1 record toward; i03 (a right-side use, a
target outside generate) bytes unchanged. Downstream all IDENTICAL on both binaries. Fires on no corpus row or probe
case.

### 3.3 laws ppIdentEndInRebuiltText219 and ppDotNameAfterArgToken219 (UhdmExporter pp166 Model::find; `R11U219_PPIDENTEND_OFF`, `R11U219_PPDOTNAME_OFF`)

After item 0 the first record of SeqDriver d/t, SimpleUVM d/t, Scoreboard d (and MiniAmiq d/t with pass 216) was the
macro method-call span: `cb.METHOD` in uvm_do_obj_callbacks with METHOD = `phase_state_change(this, state_chg)`
forwarded through uvm_do_callbacks (golden uvm_callback_defines.svh 168:11-168:29, ours 168:11-169:9), then
`CB.get_full_name()` inside uvm_info's message actual (golden uvm_message_defines.svh 116:13-116:26, ours
115:89-1346:16). Reproduced in 50 lines (cases M/m03: two nested multi-line macros, the method call a forwarded
actual). Traced (a temporary debug build, not delivered): pp166's model rebuilt Surelog's output text correctly and
aligned every slang token, but
* the END of the method name (`state_change`, 12 chars) is a location the model holds no token at (the name token was
  aligned, its end offset in the body's expansion buffer is not a recorded token start or end), so the pristine
  arithmetic added the length to the macro body's source offset and ran past the body line into the next line. Law
  ppIdentEndInRebuiltText219: the end of a one-identifier span whose start the model places is the start's place in
  the output text plus the identifier's length, on the start's output line, when the rebuilt text there holds an
  identifier of exactly that length (golden 18:11-18:23 in m03).
* slang places the member name of `CB.get_name()` (CB an actual) one past the actual's token in the ACTUAL's own
  buffer, where the model has no token (the `.` sits in the body's buffer). Law ppDotNameAfterArgToken219: that place
  is the output text right after the `.` following the actual's token, when the text reads `.` then an identifier
  (golden 6:131, ours 5:188 in m03, whose MSG actual holds a newline).

Grid M (10 cases, 20 case-views; brief (i)'s shapes): **m03 (two nested multi-line macros), m08 (a method call on an
actual in a message argument, direct and through a second macro), m09 (m03 in a CRLF file), m10 (the macros in an
included header) STRICT_EQUAL in both views**; m01, m02 (a stringified formal), m04 (pasted names `get_``M`,
`OBJ``_b`), m05 (an inactive `ifdef` branch), m07 (an actual over two lines) EQUAL at the base and unchanged; m06
(nested calls and a method chain) stage 1 in both (the `cb.id().get_id()` hier_path, ExprEmit's), 1 record toward.
Corpus: the four UVM rows' strict cells move `endline(59|135|111)` -> `line(47|123|99)` (ppIdentEnd) -> `file(7|76|52)`
(ppDotName) ([evidence/pp/uvm_rows_per_law.txt](evidence/pp/uvm_rows_per_law.txt)); away census on the four UVM
default rows against item 0 + the size/ips laws: 0 lost, 197-362 toward per row; the method_func_call file facet
order-blind (drivers/uvmdist.sh `mfc_file_away`) 12 on every UVM row-mode before and after. Probe:
r10v116repro/v116_u and r10v133repro/v133_f_macro convert. Rggen d moves bytes (138 firings) with its strict cell
unchanged (`file(3)`, the Surelog rebinding) and 1 raw record toward.

### 3.4 law landingSwitchReach219 (UhdmExporter switch functions; item (8))

Section 8.

### 3.5 The r11u214 laws as landed

Unchanged from tools/probe/r11u214dec/law_typeemit.patch except that `r11u214Law` also reads `R11U219_OFF`, and
enumTdLastWriter214 takes the two refinements' inputs (section 2.3). Law statements: tools/probe/r11u214dec/README.md
section 3 (enumTdLastWriter214 with `R11U214_SEQARBNAME_OFF`, `R11U214_ENUMPKGW_OFF`, `R11U214_ENUMCLSW_OFF`,
`R11U214_ENUMALIASGRP_OFF`, `R11U214_ENUMALIASNAME_OFF`; classTdAliasLastWriter214 `R11U214_CLASSTDW_OFF`;
classScopeTdPkgListingParent214 `R11U214_CLSSCOPETD_OFF`; cloneAliasFormalOwnChain214 `R11U214_CLONENAME_OFF`;
modStructMemberQualSpan214 `R11U214_QUALSPAN_OFF`; unitImportCopyOwnTsRef214 `R11U214_UNITCOPYTS_OFF`;
unitImportCopyValueFollowsPkg214 `R11U214_VALENC_OFF`; importVarElemOwnName214 `R11U214_IMPVARELEM_OFF`;
`R11U214_OFF` all).

### 3.6 Switch reach on the own grid ([evidence/switches_own_summary.txt](evidence/switches_own_summary.txt))

70 case-views: `R11U219_OFF` gives pristine bytes on 70; the law moves 48. Per family: Z (item 0) `R11U214_OFF`
restores all 22 movers; I `R11U219_IPSSELARM_OFF` all 6; S `R11U219_SIZE2D_OFF` + `R11U219_SIZEDIM_OFF` all 10 (each
alone 4 and 2); M the two pp switches all 10 (`R11U219_PPDOTNAME_OFF` alone 4); no family's switch moves another
family's bytes; `R11U219_UNITCLSONLY_OFF` alone moves exactly Z/x05, `R11U219_PKGWIMPORT_OFF` alone Z/x06 (both
views), each giving the unrefined law's bytes.

## 4. The gates (final binary `law_r6`, sweep `/tmp/r11u219_wG`; [evidence/final/](evidence/final/))

1. **Builds**: pristine `00cd5d712fb7` (= the main tree), law `49c50c74269c`.
2. **Probe**: EQUAL 3432 / STRICT_NOTEQUAL 655: **regressions=0 conversions=22 changes=35**.
3. **Corpora**: surelog **regressions=0 conversions=0 changes=9**; uhdm2rtlil **0 / 0 / 0**. The nine changes:

   | row-mode | baseline (= pristine) | law | laws |
   |---|---|---|---|
   | Earlgrey_0_1 default / testflags | `endcol(45)` | `endcol(39)` | modStructMemberQualSpan214 |
   | MiniAmiq default / testflags | `fullname(61)` | `file(7)` | item 0 (#10107 uvm_event_pool: classTdAliasLastWriter214), ppIdentEnd, ppDotName |
   | SeqDriver default / testflags | `fullname(61)` | `file(7)` | item 0 (#10090: classTdAliasLastWriter214), ppIdentEnd, ppDotName |
   | SimpleUVM default / testflags | `fullname(236)` | `file(76)` | item 0 (#458: unitImportCopyOwnTsRef214), ppIdentEnd, ppDotName |
   | Scoreboard default | `fullname(188)` | `file(52)` | item 0 (#466: unitImportCopyOwnTsRef214), ppIdentEnd, ppDotName |

   Every one is judge-equal (STRICT_NOTEQUAL) before and after: uhdm-cmp 0 lines on every touched row (gate 5).
   Fresh rows: `MiniAmiq,default,STRICT_NOTEQUAL,differ:file(7),,differ:file(7)`,
   `SeqDriver,default,STRICT_NOTEQUAL,differ:file(7),,differ:file(7)`,
   `SimpleUVM,default,STRICT_NOTEQUAL,differ:file(76),,differ:file(76)`,
   `Scoreboard,default,STRICT_NOTEQUAL,differ:file(52),,differ:file(52)`,
   `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:endcol(39),,differ:endcol(39)` (testflags alike).
   Every changed cell moves its first field to a later family with its old first records gone, and the away census
   reads 0 records lost on each (section 6).
4. **Downstream**: **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT**, verdicts identical to the
   baseline and to the pristine sweep row for row; the six uhdm2rtlil lanes whose slang database moves (PackageCast,
   TypedefAliasInPackage, TypedefEnum, VarPassedTo2Submodules, ibex_branch_predict, ibex_decoder: law
   enumTdLastWriter214's package writer, r11u214's six) keep byte-identical RTLIL
   ([downstream_lanes.txt](evidence/final/downstream_lanes.txt)).
5. **uhdm-cmp**: every touched row-mode and probe case is judge-equal on both binaries.
6. **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, on hard-link mirrors without the 8 fenced
   row-mode databases, drivers/bvmirror.sh): `PATH_SETS_IDENTICAL (2560 paths)`, **MOVERS 32 / 2560**, SELFCHECK
   2559 / 2560 flagged ([byteverify.txt](evidence/final/byteverify.txt)).
7. **The pass switch on the gates**: a full sweep of the final binary with `R11U219_OFF=1`
   ([sweep_alloff_summary.txt](evidence/final/sweep_alloff_summary.txt)) reads probe EQUAL 3410 / 677 and 0 / 0 / 0
   in all three stages; its byte movers against the pristine sweep are Scoreboard default alone
   ([movers_P_vs_alloff.txt](evidence/final/movers_P_vs_alloff.txt)), 92 uhdm-dump lines unsorted and 0 sorted: the
   svunit listing-order coin. So `R11U219_OFF` restores the base's bytes on every corpus and probe database.
8. **Reproduction**: the patch applied to a fresh `c4f26079` worktree and built there (`-j 2`) gives the final
   binary's md5 `49c50c74269c`.
9. **Canaries** ([canaries.txt](evidence/final/canaries.txt)): surelog ok=45 changed=7 (Earlgrey d/t, SimpleUVM d/t,
   SeqDriver d/t, Scoreboard d: seven of the nine CHANGE lines; MiniAmiq is not a canary); uhdm2rtlil ok=16 changed=0;
   `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS (ok=58), `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS (ok=2).

### 4.1 The 22 probe conversions (fresh rows in [probe_conversions_fresh_rows.csv](evidence/final/probe_conversions_fresh_rows.csv), each `<case>,EQUAL,,equal`)

importVarElemOwnName214 7 (r10sd10repro g1_assoc_class_elem_import, g1_assoc_index_import, g2_dynarray_elem_import,
g3_dynarray_class_elem_import, v1_fixedarray_elem_import, v3_elem_class_of_importing, r10sd6repro v8_unpacked_sel);
classTdAliasLastWriter214 11 (r10uvm202repro g202_e_head, r10uvm206repro g206_b_dedup, r10uvm49repro a3 a4 a5 a6,
r10uvm50repro a1 a7, r10v136repro v136_g_param, r10v202repro v202_6_twotd, r10v206repro v206_d_selfname);
classScopeTdPkgListingParent214 1 (r10uvm112repro a8_single); enumTdLastWriter214 1
(r11u111repro/grid/f5/e08_explicit_import); **ppIdentEndInRebuiltText219 2 (r10v116repro/v116_u,
r10v133repro/v133_f_macro)**. The 35 changes are r11u214's 35 exactly (the final probe csv differs from item 0
alone's only in the two pp conversions): 15 move their first field to a structural `depth` record, 5 to `value` and 1
to `file`, each at an index the pristine database already differed at (drivers/unmask.py,
[probe_changes_unmasking_check.txt](evidence/final/probe_changes_unmasking_check.txt): 35 of 35 with a pristine
record at the same index), the other 14 keep `fullname` with a smaller count.

## 5. Movers, predicted by name before the law sweep

drivers/census.sh ran the final binary with `R11U214_TRACE` and `R11U219_TRACE` over every non-fenced row-mode
(`--filter` built from the fence) and every probe case; drivers/predict.py reduced it to
[evidence/census/prediction.txt](evidence/census/prediction.txt), frozen `chmod 444` with its md5
(`3651a45be0dbabf8797e37b86150d7ba`) and time stamp before the law sweep
([prediction_frozen_at.txt](evidence/census/prediction_frozen_at.txt)): **96 predicted movers = 20 surelog + 12
uhdm2rtlil row-modes + 64 probe cases**. The sweep's byte movers are **exactly that set** (96 / 96, none
unpredicted, none predicted and unmoved: [prediction_vs_movers.txt](evidence/final/prediction_vs_movers.txt),
drivers/movers.sh). Three earlier predictions were frozen and superseded before any law sweep of their binary
([evidence/census/superseded_draft1-3](evidence/census/)): draft 1 because the dot law carried no trace (a trace was
then put on every branch), draft 2 because the refinements of section 2.3 came after its sweep, draft 3 because the
unit-scope trace fired on classes listing nothing the law writes (the trace was tightened to the byte-moving cell;
bytes identical). Per law: ENUMPKGW on Earlgrey d/t (8), BuildUVMPkg d/t, EnumVar, PackedEnumPort, TypedefPack, Rggen
d and the six uhdm2rtlil tests; ENUMCLSW, UNITCOPYTS, VALENC on SimpleUVM d/t and Scoreboard d; CLASSTDW,
IMPVARELEM on the four UVM rows; CLONENAME and ENUMALIASGRP on MiniAmiq and SeqDriver; QUALSPAN on Earlgrey;
ppIdentEndInRebuiltText219 on MiniAmiq d/t, SeqDriver d/t (263), SimpleUVM d/t, Scoreboard d (153), Rggen d (138) and 2
probe cases; ppDotNameAfterArgToken219 on the UVM rows. The size, ips and refinement laws fire on no corpus row or
probe case.

## 6. The away-moved-record census ([evidence/final/](evidence/final/), drivers/awayall.py)

Over the 96 databases that differ between the pristine and the final sweep, each record keyed by its ancestor chain
and flat (depth dropped):

| records | chain lost | chain toward | flat lost | flat toward | flat lost not paired in place |
|---|---|---|---|---|---|
| canonical (the gate's uhdm-strictcmp) | **0** | 3091 | 34 | 3057 | **0** |
| reversed control (final as the "off" side) | 3091 | 0 | 3057 | 34 | 3057 |
| raw full names (strictcmp_x, `RAW=1`) | **0** | 4485 | **0** | 4403 | 0 |
| reversed control | 4485 | 0 | 4403 | 0 | 4403 |

The 34 flat-lost canonical records are section 2.2's (MiniAmiq d/t 12, SeqDriver d/t 5). By row (canonical chain
toward): SimpleUVM d/t 479 each, Scoreboard d 408, SeqDriver d/t 381, MiniAmiq d/t 349, Earlgrey d 60 / t 14; the
probe movers the rest. Order-blind distance (drivers/uvmdist.sh, [uvmdist.txt](evidence/final/uvmdist.txt); pristine
-> item 0 alone -> final): MiniAmiq 6339 -> 6321 -> **6014**, SeqDriver 5071 -> 5062 -> **4700**, SimpleUVM 1983 ->
1876 -> **1624**, Scoreboard 1453 -> 1362 -> **1165**; `mfc_file_away` 12 on every row-mode in all three.

**Wide byte control** (drivers/widebytes.sh, every case directory under tools/probe, 13495 x 2 views = 26990
case-views, [wide_bytes.tsv](evidence/final/wide_bytes.tsv), the movers): 259 move; **256 carry a firing and give pristine bytes
under `R11U219_OFF`**; judged ([wide_movers_judged.tsv](evidence/final/wide_movers_judged.tsv)): 83 convert to
STRICT_EQUAL, 75 stay EQUAL, 98 stay unequal, **none leaves EQUAL**; the away census on all 256 in both record forms
([wide_movers_away.txt](evidence/final/wide_movers_away.txt)): 0 lost canonical; raw-name chain losses only on the
five identity cases of section 2.3 (four of them converting). The other three movers carry no firing: r11u123canon
e03_enum_const_x3/v (law rc 3 in the wide runs, rc 0 and pristine bytes in 12 concurrent reruns of each binary: an
exception under the concurrent sweep's memory load) and r11u129canon b03_member_span/v, q02_pkgparam_in_anon_port/v
(the `R11U219_OFF` run differs from pristine too; the pristine binary alone writes three different hashes for b03 in
three batches: those cases are run-to-run nondeterministic on the pristine binary).

## 7. Downstream

The gate sweep: section 4.4. The face control (drivers/dsfaces.sh: the gate's own `one()` with a fresh golden cache,
both binaries) over the cases of r11u216repro, v11u216repro, r11u212repro, v11u212repro, r11u214dec and this
directory, 342 cases ([downstream_faces.txt](evidence/final/downstream_faces.txt)): **321 IDENTICAL stay IDENTICAL, 0
leave IDENTICAL; 4 DIVERGENT -> IDENTICAL (v11u216 F/f14, S/s01, s02, s05); 2 DIVERGENT -> EQUIVALENT (S/s03, s04)**;
r11u216 NQ/n11 DIVERGENT on both (the variable initializer, section 11), v11u212 G/g12 EQUIVALENT on both, 13
SLANG_REJECT on both.

## 8. Item (8): the switch-reach repair (law landingSwitchReach219; [evidence/reach/](evidence/reach/), drivers/reach.sh)

The new switches drop one landing's WHOLE ground-B state; the old switches keep their meaning.

| switch | the laws it drops | measured (bytes, both views) |
|---|---|---|
| **`R11U219_LANDING202_OFF`** (new) | landing 202: the r11u202 laws, the v11u202 refinements, the ground-B r11u200 laws it carried; NOT pass 206's two laws nested under their gates (§ unitClassTdEndAtInitIfcPrg206 keeps its interface and program writers, § classScopeTdRetBuildsOwner206 its on-demand owner build) | 518 case-views of r11u202repro, v11u202repro, r11u206repro, v11u206repro: moves 336; equal to `R11U202_OFF` on 426, differing exactly on pass 206's UT/TR cells (r11u206 UT, TR; v11u202 UT, TR; v11u206 C, D); with `R11U206_OFF` added to both, equal on 518 of 518; with the two nested 206 laws' own switches added, equal to `R11U202_OFF` on 518 of 518 |
| `R11U202_OFF` (old) | landing 202 plus the two nested pass-206 laws (r11u213's finding) | moves 338 |
| **`R11U219_LANDING212_OFF`** (new) | landing 212: the r11u212 laws and the v11u212 refinement | equal to `R11U212_OFF R11V212_OFF` on 298 of 298 (r11u212repro, v11u212repro); moves 210 |
| **`R11U219_LANDING216_OFF`** (new) | landing 216: the r11u216 laws and the v11u216 refinements | equal to `R11U216_OFF R11V216_OFF` on 200 of 200 (r11u216repro, v11u216repro); moves 182 |
| `R11U206_OFF` (old, exact) | landing 206's six laws | (r11u213) |
| `R11U209_OFF` (old, exact for ground B) | landing 209: pass 209's laws, the v11u209 refinements and the three ground-B r11u205 laws | 504 case-views of r11u209repro, v11u209repro, r11u205dec, r11u210repro: equal to `R11U209_OFF R11U205_OFF` on 498; the 6 others are `R11U205_OFF`'s extra reach into landing 210's ground-A § elabIfArrIdxChainName205 (r11u205dec IA a02 a05, r11u210repro IA i01 i02 i03 i05) |
| `R11U219_OFF` | this landing: pass 219's laws and the r11u214 laws it lands | pristine bytes on 70 own case-views and every corpus and probe database |

## 9. Determinism ([det_law.txt](evidence/final/det_law.txt), [det_pris.txt](evidence/final/det_pris.txt), drivers/det.sh)

Three concurrent harness runs per binary of Earlgrey_0_1 and the five UVM rows, both modes: every row-mode one hash
per binary and mode except the known coins, in both binaries: Scoreboard default (law 2 + 1 draws, 92 uhdm-dump lines
unsorted and 0 sorted: the svunit listing order; pristine three hashes) and MiniAmiq (one hash per batch, a second
hash against the sweep's: dumps identical even unsorted, storage order only). Earlgrey d `6a8fcde9f0f9` / t
`dc6bc45475ff` with the law, r11u214's law hashes. No new coin.

## 10. Fence and process

* Every driver reads the four fenced names from the `FENCED=` line of tools/probe/r11u107repro/canaudit.sh
  (drivers/env.sh, fail closed) and refuses them by word boundary: case.sh, grid.sh, reach.sh, widebytes.sh,
  dscases.py (a path naming one is refused), census.sh (`--filter`), predict.py, awayall.py, movers.sh, dslanes.sh,
  bvmirror.sh (fenced row-mode directories skipped unread); uvmdist.sh and det.sh run fixed row lists checked against
  the fence. The gate sweeps dispatched every row, as the gate mandates. A grep of this directory for the four names
  reads 0.
* **One process finding against this pass**: before movers.sh existed, one ad-hoc loop compared `slang.uhdm` bytes
  (`cmp -s`, equality only) between two of this pass's own gate-sweep workdirs over every corpus directory, the 8
  fenced row-mode databases included. No content was read or decoded, no binary or script ran on a fenced test's
  sources, and no result about them is used here; every later comparison went through the fence-checked drivers.
* No gdb or debug build ran on a fenced test; the pp decode used a temporary debug build (stderr prints, reverted
  before the final binary) on this pass's own case M/m03 only.
* Binaries frozen before measurement; no source edited while a build of this worktree compiled; builds `-j 2`.
* Drivers resolve paths from the checkout; scratch is under `/tmp/r11u219_*` (exported `S`), never relative to the
  current directory.

## 11. Residues, ranked

1. **The `UVM_FILE` builtin-typedef relocation** (now the first record of all nine UVM row-modes: `typedef int
   UVM_FILE;` golden at a class method formal's type token, `uvm_root.svh 348:39-47`, `uvm_component.svh 2250:61`,
   ... one location per listing; ours at the declaration `uvm_object_globals.svh 313:9-12`). UhdmExporter's formal
   writer model (§ tfArgClassMethodOrder176 and its relatives) admits only enum and aggregate typedefs; a scalar
   builtin typedef is not a candidate. Ground B; the per-listing locations suggest per-use int_typespec objects in
   golden: decode first.
2. **Earlgrey d/t's first records** (dm_csrs.sv 91:52 `8'h04` `endcol` 56 vs 61: the package-qualified operand of a
   localparam initializer, r11u214's ground-A half, ExprEmit emitExpr < ParamEmit emitParameters).
3. **The identity family of the enum writer** (section 2.3: golden's per-class listing copies `p::c::p::ALIAS_T`
   beside the design object; ours one object): excused by the comparator; not a law of this ground without minting
   copies.
4. **x03's formal relocation into a `$unit` class method** (Z/x03 `line`: golden relocates the alias to
   `mid_c::set(ALIAS_T v)`'s type token): the `$unit`-class writer of the formal model (§ tfArgOutsideClassOrder216
   declines a class outside any package or module).
5. **The r11u214 residues not reached**: MiniAmiq #899-type formal writer order in ParamEmit (ground A), N0008 (the
   design param_assign's right side as compiled), the svaunit clone return-variable names (544 / 597 split), N0151
   identity, the module-imported int array's element span (E k01).
6. **Pass 216's residues not taken**: the sized/based range-bound encoding (f05, f12, f13, g10; decoded here: a
   plain `logic [4'h7:0] a;` is stage 1 at the base, golden `HEX:7` decompile `4'h7` over the whole literal, ours
   `UINT:7` at the size token; TypeEmit makeTypespec's bound lambda, not written), the module-scope class reference
   name, the interface-class and program typedef listings, cfg_func_width_loop #464, the 14 uvm_severity class-member
   references, the variable initializer (n11, downstream DIVERGENT on both), the unpacked `$left` (n12), net order
   across an include (n17), the declined writer shapes.
7. **Pass 212's residues not taken** (the instance-range stamps e05/g11, the net-declaration left side, member order
   across a late include a06, g08/g09 names, the exposed names, s08/s09/s18, g12 EQUIVALENT) and **the sister's
   hand-offs** (importPaCopy82's UVM_MACRO_NUMFLAGS copies, the header without parentheses, InterfArrayBind #183):
   not attempted.
8. **Macro spans left**: m06's method chain in a macro argument (stage 1, ExprEmit's hier_path); a pasted method name
   through a forwarded actual not reproduced; the grid's other shapes already equal.
9. **Items (3), (4), (6), (7) of the brief** beyond what is above: not attempted.

## 12. Files

* **cases/**: Z (item 0's fresh cases and the two refinements, 16), I (the spaced ips branch, 4), S (the `$size` reach,
  5), M (the macro spans, 10); every case's first line names its law.
* **drivers/**: env.sh (pins, fence), case.sh, grid.sh, reach.sh, widebytes.sh, census.sh, predict.py, movers.sh,
  bvmirror.sh, awayall.py (both keys, in-place pairing), away2.py, recctx.py (a flat record's chain decomposition),
  unmask.py, uvmdist.sh, det.sh, dscases.py, dsfaces.sh, dslanes.sh.
* **evidence/**: item0/ (item 0 alone, the 12 records), refine/ (the unrefined wide control and its raw census), pp/,
  reach/, census/ (the frozen prediction and the superseded drafts), final/ (gates, movers, away census, wide
  control, downstream, determinism, first records), the own grids and switch table.
* tests/LAWS.md regenerated (`python3 scripts/law_index.py`).
