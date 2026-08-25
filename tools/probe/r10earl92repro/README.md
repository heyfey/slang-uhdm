# r10earl92 — § elabCaTernaryArmInstall92

**THE ELABORATED cont_assign's Rhs IS THE SELECTED ARM, NOT THE TERNARY.**

Base `c366a17`, branch `auto5h`. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; every
instrument in this directory is MEASUREMENT ONLY.

---

## 1. The head this pass took

`Earlgrey_0_1`, **both modes**, 1 head each (250 / 278 cmp lines at
`c366a17`), the same cell:

```
hw/ip/aes/rtl/aes_key_expand.sv:10    parameter bit AES192Enable = 1,
hw/ip/aes/rtl/aes_key_expand.sv:109
  assign spec_in_192 = AES192Enable ? key_i[5] ^ key_i[1] ^ key_i[0] : '0;

instance work@top_earlgrey.u_aes.aes_core.aes_cipher_core.aes_key_expand

  LHS (golden)  operation 109:39-109:69  vpiOpType 30 (vpiBitXorOp), 2 operands
  RHS (ours)    operation 109:24-109:74  vpiOpType 32 (vpiConditionOp), 3
```

Every object BELOW golden's is identical to ours ID for ID — the same two
`bit_select key_i` operands, the same folded `5` / `1` / `0` indices at
`vpiSize 64` / `vpiUIntConst`. The defect is one level up: the elaborated
`cont_assign`'s `Rhs` is golden's XOR where ours is the whole ternary, so the
SINGULAR `SafeCompare` names the two VALUES and the head is a FOLD-PRESENCE
cell, not a field of one object.

`HEAD_BEFORE_Earlgrey_{default,testflags}.cmp` and
`HEAD_AFTER_Earlgrey_{default,testflags}.cmp` are the pristine and patched
head logs, verbatim.

---

## 2. The law, decoded from Surelog and UHDM

### 2.1 Which cont_assign can fold at all — `UhdmWriter::writeCont_assign`

`Surelog src/DesignCompile/UhdmWriter.cpp:2090` reduces the elaborated Rhs in
TWO places, and **only one of them writes a NON-constant back**:

1. `if (lhs->UhdmType() == uhdmref_obj)` (**:2121**) — a WHOLE-SIGNAL Lhs that
   `bindVariable` resolves. It clones the cont_assign, runs
   `CompileHelper::reduceExpr` over the WHOLE Rhs and then
   ```cpp
   if ((invalidValue == false) && rhstmp) assign->Rhs((expr*)rhstmp);
   ```
   installing **whatever came back**, operation or constant.
2. the trailing `if (simplified == false)` arm (**:2264**) installs the result
   only `if (res->UhdmType() == uhdmconstant)`.

So a fold to an **arm expression** reaches the database through arm 1 alone —
i.e. **only for a plain `ref_obj` Lhs**. Grid `g1` measures every other Lhs
shape on real Surelog and every one keeps the ternary (§4).

`CompileHelper::reduceExpr` (`CompileExpression.cpp:823`) hands the work to
`UHDM::ExprEval::reduceExpr` with a value functor that consults
`instance->getValue(name)` **first**, so the reduce reads THIS INSTANCE's own
parameter values — the per-instance split grid `g2`/`g5` measure.

### 2.2 Which object is installed — `ExprEval::reduceExpr`'s conditionOp arm

`UHDM templates/ExprEval.cpp:3763`:

```cpp
case vpiConditionOp:
  if (operands.size() == 3) {
    cond    = reduceExpr(operands[0], invalidValue, ...);
    condVal = get_value(invalidValue, cond);
    if (invalidValue) break;                    // NO FOLD AT ALL
    the_val = reduceExpr(condVal ? operands[1] : operands[2],
                         localInvalidValue, ...);
    if (localInvalidValue == false) {
      val = get_value(localInvalidValue, the_val);
      if (localInvalidValue == false) result = <constant INT:val, size 64>;
      else                            result = the_val;
    } else                            result = the_val;
  }
```

