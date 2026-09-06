# r10vearl108 — the ADVERSARIAL VERIFICATION of r10earl108 (§ `ovStructPatNonStructFormal108`)

Everything in this directory is **MEASUREMENT ONLY**.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

**VERDICT: ACCEPT.**  Production surface unchanged — land `/tmp/r10earl108.patch`
as submitted.  This directory adds the verifier's arms and evidence only; there
is no production edit in it.

* BASE `bb2d4f24`.  Verifier worktrees `/tmp/wt_v108` (patched) and
  `/tmp/wt_v108pris` (pristine), both created fresh at `bb2d4f24`; the patch was
  applied with `git apply -3` (clean, 0 conflict markers) and both binaries were
  built here, `-j 2`, then frozen `chmod 555` **before any sweep**.
* Pristine md5 `fd2870e34b3081cb23199acbdfdf838d`, patched
  `b3b43f254fac7ddfd263e87681d097a7` — **both reproduce the implementer's md5s
  exactly**, so the patch really is the artifact every number was measured on.
* All **6070** `cmds.txt` across the four sweeps audited BY BINARY PATH: 5962
  name the intended frozen binary, **0** name the main-tree binary, **0** name a
  worktree `build/`.

---

## 1. Every headline number, re-measured

| gate | implementer | verifier |
|---|---|---|
| goldens (patched) | 23 PASS / 0 FAIL | **23 / 0** |
| goldens `SLANG_UHDM=/bin/false` | 0 / 23 | **0 / 23** |
| u2r testflags | 679 / 50 / 2 | **679 / 50 / 2** (identical pristine and patched, both modes) |
| surelog rows | 1588, 0 differing | **1588 rows, 0 differing ROWS (status AND dump), no row converted** |
| `ct8rows` u2r tf / def | PASS | **PASS** vs committed baseline AND vs own pristine |
| `byteverify` u2r | MOVERS 0 / 1358 | **0 / 1358**, PATH_SETS_IDENTICAL |
| `byteverify` surelog | MOVERS 3 / 956 | **3 / 956**, PATH_SETS_IDENTICAL |
| Earlgrey/testflags head | 122 / 1 → 48 / 1 | **122 / 1 → 48 / 1** |
| every other named head | byte-identical | **byte-identical** (12 head logs; only Earlgrey/testflags differs) |
| canaries | ok=52/0, ok=8/0 | **ok=52 changed=0, ok=8 changed=0** |
| `ctcan2` sl / u2r | PASS / PASS | **PASS / PASS** |
| `canaudit.sh canaries.sh ctcan2.sh` | PASS | **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| SVSwitch / YosysVerx pins | `4842211c4030` / `6ccda350c24a` | **exact**, both modes |
| InterfaceModPort / BlackParrotComplex / YosysOldOr | byte-identical | **byte-identical**, both modes |
| wide boundary | LISTED 4822 PROCESSED 4822 identical 9260 DIFFERING 6 no_output 378 | **identical, and the rc histogram is SYMMETRIC (A_0 8879 = B_0 8879, A_139 16 = B_139 16, A_3 362 = B_3 362, A_4 387 = B_4 387) — ASYMMETRIC=0** |

The three byte movers, attributed by an **order-blind path-normalised whole-dump
diff** (the arbiter, not the ladder):

* `Earlgrey_0_1/default` — **198 lines, two regions, zero unrelated lines**: the
  `param_assign` Rhs swap (`constant 1'b0` → `op75` with the four member
  operands at the `pwrmgr_pkg.sv:47-50` member spans) and the appended
  instance-scoped `struct_typespec pwrmgr_pkg::pwr_ast_rsp_t` clone.
* `Earlgrey_0_1/testflags` — **198 lines, the same two regions, zero unrelated
  lines**.
