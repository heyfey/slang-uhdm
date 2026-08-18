# r10v69 — the ADVERSARIAL VERIFICATION of r10earl69 (§ hpNameBareIdxFold69)

**VERDICT: ACCEPT AS SHIPPED.**  Every headline number in
`r10earl69repro/README.md` was reproduced bit-for-bit from an independent
build in a fresh worktree at `a621c25`, and eight adversarial arms plus a
3,193-file / 1,452-directory boundary failed to produce a single
pristine-right → patched-wrong cell the judge can reach.  No fix was needed,
so there is **no `.verified.patch` carrying production changes**; the
production surface the master lands is byte-identical to `/tmp/r10earl69.patch`
(the verifier's regenerated `git diff a621c25` is byte-identical to it,
md5 `45b4f56da290522c9664d1973c65868b`).

Binaries built here, `-j 2`, at `a621c25` and `a621c25`+patch:

| | md5 | claimed by the pass |
|---|---|---|
| pristine | `32bbd68862ba4da0bb03f6700bdf0241` | same |
| patched  | `15e3eb1ceb30c1fcfcbc2b322f8b1cd0` | same |

Both frozen `chmod 555` before any sweep; `SLANG_UHDM` exported explicitly per
binary; every `cmds.txt` audited **by binary path** (u2r 1458 + 1458, surelog
1523 + 1523 lines, all naming only the two frozen paths — no main-tree binary
anywhere).  `GOLDEN_DEFER` unset; `results/*.csv` read only.

---

## 1. What was reproduced, independently

| measurement | pass claim | verifier measurement |
|---|---|---|
| Earlgrey cmp depth, default | 216 → 50 | **216 → 50**, 1 head each |
| Earlgrey cmp depth, testflags | 216 → 50 | **216 → 50**, 1 head each |
| BEFORE cmp logs byte-identical across modes | md5 `3dced0fa…` | **`3dced0faef87cacdcb37dd873993df33`** |
| AFTER cmp logs byte-identical across modes | md5 `f2ea546b…` | **`f2ea546b727b16bb28602bc7a025ad2b`** |
| the four committed `HEAD_R0_*.cmp` artifacts | — | **byte-identical to the verifier's own runs** |
| goldens, both binaries | 23 / 0 | **PASS 23 / FAIL 0** on both; `/bin/false` **0 / 23** |
| u2r, both modes, both binaries | 679 / 50 / 2 | **679 / 50 / 2** in all four sweeps |
| `ct8rows` u2r vs committed and vs own pristine | PASS | **PASS, 0 differing rows** (status AND dump), all four comparisons |
| `byteverify SELFCHECK=1` u2r | MOVERS 0 / 1358 | **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL, selfcheck 1357/1358 |
| surelog status histogram | 936 CE / 20 NE / 567 SR / 48 SF / 10 DEF / 3 ND / 2 UT / 1 TO / 1 NU | **identical, both binaries, 1588 rows** |
| `ct8rows` surelog vs committed and vs own pristine | PASS | **PASS, 0 differing rows** |
| `byteverify SELFCHECK=1` surelog | MOVERS 4 / 956 | **MOVERS 4 / 956** (see §2 — the coin set differs, the substance does not) |
| Earlgrey hier_path NAME census, per mode | 152 TO-GOLDEN / 0 AWAY / 0 MOVED-WRONG of 12,330 | **152 / 0 / 0**, 304 census diff lines, both modes |
| mover split | 144 port High_conn + 8 ELAB gen-scope cont_assign | **144 `HC_*` + 8 `CA_*`** |
| whole-EXPRESSION census (tscen69) | 0 diff lines | **0 diff lines**, both modes (162,255 / 160,030 cells) |
| golden is a FIXED POINT of the rewrite | 0 names change in 3,673 DBs | **0 in all 3,673** (267,547 hier_paths; run in two halves, 500 + 3,173) |
| canaries surelog / u2r | ok=52 / ok=8, changed=0 | **ok=52 changed=0 / ok=8 changed=0** |
| ctcan2 surelog / u2r | PASS / PASS | **PASS / PASS** |
| canaudit | audited=29 UNCOVERED=0 FENCE-BREACH=0 | **same** |
| protected DBs | SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | **SAME both modes; both pins exact** |
| rowheads | only Earlgrey moved | **only Earlgrey**; SeqDriver 99202, SimpleUVM/Scoreboard 99106, MiniAmiq 99202, BuildUVMPkg 166, Rggen 194 unchanged on both binaries |
| fence-name check | 0/0/0/0 | **0/0/0/0** |

