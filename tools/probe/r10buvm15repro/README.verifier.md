# r10buvm15 — ADVERSARIAL VERIFICATION, and one PRODUCTION FIX

**VERDICT: ACCEPT WITH A FIX.**  Every headline number in the implementer's
report reproduced BIT-FOR-BIT on binaries I built myself.  The law is right and
its corpus reach is exactly what was claimed.  Breaking it found **one symbol
class it over-fires on** — a local declared in a **NAMED statement block** — in
**4 cells over 2 arms**, all `PRISTINE-RIGHT -> PATCHED-WRONG on legal SV`.
§ `collArgNamedBlkLocalNoBind15` fixes it; the fix is **corpus-null** and the
full battery was re-run on the fixed binary.

| | |
|---|---|
| BASE | `07e10c5`, worktrees `/tmp/wt_vbuvm15` (patched+fix) and `/tmp/wt_vbuvm15pris` |
| pristine md5 | `3c8e1854c5bf883d0c654e04d0d01725` — **the implementer's number, hit exactly** |
| patched-as-shipped md5 | `63c283b1f9e48c408bb7d9d6fa31f3b8` — **hit exactly** |
| VERIFIED (patch + fix) md5 | `5ff5bf1e4f6c9ce8e21be50a885db41c` |
| deliverable | `/tmp/r10buvm15.verified.patch`, applies clean on a FRESH `07e10c5` |
| surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` + `tools/probe/r10buvm15repro/` ONLY |

`results/*.csv` were **READ ONLY**.  slang was **not** patched.  `GOLDEN_DEFER`
stayed **UNSET** and is echoed by every sweep.  **NO ROW CONVERTED** on either
corpus: `BuildUVMPkg` still reads `CMP_NOTEQUAL` in both modes.

## 1. WHAT BROKE — § `collArgNamedBlkLocalNoBind15`

`v5_named15.sv` is the discriminator arm.  Cell -> `golden / pristine / patched`:

| cell | written | G | P | Q(shipped) | Q(fixed) |
|---|---|---|---|---|---|
| **n20** | `nb15: begin int nloc; mkn15.one(nloc); end` — COLLAPSED | **BARE** | BARE | **BOUND** | BARE |
| **n31** | the same NAMED-block local read from an inner UNNAMED `begin` | **BARE** | BARE | **BOUND** | BARE |
| **n27** | `mkn15.one(sink2(nloc));` — a NESTED ordinary call inside the collapsed window | **BARE** | BARE | **BOUND** | BARE |
| **s34** (`v2_shadow15.sv`) | the same shape in a second body | **BARE** | BARE | **BOUND** | BARE |
| n10 / n30 | an UNNAMED-block local, same depths, same window | int_var | BARE | int_var | int_var |
| n23 | a FORMAL inside the named block | io_decl | BARE | io_decl | io_decl |
| n25 | a BODY local inside the named block | int_var | BARE | int_var | int_var |
| n40 / n41 | the same named block in an OUT-OF-BODY method | int_var | = G | = G | = G |
| **n50 / n51** | the same named block in a **PACKAGE** function | **int_var / io_decl** | = G | = G | = G |
| n21 / n22 / n33 | the same local through an ORDINARY call / method call | **BARE** | **BOUND** | BOUND | BOUND (**R1**, pre-existing) |

**THE PRODUCER SAYS WHY.**  `CompileHelper::bindVariable` walks the pexpr's
`VpiParent` chain and only ever inspects `uhdmbegin` / `uhdmfunction` /
`uhdmtask` scopes.  A NAMED block serializes as `uhdmnamed_begin`, so its locals
are never found while the enclosing function's formals and body locals still
are — which is exactly n20/n23/n25/n31.  `blkLocalSameCtrlDepth57` already
encodes the identical exclusion (`!declSym.name.empty() -> refuse`) for
§ `controlBodyNoBind28`'s carve-out; the § `classArgBind12` window never had it.

**THE FIX** adds one counter (`collArgBindDepth15`, raised alongside
`ClassArgBind12` at both § 69 sites) and one disjunct of the bind gate.  Each of
its three guards is a MEASURED cell, not a hedge: `collArgBindDepth15 > 0`
because n50 shows a PACKAGE function binds the same shape and n21/n33 are a
separate PRE-EXISTING residue this pass must not move; the class guard because
n40 shows an OUT-OF-BODY method binds it; the NAME test because n10/n30 show an
UNNAMED block's local, in the same window at the same depths, DOES bind.

## 2. EVERY HEADLINE NUMBER, REPRODUCED

| claim | measured here |
|---|---|
| pristine / patched md5 | **identical to the report** |
| patch applies clean on fresh `07e10c5` | yes; the implementer's built `src/ExprEmit.cpp` is byte-identical to the patch's |
| goldens 23/0, `/bin/false` 0/23 | pristine 23/0, shipped 23/0, **fixed 23/0**, `/bin/false` **0/23** |
| u2r `--mode both` 679 / 50 / 2 | exact, both modes, all three binaries |
| u2r 0 differing ROWS | shipped **0**, fixed **0** (vs the pristine sweep taken first here) |
| surelog 0 differing ROWS over 1588 | the PRISTINE sweep is **byte-identical to the committed `results/golden_surelog.csv`** (0 rows), and so are shipped and fixed |
| byteverify 9 / 956 surelog | **exactly those 9 paths**, and they are exactly the 9 my OWN prediction named first |
| byteverify 0 / 1358 u2r | **0**, shipped and fixed |
| SELFCHECK / SELFCHECK1 | 955/956 and **10** (= 9 movers + 1 corruption) |
| BuildUVMPkg 29 -> 31 cmp lines, 1 head, both modes | exact |
| cmp-log md5 `26e8f870afc4` -> `faea62de3d4b` | **exact** |
| the other ten head-set cmp logs byte-identical between binaries | exact |
| collapsed census 15 DISAGREE -> 0, 167 -> 182 agree | **exact, on an INDEPENDENT deeper census** |
| u2r census: ZERO predicted | **0 disagreements over 1358 databases** |
| canaudit 29 / UNCOVERED=0 / FENCE-BREACH=0 | exact |
| canaries ok=52 (surelog) / ok=16 (u2r), changed=0 | exact, shipped AND fixed |
| ctcan2 ok=58 / ok=2, changed=0 | exact, shipped AND fixed |
| `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | **hit exactly**, all three binaries |
| InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical | exact |
| determinism 1 distinct hash | 3 runs on `a1_collargs15.sv` and 3 on the BuildUVMPkg input |
| the pre-existing u2r baseline drift | **CONFIRMED**: on the PRISTINE binary, `ParameterSizeOfInstance` and `paramod_genscope_child` read dump `differ` in the committed CSV and `match` fresh, plus the `detail` column's absolute-vs-relative path spelling on `SLANG_REJECT` rows.  Nothing else. |

**HEAD DECODE, re-read from MY OWN pristine log, not from the brief.**
`BuildUVMPkg.default.cmp` line 29 really is `RHS: <null>` and the LHS really is
`io_decl: (lhs) … < function: (uvm_pkg::uvm_cause_effect_link::get_link)` at
`23219:62` — the singular `SafeCompare`'s `lhs!=null && rhs==null` arm, whose
`m_failedLhs` is the VALUE.  The patched head really is the mirror,
`LHS: <null>` / `int_var: (uvm_pkg::uvm_packer::get_packed_bytes::sz)`.  **R0 is
not a regression**: the whole-dump pristine->patched diff for BuildUVMPkg is
**14 lines and every one of them is an `io_decl` `vpiActual`** — the `sz`
actual under `method_func_call: (new)` is byte-identical on both sides.

**THE CENSUS BLIND SPOT, CLOSED.**  `r10buvm15cen` reads only a `tf_call`'s
DIRECT `ref_obj` arguments, so a ref nested inside an OPERATION, a CONCAT, a
SELECT or a nested call is invisible to it — and `v1_homes15.sv` cell v16
(`vmk15.one(f1 + loc15)`) proves such refs DO move.  `r10buvm15cen2.cpp` walks
the WHOLE argument subtree of every `tf_call` in a subroutine body.  Run over
the same 956 pristine databases it reproduces **15 / 167 / 26** and names the
same **9** movers, so the shipped prediction was not lucky.

## 3. THE BOUNDARY GATE — EVERY ARM IN THE TREE

`vbndsub15.sh` (buvm13's fd-3 driver) over **all 2534 `.sv` arms under
`tools/probe/`**, pristine vs the FIXED binary:

```
-- arms PROCESSED=2534 IDENTICAL=2406 MOVED=4 REJECT-BOTH=124 ONE-SIDE=0
r10buvm15repro_a1_collargs15     MOVED  heads 1->0  cmplines 29 -> 0
r10buvm15repro_a2_collbuiltin15  MOVED  heads 1->1  cmplines 547 -> 547
r10uvm69repro_a2_scope           MOVED  heads 1->1  cmplines 29 -> 22
r10uvm69repro_v1_gaps            MOVED  heads 1->1  cmplines 29 -> 22
```

**Four arms out of 2534, and all four are this law's own subject.**  Every
`r10buvm12repro` / `r10buvm13repro` arm (§ `classArgBind12`,
§ `formalDefaultBindsLikeBody13`, § `classArgBind12`'s clone fence), every
`uvm82..90`, every `sd8..12` grid and every other pass's arm is BYTE-IDENTICAL.
`ONE-SIDE=0` — the patch rejects nothing pristine accepted.  The two § 69 arms
that move do so ONLY toward golden (`vrefgrid15.py`: 2 and 3 CONVERTED cells, 0
OVER-FIRE).

## 4. WHERE THE LAW WAS BROKEN AND HELD

`v1_homes15` `v2_shadow15` `v3_clones15` `v4_builtin15` `v5_named15`
`v6_more15` `v7_named_assoc15`, measured with `varm15.sh` + `vrefgrid15.py`
(which sees EVERY `ref_obj`, including operands, and therefore sees cells the
call-level grid cannot).

**HOMES:** in-body, `static` in-body, `virtual` in-body, `automatic`, out-of-body,
package function, MODULE function, `$unit` function, `$unit` CLASS method, and
the clone fence (WILDCARD import / EXPLICIT import / fully QUALIFIED, three
modules over one package class — `v3_clones15` goes to **0 heads / 0 cmp lines**
on the patched binary).  A TASK method cannot be the subject: slang rejects
`function`->`task` invocation, so § 69 can never reach one.

**ARGUMENTS:** formals, body locals, unnamed-block locals, NAMED-block locals,
class properties, class STATIC properties, package variables, enum constants,
parameters, `this.<prop>`, `super.<prop>`, string literals, `null`, struct
members, array elements, a ref used as a SELECT INDEX, OPERATION operands,
CONCAT operands, nested calls (and the nested call's own arguments), a nested
call ON the return variable, OUTPUT formals, REF formals, a DEFAULTED formal
left unwritten, full/partial/out-of-order NAMED association, a formal SHADOWING
a package variable, a block local SHADOWING a formal, and recursion.

**DEPTHS:** top level, `if`-begin, `else`-begin, `for`, `while`, `do..while`,
`foreach`, `forever`, `fork..join_none`, `case` arm, `case default`, named block,
and a named block with an unnamed block nested inside it.

Totals, shipped -> fixed: `v2` `OVER-FIRE=1 -> 0`, `v5` `OVER-FIRE=3 -> 0`, and
**every other cell on every other arm is unchanged** — the fix moves exactly the
four cells it was written for and nothing else.

## 5. RANKED RESIDUES (measured, not touched)

1. **R1 — the SAME defect in the ORDINARY § `classArgBind12` window.**  A
   NAMED-block local passed to an uncollapsed user call or method call inside an
   in-body class method is golden **BARE** and **already BOUND on the PRISTINE
   binary** (`v5` n21 / n22 / n33).  This is NOT this pass's and my fix
   deliberately does not reach it (`collArgBindDepth15 == 0` there) — widening
   the gate would move cells no arm in this campaign has measured.  It is the
   highest-value follow-up: the shape is identical, the producer law is already
   decoded, and `v5_named15.sv` is the arm.
2. **R2 — `$unit`-scope subroutines.**  `v1` u10 / u11: golden BINDS a collapsed
   call's formal and body local inside a `$unit` function; both binaries leave
   them BARE, because `unitSubNoBind9` is a separate disjunct the window does
   not lift.  Corpus population **0** (no `$unit` collapsed call disagrees in the
   census).
3. **R3 — NAMED-ASSOCIATION arguments of a collapsed call.**  Golden emits
   `constant 0` SLOT objects (§ `namedTfArgsFormalSlots4`'s shape) where we emit
   `ref_obj`s; § 4 does not reach the § 69 arms.  `v7` y10-y13: six refs golden
   does not have at all, which the patch now also gives `vpiActual`s.  The head
   is the SAME `constant` object before and after, so this deepens a pre-existing
   residue rather than creating one.
4. **R4 — SITE 2 was measured against an ERROR-PATH golden.**
   `a2_collbuiltin15.sv`'s four class-method cells make Surelog print
   `[ERR:CP0332] Function "push_back" is not defined for variable "mkq15" of
   type iq15`.  A queue-typed return variable cannot avoid it.  `v4_builtin15.sv`
   uses a **`string`** return and `.itoa(...)` — UVM's own `index_string.itoa`
   shape — parses with **0 errors**, and reproduces SITE 2's conversions (7
   cells) plus its out-of-body and package controls.  SITE 2 remains
   **corpus-null**: all 15 corpus rows go through SITE 1.
5. **R5 — `this.<prop>` / `super.<prop>` as a collapsed-call argument.**  Golden
   builds a `hier_path` with two `ref_obj` actuals; we build one flat `ref_obj`.
   Pre-existing on both binaries (`v1` v12/v13, `v4` b15/b16) and it is the arm's
   own head once this law's cells are cleared.
6. **R6 — the Scoreboard ORDER COIN is real and was attributed order-blind.**
   Fixed vs shipped byteverify reports 1 mover, `default/Scoreboard`; its
   path-normalised dump diff is **92 raw sides and 0 SORTED sides**.  The fix is
   therefore **corpus-null**.  (Pristine vs shipped, in my run, was 2 raw and 2
   sorted — the same two predicted `l_sequencer` lines, coin unflipped.)

## 6. FILES ADDED BY THE VERIFIER

| file | what |
|---|---|
| `v1_homes15.sv` … `v7_named_assoc15.sv` | the seven break-it arms |
| `vrefgrid15.py` / `varm15.sh` | per-`ref_obj` three-way golden/pristine/patched table (sees operands) |
| `r10buvm15cen2.cpp` / `vpred15.sh` / `vpredjoin15.py` | the DEEP census + independent mover prediction |
| `vbndsub15.sh` | fd-3 boundary gate (all 2534 probe arms) |
| `vbyteverify15.sh` / `vdumpdiff15.sh` | mover set + path-normalised, order-blind attribution |
| `vsweeps15.sh` | sweep driver with its own out/workdir and a cmds.txt binary audit |
