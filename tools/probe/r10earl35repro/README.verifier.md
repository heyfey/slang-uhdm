# r10earl35 — ADVERSARIAL VERIFIER RECORD

## VERDICT: **PASS**

The law is right, the code change is right, and **every gate number and every
corpus number in the implementer's report reproduces exactly** on binaries I
built myself — down to the `diff` line number of the single moved dump line
(`364742d364741`) and both md5s.

Nine findings follow. **None of them is a defect in the patch.** Eight are
defects in the *write-up* or in its *instruments*; one (F3/F4) is a coverage gap
I closed myself, and closing it strengthened the patch's case rather than
weakening it. There are **zero regressions** anywhere I could measure, including
in the five call sites the delivered grid never reached.

The single most important thing in this document: **the shipped `netcen.py` is
still broken** (F1), refutation F5's "found and fixed before any number was
quoted" is false, and one of its consequences is that the pass is *underclaiming*
— a1 fixes **10** cells, not 9.

---

## 0. WHAT I DID

Fresh worktrees at BASE `957974d` (`git rev-parse HEAD` printed and
`grep -qF`-checked on both), `cmake -B build -DCMAKE_BUILD_TYPE=Release
-DCMAKE_PREFIX_PATH=$HOME/.local`, `--build build -j 4`, waited for the link line.

| | path | md5 | claimed | BASE grep-check |
|---|---|---|---|---|
| PATCHED | `.claude/worktrees/r10earl35v/build/slang-uhdm` | `c6869767f794169b56339699c164fde1` | **same** | OK |
| PRISTINE | `.claude/worktrees/r10earl35vpris/build/slang-uhdm` | `8a7c07f418d3a567de0b24c6a5e90fe3` | **same** | OK |

Both 32-hex-asserted in a step separate from the build; `grep -c 'error:'` = 0 in
both logs; `[100%] Linking CXX executable slang-uhdm` → `[100%] Built target
slang_uhdm` present in both. Byte-for-byte md5 agreement with the implementer's
independently-built binaries is itself a strong result: the patch is
reproducible, not environment-dependent.

Four sweeps, `--mode both --jobs 2`, own `--out` / `--workdir`, `GOLDEN_DEFER`
unset. Patch applied to a fresh 957974d worktree (`git apply --check` clean,
verbose, untruncated).

---

## 1. THE FIVE GATES, INDEPENDENTLY

**GATE 1 — BUILD. GREEN.** Above.

**GATE 2 — GOLDENS. GREEN.**
```
SLANG_UHDM=<patched> ./tests/check_goldens.sh   -> PASS=23 FAIL=0
SLANG_UHDM=/bin/false ./tests/check_goldens.sh  -> PASS=0  FAIL=23  (rc=1)
```

**GATE 3 — uhdm2rtlil. GREEN, exact.**
```
[default]   CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2
[testflags] CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2
testflags dump histogram: 496 match / 183 differ / 52 blank      == claimed
default   dump histogram: 492 match / 187 differ / 52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv <fresh testflags projection>
  -> 0 differing ROWS (0 diff row-sides)   both binaries
```
I also independently verified the projection is *not* a weakened gate:
`awk -F, 'NR>1&&$2!="testflags"' results/gate_uhdm2rtlil.csv | wc -l` = **0**, so
the committed baseline really is testflags-only and 731-against-731 is the
committed gate. Patched and pristine u2r CSVs are **byte-identical**, which is
precisely why gate 5 has to exist.

**GATE 4 — surelog, both modes. GREEN on every stated number; one row of
golden-side flake, characterised in F6.**
```
[default]   CMP_EQUAL 467  CMP_NOTEQUAL 13  SLANG_REJECT 284  SURELOG_FAIL 25  DEFERRED 5
[testflags] CMP_EQUAL 463  CMP_NOTEQUAL 10  SLANG_REJECT 286  SURELOG_FAIL 23  DEFERRED 5
dump histograms base == fresh, BOTH modes:
  default   327 blank / 242 differ / 225 match
  testflags 331 blank / 298 differ / 165 match
ct8rows: 2 differing rows (patched sweep), 1 (pristine sweep) -- see F6
Earlgrey_0_1 BY NAME: base default/CMP_NOTEQUAL testflags/SLANG_REJECT == fresh
```

