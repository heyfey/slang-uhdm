# r10vrgg15 — ADVERSARIAL VERIFICATION of r10rgg15 (`§ unbasedZeroFillOvDeclWidth15`)

**VERDICT: ACCEPT AS SHIPPED.** Every headline number reproduced bit-for-bit
from my own worktrees and my own binaries. The law survived a purpose-built
9-cell attack grid (fill shapes × declared types × widths × default/override ×
home × DEF/ELAB); **0 BROKEN cells, 0 SPAN-BROKEN cells**, and the patch turns
out to fix strictly more than the pass claimed. No production edit was needed.

Worktrees `/tmp/wt_vrgg15pris` (pristine 5d8ff29) and `/tmp/wt_vrgg15`
(5d8ff29 + `/tmp/r10rgg15.patch`), scratch `/tmp/vrgg15_*`.
Frozen binaries (`chmod 555`): base `74963e213f7f98da45ceaec21ee541e2`,
patched `561e5694d8b9024a74719993ac67dc79` — **identical to the implementer's**,
so the build is reproducible and the two reports measure the same object.

## 1. Head decode, done from the pristine cmp log by me

`uhdm-cmp golden Rggen/default` on my own base sweep is **64 lines, 1 head**, and
the file is **byte-identical** to the implementer's
`HEAD_R0_BEFORE_default_Rggen.cmp`.

Judge fields for a `constant`, read out of the generated sources (not carried
forward): `BaseClass::Compare` VpiType → VpiName → VpiDefName;
`expr::Compare` **VpiDecompile → VpiSize → Typespec**; `constant::Compare`
**VpiConstType** last.
**`VpiValue` is read by NO generated Compare** (`grep VpiValue` over
`~/git-repos/UHDM/build/generated/src/` finds only the accessors in `expr.cpp`),
and neither are `VpiFile`/line/col. So the head fails at **VpiSize (2 vs 64)**,
`BIN:0` is judge-invisible, and the span half of the law is scored by the dump
alone. Both statements were verified in source, not assumed.

**Owner = an OVERRIDE ACTUAL (the brief's option (b)), CONFIRMED:**
`rggen-sample/block_0.sv:2053` has the design's **only** `.INITIAL_VALUE('0)`
(`grep -c` over the whole test tree = 1), and
`rggen-sv-rtl/rggen_bit_field.sv:5:61` is
`parameter bit [WIDTH-1:0] INITIAL_VALUE = '0` — which is exactly the span
golden carries. WIDTH is 2 at that instance, hence golden's `vpiSize:2`.

## 2. The Surelog derivation, re-read at the source

`CompileHelper::adjustSize` (`CompileHelper.cpp:3949`): `size = Bits(ts)` unless
`Bits` is invalid, and the `orig_size == -1` tail ends `c->VpiSize(size)` while
only re-rendering the value **when `uval == 1`** (and, for `size > 64`, as a BIN
all-ones string). That is the whole law, and it also explains three of the
residues below. Two extra clauses the pass did not spell out, both measured:

* `adjustSize` **returns immediately when `ts == nullptr`** — an UNTYPED formal
  keeps size **−1** (grid `v1 u_unt`, golden `sz=-1`, no typespec at all).
* when `Bits` is invalid the size stays `orig_size` — a `time` formal keeps
  **−1** (grid `v7 atm`).

## 3. The attack grid — 9 cells I wrote, both views, scored field by field

`cell.sh` mirrors `verify_golden.py`'s `default` mode exactly
(`surelog -parse -mt 0 -mp 0` vs `slang-uhdm --single-unit`), `--elabuhdm` on
both sides for the ELAB view. `pcensus.py` is an **owner-keyed multiset census**
over every `param_assign` in a dump: key = the Lhs parameter's `vpiFullName`,
payload = **judge fields only, NO span** (`kind/decompile/size/constType/
value-kind/typespec-kind`), with the **span carried separately** so shape and
span are scored independently — the brief's requirement, and the one place the
implementer's own scorer folds `LOC`/`LL` into the shape payload (which is why
their "shape FIXED=28" is inflated; re-scored with a no-span payload their grid
gives **shape FIXED=17, span FIXED=26, BROKEN 0/0**).

