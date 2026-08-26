# r10uvm154 — § `enumWrittenNegDecLit154` — **THE `UVM_CVR_ALL` HEAD CLEARED**: an enum constant's written initializer is valued WITHOUT the enum's base type

uvm151's R0 named four next heads. This pass takes the **SimpleUVM ×2** one —
`enum_const: (UVM_CVR_ALL)` @279:7, `INT:-1` vs our `INT:4294967295` — and
clears it. **SimpleUVM ×2's head moves off the constant entirely** and lands on
`class_var: (uvm_pkg::clp)` @801:27, the object **SeqDriver ×2 already heads
on**, so two families now sit behind ONE next head.

**No conversion.** SimpleUVM stays `CMP_NOTEQUAL`; 0 differing rows on 1588
surelog + 1462 uhdm2rtlil row-sides. `results/*.csv` were not edited.

| row | pristine | patched |
|---|---|---|
| **SimpleUVM default / testflags** | **36 / 36** cmp lines, head = `enum_const (UVM_CVR_ALL)` | **60 / 60**, head = `class_var (uvm_pkg::clp)` — **NEW object** |
| SeqDriver default / testflags | 60 / 60 | 60 / 60 — head log **byte-identical** |
| Scoreboard default | 163 | 163 — head log **byte-identical** |
| MiniAmiq default / testflags | 106 / 106 | 106 / 106 — head log **byte-identical** |
| BuildUVMPkg default / testflags | 45 / 45 | 45 / 45 — head log **byte-identical** |
| Earlgrey_0_1 default / testflags | 112 / 112 | 112 / 112 — head log **byte-identical** |
| Rggen default | 0 | 0 |

