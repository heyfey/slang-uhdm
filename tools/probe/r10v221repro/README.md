# r10v221 — ADVERSARIAL VERIFICATION of r10uvm221, § `uninstIfaceEnumConstNoActual221`

**VERDICT: ACCEPT.** Every headline number in the implementer's report
reproduced bit-for-bit on binaries I built myself, and every decline face I
could construct held. **No pristine-right → patched-wrong cell was found on any
legal SV I could write**, so no fix was needed and no
`/tmp/r10uvm221.verified.patch` is shipped: `/tmp/r10uvm221.patch` stands as
delivered.

Worktrees `/tmp/wt_v221` (patched) and `/tmp/wt_v221pris` (pristine), both at
`f8062cfc`. Scratch `/tmp/v221_*`. Nothing outside those was written.

---

## 1. REPRODUCTION — the patch, and both binaries

`/tmp/r10uvm221.patch` (md5 `9193160f604f5b16b1f4bfd05c723528`) applies to a
FRESH `f8062cfc` at rc=0 with no fuzz. Production surface is exactly the
declared two files, **+54/−1**, of which the code is ONE term:

    !defGenProcessEmit &&   ->   !defGenProcessEmit && !uninstIfaceSubBody218 &&

Built independently, `-j 2`, Release, same compiler as the main tree:

| binary | md5 | note |
|---|---|---|
| pristine `f8062cfc` | `3165257bc467b3720b4558c24fa4b87b` | **byte-identical to the main tree's `build/slang-uhdm`** |
| patched | `769b69341dc3d59dab592c3fa80c4983` | **byte-identical to the implementer's gated binary** |

Both frozen `chmod 555` at `/tmp/v221_bin/` BEFORE any sweep. `SLANG_UHDM` was
exported explicitly per binary and **every `cmds.txt` was audited by binary
PATH**: 1523/1523 surelog and 1458/1458 u2r invocations name my frozen binary,
and a search for any other `slang-uhdm` path (excluding `slang-uhdm-goldens/`)
returns **nothing**. No main-tree leak.

Collateral scan: `results/*.csv` untouched, no `scripts/`, `tests/` or foreign
probe dirs in the patch, no `rm -rf` on shared scratch, no driver hard-coding
another pass's paths. The four slang-fenced names appear in **0** patch files.
`GOLDEN_DEFER` stayed unset.

## 2. THE DECODE, CHECKED AGAINST REAL SURELOG SOURCE

Every producer fact in the implementer's decode is true of
`~/git-repos/Surelog`:

* `lateBinding`'s last resort at **UhdmWriter.cpp:3951-3961** — `mod->getValue(name)`
  answers and Surelog `MakeEnum_const()`s a fresh loc-less constant, sets
  name/value/decompile/size and `VpiParent(ref)`, then `ref->Actual_group(c)`.
  Read it; it is verbatim as described.
* **Every** `lateBinding` call site: `:1302/:1304` (writePackage), `:1575/:1623`
  (writeModule), `:2071/:2072` (writeElabProgram), `:4785` (writeInstance,
  gated `if (mod && netlist)`), plus two commented-out ones at `:1066/:1067`.
  **`writeInterface` (1626-1794) contains none** — I grepped its whole body.
* `writeProgram` (1795-1900) likewise contains none, which is the implementer's
  R1 and my arm `v3_muststay` confirms it behaviourally.

**The gate is the right one.** `uninstIfaceSubBody218` is raised at exactly one
site, ModuleEmit.cpp:28656-28663, under `bool uninst9 = defAllInstCount[&def] == 0`
— *an interface no instance elaborates*, not merely *an interface definition*.
That distinction is load-bearing: an INSTANTIATED interface's def-view listing
shares its subroutine objects with the elaborated view, which `writeInstance`
DOES late-bind, so golden binds there. Arm `v1_inst` measures exactly that.

**Remove-only is structural, not merely observed.** The mint sits inside the
`else if (suppressRefActual)` branch (ExprEmit.cpp:17649), and the *other*
enum binder — the shared-object bind at `:18270` — is a sibling `else if` in
the same chain, unreachable whenever `suppressRefActual` is true. So in an
uninstantiated interface body the declined mint is the ONLY enum binder, and
the two blocks that follow it re-bind a bare ref only for
`activeForVars` (iterators) and `SymbolKind::Variable` — neither can be an
`EnumValue`. Nothing downstream re-binds what this term declines.

