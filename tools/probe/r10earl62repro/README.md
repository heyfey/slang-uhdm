# r10earl62 — § defBodyTypedefSiteShare62

**BOTH Earlgrey_0_1 heads CLEARED by ONE law, and the two modes now sit on the
SAME head, byte-identical cmp logs.  The pass is also a REFUTATION of the brief
it was dispatched with: the head was framed as "an ELABORATED cont_assign
assignment-pattern member value binds an Actual we leave null", and the census
says the assignment pattern has NOTHING TO DO WITH IT — the same reference in a
PLAIN cont_assign one screen down (`tlul_adapter_sram.sv:219`) is missing the
same edge, and the discriminator is which INSTANCE the reference sits in.**

Binaries: pristine `9aefca44d0a994e7ba84e5bfc5c8c6cc`,
patched `bea968278278c25e502eda308f26723f`.
Baselines used are the ones **in this worktree** (`results/gate_uhdm2rtlil.csv`,
`results/golden_surelog.csv`); `results/*.csv` was never written.

| head | pristine | patched | heads |
|---|---:|---:|---:|
| Earlgrey_0_1/default   | 19 cmp lines | **64** | 1 → 1 |
| Earlgrey_0_1/testflags | 37 cmp lines | **64** | 1 → 1 |

(cmp LINE COUNT is HEAD DEPTH, never a distance.  Both new logs are
`cmp -s`-IDENTICAL to each other: the two modes reached one common family.)

---

## 1. THE LAW

> **§ defBodyTypedefSiteShare62** — Surelog compiles a module's (or interface's)
> own `typedef`s **ONCE PER DEFINITION**, not once per instance: they live in
> the `DesignComponent`'s `DataTypeMap`, `UhdmWriter::writeDataTypes` writes
> them once, and every elaborated instance's `Typespecs()` lists **those same
> objects**, whatever its parameterization.  So a signal declared with a
> module-local typedef carries the DEF's `struct_typespec` / `enum_typespec`
> in **every** instance, and a reference to a module-local enum constant binds
> the DEF's single `enum_const` in **every** instance.
>
> slang mints a fresh `TypeAliasType` and a fresh `EnumValueSymbol` **per
> SPECIALIZATION**.  Our two registries (`typedefTs`, `enumConstMap`) are keyed
> on those symbols and are filled from ONE body — the first instance found for
> the definition, the one that produces the def-view listing — so every OTHER
> specialization missed: its signals fell through to a bare nameless
> `logic_typespec` and its enum references got no `vpiActual` at all.
>
> The fix keys the same two registries a second time on the typedef's
> **declaration SYNTAX NODE**, which every specialization of one module
> declaration shares, and consults it only when the symbol-keyed lookup misses.

### 1.1 The proof that golden shares ONE object

`mlts62.cpp` reads the `.uhdm` directly (Earlgrey's `uhdm-dump` is >1 GB and
takes hours — earl61's `hccen61.cpp` lesson) and prints each instance's own
typespecs and each signal's resolved typespec **with the object id**:

```
GOLDEN, default:
 TS DEF  work@tlul_adapter_sram            OWNTS enum_typespec:req_op_e  n=3 id=191242
 TS ELAB …u_dm_top.tl_adapter_device_mem   OWNTS enum_typespec:req_op_e  n=3 id=191242
 TS ELAB …u_tl_adapter_rom                 OWNTS enum_typespec:req_op_e  n=3 id=191242
 …all nine…                                                                  id=191242
 TS ELAB …u_tl_adapter_rom  VAR struct_typespec:req_t n=4 id=191248 reqfifo_rdata
 …all nine…                                                        id=191248
OURS (pristine), default:
 TS ELAB …u_dm_top.tl_adapter_device_mem VAR struct_typespec:req_t n=4 id=153253 reqfifo_rdata
 TS ELAB …u_tl_adapter_rom               VAR logic_typespec:       n=-1 id=242304 reqfifo_rdata
 TS ELAB …u_tl_adapter_ram_main          VAR logic_typespec:       n=-1 id=244792 reqfifo_rdata
 …seven more, one FRESH nameless logic_typespec each…
```

ONE instance right, EIGHT wrong — and the right one is
`u_dm_top.tl_adapter_device_mem`, which is exactly the FIRST
`tlul_adapter_sram` in slang's elaboration order (`top_earlgrey.sv:315`
instantiates `u_dm_top` before `u_tl_adapter_rom` at `:355`), i.e. the body
our def view was emitted from.  That is the whole law in one line.

