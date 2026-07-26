# GOLDEN EQUIVALENCE — phase 2 of the convergence campaign

PLAYBOOK.md governs **how** to run a convergence campaign (gates, revert-and-
refine, never-pause). HANDOFF.md records **where** the emitter stands, wave by
wave. This document defines **phase 2**: what "equal to golden" means now that
phase 1 (uhdm2rtlil 0 DIFF) is done, and how to measure and drive it.

Read PLAYBOOK.md first. Everything in it still applies — this file only changes
the target and the measurement.

---

## 1. Target

Both corpora, both modes, all cmp-equal:

| Corpus | Tests | Source |
|---|---|---|
| uhdm2rtlil | 731 | `~/git-repos/uhdm2rtlil/test` |
| Surelog suite | 794 | `~/git-repos/Surelog/{tests,third_party/tests}` |

and two modes per test:

- **`default`** — both tools get the sources plus only the args that say *where
  to find them* (include paths, defines, library search, command files). No
  model-shaping flag on either side. This isolates the emitter: a failure here
  is a difference in the model itself, not in flag handling.
- **`testflags`** — Surelog gets the test's own command line **verbatim**;
  slang-uhdm gets the same line with the UHDM-irrelevant parts removed. This is
  the claim that actually matters: *run the way the test is really run, and the
  databases match.*

A third, diagnostic-only mode exists: **`folded`** runs an `-elabuhdm` test's
own flags minus `-elabuhdm` on both sides. It is not part of the target — it
exists to order the work (§4.3): folded-not-equal means fix the folded model
first; folded-equal but testflags-not-equal means an elab-frontier bug.

Done means `CMP_EQUAL` for every test in both modes, except where slang
legitimately rejects the source (see §2.5).

**Why two modes.** One alone is not a claim. `default` alone would let a flag
bug hide; `testflags` alone would let a model bug hide behind a flag we happen
to drop. Passing both is the only concrete way to say "equal to golden".

---

## 2. Decisions

### 2.1 slang-uhdm implements UHDM-relevant flags only

slang-uhdm is a UHDM emitter built on slang, **not** a Surelog clone. So:

- **General compiler flags are slang's job.** `-I`, `-D`, `-y`, `-v`, `-L`,
  `--libmap`, `--top`, `-G`, `--timescale`, `-f`/`-F`, `+incdir+`, `+define+`,
  `+libext+` — all already present and all verified working (§4.1).
- **UHDM-relevant flags are ours.** Anything that changes the emitted database
  must exist in slang-uhdm: `--elabuhdm`, builtins/`--nobuiltin`, `--synth`/
  `--formal`, and the gaps in §3.2.
- **Surelog-only plumbing is nobody's.** Caching, threading, logging,
  preprocessor dumps, output paths, Python hooks, GC, EDA-compat shims. These
  are dropped **by the harness**, on the slang side only. Surelog still runs
  with its full command line.

### 2.2 The asymmetry lives in the harness, not in slang-uhdm

Surelog runs verbatim; slang-uhdm gets a filtered argv. This is deliberate: it
keeps the golden side untouched and confines all translation risk to one
reviewable table in `scripts/verify_golden.py`.

### 2.3 Never drop a UHDM-relevant flag silently

A flag that would change the database but is unimplemented classes the test
`UNTRANSLATABLE` and is **named in the CSV's `blocked_by` column**. Skipped
tests are never folded into a pass rate. A harness that quietly drops flags
manufactures a happy path and its numbers are worthless.

### 2.4 Compilation-unit mapping inverts

Surelog's default puts **all** files in one compilation unit; `-fileunit` gives
each file its own. slang is the opposite: per-file by default, `--single-unit`
to merge. So the harness adds `--single-unit` when Surelog does **not** say
`-fileunit`. Verified on a two-file case where file 2 uses a `$unit`-scope
typedef from file 1 (Surelog default 0 errors, `-fileunit` 1 error; slang
default errors, `--single-unit` clean). Irrelevant for single-source tests,
load-bearing for multi-file ones.

### 2.5 `SLANG_REJECT` is OUT OF SCOPE

