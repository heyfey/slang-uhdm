# r10earl43 — § defConnPkgParamFold43

**THE HEADLINE: the 46-line Earlgrey head is CLEARED and the row ADVANCES to a
new 30-line head. The whole-design multiset distance falls `308767 → 308756`
(−11), and the per-shape diff of the two dumps shows **ONE object changed** —
13 line-shapes added, 4 removed, exactly the census's prediction. Five gates
green, canaries green, ONE real byte mover in 2 311 databases and it is the
target itself.**

**And the pass's most useful product is a REFUTATION OF THE BRIEF'S OWN
FRAMING.** The brief describes the head as *"a parameter OVERRIDE site whose
written value is an imported package parameter"* and asks which callee module
declares the parameter at `9:27-9:66`. It is not an override site and there is
no callee parameter. `top_earlgrey.sv:290` is

```systemverilog
    .boot_addr_i          (ADDR_SPACE_ROM),
```

— a **PORT CONNECTION**. The committed witness says so in its own RHS block
(`vpiParent: port (boot_addr_i) 290:5-290:43`), and `9:27-9:66` is
`tl_main_pkg.sv`'s **package localparam** `param_assign`, i.e. the *source* of
the folded value, carried along as the folded constant's `vpiParent`. The grid
carries the brief's framing as a MEASURED cell (`a1_earl43.sv` u_c16) so the
refutation is a measurement, not an assertion: a real `#(.PW(PK_LOGIC32))`
override already folds on BOTH sides today (§ 6 R-1).

---

## 0. THE LAW

> **§ defConnPkgParamFold43 — in the DEF listing (`allModules`), a port
> connection whose actual is a BARE reference to a PACKAGE parameter is
> SUBSTITUTED by that parameter's OWN def-view constant: the parameter's value,
> width and written base, re-spanned at the REFERENCE, keeping the PACKAGE's
> `param_assign` as its `vpiParent`, and carrying a `ref_typespec` whose
> `vpiFullName` is the ENCLOSING MODULE's def name (`work@<mod>`) and whose
> actual is the parameter's DECLARED typespec.**
>
> **A MODULE-OWN parameter or localparam does NOT fold — it stays a `ref_obj`,
> even when it is the package one's exact twin, and even when its own value was
> COPIED from the package one.**
>
> Ownership is PER PARAMETER, never per scope: the gate is membership of
> `pkgParamConst`, which is keyed on the SYMBOL and populated only from
> `inPackage && !topView` parameters whose Rhs is a `constant`. That second
> half is not decoration — it is exactly why a package **packed-struct** or
> **unpacked-array** parameter, whose def Rhs is an OPERATION, correctly stays
> symbolic.
>
> **The WRITTEN `pkg::P` form is a DIFFERENT CELL and is deliberately NOT
> folded here** (§ 7 R1).

### STATED GATE == CODE GATE

| § | file, site | the gate, verbatim |
|---|---|---|
| `defConnPkgParamFold43` | `src/ModuleEmit.cpp`, the DEF-view `ref_module` connection loop (the `defRefModConn` block) | `if (psym43 && psym43->kind == SymbolKind::Parameter && rawText(sx43.sourceRange).find("::") == std::string::npos) if (auto pit43 = pkgParamConst.find(psym43); pit43 != pkgParamConst.end()) pkc43 = pit43->second;` |

where `sx43 = stripImplicitConv(*expr)` and `psym43` is that expression's
`NamedValueExpression` symbol when it has one. The whole change is one block
inserted ahead of the existing `expr->kind == NamedValue` arm; **no existing
line of code is modified** — the pre-existing `ref_obj` arm is untouched and is
simply not reached when the new gate fires.

### The reference is read THROUGH the implicit conversion — and that is measured, not assumed

Whether the actual carries an implicit conversion is a property of the FORMAL,
not of the reference: a 32-bit package parameter into a `logic [31:0]` formal
has none, into a `logic [15:0]` or an implicit 1-bit formal it does. Golden's
cell is the SAME either way — the parameter's own value at the parameter's own
width in the parameter's own base, regardless of the formal (`a1_earl43` u_c15
pushes a 32-bit value at a 1-bit formal and golden still prints
`32'h00008000`, size 32).

**Reading only the bare `NamedValue` would have left the pass half-done and
would have looked complete.** The Earlgrey head is the unconverted shape, so it
would have cleared; but `a1_earl43`'s `u_c5` / `u_c6` / `u_c10` / `u_c15` reach
the def listing through `emitExpr`, which ALREADY folds a package parameter
through a conversion — they were emitting the CORRECT constant with NEITHER the
parent NOR the typespec. Measured, not reasoned: the FIRST build of this pass
(md5 `98d4d6e3b476d154e79386bde8809128`, the bare-`NamedValue` gate) cleared the
head's own shape in the arm and left the `a1_earl43` grid at **9** non-matching
rows and `v43_overfire` at **3**; adding `stripImplicitConv` took `a1_earl43` to
**5** — of which 4 are named residues this § does not claim — and left
`v43_overfire` at 3, its two remaining cells also named residues. That first
binary is quoted here because it is the counterfactual: a pass that had stopped
there would have reported the same cleared head.