| cell | what it attacks | keys | shape FIXED | span FIXED | **BROKEN** |
|---|---|---|---|---|---|
| v1 | 14 declared types, widths 1/2/6/8/16/32/33/64/65/128, `'0` override **and** plain default side by side | 43 | 11 | 14 | **0** |
| v2 | `'1`/`'x`/`'z` fills into 8 formals (the arms the patch must NOT move) | 33 | 0 | 24 | **0** |
| v3 | `'b0 'h0 'd0 1'b0 6'd0 8'd0 0 3 -1 -3 'sb1` into a 6-bit formal (non-fill shapes) | 17 | 1 | 1 | **0** |
| v4 | NO-DEFAULT vs WITH-DEFAULT formals × all four fills (the span discriminator) | 26 | 5 | 12 | **0** |
| v5 | the formal's width is itself a parameter, 1/2/7/8/9/33/64/65/128 per instance, named and positional | 27 | 8 | 10 | **0** |
| v6 | HOMES: gen-`for`, gen-`if`, interface, package, class, typedef'd/enum/struct formals | 20 | 6 | 7 | **0** |
| v7 | ranged-untyped, `parameter type` formals, packed union, `time`, hierarchy pass-down, `defparam` | 26 | 7 | 11 | **0** |
| v8 | 1024-bit and 65536-bit formals; declaration and override in **different files** | 9 | 3 | 3 | **0** |
| v9 | the child READS the fill parameter (claimed/cloned constant in a `cont_assign`) | 9 | 1 | 1 | **0** |

Every cell was scored again in the **ELAB view** (`--elabuhdm` on both sides):
`v1 11/0, v2 0/0, v3 1/0, v4 5/0, v5 8/0, v6 3/0, v7 7/0` FIXED/BROKEN.
Cells **v4 and v5 go to `cmplines=0`** with the patch — the whole design
compares EQUAL, on 26 and 27 param slots respectively.

**Measured law, wider than the pass claimed** — golden's size for an unbased
`'0` override actual is the formal's own width for *every* integral formal:
`bit[0:0]`→1, `bit[1:0]`→2, `bit[32:0]`→33, `bit[63:0]`→64, `bit[64:0]`→65,
`bit[127:0]`→128, `bit[1023:0]`→1024, `bit[65535:0]`→65536, `logic[5:0]`→6,
`byte`→8, `shortint`→16, `int`/`integer`→32, `longint`→64,
`logic signed[7:0]`→8, ranged-untyped `[7:0]`→8, packed `struct`/`union`→6.
All sixteen are byte-right after the patch and were 64 before.

### The one thing the pass under-claimed
**v9 (NEW):** when the child *reads* the overridden fill parameter, golden and we
SHARE one constant between the `param_assign` Rhs and the child's `cont_assign`.
Pristine wrote `6'b0`/sz 6 there (a downstream re-render fired because the mint's
size was 64); patched writes `'b0`/sz 6 — **golden's exact rendering**. The
whole-dump distance of that cell to golden drops **117 → 99 sides**. This
second-order effect is favourable and was not in the implementer's report.

## 4. The fence, re-measured

u2r `unbased_unsized_param`: golden's four fills are
`BIN:0 sz 64 'b0` / `UINT:2^64−1 sz 64` / `BIN:X sz −1` / `BIN:Z sz −1`,
**all four loc-less**, and the formal `parameter logic [63:0] VALUE` has **no
written default** — so both halves of the discriminator are exercised by the
corpus itself. My census of that test: **10 keys, FIXED=0, BROKEN=0, span all
OK** — the patch is a provable no-op there, and the database is byte-identical.

**CORRECTION to the implementer's report:** it states this row is
"both modes, CMP_EQUAL, dump `match`". The dump column is **`differ`**, in both
modes, on both binaries, and in the committed `gate_uhdm2rtlil.csv`
(`unbased_unsized_param,testflags,CMP_EQUAL,,,differ`). The status claim is
right; the "dump match" claim is wrong. It does not affect the verdict.

## 5. My own prediction, from the PRISTINE databases

Byte-grep every pristine database for the literal `'b0` (446 of 2314 hit),
dump each and count `vpiDecompile:'b0` immediately followed by `vpiSize:64`.
**Exactly three slots in the whole corpus carry that pair:**

```
1  wd_base_sl /default  /Rggen
1  wd_base_u2r/default  /unbased_unsized_param
1  wd_base_u2r/testflags/unbased_unsized_param
```