slang is stricter than Surelog and rejects sources Surelog accepts leniently
(unimported package identifiers, assignment-pattern arity, `\`protected`
regions). **Patching slang is out of scope for this campaign.** We do not
loosen slang and we do not chase its diagnostics.

So `SLANG_REJECT` tests are excluded from the target: they are reported and
counted, but never part of the denominator. The scope of phase 2 is exactly the
**comparable** set — tests where BOTH tools produced a database — plus the
`UNTRANSLATABLE` set, which we unblock by implementing §3.2.

Practical consequence: the headline metric is `CMP_EQUAL / comparable`, not
`CMP_EQUAL / total`. Reporting against total would understate progress and
imply slang work we are not doing.

### 2.6 Builtins match Surelog's default — RESOLVED (`db83fc3`)

Surelog emits builtins **by default** and takes `-nobuiltin` to opt out. We were
originally the reverse (`--builtins` to opt in), which meant "default vs default"
was not literally default on both sides.

Now aligned: slang-uhdm emits builtins by default and `--nobuiltin` opts out,
spelled exactly as Surelog spells it. `--builtins` is kept as an accepted no-op
so invocations written against the earlier spelling keep working. `default` mode
therefore passes **no builtins flag on either side**.

**No name collision.** slang defines no `--builtins` of its own (0 hits in its
driver source, 0 in the upstream binary's help; the only adjacent option is
`--std`), so no rename was needed.

**Flipping the default required a lockstep change to the gate scripts.**
`converge.sh` and `check_goldens.sh` pass `-nobuiltin` to Surelog but were passing
nothing to us; without adding `--nobuiltin` there, every corpus test would have
regressed the moment the default flipped. Anything that changes a default must
sweep the harness for the places that relied on the old one.

## 3. Status

### 3.1 Landed

| Flag | Commit | What it does |
|---|---|---|
| `--elabuhdm` | `fc22485` | UHDM full elaboration: `ElaboratorContext` + `uniquifyTypespec(false)` + `listenDesigns`, then `UhdmAdjuster` — verbatim from Surelog's `UhdmWriter.cpp`. Both classes ship with UHDM, so this is reproduced, not reimplemented. |
| builtins (default on) | `5286421`, `db83fc3` | The `builtin` package (5 empty `class_defn`s) plus `work@mailbox`/`process`/`semaphore` from `share/builtin.sv`, Surelog's embedded string kept byte-for-byte because the UHDM spans depend on the exact text. slang parses it under the same reported path so spans match by construction. `db83fc3` flipped the default to ON with `--nobuiltin` to opt out, matching Surelog exactly; `--builtins` remains an accepted no-op. |
| `--synth` / `--formal` | `f5aed69` | Both halves were reuse. Filtering is UHDM's `SynthSubset`, called as Surelog calls it (`reportErrors=true`, `allowFormal` from `--formal`, `listenDesigns`, `filterNonSynthesizable()`) in the same pass-order slot. The `// pragma translate_off/on` half is slang's `--translate-off-format`, which `--synth` injects into `driver.options.translateOffOptions` before `processOptions()` so one flag implies both. |

The builtins work also closed real class-emission gaps: `ref` arg direction (was an
outright unsupported-exit), `io_decl` default-value exprs, untyped ANSI formals
taking no typespec, constructor `class_var` returns, static-method spans,
class-scope methods taking no `vpiInstance`, class typedef enums, and
`AllClasses` assembled name-sorted with builtin.sv's classes first.

Phase-1 result is unchanged and still gated: **488 PASS / 173 CMP_ONLY / 0
DIFF**, goldens 23/23.

### 3.2 Remaining UHDM-relevant gaps — traced to their implementation

Every remaining blocker was traced to the code that implements it, because that
decides whether we **reuse** a UHDM class (cheap, exact) or **reimplement**
Surelog behaviour in our exporter (costly, approximate).

