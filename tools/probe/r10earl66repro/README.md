# r10earl66 — § elabConnEnumConstFold66

**BASE `f7cc5ad`.  Earlgrey_0_1, BOTH modes.  The head earl65 named as R0 is
CLEARED; the new head is in `PREDICT_R0.txt`.**

Pristine binary md5 `b10a3f6e195760bb08a26b9e13b79060`,
patched binary md5 `aa09dc513ae0d50e02708833ede679bb`.
Golden caches (immutable, read-only): `00d4794526e44dc553f3` (default),
`d7348d2d2fe67abe767b` (testflags).

---

## 1. The head, decoded before any code

```
LHS: constant  id:309503  163:17-163:24
     |vpiParent -> bit_select (work@…gen_flash_banks[0].i_core.i_rd.reqs)
     |vpiDecompile:3'h0  |vpiSize:3  |HEX:0  |vpiConstType:5
RHS: ref_obj (work@…gen_flash_banks[0].i_core.PhyRead) id:252928 163:17-163:24
     |vpiName:PhyRead  |vpiActual -> enum_const (PhyRead) id:1094 71:5-71:24
```

`bit_select::Compare` (UHDM/build/generated/src/bit_select.cpp) compares
`VpiConstantSelect` and then runs the **singular**
`SafeCompare(lhs->VpiIndex(), rhs->VpiIndex(), context)`.  Both operands are
**non-null** with **different `UhdmType`**, so `BaseClass::Compare`'s type test
fails first and BaseClass.h:188's `(lhs != nullptr) && (rhs != nullptr)` arm
names **both** sides in full.  This is neither the `<null>` singular arm nor a
vector size mismatch — read the MK line, not the shape (RESUME §9).

The owner is `.req_i(reqs[PhyRead])` at `flash_phy_core.sv:163` inside
`gen_flash_banks[0].i_core`, `PhyRead` a **package** enum member
(`flash_phy_pkg.sv:70  typedef enum logic [2:0] { PhyRead = 3'h0, … }`), read
as the **index of a bit_select in an ELABORATED port `High_conn`**.

> **Golden FOLDS an enum-constant read inside an elaborated port connection to
> a constant carrying the member's own encoding; we keep the `ref_obj ->
> enum_const`.**

## 2. The census: 32 cells, and what else is in the superfamily

Direct `.uhdm` reader, never `uhdm-dump` (Earlgrey's dump is >1 GB — the
earl61-65 rule).  `tscen66` walks the DEF listing and the ELAB instance tree and
prints one keyed line per leaf of every `cont_assign`, port `High_conn`,
`param_assign` and declaration-assign, with the constant's four judge-visible
fields *and* — new in this pass — the `ref_obj`'s **Actual_group kind** plus
that actual's own value/decompile/size.  Key = `(sec, owner-instance, site,
positional route)`; the span's FILE part is normalised away because our objects
carry an empty `VpiFile` (RESUME §9).

**Calibration first (RESUME §9):** golden re-read is **byte-identical**, and the
golden-vs-golden multiset join is **0 differing cells / 162,259 STILL-RIGHT**.

Whole-design kind-pair join, pristine binary, default mode:

```
  2254  G=constant             O=ref_obj        <-- the "golden folds / we do not" SUPERFAMILY
  1136  G=constant             O=constant       (field/typespec differences)
  1045  G=<none>               O=ref_obj
   725  G=ref_obj              O=<none>
   508  G=ref_obj              O=ref_obj
   ...
```

Split the 2,254 by position and by the kind of the symbol we keep a ref to:

| cells | sec | site | position | referenced kind | symbol |
|---:|---|---|---|---|---|
| 1995 | ELAB | cont_assign | bit-select idx | (unbound) | `C0`/`C1`/`Pa` gen-scope localparams |
| 89 | ELAB | cont_assign | whole Rhs | (unbound) | `offset` |
| 87 | ELAB | cont_assign | `op11[]` operand | (unbound) | `IDW` |
| 32 | ELAB | cont_assign | `op33[]` operand | (unbound) | `MioPeriphHasSleepMode` |
| **30** | **ELAB** | **High_conn** | **bit-select idx** | **enum_const** | `PhyRead/PhyProg/PhyPgErase/PhyBkErase/FwModeRx/TxFifo` |
| 16 | ELAB | High_conn | bit-select idx | (unbound) | `N`, `STIDW`, `DataBitWidth` |
| 3 | ELAB | High_conn | ips base | (unbound) | |
| **2** | **ELAB** | **High_conn** | **`op14[]` operand** | **enum_const** | `PageErase`, `BankErase` |

**32 cells are this pass's family** — and the decisive measurement is the
complementary one, every cell where OURS is a `ref_obj -> enum_const`:

```
   587 ELAB CA   op14[]  GOLDEN=ref_obj  SAME     |
   553 ELAB CA   op15[]  GOLDEN=ref_obj  SAME     |  golden KEEPS the ref in
   111 DEF  CA   op14[]  GOLDEN=ref_obj  SAME     |  every cont_assign, both
    68 ELAB CA   op32[]  GOLDEN=ref_obj  SAME     |  views: 1,326 ELAB + 146 DEF
    64 ELAB CA   op25[]  GOLDEN=ref_obj  SAME     |
    32 ELAB CA   op24[]  GOLDEN=ref_obj  SAME     |
    21 ELAB CA   op95[]  GOLDEN=ref_obj  SAME     |
    20 DEF  CA   op32[]  GOLDEN=ref_obj  SAME     |
    10 DEF  CA   op15[]  GOLDEN=ref_obj  SAME     |
     5 DEF  CA   op95[]  GOLDEN=ref_obj  SAME     |
    30 ELAB HC   idx     GOLDEN=constant DIFF     <-- fold
     2 ELAB HC   op14[]  GOLDEN=constant DIFF     <-- fold
  TOTAL 1503
