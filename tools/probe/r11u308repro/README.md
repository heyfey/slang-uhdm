# r11u308 — pass 308, expression/parameter ground: the non-trailing select index (its elaborated class clone, its chain names, its casts, its nested paths' middle selects and indexed part-select leaves, its lvalue forms)

Pair A, refill after pass 306. Base 1e7861ae (pass 306 on top of pass 309). Production surface: src/ExprEmit.cpp
(the thirteen laws, their state static in the file) and src/ParamEmit.cpp (one declaration and one call in the drain
list, after `nestShapeDrain306`); no src/R*.h, nothing in src/LawState.h, every switch read through
src/LawSwitch.h (`lawOn(308, ...)`, `lawTrace(308, ...)`), no getenv and no reader of this pass's own.
Pristine build md5 6601ed32792b4a1efb137251e23c6ff3 (equal to the main tree's build/slang-uhdm at the base); law
build md5 1d2cda96ada1427527d37238c3937c5c. Both binaries were frozen (chmod 555) before any measurement; every
cmds.txt of both sweeps names its own binary (evidence/gates.txt). Both report slang 12.0.0+545f88b2e.

## Verdict

- **No corpus row and no probe case moves**, in status or in bytes: probe 4017 EQUAL + 70 STRICT_NOTEQUAL on both
  binaries (regressions 0, conversions 0, changes 0); surelog default 480 + 0 and testflags 474 + 0, uhdm2rtlil
  803/1/67 in both modes, regressions 0 / conversions 0 / changes 0 in both corpora; byteverify reads 0 of 3365
  corpus and downstream-lane databases and 0 of 4087 probe databases moving. Every Surelog row-mode stays CMP_EQUAL
  (954 of 954); stamped_gen_param d/t stays CMP_NOTEQUAL as at the base. The firing census (frozen before the law
  sweep) predicted exactly one firing in the gate, `surelog LocalScopeHierPath/testflags ELABCLSIDX:1`, a name the
  listener's clone recomputes to the same string (its database byte-identical, measured before the sweep and in
  it). NO PROBE CONVERSION: the probe gate runs the definition view only, and the definition-view faces of this
  ground do not occur among the 70 residues (pristine vs law over the 70 residue dirs in both views: 140 case-views,
  0 moving; evidence/residue70_pristine_vs_law.txt).
- **Downstream:** IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0, both sweeps' csvs byte-identical to
  results/downstream_uhdm2rtlil.csv.
- **The gain is outside the gate:** pass 306's residue 1 (the elaborated view of a class method naming a
  non-trailing select's index through the select: v11u306repro VB vb02, vb04, vb06, vb08, vb09, vb11, vb19 e, VD
  vd13, vd24, vd25 e, VE ve07, ve14 e, r11u306repro NB/NP e views), the verifier's residues 2 and 3 (the indexed
  part-select leaf VD vd03, vd04; the cast in a non-trailing index VN/vn01), further faces of its grid (VN/vn08's
  and VD/vd02's middle selects, the VV vv05, vv06, vv15 var_select operations, VB/vb13's indexed part select) and
  r11u306repro VH/h11 enter STRICT_EQUAL: 241 of this pass's 420 grid case-views, 70 of the 2626 standard-control
  case-views (r11u306repro, v11u306repro, r11u304repro, v11u304repro, r11u178repro, r11u181repro, r11u190verify) and
  24 of the 386 trigger-control case-views (tests/probe r10uvm79repro c2_idxkind e and v79v2_recv e among them),
  none leaving, chain away 0 on every mover. One standing pass-306 defect is fixed on the way: an lvalue path whose
  non-trailing select is on a member took the nested shape (§ lvMemberSelIdxKeepsRead308; LM lm01, lm05-lm07,
  lm09, lm10, lm12, lm16, lm20, lm23, lm26 and r11u190verify X/x02 enter STRICT_EQUAL).

## The model

