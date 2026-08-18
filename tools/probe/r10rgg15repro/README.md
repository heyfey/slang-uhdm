# r10rgg15 — § unbasedZeroFillOvDeclWidth15 + § unbasedFillOvKeepsDefaultSpan15: an UNSIZED FILL written as a parameter OVERRIDE ACTUAL is sized at the FORMAL's declared width and keeps the DECLARATION DEFAULT's span

**MEASUREMENT-ONLY directory.**  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `5d8ff29`.**  `results/*.csv` was READ ONLY and is untouched.
**Rggen still does NOT pass `uhdm-cmp`, and NO CORPUS ROW WAS CONVERTED** —
this pass says so up front.  The production change is four statements in
`src/ParamEmit.cpp`; everything else here is instrument or evidence.

Target: `default:Rggen`'s official head after r10rgg14 (64 cmp lines, 1 head at
`5d8ff29`) — the `param_assign` Rhs constant of `INITIAL_VALUE` in
`work@rggen.u_block_0.g_register_13.g_bit_field_1.u_bit_field`, declared
`parameter bit [WIDTH-1:0] INITIAL_VALUE = '0` at
`rggen-sv-rtl/rggen_bit_field.sv:5:61` and overridden `.INITIAL_VALUE ('0)` at
`rggen-sample/block_0.sv:2053`, with `WIDTH = 2` in that instance:

```
golden : constant  BIN:0  vpiSize  2  ct 3  vpiDecompile "'b0"  spanned 5:61-5:63
ours   : constant  BIN:0  vpiSize 64  ct 3  vpiDecompile "'b0"  NO SPAN AT ALL
```

**RESULT.  THE HEAD IS CLEARED, and it was a family of ONE.**

* `uhdm-cmp` (official, Rggen default): the head object moves to a **DIFFERENT
  FAMILY** (§ 9, R0) — 64 → 683 cmp lines.  A cmp line count is the head
  OBJECT's decompile size, so that number is **not** a progress metric and is
  not reported as one.  The arbiters are the whole-dump diff and the census.
* **The whole-dump path-normalised diff of Rggen, base vs patched, is 3 removed
  / 3 added lines over 1,580,844 dump lines a side — the head constant's
  `vpiSize` and its span, and NOTHING ELSE** (`DUMPDIFF_rggen_base_vs_pat.txt`).
* The head object is now **byte-identical to golden** on every field the dump
  prints (span, decompile, size, value, const type).
* Census of every `param_assign` in the whole Rggen database, all three views
  (7,214 golden keys / 7,218 ours): **FIXED 1, BROKEN 0, MOVED-STILL-WRONG 0**;
  golden-vs-golden calibration 7,214 / 7,214 identical, negative control
  (golden vs pristine ours) 12 differing — the instrument is proved able to see.
* Corpus: **0 byte movers over 1,358 uhdm2rtlil databases** and **1 byte mover
  over 956 surelog databases — `default/Rggen`, the target, and nothing else**.
  **Both numbers were PREDICTED BY NAME from the PRISTINE databases BEFORE the
  patched sweep existed** (`PREDICT_db_*.txt`).
* **0 differing ROWS** in either corpus, either mode, status AND dump column,
  against the committed baselines AND against my own base sweeps.
* Wide boundary over a COPY of the WHOLE `tools/probe` tree, no path filter:
  **3,046 sources, 2,918 identical, 3 movers — all three this pass's OWN grid
  cells**, 0 asymmetries (`BOUNDARY.txt`, `BOUNDARY_POSITIVE_CONTROL.txt`).

---

## 1. THE HEAD, decoded from the PRISTINE cmp LOG and the GENERATED Compare

`HEAD_R0_BEFORE_default_Rggen.cmp`, verbatim (LHS is ALWAYS golden):

```
LHS:
constant: , id:222437, line:5:61, endln:5:63
|vpiParent:  \_param_assign: , id:222436, line:5:33, endln:5:63
|vpiDecompile:'b0  |vpiSize:2   |BIN:0  |vpiConstType:3
|vpiTypespec: \_ref_typespec: (work@rggen.u_block_0.g_register_13.g_bit_field_1.u_bit_field)
              |vpiActual: \_bit_typespec: , id:8379, line:5:13, endln:5:28
RHS:
constant: , id:148116                       <- NO line/endln AT ALL
|vpiParent:  \_param_assign: , id:148115, line:5:33, endln:5:63
|vpiDecompile:'b0  |vpiSize:64  |BIN:0  |vpiConstType:3
|vpiTypespec: \_ref_typespec: (work@rggen.u_block_0.g_register_13.g_bit_field_1.u_bit_field)
              |vpiActual: \_bit_typespec: , id:245600, line:5:13, endln:5:28
```

