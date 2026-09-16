# r11u55 — ROAD E: the elaborated `cont_assign`'s constant-reducing Rhs is
# substituted per instance

Base commit `455f226d`. Pristine binary md5 `490c201cceef32cff72cfd7192df9396`
(byte-identical to the main tree's `build/slang-uhdm` at that commit).

---

## 1. The witness head, re-measured at the base

`struct_param_pattern_packing`, both modes, identical head (LHS is golden):

```
LHS:
decompile:
constant: , id:794, line:18:34, endln:18:35
|vpiParent:
\_cont_assign: , id:789, line:40:10, endln:40:24
|vpiDecompile:3
|vpiSize:32
|UINT:3
|vpiConstType:9
RHS:
decompile:
hier_path: (CFG.n), id:216, line:40:19, endln:40:24
```

`line:18:34` is the literal `3` inside the package's
`localparam cfg_t LIT = '{n: 3, base: 64'h1000};`, and `line:40:19` is the
`CFG.n` written on the cont_assign at line 40. The head field is `decompile:`
because `constant::Compare` reads `VpiDecompile` first.

Residue arithmetic, order-blind (dumps id-normalised and path-normalised, then
sorted and `comm`-ed):

| mode | golden lines | ours lines | golden-only | ours-only |
|---|---|---|---|---|
| default | 3204 | 2920 | **303** | **19** |
| testflags | 2694 | 2410 | **303** | **19** |

The golden-only bulk is the `p::cfg_t` FUNCTION-ARGUMENT typespec family we
never emit (11 golden-only `struct_typespec` lines, 10 `typespec_member`, 17
`ref_typespec`, 7 `vpiInstance`, 7 `package`); the fold itself accounts for the
10 golden-only `cont_assign` lines and 11 golden-only `constant` lines. The pass was briefed to expect ADVANCE and not a conversion on this
arithmetic; it CONVERTS anyway (§8) — 213 of the remaining golden-only lines
sit in a family the comparator's reachable walk never enters, so the dump
column and the judge disagree, and the judge is the judge.

---

## 2. The producer, confirmed against the pinned sources

Surelog v1.87 (`0445655ee7`).

`UhdmWriter::writeCont_assign` (`src/DesignCompile/UhdmWriter.cpp:2090`) walks
`netlist->cont_assigns()` — per ELABORATED INSTANCE. At `:2245`:

```cpp
      if (simplified == false) {
        bool invalidValue = false;
        …
        any* res = m_helper.reduceExpr((expr*)rhs, invalidValue, mod, …, assign, true);
        if (invalidValue == false) {
          if (res && (res->UhdmType() == uhdmconstant)) {
            if (cloned == false) {
              ElaboratorContext elaboratorContext(&s, false, true);
              assign = (cont_assign*)UHDM::clone_tree(assign, &elaboratorContext);
              assign->VpiParent(m);
              lhs = assign->Lhs();
              cloned = true;
              res = m_helper.adjustSize(tps, mod, m_compileDesign,
                                        netlist->getParent(), (constant*)res, true);
              res->VpiParent(assign);
            }
            assign->Rhs((constant*)res);
```

Three facts, each confirmed by a grid cell rather than by reading alone:

1. the block is OUTSIDE the `lhs->UhdmType() == uhdmref_obj` test above it, so
   the **Lhs kind is not a gate** — golden folds under all seven Lhs kinds
   (`ve1`);
2. it never inspects the Rhs kind — a `hier_path`, a two-level `hier_path`, an
   unpacked-array element read and a bit-select of a member all go in
   (`ve2`, `ve5`);
3. `tps` comes from `lhs->Typespec()->Actual_typespec()` at `:2099`, which only
   a WHOLE-NAME Lhs carries, and `adjustSize` (`CompileHelper.cpp:4065`)
   returns at once when `ts == nullptr`.

The definition listing always keeps the written expression:
`compileContinuousAssignment` compiles the Rhs with a hard `Reduce::No`
(`CompileHelper.cpp:2500`). Our def view already agrees.

### The `adjustSize` table, read off golden (`ve6_adjust_table`)

One 16-bit member per encoding, read by an 8-bit, a 16-bit and a 32-bit Lhs:

| encoding | what `adjustSize` does | measured |
|---|---|---|
| `vpiUIntConst` | uniquify-CLONES per assign, MASKS the value to the Lhs width and rewrites the decompile | `300` at `logic [7:0]` → `UINT:44` size 8; at 32 → 300/32; at 64 → 300/64, **three distinct objects** |
| `vpiHexConst` | size follows the Lhs, spelling untouched, **no uniquify** | `16'hBEEF` shared by all three assigns; the object reads size **32** — the LAST and widest reader |
| `vpiBinaryConst` | resized only when SHRINKING (`if (orig_size > size)`), value truncated to the low bits, **no uniquify** | `16'b1010010111000011` at `logic [7:0]` becomes `BIN:11000011` size 8, and the two wider readers share that already-shrunk object |
| `vpiDecConst` | untouched — the `c->VpiConstType() != vpiDecConst` guard never lets `size` leave `orig_size` | `16'd4660` stays size 16 under all three |
| select Lhs | `tps` null → `adjustSize` returns at once | the member's own width survives (`ve1` `o_bit`/`o_part`/`o_arr`) |

### Where the constant is stamped (`ve4_value_source`)

`reduceExpr` returns the object the value came from, so the location is the
SOURCE OF THE VALUE and the encoding is that source's own:

| pattern element | golden elab Rhs |
|---|---|
| `n: 3` | `UINT:3` size 32 @`22:31` (the literal `3`) |
| `m: K + 1` | `UINT:4` size 32 @`23:31` — the ELEMENT EXPRESSION's start, value already reduced |
| `h: 16'hBEEF` | `HEX:BEEF` decompile `16'hBEEF` @`24:31` |
| `b: 8'b10100101` | `BIN` decompile `8'b10100101` @`25:31` |
| `r: OTHER` | `UINT:41` @`26:31` (the reference's span, value substituted) |
| `default: 0` | `UINT:0` @`27:37` (the `0` in the default clause) |

Our own elaborated `param_assign` already carries these six member constants
with byte-identical size / value / decompile / constType / location — which is
why this law needs no new value machinery, only the substitution.

---

## 3. The golden grid

Six arms, ~55 cells. Runner (unchanged from `r11u51repro/run51.sh`):

```
bash run55.sh <binary> <tag> ve1 ve2 ve3_multi_inst ve4_value_source \
                            ve5_boundary ve6_adjust_table
python3 caread55.py grid/<arm>/gold.<tag>.dump ELAB     # the cell reader
```

`caread55.py` (the cell reader) sections the dump by VIEW (`uhdmall*` = DEF, `uhdmtop*` = ELAB,
`weaklyReferenced` = TAIL) because `writeCont_assign` runs per instance while
the definition listing is compiled `Reduce::No` — "golden folds `CFG.n`" is
never a whole-design fact. It skips `vpiParent` back-link subtrees (uhdm-dump
prints them as full child blocks) and exits 4 when an arm yields no
cont_assign, so a reader that reaches nothing can never read as agreement.
A `<none>` row means the object was printed as a STUB — i.e. it is SHARED with
a copy already printed, which is how both the def-share (ours) and the
cross-assign sharing (golden's Hex/Bin/Dec arms) show up.

| arm | what it cuts |
|---|---|
| `ve1` | the Rhs held at exactly `CFG.n`, seven Lhs kinds (plain, bit-select, part-select, unpacked-array element, signed, narrower, wider) |
| `ve2` | seven Rhs kinds: operation containing a field read, two-level read, unpacked-array element, concat containing a field read, generate-scope read, and two non-constant controls |
| `ve3_multi_inst` | **NEW** — three instances of one definition: default, `#(.CFG(p::LIT2))`, and an inline-pattern override. Proves the fold is per-instance substitution of a clone |
| `ve4_value_source` | **NEW** — six pattern-element source shapes (literal, expression, hex, binary, reference to another localparam, `default:`) |
| `ve5_boundary` | **NEW** — the shapes a widened predicate could take over wrongly: a struct VARIABLE's field, an interface signal, an unpacked-array element's field, a field under a NON-constant index, a three-level read, a packed-array member, a bit-select of a member |
| `ve6_adjust_table` | **NEW** — the `adjustSize` table above, each encoding against a narrower, equal and wider Lhs |

Recorded rcs (this pass's pristine build, md5 `490c201cceef32cff72cfd7192df9396`):

```
ve1              golden_rc=0 ours_rc=0 cmp_rc=255 heads=1 cmplines=26
ve2              golden_rc=0 ours_rc=0 cmp_rc=255 heads=1 cmplines=31
ve3_multi_inst   golden_rc=0 ours_rc=0 cmp_rc=255 heads=1 cmplines=5
ve4_value_source golden_rc=0 ours_rc=0 cmp_rc=255 heads=1 cmplines=31
ve5_boundary     golden_rc=0 ours_rc=0 cmp_rc=255 heads=1 cmplines=31
ve6_adjust_table golden_rc=0 ours_rc=0 cmp_rc=255 heads=1 cmplines=26
```

`ve5_boundary` needed a real top: our binary REJECTS a top-level module with an
unconnected interface port (`rc=3`, "unconnected interface port 'ii'"), so the
arm wraps `dut` in a `top` that instantiates the interface. Recorded as an
ERROR CELL of the harness, not as a golden claim.

---

## 4. The law as landed — § `caStructParamPatternSubst55`

`src/ModuleEmit.cpp`, the § block above `emitContAssigns`, the predicate inside
it, and the emission arm.

The emitter already had § `structParamSetter`: a member access on a struct-typed
parameter whose OWN initializer is written as an assignment pattern folds to
that member's setter. Three widenings, each with its own measured cell:

* **W1 — the initializer CHAIN.** `parameter p::cfg_t CFG = p::LIT` reaches its
  pattern through a reference to a package localparam. `structParamPattern55`
  follows references to other parameters and conversions, depth-fenced at 8
  hops, and returns null the moment the chain reaches anything else.
  This is the witness's shape and `ve1`/`ve4`'s.
* **W2 — the NESTED read.** `OC.sub.n`, `OC.m.a.n`: the member chain is walked
  outermost-last, one pattern per level (`ve2`, `ve5`).
* **W3 — `adjustSize`**, which the arm never ran. The constant enters at the
  MEMBER's declared width and is then re-stamped against the Lhs declaration
  through the existing `caLhsAdjustBind106` width, per the table in §2.
  `ve3_multi_inst`'s inline-pattern instance folds `7` at size **64** on the
  pristine binary where golden carries **32**; W3 is what fixes it.
* **the value is ALREADY REDUCED**: `m: K + 1` substitutes `UINT:4`, not an
  operation, at the element expression's own start (`ve4`).

### The fences, and why each one is there

* **Plain whole-name Lhs.** The census below finds no struct-param dotted read
  in either corpus written onto a select Lhs, while the arms that carry a
  bit-select / part-select / array-element Lhs today (`callIdxLhs`'s def-share,
  the general fold) are large families this law has no measurement for. The
  widenings are gated on a `NamedValue` Lhs; the pristine own-pattern shape is
  left EXACTLY as it was for every other Lhs kind, so nothing that folds today
  stops folding.
* **A function-BUILT struct parameter** (`= p::build()`) never reaches a
  pattern and is left to § `caAsmMemberSliceFold`, which already carries
  `struct_param_func_arg`, `struct_param_func_loop` and
  `struct_param_func_config`.
* **A non-constant read** — a struct VARIABLE's field, an interface signal, a
  field under a non-constant index — has no pattern element either and keeps
  the shared def object, which is what golden does (`ve5` controls `o_var`,
  `o_ifc`, `o_ridx`: all three AGREE on both binaries).

### Cell trace

`R11U55_CELLDBG=1` names EVERY cont_assign that reaches the site with the
predicate's answer, the object already in hand and the Lhs kind — not only the
shape the law intends to change, so a row moved by accident cannot hide.

---

## 5. Grid score after the law (`diff` of the golden and ours ELAB readouts)

| arm | before | after |
|---|---|---|
| `ve3_multi_inst` | 4 of 6 cells wrong (two instances shared the def object; the third folded at size 64) | **IDENTICAL** |
| `ve4_value_source` | 6 of 6 shared the def object | **IDENTICAL** |
| `ve1` | 1 of 7 folded | 4 of 7 exact (the four whole-name Lhs); 3 select-Lhs cells are declared residue R1 |
| `ve2` | 3 divergent cells | `OC.sub.n` now exact; generate + concat remain (R2, R3); `AP[0]` differs by LOCATION only |
| `ve5_boundary` | 4 divergent cells | `OC.m.a.n` and `CFG.v` now exact; `AP[0].n` and `CFG.n[1]` remain (R4) |
| `ve6_adjust_table` | cmplines 26 | cmplines 18; the UINT row now exact, the cross-assign sharing is R5 |

---

## 6. Residues, measured and declined

* **R1 — the three select-Lhs cells** (`ve1` `o_bit[0]`, `o_part[3:0]`,
  `o_arr[0]`). Golden folds under all seven Lhs kinds; we fold under the four
  whole-name ones. No corpus site writes a struct-param dotted read onto a
  select Lhs (census §7), and the families that own those Lhs kinds here are
  unmeasured. Grid `ve1`.
* **R2 — the GENERATE-scope read** (`ve2` `o_gen`). Golden folds `CFG.n` inside
  `if (1) begin : g` to `UINT:3` @`11:34`; we keep the `hier_path`. The share
  decision does not run for a cont_assign inside a gen scope, and the landed
  gen-scope laws own that emission — widening it is a second pass, not a fence
  on this one. Grid `ve2`.
* **R3 — the CONCAT containing a field read** (`ve2` `o_cat`,
  `{16'h0, CFG.n[15:0]}`). Golden's `reduceExpr` folds it to a 32-bit `BIN`
  constant; we keep the operation. Note this settles a cross-road question: the
  concatenation exception of pass 53's package-substitution gate does **not**
  apply at this site — two sites, two gates. Grid `ve2`.
* **R4 — a field of an unpacked-array parameter ELEMENT and a bit-select OF a
  member** (`ve5` `AP[0].n` → `UINT:11` @`22:33`; `CFG.n[1]` → `BIN` `1'b1`
  size 1 @`19:32`). Both need an element/slice step this law does not make.
  Grid `ve5_boundary`.
* **R5 — the cross-assign SHARING of the Hex, Bin and Dec reduce products.**
  Those `adjustSize` arms do not uniquify, so when ONE member is read by
  several cont_assigns of the same instance golden shares a single object and
  the last writer's width wins (`ve6`: `h_nar`/`h_eq`/`h_wid` all read size 32;
  `b_eq`/`b_wid` inherit `b_nar`'s truncation to size 8). We mint a fresh
  constant per assign. No row in either corpus reads one member from two Lhs of
  different widths, so the coupling is corpus-invisible; modelling it would add
  cross-assign shared state for a cell only this arm can see. Grid
  `ve6_adjust_table`.
* **R6 — the LOCATION on the folds this law does not own** (`ve2` `AP[0]`,
  `ve1`'s array-element cell): ours are loc-less where golden is stamped at the
  value's source. `constant::Compare` reads `VpiDecompile` / `VpiSize` /
  `VpiValue` / `VpiConstType` and never `VpiFile`/line/column, so this is
  dump-visible only.

---

## 7. The a-priori boundary census

`shapes55.py` is a SOURCE-TEXT lister on purpose: it must name rows whose
databases the pass has not built, and it must over-approximate — a row it lists
and that does not move is harmless, a row it misses is the regression nobody
predicted. It walks `uhdm2rtlil/test`, `Surelog/tests` and
`Surelog/third_party/tests` and reports every directory that declares a
user-typed parameter and reads a dotted name off it on a continuous assign,
classified by shape (`CA_DOT_PARAM`, `_DEEP`, `_IDX`, `_CAT`, `_SEL`, `_GEN`).

POSITIVE CONTROL: `shapes55.py --selftest` runs the lister over this pass's own
grid, whose shapes are known cell by cell, and asserts every class appears.
A census with no positive control can silently return zero.

```
SELFTEST dirs=5 classes=CA_DOT,CA_DOT_CAT,CA_DOT_DEEP,CA_DOT_GEN,CA_DOT_IDX,CA_DOT_PARAM,CA_DOT_SEL
SELFTEST PASS missing=-
```

The census names **23 directories**: 5 that cannot move (no judged database at
this pin — `Ariane2024`, `Earlgrey_Verilator_01_05_21`, `Earlgrey_nexysvideo`,
`IncompTitan`, and `cva6_equiv`, which is not a discovered row), **13 judged
CMP_EQUAL** and **5 judged CMP_NOTEQUAL**. `evidence/PREDICT55.txt` scores every
one of the 18 judged directories move-or-stay WITH ITS REASON, written down
before the law-binary sweeps ran. The prediction was: *exactly one row moves in
both modes — `struct_param_pattern_packing` — and nothing else in either
corpus.*

---

## 8. Measured outcome

Law binary md5 `328d4e33c1d9ae9e3f7eabf2125a9c78`.

**The witness CONVERTS, in both modes** — better than the brief's "closes its
HEAD ONLY":

```
< struct_param_pattern_packing,default,CMP_NOTEQUAL,decompile:,,
> struct_param_pattern_packing,default,CMP_EQUAL,,,differ
< struct_param_pattern_packing,testflags,CMP_NOTEQUAL,decompile:,,
> struct_param_pattern_packing,testflags,CMP_EQUAL,,,differ
```

`uhdm-cmp` returns rc=0, `heads=0`, 0 cmp lines in both modes. uhdm2rtlil goes
**784 → 785 CMP_EQUAL / 20 → 19 CMP_NOTEQUAL in each mode**; it is the ONLY row
that differs from the committed baseline in either mode.

The dump residue falls **303 → 213 golden-only** (the fold removes 90 lines:
five substituted constants, five cont_assign clones and their attributes);
ours-only stays 19. What is left is the `p::cfg_t` FUNCTION-ARGUMENT typespec
family — 11 `struct_typespec`, 10 `typespec_member`, 17 `ref_typespec`, 7
`vpiInstance`, 7 `package` — which the comparator's reachable walk never
enters, so the dump column still reads `differ` while the judge reads
CMP_EQUAL.

`byteverify`, law workdir vs THIS PASS'S OWN pristine workdir:

```
databases: patched=1608 pristine=1608
PATH_SETS_IDENTICAL (1608 paths)
MOVER ./default/struct_param_pattern_packing-551f1414/slang.uhdm
MOVER ./testflags/struct_param_pattern_packing-551f1414/slang.uhdm
MOVERS: 2 / 1608
SELFCHECK (positive control): 1607 / 1608 flagged
```

On the **Surelog suite** nothing moves: 474/9 default and 469/8 testflags,
unchanged, and the CMP_NOTEQUAL set is identical between the pristine and law
sweeps row for row. `byteverify` names three surelog movers — MiniAmiq in both
modes and SeqDriver/testflags — and all three are the documented per-invocation
COIN: order-blind each is exactly the 4-line `UINT`/`vpiDecompile`
line-number class, and the SAME PRISTINE BINARY run twice on MiniAmiq/default
produces the same class (`UINT:852` vs `UINT:942`) with an identical byte size.
Neither directory is in the boundary census and neither declares a struct-typed
parameter read on a continuous assign, so the law's predicate cannot fire there.
All five UVM-family rows and Earlgrey_0_1 stay CONVERTED (rowheads: cmplines=0,
heads=0, cmp rc=0). Every canary byte pin hits the brief's value: SVSwitch
`4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`.

**MOVED-WRONG 0. AWAY-FROM-GOLDEN 0.**

See `evidence/CENSUS.txt` for the per-site listing, `evidence/PREDICT55.txt`
for the per-row prediction and the measured outcome, `evidence/VGRID55.txt` for
the golden / pristine / law cell readouts of all six arms, and
`evidence/GATES55.txt` for the gate transcript.
