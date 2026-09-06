# r10earl111 — § `modLocalIntTsFold111` — **A MODULE-SCOPE PARAMETER'S FOLDED SELECT WIDTH CARRIES ITS OWN DECLARATION TYPESPEC, AND THE COMMENT THAT SAID OTHERWISE WAS READING THE WRONG AXIS** — the Earlgrey_0_1 testflags 17-line head CLEARED

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted**
and **NO CORPUS ROW CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own `FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `62e24789` |
| pristine binary | md5 `a09a72d01f72de09bd863bd5d20943d4`, built from this pass's OWN worktree at a clean `62e24789` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary | md5 `82ecb5ca0ee9caf5bdbaec83db901e6e`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` ONLY |
| probe surface | `tools/probe/r10earl111repro/` only |
| the head | **Earlgrey_0_1/testflags, 17 cmp lines, ONE head — CLEARED.**  17 → **364**, one head, a DIFFERENT object: the line count is UP because the new head is a 364-line `hier_path` decompile, and that object is the one `own111` named on the PRISTINE databases before a line of production code was written |
| Earlgrey_0_1/default | **31 lines, unchanged, cmp log BYTE-IDENTICAL** — r10earl107's pre-existing `u_pinmux.gen_mio_periph_in[0].data_mux` null, which this pass does not touch (its database DOES move; the judge stops earlier) |
| corpus census | both corpora × both modes, 2314 databases, 125 676 golden pairs: **TO-GOLDEN 12, AWAY 0, MOVED-WRONG 0, ONE-SIDED-CHANGED 0**; the select-bound typespec-EDGE population of the whole campaign goes **12 → 0** |
| grids | 6 arms × 2 views, calibrated golden-vs-golden at 0 DIFF: **AWAY 0 and MOVED-WRONG 0 in every arm and every view** |
| goldens | 23 PASS / 0 FAIL on the patched binary; `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (the negative control) |

---

## 1. THE JUDGE, DECODED FIRST — `own111`, the owner finder

The brief handed this pass a `ref_typespec` head with `RHS <null>`.  RESUME.md
§9's head-decode discipline says that shape is `BaseClass::SafeCompare`'s
SINGULAR overload called with `rhs == nullptr`: it names the VALUE as
`m_failedLhs` and **never names the OWNER**.  `own111.cpp` runs the OFFICIAL
`design::Compare` (the same call `uhdm-cmp` makes), then READS the parent chain
instead of guessing it, and prints every field the generated Compares actually
read.  Full output in `OWNER.r10earl111.txt`:

```
== ITERATION 0 : design::Compare -> 1
   HEAD LHS(golden) = ref_typespec id:793443
   HEAD RHS(ours)   = <null>
   ref_typespec fullname='work@top_earlgrey.u_xbar_main.u_sm1_17' name='' defname=''
   |vpiActual -> int_typespec name='' defname='' alias=<null> instance=<null>
                 signed=0 cast=<null> ranges=0  @tlul_socket_m1.sv 73:14-73:26
   |vpiParent -> constant name='' dec='2' size=32 value='UINT:2' ct=9
                 @tlul_socket_m1.sv 105:61-105:66
       |vpiParent -> param_assign @tlul_socket_m1.sv 73:27-73:44
           |vpiParent -> module_inst name='u_sm1_17' @xbar_main.sv 532:3-545:5
               |vpiParent -> module_inst name='u_xbar_main' @top_earlgrey.sv 888:3-927:5
   OWNER->Typespec() is EXACTLY the head
   MASKED golden owner's Typespec := <null>; re-running.
== ITERATION 1 : design::Compare -> -57
   HEAD = hier_path @tlul_socket_m1.sv 109:19-109:36
   golden 'tl_h_i[0].a_valid'   ours 'tl_h_i[i].a_valid'
   NOT a singular ref_typespec-with-null-RHS head -- the family is exhausted.
