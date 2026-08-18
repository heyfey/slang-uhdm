# r10rgg18 — § genLpFoldDigitsMathValue18: a gen-scope localparam fold's DIGITS are the MATHEMATICAL fold value, not the signed reading of the truncated bits

**MEASUREMENT-ONLY directory.**  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `944257e`.**  `results/*.csv` was READ ONLY and is untouched — the
master promotes rows, not this pass.

**RESULT: `default:Rggen` CONVERTS — `CMP_NOTEQUAL` → `CMP_EQUAL`.**
Rggen has ONE comparable mode (default) and it now passes the official
`uhdm-cmp`: 0 cmp lines, 0 heads, `cmp rc=0`.  The row is quoted in § 7; this
directory does NOT edit `results/golden_surelog.csv`.

The production change is TWO CALL SITES in `src/ModuleEmit.cpp` — the same two
carriers § genLpFoldSignedStructural46 (r10earl46) owns — plus one `__int128`
decimal helper.  Everything else here is instrument or evidence.

---

## 1. THE HEAD, decoded from the PRISTINE cmp LOG and the GENERATED Compare

`HEAD_R0_BEFORE_default_Rggen.cmp` is the verbatim pristine log and is
BYTE-IDENTICAL to r10rgg17's committed `HEAD_R0_AFTER_default_Rggen.cmp`, so
this pass starts on exactly the object rgg17 named as R0 (and rgg16 as R-B).
LHS is ALWAYS golden.

Read the generated `Compare` order before naming the field:

```c++
// UHDM/build/generated/src/expr.cpp:83
int32_t expr::Compare(...) {
  basetype_t::Compare(...)                       // VpiType/VpiName/VpiDefName
  lhs->VpiDecompile().compare(rhs->VpiDecompile())   // <-- FIRST
  lhs->VpiSize() - rhs->VpiSize()
  SafeCompare(lhs->Typespec(), rhs->Typespec(), ...)
}
// UHDM/build/generated/src/constant.cpp:58
int32_t constant::Compare(...) {
  basetype_t::Compare(...)                       // = expr::Compare above
  lhs->VpiConstType() - rhs->VpiConstType()
}
```

So the failing field is **`vpiDecompile`, and nothing else is even reached**:
`VpiSize` (7 = 7), the `Typespec` chain (ref_typespec → the declaration's
`bit_typespec` 33:19-33:42 on both sides) and `VpiConstType` (9 = 9) all
agree.  `vpiValue` is **not compared at all** — it is in the dump because
`uhdm-dump` prints it, not because the judge reads it.

```
LHS (golden)                                  RHS (ours)
constant 33:59-34:93                          constant 33:59-34:93
|vpiDecompile:64                              |vpiDecompile:-64
|vpiSize:7                                    |vpiSize:7
|UINT:64                                      |UINT:0
|vpiConstType:9                               |vpiConstType:9
```

The object is the `Rhs` of the `param_assign` at
`rggen-sv-rtl/rggen_register_common.sv:33:43-34:93`:

```systemverilog
for (g = 0;g < WORDS;++g) begin : g_decoder
  localparam  bit [ADDRESS_WIDTH-1:0] START_ADDRESS = OFFSET_ADDRESS
                                                    + ADDRESS_WIDTH'(BUS_BYTE_WIDTH * g);
```

in the instance
`work@rggen.u_block_1.g_register_file_2.g[1].g_register_file_0.g_register_0.g[0].g[0].u_register.u_register_common.g_decoder[0]`,
where `ADDRESS_WIDTH` is 7 and `OFFSET_ADDRESS` is 64 — **the MSB of the
declared 7-bit width is set**.

**`UINT:0` is not a second, independent divergence — it is the SAME string.**
Our emitter writes the value string `"UINT:" + sd` with `sd = "-64"`; UHDM's
`String2VpiValue` (`UHDM/templates/vpi_user.cpp:81-86`) parses the digits of a
`UINT:` value with `NumUtils::parseUint64` and, when that refuses, **stores 0**.
So one wrong `sd` produces both `vpiDecompile:-64` and `UINT:0`.  Masking
`sd` to `"64"` in a copy makes the whole database cmp-equal (§ 7) — there is
no second field behind this one.

