# r10v170 — ADVERSARIAL VERIFICATION of r10uvm170 (§ `dpiExportedPkgSubBareOwnTdUnsupported170`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of the implementer's report
reproduced bit-for-bit on binaries this verifier built itself. Four cells of
**pristine-right → patched-wrong on legal SystemVerilog** were then found by
arms the implementer's grid does not contain, decoded to their Surelog cause,
and fixed here; the fix is `/tmp/r10uvm170.verified.patch`.

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge. slang
was NOT patched; `results/*.csv` were READ ONLY; no row was converted;
`GOLDEN_DEFER` stayed unset; the four slang-fenced tests were never dispatched
and are not named in any artifact here. **LHS is ALWAYS golden.**

| | |
|---|---|
| BASE | `143df9df` (the main tree had rotated to `3d549e59`; both worktrees are pinned at BASE) |
| pristine binary | md5 `9793b8253cc81350201a215044061a4f` — **identical to the implementer's**, built independently in `/tmp/wt_v170pris` |
| implementer's patched binary | md5 `a66b73e36dedd997fb0e7bdc649b2711` — **identical to the implementer's**, rebuilt from `/tmp/r10uvm170.patch` in `/tmp/wt_v170` |
| verified binary (this pass's fix on top) | md5 `7e094bd99eb656c4c22f18f01b64165b` |
| binary sizes | pristine 22 357 608 → implementer 22 366 608 → verified 22 372 576 |

---

## 1. REPRODUCTION — every headline number, on my own binaries

Both binaries built from scratch at `143df9df` (`-j 2`), frozen `chmod 555`
before any sweep, and `SLANG_UHDM` exported explicitly per binary. Every
`cmds.txt` in all six sweep workdirs audited BY BINARY PATH: 1523/1573 surelog
and 1458/1462 u2r name the intended frozen `/tmp/v170_{pris,pat,fix}.bin`; the
remainder are golden-cache-hit rows with no slang invocation, and **no
`cmds.txt` anywhere names a main-tree binary**.

| claim | implementer | measured here |
|---|---|---|
| MiniAmiq default / testflags cmp lines | 106 → **40**, 1 head | **106 → 40, 1 head, both modes** |
| BuildUVMPkg default / testflags | 106 → **52**, 1 head | **106 → 52, 1 head, both modes** |
| SeqDriver / SimpleUVM / Scoreboard / Earlgrey / Rggen heads | 50/50, 17/17, 95, 31/26, 0 unchanged | **identical, pristine and patched** |
| goldens | 23/0 patched, 23/0 pristine, 0/23 `/bin/false` | **23/0, 23/0, 0/23** |
| uhdm2rtlil | 679/50/2 both modes, `ct8rows` PASS, 0/1358 movers | **679/50/2, PASS ×3, 0/1358** |
| surelog default | 471/10/5/283/25, identical to own pristine | **identical, cell for cell** |
| surelog testflags | 466/9/5/3/1/284/23/1/2 | **identical, cell for cell** |
| `ct8rows` surelog | 0 differing rows over 1588, NO ROW CONVERTED | **PASS vs the committed baseline AND vs my own pristine sweep** |
| byte movers | 9/956, the nine predicted rows | **9/956, exactly those nine rows** |
| canaries / ctcan2 / canaudit | 52/0, 8/0, PASS ×2, 29 audited 0 UNCOVERED 0 FENCE-BREACH | **identical** |
| byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, three byte-identical | **identical, both modes** |
| R0 heads | MiniAmiq `func_call(copy)` @155:10 vs `method_func_call(tests_names)` @155:15; BuildUVMPkg `enum_var` @19055:27 vs `class_var` @20364:10 | **confirmed verbatim in the patched head logs** |

**Attribution, re-run independently** (`attrib170.sh`, workdir-normalised,
`id:`-stripped, ORDER-BLIND): all nine movers' sorted-dump diffs contain ONLY
this law's own line shapes —

```
\_enum_typespec: (uvm_pkg::uvm_severity)      out
\_unsupported_typespec: (uvm_severity)        in
|vpiName:uvm_severity                         in
|vpiInstance: + \_package: <the home package> in
```

**Scoreboard/default — the ~50/50 coin — contributed 0 extra order-blind lines
in my run too** (plain 90, order-blind 12; SeqDriver/default plain 108,
order-blind 24).

---

## 2. WHAT BROKE — four AWAY cells the implementer's grid cannot see

The implementer's five arms score `TOWARD 10 / AWAY 0 / MOVED-WRONG 0`. That
is reproduced here exactly. But their type-kind arm varies the *shape of the
typedef's target* and their spelling arm varies the *spelling of the
reference*; **neither varies the typedef DECLARATION's own form, and neither
puts a package-local name in competition with an imported one of the same
spelling.** Four arms written here (`v170_p_export.sv`, `v170_q_shape.sv`,
`v170_r_copies.sv`, `v170_s_edge.sv`) found two such faces, and
`v170_t_fence.sv` isolates each of them against a same-shape control declared
in the SAME package and cast in the SAME body, so neither position nor the
presence of imports can be the distinguisher.

Scored against **real Surelog goldens** (`grid170.sh` + `score170.py`, both
views, every rc recorded):

| arm | cell | golden | pristine | implementer's patch |
|---|---|---|---|---|
| `v170_t_fence.sv` t01 31:17 | `Early_e`, **forward-declared** `typedef enum Early_e;` first item | `enum_typespec(FenceT2::Early_e)` | same | **`unsupported_typespec(Early_e)` — AWAY** |
| `v170_t_fence.sv` t04 34:17 | `Tail_e`, forward-declared LATE in the item list | `enum_typespec(FenceT2::Tail_e)` | same | **AWAY** |
| `v170_t_fence.sv` t09 62:17 | `Fwd2_e`, forward-declared, in a package with **no imports at all** | `enum_typespec(CleanT2::Fwd2_e)` | same | **AWAY** |
| `v170_t_fence.sv` t06 36:17 | `Ghost_e`, declared locally AND wildcard-imported | `enum_typespec(DonorT2::Ghost_e)` | same | **AWAY** |

and the same two faces again in `v170_q_shape.sv` (q01 32:16 `Jump_e`,
q06 37:16 `Shadow_e`). Their controls in the very same package and body —
`Plain_e` (t02), `Late_e` (t03), `FwdS_s` (t05), `Pln2_e` (t10),
`Link1_e`/`Pair_s`/`Sel_u` (q02/q09/q10) — all degrade correctly, so the arms
are TESTING and not merely AGREEING.

### 2.1 FENCE 2, decoded — an import provides the name

`CompilePackage::collectObjects_` replays the package's imports at the TOP of
the `CollectType::FUNCTION` pass, before the item walk
(`~/git-repos/Surelog/src/DesignCompile/CompilePackage.cpp:139-155`), and
`CompileHelper::importPackage` copies the donor's **whole data-type map** into
the importer:

```cpp
// CompileHelper.cpp:162-169
auto& typeSet = def->getDataTypeMap();
for (auto& type : typeSet) { … scope->insertDataType(type.first, type.second); }
```

`DesignComponent::insertDataType` is `m_dataTypes.emplace(name, dt)`
(`src/Design/DesignComponent.cpp:104-106`) — an **emplace, which does not
overwrite** — so the imported entry is already sitting in `m_dataTypes` when
the DPI-exported body compiles one pass early, `getDataType(name)` HITS
(`CompileType.cpp:725`), and golden resolves the cast **to the donor's
typedef**, which is exactly what golden's `DonorT2::Ghost_e` says. Our own
pristine emission independently lands on the same donor object, so pristine and
golden already agreed and the law had nothing to win there.

This is a NAME test and not a "the package has imports" test: `pa170` in the
implementer's `g170_a_spell.sv` imports `fa170` and its own bare `ea_t` still
degrades (cell a01), and that cell still degrades under the fix.

### 2.2 FENCE 3, measured — a forward typedef

`typedef enum Early_e;` above the completion makes golden RESOLVE the cast
while the same package's plain `typedef enum bit [1:0] {…} Plain_e;` degrades
**in the same exported body**. Measured in a package WITH imports (t01, t04
resolve; t02, t03, t05 degrade) and in one with NONE (t09 resolves; t10
degrades), and at both the first and a late item position — so it is the
forward declaration and neither the position nor the imports. slang records it
as `TypeAliasType::getFirstForwardDecl()`.

The Surelog *mechanism* for this one is **not fully decoded** and is carried as
residue V-R1: `paData_declaration` (which carries `paType_declaration`) is
gated to `CollectType::DEFINITION` in `CompilePackage.cpp:261`, so the naive
reading says a forward typedef should be as invisible to the FUNCTION pass as a
plain one. The forward branch of `CompileHelper::compileTypeDef`
(`CompileHelper.cpp:879-910`) is the only place that treats the two
differently — it mints a `DummyType`, calls `scope->insertTypeDef`, and
eagerly compiles the typespec *"except for packages and FileContent"* — which
is the likeliest origin, but that was not proven here. The FENCE itself is a
measured golden fact on ten cells across two packages.

---

## 3. THE FIX

Two extra conjuncts on the existing `dpiOwnTdCast170` gate, both short-
circuited so they are evaluated ONLY at a site that would otherwise degrade —
the blast radius is exactly the cast sites this law already owns.

* `include/UhdmExporter.h` — the law for `dpiHomeStillResolves170` and the
  per-package import memo `DpiImp170`.
* `src/TaskFuncEmit.cpp` — `UhdmExporter::dpiHomeStillResolves170`:
  `getFirstForwardDecl()` for FENCE 3; the home package's own
  `ExplicitImportSymbol` names and `WildcardImportSymbol::getPackage()->find()`
  for FENCE 2.
* `src/ExprEmit.cpp` — one conjunct: `&& !dpiHomeStillResolves170(*expr.type)`.

### 3.1 Every arm re-scored under the verified binary

| arm | set: TOWARD / AWAY / MOVED-WRONG | cnt |
|---|---|---|
| `g170_a_spell.sv` (implementer) | 2 / 0 / 0 | 0 / 0 / 0 |
| `g170_b_site.sv` | 3 / 0 / 0 | 0 / 0 / 0 |
| `g170_c_home.sv` | 2 / 0 / 0 | 0 / 0 / 0 |
| `g170_e_kinds.sv` | 3 / 0 / 0 | 0 / 0 / 0 |
| `g170_d_notmove.sv` (negative control) | 0 / 0 / 0 | 0 / 0 / 0 |
| `v170_t_fence.sv` | **4 / 0 / 0** (was 4 / **4** / 0) | 0 / 0 / 0 |
| `v170_q_shape.sv` | **3 / 0 / 0** (was 3 / **2** / 0) | 0 / 0 / 0 |
| `v170_p_export.sv` | 5 / 0 / 0 | 0 / 0 / 0 |
| `v170_s_edge.sv` | 3 / 0 / 0 | 0 / 0 / 0 |
| `v170_r_copies.sv` | 0 / 0 / **1** | 0 / 0 / 0 |

**The implementer's ten TOWARD cells are all still TOWARD** — the fences cost
the law nothing. `v170_r_copies.sv`'s single MOVED-WRONG is the implementer's
R1 reproduced at arm scale (see §5).

### 3.2 What the new arms establish that the old ones did not

* an **aliased** export (`export "DPI-C" c_alias_alpha = function alpha7;`)
  degrades correctly for both a function and a **task** (p01, p02, p04) — the
  detector reads `DPIExportSyntax::name`, i.e. the SV name, and that is the
  right token;
* an export separated from its subject by two other definitions degrades only
  its subject (p07 degrades, p05/p06 resolve);
* a package with **no instantiating module at all** still degrades (u01, u02);
* a `T'(v)` cast to a **type parameter** and a class-handle typedef are
  untouched (u04);
* three module instances, a wildcard-importing package, an explicitly-importing
  package and a module-scope import do not multiply or move the cell
  (`v170_r_copies.sv`, `cnt` projection 0/0/0);
* nested class-in-class methods inside the exporting package never degrade
  (s01-s03);
* a **3-link alias chain** (`Link3_e`) and a local alias of a foreign enum
  (`LocalOfForeign_e`) stay resolved, extending the implementer's `t_alias_enum`
  fence by two links and across a package boundary.

---

## 4. GATES ON THE VERIFIED BINARY

**Mover prediction made BEFORE the sweep, by name:** exactly the same nine rows
as the implementer's patch — `default/{BuildUVMPkg,MiniAmiq,Scoreboard,
SeqDriver,SimpleUVM}` and `testflags/{BuildUVMPkg,MiniAmiq,SeqDriver,
SimpleUVM}` — because `uvm_pkg` declares `uvm_severity` with no forward
typedef and imports no package that provides that name, and because both new
conjuncts can only ever NARROW the gate.

* Build: `7e094bd99eb656c4c22f18f01b64165b`, frozen.
* Goldens: **23 PASS / 0 FAIL**; `/bin/false` **0 / 23**.
* uhdm2rtlil: **679 / 50 / 2** both modes; `ct8rows` PASS against the committed
  `results/gate_uhdm2rtlil.csv` AND against my own pristine sweep, both modes;
  `byteverify SELFCHECK=1` **0 movers / 1358**, `PATH_SETS_IDENTICAL`.
* surelog: **identical histograms to my own pristine sweep**, `ct8rows`
  **0 differing rows over 1588**, **NO ROW CONVERTED**.
* Bytes: **9 movers / 956**, exactly the nine predicted.
* Heads: MiniAmiq **40 / 40**, BuildUVMPkg **52 / 52**, SeqDriver 50/50,
  SimpleUVM 17/17, Scoreboard/default 95, Earlgrey 31/26, Rggen 0 — the same
  R0 objects the implementer named.
* Canaries 52/0 and 8/0, `ctcan2` PASS ×2, `canaudit` 29 audited / 0 UNCOVERED
  / 0 FENCE-BREACH; pins `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
  InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical.
