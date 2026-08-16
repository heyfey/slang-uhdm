# r10sd5 — ADVERSARIAL VERIFIER'S REPORT

**VERDICT: PASS.** Every headline number in the implementer's report reproduces
on binaries I built myself, and the two claims that do *not* reproduce are an
arithmetic mis-count in a census summary (F2) and two path-dependent byte sizes
(F5) — neither touches a gate, a law or a mover. One substantive finding is
raised (F1): the law **as coded** is unconditional and the pass's **own grid cell
`v2`** is a measured counterexample to it, inert today only because an upstream
defect (the report's R4) stops that shape from reaching the arm. That is a
latent defect for the *next* pass, not a defect in this one — measured movers
today: **exactly the five predicted, zero elsewhere**.

| | |
|---|---|
| verifier BASE | `511725d` — `git rev-parse HEAD \| grep -c` = **1** in BOTH worktrees |
| my worktrees | `/tmp/wt_r10sd5v` (patched), `/tmp/wt_r10sd5vpris` (pristine, `git status --porcelain` = **0**) |
| my patched md5 | **`98e696e9785f4edd2a3a9da9e8ba55fa`** — identical to the delivered figure |
| my pristine md5 | **`4535fc6e3d47177635c1278c4954bf20`** — identical to the delivered figure |
| patch checked | `/tmp/r10sd5.patch`, md5 **`e3e221d762b9cccd3882e6084f888823`** |
| applied to | a **FRESH `511725d`** worktree (`git apply` clean, no offsets); **also** to current `HEAD 61d5e36`, clean, offset +127 |
| re-cut | `/tmp/r10sd5.verified.patch` — the delivered patch **plus this file only** |

The build is **reproducible**: I rebuilt both binaries from a fresh configure in
fresh worktrees and both md5s came back bit-for-bit equal to the implementer's.
That retires the usual doubt about which binary produced which number.

---

## 1. THE FIVE GATES, RE-RUN INDEPENDENTLY

Every gate below was run by me, from my own sweeps, with `SLANG_UHDM` exported
explicitly and `GOLDEN_DEFER` printed `[UNSET]` before each sweep.

| gate | required | MY measurement | verdict |
|---|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line before md5, 32-hex, BASE grep-checked | both worktrees `BASE 511725d` grep-check **=1**; ` error:` count **0** / **0**; `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen before any md5 read; md5s **98e696…** / **4535fc…**, 32 hex, different | **PASS — and both REPRODUCE the delivered md5s exactly** |
| **2 GOLDENS** | 23/0 and `/bin/false` 0/23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** | **PASS** |
| **3 u2r** | testflags j2 679/50/2, dump 496/183/52, `ct8rows` 0 rows | default **679/50/2**, testflags **679/50/2**; dump testflags **496 match / 183 differ / 52 blank**; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv`, testflags-filtered (731 rows) → **0 differing ROWS (0 row-sides)**, `PASS: every row byte-identical` | **PASS** |
| **4 surelog** | both j2 469/11 + 465/8 (FAIL 25/23, DEFER 5/5), histograms unchanged, 0 rows | default **469 / 11 / 25 / 5 / 284**; testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM); `ct8rows` vs committed `results/golden_surelog.csv` → **0 differing ROWS**; all **4** dump histograms identical (default 225/244/325, testflags 165/300/329) | **PASS** |
| **5 BYTE VERIFIER** | both corpora both modes vs a PRISTINE I build, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | u2r **0 / 1358**, surelog **5 / 953**, `PATH_SETS_IDENTICAL` both; SELFCHECK **1357/1358** and **952/953**; SELFCHECK1 **1** and **6**; the 5 are name-for-name the predicted set | **PASS** |

Commands (all run from the repo root or with absolute paths):

