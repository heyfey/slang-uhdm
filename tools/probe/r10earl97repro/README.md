# r10earl97 — § castTypedParamDeclSigned97

**The Earlgrey/testflags head: an `int_typespec` at a cast site whose
`VpiSigned` golden writes and we leave unset.**

BASE `915002a`, branch `auto5h`. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; everything
in this directory is **MEASUREMENT ONLY**.

---

## 1. The head

`rowheads.sh` on this pass's own pristine build, `Earlgrey_0_1` / testflags:
**54 cmp lines, ONE head** (`HEAD_BEFORE_Earlgrey_testflags.cmp`):

```
LHS:  int_typespec: , id:1019031, line:31:14, endln:31:17
      |vpiParent:  ref_typespec (work@top_earlgrey.u_hmac.u_packer)
      |vpiExpr:    ref_obj (work@prim_packer.PtrW.PtrW)
                     |vpiActual: parameter work@top_earlgrey.u_hmac.u_packer.PtrW
      |vpiSigned:1
RHS:  the SAME kind, the SAME span, the SAME vpiExpr ref_obj bound to the
      SAME parameter — WITHOUT vpiSigned.
```

`prim_packer.sv:31` is `localparam int PtrW = $clog2(Width+1);`; `31:14-31:17`
is the `int` keyword and `31:18-31:22` is the name. `int_typespec::Compare`
(`~/git-repos/UHDM/build/generated/src/int_typespec.cpp:97-113`) reads, in
order, `typespec::Compare` (kind / `Typedef_alias` / `Instance` / name), then
`Cast_to_expr`, then `VpiSigned`, then `Ranges`. Both sides carry the same
`Cast_to_expr`, so the failing field is the **`VpiSigned` bool** — and the bool
mismatch sets `m_failedLhs = m_failedRhs = the typespec itself`, which is why
the head names the same object twice.

`g0_head97.sv` reproduces it in fifteen lines: one head on the pristine binary,
`uhdm-cmp` EQUAL after the law, in both views.

---

## 2. The decoded model — where Surelog writes `VpiSigned` on an integer-kind typespec, and where it does not

**(a) The declaration.** `CompileHelper::compileTypespec`
(`Surelog/src/DesignCompile/CompileType.cpp:1494-1515`) routes every integer
atom / vector keyword to `compileBuiltinTypespec`
(`CompileType.cpp:1126-1231`), which opens with

```cpp
  bool isSigned = true;                       // 6.8: byte, shortint, int,
  if (sign && fC->Type(sign) == paSigning_Unsigned) isSigned = false;
```

and then, per kind:

| keyword | object | `VpiSigned` written |
|---|---|---|
| `int` | `int_typespec` | `isSigned` — **true unless `unsigned`** |
| `integer` | `integer_typespec` | `isSigned` |
| `byte` / `shortint` / `longint` | that kind | `isSigned` |
| `logic` / `reg` / net types | `logic_typespec` | `isSigned`, reset to **false** unless `signed` |
| `bit` | `bit_typespec` | same false-unless-`signed` rule |
| `time` | `time_typespec` | **never touched** (`CompileType.cpp:1188-1192`) |
| `real` / `shortreal` / `string` | that kind | no such field |

**(b) The cast target.** A `P'(x)` size cast whose `P` names a parameter is
resolved by `compileDatastructureTypespec`'s `ParamAssign` arm
(`CompileType.cpp:750-782`). Surelog **mints nothing**: it takes the
parameter's own declaration typespec —

```cpp
    UHDM::parameter* lhs = (UHDM::parameter*)param_assign->Lhs();
    if (ref_typespec* rt = lhs->Typespec()) result = rt->Actual_typespec();
    ...
    if (result->UhdmType() == uhdmint_typespec) {
      int_typespec* ts = (int_typespec*)result;
      ref_obj* ref = s.MakeRef_obj();
      ref->Actual_group(lhs); ref->VpiName(typeName); ref->VpiParent(ts);
      ts->Cast_to_expr(ref);                      // <- MUTATES the declaration
    }
```

— and only hangs a `ref_obj` on it. **The cast site's `VpiSigned` IS the
declaration's**, because it is the same object; the doubled fullname
(`work@prim_packer.PtrW.PtrW`) is the parent-synthesis of a `ref_obj` named
after the parameter and parented on the parameter's typespec.

**(c) The one place Surelog does NOT write it.** When the parameter has no
typespec at all (an UNTYPED `localparam W = ...`), the same arm falls through
to `CompileHelper::buildIntTypespec` (`CompileType.cpp:1096-1124`), which sets
`VpiValue`, `VpiName` and the location **and never touches `VpiSigned`**. That
is the negative control in `g5_neg97.sv`, and it is why the untyped sibling
must stay unsigned.