```

Three facts the judge hands over, none of them inferred:

1. **The Compare-visible payload of the object golden hangs is EMPTY except
   its kind.**  `ref_typespec::Compare` reads `VpiName`, `VpiDefName` and
   `Actual_typespec`; `int_typespec::Compare` reads `typespec::Compare`
   (`VpiName`, `Typedef_alias`, `Instance`) plus `Cast_to_expr`, `VpiSigned`
   and `Ranges`.  Golden's object has **empty names, NO Typedef_alias, NO
   Instance, no cast, no ranges and `VpiSigned` 0**.  A freshly minted
   `MakeInt_typespec()` therefore compares EQUAL to it — sharing versus
   copying is invisible, because no generated Compare reads `VpiParent`.
2. **The owner is a `constant`, and its `vpiParent` is the `param_assign` of
   the localparam whose value it is.**  That parent is Surelog's own
   fingerprint (`CompileExpression.cpp:2881` / `:2949`,
   `result->VpiParent(param_ass)`) and it identifies the exact code path that
   produced the object — see §2.
3. **The family the judge reaches through this edge is ONE cell wide.**
   Masking it moves the head straight into a different family, and that next
   object is the R0 this pass hands on (§7) — named before the patch existed
   and confirmed on the patched binary afterwards
   (`OWNER_AFTER.r10earl111.txt`, `HEAD_AFTER_Earlgrey_testflags.cmp`).

### the SOURCE

```systemverilog
 72:  localparam int unsigned IDW   = top_pkg::TL_AIW;   // 8
 73:  localparam int unsigned STIDW = $clog2(M);         // 1 or 2, per instance
 89:  for (genvar i = 0 ; i < M ; i++) begin : gen_host_fifo
105:    assign unused_tl_h_source = tl_h_i[i].a_source[IDW-1 -: STIDW];
235:  for (genvar i = 0 ; i < M ; i++) begin : gen_idrouting
236:    assign hfifo_rspvalid[i] = ... (drsp_fifo_o.d_source[0+:STIDW] == i);
237:    assign dfifo_rspready[i] = ... (drsp_fifo_o.d_source[0+:STIDW] == i) ...
```

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT INFERRED — and **THE COMMITTED COMMENT IS REFUTED**

`include/UhdmExporter.h` carried this sentence above `stampFoldedPkgParamTs`:

> *"A MODULE-scope parameter has no such object and is left bare (golden:
> BlackBePipeInt's `[0+:vaddr_width_p]` fold carries no vpiTypespec while the
> sibling `[0+:dword_width_gp]` does)."*

Both halves of that observation are real — they are re-measured here, in the
corpus, and they still hold (`CENSUS_PRE_surelog.txt`, `BlackBePipeInt`
`15772:51-15772:64` BARE beside `15773`/`15774`/`15775` stamped).  **The
inference from them is wrong.**  The axis is not the parameter's SCOPE.

### 2.1 where the object comes from

`CompileHelper::compileParameterDeclaration`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:3542-3712` and
`:3788-3878`) gives a `parameter` object a `Typespec` by exactly two routes:

* **an EXPLICIT data type** — `ts = compileTypespec(..., Data_type_or_implicit, ...)`
  at `:3546`, hung on the parameter at `:3705-3710`.  The object is located at
  the **type syntax**, which is why the head's `int_typespec` spans
  `73:14-73:26` = the `int unsigned` of `localparam int unsigned STIDW`;
* **no declared type, but an RHS that compiled to a `constant`** — `:3788`
  `if (rhs && (rhs->UhdmType() == uhdmconstant)) { if (ts == nullptr) { … } }`,
  which synthesizes a typespec per const-type and locates it at the whole
  **parameter declaration** node (`fC->populateCoreMembers(nodeId, nodeId, its)`).
  `vpiDecConst` alone falls through with no object at all.

If neither fires, the parameter has NO `Typespec`.

### 2.2 how it reaches the folded value

