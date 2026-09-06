# r10uvm168 — § `enumOriginConstTypeIsTheMemberValue168` — **AN AUTO-NUMBERED ENUM MEMBER'S VALUE IS A SIGNED ONE** — the BuildUVMPkg ×2 60-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list and `predict168.py`'s `FENCED=` input.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `39f286ef` |
| pristine binary | md5 `5bfd7087944d0a2a32585d54a9bbe1e3`, built from this pass's own worktree at a clean `39f286ef` and frozen `chmod 555` before any sweep |
| patched binary | md5 `123e8379e93105f9091763d030eda09e`, frozen `chmod 555`. The patch applied to a **FRESH `39f286ef` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on, and its 23/23 goldens were re-run from that worktree too |
| production surface | `src/ParamEmit.cpp` (the law and its three new clauses at `enumOriginHexRecode`, plus the § tag at the single call site), `include/UhdmExporter.h` (the law summary on the declaration, no code) |
| probe surface | `tools/probe/r10uvm168repro/` only |

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **BuildUVMPkg default and testflags, 60 cmp lines, ONE head each, the two logs BYTE-IDENTICAL** → **106 cmp lines, ONE head, a DIFFERENT OBJECT** (§9). A cmp line count is the HEAD OBJECT'S decompile size (RESUME.md §7). |
| corpus rows changed | **0** — both corpora, both modes. Status histograms IDENTICAL to this pass's own pristine sweep, cell for cell; `ct8rows` PASS against the committed baselines AND against this pass's own pristine sweep, status AND dump column. |
| byte movers | **3 / 956** surelog — **two PREDICTED BY NAME before the patched sweep ran** (`predict168.py` on the NEUTRAL binary: the only `arm=AUTO` firings in the whole corpus are BuildUVMPkg/default and BuildUVMPkg/testflags) — and the third is the known Scoreboard/default COIN, whose order-blind sorted-dump diff is **0 lines**. **0 / 1358** uhdm2rtlil, also predicted (its only firings are the pre-existing `arm=BIN` ones, unchanged by the law). |
| the corpus cell | ONE. The BuildUVMPkg database's path-normalised dump diff is **exactly two lines changed**: `|UINT:3` → `|INT:3` and `|vpiConstType:9` → `|vpiConstType:7`, on ONE constant out of 1 077 632 dump lines. |
| the corpus census | param_assign const-type disagreements **2 → 0** over 38 378 comparable cells (surelog) and **0 → 0** over 67 122 (uhdm2rtlil); `other-diff` 30 → 30, `only-golden` 5836 → 5836, `only-ours` 6089 → 6089 — nothing created, destroyed or re-listed. The whole-design constant identity census moves **+2 agreeing / −2 one-sided on each side**, and by exactly 2. |
| the grid (4 arms, both views) | 825 cells. On the field the law owns (`vpiConstType`): **124 TOWARD, 0 AWAY, 0 MOVED-WRONG**. On the fields it must not move (`vpiSize`, `vpiDecompile`): **14 TOWARD** (the octal arm's decompile, which golden really does re-render), **0 AWAY, 0 MOVED-WRONG**. Arm D's 252 negative-control cells: **nothing moved at all**. |
| the FLOOR (r10uvm159 + r10earl104's 20 committed arms) | **TOWARD 0, AWAY 0, MOVED-WRONG 0** in every projection. |
| the WIDE boundary (4721 arms, both views) | **MOVED_ARMS 14, RC_DIFFS 0**, `PROCESSED == LISTED == 4721`, 4564 databases produced. Three are this pass's own arms (the positive control); nine more are other passes' arms carrying **22 cells, ALL TOWARD, 0 AWAY, 0 MOVED-WRONG**; the last two are r10uvm154's already-decoded ADDRESS-DERIVED layout residue, proven binary-image-driven by the `R10E168_OFF=1` control (§8). |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this worktree's own pristine sweep reproduced the brief
exactly — **BuildUVMPkg default and testflags, 60 cmp lines, 1 head each,
`head_pris_BuildUVMPkg.{default,testflags}.cmp` byte-identical to each other**
(md5 `5315640cf76c3304a75dece1884b10c6`):

```
LHS: constant: , id:2991, line:8504:47, endln:8504:67
     |vpiDecompile:3  |INT:3   |vpiTypespec -> ref_typespec(uvm_pkg)
                                 -> enum_typespec(uvm_pkg::uvm_core_state) @8490
     |vpiConstType:7
RHS: constant: , id:2939, line:8504:47, endln:8504:67
     |vpiDecompile:3  |UINT:3  |vpiTypespec -> ref_typespec(uvm_pkg)
                                 -> enum_typespec(uvm_pkg::uvm_core_state) @8490
     |vpiConstType:9
```

`uvm_pkg.sv:8490-8504` (the 1800.2-2017-1.0 `pp_output` tree):

```systemverilog
8490: typedef enum { UVM_CORE_UNINITIALIZED, UVM_CORE_PRE_INIT,
8492:                UVM_CORE_INITIALIZING, UVM_CORE_INITIALIZED, … } uvm_core_state;
8504: parameter uvm_core_state UVM_CORE_POST_INIT = UVM_CORE_INITIALIZED;
```

## 2. DECODING THE JUDGE FIRST — `ct168own`

`ct168own.cpp` links the SAME generated `Compare` the judge does, walks the
owner chain from both sides, prints the four fields `constant::Compare` +
`expr::Compare` read, and then ABLATES: it sets OUR const type to golden's IN
MEMORY and re-runs the WHOLE `design::Compare`.

```
design::Compare r=-2
HEAD LHS(golden) = constant()@8504:47-8504:67#2991
HEAD RHS(ours)   = constant()@8504:47-8504:67#2939
  golden owner chain:  < param_assign()@8504:26-8504:67#2974
                       < package(uvm_pkg)@7351:1-83263:11#1
                       < design(unnamed)#191741
  ours   owner chain:  < param_assign()@8504:26-8504:67#2938
                       < package(uvm_pkg)@7351:1-83263:11#2744
                       < design(unnamed)#1
THE FOUR FIELDS constant::Compare + expr::Compare READ:
  golden constType=7 size=0 decompile=3 value=INT:3   ts -> enum_typespec(uvm_pkg::uvm_core_state)#2958
  ours   constType=9 size=0 decompile=3 value=UINT:3  ts -> enum_typespec(uvm_pkg::uvm_core_state)#3105
  agree: decompile=1 size=1 constType=0
ABLATION (ours constType 9 -> 7, in memory only):
  design::Compare r=3369
  NEXT LHS(golden) = unsupported_typespec(uvm_severity)@9584:15-9584:27#480
  NEXT RHS(ours)   = enum_typespec(uvm_pkg::uvm_severity)@8049:1-8055:16#304
  VERDICT: THE CONST TYPE WAS THE WHOLE HEAD (the judge moved on)
```

So r10uvm165's R0 framing is re-proven on this pass's own build:
`constant::Compare` (`~/git-repos/UHDM/build/generated/src/constant.cpp:58-71`)
tests exactly ONE field of its own, `VpiConstType`; its `basetype_t::Compare`
is `expr::Compare`, which tests `VpiDecompile`, `VpiSize` and `Typespec` —
all three already agreeing here. `VpiValue` is NOT read by either.

The owner is the **`topPackages`** listing (`VpiTop` package), not the
`allPackages` one: §3's grid shows golden keeps a `ref_obj` in the definition
listing, and we already match it there.

## 3. DECODING SURELOG — THE CONST-TYPE MATRIX, FROM THE SOURCE AND FROM A GOLDEN

Three files decide the const type of a folded enum-constant reference:

1. **`CompileHelper::compileTypeDef`'s enum arm**
   (`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:809-871`) gives
   every member a `Value`:
   * a member with a WRITTEN value takes
     `m_exprBuilder.fromVpiValue(c->VpiValue(), c->VpiSize())`;
   * a member with NO written value takes
     `value = m_exprBuilder.getValueFactory().newLValue();`
     `value->set(val, Value::Type::Integer, baseSize);` —
     **`Type::Integer`**, the auto-numbering counter, at the enum base's width.
2. **`ExprBuilder::fromVpiValue`** (`src/Expression/ExprBuilder.cpp`) re-types
   the written form: `"INT:"`/`"DEC:"` → `Type::Integer`, `"UINT:"` →
   `Type::Unsigned`, `"OCT:"` → `Type::Unsigned` **with the digits PARSED**
   (so an octal member reads back as a plain decimal), `"BIN:"` → an `StValue`
   `Binary`, `"HEX:"` → an `StValue` `Hexadecimal`. Surelog's own literal arm
   (`CompileExpression.cpp:543-563`) is what produces those prefixes: a BASED
   DECIMAL (`4'd2`) is `"DEC:"`, an UNSIZED decimal (`5`) is `"UINT:"`, a
   negative one `"INT:"`.
3. **`LValue::vpiValType()` / `SValue::vpiValType()`**
   (`src/Expression/Value.cpp:952` / `:326`) maps the type to the const type
   the REFERENCE SITE stamps — `CompileExpression.cpp:915/979/1067/1086`,
   `c->VpiConstType(sval->vpiValType())`, reached through
   `component->getValue(name)`:
   `Integer → vpiIntConst (7)`, `Unsigned → vpiUIntConst (9)`,
   `Binary → vpiBinaryConst (3)`, `Hexadecimal → vpiHexConst (5)`.

`g168_a_kinds.sv` is that matrix written down and handed to Surelog — 31
package parameters, one per member form × enum base type, read at the
`topPackages` listing (golden column; the pristine column is ours):

| member as written | enum base | golden | pristine |
|---|---|---|---|
| (nothing — auto) | none / `int` / `int unsigned` / `byte` / `shortint` / `longint` / `integer` / `logic[3:0]` / `bit[3:0]` / `logic signed[3:0]` | **INT / ct 7** | UINT / ct 9 |
| `= 4'd2` based decimal | `bit[3:0]` | **INT:2 / ct 7** | UINT:2 / ct 9 |
| `= 5` unsized decimal | none | UINT / ct 9 | UINT / ct 9 |
| `= -4` negative | none | INT:-4 / ct 7 | INT:-4 / ct 7 |
| `= 4'b0101` | `logic[3:0]` | BIN:0101 / ct 3 | BIN:0101 / ct 3 |
| `= 8'h1f`, `= 'h20` | `logic[7:0]` | HEX / ct 5 | HEX / ct 5 |
| `= 6'o17` octal | `logic[5:0]` | **UINT:15 / ct 9, decompile `15`** | OCT:17 / ct 4, decompile `6'o17` |
| `= 4'bx1x0` | `logic[3:0]` | BIN:x1x0 / ct 3 | (we keep a `ref_obj` — residue R-xzenum) |
| `= KELP_BASE + 4` expression | none | UINT / ct 9 | UINT / ct 9 |
| the member AFTER any of the above | — | **INT / ct 7** (the counter resumes at `Type::Integer`) | UINT / ct 9 |

Two golden readings that look like bugs and are not ours to fix — they are
`CompileHelper::adjustSize`'s UINT arm masking the value to the TARGET width,
and for an enum with NO written base that width is **0**:
`RUST_SEED = 5` reads back `UINT:0` and `KELP_STEP = KELP_BASE + 4` reads back
`UINT:0`. Their CONST TYPE is 9 on both sides, so they are outside this law
(residue R-uintmask, §10).

`g168_b_form.sv` (arm B) answers the rest of the brief's matrix, and the
answer is uniform: the member's encoding wins **whatever the parameter is**.
`int`, `integer`, `logic [7:0]`, `bit [7:0]`, `byte`, the enum typedef and an
UNTYPED parameter all take ct 7; `parameter` and `localparam` are the same;
ONE or TWO parameter hops keep it; a parenthesised reference keeps it; an
`int'(…)` or `8'(…)` CAST breaks it (golden ct 9, and we already matched);
`* 2`, `- 1`, `/ 3` are the ordinary `ExprEval` sign rules and are unchanged.

`g168_c_home.sv` (arm C) covers the homes: the package's own listing, a package
that imports another, an interface, a module, a generate scope (flat and
nested), a class, a child instance's parameter ACTUAL, and `$unit`.

## 4. DECODING SLANG — THE SITE

`grep -rn 'VpiConstType' src include` finds ~90 stamps; the one that decides
this head is `src/ParamEmit.cpp`, at the end of the parameter loop:

```cpp
if (topView && (inPackage || isImported) && typedParam &&
    rhs->UhdmType() == UHDM::uhdmconstant)
    if (!enumOriginHexRecode((UHDM::constant*)rhs, init))
        paramOriginBaseRecode((UHDM::constant*)rhs, init);
```

`enumOriginHexRecode` already walked the init chain (through parameter
references) to an enum member and re-encoded the constant in the member's
SOURCE BASE — but only for `'h`, `'b` and `'o`, and it returned false for a
member with no written value at all. That is the half of Surelog's rule that
had been decoded (r10impb's `ImportBinding`, the rp32/ibex HEX rows); the
`Value::Type::Integer` half had not.

`paramOriginBaseRecode` cannot take a cell from it and never could: its own
walk `break`s the moment the chain reaches something that is not a
`ParameterSymbol`, so an enum-member chain returns false there.

## 5. THE LAW

> **§ `enumOriginConstTypeIsTheMemberValue168`** — *a folded parameter constant
> whose init chain (through parameter references) lands on an ENUM CONSTANT
> takes that MEMBER'S OWN `Value` ENCODING, and an AUTO-NUMBERED member's is a
> **SIGNED** one.* Concretely, the const type is `fromVpiValue`'s of the
> member's compiled constant:
> * no written value → `INT:` / `vpiIntConst`
> * `N'd…` based decimal → `INT:` / `vpiIntConst`
> * `N'o…` octal → `UINT:` / `vpiUIntConst`, digits and decompile in DECIMAL
> * `N'b…` → `BIN:` / `vpiBinaryConst`; `N'h…` / `'h…` → `HEX:` / `vpiHexConst`
>   (both pre-existing, unchanged)
> * an unsized decimal, a negative, or an arithmetic member → unchanged.

DIRECTION: **RE-ENCODE** — no object is created, destroyed or reparented. The
OBJ / VAR / TYP census families move 0 lines; the whole-design CONSTANT census
moves exactly the 2 cells named above and nothing else.

Each of the three new clauses is a measured cell that fails without it
(`R10E168_OFF=1` restores the pre-pass path for exactly those three, and is the
NEUTRAL binary every arm scores against):

* **auto-numbered** — `g168_a_kinds.sv` a01/a02/a03 (`ka_first`/`ka_mid`/
  `ka_last`), the corpus shape, and 17 more across every enum base type.
* **based-decimal** — a20/a21 (`ka_bdec` = `COIL_TWO = 4'd2`, and the auto
  member after it).
* **octal** — a26 (`ka_oct` = `PERN_ODD = 6'o17`): golden `UINT:15` decompile
  `15`, ours was `OCT:17` decompile `6'o17`. This is the one arm where the law
  moves `VpiDecompile`, and it moves it TOWARD golden in all 14 cells.

The clauses that are DELIBERATELY NARROW, each with its negative control:
* the two NEW arms require the member's initializer to BE one written integer
  literal (`litInit168`), because Surelog's `fromVpiValue` reads the compiled
  constant; an ARITHMETIC member (`KELP_STEP = KELP_BASE + 4`, cell a30) stays
  unsigned on both sides. The pre-existing hex/binary arms keep their old,
  wider reach, so this pass cannot take a cell away from them.
* the `INT:` re-prefix declines when the constant's payload is not a plain
  decimal (`BIN:`/`HEX:`/`OCT:`/`REAL:`/`STRING:` came from a different `Value`
  arm) — and declining leaves the caller's own `paramOriginBaseRecode`
  fallback running exactly as before.

## 6. THE GRID — 4 ARMS, BOTH VIEWS, ONE SURELOG GOLDEN EACH

`grid168.sh` builds one Surelog golden and both frozen binaries' databases in
both views, dumps all six, and `cen168.py` censuses every `param_assign` whose
Rhs is a constant, keyed on (design-level listing, Lhs fullname, span) — the
`allPackages`/`topPackages` split is part of the key, because the two listings
hold the SAME parameter at the SAME span and a census that merges them reports
one of the two and calls it the answer.

`score168.sh` scores THREE projections; the tallies are

| arm | cells | full | ct | rest |
|---|---|---|---|---|
| `g168_a_kinds.sv` (member forms × enum base) | 124 | 42 T / 0 A / 0 MW | **42 T / 0 A / 0 MW** | 2 T / 0 A / 0 MW |
| `g168_b_form.sv` (parameter forms, hops, casts, homes) | 296 | 34 T / 0 A / 6 MW | **40 T / 0 A / 0 MW** | 0 T / 0 A / 0 MW |
| `g168_c_home.sv` (package/import/iface/module/genscope/class/$unit) | 153 | 38 T / 0 A / 4 MW | **42 T / 0 A / 0 MW** | 12 T / 0 A / 0 MW |
| `g168_d_notmove.sv` (negative controls) | 252 | 0 / 0 / 0 | **0 / 0 / 0** | 0 / 0 / 0 |

The ten `full`-column MOVED-WRONG cells are all the same shape and NONE of them
is a regression: they are materialized-import copies in a module's DEFINITION
listing where golden's `vpiSize` is 0 and ours is 32 **before and after**
(`A[ct=9 UINT:3 size=32 dec=3] B[ct=7 INT:3 size=32 dec=3]`, golden
`ct=7 INT:3 size=NONE`). The const type moved TOWARD golden; the size residue
is pre-existing, untouched, and is r10earl104's family, not this one. That is
exactly what the `ct` and `rest` columns are for.

## 7. THE FLOOR — r10uvm159's AND r10earl104's COMMITTED ARMS

`floor168.sh` re-scores this pass's arms AND the 20 committed arms of the two
passes that own the neighbouring populations (r10uvm159's folded-constant
TYPESPEC law, r10earl104's minted `int_typespec` family). **Every one of the
20 scores TOWARD 0 / AWAY 0 / MOVED-WRONG 0** in the `full` projection:

```
r10uvm159repro/g159_a_owners.sv   cells=16   same=0   ONLY-GOLDEN=16
r10uvm159repro/g159_b_origins.sv  cells=0
r10uvm159repro/g159_c_homes.sv    cells=31   same=0   ONLY-GOLDEN=31
r10uvm159repro/g159_d_min.sv      cells=60   same=56  ONLY-GOLDEN=4
r10earl104repro/g1_form104.sv     cells=72   same=72
r10earl104repro/g2_type104.sv     cells=44   same=44
r10earl104repro/g3_home104.sv     cells=42   same=39  ONLY-GOLDEN=1 ONLY-OURS=2
r10earl104repro/g4_cons104.sv     cells=130  same=130
r10earl104repro/g5_gscope104.sv   cells=166  same=166
r10earl104repro/g6_mix104.sv      cells=28   same=28
r10earl104repro/g7_pos104.sv      cells=100  same=100
r10earl104repro/va1_read104.sv    cells=146  same=146
r10earl104repro/va2_home104.sv    cells=68   same=68
r10earl104repro/va3_more104.sv    cells=55   same=52  ONLY-GOLDEN=3
r10earl104repro/va4_bare104.sv    cells=23   same=20  ONLY-GOLDEN=3
r10earl104repro/va5_edge104.sv    cells=16   same=16
r10earl104repro/vb1_netrange.sv   cells=4    same=4
r10earl104repro/vb2_genfor.sv     cells=4    same=4
r10earl104repro/vb3_tdefrange.sv  cells=4    same=4
r10earl104repro/vb4_instarr.sv    cells=10   same=10
```

The ONLY-GOLDEN / ONLY-OURS counts are pre-existing one-sided sets, IDENTICAL
under both binaries (they are counted as absent on both sides, which is why
they score `same`); they are named as residues in those passes' own READMEs.

## 8. THE WIDE BOUNDARY

`bound168.sh` compiles EVERY `.sv`/`.v` under a COPY of `tools/probe`, at any
depth, in BOTH views, with both frozen binaries, and reports every arm whose
rc or whose DATABASE BYTES moved. The file list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path, and `PROCESSED` is
asserted against `LISTED`. This pass's own `g168_*.sv` are the POSITIVE
CONTROL: a gate that reports zero over them cannot see.

```
LISTED=4721  PROCESSED=4721  PRODUCED_DBS=4564  MOVED_ARMS=14  RC_DIFFS=0
```

`attrib168.sh` re-builds EVERY moved arm against its OWN Surelog golden and
scores it in all three projections, so no arm is "attributed" on the strength
of a byte compare (`ATTRIB.r10uvm168.txt`):

| arm | ct-column verdict |
|---|---|
| `r10uvm168repro/g168_a_kinds.sv` / `_b_form.sv` / `_c_home.sv` | this pass's own arms — the POSITIVE CONTROL: 42 / 40 / 42 TOWARD, 0 AWAY, 0 MOVED-WRONG |
| `r10buvm18repro/grid18.sv` | 2 TOWARD (`gp::P_E`) |
| `r10earl30repro/g2_origin.sv` | 2 TOWARD (`p2::PE`) |
| `r10earl33repro/b2_init.sv` | 2 TOWARD (`q33::N13`) |
| `r10earl43repro/v43_overfire.sv` | 2 TOWARD (`q43::Q_ENUM`) |
| `r10earl44repro/a1_earl44.sv` | 2 TOWARD (`p44::PK_ENUM`) |
| `r10earl44repro/v44_overfire.sv` | 2 TOWARD (`q44::Q_ENUM`) |
| `r10earl60repro/vfa_v60.sv` | 6 TOWARD (`tp::EV` + its two module copies) |
| `r10v138repro/v3_faces.sv` | 2 TOWARD (`v3p::LP`) |
| `r10vearl71repro/v2_origins71.sv` | 2 TOWARD (`pa_v71::APE`) |
| `r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv` | **NOT this law** — see below |

**22 cells on nine other passes' arms, every one TOWARD, 0 AWAY, 0
MOVED-WRONG** in all three projections.

The two arms with NO `param_assign` cell at all are **r10uvm154's own LAYOUT
PROOF family** (that pass's README §7 / `layoutproof154.sh`): a class-scoped
`typedef <T> name[string]` mints an ADDRESS-DERIVED range bound, so any two
binaries disagree on it. Measured here: pristine `22548185` (`0x1580ed9`),
patched `22556409` (`0x1582ef9`), against an 8992-byte binary growth. The
decisive control is that **the PATCHED binary run with `R10E168_OFF=1` — the
law switched off, behaviour identical to pristine — ALSO prints 22556409**, so
the move is the binary IMAGE and not the law. Both constants sit BELOW
`\_weaklyReferenced:` (g22 line 4356 < 5118; l154 line 645 < 678), where
RESUME.md §9 says the judge cannot reach, and `uhdm-cmp` reads 3438 lines /
1 head on `g22.sv` under BOTH binaries in BOTH views.

## 9. R0 — THE NEXT HEAD ON THIS ROW

BuildUVMPkg default and testflags, **106 cmp lines, ONE head each, the two logs
BYTE-IDENTICAL** (`head_pat_BuildUVMPkg.default.cmp`, md5
`bc812ae88196732fccc89625149c9abc`). The head is a NEW OBJECT — the one
`ct168own`'s ablation named before the patch was written:

```
LHS: unsupported_typespec: (uvm_severity), id:480, line:9584:15, endln:9584:27
     |vpiName:uvm_severity
     |vpiInstance: package uvm_pkg
RHS: enum_typespec: (uvm_pkg::uvm_severity), id:304, line:8049:1, endln:8055:16
     |vpiName:uvm_pkg::uvm_severity  |vpiBaseTypespec -> bit_typespec @8049:14
     |vpiEnumConst: UVM_INFO/UVM_WARNING/UVM_ERROR/UVM_FATAL …
```

`uvm_pkg.sv:8049` declares `typedef enum bit [1:0] { UVM_INFO, … } uvm_severity;`
and `uvm_pkg.sv:9584` USES the name in a context where Surelog emits an
**`unsupported_typespec`** rather than resolving it to the enum — a TYPE-LOOKUP
FAILURE golden models and we do not. The two objects sit at DIFFERENT spans
(9584:15 vs 8049:1), so the next pass's first question is which of Surelog's
`compileTypespec` bails produces `unsupported_typespec` for a name that is in
scope, and where the reference at 9584 lives.

The other rows are unmoved: SeqDriver and SimpleUVM stay at 338,
Scoreboard/default at 95, MiniAmiq at 106, Earlgrey at 31 (default) / 50
(testflags), Rggen/default CMP_EQUAL.

### RESIDUES THIS PASS DOES NOT OWN

- **R-uintmask** — golden reads an explicitly-valued member back through
  `adjustSize`'s UINT arm, which masks the value to the TARGET width; for an
  enum with NO written base that width is 0, so `RUST_SEED = 5` folds to
  `UINT:0` and `KELP_STEP = KELP_BASE + 4` to `UINT:0` while we keep 5 and 7.
  CONST TYPE 9 on both sides, so this law is silent on it. Cells a04/a06/a30
  in `g168_a_kinds.sv`, b25 in `g168_b_form.sv`. 0 corpus cells.
- **R-untypedsize** — an UNTYPED package parameter folded from an enum member
  carries `vpiSize` 64 where golden carries 32 (cells `ka_expr`-adjacent
  `kb_untyped`, `kb_lp_bare`, `kb_wbare`). The `typedParam` gate at the call
  site keeps this law off them deliberately: moving their const type without
  their size would trade one wrong field for another. 0 corpus cells.
- **R-defmodsize** — a materialized-import copy in a module's DEFINITION
  listing carries `vpiSize` 32 where golden carries 0. r10earl104's family;
  unchanged by this pass (the ten `full`-column MOVED-WRONG cells of §6).
- **R-xzenum** — a member written with x/z bits (`GORSE_X = 4'bx1x0`) folds to
  `BIN:x1x0` in golden and stays a `ref_obj` for us. An ONLY-OURS shape, not a
  const-type one. 0 corpus cells.
- **R-addrbound** — r10uvm154's already-decoded layout residue, re-confirmed
  here on `r10buvm22repro/g22.sv` as well as on its own `l154_noenum.sv`: a
  class-scoped `typedef <T> name[string]` mints an ADDRESS-DERIVED range bound
  below `\_weaklyReferenced:`, so ANY patch that changes the binary's layout
  moves those two arms' bytes. Future boundary walks should expect them and
  run the `R10E168_OFF=1`-style neutral control before attributing them.
- **R-addfold** — `HAVEN_TRIO + 1` folds to `INT:4` / ct 7 in golden and
  `UINT:4` / ct 9 for us: `ExprEval`'s `vpiAddOp` `unsignedOperation` test
  reads the OPERAND's reduced type, and an enum member's is signed. Fixing it
  means teaching `isIntEncoded` (ExprEmit) about enum members, which is a
  different site and a much wider blast radius. Cell b15; 0 corpus cells.

## 10. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct168own.cpp` | the owner-finder + JUDGE DECODER for a both-sides-present head: owner chains, the four compared fields, and the in-memory const-type ABLATION that proves the field is the whole head. |
| `ct168cen.cpp` | the const-type census over a database PAIR: every `param_assign` whose Rhs is a constant, keyed on (design listing, Lhs fullname, span), plus a depth-keyed whole-design constant identity census. `all` prints agreeing cells too, for the a-priori prediction. |
| `cen168.py` | the same census read off `uhdm-dump` instead of the database — the independent second reading (descended from r10vearl104's `pacen.py`; only the payload changed). |
| `grid168.sh` | one Surelog golden + both binaries × both views + dumps + censuses for one arm, every rc recorded. |
| `score168.sh` | the three-projection scorer (`full` / `ct` / `rest`). |
| `floor168.sh` | scores this pass's arms AND r10uvm159's + r10earl104's committed arms. |
| `cenrun168.sh` | runs `ct168cen` over every comparable row of a sweep workdir. |
| `predict168.py` | the A-PRIORI mover prediction: re-runs the corpus with the NEUTRAL (`R10E168_OFF=1`) binary and `R10E168_DBG=1`, collecting every firing BY NAME. Uses the harness's OWN discovery and argument translation and asserts a nonzero produced-database count. |
| `predict168.sh` | the `cmds.txt`-replay first cut, kept because it is the instrument that FAILED: a recorded slang command line names its sources relative to the test directory, which `cmds.txt` does not record, so the replay ran nothing and reported zero firings. It is why `predict168.py` asserts `produced > 0`. |
| `bound168.sh` / `wide168.sh` | the wide boundary gate (two forms: rc+byte, and workdir-normalised dump). |
| `attrib168.sh` | re-builds and scores every arm the boundary reported as MOVED. |
| `g168_a_kinds.sv` … `g168_d_notmove.sv` | the four grid arms (§6). |
| `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `rowheads.sh` | the standard gate battery, copied unchanged. |