* Wide boundary over a COPY of the whole probe tree, pristine vs verified
  (`bound170.sh`, subdirectories included, list on fd 3, children `</dev/null`,
  PROCESSED asserted, scratch keyed on the RELATIVE path):

  ```
  LISTED=4773  PROCESSED=4773  PRODUCED_DBS=4616  MOVED_ARMS=14  RC_DIFFS=0
  ```

  | moved arm(s) | verdict |
  |---|---|
  | the four `r10uvm170repro/g170_*.sv` and the five `r10v170repro/v170_*.sv` | **the POSITIVE CONTROL** — 9 own arms; a gate reporting zero over them could not see. Scored against real Surelog goldens in §3.1. |
  | `r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv` | **R-addrbound** — the class-scoped `typedef … name[string]` range bound reads `22556409` pristine and `22568697` verified. r10uvm154's documented address-derived residue: the binary grew 14 968 bytes and the constant moved 12 288 = 3 pages (the implementer's own run: 9 000 bytes, 8 192 = 2 pages). Not a law. |
  | `r10uvm36repro/t48a/dut.sv`, `r10v123repro/v123_c_kinds.sv`, `r10uvm125repro/g125_b_shapes.sv` | **SERIALISATION ORDER ONLY.** Workdir-normalised, `id:`-stripped dumps: t48a 0 differing lines; the other two have identical SORTED dumps under both binaries; `uhdm-cmp` between the two databases reports **0 lines / 0 heads** in BOTH views for all three. None contains an `export "DPI"`, so this law's flag is null throughout. `g125_b_shapes.sv` is a third member of the family the implementer already named twice — it is not in their moved list only because raw capnp byte layout is what `bound170.sh` compares, and that layout is page-address sensitive. |
  | the must-stay FLOOR — every committed arm of uvm157, § `scopedTdUnsupTsHomePkgInstance83`, § `pkgVarBindsOnlyThroughInstance88`, uvm151, uvm168 | **46 arms listed, 0 moved.** Byte-identical under both binaries in both views. |

  The 32 `Segmentation fault` lines in the boundary log are 16 arms that
  segfault under `--elabuhdm`, **symmetrically on both binaries** (`RC_DIFFS=0`)
  — pre-existing at BASE, not introduced.