The index of a select written on a NON-TRAILING element of a path (`iarr[i + 1].f`, `h.arr[midx[i]].f`,
`iarr[int'(h.k)].f`) is compiled by Surelog's `CompileHelper::compileSelectExpression`
(third_party/Surelog/src/DesignCompile/CompileExpression.cpp) as part of the path: in an rvalue the index is
parented at the hier_path itself (ours alike: the operand's parent is the hier_path in the definition listing), and
Surelog stores no full name on it, so golden's names there are UHDM `BaseClass::ComputeFullName` over that chain
(`chainFullName175`). Three consequences carry this pass:

1. In the `-elabuhdm` view UHDM's `ElaboratorListener::elabClass_defn` clones every class method in place; the
   generated `DeepClone` (third_party/Surelog/third_party/UHDM/templates/clone_tree.cpp, `*clone = *this`) copies a
   STORED full name verbatim and gives each select's index the CLONED SELECT as its parent, so an UNSTORED name is
   recomputed through the select (golden `work@grid::probe::iarr[i + 1].f::iarr::i`, definition listing
   `...::iarr[i + 1].f::i`). Ours stored the definition listing's names, which the clone copied. The module
   definitions get exactly this treatment from § elabCloneFullNameUnstored137 (uhdm_main.cpp) before the listener
   runs; classes are outside that law.
2. Every named object of such an index reads its chain; where an earlier law did not name an object ours kept the
   scope's name (a var_select, a cast's ref_typespec, a path leaf read in the read shape).
3. In an LVALUE the index hangs off the select (golden `...::h.arr[].f::arr::midx::k`), and an lvalue path whose
   non-trailing select is written on a MEMBER keeps the read shape for a member path in its index; only a select
   on the path's base takes § nonTrailIdxPathNestShape306's nested shape there.

## The laws (src/ExprEmit.cpp)

`R11U308_OFF` drops all thirteen and gives pristine's bytes and exit code on 420 of 420 grid case-views.
`R11U308_TRACE=<dir>` logs every firing (`<TAG> <detail>`) and abstention or switch-off (`<TAG>_ABSTAIN`,
`<TAG>_OFF`) into `<dir>/<pid>.308`, its first line `OUT <-o path>`.

### § elabClsNonTrailIdxUnstored308 — `R11U308_ELABCLSIDX_OFF` (`elabClsNonTrailIdx308`, design-final, the -elabuhdm view only)

