# r10uvm73 — ADVERSARIAL VERIFIER REPORT

## VERDICT

**PARTIAL on the SHIPPED patch (`/tmp/r10uvm73.patch`, md5
`58bb9e3f5d6a005b72cbb36742d61058`). PASS on the re-cut
`/tmp/r10uvm73.verified.patch`.**

The head is genuinely cleared, the law's SCOPE clause is correct and
generalises past every cell the implementer tested, and **every one of the five
gates, the census, the movers, the canaries and BOTH binary md5s reproduce
exactly** on binaries I configured and built myself. I could not break the
scope predicate.

But the law's INITIALIZER clause — *"a degraded property's initializer is
class_defn-parented **and sized 64**"* — is **REFUTED in its second half**, and
that half is a real **OVER-FIRE**: it takes a field that the PRISTINE binary
emitted **correctly** and makes it **wrong**. It has no corpus witness, so it
breaks no gate; it would have landed as a latent defect. It is FIXED and
re-verified below, and the re-cut patch is the deliverable.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours, everywhere in this file.

---

## 0. WHAT I BUILT, AND THE ANCHORS

Applied to a **FRESH `7d7c29f`** (`git worktree add --detach`), not to the
implementer's tree. The patch also **applies cleanly to the current head
`dcf67d7`** (`git apply --check`), so the two live passes have landed without
colliding — see §5.

| worktree | base | content | md5 of `build/slang-uhdm` |
|---|---|---|---|
| `/tmp/wt_v73pris` | `7d7c29f` | pristine | **`ece9e9899d1089f7ebd56a8e55920d3f`** |
| `/tmp/wt_v73` | `7d7c29f` | + shipped patch | **`3b03bf98a78287b3cd7d5c1772a3e70e`** |
| `/tmp/wt_v73ref` | `7d7c29f` | + patch + my refinement | **`91f06c02e52c02a3e8eb9effeec7f332`** |

Both claimed md5s reproduced **bit for bit** on an independent configure+build
(`-j 2`, `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` read
before any md5, md5s asserted in a separate command, all 32-hex). Every base
was printed AND grep-checked against `^7d7c29f8e338398562a1874552f3504b4820db1c$`.

**One correction to the implementer's "third anchor".** Their README says the
main tree's `build/slang-uhdm` at `HEAD == 7d7c29f` md5s to `ece9e989…`. The
main tree is now at **`dcf67d7`** and its binary md5s to `d8055b9293cceed…`, so
that anchor is no longer checkable as written. It does not matter: my own
pristine build of `7d7c29f` reproduces `ece9e989…` exactly, which anchors the
control independently.

`git stash` never used. `results/*.csv` only ever READ (`git show
7d7c29f:results/…`). slang not patched. `GOLDEN_DEFER` echoed `[UNSET]` at every
sweep launch. Every sweep printed its binary's md5 and the `cmds.txt` proof of
the binary actually invoked.

---

## 1. FINDINGS

### F1 — OVER-FIRE (**the finding**): `VpiSize(64)` is unconditional; golden sizes the constant from the **LITERAL**, not from a constant 64

**SEVERITY: real defect in the landed law. Regresses a field the pristine
binary got RIGHT. Zero corpus witnesses, so no gate breaks.**

The patch writes, in both gated integer arms:

```cpp
c0->VpiSize(foreignTd73 ? 64 : (int32_t)cp.getType().getBitWidth());
```

The shipped grid initialises degraded properties with `= null`, `= 7`, `= 3`
and `= -1` **only** — every one an UNSIZED literal. On that population 64 is
right, and the clause looked like a law. It is not. Arms **v3_size.sv** and
**v4_neg.sv** make "property width" and "literal width" DISAGREE:

