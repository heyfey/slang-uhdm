# r10vearl104 — adversarial verification of r10earl104 (§ `replFoldElabSelRead104`)

**VERDICT: ACCEPT.** No pristine-right → patched-wrong cell was found on any
legal SystemVerilog shape, on any corpus row, or anywhere in the wide boundary.
The production diff is unchanged; `/tmp/r10earl104.verified.patch` is the
implementer's patch plus this directory.

Everything here is **MEASUREMENT ONLY**.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
BASE `4fbf5d0`, branch `auto5h`.  `GOLDEN_DEFER` unset throughout;
`results/*.csv` read only.

---

## 1. What was reproduced, from scratch

Two fresh worktrees at `4fbf5d0`, two independent builds (`-j 2`), and every
number below re-measured on the verifier's own sweeps and controls — nothing
carried forward from the implementer's write-up.

* pristine binary md5 **`3002e867e7137c2e5b2e2236d846dc2f`**
* patched  binary md5 **`03e245f8108782c43b9605b3c3593d80`**

Both match the implementer's reported md5s **bit for bit**, so every downstream
number is being checked against the same two artefacts the pass measured.
Both binaries were frozen (`chmod 555`) before any sweep, `SLANG_UHDM` was
exported explicitly per binary, and all 6070 `cmds.txt` files were audited by
binary PATH: **0 name the main-tree binary** and 0 name either worktree build.

`GATES.r10vearl104.txt` carries the full gate table.  Every headline number of
the pass reproduced exactly, including:

| | verifier |
|---|---|
| goldens on each binary / negative control | 23/0, 23/0 / 0/23 |
| surelog 1588 rows, three baselines | ct8rows **PASS**, 0 differing rows, **no row converts** |
| u2r testflags + default | ct8rows **PASS**, 0 differing rows |
| surelog `byteverify SELFCHECK=1` | **MOVERS 2 / 956**, PATH_SETS_IDENTICAL |
| u2r `byteverify SELFCHECK=1` | **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL |
| attribution | **15 changed dump lines per mode**, one BODY hunk each |
| heads | Earlgrey default 34/1 → **31/1**, testflags 34/1 → **50/1**, head object gone in both; every other row unchanged |
| canaries / ctcan2 / canaudit | ok=52 & ok=8 changed=0 / PASS both / audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| wide boundary | LISTED=PROCESSED=**4686**, DIFFERING=62, rc symmetric A/B, FENCED=0 |

The two movers are the two databases the pass predicted BY NAME and nothing
else — `./default/Earlgrey_0_1  5b86d1db45c6 <- 2ea0cb924f32` and
`./testflags/Earlgrey_0_1  57e778aad5aa <- 2b5e58514535`.  A standalone re-run
of the Earlgrey command line outside the harness reproduces both hashes, so the
row is byte-deterministic per binary as claimed.

---

## 2. The instrument is independent

The pass scores its cells with `cen104.cpp`, a C++ census over
`Serializer::AllObjects`.  This verification does **not** use it.  `pacen.py`
reads the `uhdm-dump` TEXT of both databases, sections it at `|uhdmtopModules:`
(DEF / ELAB) and at `_weaklyReferenced:`, and for every `param_assign` records

* the key `(view, Lhs VpiFullName, param_assign line:col)` — no file (ours is
  empty and `param_assign::Compare` never reads it), and the view IS in the key
  because both views hold a `param_assign` at the same span;
* a payload rendered as a **STRING**: the Rhs node KIND, the whole typespec
  chain (kind, loc-less-or-span, name, signedness, every range bound, the
  `vpiActual` target) and the Rhs constant's own encoding
  (`BIN`/`UINT`, `vpiSize`, `vpiConstType`, `vpiDecompile`).

`v104score.py` is a multiset-free three-way join that **refuses to score unless
the GOLDEN side is byte-identical between the two runs** and reports on three
projections: `full`, `ts` (typespec only) and `enc` (constant encoding only).
Separating those columns matters — see §4.

---

## 3. Breaking the law: the read-class faces

Seven new arms, ~420 cells, built to hit the positions neither
`paramCaFoldRead` (AST) nor `replFoldElabSelRead104` (syntax) enters.  Widths
{1, 4, 32} × declared types (`logic [W-1:0]` / `bit [W-1:0]` / a typedef) ×
homes (top module / submodule / interface / generate scope) × read faces
(none / one bare read / one select read) is `w5_cross104.sv`'s 108 cells alone.

