# r10v196 — ADVERSARIAL VERIFICATION of r10uvm196 (`§ modUnitImportParamsTwice196`) — **ACCEPT**

**MEASUREMENT ONLY.** Nothing here is an acceptance judge; the official
`uhdm-cmp` and `scripts/verify_golden.py` are. slang was NOT patched,
`results/*.csv` were READ ONLY, `GOLDEN_DEFER` stayed unset, and no driver here
ever dispatched a slang-fenced test. **LHS is ALWAYS golden (Surelog); RHS is
ALWAYS ours.**

The production surface of this pass is **unchanged by the verifier**. This
directory adds thirteen adversarial arms, their measured evidence, and two
CORRECTIONS to statements in `r10uvm196repro/README.md` (§4 below), which are
edited in place there.

---

## 1. Reproduction — every headline number, rebuilt from scratch

Two fresh worktrees at `c3e022a3` (`/tmp/wt_v196` + the patch, `/tmp/wt_v196pris`
clean), both configured and built by the verifier at `-j 2`, then frozen
`chmod 555` before any sweep; `SLANG_UHDM` exported explicitly per binary and
every `cmds.txt` audited BY PATH.

| claim | implementer | verifier |
|---|---|---|
| patch applies clean on FRESH `c3e022a3` | yes | yes, rc 0, no fuzz |
| pristine binary md5 | `4a42bc7a0018bc97d6d57ceebe1a0a9d` | **same** |
| patched binary md5 | `b319e3a6663d2992cbafd747f74a2ffc` | **same** |
| goldens / negative control | 23/0, 0/23 | **same** |
| uhdm2rtlil both modes | 679 / 50 / 2 | **same**, both binaries |
| `ct8rows` u2r vs baseline and vs own pristine | 0 rows | **same** |
| surelog 1588 rows | 0 differing rows, status AND dump | **same**, and pristine vs baseline also 0 |
| BuildUVMPkg ×2, Earlgrey_0_1/testflags, Rggen/default | CMP_EQUAL | **held**, no conversion either way |
| byteverify u2r | 0 / 1358 | **same** |
| byteverify surelog | 2 / 956 (SimpleUVM ×2) | **3 / 956** — the same two, plus `Scoreboard/default`, **the documented coin** (§3) |
| SimpleUVM ×2 head | 664681 → **62**, ONE head | **same**, and the 62-line head is the claimed R0 verbatim |
| every other row's head cmp log | byte-identical between binaries | **same** (10 of 10) |
| sorted-dump attribution | ADDED 8616 / REMOVED 0 | **same** |
| object kinds `parameter` / `param_assign` | 365→635 / 230→410, golden 635 / 410 | **same** |
| wide boundary | `LISTED=5189 PROCESSED=5189 PRODUCED=5018 MOVED=53 RC_DIFFS=0` | **identical** |
| moved arms rescored vs real goldens | TO-GOLDEN 2440 / AWAY 0 (52 non-control arms) | **identical** (106 views incl. the control: 2536 / 0, NODB 0) |
| the FLOOR | 34 families, MOVED = 0 | **verified by name**: uvm170/184/185/186/187/188/189/190/191/192/193/194, uvm82–91, buvm3–15, sd8–12 all listed, all `moved=0` (sd8–12 = 37+44+68+90+108 = 347 arms) |
| canaries / ctcan2 / canaudit | ok=52 / ok=8 / PASS, FENCE-BREACH=0 | **same** |
| protected DBs | all SAME, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **same** |

Full numbers: `GATES.v196.txt`. Boundary + floor + per-arm scores:
`BOUNDARY.v196.txt`.

**Every gate script copied into `r10uvm196repro/` is byte-identical to its
canonical original** (`canaudit.sh`, `canaries.sh`, `ctcan2.sh`, `ct8rows.sh`,
`byteverify.sh`, `rowheads.sh`) — no gate was weakened. The patch touches no
`results/*.csv`, hard-codes no other pass's paths, contains no `rm -rf`, and
carries none of the four fenced names outside `canaudit.sh`.

## 2. The law, read off SURELOG's source independently

The verifier re-derived the multiplicity rather than accepting the measurement,
and the producer is **a double registration, not a double pass**:

* `CompileFileContent::collectObjects_`
  (`~/git-repos/Surelog/src/DesignCompile/CompileFileContent.cpp:82-91`) handles
  each file-scope `paPackage_import_item` by calling
  `m_helper.importPackage(m_fileContent, …)` — and `CompileHelper::importPackage`
  itself opens with `scope->addObject(VObjectType::paPackage_import_item, fnid)`
  (`CompileHelper.cpp:133`) — and THEN calls `m_fileContent->addObject(type, fnid)`
  again. **Each file item lands in the FileContent's object list TWICE,
  adjacent.**
* `CompileModule::collectModuleObjects_` (`CompileModule.cpp:568-580`) then
  replays `fC->getObjects(paPackage_import_item)` into the module, so the module
  takes each file item twice. The module's OWN body item is materialized by the
  tree-walk case (`:601-605`) which calls `importPackage(m_module, …)` — that adds
  to the MODULE, never to `fC` — hence **once**. That is the whole 2-vs-1
  asymmetry.
* **Why packages are excluded is an ORDERING fact, not a special case.**
  `CompilePackage.cpp:143-152` carries the identical file-import block, but
  `CompileDesign::compilation_` (`CompileDesign.cpp:338-352`) runs
  `FunctorCompilePackage` **before** `FunctorCompileFileContent`, and modules and
  programs **after**. At package-compile time the FileContent's object list is
  still empty. `FunctorCompileFileContentDecl` runs earlier still and registers
  nothing (`m_declOnly == false` guard), so the count is exactly 2, deterministically.
* `importPackage` appends without dedup, from `getParameterMap()` (name order)
  for `Parameters` and `getParamAssignVec()` (declaration order) for
  `Param_assigns` — the two within-item orders the pass already carried.

The decoded model in `r10uvm196repro/README.md` §4 is therefore **correct**, and
its "2, per item, adjacent" is now derived as well as measured.

## 3. `Scoreboard/default` — the third byte mover is the COIN, proven

`byteverify` gave the verifier **3** movers, not 2. Attribution, per RESUME §9
(order-blind, never a byte comparison of two runs):

* `uhdm-dump | sort` on both sweep databases: **1100381 lines each, diff = ONE
  line, the dump's own file-path banner.** Zero content lines.
* The direct proof: the SAME command re-run from the test's source tree gives
  the **pristine** binary `df92db26e461, df92db26e461, 9455a56a1acf,
  df92db26e461` and the **patched** binary `9455a56a1acf, df92db26e461,
  df92db26e461, 7e80ee1cf561, 3340affe27b5, 9455a56a1acf` — **four distinct
  hashes out of one binary, and the patched binary reproduces the pristine
  sweep's own hash.** The row is not in this law's population.

`COIN.v196.txt`.

## 4. TWO CORRECTIONS to `r10uvm196repro/README.md` (edited in place)

1. **R4 said `parameter`'s generated `Compare` does not read `VpiImported`. It
   does** — it is the LAST field it compares,
   `~/git-repos/UHDM/build/generated/src/parameter.cpp:182`
   (`lhs->VpiImported().compare(rhs->VpiImported())`), after `VpiLocalParam` and
   `VpiName`. The Earlgrey tag residue is invisible **only** because that row
   measures CMP_EQUAL in testflags and its default row's head fires earlier —
   not because the field is unread. A future pass that moves a `vpiImported`
   tag must treat it as judge-visible. *(The pass's own added population is
   clean on this axis: the TAGGED census — key `(kind, name, vpiImported)` — on
   SimpleUVM/default against its real golden goes `GOLDEN-ONLY 360 → 0` with
   `OURS-ONLY 0`, so all 90 materialized copies carry `vpiImported = uvm_pkg`
   exactly as golden does.)*
2. **R0's citation.** `VpiSize` is compared by `expr::Compare`
   (`expr.cpp:95`), `constant`'s base — `constant.cpp` never names `VpiSize`.
   The conclusion (a one-field head the judge reads) is unchanged.

## 5. THE ADVERSARIAL ARMS — thirteen faces the pass's grid did not carry

