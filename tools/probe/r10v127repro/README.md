# r10v127 — adversarial verification of r10uvm127 (§ pkgRetOobClassAndImportCloneTs127)

The verifier's report, verbatim (paths under /tmp were its scratch; its own arms
and tools are copied beside this file by the master at landing).

All measurements complete. Every headline number reproduced bit-for-bit, and my own independent grids found no pristine-right → patched-wrong cell.

---

# r10uvm127 — VERIFIER VERDICT: **ACCEPT AS SHIPPED**

No `pristine-right → patched-wrong` case was found on any legal SV I could construct. **No fix was needed; no `/tmp/r10uvm127.verified.patch` is shipped.** `/tmp/r10uvm127.patch` (255 052 bytes, md5 `fdd6aa162825229c88ea04bfb18774b7`) is the deliverable, unchanged.

Worktrees `/tmp/wt_v127` (patched) + `/tmp/wt_v127pris` (pristine), both fresh at `f561b4d`. Scratch `/tmp/v127_*`. Nothing was written outside them.

## 1. Independently rebuilt binaries — md5s match the implementer's EXACTLY

| | md5 | frozen |
|---|---|---|
| pristine, my own build of f561b4d | `15f3eefdea95f356b4593dcd6e8ec55a` | `/tmp/v127_pris.bin` `chmod 555` |
| patched, my own apply+build | `832e499e648ce48eb7530edd4dbc2a98` | `/tmp/v127_pat.bin` `chmod 555` |

Both frozen **before** any sweep. `git apply -3` on the fresh f561b4d worktree: **rc 0, 0 conflict markers**, surface exactly `include/UhdmExporter.h` + `src/ExprEmit.cpp` + `src/StmtEmit.cpp` + `tools/probe/r10uvm127repro/`, **+53 −4** production lines (43/2, 4/1, 6/1). Fence check 0/0/0/0. No `results/*.csv` file in the patch (3 textual mentions, all prose). No stray `??` files.

## 2. The decode — I read every cited source myself, none was taken on trust

| claim | verified |
|---|---|
| the stamp writer | `~/git-repos/UHDM/templates/ExprEval.cpp:5860-5885` — walks `func->Io_decls()` **by position**, mints a `ref_typespec` when the actual has none, then `exparg->Typespec()->Actual_typespec(tps)` where `tps = io->Typespec()->Actual_typespec()` — the formal's **own object**, no `clone_tree` ✓ |
| the compared field | `expr.cpp:100` `if ((r = SafeCompare(lhs->Typespec(), rhs->Typespec(), context)) != 0) return r;` — `ref_obj::Compare` delegates ✓ |
| package compiled twice | `CompilePackage.cpp:63,68` `compile(Reduce::Yes)` then `getUnElabPackage()` `compile(Reduce::No)` ✓ |
| `paRETURN` is the only reduce-threading arm | `CompileStmt.cpp:834-843` ✓ |
| **an out-of-body method IS a package-level function declaration** | `CompilePackage.cpp:213-218` hands `reduce` to `compileFunction`; `CompileStmt.cpp:2344-2351` assembles the `paClass_scope` name into `"C::m"` and looks it up in the component's `getTask_funcs()` ✓ |
| **an import clone is a clone of the ELABORATED listing** | `CompileHelper.cpp:127` `importPackage`, `Package* def = design->getPackage(pack_name)` (the Design-level, elaborated package), `:310-325` `clone_tree` of `def->getTask_funcs()` ✓ |
| module / `$unit` take nothing | `CompileModule.cpp:776,784` and `CompileFileContent.cpp:95-98` pass a literal `Reduce::No` ✓ |
| the corpus discriminator | `uvm_printer.svh:238` is `extern virtual protected function string adjust_name`, defined out-of-body at `:805`, head site `:808` `return uvm_leaf_scope(id, scope_separator);`; callee formal at `uvm_misc.svh:445` cols 33-38. The three BARE callers `uvm_resource.svh:1065`, `uvm_objection.svh:1058`, `uvm_report_server.svh:897` are all **in-body** (no `C::`) ✓ |
| R0 sites | `uvm_packer.svh:484` out-of-body `uvm_packer::get_bytes`, `:488` `bytes = new[sz];`; `uvm_phase.svh:1400` `fork : master_phase_process` ✓ |

## 3. Gates — all reproduced on my own binaries

