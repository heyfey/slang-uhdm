# r11u312 — pass 312, expression/parameter ground: the lvalue index shapes pass 310 did not reach (concatenation, module and package subroutine targets, a `this.` path, a method-call path, a root select's call), the indexed-part-select base faces, and the call spans in an index

Pair A, refill after pass 310. Base ad7db986 (pass 310 on top of pass 315). Production surface: src/ExprEmit.cpp
only. It holds twelve laws: three drains called from `nonTrailIdxDrain308` and nine emission-time sites, so
ParamEmit's drain list is unchanged. There is no src/R*.h, nothing in src/LawState.h, and no getenv or reader
of this pass's own. Every switch is read through src/LawSwitch.h (`lawOn(312, ...)`, `lawTrace(312, ...)`).

- Pristine build md5 be2074e1fde43c4025b5fb2370dbb2a8, equal to the main tree's build/slang-uhdm at the base.
- Law build md5 4fe9e91d18cd806568767869e80b17e0.
- Both binaries were frozen (chmod 555 copies under /tmp/r11u312_bin) before any measurement, and both report
  slang 12.0.0+545f88b2e.
- Every cmds.txt of both sweeps names its own binary (evidence/gates.txt).

## Verdict

- **No corpus row and no probe case moves**, in status or in bytes.
  - probe: 4017 EQUAL + 70 STRICT_NOTEQUAL on both binaries; regressions 0, conversions 0, changes 0.
  - surelog: default 480 + 0 and testflags 474 + 0.
  - uhdm2rtlil: 803/1/67 in both modes; regressions 0, conversions 0, changes 0.
  - byteverify: 0 of 3365 corpus and downstream-lane databases moving, and 0 of 4087 probe databases.
  - Every Surelog row-mode stays CMP_EQUAL (954 of 954), and stamped_gen_param d/t stays CMP_NOTEQUAL.
  - The firing census (frozen before the law sweep, evidence/predict.txt) predicted NO firing in the gate: the
    file is empty. Its positive control (evidence/predict_poscontrol.txt) shows pass 306's trace through the
    same harness on c2_idxkind.
  - NO PROBE CONVERSION: none of the 70 residues is reached (pristine vs law over the 70 dirs in both views:
    140 case-views, 0 moving; evidence/residues70_summary.txt).
- **Downstream:** IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 on both sweeps. Both csvs are
  byte-identical to results/downstream_uhdm2rtlil.csv.
- **The gain is outside the gate.** The residues pass 310 and its verifier named first on this ground enter
  STRICT_EQUAL:
  - CLSLVTRAIL's reach: the concatenation targets VT/vt36 and VC/vc22, and the method path as a trailing index
    VT/vt37.
  - The `this.` trailing index VT/vt27.
  - The method path nested in a non-trailing index: MT mt61, mt66, mt68 and VQ vq25, vq26, vq28 (d).
  - Its lvalue and trailing spans: MT mt65 and mt67, VQ vq27 and vq29 (d/e).
  - The forward-declared class method call FX/fx02 (d/e).
  - The module task VT/vt18 moves 2 records toward golden in each view. It is headed by the sister ground's
    `<in>h_t.idx` typespec face, which this pass's MD grid avoids by its holder.
  - Totals: 270 of this pass's 440 grid case-views, 33 of the 4830 standard-control case-views and 21 of the
    88 trigger-control case-views enter STRICT_EQUAL. None leaves, and chain away is 0 on every mover.

## The model and the laws (src/ExprEmit.cpp)

`R11U312_OFF` drops all twelve and gives pristine's bytes and exit code on every grid case-view.
`R11U312_TRACE=<dir>` logs every firing (`<TAG> <detail>`) and every abstention or switch-off (`<TAG>_ABSTAIN`,
`<TAG>_OFF`) into `<dir>/<pid>.312`, its first line `OUT <-o path>`. Every switch is read through
src/LawSwitch.h (`lawOn(312, ...)`). The pass adds no src/R*.h file, no src/LawState.h section and no getenv.
The state of the three drains is local to each drain. The drains run from `nonTrailIdxDrain308`, after
pass 310's, so ParamEmit's drain list is unchanged.

### § lvIdxThisPathIsRead312 — `R11U312_THISIDX_OFF` (the `this.` form decision, § thisPathFormByPosition157's site)

