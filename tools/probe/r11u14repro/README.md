# r11u14 — an EvalFunc member LEFTOVER is the REDUCED body RHS, and the holder is not a field of it

§ `modEvalFuncLeftoverEnc`.  Everything here is MEASUREMENT-ONLY; the judge is
`uhdm-cmp` through `scripts/verify_golden.py`.  Base commit `401ed722`, pins per
`SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`, UHDM v1.87, Surelog v1.87,
uhdm2rtlil v0.68).

## 1. The producer, decoded

A member-by-member const struct builder leaves its member values behind as
`Actual_value` annotations on the SHARED struct typespec's `typespec_member`s —
the EVALFUNC LEFTOVERS.  UHDM v1.87 writes them in exactly two places, and both
write the SAME thing:

```cpp
// templates/ExprEval.cpp ~5671 (and the mirror at ~5360)
} else if (lhsexp->UhdmType() == uhdmhier_path) {
  expr *object = decodeHierPath(path, invalidValue, inst, lhsexp, MEMBER);
  if (object && object->UhdmType() == uhdmtypespec_member) {
    ((typespec_member *)object)->Actual_value(rhsexp);   // <-- the leftover
    return false;
  }
}
```

`rhsexp` is `reduceExpr(<the body assignment's RHS>)` (`evalStmt_`'s
`uhdmassignment` arm ~5898, and `setValueInInstance` reduces once more on entry).
**`setValueInInstance` never sees who holds the parameter.**  The leftover's
encoding is a property of the RHS SHAPE alone — the holder is not a field of it.
That is the whole law, and the golden grid below proves it cell by cell.

What `reduceExpr` returns, per shape:

| body RHS | what reduceExpr returns | the leftover therefore is |
|---|---|---|
| any LITERAL | the constant ITSELF | the body's own object, encoding intact |
| a CONCAT of constants | a FRESH constant: `BIN:<operand bits>`, `VpiSize(csize)`, `vpiBinaryConst` — **no `VpiDecompile`, no `Typespec`** (`vpiConcatOp` ~3993) | `csize` is the SUM OF THE OPERAND SIZES, never the member's width |
| a REPLICATION | a FRESH constant with the element's bits repeated, `VpiSize(n*width)`, **WITH `VpiDecompile(res)` and WITH a `ref_typespec -> int_typespec`** (`vpiMultiConcatOp` ~3908) | the element is always a CONCAT in the parse tree, so it reduces to BIN first and the multiconcat's `consttype` is always `vpiBinaryConst` |
| arithmetic / ternary / `$clog2` / `bit'()` | a fresh INT/UINT/BIN constant | § r10fsv2 L3's encodings |
| a WHOLE read of a formal / of a parameter | the caller argument's / that parameter's own object | its size and sign |

**THE TWO BAILS, modelled where the producer takes them.**  `vpiConcatOp` sets
`c1 = nullptr` — leaving the OPERATION itself as the leftover — when an operand
is not a constant, and when an operand is an `INT`/`UINT` constant at size 64 in
a MULTI-operand concat.  `vpiMultiConcatOp` clamps `n` to `[0,1000]` and gives up
unless it has exactly two operands.

## 2. The four candidates the brief named, RE-MEASURED on a pristine build