| cell | written | golden | **PRISTINE** | **SHIPPED patch** | **re-cut** |
|---|---|---|---|---|---|
| `c_uns`    | `holder::i_t = 7`      | 64 | 32 ✗ | **64 ✓** | 64 ✓ |
| `c_uns96`  | `holder::w_t = 7`      | 64 | 96 ✗ | **64 ✓** | 64 ✓ |
| `c_uns4`   | `holder::n_t = 7`      | 64 |  4 ✗ | **64 ✓** | 64 ✓ |
| `c_mix_w4` | `holder::w_t = 4'd7`   | **4** | 96 ✗ | **64 ✗** | **4 ✓** |
| `c_mix_4w` | `holder::n_t = 4'd7`   | **4** | **4 ✓** | **64 ✗ REGRESSED** | **4 ✓** |
| `c_sz32`   | `holder::i_t = 32'd7`  | **32** | **32 ✓** | **64 ✗ REGRESSED** | **32 ✓** |
| `c_sz8`    | `holder::i_t = 8'd7`   | **8** |  32 ✗ | **64 ✗** | **8 ✓** |
| `c_n_sz8`  | `holder::i_t = -8'd1`  | **8** |  32 ✗ | **64 ✗** | **8 ✓** |
| `c_n_sz4`  | `holder::w_t = -4'd1`  | **4** |  96 ✗ | **64 ✗** | **4 ✓** |

`c_mix_4w` and `c_sz32` are the two that matter: **pristine emitted the correct
size and the patch makes it wrong.**

**THE ACTUAL RULE**, read off golden and stated so it can be refuted: *the
constant carries the width the LITERAL WAS WRITTEN WITH; an **UNSIZED** literal
falls back to the property's typespec width, or to Surelog's typespec-less
default **64** when there is no typespec.* That single sentence predicts all 9
degraded cells above **and** the implementer's own a4 readings (`c_intinit` 64
vs control `k_intinit` 32) — which their "sized 64" wording could not.

```bash
cd tools/probe/r10uvm73repro
SLANG_UHDM=<bin> ./ct73arm.sh v3_size.sv /tmp/x_v3
python3 v73initcells.py /tmp/x_v3/g.dump /tmp/x_v3/o.dump \
  c_uns c_uns96 c_uns4 c_mix_w4 c_mix_4w c_sz32 c_sz8 k_uns k_uns96 k_uns4 k_mix_w4 k_mix_4w k_sz32 k_sz8
# shipped: agree=8 DISAGREE=6      re-cut: agree=12 DISAGREE=2 (the 2 are F2)
```

**THE FIX, and why it is minimal.** Only the `foreignTd73` branch is touched;
the non-degraded branch is left byte-identical, so **no corpus row can move by
construction** — and §4 proves it did not:

```cpp
c0->VpiSize(foreignTd73
                ? (ic0.as<IntegerLiteral>().isDeclaredUnsized
                       ? 64 : (int32_t)ic0.type->getBitWidth())
                : (int32_t)cp.getType().getBitWidth());
```

and the same one level down on `ub0` in the negated arm. `isDeclaredUnsized` is
already used in this codebase (`src/ParamEmit.cpp:13845`); `ub0` is already
stripped of the implicit conversion, so its type IS the literal's own.

### F2 — the SAME defect in the NON-degraded branch is **PRE-EXISTING** and deliberately NOT fixed

`k_sz8` (`i_t = 8'd7`, own typedef): golden **8**, ours **32** — identically on
the **pristine** binary. `k_mix_w4`, `k_n_sz8`, `k_n_sz4` likewise. This is not
this pass's; widening the fix there would move rows this pass has not measured,
so I left it and ranked it (R2 below). **Stated so the next pass does not read
my `agree=12 DISAGREE=2` as a failure: those 2 are F2.**

### F3 — UNDER-FIRE: four of the seven initializer arms are ungated

`emitClassDefn`'s initializer decode has seven arms; the patch gates three
(IntegerLiteral, the negated-integer operand, NullLiteral). Golden re-parents
the initializer of a degraded property to the `class_defn` in **all** of them:

| cell | written | golden expr parent | ours (shipped **and** re-cut) |
|---|---|---|---|
| `c_strinit`   | `holder::s_t = "hi"` | `class_defn` | `logic_var` ✗ |
| `c_realinit`  | `holder::r_t = 1.5`  | `class_defn` | `logic_var` ✗ |
| `c_timeinit`  | `holder::t_t = 5ns`  | `class_defn` | `logic_var` ✗ |
| `c_namedinit` | `holder::i_t = P_SEVEN` | `class_defn` | `logic_var` ✗ |
| `c_negreal`   | `holder::r_t = -1.5` | `class_defn` | `logic_var` ✗ |

Controls `k_strinit … k_negreal` are var-parented in golden and =golden on both
binaries, so the axis is the degradation, not the arm. NOT a regression
(pristine has the same defect with a different var kind) and **zero corpus
witnesses**, so it is a residue, not a blocker — but it is the pass's own law
left applied to 3 of 7 arms. Ranked R1.

