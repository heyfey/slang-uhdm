# r10uvm126 — § `declArrayElemTsIsWrittenKeyword126` — **A FIXED-SIZE UNPACKED ARRAY'S ELEMENT TYPESPEC IS ITS WRITTEN TYPE KEYWORD** — the SimpleUVM ×2 / Scoreboard-default / BuildUVMPkg ×2 **12-line head CLEARED**

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `0a5551e` |
| pristine binary | reproduced the main tree's `build/slang-uhdm` at `0a5551e` BYTE FOR BYTE (md5 `9eeb7f38678c006f7d2bb3ac4d9cfd84`), frozen `chmod 555` before any sweep |
| patched binary | md5 `b8587364c34513da6006b77b8ee0cb7e`, frozen `chmod 555` |
| production surface | `src/EmitHelpers.h` — ONE new helper (`writtenKeywordElemTs126`) carrying the law; `src/TaskFuncEmit.cpp` — ONE arm, ahead of the two that were already there |
| probe surface | `tools/probe/r10uvm126repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **12** | **124** | 1 — a **NEW HEAD, a different object and a different family** |
| **Scoreboard default** | **12** | **124** | 1 — the same new head |
| **BuildUVMPkg default / testflags** | **12** | **54** | 1 — a **NEW HEAD**, its own new object |
| SeqDriver default / testflags | 28 | 28 | 1 unchanged, head log **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 28 | 28 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 240 / 268 | 240 / 268 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes | |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the nine **PREDICTED BY NAME** from the PRISTINE databases before the patched sweep ran | |
| direction, all 9 movers | — | **TO-GOLDEN 9, AWAY-GOLDEN 0, STILL-WRONG 0** (6 dump lines each, all of them the same object) | |
| the law's population, all nine DBs | 1 wrong cell each | **0** | |

The cmp line count going **UP** is the rule RESUME §7 states: the head object
CHANGED, and 124 / 54 is the NEW head's decompile size, not a distance. The
`string_typespec` / `logic_typespec` head is GONE from all five row-modes.

`head_pris_*_*.cmp` are the whole 12-line pristine heads; `head_pat_*_*.cmp` are
the new ones. `head_pris_{default,testflags}_{SeqDriver,MiniAmiq}.cmp` and the
two Earlgrey logs are the row-modes whose head this pass leaves untouched — and
their patched twins are byte-identical to them.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduces the master's head log
for all five row-modes line for line (ids aside). Every one of them is the same
two objects and nothing else — twelve lines, no parent, no name, no field:

```
LHS (golden)                                    RHS (ours)
decompile:                                      decompile:
string_typespec: , line:68:7, endln:68:13       logic_typespec: , line:68:7, endln:68:13
```

`uhdm-cmp` prints `decompile:` twice per side for ONE head, which is why the
head count is `grep -c '^LHS:'` = 1 and not 2.

**The object.** `uvm_reg_bit_bash_seq.svh:68`, inside
`uvm_reg_single_bit_bash_seq::body()`:

```systemverilog
   virtual task body();
      uvm_reg_field fields[$];
      string mode[`UVM_REG_DATA_WIDTH];      // <- line 68, columns 7..13 = `string`
```

BuildUVMPkg carries the same declaration at its own 1800.2 `pp_output` line
80061. It is the ELEMENT typespec of the `array_typespec` behind `mode`, and it
is UNPARENTED on both sides, which is why the head log has no context at all:
`typespec::Compare` reached it through the array_typespec's `Elem_typespec` ref
and the two objects differ at `VpiType`, the very first thing compared.

---

## 2. OUR MINTING SITE — found by ELIMINATION, not by guessing

`cen126` censuses EVERY unpacked-array element typespec in a database, keyed on
its OWNER (kind | name | name-span) — no ids, no file, no view flag. Run over
grid B (the same four element kinds declared in ELEVEN different homes) it names
the site in one table:

| home | golden | ours (pristine) | route |
|---|---|---|---|
| nested `begin` block local | `string_typespec` | `string_typespec` | `makeTypespec` — already right |
| queue / dynamic / associative local (grid C) | `string_typespec` | `string_typespec` | `makeQueueDynArrayVar` / `makeAssocArrayVar` -> `makeTypespec` — already right |
| class property / package var / module var | *no* `Elem_typespec` | *no* `Elem_typespec` | already agrees (golden leaves it empty too) |
| paren-less function (TF-ITEM) local | *no array_var at all* | *no array_var at all* | § `blockItems9`'s negative — already right |
| formal (`io_decl`) | *no array_typespec* | *no array_typespec* | ranges ride the io_decl |
| **tf BLOCK-ITEM fixed-size local** | **`string_typespec`** | **`logic_typespec`** | **`TaskFuncEmit.cpp` — the ONE hand-rolled arm** |

That arm — a class task, a class function, an out-of-body method, a package free
function and a module task all reach it — did not call `makeTypespec` at all. It
was a three-way fallback on the element's SHAPE:

```cpp
if (leaf ... == SymbolKind::PredefinedIntegerType)  -> int_typespec
else if (lct.isIntegral() && !lct.isFourState())    -> bit_typespec
else                                                -> logic_typespec
```

i.e. it reproduced exactly three rows of Surelog's table (`int`, `bit`, and the
`default`), and put `string`, `real`, `shortreal`, `chandle`, `event`, `byte`,
`shortint`, `longint`, `integer` and `time` on the wrong class.

