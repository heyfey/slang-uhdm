# r10vrgg11 — ADVERSARIAL VERIFICATION of r10rgg11 (§ genLpPortConnValue11)

**MEASUREMENT-ONLY directory.**  The official `uhdm-cmp` remains the sole
acceptance judge.  **BASE `5a76eab`.**  `results/*.csv` READ-ONLY and untouched.
**Rggen still does NOT pass `uhdm-cmp`; NO CORPUS ROW WAS CONVERTED.**

**VERDICT: the LAW is ACCEPTED and the HEAD is genuinely CLEARED; the SHIPPED
GATE was TOO WIDE and is RE-CUT here.**  Every headline number in the
implementer's report reproduced bit-for-bit from my own two builds.  Breaking
the law over a 505-cell adversarial grid then produced **20 pristine-right →
patched-wrong Compare fields on legal SystemVerilog**, corpus-invisible, in
four initializer families.  The fix is 20 added lines on top of the
implementer's 43; after it the same 505 cells show **0 HARD-REGRESSION,
0 NET-WORSE, 0 FIELD-LOST, 197 NET-BETTER**.

---

## 1. REPRODUCTION (my own worktrees, my own builds, my own frozen binaries)

Worktrees `/tmp/wt_vrgg11pris` and `/tmp/wt_vrgg11`, both `git worktree add …
5a76eab`; the patch applied clean on the fresh one.  Both binaries built
`-j 2`, `md5` taken only after `Built target slang_uhdm`, then frozen
`chmod 555` under `/tmp/vrgg11_bin/` BEFORE any sweep; `SLANG_UHDM` exported
explicitly per binary and **every `cmds.txt` audited by binary PATH**.

| claim | implementer | verifier | |
|---|---|---|---|
| base binary md5 | `f8908264f24f59f9ca3c19826a244eae` | **same** | ✓ |
| patched binary md5 | `917997b9a0e23553ddba33dba679ca69` | **same** | ✓ |
| verified (re-cut) binary md5 | — | `770190fe319045efe063b7d647a25d68`, and the SHIPPED PATCH SOURCE rebuilt from scratch in a throwaway 5a76eab worktree gives the SAME md5 | new |
| head BEFORE (Rggen/default) | 36 cmp lines, 1 head | **byte-identical cmp log** | ✓ |
| head owner | the PORT's own `High_conn` | confirmed off the parent chain (`\_port: (i_value)`, constant at the ACTUAL's span 468:30) | ✓ |
| head AFTER | 104 cmp lines, 1 head, new family | **same** | ✓ |
| Rggen whole-dump diff base→pat | 4 lines over 1,580,412 | **4 lines over 1,580,412** | ✓ |
| goldens base / pat / `/bin/false` | 23-0 / 23-0 / 0-23 | **same** | ✓ |
| u2r base + pat, both modes | 679/50/2, 0 rows vs committed | **same** | ✓ |
| u2r byteverify | 0 movers / 1358, selfcheck live | **same** | ✓ |
| surelog base + pat, both modes | 0 rows vs committed | **same** | ✓ |
| surelog byteverify | 2 movers (Rggen + the COIN) | **1 mover — `default/Rggen` ONLY** (my Scoreboard coin landed on the same face) | ✓ (stricter) |
| named-row heads | only Rggen/default moves | **same** | ✓ |
| canaries / ctcan2 / canaudit | 52-0 / 8-0 / 58-0 (unknown 1) / audited=29 UNCOVERED=0 FENCE-BREACH=0 | **same** | ✓ |
| byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, 3 canaries identical | **same** | ✓ |
| boundary, 38 precedent dirs | files=1202 identical=1097 MOVERS=7 uncompilable=98 asym=0 | **LISTED=1202 PROCESSED=1202, identical=1097, MOVERS=7, uncompilable=98, asym=0** | ✓ |
| the 7 movers move TOWARD golden | arms=7 FIXED=9 BROKEN=0 | **7/7 NET-BETTER on the WHOLE normalised dump, both directions, 0 field lost** | ✓ |

`ct8rows.sh` (whole row, status AND dump column) was the row judge on every
sweep, against the committed baselines AND against my own base sweeps.

## 2. WHAT BROKE — the law is right, the GATE was too wide

The identity the law asserts **holds in golden in every cell I could build**:
golden's ELAB port actual IS golden's ELAB `param_assign` Rhs of that
parameter.  The defect is on OUR side: **our own ELAB gen-scope `param_assign`
Rhs is not golden's** for several initializer families, and the shipped patch
copies it unconditionally — so it propagates a declaration-constant bug into a
second Compare-visible object where the pristine 64-bit `genvarConnFold` was
closer.

Measured (`PORTTABLE_V2_genif_bit8.txt`, `localparam <T> IV = <init>;` read as
`.i_value(IV)` from a gen scope; the four fields `constant::Compare` reads):