### 1.2 Decoded from Surelog, not guessed

* `UhdmWriter::writeDataTypes` is called per `DesignComponent`;
  `writeInstance` hands the instance the definition's typespec vector.  There is
  no per-instance typedef compile at all.
* `ElaboratorListener::enterModule_inst` (UHDM `templates/ElaboratorListener.cpp`
  ~325) collects the enum constants for name binding from
  **`defMod->Typespecs()`** — the DEFINITION's list — into `paramMap`, and
  `leaveRef_obj` binds `bindAny(name)` from it.  Under `-elabuhdm` that is what
  re-binds `OpRead` for golden AND for us, which is why the *testflags* head was
  the `typespec_member` and not the `enum_const`.
* `clone_tree`'s `hier_path` resolver (UHDM `templates/clone_tree.cpp` ~1940)
  walks the ROOT's variable, reads its `Typespec()->Actual_typespec()`, and only
  if that is a `struct_typespec` does it bind the element to the matching
  `typespec_member`.  With a nameless `logic_typespec` on `reqfifo_rdata` the
  walk stops — which is why the SAME root cause shows as an *enum* head in
  default mode and a *typespec_member* head under `-elabuhdm`.

### 1.3 THE BRIEF'S FRAMING, REFUTED BY THE CENSUS

The dispatch called the family "a reference under an ELAB cont_assign
assignment-pattern (op75) member value".  `cacen62.cpp` censuses **every**
reference under **every** cont_assign in the whole database, keyed by
(section, owner DEFNAME, cont_assign line:col, positional path, ref kind:name)
→ Actual kind(name); the key carries no span and no fullname of the target,
which is all `design::Compare` reads there.  Golden-vs-ours, default mode,
whole DB:

```
  GOLDEN-BINDS enum_const   40 cells, and they are exactly FIVE keys x 8:
  g=9 o=1  ELAB work@tlul_adapter_sram L129:10 RHS/op75[1]/op32[0]/op26[1]/op15[1] ref_obj:OpRead
  g=9 o=1  ELAB work@tlul_adapter_sram L129:10 RHS/op75[6]/op32[0]/op26[1]/op14[1] ref_obj:OpRead
  g=9 o=1  ELAB work@tlul_adapter_sram L201:10 RHS/op75[0]/op32[1]           ref_obj:OpWrite
  g=9 o=1  ELAB work@tlul_adapter_sram L201:10 RHS/op75[0]/op32[2]           ref_obj:OpRead
  g=9 o=1  ELAB work@tlul_adapter_sram L219:10 RHS/op32[0]/op28[0]/op14[1]   ref_obj:OpRead   <-- NO op75
```

`L219` is `assign rspfifo_rready = (reqfifo_rdata.op == OpRead & …)` — a PLAIN
cont_assign with no assignment pattern anywhere, missing the same edge in the
same eight instances.  The pattern is not the carrier; the INSTANCE is.
The same census in testflags mode gives seven keys x 8 = 56 `typespec_member`
cells, again including `L219`.

---

## 2. MEASURED ON GOLDEN BEFORE A LINE OF CODE — three grids

`arm62.sh` runs Surelog (`-parse`, plus `-elabuhdm` for the `--elab` view) and
our binary on the same source in a private scratch dir.  **LHS is always
golden.**

### g1_earl62.sv — the FIRST grid, which measured EQUAL and was WRONG to trust
Two specializations of one module with a module-local `typedef enum` **and a
variable of that enum type beside it**.  `PASS_CMP`, and the enum reference is
bound on BOTH instances.  *An arm agreeing is not an arm testing:* the
`loc_op_e cur;` declaration makes our `makeTypespec` build a FRESH per-instance
`enum_typespec` for the second body, which registers that body's
`EnumValueSymbol`s in `enumConstMap` **by accident**.  Earlgrey has no variable
of type `req_op_e` at all — the enum is only a struct MEMBER type and a name in
expressions — so nothing registers the second body there.  g1 is kept as the
NEGATIVE control and as the record of the trap.
(g1's struct half DOES reproduce: `u_b VAR logic_typespec:` where golden has
`struct_typespec:loc_t id=41`.)