**GATE 5 — BYTE VERIFIER, both corpora both modes, vs the PRISTINE 957974d I
built. GREEN, exact.**
```
u2r     PATH_SETS_IDENTICAL (1358)  MOVERS 0/1358
        SELFCHECK 1357/1358         SELFCHECK1 1
surelog PATH_SETS_IDENTICAL (953)
        MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm
        MOVERS 1/953                SELFCHECK 952/953   SELFCHECK1 2
```
I checked the thing that would have made `SELFCHECK1 2` meaningless: byteverify
corrupts `find . -name slang.uhdm | sort | head -1`, which here is
`./default/1364_2005-89a962f1/slang.uhdm` — **not** the mover. So `2` really does
decompose as 1 corrupted + 1 real mover, as claimed.

### CANARIES — all exact
| check | measured | claimed |
|---|---|---|
| `canaries.sh` vs `golden_surelog.csv` | ok=52 changed=0 absent=0 unknown-names=7 | same |
| `canaries.sh` vs `gate_uhdm2rtlil.csv` | ok=8 changed=0 absent=0 unknown-names=25 | same |
| `ctcan2.sh EXPECT_UNKNOWN=1` (surelog, baseline FIRST) | **PASS** ok=58/0/0, unknown-patterns=1 | same |
| `ctcan2.sh EXPECT_UNKNOWN=6` (u2r, baseline FIRST) | **PASS** ok=1/0/0, unknown-patterns=6 | same |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 | same |
| `InterfaceModPort`, `BlackParrotComplex` BY NAME | `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ`, base==fresh | same |

`InterfaceModPort` and `BlackParrotComplex` genuinely carry **no u2r row** — I
confirmed the empty result rather than reading it as green, which is why they are
checked against the surelog CSV.

---

## 2. THE MOVER FENCE AND THE TARGET — REPRODUCED VERBATIM

```
diff <pristine Earlgrey default dump> <patched>   (both sed 1d)
364742d364741
<     |vpiNetType:1
REMOVED 1   ADDED 0   REMOVED-not-|vpiNetType: 0
o lines 4654895   p lines 4654894
```
The **same line number** the README quotes. The removed line sits on
`logic_net: (work@flash_mp.region_cfgs_i), line:21:87, endln:21:100` (read from
the raw dump, lines 364725–364745).

`msdist.sh` (committed copy, absolute path), vs golden:

| | golden-only | ours-only | MULTISET DISTANCE |
|---|---|---|---|
| pristine | 238946 | 70393 | 309339 |
| patched | 238946 | **70392** | **309338** |

ADDED and REMOVED separately: golden-only unchanged, ours-only −1. **A fix, not a
trade.** `pred35.sh` re-run on my own pristine dump reproduces the prediction
(mover superset = 13593 nets printing a vpiNetType; ADDED 0; census 1→0), and
every predicted quantity is met.

### the head, before and after
```
PRISTINE  30 lines  LHS/RHS logic_net (work@flash_mp.region_cfgs_i) id:927889
          sole difference:  RHS |vpiNetType:1   (LHS absent)
          vpiParent module_inst prints IDENTICALLY on both sides
PATCHED   42 lines  LHS constant id:927782 line:22:67 |UINT:2 |vpiConstType:9
                    RHS ref_obj (NumBanks) id:726174 line:22:67
```
**CLEARED and ADVANCED**, exactly as claimed, and R1 is verbatim what the README
describes.

### the brief's three claims, all REFUTED — independently confirmed
* **"the earl34 R2 residue is the named suspect"** — no. The 30-line log contains
  no hier_path, no index constant, no ref_typespec, and `vpiParent` is identical
  on both sides. § hpMixedIdxPkgFold34's `aggregateAbstain34` and element-select
  index text are untouched by this patch. **No boundary collision.**
* **"surfaces through VECTORS, not fields"** — no. One scalar `int`,
  `nets::VpiNetType`, ahead of every vector in the `Compare` order.
* **"region_cfgs_i is an unpacked array"** — no. From the corpus source,
  `flash_mp.sv:21`: `input flash_ctrl_reg_pkg::..._mp_region_cfg_mreg_t
  [TotalRegions-1:0] region_cfgs_i` — the dimension precedes the identifier, so
  it is **PACKED**, and golden emits a `logic_net`.

