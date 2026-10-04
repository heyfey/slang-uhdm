# RESUME — how to carry on the slang-uhdm convergence campaign

*First written 2026-08-17 (HEAD `89bfd8f`, 88 landings in the current block);
the procedures are timeless, the snapshot in §3b is not — run
`scripts/resume_survey.sh` for the live state. This is the START-HERE document for any new operator or model (human, Claude,
GPT, …) that takes over the campaign. It is self-contained: everything below
was measured, not remembered. When another doc disagrees with this one, this
one wins — see §11 for which docs are stale and how.*

---

## 0. Reading order (30 minutes)

1. **This file**, all of it.
2. `PLAYBOOK.md` — the campaign posture (never pause, revert-and-refine,
   gates). Its *method* is current; its numbers are not.
3. `GOLDEN_EQUIVALENCE.md` §1–2, §4.1–4.2 (target definition, harness,
   gates). §3 is regenerated below; §5's "documented-unreachable" claim is
   FALSE now (see §3.3 note there).
4. The last ~10 commit messages (`git log --format='%B' -10`): each landing
   is a decoded-model write-up with the exact numbers, the residues, and the
   NEXT HEAD (R0). The queue lives in these messages, not in a tracker.
5. The most recent pass README per row family — the highest-numbered
   `tools/probe/r10{uvm,buvm,earl,rgg}<N>repro/README.md` (plus its verifier
   dir `r10v<pass>repro/` or `VERIFIED.*.txt`/`VERIFIER.*.txt`) — the shape of
   an acceptable pass and its evidence. `ls -d tools/probe/r10uvm*repro | sort -V | tail -1`.
6. §9 here (measurement laws + ops traps) — read TWICE.

---

## 1. Mission and non-negotiables

**Target:** `slang-uhdm` (our SystemVerilog→UHDM emitter, built on slang)
must produce a database that the OFFICIAL `uhdm-cmp` judges EQUAL to
Surelog's golden database, for **both corpora × both modes**:
- corpora: `uhdm2rtlil` (871 tests, submodule `third_party/uhdm2rtlil/test`)
  and the Surelog suite (798 tests, submodule
  `third_party/Surelog/{tests,third_party/tests}`; its UVM trees are under
  `third_party/Surelog/third_party/UVM`). Since 2026-09-23 every location
  resolves relative to this repo (tests/README.md); `tests/sweep.sh` is the
  gate and the golden databases are cached after the first run;
