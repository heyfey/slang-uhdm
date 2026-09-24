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

Done means `CMP_EQUAL` for every **comparable** test in both modes (§2.5;
extending slang is out of scope, so `SLANG_REJECT` is excluded by decision).

Converge order (decided): **uhdm2rtlil default → uhdm2rtlil testflags →
Surelog default → Surelog testflags.** The first two stages are **COMPLETE**
as of `b16eb6f` (2026-07-27): uhdm2rtlil is at 100.0% comparable-equal in
both modes (679/679; the 50 SLANG_REJECT + 2 SURELOG_FAIL are the decided
exclusions). All remaining convergence work is the Surelog suite. The stages mostly contain each other:
the u2r mode pair shares 16 of its 16/17 failures, the Surelog mode pair 286
of 301/290 — and since `default` strips `-elabuhdm`, converging Surelog
default IS the folded-first strategy, with only 2 elab-only tests left for
testflags. The §3.2 flag implementations are **in-phase**, scheduled inside
the Surelog-testflags stage (they only affect tests running those flags).

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

### 2.5b Five memory-giant tests are DEFERRED to a late phase

User decision 2026-07-27: `Earlgrey_nexysvideo`, `Earlgrey_Verilator_01_05_21`,
`Rsd`, `Xgate`, `YosysSmallBoom` emit status `DEFERRED` and run neither tool.
Their golden generation OOMs or times out on this machine; failures are
uncacheable by design, so every sweep re-ran them to the timeout — ~25 min of
a ~35 min both-modes sweep, the dominant cost after the golden cache landed —
and their rows were being hand-pinned every refresh anyway. They are excluded
from the comparable denominator like `SLANG_REJECT`. Revisit on capable
hardware with `GOLDEN_DEFER=0` (the harness knob) in the late phase, together
with the byte-identity (`DUMP_MATCH`) work.

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
`converge.sh` and the (since removed) `check_goldens.sh` passed `-nobuiltin` to Surelog but were passing
nothing to us; without adding `--nobuiltin` there, every corpus test would have
regressed the moment the default flipped. Anything that changes a default must
sweep the harness for the places that relied on the old one.

### 2.7 The golden side gets `-noprecompiledcache` when a source is named `uvm_pkg.sv`/`ovm_pkg.sv` — RESOLVED (this block)

Surelog **substitutes its own bundled UVM/OVM** for any source file whose LEAF
NAME is `uvm_pkg.sv` or `ovm_pkg.sv`. `Package/Precompiled.cpp` registers
exactly those two names in its constructor and `isFilePrecompiled` keys on the
leaf alone — no path, no content hash. A file that matches is served from
`<surelog-install>/pkg/work/<leaf>.slpp`, which was built from the UVM that
ships in the Surelog **build tree** (`build/bin/1800.2-2017-1.0/src`).

So the golden for every UVM test described a **different source text** than the
one the test named on its command line. Measured on `Scoreboard`, which
compiles `third_party/UVM/uvm-1.2`:

| | golden (precompiled) | uvm-1.2 sources | slang-uhdm |
|---|---|---|---|
| `uvm_pkg` parameters | 41 | 45 | 45 |
| first parameter | `UVM_HDL_MAX_WIDTH` @ `dpi/uvm_hdl.svh:54` | @ `dpi/uvm_hdl.svh:47` | @ `:47` |
| version parameter | `UVM_VERSION_STRING` | `uvm_mgc_copyright` … `uvm_revision` | same |

Re-run Surelog with `-noprecompiledcache` and its 45 `uvm_pkg` parameters match
slang-uhdm's 45 **name-for-name and line-for-line**, in order. The 4-parameter
gap and every name difference above it were the version substitution, not the
emitter.

This is not a model difference we could ever emit, and it is not even stable:
it makes the golden depend on the Surelog build tree rather than on the test —
the same class of environment leak as `-mt`/`-mp`, which the harness already
pins to 0 on the golden side (§2.2's "verbatim" has always had a
determinism carve-out). So `verify_golden.py` now prepends
`-noprecompiledcache` to the **Surelog** argv in all three modes, and **only**
when an argument's leaf name is one of the two precompiled names
(`precompiled_guard`). The guard is deliberately narrow: the golden-cache key
is the Surelog argv, so a blanket flag would invalidate every cached golden in
both corpora, while this touches exactly the 21 Surelog tests that name one of
those files (0 in uhdm2rtlil, and 0 tests reach the names through an `-f` file).