---

## 2. THE CENSUS: every `param_assign` in Rggen, both views

`pacensus18.cpp` (built by `build18.sh`, UHDM linked STATICALLY out of
`~/.local` so it reads exactly the databases the sweeps wrote) enumerates every
`param_assign` through `UhdmListener::listenDesign` — the REACHABLE walk
`uhdm-dump` makes.  `Serializer::AllObjects()` is used ONLY to count the
weakly-referenced tail (RESUME §9): on Rggen it holds **479** of our
param_assigns, which a census over `AllObjects` would have manufactured as
"ours-only" keys.

Key = (root — which separates the DEF listing from the ELABORATED one without
trusting a path string, nearest named scope, the Lhs parameter's name, the
param_assign span).  Payload = the Compare-visible fields of the Rhs and of the
Lhs parameter, plus the DECLARED TYPE rendered from the typespec
(`bit/logic/int/integer/byte` + signedness + the declared range).
`census18join.py` joins the two sides as MULTISETS (keys collide by design —
one span per gen-scope unrolling — and a last-writer dict drops rows).

**Calibration first**: golden-vs-golden is the identity join by construction
here (the same file), and the cross-side reach is stated on every run
(`param_assigns_reachable` / `arena` / `unreachable_tail`).

| Rggen/default | keys G | keys O | shared | **differing** | gold-only | ours-only |
|---|---|---|---|---|---|---|
| BASE `944257e`  | 7552 | 7279 | 7275 | **10** | 68 | 0 |
| PATCHED         | 7552 | 7279 | 7275 | **3**  | 68 | 0 |

The **7** keys that went TO GOLDEN are the whole family, and they are exactly
the seven `START_ADDRESS` instances — one per `rggen_register_common`
instantiation, each with its own `OFFSET_ADDRESS`:

```
golden UINT:64  UINT:68  UINT:72  UINT:76  UINT:80  UINT:84  UINT:88   (sz 7, ct 9)
base   UINT:-64 UINT:-60 UINT:-56 UINT:-52 UINT:-48 UINT:-44 UINT:-40  (sz 7, ct 9)
patch  UINT:64  UINT:68  UINT:72  UINT:76  UINT:80  UINT:84  UINT:88   <- TO GOLDEN
```

`64 = -64 + 128`, `68 = -60 + 128`, … — every one is the same 7-bit word read
UNSIGNED instead of SIGNED.  **0 AWAY-GOLDEN, 0 STILL-differing in the family.**

The **3** that remain are one shape and are NOT judge-visible: golden carries
`vpiValue` on the `parameter` object of `rggen_adapter_common.STATUS_WIDTH`
where we leave it empty.  `parameter::Compare` does not read `VpiValue`, which
is why Rggen is cmp-equal with those three still in the census.  Recorded as a
residue, not as a defect of this law.

---

## 3. THE GOLDEN GRID — what Surelog actually writes

`cells/a1/a1_rgg18.sv` (17 gen-scope rows x 2 unrollings, with a MODULE-SCOPE
twin of seven of them as the control) and `cells/b1/b1_rgg18.v` (3 rows x
1..3 unrollings x 1..3 instances of the containing module, written as `.v` so
the language-flag axis is crossed too).  `cell18.sh` runs Surelog exactly as
`scripts/verify_golden.py`'s DEFAULT mode does
(`-parse -nobuiltin -nocache -sv <srcs> -mt 0 -mp 0 -o <work>`), then our
binary, then the census on both.  Every row below is golden's ELAB **and** DEF
answer — the two views agree on every cell of both grids.

