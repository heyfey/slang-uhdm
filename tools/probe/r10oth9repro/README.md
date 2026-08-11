# r10oth9 — `§ arrayElemTsSignedParented9`: the ELEMENT TYPESPEC of a dynamic / queue / assoc CLASS PROPERTY

**Result, up front: THE SVSwitch HEAD CLEARED AND MOVED.** SVSwitch stays
`CMP_NOTEQUAL` in both modes — it is not a conversion — but the
`byte_typespec 23:6` head the brief set as the target is GONE, byte-for-byte,
and the new head is in a completely different cluster:

```
OLD head (base 37ffbd2)   byte_typespec: , id:3771, line:23:6, endln:23:10
NEW head (this pass)      ref_obj: (work@packet::cal_fcs::size), line:48:22
                          vs ours  method_func_call: (size), line:48:22
```

* **cmp HEAD DEPTH 18 → 26 lines** (a head-depth measure, not a distance): the
  head moved LATER in the Compare walk.
* **dump DISTANCE 2695 → 2698 true content lines** — it went UP by 3, and that
  is **not** a regression: the three lines we now emit are **byte-identical to
  golden's three lines**, but golden lists that typespec at a DIFFERENT position
  in the top-level listing, so `diff` cannot pair them and counts them twice.
  Proven in §4.2 with the two diff hunks quoted side by side. This is the
  campaign's own law that **cmp line count and diff distance are different
  instruments** doing exactly what it warns about.
* **ONE LAW, and it REFUTES the direction the brief gave for it** (§3). The
  brief said to reuse `§ arrayVarSignedWritten8`'s clauses (b)+(c). Arm `b3`
  proves the two carriers of signedness on the SAME declaration **disagree** on
  precisely the cell those clauses exist for, so the predicate must NOT be
  reused. **A refutation of the brief is worth more than agreement, and this is
  the pass's main finding.**
* **ARMS: 108 cells across 6 arms, both sides listed at OWN CHILD DEPTH.**
  Differing cells (a FIELD disagreement) **52 → 30**; EQ **39 → 61**; 23 cell
  rows changed. `DIFFERKIND` (both sides emit an object of a DIFFERENT typespec
  class) stayed 2, `UNMEASURED` (one side emits NO object) stayed 15. Every one
  of the 30 survivors is attributed to a ranked residue in §8, and **none of
  them is in the arm the law owns**.
* **CORPUS REACH: ZERO rows moved on either corpus** (731 u2r rows, 1588
  surelog rows, WHOLE-ROW diff including the dump column) and **ZERO BYTES moved
  on either corpus** — u2r 0/679, surelog 0/953. See §5, §6.
* **ZERO canary rows moved**, counted as ROWS, on both scripts and both corpora.

Base commit `37ffbd2`, branch `auto5h`.
Pristine binary md5 `51bb84bca8a60e0e0b886a615a761322` (identical to the
main-tree `build/slang-uhdm`, which is how this pass proved its pristine
worktree really is 37ffbd2 — §1).
**Shipped patched binary md5 `6c33528bbc40a08a4ae8e6bad925ebc5`.**

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script
in this directory.

---

## 1. THE LAW, in the form a future pass can grep for

```
§ arrayElemTsSignedParented9
```

> The **ELEMENT TYPESPEC** of a DYNAMIC / QUEUE / ASSOCIATIVE **class property**
> carries BOTH
>
> * `vpiParent` → **its own `vpiReg` element variable**, and
> * `vpiSigned` = **the ELEMENT TYPE'S RESOLVED SIGNEDNESS** (`isSigned()`,
>   which PIERCES a typedef) — not a constant 1, and **not**
>   `§ arrayVarSignedWritten8`'s "as written" predicate,
>
> with exactly ONE gate, `§ arrayVarSignedWritten8`'s clause **(a)**: when the
> WHOLE ARRAY is reached through a typedef (`typedef byte barr_t[]; barr_t x;`)
> golden's object is a bare `array_typespec` carrying NEITHER field, so neither
> is stamped.

**Three placements of signedness on one declaration, and they are three
different rules.** `§ arrayVarSignedWritten8` (r10oth8) established two; this
pass measures the third and finds it disagrees with the first:

| carrier | rule | keys on |
| --- | --- | --- |
| `array_var` | `§ arrayVarSignedWritten8` | the element type **AS WRITTEN** — a typedef NAME gets NOTHING |
| element `vpiReg` var | NEVER at class/module scope (`§ arrayVarSignedWritten8`, SUPPRESS half) | — |
| **element TYPESPEC** | **`§ arrayElemTsSignedParented9`** | the element type **RESOLVED** — a typedef NAME gets `vpiSigned:1` |

Call site, one only: `src/UhdmExporter.cpp`, `emitClassDefn`'s dynamic /
queue / assoc arm. Grep either marker:

```bash
grep -n "arrayElemTsSignedParented9" src/UhdmExporter.cpp
grep -n "A PREDEFINED-INTEGER element takes the matching integer" src/UhdmExporter.cpp
```

A cross-reference warning was also added at `arraySignedWritten8`'s definition
(`grep -n "DO NOT REUSE THIS PREDICATE FOR THE ELEMENT TYPESPEC" src/UhdmExporter.cpp`)
so the next pass cannot merge the two predicates by accident.

### GATE 1 — the build, and the stale-binary control

```bash
cd <worktree> && cmake --build build -j 3     # waits for "Linking CXX executable slang-uhdm"
md5sum build/slang-uhdm                        # SEPARATE command, BEFORE any sweep
```

| binary | md5 |
| --- | --- |
| main tree `build/slang-uhdm` at 37ffbd2 | `51bb84bca8a60e0e0b886a615a761322` |
| **pristine worktree, built from scratch here** | `51bb84bca8a60e0e0b886a615a761322` |
| instrument-only build (§2, not shipped) | `fb62b9fcf76a1f78becca3cc8ddeb522` |
| law without the clause-(a) gate (§3.3, not shipped) | `0aa2155f3669f4a2ca63ec37b6bd7756` |
| **SHIPPED** | `6c33528bbc40a08a4ae8e6bad925ebc5` |