(`Scoreboard/testflags` is `SLANG_REJECT` and `Rggen/testflags` has no golden —
both print SKIP-NOFILE and are COUNTED, never read as perfection. A cmp line
count going UP is fine when the head object CHANGED: the count is the new head
object's decompile size — RESUME.md §7. `head_pris_*.cmp` / `head_pat_*.cmp`
are the logs, measured on THIS worktree's own pristine and patched sweeps.)

---

## 0. THE LAW

> **§ `enumWrittenNegDecLit154` — an enum constant whose WRITTEN initializer is
> a UNARY MINUS over a BARE UNSIZED DECIMAL literal is valued from THAT
> EXPRESSION ALONE. The enum's BASE TYPE never participates: the constant is
> `INT:<-N>` at `vpiSize` 64 in BOTH views, whatever the base and whatever the
> home.** Its `vpiDecompile` is the WRITTEN negation `-<digits>` in the def view
> and the FOLDED decimal `<-N>` in the elaborated one. The two spellings differ
> for exactly two written faces: `-0` (folds to `0`) and LEADING ZEROS (`-007`
> folds to `-7`). **A `$unit`-scope enum takes the FOLDED spelling** even though
> it has only one listing — § `unitArith` already records that the compilation
> unit is elaborated LIKE A TOP PACKAGE — while a module / class /
> parameterized-class / interface home, also single-listing, takes the WRITTEN
> one. (VERIFIER FIX: the shipped first cut discriminated on `pkgTopEmit` alone
> and emitted `-0` / `-007` in a `$unit` home where golden emits `0` / `-7`;
> the ship condition is `pkgTopEmit || unitEnum9`. See
> `tools/probe/r10v154repro/`.)

**STATED GATE == CODE GATE.** The gate is: the initializer, after
`stripImplicitConv`, is a `UnaryExpression` with `UnaryOperator::Minus` whose
operand, after `stripImplicitConv`, is an `IntegerLiteral` whose source text
holds nothing but decimal digits (and `_` separators, and the parentheses slang
already folded away, and whitespace). Nothing else — no base test, no home
test, no view test, no value test. **Everything the gate does not recognise
keeps its previous answer, so every unmeasured spelling abstains by
construction**, and §6 records golden's answer for each abstention so the next
pass over this surface starts from a measurement rather than a guess.

Production surface: **`src/TypeEmit.cpp` only**, one inserted block in the
enum-constant loop of the enum typespec builder, ahead of every existing
value branch.

---

## 1. DECODING SURELOG — where the base type does and does not reach

`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp`, the enum arm of
`compileTypespec` (~808–870):

```cpp
uint64_t baseSize = 64;
if (const ref_typespec* rt = enum_t->Base_typespec())
  if (const typespec* ts = rt->Actual_typespec())
    baseSize = Bits(ts, invalidValue, scope, compileDesign, reduce, ...);
while (enum_name_declaration) {
  ...
  Value* value = nullptr;
  if (enumValueId) {
    any* exp = compileExpression(scope, fC, enumValueId, compileDesign, reduce, ...);
    if (exp && (exp->UhdmType() == uhdmconstant)) {
      constant* c = (constant*)exp;
      value = m_exprBuilder.fromVpiValue(c->VpiValue(), c->VpiSize());
      ... if (int-ish const type) val = eval.get_value(invalidValue, c);
    } else {
      value = m_exprBuilder.evalExpr(fC, enumValueId, scope);
      value->setValid();
    }
  }
  if (value == nullptr) { value = ...newLValue(); value->set(val, Value::Type::Integer, baseSize); }
  ...
  econst->VpiValue(value->uhdmValue());
  if (enumValueId) econst->VpiDecompile(eval.prettyPrint(compileExpression(...)));
  else             econst->VpiDecompile(value->decompiledValue());
  econst->VpiSize(value->getSize());
  val++;
}
```

**`baseSize` is the ONLY place the base typespec is read, and it reaches the
constant on the `value == nullptr` path ALONE** — that is, only for an
UNWRITTEN implicit successor. A **written** initializer is valued either from
the reduced `constant`'s own `VpiValue`/`VpiSize`, or from
`ExprBuilder::evalExpr` over the raw syntax; neither knows the enum exists.
That single fact is the whole law.

Two corroborating consequences, both measured:

* **the successor counter.** `val` is updated only on the reduced-`constant`
  branch. In the DEF view (`Reduce::No`) a unary minus does **not** reduce, so
  `val` stays 0 and the next implicit member reads **1**; in the elaborated
  view it does reduce, `val` becomes −1, and the next member reads **0**.
  Golden shows exactly that (`b_*__v_succ` arms: `E_B` = `INT:1` def,
  `INT:0` elab), and it is why `-1` can carry a *64-bit* size in a view where
  it never became a `constant` at all.
* **the decompile is `prettyPrint`, not source text.** Golden prints `-1` for
  `-(1)` and for `- 1` (parens and space dropped), `--2` for `-(-2)`,
  `-PW + 1` for `-(PW+1)`, and `1 - 2` for `1-2` (binary operators get
  spaces — buvm14's R5 spacing law, at this site).

**What we did instead.** `src/TypeEmit.cpp` folded `ev.getValue()` — the member
value **slang has already coerced to the enum base**. Under uvm-1.2's
`typedef bit [`UVM_REG_CVR_WIDTH-1:0] uvm_reg_cvr_t`, `UVM_CVR_ALL = -1`
therefore read back as the zero-extended 32-bit pattern **4294967295**. The
`bit`/`logic` typedef base is also the one shape that nulls `baseSyn` (the
typedef-base clone arm), which is why this member fell through to the 64-bit
digits branch and got the *right size* with the *wrong sign* — the exact head.

---

## 2. THE CENSUS — the population the law is scored on

`ct154cen.cpp` reads each `.uhdm` DIRECTLY (`Serializer::AllObjects`; never
`uhdm-dump`, unusable at Earlgrey/UVM size) and prints one row per
`enum_const`: owner typespec, name, span, `VpiValue`, `VpiDecompile`,
`VpiSize`, base kind. `cen154.sh` walks a whole sweep workdir — resolving
golden from the **golden cache** named in `cmds.txt` when the sweep took a
cache hit, without which the census would silently cover only the handful of
misses. `cen154.py` joins the two sides as a **multiset** keyed on
(owner, name, span), keeping BOTH views under one key so a per-view flip cannot
hide in a last-writer dict (RESUME.md §9), and comparing exactly the three
fields `enum_const::Compare` reads beyond `VpiName`. A cell with no `O` side at
all is a `SLANG_REJECT` row and is excluded — counting its consts as
ONLY-GOLDEN buried the real one-sided set under ~159k phantoms on the first cut.

**Surelog corpus, 956 comparable databases, 25 106 comparable enum_const cells:**

| | pristine | patched |
|---|---|---|
| SAME | 25 072 | **25 090** (+18) |
| **WRONG** | **34** | **16** (−18) |
| ONLY-GOLDEN | 6 953 | 6 953 (unchanged) |
| ONLY-OURS | 205 | 205 (unchanged) |

**uhdm2rtlil corpus, 1 358 comparable databases, 8 213 cells: WRONG 0 before
and after; the two census TSVs are byte-identical (0 diff lines).**

The pristine WRONG population is only **three disjoint shapes**, and this law
owns exactly one of them:

| n | owner | golden | ours | this pass |
|---|---|---|---|---|
| **18** | `uvm_pkg::uvm_coverage_model_e` `UVM_CVR_ALL` | `INT:-1` / `-1` / 64 | `INT:4294967295` | **CLEARED** |
| 4 | `WidthMultiple` | `INT:2` / `2` / 32 | `UINT:2` / `2` / 32 | residue R1 |
| 12 | `uvm_pkg::uvm_recursion_policy_enum` `1 << 16/17/18` | `UINT:65536` / `1 << 16` / **80** | `INT:65536` / `1<<16` / 64 | residue R2 |

---

## 3. THE MOVER SET, PREDICTED BY NAME BEFORE THE PATCHED SWEEP EXISTED

`movers154.py` run on the **pristine** census names every comparable cell
holding `UVM_CVR_ALL`: **9 cells DIFFER, 0 AGREE** —

```
default   BuildUVMPkg  MiniAmiq  Scoreboard  SeqDriver  SimpleUVM
testflags BuildUVMPkg  MiniAmiq             SeqDriver  SimpleUVM
```

(9 cells × 2 listings = the 18 census cells; 13 carry our def-view decompile
`-1`, 5 the elaborated `4294967295`.) Earlgrey_0_1 and Rggen hold no such
constant, so their heads were predicted to stay — and did.

`byteverify.sh SELFCHECK=1` on the patched sweep found **exactly those 9 and
nothing else**:

```
MOVERS: 9 / 956          SELFCHECK: 955 / 956 flagged     (surelog)
MOVERS: 0 / 1358         SELFCHECK: 1357 / 1358 flagged   (uhdm2rtlil)
```

`attrsweep154.sh` attributes every one of them **ORDER-BLIND** (both dumps
sorted — Scoreboard/default is a ~50/50 coin per invocation, RESUME.md §9;
paths normalised, weakly-referenced tail cut). Every mover is **4 or 6 lines
and nothing else**: two `|INT:4294967295` → `|INT:-1`, plus, where the
elaborated decompile also moved, `|vpiDecompile:4294967295` → `|vpiDecompile:-1`.
`non-payload=0` on all nine; `ATTRIBUTION PASS`.

---

## 4. THE GRIDS — 717 golden-scored cells, MOVED-WRONG 0, AWAY-GOLDEN 0

Four generated grids plus the five committed arms, each cell scored
pristine → patched **against Surelog**:

| grid | axis | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | still-wrong | still-right |
|---|---|---|---|---|---|---|
| 1 | 12 bases × 11 spellings (package) | **93** | 0 | 0 | 69 | 298 |
| 2 | arithmetic / concat / ref / shift inits | **0** | 0 | 0 | 76 | 4 |
| 3 | 7 bases × 11 unary-minus spellings | **43** | 0 | 0 | 80 | 17 |
| 4 | homes × instance counts × import clone | **15** | 0 | 0 | 2 | 20 |
| arms | the five committed `g154_*.sv` | **34** | 0 | 0 | 15 | 93 |

Grid 2 is the **abstention proof**: 80 cells of arithmetic, concat, reference
and shift initializers, **not one of which moved a single field**.

The bases proved uniform for the gated shape — `INT:<-N>` / `-N` / **64** in
BOTH views for every one of: **no base, `int`, `integer`, `bit [31:0]`,
`logic [31:0]`, `byte`, `shortint`, `longint`, `int unsigned`, a typedef'd
`bit [31:0]`, a typedef'd `int`, a typedef'd `logic [15:0]`**. The homes proved
uniform too — **package, `$unit`, module, class, interface, and an
import-listing clone** — as did **1, 2 and 3 instances**. `logic [7:0]` with a
negative member is a genuine slang width error (`SLANG_REJECT`, out of scope by
decision) and is listed, not hidden.

The `$unit` home deserves its own line: § `unitArith`'s compilation-unit fork
sent a `$unit` enum's arithmetic initializer down a different road that folded
the base-coerced digits into BOTH the value and the decompile. The new block
sits **ahead** of that fork, so all six homes now answer identically — which is
what golden does (`g154_c_home.sv`, `UNIT_ALL`).

Arm `g154_e_ctrl.sv` is the **over-fire detector**: uvm-1.2's
`uvm_tlm_response_status_e` (the corpus's *other* negative-init enum, five
members written `-1 .. -5` under no base, which our pristine binary already
valued correctly — census: 126 cells, all SAME), the based/sized/unbased-unsized
literal encodings other passes own, the implicit-successor chain, a computed
concat and a reference init. Its database is **byte-identical** out of both
binaries and its golden distance is frozen at 27 lines.

---

## 5. GATES

Both binaries built in THIS worktree at BASE 258e615, `-j 2`, md5'd separately.
The pristine build **reproduces the main tree's own pristine md5 exactly**, and
this worktree's pristine sweep CSVs came out **byte-identical to the committed
258e615 controls** (`/tmp/ctl_{sl,u2r,u2r_def}_258e615.csv`, since rotated away
by a sister landing — this worktree's own pristine CSVs are the baseline used
below, and they were verified equal to those controls while they existed).

| gate | result |
|---|---|
| build both, md5 separately | pristine `18aa89a5…`, patched `5307130b…` |
| `tests/check_goldens.sh` (SLANG_UHDM exported to the patched binary) | **PASS 23 / FAIL 0** |
| negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** |
| surelog corpus, both modes, `ct8rows.sh` vs this worktree's pristine AND vs `results/golden_surelog.csv` | **0 differing rows over 1588** (status AND dump column); histograms identical |
| uhdm2rtlil testflags + default vs pristine AND vs `results/gate_uhdm2rtlil.csv` | **0 differing rows**; **679 / 50 / 2** |
| every `cmds.txt` audited BY BINARY PATH | 2981 patched, 2981 pristine, no crossover |
| `byteverify.sh SELFCHECK=1` surelog | **9 / 956**, all nine PREDICTED BY NAME; selfcheck 955/956 |
| `byteverify.sh SELFCHECK=1` uhdm2rtlil | **0 / 1358**; selfcheck 1357/1358 |
| `attrsweep154.sh` on all nine movers | `non-payload=0`, **ATTRIBUTION PASS** |
| `canaries.sh` surelog / uhdm2rtlil | **ok=52 changed=0** / **ok=8 changed=0** |
| `ctcan2.sh` both | PASS / PASS |
| `canaudit.sh canaries.sh ctcan2.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** |
| `rowheads.sh` on both sweeps | SimpleUVM ×2 head object CHANGED; every other head log byte-identical |
| wide boundary `bound154.sh` over **all 4300 committed probe arms × 2 views** | `LISTED=4300 PROCESSED=4300 MOVED=26 TAILONLY=4 BREACH=0 RC-MISMATCH=0` — **BOUNDARY PASS** |
| `goldscore154.sh` over every one of the boundary's 11 moved arms | **better=11 equal=0 worse=0** — **GOLDSCORE PASS** |

No conversion is claimed. `results/*.csv` were not edited. The four
slang-fenced tests were never dispatched and are not spelled in any artifact
here (`canaudit.sh` asserts it).

---

## 6. RESIDUES — golden's answer for everything this law ABSTAINS on

Measured, not guessed; all with the head's own `typedef bit [31:0]` base, def
view then elaborated view. **Our pristine answer is unchanged for every row
below** — that is what grid 2 and arm `g154_b_spell.sv` prove.

| written init | golden def | golden elab | ours (both) |
|---|---|---|---|
| `-32'd3` (SIZED operand) | `INT:-3` / `-32'd3` / **32** | `INT:-3` / `-3` / **32** | `INT:4294967293` / … / 64 |
| `-'d1` (UNSIZED BASED operand) | `INT:-1` / `-'d1` / **unset** | `INT:-1` / `-1` / **-1** | `INT:4294967295` / … / 64 |
| `-PW` (REFERENCE operand) | `INT:-2` / `-PW` / **32** | `INT:-2` / `-2` / **32** | `INT:4294967294` / … / 64 |
| `-(PW+1)` (inner expression) | `INT:-3` / `-PW + 1` / 64 | `INT:-3` / `-3` / 64 | `INT:4294967293` / … / 64 |
| `-(-2)` , `-(-(3))` (double negation) | `INT:2` / `--2` / 64 | `INT:2` / `2` / 64 | value already right, decompile `-(-2)` |
| `-1-1` (minus then binary minus) | `INT:-2` / `-1 - 1` / 64 | `INT:-2` / `-2` / 64 | `INT:4294967294` / … |
| `1-2` (bare subtraction) | **`UINT:18446744073709551615`** / `1 - 2` / 64 | `INT:-1` / `-1` / 64 | `INT:4294967295` / `1-2` |
| `~0` | **`UINT:18446744073709551615`** / `~0` / 64 | `UINT:18446744073709551615` / `18446744073709551615` / 64 | `INT:4294967295` |
| `PM1` (a parameter = −1) | **`INT:0`** / `PM1` / **unset** | `INT:-1` / `-1` / **32** | `INT:4294967295` / … / 64 |
| `1+2`, `3+40`, `2*3` | `UINT:3` / `1 + 2` / 64 | `UINT:3` / `3` / 64 | `BIN:…` at base width |
| `PW+AW` (ref operands) | `UINT:6` / `PW + AW` / **32** | `UINT:6` / `6` / 32 | `BIN:…` at base width |
| `1<<3` | `UINT:8` / `1 << 3` / **67** | `UINT:8` / `8` / 64 | `BIN:…` at base width |
| `{2'b10,2'b01}` | `BIN:1001` / `{2'b10,2'b01}` / **4** | `BIN:1001` / *no decompile* / 4 | `BIN:…` at base width |

Three things are worth carrying forward from that table.

* **R1 — the WHOLE non-literal family is base-independent, not just the
  negation.** Golden's value comes from the initializer for `1+2` and
  `{2'b10,2'b01}` just as much as for `-1`; the size comes from the operands'
  own widths (`1 << 3` → **67**, a shift *widening* Surelog's evaluator;
  `PW + AW` → 32; a bare literal → 64), and the def-view value follows
  `ExprBuilder::evalExpr`'s idiosyncratic signedness (a subtraction of literals
  reads UNSIGNED, a negation reads SIGNED). Our `BIN:<bits>` at the enum's base
  width is right only where the base width happens to equal the operand width
  — which is why rp32's `PRIV_ECALL` and riscv_isa_pkg's `isa_spec_et`, the
  goldens those branches were fitted to, agree while these grids do not.
  **Corpus incidence of the whole family beyond this law: 16 cells** (§2).
