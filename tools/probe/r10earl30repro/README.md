# r10earl30 — § enumSubstIntConst30

**THE HEADLINE, FIRST: `Earlgrey_0_1/default` does NOT convert.** The head this
pass was given is **CLEARED** — the row's cmp goes **36 lines → 17** and the
first divergence moves off the constant entirely — but clearing it exposes a
**second, pre-existing head** (a missing `ref_typespec` on a folded package
*parameter* at `dm_csrs.sv:408`, §6 R1). The row therefore stays
`CMP_NOTEQUAL`, byte-identical to the committed baseline:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,        <- fresh (patched)
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,        <- results/golden_surelog.csv
```

Row counts are unchanged (default **467/13**, not 468/12), so there is nothing
for an integrator to promote and `results/*.csv` were not edited.

---

## 0. THE LAW

> **§ enumSubstIntConst30 — a constant minted by COPYING an `enum_const`'s
> `VpiValue` takes its `vpiConstType` FROM THAT VALUE'S ENCODING PREFIX, and an
> `INT:` value is `vpiIntConst` (7), NEVER `vpiUIntConst` (9).**

`vpi_user.h:491,493` — `#define vpiIntConst 7`, `#define vpiUIntConst 9`. The
two call sites that mint these constants ran a `BIN:/HEX:/OCT:/DEC:` ternary
chain that was **missing its `INT:` arm** and fell through to `vpiUIntConst`, so
every implicit-valued package enum member folded to a **self-inconsistent
object**: value `INT:0`, `vpiConstType:9`.

**The whole code change is two lines** — the same line at each site:

```cpp
: v.rfind("INT:", 0) == 0 ? vpiIntConst
```

**STATED GATE == CODE GATE.** The gate is `v.rfind("INT:", 0) == 0` on the
value string copied out of the `enum_const`, and nothing else. There is no
context test, no scope test, no view test, no base-type test — because §3 shows
none of those discriminate. Everything the rule does not recognise keeps its
previous answer, so every unmeasured origin **abstains by construction**.

| # | call site | what mints the constant | arm |
|---|---|---|---|
| 1 | `src/ExprEmit.cpp` ~5169 | a **qualified `pkg::MEMBER` enum reference folded in a module expression** (the Earlgrey witness) | g1/g2/g3/g5 |
| 2 | `src/ModuleEmit.cpp` ~23806 | an **interface elab-view `cont_assign`** whose RHS ref binds a package enum const | g6 |

The identical law was **already written out twice** in this codebase and those
two sites never got it: `enumMemberSubstConst` (`ExprEmit.cpp` ~3141, the
struct-pattern / parameter substitution) and `ParamEmit.cpp` ~12642 (an
enum-typed parameter's RHS). That is the corroboration that made this a
transcription rather than a guess.

Both sites were **measured before being changed**; site 2 was not fixed by
analogy (§3.4).

---

## 1. LOCALIZATION — which field, on which object

Read from the **generated** Compare in `~/git-repos/UHDM`, not guessed.
`build/generated/src/constant.cpp` — `constant::Compare` reads **exactly one
field of its own**:

```cpp
if ((r = basetype_t::Compare(other, context)) != 0) return r;
if ((r = lhs->VpiConstType() - rhs->VpiConstType()) != 0) { ...; return r; }
```

and its base, `build/generated/src/expr.cpp` — `expr::Compare` — reads three
more, **all of them BEFORE** `vpiConstType` gets a chance:

```cpp
if ((r = lhs->VpiDecompile().compare(rhs->VpiDecompile())) != 0) { ... }
if ((r = lhs->VpiSize() - rhs->VpiSize()) != 0) { ... }
if ((r = SafeCompare(lhs->Typespec(), rhs->Typespec(), context)) != 0) return r;
```

Two consequences that shaped this pass:

* **`VpiValue` IS NEVER COMPARED.** Nothing in the chain reads it. The value is
  nonetheless the *carrier of the law* — it is where the enum member's written
  form survives — so this pass reads it as **evidence** and never as a head.
* **`VpiDecompile` and `Typespec` fire FIRST.** A constant whose decompile or
  typespec also differs can never expose its `vpiConstType`, which is exactly
  why the fixed witness hands the row to a `Typespec` head (§6 R1) and why the
  based-decimal cells in §3.3 stay stuck on their decompile (§6 R3).

The witness, measured on the target at 81b8e0c and re-measured here:

```
SOURCE  dm_csrs.sv:389:  end else if (cmderr_q == dm::CmdErrNone) begin
GOLDEN  constant @389:36-389:50  vpiDecompile:0 vpiSize:3 INT:0 vpiConstType:7
OURS    constant @389:36-389:50  vpiDecompile:0 vpiSize:3 INT:0 vpiConstType:9
```

Field-identical in **every** field except the one. `dm::cmderr_e` is
`typedef enum logic [2:0] { CmdErrNone, CmdErrBusy, ... CmdErrOther = 7 }`
(`dm_pkg.sv:135`) — an implicit-valued member of a `logic [2:0]`-based enum.

---

## 2. THE MECHANISM — where the encoding actually comes from

The `enum_const` objects themselves are **byte-identical between golden and
ours** on every arm, and they carry **no `vpiConstType` at all**:

```
GOLDEN                                   OURS
\_enum_const: (A0), line:6:37            \_enum_const: (A0), line:6:37
  |INT:0                                   |INT:0
  |vpiDecompile:0                          |vpiDecompile:0
  |vpiSize:3                               |vpiSize:3
```

So Surelog's substitution is a **copy of the `enum_const`**, and the folded
constant's `vpiConstType` is *derived* from the copied value. We already copied
value, size and decompile correctly; we recomputed the const type and got it
wrong. **This is why the fix is not a `9 -> 7` flip: it is a `derive it from the
value you already copied` rule.** A blanket `9 -> 7` would have destroyed the
77,171 legitimately-`vpiUIntConst` constants Earlgrey's golden contains (§4).

The discriminator the brief expected to find on axis (a)/(b)/(c)/(d) turns out to
be **the enum MEMBER'S OWN WRITTEN FORM**, and it is *already encoded in the
value*, which is why the shipped gate needs no new predicate:

| member written as | `enum_const` value | size | golden folded ct |
|---|---|---|---|
| implicit (`E0`, `E1`) | `INT:n` | the enum base width | **7** |
| based (`I0 = 3'd0`, `Y1 = 4'h5`) | `INT:n` / `HEX:n` | the literal's width | **7** / 5 |
| **unsized decimal** (`J0 = 0`) | `UINT:n` | **64** | **9** |

The last row is the negative control that proves the rule is the value and not
the enum: `J0`/`J1` in `g3_base.sv` **already matched golden at 9 before this
change** and are untouched by it.

---

## 3. THE GRID, CELL FOR CELL

Six arms, one axis each, `arm30.sh` (LHS always golden, `sed 1d` both dumps,
binary md5 printed on every run). The instrument is `ctcensus.py`, which
cross-tabs every constant by **(value encoding prefix, `vpiConstType`)** —
because a count of `vpiConstType:9` alone can never price this rule, while the
**joint** cell `(INT:, 9)` is exactly the self-inconsistent object the two sites
produce.

### 3.0 THE ONE-LINE RESULT

```
                  golden (INT:,7)   ours BEFORE   ours AFTER      (INT:,9): golden / ours before / ours after
g1_ctx  contexts        14                1           14   ok         0 / 13 / 0
g2_origin origins        7                2            4   §3.2       0 /  2 / 0
g3_base base types      16                0           16   ok         0 / 16 / 0
g4_ctrl OVER-FIRE CTL    5                5            5   ok         0 /  0 / 0
g5_scope scopes          7                0            7   ok         0 /  7 / 0
g6_iface 2nd call site   2                0            2   ok         0 /  2 / 0
```

**`(INT:, 9)` does not exist in golden in ANY arm, and our 40 occurrences of it
go to 0.** Five of six arms land on golden's count **exactly**; g2's shortfall is
three cells on *other origins* whose value is wrong upstream, where this rule
correctly abstains (§3.2).

**The patch's total effect on every arm dump, paths normalized:**

```
g1_ctx    13 x  |vpiConstType:9  ->  |vpiConstType:7   and NOTHING else
g2_origin  2 x  ... same
g3_base   16 x  ... same
g5_scope   7 x  ... same
g6_iface   2 x  ... same
g4_ctrl    NO LINES CHANGED AT ALL
```

No other field, no other object, no re-parenting, no span change. The over-fire
control is **byte-identical** before and after.

### 3.1 g1_ctx — the CONTEXT axis does NOT discriminate

Origin held at the witness's (a `logic [2:0]`-based package enum literal), both a
ZERO and a NONZERO member in each context. Golden reads **7 in every one**:

| cell | context | golden | ours before | after |
|---|---|---|---|---|
| o1 26:14 | `if (q == p1::E0)` — **THE EARLGREY WITNESS** | 7 | 9 | **7** |
| o2 27:19 | `else if (q == p1::E1)`, nonzero member | 7 | 9 | **7** |
| o3/o4 32:23, 34:23 | cont-assign comparison, **x2 = def AND elab view** | 7 | 9 | **7** |
| o5/o6 39:24, 40:24 | procedural assignment RHS | 7 | 9 | **7** |
| o7 44:21 | **select index** `mem[p1::E1]` | 7 | 9 | **7** |
| o8 47:23 | **concatenation element** `{5'b0, p1::E2}` | 7 | 9 | **7** |
| o9 52:7, 53:7 | **case ITEM** | 7 | 9 | **7** |
| o10 59:23 | localparam initializer (`param_assign` Rhs) | 7 | 9 | **7** |

The VIEW axis (c) is settled by o3/o4 and o9: the same span carries **two**
constants (def and elab) and both move together, so there is no view split.

Two contexts in this arm have a divergence that is **not** a `vpiConstType`
divergence and are left alone: the localparam initializer, where we emit one
**extra** constant and golden's def-view copy spans `59:23-59:27` while ours
spans `59:23-59:29` (residue R4), and the packed range bound `logic [p1::E3:0]`,
where we emit a `UINT:7` constant golden does not have at that span (residue R4).

### 3.2 g2_origin — the ORIGIN axis, and the THREE cells that must abstain

Context held at the witness's (right operand of `==`). This arm is also the
**over-fire census** for the rule.

| cell | origin | golden | ours before | after | verdict |
|---|---|---|---|---|---|
| c1 29:14 | **package enum literal, value 0** | `(INT:,7)` | `(INT:,9)` | **`(INT:,7)`** | MOVER |
| c2 31:14 | **package enum literal, value != 0** | `(INT:,7)` | `(INT:,9)` | **`(INT:,7)`** | MOVER |
| c3/c4 33, 35 | **MODULE-scope enum literal** | *no constant* | *no constant* | *no constant* | never folded — the rule cannot reach it |
| c5 37:14 | plain package parameter (`int PI = 3`) | `(UINT:,9)` | `(UINT:,9)` | `(UINT:,9)` | **must not move — did not** |
| c6 39:14 | sized package parameter (`logic [2:0] PL = 3'd3`) | `(INT:,7)` dc=3 | `(DEC:,1)` dc=`3'd3` | unchanged | **ABSTAINS** (our value is `DEC:`) — residue R5 |
| c7 41:14 | **enum-typed package parameter** (`e_t PE = E1`) | `(INT:,7)` | `(UINT:,9)` | unchanged | **ABSTAINS** (our value is `UINT:`) — residue R5 |
| c8/c9 43, 45 | module localparam, enum-typed module localparam | *no constant* | *no constant* | *no constant* | never folded |
| c10 47:14 | division fold | *no constant* | — | — | never folded |
| c12 51:14 | unsized integer literal `3` | `(UINT:,9)` | same | same | **must not move — did not** |
| c13 53:14 | sized literal `3'd3` | `(DEC:,1)` | same | same | **must not move — did not** |
| c14 55:23 | cast `p2::e_t'(1)` | `(UINT:,9)` | same | same | **must not move — did not** |
| c15 57:14 | `$bits(p2::e_t)` | `(UINT:,9)` | same | same | **must not move — did not** |
| c16 63:29 | **genvar** fold | `(UINT:,9)` | same | same | **must not move — did not** |
| — 13:33 | the package parameter object itself | `INT:1` | `UINT:1` | unchanged | **ABSTAINS** — residue R5 |

c6/c7/13:33 are the three cells that keep g2 below golden's count. In all three
the divergence is in the **value**, one layer upstream; the shipped rule derives
the const type *from* the value, so it necessarily and correctly abstains until
the value is fixed. **Deriving the const type from something other than the value
in order to "reach" those cells would have been the over-fire the brief warned
about.**

### 3.3 g3_base — the BASE TYPE axis does NOT discriminate

All 9 enum flavours, package origin, comparison context, zero and nonzero member
(18 cells). Golden reads **7 for 16 of the 18** and the two exceptions are the
`UINT:` control:

| base type | golden ct | golden size | moved |
|---|---|---|---|
| `logic [2:0]` — **the witness (`dm::cmderr_e`)** | 7 | 3 | yes |
| `logic [7:0]` | 7 | 8 | yes |
| `logic signed [2:0]` | 7 | 3 | yes |
| `bit [1:0]` | 7 | 2 | yes |
| `int` | 7 | 32 | yes |
| **no base type** | 7 | **64** | yes |
| `byte` | 7 | 8 | yes |
| `logic [2:0]` with `I0 = 3'd0` (based init) | 7 | 3 | yes (ct); decompile still differs — R3 |
| `logic [2:0]` with `J0 = 0` (**unsized init**) | **9** | **64** | **NO — matched already** |

Signedness of the base is **not** the discriminator (`logic signed [2:0]` and
`bit [1:0]` both read 7), and neither is width, nor `int`-ness.

**Arm head advance:** g3's first divergence moves from `constant @21:14` (the
witness cell) to `constant @35:14` (the based-init decompile residue) — the
`vpiConstType` head cleared, on the arm, and the next layer named.

### 3.4 g5_scope / g6_iface — scope, qualification, and the SECOND call site

`g5_scope`: qualified-under-wildcard-import, function body, task body,
`always_ff`, named `begin` block and generate-if **all read 7** and all moved
(7/7). The **unqualified** references (`q == S0` resolved through
`import p5::*`) produce **no constant on either side** — they stay `ref_obj`s —
which is why the shipped rule cannot touch them. A fold **inside the package
itself** (`localparam logic PKGHIT = (S1 == S0)`) is a different pre-existing
shape (R4) and is unreachable from this site, which requires the enclosing object
to be a `module_inst`.

`g6_iface` **measured the second call site instead of assuming it**: golden
`(INT:,7)` x2 / ours `(INT:,9)` x2, moved to 2/2, while the `HEX:` member
(`Y1 = 4'h5`) stays `vpiHexConst` and the unsized-decimal member (`Z1 = 1`) stays
`vpiUIntConst` on both sides. See §5.3 for what that arm **refuted**.

---

## 4. THE CORPUS CENSUS, RUN BEFORE CODING

The brief warned `vpiConstType` has wide reach. It does not — and the census
says so with a number, on the target design itself
(`Earlgrey_0_1/default`, complete dumps, `sed 1d` both):

```
VALUE     ct           GOLDEN       OURS     delta
BIN:      3             16791      16703       -88
DEC:      1               567        567        +0
HEX:      5             17877      17809       -68
INT:      7             22937      19670     -3267
INT:      9                 0         12       +12   <== the predicted mover set
INT:      NONE             64         64        +0
NOVAL:    NONE          18847      15431     -3416
STRING:   6              1125       1125        +0
UINT:     9             77171      75252     -1919
---- totals: golden 155475 constants, ours 146747
```

**`(INT:, 9)` occurs ZERO times in 155,475 golden constants.** The
self-inconsistent pair is an *invariant violation*, not a policy choice — which
is the strongest form the prediction could have taken. And the predicted mover
set on the whole design is **12 objects out of our 146,747**: the 77,171
`(UINT:,9)` constants a blanket flip would have destroyed are untouched, by
construction.

**Prediction checked after coding:** ours `(INT:,9)` **12 → 0**, ours
`(INT:,7)` **19670 → 19682** (`= 19670 + 12`). Exact.

---

## 5. EVERY MOVER ATTRIBUTED, PER SHAPE, BY MULTISET

`mv30.sh` takes the multiset delta of dump lines (indentation stripped) and looks
every distinct changed shape up in **golden** with a per-shape `grep -Fxc`, ADDED
and REMOVED separately, with a `SELFCHECK=1` fabricated-shape control.

```
== Earlgrey_0_1/default: ADDED instances=13 over 2 shapes; REMOVED instances=13 over 2 shapes
  ADDED   x1  golden=0                       OVER-FIRE   \_FABRICATED_SHAPE_r10earl30  <- the CONTROL, correct
  REMOVED x12 golden=77171 ours_after=75252  UNDER-FIRE  |vpiConstType:9               <- INSTRUMENT ARTIFACT, §5.2
  ADDED  : 1 covered, 1 OVER-FIRE (the fabricated one only)
  REMOVED: 1 correct, 1 UNDER-FIRE
```

Byte movers, both corpora, against my own pristine 81b8e0c build:

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
             SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 2 / 953
             SELFCHECK 952/953 flagged        SELFCHECK1 = 3  (= 2 real + 1 injected)
             MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm
             MOVER ./default/Scoreboard-59431470/slang.uhdm    <- NOT this pass, §5.1
```

### 5.1 The Scoreboard mover is NOT attributable to this pass, and it is PROVED

Four independent measurements, not one, and the fourth is conclusive:

1. **Multiset delta ZERO.** `msdist.sh` (@7c7eaa6, md5 `7c0d46b5…`) on the two
   Scoreboard dumps: `golden-only 0 / ours-only 0 / MULTISET DISTANCE 0`, at
   1,096,959 lines each. The two databases are a **pure permutation**.
2. **The law has nothing to change there.** `ctcensus.py` on both Scoreboard
   dumps: the `(INT:, 9)` cell **does not exist on either side** — 0 objects for
   the rule to touch — and every other cell is identical
   (`(INT:,7)` 145/145, `(UINT:,9)` 8757/8757, 24,066 constants both).
3. This is the **already-recorded** per-run instability (r10earl29 §8 R7;
   campaign memory *emitter-nondeterminism*: `SourceLocation` compares across
   macro buffers flip per run under parallel parse).
4. **THE DETERMINISM CONTROL: the PRISTINE, UNPATCHED binary reproduces BOTH
   SIDES of the "mover" by itself.** Three runs of
   `.claude/worktrees/r10earl30pris/build/slang-uhdm` on identical Scoreboard
   inputs, same command line, same output path:

   ```
   run 1  0b955173a977f5ea0d8af0dbae35455a
   run 2  1e7fc54075e42c3e2abbb6a1ef0dcb22
   run 3  0b955173a977f5ea0d8af0dbae35455a
   ```

   and the byte verifier's report for that row was
   `patched=0b955173a977  pristine=1e7fc54075e4`. **Both of the verifier's two
   md5s are outputs the UNPATCHED binary produces**, so the row's "movement" is
   entirely the pre-existing instability and carries no information about this
   patch. Control kept at `/tmp/r10e30_sbdet` (identical 11,146,883-byte files,
   two distinct md5s).

### 5.2 The `UNDER-FIRE` flag on `|vpiConstType:9` is an INSTRUMENT ARTIFACT

Stated plainly because the campaign has been burned by aggregates: **a bare field
line has no owner once indentation is stripped**, so `|vpiConstType:9`'s
multiplicity is a whole-database aggregate. Golden holds 77,171 of them because
77,171 of its constants are *legitimately* `vpiUIntConst`; our dropping 12 says
nothing about whether the 12 we dropped were right. `mv30.sh`'s own header
records this and refuses to let the aggregate stand as the attribution.

**THE ATTRIBUTION IS THE SPAN-KEYED ONE**, and it is exact in both directions on
all 12, every other field agreeing:

| span | source | golden | ours before | ours after |
|---|---|---|---|---|
| 389:36-389:50 | `dm_csrs.sv` `cmderr_q == dm::CmdErrNone` — **THE WITNESS** | `ct=7 INT:0 sz=3 dc=0` | `ct=9` | **`ct=7`** |
| 390:24-390:38 | `dm_csrs.sv` `cmderr_d = dm::CmdErrBusy` — the NONZERO member | `ct=7 INT:1 sz=3 dc=1` | `ct=9` | **`ct=7`** |
| 400:36, 410:36 | `dm_csrs.sv` — two more `== dm::CmdErrNone` | `ct=7 INT:0` | `ct=9` | **`ct=7`** |
| 401:24, 411:24 | `dm_csrs.sv` — two more `= dm::CmdErrBusy` | `ct=7 INT:1` | `ct=9` | **`ct=7`** |
| 575:25, 602:41 | `dm_csrs.sv` `cmderr_q <= dm::CmdErrNone` — **nonblocking** RHS | `ct=7 INT:0` | `ct=9` | **`ct=7`** |
| 134:24 | `dm_mem.sv` `cmderror_o = dm::CmdErrNone` | `ct=7 INT:0` | `ct=9` | **`ct=7`** |
| 149:24 | `dm_mem.sv` `cmderror_o = dm::CmdErrorHaltResume` | `ct=7 INT:4 dc=4` | `ct=9` | **`ct=7`** |
| 193:20 | `dm_mem.sv` `cmderror_o = dm::CmdErrNotSupported` | `ct=7 INT:2 dc=2` | `ct=9` | **`ct=7`** |
| 198:20 | `dm_mem.sv` `cmderror_o = dm::CmdErrorException` | `ct=7 INT:3 dc=3` | `ct=9` | **`ct=7`** |

**12 movers, 12 landing exactly on golden, 0 moved away, 0 over-fire.** Every one
is a `dm::cmderr_e` read; four distinct members including the brief's requested
non-zero `dm::CmdErrBusy`; three contexts (comparison operand, blocking
assignment RHS, non-blocking assignment RHS).

Whole-design multiset distance to golden: **309605 → 309589** (−16), dump line
count unchanged at 4,654,873 vs golden's 4,823,448.

### 5.3 WHAT THIS PASS REFUTED

* **The brief's axis model.** It proposed the discriminator was some combination
  of origin, context, view and enum base type, and asked for a grid over all
  four. The grid says **none of them discriminate**: 40 of 40 cells with an
  `INT:` value read 7 in golden regardless. The real discriminator is the enum
  member's own written form, and it is already carried in the copied value — so
  the shipped rule needs no new predicate at all. Had I built a
  context-or-base-type gate to match the brief's model, it would have been
  strictly worse and would have missed cells.
* **`ModuleEmit.cpp` ~23795's own comment**, which says the interface elab fold
  is `LOC-LESS`. `g6_iface.sv` shows golden folds it **at the written span in the
  DEF interface view** and **SHARES that one object** into the elab view
  (`g.dump` lines 764 and 1100 are the same object at `line:21:14`); we mint a
  fresh loc-less one per elab view and keep a `ref_obj` in the def view — golden
  51 constants there, ours 47. Recorded, **not** touched (residue R2).
* **My own first instrument.** See §7 — it faked an over-fire.
* **"`vpiConstType` has WIDE reach potential."** Measured: 12 objects on the
  target, 0 on all 679 u2r rows, 0 on 951 of 953 surelog rows.

---

## 6. RANKED RESIDUES

Ranked by measured reach on a real row, most valuable first.

**R1 — `Earlgrey_0_1/default`'s NEW head: a MISSING `ref_typespec` on a folded
package PARAMETER.** `dm_csrs.sv:408`,
`abstractauto_d.autoexecdata = 12'(dmi_req_i.data[dm::DataCount-1:0]);`

```
GOLDEN  constant @408:65-408:69  vpiDecompile:4'h2 vpiSize:4 HEX:2 vpiConstType:5
          +-- ref_typespec (work@dm_csrs.csr_read_write.dmi_req_i.data[4'h2 - 1:0].data)
                +-- logic_typespec @25:14-25:25
OURS    constant @408:65-408:78  vpiDecompile:4'h2 vpiSize:4 HEX:2 vpiConstType:5
          (no Typespec at all)  ->  cmp reports `RHS: <null>`
```

**Two divergences, neither of them mine:** the SPAN (golden ends col 69, ours col
78) and the missing `ref_typespec`. `expr::Compare` reaches `Typespec()` before
`constant::Compare` ever runs, which is why this is now the row's blocker at cmp
depth **17** (was 36). Different origin (a package *parameter*, `vpiHexConst`),
different field — squarely outside this pass's assigned field, and it belongs to
the campaign-memory *typespec-linkage* cluster. **This is the next thing to look
at for this design.** Proved pre-existing: my patch's entire effect on this
database is 12 `|vpiConstType:9`→`:7` lines (§5), and `408:65` is not one of the
12 spans.

**R2 — the interface elab `cont_assign` fold is loc-less and un-shared.** §5.3.
Golden: one located constant in the def view, shared into elab. Ours: a fresh
loc-less one per elab view, and a `ref_obj` left in the def view. 4 constants
missing per interface on `g6_iface`; the arm's dump diff is unchanged at 118
sides by this pass because that residue dominates it. An object-COUNT/SPAN law.

**R3 — `§ enumSubstDecBare` is missing at `ExprEmit.cpp` ~5165.** A **based**
enum member loses its base in the substituted copy: golden writes decompile `0`
for `I0 = 3'd0` while the `enum_const` itself keeps `3'd0`. We copy
`src->VpiDecompile()` verbatim. Measured: `g3_base.sv` cells `35:14` and `36:14`,
golden `dc=0`/`dc=1` vs ours `dc=3'd0`/`dc=3'd1`, and they are **g3's head after
this pass** because `VpiDecompile` is compared before `vpiConstType`. **The fix
is already written**: `enumMemberSubstConst` does it at `ExprEmit.cpp` ~3129
(`if (val.rfind("INT:",0)==0 && dec.find('\'')!=npos) dec = val.substr(4);`) —
one line, at the site this pass touched. **Deliberately not shipped: it is a
different compared field (`VpiDecompile`), outside the assigned territory of
`vpiConstType`, and its corpus reach was not censused.** A future pass can lift
it from here without re-measuring the law.

**R4 — pre-existing shape divergences at three folded-enum contexts.** Not
`vpiConstType`, all abstained: the localparam initializer emits one **extra**
constant and golden's def copy spans `59:23-59:27` where ours spans `59:23-59:29`
(`g1_ctx` o10); a packed range bound `logic [p1::E3:0]` gives us a `UINT:7`
constant golden lacks (`g1_ctx` o11); a fold **inside a package**
(`localparam logic PKGHIT = (S1 == S0)`) gives us an extra object and `1'b0`-vs-`0`
decompiles (`g5_scope` s0).

**R5 — the VALUE of a folded package PARAMETER whose type is an enum.** Golden
`INT:1`, ours `UINT:1` (`g2_origin` c7 and the package parameter object at
`13:33`); and for a **sized** package parameter golden `INT:3` + decompile `3` vs
ours `DEC:3` + decompile `3'd3` (c6). Because this pass's rule derives the const
type *from* the value, fixing the value here fixes the const type for free — so
R5 is the highest-leverage way to extend §0's law to a new origin. 3 cells.

**R6 — `Scoreboard` per-run output instability** (INSTRUMENT defect, not an
emitter bug). Unchanged by this pass and re-confirmed here at multiset distance
0. Carried forward verbatim from r10earl29 §8 R7; worth fixing at the source (a
stable sort key) so the byte verifier is exact everywhere.

---

## 7. THE MEASUREMENT DEFECT THIS PASS CAUGHT IN ITS OWN INSTRUMENT

**My first field reader faked an over-fire and I nearly reported it.** On
`g1_ctx` it said golden `(INT:,7)` = 12 and ours-after = **13**, i.e. one
constant more than golden. The cell it pointed at was the localparam initializer
at `59:23`.

The bug: the reader collected `|field:` lines at own-child depth and treated the
object introduced by `|vpiParent:` / `|vpiTypespec:` as **one** line to skip. An
introduced object **has its own children**, and `uhdm-dump` prints
`|vpiConstType` *after* the nested `ref_typespec` subtree:

```
\_constant: , line:59:23, endln:59:27
  |vpiDecompile:1
  |vpiSize:3
  |INT:1
  |vpiTypespec:
  \_ref_typespec: (work@g1_ctx)
    |vpiParent:                          <- reader stopped HERE
    \_constant: , line:59:23, endln:59:27
    |vpiFullName:work@g1_ctx
    |vpiActual:
    \_int_typespec: , line:59:14, endln:59:17
  |vpiConstType:7                        <- and never read THIS
```

So **every constant that carries a typespec was read as having no
`vpiConstType`** — which is exactly the localparam/param_assign shape. Golden's
14 became 12, ours-after's 14 became 13, and the difference looked like an
over-fire.

Fixed in `dumpread.py`: an introduced object's **whole subtree** is skipped and
scanning resumes at the constant's own child depth. The fix has a control that
**RUNS**, on the exact shape that broke it:

```
$ python3 ctcensus.py --selfcheck
SELFCHECK reader: vpiConstType='7' vpiSize='3' vpiDecompile='1' value='INT':'1'  leaked-child-fields=[]
SELFCHECK: PASS (a vpiConstType AFTER a nested ref_typespec must be READ, and
                 the ref_typespec's own fields must NOT leak in)
```

Every number in §3 and §4 was **re-measured** with the fixed reader. The
corrected g1 reading is golden 14 / ours-after **14** — an exact landing, not an
over-fire.

**A SECOND measurement error, also caught and corrected:** my first Earlgrey
census ran on a **partially-written dump** (3,810,820 of 4,654,873 lines — the
`;`-separated readiness check let it through). It reported ours `(INT:,7)` = 1821
where the truth is 19,670. `(INT:,9)` = 12 happened to be right, but the pass
does not rest on luck: §4's table is the re-run on the complete dumps, and both
dumps are now line-for-line equal in length (4,654,873).

---

## 8. THE FIVE GATES, each with the number I measured

Binary under test `0321a165b730e917c15a55fb12039e3c`, built at
`/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl30/build`.

### GATE 1 — BUILD

`grep -c "Linking CXX executable slang-uhdm"` = **1** (a build that compiles
nothing still exits 0, so the link line is the check); `grep -icE "error:"` =
**0**. The md5 assertion ran as a **SEPARATE command**, with the baseline
validated as 32 hex characters first (a malformed baseline is exit 9):

```
baseline OK 32 hex: 7922a457a58565ff014f9c440b585eb6
FINAL=0321a165b730e917c15a55fb12039e3c
MD5 CHANGED: PASS
```

The baseline is not asserted, it is **reproduced**: my worktree build, my
pristine-control build and the main tree's 81b8e0c binary are all
`7922a457a58565ff014f9c440b585eb6` — three independent bit-for-bit builds.

### GATE 2 — GOLDENS

`check_goldens.sh` **defaults `SLANG_UHDM` to the MAIN TREE**, so it was pinned:

```
SLANG_UHDM=<my build>  ./tests/check_goldens.sh   rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false  ./tests/check_goldens.sh   rc=1  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir`

```
testflags  679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump       496 match  183 differ  52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv -> 0 differing ROWS (0 diff row-sides)
baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both --jobs 2`

```
default    467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
dump       default   225 match / 242 differ / 327 blank
           testflags 165 match / 298 differ / 331 blank
ct8rows.sh results/golden_surelog.csv -> 0 differing ROWS (0 diff row-sides)
baseline 1589 lines = 1588 ROWS ; fresh 1589 lines = 1588 ROWS
PASS: every row byte-identical to the committed baseline
```

`Earlgrey_0_1/default` does **NOT** convert — default stays **467/13**, not
468/12. The row is quoted at the top of this file. `results/*.csv` untouched.

My **pristine** sweeps reproduce both committed baselines at **0 differing rows**
each, which is what makes GATE 5's byte comparison meaningful.

### GATE 5 — BYTE VERIFIER, both corpora, vs my own pristine 81b8e0c

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
             SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 2 / 953
             SELFCHECK 952/953 flagged        SELFCHECK1 = 3  (= 2 real + 1 injected)
```

Both movers attributed per shape against golden by **multiset** in §5:
`Earlgrey_0_1/default` = 12 objects, all landing exactly on golden;
`Scoreboard/default` = **multiset distance 0**, a pure permutation with no
`(INT:,9)` object in it at all, proved not attributable to this pass (§5.1).

### CANARIES

| check | corpus | result |
|---|---|---|
| `r10oth7repro/ctcan2.sh`, `EXPECT_UNKNOWN=6` | uhdm2rtlil | ok=1 **changed=0 absent=0** unknown-patterns=6 → PASS |
| `r10oth7repro/ctcan2.sh`, `EXPECT_UNKNOWN=1` | surelog | ok=58 **changed=0 absent=0** unknown-patterns=1 → PASS |
| **`tools/probe/r10uvm52repro/canaries.sh`** (named explicitly — several files share that basename) | uhdm2rtlil | ok=8 **changed=0 absent=0** unknown-names=25 (expected for a u2r csv) |
| **`tools/probe/r10uvm52repro/canaries.sh`** | surelog | ok=52 **changed=0 absent=0** unknown-names=7 (the u2r-only canaries) |
| `r10uvm55repro/canaudit.sh <canaries.sh> <ctcan2.sh>` | static | audited=29 **UNCOVERED=0 FENCE-BREACH=0** → PASS |

BY NAME on the surelog csv:

```
InterfaceModPort    default   CMP_EQUAL/differ      InterfaceModPort   testflags CMP_EQUAL/differ
BlackParrotComplex  default   CMP_EQUAL/differ      BlackParrotComplex testflags CMP_EQUAL/differ
SVSwitch            default   CMP_NOTEQUAL/         Earlgrey_0_1       default   CMP_NOTEQUAL/
```

`UnsignedParam`, `HierPathEval`, `FileLocalParam` and `TopParam` were **not
dispatched by any driver** (asserted by `canaudit.sh`, FENCE-BREACH=0).

### BOUNDARIES

No collision. `r10svs4` owns SVSwitch hier_path index-presence/element-kind and
`r10uvm59` owns type-parameter-scoped static-call REF_OBJS — this pass touched
neither `hier_path` nor `ref_obj`, and `SVSwitch` is byte-unchanged (it is not in
the mover list). The two edited sites are constant-minting only.

---

## 9. THE DRIVERS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `arm30.sh` | one arm's golden + ours + dumps + cmp; **prints the binary's md5**, existence-checks all four tools, `sed 1d` on both dumps, missing database = fatal, each arm in its own scratch dir |
| `dumpread.py` | **the own-child field reader**, with the subtree-skip defect of §7 documented in its header |
| `ctcensus.py` | **THE vpiConstType TABLE**: every constant cross-tabbed by (value-encoding prefix, `vpiConstType`); `--pairs` for the span-keyed join, `--span-of` to list a cell, `--selfcheck` for the reader control |
| `cells30.py` | per-span cell table with multiplicity kept, golden always argv[1] |
| `mv30.sh` | per-shape mover attribution against golden, ADDED/REMOVED separately, `SELFCHECK=1` fabricated-shape control, and a header that forbids attributing a bare field line |
| `g1_ctx.sv` | axis (b) CONTEXT — 11 contexts, zero and nonzero member |
| `g2_origin.sv` | axis (a) ORIGIN — 16 origins in one fixed context; also the over-fire census |
| `g3_base.sv` | axis (d) ENUM BASE TYPE — 9 flavours incl. the `UINT:` control |
| `g4_ctrl.sv` | **THE OVER-FIRE CONTROL** — 10 folded constants that already match golden at 9; must not move, and did not (zero lines changed) |
| `g5_scope.sv` | scope kind, qualification form, wildcard import, def/elab |
| `g6_iface.sv` | **the SECOND call site**, measured rather than assumed |

Reused unchanged: `r10uvm55repro/{msdist.sh,canaudit.sh}` (msdist pinned at
`7c7eaa6`, md5 `7c0d46b5da124cfe37d27eddc95eb7e7`), `r10oth6repro/byteverify.sh`,
`r10oth7repro/ctcan2.sh`, `r10oth8repro/ct8rows.sh`,
`r10uvm52repro/canaries.sh`. `scripts/verify_golden.py` and
`tests/check_goldens.sh` were **not** modified.
