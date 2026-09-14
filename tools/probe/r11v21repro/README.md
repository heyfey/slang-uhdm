# r11v21 — the adversarial verification of r11u21, and the gate it forced

Base `11416eb7` (matrix-1.87).  Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.
Both binaries rebuilt from source here: pristine md5
`e234b1297f348201f0cf9350691decc9` (the value the brief pins for this base),
r11u21 as submitted `342c26732c9fb64b02ccb31a63de9b4c` (bit-for-bit the md5 the
implementer reported), and the ACCEPTED-WITH-FIX build
`9403ed4f946e712e06fb707697e6e18c`.

VERDICT: **ACCEPT WITH FIX.**  The law, the producer decode, the conversion and
every gate the implementer reported reproduce exactly.  ARM TWO (the taint
strip) over-fired on a face the submitted grid never spelled: **a member read
that sits inside a CALL's arguments**.  Golden KEEPS the parameter's own Rhs
typespec there, pristine already matched golden, and the submitted patch
stripped it — `AWAY-GOLDEN`, judge-visible, on legal SV.

---

## 1. The break, measured

Fifteen new arms (`v1`–`v15`), run through the committed
`tools/probe/r11u21repro/grid.sh` (`PRIS=`/`PAT=`/`G=`), scored with the
committed `pacen21.py` / `dircen21.py`.  Every arm compiled `slrc=0
[ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.

With the SUBMITTED patch:

```
v3   SAME=9  TO=1 AWAY=2 MW=2 SW=2     <- $bits(CFG.u), $bits(CFG.u.sidWidth)
v7   SAME=14 TO=2 AWAY=1 MW=3 SW=0     <- twice(CFG.u.sidWidth)
v9   SAME=7  TO=0 AWAY=1 MW=0 SW=0     <- MINIMAL witness, head-visible
v10  SAME=6  TO=0 AWAY=1 MW=0 SW=1     <- MINIMAL $bits witness
v11  SAME=16 TO=8 AWAY=3 MW=0 SW=1     <- the call-shape matrix
v12  SAME=15 TO=2 AWAY=3 MW=0 SW=4     <- calls mixed with operators
```

`v9` is the head-visible one.  `localparam int D = twice(CFG.u.sidWidth);`,
official `uhdm-cmp`, LHS always golden, ONE head per run:

```
PRISTINE head: an unrelated pre-existing cont_assign residue (24 cmp lines)
PATCHED  head: LHS ref_typespec (work@dut) -> int_typespec 36:14-36:17
               RHS <null>                                   (8 cmp lines)
```

golden carries the ref_typespec on `D`'s constant; the patch removed ours.
The cell census says the same thing with no masking:

```
AWAY-GOLDEN topModules work@dut.D
   G constant dec=6 size=32 ct=7 INT:6 tsname=(work@dut) tsact=int_typespec@36:14
   P constant dec=6 size=32 ct=7 INT:6 tsname=(work@dut) tsact=int_typespec@36:14
   Q constant dec=6 size=32 ct=7 INT:6 tsname=            tsact=