### the separating pair, verified from GOLDEN'S OWN DUMP and from the source
```
g.dump:366724  logic_net (work@flash_mp.region_cfgs_i)  -- NO vpiNetType
g.dump:366730  logic_net (work@flash_mp.bank_cfgs_i)    -- |vpiNetType:1
```
and `flash_ctrl_reg_pkg.sv`: `..._mp_region_cfg_mreg_t`'s members are all
anonymous `struct packed {...}` (**nested**); `..._mp_bank_cfg_mreg_t` is a single
`logic q` (**flat**). Adjacent source lines, same shape, opposite golden answers.
The load-bearing row of the grid is real, and **flatness alone** explains it:
`x_flat_lp` (FLAT + localparam bound) is tagged in golden and `x_nest_p` (NEST +
parameter bound) is not, so the **dimension-source candidate is refuted outright**,
as claimed.

---

## 3. STATED GATE == CODE GATE — I audited it, and it holds

I read all **7** `hasStructFieldMember` call sites (`ModuleEmit.cpp` 876, 7556,
22176, 22234, 23097, 23172, 23653). Every one is spelled
`... && !hasStructFieldMember(sym)` and every one is the **terminal** arm of its
`else if` chain, guarding exactly one `VpiNetType(vpiWire)`. This last point is
the one the report does not make and that the argument needs: a monotone increase
that switched off a *non-terminal* arm would let a **later** branch fire, which is
an ADD, not a removal. It cannot happen here.

`declPackedStructLeaf35` is monotone: when the declared canonical type is already
a struct the `while` never runs and `c` is that same type, so `new ⊇ old`. The
loop terminates (array element types strictly decrease). The def-view atom lambda
is the same shape.

The only *read* of the field anywhere is `ModuleEmit.cpp:17595`,
`((logic_net*)lnet)->VpiNetType(mnet->VpiNetType())` — a pure propagation, so it
can only propagate the removal. **"The patch can remove `|vpiNetType:` lines and
can do nothing else" is CODE-TRUE**, and the observed 1-removed/0-added fence is
its consequence rather than a coincidence.

---

## 4. PATCH HYGIENE, earl34, LIVE PASSES

* `git apply --stat`: `src/ModuleEmit.cpp` (35+/12−) plus
  `tools/probe/r10earl35repro/{README.md,a1_flat.sv,a2_wire.sv,arm35.sh,netcen.py,pred35.sh}`.
  **Nothing else** — no `results/*.csv`, no config, no stray files. Applies clean
  to a fresh 957974d.
* **earl34 arms: all 8 hold.** `a1_idxkind a2_shape a3_escaped v1_view v2_kinds
  v3_cat v4_paren v5_init` — every one identical patched vs pristine on cmp head
  depth, dump-diff content and hunk count; and after normalising the workdir path
  out of the dumps (my first comparison called all 8 "MOVED" purely because the
  dump embeds its own absolute source path — my error, stated plainly), the
  `o.dump` **and** `cmp.log` of all 8 are **byte-identical**, `v5_init`
  concat-abstain included.
* **Live passes: NO COLLISION.** `r10uvm64` touches `include/UhdmExporter.h` +
  `src/ExprEmit.cpp` — disjoint files. `r10svs11` touches `src/ModuleEmit.cpp` at
  ~1100–1170; this patch touches ~298–340 and ~875–895. Both orders
  (`earl35` then `svs11`, and `svs11` then `earl35`) `git apply --check` clean;
  `r10uvm64` applies clean on top of both.

---

## 5. FINDINGS

### F1 — MEDIUM. `netcen.py` IS STILL BROKEN, and refutation F5 is false.

Refutation F5 says the census instrument's defect was "found and fixed before any
number was quoted". A **second, different** defect survives in the shipped file.

`netcen.py` tracks only the most recent `*_net:` header in `cur`. A net that has a
`vpiTypespec` prints, *inside* that typespec, a `ref_typespec` whose `vpiParent`
is a **back-reference to the net itself** — a `*_net:` header at a deeper indent.
That header overwrites `cur`. The net's own `|vpiNetType:` line comes **after** the
typespec block at the shallower indent, so the `len(indent) == cur[0]+2` guard
rejects it and **the net type is silently lost**. Raw evidence, golden a1 dump:

```
1333   \_logic_net: (work@e35_dut.l_flat), line:86:25, endln:86:31   <- indent 2
1337     \_ref_typespec: (work@e35_dut.l_flat)                        <- indent 4
1339       \_logic_net: (work@e35_dut.l_flat), ...                    <- HIJACKS cur
1345     |vpiNetType:1                                                <- indent 4, LOST
```

