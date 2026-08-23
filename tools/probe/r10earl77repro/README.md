# r10earl77 — § pkgScopedPortAnyDirVar77: a port written `pkg::T` is a VARIABLE, in every direction

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `a1da916`.** `results/*.csv` was READ ONLY and is untouched — **no row
was converted**; the master promotes rows, not this pass.

**The Earlgrey_0_1 head r10earl76 named as R0 — a `module_inst` vector size
mismatch, 11,664 cmp lines in default and 11,404 in testflags, one head each —
is CLEARED in both modes** (90 lines, one head, a different family in a
different instance). Every other named row's head is unchanged.

---

## 1. The head, reproduced before any code was written

This pass built its own binary from `a1da916` and got
`ce2ee168dd84bf64e3e6bb9aed5b82e7` — **byte for byte the main tree's own
`build/slang-uhdm`** — and re-measured the head on it rather than trusting
earl76's write-up:

```
Earlgrey_0_1   default      11664      1 head
Earlgrey_0_1   testflags    11404      1 head
```

Both sides of the head are the SAME `module_inst`
(`work@top_earlgrey.u_spi_device.u_fwmode`, `spi_fwmode.sv`), which is
`BaseClass::SafeCompare`'s VECTOR overload on a **SIZE MISMATCH**: it sets both
containers and names the OWNER on both sides, so the cmp log cannot say which
vector (RESUME §9). `tools/probe/r10earl76repro/mvec76.cpp` — earl76's
committed instrument, reused unchanged — prints every vector's size in
`module_inst::Compare` order; `HEAD_BEFORE_vectors_{golden,ours}.txt` are its
output on the golden cache entry and on this pass's own pristine database:

```
                golden   ours
Nets              17       18
Variables         11       10
   ... tx_data_i:  logic_var (Variables)   vs   logic_net (Nets)
```

`spi_fwmode.sv:31` is `input spi_device_pkg::spi_byte_t tx_data_i,` and
`spi_byte_t` is `typedef logic [7:0] spi_byte_t;` in `spi_device_pkg`.
`HEAD_BEFORE_NOTE.txt` records why only the first 40 lines of the cmp log are
kept here: **a cmp line count is the head's decompile DEPTH, never a distance.**

---

## 2. Question 1 — the CENSUS, and the exact boundary (`CENSUS.txt`)