| Surelog flag | Tests | Lives in | Route |
|---|---|---|---|
| `--disable-feature=parametersubstitution` | 4 | **Surelog** — `CompileExpression.cpp:96`, gates substituting assignment patterns into parameters. | Reimplement; small and localized. |
| `-bb_mod` / `-bb_inst` | 4 | **Surelog** — `CompileModule.cpp` + `DesignElaboration.cpp`. | Reimplement; needs a blackboxing concept in the exporter. Medium. |
| `-cfg` / `-cfgfile` | 2 | **Surelog** — `DesignElaboration.cpp` + `Config/ConfigSet` (Verilog `config` semantics). slang has `--libmap`/config support that may already cover it. | Investigate slang first, then decide. |
| `--disable-feature=letexprsubstitution` | 1 | **Surelog** — `CompileHelper.cpp:4257`, inlines `let` declarations. | Reimplement; small. |
| `-diffcompunit` | 1 | **Surelog** — harness behaviour (compiles both ways to diff), not a model option. | **Out of scope**; reclassify alongside `NO_DATABASE`. |
| `-pythonevalscript` / `...perfile` | 1 | **Surelog** — embedded Python that mutates the model (measured: 3755 dump lines). | **Out of scope.** |

`-synth`/`-formal` is **done** (§3.1) — it was 14 of the original 28 and the only
pure-reuse case. Of the 13 that remain, three small reimplementations cover 9,
one needs investigation (2), and two are out of scope (2).

**UHDM classes available to reuse.** `ElaboratorListener` and `UhdmAdjuster`
(both already used by `--elabuhdm`), `SynthSubset`, `UhdmLint`, `ExprEval`.

**`UhdmLint` needs no action — do not chase it.** Surelog runs it
*unconditionally*, on every write, and we never do. That looks like a gap but is
not: `UhdmLint.cpp` has 0 `Erase` calls, 0 `Make*` calls and no property
setters; every `Vpi*()` call in it is a getter. It only invokes the serializer's
error handler. It cannot change the database.

### 3.3 Measured baseline

Measured 2026-07-25 at `f5aed69` (builtins default-on, `--synth` implemented).
Per-test CSVs are committed: `results/golden_surelog.csv`,
`results/golden_uhdm2rtlil.csv`. Headline metric is `CMP_EQUAL / comparable` per
§2.5 (`comparable` = both tools produced a database; `SLANG_REJECT` is out of
scope). Neither mode passes a builtins flag any more — the defaults align.

**uhdm2rtlil, 731 tests**

| | default | testflags |
|---|---|---|
| CMP_EQUAL | 662 | 662 |
| CMP_NOTEQUAL | 16 | 17 |
| SLANG_REJECT (out of scope) | 51 | 50 |
| SURELOG_FAIL | 2 | 2 |
| **comparable** | **678** | **679** |
| **CMP_EQUAL / comparable** | **97.6%** | **97.5%** |

**Surelog suite, 794 tests**

| | default | testflags |
|---|---|---|
| CMP_EQUAL | 181 | 177 |
| CMP_NOTEQUAL | 301 | 290 |
| SLANG_REJECT (out of scope) | 286 | 283 |
| UNTRANSLATABLE | 0 | 13 |
| SURELOG_FAIL | 26 | 25 |
| NO_DATABASE | 0 | 3 |
| TIMEOUT / NO_UHDM | 0 | 3 |
| **comparable** | **482** | **467** |
| **CMP_EQUAL / comparable** | **37.6%** | **37.9%** |

Builtins took uhdm2rtlil `default` mode from **0 → 662**; before them, all 731
failed on the 510-line builtin block alone. Since `db83fc3` builtins are the
default on both sides, `default` mode passes no flag at all.

`UNTRANSLATABLE` fell 51 → 28 → **13**. First, the foreign simulator flags found
in `.sl` files were each measured against Surelog's dump and whitelisted: `+vcs+*`,
`+warn=`, `+lint=`, `+OVM_TESTNAME=`, `+v2k`, `-ast`, `-PP`, `-full64`,
`-notice`, `-line`, `-quiet`, `-Os`, `--assert`, `--trace`, `-output-split`,
`-CFLAGS <arg>`, `-pythonlistener` — all 0 dump-line change. These were the
harness refusing to compare tests it could have compared. `-pythonevalscript*`
looked equally harmless and is not: 3755 dump lines, so it stays blocked. Then
`--synth`/`--formal` (§3.1) unblocked the 14 `-synth` tests, which resolve to 5
`CMP_EQUAL`, 5 `CMP_NOTEQUAL`, 3 `SLANG_REJECT` (out of scope) and 1
`SURELOG_FAIL` — so `testflags` `CMP_EQUAL` rose 172 → 177.

