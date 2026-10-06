# v11u263: adversarial verification of r11u263 (pass 263, the module/type ground)

Base 1f47482c (pass 261). Worktrees /tmp/wt_v11u263 (law, then law + fix) and /tmp/wt_v11u263pris (pristine),
scratch /tmp/v11u263_*. The verifier built every binary itself and froze it before any measurement:

| binary | md5 |
|---|---|
| pristine (1f47482c) | b0c95d2f65aad0c43fb701cb46377cbd (equal to the brief's and the implementer's) |
| law (/tmp/r11u263.patch) | d8ef7bf328195229d48798f1f00aa11b (equal to the implementer's) |
| fix (law + § selRootCloneLegKeepsCopy263v) | b924605526fcb2d8b88584911a077710 |

All three link slang 12.0.0+545f88b2e. The patch applies clean on a fresh 1f47482c (whitespace warnings only, from
evidence files). On the current HEAD a609e392c (pass 258) the source files apply clean and only the generated
tests/LAWS.md conflicts.

## Verdict

**VERIFIED WITH ONE FIX.** Every headline number of r11u263 reproduces bit for bit. Fresh cases found
§ dottedLhsElemSelShares263 moving six elaborated-view case-views from STRICT_EQUAL to `fullname` on legal SV: a
select-rooted member path (`assign arr[N].a_valid = ...`) whose right side holds an UNSIZED constant (`'0`, `'1`,
`'h1`) or is a CAST. Surelog's `UhdmWriter::writeCont_assign` re-compiles such a cont_assign (its
`DetectUnsizedConstant` leg and its typed-operation leg) even though the right side is not a constant, so golden
holds a fresh copy and the law's shared definition object is wrong. The fix is § selRootCloneLegKeepsCopy263v, behind
its own switch `R11V263_SELCLONE_OFF`. It moves no gate database against the law: 0 of 2560 corpus, 0 of 4087 probe
and 0 of 805 downstream, as predicted before its sweep.

## Targeted rows (reproduced from the verifier's own sweeps; law = fix)

| row-mode | pristine sweep | law sweep (fresh csv row) |
|---|---|---|
| **Rggen default** | `Rggen,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | **CONVERSION `Rggen,default,CMP_EQUAL,,,equal`**; uhdm-strictcmp `STRICT_EQUAL 314498 objects`, uhdm-cmp 0 lines |
| Earlgrey_0_1 default | `differ:fullname(36)` | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(21),,differ:fullname(21)` |
| Earlgrey_0_1 testflags | `differ:fullname(4)` | `differ:fullname(4)` unchanged; the bytes move, 3 records toward golden, 0 away |

- Rggen default before (evidence/rggen_default_P_records.txt): `#92960 type A: range block_0.sv 1811:46-47 /
  B: ref_typespec <in>`, objects 314498 vs 314389. After: STRICT_EQUAL (evidence/rggen_default_L_records.txt).