Reach: 21 tests, of which 4 are **comparable** and all 4 were `CMP_NOTEQUAL` —
`BuildUVMPkg`, `SeqDriver`, `SimpleUVM` (both modes) and `Scoreboard`
(`default`; its `testflags` row is `SLANG_REJECT`, §2.5). The change converts
nothing on its own; it makes those 7 rows measure the emitter instead of a
version mismatch. Note `-noprecompiledcache` also appears in
`IRRELEVANT_NOARG`: dropping it from the **slang** side is right (slang has no
such cache) and that entry is unrelated to this guard.

Gate (this block, vs the committed baselines): **zero status changes**, all 14
`mode/status` tallies identical, `SLANG_REJECT` membership unchanged, u2r
testflags byte-identical to `results/gate_uhdm2rtlil.csv`. The only two rows
that move at all are `CoresSweRV`/`CoresSweRVMP` `default`, whose
`SURELOG_FAIL` detail goes `[   NOTE] : 0` -> `[   NOTE] : 1`: both name
`third_party/UVM/1800.2-2017-1.0/src/uvm_pkg.sv`, i.e. the SAME version the
precompiled cache held, so the guard changes no model for them — it only makes
Surelog actually compile those sources, which costs one extra NOTE and about a
minute of golden-generation time each. Cost of the guard overall is a one-time
regeneration of 21 goldens (~15 min of a sweep, dominated by the `uhdm-dump`
that computes each golden's `DUMP_MATCH` hash on an 11 MB database).

## 3. Status

### 3.1 Landed

| Flag | Commit | What it does |
|---|---|---|
| `--elabuhdm` | `fc22485` | UHDM full elaboration: `ElaboratorContext` + `uniquifyTypespec(false)` + `listenDesigns`, then `UhdmAdjuster` — verbatim from Surelog's `UhdmWriter.cpp`. Both classes ship with UHDM, so this is reproduced, not reimplemented. |
| builtins (default on) | `5286421`, `db83fc3` | The `builtin` package (5 empty `class_defn`s) plus `work@mailbox`/`process`/`semaphore` from `share/builtin.sv`, Surelog's embedded string kept byte-for-byte because the UHDM spans depend on the exact text. slang parses it under the same reported path so spans match by construction. `db83fc3` flipped the default to ON with `--nobuiltin` to opt out, matching Surelog exactly; `--builtins` remains an accepted no-op. |
| `-bb_mod` / `-bb_inst` | this block | Blackboxing, reimplemented from Surelog's own two early returns: `CompileModule.cpp` returns before **any** `collectModuleObjects_` pass when the def name is in `-bb_mod`, the def name is in `-bb_inst`, or the compiling instance's full path is in `-bb_inst`; `DesignElaboration::elaborateInstance_` creates no sub-instances under the same predicate. In the exporter that is one predicate (`blackboxedDef` / `blackboxedInst`, both no-ops when neither flag was given) and four early returns — `emitModuleDef` / `emitInterfaceDef` after the header, `emitInstance` after the header, and `emitGenScopes`' `emitBlock` after the `gen_scope_array`/`gen_scope` pair. The def-name case of the `-bb_inst` test is why `-bb_inst work@top` and `-bb_mod work@top` produce byte-identical databases. Names are matched verbatim in Surelog's `work@<name>` / `work@top.u1[i]` spelling, so slang-uhdm's own `VpiFullName` is the key with no translation. |
| `--disable-feature=parametersubstitution` | this block | Surelog gates ONE function on the feature: `CompileHelper::substituteAssignedValue` (`CompileExpression.cpp:83`) answers false when the candidate `param_assign` Rhs tree holds a `vpiAssignmentPatternOp` or `vpiConcatOp`, and its ~14 callers all read it as "may I replace this reference by the parameter's value?". Everything else the flag appears to do is downstream: an expression reading an un-inlinable parameter no longer folds, so the parameter IT initializes has no value either (`NoParamSubs`: `X='{0,1}` refused → `.P(~X)` stays an operation → `assign a = P` keeps its `ref_obj`). In the exporter that is three predicates (`paramSubstRefused` / `paramValueUnavailable` / `exprValueUnavailable`, all `false` when the flag is absent) plus one early branch in `emitParameters` that emits the un-reduced expression, one in `ExprEmit`'s package-param case, and one that suppresses the cont-assign folds. The `expandPatternAssignment` boundary is what makes an AGGREGATE-typed pattern parameter unchanged by the flag (measured byte-identical on both `init_val` and `CTRL_RESET`) while a packed-VECTOR one stops collapsing to a constant. Spelled exactly as Surelog spells it, comma list included; `--enable-feature=` is accepted the same way, and an unimplemented feature name is a hard error, never a silent no-op. |
| `--disable-feature=letexprsubstitution` | this block | Surelog gates ONE function on the feature, `CompileHelper::compileTfCall` (`CompileHelper.cpp:4257`): with substitution ON a `let` call is replaced by the declaration's body, with it OFF it becomes a `let_expr` carrying `Arguments` (the actuals) and `Let_decl`. Two facts came out of the with/without-flag golden PAIR and not from the corpus. First, the `let_decl` objects themselves exist in **both** modes (Surelog's `compileLetDeclaration` is unconditional and `UhdmWriter` lists the same objects on the def and every elab view, `UhdmWriter.cpp:1415`/`1639`), and the `Let_decls` vector is **name**-sorted, not source-sorted, because Surelog holds lets in a `std::map<std::string, LetStmt*>` (`DesignComponent.h:101`) — getting that wrong is a first-fail on the very first pair. Second, "inlining" is **pointer reuse, not substitution**: the gated branch returns `cts->Rhs((expr*)stmt->Expr())`, the declaration's own body object, so every call of a let IS the let_decl's body with the formals left as bare `ref_obj x` — the actuals never appear. slang has no call node to gate (`AssertionInstanceExpression::fromLookup` expands a `let` in place), but `Expression::create` deliberately refuses to overwrite the syntax pointer for `InvocationExpression` (`Expression.cpp:872-881`, "for cases like let decls that get expanded in place"), so an expansion is identified by its syntax being the let's BODY. The call syntax is NOT recoverable — `create`'s ordinary NameSyntax path does do the overwrite, so a substituted actual is re-anchored onto the FORMAL's identifier — and that re-anchoring is exactly what finds the actuals for `Arguments`. Both sides of the pair are cmp-equal on a purpose-built 3-let source (`sum2(x,y)`, `dbl(x)`, self-referential `id(x)=x`) across cont_assigns, an `always_comb`, and a let nested in another let's body. Residue, measured, ranked, zero corpus reach: a LITERAL actual (`sum2(a, 4'd3)`) renders with the formal's source text because the constant case reads spelling out of the source, and a formal the body never references is missing from `Arguments`. |
| `-cfg` / `-cfgfile` | this block | Verilog `config` selection (LRM 33), and the one §3.2 entry that turned out to be **pure plumbing**: slang implements config blocks natively (`ConfigBlockSymbol` — design statement, default liblist, cell/instance overrides, `use lib.cfg:config` recursion), so nothing was reimplemented. `-cfgfile <file>` is `sourceLoader.addFiles` — Surelog parses config files with a dedicated parser, slang parses `config...endconfig` as ordinary source, and a `-cfgfile` config lands in the default library exactly as Surelog's `work@<cfg>`. `-cfg <name>` becomes a top-level entry `<name>:config`; the suffix is load-bearing, because slang searches the definition map **before** the config map (`Compilation.cpp:423`) while Surelog's `setupConfigurations_` searches `ConfigSet` alone — `UnitLibrary` passes `-cfg top` while also declaring a module named `top`. An **unmatched** `-cfg` name is dropped with a warning instead of being handed to slang: Surelog treats it as non-fatal (`CM0028`, and it still writes the database) where slang's `InvalidTopModule` is fatal. Verified on a purpose-built with/without-`-cfg` golden PAIR (two candidate tops, config naming one): the two goldens differ and slang-uhdm is cmp-equal to **both**. |
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
| `-diffcompunit` | 1 | **Surelog** — harness behaviour (compiles both ways to diff), not a model option. | **Out of scope**; reclassify alongside `NO_DATABASE`. |
| `-pythonevalscript` / `...perfile` | 1 | **Surelog** — embedded Python that mutates the model (measured: 3755 dump lines). | **Out of scope.** |

