# v11u314 — adversarial verification of r11u314

Pass 314, expression/parameter ground: nine laws in src/ExprEmit.cpp (the `this.` select in an lvalue index, the
named-block lvalue index names, the indexed-part-select base renders and names, the package-qualified width, a
static class call as a trailing index, and the built-in and plain-element spans of a method path in an index).

Base e18396e3. Worktrees /tmp/wt_v11u314 (law) and /tmp/wt_v11u314pris (pristine), scratch /tmp/v11u314_*.
Implementer's patch: /tmp/r11u314.patch.

## Verdict: ACCEPT, no production change

- The verifier found NO case on legal SV where pristine was right and the law wrong, so it made no production
  change. The verified patch carries the implementer's src/ExprEmit.cpp byte-identical.
- The verified patch adds two things to the implementer's:
  - this directory;
  - one law-line fix in the implementer's grid. r11u314repro/cases/XT/xt11_builtin_iface named a law that does not
    exist (`// § lvBuiltinMethPathInIdxNameSpan314`). It now names § builtinMethPathInIdxNameSpan314, in the case
    and in drivers/grid314.inc. Its verdicts are unchanged: stage 1 at 52 uhdm-cmp lines on both binaries in both
    views.
- tests/LAWS.md is regenerated last.

## Binaries (evidence/gates.txt)

- Both binaries were rebuilt in fresh worktrees at e18396e3 with `-j 2`, then frozen (chmod 555 copies under
  /tmp/v11u314_bin) before any measurement.
- **Pristine:** 4b092c61f9f3d041af67fb9ffdc4d985, equal to the main tree's build/slang-uhdm when it was frozen.
- **Law:** 31f5e27212d0045027a74221de9cc109, equal to the implementer's.
- Both report slang 12.0.0+545f88b2e.
- The main tree's binary later read 7e2d102a. Another session rebuilt it with uncommitted src/ModuleEmit.cpp edits
  in the main tree; this pass did not. No sweep of this pass ran that binary: the audit reads own 3265, other 0.

## Reproduction of the implementer's numbers (all bit for bit)

- **Grid:** the implementer's 225 dirs in both views with every switch, 5400 lines.
  - Every line matches evidence/grid.txt except the md5 field, which embeds the worktree path.
  - Totals: 450 case-views, 350 moving, 318 entering STRICT_EQUAL, 0 leaving, R11U314_OFF equal to pristine 450 of
    450, no exit-code change, uhdm-cmp line counts changing on 146.
  - The attribution is identical line for line (evidence/attrib_impl_repro.txt; evidence/impl_grid_repro_md5.txt holds the md5 of both sorted grids with the md5 field removed, equal): 290 single-switch movers (THISSEL
    64, PKGIPSW 60, NAMEDBLK 54, ZEROWIDTH 26, SCOPEDCALLIDX 22, BUILTINSPAN 20, IPSBASEOP 18, IPSBASENAME 14,
    IPSINNER 12) and 60 needing IPSBASEOP and IPSBASENAME together.
- **Gate sweeps:** `tests/sweep.sh --jobs 3` on both binaries, workdirs of equal length (/tmp/v11u314_wdP and
  /tmp/v11u314_wdL).
  - probe: 4017 EQUAL + 70 STRICT_NOTEQUAL.
  - surelog: 480 + 0 / 474 + 0. The one testflags TIMEOUT is Google, as in the baseline.
  - uhdm2rtlil: 803/1/67 in both modes.
  - downstream: 803/66/2/0.
  - Every stage reads regressions 0, conversions 0 and changes 0.
  - The csv rows of law and pristine are identical in all three csvs once the workdir is normalised (the implementer
    saw 4 LowMem detail lines; here they normalise away). Both downstream csvs are byte-identical to
    results/downstream_uhdm2rtlil.csv.
  - Both sweeps exit 1 on the law-index check alone. The index records the commits of each law, so it reads stale in
    any worktree; in a fresh checkout of e18396e3 with /tmp/r11u314.patch applied, `scripts/law_index.py --check`
    reads current.
  - stamped_gen_param d/t stays CMP_NOTEQUAL.
