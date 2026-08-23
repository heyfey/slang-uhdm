# r10v109 — ADVERSARIAL VERIFICATION of r10uvm109 (§ `classPropNewLhsNoHoist109`)

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge; the
official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are. slang was **NOT** patched, `results/*.csv` were
**READ ONLY**, nothing was promoted, **no corpus row converted**.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `5011fd9` |
| verdict | **ACCEPT-WITH-FIX** — one law-level over-reach found and fixed |
| production surface added by the verifier | `src/ExprEmit.cpp` only — one new file-static helper `newLhsBase109`, one new conjunct in `classNewAsgLhs109` |
| binaries | pristine `d83fbe712080e876c9593794cf77dc23`, as-shipped patched `d670fdc96cb334ec05997d1e67651b70`, verified `1a97bb04167eb58517943971e183b1c8` — all three built here `-j 2`, md5 taken separately, frozen `chmod 555` before any sweep |

## 1. EVERY HEADLINE NUMBER REPRODUCED BIT-FOR-BIT

Both binaries rebuilt from scratch in fresh worktrees at `5011fd9`; the two md5s
the implementer reported came back **identical**.

| claim | reproduced |
|---|---|
| goldens patched / pristine / `/bin/false` | 23-0 / 23-0 / 0-23 |
| uhdm2rtlil testflags + default | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, both modes, both binaries |
| surelog histogram | 937 / 567 / 48 / 19 / 10 / 3 / 2 / 1 / 1, byte-identical patched vs pristine |
| `ct8rows` | PASS on all 4 u2r comparisons and all 3 surelog comparisons — **0 differing rows over 1588**, status AND dump |
| `cmds.txt` audit BY PATH | surelog 1573 files, ONE binary path each; u2r 1462 files, ONE binary path each |
| byte movers, u2r | **0 / 1358** |
| byte movers, surelog | **4 / 956** — `{default,testflags}/{SimpleUVM,SeqDriver}`; the Scoreboard COIN did not flip in this run |
| order-blind attribution of each mover | **95 lines, ALL removals**, exactly 9 `logic_net`s × 7 lines + 16 `\|vpiActual` × 2 |
| heads (`rowheads.sh`, same instrument both sweeps) | SimpleUVM 17 → **42**; SeqDriver 29, Scoreboard 42, MiniAmiq 348, BuildUVMPkg 17, Earlgrey 36, Rggen 0 all unchanged and **byte-identical head text** |
| the new SimpleUVM head vs `Scoreboard/default`'s | **byte-identical, object ids aside** — R0 confirmed |
| nine UVM databases, `score109.py` | span 64 TO-GOLDEN / 0 AWAY / 0 STILL; nospan 64 / 0 / 0; over **454,152** scored reference cells |
| SimpleUVM implicit-wire surplus | 11 → **2** (`clp`, `top`); golden-only set 8 → 8, **identical** |
| SeqDriver surplus | 10 → **1** |
| grid a1 / a2 / a3 net cells | 12 / 24 → **22 / 24** per view |
| fence, surelog / u2r | MEASURED 956 SKIP 617 **HIT 64 RISK 0** / MEASURED 1358 SKIP 104 HIT 0 RISK 0 |
| predictor | surelog 5 wide / 4 exact (5th = `testflags/SimplifyHierPath`, did not move); u2r 0 / 0 |
| canaries / ctcan2 / canaudit | ok=52 ok=8 changed=0; PASS ×2; audited PASS |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr SAME; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** |
| boundary rejects, all four runs, pristine vs as-shipped | 132/132, 144/144, 116/116, 122/122 — **bit-for-bit the implementer's**; 0 asymmetric rejects; `PROCESSED == LISTED` everywhere |
| boundary differing arms, pristine vs as-shipped | file 11, dir 5 — the implementer's four (`g109_a1/a2/a3`, `r10v107repro/v107_b2.sv`) and their dir-mode `r10uvm75repro`/`r10uvm76repro` order coins (order-blind 0), **plus this directory's seven new arms** |
| `r10v107repro/v107_b2.sv` attribution | **TO-GOLDEN in BOTH views** (def `logic_net` → NONE = golden NONE; elab `logic_net` → `class_var` = golden `class_var`) |
| `r10uvm75repro` / `r10uvm76repro` dir-mode movers | raw 14 / 18, **order-blind 0** — the documented `vpiTaskFunc` order coin, not movers |

## 2. THE BREAK — § `classPropNewLhsNoHoist109` FENCED TOO MUCH

`classNewAsgLhs109` as shipped walks the syntax parents to the nearest
assignment and fences **every** name that came up the LEFT side. The decoded law
does not say that. Surelog's `= new` arm keeps only the hier_path's **FIRST
element** out of the late-binding pool; a **SELECT INDEX** written inside the
same lvalue is compiled by the ordinary `compileExpression` road, which **does**
call `needLateBinding` — so **golden mints the index's implicit wire and binds
it**, and the shipped predicate deleted it.

