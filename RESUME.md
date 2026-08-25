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
- corpora: `uhdm2rtlil` (731 tests, `~/git-repos/uhdm2rtlil/test`) and the
  Surelog suite (794 tests, `~/git-repos/Surelog/{tests,third_party/tests}`;
  the UVM trees are under `~/git-repos/sv-tests/third_party/tools/Surelog/third_party/UVM`);
- modes: `default` (sources + where-to-find-them args only) and `testflags`
  (the test's own command line, UHDM-irrelevant parts removed).
- **Done = 0 `CMP_NOTEQUAL` rows** among comparable rows in both corpora, both
  modes. `SLANG_REJECT` (slang refuses the source) is OUT OF SCOPE by decision;
  `SURELOG_FAIL`/`NO_DATABASE`/`DEFERRED` are non-comparable.

**Golden is the spec, bugs included.** When Surelog mis-evaluates (Rggen's
corrupted packed-array evaluation, generate-if conditions it cannot value,
`ExprEval` quirks), we MODEL the mis-evaluation. We never "fix" Surelog and we
never patch UHDM. Patching **slang** is out of scope too.

**The judge is `~/git-repos/UHDM/build/bin/uhdm-cmp` and nothing else.** Every
CMP_EQUAL claim, every canary, every gate uses it. Extended comparators
(the ladder, censuses) are MEASUREMENT-ONLY (user authorization 2026-08-16:
"you can fix cmp to provide more comparison/info, as long as we still use the
official cmp to claim it is correct") and must never become a bottleneck
(never in the landing gate battery; report their cost when run).

**Standing user directives** (verbatim spirit):
- "keep converging non stop" — autonomous, continuous; the session ends when
  the user ends it, never at a self-declared milestone; never ask "shall I
  continue".
- Answer "how far are we" with MEASUREMENTS, never guesses (§10).
- Master = coordinator only (dispatch, integrate, gate, commit). Subagents =
  implement + adversarial-verify pairs, four concurrent, refilled the moment a
  slot lands. Pin the strongest available model + high effort for subagents
  and CHECK the pin on each dispatch (with Claude: `model:'opus'`,
  `effort:'high'` — session-model inheritance once killed 9 agents).
- ONE PATCH AT A TIME through the integration gate; the master promotes
  baseline CSV rows itself, with the rows quoted, only for real
  conversions/unmaskings.

**Security/hygiene constraints (in force, do not relax):**
- `results/gate_uhdm2rtlil.csv` and `results/golden_surelog.csv` are
  committed READ-ONLY baselines; only the master edits them, only for a
  measured conversion/unmasking, quoting old→new rows in the commit.
- The four slang-fenced tests (`UnsignedParam`, `HierPathEval`,
  `FileLocalParam`, `TopParam`) are NEVER dispatched, and probe artifacts must
  not spell those names individually (`canaudit.sh` reads that as
  FENCE-BREACH; its own fence list and superstring test names like
  `SizeOfUnsignedParameter` are the only allowed mentions).
- `r10earl23` (Earlgrey pass 23, `/tmp/r10earl23.patch`) is QUARANTINED: its
  agent edited a file outside its worktree (`.handled`) — flagged by a
  security classifier as a possible fake-review marker. Do not integrate it
  without explicit user direction. Audit is recorded in the commit history.
- Agents write ONLY inside their own worktree + their own pass-prefixed
  `/tmp/<pass>_*` scratch. Never `/tmp/claude-1000` (harness dir). Never
  `git stash`. Never truncate `git apply` output. `GOLDEN_DEFER` stays unset.
  Sweeps `--jobs 2`. Builds `-j 2`.
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
  tests/check_goldens.sh          23 golden dump tests (SLANG_UHDM must be exported!)
  results/golden_surelog.csv      surelog baseline (1588 rows) — READ-ONLY
  results/gate_uhdm2rtlil.csv     u2r testflags baseline (731 rows) — READ-ONLY
  tools/probe/r10<pass>repro/     one dir per landed pass: README (the decoded law),
                                  CENSUS/PREDICT/GATES/LADDERS, arms (*.sv), instruments
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

~/git-repos/UHDM/build/bin/{uhdm-cmp,uhdm-dump}   the judge and the dumper
~/git-repos/UHDM/build/generated/src/*.cpp        generated <kind>::Compare bodies — READ THESE
~/.local/include/uhdm/BaseClass.h                 SafeCompare overloads (§9 head-decode)
~/git-repos/Surelog/                              Surelog SOURCE (decode laws from it: CompileHelper.cpp,
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
   adversarial verifier; a dead verifier's partial arms are in `wt_v<pass>`)
   or, if nothing usable, drop the worktrees and re-dispatch the head.
4. **Empty slots** ⇒ dispatch a new pass per family from the R0 line of that
   family's last landing (the survey prints them). Four families in parallel:
   UVM chain (SeqDriver/SimpleUVM/Scoreboard/MiniAmiq), BuildUVMPkg,
   Earlgrey (both modes), Rggen.
5. **Controls missing** (`/tmp/ctl_wd_sl_<HEAD>` etc.) ⇒ build HEAD, run the
   two sweeps of §6 into new dirs, and `mv` them into place before judging
   anything.

Everything else — pins, canary names, fenced tests, quarantine — is in §1.

### 3b. Snapshot at the last doc update (2026-08-25 00:25, HEAD = the uvm128 landing) — EXAMPLE ONLY

Baselines (`scripts/accounting.py --md`): surelog default 471/481 comparable
equal (10 NE), testflags 466/475 (9 NE); uhdm2rtlil 679/679 both modes. The
19 surelog NE row-modes = 8 slang-fenced (out of scope) + 11 addressable
row-modes over 6 tests (Rggen/default CONVERTED by rgg18):

| row-mode(s) | head (official cmp lines = head-object DEPTH, not distance) | family / next law |
|---|---|---|
| SeqDriver×2 (uvm-1.2 tree) | 17 (depth) | a MISSING NET: golden hoists an implicit wire `sz` (logic_net work@top_tb.sz @uvm_packer.svh:488:15-488:17, vpiNetType 1) for `bytes = new[sz];` inside the out-of-body uvm_packer::get_bytes into the TOP MODULE work@top_tb; we mint none — the hoisted-net family of §§ withIterIterBindsHoistNet75 / oobRefVarLocalHoistNet107 / pkgFreeSubRefVarHoistNet117, landing in the top module's pool — uvm130's target (uvm127 landed: 17→17 new object, § pkgRetOobClassAndImportCloneTs127 — an OUT-OF-BODY method body takes Reduce::Yes like a free package function, so ExprEval::evalFunc stamps every call actual with the callee's formal's SHARED typespec by position; in-body methods never; module/$unit classes never; importer clones both views) |
| MiniAmiq×2 (uvm-1.2 tree) | 294 (depth) | a MISSING vpiJoinType: golden's `named_fork (uvm_pkg::uvm_phase::execute_phase::master_phase_process) @uvm_phase.svh:1400:9-1413:18` carries `vpiJoinType:1` for `fork : master_phase_process ... join_none`; our named_fork exists (same name, same Stmt children; spanned at the label text 1400:16-36, dump-only) but carries NO vpiJoinType — the compared field (named_fork::Compare reads it) — uvm131's target |
| SimpleUVM×2 + Scoreboard/default | 64 (depth) | the SAME cross-buffer read at a SINGLE-name built-in receiver, invisible to uvm128's two-buffer gate: uvm_object_defines.svh:1566 (the M_UVM_QUEUE_RESIZE macro) — golden's hier_path `abstractions.size`, ours named from macro text; 84 cells over 7 UVM DB-modes (size/push_back/pop_front); the next gate is likely 'the span mapped to ORIGINALS starts and ends in different FILES', with uvm128's census carrying the 87-row negative control (m_streams[stream.get_name()]-shaped, correct text, must not move) — uvm132's target (uvm128 landed: 124→64, § macroSplitRecvIsAstChain128 — a built-in receiver with no syntax node whose span ends lie in two macro buffers is rebuilt from the bound AST chain, each link carrying its own end location; the only corpus population was 7 cells at one site) |
| BuildUVMPkg×2 | 54 (depth) | `enum_var uvm_reg_hw_reset_seq::do_block::field_check_restore` (pp_output :79885:25-79885:44), the element variable of an array_var bound to `enum_typespec uvm_pkg::uvm_check_e` — the NAMED-typedef half of uvm126's family (a named element type binds golden's SHARED named typespec object; uvm126's cen126/score126/pred126 instruments and its grid A's six STILL-WRONG cells are pointed at it) — queued as uvm129 |
| Earlgrey_0_1/default | 90 (depth) | flash_erase_ctrl.sv:42 `BankAddrMask`'s shift AMOUNT (:42:57): golden folds the SUB-EXPRESSION `(PagesBitWidth + WordsBitWidth)` to constant UINT:16 sz32 with no typespec where we keep an operation (opType 24) over two folded leaves — fold every maximal non-bailing operand subtree with earl73's per-operator encoder tables, keeping earl85's leaf rule for a bare identifier — earl86's target (earl85 landed: 214/144→90/150, § srlgUnsizedBasedShiftBail85 — an UNSIZED BASED literal as a shift's arg0 (VpiSize -1) makes Surelog's reduceExpr bail and the whole tree is kept; § paOvFoldedRangeNoStamp85 — vpiOverriden follows the EMITTED range objects, a folded bound leaves no name and no stamp; § elabParamOpLeafValueFold85 — identifier leaves inside a kept tree take the instance's stored Value at the declared width with the bare signed int_typespec) |
| Earlgrey_0_1/testflags | 150 (depth) | `param_assign` PagesPerBank (:12:18) at the same u_flash_erase_ctrl instance: golden vpiOverriden:1, ours unset — the OTHER direction of the stamp, a wildcard-imported package parameter materialized into an instance (16 corpus cells, the whole of earl85's FAMILY-OVSTAMP) — earl87's target |
| Rggen/default | **CMP_EQUAL** (converted by rgg18) | Rggen's one comparable mode passes the official uhdm-cmp; its dump column stays `differ` (phase-3 residues R-N3 103 golden-only ELAB hier_paths / R-A 810 symbolic range bounds / R-D / R-N4 / R-N5 / R-E hold byte-identity, block nothing); the Rggen slot now refills on the next-largest surelog NE family (rgg18 landed: gen-scope localparam fold digits = the mathematical value, pre-truncation, own sign + the verifier's 64-bit-word and stored-value refusals) |

Byte pins that must never move: SVSwitch `4842211c4030`, YosysVerx
`6ccda350c24a` (both modes); InterfaceModPort/BlackParrotComplex/YosysOldOr
byte-identical to the control. Rate: ~44 landings in the last 24 h, 0
regressions, 81 verifier fix-before-landing re-cuts (178 landings total; several were SEGFAULTS on legal SV). Ladder lower bounds
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
   purpose-built golden grid (arms `*.sv` run through the real Surelog +
   both binaries), refuting the brief's suggested predicate if the grid says
   so (it usually does — "the brief names the decider cell, not the law").
4. Implement the smallest gated change (a `§ <name><n>` law comment at the
   site explaining what was measured), PREDICT the movers BY NAME from
   pristine databases FIRST, then run the five gates (§6) and the boundary
   (every committed arm under `tools/probe`, both views, subdirs included).
5. Deliver `/tmp/<pass>.patch` = `git diff` vs BASE, applying clean on a
   fresh BASE worktree, surface = production files + `tools/probe/<pass>repro/`
   only, and a report whose FINAL TEXT is the evidence (numbers, not prose).

**Adversarial verifier** rebuilds both binaries itself, reproduces EVERY
headline number bit-for-bit, then tries to BREAK the law with new arms
(orders, names, cases, scopes, contexts the implementer's grid did not vary —
"an arm agreeing is not an arm testing"; a grid naming everything a_t/b_t/c_t
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
path); results/*.csv read-only; never git stash; -j 2; sweeps --jobs 2 with
own --out/--workdir; export SLANG_UHDM and audit every `cmds.txt` by binary
path; freeze binaries (`chmod 555` copies) BEFORE any sweep; never dispatch
the four fenced tests; the ladder is measurement-only; LHS is always golden;
ONE head per run (`grep -c '^LHS:'`); Compare reads
VpiType/VpiName/VpiDefName + per-kind fields, never fullname/span
(VpiDecompile IS read); movers as ROWS; Scoreboard/default is a ~50/50 COIN
(order-blind attribution only); census golden-vs-golden first; boundary must
compile subdir arms with the file list on fd 3 (children `</dev/null`,
PROCESSED asserted, scratch keyed on RELATIVE path); every arm cell records
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
axes listed; every named earlier law's arms must stay byte-identical; fix
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
bash tests/check_goldens.sh | grep -c '^PASS'                 # 23
bash tests/check_goldens.sh | grep -c '^FAIL'                 # 0
SLANG_UHDM=/bin/false bash tests/check_goldens.sh | grep -c '^FAIL'   # 23 (negative control)
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
<MEASUREMENTS in DURABLE terms only: heads before/after, census/grid/arm counts, conversions, "gates all green" in one line, boundary summary>
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
- Boundary over every committed arm: only the pass's own arms move, and any
  earlier-pass arm that moves is re-measured against golden and moves TOWARD
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

**Harness traps.** `verify_golden.py` AND `tests/check_goldens.sh` silently
default `SLANG_UHDM` to the MAIN-TREE binary — export it per binary and audit
every `cmds.txt` by binary PATH (not "slang-uhdm", which also matches
`slang-uhdm-goldens/`). `verify_golden.py` records rc=139 SEGFAULTS as
`SLANG_REJECT` wearing the last stderr warning (two hidden segfaults were
unmasked this way: MiniAmiq, Earlgrey/testflags) — arms must record rc.
`uhdm-cmp` writes the head to STDERR (a `2>/dev/null` made every head counter
read 0). `grep -c` with zero matches kills `set -e` chains (`; true`). `grep`
here is ugrep. SeqDriver default/testflags goldens are different cache
entries. A partially written dump reads like a result — re-read to
byte-stable. Dump paths embed the workdir — normalise before cross-dir diffs.
Rebuilding the main binary corrupts in-flight sweeps. BUILD RACE: never edit
a source while its TU compiles; freeze binaries (`chmod 555` copies) before
sweeps. Background waiters must not self-match their own `pgrep`.

**Boundary gates.** Compile SUBDIRECTORY arms too (sd8-12 keep arms in
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
AWAY-GOLDEN phantoms. Our hier_paths have an EMPTY VpiFile. An arm AGREEING
with golden is not an arm TESTING the law (check WHICH mechanism produced
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