A one-member `this.` path written in an assignment target's select index is a read. Examples:
`h.idx[this.i] = r`, `h.idx[this.i + 1] = r`, `ia[this.i] += 1`, `{ia[this.i], r} = 2`, `h.v[this.i +: 2] = 0`.
Golden spans the hier_path over the whole `this.i` (13:11-17). It keeps the member at its own token
(13:16-17) and stores no full name on it. This is the rvalue form. Ours took the lvalue form: the hier_path
spanned `this` (13:11-15), and the member had no location and the scope's name. Pass 310's
§ clsLvTrailIdxNamesByChain310 then moved that name to `...::h.idx[ + 1]::idx::i`, which is also wrong
(v11u310repro VT/vt27).

The gate is lvIdxParent154's: the path's parent is a select, directly or through operations. An inc/dec
operand there keeps its operator's form. A postfix operand (`ia[this.i++] = r`) takes the postfix form: the
whole path, with the member loc-less and scoped (golden 13:8-14). A prefix operand keeps the lvalue form.
Cases: cases/TH.

### § clsLvTrailConcatTarget312 — `R11U312_CONCATLV_OFF` (`clsLvTrailIdxNames310`'s collection)

Pass 310's class-method law also covers targets written as members of a concatenation. Examples:
`{h.idx[i + 1], r} = 2`, `{r, h.idx[midx[i]]} = 2`, the nested `{{h.idx[i + 1]}, r}`, and `<=`. Golden
reads `work@grid::probe::h.idx[i + 1]::idx::i`; ours kept `work@grid::probe::i` (v11u310repro VT/vt36,
VC/vc22). The collection climbs concatenations only, up to an assignment whose Lhs is the outermost one.

Untouched: a streaming target (`{>>{...}} = x`, a stream operator, not a concatenation), a module process
(already golden's through § lvSelIdxChainName181's drain), and an rvalue concatenation. Cases: cases/CC.

### § modTfLvTrailIdxNamesByChain312 — `R11U312_MODTF_OFF` (`clsLvTrailIdxNames310`'s scope gate)

The same targets in a module, interface or program task or function read their chain, `.`-joined. Examples:
`task t(); h.idx[i + 1] = r;`, `h.idx[midx[i]] = r`, `+=`, `<=`, `h.idx[f(i)]`, `h.idx[int'(i)]`, and
`{h.idx[i + 1], r} = 2` (which needs this law and CONCATLV). Golden reads `work@top.t.h.idx[i + 1].idx.i`;
ours kept `work@top.t.i` (v11u310repro VT/vt18). The law reaches subroutines inside generate blocks (one and
two levels), at instance depth 3, and in two instances of one module.

Untouched: a module process (already golden's). Cases: cases/MD (a class handle or a packed struct
holds the array, so that every case can reach STRICT_EQUAL; the sister ground's `<in>h_t.idx` typespec face
heads an unpacked-struct holder).

### § pkgTfLvTrailIdxNamesByChain312 — `R11U312_PKGTF_OFF` (`clsLvTrailIdxNames310`'s scope gate)

The same targets in a package subroutine read their chain, `::`-joined. Examples: `function automatic void
f(holder h, int i); h.idx[i + 1] = 0;`, a package variable `g.idx[k + 1] = 0`, and a packed-struct package
variable. Golden reads `p::f::h.idx[i + 1]::idx::i`; ours kept `p::f::i`. Found by the first MD grid's
package control (it was STRICT_NOTEQUAL on pristine), then written as its own law. A class method inside a
package stays pass 310's. Cases: cases/PK.

### § methRecvIdxAtPath312 — `R11U312_METHIDXPAR_OFF` (`methRecvIdxAtPath312`, design-final)

Consider a method-call path written inside a select's index (`r = iarr[iarr[i].get()].f`,
`h.idx[iarr[i].get()] = r`, `r = h.arr[iarr[i].get() + 1].f`). There the index of its receiver's select hangs
at the path in the definition view and reads its chain. Surelog compiles the inner path through
compileSelectExpression, which parents an element's index at the hier_path. Golden shows `\_ref_obj i`
under `\_hier_path iarr[i].get`, and its name is the parent chain's, which skips that path for a reference:
`work@grid::probe::iarr[].f::i` and `work@grid::probe::h.idx[]::idx::i`. Ours kept the receiver builder's
prefix (`...::iarr[].f::iarr[i].get::i`) or the method scope's (`work@grid::probe::i`).