| gate | my measurement |
|---|---|
| goldens, patched | **PASS=23 FAIL=0** (`SLANG_UHDM=/tmp/v127_pat.bin`) |
| goldens, pristine | PASS=23 FAIL=0 |
| `/bin/false` negative control | **FAIL=23 PASS=0** |
| `cmds.txt` binary audit, surelog | 1573 files, **1523 name `/tmp/v127_pat.bin`** (pristine side: 1523 name `/tmp/v127_pris.bin`), 0 name any other binary |
| `cmds.txt` binary audit, u2r | 1462 files, 1458/1458 the frozen binaries |
| surelog, `--mode both`, 1588 rows | ct8rows vs committed baseline **PASS**; vs my own pristine sweep **`0 differing ROWS (0 diff row-sides)`** on status AND dump. Histograms: default 471 EQ / 10 NE / 5 DEF / 283 REJ / 25 SF; testflags 466 / 9 / 5 / 284 / 23 / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM — **identical on both binaries**. **NO ROW CONVERTED** |
| uhdm2rtlil, both modes | **679 / 50 / 2** each; ct8rows PASS vs committed baseline and vs my pristine sweep, both modes |
| byteverify surelog `SELFCHECK=1` | `PATH_SETS_IDENTICAL (956)`, **MOVERS 7/956**, SELFCHECK 955/956 |
| byteverify u2r `SELFCHECK=1` | `PATH_SETS_IDENTICAL (1358)`, **MOVERS 0/1358**, SELFCHECK 1357/1358 |
| canaries | `ok=52 changed=0` / `ok=8 changed=0`; ctcan2 **PASS ×2** |
| canaudit | `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | InterfaceModPort/BlackParrotComplex/YosysOldOr **SAME** both modes; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** ✓ |

**The 7 movers are the same 7 database paths the implementer named** — `default/{MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}` + `testflags/{MiniAmiq,SeqDriver,SimpleUVM}`. (My pristine hashes for MiniAmiq and SeqDriver/testflags differ from the implementer's; that is the documented macro-buffer nondeterminism, and the *patched* hashes for SeqDriver/SimpleUVM/Scoreboard-default and both MiniAmiq rows match theirs byte for byte. The mover **set** is what the law predicts, and it is identical.)

## 4. The a-priori prediction — reproduced exactly

`pred127` built from the shipped source, run over **my own pristine workdir**:

```
LISTED=956 PROCESSED=956 CANDIDATE_DATABASES=7 ZERO_CANDIDATE_DATABASES=949 CANDIDATE_CELLS=94 NONZERO_RC=0
default/{MiniAmiq 22, Scoreboard 2, SeqDriver 22, SimpleUVM 2}  testflags/{MiniAmiq 22, SeqDriver 22, SimpleUVM 2}
```

**0 unpredicted movers, 0 predicted databases that failed to move.** Per-mover order-blind path-normalised whole-dump diff (both dumps sorted, ids stripped): **removed=0 on all seven**; added 91/91/91/91/14/14/14; **lines outside `|vpiTypespec:` / `|vpiParent:` / `|vpiActual:` / `\_ref_typespec:` / `\_ref_obj:` / `\_*_typespec:` / `|vpiFullName:` = 0 on all seven.**

## 5. Heads — the object change is real, not a depth artifact

| row-mode | pristine head object | patched head object |
|---|---|---|
| SeqDriver def/tf | `ref_typespec (uvm_pkg::uvm_printer::adjust_name::id)` id 7725 | **`logic_net (work@top_tb.sz)` @488:15-488:17** — different object |
| MiniAmiq def/tf | `ref_typespec (…adjust_name::id)` id 7732 | **`named_fork (uvm_pkg::uvm_phase::execute_phase::master_phase_process)` @1400:9-1413:18** — different object |
| SimpleUVM def/tf, Scoreboard def | `string_typespec` id 158916/158928/159186 | **same object, same id**; the only cmp-log delta is `logic_typespec id:84364 → 84366` (2 objects minted ahead) |
| BuildUVMPkg ×2, Earlgrey ×2 | — | cmp logs **byte-identical** |

`rowheads.sh` tables match the implementer's line-for-line (17/17/12/12/12/17/17/12/12/214/144/0 → 17/17/12/12/12/**294/294**/12/12/214/144/0, measured=12 SKIP-NOFILE=2).

## 6. The corpus census and the wide boundary — reproduced

- **Nine UVM databases** (`ARGKINDS=all`, my own workdirs): **TOGOLD 46, MOVEDWRONG 0, MOVEDOTHER 4, ONESIDED_MIXED 0, ONESIDED_PAT_CHANGED 0 on every one of the nine.**
- **Wide boundary** over a copy of `tools/probe`, both binaries, both views: `LISTED=3830 FENCED_SKIPPED=0 PROCESSED=3830 MOVED=26 NO_OUTPUT_PAIRS=294 PROCESSED-ASSERT-OK`. **The 26 MOVED lines diff byte-identically against the shipped `BOUNDARY.r10uvm127.txt`.**
- **The 18 foreign arm-views, re-measured by me against goldens I built:** **7 TOGOLD, 0 MOVEDWRONG, 0 ONESIDED_MIXED, 26 ONESIDED_PAT_CHANGED** — the implementer's numbers exactly.
- **R4 independently confirmed:** golden **does** stamp `voob8`'s `package(op)/class_defn(C)/function(oobm)` copy; the arm scores **2 TOGOLD in both views**. r10buvm8's residue R6 ("stays BARE on both binaries") was a two-binary self-comparison that never consulted golden. Closed.
- Every MOVED arm judged with the **official `uhdm-cmp`**: all 30 arm-views (15 files × 2) are `rc=255` on **both** binaries. **No arm flips CMP_EQUAL → CMP_NOTEQUAL.** The line-count growth on them is head-object DEPTH at the `design` object, not distance.

## 7. BREAKING THE LAW — my own six grids, none derived from the pass's

`/tmp/v127_scratch/grids/v127_{a_callee,b_mismatch,c_faces,d_homes,e_import,f_dirs}.sv`, driver `/tmp/v127_scratch/varms.sh` (fd-3 list, children `</dev/null`, per-arm subdirectory on the relative path, every rc recorded, `PROCESSED-ASSERT-OK`), scored with `ct127cen` + `score127.py`, DEF and ELAB.

**Golden-vs-golden calibration first**, a second Surelog build of each arm in a *different directory*: **0 DIFF / 0 ONESIDED on all twelve arm-views** — the census key is neither path- nor run-dependent.

| grid | axis it adds beyond the pass's | def / elab |
|---|---|---|
| `v127_a_callee` | callee kinds the pass did **not** try: a **static method** via `C::sm()`, a **cross-package** free function, a **method call on a handle**, a **system call** `$clog2`, a **DPI task**, a package-task body, a same-class bare call | 4 / 4 TOGOLD, 1 / 2 SAME_DIFF |
| `v127_b_mismatch` | **actual-vs-formal TYPE MISMATCH**, both directions, over int/byte/shortint/`logic[7:0]` typedef/string/typedef-of-string/real/enum, each against a matched control, plus the free-function control | **11 / 11 TOGOLD** |
| `v127_c_faces` | actual faces: `this.prop`, `super.prop`, a **package variable**, a single-**bit-select**, a part-select, a member chain, an array index, a **concatenation**, a **call result**, literals, the method's own formal, a local | 12 / 11 TOGOLD |
| `v127_d_homes` | homes: **interface**, **program**, **module TASK**, module class out-of-body **task**, a class **derived from another package's class**, a class **holding a nested class**, package positive control | 3 / 3 TOGOLD |
| `v127_e_import` | **explicit single-item import**, **chained import** (A→B→C), **module importer**, **two importers of one home** | 14 / 8 TOGOLD |
| `v127_f_dirs` | directions input/output/inout/**ref**/**const ref**; **queue / dynamic array / associative array** / class-handle formals; **three module instances** | 5 / 5 TOGOLD |

**Totals over my twelve arm-views: 91 TOGOLD, `MOVEDWRONG = 0`, 12 MOVEDOTHER, 2 ONESIDED_PAT_CHANGED, 0 ONESIDED_MIXED.**

Three results are worth naming because they are the law's own proof, obtained without the implementer's fixtures:

1. **The mismatch grid pins the mechanism.** `intToByte` (int actual, `byte` formal) takes `byte_typespec @11:40-11:44`; `intToOctet` (int actual, `octet_t` = `logic[7:0]` formal) takes `logic_typespec @8:11-8:22` — **the typedef's own span**; `labelToStr` and `strToLabel` swap between `string_typespec @13:40` and `@7:11`. The stamped object is unambiguously the **callee formal's own typespec at that position**, never the actual's declared type. 11 cells, both views, all TOGOLD.
2. **The home fence is exactly right.** Golden stamps `package(Bittern)/class_defn(Cresset)/function(ctrl)`, `package(Fenland)/class_defn(Sedge)/function(derived)` (derived from another package's class) and `.../class_defn(Outerly)/function(shallow)`; it leaves `interface_inst/…`, `program/…`, `module_inst/task(modTask)`, `module_inst/…/task(Ratchet::modOobTask)` and the package `C::m` clone bare. **The patched binary matches golden on every one of those thirteen cells.**
3. **The import grid has ZERO one-sided cells** in both views — golden's and our key sets coincide exactly. Golden's `package(Alkanet)` **elab** listing stamps free fn + `class_defn(Belfry)/function(akOob)` and its **unelab** twin leaves free fn + `function(Belfry::akOob)` bare; the patched binary reproduces that split, and reproduces the stamp on both views of the `Dovecot`/`Elmwood`/`Furrow` clones.

## 8. Ranked residues

**R-A (new, MOVEDOTHER, 6 arm cells) — CONTAINER FORMAL TYPESPECS.** For a `qint_t`/`dint_t`/`aint_t` (`int[$]` / `int[]` / `int[string]`) formal, **our own** `io_decl` carries `FTS=int_typespec FTSID=139` where golden carries `array_typespec FTSID=61`, at the same span, **identically on both binaries**. The law faithfully copies our formal's object, so the cell scores MOVEDOTHER, not TOGOLD. This is the pass's R3 family (the object the stamp *points at*), extended from enum/struct to the container kinds — **pre-existing, corpus-invisible, and the next natural typespec-linkage target after this head.**

**R-B (new, SAME_DIFF, 2 arm cells) — EXPLICIT SINGLE-ITEM IMPORT CLONE, DEF VIEW.** `import Alkanet::akFree;` — golden stamps **both** views of the importer's clone (`package(Coppice)#3` and `#134`); we stamp only the elab one (`#219`), leaving `#27` bare. `pkgImportCloneEmit` reaches the **wildcard** clone only. Untouched by the pass (identical on both binaries), zero corpus population — `Surelog`'s `importPackage` clones an item import through the same `clone_tree`, so the same predicate should eventually cover it.

