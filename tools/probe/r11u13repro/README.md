# r11u13 — every site that reads an ASSEMBLED struct parameter WHOLE follows its encoding

§ `asmEncFollowsRef`.  Everything here is MEASUREMENT-ONLY; the judge is
`uhdm-cmp` through `scripts/verify_golden.py`.  Base commit `74a6bfa2`, pins per
`SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`, UHDM v1.87, Surelog v1.87,
uhdm2rtlil v0.68).

## 1. The producer, decoded

`ExprEval::reduceExpr`'s `uhdmstruct_var` arm (UHDM v1.87
`templates/ExprEval.cpp` ~4835) reduces a struct value computed by a
member-by-member const function to ONE packed `BIN` constant at the struct's
packed width, or BAILS and hands the `struct_var` straight back
(§ `pkgStructFuncAssembleBin` / § `modStructFuncAssembleBin` /
§ `pkgStructFuncAssembleBinBail` already model both halves).

What r11u11 left open is what happens AFTER that: Surelog never re-runs the
builder and never re-encodes the integer — every WHOLE read of such a parameter
is answered out of that constant's own `Value`, and the reading site only
re-renders the DECOMPILE.  Three sites inherit it and none did:

* **R1 — the default that reads the base whole.**  `parameter cfg_t Cfg = p::C`
  is the assembled constant in BOTH module views.
* **R2 — the override actual that is a bare reference.**  `child #(.Cfg(Cfg))`
  and `holder #(.H(p::C))` are that same BIN — the inheritance
  § `elabOvRefIntConst` already models for an INT-valued localparam, one
  encoding out.
* **R3 — the materialized import copy's view split.**  A module that imports the
  package materializes its own copy of the localparam; the DEF module listing
  keeps the assembler's BARE bits and every ELABORATED copy carries the `<w>'b`
  prefix `CompileHelper::adjustSize` renders.

**The decompile rule, measured on every arm of the grid:** bare in
`uhdmallPackages`/`uhdmtopPackages` and in `uhdmallModules`; `<w>'b`-prefixed in
`uhdmtopModules`.  Keyed on `defViewOrig9`, never on `topView` — the import-copy
law FORCES `topView` true for the DEF module listing too.

**The def listing resolves only across a SCOPE BOUNDARY.**  `uhdmallModules` is
written before instance elaboration, so a reference to a SIBLING parameter of the
same module is still symbolic there and golden keeps a bare `ref_obj`; a PACKAGE
localparam is already elaborated and golden carries the assembled constant.  Both
sides measured (grid `b3`/`b7` against `b1`/`b5`/`b6`/`b9`) — the ungated form
was AWAY-GOLDEN on exactly those two cells.

## 2. The corpus head, re-measured on a pristine build at this base

`struct_param_func_config` (uhdm2rtlil, both modes), pristine 1 head / 31 cmp
lines, field `decompile:`:

| key | golden | pristine |
|---|---|---|
| `uhdmallModules work@…_config.Cfg` | BIN size 66 ct 3, bare | **`func_call(build)`** |
| `uhdmtopModules work@…_config.Cfg` | BIN size 66 ct 3, `66'b…` | **`func_call(build)`** |
| `uhdmtopModules work@…_config.u_c.Cfg` | BIN size 66 ct 3, `66'b…` | **HEX `66'h1e0000000e` ct 5** |
| `uhdmtopModules work@…_config.{U,C}` | `34'b…` / `66'b…` | bare |
| `uhdmtopModules work@….u_c.{U,C}` | `34'b…` / `66'b…` | bare |

Seven param_assign keys, three sites, one row.

The other two candidates the brief named **do not cluster here** — re-measured,
their heads are a DIFFERENT law (the EvalFunc member LEFTOVER's own encoding on a
MODULE holder, which § `pkgStructFuncAssembleBin`'s literal/concat body-RHS reuse
covers only for a PACKAGE holder):