Pristine at `401ed722` (md5 `aa22f942076295f56fd20551df1ee939`, byte-identical to
the main tree's build), uhdm2rtlil 757 / 47 / 67 in BOTH modes.  One head each:

| test | head, re-measured | cluster |
|---|---|---|
| `struct_param_func_arg` | golden reuses the body's own `HEX:1000` size 64 ct 5 `64'h1000` object for `r.base = 64'h1000`; we mint `UINT:4096` size 64 ct 9 at the CALL span | **THIS FACE** |
| `struct_param_func_loop` | golden's concat-built leftover is `BIN` size 192 ct 3 with NO `vpiDecompile` and NO typespec; ours carries both | **THIS FACE** |
| `param_nested_struct_field_width` | head is `type_parameter work@dut.sel_t` missing `vpiLocalParam:1` | **NOT this face** — r11u9's R4 type_parameter single |
| `struct_param_field_shift` | head is a `ref_typespec -> int_typespec` on a call-ARGUMENT constant, `RHS: <null>` | **NOT this face** — r11u9's R4 call-arg formal typespec |

So the cluster is exactly TWO tests × two modes.  The other two moved at r11u13
without converting because r11u13 moved a DIFFERENT key on them; their heads were
never on this face.

## 3. THE GOLDEN GRID — 10 arms, every arm's rc recorded

`grid.sh` builds the Surelog golden and both binaries per arm.  All ten:
`slrc=0`, `[ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.  The arms are PAIRED — the odd
one a MODULE holder, its even twin the SAME builder with a PACKAGE holder — so
every cell is read across the holder split.

| arm | shape | golden, and what it pins |
|---|---|---|
| `c1` | six LITERAL shapes, MODULE holder | `32`→`UINT:32/64/32`; `64'h1000`→`HEX:1000/64/64'h1000`; `1'b1`→`BIN:1/1/1'b1`; `32'd64`→`DEC:64/32/32'd64`; `8'o17`→`OCT:17/8/8'o17`; `'1`→`BIN:1/**-1**/'1` |
| `c2` | `c1`'s PACKAGE twin | **every cell IDENTICAL to `c1`** — the holder is not a field of the leftover |
| `c3` | three CONCAT shapes, MODULE holder | `{64'h0,64'h8000,64'h1000}`→BIN size **192**; `{32'h1,32'h2}`→BIN size **64**; `{8'h1,8'h2}` into a **32-bit** member→BIN size **16** — the SUM OF THE OPERAND SIZES, never the member's width.  No decompile, no typespec on any of the three |
| `c4` | `c3`'s PACKAGE twin | **identical cells** |
| `c5` | REPLICATION, MODULE holder | `{16{64'h0}}` into a 1024-bit member→BIN size 1024 **with** decompile **and** a typespec; `{2{64'hff}}`→BIN size 128, same shape |
| `c6` | `c5`'s PACKAGE twin | **identical cells** |
| `c7` | arithmetic / `$clog2` / `bit'()` / whole param read, MODULE holder | `3*4`→`INT:12/64`; `PK+1`→`UINT:65/64`; `$clog2(64)`→`UINT:6/64`; `bit'(1)`→`BIN:1/1` empty decompile; `r.v = PK`→**`UINT:64` size 32**, the `int unsigned` localparam's own object |
| `c8` | `c7`'s PACKAGE twin | **identical cells; already CMP-equal on both binaries** (the landed package arm) |
| `c9` | `c1`'s BAIL twin (a member the builder never writes) + three NEGATIVE CONTROLS (a pattern-built struct localparam, an int localparam, a member select) | **databases BYTE-IDENTICAL** on both binaries |
| `c10` | the VIEW matrix on a MODULE holder: the `#(parameter …)` header form, two instances, a wildcard-importing module, a whole-struct re-pass into a function | five struct copies, every one stamped by golden |

**MEASUREMENT TRAP recorded.**  The first cut of `c1` named the function's local
`c` and the struct's third member `c`; `decodeHierPath` then resolved every
`c.<m>` write to the MEMBER named `c`, so golden stamped ONE member with the LAST
assignment's value and the assembler bailed.  An arm whose producer resolves
somewhere else teaches nothing about the law.  The arms name the local `r`.

**A SECOND TRAP, in the instrument.**  `leftcen.py`'s first cut counted the
uhdm-dump's BACKREFERENCES (an object is printed expanded once and as a bare
one-line backref afterwards) as real children, which read every struct copy twice
and every stamp as clean; and it rendered an ABSENT key and an UNSTAMPED member
identically, which made our module-view copies look unstamped when the dumper had
simply not re-expanded a SHARED object.  Both are fixed and documented in the
file.

## 4. The law

`src/ParamEmit.cpp` + two record fields and one declaration in
`include/UhdmExporter.h`.  Nothing else is touched.

1. **The `pkgHolder` fence comes off the LEFTOVER RESOLUTIONS.**  r11u9 recorded
   `litRhs` / `argWholeParam` / `paramRead` for every member but read them only
   from a PACKAGE-held stamp.  The producer has no such gate, and the grid's four
   holder pairs agree cell for cell, so the drain now resolves them for every
   stamp.  The param site's ASSEMBLE arms are untouched: `pkgHolder` still
   selects which of them runs.
2. **`catRhs` — the CONCAT / REPLICATION leftover.**  Recorded at the same place
   for a `Concatenation` or `Replication` body RHS, resolved in the drain by
   `memLeftReduceCat`, which is the producer's own reducer run over OUR OWN
   emitted body operation: it reads the operand objects' `VpiSize` /
   `VpiConstType`, takes the producer's two bails on exactly their conditions,
   and mints the constant the producer would.  Our emitted operation tree is
   structurally identical to golden's (opType 33/34, the same operand constants),
   so this is the producer's answer and not a re-derivation of it.
   * **The BITS are not re-computed.**  Every operand is a constant of exactly
     the size counted, so the LOW `csize` bits of the member's own folded slice
     ARE the concatenation.  A result WIDER than the member (an assignment that
     truncates) is outside that identity and bails to the old encoding.
3. **Nothing is minted on a bail.**  `memLeftReduceCat` returns null before it
   calls `MakeConstant`, so a bailing member keeps the value-slice encoding and
   no discarded object reaches the serializer (the r11u9 lesson).  `c9`, and 12
   of r11vu13's 13 arms, are BYTE-IDENTICAL.
4. **The replication's word-size `int_typespec` value is NOT written.**  The
   producer sets `VpiValue("UINT:<width>")` on it; `int_typespec::Compare` reads
   neither VpiValue nor a range, so writing it would move bytes the judge cannot
   see.  Recorded as a fidelity residue instead.

## 5. Instruments

* `predict.py <corpus-root> [names...]` — the A-PRIORI mover predictor, from the
  SOURCES alone.  Classifies every member write of every member-by-member
  builder as `LIT` / `CAT` / `REP` / `RD` and names the test when a shape this
  law moves is present.  Over-names by design (the sources cannot know whether
  the producer reduced or bailed).
  * REACH CONTROL: `testdirs()` WALKS (the r11u13 lesson) — 861 uhdm2rtlil test
    dirs, 700 Surelog suite dirs, 93 third-party dirs reached.
  * POSITIVE CONTROLS: `struct_param_func_arg` (`LIT:CFG.base`) and
    `struct_param_func_loop` (`CAT:CFG.base CAT:CFG.len`) are both named, and
    they are the ONLY two uhdm2rtlil names out of 861.
  * The Surelog names are `FuncStructVal`, `FuncStructValSimple` (suite) and
    `Ariane2024`, `Verilator` (third-party).
  * NEGATIVE CONTROLS, none named: `struct_param_func_config` (r11u13's
    conversion), `pkg_nested_struct_param_width`, `portsel_struct_param`,
    `def_ctx_struct_param`, `latch_decoder_partial`, `latch_tlb_napot`,
    `param_nested_struct_field_width`, `struct_param_field_shift`,
    `struct_member_cfg_width`, `cva6_struct_param_field`.
* `leftcen.py <gold.dump> [<a.dump> [<b.dump>]]` — THE LEFTOVER CENSUS, keyed
  `(section, struct_typespec name, copy ordinal, member name)` with the payload
  `constant::Compare` reads, UNCLIPPED (the r11vu13 clip trap), joined three ways
  and scored TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / SAME-WRONG / SAME-RIGHT.
* `subset.sh <griddir> <arm...>` — the ORDER-BLIND diff-line SUBSET check: every
  golden-vs-ours differing line the patched binary shows must ALREADY be in the
  pristine binary's set.  `NEW=0` is the strongest "moved only toward golden" a
  whole-dump census can state, and it is what convicts a head that MOVES to a new
  object (a cmp line count going UP proves nothing on its own).
* `grid.sh` — the golden grid driver (golden + both binaries per arm, every rc).
* `pacen.py` / `stamps.py` / `shapes.py` / `shapecmp.sh` / `dirscore.sh` /
  `arm.sh` carried from `r11u13repro`; `pacmp.py` / `rowcen.sh` / `dirline.sh`
  from `r11vu13repro`.  `shapes.py` is THE SHAPE LISTER, `dirscore.sh` the
  order-blind directional census.
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` — the current-generation battery.

RESULTS CSVs ARE NOT EDITED BY THIS PASS.

## 6. What moved

**NO CORPUS ROW CONVERTS.**  uhdm2rtlil stays **757 equal / 47 not-equal / 67
slang-reject in BOTH modes** and the Surelog suite stays **468/15 (default) and
464/13 (testflags)** — ZERO differing rows against the committed baselines AND
against this pass's own pristine sweeps, in either corpus, in either mode.

What moved is the HEAD of both named rows, and six ARMS convert:

* **`struct_param_func_arg` (both modes) — the family face CLEARS.**  Head
  before: golden's `HEX:1000` size 64 ct 5 leftover against our `UINT:4096` ct 9.
  Head after: `assign o_direct = CFG.n` — golden folds that continuous-assignment
  RHS to `BIN 32'b…11` ct 3 where we emit an unfolded `hier_path (CFG.n)`.  A
  different law, and the pass's R0.
* **`struct_param_func_loop` (both modes) — the same.**  Head before: the
  concat-built `BIN` 192 with our extra decompile and typespec.  Head after: the
  SAME `assign o_n = CFG.n` face.  One fix converts both rows.
* **Grid arms `c3`, `c4`, `c5`, `c6` CONVERT** (1 head → 0): the concat and
  replication leftovers, on both holders.
* **`r11u11repro`'s committed arms `a3` and `a5` CONVERT** (1 head → 0).
* **r11u13's R0 is CLOSED.**  Its arms `b1`/`b5`/`b6`/`b7` and r11v11u9's `g4`
  named "the replication-built 1024-bit `WIDE`: golden BIN at the member's width,
  ours the body object's `UINT:0` at 64" as the first head.  On all five that
  head is gone; `g4`'s `BIG` member now carries golden's exact 1024-bit BIN with
  its decompile and typespec where pristine had `UINT:0` size 64 wearing a
  309-digit decimal decompile.

`byteverify SELFCHECK=1`, Surelog suite, patched vs this pass's own pristine
workdir: **8 movers / 960** (selfcheck 959/960), and every one of the four NAMES
was predicted or is the proven coin family:

* `FuncStructVal` ×2 modes and `FuncStructValSimple` ×2 modes — both PREDICTED BY
  NAME (`LIT:CVA6Cfg.FETCH_WIDTH`), both **TO-GOLDEN** (6439→6431 and 275→267
  order-blind lines from golden, both modes), both still **CMP_EQUAL** with an
  identical dump column.  Attributed order-blind to exactly 8 lines of ONE class:
  the `cfg.FETCH_WIDTH = 32` leftover moves from a MINTED constant at the CALL
  span (`line:614:45` / `line:67:46`) to the SHARED body-literal object at the
  BODY span (`line:594:23` / `line:42:23`), and the minted
  `UINT:32 size 64 ct 9 dec 32` disappears.  All four compared fields are
  unchanged — this is the object-identity half of the law.
* `MiniAmiq` ×2 modes and `SeqDriver` ×2 modes — the **proven UVM coin family**.
  Attributed ORDER-BLIND to exactly 4 sorted-dump lines each, every one of the
  `UINT:<line>` / `vpiDecompile:<line>` LINE-NUMBER class (`UINT:1497`↔`UINT:0`,
  `UINT:864`↔`UINT:0`, `UINT:1288`↔`UINT:857`, `UINT:0`↔`UINT:1477`).
  **POSITIVE CONTROL, pristine alone:** the PRISTINE binary run TWICE on
  `MiniAmiq`'s own command line gives two DIFFERENT database md5s
  (`032abfe64fa2…` vs `d7ef8d3113db…`).  `SeqDriver`'s own command line names its
  sources relative to the TEST directory, so `arm.sh` cannot re-run it standalone
  (`rc=2`, `error: 'design.sv': No such file or directory`) — it is attributed by
  the NAME and the CLASS, never by the count, which is a per-run draw.
  `dirscore.sh` reads `MiniAmiq/tf` NEUTRAL and `SeqDriver/tf` "AWAY-GOLDEN by 6
  lines out of 486 684": that is the coin, not a mover.
* The predictor's two third-party names (`Ariane2024`, `Verilator`) build NO
  database on either binary in either mode.  The measured mover set is a proper
  SUBSET of the predicted set plus the coin family.

`byteverify SELFCHECK=1`, uhdm2rtlil, patched vs this pass's own pristine
workdir: **4 movers / 1608** (selfcheck 1607/1608 — the positive control that the
gate can see) — `struct_param_func_arg` and `struct_param_func_loop`, each in
both modes, and NOTHING ELSE.  Both were PREDICTED BY NAME by `predict.py` from
the sources before any patched sweep ran, and both are a proper subset of the
predicted set.  `dirscore.sh`: **4/4 TO-GOLDEN, 0 AWAY-GOLDEN, 0 NEUTRAL**
(`struct_param_func_arg` 247→225, `struct_param_func_loop` 461→429 order-blind
dump lines from golden, both modes).  `shapecmp.sh`: **0 rows GREW** a
shape-differing `param_assign` key.  `leftcen.py` on both rows, three-way:
every moved cell TO-GOLDEN, **AWAY-GOLDEN 0, MOVED-WRONG 0**.

`leftcen.py` across this pass's own grid: TO-GOLDEN `c1` 5, `c3` 3, `c4` 3,
`c5` 2, `c6` 2, `c10` 2 — **AWAY-GOLDEN 0, MOVED-WRONG 0 on every arm**, and
`c2`/`c7`/`c8`/`c9` byte-identical.  `shapes.py` across the grid: no arm GREW a
shape-differing `param_assign` key (`c9` stays at its 2, the bail residue).

**THE BOUNDARY over every committed arm of the family**, both binaries, order-
blind, `subset.sh`:

| arm set | result |
|---|---|
| this pass `c1`–`c10` | NEW-DIFF-LINES **0**, RESOLVED 174; 4 arms byte-identical |
| `r11u13repro` `b1`–`b9` | NEW **0**, RESOLVED 56; `b2`/`b3`/`b4`/`b8`/`b9` BYTE-IDENTICAL; `b1`/`b5`/`b6`/`b7` TO-GOLDEN |
| `r11vu13repro` `v1`–`v13` | NEW **0**, RESOLVED 23; **12 of 13 BYTE-IDENTICAL**, only `v7` (the MODULE holder) moves, TO-GOLDEN |
| `r11u11repro` `a1`–`a12` | NEW **0**, RESOLVED 131; `a3` and `a5` CONVERT; 5 byte-identical |
| `r11v11u9repro` `g1`–`g18`, `b2`, `b3` | 19 of 21 BYTE-IDENTICAL; `g4`, `g6m`, `g7` move, each TO-GOLDEN by the KEYED census and by distance (473→446, 524→510, 375→329).  `g6m`/`g7` show 3 and 1 "new" lines in the order-blind LINE multiset — the known family conflation (`dirline.sh`'s own caveat): the shared body object carries the BODY's span where the discarded mint carried the CALL's, so bare `\|vpiDecompile:1` lines re-pair across families.  The keyed census reads TO-GOLDEN 1 / 3 with AWAY 0 on both. |
| `r11v11u9repro` `b1` | EXCLUDED: `slrc=4`, `[ERROR] : 1` under the single-file driver (it is a multi-file arm with its own `vgrid.sh`) — an arm whose compile fails teaches error recovery, not golden |

## 7. Gates

| gate | result |
|---|---|
| pristine build md5 vs the main tree at `401ed722` | `aa22f942076295f56fd20551df1ee939` — BYTE-IDENTICAL |
| patched build md5 | `d84acd3f88dab953d1b7348d80682a2d` |
| `tests/check_goldens.sh` (patched) | 23 PASS / 0 FAIL |
| `SLANG_UHDM=/bin/false` negative control | 0 PASS / 23 FAIL |
| u2r testflags vs `results/gate_uhdm2rtlil.csv` | 0 differing rows |
| u2r default + testflags vs `results/golden_uhdm2rtlil.csv` | 0 differing rows |
| u2r patched vs this pass's own pristine sweep, both modes | 0 differing rows |
| surelog patched vs `results/golden_surelog.csv` | 468/15 (default) and 464/13 (testflags) — 0 status and 0 dump-column moves; 2 rows differ ONLY in the WORKDIR PATH inside a `SURELOG_FAIL` detail string (`LowMemLib`, `LowMemPkg`) |
| surelog patched vs this pass's own pristine sweep | same 2 workdir-path-only rows, nothing else |
| `byteverify SELFCHECK=1` u2r | 4 / 1608, selfcheck 1607/1608, both names predicted a priori, every moved key TO-GOLDEN |
| `byteverify SELFCHECK=1` surelog | 8 / 960, selfcheck 959/960 — 2 predicted names × 2 modes (TO-GOLDEN) and the 2 proven coin names × 2 modes |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS / PASS |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| HARD byte pins | `SVSwitch` 4842211c4030, `YosysVerx` 6ccda350c24a — both modes, both binaries |
| STATUS pins | `InterfaceModPort` 59a365f3ce2c, `BlackParrotComplex`, `YosysOldOr` — byte-identical pristine vs patched, both modes |
| `rowheads.sh` on the UVM / Earlgrey / Rggen rows | IDENTICAL pristine vs patched (12 measured, 2 SKIP-NOFILE as expected) |
| bail witnesses | `FuncStructVal` CMP_EQUAL, `FuncStructValSimple` CMP_EQUAL, `StructParamFuncBodyFieldCompare` CMP_NOTEQUAL head unmoved, `StructParamPatternInitCast` CMP_NOTEQUAL — all unchanged |
| fence check (the four slang-fenced tests) | 0 hits in the production diff; 0 hits anywhere in `tools/probe/r11u14repro/`; no driver dispatches them |
| the patch on a FRESH `401ed722` | `git apply --check` rc 0, 0 conflict markers, and the rebuild reproduces md5 `d84acd3f88dab953d1b7348d80682a2d` |
| `results/*.csv` | UNTOUCHED |

Every sweep exported `SLANG_UHDM` explicitly and every `cmds.txt` was audited by
BINARY PATH: `u2rp` 1742 rows and `slp` 1531 rows all on the pristine binary,
`u2rq` 1742 and `slq` 1531 all on the patched one, 0 rows on any other binary.

## 8. Residues, ranked

* **R0 — a MEMBER READ of a module-held assembled struct parameter in a
  CONTINUOUS ASSIGNMENT.**  `assign o_direct = CFG.n` is golden a `BIN` constant
  at the MEMBER's width (ct 3, carrying a `ref_typespec` to the member's own
  `int_typespec`) where we emit an unfolded `hier_path (CFG.n)`.  It is the head
  of BOTH `struct_param_func_arg` and `struct_param_func_loop` and of grid arm
  `c10`, so ONE fix converts TWO corpus rows in two modes.  This is the
  cont-assign face of the family r11u3's § `structParamMemberOvBinary` already
  models at the OVERRIDE site and r11u9's R0 names for the override actual;
  extending it is an ExprEmit law, not a ParamEmit one, and was deliberately left
  out of this pass's surface.
* **R1 — the assembler packs the LEFTOVER BITS, not the folded value.**  Grid
  `c1`/`c9`: with a size `-1` `'1` leftover and an 8-bit `8'o17` leftover
  assigned into a 4-bit and an 8-bit member, golden's assembled 141-bit constant
  is NOT slang's folded struct value — `assemble()` concatenates each leftover's
  own bit string at the member's declared width and the two disagree.  It is the
  head of `c1` and `c10` after this pass.  No corpus row carries the shape.
* **R2 — our leftover machinery declines a struct with an UNWRITTEN member.**
  Grid `c9`: golden stamps the six members the builder wrote and BAILS on the
  seventh; we record no stamp at all.  Carried unchanged from r11u13's R1 /
  r11u11's R5.  `FuncStructVal` is the corpus witness, CMP_EQUAL and
  byte-identical.
* **R3 — the MODULE holder's whole-parameter read.**  Grid `c7` `r.v = PK`:
  golden hands back the package `int unsigned` localparam's own `UINT:64` size
  **32** object; a module-held stamp finds no `elabParamConst` entry for it and
  keeps the size-64 slice.  The package holder resolves it (`c8` equal).  One
  registration, not a law.
* **R4 — the replication leftover's word-size `int_typespec`.**  The producer
  sets `VpiValue("UINT:<element width>")` on it; we mint the typespec bare.
  Judge-invisible (`int_typespec::Compare` reads neither), a fidelity residue
  only.
* **R5 — the SPAN of a shared body object.**  Unchanged in kind from r11vu13 §4:
  reusing the body's object also adopts the body's span, which is what golden
  does, so the residue is now on the discarded mint's side.  `constant::Compare`
  reads no file/line/column.