```sh
# gate 1
~/.local/bin/cmake -B /tmp/wt_r10sd5v/build -S /tmp/wt_r10sd5v \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/.local
~/.local/bin/cmake --build /tmp/wt_r10sd5v/build -j 2      # 0 error:, link line seen
md5sum /tmp/wt_r10sd5v/build/slang-uhdm                     # asserted separately
# gate 2
SLANG_UHDM=/tmp/wt_r10sd5v/build/slang-uhdm ./tests/check_goldens.sh | grep -c '^PASS'
SLANG_UHDM=/bin/false                       ./tests/check_goldens.sh | grep -c '^FAIL'
# gates 3/4 (four sweeps, --jobs 2, private --out/--workdir, SLANG_UHDM exported)
python3 scripts/verify_golden.py --corpus surelog    --mode both --jobs 2 \
    --out /tmp/r10sd5v_sl_new.csv  --workdir /tmp/r10sd5v_wd_sl_new
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 2 \
    --out /tmp/r10sd5v_u2r_new.csv --workdir /tmp/r10sd5v_wd_u2r_new
bash tools/probe/r10sd5repro/ct8rows.sh results/golden_surelog.csv   /tmp/r10sd5v_sl_new.csv
bash tools/probe/r10sd5repro/ct8rows.sh results/gate_uhdm2rtlil.csv  /tmp/r10sd5v_u2r_new_tf.csv
# gate 5
SELFCHECK=1 SELFCHECK1=1 bash tools/probe/r10sd5repro/byteverify.sh \
    /tmp/r10sd5v_wd_sl_new /tmp/r10sd5v_wd_sl_pris
```

**Pin, verified exhaustively rather than asserted.** Across all four workdirs
(1573 + 1573 + 1462 + 1462 `cmds.txt`), the only `build/slang-uhdm` paths that
appear anywhere are `/tmp/wt_r10sd5v/build/slang-uhdm` and
`/tmp/wt_r10sd5vpris/build/slang-uhdm`, each confined to its own tree:

```sh
find /tmp/r10sd5v_wd_* -name cmds.txt -print0 |
  xargs -0 grep -ho '[^ ]*build/slang-uhdm' | sort -u
```

`results/*.csv` were **read only** (`git status --porcelain -- results` = 0). No
`git stash`. slang was not patched. Both surelog CSVs (patched vs pristine) are
byte-**IDENTICAL**, as are both u2r CSVs — the movers live entirely inside rows
whose status and dump column do not move, which is exactly why gate 5 exists.

### CANARIES — all re-run

| check | required | MY measurement |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names **7** |
| `canaries.sh` u2r | at baseline | **ok=8 changed=0 absent=0**, unknown-names **25** |
| `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` | baseline FIRST, mode-matched | **ok=58 changed=0 absent=0 unknown-patterns=1**, **PASS** |
| `ctcan2.sh` u2r `EXPECT_UNKNOWN=6` | testflags-only CSV | **ok=1 changed=0 absent=0 unknown-patterns=6**, **PASS** |
| `canaudit.sh` (sd4 F6-fixed) | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, **PASS** |
| `InterfaceModPort`, `BlackParrotComplex` BY NAME | at baseline | **CMP_EQUAL in BOTH modes**, cmp.log **0 lines / 0 heads** on both binaries |

---

## 2. THE TARGET — REPRODUCED

`rowheads.sh` over my two surelog workdirs, LHS always golden, heads counted
`grep -c '^LHS:'`:

| row | pristine `511725d` | delivered | heads |
|---|---|---|---|
| **`default/SeqDriver`** | **1 416 183** | **43** | 1 → 1 |
| **`testflags/SeqDriver`** | **1 416 183** | **43** | 1 → 1 |
| `default/BuildUVMPkg` | 94 | 94 | head **byte-identical** |
| `testflags/BuildUVMPkg` | 94 | 94 | head **byte-identical** |
| `default/SimpleUVM` | 50 | 50 | head **byte-identical** |
| `testflags/SimpleUVM` | 50 | 50 | head **byte-identical** |
| `default/Scoreboard` | 50 | 50 | head **byte-identical** |
| `testflags/Scoreboard` | SKIP-NOFILE (SLANG_REJECT) | SKIP-NOFILE | counted as SKIP, never as agreement |