**THE FAILING FIELD IS `VpiSize`, AND NOTHING ELSE.**  Read the order off the
generated code, not off the dump.  `param_assign::Compare`
(`UHDM/build/generated/src/param_assign.cpp`) reads `VpiConnByName`,
`VpiOverriden`, then `SafeCompare(Rhs)`; `constant::Compare` calls
`expr::Compare` FIRST and only then its own `VpiConstType`; `expr::Compare`
reads

```
VpiDecompile   "'b0" == "'b0"    -> passes
VpiSize        2      vs 64      -> FAILS HERE
Typespec       (never reached)
```

`VpiFile`/`VpiLineNo`/`VpiColumnNo` are read by **no** generated `Compare`, so
the missing span is INVISIBLE to the judge and is scored by the DUMP alone.
Both sides' `param_assign` span `5:33-5:63`, i.e. the DECLARATION — this is an
elaborated copy of the declaration, not a copy of the override site, on BOTH
sides, and that is the first clue to the whole law.

**THE OWNER, and which of the brief's two shapes it is.**  The brief asked
whether this is (a) a declaration DEFAULT re-sized to the declared width or
(b) an OVERRIDE actual sized to the formal.  `rggen-sample/block_0.sv:2047-2060`
settles it: `g_register_13.g_bit_field_1` instantiates

```systemverilog
rggen_bit_field #(
  .WIDTH              (2),
  .INITIAL_VALUE      ('0),     // <- block_0.sv:2053, an OVERRIDE ACTUAL
  ...
) u_bit_field ( ... );
```