Two direct `.uhdm` readers (Earlgrey's `uhdm-dump` is enormous — never diff it
whole; earl61's direct-reader pattern):

* **`cen77.cpp`** — every `module_inst` PORT: direction, the port's typespec
  kind and name, the `Nets`/`Variables`/`Array_nets` entry that backs it, and
  the port's `Low_conn` target.
* **`sig77.cpp`** — **EVERY** `Nets`/`Variables`/`Array_nets` entry of every
  `module_inst`, `gen_scope` and `interface_inst`. The head is a
  `Nets`/`Variables` SIZE mismatch, so a PORT-keyed census is structurally
  blind to a BODY signal that moves; this one is not, and it is the arbiter.

Calibrated **golden-vs-golden first**: identical key sets on both sides (cen77
21,809 / 21,809 rows; sig77 41,055 / 41,055, default). Our port objects carry
an EMPTY `VpiFile` (a pre-existing campaign residue), so the LOC field is
dropped from the cen77 key — nothing else needed normalising.

> **In the WHOLE Earlgrey design, in BOTH modes, there are exactly FOUR
> signal cells where our object kind differs from golden's. ONE of them is
> this head. The other three are two other families and are NOT touched.**

| instance | signal | golden | ours | family |
|---|---|---|---|---|
| `u_flash_ctrl.u_flash_mp` | `region_cfgs_i` | `packed_array_var` | `packed_array_net` | R2 |
| `u_hmac.u_sha2.u_pad` | `fifo_rdata` | `struct_net` | `struct_var` | R3 |
| **`u_spi_device.u_fwmode`** | **`tx_data_i`** | **`logic_var`** | **`logic_net`** | **THIS LAW** |
| `u_usbdev.i_usbdev_iomux` | `sys_reg2hw_config_i` | `struct_net` | `struct_var` | R3 |

**THE BOUNDARY, read off golden over the whole design** (elaborated instances,
direction × port-typespec kind × whether the typespec NAME is scoped / bare /
anonymous):

| written type | IN | OUT | INOUT | golden |
|---|---:|---:|---:|---|
| `logic_typespec`, **SCOPED** name (`pkg::T`) | 1 | 1 | 0 | **VAR (`logic_var`)** |
| `logic_typespec`, BARE name (imported / `$unit` / local typedef) | 2 | 1 | 0 | NET |
| `logic_typespec`, ANONYMOUS (`logic`, `logic [N:0]`, implicit, `wire`) | 11511 + 23 | 6529 + 5 | 100 | NET |
| `enum_typespec`, scoped | 87 + 2 | 45 | 0 | VAR |
| `struct_typespec`, scoped | 360 VAR / 51 NET / 26 array_var | 342 / 40 / 26 | 0 | (member scan) |
| `bit_typespec`, scoped | — | — | — | VAR |

**The discriminator is the SCOPED SPELLING, and direction is not in it at all.**
The five named-`logic_typespec` cells in Earlgrey are `sha_word_t` ×3 (reached
BARE through `import hmac_pkg::*` — NET in golden, in both directions) and
`spi_device_pkg::spi_byte_t` ×2 (SCOPED — VAR in golden, in both directions).
We already emitted the OUTPUT half (`rx_data_o`) as a `logic_var`; the INPUT
half was the head.

**The u2r corpus was scanned for the shape too** (`fencescan77.sh`,
`predict77.sh`, `PREDICT_MOVERS.txt`): it holds the shape only in DEFINITION
listings, which this law does not touch, and **0 u2r databases moved.**

---

## 3. Question 2 — the DECODE, from Surelog's source

`NetlistElaboration::elabSignal`
(`~/git-repos/Surelog/src/DesignCompile/NetlistElaboration.cpp:1908`) decides
net-vs-variable from the signal's `m_type`, which
`CompileHelper::getSignalType` (`src/DesignCompile/CompileHelper.cpp:1551-1590`)
sets to the **WRITTEN FORM** of the port's data type:

```c++
bool isNet = true;
if ((dtype && (subnettype == slNoType)) || sig->isConst() || sig->isVar() ||
    (subnettype == VObjectType::paClass_scope) ||        // <-- `pkg::T`
    (subnettype == VObjectType::slStringConst)  || … ) { isNet = false; }
if (sig->getDirection() == paPortDir_Out || … Inp || … Inout) {
  if ((!sig->isVar()) && (subnettype == VObjectType::paIntVec_TypeLogic))
    isNet = true;                                        // bare `logic`/`reg` only
}
```

A `pkg::T` spelling parses to `paClass_scope`, the ladder sets `isNet = false`
outright, and **the direction override right below it only fires for
`paIntVec_TypeLogic`** — so it never takes a scoped-typedef port back. Then the
typespec dispatch turns `enum`/`bit`/`byte`/`real`/`class` into variables and
runs the struct member scan; a `logic_typespec` falls through with `isNet`
still false. **Direction never enters the rule.**

**Why the ENUM input already came out right on our side and the vector input
did not.** `makeVar` (`src/TypeEmit.cpp:4881`) had TWO separate tests: the
first — "is this a port shape Surelog varifies?" — already listed
`pkgAliasPort`; the second — `internal.kind == SymbolKind::Variable` — is
slang's model of the **LRM** rule (23.2.2.3: an `input`/`inout` port is a NET
whatever its data type; an `output` with a data type is a variable). The enum
arm higher up carries its own `pkgEnumAlias` disjunct and so never consulted
`internal.kind`; the logic arm did, and net-ified every INPUT. That asymmetry
is the whole head.

---

## 4. The law

**§ pkgScopedPortAnyDirVar77 — a PORT whose written type is a SCOPED package
type name (`pkg::T`, `T` a packed logic vector) backs a VARIABLE, in EVERY
direction — `input`, `output` and `inout` alike, with or without a `wire` or
`var` keyword, ANSI or non-ANSI. It converts the object KIND and therefore its
CONTAINER (`Nets` → `Variables`); the port's `Low_conn` follows automatically
because the same `topNets` entry feeds it.**

```c++
bool pkgScopedPort77 = portBacked && pkgAliasPort;
if ((!portBacked || hasBodyDecl(internal) || pkgAliasPort || typeParamPort ||
     ansiVarKeywordPort(internal) || dirlessVarPort) &&
    !regDecl &&
    (internal.kind == SymbolKind::Variable || typeParamPort ||
     dirlessVarPort || pkgScopedPort77) &&            // <-- the whole change
    ct.kind != SymbolKind::PredefinedIntegerType && ct.isIntegral() &&
    ct.isFourState()) { … MakeLogic_var() … }
```

