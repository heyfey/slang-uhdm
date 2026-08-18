# r10earl61 — § connOperandOwnScopeBind61 + § patFlatUnsizedMemberWidth61

**BOTH Earlgrey_0_1 heads cleared, TWICE OVER: the default head fell to law A
(29 cmp lines → 36) and then to law B (36 → 19); the testflags head fell to law
B (30 → 37).  Both modes now sit on the SAME new family.  And the pass is
FIRST A REFUTATION OF A LANDED SCOPE NOTE: `§ patFlatDefaultFillMemberWidth27`
says in the file "SCOPE — deliberately the DEFAULT setter only.  An unsized
literal written as a NAMED member value is the UNMEASURED HALF."  It is measured
here, and the rule is not the default setter's at all — Surelog's own code tests
the member value and nothing else.**

Binaries: pristine `7c1e02d417e28bb042669ec578e7a74a`,
patched `aca646e465c56158a17fff77248fa848`.
Baselines used are the ones **in this worktree** (`results/gate_uhdm2rtlil.csv`,
`results/golden_surelog.csv`); `results/*.csv` was never written.

| head | pristine | patched | heads |
|---|---:|---:|---:|
| Earlgrey_0_1/default   | 29 cmp lines | **19** | 1 → 1 |
| Earlgrey_0_1/testflags | 30 cmp lines | **37** | 1 → 1 |

(cmp LINE COUNT is HEAD DEPTH, never a distance — the testflags head grew
because the new head object prints deeper, not because anything regressed.)

---

## 1. LAW A — § connOperandOwnScopeBind61