Measured, both views, on three independent arms:

```
v109_b1.sv   slotArr[idxKappa]           = new(1);
             deepArr[idxOmega][idxKappa] = new(2);
  golden   logic_net(work@topb1.idxKappa)@30:13   logic_net(...idxOmega)@31:13
  pristine IDENTICAL to golden
  shipped  BOTH GONE                                    <<< AWAY-GOLDEN
```

The **official judge** names it. `v109_b6.sv` is the same cell alone:

```
uhdm-cmp golden ours(shipped patch)   ->  17 lines, 1 head
LHS: logic_net: (work@topb6.idxKappa6), line:14:11, endln:14:20
     |vpiParent: \_module_inst: work@topb6 …  |vpiNetType:1
RHS: <null>
```

That is the **exact mirror** of the head this pass cleared: golden binds a wire
we no longer have. `v109_b7.sv` repeats it with the array as a method local;
`v109_b8.sv` is the control (same index on an ORDINARY lvalue — unaffected).

`v109_b9.sv` shows the **second face**, a mint-SPAN move, and is the cleanest
before/after pair in this directory:

```
bagNine[bothIdxPsi] = new(bothIdxPsi);   // the same property indexes the lvalue
selfNewUpsilon      = new(argOnlyChi);   //   and is a constructor argument
  golden   logic_net(work@topb9.bothIdxPsi)@18:13   (the INDEX, first in the pool)
  pristine 18:13   — right
  shipped  18:31   — the wire survives only because the ARGUMENT is still in the
                     pool, and it is minted at the WRONG reference
  pristine head : LHS <null> / RHS logic_net(work@topb9.selfNewUpsilon)@19:5  (17 lines)
  shipped  head : LHS logic_net(work@topb9.bothIdxPsi)@18:13 / RHS <null>     (17 lines)
```

i.e. the shipped patch traded one surplus wire for one missing wire on this arm.

**WHY THE PASS'S OWN INSTRUMENTS COULD NOT SEE IT.**
* `fence109.sh` selects on the census column `NEWLHS`, which the census sets
  only for the **first** `Path_elems` element. An index reference is a different
  `ref_obj` whose `vpiParent` is a `bit_select`, so it never enters the fence at
  all — `RISK 0` was measured over a population that excludes the broken cells.
* `pred109.sh` selects on `PAR == hier_path`, with the same blind spot.
* `score109.py` (the nine-database corpus score) INTERSECTS keys across the
  three databases, so a wire that **vanishes** is not scored AWAY — it silently
  becomes a `golden-only-key`. Its companion NET-NAME SURPLUS table
  (`GOLDEN-ONLY 8 → 8 IDENTICAL`) is the instrument that covers that, and it is
  clean because the shape does not occur in either corpus.
* `attrib109.sh` (the boundary attribution) is NOT blind — it is a full outer
  join and prints `golden={…} pristine=- patched=-` rows. The gap there was
  **arm coverage**, not instrumentation: `g109_a2`'s only indexed `= new` cell
  is `idxNewD[1] = new();`, a **literal** index, and `r10v107repro/v107_b2.sv`'s
  `h.arr[ix] = new();` indexes with a method LOCAL, which the class-property
  predicate never reaches. No committed arm ever put a hoistable class-property
  NAME inside a `= new` lvalue, so nothing could report the cell.

## 3. THE FIX (minimal, in the same predicate)

```cpp
static const slang::syntax::SyntaxNode* newLhsBase109(const SyntaxNode* n);  // NEW
    // descends ElementSelectExpression.left / MemberAccessExpression.left /
    // ParenthesizedExpression.expression and answers the lvalue's BASE name
...
        if (rk != NewClassExpression && rk != CopyClassExpression) return false;
        return newLhsBase109(be.left) == sn;      // NEW: only the BASE is fenced
```

Everything else in the pass is untouched. The other three users of the pool
(§ 75 with-iterators, § 76 class-scope enum constants, § 107 `ref_var` locals)
are unreachable from a class `new` lvalue and are unaffected — `v109_b5.sv`
puts one of each beside a fenced `= new` and all three keep their golden wire.

## 4. WHAT THE FIX COSTS: **NOTHING**

`byteverify.sh SELFCHECK=1`, verified vs as-shipped:

```
surelog     MOVERS 1 / 956   -- default/Scoreboard ONLY, order-blind 0 (the COIN)
uhdm2rtlil  MOVERS 0 / 1358
```

and the boundary, pristine vs verified, is a STRICT SUBSET of pristine vs
as-shipped: `DIFFER 11 -> 8` (file, both views), `5 -> 5` (dir), rejects
unchanged at 132/144/116/122, 0 asymmetric — the three arms the shipped patch
broke are byte-identical to pristine again and **nothing new moves**.

