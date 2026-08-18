# r10buvm22 — § `namedBaseUnpackedTdRetVar22` — **the return variable of a function whose return type is a typedef CARRYING UNPACKED DIMENSIONS is the object Surelog's typedef pass left unredeemed: a `ref_var` when the typedef's WRITTEN BASE is a NAMED type, an `array_var` when it is a keyword or an inline aggregate — never the `logic_var` our factory fell through to**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `a2aa8b3` |
| worktree | `/tmp/wt_r10buvm22` |
| pristine binary | md5 `d8f8bd12744497c72f2fda00b6392765` (reproduced the main tree's byte-for-byte at pass start), frozen `chmod 555` at `/tmp/r10buvm22_bin/pristine.bin` |
| patched binary | md5 `7e5f0a49e681c80d2761b2814c092469`, frozen at `/tmp/r10buvm22_bin/pat.bin` |
| production surface | `src/EmitHelpers.h` (the law + its predicate, 166 lines, 137 of them comment), `src/TaskFuncEmit.cpp` (ONE gated arm at the return-variable site, 20 lines) |
| probe surface | `tools/probe/r10buvm22repro/` only |
| deliverable | `/tmp/r10buvm22.patch`, applies clean on a FRESH `a2aa8b3` |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass** — and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines in both corpora and both modes.  What it
does is clear the head buvm21 handed over (R0) and close the whole
unpacked-array-typedef return family at once.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp lines (`2>&1`), default / testflags | **52 / 52** | **166 / 166** |
| `BuildUVMPkg` cmp lines (stderr only) | 26 / 26 | 83 / 83 |
| `BuildUVMPkg` cmp md5 (`2>&1`), both modes | `f21a1042bba06220ee5c1e4f49ff24f4` (the brief's pin, hit exactly) | `b0d8ba9e85acfcdb4650c0743e17352e` |
| head object | `ref_var` vs `logic_var` on a queue-typedef'd function RETURN variable | `hier_path (m_streams[].exists)` vs `hier_path (m_streams[ro.get_name()].exists)` — an assoc-select-with-a-call INDEX split on the wrong dots (**R0**) |
| return-variable census, `BuildUVMPkg` (4 768 joined functions) | KIND same 4 902, diff 4 | **KIND same 4 903, diff 3 — CONVERTED 1, OVER-FIRE 0** |
| the golden GRID `g22.sv` (236 scored cells) | — | **CONVERTED 100, MSW-REGRESSION 0**, still-wrong 15, same 121 |
| the golden GRID `g22b.sv` (75 scored cells) | — | **CONVERTED 51, MSW-REGRESSION 0**, still-wrong 6, same 18 |

The cmp line count went UP (52 → 166) because masks cascade: the count is
DEPTH, not distance (RESUME §9, "Ladder facts").  The head object is gone from
the log entirely and the census proves the conversion independently.

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG FIRST

`/tmp/r10buvm22_wd/pris.default.cmp` (52 lines `2>&1`, 26 on stderr, md5
`f21a1042bba06220ee5c1e4f49ff24f4`, `grep -c '^LHS:'` = 1):

```
LHS:
ref_var:   (uvm_pkg::uvm_report_message_element_container::get_elements), id:164670, line:28181:20
|vpiParent:  \_function: (…::get_elements), id:164668
|vpiTypespec: \_ref_typespec: (…::get_elements)
                |vpiActual: \_array_typespec: (queue_of_element), id:186408, line:28180:11
RHS:
logic_var: (uvm_pkg::uvm_report_message_element_container::get_elements), id:90109, line:28181:20
|vpiParent:  \_function: (…::get_elements), id:90108
|vpiTypespec: \_ref_typespec: (…::get_elements)
                |vpiActual: \_array_typespec: (queue_of_element), id:90110, line:28180:11
```

BOTH sides are set and both are objects, so this is neither `<null>` arm of
`BaseClass.h:187-198`.  `BaseClass::Compare` tests `VpiType()` BEFORE `VpiName`
and before any per-kind field, so the head's field is the **OBJECT CLASS**
(`vpiRefVar` vs `vpiLogicVar`) — the payload underneath (the `ref_typespec` to
the `array_typespec` named `queue_of_element`, same span) already agreed on both
sides, which is why nothing but the class had to move.

Site: `1800.2-2017-1.0/pp_output/uvm_pkg.sv:28180-28181`, inside
`class uvm_report_message_element_container`:

```systemverilog
  typedef uvm_report_message_element_base queue_of_element[$];
  virtual function queue_of_element get_elements();
    return elements;
  endfunction
```

**THE OWNER, verified rather than assumed.**  The object is the function's
`vpiReturn` variable (`function::Return()`), NOT a body-local: `get_elements`'
body is `return elements;`, so it contains no reference to the return NAME and
`drainFuncRet` mints no RETLOCAL for it — the census (`cen22.sh`) reports zero
`RETLOCAL` rows for this function on EITHER side.  There is exactly **ONE**
copy of the object in the whole database (view `ELABPKG`); the class has no
`DEFPKG` or `DEFCLASS` listing of this method, on either side.

## 2. THE LAW

> **§ `namedBaseUnpackedTdRetVar22`** — the RETURN VARIABLE of a function whose
> return type names a **TYPEDEF WITH UNPACKED DIMENSIONS WRITTEN ON IT**
> (`typedef <base> t[$] / [] / [idx_t] / [N];`) is
>
> * a **`ref_var`** when the typedef's WRITTEN BASE is a **NAMED TYPE** and
>   Surelog's typedef pass never attaches a typespec to that typedef — which is
>   *always* when the typedef lives in a CLASS, a MODULE or a `$unit` class, and
>   in a PACKAGE when the base resolves to a CLASS (or, in the DEF package
>   listing only, to anything named at all);
> * an **`array_var`** otherwise — i.e. whenever the written base is a KEYWORD
>   type (`int`, `logic [7:0]`, `string`) or an INLINE `struct` / `enum`;
>
> and it is **never** the `logic_var` our factory's fall-through gave a queue /
> dynamic / associative return.  The CONTAINER FLAVOUR is irrelevant, measured:
> `[$]`, `[]`, `[string]`, `[int]` and `[4]` answer identically in every row of
> the table.  So are `static` / `virtual` / method-vs-free-function and the
> HOME of the function — only the TYPEDEF's own scope and its written base
> decide.  The OUT-OF-BODY definition is **excluded**: golden answers that with
> a `class_var`, which is § `classTdLocalVarKindFollowsCompileOrder10`'s arm.

## 3. DECODED FROM SURELOG (`~/git-repos/Surelog`), NOT INFERRED

`CompileStmt.cpp:2400-2416` builds the return object with

```cpp
var = any_cast<variables*>(compileVariable(component, fC, Return_data_type,
                                           compileDesign, Reduce::No, …));
var->VpiName("");  func->Return(var);
```

and a return type written as a NAME lands in `CompileType.cpp`'s
`slStringConst` arm (`:337-431`), whose FIRST question is

```cpp
if (const DataType* dt = component->getDataType(typeName))
  if (typespec* tps = dt->getActual()->getTypespec())
    if (variables* var = getSimpleVarFromTypespec(tps, ranges, compileDesign))
      … result = var;
```

* `getSimpleVarFromTypespec` (`CompileType.cpp:78-233`) maps an
  `array_typespec` with **no `Index_typespec`** to an `array_var` — and
  `Index_typespec` is set for ASSOCIATIVE arrays only, and only on the
  ELABORATED `array_var` path (`ElaborationStep.cpp:2140`,
  `UhdmWriter.cpp:731`), never on a typedef's own typespec.  So **when the
  typedef HAS a typespec, an unpacked-array return is an `array_var`, whatever
  the container flavour** — which is exactly what the grid shows.
* When it does NOT, the arm is skipped; `design->getClassDefinition(<the alias
  name>)` cannot find a class of that name; the `class_typespec` test fails
  (the alias's typespec is the ARRAY); and control reaches the arm's tail — a
  bare `s.MakeRef_var()` carrying the declaration's typespec (`:421-431`).
  That `ref_var` is never redeemed: `swapForSpecifiedVar` /
  `lateTypedefBinding` only redeem typespecs `getSimpleVarFromTypespec` knows,
  and `UhdmWriter.cpp:1066`'s class-body `lateTypedefBinding` is commented out
  (buvm17/19).  **Golden's `ref_var` here is an UNREDEEMED `ref_var`, and the
  elaborated listing keeps it** — the brief's hypothesis, confirmed.

WHICH typedefs have no typespec is `compileTypedef`'s own three-way split
(`CompileHelper.cpp:600-1100`):

| written base | arm | `setTypespec` |
|---|---|---|
| inline `struct` / `union` | `:657-1035` | UNCONDITIONAL (`st->setTypespec(...)`) |
| inline `enum` | `:790-875` | UNCONDITIONAL |
| keyword (`int`, `logic [7:0]`, `string`, …) | `SimpleType`, `:1053-1098` | UNCONDITIONAL (`simple->setTypespec(ts)`) |
| a NAMED type (`slStringConst` / `paClass_scope`) | `DummyType`, `:890-1052` | ONLY inside `if ((reduce == Reduce::Yes) && (Package \|\| FileContent))`, and then only when the base is **not** a `class_typespec` and **not** an `unsupported_typespec` (`:906-907`); otherwise the `else` is `dummy->setUnpackedTypespec(array_tps)`, a DIFFERENT setter that `getTypespec()` does not read |

Hence: a NAMED-base unpacked typedef is un-typespec'd — so `ref_var` — in a
CLASS, a MODULE and a `$unit` class ALWAYS; in a PACKAGE it is `ref_var` when
the base is a CLASS, and when the base is a named NON-class it is `ref_var` in
the DEF listing (the `Reduce::No` pass) against `array_var` in every elaborated
listing.  Every one of those clauses is a measured grid row below.

## 4. THE GOLDEN GRID — 311 SCORED CELLS, BOTH VIEWS

`g22.sv` (homes × shapes) and `g22b.sv` (the WRITTEN-BASE axis and the
no-dimension arm) are compiled by Surelog with and without `-elabuhdm` and by
both binaries with and without `--elabuhdm`; `gridcmp22.sh` scores every
`(cell, listing)` three ways.  Golden's answer, read off the two runs:

| written base | typedef scope | golden return variable |
|---|---|---|
| `int` / `logic [7:0]` / `string` / inline `struct` / inline `enum` | any | **`array_var`** in all five listings |
| named CLASS | class / module / `$unit` class | **`ref_var`** in all listings |
| named CLASS | package | **`ref_var`** in all listings |
| named NON-class (a typedef of int / struct / enum, a type parameter) | class / module / `$unit` class | **`ref_var`** in all listings |
| named NON-class | package | **`ref_var` in `DEFPKG`, `array_var` in `ELABPKG` / `TOPMOD` / `DEFMOD`** |

and the container flavour never matters: `pc_q_cls` / `pc_d_cls` / `pc_a_cls` /
`pc_f_cls` (`[$]`, `[]`, `[string]`, `[4]`) are all `ref_var`, and
`pc_q_int` / `pc_d_int` / `pc_a_int` / `pc_a_str` / `pc_f_int` are all
`array_var`.

```
$ bash gridcmp22.sh g22.sv  <pristine> <patched> <workdir>
CONVERTED 100  MSW-REGRESSION 0  still-wrong 15  same 121
$ bash gridcmp22.sh g22b.sv <pristine> <patched> <workdir>
CONVERTED 51   MSW-REGRESSION 0  still-wrong  6  same  18
```

**MSW-REGRESSION 0** is the load-bearing number: not one cell the pristine
binary answered correctly is answered wrongly by the patched one.

## 5. THE FENCE, ENUMERATED BEFORE THE CODE WAS WRITTEN

The instruction was to find the CMP_EQUAL rows carrying our `logic_var` return
variable *first*.  `r10buvm22cen` was run over the `slang.uhdm` of **every**
database of both pristine sweeps — 1 358 `uhdm2rtlil` and 956 `surelog` — and
filtered to `RET` rows whose return typespec is an `array_typespec`.  That is
the complete population this law can reach:

* **`uhdm2rtlil`: 0 of 1 358.**  Not one function in that corpus returns an
  unpacked-array typedef.  Predicted movers: **none**.
* **`surelog`: 28 rows in 9 databases**, and only two distinct shapes:

| shape | tests | ours, pristine | golden | predicted |
|---|---|---|---|---|
| `typedef int unsigned ASSIGN_VADDR_RET_T[2];` → `top.ASSIGN_VADDR` | `ArrayExprFuncArg`, `DefaultPatternInt`, `DefaultPatternModule`, `FuncRetArray` — **all four CMP_EQUAL** | `array_var` | `array_var` | **UNMOVED** — the written base is the KEYWORD `int unsigned`, so the predicate answers `ArrayVar` and re-emits the object they already have |
| `typedef uvm_report_message_element_base queue_of_element[$];` → `…::get_elements` and `typedef TYPE types_t[$];` → `uvm_utils::find_all` | `BuildUVMPkg`, `MiniAmiq`, `Scoreboard`, `SeqDriver`, `SimpleUVM` — **all CMP_NOTEQUAL** | `logic_var` | `ref_var` (verified in the golden `uvm-1.2` database too) | **MOVERS**, by name |

So the four CMP_EQUAL rows in the family are safe *by construction*, not by
luck, and the predicted mover set was written down before the patched binary
existed:

> `BuildUVMPkg` (default, testflags) · `MiniAmiq` (default, testflags) ·
> `SeqDriver` (default, testflags) · `SimpleUVM` (default, testflags) ·
> `Scoreboard` (default only — its testflags row is `SLANG_REJECT`) = **9
> databases**, and **0** in `uhdm2rtlil`.

## 6. RESIDUES

* **R1 — the NO-DIMENSION arm of the same Surelog rule.**  `typedef <named
  type> t;` (no brackets) in a CLASS is the same un-typespec'd `DummyType`, so
  golden gives its function return a `ref_var` where we give the redeemed kind:
  cells `lc_n_tdint` / `lc_n_tdenum` / `lc_n_tdstruct` (golden `ref_var`, ours
  `int_var` / `enum_var` / `struct_var`) and `pc_tdalias` / `pf_tdalias`.
  DELIBERATELY NOT IMPLEMENTED: the two shapes the corpora actually contain are
  already right through § `aliasClassRefVar10` (a class-handle alias) and
  § `typeParamRetIsRefVar58` (a type parameter), and widening the arm would
  move `int_var` / `enum_var` / `struct_var` returns with no corpus cell to
  hold it.  8 grid cells, still-wrong on both binaries.
* **R2 — the OUT-OF-BODY family.**  `po_q_cls` / `po_q_int` / `po_f_cls` /
  `po_tdcls` / `po_tdstruct` / `po_pq_cls`: golden gives an `extern` body's
  return object a `class_var` in five of six listings and the redeemed kind in
  the `ELABPKG`/DEF listing only.  § `classTdLocalVarKindFollowsCompileOrder10`
  owns this window and this law explicitly refuses it (clause 0).  7 grid
  cells, unmoved.
* **R3 — the typespec of a package-scope class-element array typedef.**  Golden
  gives `pf_q_cls` a `class_typespec` where the DEF listing of the same typedef
  is an `array_typespec` (the `:906` exclusion drops the dims).  Not this law's
  field; noted because the grid prints it.
* **R4 — two pre-existing `BuildUVMPkg` return-kind disagreements** the census
  reports on BOTH binaries: `uvm_sequencer_base::get_arbitration` (golden
  `ref_var` / ours `enum_var`, and the two sides name DIFFERENT enum typespecs
  — `UVM_SEQ_ARB_TYPE` vs `uvm_sequencer_arb_mode`) and
  `uvm_printer::object_printed` (golden `enum_var` / ours `class_var`).  Both
  are the enum-typedef arm, adjacent to R1.

## 7. R0 — THE NEXT HEAD

`/tmp/r10buvm22_wd/pat.default.cmp` (166 lines `2>&1`, 83 on stderr, md5
`b0d8ba9e85acfcdb4650c0743e17352e`, `grep -c '^LHS:'` = 1, byte-identical
between the two modes):

```
LHS:  hier_path: (m_streams[].exists)              @30163:48-94
        |vpiActual: \_bit_select: (m_streams[])      @30163:48-57
                      |vpiIndex: \_hier_path: (ro.get_name) @30163:58-60
        |vpiActual: \_method_func_call: (exists)     @30163:73-79
        |vpiName: m_streams[].exists
RHS:  hier_path: (m_streams[ro.get_name()].exists) @30163:48-94
        |vpiActual: \_ref_obj: (m_streams[ro)        @30163:48-60
        |vpiActual: \_ref_obj: (get_name()])         @30163:61-72
        |vpiActual: \_method_func_call: (exists)     @30163:73-79
        |vpiName: m_streams[ro.get_name()].exists
```

Both sides are objects and both are `hier_path`, so `BaseClass::Compare` passes
the type test and stops at `VpiName` — behind which the `Path_elems` vector is
2 elements on golden against 3 on ours.

Source, `uvm_pkg.sv:30163`, inside `uvm_default_report_server::execute_report_message` (`m_streams` is its assoc-of-assoc recording-stream cache):

```systemverilog
if (m_streams.exists(ro.get_name()) && (m_streams[ro.get_name()].exists(rh.get_name())))
```

**We are splitting the hierarchical path on the DOTS OF THE SOURCE TEXT rather
than on the syntax**: the dot inside the subscript `[ro.get_name()]` is treated
as a path separator, producing two bogus `ref_obj`s literally named
`m_streams[ro` and `get_name()]`.  Golden instead makes the first path element
a `bit_select` named `m_streams` whose `vpiIndex` is the nested
`hier_path (ro.get_name)`.  The rest of the path — the trailing
`method_func_call (exists)` and its `rh.get_name` argument — is already
identical on both sides, so the whole head is the FIRST element's construction:
an ELEMENT SELECT whose index expression itself contains a dot.

## 8. THE GATES

All run from this worktree with `SLANG_UHDM` exported explicitly per binary and
every `cmds.txt` audited by binary PATH.

| gate | result |
|---|---|
| (1) build both, md5 | pristine `d8f8bd12744497c72f2fda00b6392765` (= main tree), patched `7e5f0a49e681c80d2761b2814c092469`, 0 errors |
| (2) goldens | patched `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `FAIL=23 PASS=0`; pristine `PASS=23 FAIL=0` |
| (3) `uhdm2rtlil` | `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in BOTH modes; `ct8rows` = **0 differing rows** vs the committed `results/gate_uhdm2rtlil.csv` AND vs this pass's own pristine sweep, status AND dump, both modes |
| (4) `surelog --mode both` | see below |
| (5) byteverify | `uhdm2rtlil`: **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL, SELFCHECK 1357/1358; `surelog`: see below |
| boundary | see below |

### Gate 4 — the `surelog` corpus, `--mode both`

```
936 CMP_EQUAL / 20 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 1 NO_UHDM /
567 SLANG_REJECT / 48 SURELOG_FAIL / 1 TIMEOUT / 2 UNTRANSLATABLE
```

identical to this pass's own pristine sweep, and `ct8rows` reports **0
differing rows over the 1 588** against BOTH the committed
`results/golden_surelog.csv` and the pristine sweep (`PASS: every row
byte-identical to the committed baseline`, status AND dump columns).  **NO ROW
CONVERTED** — `BuildUVMPkg` is still `CMP_NOTEQUAL` in both modes and nothing
was promoted.

### Gate 5 — byteverify, `surelog`: 9 / 956, EVERY ONE PREDICTED BY NAME

```
PATH_SETS_IDENTICAL (956 paths)          SELFCHECK 955 / 956 flagged
MOVER ./default/BuildUVMPkg   ./default/MiniAmiq   ./default/Scoreboard
MOVER ./default/SeqDriver     ./default/SimpleUVM
MOVER ./testflags/BuildUVMPkg ./testflags/MiniAmiq
MOVER ./testflags/SeqDriver   ./testflags/SimpleUVM
MOVERS: 9 / 956
```

exactly the set §5 wrote down before the patched binary existed.  Each was
attributed by an ORDER-BLIND, path-normalised `uhdm-dump` diff (both dumps
`sort`ed, ids stripped), and every one reports the SAME two lines and nothing
else:

```
< \_logic_var: (uvm_pkg::uvm_report_message_element_container::get_elements)
> \_ref_var:   (uvm_pkg::uvm_report_message_element_container::get_elements)
< \_logic_var: (uvm_pkg::uvm_utils::find_all)      # the four uvm-1.2 rows only
> \_ref_var:   (uvm_pkg::uvm_utils::find_all)
```

4 changed lines on the two `BuildUVMPkg` rows (one object, printed twice), 8 on
each `uvm-1.2` row (two objects).  **Zero collateral lines** — no bind, no
typespec, no location, no other object moved.

### Protected databases (md5, pristine vs patched)

| DB | verdict |
|---|---|
| `InterfaceModPort` (both modes) | SAME `59a365f3ce2c` |
| `BlackParrotComplex` | SAME `e3e354129d5a` / `73a10e8217e5` |
| `YosysOldOr` | SAME `d68e0796d62c` |
| `SVSwitch` | SAME **`4842211c4030`** — the brief's pin, hit |
| `YosysVerx` | SAME **`6ccda350c24a`** — the brief's pin, hit |

`canaries.sh` `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r);
`ctcan2.sh` PASS on both with `EXPECT_UNKNOWN=1` / `6`;
`canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0`.

### The seven row-modes (`rowheads.sh`, DEPTH not distance)

| row | pristine | patched |
|---|---|---|
| SeqDriver / SimpleUVM / Scoreboard / MiniAmiq, both modes | 17, 1 head | **17, 1 head — unchanged** |
| Earlgrey_0_1, both modes | 46, 1 head | **46, 1 head — unchanged** |
| Rggen / default | 64, 1 head | **64, 1 head — unchanged** |
| BuildUVMPkg, both modes | 52, 1 head | **166, 1 head** |

The four `uvm-1.2` rows DID move bytes (their `find_all` / `get_elements`
objects) yet their heads are unchanged: those objects sit BELOW a
17-line head, i.e. masked.  `Scoreboard/testflags` and `Rggen/testflags` are
`SKIP-NOFILE`, expected.

### The boundary gate

```
PROCESSED=3003  LISTED=3003  DIFFER=4  PRIS_REJECT=128  PATCHED_REJECT=128
./r10buvm15repro/a2_collbuiltin15.sv
./r10buvm22repro/g22.sv          <- this pass's own grid: the POSITIVE CONTROL
./r10buvm22repro/g22b.sv         <-   (proves the gate can see a moved cell)
./r10uvm69repro/a1_type.sv
```

`PROCESSED == LISTED`, reject counts symmetric (no `asym.txt`).  Both non-grid
arms were inspected line by line and **every changed line is this law's own
object in this law's own direction**:

* `r10buvm15repro/a2_collbuiltin15.sv` — `typedef int iq15[$];` (line 12,
  KEYWORD base) returned by `q15p::pkgq15`, `qcls15::mkq15` and
  `qcls15::smkq15`: `logic_var` → `array_var`, 8 lines, and NOTHING ELSE.  The
  arm's own subject — § `collArgNamedBlkLocalNoBind15`'s binds — is untouched:
  the body locals (`ploc`, `loc15`) and every `vpiActual` are byte-identical.
* `r10uvm69repro/a1_type.sv` — `typedef int qT[$]; typedef int dT[]; typedef
  int aT[string];` returned by six `p1::f_*` functions: `logic_var` →
  `array_var`, 24 lines, nothing else.

Both are golden-correct moves by the §4 table (a KEYWORD base is an
`array_var` in every listing), and both were invisible to the corpora, which is
what the wide boundary exists to catch.

## 9. HOW TO REPRODUCE

```bash
bash build22.sh /tmp/r10buvm22_cen                 # the census instrument
bash cen22.sh <golden.uhdm> <ours.uhdm>            # golden-vs-ours return-var census
bash gridcmp22.sh g22.sv  <pristine> <patched> <wd>  # 236 cells, 3-way
bash gridcmp22.sh g22b.sv <pristine> <patched> <wd>  #  75 cells, 3-way
bash sweeps22.sh <binary> <workroot> <worktree>    # both corpora, one binary
PRISTINE=… PATCHED=… ROOT=…/tools/probe bash bound22.sh
bash canaudit.sh canaries.sh ctcan2.sh
```
