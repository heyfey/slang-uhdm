# r10v225 — adversarial verification of r10uvm225

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's report
reproduces bit-for-bit from binaries this verifier built itself, including the
two md5s, the `MOVERS 0/1358` on uhdm2rtlil, the two MiniAmiq databases down to
their hashes, and the head-field move `Array_nets` → `Process`. Twelve
adversarial arms (ten standing, two isolation) found **two judge-visible AWAY moves on legal SystemVerilog**
— an associative index written as a **class SPECIALIZATION** `C#(...)`, and an
instantiated interface's **`wire <vector typedef> x [dim]`** — and both are
fixed here, at **zero corpus cost** (byteverify fixed-vs-pristine `0/1358` on
uhdm2rtlil, and on the Surelog corpus only the two predicted MiniAmiq rows).
Ship `/tmp/r10uvm225.verified.patch`.

Base commit `b4e6f61d`. Worktrees `/tmp/wt_v225` (patch + fix) and
`/tmp/wt_v225pris` (pristine), both fresh at `b4e6f61d`.

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Both binaries built `-j 2` in this verifier's own worktrees, md5 taken
separately, then FROZEN (`chmod 555`) at immutable paths before any sweep;
every `cmds.txt` audited by BINARY PATH.

```
pristine  3ad9d8ded7c3ee0e406d779170eb73a8   (= the implementer's)
patched   89b3b263e0ffe2bae5edc9631ea3c999   (= the implementer's)
fixed     52ad6bb9c32d5f34198b6c24a3de339d   (this verifier's)
```

| claim | reproduced |
|---|---|
| goldens 23/0, `/bin/false` 0/23 | YES, on all three binaries |
| uhdm2rtlil 679/50/2 both modes | YES, all three binaries |
| u2r `ct8rows` vs committed baseline + both own pristine controls | YES, **0 differing rows** of 731 |
| u2r byteverify | YES, **MOVERS 0/1358**, SELFCHECK 1357/1358 |
| surelog 476/5 + 470/5 over 1588 row-modes | YES |
| surelog whole-row `ct8rows` vs baseline and own control | YES, **PASS outright** |
| surelog byteverify | **2 predicted MiniAmiq rows + the Scoreboard/default COIN** (§3) |
| MiniAmiq database hashes `26745aecc25e` / `abca5ecc1c14` | YES, identical to the implementer's |
| MiniAmiq dump delta 190 lines, ADD-ONLY | YES, **adds=190 removes=0**, both modes |
| MiniAmiq head 713053 / 1, cmp log md5 `ed1744b60687` | YES, and IDENTICAL on both binaries and both modes |
| head field: pristine `Array_nets` (golden 5, ours null) → patched `Process` (golden 1, ours null) | YES, exactly, via the implementer's own `ct225field` |
| grid three-way TO-GOLDEN 114 / AWAY 0 / STILL-WRONG 15 / SAME-RIGHT 11 | YES, arm for arm |
| rowheads: nine converted row-modes + Rggen/default at judge rc 0 | YES |
| canaries 52/8 changed=0, ctcan2 ×2 PASS | YES |
| five protected DBs byte-identical; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a`; InterfaceModPort `59a365f3ce2c` | YES |
| boundary LISTED = PROCESSED, RC_DIFFS 0, 170 moved arms, 9 error-recovery | YES, the same 170 and the same 9 (§5) |
| boundary re-score TO-GOLDEN 538 / AWAY 0 / STILL-WRONG 66 / SAME-RIGHT 246 | YES, exactly (§5) |
| the a-priori u2r prediction LISTED 1462, HIT_ROWS 0 | YES, re-made with the FIXED binary |

Two of the implementer's own residues were **refuted or corrected** by
measurement, not argument: **R2** understates the elaborated view's law by a
long way (§6, R-V5), and **R-B's table** is wrong for three of the five
vector-typedef spellings (§6, R-V3).

---

## 2. THE TWO DEFECTS, AND THE FIXES

### 2.1 The blind spots that hid them

`armdelta225.sh`, the pass's own three-way scorer, reads the **`Array_nets()`
census only**, and it compares each cell's **whole field string**. Two things
are therefore invisible to it:

* the holder's own **`Nets()`** entries — which is exactly what R-A rewrites,
  because `assocIdxIsBuiltin225` feeds `assocBuiltinIndexDim224` →
  `defNetOmitsTypespec224` → the BASE net's def-view typespec;
* a **single judge-visible FIELD** going from right to wrong inside a cell that
  is wrong on both binaries — `nets::Compare` reads `VpiNetType` and the
  typespec independently (`UHDM/build/generated/src/nets.cpp:277`).

This verifier adds `basedelta225.sh` (the base-net three-way) and
`fielddelta225.sh` (the per-field three-way), and the boundary re-scorer
`bscore2v225.sh` / `tri3v225.py` scores all three axes. Both are POSITIVE
CONTROLS: run against the patched binary they convict it, run against the fixed
one they clear it.

### 2.2 Defect 1 — R-A over-strips a CLASS SPECIALIZATION index

r10uvm225 restated r10uvm224's associative reprieve positively:
`assocIdxIsBuiltin225` keeps the base net's typespec only for a written
BUILT-IN keyword or `[*]`, and drops it for every `ClassType`. Golden does not.

Measured on real Surelog goldens, `vgrid225/v11_clsspec` — one interface, nine
declarations, `surelog_rc=0` and `slang_rc=0` on all three binaries:

```
                                   golden    pristine   patched   fixed
