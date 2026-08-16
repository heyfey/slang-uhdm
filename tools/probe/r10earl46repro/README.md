# r10earl46 — § genLpFoldSignedStructural46

**THE HEADLINE: the 64-line Earlgrey head is CLEARED and the row ADVANCES to a
new 46-line head in the same file.** The design-wide census, run on the pristine
pair before a line of code was written, predicted **638 cells and only those
638**; the patched run moved **exactly 638** and the per-shape multiset moved
**exactly 957 dump lines** — the arithmetic those 638 cells imply, to the line.
Along the way the arms proved the predicate this pass replaced was wrong in
**both** directions, and the over-fire half — three shapes we have been getting
wrong since the gen-scope fold was written — is fixed as a by-product with zero
Earlgrey cells at stake.

**And the byte verifier earned its keep.** It found two corpus databases nobody
predicted: `gen_test4` (a brief-PROTECTED genscope canary) and `int_types`.
`gen_test4` moved **toward** golden and is now exact on the cells the law names.
`int_types` was the one that mattered: it exposed a SECOND half of the same law
that the encoding change alone would have left broken, turning
`UINT:18446744073709551615` into `INT:0`. The pass was rebuilt with the second
half (§ genLpFoldSignedIntReadsBitsSigned46) and every gate re-run from scratch
on the new binary; `int_types` now writes golden's `INT:-1` on all 17 cells.

* BASE COMMIT `c31af36`, branch `auto5h`. Worktrees `/tmp/wt_r10earl46`
  (patched, branch `r10earl46wt`) and `/tmp/wt_r10earl46pris` (pristine,
  detached `c31af36`). Both trees' `git rev-parse HEAD` printed and checked.
* Patched binary md5 `f428238f477f364f04f8e563dcd03f12`,
  pristine binary md5 `0752f5052bbb7c06209747018ddef20d`.