I wrote `vcen35.py` (in this directory) from the dump grammar instead: it keeps a
full indent **stack** of every object header, so a field at indent *I* is
attributed to the innermost object at indent *I*−2. Command:
`diff <(sort a1_gold.netcen) <(sort a1_gold.vcen)` → **11 of 78 golden keys wrong**.

Consequences — all in the write-up, none in the code:

* **F1a. a1's FIXED count is 10, not 9.** `l_nest` (`e35_pkg::nest_t [3:0]
  l_nest;`, a body net) is tabled as "ok / same / same". Measured correctly:
  GOLDEN `-`x3, **PRISTINE `-`x2/`1`x1**, PATCHED `-`x3 → a real **FIX** the pass
  does not claim credit for. The pass is *underclaiming*.
* **F1b. a2's `bw_nest` is not "ok" — it is STILL WRONG.** GOLDEN `-`x4,
  PRISTINE and PATCHED `-`x3/`1`x1. It is an instance of residue R2, not a
  passing control. This matters for F2.
* **F1c.** several GOLDEN column values in § 3a are understated (`l_flat`'s
  golden is `-`x2/`1`x1, not `-`x3).

**What is NOT affected:** the corpus census and every gate number. The target net
has no def-view typespec, so no back-reference precedes its `|vpiNetType:` line
and `netcen.py` reads it correctly. Recomputed with `vcen35.py` on all three
Earlgrey dumps, keyed `(kind, name, span)` on both sides:

```
net KEYS: golden 27238  pristine 27239  patched 27239
NET-TYPE-VALUE disagreements vs golden:  PRISTINE 1  ->  PATCHED 0
  the 1 = logic_net work@flash_mp.region_cfgs_i  golden=(none) ours=('1',)