| init | golden | PRISTINE | SHIPPED PATCH | verdict |
|---|---|---|---|---|
| `8'o253` | `UINT:171 sz 8 ct 9 "171"` | `UINT:171 sz **64** ct 9 "171"` — 3 of 4 right | `OCT:253 sz 8 ct 4 "8'o253"` — **1 of 4** | **REGRESSION ×3 fields** |
| `8'(171)` | `UINT:171 sz 8 ct 9 "171"` | 3 of 4 right | `INT:-85 sz 8 ct 7 "-85"` | **REGRESSION ×3** |
| `8'h0a+8'ha1` | `UINT:171 sz 8 ct 9 "171"` | 3 of 4 right | `UINT:0 sz 8 ct 9 "-85"` | **REGRESSION ×2** |
| `BASE+1`, `PW` | `UINT:171/170 sz 8` | 3 of 4 right | `UINT:0 … "-85"/"-86"` | **REGRESSION ×2** |
| `8'd171` | `INT:171 sz 8 ct 7 "171"` | 1 of 4 | `UINT:171 sz 8 ct 9 "8'd171"` | lateral swap |

20 cells over grid V2 (`genif`/`genfor` × `bit[7:0]`/untyped), **0 corpus rows**
— exactly the corpus-invisible class the wide boundary exists to catch.
Two mechanisms: our gen-scope literal arm is SOURCE-ENCODED (golden re-encodes
octal and sized-decimal at ELAB), and our gen-scope NON-literal arm renders the
**signed reading of the bits** unconditionally (right for `-3`, wrong for any
MSB-set POSITIVE fold).

## 3. THE FIX — `§ genLpPortConnCopyableOnly11v`, 20 added lines

> **Copy the parameter's `param_assign` Rhs into the port actual only where
> that Rhs is itself golden's constant.**
> * literal arm: the value is `HEX:`/`BIN:` (source encoding golden keeps), or
>   a BASELESS decimal.  **Octal and sized-decimal literals refuse.**
> * fold arm: the signed-bits rendering IS the value — either the bits are
>   non-negative (`$clog2(300)` → 9, copied and EXACT) or the MATHEMATICAL fold
>   is negative (`-3`, `-8'sd3` → `INT:-3`, copied and EXACT).  An **explicit
>   size cast refuses unconditionally**: `8'(171)` is signed `-85` to slang and
>   `171` to Surelog, so `mathFold46` genuinely reports it negative — the one
>   place where "the walk evaluated" is not enough.  "Could not evaluate" also
>   refuses (unlike the INT-prefix rule F-1/earl46, where the signed reading
>   stands).

