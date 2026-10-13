# r11u310 — pass 310, expression/parameter ground: the method-call path's receiver index, the lvalue nested path's middle index, the casts and class-method lvalue indices the non-trailing laws did not reach, and the call spans in a non-trailing index

Pair A, refill after pass 308. Base 50288747 (pass 308 on top of pass 311). Production surface: src/ExprEmit.cpp only
(thirteen laws, their state static in the file, the two drains called from `nonTrailIdxDrain308`, so ParamEmit's drain
list is unchanged); no src/R*.h, nothing in src/LawState.h, every switch read through src/LawSwitch.h
(`lawOn(310, ...)`, `lawTrace(310, ...)`), no getenv and no reader of this pass's own. Pristine build md5
ce9fa46ba3afcd1ff2a7dbff0a690e9b (equal to the main tree's build/slang-uhdm at the base); law build md5
13561334707cdac7bce3d7f66b3b8481. Both binaries were frozen (chmod 555) before any measurement and both report slang
12.0.0+545f88b2e; every cmds.txt of both sweeps names its own binary (evidence/gates.txt).

## Verdict

- **No corpus row and no probe case moves**, in status or in bytes: probe 4017 EQUAL + 70 STRICT_NOTEQUAL on both
  binaries (regressions 0, conversions 0, changes 0); surelog default 480 + 0 and testflags 474 + 0, uhdm2rtlil
  803/1/67 in both modes, regressions 0 / conversions 0 / changes 0; byteverify reads 0 of 3365 corpus and
  downstream-lane databases and 0 of 4087 probe databases moving. Every Surelog row-mode stays CMP_EQUAL (954 of
  954); stamped_gen_param d/t stays CMP_NOTEQUAL. The firing census (frozen before the law sweep,
  evidence/predict.txt) predicted NO firing in the gate at all (an empty file; the positive control that the trace
  reaches through the harness: pass 306's R11U306_TRACE on tests/probe r10uvm79repro/c2_idxkind wrote its
  BARESEL/NESTSHAPE lines through scripts/check_probe.py, and this pass's own trace fires on 185 dirs of the
  firing scan). NO PROBE CONVERSION: none of the 70 residues is reached (pristine vs law over the 70 dirs in both
  views: 140 case-views, 0 moving).
- **Downstream:** IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 on both sweeps, both csvs
  byte-identical to results/downstream_uhdm2rtlil.csv.
- **The gain is outside the gate:** the residues passes 306 and 308 named first on this ground enter STRICT_EQUAL
  in both views: the path ending in a method call (v11u306repro VN/vn15, v11u308repro VK/vk02), the middle select's
  index under an lvalue base select (v11u308repro VD vd08 d, vd09 d/e, VX/vx26 d), the two cast shapes (VW vw11,
  vw12), the lvalue trailing-index naming (r11u306repro VH/h06), plus v11u308repro VS/vs21; 244 of this pass's 406
  grid case-views, 16 of the 3976 standard-control case-views and 13 of the 28 trigger-control case-views enter
  STRICT_EQUAL, none leaving, chain away 0 on every mover.

## The model

Surelog compiles the receiver of a method call written on a selected element (`r = iarr[h.k].get()`) through the
same `compileSelectExpression` (third_party/Surelog/src/DesignCompile/CompileExpression.cpp) as a member path's
element: the method call is the path's LAST element, so the receiver's select is a NON-TRAILING element and its
index is compiled in the path's element list (the shape § nonTrailIdxPathNestShape306 and its family model for
`iarr[h.k].f`). Ours builds such a receiver in a separate builder (ExprEmit's user-method deep-receiver branch,
`segs11`; the built-in method branch, `stepSel74`, for `.randomize()` and the array methods), which never raised the
non-trailing flags, kept the written index text in the path's name when the index held no `.`, and named a member
element's select by its own name. In an ASSIGNMENT TARGET, Surelog's lvalue branch hangs the index off the select and
stores no full name (golden reads the chain), which ours had right in module processes but not for a class
method's trailing select, a cast's typespec, or the middle select of a nested path the lvalue base select reshapes.
In a non-trailing select's index a package-qualified call is located from the package-scope node, `p::` (the form §
pkgQualCallQualSpan131 gives a parameter initializer), and a call in a conditional's TRUE branch keeps its whole
span (§ hpOpIdxTernTrueKeepsIdxLoc304v's model).

## The laws (src/ExprEmit.cpp)

`R11U310_OFF` drops all thirteen and gives pristine's bytes and exit code on 406 of 406 grid case-views.
`R11U310_TRACE=<dir>` logs every firing (`<TAG> <detail>`) and abstention or switch-off (`<TAG>_ABSTAIN`,
`<TAG>_OFF`) into `<dir>/<pid>.310`, its first line `OUT <-o path>`.

### § methTailIdxNestShape310 — `R11U310_METHTAIL_OFF` (the § nonTrailIdxPathNestShape306 wrapper in emitExpr; `methTailHp310`)

A member path in the index of a method-call receiver's select (`r = iarr[h.k].get()`, `iarr[h.k + 1].put(j)`,
`amap[h.k].get()`, `qq[h.k].get()`, `iarr[h.k].nx.get()`, `.randomize()`) takes pass 306's nested shape (golden `h`
9:16-17 on `k`, `k` with no full name; ours `h` 9:14-15, `k` `work@grid::probe::iarr[].get::k`), and with it pass
308's middle-select, leaf-select and indexed-part-select leaf forms. Both receiver builders name their path in
`methTailHp310()` around the index; the wrapper's climb must end at that path or at a select directly under it, a
conditional's true branch keeping the read shape. Not a with-clause or a randomize-with receiver (their path ends at
the select). Grid cases/MT, FX.