so it is **(b), an override actual** — and yet golden's constant is spanned at
the DECLARATION's `'0` (`rggen_bit_field.sv:5:61`), not at the override's.
That is not a contradiction; it is the mechanism (§ 3).  It is also the ONLY
`.INITIAL_VALUE ('0)` in the whole design — every other `rggen_bit_field`
instantiation passes a `localparam INITIAL_VALUE` or a sized `2'h0`
(`grep -n "INITIAL_VALUE *('0)" rggen-sample/*.sv` returns exactly one line).

---

## 2. THE CENSUS — golden vs ours over EVERY `param_assign`, ALL THREE VIEWS

`fcensus15.cpp` (build with `build15.sh`) reads a `.uhdm` directly with the same
static UHDM the sweeps and `uhdm-cmp` use, and emits one row per `param_assign`
in every view — `DEF` (`uhdmallModules` + `uhdmallInterfaces`), `ELAB`
(`uhdmtopModules`, gen scopes walked) and `PKG` (`uhdmallPackages`) — keyed
(view, owning scope FULL PATH, Lhs name).  The payload is exactly what decides
this pass:

* the Rhs's Compare-visible SHAPE `const(<value>,sz=,ct=,dec=)` plus **`/LOC`
  vs `/LL`** — does the constant carry a span at all;
* the **DECLARED TYPE** of the parameter it initialises (kind, signedness,
  range bounds, localparam-vs-parameter), because the brief's axis
  "`bit[N-1:0]` with N a parameter / literal width / logic / int / untyped" is
  only visible there;
* the Rhs's own `L:<file>:<line>:<col>` — which tells a DECLARATION-spanned
  constant from an OVERRIDE-SITE-spanned one WITHOUT a second instrument;
* `OV:` = `param_assign->VpiOverriden()`.

`vpiFile` is printed as a BASENAME only, so the key survives a workdir move
(dump paths embed the workdir — RESUME §9).  `UhdmName()`'s `string_view` is
materialised before every `printf` (the trap that turned r10rgg11/12/13's
census files binary and made `grep` print nothing).

**CALIBRATION FIRST, as the campaign requires.**  Golden censused twice: 7,214
rows, byte-identical, join differing = 0.  NEGATIVE CONTROL: golden vs pristine
ours = 12 differing keys — the instrument is not blind.

### Rggen, golden vs pristine ours, whole database

```
gold keys 7214   ours keys 7218
missing-ours 0   extra-ours 4          (all four under ...g_register_15.u_register.bus_if -> R0)
shape-diff keys 8
   1  G const(BIN:0,sz=2,ct=3,dec='b0)/LOC   O const(BIN:0,sz=64,ct=3,dec='b0)/LL   <- THE HEAD
   7  G const(UINT:<n>,sz=7,ct=9,dec=<n>)    O const(UINT:<n-128>,sz=7,ct=9,...)    <- R-B, the signed
                                                                                        START_ADDRESS rows
```

**The head's family is a family of ONE.**  There is exactly one row in the whole
Rggen database whose Rhs is our loc-less 64-bit `BIN:0` fill, and golden's
counterpart is the only `BIN:0 sz=2` in the database.

### The corpus census (the PREDICTOR), run on PRISTINE databases

`predict15.py` walks a whole `verify_golden` workdir, censuses OURS, keeps every
`param_assign` Rhs constant that carries NO line number (`/LL` — every constant
this pass's emitter site makes is loc-less today, so the candidate set is
MEASURED, not guessed), and prints golden's row beside it.

```
uhdm2rtlil  TESTS=1462  SKIP-NOFILE=104  CANDIDATE-ROWS=30   DIFF=0
surelog     TESTS=1573  SKIP-NOFILE=617  CANDIDATE-ROWS=285  DIFF=1  <- default/Rggen, the head
```

Filtered to the four shapes this emitter site can produce (`'b0`, the all-ones
`UINT` mask, `'bX`, `'bZ`) the candidate set across BOTH corpora is:

```
u2r  unbased_unsized_param  (both modes)  sp13 'b0 / sp14 UINT:2^64-1 / sp15 'bX / sp16 'bZ
sl   Rggen                  (default)     INITIAL_VALUE 'b0
```

**and nothing else.**  That is the whole reach of this law in 2,314 comparable
rows, and it is what makes the fence below the entire risk surface.

---

## 3. THE FENCE, FOUND FIRST AND EXPLAINED — `unbased_unsized_param`

The brief demanded the u2r CMP_EQUAL rows carrying our loc-less 64-bit fill be
found FIRST and explained.  They are `uhdm2rtlil/test/.../unbased_unsized_param`
(**both modes, CMP_EQUAL, dump `match`**):

```systemverilog
module set_param #( parameter logic [63:0] VALUE ) ( output logic [63:0] out );
...
    set_param #('0) sp13(o13);   set_param #('1) sp14(o14);
    set_param #('x) sp15(o15);   set_param #('z) sp16(o16);
```

Golden and ours, ELAB, byte for byte:

```
sp13 VALUE  BIN:0  sz 64  ct 3  dec 'b0                     NO SPAN   (both sides)
sp14 VALUE  UINT:18446744073709551615 sz 64 ct 9            NO SPAN   (both sides)
sp15 VALUE  BIN:X  sz -1  ct 3  dec 'bX                     NO SPAN   (both sides)
sp16 VALUE  BIN:Z  sz -1  ct 3  dec 'bZ                     NO SPAN   (both sides)
```

**Golden accepts our flat 64 there for one reason and one reason only: the
formal is 64 bits wide.**  And golden is LOC-LESS there for a second, separate
reason: `VALUE` has **no written default**.  Both halves of the accident are
now the two halves of the law, and both are re-measured on purpose-built cells
where they cannot coincide (§ 4, grid `g5`: the same four fills into a
**6-bit** formal, with and without a default).

---

## 4. THE GOLDEN GRID — five cells, 180 measured golden rows

`cells/g{1..5}`, run with `cell15.sh` (surelog `-parse`, slang
`--single-unit`, mirroring `verify_golden`'s `default` mode).  The full golden
tables are in `GOLDEN_SHAPES_grid.txt`; the deciding ones:

### g1 — an unsized fill as a DEFAULT, never overridden, 24 target types

```
DEF  (every target)                    BIN:0  sz -1  ct 3  dec "'0"      /LOC
ELAB bit[7:0] / logic[7:0] / byte      BIN:0  sz  8  ct 3  dec "8'b0"    /LOC
ELAB bit[1:0] / bit[0:0] / bit / logic BIN:0  sz w  ct 3  dec "<w>'b0"   /LOC
ELAB int / int unsigned / integer      BIN:0  sz 32  ct 3  dec "32'b0"   /LOC
ELAB bit[32:0] / bit[64:0]             BIN:0  sz 33 / 65   dec "<w>'b0"  /LOC
ELAB untyped `parameter A_unt = '0`    BIN:0  sz -1  ct 3  dec "'b0"     /LOC
ELAB '1 into bit[7:0]                  UINT:255 sz 8 ct 9                /LOC
```

### g2 / g3 / g5 — the SAME fill as an OVERRIDE ACTUAL

```
                                 golden ELAB
'0 -> bit[7:0]                   BIN:0  sz  8  ct 3  dec "'b0"    <- UNSIZED decompile
'0 -> bit[1:0]                   BIN:0  sz  2  ct 3  dec "'b0"
'0 -> bit[5:0]                   BIN:0  sz  6  ct 3  dec "'b0"
'0 -> logic[5:0] / logic[7:0]    BIN:0  sz  6 / 8   dec "'b0"
'0 -> int                        BIN:0  sz 32  ct 3  dec "'b0"
'0 -> untyped                    BIN:0  sz 32  ct 3  dec "'b0"
'0 -> bit[64:0]                  BIN:0  sz 65  ct 3  dec "'b0"
'0 -> bit[W-1:0], W=1/2/33/65    BIN:0  sz 1/2/33/65 dec "'b0"
'1 -> bit[5:0]                   UINT:63 sz 6 ct 9
'x / 'z -> bit[5:0]              BIN:X / BIN:Z  sz -1  dec "'bX" / "'bZ"
```

**THE DECOMPILE IS THE DISCRIMINATOR AND IT IS FREE.**  A NON-overridden `'0`
reads `"<w>'b0"`; an OVERRIDE `'0` reads the UNSIZED `"'b0"`.  Grid `g3` pairs
them in one file: `u_w2` (W=2, `P` left at its default) reads `2'b0`, `u_w2z`
(W=2, `.P('0)`) reads `'b0`, same parameter, same width, same instance
template.  We already had the decompile right on both sides; only the SIZE was
wrong, which is why the head failed on `VpiSize` and not before it.

### g5 — THE SPAN AXIS, both halves in one file

```
                     golden ELAB span of the Rhs constant
g5_wd  (formal HAS a written default 6'h2a)
   .D0('0)   BIN:0 sz 6 "'b0"    LOC  g5.sv:7:30   <- the DEFAULT's span
   .D1('1)   UINT:63 sz 6        LOC  g5.sv:8:30
   .Dx('x)   BIN:X sz -1 "'bX"   LOC  g5.sv:9:30
   .Dz('z)   BIN:Z sz -1 "'bZ"   LOC  g5.sv:10:30
g5_nd  (formal has NO default)
   .N0('0)   BIN:0 sz 6 "'b0"    NO SPAN
   .N1('1)   UINT:63 sz 6        NO SPAN
   .Nx('x)   BIN:X sz -1         NO SPAN
   .Nz('z)   BIN:Z sz -1         NO SPAN
   .M0('0) -> logic[5:0]  sz 6   NO SPAN
   .K0('0) -> int         sz 32  NO SPAN
```

**The formal's DEFAULT is the whole span discriminator**, and the u2r fence
supplies the no-default half for real.

---

## 5. THE LAW, and WHY SURELOG DOES IT

> **§ unbasedZeroFillOvDeclWidth15** — an unbased-unsized `'0` written as a
> parameter OVERRIDE ACTUAL is a `BIN:0` `vpiBinaryConst` whose `vpiSize` is
> **the FORMAL's own declared width at that instance**, with the UNSIZED
> `"'b0"` decompile.  Not a flat 64.
>
> **§ unbasedFillOvKeepsDefaultSpan15** — that constant (and the `'1`, `'x`,
> `'z` ones beside it) is the DECLARATION DEFAULT's own object rewritten in
> place, so it carries **the DEFAULT expression's span**.  A formal with NO
> written default has no such object and golden's is LOC-LESS.

Decoded from `~/git-repos/Surelog`, not guessed:

1. `CompileExpression.cpp:650` — `VObjectType::paNumber_Tick0` (`grammar/
   SV3_1aLexer.g4:43 TICK_0: '\'0'`) mints `BIN:0`, `vpiBinaryConst`,
   **`VpiSize(-1)`**, `VpiDecompile("'0")`, and `fC->populateCoreMembers(child,
   child, c)` — **that call is where golden's span comes from**, and it is on
   the DECLARATION's token because that is the expression being compiled.  Our
   DEF view already matches this exactly (`BIN:0 sz -1 dec "'0" /LOC`, both
   sides, § 2).
2. `CompileHelper::adjustSize` (`CompileHelper.cpp:3949`) — with
   `orig_size == -1` and `c->VpiConstType() == vpiBinaryConst`, the
   `bit_typespec` / `logic_typespec` arms leave the value alone (the `logic`
   arm needs `orig_size > size`; `bit` has no arm at all), and the function
   ends in its **`if (orig_size == -1)` tail**: it re-renders ONLY when
   `uval == 1` (that is the `'1` → all-ones `UINT` mask row, and the
   `size > 64` → BIN-ones row), and then unconditionally
   **`c->VpiSize(size)`** with `size = Bits(<the formal's typespec>)`.  For
   `bit [WIDTH-1:0]` with `WIDTH = 2` that is **2**.
3. `StValue::decompiledValue()` (`Expression/Value.cpp:1881`) renders a Binary
   value with `m_size == -1` as `"'b" + m_value` — `"'b0"`.  That is why an
   OVERRIDE reads `"'b0"` (its Value round-trips at size -1) while a
   non-overridden DEFAULT, whose `DesignElaboration.cpp:2540` path calls
   `fromVpiValue(c->VpiValue(), c->VpiSize())` AFTER `adjustSize` has already
   written the target width, reads `"<w>'b0"`.
4. The DECLARATION-spanned `param_assign` and Rhs on BOTH sides of every
   elaborated Rggen row (§ 2's `L:` column: `WIDTH` is `OV:1` and still spanned
   at `rggen_bit_field.sv:4:61`) is the same in-place-rewrite the campaign
   already recorded for rgg10 — Surelog elaborates by rewriting the
   declaration's own objects, so an override's value lands on the
   declaration's constant.

### WHY earl63 / earl52 DID NOT COVER THIS CELL

`§ constCallFoldAdjustSize63` owns the {producer, `adjustSize`} pipeline for a
**user CONST-CALL** initializer; `§ paramInitAdjustSizeElab52` owns it for a
**literal-originated NON-overridden DECLARATION** initializer, and ships gated
`topView && !defViewOrig9 && !inPackage && !funcScope && !overridden &&
tk52 == SrlgTsK::Int` (its F3 fence: `int` targets only, because every other
target kind's `adjustSize` arm is a no-op and five surelog tests regressed on
the ungated form).  **This cell is `overridden` and its target is `bit`** — it
is excluded by earl52's `!overridden` gate on one axis and by its `Int`-only
F3 fence on the other, twice over.  The override path's own encoder
(`ovEnc8` + `srlgAdjustSize`, `ParamEmit.cpp:5605/3327`) never sees it either:
the unbased-unsized override actual is intercepted EARLIER, by the dedicated
`unbasedOvConst` block at `ParamEmit.cpp:5936` (the mint added for
`unbased_unsized_param` sp13..sp16), which `continue`s before the
`ovEnc8`/`srlgAdjustSize` block at 6634 can run.  **That block is where our
loc-less 64-bit `BIN:0` is minted, and it is the only place in the emitter that
writes `VpiDecompile("'b0")` with `VpiSize(64)`.**

---

## 6. THE PATCH — four statements in `src/ParamEmit.cpp`

In the `unbasedOvConst` mint (`§ 5` above):

```c++
else if (bit9.value == 0) {
    c9->VpiDecompile("'b0");
    uint64_t zw15 = ps.getType().getBitWidth();     // was: VpiSize(64)
    c9->VpiSize(zw15 > 0 ? (int32_t)zw15 : 64);
    c9->VpiValue("BIN:0");
    c9->VpiConstType(vpiBinaryConst);
}
```

and, on the shared binding tail of all three arms (`'0`, `'1`, `'x`/`'z`):

```c++
c9->VpiParent(pa);
if (hasDefault && defaultSyn)
    setLoc(c9, defaultSyn->sourceRange());
```

`hasDefault`/`defaultSyn` are the function's own existing
`paramDefaultSyn(ps)` pair (`ParamEmit.cpp:3846-3858`) — the DECLARATION's
default syntax, which is exactly the object golden's span comes from.  The
`0 -> 64` fallback preserves the pre-patch behaviour for a formal whose type
has no bit width, and no measured cell reaches it.  The `'1` arm's width
(`ps.getType().getBitWidth()`) and the `'x`/`'z` arm's `-1` were ALREADY right
and are untouched.

---

## 7. THE SCORE

### Grids, order-blind 3-way ({golden, pristine, patched}), `score15.py`

```
g1   shape/STILL-OK=44  shape/STILL-WRONG=4   span/STILL-OK=48
g2   shape/FIXED=15     shape/MOVED-STILL-WRONG=1  shape/STILL-OK=16  span/FIXED=16 span/STILL-OK=16
g3   shape/FIXED=6      shape/STILL-OK=30     shape/STILL-WRONG=9    span/FIXED=6  span/STILL-OK=39
g4   shape/STILL-OK=22  shape/STILL-WRONG=4   span/STILL-OK=26
g5   shape/FIXED=7      shape/STILL-OK=15     shape/STILL-WRONG=2    span/FIXED=4  span/STILL-OK=20
----------------------------------------------------------------------------------
TOTAL  shape FIXED=28  BROKEN=0   span FIXED=26  BROKEN=0
```

**BROKEN = 0 in every cell, on both the shape and the span.**  The one
`MOVED-STILL-WRONG` is `g2 u_ones B_b65` — a `'1` override into a **65-bit**
formal, where golden renders `BIN` all-ones (`adjustSize`'s `size > 64` branch)
and we render a `UINT`.  It was wrong before this patch (loc-less UINT) and is
wrong after (located UINT): the span half moved to golden, the encoding half did
not.  It is ranked R-F below, it has **zero corpus reach** (the predictor found
no row of that shape in either corpus), and this pass deliberately does not
touch the `'1` encoding.

### Rggen, whole-database census, 3-way

```
FIXED 1   BROKEN 0   MOVED-STILL-WRONG 0
FIXED ELAB|PA|work@rggen.u_block_0.g_register_13.g_bit_field_1.u_bit_field|INITIAL_VALUE
   G const(BIN:0,sz=2,ct=3,dec='b0)/LOC
   P const(BIN:0,sz=64,ct=3,dec='b0)/LL
   Q const(BIN:0,sz=2,ct=3,dec='b0)/LOC
```

### Whole-dump diff, Rggen, base vs patched (`DUMPDIFF_rggen_base_vs_pat.txt`)

```
1,580,844 dump lines a side; 3 removed / 3 added:
  <                 \_constant:                        >  \_constant: , line:5:61, endln:5:63
  <                   |vpiSize:64                      >    |vpiSize:2
  <                 \_constant:                        >  \_constant: , line:5:61, endln:5:63
```

---

## 8. THE GATES (all mandatory, all run, all green)

| gate | result |
|---|---|
| (1) both binaries built, `-j 2` | base `74963e213f7f98da45ceaec21ee541e2`, patched `561e5694d8b9024a74719993ac67dc79`, both frozen `chmod 555` at `/tmp/r10rgg15_bin/` BEFORE any sweep |
| (2) goldens | base **23 PASS / 0 FAIL**, patched **23 PASS / 0 FAIL**, `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (negative control), `SLANG_UHDM` exported explicitly per leg |
| (3) uhdm2rtlil, both modes | **1462 rows = 1358 CMP_EQUAL / 100 SLANG_REJECT / 4 SURELOG_FAIL** (= 679/50/2 per mode); `ct15rows` vs my own base sweep **0 differing**; testflags slice vs the committed `results/gate_uhdm2rtlil.csv` **0 differing over 731** (status AND dump) |
| (4) surelog, both modes | **1588 rows** = 936 CMP_EQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 20 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM; `ct15rows` vs my base sweep **0 differing over 1588**; vs the committed `results/golden_surelog.csv` **0 differing over 1588**.  **NO ROW WAS CONVERTED — `Rggen/default` is `CMP_NOTEQUAL` before and after, and `results/*.csv` was not edited.** |
| (5) byteverify `SELFCHECK=1` | selfcheck base-vs-base **0 movers** on both corpora (the comparator is live); u2r **0 movers / 1358**; surelog **1 mover / 956 = `default/Rggen`** — the ONLY mover, PREDICTED BY NAME beforehand.  The documented `Scoreboard` COIN did not flip this run. |
| canaries | `canaries.sh` vs committed surelog baseline: **ok=52 changed=0 absent=0**; vs my own both-mode u2r base: **ok=16 changed=0 absent=0**.  `ctcan2.sh` (`EXPECT_UNKNOWN` set per corpus): **ok=58 / ok=2, changed=0**, PASS both.  `canaudit.sh canaries.sh ctcan2.sh`: **audited=29 UNCOVERED=0 FENCE-BREACH=0**, and its two self-tests fired. |
| byte-identity pins | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` `e3e354129d5a`/`73a10e8217e5`, `YosysOldOr` `d68e0796d62c`, **`SVSwitch` `4842211c4030`**, **`YosysVerx` `6ccda350c24a`** — all byte-identical base vs patched, both modes |
| boundary (both views, full `tools/probe` COPY, no path filter) | **files=3046 identical=2918 MOVERS=3 uncompilable=125 asymmetries=0**; the three movers are this pass's own `cells/g2`, `cells/g3`, `cells/g5` (the positive control).  Every `r10rgg1..14`, `r10vrgg2..14`, `r10earl45..63`, `r10uvm*`, `r10buvm*` and `r10sd*` arm is byte-identical. |

Every `cmds.txt` was audited by BINARY PATH (`grep -c 'slang-uhdm-pat'`), not
by the string `slang-uhdm`, and `GOLDEN_DEFER` was never set.

---

## 9. RESIDUES AND THE NEXT HEAD

**R0 — THE NEW HEAD of `default:Rggen` (683 cmp lines, 1 head).  A SPURIOUS
OBJECT, and the census already named it: the FOUR `extra-ours` keys.**

```
LHS: <null>
RHS: interface_inst: work@rggen_bus_if
       (work@rggen.u_block_0.g_register_15.u_register.bus_if), id:152571,
       file:.../rggen-sample/block_0.sv, line:2289:0
     |vpiParent: module_inst work@rggen_external_register
                 (work@rggen.u_block_0.g_register_15.u_register)
```

`LHS: <null>` with a full RHS is the SINGULAR `SafeCompare` overload's MIRROR
(RESUME §9): **golden has NOTHING at that slot and we emit an
`interface_inst`.**  `rggen_external_register` (the single
`g_register_15.u_register`, `block_0.sv:2289`) declares a `rggen_bus_if bus_if`
that golden does not materialise as an elaborated interface instance at all;
the whole-database `param_assign` census sees it as exactly four EXTRA rows
(`ADDRESS_WIDTH`, `BUS_WIDTH`, `RGGEN_ACCESS_DATA_BIT`,
`RGGEN_ACCESS_NON_POSTED_BIT` under `...u_register.bus_if`), which is r10rgg13's
R-B item 2 promoted to R0 by this pass.  It is a *spurious-object* head, not an
encoding one — the fix is to not emit the instance (or to not list it), and the
census key set is the acceptance test: **extra-ours must go 4 → 0.**

**R-A — still the biggest Rggen family, 810 census rows, untouched and now the
biggest ENCODING piece.**  Golden's ELAB view keeps `op11[ref(WIDTH), UINT:1]`
in gen-scope interface variable RANGE BOUNDS where we fold to `const INT:<n>`.
This pass re-confirms it from a third angle: the head's own declared-type tag
carries `R[op11[ref(WIDTH),const(UINT:1,...)]..const(UINT:0,...)]` on BOTH
sides, so the range bound is already shared correctly where the parameter's own
typespec is concerned — R-A is about the INTERFACE VARIABLE's range, a different
owner.  **Re-ranked: R-A is now the largest untaken family and outranks R-C.**

**R-B — the 7 signed `START_ADDRESS` rows, now the SECOND encoding item and the
last `param_assign` shape wrong in Rggen.**  Golden `UINT:84 / 80 / 76 / 72 /
68 / 64 / 88` at `sz=7`; we render the same 7-bit pattern SIGNED
(`UINT:-44 / -48 / -52 / -56 / -60 / -64 / -40`).  A 7-bit value with the MSB
set rendered as a negative decimal is a `srlgOvRender`/`toString` signedness
question, one owner, seven rows, and after this pass it is **the only remaining
`param_assign` shape difference in the whole 7,214-row Rggen census**.  Ranked
ABOVE R-C: it is a pure encoding fix with a census that scores it exactly.

**R-C — the 24 `hier_path` port rows** (rgg14's R-C, `block_1.sv:356`'s
`.i_sw_write_enable (register_if[6+7*i+6].value[0+1*l+:1])`): 48 objects on our
side, 24 on golden's, and the fix is STRUCTURAL (the first element has to become
a `bit_select` with a folded `vpiIndex`), not a constant re-encoding.
**Unchanged, and now ranked BELOW R-B** because R-B is seven rows of pure
encoding against R-C's structural rebuild.

**R-D — `decompileHelper` SPACING in a kept-symbolic hier_path name.**
Unchanged (rgg14's R-D, uvm92/94's family).

**R-E — a gen-scope LOCALPARAM index in a cont_assign IS folded by golden**
(rgg14's R-E).  **Re-ranked UP**, because this pass's grid `g4` found a
SECOND, independent gen-scope defect that shares its scope: a gen-scope
`localparam bit [W-1:0] L_gen = '0` reads golden `BIN:0 sz w dec "<w>'b0"`
while we emit `UINT:0 dec "0"` (4 cells in `g4`, both `u_d.g` and `u_2.g`) —
and the same module's BODY localparam is already correct on our side.  The
gen-scope param_assign emitter is diverging from the module-body one on more
than one law; taking them together is worth more than either alone.

**R-F — NEW, and deliberately abstained.**  The `'1` override into a formal
WIDER THAN 64 BITS: golden renders `BIN` all-ones at the formal's width
(`adjustSize`'s `size > 64` branch, `CompileHelper.cpp:4113`), we render a
`UINT` decimal.  Measured on `g2 u_ones B_b65` and `g3 u_w65z Q` and on the
DEFAULT side too (`g1 A_b65o`).  **Zero corpus reach** — the predictor found no
row of this shape in either corpus — which is why it was left; `cells/g2` and
`cells/g3` are the arms it should be developed on.

**R-G — NEW, measured, not fixed.**  A BASED-unsized override actual
(`.Db('b0)`, `.Dh('h0)`) is a slang `IntegerLiteral`, takes a different arm, and
is wrong in a third way: golden reads `'b0` → `BIN:0 sz 1 dec "1'b0"` (the
literal's OWN size, not the formal's) and `'h0` → `HEX:0 sz 6 dec "'h0"` (the
formal's size with an UNSIZED decompile), where we emit `UINT:0 sz 6 dec "0"`
for both (`g5 u_wd Db/Dh`).  Also `g1 A_b8l`: `parameter bit [7:0] X = 1'b0`
reads golden `sz 1`, ours `sz 8`.  This is the
`§ unsizedBasedTypedParamElab` family, not this one.

## 10. THE INSTRUMENTS

```
build15.sh      build fcensus15 against the STATIC ~/.local UHDM
fcensus15.cpp   the param_assign census, DEF + ELAB + PKG (§ 2)
predict15.py    the PRISTINE-database mover predictor (§ 2)
score15.py      order-blind 3-way grid scorer, shape AND span (§ 7)
cell15.sh       one grid cell: surelog -parse + slang --single-unit + uhdm-cmp
gates15.sh      the four mandatory sweep legs, SLANG_UHDM exported per leg
ct15rows.sh     differing-row counter, status AND dump columns
byteverify.sh   the mover gate, SELFCHECK=1
boundary15.sh   the wide boundary (subdirectories included, asymmetries loud)
canaries.sh / ctcan2.sh / canaudit.sh   the canary battery and its audit
cells/g1..g5    the golden grid (§ 4); g2/g3/g5 double as the boundary's
                positive control
```

Reproduce:

```
bash build15.sh
for c in g1 g2 g3 g4 g5; do bash cell15.sh "$PWD/cells/$c" <base-bin>;      done
for c in g1 g2 g3 g4 g5; do bash cell15.sh "$PWD/cells/$c" <pat-bin> .pat;  done
for c in g1 g2 g3 g4 g5; do python3 score15.py cells/$c;                    done
python3 predict15.py <base-workdir> PREDICT.txt
```