Pristine head: `LHS: <null>` / `RHS: package uvm_pkg` — the brief's wall,
confirmed at the stated size on both rows. New head: `LHS: <null>` /
`RHS: class_var(uvm_pkg::uvm_default_table_printer)@610:19-610:52`, 43 lines,
one head, both rows.

**The new head is PRE-EXISTING, and I checked rather than assumed it.** That
`class_var` is listed under `package uvm_pkg`'s **own** `Variables`, which this
patch never writes. Count of that object in the whole-design dump: **golden 12,
pristine 15, delivered 15** — unchanged by the patch, so R1 was behind the wall,
not created by removing it.

---

## 3. THE LAW AND THE GRID — CELL FOR CELL, ON MY BINARIES

`ct4arm.sh`-equivalent per-cell runs, LHS always golden, `sed 1d` both dumps,
private scratch per arm, both binaries.

| cell | GOLDEN (`ct5cls`) | PRIS | NEW | cmp pris → new | ours dump pris → new (golden) |
|---|---|---|---|---|---|
| **`v1` wildcard import, anon type** | `own 2`, `inst=<null> 2`, `NAME 2` | `SHARED 1`+`own 1`, `inst=p1 1`, `other 1` | **== GOLDEN** | **CMP_FAIL → PASS_CMP** | 728 → **752** (760) |
| **`v3` no initializer (span control)** | `own 2`, `<null> 2`, `NAME 2` | `SHARED 1`+`own 1`, `inst=p3 1`, `NAME 2` | **== GOLDEN** | **CMP_FAIL → PASS_CMP** | 704 → **722** (730) |
| **`v5` container is a MODULE** | not scored by `ct5cls` (R5) — **scored here from the dump, §5 F4** | shares the package object | **== GOLDEN** | **CMP_FAIL → PASS_CMP** | 706 → **732** (738) |
| `v4` explicit `import p::v` | `own 2`, `<null> 2`, `NAME 2` | `SHARED 1`+`own 1`, `inst=p4 1` | **== GOLDEN** | CMP_FAIL → CMP_FAIL, head **byte-identical** after path-normalisation | 736 → **762** (830) |
| `v2` pkg-homed typedef | `own 2`, `<null> 1` + **`inst=p2 1`** | `own 1` (we emit a NET; arm never runs) | unchanged | CMP_FAIL → CMP_FAIL, cmp.log **and** dump **byte-identical** | 736 → 736 (957) |
| **`v6` NEGATIVE CONTROL** (no import) | `own 1`, `inst=p6 1`, `NAME 1` | identical | **identical** | CMP_FAIL → CMP_FAIL, cmp.log **and** dump **byte-identical** | **707 → 707** (777) |

Every dump figure above matches the implementer's table to the line. `v6` holds:
the fix provably does nothing where nothing was imported.

**The law is READ, not inferred.** Golden's `v1` class listing, verbatim:

```
\_class_defn: (q1::c1)
  |vpiVariables:
  \_bit_var: (q1::c1::v1), line:5:7, endln:5:9        <- NAME span (5 + len("v1"))
    |vpiTypespec:
    \_ref_typespec: (q1::c1::v1)                      <- own, fullname = <class>::<name>
      |vpiActual:
      \_bit_typespec: , line:5:3, endln:5:6           <- own, NO vpiInstance
    |vpiExpr:
    \_constant: , line:5:12, endln:5:13               <- own, re-parented to the copy
```

Ours (delivered) is **identical, field for field**, including the absent
`vpiInstance`. The package's own listing keeps `bit_var (p1::v1)` at the
declarator span 5:7-5:13 with the package stamp.

### SeqDriver census (`ct5cls`, 1206 entries per side, my three databases)

| cell | GOLDEN | PRIS | NEW |
|---|---|---|---|
| entries | 1206 | 1206 | 1206 |
| `V=own` / `V=SHARED` | **1206 / 0** | 1041 / **165** | **1206 / 0** |
| `span=NAME` / `other` | **1206 / 0** | 1126 / 80 | **1206 / 0** |
| `T=own` / `A=own` | 1202 / 1202 | 1040 / 1040 | 1205 / 1205 |
| `E=own` | **315** | 230 | **315** |
| **`X own named INST`** | **63** | **63** | **63** |
| `X SHARED anon INST` / `named INST` / `anon null` | — | 45 / 115 / 5 | **0 / 0 / 0** |
| `inst=` total (adpcm_pkg + uvm_pkg) | 63 (42+21) | 223 (49+174) | 63 (49+14) |