```
**The headline 1 → 0 is correct.** (On a raw *multiset* key the numbers are 583 →
582, but that measure is dominated by how many times an object is re-printed as a
back-reference and is not a net-type statement; restricted to actual net-type
buckets it is 1 → 0.)

**Fix `netcen.py`, or delete it in favour of `vcen35.py`, before its numbers are
quoted again.**

### F2 — MEDIUM. R2's stated reason for "corpus population ZERO" is wrong for 2 of the 6 sites; the conclusion survives on a stronger fact.

R2 argues population zero because "all 6 corpus occurrences are body `wire pkg::t
x;` declarations ... and a2's `bw_nest`/`bw_flat` show golden gives those **no**
tag and **we already match**." Two problems:

1. Per F1b, **we do not match `bw_nest`.** The "we already match" half is false
   for non-flat types.
2. Two of the six types are **not flat**: `tlul_pkg::tl_h2d_t` has member
   `tl_a_user_t a_user` (a nested struct) *and* an enum `tl_a_op_e a_opcode`;
   `tl_d2h_t` has enum `tl_d_op_e d_opcode`. The other four
   (`prim_pkg::{alert_tx_t,alert_rx_t,esc_tx_t,esc_rx_t}`) are all-`logic`, i.e.
   flat, and those four do match.

The **conclusion is nevertheless correct**, by a fact I established that the
README does not use: **none of the six files is compiled by any corpus test.**
```
grep -rl 'tl_if\|tl_agent'      --include='*.sl' --include='*.f' --include='*.scr' tests third_party/tests  -> (empty)
grep -rl 'alert_esc_if\|alert_esc_agent' --include='*.sl' ... -> (empty)
grep -c 'tl_if.sv' <Earlgrey golden dump> <ours>                -> 0  0
```

**A refutation of my own, stated plainly:** my first run of the README's cited
grep returned **0 matches**, and I was one step from reporting the citation as
unreproducible. `grep` here is a shell **function** wrapping `ugrep`; it does not
exist in a non-interactive bash, and my `2>/dev/null` swallowed
`ugrep: command not found`. Run through the function, the cited command returns
**exactly 6**, as stated. The citation is sound; my instrument was not.

### F3 — MEDIUM. THE EMPTY PRODUCT CELL: 5 of the 7 patched call sites had ZERO grid coverage. I filled it, and the patch passes.

`a1_flat.sv` and `a2_wire.sv` are both plain modules, so between them they reach
**two** of the seven sites (def-view module net, elab-view module net). The other
**five are INTERFACE sites** — 22176 (iface def-view body signal), 22234 (iface
def-view unpacked array inner net), 23097 (iface elab struct_net), 23172 (iface
elab unpacked array_net inner net), 23653 (modport io_decl member). The README's
"incoherent at **every** one of the 7 ... it is now coherent at **all 7**, and
§ 5's gates measure that" is **not measured by any arm**; the gates only show
that nothing regressed.

I built **`v1_iface.sv`** (in this directory): one interface crossing flatness
(flat / nested / integer-member / enum-member) against dimension carrier (none /
packed / unpacked), with a modport and a consuming module, so all five sites are
reached. Result — **the claim is now actually true**:

```
patched vs pristine, whole arm dump, path-normalised:
969d968
<     |vpiNetType:1
```
one line, and it is a **genuine FIX** at an interface site:
`logic_net (work@e35c_if.p_nest)` (iface def-view, ModuleEmit.cpp:22176) —
GOLDEN `-`x2, PRISTINE `-`x1/`1`x1, PATCHED `-`x2. Across **41 interface net
keys: 1 FIXED, 0 REGRESSIONS.** The monotonicity argument holds empirically at
the interface sites too.

The gap was real; closing it strengthened the patch.

### F4 — MEDIUM. A residue the README does not name: the ATOM/ENUM exception exists at ONE site out of seven.

The integer / enum / 2-state exception lives **only** in the def-view module
site's inline lambda. All five interface sites call `hasStructFieldMember` alone,
so from `v1_iface.sv`:

| cell | shape | GOLDEN | PRISTINE | PATCHED |
|---|---|---|---|---|
| `p_atom` | `pkg::atom_t [3:0]` iface signal | `-`x2 | `-`x1/`1`x1 | `-`x1/`1`x1 |
| `p_enum` | `pkg::enumm_t [3:0]` iface signal | `-`x2 | `-`x1/`1`x1 | `-`x1/`1`x1 |
| `i_atom` | `pkg::atom_t` iface signal, **NO dim** | `-`x2 | `-`x1/`1`x1 | `-`x1/`1`x1 |

`i_atom` has **no dimension at all** and is wrong in PRISTINE, so this is
**pre-existing and dimension-independent** — not caused by this pass and not a
missed descent. It is distinct from R2 (net keyword) and R3 (unpacked carrier),
and it is the natural companion fix: hoist the lambda into a named predicate and
pair it at all seven sites — **exactly the "one predicate, N call sites" shape
this pass just executed.** The cells exist now.

### F5 — MEDIUM. R3 should be upgraded: the unpacked carrier is no longer "unmeasured", it is measured and wrong.

R3 says "nothing here is measured — build the cells first". `v1_iface.sv` builds
them. `pkg::nest_t u_nest [0:3]` and `pkg::atom_t u_atom [0:3]`: GOLDEN `-`x2,
**both binaries** `-`x1/`1`x1. Unchanged by the patch (correctly — it descends
`PackedArrayType` only). Re-rank R3 from *unmeasured* to **measured, real,
unfixed**.

### F6 — LOW. GATE 4's "ct8rows 0 rows" did not reproduce; it is a load-dependent GOLDEN-side flake, not a patch effect.

```
patched sweep : 2 differing ROWS   CoresSweRV,default,SURELOG_FAIL
                                   CoresSweRVMP,default,SURELOG_FAIL