The pristine worktree binary is **byte-identical** to the main tree's. That is
this pass's stale-binary control working in the useful direction: it proves the
pristine side of every comparison below really is 37ffbd2, built by this agent,
with no inherited artefact.

**WHICH BINARY PRODUCED WHICH NUMBER.** Every gate, every arm table and every
mover in this document was measured on the SHIPPED binary
`6c33528bbc40a08a4ae8e6bad925ebc5` against the pristine
`51bb84bca8a60e0e0b886a615a761322`. The two intermediate builds appear ONLY where
they are named: `fb62b9fc…` in §2 (the instrument) and `0aa2155f…` in §3.3 (the
un-gated law, whose over-fire is why it is not the shipped one). §4.2's SVSwitch
head, head depth (26) and distance (2698) were RE-MEASURED on the shipped binary
after the clause-(a) gate went in, and read identically — expected, because
SVSwitch contains no whole-array typedef, but stated rather than assumed. A
`cmake --build` on the shipped tree reports `Built target` with no relink, so the
binary matches the source in the patch.

---

## 2. WHICH CODE PATH PRODUCES THE BARE TYPESPEC — INSTRUMENTED, NOT GUESSED

The brief named TWO candidate producers and required the answer to be measured.
An `R10OTH9_TRACE`-gated `fprintf` was built (md5
`fb62b9fcf76a1f78becca3cc8ddeb522`, behaviour-neutral) and run on three arms.
Verbatim, trimmed to the interesting rows:

```
$ R10OTH9_TRACE=1 slang-uhdm b1_ctrl.sv -o /dev/null 2>&1 | grep R10OTH9
R10OTH9 PATH_I  c02_data         ts=0x762c22b31640 elemSigned=1 sharedAlias=0
R10OTH9 PATH_I  c03_data_norand  ts=0x762c22b316a0 elemSigned=1 sharedAlias=0

$ ... b2_elemkind.sv ...
R10OTH9 PATH_I  d01_byte      ts=0x7ef552ba1580 elemSigned=1 sharedAlias=0
R10OTH9 PATH_I  d02_byteu     ts=0x7ef552ba15e0 elemSigned=0 sharedAlias=0
   ... d03..d12, all PATH_I, all distinct pointers, all sharedAlias=0 ...
R10OTH9 PATH_II d13_bit       elemSigned=0
R10OTH9 PATH_II d14_bits      elemSigned=1
   ... d15..d21, all PATH_II ...

$ ... b3_typedef.sv ...
R10OTH9 PATH_I  f01_btd       ts=0x7e0b37b918e0 elemSigned=1 sharedAlias=0
R10OTH9 PATH_II f02_pkbtd     elemSigned=1
R10OTH9 PATH_II f04_written   elemSigned=1
R10OTH9 PATH_I  f05_chain     ts=0x7e0b37b91940 elemSigned=1 sharedAlias=0
R10OTH9 PATH_I  f06_wholetd   ts=0x7e0b37b919a0 elemSigned=1 sharedAlias=0
```

* **PATH_I** = `predefIntTypespec(et->getCanonicalType(), cp)`
  (grep `A PREDEFINED-INTEGER element takes the matching integer`) — it produces
  the SVSwitch `23:6` object and every ATOM element, **including the typedef'd
  ones**.
* **PATH_II** = the write-phase mint via `pendingClassPropTs`
  (grep `An ELEMENT type with no shared alias`) — it produces every
  `bit`/`logic`/`reg`/packed-vector element. It ALREADY gets `vpiParent` (the
  write phase does `ts->VpiParent(pc.var)`); what it lacks is `vpiSigned`, which
  is residue **R1** and is deliberately not fixed here.
* Some cells reach NEITHER (`f03_setd`): `classElemVar` had already bound a
  shared alias typespec, so the ref was non-null on arrival.

### THE SHARED-OBJECT HAZARD DOES NOT REACH PATH_I, and that is measured

The brief's stated hazard — "`predefIntTypespec` may hand back a SHARED object",
"vpiParent on a TYPESPEC is the LAST LISTER" — is **REFUTED for this call site**:

* `predefIntTypespec` (`src/ParamEmit.cpp`, grep
  `UhdmExporter::predefIntTypespec`) calls `s.Make<X>_typespec()`
  **unconditionally**. Every object it returns is FRESH. It never consults a
  registry, so a typedef'd element does not change that.
* The trace above prints a **DISTINCT pointer for all 20 PATH_I objects** and
  `sharedAlias=0` for every one, where `sharedAlias` is a live call to
  `isSharedAliasTs(*et, pts)` — the exact guard the brief asked for, EXECUTED,
  with its output quoted.
* **A later phase does not overwrite the stamp**: the post-patch dump shows our
  `23:6` object carrying `vpiParent -> byte_var (work@packet::data)` at the
  top-level listing occurrence (§4.2), i.e. the stamp SURVIVED to the writer.

---

## 3. THE REFUTATION — WHY `§ arrayVarSignedWritten8`'s PREDICATE MUST NOT BE REUSED

### 3.1 The brief's direction

> "Reuse the predicate for clauses (b)+(c) — do not write a second copy of the
> rule"

### 3.2 What arm `b3` measures (`b3_typedef.sv`, both sides, own child depth)