---

## 3. THE DECODED SURELOG MODEL

`CompileHelper::compileTypespec` dispatches on the PARSE NODE of the written
data type; its builtin arm `compileBuiltinTypespec`
(`~/git-repos/Surelog/src/DesignCompile/CompileType.cpp:1126-1231`) is a CLOSED
switch, and the unpacked dimensions are wrapped around whatever it returns as an
`array_typespec` (`CompileType.cpp:1590-1614`, the `if (ranges)` arm). So the
KEYWORD decides the element typespec and the brackets decide nothing:

| written node | Surelog | field detail |
|---|---|---|
| `paIntVec_TypeLogic` / `paIntVec_TypeReg` | `logic_typespec` | + Ranges, `VpiSigned` only when `signed` is written |
| `paIntegerAtomType_Int` | `int_typespec` | `VpiSigned` true unless `unsigned` |
| `paIntegerAtomType_Integer` | `integer_typespec` | " |
| `paIntegerAtomType_Byte` | `byte_typespec` | " |
| `paIntegerAtomType_LongInt` | `long_int_typespec` | " |
| `paIntegerAtomType_Shortint` | `short_int_typespec` | " |
| `paIntegerAtomType_Time` | `time_typespec` | **no `VpiSigned` at all** |
| `paIntVec_TypeBit` | `bit_typespec` | + Ranges, signed only if written |
| `paNonIntType_ShortReal` | `short_real_typespec` | |
| `paNonIntType_Real` | `real_typespec` | |
| `paString_type` (`CompileType.cpp:1220`) | `string_typespec` | |
| **default** | **`logic_typespec`** | **<- our old answer for everything above** |

`paChandle_type` (`CompileType.cpp:2019`) and `paEvent_type` (`:2035`) are the
same dispatch one level up, giving `chandle_typespec` / `event_typespec`.

**Grid A measures the whole table in one golden** — 22 fixed-size unpacked-array
locals in ONE class task body, one per element kind, in an order that is NOT the
emitter's dispatch order and with 22 different array sizes so no cell can agree
by accident. See `CENSUS.r10uvm126.txt` §D for the full 22-row table.

---

## 4. THE LAW

> **§ `declArrayElemTsIsWrittenKeyword126`.** The ELEMENT TYPESPEC of a
> FIXED-SIZE unpacked-array BLOCK-ITEM subroutine local is the typespec class
> Surelog's `compileTypespec` mints for the declaration's **WRITTEN BASE-TYPE
> KEYWORD**, not a class derived from the element's integral shape. Span,
> `VpiSigned`, `vpiInstance`, the array_typespec's ranges and the element
> VARIABLE are exactly what they already were.

**The gate is the WRITTEN SYNTAX NODE, never the canonical type.** A declaration
that NAMES A TYPEDEF (`label126_t caption126[2]`, `paint126_e hue126[4]`, a
class handle, a struct alias) binds golden's SHARED, NAMED typespec object —
carrying a name, the typedef's own span and a `vpiInstance`. Swapping our
anonymous `logic_typespec` for an anonymous `string_typespec` there would move
the cell WITHOUT reaching golden. Returning null for those nodes is what makes
this pass's movers TO-GOLDEN-only, and it is why grid A's six typedef /
aggregate / class cells are recorded as STILL-WRONG rather than dressed up.