- **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors: 7452
  linked, 8 fenced row-modes skipped):
  - PATH_SETS_IDENTICAL, 0 of 3365 corpus and downstream databases moving.
  - SELFCHECK 3363 of 3365. The reference is the first sorted path, downstream/1DUnpackedArray/slang.uhdm, and it is
    byte-identical to its twin uhdm2rtlil/testflags/1DUnpackedArray-3af704bd/slang.uhdm (checked with cmp). So the
    two unflagged files are the reference and its twin, and the comparator works.
  - A probe database embeds its worktree path, so the pristine probe stage was rerun from the law worktree
    (/tmp/v11u314_wdQ; again 4017 + 70, regressions 0). A cmp of the 4087 probe databases reads 0 moving.
- **Canaries:** surelog ok=52 changed=0 and uhdm2rtlil ok=16 changed=0 on both binaries. ctcan2 (EXPECT_UNKNOWN=1
  and 6) reads PASS on all four csvs.
- **Binary-path audit** (drivers/audit.sh, the cmds.txt list fence-filtered before reading): the pristine sweep reads
  own 3265, other 0; the law sweep reads own 3265, other 0 (noslang 50, fenced skipped 8 on each).
- **Determinism** (drivers/det.sh, three concurrent draws of the law binary; evidence/determinism.txt):
  - Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen give one hash per row-mode.
  - Those hashes equal both sweeps' and the implementer's (Earlgrey_0_1 fc04e7f2bb3f / 025c86db2d2d, MiniAmiq
    6274d155ae91, SeqDriver 0140024e994f / dcc2c63e2e29, SimpleUVM 57a5aaad5589 / f0c85a0be92c, Scoreboard d
    e60363ba3f2d, BuildUVMPkg 00b6402714d5, Rggen d 4c21b84a350d).
  - Scoreboard and Rggen testflags write no database, as at the base.
- **Firing-census prediction** (drivers/predsrc314.sh, evidence/predict_frozen.txt):
  - The verifier's own source-text predictor was frozen before reading any law-sweep result. Its path list was built
    first and fence-filtered before any file was opened: 15667 sources, 15663 after the fence.
  - It named the only package-qualified indexed-part-select width in the corpora: the ariane sources, whose rows are
    SLANG_REJECT, SURELOG_FAIL or NO_DATABASE.
  - It found no class-scope call in an index (the S hits are package-qualified calls in dimensions), no `this.`
    select in an index and no method call on a selected receiver in an index.
  - The 561 sources with an operation, select or system-call base can only render equal to the written text or
    abstain.
  - So it predicted 0 corpus movers, as did the implementer's trace census (16 `IPSBASEOP_SAME_ABSTAIN` lines).
    byteverify confirms 0.

## The attack: 239 fresh case dirs, 478 case-views (cases/, drivers/genv314.sh + drivers/gridv314.inc)

- **Case design.** Every case's first line names the law it attacks. The class cases use the implementer's template
  with a few extra properties: string, queue and holder arrays, a nested class, a typedef of a class, and an untyped,
  a typed and an enum package parameter.
- **A discarded first template.** A first template declared `int da[4][]` and `int aa[4][string]`. Our exporter
  reports those as unsupported (exit 4) and golden fails at stage 1 on them, so every class case was stage 1 on both
  binaries. That template was discarded before any counted measurement: the three cases that used those properties
  were rewritten as VM/vm04_strq, vm05_strq_lv and vm13_lv_getc. VW/vw10's width (`c ? 2 : p::N`, not constant, exit
  3 on both binaries) was rewritten to `N2 > 1 ? 2 : p::N` before counting.

