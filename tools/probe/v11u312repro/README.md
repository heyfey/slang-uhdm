# v11u312 — adversarial verification of r11u312 (pass 312, expression/parameter ground)

Verdict: **PASS, no production refinement.** The implementer's patch (src/ExprEmit.cpp, twelve laws read through
src/LawSwitch.h as `lawOn(312, "R11U312_<X>_OFF")`, `R11U312_OFF` for all, `lawTrace(312, ...)` under
`R11U312_TRACE`) is carried byte-identical. Every headline number reproduced bit for bit. 290 fresh case dirs
(580 case-views) found no case on legal SV where pristine was right and the law wrong. A whole-tree byte scan over
every fence-filtered case dir under tools/probe and tests/probe, in both views, found no mover outside the
implementer's own grid and its 81 control movers. There is no `src/R*.h`, no src/LawState.h section and no
getenv in the added lines.

## Binaries (built by this verifier, frozen chmod 555 under /tmp/v11u312_bin before any measurement)

- Worktrees /tmp/wt_v11u312pris (pristine) and /tmp/wt_v11u312 (the implementer's patch, `git apply --check`
  clean on a fresh ad7db986), built with the system-deps config against ~/.local; pristine with `-j 2`, law with
  `-j 1` while the pristine sweep ran.
- pristine `be2074e1fde43c4025b5fb2370dbb2a8`: equal to the main tree's build/slang-uhdm at the base.
- law `4fe9e91d18cd806568767869e80b17e0`: equal to the implementer's law binary.
- Both report slang 12.0.0+545f88b2e. uhdm-strictcmp `fa6e4f42…` and strictcmp_x `886f0302…` (drivers/cc_x.sh),
  both equal to the implementer's.

## Gates (evidence/gates.txt)

Both sweeps ran `tests/sweep.sh --jobs 3` with SLANG_UHDM exported, workdirs /tmp/v11u312_wdP and /tmp/v11u312_wdL.

| stage | pristine | law |
|---|---|---|
| probe | 4017 EQUAL + 70 STRICT_NOTEQUAL, 0/0/0 | 4017 + 70, 0/0/0 |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 | the same |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 | the same |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same |

- Regressions, conversions and changes are 0 against the committed baselines in every stage.
- Both downstream csvs are byte-identical to results/downstream_uhdm2rtlil.csv.
- **The first pristine surelog stage was discarded.** It ran while the law binary compiled and this verifier's
  first grid ran, and Earlgrey_0_1 testflags read TIMEOUT (machine load, on the pristine binary). The surelog stage
  was rerun alone on a quiet machine: 480 + 0 / 474 + 0, 0/0/0.
- csv row diff law vs pristine: probe 0, uhdm2rtlil 0, downstream 0, surelog 4 lines (the LowMemLib and LowMemPkg
  testflags detail text naming the workdir).
- **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered mirrors (drivers/mirror.sh,
  7452 files each, 8 fenced paths skipped): 0 of 3365 corpus and downstream-lane databases move.
  - SELFCHECK flags 3363 of 3365. The reference is the first sorted path, downstream/1DUnpackedArray/slang.uhdm, and
    the one other unflagged file is its byte-identical twin uhdm2rtlil/testflags/1DUnpackedArray-3af704bd/slang.uhdm
    (listed by name in evidence/gates.txt). Every other file is flagged, so the comparator works.
  - Probe: a probe database embeds its worktree path, so the pristine probe stage was rerun from the law worktree
    (/tmp/v11u312_wdQ). 0 of 4087 probe databases move, and the probe csvs are equal.
- canaries surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 and 6), for
  both sweeps.
- binary-path audit (drivers/audit.sh): both sweeps own 3265, other 0, noslang 50, fenced skipped 8.
- **determinism** (drivers/det.sh, law binary, three concurrent draws): one hash per row-mode on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes, equal to both sweeps and to the
  implementer's hashes (Scoreboard and Rggen testflags write no database, as at the base).
