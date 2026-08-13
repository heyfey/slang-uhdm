# r10sd4 — ADVERSARIAL VERIFICATION of § classHomedTypeTsNoPkgInstance4

**VERDICT: PASS**, with eight numbered findings. Every gate, every canary, every
grid cell and the whole mover accounting reproduce — including both binaries
**bit-for-bit**. The findings are in the **record and the instruments**, not in
the landed change: one prediction that does not bound its own mover, one
misdescribed residue, one refuted "new observation", one invocation-relative
number, one dead predicate arm, and one canary script that cannot pass on the
directory it ships in. None of them touches the correctness of the two-token
gate, and the headline — **BuildUVMPkg's wall 1 366 893 → 94, both rows** — is
real, minimal and REMOVE-only.

| | |
|---|---|
| verifier worktrees | `/tmp/wt_vsd4` (patch @ `38f308e`), `/tmp/wt_vsd4pris` (pristine @ `38f308e`), `/tmp/wt_vsd4head` (patch @ `acc7e56`, arm experiment) |
| patch verified | `/tmp/r10sd4.patch`, md5 `9b867da3b0243a9dd2bed3f5cd912ca5` |
| re-cut delivered | `/tmp/r10sd4.verified.patch` (adds THIS file + the F6 `canaudit.sh` fix; production hunk untouched) |
| base built | `38f308e` — printed and `grep -c`-checked `=1` in both worktrees |
| also built | `acc7e56` (current HEAD) + the patch, to test forward-portability over the landed `r10earl43` |

---

## 1. THE FIVE GATES, RUN INDEPENDENTLY

Two fresh worktrees, own `cmake -B`, `-j 2`, own `--out`/`--workdir`,
`GOLDEN_DEFER` printed `[UNSET]` before the sweeps, `SLANG_UHDM` pinned and
**verified by reading `cmds.txt`** (not by trusting the export), `results/*.csv`
untouched (`git status --porcelain -- results` = 0), no `git stash`.

### GATE 1 — BUILD

```sh
git worktree add --detach /tmp/wt_vsd4 38f308e && git worktree add --detach /tmp/wt_vsd4pris 38f308e
cd /tmp/wt_vsd4 && git apply /tmp/r10sd4.patch
~/.local/bin/cmake -B <wt>/build -S <wt> -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/.local
~/.local/bin/cmake --build <wt>/build -j 2
```

| | measured |
|---|---|
| BASE both worktrees | `38f308ec74d7e1da4c1d675f7c7fe50fcedb3361`, `grep -c` = **1** each |
| ` error:` count | **0** / **0** |
| link line | `[100%] Linking CXX executable slang-uhdm` → `[100%] Built target slang_uhdm` seen in both logs **before** any md5 was read |
| md5, asserted separately | patched **`3c43e9f28022dc732c0e840400eb54a4`**, pristine **`129c3164f6f62f6c9cefda43aa3608fd`** — 32-hex each, different |

**Both md5s are bit-identical to the implementer's.** An independent
worktree, an independent configure and an independent build reproduce the
delivered binary exactly; the same held for the `acc7e56` rebuild
(`25a4a0e2a42ba8ed8ce33939930b47fb`, reproduced twice). Nothing in this pass
rests on a binary I did not build.

### GATE 2 — GOLDENS

`SLANG_UHDM=<patched> ./tests/check_goldens.sh` → **23 PASS / 0 FAIL** (rc=0).
`SLANG_UHDM=/bin/false ./tests/check_goldens.sh` → **0 PASS / 23 FAIL** (rc=1).
The negative control proves the harness can fail.

### GATE 3 — uhdm2rtlil

`verify_golden.py --corpus uhdm2rtlil --mode both --jobs 2`

| | measured |
|---|---|
| default | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** |
| testflags | **679 / 50 / 2** |
| dump column (testflags) | **496 match / 183 differ / 52 blank** |
| `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv` | **0 differing ROWS (0 diff row-sides)**, `PASS: every row byte-identical` |
| patched vs pristine CSV | **IDENTICAL** |

The **GATE-3 trap is real and was re-encoded**: `results/gate_uhdm2rtlil.csv`
holds `testflags` rows only (verified: 731 testflags, 0 default), so the fresh
both-modes CSV was filtered to testflags before `ct8rows.sh` saw it. Unfiltered,
all 731 default rows read as ADDED.