### g2_earl62.sv — the witness, BOTH heads in 45 lines
Same shape with the enum used only as a struct member type.  Pristine:

| view | pristine | patched |
|---|---|---|
| plain  | `CMP_FAIL` 1 head, 19 lines — `enum_const: (EB) … RHS: <null>` | **`PASS_CMP`, heads = 0** |
| --elab | `CMP_FAIL` 1 head, 37 lines — `typespec_member: (op) … RHS: <null>` | **`PASS_CMP`, heads = 0** |

Those are the two Earlgrey heads, object-for-object, in a 45-line file, and
**g2 CONVERTS in both views**.

### g3_earl62.sv — the whole reach, and the four controls
Every carrier the head could have been about, on a module with two
specializations, beside four controls that would have made a narrower law
right.  Golden vs pristine (ELAB, second specialization):

| row | carrier | golden | ours (pristine) |
|---|---|---|---|
| a | plain cont_assign RHS, `v.op == CB_` | `enum_const` | **—** |
| b | op75 member value, direct | `enum_const` | **—** |
| c | op75 member value, ternary CONDITION | `enum_const` | **—** |
| d | op75 member value, ternary ARM | `enum_const` | **—** |
| e | op75 member value, binary operand | `enum_const` | **—** |
| f | op75 member value, concat operand | `enum_const` | **—** |
| m | GEN-SCOPE cont_assign reading the module-local enum | `enum_const` | **—** |
| — | module-local struct var `v` (`c_t`) | `struct_typespec:c_t` | **`logic_typespec:`** |
| — | module-local nested struct net `ov` (`c_outer_t`) | `struct_typespec:c_outer_t` | **`logic_typespec:`** |
| CONTROL | PACKAGE enum `q62::QB`, PACKAGE struct `qv.m` | bound | bound (agree) |
| CONTROL | ANONYMOUS enum variable `anv == AN1/AN2` | bound | bound (agree) |
| CONTROL | GEN-SCOPE-local typedef `gvv == GB` | bound | bound (agree) |
| CONTROL | single-instantiation module `c62_one` | bound | bound (agree) |

The carrier grid is FLAT — every carrier fails, and the four controls all agree
pristine, which is what fences the fix to module/interface-definition typedefs
of a multiply-specialized module.

---

## 3. THE CODE (three hunks, 80 lines, 78 of them comment)

* `include/UhdmExporter.h` — two site-keyed registries beside the symbol-keyed
  ones: `typedefTsSite62` (syntax node → typespec) and `enumConstSite62`
  (declarator syntax node → enum_const).
* `src/TypeEmit.cpp`, `emitTypedefs` — next to the existing
  `typedefTs[&ta] = ts`, record the SAME object under `ta.getSyntax()`, and for
  an enum target record each `EnumValueSymbol`'s `enum_const` under its own
  declarator syntax.  `emplace` = first writer wins, and `emitTypedefs` runs
  only for a module/interface DEFINITION listing, so the object handed out is
  always the def's and package / class / gen-scope typedefs never enter.
* `src/TypeEmit.cpp`, `makeTypespec` — after the `typedefTs` miss, a
  `TypeAlias` declared type consults `typedefTsSite62`.
