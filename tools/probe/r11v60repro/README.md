# r11v60 — the import-copy trigger must RESOLVE to the declaring package, and `time` is fenced in a PACKED struct too

Adversarial verification of r11u60 (`§ modDefImportPkgSelFlat60`) at base
`00608fe8` (v1.87 pass 58).  Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 (`0445655ee7`), uhdm2rtlil v0.68.  Every golden here
is a real Surelog v1.87 run through
[tools/probe/r11u60repro/arm.sh:1](tools/probe/r11u60repro/arm.sh#L1); every arm
records `slrc`/`ourrc`/`slerr`.

**VERDICT: ACCEPT-WITH-FIX.**  Every headline number in the implementer's
report reproduced bit-for-bit, including the two binary md5s.  Three faces the
grid did not reach moved AWAY FROM GOLDEN on the implementer's binary; two
narrowing fences repair them, the head still clears, and no measured mover
changed.

---

## 0. WHAT REPRODUCED, BIT FOR BIT

Built both binaries in my own worktrees from `00608fe8`, `-j 2`, frozen
`chmod 555` before any sweep.

| quantity | implementer | measured here |
|---|---|---|
| pristine binary | `fd9480af20aeb844dce0fe2ec7d8fee1` | identical, and identical to the main tree |
| law binary | `2f7181e05985e7c2e1c313858f93b6e7` | identical |
| head at the base, u2r DEFAULT | `ref_typespec: (work@my_if), id:379` … `RHS: <null>` | identical, 1 head per run |
| head after | `constant: id:715 vpiSize:32 UINT:8` vs `id:517 vpiSize:64` | identical |
| grid, 7 scored arms | TO 16 AWAY 0 MOVED-WRONG 0 STILL 27 SAME 76 | identical |
| u2r census | GCTRL 4, LAWCELLS 3 on 1 test, RISK 529, both modes | identical |
| u2r predictor | 174 candidate cells, 3 predicted, `iface_zero_width_field` | identical |
| u2r byte movers | 2 / 1608, both `iface_zero_width_field` | identical |
| `g8` type key | Surelog `slrc=4`, `[ERR:UH0713]` | identical |

**One evidence file does not hold: `head.{pris,law}.testflags.cmp`.**  Re-measured
here, `iface_zero_width_field` in TESTFLAGS mode does NOT head on the R0 cell —
it heads on a design-level `uhdmallPackages` VECTOR-SIZE object (`design:
(work@top), id:1014`, the SafeCompare vector overload setting both containers),
6142 stderr lines, and that head is IDENTICAL on the pristine and the patched
binary and MASKS the `p::B` cell in that mode.  The committed testflags files
carry the DEFAULT run's object ids (`id:379` / `id:380`), which a
`--timescale 1ns/1ns` run does not produce; they are the default measurement
wearing a testflags label.  The LAW is unaffected — the testflags row's byte
mover and its DEF cells move exactly as the default row's do — but the claim
"both modes, identical text" is not a measurement.  Mine:
`evidence/head.{pris,verified}.testflags.cmp`.

The sectioned closure reproduced as a DELTA exactly (my dumps are
indentation-stripped before sorting, so my absolute line counts are smaller
than the report's; the movement is the same):
`uhdmallInterfaces 36 -> 0`, `uhdmallModules 72 -> 0`,
`uhdmtopPackages 5 -> 5` (R1, unmoved), `uhdmtopModules 682 -> 520`
(**Δ162**, the same 800 -> 638 the report quotes).

**One number is a multiset artefact, corrected.**  The report's
"**82 cells** where the op-level `ref_typespec` gained `(work@bp_be_pipe_int)`"
is 82 DUMP LINES.  Per-cell, keyed on `(listing, parameter, loc)` with the
op-level ref's OWN NAME (`tsname.py`, the field `shape.py` does not read), the
whole BlackBePipeInt dump says:

```
   41  golden=work@bp_be_pipe_int  pristine=BARE  law=work@bp_be_pipe_int   <- TO GOLDEN
   62  golden=work@bp_be_pipe_int  pristine=BARE  law=BARE                  <- STILL
   41  golden=BARE   pristine=bp_common_pkg  law=bp_common_pkg              <- STILL (R1)
    1  golden=NONE   pristine=work@bp_be_pipe_int  law=same                 <- STILL
```

**41 cells TO GOLDEN, 0 AWAY**, and the 41+62 split says the face is half
closed, not closed.  `cells: 482 482 482` — no cell appeared or vanished.

---

## 1. THE THREE BREAKS (all on the implementer's binary, all legal SV)

`score60.py` per cell; full logs `evidence/GRID.law.txt` (law binary) and
`evidence/GRID.verified.txt` (after the fix).

### 1a. `v1.sv` — CROSS-PACKAGE NAME COLLISION.  AWAY-GOLDEN.

`hasMemberSelectOf` keys on a BARE NAME and ANY package.  Two packages, one
identically named unpacked-struct localparam each; `pa` member-selects its own
`HIT` in a typedef dim, `pb::HIT` is selected NOWHERE, and a module imports
`pb::HIT` only:

```
AWAY  uhdmallModules work@v1q.HIT line:14:19
   golden op=75 ts=-                      ops=[tagged_pattern tagged_pattern]
   pris   op=75 ts=-                      ops=[tagged_pattern tagged_pattern]   <- RIGHT
   law    op=75 ts=struct_typespec(pb::sb_t) ops=[const/32 const/32]            <- WRONG
```

The sibling `pb::MISS` (same package, no twin anywhere) stays tagged on every
binary — so the trigger really is the NAME, not the parameter.  This is the
r11u49 R1 warning, no longer theoretical.

### 1b. `v2.sv` — a `time` MEMBER IN A PACKED STRUCT.  AWAY-GOLDEN.

r11u49's non-integral/`time` fence is applied by r11u60 only when the struct is
UNPACKED, on the reasoning that "a packed struct's fields are integral by
construction".  True, and beside the point: `time` IS integral and IS legal in
a packed struct, and golden declines it there too.

```
AWAY  uhdmallModules work@v2q.TPK line:10:19        (struct packed {time t; logic[31:0] a;})
   golden op=75 ts=-                        ops=[tagged_pattern tagged_pattern]
   pris   op=75 ts=-                        ops=[tagged_pattern tagged_pattern]   <- RIGHT
   law    op=75 ts=struct_typespec(p2t::tp_t) ops=[const/64 const/32]             <- WRONG
```

Its plain packed sibling `CPK` is FLAT in golden and moves correctly, and its
UNPACKED twin `TUN` declines on both binaries — so the arm separates "time"
from "this arm cannot move anything".

### 1c. `v7.sv` — A SELECT IN ANOTHER PACKAGE.  AWAY-GOLDEN + MOVED-WRONG.

Package `pc` declares three identical localparams and selects none.  Package
`pd` imports `pc` and writes `pc::CFGX.a` (SCOPED) and `CFGY.a` (UNQUALIFIED,
on `pd`'s own import copy).  Golden's answer is not one rule but two objects:

| cell | golden | pristine | law |
|---|---|---|---|
| `work@v7q.CFGX` (module imports `pc`) | FLAT | tagged | flat ✔ |
| `work@v7q.CFGY` (module imports `pc`) | **TAGGED** | tagged ✔ | **flat — AWAY** |
| `work@v7d.CFGX` (module imports `pd`) | **untyped, TAGGED** | typed, tagged | **typed, flat — MOVED-WRONG** |
| `work@v7d.CFGY` (module imports `pd`) | typed + FLAT | typed, tagged | flat ✔ |
| `*.CFGN` (never selected) | tagged | tagged | tagged ✔ |

The producer reading that fits every one of those cells: `substituteAssignedValue`
reduces the `param_assign` OBJECT the select RESOLVES TO.  `pc::CFGX.a` written
in `pd` reduces `pc`'s own assign (so the copy in a module importing `pc`
flattens); a bare `CFGY.a` written in `pd` reduces `pd`'s IMPORT COPY (so `pd`'s
consumers flatten and `pc`'s do not).  A bare-name predicate cannot tell the two
apart and fires on both at both faces.

---

## 2. THE FIX — two narrowing fences, `src/TypeEmit.cpp` + `src/ParamEmit.cpp`

Both fences only ever turn `impPkgSelFlat60` OFF, so neither can mint a new
AWAY cell.

**`§ importCopyDeclPkgSelect60v`** — a new predicate
`hasMemberSelectOfInPkg(pkg, name)` keyed on `<declaring package>::<parameter>`,
populated by the SAME scan `hasMemberSelectOf` already builds (so the class
fence `§ pkgClassBodySelectDeclined49v` and the package-scope restriction are
literally the same object).  A select is recorded against the package it is
WRITTEN IN when it is bare, and against its own qualifier when it is spelled
`X::NAME.` — and only the DECLARING package's key is read.  `hasMemberSelectOf`'s
own set is byte-unchanged, so the pass-48 elab-package face is untouched.

The CROSS-PACKAGE SCOPED spelling (`pc::CFGX.a` in `pd`) is **declined
outright** rather than modelled: it is right for `work@v7q.CFGX` and wrong for
`work@v7d.CFGX`, one trigger cannot answer both, and STILL-WRONG is allowed
where MOVED-WRONG is not.  `v7q.CFGX` is recorded as R1 below.

The declaring package's own SELF-SCOPED spelling is accepted, because golden
accepts it: `v8.sv` holds `p8v::SS` (selected as `p8v::SS.a` inside `p8v`) and
`p8v::SB` (selected as `SB.a`) and golden flattens BOTH DEF import copies while
leaving the never-selected `p8v::SN` tagged.  That is the `q == pkgName` clause,
and it is load-bearing.

**`§ packedTimeMemberDeclined60v`** — the non-integral / `time` member walk runs
over BOTH packings.

**Both corpus witnesses survive, and that was checked before the sweep:**
`iface_zero_width_field`'s `p::B` is selected inside `p` itself
(`dut.sv:11,12,15,16`), and BlackBePipeInt's `bp_default_cfg_p` (`dut.sv:2046`)
and `bp_unicore_cfg_p` (`:2565`) are declared AND selected inside
`bp_common_pkg` (`:1764-14973`).  The two binaries' BlackBePipeInt databases are
byte-identical (`0754dbaa7154`), so the fix changed nothing there.

---

## 3. THE VERIFIED GRID — 15 arms, AWAY 0, MOVED-WRONG 0

```
            implementer's law binary            verified binary
ARM g1      TO 4  AWAY 0  MW 0  STILL 0         TO 4  AWAY 0  MW 0  STILL 0
ARM g2      TO 2  AWAY 0  MW 0  STILL 8         TO 2  AWAY 0  MW 0  STILL 8
ARM g3      TO 4  AWAY 0  MW 0  STILL 7         TO 4  AWAY 0  MW 0  STILL 7
ARM g4      TO 3  AWAY 0  MW 0  STILL 3         TO 3  AWAY 0  MW 0  STILL 3
ARM g5      TO 1  AWAY 0  MW 0  STILL 7         TO 1  AWAY 0  MW 0  STILL 7
ARM g6      TO 1  AWAY 0  MW 0  STILL 2         TO 1  AWAY 0  MW 0  STILL 2
ARM g7      TO 1  AWAY 0  MW 0  STILL 0         TO 1  AWAY 0  MW 0  STILL 0
ARM v1      TO 1  AWAY 1  MW 0  STILL 4         TO 1  AWAY 0  MW 0  STILL 4
ARM v2      TO 1  AWAY 1  MW 0  STILL 3         TO 1  AWAY 0  MW 0  STILL 3
ARM v3      TO 4  AWAY 0  MW 0  STILL 2         TO 4  AWAY 0  MW 0  STILL 2
ARM v4      TO 4  AWAY 0  MW 0  STILL 7         TO 4  AWAY 0  MW 0  STILL 7
ARM v5      TO 1  AWAY 0  MW 0  STILL 3         TO 1  AWAY 0  MW 0  STILL 3
ARM v6      TO 1  AWAY 0  MW 0  STILL 3         TO 1  AWAY 0  MW 0  STILL 3
ARM v7      TO 2  AWAY 1  MW 1  STILL 9         TO 0  AWAY 0  MW 0  STILL 12
ARM v8      —                                   TO 2  AWAY 0  MW 0  STILL 3
TOTAL       TO 25 AWAY 3  MW 1                  TO 30 AWAY 0  MW 0
```

The new faces the verifier arms add, beyond the implementer's grid:

| arm | face | golden | verdict |
|---|---|---|---|
| `v1` | two packages, one name; only one selected | the unselected copy TAGGED | fence 1a |
| `v2` | `time` in a PACKED struct, package-selected | TAGGED | fence 1b |
| `v3` | `'{default: N}` and `'{A:1, default: N}`, packed AND unpacked | all four FLAT at the DEF face | 4 TO ✔ |
| `v4` | nested holders: generate-instantiated, 3-deep, interface-in-module, NEVER-instantiated def | all four FLAT | 4 TO ✔ |
| `v5` | `string` member, UNPACKED-ARRAY member | TAGGED | declines ✔ |
| `v6` | pattern-valued element in a PACKED struct; SYMBOLIC member dim | TAGGED / **FLAT** | see R2 |
| `v7` | a select written in ANOTHER package, scoped and bare | split per object | fence 1c |
| `v8` | the declaring package's own SELF-SCOPED spelling | FLAT | accepted ✔ |

`v4never` is worth naming on its own: a module DEFINITION that is never
instantiated still carries the flattened import copy in golden, and it moves.

---

## 4. CENSUS AND MOVERS — predicted BY NAME, with the positive control

`cen60.py` and `pred60.py` were re-run against MY OWN pristine workdirs (the
shared `/tmp/ctl_wd_*` controls were never read).  Positive controls non-zero:
`ALLCTRL` 227 golden typed-flat cells per mode, `GCTRL` 4 in the DEF listings.

```
== u2r default   GCTRL=4  LAWCELLS=3 on 1 tests  RISK(must not move)=529
== u2r testflags GCTRL=4  LAWCELLS=3 on 1 tests  RISK(must not move)=529
== predictor: 174 candidate DEF struct-op cells -> 3 cells, 1 test, both modes
== PREDICTED MOVERS: iface_zero_width_field  (u2r)  +  BlackBePipeInt (surelog)
```

`BlackBePipeInt` was attributed BEFORE the sweep by running the frozen binaries
on its own source (§0).  MEASURED: u2r **MOVERS 2 / 1608**, both
`iface_zero_width_field`; surelog movers are the two BlackBePipeInt rows plus
the documented UVM-family draws (§5).

---

## 5. GATES

1. **BUILD** — pristine `fd9480af20aeb844dce0fe2ec7d8fee1` (byte-identical to
   the main tree at `00608fe8`); implementer's law `2f7181e05985e7c2e1c313858f93b6e7`;
   verified `9452577e1d0e0d64f87e78ad6e3b3cd6`.  0 errors, `-j 2`.
2. **GOLDENS** — `tests/check_goldens.sh` PASS 23 / FAIL 0 on the pristine AND
   the verified binary; `SLANG_UHDM=/bin/false` PASS 0 / FAIL 23.
3. **uhdm2rtlil, both modes** — 785 / 19 / 67 in each mode on both binaries, the
   baseline exactly.  Whole-row join against `results/gate_uhdm2rtlil.csv`,
   against `results/golden_uhdm2rtlil.csv` (BOTH modes, 871 rows each,
   **0 differing rows**) and against my own pristine CSVs: PASS.
4. **Surelog suite, `--mode both`** — see `evidence/GATES.txt`.
5. **byteverify `SELFCHECK=1`** vs my own pristine workdirs — u2r
   MOVERS 2/1608 (PATH_SETS_IDENTICAL, SELFCHECK 1607/1608 flagged).
6. `results/*.csv` untouched; no fenced test dispatched; `GOLDEN_DEFER` unset;
   every `cmds.txt` audited by binary PATH.

---

## 6. RESIDUES THIS VERIFICATION ADDS

* **R1 — the CROSS-PACKAGE SCOPED select is unmodelled.**  `v7q.CFGX`: a
  `pc::CFGX.a` written inside package `pd` DOES reduce `pc`'s own
  `param_assign`, and golden flattens the DEF import copy in every module that
  imports `pc` — while the copy in a module that imports `pd` stays TAGGED.  Two
  faces, one name; declined outright here.  STILL-WRONG 1 cell on `v7`, no
  corpus cell (the census names none).
* **R2 — a SYMBOLIC member dim is NOT a golden fence at either face.**  `v6`'s
  `p6n::PSYM` (`struct packed { logic [WD-1:0] a; logic [7:0] b; }`, `WD` a
  package parameter) is FLAT in golden in BOTH the elaborated package listing
  and the DEF import copy; our `structHasSymbolicMemberDim` declines both.
  PRE-EXISTING (the pristine binary is wrong at the elab face already) and
  unmoved here — a fence we carry that golden does not have.  1 cell, arm only.
* **R3 — `time` in a PACKED struct is still wrong at the ELAB PACKAGE face.**
  `v2`'s `uhdmtopPackages p2t::TPK`: golden TAGGED, our PRISTINE binary types
  and flattens it at 64/32.  The same missing fence this pass adds at the import
  -copy face, on a face this pass does not touch — pristine-wrong, so out of the
  verifier's mandate, but it is the one-line sibling of
  `§ packedTimeMemberDeclined60v` whenever that face is opened.
* **R4 — `pb::HIT` is wrong at the ELAB PACKAGE face too.**  `v1`'s
  `uhdmtopPackages pb::HIT`: golden TAGGED, our PRISTINE binary flat, because
  the landed pass-48 predicate is the bare-name one.  The r11u49 R1 warning has
  a live cell at the face it was written about; no corpus row is on it.
* **R5 — an ops residue, not a measurement one.**
  `tools/probe/r11u60repro/score60.py:12` hard-codes
  `sys.path.insert(0, '/tmp/r11u60_probe')`, a scratch path of the implementing
  session; the committed instrument cannot import `shape.py` anywhere else.  It
  was run here from a copy with that line re-pointed.

---

## 7. FILES

| file | what it is |
|---|---|
| `v1.sv` | cross-package NAME COLLISION — the AWAY cell of fence 1a |
| `v2.sv` | `time` in a PACKED struct (+ the unpacked twin and a plain packed control) |
| `v3.sv` | `'{default:}` / `'{A:1, default:}` at the import-copy face, packed and unpacked |
| `v4.sv` | nested holders: generate, 3-deep, interface-in-module, never-instantiated |
| `v5.sv` | `string` and UNPACKED-ARRAY members |
| `v6.sv` | pattern-valued element (PACKED) and a SYMBOLIC member dim |
| `v7.sv` | a select written in ANOTHER package — scoped vs bare (fence 1c) |
| `v8.sv` | the declaring package's own SELF-SCOPED spelling (the `q == pkgName` clause) |
| `tsname.py` | the op-level `ref_typespec`'s OWN NAME per cell — the field `shape.py` does not read; this is what turns "82 lines" into "41 cells" |
| `evidence/GRID.law.txt` | all 14 arms scored on the implementer's binary — the 3 AWAY + 1 MOVED-WRONG |
| `evidence/GRID.verified.txt` | all 15 arms scored on the verified binary — AWAY 0, MOVED-WRONG 0 |
| `evidence/GATES.txt` | the gate transcript |
| `evidence/BBPI.cells.txt` | the per-cell BlackBePipeInt attribution |