**(d) The view.** Elaboration clones the declaration typespec per instance
(`clone_tree`), and the clone copies the bool. So EVERY elaborated instance of
the definition carries it — measured on three instances in `g3_home97.sv`.

---

## 3. Our writer, and the fence that left it unset

`src/ExprEmit.cpp`, inside `emitExpr`'s size-cast arm, § `castTypedParamDeclTs`
(the `else if (UHDM::int_typespec* dts0 = nullptr; [&]{…}())` arm at
`~:18456-18514`). It is the arm that deliberately MIRRORS the declaration
typespec for a **typed** cast target whose default cannot fold at definition
compile — the sibling of § `castSizeParamTs` (untyped target) and of
`castTgtDefaultIsLiteral` (literal default, which mints the named object
instead). It copied `VpiName("")`, the file and all four location fields off
`dts0`, and the `Cast_to_expr` ref_obj's name / fullname / `Actual_group` —
but **not `VpiSigned`**, so the freshly minted `MakeInt_typespec()` kept the
default `false`.

The measurement that fence was written for is `scr1_pipe_tdu`'s
`localparam int unsigned ALLTRIG_W = $clog2(ALLTRIG_NUM+1)` — an **unsigned**
target, where `false` happened to be right. Both Scr1SvTests rows (5 golden
cells each mode) are of that shape, which is exactly why the defect survived:
the arm's own corpus witness never exercised the signed half.

**THE LAW.**

> § castTypedParamDeclSigned97 — the elaborated copy the cast makes of a TYPED
> parameter's declaration `int_typespec` carries that declaration's
> `VpiSigned`. Surelog shares the object; we copy it, so the flag is copied
> with the span and the `Cast_to_expr`. Because it MIRRORS, an `int unsigned`
> target stays unsigned and nothing is stamped where golden leaves it clear.

One line of production code:

```cpp
    its0->VpiSigned(dts0->VpiSigned());
```

---

## 4. The measured population, and the mover prediction

`pop97.sh` over every golden of both sweeps (the denominator = every golden
`int_typespec` OWNED BY A CAST OPERATION and carrying a `Cast_to_expr`):

* **uhdm2rtlil — 0 rows in 1358 databases.** The corpus has no cell of this
  law's shape: nothing to fix, nothing to break.
* **surelog — 278 rows in 956 databases**, in three tests:
  Earlgrey_0_1 (112 default / 111 testflags), Rggen/default (45),
  Scr1SvTests (5 per mode).

Our pristine database disagrees on **EIGHT** of the 278 — the four `sgn=1`
cells in each Earlgrey mode (`prim_packer` `Width` ×2 and `PtrW`, `pinmux`
`AlignedMuxSize`). Rggen's 45 are golden objects we do not mint at all (our
side has zero rows of that shape and Rggen/default is CMP_EQUAL — the judge
never reaches them); Scr1SvTests' 10 are the `int unsigned` cells above, right
on both sides before and after.

**PREDICTION, made from the PRISTINE databases before the patched sweep:
EXACTLY TWO DATABASES MOVE — `./default/Earlgrey_0_1` and
`./testflags/Earlgrey_0_1`. uhdm2rtlil: ZERO movers.**

**WHAT ACTUALLY MOVED** (`byteverify.sh SELFCHECK=1`, patched vs this pass's
OWN pristine sweep; both binaries frozen `chmod 555` at immutable paths of the
SAME LENGTH, every `cmds.txt` audited BY BINARY PATH — 0 of 1462 + 1573 name
the main-tree binary):

```
  uhdm2rtlil  MOVERS 0 / 1358   <- as predicted  (SELFCHECK 1357/1358 flagged)
  surelog     MOVERS 2 /  956   <- as predicted, and NOTHING ELSE
      ./default/Earlgrey_0_1
      ./testflags/Earlgrey_0_1                   (SELFCHECK 955/956 flagged)
```

**Attribution.** The whole-dump path-normalised diff of each mover is **four
added lines and nothing else** (verifier correction: they land in the block
where `uhdm-dump` FULLY EXPANDS these typespecs, which is the design's
`weaklyReferenced` print block, NOT the `uhdmtopModules` block; the DEF
(`uhdmallModules`) and ELAB (`uhdmtopModules`) blocks print the same objects
only as unexpanded `|vpiActual: \_int_typespec:` headers and are byte-identical
side for side).  The objects themselves ARE parented under the ELABORATED
module instances -- the census keys them at `work@top_earlgrey.u_hmac.u_packer`
and `work@top_earlgrey.u_pinmux` -- and they are reachable to the official
Compare through the cast operation's `ref_typespec -> Actual_typespec`, which
is how the head named one of them and why the head CLEARS.  earl60's "never
count tail stamps" rule is about objects nothing references; it does not apply
to these, and the judge itself settles it:

```
  > |vpiSigned:1   on the cast typespec of work@prim_packer.PtrW   (×1)
  > |vpiSigned:1   on the cast typespec of work@prim_packer.Width  (×2)
  > |vpiSigned:1   on the cast typespec of work@pinmux.AlignedMuxSize (×1)
```

**The census re-scored** over the SAME fixed universe with the golden side
asserted byte-unchanged (`reg97.py`, the three-way golden / pristine /
candidate per-key multiset intersection; `CALIB` golden-vs-golden reads 0):

```
  Earlgrey default    TO-GOLDEN 4  AWAY-GOLDEN 0  ADDED 0  REMOVED 0
  Earlgrey testflags  TO-GOLDEN 4  AWAY-GOLDEN 0  ADDED 0  REMOVED 0

  BOTH-SAME  74375 -> 74379 (default) / 74317 -> 74321 (testflags)
  MOVED-WRONG 3438 -> 3434  (default) /  3500 ->  3496 (testflags)
  GOLDEN-ONLY and OURS-ONLY UNCHANGED TO THE ROW in both modes.
```

The law also converts an earlier pass's arm outright: `r10earl_repro/qj27.sv`
(a cast-width arm from the same family) goes from 1 head / 27 cmp lines to
`uhdm-cmp` **EQUAL** in both views — see the boundary in §6.

**MOVED-WRONG 0 / AWAY 0**, scored in both columns: within the law's shape the
wrong cells go 3→0 (default) and 4→1 (testflags), and the one that stays is not
a signedness cell at all but a pre-existing COUNT row (an `int unsigned` cast
typespec at `u_spi_device.u_fwmode` 46:14-46:26 of which we mint one copy too
many — present identically before and after, R2 below).

---

## 5. The head after

```
  Earlgrey_0_1  default    31 lines, 1 head   (UNCHANGED — a different object)
  Earlgrey_0_1  testflags  54 -> 36 lines, 1 head — THE HEAD CLEARED, new object
```

Every other measured row is unchanged: SeqDriver 60/60, SimpleUVM 36/36,
Scoreboard 163, MiniAmiq 106/106, BuildUVMPkg 45/45, Rggen/default 0 (EQUAL).

---

## 6. Gates (all green — see `GATES.r10earl97.txt` for the transcript)

1. both binaries built `-j 2`, md5 taken separately, frozen `chmod 555`;
2. goldens **23 PASS / 0 FAIL** on the patched binary AND on the pristine one,
   `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (negative control), with
   `SLANG_UHDM` exported explicitly to each binary;
3. u2r testflags **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**;
   `ct8rows` = 0 differing rows against the committed baseline AND against this
   pass's own pristine sweep, status AND dump column, both modes;
4. surelog `--mode both`: `ct8rows` = **0 differing rows over 1588**, against
   the committed baseline and against the pass's own pristine sweep. **No row
   is converted by this pass** (Earlgrey_0_1 stays CMP_NOTEQUAL — its default
   mode still has a head);
5. `byteverify SELFCHECK=1`: every mover named and attributed (above);
6. canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r);
   `ctcan2` PASS on both; `canaudit.sh` PASS; protected DBs by name —
   InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical to
   pristine, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`;