`-synth`/`-formal` is **done** (§3.1) — it was 14 of the original 28 and the only
pure-reuse case. `-bb_mod`/`-bb_inst` is **done** too (§3.1), the first
reimplementation: 4 tests, all 4 `CMP_EQUAL`, 3 of them byte-identical
(`dump=match`). `--disable-feature=parametersubstitution` is **done** (§3.1):
4 tests unblocked, 3 to `CMP_EQUAL` and `BlackParrotMuteErrors` to
`SLANG_REJECT` (its `default` row already reads the same — an unimported
`lc_ctrl_pkg`, §2.5, so it was never reachable). `-cfg`/`-cfgfile` is **done**
(§3.1) and was the investigate-first entry: slang already implements config
blocks, so it is plumbing, and both tests reclassify `UNTRANSLATABLE` →
`SLANG_REJECT` — `LibraryIntercon` on a nettype used as an ANSI port data type
(`output realNet [0:1] out`, reproduced in 6 lines with no config or library
involved) plus `interconnect` net strictness; `UnitLibrary` on a same-library
module redefinition and on relative `instance` paths inside a nested config
(`instance sub2 liblist libw2;` in `libwconfig/libw.cfg`, where slang requires
the path to start at a cell named in the `design` statement). Both are §2.5
source strictness, unreachable through flag work.
`--disable-feature=letexprsubstitution` is **done** (§3.1) and was the last
in-scope entry in this table: `LetExpr` reclassifies `UNTRANSLATABLE` →
`SLANG_REJECT`, matching both of its own sibling rows — `let p2(x) =
$past(x,,,@(posedge clock));` over a `clock` port that the test leaves
commented out, which slang rejects and Surelog accepts, so it was never
reachable (its `default` row and both `LetInlined` rows already read the same
error). The flag itself is pair-proven in both directions and cost 0
regressions. **Everything left in this table is out of scope (2 tests), so the
flag-implementation track is closed:** no remaining Surelog flag changes the
model in a way slang-uhdm could reproduce.

