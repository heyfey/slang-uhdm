# r11u18 — two singles outside ParamEmit's assembled-struct family

Base `3343dab6` (matrix-1.87).  Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.
Two laws landed.  **No test converted** — both target heads CLEARED and each
target test advanced onto a new, different head (see §6).

---

## 1. The three heads, RE-MEASURED at this base

Measured on this pass's own pristine build (md5 `1aa37395635eecfceae336d552538b37`,
byte-identical to the main tree at `3343dab6`), official `uhdm-cmp`, LHS always
golden, ONE head per run, both modes identical.

| test | pristine head | lines / heads |
|---|---|---|
| `param_nested_struct_field_width` | `type_parameter (work@dut.sel_t)` — golden `\|vpiLocalParam:1`, ours absent; every other field (name, fullname, span, typespec, actual `logic_typespec`) already identical | 29 / 1 |
| `struct_param_field_shift` | `ref_typespec (cfg_pkg)` on a `constant` at `20:46-20:48`, `vpiActual` `int_typespec` at `14:41-14:44`, `RHS: <null>` | 9 / 1 |
| `struct_member_cfg_width` | `ref_typespec (work@struct_member_cfg_width.fu_data_i)` on a `logic_net`, `vpiActual` `struct_typespec (fu_data_t)` at `25:13-29:6`, `RHS: <null>` | 9 / 1 |

`struct_member_cfg_width` is a THIRD law (a module-local typedef's typespec on a
net) and shares nothing with A or B — **not landed**, and its head is byte-for-byte
unmoved by this patch (9 / 1 before and after).

### What the `struct_param_field_shift` head actually is

The cmp head names a `ref_typespec`, but its owner is not the func_call argument
the span suggests.  Sectioning both dumps:

* `uhdmallPackages` (DEF): `param_assign` Rhs is the `func_call build_config`,
  its `vpiArgument` constant `64` carries **no** typespec — **and ours is
  identical**, and golden's `typespec_member (XLEN)` has **no `vpiExpr` at all**.
* `uhdmtopPackages` (ELAB): the Rhs is the assembled `BIN` constant and
  `typespec_member (XLEN)` carries a `vpiExpr` LEFTOVER — golden's is the
  caller's actual object WITH a `ref_typespec (cfg_pkg)` → the FORMAL's
  `int_typespec`; ours is a fresh slice constant with none.

So the head is a MEMBER LEFTOVER of the § `pkgStructFuncAssembleBin` /
§ `modEvalFuncLeftoverEnc` family, in the ELABORATED listing only.

---

## 2. § typeParamLocalKeyword18 — the producer and its key

`vpiLocalParam` on a `type_parameter` is written from the **WRITTEN KEYWORD**,
never from the LRM-derived local flag.

Producer: `CompileHelper::compileParameterDeclaration` takes a `bool localParam`
argument and both type arms write the flag from it alone —
`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:3486`
(`paList_of_type_assignments`) and `:3628` (`paTYPE`).  The argument is decided
by the caller purely on the DECLARATION NODE KIND:
`~/git-repos/Surelog/src/DesignCompile/CompileModule.cpp:730` passes `false` for
`paParameter_declaration` and `:751-768` passes `true` for
`paLocal_parameter_declaration`, and CompilePackage / CompileClass /
CompileInterface split the same way.

slang's `ParameterSymbolBase::isLocalParam()` is a DIFFERENT predicate and would
have over-fired: a module-BODY `parameter type T = int` under an ANSI header is
local to the LRM and NOT local to Surelog (grid t1 `PT2`).

### The golden grid (Surelog v1.87, one arm per directory, every rc recorded)