---

## 1. THE CENSUS, BOTH SIDES, DESIGN-WIDE, SPAN-KEYED, BEFORE ANY CODE

`census43.py` walks both `uhdm-dump` trees by indentation, skipping
`vpiParent:` as containment (it is a BACK-reference printed in exactly the same
shape as a child) while READING it where it is the datum in question, and keys
**every port's `vpiHighConn` actual** on
`(dump section, enclosing scope, port name, port span)`.

```
Q1  port vpiHighConn actuals, design-wide       PRISTINE (288e337f)
    section     kind                  golden   ours
    allModules  constant                1999    1998
    allModules  ref_obj                 7373    7374
    topModules  constant                2395    2393
    topModules  operation               2827    2829
    ... every other kind IDENTICAL, both sections
    TOTAL                              31439   31439
```

```
Q2  SPAN-KEYED JOIN: 31439 common keys, golden-only 0, ours-only 0
    golden constant  -> ours constant    4391
    golden constant  -> ours operation      2   <-- residue R3, elab view
    golden constant  -> ours ref_obj        1   <-- THE HEAD, def view
    golden ref_obj   -> ours ref_obj    17202
    ... every other pairing on the diagonal
```

**The whole design contains exactly ONE `constant → ref_obj` port-connection
divergence and it is the head**, `top_earlgrey.sv:290:28`. Question (e) of the
brief — "how many adjacent override-site cells diverge the same way" — is
answered before any code: **one**, and the fix cannot clear more than the one.

```
Q4  SHAPE of the constant high conns                 PRISTINE
    section     vpiParent        typespec   golden   ours
    allModules  <none>           no           1988   1988
    allModules  param_assign     YES             1      0   <-- the head's shape
    allModules  port             no             10     10
    topModules  port             no           2388   2386
    topModules  port             YES             7      7
```

Golden prints the fold's shape (`param_assign` parent **plus** typespec)
**exactly once** in the whole of Earlgrey_0_1; we printed it zero times.

### THE PREDICTION, made from the pristine dumps alone, before the edit

1. exactly **one object** changes, in `allModules` only;
2. `constant → ref_obj` goes `1 → 0`; `constant → constant` goes `4391 → 4392`;
3. the `allModules / param_assign / typespec` cell goes `0 → 1`, landing on
   golden's **1**, not near it;
