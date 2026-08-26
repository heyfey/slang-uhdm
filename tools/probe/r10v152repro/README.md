# r10v152repro — adversarial verification of r10uvm152 (§ ctorEatenLocalBindsPkgCopy152)

Assembled by the master from the verifier's own scratch: `arms/v152_*.sv` are its nine grid arms, `vcen.py` its independent scorer, `GRID.r10v152.txt` its def-view grid, `boundary/` its wide-boundary summaries. The verdict text follows verbatim.

---

**VERDICT: ACCEPT** — reproduced bit-for-bit; no pristine-right → patched-wrong cell found on any legal SV I could construct. `/tmp/r10uvm152.patch` ships as-is (no `.verified.patch` needed).

## 1. Headline numbers, reproduced independently

Fresh worktrees `/tmp/wt_v152pris` + `/tmp/wt_v152` at `5cfc64a`; both binaries built by me (`-j 2`, sequential), frozen `chmod 555` at `/tmp/v152_bin/{pris,pat}.bin`.

| claim | my measurement |
|---|---|
| pristine md5 `04b111949fb08caa98ad4ac0c8bc3242` | **identical** (and equal to the main-tree control binary at the moment I checked) |
| patched md5 `502f483f715b5612dea9cc3367e59f70` | **identical** |
| patch applies clean on fresh `5cfc64a` | `git apply -3` rc 0, 0 `<<<<<<<`, surface = `include/UhdmExporter.h` + `src/ExprEmit.cpp` + `tools/probe/r10uvm152repro/` only; fence check 0/0/0/0; **no `results/` diff target**; shipped `byteverify/canaries/canaudit/ct8rows/ctcan2/rowheads` byte-identical to their originals |
| goldens 23/0, `/bin/false` 0/23 | 23/0 patched, 23/0 pristine, negative control 0 PASS / 23 FAIL |
| u2r 679/50/2 both modes, 0 differing rows | **exact**, vs my own pristine control **and** vs `results/gate_uhdm2rtlil.csv` in my worktree |
| surelog 1588 rows, 0 differing | **exact** (937 CMP_EQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM — no hidden rc=139) |
| byteverify u2r `MOVERS 0/1358` | **0/1358**, SELFCHECK 1357/1358 |
| byteverify surelog `MOVERS 4/956` | **2/956** — only `default/BuildUVMPkg` and `testflags/BuildUVMPkg`, the two PREDICTED. SELFCHECK 955/956 |
| BuildUVMPkg 30 → 45 cmp lines, 1 head, both modes | **exact**; the other **10 of 12** head logs **byte-identical** |
| corpus attribution: 2 substitutions + 30 tail removals | **exact**: dump 1 077 364 → 1 077 334; 40 diff lines; **0 unpaired addition hunks**; the moved cell (`ref_obj (…::rh)` @38768:22 → `class_var (uvm_pkg::rh)`) is now **byte-identical to golden** |
| canaries / pins | ok=52 changed=0, ok=8 changed=0, ctcan2 ×2 PASS, canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort/BlackParrotComplex/YosysOldOr md5 unchanged |
| cmds.txt audit | 3035 files per sweep; every `slang:` line names **only** my frozen binary (2981 pris / 2981 pat); **zero** name `build/slang-uhdm` |

**Correction to a headline:** the implementer's "**4/956** movers (2 predicted + `default/Scoreboard` + `default/SeqDriver` as order-only coins)" does **not** reproduce — my run has **2/956**. Their coin attribution is right; the number is run-specific and should not be carried into a commit message as a durable measurement.

## 2. Breaking the law — my own grid (independent scorer, calibrated golden×3 → RIGHT→RIGHT only)