**`w1_hier104.sv` closes the biggest suspected hole by language rule.** The
enumeration walks only the parameter's HOME declaration, so a hierarchical
`u_child.X[0]` written in the PARENT is invisible to it.  Six such positions
were built — a net declared range, another parameter's initializer, an instance
array dimension, a loop-generate stop expression, a generate-if condition and a
parameter-override actual — and **slang rejects all six**: *"reference to 'X' by
hierarchical name is not allowed in a constant expression"*.  The only legal
hierarchical select read is in a non-constant context, which is the pass's own
`va2.h1`, where golden **keeps** the mint.  The face is closed.

**Every golden verdict was reproduced.**  Across all seven arms there is not one
cell where golden holds the declared `logic_typespec` and the patched binary
mints the `int_typespec`.  Named faces and their measured answers:

| face | golden | patched | note |
|---|---|---|---|
| no read at all, width 4 / 32 | MINT | MINT | win |
| one bare read (net range) | MINT | MINT | win |
| one select read (net range) at width 4 / 32 | DECL | DECL | blocked, correct |
| the same select on a `bit [W-1:0]` | DECL | DECL | blocked |
| the same select on a **typedef**-declared parameter | DECL | DECL | blocked |
| a **port** parameter `#(parameter logic [3:0] X = {4{1'b1}})`, no read | MINT | MINT | win |
| the same port parameter with a select read | DECL | DECL | blocked |
| a select as **another select's index**, `logic [Y[X[0]]:0]` | DECL | DECL | blocked |
| a **part select** `X[1:0]` / an indexed part select `X[0+:2]` | DECL | DECL | blocked |
| a **bare AND a select** read of one parameter | DECL | DECL | blocked |
| a select in a procedural block / function / task / `final` block | MINT | MINT | win |
| a select in a **concurrent assertion** and in an `assert property` | MINT | MINT | win |
| a select in a **covergroup coverpoint** / a `property` declaration | MINT | MINT | win |
| a select in a variable declaration **inside** an `initial` block | MINT | MINT | win |
| `$bits(X)` only, **inside a generate scope** | MINT | MINT | win |
| a select read through an **interface port** (`i.XP4[0]`) | MINT | MINT | win |
| a select read inside the interface that owns it | DECL | DECL | blocked |
| an **imported** package parameter with a select read | unchanged | unchanged | `!isImported` fence holds |
| a **package** parameter | unchanged | unchanged | `!inPackage` fence holds |
| a parameter homed in a **generate scope** | golden has NO typespec; ours has none either, on both binaries | untouched | earl55 R6, out of this branch |
| **width 1**, all 36 cells of `w5` plus `w3.s10/s11` | MINT | MINT | earl55's cells stay |
| a **shadowed** name (`X[0]` selecting a same-named net in a gen block) | DECL | DECL | golden is text-blind here too |
| a 2000-term left-nested expression + a 400-term select chain | — | rc 0 both | no new recursion cliff (§5) |

`GRID.r10vearl104.txt` carries the scores.  On the verifier's own arms:
**AWAY-GOLDEN 0, MOVED-WRONG 0** (typespec projection), TO-GOLDEN 56.

**The two must-stay-EQUAL controls hold.**  `vb2_genfor` **0 cmp lines / 0
heads → 0 / 0** and `vb4_instarr` **0 / 0 → 0 / 0** — the two
`CMP_EQUAL` → `CMP_NOTEQUAL` convictions that sank r10earl103 stay EQUAL, and
neither appears in the wide boundary's differing list.  No arm anywhere in the
boundary went from 0 cmp lines to a head.

**Re-scored with the independent instrument:** the pass's own 16 arms
AWAY 0 / MOVED-WRONG 0 / TO-GOLDEN 74; earl55's thirteen arms AWAY 0 /
MOVED-WRONG 0 / TO-GOLDEN 46.  earl102's, uvm159's and the two scan
precedents' (`r10earl49repro`, `r10earl50repro`) arms are absent from the
boundary's differing list, i.e. byte-identical.

---

