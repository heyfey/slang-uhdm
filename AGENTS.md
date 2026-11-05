# AGENTS.md

Guidance for coding agents (Claude Code, Codex, Cursor) working in slang-uhdm.
Read README.md first: it states the claim this repository makes and the
numbers behind it. This file states how work here is done. The skills under
`.agents/skills/` give the step-by-step procedures.

## What this repository is

slang-uhdm exports a SystemVerilog design, compiled by slang, to a UHDM
database that is identical to the one the pinned Surelog writes for the same
sources. **Surelog's database is the specification.** Where Surelog's output
has a quirk, the exporter reproduces the quirk, because every consumer was
written against Surelog's output. slang, Surelog, UHDM and uhdm2rtlil are
pinned submodules and are never patched here.

## Equal means measured equal

A test is EQUAL only when the gate says so: `tests/sweep.sh` builds Surelog's
golden database for the test (cached), runs slang-uhdm on the same sources,
and both `uhdm-cmp` (UHDM's structural comparison) and `tools/uhdm-strictcmp`
(every field uhdm-cmp ignores: names, files, spans, decompile, size, value,
child order) read the pair equal. The committed baselines under `results/`
record every row's status. A row that leaves EQUAL fails the gate. A row that
reaches EQUAL is promoted into the baseline by the commit that earned it.
See `.agents/skills/claim-equal/SKILL.md`.

## Layout

| Path | Content |
|---|---|
| `src/*.cpp`, `include/UhdmExporter.h` | the exporter (ExprEmit, ModuleEmit, ParamEmit, StmtEmit, TaskFuncEmit, TypeEmit, UhdmExporter) |
| `src/law/LawSwitch.h`, `src/law/LawState.h` | the switch reader, trace writer and per-pass state of every law (instrumentation only) |
| `uhdm_main.cpp` | the command line |
| `tools/uhdm-strictcmp/` | the strict comparator |
| `tests/sweep.sh`, `scripts/*.py` | the five-stage gate and its harnesses |
| `results/golden_*.csv`, `results/downstream_uhdm2rtlil.csv` | the committed baselines |
| `tests/probe/<pass>/.../dut.sv` + `LAW` | the probe cases (one law each), stage one of the gate |
| `tools/probe/<pass>repro/` | per-pass evidence: README, grid scripts, measurements, residue cases |
| `tests/LAWS.md` | generated law index: law to pass, commits, switches, source sites, cases |
| `tests/FENCED.md` | the four fenced tests |
| `third_party/` | slang, Surelog (with UHDM), uhdm2rtlil |

## Build and gate

    cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j 2
    make -C third_party/Surelog release          # producer, uhdm-cmp, uhdm-dump (once)
    tests/sweep.sh --jobs 3 --workdir /tmp/<name> # full gate, about one hour; exit 0 required
    tests/sweep.sh --corpus probe                 # one stage: probe | surelog | uhdm2rtlil | downstream | svtests

Never rebuild `build/slang-uhdm` while a sweep runs (sweeps invoke it). Before
a long sweep, freeze a copy of the binary (`cp` + `chmod 555`) and point
`SLANG_UHDM` at it; `verify_golden.py` silently defaults to the main-tree binary.

### Golden cache

Surelog's database for a test never changes while Surelog and the sources are
pinned, so the harness builds each golden once and keeps it under
`~/.cache/slang-uhdm-goldens` (`GOLDEN_CACHE=<dir>` relocates it, `=0`
disables it). Nothing is cached by hand: the key is Surelog's version line
plus the test's path and arguments relative to the corpus roots (plus the text
of a probe case), so an edited case, a moved case or a Surelog pin bump
rebuilds its golden on the next run, and a cache copied to another machine
serves it. The first full sweep on a machine builds every golden (hours); a
cached sweep takes about an hour. Failures are not cached. When pruning
`/tmp`, never prune the cache; a sweep's work directory is scratch.

### Resource defaults

These are defaults for the campaign machine (limited memory). **The user's
prompt overrides them**; otherwise use them as written.

| Setting | Default |
|---|---|
| build | `cmake --build build -j 2` |
| sweep and harnesses | `--jobs 3`, one sweep at a time |
| concurrent agents (passes) | 2 |
| spawned agents | pass model and effort explicitly in every brief |
| scratch | the session scratchpad; `/tmp/<tag>` for sweep work directories |