* `src/UhdmExporter.cpp`, the deferred `pendingEnumRefs` drain — after the
  `enumConstMap` miss, consult `enumConstSite62`.  Deferred on purpose: a
  reference only reaches that queue when every earlier arm in the ExprEmit
  chain declined it, so the arms that model golden's DELIBERATE non-binds
  (§ enumNoBind13, § genCaEnumConstNoBind21, LAW C's class/out-of-body halves)
  are untouched by construction — this can only turn a NULL into the bind
  golden makes.

---

## 4. THE MEASUREMENTS

### 4.1 Earlgrey, whole-database censuses (direct `.uhdm` reads, no uhdm-dump)

3-way golden / pristine / patched, multiset-joined per key:

| census | mode | TO-GOLDEN | AWAY-GOLDEN | STILL-WRONG |
|---|---|---:|---:|---:|
| cont_assign reference Actuals (`cacen62`) | default   | **10** | **0** | **0** |
| cont_assign reference Actuals (`cacen62`) | testflags | **14** | **0** | **0** |
| signal typespecs (`mlts62`)               | default   | **64** | **0** | **0** |
| signal typespecs (`mlts62`)               | testflags | **64** | **0** | **0** |

(TO-GOLDEN counts distinct (key,value) CELLS; each corrected slot contributes
two — the wrong value going to 0 and the right value going to golden's count.
The 10 default cells are the 5 enum keys x 8 instances = 40 objects; the 14
testflags cells are 7 `typespec_member` keys x 8 = 56; the 64 typespec cells are
32 signals x 2.)  **Every cell this pass moves lands EXACTLY on golden, in both
modes, with zero AWAY-GOLDEN.**

### 4.2 Both heads, and the NEW one

Pristine default head (19 lines): `enum_const: (OpRead) id:191246 49:5-49:11
< enum_typespec (req_op_e) / RHS: <null>` — CLEARED.
Pristine testflags head (37 lines): `typespec_member: (error) id:191252
55:33-55:38 < struct_typespec (req_t) / RHS: <null>` — CLEARED.
The new head is in section 6.

### 4.3 Gate battery

| gate | result |
|---|---|
| build both, md5 | pristine `9aefca44…`, patched `bea96827…` |
| `tests/check_goldens.sh` (patched) | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → 23 FAIL (negative control) |
| u2r testflags vs committed `results/gate_uhdm2rtlil.csv` | **PASS**, every row byte-identical |
| u2r testflags vs MY pristine sweep | **PASS** |
| u2r default vs MY pristine sweep | **PASS** |
| surelog vs committed `results/golden_surelog.csv` | **PASS** (§4.5) |
| surelog vs MY pristine sweep | **PASS** (§4.5) |
| `byteverify.sh SELFCHECK=1` u2r | **MOVERS 2 / 1358**, both PREDICTED BY NAME (§4.4) |
| `byteverify.sh SELFCHECK=1` surelog | **MOVERS 2 / 956** — Earlgrey both modes, the TARGET (§4.5) |
| wide boundary (`vbndall62.sh`) | 1084 arms, 2168 runs, DIFFERING 14 (§4.6) |

Pristine status histograms (my own sweeps, this worktree's baselines):
u2r testflags 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL;
surelog 936 CMP_EQUAL / 20 CMP_NOTEQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL /
10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM.
`cmds.txt` audit: 1458 of 1462 u2r command files name the frozen binary under
test by absolute path; the other four contain no `slang:` line at all (golden
cache hit, non-comparable row) — checked for BOTH sweeps.

### 4.4 Mover PREDICTION, and the blind spot it started with

`predict62.py` reads only PRISTINE databases and flags a test when one
(DEFNAME, signal) carries both a named struct/enum typespec and a bare
`logic_typespec:`, or one (DEFNAME, cont_assign, path, ref name) carries both an
`enum_const`/`typespec_member` Actual and none.  Positive control: the Earlgrey
pristine database fires on both halves.

The FIRST run of it predicted **ZERO** u2r movers and was WRONG: `mlts62`
walked `module_inst` only, and `emitTypedefs` also runs for INTERFACES
(`emitInterfaceDef`).  With interfaces walked, the prediction is
**2 movers, `genvar_iface_struct` in default and in testflags** — exactly and
only what `byteverify` then found.  The blind spot is recorded in the probe
source so the next pass does not re-cut it.

Attribution of both movers (path-normalised sectioned 3-way vs the golden cache
entry named in that row's own `cmds.txt`):

```
default   TO-GOLDEN=2  AWAY-GOLDEN=0  STILL-WRONG=0
  golden=0  pristine=4  patched=0   \_logic_typespec: , line:8:3, endln:8:8
  golden=13 pristine=9  patched=13  \_struct_typespec: (req_t), line:6:11, endln:6:56
testflags TO-GOLDEN=2  AWAY-GOLDEN=0  STILL-WRONG=0   (identical rows)
```

`myif`'s interface-local `typedef struct packed {…} req_t;` on the second and
third interface instance.  The row was CMP_EQUAL before and stays CMP_EQUAL —
`design::Compare` never reached those cells — so this is an UNMASKING toward
golden inside an already-passing row, not a conversion.

### 4.5 Corpus rows — NOTHING MOVED

| comparison | result |
|---|---|
| surelog vs committed `results/golden_surelog.csv` | **PASS: every row byte-identical** |
| surelog vs MY pristine sweep | **PASS: every row byte-identical** |
| status histogram, patched | 936 CMP_EQUAL / 20 CMP_NOTEQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM — identical to pristine |
| `byteverify.sh SELFCHECK=1` surelog | **MOVERS 2 / 956** — `Earlgrey_0_1` default and testflags, i.e. the TARGET and nothing else |
| PREDICTION for surelog, from pristine DBs only | **2 movers, `Earlgrey_0_1` default + testflags** — exact match, by name |
| canaries | surelog `ok=52 changed=0`, u2r `ok=8 changed=0` |
| ctcan2 | surelog PASS (ok=58 changed=0), u2r PASS (ok=1 changed=0) |
| canaudit | `audited=29 UNCOVERED=0 FENCE-BREACH=0` PASS |
| protected DBs (md5, both modes) | InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME**; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |

Row heads, pristine → patched (`rowheads.sh`, DEPTH not distance):

```
SeqDriver    176/176 -> 176/176      SimpleUVM  176/176 -> 176/176
Scoreboard   176/SKIP -> 176/SKIP    MiniAmiq   176/176 -> 176/176
BuildUVMPkg   31/31  ->  31/31       Rggen       36/SKIP ->  36/SKIP
Earlgrey_0_1  19/37  ->  64/64                      <== this pass
```

**NO row's status changed, so NOTHING was promoted and `results/*.csv` was not
touched.**  Earlgrey_0_1 remains CMP_NOTEQUAL (it is the standing head row).

### 4.6 Wide boundary

`vbndall62.sh` (carried from earl61) runs EVERY `.sv` arm under
`tools/probe/*/` with BOTH frozen binaries, in the PLAIN and the `--elabuhdm`
view, and byte-compares workdir-normalised dumps.  Arms are listed by the
subdirectory glob (`PROCESSED` asserted against `LISTED`), children run with
`</dev/null`, and every run's exit code is recorded per (arm, view, SIDE) so a
crash can be attributed.

Result (final tally below): the only NON-earl62 arm that moved is

* **`r10earl59repro/v59w2_shapes59.sv`** — the arm guarding
  § genCaNestedModuleLhsOpRhsBinds59.  It moved in BOTH views, and it moved
  **TOWARD GOLDEN**: the sectioned 3-way line multiset against Surelog reads
  `TO-GOLDEN=4  AWAY-GOLDEN=0  STILL-WRONG=1` in the plain view and the same in
  the elab view.  The rows are

  ```
  TO-GOLDEN    golden=11 pristine=9  patched=11  \_struct_typespec: (st_t), line:12:11, endln:12:58
  TO-GOLDEN    golden=0  pristine=1  patched=0   \_logic_typespec: , line:16:3, endln:16:7
  TO-GOLDEN    golden=0  pristine=1  patched=0   \_logic_typespec: , line:17:3, endln:17:7
  TO-GOLDEN    golden=0  pristine=1  patched=0   \_enum_typespec:
  STILL-WRONG  golden=11 pristine=9  patched=10  \_enum_typespec: (en_t), line:13:3, endln:13:46
  ```

  Every moved line is a TYPESPEC line on the SECOND specialization's signals —
  **no `vpiActual` / binder line moved at all**, so the earl59 law's own cells
  (the `bindVariable` / `writeCont_assign` mirror) are untouched, and the arm's
  judged result is unchanged (`CMP_FAIL`, 1 head, 45 lines, both views, on both
  binaries).  The one STILL-WRONG cell (`en_t` 9→10 where golden is 11) is the
  residue ranked R2 below.

  This is stated LOUDLY because the brief says that arm "must stay
  byte-identical": it did **not**, and the measurement says the change is a
  strict improvement with zero away-golden cells.  The `dut.sv`-style
  boundary arms of earl45–61, the uvm/buvm arms and the port-`high_conn` arms
  are all byte-identical.

Final tally:

```
PROCESSED arms=1084 (asserted: the glob reached every subdirectory arm)
WIDE BOUNDARY: runs=2168 arms=1084 identical=2123 DIFFERING=14 no_output=31
signal rows: patched=3 pristine=3      <-- SYMMETRIC, same three arms on both
  rc=139 elab r10buvm8repro/v21shadow8.sv
  rc=139 elab r10uvm84repro/v84x8_break.sv
  rc=139 elab r10uvm87repro/v87_a4_scope.sv     (all PRE-EXISTING crashes)
```

The 14 differing entries are this pass's own three witness arms
(`g1/g2/g3_earl62.sv`, counted twice because they are reached by both globs)
plus `v59w2_shapes59.sv` in both views.  Fourteen detections on a sweep whose
job is to find movers is also its own POSITIVE CONTROL: the instrument sees.

---

## 5. RESIDUES THIS PASS DID NOT TAKE (measured, ranked in PREDICT_R0.txt)

* **R1 — a GEN-SCOPE cont_assign reading a module-local enum constant.**
  g3 row (m), `work@c62 L71:14 … ref_obj:CB_`: golden binds the `enum_const`,
  we still bind nothing after the fix.  The reference never reaches the
  deferred `pendingEnumRefs` queue, so the site-keyed recovery cannot see it —
  some earlier arm of ExprEmit's NamedValue chain claims it.  Deliberately NOT
  widened: § genCaEnumConstNoBind21 is a landed MEASURED-NEGATIVE for gating
  that chain on gen-scope, and the right move is to find which arm swallows it
  first.
* **R2 — one uncovered ENUM site.** earl59's `v59w2` arm ends at
  `\_enum_typespec: (en_t)` count 10 where golden has 11 (pristine 9).  One
  further ELAB copy of a module-local enum typedef is still ours-fresh: an
  `enum_var`'s OWN base typespec, not the typedef listing this pass keys.
* **R3 — `c_t varr [0:1]`**, an unpacked ARRAY of a module-local struct
  typedef, is missing entirely from the second specialization's `Variables()`
  on our side (golden lists it with an `array_typespec`).  PRE-EXISTING:
  pristine and patched are identical there.
* g2's earlier form carried an `assign v = '{op: EA, …}` that produced an
  UNRELATED pattern-constant head and masked the law; it is removed from the
  arm with the reason recorded in the source, not silently.

---

## 6. THE NEW HEAD

Both modes, identical logs: a `param_assign` Rhs constant at
`prim_ram_1p_adv.sv:32:41` (`localparam int Aw = vbits(Depth)`, elaborated as
`work@top_earlgrey.u_ram1p_ram_main`, Depth = 16384 so the value is 14).
Golden writes `INT:14`, `vpiConstType 7`, `vpiDecompile "14"`; we write
`BIN:00000000000000000000000000001110`, `vpiConstType 3`, decompile
`"32'b…1110"`.  Same slot, same size, same typespec chain — a VALUE-ENCODING
family, not a missing object.  Full statement, decode plan and ranked queue in
`PREDICT_R0.txt`.

---

## 7. FILES

| file | what it is |
|---|---|
| `cacen62.cpp` | cont_assign REFERENCE-BINDING census, read straight from a `.uhdm` (Earlgrey's `uhdm-dump` is >1 GB) — one keyed line per Compare-visible reference slot, key = (section, owner DEFNAME, ca line:col, positional path, ref kind:name); `R10E62_INST=1` swaps the DEFNAME for the instance fullname when the question is WHICH instance |
| `cacensus62.py` | multiset join of two `cacen62` censuses (golden vs ours), bucketed by direction and Actual kind |
| `cen3way62.py` | see `README` §4.1 — the 3-way golden/pristine/patched multiset join used for every census number here |
| `mlts62.cpp` | MODULE-LOCAL TYPESPEC census: each module/interface instance's own `Typespecs()` and every net/variable's resolved typespec, WITH the object id (that is what proved golden shares ONE object across nine instances) |
| `predict62.py` | mover PREDICTION from PRISTINE databases only, by name |
| `arm62.sh` | one arm: Surelog + ours on the same source, `--elab` toggles `-elabuhdm` on BOTH sides |
| `earl62.sh` | Earlgrey_0_1 in either mode against the immutable golden cache |
| `sect3way62.sh` | the sectioned (DEF+ELAB, no weaklyReferenced tail) path-normalised 3-way line multiset |
| `vbndall62.sh` | the WIDE boundary sweep (every probe `.sv`, both views, both binaries, rc recorded per side) |
| `g1_earl62.sv` | the grid that measured EQUAL and was WRONG to trust — kept as the negative control |
| `g2_earl62.sv` | the witness: BOTH Earlgrey heads in 45 lines; **CONVERTS in both views** |
| `g3_earl62.sv` | the full carrier grid + the four controls |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`, `rowheads.sh`, `byteverify62.sh` | carried forward unchanged |