`grid.sh` runs `surelog -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`, then
both binaries, then the official `uhdm-cmp`; every arm below compiled
`slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.

| arm | shape | golden cell |
|---|---|---|
| `t1` | MODULE: ANSI port list and module BODY, both keywords, type AND value params | `parameter type PT1` **0**, `localparam type LT1` **1**, body `parameter type PT2` **0**, body `localparam type LT2` **1** — and the value params `PV1/LV1/PV2/LV2` split 0/1/0/1 the same way |
| `t2` | `t1`'s PACKAGE twin | `pk::PT1` **0**, `pk::LT1` **1**, in `uhdmallPackages` AND `uhdmtopPackages` |
| `t3` | OVERRIDE + re-pass one level down | def `work@leaf.PT` **0** / `work@leaf.LT` **1**; the ELAB instance copies `work@dut.u1.MT` and `work@dut.u1.u0.PT` are **0**, and golden re-references the DEF `work@leaf.LT` for the localparam instead of minting an instance copy |
| `t4` | INTERFACE and a NON-ANSI module header | `work@ifc.IT` **0** / `work@ifc.ILT` **1**; `work@nonansi.NPT` **0** / `work@nonansi.NLT` **1** |
| `t5` | the corpus test's shape (a `localparam type` whose default reads a localparam int off a struct parameter) | `work@dut.sel_t` **1**, `work@dut.par_t` **0** |
| `t6` | CLASS defn + a gen-scope type-param re-pass | `work@cls::CT` **0**, `work@cls::CLT` **1**; `work@dut.gb[0].u.GT` / `gb[1].u.GT` **0** |
| `t7` | `t6`'s class SPECIALIZED twice | the class_defn cells as t6; the class_typespec SPECIALIZATION lists ONLY `work@user::h::cls::CT` (**0**) and never the localparam one |
| `t8` | WILDCARD-IMPORTED package type params | `pk::PT` **0** / `pk::LT` **1** in both package listings, the module's materialized copies `work@dut.PT` **0** / `work@dut.LT` **1**, and the design-level `$unit` copies `PT` **0** / `LT` **1** |
| `t9` | a keyword-OMITTED continuation declarator, and two declarators on one keyword | `LA` **1**, `LB` (no keyword of its own) **1** — it INHERITS; `PA`/`PB` **0**; `MA`/`MB` (one `localparam type`, two declarators) both **1** |

`t2` and `t8` carry large PRE-EXISTING deltas unrelated to this law (a
type-parameter-typed variable comes out `int_var` where golden has `logic_var`);
they are CENSUS witnesses for the flag cell, not head arms.

### What was NOT taken

The class_typespec SPECIALIZATION emitters (`emitClassTsParams` and the two
explicit `#(...)` arms) are untouched: golden lists only the overridable formal
there and it is already `local=0` in ours (t7).  An absent object, never a wrong
one.

---

## 3. § memLeftFormalReadTs18 — the producer and its key

`ExprEval::setValueInInstance` stamps `reduceExpr(<body RHS>)` on the
`typespec_member`; for `c.M = <formal>` the reduce hands back the CALLER's
actual, and that object carries a `ref_typespec` whose `Actual_typespec` is
**the FORMAL's own typespec** — the formal's, never the actual's.