In the elaborated view, golden's class bodies hang the index at the select again, and the name runs through
the path (`...::h.idx[]::idx::iarr[i].get::i`). There only the names move, and only inside a class: an
elaborated module keeps the stored name (golden `work@top.ia.i`). A first build renamed it there too, which
moved MI/mi31_module e one record away; it was fixed before any counted measurement.

Untouched:

- A path not written in an index (`r = iarr[i].get()`, a call argument).
- A method call's argument list. A draft climbed through it and moved MiniAmiq and SeqDriver d/t to
  STRICT_NOTEQUAL in its firing census (`space.substr(1, max1 - qc.queue[i].orig_type_name.len())` in
  uvm_factory::print, golden keeping the name through the inner path). It was fixed before any gate sweep;
  MI mi37 to mi39 are its controls.
- A name whose stored and chain values do not both lie in the enclosing scope and end in the object's own
  name.

These are pass 310's residue 1 and the method-path half of v11u310's residue 1 (r11u310repro MT mt61, mt62,
mt65 to mt68; v11u310repro VQ vq25 to vq29, VT/vt37). Cases: cases/MI.

### § lvMethPathInIdxNameSpan312 — `R11U312_LVMETHSPAN_OFF` (the receiver builder's § methPathInIdxNameSpan310 site)

A method-call path in the index of an assignment target's base select spans its first name. Example:
`iarr[iarr[i].get()].f = r` gives golden 13:10-14 where ours spanned the whole call, 13:10-23 (r11u310repro
MT/mt65, v11u310repro VQ/vq27). It reuses pass 310's rvalue rule, and a conditional's true branch keeps the
whole call.

Only the path's base select is covered. A member's select (`h.arr[iarr[i].get()].f = r`) keeps the whole call
in golden. A first draft moved LS ls05 and ls12 e off STRICT_EQUAL; it was fixed before measurement by gating
on the component index (`hpComp308() == 0`). Cases: cases/LS.

### § lvIpsNameFollowsHpRender312 — `R11U312_IPSNAME_OFF` (§ hpIdxBaseHierPathEmpty94's site)

