# r10earl44 — § scopedConnPkgParamSubst44

**THE HEADLINE: the 30-line Earlgrey head is CLEARED and the row ADVANCES to a
new 186-line head in `prim_keccak.sv`. The design-wide census predicted TEN
objects before a line of code was written; the per-shape multiset of the two
dumps says **ten objects changed and nothing else** in 4.65 million lines. Five
gates green, canaries green, and the ONLY real byte mover in 2 311 databases is
the target itself (−806 B, size delta NONZERO).**

**And the pass's most useful product is a MEASURED CORRECTION OF ITS OWN FIRST
BUILD.** Binary `a300dbaa53e8fa0abe9d4aa877eac296` got the name, the span and
the `vpiActual` of all ten cells exactly right and the grid row STILL read
`DIFFER` — because `ref_obj::VpiFullName()` in UHDM **lazily COMPUTES** a full
name by walking the parent chain whenever the field is unset, and caches it into
the object at write time. "Golden has no `vpiFullName`" is therefore spelled
`VpiFullName(name)`, not "leave it unset". § 4.3 has the counterfactual.

---

## 0. THE LAW

> **§ scopedConnPkgParamSubst44 — in the DEF listing (`allModules`), a port
> connection whose actual is written as a `::`-QUALIFIED reference to a PACKAGE
> PARAMETER is SUBSTITUTED, and golden's answer splits on the SAME predicate
> § defConnPkgParamFold43 splits on — is there a value to hand over — but takes
> a DIFFERENT SHAPE ON BOTH SIDES of that split:**
>
> * **the parameter's def Rhs IS a constant (`pkgParamConst`) → a BARE
>   constant**: value, size, decompile and const type only, spanned over the
>   WHOLE written reference. **NO `vpiParent`, NO typespec** — which is exactly
>   what makes it a different cell from § 43's bare-written fold, whose constant
>   carries the package `param_assign` as its parent AND a `ref_typespec`.
> * **the parameter's def Rhs is an OPERATION (a pattern, concat or replication
>   — every struct/array shape) → the `ref_obj` SURVIVES**, but named with the
>   QUALIFIED spelling, carrying NO synthesized `vpiFullName`, bound through
>   `vpiActual` to the PACKAGE's own def-view `parameter` object, and spanned
>   from the start of the written name UP TO (not including) the FINAL
>   identifier — i.e. over the `pkg::` qualifier alone. **THIS IS THE EARLGREY
>   HEAD and its NINE design-wide twins.**
>
> **The BARE written form of both shapes is § 43's and does not move.** A
> package parameter in NEITHER gate — the ENUM-TYPED one, whose def Rhs is a
> `ref_obj` to an `enum_const` — is left exactly as it was (§ 7 R2).

### STATED GATE == CODE GATE