* Production diff: `include/UhdmExporter.h` (+8, one declaration) and
  `src/ModuleEmit.cpp` (one new function, two call sites rewritten, one value
  arm's digits corrected).
  Nothing else in `src/` or `include/` is touched. `slang` is NOT patched.
  `results/*.csv` were READ ONLY.

---

## 1. THE LAW

> **§ genLpFoldSignedStructural46** — A GEN-SCOPE LOCALPARAM'S FOLD IS
> INT-ENCODED (`INT:v` on the parameter's own value **and** `INT:v` +
> `vpiConstType:7` on its `param_assign` Rhs constant) WHEN THE **STRUCTURE**
> OF ITS INITIALIZER REACHES A SIGNED-MINTING ARITHMETIC OPERATOR FROM THE TOP;
> UINT-encoded (`UINT:v`, `vpiConstType:9`) otherwise.
>
> `-` `*` `/` `%` `**` and unary `-` **MINT** signed.
> `+`, unary `+`, a **constant-condition `?:`** (its **TAKEN BRANCH ONLY**) and
> a **REF to a parameter** (that parameter's own initializer, module- or
> gen-scope, at any depth) **PROPAGATE**.
> An **EXPLICIT cast SEALS** its operand.
> **EVERYTHING ELSE RESETS** to unsigned — an index, `<<`, `&`, `|`, `!`, a
> function call, a concatenation, a literal, a genvar.
>
> **THE DECLARED TYPE IS IRRELEVANT.**

and its second half, which the byte verifier forced out into the open:

> **§ genLpFoldSignedIntReadsBitsSigned46** — WHEN THE FOLD IS INT-ENCODED, THE
> DIGITS ARE THE **SIGNED** READING OF THE BITS, whatever the localparam's
> declared signedness. The `param_assign` constant arm has always done this;
> the parameter's own value did not, and nothing noticed until the encoding
> half made the INT branch reachable on an UNSIGNED `ConstantValue`.
> `localparam int unsigned y = -1` in a gen block is golden **`INT:-1`** on
> BOTH carriers — not `INT:4294967295`, and certainly not the `INT:0` that a
> 64-bit row renders as when unsigned digits are pasted after an `INT:` tag.

The `§` is greppable and appears in exactly three places in the production
tree: the declaration (`include/UhdmExporter.h`), the definition
(`src/ModuleEmit.cpp`, immediately above `emitGenScopes`) and the two call
sites, each labelled `CALL SITE 1 of 2` / `CALL SITE 2 of 2`.

### 1.1 STATED GATE == CODE GATE

Every clause above is one `case` in `UhdmExporter::genLpFoldSigned46`:

| stated clause | code |
|---|---|
| `-` `*` `/` `%` `**` mint signed | `case BinaryOp:` → `Subtract, Multiply, Divide, Mod, Power: return true` |
| unary `-` mints signed | `case UnaryOp:` → `if (ue.op == Minus) return true` |
| unary `+` propagates | `if (ue.op == Plus) return genLpFoldSigned46(ue.operand(), …)` |
| `+` propagates from EITHER operand | `case Add: return f(left) \|\| f(right)` |
| everything else resets | `default: return false` in BOTH switches |
| constant-condition `?:` takes the TAKEN BRANCH ONLY | `case ConditionalOp:` → `tryEval(cond)`, then `f(cvv9.isTrue() ? co.left() : co.right())`; a non-constant / unknown condition returns `false` |
| a REF propagates from the referenced parameter's initializer | `case NamedValue:` → `sy9.kind == Parameter` → `f(*in9)` |
| an EXPLICIT cast SEALS | `case Conversion: return ce.isImplicit() && f(operand)` |
| declared type irrelevant | the type is never consulted — `e.type` appears nowhere in the function |
| both carriers get the SAME answer | ONE function, called at both sites with the same `*ps.getInitializer()` |

The `depth > 32` guard is a cycle bound, **not** a measured frontier, and the
comment at the code says so in those words.

### 1.2 What it REPLACES, and why the replacement is not optional

Both call sites previously used a slang **visitor**: *"does a Multiply, Divide
or Power appear ANYWHERE in the tree (except under an explicit cast)"*. That
predicate is wrong in **both** directions, and this pass measured both halves:

* **UNDER-fires.** No `-`, no `%`, no propagation through a REF. Earlgrey_0_1:
  **638 cells** (§4).
* **OVER-fires.** "Anywhere" reaches through operators that RESET, so
  `ARR[x*1]`, `(ARR[x]*2) | 1`, `$clog2(ARR[x]*2+1)` and a ternary whose taken
  branch is a plain literal all came out INT where golden writes UINT
  (`b1` rows IDXMUL / ORM / FCALL / TERNU-at-x=0). **Earlgrey has ZERO such
  cells** (census Q2 parameter side: golden UINT / ours INT = **0**, before and
  after), so this half is a correctness debt paid off, not a risk taken on.

### 1.3 This is a THIRD law, not a unification

The brief warned that INT/UINT encoding laws exist across the codebase. They do,
and **they disagree with each other**, which is why none of them could simply be
reused:

| | `-` | `*` | `/` | `%` | `**` | `+` prop | `?:` | REF prop | cast seals |
|---|---|---|---|---|---|---|---|---|---|
| `ParamEmit::srlgArithFoldSigned` (§ impArithFoldSigned / § impModFoldSigned) | yes | yes | yes | yes | **no** | yes | **no** | no | n/a |
| `ExprEmit::isIntEncoded` | **no** | **no** | yes | yes | signed only | via generic recursion | **no** | via `paramIntEnc` | implicit-only |
| **`ModuleEmit::genLpFoldSigned46` (this pass)** | yes | yes | yes | yes | yes | yes | **taken branch** | yes | yes |

Both older laws were measured on their OWN carriers and **both are left exactly
as they are**. The proof that the carrier is this one and not those: the
MODULE-SCOPE control rows in both arms (`MOD_MOD = ARR[3] % W`,
`MOD_SUB = W - ARR[1]`, `MOD_ADD = W + ARR[1]`, `MOD_SEL = ARR[1]`) are
byte-identical to golden **before and after** — `rows=4 differing=0` and
`rows=2 differing=0` on both binaries.

---

## 2. THE TARGET, AND WHAT IT ACTUALLY WAS

`prim_keccak.sv:60`, inside the elaborated `gen_rho_x[0].gen_rho_y[0]`:

```systemverilog
  localparam int RhoOffset [5][5] = '{ … };
  for (genvar x = 0 ; x < 5 ; x++) begin : gen_rho_x
    for (genvar y = 0 ; y < 5 ; y++) begin : gen_rho_y
      localparam int Offset   = RhoOffset[x][y]%W;   //  <- line 60, THE HEAD
      localparam int ShiftAmt = W- Offset;           //  <- line 61
```

The head named `Offset`: golden `INT:0` / `vpiConstType:7`, ours `UINT:0` /
`vpiConstType:9`, everything else identical. Both fields are read by
`constant::Compare`.

The brief's hypothesis was that `%` was the discriminator. **`%` is only a
third of it.** The census found the population is dominated by a shape the
brief did not name — `rv_plic_target.sv:64`:

```systemverilog
    localparam int Base0 = (2**level)-1;              // already INT (via `**`)
    for (genvar offset = 0; offset < 2**level; offset++) begin : gen_level
      localparam int Pa = Base0 + offset;             // 255 cells, `+` over a REF
```

`Pa` has no `%`, no `-`, no `*` of its own. It is INT because `+` **propagates
the encoding of a REF to a sibling gen-scope localparam**. That single shape is
**269 of the 319 divergent constants** — four times the whole prim_keccak
population. A `%`-only fix would have cleared 50 of 638 cells and left the row's
biggest gen-scope population untouched.

---

## 3. THE GRID, CELL FOR CELL

Two purpose-built arms, each five gen instances, **every value non-negative in
every instance** so the independent `negSib9` arm (a negative sibling forces INT
on the whole gen array) is OFF on every row and cannot be mistaken for the
operator law. `a1` fixes the type and varies the operator; `b1` is the
**discriminator** arm — every row puts a signed-minting operator UNDER a
non-arithmetic one, which is exactly where the old visitor and the new
structural law disagree.

Reproduce: `SLANG_UHDM=<bin> ./arm46.sh a1_earl46.sv <wd>` then
`python3 grid46.py <wd>/g.dump <wd>/o.dump '[3].'`. Saved:
`grid46_pristine.txt`, `grid46_a1_patched.txt`, `grid46_b1_patched.txt`.

### 3.1 a1 — the OPERATOR and DECLARED-TYPE axes (instance [3], `ARR[3]=105`)

LHS is ALWAYS golden. `P` = the parameter's own value; `C` = the `param_assign`
Rhs constant. Both carriers always agree on both sides — that is itself a
measured result, on all 43 rows × 5 instances.

| row | init | golden | pristine ours | patched ours |
|---|---|---|---|---|
| A_MOD | `ARR[x] % W` | INT | **UINT ✗** | INT ✓ |
| B_DIV | `(ARR[x]+1) / 2` | INT | INT | INT ✓ |
| C_MUL | `ARR[x] * 2` | INT | INT | INT ✓ |
| D_SUB | `W - A_MOD` | INT | **UINT ✗** | INT ✓ |
| E_SUB2 | `256 - ARR[x]` | INT | **UINT ✗** | INT ✓ |
| F_ADD | `W + ARR[x]` | UINT | UINT | UINT ✓ |
| G_SEL | `ARR[x]` | UINT | UINT | UINT ✓ |
| H_GMOD | `x % 3` (genvar) | INT | **UINT ✗** | INT ✓ |
| I_KMOD | `7 % 3` (literals) | INT | **UINT ✗** | INT ✓ |
| J_PROP | `A_MOD + 1` | INT | **UINT ✗** | INT ✓ |
| K_MODM | `(ARR[x] % W) * 2` | INT | INT | INT ✓ |
| L_CAST | `32'(ARR[x] % W)` | UINT | UINT | UINT ✓ |
| M_POW | `2 ** (x+1)` | INT | INT | INT ✓ |
| N_UMIN | `-(0 - ARR[x])` | INT | **UINT ✗** | INT ✓ |
| T_IU | `int unsigned = ARR[x]%W` | INT | **UINT ✗** | INT ✓ |
| T_LG | `logic [31:0] = …` | INT | **UINT ✗** | INT ✓ |
| T_BT | `bit [7:0] = …` | INT | **UINT ✗** | INT ✓ |
| T_BY | `byte = …` | INT | **UINT ✗** | INT ✓ |
| T_SI | `shortint = …` | INT | **UINT ✗** | INT ✓ |
| T_IG | `integer = …` | INT | **UINT ✗** | INT ✓ |
| T_UN | UNTYPED `= ARR[x]%W` | INT | **UINT ✗** | INT ✓ |
| NEG | `x - 1` (neg sibling) | INT | INT(C) / **UINT(P) ✗** | INT ✓ |
| `x` | the genvar localparam | UINT | UINT | UINT ✓ |

**The declared-type axis is FLAT.** Seven declared types, one initializer, one
answer. The brief's grid asked whether `int` vs `int unsigned` vs `logic[31:0]`
vs `bit[7:0]` vs `byte` vs untyped discriminate: **they do not, and that is a
refutation of a plausible model, not a null result** — it is what let the fix be
a pure structural predicate with no type query in it at all.

**NEG is the row that shows the two carriers were already out of step**: at
instance [3] (`x-1 = 2`, positive) golden writes INT on BOTH carriers, we wrote
INT on the constant (via `negSib9`) and UINT on the parameter (the value arm has
no `negSib9`). The new law answers INT on both on `-`'s own merits.

`a1` verdict: pristine **15 of 23 rows differ**; patched **4**, and every one of
the 4 is `vpiSize` 64-vs-32 on an otherwise IDENTICAL encoding (§6 R1). **Zero
encoding cells remain.**

### 3.2 b1 — the DISCRIMINATOR arm (instances [0] and [3])

| row | init | golden | pristine ours | patched ours |
|---|---|---|---|---|
| IDXMUL | `ARR[x*1]` — `*` under an INDEX | UINT | **INT ✗ (over-fire)** | UINT ✓ |
| IDXMOD | `ARR[(x+4) % 5]` — `%` under an INDEX | UINT | UINT | UINT ✓ |
| SHL | `(ARR[x] % W) << 1` | UINT | UINT | UINT ✓ |
| ANDM | `(ARR[x] % W) & 255` | UINT | UINT | UINT ✓ |
| ORM | `(ARR[x] * 2) \| 1` | UINT | **INT ✗ (over-fire)** | UINT ✓ |
| TERNM | `(x>0) ? (ARR[x]%W) : 3` | **UINT at x=0, INT at x=3** | UINT / **UINT ✗** | UINT / INT ✓ |
| TERNU | `(x>0) ? (ARR[x]*2) : 3` | **UINT at x=0, INT at x=3** | **INT ✗** / INT | UINT / INT ✓ |
| FCALL | `$clog2(ARR[x]*2+1)` | UINT | **INT ✗ (over-fire)** | UINT ✓ |
| CONCM | `{2'b0, 6'(ARR[x]%W)}` | **BIN** at concat width | UINT | UINT (§6 R2) |
| LSHM | `1 << (ARR[x] % 4)` | UINT | UINT | UINT ✓ |
| MODREF | `MOD_MOD + 1` (module-scope INT param) | INT | **UINT ✗** | INT ✓ |
| SELREF | `MOD_SEL + 1` (module-scope UINT param) | UINT | UINT | UINT ✓ |
| SUBADD | `(ARR[x] - 0) + 1` | INT | **UINT ✗** | INT ✓ |
| ADDSUB | `(ARR[x] + 1) - 0` | INT | **UINT ✗** | INT ✓ |
| CASTMUL | `32'(x) * 2` — `*` OUTSIDE the cast | INT | INT | INT ✓ |
| CASTADD | `32'(ARR[x]%W) + 1` | UINT | UINT | UINT ✓ |
| MULCAST | `32'(ARR[x] * 2)` — whole tree sealed | UINT | UINT | UINT ✓ |
| UPLUS | `+(ARR[x] % W)` | INT (on C) | **UINT ✗** | INT ✓ (§6 R3) |
| UNOTL | `!(ARR[x] % W)` | UINT | UINT | UINT ✓ |

**TERNM and TERNU are the pair that pins the ternary rule.** The SAME two rows
read UINT at `x=0` (condition false, taken branch is the literal `3`) and INT at
`x=3` (condition true, taken branch is the arithmetic). Neither the condition's
presence nor the untaken branch matters — only the taken one. A rule of "a
ternary resets" would fail rows at `x=3`; a rule of "a ternary propagates from
either branch" would fail the same rows at `x=0`.

**CASTMUL vs MULCAST vs CASTADD pin the seal's extent**: the cast seals its own
subtree and nothing above it. `32'(x) * 2` is INT because the `*` is outside.

`b1` verdict: pristine **9 of 20 rows differ**; patched **2**, and both are
non-law residues (§6 R2, R3).

---

## 4. THE CENSUS — PREDICTED FIRST, THEN MEASURED

`census46.py` tallies **every** `constant` and **every** `parameter` object in
the design, **both sides**, keyed on `(section, scope path, kind, span, name,
ordinal)`, and joins on `(value-encoding prefix, vpiConstType, vpiSize,
vpiDecompile)`. It was run on the **pristine** pair
(`census46_pristine.txt`) before a line of the fix existed, and the prediction
written from it is committed **verbatim** as `CENSUS_PREDICT.txt`.

### 4.1 The prediction (from the ARTIFACT, before the patched binary existed)

| population | cells | what it is |
|---|---|---|
| CONSTANT `param_assign.vpiRhs`, span `64:27-64:41` | 255 | `rv_plic_target.sv` `Pa = Base0 + offset` |
| CONSTANT `param_assign.vpiRhs`, span `60:31-60:48` | 25 | `prim_keccak.sv` `Offset` — **the head** |
| CONSTANT `param_assign.vpiRhs`, span `61:33-61:42` | 25 | `prim_keccak.sv` `ShiftAmt` |
| CONSTANT `param_assign.vpiRhs`, span `104:38-104:52` | 14 | the flash `i_valid_random` tree, same `Base0+offset` |
| **constants subtotal** | **319** | |
| PARAMETER `gen_scope.vpiParameter`, spans `64:22 / 61:22 / 60:22 / 104:33` | **319** | the SAME four declarations, second carrier |
| **TOTAL PREDICTED** | **638** | and **0** in the other direction |

Predicted **non**-movers, stated so a move would be a failed prediction: the
73 package-parameter cells (`rstmgr_pkg`, `hmac_pkg`, `flash_ctrl_pkg`, …), the
6 module-port localparam constants, the 156 `golden UINT / ours INT` constants,
the 3 `indexed_part_select.vpiBaseExpr` over-fires, and `PARAMETER golden UINT /
ours INT = 0` staying 0.

### 4.2 The measurement (`census46_patched.txt`)

| census row | pristine | patched | delta |
|---|---|---|---|
| CONSTANT golden INT → ours UINT | 489 | **170** | **−319** |
| CONSTANT golden INT → ours INT | 19284 | **19603** | **+319** |
| CONSTANT golden UINT → ours INT | 156 | **156** | 0 |
| CONSTANT every other join row | — | — | **unchanged** |
| PARAMETER golden INT → ours UINT | 392 | **73** | **−319** |
| PARAMETER golden INT → ours INT | 566 | **885** | **+319** |
| PARAMETER golden UINT → ours INT | **0** | **0** | 0 |
| PARAMETER every other join row | — | — | **unchanged** |

**638 predicted, 638 moved, 0 in the other direction, every named non-mover
still in place.**

### 4.3 One thing the prediction got wrong, stated plainly

`CENSUS_PREDICT.txt` calls the 12-cell spans `37:17 / 34:17 / 46:17 / 31:17`
"module_inst.vpiParameter". They are in fact `gen_scope.vpiParameter` in
`topModules` — package parameters materialised into a gen scope. **The
prediction that they would not move was right and they did not move**, but the
reason recorded for it named the wrong owner field. The correct reason: they are
written by ParamEmit's package/import copy (§ impOcc territory, which the brief
fenced), not by ModuleEmit's gen-scope fold. Ranked as residue R4.

