# r10v137 — ADVERSARIAL VERIFICATION of r10uvm137

**Verdict: ACCEPT WITH FIX.**  Every headline number of `/tmp/r10uvm137.patch`
reproduced bit-for-bit on this verifier's own binaries and workdirs, and the
head really is cleared.  But the law as shipped is **too wide by one variable
kind**, and that width moved a pristine-RIGHT cell to WRONG on legal
SystemVerilog.  The shipped deliverable is
`/tmp/r10uvm137.verified.patch` = the implementer's patch + a two-line gate
narrowing + this directory.

---

## 1. What was reproduced (independent build, independent sweeps)

Fresh worktrees at `194069b`, configured and built `-j 2` from scratch, md5
taken separately, both frozen `chmod 555` before any sweep:

| binary | md5 |
|---|---|
| pristine `194069b` | `47e01d321420bd9bef7d64b46068997e` |
| patched, AS SHIPPED | `c3b7698bf2b28287228753b58c3a544a` |
| patched, WITH THIS VERIFIER'S FIX | `586b8aecec27e616d93eea03fca71f1d` |

The first two are **exactly the md5s the implementer reported**.

Reproduced, all on this verifier's own pinned workdirs:

* goldens 23 PASS / 0 FAIL per binary, `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL;
* uhdm2rtlil both modes, all three binaries: **679 CMP_EQUAL / 50 SLANG_REJECT
  / 2 SURELOG_FAIL**; `ct8rows` 0 differing rows against the committed
  `results/gate_uhdm2rtlil.csv` and against this build's own pristine sweep;
  `byteverify SELFCHECK=1` **MOVERS 0 / 1358** (SELFCHECK 1357/1358);
* surelog `--mode both`, 1588 rows: **937 / 567 / 48 / 19 / 10 / 3 / 2 / 1 / 1**,
  identical pristine and patched; `ct8rows` 0 differing rows over 1588 against
  the committed `results/golden_surelog.csv` and against pristine; **no row
  converted**, `results/*.csv` untouched;
* `byteverify SELFCHECK=1` on surelog: **MOVERS 9 / 956** (SELFCHECK 955/956) —
  precisely the nine names `pred137` predicts a priori from the PRISTINE
  databases alone (`SCANNED=956 CENSUS-FAIL=0 CAN-MOVE=9`, and
  `SCANNED=1358 CAN-MOVE=0` on uhdm2rtlil), and no others;
* order-blind mover attribution: **13 lines per database, 117 total, 0
  unattributed**, every line the law's own object;
* corpus foreach census, 9 UVM databases, **9365 cells**: `LVKINDS` W→R **9**,
  **R→W 0**, `ONLY-GOLDEN 0 / ONLY-OURS 0 / AWAY 0` in every column of every
  row; MiniAmiq's 19 interface-homed cells remain;
* row heads: MiniAmiq both modes **56 → 58, one `^LHS:`**; SeqDriver 17,
  SimpleUVM 64, Scoreboard/default 64, BuildUVMPkg 64, Earlgrey 21302 / 21926,
  Rggen/default 0 — all unchanged.  The four committed
  `head_{pris,pat}_*_MiniAmiq.cmp` logs are **identical to this verifier's own,
  modulo serializer ids**, in both modes.
* cmds.txt audited BY BINARY PATH: surelog 1523 / 1573 name the frozen binary
  and 50 name none (golden-cache-only); uhdm2rtlil 1458 / 1462.  **Zero cells,
  in either corpus and either sweep, name the main-tree binary or a worktree
  `build/slang-uhdm`.**
* canaries `ok=52 changed=0` / `ok=8 changed=0`; `ctcan2` PASS on both corpora;
  `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0
  FENCE-BREACH=0`; InterfaceModPort / BlackParrotComplex / YosysOldOr SAME in
  both modes, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`.

---

## 2. THE BREAK — § `dottedForeachLoopVarBaseMustDrill137` is one kind too wide

### The claim under test

> only a **`class_var`** lets the walk reach the member: every other
> loop-variable kind — `bit_var`, `int_var`, `string_var`, `enum_var`,
> **`struct_var`**, `real_var`, `array_var` — leaves `indexTypespec` null

### Why the grid could not see it

`g137_b_kinds.sv` holds the drilled member name CONSTANT (`wells137`) across
all thirteen bases, and `wells137` is declared in **class `Ingot137` only**.
The `plate137_s` row that stands for `struct_var` therefore fails for a reason
the base KIND did not cause: the struct simply has no member of that name.
That is the self-confirming-grid trap RESUME.md §9 warns about — *an arm
agreeing is not an arm testing*.

### The source

`UHDM::ExprEval::hierarchicalSelector`'s FIRST `variables` arm is
`uhdmstruct_var` (`ExprEval.cpp:2331-2355`), and it searches the base's
`struct_typespec` `Members()` for the element name exactly as the `class_var`
arm searches a `class_defn`'s `Variables()` — and, unlike the `class_var` arm,
it **RECURSES** on a non-last element instead of returning at once.  At level 0
the name it looks for is the BASE's own name, which is not a member of the
base's own struct, so the arm returns nothing and the `level == 0` re-entry
(`ExprEval.cpp:2708-2710`) retries the real member at level 1 — the same
fall-through the `class_var` arm gets.  **A `struct_var` base drills.**

### The measurement (`v137_a_structbase.sv`, both views)

A formal `ref lode137_s f[Wraith137]` gives golden a `struct_var` base and
gives US a `struct_var` base too (the home gate is right), and then:

| written | golden's inner loop variable | pristine | patched AS SHIPPED |
|---|---|---|---|
| `s1.veins137[s2]` (class-keyed member) | `array_var` | `class_var` | `int_var` |
| `s3.spans137[s4]` (string-keyed member) | `int_var` | `string_var` | `int_var` |
| `sd.tile137.hi137[se]` (depth 3) | **`bit_var`** | **`bit_var`** | **`int_var`** ✘ |

The last row is a **RIGHT→WRONG**: `LVKINDS` and `LVTS` both, `#0` in the DEF
view and `#0`+`#1` in the ELAB view — 1 def / 2 elab cells on legal
SystemVerilog (`sd` is the LRM index type `Wraith137`, whose `tile137.hi137`
is a real packed member, so slang accepts the file; Surelog mistypes `sd` as
the ELEMENT `lode137_s`, which also has `tile137.hi137`, and drills it).

`array_var` is NOT a second such case: its arm CONSUMES level 0 (it recurses
with the array's typespec), so the level-1 lookup has a typespec, not a
variable, in hand and answers nothing — the implementer's own R2 measures
golden `int_var` there, and the source agrees.  `struct_var` is the only kind
that was mis-modelled.

### The fix (2 lines of predicate + its citation), `src/StmtEmit.cpp`

```cpp
ob137->second->UhdmType() != UHDM::uhdmclass_var &&
ob137->second->UhdmType() != UHDM::uhdmstruct_var) {
```

Deliberately conservative: a `struct_var` base whose member does NOT exist in
the Surelog-side struct still gives golden the bare `int_var`, and this law now
declines those too.  That costs **three grid cells** (arm A `s4`, arm B `ba`,
arm D `e2`: `WRONG→RIGHT` becomes `WRONG→WRONG`) and **zero corpus cells** —
`pred137` finds no `struct_var` base in any of the 956 + 1358 databases, so
every corpus number above is unchanged by the fix, and the four committed head
logs still match this verifier's fixed binary byte-for-byte modulo ids.

---

## 3. The adversarial grid (6 arms x {def, elab}, 585 foreach cells)

Totals over all twelve arm-views: `LVKINDS` **WRONG→RIGHT 27 as shipped, 19
with the fix**, **RIGHT→WRONG 3 as shipped, 0 with the fix**, **AWAY 0** in
both.  Evidence: `ARMS.v137.txt`.

`armsv137.sh` (arms137.sh with this directory's glob) runs every `v137_*.sv`
under Surelog, the pristine and the patched binary in both views and scores
with `ct137cen` + `score137.py`; each arm in its OWN subdirectory keyed on the
relative path, file list on fd 3, children `</dev/null`, `PROCESSED` asserted,
every rc recorded.  Names are deliberately unalike across arms
(`Wraith137`/`Cavern137`, `Rune137`/`scriptorium137`, `Sigil137`/`Wax137`,
`Bead137`/`Frame137`, `Thread137`/`Loom137`, `Peg137`/`Jig137`; index names
`s1..se`, `b1..ci`, `d1..dq`, `e1..ej`, `f1..h2`, `k1..lc`).

| arm | what it varies | R→W as shipped | R→W with the fix |
|---|---|---|---|
| `v137_a_structbase` | 7 dotted lists whose base type REALLY OWNS the drilled member: struct / class / bit bases, class- and packed-struct-KEYED outers, depth 3 | **1 def / 2 elab** | 0 / 0 |
| `v137_b_homes` | the three ADMITTED homes re-probed: interface-level and module-level arrays and interface/module/task FORMALS x struct / class / bit / string elements; `[i,j]`; a trailing skipped slot; a 3-deep chain | 0 / 0 | 0 / 0 |
| `v137_c_spell` | every spelling in the loop-list slot — plain local, plain property, `this.`, `super.`, `pkg::`, static `Cls::`, formal, package array, two-level `a.b.c` off a class AND a struct base — plus SET HYGIENE: the same loop-variable name reused over an admitted then a non-admitted array (both orders) and a shadowing nest | 0 / 0 | 0 / 0 |
| `v137_d_kinds` | array kinds x key types: assoc (class / packed-struct / string / int / enum keys), queue, dynamic, fixed 1-D, fixed 2-D, a skipped leading slot, a 3-loop-variable chain (wildcard-indexed assoc: `foreach` is illegal, recorded) | 0 / 0 | 0 / 0 |
| `v137_e_mult` | one parameterised module with an admitted module-level array, instantiated 1 / 2 / 3 times, plus a package class used from each and a PROGRAM home | 0 / 0 | 0 / 0 |
| `v137_f_more` | the homes A/B did not reach: static class method, free package function, free package task, `always`, `fork…join_none`, statement-block automatic | 0 / 0 | 0 / 0 |

`AWAY` is **0** in every column of every arm-view, as shipped and fixed.
`ONLY-GOLDEN`/`ONLY-OURS` appear only on the leading/trailing skipped-slot
shapes (buvm34's recorded R2) and are IDENTICAL in pristine and patched.

---

## 4. Boundary

`bound137.sh` over an independently computed list — every `.sv`/`.svh` in every
probe directory that contains a `foreach`, plus the brief's must-stay trees
(`r10uvm77-79`, `r10uvm82-91`, `r10uvm113`, `r10uvm122`, `r10uvm131`,
`r10uvm134`, `r10buvm3-15`, `r10buvm33/34`, `r10sd8-12`) whole, plus this
verifier's own arms — **990 files x both views**, from a COPY of the tree, with
ABSOLUTE paths so `cd $(dirname)` cannot silently miss a subdirectory.  See
`BOUNDARY.v137.txt`.

---

## 5. Ranked residues

1. **R0 (unchanged, and independently reproduced):** MiniAmiq x2, 58 cmp lines,
   one head — `string_var 'values'` at `uvm_component.svh:3380`, the two
   decompiles line-for-line identical except OURS carries `|vpiAutomatic:1` and
   golden carries no `vpiAutomatic` at all.
2. **The struct-var half of this law is unfinished.**  A `struct_var` base whose
   member DOES exist drills in Surelog and answers the member's own typespec;
   this fix declines the whole kind rather than model that.  Three grid cells
   (arm A `s4`, arm B `ba`, arm D `e2`) are given up; corpus incidence zero.
3. **R1 (the implementer's) is confirmed and slightly wider than written:** the
   INDEX rule also covers ALWAYS-block and FORK…JOIN_NONE bodies over
   module-level class-keyed assoc arrays (`v137_f_more` `l2`, `l6`: golden
   `array_var`, ours `class_var`) — same shape as the package/program/
   generate-block cells, identical pristine and patched.
4. **A free package function / task lists its foreach loop variable TWICE with
   the two views swapped** relative to golden (`v137_f_more` `k5`/`k7`/`k9`:
   golden `struct_var` then `ref_var`, ours `ref_var` then `struct_var`).
   Pre-existing, identical pristine and patched, outside this law's face.
