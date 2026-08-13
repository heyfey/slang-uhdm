# r10uvm65 — ADVERSARIAL VERIFICATION of § emptyFnBodyEndLabelBegin65

## VERDICT: **PASS (with two latent-law findings and three reporting corrections — no live defect)**

Every gate number, grid cell and mover figure in the implementer's report
reproduces on binaries **I configured and built myself**, and both binaries came
out **bit-identical** to theirs (`caf4aa4b…` patched, `2dc0aff2…` pristine), so
their numbers were taken on the binaries they named. The briefed 13-line head is
**cleared on all three target rows**, the five gates are green, § 62's and
§ 64's arms are **byte-identical** across the patch, and the patch is
**STATED GATE == CODE GATE**: one predicate, four terms, one call site.

I built **four new arms** (`v1_qualdrop.sv`, `v2_views.sv`, `v3_ports.sv`,
`v4_items.sv`, **135 subroutine cells**) to hunt the empty product cells the
implementer's three arms leave open. **27 further cells clear, every one to
golden's exact object, and 0 clear the wrong way.** The hunt also found the two
things the report does not know:

* **F1 — a LATENT OVER-FIRE**, 6 cells: § 65 fires on the
  § qualifiedLifetimeMethodLosesNamePortsBody46 family, whose body
  `TaskFuncEmit.cpp:5213` nulls **without looking at it**, so the gate's own
  justification ("every dropped body has items") does not cover it. Golden has
  no such block anywhere. **0 corpus sites** (16 193 files scanned, both
  corpora), so nothing shipped wrong — but the comment's argument is unsound and
  the next § 46 change breaks it.
* **F2 — a LATENT UNDER-FIRE**, 4 cells: `fd.items.empty()` is **not** golden's
  rule, it is a conservative subset of it. Golden emits the block for
  `task t; input int a; endtask : t` — **NON-ANSI port declarations are `items`**.
  **0 corpus sites.** The law's stated term should read "no statements and no
  data declarations", with non-ANSI ports allowed.