* **R2 — `uvm_recursion_policy_enum` is the next enum_const head**, 12 cells:
  `UVM_DEEP/UVM_SHALLOW/UVM_REFERENCE = 1 << 16/17/18` under a `bit` typedef
  base. Golden's def view is `UINT:65536` / `1 << 16` / **80** — the shift
  width rule — and its elaborated view `UINT:65536` / `65536` / 64; ours is
  `INT:…` / `1<<16` / 64 in the def view and `INT:…` / `65536` / 64 elaborated.
  Three separate sub-facts (the `UINT:` prefix, the 64+shift size, the
  prettyPrint spacing) and a genuinely different Surelog road from this one.
* **R3 — `WidthMultiple`**, 4 cells: golden `INT:2`, ours `UINT:2`, same
  decompile and same size 32. An encoding-PREFIX cell in
  § `enumSubstIntConst30`'s family, not a value cell; it needs the rule that
  decides `INT:` vs `UINT:` for a folded member, which §2's `unsignedIntBase`
  test gets wrong for this shape.

**R4 — the elaborated decompile for `-0` and for LEADING ZEROS. MEASURED BY
THE VERIFIER; the first cut was WRONG here and is FIXED in the shipped code.**
The gated shape's def and elab decompiles differ for exactly two written faces:
`-0` (golden prints `-0` then `0`) and leading zeros (`-007` then `-7`). Every
other spelling has raw == folded and cannot see the discriminator at all.