`CompileHelper::compileExpression`'s identifier arm
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:2865-2907` for the
instance netlist, `:2919-2977` for the component) substitutes a parameter read
by **cloning the `param_assign`'s Rhs**, re-locating the clone at the
REFERENCE (`fC->populateCoreMembers(child, child, result)` — which is why the
head constant sits at `105:61-105:66`, not at the declaration), and then:

```cpp
} else if (lhs->UhdmType() == UHDM::uhdmparameter) {
  if (ref_typespec *lhs_rt = ((UHDM::parameter *)lhs)->Typespec()) {
    tps = lhs_rt->Actual_typespec();
  }
}
expr *res = (expr *)result;
if (tps && (res->Typespec() == nullptr)) {
  ref_typespec *tps_rt = s.MakeRef_typespec();
  tps_rt->VpiParent(res);
  tps_rt->Actual_typespec(tps);
  res->Typespec(tps_rt);
}
```

**There is no scope test anywhere on that path.**  The folded value carries the
parameter's own declaration typespec whenever the parameter HAS one.

### 2.3 so why is `vaddr_width_p` bare?

```systemverilog
bp_common_aviary_defines.svh:42:  , localparam vaddr_width_p = proc_param_lp.vaddr_width
bp_be_pipe_int.sv:45:  wire [vaddr_width_p-1:0] pc = reservation.pc[0+:vaddr_width_p];
```

`vaddr_width_p` is **IMPLICITLY typed** *and* its RHS is a **struct-member
read**, not a constant, so neither route in §2.1 fires and the parameter
carries no `Typespec` to copy.  `dword_width_gp` is a package localparam whose
RHS is the literal `64`, so the second route fires.  The two cells differ by
**what the declaration gave Surelog**, and the scope agreement was a
coincidence of that one design.  Earlgrey's `localparam int unsigned STIDW`
takes the FIRST route, in a module, and is stamped — which is the head.

### 2.4 the stamp matrix, MEASURED — `g2_kind111.sv`

One declared type per row, same scope, same select shape, so exactly one axis
moves.  Golden (`-parse -elabuhdm`) hangs a DIFFERENT UHDM kind per row:

| declared type | golden's object |
|---|---|
| `int unsigned` | `int_typespec` sg=0 |
| `int` / `int signed` | `int_typespec` **sg=1** |
| `integer` / `integer unsigned` | **`integer_typespec`** |
| `byte` / `byte unsigned` | **`byte_typespec`** |
| `shortint` | **`short_int_typespec`** |
| `longint` | **`long_int_typespec`** |
| `bit` | **`bit_typespec`** rng=0 |
| `bit [3:0]` | `bit_typespec` **rng=1** |
| `logic` | **`logic_typespec`** rng=0 |
| `logic [7:0]` | `logic_typespec` **rng=1** |
| `pk::i_t` (typedef of `int`) | `int_typespec` **n='i_t' inst='pk'** sg=1 |
| `pk::w_t` (typedef of `logic[3:0]`) | `logic_typespec` **n='w_t' inst='pk'** rng=1 |
| a module-local typedef of `int` | `int_typespec` n='li_t' **alias=`ref_typespec`** |
| IMPLICIT, literal RHS | `int_typespec` sg=0 (the §2.1 second route) |
| IMPLICIT, struct-member RHS | **BARE** (the `vaddr_width_p` row) |

**Every one of those kinds, ranges, names, instances and aliases is a field a
generated `Compare` READS.**  This emitter site holds a slang symbol, not
Surelog's object, and the only thing it can mint faithfully is the FIRST row:
a bare `int_typespec` whose sole extra field is `VpiSigned`.  Minting one
anywhere else would replace a MISSING object with a WRONG one — which is
exactly the abstention § `psBoundPkgParamTs31` already wrote into this function
for a different reason.

---

## 3. THE LAW

> **§ `modLocalIntTsFold111`** — the folded WIDTH of an indexed part-select
> closing a DOTTED hier_path carries a `ref_typespec` to the read parameter's
> own declaration typespec **whatever scope that parameter lives in**, not only
> a package.  This site admits the non-package case for the ONE declared type
> whose Surelog object it can mint field-for-field — the integer atom `int`
> (with or without `unsigned`/`signed`), a bare `int_typespec` carrying only
> `VpiSigned` — and leaves every other declared type, and every implicitly
> typed parameter, BARE.

Implementation: `stampFoldedPkgParamTs` takes a new **`modIntAtom111`** flag,
**default `false`**, so the four call sites this pass does not own keep their
behaviour to the byte.  It is passed `true` at exactly the two
§ `elabHierSelWidthFold` hier_path width-fold sites, INSIDE their existing
guards, so § `connIpsPkgParamBoundNoTs65`'s High_conn carve-out and
§ `connMpRootIpsBoundKeepsTs65v`'s modport carve-out still decide first.
The admission test is `modLocalIntAtomTs111` (`src/ExprEmit.cpp`): the declared
type SYNTAX is `SyntaxKind::IntType` with no packed dimension, and the slang
type is integral, 32 bits, two-state.  A `NamedType` (any typedef) and an
`ImplicitType` both fail it, which is the whole point.

### the four predecessor laws are UNDISTURBED, and that is measured

| law | its call site | what this pass did |
|---|---|---|
| § `qualPkgParamFoldTs` | ExprEmit ~15257 | untouched — no flag, `::`-qualified reads only |
| § `psBoundPkgParamTs31` | ExprEmit ~15419 | untouched — no flag, `declTsOnly=true` |
| § `fcArgFoldParent32` | ExprEmit ~15473 | untouched — no flag |
| § `connIpsPkgParamBoundNoTs65` / § `connMpRootIpsBoundKeepsTs65v` | the two sites this pass DOES own | the new flag rides INSIDE their guards; `g5_neg111.sv` c4 and the corpus's `flash_phy.sv:128/133` both stay BARE |

The fix wanted none of earl110's machinery: no generate-depth computation, no
name renderer, no scope walk.  It reads one slang declared type.

---

## 4. THE CORPUS CENSUS — `cen111` + `censweep111.sh` + `score111.py`

`cen111.cpp` enumerates `Serializer::AllObjects()` and emits one row per
constant sitting in ANY select-bound slot — an `indexed_part_select`'s
`Base_expr`/`Width_expr`, a `part_select`'s bounds, a `bit_select`'s index, a
`range`'s bounds — so the four predecessor laws' OWN sites are inside the
census and an AWAY there cannot hide.  The VALUE is the COMPARE-VISIBLE
typespec edge and nothing else (earl60's `attrv60.py` lesson: a span-carrying
payload once hid an `Instance` flip).  The span is in the KEY only, to join the
two sides; the FILE is deliberately not in the key, because **our select-bound
constants carry an EMPTY `VpiFile`** — measured, not assumed: with the file in
the key, 4 of 22 829 Earlgrey keys joined.

**Calibration first** (`CALIB.r10earl111.txt`): golden-vs-golden reads
**20 888 keys, 0 DIFF** on Earlgrey and 259 keys, 0 DIFF on BlackBePipeInt.

`censweep111.sh` ran it over EVERY database in both corpora, both modes —
`LISTED 1573 / PROCESSED 956` (surelog) and `LISTED 1462 / PROCESSED 1358`
(uhdm2rtlil), ACCOUNTING PASS on both, `CENFAIL 0`.

### 4.1 PRISTINE vs golden — the population, before the patch

| | surelog | uhdm2rtlil |
|---|---|---|
| golden pairs | 110 894 | 14 782 |
| **EDGE** (BARE vs stamped) | **12** | **0** |
| PAYLOAD (same shape, different typespec) | 9 | 0 |
| COUNT (same payload SET, different arena multiplicity) | 8 592 | 908 |
| G-ONLY / O-ONLY | 1465 / 354 | 0 / 16 |

**All 12 EDGE cells are `Earlgrey_0_1`, both modes, all `IPS.width`, all at
three `tlul_socket_m1.sv` sites, and all in ONE direction — golden stamped,
ours bare.  There is not a single cell anywhere in either corpus where WE
stamp and golden does not.**  The 9 PAYLOAD cells are the UVM associative-array
`uvm_phase` `class_typespec` residue (R2 below), untouched by this law.

### 4.2 PATCHED — golden / pristine / patched

| | surelog | uhdm2rtlil |
|---|---|---|
| **TO-GOLDEN** | **12** | 0 |
| **AWAY** | **0** | **0** |
| **MOVED-WRONG** | **0** | **0** |
| **ONE-SIDED-CHANGED** | **0** | **0** |
| STILLWRONG (the COUNT residue) | 8601 | 908 |
| EDGE, patched vs golden | **0** | **0** |

**The select-bound typespec-edge family is CLOSED across both corpora and both
modes.**

---

## 5. THE GRIDS — six arms, two views each

`grid111.sh`; scores in `GRIDSCORE.r10earl111.txt`, per-arm detail in
`/tmp`-free form beside each arm.  Two scores are printed per arm: the STRICT
multiset and the SHAPE score.  They differ only where a key's payload SET
already matched golden but its arena MULTIPLICITY did not — a pre-existing
def/elab copy count that no generated `Compare` can read (`expr::Compare` reads
the constant's `Typespec`, never how many arena copies exist).  `g6_view111`
proves the distinction rather than asserting it: STRICT calls it MOVED-WRONG 1,
and the OFFICIAL `uhdm-cmp` calls that database **17 lines → 0, EQUAL**.

| arm | what it moves | SHAPE TOGOLD | AWAY | MOVED-WRONG | official cmp |
|---|---|---|---|---|---|
| `g1_head111` | the head reproduced: module-body `localparam int unsigned`, `+:` and `-:` halves, dotted path, unpacked struct array, one generate level | 2 / 2 | **0** | **0** | 58/1 → 58/1, log byte-identical |
| `g2_kind111` | the 17-row declared-type matrix | 3 / 3 (`int unsigned`, `int`, `int signed`) | **0** | **0** | 40/1 → 40/1, byte-identical |
| `g3_scope111` | module body / parameter port list / generate block / depth 2 / depth 0 / interface / package | 2 / 2 | **0** | **0** | 58/1 → 58/1, byte-identical |
| `g4_site111` | the same parameter in EVERY select slot (the predecessors' sites) | 2 / 2 | **0** | **0** | 58/1 → 58/1, byte-identical |
| `g5_neg111` | the seven negative controls | **0** (by design) | **0** | **0** | 11/1 → 11/1, byte-identical |
| `g6_view111` | one module instantiated twice: DEF + two ELAB copies | 1 / 1 | **0** | **0** | **17/1 → 0/0 EQUAL** |

### 5.1 `g5_neg111` cell by cell — the controls held

| cell | shape | golden | pristine | patched |
|---|---|---|---|---|
| c1 `:46` | **the `vaddr_width_p` shape** — IMPLICIT localparam, struct-member RHS | BARE | BARE | **BARE** ✓ |
| c2 `:47` | the same RHS with an EXPLICIT `int unsigned` | stamped | BARE | **stamped, golden's object exactly** |
| c3 `:48` | an OVERRIDABLE `parameter int` in a dotted select | stamped sg=1 | stamped sg=1 | unchanged |
| c4 `:49` | a module `int` localparam in an ELABORATED port High_conn | BARE | BARE | **BARE** ✓ (§ `connIpsPkgParamBoundNoTs65`) |
| c5 `:50` | a PACKAGE `parameter int`, qualified, in a High_conn | stamped | BARE | unchanged (R3) |
| c6 `:51` | an overridable `parameter int` on a PLAIN select | stamped | stamped | unchanged |
| c7 `:52` | the `generate_test/dut.sv:52` shape — implicit overridable parameter, plain select, High_conn | BARE | BARE | **BARE** ✓ |

**c1 is the cell the refuted comment was written from, and the law refuses it —
measured, not argued.**

---

## 6. THE GATES, AND THE MOVERS

### 6.1 every gate

| gate | result |
|---|---|
| build | both binaries `-j 2`, md5s taken separately, frozen `chmod 555` BEFORE any sweep |
| goldens | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| u2r testflags + default | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, both modes |
| `ct8rows` u2r | **PASS** vs the committed `results/gate_uhdm2rtlil.csv` **and** vs this pass's own pristine control, both modes — every row byte-identical, dump column included |
| `byteverify` u2r | **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL, `SELFCHECK=1` 1357/1358 flagged |
| surelog both modes | **471 CMP_EQUAL / 10 CMP_NOTEQUAL** (default) + **466 / 9** (testflags) — identical to pristine |
| `ct8rows` surelog | **PASS** vs the committed `results/golden_surelog.csv` and vs the pristine control |
| `byteverify` surelog | **MOVERS 2 / 956** — both PREDICTED BY NAME (§6.2) |
| canaries | surelog **ok=52 changed=0 absent=0**; u2r **ok=8 changed=0 absent=0** |
| `ctcan2` | **PASS** on both corpora |
| `canaudit canaries.sh ctcan2.sh` | **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs | `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr` SAME in both modes; **`SVSwitch` `4842211c4030`**, **`YosysVerx` `6ccda350c24a`** — the brief's pins to the digit |
| heads | the seven-row head set, both modes: **11 of the 12 measurable `uhdm-cmp` logs BYTE-IDENTICAL**; the twelfth is the target |

Every `cmds.txt` in all four sweep workdirs was audited by BINARY PATH:
`/tmp/r10earl111_pris.bin` in the pristine workdirs and
`/tmp/r10earl111_pat.bin` in the patched ones, one distinct path each — never
the main-tree binary `verify_golden.py` silently defaults to.  The status
histograms are quoted above rather than a bare pass count, because a rc=139
segfault is recorded as `SLANG_REJECT` wearing the last stderr warning.

### 6.2 the two movers, PREDICTED BEFORE THE PATCHED SWEEP AND THEN ATTRIBUTED

`predict111.sh` was run on the PRISTINE censuses only.  The law can touch
nothing but a constant that is ALREADY in our database in the `IPS.width` slot,
ALREADY bare, and sized 32 — it folds nothing new and moves nothing.  That
over-prediction is **44 keys corpus-wide**, split into

* **PREDICT MOVE 12** — golden stamped, ours bare → the twelve Earlgrey cells;
* **PREDICT RISK 32** — golden BARE too; the law must leave every one alone.
  Each was classified by hand against its source and each is refused by a
  DIFFERENT clause, which is why they are worth listing:

  | risk class | rows | why the law cannot reach it |
  |---|---|---|
  | `bp_be_pipe_int.sv:45` `vaddr_width_p` | BlackBePipeInt ×2 | IMPLICIT declared type |
  | `flash_phy.sv:128/133` `BankAddrW` | Earlgrey ×2 | package param inside an ELABORATED port High_conn — § `connIpsPkgParamBoundNoTs65` |
  | `prim_ram_2p_async_adv.sv:178/185` `Width` | Earlgrey ×2 | overridable `parameter int` on a PLAIN select — neither of this law's two sites |
  | `flash_ctrl_pkg` mixed-payload cells | Earlgrey ×2 | package params on the OLD path, already matching golden |
  | `generate_test/dut.sv:52…87` `DATA_WIDTH` | u2r ×2 | implicit + overridable + plain select + High_conn |

  **`NO-GOLDEN-KEY` count: 0** — every bare 32-bit `IPS.width` constant we emit
  in either corpus has a matching golden key, so the law cannot stamp a
  constant golden does not have.

**THE PREDICTION: exactly two byte movers, `Earlgrey_0_1/default` and
`Earlgrey_0_1/testflags`; zero in uhdm2rtlil; no status or dump row changes.
All three hold.**  (`SeqDriver/default`, the documented ~50/50 coin, did not
flip this time.)

Both movers were then attributed line by line with the SECTIONED,
path-normalised, ORDER-BLIND whole-dump diff (`attrib111.sh` +
`secattr111.py`).  The sectioning cuts at `\_weaklyReferenced:` and NOT at
`|uhdmtopModules:` alone, because the last such section runs to end-of-file and
swallows the tail — the tail is unreachable to the judge and is never counted:

```
Earlgrey_0_1/testflags   ADDED 696  by region {ELAB: 609, TAIL: 87}   REMOVED 0
Earlgrey_0_1/default     ADDED 696  by region {ELAB: 609, TAIL: 87}   REMOVED 0
```

**ZERO lines removed, in either database, in any region.**  The 609 ELAB lines
are 87 stamped constants (29 per generate-block site × three sites) and nothing
else — every added line is one of exactly seven spellings:

```
29 x3  \_ref_typespec: (work@top_earlgrey.u_xbar_main.u_smN_N.gen_host_fifo[N])
29 x3  \_ref_typespec: (work@top_earlgrey.u_xbar_main.u_smN_N.gen_idrouting[N])
29 x3  \_int_typespec: , line:N:N, endln:N:N
29 x3  \_constant: , line:N:N, endln:N:N      (the constant re-printed under the ref)
29 x3  |vpiTypespec:   |vpiActual:   |vpiParent:   |vpiFullName:…
```

---

## 7. RESIDUES, and R0

* **R0 — THE NEXT HEAD, NAMED BEFORE THE PATCH EXISTED** (`own111`'s mask
  ladder, iteration 1, on the PRISTINE databases) and confirmed on the patched
  binary afterwards (`OWNER_AFTER.r10earl111.txt`,
  `HEAD_AFTER_Earlgrey_testflags.cmp`).  `Earlgrey_0_1/testflags`, **364 cmp
  lines, ONE head** — a `hier_path` `VpiName` pair, `hier_path::Compare`'s LAST
  field:

  ```
  LHS (golden)  hier_path @ tlul_socket_m1.sv 109:19-109:36
                VpiName = 'tl_h_i[0].a_valid'   VpiSize = 0
  RHS (ours)    hier_path @               109:19-109:36
                VpiName = 'tl_h_i[i].a_valid'   VpiSize = 1
  ```

  The failing field is **`VpiName`**, and that is arithmetic, not a guess:
  `design::Compare` returns **−57**, which is `'0' − 'i'` = 48 − 105 — a
  `std::string::compare` result at the one differing character.  A `VpiSize`
  difference would have returned 0 − 1 = −1, so the size pair (0 vs 1) is a
  SECOND difference on the same object that the judge cannot reach yet.

  The source is `tlul_socket_m1.sv:108-109`, an ASSIGNMENT PATTERN inside the
  same `gen_host_fifo` generate body earl110's § `hpSelHalfOpParamFold110`
  already renders correctly three lines up:

  ```systemverilog
  108:    assign hreq_fifo_i = '{
  109:      a_valid:    tl_h_i[i].a_valid,
  ```

  Golden renders the GENVAR `i` **as its per-instance VALUE** here, while
  earl110's law deliberately SPELLS a genvar — measured the other way on the
  select two lines up, where golden keeps `tl_h_i[i].a_source[…]` with `i`
  spelled in the bit_select and only the PARAMETER leaves folded.  So the R0 is
  a **genvar-rendering distinguisher inside an assignment-pattern member
  value**: which syntactic context makes Surelog render a generate index as a
  number rather than as its name.  The line count is UP (17 → 364) purely
  because this object's decompile is 364 lines; it is ONE head.
  `Earlgrey_0_1/default` keeps its own pre-existing head (r10earl107's
  `u_pinmux.gen_mio_periph_in[0].data_mux` null) at 31 lines, byte-identical.

* **R1 — THE FOURTEEN DECLARED TYPES THIS LAW REFUSES.**  `g2_kind111.sv`
  measures golden stamping `integer`, `byte`, `shortint`, `longint`, `bit`,
  `bit [3:0]`, `logic`, `logic [7:0]`, three typedef spellings and the two
  implicit-with-literal-RHS rows — 14 rows this site leaves BARE because it can
  only mint an `int_typespec`.  Each needs a different UHDM kind, a Range
  vector, or the typedef's own `VpiName`/`Instance`, and the RIGHT fix is to
  reach the parameter's real object the way `pkgParamObj` does for packages —
  a MODULE-side parameter-object map.  **Corpus population: ZERO** (the census
  finds no such cell in either corpus), so it buys nothing today and is
  recorded rather than guessed at.

* **R2 — the 9 PAYLOAD cells.**  Every UVM row's associative-array
  `RNG.right` carries a `class_typespec n='uvm_phase' inst=uvm_pkg` in OURS
  that golden does not have, plus `string_typespec` multiplicity differences.
  A different family entirely; unchanged by this pass, on both sides, in both
  modes.

* **R3 — a PACKAGE `parameter int` read QUALIFIED inside an elaborated port
  High_conn.**  `g5_neg111.sv` c5: golden STAMPS it while our
  § `connIpsPkgParamBoundNoTs65` carve-out leaves it bare — and the corpus's
  `flash_phy.sv:128/133`, the very cell that carve-out was measured on, has
  golden BARE for the UNQUALIFIED spelling of the same shape.  The two cells
  disagree on the qualification axis; reconciling them needs its own arm and
  its own census.  Pre-existing, untouched, 0 corpus cells moved.

* **R4 — § `elabHierSelWidthFold` OVER-FOLDS relative to golden in three
  scopes, and this law now stamps the over-folds.**  `g3_scope111.sv` measures
  golden folding a select width ONLY at generate depth exactly one with the
  parameter declared OUTSIDE the generate block — earl110's § scope gate, one
  level down in the value fold.  Our fold has no such gate, so at depth 0
  (`:37`), at depth 2 (`:32`, `:33`) and for a parameter declared INSIDE the
  generate block (`:27`) we emit a `constant` where golden emits a `ref_obj`.
  That is PRE-EXISTING (the pristine binary emits the same four constants) and
  it is invisible to the judge at those cells, because `BaseClass::Compare`
  fails on `VpiType` long before it would read a `Typespec` — every one of the
  twelve arm cmp logs is byte-identical across this patch.  **Corpus
  population: ZERO** (`predict111.sh` reports `NO-GOLDEN-KEY 0` over 2314
  databases), which is why this pass does not reach for earl110's depth
  machinery to gate it, per the brief's instruction to stop rather than borrow
  it.  It is the cleanest next target after R0 for the fold family.

* **R5 — the arena COUNT residue, 8592 + 908 keys.**  Our select-bound
  constants exist in def+elab multiplicities golden does not match (typically
  ours 2× or 4× golden's).  No generated `Compare` counts arena copies, so it
  is invisible to the judge; it is reported here only so the STRICT and SHAPE
  scores can be read against each other rather than one being quietly chosen.

---

## 8. THE WIDE BOUNDARY

`widerun111.sh` + `wide111.sh`: every `.sv`/`.v` under a COPY of
`tools/probe`, at ANY depth, both views, both frozen binaries, workdir-
normalised dump byte-compare.  The list is read on **fd 3** with children
`</dev/null` (a stdin list was once swallowed by the first child), the fence
list is read out of `canaudit.sh`'s own `FENCED=` line so the four names are
never spelled here, `rc` is recorded per side and split so an ASYMMETRIC rc is
visible, and **PROCESSED is asserted against LISTED**.

```
LISTED=4955  FENCED_REMOVED=0  (of 4955 found)
PROCESSED=4955 identical=9486 DIFFERING=44 no_output=380
PROCESSED==LISTED (4955)
rc by side   A/0 9141  A/3 364  A/4 389  A/139 16
             B/0 9141  B/3 364  B/4 389  B/139 16