```

So the split is **position, not origin**: an ELAB port `High_conn` folds, every
`cont_assign` (both views) and every DEF-view `ref_module` `High_conn` keeps the
reference.  `GRIDS_66.txt` holds the full position × encoding grid measured on
golden.

## 3. Where it comes from in Surelog (decoded, not guessed)

`NetlistElaboration::high_conn_` (`src/DesignCompile/NetlistElaboration.cpp:854`)
compiles a port-connection actual with

```cpp
m_helper.compileExpression(parent_comp, fC, node, m_compileDesign,
                           Reduce::Yes, /*pexpr=*/nullptr, /*instance=*/parent);
```

— it **re-compiles the actual in the parent INSTANCE's context** instead of
cloning the DEF-view expression, which is the same sentence that produced
earl64's `connIpsBareBaseUint64` and earl65's `connIpsPkgParamBoundNoTs65`.
With `Reduce::Yes` an enum-member identifier is answered by `getValue` and the
constant is minted from the member's own `Value`; `LValue::decompiledValue`
supplies the decompile, which is why an `Int`/`UInt`-typed value prints bare
digits and a based value prints `<size>'<base><digits>`.  The DEF listing keeps
its `ref_obj` because it is compiled without that instance context — golden's
`ref_module` `High_conn` at the very same span holds `ref_obj -> enum_const`
(dumped on arm 1, §4).

## 4. The law and the code

> **§ elabConnEnumConstFold66** — inside an ELABORATED port `High_conn`, a read
> of an ENUM CONSTANT **that resolves to the enum member** folds to a constant
> carrying the member's own `VpiValue`/`VpiSize`, `vpiConstType` from the
> value's encoding prefix, and a decompile RE-MINTED from the value (bare digits
> for `INT:`/`UINT:`, `<size>'<base><digits>` otherwise), with **no typespec**.
> A **`part_select` bound** keeps the `ref_obj -> enum_const`.  The DEF view,
> every `cont_assign` and every procedural read are untouched.

One gate, `src/ExprEmit.cpp`, at the **end** of the `ExpressionKind::NamedValue`
case — deliberately **after** every binding arm, including
`§ pkgSubRefBindsPkgVarOverFormal81`'s last-writer overwrite — reading
`ref->Actual_group()`.

### Why it sits there: the fence, found by building it wrong first

A first cut placed the gate at the **head** of the case, keyed on
`nv.symbol.kind == SymbolKind::EnumValue`.  It cleared the head and passed u2r
(0 movers over 1,358 databases) — and **broke `Scr1SvTests` in BOTH modes,
CMP_EQUAL -> CMP_NOTEQUAL**, caught by the surelog whole-row gate:

```
scr1_top_axi.sv:562   .core_width     (SCR1_MEM_WIDTH_WORD    ),
LHS(golden) ref_obj (…i_top.SCR1_MEM_WIDTH_WORD) |vpiActual -> logic_net
RHS(ours)   constant |vpiDecompile:2'b10 |vpiSize:2 |BIN:10 |vpiConstType:3
```

Surelog never sees that typedef, mints an **implicit net** for the name and so
`getValue` answers nothing — golden's High_conn is `ref_obj -> logic_net`, and
our emitter already models the net.  slang **does** resolve the name, so a
symbol-kind gate fires where Surelog's does not.  Reading `Actual_group()`
instead makes our test exactly Surelog's: *fold the reads that DO resolve to the
enum member*.  It also leaves by construction every family that is deliberately
UNBOUND — `§ enumNoBind13`'s class-method and import-clone bodies, LAW C's
out-of-body method, the late-bound anonymous-enum pool.  Rebuilt, `Scr1SvTests`
is CMP_EQUAL again and the whole surelog corpus is 0 differing rows.