The first cut discriminated on `pkgTopEmit`, the *package* view flag, and so
gave a `$unit` home the DEF spelling. r10v154's grid measured all six homes ×
{`-0`, `-007`} × four bases against Surelog: **`$unit` takes the FOLDED
spelling (`0`, `-7`); module, class, parameterized class and interface — also
single-listing — take the WRITTEN one (`-0`, `-007`); the package shows both,
def then elaborated.** That is § `unitArith`'s own rule (the compilation unit is
compiled before any module and elaborated LIKE A TOP PACKAGE, so its single
listing IS the top one), and `unitEnum9` was already computed above the loop for
it. The ship condition is `pkgTopEmit || unitEnum9`; **7 pristine-right ->
patched-wrong cells were closed by it** (`tools/probe/r10v154repro/README.md`).

**R5 — the digit separator `-1_0`.** Golden's DEF value is `INT:-1` while its
decompile is `-10` and its elaborated value is `INT:-10`: `ExprBuilder::evalExpr`
stops at the `_` in the def view. The law does not model that; it gives
`INT:-10` / `-10` in both views, which fixes the decompile and the elaborated
value and leaves the def value wrong — no field regresses. **Corpus incidence
0**; measured over 25 cells of the verifier's grid.

---

## 7. THE WIDE BOUNDARY, AND THE ONE THING IT CAUGHT THAT ISN'T THIS LAW