| row | declaration | initializer | fold | **golden** |
|---|---|---|---|---|
| A  | `bit [6:0]`        | `OFF + 7'(BW*g)`        | 64 / 68   | `UINT:64` / `UINT:68`, sz 7, ct 9 |
| B  | `bit signed [6:0]` | `OFF + 7'(BW*g)`        | 64 / 68   | `UINT:64` / `UINT:68`, ct 9 |
| C  | `int`              | `OFF + 7'(BW*g)`        | 64 / 68   | `UINT:64`, sz 32, ct 9 |
| D  | `bit [7:0]`        | `8'hC0 + 8'(g)`         | 192 / 193 | `UINT:192` / `UINT:193` |
| J  | `logic [7:0]`      | `8'hC0 + 8'(g)`         | 192 / 193 | `UINT:192` / `UINT:193` |
| E  | `byte`             | `8'hC0 + 8'(g)`         | 192 / 193 | `UINT:192` / `UINT:193` |
| K  | `bit [3:0]`        | `4'hC + 4'(g)`          | 12 / 13   | `UINT:12` / `UINT:13` |
| H  | `bit [63:0]`       | `64'hC000…0 + 64'(g)`   | 2^63+2^62 | `UINT:13835058055282163712`, sz 64 |
| P  | UNTYPED            | `OFF + 7'(BW*g)`        | 64 / 68   | `UINT:64`, sz 32 |
| L  | `integer`          | `-1 - g`                | -1 / -2   | `INT:-1` / `INT:-2`, ct 7 |
| N  | `bit [6:0]`        | `0 - 7'd64 + g`         | -64 / -63 | `INT:-64` / `INT:-63` |
| M  | `bit [6:0]`        | `7'h40 * 1 + g`         | 64 / 65   | `INT:64` / `INT:65` |
| F  | `bit [6:0]`        | `OFF + 7'd64`           | **128**   | `INT:128`, **sz 7** |
| G1 | `bit [6:0]`        | `OFF + 7'(BW*g) + 7'd60`| 124 / 128 | `INT:124` / `INT:128`, sz 7 |
| S  | `[6:0]` (b1)       | `0 - 1 + 65*g`          | -1/64/129 | `INT:-1` / `INT:64` / `INT:129` |
| U  | `[6:0]` (b1)       | `BASE + 7'(4*g)`        | 64…80     | `UINT:64` … `UINT:80` over 6 gen instances in 3 module instances |
| T  | `signed [6:0]` (b1)| `BASE + 7'(4*g)`        | 64…80     | `UINT:64` … `UINT:80` |
| I  | `bit [64:0]`       | `65'h1_0000…0 + 65'(g)` | > 64 bits | **golden does NOT fold it at all** — the Rhs stays an `operation` |

**THE RULE, stated exactly.**

1. **The DIGITS are the decimal of the MATHEMATICAL fold value, with its own
   sign, computed BEFORE any truncation to the declared width.**
   * The declared type's SIGNEDNESS is irrelevant: `bit signed [6:0]` (B) and
     `byte` (E) print the same unsigned digits as their unsigned twins.
   * The declared WIDTH does not truncate the digits: F and G1 print **128** at
     `vpiSize` 7, and b1's S prints **129** at `vpiSize` 7.
   * The PREFIX does not decide the sign of the digits either: b1's S has a
     NEGATIVE SIBLING (`gs[0]` = -1) so the whole gen array takes the `INT`
     prefix, and `gs[1]` still prints **`INT:64`** — an INT prefix with
     UNSIGNED digits.
2. **The PREFIX (`INT:`/`UINT:`) and `vpiConstType` (7/9) are a SEPARATE
   decision**, already owned by § genLpFoldSignedStructural46 + the `negSib9`
   arm.  **This pass does not re-open it** (§ 8 R-rgg18-a is the one shape
   where it is still wrong).
3. `vpiSize` is the DECLARED width, independent of both (7 on a value of 128).

**WHY, from Surelog.**  `LValue` holds a 64-bit word plus a TYPE, and
`Value.cpp:880` renders

```c++
case Value::Type::Integer:  result = "INT:";  result += std::to_string(m_valueArray[i].m_value.s_int);
case Value::Type::Unsigned: result = "UINT:"; result += std::to_string(m_valueArray[i].m_value.u_int);
```

with `LValue::decompiledValue()` (`Value.cpp:925`) printing the SAME digits
without the prefix and `LValue::vpiValType()` (`Value.cpp:951`) returning
`vpiIntConst`/`vpiUIntConst` from the SAME `m_type`.  All four fields are
stamped from ONE `Value*` in one place —
`NetlistElaboration.cpp:429-432`:

```c++
c->VpiValue(value->uhdmValue());
c->VpiDecompile(value->decompiledValue());
c->VpiSize(value->getSize());
c->VpiConstType(value->vpiValType());
```

**There is no masking to the declared width anywhere on that path**: the size
comes from `value->getSize()` (the declaration's range) while the digits come
from the untruncated 64-bit arithmetic word.  That is the whole law.

---

## 4. WHERE OURS WENT WRONG, and the change

`src/ModuleEmit.cpp`, the gen-scope localparam arm (`emitInstance`'s
generate-block walk).  The two carriers § genLpFoldSignedStructural46 named:

* **CALL SITE 1** — the `parameter`'s own `vpiValue` (~13269).  Shipped:
  `neg = cv.integer().isSigned() && cv.integer().isNegative()` — the DECLARED
  type's reading of the TRUNCATED bits, which decides BOTH the prefix and (via
  `signedDigits46`) the digits.  Wrong on grid rows B and E, where golden
  writes `UINT:<unsigned>` on a value whose bits read negative.
* **CALL SITE 2** — the `param_assign` Rhs `constant` (~13500), **the object
  the cmp head sits on**.  Shipped:
  ```c++
  SVInt svv = cv.integer(); svv.setSigned(true);
  int64_t sv = svv.as<int64_t>().value_or(0);
  std::string sd = std::to_string(sv);          // <- ALWAYS the signed reading
  ```
  which is `-64` for the head, `-4611686018427387903` for a 64-bit MSB-set
  fold, and `0` for anything past `int64`.

The change gives both sites the same source of digits: **`mathFold46`'s value**.
`mathFold46` already existed — r10earl46's verifier added it to decide the SIGN
of the digits in the INT arm ("F-1"), folding the same shapes in 128-bit
arithmetic; this pass promotes it from a SIGN oracle to the VALUE, which is
what it was computing all along.  A new `i128dec18` renders an `__int128`
(neither `int64` nor `uint64` can hold every measured cell: H needs
13835058055282163712, a signed intermediate needs the other end).

**The F-1 block is SUBSUMED** — it is left in place, gated `&& !mok18`, so the
diff shows exactly that it can no longer fire rather than deleting a measured
law silently.

**WHAT IS NOT TOUCHED, deliberately:** `sv` (the signed reading) still feeds
`mathNeg46`/`negSib9`, so every PREFIX decision — the structural walk, the
negative-sibling arm, the `selBits9` BINARY select arm — is byte-for-byte the
shipped one.  When `mathFold46` cannot evaluate (`mok18 == false`: a call, a
leaf past 64 bits) BOTH sites keep the shipped rendering unchanged.

---

## 5. THE GRID SCORED, base vs patched

`GOLDEN_SHAPES_grid.txt` holds the full three-way listing.  Differing shared
keys, golden vs ours:

| grid | shared keys | BASE differing | PATCHED differing |
|---|---|---|---|
| a1 (`.sv`, 17 rows x 2 unrollings + 7 module-scope controls) | 43 | **26** | **13** |
| b1 (`.v`, 3 rows x 6 gen instances x 3 module instances)     | 30 | **12** | **0** |

Every a1 cell that moved, moved TO GOLDEN; **nothing moved away**.  The 13 that
remain are four PRE-EXISTING residues, each now differing on a field this law
does not own (§ 8), and — the control that matters — **the seven MODULE-SCOPE
rows (MA, MB, MD, ME, MF, MM, MN) are byte-identical between base and patched**:
they are rendered by `ParamEmit`, and this law is confined to the gen-scope
carrier.

---

## 6. THE GATES

See `GATES.txt` (build md5s + the two golden legs + both corpora + the canary
battery + the row heads), `BYTEVERIFY.txt` (0 movers over 1,358 uhdm2rtlil
databases; 3 over 956 surelog, every one named and attributed),
`BOUNDARY.txt` + `BOUNDARY_MOVERS_DECODE.txt` (3,187 sources over a COPY of the
WHOLE `tools/probe` tree with NO path filter, `.sv` and `.v`: 3,052 identical,
8 movers — two of them this pass's OWN grid cells, the POSITIVE CONTROL — and
**0 asymmetries**), and `PREDICT_db_*.txt` (the mover set predicted BY NAME
from the PRISTINE databases BEFORE the patched sweeps existed, with REACH
stated: 1,356 and 948 databases restored, 0 unreadable, FENCED tests skipped
and never named).