The two modes differ in denominator because `testflags` legitimately excludes 16
tests before running (13 `UNTRANSLATABLE` + 3 `NO_DATABASE`) that `default` mode
still attempts. That is the whole explanation for `default` showing more
`SURELOG_FAIL` and `CMP_NOTEQUAL` — not a regression between modes.

**Work remaining.** 301 (default) / 290 (testflags) Surelog-suite tests and
16/17 uhdm2rtlil tests to converge, plus 13 `UNTRANSLATABLE` to unblock via
§3.2.

**Mode overlap (measured).** The two modes' `CMP_NOTEQUAL` sets are nearly the
same set: Surelog suite 286 shared / 15 default-only / 4 testflags-only;
uhdm2rtlil 16 shared / 1 testflags-only. So this is one convergence campaign,
not two, and a fix normally moves both columns. The small asymmetric slices are
themselves triage seeds:
  - default-only is mostly tests whose testflags row is excluded
    (`UNTRANSLATABLE` blackbox/feature flags) or `SLANG_REJECT`.
  - testflags-only splits into two concrete clusters: `-P`→`-G` parameter
    override divergence (`CmdLineOverride`, `DecValue`) and elab-only
    divergence on tests whose folded models already match (`ClogParam`,
    `UnsizedParam`).

**Folded vs elaborated (measured).** In testflags mode the Surelog suite is
mostly an **elaborated-model** comparison — 629 of its `.sl` files pass
`-elabuhdm`. Of the comparable testflags tests: elab 168/418 equal (40.2%),
folded 9/49 equal (18.4%). Phase 1 converged the folded model only, so the bulk
of testflags convergence is new territory: the elaborated tree that
`ElaboratorListener`/`UhdmAdjuster` produce from both sides. Two consequences:
  - The 49 folded testflags tests (40 not-equal) are home turf for the
    phase-1 sweep-and-cluster method — start there.
  - Elab-mode dump diffs are larger and shaped differently; expect to re-tune
    diff normalisation before clustering them.

**uhdm2rtlil not-equal identities.** All 17 are either the multi-file
`project.f` frontier (`iface_method_call`, `jeras_*`, `rp32_*`,
`load_and_derive`, `resolve_types`, `mriscv_bind_sva`, `r5p_gpr_cosim`), the
`dut.v` test `recursive_map`, or the rc=4 pair below. No phase-1 single-file
`dut.sv` test is not-equal — the phase-1 claim survives the new harness intact.

**Harness bugs found and fixed while establishing this baseline** — both had
inflated the failure counts, so earlier figures in this file's history are void:

- `default` mode passed only sources, stripping `-I`/`+incdir+`. Tests needing
  include paths then failed on BOTH sides, and comparing two failed compiles
  measures nothing. Fixed by keeping point-at-the-sources args (§1).
- `default` mode also dropped `-sv`/`-sverilog` from the **Surelog** side. That
  is a parse-mode switch, not a model-shaping one, and Surelog needs it: without
  it `SimpleClass1`'s `top.v` is 10 syntax errors and no database, because class
  syntax in a `.v` file is not Verilog-1995. slang needs no equivalent (it parses
  SystemVerilog unconditionally). Fixed as a Surelog-only passthrough; this alone
  corrected 8 tests that were mis-reported as `SURELOG_FAIL`.
- uhdm2rtlil discovery now adds `-sv` when any source is `.sv` and honours a
  `# lang:` directive, matching what `test/project_files.sh` really does.

### 3.4 Coverage corrections made in phase 2

Phase 1's numbers understated the work:

- `run_corpus.sh` hardcodes `dut.sv`, so it **skipped 24 of 734** uhdm2rtlil
  dirs (17 multi-source via `project.f`, 4 `dut.v`-only) and silently truncated
  `load_and_derive`/`resolve_types` to one of their two sources. Reading
  `project.f` takes discovery to **731**. The 3 remaining dirs have no sources.
