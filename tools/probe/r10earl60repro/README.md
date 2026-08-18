# r10earl60 — § pkgScopedParamRhsTs60

**The Earlgrey_0_1/default head is cleared (9 743 cmp lines → 29), the
Earlgrey_0_1/testflags head is cleared TOO (33 → 30) as a consequence of the
same law, and the pass is FIRST a REFUTATION: the brief's target — "golden
stamps 15 402 elaborated typespecs with `vpiInstance` and we stamp 13 660,
1 742 MISSING over 33 packages" — IS AN ARTEFACT OF COUNTING THE
`weaklyReferenced` TAIL, which `design::Compare` provably cannot reach. In the
part of the database the comparator actually walks, our `vpiInstance` edge set
was ALREADY equal to golden's before this pass.**

Head: **Earlgrey_0_1/default 9 743 cmp lines → 29, 1 head → 1 head.**
**Earlgrey_0_1/testflags 33 → 30, 1 head → 1 head, and its cell is GONE:**
the `|vpiActual:` count on `…u_dm_top.i_dm_mem.DbgAddressBits` is **golden 27,
pristine 28, patched 27**.

3-way keyed census, Earlgrey_0_1, **both modes**, 15 403 / 15 407 keys:

```
TO-GOLDEN = 14      AWAY-GOLDEN = 0      STILL-WRONG = 0
UNMOVED-GOOD = 10 726 (default) / 9 424 (testflags)
```

Whole-design blast radius, path-normalised, pristine vs patched:
**105 lines / 28 hunks (default), 107 / 29 (testflags)** — and the histogram IS
the law: 14 typespec targets removed, 14 `|vpiInstance:` added, and the
packages they name.

---

## 1. THE REFUTATION, BEFORE ANY CODE

The brief asked for 1 742 missing `typespec::Instance()` stamps. `census60.py`
walks the whole dump as the COLUMN-INDENTED tree it is, keys every object that
carries a `|vpiInstance:` child on (section, owner kind, owner name+span, target
kind, target name), and splits the dump into the three sections the walk
produces:

| `vpiInstance` edges, Earlgrey_0_1/default | DEF (`uhdmall*`) | ELAB (`uhdmtop*`) | **TAIL (`weaklyReferenced`)** | total |
|---|---:|---:|---:|---:|
| golden | 623 | **2 407** | 13 540 | 16 570 |
| pristine | 623 | **2 407** | 11 798 | 14 828 |
| patched | 623 | **2 407** | 11 812 | 14 842 |

**All 1 742 are in the TAIL.** The ELAB edge MULTISET is not merely equal in
size, it is equal cell for cell up to ONE pair (`MISSING 1 / EXTRA 1`, the
`enum_typespec (dm::csr_reg_t)` whose span golden gives as `383:41-383:50` and
we give as `244:3-301:15` — a SPAN, which `Compare` does not read), before AND
after this pass.

The tail is not a place the comparator can look, and that is a fact about the
two tools' source, not an opinion:

* `templates/vpi_visitor.cpp:466` visits `vpiParent` with `shallowVisit = true`;
  a shallow visit prints the header line and **returns without inserting the
  object into `m_visited`**, so an object reached ONLY as somebody's parent ends
  up in `m_weaklyReferenced1` and is printed at the end under
  `\_weaklyReferenced:`. The tail is exactly "reachable only through
  `VpiParent`".
* **NO generated `<kind>::Compare` body reads `VpiParent`.** (`for f in
  build/generated/src/*.cpp; do awk '/^int32_t .*::Compare/,/^}/' $f | grep -q
  VpiParent && echo $f; done` → EMPTY.) `BaseClass::Compare` compares
  `VpiType`, `VpiName`, `VpiDefName` and nothing else.

So `-> package dm 432 vs 405` was never a defect count. **A number measured
`from |uhdmtopModules: to the end of the dump` measures the arena, not the
design.** The instrument that produced it was a text grep; the instrument that
refuted it is the same dump read as a tree, with the section boundary honoured.

## 2. THE HEAD, DECODED EXACTLY

```
LHS(golden): package: dm (dm::) id:16  dm_pkg.sv:19:1-414:16
RHS(ours)  : <null>
```

`RHS: <null>` is the two-argument scalar `SafeCompare(lhs, rhs, ctx)` with
`rhs == nullptr` (`BaseClass.h:187`): **it sets `m_failedLhs` to the POINTEE and
never names the OWNER.** `typespec::Compare` reads `VpiName`, then
`Typedef_alias`, then `Instance` — so the owner is a typespec whose
`Instance()` is `package dm` in golden and null in ours.