| § | file, site | the gate, verbatim |
|---|---|---|
| `scopedConnPkgParamSubst44` | `src/ModuleEmit.cpp`, `emitModuleDefPorts`, the DEF-view `ref_module` connection loop (immediately after § 43's block) | `if (expr->kind == ExpressionKind::NamedValue && expr->syntax && expr->syntax->kind == syntax::SyntaxKind::ScopedName)` then `if (psym44->kind == SymbolKind::Parameter && hsc44 && hsc44->asSymbol().kind == SymbolKind::Package)`; arm 1 `pkgParamConst.find(psym44) != end()`; arm 2 `pkgParamObj.find(psym44) != end() && paramDefRhsIsOp(psym44->as<ParameterSymbol>(), /*aggregateToo=*/true)` |

`hsc44 = psym44->getParentScope()`. The change is **one block of 127 inserted
lines and NOT ONE existing line modified** — `git diff --stat` reads
`1 file changed, 127 insertions(+)`. The pre-existing `expr->kind ==
NamedValue` arm below is untouched and is simply not reached when the new gate
fires.

Three deliberate choices, each measured rather than reasoned:

* **The written form is read as a SYNTAX KIND, not as `rawText(...).find("::")`.**
  § argWrittenQualIsSyntaxKind33 measured that an ESCAPED identifier `\a::b ` is
  ONE token whose NAME contains `::`, so the text test reads a bare reference as
  qualified and would mint a qualifier-spanned, package-bound ref where golden
  has a bare one.
* **The name is REBUILT from the symbols** (`hsc44->name + "::" + psym44->name`),
  never sliced out of the source text — the policy § pkgWrittenQualSelBase41
  states. `a1_earl44` `u_q17` writes `p44 :: PK_LOGIC32` with spaces and lands
  on golden's cell.
* **The span's end is the FINAL IDENTIFIER's start** (`sn44.right->sourceRange()
  .start()`), not `start + pkgname.size() + 2`. Same reason: the arithmetic
  form is wrong for `p44 :: P`, and § staticScopedRef12 already states the rule
  in exactly this shape (`Surelog's span stops just before the final
  identifier`).

---

## 1. THE CENSUS, BOTH SIDES, DESIGN-WIDE, SPAN-KEYED, BEFORE ANY CODE

### `census44.py` is NOT `census43.py`, and the difference is the whole pass

r10earl43's census tallied golden-**KIND** → ours-**KIND** and its headline
("exactly ONE divergent port connection in the design") was true *of the kind*.
**The r10earl44 head is `ref_obj → ref_obj`: it sits ON THE DIAGONAL of that
table and census43.py could not see it at all.** `census44.py` keys every port
`vpiHighConn` actual on the same `(section, scope, port name, port span)` and
then compares the FULL descriptor — kind, span, `vpiName`, `vpiFullName`,
presence+kind of `vpiActual`, presence of `vpiTypespec`, kind of `vpiParent` —
and tallies cells by DEFECT SIGNATURE.

```
Q1  port vpiHighConn actuals, design-wide      PRISTINE (86dca242)
    golden 31439   ours 31439   every kind IDENTICAL in both sections

Q2  SPAN-KEYED JOIN: 31439 common, golden-only 0, ours-only 0
    golden ref_obj  -> ours ref_obj    17202     <-- the head is IN HERE
    golden constant -> ours operation      2     (§ 43 R3, elab view)
    ... every other pairing on the diagonal

Q3  FIELD-LEVEL divergence on the 31439 common keys: 2661 cells
      2124  TS(G-only)
       375  SPAN
       139  NAME TS(G-only)
        10  SPAN NAME(G-qualified) FULLNAME(G-none) ACTUAL(G-only)   <-- THE HEAD
        10  FULLNAME                                (flash part_select, R5)
         2  KIND:constant->operation TS(O-only)     (§ 43 R3)
         1  ACTUALKIND                              (prim_arbiter_ppc, R6)

Q4  QUALIFIED (`::`) vpiName population among high-conn actuals
    golden: 10   allModules ref_obj nofull act   10
    ours  :  0
```

**The whole design contains exactly TEN cells with the head's signature, they
are the ENTIRE qualified population on golden's side, and ours is EMPTY.** All
ten live in `allModules`, all ten in `work@top_earlgrey`, all ten are
`pkg::*_DEFAULT` struct parameters:

```
628:26 pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT   699:18 pwrmgr_pkg::PWR_AST_RSP_DEFAULT
705:18 pwrmgr_pkg::PWR_OTP_RSP_DEFAULT           707:17 pwrmgr_pkg::PWR_LC_RSP_DEFAULT
708:20 pwrmgr_pkg::PWR_FLASH_DEFAULT             710:19 pwrmgr_pkg::PWR_PERI_DEFAULT
726:14 rstmgr_pkg::RSTMGR_AST_DEFAULT            728:15 rstmgr_pkg::RSTMGR_PERI_DEFAULT
746:14 clkmgr_pkg::CLK_DFT_DEFAULT               747:17 clkmgr_pkg::CLK_HINT_STATUS_DEFAULT
```

The **source** answers the same question independently: `grep -rnE
"\.\w+\s*\(\s*\w+::\w+\s*\)"` over the whole Earlgrey tree finds **twelve**
`::`-written single-token connections, ten of which are the port connections
above. The other two — `top_earlgrey.sv:448/449`,
`.SramAw(flash_ctrl_pkg::AddrW)` / `.SramDw(flash_ctrl_pkg::BusWidth)` — are
inside a `tlul_adapter_sram #( ... )` header, i.e. **parameter OVERRIDES, not
port connections**, so the SCALAR arm of this law has a design-wide Earlgrey
population of **ZERO** and is carried entirely by the probes.

### THE PREDICTION, made from the pristine dumps alone, before the edit

1. exactly **ten objects** change, in `allModules` only, all in `work@top_earlgrey`;
2. the `SPAN NAME(G-qualified) FULLNAME(G-none) ACTUAL(G-only)` signature goes `10 → 0`;
3. Q4 "ours" goes `0 → 10`, landing in golden's own bucket `allModules / ref_obj / nofull / act`;
4. NO kind changes at all — the Q2 table is untouched, because `ref_obj` stays `ref_obj`;
5. our dump grows by exactly `10 × 1 = 10` lines (a 5-line ref_obj subtree becomes a 6-line one);
6. no elab (`topModules`) cell moves.

### THE MEASUREMENT, after the edit (patched `aa73bb11`)

```
                                          PRISTINE   PATCHED  delta  PREDICTED
Q3 head signature cells                         10         0    -10      0
Q3 cells with ANY field divergence             2661      2651    -10   2651
Q4 ours qualified high-conn actuals              0        10    +10     10
Q2 golden ref_obj -> ours ref_obj             17202     17202      0  17202
o.dump lines                                4655204   4655214    +10    +10
golden-only line instances                   238500    238460    -40
ours-only   line instances                    70256     70226    -30
MULTISET DISTANCE                            308756    308686    -70
```

All six predictions land. Per-shape multiset of the two OURS dumps, **ADDED and
REMOVED separately, by MULTISET** — `ADDED shapes=31 instances=40`,
`REMOVED shapes=30 instances=30`, `NET=+10`:

```
ADDED   10  [        |vpiActual:]                                  (one shape, ten instances)
ADDED    1  [      \_ref_obj: (pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT), line:628:26, endln:628:38]
ADDED    1  [        |vpiName:pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT]
ADDED    1  [        \_parameter: (pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT), line:26:28, endln:26:55]
             ... and the same three shapes for each of the other NINE cells
REMOVED  1  [      \_ref_obj: (work@top_earlgrey.u_pinmux.lc_pinmux_strap_i.LC_PINMUX_STRAP_REQ_DEFAULT), line:628:26, endln:628:65]
REMOVED  1  [        |vpiName:LC_PINMUX_STRAP_REQ_DEFAULT]
REMOVED  1  [        |vpiFullName:work@top_earlgrey.u_pinmux.lc_pinmux_strap_i.LC_PINMUX_STRAP_REQ_DEFAULT]
             ... and the same three shapes for each of the other NINE cells
```

`31 = 1 + 3×10` and `30 = 3×10`. **Nothing else moved in a 4.65-million-line
dump.** The `\_parameter:` lines are the package's own def-view objects, which
both sides already carried byte-identically at the same dump offset (line
50778) — this pass only makes ten references POINT at them.

**A MEASUREMENT TRAP, recorded because it nearly went into this file as a
number.** The first `msdist.sh` reading of the patched dump was `549515`
(golden-only `483723`), an apparent catastrophe. It was a RACE: `earl44.sh`
truncates `o.dump` at the start of its redirect, and the previous run's complete
file had already satisfied the `-s o.dump` wait condition, so the instrument
read a half-written dump. Re-run after the process exited: `308686`. **A dump
distance measured against a file that is still being written is not a small
error, it is a random number** — every reading in this file was taken after the
producing process had exited.

---

## 2. THE GRID, CELL FOR CELL

`a1_earl44.sv` is the 26-cell scoped grid; `v44_overfire.sv` is the 14-cell
over-fire probe, one module so that the only thing separating two rows is the
property the law claims to key on. `grid44.py` prints `name=` and `full=` and
`act->` **separately and always** — `grid43.py` printed decompile ELSE fullname
ELSE name, i.e. exactly ONE of them, and would have rendered this head as a
naming residue instead of the three separate defects it is. **LHS is ALWAYS
golden.**

### `a1_earl44.sv` — `allModules`, the DEF listing

| cell | the actual, WRITTEN SCOPED | golden | pristine | patched |
|---|---|---|---|---|
| `u_q7` | `p44::PK_STRUCT` — **THE HEAD's shape** | `ref_obj` name=`p44::PK_STRUCT`, **no full**, act→`parameter`, span `104:25-104:30` | bare name + synthesized full, no act, full span ❌ | ✔ |
| `u_q8` | `p44::PK_STRUCTP` — pkg **`parameter`**, Earlgrey's own kind | same shape | ❌ | ✔ |
| `u_q9` | `p44::PK_ARR` — **unpacked array** | same shape | ❌ | ✔ |
| `u_deep` | the same write **one instance level down** (`mid44`) | same shape | ❌ | ✔ |
| `u_ni2` | the same write with **NO import in scope** | same shape | ❌ | ✔ |
| `u_q1` | `p44::PK_LOGIC32` | **BARE constant**, no parent, no ts, WHOLE span | `ref_obj` ❌ | ✔ |
| `u_q6` | `p44::PK_TDEF` (typedef'd type, typedef'd formal) | bare const `32'h0badc0de` | `ref_obj` ❌ | ✔ |
| `u_q17` | `p44 :: PK_LOGIC32` — **WHITESPACE spelling** | bare const | `ref_obj` ❌ | ✔ |
| `u_ni1` | `p44::PK_LOGIC32`, **NO import** | bare const | `ref_obj` ❌ | ✔ |
| `u_q3` | `p44::PK_INT` (int → `logic[31:0]`, implicit conv) | bare const `7` | ✔ | ✔ untouched |
| `u_q5` | `p44::PK_PARAM16` (16→32, implicit conv) | bare const `16'h00ff` | ✔ | ✔ untouched |
| `u_q15` | `p44::PK_LOGIC32` into an **implicit 1-bit formal** | bare const, size 32 | ✔ | ✔ untouched |
| `u_b1` | **BARE** `PK_LOGIC32` — § 43's cell | const + ts + `param_assign` parent | ✔ | **✔ DID NOT MOVE** |
| `u_b2` | **BARE** `PK_STRUCT` | bare-named `ref_obj` + synthesized full | ✔ | **✔ DID NOT MOVE** |
| `u_b3` | the module's **OWN** localparam | `ref_obj` | ✔ | **✔ DID NOT MOVE** |
| `u_b4` | **NET** control | `ref_obj` | ✔ | ✔ |
| `u_q14` | `p44::PK_LOGIC32 + 1` — **expression** | `operation` | ✔ | ✔ untouched |
| `u_q16` | **POSITIONAL** scoped conn | *no def-view port either side* | — | — |
| `u_q10` | `p44::PK_STR` — **string** | bare const `zz` size 16 | `ref_obj` ❌ | const, `"zz"` ⚠ **R3** |
| `u_q11` | `p44::PK_REAL` — **real** | bare const `1.500000` size 64 | `ref_obj` ❌ | const, `1.5` ⚠ **R3** |
| `u_q12` | `p44::PK_ENUM` — **enum-TYPED param** | bare const `1` size 2 `INT:1` | `ref_obj` ❌ | `ref_obj` ❌ **R2** |
| `u_q13` | `p44::EN_B` — **enum CONSTANT** | bare const `1` size 2 | `ref_obj` ❌ | `ref_obj` ❌ **R2** |
| `u_q21` | `p44::PK_VAR` — **package VARIABLE** | qualified name, **full KEPT**, act→`logic_var`, qualifier span | ❌ | ❌ **R1** |
| `u_q18` | `p44::PK_STRUCT.a` — **member access** | `hier_path`, no full | ❌ | ❌ **R4** |
| `u_q19` | `p44::PK_ARR[0]` — **index** | `bit_select`, no full | ❌ | ❌ **R4** |
| `u_q4` | `p44::PK_UNTYPED` — untyped | bare const `5` **size 64** | const size 32 ❌ | size 32 ❌ **R7** |

`a1_earl44` whole grid: **ROWS 99, non-MATCH 28 → 19**; **nine rows flipped to
MATCH and not one row regressed** (the verdict diff is nine one-line changes and
nothing else).

### `v44_overfire.sv` — the over-fire probe, ONE module

| cell | what it is | golden | pristine | patched |
|---|---|---|---|---|
| `u_e0` | **SCOPED** pkg scalar | bare const | `ref_obj` ❌ | ✔ |
| `u_e3` | **SCOPED** pkg struct | qualified ref + act | ❌ | ✔ |
| `u_e5` | **SCOPED** pkg unpacked array | qualified ref + act | ❌ | ✔ |
| `u_e1` | **BARE** pkg scalar — § 43 folds it | const + ts + parent | ✔ | **✔ DID NOT MOVE** |
| `u_e2` | the module's **OWN** twin (same type AND value) | `ref_obj` | ✔ | **✔ DID NOT MOVE** |
| `u_e4` | **BARE** pkg struct | `ref_obj` | ✔ | **✔ DID NOT MOVE** |
| `u_e6` | **BARE** pkg unpacked array | `ref_obj` | ✔ | **✔ DID NOT MOVE** |
| `u_e10` | **SCOPED** pkg **FUNCTION CALL** `q44::q_f()` | — | ✔ | **✔ DID NOT MOVE** |
| `u_e11` | **CLASS**-scoped static const `cls44::CI` | qualified (§ 12) | ✔ | **✔ DID NOT MOVE** |
| `u_e12` | **CLASS**-scoped static var `cls44::SV` | qualified (§ 12) | ✔ | **✔ DID NOT MOVE** |
| `u_e13` | **CLASS**-scoped localparam `cls44::CP` | qualified, full kept, qualifier span | ❌ | ❌ **R1** |
| `u_e7` | **SCOPED** pkg enum-TYPED param | bare const `1` | ❌ | ❌ **R2** |
| `u_e8` | **SCOPED** pkg **ENUM CONSTANT** | bare const `1` | ❌ | ❌ **R2** |
| `u_e9` | **SCOPED** pkg VARIABLE | qualified, full kept, act→`logic_var` | ❌ | ❌ **R1** |

`v44_overfire` whole grid: **ROWS 28, non-MATCH 11 → 8**.

**`u_e1`, `u_e2`, `u_e4`, `u_e6` are the positive controls this pass exists to
survive**, and `u_e11`/`u_e12` are the second set: a class-scoped `::` actual in
a port connection reaches `emitExpr` only when the formal forces an implicit
conversion, so § staticScopedRef12 already owns them and this law must not.
Both stayed put. `u_e13` — the SAME class, a `logic[31:0]` localparam into a
`logic[31:0]` formal, hence NO conversion and hence the short-circuit — is
wrong on both binaries and is ranked R1.

### § 43's OWN GRIDS RE-RUN ON BOTH BINARIES — the boundary, measured

The brief requires that § defConnPkgParamFold43's `a1_earl43` and `v43_overfire`
grids HOLD and CONTAIN this pass's witnesses. They do, and the two witnesses are
exactly the two rows that flip:

```
a1_earl43     grid43.py  ROWS 61  NON-MATCH 5 -> 4      (u_c2 DIFFER -> MATCH)
v43_overfire  grid43.py  ROWS 18  NON-MATCH 3 -> 2      (u_e8 DIFFER -> MATCH)
a1_earl43     grid44.py  ROWS 61  NON-MATCH 8 -> 7
v43_overfire  grid44.py  ROWS 18  NON-MATCH 4 -> 3
```

`u_c2` (`p43::PK_LOGIC32`) and `u_e8` (`q43::Q_PLAIN`) were § 43's residue R1
and are now golden-exact. The verdict diff of each grid is ONE line; every
other § 43 cell — including `u_e1`/`u_e7`, the ownership controls, and `u_b1`'s
twin `u_c1` — is byte-identical.

**grid44.py sees THREE cells grid43.py cannot**, which is why the two counts
differ (5 vs 8, 3 vs 4): `grid43.py` prints no `vpiSize`, so § 43's `u_e5`
(pkg `real`, golden size **32**, ours size **64**, on BOTH binaries) reads as
MATCH there. That is a PRE-EXISTING § 43 residue this pass surfaces and does
not touch — ranked R7.

---

## 3. THE HEAD

Pristine, **byte-identical to the committed witness
`tools/probe/r10earl43repro/r6_nexthead43.cmp`** (asserted by `diff` BEFORE any
code was written, 30 lines) — the only proof that this pass stands on the base
the brief describes:

```
LHS: ref_obj (pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT) 628:26-628:38
     |vpiName:pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT
     |vpiActual: parameter (pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT) 26:28-26:55
RHS: ref_obj (work@top_earlgrey.u_pinmux.lc_pinmux_strap_i.LC_PINMUX_STRAP_REQ_DEFAULT)
     628:26-628:65  |vpiName:LC_PINMUX_STRAP_REQ_DEFAULT  |vpiFullName:...
```

Patched, the row ADVANCES to a NEW head of **186 lines**, committed here as
`r6_nexthead44.cmp`. It is a DIFFERENT FAMILY in a different file —
`prim_keccak.sv:52:5`, an assignment-pattern `operation` (op75) inside a
localparam's pattern:

```
LHS: operation 52:5-52:32  |vpiSize:32  |vpiOpType:75
     five UINT operands, each whose vpiParent is a DIFFERENT operation at 60:31-60:48
RHS: operation 52:5-52:32  (NO vpiSize)  |vpiOpType:75
     the same five operands, each self-parented at 52:5-52:32
```

Two defects for the next pass, both stated: the inner pattern operation carries
**`vpiSize`** on golden and none on ours, and golden's operand constants are
**RE-PARENTED onto the enclosing per-row operations** while ours parent onto the
operation that holds them. Neither is a port connection and neither is in this
family.

---

## 4. THE FIVE GATES

Binary under test **`/tmp/wt_r10earl44/build/slang-uhdm` md5
`aa73bb11558ed2222d6aa741071005f1`**; PRISTINE `acc7e56`, built by me in a clean
worktree, **`/tmp/wt_r10earl44pris/build/slang-uhdm` md5
`86dca24264416ef39ce3932bc9a2b0e0`**. Both bases printed and grep-checked
(`git log --oneline -1` = `acc7e56` in each; the patched tree's `git status`
shows `M src/ModuleEmit.cpp` and the untracked probe dir, nothing else).

**A DETERMINISM CONTROL that came free**: the patched worktree was built ONCE
BEFORE the edit and produced md5 `86dca242...`, **the same md5 as the pristine
worktree's independent build**. Two different directories, two builds, one hash
— so the later `aa73bb11` is a property of the edit and not of the build tree.

| gate | result |
|---|---|
| 1 BUILD | `~/.local/bin/cmake --build /tmp/wt_r10earl44/build -j 2`, ABSOLUTE path; waited for `Linking CXX executable slang-uhdm`; `0` lines matching `error:`; md5 asserted SEPARATELY afterwards (32 hex) and RE-ASSERTED UNCHANGED after every gate had run. `ModuleEmit.cpp` mtime `17:01:17`, binary mtime `17:02:45` — no gate stands on a stale binary |
| 2 GOLDENS | `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| 3 u2r testflags | `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL`; dump `496 match / 183 differ / 52 blank`; `ct8rows.sh` vs committed `results/gate_uhdm2rtlil.csv`: **0 differing ROWS (0 diff row-sides)**; `diff` of the sorted pat/pris CSVs EMPTY in BOTH modes |
| 4 surelog both modes | see § 4.1 |
| 5 BYTE VERIFIER | see § 4.2 |

`GOLDEN_DEFER` was left UNSET throughout. `verify_golden.py` SILENTLY DEFAULTS
`SLANG_UHDM`, so every sweep EXPORTED it and the binary each sweep ACTUALLY
invoked was read back out of `cmds.txt`, not assumed:

```
pat : /tmp/wt_r10earl44/build/slang-uhdm
pris: /tmp/wt_r10earl44pris/build/slang-uhdm
```

### 4.1 GATE 4 — surelog corpus, BOTH modes, ONE INVOCATION PER MODE

Eight sweeps, strictly sequential, `--jobs 2`, one `verify_golden.py` per
(corpus, mode, binary), so the documented SURELOG_FAIL detail-row race under
concurrent sweeps cannot fire.

```
[default]   794 tests  CMP_EQUAL 469  CMP_NOTEQUAL 11  SURELOG_FAIL 25  DEFERRED 5  -> 469/11 EXPECTED
[testflags] 794 tests  CMP_EQUAL 465  CMP_NOTEQUAL  8  SURELOG_FAIL 23  DEFERRED 5  -> 465/8  EXPECTED
```

`ct8rows.sh` against the committed `results/golden_surelog.csv` (both modes
concatenated, header taken once):

```
baseline: 1589 lines = 1588 ROWS      fresh: 1589 lines = 1588 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
---- per-mode STATUS histogram (baseline -> fresh)
  default   base/fresh: 469 CMP_EQUAL  11 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
  testflags base/fresh: 465 CMP_EQUAL   8 CMP_NOTEQUAL  5 DEFERRED    3 NO_DATABASE   1 NO_UHDM
                        286 SLANG_REJECT 23 SURELOG_FAIL 1 TIMEOUT    2 UNTRANSLATABLE
---- per-mode DUMP-column histogram (baseline -> fresh)
  default   base/fresh: 325 blank  244 differ  225 match
  testflags base/fresh: 329 blank  300 differ  165 match
PASS: every row byte-identical to the committed baseline
```

Both histograms UNCHANGED, 0 rows moved, and `diff` of the sorted pat/pris CSVs
is **empty** — the same four sweeps run with the pristine binary produce a
byte-identical CSV. The target's own rows are byte-identical to the baseline —
**its ROW does not move, its BYTES do**:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,
```

### 4.2 GATE 5 — BYTE VERIFIER, both corpora, BOTH modes, vs PRISTINE

```
uhdm2rtlil : databases patched=1358 pristine=1358  PATH_SETS_IDENTICAL  MOVERS: 0 / 1358
             SELFCHECK=1 -> 1357 / 1358 flagged    SELFCHECK1=1 -> 1
```

```
surelog    : databases patched= 953 pristine= 953  PATH_SETS_IDENTICAL  MOVERS: 2 /  953
  MOVER ./default/default/Earlgrey_0_1-71da2fd7/slang.uhdm  patched=115906084178 pristine=d3dcad27f75b
  MOVER ./default/default/Scoreboard-59431470/slang.uhdm    patched=431383fbb4b3 pristine=57cf33d6ccab
             SELFCHECK=1 ->  952 /  953 flagged    SELFCHECK1=1 -> 3
```

`SELFCHECK1 = 3 = the one corrupted file + the two movers`, and `= 1` on the
uhdm2rtlil half where there is no mover — exactly what that control's own
message says to expect. Both controls fire on both corpora. The uhdm2rtlil half
covers BOTH modes (679 × 2 = 1358 databases).

**MOVER RULE APPLIED TO EACH MOVER SEPARATELY.**

```
SIZE Earlgrey_0_1/default  patched 49940578  pristine 49941384  -> -806   NONZERO
SIZE Scoreboard/default    patched 11122776  pristine 11122776  ->    0   PROVES NOTHING
```

* **Earlgrey: −806 B, NONZERO, so by the stated rule the mover is REAL** — and
  the per-shape multiset in § 1 accounts for it object-for-object: ten
  synthesized `vpiFullName` strings (~80 chars each) dropped, ten short
  qualified names and ten `vpiActual` ID references added.
* **Scoreboard: size delta ZERO, so it proves nothing and was ARBITRATED, not
  assumed.** Running the SAME test alone, five times:

```
PRISTINE run1 57cf33d6ccab   run2 57cf33d6ccab   run5 57cf33d6ccab   run6 e39ac0aaca78   run7 e39ac0aaca78
PATCHED  run3 e39ac0aaca78   run4 f122beb8472d                     (sweep: 431383fbb4b3)
```

**The pristine binary produces at least two distinct databases for the same
input, and one of them (`e39ac0aaca78`) is a database the PATCHED binary also
produces** — every one at the identical size `11122776`. The dumps of the two
sweep databases have the SAME line count (1 094 813) and differ in 170 lines
that are entirely `|vpiTaskFunc:` / `\_function:` / `\_task:` / `uvm_pkg`
typedef listing ORDER — **not one `port`, `vpiHighConn`, `ref_obj` or
`pkg::PARAM` line among them**. This is the documented emitter nondeterminism
(`SourceLocation` compares across macro buffers flip per run under parallel
parse), the same canary that flaked in r10earl42 and was clean in r10earl43 by
luck of the run.

**ONE REAL MOVER IN 2 311 DATABASES, and the verifier names it as the target.**

### 4.3 THE COUNTERFACTUAL — the build that looked complete and was not

Binary `a300dbaa53e8fa0abe9d4aa877eac296` is this pass's arm WITHOUT
`r44->VpiFullName(qn44)`. Its cells read:

```
  \_ref_obj: (work@top44.u_q7.p_i.p44::PK_STRUCT), line:104:25, endln:104:30
    |vpiName:p44::PK_STRUCT                     <-- golden's name
    |vpiFullName:work@top44.u_q7.p_i.p44::PK_STRUCT   <-- SYNTHESIZED BY UHDM
    |vpiActual: \_parameter: (p44::PK_STRUCT)   <-- golden's actual
```

Name, span and actual are all golden's and the row is still `DIFFER`. The cause
is in UHDM, not in us: the generated `ref_obj::VpiFullName()` is

```cpp
std::string_view ref_obj::VpiFullName() const {
  if (!vpiFullName_) {
    const std::string fullName = ComputeFullName();       // walks VpiParent()
    if (!fullName.empty()) const_cast<ref_obj*>(this)->VpiFullName(fullName);
  }
  return serializer_->GetSymbol(vpiFullName_);
}
```

— it MANUFACTURES and CACHES a full name whenever the field is unset, and
`Serializer_save.cpp` says so in its own comment ("some symbols are made doing
so (VpiFullName)"). `ref_obj::GetVpiPropertyValue` then prints the field only
when it DIFFERS from `vpiName`. So **the only way to reproduce golden's "no
`vpiFullName`" line is to set the full name EQUAL to the name**, which is
precisely the idiom § fcArgBareImportRef and § structParamBareImportRef already
use (`ref->VpiName(pn); ref->VpiFullName(pn);`). The existing code had written
the answer down; the first build had not read it. `ref_obj::Compare` does not
read `vpiFullName` at all, so this is cmp-INERT and pure dump distance — with
`a300dbaa` the head would have CLEARED exactly as it does now and the pass would
have shipped ten cells that are wrong in the dump.

---

## 5. CANARIES

```
canaries.sh  u2r (testflags projection) : rows ok=8  changed=0 absent=0 unknown-names=25
canaries.sh  SL  (both modes)           : rows ok=52 changed=0 absent=0 unknown-names=7
ctcan2.sh    u2r  EXPECT_UNKNOWN=6      : rows ok=1  changed=0 absent=0 unknown-patterns=6  PASS
ctcan2.sh    SL   EXPECT_UNKNOWN=1      : rows ok=58 changed=0 absent=0 unknown-patterns=1  PASS
canaudit.sh                             : audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
```

Both `ctcan2` runs take the COMMITTED baseline as their FIRST argument and are
mode-matched to the corpus. **Its guard was EXERCISED on BOTH corpora, not
assumed**: re-running each with `EXPECT_UNKNOWN=0` exits **6**, so an
unaccounted unmatched pattern can never read as green. `canaudit.sh` re-asserts
that the four SLANG-FENCED names (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) are dispatched by NO driver in this directory.

The four named canaries are `CMP_EQUAL`+`differ` rows, i.e. **their ROWS are
BLIND to byte changes**, so the DATABASES were compared BY NAME, byte for byte:

```
InterfaceModPort     default / testflags   BYTE-IDENTICAL (38003 B)
BlackParrotComplex   default / testflags   BYTE-IDENTICAL (48433 / 50584 B)
YosysOldOr           default / testflags   BYTE-IDENTICAL (14783104 B)
SVSwitch             default / testflags   BYTE-IDENTICAL (247237 B)
Earlgrey_0_1         default               DIFFERS  49940578 vs 49941384  (the target)
Earlgrey_0_1         testflags             no database (SLANG_REJECT at baseline)
```

**PROTECTED genscope canaries, BY NAME, u2r testflags, patched vs pristine
DATABASES — all BYTE-IDENTICAL** (they are also inside gate 3's `0 differing
ROWS` and gate 5's `MOVERS: 0 / 1358`):

```
gen_test9  genvar_loop_decl_2  genvar_loop_decl_3  paramod_genscope_child
genscope_cells  gen_test4  indexed_partsel_array  EnumConcat
```

**BOUNDARIES held.** The diff touches `src/ModuleEmit.cpp` and nothing else.

* **§ defConnPkgParamFold43** (`emitModuleDefPorts`, the block immediately
  above): its grids were RE-RUN on both binaries, § 2 above. `u_c1`, `u_b1`'s
  twin, `u_e1`, `u_e7` and every other bare cell are byte-identical; the two
  rows that move are its own named residue R1. **This law fires only on
  `ScopedName` and § 43's gate excludes `::`, so the two are disjoint by
  construction, not by ordering.**
* **§ pkgWrittenQualSelBase41** owns QUALIFIED SELECT BASES. `a1_earl44` `u_q19`
  (`p44::PK_ARR[0]`) is that family's cell in this position: it is a
  `bit_select`, it is ALREADY qualified on both binaries, and this pass does not
  touch it (the gate requires `expr->kind == NamedValue`; a select is not one).
  Ranked R4.
* **The naming-context memory** (`pkg::pkg::` names are CONTEXT-DEPENDENT, never
  uniformly folded) is honoured: this law qualifies a name in ONE syntactic
  position — a def-view port connection whose actual is written `pkg::P` — and
  the probes carry the bare twin of every qualified cell to prove the two do not
  move together.
* **§ staticScopedRef12** owns CLASS-scoped `::` references. `v44_overfire`
  `u_e11`/`u_e12` are its cells reached through an implicit conversion; both are
  MATCH on both binaries and did not move. `u_e13`, the un-converted class
  localparam that never reaches `emitExpr`, is wrong on both binaries and is
  ranked R1 — this law deliberately does not claim it, because its gate requires
  the symbol's parent scope to be a **Package**.
* **§ fcArgPkgParamValueFolds32 / § structParamBareImportRef** own CALL-ARGUMENT
  and general module-side reads in `emitExpr`. This is a PORT CONNECTION in the
  DEF listing, a different site; nothing in `ExprEmit.cpp` is touched, and the
  arm READS the two maps (`pkgParamConst`, `pkgParamObj`) those rules populate
  rather than deciding them.
* **`r10sd4` (package wall ddmin, likely `UhdmExporter`/`ModuleEmit`) — REPORTED
  PER THE BRIEF.** `ModuleEmit.cpp` is shared. This change is a **single
  insertion-only hunk of 127 lines** inside `emitModuleDefPorts`'s DEF-view
  `ref_module` connection loop at ~2890; it modifies NO existing line and adds NO
  member, so a textual conflict is possible only if `r10sd4` edits that same
  loop. **No collision to report as of this writing.** `r10uvm72` works in
  `ExprEmit`/`TaskFuncEmit` — untouched here.

---

## 6. REFUTATIONS, STATED PLAINLY

**R-1. "The scoped form is the same law as § 43 with the `::` allowed through."
FALSE, and implementing it that way would have stamped a parent and a typespec
golden does not have.** Golden's scoped SCALAR fold is a **BARE** constant — no
`vpiParent`, no `ref_typespec` — where § 43's bare-written fold carries BOTH
(`a1_earl44` `u_b1` vs `u_q1`, the same parameter, the same formal, the same
module, differing only in the spelling of the actual). § 43 said this in its own
R1 and this pass measures it: the two cells are four fields apart.

**R-2. "A scoped package parameter always folds." FALSE — and the shape golden
keeps is not the one we had.** The aggregate half (`u_q7`, `u_q8`, `u_q9`,
`u_deep`, `u_ni2`, `u_e3`, `u_e5`, and all ten Earlgrey cells) keeps a
`ref_obj`. The *predicate* is the same one § 43 uses — is there a value to hand
over — and its two answers produce two DIFFERENT shapes, which is why this law
has two arms instead of one.

**R-3. "The import is what makes the reference resolvable." REFUTED BY
MEASUREMENT.** `a1_earl44`'s `noimp44` module has NO import at all and its two
cells (`u_ni1` scalar, `u_ni2` struct) are byte-identical to the imported
`u_q1`/`u_q7`. The written qualifier is the whole gate; the import is not in it.

**R-4. "The ELAB view will move too." NO — and it was checked, not assumed.**
Every scoped cell's `topModules` row already MATCHED golden on the pristine
binary (`u_q1`, `u_q6`, `u_q10`, `u_q11`, `u_q12`, `u_q13`, `u_q15`), because the
elab path calls `emitExpr` while the DEF loop SHORT-CIRCUITS it for a
`NamedValue`. The census confirms design-wide: not one `topModules` cell moved.
**The elab view was, once again, never broken** — r10earl43's R-3 holds for the
scoped family as well as the bare one.

**R-5. "Our span was wrong in an unprincipled way." NO — ours is the whole
written name, golden's stops before the FINAL IDENTIFIER**, and that rule was
already written down in this codebase by § staticScopedCall12
(`splitScopedName12`'s `outEnd`) and § fcArgBareImportRef. This pass did not
discover the rule, it discovered that the def-view connection loop is a site
that never applied it.

**R-6. "`grid43.py` would have done." NO.** It prints decompile ELSE fullname
ELSE name and no size, so it renders golden's `name=pkg::P, full=-` against our
`name=P, full=work@...` as a single naming string, and it cannot see § 43's own
`u_e5` size defect at all. Three of the four counts in § 2 exist only because
the instrument was rewritten first.

---

## 7. RANKED RESIDUES

**R1 — QUALIFIED non-parameter references in a def-view port connection:
package VARIABLES (`a1_earl44` `u_q21`, `v44_overfire` `u_e9`) and CLASS
localparams (`u_e13`).** Golden qualifies the name and spans the qualifier for
these too, but — unlike the parameter cell — **KEEPS a `vpiFullName`**
(`work@mix44.u_e9.p_i.q44::Q_VAR`), and for the package variable binds
`vpiActual` to the package's own `logic_var` where we bind the importing
module's materialized `logic_net`. Earlgrey population **0** for both, which is
why they are residues and not arms: adding them would be an unmeasured
generalisation over a corpus that cannot check it. The package-variable cell is
ALSO wrong in the ELAB view (span only — `55:24-55:29` vs `55:24-55:34`), which
means `isPkgQualifiedVarRef`'s `setLoc(qr9, expr.sourceRange)` in `ExprEmit.cpp`
is the single site for BOTH views. Highest value: three cells, one probe,
one span rule already implemented twice elsewhere.

**R2 — the ENUM value source, now TWO cells wide (was § 43's R2).** Golden folds
BOTH `pkg::ENUM_TYPED_PARAM` (`u_q12`, `u_e7`) and `pkg::ENUM_CONSTANT`
(`u_q13`, `u_e8`) to `constant` `vpiDecompile:1`, `vpiSize:2` (the enum's base
width), `INT:1`, `vpiConstType:7`. **This gate provably does NOT own them and I
measured why**: the enum-typed parameter's def Rhs is a `ref_obj` to the
`enum_const`, so it is in NEITHER `pkgParamConst` NOR `paramDefRhsIsOp`, and the
enum CONSTANT is not a `Parameter` symbol at all. A second value source is
needed (`ParameterSymbol::getValue()` / `EnumValueSymbol::getValue()`), and this
pass adds a NEW datum for whoever takes it: **the scoped fold wants a BARE
constant** (no parent, no ts) where § 43's bare fold wants parent + ts
(`v43_overfire` `u_e6`: golden `constant 1 ts->ref_typespec(work@mix43)
par=param_assign`). So R2 is one value source feeding two different shapes.
**Earlgrey population: ZERO** — measured, not assumed.

**R3 — the scoped fold of a STRING or REAL package parameter takes the
*value-substituted* decompile, not the package's def constant.** Measured:
golden's scoped cell is `dec=zz sz=16` and `dec=1.500000 sz=64` — byte-identical
to what the ELAB view substitutes — while the package's own def constant (which
this arm copies, and which § 43's bare fold copies correctly) is `dec="zz"` and
`dec=1.5`. So for these two types the scoped fold is NOT "the parameter's own
def constant re-spanned". Integral parameters are unaffected (both forms agree),
which is why all four scalar probe cells and all ten Earlgrey cells land.
Earlgrey population **0**; probe cells `u_q10`, `u_q11`.

**R4 — qualified SELECT / MEMBER-ACCESS actuals keep a synthesized fullname.**
`u_q19` (`p44::PK_ARR[0]`, a `bit_select` already correctly named by
§ pkgWrittenQualSelBase41) and `u_q18` (`p44::PK_STRUCT.a`, a `hier_path`) both
carry a `vpiFullName` golden does not print, and `u_q18`'s inner `ref_obj` is
named `work@top44.u_q18.p_i.a` where golden names it `a`. The § 43/§ 44 fix
("set the full name equal to the name") is the same one-line shape. Earlgrey
population 0 in port connections.

**R5 — the 10 `FULLNAME`-only cells the census names, in the ELAB view.**
`work@flash_phy_rd_buffers` `addr_i` × 8 and `work@prim_flash` `addr_i` × 2:
golden's `part_select` fullname doubles through the instance AND the port
(`...gen_bufs[0].i_rd_buf.addr_i.addr_i`) where ours stops at the gen block
(`...gen_bufs[0].addr_i`). Present identically on both binaries. This is now
the LARGEST remaining exactly-characterised port-connection family in Earlgrey.

**R6 — the 1 `ACTUALKIND` cell.** `work@prim_arbiter_ppc` `data_i`: golden binds
a `struct_net`, we bind an `array_net`. One cell, both binaries.

**R7 — § 43's `u_e5`: a package `real` parameter's bare fold has `vpiSize:64`
where golden has `32`.** PRE-EXISTING on both binaries, invisible to
`grid43.py` (which prints no size), surfaced here by `grid44.py`. Zero Earlgrey
population; one line in `ParamEmit`'s real-constant sizing.

**R8 — `golden-only line instances: 238460` still dwarfs `ours-only: 70226`.**
Earlgrey's remaining 308 686 distance is overwhelmingly *things golden has that
we do not emit* (`TS(G-only)` alone is 2 124 port-connection cells), not things
we emit wrongly. Unchanged as a conclusion; this pass moved 70 of it.

---

## 8. FILES

| file | what it is |
|---|---|
| `census44.py` | design-wide, span-keyed, section-separated census of EVERY port `vpiHighConn` actual, BOTH sides, compared FIELD BY FIELD and tallied by DEFECT SIGNATURE (census43.py compared KINDS and could not see this head) |
| `grid44.py` | per-connection grid keyed on the port's INSTANCE, BOTH sides, printing `name=` / `full=` / `act->` / `ts->` / `par=` SEPARATELY and ALWAYS |
| `a1_earl44.sv` | the 26-cell scoped grid: written form × parameter shape × formal type × import/no-import × named/positional × depth × not-a-parameter |
| `v44_overfire.sv` | the 14-cell over-fire probe in ONE module: every scoped cell beside its BARE twin, plus the class-scope and package-function cells § 12 owns |
| `arm44.sh` | single-file arm driver (carried forward; `SLANG_UHDM` has no default, md5 printed, `sed 1d` both dumps) |
| `earl44.sh` | Earlgrey_0_1 default-mode driver against the immutable golden cache |
| `msdist.sh` | resync-immune multiset dump distance (carried forward) |
| `byteverify44.sh` | GATE 5 comparator with both mandatory negative controls |
| `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the row gate and the canary set (carried forward verbatim) |
| `r6_nexthead44.cmp` | the patched binary's Earlgrey `cmp.log` verbatim (186 lines), the witness for the NEXT pass |

`README.verifier.md` is the VERIFIER's to author. It is deliberately not
written here.

---

## 9. THE NEW HEAD, COMMITTED AS A WITNESS

`r6_nexthead44.cmp` is the patched binary's Earlgrey `cmp.log` verbatim (186
lines), so the NEXT pass can assert byte-identity against it exactly as this
pass asserted byte-identity against `r10earl43repro/r6_nexthead43.cmp` (30
lines) before starting. That assertion is not a formality: it is the only proof
that the pass is standing on the base the brief describes.
