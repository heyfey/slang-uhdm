# r11u53 — FOLDMAP ROAD A: `$bits` OF A TYPE PARAMETER STAYS A `sys_func_call`

`§ bitsTypeParamArgNeverFolds53`

The law, the golden grid it was decoded from, the census, and how to re-run
every measurement in this directory.

---

## 0. GATES

| gate | reading |
|---|---|
| 1. build both, md5 | pristine `7ad7754335b99b206c84ce70148edec3` — BYTE-IDENTICAL to the main tree's build at `e3a249bd`; patched `603fd453ae8e481417463eada04cabe1` |
| 2. goldens | `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `FAIL=23 PASS=0` |
| 3. uhdm2rtlil, both modes | 1 differing row in each mode, both the CLAIMED CONVERSION (§6.1); 783/21 → **784/20** in both |
| 4. Surelog suite, both modes | 474/9 + 469/8 UNCHANGED, every status-histogram line identical; the two "differing" rows are workdir text inside a `SURELOG_FAIL` message (§6.2) |
| 5. byteverify `SELFCHECK=1` vs this pass's own pristine workdirs | u2r **6 movers / 1608**, every one predicted BY NAME before the sweep (selfcheck 1607/1608); Surelog **4 movers / 960**, all four the documented UVM-family coin, attributed order-blind AND against a pristine-vs-pristine positive control (§6.2) |
| MOVED-WRONG / AWAY-GOLDEN | **0 / 0** — proved as SET containment on all six real movers (`NOT-PRESENT-BEFORE = 0`), not as a count |
| canaries | `canaries.sh` u2r `ok=8 changed=0`; `ctcan2.sh` `PASS`; `canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| `results/*.csv` | UNTOUCHED by this pass |

---

## 1. THE HEAD, RE-MEASURED AT THE BASE (`e3a249bd`)

`bits_of_type_param`, `uhdm2rtlil`, BOTH modes, pristine binary
(`md5 7ad7754335b99b206c84ce70148edec3`, byte-identical to the main tree's
build at `e3a249bd`). One head each; the two modes' heads are the same object:

```
LHS: sys_func_call: ($bits), line:17:39, endln:17:51        <- GOLDEN keeps
     |vpiArgument: ref_obj: (work@dut.req_t), line:17:45
RHS: constant: , line:17:39  |vpiDecompile:97 |vpiSize:64 |UINT:97   <- WE fold
```

The witness's own source carries the control in the same module
(`uhdm2rtlil/test/bits_of_type_param/dut.sv`):

```systemverilog
parameter  type req_t      = pk::req_t,
parameter  int  DATA_WIDTH = $bits(req_t),      // TYPE PARAMETER  -> golden KEEPS
localparam int  DIRECT     = $bits(pk::req_t)   // package typedef -> golden FOLDS
```

Golden keeps the first in both views and folds the second in both; ours folded
both. `DIRECT` already matched golden field for field, `ref_typespec ->
int_typespec` included — only the type-parameter cell differed.

**RESIDUE ARITHMETIC AT THE BASE, and the prediction it forces.** Order-blind
whole-dump diff against golden (`dumpdiff53.sh`), both modes:

```
default    golden=1398 ours=1461 orderblind_diff=155 gonly=20 oonly=83
testflags  golden= 888 ours= 951 orderblind_diff=153 gonly=20 oonly=83
```

The 20 golden-only lines are `4 sys_func_call ($bits)` + `2 vpiArgument` +
`2 ref_obj (work@dut.req_t)` + `2 vpiName:req_t` + `2 vpiName:$bits` +
`2 vpiFullName:work@dut.req_t` + `2 UINT:97` (the `$bits` cell, 16 lines) and
`1 type_parameter (req_t)` + `1 type_parameter (data_t)` + `1 package` +
`1 header` (4 lines, a different family). The 83 ours-only lines are dominated
by the four folded `constant`s and their
`vpiTypespec`/`ref_typespec`/`int_typespec`/`vpiSize:64`/`vpiDecompile:97`/
`vpiConstType` retinue. Measured after the fix the counts go **20 → 6** and
**83 → 61**, so the cell cleared 14 golden-only and 22 ours-only lines. What is
left behind it is the DIFFERENT family: a `type_parameter` multiset residue (golden 7
lines, ours 10 — we emit three extra `(work@dut.req_t)` lines, and golden has a
`(work@dut.data_t)` line we do not), plus three ours-only
`logic_typespec`/`range`/`operation` lines for `localparam type data_t =
logic [DATA_WIDTH-1:0]`, plus the `package`/`module_inst` head lines.