| arm | the call | golden's leftover cells |
|---|---|---|
| `b3` | NAMED, REORDERED actuals `mk(.second(16'h00F0), .first(9))` | `p` (← formal `second`) `HEX:00F0` sz 16 ct 5, ts `logic_typespec` 5:51; `q` (← formal `first`) `UINT:9` sz 64 ct 9, ts `int_typespec` 5:31 — each member's OWN formal |
| `b4` | the corpus test's shape, `build_config(64)` | `XLEN` `UINT:64` sz 64 ct 9, ts `int_typespec` 8:41; the COMPUTED `XLEN_ALIGN_BYTES` `UINT:3` — **bare, no ts** |
| `b5` | `mk(64, 8'hAB)`, formals `int unsigned` / `logic [7:0]` | `a` `UINT:64/64/9` ts `int_typespec`; `b` `HEX:AB` decompile `8'hAB` sz 8 ct 5, ts `logic_typespec` |
| `b6` | `mk(1'b1, 8'd5)`, formals `bit` / `byte` | `a` `BIN:1` `1'b1` sz 1 ct 3, ts `bit_typespec`; `b` `DEC:5` `8'd5` sz 8 ct 1, ts `byte_typespec` |
| `b7` | actuals are WHOLE PARAMETER reads `mk(PK, PL)`, both formals `int unsigned` | `a` `UINT:7` **sz 32** (PK's own), ts the FORMAL's `int_typespec`; `b` `HEX:AB` **sz 8** (PL's own, a `logic [7:0]` localparam), ts the FORMAL's `int_typespec` — **encoding from the ACTUAL, typespec from the FORMAL** |
| `b8` | actuals an EXPRESSION `PK+1` and a nested CALL `dbl(3)` | `a` `UINT:8/64/9` ts `int_typespec`; `b` `INT:6/64/7` ts `int_typespec` — even a non-object actual is stamped |
| `b9` | `b5`'s MODULE-holder twin | **every cell identical to `b5`** — HOLDER-INDEPENDENT, as § modEvalFuncLeftoverEnc found for the other leftover shapes |
| `b1`/`b2` | 6 formals, one actual `PK+1` | golden's assembler **BAILS** (the `param_assign` Rhs stays a `struct_var`), and its partial stamping is garbage: only member `c` gets a leftover and it is member `f`'s value (`PK+1` = 8) wearing `xf`'s typespec.  **Refuted as a law arm; recorded as a BAIL arm.**  Our binary assembles and stamps all six here — a PRE-EXISTING over-fire, unchanged by this pass (R2). |

The ref's `VpiFullName` is the holding package's name for a call written at
package scope (`cfg_pkg`, `pk`) and ABSENT for one written at module scope (b9).
Dump-only: `ref_typespec::Compare`
(`~/git-repos/UHDM/build/generated/src/ref_typespec.cpp:116`) reads
`VpiName`/`VpiDefName`/`Actual_typespec` and never `VpiFullName`.

### The gate

The stamp lands ONLY on the constant this stamp itself minted (`minted`,
pointer identity).  Every other candidate in `values` is an object SHARED with
the parameter or body statement a reuse resolution took it from — and golden
re-stamps a CLONE there (b7 gives a `logic [7:0]` localparam's constant an `int`
typespec), so writing through the share would corrupt the original.  Those cells
are left exactly as they are, and they already agree with golden by Compare
(`param_nested_struct_field_width`'s `pk::cfg_t.u` reuses `UCFG`'s own elaborated
constant, whose typespec is already `struct_typespec (pk::user_cfg_t)`).

The `Actual` is the formal typespec the SUBROUTINE emission already built
(`subMap[fn].argTs[i]`), never a fresh mint, so the object count does not move.

---

## 4. The patched grid

| arm | pristine | patched |
|---|---|---|
| `t1` `t3` `t4` `t6` `t9` | 1 head | **0 heads, 0 cmp lines — CMP_EQUAL** |
| `t5` | 1 head (`type_parameter work@dut.sel_t`) | 1 head, the OBJECT CHANGED: `operation` at 11:41 (the `W-1` range bound golden keeps symbolic and we fold) — R1 |
| `t7` | 1 head (`work@cls::CLT`) | 1 head, the OBJECT CHANGED: the class_typespec specialization listing (pre-existing) |
| `t2` `t8` | 1 head | 1 head, unchanged pre-existing package deltas; the FLAG cells moved (census below) |
| `b3`–`b9` | leftover `ts=NONE` | **every ts cell equals golden's, object for object** |
| `b1`/`b2` | the bail arms | unchanged over-fire, now also carrying the ts |

Keyed census (`cen18.py`, TP = type_parameter flag, ML = member leftover ts;
abbreviated dump repeats resolved to the object they name):

```
t1  TO-GOLDEN=5  AWAY-GOLDEN=0      t9  TO-GOLDEN=10 AWAY-GOLDEN=0
t3  TO-GOLDEN=2  AWAY-GOLDEN=0      t2  TO-GOLDEN=2  AWAY-GOLDEN=0
t4  TO-GOLDEN=3  AWAY-GOLDEN=0      t8  TO-GOLDEN=3  AWAY-GOLDEN=0
t5  TO-GOLDEN=3  AWAY-GOLDEN=0      b3  TO-GOLDEN=2  AWAY-GOLDEN=0
t6  TO-GOLDEN=1  AWAY-GOLDEN=0      b4  TO-GOLDEN=1  AWAY-GOLDEN=0
t7  TO-GOLDEN=1  AWAY-GOLDEN=0      b5/b9 TO-GOLDEN=2 AWAY-GOLDEN=0
```

---

## 5. The mover set, PREDICTED BY NAME BEFORE THE PATCHED SWEEP

`predict18.sh`.  L1 (§ typeParamLocalKeyword18) is a SOURCE predicate — the
law's key is the written keyword, which is not in the database at all — so the
prediction greps every corpus source for a `localparam ... type` parameter
declaration.  L2 (§ memLeftFormalReadTs18) is the named target.

* **u2r L1 predicted:** `bits_of_type_param`, `cva6_equiv`,
  `cva6_struct_param_field`, `packed_array_struct`,
  `param_nested_struct_field_width`, `type_param_override_elem_sel`,
  `type_param_packed_dim`.  **L2 predicted:** `struct_param_field_shift`.
* **surelog L1 predicted:** `StructParamFieldRange`,
  `StructParamFuncBodyFieldCompare`, `StructParamPatternInitCast`, `ClassScope`,
  `ClassTypeParamAlias`, plus files under `Google`, `Verilator`, `Ariane2024`,
  `ariane`.

Measured (`byteverify.sh SELFCHECK=1`, patched vs this pass's OWN pristine
workdirs):

* **u2r: MOVERS 14 / 1608**, selfcheck 1607/1608 — 7 names × 2 modes, exactly
  L1 ∪ L2 minus `cva6_equiv`, which is **not a discovered row** (the directory
  holds a flist and no `dut.sv`).  Zero unpredicted movers.
* **surelog: MOVERS 11 / 960**, selfcheck 959/960 —
  `StructParamFieldRange`, `StructParamFuncBodyFieldCompare`,
  `StructParamPatternInitCast` × 2 modes (all three L1-predicted), plus
  `MiniAmiq` ×2, `SeqDriver` ×2, `Scoreboard` default: the PROVEN UVM COIN
  family.  Every other L1-predicted surelog name has NO DATABASE
  (`ClassScope`/`ClassTypeParamAlias`/`Verilator`/`Google`/`Ariane2024`
  are SLANG_REJECT / TIMEOUT / NO_DATABASE; `ariane` is not a row).

**Coin attribution, order-blind + POSITIVE CONTROL.**  Sorted, path-normalised
dumps: `Scoreboard/default` **0 lines**; `MiniAmiq` and `SeqDriver` **4 lines**
each, and each is one `UINT:<n>` plus its `vpiDecompile` — the line-number class.
Positive control: the PRISTINE binary re-run three times on `MiniAmiq/default`
gives three DIFFERENT databases (`549f2d92802a`, `cae4305d88b2`, `9df4ac6de6a0`),
none equal to its own sweep hash `651738816dba`.  Pinned by NAME and by the coin
CLASS, never by the count.

**Directional census on every law mover** (`rowcen18.sh`, keyed, against each
row's OWN golden), both modes:

| row | TO-GOLDEN | AWAY-GOLDEN |
|---|---|---|
| `bits_of_type_param` | 3 | 0 |
| `cva6_struct_param_field` | 2 | 0 |
| `packed_array_struct` | 2 | 0 |
| `param_nested_struct_field_width` | 9 | 0 |
| `struct_param_field_shift` | 1 (`cfg_pkg::cfg_t.XLEN` ts NONE → `int_typespec`) | 0 |
| `type_param_override_elem_sel` | 3 | 0 |
| `type_param_packed_dim` | 3 | 0 |
| `StructParamFieldRange` | 2 | 0 |
| `StructParamFuncBodyFieldCompare` | 2 | 0 |
| `StructParamPatternInitCast` | 2 | 0 |

**AWAY-GOLDEN 0 and MOVED-WRONG 0 on all 14 + 6 measured mover sides.**

The cells the census prints with `g=ABSENT` (`work@dut.u1.u0.LT`,
`work@dut.u.rt_t`, the `weaklyReferenced work@cls::CLT`) are objects we ALREADY
emitted before this pass and golden does not emit at all — golden re-references
the definition object where we mint an instance copy.  The patch only makes
their flag agree with the object golden carries under that name; they are counted
STILL-WRONG, never AWAY, and `uhdm-cmp` confirms they are judge-invisible (t3,
t4 and t6 are CMP_EQUAL with those copies present).

A per-LINE multiset census (`rowline18.sh`) is BLIND to both laws — the moved
payloads are `|vpiLocalParam:1` and `|vpiTypespec:`, lines the dumps already
carry many times — which is why the keyed census above is the measurement.  It
reports one AWAY key on `struct_param_field_shift`
(`\_constant: , line:20:33, endln:20:49`, g=2 pris=6 pat=7): the new
`ref_typespec`'s `vpiParent` back-reference adds one more print of the
leftover's own header line, and that header carries the CALL span where golden's
carries the ARGUMENT span (R0 below).  A span, judge-invisible.

---

## 6. Head movement on the two targets — NO CONVERSION

| test | pristine head | patched head |
|---|---|---|
| `param_nested_struct_field_width` | `type_parameter (work@dut.sel_t)` missing `vpiLocalParam:1` | **CLEARED** → `operation` at `41:44-41:50`: golden keeps the `NLOG-1` range bound of `localparam type sel_t = logic [NLOG-1:0]` as a `vpiOpType:11` over `ref_obj (work@dut.sel_t.NLOG)`; we fold it to `UINT:3` with `vpiDecompile:NLOG-1` |
| `struct_param_field_shift` | `ref_typespec (cfg_pkg)` on the leftover, `RHS: <null>` | **CLEARED** → `LHS: <null>` / RHS `module_inst work@struct_param_field_shift`: we emit an `array_var acc` under `vpiVariables` that golden does not have (`logic [Cfg.XLEN-1:0] acc [0:1]`) |
| `struct_member_cfg_width` | `ref_typespec` on `logic_net fu_data_i` | **unchanged, 9 / 1** — a third law, not landed |

Both named targets remain CMP_NOTEQUAL.  Say it plainly: **this pass converts
nothing.**  It clears the two named heads and moves five further corpus rows
onto new heads.

The five collateral L1 movers all cleared their own `type_parameter` head too:

| row | pristine head object | patched head object |
|---|---|---|
| `bits_of_type_param` | `type_parameter (work@dut.data_t)` | `operation` 18:46 |
| `cva6_struct_param_field` | `type_parameter (…it_t)` | `operation` 26:12 |
| `packed_array_struct` | `type_parameter (…my_t)` | `constant` 20:25 |
| `type_param_override_elem_sel` | `type_parameter (work@child.rt_t)` | `packed_array_typespec` 17:31 |
| `type_param_packed_dim` | `type_parameter (work@dut.rt_t)` | `packed_array_typespec` 5:31 |

Rising cmp line counts on those rows are the NEW head's decompile size, not a
partial fix: the head OBJECT changed in every case.

---

## 7. Gates

| gate | result |
|---|---|
| pristine build md5 vs the main tree at `3343dab6` | `1aa37395635eecfceae336d552538b37` — BYTE-IDENTICAL |
| patched build md5 | `2e89c360034cc1e25794a8e0b61aa01f` |
| `tests/check_goldens.sh` (patched) | 23 PASS / 0 FAIL |
| `SLANG_UHDM=/bin/false` negative control | 0 PASS / 23 FAIL |
| u2r testflags vs `results/gate_uhdm2rtlil.csv` | PASS, 0 differing rows |
| u2r both modes vs `results/golden_uhdm2rtlil.csv` | PASS, 0 differing rows |
| u2r patched vs this pass's own pristine sweep, both modes | PASS, 0 differing rows |
| u2r scoreboard | 761 / 43 / 67 both modes, pristine and patched |
| surelog patched | 468/15 default + 464/13 testflags — identical to this pass's pristine sweep |
| surelog vs `results/golden_surelog.csv` and vs own pristine | 2 rows differ, BOTH only in the WORKDIR PATH inside a `SURELOG_FAIL` detail string (`LowMemLib`, `LowMemPkg`); 0 status moves, 0 dump-column moves |
| `byteverify SELFCHECK=1` u2r | 14 / 1608, selfcheck 1607/1608, every name predicted a priori, every moved cell TO-GOLDEN |
| `byteverify SELFCHECK=1` surelog | 11 / 960, selfcheck 959/960 — 3 predicted names × 2 modes (TO-GOLDEN) + the proven coin class with a positive control |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS / PASS |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| HARD byte pins | `SVSwitch` `4842211c4030`, `YosysVerx` `6ccda350c24a` — both modes, both binaries |
| STATUS pins | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex`, `YosysOldOr` — byte-identical pristine vs patched, both modes |
| `rowheads.sh` on the UVM / Earlgrey / Rggen rows | IDENTICAL pristine vs patched (12 measured, 2 SKIP-NOFILE as expected) |
| bail witnesses | `FuncStructVal` CMP_EQUAL, `FuncStructValSimple` CMP_EQUAL, `StructParamFuncBodyFieldCompare` / `StructParamPatternInitCast` / `StructParamFieldRange` CMP_NOTEQUAL — all unchanged |
| every `cmds.txt` audited BY BINARY PATH | 3273 pristine rows name `/tmp/…/pris.bin`, 3273 patched rows name `/tmp/…/pat.bin`, nothing else |
| fence check (the four slang-fenced tests) | 0 hits in the production diff; 0 hits in `tools/probe/r11u18repro/`; no driver dispatches them |
| `results/*.csv` | UNTOUCHED |

---

## 8. Residues

* **R0 — the leftover's ENCODING and SPAN, for a whole-formal-read member.**
  The typespec half of § memLeftFormalReadTs18 landed; the OBJECT-REUSE half did
  not.  Golden's leftover IS the caller's actual object, so it takes the actual's
  own base, size and `vpiConstType` and the actual's own SPAN.  Grid cells still
  wrong: `b5 b` / `b9 b` / `b3 p` (ours `UINT:171`/`UINT:240` sz 64 ct 9 where
  golden has `HEX:AB` sz 8 ct 5 and `HEX:00F0` sz 16 ct 5), `b6 a`/`b` (`BIN:1`
  `1'b1` sz 1 ct 3 and `DEC:5` `8'd5` sz 8 ct 1), `b7 a`/`b` (the PARAMETER's own
  size 32 / size 8), `b8 b` (`INT:6` ct 7).  `b4` — the corpus row's own shape —
  already agrees on the encoding, which is why the typespec alone cleared its
  head.  The fix needs a caller-ARGUMENT object map (the analogue of
  `bodyAsgRhsObj`) and is a pass of its own.
* **R1 — a type parameter's DEFAULT range bound stays SYMBOLIC.**
  `localparam type sel_t = logic [NLOG-1:0]`: golden's `logic_typespec` range
  carries the `vpiOpType:11` operation over `ref_obj (work@dut.sel_t.NLOG)`; we
  fold it to a constant in `makeTypeParamDefaultTs` (`makeBoundConst`,
  `src/TypeEmit.cpp` ~5890).  This is the NEW head of
  `param_nested_struct_field_width` and of grid arm `t5`, and it is a third law
  needing its own grid (which bounds stay symbolic, in which views).
* **R2 — our assembler fires where golden's BAILS.**  Grid `b1`/`b2`: golden
  leaves the `param_assign` Rhs a `struct_var` and stamps (almost) nothing; we
  assemble and stamp all six members.  Pre-existing, untouched by this pass, and
  now visible because the grid arm exists.
* **R3 — `struct_member_cfg_width`** still wants a `ref_typespec` on a
  `logic_net` typed by a MODULE-LOCAL typedef with parameter-driven member
  widths.  Re-measured unmoved (9 / 1, both modes).  A third, unshared law.
* **R4 — the ELAB instance copies of a `localparam type`.**  Golden's elaborated
  listing re-references the DEFINITION `type_parameter`; we mint an instance copy
  (`work@dut.u1.u0.LT`, `work@dut.u.rt_t`, `work@dut.i0.ILT`).  Judge-invisible
  today (t3/t4 are CMP_EQUAL) but it is an object golden does not have.

**R0 for the next pass: the caller-argument OBJECT REUSE half of
§ memLeftFormalReadTs18 — a whole-formal-read leftover must BE the caller's
actual object (its base, size, `vpiConstType` and span), not a value slice
wearing the right typespec.  Grid `b5`/`b6`/`b7`/`b8`/`b9` are the ready-made
witnesses and every one of their golden cells is tabulated in §3.**

---

## 9. Files

| file | what it is |
|---|---|
| `grid.sh` | the golden grid runner: Surelog v1.87 + both binaries + official `uhdm-cmp` per arm, every rc recorded |
| `t1`–`t9` | the § typeParamLocalKeyword18 arms (§2) |
| `b1`–`b9` | the § memLeftFormalReadTs18 arms (§3); `b1`/`b2` are the producer-BAIL arms |
| `tpcells.py` | lists every `type_parameter` object with its section and its `vpiLocalParam`, marking abbreviated dump repeats |
| `memcells.py` | lists every `typespec_member`'s `vpiExpr` leftover with its encoding and its `Actual` typespec |
| `cen18.py` | the KEYED directional census for both laws (a line-multiset census is blind to them) |
| `rowcen18.sh` | `cen18.py` on named SWEEP rows against each row's own golden |
| `rowline18.sh` | the per-LINE directional census, with its own blindness documented |
| `predict18.sh` | the a-priori mover prediction (source-keyed for L1, pristine-database-keyed for L2) |
| `arm.sh`, `dirscore.sh`, `shapecmp.sh`, `shapes.py`, `stamps.py`, `pacen.py`, `pacmp.py`, `leftcen.py`, `predict.py`, `dirline.sh`, `subset.sh` | carried forward from `r11u14repro` |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canary battery that RUNS here (audited: 29 names, 0 uncovered, 0 fence breaches) |