Headline: **goldens 23/0 on both binaries and 0/23 on `/bin/false`;
uhdm2rtlil 679/50/2 with 0 differing rows over 1,462 (status AND dump), against
my own base sweep AND the committed baseline; surelog EXACTLY ONE differing row
over 1,588 — the conversion.**

---

## 7. THE CONVERTED ROW — SAID LOUDLY

`results/golden_surelog.csv` is READ ONLY here and is NOT edited.  The row the
master should promote, quoted old → new:

```
old: Rggen,default,CMP_NOTEQUAL,decompile:,,
new: Rggen,default,CMP_EQUAL,,,differ
```

`rowheads.sh` on the patched workdir: `Rggen default 0 cmp lines 0 heads
cmp rc=0`.  The `dump` column stays `differ` — byte identity (phase 3) is not
this phase's bar.

---

## 8. THE NEXT HEAD (R0) AND THE RE-RANKED RESIDUES

**`default:Rggen` HAS NO HEAD ANY MORE.**  `rowheads.sh` on the patched
workdir: `Rggen default 0 cmp lines 0 heads cmp rc=0`.  Every other named row
is UNCHANGED (`ROWHEADS.txt`, base and patched side by side):

```
              BASE            PATCHED
SeqDriver      50/1 50/1  ->   50/1 50/1
SimpleUVM     108/1 108/1 ->  108/1 108/1
Scoreboard    108/1  -    ->  108/1  -
MiniAmiq       50/1 50/1  ->   50/1 50/1
BuildUVMPkg    32/1 32/1  ->   32/1 32/1
Earlgrey_0_1  216/1 216/1 ->  216/1 216/1
Rggen          64/1  -    ->    0/0  -      <- CONVERTED
```

The surelog corpus goes from **20 to 19 `CMP_NOTEQUAL` rows** (11 of them
comparable and unfenced: BuildUVMPkg x2, Earlgrey_0_1 x2, MiniAmiq x2,
Scoreboard x1, SeqDriver x2, SimpleUVM x2).  **R0 for the campaign is now one
of those rows, not an Rggen object.**

**RE-RANKING OF THE RGGEN RESIDUES — THEY ALL CHANGE CLASS.**  r10rgg17 ranked
R-A / R-N3 / R-D / R-N4 / R-N5 / R-E as candidates to become the next Rggen
*cmp head*.  None of them can be: the row is cmp-equal, so every one of them is
now a **PHASE-3 (byte-identity) residue only** — they keep the `dump` column at
`differ` and block nothing else.  Re-ranked by what they now cost:

1. **R-N3 (103 golden-only ELAB `hier_path`s, `register_if.value` /
   `register_if.write_data`) — still the largest, and now the ONLY one that is
   a MISSING-OBJECT family** rather than an encoding one.  It is the right head
   for a phase-3 Rggen pass because a missing object is the one residue class
   that can still turn into a cmp head if any other law starts reaching those
   scopes.
2. **R-A (810 census rows, `op11[ref(WIDTH), UINT:1]` kept symbolic by golden in
   gen-scope interface variable range bounds where we fold).**  Biggest by row
   count, cheapest to score, no judge consequence today.
3. **R-D / R-N4 / R-N5** (`decompileHelper` spacing; the two other hier_path
   builders; the unpacked-variable-array base kind).  Unchanged, zero corpus
   reach beyond Rggen's dump column.
4. **R-E** (a gen-scope localparam index in a cont_assign that golden folds).
   Unchanged.

**FIVE NEW RESIDUES, all MEASURED here, all on the grid, none reaching a
corpus row today** (`GOLDEN_SHAPES_grid.txt`; the a1 grid's 13 remaining
differing keys are exactly these):