pristine sweep: 1 differing ROW    CoresSweRV,default,SURELOG_FAIL
baseline detail: "[   NOTE] : 1"
fresh    detail: "[ERR:PA0203] .../dbg.sv:592: Unknown macro \"RV_PIC_REGION\"."
```
Attribution, not assumption: (a) the rows are `SURELOG_FAIL`, where slang-uhdm
never runs and the detail column is Surelog's own output; (b) the flake is
**asymmetric between my two binaries** — `CoresSweRV` flaked in both,
`CoresSweRVMP` in only one — which is the signature of load, not of a code
change; (c) three light-load repeats of `--filter CoresSweRV` return the
baseline's `[   NOTE] : 1` for **both** tests **every** time. Statuses and both
dump histograms are unchanged, and `SURELOG_FAIL` counts are at baseline (25 /
23). Mechanism: `GOLDEN_CACHE_FAILURES` defaults off, so failure rows re-run
Surelog on every sweep and its error reporting truncates under concurrency.
**Not attributable to the patch** — but the gate as stated is not flake-free, and
a future pass should compare only the status column on `SURELOG_FAIL` rows or
cache their details.

### F7 — LOW. The Scoreboard MULTI-STABLE claim is a lucky draw presented as determinism.

"The documented `Scoreboard/default` MULTI-STABLE flake did NOT fire this run ...
`patched=9cf807ea56e4 pristine=9cf807ea56e4`, size 11133449 both — byte-identical
across the two binaries." My 3-rep × 2-binary run:

```
rep1 p 0163f3d48653 / o 0735c667b15d      all six: size 11133449
rep2 p 1ba839e9c608 / o 1ba839e9c608
rep3 p 0735c667b15d / o 1ba839e9c608
```
The md5 varies **within the same binary** across reps, drawn from
{`0163f3d48653`, `0735c667b15d`, `1ba839e9c608`} — and note my values are not the
implementer's, at identical size. The statement that licenses "not a mover" is
*multi-stable with constant size and a binary-independent md5 set*, not
byte-identity. **Conclusion unchanged**, reasoning overstated. (This is also why
their run and mine agree on the mover count: within one run-pair the draws
happened to coincide.)

### F8 — COSMETIC. § 3b's header says "a2_wire.sv, 9" cells. The file and my census both have **10** def-view cells (`bw_nest`/`bw_flat` are one table row, two cells). a1's "26" is exact — I count 26.

### F9 — COSMETIC. "no new predicate" is true in spirit (no new boolean gate) but the patch does add a new file-scope helper. And § 5's "net keys 27239 / 27239" is the OURS-side count; golden is **27238** by my census.

---

## 6. RANKED RESIDUES

1. **R1′ (= their R1). A module PARAMETER is not folded inside a packed RANGE
   BOUND.** The new head: golden `constant` `|UINT:2` `|vpiConstType:9`, ours
   `ref_obj (NumBanks)`, both at `flash_mp.sv:22:67`, 42 cmp lines. Confirmed
   verbatim. A value fold on the range-bound axis, distinct from earl33's
   generate call-arg folds and from earl34's name-axis select-index text.
   **Highest value: it is the next head on this design.**
2. **R2′ (= F4, new). The ATOM/ENUM flatness exception is missing at all five
   interface sites.** Cells already built: `v1_iface.sv` `p_atom`, `p_enum`,
   `i_atom`. Pre-existing, dimension-independent. Cheapest real fix and the same
   shape as this pass.
3. **R3′ (= their R3, upgraded by F5). The UNPACKED carrier is measured and
   wrong.** Cells: `v1_iface.sv` `u_nest`, `u_atom`.
4. **R4′ (= their R2). `netTypeFor`'s explicit-net-keyword branch bypasses the
   flatness exceptions.** Pre-existing and dimension-independent (a2 `w_nest`,
   no dim). Compiled-corpus population **0**, but for the reason in F2, not the
   one stated. Cells: a1 `w_nest`; a2 `w_nest`, `w_nest_d`, `w_atom_d`, and —
   per F1b — `bw_nest`.
5. **R5′ (= their R4). Net POPULATION / object-existence differences** for
   non-flat packed-array-of-pkg-struct. Corpus: ours-only `packed_array_net
   ...u_flash_mp.region_cfgs_i`. `v1_iface` adds golden-only `packed_array_net
   p_flat` and ours-only `struct_net u_atom` / `i_atom`. An order of magnitude
   more dump bytes than the net-type field, and why every arm still `CMP_FAIL`s.
6. **R6′ (= their R5). Catalogued one-sided corpus net keys**, unrelated to net
   type. My census finds **3 ours-only** (`u_spi_device.u_fwmode.tx_data_i`,
   `packed_array_net ...u_flash_mp.region_cfgs_i`,
   `struct_net ...region_cfgs_i.region_cfgs_i`) and **2 golden-only**
   (`u_hmac.u_sha2.u_pad.fifo_rdata`, `i_usbdev_iomux.sys_reg2hw_config_i`).
   Confirmed.
7. **R7′ (= F1). Repair or retire `netcen.py`.** `vcen35.py` is in this directory.
8. **R8′ (= F6). The `CoresSweRV*` `SURELOG_FAIL`-detail flake** in the committed
   surelog baseline.

---

## 7. FILES I ADDED HERE

| file | what it is |
|---|---|
| `vcen35.py` | the verifier's **independent** net-type census: a full indent STACK, so a field is attributed to the object that actually encloses it. Written from the dump grammar, not from `netcen.py`, so agreement is evidence rather than tautology — and it is what exposed F1. |
| `v1_iface.sv` | **the empty product cell**: the interface arm reaching the five call sites a1/a2 never touched, crossing flatness against none/packed/unpacked dimension carriers, with a modport. Filled the gap and found F3/F4/F5. |
| `README.verifier.md` | this document. |

Sweep workdirs deleted.