* `struct_param_func_arg` — head is the `c.base = 64'h1000` leftover: golden
  reuses the body's own `HEX 64'h1000` ct 5 object, we re-encode `UINT:4096` ct 9.
* `struct_param_func_loop` — head is the `c.base = {64'h0, 64'h8000, 64'h1000}`
  leftover: golden's BIN 192 carries NO `vpiDecompile` and no typespec, ours
  carries both.

Both are BYTE-IDENTICAL under this pass and stay CMP_NOTEQUAL.  Their heads are
R0 for a leftover-encoding pass, not for this one.

## 3. THE GOLDEN GRID — 9 arms, every arm's rc recorded

`grid.sh` builds golden + both binaries per arm and records `slrc`, the Surelog
`[ERROR]` count and each binary's rc.  All 9 arms: `slrc=0`, `[ERROR] : 0`,
`pris_rc=0`, `pat_rc=0`.  (`b3`/`b4` were re-cut after their first spelling
raised `[ERROR] : 2` — an arm whose compile fails teaches error recovery, not
golden.)

| arm | shape | what it pins |
|---|---|---|
| `b1` | PACKAGE base, ASSEMBLES, wildcard import; R1 + R2 + R2' + R3 | all three sites TO-GOLDEN |
| `b2` | `b1`'s BAIL twin (a member the builder never writes) | **BYTE-IDENTICAL** |
| `b3` | MODULE-held base, assembles; R1 + R2 | elab TO-GOLDEN, def view must stay `ref_obj` |
| `b4` | `b3`'s BAIL twin | **BYTE-IDENTICAL** |
| `b5` | `b1` with an EXPLICIT import | TO-GOLDEN, same as `b1` |
| `b6` | `b1` with NO import (qualified `p::C` only) | TO-GOLDEN; R3 has nothing to key on |
| `b7` | the CHAIN (`E = D = p::C`) and the RE-PASS (formal handed to a grandchild) | every hop TO-GOLDEN |
| `b8` | NEGATIVE CONTROLS on an assembled base | all four unchanged |
| `b9` | the VIEW matrix: one importing module instantiated TWICE | both instance copies prefixed |

`b8`'s four negative controls, all unchanged on both binaries: `n1` `.W(C.B)` — a
member SELECT — is § `memSelAsmBaseOv`'s and stays its answer; `n2`
`.H(cfg_t'(p::C))` — a CAST around the reference — stays the pre-existing
`UINT` against golden's operation; `n3` `.H(p::G)` on a base that is NOT
function-built stays untouched; `n4` `.W(p::N)` on an INT-valued localparam stays
§ `elabOvRefIntConst`'s.  The read must be a BARE reference and the base must be
function-built.

`b2` and `b4` are the law's floor: the producer BAILED, so not one field is
written, no object is minted, and the databases are byte-identical to the
pristine binary's.

## 4. The law

`src/ParamEmit.cpp` + two record structs and one predicate in
`include/UhdmExporter.h`.  Nothing else is touched.

1. `asmRefFamilyBase(e)` — the predicate.  Walk a chain of BARE parameter
   references (`NamedValue` / `HierarchicalValue`, packed-struct typed) down to
   the parameter whose own initializer is a `memLeftInitCall`, or give up.  An
   operation, a member select, a cast or a pattern around the read is a
   DIFFERENT site with its own law.
2. **R1 and R2 RECORD, they do not write.**  The producer's bail is only final in
   the drain — that is where BOTH assemble arms apply it — so the param site
   pushes `{pa, up, base, bits, width, view}` and the override site pushes
   `{constant, base}`.  Neither mints an object and neither writes a field.
3. **The drain** (`stampEvalFuncLeftovers`, after both assemble arms) reads the
   answer off the base itself: its elaborated `param_assign` Rhs is a
   `vpiBinaryConst` when it assembled and a `struct_var` when it did not.  R1
   then mints the constant and swaps the Rhs; R2 writes exactly the four fields
   `constant::Compare` reads (`VpiValue`, `VpiConstType`, `VpiSize`,
   `VpiDecompile`) over the constant the override pipeline already minted.  R1
   runs BEFORE R2 so a default that itself reads the family is already the
   assembled constant when the override reads it.
4. **R3 is one expression** at the § `pkgStructFuncAssembleBin` mint: the
   decompile is `<w>'b<bits>` when `!inPackage && !defViewOrig9`, bare otherwise.
5. **`elabParamConst` becomes FIRST-WRITER-WINS at that mint.**  The same
   parameter is materialized once per importing scope; golden's whole-read
   leftover is the PACKAGE's own object, the one whose decompile stays bare.
   While every copy carried identical fields the last writer was
   indistinguishable — R3's view split makes the copies differ, and the last
   writer stamped `34'b…` on `struct_param_func_config`'s `p::cfg_t.u` leftover
   where golden stamps the package's bare bits.  Measured: that was the row's
   second head, and `emplace` cleared it.

**Why deferred, and why R2 writes over an existing constant.**  A bail must leave
the database byte-identical (the r11u9 lesson: a minted-then-discarded object is
still serialized).  Writing the same four fields twice is not free either — the
discarded strings stay in the serializer's table and MOVE the database's bytes
while `uhdm-dump` and `uhdm-cmp` read identical (the r11u11 lesson) — so R2's
second write happens only on rows the drain actually re-keys, and those rows move
anyway.

## 5. Instruments

* `predict.py <corpus-root> [names...]` — the A-PRIORI mover predictor, from the
  SOURCES alone; tags each hit `R1:`/`R2:`/`R3:`.  It over-names by design (the
  sources cannot know whether the assembler bailed — that is what the drain
  decides), so the measured movers must be a SUBSET of what it names.
  * REACH CONTROL: `testdirs()` walks for `.sl` files on the Surelog suite (a
    one-level `listdir` sees NOTHING there and prints a green zero).  It reports
    709 test dirs under `Surelog/tests`, `FuncStructVal`,
    `FuncStructValSimple` and `StructParamFuncBodyFieldCompare` among them.
  * POSITIVE CONTROL: `struct_param_func_config` is named on ALL THREE tags — it
    is the row this pass converts, and it carries R1, R2 and R3 in one design.
  * NEGATIVE CONTROLS: it does NOT name `FuncStructVal` /
    `FuncStructValSimple` / `StructParamFuncBodyFieldCompare` (r11u11's
    conversion and its two bail witnesses — a MODULE holder read through a
    member select), nor `pkg_nested_struct_param_width` / `portsel_struct_param`
    (CMP_EQUAL at this base; the builder is there, the bare-reference read and
    the module-side import are not).
* `grid.sh` — the golden grid driver (golden + both binaries per arm, every rc).
* `pacen.py` / `stamps.py` / `shapes.py` / `shapecmp.sh` / `dirscore.sh` /
  `arm.sh` — carried from `tools/probe/r11u11repro`; `shapes.py` is THE SHAPE
  LISTER (the r11v7 lesson) and `dirscore.sh` the order-blind directional census.
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` — the current-generation canary
  battery.

RESULTS CSVs ARE NOT EDITED BY THIS PASS.

## 6. What moved

**THE ROW CONVERTS — one test, BOTH row-modes, CMP_NOTEQUAL → CMP_EQUAL:**

* **uhdm2rtlil, BOTH modes: `struct_param_func_config`.**
  **default 754 → 755 equal, 50 → 49 not-equal; testflags 754 → 755 equal,
  50 → 49 not-equal.**  One differing row in the whole-row CSV diff, quoted:

```
< struct_param_func_config,testflags,CMP_NOTEQUAL,decompile:,,
> struct_param_func_config,testflags,CMP_EQUAL,,,differ
< struct_param_func_config,default,CMP_NOTEQUAL,decompile:,,
> struct_param_func_config,default,CMP_EQUAL,,,differ
```

The Surelog suite keeps **468 / 15 (default) and 464 / 13 (testflags)** — no
status moves either way, against the committed baseline AND against this pass's
own pristine sweep.

`byteverify SELFCHECK=1` against this pass's own pristine workdirs:

* **uhdm2rtlil: 12 movers / 1608** (selfcheck 1607/1608) — SIX tests × two modes,
  every one of them PREDICTED BY NAME by `predict.py` before any patched sweep
  ran, and every moved param_assign key measured **TO-GOLDEN**, none AWAY:
  * `struct_param_func_config` — the law's own row, 7 keys, head 1 → 0 (R1+R2+R3).
  * `param_nested_struct_field_width` (`R1:CFG=CFG`) and
    `struct_param_field_shift` (`R1:Cfg=DefaultCfg`) — both module views of
    `work@dut.CFG` / `work@…_shift.Cfg` go `func_call` → the assembled BIN.  Head
    unchanged (their heads are elsewhere), still CMP_NOTEQUAL.
  * The predictor's seventh uhdm2rtlil name, `cva6_equiv`, is NOT a discovered
    sweep row (no `dut.sv` and no `project.f`), so it cannot move — the
    over-naming the predictor is built for.
  * `def_ctx_struct_param`, `latch_decoder_partial`, `latch_tlb_napot`
    (`R2:.Cfg(CfgDefault)`) — the override actual goes `UINT:<n>` ct 9 → the
    base's `34'b…` BIN ct 3.  **These three are the struct-CAST law a sister pass
    owns; this pass moves them TO-GOLDEN and leaves their heads untouched (head
    byte-for-byte identical before and after), so the two laws meet on
    `ParamEmit.cpp` and must be re-measured at integration.**
* **Surelog suite: 5 movers / 960** (selfcheck 959/960) — `MiniAmiq` ×2 modes,
  `SeqDriver` ×2 modes, `SimpleUVM` default: the **proven UVM coin family**, and
  nothing else.  Attributed ORDER-BLIND: each is exactly 8 sorted-dump lines, all
  of the LINE-NUMBER class (`UINT:<line>` / `vpiDecompile:<line>` pairs).
  * POSITIVE CONTROL, pristine alone: the PRISTINE binary run TWICE on the row's
    own command line already differs in bytes for both `MiniAmiq` and
    `SeqDriver`; `MiniAmiq`'s pristine-vs-pristine order-blind delta is the SAME
    8 lines of the SAME class, and `SeqDriver`'s is 0 lines (the pure list-ORDER
    flip) — the count is a per-run draw, so the CLASS and the NAMES are the law,
    never the count.
  * The predictor's two Surelog names (`Ariane2024`, `Verilator`) are
    `SLANG_REJECT` / `NO_DATABASE` on both binaries and both modes — they build
    no database and cannot move.  The measured mover set is a proper SUBSET of
    the predicted set.

