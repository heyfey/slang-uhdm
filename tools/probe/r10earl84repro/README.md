# r10earl84 — § `connHpIpsBaseNonOvParamFold84`

**THE EARLGREY HEAD CLEARED IN BOTH MODES** (default 240 cmp lines → 214,
testflags 268 → 144; one head each, and the head object is now the SAME one in
both modes for the first time), and every other named row's head
**byte-identical**.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `0f32387`, branch `auto5h`.** `results/*.csv` was **READ ONLY** and is
untouched — **NO ROW WAS CONVERTED** (`Earlgrey_0_1` stays `CMP_NOTEQUAL` in
both modes; its head is cleared, the design has more — see `PREDICT_R0.txt`).
slang was **NOT** patched. Production surface: **`src/ExprEmit.cpp` and
`include/UhdmExporter.h` only.**

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_Earlgrey_{default,testflags}.cmp` are the verbatim pristine logs
from this pass's own build of `0f32387` (binary md5
`c5393d4b65932e92fb79410dacd93409`); they reproduce r10earl83's committed
`HEAD_AFTER_*` logs line for line modulo object ids.

`hw/ip/flash_ctrl/rtl/flash_ctrl.sv:171`, the `flash_prog_ctrl` instantiation
inside `top_earlgrey.u_flash_ctrl`:

```systemverilog
    .op_addr_i      (reg2hw.addr.q[DataBitWidth +: AddrW]),
