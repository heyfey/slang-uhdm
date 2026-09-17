# r11u57 — ROAD A's ELABORATED HALF: a `$bits` of a type parameter BURIED IN AN OPERATION keeps the call

`§ bitsOfTypeParamInExpr57`

Base `9cc6957a` (matrix-1.87). Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`, `git log --oneline -1`
= `0445655ee7`, the golden producer), uhdm2rtlil v0.68. Two binaries, both
frozen `555` at immutable paths before any sweep: the pristine worktree build,
md5 `a5c8b3e869a33e96fb9bf481ee4eb415` — **byte-identical to the main tree's
`build/slang-uhdm` at the base** — and the law build, md5
`bf7b1b3841621ffe005194bcd9baaf19`.

This pass writes the residue r11u53 named R2 and r11v53 named R1: the
elaborated half of `§ bitsTypeParamArgNeverFolds53` was written for a
WHOLE-Rhs `$bits` only, and the two surviving type-parameter witnesses both
write the call INSIDE a surviving operation.

---

## 0. GATES

| gate | reading |
|---|---|
| 1. build both, md5 | pristine `a5c8b3e869a33e96fb9bf481ee4eb415`, byte-identical to the main tree at `9cc6957a`; law `bf7b1b3841621ffe005194bcd9baaf19` |
| 2. goldens | `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| 3. uhdm2rtlil, both modes | **0 differing rows** against `results/golden_uhdm2rtlil.csv`, `results/gate_uhdm2rtlil.csv` and this pass's own pristine sweep — status AND dump column. 785/19/67 in both modes, unchanged |
| 4. Surelog suite, both modes | 474/9 + 469/8 UNCHANGED, every status- and dump-histogram line identical; the two "differing" rows are workdir text inside a `SURELOG_FAIL` message (§6.2) |
| 5. byteverify `SELFCHECK=1` vs this pass's own pristine workdirs | u2r **4 movers / 1608**, every one predicted BY NAME before the sweep (selfcheck 1607/1608); Surelog **5 movers / 960**, all five the documented UVM-family coin, attributed order-blind AND against a pristine-vs-pristine positive control (§6.2) |
| MOVED-WRONG / AWAY-GOLDEN | **0 / 0** on all four movers, proved as SET containment over the JUDGE-REACHABLE dump (`NOT-PRESENT-BEFORE = 0`), not as a count |
| canaries | u2r `ok=8 changed=0`; suite `ok=52 changed=0`; both `ctcan2.sh` PASS; `canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0`; every protected database byte-SAME at its pinned md5 |
| `results/*.csv` | read, never written |
| fenced tests | never dispatched |

---

## 1. THE TWO WITNESS HEADS, RE-MEASURED AT `9cc6957a`

Pristine binary, both modes, quoted whole in
[evidence/HEAD.base.txt](evidence/HEAD.base.txt). **Neither head is this law's
cell** — both sit IN FRONT of it:

`type_param_packed_dim`, default and testflags, 1 head / 30 cmp lines:

```
LHS: packed_array_var: (work@dut.rt_i), line:8:22, endln:8:26   <- GOLDEN
RHS: logic_var:        (work@dut.rt_i), line:8:22, endln:8:26   <- OURS
     (both carry the same ref_typespec -> packed_array_typespec @5:31)
```

`type_param_override_elem_sel`, default and testflags, 1 head / 23 cmp lines:

```
LHS: logic_typespec: , line:32:17, endln:32:28
     |vpiRange: range @32:23  (left UINT:1, right UINT:0)
RHS: <null>
```

(32:17 is the override actual `child #(.id_t(logic [1:0]))`.)

Both are exactly the heads r11u53 recorded when it landed, so nothing moved
under them in passes 53–55.

**THE KEEP-COUNT CELLS, re-measured at the base** (`shape57.sh`, the shape
lister, [evidence/SHAPES.txt](evidence/SHAPES.txt)) — `Kg`/`Kours` =
`sys_func_call ($bits)` objects per view, `TPg`/`TPours` = `type_parameter`
objects, which is what makes a zero readable:

```
ROW                            VIEW   Kg Kours  TPg TPours  VERDICT
type_param_packed_dim          DEF     2   2     6   6      OK
type_param_packed_dim          ELAB    4   2     9  12      KEEP-COUNT-DIFFERS
type_param_override_elem_sel   DEF     2   2     6   6      OK
type_param_override_elem_sel   ELAB    4   2    10  12      KEEP-COUNT-DIFFERS
```

