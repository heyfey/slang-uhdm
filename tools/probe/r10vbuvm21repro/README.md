# r10vbuvm21 — the ADVERSARIAL VERIFICATION of r10buvm21 (§ `incDecStmtOperandBinds21`)

**VERDICT: ACCEPT WITH FIX.**  Every headline number in the implementer's report
reproduced **bit-for-bit** from binaries this verifier built itself.  The law is
real and its operand/home/direction halves survived every attack.  Its **CARRIER
clause was too wide**: the shipped patch binds through a **delay control** and a
**`wait` statement**, where golden stays BARE — nine minimal, legal-SV arms go
**`uhdm-cmp` 0 lines (EQUAL) → 29 lines (NOT EQUAL)** under the OFFICIAL judge.
Fixed here by § `incDecOpaqueCarrier21`; the fix is **byte-inert on both
corpora** (fixed-vs-shipped `MOVERS 1/956`, and that one is the Scoreboard COIN
with an ORDER-BLIND diff of 0 lines).

**MEASUREMENT ONLY.**  Nothing in this directory is an acceptance judge; the
official `uhdm-cmp` and `scripts/verify_golden.py` are.  slang was NOT patched,
`results/*.csv` were READ-ONLY, nothing was promoted.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `e5eb5af` |
| worktrees | `/tmp/wt_vbuvm21` (patch + fix), `/tmp/wt_vbuvm21pris` (pristine) |
| pristine binary | md5 `9cb73f6c03626b09747a2bee794514c9` — **identical to the implementer's**, rebuilt from scratch |
| shipped-patch binary | md5 `15cb901fe573c114ed7f5ec336049af2` — **identical to the implementer's** |
| verified binary (patch + fix) | md5 `6acc5e0b1d631e04e4ed154fbf289d14` |
| deliverable | `/tmp/r10buvm21.verified.patch` |

## 1. WHAT REPRODUCED, BIT FOR BIT

| implementer's number | verifier's independent measurement |
|---|---|
| pristine / patched binary md5 | **both identical** (deterministic build reproduced) |
| goldens 23/0, `/bin/false` 0/23 | 23/0 pristine, 23/0 patched, 23/0 fixed, 0/23 negative |
| u2r testflags 679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`, 0 differing rows | identical, and 0 rows vs the committed gate AND pristine, both modes |
| surelog 0 differing rows over 1588, no row converted | identical (936 `CMP_EQUAL` / 20 `CMP_NOTEQUAL` / … unchanged) |
| `MOVERS 9/956` surelog, `0/1358` u2r | identical, same nine names, 8 of 9 hashes equal, Scoreboard = the coin |
| every mover = `0 removed / 2 added`, the added lines an `io_decl` `vpiActual` | identical for all nine |
| `BuildUVMPkg` cmp 29 → 52 lines, md5 `6e1067f4…` → `f21a1042…`, 1 head each | identical, both modes |
| ten other row cmp logs byte-identical | identical (`cmp -s` on the raw logs) |
| grid `g21/g21b/g21c` = 194 cells, **42 CONVERTED, 0 OVER-FIRE, 0 residue** | identical (98/62/34 cells, 17/15/10 converted) |
| corpus census 44 945 cells, **CONVERTED 1, OVER-FIRE 0, MSW 0, same 42 424, residue 2 520** | identical, same single key |
| boundary's 4th arm (`r10buvm7repro/v1_lvincdecshape.sv`) is a CONVERSION | identical: 44 cells, 37 same, **2 CONVERTED, 0 OVER-FIRE**, residue 5 |
| canaries `ok=52` / `ok=8`, `ctcan2` PASS, `canaudit` 29/0/0 | identical |
| protected DBs `InterfaceModPort`/`BlackParrotComplex`/`YosysOldOr` SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | identical |

## 2. THE BREAK — § `incDecOpaqueCarrier21` (PRISTINE-RIGHT → PATCHED-WRONG)

The shipped law says the chain from the `++` up to the subroutine may pass only
through BLOCK scopes and no control statement.  Our emitter's `ctrlBodyDepth28`
is raised for `Conditional / Case / For / Foreach / While / DoWhile / Forever /
Repeat` **and nothing else**, so a **`Timed`** statement (`#1 …`) and a
**`Wait`** statement (`wait (c) …`) pass the token straight through.  Golden does
not bind through either — `v4timing.sv`, DEFAULT view, 17 measured cells:

| carrier chain (inner → outer) | golden |
|---|---|
| `bit_select:IDX<operation#62:OP0` (nothing) / `<begin` / `<fork_stmt` | **BOUND** |
| `<event_control`, `<begin<event_control` (`@(ev)`, `@(posedge clk)`, `@(a or posedge b)`) | **BOUND** |
| `<delay_control`, `<begin<delay_control`, `<delay_control<begin`, `<delay_control<fork_stmt` | **bare** |
| `<event_control<delay_control`, `<delay_control<event_control` | **bare** |
| `<wait_stmt`, `<begin<wait_stmt`, `<wait_stmt<begin`, `<wait_stmt<event_control` | **bare** |