One production hunk, `src/TypeEmit.cpp`. `pkgAliasPort` is the existing
predicate (TypeAlias whose parent scope is a Package, written with a `::`
qualifier); the change is only that it now also satisfies the KIND test, and
only for a PORT-BACKED symbol.

**The three fences, all convicted on golden before the line was written:**

* **the name must be SPELLED SCOPED.** `pkgAliasPort` already drops a plain
  `IdentifierName`, and golden keeps a NET for an IMPORTED bare typedef
  (`import pkg::*; input v8_t x`), a `$unit` typedef and a MODULE-LOCAL typedef
  port — in BOTH directions (`g1`'s `i_impvec`/`i_unitvec`, `g2`'s
  `na_impin`/`na_locin`/`na_locout`, and Earlgrey's own three `sha_word_t`
  ports). This is the same `::` discriminator `§ defGenPkgParamFoldQual19` and
  `§ genNestedScopePkgParamNoFold24` carry.
* **PORT-BACKED only.** A BODY declaration keeps the path it already had —
  `g3_body77.sv` puts `pkg::T` body signals in plain, `wire` and `var` form in
  a module and in an interface, and **not one of them moves**.
* **the earlier arms still own their shapes.** A `pkg::struct_t` port returns
  from the struct arm before reaching here and golden agrees (`struct_net` in
  both directions); `pkg::enum_t`, `pkg::bit_t`, real/string/chandle/class each
  keep their own arm.

---

## 5. The golden grids (`GOLDEN_TABLE.txt`, `GRID_SCORE.txt`)

* **`g1_portkind77.sv`** — **20 written type shapes × {input, output}**, the
  leaf instantiated FIVE times: two driven, one **UNDRIVEN**, and two inside a
  **generate-for**. 40 port cells per instance.
* **`g2_portkw77.sv`** — the keyword / direction / style boundary:
  `input wire pkg::T`, `output wire pkg::T`, `input var`, `output var`,
  **INOUT** (plain and `wire`), **NON-ANSI** ports (the only style in which a
  MODULE-LOCAL typedef can type a port), and an **interface port** as a control.
* **`g3_body77.sv`** — the negative control: BODY declarations in every keyword
  form, plus an interface and a program.

**Golden, elaborated, `g1` (one row per shape; both directions identical unless
noted):**

| written type | golden | pristine | patched |
|---|---|---|---|
| implicit / `logic` / `logic [7:0]` / `wire` / `wire [7:0]` / `reg [7:0]` | net | net | net |
| `var logic [7:0]` | **logic_var** | logic_var | logic_var |
| **`p77::v8_t`** (packed vector) | **logic_var** | IN **net** / OUT var | **logic_var** |
| **`p77::pw_t`** (parameterised width) | **logic_var** | IN **net** / OUT var | **logic_var** |
| **`p77::m_t`** (multi-dim packed) | **logic_var** | IN **net** / OUT var | **logic_var** |
| **`p77::s1_t`** (scalar `logic` typedef) | **logic_var** | IN **net** / OUT var | **logic_var** |
| `var p77::v8_t` | logic_var | logic_var | logic_var |
| `p77::b8_t` (2-state) | bit_var | bit_var | bit_var |
| `p77::e_t` (enum) | enum_var | enum_var | enum_var |
| `p77::st_t` (packed struct) | struct_net | struct_net | struct_net |
| `v8_t` imported bare / `u8_t` `$unit` | net | net | net |
| `p77::v8_t [1:0]` (packed dims on a scoped typedef) | packed_array_var | net | net (**R2**) |

**`g2`, the direction / keyword boundary — golden makes EVERY scoped-typedef
port a variable:**

| port | golden | pristine | patched |
|---|---|---|---|
| `input  q77::v8_t` | logic_var | **net** | **logic_var** |
| `output q77::v8_t` | logic_var | logic_var | logic_var |
| `input  wire q77::v8_t` | logic_var | **net** | **logic_var** |
| `output wire q77::v8_t` | logic_var | **net** | **logic_var** |
| `inout  q77::v8_t` | logic_var | **net** | **logic_var** |
| `inout  wire q77::v8_t` | logic_var | **net** | **logic_var** |
| `input`/`output var q77::v8_t` | logic_var | logic_var | logic_var |
| NON-ANSI `input`/`output q77::v8_t` | logic_var | logic_var | logic_var |
| NON-ANSI imported / module-local typedef | net | net | net |
| `inout logic [7:0]` / `inout wire [7:0]` | net | net | net |
| interface port `if77.mp` | (no signal) | (no signal) | (no signal) |