Every arm: one REAL Surelog golden, BOTH views, both frozen binaries, every rc
recorded. Scored by the compare-visible census, never by a byte comparison of
two runs (RESUME §9's arm nondeterminism). Sources in `arms/`, census in
`ARMS.v196.txt`, scope-by-scope listings in `SCOPES.v196.txt`.

| arm | the face | golden | pristine | patched | verdict |
|---|---|---|---|---|---|
| `x1_inst` | a leaf module instantiated **1×** and **3×** — is the multiplicity per DEFINITION or per INSTANCE? | 8 on every scope, 9 on the leaf | 0 | **8/9 on all nine scopes, def + elab** | **TO-GOLDEN 144, AWAY 0** |
| `x2_spec` | **three parameter SPECIALIZATIONS** (`#(.P(1/2/3))`) of one module | 8/9 | 1 | exact on every named scope | **TO-GOLDEN 96, AWAY 0** |
| `x3_hdr` | a **module-HEADER** import (`module m import q::*;`) in a file that also carries a file-scope import of ANOTHER package | 44 | 4 wrong-tagged | exact, header item ONCE, file item TWICE | **TO-GOLDEN 40, AWAY 0** |
| `x4_after` | the file-scope import written **AFTER** the module it must reach | 8 on both modules | 0 | exact | **TO-GOLDEN 64, AWAY 0** |
| `x5_iface` | an **INTERFACE instantiated** in a module, both in the import's file | 8 on `xIf` and on `u_if` | 0 | exact | **TO-GOLDEN 64, AWAY 0** |
| `x6_twofile` | DEFINITION in file A (with the import), **INSTANTIATION in file B** | leaf 8, top 0 | 0/0 | exact | **TO-GOLDEN 32, AWAY 0** |
| `x10_defonly` | a module instantiated **only inside a NON-TAKEN generate branch** — the `§ detachedInstNoConns` segfault face | 8 | 0 | exact, **rc 0, no segfault** | **TO-GOLDEN 48, AWAY 0** |
| `x12_shadow` | a module parameter that **SHADOWS** an imported name | 33 | 1 own | count exact | **TO-GOLDEN 32, AWAY 0** (one tag cell, pre-existing, §6 V5) |
| `x13_genarr` | a **generate-loop instance ARRAY** ×4 of a module in the import's file (the R2 arity face) | 112 def / 176 elab | 0 | exact, `arity-mismatches 0` | **TO-GOLDEN 176, AWAY 0** |
| `x11_nested` | a module **nested inside another module** | outer 8, inner 8 | 0/0 | outer exact, **inner still 0** | TO-GOLDEN 32, AWAY 0 — residue V4 |
| `x9_dup` | the SAME package imported by **TWO identical file-scope items** + an explicit FUNCTION item + an empty package | 16 | 0 | **8** | TO-GOLDEN 32 of 64, AWAY 0 — residue V3 |
| `x7_inc` | the file-scope import arrives through **`` `include ``** | 32 | 0 | **0 — unmoved** | residue V1 |
| `x8_macro` | the file-scope import comes out of a **MACRO expansion** | 32 | 0 | **0 — unmoved** | residue V2 |

**AWAY-GOLDEN is 0 in every arm and every view. No pristine-right →
patched-wrong case was found, on any face.** The arms' own residual 50-line
head (a `constant` inside `quarryPkg::quarryTake`) is pre-existing and the two
binaries' cmp logs differ only by object-id renumbering.

### FENCE 3 proven live (the pass's own arm could not prove it)

`grid196.sh` runs our binary with **no** `--single-unit`, and slang's default is
one compilation unit **per file** — so `g196_d_other` (and `v196_x6`) cannot
exercise the same-buffer fence on our side by default; they agree for the wrong
reason. Re-run with `--single-unit`, which is what the UVM corpus rows use:
golden gives `xSixTop` (declared in a file with no import) **0** copies and
`xSixLeaf` + its instance **8**, and the patched binary matches scope for
scope. `SINGLEUNIT.v196.txt`.

## 6. RESIDUES the verifier adds (ranked; all pre-existing or partial, none a regression)

* **V1 — an `` `include ``d file-scope import materializes nothing.**
  `x7_inc`: golden 32 copies, both binaries 0. The fence compares
  `import.location.buffer()` with the DEFINITION's buffer, and an included
  header is its own buffer; Surelog's `FileContent` spans the include-expanded
  file, which is why golden fills it. The durable law is **same ROOT source
  file**, not same buffer — walk `SourceManager`'s `getIncludedFrom` chain (and
  `getFullyOriginalLoc` for V2) to the root before comparing. Not a regression:
  pristine is 0 too. **This is the natural next step of this law and the reason
  a corpus design that imports from a header still gets nothing.**