## 4. Why "MOVED-WRONG" appears in the `full` column and is not a regression

Three groups show a non-zero MOVED-WRONG on the FULL payload and **zero** on
the typespec projection.  Each was opened and named:

* `w3.u_s1` (`logic [1:0][3:0] X = {8{1'b1}}`) and `v7_v55.u_t1.BS` — the
  typespec moves **TO** golden; what still differs is `vpiDecompile`
  (`8'b11111111` vs golden's `11111111`), identical on BOTH binaries and
  untouched by this pass.
* `g3_anc86` (3 cells), `vaB_tern86` (2), `va5_ctx85` (1) — **the judge cannot
  reach the typespec here.**  In all six, golden's Rhs is an unfolded
  `operation` (op34) and ours is a `constant`, on both binaries.  Read from
  `UHDM/build/generated/src/param_assign.cpp:112`, `SafeCompare(lhs->Rhs(),
  rhs->Rhs(), …)` runs before the Lhs and before anything inside the constant,
  and `BaseClass::Compare` fails on `VpiType` (`vpiOperation` vs
  `vpiConstant`) first.  These are the recorded over-folds of
  § `srlgUnsizedBasedShiftBail85` and earl86's ternary-bail family.
* `va6_unbased85.z08` (`{4{'1}}`) — golden's typespec is a loc-less
  `int_typespec` too, so this cell moves **TO** golden on the typespec; only
  the judge-invisible `VpiValue` and the constant's pre-existing `VpiSize`
  still differ.

**The judge settles it directly.**  On all six non-pass boundary arms the
official `uhdm-cmp`'s ENTIRE output — the stdout body AND the stderr head — is
**byte-identical** between the pristine and the patched binary.  `g22` and
`l154_noenum` are uvm154's address-layout stamp with every changed line BELOW
the `_weaklyReferenced` marker (5118 vs 4356, 8095 vs 6471, 678 vs 645, 714 vs
646), which RESUME.md §9 says the judge cannot reach.

Among cells the judge can reach, **AWAY-GOLDEN 0 and MOVED-WRONG 0**, on both
corpora and on every arm.

---

## 5. Findings the verifier adds

Four **new forgone-win classes** (over-blocks — each cell keeps exactly what
pristine emitted, so none is a regression), not in the pass's list of four:

1. **A select on a MULTI-DIMENSIONAL packed parameter** — `logic [1:0][3:0] X`
   read as `X[0][0]`: golden KEEPS the mint, the syntax walk blocks
   (`w3.u_s2`).  The `logic [1:0][3:0]` cell with no read is a WIN (`w3.u_s1`),
   so the shape itself is in scope; only the select is over-blocked.
2. **A select inside a CLASS declared in the module** — a class PROPERTY's
   declared range `logic [X[0]:0] p;`: golden keeps the mint, the walk blocks
   because `ClassDeclaration` is not one of `srlgNoFoldCtx104`'s excluded
   contexts (`w4.u_q3`).  A select inside a class METHOD body is correctly
   excluded and wins (`w4.u_q4`).
3. **A select inside a NESTED MODULE declaration's body** — this one is caused
   by the shape of the lookup itself.  `replFoldElabSelRead104` walks the
   parent chain and keeps reassigning `decl`, so it lands on the **OUTERMOST**
   enclosing `ModuleDeclaration`, not the innermost; a nested module's select
   is therefore harvested against the outer module's parameter (`w6.u_r9`).
   Conservative in the safe direction, and the enumeration would be strictly
   better with `break` on the first match — but only if that were measured, and
   this is a win-count question, not a correctness one.
4. **A select in a plain module-body cont-assign whose RHS is a wide operand
   chain** — `assign wsel = D[0]^D[1]^…` : golden KEEPS the mint
   (`w7.u_w7.D`), so the pass's "a select in a cont-assign takes it away" is
   narrower than the arm table reads.  Same class as the pass's own recorded
   "non-constant cont-assign" residue.

One **latent hazard**, no observed effect (ranked below):
`const bool replRead104 = paramCaFoldRead(ps) || replFoldElabSelRead104(ps);`
is evaluated **before** the `topView && !inPackage` guard, so
`paramCaFoldRead` — which forces AST binding on child instance bodies
(`getInitializer()`, `ci.body.members()`, port connections) — is now invoked in
the **DEF** view and for package/imported parameters, where this call site
never invoked it before.  RESUME.md §9 records the DEF-phase AST-forcing
Heisenbug.  Measured consequence: **none** — 4686 boundary files in both views
show only the 31 arms the typespec law explains, 2314 corpus databases show
2 movers with 15 attributed lines each, and Earlgrey's runtime is unchanged
(3 s vs 3–4 s).  No fix is warranted on measurement; folding the two calls
inside the guard would remove the hazard for free if the law is ever touched
again.

**No slang patch, no `results/*.csv` edit, no `git stash`, no shared-control
read, no fenced test dispatched** — verified on the patch surface and on this
directory.

---

## 6. Ranked residues

* **R0 (unchanged, confirmed).**  Earlgrey testflags: at `pinmux.sv:176` golden
  SUBSTITUTES the folded constant (id 640534, carrying the very `int_typespec`
  this pass started emitting) into the concatenation operand where we emit a
  `ref_obj` to `gen_mio_out[0].MioPeriphHasSleepMode`.  The head log is quoted
  in `GATES.r10vearl104.txt`.  Earlgrey default: `LHS: <null>` on
  `u_pinmux.gen_mio_periph_in[0].data_mux` at `pinmux.sv:157` — a `logic_var`
  we emit and golden does not, PRE-EXISTING (the attribution shows its subtree
  byte-identical between the binaries).
* **R1.**  The over-folds under `g3_anc86` / `vaB_tern86` / `va5_ctx85`: golden
  keeps an unfolded `operation` where we emit a `constant`, on both binaries.
  Until that is fixed everything under those Rhs cells is judge-unreachable.
* **R2.**  The pass's four forgone-win classes plus the four in §5 above.  Each
  needs a discriminator the syntax walk does not have (module-level vs
  gen-scope parameter initializer; whether a cont-assign reduces; whether a
  generate branch is instantiated; a struct member range's scope; a multi-dim
  select; a class body; the innermost vs outermost module).
* **R3.**  The `replRead104` evaluation order of §5.
* **R4.**  `va6_unbased85.z08` still disagrees on the judge-invisible
  `VpiValue` (`UINT:-1` vs `UINT:1`) and on the constant's `VpiSize`.

---

## 7. Files

| file | what it is |
|---|---|
| `pacen.py` | the independent `param_assign` typespec census, read off `uhdm-dump` text |
| `v104score.py` | the three-way join; refuses to score unless the golden side is identical; `PROJ=full/ts/enc` |
| `v104grid.sh` | per-arm golden + ours build, official `uhdm-cmp` lines/heads, both censuses |
| `v104wide.sh` | the verifier's wide boundary (fd-3 list, `</dev/null` children, LISTED asserted, rc by side) |
| `w1_hier104.sv` | six hierarchical select positions — **slang rejects all six**; the face is closed by the LRM, not by the law |
| `w2_ifport104.sv` | interface-port and cross-instance select reads |
| `w3_shape104.sv` | declared shapes the grid did not cross: multi-dim packed, port parameter, operand width 2, typedef, `bit`, width 1 |
| `w4_pos104.sv` | eleven read POSITIONS: another select's index, class property range, class method body, `final`, split generate arms, gen-scope `$bits`, covergroup, `property`, three-reader mixtures |
| `w5_cross104.sv` + `gen_w5.py` | widths {1,4,32} × types {logic, bit, typedef} × homes {top, submodule, interface, gen scope} × reads {none, bare, select} = 108 cells |
| `w6_more104.sv` | program home, modport-ported interface, a shadowed name, `assert property`, an `initial`-block local's range, a NESTED module, part select and indexed part select |
| `w7_depth104.sv` | syntax-walk depth stress (2000-term expression, 400-term select chain) |
| `GRID.r10vearl104.txt` | the four score groups on three projections, the per-arm judge table, every MOVED-WRONG and STILL-WRONG cell |
| `BOUNDARY.r10vearl104.txt` + `BOUNDARY_WIDE.*` | the wide boundary, its rc symmetry, and the attribution of all six non-pass arms |
| `ATTRIB.r10vearl104.txt` | the whole-dump diff of the only two databases that moved |
| `GATES.r10vearl104.txt` | every gate, re-measured |
