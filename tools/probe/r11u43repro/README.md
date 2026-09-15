# r11u43 — the unsized fill at a target the raw-shape law does not reach

Base commit `f98e6e2c`, worktree `/tmp/wt_r11u43`.  Pristine binary md5
`0442c5b6d15987b61261f7b3d67a0741` — the OPS-stated main-tree md5 at the base,
reproduced byte for byte by this pass's own build from source.  Law binary md5
`642b03fbd3cf6e2bd518a4168022ebb9`.  The judge is the official `uhdm-cmp`
through `scripts/verify_golden.py`; everything in this directory is
measurement-only.  **`results/*.csv` ARE NOT EDITED BY THIS PASS.**

## HEADLINE — SAY IT LOUDLY

**`packed_array_struct` DOES NOT CONVERT.  ZERO corpus rows convert, and the
scoreboard does not move: uhdm2rtlil stays 780 CMP_EQUAL / 24 CMP_NOTEQUAL /
67 SLANG_REJECT in BOTH MODES, and the Surelog suite stays 474/9 default and
469/8 testflags.**  What the pass buys is:

| | |
|---|---|
| the head this pass was aimed at | **CLEARED in both modes** — the row's LAST cell it was not; a second, DISJOINT head was masked behind it |
| grid arms of legal SV | **32 CONVERT, 0 REGRESS** (84 arms generated, 83 carry a scorable constant; 63 EQ after against 31 before) |
| corpus movers | **2 of 1608** uhdm2rtlil databases, **0 of 1531** Surelog — both `packed_array_struct`, PREDICTED BY NAME before the law binary was run over the corpus |
| the moved bytes | the whole-dump diff of the moved database is **TWO LINES**: `vpiSize:168` → `vpiSize:-1` |

## 1. THE HEAD, RE-MEASURED AT `f98e6e2c`

`uhdm-cmp` on the pristine binary's own database, `grep -c '^LHS:'` = **1**
(one head per run), uhdm2rtlil `packed_array_struct`, **both modes**, identical:

```
LHS:                                       RHS:
decompile:                                 decompile:
constant: , id:27, line:20:25, endln:20:27 constant: , id:34, line:20:25, endln:20:27
|vpiParent:                                |vpiParent:
\_cont_assign: , id:105, line:20:12        \_cont_assign: , id:33, line:20:12
|vpiDecompile:'0                           |vpiDecompile:'0
|vpiSize:-1                                |vpiSize:168
|BIN:0                                     |BIN:0
|vpiConstType:3                            |vpiConstType:3
```

`dut.sv:20` is `assign arr = '0;` onto `my_t [2:0] arr;`, where
`localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b;
logic [7:0] c; };` (56 bits, so the array is 168).  The sides AGREE on the
encoding — `BIN`, ct 3, decompile `'0` — and differ ONLY in `vpiSize`.

**THE OWNING SITE** is `src/ModuleEmit.cpp:29903`, the `!topView` clause
*"A def-view `'0` RHS (alone among unbased-unsized) on a WHOLE-NET LHS sizes
at the LHS width; the elab view then shares this constant"*.  The elab view
shares the def-view object, which is why one write moves both views.

**IT IS NOT THE ROW'S LAST CELL.**  With the head cleared the row is still
`CMP_NOTEQUAL`, on a head that was MASKED behind it and that this pass does
not touch — §7.

## 2. THE PRODUCER, DECODED — the OTHER null typespec

§ `caUnbasedRhsUnboundKeepsRaw25` (pass 24) landed the gen-scope half: the fill
keeps `VpiSize` -1 whenever `CompileHelper::bindVariable` cannot FIND the Lhs,
because `UhdmWriter::writeCont_assign` then calls `adjustSize` with a null
typespec and `CompileHelper::adjustSize` opens with

```cpp
  if (ts == nullptr) { return result; }        // CompileHelper.cpp:4073
```

so the constant is returned UNTOUCHED.  That pass measured module scope and
declared it not-this-law — the bind succeeds there and golden sizes as we do.

The residue is the SECOND null.  `writeCont_assign`
(`Surelog/src/DesignCompile/UhdmWriter.cpp:2100`) seeds
`tps = lhs->Typespec()->Actual_typespec()`, overwrites it from the BOUND
declaration