```

with `localparam int DataBitWidth = $clog2(BytesPerWord);` (flash_ctrl.sv:34)
evaluating to 2, and `AddrW` a package parameter equal to 17.

| | LHS (golden) | RHS (ours, pristine) |
|---|---|---|
| the `hier_path` | `VpiName reg2hw.addr.q[2+:17]` | `VpiName reg2hw.addr.q[DataBitWidth+:17]` |
| its trailing `indexed_part_select`'s `Base_expr` | `constant` 171:36-171:48 | `ref_obj` 171:36-171:48 |
| | `vpiDecompile:2` `vpiSize:32` | `vpiName:DataBitWidth` |
| | `UINT:2` `vpiConstType:9` | |
| | `vpiTypespec -> ref_typespec -> int_typespec` (**`VpiSigned`, and nothing else**) | *(no typespec)* |
| its `Width_expr` | `constant UINT:17 sz32 ct9` | **the same** |

**Which arm — read the MK line, not the shape.** Both sides are non-null
`hier_path`s, so `hier_path::Compare` runs and reaches `Path_elems`; the elems
are equal in COUNT, so the walk descends to the `indexed_part_select` and its
`Base_expr` — a `constant` on the left and a `ref_obj` on the right, two
non-null objects of DIFFERENT `UhdmType`, i.e. `BaseClass.h:188`'s
two-non-null arm. The head is a **KIND mismatch inside `BaseClass::Compare`'s
`VpiType` line**, before any per-kind field of either side is read. The 240 /
268 lines are the hier_path sub-tree printing, not 240 cells.

**The `VpiName` difference is NOT a second defect.** `hier_path::Compare` does
read `VpiName`, but § `hpNameBareIdxFold69` re-derives that name **from the
Path_elems objects**, so the name follows whatever the base becomes. Measured,
not assumed: `g1_hp84.sv` shows the name flipping to `reg2hw.addr.q[2+:17]`
with no name-side code at all, and `hpIdxBaseHierPathEmpty94` re-stamps the
element fullnames with it.

---

## 2. Question 2 — decoded from Surelog and UHDM, not guessed

1. **The elaborated port connection is RE-COMPILED, not cloned.**
   `NetlistElaboration::high_conn_`
   (`NetlistElaboration.cpp:1332-1337`, the ordered form at `:1088-1096`)
   compiles the actual in the PARENT instance with **`Reduce::Yes`** — the fact
   § `elabConnEnumConstFold66`, § `connBitSelIdxModParamFold81` and
   § `elabConnWrittenCastFold83` all rest on.
2. **`compileSelectExpression`'s INDEXED arm passes the caller's `reduce` to
   BOTH bounds** (`CompileExpression.cpp:4258-4290`), while the SIMPLE arm
   seventeen lines above (`:4241-4249`) hardcodes `Reduce::No` for `Left_range`
   and `Right_range`. That single asymmetry is the whole reason an
   indexed-part-select BASE folds while a plain part-select BOUND does not
   (§ `genScopeConnPsDirectBoundKeepsRef71`), and it is measured on golden from
   both sides — see §3's fence table.
3. **Under `Reduce::Yes` the identifier arm answers from the instance's stored
   `Value`.** `CompileExpression.cpp:2852` takes
   `sval = instance->getValue(name)` and `:3004-3018` mints
   ```cpp
   c->VpiValue(sval->uhdmValue());   c->VpiDecompile(sval->decompiledValue());
   c->VpiConstType(sval->vpiValType()); c->VpiSize(sval->getSize());
   if (sval->isSigned()) { int_typespec *ts = s.MakeInt_typespec();
                           ts->VpiSigned(true); … c->Typespec(rt); }
   ```
   **That `if` IS the typespec-presence split** this pass was sent to find, and
   the object it mints is BARE: no name, no location, no ranges, no value, no
   `Typedef_alias`, no `Instance`, no `Cast_to_expr`. It is also why earl81's
   High_conn bit-select folds carry NONE — their producer is an OVERRIDDEN
   parameter, whose Value never goes through the signedness capture below.
4. **Where the Value's WIDTH comes from.** Not overridden:
   `DesignElaboration::collectParams_` (`DesignElaboration.cpp:2519-2545`) runs
   `adjustSize(ts, …)` on the compiled default **before**
   `fromVpiValue(c->VpiValue(), c->VpiSize())` captures it, so the stored Value
   already carries the DECLARED type's width. That is EXACTLY r10earl64's
   `adjustCopiedParamConst64` (the parameter's own elaborated `param_assign`
   Rhs re-run through `srlgAdjustSize` at the declared type), so this law
   **reuses that consumer** instead of minting a second encoder.
5. **Where the Value's SIGNEDNESS comes from.** `CompileHelper::valueRange`
   (`CompileHelper.cpp:5378-5412`), called on the very next line of
   `collectParams_`, reads `VpiSigned()` off the declared typespec for
   **`logic_typespec`, `bit_typespec` and `int_typespec` ONLY** — its `switch`
   has no other arm, so `integer`, `byte`, `shortint`, `longint`, a typedef and
   an untyped parameter all leave `isSigned` FALSE however signed the language
   says they are. `setRange` (`CompileHelper.cpp:5417`) mints a `logic_typespec`
   only when the Value carries an lr/rr RANGE, which a scalar parameter does
   not — so the ONLY typespec that can appear here is the bare signed
   `int_typespec` of point 3.

The two Surelog lines in points 3 and 5 predict the whole 15-row declared-type
grid of §4 in advance, and the grid confirms every row.

---

## 3. Question 1 — THE CENSUS: every select in a port connection, both corpora

`ct84cen.cpp` reads a `.uhdm` **DIRECTLY** (never a whole-dump diff — Earlgrey's
dump is >1 GB; earl61's direct-reader pattern) and enumerates **SELECTS**, not
bounds, so a bound that folded on one side and stayed a reference on the other
is still found under the SAME key. KEY = `SPAN + SLOT + SEL + INHP + CTX +
PORTPAR + CALLARG + PSBOUND`; PAYLOAD = `KIND NAME SZ VAL CT DEC TS TSN TSSG
TSVL TSRG TSAL TSIN TSCE HPNM CS IPT` — every field `typespec::Compare`,
`int_typespec::Compare` and `hier_path::Compare` actually read, and no
span-derived field (earl60's attrv60 lesson). `CTX`/`PORTPAR` come from the
parent walk, so the **ELAB (`PORTPAR=module_inst`) and DEF (`PORTPAR=ref_module`)
copies of one connection are separate cells** — that split is the law's whole
context test, read out of the data. `score84.py` is a **multiset** join.

Over the **42 surelog** and **36 uhdm2rtlil** databases that hold a
port-connection select at all (of 956 / 1358):

| | surelog pristine | surelog patched* | u2r pristine |
|---|---:|---:|---:|
| BOTH-SAME | 67520 | — | 884 |
| MOVED-WRONG | 30 | — | 0 |
| GOLDEN-ONLY | 1358 | — | 72 |
| OURS-ONLY | 4911 | — | 72 |
| **FAMILY-HP** (golden a folded `constant`, ours a `ref_obj`, ELAB port High_conn, INSIDE a hier_path) | **6** | **0** | **0** |
| FAMILY-BARE (the same OUTSIDE a hier_path) | **0** | 0 | **0** |
| FOLD-ELSEWHERE (the same in any other context) | **0** | 0 | **0** |

\* the patched columns are the two movers' **fixed-universe** re-score below —
apples to apples.

**THE WHOLE POPULATION IS SIX CELLS, all `SLOT=BASE` — THREE SITES, ONCE PER
MODE, ALL IN `Earlgrey_0_1`, and all the same localparam:**

| source | written | golden ELAB High_conn base | ours (pristine) |
|---|---|---|---|
| `flash_ctrl.sv:171` | `reg2hw.addr.q[DataBitWidth +: AddrW]` | `constant sz32 UINT:2 ct9 dec"2"` + `int_typespec(signed)` | `ref_obj DataBitWidth` |
| `flash_ctrl.sv:249` | (identical) | (identical) | (identical) |
| `flash_ctrl.sv:277` | (identical) | (identical) | (identical) |

**The fence evidence golden itself supplies.** Every `ref_obj` golden leaves in
a bound slot of an ELABORATED port `High_conn`, corpus-wide, is a **part_select
bound** (2352 `i`, 24 `LsbAddrBit` — `compilePartSelectRange`'s `Reduce::No`)
or a **bit_select index naming a VARIABLE** (`usb_in_endpoint`, `sel`). There is
**not one ips-BASE `ref_obj` in golden anywhere in the corpus**, which is what
makes this call site incapable of contradicting golden.

---

## 4. The law

**§ `connHpIpsBaseNonOvParamFold84` — inside an ELABORATED port `High_conn`, the
BASE of the `indexed_part_select` that closes a `hier_path`, when it names a
MODULE-SCOPE parameter or localparam that was NOT overridden at this
instantiation, is that parameter's own `param_assign` Rhs constant RE-SIZED AT
THE DECLARED TYPE'S WIDTH — and it carries a BARE `int_typespec` with
`VpiSigned` set exactly when the declared typespec is a SIGNED `int` / `bit` /
`logic` one. The enclosing `hier_path`'s `VpiName` follows for free.**

Shipped in `src/ExprEmit.cpp` as one helper plus **one call site** — the
member-access `RangeSelect` arm that builds the hier_path, placed AFTER the base
emission and gated on the result still being a `ref_obj`.

### The fences, each a negative control MEASURED ON GOLDEN

| | fence | measured |
|---|---|---|
| (a) | `elabConnEmit21` — the **DEF `ref_module` listing keeps the ref** | golden holds `ref_obj DataBitWidth` at all three corpus spans under `PORTPAR=ref_module`, and so do we; on all four arms the workdir-normalised DEF section of the dump is **byte-identical** between the two binaries |
| (b) | the base must have **survived as a `ref_obj`** | every base an earlier law folds — a genvar, a package parameter (§ `selFold9`), a gen-scope localparam (§ `genLpUseFoldParentScope47`), an operation — arrives here already a constant and is untouched **by construction**. Arm cells `g4 gb[*].g02` (a gen-scope `localparam int`) and `g3 h06` (a literal) do not move |
| (c) | **not a package symbol** | `g2 u18`: a package parameter folds on § `selFold9`'s path at width 32 with **no** typespec, and agrees before and after |
| (d) | **user-call argument depth** (`callArgDepth - sysCallArgDepth22`) | **convicted by golden, both ways**: `g1 u_c4` `.a(uf84(reg2hw.addr.q[Db +: AddrW]))` — golden KEEPS the `ref_obj` and so do we, before and after; `g1 u_c5` `.a($unsigned(…))` — golden FOLDS it and the patch folds it to golden's exact cell. The test is never a plain `callArgDepth == 0` |
| (e) | **not overridden at this instantiation** | `g4 u_m1/u_m2 u_mq` and `u_mb`: golden's values for an OVERRIDDEN parameter are `UINT:5`/`UINT:7` at size **64** and `HEX:6` `4'h6` at size 4 — the actual's own encoding, never the declared width, because `collectParams_`'s override path (`DesignElaboration.cpp:2147-2172`) has no `adjustSize` and never calls `valueRange`. § `ovHopOverriddenKeepsValue80` / § `connBitSelIdxModParamFold81` own that producer; all four cells stay pristine. The **third** instance `u_m3`, with nothing overridden, folds and lands on golden exactly — verified in the dump per instance, not by the multiset |
| (f) | an **explicit, integral, non-enum** declared type of at most 64 bits, with a known nonnegative integer value | `adjustCopiedParamConst64`'s own fences F-A1/F-A2 refuse the rest; `g2 u12/u13/u16` (implicit-type parameters) stay on the pristine `ref_obj` — a MEASURED residue (R7), not a claim that golden keeps them |

