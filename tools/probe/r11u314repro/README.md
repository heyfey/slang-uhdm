# r11u314 — pass 314, expression/parameter ground: the `this.` select in an lvalue index, named-block lvalue index names, the indexed-part-select base renders and names, the package-qualified width, a static class call as a trailing index, and the built-in and plain-element spans of a method path in an index

Pair A, refill after pass 312. Base e18396e3 (pass 312 on top of pass 317). Production surface: src/ExprEmit.cpp
only. It holds nine laws. There is no src/R*.h, nothing in src/LawState.h, and no getenv or reader of this pass's
own. Every switch is read through src/LawSwitch.h (`lawOn(314, ...)`, `lawTrace(314, ...)`).

- Pristine build md5 4b092c61f9f3d041af67fb9ffdc4d985, equal to the main tree's build/slang-uhdm at the base.
- Law build md5 31f5e27212d0045027a74221de9cc109.
- Both binaries were frozen (chmod 555 copies under /tmp/r11u314_bin) before any counted measurement, and both
  report slang 12.0.0+545f88b2e.
- Every cmds.txt of both sweeps names its own binary (evidence/gates.txt).

## Verdict

- **No corpus row and no probe case moves**, in status or in bytes.
  - probe: 4017 EQUAL + 70 STRICT_NOTEQUAL on both binaries; regressions 0, conversions 0, changes 0.
  - surelog: default 480 + 0 and testflags 474 + 0; regressions 0, conversions 0, changes 0.
  - uhdm2rtlil: 803/1/67 in both modes; regressions 0, conversions 0, changes 0.
  - byteverify: 0 of 3365 corpus and downstream-lane databases moving, and 0 of 4087 probe databases.
  - Every Surelog row-mode stays CMP_EQUAL (954 of 954), and stamped_gen_param d/t stays CMP_NOTEQUAL.
  - The firing census (frozen before the law sweep, evidence/predict.txt) predicted NO mover: its 16 lines are all
    `IPSBASEOP_SAME_ABSTAIN` (a re-rendered name equal to the written one: `rw.value[8 * i+:8]`), which moves nothing,
    and they are its positive control (the trace written through the same harness).
  - NO PROBE CONVERSION: none of the 70 residues moves (pristine vs law over the 70 dirs in both views: 140
    case-views, 0 moving; evidence/residues70_grid.txt).
- **Downstream:** IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 on both sweeps. Both csvs are
  byte-identical to results/downstream_uhdm2rtlil.csv.
- **The gain is outside the gate.** The residues passes 310 and 312 named on this ground enter STRICT_EQUAL in both
  views:
  - v11u312repro VT/vt13 and vt17 (the `this.` path through a select in an lvalue index), VX/vx09 (the module task's
    named block), VQ/vq02, vq06 and vq07 (the member-receiver column and the built-in method span), VP/vp22 (`+: p::N`),
    VP/vp30 (the generate-block base name), VP/vp15, VP2/vp41 and vp43 (the base renders and the names inside the base);
  - r11u312repro IP/ip11 (`+: p::N`), IP/ip25 and ip26 (the operation and system-call bases), MS/ms02
    (`h.idx[item::sget()]`), MI/mi12 (the zero-width member column) and r11u310repro MT/mt62;
  - and four earlier dirs: r11u296repro CT/ct13 and ct14, v11u296repro VT/vt10, v11u308repro VD/vd03.
  - Totals: 318 of this pass's 450 grid case-views and 42 of the 5820 standard-control case-views enter STRICT_EQUAL.
    None leaves, and chain away is 0 on every mover.

## The model and the laws (src/ExprEmit.cpp)

`R11U314_OFF` drops all nine laws and gives pristine's bytes and exit code on every grid case-view.
`R11U314_TRACE=<dir>` logs every firing (`<TAG> <detail>`) and every abstention or switch-off (`<TAG>_ABSTAIN`,
`<TAG>_OFF`) into `<dir>/<pid>.314`, its first line `OUT <-o path>`. Every switch is read through
src/LawSwitch.h (`lawOn(314, ...)`). The pass adds no src/R*.h file, no src/LawState.h section and no getenv; the one
piece of state kept between emitter calls (the stamped width references of § pkgQualIpsWidthSpanQualifier314) is a
static vector inside ExprEmit.cpp, drained from `nonTrailIdxDrain308` after `ipsBaseNames312`, so ParamEmit's drain list
is unchanged.

### § lvIdxThisSelPathIsRead314 — `R11U314_THISSEL_OFF` (`emitThisPathSelectErased`)