| group | law(s) attacked | dirs | case-views | moving | entering STRICT_EQUAL | leaving | equal after |
|---|---|---|---|---|---|---|---|
| VO | § ipsBaseOpSysRender314: shifts, %, &, sized, hex, unbased and signed literals, member, call, concatenation, ternary, cast, unary, package-parameter and enum operands, $bits, **, !, 2-D selects, nested selects, inc/dec, nonblocking, foreach, streaming target, `this.`, macros; module, header-parameter, for-generate, if-generate continuous assignment, interface port, enum, task, depth 3, implicit net, localparam, package function, struct-member operand | 50 | 100 | 50 | 44 | 0 | 92 |
| VW | § pkgQualIpsWidthSpanQualifier314: `p::N * 2`, `2 * p::N`, typed, untyped and enum package parameters, both bounds qualified, `-:`, an operation, a ternary condition and false branch, holder arrays, deep paths, a condition, a call argument, two widths; module process, continuous assignment, 2-D, task, header override, interface member, for-generate, net declaration, if-generate and port-connection member paths, `$unit::`, a class parameter, a parameter declaration, an own-package read, wildcard import with a qualified read, a macro | 36 | 72 | 62 | 56 | 0 | 58 |
| VS | § trailIdxStaticScopedCallName314: a class typedef, a nested class, a default argument, 2-D (first and last index), an operation index (rvalue and target), the own class unqualified and qualified, holder and member trails, a plain array, inc, nonblocking, a select argument, a non-static base method through the base class, static base and inherited methods, interface, module task, wildcard-imported package class, `#()` default specialization, a packed struct member, a static variable, a task body | 25 | 50 | 32 | 32 | 0 | 40 |
| VT | § lvIdxThisSelPathIsRead314: a `this.` root target, member chains, 2-D targets, streaming, a system-call argument, postfix and prefix decrement, a `this.` root with `++`, queues, a deep index, a named block, a for step, an ips base operation, member and holder targets, a cast, a ternary condition, two `this.` selects, unary, a named late call, constructor, derived, fork, static | 26 | 52 | 38 | 34 | 0 | 48 |
| VB | § tfLvTrailIdxNamedBlkScope314: loop and foreach blocks, a shadowing declaration, a static block variable, a constructor, 2-D, an rvalue control, a module variable control, automatic tasks, join_none, a named fork inside a named block, a class outer variable, a package function, an ips target, a nested select, an interface member | 16 | 32 | 24 | 22 | 0 | 30 |
| VM | § builtinMethPathInIdxNameSpan314 and § methPathPlainElemZeroWidth314: an operation, a select operation, getc, string queues, ternary false and condition, a sum, 2-D targets, a call-argument control, holder and member queue receivers, getc and string-queue targets, a condition, a trailing member select, a chained member, toupper; holder plain elements, `nx.nx`, plain both sides, trailing controls, an operation, an escaped name, module scope | 28 | 56 | 40 | 34 | 0 | 44 |
| VI | § ipsBaseInnerNamesFollowRender314 and § ipsBaseNamesReach314: a qualified width, `-:`, holder, `this.`, cast and deep bases, the same word in base and target; a system-call argument select, two indices, a cast index, a named block; if, case and for generate, a block, a generate-local, an interface block, a cast in a generate | 18 | 36 | 32 | 28 | 0 | 32 |
| VX | second batch: parenthesisation and precedence, binary, signed and unbased literals, shifts, negation, system call and equality in a select, concatenation, a reduction base, part- and ips-select bases under an operation, a header override, genvar bases, nested for-generates, modports, a generate condition parameter, a task named block, a function return, an unpacked struct; package widths in for-generate, modport, override, `-:`, two packages, a typedef'd package parameter, an interface body, a class `-:`; `this.` with `$urandom`, case, if/else and while; a macro plain element, a trailing member; nested and operation built-in paths | 40 | 80 | 58 | 45 | 0 | 65 |
| total | | 239 | 478 | 336 | 295 | 0 | 409 |

- Every case-view exits 0 on both binaries. No exit code changes, and R11U314_OFF gives pristine's bytes on 478 of 478.
- **Away census** (drivers/awaygrid.sh with awaychain.py and strictcmp_x): chain away 0 and flat away 0 on all 336
  movers, with 2454 chain records toward golden (evidence/away_fresh.txt, away_fresh2.txt).
- **uhdm-cmp lines:**
  - 177 case-views go from stage 1 to 0 lines and 5 shrink.
  - 8 grow, all at stage 1 on both binaries with the SAME first difference on both:
    - VW/vw11_harr and VW/vw23_mod_iface_member (d/e), 184 -> 188 and 164 -> 168;
    - VX/vx25_w_genfor_param and vx26_w_modport (d/e), 184 -> 188.
  - The head (the hier_path `harr[i].v[j+:1]` and `u.w[k+:2]`) is unchanged on both binaries. Four more lines print
    because the width constant now carries the declaration ref_typespec golden has, the same mechanism as the
    implementer's vh16. Away is 0 on each.