**R-C (new, SAME_DIFF, 2 arm cells) — `C::sm(x)` STATIC-METHOD CALL FROM AN OOB RETURN.** `return Quillon::statMeth(hasp)` — golden stamps the actual with `int_typespec @50:34-50:37`; both binaries leave it bare. A closed sub-case of the same window that the widening does not reach (the callee is resolved through the class scope, so `linked4`/`si.argTs` never carries the formal).

**R-D (confirms the pass's R1) — `super.prop` AS AN ACTUAL.** Surelog itself errors on it (`[ERR:UH0725] Unresolved hierarchical reference "super.bProp"`), so golden holds no cell; ours now carries a stamp there (2 ONESIDED_PAT_CHANGED). Golden-side limitation, not a divergence the judge can score against.

**R-E (instrument gap, not a defect) — `bound127.sh` records no per-invocation rc.** It tests file existence only, so a segfault reads as "no output". I closed the gap by hand over all 3830×2 arm-views: **14 matched `PRI`/`PAT` segfault pairs** (always the same file and view on both binaries) and **`ONESIDED_OUTPUT_TOTAL=0`** — no arm-view where pristine produced a database and patched did not. The driver is inherited verbatim from `r10buvm30`/`r10uvm124`; adding `echo "rc=$?"` per invocation would make this self-evident in a future pass.

**R-F (cosmetic).** `README.md` §4/§7 says both "the **16** foreign arm-views re-measured" and "26 across the **eighteen** foreign arm-views". The boundary reports 16 MOVED foreign *views*, while `FOREIGN.r10uvm127.txt` correctly measures 18 (both views of 9 files). The 18-view numbers are the correct ones and are the ones I reproduced.

The pass's own R1/R2/R3/R4/R5 all reproduced as written: R1 `ONESIDED_PAT_CHANGED = 0` on all nine UVM DBs and all twelve of its own arm-views, 26 across the eighteen foreign ones; R2 the importer copy count (golden 4, ours 3 — strictly closer than pristine's `{bare 1, stamped 2}`); R3 the `uvm_vector_to_string::radix` cell (`enum_typespec @82:1-97:18` vs golden's `@890:45` / `@1050:32`, with the sibling `SAME_DIFF` on both binaries pinning it as pre-existing); R4 closed; R5 `SAME_DIFF`.

## 9. What could still be wrong, and why I judge it isn't

The one structurally-worrying property of this patch is that it *adds* objects into three listings that previously held none. Three independent instruments say the addition is never a step away from golden:

- the judge itself: **0 differing rows over 1588 surelog + 1462 uhdm2rtlil**, and every one of the 30 boundary arm-views is `rc=255` on both binaries — nothing flips;
- the census: **`MOVEDWRONG = 0`** on the nine UVM databases, on the pass's twelve arm-views, on the eighteen foreign arm-views, and on my own twelve — 51 arm-views and 9 corpus databases without a single break;
- the dump: every mover **removes nothing** and adds only this law's seven line kinds.

`inClassBodyEmit` is set and cleared inside `emitTaskFuncs` (`src/TaskFuncEmit.cpp:2895` / `:6140`) with no save/restore across a nested call — but that is pre-existing structure already read by §§ 75/107/117, the new predicate introduces no new staleness, and the gate still requires `pkgScopeInst && tfBodyStmt9 && pkgRetTopExpr8` (itself saved and restored around `emitExpr` at `src/StmtEmit.cpp:4586-4618`). No measurement found it firing anywhere golden does not.

**VERDICT: ACCEPT.** Ship `/tmp/r10uvm127.patch` unchanged.
