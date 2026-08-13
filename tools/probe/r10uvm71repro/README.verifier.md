# r10uvm71 — ADVERSARIAL VERIFIER: **PARTIAL → PASS after one re-cut.** Every number in the implementer's report reproduces exactly; the LAW as stated over-fires on a cell no corpus contains, and the fix is one token

**FIRST LINE.** I applied `/tmp/r10uvm71.patch` to a FRESH `730f4bf` worktree
(`/tmp/wt_v71`), built it myself `-j 2`, and built a PRISTINE `730f4bf` control
(`/tmp/wt_v71pris`). **Both binaries reproduced the implementer's md5s bit for
bit** — control `c932a66fcafdab8b3f3931adb1657f0c`, shipped
`fb78247bbcfe28d39510111bd33252e2` — so the build is reproducible across
worktrees and every number below was measured on binaries I built.

**SECOND LINE.** Every gate, every census figure, every mover, every head and
every canary in the implementer's report **reproduced exactly**. Nothing was
overstated in the measurement. The refutation of the brief's premise (the
`class_defn` vector is IDENTICAL on both sides; the printed object was the
CONTAINER) is **confirmed** by my own runs.

**THIRD LINE, and it is why this is not a plain PASS.** The stated law reads
"a subroutine named `new` is a constructor and nothing else — `new` is a
keyword, so no package- or module-level function can carry the name". **That is
false, and the code gate inherited the error.** An *escaped identifier* is
exempt from keyword rules: `function int \new (int a);` is an ORDINARY class
method that slang also names `"new"`. **Golden keeps that method's body local on
the function; the base agreed with golden; the shipped gate deletes it.** New
arm `a4_escnew.sv`:

| | golden | base 730f4bf | SHIPPED gate | **flag gate** |
|---|---|---|---|---|
| `p4::c_esc::\new` (escaped-id METHOD, not a ctor) | **1** | 1 ✓ | **0 ✗** | **1 ✓** |
| `p4::\new` (package escaped-id function) | 1 | 1 ✓ | 1 ✓ | 1 ✓ |
| `p4::c_esc::plain_meth` (control) | 1 | 1 ✓ | 1 ✓ | 1 ✓ |
| whole-dump distance to golden | — | **97** | **123** (worse) | **97** |

No source in either corpus uses `\new` (`grep -rl '\\new[ (]'` over both corpora:
**0 files**), so all five gates stayed green over a real regression. That is the
exact failure mode the standing rules warn about: a green gate is not a proof of
a LAW, only of a POPULATION.

**FOURTH LINE.** `|| oob` in the shipped gate is **dead code**, and the README's
claim that "both halves are load-bearing and the arm proves it… a
`classScope`-only gate would have left that head standing" is **REFUTED**, twice
over — statically and by measurement.

**VERDICT: PASS on the re-cut** `/tmp/r10uvm71.verified.patch`
(md5 below). The law, the mechanism, the head clearing and every gate stand; the
gate's SPELLING is replaced by slang's own `MethodFlags::Constructor`, which is
already used twice in this same file.

---

## 0. WHAT I BUILT AND RAN

| worktree | base | gate | md5 | role |
|---|---|---|---|---|
| `/tmp/wt_v71pris` | 730f4bf | — | `c932a66fcafdab8b3f3931adb1657f0c` | CONTROL |
| `/tmp/wt_v71` | 730f4bf | shipped `sub.name=="new" && (classScope\|\|oob)` | `fb78247bbcfe28d39510111bd33252e2` | the delivered patch |
| `/tmp/wt_v71x` (stage 1) | 730f4bf | `sub.name=="new" && classScope` | `9cb92f1316053029dae4f33598e7f6dd` | is `\|\| oob` load-bearing? |
| **`/tmp/wt_v71x` (final)** | 730f4bf | **`MethodFlags::Constructor`** | **`1360280c0b04b5eb402aaf052de652a2`** | **the re-cut** |

All four `-j 2`, `[100%] Linking CXX executable slang-uhdm` → `[100%] Built
target slang_uhdm` read before any md5, each md5 asserted `^[0-9a-f]{32}$` in a
separate command. `git rev-parse HEAD` = `730f4bf9b7b389550c42a65e444a44958619d8f1`
in all four. `GOLDEN_DEFER` **UNSET** (echoed `[UNSET]` at launch).
`results/*.csv` READ ONLY. slang never patched. The four fenced tests never
dispatched (`canaudit.sh` FENCE-BREACH=0). The final comment-only edit to
`TaskFuncEmit.cpp` rebuilt to the **same md5** as the measured flag-gate binary,
so every measurement below applies to the shipped source.