- **firing census** (drivers/tracecensus.sh: the law binary under `R11U312_TRACE` through the harness over the probe
  cases and both corpora in both modes, the four fenced tests filtered out): 0 trace files, predict.txt empty, no
  TIMEOUT (Earlgrey_0_1 d/t CMP_EQUAL). Positive control: `R11U306_TRACE` and `R11U312_TRACE` through
  scripts/check_probe.py --filter c2_idxkind write pass 306's lines, and `R11U312_TRACE` on a grid case writes this
  pass's. byteverify's 0 movers agree with the empty prediction.
- Both sweeps exit 1 on the law-index check alone; tests/LAWS.md is regenerated in this patch.

## The implementer's measurements, reproduced (evidence/repro_impl.txt)

- **Grid:** its gridall.sh, case.sh and cases with this verifier's binaries and golden cache: 1320 lines, all rc=0,
  equal to its evidence/grid.txt on 1320 of 1320 lines but the md5 field (the databases embed the case path).
  `R11U312_OFF` equals pristine on 440 of 440. The gridsum312.py summary is identical: 298 moving, 270 entering,
  0 leaving, 24 uhdm-cmp line changes, none growing.
- **Away census:** identical line for line: chain away 0 and flat away 0 on 298 movers, 689 records toward golden.
- **Attribution:** the twelve switches run one at a time and attrib312.py: identical, 255 single and 43 multi.
- **Downstream** on its 46 module-scope dirs: 44 IDENTICAL on both, LR/lr17_modproc and LR/lr27_implicit
  EQUIVALENT -> IDENTICAL.
- **Controls:** the whole-tree byte scan below finds exactly its 81 control movers (45 standard + 36 trigger; the
  diff of the two lists is empty), 54 entering STRICT_EQUAL.
- **Firing scans:** excluding this verifier's dirs, 223 dirs fire in the definition view and 246 in the elaborated
  view, the lists equal to its firescan_d.txt and firescan_e.txt. The only tests/probe dir is
  r10uvm171repro/g171_b_homes in the elaborated view with METHIDXPAR_ABSTAIN alone.
- **Crashes:** the 9 known exit-139 dirs crash on both binaries (1 in the definition view, 8 in the elaborated view).

## Whole-tree byte scan (drivers/bytescan.sh, evidence/bytescan.txt, controls.txt)

Every dut.sv dir under tools/probe and tests/probe, the path list filtered by $FENCED before any file is opened:
32588 dirs in the definition view and 32611 in the elaborated view (the second scan includes this verifier's last
two groups). Both binaries run on the same dir with the same arguments, and their databases are compared by md5.

| view | moving | r11u312repro | v11u312repro | earlier passes | tests/probe | exit-code changes |
|---|---|---|---|---|---|---|
| d | 390 | 163 | 181 | 46 | 0 | 0 |
| e | 329 | 135 | 159 | 35 | 0 | 0 |

- The 81 earlier-pass movers, judged by case.sh on both binaries: 54 enter STRICT_EQUAL (31 d, 23 e), none leaves.
  r11u310repro MT/mt64 d is STRICT_EQUAL on both, a re-parented index. r11u229verify I/i02 d/e goes from uhdm-cmp
  stage 1 to 0 lines at a fullname head.
- Chain away 0 and flat away 0 on all 81, with 225 records toward golden. The uhdm-dump distance to golden falls on
  75 and is unchanged on 6.
- The 70 probe residues are among the tests/probe dirs: 0 moving in either view.

## Fresh attack (cases/, drivers/gen.py writes them; drivers/gridone.sh, case.sh)

290 fresh case dirs in both views, 580 case-views. Each case's first line names the law it attacks. Goldens are
the pinned Surelog's, built by drivers/goldwarm.sh with case.sh's key and arguments.

