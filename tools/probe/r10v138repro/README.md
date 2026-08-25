# r10v138 — ADVERSARIAL VERIFICATION of r10uvm138 (§ `pkgRetBareEnumConstFold138`)

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's
report reproduced **bit-for-bit** from my own worktrees and my own builds.
Two adversarial arms then broke the law on legal SystemVerilog, one of them a
clean **pristine-RIGHT → patched-WRONG** cell. Both are closed by one clause
added to the same block (§ `enumNameRangeIsNeverRegistered138v`), the whole
gate battery re-run on the fixed binary, and the fixed binary produces
**byte-identical databases to the implementer's on all 956 surelog and all
1358 uhdm2rtlil databases** — the fix is corpus-invisible and costs the pass
nothing.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py` are the
authorities. slang was NOT patched; `results/*.csv` were READ ONLY; nothing was
promoted; **no corpus row converted**. LHS is ALWAYS golden (Surelog).

| | |
|---|---|
| BASE | `11643b6` |
| my pristine worktree | `/tmp/wt_v138pris` at `11643b6`, own cmake configure, `-j 2` |
| my patched worktree | `/tmp/wt_v138` = `11643b6` + `/tmp/r10uvm138.patch` |
| pristine md5 | `fa055a33c4129c1689fa5ebba677261b` — **matches the implementer's** |
| implementer's patched md5 | `c066e38a3d509b98d16dbffff2ddc860` — **matches, from an independent worktree and an independent cmake configure** |
| verified (fixed) md5 | `86eaffb70c5faac40f54e5c709ac8795` |
| production surface | `src/StmtEmit.cpp` only (the implementer's block + my clause inside it) |
| probe surface | `tools/probe/r10uvm138repro/` + `tools/probe/r10v138repro/` |

---

## 1. WHAT I REPRODUCED, INDEPENDENTLY

* `git apply --check` clean on a fresh `11643b6`, no fuzz; fence scan for the
  four slang-fenced names over the patch: 0, 0, 0, 0.
* Goldens: pristine **23/0**, implementer's patched **23/0**, fixed **23/0**;
  negative control `SLANG_UHDM=/bin/false` → **PASS=0 FAIL=23**.
* **Every `cmds.txt` audited by binary PATH**, not by name:
  `v138_wd_pris/{sl,u2r}` → `/tmp/v138_bin/pris.bin` (1573 + 1462 files),
  `v138_wd_pat/{sl,u2r}` → `pat.bin`, `v138_wd_fix/{sl,u2r}` → `fix.bin`.
  One binary path per sweep, no leakage to the main-tree binary.
* uhdm2rtlil, both modes: **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**
  on all three binaries; `ct8rows` PASS against the committed
  `results/gate_uhdm2rtlil.csv` and against my own pristine sweeps.
* surelog, `--mode both`, 1588 rows over 956 databases: `ct8rows`
  **0 differing rows** (status AND dump column) against the committed
  `results/golden_surelog.csv` and against my own pristine sweep; the status
  histogram is identical to pristine in both modes (default 471/10/5/283/25,
  testflags 466/9/5/3/1/284/23/1/2). **NO ROW CONVERTED in either direction.**
* `byteverify SELFCHECK=1`: uhdm2rtlil **0 / 1358** (selfcheck 1357/1358),
  surelog **9 / 956** (selfcheck 955/956) — and the nine are exactly the nine
  named in `PREDICT.r10uvm138.txt`. `FunctionReturnEnum`, the law's negative
  control, stayed byte-identical.
* Canaries `ok=52 changed=0` / `ok=8 changed=0`; `ctcan2` PASS both;
  `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`. Byte pins: SVSwitch
  `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
  BlackParrotComplex `e3e354129d5a`/`73a10e8217e5`, YosysOldOr `d68e0796d62c`
  — all identical to pristine.
* Heads (`rowheads.sh`, DEPTH not distance), pristine → patched:
  SimpleUVM ×2 **32 → 334**, Scoreboard/default **32 → 334**,
  BuildUVMPkg ×2 **32 → 83**; SeqDriver ×2 (17), MiniAmiq ×2 (56),
  Earlgrey ×2 (21302 / 21926) head logs **byte-identical**; Rggen/default 0.
  `UVM_FRONTDOOR` in **5** pristine head logs and **0** patched ones.
  The committed `head_pris_Earlgrey_0_1_*.cmp` are truncated to 60 lines with
  the truncation stated in the file; their first 60 lines are byte-identical to
  mine. Every other committed head log matches mine id-for-id.
* **Order-blind attribution** (sorted, id- and path-stripped dumps) of all nine
  movers: SimpleUVM/Scoreboard/BuildUVMPkg **12 diff lines each = the law's ONE
  cell**; SeqDriver/MiniAmiq **32 lines each = the law's THREE cells** (the home
  package's TOP view plus BOTH views of the `adpcm_pkg`/`svaunit_pkg`
  wildcard-import clone). Nothing else moves. **Scoreboard/default's ENTIRE
  order-blind delta is this law's one cell — the ~50/50 coin did not flip and
  hides nothing.**
* Independent TO-GOLDEN check at the law's site, straight off the golden cache
  (SeqDriver/default, `1914:11-1914:24`): golden **3 `constant` + 1 `ref_obj`**;
  pristine **4 `ref_obj`**; patched **3 `constant` + 1 `ref_obj`**, the surviving
  ref_obj being the uvm_pkg DEF-view one. Exact.
* uvm120's, uvm76's, earl66's and buvm30's committed arms as must-stay
  controls: 27 arms, **byte-identical on both binaries** except
  `r10uvm120repro/g120_d_shapes.sv`, which moves **1 TOGOLD** — uvm120's own
  residue **R6** (`p120d::f_enum`), closed by this law exactly as claimed.

The one imprecision I found in the implementer's artifacts:
`PREDICT.r10uvm138.txt` says the nine databases move "each by EXACTLY ONE
cell", while `README.md` §4 (and the measurement) says SeqDriver and MiniAmiq
move three. The README is right; the PREDICT line understates. The gate
requirement — the movers named BY NAME before the patched sweep — is met either
way.

---

## 2. THE BREAK — § `enumNameRangeIsNeverRegistered138v`

### 2.1 The shape

```systemverilog
package p;
   typedef enum { RA_A[3]   } ra_t;   // an enum NAME RANGE (IEEE 1800 §6.19.1)
   typedef enum { RB_A[2:0] } rb_t;
   typedef enum int { RC_A[2] = 5 } rc_t;
   typedef enum { QR_A[2], QR_B } qr_t;
   function ra_t g_ra(); return RA_A1; endfunction
   function qr_t f_plain(); return QR_B; endfunction
endpackage
```

### 2.2 The decoded reason golden does not fold

`compileTypeDef` walks the enum's members **as written** and does **not**
expand a name range. Measured on golden: `ra_t`'s `enum_typespec` holds
**exactly ONE `enum_const`, named `RA_A`** (`rb_t` → one `RB_A`; `rc_t` → one
`RC_A`, `UINT:5`), so the `scope->setValue(enumName, value)` beside it
registers only `RA_A` and `component->getValue("RA_A1")` **misses**. reduceExpr
therefore leaves the `ref_obj` — which is also why golden's `ref_obj` for
`RA_A1` carries **no `vpiActual`**: there is no object of that name to bind to.

slang *does* expand the range (`RA_A0`..`RA_A2`, all sharing the one
`DeclaratorSyntax`), so the fold fired.

### 2.3 What it cost, measured

| cell (arm, view) | GOLDEN | PRISTINE | IMPLEMENTER'S PATCH |
|---|---|---|---|
| `v7b::f_rng` (import clone, DEF **and** TOP) | `ref_obj nm=QR_A1 act=-` | `ref_obj nm=QR_A1 act=-` **(exact)** | `constant dc=1 sz=64 INT:1 ct=7` |
| `v7b::RC::m_rng` (import clone, DEF **and** TOP) | `ref_obj nm=QR_A0 act=-` | `ref_obj nm=QR_A0 act=-` **(exact)** | `constant dc=0 sz=64 INT:0 ct=7` |
| `v6a::g_ra` / `g_rb` / `g_rc`, `v4p::fh`, `v7a::f_rng`, `v7a::RC::m_rng`, `v7b::c_rng` | `ref_obj nm=…_A1 act=-` | `ref_obj` (right KIND and NAME, surplus `vpiActual`) | `constant` |
| `v7a::f_plain` / `v7b::f_plain` (`QR_B`, the member AFTER a range) | `constant INT:1` | `ref_obj` | `constant INT:2` — **the wrong value** |

`BaseClass::Compare` reads `UhdmType()` FIRST, so the first two rows are
**pristine byte-for-byte golden → patched wrong**: a regression, not a residue.
The rest are `ref_obj`(kind+name right) → `constant`(kind wrong), i.e. cells
moved AWAY from golden across a kind boundary.

The last row is a second, independent failure of the same shape: because
Surelog never expands `QR_A[2]`, its counter runs `QR_A=0, QR_B=1` while slang
runs `QR_A0=0, QR_A1=1, QR_B=2`. Our `enum_const` for `QR_B` therefore says 2
where golden says 1, and the fold carried that disagreement into a new place —
exactly what the block's enum_const fence exists to prevent. **That fence reads
the VALUE TAG (`INT:`/`OCT:`/literal-ness) and cannot see a wrong COUNT**, which
is why the refusal has to be per ENUM and not per member.

### 2.4 The clause

In `src/StmtEmit.cpp`, inside the same block, before the enum_const fence:

```cpp
if (fold138)
    if (auto* ety138 = sy138.as<EnumValueSymbol>()
                           .getType().getCanonicalType().getSyntax())
        for (auto md138 : ety138->as<syntax::EnumTypeSyntax>().members)
            if (md138 && !md138->dimensions.empty()) { fold138 = false; break; }
```

Positive controls that still fold: `v6a::g_rd` (same package, no range),
`v7a::f_macro` (a macro-written reference), `v7a::f_paramb` (a member following
a PARAMETER-valued one, where the two counters agree).

---

## 3. THE ADVERSARIAL GRID (7 arms × 2 views, golden × pristine × both ours)

`varm.sh` builds each arm with Surelog (a golden of its own for the ELAB view,
via a second `-elabuhdm` run) and with both frozen binaries; `vscore.py` is a
multiset join on (VIEW, SITE, SPAN) over `cen138.py` censuses, printing the
one-sided sets in BOTH directions. Every child gets `</dev/null`; every rc is
recorded (an rc=139 is a segfault `verify_golden` would have filed as
SLANG_REJECT — there were none).

| arm | what it varies | implementer's patch | **verified** |
|---|---|---|---|
| `v1_xpkg` | the enum in package P1, the returning function in P2 (wildcard import, EXPLICIT single-name import, out-of-body method) | DEF 3 TOGOLD / ELAB 6 | 3 / 6, 0 MOVED-WRONG |
| `v2_shadow` | a local, a formal and a class property SHADOWING an enumerator's name; a member whose init is an expression over another member | 2 / 4 | 2 / 4 |
| `v3_faces` | bare return, ternary arms, `e_t'(…)` and `int'(…)` casts, rhs, call argument, comparison, case item, property initializer, localparam initializer, concatenation operand — in the free-function AND the out-of-body home | 5 / 10 | 5 / 10 |
| `v4_kinds` | 20 enum declarations: no base / `int` / `int unsigned` / `bit[3:0]` / `logic[7:0]` / `byte` / `shortint` / `longint`, negative, non-contiguous + resumed, hex, based-decimal, binary, unsized decimal, octal, unsized based, expression init, **name range** | 14 / 28, **AWAY 1 / 2** | 14 / 28, **AWAY 0 / 0** |
| `v5_homes` | package free fn, out-of-body method, in-body method, class-scope enum, anonymous package enum, function-local typedef, module fn, `$unit` fn, **interface fn**, **parameterised class** out-of-body, `virtual`/`extends` | 4 / 8 | 4 / 8 |
| `v6_more` | three name-range spellings, param-width base, **typedef base**, `do` / `while` / `case` / `if` / labeled `begin` nesting, export-import chain, virtual class, 3 module instances | 10 / 17, **AWAY 4 / 7** | 10 / 17, **AWAY 1 / 1** |
| `v7_extra` | struct-typedef context, parameter-valued member init, macro-written reference, a range member reached from an out-of-body method and from an IMPORT CLONE, a plain member AFTER a range | 10 / 17, **MOVED-WRONG 4 / 2**, AWAY 6 / 11 | 10 / 15, **MOVED-WRONG 0 / 0, AWAY 0 / 0** |
| **total** | | 138 TOGOLD, **6 MOVED-WRONG**, **31 AWAY** | **136 TOGOLD, 0 MOVED-WRONG, 2 AWAY** |

The two TOGOLD the fix gives up (`v7a::f_plain` / `v7b::RC::m_rng`, ELAB only)
are **not real gains**: they are duplicate-count coincidences of the multiset
key — the ELAB tree lists those functions twice, the fold collapsed one copy,
and the count happened to land on golden's one. Both cells are inside the
name-range enum the fix refuses.

Fences re-confirmed byte-exact against golden with the fixed binary (all
`SAME-OK`): module function, `$unit` function, in-body class method,
class-scope enum typedef, anonymous package enum, an assignment rhs, a
case-item expression, a variable initializer, a formal read, a call argument, a
`return` nested in `if`/`while`/`case`/labeled `begin`.

---

## 4. GATES ON THE FIXED BINARY — all green, and byte-identical to the patch

| gate | result |
|---|---|
| build | `-j 2`, md5 `86eaffb70c5faac40f54e5c709ac8795`, md5'd separately |
| goldens | **23/0**; `/bin/false` → 0/23 |
| uhdm2rtlil both modes | 679/50/2; `ct8rows` PASS vs the committed baseline and vs my pristine sweep, both modes |
| surelog `--mode both` | 1588 rows, **0 differing rows**, histogram identical to pristine, **no row converted** |
| byte movers | surelog **9 / 956** (the same nine, PREDICTED BY NAME), uhdm2rtlil **0 / 1358**, `SELFCHECK` 955/956 and 1357/1358 |
| **fixed vs implementer's patched** | **0 / 956** and **0 / 1358** — every corpus database byte-identical |
| heads | identical to the patched run, log for log; `UVM_FRONTDOOR` in 0 |
| canaries | `ok=52 changed=0`, `ok=8 changed=0`, ctcan2 PASS ×2, canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, the three byte-identical rows — all hold |
| boundary | `LISTED=4021 PROCESSED=4021 PRODUCED_DBS=3877 MOVED_ARMS=16 RC_DIFFS=0` |

**Boundary** (`bound138.sh` over a COPY of `tools/probe` **plus my seven arms**
as an extra positive control), pristine vs FIXED. The 16 moved arms are the
implementer's 9 and my 7. Scored against each arm's own Surelog golden:

| arm | verdict |
|---|---|
| `r10uvm138repro/g138_{a_ctx,b_kinds,c_homes,d_inst}.sv` | 4 + 16 + 10 + 2 = **32 TOGOLD**, 0 MOVED-WRONG — the implementer's own numbers, unchanged by the fix |
| `r10uvm120repro/g120_d_shapes.sv` | 1 TOGOLD (uvm120 residue R6 closed) |
| `r10uvm12repro/t13/t.sv` | 4 TOGOLD |
| `r10uvm86repro/g86_a2_ctx.sv` | 1 TOGOLD |
| `r10vbuvm28repro/gv28_d_reach.sv` | 2 TOGOLD |
| `r10buvm22repro/g22.sv` | **not this law** — its only delta is the image-relative address `22482521 → 22486617` / `22481665 → 22485761`, a shift of exactly **+4096** (uvm120's documented R7); golden has no cell at those three sites at all |
| `r10v138arms/v*.sv` (mine) | the grid of §3 |
| total | **40 TOGOLD, 0 MOVED-WRONG, 0 AWAY, 0 rc diffs** on the campaign's arms |

Every rc=139 in the boundary log appears on BOTH binaries; `RC_DIFFS=0` covers
them.

---

## 5. RESIDUES I MEASURED (none blocks the landing; none is a regression)

* **R-V1 — a typedef-BASED enum's folded SIZE.** `typedef bit [3:0] nib_t;
  typedef enum nib_t { PB_A, PB_B } pb_t;` — golden's `enum_const` is
  `vpiSize:4`, **ours is `vpiSize:64`, in pristine too**: a pre-existing
  `enum_const` defect. The fold copies it, so the folded constant is
  `dc=1 sz=64 INT:1 ct=7` against golden's `sz=4`. This is the one surviving
  AWAY in my grid, and it is **toward golden, not away from it**: `expr::Compare`
  reads VpiDecompile then VpiSize, so the patched cell matches on kind and
  decompile and fails on size where pristine failed on kind. The implementer's
  enum_const fence reads the VALUE TAG and cannot see a wrong SIZE. Fixing
  `enum_const`'s width for a typedef base would hand this to the fold for free.
  **Corpus population 0.**
* **R-V2 — golden's fold is NAME-KEYED and beats a shadow; ours is not.**
  `int S_A; S_A = 77; return S_A;` in a package function whose package also has
  an enumerator `S_A` — golden folds to the **ENUMERATOR's** value (`INT:0`),
  and so does it for a FORMAL (`function int f(int S_B); return S_B;` → `INT:1`)
  and for a CLASS PROPERTY (`int T_A; … return T_A;` → `UINT:3`). We keep the
  `ref_obj` to the shadowing declaration. SAME-WRONG in pristine and patched
  alike — the same name-keyed population § `pkgRetParamSubstIsRhsClone120`
  documents for parameters. Not touched.
* **R-V3 — an INTERFACE function folds in golden.**
  `interface i; function p::h_t f(); return p::H_B; endfunction endinterface`
  → golden `constant INT:1`; we keep the `ref_obj`. Pre-existing MISS, both
  binaries. The window `pkgRetFoldHome86` names a package home only.
* **R-V4 — a member whose initializer is a PARAMETER reference** (`PZ_A = PV`)
  is refused (the initializer is not an `IntegerLiteral`) where golden folds to
  `UINT:6 sz 32`. Pre-existing MISS; the member that FOLLOWS it (`PZ_B`) folds
  correctly to `INT:7 sz 32`.
* **R-V5 — the pristine ELAB view already mints a bare constant.** In
  `--elabuhdm`, pristine's top-package listing already carries
  `constant sz=64 INT:n` with **no `vpiDecompile` and no `vpiConstType`** at
  every one of these return sites (arms v1/v2/v5). The patch replaces it with
  the fully-populated golden form, which is why the ELAB half of every arm
  scores about twice the DEF half. Worth naming because it means a *different*
  producer already folds there.
* The implementer's own R1 (five refused arm-b cells), R2 (`pkg::NAME`), R3
  (nested operand), R4 (function-local body `begin`) and R5 (g22) all
  reproduced exactly as described.

**R0 (next head) — confirmed on my own patched sweep.** SimpleUVM ×2 and
Scoreboard/default: 334 lines, ONE head, `enum_typespec` golden
`uvm_pkg::uvm_sequence_state_enum` parented at `class_defn(work@env)` with a
`Typedef_alias` → the package's `uvm_pkg::uvm_sequence_state`, against ours
(the package's own object, parented at `module_inst(work@top)`, base name, no
`Typedef_alias`). BuildUVMPkg ×2: 83 lines, `LHS: <null>` against our surplus
`function (uvm_pkg::uvm_reg_map)` (the class's `ceil`) at `pp_output`:75228.

---

## 6. INSTRUMENTS IN THIS DIRECTORY (measurement-only)

| file | what it is |
|---|---|
| `varm.sh` | one arm: Surelog golden in BOTH views (a second `-elabuhdm` run for a golden of its own) + both frozen binaries + `cen138.py` census + the official `uhdm-cmp`; every child `</dev/null`, every rc printed |
| `vscore.py` | the three-way score (golden × pristine × ours) — TOGOLD / MOVWRNG / AWAY / SAMEWR / SAMEOK, multiset join on (VIEW, SITE, SPAN), one-sided sets printed both ways |
| `vattr.sh` | order-blind mover attribution: sorted, id- and path-stripped dumps, the WHOLE surviving diff printed (not a filtered view) |
| `vctl.sh` | a must-stay control arm: golden + pristine + fixed, both views, byte identity first and the census only where bytes moved |
| `v1_xpkg.sv` | cross-package: wildcard import, explicit single-name import, out-of-body method over another package's enum |
| `v2_shadow.sv` | a local / a formal / a class property shadowing an enumerator; an expression-initialised member |
| `v3_faces.sv` | the ten reference FACES × the two folding homes |
| `v4_kinds.sv` | 20 enum declarations, every base type and every explicit-value spelling, incl. a name range |
| `v5_homes.sv` | every home: package, out-of-body, in-body, class-scope enum, anonymous enum, function-local typedef, module, `$unit`, interface, parameterised class, virtual/extends |
| `v6_more.sv` | three name-range spellings, param-width base, typedef base, five nesting shapes, export chain, 3 instances |
| `v7_extra.sv` | the regression witnesses: a range member in an IMPORT CLONE (pristine-RIGHT), a plain member after a range (wrong count), a macro-written reference, a parameter-valued member |
