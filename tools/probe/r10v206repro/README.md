# r10v206 — ADVERSARIAL VERIFICATION of r10uvm206 (§ `importedClassTsRideTheFileUnit206`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of the implementer's report
reproduces bit-for-bit on binaries this verifier built itself. One
**pristine-right → patched-wrong** cell was found on legal SystemVerilog — an
*order-dependent* one, in the class-key collision the law's own dedup rule
creates — and is fixed here by a single added guard. Ship
`/tmp/r10uvm206.verified.patch`.

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The four slang-fenced
tests were never dispatched and are not spelled in any artifact here.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table and every
script.

| | |
|---|---|
| BASE | `a74e2df3`, in this verifier's OWN worktrees (`/tmp/wt_v206pris`, `/tmp/wt_v206`) |
| pristine binary | md5 `4f5f59ff040bbe46f92e4222a881637e` — **the implementer's number, reproduced** |
| implementer's patched binary | md5 `ed8d69ac8043b84d7036b4e6c21224e0` — **reproduced**, from `/tmp/r10uvm206.patch` (md5 `5292ce2b6d2e18c221d5463eb3ddb03c`) applied to a fresh `a74e2df3` |
| verified binary (with this pass's fix) | md5 `3e435c88eae83eb569693da95d99e8f8` |
| all three | frozen `chmod 555` before any sweep; every `cmds.txt` audited BY BINARY PATH (surelog 1523 / u2r 1458 per binary, **0** files naming any other `slang-uhdm`) |

Full numbers: `GATES.r10v206.txt`. Evidence: `GRID.r10v206.txt`,
`GRID_PATCHED_VS_FIXED.r10v206.txt`, `BOUNDARY*.r10v206.txt`,
`CENSUS.SimpleUVM.r10v206.txt`, `REGRESSION.r10v206.txt`, arms in `v206arms/`.

---

## 1. WHAT REPRODUCED, BIT FOR BIT

* **Both binaries.** The patch applies clean on a fresh `a74e2df3`; the surface
  is `src/{UhdmExporter,ModuleEmit,ParamEmit}.cpp` + `include/UhdmExporter.h` +
  `tools/probe/r10uvm206repro/` and nothing else. Both md5s match the report.
* **The head.** SimpleUVM `default 4177864 → 86`, `testflags 4178104 → 86`, ONE
  head each; SeqDriver 112, Scoreboard 95, MiniAmiq 112, Earlgrey/default 31 —
  all unchanged; BuildUVMPkg ×2, Rggen/default, Earlgrey/testflags 0 heads at
  `rc=0`. **All four protected CMP_EQUAL row-modes re-run at rc=0.**
* **R0.** The 86-line head is one bit on `work@top.clp`: golden
  `|vpiAutomatic:1`, ours absent, on a `class_var` under `module_inst`.
  Confirmed by reading the cmp log.
* **The census.** SimpleUVM design listing golden 123 / pristine 89 / patched
  123; design-listing join `AGREE 7 TS-DIFF 82 ONLY-GOLDEN 34 ONLY-OURS 0` →
  `AGREE 123`, everything else 0. Wide census TS-DIFF 89 → 5, **ONLY-OURS 0
  before and after**.
* **The grid**, over the implementer's own six arms, both views, real Surelog
  goldens: CALIB `226/0/0/0`, PRIS `180/28/18/12`, PATCHED `216/6/4/12` —
  **exact**. (The README's per-arm line for `g206_c_tparam` reads "AGREE 6 → 7";
  measured it is 5 → 6. The delta (+1) and every other cell of that arm, and all
  four column totals, are exactly as reported — a transcription slip, not a
  measurement error.) Arm `g206_d_modimport` is **byte-identical to pristine**
  and absent from the boundary's moved list: the negative control holds.
* **The prediction.** byteverify surelog `MOVERS 5/956` — `SimpleUVM ×2`,
  `SeqDriver ×2`, `Scoreboard/default`, exactly the predicted set — and u2r
  `MOVERS 0/1358`. Attributed order-blind (sorted, path-normalised
  `uhdm-dump`): SimpleUVM/Scoreboard **68 lines added** (all
  `class_typespec this_type / this_subtype / super_type / type_id`), SimpleUVM
  additionally **2 `vpiInstance → module_inst work@top` stamps removed**,
  SeqDriver **0 added / 1 stamp removed** — the gate correction. Nothing else
  moves in either direction.
* **The boundary.** `LISTED=5358 PROCESSED=5358 PRODUCED_DBS=5173
  MOVED_ARMS=54 RC_DIFFS=0` over a copy of the probe tree plus this verifier's
  17 arms; **the 48 committed-arm movers are exactly the implementer's 48**.
  Scored against real goldens in both views: `views=107 MISSING-ARMS=0
  NODB-views=1 TO-GOLDEN=190 AWAY-GOLDEN=0`. The floor holds by name (§ 202,
  § 201, § 199, § 197, § 196, buvm3–15, uvm82–91 all **0**; § 203 exactly its
  two arms, both TO-GOLDEN with the packed-struct fence's one-sided sets
  unmoved; sd8–12 exactly its six, all TO-GOLDEN).
* **R5, independently.** `ct8rows` moves exactly one row of 1588 against the
  committed baseline — `Earlgrey_0_1,testflags,CMP_EQUAL,,,differ` →
  `CMP_EQUAL,,,` — **and it moves on the PRISTINE binary too**. The row's
  database is byte-identical across all three binaries (`92bf7b7facdc…`) and
  `rowheads` reads it 0 lines / 0 heads / rc=0. Not a conversion, not this
  pass's. Against this verifier's own pristine control the surelog canary sheet
  is `ok=52 changed=0`; against the committed baseline it is `ok=51 changed=1` —
  that one cell — **on the pristine binary as well**.

---

## 2. THE DEFECT — a class-key collision ORPHANS an object golden lists

`fileUnitPublishesPackageClasses206` merges each imported package's class keys
into the design listing with a by-object dedup in which "the alphabetically
first key wins". Its three lines are

```cpp
            auto h206 = heldBy206.find(cts206);
            if (h206 != heldBy206.end()) {
                if (ck206 >= h206->second) continue;
                byKey206.erase(h206->second);          // <-- erases FIRST
                designTsRootLoc206.erase(h206->second);
                h206->second = ck206;
            }
            if (!byKey206.emplace(ck206, cts206).second)
                continue;                              // <-- ...and may then FAIL
```

so an object whose class key is **already taken by a different object** loses
its old key and never gains the new one: it drops out of the listing entirely.
Two independent packages can contribute the SAME bare class name, which is legal
SystemVerilog as long as the ambiguous name is never referenced.

`v206arms/y206_a_twopkgsamebare.sv` is that source. `pf206::gg206` is
represented by a class-scope `typedef gg206 this_type;`, so its class key
`gg206` is FRESH and succeeds (and makes the pass republish). `pg206::gg206` is
represented by `pg206`'s own top-level `typedef gg206 zg206;`, already published
at key `zg206`; its class key `gg206` sorts EARLIER but is now taken, so the
merge erases `zg206` and drops the object. Measured, **both views**:

```
GOLDEN               D#0  class_typespec|pg206::zg206|package:pg206
PRISTINE             D#0  class_typespec|pg206::zg206|package:pg206     <- RIGHT
IMPLEMENTER-PATCHED  D#0  class_typespec|this_type|design:work@ya206    <- WRONG
```

The design listing is ONE entry on every side, so this is not a size story: the
one position golden has, pristine got exactly right and the patch got wrong.
`design::Compare` reads `Typespecs()` positionally
(`BaseClass.h:202-224`), so it is judge-visible.

It is **order-dependent**: `v206arms/y206_b_twopkgsamebare_rev.sv` is the same
source with the two imports swapped, and there the patch is right — which is why
a single-order arm could not have found it.

**WHY GOLDEN ANSWERS WHAT IT ANSWERS.** `DesignComponent::insertDataType` is
`m_dataTypes.emplace(...)` (Surelog `src/Design/DesignComponent.cpp:103`) —
FIRST writer wins — and Surelog resolves both same-named classes to a SINGLE
ClassDefinition (its `C:pf206::gg206` and `C:pg206::gg206` listings are the same
two objects). So the contested key contributes at most the ONE entry that the
surviving class's own typedef key already carries, in BOTH import orders. The
file-unit typedef half already publishes exactly that.

---

## 3. THE FIX — one guard, `src/ModuleEmit.cpp`

> **§ `importedClassTsRideTheFileUnit206`, THE AMBIGUOUS-CLASS-KEY FENCE.** A
> class key contributed by MORE THAN ONE file-scope-imported package (with
> different typespecs) is not published at all: it is left to the typedef half.

```cpp
    std::map<std::string, std::set<const UHDM::typespec*>> cand206;
    for (auto& [pn206, loc206] : fileUnitImports206) { … cand206[ck206].insert(cts206); }
    …
            if (auto ca206 = cand206.find(ck206);
                ca206 != cand206.end() && ca206->second.size() > 1)
                continue;
```

It is a pure RESTRICTION — it can only ever publish less — so it cannot
introduce a cell anywhere. Measured consequences:

* `y206_a` (both views) returns to pristine's answer, which is golden's:
  `AGREE 3→3, AWAY 0` in the boundary score, `D#0` exact in the census.
* `y206_b` unchanged (it never fired).
* **The corpus does not move at all**: the verified binary's databases are
  BYTE-IDENTICAL to the implementer's on SimpleUVM ×2 and SeqDriver ×2, and the
  only byteverify difference of the two patched binaries over 956 databases is
  `default/Scoreboard`, whose path-normalised SORTED dump diff is **ZERO
  lines** — the documented ~50/50 COIN, not a change. u2r `MOVERS 0/1358`
  against pristine AND against the implementer's binary.
* The whole 23-arm grid, golden × pristine × verified: `AGREE 382 → 438`,
  `TS-DIFF 104 → 70`, `ONLY-GOLDEN 60 → 38`, **`ONLY-OURS 54 → 54`** — no arm
  loses an AGREE and no one-sided set rises anywhere.

---

## 4. THE ARMS THIS VERIFIER ADDED (`v206arms/`, 17 files, all legal SV)

The brief's cross — every registration face × source kind × order × package
count × imports/no-imports × DEF/ELAB. Every arm was built in BOTH views
against a REAL Surelog golden.

| arm | face | verdict |
|---|---|---|
| `y206_a_twopkgsamebare` | TWO packages, same bare class name, class key contested | **THE DEFECT** — fixed; pristine==verified==golden, both views |
| `y206_b_twopkgsamebare_rev` | the same, imports swapped | order-dependence proof: the patch was already right here |
| `x206_a_dropwithmove` | the drop path UNMASKED (one key succeeds so the pass republishes) + a class key contested by another package's TYPEDEF | TO-GOLDEN 1, AWAY 0 |
| `x206_b_dropwithmove_unit` | the same with the contested key coming from a `$unit` typedef | TO-GOLDEN 3, AWAY 0 |
| `z206_a_droprev` | `x206_a` with the imports swapped (golden gives the key to the typedef) | TO-GOLDEN 1, AWAY 0 |
| `w206_a_unitcollide` | class-scope-typedef representative beside a `$unit` typedef | TO-GOLDEN 3, AWAY 0; **`AGREE 11 = every golden cell`** |
| `w206_b_dropcollide`, `w206_c_dropcollide2` | the drop path MASKED (no other class key ⇒ `moved206` stays false ⇒ no republish); the colliding key from a package typedef / a `nettype` | unchanged on both binaries — the mask is why the defect needed `x`/`y` shapes to surface |
| `w206_d_twoclasskeys` | two packages, two DISTINCT class keys, anti-alphabetical | TO-GOLDEN 2, AWAY 0 |
| `v206_d_selfname` | dedup in the "class key LOSES" direction (`aa206_t` < `ee206`) | agrees before and after — the rule is right |
| `v206_e_samebare` / `v206_c_transitive` | two packages / a package that itself imports another | unchanged on both binaries (see R1 below) |
| `v206_f_noimport` | a design with NO import at all | unchanged — the `fileUnitImports206.empty()` guard holds |
| `v206_g_noclass` | a file-scope import of a package with NO classes | unchanged |
| `v206_b_explicit`, `w206_e_explicit` | an EXPLICIT (`import p::cls;`) import | unchanged on both binaries — see R2 |
| `v206_a_collide` | a `$unit` typedef of the imported class's own name | SLANG_REJECT on both binaries (`typedef target: PredefinedIntegerType`), identical rc — out of scope |

`v206_f_noimport`, `v206_g_noclass`, `v206_d_selfname`, `w206_b`, `w206_c`,
`v206_b`, `v206_c`, `v206_e`, `w206_e` are arms where PATCHED == PRISTINE cell
for cell: negative controls, deliberately reported as such rather than counted
as coverage.

---

## 5. RESIDUES THE ARMS FOUND (pre-existing on BOTH binaries; none is this pass's)

* **R1 — a file-scope import does not carry the imported package's OWN
  transitive imports.** `v206_c_transitive`: golden's design listing is
  `[pd206::ff206_t, pc206::hh206_t]` where `import pc206::*` is written at file
  scope and `pc206` itself does `import pd206::*`. We list only the first.
  `ONLY-GOLDEN 3` on both binaries, both views.
* **R2 — an EXPLICIT import publishes the class key too.**
  `v206_b_explicit` / `w206_e_explicit`: `import pb206::dd206;` gives golden a
  design-listing entry (`class_typespec pb206::yy206`, keyed by the CLASS name)
  that we do not have. `CompileHelper::importPackage` takes the same path for an
  explicit item (its `object_name` filter, `CompileHelper.cpp:139-147`), and
  § 206 records only `SymbolKind::WildcardImport`. `ONLY-GOLDEN 3` on both
  binaries, both views. The law's sentence should eventually say "a file-scope
  import", not "a file-scope wildcard import".
* **R3 — the class key must WIN a collision against a plain typedef when its
  package is imported FIRST.** `x206_a`: golden's `cb206` key holds the CLASS's
  representative and drops the other package's typedef of that name (first
  writer wins over an insertion sequence that is `classes of import 1, typedefs
  of import 1, classes of import 2, …`). We keep the typedef. `z206_a` is the
  mirror where golden keeps the typedef, and there we are right — so this is one
  ordering law, not two cells. `TS-DIFF 1` on the verified binary in each.