### GATE 4 — surelog

| | measured |
|---|---|
| default | **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT** |
| testflags | **465 / 8 / 23 / 5 / 286** + 3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM |
| `ct8rows.sh` vs `results/golden_surelog.csv` | **0 differing ROWS** |
| all four dump histograms | **identical** — default 225 match / 244 differ / 325 blank; testflags 165 / 300 / 329 |
| patched vs pristine CSV | **IDENTICAL** |

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs the pristine I built

```sh
SELFCHECK=1 SELFCHECK1=1 byteverify.sh <patched workdir> <pristine workdir>
```

| corpus | paths | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|---|
| uhdm2rtlil | `PATH_SETS_IDENTICAL (1358)` | **0 / 1358** | 1357 / 1358 | **1** (= the corruption alone) |
| surelog | `PATH_SETS_IDENTICAL (953)` | **2 / 953** | 952 / 953 | **3** (= 1 corruption + 2 real) |

The two movers are exactly `default/BuildUVMPkg` and `testflags/BuildUVMPkg`,
same md5 pair in both modes. Both negative controls fire.

### CANARIES

| check | measured |
|---|---|
| `canaries.sh` surelog | **ok=52 changed=0 absent=0**, unknown-names **7** (documented u2r-only) |
| `canaries.sh` u2r | **ok=8 changed=0 absent=0**, unknown-names **25** (documented) |
| `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` | **58 / 0 / 0**, unknown-patterns **1**, **PASS** |
| `ctcan2.sh` u2r `EXPECT_UNKNOWN=6` | **1 / 0 / 0**, unknown-patterns **6**, **PASS** |
| `canaudit.sh` on this directory | **audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS** — but see **F6** |
| `InterfaceModPort`, `BlackParrotComplex` BY NAME | **CMP_EQUAL in BOTH modes**, dump `differ`, unmoved |

**On the four slang-fenced names.** They are ordinary corpus rows
(`CMP_NOTEQUAL`, both modes, unmoved — `ct8rows` 0 rows covers them) and any
full-corpus sweep runs them; the standing fence is on **work dispatch**, not on
corpus membership. No driver in this directory dispatches them. Not a breach,
stated so the next verifier does not re-litigate it.

---

## 2. THE CLAIM ITSELF — every number re-measured

### 2.1 The four target rows (`rowheads.sh`, LHS always golden)

| row | pristine | patched | verdict |
|---|---|---|---|
| `default/BuildUVMPkg` | **1366893** | **94** | CLEARED |
| `testflags/BuildUVMPkg` | **1366893** | **94** | CLEARED, head byte-identical to `default` |
| `default/SeqDriver` | 1414847 | 1414847 | unmoved; DB **byte-identical** (17962228) |
| `testflags/SeqDriver` | 1414847 | 1414847 | unmoved; DB **byte-identical** (17962655) |
| `default/SimpleUVM` | 389 | 389 | unmoved |
| `testflags/SimpleUVM` | 389 | 389 | unmoved |
| `default/Scoreboard` | 389 | 389 | unmoved |
| `testflags/Scoreboard` | — | — | `SKIP-NOFILE`, **counted**, never read as agreement |

Every row `grep -c '^LHS:'` = **1**. SeqDriver's non-movement is an identity, not
a measurement: its databases are byte-equal between the two binaries.

The cleared head is what was claimed: pristine `LHS: <null>` /
`RHS: package uvm_pkg`.

### 2.2 Per-shape movers, by MULTISET, ADDED and REMOVED separately

Dump both `default/BuildUVMPkg` databases, `sed 1d`, multiset-difference:

```
REMOVED +1        |vpiInstance:
REMOVED +1        \_package: uvm_pkg (uvm_pkg::), ... line:7351:1, endln:83263:11
(ADDED: nothing)
```

**REMOVED 2, ADDED 0.** One `vpiInstance` slot and its package line, and
nothing else in 1 074 345 dump lines. `msdist.sh` against golden:

| | golden-only | ours-only | MULTISET DISTANCE |
|---|---|---|---|
| pristine | 53330 | 26289 | **79619** |
| patched | 53330 | 26287 | **79617** |

Golden-only **unchanged**; the whole −2 is ours-only shrinking. The move is
**toward** golden, REMOVE-only.