```cpp
  if (expr* exp = any_cast<expr*>(var))
    if (const ref_typespec* rt = exp->Typespec())
      if (const typespec* temp = rt->Actual_typespec()) tps = temp;
```

and the non-simplified tail calls `adjustSize(tps, …)`
(`UhdmWriter.cpp:2272`).  The bind SUCCEEDS for `arr` — golden's elaborated
declaration is right there — but the declaration Surelog elaborated for
`<named aggregate> [range] name` carries no usable `Actual_typespec` at that
moment, so `tps` is still null and `adjustSize` is still a no-op.  **The reach
boundary of the landed law is `bindVariable`'s question; this pass's boundary
is the DECLARATION's typespec, one step further in the same function.**

That the mechanism is the null and not a width is proved by the grid: golden
writes -1 for an EIGHT-bit target (`g40`) and for a 448-bit one (`g39`) alike.

## 3. THE GOLDEN GRID — 84 arms, four families, every arm's rc

Generators `mkgrid.py` (43 arms), `mkgrid2.py` (17, the write-site face),
`mkgrid3.py` (13, the gate's boundary cells), `mkgrid4.py` (11, the
type-parameter and non-ANSI-port boundary).  `rungold.sh` runs the pinned
v1.87 Surelog and records rc/ERR/FTL/db for EVERY arm (`GOLD*.rc.txt`);
`runours.sh` runs OUR exporter from an EXPLICIT frozen binary path — it never
reads `SLANG_UHDM`, which the harness silently defaults to the main tree.