**Ranked residue — library-qualified naming (0 tests today).** Surelog
qualifies every design name with its source library (`rtlLib@m`,
`logicLib@top.driverArray[0]`); slang-uhdm hardcodes `work@` at ~24 sites. The
gap is measured — a 3-file `-map` reproducer is cmp-unequal on exactly
`vpiDefName rtlLib@m` vs `work@m` and nothing else — and the fix is mechanical:
slang's `DefinitionSymbol::sourceLibrary` names the library and its default is
literally `"work"` (`Compilation.cpp:142`), so a `qualName(def)` helper would be
a hard no-op wherever no library map is in play. It is **not** worth doing yet:
the only two suite tests that pass `-map` are both `SLANG_REJECT`, so it buys
zero tests while touching every name the emitter writes.

**UHDM classes available to reuse.** `ElaboratorListener` and `UhdmAdjuster`
(both already used by `--elabuhdm`), `SynthSubset`, `UhdmLint`, `ExprEval`.

**`UhdmLint` needs no action — do not chase it.** Surelog runs it
*unconditionally*, on every write, and we never do. That looks like a gap but is
not: `UhdmLint.cpp` has 0 `Erase` calls, 0 `Make*` calls and no property
setters; every `Vpi*()` call in it is a getter. It only invokes the serializer's
error handler. It cannot change the database.

### 3.3 Measured baseline — GENERATED, do not hand-edit numbers

> Regenerated 2026-09-23 (the v1.87 pass-115 landing: ibex_pmp and ibex_icache
> converted in both uhdm2rtlil modes). For the live state and how to carry
> the campaign on, read **RESUME.md** and run `scripts/resume_survey.sh`.

The authoritative numbers come from the committed per-test CSVs via
`python3 scripts/accounting.py` (`--md` for this table). Prose and commit
messages are narrative; when they disagree with this table, the table wins —
a hand-arithmetic drift of +2 in two block-2 commit messages is why this rule
exists.