> In the ELABORATED view a **nested** reference inside a port `High_conn`
> expression — an operation's operand, a select's index, a call argument:
> anything below the top-level actual — binds its `Actual_group` **only to what
> the instantiation's own scope declares**.  At module scope that is the whole
> module body, so nothing changes.  Inside a **generate block** it is that block
> alone, and an outer name (the enclosing module's port/net/var, an **outer**
> generate block's local) stays **UNBOUND**.  The top-level actual is exempt.

### 1.1 Decoded from Surelog, not guessed

`NetlistElaboration::high_conn_` compiles a named port connection with

```cpp
hexpr = compileExpression(parent_comp, fC, Expression, …, Reduce::Yes,
                          /*pexpr=*/nullptr, /*instance=*/parent);
…
p->High_conn(hexpr);
if (hexpr->UhdmType() == uhdmref_obj)          // <-- ONLY the whole expression
    ((ref_obj*)hexpr)->Actual_group(net);      //     net = bind_net_(…), which
                                               //     DOES walk the hierarchy
```

Every **nested** ref is left to `CompileHelper::bindVariable(component,
ValuedComponentI* instance, name)` (`CompileStmt.cpp:3062`), whose entire body is

```cpp
if (ModuleInstance* inst = valuedcomponenti_cast<ModuleInstance*>(instance)) {
  Netlist* netlist = inst->getNetlist();
  if (netlist) { …nets()… ; …variables()… }
}
return nullptr;                                 // NO PARENT WALK
```

For a module-scope instantiation that netlist is the module instance's, so the
module's own ports and signals bind.  For a gen-scope instantiation it is the
**generate block's** netlist, which holds only that block's own declarations.
`UhdmWriter::lateBinding` never rescues it either: its parent walk handles
`design / function / task / for_stmt / foreach_stmt / gen_for / begin /
named_begin / fork_stmt / named_fork`, and a HighConn operand's chain is
`ref → operation → port → module_inst`.

### 1.2 MEASURED ON GOLDEN, three grids, before a line of code

`g1_earl61.sv` — every HighConn shape × module scope / if-generate /
for-generate / nested generate.  `hccensus61.py` keys every `port` on
(section, owner instance, formal, hc kind, every nested bindable's
name = ACTUAL-kind(name)); `Actual_group` is the only field
`design::Compare` reads there.  **LHS is always golden.**

| actual, ELAB view | module scope (u1) | if-gen (u2.gen_if) | for-gen | nested gen |
|---|---|---|---|---|
| `clk` (bare ref) | bound | bound | — | — |
| `~clk` | **bound** | **—** | **—** | **—** |
| `v & u` | bound (v, u) | — , — | — | — , — |
| `{v, u}` | bound, bound | — , — | — | — |
| `vv[0]` (whole hc) | — | — | — | — |
| `\|vv[1:0]` | — | — | — | — |
| `f61(v)` | bound | — | — | — |
| `sel ? v : u` | bound ×3 | — ×3 | — | — |
| `1'b0` | (no refs) | (no refs) | — | — |

`g2_earl61.sv` cuts the *what*: a gen-scope operand naming a signal declared
**inside that same gen block** IS bound (`gl & gm` → `logic_var
…u1.gen_l.gl`), and a gen block that is an **ancestor** but not the immediate
parent does NOT unbind (`m_anc61`: `i_sub` sits at module scope inside
`m_inner61`, and its `~clk` operand is bound on both sides).  Three instances
and a `[2:0]` instance ARRAY inside one gen block: golden unbinds every one.

`g3_earl61.sv` cuts it to the exact `bindVariable` semantics:

```
gen_o.gen_i's  .a(ol & om)   naming gen_o's locals   ->  UNBOUND
gen_o.gen_i's  .a(il & il)   naming its OWN locals   ->  BOUND
gf[i]'s        .a(fl & clk)  fl gen-local / clk module -> BOUND / UNBOUND
gen_b.gen_bb's .a(bl & bl)   naming gen_b's local    ->  UNBOUND
module scope   .a(ml & clk)                          ->  BOTH BOUND
```

Every one of those five rows is reproduced by the patched binary, and
**`g3_earl61.sv` CONVERTS: `CMP_FAIL` (1 head, 31 lines) → `PASS_CMP`,
heads = 0.**

### 1.3 The code

`ModuleEmit.cpp`: a RAII guard next to the existing `ElabConnGuard21` records
`connGenBlockScope61(inst)` — the generate block that immediately encloses the
instantiation, skipping the `InstanceArray` wrapper — for the duration of the
actual's emission.  `ExprEmit.cpp`: one clause in the existing netMap-bind guard
chain,

```cpp
!(elabConnEmit21 && connGenScope61 &&
  !(parent && parent->UhdmType() == UHDM::uhdmport) &&   // top-level actual is exempt
  nv.symbol.getParentScope() != connGenScope61)
```

`parent == the port` is exactly "this is the whole actual", which is exactly the
`hexpr->UhdmType() == uhdmref_obj` test Surelog applies at the same place.

---

## 2. LAW B — § patFlatUnsizedMemberWidth61, and the note it refutes

> On the **cont_assign** carrier, an assignment-pattern member value written as
> an **unsized literal** (`'0`, `'1`, `'x`, `'z`) is re-typed to the **member's
> own width**: `vpiSize` = member bits, `UINT:<0 or mask>`, `vpiConstType` 9,
> decompile the decimal digits.  `'x`/`'z` fold to **0**.  A sized literal, a
> bare decimal, and any constant nested **inside** a member value are untouched.

`UHDM::ExprEval::flattenPatternAssignments` (`ExprEval.cpp` ~890) is the whole
law, and it tests the tagged_pattern's `Pattern()` alone:

```cpp
if (patt->UhdmType() == uhdmconstant) {
  constant* c = (constant*)patt;
  if (c->VpiSize() == -1) {
    uint64_t uval = get_uvalue(invalidValue, c);           // strict == false
    if (uval == 1) { …VpiValue("UINT:"+mask); VpiConstType(vpiUIntConst);
                     VpiSize(size); }
    else if (uval == 0) { …UINT:0, vpiUIntConst, VpiSize(size); }
  }
}
```

It knows nothing about which key put the value there — a slot filled from
`default:` is a **clone of that same tagged_pattern**, which is precisely why
`§ patFlatDefaultFillMemberWidth27` worked while claiming the rule was the
default fill's.  `'x` is claimed by the `uval == 0` arm because
`NumUtils::parseBinary("X")` fails and leaves `result` at 0 while `strict` is
false, so the old `!fb9.isUnknown()` guard was wrong too.

`b1_earl61.sv`, ELAB, golden first, on `{3,1,8,16}`-bit members:

| written | golden | pristine |
|---|---|---|
| `w3 : '1` | `UINT:7` sz 3 dec `7` ct 9 | `BIN:1` sz 3 ct 3 |
| `w1 : 'x` | `UINT:0` sz 1 dec `0` ct 9 | `BIN:X` sz 1 ct 3 |
| `w16 : '0` (after non-constant members) | `UINT:0` sz **16** dec `0` | `BIN:0` sz **-1** |
| `w8 : 8'h00` | `HEX:00` sz 8 ct 5 | identical — a SIZED literal is not `VpiSize()==-1` |
| `w16 : 0` (bare decimal) | sz 16 | sz **64** |
| `'0` inside a member's ternary arm | `BIN:'0` sz -1 | identical — the test is on the member value ITSELF |

The bare-decimal row is not the flatten: it is `expandPatternAssignment`'s
`adjustOpSize` walk, which stops at the first operand Surelog's reduce cannot
value.  Once the flatten has turned `'x` into a plain sized UINT the walk no
longer stops there — so the patch also records which operands it re-typed and
lets the existing walk continue past them.

### 2.1 The FENCE, and why

The same arm is reached by the **declaration-initializer** carrier
(`patFlatAdjust` false).  `b2_earl61.sv` E1 shows Surelog models
`t61_t dv = '{…};` in a module body as a **struct_NET with no `Expr` at all**,
where we emit a `struct_var` carrying one — the arm's shape already diverges, so
there is no golden witness for the widening.  It is therefore **fenced to the
cont_assign carrier**.  With the fence off, b2's 3-way line multiset read
TO-GOLDEN 8 / AWAY-GOLDEN 0 / STILL-WRONG 6, so this is caution, not a convicted
regression — it is **ranked (R5), not taken**.  With the fence on, `b2_earl61.sv`
is **byte-identical** pristine vs patched.

---

## 3. THE EARLGREY MOVE, keyed

`hccensus61.py` over the whole design, 31 439 port-HighConn rows per mode, DEF
and ELAB row-for-row aligned with golden (12 276 + 19 163 on both sides):

| Earlgrey_0_1/default, disagreement class | pristine | patched |
|---|---:|---:|
| **GOLDEN-NULL / OURS-BOUND** | **16** | **0** |
| REFCOUNT (operand-list length) | 56 | 56 |
| NAME-DIFF (same kind, different name) | 147 | 147 |
| KIND-DIFF | 1 | 1 |

Nothing but the target class moved.  The 16 cells are, by name:
`…i_tck_inv.gen_scan.i_dft_tck_mux.clk0_i` (the head), `…u_clk_spi`'s twin,
`…u_flash_eflash.gen_flash_banks[0,1].i_core` (`host_req_i`, `host_bank_sel`),
those banks' `i_rd` (`rdy_o`, 4 each) and `flash_phy`'s `ctrl_bank_sel` /
`host_bank_sel`.

**Earlgrey_0_1/testflags DEF+ELAB is UNCHANGED** (REFCOUNT 56, NAME-DIFF 147,
before and after) — and that is a fact the brief did not have: under
`-elabuhdm` **golden's ELAB copy IS bound**, because UHDM's own
`ElaboratorListener` re-binds the elaborated clone; golden's unbound copy is the
`weaklyReferenced` **TAIL** original.  A law A implemented without checking the
second mode would have looked like a 16-cell regression there.  Our 16 removed
edges land in the tail, i.e. **toward** golden, and the judge sees nothing.

Law B, block-for-block, on the two assignment patterns Earlgrey actually has:

| block | mode | golden vs pristine | golden vs patched |
|---|---|---:|---:|
| `tlul_adapter_reg.sv:93:17-104:4` (49 copies, 2 899 lines) | testflags | 1 664 diff lines | **0 — BYTE-IDENTICAL** |
| `tlul_adapter_sram.sv:129:17-142:4` (10 copies) | default | 176 | 32 |
| `tlul_adapter_sram.sv:129:17-142:4` (28 copies) | testflags | 382 | 112 |

and the 32/112 residual is entirely the NEW HEAD (`PREDICT_R0.txt`): the
`OpRead` enum-const bind golden makes inside the ternary condition.

---

## 4. THE ARBITER — sectioned 3-way, whole dump

`sect3way61.sh`: DEF+ELAB only (the `weaklyReferenced` TAIL is unreachable to
`design::Compare` — r10earl60 R8), path-normalised, indentation-stripped,
**line multiset** rather than `diff` (a `diff` reports a moved line twice and
turns a cell that landed ON golden into two phantom movers).

```
Earlgrey_0_1/default    TO-GOLDEN=6   AWAY-GOLDEN=0   STILL-WRONG=12
Earlgrey_0_1/testflags  TO-GOLDEN=2   AWAY-GOLDEN=0   STILL-WRONG=10
```

Every STILL-WRONG row moves toward golden except `|vpiSize:1`, where we were
already 44 over golden and are now 62 over — a family shared with thousands of
unrelated objects, recorded rather than hidden.  Both TO-GOLDEN rows in
testflags are the two pattern operations' **exact** counts (146 → 194 = golden
194; 99 → 117 = golden 117).