In a class (any class_defn ancestor), every ref_obj, select, hier_path or ref_typespec under the index of a
non-trailing select whose stored full name EQUALS its own chain is left unstored, so the listener's clone computes
it through the cloned select: golden `...::iarr[i].f::i` (a bare reference: ComputeFullName skips a select directly
above a ref_obj and keeps the path), `...::iarr[[i]].f::iarr::midx`, `...::h.arr[i + j].f::arr::j`,
`...::iarr[].f::iarr` (a cast's ref_typespec). A name that differs from its chain (the nested path's bare leaf, a
middle select's path-derived name) is a modelled deviation and stays. The definition view reads the same name
either way (the serializer writes the computed name), which is why the law is gated to the view the listener runs
in. Grid EC (class methods: operations, selects, calls, system calls, conditionals, concatenations, casts, part
selects, foreach, case, while, compound assignments, inc/dec, streaming lvalue, `this.`, `super.` (stage 1 on
both), extern and pure virtual methods, a parameterized class, a static method, a task, a class in a package, in a
module and nested in a class, a macro and an included macro index; the module, interface, generate and
instance-depth controls ec37-ec45, ec62-ec65).

### § elabClsNestLeafSelUnstored308 — `R11U308_LEAFSELELAB_OFF` (inside `nestShapeDrain306`'s elaborated-class abstention)

§ nonTrailIdxPathNestShape306 names the nested path's leaf member select by its chain but stands aside in the
elaborated view of a class method. There the leaf select is unstored in golden too and the clone computes it
through the outer select (golden `...::iarr[].f::iarr::h.k[1:0]::k`, `...::iarr::h.v[i+:2]::v`); ours had kept the
written text `h.k[1:0]`. The law leaves the leaf select unstored there. Cases r11u306repro NP/np41 e, EC ec66-ec68,
IP ip11 e.

### § castTsNonTrailIdxByChain308 — `R11U308_CASTNTIDX_OFF` (`castTsNonTrailIdx308`, design-final)

The non-trailing twin of § castTsInPathIdxByChain296: a cast written in the index of a non-trailing select
(`r = iarr[int'(h.k)].f`, v11u306repro VN/vn01), reached through operations and call arguments, has its
ref_typespec named over its chain (golden `work@grid::probe::iarr[].f`; ours the scope's `work@grid::probe`); only
where the stored name is the scope's prefix of the chain name. Grid CT (class and module casts, sized, signed,
typedef, in an operation, a middle select, a select, a conditional, a call argument, an lvalue, generate scopes, a
port connection).

### § nonTrailIdxNamesByChain308 — `R11U308_NTIDXCHAIN_OFF` (`nonTrailIdxNamesByChain308`, design-final)

Every named object (not a path element) under the index of a non-trailing select whose stored name is neither empty
nor its bare name reads its chain: golden `vsp::probe::probes::bb.bin[n + two_d[1][]].fv::two_d` for the
var_select of `bb.bin[n + two_d[1][bb.q]].fv` (r11u306repro VH/h11), ours the scope's `vsp::probe::probes::two_d`.
Grid NV, BI, IP, CS.

### § nonTrailIdxReadLeafByChain308 — `R11U308_NTIDXLEAF_OFF` (the same drain, path elements)

A member path read in such an index that keeps the READ shape (a conditional's true branch, a call argument: §
nonTrailIdxPathNestShape306 stands aside there) names its later plain references over the chain too (golden
`vsp::probe::probes::bb.bin[n ? two_d[1][] : 0].fv::two_d::q`; ours `vsp::probe::probes::two_d::q`). The path's
base, and its select elements (which keep their stored written text, golden `h.arr[1]`, the break a first draft
found on MS ms08/ms10), are left alone. Cases NV nv08, nv09.

### § nonTrailIdxRvalueOnly308 — `R11U308_CALHS_OFF` (`nonTrailIdxElem308`, the guard of the naming laws)

A continuous assignment's left side is an lvalue: golden hangs its index off the select (`assign b[K-1].w =
1'b1`: `work@dut.b[K - 1].w.b.K`) where ours keeps the path as its parent, so ours' chain there is not golden's and
the naming laws above stand aside. Found by the trigger controls on a first build that moved four STRICT_EQUAL
case-views away (r11u210repro IA/i02, r11u217verify IA/a01, r11u225repro IA/a20, v11u225repro FA/f08, default view);
with the switch set those four break again. Grid CA (interface-array element left sides: a parameter index, a
for-generate index, an if-generate scope, a process left side and a right-side control).

### § lvNonTrailIdxNamesByChain308 — `R11U308_LVIDXCHAIN_OFF` (`nonTrailIdxPath308`, the lvalue form)

An assignment's left-side path hangs the index off the select itself; the two naming laws above reach that form
too (golden `h.arr[midx[hd.k]].f = r`: `...::h.arr[].f::arr::midx::k`, ours `...probe.h.arr[].f::midx::k`). Only an
assignment's left side: a first draft that took every select-parented index renamed a READ path ending in a
method call (`m_type_names[key].get_type_name()`, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard and BuildUVMPkg: 301
to 400 fullname records away) where golden keeps the scope's stored name; the firing census caught it before the
sweep. Case LM/lm16.

### § nonTrailIdxIpsLeaf308 — `R11U308_IPSLEAF_OFF` (the § nonTrailIdxPathNestShape306 wrapper)

An INDEXED part select as the nested path's leaf (`sa[t.idx[i +: 1]].f`, `iarr[h.v[i +: 2]].f`; v11u306repro VD
vd03, vd04) is the same Select-grammar member select: golden's indexed_part_select carries its member name as its
definition name and reads its full name through its final chain (`work@top.sa[].f.t.idx[i+:1].idx`); ours stored
the written text and no definition name. The drain of pass 306 now accepts the kind. Grid IP.

### § nestPathMidSelShape308 — `R11U308_NESTMIDSEL_OFF` (the § nonTrailIdxPathNestShape306 wrapper)

A select written on a MIDDLE member of the nested path (`iarr[h.arr[1].f].f`, `iarr[h.arr[h.k].f].f`; v11u306repro
VN/vn08, VD/vd02) is the same compile: golden's base ref_obj sits on the first member's token, the middle bit_select
spans from its member name to its closing bracket (`arr[1]`) and reads its name through its final chain
(`...::iarr[].f::h.arr[1].f::arr`), the leaf reference stores no full name. Ours stopped collecting the member
chain at the select and kept the read shape. Grid MS (class and module, literal, reference, path, operation and
leaf-select indices, deeper paths, lvalues on the base, inc/dec, a conditional's branches, a call argument, `this.`,
generate scopes, a port connection, an interface).