`bound154.sh` compiles **every `.sv`/`.svh` under `tools/probe` — all 4294
committed arms, subdirectories included — in BOTH views with BOTH binaries, to
the SAME output path**, and compares by md5 first. It reads the file list on
fd 3, gives every child `</dev/null`, keys scratch on the arm's RELATIVE path
(several trees keep three files all called `dut.sv`), asserts
`PROCESSED == LISTED`, records every rc and treats a pris/pat rc mismatch as a
breach, and asserts that the run did not silently compile nothing.

Only a database that MOVED is censused and dumped, and it must be attributable
on two independent counts (`attr154.py`): the `enum_const` **key multiset is
unchanged** (the law rewrites three fields and mints nothing) and every
differing payload is the law's own answer; and every added/removed line of the
judge-visible whole-dump diff is an `enum_const` payload line.

**`|vpiConstType:` is in that allow-list, and that is a result, not a
loophole.** § `enumSubstIntConst30` says a `constant` minted by COPYING an
enum_const's `VpiValue` takes its `vpiConstType` from that value's ENCODING
PREFIX. So a member going `BIN:1111…` → `INT:-1` drags its folded reference
from `vpiBinaryConst` (3) to `vpiIntConst` (7) — and **golden agrees**:
r10earl30's own verifier arm `v7_empty.sv` carries
`vpiSize 64 / INT:-1 / vpiConstType 7` on that constant, and the patched binary
now matches it. `goldscore154.sh` re-measures the arm end to end: **139 → 124
lines from golden**.