## 3. MY OWN ARMS — 10 arms x 2 golden views, EVERY rc recorded

`vgrid221.sh` builds golden in BOTH views (`-parse`, `-parse -elabuhdm`) plus
both binaries per arm, reads the arm list on fd 3 with children `</dev/null`,
keys scratch on the relative path, asserts PROCESSED == LISTED and **fails the
grid on any non-zero rc** — an arm whose compile fails teaches error recovery,
not golden. Final run: **LISTED=10 PROCESSED=10 FAILED=0**, all 40 cells rc=0.

Scored with `vcen221.py` (mine, written independently) and cross-checked
against the implementer's `cen221.py` on the same dumps.

| arm | what it attacks | result |
|---|---|---|
| `v1_inst` | **INSTANTIATED interface**, 2 instances, 22-cell body | 25/25 SAME both binaries both views; **13 enum actuals bound in golden AND ours, unmoved**; dumps content byte-identical |
| `v2_uninst` | the law's own face, 20+ contexts | golden binds **0**; pristine 16 → patched 0; **toward=16 away=0** |
| `v3_muststay` | **uninstantiated MODULE**, instantiated module, package, program, class | **pristine and patched identical cell for cell, both views**; dumps content byte-identical |
| `v4_r5iter` | §218 R5 — iterators interleaved with enum consts | 6 enum cells decline, **all 8 iterator cells keep their `int_var`** |
| `v5_shadow` | cross-enum + a local var shadowing an enum member; same names in 3 holders | only the uninstantiated holder's 5 move; patched enum-actual count **equals golden exactly** (7) |
| `v6_nonsubbody` | enum refs OUTSIDE subroutines in an uninstantiated interface | 2 of 7 move — **see residue V-R2** |
| `v7_window` | §218's admitted method-window cells beside enums | 5 enum cells decline, the 5 window cells unchanged |
| `v8_modport` | the `InterfaceModPort` canary face in miniature | uninstantiated holder's 5 decline, **instantiated holder's 5 stay bound** |
| `v9_instshape` | **the dangerous direction**: generate-loop, interface ARRAY, child-module nesting | all 10 enum actuals stay bound; **dumps content byte-identical**; `defAllInstCount` misses no shape |
| `v10_qualified` | the implementer's R2 (`::`-qualified enum) | moves EXTRA→NEITHER, **never AWAY**; golden has no ref_obj key there at all |

**Across all 20 arm x view cells: AWAY-GOLDEN = 0, and MISSING-OURS is
IDENTICAL between pristine and patched in every single cell.** No cell that
golden binds became unbound.

## 4. THE FOUR FOREIGN MOVED ARMS, SCORED AGAINST REAL GOLDENS

Wide boundary over the whole probe tree (my own run):
**LISTED = PROCESSED = 5533, RC_DIFFS = 0, MOVED_ARMS = 28.** Twenty are
positive controls — 8 the implementer's `grid221` arms, 12 my own — leaving
**four distinct foreign arms x 2 views**, which I rebuilt against real Surelog
goldens and scored:

| arm | cell | golden | pristine | patched | verdict |
|---|---|---|---|---|---|
| `r10uvm218repro/grid218/a1_iface` | `E218_A` 33:28 | BARE | `enum_const` | BARE | TOWARD |
| `r10uvm218repro/grid218/a2_window` | `Q218_A` 33:18 | BARE | `enum_const` | BARE | TOWARD |
| `r10v218repro/arms/b1_kinds` | `P1V_A` 52:18 | BARE | `enum_const` | BARE | TOWARD |
| `r10buvm13repro/v2_reach13.sv` | `IE13_B` 14:43 | BARE | `enum_const` | BARE | TOWARD |

**TOWARD-GOLDEN 8 / AWAY 0 / NEITHER 0**, MISSING-OURS unchanged in all eight.
Each arm moved exactly one enum cell. **No §220 arm (6 present, 0 moved), no
§216 arm (6 present, 0 moved), no uvm82-91, no sd8-12**; buvm3-15 moved only
`buvm13/v2_reach13.sv`. §218's `a2_window` keeps all five R5 iterator cells
bound to their `int_var` on both binaries — `i218` 42:26 / 42:36 / 44:20 and
`j218` 48:26 / 48:38, verified individually.