```

## 2. The golden rule, decoded cell by cell (`v11`, `v12`, `v13`)

`A` is a parameter this law folds, `T` one it taints, `m` a direct member read
of the family base, `twice` a user const function.

| written initializer | golden Rhs typespec |
|---|---|
| `$clog2(m)` `$bits(CFG.u)` `twice(m)` | **KEEPS** the parameter's own |
| `$clog2(m) + 1` `twice(m) + 1` `{twice(m)}` | **KEEPS** |
| `$clog2(m + 1)` `twice(m + 1)` `twice(m1 + m2)` | **KEEPS** |
| `twice($clog2(m))` `$clog2($clog2(m))` | **KEEPS** |
| `m + 1` `{m[1:0], …}` `m[0]` | strips |
| `(CFG.derived > 0) ? twice(m) : 1` | strips — on the BARE `CFG.derived` in the condition |
| `$clog2(A)` `$clog2(T)` `twice(A)` `twice(T)` `A + 1` `twice(m) + A` | strips |
| `twice(twice(m))` `twice(twice(twice(m)))` `$clog2(twice(m))` | strips |

So: **a member read reached only through a call's arguments is not a taint
source; a reference to an already-folded or already-tainted PARAMETER is one
wherever it stands.**

## 3. The fix — § paAsmMemberSliceFold21v

`src/ParamEmit.cpp`, ARM TWO's record visitor only: a `CallExpression` depth
counter, and the `MemberAccessExpression` arm accepts a taint root only at
depth 0.  The `NamedValueExpression` arm stays UNGATED, which is what keeps
`$clog2(A)`, `twice(T)`, `twice(m) + A` and the corpus row's own
`NLOG = $clog2(NOUT)` stripping.  Nine lines of gate; nothing else moves.

NOT TAKEN (the last row of the table): golden ALSO strips when a USER
`func_call` is itself an argument of another call, where a SYSTEM call in that
position keeps.  Declining there leaves the pristine answer standing — wrong as
it already was, never newly wrong — and costs four cells of `TO-GOLDEN`
(`v12` `X7`, `v13` `D2`/`D3`/`M1`).  It is R1 below.

## 4. What the fix costs, measured

* the implementer's OWN grid `t1`–`t11`: **every arm's patched dump is
  BYTE-IDENTICAL** to the submitted patch's, and the directional census
  reproduces their table exactly — TO-GOLDEN 32, AWAY-GOLDEN 0, MOVED-WRONG 0;
* the whole uhdm2rtlil corpus, both modes: `byteverify SELFCHECK=1` reads
  **MOVERS 0 / 1608** between the submitted patch and this one.  The gate
  touches only shapes no corpus test carries;
* the conversion is untouched: `param_nested_struct_field_width` 765/39/67 in
  both modes with the fixed binary, and its keyed row census is
  `SAME=10 TO-GOLDEN=4 AWAY-GOLDEN=0 MOVED-WRONG=0 STILL-WRONG=0`;
* with the fix, **AWAY-GOLDEN is 0 on all 15 verifier arms** and on all 11
  implementer arms, and no cell in either grid moves further from golden than
  pristine had it.

## 5. The other faces, and what they say

| arm | face | result with the fix |
|---|---|---|
| `v1` | NARROW / ODD Lhs over an `int` member: `byte`, `byte unsigned`, `shortint`, `bit [3:0]`, `logic [5:0]`, `longint` | 6 TO-GOLDEN, 0 AWAY — `adjustSize`'s `VpiSize(min(orig,size))` with the digits UNTRUNCATED is right in every cell; pristine head cleared, **CMP_EQUAL** |
| `v2` | NON-INTEGRAL and enum Lhs: `real`, an enum through a cast, untyped, `int` | 4 TO-GOLDEN, 0 AWAY — a `real` Lhs takes `adjustSize`'s no-branch road and golden keeps the member's own width, which is exactly what `lhsBits = 0` produces |
| `v3` | selects and `$bits` | the two `$bits` AWAYs are the break above; `BS` (`m[0]`) TO-GOLDEN; `PS` (`m[3:0]`) and `CC` (a concat) MOVED-WRONG — R2 |
| `v4` | INTERFACE holder, and a leaf module instantiated INSIDE a generate block | 6 TO-GOLDEN, 0 AWAY — the law fires correctly for `interface_inst` and for an `InstanceBody` whose enclosing scope is a generate block |
| `v5` | a const function that leaves a member UNWRITTEN | the drain DECLINES (our base's elaborated Rhs is not the 64-bit BIN); 0 TO, 0 AWAY, 0 MW — the bail works |
| `v6` | a packed UNION member in the path, a packed-ARRAY member, a WHOLE-STRUCT member read | union → DECLINED (golden keeps the `hier_path` too); array member and struct member → TO-GOLDEN at the member's own width with the member's own typespec |
| `v7` | taint shapes: ternary, concat, a bare-ref CHAIN base (`CFG2 = CFG`), a func-call argument | the chain base slices correctly; the func-call AWAY is the break; 3 MOVED-WRONG are R2 |
| `v8` | the base OVERRIDDEN with a literal pattern beside a family default, and an overridden NON-local parameter | 3 TO-GOLDEN, 0 AWAY — both override faces decline, as golden does |
| `v14` | the CLONE-NOT-SHARE probe: the folded parameter is ALSO read by a packed range, by an instance OVERRIDE actual and by a cont-assign | 1 TO-GOLDEN, 0 AWAY, 0 MW — mutating the parameter's own Rhs constant leaves `u0.P`'s copy byte-identical on both binaries, so nothing is shared across the write |
| `v15` | a MODULE-LOCAL struct typedef built by a MODULE-LOCAL const function (no package anywhere) | 2 TO-GOLDEN, 0 AWAY — **CMP_EQUAL** |

## 6. Residues, ranked

* **R1 — a USER `func_call` nested inside another call.**  `twice(twice(m))`,
  `$clog2(twice(m))`: golden strips the Rhs typespec, we keep it.  A SYSTEM
  call in the same position (`twice($clog2(m))`, `$clog2($clog2(m))`) keeps, so
  the distinguisher is the INNER call's kind, not the depth.  Witnesses `v13`
  `D2`/`D3`/`M1` and `v12` `X7`; four cells, one shape.
* **R2 — a PART SELECT of a member read.**  `v3` `PS` (`CFG.u.sidWidth[3:0]`):
  golden ignores the select and emits the WHOLE member slice (32 digits, size
  32, the member's own bare ref).  A BIT select (`v3` `BS`) is a different
  answer again (`1'b0`, size 1, no typespec) and this law already gets it
  right.  Both are ARM ONE territory, not ARM TWO's.
* **R3 — ARM TWO's partial cells.**  Where golden's constant has no typespec at
  all, the strip is right but the ENCODING is still ours: `v7` `B`/`C`/`F` and
  `v3` `CC` keep a `UINT` where golden renders `INT`, or a truncated
  `vpiDecompile`.  Five MOVED-WRONG cells in total across `v3` and `v7`; four
  of the five have a STRICTLY SMALLER failing-cell set than pristine (the
  typespec cell moves onto golden and nothing else moves), and the fifth (`PS`)
  moves no cell further away.  No cell anywhere in either grid moves away from
  golden.
* **R4 — `$bits` in the DEFINITION listing.**  `v10`/`v11`: golden folds
  `$bits(CFG.u)` to a constant in `allModules` too; we keep the
  `sys_func_call`.  Pre-existing, identical on all three binaries.

## 7. Files

| file | what it is |
|---|---|
| `v1`–`v15` | the adversarial arms; run them with the committed `r11u21repro/grid.sh` (`PRIS=`, `PAT=`, `G=`) and score with `r11u21repro/pacen21.py` / `dircen21.py` |

`v9` and `v10` are the MINIMAL regression witnesses and must stay
`AWAY-GOLDEN=0`; `v11` is the call-shape matrix the gate is decoded from.