**Eleven arms moved in total, and every single one moves TOWARD golden:**

```
TOWARD-GOLDEN r10earl30repro/v7_empty.sv          139 -> 124
TOWARD-GOLDEN r10earl66repro/g2_enc66.sv          254 -> 245
TOWARD-GOLDEN r10uvm138repro/g138_b_kinds.sv      180 -> 162
TOWARD-GOLDEN r10v138repro/v4_kinds.sv            151 -> 133
TOWARD-GOLDEN r10v66repro/v5_odd66.sv             157 -> 148
TOWARD-GOLDEN r10vbuvm30repro/vg30_e_targets.sv    78 ->  69
TOWARD-GOLDEN r10vbuvm30repro/vg30_h_macro.sv     159 -> 150
TOWARD-GOLDEN r10uvm154repro/g154_a_base.sv       101 ->   4
TOWARD-GOLDEN r10uvm154repro/g154_b_spell.sv       71 ->  41
TOWARD-GOLDEN r10uvm154repro/g154_c_home.sv        18 ->   6
TOWARD-GOLDEN r10uvm154repro/g154_d_inst.sv        20 ->  10
GOLDSCORE better=11 equal=0 worse=0 skipped=0
```

The seven earlier-pass arms are all enum-constant arms of the enum-constant
precedents — § `enumSubstIntConst30`, § `elabConnEnumConstFold66`,
§ `pkgRetBareEnumConstFold138` and their verifiers — carrying a negative member
whose value this law corrects. Arm `g154_e_ctrl.sv` did **not** move at all and
its golden distance is frozen at 27.