### The declared-type grid (`g2_types84.sv`), golden, ELAB port High_conn, ips BASE

All hold the value 2. **Golden ⇒ patched on every row that is not refused.**

| declared type | golden | typespec | patched |
|---|---|---|---|
| `localparam int` | `UINT:2 sz32 ct9` | **`int_typespec(signed)`** | = golden |
| `localparam int signed` | `UINT:2 sz32 ct9` | **yes** | = golden |
| `localparam int unsigned` | `UINT:2 sz32 ct9` | — | = golden |
| `localparam integer` | `UINT:2 sz32 ct9` | — | = golden |
| `localparam byte` | `UINT:2 sz8 ct9` | — | = golden |
| `localparam shortint` | `UINT:2 sz16 ct9` | — | = golden |
| `localparam longint` | `UINT:2 sz64 ct9` | — | = golden |
| `localparam bit [3:0] = 4'd2` | `INT:2 sz4 ct7` | — | = golden |
| `localparam bit signed [3:0] = 4'sd2` | `INT:2 sz4 ct7` | **yes** | = golden |
| `localparam logic [7:0] = 8'd2` | `INT:2 sz8 ct7` | — | = golden |
| `localparam logic signed [7:0] = 8'sd2` | `INT:2 sz8 ct7` | **yes** | = golden |
| `localparam byte_t (= logic [7:0])` | `INT:2 sz8 ct7` | — | = golden |
| `localparam ls_t (= logic signed [7:0])` | `INT:2 sz8 ct7` | **yes** | = golden |
| `localparam signed [7:0]` | `INT:2 sz8 ct7` | **yes** | REFUSED (implicit type, R7) |
| `localparam [7:0]` | `INT:2 sz8 ct7` | — | REFUSED (implicit type, R7) |
| untyped `localparam` | `UINT:2 sz32 ct9` | — | REFUSED (implicit type, R7) |