**PREDICTION MADE BEFORE THE SWEEP, LOUDLY: `bits_of_type_param` ADVANCES, it
does NOT CONVERT.** The head clears; ~39 of the 103 residue lines go; the
`type_parameter` / `data_t` family stays and becomes the new head.

**THAT PREDICTION WAS WRONG, AND THE ROW CONVERTS — SEE §6.1.** The residue
arithmetic was right (103 → 67 order-blind lines, both modes) but it is the
wrong instrument for the question: the `type_parameter` multiset lines and the
`data_t` `logic_typespec`/`range`/`operation` lines behind the head are
JUDGE-INVISIBLE. `uhdm-cmp` returns `rc=0` with `0` heads and `0` cmp lines
once the `$bits` cell is fixed, and the row's `dump` column reads `differ` —
which is exactly where a residue the judge cannot see shows up. The lesson is
recorded rather than smoothed over: an order-blind dump residue bounds the
work left, it does not predict the verdict; only `uhdm-cmp` does.

---

## 2. THE PRODUCER, CONFIRMED LINE BY LINE AGAINST THE PIN

Surelog v1.87, `0445655ee7` (`git log --oneline -1` in the pinned tree).
`FOLDMAP.md`'s ROAD A decode was re-read against the source, not carried
forward; it stands, with V6.5's citation correction confirmed.

| claim | file:line | confirmed |
|---|---|---|
| `compileBits` is the only thing that folds `$bits` | `src/DesignCompile/CompileExpression.cpp:4686` | yes |
| it does not obey the caller's `Reduce` — it UPGRADES itself on `m_elabMode && reduce==No && tps && isFullySpecified(tps)` | `:4750-4756` | yes, verbatim |
| the mint: `UINT:<bits>`, decompile the bare number, `vpiUIntConst`, `VpiSize(64)` | `:4779-4785` | yes |
| the final `else` that emits the `sys_func_call ($bits)` | `:4802` | yes (V6.5's correction to the map's `:4805`) |
| everything hangs on `getTypespec` | `:4534` | yes |
| for a bare name it fills `basename` … | `:4452` (`case slStringConst`) | yes |
| … then looks in EXACTLY TWO places: the component's DATA TYPE map, then its PORTS and SIGNALS | `:4541-4544` | yes |
| the DATA TYPE map is populated by TYPEDEFS only | `src/DesignCompile/CompileHelper.cpp:636` (`compileTypeDef`), `:160` (class definitions), `:168` (imports) | yes |

A `parameter type` / `localparam type` lives in the parameter table and is in
NEITHER map, so `tps` stays null, the self-upgrade cannot fire, `Bits()` is
never called, and the `sys_func_call` survives — in the definition compile AND
in the elaborated one. **The decision is on the argument's SYNTAX, never on the
resolved type.**

---

## 3. THE GOLDEN GRID

Seven arms in `grid/`, scored per VIEW at the SOURCE SITE of each `$bits`
(`cell53.sh`, sites derived from `dut.sv` by `sites53.sh` so a site missing on
BOTH sides is reported MISSING and can never read as agreement). Golden is the
pinned Surelog; `base` is the pristine binary, `pat` the patched one.

### 3.1 `w1_bits_argkind` — WHICH ARGUMENT KIND (one module-body localparam holder)

| `$bits` argument | golden DEF | golden ELAB | ours DEF (base→pat) | ours ELAB (base→pat) |
|---|---|---|---|---|
| `TP`, `parameter type TP = pk::req_t` | **KEEP** | **KEEP** | fold → **KEEP** | fold → **KEEP** |
| `TB`, `parameter type TB = logic [9:0]` | **KEEP** | **KEEP** | fold → **KEEP** | fold → **KEEP** |
| `TS`, `parameter type TS = pk::byte_t` | **KEEP** | **KEEP** | fold → **KEEP** | fold → **KEEP** |
| `TL`, `localparam type TL = pk::req_t` | **KEEP** | **KEEP** | fold → **KEEP** | fold → **KEEP** |
| `loc_t`, `typedef pk::req_t loc_t` | **KEEP** | fold | fold → fold | fold → fold |
| `pk::req_t` | fold | fold | fold → fold | fold → fold |
| `pk::byte_t` | fold | fold | fold → fold | fold → fold |
| `logic [9:0]` | fold | fold | fold → fold | fold → fold |