A `this.` path carrying a select, written inside an assignment target's select index, is a read. Examples:
`ia[this.ia[this.i]] = r`, `ia[this.i[1:0]] = r`, `h.idx[this.ia[i]] = r`, `ia[this.ia[i] + 1] = r`,
`lv[this.ia[i] +: 2] = 0`, `{ia[this.ia[i]], r} = 2`, `ia[this.ia[i]] <= r`. Golden spans the hier_path over the
whole written select (`this.ia[this.i]` 14:8-23) and keeps each member at its own token with a bare name; ours took
the lvalue form (the hier_path on `this` 14:8-12, the member loc-less and named `work@grid::probe::ia::ia`). This is
pass 312's § lvIdxThisPathIsRead312 for the builder that erases the select (`emitThisPathSelectErased`), whose gate it shares
(lvIdxParent154: the path's parent is a select, directly or through operations). A postfix inc/dec operand
(`ia[this.ia[i]++] = r`) spans the whole select with the members loc-less (golden 12:8-18); a prefix one keeps the
lvalue form, already golden's (`ia[++this.ia[i]] = r`, TS/ts09). v11u312repro VT/vt13 and vt17 (pass 312's verifier
residue 2). Cases: cases/TS.

### § tfLvTrailIdxNamedBlkScope314 — `R11U314_NAMEDBLK_OFF` (`clsLvTrailIdxNames310`'s stored-name gate)

