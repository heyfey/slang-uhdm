# r10sd3 — VERIFIER REPORT (adversarial)

**VERDICT: PASS (with findings).**

I rebuilt both binaries from a fresh `19730ce` in my own worktrees and got the
implementer's two md5s **bit-for-bit**, so every number below is measured on my
own build, not accepted. **Every headline number in the pass's record
reproduced**, including the ones it would have been easiest to fudge: the
428/216/216/203 → 0 population on all seven live UVM rows, the 8-cell grid's
pristine and delivered dump contents, the multiset distance 365670 → 365644, the
four SIZE-DELTAs over 3 reps on both binaries, and the SeqDriver head at
1 414 877 lines — which I found **byte-identical** before and after, a stronger
statement than the record's "same line count, same object id".

Seven findings follow. **F1–F3 are real defects in the record**; none touches a
gate, and none changes the verdict. **F3 is the one the next pass must read
first**: the entire change lives inside the `weaklyReferenced` pool, so the
population this pass closed is **cmp-inert**. **F4 is a verifier addition that
makes the pass's claim STRONGER than it stated** — the law now holds
corpus-wide, on all 2311 databases, not only on the four UVM designs.

| | |
|---|---|
| verifier worktrees | `/tmp/wt_r10sd3v` (fresh `19730ce` + patch, own cmake configure), `/tmp/wt_r10sd3vpris` (fresh `19730ce`, untouched) |
| my delivered-binary md5 | **`eb2d9506c9c64c69afc90c16c3f49d08`** — the claimed 32 hex, exactly |
| my pristine-binary md5 | **`d90af4f662bab7e66f24bfe6258a8f9b`** — the claimed 32 hex, exactly |
| patch md5 | `dd86c2e4341cef5d69273871a88d9818` (as claimed); **re-cut from my worktree is byte-identical** |
| `git apply --check` on fresh `19730ce` | rc=0 |
| porcelain after apply | **4** entries (3 production files + `tools/probe/r10sd3repro/`) |
| `git diff 19730ce -- src include` | exactly `UhdmExporter.h` +10, `ModuleEmit.cpp` +22/−2, `TaskFuncEmit.cpp` 1 line |
| `results/*.csv` | `git status --porcelain -- results` = **0**; never written |
| `GOLDEN_DEFER` | printed `[UNSET]` before the sweeps |
| `git stash` | never used |

---

## 1. FINDINGS

### F1 — the BOUNDARIES section under-declares TWO live-pass collisions

`README.md` §6/§11 declare exactly one collision (`src/TaskFuncEmit.cpp`, with
`r10uvm70`) and assert that `r10earl41`'s "file-set intersection [is] **empty**".
Both statements are wrong at the file level, and I read the live worktrees rather
than the record:

```sh
cd /tmp/wt_r10uvm70  && git diff --stat 19730ce -- include src
#   src/EmitHelpers.h  src/ModuleEmit.cpp (15)  src/TaskFuncEmit.cpp (53)
cd /tmp/wt_r10earl41 && git diff --stat 19730ce -- include src
#   include/UhdmExporter.h (6)  src/EmitHelpers.h  src/ExprEmit.cpp  src/TypeEmit.cpp
```