Row 2 is **the decisive cell** (V5's): the type parameter is bound to a BUILT-IN
keyword, so the RESOLVED type is fully specified and golden STILL keeps the
call. Any implementation that answers on the resolved type gets this cell
wrong. Rows 6-8 are the positive control — same construct, same holder, same
view, both sides fold, and they still fold after the patch.

Row 5 is the **W3 cell** and is deliberately NOT written; see §3.3.

### 3.2 `w2_bits_holder` — IS THE HOLDER A GATE?  No.

`$bits(TP)` of one type parameter in the three holders that reach a JUDGED
view — a parameter-port-list Rhs, a module-body localparam Rhs, and a
function-body `return`. Golden KEEPS in all three; base folded all three;
patched KEEPS all three. (V5's correction to the older `a2_bits_holder` is
honoured: a port range bound and a net range bound put the `sys_func_call`
only in `weaklyReferenced`, on BOTH sides, so they are not judged cells and
are left out of this arm rather than counted as agreements.)

### 3.3 `w3_typedef_view` — THE W3 CELL ON ITS OWN ARM (measured, NOT written)

A module-local typedef IS in the data-type map, so `getTypespec` resolves it
and only `m_elabMode` can separate its views. The arm asks what the alias's
TARGET does to that:

| module-local typedef | golden DEF | golden ELAB | ours (base = pat) |
|---|---|---|---|
| `typedef pk::req_t   l_struct_t` | **KEEP** | fold | fold / fold |
| `typedef pk::byte_t  l_scalar_t` | **KEEP** | fold | fold / fold |
| `typedef logic [9:0] l_builtin_t` | fold | fold | fold / fold |
| `typedef struct packed {…} l_inline_t` | fold | fold | fold / fold |
| `pk::req_t` (control) | fold | fold | fold / fold |

**FINDING, recorded not implemented:** the W3 keep is not a property of "a
module-local typedef" — it is a property of a module-local typedef whose
target is a PACKAGE-SCOPED name. A local alias of a built-in or of an inline
struct folds in the definition listing like anything else. That is a second,
view-dependent cell on road A with its own gate (`isFullySpecified` of a
package-qualified target during the definition compile), and it wants its own
pass. This arm is also this pass's **negative control**: it is the one arm
whose residue is UNCHANGED across the patch (§5).

### 3.4 `w4_bits_iface` — the interface twin

`$bits(TP)`, `$bits(TB)` and `$bits(TL)` in an INTERFACE body: golden KEEPS all
three, the `$bits(pk::req_t)` control folds. base folded all three; patched
KEEPS all three and still folds the control.

### 3.5 `w5_bits_override` — the type parameter is OVERRIDDEN at instantiation

The blast radius's own shape. `child #(.TP(pk::small_t))` beside a default
instance: golden keeps the call in the definition copy AND in BOTH elaborated
instance copies, the overridden one included. base folded all three copies;
patched keeps all three. This is the same proof as the V5 cell, taken from the
elaborated side: the binding changes, the decision does not.

### 3.6 `w6_bits_pkgscope` — the other `DesignComponent` kinds

| site | golden DEF | golden ELAB | ours base | ours pat |
|---|---|---|---|---|
| package `parameter int PW = $bits(PT)` (`PT` a package type parameter) | KEEP | **KEEP** | keep / **fold** | keep / **KEEP** |
| package `parameter int PD = $bits(pk::req_t)` (control) | KEEP | fold | keep / fold | keep / fold |

The package DEFINITION listing keeps everything (the already-landed
`§ pkgDefNeverFolds` law), so the package cell only bites in the ELABORATED
listing — and there the base was wrong and the patch fixes it.

The arm also carries a CLASS type parameter (`class cc #(type CT = pk::req_t)`
with `localparam int CW = $bits(CT)`). Golden emits its `$bits` in the
definition listing; **we emit no object at that site at all** (`MISSING` on our
side, both binaries). That is a pre-existing hole in class-body localparam
emission, unchanged by this pass, and it is recorded here rather than chased.

### 3.7 `w7_bits_inexpr` — the `$bits` is NOT the whole Rhs

Both landed-law witnesses in the blast radius write `(1 << $bits(<type
parameter>))`, so the gate has to be asked of a node INSIDE a surviving
expression. Cell counts per site (objects anchored at that line:col):

| site | golden DEF | golden ELAB | ours DEF base→pat | ours ELAB base→pat |
|---|---|---|---|---|
| `(1 << $bits(TP))` | 2 `sys_func_call` | 2 `sys_func_call` | 1 `constant` → **2 `sys_func_call`** | 0 → 0 |
| `$bits(TP) + 1` | 3 `operation` + 2 `sys_func_call` | 4 `operation` + 2 `sys_func_call` | 3 `operation` + 1 `constant` → **3 `operation` + 2 `sys_func_call`** | 2 `constant` → 2 `constant` |
| `(1 << $bits(pk::req_t))` control | 1 `constant` | — | 1 `constant` → 1 `constant` | — |
| `$bits(TQ)` whole Rhs | 2 `sys_func_call` | 2 `sys_func_call` | 2 `constant` → **2 `sys_func_call`** | 2 `constant` → **2 `sys_func_call`** |

So the DEFINITION view becomes golden for the in-expression shape too, and the
ELABORATED view of a `$bits` buried inside a surviving operation is UNCHANGED —
still folded, as it was at the base. **That is a residue of this pass, stated
as one: § bitsTypeParamArgNeverFolds53's elaborated half is written for the
whole-Rhs shape only** (`bitsOfTypeParamInit53`), because the elaborated
parameter path mints the folded constant without ever calling `emitExpr` and
re-routing an arbitrary surviving operation through it is a separate, wider
change. The arm still moves 54 residue lines toward golden and none away.

---

## 4. THE LAW AS WRITTEN

Two half-lines of production code and one shared predicate.

* `src/EmitHelpers.h` — `typeParamAliasType53(const Type*)`: slang mints a
  `TypeAliasType` for every type parameter and parents it to the declaring
  scope (`slang source/ast/symbols/ParameterSymbols.cpp:214-218`), and a
  reference to the parameter's NAME used as a type resolves to that alias. A
  plain `typedef` produces a `TypeAliasType` too, so the alias kind alone does
  not separate them — the predicate asks the DECLARING SCOPE which symbol owns
  the name and requires that symbol to be a `TypeParameterSymbol` whose own
  `getTypeAlias()` is this very type. It lives in the shared header because
  both emitters ask it and they must not drift apart.
  `bitsOfTypeParamInit53(const Expression&)` is the whole-Rhs form the
  parameter emitter needs.
* `src/ExprEmit.cpp` — `UhdmExporter::srlgBitsFoldArg`'s `DataType` branch
  refuses before consulting `srlgFullySpecType`. The order matters: the
  resolved type answers "fully specified" in exactly the cell (`w1` row 2) that
  proves the producer ignores it.
* `src/ParamEmit.cpp` — the elaborated parameter arm dispatches a whole-Rhs
  `$bits(<type parameter>)` back through `emitExpr` (the same explicit
  dispatch the `MinTypMax` initializer already uses, three lines above, and for
  the same reason: this path never reaches `emitExpr` for an initializer slang
  has a value for).

---

## 5. DIRECTION, PER ARM

`toward53.sh` — order-blind whole-dump residue against golden under both
binaries. DOWN is toward golden.

```
ARM                  base_g   base_o    pat_g    pat_o  DIRECTION
w1_bits_argkind         221      188      165      100  TOWARD-GOLDEN (-144)
w2_bits_holder           94       78       56       29  TOWARD-GOLDEN (-87)
w3_typedef_view          44       33       44       33  UNCHANGED
w4_bits_iface           116      124       87       71  TOWARD-GOLDEN (-82)
w5_bits_override         68       55       47       22  TOWARD-GOLDEN (-54)
w6_bits_pkgscope        168       45      163       36  TOWARD-GOLDEN (-14)
w7_bits_inexpr          138       91      112       63  TOWARD-GOLDEN (-54)
```

Six arms toward golden, one unchanged (the arm the law deliberately does not
touch), **zero away**. Every arm's `uhdm-cmp` head also advanced past its
`$bits` cells to a different, pre-existing law (`w1` to the W3 cell at 26:23,
`w2` to a `func_call (f)`, `w4`/`w5` to unrelated `operation`s); `w3`'s and
`w6`'s heads are byte-identical before and after.

---

## 6. CENSUS AND THE MOVER PREDICTION

`census.py`/`census2.py` walk every test directory of BOTH corpora
(`uhdm2rtlil/test`, `Surelog/tests`, `Surelog/third_party/tests`) for a
`parameter`/`localparam type` declaration and for a `$bits(...)` whose argument
mentions one of the names so declared. **49 directories declare a type
parameter; 8 of them call `$bits` on one** — that is road A's true blast
radius, counted the way V6.1 asked for it.

| corpus | dir | is it a ROW? | predicted |
|---|---|---|---|
| u2r | `bits_of_type_param` | yes, `CMP_NOTEQUAL` ×2 | **MOVER**, head clears, ADVANCE |
| u2r | `type_param_packed_dim` | yes, `CMP_NOTEQUAL` ×2 | **MOVER**, head clears (its head IS a road-A `$bits` at `4:37`) |
| u2r | `type_param_override_elem_sel` | yes, `CMP_NOTEQUAL` ×2 | **MOVER**, head is a different law (`logic_typespec` at `32:17`) and must stay `CMP_NOTEQUAL` |
| u2r | `cva6_equiv` | no (not a discovered row) | — |
| sl | `ClassScope` | row, `SLANG_REJECT` ×2 | no database, no mover |
| sl3p | `Ariane2024` | row, `SLANG_REJECT` / `NO_DATABASE` | no database, no mover |
| sl3p | `Verilator` | row, `SLANG_REJECT` ×2 | no database, no mover |
| sl3p | `ariane` (`Ariane`) | row, `SURELOG_FAIL` ×2 | no database, no mover |

The four Surelog-corpus entries were checked in the pristine workdir, not
assumed: none of their eight row directories contains a `slang.uhdm` at all
(`ClassScope`, `Ariane2024`, `Verilator` hold only `cmds.txt`; `Ariane` holds
`cmds.txt` and an `slpp_all`), so the Surelog side's zero movers is a zero with
a reason, not an unreached counter.

So the prediction BY NAME, before the patched sweeps: **exactly six databases
move** — `bits_of_type_param`, `type_param_packed_dim` and
`type_param_override_elem_sel`, in both modes — and **nothing else in either
corpus**.

`param_type_logic_width` is the census's near-miss control: it DOES declare
`parameter type dtype`, but its `$bits(a)` / `$bits(b)` name SIGNALS, so the law
cannot reach it. It is `CMP_EQUAL` in both modes and is predicted NOT to move.

### 6.1 WHAT THE PATCHED SWEEPS MEASURED

`byteverify.sh` over 1608 uhdm2rtlil databases (both modes), patched workdir vs
this pass's own pristine workdir, `SELFCHECK=1`:

```
PATH_SETS_IDENTICAL (1608 paths)
MOVER ./default/bits_of_type_param-…            MOVER ./testflags/bits_of_type_param-…
MOVER ./default/type_param_override_elem_sel-…  MOVER ./testflags/type_param_override_elem_sel-…
MOVER ./default/type_param_packed_dim-…         MOVER ./testflags/type_param_packed_dim-…
MOVERS: 6 / 1608
SELFCHECK (every file vs one fixed file): 1607 / 1608 flagged
```

**Six movers, and they are the six predicted by name. Nothing else moved in
either corpus.**

**THE CONVERSION — quoted, and NOT written into `results/*.csv` by this pass:**

```
< bits_of_type_param,default,CMP_NOTEQUAL,decompile:,,
> bits_of_type_param,default,CMP_EQUAL,,,differ
< bits_of_type_param,testflags,CMP_NOTEQUAL,decompile:,,
> bits_of_type_param,testflags,CMP_EQUAL,,,differ
```

uhdm2rtlil goes 783 / 21 → **784 / 20** in BOTH modes. `uhdm-cmp` on the row:
`rc=0`, `0` heads, `0` cmp lines, both modes.

**HEADS AND DIRECTION, per mover** (order-blind whole-dump residue against
golden, `golden-only / ours-only`, pristine → patched; identical in both modes
except for the dump sizes):

| row | head before | head after | residue |
|---|---|---|---|
| `bits_of_type_param` | `sys_func_call ($bits)` `17:39` | **none — judge-equal** | 20/83 → 6/61 |
| `type_param_packed_dim` | `sys_func_call ($bits)` `4:37` (a road-A head) | `packed_array_var (work@dut.rt_i)` `8:22` | 80/60 → 72/55 |
| `type_param_override_elem_sel` | `logic_typespec` `32:17` (a different law) | unchanged | 100/70 → 92/65 |

So road A cleared **two** heads, not one. Both surviving rows keep their
committed `CMP_NOTEQUAL` status in both modes, as the landed-law witnesses
must.

**MOVED-WRONG 0 / AWAY-GOLDEN 0, proved as a SET containment, not as a count.**
For each of the six movers the divergence-line texts under the patch are a
strict SUBSET of those under the pristine binary (ids stripped, whitespace
normalised): `NOT-PRESENT-BEFORE = 0` for all six.

```
default   bits_of_type_param            divergence texts 54 -> 41   new 0
default   type_param_override_elem_sel  divergence texts 77 -> 72   new 0
default   type_param_packed_dim         divergence texts 72 -> 67   new 0
testflags bits_of_type_param            divergence texts 54 -> 41   new 0
testflags type_param_override_elem_sel  divergence texts 77 -> 72   new 0
testflags type_param_packed_dim         divergence texts 72 -> 67   new 0
```

**THE SHAPE LISTER beside the census** (`shape53.sh`, default mode; `Kg`/`Ko` =
`sys_func_call ($bits)` objects per view, `TPg`/`TPo` = `type_parameter`
objects, which is what makes a zero readable):

```
ROW                            VIEW   Kg Ko TPg TPo     pristine  ->  patched
bits_of_type_param             DEF     2  0   4   5     ->  2  2       OK
bits_of_type_param             ELAB    4  0   6   8     ->  4  4       OK
type_param_packed_dim          DEF     2  0   6   6     ->  2  2       OK
type_param_packed_dim          ELAB    4  0   9  12     ->  4  2       KEEP-COUNT-DIFFERS
type_param_override_elem_sel   DEF     2  0   6   6     ->  2  2       OK
type_param_override_elem_sel   ELAB    4  0  10  12     ->  4  2       KEEP-COUNT-DIFFERS
param_type_logic_width         DEF     0  0   2   2     ->  0  0       OK
param_type_logic_width         ELAB    0  0   4   4     ->  0  0       OK
```

Read it as three statements. (1) Every KEEP count our side was missing in the
DEFINITION view is now exactly golden's. (2) The two surviving
`KEEP-COUNT-DIFFERS` cells are `2` where golden has `4`, in the ELABORATED view
only — that is precisely `w7`'s residue (a `$bits` buried inside a surviving
`(1 << …)` operation), named in §3.7 and left open on purpose. (3)
`param_type_logic_width` reads `K = 0` on BOTH sides while `TP` is present on
both — a genuine zero with the construct in reach, which is what stops the
census's zero from being an unreached counter.