### 4.4 Two census populations that are NOISE, and why

`census46.py` keys on a span. Earlgrey's dump contains constants with **no span
and no enclosing scope** (`span '?'`, `scope '?'`), and the join therefore pairs
arbitrary members of a pool: 141 unspanned `INT→UINT` cells sit opposite 131
unspanned `UINT→INT` cells with **mismatched values** (`g=INT:1` vs `o=UINT:0`).
These are an artefact of the instrument, not a population, and they are reported
here rather than quietly dropped so that "they did not change" is a **check**
(they did not: 156 → 156) and not a claim.

---

## 5. THE FIVE GATES

Every gate below was re-run on the FINAL binary, md5
`f428238f477f364f04f8e563dcd03f12`.

**A NOTE ON WHY "RE-RUN ON THE FINAL BINARY" IS LITERAL HERE.** This pass edited
source after gates had begun, twice, and both times every gate was re-run rather
than argued about.

1. After the first patched build I found a comment in my own new function
   asserting a number I had never measured ("measured max real depth on
   Earlgrey_0_1 is 4"). I removed the claim, **killed the running sweeps,
   rebuilt, and re-asserted the md5**: it came back
   `bf263f8704eafa58994c8cf3a52a9e82`, byte-identical to the pre-edit build.
   The identity was proved, not assumed.
2. The byte verifier then found `int_types`, whose param-value digits the
   encoding change alone left broken (§1, § …IntReadsBitsSigned46). That is a
   real code change: the binary became
   `f428238f477f364f04f8e563dcd03f12`, and **gates 1–5, both arms, the Earlgrey
   run, the census, every canary script and the byte verifier were all re-run
   from scratch on it.** The four PRISTINE sweeps were NOT re-run — the
   pristine binary never changed (`0752f5052bbb7c06209747018ddef20d`, asserted
   again at the end) — and the byte verifier's PATH-SET assertion
   (1358 = 1358, 953 = 953) is what proves the two trees still line up.

| gate | result |
|---|---|
| **1 BUILD** | `/tmp/r10earl46/bld46.sh /tmp/wt_r10earl46`, ABSOLUTE paths, `-j 2`; waited for `Linking CXX executable slang-uhdm`; **0** lines matching ` error:`; md5 asserted SEPARATELY afterwards, 32 hex; binary mtime `05:47:14` vs `ModuleEmit.cpp` `05:44:47` — no gate stands on a stale binary. BASE printed and grep-checked on BOTH trees: `c31af36…` |
| **2 GOLDENS** | `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| **3 u2r** | `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in BOTH modes on BOTH binaries; testflags dump histogram `496 match / 183 differ / 52 blank`; `ct8rows.sh` vs committed `results/gate_uhdm2rtlil.csv`: **0 differing ROWS (0 diff row-sides)**; `diff` of sorted pat/pris CSVs **EMPTY in BOTH modes** |
| **4 surelog both modes** | see §5.1 |
| **5 BYTE VERIFIER** | see §5.2 |

`GOLDEN_DEFER` was left UNSET throughout (`sweeps46.sh` unsets it explicitly so
an inherited value cannot leak in). `verify_golden.py` SILENTLY DEFAULTS
`SLANG_UHDM`, so every sweep EXPORTED it and the binary each sweep ACTUALLY
invoked was read back out of that sweep's own `cmds.txt`:

```
pat : /tmp/wt_r10earl46/build/slang-uhdm
pris: /tmp/wt_r10earl46pris/build/slang-uhdm
```

(Note: `sweeps46.sh`'s inline `cmds.txt` echo greps the FIRST `*slang-uhdm`
token on the line and that token is the GOLDEN CACHE path
`/home/heyfey/.cache/slang-uhdm`, not the binary. The binary was therefore read
back with an explicit `grep -o '/tmp/wt_r10earl46[a-z]*/build/slang-uhdm'`
instead of trusting that line — the script's own echo is not evidence and is
recorded here as a defect of the harness, not as the check.)

### 5.1 GATE 4 — the surelog corpus, both modes

`ct8rows.sh results/golden_surelog.csv <fresh both-modes csv>` (the committed
authoritative baseline is READ ONLY):

```
baseline: 1589 lines = 1588 ROWS      fresh: 1589 lines = 1588 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  default    469 CMP_EQUAL   11 CMP_NOTEQUAL   5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
  testflags  465 CMP_EQUAL    8 CMP_NOTEQUAL   5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
             3 NO_DATABASE  1 NO_UHDM  1 TIMEOUT  2 UNTRANSLATABLE
---- DUMP-column histogram, base -> fresh, IDENTICAL in both modes
  default    325 blank / 244 differ / 225 match
  testflags  329 blank / 300 differ / 165 match
PASS: every row byte-identical to the committed baseline
```

`469/11` and `465/8`, `FAIL 25/23`, `DEFER 5/5`, every histogram unchanged, and
the sorted patched/pristine CSVs `diff` EMPTY in both modes (and in both u2r
modes). The pristine sweep was ALSO checked against the committed baseline as a
control: 0 differing rows.

### 5.2 GATE 5 — the byte verifier, both corpora, both modes

`SELFCHECK=1 SELFCHECK1=1 byteverify46.sh <pat root> <pris root>`, one workdir
ROOT per (corpus, binary) with BOTH modes inside it:

```
uhdm2rtlil   PATH_SETS_IDENTICAL (1358 paths)     MOVERS: 4 / 1358
  MOVER ./default/gen_test4-bdd55aa1/slang.uhdm
  MOVER ./testflags/gen_test4-bdd55aa1/slang.uhdm
  MOVER ./default/int_types-0013e833/slang.uhdm
  MOVER ./testflags/int_types-0013e833/slang.uhdm
  SELFCHECK  1357 / 1358 flagged        SELFCHECK1  5  (= 4 real + 1 corrupted)

surelog      PATH_SETS_IDENTICAL (953 paths)      MOVERS: 1 / 953
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm
  SELFCHECK   952 / 953 flagged         SELFCHECK1  2  (= 1 real + 1 corrupted)
```

Both negative controls behave exactly as specified: the all-vs-one control
flags every path, and the single-corruption control reports precisely
`real movers + 1`.

#### The MOVER RULE applied to each mover

| mover | size delta | real? | per-shape content, and DIRECTION vs GOLDEN |
|---|---|---|---|
| `Earlgrey_0_1` default | **−1195 B** | REAL by size | 957 dump lines, 3 shape families only (`\|INT`, `\|UINT`, `\|vpiConstType`); MULTISET DISTANCE vs golden **308684 → 307428** |
| `int_types` default / testflags | **−108 B / −110 B** | REAL by size | ADDED 17 × `\|INT:-1`; REMOVED 17 UINT lines; MULTISET DISTANCE vs golden **2208 → 2174**; all four `genblk*.y` parameters now EXACTLY golden (`WRONG before=2, after=0`) |
| `gen_test4` default / testflags | **0 B** | **ZERO PROVES NOTHING** — control run below | ADDED `\|INT:0`,`\|INT:1`; REMOVED `\|UINT:0`,`\|UINT:1`; MULTISET DISTANCE vs golden **10 → 6** |

**`gen_test4` is a brief-PROTECTED genscope canary and it MOVED.** Because its
size delta is zero the rule forbids concluding anything from the byte compare
alone, so a determinism control was run: the PRISTINE binary, three runs,
`md5 49fcd00d2e70` all three times (and equal to the value the sweep recorded).
`gen_test4` is byte-deterministic, so the move is real — and it is a move
**toward golden**:

```
work@gen_test4.foo[1].PREV   golden=INT:0   pristine=UINT:0   patched=INT:0   FIXED
work@gen_test4.foo[2].PREV   golden=INT:1   pristine=UINT:1   patched=INT:1   FIXED
6 parameters; disagreeing with golden BEFORE=2  AFTER=0
```

`localparam PREV = i - 1`: a Subtract. The CONSTANT carrier was already INT (via
the independent `negSib9` arm, which sees `foo[0].PREV = -1`); the PARAMETER's
own value was not, because that arm has no `negSib9`. The new law answers INT on
both, on the `-`'s own merits. The test's CSV row is byte-identical to the
committed baseline in both modes.

#### A mover that appeared in the FIRST verifier run and is NOISE

The first byte-verifier run (before the §…IntReadsBitsSigned46 half was added)
also reported `surelog ./default/Scoreboard-59431470/slang.uhdm`, with **size
delta 0** and **zero per-shape movement** — the dumps differed only in the
POSITION of `svunit_pkg` task/function objects in the weakly-referenced tail.
Per the rule, zero size delta proves nothing, so the control was run: the
**PRISTINE** binary alone, three runs of Scoreboard —

```
run 1 md5=52eca89ea7408dbb   run 2 md5=52eca89ea7408dbb   run 3 md5=79d0a9c77a9f3ce4
(all three size 11123248)
```

**Scoreboard is not byte-deterministic under the unmodified c31af36 binary.**
The "mover" was emitter nondeterminism, not this patch, and on the final run it
does not appear at all. It is reported here anyway, because a mover that
disappears on re-run is exactly the kind of thing a write-up is tempted to omit.

#### Named-database canaries, checked BY NAME

`InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`, `SVSwitch`,
`SimpleUVM`, `SeqDriver`, `BuildUVMPkg`, `Scoreboard` (surelog, both modes) and
`gen_test9`, `genvar_loop_decl_2`, `genvar_loop_decl_3`,
`paramod_genscope_child`, `genscope_cells`, `gen_test5`,
`LocalParamInNestedForLoops` (u2r, both modes): every database **byte-identical**
to pristine except the two named movers above.

**A trap caught in my own check.** An ad-hoc `cmp` over a name list reported
`surelog/testflags/Scoreboard` as MOVED. It is not: that row is `SLANG_REJECT`
and there is **no `slang.uhdm` in either tree**, and `cmp` on two missing files
exits non-zero, which reads exactly like a mover. The byte verifier is right
(it enumerates the files that exist and asserts the path SETS are identical);
the ad-hoc check was wrong. Recorded rather than quietly corrected.

#### Canary scripts

| check | result |
|---|---|
| `canaries.sh` vs committed u2r baseline | `ok=8 changed=0 absent=0`, 25 unknown-names (all surelog-only, expected) |
| `canaries.sh` vs committed surelog baseline | `ok=52 changed=0 absent=0`, 7 unknown-names (all u2r-only, expected) |
| `ctcan2.sh` u2r, baseline FIRST, `EXPECT_UNKNOWN=6` | `ok=1 changed=0 absent=0 unknown-patterns=6` → PASS |
| `ctcan2.sh` surelog, baseline FIRST, `EXPECT_UNKNOWN=1` | `ok=58 changed=0 absent=0 unknown-patterns=1` → PASS |
| `canaudit.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0` → PASS |

### 5.3 The Earlgrey head: 64 → 46, and the row ADVANCES

The pristine run reproduced the committed witness EXACTLY (`diff` of
`wd_pris/cmp.log` against `tools/probe/r10earl45repro/r6_nexthead45.cmp` is
empty — see `r6_oldhead46_pristine.cmp`). The patched run's head is 46 lines and
sits somewhere else entirely (`r6_nexthead46.cmp`):

```
prim_keccak.sv:65:61
  LHS(golden) constant  |vpiDecompile:28 |vpiSize:32 |INT:28 |vpiConstType:7
              vpiParent -> param_assign at 61:22-61:42     (the SHARED ShiftAmt fold)
  RHS(ours)   ref_obj: (…gen_rho_y[1].gen_others.theta_data.ShiftAmt)
              vpiParent -> indexed_part_select theta_data at 65:58-65:69
```

Golden SUBSTITUTES the gen-scope localparam's folded constant into the
`indexed_part_select`'s width; we keep a `ref_obj`. That is the § genLpConst
SHARE law, a different question from this pass's, and it is the next head.

Earlgrey is **byte-deterministic** under the patched binary (two full runs,
`md5 98b93a3e54d7bcb076eadaa7de850267` both times), and the patched database is
**byte-identical under BOTH patched binaries** (the one before and the one after
the §…IntReadsBitsSigned46 half), so every Earlgrey number in §4 was produced by
the final binary's own database and not carried over on trust.


---

## 6. RANKED RESIDUES

Ranked by Earlgrey_0_1 cells first, then by how sharply the shape is
characterised. Every count below is measured, not estimated.

**R1 — PACKAGE-scope arithmetic folds, 73 Earlgrey cells, THE NEXT PASS.**
The single largest remaining `golden INT / ours UINT` PARAMETER population, and
it is one shape:

| span | declaration | golden | ours |
|---|---|---|---|
| `flash_phy_pkg.sv:31` | `parameter int AddrBitsRemain = DataWidth % BusWidth` | INT | UINT |
| `flash_phy_pkg.sv:34` | `parameter int WidthMultiple = DataWidth / BusWidth` | INT | UINT |
| `flash_phy_pkg.sv:37` | `parameter int FlashWordsPerPage = WordsPerPage / WidthMultiple` | INT | UINT |
| `flash_phy_pkg.sv:46` | `parameter int PrimFlashAddrW = BankAddrW - LsbAddrBit` | INT | UINT |
| `rstmgr_pkg.sv:11` | `localparam int OffDomains = PowerDomains-1` | INT | UINT |
| `hmac_pkg.sv:18` | `localparam int WordByte = $bits(sha_word_t)/8` | INT | UINT |
| `flash_ctrl_pkg.sv:21` | `localparam int FlashTotalPages = NumBanks * PagesPerBank` | INT | UINT |

`%`, `/`, `-`, `*` at the top — every one of which `ParamEmit`'s
`srlgArithFoldSigned` **already answers correctly**. So the defect is not the
predicate: it is that the PACKAGE parameter's own `VpiValue` is written by a
path that never asks it. Each declaration shows up in `topPackages`,
`allModules` and `topModules` alike (12, 5, 5, 7 cells …), i.e. the package
copy is materialised several times and every copy carries the same wrong
encoding. **This is fenced territory** (§ psBoundPkgParamTs31 /
`stampFoldedPkgParamTs`), which is exactly why this pass did not touch it and
why it is the obvious next one: one predicate that already exists, called from
one more place, 73 cells.

**R2 — the `vpiSize` axis on the gen-scope fold constant, 0 Earlgrey cells, 20
arm cells.** After this pass EVERY remaining difference in arm `a1` is
`vpiSize` 64 vs 32 on an otherwise IDENTICAL encoding: rows `A_MOD`
(`ARR[x] % W`), `D_SUB` (`W - A_MOD`), `T_UN` (untyped) and `NEG` (`x - 1`) —
all five instances each. Rows `E_SUB2` (`256 - ARR[x]`), `H_GMOD` (`x % 3`) and
`I_KMOD` (`7 % 3`) are size 32 on BOTH sides, so it is NOT "every INT fold is
64". The discriminator is **not yet found** and I will not guess it: what is
established is that it is orthogonal to this pass (Earlgrey's `Offset` and
`ShiftAmt` are size 32 on both sides, which is why this residue costs the row
nothing today).

**R3 — the CONCAT fold's encoding, 0 Earlgrey cells, 5 arm cells.** `b1`'s
`CONCM = {2'b0, 6'(ARR[x] % W)}`: golden writes `BIN:00101001` /
`vpiConstType:3` / `vpiSize:8` / `vpiDecompile:8'b00101001`; we write
`UINT:41` / ct9 / size 32 / `41`. A concatenation RESETS under this pass's law
and we correctly write UINT — the divergence is a *different* law (a
concat-valued fold renders BINARY at the concat's own width), pre-existing and
untouched.

**R4 — `+(expr)`: golden omits the parameter's own value, 0 Earlgrey cells, 5
arm cells.** `b1`'s `UPLUS = +(ARR[x] % W)`: after this pass the param_assign
constant matches golden's encoding exactly (`INT:41` / ct7), but golden emits
**no `VpiValue` at all** on the parameter object while we emit `INT:41`, and
golden's constant is `vpiSize:64` against our 32 (the same axis as R2). Two
independent sub-residues on one row.

**R5 — 3 `indexed_part_select.vpiBaseExpr` over-fires, 3 Earlgrey cells.**
`golden UINT:0 ct9 size 64` vs `ours INT:0 ct7 size 64`, at spans
`128:32-128:33`, `178:32-178:33`, `185:32-185:33`. A pre-existing over-fire in
a different emitter. Counted before and after: **3 both times**. It must not
grow.

**R6 — 6 module-port localparam constants, 6 Earlgrey cells.** Spans
`10:32-10:35`, `16:32-16:35` (2 each, the `gen_generic` flash instances),
`8:30-8:32` and `207:35-208:82` (1 each). `module_inst`-owned, ParamEmit's
carrier, unmoved by design.

**R7 — census instrument: unspanned constants cannot be span-keyed.** 141
`INT→UINT` and 131 `UINT→INT` `constant` cells carry NO span and NO enclosing
scope, and the join therefore pairs arbitrary pool members (their VALUES do not
even match: `g=INT:1` opposite `o=UINT:0`). They are stable across this pass
(156 → 156 on the `UINT→INT` side) and are reported as an instrument limit, not
a population. A future census should key these on a parent chain instead.

**R8 — the NEXT HEAD, `prim_keccak.sv:65:61`.** Golden substitutes the
gen-scope localparam's folded constant into the `indexed_part_select` width and
parents it at the localparam's own `param_assign`; we keep a `ref_obj` to
`ShiftAmt`. `r6_nexthead46.cmp` is the committed witness. This is the
§ genLpConst SHARE law one step further out, and it is the row's next 46 lines.

**R9 — `sweeps46.sh`'s "cmds.txt binary:" echo is not evidence.** See §7 R-5.
Fixing the harness script is out of scope for this pass; the line should be
`grep -o '/tmp/wt_[^ ]*/build/slang-uhdm'` or equivalent, and until it is,
every pass that quotes it is quoting the golden-cache path.

**R10 — a partial dump reads exactly like a result.** Mid-pass I ran the census
against `wd_pat/o.dump` while `uhdm-dump` was still writing it (4 076 318 of
4 655 216 lines). The census returned a clean, plausible, completely wrong
table (`golden INT / ours UINT = 21` instead of 170) and `shapes46.sh` reported
632 129 REMOVED instances. Nothing in either instrument said "truncated". Both
should assert the input's line count against the producer's own reported count
(`earl46.sh` already prints `o.dump lines=…`); until they do, the only defence
is to wait for the producer to exit — which is what the final numbers here did.


---

## 7. REFUTATIONS, STATED PLAINLY

**R-1. "`%` is the discriminator" — TRUE BUT SMALL.** The brief's stated
hypothesis is correct for the head cell and correct for 50 of 638 cells. It is
**not** the population. `+`-propagation-through-a-REF (`Pa = Base0 + offset`) is
**538 of the 638**, and a `%`-only patch would have cleared 8% of the divergence
and left the head's own file half-fixed (`ShiftAmt`, a `-`, would still be UINT
25 times over).

**R-2. "Grid the declared type" — REFUTED, FLAT.** `int`, `int unsigned`,
`logic [31:0]`, `bit [7:0]`, `byte`, `shortint`, `integer` and UNTYPED all give
the SAME answer for the SAME initializer, on both sides, in all five instances.
The declared type is not a discriminator at this carrier at all, and the final
predicate never queries a type.

**R-3. "The fold carrier is likely ParamEmit's gen-scope path or the elab
select-fold." — REFUTED.** It is neither. It is `ModuleEmit::emitGenScopes`'s
own inline gen-scope localparam fold. The proof is the module-scope control rows
in both arms, which are byte-identical to golden before AND after the patch:
had the carrier been ParamEmit, those four rows would have moved.

**R-4. My own predicate could have been the visitor plus `%` and `-`. That
would have been WRONG.** `b1` measures three shapes where the existing
"anywhere" visitor **already** disagrees with golden in the opposite direction
(`ARR[x*1]`, `(ARR[x]*2)|1`, `$clog2(ARR[x]*2+1)`). Widening the visitor would
have added `%` and `-` to those over-fires as well. The structural walk is not
the "bigger" change — it is the **smaller error**.

**R-5. A cited guard that does not check what the citation claims.**
`sweeps46.sh` prints a "cmds.txt binary:" line that in fact prints the golden
CACHE path. It is inherited verbatim from earlier passes, so **every earlier
README that quoted that line as proof of which binary a sweep invoked quoted a
line that cannot show that.** The real check is in §5 and it is a different
command. The script is left as-is (harness edits are out of scope for this
pass) and the defect is recorded here and in `README.verifier.md`'s territory.

**R-5b. "The two carriers always agree" was true of the ENCODING and NOT of the
DIGITS — and I wrote the claim before I had checked the second half.** §3.1's
statement that Surelog writes the same answer to both carriers held on all 43
arm rows because no arm row has unsigned bits with the MSB set. `int_types`
does, and there the parameter value and the constant disagreed in OUR output on
the digits even after the encoding matched. The claim is now true of both
fields, but it became true because the byte verifier found the counterexample,
not because the arms proved it.

**R-6. Nothing here says the `negSib9` arm is right.** It was left byte-for-byte
alone. The new law happens to subsume it for `gen_test4`'s `PREV = i-1` (a
Subtract answers INT on its own merits now), but whether a negative sibling
*independently* forces INT was NOT re-measured and is NOT claimed.