The patch applies cleanly to a fresh `730f4bf` **and** to current `auto5h` head
`02b28ca` (r10earl41 landed) — `git apply --check` clean, no textual collision.

---

## 1. FINDINGS

### FINDING 1 — the stated LAW over-fires on an escaped-identifier method (REGRESSION, latent) — **FIXED in the re-cut**

*Command:*
```bash
cd tools/probe/r10uvm71repro
SLANG_UHDM=<base>    ./ct71arm.sh a4_escnew.sv /tmp/a4_base
SLANG_UHDM=<shipped> ./ct71arm.sh a4_escnew.sv /tmp/a4_ship
python3 ct71subvars.py /tmp/a4_base/g.dump --tsv   # golden
python3 ct71subvars.py /tmp/a4_base/o.dump --tsv   # base
python3 ct71subvars.py /tmp/a4_ship/o.dump --tsv   # shipped
```
`p4::c_esc::\new` carries **1** variable in golden and in the base, **0** under
the shipped gate. The dump distance to golden goes **97 → 123**: the shipped
patch makes this cell WORSE than the code it replaces. `p4::\new` at package
scope survives only because `classScope` is false there — i.e. the name test was
already known to be unsafe and was fenced by a *scope*, not by *constructor-ness*.

**FIX (in `/tmp/r10uvm71.verified.patch`), one token, same site:**
```cpp
bool ctorNoVars71 =
    (sub.flags & MethodFlags::Constructor) != MethodFlags::None;
```
`MethodFlags::Constructor` is slang's own answer and is already used twice in
this very file (`:1032`, `:2631`). Measured after the swap:
* a4 cell back to golden (1), whole-dump distance back to **97**;
* arms a1, a2, a3 **byte-identical to the shipped binary** (0 diff lines each) —
  in-body, `super.new`, parameterized, `automatic`, out-of-body `extern`,
  `$unit`/module/nested/virtual/derived, and my new clone/`$bits`/queue cells
  all still clear, so the flag is set on the out-of-body DEFINITION too;
* the whole surelog corpus **content-identical** to the shipped binary: 953
  databases, 1 byte-differing path (`Scoreboard/default`) whose per-shape delta
  is **REMOVED=0 ADDED=0, size delta 0** — the measured noise floor (Finding 3);
* u2r **0/679 movers** vs the shipped binary;
* goldens **23/0**; both whole-row judges **0 differing ROWS**; heads unchanged
  (389/389/389, SeqDriver 1414833, BuildUVMPkg 58).

### FINDING 2 — `|| oob` is DEAD, and the README's proof-claim for it is false (documentation defect; no behavioural effect)

*Static:* `oobDefs` is a function-local vector populated **only inside
`if (classScope)`** (`TaskFuncEmit.cpp:1554-1573`); `isOutOfBody` (`:1591`) tests
membership of that same local. Everything from `:1489` to `:5200` is ONE
function (`emitTaskFuncs`), so within any invocation `oob ⟹ classScope`, hence
`(classScope || oob) ≡ classScope`.

*Measured* (`/tmp/wt_v71x` stage 1, gate `sub.name=="new" && classScope`):
```
a1_ctor:       shipped vs classScope-ONLY  difflines=0
a2_site:       shipped vs classScope-ONLY  difflines=0
a3_cells:      shipped vs classScope-ONLY  difflines=0
SimpleUVM:     shipped vs classScope-ONLY  MULTISET REMOVED=0 ADDED=0
```
The README states the opposite: "**both halves are load-bearing and the arm
proves it** … A `classScope`-only gate would have left that head standing."
Arm a1's head clears identically without `|| oob`. The disjunct cost nothing —
but a stated law that a one-line experiment refutes is exactly what the
STATED-GATE-==-CODE-GATE rule exists to catch, and it would have been inherited
by the next pass as fact.

### FINDING 3 — the noise-floor claim is overstated at the byte level (the conclusion survives)