* **`src/ModuleEmit.cpp` is shared with `r10uvm70` and is NOT declared.** Worse
  than a file collision: both passes edit the **same function**, `drainFuncRet`,
  and the same per-reference loop — `r10uvm70` at `20619-20631`
  (§ implicitRetSigningIsIntVar70 site 4/4, changing `makeReturnVar`'s
  implicit-signing argument for the **same `lv` object**), this pass at
  `20875-20894` (that `lv`'s typespec `Instance()`). The two facts are
  orthogonal (signing vs. instance) but an integrator must be told they meet in
  one function, and the record does not say so.
* **`include/UhdmExporter.h` is shared with `r10earl41`** (`+6` at ~1840, a
  method declaration; this pass `+10` at ~399, a `PendingFuncRet` field).

Neither is a blocker, and I proved that rather than assuming it:

```sh
git worktree add --detach /tmp/wt_r10sd3v_coll 19730ce
cd /tmp/wt_r10sd3v_coll
git apply /tmp/r10sd3v_uvm70.diff && git apply /tmp/r10sd3v_earl41.diff
git apply --check --exclude='tools/probe/*' /tmp/r10sd3.patch   # rc=0
# -> SD3 CO-APPLIES CLEAN ON TOP OF BOTH LIVE PASSES
```

`r10uvm70`'s `TaskFuncEmit.cpp` hunks are all at `2399-3015`, nowhere near this
pass's `5158`, so the specific conflict the record worried about cannot happen
today. **Record defect, not a substantive one** — but "intersection empty" is a
claim a reader will act on, and it is false.

### F2 — the GRID never exercises the IN-BODY arm of the law

The law has two rules (§9.4: "It is one rule — REFUTED"). The grid witnesses
**one** of them.

```sh
SLANG_UHDM=/tmp/wt_r10sd3vpris/build/slang-uhdm CT3CLS=/tmp/r10sd3v_ct3cls \
  bash tools/probe/r10sd3repro/ct3grid.sh vpris
```

| cell | ours PRIS class_defn | arm |
|---|---|---|
| g1 pkg+oob | 2 | out-of-body |
| g2 pkg+**in-body** | **0** | — |
| g3 $unit+oob | 1 | out-of-body |
| g4 module+**in-body** | **0** | — |
| g5 pkg+oob+locals | 2 | out-of-body |
| g6 two classes+oob | 4 | out-of-body |
| g7 oob **+ in-body** in ONE class | 2 — **both on the oob method** (`bit_typespec\|\|16:12`, `class_defn(c7)` ×2; the in-body `f7i` contributes nothing) | out-of-body |
| g8 base+derived **in-body** virtual | **0** | — |

All **11** pristine slots the record counts are the out-of-body arm. Our emitter
never stamps a `class_defn` on an in-body class method **anywhere in the grid**,
so there is no cell in which the delivered binary's in-body behaviour (stamp →
NULL) can be seen to change. The record's own "EMPTY PRODUCT HUNT — clean" is
therefore incomplete: it counts 11 non-vacuous slots without noticing they are
11 copies of one arm.

The second rule's **only** witness in the entire pass is 4 of the 428 SeqDriver
slots. I confirmed that key is genuinely what the record says it is:

```sh
awk 'NR==446' third_party/UVM/uvm-1.2/src/tlm2/uvm_tlm2_generic_payload.svh
#   function bit do_compare(uvm_object rhs, uvm_comparer comparer);   (col 12-15 = `bit`)
```

— an in-body method, golden `<null>=1`, ours pristine
`<null>=1 OTHER:class_defn(uvm_tlm_generic_payload)=4`, ours delivered `<null>`.
So the **fix is right there and is measured on the real database**; what is
overstated is §4/§9.4's claim that `g7` "isolates the discriminator" for *our*
emission. `g7` isolates it on **golden's** side only. A cell that reproduces the
UVM in-body stamp is still missing, and until one exists the in-body half of the
law is defended by 4 slots and no reproducer.

### F3 — UNREPORTED and material: the whole change is inside the `weaklyReferenced` pool. It is cmp-INERT.

`uhdm-dump` prints the design tree first and the unreachable-object pool last,
under `\_weaklyReferenced:`. Comparing my two databases per design:

```sh
uhdm-dump <db> | sed 1d > x.dump          # both binaries, per design
grep -n '^\\_weaklyReferenced:' pris.dump
diff pris.dump new.dump | grep -E '^[0-9]' | sed -E 's/^([0-9]+).*/\1/' | sort -n | head -1
```

| design | `\_weaklyReferenced:` at line | FIRST differing line |
|---|---|---|
| `SeqDriver` | 1 697 960 | **1 802 614** |
| `SimpleUVM` | 1 028 741 | **1 094 015** |
| `BuildUVMPkg` | 1 006 285 | **1 070 220** |
| `Scoreboard` | 1 025 499 | 1 023 464 — **nondeterminism, not the patch** |

Scoreboard's single earlier hunk is a 46-line `svunit_pkg` `Task_funcs` block
that moves position; I reproduced **the identical hunk between two runs of the
SAME pristine binary**, so it is R8's nondeterminism and not attributable to the
change:

```sh
# two pristine reps of Scoreboard, same binary
diff sb_p1.dump sb_p2.dump | head -4
#   1023463a1023464,1023509
#   > \_function: (svunit_pkg::svunit_base::get_name), line:68:1, endln:70:12   ...
```

**Consequence.** No design-reachable object changed on any of the four designs.
That is *why* every `uhdm-cmp` head is byte-identical, why no CSV row moved, and
why the multiset distance moved only 26 for a 428-slot change. The brief's
premise — "cmp-visible: `typespec::Compare` reads `Instance()`" — is true of the
**relation** (`generated/src/typespec.cpp:94`,
`SafeCompare(lhs->Instance(), rhs->Instance())`) and **false of these 428
objects**, because `Compare` never reaches them. The record states
"weaklyReferenced and cmp-invisible" only about R4's *extra copies*; it never
says the closed population itself is unreachable.