---

## 8. REPRODUCING

```sh
# pristine + patched worktrees at c31af36, both built -j 2
/tmp/r10earl46/bld46.sh /tmp/wt_r10earl46pris
/tmp/r10earl46/bld46.sh /tmp/wt_r10earl46

# the head, before and after
SLANG_UHDM=/tmp/wt_r10earl46pris/build/slang-uhdm ./earl46.sh /tmp/r10earl46/wd_pris
SLANG_UHDM=/tmp/wt_r10earl46/build/slang-uhdm     ./earl46.sh /tmp/r10earl46/wd_pat

# the grid
SLANG_UHDM=<bin> ./arm46.sh a1_earl46.sv /tmp/r10earl46/arm_a1
python3 grid46.py /tmp/r10earl46/arm_a1/g.dump /tmp/r10earl46/arm_a1/o.dump '[3].'

# the census, both sides, design-wide
uhdm-dump <golden.uhdm> | sed 1d > g.dump
python3 census46.py g.dump /tmp/r10earl46/wd_pris/o.dump   # -> census46_pristine.txt
python3 census46.py g.dump /tmp/r10earl46/wd_pat/o.dump    # -> census46_patched.txt

# movers, per shape, by MULTISET, ADDED and REMOVED separately
./shapes46.sh /tmp/r10earl46/wd_pris/o.dump /tmp/r10earl46/wd_pat/o.dump
./msdist.sh g.dump /tmp/r10earl46/wd_pat/o.dump
```

`README.verifier.md` is the VERIFIER's to author and is deliberately absent here.