- **Attribution** (each mover rerun with each switch alone; evidence/attrib_fresh*.txt):
  - 266 movers are restored by one switch: PKGIPSW 78, THISSEL 46, SCOPEDCALLIDX 32, BUILTINSPAN 34, IPSBASEOP 36,
    NAMEDBLK 24, ZEROWIDTH 14, IPSINNER 2.
  - 70 need two or three: IPSBASEOP+IPSBASENAME 66, IPSINNER+PKGIPSW 2, IPSBASEOP+IPSBASENAME+IPSINNER 2.
  - Every switch changes bytes on its own somewhere.
- **Downstream** (drivers/dscases.py, both lanes) on the 55 class-free module, interface and generate dirs:
  - 51 IDENTICAL on both binaries.
  - 3 EQUIVALENT on both: VI/vi16_mod_genfor_sel, VW/vw27_unit and VX/vx18_genfor_genvar.
  - VO/vo50_mod_struct_member_op goes DIVERGENT -> IDENTICAL (pristine's database made the Yosys plugin report a
    serious-bug abort).
  - None is worse (evidence/downstream_fresh.txt).

## Whole-tree byte scan (drivers/bytescan.sh; evidence/bytescan_*.txt, controls_*.txt)

- **Scope.** Every dut.sv dir under tools/probe outside the two r11u314/v11u314 dirs: 28767 after the fence filter,
  the list built first and filtered by word boundary before any file was opened. Each dir ran on both binaries in
  both views and the databases were compared.
- **First prefilter list (9163 dirs).** 254 lines read MOVE:
  - 92 are dirs that exit 3 on both binaries with the single-file invocation, so neither writes a database and the
    cmp reads MOVE on two missing files. They are not movers.
  - One is the exit-139 dir v11u254repro F/vf04_hier e, which crashes on both binaries.
  - That leaves 162 real movers, all exit 0 on both binaries. Through case.sh they read 102 entering STRICT_EQUAL and
    0 leaving, with chain away 0 and flat away 0 on all 162 and 2228 records toward golden.
  - uhdm-cmp lines grow on exactly the 10 case-views the implementer explained (r11u116repro f2 gi_cb_q and gi_ff_q,
    r11u229verify I/i03, v11u236repro D/d01 d, v11u244repro B/b04_cls_forms d, v11u284repro VH/vh16), with away 0.
- **The remaining 19604 dirs** (no prefilter):
  - 422 lines read MOVE. 406 are exit 3 on both binaries and 8 are the known exit-139 dirs, which crash on both.
  - That leaves 8 real movers. r11u195repro A/a02, r11u312repro MI/mi12_deeprecv and v11u312repro VQ/vq06_deep_recv
    enter STRICT_EQUAL in both views from col. r11u244repro L/l19 stays at stage 1, shrinking by 4 uhdm-cmp lines.
    All 8 read away 0, with 6 records toward golden.
- **Whole tree:** 28767 dirs and 57534 case-views.
  - 170 movers, 108 entering STRICT_EQUAL, 0 leaving, no exit-code change.
  - Chain away 0 and flat away 0, with 2234 records toward golden.
  - The 9 exit-139 dirs crash on both binaries, exactly the nine passes 310 to 314 named: v11u112repro
    m07_hdr_enum_default d/e, and the elaborated views of r10vrgg8repro v8_recurse, v8_recurse_mutual and
    v8_recurse_uncond, r11u254repro F/f04_class, r11u300repro RS/s22_recursion, and v11u254repro F/vf02_iface and
    vf04_hier.
  - 498 case-views exit 3 on both binaries: dirs that need more files or arguments than the single-file invocation.
    They are a coverage gap of this scan, the same on both binaries.
- **Coverage of the implementer's lists.** Every entering dir the implementer named in its standard and trigger
  controls moves and enters STRICT_EQUAL here too.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The implementer's residues stand as listed in r11u314repro/README.md (the elaborated-view method-call argument
   decoded to UhdmExporter's class-property array element name, IO/io11, IN/in09, PW/pw20, the stage-1 shapes).