Blast radius, path-normalised, pristine vs patched:
**562 lines / 82 hunks (default), 2 096 / 116 (testflags)** — and the histogram
IS the law: 66 `'0`→`UINT:0` re-encodings with 25 `vpiSize:3` + 25 `vpiSize:16`
+ 16 `vpiSize:1` added, and 16 `|vpiActual:` removed naming exactly the seven
nets above.

---

## 5. GATES — every one run, on the FINAL binary

1. **Build both, `-j 2`, md5 separately.**
   pristine `7c1e02d417e28bb042669ec578e7a74a`, patched
   `aca646e465c56158a17fff77248fa848`, frozen at `/tmp/r10earl61_bin/…` before
   any sweep, `chmod a-w`.
2. **Goldens** — `SLANG_UHDM` exported explicitly to EACH binary:
   patched **23 PASS / 0 FAIL**, pristine **23/0**, `/bin/false` **0 PASS /
   23 FAIL**.
3. **uhdm2rtlil, both modes** — `679 CMP_EQUAL / 50 SLANG_REJECT /
   2 SURELOG_FAIL` in **both** modes; `ct8rows.sh` vs the committed
   `results/gate_uhdm2rtlil.csv`: **0 differing rows**, status AND dump column,
   dump histogram `183 differ / 496 match / 52 blank` unchanged.  The default
   mode's whole-row diff patched-vs-pristine is **0**.