§ hpIdxBaseHierPathEmpty94 re-renders a path's name whose indexed part select has a path base
(`h.v[h.k +: 2] = 0` becomes `h.v[+:2]`). An assignment target's select had already frozen its full name
through the old text (`work@grid::probe::h.v[h.k+:2]::v`). It now takes the re-rendered text, as golden does
(`work@grid::probe::h.v[+:2]::v`). Only the old text standing whole between separators is replaced. Pristine's
own test (the name equal to the path's) keeps its getter call byte for byte. Cases: cases/IP ip01 to ip14.

### § ipsBaseSelCallRender312 — `R11U312_IPSBASE_OFF` (§ hpIdxBaseHierPathEmpty94's site)

decompileHelper's rows also cover a select and a user call written as the base. A bit_select renders `[` + its
index + `]` without its name; a func_call renders empty:

- `h.v[ia[i] +: 2] = 0`: golden hier_path `h.v[[i]+:2]`, ours the written `h.v[ia[i]+:2]`.
- `r = h.v[fn(i) +: 2]`: golden `h.v[+:2]`.

The index must be a constant or a reference. These cases were at uhdm-cmp stage 1 on pristine and reach 0
lines. Cases: cases/IP ip20 to ip31.

### § ipsBaseNamesByChain312 — `R11U312_IPSBASENAME_OFF` (`ipsBaseNames312`, design-final)

The named objects inside a member path's indexed-part-select base read their chain when the base is a select,
a call or a path. Golden reads `work@grid::probe::h.v[[i]+:2]::v::ia` and `...::v::i`, or `work@top.a.v[[i]+:
2].v.ix`; ours kept the scope's name. A reference written directly as the base already read its chain and is
not touched. Cases: cases/IP.

### § lateCallIdxNameSpan312 — `R11U312_LATECALL_OFF` (the call branch for a method declared below its caller)

A call to a class method declared below the caller is emitted by its own branch, which bypassed
§ hpIdxCallNameSpan184 and § methIdxCallNameSpan310. When such a call is written in a non-trailing select's
index or a receiver's index, it spans its name. Example: `r = iarr[fwd(h.k)].get()` gives golden `fwd`
9:14-17, ours 9:14-26 (r11u310repro FX/fx02). A conditional's true branch keeps the whole call. The
assignment-target base-select twin of § lvRootSelCallNameSpan312 is under this switch too. Cases: cases/LC,
LR/lr25.

### § lvRootSelCallNameSpan312 — `R11U312_LVROOTCALL_OFF` (the call branch, § procLvCall181's whole span)

A call written in the ROOT select's index of an assignment target path spans its name. This applies in a
process or a subroutine, directly or under an operation. Examples:

- `iarr[fn(i)].f = r` in a class method: golden `fn` 13:10-12, ours the whole call 13:10-15.
- `always_comb m[fn(i)].b = 0`.
- a module task, `always_ff` and `<=`, `+=`, named arguments.

Surelog compiles that index as a read. A member's select (`h.arr[fn(i)].f`) and a trailing select
(`h.idx[fn(i)]`) keep the whole call, and so does a conditional's true branch. This is the item (1) residue
"the module-level call in the root's select of a member-path target". Cases: cases/LR. Downstream: LR/lr17
EQUIVALENT -> IDENTICAL, because the call's span is the src attribute the plugin reads.

### § memberSelCallIdxParenSpan312 — `R11U312_MEMCALLIDX_OFF` (§ memberSelParenIdxSpan184's sites and the member-chain trailing select)

A member select anchored at its index, whose index is a call slang's range stops short of, spans the written
invocation. Example: `r = h.idx[iarr[i].get()]` gives golden 13:15-28 through the closing parenthesis; ours
stopped at the method name, 13:15-26 (r11u310repro MT/mt67, v11u310repro VQ/vq29). This follows
§ callParenSpan11's and § bitSelMethodCallIdxSpan207's model. Cases: cases/MS.

## Grid (cases/; drivers/gen312.sh writes it, gridall.sh, gridsum312.py, attrib312.py, awaygrid.sh)

The grid has 220 case dirs in both views (440 case-views; every line carries its exit code; evidence/grid.txt,
grid_summary.txt). Each case's first line names its law (`// § <law>`). The `_ctl` cases are controls the law
must not move or that its gate excludes.

| group | law | dirs | case-views | moving | entering STRICT_EQUAL | leaving | STRICT_EQUAL after |
|---|---|---|---|---|---|---|---|
| TH | § lvIdxThisPathIsRead312 | 30 | 60 | 44 | 40 | 0 | 52 |
| CC | § clsLvTrailConcatTarget312 | 18 | 36 | 24 | 24 | 0 | 36 |
| MD | § modTfLvTrailIdxNamesByChain312 | 23 | 46 | 40 | 37 | 0 | 43 |
| PK | § pkgTfLvTrailIdxNamesByChain312 | 12 | 24 | 20 | 20 | 0 | 24 |
| MI | § methRecvIdxAtPath312 | 41 | 82 | 39 | 31 | 0 | 65 |
| LS | § lvMethPathInIdxNameSpan312 | 16 | 32 | 25 | 21 | 0 | 29 |
| IP | § lvIpsNameFollowsHpRender312 (ip01-ip14), § ipsBaseSelCallRender312 (ip20-ip31), § ipsBaseNamesByChain312 | 26 | 52 | 42 | 38 | 0 | 46 |
| LC | § lateCallIdxNameSpan312 | 14 | 28 | 18 | 18 | 0 | 28 |
| LR | § lvRootSelCallNameSpan312 | 28 | 56 | 34 | 30 | 0 | 49 |
| MS | § memberSelCallIdxParenSpan312 | 12 | 24 | 12 | 11 | 0 | 21 |
| total | | 220 | 440 | 298 | 270 | 0 | 393 |

- No exit code changes, and `R11U312_OFF` equals pristine on 440 of 440 case-views.
- uhdm-cmp line counts change on 24 case-views, and none grows:
  - 20 go from stage 1 to 0 lines: IP ip20 to ip24 and ip27 to ip31 in both views (§ ipsBaseSelCallRender312,
    the path's VpiName).
  - 4 shrink by 2 at stage 1 on both binaries: TH/th15_twod and th21_extern in both views, whose 2-D and extern
    heads are unrelated.
- Attribution (drivers/attrib312.py, each mover rerun with each switch alone; evidence/grid_attrib.txt): 255 of
  the 298 movers are restored to pristine's bytes by exactly one switch:

  | switch | movers |
  |---|---|
  | METHIDXPAR | 44 |
  | THISIDX | 42 |
  | MODTF | 38 |
  | LVROOTCALL | 31 |
  | CONCATLV | 22 |
  | LATECALL | 22 |
  | PKGTF | 18 |
  | IPSNAME | 14 |
  | IPSBASE | 8 |
  | LVMETHSPAN | 8 |
  | IPSBASENAME | 2 |
  | CONCATLV or MODTF alone | 4 |
  | CONCATLV or PKGTF alone | 2 |

  The other 43 need two or more, because one case fires several laws:

  | switches | movers |
  |---|---|
  | LVMETHSPAN + METHIDXPAR | 10 |
  | MEMCALLIDX + METHIDXPAR | 10 |
  | IPSBASE + IPSBASENAME + IPSNAME | 6 |
  | IPSBASE + IPSBASENAME | 6 |
  | IPSNAME + THISIDX | 4 |
  | IPSNAME + METHIDXPAR | 4 |
  | IPSBASENAME + IPSNAME | 2 |
  | LVROOTCALL + METHIDXPAR | 1 |

  MEMCALLIDX acts on every case where it fires but never restores a case alone, because those cases' index
  reference is METHIDXPAR's too.
- The chain-keyed away census (drivers/awaygrid.sh, awaychain.py, and strictcmp_x built by drivers/cc_x.sh)
  reads chain away 0 and flat away 0 on all 298 movers, with 689 records toward golden
  (evidence/grid_away.txt). With the binaries swapped, the positive control reads away on 12 of 12 sampled
  movers (evidence/away_poscontrol.txt).
- The 17 movers with no record toward golden are of two kinds:
  - Byte-only: the definition-view re-parenting of § methRecvIdxAtPath312 on cases whose names already agreed
    (MI mi13, mi14, mi24, mi35, LS/ls16), a parent the strict walk does not key on.
  - Stage 1 on both binaries with unrelated heads: IP/ip25, LR/lr14, LS/ls13, MI mi29 and mi31, TH th15 and th21.
- Downstream (drivers/dscases.py, both lanes; evidence/downstream_cases.txt) on the 46 module-, interface- and
  program-scope dirs:
  - 44 are IDENTICAL on both binaries.
  - LR/lr17_modproc and LR/lr27_implicit go EQUIVALENT -> IDENTICAL: the call's span is the src attribute the
    plugin reads.
  - None is worse.

## Controls

- **Firing scans** (drivers/firescan.sh): the law binary under `R11U312_TRACE` over 32321 fence-filtered dut.sv
  dirs under tools/probe and tests/probe; `VIEW=e` adds `--elabuhdm`.
  - 223 dirs write a trace line in the definition view and 246 in the elaborated view. The union is 246: 168 of
    them this pass's, and 78 earlier dirs (evidence/firescan_d.txt, firescan_e.txt).
  - One tests/probe dir writes a line, r10uvm171repro/g171_b_homes, in the elaborated view only and with
    METHIDXPAR_ABSTAIN only, which moves nothing. The gate runs the definition view.
- **Crashes** (evidence/crashes.txt): the scans see 1 segfault in the definition view and 8 in the elaborated
  view, as pass 310's did. Pass 310's nine named dirs exit 139 on pristine and on the law binary alike:
  v11u112repro m07_hdr_enum_default (both views), r10vrgg8repro v8_recurse, v8_recurse_mutual and
  v8_recurse_uncond, r11u254repro F/f04_class, r11u300repro RS/s22_recursion, and v11u254repro F/vf02_iface and
  vf04_hier.
- **Standard byte controls** (drivers/controls.sh, both views): every dut.sv dir of r11u118, r11v11u118,
  r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131, r11u178, r11u181, r11u184, r11u190verify,
  r11u296, v11u296, r11u304, v11u304, r11u306, v11u306, r11u308, v11u308, r11u310 and v11u310 (4830
  case-views; evidence/controls_std_summary.txt, controls_away.txt).
  - 45 move, 33 enter STRICT_EQUAL, 0 leave, and there are no exit-code or uhdm-cmp line changes.
  - Chain away is 0 on all 45, with 62 records toward golden.
  - Entering:
    - r11u310repro: FX/fx02 d/e, MT mt61 d, mt65 d/e, mt66 d, mt67 d/e, mt68 d and mt72 d.
    - v11u296repro: VT/vt14_task_lvalue d/e.
    - v11u308repro: VX vx06_namedcall_unlinked d/e, vx08_purevirt d/e and vx25_lvidx_call d/e.
    - v11u310repro: VC/vc22 d/e, VQ vq25 d, vq26 d, vq27 d/e, vq28 d and vq29 d/e, VT vt27 d/e, vt36 d/e and
      vt37 d/e.
  - The others move toward golden or by bytes only:
    - r11u310repro MT/mt64 d: STRICT_EQUAL on both binaries, a re-parented index.
    - mt62 d: toward 1; its zero-width `h` column stands.
    - v11u310repro VT/vt18 d/e: toward 2 each; the sister's typespec head stands.
    - VT/vt40 d/e: toward 3; interface functions, stage 1.
    - v11u308repro VX/vx07 d/e: toward 1; extern, stage 1.
    - r11u178repro hp/m12 d/e: toward 2; stage 1.
    - r11u190verify RT/r01 d/e: 0 records either way, stage 1 on both binaries.
- **Trigger controls** (drivers/controls_list.sh, both views): the 44 firing dirs outside this pass and outside
  the standard controls (evidence/trigger_dirs.txt; 88 case-views; controls_trig_summary.txt,
  controls_trig_away.txt).
  - 36 move, 21 enter STRICT_EQUAL, 0 leave, and no exit code changes. Chain away is 0 on all 36, with 163
    records toward golden.
  - Entering: r11u170verify th/t01, r11u194verify I/i03, r11u244repro D/d14 and L/i10, r11u256repro M/m18,
    v11u187repro T/t23, v11u195repro A/a02 d, v11u207repro D/d05, v11u252repro VX/vx09_extern_below_caller,
    v11u256repro M/vm13 and v11u286repro VQ/vq06 (d/e unless marked).
  - uhdm-cmp lines change on 12 case-views, and none grows:
    - 8 go from stage 1 to 0 lines: r11u244 L/i10, r11u256 M/m18, v11u256 M/vm13 and r11u229verify I/i02, in
      both views. i02 now stops at a fullname head.
    - 4 shrink at stage 1 on both binaries: r11u187 T/t17 160 -> 156 and v11u224 LX/lx16 202 -> 200 and
      234 -> 232, in both views.
- **The 70 probe residues** in both views (drivers/controls_list.sh): 140 case-views, 0 moving.
- **The firing census** (drivers/tracecensus.sh): the law binary through the harness over the probe cases and
  both corpora in both modes, with the four fenced tests excluded by the filter. It was frozen before the law
  sweep and wrote no line (evidence/predict.txt is empty).
  - Its Earlgrey_0_1 testflags draw read TIMEOUT under the machine's load, so that row was rerun alone after
    the law sweep. It read CMP_EQUAL with no trace line in either mode (evidence/predict_poscontrol.txt).
  - byteverify confirms the empty prediction: 0 movers.

## Gates (evidence/gates.txt)

Both sweeps ran `tests/sweep.sh --jobs 3` from the worktree, with SLANG_UHDM exported and workdirs of equal
length (/tmp/r11u312_wdP, /tmp/r11u312_wdL). Each sweep exits 1 on the law-index check alone; tests/LAWS.md is
regenerated last, by scripts/law_index.py.

- **probe:** pristine 4017 + 70, law 4017 + 70; regressions 0, conversions 0 and changes 0 on both.
- **surelog:** 480 + 0 / 474 + 0 on both; regressions 0, conversions 0, changes 0. The csvs differ only in the
  LowMemLib and LowMemPkg testflags detail text, which names the workdir.
- **uhdm2rtlil:** 803/1/67 in both modes on both binaries; regressions 0, conversions 0, changes 0; the csvs are
  identical.
- **downstream:** 803/66/2/0 on both, and both csvs are byte-identical to results/downstream_uhdm2rtlil.csv.
- **uhdm-cmp:** 0 lines on every row the sweeps read CMP_EQUAL, as at the base (no row status moved).
- **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered mirrors built by drivers/mirror.sh):
  0 of 3365 corpus and downstream-lane databases move. A cmp loop over the 4087 probe databases finds 0 moving.
  - Predicted: the census's empty list.
  - SELFCHECK reads 3363 of 3365 flagged. The reference is the first sorted path,
    downstream/1DUnpackedArray/slang.uhdm, which is byte-identical to its twin
    uhdm2rtlil/testflags/1DUnpackedArray-3af704bd/slang.uhdm (the same test with the same arguments). So the
    two unflagged files are the reference and its twin, and every other file is flagged: the comparator works.
- **canaries:** surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 and 6).
- **binary-path audit** (drivers/audit.sh): pristine sweep own 3265, other 0; law sweep own 3265, other 0. 50
  cmds.txt run no slang, and the 8 fenced row-modes are skipped by name.