The `INT:val` outcome is **already modelled** — by
`§ elabCaTernaryFoldIntConst22` on this very path and by
`§ srlgCondOpInstValueTernFold9` on the select-Lhs path. **This law owns the
other outcome, `result = the_val`**: the arm Surelog reduced but could not
value. For an operation whose `VpiOpType` has no `case` in that switch
(`vpiBitXorOp`, the head's, has none) `reduceExpr` returns the arm object
**untouched** — which is why golden's Rhs and our operand subtree are already
identical ID for ID below it.

### 2.3 The operand gate — `constantOperands`

Same function, `ExprEval.cpp:3021`. It walks **all three operands, the
UNTAKEN arm included**, and abandons the ENTIRE reduce unless every one is a
`constant`, an `operation`, a `sys_func_call`, a `func_call`, a `bit_select`,
a `hier_path`, a `var_select`, an `enum_var`, or a `ref_obj` **whose name has
a value**. `part_select` and `indexed_part_select` are NOT on that list. The
gate is **one level deep only**: `sig ^ k[5]` is an `operation` operand and
folds even though a bare signal sits inside it.

### 2.4 Two arm shapes refuse even though the gate passes them

* a **bare `hier_path` arm** — `reduceExpr`'s `uhdmhier_path` branch
  (`ExprEval.cpp:4721`) returns `decodeHierPath(..., ReturnType::VALUE)`,
  which is `nullptr` for a signal read, and writeCont's `&& rhstmp` then
  refuses the write-back entirely. A hier_path INSIDE an operation arm folds.
* an arm that is a **constant `get_value` cannot read** (x/z, wider than 64
  bits, a real, a string). Golden installs the arm's OWN constant object with
  its own encoding, width and location — a different mint. **Not claimed
  here**; residue R1, 0 corpus cells.

### 2.5 The chain, and the two views

A ternary whose selected arm is another ternary reduces again, so the walk is
a loop that stops at the FIRST node whose condition Surelog cannot value —
installing THAT node, ternary and all. At the TOP level the same failure means
no fold, which is what we already emit, so at least one level must fold.

The **DEF view never folds** (`writeCont_assign` runs over NETLISTS; all 79
DEF rows on g1–g6 keep their ternary), and a **generate-scope home never
folds** either — those cont_assigns never reach `emitContAssigns`, whose only
three callers pass an `InstanceBodySymbol`, so the fence is structural, and
`g5 h_genfor` / `h_genif` / `h_genblk` confirm it three ways.

---

## 3. The change

`src/ModuleEmit.cpp`, inside `emitContAssigns`, immediately after
`§ elabCaTernaryFoldIntConst22` (so the constant outcome still wins) and
before the general emit. It computes `ternArm92` — the selected arm — and the
general emit then runs `emitExpr(*ternArm92, ca, prefix, rhsMap)` **through
the very same machinery** (the reemit collector, the def-view net map, the
parenting rules) that would have emitted it inside the ternary. Nothing else
moves.

Two run-time switches ship with it, the earl90/91 pattern:

* `R10E92_OFF=1` — restores pristine behaviour in the shipped binary (the A/B
  gate; §5).
* `R10E92_CELLDBG=1` — names EVERY cont_assign the site reaches with both
  answers, not only the shape the law changes (earl66's rule). The predicate
  is computed OUTSIDE the OFF switch so the OFF binary still names both.

---

## 4. The grid (ARMS.r10earl92.txt)

Six purpose-built arms, each built with **real Surelog** (the golden), the
frozen pristine binary and the frozen patched binary, and censused with
`ct92cen`. One line per cont_assign cell, the agreeing cells included.

**60 cells FIXED, 0 BROKE, 7 DIFF — and every one of the 7 is a cell no law
here owns and none of them moved.**

| grid | what it crosses | key results |
|---|---|---|
| `g1_ctx92.sv` | **CONTEXT** × the head's arm | ref_obj Lhs → ARM; bit_select / part_select Lhs → no elab copy; hier_path Lhs, concat Lhs, net-decl-assign, procedural assignment, port high_conn → TERNARY kept; ternary as an OPERAND of a larger op → inner ternary kept; nested ternary → folds two levels |
| `g2_cond92.sv` | **CONDITION shape** × 2 instances | bare parameter / localparam / parameter expression / package parameter (bare and `pkg::`-qualified) / `P == 2` / `$clog2(P)>2` all FOLD, and the OVERRIDDEN instance picks the OTHER arm; a non-constant signal condition KEEPS; a **genvar** condition KEEPS |
| `g3_arm92.sv` | **ARM shape** | xor-of-selects, bit_select, concat, replication, cast, unary, add, shift, reduction, user `func_call`, unimplemented `$countones` all install the ARM; literal / `'1` / foldable / parameter / `$clog2` fold to a CONSTANT (already right); bare signal and bare `hier_path` KEEP |
| `g4_gate92.sv` | **the operand gate** | untaken constant / bit_select / var_select / hier_path / operation / valued ref_obj → FOLDS; untaken **bare signal** → KEEPS; `st.m1 ^ k[5]` (hier_path inside an operation) → FOLDS; `sig ^ k[5]` (bare signal inside an operation) → FOLDS |
| `g5_home92.sv` | **HOME** × 1–3 instances | module home and a 3-deep instance chain FOLD; **gen-for / gen-if / named gen-block KEEP**; three instances of one module each pick their own arm; a nested ternary with a NON-constant inner condition installs the INNER TERNARY verbatim |
| `g6_shapes92.sv` | **part_select and friends** | a bare `part_select` or `indexed_part_select` in ANY of the three operand positions KEEPS the whole ternary (it is not on `constantOperands`' list); the same select INSIDE a concat FOLDS; an assignment-pattern arm FOLDS; an enum-typed PORT read (a ref_obj with no value) KEEPS |

The 7 residual DIFF cells, all pre-existing and all unchanged by this pass:
`g1 c_ca_member_s.m1` and `g1 {c_ca_cat_a,c_ca_cat_b}` (golden emits a fresh
elab copy, we emit none — residue R4); `g4 f_arm_xz` and `g6 p_arm_real` (the
poisoning-constant arm — residue R1); `g5 h_genfor` ×3 (golden substitutes the
parameter's value into a gen-for condition — residue R3).

---

## 5. Gates (GATES.r10earl92.txt)

All green; the numbers are in `GATES.r10earl92.txt` and summarised here.

* build both binaries, md5s recorded, both frozen `chmod 555` at immutable
  paths **before any sweep**; every `cmds.txt` audited BY BINARY PATH —
  **0 of 1462 + 1573** name the main-tree binary.
* goldens **23 PASS / 0 FAIL** on both binaries; `SLANG_UHDM=/bin/false`
  gives **0 PASS / 23 FAIL** (the negative control).
* `u2r` **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, both modes;
  `ct8rows` **0 differing rows** against the committed baseline AND against
  this pass's own pristine sweep, status AND dump column.
* surelog **937 / 567 / 48 / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 / 2 / 1 / 1**;
  `ct8rows` **0 differing rows** over 1588 against the committed baseline AND
  against this pass's own pristine sweep. **NO ROW WAS CONVERTED**, so
  `results/*.csv` is untouched.
* `byteverify SELFCHECK=1`: **u2r MOVERS 0/1358**, **surelog MOVERS 2/956** —
  `./default/Earlgrey_0_1-71da2fd7` and `./testflags/Earlgrey_0_1-71da2fd7`,
  both PREDICTED BY NAME. SELFCHECK flags 1357/1358 and 955/956.
* `rowheads.sh`: `Earlgrey_0_1` **250 → 64** (default) and **278 → 64**
  (testflags), 1 head each, and the two modes' head logs are now
  **byte-identical to each other**. Every other named row's head log is
  **byte-identical before and after**.
* canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r); `ctcan2`
  PASS on both; `canaudit.sh canaries.sh ctcan2.sh` **audited=29 UNCOVERED=0
  FENCE-BREACH=0**.
* protected databases, md5 vs the pristine sweep: `InterfaceModPort`,
  `BlackParrotComplex`, `YosysOldOr` **SAME** in both modes; `SVSwitch`
  `4842211c4030`; `YosysVerx` `6ccda350c24a`.
* the wide boundary: see `BOUNDARY_WIDE.tally` / `.diff` / `.rc_histogram` /
  `.signals`.

**THE A/B GATE.** `R10E92_OFF=1` on the PATCHED binary reproduces the
PRISTINE database BYTE FOR BYTE on **both movers** and on **all six grid
arms**; the law ON gives the patched sweep's own hashes. 100 % of each mover's
byte delta is this law and nothing else.

---

## 6. The corpus census, before and after

`ct92cen` + `cenrun92.sh` + `score92.py`, over the same fixed universe (409
surelog + 990 u2r databases that hold a cont_assign or a conditionOp), with
the GOLDEN side asserted unchanged (both sweeps reference the SAME 3 022
golden cache entries).

```
surelog   CA  BOTH-SAME 81 873 -> 81 876     MOVED-WRONG   170 -> 167
              GOLDEN-ONLY  421 ->    421     OURS-ONLY  14 088 -> 14 088
          CO  BOTH-SAME 14 137 -> 14 137     MOVED-WRONG     2 ->   0
              GOLDEN-ONLY  772 ->    774     OURS-ONLY   3 178 -> 3 177
uhdm2rtlil    EVERY bucket of BOTH families UNCHANGED, every diff cell
              byte-identical before and after, 0 databases moved.
```

**WRONG→RIGHT 3, RIGHT→WRONG 0, AWAY-GOLDEN 0, STILL-WRONG 0.** Exactly
**four** (database, family) rows out of 2 798 changed bucket counts at all,
and all four are the two Earlgrey databases. **Zero diff cells were added
anywhere**; twelve lines were removed, all of them the head.

`CO GOLDEN-ONLY` rising by 2 is **not** an away-golden cell: golden's
surviving ternary is an ORPHAN (`LIVE=0` — Surelog re-points `Rhs` and leaves
the object in the serializer), we simply never mint it, and an unreachable
object is invisible to `uhdm-cmp`. The proof is that the same cell moved from
`MOVED-WRONG` to `BOTH-SAME` in the CA family and the head cleared.

---

## 7. Residues and R0

`PREDICT_R0.txt` carries the full prediction, the after-numbers and the ranked
residues. **R0** is a new head in `Earlgrey_0_1`, both modes, 1 head each,
64 cmp lines, and its mechanism is already decoded: a **64-bit shift overflow
in `ExprEval`'s size-cast arm** (`UHDM templates/ExprEval.cpp:4074`,
`mask = (1ULL << cast_to) - 1` with `cast_to == 64`) makes golden fold
`prim_lfsr.sv:39`'s `LfsrDw'(1)` to `UINT:0` where we give `UINT:1`.

---

## 8. Files

| file | what it is |
|---|---|
| `ct92cen.cpp` | the cont_assign-Rhs + vpiConditionOp census (the `LIVE` field is the instrument) |
| `score92.py` | the MULTISET join and the four buckets |
| `cenrun92.sh` | per-database census + score + delete, so the corpus run does not fill the disk |
| `cen92.sh` | the row-keeping variant, for a single workdir |
| `arm92.sh`, `cells92.py` | one grid arm, three ways, one line per cell |
| `g1_ctx92.sv` … `g6_shapes92.sv` | the grid |
| `ARMS.r10earl92.txt` | the grid's full output |
| `predict92.sh`, `dirmap92.sh` | the run-time cell trace and its FENCE |
| `PREDICT_TRACE.{surelog,uhdm2rtlil}.txt` | the trace, verbatim |
| `HEAD_{BEFORE,AFTER}_Earlgrey_{default,testflags}.cmp` | the head logs |
| `GATES.r10earl92.txt` | every gate's raw output |
| `BOUNDARY_WIDE.*` | the wide boundary |
| `bdlist92.sh`, `vwide92.sh`, `bdscore92.sh` | the boundary's list, runner and scorer |
| `rowheads.sh`, `ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the shared gate battery, carried so this directory can re-run itself |
