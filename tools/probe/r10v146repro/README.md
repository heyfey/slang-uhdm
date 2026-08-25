# r10v146 — ADVERSARIAL VERIFICATION of r10uvm146 (§ `unitImportHoistsPkgParams146`)

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `59e2cdc` (= UVM pass 144) |
| verdict | **ACCEPT WITH FIX** — the law and every headline number reproduce bit-for-bit from independently built binaries; two defects inside the law's own surface were found on legal SV, fixed here, and re-gated |
| verifier production delta | two hunks in `src/UhdmExporter.cpp` + one comment in `include/UhdmExporter.h` — § `unitImportHoistsPkgParams146v` |

## 1. WHAT REPRODUCED, BIT FOR BIT

Both binaries were rebuilt from scratch in fresh worktrees at `59e2cdc`
(`/tmp/wt_v146pris`, `/tmp/wt_v146`), frozen `chmod 555` before any sweep, and
every `cmds.txt` was audited by binary PATH.

| claim | independent measurement |
|---|---|
| pristine binary md5 | `85151c56af1f033f2c355b21f2386447` — **identical** |
| as-shipped patched binary md5 | `901516adb7f7120ebba60f804a788b7d` — **identical** |
| patch applies clean on fresh `59e2cdc` | yes, and the applied tree is **byte-identical** to the implementer's built tree (`diff -r` over `src/`, `include/`, the probe dir: no differences) |
| head SimpleUVM ×2 + Scoreboard/default | pristine **62 lines, 1 head**, LHS = `parameter (UVM_STR_CRC_POLYNOMIAL)` on `design (work@top)`, `vpiImported:uvm_pkg`, RHS = our `constant` @368:36 → patched **60 lines**, LHS = `array_typespec` (the `args[$]` member) |
| the six committed small head logs | `head_pris_*` / `head_pat_*` for SimpleUVM ×2, Scoreboard, BuildUVMPkg ×2, Earlgrey ×2 all **byte-identical** to my own runs |
| BIGHEADS md5 pairs | SeqDriver.default `bec7f95e126db8cc0d7341c060379dce`, SeqDriver.testflags `4aeb021be3f23195492c191231ac3222`, MiniAmiq both `0acc55a26252eb3657fcd893acccd118` — all four reproduce, pristine == patched |
| design listing | golden 45 `vpiParameter` + 45 `vpiParamAssign`; pristine **0/0**; patched **45/45 in order**, on all three row-modes |
| corpus | u2r 679/50/2 both modes, surelog 471+466 CMP_EQUAL / 10+9 NE; `ct8rows` **0 differing rows** vs the committed baselines AND vs my own pristine sweeps; **no row converted** |
| byte movers | surelog **3/956** — `default/Scoreboard`, `default/SimpleUVM`, `testflags/SimpleUVM`, exactly the three PREDICTED; u2r **0/1358** |
| canaries | `ok=52 changed=0`, `ok=8 changed=0`, both `ctcan2` PASS, `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort/BlackParrotComplex/YosysOldOr byte-identical |
| grid | all seven `g146_*.sv` listings equal golden's IN ORDER in BOTH views; `g146_c_owners` (the negative control) byte-identical |
| boundary | independently re-run over the committed probe tree: `PROCESSED=4173 MOVED_ARMS=17 RC_DIFFS=0` — the mover SET is the implementer's 17 arms, name for name |

**The one number that did not reproduce** is the boundary's arm count. The
committed tree at `59e2cdc` plus `r10uvm146repro` holds **4173** `.sv`/`.v`
files (4166 + 7), and the implementer's own worktree holds 4173 too, so
`LISTED=4186 PRODUCED_DBS=4039` in `BOUNDARY.r10uvm146.txt` is 13 arms and 10
databases high. Nothing else moved with it: the mover set, `RC_DIFFS=0` and the
per-arm readings all reproduce. Recorded as a documentation defect, not a
measurement defect.

**The one framing I re-derived rather than took.** `parameter::Compare`
(generated `parameter.cpp`:150-187) reads VpiConstType, VpiSigned, Expr, Ranges,
Left/Right_range, VpiLocalParam, VpiName and — last — VpiImported, over
`expr::Compare`'s VpiDecompile/VpiSize. **`VpiValue` is not read.** That matters
because the copies do carry VpiValue differences from golden (`INT:115199` vs
`UINT:115199` on `UVM_LARGE_STRING` and `UVM_SMALL_STRING`; `INT:56` vs `UINT:56`
on the grid's `K_expr`) — all invisible to the judge, all inherited from our own
package listing, none introduced by this pass.

## 2. THE LAW HELD WHERE IT MATTERS MOST — the shadowing arms

The brief's hardest question for this law is whether a name that is BOTH
`$unit`-imported and locally declared may be re-pointed. Surelog's
`UhdmWriter::lateBinding` answers it twice over, and both answers were measured
against real goldens:

* `lateBinding` only ever runs on a reference whose `Actual_group()` is still
  **null** (`UhdmWriter.cpp`:3297) — but our re-point runs on references that
  are already bound to a folded `constant`/`operation`. That is the over-reach
  the arms below had to convict or clear.
* Its `while (parent)` walk is **inside-out**, and `uhdmmodule_inst` /
  `uhdmpackage` are NOT cases in it — so the design listing is consulted
  **before** the `m->Param_assigns()` package rule at :3814-3822, and a
  package's own parameter really does lose to a `$unit`-imported one of the
  same name.

| arm | shape | golden | patched |
|---|---|---|---|
| `v17_pkgfunc_shadow` | `pv17b` declares `COMMON=200` and reads it in its own function; `pv17a::COMMON=100` is `$unit`-imported | binds the DESIGN copy, **100** | **100** (pristine bound `constant 200` — the patch FIXES it) |
| `v01`–`v04` | a module / generate-block / named-block localparam shadowing the import | golden emits **no `ref_obj` at all** there | our ref keeps its `<null>` actual — untouched |
| `v19`, `v20`, `v23`, `v26` | module-function, class-in-module, genvar loop, duplicated import, all shadowing | listing == golden | no reference moved |
| `v16`, `v21`, `v29`, `v30`, `v31` | the name also being an enum constant / a variable / a module name / a task name / a class property | listing == golden | actual kinds outside `constant`/`operation` are never touched |
| `v05`, `v07`, `v14`, `v34` | a second package, a transitive package import, an import at two scopes, two packages exporting the same name | listing == golden IN ORDER | every reference TO-GOLDEN |

## 3. WHAT BROKE — two defects, both inside the law's own surface

### § `unitImportHoistsPkgParams146v` (a) — **THE MAP DEDUPES, THE VECTOR DOES NOT**

`importPackage` iterates `def->getParameterMap()`, and that map is filled by
`DesignComponent::insertParameter` (`DesignComponent.cpp`:209) with
`m_parameterMap.emplace(p->getName(), p)` — an **emplace**, so a name inserted
twice keeps the FIRST entry, while `m_orderedParameters` (the counterpart of the
`Parameters()` vector the pass copied from) keeps **both**.

`v08_export.sv` — `package pv8b` does `import pv8a::*; export pv8a::*;` and
`$unit` imports `pv8b`:

```
golden  design  vpiParameter  AA, BB          (2)   vpiParamAssign  AA, AA, BB  (3)
as-shipped      vpiParameter  AA, AA, BB      (3)   vpiParamAssign  AA, AA, BB  (3)
fixed           vpiParameter  AA, BB          (2)   vpiParamAssign  AA, AA, BB  (3)
```

(Golden's *package* `pv8b` lists AA twice as well — the dedupe is the DESIGN
listing's alone, and the `param_assign` half must NOT be deduped.)
**Fix:** dedupe the per-import source set by name, in the vector's own order,
keeping the first — five lines, before the ASCII-name sort.

### § `unitImportHoistsPkgParams146v` (b) — **THE FIRST LISTED ENTRY WINS, AND IT CAN BE THE UNIT'S OWN**

`lateBinding` does not look the name up in the import's materialized set: it
scans `design->Parameters()` **in order** and `break`s on the first `VpiName`
match (`UhdmWriter.cpp`:3361-3369). The compilation unit's OWN parameters are
listed **before** the imported copies, so when both carry a name, golden binds
the own one. The as-shipped re-point bound out of the import map and got the
other object.

`v33_own_vs_imported.sv` — `parameter int CLASH = 33;` at `$unit`, and
`pv33::CLASH = 133` imported, read inside `pv33`'s own function:

```
golden design listing   CLASH(own,33)  CLASH(imported pv33,133)  OTHER(imported,134)
golden binding          parameter CLASH  UINT:33          <- the OWN entry
pristine                constant         UINT:133         (wrong)
as-shipped              parameter CLASH  UINT:133         (wrong OBJECT)
fixed                   parameter CLASH  UINT:33          == golden
```

**Fix:** rebuild the binding map from the FINAL `design->Parameters()` in
listing order with `emplace` (first wins), restricted to the names the import
materialized — so the gate ("a `$unit` import of a package that has
parameters") is unchanged, and the object bound is the one golden binds.
`v35_localparam_unit.sv` (a `$unit` localparam beside an imported pair) is the
companion arm.

Neither defect is a pristine-right → patched-wrong regression: pristine listed
**0** parameters and bound a folded `constant` in both arms. Both are the law
binding/listing the wrong OBJECT where the right one now exists in the database,
and both are one hunk each.

## 4. THE FIX IS INERT WHERE THE PASS EARNS ITS HEAD

* the three corpus movers' databases are **byte-identical** between the
  as-shipped binary and the fixed one (`09fe7675018f`, `72125716c437`,
  `b8b43dc1f869`);
* all seven `g146_*.sv` grid databases are **byte-identical** in both views;
* SimpleUVM's design listing carries **45 distinct names and 0 duplicates**, and
  **0** own-`$unit` parameters, so neither hunk can fire there.

## 5. GATES ON THE SHIPPED (FIXED) BINARY — all green

See `GATES.r10v146.txt`.

## 6. RESIDUES THIS VERIFICATION ADDS

* **R-MODINST (the biggest, and the next head after R0/R1 in this family).**
  Golden also hoists the `$unit`-imported parameter onto **every
  `module_inst`** — `\_parameter: (work@top_v34.TWIN)` under the instance's
  `vpiParameter` — in **both** views. We list none. On `v34_two_pkgs_same_name`
  and `v31_class_prop` this is EXACTLY the object the head lands on the moment
  the design listing is right (`v34` DEF 64 → 691, `v31` ELAB 50 → 311: both
  head objects moved from "design listing missing" to "module_inst listing
  missing"). It is masked on the three corpus rows only because
  `design::Compare` reaches `AllPackages` (field 2) before `Modules`.
* **R-REALDEC.** A `real` package parameter's `param_assign` Rhs decompiles as
  `2.500000` in our ELAB package listing where golden writes `2.5`
  (`v10_kinds.sv`). `VpiDecompile` IS compared. Pre-existing in the package
  listing; the design listing now mirrors it.
* **R-MULT (= the implementer's R3), confirmed and widened.** Our databases
  carry a reference at a given `name@line:col` **twice** where golden carries it
  once, in every package-function arm (`v07`, `v14`, `v17`, `v33`, `v35`) and on
  `UVM_STREAMBITS` in the corpus (golden 12 dangling, ours 11). Pristine and
  patched agree, so it moves nothing here.
* the implementer's **R0** (`array_typespec` on the `args[$]` struct member),
  **R1** (`design->Typespecs()` 123 vs 89) and **R2** (the associative-array
  range bound leaking a raw pointer) all reproduce as stated.

## 7. FILES

| file | what |
|---|---|
| `v01`–`v35` (34 arms, one in `sub15/`) | the adversarial grid: shadowing × home × view, import forms, parameter kinds, transitive/`export`, two tops, instance arrays, two compilation units, `ifdef`, name collisions with enums/vars/modules/tasks/class properties |
| `arm146v.sh` | the arm driver — BOTH views per arm, golden built per arm, every rc recorded, list on fd 3, children `</dev/null`, PROCESSED asserted, scratch keyed on the RELATIVE path, binaries printed |
| `ct146vcen.cpp` | the IDENTITY-aware census: for every `ref_obj`, the actual's kind **and name and value and owner** (the implementer's `ct146cen` records the KIND only, which cannot see a binding to the WRONG parameter — defect (b) is exactly that shape) |
| `score146v.py` | the multiset scorer: TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / MOVED-WRONG / one-sided, per arm per view |
| `ARMS.r10v146.txt` / `CENSUS.r10v146.txt` / `GATES.r10v146.txt` / `BOUNDARY.r10v146.txt` | the evidence |