### 2.3 The reachable census (`ct4reach` [A]) — the pass's own scoreboard

| design | state | GOLDEN | ours pristine | ours patched |
|---|---|---|---|---|
| BuildUVMPkg | `<null>` | 22763 | 23629 | **23630** |
| | `ALL:uvm_pkg` | 3613 | 3411 | 3411 |
| | `TOP:uvm_pkg` | 4081 | 3547 | **3546** |
| SeqDriver | `<null>` | 34290 | 31299 | 31299 |
| | `ALL:adpcm_pkg` | 1052 | 1539 | 1539 |
| | `ALL:uvm_pkg` | 3489 | 3331 | 3331 |
| | `TOP:adpcm_pkg` | 929 | 1403 | 1403 |
| | `TOP:uvm_pkg` | 11290 | 6742 | 6742 |

**Exactly one slot moves on BuildUVMPkg; zero on SeqDriver** — every cell
matches the record. `ct4reach` also carries its own negative control and it
flips the right way: pristine `HEAD PRESENT with an empty seed`, patched
`HEAD ABSENT (empty seed) — nothing to localize`.

### 2.4 The grid, cell for cell, on binaries I built

`ct4grid.sh` on both binaries; `PASS_CMP`/dump content per cell:

| cell | pristine | patched |
|---|---|---|
| `q9_clstype_oob_local` | CMP_FAIL, **58** | CMP_FAIL, **56** |
| `q11_clstype_assoc_local` | CMP_FAIL, **72** | CMP_FAIL, **70** |
| `q1 q2 q3 q4 q5 q6 q7 q8 q10` | PASS_CMP, 26/4/26/36/6/2/16/2/42 | **identical, all PASS_CMP** |

Scored cell (`ct4key`, whole multiset per key, both sides):

```
q9   GOLDEN t9_t  inst=<null>   OURS pristine TOP:p9    OURS patched <null>   EQUAL
q11  GOLDEN t11_t inst=<null>   OURS pristine TOP:p11   OURS patched <null>   EQUAL
q10  GOLDEN ALL:p10 + TOP:p10   OURS both binaries the same                   EQUAL, UNMOVED
q8   41 copies (<null>=37 ALL:p8=2 TOP:p8=2) IDENTICAL both sides both binaries
```

`q9` vs `q10` really is a one-line discriminator on the same program, and `q8`
really does close the other degree of freedom. The discriminator holds.

The same grid run on `acc7e56` + the patch is **identical cell for cell**
(q9 = 56, q11 = 70, nine controls unmoved), so the pass is forward-portable over
the landed `r10earl43`.

### 2.5 The MOVER RULE