*Command:*
```bash
cd ~/git-repos/Surelog/third_party/tests/Scoreboard
for r in 1 2; do <PRISTINE-BIN> +incdir+… uvm_pkg.sv design.sv testbench.sv \
    --single-unit -o /tmp/v71_noise_pris_$r.uhdm; done
cmp /tmp/v71_noise_pris_1.uhdm /tmp/v71_noise_pris_2.uhdm
```
The README says two sweeps of the SAME pristine binary gave `Scoreboard/default`
**byte-identical** databases. They are **not**: same size (11122855), differing
at byte 9763798. The *content* floor is what the rules make authoritative and it
IS zero — multiset `REMOVED=0 ADDED=0`. So the conclusion ("Scoreboard's 30-line
deletion is real") stands, but the instrument that would have caught a
false-positive is the multiset, not `cmp`; and the byte verifier's mover COUNT
on that one row is not by itself trustworthy. I hit exactly this: the re-cut
binary shows `Scoreboard/default` as a "mover" against the shipped binary with a
0/0 content delta.

### FINDING 4 — pre-existing gap surfaced by my arm a3: a class declared in an INTERFACE emits no subroutines at all

`work@c_ifc::new` and `work@c_ifc::ifc_meth` are in golden and in **neither** of
our binaries (28 subroutine objects vs golden's 30). Present in the base, so
**not** caused by this patch; it is why a3's residual distance to golden is 466
lines. Reported as a residue, not a defect of this pass.

### FINDING 5 — the u2r corpus provides ZERO coverage for this law

`grep -rl "function new" ~/git-repos/uhdm2rtlil/test` → **0 files**. The
"uhdm2rtlil: 0 movers" prediction is therefore trivially true and carries no
information about the law. The whole evidential weight sits on the surelog
corpus's 4 UVM tests plus the arms — which is why the arm grid mattered here more
than usual, and why the escaped-identifier cell was worth building.

---

## 2. EVERY CLAIMED NUMBER, REPRODUCED

### 2.1 The five gates, run independently

| gate | claim | mine | verdict |
|---|---|---|---|
| 1 BUILD | ctrl `c932a66f…`, final `fb78247b…` | **identical, both** | ✓ |
| 2 GOLDENS | 23/0; `/bin/false` 0/23 | **23/0**; **0/23** | ✓ |
| 3 u2r testflags | 679/50/2, dump 496/183/52, 0 rows | **679/50/2, 496/183/52, 0 ROWS** | ✓ |
| 4 surelog both | 469/11, 465/8, DEFER 5/5, FAIL 25/23, 0 rows | **exact**, 0 ROWS, histograms unchanged | ✓ |
| 5 BYTE VERIFIER | surelog 7/953, u2r 0/679; SELFCHECK 952/678, SELFCHECK1 8/1 | **7/953, 0/679, 952/678, 8/1** | ✓ |

Both PRISTINE sweeps also judged **0 differing ROWS** against the committed
baselines (731 and 1588 rows) — the control is anchored on the corpus.

### 2.2 The movers, per-shape by MULTISET — ADDED=0 on all seven

| mover | REMOVED | ADDED | size delta |
|---|---|---|---|
| `default/BuildUVMPkg` | 42 | **0** | −222 |
| `default/Scoreboard` | 30 | **0** | −142 |
| `default/SeqDriver` | 42 | **0** | −199 |
| `default/SimpleUVM` | 30 | **0** | −134 |
| `testflags/BuildUVMPkg` | 42 | **0** | −222 |
| `testflags/SeqDriver` | 42 | **0** | −185 |
| `testflags/SimpleUVM` | 30 | **0** | −134 |

Every figure matches the report. I read every removed line: each is a
`|vpiVariables:` label or a variable declaration whose fullname contains
`::new::`. **No removed line lies outside a constructor.** All 7 rows are
`CMP_NOTEQUAL` before and after; **no `CMP_EQUAL` database moved a byte** in
either corpus.

### 2.3 The census

| | golden | ours base | ours shipped |
|---|---|---|---|
| subroutine objects (merged) | **3915** | 3915 | 3915 |
| with `vpiVariables` | **665** | **670** | **665** |
| constructors (290) with vars | **0** | **5** | **0** |
| `SUBR_DISAGREE` | 0 | 0 | 0 |

The base-vs-golden name-keyed diff is exactly the five named constructors
(`uvm_objection`, `uvm_component`, `uvm_cmdline_processor`, `uvm_port_base`,
`uvm_heartbeat`); the shipped-vs-golden name+count table is **empty across all
3915 rows**. The `vpiMethod` census output is **identical between golden and
ours** design-wide — 332 class_defns, 269 carrying `new`, `uvm_objection`'s
vector 32 entries with `new` at `[0]`, names and order identical. **The brief's
premise is refuted, exactly as reported.**

### 2.4 The heads

| row | base | shipped | re-cut |
|---|---|---|---|
| SimpleUVM/default | **593** `LHS:<null>` vs our `function (uvm_pkg::uvm_objection::new) @127:3` | **389** `function (uvm_pkg::uvm_report_enabled)` vs `RHS:<null>` | **389**, same head object |
| SimpleUVM/testflags | 593 | 389 | 389 |
| Scoreboard/default | 593 | 389 | 389 |
| SeqDriver/default,testflags | 1414881 | 1414833, **same head object** | same |
| BuildUVMPkg/default,testflags | 58 | 58, **same head object** | same |

I confirmed the new head's `RHS: <null>` (the mirror shape) and that
SeqDriver's/BuildUVMPkg's head objects are unchanged (ids normalised, first 8
lines identical).

### 2.5 Boundaries and the named owners

* **One file, three hunks**; nothing outside `src/TaskFuncEmit.cpp` and
  `tools/probe/r10uvm71repro/`. No `results/*.csv` touched.
* `§ atomVarSignedWritten68` — `b68fence.sh` over all six of 68's arms:
  **MOVED=0**, all six OURS-DUMP-IDENTICAL.
* `§ implicitRetSigningIsIntVar70` — uvm70's `a1_ret a2_site a3_cls a4_proto
  v5_gaps`: **0 diff lines** between base and shipped on every arm.
* `§ retNameRecvCollapse69` — uvm69's `a1_type a2_scope a3_recv v1_gaps`:
  **0 diff lines** on every arm.
* `§ retNameLocalInstIsHomeNotClass3` — sd3's `g1…g8` grid: **0 diff lines** on
  all eight.
* `§ invalidNewCallFromSyntax55` (new()-call bind refusals): untouched — no call
  and no binding changes; the `uvm_report_enabled` back-reference population is
  **941 both before and after** (golden 1095).
* Live `r10buvm1` (ExprEmit) and landed `r10earl41`
  (TypeEmit/ExprEmit/EmitHelpers/UhdmExporter.h): **no file overlap**, and the
  patch applies cleanly on top of `02b28ca`.
* The `$bits(<formal>)` io_decl binder rewire is genuinely input-preserving —
  see the a3 `c_bits` cell below, where the whole function region is byte-identical
  to golden after the patch.

### 2.6 Canaries

`canaries.sh` surelog **ok=52 changed=0 absent=0** (unknown-names 7);
uhdm2rtlil **ok=8 changed=0 absent=0** (unknown-names 25).
`ctcan2.sh` surelog `EXPECT_UNKNOWN=1` **ok=58 changed=0**, unknown-patterns 1;
uhdm2rtlil `EXPECT_UNKNOWN=6` **ok=1 changed=0**, unknown-patterns 6.
`canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0**.
`InterfaceModPort` and `BlackParrotComplex` BY NAME: rows byte-identical to the
baseline in both modes **and** their databases byte-identical between the two
binaries.

---

## 3. EMPTY PRODUCT CELLS — what a1/a2 never reached, and what I found there

`a3_cells.sv` and `a4_escnew.sv` (added to this directory) fill the holes:

| cell | why it is not in a1/a2 | golden | base | shipped | verdict |
|---|---|---|---|---|---|
| `c_bits::new` — ctor local typed `logic [$bits(a)-1:0]` | **the code the patch REWIRED**; a1/a2 contain no `$bits` at all | on begin | on func | **on begin** | ✓ region **byte-identical to golden** |
| `c_pkgtd::new` — pkg-typedef + struct + class-handle locals, class WILDCARD-IMPORTED into a module | `TypeEmit.cpp:6143` rebinds a clone task_func's `->Variables()`; a ctor no longer has one | 0 | 3 | **0** | ✓ region **byte-identical to golden** |
| `c_oobpar::new` — **extern ctor of a PARAMETERIZED class** | a1's oob cell is unparameterized, a1's param cell is in-body | 0 | 2 | **0** | ✓ |
| `c_queue::new` — QUEUE + dynamic-array locals (the `trace_args` shape) | a1/a2 have no array locals | 0 | 2 | **0** | ✓ |
| `c_ifc::new` — class inside an INTERFACE | site axis stops at module/`$unit`/nested | 1 subroutine | **absent** | **absent** | pre-existing gap (Finding 4) |
| **`c_esc::\new` — escaped-identifier METHOD** | the law asserts this cannot exist | **1** | 1 | **0** | ✗ **REGRESSION → Finding 1** |
| `p4::\new` — escaped-identifier PACKAGE function | same | 1 | 1 | 1 | ✓ |
| non-ctor controls in every cell above | | = | = | = | ✓ unchanged |

Multiset delta base→shipped, paths normalised: **a1 REMOVED=29 ADDED=0**, **a2
REMOVED=12 ADDED=0**, **a3 REMOVED=20 ADDED=0** — pure deletions everywhere.
Golden-vs-final per-subroutine tables for a1 and a2 are **empty diffs**, matching
the report.

One caveat on the arms: `ct71arm.sh` copies the source INTO the workdir, so the
dumps embed the workdir path. A multiset diff without path normalisation reports
~134 phantom ADDED lines. `mv71.sh` gets away without normalising only because
sweep dumps reference the shared corpus path. Normalise, or the "pure deletion"
reading on any ARM is an artefact.

---

## 4. RESIDUES, RANKED

1. **The new head on all three rows — `func_call` binding, ~154 sites.**
   Confirmed independently: the `function (uvm_pkg::uvm_report_enabled)` object
   is printed **1095** times in golden and **941** in ours, **941 before and
   after this patch**, and the control-vs-final content diff mentions it **zero**
   times. Pre-existing, call-binding family.
2. **Subroutine `endln` spans design-wide.** Golden ends a subroutine at its
   PROTOTYPE, we at the BODY. Large and pervasive (the name-keyed table matches
   on all 3915 rows; the span-keyed one does not). NOTE: the report's "1614 of
   3915" is keying-dependent — 836 subroutine names are duplicated in the table,
   so any name-join double-counts. Re-derive the number before citing it.
3. **A class declared in an INTERFACE emits no subroutines at all** (Finding 4).
   One arm cell already isolates it.
4. `c_auto::new`'s `vpiReturn` span (a1) — 4/5 cells match golden; adjacent to
   `§ retNameLocalInstIsHomeNotClass3`.
5. a1/a2 residual heads: `int_typespec` on `p1::c_param::W`; `class_defn`
   ordering on `work@a2::c_bare`.
6. **Instrument residue:** `byteverify.sh` counts movers with `cmp`, and
   `Scoreboard/default` is byte-unstable run to run. Either fold the multiset
   check into the verifier or annotate that row; today a clean run and a
   1-mover-with-0/0-content run look different and are not.

---

## 5. HOW TO REPRODUCE THE VERIFIER'S OWN FINDINGS

```bash
# the over-fire (Finding 1) — one arm, three binaries
SLANG_UHDM=<base>    ./ct71arm.sh a4_escnew.sv /tmp/a4_base
SLANG_UHDM=<shipped> ./ct71arm.sh a4_escnew.sv /tmp/a4_ship
SLANG_UHDM=<recut>   ./ct71arm.sh a4_escnew.sv /tmp/a4_fix
for d in /tmp/a4_base /tmp/a4_ship /tmp/a4_fix; do
  python3 ct71subvars.py $d/o.dump --tsv | grep 'c_esc::new'; done
python3 ct71subvars.py /tmp/a4_base/g.dump --tsv | grep 'c_esc::new'   # golden

# the empty product cells (a3)
SLANG_UHDM=<bin> ./ct71arm.sh a3_cells.sv /tmp/a3
diff <(python3 ct71subvars.py /tmp/a3/g.dump --tsv | cut -f1,2,4) \
     <(python3 ct71subvars.py /tmp/a3/o.dump --tsv | cut -f1,2,4)

# `|| oob` is dead (Finding 2) — build with `&& classScope` and diff the dumps
# the noise floor (Finding 3)
cd ~/git-repos/Surelog/third_party/tests/Scoreboard   # run the SAME binary twice
```

Arm multiset diffs MUST normalise the workdir path:
`sed 's/^ *//; s#<wd>/##g' | sort`.
