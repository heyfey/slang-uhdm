# r10uvm72 — VERIFIER'S RECORD — `§ inheritedNameBindsPkgFn72`

**VERDICT: PASS (with 4 residual findings, none blocking; 1 is a defect in a
probe instrument, not in production code).**

Every load-bearing number in the implementer's report was **reproduced
independently** on binaries I built myself from a fresh `1251d66` worktree. The
389-line head is **cleared on all three target rows**, the SimpleUVM bind census
matches golden **cell for cell**, and the whole 1632-database corpus moves
**exactly 7 databases, all four UVM tests, none of them `CMP_EQUAL`**.

I did **not** re-cut `src/ExprEmit.cpp`. The production diff is correct as
delivered, and leaving it byte-identical keeps the binary md5 that every
measurement below was taken on. `/tmp/r10uvm72.verified.patch` therefore carries
the implementer's `src/ExprEmit.cpp` **unchanged**, plus this file, three new
verifier arms, and one hardening fix to a probe script (finding 1).

---

## 0. WHAT I BUILT, AND THE ANCHOR THAT MATTERS

The main tree had moved to `acc7e56` by the time I ran — past the `38f308e` the
implementer noted — so, like them, I used **no main-tree anchor at all**.

| worktree | commit | binary md5 |
|---|---|---|
| `/tmp/wt_v72pris` | `1251d66` pristine | `caf3519f3a3e8d830b72321859c281fb` |
| `/tmp/wt_v72` | `1251d66` + `/tmp/r10uvm72.patch` | `a7f32de3b28ea975a86828cbf276168f` |

**Both md5s reproduce the implementer's exactly.** That is the strongest anchor
available here and it is stronger than a main-tree comparison would have been:
two independent `-j 2` Release builds of the same source produced bit-identical
binaries, so the delivered patch *is* what produced the delivered numbers.

The patch applied to a **fresh pristine `1251d66`** with `git apply` and no
fuzz, no whitespace warnings, and touched exactly `src/ExprEmit.cpp` plus
`tools/probe/r10uvm72repro/`.

```bash
git worktree add --detach /tmp/wt_v72 1251d66
cd /tmp/wt_v72 && git apply --whitespace=nowarn /tmp/r10uvm72.patch   # clean
md5sum /tmp/wt_v72/build/slang-uhdm /tmp/wt_v72pris/build/slang-uhdm
```

**Both pristine sweeps reproduce the committed baseline CSVs byte for byte**
(0 differing ROWS on 731 and on 1588), so the base is anchored on the corpus and
not merely on a hash.

---

## 1. THE FIVE GATES, RE-RUN INDEPENDENTLY

| gate | implementer | **mine** | verdict |
|---|---|---|---|
| **1 BUILD** | link line read, md5 asserted separately, 32-hex | same, both binaries, md5s **identical to theirs** | ✅ |
| **2 GOLDENS** | 23/0; `/bin/false` 0/23 | **23/0**; `/bin/false` **0/23** | ✅ |
| **3 u2r testflags** | 679/50/2, dump 496/183/52, 0 rows | **679/50/2**, dump **496/183/52**, **0 differing ROWS** | ✅ |
| **4 surelog both** | 469/11 + 465/8, DEFER 5/5, FAIL 25/23, 0 rows | **identical**, both histograms unchanged, **0 differing ROWS** | ✅ |
| **5 BYTE VERIFIER** | surelog 7/953, u2r 0/679 | **7/953**, **0/679**; SELFCHECK 952/953 + 678/679; SELFCHECK1 **8** and **1** | ✅ |

`GOLDEN_DEFER` was **UNSET** at every launch (echoed `[UNSET]`). `SLANG_UHDM`
was exported explicitly and **verified through `cmds.txt`** — the harness
silently defaults it to the main-tree binary, which is now a *different commit*,
so this check was not optional:

```bash
grep -o '/tmp/wt_v72[a-z]*/build/slang-uhdm' <workdir>/*/*/cmds.txt | sort -u
```

### The head — the headline claim

`rowheads.sh` on my own two workdirs:

| row | pristine | **final** | head object |
|---|---|---|---|
| SimpleUVM/default | **389** | **50** | `function (uvm_pkg::uvm_report_enabled)` → `logic_var (uvm_pkg::uvm_sequence_request::request)` @1771:34 |
| SimpleUVM/testflags | **389** | **50** | same |
| Scoreboard/default | **389** | **50** | same |
| BuildUVMPkg/{default,testflags} | 17 | **17** | unchanged — **the implementer's correction is right** |
| SeqDriver/{default,testflags} | 1414833 | 1416169 | same head object |

The head is **genuinely cleared, not pushed deeper**: `uvm_report_enabled` goes
from **122 mentions to 0** in the final cmp log on all three rows. The three new
heads are **byte-identical to each other** with ids normalised.

I confirm the implementer's own correction: **BuildUVMPkg's control is 17, not
58**, and this pass does not move it. The "58" they retracted was pass 71's
number.

### SeqDriver's +1336 is not a regression

Its head is the same pre-existing `package uvm_pkg` object before and after, its
CSV row is byte-identical to baseline, and the mover analysis shows its diff
contains **only added `vpiFunction` links**. A head is not a distance.

---

## 2. THE CENSUS AND THE MOVERS — REPRODUCED TO THE UNIT

### SimpleUVM/default, every full print of `uvm_report_enabled`

| bind target | golden | pristine | **final** |
|---|---|---|---|
| `uvm_pkg::uvm_report_enabled` (free fn) | 1079 | 925 | **1079** ✅ |
| `uvm_report_object::uvm_report_enabled` | 1 | 8 | **1** ✅ |
| `uvm_sequence_item::uvm_report_enabled` | 1 | 8 | **1** ✅ |
| UNBOUND | 17 | 157 | **17** ✅ |
| **total prints** | **1098** | **1098** | **1098** |

I then went one step further than the histogram and compared the **per-site**
tables (status + target + span + full ancestor chain, sorted):

```
GOLDEN vs FINAL: 30 differing line-sides — ALL of them UNBOUND method_func_call
                 span-only; 0 lines containing "BOUND:"
strip the spans: GOLDEN == FINAL exactly — EVERY BIND TARGET MATCHES
```

So "cell for cell" survives the stronger test: **every one of the 1098 call
sites binds what golden binds.** The only residue is 15 receiver-qualified
`method_func_call` endln spans — `§ retNameRecvCollapse69`'s family, unbound on
both sides, pre-existing (residue 3).

### Movers — predicted first, then measured

**Exactly 7 / 953 surelog, exactly 0 / 679 u2r**, and by name:
`default/{SimpleUVM,Scoreboard,SeqDriver,BuildUVMPkg}`,
`testflags/{SimpleUVM,SeqDriver,BuildUVMPkg}`. **No `CMP_EQUAL` database moved a
byte, in either corpus.** `SELFCHECK1` = **8** (7 real + 1 corrupted) and **1**
(0 real + 1) — both negative controls fire.

### Per-shape multiset, and the accounting closes

| mover | `\|vpiFunction:` ADDED | REMOVED | target ADDED | target REMOVED | OTHER | size delta |
|---|---|---|---|---|---|---|
| default/SimpleUVM | 336 | **0** | 360 | 24 | **0** | +648 |
| default/Scoreboard | 332 | **0** | 352 | 20 | **0** | +644 |
| default/SeqDriver | 334 | **0** | 355 | 21 | **0** | +652 |
| default/BuildUVMPkg | 281 | **0** | 296 | 15 | **0** | +547 |
| testflags/SimpleUVM | 336 | **0** | 360 | 24 | **0** | +648 |
| testflags/SeqDriver | 334 | **0** | 355 | 21 | **0** | +652 |
| testflags/BuildUVMPkg | 281 | **0** | 296 | 15 | **0** | +547 |

