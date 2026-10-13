# v11u308 — adversarial verification of r11u308 (expression/parameter ground: the non-trailing select index)

Verdict: **ACCEPT, no production change.** Every headline number of r11u308 reproduces bit for bit on binaries
built here, and 181 fresh case dirs (362 case-views) found no case on legal SystemVerilog where pristine was right
and the law wrong. The verified patch carries the implementer's src/ExprEmit.cpp and src/ParamEmit.cpp
byte-identical, plus this directory and the regenerated tests/LAWS.md.

Base 1e7861ae. Worktrees /tmp/wt_v11u308pris (pristine) and /tmp/wt_v11u308 (the implementer's patch, which applies
cleanly). Both were built with `-j 2` (system-deps config) and copied with chmod 555 to /tmp/v11u308_bin before
any measurement was taken:

- pristine 6601ed32792b4a1efb137251e23c6ff3 (the md5 the brief names for the main tree's build at the base)
- law 1d2cda96ada1427527d37238c3937c5c (the implementer's)
- both report slang 12.0.0+545f88b2e

The patch adds no src/R*.h, no getenv and no reader of its own. Every switch is read through src/LawSwitch.h
(`lawOn(308, ...)`, `lawTrace(308, ...)`). The state is static in ExprEmit.cpp. Each `(UHDM::ref_obj*)` cast on a
bit_select, part_select or indexed_part_select is sound, because all three derive from ref_obj in UHDM 1.87.

## Reproduction (evidence/)

- **Gate sweeps** (`tests/sweep.sh --jobs 3`, both run from the law worktree with SLANG_UHDM exported;
  sweep_P.txt and sweep_L.txt):
  - probe: 4017 EQUAL + 70 STRICT_NOTEQUAL on both binaries; regressions 0, conversions 0, changes 0.
  - surelog: default 480 + 0, testflags 474 + 0; 0/0/0.
  - uhdm2rtlil: 803/1/67 in both modes; 0/0/0.
  - downstream: 803/66/2/0; both csvs are byte-identical to results/downstream_uhdm2rtlil.csv once sorted.
  - csv row diff, law vs pristine: probe 0 lines, uhdm2rtlil 0, surelog 4. The four surelog lines are the
    LowMemLib and LowMemPkg testflags SURELOG_FAIL detail text, which names the workdir.
  - The pristine sweep exits 0. The law sweep exits 1 on the law-index check alone, because this directory's
    cases were added while it ran; the index is regenerated in the patch.
- **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered mirrors of /tmp/v11u308_wdL
  and /tmp/v11u308_wdP; the two workdir names have equal length; 7452 files mirrored, 8 fenced paths skipped):
  - MOVERS 0 of 3365; probe databases 0 of 4087.
  - SELFCHECK reads 3363 of 3365. The reference file is the first sorted path,
    downstream/1DUnpackedArray/slang.uhdm (md5 349c99c5b21c). It is byte-identical to
    uhdm2rtlil/testflags/1DUnpackedArray-3af704bd/slang.uhdm, so the reference and its twin are the two
    unflagged files and the comparator does work.
- **Canaries:** surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. ctcan2 PASS with EXPECT_UNKNOWN=1 and with
  EXPECT_UNKNOWN=6.
- **Binary-path audit** (drivers/audit.sh): both sweeps read own=3265, other=0, noslang=50, fenced_skipped=8.
- **Firing census** (drivers/tracecensus.sh, law binary under R11U308_TRACE, filter built from $FENCED;
  census_predict.txt): exactly one firing, `surelog LocalScopeHierPath/testflags ELABCLSIDX:1`, the implementer's
  prediction. Its database is byte-identical on both binaries, matching byteverify's 0 movers.
- **Determinism** (drivers/det.sh; three concurrent draws each of Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg and Rggen in both modes; determinism.txt): every row-mode gives one hash in 3 of 3, equal
  to both sweeps' databases and to the implementer's hashes. Scoreboard and Rggen testflags write no database, as
  at the base.
- **The implementer's grid** (210 dirs, 420 case-views; its drivers/gridall.sh run with this pass's binaries and a
  private golden cache; repro_grid.txt): equal to evidence/grid.txt on 1260 of 1260 lines in every field except
  the md5, which embeds the worktree path.
  - 271 moving, 241 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.
  - The per-group table matches line for line.
  - uhdm-cmp line counts change on the same 5 case-views.
  - R11U308_OFF gives pristine's bytes on 420 of 420.