**POSITIVE CONTROL for the census.** A census that counts fold sites reads zero
both when the construct is absent and when the counter never reached the
database. `shape53.sh` prints, per view and per side, the `sys_func_call
($bits)` inventory (the KEEP shape) beside the `type_parameter` inventory (is
the construct present at all) and reports `OUT-OF-REACH` rather than agreement
when both sides carry no `type_parameter`. The grid is the other half of the
control: `w1`/`w2`/`w4`/`w5`/`w6`/`w7` are deliberately-moved cells that MUST
change bytes under the patched binary, and `w3` is a deliberately-unmoved arm
that must NOT — measured in §5, and both readings came out as designed.

### 6.2 THE SURELOG CORPUS

**Row join.** `ct8rows.sh` against the committed `results/golden_surelog.csv`
AND against this pass's own pristine control: the per-mode STATUS histograms
are IDENTICAL on every line —

```
default    474 CMP_EQUAL   9 CMP_NOTEQUAL   5 DEFERRED  285 SLANG_REJECT  25 SURELOG_FAIL
testflags  469 CMP_EQUAL   8 CMP_NOTEQUAL   5 DEFERRED    3 NO_DATABASE    1 NO_UHDM
           286 SLANG_REJECT  23 SURELOG_FAIL   1 TIMEOUT   2 UNTRANSLATABLE
```