4. **surelog, `--mode both`** — `ct8rows.sh` vs the committed
   `results/golden_surelog.csv` over **1 588 rows: 0 differing rows**, both
   histograms identical (default `470/11/5/283/25`, testflags
   `466/9/5/3/1/284/23/1/2`).  **No row converted, so `results/*.csv` was not
   touched** — `Earlgrey_0_1` stays `CMP_NOTEQUAL` in both modes.
5. **Byte verifier, `SELFCHECK=1 SELFCHECK1=1`** —
   * uhdm2rtlil: **0 movers / 1 358**; selfchecks 1 357/1 358 and exactly 1.
   * surelog: **3 movers / 956**; selfchecks 955/956 and exactly 4 (= 1 + 3).
     `./default/Earlgrey_0_1`, `./testflags/Earlgrey_0_1` — predicted by name in
     `CENSUS_PREDICT61.txt`.  `./default/Scoreboard` — **EXONERATED**: the
     PRISTINE binary alone produces two different databases on two consecutive
     runs of that test (`366f571b5813`, `93089c7a372b`), and one of them is the
     hash the byte verifier reported for the *pristine* side, while two direct
     patched runs both produced `366f571b5813` too.  The dump difference is a
     single `bit_typespec (uvm_reg_addr_t)` block moved ~100 lines inside the
     `weaklyReferenced` TAIL (`\_weaklyReferenced:` is at line 1 029 823, the
     block at 1 098 958) and the whole-dump line **multiset is identical** — a
     pure ordering permutation, cross-binary, in a section the judge cannot
     reach.  This is the documented Scoreboard/default coin.

**cmds.txt audit, every file, not a sample:**

```
uhdm2rtlil_pat  1458 x /tmp/r10earl61_bin/slang-uhdm-patched3
surelog_pat     1523 x /tmp/r10earl61_bin/slang-uhdm-patched3
uhdm2rtlil_pris 1458 x /tmp/r10earl61_bin/slang-uhdm-pristine
surelog_pris    1523 x /tmp/r10earl61_bin/slang-uhdm-pristine
```

