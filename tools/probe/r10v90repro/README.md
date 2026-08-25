# r10v90 — THE ADVERSARIAL VERIFICATION OF r10earl90

**VERDICT: ACCEPT-WITH-FIX.** § `connIpsWidthNonOvParamSignedTs90` is a sound
transcription of Surelog's `if (sval->isSigned())` mint and it clears the
Earlgrey head in both modes — but **fence (e) had a hole**: a `defparam`
rebinds a parameter's VALUE without rebinding its INITIALIZER, so
`isOverriddenParam`'s span test cannot see it, and the law fired on two cells
where the pristine emitter was **RIGHT** and golden stamps **nothing**. The fix
is § `defparamHidesTheOverride90v` (one static helper, one `&&` clause at the
existing call site, DEPTH 0 only). Shipped as `/tmp/r10earl90.verified.patch`.

**BASE `986bc0a`, branch `auto5h`.** `results/*.csv` READ-ONLY and untouched;
**NO ROW CONVERTED**; slang NOT patched. Production surface unchanged from the
implementer's: `src/ExprEmit.cpp` + `include/UhdmExporter.h` only.

---

## 1. Reproduction of every headline number, bit for bit

Both binaries rebuilt from scratch in my own worktrees at `986bc0a`, frozen
`chmod 555`, every `cmds.txt` audited BY BINARY PATH.

| | implementer claimed | I measured |
|---|---|---|
| pristine binary md5 | `d181b1b59682b7739e5f5681f15a9c83` | **the same** |
| patched binary md5 (as shipped) | `491decb635ec159a3c8a5fe7b637c211` | **the same** |
| goldens patched / pristine / `/bin/false` | 23-0 / 23-0 / 0-23 | **the same** |
| u2r default & testflags | 679 / 50 / 2 | **the same, both modes** |
| surelog default | 471 EQ, 10 NE, 5 DEFERRED, 283 REJ, 25 SLFAIL | **the same** |
| surelog testflags | 466 EQ, 9 NE, 5 DEFERRED, 284 REJ, 23 SLFAIL, 3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM | **the same** |
| `HEAD_BEFORE_Earlgrey_{default,testflags}.cmp` | 15 cmp lines, 1 head, byte-identical to each other | **the same, and identical to the committed logs modulo object ids** |
| `HEAD_AFTER` default / testflags | 110 / 142 cmp lines, 1 head each | **the same, identical to the committed logs modulo ids** |
| the R0 head object | `hier_path (reg2hw.cfg0.prescale.q)` at `rv_timer.sv:56`, ours `vpiSize:12`, golden unset | **confirmed, line for line** |
| surelog byte movers | 3 / 956 (both Earlgrey + the Scoreboard coin) | **the same three** |
| Earlgrey hashes | `ded7aff7a3d0`→`43a8d277a6fc`, `8cfc4af7915b`→`02496164d2f6` | **exactly these, with the FIX in** |
| Scoreboard/default order-blind | 1 099 223 sorted lines each, 0 differing | **exactly this** |
| u2r byte movers | 0 / 1358 | **the same** |
| canaries / ctcan2 / canaudit | ok=52, ok=8, PASS, PASS, `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **the same** |
| protected DBs | all SAME; `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | **the same, both modes** |

The Scoreboard coin's PRISTINE face differed between the two of us
(`a41ad38e85c3` here, `efb7bc8e33bd` there) — which is the coin behaving as
RESUME §9 describes, and is why it must be attributed order-blind and never by
hash.

---

## 2. THE BREAK — § `defparamHidesTheOverride90v`

`v2_over90.sv` instantiates ONE module from ONE declaration and ONE source
span six times and rebinds its `parameter int MW = 4` every way SV allows:

| instance | how `MW` is rebound | golden ips WIDTH typespec | pristine | patched AS SHIPPED |
|---|---|---|---|---|
| `u_def` | not at all | **signed `int_typespec`** | none | ✓ stamps |
| `u_nam` | `#(.MW(2))` | none | none | ✓ refuses |
| `u_pos` | `#(2)` | none | none | ✓ refuses |
| `u_same` | `#(.MW(4))` — the DEFAULT VALUE | none | none | ✓ refuses |
| `u_dp` | `defparam u_dp.MW = 2;` | **none** | **none (RIGHT)** | **STAMPS (WRONG)** |
| `u_dp2` | `defparam u_dp2.MW = 4;` — the DEFAULT VALUE | **none** | **none (RIGHT)** | **STAMPS (WRONG)** |