### F4 — one shipped a5 table row is NOT backed by its own instrument, and one a5 source cell is in NO table

`ct73cells.sh` exists to make "a driver that matches nothing must never read as
agreement" mechanical. Run on a5 it reports **`UNKNOWN-CELL=1`** — on the
pristine, patched and re-cut binaries alike. The README's a5 table nevertheless
prints:

> `l_fnlocal` | `p1::holder::e_t` function local | `class_var` | =golden | =golden

The cell is `l_fnlocal`, and the instrument sees **nothing** for it: golden
names it `work@top.f.l_fnlocal` — a `.`-separated module-scope name the
driver's `::`-anchored regex cannot match. **The claim happens to be TRUE** (I
measured it directly: `class_var|ref_obj|ref_typespec` on both sides), but as
shipped it is an unsupported row of the exact kind `canaudit.sh` was written to
prevent. Reported, and corrected here by direct measurement.

Worse in the same arm: **`m_modvar`** (`p1::holder::e_t m_modvar;` — a MODULE
variable with a class-qualified type) is **in the a5 source and in no table row
at all**. Measured:

```
m_modvar   golden = logic_net|logic_var|ref_typespec
           ours   = enum_var |logic_net|ref_typespec      DIFFERS
```

so it degrades in golden too. **This widens residue R1 of the implementer's
README**, which claims the population is "PACKAGE (or `$unit`) VARIABLES": it is
**module-scope variables as well**. Ranked R3.

### F5 — `Scoreboard/default` is BYTE-NONDETERMINISTIC, and the standing MOVER RULE is what caught it

Byte-comparing the re-cut binary against the shipped one reported **1 mover**,
`./default/Scoreboard`. Per-shape by multiset it is **`REMOVED=0 ADDED=0`, size
delta **0** — the noise floor. The decisive control: **the same patched binary,
run twice, produces two different byte streams for that database** (same size
`11123248`, md5 `5d1678fd99c0…` vs `52eca89ea740…`).

```bash
for r in r1 r2; do SLANG_UHDM=/tmp/wt_v73/build/slang-uhdm python3 scripts/verify_golden.py \
  --corpus surelog --mode default --filter Scoreboard --out /tmp/sb_$r.csv --workdir /tmp/sb_wd_$r --jobs 2; done
cmp /tmp/sb_wd_r1/default/Scoreboard-*/slang.uhdm /tmp/sb_wd_r2/default/Scoreboard-*/slang.uhdm   # DIFFER
```

This is the documented emitter nondeterminism (SourceLocation compares across
macro buffers under parallel parse). It does **not** touch the implementer's
result: in the patched-vs-pristine run `Scoreboard/default` moved with
`REMOVED=24 ADDED=3` and delta `-172`, a real content change. The standing rule
— *size-delta nonzero proves real, ZERO PROVES NOTHING* — separated the two
correctly, and it is the reason a byte mover here is not evidence.

---

## 2. WHAT I COULD NOT BREAK — THE SCOPE PREDICATE, HUNTED FOR EMPTY PRODUCT CELLS

The predicate's clause (3a) is an **identity comparison on slang Symbol
addresses** (`&home->asSymbol() != &ownerCls`). Its sharpest failure mode is a
GENERIC CLASS, where every specialization is its own `ClassType` symbol and a
typedef belongs to the specialization that elaborated it — a cell the shipped
grid never populated (it measured `pholder#(int)::g_e_t`, the QUALIFIED form,
and never the bare control). **`v1_spec.sv`, 14 cells, both binaries:**