**Scores — both censuses, BOTH views, judge-visible fields:**

| arm | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG |
|---|---:|---:|---:|---:|
| `g1_portkind77.sv` | **20** | **0** | **0** | 12 (R2 ×10, R3 ×2) |
| `g2_portkw77.sv` | **6** | **0** | **0** | **0** |
| `g3_body77.sv` | **1** (the one PORT) | **0** | **0** | 1 (R1) |
| `r10earl43repro/a1_earl43.sv` | **1** | **0** | **0** | 0 |
| `r10earl44repro/a1_earl44.sv` | **1** | **0** | **0** | 0 |

`score77.py` keys on the CELL IDENTITY and carries the object kind AND the
port's `Low_conn` in the PAYLOAD. **A payload field left in the KEY manufactures
phantoms** (RESUME §9): with `LOWCONN` in the key this same grid read 20
TO-GOLDEN *plus* 20 NOGOLD-MOVED and 8 MOVED-WRONG that do not exist. Both
censuses are DEDUPED, because the `--elabuhdm` view lists a def cell and an
elab cell at the same key on BOTH binaries (earl75's R3).

---

## 6. Result

| | before | after |
|---|---|---|
| Earlgrey_0_1 / default | 11664 cmp lines, 1 head | **90 cmp lines, 1 head** |
| Earlgrey_0_1 / testflags | 11404 cmp lines, 1 head | **90 cmp lines, 1 head** |

The two after-logs are identical apart from 16 id-only lines, so there is ONE
R0, not two (`PREDICT_R0.txt`).

**Earlgrey census after the patch** (`sig77`, deduped, both modes):

| mode | keys | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG | NOGOLD-MOVED |
|---|---:|---:|---:|---:|---:|---:|
| default | 40,762 | **1** | **0** | **0** | 3 | **0** |
| testflags | 40,764 | **1** | **0** | **0** | 3 | **0** |

The one is `work@top_earlgrey.u_spi_device.u_fwmode / tx_data_i`; the three are
the pre-existing R2/R3 cells. The port census confirms the `Low_conn` moved
with it (`ref_obj -> logic_var`, golden's exact shape). **Nothing else in
either database moved.**

---

## 7. Gates

All green — `GATES.txt` carries every number. In one line: both binaries built
`-j 2` and frozen `chmod 555` before any sweep, and **every one of the 1573 +
1462 `cmds.txt` files per sweep audited by binary PATH — 0 name the main-tree
binary**; goldens 23/0 on BOTH binaries and 0/23 on `/bin/false`; uhdm2rtlil
**679/50/2 in both modes with 0 differing rows** against the committed baseline
AND against my own pristine sweep; surelog **0 differing rows over 1588** with
identical status histograms in both modes — **no row converted and
`results/*.csv` not edited**; byte movers **0/1358** and **3/956**, two of them
the PREDICTED Earlgrey databases and the third the documented Scoreboard/default
coin (170 raw dump lines, **0 order-blind**); 52 + 8 canary rows unchanged, both
supplementary canary suites PASS, `canaudit` audited=29 UNCOVERED=0
FENCE-BREACH=0; all five protected databases byte-identical with
`SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on their pins; and every
other named row's head is unchanged.

Movers were **PREDICTED BY NAME from the PRISTINE databases first**
(`PREDICT_MOVERS.txt`): a source scan flagged 30 tests, a pristine-database scan
73 rows, the arm's own precondition refuted 65 of them, and the def-vs-elab view
refuted 7 of the remaining 8 — leaving exactly the two Earlgrey databases, and
exactly those two moved.

---

## 8. Boundary

`vwide77.sh` / `vdir77.sh` (earl76's walkers, unchanged in mechanism) walk a
COPY of `tools/probe` with **no path filter**, `.sv` and `.v`, at ANY depth,
both views, both frozen binaries, workdir-normalised dump byte-compare; the
file list is read on fd 3 with children `</dev/null`, `PROCESSED` is asserted
and every cell records its `rc`. **The four slang-fenced tests are never
dispatched** — the list is filtered by the names read out of `canaudit.sh` (the
only file here that may spell them), and 0 files matched.

See `BOUNDARY_WIDE.*`, `BOUNDARY_DIR.*` and `ARMS.txt` for the tallies and the
adjudication of every differing arm.

---

## 9. Residues, ranked (R0 first)

**R0 — THE NEW EARLGREY HEAD, both modes, 1 head each, 90 cmp lines. A
REPLICATION that golden FOLDS and we do not**, in a gen-scope module-body
`cont_assign`:

```
prim_ram_2p_async_adv.sv:171   assign a_wmask_d = {TotalWidth{1'b1}};
in work@top_earlgrey.u_spi_device.u_memory_2p.i_prim_ram_2p_async_adv.gen_secded

golden   constant (LOC-LESS) |vpiDecompile:111…1 (39 ones) |vpiSize:39
                             |BIN:111…1 |vpiConstType:3
                             |vpiTypespec -> ref_typespec -> int_typespec
ours     operation 171:24-171:42 |vpiOpType:34 (vpiMultiConcatOp)
                             |vpiOperand -> constant UINT:39 sz 32  (TotalWidth,
                                            already folded correctly)
                             |vpiOperand -> operation opType 33 -> 1'b1
```

`BaseClass::Compare` tests VpiType first and names both sides, so the failing
field is the object KIND: this is an UNDER-fold, and the fix must perform a
fold, not adjust an encoding. It is the family earl68's
`§ genvarWholeCaRhsFold68` and earl72's R1 measured, and the campaign's standing
`ReplicationPassedToInstance` blocker. `PREDICT_R0.txt` carries the full decode
and the measuring instructions.

**R1 — the INTERFACE-PORT twin of this law. 0 corpus cells.** `g3_body77.sv`:
golden makes `input r77::v8_t if_in` on an INTERFACE a `logic_var`, and both
binaries leave it a `logic_net`; the OUTPUT twin `if_out` and all three
interface BODY forms already match. Interface signals are emitted from a
different site (`ModuleEmit.cpp` ~27350) which calls `makeVar` with
`portBacked=false`, so this law's `portBacked && pkgAliasPort` disjunct does not
reach them. The Earlgrey census has **zero** interface cells of this shape, and
the interface family is the campaign's largest DIFF cluster — widening the law
into it without a measured interface grid would be a blind change, so it is
recorded, not taken.

**R2 — PACKED DIMENSIONS WRITTEN ON A SCOPED TYPEDEF. 1 Earlgrey cell,
PRE-EXISTING, both directions.** `input p77::v8_t [1:0] x` is a
`packed_array_var` carrying a `logic_typespec` named `p77::v8_t` in golden, and
a bare anonymous `logic_net` on our side — in BOTH directions, on BOTH binaries.
Earlgrey's cell is `u_flash_ctrl.u_flash_mp / region_cfgs_i` (golden
`packed_array_var`, ours `packed_array_net`). This law does not reach it: the
declared type is a `PackedArrayType`, not a `TypeAlias`, so `pkgAliasPort` is
false. It is both a KIND and a TYPESPEC divergence and wants its own pass.

**R3 — an ALL-LOGIC packed-struct port that golden keeps a `struct_net` and we
make a `struct_var`. 2 Earlgrey cells, PRE-EXISTING.**
`u_hmac.u_sha2.u_pad / fifo_rdata` and
`u_usbdev.i_usbdev_iomux / sys_reg2hw_config_i`. Reproduced on the grid:
`g1_portkind77.sv`'s `i_impstruct`/`o_impstruct` in the **UNDRIVEN** instance
`u_c3` diverge exactly this way while the same ports in the two DRIVEN
instances agree — so the discriminator involves whether the signal is driven,
which `makeVar`'s struct arm does not model. Untouched here.

**R4 — our port objects carry an EMPTY `VpiFile`.** Pre-existing and
COMPARE-INVISIBLE (no generated `Compare` reads `VpiFile`); recorded because it
is why `cen77`'s key drops the LOC field.

---

## 10. Reproducing

```bash
g++ -O2 -std=c++17 cen77.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o cen77          # and sig77.cpp
python3 gen77.py                                          # regenerates g1
CEN77=./cen77 SIG77=./sig77 PRIS=<pristine> PATCHED=<patched> \
  bash arm77.sh g1_portkind77.sv <outdir>
python3 score77.py    <outdir>/g.cen <outdir>/o.cen <outdir>/q.cen
python3 sigscore77.py <outdir>/g.sig <outdir>/o.sig <outdir>/q.sig
python3 goldtbl77.py  <outdir>
CEN77=./cen77 bash predict77.sh <pristine-workdir> …       # mover prediction
bash fencescan77.sh ~/git-repos/Surelog/tests \
     ~/git-repos/Surelog/third_party/tests ~/git-repos/uhdm2rtlil/test
```