- Earlgrey default before (evidence/earlgrey_default_P_records.txt): #233633 #233638 #395727 #464077 #600811 #600816,
  then the nine #620047 to #620111 (`ref_obj N`, golden `work@tlul_socket_1n.N`, ours
  `work@top_earlgrey.u_spi_device.u_reg.u_socket.N`), then #658559 to #658579 (golden `cont_assign
  tlul_err_resp.sv 40:10`, ours `38:10`, the walk diverging). After (evidence/earlgrey_default_L_records.txt): the
  same first six, then #726217 #726221 #726225 #727777 #727781 #727785 #729363 #730573 #730577 #814099 #814102
  #814108 #814111 #816151 #816152, exactly the implementer's list.
- Earlgrey testflags: #216212 #235310 #235315 #403326 on both binaries (all ExprEmit, the sister ground).

## Gates (reproduced)

1. **Builds**: md5s above. Binary-path audit (drivers/binaudit.sh, the cmds.txt path list filtered by `$FENCED`
   before any file is opened): each of the pristine, law and fix sweeps has 3265 of 3315 files naming its own frozen
   binary, 0 naming another, 50 with no slang line (evidence/binaudit.txt).
2. **Probe**: `EQUAL=3566 STRICT_NOTEQUAL=521`, `regressions=0 conversions=0 changes=0` on all three sweeps.
3. **Corpora**: pristine reproduces the baseline in every stage (0/0/0). Law and fix: surelog `regressions=0
   conversions=1 changes=1` (CONVERSION Rggen default `differ:type(1) -> CMP_EQUAL`; CHANGE Earlgrey_0_1 default
   `differ:fullname(36) -> differ:fullname(21) [fullname -15]`); uhdm2rtlil 0/0/0 with 1606 + 0. Row by row the law
   csvs differ from pristine's only in those two rows and the LowMem workdir path (evidence/csv_P_vs_L.txt); the fix
   csvs equal the law's in all four csvs (0 differing lines).
4. **Downstream**: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871)` on all three sweeps; verdict diff 0. Three
   slang-lane databases move under the law (PackedArray, TypedefPackedDimensions, TypedefVariableDimensions, the
   uhdm2rtlil movers), all IDENTICAL on both binaries (evidence/downstream_movers_L_vs_P.txt); fix vs law 0 of 805.
5. **uhdm-cmp**: 0 lines on Rggen default and on Earlgrey_0_1 default and testflags with the law (= fix) binary.
6. **byteverify** over fence-filtered hard-link mirrors (2560 databases, 8 fenced paths skipped by name,
   PATH_SETS_IDENTICAL, SELFCHECK 2559/2560):
   - law vs pristine: MOVERS 11 / 2560, the implementer's 11: Earlgrey d/t, Rggen d, Scr1SvTests d/t, PackedArray,
     TypedefPackedDimensions, TypedefVariableDimensions d/t (evidence/byteverify_L_vs_P.txt). Probe 1 / 4087
     (r10earl_repro/tj, EQUAL on both).
   - fix vs law: MOVERS 0 / 2560, probe 0 / 4087, downstream 0 / 805 (evidence/byteverify_F_vs_L.txt,
     probe_ds_movers_F_vs_L.txt).
   - The firing census (drivers/tracecensus.sh with the FIX binary, filter from `$FENCED`) is identical line for
     line to the implementer's frozen evidence/predict_frozen.txt (12 databases) and names
     § selRootCloneLegKeepsCopy263v on 0 databases: the fix's prediction "0 movers against the law", frozen before
     the fix sweep (evidence/predict_fix_frozen.txt, md5 a89aea0b), held. Positive control: the same trace fires
     through the downstream harness on V/VU/vu02 and vu34 (evidence/posctl_trace_fix.txt).
7. **Away census** (chain-keyed, drivers/awaychain.py with strictcmp_x) on the 11 corpus movers: away=0 everywhere;
   Earlgrey d toward=14, t toward=3, Rggen d toward=109, the others 0/0 (evidence/away_corpus_chain_L.txt), as the
   implementer read.
8. **Canaries**: surelog ok=51 changed=1 (Earlgrey d, targeted), uhdm2rtlil ok=16 changed=0, both ctcan2 checks PASS,
   for the law and the fix (evidence/canaries.txt).
9. **Determinism** (drivers/det.sh, fix binary): three concurrent draws on Earlgrey_0_1, MiniAmiq, SeqDriver,
   SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes give one hash per row-mode, each equal to the fix
   sweep's (and, for the law's movers, to the law sweep's); Scoreboard testflags has no database and Rggen testflags
   is SURELOG_FAIL, as at the base (evidence/det_fix.txt).
10. **Sweep exit codes**: pristine 0; law and fix exit 1 only on the law-index check, because the verifier's
    src edit existed before tests/LAWS.md was regenerated (evidence/sweep_*_summary.txt); the index is current in the
    delivered patch.

## The implementer's grid and the byte controls

