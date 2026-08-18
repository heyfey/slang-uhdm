# r10uvm96 — § `castTargetKeywordTypespecKind96` — **THE SEVEN-ROW-MODE UVM HEAD CLEARED**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED** — but this pass's own arms `g96_a5_head.sv` (the head, minimised)
and `g96_a3_operands.sv` **PASS the official `uhdm-cmp` in BOTH views** where
pristine fails with the head, and that is said out loud below.

## The headline

uvm95 left ONE head on all seven live UVM row-modes — 12 cmp lines, byte
identical across the seven after id-stripping (md5 `e091a1e73be1`). It is gone.

```
uvm-1.2 tlm2/uvm_tlm2_time.svh:87       (and :104, the same cast again)
    local function real to_m_res(real t, time scaled, real secs);
      return t/real'(scaled) * (secs/m_res);

LHS golden   real_typespec:  , line:87:16, endln:87:20
RHS ours     logic_typespec: , line:87:16, endln:87:20
```

Columns 16..20 of line 87 are the four characters `real`. Everything else about
the cell already matched: the `operation` (vpiOpType 67), its span, its
`ref_typespec` (whose `VpiName` is EMPTY on **both** sides — the
`uvm_pkg::uvm_tlm_time::to_m_res` in the dump is `vpiFullName`, which uhdm-dump
SYNTHESISES from the parent chain and which no generated `Compare` reads), and
the operand `ref_obj`. Only the **kind** of the cast's target typespec differed.

## The law

> **An explicit cast's target typespec KIND is a pure function of the KEYWORD
> WRITTEN to the left of the `'` — never of the computed type.**
>
> Surelog's cast arm (`CompileExpression.cpp:2636`, `paCast`/`paConstant_cast`)
> takes `Simple_type = fC->Child(Casting_type)` and hands that PARSE NODE to
> `CompileHelper::compileTypespec`, whose keyword cases (`CompileType.cpp:1480`)
> funnel into `compileBuiltinTypespec` (`CompileType.cpp:1126`) — a switch on
> the node type, with `paNonIntType_RealTime` handled one level up
> (`CompileType.cpp:2041`). Measured cell by cell on purpose-built golden:
>
> | written | golden typespec | vpiSigned |
> |---|---|---|
> | `real` | **real_typespec** | — |
> | `shortreal` | **short_real_typespec** | — |
> | `realtime` | **time_typespec** (not real!) | — |
> | `time` | **time_typespec** | — |
> | `integer` | **integer_typespec** | 1 |
> | `longint` | **long_int_typespec** | 1 |
> | `shortint` | **short_int_typespec** | 1 |
> | `int` | int_typespec | 1 |
> | `byte` | byte_typespec | 1 |
> | `bit` | bit_typespec | — |
> | `logic`, `reg` | logic_typespec | — |
> | `string` | string_typespec | — |
> | `N'` | integer_typespec `INT:N` | — |
> | `signed'`, `unsigned'` | **no cast op at all** — a `$signed`/`$unsigned` `sys_func_call` |
>
> `compileBuiltinTypespec` opens with `bool isSigned = true` and only an
> explicit `unsigned` clears it, which is why the five integer atoms carry
> `vpiSigned:1` and real / shortreal / time / realtime / bit / logic carry no
> signedness at all.
>
> **Our two cast-typespec mint sites keyed on the SLANG TYPE instead**, which
> collapsed every `PredefinedIntegerType` onto `int_typespec` and every
> non-integral keyword onto the catch-all `logic_typespec`:
> `ExprEmit.cpp`'s cast fallback (the DEF road) and `ModuleEmit.cpp`'s
> `pendingCastTs` drain (the re-emitted/ELAB road). Both are fixed by the same
> written-keyword table, `castKeywordTypespec96` in `src/EmitHelpers.h`.

A cast to a **TYPEDEF NAME** is a different road entirely (Surelog sees
`slStringConst`, not a keyword node, and resolves the typedef's own typespec
object). `g96_a4_typedefs.sv` is the negative arm that asserts the keyword
table never reaches it — see R1 below for the one cell it still exposes.

## The corpus census, made BEFORE the patch, from PRISTINE databases