`X own named INST 63` agreeing **before** the patch is the measurement that
forbids the tempting law, and it survives the patch untouched. The residual
split (42/21 golden vs 49/14 ours) is **pre-existing**: pristine is 49 as well.

### Nothing was un-stamped — the safety check the null demands

Whole-design `|vpiInstance:` dump lines, `default/SeqDriver`:

```
GOLDEN 16759      PRISTINE 13014      DELIVERED 13024
```

The count went **UP by 10, toward golden**. An unconditional null that had
reached a shared package object would have driven it **down**. It did not.

---

## 4. THE MOVERS — PREDICTION AND MEASUREMENT, BOTH RE-RUN

`ct5pred` re-run by me over **my pristine sweeps**, before reading the byte
verifier's answer:

```
./default/Scoreboard-59431470   shared=66   sharedInst=64   entries=1103 classes=336
./default/SeqDriver-32af76aa    shared=165  sharedInst=160  entries=1206 classes=336
./default/SimpleUVM-1dc93a62    shared=66   sharedInst=64   entries=1094 classes=332
./testflags/SeqDriver-32af76aa  shared=165  sharedInst=160  entries=1206 classes=336
./testflags/SimpleUVM-1dc93a62  shared=66   sharedInst=64   entries=1094 classes=332
-- databases=953  RESTORE-FAIL=0  PREDICTED-MOVERS=5
-- databases=1358 RESTORE-FAIL=0  PREDICTED-MOVERS=0        (uhdm2rtlil)
```

The byte verifier then reported **exactly those five paths and no others**, and
**0 / 1358** on uhdm2rtlil. Predicted set == observed set, on both corpora,
with zero restore failures.

**MOVER RULE — size delta, and 3 reps on both binaries.**

| row | pristine | delivered | Δ |
|---|---|---|---|
| `default/SeqDriver` | 17 962 880 | 18 005 485 | **+42 605** |
| `testflags/SeqDriver` | 17 963 307 | 18 005 916 | **+42 609** |
| `default/Scoreboard` | 11 123 420 | 11 138 388 | **+14 968** |
| `default/SimpleUVM` | 11 119 038 | 11 133 735 | **+14 697** |
| `testflags/SimpleUVM` | 11 119 350 | 11 134 052 | **+14 702** |
| `default/BuildUVMPkg` (control) | 11 097 834 | 11 097 834 | **0** |

Re-emitted from its own source with its own argv, 3 reps per binary:
`18 005 485 ×3` (delivered) and `17 962 880 ×3` (pristine) — size-stable, and on
serial re-runs md5-stable too, matching the sweep's own hashes. **All five
movers have nonzero size delta: REAL by the standing law.**

**Per-shape, by MULTISET, ADDED and REMOVED separately** (my own line-level
attribution, `default/SeqDriver`, `sed 1d` both dumps):

```
TOTAL ADDED 3898   REMOVED 163          (add-dominant, as a clone must be)
vpiParent 610/0   class_var 298/113   vpiFullName 370/0   ref_typespec 350/0
vpiName 345/0     class_defn 285/0    class_typespec 240/0  string_var 75/30
distance to GOLDEN : 364 639 -> 361 278   (-3 361)
shapes IMPROVED 39   WORSENED 4   biggest gains vpiParent -610, class_var -375,
vpiName -341, vpiFullName -290, class_defn -285, class_typespec -222
worst losses ref_obj +25, ref_typespec +20, vpiOpType +1, array_typespec +1
```

Every figure in that block equals the implementer's. Every mover converges:

| row | msdist pristine | msdist delivered |
|---|---|---|
| `SeqDriver` | 364 639 | **361 278** |
| `SimpleUVM` | 142 411 | **141 293** |
| `Scoreboard` | 132 771 | **131 537** |

---

## 5. FINDINGS

### F1 — SUBSTANTIVE, LATENT: the coded law is unconditional and cell `v2` refutes it

*Command:* `/tmp/r10sd5v_ct5cls <v2 golden db>` and
`bash ct4arm.sh grid5/v2_named_pkg_typedef.sv`.

The code comment states the law as universal — *"its own actual typespec, and
**THAT TYPESPEC NEVER CARRIES A `vpiInstance`**"* — and the code implements it
unconditionally (`at5->Instance(nullptr)`). The pass's own cell `v2` measures the
opposite on golden:

```
v2 GOLDEN, class c2's listing:
  bit_var v2   V=own T=own A=own E=own  ats=6:11-6:20   inst=p2
                                        kind=bit_typespec/named/INST
```

That entry is the **import copy** (`c2` declares only `int own2`), it is golden's
own object, and golden **stamps `p2` on it** because its actual typespec is the
package-homed *named* typedef `t2`. So "the copy's typespec never carries an
instance" is false as stated.

It costs nothing today, and I verified why: we emit that shape as a `logic_net`,
so it never reaches the arm — `v2`'s cmp.log **and** dump are byte-identical
between the two binaries (path-normalised). The consequence is for the next pass:
the report's **R4 says fixing the net defect "will *feed* this arm, so the two
compose"** — measured, it will feed this arm a shape the arm answers **wrongly**.
The discriminator is already computed by this pass's own instrument
(`ct5cls`'s `named` / `pkgTs` columns). **Not a gate failure — 0 movers today,
proven by the byte verifier — but the README's §9.3 asserts the universal law
while its own `v2` row measures the counterexample.** Ranked R1 of my residues.

### F2 — the census-agreement count is wrong (arithmetic, not substance)

*Command:* `/tmp/r10sd5v_ct5cls <golden|new SeqDriver db> -q | sed -n '/SUMMARY/,$p'`, diffed.

README §3.1: *"30 census rows; **24 are EXACT**"*, and §8 R2/R3 describe *"6 rows
that still differ"*. Measured: the tally has **35 distinct rows**, of which
**25 are exact and 10 differ** (`A=none`, `A=own`, `T=none`, `T=own`,
`X own anon null`, `X own named null`, `inst=adpcm_pkg`, `inst=uvm_pkg`,
`kind=enum_typespec/named/null`, `kind=none/anon/null`). The **substance** is
right — all 10 are driven by the same two pre-existing residues (R2 = the 7-object
instance-identity split; R3 = the 3 enum-typespec entries), and I confirmed both
are pre-existing by reading the pristine tally (adpcm_pkg **49** in pristine *and*
delivered; `enum_typespec/named/null` **4** in both). Only the row count is wrong.

### F3 — `ct5pred` shares `ct5cls`'s module blind spot; "prediction exact" is weaker than it reads

*Command:* `/tmp/r10sd5v_ct5cls /tmp/r10sd5v_gridnew_v5_class_in_module/slang.uhdm`
→ `class_defns=8 rows=0`, exit **5**.

The report's R5 records that `ct5cls` does not cover the module-container arm.
The same walk is inside **`ct5pred`** (`pkgClasses(AllPackages/TopPackages)` +
`AllClasses()`), and a class declared inside a **module** is in none of those —
measured: `work@m5::c5` is absent from `AllClasses()` in `v5`. So the predictor
**cannot** see a module-contained sharer, and "predicted 5, observed 5" does not
establish that the predictor is complete; it establishes that no such design was
in the corpus. The byte verifier (0 unpredicted movers on 2311 databases) is what
actually carries that claim. R5 should be widened to name `ct5pred` too.

*Credit where due:* `ct5cls`'s empty-population guard fires correctly (exit 5,
`REFUSING TO REPORT`), so the empty score never reads as agreement.

### F4 — I closed R5 for `v5` by scoring the module arm from the dump