**TAILONLY — the pre-existing layout artifact.** A handful of arms have
databases whose BYTES move while every judge-visible object is identical: the
whole-dump diff with the weakly-referenced tail cut off is **empty**. The cause
is not this law. A class-scoped `typedef <T> name[string]` leaks a
**binary-layout-derived number** into a tail constant (`UINT:22535897` from one
binary, `UINT:22539993` from the other — exactly 4096 apart), so ANY code
motion anywhere in the emitter moves it. `layoutproof154.sh` proves the
mechanism on `l154_noenum.sv`, a source that **contains no enum at all**, where
this pass's code cannot execute: the two binaries still disagree on that tail
value while the judge-visible head is identical. RESUME.md §9 — "the
weaklyReferenced tail is unreachable to the judge; never count tail stamps".
It is invisible to both corpora: byteverify reports 0 unpredicted movers over
956 + 1358 databases. A real regression cannot hide there — it would have to
change a judge-visible object, which is exactly what the gate's `dn > 0` test
catches.

**VERIFIER CORRECTION: that tail constant is NOT judge-invisible.** Run the
official `uhdm-cmp` on the two `l154_noenum.sv` databases and it reports a head
(`constant` under an `operation` at 11:28) — `uhdm-dump` prints the object below
`\_weaklyReferenced:` but the judge still walks it. What is true, and is what
matters here, is that **all three binaries are EQUIDISTANT from golden on that
source (17 cmp lines each)**: golden emits a `string_typespec` for the
`[string]` index where we emit an `operation` over a garbage-valued `constant`,
so the associative-array-typedef bug is pre-existing, is not this law's, and
scores the same before and after. The value is run-STABLE per binary (three
runs, identical) and differs across binaries (a third, unrelated build gives
`UINT:0`), which is what makes it layout-derived rather than nondeterministic.

