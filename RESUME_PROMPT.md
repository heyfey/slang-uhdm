# RESUME_PROMPT — paste this to the model that takes over (any model, any time)

> This prompt is deliberately timeless: it does not describe the state of the
> campaign, it tells you how to DISCOVER it. Everything you need to know is in
> the repository at `~/git-repos/slang-uhdm` (branch `auto5h`) and in `/tmp`.

---

You are taking over an autonomous engineering campaign mid-flight. Read this
whole message, then follow the "First 30 minutes" exactly before touching any
code.

## What the campaign is

`slang-uhdm` (`~/git-repos/slang-uhdm`) is a SystemVerilog→UHDM emitter built
on slang. The goal is that for every test in two corpora (`uhdm2rtlil`, 731
tests; the Surelog suite, 794 tests), in two modes each (`default`,
`testflags`), the OFFICIAL comparator `~/git-repos/UHDM/build/bin/uhdm-cmp`
judges our database EQUAL to Surelog's golden database. **Done = 0
`CMP_NOTEQUAL` rows among comparable rows, both corpora, both modes.** Golden
is the spec, Surelog's bugs included: we model Surelog's behaviour (decoded
from its source under `~/git-repos/Surelog`), we never patch Surelog, UHDM or
slang. `SLANG_REJECT` rows and the four slang-fenced tests are out of scope by
decision. The user's standing instruction is "keep converging non stop":
autonomous, continuous, four concurrent implement+verify pairs, ONE patch at
a time through the integration gate, measurements never guesses.

## First 30 minutes (do not skip)

1. `cd ~/git-repos/slang-uhdm && cat RESUME.md` — the canonical operator
   manual: mission and hard constraints (§1), repo/tool map (§2), how to
   discover the live state (§3), the pass structure (§4), the brief template
   (§5), the exact integration gate (§6), the landing bar (§7), instruments
   (§8), the measurement laws and ops traps that each cost a pass to learn
   (§9), how to answer "how far" (§10), which older docs are stale (§11).
2. `bash scripts/resume_survey.sh` (and once with `HEADS=1`) — the live state:
   HEAD, dirty tree, in-flight worktrees, UNLANDED patches, controls, the
   baseline table, the NE rows, and each family's declared next head (R0).
   Then follow RESUME.md §3's decision list literally (finish or discard an
   in-flight integration; integrate a completed unlanded verified patch;
   re-launch or drop half-finished passes; refill empty slots; regenerate
   missing controls).
3. Read `PLAYBOOK.md` (posture and method) and `GOLDEN_EQUIVALENCE.md` §1–2,
   §4.1–4.2 (target/harness/gates). Then the last ~10 commit bodies
   (`git log --format='%h%n%B' -10`) — each is a decoded law with numbers,
   residues and the next head — and the most recent
   `tools/probe/r10*repro/README.md` per family, to see what an acceptable
   pass looks like.
4. Verify the environment: `~/git-repos/UHDM/build/bin/{uhdm-cmp,uhdm-dump}`
   exist; `~/.cache/slang-uhdm-goldens` exists (never delete it);
   `cmake --build build -j 2` builds; `export SLANG_UHDM=$PWD/build/slang-uhdm
   && bash tests/check_goldens.sh` gives 23 PASS; `python3
   scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2
   --out /tmp/x.csv --workdir /tmp/xw` reproduces the committed baseline
   (`bash tools/probe/r10oth8repro/ct8rows.sh results/gate_uhdm2rtlil.csv
   /tmp/x.csv` → PASS).

## How to work (the loop that produced ~40 landings/day)

- One PASS per family (UVM chain, BuildUVMPkg, Earlgrey, Rggen), four in
  parallel, each = an IMPLEMENTER agent (own git worktree at BASE=HEAD; census
  golden-vs-ours first, decode the law from Surelog source, measure it on a
  golden grid, implement the smallest gated change, PREDICT movers by name,
  run the five gates + the boundary, deliver `/tmp/r10<pass>.patch`) followed
  by an ADVERSARIAL VERIFIER agent (own fresh worktrees; reproduce every
  number bit-for-bit; try to break the law with new arms; FIX any
  pristine-right→patched-wrong cell yourself; ship
  `/tmp/r10<pass>.verified.patch`). If you cannot run subagents, do both roles
  yourself in sequence, in separate worktrees, and hold yourself to the same
  evidence — the verifier role is not optional (46 of the last 88 landings
  needed a verifier re-cut; several were segfaults on legal SV).
- The MASTER (you) only dispatches, integrates (RESUME.md §6, every command),
  commits with a decoded-model message, rotates the controls, prunes the
  landed worktrees, refills the slot on the R0 the landing named, and keeps
  the loop going. Never rebuild the main binary while a sweep runs.
- Briefs name the DECIDER CELL, not the law: write the target as measured
  facts + questions (RESUME.md §5); expect the brief's mechanism to be
  refuted by the census — that is the method working.
- Answer progress questions with `scripts/accounting.py --md`, rowheads, the
  landing rate, and (measurement-only, ~15 min) the ladder per RESUME.md §10.

## Hard rules (repeat them into every brief)

Results CSVs are read-only baselines (only you promote rows, quoting them,
for a measured conversion); never dispatch or spell the four fenced tests
individually; `r10earl23` is quarantined; agents write only in their worktree
+ `/tmp/<pass>_*` (never the main tree, never `/tmp/claude-1000`, never other
passes' scratch); no `git stash`; never truncate `git apply` output; builds
`-j 2`, sweeps `--jobs 2`; export `SLANG_UHDM` and audit `cmds.txt` by binary
path (the harness silently defaults to the main-tree binary and records
rc=139 segfaults as `SLANG_REJECT`); the judge is `uhdm-cmp` only; extended
comparators are measurement-only and never in the landing gate; a mover
that was not predicted by name is a red gate; attribution is order-blind
(Scoreboard/default flips a task_func order coin per run); LHS is always
golden; Compare reads VpiType/VpiName/VpiDefName + per-kind fields, never
fullname/span; the head must be decoded from the pristine cmp log and the
generated `<kind>::Compare` + `BaseClass.h` SafeCompare overloads, never from
a carried-forward framing.

## When you land something

Commit message = the decoded model (Surelog file:line), the measurements
(gates, movers by name, census before/after, grid, boundary, heads), the
residues, and the NEXT HEAD (R0) — that message is the queue for whoever
comes after you. Then rotate the controls, prune the worktrees, refill the
slot, and continue. If you ever pause, leave the tree clean (no partially
gated modifications) and the survey script will let the next operator resume
exactly here.