* **R4 — the MODULE arm on a `$unit` import.** `w206_d_twoclasskeys`: golden's
  `work@wd206` module listing carries the two class keys the `$unit` import
  published; ours does not (§ 45 covers only a module's OWN import).
  `ONLY-GOLDEN 4` after the patch (6 before — the design half closed).
* **R5 — `Earlgrey_0_1/testflags`'s informational dump column**, identical on
  all three binaries, with the row's database byte-identical. Already recorded
  by r10uvm197/199/201/203.
* **R6 — the `builtin` package's `work@process::state`**, one `ONLY-OURS` cell
  in every arm-view on every binary (golden's `-nobuiltin` run has no such
  scope). Not a corpus face.

**R0 stands as the implementer named it** and is the right next head: a
materialized-import `class_var` is `vpiAutomatic` in golden, at least eight
distinct objects under `module_inst`, the whole of SimpleUVM's remaining 86-line
head on both modes.

---

## 6. HOW TO REPRODUCE

```bash
git worktree add --detach /tmp/wt_v206pris a74e2df3
git worktree add --detach /tmp/wt_v206     a74e2df3
for w in /tmp/wt_v206pris /tmp/wt_v206; do
  cmake -S $w -B $w/build -DCMAKE_BUILD_TYPE=Release; done
(cd /tmp/wt_v206 && git apply /tmp/r10uvm206.verified.patch)
cmake --build /tmp/wt_v206pris/build -j 2   # md5 4f5f59ff…
cmake --build /tmp/wt_v206/build     -j 2   # md5 3e435c88…
cp /tmp/wt_v206pris/build/slang-uhdm /tmp/v206_pris.bin
cp /tmp/wt_v206/build/slang-uhdm     /tmp/v206_fix.bin
chmod 555 /tmp/v206_pris.bin /tmp/v206_fix.bin

cd /tmp/wt_v206/tools/probe/r10v206repro
g++ -O2 -std=c++17 ct206cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
    -luhdm -lcapnp -lkj -o /tmp/v206_ct206cen

# the arms, both views, real Surelog goldens
PRIS=/tmp/v206_pris.bin PATCHED=/tmp/v206_fix.bin CEN=/tmp/v206_ct206cen \
  JOIN=$PWD/join206.py bash grid206.sh $PWD/v206arms /tmp/v206_gridscr /tmp/GRID.txt

# the wide boundary and its golden-scored movers
cp -r ../../probe /tmp/v206_bsrc; cp v206arms/*.sv /tmp/v206_bsrc/
PRIS=/tmp/v206_pris.bin PATCHED=/tmp/v206_fix.bin bash bound206.sh /tmp/v206_bsrc /tmp/v206_bout
PRIS=/tmp/v206_pris.bin PATCHED=/tmp/v206_fix.bin CEN=/tmp/v206_ct206cen \
  JOIN=$PWD/join206.py bash bscore206.sh /tmp/v206_bsrc /tmp/v206_bout/MOVERS /tmp/v206_bscore

# the gates (export SLANG_UHDM per binary; audit every cmds.txt by binary PATH)
SLANG_UHDM=/tmp/v206_fix.bin bash ../../../tests/check_goldens.sh | grep -c '^PASS'   # 23
SLANG_UHDM=/tmp/v206_fix.bin python3 ../../../scripts/verify_golden.py --corpus surelog \
  --mode both --jobs 2 --out /tmp/v206_wd/slf.csv --workdir /tmp/v206_wd/slf
SELFCHECK=1 bash byteverify.sh /tmp/v206_wd/slf /tmp/v206_wd/slp    # MOVERS 5/956
bash canaudit.sh canaries.sh ctcan2.sh                              # FENCE-BREACH=0
```
