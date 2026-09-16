# r11v49 — adversarial verification of r11u49, and the three fences it was missing

Base `a0dfe261`. Pins per `SUPPORT_MATRIX.md`. Every golden here is a real
Surelog v1.87 run through `arm.sh`; every arm records `slrc`/`ourrc`/`slerr`
and every one of the 32 arms run here is `slrc=0 ourrc=0 slerr=0` on every
binary — an arm whose compile fails teaches error recovery, not golden.

Three binaries, all built by the verifier from its own worktrees and frozen
`chmod 555` at `/tmp/v11u49_bin/` before any sweep:

| binary | md5 | what it is |
|---|---|---|
| `pris.bin` | `adf22bb0c9085e300eec1b4a7c8cdacc` | `a0dfe261`, byte-identical to the main tree |
| `law.bin` | `d2d18afeeb28465f3ab0542185e67c0c` | `/tmp/r11u49.patch` as submitted |
| `final.bin` | `acbe2f0ed8915eb33dec990178ffd794` | the submitted patch **plus** the three fences below |

## 1. What reproduced bit-for-bit

* both submitted md5s, 0 errors each;
* goldens 23 PASS / 0 FAIL, `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL;
* uhdm2rtlil both modes 783 / 21 / 67; `ct8rows.sh` *PASS: every row
  byte-identical* against the committed `results/golden_uhdm2rtlil.csv`;
* Surelog both modes 474 / 9 and 469 / 8, every other bucket identical
  (DEFERRED 5/5, SLANG_REJECT 285/286, SURELOG_FAIL 25/23, NO_DATABASE 3,
  NO_UHDM 1, TIMEOUT 1, UNTRANSLATABLE 2), and the only two flagged rows are
  the workdir PATH inside a golden-side `SURELOG_FAIL` message
  (`LowMemLib`, `LowMemPkg`, testflags), status unchanged;
* `byteverify SELFCHECK=1` MOVERS **2 / 1608** on uhdm2rtlil, both
  `iface_zero_width_field` — exactly the predicted set, name for name;
* the head, `grep -c '^LHS:'` = 1: pristine `ref_typespec: , id:90 ->
  struct_typespec (p::bus_t)` / `RHS: <null>`, and on the law binary the R0
  head one level out (`ref_typespec: (work@my_if), id:379`);
* the move is TOWARD golden — order-blind whole-dump distance **1117 -> 1003**
  on `iface_zero_width_field/default`;
* the census positive control: **227** golden typed-flat ELAB cells on
  uhdm2rtlil, both modes;
* the 14-arm golden grid, re-cut and re-scored by this directory's own scorer:
  **TO 19  AWAY 0  STILL 30  SAME 102** — the submitted total, cell for cell
  (`evidence/GRID.implementer-rerun.txt`), and it re-scores identically on
  `final.bin`, so none of the three fences costs a single landed cell.

## 2. THE THREE AWAY-GOLDEN FACES THE SUBMITTED GRID DID NOT CUT

### 2a. A select written inside a CLASS — `§ pkgClassBodySelectDeclined49v`

`§ pkgScopeMemberSelect49` widened `hasMemberSelectOf` from "a select in a
package PARAMETER DECLARATION" to "a select anywhere inside a package". Arm
`b1` varied the CONSTRUCT, but every package-side site it cuts is ordinary
package code. **A CLASS BODY is not** — and it is the UVM shape.

`v11.sv`: four identical packed-struct package localparams, no `p::NAME`
anywhere (the module wildcard-imports, so only the member-select trigger can
fire), each selected in exactly one site, carrying one LIVE and one DEAD
instance of each so that "class" is separated from "never evaluated":

| parameter | its one select site | golden ELAB | `pris.bin` | `law.bin` | `final.bin` |
|---|---|---|---|---|---|
| `r::RFCALL` | package function body, function **called** | **flat** | tagged | flat ✔ | flat ✔ |
| `r::RFDEAD` | package function body, function **never called** | **flat** | tagged | flat ✔ | flat ✔ |
| `r::RCUSED` | **class** method, class instantiated, method called | **tagged** | tagged | **flat ✗ AWAY** | tagged ✔ |
| `r::RCDEAD` | **class** method, class never used | **tagged** | tagged | **flat ✗ AWAY** | tagged ✔ |

The discriminator is the CLASS, not evaluation. `v4.sv`'s `r::RCLS` is the same
cell in isolation. Fix: `if (node.kind == ClassDeclaration) return;` in the scan
(`src/TypeEmit.cpp`).

### 2b. A NON-INTEGRAL member — `§ unpNonIntegralMemberDeclined49v`

The fence a PACKED struct could never need. `v14.sv` is one package, three
unpacked structs, each read `p::NAME.member` the same way, differing only in one
member's type:

| struct | golden ELAB | `pris.bin` | `law.bin` | `final.bin` |
|---|---|---|---|---|
| `uk_t {logic [31:0] k; logic [7:0] a}` | **flat** | tagged | flat ✔ | flat ✔ |
| `ur_t {real r; logic [7:0] a}` | **tagged** | tagged | **flat ✗ AWAY, and STRUCTURALLY WRONG** | tagged ✔ |
| `us_t {string s; logic [7:0] a}` | **tagged** | tagged | **flat ✗ AWAY** | tagged ✔ |

`ur_t` is the worst cell in this review: the flat walk emits one operand per
field it can reduce, so the `real` member VANISHED and a two-member struct
flattened to a **one-operand** op75. `v1.sv`'s `uarr_t` (an unpacked-array
member) is the third face — golden tagged, and now fenced on purpose rather
than by accident.

### 2c. A `time` member — the one INTEGRAL type golden also declines

`v17.sv` sweeps every predefined integral member type in one package, one
struct each, all read `p::NAME.a`:

```
byte  shortint  int  longint  integer  bit  logic  reg   ->  golden FLAT  (8/8, law and final both flat ✔)
time                                                     ->  golden TAGGED  (law flat ✗ AWAY, final tagged ✔)
```

`v16.sv` proves it is the TYPE and not the width: a `logic [63:0]` member and a
`longint` member both flatten beside a `time` member that does not; `realtime`
is `real` and carries 2b's arity bug too. `v15.sv` adds the positive half — a
packed-union member, a packed-struct member and an `integer` member all flatten
in golden and on `final.bin`.

All three fences live in the `unpPkgPat49` / `hasMemberSelectOf` predicates only.
`final.bin` and `law.bin` produce **byte-identical uhdm2rtlil databases
(MOVERS 0 / 1608)**, so the fences cost nothing in the corpus and the pass's one
conversion-free head win is untouched.

## 3. Verifier grid — 19 arms (`evidence/GRID.verifier.txt`)

```
ARM v1   TO 2 AWAY 0   ARM v6b TO 2 AWAY 2   ARM v11  TO 2 AWAY 0   ARM v15 TO 3 AWAY 0
ARM v2   TO 3 AWAY 0   ARM v7  TO 1 AWAY 0   ARM v12  TO 0 AWAY 0   ARM v16 TO 2 AWAY 0
ARM v3   TO 1 AWAY 0   ARM v8  TO 1 AWAY 1   ARM v13  TO 0 AWAY 0   ARM v17 TO 8 AWAY 0
ARM v4   TO 0 AWAY 0   ARM v9  TO 0 AWAY 0   ARM v13p TO 0 AWAY 0   ARM v18 TO 2 AWAY 0
ARM v5   TO 2 AWAY 0   ARM v10 TO 0 AWAY 0   ARM v14  TO 1 AWAY 0
VERIFIER GRID TOTAL over 19 arms:  TO 30  AWAY 3  STILL 41  SAME 155
```

## 4. The three AWAY cells that remain — pre-existing classes, each with its control

* **`v6b` (2 cells) — a select written in an IMPORTING package.** `p::UIMP` is
  an unpacked struct localparam in `p`; the only select is `UIMP.DAT` in `p2`'s
  parameter declaration. Golden leaves `p`'s own ELAB listing tagged and
  flattens only the materialized copy `p2::UIMP`; we flatten both, and the
  `uhdmallPackages p2::UIMP` DEF listing too. **`v10.sv` is the control**: the
  identical shape with a PACKED struct, which `pris.bin` already reaches through
  a parameter declaration and already gets wrong (`ARM v10 TO 0 AWAY 0
  STILL 3`). The road was wrong before; LAW A brings unpacked structs onto it.
* **`v8` (1 cell) — cross-package NAME COLLISION.** `hasMemberSelectOf` is keyed
  on the bare base identifier, so `q::CFG`'s select flattens `p::CFG` too.
  **`v9.sv` is the control**: the same collision reached through a package
  parameter declaration, which `pris.bin` already gets wrong (`ARM v9 TO 0
  AWAY 0 STILL 3`). §2a's clause bounds the widened reach back away from the
  UVM shape.

Both need the predicate re-keyed on the (declaring package, parameter) pair — a
change to a landed law that needs its own grid, including the
unqualified-import-read face neither arm here cuts.

## 5. Two residues this directory measured that neither binary moves

* **`v12` — the const-function-builder trigger does not reach the unpacked
  road.** An unpacked package param read WHOLE by a const-function builder
  (`c.u = UU`) flattens in golden; `pris.bin` and `final.bin` both keep it
  tagged. `§ patParamEvalFuncRead26`'s third trigger fires only on the packed
  road.
* **`v13` / `v13p` — the SYMBOLIC-DIM rule outranks the member-select trigger
  where golden does not.** A 120-bit struct with parameter-dependent member dims,
  member-selected in-package and never `p::`-qualified: golden flattens, we keep
  the tagged tree. `v13p` is the PACKED control and behaves identically, so this
  is packing-independent and pre-dates LAW A entirely.

## 6. Files

| file | what it is |
|---|---|
| `arm.sh` `shape.py` | the pass's own arm runner and shape lister, re-used verbatim |
| `score3.py` | the verifier's independent golden / pristine / final cell scorer |
| `v1 v2 v7` | LAW A: member kinds, symbolic dims, key kinds, fences |
| `v14 v15 v16 v17` | the non-integral and `time` fences and their positive halves |
| `v3 v4 v5 v8 v11` | LAW B: where a select may be written; `v11` is the decisive one |
| `v6b v9 v10` | the two remaining AWAY cells and their PRISTINE controls |
| `v12 v13 v13p` | the two unmoved residues of §5 |
| `v18` | LAW A through a parameter OVERRIDE (default and actual), TO 2 AWAY 0 |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `byteverify.sh` `ct8rows.sh` `rowheads.sh` | the current-generation battery (`r10uvm221repro`), run here |
| `evidence/` | both grid scores |