Two `TS-EXTRA` cells, `TS-RIGHT->WRONG 2` on the typespec-only scorer, in BOTH
the plain and the `--elabuhdm` view. `score3_90.py` reported them only as
`WRONG->OTHER`/`WRONG->WRONG`, because the same cells already carried the
pre-existing `SZ` difference of residue R1 — which is exactly why this
directory ships `tsonly90.py`, a scorer that looks at the EIGHT typespec fields
ALONE.

### Why the span test cannot see it (read out of slang, not guessed)

`slang/source/ast/symbols/ParameterBuilder.cpp:277-287`:

```cpp
if (auto it = overrideNode->paramOverrides.find(paramSyntax); …) {
    if (!it->second.expr) {                       // a defparam: a PRE-EVALUATED cv
        param->setValue(comp, it->second.cv, …);
        return *param;                            // <-- EARLY RETURN
    }
    newInitializer = it->second.expr;             // a #() / CLI override
    param->setInitializerSyntax(*newInitializer, …);
}
```

A `defparam` takes the early return: the declared default's syntax stays in
place, `DeclaredTypeFlags::InitializerOverridden` is never added (so slang's
own `ParameterSymbol::isOverridden()` is FALSE too), and
`isOverriddenParam`'s "is the bound initializer's span inside the default's
span" test answers FALSE — while `getValue()` is the overridden one.
`#(.MW(2))`, `#(2)` and a CLI `-G` all rebind the INITIALIZER and are caught.

### The fix

Ask the map `ParameterBuilder` itself consults — the enclosing
`InstanceBodySymbol`'s **public** `hierarchyOverrideNode`, keyed by the
parameter's own declarator:

```cpp
static bool hierNodeOverridden90(const ParameterSymbol& p) {
    auto* syn = p.getSyntax();
    if (!syn) return false;
    for (auto sc = p.getParentScope(); sc; sc = sc->asSymbol().getParentScope()) {
        auto& sy = sc->asSymbol();
        if (sy.kind != SymbolKind::InstanceBody) continue;
        auto* node = sy.as<InstanceBodySymbol>().hierarchyOverrideNode;
        return node && node->paramOverrides.find(syn) != node->paramOverrides.end();
    }
    return false;
}
```

`u_dp2` is why the fix cannot be a VALUE comparison: its defparam restates the
default, the values are identical on both sides, and golden still stamps
nothing.

### DEPTH 0 ONLY — a MEASURED distinction, not a convenience

A localparam DERIVED from a defparam'd parameter behaves the OTHER way in
golden. `dv90` declares `localparam int LD = DW; localparam int unsigned
LDU = DW;` and is instantiated three times:

| instance | `DW` | golden `LD` width | golden `LDU` width |
|---|---|---|---|
| `u_dv_def` | default 4 | `UINT:4` **+ TS** | `UINT:4` **+ TS** (the SOURCE's sign wins) |
| `u_dv_ov` | `#(.DW(2))` | `UINT:2` **+ TS** (the DECLARATION decides) | `UINT:2`, **no TS** |
| `u_dv_dp` | `defparam …DW = 2;` | **`UINT:4`** + TS | **`UINT:4`** + TS |

Surelog's emitted `parameter DW` object in `u_dv_dp` still reads
`UINT:4 vpiSigned:1` with its `int_typespec` (verified in the golden dump), and
both derived localparams elaborate from the DEFAULT — a real `#()` override
re-elaborates the body's localparams, a `defparam` does not. So the RECURSION
must keep reading `isOverriddenParam` alone, and the new test belongs at the
DIRECTLY READ parameter only. With the fix at depth 0, all six `u_dp*` /
`u_dv_*` cells match golden.

---

## 3. The four adversarial arms (`v1`–`v4`), both views

`varm90.sh` builds each arm with a FRESH Surelog golden and with BOTH frozen
binaries in the PLAIN **and** the `--elabuhdm` view, censuses all five
databases with the implementer's own `ct90cen --inst`, and scores them two
ways: `score3_90.py` (whole payload) and `tsonly90.py` (the typespec fields
alone). Every child gets `</dev/null` and its rc is recorded.

| arm | what it holds that `g1`–`g4` do not | payload `RIGHT->WRONG` | `TS-RIGHT->WRONG` | `TS-EXTRA` | `TS-FIXED` |
|---|---|---:|---:|---:|---:|
| `v1_minus90.sv` | **THE `-:` GRID** — the implementer's four arms contain ZERO `-:` selects; 12 descending selects × 6 declared types × WIDTH/BASE, plus the plain-module home | 0 | 0 | 0 | 5 |
| `v2_over90.sv` | **THE OVERRIDE GRID** — named, POSITIONAL, `defparam`, `defparam`-to-the-default, override-equals-default, INSTANCE ARRAY, a TOP-LEVEL module `parameter`, an IMPLICIT port parameter, and localparams DERIVED from each | 0 | **2 → 0** | **2 → 0** | 8 → 10 |
| `v3_types90.sv` | 25 more declared types / producer chains: `typedef int`, `typedef int unsigned`, `bit signed` typedef, **2-D packed signed**, `reg signed`, `time`, an ENUM, a scalar `logic signed`, three-deep bare chains, a bare read of a WILDCARD-IMPORTED package parameter (both decl signs), qualified reads in both directions, a PARENTHESISED initializer, a PARENTHESISED width, a written-CAST width | 0 | 0 | 0 | 15 |
| `v4_homes90.sv` | homes and contexts `g3`/`g4` do not reach: a gen-if NESTED in a gen-for, a gen-CASE, an INSTANCE ARRAY inside a gen scope, a THREE-DEEP instance chain, an interface PORT actual, a MODPORT-rooted select, OUTPUT and INOUT actuals, a hier_path WIDTH, a concatenation / replication / ternary around the select, a nested unpacked+packed select, part_selects with param bounds (MUST STAY), a USER-CALL argument (MUST STAY) | 0 | 0 | 0 | 9 |

**`TS-EXTRA` 0 and `TS-RIGHT->WRONG` 0 on all four arms in BOTH views after the
fix** — the law now only ever ADDS a typespec golden also has.

### What golden says about `-:` (the gap that mattered most)

`v1` settles it: the descending form is the SAME producer. Golden stamps on
`m01` (`int`), `m04` (`bit signed [3:0]`) and `m10`/`m11`/`m12`, and stamps
NOTHING on `m02` (`int unsigned`), `m03` (untyped), `m05` (`logic [7:0]`),
`m06` (expression), `m07` (literal) and `m08` (genvar) — cell for cell the same
answers as `+:`, with `IPT=2` instead of `IPT=1`. The shipped call site serves
both because it is the `RangeSelectionKind != Simple` arm; that is correct, and
now it is measured.

### The controls that had to stay still

`ctlarm90.sh` rebuilt **36 committed arms** from `r10earl47/65/67/70/81/84/85/89`
and `r10earl90` itself, each against a FRESH Surelog golden, with both binaries
in both views: **payload `RIGHT->WRONG` 0, `TS-RIGHT->WRONG` 0, `TS-EXTRA` 0,
`TS-OTHER` 0 on every one.** The twelve cells earl47/65/70 move are this law
and move TO golden (3 / 3 / 6), reproducing the implementer's re-score.

---

## 4. Gates, re-run end to end on the FIXED binary

Everything in §1's table, plus:

* `ct8rows` u2r testflags vs the committed `results/gate_uhdm2rtlil.csv`:
  **0 differing ROWS**; u2r default and testflags vs my own pristine sweep:
  **0 differing ROWS**.
* `ct8rows` surelog vs the committed `results/golden_surelog.csv`:
  **0 differing ROWS over 1588**; vs my own pristine: **0 differing ROWS**.
  **NO ROW CONVERTED** — `Earlgrey_0_1` stays `CMP_NOTEQUAL` in both modes.
* `byteverify SELFCHECK=1`: u2r **0 movers / 1358**, `PATH_SETS_IDENTICAL`;
  surelog **3 movers / 956**, `PATH_SETS_IDENTICAL`, all three named in advance.
* THE RUN-TIME A/B GATE, re-run with the FIXED binary in Earlgrey's own
  directory from its own two command lines:
  `R10E90_OFF=1` → `ded7aff7a3d0` / `8cfc4af7915b` (the pristine sweep's own
  hashes, byte for byte); law ON → `43a8d277a6fc` / `02496164d2f6` (the patched
  sweep's own). The fix changes nothing about Earlgrey — no `defparam` in it.
* `rowheads.sh` on both sweeps: `SeqDriver` 58/1, `SimpleUVM` 334/1,
  `Scoreboard` 334/1, `MiniAmiq` 58/1, `BuildUVMPkg` 83/1, `Rggen` 0/0 —
  **head logs BYTE-IDENTICAL before and after**; `Earlgrey_0_1` 15/1 → 110/1
  (default) and 15/1 → 142/1 (testflags), one head per run in every mode.
* **THE CORPUS CENSUS re-run end to end** with my own `ct90cen` build over my
  own two surelog sweeps, golden side ASSERTED UNCHANGED (all 277 `.gold` files
  byte-identical): `TS-MISSING-ELABHC` **18 → 0**, `TS-EXTRA` **0 → 0**,
  BOTH-SAME 215 411 → 215 429, MOVED-WRONG 1 197 → 1 179, `GOLDEN-ONLY` 4 922,
  `OURS-ONLY` 43 439, `TS-MISSING-ELSEWHERE` 174, `TS-KIND-DIFF` 87 all
  unchanged. **Only two `.ours` files of 277 changed** (both Earlgrey), by 6
  rows in default and 24 in testflags, every one a
  `SLOT=WIDTH SEL=indexed_part_select INHP=0 CTX=PORTHC PORTPAR=module_inst
  TS=- → TS=int_typespec (TSSG=1)` substitution and not one row of any other
  slot, sel, INHP, context or port parent.
* **THE WIDE BOUNDARY** (`vwide90.sh`, list on fd 3, children `</dev/null`,
  PROCESSED asserted): **LISTED = PROCESSED = 4071** (the implementer's 4067
  plus this directory's four arms), both views, both frozen binaries,
  workdir-normalised dump byte-compare — **identical 7768, DIFFERING 24,
  no_output 350**, rc histogram SYMMETRIC side for side (`rc=0` 7459/7459,
  `rc=3` 336/336, `rc=4` 333/333, `rc=139` 14/14 — 14 distinct files, each
  segfaulting on BOTH sides, all in the `--elabuhdm` view: the pre-existing
  family). The 24 are 8 of my arms + 8 of the implementer's + 6 earl47/65/70
  cells (all this law, all TO golden) + 2 `r10buvm22repro/g22.sv` cells that
  `R10E90_OFF=1` proves are NOT this law — see `SCORE.boundary_movers.txt`.

---

## 5. Files

| | |
|---|---|
| `v1_minus90.sv` … `v4_homes90.sv` | the four adversarial arms |
| `varm90.sh` | one arm → Surelog golden + both binaries × both views + `ct90cen --inst` |
| `tsonly90.py` | **the typespec-presence-only scorer** — the instrument that convicted the defparam hole where the whole-payload scorer only said `WRONG->OTHER` |
| `ctlarm90.sh` | the must-stay control battery over a list of committed arms |
| `score3_90.py`, `ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | copies of the campaign instruments this directory runs |
| `ARMS.r10v90.txt`, `CONTROLS.r10v90.txt`, `GATES.r10v90.txt`, `BOUNDARY_WIDE.*`, `SCORE.boundary_movers.txt` | the measurements |
| `BREAK.r10v90.txt` | the defparam break, verbatim: the golden cells, the slang source that hides it, the fix, and why the fix is depth-0 only |
| `RESIDUES.r10v90.txt` | the seven residues this verification measured and did not take |

Build the census tool the implementer's README documents; `varm90.sh` takes it
in `CEN90`.