This audit **caught a defect in the shipped sweep driver** and it is fixed in
`sweeps61.sh`: the one-line readback `find "$wdir" -name cmds.txt | head -1` is
UNSOUND ON A RE-RUN — both modes live under one root, so re-running only the
default mode makes the walk find the previous binary's testflags file first.
This run printed `patched2` for both default sweeps while every file under the
root was `patched3`.  The driver now prints the **histogram over the mode's own
subtree**.

---

## 6. CANARIES and BOUNDARIES

* `canaudit.sh canaries.sh ctcan2.sh` — audited 29 brief names + 3 families,
  **UNCOVERED=0, FENCE-BREACH=0**; the four slang-fenced names are dispatched by
  no driver here and are not spelled in any probe artifact.
* `canaries.sh`: surelog **ok=52 changed=0 absent=0**, u2r **ok=8 changed=0**.
* `ctcan2.sh`: surelog **ok=58 changed=0** (`EXPECT_UNKNOWN=1`), u2r **ok=1
  changed=0** (`EXPECT_UNKNOWN=6`).
* Pins: `SVSwitch` **4842211c4030** and `YosysVerx` **6ccda350c24a** in BOTH
  modes; `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr` byte-identical
  to pristine in both modes.
* **WIDE BOUNDARY** (`vbndall61.sh`, both views, both binaries, arms read from
  THIS worktree): **PROCESSED arms=1 061, runs=2 122, identical=2 067,
  DIFFERING=24 rows = 8 distinct arms, no_output=31.**  Signals symmetric:
  `patched=3 pristine=3` (all three pre-existing rc=139 arms crash on BOTH
  binaries).

  Four of the eight are this pass's own witnesses (`g1/g2/g3/b1`).  The other
  four are attributed with `varm61.sh` (Surelog = golden, 3-way line multiset):

  | arm | view | TO-GOLDEN | AWAY-GOLDEN | STILL-WRONG |
  |---|---|---:|---:|---:|
  | `r10earl_repro/qq.sv` | plain / elab | 3 / 3 | **0 / 0** | 0 / 0 |
  | `r10earl_repro/ug.sv` | plain / elab | 2 / 2 | **0 / 0** | 0 / 0 |
  | `r10earl54repro/v13_v54.sv` | plain / elab | 1 / 1 | **0 / 0** | 2 / 2 |
  | `r10earl54repro/a2_earl54.sv` | plain / elab | 0 / 0 | **0 / 0** | 2 / 2 |

  `qq` and `ug` land **exactly** on golden (`|vpiActual:` 96 → 92 = 92, 97 → 93
  = 93).  `a2_earl54` is the one that needed a real answer: its `sel` net's
  `vpiActual` edge count goes 15 → 10 where golden has 11, i.e. we now unbind
  ONE MORE than golden.  Owner-keyed, golden's extra edge is at
  **`a2_earl54.sv:60`, the MODULE-SCOPE instance array** `u_arr[0:1]` — golden
  carries three `vpiActual → sel` edges under that connection's operation and
  **pristine carried two as well**.  Every edge this pass removed (2 at `:51`
  `gen_b2`, 2 at `:56` `gen_b3`, 1 at `:86` `gen_b11`) is one golden also lacks;
  the shortfall is PRE-EXISTING and is ranked R7.

  **Five multiset rows across `g3` and `b1` are labelled AWAY-GOLDEN by the
  coarse instrument and are artifacts, proven so:** they are `\_gen_scope:`,
  `\_gen_scope_array:`, `\_module_inst:` and `\_logic_var:` **header PRINT
  COUNTS**.  `uhdm-dump` keeps a global visited set, so removing an edge moves
  where an object is first reached and changes how many header-only
  re-references print — it cannot change how many objects exist.  The proof is
  the official judge: **`g3_earl61.sv` goes CMP_FAIL → PASS_CMP**, and a page
  `design::Compare` declares EQUAL cannot contain a real away-move.