- The old Surelog harness scanned only `tests/*/`, missing nested dirs and all
  90 `third_party/tests`, and skipped 53 dirs as "multifile". Walking for
  `*.sl` gives **794**.
- **The "0 DIFF" claim covers 710 single-file uhdm2rtlil tests**, not the
  multi-file ones. Those are a real, previously invisible frontier.

---

## 4. How to run the convergence

### 4.1 The harness

    scripts/verify_golden.py --corpus surelog|uhdm2rtlil
                             --mode default|testflags|folded|both|all
                             --out <csv> [--workdir <dir>]
                             [--jobs N] [--timeout S] [--filter <regex>]

`both` = default+testflags (the target modes); `all` adds the `folded`
diagnostic overlay; `folded` alone emits rows only for `-elabuhdm` tests.

There is no builtins flag: the two tools' defaults agree (§2.6).

Output CSV columns: `name,mode,status,detail,blocked_by`.
Statuses: `CMP_EQUAL`, `CMP_NOTEQUAL`, `SLANG_REJECT`, `SURELOG_FAIL`,
`NO_UHDM`, `UNTRANSLATABLE`, `NO_DATABASE`, `TIMEOUT`.

Full sweeps (long; run detached):

    SP=<scratchpad>
    setsid nohup python3 scripts/verify_golden.py --corpus surelog \
      --mode both --out $SP/sl.csv --workdir $SP/sls \
      --jobs 3 --timeout 240 > $SP/sl.log 2>&1 < /dev/null &

One test, both modes, to inspect a single divergence:

    python3 scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/one.csv --workdir /tmp/onew --filter '^ParamCast$'

Then read `/tmp/onew/<mode>/<name>/cmds.txt` for the **exact** two command
lines used, and diff the dumps:

    D=~/git-repos/UHDM/build/bin/uhdm-dump
    W=/tmp/onew/testflags/ParamCast
    diff <($D $W/slpp_all/surelog.uhdm | tail -n +2) \
         <($D $W/slang.uhdm            | tail -n +2)

Changed-line metric is `grep -c '^[-+]'` minus 2 — **not** `wc -l`, which
counts context lines.

### 4.2 Gates (unchanged from PLAYBOOK.md — these still bind)

Every change must clear, in the **main tree**:

1. `bash tests/check_goldens.sh 2>&1 | grep -c '^PASS'` == **23**
2. Corpus unchanged or improved:

       JOBS=3 timeout 900 ./scripts/run_corpus.sh ~/git-repos/uhdm2rtlil/test \
         results/<tag>.csv results/baseline_auto.csv

   Wait for **711 lines** before diffing; a short CSV yields bogus movers.
3. Movers reviewed one by one:

       diff <(sort results/baseline_auto.csv | cut -d, -f1,2) \
            <(sort results/<tag>.csv        | cut -d, -f1,2) | grep '^[<>]'

   No PASS→anything demotions. No CMP_ONLY→DIFF.
4. After committing: `cp results/<tag>.csv results/baseline_auto.csv`

Phase-2 additions:

5. No `CMP_EQUAL` → anything regressions in either corpus, either mode.
6. A test moving into `UNTRANSLATABLE` is a **regression**, not a neutral
   result — it means the harness stopped being able to compare it.

Cadence: gates 1–4 (goldens + uhdm2rtlil corpus, ~15 min) run per commit.
Gates 5–6 need a full two-mode sweep (~45–60 min per corpus) — run per wave and
before any baseline refresh, then commit the refreshed
`results/golden_*.csv` alongside, as step 4 does for `baseline_auto.csv`.

### 4.3 Working method

Unchanged from PLAYBOOK.md: sweep-and-cluster. Converge many failures into one
scratch dir, normalise each diff (digits → N, `(names)` → `(X)`), group by first
divergence. Shared rules surface as families; families are what make a single
fix worth many tests. Marker sweeps (append a unique suffix at every candidate
emission site, rebuild once, grep the dump) locate which site emits an object —
but beware later code overwriting the marked field.