`tsinst60.cpp` finds that owner by MASKING: every `<kind>::Compare` opens with
`if (!context->m_visited.insert(this).second) return r;` (LHS-keyed), so seeding
a golden object into a FRESH context's `m_visited` makes its whole `Compare`
return 0. Seed the candidate pool (`218` golden typespecs whose `Instance()` IS
the head's LHS), re-run the OFFICIAL `design::Compare`, bisect. Guards: `--calib`
compares a database against itself and **must** find no head (it does); masking
the whole pool must move the head before any bisection starts; the located
object is re-verified ALONE.

```
OWNER (verified alone): logic_typespec()@dm_pkg.sv:34:14-34:26#292571
  Instance: package(dm)#16      Typedef_alias: <null>
  next head after masking it: LHS=<null> RHS=logic_net(…i_tck_inv.clk_i)@:11:16-11:21
```

**The `VpiParent` chain of that object is a TRAP and this pass says so**: it
reads `< ref_typespec@:0:0-0:0#292570 < constant@dm_mem.sv:64:64-64:68#292569`,
and BOTH of those are ORPHANS sitting in golden's `weaklyReferenced` tail. The
position `Compare` actually reaches it from is a different edge entirely, and
the dump names it:

```
work@top_earlgrey.u_dm_top.i_dm_mem                       (the ELABORATED instance)
  vpiParamAssign  param_assign 64:41-64:77
    vpiRhs  constant 64:63-64:77  (12'h380)
      vpiTypespec  ref_typespec (work@top_earlgrey.u_dm_top.i_dm_mem)
        vpiActual  golden: logic_typespec dm_pkg.sv:34:14-34:26   Instance = package dm
                   ours  : logic_typespec dm_mem.sv:64:14-64:40   Instance = NULL
```

`dm_mem.sv:64` is `localparam logic [DbgAddressBits-1:0] DataBaseAddr =
(dm::DataAddr);`. **The disagreement is not a missing stamp at all — it is the
WRONG TYPESPEC on the elaborated folded constant.** Golden points the Rhs at the
typespec of the PACKAGE PARAMETER the value came from
(`dm_pkg.sv:34 localparam logic [11:0] DataAddr`); we pointed it at the
declaring localparam's own range type. Both are `logic_typespec` with an empty
name, so `BaseClass::Compare` and the `VpiName` test walk straight past them and
the first thing that differs is `Instance()`. **The head named the symptom two
levels below the cause.**

The DEF listing (`work@dm_mem`) points at `dm_mem.sv:64:14-64:40` on BOTH sides:
this is an ELABORATION effect, and the fix must not be able to touch the DEF
view.

## 3. THE FAMILY, MEASURED ON THE DATABASES

`pacensus60.cpp` censuses every `param_assign` **on the databases, not on the
dump**. That is not a preference: `uhdm-dump` keeps a GLOBAL visited set, so an
object SHARED between two instances prints its children exactly once, and a
dump-text census reads NOTHING for every instance after the first — asymmetric
in exactly the case being asked about (one side shares, the other clones). Its
first version walked the instance tree and found 13 791 param_assigns; the
whole-dump diff then showed the patch moving 307 cells. **A census that cannot
see a cell cannot attribute it**, so it now also enumerates
`Serializer::AllObjects()` (14 950 / 13 807 param_assign objects) and the
`ALLOBJ` rows are the arbiter.

Earlgrey_0_1/default, golden vs pristine, keyed (Lhs `vpiFullName`,
param_assign span), payload (Rhs kind, actual ts kind + span, ts Instance):

| n | shape | golden | ours (pristine) |
|---:|---|---|---|
| **1** | `i_dm_mem.DataBaseAddr` — **THE HEAD** | `logic_typespec dm_pkg.sv:34:14` inst **dm** | `logic_typespec dm_mem.sv:64:14` inst NULL |
| **13** | `u_xbar_main.u_sm1_{17..20,23..31}.IDW` | `int_typespec top_pkg.sv:10:12` inst **top_pkg** | `int_typespec tlul_socket_m1.sv:72:14` inst NULL |
| 11 | flash_erase_ctrl `AddrW/PagesPerBank/WordsPerPage`, flash_mp `AllPagesW/MpRegions/NumBanks`, rstmgr_ctrl ×2 `PowerDomains`, rv_timer `N_HARTS/N_TIMERS`, usbdev `NEndpoints` | the module's OWN typespec | a WILDCARD-IMPORTED package's SAME-NAMED typespec — **residue R1** |
| 1 | `i_ast_sync.ResetValue` | `operation`, `struct_typespec` pwrmgr_pkg | `constant`, `bit_typespec` — **residue R2** |
| 2 | flash_erase_ctrl `PageAddrMask/BankAddrMask` | `operation` Rhs | `constant` Rhs — **residue R3** |
| 3 | pinmux `MioPeriphHasSleepMode`, usbdev `AVFifoWidth`, u_memory_2p `LocalDataBitsPerMask` | — | kind/span only — **residue R4** |

The two claimed families (14 cells) are the two packages in the whole design
that are **never wildcard-imported by the module that references them**:
`dm_mem.sv` and `tlul_socket_m1.sv` contain no `import` at all.

## 4. THE GRID (`v60a`…`v60d`, `arm60.sh`, `gridrows60.sh`)

The arms WRAP the module under test (`a1 → u_sub`): a module that is the TOP
gives `design::Compare` nothing to disagree about first (r10earl59's lesson) and
the corpus shape is never a top. The default-mode row runs Surelog with
`-parse` ONLY (`scripts/verify_golden.py`'s `default` branch), so the arms run
that way too; `--elab` adds the flag to both sides.

`v60a` reproduces the head EXACTLY — `LHS: package(p_noimp) RHS: <null>` — and
`tsinst60 --calib` on the same pair reports **NO HEAD**, so the detector is not
one that flags everything.

### `v60a` — reference SHAPE × declared TYPE, package NOT imported

| row | source | golden | pristine | patched |
|---|---|---|---|---|
| `g1_intU` | `localparam int unsigned = p_noimp::A8` | **pkg ts** | own ts | **pkg ts** |
| `g2_int` | `localparam int = p_noimp::A8` | **pkg ts** | own ts | **pkg ts** |
| `g3_paren` | `localparam logic[DbgBits-1:0] = (p_noimp::B12)` | **pkg ts** | own ts | **pkg ts** |
| `g4_nopar` | `localparam logic[11:0] = p_noimp::B12` | **pkg ts** | own ts | **pkg ts** |
| `g5_fromParam` | ref to a package **`parameter`** (not localparam) | **pkg ts** | own ts | **pkg ts** |
| `g6_op` | `= p_noimp::A8 + 1` (OPERATION) | own ts | own ts | own ts |
| `g7_untyped` | `localparam g7 = p_noimp::A8` (UNTYPED) | **pkg ts** | own ts | own ts → **R5** |

### `v60a` / `v60c` — the package IS wildcard-imported, and the other fences

| row | source | golden | pristine | patched |
|---|---|---|---|---|
| `i1_shadow` | `import p_imp::*;` + `= p_imp::N`, names DIFFER | pkg ts | pkg ts | pkg ts |
| `i2_other` | `= p_imp::L` | pkg ts | pkg ts | pkg ts |
| `i3_bare` | `= N` (BARE name, resolved by the import) | **own ts** | pkg ts | pkg ts → **R1** |
| `u0 A8` | name COLLIDES, **no import anywhere** | **pkg ts** | own ts | **pkg ts** |
| `u1 PD` | PARAMETER PORT **default** `= p2::A8` | **pkg ts** | own ts | **pkg ts** |
| `u2 PO` | PARAMETER PORT **overridden** `#(.PO(p2::A8))` | own ts | own ts | own ts |
| `u3 g[0..1].gp` | GEN-SCOPE localparam `= p2::A8` | **pkg ts** | own ts | own ts → **R6** |
| `u4 c1` / `c2` | `= p2::A8` / `= c1` (chained through a LOCAL) | pkg ts / `0:0-0:0` | own / own | **pkg** / own (span-only) |
| `u5 n1/n2` | literal / operation | own ts | own ts | own ts |
| `u5 n3` | `= p3::Z`, and `p3::Z` itself came from `p2` | **p3's ts** | own ts | **p3's ts** |
| `p2::`/`p3::` rows | package's OWN param_assigns (`inPackage`) | — | — | UNCHANGED |

### `v60b` — the NAME-COLLISION half (residue R1), unchanged by design

`s_coll_scoped` (usbdev shape), `s_lit_after` / `s_lit_before` (rv_timer shape,
literal RHS), `s_port_coll` and `s_hdr_coll` (flash_erase_ctrl / rstmgr_ctrl
shape). Golden keeps the module's OWN typespec in ALL SEVEN; we bind the
wildcard-imported package's same-named one. **DIFFERING 14 before, 14 after** —
this pass does not touch them, and the arm is committed so the next pass has the
shape reproduced.

### `v60d` — the `!isImported` FENCE

`src → mid → module`: a module wildcard-imports `mid`, whose own localparams
come from a THIRD package `src`. Golden gives the module's MATERIALIZED IMPORT
COPIES the typespec of the package that DECLARES them (`mid`), not the one the
value came from (`src`). **DIFFERING 4 → 2**; the two survivors are the `mid::`
package listing rows (golden keeps a `ref_obj` Rhs where we fold to a constant),
identical on both binaries.

## 5. THE LAW

> **§ pkgScopedParamRhsTs60 — in the ELABORATED view, a parameter or localparam
> DECLARED IN A MODULE SCOPE whose WHOLE initializer (parentheses and implicit
> conversions stripped) is a reference to a PARAMETER declared in a PACKAGE has
> its folded `param_assign` Rhs constant's `ref_typespec` bound to THAT PACKAGE
> MEMBER's own typespec — the package-located object carrying
> `vpiInstance -> the declaring package`. An OPERATION Rhs, an
> instantiation-site OVERRIDE, and a MATERIALIZED WILDCARD-IMPORT COPY all keep
> the declaring scope's own typespec.**

Decoded out of Surelog, not inferred: `NetlistElaboration::elab_parameters_`
(`NetlistElaboration.cpp` ~396) builds the elaborated Rhs constant, seeds its
`ref_typespec` from the DECLARED parameter's typespec and then **unconditionally
overwrites it** —

```cpp
if (const typespec* ts = value->getTypespec()) {
  ...
  c->Typespec()->Actual_typespec((typespec*)ts);   // the VALUE's typespec wins
}
```

— and the `Value`'s typespec is set in `DesignElaboration.cpp:2542`
`value->setTypespec(cts ? cts : ts)`, where `cts` is the COMPILED expression's
own constant typespec and `ts` the declared one. A bare `pkg::name` compiles to
the package parameter's own folded constant, so `cts` is the package's typespec;
an operation or an override never produces that constant, so `ts` stands.

### The implementation is ONE `else if`

`src/ParamEmit.cpp`, inside the pre-existing `ParameterFromPkg*` arm:

```cpp
else if (!ypa && rhsRt && !isImported) {
    rhsRt->Actual_typespec(pkgHomedYTs());
    pkgRefFold = true;
}
```

The arm already implemented this law — but only when the package member is
MATERIALIZED into the referencing scope by a wildcard import, because it looks
the source up in `pkgRefSrc`, and **`pkgRefSrc` is a LOCAL variable holding only
the parameters emitted in THIS scope's own loop.** `dm_mem.sv` and
`tlul_socket_m1.sv` import nothing, so the lookup missed and the Rhs ref was
left bound by the deferred `pendingParamTs` path to the declaring scope's own
typespec. Three fences, each measured:

1. **`!ypa`** — the pkgRefSrc MISS. On a HIT the existing branch runs unchanged,
   which is why residue R1's 11 corpus cells and `v60b`'s 7 arm cells do not
   move.
2. **`rhsRt`** — only the typespec moves. The Rhs constant's value, size,
   constType, decompile and parent are NOT touched: the census shows all of them
   already equal to golden (uhdm-cmp walks past them into the typespec), and Y's
   `param_assign` is not a parent this scope owns.
3. **`!isImported`** — **THE FIRST FENCE THE CENSUS FOUND, AND THE REASON THIS PASS
   ALMOST SHIPPED A REGRESSION.** Without it the Earlgrey head CLEARED (9 743 →
   29, exactly the intended result) while the 3-way census read
   **`AWAY-GOLDEN = 293`**: a module's materialized import copy of
   `flash_phy_pkg::NumBanks` — whose own initializer is
   `flash_ctrl_pkg::NumBanks` — was retargeted from `flash_phy_pkg`'s typespec
   to `flash_ctrl_pkg`'s, and the same for `alert_handler_reg_pkg ← alert_pkg`
   and `rstmgr_pkg ← pwrmgr_pkg`, ×12 modules each. **The head-only reading
   would have shipped a regression twenty times the size of the fix.** The
   whole-dump histogram said so too: 307 added `|vpiInstance:` for a law that
   claimed 14. `v60d` is the arm for it.
4. **the package member's own initializer is not an AGGREGATE LITERAL** —
   **THE SECOND FENCE, and the WIDE BOUNDARY found this one after the corpus
   census had already read clean.** Y hands over its typespec only if Y's own
   package `param_assign` folded to a CONSTANT; a package does NOT fold a
   CONCAT or a REPLICATION (r10c9/b), keeps an `operation` Rhs for them, and
   exactly those members do not propagate. `v60e_earl60.sv` is the grid, one
   package member per initializer shape, golden's module `s_take`:

   | package member's initializer | golden's package Rhs | golden's module row | pristine | patched |
   |---|---|---|---|---|
   | `4 + 3` / `(1)?5:6` / `9` / `$clog2(16)` / `12'h380` | constant | **the MEMBER's ts** | own ts | **member's ts** |
   | `{2'b10, 2'b01}` (CONCAT) | **operation** | the MODULE's own ts | own ts | own ts |
   | `{1{1'b1}}` (REPLICATION) | **operation** | the loc-less `int_typespec 0:0-0:0` | own ts | own ts (pre-existing) |
   | `'{a:4'h1, b:4'h2}` (assignment pattern) | operation | operation, pkg struct ts | same | same |

   Without it `v60e`'s `k_cat` moved **AWAY FROM GOLDEN** outright and
   `r10earl55repro/a5_earl55.sv` moved from one wrong answer to a farther one.
   The corpus census could not see either: all 14 Earlgrey cells are sourced
   from INTEGER LITERALS, and the Earlgrey databases are **byte-identical
   between the two patched binaries** — fence 2 changes nothing there. **The
   wide boundary was the only instrument that could convict it.**

## 6. CENSUS: PREDICTED 14, MEASURED 14, AWAY-GOLDEN 0

`CENSUS_PREDICT60.txt` was written BEFORE the patched database existed and names
all 14 cells and all 13 `u_sm1_NN` instance paths.

```
Earlgrey_0_1/default    keys 15403   UNMOVED-GOOD 10726  UNMOVED-BAD 4663
                        TO-GOLDEN 14   AWAY-GOLDEN 0   STILL-WRONG 0
Earlgrey_0_1/testflags  keys 15407   UNMOVED-GOOD  9424  UNMOVED-BAD 5969
                        TO-GOLDEN 14   AWAY-GOLDEN 0   STILL-WRONG 0
```

### WHOLE-DESIGN BLAST RADIUS (path-normalised, pristine vs patched)

**default — 105 diff lines in 28 hunks:**

```
REMOVED  13  \_int_typespec: , line:72:14, endln:72:26     (tlul_socket_m1's own)
REMOVED   1  \_logic_typespec: , line:64:14, endln:64:40   (dm_mem's own)
ADDED    26  \_int_typespec: , line:10:12, endln:10:15     (top_pkg's)
ADDED    14  |vpiInstance:
ADDED    13  \_package: top_pkg …
ADDED     1  \_package: dm …
ADDED     3  \_logic_typespec: , line:34:14, endln:34:26  + its range/constants
```

Exactly 14 targets out, 14 stamps in. **ZERO** lines naming any other
identifier, module, instance, net, process or assign; **ZERO** DEF-view paths.

**testflags — 107 diff lines in 29 hunks**, the same histogram PLUS two more
removed lines, and they are the whole of TARGET B:

```
REMOVED 1  |vpiActual:
REMOVED 1  \_parameter: (work@top_earlgrey.u_dm_top.i_dm_mem.DbgAddressBits), 59:27-59:41
```

## 7. TARGET B IS CLEARED BY TARGET A'S LAW — measured, not argued

r10earl59 ranked R0-testflags as a separate mechanism: a DEF-view localparam
range bound (`logic [DbgAddressBits-1:0]`) whose `ref_obj` carried
`vpiActual → the ELABORATED instance's parameter` where golden has none. It is
gone, and the reason is structural: that leaked ref lived in the RANGE of
`dm_mem`'s own `logic_typespec 64:14-64:40`, and the only edge that reached it
from the elaborated tree was the very Rhs `ref_typespec` this law retargets.

```
|vpiActual: -> parameter (work@top_earlgrey.u_dm_top.i_dm_mem.DbgAddressBits)
   golden 27      pristine 28      patched 27
```

The testflags head therefore MOVED FORWARD, 33 → 30 lines, to a **PRE-EXISTING**
cell this pass did not create: `tlul_adapter_sram.sv:132:18` inside the
`tagged_pattern` assignment-pattern block (golden `UINT:0` size 3, ours `'0`
`BIN:0` constType 3). The proof that it is pre-existing is the blast radius
itself — the complete ADDED/REMOVED lists above contain no `tlul_adapter_sram`
line, no `132:18`, and no `BIN:0` — together with `AWAY-GOLDEN = 0`.

**This pass predicted "testflags UNCHANGED" and that prediction is REFUTED. It
is recorded here as a refutation and not quietly upgraded to a win.**

## 8. GATE RESULTS

| gate | measurement | result |
|---|---|---|
| **1 build** | both, `-j 2`, md5 **separately**, then copied to `/tmp/r10earl60_bin/{pris,pat}` and `chmod 555` BEFORE any sweep | pristine **`1c9a7a008aa169fe12e76d954e146783`**, patched **`7e7395f02206f9af44b770c8187ef79b`** |
| **2 goldens** | `tests/check_goldens.sh`, `SLANG_UHDM` exported EXPLICITLY to EACH | patched **23 PASS / 0 FAIL**, pristine **23 / 0**, `/bin/false` **0 PASS / 23 FAIL** |
| **3 u2r** | `ct8rows.sh`, **baseline FIRST**, whole row incl. the dump column | testflags vs the committed `results/gate_uhdm2rtlil.csv`: pristine **0 rows**, patched **0 rows**; pristine↔patched **0 rows** in BOTH modes.  Status **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** and dump **183 differ / 496 match** (testflags), **187/492** (default), in every cell |
| **4 surelog** | both modes concatenated, **1 588 rows**, vs the committed `results/golden_surelog.csv` | baseline↔pristine **0**, baseline↔patched **0**, pristine↔patched **0**.  Status default 470/11/5/283/25, testflags 466/9/5/3/1/284/23/1/2 — identical everywhere.  **NO ROW CONVERTED**; `results/*.csv` NOT edited |
| **5 byteverify** | `byteverify60.sh` + both controls | surelog **956 paths, 3 movers**; u2r **1 358 paths, 0 movers**.  Controls: `SELFCHECK=1` → **955/956** flagged, `SELFCHECK1=1` → **4 = 3 real + exactly 1 corrupted** |

**THE THREE surelog MOVERS, each named and attributed:**

```
MOVER ./default/Earlgrey_0_1-71da2fd7    PREDICTED BY NAME in CENSUS_PREDICT60.txt
MOVER ./testflags/Earlgrey_0_1-71da2fd7  PREDICTED BY NAME in CENSUS_PREDICT60.txt
MOVER ./default/Scoreboard-59431470      NOT predicted -- and NOT this pass
```

`Scoreboard/default` is the documented ~50/50 COIN, and this pass PROVES it
rather than citing it. Four runs of the **PRISTINE** binary alone, same command
line, same cwd:

```
15f1ee37317bff5187fc2b5b09a27197   (run 1, 3, 4)
cbf2a23ab9e7e210d23a216a9eda94f2   (run 2)
```

— which are EXACTLY the two md5s the verifier printed as
`patched=15f1ee37317b pristine=cbf2a23ab9e7`. The whole-dump diff of the two
Scoreboard databases is **94 lines in 2 hunks, 47 ADDED and 47 REMOVED, the
SAME 23 `svunit_pkg::…` task/function entries under `|vpiTaskFunc:` in a
different ORDER** — an order-only difference, and the standing rule is to
attribute only order-blind. **0 movers of this pass.**

**BINARY AUDIT — EVERY `cmds.txt`, not `head -1`:**

```
/tmp/r10earl60_swd/surelog_pat     1573 cmds.txt, 1523 slang: lines, 1523 -> .../pat,  OTHER 0
/tmp/r10earl60_swd/surelog_pris    1573 cmds.txt, 1523 slang: lines, 1523 -> .../pris, OTHER 0
/tmp/r10earl60_swd/uhdm2rtlil_pat  1462 cmds.txt, 1458 slang: lines, 1458 -> .../pat,  OTHER 0
/tmp/r10earl60_swd/uhdm2rtlil_pris 1462 cmds.txt, 1458 slang: lines, 1458 -> .../pris, OTHER 0
```

`GOLDEN_DEFER` was never set (`sweeps60.sh` unsets it and it read `<unset>` at
audit time). Both binaries were frozen at immutable `chmod 555` paths BEFORE
any sweep, and **the patched sweeps were RE-RUN from scratch after fence 2
changed the binary** — the stale-binary CSVs were discarded, not reused.

### CANARIES AND BOUNDARIES

* `canaudit.sh canaries.sh ctcan2.sh`: **audited=29 UNCOVERED=0 FENCE-BREACH=0**;
  all four slang-fenced names dispatched by no driver here, and none of them is
  spelled in any artifact of this pass.
* `canaries.sh`: surelog **ok=52 changed=0 absent=0** on BOTH binaries (7
  unknown-names are the u2r-only canaries, the expected count); u2r **ok=8
  changed=0 absent=0** on both. `ctcan2.sh` (`EXPECT_UNKNOWN=1`): **PASS on
  both**.
* Every named pin — InterfaceModPort, BlackParrotComplex, YosysOldOr, SVSwitch,
  YosysVerx — is covered by gate 5: **2 311 of 2 314 databases byte-identical**,
  the only 3 movers named and attributed above.
* **ROW HEADS** (`rowheads.sh`, LHS always golden), pristine → patched:

  | test | default | testflags |
  |---|---|---|
  | SeqDriver / SimpleUVM / Scoreboard / MiniAmiq | 96 → 96, 1 head | 96 → 96 |
  | BuildUVMPkg | 29 → 29, 1 head | 29 → 29 |
  | Rggen | 66 → 66, 1 head | (no golden on this machine) |
  | **Earlgrey_0_1** | **9 743 → 29, 1 head → 1 head** | **33 → 30, 1 head → 1 head** |

* **WIDE BOUNDARY** (`vbndall60.sh`, both views, both binaries, every committed
  `.sv` under `tools/probe`, recursive): **runs=2082 arms=1041 identical=2039
  DIFFERING=14 no_output=29**. 8 of the 14 are this pass's own arms
  (`v60a`, `v60c`, `v60d`, `v60e` × 2 views; `v60b` correctly does NOT move).
  The remaining **6 rows are 3 DISTINCT EARLIER-PASS ARMS**, and `varm60.sh`
  attributes every one three ways with the final binary:

  | arm / view | line-movers TO / **AWAY** / STILL | line distance to golden | keyed param_assign census |
  |---|---|---|---|
  | `r10earl52repro/a3_earl52.sv` plain | 6 / **0** / 0 | 123 → 117 | TO-GOLDEN 1, AWAY 0 |
  | `r10earl52repro/a3_earl52.sv` elab | 6 / **0** / 0 | 124 → 118 | TO-GOLDEN 1, AWAY 0 |
  | `r10earl52repro/a4_earl52.sv` plain | 25 / **0** / 0 | 74 → 49 | TO-GOLDEN 1, AWAY 0 |
  | `r10earl52repro/a4_earl52.sv` elab | 25 / **0** / 0 | 74 → 49 | TO-GOLDEN 1, AWAY 0 |
  | `r10earl_repro/i.sv` plain | 12 / **0** / 0 | 144 → 132 | TO-GOLDEN 2, AWAY 0 |
  | `r10earl_repro/i.sv` elab | 12 / **0** / 0 | 144 → 132 | TO-GOLDEN 2, AWAY 0 |

  **A FOURTH earlier-pass arm moved and is the reason fence 2 exists.**
  `r10earl55repro/a5_earl55.sv` first read `TO=1 AWAY=24`, line distance
  **183 → 206** (plain) and **239 → 262** (elab), with the keyed census calling
  it `STILL-WRONG` — a cell wrong before and wrong after, but FARTHER. It is
  `localparam logic [0:0] K = pk5_55::PKW1;` with `PKW1 = {1{1'b1}}`, and it is
  what sent this pass back to measure `v60e`. **With fence 2 the arm reports
  `TO=0 AWAY=0 STILL=0`, distance 183 → 183 and 239 → 239 — it no longer moves
  at all and it is no longer in the DIFFERING list.**
* **SIGNAL rows**: 6, and **SYMMETRIC** — `r10buvm8repro/v21shadow8.sv`,
  `r10uvm84repro/v84x8_break.sv`, `r10uvm87repro/v87_a4_scope.sv` each rc=139 on
  **BOTH** binaries in the elab view. Pre-existing, and an asymmetric instrument
  could not have said so (`patched=3 pristine=3`).
* **DEF-VIEW FENCE, measured twice.** Earlgrey: of the 105/107 diff lines, **0**
  carry a DEF-view `work@dm_mem.…` or `work@tlul_socket_m1.…` path. Arms: every
  `DEF` row of `v60a`…`v60e` is SAME on both binaries, before and after.

## 9. RESIDUES, RANKED (every one measured on the corpus AND reproduced on an arm)

* **R1 — the NAME-COLLISION misbind, 11 corpus cells, the largest remaining
  cell of this family.** When a module's own parameter NAME collides with a
  member of a WILDCARD-IMPORTED package, we bind the package's typespec and
  golden keeps the module's own — for an explicitly-scoped RHS (`usbdev
  NEndpoints`), a LITERAL RHS (`rv_timer N_HARTS/N_TIMERS`), a PARAMETER PORT
  (`flash_erase_ctrl AddrW`, `flash_mp MpRegions`, `rstmgr_ctrl PowerDomains`)
  and a header-import spelling alike. Reproduced in `v60b_earl60.sv` (7 cells,
  DIFFERING 14 before and after) and as `v60a`'s `i3_bare`. Golden's own
  counter-examples are in the corpus: it DOES bind the package's typespec for
  `flash_mp.BankW` and `rstmgr_ctrl.OffDomains` (body/port LOCALPARAMS whose
  names also collide), so the distinguisher is narrower than "collision" and is
  NOT yet decoded. **Not claimed here; claiming it unmeasured is exactly the
  mistake `!isImported` nearly was.**
* **R2 — `prim_flop_2sync.ResetValue` under `u_pwrmgr.i_cdc.i_ast_sync`.**
  Golden's elaborated Rhs is an `operation` carrying `pwrmgr_pkg`'s
  `struct_typespec`; ours is a `constant` with a `bit_typespec`. The
  instantiation passes a package STRUCT constant into a `parameter bit` port —
  golden keeps the argument's shape, we fold. 1 cell.
* **R3 — `flash_erase_ctrl PageAddrMask / BankAddrMask`.** Golden keeps an
  `operation` Rhs, we fold to a `constant`. 2 cells; a FOLD-depth question, not
  a typespec one.
* **R4 — 3 cells where only the typespec KIND or SPAN differs**
  (`pinmux MioPeriphHasSleepMode` int vs logic at `0:0-0:0`, `usbdev
  AVFifoWidth`, `u_memory_2p LocalDataBitsPerMask`). Two of the three are
  span-only and therefore INVISIBLE to `uhdm-cmp`.
* **R5 — the UNTYPED localparam** (`localparam g7 = pkg::A8`). Golden binds the
  package typespec here too; our `rhsRt` is not even created on the untyped path
  (`wantTs && … && (typedParam && NamedValue && Package)`), so claiming it means
  minting the ref as well. **Zero corpus cells of this shape**, so it would be
  unmeasured risk for zero corpus gain. Arm row `v60a_earl60.sv g7_untyped`.
* **R6 — the GEN-SCOPE localparam** (`for (genvar …) begin : g localparam int gp
  = pkg::A8;`). Golden binds the package typespec; the gen-scope localparam is
  emitted by a different site (`ModuleEmit`'s gen-local param path) that this
  arm does not reach. **Zero corpus cells of this shape.** Arm rows
  `v60c_earl60.sv u3.g[0]/g[1] gp`.
* **R7 — the ELAB `enum_typespec (dm::csr_reg_t)` span**, golden
  `383:41-383:50` vs ours `244:3-301:15`, the ONE `MISSING 1 / EXTRA 1` pair in
  the whole `vpiInstance` ELAB census. Spans are not compared, so it is a dump
  difference only.
* **R9 — `pkg::Y` where Y's own initializer is a REPLICATION.** Golden gives the
  referring module's fold the LOC-LESS `int_typespec 0:0-0:0` (r10earl55's
  width-1 rule); we give the module's own typespec. Wrong before this pass and
  wrong after, IDENTICALLY — fence 2 keeps it exactly where it was. Arm rows
  `v60e_earl60.sv k_repl` and `r10earl55repro/a5_earl55.sv K`. **Zero Earlgrey
  cells.**
* **R8 — the 1 742 TAIL stamps** (§1). Unreachable to `design::Compare`; a
  `uhdm-dump` cosmetic. Recorded so no later pass re-targets them.

## 10. THE LADDER

**Not re-run, and this pass says so rather than quoting a stale number.**
r10earl57's `LADDER57.md` established that the horizon rule is not a sound
ordering bound. Here both exact arbiters agree: the 3-way keyed census says
`TO-GOLDEN 14 / AWAY-GOLDEN 0 / STILL-WRONG 0` in BOTH modes, and the whole-dump
path-normalised diff is 105/107 lines carrying two identifiers.

## FILES

| file | what |
|---|---|
| `tsinst60.cpp` | the HEAD LOCATOR: finds the OWNER behind an `RHS: <null>` head by masking golden objects in a fresh `CompareContext` and re-running the OFFICIAL `design::Compare`. `--calib` control included. Measurement only |
| `pacensus60.cpp` | the `param_assign` Rhs-typespec census, taken on the DATABASES (the dump's global visited set makes a dump-text census blind to shared objects) |
| `attr60.py` | the 3-way multiset attribution (TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / UNMOVED-GOOD / UNMOVED-BAD) |
| `census60.py` | the whole-dump `vpiInstance` edge census, sectioned DEF / ELAB / TAIL — the instrument that refuted the brief |
| `objcount60.py` | the full-print object population census (with its SHALLOW-vs-FULL ambiguity made explicit) |
| `dumpdiff60.sh` | the path-normalised whole-dump diff + ADDED/REMOVED histogram |
| `v60a_earl60.sv` | THE GRID — reference shape × declared type, package NOT imported |
| `v60b_earl60.sv` | the NAME-COLLISION half (residue R1), the corpus shapes on the other side |
| `v60c_earl60.sv` | the remaining fences: collision without import, port default vs override, gen scope, chained ref, package→package |
| `v60d_earl60.sv` | the `!isImported` fence — the `src → mid → module` shape the CENSUS caught |
| `v60e_earl60.sv` | the AGGREGATE-LITERAL fence — one package member per initializer shape, the grid the WIDE BOUNDARY forced |
| `arm60.sh` / `gridrows60.sh` | arm driver (plain by default, `--elab` for the testflags shape) and its one-line-per-row printer |
| `earl60.sh` | Earlgrey_0_1 in EITHER mode, one binary, against the immutable golden cache |
| `sweeps60.sh` / `ct8rows.sh` / `byteverify60.sh` | gates 3, 4, 5 |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` | the canary battery and its audit |
| `rowheads.sh` | the seven named row heads |
| `vbndall60.sh` / `varm60.sh` | the wide boundary and its 3-way verifier |
| `CENSUS_PREDICT60.txt` | the prediction, written before the patched binary existed |
| `PREDICT_R0.txt` | the next head, both Earlgrey modes |

---

# VERIFIER APPENDIX — r10earl60 ADVERSARIAL VERIFICATION (v60)

Independent worktrees `/tmp/wt_v60` (patch applied) and `/tmp/wt_v60pris`, both
at `d51c8eb`; both binaries rebuilt from scratch and frozen `chmod 555` before
any sweep.

## 1. EVERY HEADLINE NUMBER REPRODUCED BIT-FOR-BIT

| claim | verifier measurement |
|---|---|
| pristine md5 `1c9a7a008aa169fe12e76d954e146783` | **identical** |
| patched md5 `7e7395f02206f9af44b770c8187ef79b` | **identical** |
| `src/ParamEmit.cpp` md5 `7461f75c090c92c2d152c84c8b2c53d3` | **identical**, patch applies clean on a fresh `d51c8eb` |
| goldens 23/0 (pat), 23/0 (pris), `/bin/false` 0/23 | **reproduced** |
| u2r 731 rows, 0 differing vs committed baseline, 679/50/2 | **reproduced**, both binaries, whole row incl. dump column |
| surelog 1 588 rows, 0 differing vs committed baseline, NO row converted | **reproduced**, both binaries |
| Earlgrey_0_1/default head 9 743 -> 29 | **reproduced** (`grep -c '^LHS:'` = 1 both sides) |
| Earlgrey_0_1/testflags head 33 -> 30 | **reproduced** |
| every other row head unchanged (96/96/96/96/29/66) | **reproduced** |
| 3-way census both modes: TO-GOLDEN 14 / AWAY 0 / STILL-WRONG 0, UNMOVED-GOOD 10 726 (def) / 9 424 (tf) | **reproduced to the unit**, with the implementer's own `attr60.py` AND with a Compare-visible-only payload |
| byteverify u2r 0/1358, surelog 3/956 | **reproduced**, same three paths |
| Scoreboard/default is the documented COIN | **reproduced and STRENGTHENED**: six runs of the PRISTINE binary alone gave **four** distinct md5s including both `15f1ee37317b` and `cbf2a23ab9e7` |
| canaudit 29/UNCOVERED 0/FENCE-BREACH 0; canaries ok=52/ok=8 changed=0 | **reproduced** for pris, pat and the verified binary |
| pins SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort/BlackParrotComplex/YosysOldOr byte-identical | **all hold** |
| binary audit, every `cmds.txt`, OTHER 0 | **reproduced** (1523/1573 and 1458/1462 carry a `slang:` line; the remaining 50 and 4 carry none) |
| blast radius 28 hunks (default) / 29 (testflags), zero DEF paths | **hunk counts reproduced**; changed line-SIDES measured 103 / 105 (the report says 105 / 107); every hunk lies above the `uhdmtopModules` boundary, so **zero DEF paths CONFIRMED** |

## 2. THE LAW BROKE — 7 PRISTINE-RIGHT -> PATCHED-WRONG CELLS, TWO CAUSES

The corpus census could not see them: neither shape occurs in Earlgrey or in
either corpus. Only a wider boundary grid convicts them. Both are
**Compare-visible** (`typespec::Compare` reads `vpiInstance`).

### 2a. § pkgUntypedYNoStamp60 — a PLAIN UNTYPED package member must NOT be stamped

`vfa_v60.sv` grids 19 package-member declaration shapes against one typed module
localparam each. Golden, Surelog:

```
localparam UA        = 8;        -> module's Rhs ts Instance = NULL
localparam [11:0] UB = 12'h380;  -> Instance = package
localparam signed [7:0] US = -3; -> Instance = package
every WRITTEN type (int/byte/shortint/longint/integer/bit/logic/real/
string/time/typedef/enum/struct/2-D packed) -> Instance = package
```

The module copies the package member's typespec **exactly as the package emits
it, stamp included** — and this file already encodes when a package stamps:
`inPackage && typedParam`, plus `!typedParam && isRangedUntypedParam`. The
shipped arm called `makeParamTs(ysym, /*typedParam=*/true)` and stamped
unconditionally, so `localparam UA = 8;` came back with `vpiInstance -> package`
where golden has NULL. Hit in a MODULE (`vfa`, `vfg`), an INTERFACE (`vfg`) and
a PROGRAM. Forcing `typedParam=true` also mis-ANCHORS the typespec (whole
declaration instead of the packed range / signing keyword).

Why the implementer's census missed it: `attr60.py`'s payload carries the
typespec SPAN, and for this cell the spans agreed, so the Instance flip landed
in STILL-WRONG instead of AWAY-GOLDEN. `attrv60.py` (added here) drops spans and
keeps only the fields `Compare` reads.

### 2b. § pkgYFoldNestedConcat60 — the deny is not a TOP-LEVEL kind test

`vff_v60.sv` grids the nesting. Golden, read as the PACKAGE's own elab
`param_assign` Rhs kind, which is the thing that decides:

| package member | pkg Rhs | module propagates |
|---|---|---|
| `{a,b}` | operation | no |
| `{a,b} + 4'd1` | operation | **no** <- shipped patch said yes |
| `4'd1 + {a,b}` | operation | **no** <- shipped patch said yes |
| `{4{1'b1}} & 4'hF` | operation | **no** <- shipped patch said yes |
| `{a,b}[1:0]` | operation | **no** <- shipped patch said yes |
| `1 ? {a,b} : 0` | CONSTANT | yes |
| `$bits({a,b})` | CONSTANT | yes |
| `int'(3.7)` | operation | no |
| `int'(4)`, `8'(3)`, `int'(3)+1`, `-4`, literal | CONSTANT | yes |

The shipped `yAggLit` read only `stripImplicitConv(*yinit).kind`, so a concat or
replication one level down slipped through. Re-cut on
`containsPatternOrConcat`, the predicate already in this file. The two FOLDING
shapes (ternary-with-concat-branch, `$bits(concat)`) are knowingly **forfeited**:
denying them only reproduces baseline, allowing them costs a real regression.

## 3. THE FIX IS CORPUS-NULL AND KEEPS EVERY GAIN

* `src/ParamEmit.cpp` only; no new helper, no new surface.
* byteverify **verified vs shipped-patch: 0 movers / 1358 (u2r) and 0 / 956
  (surelog)** — it changes nothing either corpus reaches.
* Earlgrey heads still **29 / 30**; census still **TO-GOLDEN 14, AWAY 0,
  STILL-WRONG 0** both modes; Earlgrey dumps **byte-identical** to the shipped
  patch in both modes.
* gates 3 and 4 re-run on the verified binary: **0 differing rows** on both
  corpora vs the committed baselines. No row converted; `results/*.csv` untouched.
* goldens 23/0; full canary battery PASS; all pins hold.
* wide boundary, 2 070 runs over 1 035 arms: DIFFERING 26 — 12 verifier arms,
  8 this pass's own arms, 6 = three pre-existing arms (`r10earl52repro/a3`,
  `a4`, `r10earl_repro/i.sv`) all TO-GOLDEN with AWAY 0. `r10earl55repro/a5_earl55.sv`
  no longer differs at all. SIGNAL rows symmetric 3/3 (pre-existing).
* every differing arm re-attributed with `attrv60.py`: **AWAY-GOLDEN = 0
  everywhere**, both views.

## 4. RESIDUES THE VERIFIER MEASURED AND DID NOT FIX

* **R-cast** — `localparam int X = pkg::Y` with `Y = int'(3.7)`: golden keeps the
  module Rhs an `operation`, we fold it to a `constant`. Pre-existing (pristine
  is wrong too); the cell is already unequal at the Rhs kind, so the typespec
  stamp riding on it is not an AWAY-GOLDEN. `vff_v60.sv:28`.
* **R-fold-forfeit** — `1 ? {a,b} : 0` and `$bits({a,b})` package members DO
  propagate in golden and we now deny them. Two boundary cells, zero corpus
  cells, no regression. `vff_v60.sv:24,26`.
* **R-dumpline** — `v60a_earl60.sv` moves the whole-dump `|vpiActual:` count
  102 -> 101 against golden's 109 while the `work@a1.u_sub.DbgBits` identifier
  count moves 9 -> 8 ONTO golden's 8. This is `uhdm-dump`'s global visited set
  re-rooting a shared subtree, not an edge loss; the database census reports 0
  AWAY. Identical under the shipped patch and the verified one.
* **R-untypedSpan** — the pre-existing `ParameterFromPkg*` arm (the `pkgRefSrc`
  HIT path) still calls `makeParamTs(_, true)`; `pkgHomedYTs(false)` reproduces
  it byte-for-byte on purpose. If a corpus row ever reaches that arm with an
  untyped package member it will carry the same two defects.

## 5. FILES ADDED BY THE VERIFIER

* `vfa_v60.sv` package-member TYPE grid (19 shapes) — convicts 2a
* `vfb_v60.sv` declaring-scope grid ($unit / interface / function / gen-if /
  nested module / two instances of one module)
* `vfc_v60.sv` port default vs instantiation override vs chain, one module
  instantiated twice from two different packages
* `vfd_v60.sv` import variety (explicit single-name import, re-export chain,
  imports one package and refers to another)
* `vfe_v60.sv` package-member initializer shapes (cast, `$bits`, unary,
  comparison, func call, unpacked array) — convicts 2b
* `vff_v60.sv` the NESTING grid — locates the fold boundary exactly
* `vfg_v60.sv` class / program / interface scopes — convicts 2a twice more
* `attrv60.py` 3-way attribution with a **Compare-visible-only** payload
* `vrun60.sh` one-arm golden/pristine/patched runner