* Named boundaries checked by name: earl59's `§ genCaNestedModuleLhsOpRhsBinds59`
  arms (`r10earl59repro/*.sv`) are **byte-identical on both views** — law A
  touches `emitInstance`'s connection path only and law B touches the pattern
  flatten only, neither reaches `writeCont_assign`'s mirror.  The port
  `high_conn` cast law (earl57 R-A) and the `tagged_pattern` / `'0` re-typing
  precedents (`§ patFlatDefaultFillMemberWidth27`,
  `§ patFlatAdjustStopsAtUnvaluable27`, `§ patFlatDidOrder27`) are the two arms
  this pass EXTENDS; both keep their landed behaviour and both are exercised by
  `b1`/`b2`.  All earl45-60 and uvm/buvm arms are inside the 1 061.

---

## 7. FILES

| file | what it is |
|---|---|
| `hccensus61.py` | the keyed PORT-HIGHCONN census: one row per port, every nested bindable's `Actual_group` kind+name, sectioned DEF/ELAB/TAIL.  Marks a header-only print `~HDRONLY` rather than calling it a null edge. |
| `sect3way61.sh` | THE ARBITER: sectioned (DEF+ELAB, TAIL dropped) path-normalised 3-way **line multiset** golden/pristine/patched. |
| `varm61.sh` | per-arm 3-way boundary attributor (runs Surelog + both binaries). |
| `vbndall61.sh` | the WIDE boundary sweep, arms read from THIS worktree, `</dev/null` on every child, `PROCESSED arms=` asserted. |
| `dumpdiff61.sh` | whole-dump path-normalised blast radius + ADDED/REMOVED histogram. |
| `ptblock61.py` | assignment-pattern block extractor (member-by-member summary). |
| `g1_earl61.sv` `g2_earl61.sv` `g3_earl61.sv` | LAW A's grids: shape × scope, what the operand names, where the gen scope must sit. |
| `b1_earl61.sv` `b2_earl61.sv` | LAW B's grid and its carrier boundary. |
| `earl61.sh` `arm61.sh` `sweeps61.sh` `byteverify61.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` `census61.py` `tsinst61.cpp` | the gate harness, carried forward from `r10earl60repro` (`sweeps61.sh` with the cmds.txt readback FIXED). |
| `CENSUS_PREDICT61.txt` | the prediction, written from the pristine databases before the byte verifier ran. |
| `PREDICT_R0.txt` | the NEXT head, both modes, decoded. |

## 8. Reproduce

```sh
git worktree add /tmp/wt_r10earl61 20f9310
cmake -S /tmp/wt_r10earl61 -B /tmp/wt_r10earl61/build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local
cmake --build /tmp/wt_r10earl61/build -j 2
cd /tmp/wt_r10earl61/tools/probe/r10earl61repro
for a in g1 g2 g3 b1 b2; do
  SLANG_UHDM=$BIN ./arm61.sh ${a}_earl61.sv /tmp/arm_$a
  python3 hccensus61.py /tmp/arm_$a/g.dump | grep ^ELAB
done
SLANG_UHDM=$BIN ./earl61.sh /tmp/r10earl61_wd/x default
python3 hccensus61.py /tmp/r10earl61_wd/x/o.dump > /tmp/x.hc
./sect3way61.sh <golden.dump> <pristine.dump> <patched.dump>
```

## 9. Ranked residue

See `PREDICT_R0.txt` R0-default / R0-testflags (one cluster: golden binds an
`Actual` inside an ELAB `op75` member value that we leave null — `enum_const` in
default, `typespec_member` in testflags) and R1–R7 there.

---

## 10. VERIFIER (r10v61) — REPRODUCED, EXTENDED, ACCEPTED

Independent worktrees `/tmp/wt_v61` + `/tmp/wt_v61pris` at `20f9310`, both
binaries rebuilt from source, frozen `chmod a-w` at `/tmp/v61_bin/` before any
sweep, every `cmds.txt` audited by binary path.

**Both md5s reproduce bit-for-bit**: pristine `7c1e02d417e28bb042669ec578e7a74a`,
patched `aca646e465c56158a17fff77248fa848`.  Both headline heads reproduce:
Earlgrey_0_1/default 29 → **19** (1 head → 1 head), testflags 30 → **37**.
Both R0 predictions land verbatim (`enum_const (OpRead)` / `typespec_member
(error)`).  The verifier's own comment corrections are **provably comment-only**
— the tree rebuilds to the SAME binary md5.