**The fence was hunted before the code too**, and the scan is committed
(`fencescan66.sh`): over **2,981 databases** (1,458 u2r + 1,523 surelog,
pristine binary) the ONLY databases carrying an ELAB port-`High_conn`
`ref_obj -> enum_const` are Earlgrey_0_1 in both modes, 32 cells each.  What that
scan could not see — and the gate could — is a name that our emitter binds to
something *else*: `Scr1SvTests`.  That is the lesson worth carrying: a census
keyed on the shape you intend to CHANGE is blind to the rows you would change
BY ACCIDENT; only the corpus gate sees those.

## 5. Arms (the grid), scored against golden

`g1_enum66.sv` — 10 enum members (sized hex / sized decimal / sized binary /
untyped / auto-valued / int-based / mixed) x positions (bit-select index, ips
base, ips width, part-select bounds, bare cast, operation operand, concat,
ternary) x homes (module body, gen-for, gen-if), module-local **and** package
enums, plus the cont_assign and procedural negative controls.
`g2_enc66.sv` — the ENCODING half: expression-valued, negative, >32-bit, signed,
octal, localparam-valued members, a `$unit` enum, three repeated instances, and
the package parameter/localparam twin.
`g3_bare66.sv` — the BARE actual (`.e_i(BH4)`) against an enum-typed and an
integral formal, written after `Scr1SvTests` to settle whether the bare position
folds.  **It does** — so the bare position is not the discriminator; resolution
is.

`score66.py` 3-way multiset join (golden / pristine / patched), payload reduced
to the fields the judge reads:

```
ARM g1_enum66  plain view  cells 235  STILL-RIGHT 206  TO-GOLDEN 17  AWAY 0  MOVED-WRONG 5
ARM g1_enum66  elab  view  cells 236  STILL-RIGHT 199  TO-GOLDEN 23  AWAY 1  MOVED-WRONG 2
ARM g2_enc66   both  views cells 100  STILL-RIGHT  83  TO-GOLDEN  3  AWAY 0  MOVED-WRONG 7
```

Every MOVED-WRONG / AWAY cell is accounted for and none is a regression:

* **5 (arm 1) + 2** are keys where **golden has `<none>`** because it reduced the
  WHOLE High_conn expression to one constant (`32'(EH4)`, `32'(EH4+1)`,
  `{29'b0,EH4}`, the ternary arms).  Wrong before (a `ref_obj` under an
  operation), wrong after (a `constant` under an operation), *closer* to golden
  in the leaf encoding.  The single `AWAY-GOLDEN` is the same thing seen through
  the multiset: pristine had no row at that sub-key at all.  This is earl60's
  `attrv60.py` lesson again — a positional key lies about a cell golden does not
  have.
* **7 (arm 2)** are the members whose **own enum_const encoding** already differs
  from Surelog's before this pass runs (`XA = 3'h2+3'h1`: golden `UINT:3`, ours
  `BIN:011`; `XO = 5'o17`: golden `UINT:15`, ours `OCT:17`).  Wrong before, wrong
  after — ranked **R2** in `PREDICT_R0.txt`, with **zero** cells of that shape in
  either corpus.
* the part-select arms (`u_ps`) and every cont_assign/procedural control are
  **STILL-RIGHT**: the negative control held.

## 6. Gates (all run in this worktree, both binaries frozen at 555)

| gate | result |
|---|---|
| build both, md5 | `b10a3f6e…` pristine / `aa09dc51…` patched |
| `tests/check_goldens.sh` (SLANG_UHDM exported per binary) | **PASS 23 / FAIL 0** |
| negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** |
| u2r testflags | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL |
| u2r default | 679 / 50 / 2 |
| `ct8rows` u2r tf vs **committed** `results/gate_uhdm2rtlil.csv` | **PASS, 0 differing rows** |
| `ct8rows` u2r tf/def vs this pass's own pristine sweep | **PASS, 0 differing rows** |
| `byteverify SELFCHECK=1` u2r (1358 DBs) | **MOVERS 0 / 1358**, selfcheck 1357/1358 |
| surelog `--mode both` (1588 rows, 956 DBs) | status histogram **IDENTICAL** to pristine |
| `ct8rows` surelog vs **committed** `results/golden_surelog.csv` | **PASS, 0 differing rows** |
| `ct8rows` surelog vs this pass's own pristine sweep | **PASS, 0 differing rows** |
| `byteverify SELFCHECK=1` surelog (956 DBs) | **MOVERS 2 / 956** = `Earlgrey_0_1` default + testflags, the PREDICTED set |
| Earlgrey both modes | head **CLEARED**, 1 head each, AFTER logs **byte-identical** |
| whole-design census, both modes | **32 TO-GOLDEN, 0 AWAY-GOLDEN, 0 MOVED-WRONG**, and those 32 are the ONLY cells that changed |
| golden-vs-golden calibration | 0 differing cells / 162,259 |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS / PASS |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected DBs by md5 | InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME**; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| `rowheads.sh` | only Earlgrey moved (36 -> 46); SeqDriver/SimpleUVM/Scoreboard/MiniAmiq 12, BuildUVMPkg 152, Rggen 36 unchanged |
| WIDE boundary (2,940 `.sv`, PROCESSED == LISTED, both views, both binaries) | **8 differing = this pass's 3 arms x 2 views + `r10earl61repro/g2_earl61.sv` x 2**, all scored below |
| per-DIRECTORY boundary (1,361 dirs, both views) | **7 differing** = `r10earl66repro` x2 + the KNOWN order coin (§6b) |