The `bit [3:0]` and `logic [7:0]` rows are the proof that the encoding is the
parameter's **own** `param_assign` Rhs re-sized and not a flat decimal: a `4'd2`
initialiser is `INT:2` `vpiIntConst`, never `UINT:2`. A NEGATIVE base cannot be
armed at this position at all — slang rejects `q[-2 +: 8]` with `-Wrange-oob`
and the whole file with it — and the helper refuses `isNegative()` regardless.

---

## 5. Question 4 — the purpose-built goldens

`arm84.sh` builds each arm with Surelog (`-parse -nobuiltin -nocache -d uhdm`)
and with BOTH FROZEN binaries, censuses all three, and `score3_84.py` scores
every cell three ways. Every child gets `</dev/null` and its rc is recorded.
Full output: `ARMS.r10earl84.txt`.

The arm census adds **`INST=`** (the owning `module_inst`'s `VpiFullName`) to
the KEY. Without it a multiset join pairs the fold in ONE elaborated copy
against golden's value in ANOTHER and manufactures a phantom `WRONG->OTHER` —
it did, on `g4`'s three `mid84` instances, until the key was added. `INST` is a
CONTEXT CLASS in the key, never a payload field, and the corpus census leaves it
OFF so a naming residue cannot masquerade as a fold residue.

| arm | what it holds | SAME→SAME | WRONG→RIGHT | **RIGHT→WRONG** | WRONG→WRONG |
|---|---|---:|---:|---:|---:|
| `g1_hp84.sv` | the head minimised, then **11 CONTEXTS** for one and the same read: ELAB High_conn (×2 instances), an output port's High_conn, a user-call argument, a system-call argument, one operation deep, a module-body `cont_assign`, a procedural read, a procedural LVALUE, a gen-scope High_conn and gen-scope `cont_assign`, a declaration range bound | 27 | 14 | **0** | 1 |
| `g2_types84.sv` | **16 DECLARED TYPES** × the ips BASE, plus a package parameter | 36 | 26 | **0** | 6 |
| `g3_pos84.sv` | **THE POSITION GRID**: `+:`/`-:` BASE, ips WIDTH, `bit_select` IDX, `part_select` LEFT/RIGHT, a `var_select`+ips, each INSIDE and OUTSIDE a hier_path, DEF and ELAB | 29 | 2 | **0** | 13 |
| `g4_prod84.sv` | **THE PRODUCER GRID**: module localparam, expression and `$clog2` initialisers, a package parameter, a module parameter NOT overridden and the same one OVERRIDDEN at two instantiations with two encodings (`5`/`7`, `4'h6`/`4'd2`), a genvar, a gen-scope localparam | 26 | 16 | **0** | 10 |

**`RIGHT->WRONG` 0 and `WRONG->OTHER` 0 on every arm.** The 30 `WRONG->WRONG`
cells are classified one by one in `ARMS.r10earl84.txt` and ranked as R1-R4/R7
in `PREDICT_R0.txt`; not one of them is new.

---

## 6. The gates

All green — `GATES.r10earl84.txt` has the full battery. In one line: goldens
23/0 and 0/23 on the negative control; uhdm2rtlil 679/50/2 in both modes with
**0 differing rows** and **0 byte movers / 1358**; surelog 471+466 CMP_EQUAL /
10+9 CMP_NOTEQUAL with **0 differing rows over 1588** and **2 byte movers /
956** — exactly the two Earlgrey databases this pass PREDICTED BY NAME from the
pristine census, with no Scoreboard coin; canaries `ok=52` / `ok=8`
`changed=0`, both `ctcan2` PASS, `canaudit` `audited=29 UNCOVERED=0
FENCE-BREACH=0`, all five protected databases byte-identical (SVSwitch
`4842211c4030`, YosysVerx `6ccda350c24a`).

**THE MOVERS ARE ATTRIBUTED TWO WAYS, and both are exact.**

* **A run-time A/B gate.** The patched binary run with `R10E84_OFF=1` (the law
  disabled, everything else identical) reproduces the PRISTINE Earlgrey
  database **byte for byte in both modes** — `2a0b5eda6b19` and
  `469400b3a877`, the pristine sweep's own hashes — while the law ON gives the
  patched sweep's `eca4492a7f16` / `3d2354c0922c`. **100 % of each mover's byte
  delta is this law.**
* **The span-keyed direct-reader census.** The `.ours` delta is exactly 6 cells
  in default and 12 in testflags (the same three sites, elaborated twice): 3
  BASE cells replaced by the constant golden holds, field for field, and their
  3 WIDTH twins, which change ONLY in the enclosing hier_path's `VpiName`.
  Fixed-universe re-score: BOTH-SAME 8171 → **8183**, MOVED-WRONG 30 → **18**,
  GOLDEN-ONLY 30 → 30, OURS-ONLY 3422 → 3422, FAMILY-HP 6 → **0**. Per-cell
  3-way verdict: `WRONG->RIGHT` 6 per mode, **`RIGHT->WRONG` 0,
  `WRONG->OTHER` 0**. **MOVED-WRONG 0 / AWAY 0.**

**THE WIDE BOUNDARY** (`vwide84.sh`, 4 shards, list on fd 3, children
`</dev/null`, PROCESSED asserted): **LISTED = PROCESSED = 3753** `.sv`/`.v`
sources at any depth under `tools/probe`, both views, both frozen binaries,
workdir-normalised dump byte-compare — **7202 identical, 10 DIFFERING**.
**Eight are this pass's own four arms in both views.** The other two are
`r10buvm22repro/g22.sv`, and they are **not this law's**: the A/B gate proves it
(`R10E84_OFF=1` on the patched binary still prints the patched number, and the
pristine binary prints its own on repeat runs). The cell is a garbage numeric
literal our tool writes for a class-scope associative-array typedef on a
pre-existing path both binaries exit `rc=4` on, and its value **tracks the
binary's code layout** — see `PREDICT_R0.txt` **R5**, which is a real find worth
its own pass. rc histograms are symmetric side for side, `rc=139` 14/14 (the
pre-existing elab-view signals earl82's and earl83's R6 recorded).

---

## 7. Files

| | |
|---|---|
| `ct84cen.cpp` | the select-bound census; direct `.uhdm` reader, dispatches nothing |
| `cen84.sh` | runs it over a whole `verify_golden` workdir, golden path from each test's OWN `cmds.txt` |
| `score84.py` | the multiset join + the FAMILY extractor (`--family`, `--allmoved`, `--detail`) |
| `arm84.sh`, `score3_84.py` | one arm, three databases, the 3-way per-cell verdict |
| `vwide84.sh` | the wide boundary |
| `g1_hp84.sv` … `g4_prod84.sv` | the purpose-built goldens |
| `HEAD_BEFORE_*.cmp`, `HEAD_AFTER_*.cmp` | the verbatim `uhdm-cmp` logs, both modes |
| `CENSUS.r10earl84.txt`, `ARMS.r10earl84.txt`, `GATES.r10earl84.txt`, `BOUNDARY_WIDE.*` | the measurements |
| `PREDICT_R0.txt` | the mover prediction and the NEXT HEAD, decoded |

Build the census tool with
`g++ -O2 -std=c++17 ct84cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct84cen`.

`R10E84_OFF=1` disables the law at run time in the shipped binary; it is the
A/B gate every attribution in §6 rests on.