`ct96cen.cpp` restores a database and emits one row per `operation` with
`VpiOpType() == vpiCastOp`: the operation's span, the `Actual_typespec`'s KIND
and span, the SOURCE TEXT at the typespec's span (the cast target *as written*),
the `ref_typespec`'s `VpiName`, the operand kinds, the carrier and the owner.
`join96.py` multiset-joins golden against ours on **(operation span, owner
vpiFullName)** and compares only the judged shape (kind + ref name).

*(Two traps paid for here: `VpiFile` is EMPTY on most of our objects and the
nearest file-bearing ancestor is a different object on the two sides, so a
file-keyed join reported 100% disagreement — the file is a READING column only;
and a dict-keyed join drops the DEF/ELAB/import clones, so the join is a
multiset.)*

| corpus | dbs | golden cast cells | KEYWORD-family KIND disagreements |
|---|---|---|---|
| uhdm2rtlil | 1358 | 1968 | **0** (8 DIFF lines total, all `static_cast_simple` extra inner objects on a CMP_EQUAL row) |
| surelog | 956 | 5352 | **18**, every one `real` → golden `real_typespec` / ours `logic_typespec` |

The 18 sit in exactly 9 databases, two cells each:

```
  default/SeqDriver  default/SimpleUVM  default/MiniAmiq  default/Scoreboard
  testflags/SeqDriver testflags/SimpleUVM testflags/MiniAmiq
      uvm-1.2 tlm2/uvm_tlm2_time.svh  87:16-87:29  and  104:21-104:34
  default/BuildUVMPkg  testflags/BuildUVMPkg
      1800.2 pp_output uvm_pkg.sv    57204:16      and  57222:21
```

`testflags/Scoreboard` produces no database at all (no golden, no `slang.uhdm`),
which is why the mover set is nine and not ten.

**The u2r fence the brief asked for does not exist**: there is no u2r
`CMP_EQUAL` row carrying our `logic_typespec` on a `real` cast, because there is
no `real` / `shortreal` / `realtime` cast anywhere in the uhdm2rtlil corpus
(grep over every `.sv`/`.svh`/`.v` finds none), and its golden cast targets are
only `int` / `byte` / `logic` / size / typedef / struct / enum. Likewise neither
corpus contains a single `integer'` / `longint'` / `shortint'` / `time'` /
`shortreal'` / `realtime'` cast — so those six rows of the table are carried by
purpose-built golden only, and they move exactly one corpus-invisible cell
(see the boundary result below).

## The grid, golden-side, run BEFORE any code