* **`|vpiFunction:` REMOVED = 0 on all seven — no bind was ever lost.** Verified
  by me directly on the multiset diffs.
* **Only two line shapes move**, on every mover. OTHER = 0.
* `360 = 336 + 24`, `352 = 332 + 20`, `355 = 334 + 21`, `296 = 281 + 15`.
* SimpleUVM's head target `line:133:1, endln:140:12` is added **exactly 154 =
  140 (defect A) + 14 (defect B)**.
* **All 140 removed targets, pooled, are CLASS METHODS — not one free function
  lost a link.** Five names only: `uvm_reg::get_full_name` 63,
  `uvm_sequence_item::uvm_report_enabled` 43,
  `uvm_report_object::uvm_report_enabled` 23, `uvm_object::get_name` 7,
  `uvm_policy::get_active_object_depth` 4. These equal the implementer's
  split figures (45+18, 37+6, 23, 7, 4).

### Design-wide bind census (SimpleUVM/default, every name)

Total `vpiFunction` links **golden 2931 / pristine 2583 / final 2919** — the
implementer's figures exactly. Target rows where golden and final disagree:
**13**, and **12 of them are byte-identical to the pristine disagreement**
(pre-existing). Controls hold in the wild: inherited `uvm_reg::get_full_name`
**0/9/0**, `uvm_object::get_name` **0/1/0**, own-class
`uvm_port_base::get_full_name` **4/4/4**. The single row that moved without
landing is `uvm_report_fatal` **185 → 223 vs golden 224** — residue 2, disclosed.

---

## 3. THE GRID — REPRODUCED, PLUS THREE ARMS OF MY OWN

`a1_shadow.sv`: golden 13 `fe` prints, ours 13. **Final: `CELLS IDENTICAL TO
GOLDEN` (diff empty).** Pristine differs on **exactly** the two in-body
inherited cells (`d_inbody`, `g_inbody`), bound to `p1::shbase::fe`. Reproduced
verbatim.

`a2_site.sv`: cmp head depth **117 → 56**. Every claimed cell reproduces,
including the two that make the law falsifiable:

* **`u_lonely`** — inherited name, no free twin: pristine wrongly bound
  `p2::shbase::lonely`, **final is UNBOUND, matching golden.** The law is not
  "bind something".
* **`m_shadowed`** — module-level free fn: **wrong object → null**, golden binds
  `work@top.mfe`. A **partial**, correctly reported as one (residue 1).

### My three new arms

**`v1_pos.sv` — THE POSITION AXIS, which neither shipped arm varies.** Every
call in `a1`/`a2` sits inside an `if (...)` condition, yet defect B *is* a
position-dependence bug. I pinned six positions (assignment RHS, `if` cond,
`case` cond, call argument, `return`, `while` cond):

```
FINAL:    golden 6 prints, ours 6 — CELLS IDENTICAL TO GOLDEN
PRISTINE: wrong on EXACTLY the if_stmt and case_stmt cells
```

This independently confirms defect B's mechanism *and* proves the widened gate
does **not** regress the four positions that were already correct.

**`v2_walk.sv` — CROSS-PACKAGE, and it REFUTES part of the stated law**
(finding 2 below).