`detcheck.sh` (the campaign's own determinism instrument), 3 runs per binary,
`BuildUVMPkg`'s own argv:

| binary | bytes | distinct hashes |
|---|---|---|
| pristine | **11097312** ×3 | **1** |
| patched | **11097300** ×3 | **1** |

**SIZE-DELTA −12.** Real mover by the standing law — and see **F3**/**F4** for
what the record gets wrong about these two numbers.

---

## 3. PATCH HYGIENE

| check | result |
|---|---|
| `git apply --check` on fresh `38f308e` | **rc=0**, applies clean |
| `git apply --check` on current HEAD `acc7e56` | **rc=0**, applies clean, builds, grid identical |
| `git diff 38f308e -- include src` | **`src/TaskFuncEmit.cpp` +36 / −2 and nothing else** |
| files in patch | **61** = 1 production + 60 under `tools/probe/r10sd4repro/`; nothing outside |
| `git status --porcelain -uall` | **61** (plain `--porcelain` prints 2 — it collapses the untracked dir; the record's "61" is the `-uall` count) |
| `results/*.csv` | **untouched**, porcelain 0 |
| `README.verifier.md` in the delivered patch | **absent**, as required |
| probe dir vs the implementer's worktree | **byte-identical** (`diff -rq`, no output) |

### Boundaries — checked BEHAVIOURALLY, not by file-set argument

| boundary | check | result |
|---|---|---|
| § `classTdSpecParamsForeignHome1` (sd1 b1–b28) | `ct1grid.sh` on both binaries | **28 cells, output IDENTICAL** — `cells=28 golden-PA-cells=11 ours-PA-cells=7 SAME=24 DIFF=4 FAILED=0` on both. `UhdmExporter.cpp` also absent from the file set. |
| sd3 grid g1–g8 | `ct3grid.sh` on both binaries | **IDENTICAL** apart from the `WD=` tag I passed |
| buvm2 arms a1–a4, v1–v3 | `ct2arm.sh` on both binaries | **all 7 identical** (a4 PASS_CMP/DUMP_MATCH, v3 PASS_CMP, five CMP_FAIL at unchanged sizes) |
| sd2-verifier F3 | those rows' DBs byte-identical between binaries (gate 5) | undisturbed |
| live `r10earl43` (`ParamEmit.cpp`) | landed as `acc7e56`; patch applies and reproduces over it | intersection empty, **confirmed** |
| live `r10uvm72` (`TaskFuncEmit.cpp` — declared COLLISION) | `/tmp/wt_r10uvm72` working tree | currently touches **`src/ExprEmit.cpp` only** — the collision is **potential, not materialised**. Reporting it was correct and conservative. |

---

## 4. FINDINGS

### F1 — the census-predict does NOT contain the only mover, and its stated second arm does not exist

`README.md` §5.1: *"Result: **35 candidate rows, stated as an UPPER BOUND**, the
four UVM designs among them."* The four UVM designs are **not** among them.

```sh
cd tools/probe/r10sd4repro && bash predict4.sh | tail -n +2 | grep -iE 'build|uvmpkg'
#   -> NO OUTPUT.  BuildUVMPkg is absent from all 35 rows.
bash predict4.sh | grep -iE 'SeqDriver|SimpleUVM|Scoreboard'
#   -> uvm tests/SeqDriver / tests/SimpleUVM / tests/Scoreboard   (three, not four)
```

`BuildUVMPkg` — the **only row that moved** — is not in the predicted set. Root
cause is a cited guard that does not do what the citation claims, the campaign's
own dominant failure mode: `predict4.sh`'s header says *"The four UVM designs are
matched by NAME as well, because their shape lives in `third_party/UVM`"*, but
the code has **no name arm at all**. It reads only `.sv`/`.svh`/`.v` files inside
each test directory and sets `uvm` from their **content**:

```python
if 'uvm_pkg' in t or 'uvm_macros' in t: uvm = True
```

`Surelog/third_party/tests/BuildUVMPkg/` contains exactly one file,
`BuildUVMPkg.sl`, whose body is
`../../../UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv -verbose -parse …`. No
`.sv` file, so nothing is ever read and the row is never scored. An upper bound
that excludes the observed mover is not an upper bound.

**Not fatal to the pass**, and this is the fair reading: the record makes a
*second*, sharper prediction from the artifact — `ct4reach`'s reachable census,
BuildUVMPkg **1 slot** / SeqDriver **0** — and that one held **exactly** (§2.3).
The pass was predicted; `predict4.sh` is simply not what predicted it. Fix the
header or add the name arm; do not quote the 35 as a bound on this law again.

### F2 — R5 misdescribes the new BuildUVMPkg head; the fix direction it implies is wrong

Record: *"`LHS: struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)@11947:40` /
**`RHS: <null>`** … golden carries a struct typespec in a listing where we carry
nothing."* Measured, patched binary, `default/BuildUVMPkg`:

```sh
sed -n '85,90p' <out>/BuildUVMPkg.default.cmp
RHS:
decompile:
logic_typespec: , id:18582, line:11965:5, endln:11965:30
|vpiParent:
\_typespec_member: (orig), id:18581, line:11965:31, endln:11965:35
```

The RHS is **not** null. Source line 11965 is
`    m_uvm_factory_type_pair_t orig;` — a struct member whose type is the
**package-homed** typedef. Golden emits the named
`struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)` (correctly carrying
`vpiInstance` = `uvm_pkg`); we emit an **unnamed `logic_typespec`** at the
member's own span. It is a typespec **KIND** defect on a struct member, not a
missing object. "We carry nothing" and "we carry the wrong kind" are different
patches; the next pass should start from the measured one. The 94-line head and
both rows' byte-identity are otherwise exactly as claimed.

### F3 — "BuildUVMPkg is hash-unstable" is REFUTED, by the pass's own instrument

Record §5.5 records a **new** campaign-wide observation: *"BuildUVMPkg is
hash-unstable on both binaries (3 distinct md5s at fixed size) — extends sd2 R8
beyond Scoreboard … Any pass reading a BuildUVMPkg byte difference as evidence
must read the SIZE."*

```sh
cd <UVM pp_output> && detcheck.sh /tmp/wt_vsd4pris/build/slang-uhdm 3 $DIR/uvm_pkg.sv --single-unit
#   run 1..3: c51a89a19b9994a7  bytes=11097312
#   distinct hashes=1   NO_OUTPUT runs=0        rc=0  PASS
cd <UVM pp_output> && detcheck.sh /tmp/wt_vsd4/build/slang-uhdm 3 $DIR/uvm_pkg.sv --single-unit
#   run 1..3: dd2ba8b82ad66b27  bytes=11097300
#   distinct hashes=1   NO_OUTPUT runs=0        rc=0  PASS
```

**`distinct hashes = 1` on both binaries** — `detcheck.sh`, the instrument that
ships in this very directory for exactly this question, contradicts the
observation. Across this verification BuildUVMPkg was emitted **17 times** in
**5 invocation styles** (sequential; 3-way concurrent; three different `-o`
basenames of equal length; two cwds; both binaries) and **never produced more
than one hash per (binary, invocation)**. Determinism is not conditional on
load here.

This one matters beyond bookkeeping: carried forward, it instructs future passes
to **discount byte differences on BuildUVMPkg**, i.e. to weaken a gate, on the
strength of an artifact. **Do not propagate it.** sd2 R8's `Scoreboard` finding
is untouched by this — only its claimed extension is refuted.

### F4 — `SIZE-DELTA −12` is invocation-relative, not a property of the change

The −12 reproduces, twice, and I confirm it (§2.5, §2.2). But it is not portable:

```sh
# cwd = <UVM pp_output>, source given as $DIR/uvm_pkg.sv  ->  11097312 vs 11097300  (delta -12)
# cwd = /tmp/vsd4rep,    source given as an absolute path ->  11097249 vs 11097249  (delta   0)
```

Same two binaries, same `--single-unit`, 5 alternating reps each: **delta zero**.
The `-o` path is *not* the cause (same binary, three `-o` paths, three lengths →
one size, one hash). The absolute size tracks the **cwd / source-path spelling**,
and whether the removed slot's 12 bytes survive or are absorbed by capnp padding
tracks it too.

This does **not** undercut the mover — by the standing MOVER RULE a zero size
delta *proves nothing*, and the authority is per-shape content, which I
reproduced exactly (REMOVED 2 / ADDED 0, msdist −2, one census slot). It means
the record should scope the number: *−12 under BuildUVMPkg's own argv from its
own directory*, not *−12 full stop*.

### F5 — predicate arm 2 is DEAD across both corpora, and it is the one condition in the gate that was never measured

The record holds site 2 to a high standard — *"The second site was MEASURED, not
generalised"* (grid `q11`, run on the pristine binary before the code was
written). Arm 2 of the predicate got no such treatment; its justification is an
assertion:

> *"a `typedef` inside a class reaches the site as a `TypeAliasType` in some
> paths and as the aliased `StructType` in others; either spelling must answer
> the same."*

Tested by deletion, same base (`acc7e56`), same configure, `-j 2`:

```cpp
    if (const Scope* sc = t->getCanonicalType().getParentScope())   // arm 2
        if (sc->asSymbol().kind == SymbolKind::ClassType)           //   REMOVED
            return true;                                            //
```

| | full predicate | arm 1 only |
|---|---|---|
| grid `q1`…`q11` | 56 / 70 / nine controls | **identical, cell for cell** |
| `BuildUVMPkg` head | 94 lines, 1 head, same LHS | **94 lines, 1 head, same LHS** |
| `BuildUVMPkg` database | 11097300 | **11097300, and `cmp` says BYTE-IDENTICAL** |

And that generalises to the whole campaign corpus **without another sweep**:
gate 5 proves the only databases that differ at all between pristine and patched
are BuildUVMPkg's (2 of 2311 across both corpora, both modes); arm 1 alone
reproduces BuildUVMPkg **byte-for-byte**; therefore **arm 2 changes nothing on
any of the 2311 databases in either mode**.

Arm 2 is not *wrong* — it can only ever suppress a stamp on a class-homed type,
which the law says is never stamped — but it is **unmeasured breadth**, and this
campaign has already paid for unmeasured breadth once at scale (pass 56, a law
that "would have destroyed 218 correct bindings"). Either delete it, or land the
grid cell that exercises it. Do not leave it justified by prose.

### F6 — `canaudit.sh` cannot pass on the directory it ships in, once the mandated record exists — FIXED HERE

The standing rules require the verifier to author `README.verifier.md` **in this
directory**, and require `canaudit` `UNCOVERED=0` / `FENCE-BREACH=0`. Those two
requirements were mutually exclusive:

```sh
printf 'UnsignedParam HierPathEval FileLocalParam TopParam\n' > tools/probe/r10sd4repro/README.verifier.md
bash canaudit.sh ./canaries.sh ./ctcan2.sh
#   UnsignedParam   FENCE-BREACH in: .../README.verifier.md
#   ... x4
#   ---- audited=29  UNCOVERED=0  FENCE-BREACH=4      (exit 6)
```

The exclusion was the literal filename `/README.md$`. The implementer's
`canaudit` **PASS was obtainable only because the file they were required to
leave for the verifier was still absent** — and their own ops note reads the
`r10sd3repro` symptom as "a property of the audit" rather than as a defect that
would recur here by construction.

**Fixed in the re-cut patch**: the exclusion now covers `README[^/]*\.md$` — every
`README*.md` **record** in the directory, and nothing else. Re-exercised the
self-test: dropping a fake driver `zz_fake_driver.sh` containing a fenced name
still reports `FENCE-BREACH in: .../zz_fake_driver.sh`, `FENCE-BREACH=1`. The
audit still fires on a real driver; it no longer fires on a record.

### F7 — `ct4key` truncates at 24 copies per key, so per-key listings above 24 are unverifiable as printed

`ct4key.cpp:96` — `if (n++ < 24)`. The `TOTAL … copies:` line is exact, the
listing is not. R1's *"golden 10 `bit_typespec@26:1-26:4` copies (4 pkg + 6 null)
vs our 6 (4 + 2)"* cannot be checked from the printed listing (the
`bit_typespec` key group holds 3647 golden / 1804 ours copies and prints 24). An
early attempt of mine to check it read `0` on golden and looked like a
contradiction; it was my instrument error, not the record's. Flagged so the next
reader does not repeat it. Quote `TOTAL`, or narrow the key.

### F8 — EMPTY-PRODUCT HUNT: two un-gated stamp sites tested, and the narrow gate is CONFIRMED correct

The stated **law** ("a typespec whose TYPE is declared inside a class never
carries a package `vpiInstance`, whatever scope the DECLARATION sits in") is
universal; the **gate** is two of at least four `Instance(tsInst)` stamp sites in
`TaskFuncEmit.cpp`. The obvious adversarial question is whether the un-gated
siblings carry the same defect and were simply missed. They do not. Two new
cells, written here, on both binaries:

| cell | shape | site exercised | golden | ours (both binaries) |
|---|---|---|---|---|
| `qv12_clstype_fixedarray_oob` | q9 with a **fixed-size** unpacked array | `TaskFuncEmit.cpp:~4727` | `<null>` | **`<null>`** |
| `qv13_clstype_flat_oob` | q9 with **no array at all**, flat local | `TaskFuncEmit.cpp:~4969` | `<null>` | **`<null>`** |

Non-vacuity checked, so an `<null>`/`<null>` agreement costs something: each
program carries live package stamps on both sides (`qv13` golden `ALL:p13=1
TOP:p13=1`, ours identical). **The gate's narrow scope is right, and now by
measurement instead of by omission** — the sharing that makes the queue/assoc
arms bite does not occur in those arms.

Byproduct, previously unreported: `qv12` shows **our side emits two surplus
package-stamped typespecs golden has none of** —
`logic_typespec@12:5-12:10 inst=TOP:p12` and `…ALL:p12`, one per view, at the
fixed-array oob local. Golden 62 typespec copies (`<null>`=60, ALL=1, TOP=1) vs
ours 64 (`<null>`=60, ALL=2, TOP=2). A separate family in the fixed-array arm,
untouched by this pass and unrelated to it. `qv13` is clean (54 vs 54).

Also confirmed positively: after the fix, `q9` and `q11`'s **whole-design
typespec instance census matches golden exactly** (62 vs 62 and 70 vs 70, per
state) — the cell does not merely stop failing, it converges.

---

## 5. RESIDUES, RE-RANKED FOR THE NEXT PASS

1. **R1 (theirs) — the SeqDriver wall, 1 414 847, both rows. CONFIRMED and
   ready.** I re-measured the localization and it holds. The named site is
   verbatim at `src/ModuleEmit.cpp:4096-4099`:
   `if (auto* v23 = pv23->Variables()) for (auto* x23 : *v23) … vars23->push_back(x23);`
   — the imported package's **own** variable objects, pushed into the importing
   scope. And `ct4key` gives the target shape outright:

   ```
   GOLDEN  5 x bit_var(uvm_start_uvm_declarations)@26:5-26:31  <- class_defn(adpcm_driver /
           adpcm_seq_item / adpcm_sequencer / adpcm_test / adpcm_tx_seq) <- package(adpcm_pkg)
           6 x @26:5-26:35 (2 adpcm_pkg + 2 uvm_pkg + 2 module_inst) + 2 logic_net  = 13 copies
   OURS    6 copies, NO class_defn listing at all, every one at @26:5-26:35
   ```

   Golden emits **five distinct class-scope copies at the NAME span**; we emit
   none. Clone at that push, with the NAME span. Biggest item left on these rows.
2. **R3 (theirs) — the `TOP:` view deficit**, re-measured and unchanged:
   SeqDriver `TOP:uvm_pkg` 11290 golden vs 6742 ours (**−4548**), BuildUVMPkg
   4081 vs 3546 (**−535**); `adpcm_pkg` long on both views (**+487 / +474**).
   Still the largest single number on these designs.
3. **F2's real head** — the `logic_typespec`-for-`struct_typespec` kind defect on
   a struct member of a package typedef. 94 lines, both rows, two orders of
   magnitude cheaper than anything these rows have offered.
4. **F5** — delete arm 2, or land the cell that exercises it.
5. **F1** — give `predict4.sh` the name arm its header already claims, or stop
   citing its count as a bound.
6. **F8's byproduct** — the fixed-array oob-local surplus (`+2` package-stamped
   `logic_typespec`), with `qv12` as a 19-line ready-made reproducer.
7. **R4 (theirs)** — `q9`/`q11`'s new head `LHS: ref_var(p9::c9::f9::l9)`,
   confirmed unchanged before and after; a real 12-line reproducer.
8. **F7** — raise or parameterise `ct4key`'s 24-copy print cap.
9. **R2 (theirs)** — `classHomedType4` still sits between
   `makeQueueDynArrayVar`'s doc comment and its signature (confirmed at
   `TaskFuncEmit.cpp:1092-1128`). Their reason for not fixing it — that every
   number in the record was measured on the binary the delivered patch builds —
   is sound, and I did not fix it either, for the same reason. One-line move for
   the integrator.

## 6. WHAT I DID NOT VERIFY

Stated plainly, so it is not read as endorsed:

* **The gdb-watchpoint readout** (`ct4bt`, §3.4) — I did not re-run the
  watchpoint or re-derive the frame stack. Its *conclusions* are independently
  corroborated by everything I did measure (the arm is `vpiInstance`; the owner
  is a typespec; the BuildUVMPkg owner is the class-homed struct typedef; the
  SeqDriver owner is the `bit_var` import listing at `@26:5`), so I have no
  reason to doubt it — but it is corroborated, not reproduced.
* **The "`Compare` costs ~1.5 ms / `m_visited` = 1613" cost model.** I timed one
  whole-design `uhdm-cmp` on SeqDriver at **785 ms**, essentially all of it
  database load plus printing the 1 414 847-line subtree — consistent with the
  claim, but the claim isolates `Compare()` itself and I did not.
* **`ct4mut2` / `ct4vec` / `ct4scan` / `ct4own`'s counts** (6818, 25, 34299 /
  316922 / 1613, 16 killers). These support the *method* narrative and the
  refutations, not the landed gate.
* **The refutations of `r10sd2` §4.1 and R1.** I verified the one that is cheap
  and load-bearing — that the four target row-modes are **two** defects with two
  owners and two emitter files, which §2.1 and §2.4 establish directly — and
  took the rest on the record.