7. boundary — `BOUNDARY_WIDE.*`: every `.sv`/`.v` under a COPY of
   `tools/probe` at ANY depth (subdirectory arms included), both views, both
   binaries, workdir-normalised dump byte-compare, list on fd 3, children
   `</dev/null`, **LISTED=4364 == PROCESSED=4364**, identical 8370,
   **DIFFERING 2**, and the rc histogram is SYMMETRIC side for side
   (`0_A 8005 / 0_B 8005`, `139_A 14 / 139_B 14`, `3_A 342 / 3_B 342`,
   `4_A 367 / 4_B 367`). The two differing cells are both views of ONE
   earlier-pass arm, `r10earl_repro/qj27.sv` — itself a cast-width arm.
   Re-measured against golden it moves TOWARD it and nowhere else:
   `uhdm-cmp` 27 lines / 1 head → **EQUAL** in both views, census
   MOVED-WRONG 5→4 with both one-sided sets unchanged, `reg97` TO-GOLDEN 1 /
   AWAY-GOLDEN 0 / ADDED 0 / REMOVED 0 on
   `int|36:14-36:17|cast|work@qj27.u_c` (`localparam int MSZW = $clog2(…)`
   used as `MSZW'(be_i)` — the law's own shape).
   `BOUNDARY_OWN.*` is the POSITIVE CONTROL that the gate can see a moved
   cell: of the six own arms, **10 of 12 cells differ** (g0–g4 in both views)
   and exactly **2 are identical** — `g5_neg97` in both views, the negative
   control.

The four slang-fenced test names are never dispatched and appear in no driver
here; `canaudit.sh` asserts it.

---

## 7. Ranked residues this pass MEASURED and deliberately did not take

* **R1 — A NON-`int` CAST TARGET'S DECLARATION TYPESPEC IS NOT REUSED AT ALL.**
  `g1_kind97`: for `integer` / `shortint` / `longint` / `byte` / `time` /
  `bit` / `logic signed` computed-default localparams used as cast widths,
  golden reuses the DECLARATION typespec of that kind at the cast site (no
  `Cast_to_expr` — `CompileType.cpp:777` only attaches the ref for an
  `int_typespec`), while we mint a NAMED `int_typespec` at the identifier span.
  8 GOLDEN-ONLY + 16 OURS-ONLY cells on that arm, IDENTICAL before and after.
  **Corpus denominator: 0 cells** (`pop97.sh` finds no golden non-`int` cast
  typespec in either corpus). Its own law, its own census.
* **R2 — A PARENTHESISED CAST WIDTH ON A TYPED TARGET.** `g4_form97` `W_PAR`
  (`(W_PAR)'(m)` on a LITERAL-default `localparam int`): golden reuses the
  declaration `int_typespec` (`sgn=1`, with the `Cast_to_expr`), we mint an
  `integer_typespec` at the paren span. The same family owns the surviving
  Earlgrey COUNT row at `u_spi_device.u_fwmode` 46:14-46:26. 1 GOLDEN-ONLY +
  1 OURS-ONLY per view on the arm; 1 corpus cell (testflags only).
* **R3 — AN IMPORTED PACKAGE PARAMETER IS NOT LISTED UNDER THE IMPORTING
  MODULE.** `g2_owner97`: golden carries `int` typespecs for `p2o97::P_BASE`
  and `p2o97::P_PKG` under `work@sub2o97`; we carry none. 2 cells per view,
  unchanged by this law.
* **R4 — A GEN-SCOPE / INTERFACE CAST WIDTH FOLDS TO A DIFFERENT KIND.**
  `g3_home97`: golden's cast typespec inside a generate block (and inside an
  interface) is an `integer_typespec` at the cast span; ours differs. 3
  GOLDEN-ONLY cells on that arm, unchanged.
* **R5 — THE PRE-EXISTING PROBE / BOUNDARY SEGFAULTS.** The wide boundary's rc
  histogram is SYMMETRIC side for side; recorded by earl82 R6 / earl83 R6 /
  earl84 R6 / earl85 R5 / earl89 R6 / earl90 R8 / earl91 R5 / earl93 R7 /
  earl94 R6 / earl95 R4 / earl96 R5, and `byteverify` proves none of them is a
  mover.

---

## 8. Files

| file | what it is |
|---|---|
| `ct97cen.cpp` | the census: every integer-kind typespec, keyed by kind/span/name/role/owner/home/`Cast_to_expr`/ranges, payload `sgn=` |
| `sg97.cpp` | the human-readable lister of the same population (one line per object) |
| `score97.py` | MULTISET join of two censuses (BOTH-SAME / MOVED-WRONG / one-sided sets) |
| `reg97.py` | the regression instrument: per-key three-way golden / pristine / candidate intersection (TO-GOLDEN / AWAY-GOLDEN / ADDED / REMOVED) |
| `cen97.sh` | runs the census over every database of a sweep against its OWN golden |
| `pop97.sh` | the DENOMINATOR: every golden cell of the law's shape, corpus-wide |
| `arm97.sh` | one arm, both views, both binaries, official uhdm-cmp per side + buckets |
| `vwide97.sh` | the WIDE boundary over every `.sv`/`.v` under a copy of `tools/probe` |
| `g0…g5_*.sv` | the head repro and the four grids + the negative controls |
| `HEAD_*_Earlgrey_*.cmp` | the official cmp heads before and after, both modes |
| `POP_sl.txt` / `POP_u2r.txt` | the denominator listings |
| `CENSUS.` / `ARMS.` / `GATES.` / `BOUNDARY_*` | the transcripts |
| `PREDICT_R0.txt` | the mover prediction and the NEXT HEAD |