For phase 2 specifically: **fix the folded model first, then the elab-only
residue.** Both tools now derive their elab output by running the same UHDM
library passes (`ElaboratorListener` + `UhdmAdjuster`) over their own folded
models, so folded divergences propagate downstream and folded fixes shrink elab
diffs for free. The reverse is not true. Concretely:

1. **Folded divergences** — `default`-mode failures, the folded-only testflags
   tests, and `folded`-mode failures of `-elabuhdm` tests. All are phase-1
   home turf; the sweep-and-cluster method applies unchanged.
2. **Flag-handling divergences** — failing `testflags` (or `folded`) while
   passing `default`: the flag translation or a flag implementation is wrong,
   not the emitter (e.g. the `-P`→`-G` cluster).
3. **Elab-only divergences** — folded-equal but testflags-not-equal (e.g.
   `ClogParam`, `UnsizedParam`). Decode these against the elaborated tree;
   expect aliasing/`UhdmAdjuster` effects that dumps may not show. Start after
   the folded queue is drained, from the smallest reproducers.
4. **Skip `SLANG_REJECT` entirely** (§2.5) — out of scope, not a work item.
5. **`UNTRANSLATABLE` by implementing §3.2**, largest bucket first.

### 4.4 Agent-ops rules (learned the hard way)

- Worktree agents **must** `export SLANG_UHDM=$PWD/build/slang-uhdm`.
- **Never `git stash`** — the stack is shared across worktrees.
- **Never truncate `git apply` output.** One failed file rolls the *whole*
  patch back, and you then measure an unchanged tree believing it changed.
- Agent baselines are **often stale**. Require every agent to build its own
  true HEAD baseline (revert, build, run) before claiming "no regressions" —
  and re-gate in the main tree regardless. Only main-tree gates count.
- **Inspect agent patches for collateral.** The `--builtins` patch arrived
  carrying overwrites of `results/*.csv` from the agent's own corpus runs;
  those were reverted before commit.
- Rebuilding the main-tree binary **corrupts any sweep in flight** — sweeps
  invoke `build/slang-uhdm`. Check `pgrep -f verify_golden.py` first.

---

## 5. Open questions

1. ~~Flip the builtins default?~~ **RESOLVED** (`db83fc3`): builtins are on by
   default with `--nobuiltin` to opt out, matching Surelog. `default` mode now
   passes no flag on either side.
2. **Is `-cfg` covered by slang's `--libmap` config handling?** Unverified.
2b. **When Surelog errors but still writes a database, is that database a
   golden?** Two uhdm2rtlil tests (`asgn_expr_sv`, `typedef_param`) make Surelog
   print compile errors and exit nonzero (rc=4) — yet it still writes a full
   `surelog.uhdm`. Our two harnesses currently disagree on what that means:
   `converge.sh` looks at the exit code, calls it `SURELOG_FAIL`, and skips the
   test; `verify_golden.py` looks for the `.uhdm` file, finds it, compares, and
   reports not-equal. Same test, one harness says "skipped", the other says
   "failing". The decision needed: treat an errored-but-written database as a
   valid golden (compare it) or not (skip it)? Recommendation: compare — Surelog
   itself ships these tests with the errors recorded in their golden logs, i.e.
   upstream treats the output as the expected result. Once decided, make
   `converge.sh` agree; note this reopens phase 1's count by 2 (they were always
   divergent, just hidden behind the rc check).
2c. ~~Is byte-identity still the end state?~~ **RESOLVED**: `CMP_EQUAL` is the
   phase-2 bar; byte identity (a `DUMP_MATCH` column in `verify_golden.py`) is
   phase 3, after both corpora are cmp-equal in both modes.
3. **Does `$RV_ROOT`-style variable expansion in `-f` files work?** slang's `-f`
   reads the flist but does not appear to expand the variable (`CoresSweRV`:
   "'/design/swerv_wrapper.sv': No such file or directory"). Affects 2 tests.
4. **Elab-mode byte convergence.** `--elabuhdm` is cmp-equal on sampled tests
   but leaves ~86–96 dump-line differences. Untouched territory.