**Golden: 84/84 rc=0, ERR=0, FTL=0, db=YES.**
**Ours: 83/84 rc=0; `g33` is rc=3, a genuine SLANG_REJECT** — slang refuses
`assign z2 = '0;` onto a bare `e_t` ("no implicit conversion from 'bit[0:0]'
to 'e_t'").  AN ARM WHOSE COMPILE FAILS TEACHES ERROR-RECOVERY, NOT GOLDEN:
`g33` is excluded from scoring and from the law.

Scored tables: `TABLE.pris.all.txt` (golden vs pristine, **EQ 31 / DIFF 51 /
SLANG_REJECT 1**) and `TABLE.law.all.txt` (golden vs law, **EQ 63 / DIFF 19 /
SLANG_REJECT 1**).  Both views of every arm are scored — an arm whose def and
elab views disagree shows two cells.  83 of the 84 arms carry a scorable
constant; `g26` (a `localparam my_t [2:0] P = '0;` read through a ref) yields
none on EITHER side and is absent from both tables, identically.

The 32 arms that CONVERT, by name:
`g02 g03 g04 g09 g28 g31 g32 g35 g38 g39 g40 h03 h08 h09 h12 h13 h15 i05 i06
i07 i08 i09 i11 i13 j01 j02 j04 j05 j06 j08 j09 j11`.
The arms that REGRESS: **none** — the pris-EQ ∩ law-DIFF join is EMPTY.

### 3a. Golden KEEPS THE FILL RAW (`VpiSize` -1) — the target shape

| arm | declaration | golden | pristine |
|---|---|---|---|
| `g02` | `my_t [2:0] s1;` (struct TYPE PARAMETER) | **-1** | 168 |
| `g03` | `my_t [0:0] s2;` | -1 | 56 |
| `g04` | `my_t [1:0][2:0] s3;` | -1 | 336 |
| `g05`/`g06`/`g07` | the same target, `'1` / `'x` / `'z` | -1 | -1 / -1 / -1 (elab `'1` sizes — §6 R0) |
| `g09` | `st_t [2:0] t1;` (module TYPEDEF struct) | -1 | 168 |
| `g31` | `e_t [2:0] z0;` (ENUM) | -1 | 24 |
| `g32` | `un_t [2:0] z1;` (packed UNION) | -1 | 24 |
| `g35` | `sa_t [1:0] z4;` (struct whose member is an array) | -1 | 48 |
| `g38`/`g39`/`g40` | `st_t [1:0]` 112 / `st_t [7:0]` 448 / `s4_t [1:0]` **8** | -1 | 112 / 448 / 8 |
| `g28`/`h08` | `output pk::st_t [2:0] po;` (ANSI port) | -1 | 168 |
| `h09` | `output var pk::st_t [2:0] po;` | -1 | 168 |
| `i08` | `output pk::st_t [2:0] po;` (NON-ANSI port) | -1 | 168 |
| `i09` | `inout pk::st_t [2:0] io;` | -1 | 168 |
| `j05`/`j06` | non-ANSI port with `var` / `wire` spelled | -1 | 168 |
| `h03` | the same target beside an unrelated declaration | -1 | 168 |
| `h13` | the same target driving a submodule port | -1 | 168 |
| `h15` | the same target inside an INTERFACE | -1 | 168 |
| `i05` | the same target in a CHILD instance (elaborated twice) | -1 | 168 |
| `i11` | `assign #1 x = '0;` | -1 | 168 |
| `i13` | a typedef OF a typedef struct | -1 | 168 |
| `j01`/`j09` | a PORT type parameter at its struct DEFAULT | -1 | 168 |
| `j02`/`j04` | `localparam type T = pk::st_t;` (module / child) | -1 | 168 |
| `j08` | a module typedef inside a CHILD instance | -1 | 168 |
| `j11` | **the corpus row verbatim** — `scalar_sig` 56, `arr` **-1** | 56 / -1 | 56 / 168 |

**THE WIDTH NEVER ENTERS.**  `g40` (8 bits) and `g39` (448) are the proof.

### 3b. Golden SIZES, and this emitter already matches — the fence exists for these

| arm | declaration | golden = ours |
|---|---|---|
| `g01` / `g08` / `g17` | `my_t s0;` / `st_t t0;` / an ANONYMOUS inline packed struct — a struct with NO written dimension | 56 |
| `g34` | `sa_t z3;` — the array is INSIDE the struct | 24 |
| `g36` | `typedef st_t [2:0] arr_t; arr_t z5;` — the array is INSIDE THE TYPEDEF | **168** |
| `g37` | `typedef logic [2:0][7:0] pa_t; pa_t z6;` | 24 |
| `i03` | `typedef e_t [2:0] ea_t; ea_t x;` | 24 |
| `i01` | an ANONYMOUS packed struct carrying a written dimension | **168** |
| `g14`/`g15`/`g27`/`h07` | anonymous packed logic: body, multi-dim, ANSI port, `output wire` | 56/24/24/24 |
| `g11` | `b_t u0;` (a LOGIC typedef, no dim) | 8 |
| `h02` | `var st_t [2:0] x;` | **168** |
| `j07` | an OVERRIDDEN type parameter at a target with NO dimension | 56 |
| `g20`–`g25`, `g29`, `g30`, `h14`, `i04` | a gen scope (the landed law), an `always_comb`/`initial` assignment, a bit-select / part-select / member / unpacked-element Lhs | -1 already |
| `g41` / `g42` / `h16` / `h17` | `112'd0` / a bare `0` / `168'b0` / `{168{1'b0}}` — **the CONTROLS that convict the FILL rather than the target** | unmoved |

### 3c. Golden sizes at the ELEMENT's width — MEASURED, DECLINED (R0)

| arm | declaration | golden | ours |
|---|---|---|---|
| `g12`/`g13`/`h10` | `b_t [2:0] u1;` (a LOGIC typedef), and the enum with `wire` | **8** | 24 |
| `g18`/`h05` | `var my_t [2:0] x;` | **56** | 168 |
| `g19`/`h01`/`h04`/`h06`/`i12` | `wire <aggregate> [2:0] x;` in a module BODY (and with a drive strength) | **56** | 168 |
| `i10`/`j03` | a PORT type parameter **OVERRIDDEN** at instantiation | **56** | 168 |
| `j10` | a localparam alias OF an overridden type parameter | **1** | 168 |

These are golden's own second face and it is not one rule — `h02`
(`var st_t [2:0]`) answers **168** where `h05` (`var my_t [2:0]`) answers 56.
The law DECLINES all of them and leaves them EXACTLY as pristine left them,
never moved to a third object (r11u22 R3 verbatim).

### 3d. The SHAPE LISTER beside the census

`nets.py` (`GOLD.shapes.txt`) reads the declaration OBJECT golden elaborated for
every arm, from the database, so the shape is read and not guessed.  It is what
separates 3a from 3c: golden mints a `packed_array_net` / `packed_array_var`
over a struct/union/enum typespec for 3a, and for 3c it drops the dimension in
its own declaration too (`struct_net`).

## 4. THE LAW, AND WHAT IT IS GATED ON

`§ caUnbasedFillPackedAggregateKeepsRaw43`, `src/ModuleEmit.cpp` (the §
comment carries the whole arm table; `caFillPackedAggregateKeepsRaw43` is the
predicate, `off43()` / `cellDbg43()` the A/B switch and the trace).

> A module-scope `cont_assign` whose Rhs is the unbased-unsized fill `'0` and
> whose Lhs is a WHOLE NAME keeps the fill RAW — `VpiSize` -1, `BIN:0`, the
> `'0` decompile — when the declaration is
>   **(1)** a packed array whose dimension is WRITTEN ON THE DECLARATION (the
>   type slang gives the symbol is an UNNAMED `PackedArrayType`; a typedef
>   that IS the array names the type and is declined — `g36`),
>   **(2)** over a NAMED struct / union / enum element (an anonymous element is
>   not a name — `i01`; a named LOGIC typedef is golden's element-width face —
>   `g12`),
>   **(2b)** where an ENUM or PACKED UNION element is named by a PLAIN typedef
>   and NOT reached through a type parameter (added by the verifier r11v43,
>   which measured golden at the ELEMENT's width — 8 — on seven such arms;
>   a STRUCT element is not split this way),
>   **(3)** whose element alias chain does not reach an OVERRIDDEN type
>   parameter (`i10`/`j03`/`j10`), and
>   **(4)** at a write site that is a PORT declaration — ANSI or non-ANSI,
>   whatever keyword it spells — or a module-body data declaration with NO
>   `var` and no net keyword.

Clause (4) is asked with the emitter's existing helpers (`hasVarKeywordDecl`,
and a new `portDeclaredSym43` walk that accepts `ImplicitAnsiPort`,
`ExplicitAnsiPort` and `PortDeclaration`); clause (3) with `typeParamOfAlias`
plus `TypeParameterSymbol::isOverridden()`; clause (2b) with the same
`typeParamOfAlias` walk asked WITHOUT the overridden test
(`aliasAnyTypeParam43`).  The full measurement behind (2b), its cost and the
arms it declines are in `tools/probe/r11v43repro/README.md` §2.