Pass 310's and 312's lvalue trailing-index naming (CLSLVTRAIL, MODTF, PKGTF, CONCATLV) takes a name ours stored under a
NAMED BLOCK of the subroutine (a named begin or fork between the target and the subroutine), as well as the
subroutine's own scope. Example: `task t(input int i); begin : b int j; j = i; h.idx[j + 1] = 0; end endtask` gives
golden `work@top.t.b.h.idx[j + 1].idx.j`, ours `work@top.t.b.j` (v11u312repro VX/vx09, pass 312's verifier residue 3).
It reaches module, interface and program tasks and functions, generate-block subroutines (one and two levels, if and
case generates), instance depth 3, two instances, class methods and fork blocks, nested named blocks, a name declared
in an outer named block, an unnamed inner block, `+=`, a concatenation target, a select, cast and call index. A module
process (§ lvSelIdxChainName181's) and a for-loop's variable stay as they were. Cases: cases/NB.

### § ipsBaseOpSysRender314 — `R11U314_IPSBASEOP_OFF` (`hpIdxBaseHierPathEmpty94`, helper `dhRender314`)

Surelog composes a hier_path's name with CompileHelper::decompileHelper, a closed dispatch on the index object's UHDM
type. Pass 94 and pass 312 transcribed the rows for a hier_path, a bit_select with a constant or reference index and a
func_call written as an indexed part select's base. This law transcribes the rest, on the UHDM object, calling UHDM's
own `ExprEval::prettyPrint` for the operation row as Surelog does:
- an operation base renders its prettyPrint (`r = h.v[ia[i] + 1 +: 2]`: golden `h.v[ + 1+:2]`, the bit_select operand
  having no prettyPrint row);
- a bit_select base whose index is an operation renders `[` + prettyPrint + `]` (`h.v[ia[i + 1] +: 2] = 0`: golden
  `h.v[[i + 1]+:2]`, ours the written `h.v[ia[i + 1]+:2]`; r11u312repro IP/ip25), and one whose index is a call, a
  system call, a path or a cast renders empty (`h.v[ia[$clog2(i)] +: 2]`: golden `h.v[+:2]`);
- a system call, a method call or any other kind with no row renders empty (`h.v[$clog2(i) +: 2] = 0`: golden
  `h.v[+:2]`; r11u312repro IP/ip26);
- a part select and an indexed part select render their bracket text.
A reference or constant base keeps pristine's text (a folded constant's name is a pre-reduction fossil in golden,
§ hpIdxBaseHierPathEmpty94's calibration). The object render may only drop or re-space what the name's text already
holds: every identifier it writes must stand in pristine's bracket text. Where the text renderer had substituted a
parameter's value (an elaborated generate scope's `q[i].a_source[IDW-1-:STIDW]`, golden `8 - 1`, our operand still a
ref_obj `IDW`), the render abstains (`IPSBASEOP_ABSTAIN`) and pristine's text stays: v11u264repro VG/vg07, where a
first build moved 4 and 8 chain records away in the two views while staying at stage 1 (found by the trigger controls,
fixed and remeasured before delivery; IO io37 to io40 are its cases). An empty bracket body (`h.v[]`, a macro-born
base whose text the renderer could not read) substituted nothing and takes no gate (IO io34, io42, io43; a second build
had gated it and lost io34). prettyPrint dereferences operands unchecked, so
the render also abstains when an operation below the base has a missing operand. A render equal to the written text
moves nothing and is traced `IPSBASEOP_SAME_ABSTAIN` (every corpus firing is of this kind). Cases: cases/IO.

### § ipsBaseNamesReach314 — `R11U314_IPSBASENAME_OFF` (`ipsBaseNames312`)

Pass 312's § ipsBaseNamesByChain312 reaches the shapes the render above now renders. An operation base and a system
call's arguments are walked; a name ours stored under an enclosing select of the base, under a named block between the
select and its scope, or the ref_typespec of a cast or of a folded constant stored with the scope's or the select's
name, reads its chain as golden
does (`h.v[ia[i + 1] +: 2]`: golden `work@grid::probe::h.v[[i + 1]+:2]::v::ia::i`, ours `work@grid::probe::ia::i`;
`work@top.a.v[[k + 1]+:2].v.ix.k` at module scope; a generate block's `a.v[ix[k] +: 2]` golden
`work@top.g.a.v[[k]+:2].v.ix`, ours `work@top.g.ix`, v11u312repro VP/vp30). A path written inside the base's select
index names its trailing reference by its chain (`h.v[ia[h.k] +: 2]`). Cases: cases/IO.

### § ipsBaseInnerNamesFollowRender314 — `R11U314_IPSINNER_OFF` (`hpIdxBaseHierPathEmpty94`)

When a path's name is re-rendered, the objects inside the indexed part select's base and width whose full names were
frozen through the old text take the new text, as § lvIpsNameFollowsHpRender312 does for the select itself:
`h.v[h.hh.idx[i] +: 2] = 0` gives golden `work@grid::probe::h.v[+:2]::v::h.hh.idx[i]::idx`, ours
`...::h.v[h.hh.idx[i]+:2]::v::h.hh.idx[i]::idx` (v11u312repro VP2/vp43); `h.v[lv[3:0] +: 2] = 0` gives golden
`...::h.v[[3:0]+:2]::v::lv`. Only the old text standing whole between separators, once, is replaced. Cases: cases/IN.

### § trailIdxStaticScopedCallName314 — `R11U314_SCOPEDCALLIDX_OFF` (the trailing-select name composer, § hpTrailSelIdxDecompiled89's site)

A static class method reached through `::` with its body in the class (`item::sget()`) is § staticScopedCall12's bare
ref_obj named `<first segment>::<final identifier>`, so decompileHelper's reference row renders that name. As a
trailing select's index golden names the hier_path `h.idx[item::sget]` and the select `...::h.idx[item::sget]::idx`;
ours dropped the group as for a call (`h.idx`; r11u312repro MS/ms02, uhdm-cmp stage 1), rvalue and assignment target
alike. Arguments are dropped (`item::sget2(i)` renders `item::sget2`), a class specialization renders the class
identifier (`item#(2)::sget()` renders `item::sget`), a package class keeps its written first segment. An out-of-body
method (which may keep a func_call, § classScopeCallOfOutOfBodyMethodIsFuncCall26) is left alone, and so is a
non-trailing select's index (`iarr[item::sget()].f`, where golden keeps a func_call; v11u312repro VS/vs02). Cases:
cases/SC.

### § pkgQualIpsWidthSpanQualifier314 — `R11U314_PKGIPSW_OFF` (§ pkgQualBoundSpanQualifier192's and § psBoundPkgParamTs31's site, and § elabHierSelWidthFold's two member-path width folds)

A written `pkg::P` folded as an indexed part select's WIDTH is Surelog's unreduced range compile, as a part select's
bound is. The folded constant spans the qualifier with its colons (`h.v[ia[i] +: p::N]`: golden 13:18-21, ours the
whole name 13:18-22; v11u312repro VP/vp22, r11u312repro IP/ip11) and carries a ref_typespec to the parameter's
declaration typespec that golden stores no full name on: ours had none on a plain select (`w[k +: p::N]`, uhdm-cmp
stage 1 on pristine, golden `work@top.w`) and the scope's name under a path (golden
`work@grid::probe::h.v[[i]+:1]::v`, ours `work@grid::probe`). The member-path width fold is parented at its select, as
golden's is. The reference is named design-final over its final chain. The base keeps the whole name and no stamp
(§ psBoundPkgParamTs31's measured negative), a bare imported read is § ipsWidFold9's and is left alone, a localparam
width is not a package fold, and a conditional's true operand is left alone. Cases: cases/PW.

### § builtinMethPathInIdxNameSpan314 — `R11U314_BUILTINSPAN_OFF` (the built-in method branch's hier_path span)

A built-in method path whose receiver carries a select (`sarr[i].len()`, `hs[i].q.size()`), written in a non-trailing
path select's index, spans its first name, as a user method's path there does (§ methPathInIdxNameSpan310,
§ lvMethPathInIdxNameSpan312): golden `r = iarr[sarr[i].len()].f` 4:89-93 and the target `iarr[sarr[i].len()].f = r`
4:85-89, ours the whole call (v11u312repro VQ/vq07, pass 312's verifier residue 4). A receiver with no select
(`iarr[h.q.size()].f`) keeps the whole call in golden, and so does a conditional's true branch. Cases: cases/BM.

### § methPathPlainElemZeroWidth314 — `R11U314_ZEROWIDTH_OFF` (both method-path builders' plain elements)

In a method-call path spanned to its first name by the three laws above, a path holding a select, each PLAIN element
(no select) sits zero-width at its name's end: golden `iarr[h.arr[i].get()].f` `h` 13:15-15,
`iarr[iarr[i].nx.get()].f` `nx` 13:24-24, `iarr[hs[i].q.size()].f` `q` 4:90-90; ours the name (v11u312repro VQ/vq02,
vq06, r11u312repro MI/mi12, pass 310's mt62). A select-less path (`iarr[h.hh.get()].f`) keeps its elements' widths in
golden (ZW/zw15: a first draft without that gate moved it off STRICT_EQUAL and was fixed before any counted
measurement). Cases: cases/ZW.

## Grid (cases/; drivers/gen314.sh writes it from drivers/grid314.inc, gridall.sh, gridsum314.py, attrib314.py, awaygrid.sh)

The grid has 225 case dirs in both views (450 case-views; every line carries its exit code; evidence/grid.txt,
grid_summary.txt). Each case's first line names its law (`// § <law>`). The `_ctl` cases are controls the law must not
move or that its gate excludes. The class cases share one template (gen314.sh: a package `p`, a struct, `item`,
`holder` and `grid` classes, the statements as `probe()`'s body, and `fwd` declared below it); two cases carry an
include file `inc314.svh` (TS/ts35, PW/pw22).

| group | law | dirs | case-views | moving | entering STRICT_EQUAL | leaving | STRICT_EQUAL after |
|---|---|---|---|---|---|---|---|
| TS | § lvIdxThisSelPathIsRead314 | 39 | 78 | 62 | 56 | 0 | 68 |
| NB | § tfLvTrailIdxNamedBlkScope314 | 28 | 56 | 50 | 46 | 0 | 52 |
| IO | § ipsBaseOpSysRender314 (with § ipsBaseNamesReach314 on io04, io13, io15, io22, io25, io33) | 43 | 86 | 66 | 62 | 0 | 78 |
| IR | § ipsBaseNamesReach314 | 7 | 14 | 14 | 14 | 0 | 14 |
| IN | § ipsBaseInnerNamesFollowRender314 | 12 | 24 | 18 | 16 | 0 | 22 |
| SC | § trailIdxStaticScopedCallName314 | 12 | 24 | 20 | 20 | 0 | 20 |
| PW | § pkgQualIpsWidthSpanQualifier314 | 34 | 68 | 58 | 52 | 0 | 60 |
| BM | § builtinMethPathInIdxNameSpan314 | 16 | 32 | 18 | 12 | 0 | 26 |
| ZW | § methPathPlainElemZeroWidth314 | 21 | 42 | 22 | 22 | 0 | 42 |
| XT | caution (h)'s shapes for each law (named and late calls, implicit nets, interface bodies, class specializations, extern and pure virtual prototypes) | 13 | 26 | 22 | 18 | 0 | 22 |
| total | | 225 | 450 | 350 | 318 | 0 | 404 |

- No exit code changes, and `R11U314_OFF` equals pristine on 450 of 450 case-views.
- uhdm-cmp line counts change on 146 case-views, and none grows: 142 go from stage 1 to 0 lines (the hier_path
  VpiName renders of § ipsBaseOpSysRender314 and § trailIdxStaticScopedCallName314, and the ref_typespec presence of
  § pkgQualIpsWidthSpanQualifier314), and 4 shrink by 2 at stage 1 on both binaries (TS/ts17 and ts37, whose
  non-trailing and extern heads are unrelated).
- Attribution (drivers/attrib314.py, each mover rerun with each switch alone; evidence/grid_attrib.txt): 290 of the
  350 movers are restored to pristine's bytes by exactly one switch:

  | switch | movers |
  |---|---|
  | THISSEL | 64 |
  | PKGIPSW | 60 |
  | NAMEDBLK | 54 |
  | ZEROWIDTH | 26 |
  | SCOPEDCALLIDX | 22 |
  | BUILTINSPAN | 20 |
  | IPSBASEOP | 18 |
  | IPSBASENAME | 14 |
  | IPSINNER | 12 |

  The other 60 need IPSBASEOP and IPSBASENAME together (the render and the names inside the rendered base). Every
  switch changes bytes on its own somewhere.
- The chain-keyed away census (drivers/awaygrid.sh with awaychain.py and strictcmp_x built by drivers/cc_x.sh) reads
  chain away 0 and flat away 0 on all 350 movers, with 1999 chain records toward golden (1082 flat)
  (evidence/grid_away.txt). With the binaries swapped, the positive control reads away on 12 of 12 sampled movers,
  one per law group (evidence/away_poscontrol.txt).
- The 8 movers with no record toward golden are stage 1 on both binaries: BM/bm16 (a 2-D string receiver), IO/io11
  (the localparam width fossil, residue 2), TS/ts17 and ts37 (uhdm-cmp 2 lines shorter).
- Downstream (drivers/dscases.py, both lanes; evidence/downstream_cases.txt) on the 47 class-free module-, interface-
  and generate-scope dirs: 44 IDENTICAL and 3 EQUIVALENT on both binaries (IO io37, io40 and io41, the
  parameter-substitution controls the law leaves alone), none worse.
- Draft breaks, each fixed before delivery, every number above remeasured on the final binary (31f5e272): the
  census, the law sweep, the grid, the controls, the scans, byteverify and determinism:
  1. § methPathPlainElemZeroWidth314's first form also zeroed the elements of a select-less path; it moved ZW/zw15
     (`iarr[h.hh.get()].f`) off STRICT_EQUAL. It is now gated on a path holding a select.
  2. § trailIdxStaticScopedCallName314's first form left an assignment target's index with no bracket group when its
     switch was off, where pristine writes `[]`: `R11U314_OFF` differed from pristine on SC/sc02 d/e in the first full
     grid. The switch-off now takes pristine's branches.
  3. § ipsBaseOpSysRender314's and § pkgQualIpsWidthSpanQualifier314's first traces logged every rendered base and
     every walk that reached a width, over-predicting 1022 IPSBASEOP lines and two PKGIPSW lines (BlackBePipeInt d/t,
     an unqualified width) in an early census; the trace now separates a render equal to the written text
     (`IPSBASEOP_SAME_ABSTAIN`) and logs the span only when the qualifier is written.
  4. § ipsBaseOpSysRender314's object render without the identifier gate moved v11u264repro VG/vg07 (stage 1 on both
     binaries) 4 and 8 chain records AWAY in its two views, found by the trigger controls' away census: in an
     elaborated generate scope the name's text had the parameter's value (`8 - 1`, golden's) where our operand is a
     ref_obj `IDW`. The gate (every identifier of the render must stand in pristine's text) fixed it (vg07: away 0);
     IO io37 to io40 are its cases. Its first form also gated an empty bracket body and lost IO/io34 (a macro-born base,
     `h.v[]` on pristine); the empty body is exempt (io34, io42, io43 enter STRICT_EQUAL).
  5. § ipsBaseNamesReach314's walk first stopped at a folded constant, leaving its ref_typespec at the select's name in a
     generate block (`ix[k + LP]`, IO/io39 at fullname); the constant's ref_typespec is reached now (io39 enters).

## Controls

- **Firing scans** (drivers/firescan.sh): the law binary under `R11U314_TRACE` over 33079 fence-filtered dut.sv dirs
  under tools/probe and tests/probe; `VIEW=e` adds `--elabuhdm` (evidence/firescan_d.txt, firescan_e.txt).
  - 305 dirs write a trace line in each view: 185 of them this pass's, and 120 earlier dirs, 85 of which fire a
    non-abstention tag.
  - The only tests/probe dirs are r10uvm147repro/g147_a and r10uvm94repro/g94_a0_head, with `IPSBASEOP_SAME_ABSTAIN`
    only (a render equal to the written text), which moves nothing.
- **Crashes** (evidence/crashes.txt): the scans see 1 segfault in the definition view and 8 in the elaborated view, the
  nine dirs passes 310 and 312 named, each exiting 139 on pristine and on the law binary alike:
  v11u112repro m07_hdr_enum_default (both views), r10vrgg8repro v8_recurse, v8_recurse_mutual and v8_recurse_uncond,
  r11u254repro F/f04_class, r11u300repro RS/s22_recursion, v11u254repro F/vf02_iface and vf04_hier.
- **Standard byte controls** (drivers/controls.sh, both views): every dut.sv dir of r11u118, r11v11u118, r11u119,
  r11u120, r11v120, r11u124, r11v124, r11u131, r11v131, r11u157hp, r11u181, r11u184, r11u192, r11u296, v11u296,
  r11u304, v11u304, r11u306, v11u306, r11u308, v11u308, r11u310, v11u310, r11u312 and v11u312 (5820 case-views;
  evidence/controls_std_summary.txt, controls_away.txt).
  - 48 move, 42 enter STRICT_EQUAL, 0 leave, no exit-code change; uhdm-cmp lines change on 18 case-views, each from
    stage 1 to 0.
  - Chain away is 0 on all 48, with 334 records toward golden.
  - Entering (d/e each): r11u296repro CT/ct13_part_sel_bound and ct14_ips_base; r11u310repro MT/mt62_inpathop;
    r11u312repro IP/ip11_widthref, ip25_selop_ctl, ip26_sys_ctl, MI/mi12_deeprecv and MS/ms02_noarg; v11u296repro
    VT/vt10_ips_width_cast; v11u308repro VD/vd03_ipsleafop; v11u312repro VP/vp15_nestsel_ctl, vp22_width_pkg,
    vp30_mod_gen, VP2/vp41_psbase_ctl, vp43_fn_noarg_path, VQ/vq02_member_recv, vq06_deep_recv, vq07_strlen,
    VT/vt13_thisarr_in_idx, vt17_bitsel and VX/vx09_named_blk.
  - The other 6 move by bytes at stage 1 on both binaries with 0 records either way: r11u306repro NP/np26_ipswidth and
    v11u312repro VP/vp20_harr and vp31_mod_genfor (d/e).
- **Trigger controls** (drivers/controls_list.sh, both views): the 61 firing dirs outside this pass and outside the
  standard controls (evidence/trigger_dirs.txt; 122 case-views; controls_trig_summary.txt, controls_trig_away.txt).
  - 122 move, 66 enter STRICT_EQUAL, 0 leave, no exit-code change. Chain away is 0 and flat away 0 on all 122, with
    1900 records toward golden.
  - Entering: r11u116repro grid/f2 g1_cb_q, g1_ff_q, g1_in_q, g2_ca_q, g2_cb_q, g2_ff_q, g2_in_q, g3_ca_q, g3_cb_q,
    g3_ff_q, g3_in_q and gi_in_q; r11u195repro A/a02; r11u209repro R5/i1; r11u217verify IP/i03; r11u218dec
    IX/x11_sysfunc_width; r11u219repro I/i02_parambase; r11u229verify I/i02 and i04; r11u244repro L/i06, i07 and
    X/x05; r11u256repro B/b08_qualified; r11u264repro G/g08, g15 and N/n17_gen_ips_lhs; r11u298repro
    QT/qt19_ips_ctl; r11v154repro lb/i4; v11u116repro arms/f2k_mixq and f2k_qual; v11u244repro A/a04_ips_rv,
    a08_constslot, B/b02_mod_comb and X/x04_ifc_body; v11u247repro A/a01_shadow and a01_shadowq; v11u256repro
    B/vb13_qualified_nested (one view or both; the summary names each).
  - uhdm-cmp lines grow on 10 case-views, all at stage 1 on both binaries, each because the first difference moved
    LATER in the walk (evidence/controls_trig_growth.txt; away 0 on each):
    - r11u116repro f2 gi_cb_q and gi_ff_q 17 -> 46/50: pristine's head, the missing ref_typespec of the definition
      view's `+:p::P` width (id 68), is cleared; the new head is the elaborated generate scope's folded `b` (id 227).
    - r11u229verify I/i03 216/232 -> 683/695: pristine's head, the package function's hier_path name
      `arr[i].v[+:2]` (a cast base renders empty), is cleared; the new head is the module listing.
    - v11u236repro D/d01 d 17 -> 58: the missing width ref_typespec (id 88) cleared; the new head the constant id 325.
    - v11u244repro B/b04_cls_forms d 208 -> 240: the hier_path `rw.data[ * 8+:8]` (line 9) cleared; the new head
      `rw.data[8 * i+:4 * 2]` (line 14, an operation width this pass does not render).
    - v11u284repro VH/vh16_ips_pkg_width 156 -> 160: the same head (the path name's width text `4'h2`, pass 284's
      residue), four more printed lines because the width constant now has golden's parent and span (12:28-32) and
      its reference golden's chain shape.
- **The 70 probe residues** in both views: 140 case-views, 0 moving (evidence/residues70_grid.txt).
- **The firing census** (drivers/tracecensus.sh): the law binary through the harness over the probe cases and both
  corpora in both modes, the four fenced tests excluded by the filter, frozen before the law sweep
  (evidence/predict.txt): 16 database lines, all `IPSBASEOP_SAME_ABSTAIN` (BuildUVMPkg, Earlgrey_0_1, MiniAmiq,
  SeqDriver and SimpleUVM d/t, Rggen d, Scoreboard d, iface_ff_genvar_partsel d/t, two probe cases), i.e. NO predicted
  mover; those lines, written through the same harness, are its positive control (evidence/predict_poscontrol.txt).
  byteverify confirms it: 0 movers.

## Gates (evidence/gates.txt)

Both sweeps ran `tests/sweep.sh --jobs 3` from the worktree, with SLANG_UHDM exported, GOLDEN_DEFER unset and workdirs
of equal length (/tmp/r11u314_wdP, /tmp/r11u314_wdL). Each sweep exits 1 on the law-index check alone; tests/LAWS.md is
regenerated last, by scripts/law_index.py.

- **probe:** pristine 4017 + 70, law 4017 + 70; regressions 0, conversions 0 and changes 0 on both.
- **surelog:** 480 + 0 / 474 + 0 on both (the testflags TIMEOUT row is Google, as in the baseline); regressions 0,
  conversions 0, changes 0. The csvs differ only in the LowMemLib and LowMemPkg testflags detail text, which names the
  workdir.
- **uhdm2rtlil:** 803/1/67 in both modes on both binaries; regressions 0, conversions 0, changes 0; the csvs are
  identical, stamped_gen_param d/t staying CMP_NOTEQUAL.
- **downstream:** 803/66/2/0 on both, and both csvs are byte-identical to results/downstream_uhdm2rtlil.csv.
- **uhdm-cmp:** 0 lines on every row the sweeps read CMP_EQUAL, as at the base (no row status moved).
- **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered mirrors built by drivers/mirror.sh): 0 of 3365
  corpus and downstream-lane databases move. A cmp loop over the 4087 probe databases finds 0 moving.
  - Predicted: the census's list, with no firing line.
  - SELFCHECK reads 3363 of 3365 flagged. The reference is the first sorted path, downstream/1DUnpackedArray/slang.uhdm,
    which is byte-identical to its twin uhdm2rtlil/testflags/1DUnpackedArray-3af704bd/slang.uhdm (the same test with
    the same arguments). So the two unflagged files are the reference and its twin, every other file is flagged, and
    the comparator works.
- **canaries:** surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 and 6).
- **binary-path audit** (drivers/audit.sh): pristine sweep own 3265, other 0; law sweep own 3265, other 0. 50
  cmds.txt run no slang, and the 8 fenced row-modes are skipped by name.
- **determinism** (drivers/det.sh; evidence/determinism.txt): three concurrent draws per row-mode of Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes read one hash each, equal to the
  law sweep's and the pristine sweep's. Scoreboard and Rggen testflags write no database, as at the base.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **The elaborated view's method-call argument inside a receiver index** (pass 312's residue 1: r11u312repro MI/mi17,
   mi39, mi40, MS/ms03, LS/ls14 e; v11u312repro VI/vi11, VQ/vq13, VN/vn17 e). DECODED, and it is the sister ground's.
   The differing record is not ours: it is UHDM's elaborator clone. `method_func_call::DeepClone`
   (third_party/Surelog/third_party/UHDM/templates/clone_tree.cpp, the `is_function` branch) clones the receiver
   array's ELEMENT variable (`arr->Variables()->front()`, here the `class_var` under `array_var iarr`) for an argument
   whose actual has the argument's own name, renames the clone `j` and parents it at the original call. `clone_tree`
   copies the stored full name. Golden's element reg stores no full name, so the clone's name is computed from its
   new parent chain (`work@grid::probe::iarr[].f::iarr[i].put::j`); ours stores `work@grid::iarr` on the element reg,
   and the clone keeps it. The writer is UhdmExporter.cpp's class-property array branch (`reg->VpiFullName(pfn)`, the
   element reg of a class property array, beside § arraySignedWritten8's use there); leaving that name unstored is
   the fix, on the module/type ground. Not written here.
2. **The indexed-part-select width written as a class localparam** (IO/io11 `h.v[ia[i + 1] +: N2]`): golden's path
   name keeps `+:N2` (a pre-reduction fossil, § hpIdxBaseHierPathEmpty94's calibration class), ours renders the folded
   constant `+:1`; stage 1 on both binaries.
3. **An indexed part select as the base of another** (IN/in09 `h.v[lv[i +: 2] +: 2]`): golden names the inner select
   by its chain and spans it 13:12-18 (from the base to the width), ours `work@grid::probe::lv` at 13:9-19; moved from
   stage 1 to fullname by this pass's render, not equal.
4. **A package width in a port connection** (PW/pw20 `.i(w[3 +: p::N])`): golden names the stamped reference
   `work@top.u.i.w` through the port, ours `work@top.w` (our high-conn select is not parented at the port; ModuleEmit's
   emitInstance, the sister's); moved from stage 1 to fullname.
5. **Stage 1 on both binaries, not decoded:** generate continuous assignments with a package width (PW/pw29 and pw30),
   a package function's width (pw33), a for-generate subroutine with a named block (NB/nb26), a program subroutine
   (NB/nb10), a class specialization and an extern method around a `this.` select (TS/ts39, ts37), a non-trailing
   `this.` index (ts17), a member select written after `this.` (ts30), `super.` (ts34), the class handles in module
   and interface bodies (BM/bm14, XT/xt11, pass 310's vm51 shape), a 2-D string receiver (bm16), a queue-array
   receiver (bm15, exit 4 on both), a static call in a non-trailing select's index where golden keeps a func_call
   (SC/sc03 and v11u312repro VS/vs02), an out-of-body static method (sc09), an extern method below the caller
   (XT/xt12), and the control dirs v11u312repro VP/vp20 and vp31 and r11u306repro NP/np26 (moved in bytes, 0 records
   either way).
6. **Pass 312's other residues stand:** vx12 (a nested module's task), vi16 and vq03 (the 2-D receiver's outer select
   end), vf15 (the late call after a late-call root), LR/lr14 and ls13 (concatenation targets whose root select holds a
   call), the stage-1 shapes listed there; pass 310's vm72, qc08, qc10 and vq38.
7. **The 70 probe residues** at the base: none moves in either view on this binary. Their first records are the
   sister ground's typespec, file and listing faces as passes 308 to 312 classified them, and this ground's t12,
   r11v21repro/v15, vh_arrelem, r11v4repro/v6, l_concat and the four r11u109 64-bit value cases (a Surelog defect).

## Sister-ground faces (reported, not written)

- Residue 1 above: UhdmExporter.cpp's class-property array element reg storing `pfn` (the UHDM elaborator's clone
  for a method-call argument copies it).
- PW/pw20: the port-connection select's parent (ModuleEmit emitInstance), which names the width's reference.
- Pass 312's faces stand as reported: the `<in>h_t.idx` ref_typespec full name on unpacked struct members (vt18,
  vx06; TypeEmit), the interface-body struct typespec end line (lr22, vx20, vf08; TypeEmit), the elaborated
  cont_assign ref_typespec names (lr23 e, vf01 e, vf03, vf05, vf12; ModuleEmit), and vq51.

## Process

- Worktree /tmp/wt_r11u314 at e18396e3, scratch /tmp/r11u314_* and the session scratchpad. Built with -j 2. The
  pristine binary was frozen before any edit; its md5 equals the main tree's build/slang-uhdm (4b092c61). Exploration
  before the worktree built ran on a read-only copy of the main tree's binary (the same md5).
- Drivers were copied from tools/probe/r11u312repro/drivers and renamed to R11U314 / r11u314. New drivers:
  gen314.sh and grid314.inc (the whole grid), attrib314.py and gridsum314.py (renamed copies of pass 312's).
- **THE FENCE:**
  - Every driver that opens a source or a database reads $FENCED fail-closed (four names) from
    tools/probe/r11u107repro/canaudit.sh (drivers/env.sh).
  - Every tree scan (firescan.sh, controls.sh, controls_list.sh, mirror.sh, audit.sh) builds its path list first and
    filters it by word boundary before any file is opened; one search of the black-parrot sources for the width
    spelling ran on a fence-filtered find list.
  - byteverify ran on fence-filtered mirrors, and the census filter excludes the four fenced tests by exact name.
  - The fence scan of this directory reads 0 files for each of the four names. No fenced test's head was read; the
    only fenced facts cited are the sweep csvs' verdicts.
- **SLIPS, no effect:**
  1. The first background build of the pristine binary was started from a subshell that the tool's own shell had
     already left, and a second build was started in the same tree; the second exited 1 on the build lock and the
     first finished (the binary's md5 is the main tree's). No source was edited while it compiled.
  2. One wait loop used `pgrep -f` with a pattern its own command line contained, so it could not end; it was
     stopped by its own task id within a minute. Nothing was killed by it.
  3. One grep was written over a glob of the corpus test tree (`BlackParrot*`) that matched no directory, so it read no
     file; the search was redone on a fence-filtered find list.
  4. The first census run (on the binary before the switch-off fix) was stopped through its own process group after
     its command line was checked for this pass's name; it was rerun on the final binary before the law sweep.
  5. Six draft cases were not legal SV or did not build on either binary and were rewritten before any counted
     measurement (NB/nb12, a package subroutine naming $unit classes; IO/io18, `$bits` of an int; IO/io31, a part
     select of an int; BM/bm03 and bm04, `size()` of a fixed array; SC/sc09's `static extern` order); TS/ts31
     (`lv[i +: this.N2]`, exit 3 on both binaries) was dropped from the grid and its lines removed from
     evidence/grid.txt.
  Nothing was written to the main tree; no other agent's process was listed or touched.
- No patch file is kept in this directory; the delivery /tmp/r11u314.patch is transport only.
