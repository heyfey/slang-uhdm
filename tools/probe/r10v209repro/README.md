# r10v209 — ADVERSARIAL VERIFICATION of r10uvm209 (§ `hoistedLocalKeepsItsLifetime209`)

**MEASUREMENT ONLY.** The official `uhdm-cmp` and `scripts/verify_golden.py` are
the sole authorities. slang was NOT patched; `results/*.csv` were READ-ONLY;
`GOLDEN_DEFER` stayed unset; the four slang-fenced tests were never dispatched
and are not spelled here. **LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

**VERDICT: ACCEPT** — the pass's production diff is unchanged; this directory is
evidence only.

## 1. Bit-for-bit reproduction, from this verifier's OWN worktrees and binaries

Two fresh worktrees at `b14d8969`; both binaries built here
(`cmake -DCMAKE_BUILD_TYPE=Release`, `-j 2`), frozen `chmod 555`,
`SLANG_UHDM` exported explicitly per binary, every `cmds.txt` audited by path.

| claim | verifier's measurement |
|---|---|
| pristine md5 | `ca22259d3130f2ff5b7e6a696f562ef3` — reproduced |
| patched md5 | `526cbd7fa52f03f17ad969c2f1ddcfef` — reproduced from the patch on a fresh `b14d8969` |
| patch md5 | `7189b86a1afc6ff7126f933901643dcf`; `git add -A && git diff --cached b14d8969` regenerates it byte-identically |
| goldens | 23/0 on both binaries; `SLANG_UHDM=/bin/false` → 23 FAIL |
| surelog conversion | reproduced verbatim: `SimpleUVM,{default,testflags}` `CMP_NOTEQUAL` → `CMP_EQUAL`; `default` 473→474 / 8→7, `testflags` 468→469 / 7→6; every other histogram cell flat |
| u2r | 679 / 50 / 2 both modes; `ct8rows` PASS vs committed gate AND vs own pristine; byteverify **0 / 1358** |
| prediction (pristine only) | surelog `VISITED=956 FIRING=4` = `{default,testflags} × {SimpleUVM, SeqDriver}`, `FIRES` 10 / 5 by name; u2r `VISITED=1358 FIRING=0` |
| heads | pristine SeqDriver 112/1, SimpleUVM 86/1, Scoreboard 95/1, MiniAmiq 112/1, BuildUVMPkg/Earlgrey/Rggen 0/0. Patched: SimpleUVM ×2 **86→0, heads 1→0, cmp rc=0**; all others unchanged. The pristine SimpleUVM/default head dump is byte-identical to the shipped `head_pris_SimpleUVM.default.txt` |
| census (9 names × both modes) | `ROWS=16 SKIP-NOFILE=2 UNKNOWN-NAME=0`; **MOVED-WRONG 0, AWAY 0, WRONG→RIGHT 30**; LISTING WRONG 30→0; SimpleUVM 1218→1228, SeqDriver 1366→1371 |
| implementer's grid | CALIB `AGREE 662 / 0 / 0 / 0`; PRIS `572/70/20/0`; PATCHED `622/20/20/0`; `NEW-WRONG-CELLS 0` recomputed by set difference (`move209.py`); 0 nonzero rcs |
| canaries / ctcan2 / canaudit | surelog vs own pristine `ok=50 changed=2` (the two named SimpleUVM rows); u2r `ok=8 changed=0`; ctcan2 PASS ×4; canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | all SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`; `BuildUVMPkg ×2`, `Earlgrey_0_1/testflags`, `Rggen/default` byte-identical and `CMP_EQUAL` at `cmp rc=0` |
| shipped instruments | `byteverify.sh canaries.sh ctcan2.sh ct8rows.sh rowheads.sh canaudit.sh` are byte-identical to the canonical copies; no script hard-codes another pass's `/tmp` path; both `rm -rf`s target caller-supplied variables |

**R5 confirmed independently**: this verifier's own PRISTINE surelog sweep
already differs from the committed `results/golden_surelog.csv` on the
`Earlgrey_0_1 ×2` informational dump column (`differ` → empty), status
`CMP_EQUAL` in all four cells. Environment-borne, not this pass's.

## 2. ONE DISCREPANCY WITH THE PASS REPORT — the byte-mover count

`byteverify SELFCHECK=1` on this verifier's sweeps reads **MOVERS 5 / 956**, not
4. The extra database is `./default/Scoreboard-59431470/slang.uhdm`, and it is
the documented ~50/50 coin (RESUME §9), attributed three ways:

* **order-blind**: `uhdm-dump` both, path-normalised, `sort`ed — 118 raw diff
  lines, **0 order-blind diff lines**. Same multiset, different order.
* **predictor**: `ct209pred` on that PRISTINE database reads `FIRES=0`.
* **same-binary repeat**: the PRISTINE binary alone, run four times on that
  command line, produced `b7e9d26bdeae` ×3 and `125954be7853` ×1.

Its CSV row is unchanged in both columns. The pass's "MOVERS 4/956" was a
lucky read of a coin, not a claim the patch breaks. **The integrator must
expect 4 OR 5 and attribute the Scoreboard cell order-blind.**

## 3. BREAKING THE LAW — ten new arms, both views, real Surelog goldens

`grid209.sh` with this verifier's frozen binaries. Calibration golden-vs-golden
first: `AGREE 616 / 0 / 0 / 0` (arms H–O) and `102 / 0 / 0 / 0` (arms P–Q).

| arm | what it attacks | PRIS → PATCHED WRONG | MOVED-WRONG |
|---|---|---|---|
| `v209_h_nested` | locals in an anonymous `begin`, a named `begin`, a `for` body, **and `static` declared INSIDE a nested block** | 20 → **0** | 0 |
| `v209_i_subr` | an out-of-body **task** and **function** with locals of the hoisted shapes; a class with BOTH an oob `new` and an oob task | 2 → **0** | 0 |
| `v209_j_qual` | every § 26 qualifier/initializer face (`const`, `var`, `= new()`, `= other`, typedef'd, keyword) written as a ctor local, beside its package twin | 7 → **1** | 0 |
| `v209_k_modown` | a module's OWN variables beside a materialised import | 1 → **0** | 0 |
| `v209_l_trans` | the TRANSITIVE clone (p1 → p2 → module), with a `static` hoisted local | 5 → **1** | 0 |
| `v209_m_dyn` | hoisted assoc / queue / dynamic array, plain and `static`, beside package twins | 26 → **12** | 0 |
| `v209_n_modclass` | an out-of-body ctor in a **module-scope** class | 2 → 2 | 0 |
| `v209_o_paramcls` | a **parameterized** class's oob ctor (the default-specialization walk) + an explicit single-symbol import | 7 → **5** | 0 |
| `v209_p_ifprog` | the same materialised import inside an **interface** and a **program** | 10 → **0** | 0 |
| `v209_q_shadow` | a hoisted local with the **SAME NAME** as a package member of the same kind | (in the 10 above) | 0 |

**TOTAL over 20 arm-views: MOVED-WRONG 0, cells FIXED 108, ONLY-OURS 0 → 0.**
No arm regressed on any cell. Highlights read directly off golden:

* arm H: golden and ours agree cell for cell, `lh_anon_static A0`,
  `lh_named_static A0`, `lh_top / lh_anon / lh_named / lh_loop A1` — the law is
  right on `static` inside nested blocks, which no shipped arm covered.
* arm I: golden's package listing carries ONLY the constructor's two locals; the
  task's and function's locals are absent. § 203's distinguisher holds and we
  match it.
* arm Q: the two same-named `shared_h` come out `A0` (package item, net shape)
  and `A1` (hoisted local) in golden AND in ours, per position. The rule keys on
  the declaration, not the name.
* arm P: `lp_h_static A0` in golden's module ELAB listing and in ours; interface
  and program copies agree with the module's.
* arm O: `lo_h A1`, `lo_h_static A0`, `lo_i A1` — the parameterized class's
  hoisted locals carry their own lifetimes.

## 4. WIDE BOUNDARY, re-run here

```
LISTED=5389 PROCESSED=5389 PRODUCED_DBS=5204 MOVED_ARMS=29 RC_DIFFS=0
SCORED views=58 MISSING-ARMS=0 NODB-views=0 TO-GOLDEN=314 AWAY-GOLDEN=0
```

22 movers are the pass's own set, arm for arm; 7 are this verifier's new arms
(`v209_n_modclass` correctly ABSENT — we emit nothing there). Every moved arm
was rebuilt against a REAL Surelog golden in both views: **AGREE never falls,
`ONLY-GOLDEN` and `ONLY-OURS` never rise.**

Fences, checked by name against `BOUNDARY_MOVERS.v209.txt`:

* § 203: only `g203_a_oob` (6→0), `g203_c_mult` (1→0), `g203_d_dump` (2→0)
  moved. `g203_b_cont`, `g203_e_ctl` and the packed-struct fence
  `g203_f_pkstruct` are **absent**.
* § 206 (`grid206/` + `v206arms/`, ambiguous-key fence included), § 205, § 195,
  `buvm3-15`, `sd8-12`: **zero moved**.
* `uvm82-91`: exactly ONE arm, `r10uvm87repro/v87_a3_oob.sv`. Attributed here
  by whole-dump diff: **one added line, `|vpiAutomatic:1` on
  `work@m87a3.l_ctor`** — the law's own object on the law's own field, matching
  golden. Its census AGREE is flat because § 87's pre-existing `logic_var`
  vs `class_var` kind mismatch sits on the same cell.

## 5. RANKED RESIDUES FOUND HERE (all pre-existing on BOTH binaries)

1. **R1 is WIDER than the pass reports.** Not only a package-scope QUEUE: the
   package-scope **dynamic array** is golden-1 / ours-0 too. `v209_m_dyn`,
   golden reads `array_var|pm_q|A1` and `array_var|pm_dyn|A1`, ours `A0`, in
   all four listings (`P:top`, `P:all`, the class copy, the module ELAB copy),
   both views — 12 cells. The associative twin is right. `emitPkgArrayVar`'s
   package-scope split (`aType == vpiAssocArray`) is § 26 not yet generalised
   to `array_var`.
2. **NEW — Surelog hoists a MODULE-scope class's out-of-body constructor locals
   into the MODULE's own variable listing, at `vpiAutomatic 0`.**
   `v209_n_modclass`: golden's elaborated `work@gn209` is
   `pn_h(A0), ln_h(A0), ln_i(A0), mn_obj(A0), mn_i(A0)`; ours lists three.
   `collectOobCtorLocals` is package-only. **TRAP for whoever extends it: the
   value there is 0, not slang's `Automatic` — `compileDataDeclaration`'s
   `is_static = (ModuleDefinition || Program)` is TRUE for a module.** This is a
   second, independent confirmation of § 209's decoded mechanism.
3. **NEW — the module ELAB listing puts an EXPLICIT single-symbol import AFTER
   the wildcard copy; golden puts it FIRST.** `v209_o_paramcls`: golden
   `po_int, lo_h, lo_h_static, lo_i, po_own`, ours
   `lo_h, lo_h_static, lo_i, po_own, po_int`. All five VALUES are right; the
   five WRONG cells per view are the shift alone.
   `collectImportedPkgVars`'s `ExplicitImport` loop runs after the wildcard one.
4. **R2 reconfirmed** — the module hoist does not follow a transitive wildcard
   import (`v209_l_trans`: golden's `work@gl209` lists `pl209a`'s entries, ours
   lists `pl209b`'s own; `ONLY-GOLDEN 4`).
5. **NEW (minor)** — golden types a **typedef'd class handle** declared in an
   out-of-body ctor body as `logic_var`; we emit `class_var`
   (`v209_j_qual`, `cj209t lj_typedef`). One cell per view, kind only.
6. **NEW (code robustness, no measurable effect today)** — in the new
   `!ownPkgMember209` branch of both `emitPackageVar` and `emitPkgArrayVar`
   the inner test is `vs.kind == SymbolKind::Variable`; when that is false
   NOTHING is stamped, because the § 26 test is now in the `else`. Every
   current caller filters to `SymbolKind::Variable`, so it is unreachable — but
   a future caller handing over, say, a `ClassPropertySymbol` would silently
   lose the qualifier rather than fall back.
7. **Measurement note** — Surelog rejects `var <class-type> <name>;` inside a
   subroutine body (`[ERR:UH0701] Unsupported statement`), which is why
   `v209_j_qual` records `rc_surelog=4`. The golden is still produced and the
   arm calibrates clean; that one declaration's cell is not a trustworthy
   measurement.

## 6. FILES

`arms/` ten adversarial arms; `GRID.v209.*.txt` their grid runs (CALIB / PRIS /
PATCHED per arm-view, every rc recorded); `move209.py` the per-cell
MOVED-WRONG / STILL-WRONG / FIXED scorer; `CENSUS.v209.txt` the nine-name
census; `BOUNDARY_MOVERS.v209.txt` / `BOUNDARY_SCORES.v209.txt` the 5389-arm
boundary and the golden re-score of all 29 movers.