### § lvMemberSelIdxKeepsRead308 — `R11U308_LVMEMSEL_OFF` (the § nonTrailIdxPathNestShape306 wrapper)

An LVALUE path whose non-trailing select is written on a MEMBER (`h.arr[hd.k].f = r`, `m.w[n.w[k].v + 1].v = 2`)
keeps the read shape for a member path in its index: golden `hd` on its own token, the leaf named through the
select (`...::h.arr[].f::arr::k`), a middle select storing its written text (`n.w[k]`). Only a select on the
path's BASE (`iarr[h.k].f = 3`, `sa[u.a[1].k].f = j`) takes the nested shape in an lvalue. This is a refinement of
§ nonTrailIdxPathNestShape306 (whose grid had only base-select lvalues; pristine is wrong on LM lm01, lm05-lm07,
lm09, lm10, lm12, lm16, lm20, lm23, lm26, each restored by this switch alone) and the guard of § nestPathMidSelShape308, whose first draft moved three
STRICT_EQUAL controls away (r11u181repro lx/x01, lx/x02, adv/a01, both views: the standard controls caught it).
Only the lvalue path ITSELF (its parent an assignment or an inc/dec operation): a path nested in its index is built
with the lvalue flag too, and golden reshapes a member path two levels down (`m.w[n.w[o.w[IX.k].v].v].v = 2`: `IX`
on `k`, `k` unnamed; r11u190verify X/x02, whose first trigger-control run read chain away 4 before this gate and
now enters STRICT_EQUAL; LM lm27-lm30). The component index is a static `hpComp308` beside pass 306's flag. Grid LM.

### § varSelIdxOpHpLeafByPath308 — `R11U308_VSHPOP_OFF` (trailIdxNestedNames187's walk, § varSelIdxHpLeafByPath306's case)

The member path inside a var_select's index below a path's trailing select is reached below OPERATIONS and CALLS
too (`bb.bin[two_d[1][bb.q + bb.q]]`, `two_d[1][f(bb.q)]`, `two_d[1][n ? bb.q : 0]`; v11u306repro VV vv05, vv06,
vv15): an operation has no name and ComputeFullName skips a call, so golden reads the leaf through the var_select's
path-derived name (`vsp::probe::probes::bb.bin::bin::two_d::q`). Grid VO.

### § nestShapeThroughVarSel308 — `R11U308_NESTVARSEL_OFF` (the § nonTrailIdxPathNestShape306 wrapper's parent climb)

A var_select in a non-trailing index is climbed like a one-level select (`bb.bin[n + two_d[1][bb.q]].fv`,
r11u306repro VH/h11: golden's `bb` on `q`, `q` with no full name). An lvalue stands aside (golden
`bb.bin[two_d[1][bb.q]].fv = got` keeps the read shape with the var_select parented at the select: NV/nv04, which a
first draft moved one flat record away). Grid NV.

### § bareSelIdxIpsWhole308 — `R11U308_BAREIPS_OFF` (emitMixedHierPath, pass 304's walker and pass 306's BARESEL reach test)

An indexed part select in a non-trailing select's index (`iarr[midx[v[i+:2]]].f`, v11u306repro VB/vb13;
`iarr[v8[i+:2] + 1].f`) spans its whole select as the bit selects there do (golden 9:19-26, ours its base to its
width 9:21-25). A call argument keeps its own span. Grid BI.

## Grid (cases/; drivers/gridall.sh, gridsum308.py, attrib308.sh, awaygrid.sh)