### § methRecvSelCallIdxDecompiled310 — `R11U310_METHIDXTEXT_OFF` (the deep-receiver branch's § dottedIdxRecvFromSyntax23 gate)

A SELECT, a USER CALL or (behind a macro) a member path written as a receiver element's index (`r =
iarr[midx[i]].get()`, `iarr[fn(i)].get()`, `` iarr[`IDX].get() ``) opens the gate a dotted index opens: the path's
name renders the decompiled index (golden `iarr[[i]].get`, `iarr[].get`; ours the written text, uhdm-cmp stage 1)
and the index hangs at the path. Cases mt31, mt32, mt59, mt60 (stage 1 -> STRICT_EQUAL), cd20.

### § methRecvElemCumName310 — `R11U310_METHRECVCUM_OFF` (the deep-receiver branch's element loop)

A MEMBER element's select under that gate is named by the receiver text up to it (golden `h.hh.arr[]` for `r =
h.hh.arr[hd.k].get()`, ours `arr[]`), as the written form already was. Cases mt09, mt35, mt40, mt44, mt48, mt51.

### § methIdxCallNameSpan310 — `R11U310_METHIDXCALL_OFF` (the call branch, `methIdxCall310`)

A call in a receiver element's index (`r = iarr[fn(h.k)].get()`, `iarr[i + fn(j)].get()`) spans its name, as §
hpIdxCallNameSpan184 does in a path's non-trailing index (golden `fn` 9:14-16, ours 9:14-21). Cases mt06, mt37,
mt70, fx02.

### § methIdxSelWholeByPath310 — `R11U310_METHIDXSEL_OFF` (the deep-receiver branch)

A SELECT written as the receiver element's index (`r = iarr[midx[h.k]].get()`) is named by the path and spans its
whole select (golden `work@grid::probe::iarr[].get::midx` 9:14-23, ours the scope's `work@grid::probe::midx` at its
index), § hpMidSelIdxAtPath79's receiver twin. Cases mt03, mt08, mt26, mt27, mt47, mt49, fx03, cd20.

### § methIdxNestSelWhole310 — `R11U310_METHNESTSEL_OFF` (the deep-receiver branch, after the index)

A select nested in that index, under an operation (`iarr[midx[i] + 1].get()`) or under the bare select
(`iarr[midx[midx[h.k]]].get()`), is named by the path and spans its whole select (§ hpOpIdxNestedSelByPath304 and §
nonTrailSelNestedSelWhole306's receiver twin), a call argument and a true branch keeping the index span. Cases
mt33, mt36.

### § methPathInIdxNameSpan310 — `R11U310_METHPATHSPAN_OFF` (the deep-receiver branch's path location)

A method-call path written in a non-trailing select's index (`r = iarr[iarr[h.k].get()].get()`, `r =
iarr[iarr[i].get()].f`, `r = h.arr[iarr[h.k].get()].f`) spans its first name (golden `iarr[].get` 9:14-18, ours the
whole call), a conditional's true branch keeping the whole call (mt68: the first draft moved its e view off
STRICT_EQUAL; fixed before measurement). Cases mt50, mt61, mt63, mt72, r11u195repro A/a02.

### § lvNestShapeMidIdxAtSel310 — `R11U310_LVNESTIDX_OFF` (the § nonTrailIdxPathNestShape306 wrapper)

An LVALUE path whose non-trailing select is on its BASE (`iarr[h.arr[i].f].f = r`, `always_ff
sa[u.a[i].k].f <= 0`) takes the nested shape, and there the nested path's middle select keeps its index at the
select as in the read form (§ hierPathSelIdxAtPath178's nested-path exception): golden `i` parented at `arr` and
named through both paths (`...::iarr[].f::h.arr[i].f::i`); § lvIdxMixedPathIsRead181 had hung it on the inner path,
whose chain skips that path. The index goes back to its select and a reference is named from the chain by pass
178's drain. Grid cases/LN (class, module process, task, generate, depth 3, implicit net, interface), FX/fx17, fx18.

### § castTsNestSelIdxByChain310 — `R11U310_CASTSELIDX_OFF` and § castTsLvIdxByChain310 — `R11U310_CASTLVIDX_OFF` (`castTsNonTrailIdx310`, design-final)

The cast shapes § castTsNonTrailIdxByChain308 and § castTsInPathIdxByChain296 do not reach: a cast in the index of
a select NESTED in a path select's index (`r = iarr[midx[int'(h.k)] + int'(j)].f`, golden `...::iarr[ + ].f::midx`;
the trailing twin `r = h.arr[1].g[midx[int'(i)]]`, golden `...::h.arr[1].g::g::midx`) and a cast in an ASSIGNMENT
TARGET's or an inc/dec operand's select index (`h.arr[int'(hd.k)].f = r`, golden `work@grid::probe::h.arr[].f::arr`,
ours `work@grid::probe.h.arr[].f`). Surelog stores no full name on a ref_typespec; ours is renamed to its chain
where the stored name and the chain both lie in the enclosing scope (computed with chainFullName175, the stored
name read with `storedFullName308`, never through UHDM's getter). Grid cases/CD, CL.

### § clsLvTrailIdxNamesByChain310 — `R11U310_CLSLVTRAIL_OFF` (`clsLvTrailIdxNames310`, design-final)

In a CLASS METHOD, the named objects inside an assignment target's TRAILING select index read their chain
(`h.idx[i + 1] = r`: golden `work@grid::probe::h.idx[i + 1]::idx::i`; `h.idx[midx[i]] = r`: the select
`...::h.idx[[i]]::idx::midx`; `+=`, `<=`, a conditional, a call, a cast, a var_select and a path's trailing
reference too); ours kept the method scope's `work@grid::probe::i` or the enclosing select's stored name. A module
process (§ lvSelIdxChainName181's drain), a reference directly under the select and an inc/dec operand were already
golden's and are untouched; only where the stored name is the scope's, or an enclosing select's stored name, plus
the object's own name. Grid cases/TL, CL, FX (package, nested, module, interface and parameterized classes, extern,
`this.`, macros from an include), r11u306repro VH/h06.

### § idxCallTernTrueKeepsSpan310 — `R11U310_CALLTERNTRUE_OFF` (the call branch)

A call in a conditional's TRUE branch inside a non-trailing index keeps its whole span (golden `iarr[c ? fn(i) :
j].f` 9:18-23, ours the name 9:18-20), the § hpOpIdxTernTrueKeepsIdxLoc304v twin for § hpIdxCallNameSpan184 (a
refinement of pass 184 behind this pass's switch). Cases mt71, qc14 (module, downstream EQUIVALENT -> IDENTICAL).

### § idxQualCallNameSpan310 — `R11U310_QUALCALLSPAN_OFF` (the call branch's `qualSpan131`)

In a non-trailing path select's index (rvalue or lvalue path, a method receiver too; not in a true branch) a
PACKAGE-QUALIFIED call spans its qualifier with the `::` (golden `p::` 7:14-17 for `r = iarr[p::f(i)].f`, 13:10-13
for `iarr[p::f(i)].f = r`, 18:22-25 for `always_comb r = sa[p::f(i)].f`; ours the package token `p`); a trailing
index, a plain read and a true branch keep the package token (cases/QC/qc16_survey measures all seven positions in
one file). Grid cases/QC, FX/fx08.

## Grid (cases/; drivers/gridall.sh, gridsum310.py, attrib310.sh, awaygrid.sh)

203 case dirs in both views (406 case-views; every line with its exit code; evidence/grid.txt, grid_summary.txt),
each case's first line naming its law (relabelled from the attribution where the restoring switch differed from the
draft label): MT (69, the method-call receiver), LN (32, the lvalue nested path), TL (31, the class lvalue trailing
index), CD (24) and CL (10) (the casts and lvalue indices), FX (22, the brief's mandatory shapes: class
specialization in an index, linked, forward and named calls, extern above and below, pure virtual, task, static,
foreach, package function, 2-D, string key, package / nested / module / interface / parameterized classes, macros
from an include, two-level and case generates, depth 3, `this.` and `super.` lvalues), QC (15, the qualified calls
and the true branch).

| group | case-views | moving | entering STRICT_EQUAL | leaving | STRICT_EQUAL after |
|---|---|---|---|---|---|
| CD | 48 | 28 | 26 | 0 | 40 |
| CL | 20 | 12 | 12 | 0 | 20 |
| FX | 44 | 40 | 30 | 0 | 32 |
| LN | 64 | 46 | 30 | 0 | 60 |
| MT | 138 | 114 | 98 | 0 | 116 |
| QC | 30 | 22 | 16 | 0 | 22 |
| TL | 62 | 32 | 32 | 0 | 62 |
| total | 406 | 294 | 244 | 0 | 352 |

- 0 exit-code changes; `R11U310_OFF` equal to pristine on 406 of 406 case-views.
- uhdm-cmp line counts change on 13 case-views: 10 from stage 1 to 0 lines (cd20, mt31, mt32, mt59, mt60 in both
  views: the receiver path's name now decompiled) and 3 at stage 1 on both binaries with the same first head
  (mt47 d/e 662 -> 660 and 706 -> 704, mt58 d 108 -> 106; the class-var and extern heads unrelated to these laws).
- Attribution (drivers/attrib310.sh, each mover rerun with each switch alone; evidence/grid_attrib.txt): 254 movers
  restored to pristine's bytes by exactly one switch (METHTAIL 72, CLSLVTRAIL 62, LVNESTIDX 50, QUALCALLSPAN 20,
  CASTLVIDX 16, CASTSELIDX 10, METHIDXCALL 8, METHPATHSPAN 8, CALLTERNTRUE 4, METHIDXTEXT 2, METHNESTSEL 2), 40
  needing two or more because one case fires several laws (METHIDXSEL with METHTAIL 14, METHRECVCUM with METHTAIL
  6, METHIDXSEL, METHRECVCUM and METHTAIL 6, METHIDXTEXT with METHTAIL 4, and five pairs of 2).
- The chain-keyed away census (drivers/awaygrid.sh, this pass's awaychain.py and strictcmp_x built by
  drivers/cc_x.sh): chain away 0 and flat away 0 on all 294 movers with 627 records toward golden by chain key
  (evidence/grid_away.txt); the positive control with the binaries swapped reads away on 12 of 12 sampled movers
  (evidence/away_poscontrol.txt). The movers with no record toward golden are byte-only (the LN e views equal on
  both binaries, a parent the strict walk does not key on) or at stage 1 on both (cd32, fx16).
- Downstream (drivers/dscases.py, both lanes) on the 25 module-scope case dirs: 21 IDENTICAL on both binaries,
  QC qc10, qc12, qc14 and qc16 EQUIVALENT -> IDENTICAL (the call's span is the src attribute the plugin reads);
  none worse (evidence/downstream_cases_*.txt).

## Controls

- Firing scans (drivers/firescan.sh, the law binary under `R11U310_TRACE` over 31555 fence-filtered dut.sv dirs
  under tools/probe and tests/probe; `VIEW=e` adds `--elabuhdm`): 185 dirs write a trace line in each view (157 of
  them this pass's, none under tests/probe; evidence/firescan_d.txt, firescan_e.txt).
- Crashes (drivers/crashscan.sh, the law binary over the same 31555 dirs): 1 dir exits 139 in the definition view
  (v11u112repro m07_hdr_enum_default) and 8 in the elaborated view (r10vrgg8repro v8_recurse, v8_recurse_mutual,
  v8_recurse_uncond, r11u254repro F/f04_class, r11u300repro RS/s22_recursion, m07_hdr_enum_default, v11u254repro
  F/vf02_iface, vf04_hier), each exiting 139 on pristine too (evidence/crashes.txt).
- Standard byte controls (drivers/controls.sh, both views) over every dut.sv dir of r11u118, r11v11u118, r11u119,
  r11u120, r11v120, r11u124, r11v124, r11u131, r11v131, r11u178, r11u181, r11u184, r11u190verify, r11u296, v11u296,
  r11u304, v11u304, r11u306, v11u306, r11u308 and v11u308 (3976 case-views): 24 moving, 16 entering STRICT_EQUAL
  (v11u306 VN/vn15, r11u306 VH/h06, v11u308 VK/vk02, VD vd08 d, vd09, VX/vx26 d, VS/vs21, VW vw11, vw12), 0 leaving,
  0 exit-code changes; chain away 0 on all 24 with 144 records toward golden (evidence/controls_std_summary.txt,
  controls_away.txt). Four uhdm-cmp line changes, all at stage 1 on both binaries: r11u296repro CI/ci05 d/e 156 ->
  1432 and 180 -> 1860 (the package listing's receiver `fl[ix[k]].rub` now golden's `fl[[k]].rub` byte for byte, so
  the first difference moved later to the import clone in package j, whose whole package uhdm-cmp prints; chain
  away 0, 36 and 67 records toward golden) and CI/ci11 d/e 160 -> 174 and 204 -> 190 (the same receiver face, away
  0). r11u308repro VO/vo08 moves bytes with no record either way.
- Trigger controls (drivers/controls_list.sh, both views) over the 14 firing dirs outside this pass and outside the
  standard controls (evidence/trigger_dirs.txt; 28 case-views): 22 moving, 13 entering STRICT_EQUAL (r11u191dec
  H/h03, r11u194verify C/c01, r11u215repro R/r03, r11u221verify R/r01, R/r03, v11u215repro OR/r07, v11u195repro
  A/a02 e), 0 leaving, 0 exit-code or uhdm-cmp changes; chain away 0 on all 22 with 30 records toward golden
  (evidence/controls_trigger_summary.txt, controls_trigger_away.txt).
- The firing census (drivers/tracecensus.sh, the law binary through the harness over the probe cases and both
  corpora in both modes, the four fenced tests excluded by the filter), frozen before the law sweep: no line
  (evidence/predict.txt is empty); its csvs read probe 4017 + 70 and the corpora 0/0/0 against the baselines, and
  the UVM rows (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg, Earlgrey_0_1, Rggen, both modes) were also
  run on two intermediate builds and read byte-identical to pristine.

## Gates (evidence/gates.txt, sweep_P.log, sweep_L.log)

Both sweeps `tests/sweep.sh --jobs 3` from the worktree with SLANG_UHDM exported; each exits 1 on the law-index
check alone (tests/LAWS.md is regenerated last, by scripts/law_index.py).

- probe: pristine 4017 + 70, law 4017 + 70; regressions 0, conversions 0, changes 0 on both.
  After tests/LAWS.md was regenerated, `tests/sweep.sh --corpus probe` on the law binary exits 0 (4017 + 70, 0/0/0).
- surelog: 480 + 0 / 474 + 0 on both, regressions 0, conversions 0, changes 0; the csvs differ only in the LowMemLib
  and LowMemPkg testflags detail text, which names the workdir.
- uhdm2rtlil: 803/1/67 in both modes on both, regressions 0, conversions 0, changes 0; csvs identical.
- downstream: 803/66/2/0 on both, both csvs byte-identical to results/downstream_uhdm2rtlil.csv.
- uhdm-cmp: 0 lines on every row the sweeps read CMP_EQUAL, as at the base (no row status moved).
- byteverify (tools/probe/r11v75repro/byteverify.sh on fence-filtered mirrors built by drivers/mirror.sh; workdir
  names of equal length): 0 of 3365 corpus and downstream-lane databases moving, and a cmp loop over the 4087 probe
  databases: 0 moving. Predicted: the census's empty list. SELFCHECK reads 3363 of 3365: the reference is the first
  sorted path, downstream/1DUnpackedArray/slang.uhdm, byte-identical to its twin
  uhdm2rtlil/testflags/1DUnpackedArray-*/slang.uhdm (the same test with the same arguments), so the reference and the
  twin are the two unflagged files; every other file is flagged, so the comparator works.
- canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 and 6).
- binary-path audit (drivers/audit.sh): pristine sweep own 3265 other 0, law sweep own 3265 other 0 (50 cmds.txt run
  no slang; the 8 fenced row-modes skipped by name).
- determinism (drivers/det.sh): three concurrent draws per row-mode of Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes read one hash each, equal to the law sweep's and to the
  pristine sweep's (evidence/determinism.txt; Scoreboard and Rggen testflags write no database, as at the base).

## Residues (ranked; all wrong on pristine too, none moved away)

1. **A path nested in a non-trailing index** (`r = iarr[iarr[i].get()].f`, mt61 d; `iarr[h.arr[j].get() + 1].f`,
   mt62; `iarr[iarr[p::f(i)].k].f`, qc08; mt66, mt68 d): golden names the inner path's index reference by the OUTER
   path only (`...::iarr[].f::i`, the inner path skipped), where ours stores `...::iarr[].f::iarr[i].get::i` (the
   receiver builder's index prefix); qc08's plain inner path `iarr[].k` spans its first name in golden (8:14-18,
   ours the whole path: the § methPathInIdxNameSpan310 twin for emitMixedHierPath paths); mt62 golden places the
   inner base `h` at a zero-width 9:15-15. This ground's (ExprEmit); the next law.
2. **The lvalue and trailing forms of a method path in an index** (`iarr[iarr[i].get()].f = r`, mt65;
   `h.idx[iarr[i].get()]`, mt67): endcol on both binaries, golden spans not decoded.
3. **A forward-declared class method called in an index** (`iarr[fwd(h.k)].get()`, fx02; `iarr[fwd(i)].f`):
   golden spans the name, ours the whole call (§ hpIdxCallNameSpan184 is not reached by that call's branch).
4. **A call argument's ref_typespec in a module's non-trailing index** (`sa[p::f(i) + 1].f`, qc10: golden
   `work@top.sa[ + 1].f.i`, ours `work@top.i`).
5. **Stage 1 on both binaries, heads unrelated to these laws:** mt44 (a module's class_var), mt47, fx03, fx16
   (extern), mt57 (a parameterized class's constant), mt58, fx22 (`super.`), fx01 (a class specialization's
   localparam), fx09 (2-D), ln22 (`this.` lvalue base), ln37 and cd33 (interface bodies), cd32 and qc13 (generate
   blocks), cd06 (`signed'`), cd07 (a typedef cast), qc07 (`p :: f` with blanks), mt27 and mt49 (the nested path's
   own text `h.idx[]` in a receiver index).
6. **The 70 probe residues** at the base: none moves in either view on this binary (140 case-views, 0 moving). This
   ground's among them stand as pass 308 listed them: t12, r11v21repro/v15, vh_arrelem, r11v4repro/v6, l_concat
   and the four r11u109 64-bit value cases (a Surelog defect).
7. Pass 308's other residues stand: the port-connection bare select's second listing (v11u306repro VB/vb14), the
   macro-born bare selects (vb12, vb16, NS/m19, VN/vn19), the escaped member span (vd17).

## Sister-ground faces (reported, not written)

- None new is reached by this pass's grid. The faces passes 306 and 308 listed (TypeEmit emitSyntaxExpr called from
  ModuleEmit emitDefGenStmts for a definition-view generate statement's index; ModuleEmit's interface port net
  ref_typespec and interface instance listing; TypeEmit's interface-body struct typespec end; UhdmExporter /
  TaskFuncEmit's package-function formal typedef stretch) stand unchanged.

## Process

- Worktree /tmp/wt_r11u310 at 50288747, scratch /tmp/r11u310_*; built with -j 2 (one comment-only rebuild with -j 1,
  byte-identical to the frozen law binary); the pristine binary frozen before any edit, md5 equal to the main tree's
  build/slang-uhdm. Drivers copied from tools/probe/r11u308repro/drivers (renamed to R11U310 / r11u310); new:
  attrib310.sh (this pass's switches) and gridsum310.py (renamed copies of pass 308's).
- THE FENCE: every driver reads $FENCED fail-closed (four names) from tools/probe/r11u107repro/canaudit.sh; every
  path list is built and filtered before any file is opened; byteverify ran on fence-filtered mirrors; the census
  filter excludes the four fenced tests by exact name; the fence scan of this directory reads 0 files for each of
  the four names.
- The law binary changed during development (each draft measured on this pass's own grid only); every measurement
  in this README is on the final binary 13561334707cdac7bce3d7f66b3b8481, including the census, which ran on it.
- SLIPS, no effect: (1) one wait loop used a `pgrep -f` pattern that could match its own command line; it was
  stopped as this session's own background task before it could hang, nothing was killed, and the census it
  waited on was then awaited by its output file. (2) The first draft of § methIdxCallNameSpan310 reused pass 184's
  flag and moved MT/mt69 (`iarr[c ? fn(i) : j].get()`) off STRICT_EQUAL; the receiver got its own flag and the
  true-branch rule (§ idxCallTernTrueKeepsSpan310) before any gate measurement. (3) The first draft of §
  methPathInIdxNameSpan310 moved MT/mt68 e off STRICT_EQUAL (a true branch); fixed the same way. (4) The first draft
  of § idxQualCallNameSpan310 spanned `p::f` where golden spans `p::`; decoded from a one-file survey (QC/qc16)
  before measurement. (5) One draft case (an assignment to an unpacked struct array element in a continuous
  assignment) was not legal SV and was dropped. No other agent's process, worktree or file was touched; nothing
  was written to the main tree.
- No patch file in this directory; the delivery /tmp/r11u310.patch is transport only.
