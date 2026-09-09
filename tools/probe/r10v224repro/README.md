# r10v224 — adversarial verification of r10uvm224

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's report
reproduces bit-for-bit from binaries this verifier built itself. Twelve
adversarial arms found **one judge-visible field-level AWAY move** — the
`array_net` inner element net's `vpiNetType` on a STRUCT-typedef fixed unpacked
array — and it is fixed here in three lines, at **zero corpus cost** (byteverify
fixed-vs-patched MOVERS 0/956 and 0/1358). Ship
`/tmp/r10uvm224.verified.patch`.

Base commit `e492c4e0`. Worktrees `/tmp/wt_v224` (patch + fix) and
`/tmp/wt_v224pris` (pristine), both fresh at `e492c4e0`.

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Built both binaries from fresh worktrees, `-j 2`, md5 taken separately:

```
pristine  3a8d774326e1c5523f420e7d50fc41cc   (= the implementer's, and the main tree's)
patched   17b6dd3053db12a075388c3a51b5efed   (= the implementer's)
fixed     3ad9d8ded7c3ee0e406d779170eb73a8   (this verifier's, +3 lines)
```

Binary size delta patched−pristine = **+184 bytes**, as reported.

| claim | reproduced |
|---|---|
| goldens 23/0, `/bin/false` 0/23 | YES, on pristine, patched and fixed |
| uhdm2rtlil 679/50/2 both modes | YES, all three binaries |
| u2r ct8rows vs baseline + both controls | YES, **0 differing rows** of 731 |
| u2r byteverify | YES, **MOVERS 0/1358** |
| surelog 476/5 + 470/5 over 1588 row-modes | YES, all three binaries |
| surelog byteverify | YES, **MOVERS 3/956** — MiniAmiq ×2 + Scoreboard/default |
| MiniAmiq attribution 33 lines, order-blind, all the law's | YES, both modes, identical |
| Scoreboard/default 92 raw / **0 order-blind** | YES, exactly the recorded coin |
| grid 142 → 79 cells wrong | YES, cell for cell |
| head: pristine 17/1 → patched 713053/1, both modes | YES, and the head OBJECT changed as described |
| the nine converted row-modes + Rggen/default at 0/0 rc=0 | YES |
| canaries u2r 8/0, ctcan2 both PASS, canaudit 29/0/0 | YES |
| protected DBs SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | YES |
| InterfaceModPort byte-identical | YES, and measured FIRST (§4) |
| boundary LISTED = PROCESSED, RC_DIFFS 0, 19 non-verifier sources | YES, the same 19 |
| the 4 TOWARD-golden arms' cmp line counts | YES, all eight numbers exactly |
| the 3 static-address false movers | YES, re-proved on all four tells |

Two headline numbers are **OVERSTATED, not wrong** — see §5.

---

## 2. THE DEFECT, AND THE FIX

### 2.1 The blind spot

`netcen224.py`, the pass's own scorer, records an `array_net`'s inner element
net as `inner_ts=<typespec>` and **nothing else**. `nets::Compare` reads
`VpiNetType` (`UHDM/build/generated/src/nets.cpp:277`, on the `logic_net → net →
nets` chain), so that field is **judge-visible** and a grid blind to it can
report `AWAY 0` while a cell moves away on it. `innernt224.py` here reads it.

### 2.2 The cell

In `emitInterfaceDef` the patch routes a stripped base net's array_net inner
element net down a new branch that stamps `VpiNetType(36)` unconditionally. The
pristine build reached that net through `structElemTs`, which stamps NO net type
for a struct element. Measured on golden (arms `v6_structarr`, `v12_innernt`,
instantiated and uninstantiated alike):

```
                                     golden      pristine     patched
sp6_t  arr [1:0]   (packed struct)   ts none     ts struct    ts none
                   netType           none        none         36   <-- AWAY
su6_t  arr [1:0]   (unpacked struct) netType     none        none  36   <-- AWAY
tv6_t  arr [1:0]   (plain typedef)   netType     none        36    36   (pre-existing)
int    arr [1:0]                     netType     none        36    36   (pre-existing)
```