| Corpus | Mode | Total | Status breakdown | Comparable | Equal |
|---|---|---|---|---|---|
| Surelog suite | default | 798 | CMP_EQUAL=480 SLANG_REJECT=285 SURELOG_FAIL=25 DEFERRED=5 CMP_NOTEQUAL=3 | 483 | 480 (99.4%) |
| Surelog suite | testflags | 798 | CMP_EQUAL=474 SLANG_REJECT=286 SURELOG_FAIL=23 DEFERRED=5 NO_DATABASE=3 CMP_NOTEQUAL=3 UNTRANSLATABLE=2 TIMEOUT=1 NO_UHDM=1 | 477 | 474 (99.4%) |
| uhdm2rtlil | default | 871 | CMP_EQUAL=803 SLANG_REJECT=67 CMP_NOTEQUAL=1 | 804 | 803 (99.9%) |
| uhdm2rtlil | testflags | 871 | CMP_EQUAL=803 SLANG_REJECT=67 CMP_NOTEQUAL=1 | 804 | 803 (99.9%) |

Denominator accounting (every excluded test is one of): `SLANG_REJECT`
(out of scope, §2.5), `DEFERRED` (5 memory giants, §2.5b), `UNTRANSLATABLE`
(unimplemented UHDM-relevant flags, §3.2, testflags only), `SURELOG_FAIL` /
`NO_DATABASE` / `NO_UHDM` / `TIMEOUT` (golden side absent). Within
`CMP_NOTEQUAL`, the four slang-fenced tests (out of scope) account for 8 of the
row-modes; the rest are on active head chains (the old "documented-unreachable
BuildUVMPkg/SeqDriver/SimpleUVM PPCache" claim is OBSOLETE since 2026-08-16 —
r10uvm83 brought the UVM container wall from 1.45M cmp lines to 54; see RESUME.md).

Byte identity (`dump=match`) is tracked on `CMP_EQUAL` rows only (phase-3
metric; not-equal rows deliberately skip the dump).

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

**Golden cache.** The golden side is immutable (pinned Surelog binary, pinned
sources), so the harness caches each test's Surelog database + dump hash under
`~/.cache/slang-uhdm-goldens`, keyed by Surelog binary identity + test dir +
argv. A warm sweep runs NO Surelog and dumps NO goldens — only the slang side
executes. Before this, every sweep by every agent, verifier, and gate re-ran
all 731/794 Surelog compiles to regenerate identical goldens; tens of
thousands of redundant compiles per wave-cycle. The cache is shared across
worktrees (atomic writes), so agent sweeps warm each other. `GOLDEN_CACHE=0`
disables it; a Surelog rebuild auto-invalidates (identity key). TIMEOUT
results are never cached.

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

### 4.2 Gates

**One harness.** `verify_golden.py` is the single classification engine. The
rc=4 episode (§5 2b) is why: two harnesses with independent policies did not
merely duplicate effort, they *contradicted* — one scoreboard said "skipped",
the other said "failing", for the same test. The division of labour now:

| Tool | Role |
|---|---|
| `scripts/verify_golden.py` | THE harness: classification, both corpora, all modes, the `strict` column (uhdm-strictcmp; the `dump` column until 2026-09-24) |
| `tools/uhdm-strictcmp` | uhdm-cmp's own Compare first (so nothing it rejects can pass), then every judge-blind field per object in walk order: name, def name, full name, file basename, spans, decompile, size, value, const type, child order |
| `tests/sweep.sh` | the gate: both corpora, both modes, every row's status against the committed scoreboards (`scripts/compare_results.py`) |
| `scripts/converge.sh` | single-test dev microscope; produces `dump.diff` for inspection; same artifact policy |
| `scripts/run_corpus.sh` | **deprecated** — kept only to reproduce phase-1 CSVs |

**Since 2026-09-24 the sixth column is `strict`**: `equal` when uhdm-strictcmp
finds no judge-blind difference, else `differ:<first field>(<objects>)`; it
supersedes the dump-text identity below and is the intended equality of the
gate once the corpus reaches zero strict differences (measured at the switch:
surelog 471 of 954 CMP_EQUAL row-modes strict-equal, uhdm2rtlil 1026 of 1606,
probe cases 1117 of 2833; the first field is `file` on most default-mode rows
because Surelog stamps builtin.sv on the builtin classes).