Nine arms, `/tmp/v152_arms/v152_{a_collide,b_faces,c_homes,d_shape,e_pos,f_clone,g_edge,h_prop,i_iface}.sv`, DEF **and** ELAB, scored by `/tmp/v152_arms/vcen.py` (key = ref line:col; payload = multiset of `kind|target|line:col` — deliberately *not* the implementer's key).

**RIGHT→WRONG = 0 in every arm, every view. 23 WRONG→RIGHT printed in the def grid alone (`/tmp/v152_grid.txt`), plus 7 more in arms F–I. Every one-sided count identical pristine/patched, and 0 unpaired addition hunks in every arm's whole-dump diff.** I also re-scored the implementer's own five arms with my scorer: RIGHT→WRONG 0 everywhere.

The cells that actually test the law rather than confirm it:

- **Name collision + listing order** (`v152_a_collide.sv`): a package that owns `Bee shadow_up;` at line 8 *before* the class. Golden binds the eaten `Zeta::new::shadow_up` and `Yank::new::shadow_up` to **`qcol::shadow_up` @8:7 — the unrelated real package variable**, not either collected copy. Patched matches. Our package `Variables()` order (8, 26, 27, 34, 35, 42, 43, 49) is byte-for-byte golden's, so first-match-wins agrees.
- **A copy contributed by a *different* constructor wins** (same arm, cell c05): `Xray::new`'s eaten `shadow_dn` binds `qcol::shadow_dn` **@35:9 — Yank::new's line-35 local's collected copy** — ahead of both Xray's own eaten decl (42) and the real package var (49). Pristine already had this right via § 148; **patched keeps it** (the risky RIGHT→RIGHT the `tfBodyCtor27` early-return could have broken).
- **Kind mismatch** (`v152_g_edge.sv` g01): eaten `Pin clash;` (class handle) against a package `string clash;`. Golden binds the **`string_var`**. Patched reproduces exactly — name-only matching is Surelog's, confirmed, not a shortcut.
- **§ 148 must-stay** (`v152_b_faces.sv` b07): a paren-less out-of-body **method**'s local `bare_loc` binds the package `facepkg::bare_loc` in golden, pristine and patched alike. **§ 142 must-stay** (b05 `stat_prop`), **block-item local** (b06 `par_loc`) unchanged.
- **§ 81 must-stay** (`v152_e_pos.sv` e20–e23): a package subroutine's formal colliding with a package variable — `io_decl` in the `if` predicate and the `case` condition, package var in the lvalue and the ternary — **golden = pristine = patched, cell for cell**. The `condPredEarlyBound81` lift is inert outside the eaten set.
- **Positions** (same arm): the eaten name moves WRONG→RIGHT in the `if` predicate, `case` condition, `while` condition, a `for`-body `if`, an lvalue, a ternary operand, a call argument, a named-block `if` — and in a **`fork` arm** and a **`foreach` body** (`v152_g_edge.sv` g06/g08). Its non-eaten twin stays RIGHT→RIGHT in all of them.
- **`super.new()` first** (`v152_g_edge.sv` g03): with a nested-block declaration and a same-named package variable present, golden binds the LOCAL and the law correctly does **not** fire.
- **Shapes** (`v152_d_shape.sv`): 1 / 2 / 3 declarators in one declaration (all move, § 144v widening confirmed), a second *declaration* (stays local), initialisers, dynamic array, `int`/`string` kinds, 3 instances of one class — all correct, zero away-moves.
- **Homes** (`v152_c_homes.sv`): package → moves; `$unit`, module, program, interface → **identical before and after** (pre-existing residues; golden's module/interface answers are `logic_net work@…`, which we never mint).
- **Wildcard-import clone** (`v152_f_clone.sv`): both the home package's and the importer's eaten references move **toward** golden; no away-move in either view.
- **Interface / abstract / forward-declared class handles** (`v152_i_iface.sv`): abstract-class handle is a clean WRONG→RIGHT; the **interface-class** handle is a refinement of R1 below.
- **`--single-unit --nobuiltin`** (the corpus flag set) reproduces the arm-A result identically — no flag sensitivity.

## 3. My own wide boundary

`LISTED=4317 PROCESSED=4317 PRODUCED=4171 MOVED_ARMS=14 MOVED_ARMVIEWS=26 RC_DIFFS=0` (`/tmp/v152_bound3/`, 6-way parallel, children `</dev/null`, scratch keyed on the relative path, PRODUCED asserted). My first cut passed `-sv` to our binary, produced **68** databases and printed `MOVED=0` — the PRODUCED counter convicted it, the same trap the implementer documents in `bound152.sh`.

14 movers = 5 implementer arms + 5 of mine (positive controls) + **the same four earlier-pass arms they named**, each re-measured by me against Surelog golden:

| arm | cell | pristine → patched | golden | official cmp |
|---|---|---|---|---|
| `r10uvm144repro/g144_e.sv` | `vc07` @29:48 | local → `p144e::vc07` | `p144e::vc07` | 6640/7048 **unchanged**, 1 head |
| `r10uvm47repro/t65c/dut.sv` | `shared_name` @38:9 | local → `r1::shared_name` | same | 4376/4728 unchanged |
| `r10uvm47repro/t65d/dut.sv` | `dup_name` @22:9 | local → `r2::dup_name` | same | 2720/3040 unchanged |
| `r10v144repro/v144_b_ctor.sv` | `b22x` @70:44 | local → `q144b::b22x` | same | 25212/72248 unchanged |

RIGHT→WRONG 0 and one-sided counts identical on all four, both views.

## 4. Measured findings the implementer's report gets wrong or under-states

**F1 — the R0 framing is wrong, and I have the right decode.** Their §8 says the new head's `RHS: <null>` "names a CONTAINER whose element golden has at a position we do not". Measured: it is the **SINGULAR `ref_obj::Actual_group` overload** (the buvm13/15 pattern), i.e. golden binds and **we are bare**. The reference is `ref_obj (uvm_pkg::uvm_root::new::clp)` @`38789:3` — `clp` is the **class property `uvm_root::clp` declared at `uvm_pkg.sv:38507`**, not a local. Golden late-binds it to `class_var (uvm_pkg::clp)` @`33188:27`, the package copy collected from `uvm_phase::new`'s nested-`begin` block item — first-match-wins across the package listing, exactly the arm-A `shadow_dn` shape. Our package's `vpiVariables` carries that same `clp` at the **identical slot** (dump line 134, both sides byte-identical), so no container mismatch exists there; golden's only other extra `clp` occurrences (dump lines 1088636 / 1088824) are weaklyReferenced-**tail** `class_typespec`s, unreachable to the judge. R0's real statement: *a **class property** referenced inside an out-of-body subroutine at package scope binds a same-named **package** variable in golden; we send it to the §§107/117 hoist pool, which binds nothing when nothing hoists (a package-only compile) and so leaves the reference bare.* My arm `/tmp/v152_arms/v152_h_prop.sv` is a ready-made witness: golden binds `proppkg::gadget` for both an ordinary property (h02) and a `static` one (h03), and for an ordinary out-of-body **method** too (h04); we bind `logic_net work@mprop.*` in all three, pristine and patched alike.

**F2 — R1 needs splitting.** Their R1 says a typedef'd handle "is not bound at the § 81 site at all, so the law leaves it untouched". True for `v152_b_faces.sv` b01/b02 (typedef / specialization → hoist pool, unmoved). **But an interface-class handle *is* bound**, so the law fires and re-points it to *our* package copy: `v152_i_iface.sv` i01, golden's copy is a **`logic_var`** (`ifcpkg::t_first`), ours a `class_var`. The cell was wrong before (wrong name *and* wrong `VpiType`) and is wrong after (wrong `VpiType` only) — `variables::Compare` stops at `VpiType` either way, so **judge-neutral, not away** — but the residue should read "our package copy has the wrong kind wherever Surelog splits by written type", not "the law never touches these".

**F3 — R5 (span) is now visible at newly-bound cells.** A paren-less constructor's ordinary local carries our span (start of declaration) where golden has the declarator's: arm A `qcol::Xray::new::tail_one` ours `43:5` vs golden `43:9`; arm B `facepkg::Second::new::fwd_second` ours `61:5` vs golden `61:16`. Dump-only (no generated `Compare` reads a location), the object's span was already wrong in pristine — but these two cells score "moved-but-not-equal" under any span-carrying census, so the README's R5 entry is load-bearing for the next reader.

**F4 — housekeeping, not the patch.** During my session the **main tree's `build/slang-uhdm` changed** (`04b11194…` → `3b10fa70…`) and `scripts/__pycache__/verify_golden.cpython-311.pyc` appeared there at 20:35. Neither is mine — every one of my 6070 `cmds.txt` lines names `/tmp/v152_bin/{pris,pat}.bin` and I never built or ran in the main tree — but another agent is writing there, and a sweep started from the main tree right now would pick up a different binary.

## 5. Ranked residues (mine, after re-measurement)

1. **R0 (as corrected in F1)** — class-property reference in an out-of-body package subroutine loses to the package listing. Corpus incidence: the BuildUVMPkg head, both modes. Witness `/tmp/v152_arms/v152_h_prop.sv`.
2. **R1′ (as split in F2)** — our package copy is a `class_var` where Surelog mints a `logic_var` (interface-class, typedef'd, specialization handles). Corpus incidence 0.
3. **R3/R4** — module / `$unit` / program / interface homes: golden binds a scope-level copy (`work@mod.<name>`, an implicit net for a module/interface), we emit none and stay bare or bind the local. Corpus incidence 0; unchanged by this pass (`v152_c_homes.sv` h01/h02, h07–h12).
4. **R2** — unpacked array as the eaten element: golden lists a package `array_var`, our package listing drops unpacked arrays. Corpus incidence 0.
5. **R5 (F3)** — paren-less-constructor local span, dump-only.
6. **R6** — ELAB module-hoist clones: golden re-names references inside a clone after the hoisting class; count-for-count unchanged (every `WW-MOVED` cell in my grid is this residual multiplicity and nothing else).

## Evidence (all absolute)

`/tmp/v152_arms/` (9 arm sources + `vcen.py` + `v152arm.sh`), `/tmp/v152_wd/<arm>/` (golden + pristine + patched, both views, dumps and cmps), `/tmp/v152_grid.txt`, `/tmp/v152_bound3/{moved.txt,rcdiff.txt,produced.txt}` + `/tmp/v152_bdrv3.log`, `/tmp/v152_mv/` (the four earlier-pass arms re-measured), `/tmp/v152_wd_{pris,pat}/` (my own sweep controls + CSVs), `/tmp/v152_heads_{pris,pat}/`, `/tmp/v152_buvm_{gold,pris,pat}.dump` + `/tmp/v152_buvm.diff`, `/tmp/v152_bin/{pris,pat}.bin`, worktrees `/tmp/wt_v152` and `/tmp/wt_v152pris`.