210 case dirs in both views (420 case-views; drivers/gridall.sh with labels pristine, law and law+R11U308_OFF,
every line with its exit code; evidence/grid.txt, grid_summary.txt), each case's first line naming its law: EC
(66 dirs, § elabClsNonTrailIdxUnstored308 and its module, interface, generate, instance-depth and implicit-net
controls; ec45, ec62 § castTsNonTrailIdxByChain308; ec66-ec68 § elabClsNestLeafSelUnstored308), CT (19, §
castTsNonTrailIdxByChain308), IP (16, § nonTrailIdxIpsLeaf308), MS (25, § nestPathMidSelShape308), LM (26, §
lvMemberSelIdxKeepsRead308; lm16 § lvNonTrailIdxNamesByChain308), VO (12, § varSelIdxOpHpLeafByPath308), NV (15, §
nestShapeThroughVarSel308; nv08, nv09 § nonTrailIdxReadLeafByChain308), BI (15, § bareSelIdxIpsWhole308), CS (10,
§ nonTrailIdxNamesByChain308: the constant slots), CA (6, § nonTrailIdxRvalueOnly308).

| group | case-views | moving | entering STRICT_EQUAL | leaving | STRICT_EQUAL after |
|---|---|---|---|---|---|
| BI | 30 | 27 | 25 | 0 | 28 |
| CA | 12 | 0 | 0 | 0 | 6 |
| CS | 20 | 3 | 2 | 0 | 6 |
| CT | 38 | 34 | 30 | 0 | 34 |
| EC | 132 | 55 | 53 | 0 | 116 |
| IP | 32 | 32 | 25 | 0 | 25 |
| LM | 52 | 34 | 34 | 0 | 52 |
| MS | 50 | 44 | 38 | 0 | 42 |
| NV | 30 | 20 | 12 | 0 | 12 |
| VO | 24 | 22 | 22 | 0 | 22 |
| total | 420 | 271 | 241 | 0 | 343 |

- 0 exit-code changes; `R11U308_OFF` equal to pristine on 420 of 420 case-views; with `R11U308_CALHS_OFF` alone
  CA ca01, ca02 (fullname) and ca03, ca05 (bytes, stage 1) move off pristine, the break that law guards.
- uhdm-cmp line counts change on 5 case-views, all at stage 1 on both binaries with the same first difference
  (MS/ms28_iface d 760 -> 758, NV/nv02_whole d/e 210 -> 208 and 250 -> 248, NV/nv11_mod d/e 190 -> 188): the
  printed dump of the differing object carries the renamed objects (`(work@top.sa[].f.m2.k)` -> `(k)`).
- Attribution (drivers/attrib308.sh: each mover rerun with each switch alone; evidence/grid_attrib.txt): 214 movers
  restored to pristine's bytes by exactly one switch (ELABCLSIDX 47, NESTMIDSEL 42, CASTNTIDX 32, LVMEMSEL 22,
  VSHPOP 22, IPSLEAF 21, NTIDXCHAIN 10, NESTVARSEL 8, BAREIPS 7, LVIDXCHAIN 2, LEAFSELELAB 1), 57 needing two or more
  because a case fires several laws (CASTNTIDX with ELABCLSIDX 10, LEAFSELELAB with NESTMIDSEL 9, BAREIPS or
  NESTVARSEL or IPSLEAF with NTIDXCHAIN 16, NTIDXCHAIN with NTIDXLEAF 4, the rest listed in the file).
- The chain-keyed away census (drivers/awaygrid.sh with this pass's awaychain.py and the record comparator
  strictcmp_x built by drivers/cc_x.sh): chain away 0 and flat away 0 on all 271 movers, 638 records toward golden
  (evidence/grid_away.txt); the positive control with the binaries swapped reads away on 11 of 12 sampled movers by
  chain key and 12 of 12 by flat key (NV/nv02_whole, a stage-1 case, moves only by the flat key;
  evidence/away_poscontrol.txt).
