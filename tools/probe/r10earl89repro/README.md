# r10earl89 — § `dimBoundLeafValueSignedTs89`: the folded parameter leaf of an unpacked-dimension bound takes the bare signed `int_typespec` exactly when the parameter's stored `Value` is SIGNED

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `dcb54b3`, branch `auto5h`.** `results/*.csv` was **READ ONLY** and is
untouched — **NO ROW WAS CONVERTED** (`Earlgrey_0_1` stays `CMP_NOTEQUAL` in
both modes; its head is cleared, the design has more — see `PREDICT_R0.txt`).
slang was **NOT** patched. Production surface: **`src/TypeEmit.cpp` only.**

Kill switch: `R10E89_OFF=1` restores the pre-pass answer exactly, in both arms.
It is the neutral binary the Earlgrey attribution scores against (Earlgrey is
never whole-dump diffed — its dump is >1 GB; earl61's rule), and it is also the
instrument that PREDICTED the movers (`R10E89_CELLDBG=1`, §5).

**The Earlgrey_0_1 head r10earl88 named as R0 — a `ref_typespec` the judge
finds on golden's side and not on ours, 17 cmp lines and one head in EACH mode,
the two logs byte-identical — is CLEARED in both modes.** Every other named
row's head is unchanged.

---

## 1. The head, reproduced before any code was written

This pass built its own binary from `dcb54b3` (`4e11f0b821c3`) and re-measured
every named row on it with `rowheads.sh` rather than trusting earl88's
write-up (`HEAD_BEFORE_*`):

```
Earlgrey_0_1   default      17      1 head
Earlgrey_0_1   testflags    17      1 head
```

```systemverilog
// hw/ip/flash_ctrl/rtl/flash_mp.sv, in top_earlgrey.u_flash_ctrl.u_flash_mp
localparam int TotalRegions = MpRegions + 1;        // :14
logic [AllPagesW-1:0] region_end [TotalRegions];    // :54
```

The head is `BaseClass::SafeCompare`'s SINGULAR overload naming the VALUE with
`RHS: <null>` (RESUME §9), and the value is the whole `ref_typespec`:

```
LHS (golden)                                    RHS (ours)
  ref_typespec (…u_flash_mp.region_end)           <null>
  |vpiParent: constant 54:36-54:48                (the constant is there,
  |vpiActual: int_typespec                         field for field, with no
                                                   vpiTypespec)
```

`dimts89` (this pass's direct `.uhdm` reader — never `uhdm-dump` on Earlgrey)
prints the two bounds of that ONE `vpiRange` on both sides:

```
GOLDEN  L{ct=9 sz=64 UINT:0 dec=0 TS=none}
        R/op11[0]{ct=9 sz=32 UINT:9 dec=9 TS=int_typespec/sgn/bare}
        R/op11[1]{ct=7 sz=64 INT:1 dec=- TS=none}
OURS    L{ct=9 sz=64 UINT:0 dec=0 TS=none}
        R/op11[0]{ct=9 sz=32 UINT:9 dec=9 TS=none}          <- THE HEAD
        R/op11[1]{ct=7 sz=64 INT:1 dec=- TS=none}
```

Everything else is byte-equal: the `[0 : TotalRegions-1]` rewrite, the
`vpiSubOp`, both bound encodings (`UINT:9` at 32 — that is
§ `dimBoundInheritsParamEnc74` and § `dimFoldReducedTypedWidth26`, already
landed), and the SIBLING literal `1`, which carries **no typespec on either
side** and is this law's built-in negative control. `constant::Compare` reads
`Typespec`, so the field is judge-visible.

---

## 2. Question 1 — the DECODE, from Surelog's source

**ONE PRODUCER FOR TWO FAMILIES.** `CompileHelper::compileRanges`
(`src/DesignCompile/CompileExpression.cpp:4038-4155`) rewrites `[E]` into
`[0 : E-1]` and compiles `E` with `compileExpression(..., Reduce::Yes)`. When
`E` NAMES A PARAMETER, that call lands in the SAME identifier arm
§ `elabParamOpLeafValueFold85` (r10earl85) decoded for an operation leaf
(`CompileExpression.cpp:2852` and `:3004-3018`):

```c++
if ((reduce == Reduce::Yes) && instance) sval = instance->getValue(name);
...
UHDM::constant *c = s.MakeConstant();
c->VpiValue(sval->uhdmValue());      c->VpiDecompile(sval->decompiledValue());
c->VpiConstType(sval->vpiValType()); c->VpiSize(sval->getSize());
if (sval->isSigned()) {                             // <- THE WHOLE HEAD
    int_typespec *ts = s.MakeInt_typespec();  ts->VpiSigned(true);
    ref_typespec *rt = s.MakeRef_typespec();  rt->VpiParent(c);
    rt->Actual_typespec(ts);                  c->Typespec(rt);
}
```

So the dimension bound and the operation leaf ask ONE question: **is the
instance's stored `Value` SIGNED?**

**WHERE THAT SIGN IS SET.** `DesignElaboration::collectParams_`
(`src/DesignCompile/DesignElaboration.cpp:2521-2545`) is the ONLY caller of
`valueRange` in Surelog:

```c++
ts = p->getTypespec(); ...                        // the DECLARED typespec
m_helper.adjustSize(ts, ..., c);
if (c->Typespec() == nullptr) { ... c->Typespec(<ts>); }   // else KEEP the
                                                           // initializer's own
value = m_exprBuilder.fromVpiValue(c->VpiValue(), c->VpiSize());
if (const UHDM::ref_typespec *rt = c->Typespec()) cts = rt->Actual_typespec();
value->setTypespec(cts ? cts : ts);
if (ts) m_helper.valueRange(value, ts, cts ? cts : ts, ...);   // NOT CALLED
                                                               // WHEN ts IS NULL
```

and `CompileHelper::valueRange` (`CompileHelper.cpp:5380-5412`) ends

```c++
switch (rhstps->UhdmType()) {                         // rhstps == cts
  case uhdmlogic_typespec: isSigned = tps->VpiSigned(); break;
  case uhdmbit_typespec:   isSigned = tps->VpiSigned(); break;
  case uhdmint_typespec:   isSigned = tps->VpiSigned(); break;
  default: break;                                     // EVERYTHING ELSE UNSIGNED
}
val->setSigned(isSigned);
```

**THREE CONSEQUENCES**, each of them a measured column of `g1_redtype89.sv`
(12 declared types x 4 initializer forms, one `localparam` per row, GOLDEN =
Surelog; `GRID.r10earl89.txt`):

| declared type of the sizing parameter | `= 4` | `= BASE` | `= BASE+1` | `= $clog2(64)` |
|---|:--:|:--:|:--:|:--:|
| `int` | **TS** | **TS** | **TS** | **TS** |
| `int unsigned` | – | **TS** | – | – |
| `logic [7:0]` | – | **TS** | – | – |
| `logic signed [7:0]` | **TS** | **TS** | **TS** | **TS** |
| `bit [7:0]` | – | **TS** | – | – |
| `bit signed [7:0]` | **TS** | **TS** | **TS** | **TS** |
| *(untyped)* | – | – | – | – |
| `signed [7:0]` (implicit + `signed`) | **TS** | **TS** | **TS** | **TS** |
| `integer` | – | **TS** | – | – |
| `shortint` | – | **TS** | – | – |
| `longint` | – | **TS** | – | – |
| `byte` | – | **TS** | – | – |

1. **AN UNTYPED `localparam X = …` HAS NO TYPESPEC AT ALL**, `valueRange` never
   runs, and the Value is UNSIGNED for EVERY initializer form — including the
   bare-reference one that makes every other row stamp. `localparam [7:0] X`
   and `localparam signed X` DO have a compiled typespec (`g4_edge89.sv`
   `i_rng_ref` / `i_sgn_lit`), so "implicit" is not the discriminator: **a
   SIGNING TOKEN or a DIMENSION is**.
2. **THE SWITCH NAMES THREE TYPESPEC KINDS.** `byte` / `integer` / `shortint` /
   `longint` are `byte_typespec` / `integer_typespec` / … and fall to
   `default:` — they NEVER stamp on their own, though slang calls every one of
   them signed. That is the half § `dimFoldTsQualifiedOrSignedModPar26`'s raw
   `getType().isSigned()` test got wrong, and the four `_lit` cells it
   over-stamps in `g1` were **AWAY-GOLDEN before this pass**.
3. **`cts` — THE INITIALIZER CONSTANT'S OWN TYPESPEC — WINS OVER THE DECLARED
   ONE.** A BARE-REFERENCE initializer is compiled by the identifier arm above,
   so its constant ALREADY CARRIES the referenced parameter's bare signed
   `int_typespec` whenever THAT parameter's Value is signed. `g2_chain89.sv`
   measures the inheritance **two and three hops deep** (`r2_a`, `r3_a`),
   **through parentheses** (`p_par`), and **not** through `int'(B)` /
   `B + 0` (a `reduceExpr` fold mints no typespec at all — earl86's producer
   (B)), and it measures the refusals: an inherited sign from an `int unsigned`
   / `logic [7:0]` / `byte` / untyped source does not appear (`r_iu_iu`,
   `r_iu_lg`, `r_iu_by`, `r_iu_un`, `r2_b`, `r2_c`).

**AND THE TWO REFUSALS, both convicted on golden BEFORE the line was written:**

* **AN OVERRIDDEN PARAMETER** never stamps and never lends its sign: its stored
  Value is the plain 64-bit UINT the override actual built and never reaches
  `valueRange` (§ `rangeBoundStoredWidth82`, earl85's r11 row). `g2`'s THREE
  instantiations of one sink module (`#(.OVI(6))` a literal, `#(.OVI(B_INT))` a
  parameter, and one left at its default) measure both halves on the same
  `parameter int OVI`: **TS at its default, none in either overridden
  instance** — while the localparam one hop below it (`h_ovi`, declared `int`)
  keeps its TS everywhere, and its `int unsigned` twin `h_ovi_u = OVI` loses
  the `cts` inheritance exactly where the override lands.
* **A PACKAGE MEMBER READ BARE** is not this instance's Value at all
  (`instance->getValue()` does not hold it) — golden leaves the bound bare
  (`g2` `k_bare`, `g3` `d_pkg_bare`), and the QUALIFIED spelling is a DIFFERENT
  producer that hands back the **PACKAGE's OWN LOCATED** typespec, signed or
  unsigned as declared (`g3` `d_pkg_qual` `int_typespec/sgn/loc`, `d_pkg_qu`
  `int_typespec/uns/loc`). Neither is widened here: `qual26` keeps the arm it
  had, and the located-typespec half is ranked **R3**.

---

## 3. The law

**§ `dimBoundLeafValueSignedTs89` — the folded parameter leaf of an UNPACKED
size-form dimension bound carries a BARE SIGNED `int_typespec` exactly when the
parameter's STORED `Value` is SIGNED, and that sign is `valueRange`'s
THREE-KIND SWITCH (`logic_typespec` / `bit_typespec` / `int_typespec`, read for
`VpiSigned`) over the parameter's EFFECTIVE typespec — the INITIALIZER
CONSTANT's own typespec, which a BARE-REFERENCE initializer inherits from the
parameter it names, else the DECLARED one — and NEVER when the parameter has no
compiled typespec at all (a bare `localparam X = …`) or has been OVERRIDDEN.**

One production file, `src/TypeEmit.cpp`, two hunks in the unpacked size-form
dimension builder.

**(a) the predicate.** `sgnDecl26` (`dimPar26->getType().isSigned()`) is
replaced by `paramValueSigned89`, which transcribes the switch above and adds
the `cts` walk; `!implicit26` goes with it, because `paramHasTypespec89` is the
condition it was standing in for and answers `localparam [7:0]` / `localparam
signed` correctly. Both the OLD and the NEW answer are always computed, so the
NEUTRAL binary can name the mover set without emitting it.

**(b) the arm that never asked.** A dimension whose sizing parameter Surelog
had to REDUCE (its initializer is not a plain literal and not a bare ref to a
typed parameter) leaves § `dimFoldReducedTypedWidth26`'s arm with `continue`,
and until this pass it left with NO typespec at all — which is the head. It now
takes the same stamp the generic arm gives it. **The QUALIFIED spelling is
deliberately NOT carried into that arm** (`valSgn89`, not `tsStamp26`): golden
hands a qualified package reference the package's own LOCATED typespec, which
this arm cannot mint, so carrying `qual26` in would have replaced a MISSING
typespec with a WRONG one (`g3`'s `d_pkg_qu` is the cell that says so).

**The fences, each with the golden measurement that says why:**

* **the sibling literal is untouched.** The `INT:1` right operand of every
  `[0 : E-1]` carries no typespec on either side, in all 4 arms and both views.
* **a LITERAL-sized dimension is untouched.** `[8]` never enters this block
  (`sizeSyn->kind != IntegerLiteralExpression`); `g1`'s `v_ctl_lit` and `g4`'s
  `v_ctl_lit` are byte-identical pristine vs patched.
* **PACKED dimensions are a different builder and do not move.** `g3`'s
  `d_pk_s` / `d_pk_u` (`logic [M_S-1:0]`) and the struct-member packed dim are
  byte-identical on both binaries.
* **QUEUE and ASSOCIATIVE dimensions have no folded bound at all** (`g3`
  `d_q_s [$]`, `d_aa_s [int]`), and the `array_typespec` associative bound the
  UVM rows carry is a `string_typespec` cell this law never reaches.
* **an OVERRIDDEN dimension parameter keeps its `continue` arm and its bare
  bound**: `g2`'s `u_lit` / `u_ref` instances are byte-identical pristine vs
  patched on `s_ovi` / `s_ovu` / `s_nov`.
* **the GEN-SCOPE home was ALREADY RIGHT and stays right.** In a generate
  block the bound expression does not bind, so the cell never reaches the
  reduced arm; `g3`'s `gb[0]`/`gb[1]`/`gi1` and `g4`'s `gc[0]`/`gc[1]` rows are
  byte-identical pristine vs patched and equal to golden on both.
* **R10E89_OFF=1 reproduces the PRISTINE database BYTE FOR BYTE** on all four
  arms in BOTH views (`ARMS.r10earl89.txt`).

---

## 4. Question 5 — the grids

Every arm is built by `arm89.sh` with **Surelog** (golden) and with the TWO
FROZEN binaries plus the NEUTRAL one, **twice**: plain and `-elabuhdm` /
`--elabuhdm`. Every child gets `</dev/null` and its rc is recorded.
`dimts89` censuses all eight databases; `score89.py` joins them as a MULTISET
on the CELL IDENTITY (owner chain + owner kind + the range's ORDINAL among its
owner's ranges — earl79's `rngcen79` keyed on the chain alone and would have
merged the two dimensions of `[M_S][W2]`), payloads DEDUPED per key, and
carries **no span** in the payload (earl60/earl69). `tsscore89.py` scores the
ONE field this law owns leg by leg, and asserts that no other field moved.

| arm | what it varies | TS W→R | TS R→W | TS AWAY | other field moved |
|---|---|---:|---:|---:|---:|
| `g1_redtype89.sv` | 12 declared types x 4 initializer forms (literal / bare ref / expression / `$clog2`) + a literal-sized control | **51** | **0** | **0** | **0** |
| `g2_chain89.sv` | the `cts` half: 1/2/3-hop chains, parens, cast, `+0`, unary, package bare vs qualified, three OVERRIDE homes | **39** | **0** | **0** | **0** |
| `g3_homes89.sv` | DECLARATION KINDS x DIMENSION KINDS x HOMES: variable / net / port / typedef / struct member / function local / CLASS PROPERTY; unpacked / 2-D / packed / queue / associative; module body / gen-for / gen-if / interface / a 3-deep instance chain / two sibling instances / a ported child | **30** | **0** | **0** | **0** |
| `g4_edge89.sv` | implicit with a range / with `signed` / with `unsigned`; typedef'd `int` / `int unsigned` / `logic signed [7:0]` / `logic [7:0]`; an ENUM-typed parameter; genvar-derived localparams | **18** | **0** | **0** | **0** |

Two declaration kinds carry NO dimension-bound cell to score, and the arm says
so rather than implying coverage: a **function local** unpacked array
(`g3`'s `fn_s`/`fn_u`) produces no `range` on EITHER side, and a **class
property** (`g3`'s `cp_s`/`cp_u`) produces one on OURS ONLY — golden's
`class_defn` emits no range for it at all. That ONLY-OURS cell is the arms'
single moved cell that has no golden counterpart (3 cells in the definition
view, 7 in the elaborated one; ranked **R7**), and it is the one place the
field scorer is structurally blind, because it only scores keys all three
databases hold. Corpus-wide it does not arise: `ONLY-OURS` is unchanged at
33 427 / 2 700 and the `ours` cell files differ by exactly the six head lines.

`g3` also reports **6 `TS-NO-GOLDEN-LEG`** legs — the interface DEFINITION
listing, where golden keeps the bound as a `ref_obj` and ours has folded it to
a constant since long before this pass. There is no golden typespec answer to
move toward or away from on a leg golden does not have as a constant at all;
the cell disagrees on the leg KIND before and after. Ranked **R2**, with the
ELABORATED interface twin (`u_if.if_s`) among the 30 that DID move to golden.

The ELABORATED view scores identically on every arm. Whole-cell scores are in
`SCORE.g*.txt`; they report a handful of `WRONG->OTHER` cells, and **every one
of them is a cell whose typespec moved TO golden while a PRE-EXISTING WIDTH
residue stays wrong** (R1) — no cell moved away, in either scorer.

`g3` puts the law in every home the corpus has:
`work@g3_89` body (`d_var_s`, `d_net_s`, `d_2d_s` both dims), an INTERFACE
body (`u_if.if_s`), a PORTED child's body (`u_p.p_body_s`), and a three-deep
instance chain with two sibling parents and two differently-parameterised
leaves (`u_m1.u_a`, `u_m1.u_b`, `u_m2.u_a`, `u_m2.u_b`) — all four leaf
instances move identically, with the right per-instance value. The `_u`
(`int unsigned`) twin of EVERY one of those rows is the negative control and
does not move.

---

## 5. Questions 2 and 3 — the CORPUS: the census, then the prediction

### 5.1 the identity census (`cen89.sh` + `cencount89.py`)

`cen89.sh` runs `dimts89` over EVERY database of a sweep workdir AND over the
GOLDEN named in that test's OWN `cmds.txt` (the immutable golden-cache path).
**It READS DATABASES AND DISPATCHES NOTHING**, so no test — fenced or otherwise
— is run by it. `cencount89.py` joins them as a MULTISET (RESUME §9: keys
collide and a last-writer dict drops rows), deduping payloads per key, and
scores BOTH one-sided sets explicitly.

| bucket | surelog before | surelog after | u2r before | u2r after |
|---|---:|---:|---:|---:|
| BOTH-SAME | 292 269 | **292 275** | 136 746 | 136 746 |
| **FAM-TS-MISSING** (golden has the typespec, we do not) | **6** | **0** | **0** | **0** |
| **FAM-TS-EXTRA** (we have one, golden does not — AWAY) | **0** | **0** | **0** | **0** |
| FAM-TS-KIND | 35 | 35 | 0 | 0 |
| OTHER-DIFF | 115 206 | 115 206 | 2 930 | 2 930 |
| ONLY-GOLDEN / ONLY-OURS | 63 463 / 33 427 | unchanged | 26 610 / 2 700 | unchanged |

**The 6 FAM-TS-MISSING cells are `Earlgrey_0_1`'s `region_end` and nothing
else, corpus-wide** — one cell in each mode, three deduped ordinals each. The
35 FAM-TS-KIND are a different family entirely (an associative array's
`string_typespec` / `class_typespec` KEY, and located-vs-bare package
typespecs) and this law cannot reach them.

### 5.2 the mover prediction, made BEFORE any patched sweep was read

`predict89.sh` re-runs each test's OWN slang command line — read out of the
PRISTINE sweep's `cmds.txt`, in the test's OWN source directory — with the
patched binary under **`R10E89_OFF=1`** (whose database is byte-identical to
the pristine one) and `R10E89_CELLDBG=1`, which prints the OLD and the NEW
typespec answer for **EVERY** unpacked size-form dimension the two arms reach,
not only the ones the law intends to change (earl66's rule: a trace keyed on
the shape you intend to change is blind to the rows you would change by
accident). Output goes to `/dev/null`. **The four slang-fenced tests are never
dispatched**: only command lines that ALREADY RAN in the pristine sweep are
re-run, and those four are not in it.

```
uhdm2rtlil   1358 databases    60 trace lines    CHANGED 0
surelog       956 databases   134 trace lines    CHANGED 2
```

**PREDICTION: EXACTLY TWO CELLS CHANGE, and they are the head:**

```
default/Earlgrey_0_1    R10E89 RED region_end:54:36 par=TotalRegions tsOld=0 tsNew=1
testflags/Earlgrey_0_1  R10E89 RED region_end:54:36 par=TotalRegions tsOld=0 tsNew=1
```

Both are RED-arm ADDS (pristine stamped nothing there). **NOT ONE cell changes
through the PREDICATE half** — the whole corpus's other size-form dimension
bounds (`Scr1SvTests`, `IfGenTypeBinding`, `MemoryInGenblock`,
`issue326_packed_mem`, `hier_path`, `struct_param_dim`) answer `tsOld == tsNew`
on every row, so the byte/integer/shortint/longint tightening and the `cts`
widening are **corpus-invisible and arm-convicted**, which is exactly why they
needed the grids and the wide boundary.

The largest reachable population NOT taken is named here, because a prediction
that does not say what it excludes is not a prediction. The corpus's other
size-form bounds divide into four groups:

* a non-overridden `int` sizing parameter, BOTH answers 1 — `MemoryInGenblock`
  `N` (5 declarations), `issue326_packed_mem` `DEPTH`, `IfGenTypeBinding`
  `PMPNumRegions`;
* an `int unsigned` sizing parameter, BOTH answers 0 — `hier_path`
  `PMPNumChan` / `PMPNumRegions` (7 declarations);
* **`Scr1SvTests` `q_data [SCR1_IFU_Q_SIZE_HALF]` and `q_err`, the ONLY other
  corpus rows that reach the RED arm this pass changed** — and they do NOT
  gain a typespec, because `localparam SCR1_IFU_Q_SIZE_HALF =
  SCR1_IFU_Q_SIZE_WORD * 2` is UNTYPED and therefore has no compiled typespec
  for `valueRange` to read. They are § `dimFoldReducedParam`'s own witness,
  and consequence (1) is what keeps them still;
* one `struct_param_dim` row that is `qual26` and never consults either answer.

---

## 6. Result

| | before | after |
|---|---|---|
| Earlgrey_0_1 / default | 17 cmp lines, 1 head | **15 cmp lines, 1 head** |
| Earlgrey_0_1 / testflags | 17 cmp lines, 1 head | **15 cmp lines, 1 head** |

The two after-logs are byte-identical, so there is ONE R0, not two
(`PREDICT_R0.txt` Part 2). Every OTHER named row's head log
(`SeqDriver`, `SimpleUVM`, `Scoreboard`, `MiniAmiq`, `BuildUVMPkg`, `Rggen`,
both modes where they exist) is **byte-identical before and after**.

The corpus-wide range-census delta is SIX LINES — the head's three deduped
ordinals in each mode, `TS=none` -> `TS=int_typespec/sgn/bare`, matching
golden exactly:

```
surelog   BOTH-SAME 292 269 -> 292 275   FAM-TS-MISSING 6 -> 0   FAM-TS-EXTRA 0 -> 0
u2r       every bucket unchanged; the two `ours` cell files are byte-identical
```

---

## 7. Gates

All green — `GATES.r10earl89.txt` carries every number. In one line: both
binaries built `-j 2` and frozen `chmod 555` before any sweep, and **every one
of the 1573 + 1462 `cmds.txt` files audited BY BINARY PATH — 0 name the
main-tree binary**; goldens **23 PASS / 0 FAIL** on BOTH binaries and **0/23**
on `/bin/false`; uhdm2rtlil **679 / 50 / 2 with 0 differing rows in BOTH modes**
against the committed baseline AND against this pass's own pristine sweep;
surelog **0 differing rows over 1588** with an identical status histogram —
**NO ROW CONVERTED and `results/*.csv` not edited**; byte movers **0/1358** and
**2/956**, both PREDICTED BY NAME from the pristine databases first; the
run-time A/B gate reproduces the pristine Earlgrey databases byte for byte with
`R10E89_OFF=1` in both modes; 52 + 8 canary rows unchanged with `changed=0`,
both supplementary canary suites PASS, `canaudit` **audited=29 UNCOVERED=0
FENCE-BREACH=0**; all five protected databases byte-identical with
`SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on their pins.

---

## 8. Boundary

`vwide89.sh` (earl88's walker, unchanged in mechanism) walks a COPY of
`tools/probe` with **no path filter**, `.sv` and `.v`, at ANY depth, both
views, both frozen binaries, workdir-normalised dump byte-compare; the file
list is read on **fd 3** with children `</dev/null`, `PROCESSED` is asserted
equal to `LISTED`, and every cell records its `rc`. **The four slang-fenced
tests are never dispatched** — `bdlist89.sh` filters the list by the names read
out of `canaudit.sh` (the only file here that may spell them) and **0 of 4037
files matched**.

```
PROCESSED=4037 (== LISTED)  identical=7706  DIFFERING=18  no_output=350
rc:  0 -> 14786    3 -> 672    4 -> 662    139 -> 28
     the 28 rc=139 are 14 files x 2 sides and the A/B rc=139 SETS ARE IDENTICAL
```

All 18 differing cells are **9 files x 2 views**, and every one was re-measured
AGAINST GOLDEN by `bdscore89.sh` (Surelog built on the file, both frozen
binaries, the neutral one, both views, scored whole-cell and field-wise):

| file | TS W→R | TS R→W | TS AWAY | `R10E89_OFF=1` reproduces |
|---|---:|---:|---:|---|
| this pass's own four arms | 138 | **0** | **0** | the PRISTINE database |
| `r10earl74repro/g1_dims74.sv` | **87** | **0** | **0** | the PRISTINE database |
| `r10vearl74repro/va2_v74.sv` | **33** | **0** | **0** | the PRISTINE database |
| `r10vearl74repro/va3_v74.sv` | **18** / 26 | **0** | **0** | the PRISTINE database |
| `r10vearl74repro/va1_v74.sv` | **6** | **0** | **0** | the PRISTINE database |
| `r10buvm22repro/g22.sv` | **0** | **0** | **0** | **the PATCHED database** |

The four `earl74`/`vearl74` files are **another author's dimension grids** —
144 more legs moved TO GOLDEN, RIGHT→WRONG 0, in files this pass never saw
while writing the law. They are the independent confirmation.

`r10buvm22repro/g22.sv` is **NOT this law**: `R10E89_OFF=1` reproduces the
**PATCHED** hash (`6b8239ea7517` / `78ba905a2f2b`), not the pristine one, and
the delta is a queue bound's `UINT:22486617` -> `UINT:22490713` — a database
value derived from an ADDRESS that tracks the binary's code layout. That is
earl84's **R5**, reproduced from a third binary pair (earl85 saw the same file
do the same thing); golden has no such leg at all, and the typespec on it is
`TS=none` on both binaries.

`BOUNDARY_WIDE.*` carries the tally, the rc histogram, the differing list and
the 28 signalling runs; `SCORE.bd_*.txt` carries each re-scoring verbatim.

(The walk ran before `g3_homes89.sv` gained its class-property and
function-local rows. That file was already in the differing list as one of this
pass's own arms, and the committed version is scored directly against golden in
`SCORE.g3.txt` — TS W→R 30, R→W 0, AWAY 0, other fields moved 0, `R10E89_OFF=1`
byte-identical to pristine in both views.)

---

## 9. Residues, ranked

`PREDICT_R0.txt` carries all of them with their evidence and their corpus cell
counts. **R0** is the new Earlgrey head — the SAME missing bare signed
`int_typespec`, on the WIDTH operand of an elaborated port high_conn's indexed
part-select (`rv_timer.sv:82`, `intr_timer_en[h*N_TIMERS +: N_TIMERS]` in
`top_earlgrey.u_rv_timer.gen_harts[0].u_intr_hw`, `localparam int N_TIMERS`),
one producer further along. Then: **R1** the reduced arm's WIDTH for an
implicit-typed sizing parameter (12 arm cells, 0 corpus cells), **R2** the
interface DEFINITION listing folding a bound golden keeps as a `ref_obj`,
**R3** the qualified package reference's LOCATED typespec, **R4** a unary-plus
initializer losing its dimension in golden, **R5** `int'(B)` re-typing the
bound (earl79's refused row), **R6** the pre-existing probe segfaults (named:
`Tnoc`, both modes, symmetric on both binaries), **R7** a class property's
unpacked dimension, a range golden does not emit at all.

---

## 10. Reproducing

```bash
g++ -O2 -std=c++17 dimts89.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o dimts89
DIMTS89=./dimts89 PRIS=<pristine> PATCHED=<patched> bash arm89.sh g1_redtype89.sv <dir>
python3 score89.py   <dir>/g.rg <dir>/o.rg <dir>/q.rg      # whole cell
python3 tsscore89.py <dir>/g.rg <dir>/o.rg <dir>/q.rg      # the TS field alone
python3 grid89.py    <dir> def|elab                        # the readable grid
DIMTS89=./dimts89 bash cen89.sh <sweep-workdir> <prefix>   # corpus census
python3 cencount89.py <prefix>.golden <prefix>.ours <out.txt>
NEUTRAL=<patched> DIRMAP=<map> bash predict89.sh <pristine-workdir> <out>
bash bdlist89.sh <probe-root-copy> <list>                  # fenced names filtered
PATCHED_BIN=<q> PRISTINE_BIN=<p> PROBE_ROOT=<copy> bash vwide89.sh <list> <out>
```

`R10E89_OFF=1` disables the law at run time; `R10E89_CELLDBG=1` traces it.

---

## 11. VERIFIER CORRECTION (r10v89)

Two lines of §2's decode are wrong and one cell of the law was wrong with them.
`CompileHelper::valueRange` (`CompileHelper.cpp:5379-5398`) casts each `tps`
**out of `rhstps`**, not out of the declared `lhstps`:

```c++
case uhdmint_typespec: { int_typespec* tps = (int_typespec*)rhstps;
                         isSigned = tps->VpiSigned(); break; }
```

so the sign is the **effective typespec's OWN sign** — the initializer
constant's typespec when it has one, else the declared one. That is the same
answer as "recurse on the referenced parameter's Value" for a BARE module-scope
hop, and a DIFFERENT one for a QUALIFIED package hop, where the constant
carries the package's own DECLARED (located) typespec. `paramValueSigned89`
now asks the declared question on a qualified hop; without it
`localparam int unsigned q = px89::X_FROM_QUAL;` (with `localparam int unsigned
X_FROM_QUAL = pw89::W_INT;`) was pristine-RIGHT → patched-WRONG.
Evidence and the four separating golden cells:
`tools/probe/r10v89repro/README.md` §1, `va4_v89.sv`.