*Command:* `sed -n '556,600p' /tmp/r10sd5v_gridpris_v5_class_in_module/o.dump`
vs the same range of the delivered and golden dumps.

```
PRIS      class_defn (work@m5::c5) |vpiVariables: \_int_var: (p5::v5), 5:7-5:13   <- the PACKAGE's object
DELIVERED class_defn (work@m5::c5) |vpiVariables: \_int_var: (work@m5::c5::v5), 5:7-5:9
                                     own ref_typespec (work@m5::c5::v5), own int_typespec, own constant
GOLDEN    class_defn (work@m5::c5) |vpiVariables: \_int_var: (work@m5::c5::v5), 5:7-5:9   ... identical
```

The module arm takes the copy, with the NAME span and the `<class fullname>::<name>`
naming, **cell-for-cell equal to golden** — so `v5`'s `PASS_CMP` is a scored
result, not an unscored one. The `only23` (explicit-import) path is likewise
scored, by `v4`.

### F5 — two quoted byte sizes are path-dependent and do not reproduce

*Command:* `stat -c%s <arm>/cmp.log`, with and without normalising the scratch
directory name out.

README §5 quotes `v2`'s head as **3578 B** and `v4`'s as **1950 B**. `cmp.log`
embeds the arm's scratch path, so those absolute sizes are properties of the
implementer's directory names: at my paths I measure 3602/1962 raw and 3498/1910
normalised. **The identity claims they support all hold** — after normalisation
`v2` and `v6` are byte-identical between the two binaries in *both* `cmp.log` and
`o.dump`, and `v4`'s head is byte-identical. Quote line counts, not byte sizes,
for anything produced inside a scratch directory.

### F6 — "not dispatched by any driver" is true of the probe directory, not of the corpus

*Command:* `grep -c '^UnsignedParam,' results/golden_surelog.csv` → **2**.

All four fenced names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) are **rows of the surelog corpus** and are therefore exercised by any
full-corpus gate sweep — the implementer's and mine alike, and by the committed
baseline itself. `canaudit`'s assertion is that no *driver in the probe
directory* names them, and that passes (**FENCE-BREACH=0**). The rows are
unchanged (covered by `ct8rows` = 0 differing rows). No action; recorded so the
sentence is not read as "these tests were not run".

### F7 — the `cmds.txt` pin claim, made precise

*Command:* see §1. **1523 of 1573** surelog `cmds.txt` and **1458 of 1462** u2r
`cmds.txt` contain a binary path; the remainder are golden-cache-only entries
that name none. The stronger, checkable statement — and the one that matters — is
that **no `cmds.txt` in any of the four trees names any binary other than the two
intended**, each in its own tree. That holds.

---

## 6. BOUNDARIES — MEASURED, NOT ARGUED

The implementer defends the sd4 boundary "by construction" (`TaskFuncEmit.cpp`
is not in the file set). That is **not sufficient**: this patch changes the class
import listing, and the q-cells contain packages, classes and imports. So I ran
all three grids on **both** binaries and compared the path-normalised dumps.

| grid | cells | result |
|---|---|---|
| **sd4/sd5 q-grid** (`q1…q11`, `qv12`, `qv13`) — `§ classHomedTypeTsNoPkgInstance4` | **13** | **13/13 dump byte-IDENTICAL pris vs new**, every verdict unchanged (q9/q11/qv12/qv13 `CMP_FAIL` at 52/52/90/56 lines on both; the rest `PASS_CMP`) |
| **sd1 b-grid** (`b1…b28`) — `§ classTdSpecParamsForeignHome1` | **28** | **28/28 dump byte-IDENTICAL**, every verdict and every cmp line count unchanged |
| **sd3 g-grid** (`g1…g8`) — `§ retNameLocalInstIsHomeNotClass3` | **8** | **8/8 dump byte-IDENTICAL**, every verdict unchanged |

**sd2-verifier F3** (`design.Parameters` NULL vs 45 on SimpleUVM/Scoreboard) —
**undisturbed, measured** on the two designs that actually move:

```
SimpleUVM  pris design.Parameters=NULL AllPackages=2 TopPackages=2 AllClasses=4
SimpleUVM  new  design.Parameters=NULL AllPackages=2 TopPackages=2 AllClasses=4
Scoreboard pris design.Parameters=NULL AllPackages=3 TopPackages=3 AllClasses=4
Scoreboard new  design.Parameters=NULL AllPackages=3 TopPackages=3 AllClasses=4
```

**LIVE-PASS COLLISION — confirmed clean, and CARRIED FURTHER THAN CLAIMED.**
`r10uvm73` (`61d5e36`) and `r10earl44` (`dcf67d7`) both landed above this BASE.
`r10earl44` added 127 lines at `ModuleEmit.cpp:2893`, above all of this pass's
hunks. The patch applies to `HEAD 61d5e36` with `git apply` **clean**, hunks 2
and 3 at offset **+127**, no textual overlap and no `.rej`. The implementer
stopped at "applies". I went further and **built both sides at HEAD**
(`/tmp/wt_r10sd5vhead` patched md5 `a0213616a9f89c23f2db57c441e2d03d`,
`/tmp/wt_r10sd5vheadpris` pristine md5 `98b4d0a565ccbd8054182fccba9b3c2d`, BASE
`61d5e36` grep-checked **=1** in both, ` error:` **0** in both):

| at `HEAD 61d5e36` | pristine | patched |
|---|---|---|
| `default/SeqDriver` cmp lines | **1 416 141** | **43** |
| head | `<null>` / `package uvm_pkg` | `<null>` / `class_var(uvm_pkg::uvm_default_table_printer)` |
| database size | 17 962 716 | 18 005 301 (**+42 585**) |
| goldens | — | **23 PASS / 0 FAIL** |

So the fix survives both live passes: it still clears the wall on top of them,
to the same 43-line head, and the goldens hold. (The pristine wall is 1 416 141
at HEAD rather than 1 416 183 — `r10uvm73` shortened that subtree by 42 lines —
which is itself a reminder to re-measure a baseline before quoting it.)

**Patch hygiene.** 50 files: `src/ModuleEmit.cpp` (+85 −1) and 49 files under
`tools/probe/r10sd5repro/`. Nothing outside `src/`, `include/`,
`tools/probe/r10sd5repro/`. No `results/`, no slang patch, no
`README.verifier.md` (correctly left to me — the string appears only once in the
patch, inside prose). All 24 carried-forward instruments (`byteverify.sh`,
`ct8rows.sh`, `ctcan2.sh`, `canaudit.sh`, `canaries.sh`, `msdist.sh`,
`ct4*`, `census.py`, `slots.py`, `cells.py`, `dumptree.py`, `TAP.md`, …) are
**byte-identical to `r10sd4repro/`'s**, so nothing was quietly re-tuned.

**The change is surgical and I confirmed it is the only one.** `grep -n
'vars23->push_back'` finds two sites: the import arm (wrapped) and the class's
**own** members at `:4304` (correctly left sharing nothing to clone). `cd` is the
importing `class_defn` from `classDefnMap`; `s` is the serializer. `DeepClone`
is genuinely unusable here (`UhdmExporter.h`:490 recurses through `Typedef_alias`).

---

## 7. EMPTY PRODUCT HUNT

| candidate | verdict |
|---|---|
| grid cells that produce no golden or no ours database | **none** — all 6 grid5 cells, all 13 q-cells, 28 b-cells and 8 g-cells produced both sides on both binaries |
| `ct5cls` scoring an empty population | fires its guard: `v5` → `rows=0`, `REFUSING TO REPORT`, **exit 5**. Not silent agreement. Scored instead from the dump (F4) |
| `ct5pred` skipping unreadable databases | **RESTORE-FAIL=0** on 953 and on 1358 |
| `byteverify.sh` comparing mismatched trees | **PATH_SETS_IDENTICAL** on both corpora; SELFCHECK **1357/1358** and **952/953**; SELFCHECK1 **1** and **6** — the comparator provably sees a single changed byte |
| `rowheads.sh` reading a missing side as perfection | `testflags/Scoreboard` printed **SKIP-NOFILE** and counted, never as a pass |
| `canaries.sh` typo'd name reading green | guard present, **unknown-names 7 / 25** reported and matched to the documented cross-corpus sets |
| `ct8rows.sh` fed an unfiltered u2r CSV | the trap was avoided: the fresh CSV was filtered to **testflags (731 rows)** before comparison, else all 731 default rows read as ADDED |
| **my own runner** | I hit one: my first boundary-grid loop globbed `tools/probe/r10sd5repro/grid/*.sv` in the **main tree**, where that directory does not exist, and printed `IDENTICAL` for a cell that produced nothing. Re-run against the worktree path; the 13 q-cells above are the real measurement. Recorded because it is the exact failure this section exists to catch. |