- Downstream (drivers/dscases.py, both lanes) on the 55 module-scope case dirs: the 78 module-scope case dirs: 68 IDENTICAL on both binaries, BI bi03, bi04, bi10 and bi15 EQUIVALENT -> IDENTICAL (the whole indexed part-select span now matches the src attribute), CA/ca03, CS cs01, cs03, cs08 and MS/ms28 EQUIVALENT on both, CS/cs06 DIVERGENT on both; none worse (evidence/downstream_cases_*.txt).
- The slots: part-select and indexed part-select bases and widths, replication operands, bit-select indices,
  dimension bounds and parameter defaults (CS: stage 1 on both binaries except the class forms cs04/cs05 e, which
  enter STRICT_EQUAL), if-, for- and two-level generate scopes (stage 1 or the sister's face, below), instance
  depths 1-3 (ec43), implicit nets (ec44), interface bodies (ec39, ip15, ms28), class specializations in an index
  (cs11, stage 1), `this.` and `super.` paths, inc/dec, compound assignment and streaming lvalues, calls as indices
  with positional and named arguments, extern and pure virtual methods, macro and included-macro tokens.

## Controls

- Firing scans (drivers/firescan.sh, the law binary under `R11U308_TRACE` over 31020 fence-filtered dut.sv dirs
  under tools/probe and tests/probe; `VIEW=e` adds `--elabuhdm`): the definition view writes a trace line in 162
  dirs (117 of them this pass's, none under tests/probe), the elaborated view in 448 (173 this pass's, 19 under
  tests/probe). Crashes (drivers/crashscan.sh): 8 dirs exit 139 in the elaborated view and 1 in the definition view
  (v11u112repro m07_hdr_enum_default), every one exiting 139 on pristine too (evidence/crashes.txt).
- Standard byte controls (drivers/controls.sh, both views) over every dut.sv dir of r11u118, r11v11u118, r11u119,
  r11u120, r11u124, r11u131, r11u178, r11u181, r11u184, r11u190verify, r11u296, v11u296, r11u304, v11u304, r11u306
  and v11u306 (2626 case-views): 84 moving, 70 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 2 uhdm-cmp
  line changes (r11u306repro NP/np17_varsel d/e 190 -> 188 and 230 -> 228, stage 1 on both binaries with the same
  first difference); chain away 0 and flat away 0 on all 84 with 203 records toward golden
  (evidence/controls_std*.txt, controls_away.txt). The movers that stay not equal: r11u178repro hp/h10 d/e, r11u306
  NB/nb08 e, NP/np10 e, np17 d/e, v11u306 VN/vn18 e (stage 1 on both), r11u304 NS/m19 d/e, v11u304 VN/vn19 d/e,
  v11u306 VB vb12 e, vb16 e (fullname -> col: the macro face of residue 3), VN/vn15 e (residue 1).
- Trigger controls (drivers/controls_list.sh, both views): the 193 firing dirs outside this pass and outside the
  standard controls (evidence/trigger_dirs.txt; 386 case-views): 53 moving, 24 entering STRICT_EQUAL (tests/probe
  r10uvm79repro c2_idxkind e and v79v2_recv e, r11u190verify LC c03, c04, r11u194verify X/x06, r11u195repro K/k12,
  r11v178repro hx/x13, r11v181repro lx x01, x02, x04 and others: evidence/controls_trigger_summary.txt), 0 leaving,
  0 exit-code or uhdm-cmp changes; chain away 0 and flat away 0 on all 53 with 123 records toward golden
  (evidence/controls_trigger_away.txt).
- The firing census (drivers/tracecensus.sh, the law binary through the harness over the probe cases and both
  corpora in both modes, the four fenced tests excluded by the filter), frozen before the law sweep
  (evidence/predict.txt): `surelog LocalScopeHierPath/testflags ELABCLSIDX:1`, nothing else. The line is itself the
  positive control that the trace reaches through the harness; the database is byte-identical on both binaries (the
  cleared name is the one the listener's clone recomputes). The census of a draft that reached every
  select-parented index (evidence/predict_draft_lvidx_all.txt) named 301 to 400 NTIDXCHAIN firings on the UVM rows
  and BuildUVMPkg, and those rows then read STRICT_NOTEQUAL fullname(400) and (308)
  (evidence/draft_lvidx_all_uvm_rows.csv): the draft was narrowed to an assignment's left side before any sweep.

## Gates (evidence/gates.txt, sweep_P.log, sweep_L.log)

Both sweeps `tests/sweep.sh --jobs 3` from the worktree with SLANG_UHDM exported (each exits 1 on the law-index
check alone: tests/LAWS.md is regenerated last, by scripts/law_index.py). evidence/gates.txt.

- probe: pristine 4017 + 70, law 4017 + 70; regressions 0, conversions 0, changes 0 on both.
- surelog: 480 + 0 / 474 + 0 on both, regressions 0, conversions 0, changes 0; the csvs differ only in the
  LowMemLib and LowMemPkg testflags detail text, which names the workdir.
- uhdm2rtlil: 803/1/67 in both modes on both, regressions 0, conversions 0, changes 0; csvs identical.
- downstream: 803/66/2/0 on both, both csvs byte-identical to results/downstream_uhdm2rtlil.csv.
- uhdm-cmp: 0 lines on every row the sweeps read CMP_EQUAL, as at the base (no row status moved).
- byteverify (tools/probe/r11v75repro/byteverify.sh on fence-filtered mirrors built by drivers/mirror.sh; workdir
  names of equal length): 0 of 3365 corpus and downstream-lane databases moving, and a cmp loop over the 4087
  probe databases: 0 moving. Predicted: the census's one line, byte-neutral. SELFCHECK reads 3363 of 3365: the
  reference is the first sorted path, downstream/1DUnpackedArray/slang.uhdm, byte-identical (md5 349c99c5b21c)
  to its twin uhdm2rtlil/testflags/1DUnpackedArray-*/slang.uhdm, so the reference and the twin are the two
  unflagged files (every other file is flagged: the comparator works).
- canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 and 6).
- binary-path audit (drivers/audit.sh): pristine sweep own 3265 other 0, law sweep own 3265 other 0 (50 cmds.txt
  run no slang; the 8 fenced row-modes skipped by name).
- determinism (drivers/det.sh): three concurrent draws per row-mode of Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes read one hash each, equal to the law sweep's and to
  the pristine sweep's (evidence/determinism.txt; Scoreboard and Rggen testflags write no database, as at the
  base). A first build moved MiniAmiq d/t and SeqDriver d/t in bytes with dump-identical databases: the drains
  had read unstored full names through UHDM's getter, which freezes the computed name into a new symbol; every
  read of this pass now goes through `storedFullName308` (the symbol id, read the way r11u215's probe in
  ParamEmit reads it), and the four databases are byte-identical to pristine's.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **A path ending in a method call** (`r = iarr[h.k].get()`, v11u306repro VN/vn15, col on both binaries): the
   select before the call is built as the path's last member, so § nonTrailIdxPathNestShape306's non-trailing flag is
   never raised and the member path in its index keeps the read shape (golden `h` on `k`, `k` unnamed). This
   ground's (ExprEmit emitMixedHierPath's call tail); the next law. Note for that law: a READ path ending in a
   method call hangs its index off the select and golden keeps the scope's stored name on a bare reference there
   (`m_type_names[key].get_type_name()`, the UVM rows), the face § lvNonTrailIdxNamesByChain308's first draft broke.
