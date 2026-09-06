# r10v169 — the adversarial verification of r10uvm169 (§ `pkgRetParamSubstReachesTheImportCloneDefView169`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of the pass reproduced
bit-for-bit in this verifier's own worktrees, including both binary md5s. Ten
new arms broke one cell of the law: a return that **CALLS** a param-backed
subroutine was pristine-RIGHT and went patched-WRONG in a wildcard clone's
unelaborated listing. One condition fixes it, the fix is measured on every gate,
and it costs the pass nothing — the corpus databases it produces are
byte-identical to the shipped patch's.

Ship `/tmp/r10uvm169.verified.patch`.

**MEASUREMENT-ONLY probes.** Nothing here is an acceptance judge. The official
`uhdm-cmp` and `scripts/verify_golden.py` are the authorities. slang was **NOT**
patched; `results/*.csv` were **READ ONLY**; **no row was converted**;
`GOLDEN_DEFER` was never set. **LHS is ALWAYS golden (Surelog); RHS is ALWAYS
ours**, everywhere below.

| | |
|---|---|
| BASE | `cfb2321f` |
| worktrees | `/tmp/wt_v169` (patched), `/tmp/wt_v169pris` (pristine) — both fresh at `cfb2321f` |
| pristine binary | md5 `196a8dcc6d57a4a2da7f6017d652712d` — **reproduces the pass's md5 exactly** |
| the pass's binary | md5 `ae36c8b5caa51176a4bb77e9f2fec2f2` — **reproduces the pass's md5 exactly** |
| the VERIFIED binary | md5 `9a793239793883a5a8c492897f71a250` — the above **+ one condition** |
| all three | frozen `chmod 555` before any sweep |

---

## 1. What reproduced, independently

Built both binaries from scratch in this verifier's own worktrees and re-ran the
whole battery. Everything the pass claimed came back identical:

| claim | reproduced |
|---|---|
| both binary md5s | **bit-for-bit** |
| goldens | PASS 23 / FAIL 0 on both binaries; `SLANG_UHDM=/bin/false` → FAIL 23 / PASS 0 |
| uhdm2rtlil, both modes | `ct8rows` PASS vs the committed baseline **and** vs this verifier's own pristine sweep; 679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL` |
| surelog 1588 rows | `ct8rows` **0 differing rows** (status AND dump), histogram identical, `CMP_NOTEQUAL` 10 default / 9 testflags, **no row converted** |
| byte movers | surelog **5 / 956** — the four predicted (19 order-blind diff lines each, all one cell) + `Scoreboard/default` at **0 order-blind lines**; uhdm2rtlil **0 / 1358**; SELFCHECK 955/956 and 1357/1358 |
| a-priori census | surelog `rows=956 skipped=617 censusfail=0`, **4** `OURS-REF-GOLDEN-CONST` in exactly the four named databases, **0 AWAY**; uhdm2rtlil `rows=1358 skipped=104 censusfail=0`, **0 cells in any direction** |
| heads | SeqDriver ×2 **50 → 27**, one head, a NEW object; **SimpleUVM 17 unchanged**; every other head cmp log byte-identical |
| R0 | confirmed verbatim — 27 lines, `RHS: <null>`, golden's `Return` `string_var` of `uvm_pkg::uvm_instance_scope` (`uvm_misc.svh:340:10`) |
| canaries | 52/0, 8/0, ctcan2 PASS ×2, `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, the three byte-identical ones SAME |
| the pass's grid | RET **24 TOWARD / 0 AWAY / 4 STILL-WRONG / 31 UNMOVED**, OBJ 0 AWAY — reproduced on the verified binary |
| the boundary arm | `r10uvm120repro/g120_c_homes.sv` re-measured at **6 TOWARD / 0 AWAY / 0 STILL-WRONG** |
| the wide boundary | 4747 arms, `PROCESSED=4747 PRODUCED_DBS=4590 MOVED_ARMS=13 RC_DIFFS=0` — every mover a positive control |
| the pass's "fifth arm is an artefact" | **CONFIRMED**: `r10vrgg3repro/xi_iface_param_type/dut.sv` did not appear in either of this verifier's full boundary runs |
| cmds.txt audit | 1523 surelog + 1458 u2r invocations per binary on all six sweeps, **0 main-tree, 0 worktree-build leakage** |
| the patch file | `git diff cfb2321f` in a fresh worktree regenerates `/tmp/r10uvm169.patch` character-for-character (modulo `index` lines); surface = `src/StmtEmit.cpp` + `tools/probe/r10uvm169repro/`; `results/*.csv` 0 hunks; fence check 0 for each of the four names |

Two of the pass's own framings are worth recording as *confirmed by a second
measurement*, because both are load-bearing and both are easy to get wrong:

* **Scoreboard/default is a coin.** The pass's log records its two md5s with the
  `patched=`/`pristine=` labels the other way round from this verifier's run —
  the SAME two hashes, swapped. That is exactly the signature of a per-invocation
  coin, and the order-blind diff is 0 lines in both runs.
* **The cmp line count is DEPTH.** Two of this verifier's arms grew their line
  count under the patch (`m_export` 50→62, `n_collide` 1334→1376) and NEITHER is
  a regression: on `m_export` the head **moved to a different object** (a
  pre-existing `vpiSize` omission on an interface's wildcard-imported string
  parameter, `work@if169m.sm169`, verified byte-identical on both binaries), and
  on `n_collide` the head object is unchanged and the +42 lines are entirely the
  folded constants the pass ADDS, which golden also holds.

---

## 2. THE BREAK — § `pkgRetClonedCallFoldIsGoldensFuncCall169v`

**A RETURN THAT *CALLS* A PARAM-BACKED SUBROUTINE IS GOLDEN'S `func_call` IN A
WILDCARD CLONE'S UNELABORATED LISTING. ONLY THE BARE PARAMETER READ FOLDS
THERE.**

Arm O (`v169_o_nonparam.sv`), inside a wildcard-imported package:

```systemverilog
function int f_ko169();     return ko169;      endfunction   // the BARE read
function int f_callp169();  return f_ko169();  endfunction   // a CALL to it
```

Measured **per listing** (`listcheck.py` splits the `uhdm-dump` at its top-level
`\_package:` headers, so the `AllPackages` and `TopPackages` listings of one
package are never merged into a multiset):

| object | run | golden | pristine | the pass as shipped | VERIFIED |
|---|---|---|---|---|---|
| `p169io::f_ko169` | def | `{constant, constant}` | `{ref_obj, constant}` | `{constant, constant}` ✓ | `{constant, constant}` ✓ |
| `p169io::f_ko169` | elab | `{constant, constant}` | `{ref_obj, constant}` | `{constant, constant}` ✓ | `{constant, constant}` ✓ |
| `p169io::f_callp169` | def | `{func_call, func_call}` | `{func_call, constant}` | `{constant, constant}` ✗ | `{func_call, constant}` ✓ |
| `p169io::f_callp169` | elab | `{func_call, constant}` | `{func_call, constant}` | `{constant, constant}` ✗ | `{func_call, constant}` ✓ |

The first listing of `p169io::f_callp169` **matched golden on the pristine
binary and stopped matching under the patch**, in both runs. The second listing
is the `pkgTopEmit` one and is § `pkgRetParamSubstIsRhsClone120`'s pre-existing
over-fold — untouched here, as it should be.

**Why the pass's three fences do not reach it.** § 169 fenced the `foldedRet`
read, the `foldedRet` write and the literal arm to `pkgTopEmit`. But
`resolveConstExpr` (`src/ModuleEmit.cpp:24826`) dispatches a `Call` to
`constCallFold`, which reports **both** `cf.directSub` **and** `cf.param` — so
the PARAMETER-SUBSTITUTION arm, the one § 169 widens, catches the call first and
the fenced `foldedRet` arm is never consulted.

**The fix — one condition, `src/StmtEmit.cpp`:**

```cpp
if (fp120 && direct120 && (pkgTopEmit || !cf.directSub)) {
```

`cf.directSub` is non-null **exactly** when the returned expression is a call: a
bare `NamedValue` parameter read leaves it null (`resolveConstExpr`'s
`NamedValue` arm sets only `lit`/`param`/`site`). So the widened half now folds
the bare read and nothing else, and the call fold stays `pkgTopEmit`-only like
the other three arms.

**What the fix costs: nothing.**

* the pass's own four arms re-scored on the verified binary: RET **24 TOWARD /
  0 AWAY / 4 STILL-WRONG / 31 UNMOVED** — *identical* to the pass's claim;
* `r10uvm120repro/g120_c_homes.sv`: **6 TOWARD / 0 AWAY**, identical;
* all ten of this verifier's arms: *identical* RET and OBJ totals, except arm O,
  whose STILL-WRONG drops from 2 to 0;
* the four predicted corpus movers carry the **same md5** on the shipped and the
  verified build (`ec08740916fc`, `f464a73846a6`, `48d70aa95909`), all seven
  head cmp logs are byte-identical, and every gate is green again.

---

## 3. THE TEN ARMS

Every arm compiled by `~/git-repos/Surelog/build/bin/surelog` and by both
binaries in BOTH views, every command and rc in the arm's own `cmds.txt`, the
Surelog "units compiled" list printed so an arm that compiles to nothing cannot
read green. Full scores in `GRID.r10v169.txt`.

| arm | the face it breaks | RET (pristine → VERIFIED) |
|---|---|---|
| `v169_e_shadow.sv` | a FORMAL, a LOCAL and a `const string` LOCAL each carrying a package parameter's name, in a clone | 10 TOWARD / 0 AWAY — golden folds all of them; § 120's name-keyed half is right in the clone too |
| `v169_f_foreign.sv` | a QUALIFIED `pkg::P` read, a WILDCARD-visible foreign parameter, and a CHAINED import (importer-of-an-importer) | 14 TOWARD / 0 AWAY / 4 STILL-WRONG / 6 UNMOVED |
| `v169_g_control.sv` | recursion, two returns in one function, a `case` return, a void function's `return;`, a task's `return;` | 4 TOWARD / 0 AWAY — and the arm goes **CMP_EQUAL** under the official judge in the elab view (50 lines → 0) |
| `v169_h_types.sv` | return type NARROWER / WIDER than the parameter, and `int'()`, `real'()`, `string'()` casts | 10 TOWARD / 0 AWAY — every cast UNMOVED in home and clone, both views (correctly fenced) |
| `v169_i_multi.sv` | THREE wildcard importers of ONE home — the `foldCloneTs` shared-key hazard | 12 TOWARD / 0 AWAY; no object collapse, and each listing's typespec carries `vpiInstance = the HOME package`, which is golden's |
| `v169_k_rhsform.sv` | parameters whose DEF-view Rhs is an OPERATION, a CHAIN, a CONCATENATION or `$clog2` | 8 TOWARD / 0 AWAY / 4 STILL-WRONG |
| `v169_l_class.sv` | a STATIC method, an out-of-body method over a CLASS-scope localparam, a parameterised class | 6 TOWARD / 0 AWAY — in-body and static methods correctly untouched |
| `v169_m_export.sv` | `export p::*`, and an INTERFACE's wildcard import | 4 TOWARD / 0 AWAY — an interface produces no clone listing, as it must not |
| `v169_n_collide.sv` | the importer declares a parameter AND a function whose names are the home's | 6 TOWARD / 0 AWAY — **no cross-listing splice**: the clone folds the home's `23`, never the importer's `99` |
| `v169_o_nonparam.sv` | enum member, `const` variable, plain variable, literal, negated literal, string literal, a CALLED sub, a CALLED PARAM-BACKED sub | **the break above**; 2 TOWARD / 0 AWAY / 0 STILL-WRONG on the verified binary |

Totals over the ten arms on the verified binary: RET **BOTH-RIGHT 144, TOWARD
76, AWAY 0, STILL-WRONG 12, UNMOVED 52**; OBJ **AWAY 0 in every arm**. The
official `uhdm-cmp` was run on every arm in both views: the verified binary is
never worse than the pristine one anywhere, and `g_control`'s elab view becomes
`CMP_EQUAL`.

---

## 4. RESIDUES THIS VERIFICATION ADDS, RANKED

Every one has **zero corpus witnesses** (the a-priori census reports 0 cells in
either direction outside the four predicted ones, in both corpora).

1. **A HOME PACKAGE THAT ITSELF WILDCARD-IMPORTS ANOTHER PACKAGE FOLDS ITS OWN
   `AllPackages` LISTING TOO — and we do not.** Arm F `p169hf2::f_wild169` and
   `f_wilds169`: golden holds `{constant, constant}` in the def run where we hold
   `{constant, ref_obj}`, UNMOVED on both binaries. Same shape as § 169's law one
   step further out (`importPackage` puts the foreign `param_assign`s into the
   importer's own component, so `getValue` answers in the unelaborated view as
   well). **4 cells, the cleanest next widening of this family.**
2. **The `pkg::NAME` qualified read now folds in the clone carrying a
   `ref_typespec` golden does not have.** Arm F `f_qual169`: golden is
   `constant … TS=<none>` (§ 120's residue R5 — `paPackage_scope` answers from
   `pack->getValue()`), ours is `constant … TS=int_typespec`. The KIND is fixed,
   the typespec is a new residue in a second listing. 4 cells.
3. **An OPERATION- or CONCATENATION-initialised parameter's fold carries a
   `vpiDecompile`, a typespec and the WRONG `vpiConstType`.** Arm K: golden's
   `parameter string sk169 = {"ex","wye"}` folds to `DEC=<empty> TS=<none> CT=6`
   and `parameter bit[7:0] ve169 = {4'hA,4'h5}` to `DEC=<empty> TS=<none> CT=3
   BIN:10100101`; ours are `DEC=exwye TS=string_typespec` and `DEC=165
   TS=bit_typespec CT=9 UINT:165`. This EXTENDS the pass's residue R3 (`real`
   and a typedef'd vector) with a **concatenation** face and a **`vpiConstType`**
   face it did not name. Pre-existing in the home's elaborated listing on the
   pristine binary; the pass replicates it into one more listing and introduces
   no new wrong value.
4. **Golden reads the IMPORTED home's value for the importer's OWN
   same-named parameter.** Arm N `p169in::f_in169`: the importer declares
   `parameter int kn169 = 99` after `import p169hn::*`, and golden's fold reads
   **23**, the home's. Ours reads 99. UNMOVED on both binaries, pre-existing —
   Surelog's `getValue` walks `getParam_assigns()` and the imported entry is
   first. A clean distinguisher for whoever owns § 120 next.
5. **Golden DROPS a function the importer declares whose name collides with a
   wildcard-imported one.** Arm N `p169in::f_dup169` at `18:28`: golden's
   listing has no such object at all; we emit it. UNMOVED, pre-existing.
6. **The interface `vpiSize` omission arm `m_export` unmasked.** Fixing the
   export-package clone's fold advanced that arm's head onto a pre-existing
   defect: golden's `work@if169m` `param_assign` constant for the
   wildcard-imported `sm169` carries `vpiSize:16`, ours carries none — identical
   on both binaries.

Confirmations of the pass's own residues on faces it did not have:

* **R5** (a nested-window clone return's `ref_obj` `Actual_group`: golden
  `<null>`, ours the bound `constant`) now measured on recursion, `case`, `if`
  and a post-declaration `if` — 9 UNMOVED cells in arm G.
* **R2** (the class_defn's own copy of an out-of-body body) reproduced in arm L,
  plus a new face: an out-of-body method over a **class-scope localparam**
  (`m_oobc169`), UNMOVED in the elab view.

---

## 5. HOW TO REPRODUCE

```bash
g++ -O2 -std=c++17 ../r10uvm169repro/ct169cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct169cen

for a in e_shadow f_foreign g_control h_types i_multi k_rhsform l_class \
         m_export n_collide o_nonparam; do
  bash ../r10uvm169repro/grid169.sh v169_$a.sv <pristine bin> <verified bin> \
       /tmp/g/$a $PWD/ct169cen
  python3 ../r10uvm169repro/score169.py /tmp/g/$a/cen.{g,a,b}.txt RET
  python3 ../r10uvm169repro/score169.py /tmp/g/$a/cen.{g,a,b}.txt OBJ
done

# the PER-LISTING instrument that convicted the call fold: it splits a
# uhdm-dump at its top-level package/class/module headers, so a package's
# AllPackages and TopPackages listings are never merged into one multiset.
uhdm-dump /tmp/g/o_nonparam/b_def.uhdm > o.dump
python3 listcheck.py o.dump 'p169io::f_callp169'
python3 listcheck.py o.dump 'p169io::f_ko169'

# the wide boundary, over a COPY of the probe tree, on an IDLE machine
PRIS=<pristine bin> PATCHED=<verified bin> \
  bash ../r10uvm169repro/bound169.sh <probe-tree copy> /tmp/bnd
```

Artifacts kept here: `VERIFIED.r10v169.txt` (every gate), `GRID.r10v169.txt`
(all ten arms plus the pass's four and the boundary arm), `BOUNDARY.r10v169.txt`
(both 4747/4748-arm runs), the ten arm sources and `listcheck.py`.