This does **not** flip the verdict: the pass's stated success criterion is the
population going to golden parity, and it does; the head measurement (§5.4) is
correct and was going to be negative for exactly this reason. But it bounds the
value precisely, and it is the fact the next pass needs: **fixing this family
cannot move cmp until the objects are reachable.** It also explains R1's
resistance — the head's `vpiInstance` slot is on a *reachable* object, so it is
a different mechanism, not a leftover of this one.

### F4 — verifier addition: the law now holds CORPUS-WIDE, not just on the four UVM designs

The pass claims parity on the four UVM designs. I checked **every database both
sweeps produced with the delivered binary** — 953 surelog + 1358 uhdm2rtlil =
**2311** — for any surviving `class_defn`-valued `Instance()`:

```sh
for f in $(find <sl_new> <u2r_new> -name slang.uhdm); do
  n=$(/tmp/r10sd3v_ct3cls "$SMALLDB" "$f" 0 | grep 'TOTAL class_defn' | awk '{print $NF}')
  [ "$n" != 0 ] && echo "REMAINING $n $f"
done
#   (no output)  SCAN_DONE
```

**Zero remaining, corpus-wide.** NEGATIVE CONTROL, because a scanner that reaches
nothing prints the same thing: the identical invocation on the *pristine*
databases reports `428` (SeqDriver) and `216` (SimpleUVM). This is a stronger
statement than the pass made and it belongs in the record.

### F5 — `default/Scoreboard`'s hash instability is on BOTH binaries, not just the pristine one

`README.md` §5.3 records "**no** — 3 distinct hashes on the pristine binary at
one fixed size". My 3 reps per binary, each run from the test's own source dir:

| binary | size (3 reps) | distinct md5s |
|---|---|---|
| pristine | 11122938 ×3 | **2** |
| delivered | 11122848 ×3 | **3** |

The *conclusion* is untouched and the SIZE-DELTA rule is applied correctly — but
"3 on the pristine binary" is a sample of a random variable printed as if it were
a property. The property is "hash-unstable at fixed size, on both binaries".

### F6 — the census-predict is left as an open upper bound; it closes cleanly, and closing it is worth one line

`predict.sh` reproduces exactly (2 u2r + 59 surelog; `u2r CANDIDATES=2`,
`surelog CANDIDATES=31` + `28`), and the four UVM rows are among them. The record
stops at "upper bound". It is closable:

* **u2r, 2 candidates, 0 movers — both explained.** `func_typename_ret` matches
  the out-of-body regex on `P::S` and contains **no class at all**;
  `hello-uvm` is `SLANG_REJECT` in both modes (`unknown package 'uvm_pkg'`) and
  emits no database.
* **surelog, 59 candidates, 7 movers.** Only **10** of the 59 emit a database at
  all (49 are `SLANG_REJECT`/no-db). Of those 10, the 7 UVM rows moved; I
  measured the other 6 — `Earlgrey_0_1`, `FuncStructVal`, `FuncStructValSimple`,
  `IOClassStruct`, `PackFunc`, `TaskDecls` — and **all carry 0 class_defn slots**.

So the mover set is not merely bounded above by the prediction, it is **exactly
accounted for**, which is the reading the standing law wants.

### F7 — R2's framing: the number that moved the wrong way is 212, and the net still improves by 432

Confirmed: `ALL:adpcm_pkg` 1544 → 1650, `TOP:adpcm_pkg` 1403 → 1509 (+212), from
`tsInst` naming the **clone target** package in a package-import clone pass. But
the record leaves R2 reading as if the pass traded one wrong for another. The
whole-database `|deficit|` on `default/SeqDriver`, summed over every
`vpiInstance` state, is:

```
pristine   2260 + 492 + 114 + 474 + 4578 + 428  =  8346
delivered  2256 + 598 +   8 + 580 + 4472 +   0  =  7914      (-432)
```

Every individual state is reproduced from `ct3cls` `[A]`. R2 is real and worth
its rank; the net is an improvement and should be stated alongside it.

---

## 2. WHAT REPRODUCED — every load-bearing number

### 2.1 The population (the pass's success criterion)

`ct3cls`, my binaries, both modes, golden from each row's own `cmds.txt` cache:

| row | golden | ours PRIS | ours NEW |
|---|---|---|---|
| `default/SeqDriver` | 0 | **428** | **0** |
| `testflags/SeqDriver` | 0 | **428** | **0** |
| `default/SimpleUVM` | 0 | **216** | **0** |
| `testflags/SimpleUVM` | 0 | **216** | **0** |
| `default/Scoreboard` | 0 | **216** | **0** |
| `default/BuildUVMPkg` | 0 | **203** | **0** |
| `testflags/BuildUVMPkg` | 0 | **203** | **0** |
| `testflags/Scoreboard` | SLANG_REJECT — no database, counted as SKIP | | |

**`428 / 216 / 216 / 203` — the r10sd2-verifier's F1 correction, independently
reproduced a third time.** `r10sd2`'s `214` remains refuted.

### 2.2 The decode, and where the 428 went (`default/SeqDriver`)

`[B]`: `GOLDEN_NONNULL_ONLY` **30 keys / 424 slots**, `GOLDEN_NULL_ONLY`
**1 key / 4 slots**. `[D]`: owner types `bit_typespec=36 int_typespec=20
integer_typespec=12 string_typespec=360`, parent **always** `ref_typespec` (428),
**19** class names. `ct3site`: home scope **428 TOP:uvm_pkg**.

`[A]` whole database:

| state | GOLDEN | PRIS | NEW |
|---|---|---|---|
| `<null>` | 34299 | 32039 | **32043** (+4) |
| `ALL:uvm_pkg` | 3489 | 3375 | **3481** (+106) |
| `TOP:uvm_pkg` | 11290 | 6712 | **6818** (+106) |
| `ALL:adpcm_pkg` | 1052 | 1544 | **1650** (+106) |
| `TOP:adpcm_pkg` | 929 | 1403 | **1509** (+106) |
| `OTHER:class_defn(*)` | **0** | **428** | **0** |

`4 + 106 × 4 = 428`, exactly, as claimed.

### 2.3 The grid — all 16 numbers

`DUMP_DIFF content`, PRIS → NEW: g1 **18→16**, g2 6→6, g3 **249→247**, g4 6→6,
g5 **31→29**, g6 **36→32**, g7 **24→22**, g8 34→34. `class_defn` PRIS
**2/0/1/0/2/4/2/0**, NEW **0** everywhere. cmp verdicts unchanged
(`g3 CMP_FAIL` at 378 lines both binaries; the rest `PASS_CMP`). Every cell
produced both databases; no `SURELOG_FAIL`. See F2 for what the grid does *not*
cover.

### 2.4 Movers, distance, size

* byte verifier, **my** two sweeps per corpus: u2r **0 / 1358**
  (`PATH_SETS_IDENTICAL`, SELFCHECK **1357/1358**, SELFCHECK1 **1**);
  surelog **7 / 953** (`PATH_SETS_IDENTICAL`, SELFCHECK **952/953**,
  SELFCHECK1 **8**). The 7 are exactly the 7 live UVM rows.
* CSVs: `u2r new == u2r pris` and `surelog new == surelog pris`, byte-identical
  whole-file — so nothing moved in status *or* dump column either.
* `msdist.sh` on `default/SeqDriver`: golden-only **264346 → 264333**, ours-only
  **101324 → 101311**, **MULTISET DISTANCE 365670 → 365644 (−26)**.
* dump-level: `|vpiInstance:` followed by a `class_defn` — golden **0**, ours
  **106 → 0** (SeqDriver), **106 → 0** (SimpleUVM), **101 → 0** (BuildUVMPkg),
  **106 → 0** (Scoreboard).
* SIZE-DELTA, **3 reps on BOTH binaries**, each from the test's own source dir:

| design | pristine ×3 | delivered ×3 | Δ |
|---|---|---|---|
| SeqDriver | 17962372 | 17962228 | **−144** |
| SimpleUVM | 11118646 | 11118556 | **−90** |
| Scoreboard | 11122938 | 11122848 | **−90** (hash-unstable both binaries — F5) |
| BuildUVMPkg | 11097319 | 11097258 | **−61** |

### 2.5 The bonus measurement — the SeqDriver head

`rowheads.sh` over both workdirs, then `cmp` of the head files themselves:

| row | PRIS | NEW | head text |
|---|---|---|---|
| `default/SeqDriver` | 1414877 / 1 head | 1414877 / 1 head | **byte-identical** |
| `testflags/SeqDriver` | 1414877 | 1414877 | **byte-identical** |
| `default,testflags/SimpleUVM` | 54 | 54 | byte-identical |
| `default/Scoreboard` | 54 | 54 | byte-identical |
| `default,testflags/BuildUVMPkg` | 58 | 58 | byte-identical |

`LHS: <null>` / `RHS: package uvm_pkg id:6040` on `default/SeqDriver`, as
recorded. **The head does not clear** — confirmed, and by a stronger test than
the record used. The baseline correction is also correct: SimpleUVM/Scoreboard
are `int_var (uvm_pkg::uvm_tr_stream::get_recorders)@371:13` vs `logic_var`, and
BuildUVMPkg is `ref_obj (…uvm_deferred_init)@14107:7` vs `hier_path`.

### 2.6 STATED GATE == CODE GATE

```
pf.inst occurrences in ModuleEmit.cpp: pristine 10 -> delivered 9
20564 pkgOnly gate | 20689/20694 aggregate view | 20756 clone view
20790 per-view key | 20853/20855 retTopView67      <- ALL still pf.inst
20893  if (pf.tsInst3) ts->Instance(pf.tsInst3);    <- the ONE substitution
```

`tsInst3` is last in `PendingFuncRet` (aggregate-init resolution claim holds).
The "identical for non-class scopes" argument is sound in the code —
`oobHomePkg` is assigned only under `if (classScope && !oobDefs.empty())`, so for
`!classScope` the new expression collapses to `pkgScope ? m : nullptr`, the old
one — and is confirmed empirically by 1358 u2r databases and 946 non-UVM surelog
databases not moving a byte.

---

## 3. THE FIVE GATES, RUN INDEPENDENTLY

| gate | measured HERE |
|---|---|
| **1 BUILD** | own `cmake` configure in both worktrees, absolute path, `make -j 2`, `Linking CXX executable slang-uhdm` seen before any md5 was read, `error:` count **0** both, BASE `git rev-parse \| grep -c` = **1** both. **`eb2d9506c9c64c69afc90c16c3f49d08`** / **`d90af4f662bab7e66f24bfe6258a8f9b`** — both 32 hex, different, both exactly as claimed |
| **2 GOLDENS** | `23 PASS / 0 FAIL`; `SLANG_UHDM=/bin/false` → `0 PASS / 23 FAIL` |
| **3 u2r** | default **679/50/2**, testflags **679/50/2**; `ct8rows` vs `results/gate_uhdm2rtlil.csv` (testflags-filtered — the trap the record re-encodes, and it is real: the baseline holds testflags rows only) → **0 differing ROWS, 0 row-sides**, dump **496 match / 183 differ / 52 blank** base == fresh |
| **4 surelog** | default **469 / 11 / 25 FAIL / 5 DEFER / 284 REJECT**; testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM); `ct8rows` vs `results/golden_surelog.csv` → **0 differing ROWS**, all **4** dump histograms identical (default 225/244/325, testflags 165/300/329) |
| **5 BYTE VERIFIER** | §2.4 — both corpora, both modes, vs the pristine I built, `SELFCHECK=1 SELFCHECK1=1`, per-shape by multiset, ADDED/REMOVED separate, census-predict run and **closed** (F6) |

All sweeps `--jobs 2` with private `--out`/`--workdir`; `SLANG_UHDM` pinned and
**verified by reading `cmds.txt`** in each workdir (the r10sd2-verifier's F4 trap
— `verify_golden.py` defaults it to the main-tree binary).

**CANARIES** — `canaries.sh` surelog **ok=52 changed=0 absent=0** (unknown 7),
u2r **ok=8 changed=0 absent=0** (unknown 25); `ctcan2.sh` `EXPECT_UNKNOWN=1`
surelog **ok=58, unknown-patterns=1, PASS**, `EXPECT_UNKNOWN=6` u2r **ok=1,
unknown-patterns=6, PASS**; `canaudit.sh` **audited=29 UNCOVERED=0
FENCE-BREACH=0**, and `UnsignedParam` / `HierPathEval` / `FileLocalParam` /
`TopParam` dispatched by no driver. **By name**: `InterfaceModPort` `CMP_EQUAL`
both modes, `BlackParrotComplex` `CMP_EQUAL` both modes; `SeqDriver`
`SimpleUVM` `BuildUVMPkg` `CMP_NOTEQUAL` both modes, `Scoreboard`
`CMP_NOTEQUAL`(default) / `SLANG_REJECT`(testflags).

**BOUNDARIES re-checked here.**