## 5. GATES — reproduced independently, all green

| gate | result |
|---|---|
| goldens, pristine | **23 PASS / 0 FAIL** |
| goldens, patched | **23 PASS / 0 FAIL** |
| `SLANG_UHDM=/bin/false` negative control | **0 PASS / 23 FAIL** |
| u2r counts, both binaries both modes | **679 / 50 / 2** |
| u2r `ct8rows` vs committed, vs my own pristine tf, vs my own pristine def | **0 differing ROWS** x3 |
| u2r `byteverify` SELFCHECK=1 | **MOVERS 0/1358**, PATH_SETS_IDENTICAL, SELFCHECK 1357/1358 |
| surelog counts, both binaries | **476/5 default + 470/5 testflags** — the stated baseline |
| surelog `ct8rows` vs committed AND vs my own pristine | **0 differing ROWS over 1588**, status and dump columns |
| surelog `byteverify` SELFCHECK=1 | **MOVERS 2/956**, PATH_SETS_IDENTICAL, SELFCHECK 955/956 |
| canaries | surelog **ok=52 changed=0**, u2r **ok=8 changed=0** |
| ctcan2 | PASS x2 |
| canaudit | **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs | InterfaceModPort **SAME both modes**, BlackParrotComplex SAME, YosysOldOr SAME, SVSwitch **`4842211c4030`**, YosysVerx **`6ccda350c24a`** |
| the NINE CMP_EQUAL row-modes | all **CMP_EQUAL**, rows **byte-identical across pristine / patched / committed** |

**NO CONVERSION, and none was expected** — `results/*.csv` was never edited.

**The movers were predicted BY NAME from my own pristine databases before the
patched binary touched a corpus.** Re-running `predict221.sh` on my pristine
workdir: surelog **6 of 1573** row-modes carry an uninstantiated-interface
candidate (all naming `svaunit_vpi_interface`), of which **exactly 2 FIRE** —
`MiniAmiq/default` and `MiniAmiq/testflags`, cells=16 each; the other four
(AmiqSimpleTestSuite x2, Monitor x2) are SLANG_REJECT with no database.
u2r: **0 of 1462**. Measured movers: **exactly those two**.

## 6. THE HEAD, BEFORE AND AFTER

Before (my own pristine sweep): **MiniAmiq x2 = 19 lines / 1 head**, everything
else 0/0, `SKIP-NOFILE` on Scoreboard/tf and Rggen/tf as expected. The object is
`LHS: <null>` against our `enum_const (SVAUNIT_START)` parented on
`ref_obj … get_state_from_reason.SVAUNIT_START` @`svaunit_vpi_interface.sv:155:20`
— uvm220's R0 verbatim, and the `LHS: <null>` mirror confirms OURS carries the
extra object, so DECLINING is the correct direction.

After: **MiniAmiq x2 = 152 lines / 1 head**, the two logs byte-identical,
`grep -c '^LHS:'` = **1**, and `SVAUNIT_START` appears **0** times in the cmp.
The rise 19 → 152 is the new head object's decompile size, not distance.

Whole-dump diff of the moved database (1.89M lines, ids and workdir
normalised): **0 added, 144 removed**, and all 144 classify as
**16 cells x 9 lines** — 16 `|vpiActual:`, 32 `\_enum_const:`, and 16 each of
`vpiSize` / `vpiParent` / `vpiName` / `vpiDecompile` / `UINT` / `\_ref_obj:`.
**0 unclassified.** `enum_const` lines 4236 → 4204 = exactly the 32 removed.
The whole `uhdmallPackages` region is **byte-identical between the binaries**
(same line span, md5 `86e7fe39ebb78a7568164b516c7cfff0`): nothing shared was
orphaned, re-parented or moved.

## 7. MEASURE THE MEASURER — a bug in MY scorer, not theirs

Worth recording because it nearly produced a false AWAY. Scoring
`buvm13/v2_reach13.sv`, my scorer reported golden binding `io_decl(v)` at
`IE13_B` 14:43 and **MISSING-OURS rising 15 → 16** — which would have been a
regression. It was wrong twice over:

1. A ref prints its `|vpiParent:` as a nested `\_kind: (name)` line exactly the
   way it prints its actual, so "record every nested kind" read the PARENT as
   the actual. Golden in fact leaves that ref **BARE**; the `io_decl(v)` is its
   parent.