[Cd225]              plain class    DROP       keep✗      DROP✓    DROP✓
[Cp225]              generic, all
                     defaults       DROP       keep✗      DROP✓    DROP✓
[<typedef of Cp225#(3)>]            DROP       DROP✓      DROP✓    DROP✓
[Cp225#(2)]  [Cp225#(4)]
[Cp225#()]   [Ce225#(2)]
[p225p::Cq225#(5)]                  KEEP       KEEP✓      DROP✗    KEEP✓
```

so the patched build lost a typespec the pristine build had right on **five
cells here and a sixth in `v8_scopedidx`** (`tvs_t s_hnd [Cs225#(2)];`) — six
AWAY moves on a judge-visible field.

`Cp225` and `Cp225#()` resolve to the **same** specialization type and golden
answers them differently, so the discriminator is **syntactic**: Surelog's
`compileRanges` compiles a plain (possibly scoped) NAME as an EXPRESSION — the
size model, and the base net loses its typespec — and compiles a built-in
keyword, `[*]` or a `C#(...)` specialization as a TYPE — the associative
MARKER with an index typespec, and the base net keeps its typespec. It is ONE
predicate for both halves, and the array_net's own range code was making the
same mistake (`[p225p::Cq225#(5)]` took the size model where golden gives the
marker with `class_typespec(p225p::Cq225)`).

**THE FIX** (`src/ModuleEmit.cpp`): `assocIdxSel225` +
`assocIdxWrittenPlainName225` — a plain name is an `IdentifierName`, or a
`ScopedName` whose rightmost segment is one; a trailing `#(...)` is a
`ClassName` and is not. `assocBuiltinIndexDim224` walks the declarator's
written dimensions in step with the type chain and reprieves a level whose
bracket is not a plain name; `makeIfaceDefArrayNet225`'s `namedIdx` reads the
same predicate.

### 2.3 Defect 2 — the `!innerNt225` guard drops R-B's 36 for a real NET

R-B stamps the inner element net `36` when the interface is instantiated and
the element type is a vector typedef, but only `if (!innerNt225)` — only when
our base net is bare. A real NET is never bare: `netTypeFor` answers
`1/2/3/4` for `wire/wand/wor/tri`. Measured on golden,
`vgrid225/v12_netvectd` — one file, two interfaces, twelve declarations,
`rc=0` everywhere:

```
declaration              UNINST  golden   INST  golden | pristine  patched  fixed
wire  <logic typedef>            1              36        36✓        1✗     36✓
wand  <logic typedef>            2              36        36✓        2✗     36✓
wor   <logic typedef>            3              36        36✓        3✗     36✓
tri   <logic typedef>            4              36        36✓        4✗     36✓
wire  <reg typedef>              1              48        36✗        1✗     36✗ (R-V3)
wire  logic [3:0]                1               1         36✗        1✓     1✓
```

The patched build moved **four instantiated cells the pristine build had
right** (its blanket 36) to the net keyword; the same cell appears again as
`if225v_net.w_td` in `v10_implicit`. The UNINSTANTIATED column is where the
patch is a big win — pristine reads 36 for all six and golden reads the net
keyword — so the guard has to go, not the rule.

**THE FIX** (`src/ModuleEmit.cpp`): drop the `!innerNt225` precondition. The
uninstantiated column is untouched (the bump is gated on
`ifaceInstantiated225`), every struct form is untouched
(`vectorTypedefElem225` is false for a struct typedef, so the explicit
package-qualified `vpiWire` cell keeps its 1), and the `reg`→48 /
`bit`→none / chained-alias→none keyword split stays exactly where the pristine
build left it (R-V3, §6).

### 2.4 The fix's blast radius, measured

```
                       IMPL grid (13 arms)  VERIFIER grid (10)  v11   v12
ANET   pris → fixed     114 / AWAY 0          71 / AWAY 0        8/0   2/0
NET    pris → fixed       4 / AWAY 0           0 / AWAY 0        2/0   0/0
FIELD  pris → fixed      82 / AWAY 0          94 / AWAY 0        2/0   9/0
FIELD  patched → fixed    0 / AWAY 0           4 / AWAY 0       19/0   4/0
```

The `patched → fixed` row is the point: **the fix changes nothing at all on the
implementer's own thirteen arms** and moves 27 fields toward golden elsewhere,
with no field moving away anywhere.

---

## 3. THE THIRD BYTE MOVER, AND WHY IT IS NOT ONE

The implementer reports `MOVERS 2/956` on the Surelog corpus. This verifier's
run reads **3/956** — the same two MiniAmiq rows plus
`default/Scoreboard-59431470`. That third row is **THE COIN** (RESUME §9), and
it is attributed the way the law requires, order-blind:

```
row                       raw diff lines   ORDER-BLIND
default/Scoreboard          94                2   <-- both are the dump's own
                                                   workdir header line
default/MiniAmiq           192              192
testflags/MiniAmiq         192              192
```

The two Scoreboard lines are `slP/… : Restored design Pre-Elab:` vs
`slQ/… : Restored design Pre-Elab:` — the dump header carrying the sweep's
workdir. Order-blind, the Scoreboard databases are **identical**; the same row
flips the other way between two other binaries in this session's own runs. The
MiniAmiq delta is **190 added lines and 0 removed**, both modes, and every one
of them is an `array_net` subtree.

---

## 4. THE ADVERSARIAL GRID (`vgrid225/`, 10 arms + 2 isolation arms)

Every arm compiled with the canonical golden-side Surelog — the one
`scripts/verify_golden.py` names, `~/git-repos/Surelog/build/bin/surelog` —
and with each pinned binary; **every rc recorded on both sides, all zero,
LISTED 10 PROCESSED 10**.

**THE HOLDER FENCE, adversarially** (`v5_holders`, `v6_genscope`). Golden's
array_net list is EXACTLY the interface body's, and ours is byte-for-byte the
same list:

```
package p225v            golden 0   ours 0
module (empty parens)    golden 0   ours 0
module (no parens)       golden 0   ours 0
program                  golden 0   ours 0
interface generate block golden 0   ours 0     <-- NOT in grid225
interface for-genvar     golden 0   ours 0     <-- NOT in grid225
modport interface        golden 3   ours 3, no modport object moved
interface body           golden 4   ours 4, MISSING 0 EXTRA 0 DIFF 0
```

**THE MIXED CHAINS** (`v2_mixed`, 16 declarations): `[1:0][2]`, `[1:0][]`,
`[][1:0]`, `[1:0][$]`, `[$][1:0]`, `[1:0][string]`, `[string][1:0]`, `[][]`,
`[string][int]`, `[string][<name>]`, `[<name>][string]`, `[$][string]`,
`[string][$]`, `[1:0][2][3]`, `[string][][$][1:0]`, `[*]` — **16/16 exact**,
the whole arm TO-GOLDEN, base nets 16/16 SAME-RIGHT.

**THE REMAINING BUILT-IN INDEX KEYWORDS** (`v3_idxforms`): `[longint]`,
`[time]`, `[int unsigned]`, `[byte unsigned]`, `[reg]`,
`[longint unsigned]`, `[logic[1:0]]`, `[*]`, `[string]` — **9/9 exact**, base
nets 9/9 SAME-RIGHT. R-A's positive whitelist is right on all of them.

**THE QUEUE MAX-BOUND SPLIT, REFUTED AS A DEFECT** (`v1_qbound`).
`makeIfaceDefArrayNet225` splits on `q.maxBound && boundSyn`, so a bound
evaluating to ZERO would silently take the unbounded `[$]` shape. MEASURED:
slang **rejects** `[$:0]` and `[$:<zero param>]` ("value must be positive"), so
`maxBound == 0` is equivalent to unbounded and the branch cannot be reached
with a written bound. `[$]`, `[$:1]`, `[$:3]` and `[$:255]` are exact.

**THE HIDDEN-DIMENSION FENCE, widened** (`v9_multi`). A typedef whose target
is a DYNAMIC, QUEUE or ASSOCIATIVE array is an `unsupported construct` on both
binaries ("typedef target: DynamicArrayType" …) — the same fence family as the
pass's R6 — so only the FIXED hidden form is reachable. Two levels of hidden
fixed dimension, with and without a written one on top, and a written
dynamic/associative level over a hidden fixed one: **all exact**.

**NETS CANNOT CARRY THE NEW KINDS.** `wire x [$]`, `wire x [string]` and
`wire x []` are illegal SV ("only 4-state integral types and unpacked
structs/unions and arrays of such types are allowed"), so the dynamic/queue/
associative half of this law applies to interface VARIABLES only. Recorded
because it bounds the law's reach.

---

## 5. THE WIDE BOUNDARY

Run over a COPY of the whole probe tree — subdirectories included — with the
PRISTINE and the FIXED binary, both views, every rc recorded, and re-scored
against a FRESH Surelog per moved arm on all THREE axes (array_nets, the
holder's own nets, and per-field):

```
-- LISTED=5629 PROCESSED=5629 MOVED_ARMS=190 RC_DIFFS=0
```

`5629 = 5619 + this verifier's 10 new sources`, and `190 = 170 + 10 x 2 views`:
**excluding this verifier's own arms the moved set is exactly the
implementer's 170.** No `RCDIFF`, no `ONESIDE`.

Re-scored against a FRESH Surelog per moved source — 86 sources scored, 9 whose
own Surelog compile fails (error recovery, not golden; the implementer's same
9):

```
                       IMPLEMENTER TREE (76 sources)      THIS VERIFIER'S 10
ANET   TO-GOLDEN=538  AWAY=0  SW=66   SR=246      142 / 0 / 52 / 16
NET    TO-GOLDEN=10   AWAY=0  SW=254  SR=1544       0 / 0 / 72 / 172
FIELD  TO-GOLDEN=372  AWAY=0  SW=158  SR=10332    188 / 0 / 86 / 1926
FIELD-AWAY lines printed anywhere in the tree: 0
```

The ANET row is the implementer's own `538 / 0 / 66 / 246`, reproduced exactly.
The NET and FIELD rows are new here, and they are the rows that matter: the
base-net axis and the per-field axis are where both defects lived, and with the
fix in place they read **AWAY 0** over the whole probe tree.

No must-stay family moved on any axis but this law's:
`§ ifaceDefNetTypespecIsTheModuleRule224` + the v224 verifier arms,
`§ wildcardImportCopiesPkgVarsToDefNets223` + v223,
`§ ifaceOwnCallCalleeFormRoutes222`, `§ uninstIfaceEnumConstNoActual221`,
`§ uninstIfaceForeachHdrUnresolved220`, `§ uninstIfaceBodyBindsInMethodWindow218`
and `§ dpiExportListedAtExportItem216` are all inside that accounting, and every
arm that moved moved TOWARD golden.

**THE A-PRIORI PREDICTION, re-made with the FIXED binary.** `predict225.sh`
replays each row's own recorded command line under `R10E225_DBG=1` into scratch
of its own:

```
uhdm2rtlil  LISTED=1462  PROCESSED=1462  HIT_ROWS=0
            (4 NOCMD rows = the two SURELOG_FAIL tests x 2 modes)
```

```
surelog     LISTED=1573  PROCESSED=1573  HIT_ROWS=2
            default/MiniAmiq 5 lines, testflags/MiniAmiq 5 lines,
            every one a `MINT ... pris=0`
```

so the `MOVERS 0/1358` on uhdm2rtlil is a POSITIVE statement — the law is
traced as touching no cell in that corpus at all — and not merely an absence of
measurement, and the predicted Surelog mover set is exactly the measured one.
**`REMOVE` and `RA-FLIP` are ZERO in BOTH corpora**, which is the independent
proof that this verifier's R-A′ change flips no corpus cell: the fix is a
grid-only correction with a measured blast radius of nothing.

---

## 6. RANKED RESIDUES

* **R-V1 (the successor's head, unchanged) — the interface definition's
  `Process()`, golden 1, ours 0.** Independently confirmed here with the
  implementer's own `ct225field` on databases this verifier produced: pristine's
  first disagreeing field is `Array_nets` (golden 5, ours null) and the fixed
  build's is `Process` (golden 1, ours null), with `Nets`, `Parameters`,
  `Param_assigns` and `Typespecs` all agreeing in between. The cmp log is
  byte-identical either way, so the successor MUST run the field probe and not
  the line count.
* **R-V2 — THE ELABORATED INTERFACE VIEW LISTS AN ARRAY_NET FOR EVERY NET, not
  only for a packed-struct element.** The pass's R2 says golden's elab view
  lists one "only for a PACKED-STRUCT element". MEASURED otherwise on
  `v10_implicit`: golden's `work@top225v_net.u_n` lists **nine** — `w_plain`,
  `w_pk`, `w_lg`, `w_and`, `w_or`, `w_tri`, `w_td`, `w_par`, `w_rng` — with the
  REAL `vpiSize` (2, 4), the real net type (1/2/3/4) and a `logic_typespec`
  inner net, and `v7_ports` adds two more for ANSI PORT nets. We list none of
  them. This is the widest measured gap left in the family and the natural
  successor to R-V1: 11 golden cells missing on two of this verifier's arms
  alone.
* **R-V3 — R-B's VECTOR-TYPEDEF TABLE IS WRONG FOR THREE SPELLINGS.** The pass
  records "a VECTOR TYPEDEF reads 36 when the interface is INSTANTIATED".
  Measured across `v4_vectd` (variables) and `v12_netvectd` (nets), golden
  splits on the typedef's WRITTEN KEYWORD, and on whether the alias is direct:

  ```
  typedef logic [1:0] / typedef logic   ->  36
  typedef reg   [1:0]                   ->  48
  typedef bit   [1:0]                   ->  none
  typedef <another alias>  (chained)    ->  none
  ```

  We read 36 for all four, on the pristine build and on the fixed one alike —
  5 STILL-WRONG cells in `v4_vectd` and 1 in `v12_netvectd`. `aliasVectorKeyword`
  (`src/EmitHelpers.h:770`) already reads the written keyword through the alias
  chain, but it walks THROUGH a chained alias where golden stops at the first
  one, so it is a starting point and not the answer. Deliberately NOT taken
  here: it is a new law, it needs its own grid and its own a-priori census, and
  every one of its cells is wrong on the pristine build too.
* **R-V4 — THE ARRAY_NET'S INNER TYPESPEC DOES NOT FOLLOW THE BASE NET'S ON A
  PORT.** The producer's rule, quoted in the patch's own comment, is
  `if (dest_net->Typespec())`. The base net's guard is
  `if (!it.port && !implicitNet && !omitTs224)`; the inner net's is
  `if (!omitTs224)`. An ANSI port net with an unpacked dimension therefore gets
  a BARE base net and a TYPED inner net, where golden has both bare
  (`v7_ports`, `if225v_ansi.pin` / `.pout`, 2 cells). A stated-gate/code-gate
  split, one line to close (`if (!it.port && !implicitNet && !omitTs224)`), and
  it is wrong on the PRISTINE build too — so it is a residue, not a regression,
  and it belongs to whoever takes R-V2's elaborated law.
* **R-V5 — the associative index typespec's NAME is not package-qualified.**
  `[p225p::Cq225#(5)]` reads `class_typespec(p225p::Cq225)` in golden and
  `class_typespec(Cq225)` for us — the last remaining `v11_clsspec` cell after
  the fix. Naming is context-dependent; do not "fix" it uniformly.
* **R-V6 — the base net's `vpiNetType` on the interface road never sees the
  DEF-VIEW arm.** `emitInterfaceDef` calls `netTypeFor(*it.sym)` with the
  default `defView=false` (`src/ModuleEmit.cpp:29424`) while the module road
  calls `netTypeFor(*it.sym, true)` (`:1560`). That is why golden's
  `wire tvw_t w_td [1:0]` def-view base net reads 36 and ours reads 1
  (`v10_implicit`). The pass's R1 by another name, with the line that causes it.
* The pass's own **R3, R4, R5, R6, R7** all reproduce as described and are not
  restated here.

---

## 7. FILES

* `vgrid225/` — 10 adversarial arms (`v1_qbound` … `v10_implicit`); the two
  isolation arms `v11_clsspec` and `v12_netvectd` are quoted in §2 and rebuilt
  by `isoarms225.sh`.
* `basedelta225.sh` — the BASE-NET three-way (the axis `armdelta225.sh` is
  blind to).
* `fielddelta225.sh` — the PER-FIELD three-way (the axis a whole-cell compare
  is blind to).
* `bscore2v225.sh` + `tri3v225.py` — the boundary re-score, all three axes.
* `grid225.sh`, `anetcen225.py`, `basenet225.py`, `armdelta225.sh`,
  `gscore225.sh` — the implementer's instruments, copied verbatim and run here.
* `VERIFIED.r10v225.txt` — the full gate battery output of this verification.
* `BOUNDARY.r10v225.txt`, `BOUNDARY.score.r10v225.txt` — the wide boundary and
  its three-axis re-score.
* `PREDICT.uhdm2rtlil.r10v225.txt`, `PREDICT.surelog.r10v225.txt` — the
  a-priori mover prediction, re-made with the FIXED binary.