* `Scoreboard/default` — straight diff 94 lines, **order-blind diff 0 content
  lines** (the only residual line is the dump's own file-path header).  This is
  the documented ~50/50 coin; its head log is byte-identical pristine vs
  patched.

R0 re-decoded on the patched database and it is exactly what `PREDICT_R0.txt`
named: `usbdev_usbif.sv:54` range LEFT bound, golden `constant "6" **sz 32**`
with a `ref_typespec -> int_typespec`, ours `"6" **sz 64**` with **no
typespec** — `expr::Compare` fails at `VpiSize`.

---

## 2. Breaking the law — 13 arms the pass never ran (`gridv108.sh`)

`GRID.r10vearl108.txt` / `SCORE.r10vearl108.txt`.  26 arm × view cells:
**TO_GOLDEN 39, AWAY_GOLDEN 0.**  Not one cell that was RIGHT on the pristine
binary is WRONG on the patched one, anywhere.

**NEW TO-GOLDEN faces the pass understated** (all judged by `uhdm-cmp`, not by
the census):

| arm | face | pristine → patched |
|---|---|---|
| `m_gen108` | a gen-`for` and a gen-`if` instance | 122/1 → **0/0 EQUAL** |
| `m_arr108` | an INSTANCE ARRAY `ma108 #(.R(RSP)) i_a [2:0]` | 122/1 → **0/0 EQUAL** |
| `m_multi108` | three instances of one prim: struct actual + literal actual + no override | 122/1 → **0/0 EQUAL** |
| `m_wide108` | an **80-bit** struct actual at an `int` formal | 106/1 → **0/0 EQUAL** |
| `m_nest108` | a NESTED-struct actual at a `bit` formal | 132/1 → **0/0 EQUAL** |
| `v1_types108` | `shortint`, `shortint unsigned`, `longint`, `longint unsigned`, `time`, `int unsigned`, `byte unsigned`, `bit signed`, `integer signed` formals | 9 cells TO_GOLDEN, 0 AWAY |
| `m_hier108` | a gen-block localparam actual and a `pkg::`-qualified actual | TO_GOLDEN |

`v1_types108` matters most: the admission test is
`PredefinedIntegerType || ScalarType/Bit`, and the pass golden-witnessed only
`bit`/`int`/`integer`/`byte`.  **Every remaining member of the admitted set is
golden-witnessed here**, and the `reg` control (a `ScalarType/Reg`) correctly
declines alongside `logic`.

**Controls that correctly DO NOT fire** (byte-identical to pristine):
`logic` / `reg` / `logic [0:0]` / `logic [2:0]` / `logic [6:0]` / `bit [6:0]`
formals; a `defparam` override (`m_defp108`); an int-literal, an expression and
a plain-`int`-param actual; a parent struct formal overridden by a bare package
reference (`m_par2108`); and — measured, not reasoned —
**`--disable-feature=parametersubstitution`**, where the patched and pristine
dumps of the moving shape are **BYTE-IDENTICAL** (the `noParamSubst` arm claims
`rhs` ahead of the `!rhs`-guarded flat arm).

`m_ifs108` — the LANDED struct-formal precedent inside an **interface** — is
`0/0` on both binaries: undisturbed.

---

## 3. The two residues this verification found (both pristine-wrong already)

Neither is a regression: on both faces the pristine binary was already wrong, so
`AWAY_GOLDEN` stays 0.  Both are `MOVED_WRONG` — the law fires and lands on a
different wrong object — and both are worth naming for the next pass.

### R-V1 — an INTERFACE instance gets the op75 with the FORMAL's typespec

`m_if108.sv`: `interface mi108 #(parameter bit R = 0); ... mi108 #(.R(RSP)) i_if();`
**122/1 → 164/1**, a NEW head:

```
LHS  struct_typespec (u108::rsp_t)   under ref_typespec (work@m_if108.i_if)
RHS  bit_typespec                    under ref_typespec (work@m_if108.i_if.R)
```

The `op75` and all four operands are now **exactly** golden's; only the
`ref_typespec`'s ACTUAL is the FORMAL's `bit_typespec` instead of a clone of the
ACTUAL's struct typespec.  The failure therefore moved from a whole-object
`VpiType` mismatch DOWN to the typespec — closer, not further — but it is
compare-visible and it did not exist before this patch.

Diagnosis (read, not guessed): `mintParamOpClones` is called from **one** place,
`src/ModuleEmit.cpp:6852`, inside the module-instance path.  The INTERFACE elab
path calls `emitParameters(..., topView=true, ...)` at
`src/ModuleEmit.cpp:27959` and **never mints the op clone**, so the flat arm's
`rhsRt` is left to `patchParamTypespecs`, which binds it to the parameter's OWN
typespec clone.  With a struct FORMAL that clone IS the struct — which is
exactly why the landed struct-formal law never exposed the gap and why
`m_ifs108` is clean.  With a non-struct formal it is the `bit_typespec`.
The fix is to reach `mintParamOpClones` from the interface elab path; it was NOT
attempted here because minting there would also act on the landed struct-formal
interface cells that are currently EQUAL, and that risk belongs in a pass with
its own gate battery, not in a verification.

### R-V2 — the actual is the parent's own struct FORMAL overridden with an INLINE pattern

`m_par108.sv`: `mid108 #(.P(rsp_t'{...})) i_q` and inside `mid108`,
`mp108 #(.R(P)) i_p`.  Golden's Rhs there is `op67(op33(ref_obj, const, …))` —
the implementer's residue R4 producer, one level down.  Ours was `constant 0`
and is now a flat `op75`.  Masked in the arm (cmp count unchanged at 2428/1;
the two dumps differ only in one arena id), so it reaches the judge in no corpus
cell, but the shape is admitted and the producer is the wrong one.
The discriminator is `ParameterSymbol::getInitializer()` on an OVERRIDDEN
parameter: it returns the OVERRIDE expression, so an inline pattern there reads
as a declaration pattern.  `m_par2108` — the same shape overridden with a bare
package reference — correctly declines, because there the initializer is a
`NamedValue`, not a pattern.

### A census caveat, not a defect

`cen108`'s payload includes `tsfn`, the op's `ref_typespec` **vpiFullName**, and
**no generated `Compare` reads a fullname** (RESUME.md §9).  Seven gen-scope
cells across `m_gen108` / `m_hier108` / `v2_shape108` score `MOVED_WRONG` on
that column alone — golden `work@m_gen108.gfor[0].i_g`, ours
`work@m_gen108.i_g` — while `uhdm-cmp` calls the whole database **EQUAL**
(`m_gen108` 122/1 → 0/0).  So the pass's corpus `MOVED-WRONG=0` is conservative
in the safe direction, and its `TO-GOLDEN=2` is a floor, not a ceiling.  This is
the pass's own residue R5, measured.

---

## 4. Reproducing

```bash
PATCHED_BIN=<patched> PRISTINE_BIN=<pristine> CEN_BIN=<cen108 from r10earl108repro> \
  bash gridv108.sh <outdir> v1_types108.sv v2_shape108.sv m_gen108.sv m_if108.sv \
       m_ifs108.sv m_par108.sv m_par2108.sv m_wide108.sv m_nest108.sv \
       m_defp108.sv m_multi108.sv m_arr108.sv m_hier108.sv
# then, per cell:  cen108 <golden> <ours> <view> --raw  |  score108.py (r10earl108repro)
PATCHED_BIN=… PRISTINE_BIN=… PROBE_ROOT=<worktree> STAGE=… \
  bash widev108.sh <file-list> <out-prefix>     # WIDE.* here are its outputs
```