| cell | written | golden | pristine | **final** |
|---|---|---|---|---|
| `v_pgen_own` | generic class's OWN typedef, **BARE**, in itself | `logic_var` + ts | =golden | **=golden** |
| `v_pgen_ownenum` | ditto, ENUM (the decisive control) | `enum_var` + ts | =golden | **=golden** |
| `v_pgen_selfqual` | `pgen#(W)::pw_t` in `pgen` | `logic_var` / NONE | ✗ `unsupported_typespec` | **=golden** |
| `v_pkid_inh` | base's typedef, bare, base is `pgen#(8)` | `logic_var` / NONE | ✗ | **=golden** |
| `v_pkid_qual` | `pgen#(8)::pe_t` from the derived | `logic_var` / NONE | ✗ | **=golden** |
| `v_outer_own` | outer class's own typedef in outer | `enum_var` + ts | =golden | **=golden** |
| `v_inner_bare` | **NESTED class**, OUTER's typedef, bare | `logic_var` / NONE | ✗ `enum_var` | **=golden** |
| `v_inner_qual` | nested class, `outer::o_e_t` | `logic_var` / NONE | ✗ | **=golden** |
| `v_inner_own` | nested class's OWN typedef | `enum_var` + ts | =golden | **=golden** |
| `v_selfpkg_bare` | own typedef, bare | `enum_var` + ts | =golden | **=golden** |
| `v_selfpkg_qual` | own typedef, `C::t` | `logic_var` / NONE | ✗ | **=golden** |
| `v_selfpkg_pkgqual` | own typedef, **`p1::C::t`** (two `::`) | `logic_var` / NONE | ✗ | **=golden** |
| `v_qual_union` | class-qualified **UNPACKED UNION** typedef | `logic_var` / NONE | ✗ `union_var` | **=golden** |
| `v_qual_pstruct` | class-qualified packed struct | `logic_var` / NONE | ✗ `bit_var` | **=golden** |

**`agree=5 → agree=14, DISAGREE=0, UNKNOWN-CELL=0.`** No false positive on
either generic-class control; nine products the shipped grid left empty are now
=golden. **The scope half of the law survives adversarial extension.**

### The one interaction the patch creates, measured not assumed

`foreignTd73` sets `v` **before** `if (!v && ct.kind == VirtualInterfaceType)`,
so a class-qualified virtual-interface typedef now leaves `vifProp6` **false**
where it used to be true. `grep -n vifProp6 src/UhdmExporter.cpp` shows it is
read in exactly two places and **both are `vifProp6 || foreignTd73`**, so the
pre-emption is inert by inspection — and by measurement: **`v5_vif.sv`, 6 cells
(class-qualified vif typedef ± modport ± `= null`, against own-typedef and
plain-`virtual` controls), `agree=6 DISAGREE=0` on the pristine, patched AND
re-cut binaries.**

### Refutations — I re-ran the implementer's, and they hold

`c_self_qual_enum` degrades with nothing to resolve, `c_locloc` does not degrade
though its RHS is the cross-class name, `holder::s_t|i_t|v_t` degrade like the
enum, and `seq_req_t` is declared 1722 lines ABOVE its use. **Resolvability,
enum-ness and compile-order are all correctly refuted.** I add: uvm-1.2 writes
`X::y` in ~30 places and **all but three are FUNCTION/TASK LOCALS**, which the
grid measures as non-degrading (a1 `l_qual_enum` 5/5 AGREE) — so the census's
"exactly 3 cells" is independently corroborated from the SOURCE side.

---

## 3. THE FIVE GATES, RUN INDEPENDENTLY

Every number below is from **my** sweeps on **my** binaries.
`P` = shipped patch, `R` = re-cut, `∅` = pristine.

| gate | claimed | **P (mine)** | **R (mine)** | ∅ control |
|---|---|---|---|---|
| **1 BUILD** md5 | `3b03bf98…` | **`3b03bf98…`** ✓ | `91f06c02…` | **`ece9e989…`** ✓ |
| **2 GOLDENS** | 23/0; `/bin/false` 0/23 | **23/0** | **23/0** | `/bin/false` **0/23** |
| **3 u2r testflags** | 679/50/2, dump 496/183/52, 0 rows | **679/50/2, 496/183/52, 0 ROWS** | **0 ROWS** | **0 ROWS** |
| **4 surelog default** | 469/11/5/284/25 | **469/11/5/284/25** | idem | idem |
| **4 surelog testflags** | 465/8/5/286/23 (+3/2/1/1) | **465/8/5/286/23 +3 NO_DATABASE +2 UNTRANSLATABLE +1 TIMEOUT +1 NO_UHDM** | idem | idem |
| **4 dump column** | 225/244, 165/300 | **225 match/244 differ (default), 165/300 (testflags)** | idem | **identical to P** |
| **4 whole-row** | 0 differing ROWS on 1588 | **0 differing ROWS** | **0** | **0** |
| **5 byteverify surelog** | 953/953, 7 movers | **953/953, PATH_SETS_IDENTICAL, 7 movers** | R vs P: 1, `REMOVED=0 ADDED=0` (F5) | — |
| **5 byteverify u2r** | 679/679, 0 movers | **679/679, 0 movers** | **R vs P: 0 movers** | — |
| **5 SELFCHECK / SELFCHECK1** | 952/953 & 8; 678/679 & 1 | **952/953, 8; 678/679, 1** | 952/953, 2; 678/679, 1 | — |