### 10.1 The arbiter the real target needs — `hccen61.cpp`

Earlgrey's `uhdm-dump` is >1 GB and takes hours, so `sect3way61.sh` cannot be
run on the pass's actual target.  `hccen61` reads the `.uhdm` directly (under
1 s) and emits an owner-keyed, Compare-visible census of exactly the two slots
these laws touch.  **On Earlgrey_0_1 itself, both modes:**

| mode | slot | keys | TO-GOLDEN | AWAY-GOLDEN | STILL-WRONG |
|---|---|---:|---:|---:|---:|
| default | port HighConn (law A) | 19 163 | 14 | **0** | 0 |
| default | pattern constants (law B) | 2 631 | 66 | **0** | 0 |
| testflags | port HighConn (law A) | 19 163 | 0 | **0** | 0 |
| testflags | pattern constants (law B) | 2 637 | 66 | **0** | 0 |

Every cell this pass moves lands **exactly** on golden.  Law A is a measured
**no-op under `-elabuhdm`** — mechanism decoded and now recorded at the field
declaration: `uhdm_main.cpp` runs UHDM's own `ElaboratorListener`, which
re-binds the clone.

### 10.2 Adversarial grids (`v1`–`v7_v61.sv`), owner-keyed, AWAY-GOLDEN 0

Un-`begin`'d if- and for-generate, case-generate, unnamed `genblk`, 3-deep and
for-in-if-in-for nesting, TOP-module gen scope, name shadowing, gen-local net vs
var, replication / cast / `$bits` / indexed part-select / struct member / mixed
concat / ternary, `.name()`, `.*`, ORDERED (positional) connections, gate
primitives, interface and modport ports, instance arrays, `$unit` operands,
function-call arguments, parameterised children, unconnected ports; law B over
member widths 1/3/8/16/63/64/65/128, signed, enum, packed-array, nested struct,
`'0`/`'1`/`'x`/`'z`/sized, gen-scope and interface and ternary-nested carriers.

### 10.3 Boundary — TWO axes, both wider than the shipped one

* `vbnd_rec.sh` — **recursive** over `tools/probe`: 2 536 arms, 10 144 runs,
  DIFFERING 16 (8 arms × 2 views), signals SYMMETRIC 7/7.  `vbndall61.sh`'s
  `$ROOT/*/*.sv` glob reaches only the 1 061 depth-1 arms; **1 473 deeper arms
  were unmeasured** and are clean.
* `vbnd_dir.sh` — **per-directory** multi-file compile: 1 088 dirs, 4 352 runs,
  **DIFFERING 0**, signals symmetric 4/4.  Covers the 255 single-file arms that
  produce no database alone.

### 10.4 Corrections to this pass's record

1. **`'x`/`'z` fold for the wrong stated reason.** `ExprEval.h:99` declares
   `get_uvalue(bool&, const expr*, bool strict = true)` and the flatten's call
   takes that default, so `strict` is **true**, not false.  The arm still claims
   `'x` because `flattenPatternAssignments` **never reads `invalidValue`**.
   Corrected in-file.
2. **A latent >64-bit landmine, measured (`v7_v61.sv`) and PRE-EXISTING** —
   pristine and patched byte-identical.  Golden's all-ones fill is
   `NumUtils::getMask`, which **saturates at 64 bits**: a 128-bit member's
   `'{default:'1}` is `UINT:18446744073709551615` at `vpiSize 128`, where
   `SVInt::setAllOnes()` yields the full 128-bit value.  Reachable today through
   the UNFENCED `default:` half.  Recorded in-file; not widened here.
3. **`sect3way61.sh` can report a FALSE AWAY-GOLDEN** — `v5_v61.sv` documents
   one in full.  Key by OWNER before believing a line-multiset AWAY row.
4. **Three arm conversions the pass under-reported**: besides `g3_earl61`,
   `r10earl54repro/v13_v54.sv`, `r10earl_repro/qq.sv` and `r10earl_repro/ug.sv`
   all go CMP_FAIL → **PASS_CMP** in the plain view.
5. **Scoreboard/default exonerated with stronger evidence**: six runs of the two
   frozen binaries on the row's own command line produced **five distinct
   hashes**, and one hash (`965bb1ca438d`) was produced by **both** binaries.