**THE PREDICTION, MADE LOUDLY BEFORE THE PATCHED SWEEP AND FROM THE KEYED
ARITHMETIC: BOTH ROWS ADVANCE, NEITHER CONVERTS, AND NEITHER HEAD EVEN MOVES.**
This law's cells are the ELAB `param_assign` Rhs of
`localparam int DEPTH = (1 << $bits(<type param>))`, which the official
Compare reaches only AFTER the `packed_array_var` / `logic_typespec` heads
above. Fixing a cell BEHIND the head cannot change the head, cannot change the
cmp line count and cannot convert the row; what it changes is bytes, the
KEEP-COUNT cells and the judge-reachable residue. Measured after: heads
identical, `30` and `23` cmp lines identical, statuses identical, and both
KEEP-COUNT cells now `OK` (§6.1).

---

## 2. THE PRODUCER FACT TRANSFERS — CONFIRMED AT THE PIN, NOT CARRIED FORWARD

`CompileHelper::compileBits`, Surelog `src/DesignCompile/CompileExpression.cpp`:

| claim | line | confirmed at `0445655ee7` |
|---|---|---|
| `compileBits` is the only thing that folds `$bits` | `:4686` | yes |
| the self-upgrade: `m_elabMode && reduce==Reduce::No && tps && isFullySpecified(tps)` → `reduce = Reduce::Yes` | `:4750-4756` | yes, verbatim |
| everything hangs on `getTypespec` | `:4534` | yes |
| … whose bare-name lookup reaches exactly the component's DATA TYPE map and its PORTS and SIGNALS | `:4541-4544` | yes |
| the `else` that emits the surviving `sys_func_call ($bits)` | `:4802` | yes |

**The self-upgrade fires PER EXPRESSION, not per view and not per holder.**
`reduce` is a by-value parameter of `compileBits`; the upgrade writes that
LOCAL copy and it dies with the call. Nothing in the function can see whether
the `$bits` is the whole initializer or one operand of an operation, and the
only thing it can see about the view is `m_elabMode`. A `parameter type` /
`localparam type` lives in the parameter table, which is in neither map, so
`tps` stays null, the upgrade cannot fire, `Bits()` is never called, and the
call survives — in the definition compile AND in the elaborated one, at
whatever depth it stands. The operation AROUND it then cannot reduce either,
because one of its operands is not a constant.

The two-map lookup and the import-shadow door (`§
importedTypeShadowsTypeParam53`, r11v53) apply identically in the elaborated
view: the shadow is a property of the component's data type map, which
`importPackage` (`CompileHelper.cpp:162-169`) fills the same way for both
compiles. Arm `e3_shadow57` measures it rather than assuming it.

---

## 3. THE GOLDEN GRID — EIGHT ARMS

`grid/` holds one design per arm. `run57.sh <binary> <tag>` runs the pinned
Surelog and a chosen binary over each and records **both** rcs
([evidence/RC.txt](evidence/RC.txt): all eight arms `golden_rc=0 ours_rc=0`
under both binaries, so no cell here is an error-recovery reading).
`sites57.sh` derives the `$bits` sites from `dut.sv` — never from a dump — so
a site missing on BOTH sides reads MISSING and can never pass as agreement;
`cell57.sh` prints, per SOURCE SITE and per VIEW, the object kinds each side
carries ([evidence/CELLS.txt](evidence/CELLS.txt)).

### 3.1 `e1_inexpr57` — WHICH BURIED SHAPE (module-body localparams)

ELABORATED view, objects at the `$bits` site, golden vs ours base → law:

| site | shape | golden ELAB | ours base | ours law |
|---|---|---|---|---|
| 21:29 | `(1 << $bits(TP))` | 2 `sys_func_call` | **none** | **2 `sys_func_call`** |
| 22:23 | `$bits(TP) + 1` | 4 `operation` + 2 `sys_func_call` | 2 `constant` | **4 + 2, cell for cell** |
| 23:23 | `$bits(TP) * 2 - 3` | 7 `operation` + 2 `sys_func_call` | 2 `constant` | **7 + 2** |
| 24:32 | `{$bits(TP){1'b1}}` | 2 `sys_func_call` | none | **2 `sys_func_call`** |
| 25:29 | `(1 << $bits(pk::req_t))` CONTROL | — (folded) | — | — unchanged |
| 26:23 | `$bits(TQ)` whole Rhs (the LANDED cell) | 2 | 2 | 2 unchanged |
| 27:23 / 27:35 | `$bits(TP) + $bits(TQ)` — TWO kept calls | 4 `op` + 2 + 2 | 2 `constant` | **4 + 2 + 2** |
| 28:29 | `WID + $bits(TP)` | 2 `sys_func_call` | none | **2 `sys_func_call`** |