so ONE delay/wait ANYWHERE on the chain blocks the bind — a DEPTH, not a flag —
while an event control is transparent.  The shipped binary bound **all 13** of
those cells (`OVER-FIRE 13`).

**The official judge convicts it.**  `vmin21.sh` writes 16 one-construct arms,
each of which the PRISTINE binary already compares EQUAL, and runs
`uhdm-cmp golden ours` on each (DEFAULT view):

```
                 PRIS   SHIPPED   FIXED          verdict
plain/beg/fork/evt/assertblk/scalar   29 →  0  →  0   the law's own conversions, kept
delay, delaybeg, delayfork, delayonbeg, delayscalar,
delayevt, evtdelay, wait, waitbeg      0 → 29  → 0   REGRESSION, fixed
ifstmt                                 0 →  0  →  0   § controlBodyNoBind28, untouched
```

The regression head is the MIRROR of the head this pass cleared — the singular
`ref_obj::Actual_group` arm with **`LHS: <null>`**, i.e. OURS carrying an
`io_decl (s)` actual that golden does not.

### THE DECODE (Surelog, read not guessed)

* `CompileHelper::compileEventControlStmt` (`CompileStmt.cpp:1374`) runs
  **`event->VpiParent(pstmt);` BEFORE** `compileStmt` on the inner statement, so
  the eager `bindVariable` walk climbs event_control → function and BINDS.
* `CompileHelper::compileProceduralTimingControlStmt` (`CompileHelper.cpp:3016`)
  makes its `delay_control` and passes it to `compileStmt` **without ever
  setting `dc->VpiParent`** → the walk dead-ends → BARE.
* `case VObjectType::paWait_statement:` (`CompileStmt.cpp:720`) makes its
  `wait_stmt`, compiles the guarded statement under it, and only parents the
  wait afterwards → BARE.

### THE FIX (minimal, gated)

`int incDecOpaqueDepth21` (UhdmExporter.h) + an RAII `IncDecOpaque21` raised in
`StmtEmit.cpp` around **only** the delayed statement of a `TimingControlKind::
Delay` timed statement and the guarded statement of a `Wait`; the statement-
position token is raised only at `ctrlBodyDepth28 == 0 && incDecOpaqueDepth21 ==
0`.  Event controls are untouched.  A statement AFTER an opaque carrier in the
same block still binds (`l_afterdel` / `l_afterwait` in `v4timing.sv`, golden
BOUND, ours BOUND — the RAII restores the depth).  PACKAGE free subroutines bind
in every carrier in golden and already did in ours (`pf_del` / `pf_wait`); the
fix does not reach them.

## 3. THE REST OF THE ATTACK — WHERE THE LAW HELD

Three-way censuses (golden / pristine / fixed), DEFAULT view, `--noloc`, multiset
join, `ALLREFS=1`:

| arm | cells | CONVERTED | OVER-FIRE | MSW |
|---|---|---|---|---|
| `v1carrier.sv` — Timed/Wait/assert/label/fork-join_any/join_none/unique-if/priority-case | 51 | 10 | **0** | 1 (a label SHAPE artefact, § 5) |
| `v2home.sv` — inheritance + `super.new`, ctor, static/virtual/extern-OOB, parameterized ×2 specialisations, nested class, class in a PROGRAM and an INTERFACE, every direction (`ref`/`inout`/`output`/default-valued), task | 49 | 15 | **0** | 0 |
| `v3operand.sv` — assoc by int/string/CLASS-HANDLE/enum, queue, dynamic, fixed, 2-D, nested index `af[ai[k]]`, arithmetic index, CALL index, part-select and ips bases, `this.`, handle base, local-handle base, package-var base, formal-array base, member paths, `s++` on every direction, block/named-block/nested-block locals, `$unit` class + free function | 63 | 21 | **0** | 0 |
| `v4timing.sv` — the carrier boundary above (+ leak and package controls) | 69 | 8 | **0** | 0 |
| `g21.sv` + `g21b.sv` + `g21c.sv` (the pass's own) | 194 | 42 | **0** | 0 |
| `r10buvm7repro/v1_lvincdecshape.sv` | 44 | 2 | **0** | 0 |

**ELAB view.**  The pass's `grid21.sh` ran the DEFAULT model only; `vgrid21.sh`
runs both.  In the elaborated model golden holds ONE copy per site and binds it,
while ours holds a DEF and an ELAB copy — so the elab join is scored per key
against golden's value: on `g21c.sv` **10 moved keys, all TO-GOLDEN, 0 AWAY**,
and the elab `uhdm-cmp` head is unchanged on every arm measured.

**BOUNDARY (both views, fixed binary).**  A COPY of the whole `tools/probe`
tree, no path filter, arm list on fd 3, children `</dev/null`, rc recorded per
cell, dumps banner/path-normalised:

```
VIEW=def   LISTED=3014 PROCESSED=3014 REJECTS_A=222 REJECTS_B=222 DIFFER=8
VIEW=elab  LISTED=3014 PROCESSED=3014 REJECTS_A=231 REJECTS_B=231 DIFFER=4
```

rejects symmetric in both views, `PROCESSED == LISTED`.  The eight DEF-view
differing arms are the three `g21*` arms, `r10buvm7repro/v1_lvincdecshape.sv`
(re-measured against golden: 2 CONVERTED / 0 OVER-FIRE) and this verifier's own
four positive controls.  Every other bind-window law in the tree (buvm3–20,
uvm82–95, sd8–12, § `classArgBind12/28/52/57/64`, `collArgNamedBlkLocalNoBind15`,
`newArrayArgNoBind16`, `foreachElabLoopVarAnyKindBinds17`,
`pkgParamBareTdNamedClone18`, `foreachArraySelfSelectAssignDropsTs19`,
`pkgClassOobRetNameBareClone20`) is untouched by the other 3006 arms.

## 4. THE VERIFIED PATCH'S OWN GATES (all green)

1. build both, md5s (above); binaries frozen `chmod 555` at `/tmp/vbuvm21_bin/`.
2. goldens **23 PASS / 0 FAIL** (fixed), `SLANG_UHDM=/bin/false` → **0/23**.
3. u2r testflags vs committed `gate_uhdm2rtlil.csv`: **PASS, 0 differing rows**
   (679/50/2); testflags AND default vs the pristine sweep: **PASS, 0 rows**.
4. surelog `--mode both` vs committed `results/golden_surelog.csv`: **PASS, 0
   differing rows over 1588**; vs the pristine sweep: **PASS, 0 rows**.
   **NO ROW CONVERTED — nothing to promote.**
5. byteverify `SELFCHECK=1`: surelog **`MOVERS 9/956`** (the same nine the pass
   predicted by name, all already `CMP_NOTEQUAL`), u2r **`MOVERS 0/1358`**,
   `PATH_SETS_IDENTICAL`; fixed-vs-shipped **`MOVERS 1/956`** = Scoreboard/default,
   ORDER-BLIND diff **0 lines** → the coin, not a mover.
* canaries `ok=52 changed=0` / `ok=8 changed=0`; `ctcan2` PASS both; `canaudit`
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`; protected DBs unchanged.
* heads: 12 measured, 1 head each; only `BuildUVMPkg` moved, 29 → 52 lines,
  md5 `f21a1042bba06220ee5c1e4f49ff24f4` — identical to the shipped patch's, so
  **R0 stands as the implementer stated it** (`ref_var` vs `logic_var` on the
  queue-typedef'd return variable of `get_elements`).
* every `cmds.txt` in all six sweep workdirs names exactly ONE binary, audited by
  PATH: 1523 (surelog) / 1458 (u2r) lines per sweep.

## 5. RANKED RESIDUES THIS VERIFICATION FOUND

* **R-A (new, MISS not regression).**  A subroutine local declared in an
  UNNAMED block nested inside a NAMED block: golden BINDS it under `++`
  (`v3operand.sv` `s_nestedloc`, golden `int_var(xl)`), ours stays BARE both
  before and after — `incDecBindSym21` walks out through the unnamed block and
  then refuses at the named one.  Widening it is a one-line change but was left
  alone: it is an under-claim, and no corpus cell exercises it.
* **R-B (pre-existing shape bug, unrelated).**  A LABELLED statement
  (`lbl: a[s]++;`) is wrapped by us in a `named_begin` golden does not emit; the
  arm is `CMP_NOTEQUAL` in the pristine binary already (88 lines) and stays so
  (92) — the law's bind at that site agrees with golden's value.
* **R-C (unmeasurable).**  A `$unit`-scope TASK under a delay/wait: Surelog
  emits no body for `$unit` tasks in the arms tried, so golden says nothing.
  The fixed binary leaves them BARE, consistent with the class-home measurement.
* **R0 unchanged** — the next head is the implementer's `get_elements`
  `ref_var`/`logic_var` (`uvm_pkg.sv:28181`), reproduced here byte-for-byte.

## 6. THE INSTRUMENTS

| file | what it is |
|---|---|
| `vgrid21.sh` | VIEW-GENERAL three-way grid runner (golden / A / B) in the DEFAULT **and** ELAB models; reuses the pass's `r10buvm21cen` + `cen3.py` |
| `vjudge21.sh` | the OFFICIAL judge on one arm, both views, N binaries: `uhdm-cmp` line and head counts, rc per cell |
| `vmin21.sh` | the 16 one-construct arms of § 2 — each EQUAL in the pristine binary, so a regression is convicted by `uhdm-cmp` and not by a census |
| `vbound21.sh` | the wide boundary: every `.sv`/`.v` under a COPY of `tools/probe`, both binaries, fd-3 list, children `</dev/null`, `PROCESSED` asserted, rc per cell, banner/path-normalised dumps |
| `v1carrier.sv` / `v2home.sv` / `v3operand.sv` / `v4timing.sv` | the adversarial arms of § 3 |
