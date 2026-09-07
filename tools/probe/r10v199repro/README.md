# r10v199 — ADVERSARIAL VERIFICATION of r10uvm199 (§ `impUnsizedBasedLhsNoTs199`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's report
reproduces bit-for-bit from fresh `078597b7` worktrees. One narrow
pristine-right → patched-wrong cell was found on legal SV outside the committed
corpus and boundary, and is repaired here by
§ `parenCastWidthLhsKeepsTs199v` — **one extra disjunct**, byte-identical to the
submitted patch on all 5247 committed probe sources and on both corpora.

**MEASUREMENT ONLY.** The official `uhdm-cmp` and `scripts/verify_golden.py`
are the sole authorities. slang was **NOT** patched; `results/*.csv` were
**READ ONLY**; nothing was promoted; **no corpus row converted** in either
direction; `GOLDEN_DEFER` stayed unset; the four slang-fenced tests were never
dispatched (`canaudit` `FENCE-BREACH=0`, and the 5247-source boundary list
contains 0 files whose path carries a fenced name).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `078597b7` |
| pristine | md5 `509209e7d53d55dc7c8b79165aed9f56` — **reproduced**, built from a fresh `078597b7` worktree, `-j 2`, frozen `chmod 555` |
| patched | md5 `e950ec36eb6d946937966eeee18f8642` — **reproduced**, the submitted patch applied to a fresh `078597b7` worktree and rebuilt |
| fixed (shipped) | md5 `5750d99a4df7f0e7a7b225262f6a8763` |
| production surface | `src/ParamEmit.cpp` only, in all three |
| Surelog | `~/git-repos/Surelog/build/bin/surelog` v1.86 (RESUME §9 / the pass's R5: the sv-tests copy calibrates to nothing) |

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Both binaries came out with the exact md5s the implementer reported, from
worktrees this verifier created and configured itself. Then, with
`SLANG_UHDM` exported explicitly per binary and every `cmds.txt` audited by
binary **path**:

| claim | verifier's own measurement |
|---|---|
| goldens 23 / 0, negative control 0 / 23 | **confirmed** on pristine, patched and fixed |
| surelog 0 differing rows vs own pristine | **confirmed**, `PASS: every row byte-identical`, 1588 rows |
| u2r 0 differing rows ×3 | **confirmed** (tf vs own pristine, default vs own pristine, tf vs the committed gate) |
| byte movers 6 predicted rows | **confirmed: 6 / 956**, exactly `{default,testflags} × {SimpleUVM, SeqDriver, MiniAmiq}`. `Scoreboard/default` did **not** move in this run — the same ~50/50 coin RESUME §9 names, landing the other way |
| u2r byte movers | **confirmed 0 / 1358** |
| head: SimpleUVM ×2, 17 → 17, DIFFERENT OBJECT, OTHER SIDE | **confirmed**. Pristine `LHS: <null>` / RHS ours `ref_typespec (work@top.UVM_RADIX) id:179060` on a `parameter` @99:11-99:20; patched `LHS` golden `ref_typespec (work@top) id:120084` on a `constant` @217:31-217:38 → `int_typespec` @217:1-217:38, `RHS: <null>` |
| every other row's cmp log byte-identical | **confirmed**, 10 of 12 cmp logs `cmp -s` identical, incl. `SeqDriver` ×2 and `MiniAmiq` ×2 which ARE byte movers |
| boundary MOVED_ARMS = 20 | **confirmed** over this verifier's own 5247-source list, and the 20 are the same 20 files by name; `g199_g_typed.sv` correctly absent |
| all moved arms move TO GOLDEN | **confirmed**: 40 views, **TO-GOLDEN 174, AWAY-GOLDEN 0**, ONLY-GOLDEN and ONLY-OURS unchanged in every view |
| the FLOOR | **confirmed by family**: uvm196 9, uvm197 6, uvm188 4, uvm187 6, uvm185 5, uvm190 4, uvm170 5, uvm82-91 130, buvm 192, sd 464 — **all listed, all MOVED=0** |
| canaries / ctcan2 / canaudit / protected DBs | **confirmed**: `ok=52` and `ok=8`, `changed=0`; ctcan2 PASS ×2; canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0`; all 10 protected DBs byte-identical, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` |
| the four CMP_EQUAL row-modes | **confirmed** on both columns, patched == own pristine (`ROWMODES.r10v199.txt`) |
| R1 (the `Earlgrey_0_1/testflags` dump cell) | **confirmed as NOT this pass's** — the committed CSV says `CMP_EQUAL,,,differ`, both of this verifier's binaries say `CMP_EQUAL,,,`; STATUS agrees |

---

## 2. BREAKING THE LAW — 13 arms of this verifier's OWN, 15 arm-views, real goldens

`grid_v199/` is written from scratch (not copied from the pass). Every arm is
built by Surelog v1.86 in **both** views and scored by `ctv199` + `score.py`,
which key a cell on `view | ownerkind | ownername | listing | paramname` and
compare the typespec-kind **multiset** — so a slot renumbering cannot hide a
change and a count change cannot masquerade as a value change.
Full table in `GRID.r10v199.txt`.

**The law, at its strongest phrasing, is what golden actually does.** In every
golden here, the `Parameters[i]` entry and the matching
`Param_assigns[i].Lhs` carry the **same typespec value, without a single
exception** (`ASYMMETRY.r10v199.txt`). Ours, pristine, is asymmetric on 30
(view, owner, param) keys across the arms; patched, on **none**. That is the
mirror the pass decoded, measured directly rather than inferred.

| face put under load | golden | pristine → patched |
|---|---|---|
| **typed params MUST KEEP their typespec** (`int`, `string`, `bit [7:0]`, `integer`, `logic [2:0]`, `real`, a typedef'd vector, a typedef'd **enum**, a typedef'd packed **struct**, `localparam int`) — `v199_b_typed` | all keep | **0 cells differ, before AND after**; the two databases are byte-identical apart from the 1-byte output path string |
| **untyped-sized** `8'hab`, **untyped plain-decimal** `13`, decimal-based `'d13`, unbased-unsized `'0`, string literal, real literal, `signed`, `[5:0]`-ranged | all keep except `'d13`/`'0` which golden never gives one | already right, **unchanged** |
| **LOCALPARAMS** — `localparam A_LHEX = 'h1f`, `localparam D_LBIN = 'b1010` vs `localparam A_LDEC = 9` | unsized-based localparam gets **none**; decimal localparam **keeps** | the two unsized-based localparams were wrong on pristine and are **fixed**; the decimal one never moved |
| **the package-side originals MUST NOT change** | — | **0 package cells changed on any of the 13 arms**, `defpkg` and `elabpkg` alike |
| **uvm197's string copy size stamp** | `const/6/sz=56/ref->string_typespec` | identical on golden, pristine and patched, in every listing |
| **the Rhs half** | — | **0 `PA.Rhs` cells changed on any arm** — the patch does not touch the Rhs |
| **DEF vs ELAB** | same verdict in both | both views measured for every arm; the patch's effect is confined to the def-view Lhs clone, exactly as claimed |
| **1 / 2 / 3 instances** | body import 1 copy, file-scope 2, file-scope + body 3 | all three decline together; the copy COUNT never changes the verdict |
| MODULE vs **INTERFACE** vs **PROGRAM** def listings | none in all three | fixed in all three |
| explicit `import p::X;`, incl. an item never referenced | none / none / decimal keeps | fixed; the decimal control does not move |
| re-export chain (`export p::*`) | none | fixed |
| generate-block import | none | fixed |
| child instance parameter override | none | the imported cell fixed |
| **exotic literal forms** — `'sh5`, `'sb101`, `'HFF`, `'h1_2_3` | none | **all four fixed** — signed-based and capitalised unsized literals behave exactly like `'h…` |
| `-G` command-line overrides on an imported param | — | `cliOverridden()` returns false for any package-scope parameter (`ParamEmit.cpp:317`), so `cliOv` is unreachable in this block; measured: with `-G` on a decimal, a typed and an unsized-based import, **only the unsized-based cell moves** |

Nothing in that table is a regression. `v199_h_edge`'s `H_NEG = -'h5` and
`v199_k_override`'s own module parameter `P` stay wrong — they are wrong on the
**pristine** binary too, on both listings, and belong to
§ `implicitUnsizedBasedNoTs102` and to the module-parameter family. `v199_i_chain`'s
residue is R2 multiplicity (golden makes 4 copies of a re-exported param, we
make 2) and is byte-identical on both binaries.

---

## 3. THE ONE THING THAT BROKE — § `parenCastWidthLhsKeepsTs199v`

`grid_v199/v199_l_castw.sv`:

```systemverilog
package vpl;
  parameter L_W = 'h8;                          // UNTYPED, UNSIZED BASED
  parameter logic [31:0] L_VAL = (L_W)'(3);     // ...used as a PAREN-CAST WIDTH
endpackage
import vpl::*;
module vl(input logic clk); ... endmodule
```

and its control `v199_m_ctl.sv`, identical but for `M_W + 1` in place of the
cast.

| cell | golden | pristine | patched | fixed |
|---|---|---|---|---|
| `def work@vl Param_assigns[i].Lhs L_W` (×2 copies) | `ref->int_typespec` | `ref->int_typespec` ✔ | **`NO-TS` ✘** | `ref->int_typespec` ✔ |
| `def work@vl Parameters[i] L_W` | `ref->int_typespec` | `NO-TS` ✘ | `NO-TS` ✘ | `NO-TS` ✘ |
| the same cells with `M_W + 1` instead of the cast | `NO-TS` | `NO-TS` ✔ | `NO-TS` ✔ | `NO-TS` ✔ |

Arm AGREE: pristine 38, patched **36**, fixed 38. Control arm AGREE: pristine
46, patched **48**, fixed 48.

**What it is.** Golden puts an `int_typespec` on an untyped unsized-based
parameter once its own package uses it as a paren-cast width — the control arm
isolates the cast as the cause. Our declaration-side gate
(`implicitUnsizedBasedNoTs102`, `ParamEmit.cpp:4732`) does not know that, so it
over-declines on `up`; pristine's unconditional Lhs attach happened to give the
def-view clone the RIGHT answer, and a bare mirror carries the declaration-side
mistake into a cell that was previously correct.

**How bad it is.** It is judge-unreachable, and provably so, not by luck:

* `scope::Compare` reads `Parameters()` **before** `Param_assigns()`
  (`UHDM/build/generated/src/scope.cpp:345-346`), and whenever this cell can
  regress, the same scope's `Parameters[i]` cell for the same parameter is
  already divergent on **both** binaries — identical predicate, identical
  symbol.
* `design::Compare` reads `AllPackages()` before `AllInterfaces()` and
  `AllModules()` (`design.cpp:296-308`), and the package's own declaration
  carries the same over-decline, so it fires earlier still.
* Measured: `uhdm-cmp` on this arm returns the **same head object** for the
  pristine and the patched binary (the def package's `L_W` typespec).

It is also invisible to the corpus (0 differing rows, movers 6/956 all
attributed) and to the committed boundary (0 of 5247 sources carries the
shape).

**The fix shipped here**, `src/ParamEmit.cpp`, one disjunct:

```cpp
if (up->Typespec() || isParenCastWidthParam(ps.name)) {
```

Every cell it produces is either the pristine value or the mirror value and
never a third one, so it cannot regress anything the pristine binary got right,
and it keeps the whole law everywhere else. Verified:

* **boundary, patched vs fixed: 5247 listed, 5247 processed, 5063 SAME, 184
  NODB, MOVED 0, RCDIFF 0** — byte-identical on every committed probe source;
* **13 verifier arms + 4 grid2 arms: 0 cells differ between patched and fixed**,
  except `v199_l_castw`, which goes back to agreeing with golden;
* goldens 23 / 0; corpus gates re-run (§ 5).

**The real repair belongs at `ParamEmit.cpp:4732`**, where adding
`&& !isParenCastWidthParam(ps.name)` to `implicitUnsizedBasedNoTs102` would
clear all ten of `v199_l_castw`'s diffs instead of two. That is § 102's law,
not this pass's, and it moves the package and elaborated listings as well — a
pass of its own. It is ranked as R0b below.

---

## 4. RESIDUES, ranked (verifier's own)

* **R0b — § `implicitUnsizedBasedNoTs102` does not know about paren-cast-width
  params.** `parameter W = 'h8;` + `(W)'(x)` in the same package: golden gives
  `W` an `int_typespec` in all four listings, we give it none in three of them
  (the fourth is held by the disjunct shipped here). Reproducer:
  `grid_v199/v199_l_castw.sv` with `v199_m_ctl.sv` as the isolating control.
  Fix at `ParamEmit.cpp:4732`; blast radius is the `isParenCastWidthParam`
  name-scan, which is global and name-keyed, so it needs its own corpus sweep.
* **R0c — `-'h5` (a NEGATED unsized based literal) is declined and golden keeps
  it.** Same predicate, wrong on both listings and on the pristine binary;
  `grid_v199/v199_h_edge.sv`, key `H_NEG`. Concatenations, ternaries and
  `'hff + 1` are all already right.
* **R1 — the `Earlgrey_0_1,testflags` dump-column cell.** Confirmed present on
  the PRISTINE binary, so not this pass's; `results/*.csv` untouched. The
  master's call whether to refresh the informational column.
* **R2 — the re-export MULTIPLICITY residue is reproducible in miniature.**
  `grid_v199/v199_i_chain.sv`: golden's def-view Param_assigns listing holds
  **4** copies of a re-exported package parameter where ours holds 2, on both
  binaries. Same family as the pass's R2 (Earlgrey). This is a 20-line
  reproducer for it.
* **R3 — a module's OWN parameter defaulted from a package parameter keeps a
  typespec golden declines.** `grid_v199/v199_k_override.sv`, `work@kchild.P`
  (`imp=` empty, so not a materialized import). Both binaries, both listings.
* **R4 — `Scoreboard/default` did not move in this verifier's run** where it did
  in the implementer's. Both readings are consistent with RESUME §9's coin; the
  order-blind attribution is what settles it, and neither run shows a content
  change there. Do not treat either count as the number.

---

## 5. THE FILES

| file | what it is |
|---|---|
| `ctv199.cpp` | the verifier's own census. Walks `AllModules`/`TopModules`/`AllPackages`/`TopPackages`/`AllInterfaces`/`AllPrograms` and prints one sorted line per parameter cell: `view\|ownerkind\|ownername\|listing\|index\|param` + typespec kind + `vpiImported`, plus the Rhs constant's type/size/typespec. Build: `g++ -O2 -std=c++17 ctv199.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ctv199` |
| `score.py` | multiset join golden × ours on `view\|ownerkind\|ownername\|listing\|param` (INDEX deliberately out of the key), reporting AGREE / DIFF-G / DIFF-O / ONLY-G / ONLY-O with every differing key printed |
| `asym.py` | golden's own `Parameters` vs `Param_assigns.Lhs` mirror check — the instrument that states the law directly |
| `bnd.sh` / `bnd2.sh` | the wide boundary (list on a file, children `</dev/null`, scratch keyed on the RELATIVE path, `PROCESSED` asserted) |
| `grid_v199/*.sv` | 13 arms: a untyped kinds + localparams, b typed kinds, c one-copy body import, d interface + program, e explicit imports, f three copies, g uvm shape, h exotic literals, i re-export chain, j generate block, k instance override, l paren-cast width (the regression), m its control |
| `GATES` / `ROWMODES` / `GRID` / `ASYMMETRY` / `BOUNDARY` / `BOUNDARY_SCORES` `.r10v199.txt` | the raw evidence |

## 6. REPRODUCING

```bash
git worktree add /tmp/wt 078597b7 && cd /tmp/wt
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/.local
cmake --build build -j 2 && cp build/slang-uhdm /tmp/pris && chmod 555 /tmp/pris
git apply /tmp/r10uvm199.verified.patch && cmake --build build -j 2
cp build/slang-uhdm /tmp/fix && chmod 555 /tmp/fix

cd tools/probe/r10v199repro
g++ -O2 -std=c++17 ctv199.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
    -luhdm -lcapnp -lkj -o /tmp/ctv199
# per arm: build BOTH golden views with ~/git-repos/Surelog/build/bin/surelog
#   -parse -d coveruhdm [-elabuhdm] -nobuiltin -nocache <arm>.sv
# then /tmp/ctv199 on each database and python3 score.py <golden> <ours> <tag>.
# The mirror law itself: python3 asym.py <golden census>  ->  ASYM=0.
```