Structurally the gate only ever *withholds* map entries, so nothing outside the
port-connection arm can see it, and the head's `8'hab` (HEX) is untouched.

## 4. THE ADVERSARIAL GRIDS — 505 cells, `gen.py` + `cells/V4/`

* **V1, 150 cells** — 10 homes (`mod`, `genif`, `genif-else`, `genfor`,
  `genfor×3`, external-genvar `genfor`, `gencase`, gen-in-gen inner, gen-in-gen
  outer, ANONYMOUS gen block) × 15 declared types (incl. `real`, `string`,
  typedef'd, enum, packed-2D).
* **V2, 150 cells** — 3 homes × 2 types × **26 initializers** (sized/unsized/
  based/underscored/signed-literal/negative/x/z/real/string/concat/replication/
  cast/call/`$clog2`/param-expr/outer-param/enum/ternary/64-bit).
* **V3, 180 cells** — 3 homes × 3 types × **20 read sites** (bare, positional,
  concat, cast, part-select, user call, ternary, operation, replication, system
  call, braced, parameter override, override-expression, `defparam`,
  cont-assign, procedural, gen-condition, instance array, two instances, none).
* **V4, 25 hand-written cells** — 1/2/3 instances, 3 instances with DIFFERENT
  parameterisation, inline and external genvars, genvar beside a localparam,
  non-literal inits, hierarchical reads (`top.g.IV`, `g.IV`), outer-scope read,
  module-param read from a gen scope, interface gen scope, instance array,
  shared read at two ports, gen-in-gen through an instance, wide/narrow formal,
  gate primitive, unpacked-array select, `defparam`, implicit `.IV` port,
  real/string ports, three-deep nesting.

Scoring (`score3.py`) is **order-blind**: a multiset over the whole
path-normalised `uhdm-dump` of each side, reporting the symmetric difference to
golden for the pristine and the candidate, plus `FIELD-LOST` — any golden line
the pristine matched and the candidate does not.  A cell that merely swaps one
wrong line for another can never read as progress.

| grid | SHIPPED PATCH | **WITH THE FIX** |
|---|---|---|
| V1 (150) | HARD 0, NET-WORSE 0, FIELD-LOST 0, BETTER 117 | HARD 0, **NET-WORSE 0, FIELD-LOST 0**, BETTER 108 |
| V2 (150) | HARD 0, **NET-WORSE 16, FIELD-LOST 20**, BETTER 78 | HARD 0, **NET-WORSE 0, FIELD-LOST 0**, BETTER 58 |
| V3 (180) | HARD 0, NET-WORSE 0, FIELD-LOST 0, BETTER 18 | HARD 0, **0, 0**, BETTER 18 |
| V4 (25) | HARD 0, NET-WORSE 0, FIELD-LOST 0, BETTER 13 | HARD 0, **0, 0**, BETTER 13 |

V3 confirms the scope claim exactly: **only** `portplain`, `portpos` and
`twoinst` move; concat / cast / part-select / call / ternary / operation /
replication / system-call / override / override-expression / `defparam` /
cont-assign / procedural / gen-condition / instance-array cells are byte-still.
V4 confirms the genvar law (`genvar_inline`, `genvar_ext` byte-still), the
hierarchical reads (`hier_read`, `hier_read_rel` byte-still), and that 1/2/3
instances and three differently-parameterised instances scale linearly with no
cross-instance contamination.

## 5. GATES ON THE FIXED BINARY (all mandatory legs, re-run end to end)

See `GATES_fix.txt`.  Goldens 23-0, negative control 0-23; u2r both modes
679/50/2 with **0 differing ROWS** against the committed baseline and against
my own base, **0 byte movers over 1358**; surelog both modes **0 differing
ROWS**, byte movers **exactly the predicted one row**; canaries, ctcan2 and
canaudit at baseline; every byte pin held; boundary over the 38 precedent dirs
`LISTED=1202 PROCESSED=1202 MOVERS=7 asym=0`, all 7 NET-BETTER; positive
control over this pass's own cells `MOVERS=14 / 25`, 13 NET-BETTER, 1 unchanged,
**0 worse**.

## 6. RESIDUES, RANKED

1. **R-A (the head's successor, unchanged):** `default:Rggen`'s new head is a
   user function call unreduced inside a packed range bound
   (`rggen_or_reducer.sv:66`).  Confirmed already wrong in the base and merely
   masked — the four-line whole-dump diff is the proof.
2. **R-B (NEW, this verification):** our ELAB gen-scope `param_assign` Rhs is
   wrong for `8'o253` (source-encoded where golden re-encodes `UINT:171`),
   `8'd171` (`UINT` + raw decompile where golden writes `INT:171` / `"171"`),
   `8'(171)` / `expr` / `BASE+1` / `PW` (`INT:-85` or an UNSET `VpiValue`
   printing `UINT:0`, where golden writes the plain unsigned decimal).  Fixing
   THAT object is the principled next pass; it would then let the copy gate be
   widened back and would move corpus rows, so it needs its own gate battery.
3. **R-C:** the single **UNSET `VpiValue`** on the non-literal gen-scope fold
   constant (`UINT:0` beside a `-85` decompile) is a plain bug, visible in the
   pristine base, independent of this law.
4. **R-D:** the whole-expression port-actual fold (concat / cast / part-select /
   call actuals) — 132 of 144 grid-B cells in the implementer's own measurement,
   the r10scr13 NOTE (a) family, corpus-wide and untouched.
5. **R-E:** withheld gains from the re-cut gate — `{4'ha,4'hb}`, `{2{4'ha}}`,
   `1?8'hab:0` and enum-member initializers keep the pristine 64-bit fold and so
   still miss the `vpiSize` they would have gained.  They are wrong on the other
   three fields either way; R-B is the fix that makes them right.

## 7. INSTRUMENTS

| file | what it does |
|---|---|
| `gen.py` | generates grids V1 / V2 / V3 (`gen.py <dir> V1`) |
| `cells/V4/` | the 25 hand-written adversarial cells |
| `cell.sh` / `run.sh` | one cell / one grid: Surelog once, then our side per binary tag; NODB / NOSLANG printed and COUNTED; `</dev/null` on the CHILD |
| `score2.py` / `score3.py` | the order-blind multiset scorer (HARD-REGRESSION / NET-WORSE / NET-BETTER / FIELD-LOST) |
| `porttable.sh` | the four Compare fields of every cell's ELAB port `High_conn`, one column per binary |
| `bnd.sh` | the recursive boundary: file list on **fd 3**, `</dev/null` on every child, `PROCESSED` asserted against `LISTED`, UNCOMPILABLE / ASYMMETRY counted |
| `armscore.sh` | rebuilds golden per arm so a MOVER can be scored TOWARD golden |
| `gates.sh` | the mandatory legs, `SLANG_UHDM` exported per binary, my own out/workdirs |
