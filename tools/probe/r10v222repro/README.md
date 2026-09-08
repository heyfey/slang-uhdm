# r10v222 — adversarial verification of r10uvm222 (§ ifaceOwnCallCalleeFormRoutes222)

**VERDICT: ACCEPT WITH FIX.** The law is right, the decode is right, and every
headline number reproduces bit-for-bit on binaries built here from
`/tmp/r10uvm222.patch` on a fresh `db069bdf`. The *implementation* of the law
was one character too wide: it cut the call's raw text at the **first** `(`,
and a receiver may legally carry a `(` of its own. Two spellings that compile
rc 0 on **both** tools, and that golden renders as `method_func_call`, became
`func_call` under the patch as delivered — **pristine-right → patched-wrong**.
Fixed here, minimally, inside the same arm; the fix is gated in full and ships
as `/tmp/r10uvm222.verified.patch`.

---

## 1. WHAT REPRODUCED, BIT-FOR-BIT

Two fresh worktrees at `db069bdf`, two independent builds, binaries frozen
`chmod 555` before any sweep, `SLANG_UHDM` exported per binary and every
`cmds.txt` audited by PATH.

| claim | measured here |
|---|---|
| pristine binary = the base | md5 `769b69341dc3d59dab592c3fa80c4983`, **byte-identical to the main-tree build at `db069bdf`** |
| patched binary | md5 `aef5fdd9b78211185175dd251e9378f2` — **the implementer's value exactly** |
| head before | MiniAmiq ×2, **152 lines / 1 head**, the two logs byte-identical to each other, to the implementer's `head_pris_MiniAmiq.*.cmp` **and** to `r10uvm221repro/head_pat_MiniAmiq.default.cmp` |
| head after | MiniAmiq ×2, **1 388 494 / 1**, first 220 lines byte-identical to `head_pat_MiniAmiq.*.head220.cmp`; the new head is `interface_inst: work@svaunit_vpi_interface` on its net list |
| every other row at base | SeqDriver ×2, SimpleUVM ×2, Scoreboard/def, BuildUVMPkg ×2, Earlgrey_0_1 ×2, Rggen/def — **0 lines / 0 heads / cmp rc 0** on both binaries |
| golden grid | a1 28/44 → **0/0**, a4 8/12 → **0/0**, a2 20/20 → **10/10**, a3 31/31 → **3/3**, a5 11/11 unchanged, a6 slang rc 3 — **every number** |
| a-priori population | u2r **1358 databases → 0 hits, 0 cells**; surelog **956 → exactly 2 row-modes, 7 cells each**, MiniAmiq default + testflags, read from *pristine* databases |
| movers | u2r byteverify **0 / 1358**; surelog **2 / 956**, the two predicted, patched hash `f4fdf6830862` |
| MiniAmiq census | 44 added / 70 removed; vs golden MISSING 260 558 → **260 521**, EXTRA 96 711 → **96 648**; newly-appearing MISSING **7** (all `\|vpiParent:` filler), newly-appearing EXTRA **0** |
| wide boundary | LISTED = PROCESSED = **5541**, RC_DIFFS **0**, MOVED **24** — *the same twenty-four arms and views*, and the seven re-judged arms read **TOWARD-GOLDEN 14/14, AWAY 0** |
| must-stay floor | uvm216 **0** of 6 arms, uvm220 **0** of 6, uvm221 **0** of 5, uvm218 **1** of 5 (`grid218/a5_sibling`, its own R1); `a2_window` did not move |
| pins | `InterfaceModPort` `59a365f3ce2c` SAME both modes, `BlackParrotComplex`, `YosysOldOr` SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` |

The `Earlgrey_0_1` blank-dump row is **confirmed as an artefact, from the other
side**: here it lands on `default` (not `testflags`) and it appears on the
**pristine** binary as well as the patched one — the CSVs of the two sweeps are
byte-identical to each other. That database is 50.9 MB and `uhdm-dump` takes
**50 s on an idle machine** against the harness's 180 s timeout; re-measured
alone the row reads `CMP_EQUAL,,,differ` in both modes. `verify_golden.py`
:633-635 swallows `TimeoutExpired` and leaves the dump column empty. The status
column never moved. **Not a mover, and provably not the patch's.**

Full numbers: `GATES.v222.txt`.

---

## 2. THE BREAK — a `(` that belongs to the RECEIVER

The arm is reached for every call whose callee is declared in an interface,
and the delivered patch decides the call's kind from

```
std::string callee222 = raw1.substr(0, raw1.find('('));   // the FIRST '('
auto dot1 = callee222.find_last_of('.');
```

`raw1` is the whole call statement. The **first** `(` is the argument list's
only when the receiver holds none. A receiver may legally hold one, and then
the cut lands inside the receiver, the callee's own dot vanishes with it, and
the arm declines — emitting a plain `func_call` at the statement column where
golden emits a `method_func_call` at the method token with a `vpiPrefix`.

Two families, both rc 0 on **both** tools (`arms/v222_paren.sv`,
`arms/v222_escparen.sv`; cells in `BREAK.v222.txt`):

| cell | source | golden | pristine | patch as delivered |
|---|---|---|---|---|
| p01 | `bank22p[(a_i)].poke22p(a_s,1)` | `method_func_call` 30:22, prefix `bank22p` | `method_func_call` **30:22** | `func_call` 30:7, **no prefix** |
| p02 | `bank22p[idx22p(a_i)].poke22p(…)` | `method_func_call` 35:28 | `method_func_call` **35:28** | `func_call` 35:7 |
| p03 | `bank22p[int'(a_i)].poke22p(…)` | `method_func_call` 40:26 | `method_func_call` **40:26** | `func_call` 40:7 |
| p04 | `bank22p[(a_i)].poke22p(o22p.path22p(),4)` | `method_func_call` 45:22 | `method_func_call` 45:35 | `func_call` 45:7 |
| e11 | `\vif(par22e .poke22e(a_s,11)` | `method_func_call` 24:24, prefix `vif(par22e` | `method_func_call` **24:20** | `func_call` 24:7 |
| e12 | `\vif(par22e .poke22e(o22e.path22e(),12)` | `method_func_call` 29:24 | `method_func_call` 29:33 | `func_call` 29:7 |

On p01–p03 the pristine emitter matched golden's **kind and position exactly**;
the patch as delivered loses both. Scored as multisets against golden:
`v222_paren` goes **9/9 → 21/13 AWAY-GOLDEN** in the DEF view and **9/40 →
21/36 AWAY** in ELAB. (`v222_escparen`'s aggregate reads "TOWARD" only because
two differently-wrong records cancel in the count — the KIND is wrong in both
cells; read `BREAK.v222.txt`, not the total.)

Surelog is unambiguous about the target: `CompileHelper.cpp:4216-4241` builds
the `method_func_call` when the name node's sibling is a
`paConstant_bit_select` — **which is exactly what a receiver's subscript
is** — and names the prefix from the FIRST name (`prefix->VpiName(name)`),
which is why golden's prefix is `bank22p` with no subscript.

Neither family is in either corpus (the a-priori census finds zero such cells
outside MiniAmiq), so this is a **latent** regression, not a corpus one — which
is precisely what the wide boundary and the golden grid exist to catch.

---

## 3. THE FIX — cut at the ARGUMENT LIST's paren, not at the first one

`src/ExprEmit.cpp`, inside the same arm, replacing the two lines above: scan
the raw text for the first `(` that is **not inside a select, an escaped
identifier, or a string literal**, and take the last `.` of what precedes it.

* a select — `[` … `]` — is entered and left by depth, so `bank[(i)]`,
  `bank[f(i)]` and `bank[int'(i)]` all hand back the receiver whole;
* an escaped identifier runs from `\` to the next whitespace, so
  `\vif(par .poke(x)` keeps its name;
* a quoted string is skipped, so a select holding `"a]b"` cannot unbalance the
  depth.

Where the receiver holds no `(` — **every corpus cell, every § 176 cell and
every one of § 222's own grid arms** — this reads character-for-character what
`raw1.find('(')` reads. Measured, not argued: on `a1_home`, `a2_qual`,
`a3_holder`, `a4_dpi`, `a5_edge` and on the verifier's own `v222_kinds`, the
fix binary's dumps are **byte-identical to the implementer's patched binary**
(path-normalised diff: 0 lines, all six arms), and on the corpus the MiniAmiq
database hash is the same `f4fdf6830862`.

With the fix, `v222_paren` reads **9/9 → 5/5 TOWARD-GOLDEN** (DEF) and **9/40 →
5/36** (ELAB): golden's kind and position are kept on all four cells *and*
p04's argument-dot bug is cured — the residue that remains is § 176's own R2,
the subscript our prefix name keeps. `v222_escparen` holds its pristine kind
and loses e12's argument-dot bug; what is left is § 222's recorded R4.

---

## 4. THE ROUTING FACES, PROBED ADVERSARIALLY

`arms/v222_kinds.sv` (surelog rc 0, slang rc 0, DEF and ELAB) puts, under one
golden, a bare interface-sibling callee whose argument spells a **class-scope
call** (`obj22k::sfn22k(1)`), a **package-scope call** (`pk22k::pkfn22k(2)`), a
**built-in method call** (`q22k.size()`), a **nested user call whose own
argument is dotted** (`fn22k(o22k.num22k())`), a **plain dotted name**, and a
**`this.`-qualified call**; a built-in method call in statement position
(`q22k.push_back(o22k.num22k())`); a **receiver-qualified interface callee**
reached from a module; and, as controls, the same argument spellings around
callees in a **package**, a **class** and a **module**.

Result: **23/33 → 0/0** — exact agreement with golden on every call record —
identically on the implementer's binary and on the fix, in DEF and in ELAB.
The controls do not move.

`arms/v222_parenrecv.sv` records the one remaining spelling where a `(` could
precede the callee's dot at top level, `(vif).poke(x)`: **Surelog rc 3 and
slang rc 3** — neither tool compiles it, so like § 222's `a6` it is
unreachable, and the rc is the measurement.

Both corpora were probed for the routing fix's width **before** the patched
binary touched a sweep: the implementer's own database-side signature over
1358 pristine u2r databases returns **0 hits / 0 cells**, and `byteverify`
then measured **0 / 1358**. The u2r zero is proven twice, once a priori.

---

## 5. FILES

| file | what |
|---|---|
| `GATES.v222.txt` | every gate number, all three binaries, measured here. |
| `BREAK.v222.txt` | the regression cell by cell: golden / pristine / patch-as-delivered / fix. |
| `GRID.v222.txt` | the adversarial grid, DEF and ELAB, every rc, every cell count. |
| `BOUNDARY.v222.txt` | the wide boundary, pristine vs fix, with these arms installed: LISTED = PROCESSED = 5545, RC_DIFFS 0, MOVED 30 = the implementer's 24 + this verifier's 3 arms × 2 views. |
| `ARMSCORE.v222.txt` | the moved boundary arms re-judged against golden by the official uhdm-cmp and by the order-blind join: TOWARD-GOLDEN 14/14, AWAY 0. |
| `arms/` | `v222_paren.sv`, `v222_escparen.sv` (the break), `v222_kinds.sv` (the routing faces), `v222_parenrecv.sv` (the unreachable spelling). |
| `boundp222.sh` | the wide boundary gate with `bound222.sh`'s contract, dispatched by `xargs -P` — an arm's two runs stay inside one child, PROCESSED is asserted equal to LISTED, children get `</dev/null`, scratch is keyed on the RELATIVE path, every rc recorded. |

---

## 6. RESIDUES, RANKED

* **R0 stands as the implementer wrote it** — MiniAmiq ×2, 1 388 494, one head
  both modes: `interface_inst: work@svaunit_vpi_interface` on its **net list**,
  golden 71 `vpiNet` + 5 `vpiArrayNet` + 1 `vpiProcess` against our five
  declared variables. Verified here from the fix binary's own head log.
  `instance::Compare` reads `Nets()` on the line after `Task_funcs()`, so
  `Array_nets()` and then `Process()` are what a fix there surfaces next.
* **R1 (new, this verifier's) — THE PREFIX NAME IS STILL A RAW TEXT SLICE.**
  Three recorded residues — § 222's R2 (a spaced dot leaves a trailing space),
  R3 (a subscripted receiver keeps its subscript), R4 (an escaped name keeps
  its backslash and trailing space) — plus the four `v222_paren` cells and two
  `v222_escparen` cells measured here are ONE fact: golden names the prefix
  from the **first name of the receiver** (`prefix->VpiName(name)` at
  `CompileHelper.cpp:4234`, where `name = SymName(dollar_or_string)`), while we
  name it from the receiver's whole source text. Reading the name off the
  syntax node instead of the text would close R2, R3, R4 and the five remaining
  `v222_paren` cells at once, and would retire the text scan this pass
  narrowed. That is the next arm in this family.
* **R2 — an escaped receiver's call is four columns early** (`v222_escparen`
  e11: golden 24:24, ours 24:20; § 222's R4 from the other side). The method
  token's position is computed from the text slice's dot, so it inherits every
  residue R1 names.
* **R3 — `(vif).poke(x)` and `get_vif().poke(x)` are unreachable, not
  modelled.** Both tools refuse them today (rc 3). If slang ever accepts
  either, this arm's callee-form read declines it and the shape must be decided
  on measured golden.