- **determinism** (drivers/det.sh; evidence/determinism.txt): three concurrent draws per row-mode of
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes read one hash
  each. The hash equals the law sweep's and the pristine sweep's. Scoreboard and Rggen testflags write no
  database, as at the base.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **A method-call argument in a receiver path inside an index, elaborated view** (MI/mi17 e, mi39 e, mi40 e,
   MS/ms03 e, LS/ls14 e). Example: `r = iarr[iarr[i].put(j)].f`. The first differing record is a class_var
   `j`: golden's full name reads `work@grid::probe::iarr[].f::iarr[i].put::j`, ours `work@grid::iarr`. The
   definition view is STRICT_EQUAL. Not decoded: the record may be the argument's actual reached through the
   walk rather than the declaration itself.
2. **The method path nested two levels or behind an operation in a receiver's index** (stage 1 on both
   binaries, where golden's hier_path text differs): MI mi09 `iarr[iarr[i + 1].get()]`, mi16 (2-D receiver)
   and mi26 (`this.iarr[i].get()`); and the zero-width column of a deeper receiver `iarr[i].nx.get()` (MI/mi12,
   golden `nx` at 13:24-24).
3. **Stage 1 on both binaries, heads not decoded here:** class handles in module and interface bodies (MI
   mi31 and mi41, the shape of pass 310's vm51 and vm54), an interface subroutine (MD/md03 d), a program
   (MD/md07), and an extern method declared below its caller (LR/lr28).
4. **Concatenation targets with a root-select call or method path** (LR/lr14 `{iarr[fn(i)].f, r} = 2`, LS/ls13):
   stage 1 on both binaries. Ours lists a hier_path `iarr[].f` with the call under it, and golden lists no such
   hier_path at that place. The structure is not decoded. The span laws still move their bytes, with 0 records
   either way.
5. **A class-scope no-argument call as a member select's index** (MS/ms02 `r = h.idx[item::sget()]`): golden's
   hier_path is named `h.idx[item::sget]`, ours `h.idx` (uhdm-cmp stage 1 on both binaries). This is the
   path-name renderer's class-scope call row.
6. **The indexed part-select width written as a package parameter** (IP/ip11 `h.v[h.k +: p::N]`): golden's
   folded width constant ends one column earlier, the pkg:: span family of § pkgQualCallQualSpan131.
7. **The select and system-call bases § ipsBaseSelCallRender312 leaves alone** (IP ip25 `h.v[ia[i + 1] +: 2]`,
   ip26 `h.v[$clog2(i) +: 2]`): stage 1 on both binaries. Golden names the paths `h.v[[i + 1]+:2]` (the
   operation index pretty-printed inside the brackets) and `h.v[+:2]` (a system call renders empty); ours keeps
   the written text. This is the next law on this ground: the same decompileHelper rows, extended to an
   operation index and a system call. § ipsBaseNamesByChain312 already moves ip25's bytes, with 0 records
   either way.
8. **Pass 310's other residues stand:**
   - the with-clause receiver followed by a member (v11u310repro VM/vm72);
   - qc08's plain inner path spanning its first name;
   - mt62's zero-width base;
   - the call argument's ref_typespec in a module's non-trailing index (qc10, vq38);
   - the stage-1 heads (2-D receivers, `this.` index and receiver, extern, `super.`, interface functions,
     randomize-with, typedef and generate casts).
9. **The 70 probe residues** at the base: none moves in either view on this binary. This ground's among them
   stand as passes 308 and 310 listed them: t12, r11v21repro/v15, vh_arrelem, r11v4repro/v6, l_concat and the
   four r11u109 64-bit value cases (a Surelog defect).

## Sister-ground faces (reported, not written)

- The `<in>h_t.idx` ref_typespec full name of an unpacked struct member typespec (the first MD grid's head on
  every unpacked-struct holder, v11u310repro VT/vt18's head after this pass). Golden stores no full name on
  these three ref_typespecs, and ours writes `<in>h_t.idx`. It is most likely TypeEmit's struct member listing;
  not backtraced.
- LR/lr22_iface (an interface `always_comb m[fn(i)].b = 0`, the law converting its call span): the struct
  typespec's end line runs to the use site (golden 2:9-3:25, ours 2:9-2:41). This is the interface-body struct
  typespec end that passes 306 and 308 reported in TypeEmit.
- LR/lr23_cont_ctl e (`assign m[fn(1)].b = 0`): the elaborated cont_assign's ref_typespec named `work@top.m[].b.m`
  in golden. This is ModuleEmit's elaborated continuous-assignment clone, a module-scope face no law of this
  pass touches.
- vq51 (pass 310's verifier: a call in a ternary true branch inside a definition-view for-generate statement)
  stands as reported, most likely TypeEmit emitSyntaxExpr from ModuleEmit emitDefGenStmts.

## Process

- Worktree /tmp/wt_r11u312 at ad7db986, scratch /tmp/r11u312_* and the session scratchpad. Built with -j 2.
  The pristine binary was frozen before any edit; its md5 equals the main tree's build/slang-uhdm. While the
  worktree built, exploration ran on a read-only copy of the main tree's binary (the same md5).
- Drivers were copied from tools/probe/r11u310repro/drivers and renamed to R11U312 / r11u312. New drivers:
  - gen312.sh, which writes the whole grid;
  - mkcase.sh, a case writer with pass 310's class template;
  - pair.sh, which writes both producers' dumps side by side for decoding;
  - attrib312.py, the per-switch attribution;
  - gridsum312.py, a renamed copy of pass 310's.
- **THE FENCE:**
  - Every driver reads $FENCED fail-closed (four names) from tools/probe/r11u107repro/canaudit.sh.
  - Every path list is built and filtered before any file is opened.
  - byteverify ran on fence-filtered mirrors, and the census filter excludes the four fenced tests by exact
    name.
  - The fence scan of this directory reads 0 files for each of the four names.
  - The UVM decode read only uvm_factory.svh line 1586 and the MiniAmiq and SeqDriver databases, none of them
    fenced.
- **Draft breaks, caught before any counted measurement:**
  1. § lvMethPathInIdxNameSpan312's first draft fired on a member's select too and moved LS ls05 and ls12 e off
     STRICT_EQUAL. It is now gated on the base select.
  2. § methRecvIdxAtPath312's first draft climbed through method-call argument lists. Its firing census
     predicted MiniAmiq and SeqDriver d/t moving (22 firings each), and that census's csv read them
     STRICT_NOTEQUAL fullname(33) and (22): `space.substr(1, max1 - qc.queue[i].orig_type_name.len())` in
     uvm_factory::print, where golden keeps the name through the inner path. The climb now stops at a method
     call and at a path the child is an element of; MI mi37 to mi39 are the controls. The gate sweep never
     ran that draft.
  3. Its second draft renamed in the elaborated view of a module too, which moved MI/mi31 e one record away in
     the away census. It now renames in class bodies only.
  4. The thisIdx law's first form turned an inc/dec operand into the read form (TH/th20 at fullname). The
     postfix form is now kept.
  5. The first MD grid's package control was STRICT_NOTEQUAL on pristine, so it became
     § pkgTfLvTrailIdxNamesByChain312 with its own grid PK.
  6. Four draft cases were not legal SV or did not compile on either binary, and were rewritten:
     - th18 (`super.` with no base class);
     - md16 (a $unit class referenced from a package);
     - ip11 (an undeclared width);
     - ip14 (a continuous-assignment target with a variable index).
  Each fix rebuilt the law binary. Every measurement above was redone on the final binary 4fe9e91d: the census,
  both sweeps' law half, the grid, the controls, the scans, byteverify and determinism. The pristine sweep is
  on the frozen pristine binary.
- **SLIPS, no effect:**
  1. One wait loop used `pgrep -u <uid> -f` with a pattern that its own command line contained. It ended
     because its file condition became true; nothing was killed by it.
  2. Superseded measurement runs (a sweep, the controls and a firing scan on intermediate binaries) were stopped
     by their own process groups after their command lines were checked for this pass's name. No other agent's
     process was listed or touched.
  3. One rm was refused by the harness's safety check for an unguarded variable; it was rewritten with literal
     paths.
  4. The first copy of the drivers put a `#` history comment ahead of strictcmp_x.cpp's first line, which broke
     its build; this was fixed to `//`.
  Nothing was written to the main tree.
- No patch file is kept in this directory; the delivery /tmp/r11u312.patch is transport only.