- modes: `default` (sources + where-to-find-them args only) and `testflags`
  (the test's own command line, UHDM-irrelevant parts removed).
- **Done = 0 `CMP_NOTEQUAL` rows** among comparable rows in both corpora, both
  modes. `SLANG_REJECT` (slang refuses the source) is OUT OF SCOPE by decision;
  `SURELOG_FAIL`/`NO_DATABASE`/`DEFERRED` are non-comparable.

**Golden is the spec, bugs included.** When Surelog mis-evaluates (Rggen's
corrupted packed-array evaluation, generate-if conditions it cannot value,
`ExprEval` quirks), we MODEL the mis-evaluation. We never "fix" Surelog and we
never patch UHDM. Patching **slang** is out of scope too.

**The gate is `uhdm-cmp` AND `tools/uhdm-strictcmp` (strict since c9e2923c,
user decision 2026-09-24).** A row-mode is CMP_EQUAL only when both read
equal, else STRICT_NOTEQUAL; `tests/sweep.sh` compares the surelog,
uhdm2rtlil and probe csvs against `results/golden_*.csv` with regressions=0
as the bar. Any other comparator (the ladder, censuses) is measurement-only
and never in the gate; report its cost when run.

**Standing user directives** (verbatim spirit):
- "keep converging non stop" — autonomous, continuous; the session ends when
  the user ends it, never at a self-declared milestone; never ask "shall I
  continue".
- Answer "how far are we" with MEASUREMENTS, never guesses (§10).
- Master = coordinator only (dispatch, integrate, gate, commit). Subagents =
  implement + adversarial-verify pairs or single measurement passes, three
  concurrent subagents in total (user 2026-09-24), refilled the moment a slot
  lands. Pin the strongest available model + high effort for subagents
  and CHECK the pin on each dispatch (with Claude: `model:'claude-opus-5-5'`,
  `effort:'high'` in EVERY agent() call, user 2026-09-22 — session-model inheritance once killed 9 agents).
- ONE PATCH AT A TIME through the integration gate; the master promotes
  baseline CSV rows itself, with the rows quoted, only for real
  conversions/unmaskings.

**Security/hygiene constraints (in force, do not relax):**
- `results/golden_surelog.csv`, `results/golden_uhdm2rtlil.csv` and
  `results/golden_probe.csv` are committed READ-ONLY baselines; only the master edits them, only for a
  measured conversion/unmasking, quoting old→new rows in the commit.
- The four slang-fenced tests (`UnsignedParam`, `HierPathEval`,
  `FileLocalParam`, `TopParam`) are NEVER dispatched, and probe artifacts must
  not spell those names individually (`canaudit.sh` reads that as
  FENCE-BREACH; its own fence list and superstring test names like
  `SizeOfUnsignedParameter` are the only allowed mentions).
- The record of the fenced tests is `tests/FENCED.md`: the names with a tag
  each (F1 to F4), the rules, and the design notes that were source comments.
  The exporter source holds no fenced name; it refers to a test by its tag
  (user decision 2026-09-29).
- NO PATCH FILE OF A LAW OR A FIX IN THE REPOSITORY (user decision
  2026-09-29). A pass delivers its work as `/tmp/<pass>.patch`; a
  verification delivers a fix as `/tmp/<pass>_fix.patch` and a decode its laws
  as `/tmp/<pass>_law.patch`. These files are transport only. A landing
  deletes every `*.patch` from the pass's `tools/probe/<pass>` directory
  before `git add`. Only tool patches that a driver applies stay tracked.
- The golden cache is `CACHE_ROOT/<surelog commit>/<key>`
  (`verify_golden.cache_base()`, user decision 2026-09-29): a moved Surelog
  pin never reads an old golden.
- Surelog's `-sverilog` reaches slang-uhdm as `--sverilog` in both the
  default and the testflags mode (user decision 2026-09-29).
- KNOWN FAILURES THAT STAY IN THE GATE (user decision 2026-09-29; they run in
  seconds): LogicTypespec d/t, Scr1SvTests d/t and stamped_gen_param d/t are
  Surelog behaviours the exporter does not copy. They stay STRICT_NOTEQUAL or
  CMP_NOTEQUAL rows and are not work items.
- `r10earl23` (Earlgrey pass 23, `/tmp/r10earl23.patch`) is QUARANTINED: its
  agent edited a file outside its worktree (`.handled`) — flagged by a
  security classifier as a possible fake-review marker. Do not integrate it
  without explicit user direction. Audit is recorded in the commit history.
- Agents write ONLY inside their own worktree + their own pass-prefixed
  `/tmp/<pass>_*` scratch. Never `/tmp/claude-1000` (harness dir). Never
  `git stash`. Never truncate `git apply` output. `GOLDEN_DEFER` stays unset.
  Sweeps `--jobs 3`. Builds `-j 2`.
- Never delete another pass's `/tmp` scratch or frozen binaries while it may
  be in flight; prune only landed passes' worktrees.

---

## 2. Repo and environment map

```
~/git-repos/slang-uhdm            this repo (branch auto5h; main = PR target)
  src/{ExprEmit,ModuleEmit,ParamEmit,StmtEmit,TaskFuncEmit,TypeEmit,UhdmExporter}.cpp
  include/UhdmExporter.h          the emitter (~200k lines; laws are § comments)
  build/slang-uhdm                the binary (cmake --build build -j 2)
  scripts/verify_golden.py        THE harness (one classification engine)
  scripts/accounting.py --md      regenerates the baseline table from results/*.csv
  tests/sweep.sh                  THE gate: both corpora x both modes vs results/golden_*.csv
  results/golden_surelog.csv      surelog baseline (1588 rows) — READ-ONLY
  results/gate_uhdm2rtlil.csv     u2r testflags baseline (731 rows) — READ-ONLY
  tools/probe/r10<pass>repro/     one dir per landed pass: README (the decoded law),
                                  CENSUS/PREDICT/GATES/LADDERS, cases (*.sv), instruments
  tools/probe/r10ladder1repro/    ctladder.cpp (+ctfields.inc), cluster.py, CLUSTERS*.md
  tools/probe/r10uvm67repro/rowheads.sh   heads (cmp lines/heads) for named rows
  tools/probe/r10oth8repro/ct8rows.sh     whole-row CSV judge (status AND dump column)
  tools/probe/r10oth4repro/byteverify.sh  byte movers between two sweep workdirs
  tools/probe/r10uvm52repro/canaries.sh   named canary rows vs baseline
  tools/probe/r10uvm67repro/ctcan2.sh     supplementary canaries (EXPECT_UNKNOWN=1 sl / 6 u2r)
  tools/probe/r10sd4repro/canaudit.sh     audits the canary scripts (run from a pass dir:
                                          bash canaudit.sh canaries.sh ctcan2.sh)
  tools/probe/r10earl60repro/tsinst60.cpp masks golden objects in a fresh CompareContext and
                                          re-runs the OFFICIAL Compare to name an RHS<null> owner
  PLAYBOOK.md GOLDEN_EQUIVALENCE.md HANDOFF.md NOTES.md PLAN.md   older docs (§11)

third_party/Surelog/build/bin/surelog             the producer (built inside the submodule, or SURELOG=...)
third_party/Surelog/build/third_party/UHDM/bin/{uhdm-cmp,uhdm-dump}   the judge and the dumper (or UHDM_CMP=/UHDM_DUMP=;
                                                  or build/third_party/Surelog/third_party/UHDM/bin from the in-tree build)
third_party/slang + third_party/Surelog/third_party/UHDM   the PINNED frontend and library, built in-tree by cmake by default
~/git-repos/UHDM/build/bin/{uhdm-cmp,uhdm-dump}   the same tools from the standalone UHDM build on this machine
~/git-repos/UHDM/build/generated/src/*.cpp        generated <kind>::Compare bodies — READ THESE
~/.local/include/uhdm/BaseClass.h                 SafeCompare overloads (§9 head-decode)
third_party/Surelog/ (= ~/git-repos/Surelog)      Surelog SOURCE (decode laws from it: CompileHelper.cpp,
                                                  CompileExpression.cpp, CompileStmt.cpp, UhdmWriter.cpp,
                                                  ElaborationStep.cpp, NetlistElaboration.cpp, ExprEval.cpp)
~/git-repos/Surelog/build/bin/surelog             the golden Surelog the harness runs (scripts/verify_golden.py) — NOT the sv-tests
                                                  copy: goldens built with ~/git-repos/sv-tests/third_party/tools/Surelog/build/bin/surelog
                                                  restore into a corrupt database under this UHDM (uhdm-dump segfaults), so a grid scores nothing
~/.cache/slang-uhdm-goldens/<hash>/golden.uhdm    golden cache (3727 entries, 12 GB) — KEEP IT
```

Controls (rotated on every landing by the master, live in `/tmp`):
`/tmp/ctl_wd_sl_<HEAD>` (956 surelog DBs), `/tmp/ctl_wd_u2r_<HEAD>` (1358),
`/tmp/ctl_{sl,u2r,u2r_def}_<HEAD>.csv`, `/tmp/pris_<md5>.bin` (the pristine
binary). If they are gone, regenerate: build HEAD, run the two sweeps into
new dirs, `mv` them into place.

---

## 3. Discover the CURRENT state (do this first, every time — the handoff can happen at any moment)

Nothing below in §3b is authoritative once a day has passed. The live state is
always derivable from the repo + `/tmp`, and one script prints it:

```bash
cd ~/git-repos/slang-uhdm
bash scripts/resume_survey.sh          # git state, in-flight worktrees, UNLANDED patches, controls,
                                       # baseline table, NE rows, each family's declared next head (R0)
HEADS=1 bash scripts/resume_survey.sh  # + official cmp heads on the newest control (a few minutes)
```

Then decide, in this order:
1. **Dirty main tree** (tracked modifications) ⇒ an integration was in
   flight. Identify which patch (`git diff --stat`, compare against
   `/tmp/r10*.verified.patch`), and either finish §6 from the top (re-run
   every gate) or `git checkout -- .` and start that patch's integration
   again. Never commit a partially gated tree.
2. **UNLANDED patch whose worktrees are gone** ⇒ its pass completed but was
   never integrated ⇒ integrate it via §6 (verified patch first).
3. **UNLANDED patch whose worktrees still exist** ⇒ the pass was in flight
   (implementer or verifier). Its worktree keeps the work: read
   `git -C /tmp/wt_r10<pass> diff HEAD --stat` and the pass's
   `tools/probe/r10<pass>repro/README.md` if written. Either re-launch the
   missing role (an implementer's finished patch still needs a fresh
   adversarial verifier; a dead verifier's partial cases are in `wt_v<pass>`)
   or, if nothing usable, drop the worktrees and re-dispatch the head.
4. **Empty slots** ⇒ dispatch a new pass per family from the R0 line of that
   family's last landing (the survey prints them). Four families in parallel:
   UVM chain (SeqDriver/SimpleUVM/Scoreboard/MiniAmiq), BuildUVMPkg,
   Earlgrey (both modes), Rggen.
5. **Controls missing** (`/tmp/ctl_wd_sl_<HEAD>` etc.) ⇒ build HEAD, run the
   two sweeps of §6 into new dirs, and `mv` them into place before judging
   anything.

Everything else — pins, canary names, fenced tests, quarantine — is in §1.

### 3b. Snapshot at the last doc update (2026-09-24, HEAD = the strict flip landing) — EXAMPLE ONLY

> **v1.87 campaign, THE STRICT AXIS (2026-09-24, HEAD = the strict flip).**
> The gate's equality is STRICT since this landing: a row-mode is CMP_EQUAL
> only when uhdm-cmp AND tools/uhdm-strictcmp read equal; a judge-equal
> row-mode the strict comparator rejects reads STRICT_NOTEQUAL (its detail =
> the strict verdict `differ:<field>(<objects>)`); a probe case reads EQUAL or
> STRICT_NOTEQUAL and tests/sweep.sh compares the probe csv against
> results/golden_probe.csv like the two corpora. Regressions=0 is the gate;
> a STRICT_NOTEQUAL -> CMP_EQUAL row is a conversion a landing commits by
> re-baselining the three LF csvs. Baselines at this head: surelog 639
> CMP_EQUAL + 315 STRICT_NOTEQUAL of 954 judge-equal row-modes (480/3 +
> 474/3 judge, the 6 NE = the three fenced tests), uhdm2rtlil 1270 + 336 of
> 1606 (803/1/67 judge; stamped_gen_param stays NOT_EQUAL by user decision),
> probe 2081 EQUAL + 2006 STRICT_NOTEQUAL of 4087 (all judge-equal);
> downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT (func_upto,
> matching_end_labels = the plugin's pointer order, not a database field) / 0
> DIVERGENT of 871. THE COMPARATOR: stage 1 = uhdm-cmp's own Compare; stage 2
> = a listener walk comparing name, defname, fullname, file basename, the
> four span fields, decompile, size, value, const type in walk order, with
> typespec IDENTITY canonicalised (every typespec subtree and enum_const
> re-expands at each reference; verified sound by r11u123) and a copy's full
> name or span excused ONLY where golden itself gives that object more than
> one name or span (mode 4, verified by r11u129): the identity residue is
> ZERO row-modes; every remaining difference names an emitter site. THE
> RESIDUE is explicit: tools/probe/r11u132map (third-edition map)
> fail_list.csv + probe_fail_list.csv, ranked OPEN clusters with sites
> (largest: full names inside a typespec subtree 334 row-modes; the
> unparented golden ref_typespec on pattern ops/constants; hier_path element
> spans and names; object-sharing classes outside typespecs; operation and
> constant spans; the --elabuhdm clones). Landed on this axis: passes 117-121
> (downstream identity), 124/125/130 (file, value, span, name laws; 25-177
> row-modes each), the comparator (fc313b50, canon d3cdef19-era, mode 4
> 4f73d52f), the law index (tests/LAWS.md by scripts/law_index.py, a LAW
> file per case dir, --check in the sweep; the term is "probe case"), the
> probe set at 4087 cases (the other-named cases judged and moved). Live
> pairs work the map's OPEN clusters per ground (expression:
> ExprEmit/EmitHelpers/StmtEmit/ParamEmit; module: TypeEmit/ModuleEmit/
> UhdmExporter/TaskFuncEmit/uhdm_main); every landing re-baselines the
> three csvs from its own sweep and regenerates tests/LAWS.md.

> **v1.87 campaign CONVERGENCE snapshot (2026-09-23, HEAD = the pass-116
> landing).** The matrix-1.87 branch has landed 116 passes since the
> df23d880 rebaseline: surelog 480/3 default + 474/3 testflags (of 798; ALL
> SIX NE row-modes are the three slang-fenced tests), uhdm2rtlil 803 equal /
> 1 not-equal / 67 reject in both modes (of 871). Passes 105-115 CONVERTED
> TWENTY-THREE ROWS after 33 dry groundwork passes (70-103):
> port_chained_type_param (105), mem_packed_2d_byte_write (106),
> type_param_packed_dim (107), anon_struct_packed_dim +
> cva6_struct_param_field + type_param_unpacked_port + StructParamFieldRange
> + StructParamFuncBodyFieldCompare + StructParamPatternInitCast (108),
> type_param_override_elem_sel (109), SequenceInst + const_cast_signext +
> packed_array_struct + unpacked_elem_partsel_comb (110), cfg_func_width_loop
> + LargeValue2Struct (111), arb_idx_cast (112), ibex_tracer (113), Rggen
> default (114), ibex_pmp + ibex_icache (115). The ONE open row,
> stamped_gen_param, CANNOT CONVERT against the pinned Surelog v1.87: its
> golden elaborates gen_grps[0].u.g[0..2] as `inv` where the source's
> UT = {2'b01,2'b01,2'b01} requires `keep` (and gen_grps[1].u.g[0] as `keep`
> where it requires `inv`) because Surelog's ExprEval bit-selected the
> pre-folded pattern constant instead of element-selecting it — the defect
> the test's own header comment names (fixed upstream after the pin). slang
> elaborates the real value, so the generate structure differs on every
> judged line after the value; pass 116 cleared the typespec head (11 -> 64
> lines, every cell toward golden) and the next head is the garbage value
> itself (golden 1'b0 vs ours 6'b010101 at 44:31). Fencing that row is the
> USER'S decision (a producer-defect fence, the fourth after the three
> slang-fenced tests); results/*.csv keep it CMP_NOTEQUAL until then. The
> post-convergence task the user set (memory probe-cases-to-tests-after-
> convergence) is IN PROGRESS: a census of every unique tools/probe dut.sv
> case through the corpus harness in both modes on the HEAD binary
> (scratchpad probe_census.py -> which cases read CMP_EQUAL and whether their
> dumps match byte-for-byte), then a selection + layout proposal for
> tests/, then STOP for the user's direction before editing tests/.
> Method that converged the corpus: HEAD-ANCHORED SELECTION (memory
> head-anchored-selection) — every brief names the open corpus tests it
> targets and their measured uhdm-cmp head cluster, predicts each row's cmp
> line-count movement by name, batches EVERY located face on one ground, and
> refills come from the head clusters; two implement+verify pairs on
> DISJOINT FILE SETS (pair A: ExprEmit.cpp + EmitHelpers.h + StmtEmit.cpp;
> pair B: TypeEmit.cpp + UhdmExporter.cpp + ModuleEmit.cpp + ParamEmit.cpp),
> every agent() pinned model 'claude-opus-5-5' + effort 'high'; the §6
> integration cycle unchanged (apply the verifier's patch stacked on the
> current head, build -j 2, goldens 23/0 + /bin/false 0/23, three sweeps
> --jobs 3, row-joins vs results/*.csv and the controls, byteverify with
> a-priori movers by name, the canary battery from tools/probe/r11u107repro,
> the ten hard db pins, promotion by surgical sed + accounting.py --md +
> SUPPORT_MATRIX.md in the SAME commit, control rotation, family prune).
> Instrument laws recorded at the end: a substituted parameter read keeps
> its initializer literal's BASED encoding (the producer clones the
> param_assign right-hand side); a generate block is its own design
> component so a package-parameter read there is late-bound as a
> per-reference enum_const clone on either side of an assignment; a
> pkg::NAME.member read inside a live (non-overridden) parameter declaration
> flattens the package pattern to a nameless, parentless op whose operands
> carry Surelog's own Bits (a typedef of a packed array of a typedef'd
> vector is counted twice: row_t [0:1] reads 36, not 12); the binary does
> not truncate an existing -o file, so every database must be written to a
> fresh path.
> The pass-113 paragraph below is HISTORY.
> **v1.87 campaign refresh (2026-09-23, HEAD = the pass-113 landing).** The
> matrix-1.87 branch has landed 113 passes since the df23d880 rebaseline:
> surelog 479/4 default + 474/3 testflags (of 798; 6 of the 7 NE row-modes
> are the three slang-fenced tests), uhdm2rtlil 801 equal / 3 not-equal /
> 67 reject in both modes (of 871). Passes 105-113 CONVERTED NINETEEN ROWS
> after 33 dry groundwork passes (70-103): port_chained_type_param (105),
> mem_packed_2d_byte_write (106), type_param_packed_dim (107),
> anon_struct_packed_dim + cva6_struct_param_field + type_param_unpacked_port
> + StructParamFieldRange + StructParamFuncBodyFieldCompare +
> StructParamPatternInitCast (108), type_param_override_elem_sel (109),
> SequenceInst + const_cast_signext + packed_array_struct +
> unpacked_elem_partsel_comb (110), cfg_func_width_loop + LargeValue2Struct
> (111), arb_idx_cast (112), ibex_tracer (113). The turn came from the
> HEAD-ANCHORED SELECTION rule (user course-correction 2026-09-22, memory
> head-anchored-selection): every brief names the open corpus tests it
> targets and their measured uhdm-cmp head cluster, predicts each row's cmp
> line-count movement by name, and refills come from the head clusters, not
> from residue lists; batching EVERY located face on one ground converted six
> rows in one pass (108). Since pass 108 two implement+verify pairs run
> concurrently on DISJOINT FILE SETS: the parameter line owns ParamEmit.cpp +
> EmitHelpers.h + StmtEmit.cpp (passes 111, 113), the typespec line owns
> TypeEmit.cpp + UhdmExporter.cpp + ModuleEmit.cpp + ExprEmit.cpp (passes
> 112, 114); each brief names the sister's files as FENCED, a face whose fix
> sits in a fenced file stops at the decode and is reported as a located
> residue for the other line. Every landing: apply the verifier's patch
> stacked on the current head (a pair's base may be one or two commits back
> when the sister landed first), build -j 2, goldens 23/0 + /bin/false 0/23,
> three sweeps --jobs 3 into /tmp/intr11uNNN/{sl,u2r,u2r_def}, row-joins vs
> results/*.csv and vs the controls, byteverify with a-priori movers by name,
> canaries + ctcan2 + canaudit (tools/probe/r11u107repro ships the battery),
> the ten hard db pins, then PROMOTE converted rows by surgical sed on the
> exact row text (u2r: golden_uhdm2rtlil.csv both modes + gate_uhdm2rtlil.csv
> testflags; surelog: golden_surelog.csv per converted mode), regenerate the
> GOLDEN_EQUIVALENCE.md §3.3 rows from scripts/accounting.py --md and update
> SUPPORT_MATRIX.md in the SAME commit; then rotate the controls to
> /tmp/ctl_wd_{sl,u2r,u2r_def}_<head> + /tmp/ctl_*_<head>.csv +
> /tmp/pris_<md5-4>.bin, prune the pair's worktrees and /tmp scratch, and
> re-measure every open head on the new controls before refilling. Open
> after 113 (+ the three slang-fenced): stamped_gen_param 11 (a module
> variable typed q2::impl_t wants golden's bare ref_typespec — typespec line),
> ibex_icache (a nested-generate always_ff left-hand index reading a package
> parameter stays a ref_obj bound to an enum_const in golden — ExprEmit),
> ibex_pmp 64 (a param_assign right-hand side written 32'h00000FFF keeps HEX
> const type 5 in golden — parameter line), Rggen default (CONVERTED by the
> queued r11u115 patch = pass 114; its testflags row is SURELOG_FAIL).
> Instrument laws recorded this stretch: a package-homed declaration keeps a
> parameter-read range bound UNFOLDED (ref_obj) in golden while module and
> generate homes fold it to the declared width; the producer folds a range
> bound to INT size 64 only for sub/mult/div/mod/power/conditional; a
> parameter's typespec name comes from WHICH OBJECT IS COPIED (the package
> listing object vs a bare clone), never from a qualifier rewrite; the
> UVM-family databases move by a 0-or-4-line UINT/vpiDecompile coin on every
> build and must be attributed order-blind.
> The pass-103 paragraph below is HISTORY.
> **v1.87 campaign refresh (2026-09-22, HEAD = the pass-103 landing).** The
> matrix-1.87 branch has landed 103 passes since the df23d880 rebaseline:
> surelog 474/9 default + 469/8 testflags (of 798; 6 of the 17 NE row-modes
> are the three slang-fenced tests), uhdm2rtlil 788 equal / 16 not-equal /
> 67 reject in both modes (of 871). Passes 94-103 are ALL GROUNDWORK — zero
> conversions, zero regressions — with corpus bytes moving TO GOLDEN at 94
> and 97 (ibex_icache, divide and add-mint cases). Since the pass-93 refresh
> the master moved to Fable 5.1 and the subagent pin to claude-opus-5-5
> (user directive 2026-09-22; a pair now lands in roughly 70-140 minutes).
> Landed: the mult/div/mod INT mint + written-digit leaf + concat kind-1 +
> bare replication (94), the complete program flattening per member kind +
> the empty loop's copy + three verifier name/order fixes (95), the
> name-keyed class registry + module-own gen-block class + interface classes
> at the design root + def-view final block (96), the tick literal as one
> digit + the add mint climbing the tree + the comparison's minus one + the
> chain's initializer (97), every interface's classes at the root + six
> nested-module laws (98), the power case's INT mint with two digit laws
> decoded-and-OFF pending the reader's width (99), the ported nested module's
> shell + the scoped definition key + the library-unit guard (100), the
> reduced comparison operand + the evaluated call fold with seven decline
> gates + the unknown-literal decline (101), the file-scope namesake's key at
> entry + the unreached definition's ports on three roads (102), and the
> definition table's top-road, program and interface namesakes keyed at
> entry (103). COURSE CORRECTION at 103: 33 groundwork passes had converted
> nothing because briefs followed residue chains; every brief now names the
> open corpus tests it targets and their measured head cluster (memory
> head-anchored-selection; cluster A = one struct-member range-bound fold
> head shared by four tests). Instrument laws recorded this stretch: censuses walk
> GOLDEN databases first; slot scorers are blind to INVENTED entries (the
> whole-dump distance and the judge arbitrate); location-keyed scorers are
> blind to rangeless golden constants (net-name second key); a verifier once
> applied into the MAIN tree (prove tree = base + patch before continuing).
> The queue: the reader-width hand-off + size face (r11u104, in flight), the
> definition table's top road + program namesake (r11u105, in flight), the
> param_assign-site fold rules (pass-101 R0), the parameterized-class listing
> (pass-96 R0, Heisenbug road), pass-95 R3/R4/R5, the interface module-shell
> kind divergence, pass-100 R1/R3, pass-92 R0 parameter half, RV94-6, the
> $unit ref_obj shape, the enum-hop const type, pass-91 R3+R4, pass-83 R4,
> pass-85 R2/R3, pass-87 R1/R4, pass-86 defparam VALUE, pass-89 R2/R3,
> pass-80 R2/R3, r11u67 R-KWDUMMY + pass-64 element-reach, BBPI 62 bare
> cells, r11u70 R3, r11u68 R0, r11u73 R2, pass-79 R3, the kind-2/kind-0
> call-wrapped hole, RV97-1, TRIAGE2 singletons.
> The pass-93 paragraph below is HISTORY.
> **v1.87 campaign refresh (2026-09-22, HEAD = the pass-93 landing).** The
> matrix-1.87 branch has landed 93 passes since the df23d880 rebaseline:
> surelog 474/9 default + 469/8 testflags (of 798; 6 of the 17 NE row-modes
> are the three slang-fenced tests), uhdm2rtlil 788 equal / 16 not-equal /
> 67 reject in both modes (of 871). Passes 84-93 are ALL GROUNDWORK — zero
> conversions, zero regressions — but pass 93 moved the first corpus bytes
> since pass 69: ibex_icache moved TO GOLDEN in both modes (its row stays
> not-equal). Landed since the pass-83 refresh: the module-route
> Value-store encoding + qualified pin (84), the interface clone's drive
> fields + width/decompile (85), the signed store test + decimal width
> (86), the interface net-decl-assign listing + declined cells (87), the
> signed chain + the package 64-cap + the override's own width (88), the
> strength declaration that writes nothing + the delay that stays a name
> (89), the program's empty cont_assign vector + the strength-port revert
> (90), the package clone that outvotes the reader — gated on the WRITTEN
> ScopedName scope — + the negative fold's INT (91), the program-generate
> flattening + the interface port-declaration net mint in source order
> (92), and the implicit-sign synthesized typespec (32-default) + the
> negative and negative-zero folds with the concatenation fence (93). An
> instrument fix rode pass 93: the landed a-priori censuses walked an
> empty uhdm2rtlil root (singular/plural path mismatch); census94 keys on
> the sweep's own roots. The queue: the mult/div/mod INT mint (RV94-1,
> the next head — commoner than the minus), the out-of-32 unsized decimal
> (RV94-2), the concat class under an explicit type (RV94-3), the COMPLETE
> program flattening — initial/final/task-func/parameter re-home (pass-92
> R0), pass-91 R3 written-assign width + R4 binary hop, the $unit ref_obj
> shape, the enum-hop const type, pass-83 R4 hoisted-copy binding,
> pass-85 R2/R3, pass-87 R1/R4, pass-86 defparam VALUE, pass-89 R2/R3,
> pass-80 R2/R3 module listing, r11u67 R-KWDUMMY + pass-64 element-reach,
> BBPI 62 bare cells, r11u70 R3 cast holders, r11u68 R0 cast face, r11u73
> R2 dropped-operand, pass-79 R3 nested wrapper, TRIAGE2 singletons.
> The pass-83 paragraph below is HISTORY.

> **v1.87 campaign refresh (2026-09-21, HEAD = the pass-83 landing).** The
> matrix-1.87 branch has landed 83 passes since the df23d880 rebaseline:
> surelog 474/9 default + 469/8 testflags (of 798; 6 of the 17 NE row-modes
> are the three slang-fenced tests), uhdm2rtlil 788 equal / 16 not-equal /
> 67 reject in both modes (of 871). Passes 74-83 are ALL GROUNDWORK — zero
> conversions, zero regressions; the corpus-visible faces are thinning and
> the campaign is closing byte-truth laws the judge reads. Landed since the
> pass-73 refresh: the gen-scope binding stores + package-import homes
> (74), the written-digits value read + signedness casts (75), the cast
> typespec hand-on + unsigned-shift table (76), the module-side import
> hoist + kind tables (77), the package listing's two views (78), the
> unpacked holder builder (79), the written-path fold decline + the
> producer's-vector shadowing (80), the package-hop typespec with its two
> lexical fences (81), the interface import hoist + interface cont_assign
> reducer (82), and the import clones — the elaborated pointer, the
> explicit item, the clones-first slot (83). The queue: the interface
> clone's drive fields + interface-home width/decompile (r11u85, in
> flight), pass-83 residues, pass-80 R2/R3 module listing faces, r11u67
> R-KWDUMMY + pass-64 element-reach, BBPI 62 bare cells, r11u70 R3 cast
> holders, r11u68 R0 cast face, r11u73 R2 dropped-operand, pass-79 R3
> nested wrapper, pass-81 R1 module-route encoding, TRIAGE2 singletons.
> The pass-73 paragraph below is HISTORY.

> **v1.87 campaign refresh (2026-09-20, HEAD = the pass-73 landing).** The
> matrix-1.87 branch has landed 73 passes since the df23d880 rebaseline:
> surelog 474/9 default + 469/8 testflags (of 798; 6 of the 17 NE row-modes
> are the three slang-fenced tests), uhdm2rtlil 788 equal / 16 not-equal /
> 67 reject in both modes (of 871). Conversions since the pass-64 refresh:
> typed_named_pattern (69) — seven u2r conversions in the pass 44-69
> stretch. Landed grounds since: the net-type cells (64/66), the size-stamp
> walk (67), the gen-scope substitution merge + share-cut + namesake width
> (68/71), the cast-pattern mint (69), the value half of the reduce table —
> int64, the pow cast artefact, the decimal leaf, the untyped-mint chain
> (70/72), and the namesake Lhs binding + gen-scope member fold (73). The
> queue: the gen-scope NET namesake binding (pass-73 R1, the cheapest cell),
> the gen-scope localparam fold base, the package-imported namesake (two
> shapes measured), the signed based-decimal VALUE (pass-72 R1, the widest
> value cell), r11u67 R-KWDUMMY + the pass-64 element-reach refinement,
> BBPI's 62 bare op-ref cells, the r11u70 package/interface cast holders,
> the r11u68 cast face, and the TRIAGE2 singletons. The pass-64 paragraph
> below is HISTORY.

> **v1.87 campaign refresh (2026-09-17, HEAD = the pass-64 landing).** The
> matrix-1.87 branch has landed 64 passes since the df23d880 rebaseline:
> surelog 474/9 default + 469/8 testflags (of 798; 6 of the 17 NE row-modes
> are the three slang-fenced tests), uhdm2rtlil 787 equal / 17 not-equal /
> 67 reject in both modes (of 871). Conversions since the pass-54 refresh:
> iface_zero_width_field (60), struct_member_cfg_width (63) — six u2r
> conversions in the pass 44-63 stretch. TRIAGE2's clusters and the
> FOLDMAP's roads are all landed or queued out; steering now follows the
> probe-README residue chains. The queue: RV0 folded-operand encoding
> (packed road), the r11u49 R3 cast case (typed_named_pattern), the
> generate-scope share cell (struct_param_field_shift), the r11u56 R0
> member-width stamp on a based literal, BBPI's 62 bare op-ref cells, the
> r11v65 V-R1 dimension-less alias-of-alias (a landed-code guard), and the
> TRIAGE2 singletons. The pass-54 paragraph below is HISTORY.

> **v1.87 campaign refresh (2026-09-16, HEAD = the pass-54 landing).** The
> matrix-1.87 branch has landed 54 passes since the df23d880 rebaseline:
> surelog 474/9 default + 469/8 testflags (of 798; 6 of the 17 NE row-modes
> are the three slang-fenced tests), uhdm2rtlil 785 equal / 19 not-equal /
> 67 reject in both modes (of 871). The steering maps are
> `tools/probe/r11u44repro/TRIAGE2.md` (the second full triage; C1/C3/C4/C5/
> C6/C7 dispatched and landed, 5 conversions among them) and
> `tools/probe/r11u51repro/FOLDMAP.md` (the C2 fold-decision census: five
> producer roads; C landed pass 51, A pass 52 CONVERTING bits_of_type_param,
> B pass 53, E pass 54 CONVERTING struct_param_pattern_packing; road D
> refuted as mapped — its re-scoped law and every remaining road residue are
> queued in the FOLDMAP and the probe READMEs). Conversions this stretch:
> genvar_pow_index (44), packed_struct_array_fifo (47), bits_of_type_param
> (52), struct_param_pattern_packing (54). The pass-29 paragraph below and
> the v1.86 table under it are HISTORY.

> **v1.87 campaign refresh (2026-09-14, HEAD = the pass-29 landing).** The
> matrix-1.87 branch (Surelog v1.87 + UHDM v1.87 + slang 7d61e0ad1, since 2026-10-04 v12.0 545f88b2e with no database changed +
> uhdm2rtlil v0.68) has landed 29 passes since the df23d880 rebaseline:
> surelog 474/9 default + 469/8 testflags (of 798; 6 of the 17 NE row-modes
> are the three slang-fenced tests), uhdm2rtlil 768 equal / 36 not-equal /
> 67 reject in both modes (of 871). The full per-row triage of every
> remaining not-equal row lives at `tools/probe/r11u29repro/TRIAGE.md`
> (12 clusters + 12 singletons, ranked; K1 closed by pass 29). The v1.86
> table below is HISTORY.


Baselines (`scripts/accounting.py --md`): surelog default 473/481 comparable
equal (8 NE), testflags 468/475 (7 NE); uhdm2rtlil 679/679 both modes. The
19 surelog NE row-modes = 8 slang-fenced (out of scope) + 11 addressable
row-modes over 6 tests (Rggen/default CONVERTED by rgg18):

| row-mode(s) | head (official cmp lines = head-object DEPTH, not distance) | family / next law |
|---|---|---|
| SeqDriver×2 | CMP_EQUAL ×2 (CONVERTED at uvm219 — the WHOLE TEST CLOSED) | CLOSED — § hoistedThisRidesTheForwardedBlock219: the implicit this wire is a FORWARDED late-binding mint and lands span-sorted inside the forwarded block, never after the module's own wires (the import splices the package's late-binding list during the item pass); the SeqDriver ladder ran the clone-import chain, the view crossings, the interface family and the order law; R0 recorded: the implicit block is still golden's multiset in a different order, masked by the visited-set short circuit — the family's next face should the mask ever lift |
| MiniAmiq×2 | CONVERTED — CMP_EQUAL both modes at judge rc 0 (uvm227, the campaign's 9th+10th row-mode conversions, SIXTH whole-test close, THE LAST WORKABLE ROW) | § importedFreeCallTakesFirstListingImport227 — a bare call to a package free subroutine binds the FIRST wildcard-imported package's copy in written import order when that package's listing carries the name; one lookup at the call case, link-only; verifier CLEAN ACCEPT, twenty-three adversarial cases, conversion reproduced deterministically. THE ADDRESSABLE CORPUS IS AT ZERO: every remaining surelog not-equal row-mode belongs to the four slang-fenced tests (8 row-modes); u2r is 100% equal both modes. New-face residues at zero corpus cells: bare TASK calls, unit/generate import scopes, ::-argument decline, the program holder, the class-in-package holder |
| SimpleUVM×2 | CMP_EQUAL ×2 (CONVERTED at uvm209 — the WHOLE TEST CLOSED) | CLOSED — § hoistedLocalKeepsItsLifetime209: the automatic flag follows the source declaration's lifetime (Surelog's package collector does not stop at a class CONSTRUCTOR declaration — the hoist's mechanism; golden's module copy is the package listing value for value); the SimpleUVM ladder ran the depth artifact, the materialized-parameter family, the implicit-nets family, the design listing and the lifetime bit |
| BuildUVMPkg×2 | CMP_EQUAL (CONVERTED, uvm194 — the block's FIRST row conversion; the two baseline rows promoted in the landing commit) | CLOSED — § homeRetNameSelBindSurvivesDefViewUnbind194: a home return-name select binding survives the definition-view unbind (one gated exemption clause in the drain; the clone fence from an case); the family's whole ladder ran uvm170→194 |
| Scoreboard/default | CMP_EQUAL (CONVERTED at uvm212 — the comparable half of the test CLOSED; testflags is a slang reject outside the comparable set) | CLOSED — § classTdCloneTakesTheBasesEmptyListing212: a clone class typedef takes the base's EMPTY specialization listing (the vector verdict wore a singular face; library and macros decide nothing — clone-hood and the base's listing are the only variables; golden has zero clone-vs-base mismatches everywhere, ours had exactly one corpus-wide) |
| Earlgrey_0_1×2 (both modes) | CMP_EQUAL ×2 (default CONVERTED at earl122, testflags at earl117 — the WHOLE TEST CLOSED) | CLOSED — § genCaPatTagDeepBind122: the deep-bind walk descends a tagged wrapper to its pattern value (the wrapper earl121 had just taught the default view to keep); the listing framing refuted (the variables vector read 4/4 both sides — a BINDING law); the Earlgrey ladder ran earl104→122 |
| Rggen/default | **CMP_EQUAL** (converted by rgg18) | Rggen's one comparable mode passes the official uhdm-cmp; its dump column stays `differ` (phase-3 residues R-N3 103 golden-only ELAB hier_paths / R-A 810 symbolic range bounds / R-D / R-N4 / R-N5 / R-E hold byte-identity, block nothing); the Rggen slot now refills on the next-largest surelog NE family (rgg18 landed: gen-scope localparam fold digits = the mathematical value, pre-truncation, own sign + the verifier's 64-bit-word and stored-value refusals) |

Byte pins that must never move: SVSwitch `4842211c4030`, YosysVerx
`6ccda350c24a` (both modes); InterfaceModPort/BlackParrotComplex/YosysOldOr
byte-identical to the control. Rate: ~44 landings in the last 24 h, 0
regressions, 132 verifier fix-before-landing re-cuts (313 landings total; several were SEGFAULTS on legal SV). Ladder lower bounds
(§10): ≥170 families remain; realistic closure 1–3 weeks of continuous
operation (Rggen → BuildUVMPkg → UVM five → Earlgrey).

Cross-family residues still open at that time (owner pass in parentheses):
uvm91 R-A/R-B, rgg9 R1 (gen-scope cont-assigns do not fold), buvm14 R1/R5,
earl60 R-cast/R-fold-forfeit, uvm89 R2, rgg8 R2, buvm13 R6/R7, earl59 R-V1,
buvm12 R1, rgg7 R1–R4, uvm88 R1/V1, earl58 R1 (1,989 Earlgrey cells: d1
bit_select index in for-generate cont-assigns), uvm87 R-A, buvm10 R1, buvm11
R3, earl57 R3 (stale `currentScope` throughout `emitInstance` — the biggest
structural lead), design::Typespecs 123/89 + Parameters/Param_assigns
45/NULL, and the CLUSTERS.vladder1.md families. The CURRENT list is always
the "Residues"/"R0" paragraphs of the last commit per family.

---

## 4. The unit of work: a PASS (implement + adversarially verify)

Every landing is one pass, named `r10<family><n>` (uvm92, buvm16, earl61,
rgg10 …), run as TWO agents in sequence, each in its own git worktree at the
same BASE commit:

**Implementer** receives a BRIEF (§5) naming the head; it must
1. Decode the head from the pristine cmp log itself (never trust the brief's
   framing — briefs have been wrong about "missing object" vs "null vector",
   "listing" vs "link", "RHS <null>" vs size mismatch; see §9).
2. CENSUS golden-vs-ours over the whole family BEFORE any code, calibrated
   golden-vs-golden first (a census that reports 0 on golden-vs-golden is the
   only census that means anything). Keys must be COMPARE-VISIBLE fields.
3. DECODE the law from Surelog SOURCE (quote file:line), then MEASURE it on a
   purpose-built golden grid (cases `*.sv` run through the real Surelog +
   both binaries), refuting the brief's suggested predicate if the grid says
   so (it usually does — "the brief names the decider cell, not the law").
4. Implement the smallest gated change (a `§ <name><n>` law comment at the
   site explaining what was measured), PREDICT the movers BY NAME from
   pristine databases FIRST, then run the five gates (§6) and the boundary
   (every committed case under `tools/probe`, both views, subdirs included).
5. Deliver `/tmp/<pass>.patch` = `git diff` vs BASE, applying clean on a
   fresh BASE worktree, surface = production files + `tools/probe/<pass>repro/`
   only, and a report whose FINAL TEXT is the evidence (numbers, not prose).

**Adversarial verifier** rebuilds both binaries itself, reproduces EVERY
headline number bit-for-bit, then tries to BREAK the law with new cases
(orders, names, cases, scopes, contexts the implementer's grid did not vary —
"an case agreeing is not an case testing"; a grid naming everything a_t/b_t/c_t
over A/B/C is self-confirming). Any pristine-right → patched-wrong cell on
legal SV is FIXED BY THE VERIFIER (minimal, gated), the full battery re-run,
and `/tmp/<pass>.verified.patch` shipped. 46 of 88 landings needed such a
re-cut; several caught SEGFAULTS on legal SV that no gate would have shown.

Four passes run concurrently (one per row family). Bases drift: a patch made
at an older base is applied with `git apply -3` (three-way; same-point
function-insertion conflicts in `ModuleEmit.cpp` are routine — keep BOTH,
close ours before theirs).

---

## 5. Brief template (what to hand an implementer)

Standing ops rules (copy verbatim into every brief — see the `OPS` block in
any `scratchpad/*.js` if available, else reconstruct from §1 and §9):
repo/branch/BASE; own worktree + pass-prefixed scratch only; no writes to the
main tree (two agents left empty stray files there — every redirect names a
path); results/*.csv read-only; never git stash; -j 2; sweeps --jobs 3 with
own --out/--workdir; export SLANG_UHDM and audit every `cmds.txt` by binary
path; freeze binaries (`chmod 555` copies) BEFORE any sweep; never dispatch
the four fenced tests, never run any binary, gdb or script on their sources or
a copy, every source scan excludes them by word boundary; the ladder is
measurement-only; LHS is always golden;
ONE head per run (`grep -c '^LHS:'`); Compare reads
VpiType/VpiName/VpiDefName + per-kind fields, never fullname/span
(VpiDecompile IS read); movers as ROWS; Scoreboard/default is a ~50/50 COIN
(order-blind attribution only); census golden-vs-golden first; boundary must
compile subdir cases with the file list on fd 3 (children `</dev/null`,
PROCESSED asserted, scratch keyed on RELATIVE path); every case cell records
rc (never let an rc=139 hide as SLANG_REJECT); canaries + pins; the five
gates; deliverable spec.

Then the TARGET paragraph: the head verbatim (LHS/RHS lines from the cmp
log), the source lines, the suspected mechanism as a QUESTION not a fact,
what to census, what to decode in Surelog (name the files), what grid to
measure on golden, where our emitter site probably is (`grep` hints), what
existing laws neighbour it (name them so the pass does not fight them), and
"predict movers by name across BOTH corpora; CMP_EQUAL rows must stay
CMP_EQUAL judged by status AND dump; if any row PASSES cmp SAY SO LOUDLY and
do NOT edit results/*.csv; report new heads as R0."

Then the VERIFIER paragraph: reproduce bit-for-bit; break the law along the
axes listed; every named earlier law's cases must stay byte-identical; fix
pristine-right→patched-wrong cells yourself; ship `.verified.patch`; VERDICT +
ranked residues.

Worked examples of the exact text: the `scratchpad/<pass>.js` files of this
session (if the scratchpad survives) or, equivalently, the `INPUTS.*.txt`
file committed in each `tools/probe/r10<pass>repro/`.

---

## 6. The integration cycle (master, ONE PATCH AT A TIME)

Run from the main tree at HEAD, after a pass reports ACCEPT (or ACCEPT-WITH-
FIX → use `.verified.patch`). Every step is a gate; stop at the first red.

```bash
cd ~/git-repos/slang-uhdm
P=/tmp/r10<pass>.verified.patch            # or /tmp/r10<pass>.patch when unchanged
git status --short | grep -v '^??'          # must be EMPTY (also remove stray ?? files)
for n in UnsignedParam HierPathEval FileLocalParam TopParam; do            # fence check
  awk '/^diff --git/{f=$4} /'$n'/{print f}' $P | grep -v canaudit | grep -c .; done   # all 0
git apply -3 $P 2>&1 | grep -v 'Falling back to direct application\|whitespace'   # rc 0
git reset -q; git status --short | grep -v '^??'; grep -c '<<<<<<<' $(git diff --name-only -- src include)  # 0
timeout 590 cmake --build build -j 2 2>&1 | grep -E ' error |Built target slang_uhdm$'
md5sum build/slang-uhdm
export SLANG_UHDM=$PWD/build/slang-uhdm
tests/sweep.sh --filter '^Assign' | tail -3                  # regressions=0 (quick smoke; the full sweeps follow)
SLANG_UHDM=/bin/false tests/sweep.sh --filter '^Assign' | tail -1   # must NOT read regressions=0 (negative control)
W=/tmp/wd<pass>; mkdir -p $W/sl $W/u2r
nohup bash -c "python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 2 --out $W/sl.csv --workdir $W/sl > $W/sl.log 2>&1" >/dev/null 2>&1 &
nohup bash -c "python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 --out $W/u2r_tf.csv --workdir $W/u2r > $W/u2r_tf.log 2>&1; python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default --jobs 2 --out $W/u2r_def.csv --workdir $W/u2r > $W/u2r_def.log 2>&1" >/dev/null 2>&1 &
# u2r finishes in ~30 s, surelog in ~14 min. Wait for the CSV files to EXIST (until-loop), then:
grep -o 'slang: *[^ ]*slang-uhdm' $(find $W/u2r -name cmds.txt | head -1)   # the MAIN-TREE binary
bash tools/probe/r10oth8repro/ct8rows.sh results/gate_uhdm2rtlil.csv $W/u2r_tf.csv | tail -1     # PASS
bash tools/probe/r10oth8repro/ct8rows.sh /tmp/ctl_u2r_<HEAD>.csv     $W/u2r_tf.csv | tail -1     # PASS
bash tools/probe/r10oth8repro/ct8rows.sh /tmp/ctl_u2r_def_<HEAD>.csv $W/u2r_def.csv | tail -1    # PASS
SELFCHECK=1 bash tools/probe/r10oth4repro/byteverify.sh $W/u2r /tmp/ctl_wd_u2r_<HEAD> | tail -3  # MOVERS 0/1358 (unless predicted)
bash tools/probe/r10oth8repro/ct8rows.sh results/golden_surelog.csv $W/sl.csv | tail -1          # PASS (or exactly the claimed conversion — quote it, promote the row yourself)
bash tools/probe/r10oth8repro/ct8rows.sh /tmp/ctl_sl_<HEAD>.csv     $W/sl.csv | tail -1
SELFCHECK=1 bash tools/probe/r10oth4repro/byteverify.sh $W/sl /tmp/ctl_wd_sl_<HEAD> | grep -E 'MOVER|SELFCHECK|PATH'
#   every mover must be one the pass PREDICTED BY NAME. Scoreboard/default is a coin: attribute by
#   uhdm-dump path-normalised ORDER-BLIND diff (sort both dumps; 0 lines ⇒ coin, else the law's lines).
bash tools/probe/r10uvm67repro/rowheads.sh $W/sl /tmp/heads<pass> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
#   (SKIP-NOFILE on Scoreboard/tf + Rggen/tf is expected; counts are DEPTH not distance)
bash tools/probe/r10uvm52repro/canaries.sh $W/sl.csv results/golden_surelog.csv | grep 'ok='       # ok=52 changed=0
bash tools/probe/r10uvm52repro/canaries.sh $W/u2r_tf.csv results/gate_uhdm2rtlil.csv | grep 'ok='  # ok=8 changed=0
EXPECT_UNKNOWN=1 bash tools/probe/r10uvm67repro/ctcan2.sh results/golden_surelog.csv $W/sl.csv | tail -1     # PASS
EXPECT_UNKNOWN=6 bash tools/probe/r10uvm67repro/ctcan2.sh results/gate_uhdm2rtlil.csv $W/u2r_tf.csv | tail -1 # PASS
(cd tools/probe/r10<pass>repro && bash canaudit.sh canaries.sh ctcan2.sh | tail -1)               # PASS
# protected DBs by name (md5 vs control): InterfaceModPort BlackParrotComplex YosysOldOr SAME; SVSwitch 4842211c4030; YosysVerx 6ccda350c24a
git add <production files> tools/probe/r10<pass>repro [tools/probe/r10v<pass>repro]
# DOCS IMPLIED BY THE LANDING RIDE WITH IT: if §3b of RESUME.md (or GOLDEN_EQUIVALENCE
# §3.3) needs refreshing because of this landing (heads, metrics, progress), edit it NOW
# and `git add` it with the patch — do not split a landing's numbers from the code that
# produced them (user direction 2026-08-18). Genuine documentation-only work (rules,
# templates, corrections) may be committed on its own with a `docs:` subject.
git commit -F - <<'EOF'
block-3 groundwork: <family> pass N — § <law>, <what the head was and how it moved>, <verifier verdict>
<DECODED MODEL: Surelog file:line, the rule, gates/fences>
<MEASUREMENTS in DURABLE terms only: heads before/after, census/grid/case counts, conversions, "gates all green" in one line, boundary summary>
<RESIDUES + R0 — the R0 line is what scripts/resume_survey.sh greps for>
Evidence: tools/probe/r10<pass>repro/README.md (+ the verifier's tools/probe/r10v…repro/README.md)
Co-Authored-By: <your model name> <noreply@…>
EOF
# COMMIT-MESSAGE HYGIENE (user direction 2026-08-18): NO session-ephemeral content —
# no /tmp paths (patches, worktrees, scratch, controls), no binary/patch/cmp-log md5s,
# no per-database mover hashes, no "integration on <hash>: build md5…" or rotation notes.
# All of that lives in the committed pass README; the commit carries only what stays true.
# rotate controls: mv $W/sl /tmp/ctl_wd_sl_<NEWHEAD>; mv $W/u2r /tmp/ctl_wd_u2r_<NEWHEAD>; cp the 3 CSVs; cp build/slang-uhdm /tmp/pris_<md5>.bin; rm the OLD control set
# prune the landed pass's worktrees (git worktree remove --force; git worktree prune)
# refill the slot: dispatch the next pass at NEWHEAD on the R0 the landing named; verify the model pin
```

Never rebuild `build/slang-uhdm` while a sweep is running (sweeps invoke it).
Never poll a background waiter with a self-matching `pgrep`.

---

## 7. What "landing quality" means (the bar every commit met)

- 0 differing rows on both corpora (status AND dump column) except a claimed
  conversion, quoted and promoted by the master.
- Every byte mover PREDICTED BY NAME from pristine databases before the
  patched sweep, attributed line-by-line (order-blind), and every mover moves
  TOWARD golden (census TO-GOLDEN n / AWAY-GOLDEN 0 / STILL-WRONG 0).
- The head clears (or the family closes corpus-wide) — a cmp line count going
  UP is fine when the head object CHANGED (it is the new head's decompile
  size); a line count going DOWN with the same object is a partial fix.
- Boundary over every committed case: only the pass's own cases move, and any
  earlier-pass case that moves is re-measured against golden and moves TOWARD
  it.
- The decoded law cites Surelog file:line and a golden grid; refuted
  hypotheses are recorded as refuted, not dressed up.

---

## 8. Instruments (all measurement-only; the judge is uhdm-cmp)

- **rowheads.sh** — official cmp on named rows: cmp lines + `^LHS:` count.
- **ctladder** (`tools/probe/r10ladder1repro/ctladder.cpp`, build:
  `g++ -O2 -std=c++17 ctladder.cpp -I ~/.local/include -I <dir with ctfields.inc> -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ctladder`;
  usage `ctladder golden.uhdm ours.uhdm [--calib] [--max=N] [--budget=SEC]`) —
  mask-and-rerun around the OFFICIAL Compare: seeds the head into m_visited
  and re-runs to fixpoint/budget, printing one RUNG per masked head with a
  FAM= family string. `--calib` golden-vs-golden must read 0 rungs. Counts
  are LOWER BOUNDS (cascade masks suppress most of a big design); the rung
  set is not comparable across a change that removes a cascade mask. Cost:
  UVM rows minutes, Earlgrey budget-truncated. Never in the landing gate.
- **cluster.py / CLUSTERS.vladder1.md** — family census across rows (F1 =
  hier_path VpiName TEXT, F13 = super.new args, F116 …); re-rank the queue.
- **tsinst60.cpp** — names the OWNER of an `RHS: <null>` head via the
  official Compare (the field heuristic names the TARGET).
- **byteverify.sh / ct8rows.sh / canaries.sh / ctcan2.sh / canaudit.sh** —
  the gates (§6).
- Per-pass censuses (`ct<pass>cen.cpp` reading `Serializer::AllObjects`,
  `cen*.py` multiset joins) — copy the nearest one; keep the DEF/ELAB view
  OUT of the key (the two producers label it differently); make the payload
  COMPARE-VISIBLE (a span in the payload once hid an `Instance` flip).
- Whole-dump diff: `uhdm-dump` both DBs, `sed` the workdir path away, `sort`
  for order-blind, and SECTION by `|uhdmtopModules:` (DEF / ELAB /
  weaklyReferenced TAIL — the tail is unreachable to the judge; never count
  tail stamps).

---

## 9. Measurement laws and ops traps (read twice; every line cost a pass)

**Head decoding.** Read `~/.local/include/uhdm/BaseClass.h` SafeCompare
overloads and the owner kind's generated `Compare` order
(`~/git-repos/UHDM/build/generated/src/<kind>.cpp`) BEFORE naming the field:
the VECTOR overload sets BOTH containers on a size mismatch, and with `rhs ==
nullptr` sets the OWNER as LHS and leaves RHS unset (uvm90's "missing
super.new" was a NULL ARGUMENT VECTOR); the SINGULAR overload names the VALUE
with `RHS: <null>` (buvm13/15: `ref_obj::Actual_group`), and its mirror names
ours with `LHS: <null>`; a `hier_path` LHS with a full RHS is a `Path_elems`
size mismatch (buvm14). Verify from the pristine cmp log yourself; never
trust a carried-forward framing. ctladder's `SHAPE=MISSING-OURS` is
misleading when `FIELD=<rhs-null>`. Compare reads VpiType/VpiName/VpiDefName
+ per-kind fields; never VpiFullName/VpiFile/line/col; VpiDecompile IS read;
`typespec::Compare` walks `Typedef_alias` before `Instance`; `range::Compare`
reads VpiSize/Left_expr/Right_expr not vpiParent; no generated Compare reads
VpiParent (so sharing vs copying is invisible to the judge).

**Nondeterminism.** Scoreboard/default is a ~50/50 COIN per invocation
(svunit_pkg `vpiTaskFunc` list ORDER flip, ~92 dump lines; macro-buffer
SourceLocation ordering under slang's parallel parse — up to four pristine
hashes seen). Attribute ONLY order-blind (sorted dumps) or by face-matched
pairs; a null-sweep-clean read is luck. Earlgrey_0_1 both modes are
byte-deterministic per binary. Size-delta nonzero proves a real mover; zero
proves nothing.

**Harness traps.** `verify_golden.py` (and `tests/sweep.sh` over it) silently
defaults `SLANG_UHDM` to the MAIN-TREE binary — export it per binary and audit
every `cmds.txt` by binary PATH (not "slang-uhdm", which also matches
`slang-uhdm-goldens/`). `verify_golden.py` records rc=139 SEGFAULTS as
`SLANG_REJECT` wearing the last stderr warning (two hidden segfaults were
unmasked this way: MiniAmiq, Earlgrey/testflags) — cases must record rc.
`uhdm-cmp` writes the head to STDERR (a `2>/dev/null` made every head counter
read 0). `grep -c` with zero matches kills `set -e` chains (`; true`). `grep`
here is ugrep. SeqDriver default/testflags goldens are different cache
entries. A partially written dump reads like a result — re-read to
byte-stable. Dump paths embed the workdir — normalise before cross-dir diffs.
Rebuilding the main binary corrupts in-flight sweeps. BUILD RACE: never edit
a source while its TU compiles; freeze binaries (`chmod 555` copies) before
sweeps. Background waiters must not self-match their own `pgrep`.

**Boundary gates.** Compile SUBDIRECTORY cases too (sd8-12 keep cases in
subdirs; a top-level glob ran nothing and printed green); read the file list
on fd 3 with children `</dev/null` (a stdin-list was swallowed by the first
child); assert PROCESSED == LISTED; key scratch on the RELATIVE path
(`r10uvm33repro` has three `dut.sv`); a positive control (a deliberately
moved cell) proves the gate can see. The wide boundary alone convicts
corpus-invisible regressions (earl60's two).

**Census traps.** Calibrate golden-vs-golden FIRST. Slot-keyed censuses are
BLIND below the slot (earl56's 107-cell regression); use depth-keyed
identity censuses + the whole-dump sectioned diff. Multiset joins (keys
collide; a last-writer dict drops rows). NODEDUP censuses manufacture
AWAY-GOLDEN phantoms. Our hier_paths have an EMPTY VpiFile. An case AGREEING
with golden is not an case TESTING the law (check WHICH mechanism produced
agreement; a scorer that does not BUILD the databases scores −1/N on both
binaries).

**Emitter facts.** `currentScope` is STALE throughout `emitInstance`
(ModuleEmit.cpp ~6608–11500, zero assignments) — any name bind during
elaborated emission reads garbage (earl57 R3; high_conn casts mis-bind to the
child); the weaklyReferenced tail is unreachable to the judge; UHDM
`any_cast` IS-A — dispatch on `UhdmType()`; `VpiFullName(name)` = the
no-fullname idiom; a vector-form `<null>` prints the CONTAINER; the uhdm dump
SYNTHESIZES vpiFullName from the parent chain (a "naming residue" is often a
PARENTING residue — check vpiParent first); Surelog's naming is context-
dependent (do not "fix" `pkg::pkg::` uniformly); never call
`getDefaultSpecialization` in probes (it MINTS objects); do not force AST
binding during the DEF phase (Heisenbug: an AST-forcing walk changed later
emission); no premature helper extraction until 0 NE (the copies differ in
gate-verified ways).

**Ladder facts.** ONE head per run; masks cascade — the count is a lower
bound; not comparable across a change that removes a cascade mask; the
horizon rule for "cleared vs unreached" is unsound (masking reorders the
walk) — the whole-dump diff and census are the arbiter.

**Agent ops.** Pin the model + effort per agent and verify on the first
assistant turn; API 529 storms kill agents (cool down after 3, resume with
cached phases); a resumed implementer must RE-MEASURE an inherited worktree,
never trust its write-up; dead agents' worktrees keep uncommitted work; agent
baselines are often stale — only main-tree gates count; inspect patches for
collateral (results/*.csv edits, stray files, drivers hard-coding another
pass's paths, `rm -rf` on shared scratch, sitescans dispatching fenced tests);
`/tmp` grows ~350 GB in days — prune entries older than 6 h excluding
`/tmp/claude-1000` and live pass tags; keep the golden cache; the WSL VHDX
only shrinks from Windows.

---

## 10. Answering "how far are we / when done"

1. Official: `python3 scripts/accounting.py --md` (baseline) and
   `rowheads.sh` on the current controls (heads).
2. Rate: `git log --since='24 hours ago' --oneline | wc -l`.
3. Remaining population (measurement-only, ~15 min): build ctladder, run
   per NE row against its golden (`grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' <workdir>/<mode>/<test>-*/cmds.txt`)
   with the same budgets every time so the trend is comparable
   (SeqDriver 420 s, BuildUVMPkg 420 s, Rggen 300 s, Earlgrey 300 s per
   mode; `--max=3000`); report rungs, distinct `FAM=` families, and
   `suppressed=`/`cascades=` from the `[S]` line (cascade-dominated rows are
   uncountable). Last reading (22:00, HEAD 66f9c73): SeqDriver ≥225/67
   (truncated), BuildUVMPkg 180/55, Rggen 88/16, Earlgrey/tf ≥227/27,
   Earlgrey/default cascade-dominated.
4. Estimate = families ÷ (landings/day × families-per-landing≈1), stated as
   a lower bound with the caveats above. Never guess.

---

## 11. Docs: what is current, what is stale

- `RESUME.md` (this) — current at 2026-08-17.
- `PLAYBOOK.md` — method current; its counts (405/158/98 etc.) are phase-1
  history. Read for posture and the survey→decode→gate loop.
- `GOLDEN_EQUIVALENCE.md` — §1–2, §4 current; §3.3 table regenerated
  2026-08-17; §3.3's "three suite tests documented-unreachable
  (BuildUVMPkg/SeqDriver/SimpleUVM)" is OBSOLETE — all three are on active
  head chains (uvm83 brought the UVM container wall from 1.45M cmp lines to
  54); §5 open questions 3–4 still open.
- `HANDOFF.md`, `NOTES.md`, `PLAN.md` — historical logs (waves 1–4, phase 1);
  useful only for archaeology of a specific law.
- The per-pass `tools/probe/r10*repro/README.md` files are the real spec of
  the emitter's laws; the commit messages index them.
- The convergence memory files of the previous operator (Claude) are folded
  into §1 and §9 above.