- The 46 case dirs of r11u263repro (92 case-views) on pristine, law, fix, fix + `R11V263_OFF`, fix + `R11U263_OFF`
  and the fix with each switch off (920 lines, every one `rc=0`): 70 moving, 27 entering STRICT_EQUAL, none leaving,
  each mover moved by exactly one switch (GENIFPORT 22, DOTSELBASE 22, GENLPRANGE 18, DOTOPRHS 8);
  `R11U263_OFF` gives pristine's bytes and `R11V263_OFF` the law's on 92 of 92; the fix equals the law on all 92
  (the refinement does not fire on any of them).
- The implementer's 19 control dirs on all three binaries (2574 case-views, 7722 lines): 2 moving under the law and
  the fix, v11u261 VD/vd04_iface_port_child in both views, STRICT_EQUAL on all binaries; 0 entering, 0 leaving, no
  exit code or uhdm-cmp line count changing; the 24 nonzero-exit lines are 8 case-views exiting 3 or 4 identically on
  all three binaries (evidence/controls_impl19*.txt).
- Widened by six dirs that hold the cont_assign clone legs (r11u193repro: the unsized leg; r11u176repro: the cast
  leg; r11u225repro, r11u171repro, r11u16repro, r11u164repro): 718 case-views, 0 moving on either binary
  (evidence/controls_widen*.txt).

## Attack: 66 fresh case dirs in both views (cases/, 132 case-views)

drivers/gridF.sh runs every case on the ten configurations above (1320 lines, every one `rc=0`,
evidence/gridF_cases.txt, gridF_cases_summary.txt). Every case's first line names its law.

| dir | law | shapes |
|---|---|---|
| VU/vu01, vu03 to vu09, vu11 to vu14, vu16, vu22, vu23, vu27 to vu31, vu33, vu38, vu42, vu45, vu46 | § dottedLhsVarOpRhsShares263 | variable root with `'1` in an operation (vu01), concatenation, `+ 1`, conditional with `'0`, `+ 4'd1`, `& N`, enum conditional, size cast, `'1` branch, streaming, `- 2`, unary, local typedef, nested member with replication, an output struct port, an interface member read, a member read, a bit-select read, a localparam array read, a constant function call, a cast of a parameter, an enum cast, a parameter delay, an interface body, a generate-block variable |
| VU/vu15, vu17, vu21, vu24 to vu26, vu32, vu36, vu37, vu39 to vu41, vu43, vu44, vu47 | § dottedLhsElemSelShares263 | select root in a for-generate with `'1`, `+ 1`, sized `&`, an output struct-array port, a system call, a parameter-expression index, replication, `$unsigned`, plain and conditional, a 2-D root, parameter and literal delays, streaming, a sign cast, instances inside a generate |
| VU/vu02, vu10, vu18 to vu20, vu34, vu35 | § selRootCloneLegKeepsCopy263v | select root with `a \| '0`, `c & '1`, `c \| 'h1`, `a ? c : '1`, a call with a `'1` argument, `4'(c ^ {4{b}})`, `tp::op_e'(c[2:0])` |
| VG/vg01 to vg09 | § genIfacePortActualInst263 | an instance array in a generate, two module levels of generate passthrough, a generic child of a plain port, a local interface instance beside the port, two instances with a nested if inside a for, the second of two ports, positional connection, case-generate, an interface-array element actual |
| VR/vr01 to vr10 | § genLpArrRangeFirst263 | descending range read by an assign and genvar-valued initializers (vr01), two arrays with a default pattern (vr02), a parameter-width element in two instances (vr03), the `parameter` keyword in a generate block (vr04), a packed 2-D element (vr05); isolated: descending range in an if-generate (vr06), two-deep for-generate (vr07), two arrays in one block (vr08), a module instantiated twice (vr09), case-generate (vr10) |

Results:

- **The law**: 114 case-views moving, 51 entering STRICT_EQUAL and **6 LEAVING**: VU/vu02_el, vu10_el, vu18_el,
  vu19_el, vu34_el and vu35_el go `STRICT_EQUAL -> STRICT_NOTEQUAL fullname`. Golden (elaborated view):
  `ref_obj N work@top.u_a.arr[N].a_valid.N` at 8:14-15 in a fresh per-instance copy; the law shared the definition's
  cont_assign, so the record reads `work@sock.N` (#379 and #489 on vu02_el). In the default view the same cases are
  `fullname` on both binaries (the implementer's T/t11 face), the law moving them from a fresh copy named
  `work@top.u_a.N` to the shared `work@sock.N`.
- **The fix**: 100 moving, 51 entering, **0 leaving**; `R11V263_OFF` gives the law's bytes and `R11U263_OFF`
  pristine's on 132 of 132; every mover moved by exactly one switch, except VU/vu47 (which holds both
  cont_assign shapes) moved by each of the two cont_assign switches; the 14 case-views of the seven
  § selRootCloneLegKeepsCopy263v dirs return to pristine's bytes exactly.
- Away census on the fix's 100 movers (drivers/awayall.sh, evidence/away_cases_fix.txt): 0 lost records on every
  case-view both of whose sides pass stage 1. Five stage-1 case-views lose dump lines that carry no identity:
  vu25, vu36 and vu44 one `|vpiParent:` line each (dump distance 62 -> 9), vu47_el two `|vpiParent:` and one
  `|vpiActual:` (203 -> 114; each law alone loses 0), and vg02_el 27 lines of the interface's param_assign / modport
  listing printed at the top level, the same print artifact the implementer recorded on I/i08_el, i11_el and i13_el:
  the fix reads STRICT_EQUAL there.
- § genLpArrRangeFirst263: the isolated cases vr06 to vr10 all enter STRICT_EQUAL in both views (10 of 10); vr01 to
  vr05 move but are stage 1 on both binaries on other faces (an elaborated folded read of the array, a default
  pattern, a parameter-dependent range).
- § genIfacePortActualInst263: vg02, vg05, vg06, vg08 and vg09 enter STRICT_EQUAL (vg09_el stage 1 -> depth); vg03
  and vg07 move toward golden and stay stage 1 (uhdm-cmp 36 -> 34 on vg03); vg01 (instance array) and vg04 do not
  fire.
- Downstream on the 66 fresh cases (drivers/dscases.py, evidence/ds_fresh_*.txt): pristine 55 IDENTICAL, 10
  EQUIVALENT, 1 STATUS_DIFF; law and fix 62 IDENTICAL, 4 EQUIVALENT. No case leaves IDENTICAL; vg02, vg05, vg06,
  vg07, vg08 and vg09 go EQUIVALENT -> IDENTICAL and vg03 STATUS_DIFF -> IDENTICAL.

## The fix

### § selRootCloneLegKeepsCopy263v (`R11V263_SELCLONE_OFF`)

ModuleEmit, the elaborated cont_assign's sharing decision, inside § dottedLhsElemSelShares263.

- Golden's rule (Surelog `UhdmWriter::writeCont_assign`): a cont_assign whose Lhs is not a ref_obj is cloned when
  its Rhs reduces to a constant (the law's `tryEval` test), when its Rhs holds a constant of vpiSize -1
  (`DetectUnsizedConstant`), or when its Rhs is an operation carrying a typespec (a cast; the
  `flattenPatternAssignments` branch).
- The law covered only the first leg. The fix makes it abstain when the definition's own cont_assign satisfies
  `rhsHasUnsized193` (the § caUnsizedRhsClonePerInst193 predicate) or `castRhsClones176` (the
  § castRhsClonePerInst176 predicate). The base's fresh copy then stands, as on pristine.
- § dottedLhsVarOpRhsShares263 needs no such abstention: on a variable root the existing § 193 and § 176 clone legs
  already re-clone the shared object, and every variable-root unsized and cast case (vu01, vu05, vu09, vu11, vu33,
  vu38) is STRICT_EQUAL under the law.
- A parameter DELAY on a select root (vu40, vu43) is not abstained from: the law moves the elaborated view
  `type -> STRICT_EQUAL` there.
- `R11V263_OFF` drops the fix (the law's bytes); `R11U263_OFF` still drops the whole pass (pristine bytes).

## Residues, ranked (all wrong on pristine too)

1. **The select-rooted default view of the clone-leg shapes** (vu02, vu10, vu18, vu19, vu34, vu35 and the
   implementer's T/t11): golden's fresh copy names the index `work@top.u_a.arr[N].a_valid.N`, ours
   `work@top.u_a.N`; this is the definition-view naming of a fresh hier_path copy, not the sharing decision.
2. The implementer's residues stand as listed in r11u263repro/README.md: Earlgrey default #726217 / #727777 /
   #730573, #729363 and #816151 (module/type or ParamEmit, writers not located); the definition-view generate
   localparam arrays with non-logic elements (R/r03 to r10); T/t12 and the packed or `wire` roots t06, t16, t17;
   I/i14, i07, i09.
3. Fresh shapes the laws do not reach: an instance ARRAY inside a generate block passed the port (VG/vg01, stage 1
   on both binaries), positional connection (vg07, i04), a select root inside a generate block (vu15: the
   gen-scope cont_assigns take another path, `fullname` on both binaries), select roots with `$countones`,
   `$unsigned` or `signed'` right sides (vu25, vu36, vu44: stage 1 on both, the law moving them toward golden), an
   interface body (vu45, stage 1 on both), the generate localparam array read in an elaborated assign (vr01).
4. The brief's items the implementer did not attempt (D/d08, G/g06, pass 261's and 259's residue lists, the seven
   first-match pointer-keyed loops, items (4) to (7)).

## Sister-ground faces (call sites; not written)

As the implementer listed them, confirmed on the verifier's sweeps: Earlgrey d #233633 / #233638 (ExprEmit
§ shadowedImportParamFold), #395727 (ExprEmit's enum-constant clone, § genCaEnumBindsSelectOnly22's sites), #464077
(ExprEmit stampFoldedPkgParamTs), #600811 / #600816 (ExprEmit, the gen-scope replication fold), #814099 to #814111
(ExprEmit, the § genIpsBoundOwner256 family); Earlgrey t #216212, #235310 / #235315, #403326 (ExprEmit);
MiniAmiq / SeqDriver #121302 / #121260 / #121272 (StmtEmit § cloneLoopVarHomeObject183, landed since by pass 258 at
a609e392c); BlackBePipeInt #331795 / #331692 (ParamEmit).

## Process

- The verifier signalled no process, listed no other agent's command line, and dispatched, read or decoded nothing
  fenced outside the gate sweeps. Every corpus path list (byteverify mirrors, binary audit, probe and downstream
  byte loops, away census) was filtered by `$FENCED` before any file was opened.
- First fix draft (fix1, md5 926e5b17) abstained on unsized constants only; the cast cases vu34 and vu35 were found
  next and the predicate widened before any gate measurement. fix1 was never swept.
- vg03 and vg09 first held an unconnected top-level module or program (slang rc=3 on every binary); the extra
  modules were removed before any measurement was recorded. The seven § selRootCloneLegKeepsCopy263v cases had
  their first lines retagged from the law's name, and the whole grid was rerun from this directory afterwards.
- The verifier's src edit predates its law sweep, so the law and fix sweeps exit 1 on the law-index check alone.

## Files

- `src/R263.h`: adds `r11v263On` (the verifier's switches).
- `src/ModuleEmit.cpp`: § selRootCloneLegKeepsCopy263v inside § dottedLhsElemSelShares263.
- `cases/{VU,VG,VR}`: 66 case dirs.
- `drivers/`: copied from r11u263repro/drivers (case.sh maps this directory), plus gridF.sh, gridFsum.py,
  controls3.sh, ctl3sum.py, binaudit.sh and quick.sh.
- `evidence/`: sweeps, byteverify, census, away censuses, controls, grid, downstream, det, canaries, records.