**Typespec identity is canonicalised, and is the one explicit residue of the
strict contract.** Surelog clones every typespec it reaches during
elaboration (`uniquifyTypespec_` is set on every `clone_tree` before the
final elaboration), so golden holds a private copy of a typespec where we
hold one shared object. A shared object's children list once in a listener
walk, a copy's children at every copy: that is an identity difference, not a
content difference. Since 2026-09-24 the comparator re-expands a typespec
subtree (and an enum constant reached through a reference) at every
reference, so the two shapes list identically, while a content difference
inside any copy still reads as a difference. Objects on the walk's own path
are never re-expanded and the members under a class typespec stay visited
once (a class body is shared on both sides). `--no-canon` gives the raw
walk; the walk stops at 4M records a side (exit 3) because a deeply nested
typedef graph unfolds into a tree. Verified adversarially (r11u123,
tools/probe/r11u123canon): for every row that the canonical walk turns
equal, each raw walk is the canonical one with repeated subtrees removed,
proved mechanically on 82 corpus and 143 probe rows; 44,080 single-field
mutations were all caught; the verdict is symmetric; widening the root set
(nets, parameters, constants) converts at most four rows and uncovers
content, so the root set stays every typespec subclass plus `enum_const`
with the class-typespec barrier. Whether an object is shared or copied is
NOT part of the strict contract: the downstream consumer reads content, not
identity.