4. our `ref_obj` count in `allModules` goes `7374 → 7373`, golden's number;
5. our dump grows by exactly `14 − 5 = 9` lines (the folded constant's subtree
   minus the ref_obj's);
6. the two `constant → operation` cells do NOT move — they are the elab view
   and a different mechanism.

### THE MEASUREMENT, after the edit (patched f376ff68)

```
                                   PRISTINE     PATCHED   delta   PREDICTED
golden constant -> ours ref_obj           1           0      -1      0
golden constant -> ours constant       4391        4392      +1   4392
allModules param_assign+ts (ours)         0           1      +1      1
allModules ref_obj (ours)              7374        7373      -1   7373
golden constant -> ours operation         2           2       0      2
o.dump lines                        4655195     4655204      +9     +9
golden-only line instances           238510      238500     -10
ours-only   line instances            70257       70256      -1
MULTISET DISTANCE                    308767      308756     -11
```

All six predictions land. Per-shape multiset of the two OURS dumps, ADDED and
REMOVED separately — **one object, nothing else in a 4.65-million-line dump**:

```
ADDED    1  [      \_constant: , line:290:28, endln:290:42]
ADDED    1  [        |vpiParent:]                     (the param_assign back-ref)
ADDED    1  [        \_param_assign: , line:9:27, endln:9:67]
ADDED    1  [        |vpiDecompile:32'h00008000]
ADDED    1  [        |vpiSize:32]
ADDED    1  [        |HEX:00008000]
ADDED    1  [        |vpiTypespec:]
ADDED    1  [        \_ref_typespec: (work@top_earlgrey)]
ADDED    1  [          |vpiParent:]
ADDED    1  [          \_constant: , line:290:28, endln:290:42]
ADDED    1  [          |vpiFullName:work@top_earlgrey]
ADDED    1  [          |vpiActual:]
ADDED    1  [          \_logic_typespec: , line:9:14, endln:9:26]
ADDED    1  [        |vpiConstType:5]
REMOVED  1  [      \_ref_obj: (work@top_earlgrey.u_rv_core_ibex.boot_addr_i.ADDR_SPACE_ROM), line:290:28, endln:290:42]
REMOVED  1  [        |vpiName:ADDR_SPACE_ROM]
REMOVED  1  [        |vpiFullName:work@top_earlgrey.u_rv_core_ibex.boot_addr_i.ADDR_SPACE_ROM]
REMOVED  1  [        \_port: (boot_addr_i), line:290:5, endln:290:43]
```

**One line of that block is NOT golden's**, and it is stated here rather than
left to be found: golden prints the package `param_assign` as
`9:27, endln:9:66`, we print `9:27, endln:9:67`. That is a **PRE-EXISTING**
end-column defect of our package `param_assign` span, not a product of this
pass — the pristine dump already carries 13 occurrences of `9:27-9:67` where
golden carries 15 of `9:27-9:66`. `tl_main_pkg.sv:9` is 67 characters long, so
our end is the exclusive column and golden's is the last character's. It is
ranked R4 and it does not reach `uhdm-cmp`, which does not follow
`vpiParent` back-references (the head advances past this very object).

---

## 2. THE GRID, CELL FOR CELL

`a1_earl43.sv` is 16 cells across five axes (what the actual IS, the FORMAL's
type, instance DEPTH, named vs positional, and the brief's override framing);
`v43_overfire.sv` is the 9-cell over-fire/under-fire probe. Both key each row on
the port's **instance** (its `vpiParent` `ref_module` / `module_inst`) so a row
survives span drift, and both print `GOLDEN_ONLY` / `OURS_ONLY` rather than
dropping a row either side lacks. **LHS is ALWAYS golden.**

### `a1_earl43.sv` — `allModules`, the DEF listing, where the whole question lives

| cell | the actual | formal | golden | pristine | patched |
|---|---|---|---|---|---|
| `u_c1` | imported pkg localparam `logic [31:0]` — **the head's shape** | `logic[31:0]` | const + ts + `param_assign` | `ref_obj` ❌ | const + ts + parent ✔ |
| `u_deep` | the same, **one instance level down** (`mid43`) | `logic[31:0]` | const + ts(`work@mid43`) + parent | `ref_obj` ❌ | ✔ |
| `u_c11` | imported pkg localparam of a **typedef'd** type | `word43_t` | const + ts + parent | `ref_obj` ❌ | ✔ |
| `u_c5` | imported pkg localparam `int` | `logic[31:0]` | const `7` + ts + parent | const, **no ts/parent** ❌ | ✔ |
| `u_c6` | imported pkg **untyped** localparam | `logic[31:0]` | const `5` + ts + parent | const, no ts/parent ❌ | ✔ |
| `u_c10` | imported pkg **`parameter`** `logic[15:0]` | `logic[31:0]` | const `16'h00ff` + ts + parent | const, no ts/parent ❌ | ✔ |
| `u_c15` | imported pkg localparam, **implicit 1-bit formal** | implicit | const `32'h00008000` (size 32!) + ts + parent | const, no ts/parent ❌ | ✔ |
| `u_c3` | the module's **OWN localparam** | `logic[31:0]` | **`ref_obj`** | `ref_obj` ✔ | `ref_obj` ✔ |
| `u_c4` | the module's **OWN parameter** | `logic[31:0]` | **`ref_obj`** | ✔ | ✔ |
| `u_c12` | the module's **OWN untyped localparam** | `logic[31:0]` | **`ref_obj`** | ✔ | ✔ |
| `u_c7` | **expression** of imported pkg params | `logic[31:0]` | `operation` op24 | ✔ | ✔ |
| `u_c8` | **literal** control | `logic[31:0]` | bare const | ✔ | ✔ |
| `u_c9` | **net** control | `logic[31:0]` | `ref_obj` | ✔ | ✔ |
| `u_c2` | **SCOPED** `p43::PK_LOGIC32` | `logic[31:0]` | **bare const, NO ts, NO parent** | `ref_obj` ❌ | `ref_obj` ❌ **residue R1** |
| `u_c13` | **POSITIONAL** conn | — | *no def-view port on EITHER side* | — | — |
| `u_c16` | the brief's **OVERRIDE** framing | — | *not a port conn; folds on both sides already* | — | — |

`a1_earl43` whole-grid: **ROWS 61, non-MATCH 12 → 5**, and the arm's own
`cmp.log` head goes **46 → 28 lines**.

**The arm reproduces the Earlgrey head SHAPE-FOR-SHAPE in a 95-line file**, and
that is why it exists — the pristine arm's `cmp.log` is 46 lines, the same
length as Earlgrey's, and every field lines up:

```
Earlgrey  LHS constant 290:28-290:42  parent param_assign 9:27-9:66
                                      ref_typespec (work@top_earlgrey) -> logic_typespec 9:14-9:26
          RHS ref_obj  290:28-290:42  work@top_earlgrey.u_rv_core_ibex.boot_addr_i.ADDR_SPACE_ROM
a1 u_deep LHS constant  49:24-49:34   parent param_assign 22:27-22:52
                                      ref_typespec (work@mid43)        -> logic_typespec 22:14-22:26
          RHS ref_obj   49:24-49:34   work@mid43.u_deep.p_i.PK_LOGIC32
```

The arm cell is `mid43`'s child, i.e. the DEPTH cell — which is also the datum
that killed the brief's instance-depth hypothesis (§ 6 R-2): the `ref_typespec`
names `work@mid43`, the module the connection is WRITTEN in, not the top.

### `v43_overfire.sv` — the per-PARAMETER over-fire / under-fire probe

One module, one wildcard import, an own localparam that is the package one's
exact twin:

| cell | what it is | golden | pristine | patched |
|---|---|---|---|---|
| `u_e0` `Q_PLAIN` | pkg `logic[31:0]` | const + ts + parent | `ref_obj` ❌ | ✔ |
| `u_e1` `E1_OWN` | **module's OWN, identical type AND value** | **`ref_obj`** | `ref_obj` ✔ | **`ref_obj` ✔** |
| `u_e7` `E7_OWN_FROM_PKG` | own localparam whose VALUE is the pkg param | **`ref_obj`** | ✔ | **`ref_obj` ✔** |
| `u_e4` `Q_STR` | pkg **string** | const `"zz"` + ts + parent | `ref_obj` ❌ | ✔ |
| `u_e5` `Q_REAL` | pkg **real** | const `1.5` + ts + parent | `ref_obj` ❌ | ✔ |
| `u_e2` `Q_STRUCT` | pkg **packed struct** | **`ref_obj`** | ✔ | **`ref_obj` ✔** |
| `u_e3` `Q_ARR` | pkg **unpacked array** | **`ref_obj`** | ✔ | **`ref_obj` ✔** |
| `u_e6` `Q_ENUM` | pkg **enum-typed** | const `1` + ts + parent | `ref_obj` ❌ | `ref_obj` ❌ **residue R2** |
| `u_e8` | **SCOPED** `q43::Q_PLAIN` | bare const | `ref_obj` ❌ | `ref_obj` ❌ **residue R1** |

`v43_overfire` whole-grid: **ROWS 18, non-MATCH 6 → 3** (R1, R2 and one
pre-existing elab unpacked-array conn).

**`u_e1` and `u_e7` are the positive controls this pass exists to survive.**
Had the gate been read as "this scope imports something", both would have
started folding and the pass would have OVER-fired invisibly: `E1_OWN` is
`localparam logic [31:0] = 32'h00008000` — byte-for-byte the type and value of
the package parameter beside it. Ownership is the only property that separates
them, and `pkgParamConst` is keyed on the symbol, so an import-materialized
reference and a module-own declaration cannot be confused.

`u_e2` / `u_e3` are the other half: the **aggregate** package parameters. They
are excluded not by a type test but because their def `Rhs` is an OPERATION and
so never enters `pkgParamConst` at all — the gate the code already had turns out
to be exactly the gate golden uses.

---

## 3. THE HEAD

Pristine, byte-identical to the committed witness
`tools/probe/r10earl42repro/r6_nexthead42.cmp` (asserted by `diff` BEFORE any
code was written, 46 lines):

```
LHS: constant 290:28-290:42  32'h00008000, parent param_assign 9:27-9:66,
     ref_typespec (work@top_earlgrey) -> logic_typespec 9:14-9:26
RHS: ref_obj  290:28-290:42  work@top_earlgrey.u_rv_core_ibex.boot_addr_i.ADDR_SPACE_ROM
```

Patched, the row ADVANCES to a NEW head of **30 lines**, committed here as
`r6_nexthead43.cmp`:

```
LHS: ref_obj (pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT) 628:26-628:38
     |vpiName:pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT
     |vpiActual: parameter (pinmux_pkg::LC_PINMUX_STRAP_REQ_DEFAULT) 26:28-26:55
RHS: ref_obj (work@top_earlgrey.u_pinmux.lc_pinmux_strap_i.LC_PINMUX_STRAP_REQ_DEFAULT)
     628:26-628:65   |vpiName:LC_PINMUX_STRAP_REQ_DEFAULT   |vpiFullName:...
```

It is the SCOPED written form of the very same family, and it is a **third**
cell again: a scoped reference to a package parameter of an AGGREGATE type,
where golden keeps a `ref_obj` but names it with the QUALIFIED name, carries NO
`vpiFullName`, binds `vpiActual` to the parameter object, and spans only the
qualified name (`628:26-628:38`) where we span to the end of the connection
(`628:26-628:65`). Three separate defects in one cell, all decoded, all ranked
R1 — the next pass starts with them already measured.

---

## 4. THE FIVE GATES

Binary under test **`/tmp/wt_r10earl43/build/slang-uhdm` md5
`f376ff682605be375e5eb5ce46568791`**; PRISTINE `5fa6b49`, built by me in a
clean worktree, **`/tmp/wt_r10earl43pris/build/slang-uhdm` md5
`288e337ff8a9489571ea256059e53a8d`**. Both bases printed and grep-checked
(`git log --oneline -1` in each worktree = `5fa6b49`; the patched tree's
`git status` shows `M src/ModuleEmit.cpp` and nothing else tracked).

| gate | result |
|---|---|
| 1 BUILD | `~/.local/bin/cmake --build /tmp/wt_r10earl43/build -j 2`, ABSOLUTE path, waited for `Linking CXX executable slang-uhdm`, `0` lines matching `error:`; md5 asserted SEPARATELY afterwards (32 hex), and re-asserted UNCHANGED after every gate had run — `ModuleEmit.cpp` mtime `15:47:31`, binary mtime `15:48:42`, so no gate stands on a stale binary |
| 2 GOLDENS | `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| 3 u2r testflags | `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL`; dump `496 match / 183 differ / 52 blank`; `ct8rows.sh` vs committed `results/gate_uhdm2rtlil.csv`: **0 differing ROWS (0 diff row-sides)**; `diff <(sort u2r_pat.csv) <(sort u2r_pris.csv)` EMPTY |
| 4 surelog both modes | see § 4.1 |
| 5 BYTE VERIFIER | see § 4.2 |

`GOLDEN_DEFER` was left UNSET throughout. `verify_golden.py` SILENTLY DEFAULTS
`SLANG_UHDM`, so every sweep exported it and the binary each sweep ACTUALLY
invoked was read back out of `cmds.txt`, not assumed:

```
pat : /tmp/wt_r10earl43/build/slang-uhdm dut.sv --single-unit --nobuiltin -o .../slang.uhdm
pris: /tmp/wt_r10earl43pris/build/slang-uhdm dut.sv --single-unit --nobuiltin -o .../slang.uhdm
```

### 4.1 GATE 4 — surelog corpus, BOTH modes, ONE INVOCATION PER MODE

Run strictly sequentially, one `verify_golden.py` per mode per binary, so the
documented SURELOG_FAIL detail-row race under concurrent sweeps cannot fire.

```
[default]   794 tests  CMP_EQUAL 469  CMP_NOTEQUAL 11  SURELOG_FAIL 25  DEFERRED 5   -> 469/11  EXPECTED
[testflags] 794 tests  CMP_EQUAL 465  CMP_NOTEQUAL  8  SURELOG_FAIL 23  DEFERRED 5   -> 465/8   EXPECTED
```

`ct8rows.sh` against the committed `results/golden_surelog.csv` (the two modes
concatenated into one 1 588-row CSV, header taken once):

```
baseline: 1589 lines = 1588 ROWS (the header is not a row)
fresh   : 1589 lines = 1588 ROWS
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

Both histograms UNCHANGED, 0 rows moved. `diff <(sort sl_pat.csv) <(sort
sl_pris.csv)` is **empty** — the same four sweeps run with the pristine binary
produce a byte-identical CSV, so every number above is a property of the corpus,
not of the machine. The target's own rows are byte-identical to the baseline —
**its ROW does not move, its BYTES do**:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,
```

### 4.2 GATE 5 — BYTE VERIFIER, both corpora, both modes, vs PRISTINE

```
uhdm2rtlil : databases patched=1358 pristine=1358  PATH_SETS_IDENTICAL  MOVERS: 0 / 1358
             SELFCHECK=1 -> 1357 / 1358 flagged    SELFCHECK1=1 -> 1
```

```
surelog    : databases patched= 953 pristine= 953  PATH_SETS_IDENTICAL  MOVERS: 1 /  953
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  patched=d3dcad27f75b pristine=db70c71278dd
             SELFCHECK=1 ->  952 /  953 flagged    SELFCHECK1=1 -> 2
```

`SELFCHECK1 = 2 = the one corrupted file + the one mover`, and
`SELFCHECK1 = 1` on the uhdm2rtlil half where there is no mover — exactly what
that control's own message says to expect. Both controls fire on both corpora.
The uhdm2rtlil half covers **both modes** (679 × 2 = 1358 databases): the
`default` sweep was run for both binaries purely so gate 5 could see it, and its
CSVs are identical too.

**ONE REAL MOVER IN 2 311 DATABASES, and the verifier names it as the target.**

```
SIZE  Earlgrey_0_1/default  patched 49941384  pristine 49941318  -> +66
```

**The size delta is NONZERO, which by the stated rule PROVES the mover is
real** — no arbitration on the noise floor is needed for it, and the per-shape
multiset in § 1 accounts for it object-for-object: one `ref_obj` subtree (4 line
shapes) replaced by one folded `constant` subtree (14 line shapes), +9 dump
lines, +66 serialized bytes. The two md5s are the SAME two my own `earl43.sh`
runs produced from a different working directory, which is an independent
confirmation that the sweep and the probe measured the same binary.

**No FLAKE this time.** `Scoreboard`, which flaked in r10earl42 (the documented
emitter nondeterminism: `SourceLocation` compares across macro buffers flip per
run under parallel parse), is byte-identical here — a reminder that its absence
from the mover list is luck of the run and not evidence about this change.

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
mode-matched to the corpus, per that script's own contract. **Its guard was
exercised on BOTH corpora, not assumed:** re-running each with
`EXPECT_UNKNOWN=0` exits **6**, so an unaccounted unmatched pattern can never
read as green. `canaudit.sh` also re-asserts that the four SLANG-FENCED names
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched
by NO driver in this directory.

**BY NAME, fresh vs committed baseline — every one IDENTICAL:**

```
InterfaceModPort     default   CMP_EQUAL ,,differ      IDENTICAL
InterfaceModPort     testflags CMP_EQUAL ,,differ      IDENTICAL
BlackParrotComplex   default   CMP_EQUAL ,,differ      IDENTICAL
BlackParrotComplex   testflags CMP_EQUAL ,,differ      IDENTICAL
YosysOldOr           default   CMP_EQUAL ,,differ      IDENTICAL
YosysOldOr           testflags CMP_EQUAL ,,differ      IDENTICAL
SVSwitch             default   CMP_EQUAL ,,differ      IDENTICAL
SVSwitch             testflags CMP_EQUAL ,,differ      IDENTICAL
Earlgrey_0_1         default   CMP_NOTEQUAL decompile: IDENTICAL
Earlgrey_0_1         testflags SLANG_REJECT            IDENTICAL
```

All four of those rows are `CMP_EQUAL`+`differ`, so **their rows are BLIND to
byte changes**. The row check alone is therefore not the guarantee the brief
asks for, and the DATABASES were compared BY NAME, byte for byte, directly:

```
InterfaceModPort     default / testflags   BYTE-IDENTICAL
BlackParrotComplex   default / testflags   BYTE-IDENTICAL
YosysOldOr           default / testflags   BYTE-IDENTICAL
SVSwitch             default / testflags   BYTE-IDENTICAL
```

**PROTECTED genscope canaries, BY NAME, u2r testflags, fresh vs committed
baseline — all IDENTICAL** (they are inside the `0 differing ROWS` of gate 3,
and inside the `MOVERS: 0 / 1358` of gate 5):

```
gen_test9  genvar_loop_decl_2  genvar_loop_decl_3  paramod_genscope_child
genscope_cells  gen_test4  indexed_partsel_array  EnumConcat
```

**BOUNDARIES held.** The diff touches `src/ModuleEmit.cpp` and nothing else.
* `§ importedConcatNoMdimReorder42` (ParamEmit 11496) — different file; its
  grid and `v42_overfire` are untouched, and Earlgrey's `vpiReordered`
  population is still `0`, golden's number (the census in § 1 re-reads the whole
  design and finds no new operation-order cell).
* `§ caTernOperandRead1` (ParamEmit, cont-assign ternary operand reads) —
  different file; `YosysOldOr` is protected BY NAME above and its database is
  byte-identical.
* `§ psBoundPkgParamTs31` / `§ stampFoldedPkgParamTs` / `makeParamTs` own
  **parameter typespec minting**; this pass mints no parameter typespec. It
  mints one `ref_typespec` on a CONNECTION's folded constant and takes its
  actual from the parameter object those rules already built — it reads their
  output and does not decide it.
* `§ fcArgPkgParamValueFolds32` / `aggregateAbstain34` own **call-argument**
  pkg-param folds; this is a PORT CONNECTION in the DEF listing, a different
  site, and the aggregate shapes ABSTAIN here too (`u_e2`, `u_e3`).
* The naming-context memory (`pkg::pkg::` base-ref names are CONTEXT-DEPENDENT,
  never uniformly folded) is the reason the `::` written form is EXCLUDED by the
  gate rather than folded along with the bare one — see § 7 R1, where golden's
  answer for the scoped form is measured to be a THIRD shape again.
* `uvm67` R5-R9's range-bound fold families concern when Surelog binds a range
  ref to the parameter OBJECT vs its Rhs; no range bound is emitted or read here.
* Live passes `r10uvm71` (TaskFuncEmit/ModuleEmit) and `r10buvm2` (class-property
  init, ModuleEmit/StmtEmit) share `ModuleEmit.cpp` with this change. **This is
  reported, per the brief.** The edit is a self-contained block inserted inside
  `emitModuleDefPorts`'s DEF-view `ref_module` connection loop; it modifies no
  existing line and adds no member, so a textual merge conflict is possible only
  if another pass edits that same loop. ParamEmit was expected free and is
  indeed untouched — no collision to report there.

---

## 6. REFUTATIONS, STATED PLAINLY

**R-1. The head is NOT a parameter override site, and there is no callee
parameter declaration at `9:27-9:66`.** The brief's framing — "at a parameter
OVERRIDE site whose written value is an imported package parameter, golden folds
the Rhs to the parameter's VALUE" — names the wrong mechanism, the wrong file
for line 9, and the wrong object for the parent. `top_earlgrey.sv:290` is
`.boot_addr_i (ADDR_SPACE_ROM)`, a port connection; `9:27-9:66` is
`tl_main_pkg.sv`'s `localparam logic [31:0] ADDR_SPACE_ROM = 32'h 00008000;`
`param_assign` — the SOURCE of the value, not a destination. The committed
witness already contains the disproof in its RHS block (`vpiParent: port
(boot_addr_i), line:290:5, endln:290:43`), which is why the first action of this
pass was to read the witness rather than the summary of it. **And the framing is
refuted by MEASUREMENT, not only by reading**: `a1_earl43` cell `u_c16` is a
genuine `leafp43 #(.PW (PK_LOGIC32)) u_c16` override of exactly the shape the
brief describes, and its `param_assign` Rhs is ALREADY a folded constant with a
`ref_typespec` on both sides — pristine included. Had the brief's law been
implemented, it would have been implemented at a site that was never broken.

**R-2. "The `work@top_earlgrey` fullname on the `ref_typespec` is odd" — it is
the ordinary DEF-listing convention and it is not the instance path.** Every
folded cell in both probes carries the same convention: `work@top43` for
connections written in `top43`, `work@mid43` for the one written in `mid43`
(`u_deep`, the arm's twin of the Earlgrey head). It is the ENCLOSING MODULE's
def name — the `prefix` the surrounding def-listing loop already builds — and it
is unrelated to instance depth. The brief's instance-depth axis is therefore
answered NEGATIVE: depth does not enter the cell at all.

**R-3. The ELAB view was never broken, and "elaborated vs def view — census
both" was the axis that mattered.** In `topModules` we already fold every cell
in this family, byte-identically to golden, including Earlgrey's own
`work@top_earlgrey.u_rv_core_ibex` `boot_addr_i` (`constant → constant` on the
span-keyed join). The entire defect lived in the DEF listing, where
`ModuleEmit`'s `ref_module` connection loop SHORT-CIRCUITS `emitExpr` for a
`NamedValue` and mints a `ref_obj` unconditionally. Had the census been run on
`topModules` alone — the section a reader naturally reaches for — it would have
reported **zero** divergence and the head would have looked unreachable.

**R-4. "Callee param typed vs untyped" and "the FORMAL's type" do not enter the
cell.** The brief asked for that axis; the grid says the folded constant is the
PARAMETER's own value at the PARAMETER's own width in the PARAMETER's own base,
whatever the formal is. `u_c15` drives a 32-bit package localparam into an
IMPLICIT 1-bit formal and golden still prints `vpiSize:32`,
`vpiDecompile:32'h00008000`; `u_c10` drives a 16-bit one into a 32-bit formal and
golden still prints `vpiSize:16`. What the formal DOES control is whether slang
wraps the reference in an implicit conversion — which is why the fold has to be
read through `stripImplicitConv` and why reading the bare `NamedValue` alone
left four grid cells half-right (§ 0).

**R-5. `pkgParamConst` membership is not a proxy for "integral" — it is the
gate golden uses, and the aggregate cells prove it.** A tempting alternative
gate is "the parameter's type is integral". It is wrong in both directions:
`Q_STR` (string) and `Q_REAL` (real) are NOT integral and golden FOLDS them,
while `Q_STRUCT` (packed struct — integral!) golden leaves symbolic. The
property that separates all four is whether the parameter's own def-view `Rhs`
is a `constant` rather than an `operation`, which is precisely the condition
under which `ParamEmit` registers it in `pkgParamConst`. The gate was not chosen
for convenience; it was the only predicate the probe's eight shapes agreed with.

---

## 7. RANKED RESIDUES

**R1 — the NEW Earlgrey head (30 lines), `top_earlgrey.sv:628:26`, and the same
cell in BOTH probes (`a1_earl43` `u_c2`, `v43_overfire` `u_e8`).** The SCOPED
written form `pkg::P`. Golden's answer depends on the parameter's shape and we
are wrong for both:
* scalar pkg param written scoped → golden folds to a **BARE** constant, no
  `vpiParent`, no typespec (`u_c2`, `u_e8`). We keep a `ref_obj`.
* aggregate pkg param written scoped → golden keeps a `ref_obj` but with
  **`vpiName` = the QUALIFIED name**, **no `vpiFullName`**, `vpiActual` bound to
  the `parameter` object, and the span of the QUALIFIED NAME ONLY
  (`628:26-628:38`); we emit the bare name, a synthesized instance-scoped
  `vpiFullName`, no actual, and a span running to the end of the connection
  (`628:26-628:65`).
This pass deliberately does not fire on `::` — firing the § 0 arm there would
stamp a parent and a typespec golden does not have, trading one wrong shape for
another. Highest value: it is the row's head, it is three defects in one cell,
and both probes already contain it.

**R2 — pkg ENUM-TYPED parameters (`v43_overfire` `u_e6`).** Golden folds
`Q_ENUM` to `constant 1`, `vpiSize:2` (the enum's base width), `INT:1`,
`vpiConstType:7`, with the `param_assign` parent and a `ref_typespec` →
`enum_typespec (q43::en43_t)`. We keep a `ref_obj`. It is out of § 0's reach by
construction: BOTH sides agree the package's own `param_assign` Rhs for
`Q_ENUM` is a `ref_obj` to the `enum_const`, so it is not in `pkgParamConst`
and the fold needs a second value source. Zero population in Earlgrey.

**R3 — the two elab-view `constant → operation` cells.** The only other
port-connection divergences in the whole design:
`work@top_earlgrey.u_alert_handler.i_ping_timer` `wait_cyc_mask_i` @87:27-87:51
and `work@top_earlgrey.u_flash_ctrl.u_to_prog_fifo` `rdata_i` @137:18-137:30.
Golden folds an operation-valued actual to a constant in the ELAB view; we keep
the operation. Present identically on both binaries. `a1_earl43` `u_c7`
(`PK_LOGIC32 + 1`) is the probe cell for this family and shows the same
`operation` vs `constant 32769`.

**R4 — our package `param_assign` end column is one too high.** Golden
`9:27-9:66`, ours `9:27-9:67`, design-wide (13 vs 15 occurrences for that one
`tl_main_pkg` parameter). Pre-existing, unrelated to this pass, and invisible to
`uhdm-cmp` (which does not follow `vpiParent`), but it costs multiset distance
and it is now visible in the head's own subtree.

**R5 — two elab-view cells the probes surface that Earlgrey does not have.**
`a1_earl43` `u_c13`: a POSITIONAL connection of a package parameter — golden
keeps a `ref_obj` (`work@top43.PK_LOGIC32`), we fold to a constant, i.e. an
elab-view OVER-fire that predates this pass. `a1_earl43` `u_c8`'s `z_o`: our
span for the token after a literal written with an internal space
(`32'h 00008000`) is one column high on both binaries.

**R6 — `golden-only line instances: 238500` still dwarfs `ours-only: 70256`.**
Earlgrey's remaining 308 756 distance is overwhelmingly *things golden has that
we do not emit*, not things we emit wrongly. Unchanged as a conclusion by this
pass; the pass moved 11 of it.

---

## 8. FILES

| file | what it is |
|---|---|
| `census43.py` | design-wide, span-keyed, section-separated census of EVERY port `vpiHighConn` actual, BOTH sides, with the constant SHAPE tally (parent kind × typespec) |
| `grid43.py` | per-connection grid keyed on the port's INSTANCE, BOTH sides, GOLDEN_ONLY/OURS_ONLY guards, prints ts + parent kind |
| `a1_earl43.sv` | the 16-cell grid: what the actual is × formal type × depth × named/positional × the brief's override framing |
| `v43_overfire.sv` | the per-PARAMETER over-fire/under-fire probe (own twin + pkg aggregate/string/real/enum shapes in ONE module) |
| `arm43.sh` | single-file arm driver (carried forward; `SLANG_UHDM` has no default, md5 printed, `sed 1d` both dumps) |
| `earl43.sh` | Earlgrey_0_1 default-mode driver against the immutable golden cache |
| `msdist.sh` | resync-immune multiset dump distance (carried forward) |
| `byteverify43.sh` | GATE 5 comparator with both mandatory negative controls |
| `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the row gate and the canary set (carried forward verbatim) |
| `r6_nexthead43.cmp` | the patched binary's Earlgrey `cmp.log` verbatim (30 lines), the witness for the NEXT pass |

`README.verifier.md` is the VERIFIER's to author. It is deliberately not
written here.

---

## 9. THE NEW HEAD, COMMITTED AS A WITNESS

`r6_nexthead43.cmp` is the patched binary's Earlgrey `cmp.log` verbatim (30
lines), so the NEXT pass can assert byte-identity against it exactly as this
pass asserted byte-identity against `r10earl42repro/r6_nexthead42.cmp` (46
lines) before starting. That assertion is not a formality: it is the only proof
that the pass is standing on the base the brief describes.