## How exporter code is written: laws

Every behaviour the exporter reproduces is a **law**: a `// § <name><pass>`
comment at the site that states what was measured in Surelog's source and on a
golden grid, a guard `lawOn(<pass>, "R11U<pass>_<LAW>_OFF")` from
`src/law/LawSwitch.h` so a reviewer can switch the law off and get the earlier
bytes back, optional `lawTrace(<pass>, "§ name", detail)` tracing, state in
`src/law/LawState.h`, and the cases that prove it under `tests/probe/<pass>/`
with a `LAW` file. `python3 scripts/law_index.py` regenerates `tests/LAWS.md`;
the sweep fails when it is stale. Work is organised in numbered **passes**
(`r11u<N>repro` implementer, `v11u<N>repro` verifier); the next pass number
is one above the highest under `tools/probe/` and `tests/probe/`
(`ls tools/probe tests/probe | grep -oE 'r11u[0-9]+' | sort -t u -k 2 -n | tail -n 1`).
See `.agents/skills/fix-one-test/SKILL.md`.

## Hard rules

- **Do not patch the submodules** (slang, Surelog, UHDM, uhdm2rtlil) or the
  sv-tests checkout. slang rejects some sources Surelog accepts; those tests
  are out of scope, not bugs to fix here.
- **`results/*.csv` change only by promotion**: the exact rows a gated sweep
  read as conversions, in the commit that lands the fix. Never edit a row to
  make a gate pass.
- **The four fenced tests** (`tests/FENCED.md`): never run, open, copy, debug
  or spell them. Read their names from the `FENCED=` line of
  `tools/probe/r11u107repro/canaudit.sh`; every scan over corpus trees
  excludes them by word boundary.
- **Never commit** a `.uhdm` golden (tied to the UHDM commit; the cache builds
  it) or a patch file whose content landed in `src/`.
- **No per-pass headers**, no `getenv` outside `src/law/LawSwitch.h`.
- **A refactor of instrumentation** (switches, traces, headers) lands only
  with every database byte-identical (full sweep + md5 comparison against a
  control sweep). Exporter logic is refactored only when the gate stays clean.
- **One landing = one commit**: law, cases, pass README, `tests/LAWS.md`,
  promoted rows together, and the message names the laws as `§ name` (the
  law index reads them from `git log`).
- **Work in the checkout you were given.** A git worktree is for concurrent
  agents only: when another agent builds or sweeps in the same checkout at the
  same time, each takes its own worktree at the same base (a worktree needs
  its own build). An agent writes only under its pass directory, the files
  its law touches and its scratch. Never `git stash`. Never touch another
  agent's processes or files.
- **A landing in the main tree takes a verify-pass first** when the resource
  defaults allow a second agent; a lone agent records in its pass README that
  no independent verifier ran.

## Skills

| Skill | Use it when |
|---|---|
| `.agents/skills/claim-equal/` | you are about to say a test, a case or a row is EQUAL |
| `.agents/skills/fix-one-test/` | one test or case is not equal and you want to make it equal |
| `.agents/skills/verify-pass/` | you are the adversarial verifier of another agent's fix |
| `.agents/skills/land-change/` | you integrate a verified fix into the main tree: gate, promote, index, commit |
| `.agents/skills/converge-group/` | many tests are not equal and you want to drive the group to zero |
| `.agents/skills/bump-matrix/` | a pin moves (slang, Surelog/UHDM, uhdm2rtlil) or a release is cut |

Claude Code reads them through `.claude/skills`, Cursor through
`.cursor/skills` (both symlinks to `.agents/skills`).

## Documents

| Document | Content |
|---|---|
| README.md | the claim, the pass rates, the release matrix |
| GOLDEN_EQUIVALENCE.md | the definition of the target, the two modes, the flag policy, the decisions |
| tests/README.md | the gate: stages, statuses, baselines, golden cache, downstream and sv-tests stages |
| tests/probe/README.md, tools/probe/README.md | the probe set and the evidence tree |
| tests/LAWS.md, tests/FENCED.md | the law index; the fenced tests |