Field-level census over all 27 arms (15 the implementer's + 12 mine):

```
PRIS -> PAT   fields same=16 fixed=17 still-wrong=169 AWAY=4
PRIS -> FIX   fields same=20 fixed=17 still-wrong=169 AWAY=0
```

The four AWAY fields are the four struct-element cells. Note the CELL was wrong
on both binaries (pristine on the typespec, patched on the net type), so a
per-cell scorer reports "still-wrong" twice and AWAY 0 — which is exactly what
the pass's grid reported. The move is real and it is at field granularity.

### 2.3 The fix

`src/ModuleEmit.cpp`, in the `omitTs224` branch of the interface array_net:

```cpp
if (omitTs224) {
    if (!structElemTs(*it.sym))
        in9->VpiNetType(36);
}
```

Three lines. It restores pristine's exact answer on that field for the struct
form and changes nothing else. **Cost, measured, not asserted:** byteverify
fixed-vs-patched reads **MOVERS 0/956** on surelog and **0/1358** on
uhdm2rtlil — the fix is corpus-neutral, so every one of the pass's gate numbers
carries over verbatim, and the boundary fixed-vs-patched confirms it arm by arm.

---

## 3. TWELVE ADVERSARIAL ARMS (`vgrid224/`)

Every arm compiled with the canonical golden-side Surelog and with each binary;
every rc recorded on both sides, **all zero**. Cells wrong **86 → 39**, no arm
worse.

| arm | what it attacks | result |
|---|---|---|
| `v1_tdhide` | a typedef HIDING the unpacked dimension (`typedef t aa_t [string]; aa_t x;`) — the predicate walks the CANONICAL type, the law was measured over WRITTEN dimensions | **UNREACHABLE**: slang-uhdm REJECTS a typedef whose target is an Associative/DynamicArrayType (rc=4, on the pristine binary too). The fixed alias is kept and scores 7 → 2 |
| `v2_clsidx` | associative INDEX types never measured: a CLASS handle, `[bit[7:0]]`, `[logic[3:0]]`, `[byte]`, `[shortint]`, `[integer]` | every built-in and packed index: reprieve CORRECT (golden keeps). **CLASS index: golden DROPS, the predicate keeps** — STILL-WRONG, not a regression (pristine kept it too). See R-A |
| `v3_tdstr` | an index written as a typedef OF a builtin (`typedef string s_t; t x [s_t]`), local and package | correct: TypeAlias index drops, 8 → 4 |
| `v4_chain` | mixed chains `[t][string]`, `[][string]`, `[$][string]`, `[string][t]`, `[2][2][string]` | correct in every position, 7 → 4 |
| `v5_explport` | the two clauses that do NOT ask about the header form — the EXPLICIT-port net and `hasBareImplicitType` — now firing on an ANSI-header interface | golden AGREES with both; 4 → 2, two def-view cells TO-GOLDEN |
| `v6_structarr` | a fixed unpacked array of a struct typedef, imported bare and package-qualified | the AWAY cell (§2). Cells 6 → 0 by the pass's scorer |
| `v7_inst` | the ELABORATED view of an instantiated interface | unmoved; the law is definition-view only. 9 → 4 |
| `v8_modport` | a MODPORT interface (the InterfaceModPort shape) | 6 → 4, no modport object moved |
| `v9_pkgprog` | PACKAGE data and the refuted PROGRAM road | package untouched; **the program's `[string]` net went TO GOLDEN** — an independent corroboration of the associative reprieve on the module/program road. 5 → 4 |
| `v10_nonansi` | the reprieve under a GENUINE non-ANSI interface port list (the pass measured it under empty parens) | correct, 7 → 2 |
| `v11_multiinst` | one definition, THREE instances, one of them in a generate block | the definition answers the law once; all three elaborated views unmoved. 8 → 4 |
| `v12_innernt` | the inner element net's `vpiNetType`, instantiated vs not | the AWAY cell (§2), and golden's own shape recorded for R0 |

Plus a **Verilog-lex-mode** arm (a `.v` root file, non-ANSI module,
`logic x [string];`) run outside the grid: golden KEEPS the typespec, pristine
dropped it, **patched keeps it** — the associative reprieve is right on the
`vlogUnresolvedLogicNet` road too, which the pass did not measure.

---

## 4. THE u2r ZERO, PROVEN STRUCTURALLY

The implementer proved it with an instrumented predictor binary. This verifier
proves it from the SOURCES, independently, and the two agree:

* Across the whole uhdm2rtlil corpus there are **48 interface declarations and
  not one has an empty-parens or a genuine non-ANSI port list**. All 15 that a
  crude header regex flags are `#(parameter …)` parameter port lists with NO
  port parens at all (`interface tif #(parameter tpkg::cfg_t CFG = …);`) —
  a NO-PARENS header, which KEEPS. Every net in them is a builtin
  `logic [WIDTH-1:0]`.
* The corpus contains **zero associative-array declarations**, so the module
  road's new reprieve reaches nothing either.
* byteverify then measured **MOVERS 0/1358** for patched and for fixed.

`InterfaceModPort` was measured FIRST, as the brief requires: `top.v` declares
`interface mem_interface(input bit clock)` and `interface mem_if (input wire
clk)` — ANSI headers both — and every net is a builtin `wire`/`logic [7:0]`
with no unpacked dimension. The law cannot reach it, and its database is
byte-identical on all three binaries in both modes.

---

## 5. TWO OVERSTATED HEADLINES (not defects of the patch)

1. **"surelog ct8rows zero differing rows against the committed baseline
   outright."** Not a property — a draw. `Earlgrey_0_1`'s DUMP column is the
   recorded timeout artifact and it flips run to run:

   ```
   committed baseline vs MY PATCHED sweep    2 differing rows (Earlgrey ×2, dump col)
   committed baseline vs MY PRISTINE control 1 differing row  (Earlgrey/testflags)
   committed baseline vs MY FIXED sweep      0 differing rows
   ```

   The STATUS is `CMP_EQUAL` in every cell of every run, and the databases are
   **byte-identical** (`8c2ba25c4d7f` default, `92bf7b7facdc` testflags, on
   pristine, patched and fixed alike; Earlgrey is not among the byteverify
   movers). The standing rules anticipate exactly this and say to prove the
   database byte-identical instead — which is done. The correct claim is "0
   differing STATUS rows over 1588; the two Earlgrey dump-column cells are the
   recorded artifact, databases proved identical."

2. **"canaries 52 changed=0."** Same cause: my patched sweep reads `ok=50
   changed=2` and my PRISTINE control reads `ok=51 changed=1`, and both changed
   rows are `Earlgrey_0_1 … CMP_EQUAL/differ -> CMP_EQUAL/`. The fixed sweep
   drew `ok=52 changed=0`. No canary STATUS moved in any run.

Neither affects the verdict: no status regressed anywhere, on any binary, in
either corpus.

---

## 6. RANKED RESIDUES THIS VERIFICATION ADDS

* **R-A — THE ASSOCIATIVE REPRIEVE OVER-FIRES ON A CLASS-TYPED INDEX.**
  `assocBuiltinIndexDim224` reprieves any index whose type is not a
  `TypeAlias`; a class handle is a legal associative index and is not a
  TypeAlias, so `tv2_t x [Cv2_224];` keeps its typespec and **golden drops it**
  (arm `v2_clsidx`). Pristine kept it too, so this is STILL-WRONG, not a
  regression — but the law as written is one predicate wider than golden. The
  measured boundary of the reprieve is: keep for `string`/`int`/`logic`/`bit`/
  `byte`/`shortint`/`integer`/`bit[7:0]`/`logic[3:0]`/`[*]`; drop for every
  named index, **class handles included**. Cheap to land with R0.
* **R-B — THE INNER ELEMENT NET'S `vpiNetType` IS ONLY HALF DECODED.** After
  the fix we match golden on the struct form and are still wrong on the plain
  ones: golden emits NO `vpiNetType` on a def-view inner net in an
  UNINSTANTIATED interface but emits `36` on a bare-typedef element in an
  INSTANTIATED one (`v12_innernt`: `vi_tdarr224` 36, `vc_tdarr224` none, same
  declaration, same header). We emit `36` in both. 5 fields per arm across the
  grid. It belongs to R0's `Array_nets()` law, which rewrites that branch.
* **R-C — `netcen224.py` IS BLIND TO THE INNER NET'S NET TYPE.** The successor
  must not re-use it unmodified to score R0's array_net law: use
  `innernt224.py` beside it, or the same class of AWAY move will score as SAME
  again.
* **R-D — A TYPEDEF WHOSE TARGET IS AN ASSOCIATIVE OR DYNAMIC ARRAY IS A
  SLANG_REJECT.** `typedef t aa_t [string];` makes slang-uhdm exit 4 with
  "unsupported constructs: typedef target: AssociativeArrayType". That is why
  the canonical-type walk in `assocBuiltinIndexDim224` cannot be attacked
  through an alias today — and it is a standing fence the successor should not
  assume will hold if that reject is ever lifted.

The implementer's own R0–R7 all stand as written; R0 (the interface
definition's `Array_nets()`, golden 5 / ours 0, plus its `Process`) is
confirmed as the head on both modes from this verifier's own `rowheads.sh` run.

---

## 7. FILES

* `vgrid224/` — the twelve adversarial arms (`v1_tdhide` … `v12_innernt`).
* `innernt224.py` — the inner-element-net field scorer (`vpiNetType` +
  `vpiTypespec`, scored PER FIELD, richest occurrence per fullname).
* `VGRID.score.r10v224.txt` — the twelve arms scored three ways with every rc.
* `INNERNT.pris_vs_pat.r10v224.txt`, `INNERNT.pris_vs_fix.r10v224.txt` — the
  field census that convicts and then clears the AWAY move.
* `BOUNDARY.pris_vs_pat.r10v224.txt`,
  `BOUNDARY.pat_vs_fix.r10v224.txt` — this verifier's own wide boundaries.
* `VERIFIED.r10uvm224.txt` — the whole gate battery as this verifier ran it.