* **`/tmp/r10uvm170.verified.patch` applied to a FRESH `143df9df` worktree
  rebuilds to the BYTE-IDENTICAL binary, md5 `7e094bd99eb656c4c22f18f01b64165b`,
  and passes 23/23 goldens there** — the patch IS the artifact every number
  above was measured on.
* Fenced-name hits in the patch: **0**. `results/*.csv` edits: **0**.

---

## 5. RESIDUES (ranked)

* **V-R1 — the FORWARD-TYPEDEF fence is measured, not decoded.** Ten golden
  cells say a forward-declared enum alias resolves inside an exported body
  while a plain one degrades; the Surelog path that makes `getDataType` hit for
  the forward one was not found (§2.2). Anyone who finds it can state FENCE 3
  as a mechanism instead of a fact — and should check whether it generalises to
  a forward `typedef struct`/`typedef union`, which this pass did not measure.
* **V-R2 — the implementer's R1 is real and now has an ARM.**
  `v170_r_copies.sv` t01 reproduces the SeqDriver/SimpleUVM copy split in
  eighty lines: golden holds BOTH a resolved and an `unsupported` copy at
  `15:16` while both binaries hold only one. It is a two-package,
  three-instance design with a wildcard-importing package — a much cheaper
  vehicle for hunting the design-level distinguisher than a UVM row.