The regenerated `git diff a621c25` of the applied tree is **byte-identical** to
the shipped patch; surface is `src/ExprEmit.cpp` + `RESUME.md` §3b +
`tools/probe/r10earl69repro/` only, **31 files**, no `results/*.csv`.

## 2. The two surelog byteverify movers that are NOT Earlgrey

The pass reported `Scoreboard`/default + `SeqDriver`/default; this run got
`SeqDriver`/**both** modes and no Scoreboard.  Both readings are the same
documented coin (RESUME §9), proved here rather than asserted:

* order-blind (sorted, workdir-normalised) dump diff = **0 lines** in both
  SeqDriver modes;
* re-running `SeqDriver` **serially** with each binary from the test directory
  gives the SAME database md5 `bded52f700d4` for the **pristine** and the
  **patched** binary — the sweep's other face (`d6d539938d62`) is the coin
  under parallel load, not a mover.

## 3. Breaking the law — eight adversarial arms

`v1`…`v7` here cover what `a1`/`a2` do not: struct member **chains**
(`oarr[i].x.c[P+:W]`), the hier_path on the **LHS** of a cont_assign, as an
**operation operand**, as a **call argument**, as a **bit-select base**,
**no-index** paths, **instance-array** and **interface-array** hierarchical
refs, a hierarchical read **into a generate block** (`gblk[0].w`),
**3 unrollings**, **3 nested genvars**, **3 instances** with per-instance
parameters, **enum-constant / qualified / cast / call / select** bounds, and
**escaped identifiers whose names contain brackets** (`\esc[2] [i].mm[XA+:XB]`).
Every arm is built with Surelog (golden) and with both frozen binaries in BOTH
views, and scored **judge-faithfully** (`hier_path::Compare` reads
`Path_elems`, then `Root_value`, then `VpiName`) with a **NO-SPAN, NO-LOC**
element payload — the pass's own `armscore69.py` compares an element payload
that still carries `span=`, which is exactly earl60's trap (a span-carrying
payload can hide a real name flip inside `STILL-WRONG`).  `vscore69v.py` here
strips both and additionally prints the **strictest possible NAME-ONLY** view.

Result, all seven arms × both views:

* **0 AWAY-GOLDEN, 0 MOVED-WRONG** judge-faithfully;
* the NAME-ONLY view finds cells that move without reaching golden — every one
  of them is a cell whose `Path_elems` **already differ from golden in a
  judge-visible way** (golden has a `ref_obj`, we have a folded `constant`, or
  vice versa), verified element-by-element by hand;
* `v7` proves the **fail-closed** clause works: on `\esc[2] [i].mm[XA+:XB]` the
  element's `VpiName` does not line up with the hier_path's name, the walk
  aborts, and the patched output is byte-identical to the pristine one.

## 4. The mirror is faithful to the shipped C++

`hpfold69.py` is what proves "golden is a fixed point", so the mirror itself
was validated against the **binaries**: `mirrorcheck.py` predicts the patched
name from the *pristine* census and compares it with the *real* patched census.

| corpus | cells | disagreements |
|---|---|---|
| the seven arms, both views | 498 | **0** |
| Earlgrey default | 12,330 | **0** |
| Earlgrey testflags | 12,330 | **0** |

So the golden-cache fixed-point measurement is a statement about the shipped
helper, not about a re-implementation of it.

## 5. Boundary — wider than the pass's, both views, scored against golden

Run from a **read-only copy** of the main tree's `tools/probe` plus this pass's
two arms and this verifier's seven, `.sv` **and** `.v`, list on fd 3, children
`</dev/null`, `PROCESSED` asserted, rc recorded per cell.

| gate | result |
|---|---|
| WIDE, 3,193 files × 2 views × 2 binaries | **PROCESSED = LISTED = 3,193**; 6,076 identical / **40 differing** / 270 no_output |
| WIDE signals | 20 rows `rc=139`, **every one paired A and B** (10 files, pre-existing on both binaries) |
| per-DIRECTORY, 1,452 dirs × 2 views × 2 binaries | see `§5b` |
| every differing FILE re-scored against a REBUILT Surelog golden | **0 AWAY-GOLDEN, 0 MOVED-WRONG**, 20 files × 2 views, no `NOGOLD` |

Excluding this verifier's own seven arms the differing set is **28 units** —
exactly the pass's number, and the same files.  The three UVM **directory**
units (`r10uvm75/76/88repro`) are **order coins**: order-blind diff 0 lines,
and the *pristine* binary run against *itself* on `r10uvm75repro` reproduces
14–20 raw differing lines across repeats.

`r10buvm22repro/g22.sv` carries **no name change**: its 12 lines are three
`array_typespec` range constants differing by exactly `0x3000`.  Confirmed
here as a **pre-existing type-confusion read** — `src/TypeEmit.cpp:10345`
does `ct.as<FixedSizeUnpackedArrayType>()` unchecked on an
`AssociativeArrayType` — deterministic per binary (two repeats each), moving
only with the binary image, and **wrong on both binaries** (Surelog's golden
says `0`, ours says `2218…`), so it is not a pristine-right → patched-wrong
cell.  It has zero corpus population (byteverify).

## 6. What the pass under-reported (findings, not defects)

1. The "one over-reach, bounded" class is **larger than `a2`**: the same
   name-follows-a-wrong-object shape appears in `r10earl34repro/v2_kinds.sv`
   and `v5_init.sv` (`arr2[PkgCat].base.q` → `arr2[9].base.q`,
   `a4[InRep].base.q` → `a4[5].base.q`) and in this verifier's `v1`/`v3`.
   All of them are judge-unreachable for the same reason (golden's index is a
   `ref_obj`, ours a `constant`, and `Path_elems` is compared first), and all
   of them have **zero corpus population**.
2. `armscore69.py`'s element payload carries `span=`; use `vscore69v.py` (or
   pipe through `nospan69.sh`) when scoring a name-only law.
3. The law is applied **only in `src/ExprEmit.cpp`** (21 of 21 setter sites
   there, verified mechanically).  Seven further `Path_elems(<vec>)` setter
   sites exist in `ModuleEmit.cpp` (3), `TypeEmit.cpp` (2) and `StmtEmit.cpp`
   (2) and are **not** covered.
4. `hpname69`'s per-element payload does not descend into an `operation`
   operand, so its "elements agree" is an approximation for operation-bound
   cells.  It does not affect any verdict here (the real target's strictest
   NAME-ONLY view is 152 TO-GOLDEN / 0 AWAY / 0 MOVED-WRONG).
5. Importing `hpfold69.py` writes `tools/probe/r10earl69repro/__pycache__/`;
   it must not be `git add`ed.

## 7. Integration note for the master

On the **current HEAD** (`944257e3`, rgg17 landed) `git apply -3` puts
`src/ExprEmit.cpp` in **cleanly** (0 conflict markers, and the 21/21 setter
coverage is preserved — rgg17 added no new `Path_elems` setter in that file),
but **`RESUME.md` §3b CONFLICTS**: HEAD has already moved the SeqDriver,
BuildUVMPkg and Rggen rows.  The resolution is mechanical — keep HEAD's rows
for everything except the two `Earlgrey_0_1` rows, which take earl69's.

## 8. Files

* `v1_shapes69.sv` … `v7_escape69.sv` — the adversarial arms (§3).
* `vscore69v.py` — the NO-SPAN judge-faithful 3-way scorer, with a separate
  NAME-ONLY view and a span-PRESENCE counter.
* `mirrorcheck.py` — validates `hpfold69.py` against the real binaries (§4).
* `runarm.sh` — build one arm with Surelog + both binaries, both views.
* `vscore.sh` — rebuild the golden for every boundary-differing file and score
  it (also prints raw and order-blind dump-diff line counts).
* `vwide.sh` / `vdir.sh` — the recursive and per-directory boundaries, `.sv`
  **and** `.v`, fd-3 list, children `</dev/null`, PROCESSED asserted, rc per
  cell.

All of it is MEASUREMENT ONLY; the official `uhdm-cmp` remains the sole judge.