**One serialization lesson is baked into the production code.** The first cut
set `VpiValue`, `VpiSize`, `VpiDecompile` in that order — a different order
from the digits branch below it — and the serializer, which interns each string
on first use, swapped two symbol-pool indices. That made the database bytes
differ for constants whose CONTENT did not move at all (`uvm_tlm_response_status_e`,
which this law re-derives to exactly the answer it already had). `uhdm-cmp` and
`uhdm-dump` both read through the pool and cannot see it; `byteverify.sh` and
this boundary can, and an unattributable byte mover is indistinguishable from a
real one. The shipped code sets **decompile, then size, then value**, and arm
`g154_e_ctrl.sv` is byte-identical out of both binaries because of it.

---

## 8. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `g154_a_base.sv` | arm A — 11 enum bases, one negative member each |
| `g154_b_spell.sv` | arm B — 5 FIRING spellings + 5 ABSTAINING ones in one package |
| `g154_c_home.sv` | arm C — `$unit`, module, interface and class homes |
| `g154_d_inst.sv` | arm D — 1/2/3 instances + an import-listing clone |
| `g154_e_ctrl.sv` | arm E — the MUST-STAY controls (`uvm_tlm_response_status_e` &c.) |
| `l154_noenum.sv` | the LAYOUT PROOF source — no enum at all (not an arm) |
| `arm154.sh` | one-arm driver: golden + ours, cmp + path-normalised dump diff |
| `ct154cen.cpp` | the `enum_const` census reader (direct `.uhdm`) |
| `cen154.sh` / `cen154.py` | corpus-wide census driver and multiset join |
| `movers154.py` | names the mover cells BY (mode,test) from a pristine census |
| `attrsweep154.sh` | order-blind line-by-line attribution of the corpus movers |
| `bound154.sh` / `attr154.py` | the wide boundary and its two-count attribution |
| `goldscore154.sh` | re-scores every boundary mover AGAINST GOLDEN |
| `layoutproof154.sh` | proves the TAILONLY moves are layout, not this law |
| `gengrid154.py` / `gridrun154.sh` / `score154.py` / `cells154.py` | the grid generator, one-cell runner and golden scorer of §4 |
| `head_pris_*.cmp` / `head_pat_*.cmp` | the seven rows' head logs, before and after |
| `GATES.txt` `CENSUS.txt` `MOVERS.txt` `BOUNDARY.txt` `ARMS.txt` | every gate, census, mover and boundary reading above, verbatim |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` `ct8rows.sh` `byteverify.sh` | the gate scripts, carried so this directory runs standalone |

---

## 9. R0 — THE NEXT HEAD

**SimpleUVM ×2 now heads on the SAME object SeqDriver ×2 does**, so four
row-modes share one next head:

```
SeqDriver ×2 and SimpleUVM ×2, 60 cmp lines, ONE ^LHS: — uvm_pkg.sv:801:27
LHS (golden)  class_var: (uvm_pkg::clp) @801:27-801:66, parent \_package: uvm_pkg
              vpiTypespec -> class_typespec (uvm_cmdline_processor)
              vpiExpr     -> ref_obj (uvm_cmdline_processor::get_inst)
```

a PACKAGE-scope `class_var` named `clp`, initialised from a static method call,
that golden places in the package and we do not — the
`CompilePackage::collectObjects_` out-of-body-walk family
§ `tfItemLocalLosesToPkgVar148` decoded, one object further out. See
`head_pat_SimpleUVM.default.cmp` and `head_pat_SeqDriver.default.cmp`.

The other queued heads, unchanged by this pass: **MiniAmiq ×2** 106 lines
(`unsupported_typespec: (uvm_severity)` @168:15 with `vpiInstance uvm_pkg`),
**Scoreboard/default** 163 lines (the `begin` of
`uvm_pkg::uvm_reg_predictor::get_type_name` @118:26 under an `if_stmt`),
**BuildUVMPkg ×2** 45 lines, **Earlgrey_0_1 ×2** 112 lines. Inside this
family, §6's **R2 (`uvm_recursion_policy_enum`, 12 cells)** and **R3
(`WidthMultiple`, 4 cells)** are the only `enum_const` payload cells left wrong
in either corpus.