THE BAIL WITNESSES STAND, all BYTE-IDENTICAL on both modes: `FuncStructVal`
(CMP_EQUAL), `StructParamFuncBodyFieldCompare` (CMP_NOTEQUAL, head unmoved), and
r11u11's conversion `FuncStructValSimple` (CMP_EQUAL).  So do
`pkg_nested_struct_param_width` and `portsel_struct_param` (CMP_EQUAL,
byte-identical), and `cva6_struct_param_field`, `struct_member_cfg_width`,
`struct_param_func_arg`, `struct_param_func_loop` (byte-identical).

`shapes.py` across the grid — SHAPE-differing `param_assign` keys, pristine →
patched: `b1` 2→0, `b3` 1→0, `b5` 2→0, `b6` 2→0, `b7` 3→0, `b9` 4→0;
`b2` 10→10, `b4` 4→4 (the BAIL twins), `b8` 1→1 (the negative controls).
**ZERO arms GREW a shape-differing key.**

## 7. Gates

| gate | result |
|---|---|
| pristine build md5 vs the main tree at `74a6bfa2` | `2ca79fb72247897ddc2983a1dc40696f` — BYTE-IDENTICAL |
| `tests/check_goldens.sh` (patched) | 23 PASS / 0 FAIL |
| `SLANG_UHDM=/bin/false` negative control | 0 PASS / 23 FAIL |
| u2r `ct8rows` vs `results/gate_uhdm2rtlil.csv` | 1 differing row, quoted above |
| u2r default vs `results/golden_uhdm2rtlil.csv` | 1 differing row, quoted above |
| surelog `ct8rows` patched vs this pass's pristine | 0 status/dump moves (2 rows differ only in the WORKDIR PATH inside a `SURELOG_FAIL` detail string: `LowMemLib`, `LowMemPkg`) |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS / PASS |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| HARD byte pins | `SVSwitch` 4842211c4030, `YosysVerx` 6ccda350c24a — both modes |
| STATUS pins | `InterfaceModPort` 59a365f3ce2c, `BlackParrotComplex`, `YosysOldOr` — all SAME |
| fence check (UnsignedParam/HierPathEval/FileLocalParam/TopParam) | 0 hits in the source diff |