| group | law attacked | case-views | moving | entering STRICT_EQUAL | leaving | STRICT_EQUAL after |
|---|---|---|---|---|---|---|
| VT | § lvIdxThisPathIsRead312 | 70 | 38 | 34 | 0 | 60 |
| VC | § clsLvTrailConcatTarget312 | 40 | 24 | 24 | 0 | 38 |
| VM | § modTfLvTrailIdxNamesByChain312 | 56 | 45 | 42 | 0 | 50 |
| VX | § modTfLvTrailIdxNamesByChain312 (vx01-vx16), § lvRootSelCallNameSpan312 (vx17-vx24) | 48 | 22 | 18 | 0 | 38 |
| VK | § pkgTfLvTrailIdxNamesByChain312 | 16 | 14 | 14 | 0 | 16 |
| VI | § methRecvIdxAtPath312 | 80 | 34 | 3 | 0 | 66 |
| VQ | § lvMethPathInIdxNameSpan312 | 32 | 26 | 17 | 0 | 21 |
| VP | § ipsBaseSelCallRender312, § lvIpsNameFollowsHpRender312, § ipsBaseNamesByChain312 | 74 | 70 | 56 | 0 | 58 |
| VP2 | § ipsBaseSelCallRender312 | 12 | 10 | 8 | 0 | 8 |
| VS | § lvRootSelCallNameSpan312 | 40 | 24 | 24 | 0 | 36 |
| VL | § lateCallIdxNameSpan312 | 32 | 20 | 18 | 0 | 30 |
| VF | § lateCallIdxNameSpan312 (module, interface and class functions declared below their use) | 34 | 16 | 14 | 0 | 21 |
| VN | § memberSelCallIdxParenSpan312 | 46 | 10 | 9 | 0 | 41 |
| total | | 580 | 353 | 281 | 0 | 483 |

- No exit code changes. `R11U312_OFF` equals pristine on 580 of 580 case-views (evidence/fresh_grid.txt).
- uhdm-cmp line counts change on 66 case-views, all going from stage 1 to 0 lines (the VP, VP2 and VF IPS shapes
  of § ipsBaseSelCallRender312), none growing.
- **Away census** (drivers/awaygrid.sh, awaychain.py, strictcmp_x): chain away 0 and flat away 0 on all 353
  movers, with 1305 records toward golden (evidence/fresh_away.txt). The positive control (binaries swapped) reads
  away on 12 of 12 sampled movers (evidence/away_poscontrol.txt).
- **Dump distance** (drivers/dumpdist.sh: uhdm-dump line diff to golden, which sees the parent field the strict walk
  does not key on): 346 movers move toward golden and 7 are unchanged; none moves away (evidence/fresh_dumpdist.txt).
  This covers the 25 VI movers that are STRICT_EQUAL on both binaries (the only movers that are): § methRecvIdxAtPath312 re-parents the
  receiver's index at the hier_path in the definition view, and golden's dump shows the same parent (VI/vi04_fnarg:
  golden, pristine and law dumps compared).
- **Attribution** (drivers/tracetags.sh, attrib.sh): every mover writes at least one firing tag (245 one, 64 two,
  44 three). The switches of its tags set together restore pristine's bytes on 350 of 353. The other 3 (VP/vp10_methbase
  d, VP/vp17_strlen d/e) need IPSBASENAME as well: with METHIDXPAR off, § ipsBaseNamesByChain312 renames the
  same object (`IPSBASENAME work@grid::probe::i -> ...::h.v[+:2]::v::iarr[i].get::i`), so the two laws overlap on a
  method-call base and both are needed to restore. All three are STRICT_EQUAL under the law.