2. **The port-connection bare select's second listing** (`.a(sa[m[m[i]]].f)`, v11u306repro VB/vb14): the first
   listing is right since pass 306 (`work@top.u1.a.sa[].f.m`); the instance's port high-conn listing keeps
   `work@top.sa[].f.m` (written after this ground's drains), and golden has a deeper object under the index there
   (`#335 depth`). Not decoded.
3. **Macro-born bare selects** (v11u306repro VB vb12, vb16; r11u304repro NS/m19, v11u304repro VN/vn19 move
   fullname -> col in the elaborated view only): golden lays the macro body's columns out on the expanded line; pass
   304's walker abstains on macro spans. The macro column model (UhdmExporter buildMacroExpansions) is the sister's.
4. **An escaped member name** (`iarr[h.\kk ].f`, VD/vd17): golden places both refs at 9:16-24 (from the backslash,
   past the closing bracket), a Surelog width artefact of § escBlockNameSpanTrailSpace286's family; not copied.
5. **The lvalue twin of § varSelIdxHpLeafByPath306** (r11u306repro VH/h06 `bb.bin[n + two_d[1][bb.q]] = got`): the
   trailing select's index of an lvalue is not path-named at all (`n`, the var_select and the leaf keep the scope's
   names); § lvSelIdxChainName181's ground.
6. **Stage 1 on both binaries, heads on the hier_path's own text** (VpiName/VpiDecompile such as
   `bb.bin[[1][2]].fv`, `sa[i + 1].f[2:0]`): NV nv05-nv07, nv13-nv15, VO/vo08, CT ct14, ct15, IP ip05, ip06, MS ms11,
   ms23, ms24, EC ec15 (extern), ec49 (`super.`), CS cs01, cs03, cs06-cs08, cs10, cs11, BI/bi15, CA ca03, ca05; and
   r11u306repro's stage-1 list unchanged. CS/cs06_lp (`LP[i+1].f` of a localparam struct array) is downstream
   DIVERGENT on both binaries.