Every sweep exported `SLANG_UHDM` explicitly and every `cmds.txt` was audited by
BINARY PATH: `u2rp`/`slp` 1742/960 rows all `/tmp/r11u13_pris.bin`, `u2rq`/`slq`
all `/tmp/r11u13_pat.bin`.

## 8. Residues, ranked

* **R0 — the EvalFunc member LEFTOVER's own encoding on a MODULE holder.**  The
  head of `struct_param_func_arg` (golden reuses the body's own `HEX 64'h1000`
  ct 5 object, we re-encode `UINT:4096` ct 9) and of `struct_param_func_loop`
  (golden's concat-built BIN 192 carries NO `vpiDecompile` and no typespec, ours
  carries both), and the first head of grid arms `b1`/`b5`/`b6`/`b7` (the
  replication-built 1024-bit `WIDE`: golden BIN at the MEMBER's width, ours the
  body object's `UINT:0` at 64).  § `pkgStructFuncAssembleBin` already reuses the
  literal/concat body RHS for a PACKAGE holder and is deliberately fenced off the
  MODULE holder; the rule that decides which shape re-encodes and which is reused
  is the next thing to decode.  Identical on both binaries.
* **R1 — our leftover machinery declines a struct with an UNWRITTEN member.**
  Grid `b2`/`b4`: golden stamps the members the builder wrote and BAILS; we
  record no stamp at all, so every read falls through to the decimal arms.
  Carried unchanged from r11u11's R5.
* **R2 — the CAST around a family reference.**  Grid `b8` `n2`:
  `.H(cfg_t'(p::C))` is golden an OPERATION where we fold `UINT`.  Identical on
  both binaries; a cast is not a bare reference and this law leaves it alone.
* **R3 — the def listing's IMPORT COPY value.**  Grid `b1`/`b5`/`b7`/`b9`:
  `uhdmallModules work@top.C` is golden the assembled BIN where we fold
  `INT:0` / `INT:<n>` at struct width.  Unchanged by this pass (its decompile
  view split is R3's, its VALUE is not) and identical on both binaries.