The four law databases `{default,testflags}/{SimpleUVM,SeqDriver}` are
**byte-identical** between the as-shipped and the verified binary. The broken
shape has **zero reach in either corpus**, so every headline number in §1 holds
verbatim for the verified binary, and it re-passes the whole battery:
goldens 23-0, u2r 679/50/2 both modes, surelog 937/567/48/19/10/3/2/1/1,
`ct8rows` PASS on all six comparisons, canaries ok=52 / ok=8 changed=0,
ctcan2 PASS ×2, `cmds.txt` one binary path each (1573 / 1462).

## 5. THE ARMS

| arm | what it puts under the law | shipped | verified |
|---|---|---|---|
| `v109_b1.sv` | class property as the **INDEX** of a `= new` lvalue (1-D and 2-D), plus an `= new[n]` size and two plain controls | **2 wires lost** | golden |
| `v109_b6.sv` | the same cell, minimal, class-property array | **1 wire lost, IT IS THE HEAD** | golden |
| `v109_b7.sv` | the same cell with the array a **method local** | **1 wire lost** | golden |
| `v109_b8.sv` | control: same index on an ORDINARY lvalue | unchanged | unchanged |
| `v109_b9.sv` | the same name as **index of the lvalue AND constructor argument**; plus `p = new(otherProp)` | **span 18:13 → 18:31** | golden |
| `v109_b10.sv` | the property name reached through a **function call** and a **cast** inside the lvalue's index; a class property that **shadows a package-level variable** of the same name; a **module-nested** class (no package home) | **2 wires lost** (`callIdxRho`, `castIdxTau`); the shadow cell is TO-GOLDEN | golden on all four |
| `v109_b2.sv` | `this.` / `super.`-qualified `= new` lvalues, an inherited property, plain controls | correct | correct |
| `v109_b2n.sv` | the NONBLOCKING `x <= new()` corner — **ILLEGAL SV**, Surelog rejects it (`PA0207` at the `new` token), so the predicate's `NonblockingAssignmentExpression` arm is unreachable on legal source | — | — |
| `v109_b3.sv` | **mint ORDER**: `= new` first + a later plain read (golden mints at the READ — shipped and verified both move the span to golden's 32:21); a plain read first + a later `= new`; and two names the module **DECLARES** (golden leaves the `= new` lvalue unbound even when the net exists — both binaries match) | correct, 6/6 ref cells to golden | correct |
| `v109_b4.sv` | `= new` inside a for body, `fork…join`, a case item, a `foreach` body indexed by the ITERATOR, a `while`, both halves of an `if/else`; two tops, a child, two instances, an import-only and an import-nothing module | correct | correct |
| `v109_b5.sv` | a `with`-iterator (§75), a class-scope enum constant written bare **and** `::`-scoped (§76), a `ref` formal (§107) and a plain read, each beside a fenced `= new` | all four keep their golden wire | same |

`GRID.v109.txt` is the cell-by-cell table (golden / pristine / as-shipped /
verified) for every arm above plus `g109_a1/a2/a3` and `r10v107repro/v107_b2.sv`,
in BOTH views, with each arm's `uhdm-cmp` line count.

## 6. RESIDUES THIS VERIFICATION LEAVES

1. **R0 stands** — SimpleUVM ×2's new head is byte-identical to
   `Scoreboard/default`'s: the unfolded unary MINUS at
   `uvm-1.2 base/uvm_sequencer_base.svh:529:23` (golden one signed `INT:-1`,
   ours `operation vpiOpType:1` over `UINT:1`). ONE law heads THREE rows.
2. **R-IDXPOOL (new, from this verification)** — the pool rule is per-ELEMENT,
   not per-lvalue: the base of a `= new` lvalue is out, every other name written
   inside it is in. Zero corpus reach today; it becomes reachable the moment a
   UVM-style `arr[prop] = new()` appears in a hoisted out-of-body body.
3. **Instrument residue** — `score109.py`'s three-way key intersection cannot
   report a VANISHED cell as AWAY. Any future pass that removes objects must
   score the one-sided sets explicitly (the NET-NAME SURPLUS table does; make it
   the primary, not the appendix).
4. **R-CLP / R-TOPNET** confirmed by name: SimpleUVM's remaining ours-only
   implicit wires are exactly `clp` and `top`.
5. **R-MULTI** re-measured on `g109_a3` and on `v109_b4` (`ctlNu4`, `readNu5`
   minted in every importing module where golden mints in one): PRE-EXISTING,
   byte-identical in all three binaries.

## 7. FILES

```
README.md              this file
GRID.v109.txt          every arm, both views, golden/pristine/shipped/verified
SCORE.uvm9.reproduced.txt   the nine-database score, reproduced here
GATES.v109.txt         the whole battery, three binaries
BOUND.v109.txt         the four boundary runs
head_pris_v109_b9.cmp        pristine head: the surplus wire the law targets
head_patAsShipped_v109_b9.cmp the SHIPPED head: the wire golden has and it lost
head_patAsShipped_v109_b6.cmp the same, on the minimal arm
v109_b1..b9.sv         the arms
run109v.sh             golden + two of ours, both views, census + official cmp
```
