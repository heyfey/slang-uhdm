# r11u244 — pass 244, the expression/parameter ground (implementer)

Base `2b7fb2f5` (matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp` (the drain calls) and
the new switch header `src/R244.h`. Seven laws; each reads its own `R11U244_<LAW>_OFF`, and `R11U244_OFF` drops all
seven and restores the pristine bytes. `R11U244_TRACE=<dir>` writes `<dir>/<pid>.244`: first line `OUT <-o path>`,
then one `<law> <detail>` line per firing. The non-writing branches are tagged `_shape`, `_failed`, `_parented`,
`_same` and `_this`. No file of the sister ground (TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit, uhdm_main) is
touched. One law (§ cloneBlockFixedArrTsParented244) appends to pass 241's design-final list `g_cloneArrTs241`
(declared `extern` in StmtEmit) and is applied by § cloneLocalArrayTsParented241's drain with its guard.

The four slang-fenced tests are never named here. Every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed. Nothing fenced was dispatched outside the gate sweeps,
decoded or opened: the census ran with a `--filter` built from `$FENCED`, byteverify ran on hard-link mirrors filtered
by `$FENCED` (`drivers/bvmirror.sh`), and the away census skips fenced paths before opening them.

## Verdict per targeted row (base -> this pass; fresh rows of the law sweep `/tmp/r11u244_wL`)

**No corpus row converts.** Seven row-modes move their first record later, each with **0 golden-agreeing records
lost** (chain-keyed away census 0 on all of them). Twelve probe cases convert.

```
BuildUVMPkg,default,STRICT_NOTEQUAL,differ:endcol(4),,differ:endcol(4)
BuildUVMPkg,testflags,STRICT_NOTEQUAL,differ:endcol(4),,differ:endcol(4)
MiniAmiq,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
MiniAmiq,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
Scoreboard,default,STRICT_NOTEQUAL,differ:file(2),,differ:file(2)
SeqDriver,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
SeqDriver,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
```

| row-mode | base | after | what moved (records in [evidence/heads.txt](evidence/heads.txt)) |
|---|---|---|---|
| MiniAmiq d/t | `fullname(4)` #71388 | `depth(1)` #76762 | Brief item (1)(a). #71388/#71389/#71399 are cleared by § cloneBlockArrElemOwnCopy244 and § cloneBlockFixedArrTsParented244 (the nested-block `int q[5]` in `svaunit_pkg::uvm_table_printer::emit`). #72428 (`bits = new[m_packed_size]` in the copy of `uvm_packer::get_bits`, golden `svaunit_pkg::uvm_packer::get_bits::m_packed_size`, ours bare) is cleared by § cloneNewArrayCallParented244. Toward 972 per mode, away 0. The new head is on the sister ground (see "Sister-ground faces"). |
| SeqDriver d/t | `fullname(4)` #71344 / #71356 | `depth(1)` #76718 / #76730 | The same faces in the `adpcm_pkg` copy. Toward 652 per mode, away 0. |
| Scoreboard d | `fullname(3)` #81633 | `file(2)` #84633 | Brief item (1)(c). `predict_info.addr[rw.addr] = 1`: the trailing `addr` of the index path is named by the chain (golden `uvm_pkg::uvm_reg_predictor::write::predict_info.addr[]::addr::addr`), fixed by § hpSelIdxPathTrailByChain244. Toward 14, away 0. The new head (a class_typespec's param_assign written with a file where golden's has none) is on the sister ground. |
| BuildUVMPkg d/t | `file(8)` #81827 | `endcol(4)` #91593 | Brief item (1)(b). #81827 (the foreach body `begin` of `uvm_port_component::get_connected_to` with no location in ours) is cleared by § invalidBlockLocFromSyntax244. #82349 (the Scoreboard face) is cleared by § hpSelIdxPathTrailByChain244. #139619 (`rw.data[i*8+:8]`) is cleared by § lvHpIpsOperandChain244. #139713 (`cb.` + newline + `pre_read(rw)`) is cleared by § methCallNameSpanAcrossLines244. The four left are #91593, #121601, #129711 and #153018, listed under the residues. Toward 11 per mode, away 0. |
| SimpleUVM d/t | `file(2)` #75684 / #75696 | unchanged | Brief item (1)(d). The head is the sister's `work@top.this` wire (TypeEmit `thisImplicitNetBoth38`). Bytes move behind it: the hier_path index and invalid-block laws fire (toward 14 per mode, away 0). |

The base records, reproduced at the base with `build/uhdm-strictcmp` (question 1):

```
MiniAmiq d #71388 fullname   A: 5 int_var  svaunit_pkg::uvm_table_printer::emit     uvm_printer.svh 1049 11 1049 12
                             B: 5 int_var  svaunit_pkg::uvm_table_printer::emit::q  uvm_printer.svh 1049 11 1049 12
Scoreboard d #81633 fullname A: 16 ref_obj addr uvm_pkg::uvm_reg_predictor::write::predict_info.addr[]::addr::addr
                             B: 16 ref_obj addr uvm_pkg::uvm_reg_predictor::write::addr
BuildUVMPkg d #81827 file    A: 8 begin uvm_pkg::uvm_port_component::get_connected_to uvm_pkg.sv 45157 26 45159 8
                             B: 8 begin uvm_pkg::uvm_port_component::get_connected_to            0 0 0 0
```

## The laws (read each at its § token)

### § cloneBlockArrElemOwnCopy244 (`R11U244_BLKELEMCOPY_OFF`; StmtEmit, the block branch's array locals + `drainBlkElemCopies244`)

A nested-block array local lists its element variable twice: first on the block's Variables, then under the
array_var. In the home listing both lists hold one object, so a walk meets it once. The importer's listing is
Surelog's `clone_tree` of the home subroutine (CompileHelper importPackage), and DeepClone copies each list. So the
block's entry is its own copy, parented at the block, with no stored full name (the getter computes the block's,
`svaunit_pkg::uvm_table_printer::emit`). The array_var's entry is a second copy (`...::emit::q`).

**Law:** in an importer copy (`pkgImportCloneEmit`), the block's element entry of every fixed, queue, dynamic and
associative local is replaced design-final by a `clone_tree` copy made with § importCloneBodyLocalCopies175's context.
The copy is parented at the block and its stored full names (the variable's and its ref_typespec's) are cleared. A
non-element entry abstains (`_shape`), and so does a failed clone (`_failed`); neither fired.

Pass 175's law covers the subroutine body's wrapper list. This law covers the user-written blocks. Function-level
array locals list their element only under the array_var, in golden too (grid N n13).

### § cloneBlockFixedArrTsParented244 (`R11U244_BLKFIXARRTS_OFF`; StmtEmit, the fixed-size block branch)

This is the fixed-size twin of § cloneLocalArrayTsParented241, MiniAmiq #71399. In a copy, the clone's array_typespec
is parented at the local's ref_typespec, so the element reference under it reads the local's full name (strict
prints `<in>`). The pair is queued on `g_cloneArrTs241` and set by pass 241's design-final drain, which applies its
own guard (`..._shared` abstains).

### § cloneNewArrayCallParented244 (`R11U244_NEWARRPARENT_OFF`; ExprEmit NewArray branch + `drainNewArrParent244`)

§ newArray11 keeps the `new[...]` call unparented, which models Surelog's home listing: `paDynamic_array_new` compiles
the call with no parent, so the references under it store no name. UHDM's ComputeFullName stops at the call and gives
`m_packed_size`, and vpi_get_str reports that as no full name because it equals the name. In the importer's
`clone_tree`, DeepCopy parents the cloned call at the cloned assignment. The chain then runs through the copy, and
golden's references read `<copy subroutine>::<name>`.

§ cloneNewArrayArgBindsOwnDecl186 measured this name earlier and did not take it, because of the `-elabuhdm` view's
module-hoisted copy. That view keeps the base: the law is gated on `!elabUhdmView121`.

**Law:** in the default view's importer copies, the call is parented at its assignment, design-final, before any later
drain reads a name. A call that already has a parent abstains (`_parented`); it never fired.

### § hpSelIdxPathTrailByChain244 (`R11U244_HPIDXTRAIL_OFF`; ExprEmit `drainHpSelIdxTrail244`)

This rule applies to a hier_path written inside the select index of a hier_path's member bit select or indexed part
select. The index can be the path itself (`pi.addr[rw.addr]`, `s.v[t.k]`, `s.d[t.k +: 2]`), or the path can sit
inside an operation (`[rw.addr + 1]`), a concatenation (`[{t.j}]`) or a call argument (`[g(rw.k)]`). In every such
position the path's **trailing** reference stores no full name, and the reader computes it through the chain: the
inner path is skipped, while the member select and the outer path are named. Golden reads
`uvm_pkg::uvm_reg_predictor::write::predict_info.addr[]::addr::addr` in a class method, `work@top.s.v[].v.k` in a
module and `work@top.s.v.v.j` for an rvalue, in both views. Ours scoped the reference like a plain one.

**Law:** the trailing reference is set design-final to the chain name (`chainFullName175`), after the path-index
drains. A path in a plain select's index (`a[rw.k]`) is already right and is not touched.

The refinement found by the firing census: a `this.` / `super.`-rooted inner path keeps its bare name
(`pkt.data[this.data[k]]`, probe `r10svs4repro/g1_thisidx`), so the law abstains there (`_this`). A stored name that
is already the chain name is `_same`.

### § lvHpIpsOperandChain244 (`R11U244_LVIPSCHAIN_OFF`; ExprEmit `drainLvIpsChain244`)

This is the indexed-part-select twin of § lvSelIdxChainName181. In a procedural lvalue path (the hier_path that is an
assignment's Lhs), the references inside an indexed part select's base or width operation, or inside a call there,
store no name. Golden reads `...::bus2reg::rw.data[i * 8+:8]::data::i`; ours read `...::bus2reg::i`. The rule is
applied design-final with § 181's guard (`chainFix181`). A plain-reference base and the rvalue are already right
(grid L i02, i03).

### § invalidBlockLocFromSyntax244 (`R11U244_INVBLKLOC_OFF`; StmtEmit block branch, the Invalid branch, the subroutine wrapper anchor)

slang hands a block that holds a bad statement back as an InvalidStatement over the partly built BlockStatement. Such
a statement is, for example, `list1[name].get_comp()` against the default `PORT = uvm_object`. The child BlockStatement
has no syntax and an empty range: `createBlockStatement` takes the body's range, and InvalidStatement's own range is
`SourceRange()`. The syntax sits on one of two statements:

* on the InvalidStatement, because `Statement::bind` sets it after `BlockStatement::fromSyntax`;
* on the child, when slang made the block from a hierarchy node (`tryGetBlock`, the implicit block of a foreach), because `bindBlock` sets it before `badStmt`.

Surelog parsed the text and locates both: the block at its `begin..end`, and the subroutine wrapper anchored at such
an item at the item's statement.

**Law:** the location is read from whichever of the two holds the syntax.

### § methCallNameSpanAcrossLines244 (`R11U244_METHNAMELOC_OFF`; ExprEmit `methNameLoc244` at the six receiver-relative method-span sites)

A method_func_call is located at its name token, wherever that token sits (golden 63085:29-37 for the preprocessed
`cb.` + newline + `pre_read(rw)`). Our receiver-relative raw offset is correct only for the tight spelling.

**Law:** step from the guess over whitespace, comments and at most one dot to the name. Keep the guess when the text
there does not spell the name.

As a side effect, § methodParensWritten77 now sees the real name token, so `z = cb. get;` and the newline spelling
are recognised as parens-less calls. Grid D d09 and d10 move from stage 1 (26 / 34 uhdm-cmp lines) to STRICT_EQUAL.

## Binaries (frozen before any measurement; every `cmds.txt` audited by binary path)

| binary | md5 | note |
|---|---|---|
| pristine (`/tmp/r11u244_bin/pristine`) | `ffc33c14c9ae12cc33b6f0eeee552e26` | built at `2b7fb2f5` with the system-deps config (`-j 2`), identical to the main tree's `build/slang-uhdm`; reports slang 12.0.0+545f88b2e |
| law (`/tmp/r11u244_bin/law`) | `6961085a65faf68adff922649aebecea` | this patch (the worktree's build of the delivered sources, `dev10`) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the worktree's build of `tools/uhdm-strictcmp` |
| strictcmp_x | `886f030233ecdbcce7d0e29ac0c4df2c` | `drivers/strictcmp_x.cpp`, built by `drivers/cc_x.sh`, used by the away census |

Development binaries `dev1` to `dev9` ran only on cases and on filtered target rows. `dev9` was frozen once as `law`
for a first census, which exposed `g1_thisidx` (§ hpSelIdxPathTrailByChain244's `this.` refinement). The census,
prediction and law sweep cited here are all the final binary's. Every `cmds.txt` of the pristine sweep names
`/tmp/r11u244_bin/pristine` only (3273 of 3273), and of the law sweep `/tmp/r11u244_bin/law` only (3273 of 3273).

## Gates (from the worktree, SLANG_UHDM exported, `tests/sweep.sh --jobs 3`; [evidence/sweep_pristine.txt](evidence/sweep_pristine.txt), [evidence/sweep_law.txt](evidence/sweep_law.txt))

| stage | pristine sweep (`/tmp/r11u244_wP`) | law sweep (`/tmp/r11u244_wL`) |
|---|---|---|
| probe | EQUAL 3481 + STRICT_NOTEQUAL 606, 0 / 0 / 0 | EQUAL **3493** + 594: **regressions 0, conversions 12, changes 7** |
| surelog | 470 + 10 / 466 + 8, 0 / 0 / 0 | 470 + 10 / 466 + 8: **regressions 0, conversions 0, changes 7** (the rows above) |
| uhdm2rtlil | 803 + 0 per mode, 0 / 0 / 0 | **0 / 0 / 0** |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **803 / 66 / 2 / 0, not excused 0**; the two csvs sorted and diffed: **0 lines** |

Both sweeps print `law index STALE` first: the base's committed `tests/LAWS.md` predates its own commit. The patch
carries the regenerated file. The only other surelog csv lines that differ between the two sweeps are LowMemLib and
LowMemPkg testflags, whose SURELOG_FAIL detail text carries the workdir path (environment).

**Probe conversions (12):** r10earl29repro/a4_ctx and a6_noconcat, r10uvm94repro/g94_a0_head
(§ hpSelIdxPathTrailByChain244); r10svs2repro/w2_spacedot, r10svs8repro/a5_escaped and a6_escinlaw
(§ methCallNameSpanAcrossLines244); r10uvm165repro/g165_c_forms, r10uvm59repro/e01_uninstgen and f01_lvuninst,
r10v160repro/y13_foreach and y14_fork, r10v165repro/v165_e_assert (§ invalidBlockLocFromSyntax244). Every one reads
`STRICT_NOTEQUAL ... -> EQUAL` in the law sweep's compare.

**Probe changes (7):**

| case | change | law | attribution |
|---|---|---|---|
| r10earl29repro/a1_hp2, a2_hp1, b3_edges | fullname 4 -> 2 | § hpSelIdxPathTrailByChain244 | improvement |
| r10uvm92repro/v92_b2_varsel | fullname 22 -> 21 | § hpSelIdxPathTrailByChain244 | improvement |
| r10uvm158repro/g158_a_shape, r10v158repro/v158_d | file 2 -> 1 | § invalidBlockLocFromSyntax244 | improvement |
| r10uvm208repro/g208_e_head | fullname 4 -> 8 | § cloneBlockArrElemOwnCopy244 + § cloneBlockFixedArrTsParented244 | see below |

g208_e_head's count grows, but the walk diverges later. The old first record #92 (the nested-block element `addrs208`
under the begin, golden `p208b_e::M208::m_set_reg_offset208`) is cleared. The new first record #109 (the array
typespec's element ref inside the queue local's copy) is present in the pristine database too. The added records
(#173, #386) are the pre-existing foreach loop variable face: the alias's actual names `p208a_e::uvm_reg_addr208_t`
in golden and the copy's name in ours (brief item (1)(e)). Its chain-keyed away census reads **0 lost, 48 toward**.

**uhdm-cmp** reads 0 lines on all 9 corpus movers (rc 0, [evidence/movers/uhdmcmp.txt](evidence/movers/uhdmcmp.txt)).

**Canaries** ([evidence/canaries.txt](evidence/canaries.txt)):
* `canaries.sh` surelog: ok=47 changed=5. The five are the targeted SeqDriver d/t, BuildUVMPkg d/t and Scoreboard d; MiniAmiq is not a canary. unknown-names 7 (the u2r-only canaries).
* `canaries.sh` uhdm2rtlil: ok=16 changed=0.
* `EXPECT_UNKNOWN=1 ctcan2.sh` surelog: PASS.
* `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil: PASS.

**`R11U244_OFF=1`** with the law binary writes the pristine bytes on all 9 corpus mover row-modes
([evidence/movers/off_corpus.txt](evidence/movers/off_corpus.txt)) and on all 258 grid case-views.

## The mover prediction, frozen before the law sweep ([evidence/census/](evidence/census/))

`drivers/census.sh` ran `law` with `R11U244_TRACE` over both corpora in both modes (`--filter` built from `$FENCED`)
and every probe case. `drivers/dscensus.py` ran every downstream lane (the harness's translated command line).
`drivers/predict.py` then named every database whose process fired a writing branch: **28 predicted movers**. They are
9 surelog row-modes, 19 probe cases, 0 uhdm2rtlil and 0 downstream lanes. The prediction was frozen at
2026-10-05T04:54:48-04:00 (`frozen_at.txt`, md5 `eb4ac8bb4fcaeff7fb1bdf32ff35205d`); the law sweep's log was created
at 04:55:01.

Firings ([census/firings.txt](evidence/census/firings.txt)):

| law or tag | firings |
|---|---|
| cloneBlockArrElemOwnCopy244 | 410 |
| hpSelIdxPathTrailByChain244 | 83 |
| hpSelIdxPathTrailByChain244_this (non-writing) | 1 |
| cloneNewArrayCallParented244 | 80 |
| invalidBlockLocFromSyntax244 | 55 |
| methCallNameSpanAcrossLines244 | 13 |
| lvHpIpsOperandChain244 | 9 |
| cloneBlockFixedArrTsParented244 | 8 |

No other non-writing tag fired. No uhdm2rtlil or downstream lane fires any law.

**byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`, on hard-link mirrors of both sweeps without
the fenced paths, same-length workdir names; [evidence/movers/byteverify.txt](evidence/movers/byteverify.txt)):
`PATH_SETS_IDENTICAL (2560 paths)`, **MOVERS: 9 / 2560**. Every mover was predicted and every prediction moved:
BuildUVMPkg d/t, MiniAmiq d/t, Scoreboard d, SeqDriver d/t and SimpleUVM d/t.

`SELFCHECK (every file vs one fixed file): 2559 / 2560 flagged` is the self-check reading correctly, not a movers line:
one side is replaced by one fixed file, and that file compared with itself is the one path the check cannot flag.

**Probe**: 19 of 4087 databases move, exactly the 19 predicted
([evidence/movers/probe_movers.txt](evidence/movers/probe_movers.txt)). **Downstream**: the verdict csvs are identical,
and no lane fired in the census.

## Away-moved-record census (map 13's chain-keyed census, `drivers/awayrows.py` with strictcmp_x; [evidence/movers/away.txt](evidence/movers/away.txt))

Over the 28 databases that differ between the pristine and the law sweeps, **chain-keyed away is 0 and flat away is 0
on every one**. Toward counts per database:

| database | toward (chain key) |
|---|---|
| MiniAmiq, per mode | 972 |
| SeqDriver, per mode | 652 |
| Scoreboard d | 14 |
| SimpleUVM, per mode | 14 |
| BuildUVMPkg, per mode | 11 |
| g208_e_head | 48 |
| the other probe movers | 1-10 each |

Positive control ([evidence/movers/away_reversed_control.txt](evidence/movers/away_reversed_control.txt)): the same
census with the sweeps swapped reads those numbers as away, with toward 0.

## Determinism ([evidence/det_law.txt](evidence/det_law.txt))

`drivers/det.sh` ran three concurrent harness runs of the law binary on Earlgrey_0_1 and the five UVM rows, in both
modes. It reads **one hash per row-mode on all 11** (Scoreboard testflags writes no database), each equal to the law
sweep's database: Earlgrey_0_1 d `99040b3db63c`, t `233bf5448585` (unchanged from the base); MiniAmiq d/t
`b81f02871696`; SeqDriver d `bfb977eb25d5`, t `22b827306854`; SimpleUVM d `8e3c098a9457`, t `cf69afafd63a`;
Scoreboard d `e543358b8607`; BuildUVMPkg d/t `dd1884e82c82`.

## Grid (cases/, 129 cases, both views; `drivers/grid.sh`, `drivers/gridsum.py`; [evidence/grid.txt](evidence/grid.txt), [evidence/grid_summary.md](evidence/grid_summary.md))

The grid made 2580 runs: pristine, law, law with `R11U244_OFF`, and the law with each of the seven switches, in the
default and `-elabuhdm` views. **Every line carries its exit code**: 254 case-views exit 0 on both binaries. F/f19
(fork in a function, illegal SV) exits 3 on both. X/x02 (pure virtual in a virtual parameterized class) exits 4 on
both, at stage 1 with 33 lines.

* `R11U244_OFF` writes the pristine bytes on **258 of 258** case-views.
* **108 case-views enter STRICT_EQUAL and none leaves.**
* No uhdm-cmp line count rises. Four fall: D d09 and d10, 26 / 34 -> 0 in both views.
* Each switch reverts only its own law's cases:

| switch | case-views reverted |
|---|---|
| BLKELEMCOPY | 28 |
| BLKFIXARRTS | 24 |
| NEWARRPARENT | 17 |
| HPIDXTRAIL | 46 |
| LVIPSCHAIN | 16 |
| INVBLKLOC | 20 |
| METHNAMELOC | 28 |

| group | law | shapes | pristine -> law |
|---|---|---|---|
| N n01-n13 | § cloneBlockArrElemOwnCopy244, § cloneBlockFixedArrTsParented244 | a nested-block `int q[5]` in a copy (the MiniAmiq shape), queue, dynamic, 2-D fixed, struct element, class handle, a range dimension, `logic [7:0] q[5]`, two locals, nested begins, a string array, foreach over the local, function-level arrays (n13) | 15 case-views enter STRICT_EQUAL: n01, n06, n07, n09-n11 in both views, n02 and n03 in the default view (their `-elabuhdm` view was already equal), and n04 in the `-elabuhdm` view. n04's default view reads `type`, a pre-existing face (the var_select's home binding). n05 and n12 stage 1 on both binaries (unchanged line counts). n08: a pre-existing part-select name face. n13: TaskFuncEmit's function-level fixed array, on the sister ground. |
| W w01-w16 | § cloneNewArrayCallParented244 | `new[n]`, a class property, an operation, a call, `arr[k]`, `v[k+:2]`, `src.size()`, a copy source, `$clog2`, a named block, `this.md = new[n]`, `h.q.size()`, loops and conditions | 9 case-views fullname -> STRICT_EQUAL (default view; the `-elabuhdm` view is untouched by design and was already equal). Six stage-1 shapes are unchanged on both binaries. |
| L l01-l19 | § hpSelIdxPathTrailByChain244 | lvalue and rvalue path index, an associative member, a nested path, an operation index, `+=`, `++`, if and foreach holders, controls on plain selects (l13-l15), a `this.` index (l19) | 12 cases (l01-l05, l07, l08, l10, l11, l16-l18) fullname -> STRICT_EQUAL in both views. Controls unchanged. l06, l09, l12 and l19 stage 1 on both binaries. |
| L m01-m05 | § hpSelIdxPathTrailByChain244 | module always_comb, continuous assignment, initial, generate-for, a part-select index and a concatenation index | the path face cleared. m01-m03 and m05 still fail on a pre-existing ref_typespec name inside an unpacked struct member typedef (sister ground). m04 stage 1 on both. |
| L i01-i10 | § lvHpIpsOperandChain244 | `[i*8+:8]`, `[i*8-:8]`, foreach, `+=`, a nested member, controls `[i+:8]` and the rvalue | i01, i04, i05, i08 and i09 -> STRICT_EQUAL in both views. Controls unchanged. i06, i07 and i10 stage 1 on both. |
| F f01-f20 | § invalidBlockLocFromSyntax244 | valid controls (f01-f10) and an unresolvable method on a defaulted type parameter under foreach, if, for, nested begins, a decl in the block and a statement before | 8 cases (f11, f12, f14-f18, f20) file -> STRICT_EQUAL in both views. Controls unchanged. f13 (a named begin) stage 1 on both. |
| D d01-d20 | § methCallNameSpanAcrossLines244 | newline after the dot, before the dot, spaces, a block comment, a line comment, an expression, a condition, a call argument, a nested call, a parens-less call, `this.` paths | 12 cases (d01, d03, d04, d06, d07, d09, d10, d13, d15, d16, d18, d20) -> STRICT_EQUAL in both views. d12 (the macro-body spelling) unchanged, a residue. d19 (an interface method) stage 1 on both. |
| X x01-x09 | context cases for every law | an interface body, a class specialization with a parameter in bounds, extern and pure virtual prototypes, named and empty-slot calls with omitted defaults, implicit nets and a two-level generate, generate-local nets | x03, x04, x06, x08, x09 -> STRICT_EQUAL. x01 unchanged and equal. x02 (exit 4), x05 and x07 stage 1 with unchanged line counts. |
| H h01-h12, P p01-p04, G g01 | decode cases (no law of this pass) | H: the clone hier-base binding of item (1), all STRICT_EQUAL on both binaries (distinguisher not isolated). P: BlackBePipeInt's paren-cast width shape, stage 1 on both. G: Rggen's call-argument typespec, line on both. | unchanged |

The constant slots were exercised where each law can meet them: a part-select bound and an indexed part-select base
and width (L i-cases, X x04, x05), a dimension bound (N n07, X x02), a parameter in a bound (X x02, x06), a
replication-free concatenation index (L m05) and a `new[...]` size (W).

## Sister-ground faces (decode only; call sites)

1. **MiniAmiq / SeqDriver #76762 / #76718 / #76730** (the new head of all four row-modes). In the copy of
   `uvm_phase::execute_phase`, the `uvm_do_callbacks` expansion `cb = iter.first()`: golden's hier_path base `iter`
   binds a home-named `class_var uvm_pkg::uvm_phase::execute_phase::iter` that no listing walks, while ours binds the
   copy's own declaration. Our `uvm_phase::add` copy already matches golden on the same macro.
   * Site: UhdmExporter `pkgCloneHierBind9` / § cloneStmtHomeVarRef17. The latter keys a clone's variables by
     declaration site and refuses an ambiguous key, and every expansion of the macro shares one site.
   * Grid H h01-h12 (function / task, multiple expansions, macro-defined) all read STRICT_EQUAL, so the distinguisher
     is not isolated.
2. **Scoreboard d #84633**: a `class_typespec`'s param_assign (`uvm_analysis_imp#(int, my_scoreboard)`'s `T`) that
   golden writes with no file and ours with `uvm_analysis_port.svh`. Site: the UhdmExporter class_typespec
   param_assign writers (`cts->Param_assigns`). Behind it is #84965 (a parameter `UVM_RADIX` against golden's
   constant).
3. **BuildUVMPkg #91593 / #121601 / #129711**:
   * #91593: a pure-virtual prototype formal `int unsigned precedence`, int_typespec ending at `int` in golden and at
     `unsigned` in ours (the TaskFuncEmit formal typespec).
   * #121601: the raw full name of `uvm_packer::m_bits`' typedef reference (the class property writer).
   * #129711: the `T` typespec of `uvm_queue#(T)` located at `push_back(T item)` 14837 in golden and at
     `T queue[$]` 14699 in ours (the class body writers).
4. **SimpleUVM #75684 / #75696**: the `work@top.this` wire (TypeEmit `thisImplicitNetBoth38`, pass 240's face).
5. **Grid N n13**: TaskFuncEmit's function-level fixed-array local in a copy does not take
   § cloneLocalArrayTsParented241 (the `<in>` element reference).
6. **Grid L m01-m05**: an unpacked struct typedef's unpacked-array member's ref_typespec is named `<in>arr_t.v` in
   ours and unnamed in golden (the TypeEmit struct member writer).

## Residues, ranked (ground A first)

1. **BuildUVMPkg #153018** (the fourth record left; ground A, decoded, not written). In `uvm_reg_map::m_set_reg_offset`,
   the foreach loop variable `addrs` (a `ref_var`) binds an array_typespec whose element alias reaches the
   unfolded `bit unsigned [64-1:0] uvm_reg_addr_t` typedef. Golden reaches the folded copy (`INT:63`) of the listing it
   sits in. This is brief item (1)(e): StmtEmit `arrayVarArrayTs` binds the last emission's array_typespec, not the
   current listing's. Probe g208_e_head's added records (#173 / #386) are the same face.
2. **Rggen d #23546** (brief item 2; reproduced as grid G g01, where both views differ in this shape). The folded
   parameter actual of an elaboration-time call (`f(N)` with `N=25`) is typed with N's int_typespec in golden and with
   the formal's in ours. The stamping lives in ExprEmit's argument emission beside § nestedParamActualTs6; not
   written.
3. **BlackBePipeInt d #38807 / t #38803** (brief item 4): reproduced shapes P p01-p04 are stage 1 at the base on
   another face. The folded constant of an importing package's `w_gp = dev_addr_width_gp + 1` is typed by the cast
   int_typespec 3:3-36 in golden. A decode grid needs another shape first; not written.
4. **Earlgrey_0_1 d/t** (brief item 3) #136315 / #137760, then #142988 and #154375: not attempted. The bytes are
   unchanged and no law fires.
5. Grid residues:
   * D d12: a method call whose name comes from a macro body on another line.
   * N n04: a 2-D var_select's home binding in a copy.
   * N n08: the part-select name `q::q`.
   * L m01-m05: the sister typespec face.
   * F f13: the named begin under an invalid foreach.
   * W stage-1 shapes w02, w05, w06, w08, w09, w14.
6. The brief's items (5), (6) and (7): not attempted.

## Process notes

- Every command ran from the worktree `/tmp/wt_r11u244` (base `2b7fb2f5`), with scratch under `/tmp/r11u244_*`. The main
  checkout was never written and no submodule was initialised in the worktree. No process of another agent was
  listed or signalled.
  * One waiter of this pass used `pgrep -f` on its own workdir name. It matched its own shell and never ended; it was
    stopped by its task id, and nothing else was signalled.
- **Fence**: the fence names were read into a variable only. One `compare_results.py` call on the census's surelog csv,
  run without `--filter`, printed the four fenced rows as `ONLY-COMMITTED (not run)` lines, read from the committed
  baseline csv only; no fenced file or database was opened. Every later compare used a `--filter` built from
  `$FENCED`.
  * The census, mirrors and away census filter by `$FENCED` before any file is opened.
  * The producer (`$SURELOG`) ran only on this pass's own case files (`case.sh`) and inside the harness.
- Every tool reached through a variable was guarded with `[ -x ]` (in `env.sh` and `case.sh`, and before every
  uhdm-dump, uhdm-cmp and strictcmp call); no database was executed.
- The decode-only cases H, P and G name existing laws in their first line (§ cloneStmtHomeVarRef17,
  § parenCastWidthRefPkgBare207, § nestedParamActualTs6), because no law of this pass covers them. The relabel was
  made before the final grid run.
- The patch carries no patch file; `/tmp/r11u244.patch` is transport only.

## Drivers (`drivers/`; every one reads `$FENCED` fail-closed, compiled helpers included)

`env.sh`, `case.sh`, `grid.sh`, `gridsum.py`, `census.sh`, `dscensus.py`, `predict.py` (the `.244` traces, with this
pass's non-writing tags), `bvmirror.sh`, `det.sh`, `awayrows.py`, `strictcmp_x.cpp` + `cc_x.sh`, and the identity
readers `memids.cpp` and `paramids.cpp`. All were copied from r11u242repro, with the switches and trace names updated.