Every ELABORATED cell now matches golden count for count. The DEFINITION view
of every one of them was already golden (that is r11u53's half) and is
unchanged.

### 3.2 `e2_holder57` — IS THE HOLDER A GATE? No.

`(1 << $bits(TP))` in the **parameter port list** (10:31 — the shape BOTH
corpus witnesses write), in the module body (16:29), and `$bits(TP) + 3` in a
function-body `return` (19:12). Golden keeps in both views for the first two;
ours base kept in DEF only and now keeps in both. The function body produces
no ELAB object on EITHER side, so it is an agreement cell, not a tested one,
and is reported as such. The body control `(1 << $bits(pk::small_t))` folds on
both sides before and after.

### 3.3 `e3_shadow57` — THE IMPORT-SHADOW DOOR, IN THE ELABORATED VIEW

One module, `import pk::*`, two type parameters: `req_t` (a name the imported
package also exports as a type) and `solo_t` (it does not).

| site | golden DEF | golden ELAB | ours base | ours law |
|---|---|---|---|---|
| 18:29 `$bits(req_t)` SHADOWED | 1 `constant` (FOLDS) | folded | folds | **folds — unchanged** |
| 19:29 `$bits(solo_t)` | 2 `sys_func_call` | 2 `sys_func_call` | DEF only | **both views** |

The door is honoured in the elaborated view exactly as in the definition one,
and it is `typeParamAliasType53` doing it — unchanged, not re-derived.

### 3.4 `e4_typedef57` — THE W3 CELL AS A CONTROL, OPPOSITE POLARITY

A module-local `typedef pk::req_t loc_t` with the call buried:
`(1 << $bits(loc_t))`. Golden KEEPS it in the DEFINITION listing and FOLDS it
in the ELABORATED one; we fold in both. **This pass writes the elaborated
half, so the gate must not resurrect the call here — and it does not:** no
ELAB object at the site on either side, and the arm's DATABASE is
byte-IDENTICAL under both binaries (`armbytes57.sh`: `3dcf3a6fa9ed` →
`3dcf3a6fa9ed`). The built-in-target twin (`typedef logic [9:0] bi_t`) and the
package-scoped control fold on both sides throughout.

### 3.5 `e5_genblock57` — THE GENERATE CONTROL

r11v53's R2: a generate-block localparam is out of both halves' reach. Golden
keeps the type-parameter cell in DEF, ELAB and the tail; we keep it in DEF
only, and in the DEF view we also keep the `$bits(pk::req_t)` CONTROL that
golden folds. Byte-IDENTICAL under both binaries (`6ea8a0d654c4` →
`6ea8a0d654c4`). Left exactly where r11v53 left it.

### 3.6 `e6_override57` — BOTH INSTANCE COPIES OF AN OVERRIDDEN TYPE PARAMETER

The corpus witness `type_param_override_elem_sel`'s own shape. Golden keeps
the parameter-port-list call in the definition copy and in **both** elaborated
instance copies (4 objects at 9:30) and the body call in both (8 `operation` +
4 `sys_func_call` at 13:22). Ours base had the DEF copies only; ours law has
`4` and `8 + 4` — golden's counts exactly, the overridden copy included. The
binding changes; the decision does not.

### 3.7 `e7_pkgiface57` — THE OTHER `DesignComponent` KINDS

| site | golden ELAB | ours base | ours law |
|---|---|---|---|
| 10:30 package `parameter int PW = (1 << $bits(PT))` | 2 | 0 | **2** |
| 11:30 package control `$bits(pk::req_t)` | — | — | unchanged |
| 14:29 interface body `(1 << $bits(IT))` | 4 | 2 | **4** |
| 15:29 interface control | 1 `constant` | 1 `constant` | unchanged |

### 3.8 `e8_reduce57` — THE BOUNDARY THE WIDENED GATE COULD OVERRUN

This arm is why the law is not a containment test. The producer's elaborated
reduce is bottom-up and answers a constant-condition CONDITIONAL with its
TAKEN BRANCH alone, so a `$bits` in the branch that is not taken never reaches
the result. Golden, ELABORATED view:

| cell | golden's elaborated Rhs | ours base | ours law |
|---|---|---|---|
| `T1 = (1) ? 7 : $bits(TP)` | `constant` @14:23 — FOLDED | folded | **folded (agrees)** |
| `T2 = (0) ? 7 : $bits(TP) + 1` | the BRANCH's `operation` @15:33, the conditional GONE | folded | **the branch's operation @15:33** |
| `T3 = (1'b0) && ($bits(TP) > 0)` | the whole `&&` `operation` @16:23 — a short circuit does NOT reduce | folded | **the whole operation** |
| `T4 = (1) ? 7 : $bits(pk::req_t)` CONTROL | `constant` 7 | folded | folded |
| `T5 = ($bits(TP) > 0) ? 7 : 9` | the WHOLE conditional @18:23 — the CONDITION cannot reduce | folded | **the whole conditional** |
| `T6 = 1 + ((0) ? 7 : $bits(TP))` | `1 + $bits(TP)`, the INTERIOR conditional collapsed away | folded | folded — **FENCED, see R3** |
| `T7 = 1 + ((1) ? 7 : $bits(TP))` | `constant` 8 | folded | **folded (agrees)** |

A naive containment gate was BUILT AND MEASURED before the law was written: it
claimed T1 and put a `sys_func_call` where golden has a constant. That reading
is what forced the reachability rule; it is recorded because it was the pass's
one near-miss, not smoothed over.

### 3.9 Direction, per arm

`toward57.sh` — order-blind whole-dump residue against golden under both
binaries; DOWN is toward golden ([evidence/TOWARD.txt](evidence/TOWARD.txt)):

```
ARM                  base_g  base_o   law_g   law_o  DIRECTION
e1_inexpr57             279      99     145      60  TOWARD-GOLDEN (-173)
e2_holder57             109      58      63      57  TOWARD-GOLDEN  (-47)
e3_shadow57              62      57      40      51  TOWARD-GOLDEN  (-28)
e4_typedef57             23      11      23      11  UNCHANGED   (fence)
e5_genblock57            98      40      98      40  UNCHANGED   (fence)
e6_override57           165      47      77      23  TOWARD-GOLDEN (-112)
e7_pkgiface57            81      59      40      43  TOWARD-GOLDEN  (-57)
e8_reduce57             222      62     122      44  TOWARD-GOLDEN (-118)
```

Six arms toward golden, two unchanged — and the two unchanged are exactly the
two the law fences, measured byte-identical rather than merely counted
(`armbytes57.sh`). Zero arms away.

`armsubset57.sh base law` proves the same as a SET over the judge-reachable
sections: seven arms introduce **no** divergence text at all
(`cleared` 15–36, `new=0`), and `e1_inexpr57` introduces exactly 7, all in the
two operand cells named as R2 below.

---

## 4. THE LAW AS WRITTEN

One dispatch site and four helpers, all in the shared header so the two
emitters cannot drift apart.

* `src/EmitHelpers.h`
  * `bitsOfTypeParamCall53(const CallExpression&)` — the call-shape half of
    the landed `bitsOfTypeParamInit53`, factored out unchanged so that
    predicate keeps its exact behaviour and the new one cannot re-derive it.
    The gate underneath is `typeParamAliasType53`, **untouched**, import-shadow
    door (`§ importedTypeShadowsTypeParam53`) included.
  * `bitsOfTypeParamReach57` — is a surviving call REACHABLE in this
    expression? A visitor that prunes a constant-condition conditional to its
    conditions plus its `knownSide()`; slang carries `isConst`/`isTrue` on
    `ConditionalExpression` and exposes exactly that side.
  * `elabCondBranch57` — the sub-expression the producer's reduce carries:
    descend through every TOP-LEVEL collapsible conditional (T2).
  * `interiorCondFold57` — the FENCE: a conditional strictly BELOW the claimed
    root that the producer would collapse and this emission would re-render
    (T6).
  * `bitsOfTypeParamInExpr57` — the three composed; it returns the expression
    to emit FROM, or null.
* `src/ParamEmit.cpp`, the elaborated parameter arm — the same explicit
  `emitExpr` dispatch r11u53 wrote three lines above for the `MinTypMax`
  initializer and for the whole-Rhs `$bits`, now asked of the predicate's
  answer instead of the whole initializer. The per-node gate inside
  `UhdmExporter::srlgBitsFoldArg` still decides each `$bits` on the way
  through, which is why the `$bits(pk::req_t)` control in the SAME initializer
  still folds.

Nothing else changed. `srlgBitsFoldArg` and `bitsOfTypeParamInit53` behave
exactly as they did at the base.

---

## 5. CENSUS AND THE MOVER PREDICTION

`census57.py` splits road A's radius one level finer than r11u53's
`census.py`: per USE SITE, is the `$bits(<type parameter>)` the ENTIRE Rhs of
its parameter assignment (already golden since r11u53) or BURIED in one
([evidence/CENSUS.blastradius.txt](evidence/CENSUS.blastradius.txt))? Over
`uhdm2rtlil/test`, `Surelog/tests` and `Surelog/third_party/tests`:

| corpus | dir | buried / whole | is it a ROW? | predicted |
|---|---|---|---|---|
| u2r | `type_param_packed_dim` | 1 / 0 | yes, `CMP_NOTEQUAL` ×2 | **MOVER**, ADVANCE, head unchanged |
| u2r | `type_param_override_elem_sel` | 1 / 0 | yes, `CMP_NOTEQUAL` ×2 | **MOVER**, ADVANCE, head unchanged |
| u2r | `cva6_equiv` | 11 / 3 | **not a discovered row** | — |
| u2r | `bits_of_type_param` | 0 / 1 | row, `CMP_EQUAL` ×2 | NOT a mover (whole-Rhs only) |
| sl | `ClassScope` | 2 / 0 | row, `SLANG_REJECT` ×2 | no database, no mover |
| sl3p | `ariane` (`Ariane`) | 4 / 0 | row, `SURELOG_FAIL` ×2 | no database, no mover |
| sl3p | `Ariane2024` | 0 / 1 | row, `SLANG_REJECT` / `NO_DATABASE` | no database, no mover |
| sl3p | `Verilator` | 0 / 1 | row, `SLANG_REJECT` ×2 | no database, no mover |

The four Surelog-corpus entries were CHECKED in this pass's own pristine
workdir, not assumed: none of their row directories holds a `slang.uhdm` at
all (`ClassScope`, `Ariane2024`, `Verilator` hold only `cmds.txt`; `Ariane`
holds `cmds.txt` and an `slpp_all`). The Surelog side's zero is a zero with a
reason.

`cva6_equiv` and `ibex` are in the corpus tree but are not discovered rows —
neither appears in `results/golden_uhdm2rtlil.csv`.

**THE PREDICTION BY NAME, BEFORE THE PATCHED SWEEPS: exactly FOUR databases
move — `type_param_packed_dim` and `type_param_override_elem_sel`, in both
modes — and nothing else in either corpus.**

`param_type_logic_width` is the census's near-miss control: it declares
`parameter type dtype` but its `$bits(a)` / `$bits(b)` name SIGNALS, so the law
cannot reach it; it is `CMP_EQUAL` in both modes and predicted not to move.

**POSITIVE CONTROL for the census.** A counter of fold sites reads zero both
when the construct is absent and when it never reached the database.
`shape57.sh` prints the `sys_func_call ($bits)` inventory BESIDE the
`type_parameter` inventory per view and per side, and reports `OUT-OF-REACH`
rather than agreement when both sides carry no `type_parameter`:
`param_type_logic_width` reads `K = 0` on both sides with `TP` present on both
— a genuine zero with the construct in the counter's reach.

---

## 6. WHAT THE PATCHED SWEEPS MEASURED

### 6.1 uhdm2rtlil

`byteverify.sh` over 1608 databases (both modes), law workdir vs this pass's
OWN pristine workdir, `SELFCHECK=1`
([evidence/GATES.uhdm2rtlil.txt](evidence/GATES.uhdm2rtlil.txt)):

```
PATH_SETS_IDENTICAL (1608 paths)
MOVER ./default/type_param_override_elem_sel-…   MOVER ./testflags/type_param_override_elem_sel-…
MOVER ./default/type_param_packed_dim-…          MOVER ./testflags/type_param_packed_dim-…
MOVERS: 4 / 1608
SELFCHECK (every file vs one fixed file): 1607 / 1608 flagged
```

**Four movers, and they are the four predicted by name. Nothing else moved.**
Every `cmds.txt` in both sweeps was audited BY BINARY PATH: 1742 files each,
1742 naming `/tmp/r11u57_law.bin` and 1742 naming `/tmp/r11u57_pris.bin`
respectively.

**Rows: ZERO differing.** `ct8rows.sh` against `results/gate_uhdm2rtlil.csv`,
against this pass's own pristine testflags sweep and against its own pristine
default sweep all read `PASS: every row byte-identical`; a direct join against
`results/golden_uhdm2rtlil.csv` (which holds BOTH modes) reads **0 differing
rows in each mode**, status and dump column alike. 785/19/67 in both modes.

**HEADS AND DIRECTION, per mover** — exactly as predicted in §1:

| row | head before | head after | cmp lines | judge-reachable residue (golden-only / ours-only) |
|---|---|---|---|---|
| `type_param_packed_dim` | `packed_array_var (work@dut.rt_i)` 8:22 | **unchanged** | 30 → 30 | 28/46 → **6/40** |
| `type_param_override_elem_sel` | `logic_typespec` 32:17, `RHS: <null>` | **unchanged** | 23 → 23 | 27/35 → **5/29** |

identical in both modes. The KEEP-COUNT cells cleared:

```
ROW                            VIEW   Kg Kours  TPg TPours  VERDICT   (was)
type_param_packed_dim          ELAB    4   4     9  12      OK        (4 / 2 KEEP-COUNT-DIFFERS)
type_param_override_elem_sel   ELAB    4   4    10  12      OK        (4 / 2 KEEP-COUNT-DIFFERS)
```

and `bits_of_type_param` — r11u53's CONVERTED row — keeps `Kg=Kours` 2/2 DEF
and 4/4 ELAB and stays `CMP_EQUAL` in both modes, as the landed law requires.

**MOVED-WRONG 0 / AWAY-GOLDEN 0, proved as a SET containment over the
JUDGE-REACHABLE dump** (`subsetsec57.sh`, `uhdmallModules:` …
`weaklyReferenced:`), for all four movers:

```
default   type_param_packed_dim         judge gonly/oonly 28/46 -> 6/40   texts 44 -> 24   new 0
default   type_param_override_elem_sel  judge gonly/oonly 27/35 -> 5/29   texts 39 -> 19   new 0
testflags type_param_packed_dim         judge gonly/oonly 28/46 -> 6/40   texts 44 -> 24   new 0
testflags type_param_override_elem_sel  judge gonly/oonly 27/35 -> 5/29   texts 39 -> 19   new 0
```

**The change is confined to the ELABORATED listing, and that is measured, not
argued** ([evidence/VIEWSPLIT.txt](evidence/VIEWSPLIT.txt)). For all four
movers the `uhdmallModules:` DEFINITION section and the `weaklyReferenced:`
TAIL are byte-IDENTICAL before and after; only the `uhdmtopModules:` section
grows, by 16 lines on each row in each mode — the kept `sys_func_call` tree
replacing one folded constant.

**One reading that needs its explanation, and gets it rather than a footnote.**
The inherited WHOLE-dump prover (`subset57.sh`, tail included) reports 5 new
ours-only line TEXTS on `type_param_packed_dim`. They are a cross-section
multiset artifact, measured to the exact indentation depth
([evidence/TAILARTIFACT.txt](evidence/TAILARTIFACT.txt)):

```
occurrences of '        |UINT:1'     whole / judge sections / weaklyReferenced tail
  golden      6 / 2 / 1
  ours base   6 / 1 / 2     <- whole-dump total EQUAL to golden, so no diff line
  ours law    7 / 2 / 2     <- the JUDGE sections now MATCH golden (1 -> 2)
```

Our `weaklyReferenced` tail is byte-identical before and after (a `cmp` of the
section passes), so nothing moved there; the whole-dump total changed only
because the judge-section DEFICIT that used to cancel a pre-existing tail
SURPLUS is gone. The tail is unreachable to `uhdm-cmp` (RESUME §9), and
`uhdm-cmp` itself reads the same head and the same 30 cmp lines before and
after.

### 6.2 The Surelog suite

[evidence/GATES.surelog.txt](evidence/GATES.surelog.txt).

**Row join.** `ct8rows.sh` against the committed `results/golden_surelog.csv`
AND against this pass's own pristine control: the per-mode STATUS histograms
are IDENTICAL on every line —

```
default    474 CMP_EQUAL   9 CMP_NOTEQUAL   5 DEFERRED  285 SLANG_REJECT  25 SURELOG_FAIL
testflags  469 CMP_EQUAL   8 CMP_NOTEQUAL   5 DEFERRED    3 NO_DATABASE    1 NO_UHDM
           286 SLANG_REJECT  23 SURELOG_FAIL   1 TIMEOUT   2 UNTRANSLATABLE
```

and so are both DUMP-column histograms (default 324 blank / 248 differ / 226
match; testflags 329 / 303 / 166). The only two differing rows are `LowMemLib`
and `LowMemPkg` in testflags, whose `SURELOG_FAIL` detail string quotes the
WORKDIR PATH inside a Surelog log message — and the same two rows differ
between the committed baseline and this pass's PRISTINE control for the same
reason, so it is workdir text, not a status change. **474/9 and 469/8 stand.**

**Binary audit.** Each sweep holds 1581 `cmds.txt`; 1531 carry a `slang:`
line, and in the law sweep all 1531 name `/tmp/r11u57_law.bin` while in the
pristine sweep all 1531 name `/tmp/r11u57_pris.bin`. No other `slang-uhdm`
path appears in either.

**byteverify `SELFCHECK=1`, law vs this pass's own pristine:**

```
PATH_SETS_IDENTICAL (960 paths)
MOVER ./default/MiniAmiq-…     MOVER ./testflags/MiniAmiq-…
MOVER ./default/SeqDriver-…    MOVER ./testflags/SeqDriver-…
MOVER ./default/SimpleUVM-…
MOVERS: 5 / 960
SELFCHECK (every file vs one fixed file): 959 / 960 flagged
```

**Predicted movers on this corpus: ZERO, and the zero has a reason** — none of
the four census directories that carry the construct produces a `slang.uhdm`
at all (§5). **The five observed movers are the documented UVM-family coin,
attributed rather than waved through**, by two independent measurements:

1. **Order-blind attribution** (uhdm-dump, path-normalised, sorted). Every one
   of the five is the SAME 4-line class and nothing else — a
   `UINT`/`vpiDecompile` pair whose value is a LINE NUMBER:
   MiniAmiq/default `986 ↔ 1499`, SeqDriver/default `0 ↔ 1003`,
   SimpleUVM/default `1328 ↔ 1072`, MiniAmiq/testflags `0 ↔ 954`,
   SeqDriver/testflags `1518 ↔ 779`. No structural line moves in either
   direction.
2. **POSITIVE CONTROL — the PRISTINE binary against ITSELF.** Two further
   sweeps of the same three tests with `/tmp/r11u57_pris.bin` and no code
   change whatever:

```
MiniAmiq   run1 b4f2ec65fedc  run2 7ba770b783a7   (sweep pristine ace6c1774ad3, law 1dddb5915f8d)
SeqDriver  run1 e4ef218438f1  run2 dc3c627f2997   (sweep pristine 2fb39f8b4130, law 3710fac61779)
SimpleUVM  run1 d4f8cd018f2d  run2 d4f8cd018f2d   (a 0-line draw, the documented other face)
```

   Four distinct MiniAmiq hashes and four distinct SeqDriver hashes are now on
   record from binaries that differ in one dispatch line, and all six control
   runs are `CMP_EQUAL`. The control closes on the SAME CLASS, not merely on
   "some difference": read order-blind, pristine run1 vs pristine run2 differs
   in exactly `orderblind_diff_lines=4`, `UINT:1007 ↔ UINT:840` /
   `vpiDecompile:1007 ↔ vpiDecompile:840` (MiniAmiq) and
   `UINT:1424 ↔ UINT:1035` (SeqDriver) — the identical line-number pair the
   cross-binary comparison showed, produced by a binary that did not change.

**Statuses did not move.** MiniAmiq, SeqDriver, SimpleUVM, BuildUVMPkg and
Earlgrey_0_1 are `CMP_EQUAL` in both modes under both binaries; Scoreboard is
`CMP_EQUAL`/`SLANG_REJECT` as committed. `rowheads.sh` on the law workdir
reads `cmp rc=0`, `0` heads and `0` cmp lines for all eleven measured cells
(the one `SKIP-NOFILE`, Scoreboard/testflags, is the documented expected one).

**PROTECTED DATABASES, BY NAME** (md5, pristine → law, both modes, all SAME):

```
SVSwitch            4842211c4030   (HARD PIN, both modes)
YosysVerx           6ccda350c24a   (HARD PIN, both modes)
InterfaceModPort    59a365f3ce2c
BlackParrotComplex  e3e354129d5a / 73a10e8217e5
YosysOldOr          d68e0796d62c
Earlgrey_0_1        default 8bdf25272e08, testflags 59d0ee6d10c3 — CMP_EQUAL both modes
```

**Battery.** `canaries.sh` `ok=52 changed=0 absent=0`; `ctcan2.sh`
`ok=58 changed=0 absent=0`, PASS; `canaudit.sh` `audited=29 UNCOVERED=0
FENCE-BREACH=0`. On uhdm2rtlil, `canaries.sh` `ok=8 changed=0 absent=0` and
`ctcan2.sh` PASS.

---

## 7. RESIDUES THIS PASS LEAVES OPEN, NAMED

* **R0 — THE NEXT HEAD, unchanged and now unmasked.**
  `type_param_packed_dim`'s head is `packed_array_var (work@dut.rt_i)` at
  `8:22` against our `logic_var` — a port declared with a `localparam type
  rt_t = resp_id_t [DEPTH-1:0]` gets the wrong VARIABLE KIND on our side while
  both sides' `ref_typespec` points at the same `packed_array_typespec`.
  `type_param_override_elem_sel`'s is `logic_typespec` at `32:17` with
  `RHS: <null>` — the override actual `.id_t(logic [1:0])` has no typespec on
  our side at all. Road A's fold work on these two rows is now DONE: their
  `$bits` inventories match golden in both views and both modes.
* **R1 — a REDUCIBLE OPERAND beside the surviving call still reduces in
  golden's elaborated view; we re-render the source syntax.** Two faces, one
  family, both measured on `e1_inexpr57` and both the pass-49/55 substitution
  family:
  * `WID + $bits(TP)` (28:23) — golden's DEF listing keeps `ref_obj
    (work@dut.WID)` and its ELAB listing substitutes `constant UINT:5 size 32`;
    we emit the DEF-shaped `ref_obj` in both. The machinery exists
    (`misevalParamRhsScope` + ExprEmit's `§ elabMisevalRefSubst` arm, which
    needs `paramRhsObj` for the sibling); it is NOT switched on here because
    its blast radius is every elaborated parameter Rhs.
  * `{$bits(TP){1'b1}}` (24:41) — golden's DEF listing and ours BOTH carry the
    inner concat as `operation` opType 33 over `constant 1'b1`; golden's ELAB
    listing collapses it to one `constant BIN:1` at the concat's own span
    (24:41-24:47) while we re-render the concat.

  Neither reaches the corpus: both witnesses' surviving operand is the literal
  `1`, and their `param_assign` trees come out byte-identical to golden
  (quoted in §6.1's evidence).
* **R2 — a kept operation Rhs on a RANGED parameter carries no `ref_typespec`.**
  `e1_inexpr57`'s new head: golden gives the elaborated `operation` at 24:31 a
  `ref_typespec (work@dut) -> logic_typespec`, we give it none. An `int`
  holder's operation DOES get it on our side (S1, T2 — verified against golden
  field for field), so this is the ranged-parameter arm of the existing
  operation-Rhs typespec rule, not something this law removed. Grid-only: the
  corpus witnesses are `localparam int`.
* **R3 — an INTERIOR conditional the producer collapses is FENCED.**
  `1 + ((0) ? 7 : $bits(TP))` — golden's elaborated Rhs is `1 + $bits(TP)`
  with the conditional gone; claiming it would require REWRITING the emitted
  tree, so `interiorCondFold57` refuses and the initializer stays folded
  exactly as at the base (`e8_reduce57` T6). Not a regression; a named hole.
* **R4 — generate-block localparams remain out of both halves' reach**
  (r11v53's R2, arm `e5_genblock57`, byte-unchanged here), and **R5 — the W3
  cell** (a module-local typedef of a package-scoped name: golden DEF-keep /
  ELAB-fold, arm `e4_typedef57`, byte-unchanged here) are carried forward
  untouched and re-measured, not assumed.

---

## 8. HOW TO RE-RUN EVERYTHING

```bash
R=tools/probe/r11u57repro
bash $R/run57.sh <pristine binary> base      # golden + ours per arm, rc on BOTH sides
bash $R/run57.sh <law binary>      law
bash $R/cell57.sh <arm> <tag> $(bash $R/sites57.sh <arm> | cut -f1)
bash $R/toward57.sh                          # per-arm direction
bash $R/armbytes57.sh base law               # which arms moved AT ALL (the fences)
bash $R/armsubset57.sh base law              # per-arm new divergence TEXTS
python3 $R/census57.py                       # the buried-vs-whole blast radius
bash $R/shape57.sh <rowdir> [...]            # the census's positive control
bash $R/dumpdiff57.sh <rowdir> <outprefix>   # whole-dump residue for a corpus row
bash $R/subsetsec57.sh <pristine rowdir> <law rowdir>   # AWAY-GOLDEN, judge sections
bash $R/subset57.sh    <pristine rowdir> <law rowdir>   # the whole-dump twin
SELFCHECK=1 bash $R/byteverify.sh <law workdir> <pristine workdir>
```

`canaries.sh`, `ctcan2.sh` and `canaudit.sh` are the current-generation
battery (`r10uvm221repro`), carried here unmodified so the audit runs in this
directory. Grid run artifacts (a Surelog tree, two databases and four dumps
per arm) are regenerated by `run57.sh` and are not committed; `evidence/`
carries the distilled readings.

| file | what it holds |
|---|---|
| `evidence/RC.txt` | every arm's `golden_rc`/`ours_rc` on both binaries |
| `evidence/CELLS.txt` | the site-keyed, view-sectioned cell inventory, both tags |
| `evidence/HEAD.base.txt`, `evidence/HEAD.law.txt` | the two witnesses' heads, quoted whole, both modes |
| `evidence/HEADS.arms.txt` | each arm's `uhdm-cmp` head before and after |
| `evidence/TOWARD.txt` | direction, arm bytes and the per-arm subset proof |
| `evidence/SHAPES.txt` | the shape lister, both modes, both binaries |
| `evidence/CENSUS.blastradius.txt` | the buried/whole census over both corpora |
| `evidence/GATES.uhdm2rtlil.txt` | byteverify, the cmds audit, the row joins, both subset provers |
| `evidence/TAILARTIFACT.txt` | the whole-dump prover's 5 texts, resolved to the tail |
| `evidence/VIEWSPLIT.txt` | DEF and TAIL byte-identical; only the ELAB listing moves |
| `evidence/GATES.surelog.txt` | the suite's row joins, byte verification and battery |