The two `unbased_unsized_param` slots have a **64-bit formal with no default**,
so both halves of the patch are no-ops there. **Predicted mover set =
{default/Rggen}, one database.** Measured (`byteverify SELFCHECK=1`): u2r **0
movers / 1358**; surelog **2 movers / 956** = `default/Rggen` (the target) and
`default/Scoreboard` — the latter attributed ORDER-BLIND as the documented coin
(raw diff 28 sides = one 13-line `bit_typespec` block relocated; **sorted** diff
2 sides = the output-path banner only). Prediction met exactly.
*(The implementer saw 1 mover; the coin simply did not flip for them.)*

## 6. The target, re-measured

* Whole-dump path-normalised diff, Rggen base vs patched: **3 changed lines
  (6 sides) + the banner, over 1,580,844 lines a side** — the head constant's
  `vpiSize` and its span, nothing else.
* The patched head object is **byte-identical to golden's own 21-line
  rendering**, checked line by line against the golden dump.
* Rggen whole-database `param_assign` census (golden vs base vs patched):
  **7372 keys, FIXED 1, BROKEN 0**, the one FIXED key being
  `work@rggen.u_block_0.g_register_13.g_bit_field_1.u_bit_field.INITIAL_VALUE`.
  Calibration **golden-vs-golden 0 differing / 7346**; negative control
  golden-vs-base **125 differing** (instrument live).
* `rowheads.sh` unchanged everywhere except Rggen/default **64 → 683**.
* **NO ROW CONVERTED**: Rggen/default is `CMP_NOTEQUAL` before and after;
  `results/*.csv` untouched.

See `GATES.txt`, `BOUNDARY.txt`, `cells/*/CENSUS*.txt`.

## 7. Ranked residues (measured here; ranks are mine)

* **R-A** `'1` fill into a formal **wider than 64 bits** — golden renders the BIN
  all-ones string (`adjustSize`'s `size > 64` branch), we render the UINT
  decimal. Confirmed at 65, 128 **and 1024** bits (`v2 o_b65/o_b128`,
  `v8 o_big`). Wrong before and after; zero corpus reach. Cheapest remaining
  item in this family — the branch is three lines from the one just fixed.
* **R-B** BASED-unsized and sized literal override actuals take a different arm
  and are wrong a third way (`v3`): `'b0`→golden `1'b0` sz 1, `'h0`→golden HEX
  sz 6, `'d0`/`-1`/`-3`→golden INT ct 7, `'sb1`→golden 63. Unchanged by this
  pass.
* **R-C (NEW)** **`parameter type T` formals**: golden sizes the fill by the
  formal's **DECLARED (unspecialized) type** — all three of `T=bit[12:0]`,
  default `T=bit[5:0]`, `T=int` read `sz 6` with a `bit_typespec`. We emit an
  `int_typespec` (pre-existing) and now size by the **specialized** type
  (13/6/32 vs 64/64/64 before). Every cell is NE before and after — no
  regression, no conversion — but the width source is a distinguisher nobody has
  named. Zero corpus reach.
* **R-D (NEW)** **untyped formal** `parameter P = '0`: golden is `sz −1` with
  **no typespec at all**; we emit a `logic_typespec` and now `sz 32` (was 64).
  Needs both halves to converge; zero corpus reach.
* **R-E (NEW)** `time` formal: golden `sz −1` (Bits invalid), we keep 64 before
  and after.
* **R-F (NEW)** `defparam` of a fill (`v7 d0.DP`): golden `dec=0 sz=6 ct=17`,
  we write `6'b0` BIN ct 3. Untouched by this pass.
* **R-G** a param-REF override actual re-renders SIZED (`v7 c_pass`: golden
  `'b0` sz 10, ours `10'b0`) — the unsized encoding is not propagated down a
  hierarchy the way golden propagates it.
* **R-H** gen-scope localparam `= '0` reads golden `<w>'b0` BIN, we write UINT
  `0` (`v6 gblk[*].GL`) — the implementer's R-E, reproduced.
* **OPS** the ELAB view segfaults (rc 139) on **10** `tools/probe` arms,
  **symmetrically on both binaries** — pre-existing, named in `BOUNDARY.txt`.

## 8. Files

`cell.sh` (arm driver), `pcensus.py` (owner-keyed no-span census + separate span
judge), `boundary.sh` / `boundary_elab.sh` (the three-arm wide boundary),
`cells/v1..v9/*.sv` + their `CENSUS*.txt`, `GATES.txt`, `BOUNDARY.txt`.