Row judges run against `git show 7d7c29f:results/{golden_surelog,gate_uhdm2rtlil}.csv`
— **not** the working tree's, which has moved with the two landed live passes.

**MOVERS, per-shape by MULTISET — every figure reproduced exactly:**

```
./default/BuildUVMPkg    REMOVED=24 ADDED=3  11097846 -> 11097669  (-177)
./default/Scoreboard     REMOVED=24 ADDED=3  11123420 -> 11123248  (-172)
./default/SeqDriver      REMOVED=24 ADDED=3  17962880 -> 17962716  (-164)
./default/SimpleUVM      REMOVED=24 ADDED=3  11119038 -> 11118874  (-164)
./testflags/BuildUVMPkg  REMOVED=24 ADDED=3  11097846 -> 11097669  (-177)
./testflags/SeqDriver    REMOVED=24 ADDED=3  17963307 -> 17963133  (-174)
./testflags/SimpleUVM    REMOVED=24 ADDED=3  11119350 -> 11119186  (-164)
```

Size delta **nonzero on all seven**. Removed set = 3×(`|vpiTypespec:` +
`|vpiParent:` + `|vpiActual:` + `\_ref_typespec:`), 2× each `enum_var` at
1771:34 / 580:35 / 584:35, the 3 fullnames, the 3 `enum_typespec` referrers;
added set = exactly 3 `logic_var`. **Three objects per database and nothing
else.** No `CMP_EQUAL` database moved a byte in either corpus.

**HEAD, measured by me on both sweeps:**

| row | ∅ | P | R |
|---|---|---|---|
| `SimpleUVM` default / testflags | 50 / 50 | **42 / 42** | 42 / 42 |
| `Scoreboard` default | 50 | **42** | 42 |
| `SeqDriver` default / testflags | 1416183 | **1416141** | 1416141 |
| `BuildUVMPkg` default / testflags | 1368017 | **1367975** | 1367975 |

`Scoreboard/testflags` is SLANG_REJECT with no golden — `SKIP-NOFILE`,
counted, not silently green. The three new heads are byte-identical with ids
normalised (single md5 across all three) and are the claimed R4:
`bit_select (arb_sequence_q[i])` @554:32-46 with `vpiIndex` → `ref_obj` →
`int_var`, against our one `ref_obj` spanning to 554:49.

**CENSUS, run FIRST, span-keyed, BOTH sides, by me:**

```
pristine: LHS 6642 / RHS 6221, shared 6172, LHS-only 470, RHS-only 49 -> 36 disagreements
final   : LHS 6642 / RHS 6221, shared 6172, LHS-only 470, RHS-only 49 -> 33 disagreements
```

The `logic_var ts=0 / enum_var ts=0|1` row — **exactly 3 cells** — is GONE; all
eleven other shapes are cell-for-cell unchanged; **no new shape appeared** and
no object was created or destroyed.

**CANARIES** (patched AND re-cut, both corpora):