---

## 8. RANKED RESIDUES (mine, after verification)

1. **R1′ = my F1.** The unconditional instance-null on the copy's actual
   typespec is not golden's general answer (`v2`: golden stamps `p2` on a class
   copy whose actual typespec is a package-homed named typedef). Inert today;
   becomes wrong the moment R4 below is fixed. The discriminator is already
   measured by `ct5cls`. **Fix R4 and this together, not R4 alone.**
2. **R2′ — the new SeqDriver head, 43 lines, both rows** (implementer's R1):
   `<null>` / `class_var(uvm_pkg::uvm_default_table_printer)@610:19`. Verified
   **pre-existing** (dump count 15 on both binaries, golden 12). Largest item
   left on these rows and four orders of magnitude cheaper than the wall.
3. **R3′ — 7 class-listing typespecs stamped `adpcm_pkg` where golden stamps
   `uvm_pkg`** (total right at 63/63; split 42/21 vs 49/14). Verified
   **pre-existing** (pristine 49). A ready-made 7-object target.
4. **R4′ — imported package-typedef'd variable emitted as `logic_net`, not a
   variable** (`grid5/v2`). Verified: the arm never runs, dump and cmp.log
   byte-identical. Composes with R1′.
5. **R5′ — `ct5cls` AND `ct5pred` are both blind to the module-container arm**
   (F3). Widen the walk before either is quoted on that arm again.
6. **R6′ — 3 entries carry an `enum_typespec` where golden carries none.**
   Verified pre-existing.
7. **R7′ — `ct5deep` must never be used as a sharing test** (the implementer's
   own refutation §9.1, which I did not need to re-derive: its `emplace`-keeps-
   first pairing holds the ALL-view copy while shared entries share the TOP-view
   copy). Kept with its header warning; correct disposition.
8. **R8′ — the TOP-view instance deficit** (golden 16 759 vs ours 13 024).
   Untouched; this pass moved it **+10 toward golden** and damaged nothing.
9. **R9′ — `v4`'s residual head** in package `q4`'s own listing, independent of
   the class copy.

---

## 9. WHAT I DID NOT TAKE ON TRUST

* Both binaries **rebuilt from scratch in fresh worktrees**; both md5s reproduce.
* All four sweeps **re-run by me**, not read from the implementer's workdirs.
* The census, the grid, the movers, the per-shape multiset, the msdist figures
  and the size deltas **re-measured from my own databases**.
* The sd4 / sd1 / sd3 boundaries **measured on 49 grid cells**, not argued from
  the file set.
* The new head's **pre-existence** measured, not assumed.
* The "nothing was un-stamped" safety property measured directly
  (`vpiInstance` 13 014 → 13 024 against golden 16 759).
* The implementer's §9.1 refutation of its own `ct5deep` control is **correct
  and material** — I confirmed the pairing defect by reading the tool — and it is
  to their credit that they caught it in a session they inherited.

**Sweep workdirs deleted after measurement** (`/tmp/r10sd5v_wd_*`, ~2 GB), along
with my per-arm scratch directories. My worktrees are `/tmp/wt_r10sd5v`,
`/tmp/wt_r10sd5vpris`, `/tmp/wt_r10sd5vhead`, `/tmp/wt_r10sd5vheadpris`.