2. Fresh, not reached by § ipsBaseNamesReach314:
   - a case-generate scope: VI/vi13 `ix` named `gc.ix`, golden `gc.a.v[[k + 1]+:2].v.ix`, fullname;
   - a 2-D var_select inside the base: VO/vo18 `ib` named `work@grid::probe::ib`, golden
     `...::h.v[[i][j + 1]+:2]::v::ib`;
   - an indexed part select inside an operation base: VX/vx14 `lv` named `work@grid::probe::lv`, golden
     `...::h.v[i+:2 + 1+:2]::v::lv`.
3. A plain or nested path written in a non-trailing select's index, which golden spans to its first name (pass 310's
   qc08 class, not one of this pass's shapes):
   - VM/vm20 `iarr[harr[i].hh.k].f` (hier_path end 18 against ours 26, both binaries);
   - VX/vx39 `iarr[iarr[sarr[i].len()].f].f` (the inner path end 18 against 35);
   - VM/vm26 `harr[i].idx[h.arr[i].get()] = r`, endcol on both binaries.
4. The member root of an inc/dec target with a rendered base (VO/vo29 `h.v[ia[i + 1] +: 2]++`): golden's `h` sits at
   column 7, ours at 5. It moved from stage 1 to col.
5. Stage 1 on both binaries, not decoded:
   - VS: vs06 and vs07 (`item::sget() + 1` as a trailing index), vs10 (`harr[item::sget()].k`), vs11 (a member trail
     with a static call);
   - VO: vo14 (a package enum operand in the base), vo24 (a holder-array target);
   - VT: vt02 (`this.h.idx[i]` in a target index), vt16 (a holder-array target);
   - VB/vb02 (a foreach block); VM/vm02 (a select-operation receiver), vm19 (`toupper().len()`), vm27 (an escaped
     receiver), vm28 (module scope);
   - VX: vx18 (a genvar base in the elaborated view), vx21 (a generate-condition parameter), vx25 and vx26 (for-generate
     and modport widths), vx30 (a typedef'd package parameter), vx37 (a macro plain element);
   - VW: vw05 (an enum width), vw27 (`$unit::`), vw30 (a parameter declaration), vw31 (an own-package read), vw36 (a
     port connection);
   - VI/vi16 (a for-generate array of structs).
   - vs12 (a plain array with a static call) reads fullname on both binaries.

## Sister-ground faces (reported, not written)

- The implementer's: UhdmExporter.cpp's class-property array element reg storing its full name (`reg->VpiFullName(pfn)`;
  UHDM's method_func_call clone copies it into the elaborated view), and PW/pw20's port-connection select parent
  (ModuleEmit emitInstance).
- No new sister-ground face was isolated by this attack.

## Process

- **The fence.**
  - Every driver that opens a source or a database reads $FENCED fail-closed (drivers/env.sh, copied from r11u314repro
    with this pass's paths).
  - The predictor, the byte scan, the mirrors and the audit build their path lists first and filter them before
    opening any file.
  - The fence scan of this directory reads 0 files for each of the four names.
- **THE VERIFIER'S SLIP (fence), no effect on any measurement.** One lookup of which `.sl` file lists the ariane
  sources ran `grep -l` over the glob `Surelog/tests/*/*.sl` (and third_party/tests). That glob includes the four
  fenced tests' `.sl` command-line files, so grep opened them before the list was filtered. Its output named only
  Ariane2024. No fenced source, database or binary run was involved, and no fenced fact is used here. Every later
  scan built and filtered its list first.
- **Other slips, no effect:**
  1. The first away census ran before awayrows.py was copied and with driver files lacking the executable bit; it
     printed nothing and was rerun.
  2. The first byte-scan run read relative paths from the main tree's cwd, where the `cd` failed for every dir, so no
     binary ran and nothing was written. It was stopped by its own task id and rerun with absolute paths.
  3. Two lines of the attack grid include had a broken shell quote: the shell printed errors and wrote no file. The
     worktree and the main tree were checked to hold no stray file.
- Nothing was written to the main tree. No process this pass did not start was touched, and no other agent's command
  line was listed.
- No patch file is kept in this directory; the delivery /tmp/r11u314.verified.patch is transport only.