**`v3_nest.sv` — the OOB / OWN-CLASS cell with a package free twin**, the one
way `inheritedCall72` becomes true with no inheritance at all (`curSubOob9`
alone). **Identical to golden on both binaries** — no regression. (A *nested*
class cell was attempted and is **not constructible**: SystemVerilog rejects
`call to non-static member function without object handle from nested class`, so
the helper's multi-pop `while` is defensive but unreachable for that shape.)

---

## 4. FINDINGS, RANKED

### FINDING 1 — `ct72predict.py` silently produces WRONG numbers when run concurrently *(fixed in this patch)*

The predictor wrote to a **hard-coded** scratch path:

```python
tmp = '/tmp/r10uvm72_predict.dump'      # and tmp + '.2'
```

Two invocations at once — the surelog corpus and the uhdm2rtlil corpus, the
obvious way to use a two-core budget — overwrite each other's dump between the
write and the scan. **Measured, not theorised**: run concurrently the same
script on the same pristine workdirs gave **5/953 and 1/679**; run **serially**
it gave the correct **7/953 and 0/679**.

```bash
python3 ct72predict.py /tmp/v72_wd_sl_pris    # serial: 7/953, the right 7 names
python3 ct72predict.py /tmp/v72_wd_u2r_pris   # serial: 0/679
```

**The fix is demonstrated, not asserted.** Re-run the two corpora **at the same
time** with the per-process path in place and they now both come out right:

| run | surelog | u2r |
|---|---|---|
| concurrent, **before** the fix | **5 / 953** ✗ | **1 / 679** ✗ |
| serial, before the fix | 7 / 953 ✓ | 0 / 679 ✓ |
| **concurrent, after the fix** | **7 / 953** ✓ | **0 / 679** ✓ |

and the 7 names in the concurrent post-fix run are exactly the 7 `byteverify.sh`
found.

**This cost me a false alarm against the implementer, and it is exactly the
failure mode this campaign fears: a gate instrument returning a wrong answer
with no error.** It is a *probe* defect only — production code is untouched by
it, and the implementer's reported prediction is **correct** (verified serially,
and it matches the actual movers by name). Fixed here: the path is now
per-process and cleaned up. The standing rules already require PASS-PREFIXED
scratch names; this script predated that discipline.

### FINDING 2 — the LAW's "walk starts at the CALLER, never the callee" is REFUTED cross-package (pre-existing; new wrong bind in one sub-shape)

`v2_walk.sv` puts the base class in package `qa` and the caller in package `qb`,
with a free `ge` in both. **Golden binds `qa::ge` — the CALLEE's package — in
both cells.** Our emitter binds the CALLER's:

| cell | golden | pristine | final |
|---|---|---|---|
| `qb::bderived::x_cross` (qb declares its own `ge`) | `qa::ge` | `qb::ge` ✗ | `qb::ge` ✗ **unchanged** |
| `qc::cderived::x_wild` (qc only wildcard-imports qa) | `qa::ge` | **UNBOUND** | **`qc::ge`** ✗ **new wrong bind** |

Inside `uvm_pkg` the caller-walk and the callee-walk give the **same answer**, so
uvm-1.2 cannot distinguish them and the census legitimately matches golden cell
for cell. But the law as *stated* is over-general. Note the second row: defect
C's wildcard half turns "no link" into "a link to the importing package's
**clone**" (both sides have a `qc::ge` clone object; golden points at the
original in `qa`, we point at the clone in `qc`). **No corpus row exhibits
either shape** — 0 u2r movers and all 7 surelog movers verified correct — so
this is a residue, not a blocker. It is the natural next question for this
family.

### FINDING 3 — a differing arm cell the a2 table never lists (`unitcls::u_oob`)

`a2_site.sv` declares `u_oob`, an **out-of-body** method of the `$unit`-scope
class. Golden emits a `fe` call there bound to `p2::fe`; **we emit no call
object at all** (golden 4 `fe` prints, ours 3).

```bash
./ct72cells.sh /tmp/v72_a2_final fe   # "golden prints=4 ours=3"
```

**Pre-existing — identical on pristine — and therefore not a regression.** But
the README's a2 table presents its cells as the arm's full account and this cell
appears in none of its rows, so a reader checking "cell for cell" would not find
it. (`m_pkgname` is likewise unlisted, though it matches golden.) Reporting, not
blocking.

### FINDING 4 — a comment at SITE 1 misstates the change as behaviour-preserving