Both are add/miss directions **outside** the corpus, both measured cell by cell,
and neither touches a shipped byte. Findings **F3–F5** are reporting
corrections. **No code defect.**

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)`.

---

## 0. BASE, BINARIES, PATCH

`auto5h` is still at **575f51d** — no landing intervened, so the briefed base IS
the current head and this is where the patch lands.

```
git rev-parse HEAD (main tree)        -> 575f51d14dace52ccfff05e1037eb527d0ad3b10
git -C /tmp/wt_v65     rev-parse HEAD -> 575f51d14dace52ccfff05e1037eb527d0ad3b10
git -C /tmp/wt_v65pris rev-parse HEAD -> 575f51d14dace52ccfff05e1037eb527d0ad3b10
md5sum /tmp/r10uvm65.patch  -> 2db980fe37c179bd84b96896e11827cd   (2162 lines)  MATCHES
git apply --check -v /tmp/r10uvm65.patch  -> rc=0 on a fresh 575f51d worktree
```

| tree | what | md5 of `build/slang-uhdm` |
|---|---|---|
| `/tmp/wt_v65` | patch applied, configured + built BY ME | **`caf4aa4b69f3fa155eb3d2b0afb415b3`** |
| `/tmp/wt_v65pris` | pristine 575f51d control, built BY ME | **`2dc0aff2ad7a0e04c304fcb71923de7b`** |
| implementer's `/tmp/wt_r10uvm65/build` | re-hashed by me | `caf4aa4b69f3fa155eb3d2b0afb415b3` ✓ |
| implementer's `/tmp/wt_r10uvm65pris/build` | re-hashed by me | `2dc0aff2ad7a0e04c304fcb71923de7b` ✓ |
| `~/git-repos/slang-uhdm/build/slang-uhdm` | main tree, pristine 575f51d | `2dc0aff2ad7a0e04c304fcb71923de7b` |

The build is **reproducible to the byte**: my independent configure + build
produced the same two md5s, and the main tree's own binary is a third
confirmation of the control. Link lines were waited for and read; md5s asserted
in their own commands, 32 hex each.

```
grep -cE 'error:' /tmp/v65_build_p.log /tmp/v65_build_c.log        -> 0 , 0
grep -E 'Linking CXX executable slang-uhdm|Built target slang_uhdm$'  -> [100%] both, both logs
SLANG_UHDM was passed EXPLICITLY and ABSOLUTELY to every sweep and every arm
  (verify_golden.py:53 defaults it to the MAIN TREE binary — the r10uvm64
   verifier's trap, avoided here by construction).
```

---

## 1. PATCH HYGIENE AND THE GATE ITSELF

`git apply --numstat`: **19 files, +2024 / −0** — an add-only patch (17 new files
+ 2 modified), no deletions anywhere.

* Production: **`include/UhdmExporter.h`** (+11, a forward declaration and a
  comment) and **`src/TaskFuncEmit.cpp`** (+86, the predicate and the call site).
* 17 files under `tools/probe/r10uvm65repro/` and **nothing else**:
  `git apply --numstat | awk '{print $3}' | grep -vE '^(include/UhdmExporter\.h|src/TaskFuncEmit\.cpp|tools/probe/r10uvm65repro/)' | wc -l` → **0**.
* `results/` untouched in the patch and in both worktrees
  (`git status --porcelain results/` → empty in each).
* `git stash list` has two entries, both dated **2026-07-24** (`eb225cd waves
  33-35`), weeks before this base. **Not attributable to r10uvm65.**
* `grep -rn 'emptyFnBodyEndLabel65' src/ include/` → **declared once, defined
  once, called from exactly one site.**

### STATED GATE == CODE GATE — read off my own worktree, not off the README

```c
if ((sub.flags & MethodFlags::Constructor) != MethodFlags::None) return nullptr;
auto* syn = sub.getSyntax();  if (!syn) return nullptr;
if (syn->kind != FunctionDeclaration && syn->kind != TaskDeclaration) return nullptr;
auto& fd = syn->as<FunctionDeclarationSyntax>();
if (!fd.items.empty()) return nullptr;
if (sub.subroutineKind == Task && (!fd.prototype->portList ||
                                    fd.prototype->portList->ports.empty())) return nullptr;
auto* ebn = fd.endBlockName;
if (!ebn || ebn->name.range().start() == SourceLocation::NoLocation) return nullptr;
return ebn;
```
```c
// call site, TaskFuncEmit.cpp:5321, after every body-drop rule and the param wrapper
if (!body)
    if (auto* ebn65 = emptyFnBodyEndLabel65(sub)) {
        auto* eb65 = s.MakeBegin();
        eb65->VpiParent(tf); eb65->VpiFullName(fullName);
        setLoc(eb65, ebn65->name.range());
        body = eb65;
    }
```

Four terms, no scope test, no qualifier test, no return-type test, no
function-port test, no out-of-body test, no name test, no `Stmts`, no new member
and no new counter. The README's table is exact.

### THE MECHANICAL ARGUMENT, CHECKED RATHER THAN ACCEPTED

Two claims in the comment are load-bearing and I checked both against the code:

1. **"Placed after every body-DROP rule, so the gate can never fire on a body
   those rules emptied: it is a SYNTAX test (`items` empty) and every dropped
   body has items."** I read every `body = nullptr` in the function
   (`grep -n 'body = nullptr' src/TaskFuncEmit.cpp` → 5224, 5238) **and the
   initialiser at 5213**, which is the one the comment misses:
   ```c
   auto* body = (qualCtor27 || qualLifetime46) ? nullptr : emitStmt(sub.getBody(), …);
   ```
   `qualLifetime46` drops the body **without inspecting it**. The two `= nullptr`
   sites at 5224/5238 do test the body (`isSuperNewStmt27`,
   `thisSuperNewAssignNoStmt3`) and both need a statement, so for THOSE the
   argument holds. For § 46 it does not — see **F1**, arm `v1_qualdrop.sv`.
   `qualCtor27` is covered by the Constructor term, so only § 46 leaks.
2. **The `fnBlockLocalPav` re-parent loop right after the call site now sees the
   new `begin`** (`if (body && body->UhdmType()==uhdmbegin) for (pav : fnBlockLocalPav) pav->VpiParent(body)`).
   Unreachable by construction — `blockLocal` variables ARE `items`, so
   `items.empty()` excludes them — and **measured**: the corpus adds exactly
   `27 × 5` lines and not one re-parented line, and no arm shows a moved
   `vpiParent`.

---

## 2. THE HEAD — CLEARED ON ALL THREE ROWS, AND THE BRIEF WAS WRONG

`rowheads.sh` on my own two surelog sweeps:

| row | pristine cmp lines | patched | head after |
|---|---|---|---|
| SimpleUVM / default | **13** | **262** | `begin (uvm_pkg::uvm_cause_effect_link::get_link) @255:7-255:29` |
| SimpleUVM / testflags | **13** | **262** | same |
| Scoreboard / default | **13** | **262** | same |
| Scoreboard / testflags | SKIP-NOFILE (SLANG_REJECT, no database) | — | reported, not hidden |
| SeqDriver / both | 85 | **85** | unchanged (`class_typespec (adpcm_pkg::type_id)`) |
| BuildUVMPkg / both | 58 | **58** | unchanged |
| SVSwitch / both | 54 | **54** | unchanged |

`grep -c do_open` on all three fresh cmp logs → **0, 0, 0**. The rise 13 → 262
is head DEPTH, not distance; the distance figures are in §5.

**The brief's mechanism (a) is the right one and its bail theory is false.** I
censused both sides before accepting anything: `grep -F "uvm_recorder::do_open)"`
→ **golden 6 lines, ours (pristine) 4**; the missing pair is `|vpiStmt:` + the
`begin` header, and golden's block has **no `Stmts` either** — it is empty on
golden's side too. The emitter's own note list for the Scoreboard compile is
`UnboundedLiteral` + `system method call: size`; neither is at line 547 and
neither is a statement. **No bail is involved.** The brief's "a begin whose
entire content we drop renders EMPTY on one side" is false in the way that
matters: the BLOCK is the missing object, not its content.

---

## 3. EMPTY PRODUCT CELLS — MY FOUR NEW ARMS (135 cells)

The implementer's arms walk kind × label × scope × body-form and the port list.
Three product axes are never opened, and each is exactly where a "no term on
this axis" claim goes wrong unseen: **the interaction with the other rules that
null the body**, **view multiplicity**, and **which KIND of `items` entry bars
the block**.

```
                       PRE (pristine)              POST (shipped)
v1_qualdrop  39 cells  SAME=21 DIFF=7  UNM=11      SAME=28 DIFF=0 UNM=11   + 6 latent over-fire (F1)
v2_views     30 cells  SAME=20 DIFF=8  UNM=2       SAME=28 DIFF=0 UNM=2
v3_ports     37 cells  SAME=20 DIFF=15 UNM=2       SAME=31 DIFF=4 UNM=2    4 remaining = F2
v4_items     29 cells  SAME=27 DIFF=2  UNM=0       SAME=28 DIFF=1 UNM=0
------------------------------------------------------------------------------
TOTAL       135 cells  DIFF=32                     DIFF=5   -> 27 cells cleared,
                                                             every one to golden's
                                                             exact span, 0 wrong way
```

### 3.1 `v1_qualdrop.sv` — **FINDING F1, the latent over-fire**

§ qualifiedLifetimeMethodLosesNamePortsBody46: an **in-class** method with BOTH a
class-item **qualifier** and a **written lifetime** loses its name, ports and
body in golden. b1/b2/b3 have no such cell (e21/e24/d15 write a lifetime with no
qualifier; c04/c16/e23 a qualifier with no lifetime). The product:

| cell | source | GOLDEN | pre | post |
|---|---|---|---|---|
| q01 | `protected function automatic void q01(); endfunction : q01` | **no object, no block** | — | **`begin@32:19-32:32*E`** ← surplus |
| q02 | `protected task automatic q02(int a);` | **none** | — | **`begin@34:15-34:33*E`** ← surplus |
| q03 | `local function automatic void q03();` | **none** | — | **surplus** |
| q04 | `static task automatic q04(int a);` | **none** | — | **surplus** |
| q05 | `virtual function automatic void q05();` | **none** | — | **surplus** |
| q06 | `protected function automatic int q06(int a);` | **none** | — | **surplus** |
| q07 | qualifier only (control) | `begin@46:19-46:32*E` | `-NONE-` | **match** |
| q08/q09 | lifetime only, function / ported task (controls) | `begin*E` | `-NONE-` | **match** |
| q10 | `protected task q10(int a)` (qualifier only, ported) | `begin@52:15-52:33*E` | UNM | **at golden's span** |
| q11 | § 46 shape **with** a body | `-NONE-` | `-NONE-` | `-NONE-` |
| q12 | § 46 shape, **no end label** | `-NONE-` | `-NONE-` | `-NONE-` |
| q13 | `protected function new()` (qualified ctor) | `-NONE-` | `-NONE-` | `-NONE-` |
| q14/q15 | OOB twins (§ 46 excludes oob) | `begin*E` | `-NONE-` | **match** |
| q16/q17 | module-scope lifetime controls | `begin*E` | `-NONE-` | **match** |

Golden collapses all six § 46 methods into **ONE** stub
(`function (v1p::v1c) @37:5-38:30`, the documented NOT-IMPLEMENTED collapse) and
that stub has **`-NONE-` at `vpiStmt`**. We emit six stubs, and after the patch
each carries an empty `begin` **golden has nowhere**: `+30 dump lines` of pure
surplus (6 × 5), and the blocks carry the FULL name (`v1p::v1c::q01_qual_auto`)
while § 46 truncates their own parent's to `v1p::v1c`.

```
grep -E '^\+.*\\_begin:' /tmp/v65arm_post_v1/d.diff   -> the 6 surplus blocks
grep -E '\\_begin:.*q0' /tmp/v65arm_post_v1/g.dump     -> only q07/q08/q09 (the controls)
```

**Severity: LATENT, not live.** My corpus census (`/tmp/v65_res_census.py`,
comments and strings stripped, self-tested against my own arm so a scanner that
finds nothing cannot read as green) over
`Surelog/tests + Surelog/third_party + uhdm2rtlil/test`:
**16 193 files, 0 sites.** Independently: the byte verifier's 953 databases
contain **7 movers**, and every added `begin` in all of them is golden-matched
(§5). Nothing shipped wrong. What is wrong is the comment's *argument*, and a
one-term fix (`!qualLifetime46`, already a live local at 5213) would make the
stated gate true.

### 3.2 `v3_ports.sv` — **FINDING F2, the latent under-fire**

| cell | source | GOLDEN | pre | post |
|---|---|---|---|---|
| **r01** | `task r01; input int a; endtask : r01` (**NON-ANSI**) | **`begin@30:15-30:28*E`** | `-NONE-` | **`-NONE-`** ← missed |
| **r02** | function twin of r01 | **`begin@33:19-33:32*E`** | `-NONE-` | **missed** |
| **r15/r16** | module-scope twins | **`begin*E`** | `-NONE-` | **missed** |
| r03 | non-ANSI ports **+ a statement** (control) | `sys_func_call` | same | same |
| r04..r12 | ANSI port product: default value, `ref`, `output`, `inout`, two ports, unpacked-array port, typedef'd type, `string`, class handle | `begin*E` ×9 | `-NONE-` | **all 9 match** |
| r13 | `pure virtual task` with a port | `-NONE-` | `-NONE-` | `-NONE-` |
| r14 | prototype carries the ports, definition is OOB | `begin@64:13-64:22*E` | `-NONE-` | **match** |
| r17 | module ANSI control | `begin*E` | `-NONE-` | **match** |

Non-ANSI port declarations live in `fd.items`, so `items.empty()` is false and
the gate declines — but Surelog builds a `tf_port_list` from them and emits the
block. **The law's second term as stated ("the body must be SYNTACTICALLY EMPTY
— `items` empty") is therefore not golden's rule**; it is a safe subset. Corpus
sites: **0** (same census). Direction: **miss**, never wrong-object.

### 3.3 `v4_items.sv` — WHICH item kind actually bars the block

This is the arm that says how conservative `items.empty()` is, and it mostly
**vindicates** the gate:

| cell | body holds only… | GOLDEN | post |
|---|---|---|---|
| s01 / s12 | a wildcard `import` | `-NONE-` | `-NONE-` ✓ |
| s03 | **two null statements** | `begin@34:7-34:8*E` | same on both sides ✓ (pre-existing) |
| s04 | a **`static`** variable declaration | `-NONE-` | `-NONE-` ✓ |
| s05 | an **`event`** declaration (ported task) | `-NONE-` | `-NONE-` ✓ |
| s07 | a declaration **with an initialiser** | `assignment@46:11-46:20` | `-NONE-` (pre-existing DIFF, unchanged) |
| s08 | an explicit empty `begin end` | `begin@50:7-51:10*E` | same ✓ |
| s09 | nothing (control) | `begin@55:19-55:30*E` | **fires** ✓ |
| s10/s11/s13 | a **`localparam`** (the `taskBodyPa9` path) | `-NONE-` | `-NONE-` ✓ |

`s10`/`s13` matter beyond this law: a task whose body is ONLY a localparam is the
one shape where the § 9 param wrapper (built one statement earlier, and requiring
a non-null body) and § 65 (requiring `items.empty()`) can BOTH decline — and
golden emits nothing there either, so the interaction is correct by measurement.

**Surelog SEGFAULTS (rc=139, no database) on a body-only `typedef`** —
`function void f(); typedef int t; endfunction : f` — so two planned cells cannot
be measured at all. Recorded in the arm; not attributable to this patch.

### 3.4 `v2_views.sv` — every view I could reach from source

| cell | view | GOLDEN | pre | post |
|---|---|---|---|---|
| m01/m02 | package class, function / ported task | `begin*E` | `-NONE-` | **match** |
| p01/p02 | **parameterized class**, specialized twice | `begin*E` | `-NONE-` | **match** |
| n01 | **nested class** | `begin@64:21-64:30*E` | `-NONE-` | **match** |
| g01 | module instantiated **twice** (def + elab) | `begin@79:17-79:26*E` | `-NONE-` | **match** |
| g02 | inside a **generate-for**, BOTH `gblk[0]` and `gblk[1]` | `begin@87:19-87:28*E` ×2 | `-NONE-` ×2 | **both match** |
| i01 | **interface-class** `pure virtual` prototype | (no object) | `-NONE-` | `-NONE-` ✓ |
| d01 | **DPI import** (different syntax node kind) | `-NONE-` | `-NONE-` | `-NONE-` ✓ |
| x01 | **checker** scope | `begin@99:17-99:26*E` | `-NOOBJ-` | `-NOOBJ-` (we emit no function object at all — pre-existing listing gap, unchanged) |

My clone-view cell did not materialise (our emitter did not produce a clone of
`v2src::v2c` for this source), so the **package-clone view rests on the corpus
measurement, where it is unambiguous**: golden has
`begin (adpcm_pkg::uvm_reg_block::readmemh) @1800:10-1800:18` **twice** and after
the patch so do we (§5).

---

## 4. THE IMPLEMENTER'S OWN GRIDS, REPRODUCED CELL FOR CELL

`ct65arm.sh` + `ct65cells.py`, both binaries, my own runs:

| arm | pristine | shipped | dump content pristine → shipped |
|---|---|---|---|
| `b1_empty.sv` | SAME=33 **DIFF=7** UNM=2 | SAME=40 **DIFF=0** UNM=2 | 51 → **8** |
| `b2_scopes.sv` | SAME=22 **DIFF=8** UNM=10 | SAME=30 **DIFF=0** UNM=10 | 90 → **51** |
| `b3_taskport.sv` | SAME=30 **DIFF=16** UNM=1 | SAME=46 **DIFF=0** UNM=1 | 208 → **118** |

Every figure identical to the report. The residual b1 content is exactly the 4
`c24` function-span lines + 4 lines of golden listing a decl-only body's var
twice; b2's is the OOB-definition HOME disagreement, the `virtual`/`pure` span
laws, the `$unit` task listing and a program instance listing; b3's includes
**e05**, the one place § 65 adds an object golden lacks — and golden emits **no
`task` object at all** there, so the whole object is surplus either way (I read
the diff rather than taking this on trust).

### § endBlockLabelAllOwners62 — HOLDS, byte for byte

`arm62.sh`, all three arms, pristine vs patched:
`c1_endlabel`, `c2_neighbours`, `c3_edge` → **`o.dump` byte-identical** in all
three (dump content 235 / 26 / 150, cmp lines 18 / 114 / 1038, identical on both
binaries). § 62 owns the `vpiEndLabel` FIELD; this patch mints a statement block
that merely happens to be LOCATED at the label token. **No collision.**

### § blkLocalSameCtrlDepthWindowBinds64 — HOLDS, byte for byte

`ct64arm.sh` + `ct64cells.py`, all six arms (`b1_cond`, `b2_modtwin`, `b3_kinds`,
`v1_prod`, `v2_ctx`, `v3_loopwin`), both binaries:

```
path-normalised differing dump lines:   0   0   0   0   0   0
cell grids identical: 65/1, 32/9(+10 NAME-DIFFERS), 48/0, 161/0, 104/3, 54/0
```

The uvm64 R1 residue (a NAMED-block-local over-bind at depth 0, `b1_cond` c08)
is **still exactly one cell, unchanged** — and it is **not** this head:
`REMOVED = 0` in all 7 movers and the object § 65 adds has no reference fields.

### Live passes

`/tmp/wt_r10svs12` no longer exists (r10svs12 has landed as `550eac3`);
`/tmp/wt_r10earl36` is live and touches `src/TypeEmit.cpp` only.
`git -C /tmp/wt_r10earl36 apply --check /tmp/r10uvm65.patch` → **rc=0**. No file
overlap (`TaskFuncEmit.cpp` + `UhdmExporter.h` vs `TypeEmit.cpp` /
`ModuleEmit.cpp`), no probe-directory collision.

---

## 5. THE FIVE GATES, RUN BY ME

### GATE 1 — BUILD
`/tmp/wt_v65/build` and `/tmp/wt_v65pris/build`, absolute; link lines read; 0
`error:`; both md5s asserted separately and 32 hex; both worktrees at 575f51d.
See §0.

### GATE 2 — GOLDENS, with the negative control
```
SLANG_UHDM=/tmp/wt_v65/build/slang-uhdm ./tests/check_goldens.sh  rc=0  PASS=23 FAIL=0
SLANG_UHDM=/bin/false                    ./tests/check_goldens.sh  rc=1  PASS=0  FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own out/workdir
```
patched : 679 CMP_EQUAL  50 SLANG_REJECT  2 SURELOG_FAIL ; dump 496 match/183 differ/52 blank
pristine: identical
ct8rows.sh results/gate_uhdm2rtlil.csv <fresh>  -> 731 ROWS both sides,
   WHOLE-ROW diff (status AND dump column): 0 differing ROWS   — BOTH sweeps
```

### GATE 4 — surelog, `--mode both --jobs 2`, `GOLDEN_DEFER` echoed `[UNSET]`
```
default   467 CMP_EQUAL 13 CMP_NOTEQUAL 5 DEFERRED 284 SLANG_REJECT 25 SURELOG_FAIL
testflags 463 CMP_EQUAL 10 CMP_NOTEQUAL 5 DEFERRED 286 SLANG_REJECT 23 SURELOG_FAIL
          3 NO_DATABASE 1 NO_UHDM 1 TIMEOUT 2 UNTRANSLATABLE
dump default 225/242/327 · testflags 165/298/331 — STATUS and DUMP histograms IDENTICAL
ct8rows.sh results/golden_surelog.csv <fresh>  -> 1588 ROWS both sides, 0 differing ROWS
   — BOTH sweeps.  5 DEFERRED in both modes, as in the baseline.
```

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs MY OWN pristine build
```
u2r     : PATH_SETS_IDENTICAL (679)  MOVERS 0 / 679   SELFCHECK 678/679   SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953)  MOVERS 7 / 953   SELFCHECK 952/953   SELFCHECK1 = 8
```
Both negative controls fire in both corpora, so "0 movers" on u2r is a
measurement and not a mis-wired driver. The 7 movers are exactly
`default/{BuildUVMPkg,Scoreboard,SeqDriver,SimpleUVM}` +
`testflags/{BuildUVMPkg,SeqDriver,SimpleUVM}`, and BuildUVMPkg's two modes share
the patched bytes (`e2473bb87158`) — the predicted set, exactly.

### CENSUS-PREDICT, re-run by me, with its arm control
```
census65.py <UVM src>            -> 25 fire sites (7 functions + 18 tasks), file for file
census65.py <tests> <u2r>        -> 4  (SimpleClass, ConcatVal, PreprocUhdmCov, r5p_csr)
census65.py <third_party>        -> + Opentitan 3, Rp32 1  = the report's 8 elsewhere
ARM CONTROL (a scanner that finds nothing where the grid moves measures nothing):
  b1 8  b2 11  b3 17  v1 14  v2 8  v3 11  v4 1   — each equals that arm's fires
```
25 predicted subroutines → **27 emitted blocks**, the surplus being the two OOB
tasks in two views: the script's own stated bound, and it holds.

### CANARIES
```
canaries.sh vs u2r baseline     : ok=8   changed=0 absent=0 unknown-names=25
canaries.sh vs surelog baseline : ok=52  changed=0 absent=0 unknown-names=7
ctcan2.sh EXPECT_UNKNOWN=6 (u2r): ok=1   changed=0 absent=0 unknown-patterns=6   PASS
ctcan2.sh EXPECT_UNKNOWN=1 (sl) : ok=58  changed=0 absent=0 unknown-patterns=1   PASS
canaudit.sh canaries.sh ctcan2.sh: audited=29  UNCOVERED=0  FENCE-BREACH=0       PASS
BY NAME, both modes, base == fresh:
  InterfaceModPort   CMP_EQUAL/differ , CMP_EQUAL/differ
  BlackParrotComplex CMP_EQUAL/differ , CMP_EQUAL/differ
  SimpleUVM/SeqDriver/BuildUVMPkg/SVSwitch CMP_NOTEQUAL both modes
  Scoreboard  default CMP_NOTEQUAL , testflags SLANG_REJECT
```
The four slang-fenced tests were never dispatched (FENCE-BREACH=0). **See F3:
`canaries.sh` ships without its executable bit and had to be run as
`bash canaries.sh`.**

### DETERMINISM AND THE SIZE DELTA — Scoreboard/default, **7 reps per binary**
```
PATCHED  caf4aa4b : 70e3471e ×2, 5608dbd4 ×2, 33f1c5c1 ×2 (+1)  distinct=3 over 7 runs
                    bytes = 11 133 116 on ALL SEVEN
PRISTINE 2dc0aff2 : 6cdddd3a ×3, 034ff03d ×2, 1b919624 ×1      distinct=3 over 7 runs
                    bytes = 11 133 994 on ALL SEVEN
```
The hash flake is **pre-existing and symmetric** — I see 3 distinct hashes on
BOTH binaries (see **F4**: the report's "worse on pristine" is an artefact of a
3-rep sample). What matters holds exactly: **the byte SIZE is stable within each
binary**, so the mover attribution rests on the size, and the delta reproduces:

```
mover                 pristine     patched      delta
default/SimpleUVM     11129685     11128807     -878
default/Scoreboard    11133994     11133116     -878
default/BuildUVMPkg   11107000     11106123     -877
default/SeqDriver     17965493     17963219    -2274
testflags/SimpleUVM   11130054     11129176     -878
testflags/BuildUVMPkg 11107000     11106123     -877
testflags/SeqDriver   17965897     17963641    -2256
```
**F5: the report's EXPLANATION of the shrink does not survive my arms** — see §7.
Its CONCLUSION (nothing was lost) does, on stronger evidence than the report
gives: the whole-dump multiset reports **REMOVED = 0** on all 7 movers, i.e. not
one dump line text disappears anywhere, and the dump grows by exactly +135.

---

## 6. THE MOVERS, PER SHAPE, BY MULTISET — ALL SEVEN, ALL REPRODUCED

`mv65.sh`, LHS always golden, `sed 1d` all three dumps, ADDED/REMOVED never
netted:

| mover | distance to golden pristine → patched | gain | ADDED | REMOVED |
|---|---|---|---|---|
| default/SimpleUVM | 144463 → 144362 | +101 | 135 | **0** |
| testflags/SimpleUVM | 144459 → 144358 | +101 | 135 | **0** |
| default/Scoreboard | 134770 → 134669 | +101 | 135 | **0** |
| default/SeqDriver | 367603 → 367482 | +121 | **155** | **0** |
| testflags/SeqDriver | 367603 → 367482 | +121 | **155** | **0** |
| default/BuildUVMPkg | 81115 → 81030 | +85 | 135 | **0** |
| testflags/BuildUVMPkg | 81115 → 81030 | +85 | 135 | **0** |

Every figure identical to the report. `135 = 27 × 5`, `155 = 31 × 5`, and the
five shapes per site are `|vpiStmt:`, the `begin` header, `|vpiParent:`, the
parent `function`/`task` back-reference and `|vpiFullName:`.

**THE OVER-FIRE AUDIT AT CORPUS SCALE — the decisive measurement, and I ran it
myself.** Of the **354** three-way rows across the four designs, exactly **4**
have `golden=0`, and all four are the SAME OBJECT: the back-reference line
`\_function: (uvm_pkg::uvm_reg_indirect_data::build), line:57:4, endln:58:22`
(three designs) and its `--single-unit` renumbering `line:68887:4, endln:68888:22`
(BuildUVMPkg) — the line our new `begin` prints for its parent, carrying OUR
(pre-existing, wrong) function span. Residue 5, not a new object. **Every one of the 27 (29 on SeqDriver) added `begin` header texts has
`golden == patched`**, including the clone view:

```
[  \_begin: (adpcm_pkg::uvm_reg_block::readmemh),  line:1800:10, endln:1800:18]  golden=2 pristine=0 patched=2
[  \_begin: (adpcm_pkg::uvm_reg_block::writememh), line:1807:10, endln:1807:19]  golden=2 pristine=0 patched=2
```
`155 = 135 + 4 blocks × 5` — the def view, the elab view, the OOB hoist and the
package clone are all covered from the one shared body path, and each lands on a
count golden already had rather than past it.

### WHOLE-DESIGN PER-CELL AUDIT — all four movers, not just SimpleUVM

| design | `ct65cells.py` totals pristine → shipped | under-fire | over-fire | hidden in UNMEASURED |
|---|---|---|---|---|
| SimpleUVM | SAME 3049→**3073**, DIFF 64→**40**, UNM 1604 | **24 → 0** | **0 → 0** | 1 (the `build` span cell; its block IS at golden's span) |
| Scoreboard | SAME 3098→**3122**, DIFF 65→**41**, UNM 1608 | **24 → 0** | **0 → 0** | 1 (same cell) |
| BuildUVMPkg | SAME 3371→**3395**, DIFF 49→**25**, UNM 1752 | **24 → 0** | **0 → 0** | 1 (same cell) |
| SeqDriver | SAME 3943→**3969**, DIFF 83→**57**, UNM 1628 | **26 → 0** | **0 → 0** | 1 (same cell) |

The report audits SimpleUVM only; **the other three agree, cell for cell**. I
also swept the **UNMEASURED** bucket for the failure mode my v1 arm exposes — a
block on an object key golden does not carry — and in the whole corpus it returns
that single `uvm_reg_indirect_data::build` cell, whose `begin` golden has at the
identical span (`golden=1 patched=1`). **No hidden over-fire anywhere in the
corpus.**

Of the 40 remaining SimpleUVM DIFF cells, **39** have a body block on BOTH sides
at different spans (the second-item-anchor / macro-loc family) and **1** is a
statement-KIND difference (`uvm_algorithmic_comparator` golden
`method_func_call@131:10` vs our `hier_path@131:5`). None involves emptiness.
The report's "all SPAN or macro-loc" is right for 39 of 40.

---

## 7. FINDINGS

Numbered, each with the command that produced it.

**F1 — LATENT OVER-FIRE on the § 46 family (the only finding with teeth).**
`§ qualifiedLifetimeMethodLosesNamePortsBody46` nulls the body at
`TaskFuncEmit.cpp:5213` **without inspecting it**, so § 65's stated safety
argument ("every dropped body has items") does not hold for it: 6 arm cells mint
an empty `begin` (30 dump lines) that golden has **nowhere**, on stub objects
whose own name § 46 deliberately truncates. **0 corpus sites** (16 193 files) and
**0 corpus movers**, so no shipped byte is wrong; but the comment states a
property the code does not have, and the fix is one existing local
(`!qualLifetime46`).
`ct65arm.sh v1_qualdrop.sv` + `python3 ct65cells.py` + `grep -E '^\+.*\\_begin:' d.diff`
+ `python3 /tmp/v65_res_census.py ~/git-repos/Surelog/{tests,third_party} ~/git-repos/uhdm2rtlil/test`

**F2 — LATENT UNDER-FIRE: `items.empty()` is not golden's rule.** Golden emits
the block for a **NON-ANSI**-ported empty labelled subroutine
(`task t; input int a; endtask : t`) — 4 arm cells (r01/r02/r15/r16), golden
`begin*E`, ours `-NONE-` before and after. Port declarations ARE `items`. The
law's term should read "no statements and no data declarations, non-ANSI ports
allowed"; `v4_items` shows the gate is otherwise correctly conservative on five
further item kinds (import, static decl, event decl, localparam, two null
statements). **0 corpus sites.**
`ct65arm.sh v3_ports.sv` / `ct65arm.sh v4_items.sv`

**F3 — PATCH HYGIENE: `canaries.sh` ships mode 100644.** Every other script in
the patch is 100755; this one is not, so `./canaries.sh` fails with *Permission
denied* and the durable record's own instructions do not run as written. The
implementer's numbers are unaffected (I reproduce them with `bash canaries.sh`),
and the same file is 100755 in `r10uvm62repro` and `r10uvm64repro`.
`grep -E '^new file mode' /tmp/r10uvm65.patch | sort | uniq -c` → 5 × 100644, 12 × 100755

**F4 — REPORTING: the determinism flake is symmetric, not "worse on pristine".**
The report reads 2 hashes patched / 3 pristine from 3 reps and concludes the
flake is worse on the pristine binary. At **7 reps each I get 3 distinct hashes
on BOTH**. The load-bearing half — size stable within each binary, delta stable
across designs — reproduces exactly.
`detcheck.sh <bin> 3` then `detcheck.sh <bin> 4`, in
`~/git-repos/Surelog/third_party/tests/Scoreboard`

**F5 — REPORTING: the offered explanation of the size shrink is refuted at small
scale.** The report attributes −878 bytes to packed capnp being non-monotonic in
content. `writePackedMessageToFd` is real (`UHDM/templates/Serializer_save.cpp:122`),
but on **all seven of my arms the same patch GROWS the database**, ~50 bytes per
added block (b1 +452 for 9 blocks, b2 +549, b3 +716, v1 +830, v2 +279, v3 +690,
v4 +81). So the encoding is monotonic where it can be checked, and the ~2.2 kB of
counter-movement inside an 11 MB database is **unexplained**, not explained. The
report's CONCLUSION survives on better evidence, which I state instead: the
whole-dump multiset shows **REMOVED = 0** on all 7 movers (not one dump line text
disappears anywhere), the dump grows by exactly +135, every added object is
golden-matched, and the cmp head advanced.
`stat -c %s` on the 7 mover pairs and on the 7 arm pairs; `mv65.sh` REMOVED column

**F6 — ENVIRONMENT, for the record: Surelog SEGFAULTS on a body-only `typedef`**
(`function void f(); typedef int t; endfunction : f`, rc=139, no database), so
that item kind cannot be measured against golden at all. Not attributable to this
patch; it cost two planned `v4_items` cells.
`surelog -parse -nocache s02.sv; echo $?` → 139

**F7 — the report's own headline caveat is TRUE and worth keeping.** "Had I
stopped when the head cleared I would have landed a law right about the head and
wrong about 18 of its 25 sites" — I confirm the shipped binary emits 27 blocks
where the discarded "FUNCTION only" gate would emit 7, and that
`uvm_reg_block::readmemh`'s golden block is the counterexample
(`golden=1 pristine=0 patched=1` in my own three-way count). The port-list term
is separated from out-of-body-ness cell by cell in b3 and my v1 q10/q14/q15
reproduce that separation independently.

---

## 8. RANKED RESIDUES (mine, after the patch)

1. **The new head on all three target rows** (262 cmp lines):
   `begin (uvm_pkg::uvm_cause_effect_link::get_link) @255:7-255:29`. Both sides
   have the block; the `Stmts` differ. **Pre-existing and masked** — the
   pristine→shipped dump delta is +135 lines of `begin`/`vpiStmt`/`vpiParent`/
   `vpiFullName` and nothing near this object. A body-block CONTENT law, and the
   best next head on these rows.
2. **F1, the § 46 latent over-fire** — the only place in the corpus-free space
   where this gate is measurably wrong, and a one-term fix. Rank it above the
   span families because it is a WRONG-OBJECT direction, even if currently
   unreachable.
3. **The body-block SPAN family: 39 of the 40 remaining SimpleUVM cells**
   (`uvm_object::compare` golden `1050:3-1050:20` vs ours `1049:3-1049:13`, and
   its 38 siblings) plus the 1 statement-KIND cell
   (`method_func_call` vs `hier_path`). Also 41 / 25 / 57 cells on
   Scoreboard / BuildUVMPkg / SeqDriver.
4. **F2, the non-ANSI under-fire** — 4 cells, miss direction, no corpus site.
5. **The FUNCTION's own span when `virtual` leads** (b1 c24, b2 d09/d10,
   `uvm_reg_indirect_data::build`): golden collapses onto the `virtual` token.
   This is why 4 of the corpus's added back-reference lines have `golden=0`, and
   the only reason any added text does.
6. **Where an OOB definition LIVES** (golden: design `Task_funcs`, dotted name;
   ours: inside the class) — 51 residual b2 lines.
7. **Listing gaps § 65 furnishes correctly on top of**: the `$unit`-scope ported
   task (b3 e05 — golden emits no object at all, so our 5 added lines sit inside
   an object that is 100% surplus either way, no corpus site) and the **checker**
   scope (v2 x01 — golden has the function AND the block, we emit no function
   object at all).
8. **Golden lists a decl-only body's local var twice** (b1 c17/c21, 4 lines);
   **an initialised body-local becomes a statement in golden and nothing in ours**
   (v4 s07).
9. **F5's unexplained ~2.2 kB of negative size movement** in the large
   databases. Content is provably intact; the byte size is simply not an
   instrument this campaign should quote without the dump beside it.

---

## 9. FILES I ADDED

| file | what it is |
|---|---|
| `v1_qualdrop.sv` | the § 46 / § 27 **body-drop interaction** arm — qualifier × written lifetime × kind × port list × label × oob, 39 cells. **Finds F1.** |
| `v2_views.sv` | the **view-multiplicity** arm — package class, parameterized class ×2 specializations, nested class, module instantiated twice, generate-for ×2, interface-class pure prototype, DPI import, checker. |
| `v3_ports.sv` | the **port-list product** arm — NON-ANSI ports (**finds F2**), default value, `ref`/`output`/`inout`, two ports, unpacked-array port, typedef'd type, `string`, class-handle port, pure-virtual ported task, prototype-carries-ports OOB. |
| `v4_items.sv` | the **item-kind** arm — which `items` entry actually bars the block: import, static decl, event decl, localparam (the `taskBodyPa9` interaction), two null statements, explicit empty `begin end`, initialised decl. |
| `README.verifier.md` | this record |

Sweep workdirs (`/tmp/v65_wd_*`), arm scratch (`/tmp/v65arm_*`, `/tmp/v65_62_*`,
`/tmp/v65_64_*`, `/tmp/v65_v4bisect`) and the big dumps were deleted after
measurement. `/tmp/claude-1000` untouched; slang not patched; `results/*.csv`
only ever read; `git stash` never used; the four fenced tests never dispatched.