`cmds.txt` audited by BINARY PATH in every arm (1458 u2r + 1523 surelog lines,
all `/tmp/r10earl66_p{ristine,atched}.bin`), `SLANG_UHDM` exported explicitly per
binary, `GOLDEN_DEFER` unset, `results/*.csv` never written.  The 2 `rc=-11`
rows in the surelog sweep (`Tnoc`, both modes) are present on BOTH binaries —
pre-existing, not introduced.

### 6b. The boundary movers that are not movers

`r10uvm75repro`, `r10uvm76repro` and `r10uvm88repro` differ between the two
binaries in the per-directory arm — and differ between three runs of the **same**
(pristine) binary:

```
r10uvm75repro  fd09c790fa74 / d19e171af7d6 / a796d9fe1b1a
r10uvm76repro  0bcfb8930046 / cfd543a881ff / 1f7e308b2ebe
r10uvm88repro  8c69b82ecf73 / b585f2c7bac5 / 92c161c84a1a
```

and the patched-vs-pristine diff is **order-blind ZERO** on all three (sorted,
workdir-normalised dumps).  Documented `vpiTaskFunc` list-order coin (RESUME §9).
The 10 `rc=139` signals the wide boundary raises appear on **both** binaries,
paired one-for-one — pre-existing.

`r10earl61repro/g2_earl61.sv` is a REAL mover and it is scored, not listed:
`k61 i_en (.a(clk & (E1 == E1)), …)` — golden reduces the whole comparison to
`constant BIN:1 sz 1`, we kept two `ref_obj -> enum_const` operands and now emit
two `constant INT:1 sz 2` operands.  Wrong before, wrong after (R4 in
`PREDICT_R0.txt`); every other earl61 cell is STILL-RIGHT, and
`§ connOperandOwnScopeBind61`'s own binder cells are untouched.

## 7. Instruments (measurement only; the official `uhdm-cmp` is the judge)

* `tscen66.cpp` — whole-design expression census, direct `.uhdm` reader,
  positional route key; payload = the constant's four judge fields + typespec
  presence/kind, and for a `ref_obj` its **Actual_group kind** plus that actual's
  value/decompile/size.  Extends `r10earl65repro/tscen65.cpp`.  **No span in the
  scoring payload** (earl60's `attrv60.py` lesson; the raw line keeps one for
  eyeballing and `score66.py` is fed the same keyed lines both sides).
* `cen66.sh` — normalises the span FILE part so golden and ours join.
* `kindjoin66.py` — the (golden kind, ours kind) pair census.
* `sfam66.py` — ranks the "golden folds / we do not" superfamily by
  `(sec, site, position, referenced-symbol kind)` and by symbol name.
* `encen66.py` — every OURS `ref_obj -> enum_const` cell with what GOLDEN holds
  at the same key, bucketed SAME/DIFF.  This is the instrument that named the law.
* `fencescan66.sh` — the corpus-wide fence scan (every database in a sweep
  workdir carrying the shape the law would change).
* `score66.py` — 3-way multiset join, TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG /
  STILL-RIGHT / STILL-WRONG (from `r10earl64repro/score64.py`).
* `runarm66.sh` — one arm, Surelog + one binary in BOTH views, censuses printed.
* `tsdet66.cpp` — every judge-visible typespec field for the constants at a span.
* `vwide66.sh` / `vdir66.sh` — the recursive and per-directory boundaries; list on
  fd 3, children `</dev/null`, PROCESSED asserted; the four slang-fenced test
  names are filtered out of the list before dispatch.
* `earl66.sh` — one Earlgrey run, one binary, md5 printed, golden from cache.
* `armscore66.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`,
  `byteverify.sh`, `rowheads.sh` — the standard battery.