- **Downstream** (drivers/dscases.py) on the 68 module- and interface-scope fresh dirs: 63 IDENTICAL on
  both binaries, VX vx17_rootcall_packedarr, vx22_rootcall_depth3 and vx23_rootcall_implicit EQUIVALENT ->
  IDENTICAL (§ lvRootSelCallNameSpan312: the call's span is the src attribute the plugin reads), VP/vp31_mod_genfor
  EQUIVALENT on both and VX/vx08_vif_task STATUS_DIFF on both. None is worse (evidence/downstream.txt).

The shapes covered:

- **THISIDX:** `this.` targets with a select (`this.ia[2]`, `this.ia[this.i]`, `this.lv[3:0]`, `this.lv[this.i +: 2]`),
  a `this.` path under a call argument, a system call, a cast, a unary, a ternary, a concatenation, a nested select
  and a `this.` select in an index. Also prefix, postfix and compound operators, foreach, fork, if branches, a macro,
  an associative index, member roots, and derived, parameterized and task-output contexts.
- **CONCATLV, MODTF, PKGTF:** concatenation targets with reference, operation, call, select, parameter, enum and
  package-parameter indices, at depth 2 and 3 of nesting, with streaming, rvalue and plain controls.
  - Module, interface and program subroutines with task arguments, module variables, localparams, enums, wires,
    automatic and static locals, named blocks, for and foreach variables.
  - Holders: interface instances, ports and modports, hierarchical instance paths, virtual interfaces, packed and
    unpacked structs and packed arrays.
  - Contexts: if and for generate blocks, depths 2 and 3, two instances of one module, parameterized instances and
    a nested module. Package subroutines with package variables, parameters, imports and package classes.
- **METHIDXPAR:** built-in receivers (`string.len()`, `enum.next()`); method paths under a user call, a system call,
  a cast, a ternary, an operation, an if or case condition, loops, `$display`, a return, a call argument and an
  indexed part select. Also receivers with select, member, enum, package-parameter, localparam and bit indices,
  2-D receivers, the lvalue forms, and module, generate, interface and package-function scopes.
- **IPS laws:** bases with localparam, enum, package-parameter, constant, hex, vector, string and enum-array
  indices; static, package and class-scope calls, method and nested calls; `-:`, compound, a condition, a deeper
  path, a holder array and a package width. Module scope: always_comb, assign, always_ff, a task, depth 2, if and
  for generate, a parameter index, a function base and an rvalue.
- **Call span laws:** static, class-scope, package, nested, named, parenthesised and cast calls in a root select; a
  root select followed by a member select; 2-D, inc/dec and compound targets; ternary true and false branches;
  `this.` paths and holder arrays.
  - Module processes, a task, an interface, depth 3, an implicit net, a package function and a generate always_ff.
  - Functions declared below their use in modules (continuous assignments, always_comb, always_ff, generate, a net
    declaration, a task) and in an interface, and member selects with method, system, package, multi-line, macro,
    2-D and nested-call indices.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **A method-call argument inside a receiver index, elaborated view** (VI/vi11_putarg e, VQ/vq13_put e,
   VN/vn17_put e: the class_var `j` full name `work@grid::iarr` where golden has
   `...::iarr[i].put::j`). This is the implementer's residue 1; its definition views enter STRICT_EQUAL.
2. **A `this.` path reached through a select inside an lvalue index** (VT/vt13 `ia[this.ia[this.i]] = r`, vt17
   `ia[this.i[1:0]] = r`). Golden spans the hier_path over the whole `this.ia` and keeps the member at its token;
   ours keeps the lvalue form. § lvIdxThisPathIsRead312's `chain.size() == 1 && lvIdxParent154` gate does not reach
   a this-path whose own parent is a select inside the index. This is the next reach of THISIDX.
3. **Module subroutine targets whose index variables live in a named block** (VX/vx09_named_blk: golden
   `work@top.t.b.h.idx[j + 1].idx.j`, ours `work@top.t.b.j`). MODTF's stored-name gate requires the subroutine's
   own scope plus the name, so a block-scoped variable is left alone.
   A nested module's task (VX/vx12_nested_mod) keeps Surelog's `work@top.work@top::inner.t...` form, not attempted.
4. **2-D and built-in receiver spans:** `i2[iarr[i].get()][j].f` (VI/vi16 and VQ/vq03: the outer select ends two
   columns early, golden through the call's parenthesis). In `iarr[sarr[i].len()].f = r` (VQ/vq07) golden spans the
   built-in method path's first name and ours the whole call: LVMETHSPAN's twin for a built-in method. A member
   receiver `iarr[h.arr[i].get()].f = r` (VQ/vq02, vq06) stands at the zero-width golden column of pass 310's mt62
   residue.
5. **The indexed part-select base text inside a nested base path's names** (VP2/vp43 `h.v[h.hh.idx[i] +: 2] = 0`:
   golden `...::h.v[+:2]::v::h.hh.idx[i]::idx`, ours keeps `h.v[h.hh.idx[i]+:2]`). This is the
   § lvIpsNameFollowsHpRender312 twin for objects inside the base. VP/vp30_mod_gen (a generate-block
   `a.v[ix[k] +: 2]`) keeps `work@top.g.ix` where golden reads the chain. VP/vp22 (`+: p::N`) is the implementer's
   ip11 end-column residue. VP/vp28_mod_assign (`assign a.v[ix[1] +: 2]`) stands at a bit_select column head,
   not decoded.
6. **A late call in a member select after a late-call root** (VF/vf15 `harr[fwd(i)].arr[fwd(j)].f = r`: golden
   names the member select `harr[].arr[]` and spans `fwd` 14:22-25; ours the chain name and the whole call).
   Moved toward golden, not equal.
7. **Stage 1 on both binaries, not decoded:** class-scope calls (VS/vs02 `iarr[item::sget()].f`), `this.iarr[...]`
   roots (VS/vs14, VQ/vq08), a 2-D member index (VN vn15 and vn16), a struct member index (VT/vt15), derived and
   parameterized classes (VT vt33, vt34), a holder-array concatenation (VC/vc16), generate subroutines
   (VM vm07 d, vm21), module, interface and generate class-handle scopes (VI vi36 to vi39), a virtual-interface
   task (VX/vx08), the IPS shapes with a localparam width, a nested select or a 2-D select base (VP vp07, vp15, vp16,
   vp20, VP2/vp41), a generate continuous assignment (VF/vf07) and the concatenation root call (VL/vl16, the
   implementer's lr14 residue).
8. **Sister-ground faces (reported, not written):**
   - The `<in>us_t.idx` ref_typespec full name of an unpacked struct member (VX/vx06), the implementer's vt18 face,
     most likely TypeEmit.
   - The elaborated continuous-assignment ref_typespec names `work@top.m[].b` and `work@top.s.v.v` (VF vf01 e,
     vf03, vf05, vf12; ModuleEmit's cont_assign clone, the implementer's lr23 face).
   - The interface struct typespec's end line (VX/vx20, VF/vf08; TypeEmit, the implementer's lr22 face).

## Process

- Worktrees /tmp/wt_v11u312 and /tmp/wt_v11u312pris at ad7db986; scratch /tmp/v11u312_* and the session
  scratchpad. Nothing was written to the implementer's worktree.
- **THE FENCE:** every driver sources drivers/env.sh, which reads $FENCED fail-closed (four names) from
  tools/probe/r11u107repro/canaudit.sh's FENCED= line. Every tree scan (bytescan.sh, firescan.sh, mirror.sh,
  audit.sh) builds its path list first and filters it by word boundary before any file is opened. The census
  filter excludes the four fenced tests by exact name. The fence scan of this directory reads 0 files for each of
  the four names. No fenced test's head was read; the only fenced facts cited are the sweep's csv verdicts.
- **THE VERIFIER'S SLIPS, no effect:**
  1. The first run of drivers/gen.py reused the variable that held the cases root for a law name, so it wrote its
     243 dut.sv files into a directory named after that law at the MAIN TREE's root. They were found by
     `git status` within a minute, checked to be 243 dut.sv files all newer than this pass's worktree log, and
     removed with that one directory's literal path. The main tree's `git status` reads clean again. The generator
     now writes under an absolute path asserted to start with `/`.
  2. Eleven first drafts were not legal SV or did not build a golden and were rewritten before any counted
     measurement:
     - VK (eight cases): package subroutines that named $unit classes;
     - VI/vi40: the same;
     - VP/vp28: a variable index in a continuous-assignment target;
     - VI/vi31: `std::randomize` with no Surelog golden.
     A continuous assignment with a variable ternary index (vf11) exited 3 on both binaries and was dropped.
  3. The first pristine surelog stage was discarded (TIMEOUT under load, see Gates).
  - No process was killed. No other agent's process was listed or touched.
- No patch file is kept in this directory; the delivery /tmp/r11u312.verified.patch is transport only.