| guard | result |
|---|---|
| `canaries.sh` surelog | **ok=52 changed=0 absent=0**, unknown-names=7 |
| `canaries.sh` u2r | **ok=8 changed=0 absent=0**, unknown-names=25 |
| `ctcan2.sh` surelog, baseline FIRST, `EXPECT_UNKNOWN=1` | **ok=58 changed=0 absent=0**, unknown-patterns=1 — PASS |
| `ctcan2.sh` u2r, baseline FIRST, `EXPECT_UNKNOWN=6` | **ok=1 changed=0 absent=0**, unknown-patterns=6 — PASS |
| `canaudit.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| `InterfaceModPort`, `BlackParrotComplex` BY NAME | both modes `CMP_EQUAL/differ`, **byte-identical to pristine**, and R==P |

**Fence note.** The four fenced names are dispatched by **no driver** in this
directory (`canaudit.sh` proves it). They do appear in the full-corpus sweep
workdirs, which is what a 1588-row gate means; their rows are inside the
**0 differing ROWS** result.

---

## 4. WHY THE RE-CUT INHERITS ALL FIVE GATES

The refinement touches only the `foreignTd73` branch of two size expressions.
The degraded population in both corpora is **exactly the 3 uvm properties, none
of which has an initializer at all**, so the re-cut binary must be
content-identical on the corpora. Proven, not asserted:

* `byteverify.sh` **re-cut vs shipped, u2r: 0 movers / 679**.
* `byteverify.sh` **re-cut vs shipped, surelog: 1 byte mover / 953**, and it is
  `REMOVED=0 ADDED=0 delta 0` — the noise floor, shown in F5 to reproduce with
  the SAME binary twice.
* Independently anyway: re-cut goldens **23/0**; re-cut whole-row judge **0
  differing ROWS** on 1588 and on 731; re-cut heads **42/42/42**; re-cut
  canaries identical to the above.

---

## 5. PATCH HYGIENE AND BOUNDARIES — ALL CHECKED MECHANICALLY

* **STATED GATE == CODE GATE.** `classScopedTypedefProp73` = **1** in
  `src/EmitHelpers.h` (definition) and **1** in `src/UhdmExporter.cpp` (the
  single call); `foreignTd73` = **9** in `UhdmExporter.cpp` (1 decl + 8 reads:
  array-arm veto, kind decode, int-init size, int-init parent, neg-init size,
  neg-init parent, null-init first-arg, `ref_typespec` skip). **Two production
  files, no others.** The re-cut changes the two size expressions and adds no
  new symbol, so the counts are unchanged.
* **`§ implicitRetSigningIsIntVar70`** — `src/TaskFuncEmit.cpp` is **untouched**
  (`git diff --stat` empty). Its negative control, a FUNCTION LOCAL and a
  FORMAL ARGUMENT of the identical class-qualified type, reads **5/5 AGREE**
  (a1 `l_*`/`a_*`) on all three binaries.
* **`§ atomVarSignedWritten68`** — the patch adds **0** `VpiSigned` lines.
* **`§ classPropTimeLitInit2` / `§ classPropNullInitParentedByTypespec2`
  (r10buvm2)** — `nullInitDefnParented2`'s BODY is **byte-identical** to
  `7d7c29f`'s (`diff` of the extracted function: no output). Only its first
  ARGUMENT is OR'd. Its "no typespec → no re-parent" law is confirmed on this
  third population — and, per F1/F3, is the **only** half of the initializer
  story the shipped patch got right end-to-end.
* **uvm68 V3 enum_var law** — nothing is stamped or unstamped on an `enum_var`;
  the diff's only `Enum_var` change is `if` → `else if` on the condition.
* **uvm72 / uvm71** — untouched files; the census's other shapes are unchanged
  cell-for-cell.
* **LIVE PASSES.** `r10sd4` landed as `511725d` and `r10earl44` as `dcf67d7`;
  both touch `src/ModuleEmit.cpp` / `src/TaskFuncEmit.cpp` only. `comm -12` of
  the two file sets is **empty** — no collision — and the patch **applies
  cleanly to `dcf67d7`** as well as to `7d7c29f`. The implementer's warning
  stands: if a later package-typedef pass lands, it meets residue R2 head-on.
* **No `README.verifier.md` was shipped by the implementer** — correct, it is
  this file.

---

## 6. RESIDUES, RANKED

* **R1 — the four UNGATED initializer arms (F3).** String / real / time /
  named-value / negated-real initializers on a degraded property keep our var
  parent where golden uses the `class_defn`. This is the pass's own law applied
  to 3 of 7 arms. Cheapest real follow-up: five call sites, one existing
  predicate, cells already written (`v2_init.sv`). No corpus witness.
* **R2 — the NON-degraded sized-literal size (F2), PRE-EXISTING.** `k_sz8`
  (`i_t = 8'd7`): golden **8**, ours **32**, on the pristine binary too. The
  same "literal as written" rule F1 establishes governs it; fixing it is a
  separate head because it CAN move corpus rows.
* **R3 — R1-of-the-implementer's-README is WIDER than stated (F4).** Not only
  package/`$unit` variables: a **MODULE** variable with a class-qualified type
  degrades in golden too (a5 `m_modvar`, never tabled). Same emission site
  family (`TypeEmit.cpp`), still zero corpus witnesses.