* **V2 — a MACRO-EXPANDED file-scope import materializes nothing.** `x8_macro`:
  golden 32, both binaries 0. Same fix (`getFullyOriginalLoc`, RESUME §9's
  macro-buffer note). Same direction, not a regression.
* **V3 — two IDENTICAL wildcard file items collapse to one.** `x9_dup`: golden
  16 (2 items × 2 copies × 4 params), patched 8. slang's `Scope::addWildcardImport`
  drops a duplicate identical import, so the CU holds ONE symbol where Surelog's
  parse tree holds two items. Fixing it needs the syntax list, not the symbol
  list. Half the population, moving the right way.
* **V4 — a NESTED module takes no copies.** `x11_nested`: golden fills
  `work@xOuter::xInner` with 8, we give 0 (FENCE 2 requires the definition's
  parent scope to be a `CompilationUnit`). Surelog materializes into a nested
  module because its `fC` is still the file's. Same direction; the nested
  module's DEFNAME also differs (`work@xInner` vs `work@xOuter::xInner`), a
  separate pre-existing naming residue.
* **V5 — the shadowing TAG cell.** `x12_shadow`: where a module's own parameter
  shadows an imported name, golden's copy is tagged `vpiImported=quarryPkg` and
  ours is the untagged own declaration; the COUNT is right. Pre-existing
  (pristine shows the same `OURS-ONLY-OWN=1`), and — per §4 — **judge-visible in
  principle**, so it belongs with the pass's R4 as one tag family.
* **V6 — the census's own blind spot.** `ct196cen --cen` iterates GOLDEN
  instance keys only, so a scope we have and golden does not is never scored.
  `x2_spec` has three such scopes (empty name and defname, `Parameters` 1→9,
  `Param_assigns` 3→11 under the patch) — this law's population lands on them
  too. They sit in no compared vector (the arm's cmp log changes only by id
  renumbering, and the corpus shows 0 differing rows), but "AWAY-GOLDEN 0" from
  this instrument means "away on golden-known scopes 0", and a future pass
  should read it that way.

## 7. FILES

| file | what it is |
|---|---|
| `arms/` | the thirteen adversarial sources + the two runners (`run_arms.sh`, `run2.sh`; both take the frozen binaries and `grid196.sh` from the implementer's dir) |
| `ARMS.v196.txt` | every arm's `cmp` line and CENSUM row, pristine and patched, both views |
| `SCOPES.v196.txt` | scope-by-scope `Parameters` / `Param_assigns` counts, golden vs patched vs pristine, for the six faces the pass's README did not carry |
| `SINGLEUNIT.v196.txt` | FENCE 3 proven under `--single-unit` |
| `COIN.v196.txt` | the `Scoreboard/default` coin, ten runs |
| `GATES.v196.txt` | the verifier's own full gate battery |
| `BOUNDARY.v196.txt` | the verifier's own 5189-source boundary, the 53 movers, the FLOOR by name, and all 106 rescored views |

## 8. VERDICT

**ACCEPT.** Every headline number reproduces bit-for-bit, including both binary
md5s. The law is independently derivable from Surelog's source, including the
part the pass could only measure (why 2, and why packages are excluded). Thirteen
adversarial faces — instance counts, specializations, header imports, import
order, interfaces, cross-file definitions, generate arrays, non-taken generate
branches, nested modules, shadowing, duplicate items, includes and macros —
produce **AWAY-GOLDEN 0** everywhere; the four faces that do not move are all
pristine-wrong-too (V1–V4), never pristine-right-turned-wrong. The floor holds
by name, the corpus does not move a row, and the two protected CMP_EQUAL
families are intact.