and so are both DUMP-column histograms. The only two "differing" rows are
`LowMemLib` and `LowMemPkg` in testflags, whose `SURELOG_FAIL` detail string
quotes the WORKDIR PATH inside a Surelog log message; the same two rows differ
between the committed baseline and the PRISTINE control for the same reason,
so this is workdir text, not a status change. 474/9 and 469/8 stand.

**byteverify `SELFCHECK=1`, patched vs this pass's pristine control:**

```
PATH_SETS_IDENTICAL (960 paths)
MOVER ./default/MiniAmiq-…     MOVER ./testflags/MiniAmiq-…
MOVER ./default/SeqDriver-…    MOVER ./testflags/SeqDriver-…
MOVERS: 4 / 960
SELFCHECK (every file vs one fixed file): 959 / 960 flagged
```

**Those four are the DOCUMENTED UVM-family nondeterminism, and they are
attributed, not waved through.** `MiniAmiq` and `SeqDriver` carry no
`parameter type` at all (they are not among the census's eight), so the law
cannot reach them. Two independent measurements say so:

1. **Order-blind attribution** (uhdm-dump, path- and id-normalised, sorted).
   Every one of the four is the SAME 4-line class and nothing else — a
   `UINT`/`vpiDecompile` pair whose value is a LINE NUMBER:
   `0 ↔ 597` (MiniAmiq/default), `0 ↔ 1420` (SeqDriver/default),
   `940 ↔ 0` (MiniAmiq/testflags), `0 ↔ 556` (SeqDriver/testflags).
   No structural line moves in either direction.
2. **POSITIVE CONTROL — the PRISTINE binary against ITSELF.** Two further
   sweeps of the same two tests with `/tmp/r11u53_pris.bin` and no code change
   whatever:

```
MiniAmiq   run1 7207abd0e3c0   run2 b8a9547a1f15   (sweep control 27419f6011b4, patched e22a70cacf12)
SeqDriver  run1 2fb39f8b4130   run2 0112568d700f   (sweep control 2fb39f8b4130, patched 21ad8027f4d8)
```

   Four distinct MiniAmiq hashes from one unchanged binary, and SeqDriver's
   run1 reproduces the sweep control exactly while run2 does not. The byte
   move is a per-invocation coin (macro-buffer `SourceLocation` ordering under
   slang's parallel parse), and this pass's binary lands inside the same set.
   Both rows are `CMP_EQUAL` in both modes in BOTH sweeps — status unchanged,
   as the UVM family requires.

   And the control closes on the SAME CLASS, not merely on "some difference":
   read order-blind, pristine run1 vs pristine run2 differs in exactly

```
PRISTINE-vs-PRISTINE MiniAmiq orderblind_diff_lines=4
  |UINT:892 <-> |UINT:905     |vpiDecompile:892 <-> |vpiDecompile:905
```

   — the identical 4-line `UINT`/`vpiDecompile` line-number pair the patched
   comparison showed, produced by a binary that did not change at all.

Note the tell in the raw hashes: `testflags/MiniAmiq patched = 27419f6011b4`
is bit-for-bit the hash the DEFAULT-mode PRISTINE run produced. A real code
change cannot make one mode's patched output equal another mode's pristine
output; a coin over a small hash set does it routinely.

**PROTECTED DATABASES, BY NAME** (md5, pristine → patched, both modes):

```
SVSwitch            4842211c4030 -> 4842211c4030   (HARD PIN, both modes)
YosysVerx           6ccda350c24a -> 6ccda350c24a   (HARD PIN, both modes)
InterfaceModPort    59a365f3ce2c -> 59a365f3ce2c
BlackParrotComplex  e3e354129d5a / 73a10e8217e5  SAME both modes
YosysOldOr          d68e0796d62c -> d68e0796d62c
Earlgrey_0_1        default 8bdf25272e08, testflags 59d0ee6d10c3  SAME, CMP_EQUAL both modes
```

**Canaries.** `canaries.sh` `ok=52 changed=0 absent=0`; `ctcan2.sh`
`ok=58 changed=0 absent=0`, `PASS`.

**Predicted movers on this corpus: ZERO, and that zero has a reason** — the
four Surelog-corpus directories that carry the construct produce no
`slang.uhdm` at all (§6). The four observed movers are the documented coin.

---

## 7. RESIDUES THIS PASS LEAVES OPEN, NAMED

* **R1 — the W3 cell.** A module-local typedef whose target is a PACKAGE-SCOPED
  name: golden KEEPS its `$bits` in the definition listing and FOLDS it in the
  elaborated one; we fold in both. The gate is `isFullySpecified` of a
  package-qualified target during the definition compile, not the typedef-ness
  of the alias — `w3_typedef_view` shows a local alias of a built-in or of an
  inline struct folding on both sides. Measured, not written.
* **R2 — the elaborated half is whole-Rhs only.** `$bits(<type parameter>)`
  buried inside a surviving operation (`(1 << $bits(TP))`) keeps the call in
  the DEFINITION view but is still folded in the ELABORATED one, because the
  elaborated parameter path mints the constant without calling `emitExpr` and
  `bitsOfTypeParamInit53` only recognises the whole-Rhs shape. This is the two
  `KEEP-COUNT-DIFFERS` ELAB cells in §6.1's shape table and `w7_bits_inexpr`'s
  open row. It is the next thing on this road.
* **R3 — a class-body localparam initialised by `$bits(<class type
  parameter>)` produces NO object on our side** at that site, in either
  binary (`w6_bits_pkgscope`, `MISSING` both views). Pre-existing, unrelated to
  this law, recorded so the next reader of `w6` is not surprised.
* **R0 — `bits_of_type_param` is CONVERTED; `type_param_packed_dim`'s head is
  now `packed_array_var (work@dut.rt_i)` at `8:22` and
  `type_param_override_elem_sel`'s is still `logic_typespec` at `32:17`.**
  Road A's remaining work is R2; roads B/C/D/E of `FOLDMAP.md` are untouched.

---

## 8. HOW TO RE-RUN EVERYTHING

```bash
R=tools/probe/r11u53repro
bash $R/run53.sh <pristine binary> base          # golden + ours, per arm, rc recorded on BOTH sides
bash $R/run53.sh <patched  binary> pat
for a in $(ls $R/grid); do bash $R/cell53.sh $a pat $(bash $R/sites53.sh $a | cut -f1); done
bash $R/toward53.sh                              # direction, per arm
bash $R/dumpdiff53.sh <rowdir> /tmp/out          # residue arithmetic for a corpus row
bash $R/shape53.sh <rowdir> [...]                # the census's shape inventory
python3 $R/census.py                             # the blast radius, both corpora
```

```bash
bash $R/subset53.sh <pristine rowdir> <patched rowdir>   # AWAY-GOLDEN as a set proof
```

`run53.sh` records `golden_rc` and `ours_rc` for every arm; all seven arms
compile `0/0` on both binaries, so no cell in this directory is an
error-recovery reading. The grid's run artifacts (two Surelog trees, two
databases and four dumps per arm) are regenerated by `run53.sh` and are not
committed; `evidence/` carries the distilled readings:

| file | what it holds |
|---|---|
| `evidence/RC.txt` | every arm's `golden_rc`/`ours_rc` on both binaries |
| `evidence/CELLS.base.txt`, `evidence/CELLS.pat.txt` | the site-keyed, view-sectioned cell inventory |
| `evidence/HEADS.txt` | each arm's `uhdm-cmp` head before and after |
| `evidence/TOWARD.txt` | the per-arm direction table of §5 |
| `evidence/CENSUS.blastradius.txt` | the 49-directory / 8-directory census of §6 |
| `evidence/GATES.uhdm2rtlil.txt` | `byteverify` + both `ct8rows` joins |
| `evidence/SUBSET.txt` | `NOT-PRESENT-BEFORE = 0` for all six movers |
| `evidence/SHAPES.txt` | the shape lister, both modes, both binaries |
| `evidence/GATES.surelog.txt` | the Surelog-corpus joins and byte verification |