**Full names and spans on a typespec copy are excused only in the shape a
copy per use explains.** Golden's copy of a typespec is parented and
located at its use site; our one object is parented and located at its
declaration. So the full name of an object inside a copy carries the use
site's path on golden's side (`BC1.B` against `B` on a member's reference),
and a typedef's copy may carry the reference's span. The comparator's
default rule (`--canon-fullname 4`, verified adversarially by r11u129,
tools/probe/r11u129canon) reads a full name inside a copy as its tail (the
names on its parent chain up to the nearest named typespec, that name
included; a name that does not end with its tail is compared whole) and
excuses a different full name with an equal tail only when golden gives
that object of ours more than one name across its listings and ours is one
of them; likewise a named typedef root reached through a reference is
excused a different span only when golden gives that typedef more than one
span and ours is one of them. A name or span golden gives the same way at
every listing is content. Under this rule the identity residue is ZERO
row-modes: no row-mode differs from golden for identity alone, and every
remaining difference names an emitter site. The earlier readings stay as
measurement knobs (3: the last name on the walk's path, which missed
middle names and whose span rule never fired; 2: everything compared whole;
1 and 0: names inside a copy skipped). Measured at the switch on the
pass-124 sweep: strict-equal row-modes surelog 640 -> 632 of 954,
uhdm2rtlil 1264 -> 1252 of 1606, probe cases 2068 -> 2069 of 4087
(the rows the rule stops excusing are content: bare member-reference names
under anonymous aggregates, a chain that skips the typespec level, a
missing or extra reference full name). The remaining `depth`, `count` and
`type` first fields are content (a net binding, a typedef-alias reference,
shared constants: tools/probe/r11u128map section 5), not identity.

Historical: the `dump` column carried run_corpus's byte-identity distinction forward:
phase-1 `PASS` ≡ `CMP_EQUAL`+`match`, `CMP_ONLY` ≡ `CMP_EQUAL`+`differ`,
`DIFF` ≡ `CMP_NOTEQUAL`. `CMP_EQUAL` is the phase-2 bar; the `dump` column is
the phase-3 metric, already measured so regressions in byte identity stay
visible now.

Every change must clear, in the **main tree**:

1. `tests/sweep.sh` reads `regressions=0` for both corpora (or, per corpus:)
2. The uhdm2rtlil gate, against the committed baseline:

       python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
         --out /tmp/gate.csv --workdir /tmp/gatew --jobs 3

       diff <(sort results/gate_uhdm2rtlil.csv) <(sort /tmp/gate.csv)

   Wait for **732 lines** (731 tests + header) before diffing.
3. Movers reviewed one by one. Regressions, none allowed:
   - `CMP_EQUAL` → anything
   - `dump` `match` → `differ` (byte-identity demotion — phase-1's PASS→CMP_ONLY)
   - anything → `UNTRANSLATABLE` (the harness stopped being able to compare it)
4. After committing: `cp /tmp/gate.csv results/gate_uhdm2rtlil.csv`
5. Full two-mode sweeps of both corpora per wave (not per commit; ~45–60 min
   per corpus), refreshing `results/golden_*.csv` alongside.

Gate cadence (decided): while converging, the per-commit gate stays goldens +
u2r testflags (fast, bounded risk) with the Surelog suite gated per wave —
balancing regression risk against dev overhead. **Once fully converged, the
per-commit gate becomes u2r testflags + Surelog testflags, always.**

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

### 4.3b Dispatch: rolling frontier, not waves

Batch waves (one 12-agent workflow, integrate when ALL finish) lose hours to
stragglers: wave 3a's fastest cluster finished ~3h before its slowest while
five verified patches sat idle. The batch shape was justified only while
integration gates cost ~25 min each; the golden cache made a full
integration gate ~5 min, so stream instead:

- ONE workflow per cluster (implement+verify pair) — each completion wakes
  the orchestrator individually.
- Integrate every CONFIRMED patch immediately: apply → build → goldens +
  warm gates → commit → refresh baselines. Cross-patch interactions surface
  per-patch instead of six-at-once.
- Keep 3-4 implement agents running; launch the next backlog cluster as each
  finishes (the machine OOM-kills compilers at load ~20 — more concurrency
  is not faster).
- Streaming is safe: each worktree is frozen at its branch-point HEAD, so an
  agent's committed baselines match its binary and its gates stay internally
  consistent while mainline advances.
- Stragglers that outlive the frontier get their worktree harvested
  (git diff HEAD) rather than holding integration.
- **Model/effort pins (decided):** the orchestrator runs Fable 5 at xhigh;
  every subagent — implement and verify alike — is pinned `model: 'opus'`,
  `effort: 'high'` explicitly in each `agent()` call. Never rely on session
  inheritance for either (inherited model burned a session limit; inherited
  effort was silently uniform for four waves).
- **One cluster per agent context — no persistent workers.** An agent that
  finishes does NOT pick up the next cluster: context filled with one
  cluster's decode state invites mis-generalization on the next (the block
  produced three "heuristics" that were really one Surelog parser rule, each
  born from pattern-matching with stale context). Decode state transfers
  between agents through groundwork commits, ranked residues, and in-code
  NOTEs — never through a reused context.

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
2. ~~Is `-cfg` covered by slang's `--libmap` config handling?~~ **RESOLVED
   (yes, this block)**: slang's `ConfigBlockSymbol` implements the whole of
   LRM 33 and `--top <name>:config` selects a config block, so `-cfg`/`-cfgfile`
   is plumbing (§3.1). What slang does **not** carry is Surelog's
   library-qualified naming (`rtlLib@m` vs our `work@m`) — ranked, 0 tests, §3.2.
2b. ~~Errored-but-written Surelog database: golden or not?~~ **RESOLVED
   (match Surelog, `e8434be`)**: the golden is the artifact — Surelog's own
   regression records the errors in its golden logs and treats the output as
   expected. `converge.sh` now keys on the artifact like `verify_golden.py`,
   printing the rc when nonzero. `asgn_expr_sv` and `typedef_param` thereby
   entered the corpus as DIFF (135/223 dump lines). The policy then emptied the
   bucket entirely: every remaining "SURELOG_FAIL" was also rc=4-with-database
   (slang rejects those sources). uhdm2rtlil is now **488 PASS / 173 CMP_ONLY /
   2 DIFF / 47 SLANG_REJECT / 0 SURELOG_FAIL** — the 2 DIFF were always
   divergent, only hidden behind the rc check.
2c. ~~Is byte-identity still the end state?~~ **RESOLVED**: `CMP_EQUAL` is the
   phase-2 bar; byte identity (a `DUMP_MATCH` column in `verify_golden.py`) is
   phase 3, after both corpora are cmp-equal in both modes.
3. **Does `$RV_ROOT`-style variable expansion in `-f` files work?** slang's `-f`
   reads the flist but does not appear to expand the variable (`CoresSweRV`:
   "'/design/swerv_wrapper.sv': No such file or directory"). Affects 2 tests.
4. **Elab-mode byte convergence.** `--elabuhdm` is cmp-equal on sampled tests
   but leaves ~86–96 dump-line differences. Untouched territory.