**THE LANDED FILL LAWS' WITNESSES STAY.**  The gen-scope sites
(§ `caUnboundTernaryFold23`, § `caUnbasedRhsUnboundKeepsRaw25`,
§ `genCaUnbasedSizing`) are NOT touched: arms `g20` (gen scope), `h14` (the
target shape inside a gen scope) and `g21`/`g22` (`always_comb` / `initial`)
are `-1` on BOTH binaries and on golden, and `g23`–`g25` (select Lhs) likewise.

### The A/B switch and the NEUTRAL binary

`R11U43_OFF=1` makes the shipped binary take no decision at all.
`neutral.sh` compares the neutral binary's database against the pristine one
arm by arm: **84 same, 0 diff, on all four grids.**  That is what proves the
binary difference is this law and nothing else — and it is what makes the
census a-priori, because `R11U43_CELLDBG=1` computes the CLAIM outside the A/B
switch and so names the movers from the PRISTINE emission.

## 5. THE CENSUS — movers named BY NAME before the law binary ran the corpus

`pred43.py` re-runs the NEUTRAL binary with the trace over the EXACT command
line each corpus row recorded in its own `cmds.txt` (binary from argv, never
from `SLANG_UHDM`).

| corpus | rows with a slang command | CELL trace lines (the POSITIVE CONTROL) | PREDICTED movers |
|---|---|---|---|
| uhdm2rtlil | 1742 | 48 | **`packed_array_struct` default + testflags — 2** (`PRED.u2r.txt`) |
| Surelog suite | 1531 (51 rows never ran slang) | 12 | **0** (`PRED.sl.txt`) |

A census zero needs a positive control, and there are two: the trace is LIVE
on both corpora (48 and 12 lines — the site is reached in the Surelog suite as
well, it simply never claims there), and the same scanner over uhdm2rtlil finds
the two rows it must.

### byteverify, SELFCHECK=1, against this pass's OWN pristine workdirs