**This is a typespec-CLASS-only law.** `cen126` also reports the element
VARIABLE and the `vpiInstance`, and in all 22 grid-A cells BOTH were already
golden's answer before the patch — `makeReturnVar` / § `declArrayElemKind-
IsDeclKind12` had the variable right (golden itself gives an `event` element a
`logic_var` next to an `event_typespec`), and § `queueLocalElemTsInstance40` /
§ `classHomedTypeTsNoPkgInstance4` had the instance right (package for a package
free function and an out-of-body method, nothing for an in-body one).

---

## 5. THE GRIDS

`ARMS.r10uvm126.txt` says what each arm is for. Every arm is built by `arm126.sh`
with BOTH frozen binaries in BOTH views and with Surelog `-parse` for the golden.

| grid | DEF: FIXED | MOVED-WRONG | STILL-WRONG | ELAB: LAW cells | TO-GOLDEN |
|---|---|---|---|---|---|
| `g126_a_kinds.sv` (22 element kinds) | 10 | **0** | 6 | 10 | 10 |
| `g126_b_homes.sv` (11 declaration homes) | 20 | **0** | 5 | 28 | 28 |
| `g126_c_dims.sv` (1-D/2-D/3-D/dyn/queue/assoc/mixed) | 13 | **0** | **0** | 13 | 13 |
| `g126_d_inst.sv` (1/2/3 instances, module scope) | 3 | **0** | 7 | 3 | 3 |
| **total** | **46** | **0** | **18** | **54** | **54** |

`BROKE-AGREEING` (a cell that agreed with golden before and does not now) is
**0** in every grid and in both views. The 18 STILL-WRONG cells are enumerated
and explained in `CENSUS.r10uvm126.txt` §C — six are the deliberate typedef /
aggregate exclusion, five are module/package-variable array_vars our emitter does
not list at all, seven are the methods of a class declared in a MODULE, which our
listings do not carry.

Grid C's `dms126` deserves a line of its own: `string dms126[2][]` — a MIXED
fixed-then-dynamic shape whose canonical leaf is a `DynamicArrayType`, not a
string. Dispatching on the SYNTAX gets it right (`string_typespec`) where any
dispatch on the peeled canonical type cannot.

---

## 6. THE CORPUS CENSUS AND THE A-PRIORI PREDICTION

`pred126.sh` walks all 2314 pristine databases in both workdirs, reads each
row's OWN golden out of its `cmds.txt`, censuses both and scores them.
**Before the patched binary finished compiling** it named the mover set:

```
PREDICT law=1 residue=15   {default,testflags}/{BuildUVMPkg,MiniAmiq,SeqDriver,SimpleUVM}
PREDICT law=1 residue=15   default/Scoreboard
SCANNED=2314 PREDICTED_MOVERS=9 NO_GOLDEN=0
```

Nine databases, one law cell each, and it is the SAME declaration in all nine —
`uvm_reg_bit_bash_seq.svh:68`. **uhdm2rtlil holds not one law cell in 1358
databases.** SeqDriver and MiniAmiq carry the cell too even though their own head
is a different object, which is why nine databases move and only five heads do.

`SELFCHECK=1 byteverify.sh` afterwards: **MOVERS 9 / 956** surelog (the nine
names, no others) and **0 / 1358** uhdm2rtlil. `attr126.sh` attributes each one
line by line and ORDER-BLIND (Scoreboard/default is the ~50/50 coin):
**6 dump lines each, 54 in total, every one of them
`logic_typespec` -> `string_typespec` at the same span** — see
`MOVERS.r10uvm126.txt`, which also reads the three dump positions of the ONE
shared object back out of the patched database (the element `string_var`'s
typespec ref, the array_typespec's `vpiElemTypespec` ref, and one un-parented
listing in the weaklyReferenced tail).

The 15 RESIDUE cells per database are untouched, as designed.

---

## 7. THE BOUNDARY

`bound126.sh` (r10buvm30's gate, reused) compiles **every** `.sv`/`.v` under a
COPY of `tools/probe` with both binaries in both views — file list on fd 3,
children `</dev/null`, `PROCESSED` asserted against `LISTED`, subdirectory arms
included, scratch keyed on the RELATIVE path.

```
LISTED=3798  FENCED_SKIPPED=0  PROCESSED=3798  MOVED=14  NO_OUTPUT_PAIRS=294
PROCESSED-ASSERT-OK          (no ASYMMETRIC_OUTPUT: the 294 no-output pairs are
                              arms BOTH binaries reject or segfault identically)
