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
  must exist in slang-uhdm: `--elabuhdm`, `--builtins`, and the gaps in §3.2.
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

### 2.5 `SLANG_REJECT` is a real bucket, not an excuse

slang is stricter than Surelog and legitimately rejects sources Surelog accepts
leniently (unimported package identifiers, assignment-pattern arity). Those
tests cannot be compared — but they must stay **visible and counted**, because
some are genuine slang-side gaps worth fixing and only inspection tells which.

### 2.6 Builtins: our default differs from Surelog's — OPEN DECISION

Surelog emits builtins **by default** and takes `-nobuiltin` to opt out.
slang-uhdm is the reverse: no builtins by default, `--builtins` to opt in.

Consequence: "default vs default" is not literally default on both sides — the
harness must pass `--builtins` for `default` mode to mean anything.

Recommendation, **not yet applied**: flip slang-uhdm to match Surelog (builtins
on by default, add `--nobuiltin` to opt out). Then `default` mode needs no flag
at all and the word "default" is honest. Deferred because flipping a default is
a user-visible behaviour change. See §5 question 1.

---

## 3. Status

### 3.1 Landed

| Flag | Commit | What it does |
|---|---|---|
| `--elabuhdm` | `fc22485` | UHDM full elaboration: `ElaboratorContext` + `uniquifyTypespec(false)` + `listenDesigns`, then `UhdmAdjuster` — verbatim from Surelog's `UhdmWriter.cpp`. Both classes ship with UHDM, so this is reproduced, not reimplemented. |
| `--builtins` | `5286421` | The `builtin` package (5 empty `class_defn`s) plus `work@mailbox`/`process`/`semaphore` from `share/builtin.sv`, Surelog's embedded string kept byte-for-byte because the UHDM spans depend on the exact text. slang parses it under the same reported path so spans match by construction. |

`--builtins` also closed real class-emission gaps: `ref` arg direction (was an
outright unsupported-exit), `io_decl` default-value exprs, untyped ANSI formals
taking no typespec, constructor `class_var` returns, static-method spans,
class-scope methods taking no `vpiInstance`, class typedef enums, and
`AllClasses` assembled name-sorted with builtin.sv's classes first.

Phase-1 result is unchanged and still gated: **488 PASS / 173 CMP_ONLY / 0
DIFF**, goldens 23/23.

### 3.2 Remaining UHDM-relevant gaps in slang-uhdm

| Surelog flag | Tests | What it does | Route |
|---|---|---|---|
| `-synth` / `-formal` | 14 | Two effects. (a) Honours `// pragma translate_off/on` — **already available**: slang's `--translate-off-format pragma,translate_off,translate_on` reproduces it exactly (verified: both tools 13 → 0 occurrences). (b) Prunes net `ref_typespec`/`logic_typespec` (81 dump lines on `ParamArraySelect`) — **exporter work needed**. | (a) harness mapping, (b) exporter |
| `-cfg` / `-cfgfile` | 4 | Selects a Verilog `config` block. slang accepts `--libmap`; whether its config handling matches is **unverified**. | investigate |
| `-bb_mod` / `-bb_inst` | 4 | Blackboxes a known module/instance. `--ignore-unknown-modules` is *not* equivalent (missing ≠ blackboxed). | exporter/driver |
| `--disable-feature=parametersubstitution` | 4 | Disables assignment-pattern substitution in parameters. | exporter |
| `--disable-feature=letexprsubstitution` | 1 | Disables let-expression inlining. | exporter |

### 3.3 Measured baseline

**uhdm2rtlil, 731 tests** (`--builtins` on):

| | default | testflags |
|---|---|---|
| CMP_EQUAL | 662 | 662 |
| CMP_NOTEQUAL | 16 | 17 |
| SLANG_REJECT | 51 | 50 |
| SURELOG_FAIL | 2 | 2 |

`--builtins` took `default` mode from **0 → 662**; before it, all 731 failed on
the 510-line builtin block alone.

**Surelog suite, 794 tests** (`--builtins` on, sources-only `default`):

| | default | testflags |
|---|---|---|
| CMP_EQUAL | 182 | 170 |
| CMP_NOTEQUAL | 290 | 279 |
| SLANG_REJECT | 291 | 267 |
| UNTRANSLATABLE | 0 | 51 |
| SURELOG_FAIL | 31 | 22 |
| NO_DATABASE | 0 | 3 |
| TIMEOUT / NO_UHDM | 1 | 2 |

Caveat on that table: it was measured with `default` mode passing **only**
sources, which strips `-I`/`+incdir+` and makes tests that need include paths
fail on both sides (hence `SURELOG_FAIL` 31 > 22 — garbage-in, not a finding).
§2.1's location-args refinement fixes this; numbers are being re-measured.

**Where the mass is.** On the Surelog suite the two big buckets are
`SLANG_REJECT` (~35%) and `CMP_NOTEQUAL` (~35%) — roughly equal. So phase 2 is
*two* campaigns: making slang accept more real-world SV, and converging the
model. On uhdm2rtlil only ~67 tests remain, mostly the multi-file designs that
phase 1 never looked at.

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
                             --mode default|testflags|both
                             --builtins
                             --out <csv> [--workdir <dir>]
                             [--jobs N] [--timeout S] [--filter <regex>]

Output CSV columns: `name,mode,status,detail,blocked_by`.
Statuses: `CMP_EQUAL`, `CMP_NOTEQUAL`, `SLANG_REJECT`, `SURELOG_FAIL`,
`NO_UHDM`, `UNTRANSLATABLE`, `NO_DATABASE`, `TIMEOUT`.

Full sweeps (long; run detached):

    SP=<scratchpad>
    setsid nohup python3 scripts/verify_golden.py --corpus surelog \
      --mode both --builtins --out $SP/sl.csv --workdir $SP/sls \
      --jobs 3 --timeout 240 > $SP/sl.log 2>&1 < /dev/null &

One test, both modes, to inspect a single divergence:

    python3 scripts/verify_golden.py --corpus surelog --mode both --builtins \
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

### 4.3 Working method

Unchanged from PLAYBOOK.md: sweep-and-cluster. Converge many failures into one
scratch dir, normalise each diff (digits → N, `(names)` → `(X)`), group by first
divergence. Shared rules surface as families; families are what make a single
fix worth many tests. Marker sweeps (append a unique suffix at every candidate
emission site, rebuild once, grep the dump) locate which site emits an object —
but beware later code overwriting the marked field.

For phase 2 specifically, triage in this order:

1. **`default`-mode failures first.** They are model bugs with no flag
   involvement — the cleanest signal available.
2. **Then `testflags`-only failures.** A test failing `testflags` but passing
   `default` isolates the bug to flag handling.
3. **`SLANG_REJECT` separately.** Read the diagnostic; decide slang gap vs
   Surelog leniency. Do not fix by loosening slang blindly.
4. **`UNTRANSLATABLE` by implementing §3.2**, largest bucket first.

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

1. **Flip the builtins default?** (§2.6) Recommend yes: builtins on by default
   plus `--nobuiltin`, so `default` mode needs no flags. Needs sign-off — it
   changes observable behaviour for existing users.
2. **Is `-cfg` covered by slang's `--libmap` config handling?** Unverified.
3. **Are the 291 `SLANG_REJECT` tests slang gaps or Surelog leniency?**
   Unsampled. This is ~35% of the Surelog suite and the single largest unknown.
4. **Elab-mode byte convergence.** `--elabuhdm` is cmp-equal on sampled tests
   but leaves ~86–96 dump-line differences. Untouched territory.