```

**The rc split is IDENTICAL side for side** — same 9141 successes, same 364 and
389 rejections, same 16 pre-existing segfaults on each binary.  No arm rejects
on one side and not the other, and the patch introduces no new signal.

`DIFFERING=44` is **22 files × 2 views: 6 are this pass's own arms**, and 16
are earlier passes'.  Every one of those 16 was re-measured against GOLDEN with
the official `uhdm-cmp` (`foreign111.sh`, `FOREIGN.r10earl111.txt`) and
cell-by-cell against golden's census (`FOREIGN_CELLS.r10earl111.txt`):

| | |
|---|---|
| head OBJECT | **IDENTICAL, pristine vs patched, in all 32 arm-views** (first six cmp lines byte-for-byte) |
| cmp logs | **16 of 32 arm-views BYTE-IDENTICAL**; the other 16 differ by ADDED lines only — `+14` in twelve of them, which is exactly one `ref_typespec` + `int_typespec` block printed under a constant OUR side already had |
| `r10earl_repro/vc` | the one arm with a large raw diff (`−666/+694`): with arena `id:` masked it is **+28 / −0** — the rest is id RENUMBERING, because minting objects earlier shifts every later id |
| SHAPE AWAY | **0 in every one of the 32 arm-views** |
| the 60 changed cells | **30 NEW-PAYLOAD-IS-GOLDENS** (golden stamped, we were bare, we now carry golden's object field for field — wins on `r10earl110/g1`,`g5`, `r10earl65/g2_hier65`, `r10earl69/a1`,`a2`, `r10earl84/g3_pos84`, `r10v69/v1_shapes69`, `r10vearl110/v3`,`v4`) and **30 NEW-PAYLOAD-NOT-IN-GOLDEN** (golden has NO key there — the residue-R4 over-fold, where golden emits a `ref_obj` and we emit a constant, so the cell already failed on `VpiType` before this patch) |
| **cells where GOLDEN IS BARE and the patch STAMPED** | **ZERO** — the formal definition of an AWAY, counted over all 32 foreign arm-views, all 12 of this pass's own, and all 2314 corpus databases |

Two arm-views (`r10earl65/g2_hier65`, `r10earl84/g3_pos84`) score SHAPE
MOVED-WRONG 1 on the strict reading.  Both are the SAME cell shape and both are
wins: golden has ONE stamped copy at the key, the pristine binary had two or
three BARE copies, and the patched binary has one carrying **golden's exact
payload** beside the pre-existing extra bare copies (residue R5).  The
multiplicity, not the edge, is what the strict score is objecting to.

---

## 9. FILES

| file | what it is |
|---|---|
| `own111.cpp` | the OWNER FINDER — official `design::Compare`, the full Compare-visible payload of the head's typespec edge, the parent chain READ not guessed, then golden-side masking to walk and COUNT the family |
| `OWNER.r10earl111.txt` / `OWNER_AFTER.r10earl111.txt` | its output on the pristine and the patched databases |
| `cen111.cpp` / `cen111.py` | the select-bound constant typespec-EDGE census and its multiset scorer (STRICT + SHAPE) |
| `censweep111.sh` | the census over EVERY database in a workdir, with golden read from each row's own `cmds.txt` and LISTED/PROCESSED accounting |
| `score111.py` | the corpus scorer — EDGE / PAYLOAD / COUNT buckets, then TO-GOLDEN / AWAY / MOVED-WRONG |
| `calib111.sh` / `CALIB.r10earl111.txt` | the golden-vs-golden calibration of the whole instrument |
| `predict111.sh` / `PREDICT_R0.txt` | the mover prediction from PRISTINE databases only, plus the R0 decode |
| `attrib111.sh` / `secattr111.py` | the sectioned, path-normalised, ORDER-BLIND whole-dump mover attribution (tail split at `\_weaklyReferenced:`) |
| `grid111.sh`, `g1..g6_*111.sv`, `TOPS.txt` | the six arms and their driver |
| `GRID.r10earl111.txt` / `GRIDSCORE.r10earl111.txt` | the arm table and the per-arm censuses |
| `foreign111.sh` / `FOREIGN.r10earl111.txt` | every foreign arm the wide boundary flagged, re-scored against GOLDEN with the official `uhdm-cmp` |
| `FOREIGN_CELLS.r10earl111.txt` | every census cell that changed on a foreign arm, classified against golden — including the AWAY count (0) |
| `MOVER_Earlgrey_{default,testflags}.txt` | the sectioned order-blind attribution of the two byte movers |
| `widerun111.sh` / `wide111.sh` / `BOUNDARY_WIDE.*` | the wide boundary |
| `CENSUS_PRE_*.txt` / `CENSUS_*.txt` | the corpus censuses, before and across the patch |
| `HEAD_{BEFORE,AFTER}_Earlgrey_{default,testflags}.cmp` | the official `uhdm-cmp` logs on both sides |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the standard gate battery, carried unchanged |