| arm | what varies | cells | what it pins |
|---|---|---|---|
| `g96_a1_keywords.sv` | **only the keyword** (one home, one carrier) | 16 | the table above; `int`/`byte`/`bit`/`logic`/`reg`/`8'` sit beside the movers as controls that must NOT move |
| `g96_a2_homes.sv` | **only the home and carrier** (`real'` everywhere) | 12 | class method in a package (the head's own shape), package function, module function, module task, `initial`, `always_comb`; as return / assignment / operand / call arg / condition |
| `g96_a3_operands.sv` | **only the operand** | 18 | bare var, parameter, int literal, real literal, bit-select, part-select, indexed part-select, unpacked element, member, typedef'd struct member, function call, concat, operation, nested cast, ternary — plus `shortreal'` and `realtime'` on two of them so the arm cannot pass by agreeing on `real` alone |
| `g96_a4_typedefs.sv` | **NEGATIVE** — a typedef of each moving keyword | 8 | a patch keyed on the computed TYPE instead of the written keyword would light this arm up; it does not |
| `g96_a5_head.sv` | the head, minimised | 2 | a package class with `local function real … return t/real'(scaled) * (secs/m_res);` |

Scored three-way (golden / pristine / patched) by `three96.sh`, **both views**:

```
 g96_a1_keywords  def   CELLS 16  ALREADY-OK 6  FIXED 7  BROKE 0  STILL 3
 g96_a1_keywords  elab  CELLS 16  ALREADY-OK 6  FIXED 7  BROKE 0  STILL 3
 g96_a2_homes     def   CELLS 12  ALREADY-OK 0  FIXED 12 BROKE 0  STILL 0
 g96_a2_homes     elab  CELLS 12  ALREADY-OK 0  FIXED 10 BROKE 0  STILL 2
 g96_a3_operands  def   CELLS 18  ALREADY-OK 1  FIXED 17 BROKE 0  STILL 0   pat PASS_CMP
 g96_a3_operands  elab  CELLS 18  ALREADY-OK 1  FIXED 17 BROKE 0  STILL 0   pat PASS_CMP
 g96_a4_typedefs  def   CELLS  8  ALREADY-OK 7  FIXED 0  BROKE 0  STILL 1
 g96_a4_typedefs  elab  CELLS  8  ALREADY-OK 7  FIXED 0  BROKE 0  STILL 1
 g96_a5_head      def   CELLS  2  ALREADY-OK 0  FIXED 2  BROKE 0  STILL 0   pat PASS_CMP
 g96_a5_head      elab  CELLS  2  ALREADY-OK 0  FIXED 2  BROKE 0  STILL 0   pat PASS_CMP
```

**`g96_a5_head.sv` and `g96_a3_operands.sv` go from `CMP_FAIL / heads 1 / 12
cmp lines` on the pristine binary to `PASS_CMP / heads 0 / 0 cmp lines` on the
patched one, in BOTH the default and the `-elabuhdm` view.** Said out loud, as
the standing brief requires. `BROKE` is **0** in all ten runs.

The `STILL` cells are all pre-existing and byte-unchanged by the patch — they
are R1/R2/R3 below.

## Gates

See `GATES.r10uvm96.txt` for the full transcript. Summary:

* goldens **23/0** patched and pristine, `/bin/false` **0/23**;
* u2r `testflags` and `default` both **679 / 50 / 2**; `ct8rows` vs the
  worktree's committed `results/gate_uhdm2rtlil.csv`: **PASS, 0 differing rows**
  (status AND dump);
* surelog `--mode both`: **936 CMP_EQUAL / 20 CMP_NOTEQUAL** — the *identical*
  histogram to the pristine sweep run from the same worktree; `ct8rows` vs the
  committed `results/golden_surelog.csv`: **PASS, 0 differing rows over 1588**;
  **no row converted, nothing promoted**;
* `byteverify SELFCHECK=1`: u2r **MOVERS 0 / 1358**; surelog **MOVERS 9 / 956**,
  and the nine are **exactly the nine predicted by name** in
  `PREDICT.r10uvm96.txt` before the patched binary existed. Each mover's
  path-normalised, id-stripped `uhdm-dump` diff is **exactly 8 lines** —
  2 casts × (the in-tree copy + the design's top-level typespec listing) ×
  (removed, added) — and the count is the same **ORDERED and ORDER-BLIND**, so
  Scoreboard/default's ~50/50 coin did not flip and the whole move is the law's;
* pins: `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` **SAME**,
  `SVSwitch` **4842211c4030**, `YosysVerx` **6ccda350c24a** — all ten cells;
* canaries `ok=56 changed=0` (surelog) and `ok=9 changed=0` (u2r);
  `ctcan2.sh` PASS on both; `canaudit.sh audited=33 UNCOVERED=0 FENCE-BREACH=0`;
* wide boundary from a COPY of `tools/probe` (`bound96.sh`, no path filter,
  both views): **LISTED=2921 PROCESSED=2921 PROCESSED-ASSERT-OK**,
  `RC_PAIRS_COMPARED=5842`, **RC_DIFF 0**, **ASYMMETRIC_OUTPUT 0**,
  **MOVED=10** — 8 are this pass's own four moving arms × 2 views, and the
  other 2 are `r10v63repro/v4_values.sv:18` `return integer'(v - 1);`
  (`int_typespec` → `integer_typespec`), which golden confirms is **TO-GOLDEN**;
  that arm's `uhdm-cmp` output is byte-identical before and after (40 lines,
  1 head), so its head did not move.

## The new head — R0 for the next pass

All seven row-modes now head at **17 cmp lines, 1 head**, and it is one law:

```
LHS: <null>
RHS:
ref_typespec: (uvm_pkg::uvm_port_base::this_type)
|vpiParent:
\_class_typespec: (this_type), line:199:11, endln:199:24
|vpiFullName:uvm_pkg::uvm_port_base::this_type
|vpiActual:
\_class_typespec: (this_type), line:199:11, endln:199:24
```

`uvm-1.2 base/uvm_port_base.svh:199` — `typedef uvm_port_base #(IF) this_type;`
inside `class uvm_port_base`. `LHS: <null>` is the SINGULAR `SafeCompare`
overload naming OURS: golden's `class_typespec` leaves the slot EMPTY and we
fill it with a `ref_typespec` whose `Actual_typespec` is the class_typespec
itself (a self-referential typedef alias). The three id-stripped hashes across
the seven (`a686e47a969a` SeqDriver, `6f5e1cdbb514` SimpleUVM + Scoreboard,
`183c9498dfb9` MiniAmiq) differ ONLY in the test package name that uhdm-dump
synthesises into the parenthesised `vpiFullName` (`adpcm_pkg::this_type` /
`this_type` / `svaunit_pkg::this_type`) — the same object, the same slot, the
same law. **BuildUVMPkg is unchanged at 152 lines / 1 head** (its own head is
deeper than the real-cast cells and did not move).

## Residues, named for the queue

* **R1 — `realtime` TYPEDEF cast** (`g96_a4_typedefs.sv:24`, both views,
  pre-existing and untouched): `typedef realtime rtime_t; … rtime_t'(q)` —
  golden `time_typespec`, ours `real_typespec`. The typedef road builds the
  alias's typespec from slang's type (a `FloatingType`), and slang has no
  separate `realtime`; Surelog's `paNonIntType_RealTime` → `time_typespec` rule
  applies to the DECLARATION too. Corpus-invisible today.
* **R2 — `string'(x)` in a MODULE `initial`** (`g96_a1_keywords.sv:24`, both
  views, pre-existing): golden `string_typespec`, ours `integer_typespec`.
  `StringType` is not in `isTypeSyntaxKind`, so a module-scope `string'` never
  reaches the fallback's landed `string` arm (§ `stringCastKeepsStringTypespec26`)
  — it falls into the *size*-cast road, whose bind of the word `string` fails
  and leaves a valueless `integer_typespec`. All 52 `string_typespec` cast cells
  in the surelog corpus agree today, so this too is corpus-invisible.
* **R3 — `signed'(x)` / `unsigned'(x)` as a `$display` argument**
  (`g96_a1_keywords.sv:25-26`, both views, pre-existing): golden emits a
  `$signed` / `$unsigned` `sys_func_call` and NO cast operation; we emit a
  `vpiCastOp` operation with no `Typespec()` at all (`<noref>`). The landed
  `SignedCastExpression` arm does not reach this shape.
* **R4 — cast-operation MULTIPLICITY** (the 1,108 remaining surelog census DIFF
  lines and the two `STILL` cells of `g96_a2_homes` elab): golden and we hold
  *different numbers of copies* of the same cast at the same span (DEF + ELAB +
  per-import clones). Not a KIND question and not touched here.
* **R5 — `uvm_severity'(…)`** (13 surelog cells): golden mints
  `unsupported_typespec`, we mint `enum_typespec`. A late-typedef-binding
  question, unrelated to the keyword table.

## Files

```
ct96cen.cpp   the cast-target census (build line at the top of the file)
cen96.sh      run it over a whole verify_golden workdir
join96.py     multiset join, key = (operation span, owner vpiFullName)
three96.sh    three-way arm scorer, golden / pristine / patched, rc recorded
bound96.sh    the wide boundary gate (fd-3 list, children </dev/null,
              PROCESSED asserted, per-cell rc compared)
pins96.sh     the named protected databases, md5 side by side
byteverify.sh canaries.sh ctcan2.sh canaudit.sh ct8rows.sh rowheads.sh
              carried forward unchanged from r10uvm95repro
g96_a1..a5    the five golden arms
CENSUS / GRID / GATES / PREDICT / INPUTS .r10uvm96.txt   the measurements
head_{pris,pat}_default_{SeqDriver,BuildUVMPkg}.cmp      the head, before/after
```