* `§ classTdSpecParamsForeignHome1` / sd1 **b1–b28**: I ran
  `r10sd1repro/ct1grid.sh` with **both** binaries — 28 cells, `SAME=24 DIFF=4
  FAILED=0`, golden-PA-cells=11, ours-PA-cells=7, and the two runs are
  **byte-identical**. The grid holds.
* sd2-verifier **F3** (`design.Param_assigns`/`Parameters`/`Typespecs`):
  `ct2design` on SimpleUVM and Scoreboard, both binaries — `45 / -1`, `45 / -1`,
  `123 / 89` and `125 / 91`, **identical before and after**. Untouched, still
  masked, still the next thing behind those rows' heads.
* live passes: see **F1**.

---

## 4. RANKED RESIDUES (this verification's ordering)

1. **The closed population is unreachable — F3.** Before anyone spends another
   pass on `vpiInstance`-family work expecting cmp movement, settle whether
   these return-name locals *should* be reachable. § classMethodRetNameNoBind56
   drops the in-body class refs by design; the out-of-body ones keep
   `Actual_group`, yet their typespecs still land in the weakly-referenced pool.
   That gap between "bound ref" and "unreachable typespec" is itself a finding
   waiting to be made, and it is cheap: one `ct3cls` variant that flags
   reachability.
2. **R1 — the SeqDriver head, 1 414 877, still open**, and now known not to be
   this family (measured twice: sd2 by in-memory mutation, this pass by a
   shipped binary, me by byte-identical head text). F3 sharpens it: the head's
   slot is on a **reachable** object, so a different mechanism owns it.
   `ct2owner.cpp` + set-valued ddmin over the 34 `class_typespec` chokepoints
   remains the instrument.
3. **R2/F7 — `adpcm_pkg` +212**, net `|deficit|` still −432. The mechanism is
   `tsInst` naming the **clone target** in a package-import clone; golden names
   `uvm_pkg` at those keys. One `ct3cls` line scores it and it is the cheapest
   next survey in this family.
4. **F2 — no in-body reproducer.** A grid cell that makes our emitter stamp a
   `class_defn` on an in-body class method does not exist. Until it does, the
   second rule rests on 4 UVM slots. Worth ten minutes with the UVM shape
   (`uvm_object`-derived class, mixed extern/in-body members, module-scope
   wildcard import) to find what g2/g7 are missing.
5. **R3 — `TOP:uvm_pkg` still −4472 on SeqDriver** (this pass closed 106);
   −644/−589/−534 elsewhere. Same view mechanism plausibly reaches R1.
6. **R4 — we emit more objects than golden at these keys.** Reproduced in g1:
   after the fix `ALL:p1` reads 5 against golden's 4 while `TOP:p1` becomes
   exact. Stamp right, population wrong.
7. **R5 — `g3_unit_oob` `CMP_FAIL` 378 lines both binaries.** A 10-line
   `$unit`-home reproducer, ready to use.
8. **R7/R8 unchanged** — `VpiFile` blind spot; `default/Scoreboard`
   hash-unstable **on both binaries** (F5), judge by size.

---

## 5. WHAT I COULD NOT VERIFY

* **The tap's "179 setters, one site, 526 stamps" (§3).** Reproducing it needs a
  throwaway instrumented build, which the patch deliberately does not carry. The
  strongest available corroboration is F4: changing that **one** line takes the
  population to zero on **all 2311 databases in both corpora**, which no
  partial-site fix could do. `TAP.md` is enough to rebuild it.
* **The record's "26 corpus-wide sampled goldens"** for the parent law's golden
  side (inherited from r10sd2). I re-measured golden = 0 on the 7 live UVM rows
  only.

---

## 6. VERIFIER ARTIFACTS

Worktrees `/tmp/wt_r10sd3v`, `/tmp/wt_r10sd3vpris`, `/tmp/wt_r10sd3v_coll`
(collision test). Instruments built from this directory's own sources:
`/tmp/r10sd3v_ct3cls`, `/tmp/r10sd3v_ct3site`, `/tmp/r10sd3v_ct2design`,
`/tmp/r10sd3v_ct2vclsdefn`. Sweep workdirs `/tmp/r10sd3v_wd_{u2r,sl}_{new,pris}`
and CSVs `/tmp/r10sd3v_{u2r,sl}_{new,pris}.csv` — **deleted after the report**,
as the standing rules require. No file outside `/tmp` and this directory was
written; `results/*.csv` were read only.