```
uhdm2rtlil  databases: patched=1608 pristine=1608   PATH_SETS_IDENTICAL
            MOVER ./default/packed_array_struct-a5048efa/slang.uhdm
            MOVER ./testflags/packed_array_struct-a5048efa/slang.uhdm
            MOVERS: 2 / 1608
            SELFCHECK (every file vs one fixed file): 1607 / 1608 flagged
Surelog     databases: patched=960 pristine=960     PATH_SETS_IDENTICAL
            MOVERS: 6 / 960  — MiniAmiq(def,tf), Scoreboard(def),
                               SeqDriver(def,tf), SimpleUVM(def)
            SELFCHECK: 959 / 960 flagged
```

**The two uhdm2rtlil movers are exactly the two the pass predicted by name.**
The six Surelog movers are the KNOWN pristine UVM coin, and they are attributed
ORDER-BLIND (sorted, path-normalised dumps) rather than waved past:
`Scoreboard/default` differs by **0 lines** (the pure coin) and the other five
by **4 lines each, all of one class** — a `|UINT:<n>` plus its
`|vpiDecompile:<n>`, a line-number constant out of the UVM macro machinery.
**Not one of those 24 lines is a `vpiSize`.**  POSITIVE CONTROL: two runs of the
SAME PRISTINE binary on `MiniAmiq/default` give different md5s
(`6011a0f92935` vs `ee85bcf7dbfd`) and the SAME 4-line class.  The UVM family's
rows stay CMP_EQUAL — `rowheads.sh` reads 0 heads, `cmp rc=0`, for
SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg and for
Earlgrey_0_1 in both modes.  And the moved bytes are
attributed cell by cell, not by the absence of a delta: the path-normalised
whole-dump diff of the moved database is

```
135c135
<       |vpiSize:168
---
>       |vpiSize:-1
```

— **two lines, one cell, the law's cell.**

## 6. WHAT THE PASS DECLINED, AND WHY (R0)

**R0-1 — the `'1` fill at the same target.**  Golden keeps `BIN:1` at -1 in
BOTH views (`g05`, `g10`, `h11`, `i02`); our DEF view already agrees and our
ELAB view sizes (168 `BIN:1…1`, or `UINT:255` at 8 bits).  Declining at
`ModuleEmit.cpp`'s `site=elab1` mint and at the `w27 > 64` re-encode was BUILT
AND MEASURED AS A NO-OP on all four arms — the sized elab object is minted by
a third site this pass did not find (`R11U27_OFF=1` does not remove it either),
so **neither decline ships** and only the traces remain.  They are what will
name the producer next time.

**R0-2 — golden's ELEMENT-WIDTH face** (§3c): the `var`/net keyword in a module
body, a packed dim over a named LOGIC typedef, and an OVERRIDDEN type
parameter.  Nine arms, three sub-rules, and golden contradicts itself across
them (`h02` 168 vs `h05` 56).  DECLINED whole.

**R0-3 — `g42`/`g43`** (a bare `0` and an assignment pattern at this target):
different faces, out of this law's reach.

## 7. THE NEXT HEAD ON THE TARGET ROW — measured, and DISJOINT from this pass

With the fill head cleared, `packed_array_struct` is still `CMP_NOTEQUAL` in
both modes, `grep -c '^LHS:'` = 1, on

```
LHS: <null>
RHS:
decompile:
module_inst: work@packed_array_struct …
|vpiVariables:
\_struct_var: (work@packed_array_struct.scalar_sig) …
\_struct_var: (work@packed_array_struct.arr) …
```

Golden's elaborated view has NO `vpiVariables` at all; it lists

```
|vpiNet: \_struct_net:        (work@packed_array_struct.scalar_sig)
|vpiNet: \_packed_array_net:  (work@packed_array_struct.arr)
```

That is the DECLARATION-SHAPE family (the net-vs-var rule that pass 40 landed
one cell of), not the fill-size family, and the two faces are disjoint: the
whole-dump diff in §5 shows this pass changed nothing about either declaration.
**R0 — `packed_array_struct` converts when a pass makes a packed array over a
struct TYPE PARAMETER elaborate as a `packed_array_net` carrying a `struct_net`
element, and the bare type-parameter struct as a `struct_net`.**

## 8. GATES

All in `GATES.r11u43.txt`, every one green; the canary battery is the current
generation (`canaries.sh` md5 `e1f84a84bf5d`, `ctcan2.sh` `3d3f9a2aa485`,
`canaudit.sh` `b2289875bb3d`, copied from `r10uvm221repro`).