2. My fix then left a duplicated `j += 1`, so the field walk skipped every other
   line and stopped seeing actuals at all.

Fixed, my scorer agrees with `cen221.py` cell for cell, and the cell is
**TOWARD-GOLDEN**. The implementer's score was correct throughout. Their
`ARMSCORE` also honestly flags `[GOLDEN-RECOVERED-ERRORS grc=4: 1 errors]` on
that arm — good hygiene, since that arm's Surelog compile does carry one
unrelated `EL0514` error.

One measurer note on `cen221.py`, not affecting any result: given a
fullname prefix that matches nothing it prints all-zero counts rather than
failing, so its prefix argument must be spelled `work@<name>`.

---

## 8. RESIDUES, RANKED

**V-R1 — a pre-existing SEGFAULT, both binaries, unrelated to this pass.**
An interface **with a port list** in a design with **no top-level module**
crashes `slang-uhdm` at rc=139. Minimal repro, identical on pristine
`3165257b` and patched `769b6934`:

    interface a_if(input logic clk);
      logic [2:0] st;
    endinterface

No enum, no function, no package needed; removing the port list OR adding any
top module makes it compile. This bit three of my arms before I added tops.
It matters beyond tidiness: `verify_golden.py` records rc=139 as
**SLANG_REJECT wearing the last stderr warning**, so this crash is invisible in
the corpus tables — a row that should read as a crash reads as a rejection.
Not this pass's business, but it deserves its own pass.

**V-R2 — the law is UNDER-APPLIED relative to its own decode.**
The decode is about `writeInterface` as a whole: it calls `lateBinding`
NOWHERE, so *every* enum reference in an uninstantiated interface should be
golden-bare. But the flag is raised only around `emitTaskFuncs` — **subroutine
bodies only**. Arm `v6_nonsubbody` measures the gap: golden binds **0** enum
actuals in that holder, pristine minted **7**, patched still mints **5**:

| line:col | cell | context |
|---|---|---|
| 18:28 | `W_Z` | `localparam int LP = int'(W_Z);` — parameter initialiser |
| 21:14 | `W_X` | `assign a = W_X;` — continuous-assign RHS |
| 22:20 | `W_Y` | `assign b = (c == W_Y) ? …` — CA condition |
| 22:27 | `W_Z` | ternary true arm |
| 22:33 | `N_A` | ternary false arm |

This is **not a regression** — pristine was wrong here and patched is wrong the
same way in 5 of 7 cells — and it costs no corpus row today (the MiniAmiq
holder's 16 cells all live in subroutines, and the census closes). But the law
as written is narrower than the fact it decodes. Extending it is a *new* law
needing its own gating, not a widening to be waved through: the continuous-
assign path is exactly where the `inGenScopeCaRhs` / `caEnumSelPos22` /
`genCaLhsSelect22` carve-outs already live, and § `genCaEnumConstNoBind21` is
recorded as MEASURED NEGATIVE for gating that arm. Highest-value next step on
this family.

**V-R3 — three signal refs also stay bound where golden is bare.**
In the same `v6_nonsubbody` holder, the continuous-assign signal refs `a` 21:10,
`b` 22:10 and `c` 22:15 carry actuals golden leaves bare. Pre-existing,
unchanged by the patch, and the variable-half analogue of V-R2.

**V-R4 — the implementer's R0 stands, with their own caveat intact.**
The new MiniAmiq head is golden `func_call: (control_assertion_dpi)` @310:7
versus our `method_func_call: (control_assertion_dpi)` @310:35 — same callee,
same three arguments, same parent `begin`, only the OBJECT KIND differs,
because the first argument is a receiver-qualified call (`a_sva.get_sva_path()`)
and we render the whole statement through the `hier_path`/method arm. Their
note that §218's R1 (`a_sim_time` @383:56) sits inside one of these very
statements and must be re-measured before being treated as separate is correct
and worth carrying forward.

## 9. FILES

* `vgrid221.sh` — my golden grid (both views, both binaries, every rc, fd-3 list, PROCESSED asserted)
* `vcen221.py` — my census (multiset-keyed, tail-cut, actual-vs-parent correct)
* `vresidue.py` — lists cells still EXTRA-OURS after the patch, so an under-application is named
* `arms/v1_inst … v10_qualified` — the ten adversarial arms