```

The gate's own POSITIVE CONTROL is built in: it sees this pass's four grids move
(60/120, 168/336, 78/156 and 18/36 dump lines), so a silent run would have been
a broken gate, not a clean one. The four slang-fenced names are never dispatched
and never spelled — `FENCED_SKIPPED=0` is the assertion that no arm file under
`tools/probe` is named after one of them.

Three EARLIER-PASS arms moved. Each was re-measured against its own Surelog
golden and every moved cell moves **TOWARD** golden:

| arm | moved cells | verdict |
|---|---|---|
| `r10buvm8repro/v2_argts8.sv` (`string arr [2];` at :100) | 1 | **FIXED**, MOVED-WRONG 0, STILL-WRONG 0; the arm's own cmp line count and head are UNCHANGED (21748 / 1) |
| `r10sd12repro/grid12_h3.sv` (`byte` local at :24) | 1 | **FIXED**; § `declArrayElemKindIsDeclKind12`'s own cells (`n_cls`, `p_c`, `p_i`, `p_s`) all SAME-OK |
| `r10uvm20repro/t30_t.sv` (three `_f_str` cells) | 3 | **FIXED**; every queue / dynamic / associative cell in the same file SAME-OK |

The other four moving arms are this pass's own four grids. Nothing else in 3798
arms moved a byte.

---

## 8. RESIDUES AND R0

Left standing, all measured, none of them this law's:

1. **A NAMED element type binds golden's SHARED typespec object.** An `enum` /
   `struct` / `class` / plain typedef element is `enum_typespec(pk::e)` /
   `struct_typespec(pk::s)` / `class_typespec` / `int_typespec(td)` in golden —
   a name, the typedef's own span and a `vpiInstance` — and an anonymous
   `logic_typespec` / `bit_typespec` / unnamed `class_typespec` in ours. **5
   class_typespec cells + 1 int_typespec cell per UVM database**, plus 6 of grid
   A's 22 cells.
2. **An associative array of a 2-state / class element has no `Elem_typespec`
   at all in ours** where golden has one: **7 `bit_typespec` + 2
   `class_typespec` cells per UVM database** (`bit predecessors[uvm_phase]`,
   `sorted_override_queues`, …).
3. **A module-scope or package-scope keyword array** lists no `array_var` of
   ours in grid B (golden lists one with an empty `Elem_typespec`).
4. **A class declared inside a MODULE** contributes no subroutine locals to
   either of our listings (grid D, 7 ONLY-GOLDEN cells).

**R0 (next head).** The head this pass hands on is *not* one object but two:

* **SimpleUVM ×2 / Scoreboard-default (124 lines, 1 head)** — an
  `operation` `vpiOpType 15` at `uvm_object_defines.svh:1978:21-1978:76` inside
  `uvm_reg_mem_hdl_paths_seq::__m_uvm_field_automation`, over the two
  `hier_path`s `abstractions.size` and `local_data__.abstractions.size`. A
  hier_path / method-call family — check for overlap with uvm124 (method-call
  receiver name/span) and earl84 (hier_path base fold) before dispatching.
* **BuildUVMPkg ×2 (54 lines, 1 head)** — the `enum_var`
  `uvm_reg_hw_reset_seq::do_block::field_check_restore` at `:79885:25-79885:44`,
  the ELEMENT variable of an `array_var`, whose `ref_typespec` binds
  `enum_typespec(uvm_pkg::uvm_check_e)`. This is residue 1 above, one level up:
  the same declarator-array element family this pass just decoded, now asking the
  NAMED-typedef half of the question. **That is the natural next pass** — the
  instruments (`cen126`, `score126.py`, `pred126.sh`, the four grids) are already
  pointed at it, and grid A's six STILL-WRONG cells are its ready-made golden.

---

## 9. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `cen126.cpp` | the census: one CELL per unpacked-array-typed owner — array-typespec kind/span/ranges/index, ELEMENT typespec kind/name/span/ranges/`vpiInstance`, and the element VARIABLE's class. Keyed on the owner, never on ids or the view. |
| `score126.py` | the multiset golden-vs-ours(-vs-patched) join; classifies every disagreeing cell LAW / RESIDUE and every patched cell TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / MOVED-WRONG, and reports `BROKE-AGREEING` |
| `pred126.sh` | the a-priori mover predictor / corpus census over a whole workdir |
| `wide126.sh` | the nine UVM row-modes, golden vs pristine vs patched |
| `arm126.sh` | one grid arm: Surelog golden + both binaries + both views + census + the OFFICIAL `uhdm-cmp` |
| `attr126.sh` | mover attribution: path-normalised whole-dump diff, in order AND order-blind |
| `bound126.sh` | the WIDE boundary gate over every arm under `tools/probe` |
| `g126_[abcd]_*.sv` | the four grids (see `ARMS.r10uvm126.txt`) |
| `head_pris_*.cmp` / `head_pat_*.cmp` | the whole head logs, before and after, for all eleven measured row-modes |
| `PREDICT` / `MOVERS` / `CENSUS` / `GATES` / `ARMS`.r10uvm126.txt | the four evidence files and the arm index |
| `rowheads.sh` `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` | the campaign's gates, copied verbatim so this directory can re-run its own claims |