```cpp
// (§ inheritedNameBindsPkgFn72 — the walk this arm spelled
//  inline is now `pkgFreeSubForName72`, the SAME function
//  the § classCallNoLink12 arm calls.  Behaviour here is
//  byte-identical: the helper is that walk, moved.)
```

It is **not** byte-identical at this site: the old inline walk did a *direct
member* lookup only, and `pkgFreeSubForName72` adds the **wildcard-import**
half — which is defect C, and which the implementer documents correctly
everywhere else (including four lines away, in the helper's own header, and in
the defect table). The code is right; this one comment contradicts it, and in a
campaign where comments are the memory that is worth correcting on the next
touch. **I deliberately did not edit `src/ExprEmit.cpp` for it**: a comment-only
edit would invalidate the binary md5 that every number in this document was
measured on, for no behavioural gain.

---

## 5. RESIDUES, RANKED (mine, merged with the implementer's)

1. **`m_shadowed`** — module-level free fn found but not yet in `subMap`; wrong
   object → null. A partial, correctly disclosed. No corpus row exhibits it.
2. **`uvm_report_fatal` one link short** — 223 vs golden 224; the only target
   row that moved without landing. Already isolated to one site.
3. **Cross-package walk direction** (finding 2) — including the `x_wild`
   clone-vs-original bind.
4. **17 receiver-qualified `method_func_call` endln spans** (15 differ),
   `§69`'s family, + the 12 pre-existing design-wide target rows.
5. **`u_oob`** (finding 3) — golden emits an oob call object at `$unit` that we
   do not emit at all. Pre-existing.
6. **a2's `tk` cell** — we emit a bare unlinked `func_call` where golden emits
   none.
7. **typespec ORDERING** in a1/a2 (cmp-invisible), and **the new head**,
   `logic_var (uvm_pkg::uvm_sequence_request::request)` @1771 — a different
   family and the natural next target.

---

## 6. HYGIENE, BOUNDARIES, CANARIES

**Canaries — all re-run by me, all reproduce:**