7. **The 70 probe residues** at the base: none moves in either view on this binary (pristine vs law over the 70
   dirs, both views: 140 case-views, 0 moving). This ground's among them stand as pass 306 listed them: t12 (the
   returned path's parent, golden unparented), r11v21repro/v15 (the assembled param_assign reference), vh_arrelem
   (a typedef object per package listing), r11v4repro/v6, l_concat (a net binding), the four r11u109 64-bit value
   cases (a Surelog defect).

## Sister-ground faces (reported, not written)

- TypeEmit emitSyntaxExpr called from ModuleEmit emitDefGenStmts: the definition-view GENERATE statement's index
  (EC ec40, ec41, ec42, ec64: `assign r = sa[i+1].f` in a generate block, golden `work@top.gi.sa[i + 1].f.i`, ours
  `work@top.gi.i`): there the index operation is parented at the select, not at the path, so neither golden's chain
  nor this pass's laws reach it; the same writer as p1_pos115, v8, g13 and v41v_comment.
- ModuleEmit: an interface port's net ref_typespec in the definition listing (EC/ec39, IP/ip15 d: golden RHS
  `<null>`), the interface instance listing (MS/ms28 d stage 1); TypeEmit: the interface body's struct typespec end
  stretched to the use site (ec39 e, ip15 e: endline, the np39 / vn41 face).
- UhdmExporter / TaskFuncEmit: a package function formal's struct typedef stretched to the formal (EC/ec50_pkgfn:
  `p::s_t` 3:11-43 where golden has 4:37-40; § tfArgTypedefLastWriter146's family).
- The sister-ground faces passes 304 and 306 listed stand unchanged (no such case moves on this binary).

## Process

- Worktree /tmp/wt_r11u308 at 1e7861ae, scratch /tmp/r11u308_*; built with -j 2; the pristine binary frozen
  before any edit, md5 equal to the main tree's build/slang-uhdm. Drivers copied from tools/probe/r11u306repro/
  drivers (renamed to R11U308 / r11u308; the C++ header comment of strictcmp_x.cpp made a `//` line before its
  first compile); new: pl.sh, gridsum308.py, attrib308.sh, crashscan.sh, and firescan.sh's `VIEW=e`.
- THE FENCE: every driver reads $FENCED fail-closed (four names) from tools/probe/r11u107repro/canaudit.sh;
  every path list is built and filtered before any file is opened; byteverify ran on fence-filtered mirrors; the
  fence scan of this directory reads 0 files for each of the four names.
- The law binary changed four times after measurements had started, each time because a gate caught a break
  before delivery, and every measurement in this README is on the final binary
  (1a867d9f was replaced after its firing census named the UVM rows; 72d853cb after the UVM byte movers;
  64efc368 after the trigger controls' four continuous-assignment breaks; 14c7c2d7 after r11u190verify X/x02's
  away records; the final binary is 1d2cda96):
  the census, the grid, the attribution, the away census, the standard and trigger controls, the crash scans,
  both sweeps' comparisons, byteverify, canaries, the audit, determinism and the downstream cases were rerun on
  1d2cda96ada1427527d37238c3937c5c.
- SLIPS, no effect: (1) one standard-controls launch ran in the wrong directory (`controls.sh: No such file`) and
  its stale csv was read once before the timestamps showed it; rerun. (2) The first trigger-controls run named the
  tests/probe dirs relative to tools/probe and their 23 dirs found no database; rerun with `../../tests/probe`
  paths. (3) A law sweep, a firing scan and a crash scan on superseded binaries were stopped by their own
  process groups (each command line checked for this pass's name first); the crash scan's half-done scratch was
  removed. (4) Three draft cases were not legal SV (CS cs09, cs12 a variable part-select bound; LM/lm25 an
  assign to a variable-indexed unpacked struct array; CA/ca06 a cast index on an interface array) and were
  dropped before any measurement counted. No other agent's process, worktree or file was touched; nothing
  was written to the main tree.
- No patch file in this directory; the delivery /tmp/r11u308.patch is transport only.