* **R4 — POISONED PACKAGE ALIAS.** Confirmed exactly as the implementer states:
  a2 `c_pkgalias` and a3 `c_pkgcls` / `c_pkgpkgcls` / `c_clsofpkgcls` remain
  DISAGREE (a2 `agree=8 DISAGREE=1`, a3 `agree=4 DISAGREE=3`). Two objects, one
  law; the package-typedef half is the prerequisite.
* **R5 — packed-struct property typed by a PACKAGE typedef.** a1 `c_pkg_struct`
  is the single remaining a1 DISAGREE (`agree=22/23`), pre-existing, and it is
  the one residue with a real corpus witness: `uvm_reg_map_info::mem_range`
  @29:27, the census's lone `LHS struct_var / RHS bit_var` cell.
* **R6 — THE NEW HEAD.** `hier_path (arb_sequence_q[i].request.name)` @554:32,
  three rows × 42 lines, one shape, byte-identical across the three. The use
  site of the property this pass fixed. Confirmed as the obvious next head.
* **R7 — `Scoreboard/default` byte nondeterminism (F5).** Not this pass's, but
  it means a byte-level mover reading on that database is only trustworthy with
  the multiset/size-delta rule applied. Worth a line in the next brief.
* **R8 — the 33 remaining census disagreements**, all function-return / local
  families except `mem_range` (=R5). This pass's own family is **empty**.

---

## 7. FILES

* `/tmp/r10uvm73.verified.patch` — the deliverable: shipped patch + the F1 fix +
  the five verifier arms + the verifier instrument + this file.
* Verifier arms added: `v1_spec.sv` (scope empty cells), `v2_init.sv` (ungated
  init arms), `v3_size.sv` (the size carrier), `v4_neg.sv` (its negated twin),
  `v5_vif.sv` (the §6 interaction).
* Verifier instrument added: `v73initcells.py` — the per-cell INITIALIZER table
  (kind / expr node / **expr PARENT** / every `vpiSize`), with the same
  UNKNOWN-CELL guard as `ct73cells.sh`. `ct73cells.sh` reads kind and typespec
  only and is structurally blind to the initializer half this pass legislates;
  **that blind spot is how the "sized 64" clause shipped unrefuted**, which is
  the one instrument lesson of this verification.

## 8. HOW TO REPRODUCE THE FINDINGS

```bash
cd tools/probe/r10uvm73repro
# F1 / F2 -- the size carrier (shipped: DISAGREE=6, re-cut: DISAGREE=2)
SLANG_UHDM=<bin> ./ct73arm.sh v3_size.sv /tmp/x_v3
python3 v73initcells.py /tmp/x_v3/{g,o}.dump c_uns c_uns96 c_uns4 c_mix_w4 c_mix_4w c_sz32 c_sz8 \
                                             k_uns k_uns96 k_uns4 k_mix_w4 k_mix_4w k_sz32 k_sz8
# F1 negated twin
SLANG_UHDM=<bin> ./ct73arm.sh v4_neg.sv /tmp/x_v4
# F3 -- the ungated arms (7 DISAGREE on every binary)
SLANG_UHDM=<bin> ./ct73arm.sh v2_init.sv /tmp/x_v2
python3 v73initcells.py /tmp/x_v2/{g,o}.dump c_strinit c_realinit c_timeinit c_namedinit c_negreal
# F4 -- the unsupported table row and the untabled cell
SLANG_UHDM=<bin> ./ct73arm.sh a5_shape.sv /tmp/x_a5
./ct73cells.sh /tmp/x_a5 c_qual_arrtd c_qual_qtd c_qual_ustruct c_qual_pstruct \
                         c_qual_dyn c_qual_q p_pkgvar l_fnlocal m_modvar     # UNKNOWN-CELL=2
# §2 -- the scope empty cells (5 -> 14 AGREE) and the vif interaction (6/6)
SLANG_UHDM=<bin> ./ct73arm.sh v1_spec.sv /tmp/x_v1 && ./ct73cells.sh /tmp/x_v1 v_pgen_own v_pgen_ownenum …
SLANG_UHDM=<bin> ./ct73arm.sh v5_vif.sv  /tmp/x_v5 && ./ct73cells.sh /tmp/x_v5 c_qual_vif c_qual_vifmp …
```