* **V-R3 — FENCE 2 is a slang/Surelog AGREEMENT, not a slang correctness
  claim.** At `v170_t_fence.sv` t06 both Surelog and our emitter bind the
  wildcard-imported `Ghost_e` in preference to the package's own later
  declaration of that name. LRM 26.3 gives the local declaration precedence.
  The fix keeps us bug-for-bug with golden, which is this project's contract,
  but the underlying binding is worth a separate look.
* **V-R4 — the implementer's R2 sites are confirmed and still unowned.** A
  block-local typedef used as a cast target inside an exported body
  (`v170_q_shape.sv` q11 44:18) is `unsupported_typespec` in golden and
  `logic_typespec()` in BOTH binaries — a `same-differ`, untouched by this law
  and by the fix.
* **V-R5 — the address-derived boundary constant moves again.** The verified
  binary is 22 372 576 bytes, so `r10buvm22repro/g22.sv` and
  `r10uvm154repro/l154_noenum.sv` shift their class-scoped `typedef … name[string]`
  range bound from `22556409` to `22568697`. Same r10uvm154 R-addrbound
  signature — the shift is 3 whole pages against a 14 968-byte image growth —
  not a law.
* **V-R6 — `bound170.sh` compares raw capnp bytes, which are page-address
  sensitive.** `r10uvm125repro/g125_b_shapes.sv` moved here and did not move for
  the implementer, purely because the two binaries differ in size by a
  different number of pages; its workdir-normalised SORTED dump is identical
  under both binaries and `uhdm-cmp` is 0/0 in both views. The gate is still
  the right one (it is strictly stronger than a cmp-line count), but its
  moved-arm list has to be attributed every time and a moved arm is not by
  itself a finding.

## 6. FILES

| file | what it is |
|---|---|
| `v170_p_export.sv` | the EXPORT-DECLARATION axis: aliased C name, exported task, an export separated from its subject, an export written below |
| `v170_q_shape.sv` | the TYPEDEF-SHAPE axis: forward typedef, 3-link alias chain, alias of a foreign enum, a name shadowing an import, block-local typedef, nested classes |
| `v170_r_copies.sv` | the COPY / CLONE / INSTANCE axis: wildcard and explicit importers, three module instances |
| `v170_s_edge.sv` | EDGE shapes: a package no module instantiates, a type-parameter cast, a class-handle typedef, a generate block, a module-scope export |
| `v170_t_fence.sv` | the two AWAY faces ISOLATED, each against a same-shape control in the same package (and a second package with no imports at all) |

Reproduce with the implementer's own instruments:

```sh
CT170CEN=<ct170cen> ../r10uvm170repro/grid170.sh v170_t_fence.sv <pristine> <verified> <wd>
python3 ../r10uvm170repro/score170.py <wd> t_fence --all
```