* **R-rgg18-a — a SIZED DECIMAL literal MINTS SIGNED in the fold's PREFIX.**
  Grid F (`OFF + 7'd64`) and G1 (`… + 7'd60`): golden writes `INT:128` / ct 7
  where we write `UINT:128` / ct 9.  **This pass made the DIGITS golden on both
  rows** (128 and 124/128, pre-truncation) and left the prefix alone, so the
  divergence is now one field wide.  § genLpFoldSignedStructural46's measured
  table classifies "a literal" as RESET-to-unsigned; it was never measured on a
  SIZED DECIMAL, and r10rgg11 had independently seen `8'd171 -> INT:171 ct 7`
  from the other direction.  The fix is one row of that table, but it is a
  PREFIX law and re-opening the prefix is a separate measurement.
* **R-rgg18-b — a BARE REF initializer keeps the REFERENCED parameter's SOURCE
  encoding.**  Grid Q (`localparam bit [6:0] Q = OFF;` with `OFF = 7'h40`):
  golden `HEX:40` / ct 5 / decompile `7'h40`, ours `UINT:64` / ct 9 / `64`.
  Four of the eight boundary movers are this shape
  (`BOUNDARY_MOVERS_DECODE.txt`), which makes it the widest-reaching new
  residue by arm count even at zero corpus reach.
* **R-rgg18-c — an UNTYPED gen-scope localparam's `vpiSize`.**  Grid P: golden
  32 (the inferred `int` width), ours 7 (the initializer's width).  `VpiSize` is
  the SECOND field `expr::Compare` reads, so this one WOULD be a head if it ever
  reached a corpus row.
* **R-rgg18-d — a fold WIDER THAN 64 BITS IS NOT FOLDED BY GOLDEN AT ALL.**
  Grid I (`bit [64:0] I = 65'h1_0000_0000_0000_0000 + 65'(g)`): golden keeps the
  `operation` as the param_assign Rhs; we mint a constant.  `mathFold46` already
  refuses (`ok=false`) at that width, which is why this pass changes nothing
  here — it is an ABSTAIN law, not a rendering one.
* **R-rgg18-e — Surelog evaluates `64'(genvar)` as 0.**  Grid H at `g=1`:
  golden `UINT:13835058055282163712` for BOTH unrollings (the `+ 64'(g)` term
  vanishes) where the arithmetic says `…713`.  Golden is the spec, bugs
  included; modelling this one needs its own grid.  Base was
  `-4611686018427387903` here, so the cell moved much closer without becoming
  equal.

**AND ONE RESIDUE THE RGGEN CENSUS STILL SHOWS (3 keys, NOT judge-visible):**
golden carries `vpiValue` on the `parameter` object of
`rggen_adapter_common.STATUS_WIDTH` (`UINT:2`) where ours is empty.
`parameter::Compare` does not read `VpiValue` — which is precisely why Rggen is
cmp-equal with those three still differing, and why the census is reported next
to the judge and never instead of it.

---

## 9. WHAT THIS PASS DOES **NOT** CLAIM

* It does not touch the PREFIX (`INT:`/`UINT:` + `vpiConstType`) of any fold.
  § genLpFoldSignedStructural46's structural walk and the `negSib9`
  negative-sibling arm are byte-for-byte the shipped ones; R-rgg18-a is the one
  shape where the prefix is still wrong and it is named, not fixed.
* It does not touch the MODULE-SCOPE renderer (`ParamEmit`).  The a1 grid's
  seven module-scope control rows are byte-identical base-vs-patched, and two of
  them (MF, MN) are still wrong against golden in exactly the way they were.
* It does not claim `mathFold46` models Surelog's evaluator completely.  Where
  the walk refuses (`ok=false`) BOTH carriers keep the shipped rendering, and
  R-rgg18-d is the measured example.
* `results/golden_surelog.csv` and `results/gate_uhdm2rtlil.csv` were **not
  edited**.  The converted row is quoted in § 7 for the master to promote.
* The 3 surelog byte movers and the 8 boundary movers are named and attributed
  individually (`BYTEVERIFY.txt`, `BOUNDARY_MOVERS_DECODE.txt`); six of the
  eleven are DUMP-IDENTICAL symbol-table shrinkage and four are pre-existing
  NE cells that stay NE.