| cell | declaration | golden `array_var` `vpiSigned` | golden **element typespec** `vpiSigned` |
| --- | --- | --- | --- |
| `f01_btd` / `g01_btd` | `typedef byte b_t; b_t x[];` | **absent** | **1** |
| `f05_chain` / `g05_chain` | `typedef b_t b2_t; b2_t x[];` | **absent** | **1** |
| `f04_written` / `g04_written` | `bit signed [7:0][3:0] x[];` | 1 | 1 |
| `f06_wholetd` / `g06_wholetd` | `typedef byte barr_t[]; barr_t x;` | absent | **no `byte_typespec` at all** — golden emits a bare `array_typespec` with NEITHER field |

`arraySignedWritten8` returns **false** for `f01`/`f05` (clause (b): the written
element is a `TypeAlias`, which its `switch` rejects — that rejection is
r10oth8's own F1 fix). So reusing it would leave `f01`/`f05` **exactly as wrong
as they are today**. The shipped predicate is `et->isSigned()`, which resolves
through the alias, and `f01_btd` reads **EQ** after the patch.

**The clause that DOES transfer is (a)**, and only (a): `f06`/`g06` show golden
carrying neither field for a whole-array typedef, so it is gated out. §3.3
records what happened when it was not.

### 3.3 A measured over-fire, caught before shipping

The first patched build (`0aa2155f3669f4a2ca63ec37b6bd7756`) stamped
unconditionally. Arm `b3` then read `f06_wholetd` as
`ours byte_typespec vpiSigned:1 vpiParent -> byte_var` against golden's
field-less `array_typespec` — **3 dump lines golden does not have**. That is an
over-fire on a MEASURED cell, so clause (a) was added and the build redone
(`6c33528bbc40a08a4ae8e6bad925ebc5`); `f06_wholetd`'s row is now **byte-identical
to the pristine reading**, which is the correct outcome for a cell whose real
residue is the object CLASS (ranked R4), not its fields.

### 3.4 A second, smaller refutation of the brief

The brief located the defect in the class-property arm. That is right, but its
framing ("signedness rides the array_var AND the element TYPESPEC") reads as a
general gap. It is not: arm `b1` cells `m02_data`/`m03_data2` show the
**MODULE-scope twin was already correct at 37ffbd2** — `emitDynArrayVar` already
does `elemTs->VpiParent(reg)` over a typespec `sharedTypespec`/`makeTypespec`
had already signed. **One of the three array_var sites owed the fields, not
three.** Both stamps in the patch are transcribed from that working sibling and
from the working PLAIN-SCALAR sibling (`makeTypespec`'s
`PredefinedIntegerType` arm does `t->VpiSigned(pit.isSigned)`; its caller does
`ts->VpiParent(pc.var)`), so nothing here is invented.

---

## 4. THE TARGET — SVSwitch

### 4.1 Reproduce

```bash
S=<scratch>
SLANG_UHDM=<build>/slang-uhdm python3 scripts/verify_golden.py --corpus surelog \
    --mode both --filter SVSwitch --out $S/svs.csv --workdir $S/svs_wd --jobs 2
cat $S/svs_wd/default/SVSwitch-*/cmds.txt      # names the cached golden
G=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' $S/svs_wd/default/SVSwitch-*/cmds.txt)/golden.uhdm
O=$S/svs_wd/default/SVSwitch-*/slang.uhdm
uhdm-cmp $G $O | tee cmp.log; grep -c '^LHS:' cmp.log       # ONE head per run
uhdm-dump $G | sed 1d > g.dump; uhdm-dump $O | sed 1d > o.dump
diff -u g.dump o.dump > d.diff
grep -E '^[-+]' d.diff | grep -vcE '^(---|\+\+\+) '         # THE DISTANCE
```

### 4.2 What moved

| measure | 37ffbd2 | this pass |
| --- | --- | --- |
| status, both modes | `CMP_NOTEQUAL` | `CMP_NOTEQUAL` (unchanged) |
| cmp heads (`grep -c '^LHS:'`) | 1 | 1 |
| cmp HEAD DEPTH (lines) | 18 | 26 |
| dump DISTANCE (content lines) | 2695 | 2698 |
| head object | `byte_typespec 23:6` | `ref_obj (work@packet::cal_fcs::size) 48:22` |

Our own dump changed by **exactly three added lines, nothing removed**:

```
$ diff -u o.dump.pristine o.dump.patched
@@ -21897,6 +21897,9 @@
   |vpiSigned:1
 \_array_typespec:
 \_byte_typespec: , line:23:6, endln:23:10
+  |vpiParent:
+  \_byte_var: (work@packet::data), line:23:11, endln:23:15
+  |vpiSigned:1
```

**Those three lines are golden's, verbatim.** The reason the DISTANCE still grew
is the listing-ORDER residue the brief told me to leave alone — golden carries
the identical three lines at a different position, so they appear as `+` at our
position and `-` at golden's:

```
$ grep -B3 -A6 'byte_typespec: , line:23:6' d.diff        # post-patch
2662-+\_array_typespec:
2663-+\_byte_typespec: , line:23:6, endln:23:10
2664-+  |vpiParent:
2665-+  \_byte_var: (work@packet::data), line:23:11, endln:23:15
2666-+  |vpiSigned:1
   ...
3972--\_byte_typespec: , line:23:6, endln:23:10
3973--  |vpiParent:
3974--  \_byte_var: (work@packet::data), line:23:11, endln:23:15
3975--  |vpiSigned:1
3976--\_array_typespec:
```

### 4.3 THE ORDER — RE-MEASURED AFTER THE FIELD FIX, AS ASKED. IT DID NOT MOVE.

Top-level listing order of the four `byte_typespec` spans, by
`grep -n byte_typespec` on each dump (the listing occurrence, indent 0):

| | golden | ours @ 37ffbd2 | ours @ this pass |
| --- | --- | --- | --- |
| first group | `41:10`, `43:3` | `23:6`, `41:10`, `43:3` | `23:6`, `41:10`, `43:3` |
| later group | `23:6`, `24:6` | `24:6` | `24:6` |

**Unchanged in both directions.** Our `23:6` element typespec is listed in the
EARLIER group (with the subroutine-local ones) where golden lists it in the
LATER group beside its sibling `24:6` and the `array_typespec`. Ranked **R2**;
it is a parent-policy / last-lister question and it is NOT what the new head is
about — the new head is a `hier_path`/method-call modelling difference at
`Packet.sv:48` (`data.size`), an unrelated cluster (see the campaign's
`hier_path` cluster note).

---

## 5. THE ARM TABLES — 108 CELLS, BOTH SIDES AT OWN CHILD DEPTH

```bash
SLANG_UHDM=<build>/slang-uhdm tools/probe/r10oth9repro/ct9all.sh <tag>
```

The columns are `G:ts` (golden's element-typespec CLASS), `G:tsSigned`,
`G:tsParent`, `G:av` (the array_var's OWN `vpiSigned`, for context), then the
same four for OURS, then the verdict. `-` = the field is ABSENT; `-NOOBJ-` = that
side emits **no object at all**, which is a louder reading and is scored
`UNMEASURED`, never `DIFFER`.

### 5.1 Totals

| | CELLS | EQ | DIFFER (a FIELD disagrees) | DIFFERKIND (different typespec class) | UNMEASURED (one side emits no object) |
| --- | --- | --- | --- | --- | --- |
| 37ffbd2 | 108 | 39 | **52** | 2 | 15 |
| this pass | 108 | **61** | **30** | 2 | 15 |

**Of the 91 cells where BOTH sides emit an object of the same class, 61 agree
and 30 differ**; all 30 are attributed in §8 and **not one of them is in the arm
this law owns** (class-scope dynamic/queue/assoc with an integer-atom element:
20/20 EQ).

### 5.2 Exactly which cells the patch changed — 23 rows, named

```bash
diff <(arms_pristine) <(arms_patched)          # per arm, cell rows only
```

| arm | rows changed | cells |
| --- | --- | --- |
| `b1_ctrl` | 2 | `c02_data`, `c03_data_norand` |
| `b2_elemkind` | 12 | `d01_byte` … `d12_time` (every atom, signed AND unsigned) |
| `b3_typedef` | 2 | `f01_btd` (→EQ), `f05_chain` (SIGNED half fixed, PARENT half is R2) |
| `b4_arraykind` | 6 | `h02_dyn`, `h03_q`, `h04_qb`, `h05_as_str`, `h06_as_int`, `h07_as_wild` |
| `b5_nonintegral` | **0** | — the law never reaches a non-integral element |
| `b6_scope` | 1 | `p01_data` (the class witness) — and **`n01`..`n05` are byte-identical** |

22 of the 23 turned `DIFFER`→`EQ`; the 23rd (`f05_chain`) went
`DIFFER-SIGNED+PARENT` → `DIFFER-PARENT`.

### 5.3 Arm b1 — the control and the target (7/7 EQ)

```
CELL                   G:ts           G:tsSigned  G:tsParent                      G:av | O:ts           O:tsSigned  O:tsParent                      O:av | VERDICT
c01_fcs                byte_typespec  1           byte_var(work@bc::c01_fcs)      1    | byte_typespec  1           byte_var(work@bc::c01_fcs)      1    | EQ
c02_data               byte_typespec  1           byte_var(work@bc::c02_data)     1    | byte_typespec  1           byte_var(work@bc::c02_data)     1    | EQ
c03_data_norand        byte_typespec  1           byte_var(work@bc::c03_data_norand) 1 | byte_typespec  1           byte_var(work@bc::c03_data_norand) 1 | EQ
c04_fcs_rand           byte_typespec  1           byte_var(work@bc::c04_fcs_rand) 1    | byte_typespec  1           byte_var(work@bc::c04_fcs_rand) 1    | EQ
m01_fcs                byte_typespec  1           byte_var(work@b1_top.m01_fcs)   1    | byte_typespec  1           byte_var(work@b1_top.m01_fcs)   1    | EQ
m02_data               byte_typespec  1           byte_var(work@b1_top.m02_data)  1    | byte_typespec  1           byte_var(work@b1_top.m02_data)  1    | EQ
m03_data2              byte_typespec  1           byte_var(work@b1_top.m03_data2) 1    | byte_typespec  1           byte_var(work@b1_top.m03_data2) 1    | EQ
CELLS=7 EQ=7 DIFFER=0 DIFFERKIND=0 UNMEASURED=0
```

At 37ffbd2 `c02_data`/`c03_data_norand` read `ours - / -` — the SVSwitch head
reproduced in a 31-line file (`wc -l b1_ctrl.sv` = 31), with `cmp heads=1
lines=18`, the same head depth SVSwitch itself had. `c01_fcs` is the control the brief named and it was already
right; `m02_data`/`m03_data2` are the module twins and they were already right
too (§3.4).

### 5.4 Arm b2 — element kinds. The 12 ATOM cells all convert; the 6 UNSIGNED ones stay absent

Class side (`d*`), after the patch — the negative controls are the point:

| cell | written element | golden ts `vpiSigned` | ours, after | verdict |
| --- | --- | --- | --- | --- |
| `d01_byte` | `byte` | 1 | 1 | EQ |
| `d02_byteu` | `byte unsigned` | **absent** | **absent** | EQ |
| `d03_bytes` | `byte signed` | 1 | 1 | EQ |
| `d04_int` / `d05_intu` | `int` / `int unsigned` | 1 / absent | 1 / absent | EQ |
| `d06`/`d07` | `shortint` / `shortint unsigned` | 1 / absent | 1 / absent | EQ |
| `d08`/`d09` | `longint` / `longint unsigned` | 1 / absent | 1 / absent | EQ |
| `d10`/`d11` | `integer` / `integer unsigned` | 1 / absent | 1 / absent | EQ |
| `d12_time` | `time` | **absent** | **absent** | EQ |
| `d13`…`d21` | `bit`/`logic`/`reg`, plain and `signed`, scalar and vector | — | — | 4 EQ, **5 DIFFER-SIGNED → R1** |

**The six `unsigned` cells and `time` are the negative control that FIRES**: the
value stamped is `isSigned()`, not a constant 1, so they stay absent. `time`
additionally has no `case` in the switch, matching `makeTypespec`. Module twins
`e01`..`e12` were already EQ (except `e12_time`/`e17_reg`/`e18_regs`, where
golden emits no object → UNMEASURED).

### 5.5 Arm b4 — all four array kinds

| cell | shape | verdict after |
| --- | --- | --- |
| `h02_dyn`, `h03_q`, `h04_qb`, `h05_as_str`, `h06_as_int`, `h07_as_wild`, `h09_dyn2`… | class dynamic / queue / **bounded** queue / assoc `[string]` / `[int]` / `[*]` | **all 6 reached → EQ** |
| `h01_fix`, `h08_fix2`, `h09_dyn2`, `h10_fixdyn`, `h11_dynfix` | class arrays whose element typespec **we do not emit at all** | UNMEASURED (5) — residue **R3** |
| `i01_fix`, `i08_fix2` | module FIXED arrays | DIFFER-PARENT: our element var is an `int_var` where golden has a `byte_var` — residue **R5** |
| `i02`..`i07`, `i09`, `i10`, `i11` | module dynamic/queue/assoc | EQ (already were) |

**All four array kinds behave identically under the law** — that is the answer to
the brief's arm 5, and the bounded queue `[$:7]` is not special.

### 5.6 Arm b5 — non-integral elements: the law changes NOTHING

`0` rows changed. `enum` / signed-enum / packed struct / **signed packed struct**
/ unpacked struct / string / real / class handle / chandle all take neither
PATH_I nor PATH_II's signed stamp. **A predicate of "signed" without a kind list
would have over-fired on `j02_enums` and `j04_structs`** (both `isSigned()`-true,
both golden-absent); the shipped law cannot, because it only ever runs inside the
`PredefinedIntegerType` branch.

### 5.7 Arm b6 — THE SCOPE NEGATIVE CONTROL, and it holds

```
n01_loc_dyn  byte_typespec 1 -   -  | byte_typespec 1 -   -  | EQ
n02_loc_q    byte_typespec 1 -   -  | byte_typespec 1 -   -  | EQ
n03_loc_int  int_typespec  1 -   -  | int_typespec  1 -   -  | EQ
n04_blk_dyn  -NOOBJ-       - -   -  | -NOOBJ-       - -   -  | UNMEASURED
n05_blk_q    -NOOBJ-       - -   -  | -NOOBJ-       - -   -  | UNMEASURED
p01_data     byte_typespec 1 byte_var(work@pc::p01_data) 1 | byte_typespec 1 byte_var(work@pc::p01_data) 1 | EQ
p02_fcs      byte_typespec 1 byte_var(work@pc::p02_fcs)  1 | byte_typespec 1 byte_var(work@pc::p02_fcs)  1 | EQ
```

The subroutine-local cells `n01`..`n05` are **byte-identical pristine vs
patched** (diffed, empty). The law did not leak into `TaskFuncEmit.cpp` /
`StmtEmit.cpp`, and the patch touches neither file. Note the SEPARATE reading
those cells give: at subroutine scope golden's element typespec carries
`vpiSigned:1` and **no `vpiParent` at all**, on both sides — so the PARENT half
of this law is genuinely class/module-scope-bound, and a future pass must not
generalise it.

---

## 6. GATE 3 — u2r ROWS (whole-row, dump column included)

```bash
SLANG_UHDM=<build>/slang-uhdm python3 scripts/verify_golden.py \
    --corpus uhdm2rtlil --mode testflags --jobs 2 \
    --out /tmp/r10oth9out/u2r_pat.csv --workdir /tmp/r10oth9out/wd_u2r_pat
bash tools/probe/r10oth8repro/ct8rows.sh results/gate_uhdm2rtlil.csv \
    /tmp/r10oth9out/u2r_pat.csv
```

```
baseline: 732 lines = 731 ROWS (the header is not a row)
fresh   : 732 lines = 731 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  testflags  base:  679 CMP_EQUAL  50 SLANG_REJECT  2 SURELOG_FAIL
  testflags  fresh: 679 CMP_EQUAL  50 SLANG_REJECT  2 SURELOG_FAIL
  testflags  base:  52  183 differ  496 match
  testflags  fresh: 52  183 differ  496 match
PASS: every row byte-identical to the committed baseline
```

**679 / 50 / 2 and 496 match / 183 differ / 52 blank — exactly the committed
baseline, 0 differing rows.**

## 7. GATE 4 — surelog ROWS

```bash
SLANG_UHDM=<build>/slang-uhdm python3 scripts/verify_golden.py \
    --corpus surelog --mode both --jobs 2 \
    --out /tmp/r10oth9out/sl_pat.csv --workdir /tmp/r10oth9out/wd_sl_pat
bash tools/probe/r10oth8repro/ct8rows.sh results/golden_surelog.csv \
    /tmp/r10oth9out/sl_pat.csv
```

```
baseline: 1589 lines = 1588 ROWS (the header is not a row)
fresh   : 1589 lines = 1588 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  default    base:  467 CMP_EQUAL 13 CMP_NOTEQUAL 5 DEFERRED 284 SLANG_REJECT 25 SURELOG_FAIL
  default    fresh: 467 CMP_EQUAL 13 CMP_NOTEQUAL 5 DEFERRED 284 SLANG_REJECT 25 SURELOG_FAIL
  testflags  base:  463 CMP_EQUAL 10 CMP_NOTEQUAL 5 DEFERRED 3 NO_DATABASE 1 NO_UHDM
                    286 SLANG_REJECT 23 SURELOG_FAIL 1 TIMEOUT 2 UNTRANSLATABLE
  testflags  fresh: (identical)
  default    dump base/fresh:  327 blank / 242 differ / 225 match   (identical)
  testflags  dump base/fresh:  331 blank / 298 differ / 165 match   (identical)
PASS: every row byte-identical to the committed baseline
```

**default 467 / 13, testflags 463 / 10, dump match 225 / 165 — exactly the
committed baseline, 0 differing rows.** `GOLDEN_DEFER` left at its default: the
5 memory-giant tests read `DEFERRED` in both modes, as they must.

---

## 8. GATE 5 — THE BYTE VERIFIER, BOTH CORPORA, AND EVERY MOVER ATTRIBUTED

```bash
SELFCHECK=1 SELFCHECK1=1 bash tools/probe/r10oth6repro/byteverify.sh \
    /tmp/r10oth9out/wd_u2r_pat /tmp/r10oth9out/wd_u2r_pris
SELFCHECK=1 SELFCHECK1=1 bash tools/probe/r10oth6repro/byteverify.sh \
    /tmp/r10oth9out/wd_sl_pat  /tmp/r10oth9out/wd_sl_pris
```

The pristine side is a worktree **this agent configured and built from 37ffbd2**
(§1), not an inherited tree.

| corpus | databases | PATH SETS | MOVERS | SELFCHECK | SELFCHECK1 |
| --- | --- | --- | --- | --- | --- |
| uhdm2rtlil | 679 / 679 | IDENTICAL | **0 / 679** | 678 / 679 flagged | 1 |
| surelog | 953 / 953 | IDENTICAL | **9 / 953** | 952 / 953 flagged | 10 (= 1 corrupted + 9 real) |

Both negative controls fired on both corpora, so a "0 movers" reading here is a
measurement and not a blind comparator.

### 8.1 ALL NINE surelog movers, attributed by DIFFING THE DUMPS

```bash
tools/probe/r10oth9repro/ct9movers.sh /tmp/r10oth9out/wd_sl_pat \
    /tmp/r10oth9out/wd_sl_pris <relpath>
```

| mover | content lines changed | `vpiParent` | `vpiSigned` | element-var headers | `class_typespec` | `vpiTypedefAlias` | attribution |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `default/SVSwitch` | 3 | 1 | 1 | 1 | **0** | **0** | **the law** |
| `testflags/SVSwitch` | 3 | 1 | 1 | 1 | 0 | 0 | the law |
| `default/SimpleUVM` | 59 | 23 | 13 | 23 | 0 | 0 | the law |
| `testflags/SimpleUVM` | 59 | 23 | 13 | 23 | 0 | 0 | the law |
| `default/SeqDriver` | 59 | 23 | 13 | 23 | 0 | 0 | the law |
| `testflags/SeqDriver` | 59 | 23 | 13 | 23 | 0 | 0 | the law |
| `default/Scoreboard` | 59 | 23 | 13 | 23 | 0 | 0 | the law (+ see §8.3) |
| `default/BuildUVMPkg` | 58 | 23 | 12 | 23 | 0 | 0 | the law |
| `testflags/BuildUVMPkg` | 58 | 23 | 12 | 23 | 0 | 0 | the law |

**EVERY changed line in EVERY mover is a `+`. Nothing was removed anywhere.**
`23 + 23 + 13 = 59` and `23 + 23 + 12 = 58` account for the totals exactly, with
no unclassified remainder. The UVM lines are the real reach of the law, named:

```
+|vpiParent:
+\_int_var: (uvm_pkg::uvm_default_report_server::m_severity_count), line:250:13
+|vpiSigned:1
...
uvm_pkg::uvm_default_report_server::m_id_count      uvm_pkg::uvm_reg_block::regs
uvm_pkg::uvm_heartbeat_callback::cnt                uvm_pkg::uvm_reg_block::mems
uvm_pkg::uvm_heartbeat_callback::last_trigger (time — parent only, no signed)
uvm_pkg::uvm_objection::m_drain_time          (time — parent only, no signed)
uvm_pkg::uvm_seed_map::seed_table             (int UNSIGNED — parent only)
uvm_pkg::uvm_seed_map::count                  uvm_pkg::uvm_reg_block::vregs
uvm_pkg::uvm_report_handler::severity_actions uvm_pkg::uvm_sequence_base::m_sqr_seq_ids
uvm_pkg::uvm_report_handler::severity_file_handles
uvm_pkg::uvm_sequence_library::seqs_distrib   uvm_pkg::uvm_sequencer_base::sequence_ids
```

23 objects gain the parent; only **13** gain `vpiSigned`, and the 10 that do not
are the `time` and `int unsigned` properties. **That 23-vs-13 split IS the
negative control firing at corpus scale**, on real UVM source, not on an arm.

### 8.2 THE EXPECTED ~7 ALIAS MOVERS DID NOT APPEAR — a refutation of the brief's prediction

The brief said to expect ~7 UVM byte movers from the build-dependent
`vpiTypedefAlias` / `class_typespec` population and not to call them a
regression. **On this pair that churn did not fire at all**: `class_typespec`
changed lines = **0** and `vpiTypedefAlias` changed lines = **0** in all nine
movers. All 9 movers are this pass's law, and 5 of them (the four UVM tests +
SVSwitch) would have been movers regardless. The brief's expectation is a
DISTRIBUTION, not a constant — this pass drew a zero from it. Stating "~7 of my
movers are the known instability" would have been false here, and the only reason
it is knowably false is that the movers were READ.

### 8.3 Scoreboard — the brief's determinism claim is REFUTED for this test

The brief states "Each binary is deterministic across reps
(`tools/probe/r10oth7repro/ctflake.sh`)". **Not for Scoreboard.** Three reps of
each binary on the Scoreboard command line, same cwd, same inputs:

```
d86aa4ab736cd90b52d59f9d0246fca3  pat1.uhdm
031ac4faa8e3efc0c45574eee64c1dd7  pat2.uhdm
3889ef40071fc811296523f1f362e02b  pat3.uhdm
d446d18f4e8636667c440132e2e331ae  pris1.uhdm
3d3655aaa217d21b27a5f57bb3995fd5  pris2.uhdm
e2672d2c51356f698c66437e6cbe1186  pris3.uhdm
```

**Six reps, six distinct md5s — flaky WITHIN each binary.** r10oth8's own §6/F6
found the same thing for Scoreboard, so the refutation is of the brief's blanket
phrasing, not of r10oth8's measurement. Crucially, the flake and the law have
DISJOINT content signatures, which is why the attribution above still holds:

| comparison | content lines | dominant shapes |
| --- | --- | --- |
| `pat1` vs `pat2` (SAME binary — pure flake) | 78 | `vpiTypedefAlias`, `vpiRange`, `vpiInstance`, `vpiParent` — paired `-`/`+` |
| `pris1` vs `pris2` (SAME binary — pure flake) | 170 | `vpiTaskFunc` ×23 paired, plus the same alias shapes |
| `pris1` vs `pat1` (across binaries) | 151 | the flake shapes **plus** 23 unpaired `+vpiParent`, 13 `+vpiSigned:1` |

The flake is always **paired** `-`/`+` reordering; the law is always **unpaired
`+`**. The sweep pair in §8.1 happened to draw a flake-free Scoreboard, which is
why it read a clean 59.

**Gate on ROWS and dump VERDICTS: neither moved.** `Scoreboard,default` stays
`CMP_NOTEQUAL` with a blank dump column and `Scoreboard,testflags` stays
`SLANG_REJECT` (§9), so the flake is invisible to the gate, exactly as before.

---

## 9. THE CANARIES — ROWS, both scripts, both corpora

```bash
EXPECT_UNKNOWN=6 tools/probe/r10oth7repro/ctcan2.sh results/gate_uhdm2rtlil.csv /tmp/r10oth9out/u2r_pat.csv
EXPECT_UNKNOWN=1 tools/probe/r10oth7repro/ctcan2.sh results/golden_surelog.csv  /tmp/r10oth9out/sl_pat.csv
tools/probe/r10uvm52repro/canaries.sh /tmp/r10oth9out/u2r_pat.csv results/gate_uhdm2rtlil.csv
tools/probe/r10uvm52repro/canaries.sh /tmp/r10oth9out/sl_pat.csv  results/golden_surelog.csv
```

Note the ARGUMENT ORDER DIFFERS between the two scripts (`ctcan2.sh` is
`<baseline> <fresh>`, `canaries.sh` is `<new> <baseline>`); both were called the
way their own header specifies.

| script | corpus | rows compared | changed | absent | unknown | declared EXPECT_UNKNOWN |
| --- | --- | --- | --- | --- | --- | --- |
| `ctcan2.sh` | uhdm2rtlil | 1 | **0** | **0** | 6 | 6 ✓ |
| `ctcan2.sh` | surelog | 58 | **0** | **0** | 1 | 1 ✓ |
| `canaries.sh` | uhdm2rtlil | 8 | **0** | **0** | 25 names | (u2r/surelog split, as its own NOTE states) |
| `canaries.sh` | surelog | 52 | **0** | **0** | 7 names | 7 ✓ |

**`changed=0 absent=0` on all four.** The two names the brief asks for BY NAME:

| test | corpus | baseline | fresh |
| --- | --- | --- | --- |
| `InterfaceModPort` | surelog, default | `CMP_EQUAL / differ` | `CMP_EQUAL / differ` |
| `InterfaceModPort` | surelog, testflags | `CMP_EQUAL / differ` | `CMP_EQUAL / differ` |
| `BlackParrotComplex` | surelog, default | `CMP_EQUAL / differ` | `CMP_EQUAL / differ` |
| `BlackParrotComplex` | surelog, testflags | `CMP_EQUAL / differ` | `CMP_EQUAL / differ` |

Neither test exists in the uhdm2rtlil corpus — `grep -E '^(InterfaceModPort|BlackParrotComplex),'`
on both u2r CSVs returns nothing, in the baseline as well as the fresh sweep, so
"unchanged" there is a statement about ABSENCE and is reported as such rather
than as a pass.

---

## 10. RANKED RESIDUE

Ranking is by **cells the fix would convert × how well it is already
characterised**, and every entry names the arm cells that measure it. None of
these is a regression introduced by this pass; all are pre-existing readings this
pass's instrument made visible.

**R1 — `vpiSigned` on the element typespec of a SIGNED `bit` / `logic` / `reg`
element (11 arm cells, BOTH scopes).** The single biggest residue and the
natural next pass. Cells: `d14_bits`, `d16_logics`, `d18_regs`, `d20_vecs`,
`d21_lvecs`, `f04_written` (class) and `e14_bits`, `e16_logics`, `e20_vecs`,
`e21_lvecs`, `g04_written` (module) — golden `1`, ours absent, `vpiParent`
already correct on every one. Producer: **PATH_II**, the write-phase
`pendingClassPropTs` mint through `makeTypespec`'s scalar/packed arm (grep
`An ELEMENT type with no shared alias`), which is why it is NOT class-scope-only
and why this pass did not touch it: that arm serves every `bit`/`logic` variable
in the design, so it needs its own module-scope arm table before anyone stamps
it. The exact place is marked in the code
(grep `THE HALF THIS PASS DELIBERATELY DID NOT SHIP`).

**R2 — the shared-typedef LAST-LISTER parent, and the listing ORDER (15 arm
cells + the SVSwitch order).** Two faces of one question. (a) For a typedef'd
element golden mints **ONE** typespec shared across every declaration and its
`vpiParent` is whatever listed it LAST — the DESIGN: `f03_setd`/`g03_setd`,
`f05_chain`/`g05_chain`, `j01`–`j05`/`k01`–`k05` all read golden
`design(work@b5_top)` against our per-declaration object parented at its var,
and `g01_btd` reads golden `byte_var(work@fc::f01_btd)` — the CLASS's var — for
the MODULE declaration, which is the same object being shared. (b) SVSwitch's
top-level listing puts our `23:6` in the earlier group and golden's in the later
one (§4.3). Both are parent-policy / last-lister work and both were explicitly
out of scope here. **This is the campaign's `vpiParent`-is-the-last-lister law,
and it did NOT bite this pass** — PATH_I objects are provably fresh (§2) — but it
governs R2 entirely.

**R3 — a class-scope FIXED-size array property emits NO element typespec at all
(5 arm cells).** `h01_fix`, `h08_fix2`, `h09_dyn2`, `h10_fixdyn`, `h11_dynfix`
read `-NOOBJ-` on our side against a fully populated golden object. That is the
loudest class of reading in the whole table and it is a MISSING-OBJECT residue,
not a field one. It is a different exporter arm (the class fixed-array path, not
`emitClassDefn`'s dynamic/queue/assoc arm), and `h09_dyn2` being in this list
says the gap is wider than "fixed": a 2-D `byte x[][]` class property does not
reach the element typespec either.

**R4 — the whole array through a typedef is the wrong typespec CLASS (2 arm
cells).** `f06_wholetd` / `g06_wholetd`: `typedef byte barr_t[]; barr_t x;` gives
golden a bare `array_typespec` and us a `byte_typespec`. Ranked below R3 because
it is 2 cells and shares r10oth8's open residue (its arm a5 `d04`/`d05` found
golden gives that shape no `vpiArrayType` at all). This pass's clause-(a) gate
keeps our fields matching golden's (both empty) so the residue stays exactly
where r10oth8 left it (§3.3).

**R5 — a module-scope FIXED array's element var is an `int_var` where golden has
a `byte_var` (2 arm cells).** `i01_fix`, `i08_fix2`. Small, sharp, fully
characterised: the element VAR CLASS is decided from the wrong type for a fixed
unpacked array of an atom. Surfaces as `DIFFER-PARENT` here only because the
parent's object TYPE is part of the reading.

**R6 — class-handle / `chandle` / `real` element typespec, scope-inverted (2
DIFFER + 3 UNMEASURED = 5 cells).** `j08_handle` (golden has the parent, we have
none) and `k08_handle` (we have it, golden does not) invert between class and
module scope; `j07_real` / `j09_chandle` / `k09_chandle` are `-NOOBJ-` on one
side. Lowest rank: 5 cells, no shared producer identified, and the inversion
means neither direction is safe to guess.

**The three counts add up exactly, which is the point of keeping them apart.**
`DIFFER` 30 = R1 (11) + R2 (15) + R5 (2) + R6 (2).
`DIFFERKIND` 2 = R4.
`UNMEASURED` 15 = R3 (5) + R6 (3) + `e12_time`/`e17_reg`/`e18_regs` (3, golden
emits no object for a module-scope `time`/`reg` dynamic array) +
`f02_pkbtd`/`g02_pkbtd` (2, golden emits no element typespec for a packed-wrapped
typedef element) + `n04_blk_dyn`/`n05_blk_q` (2, NEITHER side emits an object for
a statement-block-local dynamic array — the only cells where `-NOOBJ-` appears on
both sides and therefore the only ones where UNMEASURED means "nothing to
measure" rather than "one side is missing an object").

**R7 — the NEW SVSwitch head, `data.size` (1 test, not this cluster).** Golden
`ref_obj (work@packet::cal_fcs::size)` under a `hier_path (data.size)` spanning
`48:17-48:26`; ours a `method_func_call (size)` under a `hier_path` spanning
`48:17-48:21`. A built-in array-query method call written as a member select —
that is the campaign's `hier_path` cluster, not an array/typespec question, and
it is listed here only so the next SVSwitch pass starts from the measured head
rather than re-deriving it.

---

## 11. WHAT IS IN THIS DIRECTORY

| file | what it is |
| --- | --- |
| `b1_ctrl.sv` | the control (`byte fcs;`) and the target (`rand byte data[];`, and without `rand`), class + module twin |
| `b2_elemkind.sv` | every element kind that reaches the arm — 6 atoms × signed/unsigned, `time`, `bit`/`logic`/`reg` scalar and vector, `bit signed [7:0]` — class + module twin |
| `b3_typedef.sv` | THE TYPEDEF CELL: plain, packed-wrapped, signed-enum, chained, and whole-array-through-typedef |
| `b4_arraykind.sv` | fixed / dynamic / queue / bounded queue / assoc `[string]` `[int]` `[*]` / 2-D combinations |
| `b5_nonintegral.sv` | enum, signed enum, packed struct, **signed** packed struct, unpacked struct, string, real, class handle, chandle |
| `b6_scope.sv` | THE SCOPE NEGATIVE CONTROL — subroutine and block locals beside the class witness |
| `ct9arm.sh` | one arm: run Surelog + ours, dump both, cmp, report HEAD DEPTH and DISTANCE separately |
| `ct9cells.py` | THE CELL EXTRACTOR — descends var → `vpiReg` → `vpiTypespec` → `vpiActual`, then reads the fields at the object's RICHEST occurrence, own child depth only |
| `ct9all.sh` | every arm + the four-way totals (EQ / DIFFER / DIFFERKIND / UNMEASURED) |
| `ct9movers.sh` | attribute a byte mover by diffing the two dumps and classifying the changed lines by content |

Every number in this document is produced by one of those scripts or by a command
quoted beside it. Nothing here is a recollection.