- **Grid attribution** (attrib308.sh; repro_grid_attrib.txt): equal to evidence/grid_attrib.txt on all 271 lines.
  214 movers are restored by exactly one switch:

  | Switch | Movers |
  |---|---|
  | ELABCLSIDX | 47 |
  | NESTMIDSEL | 42 |
  | CASTNTIDX | 32 |
  | LVMEMSEL | 22 |
  | VSHPOP | 22 |
  | IPSLEAF | 21 |
  | NTIDXCHAIN | 10 |
  | NESTVARSEL | 8 |
  | BAREIPS | 7 |
  | LVIDXCHAIN | 2 |
  | LEAFSELELAB | 1 |

  The other 57 need two or more switches.
- **Grid away census** (awaygrid.sh with strictcmp_x rebuilt by cc_x.sh; repro_grid_away.txt): chain away 0 and
  flat away 0 on all 271 movers, with 638 records toward golden.
  - Positive control, binaries swapped, on 12 sampled movers: away on 12 of 12 by both keys
    (away_poscontrol.txt).
- **Controls over the whole probe tree instead of a sample.** drivers/bytescan.sh (new) runs both binaries on every
  fence-filtered dut.sv dir under tools/probe and tests/probe and compares database md5s, so a law that moves
  bytes without a trace line is seen too: BAREIPS's reach-test change carries no trace of its own.
  - Default view: 31186 dirs, 196 moving.
  - Elaborated view: 31201 dirs, 361 moving.
  - No exit-code change in either view. The two pristine segfaults are on dirs that also crash under the law.
  - Outside r11u308repro and this directory, 137 case-views move. All 137 are in earlier passes' repro dirs or
    tests/probe; their verdicts and away census are in controls_movers_*.txt: 94 enter STRICT_EQUAL, 0 leave,
    0 exit-code changes, chain away 0 and flat away 0 on all 137, 326 records toward golden.
  - The two uhdm-cmp line changes are r11u306repro NP/np17_varsel d/e (190 -> 188 and 230 -> 228), at stage 1 on
    both binaries.
  - Under tests/probe the default view (the gate's view) moves 0 dirs. The elaborated view moves 2:
    r10uvm79repro c2_idxkind e and v79v2_recv e, both entering STRICT_EQUAL, which is the implementer's
    trigger-control finding.

## The attack (cases/, 181 dirs, both views; fresh_grid.txt, fresh_away.txt, downstream_fresh.txt)

Every case's first line names the law it attacks. Each case-view is measured with pristine, law and
law+R11U308_OFF, and every line carries its exit code.

| group | what | case-views | moving | entering STRICT_EQUAL | STRICT_EQUAL after |
|---|---|---|---|---|---|
| VC | § elabClsNonTrailIdxUnstored308 class contexts: property initializer, constraint, covergroup, nested class, static and extern methods, derived parameterized class, fork, program class, module class, foreach variable, locals, formals, class-scoped static, enum, $size, $clog2, this., super., if/while, $display, randomize-with, declaration initializers, for/case/repeat, nested non-trailing selects, interface class, pkg::K | 68 | 26 | 19 | 50 |
| VD | § nonTrailIdxIpsLeaf308 / § bareSelIdxIpsWhole308 (-: forms, operation bases, lvalues, class) and § nestPathMidSelShape308 (module, two-deep, lvalue base, always_ff, 2-D and part-select leaves, conditional, inc/dec), § varSelIdxOpHpLeafByPath308 and § nestShapeThroughVarSel308 in modules | 32 | 30 | 23 | 25 |
| VM | module contexts of the naming laws: always_comb, always_ff, compound, task, for, initial lvalues; continuous-assignment left sides; net declaration; port; module function; generate; package and struct indices; interface member index; $unsigned | 36 | 0 | 0 | 23 |
| VT | § castTsNonTrailIdxByChain308: procedural lvalue, signed', typedef, nested casts, cast in a select, always_ff, class read and lvalue, package typedef, for-generate, two casts, $bits | 24 | 18 | 12 | 14 |
| VX | the brief's mandatory shapes: implicit net, interface body, class specialization in the index, this. paths, linked and unlinked named calls, extern above the caller, pure virtual, macros from an include in a class and in a module, if/case/two-level generates, depth 3, streaming lvalues, inc/dec with unary and call indices, concatenation, part-select, inside, conditional, associative, queue and dynamic indices, output arguments, nonblocking | 60 | 21 | 13 | 37 |
| VA | § nonTrailIdxRvalueOnly308's edges: concatenation left side, output-port actual, part-select left side, delayed assign, streaming left side, always_ff, initial, variable left sides, force/release, net declaration, read concatenation | 28 | 2 | 0 | 3 |
| VK | read paths ending in a method call (`iarr[i + 1].get()`, `.size()`, `.randomize()`, associative `m[key].get()`; the UVM face of § lvNonTrailIdxNamesByChain308's first draft) | 10 | 3 | 1 | 5 |
| VL | § nonTrailIdxReadLeafByChain308 in modules (conditional, call, system call, condition, concatenation, leaf select), class three-deep paths, middle-select indexed part-select leaf, hierarchical index, module-function index, indexed part selects under calls and true branches, var_select lvalues and operations | 30 | 14 | 5 | 16 |
| VS | § lvMemberSelIdxKeepsRead308 outside plain assignment (output argument, streaming, nonblocking, for-initializer, compound, module struct-member lvalues), struct arrays in classes, a virtual interface, a class-scoped static, a package variable, program, interface and package functions, two-deep middle selects, cast in a member, typedef and ternary, port, always_comb, net declaration | 44 | 28 | 19 | 25 |
| VW | 2-D struct arrays, $bits of a path, a non-trailing select inside a non-trailing index (module and class, read and lvalue), an interface port, a parameterized child, a case-generate lvalue, cast in an always_ff lvalue, deep and lvalue cast indices, struct-member and enum casts, var_select under a conditional | 30 | 12 | 5 | 12 |
| total | | 362 | 154 | 97 | 210 |

- 0 leaving STRICT_EQUAL and 0 exit-code changes.
- R11U308_OFF gives pristine's bytes on 362 of 362 case-views.
- Away census: chain away 0 and flat away 0 on all 154 movers, with 457 records toward golden.
- uhdm-cmp line counts change on 6 case-views, all at stage 1 on both binaries with the same first difference:
  VD/vd03_ipsleafop d/e 186 -> 188 (the printed object gains its definition name), VD/vd16 d/e 254 -> 252 and
  VW/vw15 d/e 266 -> 264 / 314 -> 312.
- Downstream (drivers/dscases.py, both lanes, on the 92 dirs with module content): 80 IDENTICAL on both binaries.
  VD/vd01_ipsminus goes EQUIVALENT -> IDENTICAL; no verdict gets worse. EQUIVALENT on both: va01, va02, vl12.
  DIVERGENT on both: va03_partsel and va10_varlhs_concat, both on pristine too, at stage 1. SLANG_REJECT on both:
  va11, va12, vm03, vw02. SURELOG_FAIL: va05, vw13.
- Every pristine-to-law mover that stays STRICT_NOTEQUAL moves toward golden only. The new heads:
  - vd08 d, vd09 d/e and vx26 d (col -> fullname): **the index of a middle select under an LVALUE base select**
    (`iarr[h.arr[i].f].f = r`, `always_ff sa[u.a[i].k].f <= 0`). Golden names `i` through the middle path
    (`...::iarr[].f::h.arr[i].f::i`); ours keeps an earlier law's `...::iarr[].f::i`. The read forms (vd07, vs15)
    enter STRICT_EQUAL, and the class elaborated view is right through ELABCLSIDX.
  - vt09 (fullname -> name): pkg::n_t' casts, the sister's typedef name face.
  - vx10 (fullname -> col): a macro index in a module.
  - vl12, vl14 (fullname -> col).
  - vs22 d (fullname -> depth): the next pre-existing record.
  - vc13 e (fullname -> endcol).

## Residues (ranked; all wrong on pristine too, none moved away)

1. **A middle select's own index under an lvalue base select** (VD vd08 d, vd09 d/e, VX/vx26 d). The rvalue
   rename of § nestPathMidSelShape308 does not reach the lvalue path's index chain. This ground's (ExprEmit),
   the twin of the read form the law covers.
2. **A cast nested inside a select in a non-trailing index** (`iarr[midx[int'(h.k)] + int'(j)].f`, VW/vw11) and
   **a cast in an lvalue's non-trailing index** (`h.arr[int'(hd.k)].f = r`, VW/vw12: golden
   `work@grid::probe::h.arr[].f::arr`, ours `work@grid::probe.h.arr[].f`). castTsNonTrailIdx308 climbs operations
   and calls only, and only for the rvalue form.
3. **The implementer's residues stand as listed in tools/probe/r11u308repro/README.md:** VN/vn15
   `iarr[h.k].get()`, VB/vb14, the macro-born bare selects, vd17, VH/h06, the stage-1 shapes and the 70 probe
   residues. My VK/vk02_methtail_path (`iarr[h.k + 1].get()`, col on both binaries) is a second witness of their
   residue 1.
4. **Stage 1 on both binaries** (the hier_path's own text or an unrelated head): property initializers vc01,
   randomize-with vc23, interface class vc29, pkg::K indices vc30 and vm12, extern methods vc34 and vx07, super.
   vc20, this. vx04, class specialization vx03, generate-local classes vx18, 2-D and nested-non-trailing module
   reads vm11 and vw03, an interface index vm16, an interface port vw07, signed' vt02, $bits vt12, nested casts
   vt04, if-generate vx11, interface bodies vx02 d, program, interface and package functions vs11, vs12 d and
   vs13, package variables vs10, var_select lvalues vl13 and vd16, the CA edges va01, va03, va10 and va13.
5. **Exit 3 or 4 on every binary, or no golden:**
   - vc33 (static method with an item[] formal; exit 3)
   - vk03 (`.size()` on a member array; exit 3)
   - vm03, va11, va12, vw02 (exit 3)
   - vc03 (covergroup; exit 4)
   - va05, vl15, vw13 (Surelog writes no database)

## Sister-ground faces (reported, not written)

- **Generate-scope names** (VM/vm09_genfor, VX/vx12_gencase: fullname on both binaries; VA/va07): TypeEmit
  emitSyntaxExpr called from ModuleEmit emitDefGenStmts. This is the implementer's EC ec40-ec42 face.
- **The port-connection index's depth face** (VM/vm06_port d): ModuleEmit, the VB/vb14 family.
- **The interface body's typespec endline** (VX/vx02 e, VS/vs12 e, VS/vs08 d): TypeEmit, the np39 / vn41 face.
- **The package function's line face** (VS/vs13): UhdmExporter / TaskFuncEmit, § tfArgTypedefLastWriter146's
  family.

## Process

- **Fence:** every driver reads $FENCED fail-closed from tools/probe/r11u107repro/canaudit.sh. bytescan.sh builds
  its path list and filters it by word boundary before any file is opened, and the mirrors skip the 8 fenced
  paths. The fence scan of this directory reads 0 files for each of the four names.
- **Drivers** are copied from r11u308repro/drivers with the scratch prefix changed to /tmp/v11u308_*. New:
  bytescan.sh. Golden cache /tmp/v11u308_gold (private).
- **No source edits.** No src edit was made in either worktree, so no rebuild happened.
- **SLIPS, no effect:**
  1. A first attribution run read gridsum.py's `MOVER c v: verdict` lines, where attrib308.sh expects
     gridsum308.py's `MOVER c v:`. It produced garbage switch names, was discarded, and was rerun from
     gridsum308.py's list; the rerun matches the implementer's on 271 of 271.
  2. One of my wait loops used a pgrep -f pattern that also matched its own shell's command line, so it could
     never end. It was stopped as my own background task. It only waited and killed nothing; the census it waited
     on had already finished.
- No other agent's process, worktree or file was touched, and nothing was written to the main tree.