| guard | result |
|---|---|
| `canaries.sh` surelog | **ok=52 changed=0 absent=0**, unknown-names=7 |
| `canaries.sh` uhdm2rtlil | **ok=8 changed=0 absent=0**, unknown-names=25 |
| `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` | **ok=58 changed=0**, unknown-patterns=1 — PASS |
| `ctcan2.sh` u2r `EXPECT_UNKNOWN=6` | **ok=1 changed=0**, unknown-patterns=6 — PASS |
| `canaudit.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** — PASS |
| `InterfaceModPort`, `BlackParrotComplex` BY NAME | `slang.uhdm` **byte-identical** in both modes, `CMP_EQUAL/differ` |

**Neighbouring passes' arms — I ran every one on BOTH binaries and compared the
dumps after normalising the workdir path** (the path is embedded in `file:`, and
comparing raw dumps from two workdirs reports a spurious move — it briefly
fooled me):

* `§ ctorBodyLocalsNotOnFunc71` a1–a4: **all four byte-identical — HOLD**
* `r10uvm70repro` a1–a4 + v5_gaps: **all five byte-identical — HOLD**
* `r10uvm69repro` a1–a3 + v1_gaps: **all four byte-identical — HOLD**

**Boundaries.** One production file, `src/ExprEmit.cpp`, five hunks (four in
`emitExpr` + one file-local static). `git diff --name-only` returns that file
and nothing else.

* `r10earl43` is **ParamEmit.cpp** — untouched, **no overlap**.
* `§ ctorBodyLocalsNotOnFunc71` is **TaskFuncEmit.cpp** — untouched.
* `classMethodNoBind`'s owner **StmtEmit.cpp** — untouched (the patch *stops
  reading* that flag; it does not change it).
* `r10buvm2` may share `ExprEmit.cpp`. The implementer reported this rather than
  assuming it away, which is the right call; the hunks are confined to the
  tf-call arm of `emitExpr`, so a textual collision is unlikely but possible.
  **Still reported, not resolved — it is a landing-order question.**
* `§ invalidNewCallFromSyntax55` / `§ retNameRecvCollapse69` /
  `§ classMethodRetNameNoBind56`: untouched, and §69's 17-print population is
  identical before and after (measured in §2).

**No diagnostics shipped**: `grep -cE '^\+.*(fprintf|cerr|getenv)'` on the src
diff returns **0**.

**STATED GATE == CODE GATE**: `grep -c` gives **5 / 4 / 4** for
`inheritedNameBindsPkgFn72` / `pkgFreeSubForName72` / `inheritedCall72`, all in
`src/ExprEmit.cpp` and nowhere else. I also checked the one thing a hoist can
break — that the hoisted gate reads the same values at its new site:
`curSubClassScope9`, `curSubOob9` and `currentSubSym` are set **only** in
`TaskFuncEmit.cpp` (per-subroutine, saved/restored) and are **never reassigned
between the new and old sites**, so the hoist is value-safe.

`results/*.csv` were only ever READ. `git stash` never used. slang not patched.
The four slang-fenced tests were never dispatched (`FENCE-BREACH=0`). My sweep
workdirs were deleted after measurement.

---

## 7. HOW TO REPRODUCE THIS VERIFICATION

```bash
git worktree add --detach /tmp/wt_v72pris 1251d66
git worktree add --detach /tmp/wt_v72     1251d66
cd /tmp/wt_v72 && git apply --whitespace=nowarn /tmp/r10uvm72.patch
# configure + build BOTH, -j 2, read the link line, md5 in a SEPARATE command

export SLANG_UHDM=/tmp/wt_v72/build/slang-uhdm      # NEVER rely on the default
python3 scripts/verify_golden.py --corpus surelog    --mode both      --jobs 2 \
        --out /tmp/v72_sl_patched.csv  --workdir /tmp/v72_wd_sl_patched
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 \
        --out /tmp/v72_u2r_patched.csv --workdir /tmp/v72_wd_u2r_patched
# ...and the same two with the pristine binary.

cd tools/probe/r10uvm72repro
./ct8rows.sh <(git show 1251d66:results/golden_surelog.csv) /tmp/v72_sl_patched.csv
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh /tmp/v72_wd_sl_patched /tmp/v72_wd_sl_pris
./mv72.sh /tmp/v72_wd_sl_patched /tmp/v72_wd_sl_pris /tmp/v72_mv   # NOTE: ls -a
./rowheads.sh /tmp/v72_wd_sl_patched /tmp/v72_heads_final SimpleUVM Scoreboard SeqDriver BuildUVMPkg
python3 ct72predict.py /tmp/v72_wd_sl_pris          # now safe to run concurrently

# the arms, both binaries
for a in a1_shadow a2_site v1_pos v2_walk v3_nest; do
  SLANG_UHDM=<bin> ./ct72arm.sh $a.sv /tmp/x_$a; done
./ct72cells.sh /tmp/x_a1_shadow fe other_free
./ct72cells.sh /tmp/x_v1_pos    fe          # the POSITION axis
./ct72cells.sh /tmp/x_v2_walk   ge          # the cross-package REFUTATION
```

---

## 8. VERDICT

**PASS.** The law is real, the mechanism is decoded correctly, the fix is
minimal and confined, and every gate is green on binaries I built myself. The
implementer's two self-corrections (BuildUVMPkg 58→17, and the presence-vs-target
census error) are both genuine and both check out — the second one in particular
would have shipped half a fix, and they caught it themselves.

Three things kept this from being a rubber stamp and all three are recorded
above: a probe instrument that lies when run in parallel (finding 1, fixed), a
stated law that is over-general in a shape uvm-1.2 cannot exhibit (finding 2),
and an arm cell missing from its own table (finding 3). None of them touches the
production change or any corpus row.
